--[[
    HopeAddon Minigames Module
    Rock-Paper-Scissors game between Fellow Travelers
]]

local Minigames = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game types
Minigames.GAME_RPS = "rps"

-- Game states
local STATE_IDLE = "IDLE"
local STATE_PENDING = "PENDING"           -- Waiting for accept/reject
local STATE_COMMITTED = "COMMITTED"       -- RPS: sent hash, waiting for opponent
local STATE_REVEALING = "REVEALING"       -- RPS: both hashes received, revealing
local STATE_COMPLETED = "COMPLETED"

-- Message types (added to FellowTravelers protocol)
Minigames.MSG_GAME_CHALLENGE = "GCHL"     -- Challenge invitation
Minigames.MSG_GAME_ACCEPT = "GACC"        -- Accept challenge
Minigames.MSG_GAME_REJECT = "GREJ"        -- Reject challenge
Minigames.MSG_GAME_MOVE = "GMOV"          -- Player move/choice (roll or hash)
Minigames.MSG_GAME_REVEAL = "GREV"        -- Reveal choice (RPS plaintext + salt)
Minigames.MSG_GAME_RESULT = "GRES"        -- Result confirmation
Minigames.MSG_GAME_CANCEL = "GCAN"        -- Cancel/timeout

-- Message format definitions for validation and parsing
local MESSAGE_FORMATS = {
    GCHL = {"gameType", "sessionId", "challengerName"},  -- 3 parts
    GACC = {"sessionId", "accepterName"},                -- 2 parts
    GREJ = {"sessionId", "reason"},                      -- 2 parts
    GMOV = {"sessionId", "move", "timestamp"},           -- 3 parts (move = roll or hash)
    GREV = {"sessionId", "choice", "salt"},              -- 3 parts (RPS reveal)
    GRES = {"sessionId", "winner", "move1", "move2"},    -- 4 parts
    GCAN = {"sessionId", "reason"},                      -- 2 parts
}

-- Timeouts
local CHALLENGE_TIMEOUT = 30              -- Seconds to respond to challenge
local MOVE_TIMEOUT = 60                   -- Seconds to make a move
local REVEAL_TIMEOUT = 30                 -- Seconds to reveal after both committed
local CHALLENGE_COOLDOWN = 30             -- Seconds before challenging same player again

-- Anti-cheat settings
local ENFORCE_HASH_INTEGRITY = true       -- Reject RPS game if opponent's hash doesn't match reveal

-- Dice roll detection pattern (from CHAT_MSG_SYSTEM)
-- Matches: "PlayerName rolls 42 (1-100)"
Minigames.DICE_ROLL_PATTERN = "(.+) rolls (%d+) %(1%-(%d+)%)"

-- RPS choices
local RPS_ROCK = "rock"
local RPS_PAPER = "paper"
local RPS_SCISSORS = "scissors"

-- RPS win matrix: [myChoice][theirChoice] = "win" | "lose" | "tie"
local RPS_OUTCOMES = {
    [RPS_ROCK] = {
        [RPS_ROCK] = "tie",
        [RPS_PAPER] = "lose",
        [RPS_SCISSORS] = "win",
    },
    [RPS_PAPER] = {
        [RPS_ROCK] = "win",
        [RPS_PAPER] = "tie",
        [RPS_SCISSORS] = "lose",
    },
    [RPS_SCISSORS] = {
        [RPS_ROCK] = "lose",
        [RPS_PAPER] = "win",
        [RPS_SCISSORS] = "tie",
    },
}

--============================================================
-- MODULE STATE
--============================================================

-- Session state: activeGame and pendingChallenge are mutually exclusive
-- Only one can be active at a time
Minigames.activeGame = nil                -- Current game session (challenger or accepter)
Minigames.pendingChallenge = nil          -- Incoming challenge we haven't responded to

-- Timeout tracking: single timer slot, but typed for clarity
Minigames.timeoutTimer = nil              -- Timer handle for current timeout
Minigames.timeoutType = nil               -- "challenge", "move", or "reveal"

-- Persistent state
Minigames.challengeCooldowns = {}         -- [playerName] = timestamp of last challenge sent
Minigames.eventFrame = nil                -- Event frame for roll detection

--[[
    Reset all session state (called on game end, cancel, or disable)
]]
local function ResetSessionState()
    Minigames.activeGame = nil
    Minigames.pendingChallenge = nil
    if Minigames.timeoutTimer then
        Minigames.timeoutTimer:Cancel()
        Minigames.timeoutTimer = nil
    end
    Minigames.timeoutType = nil
end

--============================================================
-- MESSAGE PARSING
--============================================================

--[[
    Parse and validate a message based on its type
    Centralized parsing reduces code duplication and improves maintainability
    @param msgType string - Message type constant (GCHL, GACC, etc.)
    @param data string - Pipe-delimited message data
    @return table|nil - Parsed message fields or nil if invalid
]]
local function ParseMessage(msgType, data)
    if not data then return nil end

    local format = MESSAGE_FORMATS[msgType]
    if not format then
        HopeAddon:Debug("Unknown message type:", msgType)
        return nil
    end

    local parts = {strsplit("|", data)}

    -- Validate part count
    if #parts < #format then
        HopeAddon:Debug("Invalid message format for", msgType, "- expected", #format, "parts, got", #parts)
        return nil
    end

    -- Return structured data
    local parsed = {}
    for i, fieldName in ipairs(format) do
        parsed[fieldName] = parts[i]
    end

    return parsed
end

--============================================================
-- LIFECYCLE
--============================================================

function Minigames:OnInitialize()
    -- Nothing to do at init
end

function Minigames:OnEnable()
    HopeAddon:Debug("Minigames module enabled")

    -- Create event frame for roll detection
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
    self.eventFrame:SetScript("OnEvent", function(_, event, msg)
        if event == "CHAT_MSG_SYSTEM" then
            Minigames:OnSystemMessage(msg)
        end
    end)
end

function Minigames:OnDisable()
    -- Cancel any active game
    self:CancelGame("logout")

    -- Reset all session state
    ResetSessionState()

    -- Unregister event frame
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame = nil
    end

    -- Clear cooldown tracking
    wipe(self.challengeCooldowns)
end

--============================================================
-- DICE ROLL DETECTION (via CHAT_MSG_SYSTEM)
--============================================================

--[[
    Handle system messages to detect /roll results
    @param msg string - System message text
]]
function Minigames:OnSystemMessage(msg)
    -- Quick substring check before expensive regex (60-70% reduction in regex calls)
    if not msg:find("rolls") then return end

    -- Parse the roll message: "PlayerName rolls 42 (1-100)"
    local playerName, rollResult, maxRoll = msg:match(self.DICE_ROLL_PATTERN)
    if not playerName then return end

    rollResult = tonumber(rollResult)
    maxRoll = tonumber(maxRoll)

    local myName = UnitName("player")

    -- Roll detection is used by Death Roll module only now
    -- This module no longer handles dice games
end

--============================================================
-- MESSAGE PARSING
--============================================================

-- Note: MESSAGE_FORMATS defined at top of file (line 34) is used by both
-- local ParseMessage() and Minigames:ParseMessage() below

--[[
    Parse and validate a message
    @param msgType string - Message type
    @param data string - Message data (pipe-separated)
    @return table|nil - Parsed data or nil if invalid
]]
function Minigames:ParseMessage(msgType, data)
    if not data then return nil end

    local format = MESSAGE_FORMATS[msgType]
    if not format then return nil end

    local parts = {strsplit("|", data)}

    -- Validate part count
    if #parts < #format then
        HopeAddon:Debug("Invalid message format for", msgType, "- expected", #format, "parts, got", #parts)
        return nil
    end

    -- Return structured data
    local parsed = {}
    for i, fieldName in ipairs(format) do
        parsed[fieldName] = parts[i]
    end

    return parsed
end

--============================================================
-- SESSION MANAGEMENT
--============================================================

--[[
    Generate a unique session ID
    @return string - Session ID
]]
function Minigames:GenerateSessionId()
    -- Simple session ID: timestamp + random
    local timestamp = GetTime()
    local random = math.random(10000, 99999)
    return string.format("%d%d", math.floor(timestamp * 1000) % 100000, random)
end

--[[
    Create a new game session
    @param gameType string - "dice" or "rps"
    @param opponent string - Opponent player name
    @param isChallenger boolean - Are we the challenger?
    @param sessionId string|nil - Session ID (use existing for accepting)
    @return table - New session
]]
function Minigames:CreateSession(gameType, opponent, isChallenger, sessionId)
    return {
        sessionId = sessionId or self:GenerateSessionId(),
        gameType = gameType,
        opponent = opponent,
        state = STATE_PENDING,
        isChallenger = isChallenger,

        -- Common fields
        startTime = GetTime(),
        timeout = CHALLENGE_TIMEOUT,

        -- Player's move
        myChoice = nil,
        mySalt = nil,
        myHash = nil,
        myRoll = nil,

        -- Opponent's move
        opponentHash = nil,
        opponentChoice = nil,
        opponentSalt = nil,
        opponentRoll = nil,
    }
end

--[[
    Cancel current game
    @param reason string|nil - Reason for cancellation
]]
function Minigames:CancelGame(reason)
    if self.activeGame then
        local opponent = self.activeGame.opponent
        local sessionId = self.activeGame.sessionId

        -- Notify opponent if we're actively in a game
        if self.activeGame.state ~= STATE_COMPLETED and
           self.activeGame.state ~= STATE_IDLE and
           reason ~= "logout" then
            self:SendGameMessage(opponent, Minigames.MSG_GAME_CANCEL, sessionId .. "|" .. (reason or "cancelled"))
        end

        self.activeGame = nil

        -- Cancel timeout
        if self.timeoutTimer then
            self.timeoutTimer:Cancel()
            self.timeoutTimer = nil
        end

        -- Notify UI
        if HopeAddon.MinigamesUI then
            HopeAddon.MinigamesUI:OnGameCancelled(reason)
        end

        HopeAddon:Debug("Game cancelled:", reason)
    end

    -- Also clear pending challenge
    if self.pendingChallenge then
        self.pendingChallenge = nil
        if HopeAddon.MinigamesUI then
            HopeAddon.MinigamesUI:HideChallengePopup()
        end
    end
end

--[[
    Start timeout timer
    @param duration number - Timeout in seconds
    @param callback function - Function to call on timeout
    @param timeoutType string|nil - "challenge", "move", or "reveal" (for debugging)
]]
function Minigames:StartTimeout(duration, callback, timeoutType)
    -- Cancel existing timer
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
    end

    self.timeoutType = timeoutType
    self.timeoutTimer = HopeAddon.Timer:After(duration, function()
        Minigames.timeoutTimer = nil
        Minigames.timeoutType = nil
        callback()
    end)
end

--============================================================
-- CHALLENGE FLOW
--============================================================

--[[
    Send a challenge to another player
    @param targetName string - Player name to challenge
    @param gameType string - "dice" or "rps"
    @return boolean - Success
]]
function Minigames:SendChallenge(targetName, gameType)
    gameType = gameType or Minigames.GAME_DICE

    -- Validate game type
    if gameType ~= Minigames.GAME_DICE and gameType ~= Minigames.GAME_RPS then
        HopeAddon:Print("Invalid game type. Use 'rps'.")
        return false
    end

    -- Check if we're already in a game
    if self.activeGame then
        HopeAddon:Print("You're already in a game! Use /hope cancel to cancel it.")
        return false
    end

    -- Check if target is a fellow traveler
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers or not FellowTravelers:IsFellow(targetName) then
        HopeAddon:Print(targetName .. " is not a Fellow Traveler (no addon detected).")
        return false
    end

    -- Prune expired cooldowns to prevent unbounded table growth
    local now = GetTime()
    for name, timestamp in pairs(self.challengeCooldowns) do
        if now - timestamp >= CHALLENGE_COOLDOWN then
            self.challengeCooldowns[name] = nil
        end
    end

    -- Check cooldown for this player
    local lastChallenge = self.challengeCooldowns[targetName]
    if lastChallenge then
        local elapsed = now - lastChallenge
        if elapsed < CHALLENGE_COOLDOWN then
            local remaining = math.ceil(CHALLENGE_COOLDOWN - elapsed)
            HopeAddon:Print("Please wait " .. remaining .. " seconds before challenging " .. targetName .. " again.")
            return false
        end
    end

    -- Record challenge time for cooldown
    self.challengeCooldowns[targetName] = now

    -- Create session
    local session = self:CreateSession(gameType, targetName, true)
    self.activeGame = session

    -- Build challenge message: gameType|sessionId|challengerName
    local playerName = UnitName("player")
    local data = string.format("%s|%s|%s", gameType, session.sessionId, playerName)

    -- Send challenge
    self:SendGameMessage(targetName, Minigames.MSG_GAME_CHALLENGE, data)

    -- Start challenge timeout
    self:StartTimeout(CHALLENGE_TIMEOUT, function()
        if Minigames.activeGame and Minigames.activeGame.sessionId == session.sessionId then
            Minigames:CancelGame("timeout")
            HopeAddon:Print(targetName .. " did not respond to your challenge.")
        end
    end, "challenge")

    HopeAddon:Print("Challenge sent to " .. targetName .. " (Rock-Paper-Scissors)")

    -- Show waiting UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowWaitingForAccept(targetName, gameType)
    end

    return true
end

--[[
    Handle incoming challenge
    @param sender string - Challenger name
    @param data string - Challenge data
]]
function Minigames:HandleChallenge(sender, data)
    -- Parse data: gameType|sessionId|challengerName
    local parsed = ParseMessage("GCHL", data)
    if not parsed then return end

    local gameType = parsed.gameType
    local sessionId = parsed.sessionId
    local challengerName = parsed.challengerName

    -- Check if we're already in a game
    if self.activeGame then
        -- Auto-reject
        self:SendGameMessage(sender, Minigames.MSG_GAME_REJECT, sessionId .. "|busy")
        return
    end

    -- Store pending challenge
    self.pendingChallenge = {
        challenger = challengerName,
        gameType = gameType,
        sessionId = sessionId,
        receivedAt = GetTime(),
    }

    -- Show challenge popup
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowChallengePopup(challengerName, gameType, sessionId)
    else
        -- Fallback: print to chat
        HopeAddon:Print(challengerName .. " challenges you to Rock-Paper-Scissors! Type /hope accept or /hope decline")
    end

    -- Start timeout for auto-decline
    self:StartTimeout(CHALLENGE_TIMEOUT, function()
        if Minigames.pendingChallenge and Minigames.pendingChallenge.sessionId == sessionId then
            Minigames:DeclineChallenge()
            HopeAddon:Print("Challenge from " .. challengerName .. " expired.")
        end
    end, "challenge")
end

--[[
    Accept a pending challenge
]]
function Minigames:AcceptChallenge()
    if not self.pendingChallenge then
        HopeAddon:Print("No pending challenge to accept.")
        return
    end

    local challenge = self.pendingChallenge
    self.pendingChallenge = nil

    -- Cancel timeout
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
        self.timeoutTimer = nil
    end

    -- Create session as non-challenger
    local session = self:CreateSession(challenge.gameType, challenge.challenger, false, challenge.sessionId)
    session.state = STATE_WAITING_ROLLS  -- Move to in-game state
    self.activeGame = session

    -- Send accept
    local playerName = UnitName("player")
    self:SendGameMessage(challenge.challenger, Minigames.MSG_GAME_ACCEPT,
        session.sessionId .. "|" .. playerName)

    HopeAddon:Print("Challenge accepted! Starting Rock-Paper-Scissors with " .. challenge.challenger)

    -- Hide challenge popup
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:HideChallengePopup()
    end

    -- Start the game
    self:StartGame()
end

--[[
    Decline a pending challenge
]]
function Minigames:DeclineChallenge()
    if not self.pendingChallenge then
        return
    end

    local challenge = self.pendingChallenge
    self.pendingChallenge = nil

    -- Cancel timeout
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
        self.timeoutTimer = nil
    end

    -- Send reject
    self:SendGameMessage(challenge.challenger, Minigames.MSG_GAME_REJECT,
        challenge.sessionId .. "|declined")

    -- Hide challenge popup
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:HideChallengePopup()
    end
end

--[[
    Handle challenge accepted
    @param sender string
    @param data string - sessionId|accepterName
]]
function Minigames:HandleAccept(sender, data)
    local parsed = ParseMessage("GACC", data)
    if not parsed then return end

    local sessionId = parsed.sessionId
    local accepterName = parsed.accepterName

    if not self.activeGame or self.activeGame.sessionId ~= sessionId then
        HopeAddon:Debug("Received accept for unknown session:", sessionId)
        return
    end

    -- Cancel timeout
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
        self.timeoutTimer = nil
    end

    -- Update state
    self.activeGame.state = STATE_WAITING_ROLLS

    HopeAddon:Print(accepterName .. " accepted your challenge! Starting Rock-Paper-Scissors")

    -- Start the game
    self:StartGame()
end

--[[
    Handle challenge rejected
    @param sender string
    @param data string - sessionId|reason
]]
function Minigames:HandleReject(sender, data)
    local parsed = ParseMessage("GREJ", data)
    if not parsed then return end

    local sessionId = parsed.sessionId
    local reason = parsed.reason

    if not self.activeGame or self.activeGame.sessionId ~= sessionId then
        return
    end

    -- Cancel timeout
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
        self.timeoutTimer = nil
    end

    self.activeGame = nil

    local reasonText = reason == "busy" and " (busy with another game)" or ""
    HopeAddon:Print(sender .. " declined your challenge" .. reasonText)

    -- Update UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:OnChallengeRejected(sender, reason)
    end
end

--============================================================
-- GAME LOGIC
--============================================================

--[[
    Start the actual game after challenge is accepted
]]
function Minigames:StartGame()
    if not self.activeGame then return end

    local game = self.activeGame

    -- Show game UI (RPS only now)
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowRPSGame(game.opponent)
    end

    -- Start move timeout
    self:StartTimeout(MOVE_TIMEOUT, function()
        if Minigames.activeGame and Minigames.activeGame.sessionId == game.sessionId then
            Minigames:CancelGame("timeout")
            HopeAddon:Print("Game timed out - no move received.")
        end
    end, "move")
end

--[[
    Make a move in the current game (RPS only)
    @param choice string - "rock", "paper", or "scissors"
]]
function Minigames:MakeMove(choice)
    if not self.activeGame then
        HopeAddon:Print("No active game.")
        return
    end

    self:MakeRPSMove(choice)
end

--============================================================
-- ROCK-PAPER-SCISSORS LOGIC
--============================================================

--[[
    Generate a random salt for RPS commit
    @return string - Salt
]]
function Minigames:GenerateSalt()
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local salt = ""
    for i = 1, 16 do
        local idx = math.random(1, #chars)
        salt = salt .. chars:sub(idx, idx)
    end
    return salt
end

--[[
    Create a simple hash for RPS commit
    Uses a simple checksum approach (not cryptographically secure, but sufficient)
    @param choice string - Rock/paper/scissors
    @param salt string - Random salt
    @return string - Hash
]]
function Minigames:CreateHash(choice, salt)
    local combined = choice .. ":" .. salt
    local hash = 0
    for i = 1, #combined do
        local byte = string.byte(combined, i)
        hash = (hash * 31 + byte) % 2147483647
    end
    return string.format("%010d", hash)
end

--[[
    Verify a hash matches the choice and salt
    @param hash string
    @param choice string
    @param salt string
    @return boolean
]]
function Minigames:VerifyHash(hash, choice, salt)
    return self:CreateHash(choice, salt) == hash
end

--[[
    Make an RPS move (commit phase)
    @param choice string - "rock", "paper", or "scissors"
]]
function Minigames:MakeRPSMove(choice)
    local game = self.activeGame
    if not game or game.gameType ~= Minigames.GAME_RPS then return end
    if game.myChoice then return end  -- Already made choice

    -- Validate choice
    choice = string.lower(choice)
    if choice ~= RPS_ROCK and choice ~= RPS_PAPER and choice ~= RPS_SCISSORS then
        HopeAddon:Print("Invalid choice! Use: rock, paper, or scissors")
        return
    end

    -- Generate salt and hash
    local salt = self:GenerateSalt()
    local hash = self:CreateHash(choice, salt)

    game.myChoice = choice
    game.mySalt = salt
    game.myHash = hash
    game.state = STATE_COMMITTED

    -- Send hash to opponent: sessionId|hash|timestamp
    local timestamp = GetTime()
    local data = string.format("%s|%s|%.3f", game.sessionId, hash, timestamp)
    self:SendGameMessage(game.opponent, Minigames.MSG_GAME_MOVE, data)

    HopeAddon:Print("Choice locked in! Waiting for opponent...")

    -- Update UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:OnRPSChoiceMade(choice)
    end

    -- Check if both have committed
    self:CheckRPSCommitComplete()
end

--[[
    Handle received RPS hash
    @param sender string
    @param data string - sessionId|hash|timestamp
]]
function Minigames:HandleRPSMove(sender, data)
    local parsed = ParseMessage("GMOV", data)
    if not parsed then return end

    local sessionId = parsed.sessionId
    local hash = parsed.move

    if not self.activeGame or self.activeGame.sessionId ~= sessionId then
        HopeAddon:Debug("Received RPS move for unknown session:", sessionId)
        return
    end

    local game = self.activeGame
    if game.gameType ~= Minigames.GAME_RPS then return end

    game.opponentHash = hash

    HopeAddon:Print(game.opponent .. " has made their choice!")

    -- Update UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:OnOpponentRPSCommitted()
    end

    -- Check if both have committed
    self:CheckRPSCommitComplete()
end

--[[
    Check if both players have committed, then start reveal phase
]]
function Minigames:CheckRPSCommitComplete()
    local game = self.activeGame
    if not game or game.gameType ~= Minigames.GAME_RPS then return end
    if not game.myChoice or not game.opponentHash then return end

    -- Both committed, start reveal
    game.state = STATE_REVEALING

    -- Send our reveal: sessionId|choice|salt
    local data = string.format("%s|%s|%s", game.sessionId, game.myChoice, game.mySalt)
    self:SendGameMessage(game.opponent, Minigames.MSG_GAME_REVEAL, data)

    HopeAddon:Print("Both players ready - revealing choices...")

    -- Start reveal timeout
    self:StartTimeout(REVEAL_TIMEOUT, function()
        if Minigames.activeGame and Minigames.activeGame.sessionId == game.sessionId
           and Minigames.activeGame.state == STATE_REVEALING then
            Minigames:CancelGame("reveal_timeout")
            HopeAddon:Print("Opponent failed to reveal - game cancelled.")
        end
    end, "reveal")

    -- Check if we already have their reveal
    self:CheckRPSRevealComplete()
end

--[[
    Handle received RPS reveal
    @param sender string
    @param data string - sessionId|choice|salt
]]
function Minigames:HandleRPSReveal(sender, data)
    local parsed = ParseMessage("GREV", data)
    if not parsed then return end

    local sessionId = parsed.sessionId
    local choice = parsed.choice
    local salt = parsed.salt

    if not self.activeGame or self.activeGame.sessionId ~= sessionId then
        HopeAddon:Debug("Received RPS reveal for unknown session:", sessionId)
        return
    end

    local game = self.activeGame
    if game.gameType ~= Minigames.GAME_RPS then return end

    -- Verify hash
    if not self:VerifyHash(game.opponentHash, choice, salt) then
        HopeAddon:Print("|cFFFF0000Warning:|r " .. game.opponent .. "'s reveal doesn't match their commit!")
        if ENFORCE_HASH_INTEGRITY then
            HopeAddon:Print("Game cancelled due to hash integrity failure.")
            self:CancelGame("hash_mismatch")
            return
        end
        -- If not enforcing, continue but mark as suspicious
        game.hashMismatch = true
    end

    game.opponentChoice = choice
    game.opponentSalt = salt

    -- Check if reveal is complete
    self:CheckRPSRevealComplete()
end

--[[
    Check if RPS reveal is complete and determine winner
]]
function Minigames:CheckRPSRevealComplete()
    local game = self.activeGame
    if not game or game.gameType ~= Minigames.GAME_RPS then return end
    if not game.myChoice or not game.opponentChoice then return end

    -- Cancel timeout
    if self.timeoutTimer then
        self.timeoutTimer:Cancel()
        self.timeoutTimer = nil
    end

    -- Determine winner
    local myResult = RPS_OUTCOMES[game.myChoice][game.opponentChoice]

    -- Record stats
    self:RecordGameResult(game.opponent, Minigames.GAME_RPS, myResult, game.myChoice, game.opponentChoice)

    -- Mark complete
    game.state = STATE_COMPLETED

    -- Format choices for display
    local function capitalize(s)
        return s:sub(1,1):upper() .. s:sub(2)
    end

    local myDisplay = capitalize(game.myChoice)
    local oppDisplay = capitalize(game.opponentChoice)

    -- Announce result
    local resultText
    if myResult == "win" then
        resultText = "|cFF00FF00You win!|r (" .. myDisplay .. " beats " .. oppDisplay .. ")"
    elseif myResult == "lose" then
        resultText = "|cFFFF0000You lose!|r (" .. oppDisplay .. " beats " .. myDisplay .. ")"
    else
        resultText = "|cFFFFFF00Tie!|r (Both chose " .. myDisplay .. ")"
    end
    HopeAddon:Print("Rock-Paper-Scissors Result: " .. resultText)

    -- Update UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowRPSResult(game.myChoice, game.opponentChoice, myResult)
    end

    -- Challenger sends result confirmation
    if game.isChallenger then
        local winner = myResult == "win" and UnitName("player") or
                      (myResult == "lose" and game.opponent or "tie")
        local data = string.format("%s|%s|%s|%s",
            game.sessionId, winner, game.myChoice, game.opponentChoice)
        self:SendGameMessage(game.opponent, Minigames.MSG_GAME_RESULT, data)
    end
end

--============================================================
-- STATS TRACKING
--============================================================

--[[
    Ensure minigame stats structure exists for a player
    @param playerName string
]]
function Minigames:EnsureStatsStructure(playerName)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end

    local known = HopeAddon.charDb.travelers.known
    if not known then return end

    if not known[playerName] then
        known[playerName] = {
            firstSeen = HopeAddon:GetDate(),
            lastSeen = HopeAddon:GetDate(),
            stats = {},
        }
    end

    if not known[playerName].stats then
        known[playerName].stats = {}
    end

    if not known[playerName].stats.minigames then
        known[playerName].stats.minigames = {
            rps = { wins = 0, losses = 0, ties = 0, lastPlayed = nil },
            deathroll = { wins = 0, losses = 0, ties = 0, highestBet = 0, lastPlayed = nil },
            pong = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil },
            tetris = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil },
            words = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil },
            battleship = { wins = 0, losses = 0, ties = 0, lastPlayed = nil },
        }
    end

    -- Ensure all game stats exist for existing players (migration)
    local stats = known[playerName].stats
    if stats.minigames then
        if not stats.minigames.deathroll then
            stats.minigames.deathroll = { wins = 0, losses = 0, ties = 0, highestBet = 0, lastPlayed = nil }
        end
        if not stats.minigames.pong then
            stats.minigames.pong = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil }
        end
        if not stats.minigames.tetris then
            stats.minigames.tetris = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil }
        end
        if not stats.minigames.words then
            stats.minigames.words = { wins = 0, losses = 0, ties = 0, highestScore = 0, lastPlayed = nil }
        end
        if not stats.minigames.battleship then
            stats.minigames.battleship = { wins = 0, losses = 0, ties = 0, lastPlayed = nil }
        end
        -- Migration: ensure ties field exists on all game stats
        for _, gameStats in pairs(stats.minigames) do
            if gameStats.ties == nil then
                gameStats.ties = 0
            end
        end
    end
end

--[[
    Record game result
    @param opponent string
    @param gameType string
    @param result string - "win", "lose", or "tie"
    @param myMove any - Player's roll/choice
    @param theirMove any - Opponent's roll/choice
]]
function Minigames:RecordGameResult(opponent, gameType, result, myMove, theirMove)
    self:EnsureStatsStructure(opponent)

    local known = HopeAddon.charDb.travelers.known
    if not known or not known[opponent] then return end

    local stats = known[opponent].stats.minigames[gameType]
    if not stats then return end

    -- Update counts
    if result == "win" then
        stats.wins = stats.wins + 1
    elseif result == "lose" then
        stats.losses = stats.losses + 1
    else
        stats.ties = stats.ties + 1
    end

    -- Update last played
    stats.lastPlayed = HopeAddon:GetDate()

    -- Game-specific stats tracking
    if gameType == "deathroll" and type(myMove) == "number" then
        -- Track highest bet amount
        if myMove > (stats.highestBet or 0) then
            stats.highestBet = myMove
        end
    elseif (gameType == "pong" or gameType == "tetris" or gameType == "words") and type(myMove) == "number" then
        -- Track highest score
        if myMove > (stats.highestScore or 0) then
            stats.highestScore = myMove
        end
    end

    HopeAddon:Debug("Recorded game result:", opponent, gameType, result)
end

--[[
    Get minigame stats for a player
    @param playerName string
    @return table|nil
]]
function Minigames:GetStats(playerName)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return nil end
    local known = HopeAddon.charDb.travelers.known
    if not known or not known[playerName] then return nil end
    if not known[playerName].stats then return nil end
    return known[playerName].stats.minigames
end

--[[
    Format stats for display
    @param playerName string
    @return string
]]
function Minigames:FormatStats(playerName)
    local stats = self:GetStats(playerName)
    if not stats then return "No games played" end

    local lines = {}

    -- RPS stats
    local rps = stats.rps
    if rps and (rps.wins + rps.losses + rps.ties) > 0 then
        table.insert(lines, string.format("RPS: %dW-%dL-%dT",
            rps.wins, rps.losses, rps.ties))
    end

    if #lines == 0 then
        return "No games played"
    end

    return table.concat(lines, " | ")
end

--============================================================
-- RESULT VALIDATION
--============================================================

--[[
    Handle incoming result confirmation from challenger
    Validates that the result matches our local calculation
    @param sender string - Challenger name
    @param data string - sessionId|winner|move1|move2
]]
function Minigames:HandleResult(sender, data)
    local parsed = ParseMessage("GRES", data)
    if not parsed then return end

    local sessionId = parsed.sessionId
    local winner = parsed.winner
    local move1 = parsed.move1
    local move2 = parsed.move2

    -- Only non-challengers receive GRES messages
    if not self.activeGame then
        HopeAddon:Debug("Received result for no active game")
        return
    end

    if self.activeGame.sessionId ~= sessionId then
        HopeAddon:Debug("Received result for wrong session:", sessionId)
        return
    end

    -- We already calculated our result locally, but let's validate it matches
    local game = self.activeGame
    local localWinner

    -- For RPS: use outcome table
    if game.myChoice and game.opponentChoice then
        local myResult = RPS_OUTCOMES[game.myChoice][game.opponentChoice]
        if myResult == "win" then
            localWinner = UnitName("player")
        elseif myResult == "lose" then
            localWinner = game.opponent
        else
            localWinner = "tie"
        end
    end

    -- Validate result matches
    if localWinner and winner ~= localWinner then
        HopeAddon:Debug("Result mismatch! Local:", localWinner, "Remote:", winner)
        HopeAddon:Print("|cFFFF6600Warning:|r Result from " .. sender .. " doesn't match local calculation (local: " .. localWinner .. ", remote: " .. winner .. ")")
    else
        HopeAddon:Debug("Result validated successfully:", winner)
    end
end

--============================================================
-- MESSAGE HANDLING
--============================================================

--[[
    Send a game message to a player
    @param target string - Player name
    @param msgType string - Message type constant
    @param data string - Message data
]]
function Minigames:SendGameMessage(target, msgType, data)
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(target, msgType, data)
    end
end

--[[
    Route incoming game message to appropriate handler
    Called from FellowTravelers:OnAddonMessage
    @param msgType string
    @param sender string
    @param data string
    @return boolean - True if message was handled
]]
function Minigames:HandleMessage(msgType, sender, data)
    if msgType == self.MSG_GAME_CHALLENGE then
        self:HandleChallenge(sender, data)
        return true

    elseif msgType == self.MSG_GAME_ACCEPT then
        self:HandleAccept(sender, data)
        return true

    elseif msgType == self.MSG_GAME_REJECT then
        self:HandleReject(sender, data)
        return true

    elseif msgType == self.MSG_GAME_MOVE then
        -- Route to RPS handler
        if self.activeGame then
            self:HandleRPSMove(sender, data)
        end
        return true

    elseif msgType == self.MSG_GAME_REVEAL then
        self:HandleRPSReveal(sender, data)
        return true

    elseif msgType == self.MSG_GAME_RESULT then
        self:HandleResult(sender, data)
        return true

    elseif msgType == self.MSG_GAME_CANCEL then
        local parsed = ParseMessage("GCAN", data)
        if parsed and self.activeGame and self.activeGame.sessionId == parsed.sessionId then
            self.activeGame = nil
            if self.timeoutTimer then
                self.timeoutTimer:Cancel()
                self.timeoutTimer = nil
            end
            HopeAddon:Print(sender .. " cancelled the game.")
            if HopeAddon.MinigamesUI then
                HopeAddon.MinigamesUI:OnGameCancelled("opponent_cancelled")
            end
        end
        return true
    end

    return false
end

--[[
    Check if a message type is a minigame message
    @param msgType string
    @return boolean
]]
function Minigames:IsMinigameMessage(msgType)
    return msgType == self.MSG_GAME_CHALLENGE or
           msgType == self.MSG_GAME_ACCEPT or
           msgType == self.MSG_GAME_REJECT or
           msgType == self.MSG_GAME_MOVE or
           msgType == self.MSG_GAME_REVEAL or
           msgType == self.MSG_GAME_RESULT or
           msgType == self.MSG_GAME_CANCEL
end

--============================================================
-- LOCAL RPS GAME (vs AI)
--============================================================

-- AI opponent names for flavor
local AI_OPPONENTS = {
    "The Arcane Automaton",
    "Chromie's Timebot",
    "Illidan's Echo",
    "Khadgar's Familiar",
    "Medivh's Ghost",
    "Kel'Thuzad's Shade",
    "Vol'jin's Spirit",
    "Mograine's Specter",
}

-- Local RPS game state
Minigames.localRPSGame = nil

--[[
    Start a local RPS game against AI
]]
function Minigames:StartLocalRPSGame()
    -- Random AI opponent name for fun
    local aiName = AI_OPPONENTS[math.random(#AI_OPPONENTS)]

    self.localRPSGame = {
        isLocal = true,
        aiName = aiName,
        playerChoice = nil,
        aiChoice = nil,
        result = nil,
        state = "choosing",  -- choosing, revealing, complete
    }

    -- Show UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowLocalRPSGame(aiName)
    end
end

--[[
    Handle player making choice in local RPS
    @param choice string - "rock", "paper", or "scissors"
]]
function Minigames:HandleLocalRPSChoice(choice)
    local game = self.localRPSGame
    if not game or game.state ~= "choosing" then return end

    -- Validate choice
    choice = string.lower(choice)
    if choice ~= RPS_ROCK and choice ~= RPS_PAPER and choice ~= RPS_SCISSORS then
        return
    end

    game.playerChoice = choice
    game.state = "revealing"

    -- AI makes random choice
    local choices = {RPS_ROCK, RPS_PAPER, RPS_SCISSORS}
    game.aiChoice = choices[math.random(3)]

    -- Determine result
    local result = RPS_OUTCOMES[choice][game.aiChoice]

    -- Record stats (AI as opponent name)
    self:RecordGameResult(game.aiName, Minigames.GAME_RPS, result, choice, game.aiChoice)

    game.result = result
    game.state = "complete"

    -- Trigger gameshow reveal in UI
    if HopeAddon.MinigamesUI then
        HopeAddon.MinigamesUI:ShowLocalRPSReveal(game)
    end
end

--[[
    Clear local RPS game state
]]
function Minigames:ClearLocalRPSGame()
    self.localRPSGame = nil
end

-- Register module
HopeAddon:RegisterModule("Minigames", Minigames)
HopeAddon:Debug("Minigames module loaded")
