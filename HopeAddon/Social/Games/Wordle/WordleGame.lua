--[[
    HopeAddon Wordle - Core Game Logic
    WoW-themed Wordle game with practice and multiplayer modes
]]

local WordleGame = {}

--============================================================
-- CONSTANTS
--============================================================

WordleGame.WORD_LENGTH = 5
WordleGame.MAX_GUESSES = 6

-- Game modes
WordleGame.MODE = {
    PRACTICE = "practice",      -- vs AI (random word)
    CHALLENGE = "challenge",    -- vs Player (one picks, one guesses)
}

-- Game states
WordleGame.STATE = {
    IDLE = "idle",              -- No game active
    PICKING = "picking",        -- Challenger picking secret word
    WAITING = "waiting",        -- Waiting for opponent
    PLAYING = "playing",        -- Game in progress (guessing)
    ENDED = "ended",            -- Game finished
}

-- Result types for each letter
WordleGame.RESULT = {
    CORRECT = "correct",        -- Green - right letter, right position
    PRESENT = "present",        -- Yellow - right letter, wrong position
    ABSENT = "absent",          -- Grey - letter not in word
}

--============================================================
-- MODULE STATE
--============================================================

-- Active games by gameId
WordleGame.games = {}

-- Current active game (for UI reference)
WordleGame.currentGameId = nil

-- Pending challenges
WordleGame.pendingChallenges = {}   -- [playerName] = { gameId, timestamp }
WordleGame.receivedChallenges = {}  -- [playerName] = { gameId, timestamp, secretWordHash }

--============================================================
-- LIFECYCLE
--============================================================

function WordleGame:OnInitialize()
    HopeAddon:Debug("WordleGame initializing...")
end

function WordleGame:OnEnable()
    -- Register with GameComms for multiplayer
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        -- Register handlers for Wordle-specific messages
        GameComms:RegisterHandler("WORDLE", "CHALLENGE", function(sender, gameId, data)
            self:HandleChallenge(sender, gameId, data)
        end)
        GameComms:RegisterHandler("WORDLE", "ACCEPT", function(sender, gameId, data)
            self:HandleAccept(sender, gameId, data)
        end)
        GameComms:RegisterHandler("WORDLE", "DECLINE", function(sender, gameId, data)
            self:HandleDecline(sender, gameId, data)
        end)
        GameComms:RegisterHandler("WORDLE", "GUESS", function(sender, gameId, data)
            self:HandleGuess(sender, gameId, data)
        end)
        GameComms:RegisterHandler("WORDLE", "RESULT", function(sender, gameId, data)
            self:HandleResult(sender, gameId, data)
        end)
        GameComms:RegisterHandler("WORDLE", "REVEAL", function(sender, gameId, data)
            self:HandleReveal(sender, gameId, data)
        end)
    end

    -- Periodic cleanup of stale challenge tables (entries can persist if callbacks fail)
    self.challengeCleanupTicker = HopeAddon.Timer:NewTicker(120, function()
        local now = time()
        for playerName, challenge in pairs(self.pendingChallenges) do
            if now - challenge.timestamp > 120 then
                self.pendingChallenges[playerName] = nil
            end
        end
        for playerName, challenge in pairs(self.receivedChallenges) do
            if now - challenge.timestamp > 120 then
                self.receivedChallenges[playerName] = nil
            end
        end
    end)

    HopeAddon:Debug("WordleGame enabled")
end

function WordleGame:OnDisable()
    -- Cancel challenge cleanup ticker
    if self.challengeCleanupTicker then
        self.challengeCleanupTicker:Cancel()
        self.challengeCleanupTicker = nil
    end

    -- Cleanup
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:UnregisterHandler("WORDLE", "CHALLENGE")
        GameComms:UnregisterHandler("WORDLE", "ACCEPT")
        GameComms:UnregisterHandler("WORDLE", "DECLINE")
        GameComms:UnregisterHandler("WORDLE", "GUESS")
        GameComms:UnregisterHandler("WORDLE", "RESULT")
        GameComms:UnregisterHandler("WORDLE", "REVEAL")
    end

    -- Close any UI
    if self.CloseUI then
        self:CloseUI()
    end

    wipe(self.games)
    wipe(self.pendingChallenges)
    wipe(self.receivedChallenges)
end

--============================================================
-- GAME CREATION & MANAGEMENT
--============================================================

--[[
    Create a new game instance
    @param mode string - "practice" or "challenge"
    @param opponent string|nil - Opponent name (nil for practice)
    @param secretWord string|nil - Secret word (nil for random)
    @return string - Game ID
]]
function WordleGame:CreateGame(mode, opponent, secretWord)
    local gameId = self:GenerateGameId()
    local playerName = UnitName("player")

    -- Get secret word
    local WordleWords = HopeAddon.WordleWords
    if not secretWord then
        secretWord = WordleWords:GetRandomWord()
    end
    secretWord = secretWord:upper()

    -- Validate word
    if #secretWord ~= self.WORD_LENGTH or not WordleWords:IsValidWord(secretWord) then
        HopeAddon:Print("|cFFFF0000Error:|r Invalid word - must be 5 letters and in dictionary")
        return nil
    end

    local game = {
        id = gameId,
        mode = mode,
        state = self.STATE.PLAYING,
        secretWord = secretWord,
        guesses = {},               -- Array of { word, results }
        currentInput = "",          -- Current typing buffer
        player = playerName,
        opponent = opponent,
        winner = nil,
        startTime = GetTime(),
        endTime = nil,
        -- Keyboard state (tracks which letters have been used)
        letterStates = {},          -- [letter] = "correct"|"present"|"absent"
    }

    self.games[gameId] = game
    self.currentGameId = gameId

    HopeAddon:Debug("Created Wordle game:", gameId, "mode:", mode, "word:", secretWord)

    return gameId
end

--[[
    Generate unique game ID
    @return string
]]
function WordleGame:GenerateGameId()
    return string.format("WORDLE_%s_%d", UnitName("player"), GetTime() * 1000)
end

--[[
    Get a game by ID
    @param gameId string
    @return table|nil
]]
function WordleGame:GetGame(gameId)
    return self.games[gameId]
end

--[[
    Get current active game
    @return table|nil
]]
function WordleGame:GetCurrentGame()
    if self.currentGameId then
        return self.games[self.currentGameId]
    end
    return nil
end

--[[
    Get all active games
    @return table
]]
function WordleGame:GetActiveGames()
    return self.games
end

--============================================================
-- GUESS EVALUATION (CORE WORDLE ALGORITHM)
--============================================================

--[[
    Evaluate a guess against the secret word
    Uses standard Wordle algorithm:
    1. First pass: mark correct (green) letters
    2. Second pass: mark present (yellow) or absent (grey)

    @param guess string - 5-letter guess
    @param secret string - 5-letter secret word
    @return table - Array of result types for each position
]]
function WordleGame:EvaluateGuess(guess, secret)
    local result = {}
    local secretCounts = {}

    guess = guess:upper()
    secret = secret:upper()

    -- Count letters in secret word
    for i = 1, #secret do
        local letter = secret:sub(i, i)
        secretCounts[letter] = (secretCounts[letter] or 0) + 1
    end

    -- First pass: mark correct positions (green)
    for i = 1, #guess do
        local guessLetter = guess:sub(i, i)
        local secretLetter = secret:sub(i, i)
        if guessLetter == secretLetter then
            result[i] = self.RESULT.CORRECT
            secretCounts[guessLetter] = secretCounts[guessLetter] - 1
        end
    end

    -- Second pass: mark present (yellow) or absent (grey)
    for i = 1, #guess do
        if not result[i] then
            local guessLetter = guess:sub(i, i)
            if secretCounts[guessLetter] and secretCounts[guessLetter] > 0 then
                result[i] = self.RESULT.PRESENT
                secretCounts[guessLetter] = secretCounts[guessLetter] - 1
            else
                result[i] = self.RESULT.ABSENT
            end
        end
    end

    return result
end

--============================================================
-- GAME ACTIONS
--============================================================

--[[
    Submit a guess
    @param gameId string - Game ID
    @param guess string - 5-letter word
    @return boolean, string - Success, status message
]]
function WordleGame:SubmitGuess(gameId, guess)
    local game = self.games[gameId]
    if not game then
        return false, "Game not found"
    end

    if game.state ~= self.STATE.PLAYING then
        return false, "Game is not active"
    end

    -- Prevent submitting during reveal animation
    if game.isRevealing then
        return false, "Wait for reveal"
    end

    guess = guess:upper()

    -- Validate length
    if #guess ~= self.WORD_LENGTH then
        -- Shake row for insufficient letters
        if self.ShakeCurrentRow then
            self:ShakeCurrentRow(gameId)
        end
        return false, "Not enough letters"
    end

    -- Validate word exists in dictionary
    local WordleWords = HopeAddon.WordleWords
    if not WordleWords:IsValidWord(guess) then
        -- Shake row for invalid word
        if self.ShakeCurrentRow then
            self:ShakeCurrentRow(gameId)
        end
        return false, "Not in word list"
    end

    -- For challenge mode as guesser: send guess to opponent, don't evaluate locally
    if game.isGuesser and game.mode == self.MODE.CHALLENGE then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms and game.opponent then
            GameComms:SendGameMessage(game.opponent, "GUESS", "WORDLE", game.remoteGameId or game.id, guess)
        end
        return true, "Guess sent"
    end

    -- Evaluate the guess (local mode only)
    local result = self:EvaluateGuess(guess, game.secretWord)

    -- Store the guess
    local guessRow = #game.guesses + 1
    table.insert(game.guesses, {
        word = guess,
        result = result,
    })

    -- Update keyboard letter states
    for i = 1, #guess do
        local letter = guess:sub(i, i)
        local letterResult = result[i]

        -- Only upgrade letter state (absent -> present -> correct)
        local currentState = game.letterStates[letter]
        if not currentState then
            game.letterStates[letter] = letterResult
        elseif currentState == self.RESULT.ABSENT then
            game.letterStates[letter] = letterResult
        elseif currentState == self.RESULT.PRESENT and letterResult == self.RESULT.CORRECT then
            game.letterStates[letter] = letterResult
        end
    end

    -- Clear input buffer
    game.currentInput = ""

    -- Determine outcome before animation
    local isWin = guess == game.secretWord
    local isLose = not isWin and #game.guesses >= self.MAX_GUESSES

    -- Mark as revealing (prevent double-submit)
    game.isRevealing = true

    -- Animate the reveal, then handle outcome
    if self.RevealGuess then
        self:RevealGuess(gameId, guessRow, result, function()
            -- Animation complete - now handle outcome
            game.isRevealing = false

            if isWin then
                game.state = self.STATE.ENDED
                game.endTime = GetTime()
                game.winner = game.player

                -- Record statistics
                self:RecordGameResult(game)

                -- Bounce winning row, then celebrate
                if self.BounceWinningRow then
                    self:BounceWinningRow(gameId, guessRow, function()
                        -- Show celebration effect
                        if HopeAddon.Effects and self.ui and self.ui.frame then
                            HopeAddon.Effects:Celebrate(self.ui.frame, 2)
                        end
                    end)
                end

                -- Play victory sound after reveal
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayAchievement()
                end

                -- Show win message based on guess count (standard Wordle)
                local C = HopeAddon.Constants
                local winMessages = C and C.WORDLE and C.WORDLE.WIN_MESSAGES or {
                    [1] = "Genius!",
                    [2] = "Magnificent!",
                    [3] = "Impressive!",
                    [4] = "Splendid!",
                    [5] = "Great!",
                    [6] = "Phew!",
                }
                local winMessage = winMessages[#game.guesses] or "Nice!"
                self:ShowFloatingMessage(winMessage, false)

                -- Update status text
                if self.UpdateStatusText then
                    self:UpdateStatusText(gameId)
                end

            elseif isLose then
                game.state = self.STATE.ENDED
                game.endTime = GetTime()
                game.winner = "word"

                -- Record statistics
                self:RecordGameResult(game)

                -- Play failure sound
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayError()
                end

                -- Show the secret word
                self:ShowFloatingMessage(game.secretWord, true)

                -- Update status text
                if self.UpdateStatusText then
                    self:UpdateStatusText(gameId)
                end
            else
                -- Game continues - update keyboard colors
                if self.UpdateKeyboardColors then
                    self:UpdateKeyboardColors(gameId)
                end
            end
        end)
    else
        -- Fallback: no animation, direct update
        game.isRevealing = false

        if isWin then
            game.state = self.STATE.ENDED
            game.endTime = GetTime()
            game.winner = game.player
            self:RecordGameResult(game)
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayAchievement()
            end
        elseif isLose then
            game.state = self.STATE.ENDED
            game.endTime = GetTime()
            game.winner = "word"
            self:RecordGameResult(game)
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayError()
            end
        else
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
        end

        if self.UpdateUI then
            self:UpdateUI(gameId)
        end
    end

    return true, isWin and "win" or (isLose and "lose" or "continue")
end

--[[
    Add a letter to current input
    @param gameId string
    @param letter string - Single letter A-Z
]]
function WordleGame:AddLetter(gameId, letter)
    local game = self.games[gameId]
    if not game or game.state ~= self.STATE.PLAYING then
        return
    end

    if #game.currentInput >= self.WORD_LENGTH then
        return
    end

    letter = letter:upper()
    if letter:match("^[A-Z]$") then
        game.currentInput = game.currentInput .. letter

        -- Update UI
        if self.UpdateUI then
            self:UpdateUI(gameId)
        end

        -- Typing pop animation for the newly added letter
        local currentRow = #game.guesses + 1
        local col = #game.currentInput
        if self.AnimateLetterInput then
            self:AnimateLetterInput(currentRow, col)
        end
    end
end

--[[
    Remove last letter from current input (backspace)
    @param gameId string
]]
function WordleGame:RemoveLetter(gameId)
    local game = self.games[gameId]
    if not game or game.state ~= self.STATE.PLAYING then
        return
    end

    if #game.currentInput > 0 then
        game.currentInput = game.currentInput:sub(1, -2)

        -- Update UI
        if self.UpdateUI then
            self:UpdateUI(gameId)
        end
    end
end

--[[
    Submit current input as guess
    @param gameId string
    @return boolean, string
]]
function WordleGame:SubmitCurrentInput(gameId)
    local game = self.games[gameId]
    if not game or game.state ~= self.STATE.PLAYING then
        return false, "Game not active"
    end

    if #game.currentInput ~= self.WORD_LENGTH then
        return false, "Enter " .. self.WORD_LENGTH .. " letters"
    end

    return self:SubmitGuess(gameId, game.currentInput)
end

--============================================================
-- PRACTICE MODE
--============================================================

--[[
    Start a practice game (vs AI with random word)
]]
function WordleGame:StartPractice()
    -- Close any existing game
    if self.currentGameId then
        self:EndGame(self.currentGameId, "new_game")
    end

    local gameId = self:CreateGame(self.MODE.PRACTICE, nil, nil)
    if gameId then
        HopeAddon:Print("|cFF00FF00WoWdle|r - Guess the 5-letter WoW word!")
        HopeAddon:Print("You have " .. self.MAX_GUESSES .. " attempts.")

        -- Show UI
        if self.ShowUI then
            self:ShowUI(gameId)
        end
    end

    return gameId
end

--============================================================
-- MULTIPLAYER (via GameComms)
--============================================================

--[[
    Send a challenge to another player
    @param targetPlayer string - Target player name
]]
function WordleGame:SendChallenge(targetPlayer)
    if not targetPlayer then
        HopeAddon:Print("Usage: /hope wordle <player>")
        return false
    end

    local playerName = UnitName("player")
    if targetPlayer == playerName then
        HopeAddon:Print("You can't challenge yourself!")
        return false
    end

    -- Check if already have pending challenge
    if self.pendingChallenges[targetPlayer] then
        HopeAddon:Print("Already have a pending challenge to " .. targetPlayer)
        return false
    end

    -- Check if target is a Fellow Traveler
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers or not FellowTravelers:IsFellow(targetPlayer) then
        HopeAddon:Print(targetPlayer .. " is not a Fellow Traveler (they need the addon)")
        return false
    end

    -- Show word picker UI
    self:ShowWordPicker(targetPlayer)

    return true
end

--[[
    Show word picker popup for challenger
    @param targetPlayer string
]]
function WordleGame:ShowWordPicker(targetPlayer)
    -- Create simple popup to pick word
    StaticPopupDialogs["HOPE_WORDLE_PICK_WORD"] = {
        text = "Pick a 5-letter WoW word for " .. targetPlayer .. " to guess:",
        button1 = "Send Challenge",
        button2 = "Cancel",
        hasEditBox = true,
        maxLetters = 5,
        OnAccept = function(self)
            local word = self.editBox:GetText():upper()
            local WordleWords = HopeAddon.WordleWords
            if #word == 5 and WordleWords:IsValidWord(word) then
                WordleGame:SendChallengeWithWord(targetPlayer, word)
            else
                HopeAddon:Print("|cFFFF0000Invalid word!|r Must be exactly 5 letters and in the WoW dictionary.")
            end
        end,
        OnShow = function(self)
            self.editBox:SetText("")
            self.editBox:SetFocus()
        end,
        EditBoxOnEnterPressed = function(self)
            self:GetParent().button1:Click()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopup_Show("HOPE_WORDLE_PICK_WORD")
end

--[[
    Send challenge with chosen word
    @param targetPlayer string
    @param word string
]]
function WordleGame:SendChallengeWithWord(targetPlayer, word)
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then
        HopeAddon:Print("GameComms module not available!")
        return
    end

    local gameId = self:GenerateGameId()

    -- Store pending challenge with the secret word
    self.pendingChallenges[targetPlayer] = {
        gameId = gameId,
        secretWord = word,
        timestamp = GetTime(),
    }

    -- Send challenge (hash the word for security, reveal later)
    local wordHash = self:HashWord(word)
    GameComms:SendGameMessage(targetPlayer, "CHALLENGE", "WORDLE", gameId, wordHash)

    HopeAddon:Print("Sent Wordle challenge to " .. targetPlayer)

    -- Set timeout
    HopeAddon.Timer:After(60, function()
        if self.pendingChallenges[targetPlayer] and
           self.pendingChallenges[targetPlayer].gameId == gameId then
            self.pendingChallenges[targetPlayer] = nil
            HopeAddon:Print("Wordle challenge to " .. targetPlayer .. " expired")
        end
    end)
end

--[[
    Simple hash for word (not cryptographic, just for basic verification)
    @param word string
    @return string
]]
function WordleGame:HashWord(word)
    local hash = 0
    for i = 1, #word do
        hash = hash + word:byte(i) * i
    end
    return tostring(hash)
end

--[[
    Accept a received challenge
    @param senderName string
]]
function WordleGame:AcceptChallenge(senderName)
    local challenge = self.receivedChallenges[senderName]
    if not challenge then
        HopeAddon:Print("No pending Wordle challenge from " .. (senderName or "anyone"))
        return
    end

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:SendGameMessage(senderName, "ACCEPT", "WORDLE", challenge.gameId, "")
    end

    -- Create game (we don't know the word yet - opponent will reveal after each guess)
    self.receivedChallenges[senderName] = nil

    -- Wait for opponent to start sending results
    HopeAddon:Print("Accepted Wordle challenge from " .. senderName)
    HopeAddon:Print("Waiting for game to start...")

    -- Create a game shell (guesser doesn't know secret word - guesses are sent to opponent for evaluation)
    local gameId = self:CreateGame(self.MODE.CHALLENGE, senderName, "XXXXX") -- Placeholder: word revealed via HandleReveal
    if gameId then
        local game = self.games[gameId]
        game.state = self.STATE.WAITING
        game.isGuesser = true
        game.remoteGameId = challenge.gameId

        -- Show UI
        if self.ShowUI then
            self:ShowUI(gameId)
        end
    end
end

--[[
    Decline a received challenge
    @param senderName string
]]
function WordleGame:DeclineChallenge(senderName)
    local challenge = self.receivedChallenges[senderName]
    if not challenge then
        return
    end

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:SendGameMessage(senderName, "DECLINE", "WORDLE", challenge.gameId, "")
    end

    self.receivedChallenges[senderName] = nil
    HopeAddon:Print("Declined Wordle challenge from " .. senderName)
end

--[[
    Check if there are any pending challenges
    @return boolean
]]
function WordleGame:HasPendingChallenges()
    for _ in pairs(self.receivedChallenges) do
        return true
    end
    return false
end

--[[
    Get pending challenges
    @return table
]]
function WordleGame:GetPendingChallenges()
    return self.receivedChallenges
end

--============================================================
-- NETWORK MESSAGE HANDLERS
--============================================================

function WordleGame:HandleChallenge(sender, gameId, data)
    -- Store received challenge
    self.receivedChallenges[sender] = {
        gameId = gameId,
        wordHash = data,
        timestamp = GetTime(),
    }

    HopeAddon:Print("|cFF00FF00[Wordle]|r " .. sender .. " challenges you to Wordle!")
    HopeAddon:Print("Type |cFFFFFF00/hope wordle accept|r or |cFFFFFF00/hope wordle decline|r")

    -- Play notification sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end
end

function WordleGame:HandleAccept(sender, gameId, data)
    local challenge = self.pendingChallenges[sender]
    if not challenge or challenge.gameId ~= gameId then
        return
    end

    HopeAddon:Print(sender .. " accepted your Wordle challenge!")

    -- Create local game as word-picker (we know the word)
    local localGameId = self:CreateGame(self.MODE.CHALLENGE, sender, challenge.secretWord)
    if localGameId then
        local game = self.games[localGameId]
        game.isGuesser = false
        game.remoteGameId = gameId
        game.state = self.STATE.WAITING -- Wait for their guesses

        -- We don't show UI - we just wait for their guesses
        HopeAddon:Print("Waiting for " .. sender .. " to guess your word...")
    end

    self.pendingChallenges[sender] = nil
end

function WordleGame:HandleDecline(sender, gameId, data)
    local challenge = self.pendingChallenges[sender]
    if not challenge or challenge.gameId ~= gameId then
        return
    end

    HopeAddon:Print(sender .. " declined your Wordle challenge")
    self.pendingChallenges[sender] = nil
end

function WordleGame:HandleGuess(sender, gameId, data)
    -- Find our game with this opponent
    local localGame = nil
    for id, game in pairs(self.games) do
        if game.opponent == sender and game.mode == self.MODE.CHALLENGE then
            localGame = game
            break
        end
    end

    if not localGame or localGame.isGuesser then
        return
    end

    -- Evaluate their guess
    local guess = data:upper()
    local result = self:EvaluateGuess(guess, localGame.secretWord)

    -- Send result back
    local resultStr = ""
    for i, r in ipairs(result) do
        if r == self.RESULT.CORRECT then
            resultStr = resultStr .. "G"
        elseif r == self.RESULT.PRESENT then
            resultStr = resultStr .. "Y"
        else
            resultStr = resultStr .. "X"
        end
    end

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:SendGameMessage(sender, "RESULT", "WORDLE", gameId, guess .. ":" .. resultStr)
    end

    -- Check if they won
    if guess == localGame.secretWord then
        HopeAddon:Print(sender .. " guessed your word '" .. localGame.secretWord .. "' correctly!")
        self:EndGame(localGame.id, "opponent_win")
    elseif #localGame.guesses >= self.MAX_GUESSES then
        -- Reveal word
        if GameComms then
            GameComms:SendGameMessage(sender, "REVEAL", "WORDLE", gameId, localGame.secretWord)
        end
        HopeAddon:Print(sender .. " failed to guess your word '" .. localGame.secretWord .. "'!")
        self:EndGame(localGame.id, "opponent_lose")
    end
end

function WordleGame:HandleResult(sender, gameId, data)
    -- Find our game as guesser
    local localGame = nil
    for id, game in pairs(self.games) do
        if game.opponent == sender and game.isGuesser then
            localGame = game
            break
        end
    end

    if not localGame then
        return
    end

    -- Parse result: "GUESS:GGYXX"
    local guess, resultStr = strsplit(":", data)
    local result = {}
    for i = 1, #resultStr do
        local c = resultStr:sub(i, i)
        if c == "G" then
            result[i] = self.RESULT.CORRECT
        elseif c == "Y" then
            result[i] = self.RESULT.PRESENT
        else
            result[i] = self.RESULT.ABSENT
        end
    end

    -- Store the guess
    table.insert(localGame.guesses, {
        word = guess,
        result = result,
    })

    -- Update UI
    if self.UpdateUI then
        self:UpdateUI(localGame.id)
    end

    -- Check win
    if resultStr == "GGGGG" then
        localGame.state = self.STATE.ENDED
        localGame.winner = localGame.player
        HopeAddon:Print("|cFF00FF00You guessed the word!|r")
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayAchievement()
        end
    elseif #localGame.guesses >= self.MAX_GUESSES then
        localGame.state = self.STATE.ENDED
        -- Word will be revealed by REVEAL message
    end
end

function WordleGame:HandleReveal(sender, gameId, data)
    -- Find our game
    local localGame = nil
    for id, game in pairs(self.games) do
        if game.opponent == sender and game.isGuesser then
            localGame = game
            break
        end
    end

    if not localGame then
        return
    end

    localGame.secretWord = data:upper()
    localGame.state = self.STATE.ENDED
    localGame.winner = "word"

    HopeAddon:Print("|cFFFF0000The word was:|r " .. localGame.secretWord)

    -- Update UI
    if self.UpdateUI then
        self:UpdateUI(localGame.id)
    end
end

--============================================================
-- GAME END & CLEANUP
--============================================================

--[[
    End a game
    @param gameId string
    @param reason string|nil
]]
function WordleGame:EndGame(gameId, reason)
    local game = self.games[gameId]
    if not game then
        return
    end

    game.state = self.STATE.ENDED
    game.endTime = GetTime()

    HopeAddon:Debug("Wordle game ended:", gameId, "reason:", reason or "normal")

    -- Don't destroy immediately - let UI show results
end

--[[
    Close/destroy a game
    @param gameId string
]]
function WordleGame:CloseGame(gameId)
    local game = self.games[gameId]
    if not game then
        return
    end

    -- Close UI if this is current game
    if self.currentGameId == gameId then
        if self.CloseUI then
            self:CloseUI()
        end
        self.currentGameId = nil
    end

    self.games[gameId] = nil
end

--============================================================
-- STATISTICS TRACKING
--============================================================

--[[
    Record game result to charDb statistics
    @param game table - Completed game
]]
function WordleGame:RecordGameResult(game)
    if not game or game.state ~= self.STATE.ENDED then
        return
    end

    -- Ensure wordle data structure exists
    local charDb = HopeAddon.charDb
    if not charDb then return end

    charDb.wordle = charDb.wordle or {
        stats = {
            gamesPlayed = 0,
            gamesWon = 0,
            currentStreak = 0,
            maxStreak = 0,
            guessDistribution = { 0, 0, 0, 0, 0, 0 },
        },
        lastPlayed = nil,
    }

    local stats = charDb.wordle.stats

    -- Increment games played
    stats.gamesPlayed = stats.gamesPlayed + 1

    -- Check win/loss
    local won = game.winner == game.player

    if won then
        stats.gamesWon = stats.gamesWon + 1
        stats.currentStreak = stats.currentStreak + 1
        stats.maxStreak = math.max(stats.maxStreak, stats.currentStreak)

        -- Update guess distribution (guesses = number of attempts)
        local attempts = #game.guesses
        if attempts >= 1 and attempts <= 6 then
            stats.guessDistribution[attempts] = stats.guessDistribution[attempts] + 1
        end
    else
        -- Lost - reset streak
        stats.currentStreak = 0
    end

    charDb.wordle.lastPlayed = time()

    HopeAddon:Debug("Wordle stats updated - Won:", won, "Games:", stats.gamesPlayed, "Streak:", stats.currentStreak)
end

--[[
    Get statistics summary
    @return table|nil
]]
function WordleGame:GetStatistics()
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.wordle then
        return nil
    end

    local stats = charDb.wordle.stats
    local winRate = stats.gamesPlayed > 0 and (stats.gamesWon / stats.gamesPlayed * 100) or 0

    return {
        gamesPlayed = stats.gamesPlayed,
        gamesWon = stats.gamesWon,
        winRate = winRate,
        currentStreak = stats.currentStreak,
        maxStreak = stats.maxStreak,
        guessDistribution = stats.guessDistribution,
    }
end

--[[
    Print statistics to chat
]]
function WordleGame:PrintStatistics()
    local stats = self:GetStatistics()
    if not stats then
        HopeAddon:Print("|cFFFFD700WoWdle Statistics:|r No games played yet!")
        return
    end

    HopeAddon:Print("|cFFFFD700=== WoWdle Statistics ===|r")
    HopeAddon:Print(string.format("Games Played: %d | Won: %d (%.0f%%)",
        stats.gamesPlayed, stats.gamesWon, stats.winRate))
    HopeAddon:Print(string.format("Current Streak: %d | Best Streak: %d",
        stats.currentStreak, stats.maxStreak))

    -- Show guess distribution
    local distStr = ""
    for i = 1, 6 do
        distStr = distStr .. i .. ":" .. stats.guessDistribution[i] .. " "
    end
    HopeAddon:Print("Guess Distribution: " .. distStr)
end

--============================================================
-- HELPER FUNCTIONS
--============================================================

--[[
    Format results as emoji string (for sharing)
    @param game table
    @return string
]]
function WordleGame:FormatResultsEmoji(game)
    if not game then
        return ""
    end

    local lines = {}
    for _, guess in ipairs(game.guesses) do
        local line = ""
        for _, r in ipairs(guess.result) do
            if r == self.RESULT.CORRECT then
                line = line .. "|cFF6AAA64G|r"  -- Green
            elseif r == self.RESULT.PRESENT then
                line = line .. "|cFFC9B458Y|r"  -- Yellow
            else
                line = line .. "|cFF787C7EX|r"  -- Grey
            end
        end
        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end

--[[
    Get game statistics for a completed game
    @param game table
    @return table
]]
function WordleGame:GetGameStats(game)
    if not game then
        return nil
    end

    return {
        attempts = #game.guesses,
        won = game.winner == game.player,
        secretWord = game.state == self.STATE.ENDED and game.secretWord or nil,
        duration = game.endTime and (game.endTime - game.startTime) or nil,
    }
end

--============================================================
-- HINT SYSTEM
--============================================================

--[[
    Use a hint - reveals one unrevealed correct letter position
    @param gameId string
    @return boolean success
]]
function WordleGame:UseHint(gameId)
    local game = self.games[gameId]
    if not game or game.state ~= self.STATE.PLAYING then
        self:ShowFloatingMessage("No active game", true)
        return false
    end

    -- Track hints used (max 2 per game)
    game.hintsUsed = (game.hintsUsed or 0) + 1

    if game.hintsUsed > 2 then
        game.hintsUsed = 2  -- Cap at 2
        self:ShowFloatingMessage("No more hints!", true)
        return false
    end

    -- Find a letter position not yet revealed correctly
    local secretWord = game.secretWord
    local revealedPositions = {}

    -- Check which positions are already known correct from previous guesses
    for _, guess in ipairs(game.guesses) do
        for i, result in ipairs(guess.result) do
            if result == self.RESULT.CORRECT then
                revealedPositions[i] = true
            end
        end
    end

    -- Find unrevealed positions
    local hintPositions = {}
    for i = 1, self.WORD_LENGTH do
        if not revealedPositions[i] then
            table.insert(hintPositions, i)
        end
    end

    if #hintPositions == 0 then
        self:ShowFloatingMessage("All letters known!", false)
        return false
    end

    -- Pick random unrevealed position
    local pos = hintPositions[math.random(#hintPositions)]
    local letter = secretWord:sub(pos, pos)

    -- Show hint message
    self:ShowFloatingMessage("Position " .. pos .. " is '" .. letter .. "'", false)

    -- Play click sound for feedback
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    -- Update hint button state
    if self.UpdateHintButton then
        self:UpdateHintButton()
    end

    return true
end

--============================================================
-- PUBLIC API FOR SLASH COMMANDS
--============================================================

--[[
    Start a Wordle game (called from slash command)
    @param targetPlayer string|nil - nil for practice, name for challenge
]]
function WordleGame:StartGame(targetPlayer)
    if not targetPlayer or targetPlayer == "" then
        return self:StartPractice()
    else
        return self:SendChallenge(targetPlayer)
    end
end

-- Register module
HopeAddon:RegisterModule("WordleGame", WordleGame)
HopeAddon.WordleGame = WordleGame

-- Register with GameCore
local GameCore = HopeAddon:GetModule("GameCore")
if GameCore then
    GameCore.GAME_TYPE.WORDLE = "WORDLE"
    GameCore:RegisterGame("WORDLE", WordleGame)
end

HopeAddon:Debug("WordleGame module loaded")
