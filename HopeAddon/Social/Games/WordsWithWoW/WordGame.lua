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

-- UI Constants
WordGame.TILE_SIZE = 32
WordGame.TILE_PADDING = 2
WordGame.BOARD_SIZE = 15
WordGame.RACK_SIZE = 7

--============================================================
-- MODULE STATE
--============================================================

-- Active word games
WordGame.games = {}

-- Frame pools for efficient UI
WordGame.pools = {
    boardTile = nil,  -- Pool for 225 board tiles
    rackTile = nil,   -- Pool for 7 rack tiles
    toast = nil,      -- Pool for score popups
}

-- Cached module references
WordGame.GameCore = nil
WordGame.GameComms = nil
WordGame.GameUI = nil
WordGame.WordBoard = nil
WordGame.WordDictionary = nil
WordGame.Persistence = nil

-- Drag and drop state (shared across games, only one drag at a time)
WordGame.dragState = {
    isDragging = false,
    gameId = nil,              -- Active game being played
    dragTile = nil,            -- The floating drag frame
    sourceTile = nil,          -- Original rack tile being dragged
    sourceIndex = nil,         -- Rack index (1-7)
    letter = nil,              -- Letter being dragged
    pendingPlacements = {},    -- Array of {row, col, letter, rackIndex}
    placementDirection = nil,  -- "H" or "V" or nil (auto-detect)
    startRow = nil,            -- First tile placed row
    startCol = nil,            -- First tile placed col
    validSquares = {},         -- [row..","..col] = true for valid drop targets
}

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
    self.Persistence = HopeAddon:GetModule("WordGamePersistence")

    -- Create frame pools for efficient UI
    self:CreateFramePools()

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

    -- Restore any saved games from previous session
    self:RestoreSavedGames()

    HopeAddon:Debug("WordGame enabled")
end

function WordGame:OnDisable()
    -- Save all active games before disabling
    self:SaveAllGames()

    -- Clean up all active games
    for gameId in pairs(self.games or {}) do
        self:OnDestroy(gameId)
    end
    self.games = {}

    -- Destroy frame pools
    self:DestroyFramePools()
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
            -- Player panels
            p1Frame = nil,
            p2Frame = nil,
            p1Icon = nil,
            p2Icon = nil,
            p1NameText = nil,
            p2NameText = nil,
            p1ScoreText = nil,
            p2ScoreText = nil,
            p1ActiveGlow = nil,
            p2ActiveGlow = nil,
            -- Online status (player 2 only, for remote games)
            p2StatusDot = nil,
            p2StatusText = nil,
            -- Turn banner
            turnBanner = nil,
            turnText = nil,
            turnGlow = nil,
            -- Board display (frame-based)
            boardContainer = nil,
            boardBg = nil,
            tileFrames = {},  -- [row][col] = tile frame
            -- Tile rack
            rackFrame = nil,
            rackTiles = {},   -- array of 7 rack tile frames
            bagCountText = nil,
            -- Status area
            lastMoveText = nil,
            instructionText = nil,
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
            -- Tile bag and hands (for rack display)
            tileBag = {},             -- Remaining tiles to draw
            playerHands = {           -- Current tiles in hand
                [game.player1] = {},
                [game.player2] = {},
            },
            -- Recently placed tiles for animation/glow
            recentlyPlaced = {},      -- {row, col} array
            recentlyPlacedTime = 0,   -- GetTime() when placed
            -- AI opponent state (for practice mode)
            ai = {
                enabled = false,       -- Set true for AI-controlled player
                playerNum = 2,         -- Which player is AI (usually 2)
                phase = "IDLE",        -- IDLE | THINKING
            },
            -- Online status ticker (for remote games)
            statusTicker = nil,
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

    -- Initialize tile bag
    state.tileBag = self:CreateTileBag()

    -- Draw initial hands for both players
    state.playerHands[game.player1] = self:DrawTiles(state, self.RACK_SIZE)
    state.playerHands[game.player2] = self:DrawTiles(state, self.RACK_SIZE)

    -- Player 1 goes first
    state.gameState = self.GAME_STATE.PLAYER1_TURN
    state.turnCount = 1

    -- Initialize drag state for this game
    self.dragState.gameId = gameId
    wipe(self.dragState.pendingPlacements)
    self.dragState.placementDirection = nil
    self.dragState.startRow = nil
    self.dragState.startCol = nil
    wipe(self.dragState.validSquares)

    -- Show UI
    self:ShowUI(gameId)

    -- Enable AI for practice mode (LOCAL games)
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.LOCAL then
        state.ai.enabled = true
        state.ai.playerNum = 2  -- AI plays as player 2
        HopeAddon:Debug("Words Practice Mode: AI opponent enabled")
    end

    -- Start online status ticker for remote games
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE then
        state.statusTicker = HopeAddon.Timer:NewTicker(15, function()
            self:UpdateOnlineStatus(gameId)
        end)
    end

    local currentPlayer = self:GetCurrentPlayer(gameId)
    HopeAddon:Print("Words with WoW started! " .. currentPlayer .. " goes first.")
    HopeAddon:Print("Drag tiles from your rack to the board, then click 'Play Word' to submit.")
    HopeAddon:Print("Or use: /word <word> <H/V> <row> <col>  •  /pass to skip")
end

--[[
    Called when game ends
]]
function WordGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    state.gameState = self.GAME_STATE.FINISHED

    -- Cancel status ticker if running
    if state.statusTicker then
        state.statusTicker:Cancel()
        state.statusTicker = nil
    end

    -- Clear drag state
    if self.dragState.gameId == gameId then
        self:CancelDrag()
        wipe(self.dragState.pendingPlacements)
        self.dragState.placementDirection = nil
        self.dragState.startRow = nil
        self.dragState.startCol = nil
        wipe(self.dragState.validSquares)
        self.dragState.gameId = nil
    end

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

    -- Update UI to show final state
    self:UpdateUI(gameId)

    -- Show our custom game over screen instead of generic GameUI
    self:ShowGameOverScreen(gameId)
end

--[[
    Clean up game UI elements (memory leak prevention)
]]
function WordGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Release board tile frames back to pool
    if ui.tileFrames then
        for row = 1, self.BOARD_SIZE do
            if ui.tileFrames[row] then
                for col = 1, self.BOARD_SIZE do
                    local tile = ui.tileFrames[row][col]
                    if tile then
                        self:ReleaseTileFrame(tile)
                    end
                end
            end
        end
        ui.tileFrames = {}
    end

    -- Release rack tile frames back to pool
    if ui.rackTiles then
        for _, tile in ipairs(ui.rackTiles) do
            if tile then
                self:ReleaseTileFrame(tile)
            end
        end
        ui.rackTiles = {}
    end

    -- Clear FontString references
    if ui.p1ScoreText then ui.p1ScoreText:SetText(""); ui.p1ScoreText = nil end
    if ui.p2ScoreText then ui.p2ScoreText:SetText(""); ui.p2ScoreText = nil end
    if ui.p1NameText then ui.p1NameText:SetText(""); ui.p1NameText = nil end
    if ui.p2NameText then ui.p2NameText:SetText(""); ui.p2NameText = nil end
    if ui.turnText then ui.turnText:SetText(""); ui.turnText = nil end
    if ui.lastMoveText then ui.lastMoveText:SetText(""); ui.lastMoveText = nil end
    if ui.instructionText then ui.instructionText:SetText(""); ui.instructionText = nil end
    if ui.bagCountText then ui.bagCountText:SetText(""); ui.bagCountText = nil end

    -- Clear glow textures
    if ui.p1ActiveGlow then ui.p1ActiveGlow:Hide(); ui.p1ActiveGlow = nil end
    if ui.p2ActiveGlow then ui.p2ActiveGlow:Hide(); ui.p2ActiveGlow = nil end
    if ui.turnGlow then ui.turnGlow:Hide(); ui.turnGlow = nil end

    -- Clear frame references
    if ui.p1Frame then ui.p1Frame:Hide(); ui.p1Frame:SetParent(nil); ui.p1Frame = nil end
    if ui.p2Frame then ui.p2Frame:Hide(); ui.p2Frame:SetParent(nil); ui.p2Frame = nil end
    if ui.turnBanner then ui.turnBanner:Hide(); ui.turnBanner:SetParent(nil); ui.turnBanner = nil end
    if ui.rackFrame then ui.rackFrame:Hide(); ui.rackFrame:SetParent(nil); ui.rackFrame = nil end
    if ui.boardContainer then ui.boardContainer:Hide(); ui.boardContainer:SetParent(nil); ui.boardContainer = nil end

    -- Clear game over overlay
    if ui.gameOverOverlay then
        ui.gameOverOverlay:Hide()
        ui.gameOverOverlay:SetParent(nil)
        ui.gameOverOverlay = nil
    end

    -- Clear chat panel
    if ui.chatPanel then
        ui.chatPanel:Hide()
        ui.chatPanel:SetParent(nil)
        ui.chatPanel = nil
    end
    if ui.chatMessages then
        for _, msg in ipairs(ui.chatMessages) do
            msg:Hide()
            msg:SetParent(nil)
        end
        ui.chatMessages = nil
    end
    ui.chatScrollFrame = nil
    ui.chatScrollContent = nil
    ui.chatInputBox = nil

    -- Clear window reference
    if ui.window then
        ui.window = nil
    end

    -- Clear state references
    state.board = nil
    state.moveHistory = nil
    state.scores = nil
    state.tileBag = nil
    state.playerHands = nil
    state.recentlyPlaced = nil
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
    if not game or not game.data or not game.data.state then
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

    -- BINGO bonus: +35 points for using all 7 tiles in one turn
    local C = HopeAddon.Constants
    local gotBingo = (#placedTiles >= self.RACK_SIZE)
    if gotBingo and C.WORDS_BINGO_BONUS then
        totalScore = totalScore + C.WORDS_BINGO_BONUS
        HopeAddon:Print("|cFFFFD700BINGO! +" .. C.WORDS_BINGO_BONUS .. " bonus for using all 7 tiles!|r")
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

    -- Mark tiles for glow effect
    self:MarkRecentlyPlaced(gameId, placedTiles)

    -- Refill player's hand from tile bag
    -- placedTiles contains {row, col, letter} for each NEW tile placed on board
    -- (tiles that were already on board from previous words are not in placedTiles)
    local usedLetters = {}
    for _, tile in ipairs(placedTiles) do
        if tile.letter then
            table.insert(usedLetters, tile.letter)
        end
    end
    self:RefillHand(gameId, playerName, usedLetters)

    -- Print results
    HopeAddon:Print(playerName .. " played '" .. word .. "' for " .. totalScore .. " points!")
    if #formedWords > 1 then
        local crossWords = {}
        for i = 2, #formedWords do
            table.insert(crossWords, formedWords[i].word)
        end
        HopeAddon:Print("Cross-words: " .. table.concat(crossWords, ", "))
    end

    -- Play sound effects and show score toast
    local C = HopeAddon.Constants
    local thresholds = C and C.WORDS_SCORE_THRESHOLDS

    if HopeAddon.Sounds then
        if thresholds then
            if totalScore >= thresholds.AMAZING then
                HopeAddon.Sounds:PlayAchievement()
            elseif totalScore >= thresholds.GREAT then
                HopeAddon.Sounds:PlayBell()
            elseif totalScore >= thresholds.GOOD then
                HopeAddon.Sounds:PlayNewEntry()
            else
                HopeAddon.Sounds:PlayClick()
            end
        else
            HopeAddon.Sounds:PlayClick()
        end
    end

    -- Show score toast popup
    self:ShowScoreToast(gameId, word, totalScore, placedTiles)

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
    if not game or not game.data or not game.data.state then
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

    -- Clear any pending drag state for new turn
    if self.dragState.gameId == gameId then
        self:CancelDrag()
        wipe(self.dragState.pendingPlacements)
        self.dragState.placementDirection = nil
        self.dragState.startRow = nil
        self.dragState.startCol = nil
        wipe(self.dragState.validSquares)
    end

    local currentPlayer = self:GetCurrentPlayer(gameId)
    HopeAddon:Print(currentPlayer .. "'s turn.")

    self:UpdateUI(gameId)

    -- Check if AI should play next
    self:CheckAITurn(gameId)
end

--============================================================
-- REMOTE GAME HANDLING
--============================================================

--[[
    Handle word placement from remote player
]]
function WordGame:HandleRemoteMove(sender, gameId, data)
    if not data or data == "" then
        HopeAddon:Debug("HandleRemoteMove: Invalid data received from " .. (sender or "unknown"))
        return
    end

    local word, dir, startRow, startCol, remoteScore = strsplit("|", data)
    if not word or not dir or not startRow or not startCol then
        HopeAddon:Debug("HandleRemoteMove: Malformed move data: " .. tostring(data))
        return
    end

    startRow = tonumber(startRow)
    startCol = tonumber(startCol)
    remoteScore = tonumber(remoteScore)
    local horizontal = (dir == "H")

    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return end

    local state = game.data.state

    -- Process the move (recalculates score locally for validation)
    local success, message = self:PlaceWord(gameId, word, horizontal, startRow, startCol, sender)

    if success then
        -- Play notification sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayBell()
        end

        -- Show chat notification
        local lastMove = state.moveHistory[#state.moveHistory]
        if lastMove then
            HopeAddon:Print(string.format(
                "|cFF9B30FF[Words]|r %s played '%s' for |cFFFFD700%d|r points!",
                sender, word, lastMove.score
            ))
        end

        -- Score validation: Compare remote claimed score vs locally calculated score
        -- This prevents score manipulation by validating all word placements independently
        if remoteScore then
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

        -- Check if it's now local player's turn
        local playerName = UnitName("player")
        if self:IsPlayerTurn(gameId, playerName) then
            HopeAddon:Print("|cFF00FF00It's your turn!|r Use /word or drag tiles to play.")
            self:FlashTurnBanner(gameId)
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

    -- Notification
    HopeAddon:Print(string.format("|cFF9B30FF[Words]|r %s passed their turn.", sender))

    self:PassTurn(gameId, sender)

    -- Check if it's now local player's turn
    local playerName = UnitName("player")
    if self:IsPlayerTurn(gameId, playerName) then
        HopeAddon:Print("|cFF00FF00It's your turn!|r")
        self:FlashTurnBanner(gameId)

        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayBell()
        end
    end
end

--============================================================
-- AI OPPONENT (Practice Mode)
--============================================================

--[[
    Check if AI should take a turn
]]
function WordGame:CheckAITurn(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    if not state.ai or not state.ai.enabled then return end

    -- Check if it's AI's turn
    local currentPlayer = self:GetCurrentPlayer(gameId)
    local aiPlayer = state.ai.playerNum == 1 and game.player1 or game.player2

    if currentPlayer == aiPlayer and state.ai.phase == "IDLE" then
        self:StartAIThinking(gameId)
    end
end

--[[
    Start AI thinking phase (delay before deciding)
]]
function WordGame:StartAIThinking(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local C = HopeAddon.Constants.WORDS_AI_SETTINGS

    state.ai.phase = "THINKING"

    -- Update UI to show "AI is thinking..." immediately
    self:UpdateUI(gameId)

    -- Random thinking delay (1-3 seconds)
    local thinkDelay = C.THINK_TIME_MIN + math.random() * (C.THINK_TIME_MAX - C.THINK_TIME_MIN)

    HopeAddon:Debug("AI thinking for", string.format("%.1f", thinkDelay), "seconds...")

    -- Schedule AI decision after delay
    HopeAddon.Timer:After(thinkDelay, function()
        -- Make sure game still exists and it's still AI's turn
        local currentGame = self.games[gameId]
        if currentGame and currentGame.data.state.ai.phase == "THINKING" then
            self:ProcessAIDecision(gameId)
        end
    end)
end

--[[
    Process AI decision - find and play best word
]]
function WordGame:ProcessAIDecision(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local C = HopeAddon.Constants.WORDS_AI_SETTINGS

    -- Get AI player info
    local aiPlayer = state.ai.playerNum == 1 and game.player1 or game.player2
    local hand = state.playerHands[aiPlayer]

    if not hand or #hand == 0 then
        HopeAddon:Debug("AI has no tiles, passing")
        self:AIPass(gameId)
        return
    end

    -- Find all valid placements
    local validMoves = self:FindAllValidPlacements(gameId, hand)

    if #validMoves == 0 then
        HopeAddon:Debug("AI found no valid moves, passing")
        self:AIPass(gameId)
        return
    end

    -- Sort by score descending
    table.sort(validMoves, function(a, b) return a.score > b.score end)

    HopeAddon:Debug("AI found", #validMoves, "valid moves, best score:", validMoves[1].score)

    -- Apply difficulty - sometimes pick suboptimal moves
    local selectedIndex = 1
    if math.random() < C.MISTAKE_CHANCE and #validMoves > 1 then
        -- Pick a random move from top 5
        selectedIndex = math.random(1, math.min(5, #validMoves))
        HopeAddon:Debug("AI making 'mistake', picking move #" .. selectedIndex)
    end

    -- Apply length preference - AI prefers shorter words (easier to beat)
    if #validMoves[selectedIndex].word > C.MAX_WORD_LENGTH then
        for i, move in ipairs(validMoves) do
            if #move.word <= C.MAX_WORD_LENGTH then
                if math.random() < (1 - C.SKIP_LONG_WORD_CHANCE) then
                    selectedIndex = i
                    HopeAddon:Debug("AI preferring shorter word:", move.word)
                    break
                end
            end
        end
    end

    local selectedMove = validMoves[selectedIndex]

    -- Execute the move
    self:AIPlayWord(gameId, selectedMove)
end

--[[
    Find all valid word placements for AI
]]
function WordGame:FindAllValidPlacements(gameId, hand)
    local game = self.games[gameId]
    local state = game.data.state
    local board = state.board
    local validMoves = {}

    local isFirstWord = board:IsBoardEmpty()

    -- Generate all possible words from hand letters
    local possibleWords = self:GenerateWordsFromHand(hand)

    HopeAddon:Debug("AI checking", #possibleWords, "possible words from hand")

    for _, word in ipairs(possibleWords) do
        -- Try placing at each valid position
        for row = 1, self.BOARD_SIZE do
            for col = 1, self.BOARD_SIZE do
                -- Try horizontal
                local canPlace, _ = board:CanPlaceWord(word, row, col, true, isFirstWord)
                if canPlace and self:HasRequiredLetters(hand, word, board, row, col, true) then
                    -- Temporarily place to calculate score
                    local score = self:CalculatePlacementScore(gameId, word, row, col, true)
                    if score > 0 then
                        table.insert(validMoves, {
                            word = word,
                            row = row,
                            col = col,
                            horizontal = true,
                            score = score
                        })
                    end
                end

                -- Try vertical
                canPlace, _ = board:CanPlaceWord(word, row, col, false, isFirstWord)
                if canPlace and self:HasRequiredLetters(hand, word, board, row, col, false) then
                    local score = self:CalculatePlacementScore(gameId, word, row, col, false)
                    if score > 0 then
                        table.insert(validMoves, {
                            word = word,
                            row = row,
                            col = col,
                            horizontal = false,
                            score = score
                        })
                    end
                end
            end
        end
    end

    return validMoves
end

--[[
    Generate all dictionary words that can be made from hand letters
]]
function WordGame:GenerateWordsFromHand(hand)
    local possibleWords = {}
    local dictionary = self.WordDictionary.WORDS

    -- Build letter count from hand
    local letterCount = {}
    for _, letter in ipairs(hand) do
        local upper = letter:upper()
        letterCount[upper] = (letterCount[upper] or 0) + 1
    end

    -- Check each dictionary word
    for word in pairs(dictionary) do
        if self:CanMakeWord(word, letterCount) then
            table.insert(possibleWords, word)
        end
    end

    return possibleWords
end

--[[
    Check if a word can be made from available letters
]]
function WordGame:CanMakeWord(word, letterCount)
    local needed = {}
    for i = 1, #word do
        local letter = word:sub(i, i):upper()
        needed[letter] = (needed[letter] or 0) + 1
    end

    for letter, count in pairs(needed) do
        if (letterCount[letter] or 0) < count then
            return false
        end
    end

    return true
end

--[[
    Check if player has required letters (accounting for board tiles)
]]
function WordGame:HasRequiredLetters(hand, word, board, startRow, startCol, horizontal)
    local handCopy = {}
    for _, letter in ipairs(hand) do
        local upper = letter:upper()
        handCopy[upper] = (handCopy[upper] or 0) + 1
    end

    for i = 1, #word do
        local row = horizontal and startRow or (startRow + i - 1)
        local col = horizontal and (startCol + i - 1) or startCol
        local letter = word:sub(i, i):upper()
        local boardLetter = board:GetLetter(row, col)

        if boardLetter then
            -- Use board tile (no hand letter needed)
            if boardLetter ~= letter then
                return false
            end
        else
            -- Need letter from hand
            if (handCopy[letter] or 0) < 1 then
                return false
            end
            handCopy[letter] = handCopy[letter] - 1
        end
    end

    return true
end

--[[
    Calculate potential score for a placement (without actually placing)
]]
function WordGame:CalculatePlacementScore(gameId, word, startRow, startCol, horizontal)
    local game = self.games[gameId]
    local state = game.data.state
    local board = state.board

    -- Simulate placing to find new tiles
    local placedTiles = {}
    for i = 1, #word do
        local row = horizontal and startRow or (startRow + i - 1)
        local col = horizontal and (startCol + i - 1) or startCol
        local letter = word:sub(i, i):upper()

        if board:IsEmpty(row, col) then
            table.insert(placedTiles, { row = row, col = col, letter = letter })
        end
    end

    if #placedTiles == 0 then
        return 0  -- No new tiles, invalid
    end

    -- Calculate base word score
    local score = board:CalculateWordScore(word, startRow, startCol, horizontal, placedTiles)

    return score
end

--[[
    Execute AI's word placement
]]
function WordGame:AIPlayWord(gameId, move)
    local game = self.games[gameId]
    if not game then return end

    local aiPlayer = game.data.state.ai.playerNum == 1 and game.player1 or game.player2

    HopeAddon:Debug("AI playing:", move.word, "at", move.row, move.col, move.horizontal and "H" or "V", "for", move.score, "points")

    -- Use existing PlaceWord function
    local success, message = self:PlaceWord(
        gameId,
        move.word,
        move.horizontal,
        move.row,
        move.col,
        aiPlayer
    )

    if not success then
        HopeAddon:Debug("AI move failed:", message)
        self:AIPass(gameId)
    end

    game.data.state.ai.phase = "IDLE"
end

--[[
    AI passes their turn
]]
function WordGame:AIPass(gameId)
    local game = self.games[gameId]
    if not game then return end

    local aiPlayer = game.data.state.ai.playerNum == 1 and game.player1 or game.player2

    self:PassTurn(gameId, aiPlayer)
    game.data.state.ai.phase = "IDLE"
end

--============================================================
-- ONLINE STATUS INDICATOR (Remote Games)
--============================================================

--[[
    Update online status indicator for remote opponent
]]
function WordGame:UpdateOnlineStatus(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local GameCore = self.GameCore

    -- Only show for remote games
    if not GameCore or game.mode ~= GameCore.GAME_MODE.REMOTE then
        return
    end

    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers then return end

    local opponent = game.opponent
    local fellow = FellowTravelers:GetFellow(opponent)

    -- Update status UI elements (if they exist)
    local statusDot = ui.p2StatusDot
    local statusText = ui.p2StatusText
    if not statusDot or not statusText then return end

    local C = HopeAddon.Constants.WORDS_ONLINE_STATUS

    if fellow and fellow.lastSeenTime then
        local elapsed = time() - fellow.lastSeenTime

        statusDot:Show()
        statusText:Show()

        if elapsed < C.ACTIVE_THRESHOLD then
            statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
            statusText:SetText("Active")
            statusText:SetTextColor(0.2, 1, 0.2)
        elseif elapsed < C.RECENT_THRESHOLD then
            statusDot:SetTexture("Interface\\COMMON\\Indicator-Yellow")
            statusText:SetText("Online")
            statusText:SetTextColor(1, 1, 0.2)
        elseif elapsed < C.STALE_THRESHOLD then
            statusDot:SetTexture("Interface\\COMMON\\Indicator-Yellow")
            statusText:SetText("Away")
            statusText:SetTextColor(0.8, 0.8, 0.2)
        else
            statusDot:SetTexture("Interface\\COMMON\\Indicator-Gray")
            statusText:SetText("Offline")
            statusText:SetTextColor(0.5, 0.5, 0.5)
        end
    else
        statusDot:SetTexture("Interface\\COMMON\\Indicator-Gray")
        statusDot:Show()
        statusText:SetText("Unknown")
        statusText:SetTextColor(0.5, 0.5, 0.5)
        statusText:Show()
    end
end

--============================================================
-- FRAME POOLS
--============================================================

--[[
    Create frame pools for efficient UI management
]]
function WordGame:CreateFramePools()
    -- Use HopeAddon.FramePool if available
    local FramePool = HopeAddon.FramePool
    if not FramePool then
        HopeAddon:Debug("WordGame: FramePool not available, using direct frame creation")
        return
    end

    local self_ref = self  -- Capture self for closures

    -- Board tile pool (225 tiles for 15x15 grid)
    self.pools.boardTile = FramePool:NewNamed("Words_BoardTile",
        -- Create function: creates and initializes a new tile frame
        function()
            local tile = CreateFrame("Button", nil, UIParent)
            self_ref:InitializeTileFrame(tile)
            tile:Hide()
            return tile
        end,
        -- Reset function: clears tile state when returned to pool
        function(tile)
            tile:Hide()
            tile:ClearAllPoints()
            tile:SetParent(UIParent)
            -- Reset colors to defaults
            if tile.bg then tile.bg:SetColorTexture(0.2, 0.2, 0.2, 1) end
            if tile.outerBorder then tile.outerBorder:SetColorTexture(0.4, 0.35, 0.3, 1) end
            -- Clear text
            if tile.letter then tile.letter:SetText("") end
            if tile.bonusLabel then tile.bonusLabel:SetText("") end
            if tile.points then tile.points:SetText("") end
            -- Hide glow
            if tile.glow then tile.glow:Hide() end
            -- Stop any active effects
            if HopeAddon.Effects and HopeAddon.Effects.StopGlowsOnParent then
                HopeAddon.Effects:StopGlowsOnParent(tile)
            end
        end
    )

    -- Rack tile pool (7 tiles for player's hand)
    self.pools.rackTile = FramePool:NewNamed("Words_RackTile",
        function()
            local tile = CreateFrame("Button", nil, UIParent)
            self_ref:InitializeTileFrame(tile)
            tile:Hide()
            return tile
        end,
        function(tile)
            tile:Hide()
            tile:ClearAllPoints()
            tile:SetParent(UIParent)
            if tile.bg then tile.bg:SetColorTexture(0.2, 0.2, 0.2, 1) end
            if tile.outerBorder then tile.outerBorder:SetColorTexture(0.4, 0.35, 0.3, 1) end
            if tile.letter then tile.letter:SetText("") end
            if tile.bonusLabel then tile.bonusLabel:SetText("") end
            if tile.points then tile.points:SetText("") end
            if tile.glow then tile.glow:Hide() end
            if HopeAddon.Effects and HopeAddon.Effects.StopGlowsOnParent then
                HopeAddon.Effects:StopGlowsOnParent(tile)
            end
        end
    )

    -- Toast pool (score popups)
    self.pools.toast = FramePool:NewNamed("Words_Toast",
        function()
            local toast = CreateFrame("Frame", nil, UIParent)
            self_ref:InitializeToastFrame(toast)
            toast:Hide()
            return toast
        end,
        function(toast)
            toast:Hide()
            toast:ClearAllPoints()
            toast:SetParent(UIParent)
            if toast.text then toast.text:SetText("") end
        end
    )
end

--[[
    Destroy frame pools
]]
function WordGame:DestroyFramePools()
    if self.pools.boardTile then
        self.pools.boardTile:Destroy()
        self.pools.boardTile = nil
    end
    if self.pools.rackTile then
        self.pools.rackTile:Destroy()
        self.pools.rackTile = nil
    end
    if self.pools.toast then
        self.pools.toast:Destroy()
        self.pools.toast = nil
    end
end

--[[
    Initialize a tile frame with all necessary elements
    Uses SetColorTexture() for clean, scalable tile cubes with 3D bevel effect
]]
function WordGame:InitializeTileFrame(tile)
    local size = self.TILE_SIZE
    tile:SetSize(size, size)

    -- Outer border (dark edge for 3D cube effect)
    tile.outerBorder = tile:CreateTexture(nil, "BACKGROUND", nil, -1)
    tile.outerBorder:SetAllPoints()
    tile.outerBorder:SetColorTexture(0.4, 0.35, 0.3, 1)  -- Dark brown edge

    -- Inner background (main tile color - set dynamically based on bonus type)
    tile.bg = tile:CreateTexture(nil, "BACKGROUND")
    tile.bg:SetPoint("TOPLEFT", 1, -1)
    tile.bg:SetPoint("BOTTOMRIGHT", -1, 1)
    tile.bg:SetColorTexture(0.95, 0.90, 0.75, 1)  -- Default parchment

    -- Top highlight (3D bevel - light edge)
    tile.topHighlight = tile:CreateTexture(nil, "BORDER")
    tile.topHighlight:SetPoint("TOPLEFT", 1, -1)
    tile.topHighlight:SetPoint("TOPRIGHT", -1, -1)
    tile.topHighlight:SetHeight(2)
    tile.topHighlight:SetColorTexture(1, 1, 1, 0.2)

    -- Left highlight (3D bevel - light edge)
    tile.leftHighlight = tile:CreateTexture(nil, "BORDER")
    tile.leftHighlight:SetPoint("TOPLEFT", 1, -1)
    tile.leftHighlight:SetPoint("BOTTOMLEFT", 1, 1)
    tile.leftHighlight:SetWidth(2)
    tile.leftHighlight:SetColorTexture(1, 1, 1, 0.15)

    -- Bottom shadow (3D bevel - dark edge)
    tile.bottomShadow = tile:CreateTexture(nil, "BORDER")
    tile.bottomShadow:SetPoint("BOTTOMLEFT", 1, 1)
    tile.bottomShadow:SetPoint("BOTTOMRIGHT", -1, 1)
    tile.bottomShadow:SetHeight(2)
    tile.bottomShadow:SetColorTexture(0, 0, 0, 0.25)

    -- Right shadow (3D bevel - dark edge)
    tile.rightShadow = tile:CreateTexture(nil, "BORDER")
    tile.rightShadow:SetPoint("TOPRIGHT", -1, -1)
    tile.rightShadow:SetPoint("BOTTOMRIGHT", -1, 1)
    tile.rightShadow:SetWidth(2)
    tile.rightShadow:SetColorTexture(0, 0, 0, 0.2)

    -- Letter text (large, centered, clear readable font)
    tile.letter = tile:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    tile.letter:SetPoint("CENTER", 0, 2)
    tile.letter:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")

    -- Bonus label (shown when empty - DL, TL, DW, TW, star)
    tile.bonusLabel = tile:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    tile.bonusLabel:SetPoint("CENTER", 0, 0)
    tile.bonusLabel:SetFont(HopeAddon.assets.fonts.SMALL, 9, "OUTLINE")

    -- Point value (small, bottom-right corner)
    tile.points = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tile.points:SetPoint("BOTTOMRIGHT", -2, 2)
    tile.points:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")

    -- Glow texture for recently placed tiles
    tile.glow = tile:CreateTexture(nil, "OVERLAY")
    tile.glow:SetPoint("TOPLEFT", -4, 4)
    tile.glow:SetPoint("BOTTOMRIGHT", 4, -4)
    tile.glow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    tile.glow:SetBlendMode("ADD")
    tile.glow:Hide()

    -- Highlight for hover (clean white overlay)
    tile.highlight = tile:CreateTexture(nil, "HIGHLIGHT")
    tile.highlight:SetPoint("TOPLEFT", 1, -1)
    tile.highlight:SetPoint("BOTTOMRIGHT", -1, 1)
    tile.highlight:SetColorTexture(1, 1, 1, 0.15)
    tile.highlight:SetBlendMode("ADD")

    return tile
end

--[[
    Initialize a toast frame for score popups
]]
function WordGame:InitializeToastFrame(toast)
    toast:SetSize(200, 40)

    toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    toast.text:SetPoint("CENTER")
    toast.text:SetFont(HopeAddon.assets.fonts.TITLE, 20, "OUTLINE")
    toast.text:SetTextColor(1, 0.84, 0)

    return toast
end

--[[
    Acquire a tile frame from the pool or create new
]]
function WordGame:AcquireTileFrame(parent, poolType)
    local pool = self.pools[poolType or "boardTile"]
    if pool then
        local tile = pool:Acquire()
        tile:SetParent(parent)
        tile:Show()
        return tile
    end

    -- Fallback: create directly if pool unavailable
    local tile = CreateFrame("Button", nil, parent)
    self:InitializeTileFrame(tile)
    tile:Show()
    return tile
end

--[[
    Release a tile frame back to the pool
]]
function WordGame:ReleaseTileFrame(tile)
    if not tile then return end

    tile:Hide()
    tile:ClearAllPoints()
    tile:SetParent(nil)

    -- Clear state
    if tile.letter then tile.letter:SetText("") end
    if tile.bonusLabel then tile.bonusLabel:SetText("") end
    if tile.points then tile.points:SetText("") end
    if tile.glow then tile.glow:Hide() end

    -- Return to pool if possible
    local pool = self.pools.boardTile or self.pools.rackTile
    if pool then
        pool:Release(tile)
    end
end

--============================================================
-- TILE BAG AND HANDS
--============================================================

--[[
    Create a shuffled tile bag based on letter distribution
]]
function WordGame:CreateTileBag()
    local bag = {}
    local distribution = self.WordDictionary.LETTER_DISTRIBUTION

    for letter, count in pairs(distribution) do
        for i = 1, count do
            table.insert(bag, letter)
        end
    end

    -- Shuffle using Fisher-Yates
    for i = #bag, 2, -1 do
        local j = math.random(1, i)
        bag[i], bag[j] = bag[j], bag[i]
    end

    return bag
end

--[[
    Draw tiles from the bag
    @param state Game state with tileBag
    @param count Number of tiles to draw
    @return array of letter strings
]]
function WordGame:DrawTiles(state, count)
    local drawn = {}
    for i = 1, count do
        if #state.tileBag > 0 then
            table.insert(drawn, table.remove(state.tileBag))
        end
    end
    return drawn
end

--[[
    Refill player's hand after placing a word
    @param gameId string
    @param playerName string
    @param usedLetters array of letters used
]]
function WordGame:RefillHand(gameId, playerName, usedLetters)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local hand = state.playerHands[playerName]
    if not hand then return end

    -- Remove used letters from hand
    for _, letter in ipairs(usedLetters) do
        for i, handLetter in ipairs(hand) do
            if handLetter == letter then
                table.remove(hand, i)
                break
            end
        end
    end

    -- Draw new tiles to fill back to 7
    local needed = self.RACK_SIZE - #hand
    local newTiles = self:DrawTiles(state, needed)
    for _, tile in ipairs(newTiles) do
        table.insert(hand, tile)
    end
end

--============================================================
-- UI
--============================================================

--[[
    Show Words with WoW UI - TBC Cartoon Theme
]]
function WordGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    if not self.GameUI then return end

    local ui = game.data.ui
    local state = game.data.state
    local C = HopeAddon.Constants

    -- Create game window (dedicated WORDS size for board display)
    local window = self.GameUI:CreateGameWindow(gameId, "Words with WoW", "WORDS")
    if not window then return end

    ui.window = window
    local content = window.content

    -- ========== PLAYER PANELS ==========
    self:CreatePlayerPanel(content, ui, game, 1)  -- Player 1 (left)
    self:CreatePlayerPanel(content, ui, game, 2)  -- Player 2 (right)

    -- ========== TURN BANNER ==========
    self:CreateTurnBanner(content, ui)

    -- ========== BOARD CONTAINER ==========
    local boardSize = self.BOARD_SIZE * (self.TILE_SIZE + self.TILE_PADDING) + 40  -- +40 for row/col labels
    local boardContainer = CreateFrame("Frame", nil, content)
    boardContainer:SetSize(boardSize, boardSize)
    boardContainer:SetPoint("TOP", 0, -60)
    ui.boardContainer = boardContainer

    -- Board background (clean wood tone instead of quest parchment)
    local boardBg = boardContainer:CreateTexture(nil, "BACKGROUND")
    boardBg:SetAllPoints()
    boardBg:SetColorTexture(0.35, 0.28, 0.20, 1)  -- Dark wood tone
    ui.boardBg = boardBg

    -- Create column labels
    for col = 1, self.BOARD_SIZE do
        local label = boardContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        local x = 25 + (col - 1) * (self.TILE_SIZE + self.TILE_PADDING) + self.TILE_SIZE / 2
        label:SetPoint("TOP", boardContainer, "TOP", x - boardSize/2, -5)
        label:SetText(tostring(col))
        label:SetTextColor(0.4, 0.3, 0.2)
    end

    -- Create row labels and tile grid
    ui.tileFrames = {}
    for row = 1, self.BOARD_SIZE do
        ui.tileFrames[row] = {}

        -- Row label
        local rowLabel = boardContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        local y = -20 - (row - 1) * (self.TILE_SIZE + self.TILE_PADDING) - self.TILE_SIZE / 2
        rowLabel:SetPoint("LEFT", boardContainer, "LEFT", 5, y + boardSize/2 - 20)
        rowLabel:SetText(tostring(row))
        rowLabel:SetTextColor(0.4, 0.3, 0.2)

        for col = 1, self.BOARD_SIZE do
            local tile = self:AcquireTileFrame(boardContainer, "boardTile")
            local x = 25 + (col - 1) * (self.TILE_SIZE + self.TILE_PADDING)
            local tileY = -20 - (row - 1) * (self.TILE_SIZE + self.TILE_PADDING)
            tile:SetPoint("TOPLEFT", boardContainer, "TOPLEFT", x, tileY)

            -- Store row/col for tooltip
            tile.row = row
            tile.col = col

            -- Enable mouse interaction for drag & drop
            tile:EnableMouse(true)
            tile:RegisterForClicks("LeftButtonUp", "LeftButtonDown")

            -- Setup hover handlers (tooltip + drag highlighting)
            tile:SetScript("OnEnter", function(self)
                -- Show enhanced highlight if this is a valid drop target
                if WordGame.dragState.isDragging then
                    if WordGame:IsValidDropTarget(self.row, self.col) then
                        local C = HopeAddon.Constants
                        local hoverColor = C.WORDS_DRAG_COLORS.VALID_HOVER
                        if self.validHighlight then
                            self.validHighlight:SetColorTexture(hoverColor.r, hoverColor.g, hoverColor.b, hoverColor.a)
                        end
                    end
                else
                    -- Normal tooltip
                    WordGame:OnTileEnter(self, gameId)
                end
            end)

            tile:SetScript("OnLeave", function(self)
                -- Restore normal valid highlight color
                if WordGame.dragState.isDragging and self.validHighlight and self.validHighlight:IsShown() then
                    local C = HopeAddon.Constants
                    local validColor = C.WORDS_DRAG_COLORS.VALID_DROP
                    self.validHighlight:SetColorTexture(validColor.r, validColor.g, validColor.b, validColor.a)
                end
                WordGame:OnTileLeave(self)
            end)

            -- Handle mouse up (drop tile here)
            tile:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    if WordGame.dragState.isDragging then
                        -- Drop the dragged tile here
                        WordGame:EndDrag(self.row, self.col)
                    elseif self.isPending then
                        -- Click on pending tile to return it to rack
                        WordGame:RemovePendingTile(gameId, self.row, self.col)
                        if HopeAddon.Sounds then
                            HopeAddon.Sounds:PlayClick()
                        end
                    end
                end
            end)

            ui.tileFrames[row][col] = tile
        end
    end

    -- ========== TILE RACK ==========
    self:CreateTileRack(content, ui, game)

    -- ========== BUTTON BAR (Words with Friends style) ==========
    self:CreateButtonBar(content, ui, game)

    -- ========== HELP TEXT ==========
    local helpText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetPoint("BOTTOM", 0, 2)
    helpText:SetText("Drag tiles • Click to return • Shuffle to reorder")
    helpText:SetTextColor(0.5, 0.5, 0.5)
    ui.helpText = helpText

    -- ========== GAME CHAT (Remote games only) ==========
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE then
        self:CreateGameChatPanel(content, ui, game)
    end

    window:Show()

    -- Initial render
    self:UpdateUI(gameId)
end

--[[
    Create a player panel (score, name, active indicator)
]]
function WordGame:CreatePlayerPanel(parent, ui, game, playerNum)
    local isP1 = (playerNum == 1)
    local playerName = isP1 and game.player1 or game.player2
    local colors = HopeAddon.colors

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(140, 70)
    if isP1 then
        frame:SetPoint("TOPLEFT", 10, -5)
    else
        frame:SetPoint("TOPRIGHT", -10, -5)
    end

    -- Background with border
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(HopeAddon.assets.textures.TOOLTIP_BG)
    bg:SetVertexColor(0.15, 0.12, 0.1, 0.9)

    -- Active glow (hidden until it's this player's turn)
    local glow = frame:CreateTexture(nil, "BORDER")
    glow:SetPoint("TOPLEFT", -3, 3)
    glow:SetPoint("BOTTOMRIGHT", 3, -3)
    glow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    glow:SetVertexColor(1, 0.84, 0, 0.8)
    glow:SetBlendMode("ADD")
    glow:Hide()

    -- Player icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 8, 0)
    icon:SetTexture("Interface\\Icons\\Achievement_Character_Human_" .. (isP1 and "Male" or "Female"))

    -- Player name
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    nameText:SetText(playerName)
    nameText:SetTextColor(isP1 and 0.2 or 1, isP1 and 1 or 0.2, 0.2)
    nameText:SetWidth(85)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)

    -- Score display
    local scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scoreText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 2)
    scoreText:SetText("0")
    scoreText:SetTextColor(1, 0.84, 0)

    -- Online status indicator (for player 2 in remote games)
    local statusDot = nil
    local statusText = nil
    if not isP1 then
        statusDot = frame:CreateTexture(nil, "OVERLAY")
        statusDot:SetSize(10, 10)
        statusDot:SetPoint("LEFT", nameText, "RIGHT", 4, 0)
        statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
        statusDot:Hide()  -- Hidden for local games

        statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statusText:SetPoint("LEFT", statusDot, "RIGHT", 3, 0)
        statusText:SetText("")
        statusText:Hide()
    end

    -- Store references
    if isP1 then
        ui.p1Frame = frame
        ui.p1Icon = icon
        ui.p1NameText = nameText
        ui.p1ScoreText = scoreText
        ui.p1ActiveGlow = glow
    else
        ui.p2Frame = frame
        ui.p2Icon = icon
        ui.p2NameText = nameText
        ui.p2ScoreText = scoreText
        ui.p2ActiveGlow = glow
        ui.p2StatusDot = statusDot
        ui.p2StatusText = statusText
    end
end

--[[
    Create the turn banner
]]
function WordGame:CreateTurnBanner(parent, ui)
    local banner = CreateFrame("Frame", nil, parent)
    banner:SetSize(200, 30)
    banner:SetPoint("TOP", 0, -5)

    -- Banner background (scroll ribbon texture)
    local bg = banner:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(HopeAddon.assets.textures.DIVIDER)
    bg:SetVertexColor(0.8, 0.7, 0.5, 0.8)

    -- Turn text
    local turnText = banner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnText:SetPoint("CENTER")
    turnText:SetText("Waiting...")
    turnText:SetTextColor(1, 1, 0.5)

    -- Glow for "YOUR TURN"
    local turnGlow = banner:CreateTexture(nil, "BORDER")
    turnGlow:SetPoint("TOPLEFT", -5, 5)
    turnGlow:SetPoint("BOTTOMRIGHT", 5, -5)
    turnGlow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    turnGlow:SetVertexColor(1, 0.84, 0, 0.6)
    turnGlow:SetBlendMode("ADD")
    turnGlow:Hide()

    ui.turnBanner = banner
    ui.turnText = turnText
    ui.turnGlow = turnGlow
end

--[[
    Create the tile rack display
]]
function WordGame:CreateTileRack(parent, ui, game)
    local rackFrame = CreateFrame("Frame", nil, parent)
    rackFrame:SetSize(300, 50)
    rackFrame:SetPoint("BOTTOM", 0, 45)  -- Above button bar (which is 35px tall at 5px from bottom)
    ui.rackFrame = rackFrame

    -- Rack background
    local rackBg = rackFrame:CreateTexture(nil, "BACKGROUND")
    rackBg:SetAllPoints()
    rackBg:SetTexture(HopeAddon.assets.textures.TOOLTIP_BG)
    rackBg:SetVertexColor(0.2, 0.15, 0.1, 0.9)

    -- Label
    local rackLabel = rackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rackLabel:SetPoint("LEFT", 8, 0)
    rackLabel:SetText("Your Tiles:")
    rackLabel:SetTextColor(0.6, 0.6, 0.6)

    -- Create 7 rack tile slots with drag handlers
    ui.rackTiles = {}
    local startX = 75
    local gameId = game.id
    for i = 1, self.RACK_SIZE do
        local tile = self:AcquireTileFrame(rackFrame, "rackTile")
        tile:SetPoint("LEFT", rackFrame, "LEFT", startX + (i - 1) * (self.TILE_SIZE + 4), 0)
        tile.rackIndex = i
        ui.rackTiles[i] = tile

        -- Enable mouse interaction
        tile:EnableMouse(true)
        tile:RegisterForClicks("LeftButtonUp", "LeftButtonDown")

        -- Start drag on mouse down
        tile:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                WordGame:StartDrag(gameId, self.rackIndex)
            end
        end)

        -- End drag on mouse up (if released on rack, cancel)
        tile:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and WordGame.dragState.isDragging then
                WordGame:CancelDrag()
            end
        end)

        -- Hover highlight
        tile:SetScript("OnEnter", function(self)
            if not WordGame.dragState.isDragging then
                -- Show tooltip with letter value
                local letter = self.letter and self.letter:GetText()
                if letter and letter ~= "" then
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    local value = WordGame.WordDictionary.LETTER_VALUES[letter] or 0
                    GameTooltip:AddLine(letter .. " (" .. value .. " pts)")
                    GameTooltip:AddLine("Click and drag to place", 0.7, 0.7, 0.7)
                    GameTooltip:Show()
                end
            end
        end)

        tile:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    -- Bag count
    local bagCountText = rackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bagCountText:SetPoint("RIGHT", -8, 0)
    bagCountText:SetText("Bag: 100")
    bagCountText:SetTextColor(0.7, 0.7, 0.7)
    ui.bagCountText = bagCountText
end

--[[
    Update UI elements
]]
function WordGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state
    local C = HopeAddon.Constants

    -- Update scores
    if ui.p1ScoreText then
        ui.p1ScoreText:SetText(tostring(state.scores[game.player1] or 0))
    end
    if ui.p2ScoreText then
        ui.p2ScoreText:SetText(tostring(state.scores[game.player2] or 0))
    end

    -- Update active player glow
    local isP1Turn = (state.gameState == self.GAME_STATE.PLAYER1_TURN)
    local isP2Turn = (state.gameState == self.GAME_STATE.PLAYER2_TURN)

    if ui.p1ActiveGlow then
        if isP1Turn then ui.p1ActiveGlow:Show() else ui.p1ActiveGlow:Hide() end
    end
    if ui.p2ActiveGlow then
        if isP2Turn then ui.p2ActiveGlow:Show() else ui.p2ActiveGlow:Hide() end
    end

    -- Update turn banner
    if ui.turnText then
        local turnText = ""
        local showGlow = false
        local playerName = UnitName("player")

        -- Check if AI is thinking
        local aiThinking = state.ai and state.ai.enabled and state.ai.phase == "THINKING"

        if aiThinking then
            turnText = "AI is thinking..."
            ui.turnText:SetTextColor(1, 0.7, 0.3)  -- Orange for AI thinking
        elseif state.gameState == self.GAME_STATE.PLAYER1_TURN then
            if game.player1 == playerName then
                turnText = "YOUR TURN!"
                showGlow = true
                ui.turnText:SetTextColor(0.2, 1, 0.2)  -- Green for your turn
            else
                turnText = game.player1 .. "'s turn"
                ui.turnText:SetTextColor(1, 1, 0.5)  -- Yellow for waiting
            end
        elseif state.gameState == self.GAME_STATE.PLAYER2_TURN then
            if game.player2 == playerName then
                turnText = "YOUR TURN!"
                showGlow = true
                ui.turnText:SetTextColor(0.2, 1, 0.2)  -- Green for your turn
            else
                turnText = game.player2 .. "'s turn"
                ui.turnText:SetTextColor(1, 1, 0.5)  -- Yellow for waiting
            end
        elseif state.gameState == self.GAME_STATE.FINISHED then
            turnText = "GAME OVER!"
            ui.turnText:SetTextColor(1, 0.3, 0.3)  -- Red for game over
        else
            turnText = "Waiting..."
            ui.turnText:SetTextColor(1, 1, 0.5)
        end

        if state.consecutivePasses > 0 then
            turnText = turnText .. " (Pass: " .. state.consecutivePasses .. ")"
        end

        ui.turnText:SetText(turnText)

        if ui.turnGlow then
            if showGlow then ui.turnGlow:Show() else ui.turnGlow:Hide() end
        end
    end

    -- Update online status for remote games
    self:UpdateOnlineStatus(gameId)

    -- Update board tiles
    self:UpdateBoardTiles(gameId)

    -- Update tile rack
    self:UpdateTileRack(gameId)

    -- Update last move
    if ui.lastMoveText and #state.moveHistory > 0 then
        local lastMove = state.moveHistory[#state.moveHistory]
        local dir = lastMove.horizontal and "H" or "V"
        local moveText = string.format("Last: %s played '%s' for %d pts",
            lastMove.player, lastMove.word, lastMove.score)
        ui.lastMoveText:SetText(moveText)
    end
end

--[[
    Flash the turn banner to get player's attention (for remote game notifications)
]]
function WordGame:FlashTurnBanner(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    if not ui.turnBanner or not ui.turnGlow then return end

    -- Show and pulse the glow
    ui.turnGlow:Show()

    -- Use Effects module for pulsing if available
    if HopeAddon.Effects and HopeAddon.Effects.CreatePulsingGlow then
        HopeAddon.Effects:CreatePulsingGlow(ui.turnBanner, 2.0, {
            color = { r = 1, g = 0.84, b = 0, a = 0.8 },
            pulseSpeed = 0.5,
        })
    else
        -- Fallback: Simple flash using Timer
        local flashCount = 0
        local maxFlashes = 6

        local function DoFlash()
            flashCount = flashCount + 1
            if flashCount > maxFlashes then
                ui.turnGlow:SetAlpha(0.6)
                return
            end

            if flashCount % 2 == 0 then
                ui.turnGlow:SetAlpha(0.3)
            else
                ui.turnGlow:SetAlpha(1.0)
            end

            HopeAddon.Timer:After(0.25, DoFlash)
        end

        DoFlash()
    end
end

--[[
    Update all board tile visuals
]]
function WordGame:UpdateBoardTiles(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    local ui = game.data.ui
    local state = game.data.state
    if not state or not state.board then return end

    local board = state.board
    local C = HopeAddon.Constants

    if not ui or not ui.tileFrames then return end

    local bonusColors = C.WORDS_BONUS_COLORS
    local bonusLabels = C.WORDS_BONUS_LABELS
    local tileColors = C.WORDS_TILE_COLORS
    local letterValues = self.WordDictionary.LETTER_VALUES

    -- Check for recently placed tiles
    local isRecent = {}
    local recentTime = state.recentlyPlacedTime or 0
    local elapsed = GetTime() - recentTime
    if elapsed < 3 and state.recentlyPlaced then
        for _, pos in ipairs(state.recentlyPlaced) do
            isRecent[pos.row .. "," .. pos.col] = true
        end
    end

    for row = 1, self.BOARD_SIZE do
        for col = 1, self.BOARD_SIZE do
            local tile = ui.tileFrames[row][col]
            if tile then
                local letter = board:GetLetter(row, col)
                local bonus = board:GetBonus(row, col)
                local key = row .. "," .. col

                if letter then
                    -- Show placed letter
                    tile.letter:SetText(letter)
                    tile.letter:SetTextColor(tileColors.LETTER.r, tileColors.LETTER.g, tileColors.LETTER.b)
                    tile.letter:Show()

                    tile.points:SetText(tostring(letterValues[letter] or 0))
                    tile.points:SetTextColor(tileColors.POINTS.r, tileColors.POINTS.g, tileColors.POINTS.b)
                    tile.points:Show()

                    tile.bonusLabel:Hide()

                    -- Placed tile color
                    tile.bg:SetColorTexture(tileColors.PLACED.r, tileColors.PLACED.g, tileColors.PLACED.b, tileColors.PLACED.a or 1)

                    -- Show glow for recently placed
                    if isRecent[key] then
                        tile.glow:SetVertexColor(tileColors.NEW_GLOW.r, tileColors.NEW_GLOW.g, tileColors.NEW_GLOW.b, tileColors.NEW_GLOW.a)
                        tile.glow:Show()
                    else
                        tile.glow:Hide()
                    end
                else
                    -- Show empty cell with bonus indicator
                    tile.letter:Hide()
                    tile.points:Hide()

                    local bc = bonusColors[bonus] or bonusColors[0]
                    tile.bg:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)

                    local label = bonusLabels[bonus] or ""
                    tile.bonusLabel:SetText(label)
                    if bonus == 5 then  -- Center star
                        tile.bonusLabel:SetTextColor(1, 0.84, 0)
                    elseif bonus == 4 then  -- Triple Word
                        tile.bonusLabel:SetTextColor(1, 0.4, 0.3)
                    elseif bonus == 3 then  -- Double Word
                        tile.bonusLabel:SetTextColor(0.9, 0.5, 0.9)
                    elseif bonus == 2 then  -- Triple Letter
                        tile.bonusLabel:SetTextColor(0.5, 0.7, 1)
                    elseif bonus == 1 then  -- Double Letter
                        tile.bonusLabel:SetTextColor(0.4, 0.9, 0.7)
                    else
                        tile.bonusLabel:SetTextColor(0.6, 0.5, 0.4)
                    end
                    tile.bonusLabel:Show()

                    tile.glow:Hide()
                end
            end
        end
    end
end

--[[
    Update tile rack display
]]
function WordGame:UpdateTileRack(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state

    if not ui.rackTiles then return end

    -- Get current player's hand
    local playerName = UnitName("player")
    local hand = state.playerHands[playerName] or state.playerHands[game.player1] or {}
    local tileColors = HopeAddon.Constants.WORDS_TILE_COLORS
    local letterValues = self.WordDictionary.LETTER_VALUES

    -- Check which rack indices are used in pending placements
    local pendingIndices = {}
    for _, p in ipairs(self.dragState.pendingPlacements) do
        pendingIndices[p.rackIndex] = true
    end

    for i = 1, self.RACK_SIZE do
        local tile = ui.rackTiles[i]
        if tile then
            local letter = hand[i]
            local isPendingOnBoard = pendingIndices[i]

            if letter then
                tile.letter:SetText(letter)
                tile.letter:SetTextColor(tileColors.LETTER.r, tileColors.LETTER.g, tileColors.LETTER.b)
                tile.letter:Show()

                tile.points:SetText(tostring(letterValues[letter] or 0))
                tile.points:SetTextColor(tileColors.POINTS.r, tileColors.POINTS.g, tileColors.POINTS.b)
                tile.points:Show()

                tile.bonusLabel:Hide()
                tile.bg:SetColorTexture(tileColors.PLACED.r, tileColors.PLACED.g, tileColors.PLACED.b, tileColors.PLACED.a or 1)

                -- Dim tiles that are currently placed on the board (pending)
                if isPendingOnBoard then
                    tile:SetAlpha(0.3)
                else
                    tile:SetAlpha(1)
                end
            else
                tile.letter:Hide()
                tile.points:Hide()
                tile.bonusLabel:Hide()
                tile.bg:SetColorTexture(0.3, 0.25, 0.2, 0.5)
                tile:SetAlpha(0.5)
            end
        end
    end

    -- Update bag count
    if ui.bagCountText then
        local bagCount = state.tileBag and #state.tileBag or 0
        ui.bagCountText:SetText("Bag: " .. bagCount)
    end
end

--[[
    Update a single tile to show a letter
    @param tile Frame - The tile frame to update
    @param letter string - The letter to show (or nil to clear)
    @param isPending boolean - True if this is a pending (not yet confirmed) tile
]]
function WordGame:UpdateTileWithLetter(tile, letter, isPending)
    if not tile then return end

    local C = HopeAddon.Constants
    local tileColors = C.WORDS_TILE_COLORS
    local letterValues = self.WordDictionary.LETTER_VALUES

    if letter then
        -- Show the letter
        tile.letter:SetText(letter)
        tile.letter:SetTextColor(tileColors.LETTER.r, tileColors.LETTER.g, tileColors.LETTER.b)
        tile.letter:Show()

        -- Show point value
        tile.points:SetText(tostring(letterValues[letter] or 0))
        tile.points:SetTextColor(tileColors.POINTS.r, tileColors.POINTS.g, tileColors.POINTS.b)
        tile.points:Show()

        -- Hide bonus label when letter is shown
        tile.bonusLabel:Hide()

        -- Set tile color based on state
        if isPending then
            local pendingColor = C.WORDS_DRAG_COLORS.PENDING_TILE
            local pendingBorder = C.WORDS_DRAG_COLORS.PENDING_BORDER
            tile.bg:SetColorTexture(pendingColor.r, pendingColor.g, pendingColor.b, pendingColor.a)
            if tile.outerBorder then
                tile.outerBorder:SetColorTexture(pendingBorder.r, pendingBorder.g, pendingBorder.b, pendingBorder.a)
            end
        else
            tile.bg:SetColorTexture(tileColors.PLACED.r, tileColors.PLACED.g, tileColors.PLACED.b, tileColors.PLACED.a or 1)
            if tile.outerBorder then
                tile.outerBorder:SetColorTexture(0.4, 0.35, 0.3, 1)
            end
        end
    else
        -- Clear the tile
        tile.letter:Hide()
        tile.points:Hide()
    end
end

--[[
    Tile hover enter - show tooltip
]]
function WordGame:OnTileEnter(tile, gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local board = state.board
    local C = HopeAddon.Constants

    local row, col = tile.row, tile.col
    local letter = board:GetLetter(row, col)
    local bonus = board:GetBonus(row, col)

    GameTooltip:SetOwner(tile, "ANCHOR_CURSOR")

    if letter then
        -- Find who played this tile
        local playedBy = nil
        for _, move in ipairs(state.moveHistory) do
            local startR, startC = move.startRow, move.startCol
            local len = #move.word
            for i = 0, len - 1 do
                local r = move.horizontal and startR or (startR + i)
                local c = move.horizontal and (startC + i) or startC
                if r == row and c == col then
                    playedBy = move.player
                    break
                end
            end
            if playedBy then break end
        end

        GameTooltip:AddLine(letter .. " (" .. (self.WordDictionary.LETTER_VALUES[letter] or 0) .. " pts)")
        if playedBy then
            GameTooltip:AddLine("Played by: " .. playedBy, 0.7, 0.7, 0.7)
        end
    else
        local bonusName = C.WORDS_BONUS_NAMES[bonus] or ""
        if bonusName ~= "" then
            GameTooltip:AddLine(bonusName)
            if bonus == 1 then
                GameTooltip:AddLine("2x letter value", 0.4, 0.9, 0.7)
            elseif bonus == 2 then
                GameTooltip:AddLine("3x letter value", 0.5, 0.7, 1)
            elseif bonus == 3 then
                GameTooltip:AddLine("2x word value", 0.9, 0.5, 0.9)
            elseif bonus == 4 then
                GameTooltip:AddLine("3x word value", 1, 0.4, 0.3)
            elseif bonus == 5 then
                GameTooltip:AddLine("First word must cover this square", 1, 0.84, 0)
            end
        else
            GameTooltip:AddLine("Empty square")
        end
    end

    GameTooltip:AddLine(string.format("Position: Row %d, Col %d", row, col), 0.5, 0.5, 0.5)
    GameTooltip:Show()
end

--[[
    Tile hover leave
]]
function WordGame:OnTileLeave(tile)
    GameTooltip:Hide()
end

--============================================================
-- DRAG AND DROP SYSTEM
--============================================================

--[[
    Create the floating drag tile frame (singleton, reused)
]]
function WordGame:CreateDragTile()
    if self.dragState.dragTile then return self.dragState.dragTile end

    local tile = CreateFrame("Frame", "WordGameDragTile", UIParent)
    tile:SetSize(self.TILE_SIZE + 4, self.TILE_SIZE + 4)
    tile:SetFrameStrata("TOOLTIP")
    tile:SetFrameLevel(100)
    tile:Hide()

    -- CRITICAL: Disable mouse so the drag tile doesn't intercept clicks
    -- This allows OnMouseUp to fire on the board tiles underneath
    tile:EnableMouse(false)

    -- Shadow under tile
    tile.shadow = tile:CreateTexture(nil, "BACKGROUND")
    tile.shadow:SetPoint("TOPLEFT", 3, -3)
    tile.shadow:SetPoint("BOTTOMRIGHT", 3, -3)
    tile.shadow:SetColorTexture(0, 0, 0, 0.4)

    -- Outer border
    tile.outerBorder = tile:CreateTexture(nil, "BORDER")
    tile.outerBorder:SetAllPoints()
    tile.outerBorder:SetColorTexture(0.6, 0.5, 0.35, 1)

    -- Inner background
    tile.bg = tile:CreateTexture(nil, "ARTWORK")
    tile.bg:SetPoint("TOPLEFT", 2, -2)
    tile.bg:SetPoint("BOTTOMRIGHT", -2, 2)
    tile.bg:SetColorTexture(0.95, 0.90, 0.80, 1)

    -- Letter
    tile.letter = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tile.letter:SetPoint("CENTER", 0, 2)
    tile.letter:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

    -- Points
    tile.points = tile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tile.points:SetPoint("BOTTOMRIGHT", -3, 3)
    tile.points:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

    -- Update position to follow cursor
    tile:SetScript("OnUpdate", function(self)
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end)

    self.dragState.dragTile = tile
    return tile
end

--[[
    Start dragging a tile from the rack
]]
function WordGame:StartDrag(gameId, rackIndex)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return end

    local state = game.data.state
    local ui = game.data.ui

    -- Check if it's player's turn
    local playerName = UnitName("player")
    if not self:IsPlayerTurn(gameId, playerName) then
        HopeAddon:Print("It's not your turn!")
        return
    end

    -- Get the letter at this rack position
    local hand = state.playerHands[playerName]
    if not hand then return end

    local letter = hand[rackIndex]
    if not letter then return end

    -- Check if this tile is already placed (pending)
    for _, pending in ipairs(self.dragState.pendingPlacements) do
        if pending.rackIndex == rackIndex then
            HopeAddon:Print("This tile is already placed on the board!")
            return
        end
    end

    -- Set up drag state
    self.dragState.isDragging = true
    self.dragState.gameId = gameId
    self.dragState.sourceIndex = rackIndex
    self.dragState.letter = letter
    self.dragState.sourceTile = ui.rackTiles[rackIndex]

    -- Create and show drag tile
    local dragTile = self:CreateDragTile()
    dragTile.letter:SetText(letter)
    dragTile.letter:SetTextColor(0.15, 0.10, 0.05)
    local value = self.WordDictionary.LETTER_VALUES[letter] or 0
    dragTile.points:SetText(tostring(value))
    dragTile.points:SetTextColor(0.4, 0.35, 0.25)
    dragTile:Show()

    -- Dim the source rack tile
    if self.dragState.sourceTile then
        self.dragState.sourceTile:SetAlpha(0.3)
    end

    -- Calculate and show valid drop squares
    self:CalculateValidSquares(gameId)
    self:ShowValidSquares(gameId)

    -- Play pickup sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Calculate which board squares are valid drop targets
]]
function WordGame:CalculateValidSquares(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return end

    local state = game.data.state
    local board = state.board
    local pending = self.dragState.pendingPlacements

    wipe(self.dragState.validSquares)

    -- Check if board is empty (first word)
    local isBoardEmpty = board:IsBoardEmpty() and #pending == 0

    if isBoardEmpty then
        -- First word: any empty square that could connect to center
        -- For simplicity, allow any empty square (validation happens on confirm)
        for row = 1, self.BOARD_SIZE do
            for col = 1, self.BOARD_SIZE do
                if board:IsEmpty(row, col) then
                    self.dragState.validSquares[row .. "," .. col] = true
                end
            end
        end
    elseif #pending == 0 then
        -- First tile of a new word: must be adjacent to existing tiles
        for row = 1, self.BOARD_SIZE do
            for col = 1, self.BOARD_SIZE do
                if board:IsEmpty(row, col) then
                    -- Check if adjacent to any existing letter
                    local adjacents = {
                        { row - 1, col }, { row + 1, col },
                        { row, col - 1 }, { row, col + 1 }
                    }
                    for _, adj in ipairs(adjacents) do
                        if board:GetLetter(adj[1], adj[2]) then
                            self.dragState.validSquares[row .. "," .. col] = true
                            break
                        end
                    end
                end
            end
        end
    else
        -- Subsequent tiles: must be in line with pending placements
        local firstPending = pending[1]
        local startRow, startCol = firstPending.row, firstPending.col
        local direction = self.dragState.placementDirection

        if #pending == 1 then
            -- Second tile: can go horizontal or vertical from first
            -- Horizontal options
            for col = 1, self.BOARD_SIZE do
                if col ~= startCol and board:IsEmpty(startRow, col) then
                    -- Check no pending tile already there
                    local occupied = false
                    for _, p in ipairs(pending) do
                        if p.row == startRow and p.col == col then
                            occupied = true
                            break
                        end
                    end
                    if not occupied then
                        self.dragState.validSquares[startRow .. "," .. col] = true
                    end
                end
            end
            -- Vertical options
            for row = 1, self.BOARD_SIZE do
                if row ~= startRow and board:IsEmpty(row, startCol) then
                    local occupied = false
                    for _, p in ipairs(pending) do
                        if p.row == row and p.col == startCol then
                            occupied = true
                            break
                        end
                    end
                    if not occupied then
                        self.dragState.validSquares[row .. "," .. startCol] = true
                    end
                end
            end
        else
            -- Direction is locked, only allow squares in that direction
            if direction == "H" then
                for col = 1, self.BOARD_SIZE do
                    if board:IsEmpty(startRow, col) then
                        local occupied = false
                        for _, p in ipairs(pending) do
                            if p.row == startRow and p.col == col then
                                occupied = true
                                break
                            end
                        end
                        if not occupied then
                            self.dragState.validSquares[startRow .. "," .. col] = true
                        end
                    end
                end
            elseif direction == "V" then
                for row = 1, self.BOARD_SIZE do
                    if board:IsEmpty(row, startCol) then
                        local occupied = false
                        for _, p in ipairs(pending) do
                            if p.row == row and p.col == startCol then
                                occupied = true
                                break
                            end
                        end
                        if not occupied then
                            self.dragState.validSquares[row .. "," .. startCol] = true
                        end
                    end
                end
            end
        end
    end
end

--[[
    Show visual highlights on valid drop squares
]]
function WordGame:ShowValidSquares(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    local C = HopeAddon.Constants
    local validColor = C.WORDS_DRAG_COLORS.VALID_DROP

    for row = 1, self.BOARD_SIZE do
        for col = 1, self.BOARD_SIZE do
            local tile = ui.tileFrames[row] and ui.tileFrames[row][col]
            if tile then
                local key = row .. "," .. col
                if self.dragState.validSquares[key] then
                    -- Show valid highlight
                    if not tile.validHighlight then
                        tile.validHighlight = tile:CreateTexture(nil, "OVERLAY")
                        tile.validHighlight:SetPoint("TOPLEFT", 2, -2)
                        tile.validHighlight:SetPoint("BOTTOMRIGHT", -2, 2)
                        tile.validHighlight:SetBlendMode("ADD")
                    end
                    tile.validHighlight:SetColorTexture(validColor.r, validColor.g, validColor.b, validColor.a)
                    tile.validHighlight:Show()
                end
            end
        end
    end
end

--[[
    Hide valid square highlights
]]
function WordGame:HideValidSquares(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui

    for row = 1, self.BOARD_SIZE do
        for col = 1, self.BOARD_SIZE do
            local tile = ui.tileFrames[row] and ui.tileFrames[row][col]
            if tile and tile.validHighlight then
                tile.validHighlight:Hide()
            end
        end
    end
end

--[[
    Check if a square is a valid drop target
]]
function WordGame:IsValidDropTarget(row, col)
    return self.dragState.validSquares[row .. "," .. col] == true
end

--[[
    End drag - drop tile on board or cancel
]]
function WordGame:EndDrag(targetRow, targetCol)
    if not self.dragState.isDragging then return end

    local gameId = self.dragState.gameId
    local game = self.games[gameId]

    -- Hide drag tile
    if self.dragState.dragTile then
        self.dragState.dragTile:Hide()
    end

    -- Hide valid squares
    self:HideValidSquares(gameId)

    -- Restore source tile alpha (if not being placed)
    if self.dragState.sourceTile then
        self.dragState.sourceTile:SetAlpha(1)
    end

    -- Check if valid drop
    if targetRow and targetCol and self:IsValidDropTarget(targetRow, targetCol) then
        -- Add to pending placements
        self:AddPendingTile(gameId, targetRow, targetCol, self.dragState.letter, self.dragState.sourceIndex)

        -- Play drop sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayNewEntry()
        end
    else
        -- Invalid drop or cancelled - play error sound
        if targetRow and targetCol and HopeAddon.Sounds then
            HopeAddon.Sounds:PlayError()
        end
    end

    -- Clear drag state (but keep pending placements)
    self.dragState.isDragging = false
    self.dragState.sourceTile = nil
    self.dragState.sourceIndex = nil
    self.dragState.letter = nil
end

--[[
    Cancel current drag without placing
]]
function WordGame:CancelDrag()
    if not self.dragState.isDragging then return end

    local gameId = self.dragState.gameId

    -- Hide drag tile
    if self.dragState.dragTile then
        self.dragState.dragTile:Hide()
    end

    -- Hide valid squares
    self:HideValidSquares(gameId)

    -- Restore source tile alpha
    if self.dragState.sourceTile then
        self.dragState.sourceTile:SetAlpha(1)
    end

    -- Clear drag state
    self.dragState.isDragging = false
    self.dragState.sourceTile = nil
    self.dragState.sourceIndex = nil
    self.dragState.letter = nil
end

--[[
    Add a tile to pending placements
]]
function WordGame:AddPendingTile(gameId, row, col, letter, rackIndex)
    local pending = self.dragState.pendingPlacements

    -- Add to pending list
    table.insert(pending, {
        row = row,
        col = col,
        letter = letter,
        rackIndex = rackIndex,
    })

    -- Detect direction after second tile
    if #pending == 2 then
        local first = pending[1]
        local second = pending[2]
        if first.row == second.row then
            self.dragState.placementDirection = "H"
        else
            self.dragState.placementDirection = "V"
        end
        self.dragState.startRow = first.row
        self.dragState.startCol = first.col
    elseif #pending == 1 then
        self.dragState.startRow = row
        self.dragState.startCol = col
    end

    -- Update UI to show pending tile on board
    self:UpdatePendingTilesDisplay(gameId)
    self:UpdateTileRack(gameId)
    self:UpdateLiveScore(gameId)
    self:UpdateButtonBar(gameId)
end

--[[
    Remove a pending tile (click to return to rack)
]]
function WordGame:RemovePendingTile(gameId, row, col)
    local pending = self.dragState.pendingPlacements

    for i, p in ipairs(pending) do
        if p.row == row and p.col == col then
            table.remove(pending, i)
            break
        end
    end

    -- Reset direction if we're back to 1 or 0 tiles
    if #pending <= 1 then
        self.dragState.placementDirection = nil
    end

    -- Update displays
    self:UpdatePendingTilesDisplay(gameId)
    self:UpdateTileRack(gameId)
    self:UpdateLiveScore(gameId)
    self:UpdateButtonBar(gameId)
end

--[[
    Clear all pending placements
]]
function WordGame:ClearPendingTiles(gameId)
    wipe(self.dragState.pendingPlacements)
    self.dragState.placementDirection = nil
    self.dragState.startRow = nil
    self.dragState.startCol = nil
    wipe(self.dragState.validSquares)

    self:UpdatePendingTilesDisplay(gameId)
    self:UpdateTileRack(gameId)
    self:UpdateLiveScore(gameId)
    self:UpdateButtonBar(gameId)

    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Update board display to show pending tiles
]]
function WordGame:UpdatePendingTilesDisplay(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    local C = HopeAddon.Constants
    local pendingColor = C.WORDS_DRAG_COLORS.PENDING_TILE
    local pendingBorder = C.WORDS_DRAG_COLORS.PENDING_BORDER
    local tileColors = C.WORDS_TILE_COLORS
    local letterValues = self.WordDictionary.LETTER_VALUES

    -- First, reset all board tiles to normal state
    self:UpdateBoardTiles(gameId)

    -- Then overlay pending tiles
    for _, pending in ipairs(self.dragState.pendingPlacements) do
        local tile = ui.tileFrames[pending.row] and ui.tileFrames[pending.row][pending.col]
        if tile then
            -- Show as pending tile
            tile.letter:SetText(pending.letter)
            tile.letter:SetTextColor(tileColors.LETTER.r, tileColors.LETTER.g, tileColors.LETTER.b)
            tile.letter:Show()

            tile.points:SetText(tostring(letterValues[pending.letter] or 0))
            tile.points:SetTextColor(tileColors.POINTS.r, tileColors.POINTS.g, tileColors.POINTS.b)
            tile.points:Show()

            tile.bonusLabel:Hide()

            -- Pending color (slightly different from placed)
            tile.bg:SetColorTexture(pendingColor.r, pendingColor.g, pendingColor.b, pendingColor.a)
            tile.outerBorder:SetColorTexture(pendingBorder.r, pendingBorder.g, pendingBorder.b, pendingBorder.a)

            -- Store pending flag for click handling
            tile.isPending = true
            tile.pendingLetter = pending.letter
            tile.pendingRackIndex = pending.rackIndex
        end
    end
end

--[[
    Get the word formed by pending tiles (sorted)
]]
function WordGame:GetPendingWord()
    local pending = self.dragState.pendingPlacements
    if #pending == 0 then return "" end

    -- Sort pending by position
    local sorted = {}
    for _, p in ipairs(pending) do
        table.insert(sorted, p)
    end

    local direction = self.dragState.placementDirection
    if direction == "H" then
        table.sort(sorted, function(a, b) return a.col < b.col end)
    elseif direction == "V" then
        table.sort(sorted, function(a, b) return a.row < b.row end)
    end

    local word = ""
    for _, p in ipairs(sorted) do
        word = word .. p.letter
    end

    return word
end

--[[
    Estimate score for pending word (simplified, doesn't include cross-words)
]]
function WordGame:EstimatePendingScore(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return 0 end

    local state = game.data.state
    local board = state.board
    local pending = self.dragState.pendingPlacements
    local letterValues = self.WordDictionary.LETTER_VALUES

    local score = 0
    local wordMultiplier = 1

    for _, p in ipairs(pending) do
        local value = letterValues[p.letter] or 0
        local bonus = board:GetBonus(p.row, p.col)

        if bonus == 1 then -- DL
            value = value * 2
        elseif bonus == 2 then -- TL
            value = value * 3
        elseif bonus == 3 or bonus == 5 then -- DW or Center
            wordMultiplier = wordMultiplier * 2
        elseif bonus == 4 then -- TW
            wordMultiplier = wordMultiplier * 3
        end

        score = score + value
    end

    return score * wordMultiplier
end

--[[
    Confirm and submit the pending word
]]
function WordGame:ConfirmPendingWord(gameId)
    local pending = self.dragState.pendingPlacements
    if #pending == 0 then
        HopeAddon:Print("No tiles placed!")
        return
    end

    -- Build the word and determine placement
    local word = self:GetPendingWord()
    local direction = self.dragState.placementDirection or "H"
    local horizontal = (direction == "H")

    -- Sort to find start position
    local sorted = {}
    for _, p in ipairs(pending) do
        table.insert(sorted, p)
    end

    if horizontal then
        table.sort(sorted, function(a, b) return a.col < b.col end)
    else
        table.sort(sorted, function(a, b) return a.row < b.row end)
    end

    local startRow = sorted[1].row
    local startCol = sorted[1].col

    -- Clear pending state before placing (so PlaceWord works correctly)
    self:ClearPendingTiles(gameId)

    -- Attempt to place the word
    local playerName = UnitName("player")
    local success, message = self:PlaceWord(gameId, word, horizontal, startRow, startCol, playerName)

    if not success then
        HopeAddon:Print("|cFFFF0000" .. message .. "|r")
        -- Could restore pending tiles here, but for now just clear
    end
end

--============================================================
-- WORDS WITH FRIENDS STYLE FEATURES
--============================================================

--[[
    Shuffle tiles in the rack (randomize order)
]]
function WordGame:ShuffleTiles(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return end

    local state = game.data.state
    local playerName = UnitName("player")
    local hand = state.playerHands[playerName]
    if not hand or #hand == 0 then return end

    -- Fisher-Yates shuffle
    for i = #hand, 2, -1 do
        local j = math.random(1, i)
        hand[i], hand[j] = hand[j], hand[i]
    end

    -- Update rack display
    self:UpdateTileRack(gameId)

    -- Play shuffle sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Recall all placed tiles back to rack (animated)
]]
function WordGame:RecallTiles(gameId)
    local pending = self.dragState.pendingPlacements
    if #pending == 0 then return end

    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui

    -- Animate tiles flying back to rack (simple version - just clear with sound)
    -- For each pending tile, we could animate it, but for now just clear
    for _, p in ipairs(pending) do
        local boardTile = ui.tileFrames[p.row] and ui.tileFrames[p.row][p.col]
        if boardTile then
            -- Reset the isPending flag
            boardTile.isPending = false
            boardTile.pendingLetter = nil
            boardTile.pendingRackIndex = nil
        end
    end

    -- Clear pending state
    wipe(self.dragState.pendingPlacements)
    self.dragState.placementDirection = nil
    self.dragState.startRow = nil
    self.dragState.startCol = nil

    -- Update displays
    self:UpdateBoardTiles(gameId)
    self:UpdateTileRack(gameId)
    self:UpdateButtonBar(gameId)
    self:UpdateLiveScore(gameId)

    -- Play recall sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Swap tiles - exchange selected tiles for new ones from bag (loses turn)
]]
function WordGame:SwapTiles(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.state then return end

    local state = game.data.state
    local playerName = UnitName("player")

    -- Check if it's player's turn
    if not self:IsPlayerTurn(gameId, playerName) then
        HopeAddon:Print("It's not your turn!")
        return
    end

    -- Check if bag has tiles
    local bagCount = state.tileBag and #state.tileBag or 0
    if bagCount == 0 then
        HopeAddon:Print("No tiles left in the bag to swap!")
        return
    end

    local hand = state.playerHands[playerName]
    if not hand or #hand == 0 then return end

    -- Clear any pending placements first
    if #self.dragState.pendingPlacements > 0 then
        self:RecallTiles(gameId)
    end

    -- Swap ALL tiles (simplest version - like Words with Friends)
    -- Return current tiles to bag
    for _, letter in ipairs(hand) do
        table.insert(state.tileBag, letter)
    end

    -- Shuffle bag
    for i = #state.tileBag, 2, -1 do
        local j = math.random(1, i)
        state.tileBag[i], state.tileBag[j] = state.tileBag[j], state.tileBag[i]
    end

    -- Draw new tiles
    wipe(hand)
    local newTiles = self:DrawTiles(state, self.RACK_SIZE)
    for _, tile in ipairs(newTiles) do
        table.insert(hand, tile)
    end

    -- Swap counts as a turn
    HopeAddon:Print(playerName .. " swapped all tiles.")

    -- Update UI
    self:UpdateTileRack(gameId)
    self:UpdateButtonBar(gameId)

    -- Next turn
    self:NextTurn(gameId)

    -- Send to remote if networked
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE and self.GameComms then
        self.GameComms:SendMove(game.opponent, "WORDS", gameId, "SWAP")
    end

    -- Play swap sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayNewEntry()
    end
end

--[[
    Update the live score display as tiles are placed
]]
function WordGame:UpdateLiveScore(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    local pending = self.dragState.pendingPlacements
    local C = HopeAddon.Constants

    -- Create live score text if it doesn't exist
    if not ui.liveScoreText then
        ui.liveScoreText = ui.window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ui.liveScoreText:SetPoint("BOTTOM", ui.rackFrame, "TOP", 0, 8)
        ui.liveScoreText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    end

    if #pending == 0 then
        ui.liveScoreText:SetText("")
        return
    end

    -- Build the word and calculate score
    local word = self:GetPendingWord()
    local estimatedScore = self:EstimatePendingScore(gameId)

    -- Check for bonus squares used
    local bonusesUsed = {}
    local state = game.data.state
    local board = state.board

    for _, p in ipairs(pending) do
        local bonus = board:GetBonus(p.row, p.col)
        if bonus == 1 then bonusesUsed["DL"] = true
        elseif bonus == 2 then bonusesUsed["TL"] = true
        elseif bonus == 3 then bonusesUsed["DW"] = true
        elseif bonus == 4 then bonusesUsed["TW"] = true
        elseif bonus == 5 then bonusesUsed["★"] = true
        end
    end

    -- Build bonus text
    local bonusText = ""
    if next(bonusesUsed) then
        local bonusList = {}
        for b, _ in pairs(bonusesUsed) do
            table.insert(bonusList, b)
        end
        bonusText = " |cFF888888(" .. table.concat(bonusList, ", ") .. ")|r"
    end

    -- Check for BINGO (all 7 tiles used)
    local bingoText = ""
    if #pending >= 7 then
        bingoText = " |cFFFFD700+35 BINGO!|r"
        estimatedScore = estimatedScore + C.WORDS_BINGO_BONUS
    end

    -- Format: "DRAGON → 24 pts (DW, TL)"
    ui.liveScoreText:SetText(string.format("|cFFFFD700%s|r → |cFF00FF00%d pts|r%s%s",
        word, estimatedScore, bonusText, bingoText))
end

--[[
    Create the Words with Friends style button bar
]]
function WordGame:CreateButtonBar(parent, ui, game)
    local gameId = game.id
    local C = HopeAddon.Constants
    local btnColors = C.WORDS_BUTTON_COLORS

    local buttonBar = CreateFrame("Frame", nil, parent)
    buttonBar:SetSize(500, 35)
    buttonBar:SetPoint("BOTTOM", 0, 5)
    ui.buttonBar = buttonBar

    -- Helper to create styled button
    local function CreateActionButton(name, text, color, xOffset, width, onClick)
        local btn = CreateFrame("Button", nil, buttonBar)
        btn:SetSize(width or 70, 28)
        btn:SetPoint("LEFT", buttonBar, "LEFT", xOffset, 0)

        -- Background
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(color.r, color.g, color.b, 0.8)

        -- Border
        btn.border = btn:CreateTexture(nil, "BORDER")
        btn.border:SetPoint("TOPLEFT", -1, 1)
        btn.border:SetPoint("BOTTOMRIGHT", 1, -1)
        btn.border:SetColorTexture(0.2, 0.2, 0.2, 1)

        -- Text
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("CENTER")
        btn.text:SetText(text)
        btn.text:SetTextColor(1, 1, 1)

        -- Hover effect
        btn:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(color.r + 0.1, color.g + 0.1, color.b + 0.1, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isEnabled ~= false then
                self.bg:SetColorTexture(color.r, color.g, color.b, 0.8)
            end
        end)

        btn:SetScript("OnClick", onClick)

        btn.SetEnabled = function(self, enabled)
            self.isEnabled = enabled
            if enabled then
                self.bg:SetColorTexture(color.r, color.g, color.b, 0.8)
                self.text:SetTextColor(1, 1, 1)
                self:EnableMouse(true)
            else
                self.bg:SetColorTexture(btnColors.DISABLED.r, btnColors.DISABLED.g, btnColors.DISABLED.b, 0.5)
                self.text:SetTextColor(0.5, 0.5, 0.5)
                self:EnableMouse(false)
            end
        end

        return btn
    end

    -- Shuffle button (blue)
    ui.shuffleBtn = CreateActionButton("shuffle", "Shuffle", btnColors.SHUFFLE, 10, 65, function()
        WordGame:ShuffleTiles(gameId)
    end)

    -- Swap button (orange)
    ui.swapBtn = CreateActionButton("swap", "Swap", btnColors.SWAP, 85, 55, function()
        WordGame:SwapTiles(gameId)
    end)

    -- Recall button (yellow)
    ui.recallBtn = CreateActionButton("recall", "Recall", btnColors.RECALL, 150, 60, function()
        WordGame:RecallTiles(gameId)
    end)

    -- Pass button (gray)
    ui.passBtn = CreateActionButton("pass", "Pass", btnColors.PASS, 220, 50, function()
        local playerName = UnitName("player")
        WordGame:PassTurn(gameId, playerName)
    end)

    -- PLAY button (green, larger, on right side)
    ui.playBtn = CreateActionButton("play", "▶ PLAY", btnColors.PLAY, 380, 90, function()
        WordGame:ConfirmPendingWord(gameId)
    end)
    ui.playBtn.text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

    -- Initial state
    self:UpdateButtonBar(gameId)
end

--[[
    Update button states based on game state
]]
function WordGame:UpdateButtonBar(gameId)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    local state = game.data.state
    local pending = self.dragState.pendingPlacements
    local playerName = UnitName("player")
    local isMyTurn = self:IsPlayerTurn(gameId, playerName)
    local hasPending = #pending > 0

    -- Shuffle: always enabled
    if ui.shuffleBtn then
        ui.shuffleBtn:SetEnabled(true)
    end

    -- Swap: enabled on your turn, no pending tiles
    if ui.swapBtn then
        ui.swapBtn:SetEnabled(isMyTurn and not hasPending)
    end

    -- Recall: enabled only when tiles are pending
    if ui.recallBtn then
        ui.recallBtn:SetEnabled(hasPending)
    end

    -- Pass: enabled on your turn, no pending tiles
    if ui.passBtn then
        ui.passBtn:SetEnabled(isMyTurn and not hasPending)
    end

    -- Play: enabled on your turn with pending tiles
    if ui.playBtn then
        ui.playBtn:SetEnabled(isMyTurn and hasPending)
    end

    -- Hide old confirm/cancel buttons if they exist
    if ui.confirmButton then ui.confirmButton:Hide() end
    if ui.cancelButton then ui.cancelButton:Hide() end
end

--[[
    Create embedded game chat panel for multiplayer games
]]
function WordGame:CreateGameChatPanel(parent, ui, game)
    local GameChat = HopeAddon:GetModule("GameChat")

    -- Create chat panel container
    local chatPanel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    chatPanel:SetSize(180, 150)
    chatPanel:SetPoint("BOTTOMRIGHT", -5, 45)

    -- Dark semi-transparent background
    chatPanel:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    chatPanel:SetBackdropColor(0.05, 0.05, 0.05, 0.85)
    chatPanel:SetBackdropBorderColor(0.4, 0.35, 0.3, 0.8)

    -- Title
    local title = chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFFFFD700Game Chat|r")

    -- Messages scroll area
    local scrollFrame = CreateFrame("ScrollFrame", nil, chatPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -22)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 30)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetSize(140, 200)
    scrollFrame:SetScrollChild(scrollContent)

    ui.chatPanel = chatPanel
    ui.chatScrollFrame = scrollFrame
    ui.chatScrollContent = scrollContent
    ui.chatMessages = {}

    -- Input box for typing messages
    local inputBox = CreateFrame("EditBox", nil, chatPanel, "InputBoxTemplate")
    inputBox:SetSize(140, 18)
    inputBox:SetPoint("BOTTOMLEFT", 8, 6)
    inputBox:SetAutoFocus(false)
    inputBox:SetMaxLetters(100)
    inputBox:SetFontObject(GameFontNormalSmall)

    -- Placeholder text
    inputBox.placeholder = inputBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    inputBox.placeholder:SetPoint("LEFT", 5, 0)
    inputBox.placeholder:SetText("Type to chat...")
    inputBox.placeholder:SetTextColor(0.5, 0.5, 0.5, 0.7)

    inputBox:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then
            self.placeholder:Show()
        else
            self.placeholder:Hide()
        end
    end)

    inputBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if text and text ~= "" then
            -- Send via GameChat
            if GameChat then
                GameChat:SendMessage(text)
            end
            self:SetText("")
        end
        self:ClearFocus()
    end)

    inputBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)

    ui.chatInputBox = inputBox

    -- Hook into GameChat to receive messages
    if GameChat then
        -- Store original display function
        local originalDisplay = GameChat.DisplayMessage
        GameChat.DisplayMessage = function(chatSelf, sender, message)
            -- Call original
            originalDisplay(chatSelf, sender, message)
            -- Also update our embedded display
            WordGame:AddChatMessage(game.id, sender, message)
        end

        -- Show existing messages
        local messages = GameChat:GetMessages()
        for _, msg in ipairs(messages) do
            self:AddChatMessage(game.id, msg.sender, msg.message)
        end
    end

    -- Hint text
    local hint = chatPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("BOTTOMRIGHT", -30, 8)
    hint:SetText("or /gc")
    hint:SetTextColor(0.4, 0.4, 0.4)
end

--[[
    Add a chat message to the embedded display
]]
function WordGame:AddChatMessage(gameId, sender, message)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    if not ui.chatScrollContent then return end

    local content = ui.chatScrollContent
    local messages = ui.chatMessages or {}

    -- Create message text
    local msgFrame = CreateFrame("Frame", nil, content)
    msgFrame:SetSize(135, 14)

    local text = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("TOPLEFT")
    text:SetWidth(135)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)

    local isMe = sender == UnitName("player")
    local nameColor = isMe and "|cFF00FF00" or "|cFFFFD700"
    text:SetText(nameColor .. sender .. ":|r " .. message)

    -- Calculate height
    local textHeight = text:GetStringHeight() or 14
    msgFrame:SetHeight(textHeight + 2)

    table.insert(messages, msgFrame)
    ui.chatMessages = messages

    -- Position all messages
    local yOffset = 0
    for i, msg in ipairs(messages) do
        msg:ClearAllPoints()
        msg:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        yOffset = yOffset + msg:GetHeight()
    end

    -- Update content height
    content:SetHeight(math.max(yOffset, 100))

    -- Scroll to bottom
    if ui.chatScrollFrame then
        local maxScroll = ui.chatScrollFrame:GetVerticalScrollRange() or 0
        ui.chatScrollFrame:SetVerticalScroll(maxScroll)
    end

    -- Limit messages (keep last 20)
    while #messages > 20 do
        local old = table.remove(messages, 1)
        old:Hide()
        old:SetParent(nil)
    end
end

--[[
    Mark recently placed tiles for glow effect
]]
function WordGame:MarkRecentlyPlaced(gameId, placedTiles)
    local game = self.games[gameId]
    if not game or not game.data or not placedTiles then return end

    local state = game.data.state
    state.recentlyPlaced = placedTiles
    state.recentlyPlacedTime = GetTime()
end

--[[
    Show floating score toast popup
]]
function WordGame:ShowScoreToast(gameId, word, score, placedTiles)
    local game = self.games[gameId]
    if not game or not game.data or not game.data.ui then return end

    local ui = game.data.ui
    if not ui.boardContainer then return end

    -- Create toast frame (not pooled for simplicity)
    local toast = CreateFrame("Frame", nil, ui.boardContainer)
    toast:SetSize(200, 50)
    toast:SetFrameStrata("TOOLTIP")

    -- Position at center of placed word
    if placedTiles and #placedTiles > 0 then
        local midTile = placedTiles[math.ceil(#placedTiles / 2)]
        local x = 25 + (midTile.col - 1) * (self.TILE_SIZE + self.TILE_PADDING) + self.TILE_SIZE / 2
        local y = -20 - (midTile.row - 1) * (self.TILE_SIZE + self.TILE_PADDING) - self.TILE_SIZE / 2
        toast:SetPoint("CENTER", ui.boardContainer, "TOPLEFT", x, y - 20)
    else
        toast:SetPoint("CENTER", ui.boardContainer, "CENTER", 0, 0)
    end

    -- Score text with glow
    local text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER")
    text:SetFont(HopeAddon.assets.fonts.TITLE, 22, "OUTLINE")

    -- Color based on score
    local C = HopeAddon.Constants
    local thresholds = C and C.WORDS_SCORE_THRESHOLDS
    if thresholds and score >= thresholds.AMAZING then
        text:SetText("+" .. score .. " " .. word .. "!")
        text:SetTextColor(1, 0.5, 0)  -- Orange for amazing
    elseif thresholds and score >= thresholds.GREAT then
        text:SetText("+" .. score .. "!")
        text:SetTextColor(1, 0.84, 0)  -- Gold for great
    else
        text:SetText("+" .. score)
        text:SetTextColor(0.9, 0.9, 0.5)  -- Yellow for normal
    end

    -- Animate: Float up and fade out over 1.5 seconds
    local startTime = GetTime()
    local duration = 1.5
    local startY = toast:GetTop() and 0 or 0

    toast:SetScript("OnUpdate", function(self, elapsed)
        local now = GetTime()
        local progress = (now - startTime) / duration

        if progress >= 1 then
            self:Hide()
            self:SetScript("OnUpdate", nil)
            return
        end

        -- Float upward
        local yOffset = progress * 50
        self:ClearAllPoints()
        if placedTiles and #placedTiles > 0 then
            local midTile = placedTiles[math.ceil(#placedTiles / 2)]
            local x = 25 + (midTile.col - 1) * (WordGame.TILE_SIZE + WordGame.TILE_PADDING) + WordGame.TILE_SIZE / 2
            local y = -20 - (midTile.row - 1) * (WordGame.TILE_SIZE + WordGame.TILE_PADDING) - WordGame.TILE_SIZE / 2
            self:SetPoint("CENTER", ui.boardContainer, "TOPLEFT", x, y - 20 + yOffset)
        else
            self:SetPoint("CENTER", ui.boardContainer, "CENTER", 0, yOffset)
        end

        -- Fade out in last 40%
        if progress > 0.6 then
            local fadeProgress = (progress - 0.6) / 0.4
            self:SetAlpha(1 - fadeProgress)
        end
    end)

    toast:Show()
end

--[[
    Show game over results screen overlay
]]
function WordGame:ShowGameOverScreen(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    local ui = game.data.ui
    local state = game.data.state

    if not ui.window then return end

    -- Create overlay frame
    local overlay = CreateFrame("Frame", nil, ui.window, "BackdropTemplate")
    overlay:SetAllPoints()
    overlay:SetFrameStrata("DIALOG")

    -- Dark background
    overlay:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    overlay:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    overlay:SetBackdropBorderColor(0.5, 0.4, 0.3, 1)

    -- Results panel (dark wood tone to match board)
    local panel = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    panel:SetSize(350, 400)
    panel:SetPoint("CENTER")
    panel:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true, tileSize = 16, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    panel:SetBackdropColor(0.35, 0.28, 0.20, 1)  -- Dark wood tone to match board
    panel:SetBackdropBorderColor(1, 0.84, 0, 1)

    -- "GAME OVER" title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -30)
    title:SetFont(HopeAddon.assets.fonts.TITLE, 28, "OUTLINE")
    title:SetText("GAME OVER!")
    title:SetTextColor(0.8, 0.2, 0.1)

    -- Determine winner
    local p1Score = state.scores[game.player1] or 0
    local p2Score = state.scores[game.player2] or 0
    local winner, winnerScore, loser, loserScore

    if p1Score > p2Score then
        winner, winnerScore = game.player1, p1Score
        loser, loserScore = game.player2, p2Score
    elseif p2Score > p1Score then
        winner, winnerScore = game.player2, p2Score
        loser, loserScore = game.player1, p1Score
    else
        winner = nil  -- Tie
    end

    -- Winner announcement
    local winnerText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    winnerText:SetPoint("TOP", title, "BOTTOM", 0, -25)
    if winner then
        winnerText:SetText("|TInterface\\Icons\\Achievement_Reputation_08:20:20|t " .. winner .. " WINS!")
        winnerText:SetTextColor(1, 0.84, 0)
    else
        winnerText:SetText("IT'S A TIE!")
        winnerText:SetTextColor(0.8, 0.8, 0.8)
    end

    -- Scores
    local scoreY = -120
    local p1Line = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p1Line:SetPoint("TOPLEFT", 40, scoreY)
    p1Line:SetText(game.player1 .. ":")
    p1Line:SetTextColor(0.2, 1, 0.2)

    local p1ScoreText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    p1ScoreText:SetPoint("TOPRIGHT", -40, scoreY)
    p1ScoreText:SetText(tostring(p1Score))
    p1ScoreText:SetTextColor(1, 0.84, 0)

    local p2Line = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p2Line:SetPoint("TOPLEFT", 40, scoreY - 25)
    p2Line:SetText(game.player2 .. ":")
    p2Line:SetTextColor(1, 0.2, 0.2)

    local p2ScoreText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    p2ScoreText:SetPoint("TOPRIGHT", -40, scoreY - 25)
    p2ScoreText:SetText(tostring(p2Score))
    p2ScoreText:SetTextColor(1, 0.84, 0)

    -- Divider
    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetSize(280, 2)
    divider:SetPoint("TOP", 0, -180)
    divider:SetVertexColor(0.6, 0.5, 0.4, 0.8)

    -- Statistics
    local statsY = -200
    local statsLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsLabel:SetPoint("TOPLEFT", 40, statsY)
    statsLabel:SetText("Words Played:")
    statsLabel:SetTextColor(0.4, 0.35, 0.3)

    local wordsCount = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wordsCount:SetPoint("TOPRIGHT", -40, statsY)
    wordsCount:SetText(tostring(#state.moveHistory))
    wordsCount:SetTextColor(0.3, 0.25, 0.2)

    local turnsLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnsLabel:SetPoint("TOPLEFT", 40, statsY - 20)
    turnsLabel:SetText("Total Turns:")
    turnsLabel:SetTextColor(0.4, 0.35, 0.3)

    local turnsText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnsText:SetPoint("TOPRIGHT", -40, statsY - 20)
    turnsText:SetText(tostring(state.turnCount))
    turnsText:SetTextColor(0.3, 0.25, 0.2)

    -- Find best word
    local bestWord, bestScore = "", 0
    for _, move in ipairs(state.moveHistory) do
        if move.score > bestScore then
            bestWord = move.word
            bestScore = move.score
        end
    end

    if bestWord ~= "" then
        local bestLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bestLabel:SetPoint("TOPLEFT", 40, statsY - 45)
        bestLabel:SetText("Best Word:")
        bestLabel:SetTextColor(0.4, 0.35, 0.3)

        local bestText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        bestText:SetPoint("TOPRIGHT", -40, statsY - 45)
        bestText:SetText(bestWord .. " (" .. bestScore .. " pts)")
        bestText:SetTextColor(1, 0.84, 0)
    end

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    closeBtn:SetSize(100, 30)
    closeBtn:SetPoint("BOTTOM", 0, 30)
    closeBtn:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    closeBtn:SetBackdropColor(0.3, 0.25, 0.4, 1)
    closeBtn:SetBackdropBorderColor(0.5, 0.4, 0.6, 1)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeBtnText:SetPoint("CENTER")
    closeBtnText:SetText("Close")
    closeBtnText:SetTextColor(1, 0.84, 0)

    closeBtn:SetScript("OnClick", function()
        overlay:Hide()
        if ui.window then
            ui.window:Hide()
        end
        if self.GameCore then
            self.GameCore:DestroyGame(gameId)
        end
    end)

    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.4, 0.35, 0.55, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.3, 0.25, 0.4, 1)
    end)

    -- Store reference for cleanup
    ui.gameOverOverlay = overlay
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

--============================================================
-- PERSISTENCE
--============================================================

--[[
    Save all active games to storage
]]
function WordGame:SaveAllGames()
    if not self.Persistence then return end

    for gameId, game in pairs(self.games) do
        -- Only save games that are in progress (not finished)
        local state = game.data and game.data.state
        if state and state.gameState ~= self.GAME_STATE.FINISHED then
            -- Determine opponent name
            local playerName = UnitName("player")
            local opponent = game.player1 == playerName and game.player2 or game.player1

            -- Don't save local solo games (player vs themselves)
            if opponent and not opponent:match("%(2%)$") then
                self.Persistence:SaveGame(opponent, game)
            end
        end
    end
end

--[[
    Save a specific game
    @param gameId string
]]
function WordGame:SaveGame(gameId)
    if not self.Persistence then return end

    local game = self.games[gameId]
    if not game then return end

    local playerName = UnitName("player")
    local opponent = game.player1 == playerName and game.player2 or game.player1

    -- Don't save local solo games
    if opponent and not opponent:match("%(2%)$") then
        self.Persistence:SaveGame(opponent, game)
        HopeAddon:Debug("WordGame: saved game vs", opponent)
    end
end

--[[
    Restore saved games from previous session
]]
function WordGame:RestoreSavedGames()
    if not self.Persistence then return end

    local savedGames = self.Persistence:GetAllGames()
    local count = 0

    for opponent, savedState in pairs(savedGames) do
        count = count + 1
    end

    if count > 0 then
        HopeAddon:Print("Words with WoW: " .. count .. " saved game(s) available.")
        HopeAddon:Print("Use /hope words list to see them, or /hope words <player> to continue.")
    end
end

--[[
    Resume a saved game with an opponent
    @param opponentName string
    @return string|nil - Game ID if resumed
]]
function WordGame:ResumeGame(opponentName)
    if not self.Persistence then
        return nil, "Persistence not available"
    end

    -- Check if game already active
    for gameId, game in pairs(self.games) do
        if game.player1 == opponentName or game.player2 == opponentName then
            -- Game already loaded, just show UI
            self:ShowUI(gameId)
            return gameId
        end
    end

    -- Load from storage
    local savedState = self.Persistence:LoadGame(opponentName)
    if not savedState then
        return nil, "No saved game found vs " .. opponentName
    end

    -- Create game through GameCore
    if not self.GameCore then
        return nil, "GameCore not available"
    end

    local mode = self.GameCore.GAME_MODE.REMOTE
    local gameId = self.GameCore:CreateGame(self.GameCore.GAME_TYPE.WORDS, mode, opponentName)

    local game = self.games[gameId]
    if not game then
        return nil, "Failed to create game"
    end

    -- Restore state from saved data
    game.player1 = savedState.player1
    game.player2 = savedState.player2
    game.createdAt = savedState.createdAt

    local state = game.data.state
    state.gameState = savedState.data.state.gameState
    state.scores = savedState.data.state.scores or {}
    state.moveHistory = savedState.data.state.moveHistory or {}
    state.consecutivePasses = savedState.data.state.consecutivePasses or 0
    state.turnCount = savedState.data.state.turnCount or 0

    -- Restore board from sparse format
    if savedState.savedBoard then
        self.Persistence:DeserializeBoard(savedState.savedBoard, state.board)
    end

    -- Clear row cache to force re-render
    state.rowCache = {}
    state.dirtyRows = {}
    for row = 1, state.board.size do
        state.dirtyRows[row] = true
    end

    -- Show UI
    self:ShowUI(gameId)

    -- Announce resumption
    local currentPlayer = self:GetCurrentPlayer(gameId)
    HopeAddon:Print("Resumed Words with WoW vs " .. opponentName)
    HopeAddon:Print(currentPlayer .. "'s turn. (Turn " .. state.turnCount .. ")")

    return gameId
end

--[[
    List all saved games
]]
function WordGame:ListSavedGames()
    if not self.Persistence then
        HopeAddon:Print("No persistence module available.")
        return
    end

    local savedGames = self.Persistence:GetAllGames()
    local count = 0

    HopeAddon:Print("=== Words with WoW Saved Games ===")

    for opponent, savedState in pairs(savedGames) do
        count = count + 1
        local myScore = savedState.scores[UnitName("player")] or 0
        local theirScore = savedState.scores[opponent] or 0
        local isMyTurn = self.Persistence:IsMyTurn(savedState)
        local turnIndicator = isMyTurn and "|cFF00FF00YOUR TURN|r" or "|cFFFFFF00waiting|r"

        HopeAddon:Print(string.format(
            "%d. vs %s - Score: %d-%d - Turn %d - %s",
            count, opponent, myScore, theirScore, savedState.turnCount or 0, turnIndicator
        ))
    end

    if count == 0 then
        HopeAddon:Print("No saved games.")
    else
        HopeAddon:Print("Use /hope words <player> to continue a game.")
    end
end

--[[
    Forfeit a game against an opponent
    @param opponentName string
]]
function WordGame:ForfeitGame(opponentName)
    if not self.Persistence then return end

    -- Check if game is active
    for gameId, game in pairs(self.games) do
        if game.player1 == opponentName or game.player2 == opponentName then
            -- End the active game
            if self.GameCore then
                self.GameCore:EndGame(gameId, "forfeit")
            end
        end
    end

    -- Clear from storage
    self.Persistence:ClearGame(opponentName)

    HopeAddon:Print("Forfeited Words game vs " .. opponentName)
end

-- Register with addon
HopeAddon:RegisterModule("WordGame", WordGame)
HopeAddon.WordGame = WordGame

HopeAddon:Debug("WordGame module loaded")
