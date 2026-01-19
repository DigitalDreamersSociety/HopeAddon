--[[
    HopeAddon Words with WoW Game
    Scrabble-style word game with WoW vocabulary

    Rules:
    1. Players take turns placing words on a 15x15 board
    2. First word must cover the center square
    3. Subsequent words must connect to existing words
    4. Words validated against WoW-themed dictionary
    5. Score based on letter values and bonus squares
    6. Game ends when both players pass consecutively
]]

local WordGame = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game states specific to Words with WoW
WordGame.GAME_STATE = {
    WAITING_TO_START = "WAITING_TO_START",
    PLAYER1_TURN = "PLAYER1_TURN",
    PLAYER2_TURN = "PLAYER2_TURN",
    FINISHED = "FINISHED",
}

-- Pass tracking
WordGame.MAX_CONSECUTIVE_PASSES = 2

--============================================================
-- MODULE STATE
--============================================================

-- Active word games
WordGame.games = {}

-- Cached module references
WordGame.GameCore = nil
WordGame.GameComms = nil
WordGame.GameUI = nil
WordGame.WordBoard = nil
WordGame.WordDictionary = nil

--============================================================
-- LIFECYCLE
--============================================================

function WordGame:OnInitialize()
    HopeAddon:Debug("WordGame initializing...")
end

function WordGame:OnEnable()
    -- Cache module references
    self.GameCore = HopeAddon:GetModule("GameCore")
    self.GameComms = HopeAddon:GetModule("GameComms")
    self.GameUI = HopeAddon:GetModule("GameUI")
    self.WordBoard = HopeAddon.WordBoard
    self.WordDictionary = HopeAddon.WordDictionary

    -- Register with GameCore
    if self.GameCore then
        self.GameCore:RegisterGame(self.GameCore.GAME_TYPE.WORDS, self)
    end

    -- Register communication handlers
    if self.GameComms then
        self.GameComms:RegisterHandler("WORDS", "MOVE", function(sender, gameId, data)
            self:HandleRemoteMove(sender, gameId, data)
        end)
        self.GameComms:RegisterHandler("WORDS", "PASS", function(sender, gameId, data)
            self:HandleRemotePass(sender, gameId)
        end)
    end

    HopeAddon:Debug("WordGame enabled")
end

function WordGame:OnDisable()
    -- Clean up all active games
    for gameId in pairs(self.games or {}) do
        self:OnDestroy(gameId)
    end
    self.games = {}
end

--============================================================
-- GAME LIFECYCLE (Called by GameCore)
--============================================================

--[[
    Called when game is created
]]
function WordGame:OnCreate(gameId, game)
    -- Initialize word game specific data with ui/state structure
    game.data = {
        ui = {
            window = nil,
            p1Frame = nil,
            p2Frame = nil,
            p1ScoreText = nil,
            p2ScoreText = nil,
            turnText = nil,
            boardFrame = nil,
            boardText = nil,
            lastMoveText = nil,
        },
        state = {
            board = self.WordBoard:New(),  -- WordBoard instance with methods
            gameState = self.GAME_STATE.WAITING_TO_START,
            scores = {
                [game.player1] = 0,
                [game.player2] = 0,
            },
            moveHistory = {},
            consecutivePasses = 0,
            turnCount = 0,
            -- Row cache for optimized board rendering (C3 fix)
            rowCache = {},       -- Cached row strings [rowNum] = "string"
            dirtyRows = {},      -- [rowNum] = true for rows that need re-render
            headerCache = nil,   -- Cached header row
            separatorCache = nil, -- Cached separator row
        },
    }

    -- Store reference
    self.games[gameId] = game

    HopeAddon:Debug("Words with WoW game created:", gameId)
end

--[[
    Called when game starts
]]
function WordGame:OnStart(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Player 1 goes first
    state.gameState = self.GAME_STATE.PLAYER1_TURN
    state.turnCount = 1

    -- Show UI
    self:ShowUI(gameId)

    local currentPlayer = self:GetCurrentPlayer(gameId)
    HopeAddon:Print("Words with WoW started! " .. currentPlayer .. " goes first.")
    HopeAddon:Print("Use: /word <word> <H/V> <row> <col>")
    HopeAddon:Print("Example: /word DRAGON H 8 8")
    HopeAddon:Print("Or: /pass to pass your turn")
end

--[[
    Called when game ends
]]
function WordGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    state.gameState = self.GAME_STATE.FINISHED

    -- Determine winner by score
    local p1Score = state.scores[game.player1] or 0
    local p2Score = state.scores[game.player2] or 0

    if p1Score > p2Score then
        game.winner = game.player1
    elseif p2Score > p1Score then
        game.winner = game.player2
    else
        game.winner = nil  -- Tie
    end

    -- Print results
    if game.winner then
        HopeAddon:Print("Words with WoW ended! " .. game.winner .. " wins!")
    else
        HopeAddon:Print("Words with WoW ended in a tie!")
    end
    HopeAddon:Print("Final Scores - " .. game.player1 .. ": " .. p1Score .. ", " .. game.player2 .. ": " .. p2Score)

    -- Record stats for remote games
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE and game.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames and Minigames.RecordGameResult then
            local playerName = UnitName("player")
            local result
            if game.winner == playerName then
                result = "win"
            elseif game.winner == nil then
                result = "tie"
            else
                result = "lose"
            end
            Minigames:RecordGameResult(game.opponent, "words", result)
        end
    end

    -- Show game over UI
    if self.GameUI then
        local stats = {
            [game.player1 .. " Score"] = p1Score,
            [game.player2 .. " Score"] = p2Score,
            ["Total Turns"] = state.turnCount,
            ["Words Played"] = #state.moveHistory,
        }
        self.GameUI:ShowGameOver(gameId, game.winner, stats)
    end
end

--[[
    Clean up game UI elements (memory leak prevention)
]]
function WordGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Clear FontString references
    if ui.p1ScoreText then
        ui.p1ScoreText:SetText("")
        ui.p1ScoreText = nil
    end
    if ui.p2ScoreText then
        ui.p2ScoreText:SetText("")
        ui.p2ScoreText = nil
    end
    if ui.turnText then
        ui.turnText:SetText("")
        ui.turnText = nil
    end
    if ui.boardText then
        ui.boardText:SetText("")
        ui.boardText = nil
    end
    if ui.lastMoveText then
        ui.lastMoveText:SetText("")
        ui.lastMoveText = nil
    end

    -- Clear frame references
    if ui.p1Frame then
        ui.p1Frame:Hide()
        ui.p1Frame:SetParent(nil)
        ui.p1Frame = nil
    end
    if ui.p2Frame then
        ui.p2Frame:Hide()
        ui.p2Frame:SetParent(nil)
        ui.p2Frame = nil
    end
    if ui.boardFrame then
        ui.boardFrame:Hide()
        ui.boardFrame:SetParent(nil)
        ui.boardFrame = nil
    end

    -- Clear window reference
    if ui.window then
        ui.window = nil
    end

    -- Clear state references
    if state.rowCache then
        state.rowCache = nil
    end
    if state.dirtyRows then
        state.dirtyRows = nil
    end

    state.board = nil
    state.moveHistory = nil
    state.scores = nil
end

--[[
    Called when game is destroyed
]]
function WordGame:OnDestroy(gameId)
    -- Clean up UI elements first
    self:CleanupGame(gameId)

    -- Clean up UI window
    if self.GameUI then
        self.GameUI:DestroyGameWindow(gameId)
    end

    self.games[gameId] = nil
end

--============================================================
-- TURN MANAGEMENT
--============================================================

--[[
    Get current player based on game state
]]
function WordGame:GetCurrentPlayer(gameId)
    local game = self.games[gameId]
    if not game then return nil end

    local state = game.data.state

    if state.gameState == self.GAME_STATE.PLAYER1_TURN then
        return game.player1
    elseif state.gameState == self.GAME_STATE.PLAYER2_TURN then
        return game.player2
    end

    return nil
end

--[[
    Check if it's a player's turn
]]
function WordGame:IsPlayerTurn(gameId, playerName)
    return self:GetCurrentPlayer(gameId) == playerName
end

--[[
    Place a word on the board
    @param gameId string
    @param word string
    @param horizontal boolean
    @param startRow number
    @param startCol number
    @param playerName string
    @return boolean, string - success, message
]]
function WordGame:PlaceWord(gameId, word, horizontal, startRow, startCol, playerName)
    local game = self.games[gameId]
    if not game then
        return false, "Game not found"
    end

    local state = game.data.state

    if state.gameState == self.GAME_STATE.FINISHED then
        return false, "Game is finished"
    end

    -- Check if it's player's turn
    if not self:IsPlayerTurn(gameId, playerName) then
        return false, "Not your turn"
    end

    word = word:upper()

    -- Validate word is in dictionary
    if not self.WordDictionary:IsValidWord(word) then
        return false, "'" .. word .. "' is not in the dictionary"
    end

    -- Check if first word
    local isFirstWord = state.board:IsBoardEmpty()

    -- Validate placement
    local canPlace, error = state.board:CanPlaceWord(word, startRow, startCol, horizontal, isFirstWord)
    if not canPlace then
        return false, error
    end

    -- Place the word
    local placedTiles = state.board:PlaceWord(word, startRow, startCol, horizontal)

    -- Invalidate cached rows that were modified (C3 optimization)
    self:InvalidateRows(gameId, placedTiles)

    -- Find all words formed (main word + cross words)
    local formedWords = state.board:FindFormedWords(placedTiles, horizontal)

    -- Validate all formed words
    for _, wordData in ipairs(formedWords) do
        if not self.WordDictionary:IsValidWord(wordData.word) then
            -- Undo placement
            for _, tile in ipairs(placedTiles) do
                state.board:SetLetter(tile.row, tile.col, nil)
            end
            return false, "Cross-word '" .. wordData.word .. "' is not in the dictionary"
        end
    end

    -- Calculate total score for all formed words
    local totalScore = 0
    for _, wordData in ipairs(formedWords) do
        local wordScore = state.board:CalculateWordScore(
            wordData.word,
            wordData.startRow,
            wordData.startCol,
            wordData.horizontal,
            placedTiles
        )
        totalScore = totalScore + wordScore
    end

    -- Update player score
    state.scores[playerName] = (state.scores[playerName] or 0) + totalScore

    -- Record move
    table.insert(state.moveHistory, {
        player = playerName,
        word = word,
        startRow = startRow,
        startCol = startCol,
        horizontal = horizontal,
        score = totalScore,
        turnNumber = state.turnCount,
    })

    -- Reset consecutive passes
    state.consecutivePasses = 0

    -- Print results
    HopeAddon:Print(playerName .. " played '" .. word .. "' for " .. totalScore .. " points!")
    if #formedWords > 1 then
        local crossWords = {}
        for i = 2, #formedWords do
            table.insert(crossWords, formedWords[i].word)
        end
        HopeAddon:Print("Cross-words: " .. table.concat(crossWords, ", "))
    end

    -- Update UI
    self:UpdateUI(gameId)

    -- Switch turns
    self:NextTurn(gameId)

    -- Send to remote player if networked
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE and self.GameComms then
        local dir = horizontal and "H" or "V"
        local moveData = string.format("%s|%s|%d|%d|%d", word, dir, startRow, startCol, totalScore)
        self.GameComms:SendMove(game.opponent, "WORDS", gameId, moveData)
    end

    return true, "Word placed successfully"
end

--[[
    Handle a player passing their turn
]]
function WordGame:PassTurn(gameId, playerName)
    local game = self.games[gameId]
    if not game then
        return false, "Game not found"
    end

    local state = game.data.state

    if state.gameState == self.GAME_STATE.FINISHED then
        return false, "Game is finished"
    end

    if not self:IsPlayerTurn(gameId, playerName) then
        return false, "Not your turn"
    end

    state.consecutivePasses = state.consecutivePasses + 1

    HopeAddon:Print(playerName .. " passed.")

    -- Check for game end (both players passed)
    if state.consecutivePasses >= self.MAX_CONSECUTIVE_PASSES then
        if self.GameCore then
            self.GameCore:EndGame(gameId, "both_passed")
        end
        return true, "Game ended - both players passed"
    end

    -- Update UI
    self:UpdateUI(gameId)

    -- Switch turns
    self:NextTurn(gameId)

    -- Send to remote player if networked
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE and self.GameComms then
        self.GameComms:SendMove(game.opponent, "WORDS", gameId, "PASS")
    end

    return true, "Turn passed"
end

--[[
    Advance to next turn
]]
function WordGame:NextTurn(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    state.turnCount = state.turnCount + 1

    if state.gameState == self.GAME_STATE.PLAYER1_TURN then
        state.gameState = self.GAME_STATE.PLAYER2_TURN
    else
        state.gameState = self.GAME_STATE.PLAYER1_TURN
    end

    local currentPlayer = self:GetCurrentPlayer(gameId)
    HopeAddon:Print(currentPlayer .. "'s turn.")

    self:UpdateUI(gameId)
end

--============================================================
-- REMOTE GAME HANDLING
--============================================================

--[[
    Handle word placement from remote player
]]
function WordGame:HandleRemoteMove(sender, gameId, data)
    local word, dir, startRow, startCol, remoteScore = strsplit("|", data)
    startRow = tonumber(startRow)
    startCol = tonumber(startCol)
    remoteScore = tonumber(remoteScore)
    local horizontal = (dir == "H")

    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Process the move (recalculates score locally for validation)
    local success, message = self:PlaceWord(gameId, word, horizontal, startRow, startCol, sender)

    if success then
        -- Score validation: Compare remote claimed score vs locally calculated score
        -- This prevents score manipulation by validating all word placements independently
        if remoteScore then
            local lastMove = state.moveHistory[#state.moveHistory]
            if lastMove and lastMove.score ~= remoteScore then
                -- Score mismatch detected - using local calculation (anti-cheat)
                HopeAddon:Print(string.format(
                    "|cFFFFAA00⚠ Score mismatch:|r %s claimed %d points but calculation shows %d (using verified score)",
                    sender, remoteScore, lastMove.score
                ))
                HopeAddon:Debug("Words score validation - claimed: " .. remoteScore .. ", actual: " .. lastMove.score)
                -- Note: PlaceWord already used the locally calculated score in state.scores
                -- so we don't need to override it - we're just alerting the user
            end
        end
    else
        HopeAddon:Print("|cFFFF0000Remote move failed:|r " .. message)
    end
end

--[[
    Handle pass from remote player
]]
function WordGame:HandleRemotePass(sender, gameId)
    local game = self.games[gameId]
    if not game then return end

    self:PassTurn(gameId, sender)
end

--============================================================
-- UI
--============================================================

--[[
    Show Words with WoW UI
]]
function WordGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    if not self.GameUI then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Create game window (dedicated WORDS size for board display)
    local window = self.GameUI:CreateGameWindow(gameId, "Words with WoW", "WORDS")
    if not window then return end

    -- Store window reference for cleanup
    ui.window = window

    local content = window.content

    -- Player 1 info (left side)
    local p1Frame = CreateFrame("Frame", nil, content)
    p1Frame:SetPoint("TOPLEFT", 10, -10)
    p1Frame:SetSize(120, 60)
    ui.p1Frame = p1Frame

    local p1Name = p1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p1Name:SetPoint("TOP", 0, -5)
    p1Name:SetText(game.player1)
    p1Name:SetTextColor(0.2, 1, 0.2)

    local p1ScoreLabel = p1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    p1ScoreLabel:SetPoint("TOP", p1Name, "BOTTOM", 0, -5)
    p1ScoreLabel:SetText("Score:")
    p1ScoreLabel:SetTextColor(0.6, 0.6, 0.6)

    local p1Score = p1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    p1Score:SetPoint("TOP", p1ScoreLabel, "BOTTOM", 0, -2)
    p1Score:SetText("0")
    p1Score:SetTextColor(1, 0.84, 0)
    ui.p1ScoreText = p1Score

    -- Player 2 info (right side)
    local p2Frame = CreateFrame("Frame", nil, content)
    p2Frame:SetPoint("TOPRIGHT", -10, -10)
    p2Frame:SetSize(120, 60)
    ui.p2Frame = p2Frame

    local p2Name = p2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p2Name:SetPoint("TOP", 0, -5)
    p2Name:SetText(game.player2)
    p2Name:SetTextColor(1, 0.2, 0.2)

    local p2ScoreLabel = p2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    p2ScoreLabel:SetPoint("TOP", p2Name, "BOTTOM", 0, -5)
    p2ScoreLabel:SetText("Score:")
    p2ScoreLabel:SetTextColor(0.6, 0.6, 0.6)

    local p2Score = p2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    p2Score:SetPoint("TOP", p2ScoreLabel, "BOTTOM", 0, -2)
    p2Score:SetText("0")
    p2Score:SetTextColor(1, 0.84, 0)
    ui.p2ScoreText = p2Score

    -- Turn indicator (center top)
    local turnLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnLabel:SetPoint("TOP", 0, -15)
    turnLabel:SetText("Waiting to start...")
    turnLabel:SetTextColor(1, 1, 0.5)
    ui.turnText = turnLabel

    -- Board display (center)
    local boardFrame = CreateFrame("ScrollFrame", nil, content)
    boardFrame:SetPoint("TOP", 0, -80)
    boardFrame:SetPoint("BOTTOM", 0, 50)
    boardFrame:SetPoint("LEFT", 10, 0)
    boardFrame:SetPoint("RIGHT", -10, 0)
    ui.boardFrame = boardFrame

    local boardContent = CreateFrame("Frame", nil, boardFrame)
    boardFrame:SetScrollChild(boardContent)
    boardContent:SetSize(600, 400)

    local boardText = boardContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    boardText:SetPoint("TOPLEFT", 5, -5)
    boardText:SetJustifyH("LEFT")
    boardText:SetJustifyV("TOP")
    boardText:SetFont("Fonts\\FRIZQT__.TTF", 10)  -- Monospaced-like font
    boardText:SetText(self:RenderBoard(state.board, game.data))
    boardText:SetTextColor(0.9, 0.9, 0.9)
    ui.boardText = boardText

    -- Last move display (bottom)
    local lastMoveLabel = self.GameUI:CreateLabel(content, "Last Move:", "GameFontNormalSmall")
    lastMoveLabel:SetPoint("BOTTOMLEFT", 10, 30)
    lastMoveLabel:SetTextColor(0.6, 0.6, 0.6)

    local lastMoveText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lastMoveText:SetPoint("BOTTOMLEFT", 10, 10)
    lastMoveText:SetPoint("BOTTOMRIGHT", -10, 10)
    lastMoveText:SetJustifyH("LEFT")
    lastMoveText:SetText("No moves yet")
    lastMoveText:SetTextColor(0.8, 0.8, 0.8)
    ui.lastMoveText = lastMoveText

    window:Show()

    -- Initial update
    self:UpdateUI(gameId)
end

--[[
    Update UI elements
]]
function WordGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Update scores
    if ui.p1ScoreText then
        ui.p1ScoreText:SetText(tostring(state.scores[game.player1] or 0))
    end
    if ui.p2ScoreText then
        ui.p2ScoreText:SetText(tostring(state.scores[game.player2] or 0))
    end

    -- Update turn indicator
    if ui.turnText then
        local turnText = ""
        if state.gameState == self.GAME_STATE.PLAYER1_TURN then
            turnText = game.player1 .. "'s turn (Turn " .. state.turnCount .. ")"
        elseif state.gameState == self.GAME_STATE.PLAYER2_TURN then
            turnText = game.player2 .. "'s turn (Turn " .. state.turnCount .. ")"
        elseif state.gameState == self.GAME_STATE.FINISHED then
            turnText = "Game Over!"
        else
            turnText = "Waiting to start..."
        end

        if state.consecutivePasses > 0 then
            turnText = turnText .. " (Pass count: " .. state.consecutivePasses .. ")"
        end

        ui.turnText:SetText(turnText)
    end

    -- Update board display
    if ui.boardText then
        ui.boardText:SetText(self:RenderBoard(state.board, game.data))
    end

    -- Update last move
    if ui.lastMoveText and #state.moveHistory > 0 then
        local lastMove = state.moveHistory[#state.moveHistory]
        local dir = lastMove.horizontal and "H" or "V"
        local moveText = string.format("%s: '%s' at %d,%d (%s) for %d points",
            lastMove.player, lastMove.word, lastMove.startRow, lastMove.startCol, dir, lastMove.score)
        ui.lastMoveText:SetText(moveText)
    end
end

--[[
    Render a single board row (for caching)
    @param board WordBoard
    @param row number
    @return string
]]
function WordGame:RenderBoardRow(board, row)
    local line = ""

    -- Row label
    if row < 10 then
        line = " " .. row .. " |"
    else
        line = row .. " |"
    end

    -- Cells
    for col = 1, board.size do
        local letter = board:GetLetter(row, col)
        local bonus = board:GetBonus(row, col)

        if letter then
            line = line .. " " .. letter
        else
            -- Show bonus square indicators
            if bonus == board.BONUS.CENTER then
                line = line .. " *"  -- Center star
            elseif bonus == board.BONUS.TRIPLE_WORD then
                line = line .. " ="  -- Triple word
            elseif bonus == board.BONUS.DOUBLE_WORD then
                line = line .. " -"  -- Double word
            elseif bonus == board.BONUS.TRIPLE_LETTER then
                line = line .. " +"  -- Triple letter
            elseif bonus == board.BONUS.DOUBLE_LETTER then
                line = line .. " ."  -- Double letter
            else
                line = line .. "  "  -- Empty
            end
        end

        if col < board.size then
            line = line .. " "
        end
    end

    return line
end

--[[
    Render board as text (monospaced grid) with row caching for performance
    @param board WordBoard
    @param gameData table - game.data containing cache
    @return string
]]
function WordGame:RenderBoard(board, gameData)
    local lines = {}

    -- Get or create cache from game data state
    local state = gameData and gameData.state
    local rowCache = state and state.rowCache or {}
    local dirtyRows = state and state.dirtyRows or {}

    -- Header row (column numbers) - cached since it never changes
    if state and state.headerCache then
        table.insert(lines, state.headerCache)
    else
        local header = "    "  -- Row label spacing
        for col = 1, board.size do
            if col < 10 then
                header = header .. " " .. col
            else
                header = header .. col
            end
            if col < board.size then
                header = header .. " "
            end
        end
        table.insert(lines, header)
        if state then
            state.headerCache = header
        end
    end

    -- Separator - cached since it never changes
    if state and state.separatorCache then
        table.insert(lines, state.separatorCache)
    else
        local separator = "   " .. string.rep("-", board.size * 3 - 1)
        table.insert(lines, separator)
        if state then
            state.separatorCache = separator
        end
    end

    -- Board rows - use cache where possible
    for row = 1, board.size do
        if rowCache[row] and not dirtyRows[row] then
            -- Use cached row
            table.insert(lines, rowCache[row])
        else
            -- Render and cache row
            local line = self:RenderBoardRow(board, row)
            rowCache[row] = line
            if dirtyRows[row] then
                dirtyRows[row] = nil  -- Clear dirty flag
            end
            table.insert(lines, line)
        end
    end

    -- Store cache back to game data state
    if state then
        state.rowCache = rowCache
        state.dirtyRows = dirtyRows
    end

    -- Legend (static)
    table.insert(lines, "")
    table.insert(lines, "Legend: * Center  = Triple Word  - Double Word  + Triple Letter  . Double Letter")

    return table.concat(lines, "\n")
end

--[[
    Mark rows as dirty when tiles are placed
    @param gameId string
    @param placedTiles table - array of {row, col} entries
]]
function WordGame:InvalidateRows(gameId, placedTiles)
    local game = self.games[gameId]
    if not game or not game.data or not placedTiles then return end

    local state = game.data.state

    for _, tile in ipairs(placedTiles) do
        if tile.row then
            state.dirtyRows[tile.row] = true
        end
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Start a new Words with WoW game
    @param opponent string|nil - Opponent name (nil for local)
    @return string - Game ID
]]
function WordGame:StartGame(opponent)
    if not self.GameCore then return nil end

    local mode = opponent and self.GameCore.GAME_MODE.REMOTE or self.GameCore.GAME_MODE.LOCAL
    local gameId = self.GameCore:CreateGame(self.GameCore.GAME_TYPE.WORDS, mode, opponent)

    local game = self.GameCore:GetGame(gameId)

    -- If local, set player 2 as alternate
    if not opponent then
        game.player2 = UnitName("player") .. " (2)"
    end

    self.GameCore:StartGame(gameId)

    return gameId
end

--[[
    Get active games
    @return table
]]
function WordGame:GetActiveGames()
    return self.games
end

--[[
    Get game by ID
    @param gameId string
    @return table|nil
]]
function WordGame:GetGame(gameId)
    return self.games[gameId]
end

--[[
    Parse /word command and place word
    @param gameId string
    @param word string
    @param direction string - "H" or "V"
    @param row string|number
    @param col string|number
    @param playerName string
    @return boolean, string
]]
function WordGame:ParseAndPlaceWord(gameId, word, direction, row, col, playerName)
    if not word or not direction or not row or not col then
        return false, "Usage: /word <word> <H/V> <row> <col>"
    end

    direction = direction:upper()
    if direction ~= "H" and direction ~= "V" then
        return false, "Direction must be H (horizontal) or V (vertical)"
    end

    row = tonumber(row)
    col = tonumber(col)

    if not row or not col then
        return false, "Row and column must be numbers"
    end

    local horizontal = (direction == "H")

    return self:PlaceWord(gameId, word, horizontal, row, col, playerName)
end

-- Register with addon
HopeAddon:RegisterModule("WordGame", WordGame)
HopeAddon.WordGame = WordGame

HopeAddon:Debug("WordGame module loaded")
