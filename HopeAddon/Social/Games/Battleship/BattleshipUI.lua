--[[
    HopeAddon Battleship UI
    Gameshow-style visual effects for Battleship game
    Follows the Death Roll UI pattern for consistency
]]

local BattleshipUI = {}

-- Use centralized backdrop frame creation from Core.lua
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

--============================================================
-- CONSTANTS
--============================================================

-- Shot result types with colors and messages
local SHOT_RESULTS = {
    HIT = {
        text = "HIT!",
        color = { r = 0.8, g = 0.2, b = 0.2 },
        sound = "hit",
    },
    MISS = {
        text = "MISS",
        color = { r = 0.4, g = 0.6, b = 0.9 },
        sound = "miss",
    },
    SUNK = {
        text = "SUNK!",
        color = { r = 1.0, g = 0.0, b = 0.0 },
        sound = "sunk",
    },
}

-- Turn states with visual styles
local TURN_STATES = {
    YOUR_TURN = {
        text = "YOUR TURN!",
        color = { r = 0.2, g = 1.0, b = 0.2 },
        borderColor = { r = 1.0, g = 0.84, b = 0 },
        hint = "/fire A5  or click enemy grid",
        pulse = true,
    },
    ENEMY_TURN = {
        text = "Waiting...",
        color = { r = 0.6, g = 0.6, b = 0.6 },
        borderColor = { r = 0.4, g = 0.4, b = 0.4 },
        hint = nil,
        pulse = false,
    },
    PLACEMENT = {
        text = "PLACE YOUR SHIPS",
        color = { r = 0.4, g = 0.7, b = 1.0 },
        borderColor = { r = 0.4, g = 0.7, b = 1.0 },
        hint = "Click grid to place | R to rotate",
        pulse = false,
    },
}

-- Animation timing constants (in seconds)
local ANIMATION_TIMING = {
    SUSPENSE_DELAY = 0.05,      -- Time before showing result
    REVEAL_DURATION = 0.4,      -- PopIn animation duration
    COORD_DELAY = 0.15,         -- Delay before showing coordinate
    SUNK_DELAY = 0.5,           -- Delay before showing ship name (if sunk)
    FADE_START = 1.0,           -- When to start fading out
    TOTAL_SEQUENCE = 1.4,       -- Total animation lock time
}

-- Colors
local COLORS = {
    GOLD = { r = 1, g = 0.84, b = 0 },
    MUTED = { r = 0.6, g = 0.6, b = 0.6 },
    VICTORY = { r = 0.2, g = 1, b = 0.2 },
    DEFEAT = { r = 1, g = 0.2, b = 0.2 },
}

-- Consistent backdrop for frames
local WINDOW_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

--============================================================
-- MODULE STATE
--============================================================

-- Frame pools for efficient memory management
BattleshipUI.shotResultPool = nil
BattleshipUI.turnPromptPool = nil

-- Per-game UI frames
BattleshipUI.gameFrames = {}  -- [gameId] = { shotResult, turnPrompt, victory }

-- Animation timers (for cleanup)
BattleshipUI.animationTimers = {}  -- [gameId] = { timer handles }

--============================================================
-- LIFECYCLE
--============================================================

function BattleshipUI:OnInitialize()
    HopeAddon:Debug("BattleshipUI initializing...")
end

function BattleshipUI:OnEnable()
    HopeAddon:Debug("BattleshipUI enabled")
    self:CreateFramePools()
end

function BattleshipUI:OnDisable()
    -- Clean up all game frames
    for gameId, _ in pairs(self.gameFrames) do
        self:CleanupGameFrames(gameId)
    end
    wipe(self.gameFrames)

    -- Cancel all animation timers
    for gameId, timers in pairs(self.animationTimers) do
        for _, timer in ipairs(timers) do
            if timer and timer.Cancel then timer:Cancel() end
        end
    end
    wipe(self.animationTimers)

    -- Destroy frame pools
    if self.shotResultPool then
        self.shotResultPool:Destroy()
        self.shotResultPool = nil
    end
    if self.turnPromptPool then
        self.turnPromptPool:Destroy()
        self.turnPromptPool = nil
    end
end

--============================================================
-- FRAME POOLS
--============================================================

function BattleshipUI:CreateFramePools()
    local FramePool = HopeAddon.FramePool
    if not FramePool then
        HopeAddon:Debug("FramePool not available, BattleshipUI pools disabled")
        return
    end

    -- Shot result frame pool (shows HIT!/MISS/SUNK!)
    self.shotResultPool = FramePool:NewNamed("Battleship_ShotResult",
        -- Create function
        function()
            local container = CreateFrame("Frame", nil, UIParent)
            container:SetSize(200, 100)

            -- Semi-transparent background for focus
            local bg = container:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0, 0, 0, 0.4)
            container.bg = bg

            -- Main result text (HIT!/MISS/SUNK!)
            local resultText = container:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
            resultText:SetPoint("CENTER", container, "CENTER", 0, 15)
            resultText:SetText("")
            container.resultText = resultText

            -- Coordinate text below
            local coordText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            coordText:SetPoint("TOP", resultText, "BOTTOM", 0, -5)
            coordText:SetText("")
            container.coordText = coordText

            -- Ship name (for SUNK)
            local shipText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            shipText:SetPoint("TOP", coordText, "BOTTOM", 0, -3)
            shipText:SetText("")
            container.shipText = shipText

            container:Hide()
            return container
        end,
        -- Reset function
        function(frame)
            frame:Hide()
            frame:SetAlpha(0)
            frame:ClearAllPoints()
            frame:SetParent(UIParent)
            frame.resultText:SetText("")
            frame.coordText:SetText("")
            frame.shipText:SetText("")
            -- Stop any active effects
            if HopeAddon.Effects then
                HopeAddon.Effects:StopGlowsOnParent(frame)
            end
        end
    )

    -- Turn prompt frame pool
    self.turnPromptPool = FramePool:NewNamed("Battleship_TurnPrompt",
        -- Create function
        function()
            local frame = CreateBackdropFrame("Frame", nil, UIParent)
            frame:SetSize(250, 50)

            frame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            frame:SetBackdropColor(0.1, 0.08, 0.15, 0.95)

            -- Main prompt text
            local promptText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            promptText:SetPoint("TOP", frame, "TOP", 0, -8)
            promptText:SetText("")
            frame.promptText = promptText

            -- Command hint text
            local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            hintText:SetPoint("TOP", promptText, "BOTTOM", 0, -3)
            hintText:SetText("")
            hintText:SetTextColor(0.7, 0.7, 0.7)
            frame.hintText = hintText

            frame:Hide()
            return frame
        end,
        -- Reset function
        function(frame)
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)
            frame:SetBackdropBorderColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b, 1)
            frame.promptText:SetText("")
            frame.hintText:SetText("")
            -- Stop any active effects
            if HopeAddon.Effects then
                HopeAddon.Effects:StopGlowsOnParent(frame)
            end
        end
    )

    HopeAddon:Debug("BattleshipUI frame pools created")
end

--============================================================
-- FRAME ACQUISITION
--============================================================

function BattleshipUI:AcquireShotResultFrame(parent)
    if self.shotResultPool then
        local frame = self.shotResultPool:Acquire()
        frame:SetParent(parent)
        return frame
    end

    -- Fallback: create directly if pool unavailable
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 100)

    local bg = container:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.4)
    container.bg = bg

    local resultText = container:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
    resultText:SetPoint("CENTER", container, "CENTER", 0, 15)
    container.resultText = resultText

    local coordText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    coordText:SetPoint("TOP", resultText, "BOTTOM", 0, -5)
    container.coordText = coordText

    local shipText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    shipText:SetPoint("TOP", coordText, "BOTTOM", 0, -3)
    container.shipText = shipText

    return container
end

function BattleshipUI:AcquireTurnPromptFrame(parent)
    if self.turnPromptPool then
        local frame = self.turnPromptPool:Acquire()
        frame:SetParent(parent)
        return frame
    end

    -- Fallback: create directly if pool unavailable
    local frame = CreateBackdropFrame("Frame", nil, parent)
    frame:SetSize(250, 50)
    frame:SetBackdrop(WINDOW_BACKDROP)
    frame:SetBackdropColor(0.1, 0.08, 0.15, 0.95)

    local promptText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    promptText:SetPoint("TOP", frame, "TOP", 0, -8)
    frame.promptText = promptText

    local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hintText:SetPoint("TOP", promptText, "BOTTOM", 0, -3)
    hintText:SetTextColor(0.7, 0.7, 0.7)
    frame.hintText = hintText

    return frame
end

--============================================================
-- GAME FRAME MANAGEMENT
--============================================================

function BattleshipUI:InitializeGameFrames(gameId, parent)
    if self.gameFrames[gameId] then
        return self.gameFrames[gameId]
    end

    local frames = {
        shotResult = self:AcquireShotResultFrame(parent),
        turnPrompt = self:AcquireTurnPromptFrame(parent),
        victory = nil,  -- Created on demand
    }

    -- Position shot result in center
    frames.shotResult:SetPoint("CENTER", parent, "CENTER", 0, 0)

    -- Position turn prompt at bottom
    frames.turnPrompt:SetPoint("BOTTOM", parent, "BOTTOM", 0, 5)

    self.gameFrames[gameId] = frames
    self.animationTimers[gameId] = {}

    return frames
end

function BattleshipUI:CleanupGameFrames(gameId)
    local frames = self.gameFrames[gameId]
    if not frames then return end

    -- Release pooled frames
    if frames.shotResult then
        if self.shotResultPool then
            self.shotResultPool:Release(frames.shotResult)
        else
            frames.shotResult:Hide()
        end
    end

    if frames.turnPrompt then
        if self.turnPromptPool then
            self.turnPromptPool:Release(frames.turnPrompt)
        else
            frames.turnPrompt:Hide()
        end
    end

    if frames.victory then
        frames.victory:Hide()
        frames.victory:SetParent(nil)
    end

    self.gameFrames[gameId] = nil

    -- Cancel animation timers
    local timers = self.animationTimers[gameId]
    if timers then
        for _, timer in ipairs(timers) do
            if timer and timer.Cancel then timer:Cancel() end
        end
        self.animationTimers[gameId] = nil
    end
end

--============================================================
-- SHOT RESULT ANIMATION
--============================================================

--[[
    Show shot result with gameshow animation
    @param gameId string - Game identifier
    @param resultType string - "HIT", "MISS", or "SUNK"
    @param coord string - Coordinate string like "B5"
    @param shipName string|nil - Ship name if sunk
    @param isPlayerShot boolean - True if player fired the shot
]]
function BattleshipUI:ShowShotResult(gameId, resultType, coord, shipName, isPlayerShot)
    local frames = self.gameFrames[gameId]
    if not frames or not frames.shotResult then return end

    local result = SHOT_RESULTS[resultType] or SHOT_RESULTS.MISS
    local shotFrame = frames.shotResult

    -- Cancel any existing animations for this game
    local timers = self.animationTimers[gameId] or {}
    for _, timer in ipairs(timers) do
        if timer and timer.Cancel then timer:Cancel() end
    end
    self.animationTimers[gameId] = {}

    -- Hide turn prompt during animation
    if frames.turnPrompt then
        frames.turnPrompt:Hide()
    end

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:Play("battleship", result.sound)
    end

    -- Set up initial state
    shotFrame.resultText:SetText(result.text)
    shotFrame.resultText:SetTextColor(result.color.r, result.color.g, result.color.b)
    shotFrame.coordText:SetText("")
    shotFrame.shipText:SetText("")
    shotFrame:SetAlpha(0)
    shotFrame:Show()

    -- Animation sequence
    local newTimers = {}

    -- Step 1: Reveal result text with PopIn
    table.insert(newTimers, HopeAddon.Timer:After(ANIMATION_TIMING.SUSPENSE_DELAY, function()
        if HopeAddon.Effects then
            HopeAddon.Effects:PopIn(shotFrame, ANIMATION_TIMING.REVEAL_DURATION)
        else
            shotFrame:SetAlpha(1)
        end
    end))

    -- Step 2: Show coordinate
    table.insert(newTimers, HopeAddon.Timer:After(ANIMATION_TIMING.SUSPENSE_DELAY + ANIMATION_TIMING.COORD_DELAY, function()
        shotFrame.coordText:SetText("[" .. coord .. "]")
        shotFrame.coordText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
    end))

    -- Step 3: If SUNK, show ship name with burst effect
    if resultType == "SUNK" and shipName then
        table.insert(newTimers, HopeAddon.Timer:After(ANIMATION_TIMING.SUNK_DELAY, function()
            shotFrame.shipText:SetText(shipName .. " destroyed!")
            shotFrame.shipText:SetTextColor(1, 0.5, 0.5)

            -- Burst effect
            if HopeAddon.Effects then
                HopeAddon.Effects:CreateBurstEffect(shotFrame, "HELLFIRE_RED")
            end
        end))
    end

    -- Step 4: Fade out
    table.insert(newTimers, HopeAddon.Timer:After(ANIMATION_TIMING.FADE_START, function()
        if HopeAddon.Effects then
            HopeAddon.Effects:FadeOut(shotFrame, 0.4)
        else
            shotFrame:SetAlpha(0)
        end
    end))

    -- Step 5: Hide and show turn prompt
    table.insert(newTimers, HopeAddon.Timer:After(ANIMATION_TIMING.TOTAL_SEQUENCE, function()
        shotFrame:Hide()
    end))

    self.animationTimers[gameId] = newTimers
end

--============================================================
-- TURN PROMPT
--============================================================

--[[
    Show turn prompt banner
    @param gameId string - Game identifier
    @param turnState string - "YOUR_TURN", "ENEMY_TURN", or "PLACEMENT"
    @param opponentName string|nil - Opponent name for waiting message
    @param shipInfo string|nil - Ship placement info for PLACEMENT state
]]
function BattleshipUI:ShowTurnPrompt(gameId, turnState, opponentName, shipInfo)
    local frames = self.gameFrames[gameId]
    if not frames or not frames.turnPrompt then return end

    local state = TURN_STATES[turnState] or TURN_STATES.ENEMY_TURN
    local prompt = frames.turnPrompt

    -- Set text
    if turnState == "ENEMY_TURN" and opponentName then
        prompt.promptText:SetText("Waiting for " .. opponentName .. "...")
    elseif turnState == "PLACEMENT" and shipInfo then
        prompt.promptText:SetText("Place: " .. shipInfo)
    else
        prompt.promptText:SetText(state.text)
    end

    prompt.promptText:SetTextColor(state.color.r, state.color.g, state.color.b)

    -- Set hint
    if state.hint then
        prompt.hintText:SetText(state.hint)
        prompt.hintText:Show()
    else
        prompt.hintText:Hide()
    end

    -- Set border color
    prompt:SetBackdropBorderColor(state.borderColor.r, state.borderColor.g, state.borderColor.b, 1)

    -- Add pulsing glow for YOUR_TURN
    if state.pulse and HopeAddon.Effects then
        HopeAddon.Effects:CreatePulsingGlow(prompt, "GOLD_BRIGHT")

        -- Play turn notification sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:Play("battleship", "yourTurn")
        end
    end

    prompt:Show()
end

function BattleshipUI:HideTurnPrompt(gameId)
    local frames = self.gameFrames[gameId]
    if not frames or not frames.turnPrompt then return end

    frames.turnPrompt:Hide()

    -- Stop any glows
    if HopeAddon.Effects then
        HopeAddon.Effects:StopGlowsOnParent(frames.turnPrompt)
    end
end

--============================================================
-- SHIP SUNK CELEBRATION
--============================================================

--[[
    Show ship sunk celebration
    @param gameId string - Game identifier
    @param shipName string - Name of the sunk ship
    @param isEnemy boolean - True if enemy ship was sunk
    @param cells table|nil - Array of {row, col} for sparkle positions
]]
function BattleshipUI:ShowShipSunkCelebration(gameId, shipName, isEnemy, cells)
    if not HopeAddon.Effects then return end

    local frames = self.gameFrames[gameId]
    if not frames then return end

    if isEnemy then
        -- Victory sparkles when we sink enemy ship
        if frames.shotResult and frames.shotResult:GetParent() then
            HopeAddon.Effects:CreateSparkles(frames.shotResult:GetParent(), 8, "FEL_GREEN")
        end
    else
        -- Shake effect when our ship is sunk
        if frames.turnPrompt then
            HopeAddon.Effects:Shake(frames.turnPrompt, 5, 0.3)
        end
    end
end

--============================================================
-- VICTORY/DEFEAT OVERLAY
--============================================================

--[[
    Show victory or defeat overlay
    @param gameId string - Game identifier
    @param didWin boolean - True if player won
    @param stats table - Game statistics { shipsRemaining, shotsFired }
]]
function BattleshipUI:ShowVictoryOverlay(gameId, didWin, stats)
    local frames = self.gameFrames[gameId]
    if not frames then return end

    -- Get parent window
    local parent = frames.turnPrompt and frames.turnPrompt:GetParent()
    if not parent then return end

    -- Create victory overlay
    local overlay = CreateBackdropFrame("Frame", nil, parent)
    overlay:SetAllPoints()
    overlay:SetFrameStrata("DIALOG")

    overlay:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local color = didWin and COLORS.VICTORY or COLORS.DEFEAT
    overlay:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    overlay:SetBackdropBorderColor(color.r, color.g, color.b, 1)

    -- Title
    local title = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", overlay, "TOP", 0, -30)
    title:SetText(didWin and "VICTORY!" or "DEFEAT")
    title:SetTextColor(color.r, color.g, color.b)

    -- Subtitle
    local subtitle = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -10)
    subtitle:SetText(didWin and "All enemy ships destroyed!" or "Your fleet was destroyed!")
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    -- Stats
    if stats then
        local statsText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statsText:SetPoint("TOP", subtitle, "BOTTOM", 0, -20)

        local statsStr = ""
        if stats.shipsRemaining then
            statsStr = statsStr .. "Ships Remaining: " .. stats.shipsRemaining .. "/5\n"
        end
        if stats.shotsFired then
            statsStr = statsStr .. "Shots Fired: " .. stats.shotsFired
        end
        statsText:SetText(statsStr)
        statsText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
    end

    -- Close button
    local closeBtn = CreateFrame("Button", nil, overlay, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 24)
    closeBtn:SetPoint("BOTTOM", overlay, "BOTTOM", 0, 20)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        overlay:Hide()
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:DestroyGame(gameId)
        end
    end)

    -- Play sounds and effects
    if HopeAddon.Sounds then
        if didWin then
            HopeAddon.Sounds:Play("battleship", "victory")
        else
            HopeAddon.Sounds:Play("battleship", "defeat")
        end
    end

    if didWin and HopeAddon.Effects then
        HopeAddon.Effects:Celebrate(overlay, 2.0)
    end

    frames.victory = overlay
    overlay:Show()
end

--============================================================
-- PUBLIC API
--============================================================

-- Check if animation is currently playing
function BattleshipUI:IsAnimating(gameId)
    local timers = self.animationTimers[gameId]
    return timers and #timers > 0
end

-- Get animation lock time for callers to wait
function BattleshipUI:GetAnimationDuration()
    return ANIMATION_TIMING.TOTAL_SEQUENCE
end

-- Register module
HopeAddon:RegisterModule("BattleshipUI", BattleshipUI)
HopeAddon:Debug("BattleshipUI module loaded")
