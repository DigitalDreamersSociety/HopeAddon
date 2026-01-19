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
    ENTRY_DELAY = 0.1,              -- Auto Repeat Enable (ARE) spawn delay

    -- Scoring
    POINTS_SINGLE = 100,
    POINTS_DOUBLE = 300,
    POINTS_TRIPLE = 500,
    POINTS_TETRIS = 800,
    POINTS_TSPIN_SINGLE = 800,
    POINTS_TSPIN_DOUBLE = 1200,
    POINTS_TSPIN_TRIPLE = 1600,
    POINTS_MINI_TSPIN = 100,

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
        ui = {
            window = nil,
            countdownText = nil,
            boards = {
                [1] = {
                    container = nil,
                    gridFrame = nil,
                    cellTextures = nil,
                    scoreLabel = nil,
                    levelLabel = nil,
                    linesLabel = nil,
                },
            },
        },
        state = {
            -- Board setup: LOCAL has 2 boards, REMOTE has 1 board (local player only)
            boards = {
                [1] = self:CreateBoard(1),
            },
            -- Game state
            paused = false,
            countdown = 3,
            gameOver = false,
            loser = nil,  -- Which player lost (1 or 2)
            countdownTimer = nil,
        },
    }

    -- In LOCAL mode, create second board for player 2
    if not isRemote then
        game.data.state.boards[2] = self:CreateBoard(2)
        game.data.ui.boards[2] = {
            container = nil,
            gridFrame = nil,
            cellTextures = nil,
            scoreLabel = nil,
            levelLabel = nil,
            linesLabel = nil,
        }
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
        entryDelayTimer = 0,        -- Timer for spawn delay
        waitingForEntry = false,    -- Flag for entry delay state

        -- Input state for DAS/ARR
        inputState = {
            left = { pressed = false, timer = 0, repeating = false },
            right = { pressed = false, timer = 0, repeating = false },
        },

        -- Stats
        level = 1,
        lines = 0,
        score = 0,

        -- Garbage system
        incomingGarbage = 0,        -- Garbage received from opponent
        outgoingGarbage = 0,        -- Garbage to send to opponent

        -- T-Spin detection
        lastActionWasRotation = false,
        lastRotationKicked = false,

        -- Combo system
        backToBack = false,         -- Is back-to-back active?
        comboCount = 0,             -- Consecutive line clears

        -- Player number (for input mapping)
        playerNum = playerNum,
    }
end

function TetrisGame:OnStart(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Initialize piece queues for all boards
    for playerNum, board in pairs(state.boards) do
        self:RefillBag(board)
        for i = 1, 3 do
            table.insert(board.nextPieces, self:GetNextFromBag(board))
        end
    end

    -- Show UI
    self:CreateUI(gameId)

    -- Start countdown
    state.countdown = 3
    self:StartCountdown(gameId)
end

function TetrisGame:OnUpdate(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    if state.paused or state.countdown > 0 or state.gameOver then
        return
    end

    -- Update all boards (1 for REMOTE, 2 for LOCAL)
    for playerNum, board in pairs(state.boards) do
        self:UpdateBoard(gameId, playerNum, dt)
    end

    -- Update UI
    self:UpdateUI(gameId)
end

function TetrisGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local GameUI = HopeAddon:GetModule("GameUI")
    local GameCore = HopeAddon:GetModule("GameCore")

    if GameUI then
        local winner = state.loser == 1 and game.player2 or game.player1

        -- Build stats based on available boards
        local stats = {}
        if state.boards[1] then
            stats["Your Lines"] = state.boards[1].lines
            stats["Your Score"] = state.boards[1].score
        end
        if state.boards[2] then
            stats["P2 Lines"] = state.boards[2].lines
            stats["P2 Score"] = state.boards[2].score
        end

        GameUI:ShowGameOver(gameId, winner, stats)
    end

    -- Record stats for remote games
    if game.mode == GameCore.GAME_MODE.REMOTE and game.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames and Minigames.RecordGameResult then
            local playerName = UnitName("player")
            local winner = state.loser == 1 and game.player2 or game.player1
            local result = (winner == playerName) and "win" or "lose"
            local myScore = state.boards[1] and state.boards[1].score or 0
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

    local board = game.data.state.boards[playerNum]
    if not board then return end

    -- Handle entry delay (ARE)
    if board.waitingForEntry then
        board.entryDelayTimer = board.entryDelayTimer + dt
        if board.entryDelayTimer >= self.SETTINGS.ENTRY_DELAY then
            board.waitingForEntry = false
            board.entryDelayTimer = 0
        else
            return  -- Don't spawn yet
        end
    end

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

    local board = game.data.state.boards[playerNum]
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
    local board = game.data.state.boards[playerNum]
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

    -- Process garbage canceling before spawning
    local garbageToApply = self:ProcessGarbage(gameId, playerNum)
    if garbageToApply > 0 then
        local gameOver = board.grid:AddGarbageRows(garbageToApply)
        board.incomingGarbage = 0
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
    local board = game.data.state.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.currentPiece then return false end

    local newRow = board.pieceRow + dRow
    local newCol = board.pieceCol + dCol

    local blocks = TetrisBlocks:GetBlocks(board.currentPiece, board.pieceRotation)

    if board.grid:CanPlace(blocks, newRow, newCol) then
        board.pieceRow = newRow
        board.pieceCol = newCol

        -- Clear rotation flag (moving cancels T-Spin)
        board.lastActionWasRotation = false

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
    local board = game.data.state.boards[playerNum]
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

            -- Track rotation for T-Spin detection
            board.lastActionWasRotation = true
            board.lastRotationKicked = (kick[1] ~= 0 or kick[2] ~= 0)  -- True if not first kick (0,0)

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
    local board = game.data.state.boards[playerNum]

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

function TetrisGame:DetectTSpin(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.state.boards[playerNum]
    local TetrisGrid = HopeAddon.TetrisGrid

    -- Must be T-piece
    if board.currentPiece ~= "T" then return false, false end

    -- Must have rotated (not just moved)
    if not board.lastActionWasRotation then return false, false end

    -- Check 3-corner rule: Check all 4 corners of the 3x3 bounding box
    local corners = {
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1}  -- TL, TR, BL, BR
    }
    local filledCorners = 0
    local frontCorners = 0  -- Corners facing the T's direction

    -- Determine front corners based on rotation (where T's point faces)
    local frontCornerIndices = {}
    if board.pieceRotation == 1 then  -- Pointing up
        frontCornerIndices = {1, 2}  -- Top-left, Top-right
    elseif board.pieceRotation == 2 then  -- Pointing right
        frontCornerIndices = {2, 4}  -- Top-right, Bottom-right
    elseif board.pieceRotation == 3 then  -- Pointing down
        frontCornerIndices = {3, 4}  -- Bottom-left, Bottom-right
    else  -- Pointing left
        frontCornerIndices = {1, 3}  -- Top-left, Bottom-left
    end

    for i, corner in ipairs(corners) do
        local row = board.pieceRow + corner[1]
        local col = board.pieceCol + corner[2]

        -- Check if corner is filled (out of bounds counts as filled)
        local isFilled = false
        if row < 1 or row > TetrisGrid.HEIGHT or col < 1 or col > TetrisGrid.WIDTH then
            isFilled = true
        elseif not board.grid:IsEmpty(row, col) then
            isFilled = true
        end

        if isFilled then
            filledCorners = filledCorners + 1
            -- Check if this is a front corner
            for _, frontIdx in ipairs(frontCornerIndices) do
                if i == frontIdx then
                    frontCorners = frontCorners + 1
                    break
                end
            end
        end
    end

    -- T-spin: 3+ corners filled
    -- Mini T-spin: 2 corners filled, but neither front corners OR no rotation kick
    local isTSpin = filledCorners >= 3
    local isMini = filledCorners == 2 and (frontCorners == 0 or not board.lastRotationKicked)

    return isTSpin, isMini
end

function TetrisGame:LockPiece(gameId, playerNum)
    local game = self.games[gameId]
    local board = game.data.state.boards[playerNum]
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not board.currentPiece then return end

    -- Detect T-Spin before placing piece
    local isTSpin, isMini = self:DetectTSpin(gameId, playerNum)

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
    board.waitingForEntry = true
    board.entryDelayTimer = 0

    -- Check for line clears (pass T-Spin info)
    local clearedLines = #board.grid:FindCompleteRows()
    if clearedLines == 0 and not (isMini and clearedLines == 0) then
        -- Reset combo if no lines cleared and not a mini T-Spin
        board.comboCount = 0
    end

    self:CheckLineClears(gameId, playerNum, isTSpin, isMini)

    -- Play lock sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--============================================================
-- GARBAGE SYSTEM
--============================================================

function TetrisGame:ProcessGarbage(gameId, playerNum)
    local game = self.games[gameId]
    if not game then return 0 end

    local board = game.data.state.boards[playerNum]
    if not board then return 0 end

    -- Cancel incoming with outgoing
    local canceled = math.min(board.incomingGarbage, board.outgoingGarbage)
    board.incomingGarbage = board.incomingGarbage - canceled
    board.outgoingGarbage = board.outgoingGarbage - canceled

    -- Send remaining outgoing
    if board.outgoingGarbage > 0 then
        local opponentNum = playerNum == 1 and 2 or 1
        self:SendGarbage(gameId, opponentNum, board.outgoingGarbage)
        board.outgoingGarbage = 0
    end

    -- Return remaining incoming to be applied
    return board.incomingGarbage
end

--============================================================
-- LINE CLEAR & SCORING
--============================================================

function TetrisGame:CheckLineClears(gameId, playerNum, isTSpin, isMini)
    local game = self.games[gameId]
    local board = game.data.state.boards[playerNum]
    local S = self.SETTINGS

    local completeRows = board.grid:FindCompleteRows()
    local clearedCount = #completeRows

    -- Handle T-Spin without line clear (Mini T-Spin)
    if isMini and clearedCount == 0 then
        board.score = board.score + S.POINTS_MINI_TSPIN * board.level
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayClick()
        end
        return
    end

    if clearedCount == 0 then return end

    -- Clear the rows
    clearedCount = board.grid:ClearRows(completeRows)

    -- Update stats
    board.lines = board.lines + clearedCount

    -- Calculate score and garbage
    local points = 0
    local garbage = 0

    if isTSpin then
        -- T-Spin scoring
        if clearedCount == 1 then
            points = S.POINTS_TSPIN_SINGLE
            garbage = S.GARBAGE_DOUBLE + 2  -- Bonus garbage
        elseif clearedCount == 2 then
            points = S.POINTS_TSPIN_DOUBLE
            garbage = S.GARBAGE_TETRIS + 2  -- Bonus garbage
        elseif clearedCount >= 3 then
            points = S.POINTS_TSPIN_TRIPLE
            garbage = S.GARBAGE_TETRIS + 3  -- Bonus garbage
        end
    elseif isMini then
        -- Mini T-Spin with line clear
        points = S.POINTS_MINI_TSPIN * clearedCount
        garbage = S.GARBAGE_SINGLE
    else
        -- Normal scoring
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
    end

    -- Determine if this is a "difficult" clear (Tetris or T-Spin)
    local isDifficult = (clearedCount >= 4) or isTSpin

    -- Back-to-back bonus (50% more points)
    if board.backToBack and isDifficult then
        points = math.floor(points * 1.5)
        HopeAddon:Print("Back-to-Back!")
    end

    -- Update back-to-back state
    if isDifficult then
        board.backToBack = true
    elseif clearedCount > 0 then
        board.backToBack = false
    end

    -- Combo system (rewards consecutive line clears)
    if clearedCount > 0 then
        board.comboCount = board.comboCount + 1
        if board.comboCount > 1 then
            local comboBonus = (board.comboCount - 1) * 50 * board.level
            points = points + comboBonus
            HopeAddon:Debug("Combo", board.comboCount, "- Bonus:", comboBonus)
        end
    else
        board.comboCount = 0
    end

    board.score = board.score + points * board.level

    -- Queue garbage (will be sent after canceling in ProcessGarbage)
    if garbage > 0 then
        board.outgoingGarbage = board.outgoingGarbage + garbage
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
        local board = game.data.state.boards[targetPlayer]
        if board then
            board.incomingGarbage = board.incomingGarbage + amount
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
        local board = game.data.state.boards[1]
        if board then
            board.incomingGarbage = board.incomingGarbage + amount
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

    local state = game.data.state

    -- Opponent lost, we win!
    state.gameOver = true
    state.loser = 2  -- Opponent is considered "player 2" in remote mode

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

    local state = game.data.state

    state.gameOver = true
    state.loser = losingPlayer

    local GameCore = HopeAddon:GetModule("GameCore")

    -- In REMOTE mode, notify opponent that we lost
    if game.mode == GameCore.GAME_MODE.REMOTE then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms and game.opponent then
            local score = state.boards[1] and state.boards[1].score or 0
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

    local state = game.data.state

    state.countdown = 3

    -- Cancel existing countdown timer
    if state.countdownTimer then
        state.countdownTimer:Cancel()
    end

    local function tick()
        local currentGame = self.games[gameId]  -- Re-fetch each time
        if not currentGame then return end

        local currentState = currentGame.data.state
        currentState.countdown = currentState.countdown - 1

        if currentState.countdown > 0 then
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            currentState.countdownTimer = HopeAddon.Timer:After(1, tick)
        else
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayAchievement()
            end
            currentState.countdownTimer = nil
        end

        self:UpdateUI(gameId)
    end

    state.countdownTimer = HopeAddon.Timer:After(1, tick)
end

--============================================================
-- INPUT HANDLING
--============================================================

function TetrisGame:OnKeyDown(gameId, key)
    local game = self.games[gameId]
    local state = game.data.state
    if not game or state.paused or state.countdown > 0 or state.gameOver then
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    if isRemote then
        -- REMOTE MODE: All keys control board 1 (local player)
        -- Accept both WASD and arrow keys for convenience
        if key == "A" or key == "LEFT" then
            local input = state.boards[1].inputState.left
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, -1)  -- Immediate first move
            end
        elseif key == "D" or key == "RIGHT" then
            local input = state.boards[1].inputState.right
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, 1)  -- Immediate first move
            end
        elseif key == "W" or key == "UP" then
            self:RotatePiece(gameId, 1, 1)  -- Clockwise
        elseif key == "Q" then
            self:RotatePiece(gameId, 1, -1)  -- Counter-clockwise
        elseif key == "S" or key == "DOWN" then
            state.boards[1].softDropping = true
        elseif key == "SPACE" or key == "ENTER" then
            self:HardDrop(gameId, 1)
        end
    else
        -- LOCAL MODE: Separate controls for each player
        -- Player 1 controls (A/D/W/S/Space)
        if key == "A" then
            local input = state.boards[1].inputState.left
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, -1)  -- Immediate first move
            end
        elseif key == "D" then
            local input = state.boards[1].inputState.right
            if not input.pressed then
                input.pressed = true
                input.timer = 0
                input.repeating = false
                self:MovePiece(gameId, 1, 0, 1)  -- Immediate first move
            end
        elseif key == "W" then
            self:RotatePiece(gameId, 1, 1)  -- Clockwise
        elseif key == "Q" then
            self:RotatePiece(gameId, 1, -1)  -- Counter-clockwise
        elseif key == "S" then
            state.boards[1].softDropping = true
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
            self:RotatePiece(gameId, 2, 1)  -- Clockwise
        elseif key == "RSHIFT" or key == "LSHIFT" then
            self:RotatePiece(gameId, 2, -1)  -- Counter-clockwise
        elseif key == "DOWN" then
            state.boards[2].softDropping = true
        elseif key == "ENTER" then
            self:HardDrop(gameId, 2)
        end
    end

    -- Pause (common to both modes)
    if key == "ESCAPE" then
        state.paused = not state.paused
    end

    self:UpdateUI(gameId)
end

function TetrisGame:OnKeyUp(gameId, key)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
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
            state.boards[1].softDropping = false
        end
    else
        -- LOCAL MODE: Release keys for respective players
        -- Player 1
        if key == "A" then
            game.data.boards[1].inputState.left.pressed = false
        elseif key == "D" then
            game.data.boards[1].inputState.right.pressed = false
        elseif key == "S" then
            state.boards[1].softDropping = false
        end

        -- Player 2
        if key == "LEFT" then
            state.boards[2].inputState.left.pressed = false
        elseif key == "RIGHT" then
            state.boards[2].inputState.right.pressed = false
        elseif key == "DOWN" then
            state.boards[2].softDropping = false
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

    local ui = game.data.ui

    -- Determine if this is remote mode
    local isRemote = (game.mode == GameCore.GAME_MODE.REMOTE)

    -- Create window
    local window = GameUI:CreateGameWindow(gameId, "Tetris Battle", isRemote and "TETRIS_REMOTE" or "TETRIS")
    if not window then return end

    ui.window = window  -- Store reference for cleanup
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
        ui.boards[1].container = boardContainer

        -- Opponent name label
        local opponentLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        opponentLabel:SetPoint("TOP", boardContainer, "BOTTOM", 0, -10)
        opponentLabel:SetText("VS: " .. (game.opponent or "Unknown"))
        opponentLabel:SetTextColor(1, 0.84, 0)

        -- Controls hint
        local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        controlsText:SetPoint("BOTTOM", 0, 5)
        controlsText:SetText("A/D to move | W/Q to rotate CW/CCW | S to soft drop | Space to hard drop")
        controlsText:SetTextColor(0.5, 0.5, 0.5)
    else
        -- LOCAL MODE: Two boards side-by-side
        -- Board 1 (left)
        local board1Container = CreateFrame("Frame", nil, content)
        board1Container:SetSize(gridWidth + 100, gridHeight + 60)
        board1Container:SetPoint("LEFT", 20, 0)

        self:CreateBoardUI(board1Container, gameId, 1, cellSize, false)
        ui.boards[1].container = board1Container

        -- Board 2 (right)
        local board2Container = CreateFrame("Frame", nil, content)
        board2Container:SetSize(gridWidth + 100, gridHeight + 60)
        board2Container:SetPoint("RIGHT", -20, 0)

        self:CreateBoardUI(board2Container, gameId, 2, cellSize, false)
        ui.boards[2].container = board2Container

        -- VS text
        local vsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        vsText:SetPoint("CENTER", 0, 0)
        vsText:SetText("VS")
        vsText:SetTextColor(1, 0.84, 0)

        -- Controls hint
        local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        controlsText:SetPoint("BOTTOM", 0, 5)
        controlsText:SetText("P1: A/D/W/Q/S/Space | P2: Arrows/Up/Shift/Down/Enter")
        controlsText:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Countdown overlay (common to both modes)
    local countdownText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    countdownText:SetPoint("CENTER", 0, 50)
    countdownText:SetText("3")
    countdownText:SetTextColor(1, 0.84, 0)
    ui.countdownText = countdownText

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
    local ui = game.data.ui.boards[playerNum]
    local board = game.data.state.boards[playerNum]
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
    ui.gridFrame = gridFrame

    -- Create cell textures
    ui.cellTextures = {}
    for row = 1, TetrisGrid.HEIGHT do
        ui.cellTextures[row] = {}
        for col = 1, TetrisGrid.WIDTH do
            local cell = gridFrame:CreateTexture(nil, "ARTWORK")
            cell:SetSize(cellSize - 1, cellSize - 1)
            cell:SetPoint("BOTTOMLEFT", gridFrame, "BOTTOMLEFT",
                (col - 1) * cellSize + 1,
                (TetrisGrid.HEIGHT - row) * cellSize + 1)
            cell:SetColorTexture(0.1, 0.1, 0.1, 1)
            ui.cellTextures[row][col] = cell
        end
    end

    -- Score/Level display
    local scoreLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scoreLabel:SetPoint("TOPLEFT", gridFrame, "BOTTOMLEFT", 0, -5)
    scoreLabel:SetText("Score: 0")
    scoreLabel:SetTextColor(0.8, 0.8, 0.8)
    ui.scoreLabel = scoreLabel

    local levelLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("TOPRIGHT", gridFrame, "BOTTOMRIGHT", 0, -5)
    levelLabel:SetText("Lvl: 1")
    levelLabel:SetTextColor(0.8, 0.8, 0.8)
    ui.levelLabel = levelLabel

    local linesLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    linesLabel:SetPoint("TOP", gridFrame, "BOTTOM", 0, -5)
    linesLabel:SetText("Lines: 0")
    linesLabel:SetTextColor(0.8, 0.8, 0.8)
    ui.linesLabel = linesLabel
end

function TetrisGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Update countdown
    if ui.countdownText then
        if state.countdown > 0 then
            ui.countdownText:SetText(tostring(state.countdown))
            ui.countdownText:Show()
        else
            ui.countdownText:Hide()
        end
    end

    -- Update all boards (1 for REMOTE, 2 for LOCAL)
    for playerNum, board in pairs(state.boards) do
        self:UpdateBoardUI(gameId, playerNum)
    end
end

function TetrisGame:UpdateBoardUI(gameId, playerNum)
    local game = self.games[gameId]
    local ui = game.data.ui.boards[playerNum]
    local board = game.data.state.boards[playerNum]
    local TetrisGrid = HopeAddon.TetrisGrid
    local TetrisBlocks = HopeAddon.TetrisBlocks

    if not ui.cellTextures then return end

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
                ui.cellTextures[row][col]:SetColorTexture(color.r, color.g, color.b, 1)
            else
                ui.cellTextures[row][col]:SetColorTexture(0.1, 0.1, 0.1, 1)
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
                ui.cellTextures[row][col]:SetColorTexture(color.r, color.g, color.b, 1)
            end
        end
    end

    -- Clear dirty flags
    board.grid:ClearDirtyCells()

    -- Update stats (only if changed to reduce string allocations)
    if ui.scoreLabel then
        local scoreText = "Score: " .. board.score
        if ui.scoreLabel:GetText() ~= scoreText then
            ui.scoreLabel:SetText(scoreText)
        end
    end
    if ui.levelLabel then
        local levelText = "Lvl: " .. board.level
        if ui.levelLabel:GetText() ~= levelText then
            ui.levelLabel:SetText(levelText)
        end
    end
    if ui.linesLabel then
        local linesText = "Lines: " .. board.lines
        if ui.linesLabel:GetText() ~= linesText then
            ui.linesLabel:SetText(linesText)
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
    if game.data and game.data.state then
        local state = game.data.state
        if state.countdownTimer then
            state.countdownTimer:Cancel()
            state.countdownTimer = nil
        end
    end

    -- Clear UI references
    if game.data and game.data.ui then
        local ui = game.data.ui

        -- Clear countdown text FontString reference
        ui.countdownText = nil

        -- Destroy cell textures and clear UI references for all boards
        if ui.boards then
            for playerNum, uiBoard in pairs(ui.boards) do
                -- Destroy cell textures
                if uiBoard.cellTextures then
                    for row = 1, #uiBoard.cellTextures do
                        for col = 1, #uiBoard.cellTextures[row] do
                            local texture = uiBoard.cellTextures[row][col]
                            if texture then
                                texture:Hide()
                                texture:SetParent(nil)
                            end
                        end
                    end
                    uiBoard.cellTextures = nil
                end

                -- Release frame references
                if uiBoard.container then
                    uiBoard.container:Hide()
                    uiBoard.container:SetParent(nil)
                    uiBoard.container = nil
                end
                if uiBoard.gridFrame then
                    uiBoard.gridFrame:Hide()
                    uiBoard.gridFrame:SetParent(nil)
                    uiBoard.gridFrame = nil
                end

                -- Clear label references
                uiBoard.scoreLabel = nil
                uiBoard.levelLabel = nil
                uiBoard.linesLabel = nil
            end
        end

        -- Hide window
        if ui.window then
            ui.window:Hide()
            ui.window = nil
        end
    end

    -- Clear input state and grids for all boards
    if game.data and game.data.state and game.data.state.boards then
        for playerNum, board in pairs(game.data.state.boards) do
            -- Clear input state
            board.softDropping = false
            if board.inputState then
                board.inputState.left.pressed = false
                board.inputState.right.pressed = false
            end

            -- Clear grid
            if board.grid then
                board.grid:Clear()
                board.grid = nil
            end
        end
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
