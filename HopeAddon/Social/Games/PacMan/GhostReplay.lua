--[[
    HopeAddon Ghost Replay System for Pac-Man
    Shows opponent's pellet collection with a fixed 3-second delay
    Creates a "ghost racing" effect for Score Challenge mode
]]

local GhostReplay = {}
HopeAddon.GhostReplay = GhostReplay

local handlerRefCount = 0

--============================================================
-- SETTINGS
--============================================================

GhostReplay.SETTINGS = {
    REPLAY_DELAY = 3.0,         -- Fixed 3-second delay for ghost replay
    BATCH_INTERVAL = 0.5,       -- Send batches every 0.5 seconds
    MAX_BATCH_SIZE = 10,        -- Max events per message
    GHOST_ALPHA = 0.5,          -- Ghost transparency
    GHOST_COLOR = { r = 0.4, g = 0.8, b = 1.0 },  -- Cyan tint
    TRAIL_LENGTH = 3,           -- Position trail segments
    DISCONNECT_TIMEOUT = 5.0,   -- Fade ghost after 5s of no events
    PELLET_DIM_ALPHA = 0.3,     -- Dimmed pellet alpha when ghost ate it
}

--============================================================
-- STATE FACTORY
--============================================================

--[[
    Create a new ghost replay state
    @return table - Ghost replay state structure
]]
function GhostReplay:CreateState()
    return {
        enabled = true,

        -- Outbound (my events to send)
        outbound = {
            pendingEvents = {},     -- {row, col, time, type}
            batchSequence = 0,
            gameStartTime = 0,
            lastSendTime = 0,
        },

        -- Inbound (opponent events to replay)
        inbound = {
            eventQueue = {},        -- Sorted by replayAt time
            lastSequence = 0,
            lastEventTime = 0,      -- For disconnect detection
            anchorReceivedAt = nil,    -- When first event was received (for timing)
            anchorOpponentTime = nil,  -- Opponent's timestamp of first event (centiseconds)
        },

        -- Visuals
        ghost = {
            frame = nil,            -- Ghost pacman frame
            trail = {},             -- Trail frames
            eatenOverlay = {},      -- [row][col] = true
            lastRow = nil,
            lastCol = nil,
            visible = false,
        },
    }
end

--============================================================
-- INITIALIZATION
--============================================================

--[[
    Initialize ghost replay for a game
    @param gameId string - Game ID
    @param game table - PacManGame game data
    @param opponent string - Opponent name
]]
function GhostReplay:Initialize(gameId, game, opponent)
    if not game or not game.data then return end

    local state = game.data.state

    -- Create ghost replay state
    state.ghostReplay = self:CreateState()
    state.ghostReplay.outbound.gameStartTime = GetTime()
    state.ghostReplay.inbound.lastEventTime = GetTime()
    state.ghostReplay.opponent = opponent
    state.ghostReplay.gameId = gameId
    state.ghostReplay.visualsCreated = false

    -- Register network handler
    self:RegisterHandler(gameId)

    HopeAddon:Debug("GhostReplay initialized for game", gameId)
end

--[[
    Create ghost visuals (called when UI is ready)
    @param gameId string
]]
function GhostReplay:CreateVisuals(gameId)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    local ui = game.data.ui

    if replay.visualsCreated then return end
    if not ui.gridFrame then return end

    self:CreateGhostVisual(replay, ui.gridFrame, PacManGame.SETTINGS.CELL_SIZE)
    replay.visualsCreated = true

    HopeAddon:Debug("GhostReplay visuals created for game", gameId)
end

--============================================================
-- NETWORK HANDLERS
--============================================================

--[[
    Register handler for ghost replay messages
    @param gameId string
]]
function GhostReplay:RegisterHandler(gameId)
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    handlerRefCount = handlerRefCount + 1
    if handlerRefCount == 1 then
        -- Only register on first game
        GameComms:RegisterHandler("GHOST_PACMAN", "MOVE", function(sender, gId, data)
            self:OnReceiveBatch(sender, gId, data)
        end)
    end
end

--[[
    Unregister handler
]]
function GhostReplay:UnregisterHandler()
    handlerRefCount = handlerRefCount - 1
    if handlerRefCount <= 0 then
        handlerRefCount = 0
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:UnregisterHandler("GHOST_PACMAN", "MOVE")
        end
    end
end

--[[
    Handle receiving a batch of pellet events
    @param sender string - Opponent name
    @param gameId string - Game ID
    @param data string - Message format: "seq|t1,r1,c1,P|t2,r2,c2,W|..."
]]
function GhostReplay:OnReceiveBatch(sender, gameId, data)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    -- Find the game
    local game = nil
    for gId, g in pairs(PacManGame.games) do
        if g.data.state.ghostReplay and g.data.state.ghostReplay.opponent == sender then
            game = g
            break
        end
    end

    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    if not replay.enabled then return end

    -- Parse batch
    local parts = { strsplit("|", data) }
    if #parts < 1 then return end

    local seq = tonumber(parts[1])
    if not seq then return end

    -- Check sequence (allow some reordering)
    if seq <= replay.inbound.lastSequence - 5 then
        HopeAddon:Debug("GhostReplay: Ignoring old batch", seq)
        return
    end
    replay.inbound.lastSequence = math.max(replay.inbound.lastSequence, seq)

    local now = GetTime()
    replay.inbound.lastEventTime = now

    -- Parse events (skip first element which is sequence)
    for i = 2, #parts do
        local eventStr = parts[i]
        if eventStr and eventStr ~= "" then
            local t, r, c, typ = strsplit(",", eventStr)
            t = tonumber(t)
            r = tonumber(r)
            c = tonumber(c)

            if t and r and c and typ then
                -- Establish anchor on first event (for timing)
                if not replay.inbound.anchorReceivedAt then
                    replay.inbound.anchorReceivedAt = now
                    replay.inbound.anchorOpponentTime = t  -- centiseconds
                end

                -- Calculate replay time preserving relative spacing
                -- t is centiseconds from opponent's game start
                local opponentElapsedSeconds = (t - replay.inbound.anchorOpponentTime) / 100
                local replayAt = replay.inbound.anchorReceivedAt + opponentElapsedSeconds + self.SETTINGS.REPLAY_DELAY

                -- Insert into queue (sorted by replayAt)
                local event = {
                    row = r,
                    col = c,
                    type = typ,
                    replayAt = replayAt,
                }

                -- Simple insertion sort (queue is usually small)
                local inserted = false
                for j = 1, #replay.inbound.eventQueue do
                    if replayAt < replay.inbound.eventQueue[j].replayAt then
                        table.insert(replay.inbound.eventQueue, j, event)
                        inserted = true
                        break
                    end
                end
                if not inserted then
                    table.insert(replay.inbound.eventQueue, event)
                end
            end
        end
    end
end

--============================================================
-- RECORDING (OUTBOUND)
--============================================================

--[[
    Record a pellet collection event
    @param gameId string
    @param row number
    @param col number
    @param isPower boolean
]]
function GhostReplay:RecordPellet(gameId, row, col, isPower)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    if not replay.enabled then return end

    local now = GetTime()
    local timeOffset = now - replay.outbound.gameStartTime

    local event = {
        row = row,
        col = col,
        time = math.floor(timeOffset * 100),  -- Centiseconds
        type = isPower and "W" or "P",
    }

    table.insert(replay.outbound.pendingEvents, event)

    -- Force immediate send for power pellets
    if isPower then
        self:FlushBatch(gameId)
    end
end

--[[
    Check if it's time to send a batch and send if so
    @param gameId string
    @param dt number - Delta time
]]
function GhostReplay:UpdateOutbound(gameId, dt)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    if not replay.enabled then return end

    local now = GetTime()
    if now - replay.outbound.lastSendTime >= self.SETTINGS.BATCH_INTERVAL then
        if #replay.outbound.pendingEvents > 0 then
            self:FlushBatch(gameId)
        end
    end
end

--[[
    Send pending events as a batch
    @param gameId string
]]
function GhostReplay:FlushBatch(gameId)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    if #replay.outbound.pendingEvents == 0 then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Increment sequence
    replay.outbound.batchSequence = replay.outbound.batchSequence + 1

    -- Build message: "seq|t1,r1,c1,P|t2,r2,c2,W|..."
    local parts = { tostring(replay.outbound.batchSequence) }

    local eventCount = math.min(#replay.outbound.pendingEvents, self.SETTINGS.MAX_BATCH_SIZE)
    for i = 1, eventCount do
        local event = replay.outbound.pendingEvents[i]
        local eventStr = string.format("%d,%d,%d,%s", event.time, event.row, event.col, event.type)
        table.insert(parts, eventStr)
    end

    local message = table.concat(parts, "|")

    -- Remove sent events
    for i = 1, eventCount do
        table.remove(replay.outbound.pendingEvents, 1)
    end

    -- Send to opponent
    GameComms:SendMove(replay.opponent, "GHOST_PACMAN", gameId, message)

    replay.outbound.lastSendTime = GetTime()
end

--============================================================
-- REPLAY (INBOUND)
--============================================================

--[[
    Update ghost replay - process event queue and update visuals
    @param gameId string
    @param dt number - Delta time
]]
function GhostReplay:UpdateReplay(gameId, dt)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay
    local state = game.data.state
    local ui = game.data.ui

    if not replay.enabled then return end

    local now = GetTime()

    -- Check for disconnect (no events for DISCONNECT_TIMEOUT)
    if now - replay.inbound.lastEventTime > self.SETTINGS.DISCONNECT_TIMEOUT then
        if replay.ghost.visible then
            self:FadeOutGhost(replay)
        end
        return
    end

    -- Process events from queue
    while #replay.inbound.eventQueue > 0 and replay.inbound.eventQueue[1].replayAt <= now do
        local event = table.remove(replay.inbound.eventQueue, 1)

        -- Move ghost to this position
        self:MoveGhostTo(replay, event.row, event.col, ui, PacManGame.SETTINGS.CELL_SIZE)

        -- Mark pellet as ghost-eaten (visual only)
        self:MarkPelletEaten(replay, state, ui, event.row, event.col)
    end
end

--============================================================
-- GHOST VISUAL
--============================================================

--[[
    Create the ghost visual (cyan-tinted pacman)
    @param replay table - Ghost replay state
    @param parent Frame - Grid frame
    @param cellSize number
]]
function GhostReplay:CreateGhostVisual(replay, parent, cellSize)
    local S = self.SETTINGS
    local size = cellSize - 2

    -- Main ghost frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)
    frame:SetFrameLevel(parent:GetFrameLevel() + 8)
    frame:SetAlpha(S.GHOST_ALPHA)

    -- Cyan-tinted pacman body
    local body = frame:CreateTexture(nil, "ARTWORK")
    body:SetAllPoints()
    body:SetTexture("Interface\\COMMON\\Indicator-Yellow")
    body:SetVertexColor(S.GHOST_COLOR.r, S.GHOST_COLOR.g, S.GHOST_COLOR.b, 1)

    -- Ghost label
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    label:SetText("GHOST")
    label:SetTextColor(S.GHOST_COLOR.r, S.GHOST_COLOR.g, S.GHOST_COLOR.b, 0.8)

    frame.body = body
    frame.label = label
    frame:Hide()

    replay.ghost.frame = frame

    -- Create trail frames
    for i = 1, S.TRAIL_LENGTH do
        local trailFrame = CreateFrame("Frame", nil, parent)
        trailFrame:SetSize(size * 0.7, size * 0.7)
        trailFrame:SetFrameLevel(parent:GetFrameLevel() + 7)
        trailFrame:SetAlpha(S.GHOST_ALPHA * (1 - i / (S.TRAIL_LENGTH + 1)))

        local trailBody = trailFrame:CreateTexture(nil, "ARTWORK")
        trailBody:SetAllPoints()
        trailBody:SetTexture("Interface\\COMMON\\Indicator-Yellow")
        trailBody:SetVertexColor(S.GHOST_COLOR.r, S.GHOST_COLOR.g, S.GHOST_COLOR.b, 1)

        trailFrame.body = trailBody
        trailFrame:Hide()

        replay.ghost.trail[i] = {
            frame = trailFrame,
            row = nil,
            col = nil,
        }
    end
end

--[[
    Move ghost to a new position
    @param replay table
    @param row number
    @param col number
    @param ui table - Game UI
    @param cellSize number
]]
function GhostReplay:MoveGhostTo(replay, row, col, ui, cellSize)
    local ghost = replay.ghost
    if not ghost.frame or not ui.gridFrame then return end

    -- Update trail positions
    for i = self.SETTINGS.TRAIL_LENGTH, 2, -1 do
        ghost.trail[i].row = ghost.trail[i - 1].row
        ghost.trail[i].col = ghost.trail[i - 1].col
    end
    if ghost.lastRow then
        ghost.trail[1].row = ghost.lastRow
        ghost.trail[1].col = ghost.lastCol
    end

    -- Position trail frames
    for i, trail in ipairs(ghost.trail) do
        if trail.row and trail.col then
            trail.frame:ClearAllPoints()
            trail.frame:SetPoint("TOPLEFT", ui.gridFrame, "TOPLEFT",
                (trail.col - 1) * cellSize + 1 + (cellSize * 0.15),
                -((trail.row - 1) * cellSize + 1 + (cellSize * 0.15)))
            trail.frame:Show()
        end
    end

    -- Move main ghost
    ghost.frame:ClearAllPoints()
    ghost.frame:SetPoint("TOPLEFT", ui.gridFrame, "TOPLEFT",
        (col - 1) * cellSize + 1,
        -((row - 1) * cellSize + 1))

    if not ghost.visible then
        ghost.frame:Show()
        ghost.visible = true
    end

    ghost.lastRow = row
    ghost.lastCol = col
end

--[[
    Fade out ghost when opponent disconnects
    @param replay table
]]
function GhostReplay:FadeOutGhost(replay)
    local ghost = replay.ghost
    if not ghost.frame then return end

    -- Simple hide (could add fade animation)
    ghost.frame:Hide()
    for _, trail in ipairs(ghost.trail) do
        trail.frame:Hide()
    end

    ghost.visible = false
end

--============================================================
-- PELLET OVERLAY
--============================================================

--[[
    Mark a pellet as eaten by the ghost (visual dimming only)
    @param replay table
    @param state table - Game state
    @param ui table - Game UI
    @param row number
    @param col number
]]
function GhostReplay:MarkPelletEaten(replay, state, ui, row, col)
    local Maps = HopeAddon.PacManMaps
    if not Maps then return end

    -- Only show overlay if pellet still exists for local player
    local cellType = state.map[row] and state.map[row][col]
    if cellType == Maps.CELL.PELLET or cellType == Maps.CELL.POWER then
        local cell = ui.cells[row] and ui.cells[row][col]
        if cell and cell.pellet then
            -- Dim to show ghost ate it
            local S = self.SETTINGS
            cell.pellet:SetVertexColor(
                S.GHOST_COLOR.r * 0.5,
                S.GHOST_COLOR.g * 0.5,
                S.GHOST_COLOR.b * 0.5,
                S.PELLET_DIM_ALPHA
            )
        end
    end

    -- Track for cleanup on level reset
    replay.ghost.eatenOverlay[row] = replay.ghost.eatenOverlay[row] or {}
    replay.ghost.eatenOverlay[row][col] = true
end

--[[
    Reset pellet overlays (called on level transition)
    @param replay table
    @param ui table
]]
function GhostReplay:ResetPelletOverlays(replay, ui)
    if not replay or not replay.ghost.eatenOverlay then return end

    -- Just clear tracking - pellets get re-rendered on level reset
    wipe(replay.ghost.eatenOverlay)

    -- Clear event queue for new level
    wipe(replay.inbound.eventQueue)

    -- Reset anchor for new level (fresh timeline)
    replay.inbound.anchorReceivedAt = nil
    replay.inbound.anchorOpponentTime = nil

    -- Reset ghost position
    if replay.ghost.frame then
        replay.ghost.frame:Hide()
    end
    for _, trail in ipairs(replay.ghost.trail) do
        trail.frame:Hide()
        trail.row = nil
        trail.col = nil
    end
    replay.ghost.visible = false
    replay.ghost.lastRow = nil
    replay.ghost.lastCol = nil
end

--============================================================
-- CLEANUP
--============================================================

--[[
    Clean up ghost replay resources
    @param gameId string
]]
function GhostReplay:Cleanup(gameId)
    local PacManGame = HopeAddon:GetModule("PacManGame")
    if not PacManGame then return end

    local game = PacManGame.games[gameId]
    if not game or not game.data.state.ghostReplay then return end

    local replay = game.data.state.ghostReplay

    -- Destroy ghost frame
    if replay.ghost.frame then
        replay.ghost.frame:Hide()
        replay.ghost.frame:SetParent(nil)
        replay.ghost.frame = nil
    end

    -- Destroy trail frames
    for _, trail in ipairs(replay.ghost.trail) do
        if trail.frame then
            trail.frame:Hide()
            if trail.frame.body then
                trail.frame.body = nil
            end
            trail.frame:SetParent(nil)
            trail.frame = nil
        end
    end

    -- Unregister handler
    self:UnregisterHandler()

    -- Clear state
    game.data.state.ghostReplay = nil

    HopeAddon:Debug("GhostReplay cleaned up for game", gameId)
end

HopeAddon:Debug("GhostReplay module loaded")
