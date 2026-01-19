--[[
    HopeAddon Tetris Battle Game
    Side-by-side Tetris where cleared rows send garbage to opponent

    Controls:
    - Player 1: A/D to move, W to rotate, S for soft drop, Space for hard drop
    - Player 2: Left/Right arrows to move, Up to rotate, Down for soft drop, Enter for hard drop
]]

local TetrisGame = {}

--============================================================
-- CONSTANTS
--============================================================

TetrisGame.SETTINGS = {
    -- Timing (in seconds)
    INITIAL_DROP_INTERVAL = 1.0,    -- Time between automatic drops
    MIN_DROP_INTERVAL = 0.1,        -- Fastest drop speed
    SOFT_DROP_INTERVAL = 0.05,      -- Speed when holding down
    LOCK_DELAY = 0.5,               -- Time before piece locks after landing
    LINE_CLEAR_DELAY = 0.3,         -- Animation time for clearing lines
    MAX_LOCK_MOVES = 15,            -- Max moves/rotations before forced lock
    DAS_DELAY = 0.167,              -- Delayed Auto Shift initial delay (10 frames @ 60fps)
    ARR_INTERVAL = 0.033,           -- Auto Repeat Rate interval (2 frames @ 60fps)

    -- Scoring
    POINTS_SINGLE = 100,
    POINTS_DOUBLE = 300,
    POINTS_TRIPLE = 500,
    POINTS_TETRIS = 800,

    -- Garbage
    GARBAGE_SINGLE = 0,
    GARBAGE_DOUBLE = 1,
    GARBAGE_TRIPLE = 2,
    GARBAGE_TETRIS = 4,

    -- Level progression
    LINES_PER_LEVEL = 10,
    SPEED_MULTIPLIER = 0.85,        -- Drop interval *= this per level
}

--============================================================
-- MODULE STATE
--============================================================

TetrisGame.games = {}

--============================================================
-- LIFECYCLE
--============================================================

function TetrisGame:OnInitialize()
    HopeAddon:Debug("TetrisGame initializing...")
end

function TetrisGame:OnEnable()
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:RegisterGame(GameCore.GAME_TYPE.TETRIS, self)
    end

    -- Register network handlers for multiplayer
    self:RegisterNetworkHandlers()

    HopeAddon:Debug("TetrisGame enabled")
end

function TetrisGame:OnDisable()
    for gameId in pairs(self.games) do
        self:CleanupGame(gameId)
    end
end

function TetrisGame:RegisterNetworkHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Handle opponent moves (garbage received)
    GameComms:RegisterHandler("TETRIS", "MOVE", function(sender, gameId, data)
        self:OnOpponentMove(sender, gameId, data)
    end)

    -- Handle opponent state updates
    GameComms:RegisterHandler("TETRIS", "STATE", function(sender, gameId, data)
        self:OnOpponentState(sender, gameId, data)
    end)

    -- Handle opponent game over
    GameComms:RegisterHandler("TETRIS", "END", function(sender, gameId, data)
        self:OnOpponentGameOver(sender, gameId, data)
    end)

    HopeAddon:Debug("TetrisGame network handlers registered")
end

--============================================================
-- GAME LIFECYCLE (Called by GameCore)
--============================================================

function TetrisGame:OnCreate(gameId, game)
    local TetrisGrid = HopeAddon.TetrisGrid
    local TetrisBlocks = HopeAddon.TetrisBlocks
    local GameCore = HopeAddon:GetModule("GameCore")

    -- Determine how many boards to create based on mode
    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    game.data = {
        -- Board setup: LOCAL has 2 boards, REMOTE has 1 board (local player only)
        boards = {
            [1] = self:CreateBoard(1),
        },

        -- Game state
        paused = false,
        countdown = 3,
        gameOver = false,
        loser = nil,  -- Which player lost (1 or 2)
    }

    -- In LOCAL mode, create second board for player 2
    if not isRemote then
        game.data.boards[2] = self:CreateBoard(2)
    end

    self.games[gameId] = game
    HopeAddon:Debug("Tetris game created:", gameId, "mode:", game.mode)
end

function TetrisGame:CreateBoard(playerNum)
    local TetrisGrid = HopeAddon.TetrisGrid
    local TetrisBlocks = HopeAddon.TetrisBlocks
    local S = self.SETTINGS

    return {
        -- Grid
        grid = TetrisGrid:New(),

        -- Current piece
        currentPiece = nil,
        pieceRow = 0,
        pieceCol = 0,
        pieceRotation = 1,

        -- Last piece position (for dirty tracking)
        lastPieceRow = nil,
        lastPieceCol = nil,
        lastPieceRotation = nil,
        lastPieceType = nil,

        -- Next piece queue
        nextPieces = {},
        pieceBag = {},

        -- Timing
        dropTimer = 0,
        dropInterval = S.INITIAL_DROP_INTERVAL,
        lockTimer = 0,
        lockMoveCount = 0,          -- Count moves/rotations during lock
        isLocking = false,
        softDropping = false,
        softDropDistance = 0,       -- Track cells dropped for scoring

        -- Input state for DAS/ARR
        inputState = {
            left = { pressed = false, timer = 0, repeating = false },
            right = { pressed = false, timer = 0, repeating = false },
        },

        -- Stats
        level = 1,
        lines = 0,
        score = 0,

        -- Pending garbage
        pendingGarbage = 0,

        -- Player number (for input mapping)
        playerNum = playerNum,
    }
end

function TetrisGame:OnStart(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Initialize piece queues for all boards
    for playerNum, board in pairs(game.data.boards) do
        self:RefillBag(board)
        for i = 1, 3 do
            table.insert(board.nextPieces, self:GetNextFromBag(board))
        end
    end

    -- Show UI
    self:CreateUI(gameId)

    -- Start countdown
    game.data.countdown = 3
    self:StartCountdown(gameId)
end

function TetrisGame:OnUpdate(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    if game.data.paused or game.data.countdown > 0 or game.data.gameOver then
        return
    end

    -- Update all boards (1 for REMOTE, 2 for LOCAL)
    for playerNum, board in pairs(game.data.boards) do
        self:UpdateBoard(gameId, playerNum, dt)
    end

    -- Update UI
    self:UpdateUI(gameId)
end

function TetrisGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        local winner = game.data.loser == 1 and game.player2 or game.player1

        -- Build stats based on available boards
        local stats = {}
        if game.data.boards[1] then
            stats["Your Lines"] = game.data.boards[1].lines
            stats["Your Score"] = game.data.boards[1].score
        end
        if game.data.boards[2] then
            stats["P2 Lines"] = game.data.boards[2].lines
            stats["P2 Score"] = game.data.boards[2].score
        end

        GameUI:ShowGameOver(gameId, winner, stats)
    end

    -- Record stats for remote games
    if game.mode == GameCore.GAME_MODE.REMOTE and game.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames and Minigames.RecordGameResult then
            local playerName = UnitName("player")
            local result = (winner == playerName) and "win" or "lose"
            local myScore = game.data.boards[1] and game.data.boards[1].score or 0
            Minigames:RecordGameResult(game.opponent, "tetris", result, myScore)
        end
    end
end

function TetrisGame:OnDestroy(gameId)
    self:CleanupGame(gameId)
end

--============================================================
-- BOARD UPDATE
--============================================================

function TetrisGame:UpdateBoard(gameId, playerNum, dt)
    local game = self.games[gameId]
    if not game then return end

    local board = game.data.boards[playerNum]
    if not board then return end

    -- Spawn new piece if needed
    if not board.currentPiece then
        self:SpawnPiece(gameId, playerNum)
        return
    end

    -- Process DAS/ARR input
    self:UpdateDASInput(gameId, playerNum, dt)

    -- Handle locking
    if board.isLocking then
        board.lockTimer = board.lockTimer + dt
        if board.lockTimer >= self.SETTINGS.LOCK_DELAY then
            self:LockPiece(gameId, playerNum)
            return
        end
    end

    -- Automatic drop
    local dropInterval = board.softDropping and self.SETTINGS.SOFT_DROP_INTERVAL or board.dropInterval
    board.dropTimer = board.dropTimer + dt

    if board.dropTimer >= dropInterval then
        board.dropTimer = 0
        local moved = self:MovePiece(gameId, playerNum, 1, 0)  -- Move down

        -- Track soft drop for scoring
        if moved and board.softDropping then
            board.softDropDistance = board.softDropDistance + 1
        end
    end
end

function TetrisGame:UpdateDASInput(gameId, playerNum, dt)
    local game = self.games[gameId]
    if not game then return end

    local board = game.data.boards[playerNum]
    if not board or not board.currentPiece then return end

    local S = self.SETTINGS

    for direction, input in pairs(board.inputState) do
        if input.pressed then
            input.timer = input.timer + dt

            if not input.repeating then
                -- Wait for DAS delay
                if input.timer >= S.DAS_DELAY then
                    input.repeating = true
                    input.timer = 0
                end
            else
                -- ARR auto-repeat
                if input.timer >= S.ARR_INTERVAL then
                    local dCol = (direction == "left") and -1 or 1
                    self:MovePiece(gameId, playerNum, 0, dCol)
                    input.timer = 0
                end
            end
        end
    end
end

--============================================================
-- PIECE OPERATIONS
--============================================================

function TetrisGame:SpawnPiece(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    -- Get next piece
    local pieceType = table.remove(board.nextPieces, 1)
    table.insert(board.nextPieces, self:GetNextFromBag(board))

    -- Set current piece
    board.currentPiece = pieceType
    board.pieceRotation = 1

    -- Spawn position
    local spawnRow, spawnCol = TetrisBlocks:GetSpawnPosition(pieceType, board.grid.width)
    board.pieceRow = spawnRow
    board.pieceCol = spawnCol

    -- Check if spawn position is blocked (game over)
    local blocks = TetrisBlocks:GetBlocks(pieceType, 1)
    if not board.grid:CanPlace(blocks, spawnRow, spawnCol) then
        self:OnBoardGameOver(gameId, playerNum)
        return
    end

    -- Add any pending garbage before the new piece
    if board.pendingGarbage > 0 then
        local gameOver = board.grid:AddGarbageRows(board.pendingGarbage)
        board.pendingGarbage = 0
        if gameOver then
            self:OnBoardGameOver(gameId, playerNum)
            return
        end
    end

    -- Reset timers
    board.dropTimer = 0
    board.lockTimer = 0
    board.lockMoveCount = 0
    board.softDropDistance = 0
    board.isLocking = false
end

function TetrisGame:MovePiece(gameId, playerNum, dRow, dCol)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.currentPiece then return false end

    local newRow = board.pieceRow + dRow
    local newCol = board.pieceCol + dCol

    local blocks = TetrisBlocks:GetBlocks(board.currentPiece, board.pieceRotation)

    if board.grid:CanPlace(blocks, newRow, newCol) then
        board.pieceRow = newRow
        board.pieceCol = newCol

        -- Reset lock timer on successful move
        if board.isLocking then
            board.lockMoveCount = board.lockMoveCount + 1

            -- Force lock after MAX_LOCK_MOVES
            if board.lockMoveCount >= self.SETTINGS.MAX_LOCK_MOVES then
                self:LockPiece(gameId, playerNum)
                return true
            end

            board.lockTimer = 0
        end

        return true
    else
        -- Moving down failed - start locking
        if dRow > 0 then
            board.isLocking = true
        end
        return false
    end
end

function TetrisGame:RotatePiece(gameId, playerNum, direction)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.currentPiece then return false end

    local newRotation = ((board.pieceRotation - 1 + direction) % 4) + 1

    -- Try wall kicks
    local kicks = TetrisBlocks:GetWallKicks(board.currentPiece, board.pieceRotation, direction)
    local blocks = TetrisBlocks:GetBlocks(board.currentPiece, newRotation)

    for _, kick in ipairs(kicks) do
        local newRow = board.pieceRow + kick[1]
        local newCol = board.pieceCol + kick[2]

        if board.grid:CanPlace(blocks, newRow, newCol) then
            board.pieceRow = newRow
            board.pieceCol = newCol
            board.pieceRotation = newRotation

            -- Reset lock timer on successful rotation
            if board.isLocking then
                board.lockMoveCount = board.lockMoveCount + 1

                -- Force lock after MAX_LOCK_MOVES
                if board.lockMoveCount >= self.SETTINGS.MAX_LOCK_MOVES then
                    self:LockPiece(gameId, playerNum)
                    return true
                end

                board.lockTimer = 0
            end

            return true
        end
    end

    return false
end

function TetrisGame:HardDrop(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]

    if not board.currentPiece then return end

    -- Drop until collision
    local dropDistance = 0
    while self:MovePiece(gameId, playerNum, 1, 0) do
        dropDistance = dropDistance + 1
    end

    -- Lock immediately
    self:LockPiece(gameId, playerNum)

    -- Bonus points for hard drop
    board.score = board.score + dropDistance * 2
end

function TetrisGame:LockPiece(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.currentPiece then return end

    -- Place piece on grid
    local blocks = TetrisBlocks:GetBlocks(board.currentPiece, board.pieceRotation)
    local color = TetrisBlocks:GetColor(board.currentPiece)
    board.grid:PlaceBlocks(blocks, board.pieceRow, board.pieceCol, color)

    -- Award soft drop points
    if board.softDropDistance > 0 then
        board.score = board.score + board.softDropDistance
    end

    -- Clear current piece
    board.currentPiece = nil
    board.isLocking = false
    board.lockTimer = 0

    -- Check for line clears
    self:CheckLineClears(gameId, playerNum)

    -- Play lock sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--============================================================
-- LINE CLEAR & SCORING
--============================================================

function TetrisGame:CheckLineClears(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local S = self.SETTINGS

    local completeRows = board.grid:FindCompleteRows()
    if #completeRows == 0 then return end

    -- Clear the rows
    local clearedCount = board.grid:ClearRows(completeRows)

    -- Update stats
    board.lines = board.lines + clearedCount

    -- Calculate score
    local points = 0
    local garbage = 0

    if clearedCount == 1 then
        points = S.POINTS_SINGLE
        garbage = S.GARBAGE_SINGLE
    elseif clearedCount == 2 then
        points = S.POINTS_DOUBLE
        garbage = S.GARBAGE_DOUBLE
    elseif clearedCount == 3 then
        points = S.POINTS_TRIPLE
        garbage = S.GARBAGE_TRIPLE
    elseif clearedCount >= 4 then
        points = S.POINTS_TETRIS
        garbage = S.GARBAGE_TETRIS
    end

    board.score = board.score + points * board.level

    -- Send garbage to opponent
    local opponentNum = playerNum == 1 and 2 or 1
    if garbage > 0 then
        self:SendGarbage(gameId, opponentNum, garbage)
    end

    -- Level up check
    local newLevel = math.floor(board.lines / S.LINES_PER_LEVEL) + 1
    if newLevel > board.level then
        board.level = newLevel
        board.dropInterval = S.INITIAL_DROP_INTERVAL * math.pow(S.SPEED_MULTIPLIER, newLevel - 1)
        board.dropInterval = math.max(board.dropInterval, S.MIN_DROP_INTERVAL)
    end

    -- Play clear sound
    if HopeAddon.Sounds then
        if clearedCount >= 4 then
            HopeAddon.Sounds:PlayAchievement()
        else
            HopeAddon.Sounds:PlayClick()
        end
    end
end

function TetrisGame:SendGarbage(gameId, targetPlayer, amount)
    local game = self.games[gameId]
    local GameCore = HopeAddon:GetModule("GameCore")

    if game.mode == GameCore.GAME_MODE.LOCAL then
        -- Local mode: directly add to opponent's board
        local board = game.data.boards[targetPlayer]
        if board then
            board.pendingGarbage = board.pendingGarbage + amount
            HopeAddon:Debug("Sent", amount, "garbage to player", targetPlayer, "(local)")
        end
    else
        -- Remote mode: send message to opponent
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms and game.opponent then
            local data = "GARBAGE|" .. tostring(amount)
            GameComms:SendMove(game.opponent, "TETRIS", gameId, data)
            HopeAddon:Debug("Sent", amount, "garbage to", game.opponent, "(remote)")
        end
    end
end

--============================================================
-- NETWORK HANDLERS (Remote Multiplayer)
--============================================================

function TetrisGame:OnOpponentMove(sender, gameId, data)
    local game = self.games[gameId]
    if not game then
        HopeAddon:Debug("OnOpponentMove: Game not found:", gameId)
        return
    end

    -- Parse message: "GARBAGE|amount"
    local msgType, payload = strsplit("|", data)

    if msgType == "GARBAGE" then
        local amount = tonumber(payload) or 0
        -- Add to our board (always board 1 in REMOTE mode)
        local board = game.data.boards[1]
        if board then
            board.pendingGarbage = board.pendingGarbage + amount
            HopeAddon:Debug("Received", amount, "garbage from", sender)
        end
    end
end

function TetrisGame:OnOpponentState(sender, gameId, data)
    -- Reserved for future use (e.g., spectator mode, real-time board sync)
    HopeAddon:Debug("OnOpponentState from", sender, ":", data)
end

function TetrisGame:OnOpponentGameOver(sender, gameId, data)
    local game = self.games[gameId]
    if not game then
        HopeAddon:Debug("OnOpponentGameOver: Game not found:", gameId)
        return
    end

    -- Opponent lost, we win!
    game.data.gameOver = true
    game.data.loser = 2  -- Opponent is considered "player 2" in remote mode

    HopeAddon:Debug("Opponent", sender, "lost - we win!")

    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        -- We are the winner
        GameCore:SetWinner(gameId, UnitName("player"))
    end
end

--============================================================
-- GAME OVER
--============================================================

function TetrisGame:OnBoardGameOver(gameId, losingPlayer)
    local game = self.games[gameId]
    if not game then return end

    game.data.gameOver = true
    game.data.loser = losingPlayer

    local GameCore = HopeAddon:GetModule("GameCore")

    -- In REMOTE mode, notify opponent that we lost
    if game.mode == GameCore.GAME_MODE.REMOTE then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms and game.opponent then
            local score = game.data.boards[1] and game.data.boards[1].score or 0
            GameComms:SendEnd(game.opponent, "TETRIS", gameId, "LOSS|" .. tostring(score))
            HopeAddon:Debug("Sent game over notification to", game.opponent)
        end
    end

    local winner = losingPlayer == 1 and game.player2 or game.player1

    if GameCore then
        GameCore:SetWinner(gameId, winner)
    end
end

--============================================================
-- PIECE BAG
--============================================================

function TetrisGame:RefillBag(board)
    local TetrisBlocks = HopeAddon.TetrisBlocks
    board.pieceBag = TetrisBlocks:GenerateBag()
end

function TetrisGame:GetNextFromBag(board)
    if #board.pieceBag == 0 then
        self:RefillBag(board)
    end
    return table.remove(board.pieceBag, 1)
end

--============================================================
-- COUNTDOWN
--============================================================

function TetrisGame:StartCountdown(gameId)
    local game = self.games[gameId]
    if not game then return end

    game.data.countdown = 3

    -- Cancel existing countdown timer
    if game.data.countdownTimer then
        game.data.countdownTimer:Cancel()
    end

    local function tick()
        local currentGame = self.games[gameId]  -- Re-fetch each time
        if not currentGame then return end

        currentGame.data.countdown = currentGame.data.countdown - 1

        if currentGame.data.countdown > 0 then
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            currentGame.data.countdownTimer = HopeAddon.Timer:After(1, tick)
        else
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayAchievement()
            end
            currentGame.data.countdownTimer = nil
        end

        self:UpdateUI(gameId)
    end

    game.data.countdownTimer = HopeAddon.Timer:After(1, tick)
end

--============================================================
-- INPUT HANDLING
--============================================================

function TetrisGame:OnKeyDown(gameId, key)
    local game = self.games[gameId]
    if not game or game.data.paused or game.data.countdown > 0 or game.data.gameOver then
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    if isRemote then
        -- REMOTE MODE: All keys control board 1 (local player)
        -- Accept both WASD and arrow keys for convenience
        if key == "A" or key == "LEFT" then
            local input = game.data.boards[1].inputState.left
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, -1)  -- Immediate first move
            end
        elseif key == "D" or key == "RIGHT" then
            local input = game.data.boards[1].inputState.right
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, 1)  -- Immediate first move
            end
        elseif key == "W" or key == "UP" then
            self:RotatePiece(gameId, 1, 1)
        elseif key == "S" or key == "DOWN" then
            game.data.boards[1].softDropping = true
        elseif key == "SPACE" or key == "ENTER" then
            self:HardDrop(gameId, 1)
        end
    else
        -- LOCAL MODE: Separate controls for each player
        -- Player 1 controls (A/D/W/S/Space)
        if key == "A" then
            local input = game.data.boards[1].inputState.left
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, -1)  -- Immediate first move
            end
        elseif key == "D" then
            local input = game.data.boards[1].inputState.right
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, 1)  -- Immediate first move
            end
        elseif key == "W" then
            self:RotatePiece(gameId, 1, 1)
        elseif key == "S" then
            game.data.boards[1].softDropping = true
        elseif key == "SPACE" then
            self:HardDrop(gameId, 1)
        end

        -- Player 2 controls (Arrows/Enter)
        if key == "LEFT" then
            local input = game.data.boards[2].inputState.left
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 2, 0, -1)  -- Immediate first move
            end
        elseif key == "RIGHT" then
            local input = game.data.boards[2].inputState.right
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 2, 0, 1)  -- Immediate first move
            end
        elseif key == "UP" then
            self:RotatePiece(gameId, 2, 1)
        elseif key == "DOWN" then
            game.data.boards[2].softDropping = true
        elseif key == "ENTER" then
            self:HardDrop(gameId, 2)
        end
    end

    -- Pause (common to both modes)
    if key == "ESCAPE" then
        game.data.paused = not game.data.paused
    end

    self:UpdateUI(gameId)
end

function TetrisGame:OnKeyUp(gameId, key)
    local game = self.games[gameId]
    if not game then return end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    if isRemote then
        -- REMOTE MODE: Release keys for board 1 only
        if key == "A" or key == "LEFT" then
            game.data.boards[1].inputState.left.pressed = false
        elseif key == "D" or key == "RIGHT" then
            game.data.boards[1].inputState.right.pressed = false
        elseif key == "S" or key == "DOWN" then
            game.data.boards[1].softDropping = false
        end
    else
        -- LOCAL MODE: Release keys for respective players
        -- Player 1
        if key == "A" then
            game.data.boards[1].inputState.left.pressed = false
        elseif key == "D" then
            game.data.boards[1].inputState.right.pressed = false
        elseif key == "S" then
            game.data.boards[1].softDropping = false
        end

        -- Player 2
        if key == "LEFT" then
            game.data.boards[2].inputState.left.pressed = false
        elseif key == "RIGHT" then
            game.data.boards[2].inputState.right.pressed = false
        elseif key == "DOWN" then
            game.data.boards[2].softDropping = false
        end
    end
end

--============================================================
-- UI
--============================================================

function TetrisGame:CreateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    local GameCore = HopeAddon:GetModule("GameCore")
    local TetrisGrid = HopeAddon.TetrisGrid

    -- Determine if this is remote mode
    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    -- Create window
    local window = GameUI:CreateGameWindow(gameId, "Tetris Battle", isRemote and "TETRIS_REMOTE" or "TETRIS")
    if not window then return end

    game.data.window = window  -- Store reference for cleanup
    local content = window.content

    -- Cell size based on grid dimensions
    local cellSize = 18
    local gridWidth = TetrisGrid.WIDTH * cellSize
    local gridHeight = TetrisGrid.HEIGHT * cellSize

    if isRemote then
        -- REMOTE MODE: Single board (center)
        local boardContainer = CreateFrame("Frame", nil, content)
        boardContainer:SetSize(gridWidth + 100, gridHeight + 60)
        boardContainer:SetPoint("CENTER", 0, 0)

        self:CreateBoardUI(boardContainer, gameId, 1, cellSize, true)
        game.data.boards[1].container = boardContainer

        -- Opponent name label
        local opponentLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        opponentLabel:SetPoint("TOP", boardContainer, "BOTTOM", 0, -10)
        opponentLabel:SetText("VS: " .. (game.opponent or "Unknown"))
        opponentLabel:SetTextColor(1, 0.84, 0)

        -- Controls hint
        local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        controlsText:SetPoint("BOTTOM", 0, 5)
        controlsText:SetText("A/D to move | W to rotate | S to soft drop | Space to hard drop")
        controlsText:SetTextColor(0.5, 0.5, 0.5)
    else
        -- LOCAL MODE: Two boards side-by-side
        -- Board 1 (left)
        local board1Container = CreateFrame("Frame", nil, content)
        board1Container:SetSize(gridWidth + 100, gridHeight + 60)
        board1Container:SetPoint("LEFT", 20, 0)

        self:CreateBoardUI(board1Container, gameId, 1, cellSize, false)
        game.data.boards[1].container = board1Container

        -- Board 2 (right)
        local board2Container = CreateFrame("Frame", nil, content)
        board2Container:SetSize(gridWidth + 100, gridHeight + 60)
        board2Container:SetPoint("RIGHT", -20, 0)

        self:CreateBoardUI(board2Container, gameId, 2, cellSize, false)
        game.data.boards[2].container = board2Container

        -- VS text
        local vsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        vsText:SetPoint("CENTER", 0, 0)
        vsText:SetText("VS")
        vsText:SetTextColor(1, 0.84, 0)

        -- Controls hint
        local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        controlsText:SetPoint("BOTTOM", 0, 5)
        controlsText:SetText("P1: A/D/W/S/Space | P2: Arrows/Enter")
        controlsText:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Countdown overlay (common to both modes)
    local countdownText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    countdownText:SetPoint("CENTER", 0, 50)
    countdownText:SetText("3")
    countdownText:SetTextColor(1, 0.84, 0)
    game.data.countdownText = countdownText

    -- Keyboard handling
    window:SetScript("OnKeyDown", function(_, key)
        self:OnKeyDown(gameId, key)
    end)
    window:SetScript("OnKeyUp", function(_, key)
        self:OnKeyUp(gameId, key)
    end)
    window:EnableKeyboard(true)
    window:SetPropagateKeyboardInput(false)

    window:Show()
    self:UpdateUI(gameId)
end

function TetrisGame:CreateBoardUI(container, gameId, playerNum, cellSize, isRemote)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisGrid = HopeAddon.TetrisGrid
    local GameUI = HopeAddon:GetModule("GameUI")

    local gridWidth = TetrisGrid.WIDTH * cellSize
    local gridHeight = TetrisGrid.HEIGHT * cellSize

    -- Player label
    local playerLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerLabel:SetPoint("TOP", 0, -5)
    if isRemote then
        playerLabel:SetText("You")
        playerLabel:SetTextColor(0.2, 0.8, 0.2)  -- Green for player
    else
        playerLabel:SetText(playerNum == 1 and "Player 1" or "Player 2")
        playerLabel:SetTextColor(playerNum == 1 and 0.2 or 0.8, playerNum == 1 and 0.8 or 0.2, 0.2)
    end

    -- Grid frame
    local gridFrame = GameUI:CreatePlayArea(container, gridWidth, gridHeight)
    gridFrame:SetPoint("TOP", playerLabel, "BOTTOM", 0, -10)
    board.gridFrame = gridFrame

    -- Create cell textures
    board.cellTextures = {}
    for row = 1, TetrisGrid.HEIGHT do
        board.cellTextures[row] = {}
        for col = 1, TetrisGrid.WIDTH do
            local cell = gridFrame:CreateTexture(nil, "ARTWORK")
            cell:SetSize(cellSize - 1, cellSize - 1)
            cell:SetPoint("BOTTOMLEFT", gridFrame, "BOTTOMLEFT",
                (col - 1) * cellSize + 1,
                (TetrisGrid.HEIGHT - row) * cellSize + 1)
            cell:SetColorTexture(0.1, 0.1, 0.1, 1)
            board.cellTextures[row][col] = cell
        end
    end

    -- Score/Level display
    local scoreLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scoreLabel:SetPoint("TOPLEFT", gridFrame, "BOTTOMLEFT", 0, -5)
    scoreLabel:SetText("Score: 0")
    scoreLabel:SetTextColor(0.8, 0.8, 0.8)
    board.scoreLabel = scoreLabel

    local levelLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("TOPRIGHT", gridFrame, "BOTTOMRIGHT", 0, -5)
    levelLabel:SetText("Lvl: 1")
    levelLabel:SetTextColor(0.8, 0.8, 0.8)
    board.levelLabel = levelLabel

    local linesLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    linesLabel:SetPoint("TOP", gridFrame, "BOTTOM", 0, -5)
    linesLabel:SetText("Lines: 0")
    linesLabel:SetTextColor(0.8, 0.8, 0.8)
    board.linesLabel = linesLabel
end

function TetrisGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Update countdown
    if game.data.countdownText then
        if game.data.countdown > 0 then
            game.data.countdownText:SetText(tostring(game.data.countdown))
            game.data.countdownText:Show()
        else
            game.data.countdownText:Hide()
        end
    end

    -- Update all boards (1 for REMOTE, 2 for LOCAL)
    for playerNum, board in pairs(game.data.boards) do
        self:UpdateBoardUI(gameId, playerNum)
    end
end

function TetrisGame:UpdateBoardUI(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.boards[playerNum]
    local TetrisGrid = HopeAddon.TetrisGrid
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.cellTextures then return end

    -- Mark old piece position as dirty (cells that need to be cleared)
    if board.lastPieceType and board.lastPieceRow then
        local oldBlocks = TetrisBlocks:GetBlocks(board.lastPieceType, board.lastPieceRotation)
        for _, block in ipairs(oldBlocks) do
            local row = board.lastPieceRow + block[1]
            local col = board.lastPieceCol + block[2]
            if row >= 1 and row <= TetrisGrid.HEIGHT and col >= 1 and col <= TetrisGrid.WIDTH then
                board.grid:MarkDirty(row, col)
            end
        end
    end

    -- Mark new piece position as dirty (cells that need to be drawn)
    if board.currentPiece then
        local blocks = TetrisBlocks:GetBlocks(board.currentPiece, board.pieceRotation)
        for _, block in ipairs(blocks) do
            local row = board.pieceRow + block[1]
            local col = board.pieceCol + block[2]
            if row >= 1 and row <= TetrisGrid.HEIGHT and col >= 1 and col <= TetrisGrid.WIDTH then
                board.grid:MarkDirty(row, col)
            end
        end

        -- Store current position as "last" for next frame
        board.lastPieceRow = board.pieceRow
        board.lastPieceCol = board.pieceCol
        board.lastPieceRotation = board.pieceRotation
        board.lastPieceType = board.currentPiece
    else
        -- No current piece, clear last piece tracking
        board.lastPieceRow = nil
        board.lastPieceCol = nil
        board.lastPieceRotation = nil
        board.lastPieceType = nil
    end

    -- Redraw only dirty cells from the grid
    local dirtyCells = board.grid:GetDirtyCells()
    for row, cols in pairs(dirtyCells) do
        for col, _ in pairs(cols) do
            local color = board.grid:GetCell(row, col)
            if color then
                board.cellTextures[row][col]:SetColorTexture(color.r, color.g, color.b, 1)
            else
                board.cellTextures[row][col]:SetColorTexture(0.1, 0.1, 0.1, 1)
            end
        end
    end

    -- Draw current piece on top (always fresh, not from grid)
    if board.currentPiece then
        local blocks = TetrisBlocks:GetBlocks(board.currentPiece, board.pieceRotation)
        local color = TetrisBlocks:GetColor(board.currentPiece)

        for _, block in ipairs(blocks) do
            local row = board.pieceRow + block[1]
            local col = board.pieceCol + block[2]

            if row >= 1 and row <= TetrisGrid.HEIGHT and col >= 1 and col <= TetrisGrid.WIDTH then
                board.cellTextures[row][col]:SetColorTexture(color.r, color.g, color.b, 1)
            end
        end
    end

    -- Clear dirty flags
    board.grid:ClearDirtyCells()

    -- Update stats (only if changed to reduce string allocations)
    if board.scoreLabel then
        local scoreText = "Score: " .. board.score
        if board.scoreLabel:GetText() ~= scoreText then
            board.scoreLabel:SetText(scoreText)
        end
    end
    if board.levelLabel then
        local levelText = "Lvl: " .. board.level
        if board.levelLabel:GetText() ~= levelText then
            board.levelLabel:SetText(levelText)
        end
    end
    if board.linesLabel then
        local linesText = "Lines: " .. board.lines
        if board.linesLabel:GetText() ~= linesText then
            board.linesLabel:SetText(linesText)
        end
    end
end

--============================================================
-- CLEANUP
--============================================================

function TetrisGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game then
        self.games[gameId] = nil
        return
    end

    -- Cancel countdown timer
    if game.data and game.data.countdownTimer then
        game.data.countdownTimer:Cancel()
        game.data.countdownTimer = nil
    end

    -- Destroy cell textures and clear input state for all boards
    if game.data and game.data.boards then
        for playerNum, board in pairs(game.data.boards) do
            -- Clear input state
            board.softDropping = false

            -- Destroy cell textures
            if board.cellTextures then
                for row = 1, #board.cellTextures do
                    for col = 1, #board.cellTextures[row] do
                        local texture = board.cellTextures[row][col]
                        if texture then
                            texture:Hide()
                            texture:SetParent(nil)
                        end
                    end
                end
                board.cellTextures = nil
            end

            -- Release frame references
            if board.container then
                board.container:Hide()
                board.container:SetParent(nil)
                board.container = nil
            end
            if board.gridFrame then
                board.gridFrame:Hide()
                board.gridFrame:SetParent(nil)
                board.gridFrame = nil
            end

            -- Clear grid
            if board.grid then
                board.grid:Clear()
                board.grid = nil
            end
        end
    end

    -- Hide window
    if game.data and game.data.window then
        game.data.window:Hide()
        game.data.window = nil
    end

    -- GameUI handles window destruction
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        GameUI:DestroyGameWindow(gameId)
    end

    -- Clear game data
    self.games[gameId] = nil
end

--============================================================
-- PUBLIC API
--============================================================

function TetrisGame:StartGame()
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return nil end

    local gameId = GameCore:CreateGame(GameCore.GAME_TYPE.TETRIS, GameCore.GAME_MODE.LOCAL, nil)

    local game = GameCore:GetGame(gameId)
    if game then
        game.player1 = "Player 1"
        game.player2 = "Player 2"
    end

    GameCore:StartGame(gameId)

    return gameId
end

-- Register with addon
HopeAddon:RegisterModule("TetrisGame", TetrisGame)
HopeAddon.TetrisGame = TetrisGame

HopeAddon:Debug("TetrisGame module loaded")
