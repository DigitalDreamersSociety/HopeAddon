--[[
    HopeAddon Words with WoW Invites
    Handles multiplayer invite/accept/decline flow for async games
]]

local WordGameInvites = {}

--============================================================
-- CONSTANTS
--============================================================

-- Message types (prefixed to GSYNC data)
local MSG_PREFIX = {
    INVITE = "WINV",     -- Game invite with initial state
    ACCEPT = "WACC",     -- Accept invite
    DECLINE = "WDEC",    -- Decline invite
    SYNC = "WSYNC",      -- Full state sync
    RESUME = "WRES",     -- Resume request
}

-- Invite timeout (24 hours)
local INVITE_TIMEOUT = 24 * 60 * 60

--============================================================
-- MODULE STATE
--============================================================

WordGameInvites.pendingInvites = {}  -- Runtime copy of storage
WordGameInvites.sentInvites = {}     -- Runtime copy of storage

--============================================================
-- LIFECYCLE
--============================================================

function WordGameInvites:OnInitialize()
    HopeAddon:Debug("WordGameInvites initializing...")
end

function WordGameInvites:OnEnable()
    -- Register communication handlers
    self:RegisterHandlers()

    -- Sync with persistence
    self:SyncFromStorage()

    HopeAddon:Debug("WordGameInvites enabled")
end

function WordGameInvites:OnDisable()
    -- Save pending invites back to storage
    self:SyncToStorage()
end

--[[
    Sync in-memory state from persistent storage
]]
function WordGameInvites:SyncFromStorage()
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if not Persistence then return end

    self.pendingInvites = Persistence:GetAllPendingInvites() or {}
    self.sentInvites = Persistence:GetAllSentInvites() or {}
end

--[[
    Sync in-memory state to persistent storage
]]
function WordGameInvites:SyncToStorage()
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if not Persistence then return end

    -- Already synced via Persistence module, nothing extra needed
end

--============================================================
-- NETWORK HANDLERS
--============================================================

function WordGameInvites:RegisterHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Register SYNC handler for Words messages
    GameComms:RegisterHandler("WORDS", "SYNC", function(sender, gameId, data)
        self:HandleSyncMessage(sender, gameId, data)
    end)
end

--[[
    Handle SYNC messages (invites, accepts, declines, syncs, resumes)
]]
function WordGameInvites:HandleSyncMessage(sender, gameId, data)
    if not data or data == "" then return end

    -- Fix #18: Notify persistence that we're processing a message
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        Persistence:BeginMessageProcessing()
    end

    -- Parse prefix
    local prefix, payload = data:match("^(%u+):(.*)$")
    if not prefix then
        -- No prefix, might be old format or raw sync
        prefix = "WSYNC"
        payload = data
    end

    if prefix == MSG_PREFIX.INVITE then
        self:HandleInviteReceived(sender, gameId, payload)
    elseif prefix == MSG_PREFIX.ACCEPT then
        self:HandleAcceptReceived(sender, gameId, payload)
    elseif prefix == MSG_PREFIX.DECLINE then
        self:HandleDeclineReceived(sender, gameId, payload)
    elseif prefix == MSG_PREFIX.SYNC then
        self:HandleStateSync(sender, gameId, payload)
    elseif prefix == MSG_PREFIX.RESUME then
        self:HandleResumeRequest(sender, gameId, payload)
    end

    -- Fix #18: End message processing flag
    if Persistence then
        Persistence:EndMessageProcessing()
    end
end

--============================================================
-- INVITE FLOW
--============================================================

--[[
    Send a game invite to another player
    @param opponent string - Target player name
    @return string|nil - Game ID if invite sent
]]
function WordGameInvites:SendInvite(opponent)
    local playerName = UnitName("player")

    if not opponent or opponent == playerName then
        HopeAddon:Print("Cannot invite yourself!")
        return nil
    end

    -- Check if already have active game with this player
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence and Persistence:HasGame(opponent) then
        HopeAddon:Print("You already have an active game with " .. opponent)
        HopeAddon:Print("Use /hope words " .. opponent .. " to continue it.")
        return nil
    end

    -- Check if already have pending invite to this player
    if self.sentInvites[opponent] then
        HopeAddon:Print("You already have a pending invite to " .. opponent)
        return nil
    end

    -- Check max concurrent games
    if Persistence and Persistence:GetGameCount() >= Persistence.CONFIG.MAX_CONCURRENT_GAMES then
        HopeAddon:Print("Maximum concurrent games reached (" .. Persistence.CONFIG.MAX_CONCURRENT_GAMES .. ")")
        return nil
    end

    -- Verify opponent is a Fellow Traveler (has addon)
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if FellowTravelers and not FellowTravelers:IsFellow(opponent) then
        HopeAddon:Print(opponent .. " doesn't have the addon or isn't online.")
        return nil
    end

    -- Generate game ID
    local gameId = string.format("WG_%s_%s_%d", playerName, opponent, time())

    -- Create initial game state
    local initialState = {
        version = 1,
        gameId = gameId,
        createdAt = time(),
        lastMoveAt = time(),
        player1 = playerName,
        player2 = opponent,
        currentTurn = "PLAYER1_TURN",
        board = {},  -- Empty board
        scores = {
            [playerName] = 0,
            [opponent] = 0,
        },
        moveHistory = {},
        consecutivePasses = 0,
        turnCount = 0,
        state = "WAITING_ACCEPT",
    }

    -- Store sent invite
    self.sentInvites[opponent] = {
        state = initialState,
        timestamp = time(),
    }

    -- Save to persistence
    if Persistence then
        Persistence:SaveSentInvite(opponent, initialState)
    end

    -- Send via GameComms
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        local payload = MSG_PREFIX.INVITE .. ":" .. self:SerializeState(initialState)
        GameComms:SendGameMessage(opponent, "GSYNC", "WORDS", gameId, payload)
    end

    HopeAddon:Print("Sent Words with WoW invite to " .. opponent)
    HopeAddon:Print("Invite expires in 24 hours.")

    return gameId
end

--[[
    Accept a pending invite
    @param senderName string - Who sent the invite
]]
function WordGameInvites:AcceptInvite(senderName)
    local invite = self.pendingInvites[senderName]
    if not invite then
        HopeAddon:Print("No pending invite from " .. (senderName or "anyone"))
        return false
    end

    local gameState = invite.state
    local playerName = UnitName("player")

    -- Update state to playing
    gameState.state = "PLAYING"
    gameState.lastMoveAt = time()

    -- Save game to persistence (Fix #2 & #17: Construct proper game state for SaveGame)
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        -- Create a proper game structure that SerializeGame expects
        -- For new games from invites, board is empty so we pass an empty sparse board directly
        local savedState = {
            version = 1,
            gameId = gameState.gameId,
            createdAt = gameState.createdAt,
            lastMoveAt = time(),
            player1 = gameState.player1,
            player2 = gameState.player2,
            currentTurn = gameState.currentTurn,
            board = gameState.board or {},  -- Include board data from invite
            scores = gameState.scores or {},
            moveHistory = gameState.moveHistory or {},
            consecutivePasses = gameState.consecutivePasses or 0,
            turnCount = gameState.turnCount or 0,
            state = "PLAYING",
            tileBag = {},  -- Empty for now, will be created on resume
            playerHands = {},  -- Empty for now, will be dealt on resume
        }
        -- Save directly to storage (bypass SerializeGame since we have raw state)
        Persistence:EnsureStorage()
        local storage = HopeAddon.charDb and HopeAddon.charDb.savedGames
            and HopeAddon.charDb.savedGames.words
        if storage then
            storage.games[senderName] = savedState
        end
        Persistence:ClearPendingInvite(senderName)
    end

    -- Clear from runtime
    self.pendingInvites[senderName] = nil

    -- Send accept message
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        local payload = MSG_PREFIX.ACCEPT .. ":" .. gameState.gameId
        GameComms:SendGameMessage(senderName, "GSYNC", "WORDS", gameState.gameId, payload)
    end

    HopeAddon:Print("Accepted Words with WoW from " .. senderName .. "!")
    HopeAddon:Print("Use /hope words " .. senderName .. " to start playing.")

    return true
end

--[[
    Decline a pending invite
    @param senderName string - Who sent the invite
]]
function WordGameInvites:DeclineInvite(senderName)
    local invite = self.pendingInvites[senderName]
    if not invite then return end

    local gameId = invite.state and invite.state.gameId or ""

    -- Clear from persistence
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        Persistence:ClearPendingInvite(senderName)
    end

    -- Clear from runtime
    self.pendingInvites[senderName] = nil

    -- Send decline message
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        local payload = MSG_PREFIX.DECLINE .. ":" .. gameId
        GameComms:SendGameMessage(senderName, "GSYNC", "WORDS", gameId, payload)
    end

    HopeAddon:Print("Declined Words invite from " .. senderName)
end

--============================================================
-- INCOMING MESSAGE HANDLERS
--============================================================

--[[
    Handle incoming invite
]]
function WordGameInvites:HandleInviteReceived(sender, gameId, payload)
    local gameState = self:DeserializeState(payload)
    if not gameState then
        HopeAddon:Debug("WordGameInvites: Failed to parse invite from", sender)
        return
    end

    -- Store pending invite
    self.pendingInvites[sender] = {
        state = gameState,
        timestamp = time(),
    }

    -- Save to persistence
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        Persistence:SavePendingInvite(sender, gameState)
    end

    -- Play notification sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    -- Show notification
    HopeAddon:Print("|cFF9B30FF[Words with WoW]|r " .. sender .. " challenges you!")
    HopeAddon:Print("Type /hope words accept " .. sender .. " or /hope words decline " .. sender)

    -- Show popup if MinigamesUI available
    local MinigamesUI = HopeAddon:GetModule("MinigamesUI")
    if MinigamesUI and MinigamesUI.ShowChallengePopup then
        MinigamesUI:ShowChallengePopup(sender, "WORDS", gameId, "wordsinvites")
    end
end

--[[
    Handle invite accepted
]]
function WordGameInvites:HandleAcceptReceived(sender, gameId, payload)
    local invite = self.sentInvites[sender]
    if not invite then
        HopeAddon:Debug("WordGameInvites: Received accept for unknown invite from", sender)
        return
    end

    local gameState = invite.state

    -- Update state
    gameState.state = "PLAYING"
    gameState.lastMoveAt = time()

    -- Save game to persistence (Fix #2 & #17: Construct proper game state for SaveGame)
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        -- Create a proper game structure that SerializeGame expects
        local savedState = {
            version = 1,
            gameId = gameState.gameId,
            createdAt = gameState.createdAt,
            lastMoveAt = time(),
            player1 = gameState.player1,
            player2 = gameState.player2,
            currentTurn = gameState.currentTurn,
            board = gameState.board or {},  -- Include board data from invite
            scores = gameState.scores or {},
            moveHistory = gameState.moveHistory or {},
            consecutivePasses = gameState.consecutivePasses or 0,
            turnCount = gameState.turnCount or 0,
            state = "PLAYING",
            tileBag = {},  -- Empty for now, will be created on resume
            playerHands = {},  -- Empty for now, will be dealt on resume
        }
        -- Save directly to storage (bypass SerializeGame since we have raw state)
        Persistence:EnsureStorage()
        local storage = HopeAddon.charDb and HopeAddon.charDb.savedGames
            and HopeAddon.charDb.savedGames.words
        if storage then
            storage.games[sender] = savedState
        end
        Persistence:ClearSentInvite(sender)
    end

    -- Clear from runtime
    self.sentInvites[sender] = nil

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    HopeAddon:Print("|cFF00FF00" .. sender .. " accepted your Words challenge!|r")
    HopeAddon:Print("Use /hope words " .. sender .. " to start playing.")
end

--[[
    Handle invite declined
]]
function WordGameInvites:HandleDeclineReceived(sender, gameId, payload)
    local invite = self.sentInvites[sender]
    if not invite then return end

    -- Clear from persistence
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if Persistence then
        Persistence:ClearSentInvite(sender)
    end

    -- Clear from runtime
    self.sentInvites[sender] = nil

    HopeAddon:Print(sender .. " declined your Words challenge.")
end

--[[
    Handle state sync (for resume)
]]
function WordGameInvites:HandleStateSync(sender, gameId, payload)
    local remoteState = self:DeserializeState(payload)
    if not remoteState then return end

    -- Compare with local state
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if not Persistence then return end

    local localState = Persistence:LoadGame(sender)
    if not localState then
        -- We don't have this game, might be new
        HopeAddon:Debug("WordGameInvites: Received sync for unknown game from", sender)
        return
    end

    -- Validate board hashes match
    local localHash = Persistence:GenerateBoardHash(localState.savedBoard)
    local remoteHash = Persistence:GenerateBoardHash(remoteState.board)

    if localHash ~= remoteHash then
        HopeAddon:Print("|cFFFF0000Warning:|r Board state mismatch with " .. sender)
        HopeAddon:Print("Your local game may be out of sync. Consider forfeiting and starting fresh.")
    else
        HopeAddon:Debug("WordGameInvites: State sync verified with", sender)
    end
end

--[[
    Handle resume request (opponent came online)
]]
function WordGameInvites:HandleResumeRequest(sender, gameId, payload)
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if not Persistence then return end

    -- Check if we have this game
    if Persistence:HasGame(sender) then
        HopeAddon:Print("|cFF00FF00" .. sender .. " is online!|r Resume your Words game with /hope words " .. sender)

        -- Play notification
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayBell()
        end
    end
end

--============================================================
-- SERIALIZATION
--============================================================

--[[
    Serialize state to string for network transmission
    Simple format: key=value pairs separated by |
]]
function WordGameInvites:SerializeState(state)
    if not state then return "" end

    -- Simple serialization: send essential data (Fix #3: Include moveHistory)
    local parts = {
        "v=" .. (state.version or 1),
        "id=" .. (state.gameId or ""),
        "p1=" .. (state.player1 or ""),
        "p2=" .. (state.player2 or ""),
        "turn=" .. (state.currentTurn or "PLAYER1_TURN"),
        "t=" .. (state.turnCount or 0),
        "pass=" .. (state.consecutivePasses or 0),
    }

    -- Scores
    if state.scores then
        for player, score in pairs(state.scores) do
            table.insert(parts, "s_" .. player .. "=" .. score)
        end
    end

    -- Move history count (for validation - full history sent separately via MOVE messages)
    if state.moveHistory then
        table.insert(parts, "moves=" .. #state.moveHistory)
    end

    return table.concat(parts, "|")
end

--[[
    Deserialize state from network string
]]
function WordGameInvites:DeserializeState(data)
    if not data or data == "" then return nil end

    local state = {
        scores = {},
        board = {},
        moveHistory = {},
    }

    for part in data:gmatch("[^|]+") do
        local key, value = part:match("^(.-)=(.*)$")
        if key and value then
            if key == "v" then
                state.version = tonumber(value) or 1
            elseif key == "id" then
                state.gameId = value
            elseif key == "p1" then
                state.player1 = value
            elseif key == "p2" then
                state.player2 = value
            elseif key == "turn" then
                state.currentTurn = value
            elseif key == "t" then
                state.turnCount = tonumber(value) or 0
            elseif key == "pass" then
                state.consecutivePasses = tonumber(value) or 0
            elseif key:match("^s_") then
                local player = key:sub(3)
                state.scores[player] = tonumber(value) or 0
            end
        end
    end

    return state
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Get all pending invites (received)
    @return table
]]
function WordGameInvites:GetPendingInvites()
    return self.pendingInvites
end

--[[
    Check if we have a pending invite from someone
    @param senderName string
    @return table|nil
]]
function WordGameInvites:GetPendingInvite(senderName)
    return self.pendingInvites[senderName]
end

--[[
    Check if we have any pending invites
    @return boolean
]]
function WordGameInvites:HasPendingInvites()
    return next(self.pendingInvites) ~= nil
end

--[[
    Send resume notification to opponent
    @param opponentName string
]]
function WordGameInvites:SendResumeNotification(opponentName)
    local Persistence = HopeAddon:GetModule("WordGamePersistence")
    if not Persistence then return end

    local savedGame = Persistence:LoadGame(opponentName)
    if not savedGame then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        local payload = MSG_PREFIX.RESUME .. ":" .. (savedGame.id or "")
        GameComms:SendGameMessage(opponentName, "GSYNC", "WORDS", savedGame.id or "", payload)
    end
end

-- Register with addon
HopeAddon:RegisterModule("WordGameInvites", WordGameInvites)
HopeAddon.WordGameInvites = WordGameInvites

HopeAddon:Debug("WordGameInvites module loaded")
