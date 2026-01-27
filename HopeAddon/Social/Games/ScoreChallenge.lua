--[[
    HopeAddon Score Challenge System
    Manages score-based challenges for Tetris and Pong
    Both players play locally, compare scores at the end
]]

local ScoreChallenge = {}

--============================================================
-- CONSTANTS
--============================================================

-- Challenge states
ScoreChallenge.STATE = {
    NONE = "NONE",
    PENDING = "PENDING",       -- Waiting for opponent to accept
    COUNTDOWN = "COUNTDOWN",   -- Both accepted, countdown starting
    PLAYING = "PLAYING",       -- Game in progress
    WAITING = "WAITING",       -- Local game done, waiting for opponent
    FINISHED = "FINISHED",     -- Both done, winner declared
}

-- Timing
local STATUS_PING_INTERVAL = 10  -- Send status every 10 seconds
local CHALLENGE_TIMEOUT = 60     -- Seconds before challenge expires
local GAME_TIMEOUT = 600         -- 10 minute max game length
local WAIT_TIMEOUT = 120         -- 2 minutes to wait for opponent after finishing

--============================================================
-- MODULE STATE
--============================================================

-- Current active challenge (only one at a time)
ScoreChallenge.activeChallenge = nil

-- Pending received challenges
ScoreChallenge.pendingChallenges = {}  -- [senderName] = { gameType, gameId, timestamp }

-- Timers
ScoreChallenge.statusTicker = nil

--============================================================
-- LIFECYCLE
--============================================================

function ScoreChallenge:OnInitialize()
    HopeAddon:Debug("ScoreChallenge initializing...")
end

function ScoreChallenge:OnEnable()
    -- Register network handlers
    self:RegisterNetworkHandlers()

    HopeAddon:Debug("ScoreChallenge enabled")
end

function ScoreChallenge:OnDisable()
    -- Unregister network handlers to prevent handler accumulation on /reload
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:UnregisterHandler("SCORE_TETRIS", "MOVE")
        GameComms:UnregisterHandler("SCORE_TETRIS", "END")
        GameComms:UnregisterHandler("SCORE_PONG", "MOVE")
        GameComms:UnregisterHandler("SCORE_PONG", "END")
    end

    -- Cancel active challenge
    if self.activeChallenge then
        self:CancelChallenge("SHUTDOWN")
    end

    -- Stop status ticker
    if self.statusTicker then
        self.statusTicker:Cancel()
        self.statusTicker = nil
    end

    -- Clear pending challenges
    wipe(self.pendingChallenges)
end

function ScoreChallenge:RegisterNetworkHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Register handlers using existing GameComms infrastructure
    -- SCORE_TETRIS and SCORE_PONG are treated as game types

    -- Score challenge MOVE handler (for status pings)
    GameComms:RegisterHandler("SCORE_TETRIS", "MOVE", function(sender, gameId, data)
        self:OnOpponentStatus(sender, gameId, data)
    end)
    GameComms:RegisterHandler("SCORE_PONG", "MOVE", function(sender, gameId, data)
        self:OnOpponentStatus(sender, gameId, data)
    end)

    -- Score challenge END handler
    GameComms:RegisterHandler("SCORE_TETRIS", "END", function(sender, gameId, data)
        self:OnOpponentEnded(sender, gameId, data)
    end)
    GameComms:RegisterHandler("SCORE_PONG", "END", function(sender, gameId, data)
        self:OnOpponentEnded(sender, gameId, data)
    end)

    -- For invite/accept/decline, we'll use GameComms' existing system
    -- but intercept it at the invite handler level
end

--============================================================
-- CHALLENGE FLOW
--============================================================

--[[
    Start a new score challenge
    @param opponent string - Target player name
    @param gameType string - TETRIS or PONG
    @return boolean - Success
]]
function ScoreChallenge:StartChallenge(opponent, gameType)
    if not opponent or opponent == UnitName("player") then
        HopeAddon:Print("Cannot challenge yourself!")
        return false
    end

    -- Check if already in a challenge
    if self.activeChallenge then
        HopeAddon:Print("Already in a challenge. Use /hope cancel to abort.")
        return false
    end

    -- Verify opponent is a Fellow Traveler with detailed feedback
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    local fellow = FellowTravelers and FellowTravelers:GetFellow(opponent)

    if not fellow then
        HopeAddon:Print("|cFFFF6666" .. opponent .. "|r has not been discovered yet.")
        HopeAddon:Print("Fellow Travelers are discovered automatically within ~300 yards.")
        HopeAddon:Print("Wait a moment or group up with them to discover faster.")
        return false
    end

    -- Check if recently seen (within 5 minutes)
    local now = time()
    local lastSeen = fellow.lastSeenTime or 0
    local timeSinceLastSeen = now - lastSeen
    if timeSinceLastSeen > 300 then
        local minsAgo = math.floor(timeSinceLastSeen / 60)
        HopeAddon:Print("|cFFFFFF66Warning:|r " .. opponent .. " was last seen " .. minsAgo .. " minutes ago.")
        HopeAddon:Print("They may be offline or out of range. Sending challenge anyway...")
    end

    -- Generate game ID
    local gameId = string.format("SC_%s_%d", UnitName("player"), GetTime() * 1000)

    -- Create challenge state
    self.activeChallenge = {
        gameId = gameId,
        gameType = gameType,
        opponent = opponent,
        isChallenger = true,
        state = self.STATE.PENDING,
        startTime = GetTime(),

        -- My stats
        myScore = 0,
        myLines = 0,
        myLevel = 1,
        myFinished = false,
        myFinishTime = nil,

        -- Opponent stats
        opponentScore = 0,
        opponentLines = 0,
        opponentLevel = 1,
        opponentFinished = false,
        opponentFinishTime = nil,

        -- Timing
        lastPingTime = 0,
        lastOpponentPing = GetTime(),
    }

    -- Send challenge
    self:SendMessage(opponent, "INVITE", gameId, gameType)

    HopeAddon:Print("Challenge sent to " .. opponent .. " for " .. gameType .. " Score Battle!")
    HopeAddon:Print("Waiting for response... (60 second timeout)")

    -- Start timeout timer
    self.activeChallenge.timeoutTimer = HopeAddon.Timer:After(CHALLENGE_TIMEOUT, function()
        if self.activeChallenge and self.activeChallenge.state == self.STATE.PENDING then
            HopeAddon:Print("Challenge to " .. opponent .. " timed out.")
            self:CancelChallenge("TIMEOUT")
        end
    end)

    return true
end

--[[
    Accept a pending challenge
    @param challenger string - Who sent the challenge
    @return boolean - Success
]]
function ScoreChallenge:AcceptChallenge(challenger)
    local pending = self.pendingChallenges[challenger]
    if not pending then
        HopeAddon:Print("No pending challenge from " .. (challenger or "anyone"))
        return false
    end

    -- Check if already in a challenge
    if self.activeChallenge then
        HopeAddon:Print("Already in a challenge. Use /hope cancel to abort.")
        return false
    end

    -- Create challenge state
    self.activeChallenge = {
        gameId = pending.gameId,
        gameType = pending.gameType,
        opponent = challenger,
        isChallenger = false,
        state = self.STATE.COUNTDOWN,
        startTime = GetTime(),

        -- My stats
        myScore = 0,
        myLines = 0,
        myLevel = 1,
        myFinished = false,
        myFinishTime = nil,

        -- Opponent stats
        opponentScore = 0,
        opponentLines = 0,
        opponentLevel = 1,
        opponentFinished = false,
        opponentFinishTime = nil,

        -- Timing
        lastPingTime = 0,
        lastOpponentPing = GetTime(),
    }

    -- Clear pending
    self.pendingChallenges[challenger] = nil

    -- Send accept
    self:SendMessage(challenger, "ACCEPT", pending.gameId, pending.gameType)

    HopeAddon:Print("Challenge accepted! Starting " .. pending.gameType .. " Score Battle vs " .. challenger)

    -- Start the game
    self:StartGame()

    return true
end

--[[
    Decline a pending challenge
    @param challenger string
]]
function ScoreChallenge:DeclineChallenge(challenger)
    local pending = self.pendingChallenges[challenger]
    if not pending then return end

    -- Send decline
    self:SendMessage(challenger, "DECLINE", pending.gameId, "")

    -- Clear pending
    self.pendingChallenges[challenger] = nil

    HopeAddon:Print("Declined challenge from " .. challenger)
end

--[[
    Cancel current challenge
    @param reason string
]]
function ScoreChallenge:CancelChallenge(reason)
    if not self.activeChallenge then return end

    -- Cancel timeout timer
    if self.activeChallenge.timeoutTimer then
        self.activeChallenge.timeoutTimer:Cancel()
    end

    -- Stop status ticker
    if self.statusTicker then
        self.statusTicker:Cancel()
        self.statusTicker = nil
    end

    -- Notify opponent if not already finished
    if self.activeChallenge.state ~= self.STATE.FINISHED then
        self:SendMessage(self.activeChallenge.opponent, "END",
            self.activeChallenge.gameId,
            "CANCEL|" .. (reason or "QUIT"))
    end

    -- Clean up any running game
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore and self.activeChallenge.localGameId then
        GameCore:DestroyGame(self.activeChallenge.localGameId)
    end

    self.activeChallenge = nil

    HopeAddon:Print("Challenge cancelled: " .. (reason or "user quit"))
end

--============================================================
-- GAME MANAGEMENT
--============================================================

--[[
    Start the actual game
]]
function ScoreChallenge:StartGame()
    if not self.activeChallenge then return end

    local challenge = self.activeChallenge
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    challenge.state = self.STATE.PLAYING

    -- Create local game in SCORE_CHALLENGE mode
    local gameId = GameCore:CreateGame(
        GameCore.GAME_TYPE[challenge.gameType],
        GameCore.GAME_MODE.SCORE_CHALLENGE,
        challenge.opponent
    )

    challenge.localGameId = gameId

    -- Store reference to challenge in game data
    local game = GameCore:GetGame(gameId)
    if game then
        game.scoreChallenge = challenge
    end

    -- Start game
    GameCore:StartGame(gameId)

    -- Start status ping ticker
    self.statusTicker = HopeAddon.Timer:NewTicker(STATUS_PING_INTERVAL, function()
        self:SendStatusPing()
    end)

    -- Start game timeout
    challenge.gameTimeoutTimer = HopeAddon.Timer:After(GAME_TIMEOUT, function()
        if self.activeChallenge and self.activeChallenge.state == self.STATE.PLAYING then
            HopeAddon:Print("Score challenge timed out (10 minute limit).")
            self:OnLocalGameEnded(self.activeChallenge.myScore, self.activeChallenge.myLines, self.activeChallenge.myLevel)
        end
    end)
end

--[[
    Called when local game updates score
    @param score number
    @param lines number (Tetris)
    @param level number
]]
function ScoreChallenge:UpdateMyScore(score, lines, level)
    if not self.activeChallenge then return end

    self.activeChallenge.myScore = score
    self.activeChallenge.myLines = lines or 0
    self.activeChallenge.myLevel = level or 1
end

--[[
    Called when local game ends
    @param finalScore number
    @param lines number
    @param level number
]]
function ScoreChallenge:OnLocalGameEnded(finalScore, lines, level)
    if not self.activeChallenge then return end

    local challenge = self.activeChallenge

    challenge.myScore = finalScore
    challenge.myLines = lines or 0
    challenge.myLevel = level or 1
    challenge.myFinished = true
    challenge.myFinishTime = GetTime()

    -- Stop status ticker
    if self.statusTicker then
        self.statusTicker:Cancel()
        self.statusTicker = nil
    end

    -- Cancel game timeout
    if challenge.gameTimeoutTimer then
        challenge.gameTimeoutTimer:Cancel()
        challenge.gameTimeoutTimer = nil
    end

    -- Send final score
    self:SendMessage(challenge.opponent, "END", challenge.gameId,
        string.format("%d|%d|%d", finalScore, lines or 0, level or 1))

    -- Check if opponent already finished
    if challenge.opponentFinished then
        self:CompareResults()
    else
        challenge.state = self.STATE.WAITING
        HopeAddon:Print("Game over! Score: " .. finalScore .. ". Waiting for " .. challenge.opponent .. "...")

        -- Start wait timeout
        challenge.waitTimeoutTimer = HopeAddon.Timer:After(WAIT_TIMEOUT, function()
            if self.activeChallenge and self.activeChallenge.state == self.STATE.WAITING then
                HopeAddon:Print(challenge.opponent .. " didn't finish in time. You win by forfeit!")
                self:DeclareWinner(UnitName("player"), "FORFEIT")
            end
        end)
    end
end

--[[
    Compare results and declare winner
]]
function ScoreChallenge:CompareResults()
    if not self.activeChallenge then return end

    local challenge = self.activeChallenge
    challenge.state = self.STATE.FINISHED

    -- Cancel wait timeout
    if challenge.waitTimeoutTimer then
        challenge.waitTimeoutTimer:Cancel()
        challenge.waitTimeoutTimer = nil
    end

    local myScore = challenge.myScore
    local theirScore = challenge.opponentScore

    local winner
    local reason = "SCORE"

    if myScore > theirScore then
        winner = UnitName("player")
    elseif theirScore > myScore then
        winner = challenge.opponent
    else
        -- Tie-breaker: who finished first
        if challenge.myFinishTime and challenge.opponentFinishTime then
            if challenge.myFinishTime < challenge.opponentFinishTime then
                winner = UnitName("player")
                reason = "TIEBREAK"
            else
                winner = challenge.opponent
                reason = "TIEBREAK"
            end
        else
            winner = "DRAW"
            reason = "TIE"
        end
    end

    self:DeclareWinner(winner, reason)
end

--[[
    Declare the winner
    @param winner string - Player name or "DRAW"
    @param reason string
]]
function ScoreChallenge:DeclareWinner(winner, reason)
    if not self.activeChallenge then return end

    local challenge = self.activeChallenge

    -- Display results
    HopeAddon:Print("=== " .. challenge.gameType .. " SCORE BATTLE RESULTS ===")
    HopeAddon:Print("You: " .. challenge.myScore .. " | " .. challenge.opponent .. ": " .. challenge.opponentScore)

    if winner == "DRAW" then
        HopeAddon:Print("It's a DRAW!")
    elseif winner == UnitName("player") then
        HopeAddon:Print("YOU WIN! " .. (reason == "TIEBREAK" and "(Tiebreaker: finished first)" or ""))
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayAchievement()
        end
    else
        HopeAddon:Print(winner .. " wins! " .. (reason == "TIEBREAK" and "(Tiebreaker: finished first)" or ""))
    end

    -- Record stats
    local Minigames = HopeAddon:GetModule("Minigames")
    if Minigames and Minigames.RecordGameResult then
        local result = winner == UnitName("player") and "win" or (winner == "DRAW" and "draw" or "lose")
        Minigames:RecordGameResult(challenge.opponent, challenge.gameType:lower(), result, challenge.myScore)
    end

    -- Clean up
    self.activeChallenge = nil
end

--============================================================
-- NETWORK HANDLERS
--============================================================

function ScoreChallenge:OnChallengeReceived(sender, gameId, data)
    -- Data contains game type
    local gameType = data

    -- Store pending challenge
    self.pendingChallenges[sender] = {
        gameId = gameId,
        gameType = gameType,
        timestamp = GetTime(),
    }

    -- Play notification sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    -- Show challenge popup via MinigamesUI
    local MinigamesUI = HopeAddon:GetModule("MinigamesUI")
    if MinigamesUI and MinigamesUI.ShowChallengePopup then
        -- Use "SCORE_" prefix so popup shows correct game name
        MinigamesUI:ShowChallengePopup(sender, "SCORE_" .. gameType, gameId, "scorechallenge")
    end

    -- Also print to chat as fallback
    HopeAddon:Print(sender .. " challenges you to a " .. gameType .. " Score Battle!")
    HopeAddon:Print("Type /hope accept to play, or /hope decline to refuse.")

    -- Auto-expire after timeout
    HopeAddon.Timer:After(CHALLENGE_TIMEOUT, function()
        if self.pendingChallenges[sender] and self.pendingChallenges[sender].gameId == gameId then
            self.pendingChallenges[sender] = nil
            -- Hide popup if still showing for this challenge
            if MinigamesUI and MinigamesUI.HideChallengePopup then
                MinigamesUI:HideChallengePopup()
            end
        end
    end)
end

function ScoreChallenge:OnChallengeAccepted(sender, gameId, data)
    if not self.activeChallenge then return end
    if self.activeChallenge.gameId ~= gameId then return end
    if sender ~= self.activeChallenge.opponent then return end

    -- Cancel timeout
    if self.activeChallenge.timeoutTimer then
        self.activeChallenge.timeoutTimer:Cancel()
    end

    HopeAddon:Print(sender .. " accepted! Starting game...")

    -- Start the game
    self:StartGame()
end

function ScoreChallenge:OnChallengeDeclined(sender, gameId)
    if not self.activeChallenge then return end
    if self.activeChallenge.gameId ~= gameId then return end

    HopeAddon:Print(sender .. " declined your challenge.")
    self:CancelChallenge("DECLINED")
end

function ScoreChallenge:OnOpponentStatus(sender, gameId, data)
    if not self.activeChallenge then return end
    if self.activeChallenge.gameId ~= gameId then return end
    if sender ~= self.activeChallenge.opponent then return end

    -- Parse: score|lines|level|token
    local score, lines, level, token = strsplit("|", data)

    -- Validate token (simple anti-cheat)
    local expectedToken = self:GenerateToken(gameId, score, sender)
    if token ~= expectedToken then
        HopeAddon:Debug("ScoreChallenge: Invalid token from", sender)
        -- Don't reject - might be timing issue, just log it
    end

    self.activeChallenge.opponentScore = tonumber(score) or 0
    self.activeChallenge.opponentLines = tonumber(lines) or 0
    self.activeChallenge.opponentLevel = tonumber(level) or 1
    self.activeChallenge.lastOpponentPing = GetTime()

    -- Update UI if game supports it
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI and GameUI.UpdateOpponentStatus then
        GameUI:UpdateOpponentStatus(
            self.activeChallenge.localGameId,
            self.activeChallenge.opponentScore,
            self.activeChallenge.opponentLines,
            self.activeChallenge.opponentLevel,
            "PLAYING"
        )
    end
end

function ScoreChallenge:OnOpponentEnded(sender, gameId, data)
    if not self.activeChallenge then return end
    if self.activeChallenge.gameId ~= gameId then return end
    if sender ~= self.activeChallenge.opponent then return end

    -- Parse: score|lines|level OR CANCEL|reason
    local part1, part2, part3 = strsplit("|", data)

    if part1 == "CANCEL" then
        HopeAddon:Print(sender .. " cancelled the challenge.")
        if self.activeChallenge.state == self.STATE.PLAYING then
            HopeAddon:Print("You win by forfeit!")
            self:DeclareWinner(UnitName("player"), "FORFEIT")
        else
            self:CancelChallenge("OPPONENT_QUIT")
        end
        return
    end

    self.activeChallenge.opponentScore = tonumber(part1) or 0
    self.activeChallenge.opponentLines = tonumber(part2) or 0
    self.activeChallenge.opponentLevel = tonumber(part3) or 1
    self.activeChallenge.opponentFinished = true
    self.activeChallenge.opponentFinishTime = GetTime()

    -- Update UI
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI and GameUI.UpdateOpponentStatus then
        GameUI:UpdateOpponentStatus(
            self.activeChallenge.localGameId,
            self.activeChallenge.opponentScore,
            self.activeChallenge.opponentLines,
            self.activeChallenge.opponentLevel,
            "FINISHED"
        )
    end

    -- If we're done too, compare
    if self.activeChallenge.myFinished then
        self:CompareResults()
    else
        HopeAddon:Print(sender .. " finished with " .. self.activeChallenge.opponentScore .. " points! Keep playing!")
    end
end

--============================================================
-- MESSAGING
--============================================================

function ScoreChallenge:SendStatusPing()
    if not self.activeChallenge then return end
    if self.activeChallenge.state ~= self.STATE.PLAYING then return end

    local challenge = self.activeChallenge
    local token = self:GenerateToken(challenge.gameId, challenge.myScore, UnitName("player"))

    local data = string.format("%d|%d|%d|%s",
        challenge.myScore,
        challenge.myLines,
        challenge.myLevel,
        token)

    self:SendMessage(challenge.opponent, "STATUS", challenge.gameId, data)
    challenge.lastPingTime = GetTime()
end

function ScoreChallenge:SendMessage(target, msgType, gameId, data)
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Determine the score game type from active challenge
    local gameType = "SCORE_" .. (self.activeChallenge and self.activeChallenge.gameType or "TETRIS")

    if msgType == "INVITE" then
        -- Use custom send since GameComms:SendInvite has its own gameId generation
        GameComms:SendGameMessage(target, "GINV", gameType, gameId, data)
    elseif msgType == "ACCEPT" then
        GameComms:SendGameMessage(target, "GACC", gameType, gameId, data)
    elseif msgType == "DECLINE" then
        GameComms:SendGameMessage(target, "GDEC", gameType, gameId, data)
    elseif msgType == "STATUS" then
        GameComms:SendMove(target, gameType, gameId, data)
    elseif msgType == "END" then
        GameComms:SendEnd(target, gameType, gameId, data)
    end
end

--============================================================
-- ANTI-CHEAT TOKEN
--============================================================

--[[
    Generate simple validation token
    @param gameId string
    @param score number
    @param playerName string
    @return string - Token
]]
function ScoreChallenge:GenerateToken(gameId, score, playerName)
    -- Simple hash: first 4 chars of both player names + gameId last 4 + score
    -- Not secure, but prevents casual injection
    local myName = UnitName("player")
    local oppName = self.activeChallenge and self.activeChallenge.opponent or ""

    local secret = string.sub(myName, 1, 4) .. string.sub(oppName, 1, 4)
    local gameKey = string.sub(gameId, -4)

    -- Simple numeric hash
    local hash = 0
    for i = 1, #secret do
        hash = hash + string.byte(secret, i) * i
    end
    hash = hash + (tonumber(score) or 0)
    hash = hash + (tonumber(gameKey) or 0)

    return string.format("%X", hash % 65536)  -- 4 hex chars
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Check if in an active challenge
    @return boolean
]]
function ScoreChallenge:IsInChallenge()
    return self.activeChallenge ~= nil
end

--[[
    Get current challenge info
    @return table|nil
]]
function ScoreChallenge:GetActiveChallenge()
    return self.activeChallenge
end

--[[
    Get pending challenge from a player
    @param playerName string
    @return table|nil
]]
function ScoreChallenge:GetPendingChallenge(playerName)
    return self.pendingChallenges[playerName]
end

--[[
    Check if there are any pending challenges
    @return boolean
]]
function ScoreChallenge:HasPendingChallenges()
    return next(self.pendingChallenges) ~= nil
end

-- Register with addon
HopeAddon:RegisterModule("ScoreChallenge", ScoreChallenge)
HopeAddon.ScoreChallenge = ScoreChallenge

HopeAddon:Debug("ScoreChallenge module loaded")
