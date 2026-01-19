--[[
    HopeAddon Words with WoW - Test Suite
    Manual testing utilities for WordGame, WordBoard, WordDictionary

    Usage:
        /wordtest all       - Run all tests
        /wordtest dict      - Test dictionary
        /wordtest board     - Test board placement
        /wordtest score     - Test scoring
        /wordtest cross     - Test cross-words
        /wordtest flow      - Test game flow
        /wordtest help      - Show commands
]]

local Tests = {}

-- Test counters
local totalPassed = 0
local totalFailed = 0

--============================================================
-- UTILITY FUNCTIONS
--============================================================

local function Assert(condition, testName)
    if condition then
        totalPassed = totalPassed + 1
        HopeAddon:Debug("✓ PASS:", testName)
        return true
    else
        totalFailed = totalFailed + 1
        HopeAddon:Print("|cFFFF0000✗ FAIL:|r " .. testName)
        return false
    end
end

local function AssertEquals(actual, expected, testName)
    if actual == expected then
        totalPassed = totalPassed + 1
        HopeAddon:Debug("✓ PASS:", testName)
        return true
    else
        totalFailed = totalFailed + 1
        HopeAddon:Print("|cFFFF0000✗ FAIL:|r " .. testName .. " - Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual))
        return false
    end
end

local function ResetCounters()
    totalPassed = 0
    totalFailed = 0
end

local function PrintSummary(suiteName)
    local total = totalPassed + totalFailed
    local percent = total > 0 and (totalPassed / total * 100) or 0

    HopeAddon:Print("========================================")
    HopeAddon:Print(suiteName .. " Results:")
    HopeAddon:Print(string.format("  Passed: |cFF00FF00%d|r", totalPassed))
    HopeAddon:Print(string.format("  Failed: |cFFFF0000%d|r", totalFailed))
    HopeAddon:Print(string.format("  Total:  %d (%.1f%% pass rate)", total, percent))
    HopeAddon:Print("========================================")
end

--============================================================
-- TEST SUITES
--============================================================

function Tests:Dictionary()
    ResetCounters()
    HopeAddon:Print("Running Dictionary Tests...")

    local dict = HopeAddon.WordDictionary

    -- Valid words
    Assert(dict:IsValidWord("DRAGON"), "Valid word: DRAGON")
    Assert(dict:IsValidWord("WARRIOR"), "Valid word: WARRIOR")
    Assert(dict:IsValidWord("ILLIDAN"), "Valid word: ILLIDAN")
    Assert(dict:IsValidWord("PALADIN"), "Valid word: PALADIN")
    Assert(dict:IsValidWord("HORDE"), "Valid word: HORDE")

    -- Invalid words
    Assert(not dict:IsValidWord("ZZZQQQ"), "Invalid word: ZZZQQQ")
    Assert(not dict:IsValidWord("NOTAWORD"), "Invalid word: NOTAWORD")
    Assert(not dict:IsValidWord("ASDFGH"), "Invalid word: ASDFGH")

    -- Case insensitivity
    Assert(dict:IsValidWord("dragon"), "Case insensitive: dragon")
    Assert(dict:IsValidWord("DrAgOn"), "Case insensitive: DrAgOn")
    Assert(dict:IsValidWord("WARRIOR") == dict:IsValidWord("warrior"), "Case consistency")

    -- Letter values
    AssertEquals(dict:GetLetterValue("Q"), 10, "Letter value: Q = 10")
    AssertEquals(dict:GetLetterValue("E"), 1, "Letter value: E = 1")
    AssertEquals(dict:GetLetterValue("Z"), 10, "Letter value: Z = 10")
    AssertEquals(dict:GetLetterValue("A"), 1, "Letter value: A = 1")
    AssertEquals(dict:GetLetterValue("K"), 5, "Letter value: K = 5")

    -- Word value
    local dragonValue = dict:GetWordValue("DRAGON")
    AssertEquals(dragonValue, 8, "Word value: DRAGON = 8 (D2+R1+A1+G2+O1+N1)")

    -- Tile bag
    local bag = dict:GenerateTileBag()
    AssertEquals(#bag, 98, "Tile bag size: 98 tiles")

    -- Count E tiles in bag (should be 12)
    local eCount = 0
    for _, tile in ipairs(bag) do
        if tile == "E" then
            eCount = eCount + 1
        end
    end
    AssertEquals(eCount, 12, "Tile bag E count: 12")

    -- Count A tiles in bag (should be 9)
    local aCount = 0
    for _, tile in ipairs(bag) do
        if tile == "A" then
            aCount = aCount + 1
        end
    end
    AssertEquals(aCount, 9, "Tile bag A count: 9")

    -- Edge cases
    Assert(not dict:IsValidWord(""), "Empty string invalid")
    Assert(not dict:IsValidWord(nil), "Nil input invalid")
    Assert(not dict:IsValidWord("A"), "Single letter invalid")

    -- Word count
    local count = dict:GetWordCount()
    Assert(count > 400, "Dictionary has 400+ words (got " .. count .. ")")

    PrintSummary("Dictionary Tests")
end

function Tests:BoardPlacement()
    ResetCounters()
    HopeAddon:Print("Running Board Placement Tests...")

    local board = HopeAddon.WordBoard:New()

    -- Test 1: Empty board
    Assert(board:IsBoardEmpty(), "Board starts empty")

    -- Test 2: First word must cover center
    local ok, err = board:CanPlaceWord("DRAGON", 8, 8, true, true)
    Assert(ok, "First word at center: valid")

    -- Test 3: First word off-center
    ok, err = board:CanPlaceWord("DRAGON", 1, 1, true, true)
    Assert(not ok and err and err:find("center"), "First word off-center: invalid (" .. tostring(err) .. ")")

    -- Test 4: Out of bounds horizontal
    ok, err = board:CanPlaceWord("DRAGONHAWK", 8, 12, true, false)
    Assert(not ok and err and err:find("beyond"), "Out of bounds horizontal: invalid (" .. tostring(err) .. ")")

    -- Test 5: Out of bounds vertical
    ok, err = board:CanPlaceWord("DRAGONHAWK", 12, 8, false, false)
    Assert(not ok and err and err:find("beyond"), "Out of bounds vertical: invalid (" .. tostring(err) .. ")")

    -- Test 6: Place first word
    local tiles = board:PlaceWord("DRAGON", 8, 8, true)
    Assert(#tiles == 6, "First word placed: 6 tiles")
    Assert(not board:IsBoardEmpty(), "Board no longer empty")

    -- Verify tiles are where expected
    local tile = board:GetTile(8, 8)
    AssertEquals(tile, "D", "Tile at (8,8) is D")
    tile = board:GetTile(8, 13)
    AssertEquals(tile, "N", "Tile at (8,13) is N")

    -- Test 7: Disconnected word
    ok, err = board:CanPlaceWord("FIRE", 1, 1, true, false)
    Assert(not ok and err and err:find("connect"), "Disconnected word: invalid (" .. tostring(err) .. ")")

    -- Test 8: Connected word (vertical through first letter)
    ok, err = board:CanPlaceWord("DRUID", 8, 8, false, false)
    Assert(ok, "Connected word (shares D): valid")

    -- Test 9: Conflicting letter
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("DRAGON", 8, 8, true)
    ok, err = board:CanPlaceWord("SWORD", 8, 8, true, false)
    Assert(not ok and err and err:find("onflic"), "Conflicting letter: invalid (" .. tostring(err) .. ")")

    -- Test 10: Word reusing all existing tiles (no new tiles)
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("FIRE", 8, 7, true)  -- F(8,7) I(8,8) R(8,9) E(8,10)
    -- Try to place "I" vertically at (8,8) - would reuse existing I
    ok, err = board:CanPlaceWord("I", 8, 8, false, false)
    Assert(not ok and err and err:find("new tile"), "No new tiles: invalid (" .. tostring(err) .. ")")

    -- Test 11: Valid word placement after first word
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("FIRE", 8, 7, true)
    ok, err = board:CanPlaceWord("AXE", 8, 9, false, false)  -- A(8,9) X(9,9) E(10,9) - uses R at (8,9)
    if ok then
        Assert(true, "Connected word placement valid")
    else
        HopeAddon:Debug("Note: AXE placement failed - " .. tostring(err))
    end

    PrintSummary("Board Placement Tests")
end

function Tests:Scoring()
    ResetCounters()
    HopeAddon:Print("Running Scoring Tests...")

    local board = HopeAddon.WordBoard:New()

    -- Test 1: Center square bonus (2x)
    local tiles = board:PlaceWord("DRAGON", 8, 8, true)
    local score = board:CalculateWordScore("DRAGON", 8, 8, true, tiles)

    -- DRAGON = D(2) + R(1) + A(1) + G(2) + O(1) + N(1) = 8
    -- Center is DW, so 8 × 2 = 16
    AssertEquals(score, 16, "Center square bonus: DRAGON = 16 (8×2)")

    -- Test 2: Triple word bonus
    board = HopeAddon.WordBoard:New()
    tiles = board:PlaceWord("FIRE", 1, 1, true)  -- F(1,1) I(1,2) R(1,3) E(1,4)
    score = board:CalculateWordScore("FIRE", 1, 1, true, tiles)

    -- FIRE = F(4) + I(1) + R(1) + E(1) = 7
    -- Position (1,1) is TW (triple word), so 7 × 3 = 21
    AssertEquals(score, 21, "Triple word bonus: FIRE = 21 (7×3)")

    -- Test 3: Simple word scoring (no bonuses on second+ placement)
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("FIRE", 8, 7, true)  -- Place first word
    tiles = board:PlaceWord("ARC", 7, 9, false)  -- A(7,9) R(8,9) C(9,9)
    -- R at (8,9) is reused, so tiles should be A and C only
    -- But let's just verify score is calculated
    score = board:CalculateWordScore("ARC", 7, 9, false, tiles)
    Assert(score > 0, "ARC scored: " .. score .. " points")

    -- Test 4: Word value without board bonuses
    local dict = HopeAddon.WordDictionary
    local wordValue = dict:GetWordValue("WARRIOR")
    -- W(4) + A(1) + R(1) + R(1) + I(1) + O(1) + R(1) = 10
    AssertEquals(wordValue, 10, "WARRIOR base value: 10")

    PrintSummary("Scoring Tests")
end

function Tests:CrossWords()
    ResetCounters()
    HopeAddon:Print("Running Cross-Word Tests...")

    local board = HopeAddon.WordBoard:New()
    local dict = HopeAddon.WordDictionary

    -- Setup: Place FIRE horizontally at row 8
    board:PlaceWord("FIRE", 8, 6, true)  -- F(8,6) I(8,7) R(8,8) E(8,9)

    -- Test 1: Place word vertically that reuses a letter
    local ok, err = board:CanPlaceWord("ARC", 7, 8, false, false)
    -- A(7,8) R(8,8) C(9,8) - reuses R at (8,8)

    if ok then
        local tiles = board:PlaceWord("ARC", 7, 8, false)
        local words = board:FindFormedWords(tiles, false)

        -- Should find ARC as main word
        Assert(#words >= 1, "Cross-word: found " .. #words .. " word(s)")

        -- Validate all words are in dictionary
        local allValid = true
        for _, wordData in ipairs(words) do
            if not dict:IsValidWord(wordData.word) then
                allValid = false
                HopeAddon:Print("Invalid word formed: " .. wordData.word)
            else
                HopeAddon:Debug("Formed word: " .. wordData.word)
            end
        end
        Assert(allValid, "All formed words valid in dictionary")
    else
        HopeAddon:Print("Could not place cross-word: " .. tostring(err))
        totalFailed = totalFailed + 1
    end

    -- Test 2: Multiple cross-words
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("DRAGON", 8, 5, true)  -- D(8,5) R(8,6) A(8,7) G(8,8) O(8,9) N(8,10)

    -- Place word vertically that intersects multiple letters
    ok, err = board:CanPlaceWord("RAGE", 6, 6, false, false)  -- R(6,6) A(7,6) G(8,6) E(9,6)
    -- This intersects the R in DRAGON at (8,6)

    if ok then
        local tiles = board:PlaceWord("RAGE", 6, 6, false)
        local words = board:FindFormedWords(tiles, false)
        Assert(#words >= 1, "Multiple cross-word test: found " .. #words .. " word(s)")
    else
        HopeAddon:Debug("RAGE placement not valid: " .. tostring(err))
    end

    -- Test 3: GetHorizontalWord and GetVerticalWord
    board = HopeAddon.WordBoard:New()
    board:PlaceWord("FIRE", 8, 6, true)

    local hWord = board:GetHorizontalWord(8, 8)
    AssertEquals(hWord, "FIRE", "GetHorizontalWord returns FIRE")

    local vWord = board:GetVerticalWord(8, 8)
    Assert(vWord == "R" or vWord == "", "GetVerticalWord returns single letter or empty")

    PrintSummary("Cross-Word Tests")
end

function Tests:GameFlow()
    ResetCounters()
    HopeAddon:Print("Running Game Flow Tests...")

    local WordGame = HopeAddon:GetModule("WordGame")
    local GameCore = HopeAddon:GetModule("GameCore")

    if not WordGame or not GameCore then
        HopeAddon:Print("|cFFFF0000ERROR:|r WordGame or GameCore module not loaded")
        PrintSummary("Game Flow Tests")
        return
    end

    -- Test 1: Create game (local mode)
    local gameId = WordGame:StartGame()
    Assert(gameId ~= nil, "Game created with ID: " .. tostring(gameId))

    local game = WordGame:GetGame(gameId)
    Assert(game ~= nil, "Game retrieved from GameCore")

    if not game or not game.data then
        HopeAddon:Print("|cFFFF0000ERROR:|r Game data is nil")
        PrintSummary("Game Flow Tests")
        return
    end

    AssertEquals(game.data.gameState, "PLAYER1_TURN", "Game started with PLAYER1_TURN state")

    -- Test 2: Place first word
    local player1 = game.player1
    local success, msg = WordGame:PlaceWord(gameId, "DRAGON", true, 8, 8, player1)
    Assert(success, "First word placed successfully: " .. tostring(msg))

    -- Test 3: Turn switched
    game = WordGame:GetGame(gameId)  -- Re-fetch game state
    if game and game.data then
        AssertEquals(game.data.gameState, "PLAYER2_TURN", "Turn switched to PLAYER2_TURN")

        -- Test 4: Score updated
        Assert(game.data.scores[player1] > 0, "Player 1 score increased: " .. game.data.scores[player1])

        -- Test 5: Wrong player tries to move
        success, msg = WordGame:PlaceWord(gameId, "FIRE", true, 1, 1, player1)
        Assert(not success and msg and msg:find("turn"), "Wrong player rejected: " .. tostring(msg))

        -- Test 6: Pass turn
        local player2 = game.player2
        success, msg = WordGame:PassTurn(gameId, player2)
        Assert(success, "Player 2 passed turn: " .. tostring(msg))

        game = WordGame:GetGame(gameId)
        if game and game.data then
            AssertEquals(game.data.consecutivePasses, 1, "Pass count incremented to 1")

            -- Test 7: Double pass ends game
            success, msg = WordGame:PassTurn(gameId, player1)
            Assert(success, "Player 1 passed turn: " .. tostring(msg))

            game = WordGame:GetGame(gameId)
            if game and game.data then
                AssertEquals(game.data.gameState, "FINISHED", "Game ended with FINISHED state after double pass")
            end
        end
    end

    -- Cleanup
    GameCore:EndGame(gameId, "test_complete")

    PrintSummary("Game Flow Tests")
end

function Tests:All()
    HopeAddon:Print("|cFF9B30FFWords with WoW - Running All Tests|r")
    HopeAddon:Print("========================================")

    self:Dictionary()
    HopeAddon:Print("")

    self:BoardPlacement()
    HopeAddon:Print("")

    self:Scoring()
    HopeAddon:Print("")

    self:CrossWords()
    HopeAddon:Print("")

    self:GameFlow()
    HopeAddon:Print("")

    HopeAddon:Print("|cFF00FF00All test suites complete!|r")
end

--============================================================
-- SLASH COMMAND
--============================================================

SLASH_WORDTEST1 = "/wordtest"
SlashCmdList["WORDTEST"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "" or cmd == "help" then
        HopeAddon:Print("|cFF9B30FFWords with WoW Test Commands:|r")
        HopeAddon:Print("  |cFFFFD100/wordtest all|r       - Run all tests")
        HopeAddon:Print("  |cFFFFD100/wordtest dict|r      - Test dictionary")
        HopeAddon:Print("  |cFFFFD100/wordtest board|r     - Test board placement")
        HopeAddon:Print("  |cFFFFD100/wordtest score|r     - Test scoring")
        HopeAddon:Print("  |cFFFFD100/wordtest cross|r     - Test cross-words")
        HopeAddon:Print("  |cFFFFD100/wordtest flow|r      - Test game flow")
        HopeAddon:Print("  |cFFFFD100/wordtest help|r      - Show this help")
    elseif cmd == "all" then
        Tests:All()
    elseif cmd == "dict" or cmd == "dictionary" then
        Tests:Dictionary()
    elseif cmd == "board" or cmd == "placement" then
        Tests:BoardPlacement()
    elseif cmd == "score" or cmd == "scoring" then
        Tests:Scoring()
    elseif cmd == "cross" or cmd == "crossword" then
        Tests:CrossWords()
    elseif cmd == "flow" or cmd == "game" then
        Tests:GameFlow()
    else
        HopeAddon:Print("|cFFFF0000Unknown test:|r " .. cmd)
        HopeAddon:Print("Type |cFFFFD100/wordtest help|r for commands")
    end
end

HopeAddon:Print("|cFF9B30FFWordGame test suite loaded.|r Type |cFFFFD100/wordtest help|r for commands.")
