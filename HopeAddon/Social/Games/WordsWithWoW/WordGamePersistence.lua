--[[
    HopeAddon Words with WoW Persistence
    Handles save/load of game state for async multiplayer
]]

local WordGamePersistence = {}

--============================================================
-- CONSTANTS
--============================================================

local PERSISTENCE_VERSION = 1

-- Configuration
WordGamePersistence.CONFIG = {
    INVITE_TIMEOUT = 24 * 60 * 60,          -- 24 hours in seconds
    INACTIVITY_FORFEIT = 30 * 24 * 60 * 60, -- 30 days in seconds
    MAX_CONCURRENT_GAMES = 10,              -- Max simultaneous games per player
    SYNC_RETRY_INTERVAL = 60,               -- Seconds between resume attempts
}

-- Game states that can be persisted
WordGamePersistence.STATE = {
    WAITING_ACCEPT = "WAITING_ACCEPT",  -- Invite sent, waiting for response
    PLAYING = "PLAYING",                -- Game in progress
    PAUSED = "PAUSED",                  -- Opponent offline
    FINISHED = "FINISHED",              -- Game complete
}

--============================================================
-- INITIALIZATION
--============================================================

function WordGamePersistence:OnInitialize()
    -- Ensure storage exists
    self:EnsureStorage()
end

function WordGamePersistence:OnEnable()
    -- Cleanup expired games/invites on enable
    self:CleanupExpired()
    HopeAddon:Debug("WordGamePersistence enabled")
end

function WordGamePersistence:OnDisable()
    -- Nothing to clean up
end

--[[
    Ensure charDb storage structure exists
]]
function WordGamePersistence:EnsureStorage()
    local charDb = HopeAddon.charDb
    if not charDb then return end

    if not charDb.savedGames then
        charDb.savedGames = {}
    end

    if not charDb.savedGames.words then
        charDb.savedGames.words = {
            games = {},             -- [opponentName] = gameState
            pendingInvites = {},    -- [senderName] = { state, timestamp }
            sentInvites = {},       -- [recipientName] = { state, timestamp }
        }
    end
end

--============================================================
-- SERIALIZATION
--============================================================

--[[
    Serialize a game for storage
    @param game table - Active game object from WordGame.games
    @return table - Serializable state
]]
function WordGamePersistence:SerializeGame(game)
    if not game or not game.data then return nil end

    local state = game.data.state
    local now = time()

    return {
        version = PERSISTENCE_VERSION,
        gameId = game.id,
        createdAt = game.createdAt or now,
        lastMoveAt = now,

        -- Players
        player1 = game.player1,
        player2 = game.player2,
        currentTurn = state.gameState,  -- PLAYER1_TURN or PLAYER2_TURN

        -- Board (sparse - only cells with letters)
        board = self:SerializeBoard(state.board),

        -- Scores
        scores = {
            [game.player1] = state.scores[game.player1] or 0,
            [game.player2] = state.scores[game.player2] or 0,
        },

        -- Move history
        moveHistory = self:CopyMoveHistory(state.moveHistory),

        -- Game state
        consecutivePasses = state.consecutivePasses or 0,
        turnCount = state.turnCount or 0,
        state = self.STATE.PLAYING,
    }
end

--[[
    Serialize board to sparse format (only letters, bonuses are calculated)
    @param board WordBoard instance
    @return table - Sparse 2D table of letters
]]
function WordGamePersistence:SerializeBoard(board)
    if not board or not board.cells then return {} end

    local sparse = {}

    for row = 1, board.size do
        for col = 1, board.size do
            local letter = board:GetLetter(row, col)
            if letter then
                if not sparse[row] then
                    sparse[row] = {}
                end
                sparse[row][col] = letter
            end
        end
    end

    return sparse
end

--[[
    Copy move history (deep copy to avoid reference issues)
    @param history table
    @return table
]]
function WordGamePersistence:CopyMoveHistory(history)
    if not history then return {} end

    local copy = {}
    for i, move in ipairs(history) do
        copy[i] = {
            player = move.player,
            word = move.word,
            startRow = move.startRow,
            startCol = move.startCol,
            horizontal = move.horizontal,
            score = move.score,
            turnNumber = move.turnNumber,
        }
    end
    return copy
end

--[[
    Deserialize board from sparse format into a WordBoard instance
    @param sparse table - Sparse letter data
    @param board WordBoard instance to populate
]]
function WordGamePersistence:DeserializeBoard(sparse, board)
    if not sparse or not board then return end

    -- Clear existing letters
    board:Clear()

    -- Restore letters
    for row, cols in pairs(sparse) do
        row = tonumber(row)
        if row then
            for col, letter in pairs(cols) do
                col = tonumber(col)
                if col and letter then
                    board:SetLetter(row, col, letter)
                end
            end
        end
    end
end

--[[
    Create a game state from serialized data
    @param savedState table - Serialized state from storage
    @return table - Reconstructed game object (partial, needs WordGame to complete)
]]
function WordGamePersistence:DeserializeGame(savedState)
    if not savedState then return nil end

    -- Version check (for future migrations)
    local version = savedState.version or 1
    if version ~= PERSISTENCE_VERSION then
        HopeAddon:Debug("WordGamePersistence: migrating from version", version)
        -- Future: handle migrations here
    end

    return {
        id = savedState.gameId,
        player1 = savedState.player1,
        player2 = savedState.player2,
        createdAt = savedState.createdAt,
        lastMoveAt = savedState.lastMoveAt,

        -- Data structure matching WordGame
        data = {
            state = {
                gameState = savedState.currentTurn,
                scores = savedState.scores or {},
                moveHistory = savedState.moveHistory or {},
                consecutivePasses = savedState.consecutivePasses or 0,
                turnCount = savedState.turnCount or 0,
                -- board will be populated by WordGame during restore
            },
        },

        -- Sparse board for restoration
        savedBoard = savedState.board,

        -- Persistence state
        persistState = savedState.state,
    }
end

--============================================================
-- GAME STORAGE
--============================================================

--[[
    Save a game against an opponent
    @param opponentName string
    @param game table - Game object from WordGame
]]
function WordGamePersistence:SaveGame(opponentName, game)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    local serialized = self:SerializeGame(game)

    if serialized then
        storage.games[opponentName] = serialized
        HopeAddon:Debug("WordGamePersistence: saved game vs", opponentName)
    end
end

--[[
    Load a saved game against an opponent
    @param opponentName string
    @return table|nil - Deserialized game state
]]
function WordGamePersistence:LoadGame(opponentName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    local saved = storage.games[opponentName]

    if saved then
        return self:DeserializeGame(saved)
    end

    return nil
end

--[[
    Remove a saved game
    @param opponentName string
]]
function WordGamePersistence:ClearGame(opponentName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    storage.games[opponentName] = nil

    HopeAddon:Debug("WordGamePersistence: cleared game vs", opponentName)
end

--[[
    Check if a game exists against an opponent
    @param opponentName string
    @return boolean
]]
function WordGamePersistence:HasGame(opponentName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    return storage.games[opponentName] ~= nil
end

--[[
    Get all active games
    @return table - Dictionary of [opponentName] = gameState
]]
function WordGamePersistence:GetAllGames()
    self:EnsureStorage()

    return HopeAddon.charDb.savedGames.words.games
end

--[[
    Get count of active games
    @return number
]]
function WordGamePersistence:GetGameCount()
    local count = 0
    for _ in pairs(self:GetAllGames()) do
        count = count + 1
    end
    return count
end

--============================================================
-- INVITE STORAGE
--============================================================

--[[
    Save a pending invite (received from another player)
    @param senderName string
    @param gameState table
]]
function WordGamePersistence:SavePendingInvite(senderName, gameState)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    storage.pendingInvites[senderName] = {
        state = gameState,
        timestamp = time(),
    }

    HopeAddon:Debug("WordGamePersistence: saved pending invite from", senderName)
end

--[[
    Get a pending invite
    @param senderName string
    @return table|nil - { state, timestamp }
]]
function WordGamePersistence:GetPendingInvite(senderName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    return storage.pendingInvites[senderName]
end

--[[
    Clear a pending invite
    @param senderName string
]]
function WordGamePersistence:ClearPendingInvite(senderName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    storage.pendingInvites[senderName] = nil
end

--[[
    Get all pending invites
    @return table
]]
function WordGamePersistence:GetAllPendingInvites()
    self:EnsureStorage()

    return HopeAddon.charDb.savedGames.words.pendingInvites
end

--[[
    Save a sent invite (we sent to another player)
    @param recipientName string
    @param gameState table
]]
function WordGamePersistence:SaveSentInvite(recipientName, gameState)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    storage.sentInvites[recipientName] = {
        state = gameState,
        timestamp = time(),
    }

    HopeAddon:Debug("WordGamePersistence: saved sent invite to", recipientName)
end

--[[
    Get a sent invite
    @param recipientName string
    @return table|nil - { state, timestamp }
]]
function WordGamePersistence:GetSentInvite(recipientName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    return storage.sentInvites[recipientName]
end

--[[
    Clear a sent invite
    @param recipientName string
]]
function WordGamePersistence:ClearSentInvite(recipientName)
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    storage.sentInvites[recipientName] = nil
end

--[[
    Get all sent invites
    @return table
]]
function WordGamePersistence:GetAllSentInvites()
    self:EnsureStorage()

    return HopeAddon.charDb.savedGames.words.sentInvites
end

--============================================================
-- CLEANUP
--============================================================

--[[
    Clean up expired invites and inactive games
]]
function WordGamePersistence:CleanupExpired()
    self:EnsureStorage()

    local storage = HopeAddon.charDb.savedGames.words
    local now = time()
    local inviteTimeout = self.CONFIG.INVITE_TIMEOUT
    local inactivityForfeit = self.CONFIG.INACTIVITY_FORFEIT

    -- Clean expired pending invites
    for sender, invite in pairs(storage.pendingInvites) do
        if now - invite.timestamp > inviteTimeout then
            storage.pendingInvites[sender] = nil
            HopeAddon:Debug("WordGamePersistence: expired invite from", sender)
        end
    end

    -- Clean expired sent invites
    for recipient, invite in pairs(storage.sentInvites) do
        if now - invite.timestamp > inviteTimeout then
            storage.sentInvites[recipient] = nil
            HopeAddon:Debug("WordGamePersistence: expired invite to", recipient)
        end
    end

    -- Clean inactive games (30 day forfeit)
    for opponent, gameState in pairs(storage.games) do
        local lastMove = gameState.lastMoveAt or gameState.createdAt or 0
        if now - lastMove > inactivityForfeit then
            storage.games[opponent] = nil
            HopeAddon:Print("Words game vs " .. opponent .. " forfeited due to inactivity.")
        end
    end
end

--============================================================
-- UTILITY
--============================================================

--[[
    Generate a simple hash for board state validation
    @param board table - Sparse board data
    @return string - Hash string
]]
function WordGamePersistence:GenerateBoardHash(board)
    if not board then return "empty" end

    local hash = 0
    for row, cols in pairs(board) do
        for col, letter in pairs(cols) do
            -- Simple hash: row * 1000 + col * 10 + letter byte
            hash = hash + (tonumber(row) or 0) * 1000
            hash = hash + (tonumber(col) or 0) * 10
            hash = hash + (string.byte(letter) or 0)
        end
    end

    return string.format("%X", hash % 0xFFFFFF)
end

--[[
    Validate that two board states match
    @param board1 table - Sparse board
    @param board2 table - Sparse board
    @return boolean
]]
function WordGamePersistence:BoardsMatch(board1, board2)
    return self:GenerateBoardHash(board1) == self:GenerateBoardHash(board2)
end

--[[
    Get the player whose turn it is
    @param savedState table
    @return string - Player name
]]
function WordGamePersistence:GetCurrentPlayer(savedState)
    if not savedState then return nil end

    local turn = savedState.currentTurn or savedState.data and savedState.data.state and savedState.data.state.gameState

    if turn == "PLAYER1_TURN" then
        return savedState.player1
    elseif turn == "PLAYER2_TURN" then
        return savedState.player2
    end

    return nil
end

--[[
    Check if it's our turn in a saved game
    @param savedState table
    @return boolean
]]
function WordGamePersistence:IsMyTurn(savedState)
    local currentPlayer = self:GetCurrentPlayer(savedState)
    return currentPlayer == UnitName("player")
end

-- Register with addon
HopeAddon:RegisterModule("WordGamePersistence", WordGamePersistence)
HopeAddon.WordGamePersistence = WordGamePersistence

HopeAddon:Debug("WordGamePersistence module loaded")
