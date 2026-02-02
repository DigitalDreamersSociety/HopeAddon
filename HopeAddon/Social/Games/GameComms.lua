--[[
    HopeAddon Game Communications
    Handles game-specific addon messaging for multiplayer games
]]

local GameComms = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game message types (extend FellowTravelers protocol)
local MSG_GAME_INVITE = "GINV"      -- Invite to play a game
local MSG_GAME_ACCEPT = "GACC"      -- Accept game invite
local MSG_GAME_DECLINE = "GDEC"     -- Decline game invite
local MSG_GAME_STATE = "GSTA"       -- Game state update
local MSG_GAME_MOVE = "GMOV"        -- Player move/action
local MSG_GAME_END = "GEND"         -- Game ended
local MSG_GAME_CHAT = "GCHAT"       -- In-game chat
local MSG_GAME_SYNC = "GSYNC"       -- State sync request/response

-- Invite timeout (seconds)
local INVITE_TIMEOUT = 60

-- Cache SendAddonMessage function at load time (TBC optimization)
local CachedSendAddonMessage = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage

--============================================================
-- MODULE STATE
--============================================================

-- Pending invites (sent and received)
GameComms.pendingInvites = {}   -- [playerName] = { gameType, timestamp, gameId }
GameComms.receivedInvites = {}  -- [playerName] = { gameType, timestamp, gameId }

-- Message callbacks per game type
GameComms.messageHandlers = {}

--============================================================
-- LIFECYCLE
--============================================================

function GameComms:OnInitialize()
    -- Register addon message prefix if needed
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix("HOPEADDON")
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix("HOPEADDON")
    end

    -- Store message prefix
    self.messagePrefix = "HOPEADDON"

    HopeAddon:Debug("GameComms initializing...")
end

function GameComms:OnEnable()
    -- Register with FellowTravelers callback system (no hooking needed)
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if FellowTravelers then
        FellowTravelers:RegisterMessageCallback("GameComms",
            function(msgType)
                -- Match "GAME" message type (SendDirectMessage uses "GAME" as msgType)
                -- The actual game message types (GINV, GACC, etc) are in the data portion
                return msgType == "GAME"
            end,
            function(msgType, senderName, data)
                -- data contains the full game message: "GINV:1:SCORE_TETRIS:gameId:payload"
                -- Pass it directly to HandleGameMessage
                GameComms:HandleGameMessage(nil, data or "", nil, senderName)
            end
        )
    end

    -- Start invite cleanup ticker
    self.cleanupTicker = HopeAddon.Timer:NewTicker(30, function()
        self:CleanupExpiredInvites()
    end)

    HopeAddon:Debug("GameComms enabled")
end

function GameComms:OnDisable()
    -- Cancel timer
    if self.cleanupTicker then
        self.cleanupTicker:Cancel()
        self.cleanupTicker = nil
    end

    -- Unregister callback
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if FellowTravelers then
        FellowTravelers:UnregisterMessageCallback("GameComms")
    end

    -- Clear references to prevent memory leaks
    self.pendingInvites = {}
    self.receivedInvites = {}
    self.messageHandlers = {}
end

--============================================================
-- MESSAGE REGISTRATION
--============================================================

--[[
    Register a handler for game messages
    @param gameType string - Game type from GameCore.GAME_TYPE
    @param messageType string - Message type (MOVE, STATE, etc)
    @param handler function(sender, gameId, data)
]]
function GameComms:RegisterHandler(gameType, messageType, handler)
    if not self.messageHandlers[gameType] then
        self.messageHandlers[gameType] = {}
    end
    self.messageHandlers[gameType][messageType] = handler
end

--[[
    Unregister a handler
    @param gameType string
    @param messageType string
]]
function GameComms:UnregisterHandler(gameType, messageType)
    if self.messageHandlers[gameType] then
        self.messageHandlers[gameType][messageType] = nil
    end
end


--[[
    Handle incoming game messages
]]
function GameComms:HandleGameMessage(prefix, message, channel, sender)
    -- Validate input
    if not message or message == "" then return end
    if not sender then return end

    -- Parse sender name
    local senderName = strsplit("-", sender)
    if not senderName then return end

    local playerName = UnitName("player")

    -- Don't process our own messages
    if senderName == playerName then return end

    -- Parse message format: TYPE:VERSION:GAMETYPE:GAMEID:DATA
    local msgType, version, gameType, gameId, data = strsplit(":", message, 5)
    if not msgType or not gameType then return end

    version = tonumber(version) or 1

    HopeAddon:Debug("Game message from", senderName, "type:", msgType, "game:", gameType)

    if msgType == MSG_GAME_INVITE then
        self:HandleInvite(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_ACCEPT then
        self:HandleAccept(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_DECLINE then
        self:HandleDecline(senderName, gameType, gameId)
    elseif msgType == MSG_GAME_STATE then
        self:HandleState(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_MOVE then
        self:HandleMove(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_END then
        self:HandleEnd(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_CHAT then
        self:HandleChat(senderName, gameType, gameId, data)
    elseif msgType == MSG_GAME_SYNC then
        self:HandleSync(senderName, gameType, gameId, data)
    end
end

--============================================================
-- INVITE SYSTEM
--============================================================

--[[
    Send a game invite to a player
    @param playerName string - Target player
    @param gameType string - Game type
    @param betAmount number|nil - Gold bet amount (for gambling games)
    @return string|nil - Game ID if invite sent
]]
function GameComms:SendInvite(playerName, gameType, betAmount)
    if not playerName or playerName == UnitName("player") then
        return nil
    end

    -- Check if already have pending invite
    if self.pendingInvites[playerName] then
        HopeAddon:Print("Already have a pending invite to " .. playerName)
        return nil
    end

    -- Verify opponent is a Fellow Traveler with detailed feedback
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    local fellow = FellowTravelers and FellowTravelers:GetFellow(playerName)

    if not fellow then
        HopeAddon:Print("|cFFFF6666" .. playerName .. "|r has not been discovered yet.")
        HopeAddon:Print("Fellow Travelers are discovered automatically within ~300 yards.")
        HopeAddon:Print("Wait a moment or group up with them to discover faster.")
        return nil
    end

    -- Check if recently seen (within 5 minutes)
    local now = time()
    local lastSeen = fellow.lastSeenTime or 0
    local timeSinceLastSeen = now - lastSeen
    if timeSinceLastSeen > 300 then
        local minsAgo = math.floor(timeSinceLastSeen / 60)
        HopeAddon:Print("|cFFFFFF66Warning:|r " .. playerName .. " was last seen " .. minsAgo .. " minutes ago.")
        HopeAddon:Print("They may be offline or out of range. Sending invite anyway...")
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    local gameId = GameCore:GenerateGameId()

    -- Store pending invite
    self.pendingInvites[playerName] = {
        gameType = gameType,
        timestamp = GetTime(),
        gameId = gameId,
        betAmount = betAmount,
    }

    -- Send invite message
    local data = betAmount and tostring(betAmount) or ""
    self:SendGameMessage(playerName, MSG_GAME_INVITE, gameType, gameId, data)

    HopeAddon:Print("Sent " .. gameType .. " invite to " .. playerName)

    -- Set timeout
    HopeAddon.Timer:After(INVITE_TIMEOUT, function()
        if self.pendingInvites[playerName] and
           self.pendingInvites[playerName].gameId == gameId then
            self.pendingInvites[playerName] = nil
            HopeAddon:Print("Invite to " .. playerName .. " expired")
        end
    end)

    return gameId
end

--[[
    Accept a received game invite
    @param playerName string - Player who sent invite
]]
function GameComms:AcceptInvite(playerName)
    local invite = self.receivedInvites[playerName]
    if not invite then
        HopeAddon:Print("No pending invite from " .. playerName)
        return
    end

    -- Create local game instance using the CHALLENGER'S gameId for synchronization
    -- isChallenger = false because we are ACCEPTING (the other player challenged us)
    local GameCore = HopeAddon:GetModule("GameCore")
    local mode = GameCore.GAME_MODE.REMOTE
    local gameId = GameCore:CreateGame(invite.gameType, mode, playerName, invite.gameId, false)
    GameCore:StartGame(gameId)

    -- Send accept message with the shared gameId
    self:SendGameMessage(playerName, MSG_GAME_ACCEPT, invite.gameType, invite.gameId, "")

    -- Clear invite
    self.receivedInvites[playerName] = nil

    HopeAddon:Print("Accepted " .. invite.gameType .. " from " .. playerName)
end

--[[
    Decline a received game invite
    @param playerName string - Player who sent invite
]]
function GameComms:DeclineInvite(playerName)
    local invite = self.receivedInvites[playerName]
    if not invite then return end

    -- Send decline message
    self:SendGameMessage(playerName, MSG_GAME_DECLINE, invite.gameType, invite.gameId, "")

    -- Clear invite
    self.receivedInvites[playerName] = nil

    HopeAddon:Print("Declined invite from " .. playerName)
end

--[[
    Handle incoming invite
]]
function GameComms:HandleInvite(sender, gameType, gameId, data)
    -- Check if this is a score challenge (SCORE_TETRIS, SCORE_PONG)
    if string.find(gameType, "^SCORE_") then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            -- Extract actual game type (TETRIS, PONG)
            local actualGameType = string.gsub(gameType, "^SCORE_", "")
            ScoreChallenge:OnChallengeReceived(sender, gameId, actualGameType)
        end
        return
    end

    local betAmount = tonumber(data)

    -- Store received invite
    self.receivedInvites[sender] = {
        gameType = gameType,
        timestamp = GetTime(),
        gameId = gameId,
        betAmount = betAmount,
    }

    -- Notify player
    local betStr = betAmount and (" for " .. HopeAddon:FormatGold(betAmount * 10000)) or ""
    HopeAddon:Print(sender .. " has challenged you to " .. gameType .. betStr .. "!")
    HopeAddon:Print("Type /hope game accept " .. sender .. " to accept")

    -- Forward to MinigamesUI for unified challenge popup
    local MinigamesUI = HopeAddon:GetModule("MinigamesUI")
    if MinigamesUI and MinigamesUI.ShowChallengePopup then
        MinigamesUI:ShowChallengePopup(sender, gameType, gameId, "gamecore")
    end
end

--[[
    Handle invite accepted
]]
function GameComms:HandleAccept(sender, gameType, gameId, data)
    -- Check if this is a score challenge accept
    if string.find(gameType, "^SCORE_") then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:OnChallengeAccepted(sender, gameId, data)
        end
        return
    end

    local invite = self.pendingInvites[sender]
    if not invite or invite.gameId ~= gameId then
        HopeAddon:Debug("Received accept for unknown invite")
        return
    end

    -- Clear pending invite
    self.pendingInvites[sender] = nil

    -- Create game instance using the SHARED gameId for synchronization
    -- isChallenger = true because WE sent the invite that was accepted
    local GameCore = HopeAddon:GetModule("GameCore")
    local mode = GameCore.GAME_MODE.REMOTE
    local sharedGameId = GameCore:CreateGame(gameType, mode, sender, gameId, true)
    GameCore:StartGame(sharedGameId)

    -- Notify game module
    local gameModule = GameCore:GetGameModule(gameType)
    if gameModule and gameModule.OnMatchFound then
        gameModule:OnMatchFound(sharedGameId, sender)
    end

    HopeAddon:Print(sender .. " accepted your " .. gameType .. " challenge!")
end

--[[
    Handle invite declined
]]
function GameComms:HandleDecline(sender, gameType, gameId)
    -- Check if this is a score challenge decline
    if string.find(gameType, "^SCORE_") then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:OnChallengeDeclined(sender, gameId)
        end
        return
    end

    local invite = self.pendingInvites[sender]
    if invite and invite.gameId == gameId then
        self.pendingInvites[sender] = nil
        HopeAddon:Print(sender .. " declined your " .. gameType .. " challenge")
    end
end

--============================================================
-- GAME STATE MESSAGES
--============================================================

--[[
    Send a game move/action
    @param playerName string - Opponent name
    @param gameType string
    @param gameId string
    @param moveData string - Serialized move data
]]
function GameComms:SendMove(playerName, gameType, gameId, moveData)
    self:SendGameMessage(playerName, MSG_GAME_MOVE, gameType, gameId, moveData)
end

--[[
    Send game state update
    @param playerName string - Opponent name
    @param gameType string
    @param gameId string
    @param stateData string - Serialized state
]]
function GameComms:SendState(playerName, gameType, gameId, stateData)
    self:SendGameMessage(playerName, MSG_GAME_STATE, gameType, gameId, stateData)
end

--[[
    Send game end notification
    @param playerName string - Opponent name
    @param gameType string
    @param gameId string
    @param reason string - End reason
]]
function GameComms:SendEnd(playerName, gameType, gameId, reason)
    self:SendGameMessage(playerName, MSG_GAME_END, gameType, gameId, reason)
end

--[[
    Handle move message
]]
function GameComms:HandleMove(sender, gameType, gameId, data)
    local handler = self.messageHandlers[gameType] and self.messageHandlers[gameType]["MOVE"]
    if handler and type(handler) == "function" then
        local success, err = pcall(handler, sender, gameId, data)
        if not success then
            HopeAddon:Debug("Error in MOVE handler:", err)
        end
    end
end

--[[
    Handle state message
]]
function GameComms:HandleState(sender, gameType, gameId, data)
    local handler = self.messageHandlers[gameType] and self.messageHandlers[gameType]["STATE"]
    if handler and type(handler) == "function" then
        local success, err = pcall(handler, sender, gameId, data)
        if not success then
            HopeAddon:Debug("Error in STATE handler:", err)
        end
    end
end

--[[
    Handle end message
]]
function GameComms:HandleEnd(sender, gameType, gameId, data)
    local handler = self.messageHandlers[gameType] and self.messageHandlers[gameType]["END"]
    if handler and type(handler) == "function" then
        local success, err = pcall(handler, sender, gameId, data)
        if not success then
            HopeAddon:Debug("Error in END handler:", err)
        end
    end

    HopeAddon:Print("Game with " .. sender .. " has ended: " .. (data or "unknown"))
end

--[[
    Handle chat message
]]
function GameComms:HandleChat(sender, gameType, gameId, data)
    local handler = self.messageHandlers[gameType] and self.messageHandlers[gameType]["CHAT"]
    if handler and type(handler) == "function" then
        local success, err = pcall(handler, sender, gameId, data)
        if not success then
            HopeAddon:Debug("Error in CHAT handler:", err)
        end
    end
end

--[[
    Handle sync request/response
]]
function GameComms:HandleSync(sender, gameType, gameId, data)
    local handler = self.messageHandlers[gameType] and self.messageHandlers[gameType]["SYNC"]
    if handler and type(handler) == "function" then
        local success, err = pcall(handler, sender, gameId, data)
        if not success then
            HopeAddon:Debug("Error in SYNC handler:", err)
        end
    end
end

--============================================================
-- MESSAGE SENDING
--============================================================

--[[
    Send a game message to a player
    @param playerName string
    @param msgType string
    @param gameType string
    @param gameId string
    @param data string
]]
function GameComms:SendGameMessage(playerName, msgType, gameType, gameId, data)
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers then return end

    -- Format: TYPE:VERSION:GAMETYPE:GAMEID:DATA
    local msg = string.format("%s:1:%s:%s:%s", msgType, gameType or "", gameId or "", data or "")
    FellowTravelers:SendDirectMessage(playerName, "GAME", msg)
end

--[[
    Broadcast a game message (YELL for nearby players)
    @param msgType string
    @param gameType string
    @param gameId string
    @param data string
]]
function GameComms:BroadcastGameMessage(msgType, gameType, gameId, data)
    local prefix = "HOPEADDON"
    local msg = string.format("%s:1:%s:%s:%s", msgType, gameType, gameId or "", data or "")

    if CachedSendAddonMessage then
        -- Use pcall to handle edge cases silently
        local success, err = pcall(CachedSendAddonMessage, prefix, msg, "YELL")
        if not success and HopeAddon.db and HopeAddon.db.debug then
            HopeAddon:Debug("GameComms broadcast failed:", err)
        end
    end
end

--============================================================
-- UTILITIES
--============================================================

--[[
    Clean up expired invites
]]
function GameComms:CleanupExpiredInvites()
    local now = GetTime()

    for name, invite in pairs(self.pendingInvites) do
        if now - invite.timestamp > INVITE_TIMEOUT then
            self.pendingInvites[name] = nil
        end
    end

    for name, invite in pairs(self.receivedInvites) do
        if now - invite.timestamp > INVITE_TIMEOUT then
            self.receivedInvites[name] = nil
        end
    end
end

--[[
    Get list of pending invites (sent)
    @return table
]]
function GameComms:GetPendingInvites()
    return self.pendingInvites
end

--[[
    Get list of received invites
    @return table
]]
function GameComms:GetReceivedInvites()
    return self.receivedInvites
end

--[[
    Check if player has a pending invite
    @param playerName string
    @return boolean
]]
function GameComms:HasPendingInvite(playerName)
    return self.pendingInvites[playerName] ~= nil
end

--[[
    Check if have received invite from player
    @param playerName string
    @return table|nil - Invite data
]]
function GameComms:GetReceivedInvite(playerName)
    return self.receivedInvites[playerName]
end

-- Register with addon
HopeAddon:RegisterModule("GameComms", GameComms)
HopeAddon.GameComms = GameComms

HopeAddon:Debug("GameComms module loaded")
