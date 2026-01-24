--[[
    HopeAddon Game Core
    Shared game loop, state machine, and common utilities for mini-games
]]

local GameCore = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game states
GameCore.STATE = {
    IDLE = "IDLE",           -- No game active
    WAITING = "WAITING",     -- Waiting for opponent response
    PLAYING = "PLAYING",     -- Game in progress
    PAUSED = "PAUSED",       -- Game paused
    ENDED = "ENDED",         -- Game finished
}

-- Game types
GameCore.GAME_TYPE = {
    DEATH_ROLL = "DEATH_ROLL",
    PONG = "PONG",
    TETRIS = "TETRIS",
    WORDS = "WORDS",
    BATTLESHIP = "BATTLESHIP",
}

-- Game modes
GameCore.GAME_MODE = {
    LOCAL = "LOCAL",                   -- Both players same keyboard
    NEARBY = "NEARBY",                 -- Using YELL channel (in-person)
    REMOTE = "REMOTE",                 -- Using WHISPER channel (any distance)
    SCORE_CHALLENGE = "SCORE_CHALLENGE", -- Play locally, compare scores at end
}

-- Frame rate target (60fps for smooth modern gameplay)
GameCore.TARGET_FPS = 60
GameCore.FRAME_TIME = 1 / GameCore.TARGET_FPS

--============================================================
-- MODULE STATE
--============================================================

-- Active games registry
GameCore.activeGames = {}

-- Game update frame
GameCore.updateFrame = nil
GameCore.lastUpdate = 0

-- Registered game types
GameCore.registeredGames = {}

--============================================================
-- LIFECYCLE
--============================================================

function GameCore:OnInitialize()
    HopeAddon:Debug("GameCore initializing...")
end

function GameCore:OnEnable()
    -- Create update frame for game loops
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)

    HopeAddon:Debug("GameCore enabled")
end

function GameCore:OnDisable()
    -- Stop all active games
    for gameId, game in pairs(self.activeGames) do
        self:EndGame(gameId, "SHUTDOWN")
    end

    if self.updateFrame then
        self.updateFrame:SetScript("OnUpdate", nil)
        self.updateFrame:Hide()
        self.updateFrame:SetParent(nil)
        self.updateFrame = nil
    end

    -- Clear key states to prevent memory accumulation
    wipe(self.keyStates)
end

--============================================================
-- GAME REGISTRATION
--============================================================

--[[
    Register a game type
    @param gameType string - Game type constant
    @param gameModule table - Game module with lifecycle functions
]]
function GameCore:RegisterGame(gameType, gameModule)
    self.registeredGames[gameType] = gameModule
    HopeAddon:Debug("Registered game:", gameType)
end

--[[
    Get a registered game module
    @param gameType string
    @return table|nil
]]
function GameCore:GetGameModule(gameType)
    return self.registeredGames[gameType]
end

--============================================================
-- GAME LOOP
--============================================================

--[[
    Main update loop - distributes updates to active games
    @param elapsed number - Time since last frame
]]
function GameCore:OnUpdate(elapsed)
    self.lastUpdate = self.lastUpdate + elapsed

    -- Throttle to target FPS
    if self.lastUpdate < self.FRAME_TIME then
        return
    end

    local dt = self.lastUpdate
    self.lastUpdate = 0

    -- Update each active game
    for gameId, game in pairs(self.activeGames) do
        if game.state == self.STATE.PLAYING then
            local gameModule = self.registeredGames[game.gameType]
            if gameModule and gameModule.OnUpdate then
                gameModule:OnUpdate(gameId, dt)
            end
        end
    end
end

--============================================================
-- GAME STATE MANAGEMENT
--============================================================

--[[
    Create a new game instance
    @param gameType string - Type of game
    @param mode string - LOCAL, NEARBY, or REMOTE
    @param opponent string|nil - Opponent name (nil for local)
    @param sharedGameId string|nil - Optional shared gameId (for network games)
    @param isChallenger boolean|nil - True if this player initiated the challenge (goes first)
    @return string - Game ID
]]
function GameCore:CreateGame(gameType, mode, opponent, sharedGameId, isChallenger)
    local gameId = sharedGameId or self:GenerateGameId()
    local localPlayer = UnitName("player")

    -- Determine player1/player2 based on who challenged
    -- Player1 always goes first, so challenger should be player1
    local player1, player2
    if mode == self.GAME_MODE.REMOTE and opponent then
        if isChallenger then
            -- Challenger: I am player1, opponent is player2
            player1 = localPlayer
            player2 = opponent
        else
            -- Acceptor: Challenger (opponent) is player1, I am player2
            player1 = opponent
            player2 = localPlayer
        end
    else
        -- Local games: local player is always player1
        player1 = localPlayer
        player2 = opponent or "Player 2"
    end

    local game = {
        id = gameId,
        gameType = gameType,
        mode = mode,
        state = self.STATE.IDLE,
        opponent = opponent,
        player1 = player1,
        player2 = player2,
        isChallenger = isChallenger or false,
        startTime = nil,
        endTime = nil,
        winner = nil,
        score = { 0, 0 },
        data = {}, -- Game-specific data
    }

    self.activeGames[gameId] = game

    -- Initialize game-specific data
    local gameModule = self.registeredGames[gameType]
    if gameModule and gameModule.OnCreate then
        gameModule:OnCreate(gameId, game)
    end

    HopeAddon:Debug("Created game:", gameId, "type:", gameType)
    return gameId
end

--[[
    Start a game
    @param gameId string
]]
function GameCore:StartGame(gameId)
    local game = self.activeGames[gameId]
    if not game then return end

    game.state = self.STATE.PLAYING
    game.startTime = GetTime()

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnStart then
        gameModule:OnStart(gameId)
    end

    HopeAddon:Debug("Started game:", gameId)
end

--[[
    Pause a game
    @param gameId string
]]
function GameCore:PauseGame(gameId)
    local game = self.activeGames[gameId]
    if not game or game.state ~= self.STATE.PLAYING then return end

    game.state = self.STATE.PAUSED

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnPause then
        gameModule:OnPause(gameId)
    end
end

--[[
    Resume a paused game
    @param gameId string
]]
function GameCore:ResumeGame(gameId)
    local game = self.activeGames[gameId]
    if not game or game.state ~= self.STATE.PAUSED then return end

    game.state = self.STATE.PLAYING

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnResume then
        gameModule:OnResume(gameId)
    end
end

--[[
    End a game
    @param gameId string
    @param reason string|nil - Reason for ending
]]
function GameCore:EndGame(gameId, reason)
    local game = self.activeGames[gameId]
    if not game then return end

    game.state = self.STATE.ENDED
    game.endTime = GetTime()

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnEnd then
        gameModule:OnEnd(gameId, reason)
    end

    HopeAddon:Debug("Ended game:", gameId, "reason:", reason or "normal")
end

--[[
    Destroy a game instance (cleanup)
    @param gameId string
]]
function GameCore:DestroyGame(gameId)
    local game = self.activeGames[gameId]
    if not game then return end

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnDestroy then
        gameModule:OnDestroy(gameId)
    end

    self.activeGames[gameId] = nil
    HopeAddon:Debug("Destroyed game:", gameId)
end

--[[
    Get a game instance
    @param gameId string
    @return table|nil
]]
function GameCore:GetGame(gameId)
    return self.activeGames[gameId]
end

--[[
    Set a game's winner
    @param gameId string
    @param winner string - Player name or "DRAW"
]]
function GameCore:SetWinner(gameId, winner)
    local game = self.activeGames[gameId]
    if not game then return end

    game.winner = winner
    self:EndGame(gameId, "WINNER")
end

--[[
    Update game score
    @param gameId string
    @param player number - 1 or 2
    @param score number
]]
function GameCore:SetScore(gameId, player, score)
    local game = self.activeGames[gameId]
    if not game then return end

    game.score[player] = score

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnScoreChange then
        gameModule:OnScoreChange(gameId, player, score)
    end
end

--[[
    Increment player score
    @param gameId string
    @param player number - 1 or 2
    @param amount number - Amount to add (default 1)
]]
function GameCore:AddScore(gameId, player, amount)
    amount = amount or 1
    local game = self.activeGames[gameId]
    if not game then return end

    game.score[player] = (game.score[player] or 0) + amount

    local gameModule = self.registeredGames[game.gameType]
    if gameModule and gameModule.OnScoreChange then
        gameModule:OnScoreChange(gameId, player, game.score[player])
    end
end

--============================================================
-- UTILITY FUNCTIONS
--============================================================

--[[
    Generate unique game ID
    @return string
]]
function GameCore:GenerateGameId()
    return string.format("GAME_%s_%d", UnitName("player"), GetTime() * 1000)
end

--[[
    Get elapsed game time
    @param gameId string
    @return number - Seconds elapsed
]]
function GameCore:GetElapsedTime(gameId)
    local game = self.activeGames[gameId]
    if not game or not game.startTime then return 0 end

    if game.endTime then
        return game.endTime - game.startTime
    end
    return GetTime() - game.startTime
end

--[[
    Format time as MM:SS
    @param seconds number
    @return string
]]
function GameCore:FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

--[[
    Simple AABB collision detection
    @param x1, y1, w1, h1 - First rectangle
    @param x2, y2, w2, h2 - Second rectangle
    @return boolean
]]
function GameCore:CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

--[[
    Point in rectangle check
    @param px, py - Point coordinates
    @param rx, ry, rw, rh - Rectangle
    @return boolean
]]
function GameCore:PointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and
           py >= ry and py <= ry + rh
end

--[[
    Clamp a value between min and max
    @param value number
    @param min number
    @param max number
    @return number
]]
function GameCore:Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

--[[
    Linear interpolation
    @param a number - Start value
    @param b number - End value
    @param t number - Interpolation factor (0-1)
    @return number
]]
function GameCore:Lerp(a, b, t)
    return a + (b - a) * t
end

--[[
    Random integer between min and max (inclusive)
    @param min number
    @param max number
    @return number
]]
function GameCore:RandomInt(min, max)
    return math.random(min, max)
end

--[[
    Shuffle an array in place
    @param array table
]]
function GameCore:Shuffle(array)
    local n = #array
    for i = n, 2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end

--============================================================
-- INPUT HELPERS
--============================================================

-- Key state tracking for held keys
GameCore.keyStates = {}

--[[
    Check if a key is currently held
    @param key string
    @return boolean
]]
function GameCore:IsKeyDown(key)
    return self.keyStates[key] == true
end

--[[
    Set key state (called by input handlers)
    @param key string
    @param isDown boolean
]]
function GameCore:SetKeyState(key, isDown)
    self.keyStates[key] = isDown
end

--[[
    Clear all key states
]]
function GameCore:ClearKeyStates()
    wipe(self.keyStates)
end

-- Register with addon
HopeAddon:RegisterModule("GameCore", GameCore)
HopeAddon.GameCore = GameCore

HopeAddon:Debug("GameCore module loaded")
