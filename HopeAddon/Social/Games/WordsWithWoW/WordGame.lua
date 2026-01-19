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
    -- Initialize word game specific data
    game.data = {
        board = self.WordBoard:New(),
        gameState = self.GAME_STATE.WAITING_TO_START,
        scores = {
            [game.player1] = 0,
            [game.player2] = 0,
        },
        moveHistory = {},
        consecutivePasses = 0,
        turnCount = 0,
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

    -- Player 1 goes first
    game.data.gameState = self.GAME_STATE.PLAYER1_TURN
    game.data.turnCount = 1

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

    game.data.gameState = self.GAME_STATE.FINISHED

    -- Determine winner by score
    local p1Score = game.data.scores[game.player1] or 0
    local p2Score = game.data.scores[game.player2] or 0

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
            ["Total Turns"] = game.data.turnCount,
            ["Words Played"] = #game.data.moveHistory,
        }
        self.GameUI:ShowGameOver(gameId, game.winner, stats)
    end
end

--[[
    Called when game is destroyed
]]
function WordGame:OnDestroy(gameId)
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

    if game.data.gameState == self.GAME_STATE.PLAYER1_TURN then
        return game.player1
    elseif game.data.gameState == self.GAME_STATE.PLAYER2_TURN then
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

    if game.data.gameState == self.GAME_STATE.FINISHED then
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
    local isFirstWord = game.data.board:IsBoardEmpty()

    -- Validate placement
    local canPlace, error = game.data.board:CanPlaceWord(word, startRow, startCol, horizontal, isFirstWord)
    if not canPlace then
        return false, error
    end

    -- Place the word
    local placedTiles = game.data.board:PlaceWord(word, startRow, startCol, horizontal)

    -- Find all words formed (main word + cross words)
    local formedWords = game.data.board:FindFormedWords(placedTiles, horizontal)

    -- Validate all formed words
    for _, wordData in ipairs(formedWords) do
        if not self.WordDictionary:IsValidWord(wordData.word) then
            -- Undo placement
            for _, tile in ipairs(placedTiles) do
                game.data.board:SetLetter(tile.row, tile.col, nil)
            end
            return false, "Cross-word '" .. wordData.word .. "' is not in the dictionary"
        end
    end

    -- Calculate total score for all formed words
    local totalScore = 0
    for _, wordData in ipairs(formedWords) do
        local wordScore = game.data.board:CalculateWordScore(
            wordData.word,
            wordData.startRow,
            wordData.startCol,
            wordData.horizontal,
            placedTiles
        )
        totalScore = totalScore + wordScore
    end

    -- Update player score
    game.data.scores[playerName] = (game.data.scores[playerName] or 0) + totalScore

    -- Record move
    table.insert(game.data.moveHistory, {
        player = playerName,
        word = word,
        startRow = startRow,
        startCol = startCol,
        horizontal = horizontal,
        score = totalScore,
        turnNumber = game.data.turnCount,
    })

    -- Reset consecutive passes
    game.data.consecutivePasses = 0

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

    if game.data.gameState == self.GAME_STATE.FINISHED then
        return false, "Game is finished"
    end

    if not self:IsPlayerTurn(gameId, playerName) then
        return false, "Not your turn"
    end

    game.data.consecutivePasses = game.data.consecutivePasses + 1

    HopeAddon:Print(playerName .. " passed.")

    -- Check for game end (both players passed)
    if game.data.consecutivePasses >= self.MAX_CONSECUTIVE_PASSES then
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
        self.GameComms:SendCustom(game.opponent, "WORDS", gameId, "PASS", "")
    end

    return true, "Turn passed"
end

--[[
    Advance to next turn
]]
function WordGame:NextTurn(gameId)
    local game = self.games[gameId]
    if not game then return end

    game.data.turnCount = game.data.turnCount + 1

    if game.data.gameState == self.GAME_STATE.PLAYER1_TURN then
        game.data.gameState = self.GAME_STATE.PLAYER2_TURN
    else
        game.data.gameState = self.GAME_STATE.PLAYER1_TURN
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
    local word, dir, startRow, startCol, score = strsplit("|", data)
    startRow = tonumber(startRow)
    startCol = tonumber(startCol)
    score = tonumber(score)
    local horizontal = (dir == "H")

    local game = self.games[gameId]
    if not game then return end

    -- Process the move
    local success, message = self:PlaceWord(gameId, word, horizontal, startRow, startCol, sender)

    if not success then
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

    -- Create game window (larger for board display)
    local window = self.GameUI:CreateGameWindow(gameId, "Words with WoW", "LARGE")
    if not window then return end

    -- Store window reference for cleanup
    game.data.window = window

    local content = window.content

    -- Player 1 info (left side)
    local p1Frame = CreateFrame("Frame", nil, content)
    p1Frame:SetPoint("TOPLEFT", 10, -10)
    p1Frame:SetSize(120, 60)

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
    game.data.p1ScoreText = p1Score

    -- Player 2 info (right side)
    local p2Frame = CreateFrame("Frame", nil, content)
    p2Frame:SetPoint("TOPRIGHT", -10, -10)
    p2Frame:SetSize(120, 60)

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
    game.data.p2ScoreText = p2Score

    -- Turn indicator (center top)
    local turnLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnLabel:SetPoint("TOP", 0, -15)
    turnLabel:SetText("Waiting to start...")
    turnLabel:SetTextColor(1, 1, 0.5)
    game.data.turnText = turnLabel

    -- Board display (center)
    local boardFrame = CreateFrame("ScrollFrame", nil, content)
    boardFrame:SetPoint("TOP", 0, -80)
    boardFrame:SetPoint("BOTTOM", 0, 50)
    boardFrame:SetPoint("LEFT", 10, 0)
    boardFrame:SetPoint("RIGHT", -10, 0)

    local boardContent = CreateFrame("Frame", nil, boardFrame)
    boardFrame:SetScrollChild(boardContent)
    boardContent:SetSize(600, 400)

    local boardText = boardContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    boardText:SetPoint("TOPLEFT", 5, -5)
    boardText:SetJustifyH("LEFT")
    boardText:SetJustifyV("TOP")
    boardText:SetFont("Fonts\\FRIZQT__.TTF", 10)  -- Monospaced-like font
    boardText:SetText(self:RenderBoard(game.data.board))
    boardText:SetTextColor(0.9, 0.9, 0.9)
    game.data.boardText = boardText

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
    game.data.lastMoveText = lastMoveText

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

    -- Update scores
    if game.data.p1ScoreText then
        game.data.p1ScoreText:SetText(tostring(game.data.scores[game.player1] or 0))
    end
    if game.data.p2ScoreText then
        game.data.p2ScoreText:SetText(tostring(game.data.scores[game.player2] or 0))
    end

    -- Update turn indicator
    if game.data.turnText then
        local turnText = ""
        if game.data.gameState == self.GAME_STATE.PLAYER1_TURN then
            turnText = game.player1 .. "'s turn (Turn " .. game.data.turnCount .. ")"
        elseif game.data.gameState == self.GAME_STATE.PLAYER2_TURN then
            turnText = game.player2 .. "'s turn (Turn " .. game.data.turnCount .. ")"
        elseif game.data.gameState == self.GAME_STATE.FINISHED then
            turnText = "Game Over!"
        else
            turnText = "Waiting to start..."
        end

        if game.data.consecutivePasses > 0 then
            turnText = turnText .. " (Pass count: " .. game.data.consecutivePasses .. ")"
        end

        game.data.turnText:SetText(turnText)
    end

    -- Update board display
    if game.data.boardText then
        game.data.boardText:SetText(self:RenderBoard(game.data.board))
    end

    -- Update last move
    if game.data.lastMoveText and #game.data.moveHistory > 0 then
        local lastMove = game.data.moveHistory[#game.data.moveHistory]
        local dir = lastMove.horizontal and "H" or "V"
        local moveText = string.format("%s: '%s' at %d,%d (%s) for %d points",
            lastMove.player, lastMove.word, lastMove.startRow, lastMove.startCol, dir, lastMove.score)
        game.data.lastMoveText:SetText(moveText)
    end
end

--[[
    Render board as text (monospaced grid)
    @param board WordBoard
    @return string
]]
function WordGame:RenderBoard(board)
    local lines = {}

    -- Header row (column numbers)
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

    -- Separator
    table.insert(lines, "   " .. string.rep("-", board.size * 3 - 1))

    -- Board rows
    for row = 1, board.size do
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

        table.insert(lines, line)
    end

    -- Legend
    table.insert(lines, "")
    table.insert(lines, "Legend: * Center  = Triple Word  - Double Word  + Triple Letter  . Double Letter")

    return table.concat(lines, "\n")
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
