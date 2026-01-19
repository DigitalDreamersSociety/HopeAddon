# HopeAddon Implementation Guide

## Purpose

This guide complements the **UI_ORGANIZATION_GUIDE.md** by providing:
- **Gap Analysis**: What's missing or broken in current implementations
- **Refactoring Plans**: How to eliminate code duplication and improve architecture
- **Fix Procedures**: Step-by-step instructions for resolving identified issues
- **Implementation Priorities**: Ordered roadmap for completing the UI system

**Relationship to UI Organization Guide:**
- **UI_ORGANIZATION_GUIDE.md** → Defines WHAT the UI should be (specs, standards, patterns)
- **IMPLEMENTATION_GUIDE.md** → Defines WHAT'S MISSING and HOW TO FIX IT (gaps, refactoring, fixes)

---

## Executive Summary

### Analysis Scope

Three comprehensive analyses were performed across the entire codebase:

1. **UI Implementation Gaps** - Compared actual implementations against UI_ORGANIZATION_GUIDE.md specifications
2. **Component Reusability** - Identified code duplication and missing abstractions
3. **Animation & Effects Integration** - Found gaps in transitions, celebrations, and sound integration

### Key Findings

**Critical Issues: 3**
- Words with WoW memory leak (no CleanupGame function)
- Pong ball desync in multiplayer (local physics divergence)
- Words board rendering O(n²) performance issue

**Code Duplication: 8 instances**
- CreateBackdropFrame compatibility wrapper duplicated ~70 lines across 8 files

**Missing Abstractions: 12+**
- Form builders, labeled controls, button factories, color helpers, validation utilities

**Animation Gaps: 18+**
- Missing 0.15s hover transitions, celebration effects not integrated, undefined PlayHover() calls

**TBC Theme Violations: 2+**
- BROWN color used in game cards (should use TBC palette)
- PARCHMENT colors need audit (may be too classic WoW)

---

## Part 1: Critical Issues & Fixes

### Issue C1: Words with WoW Memory Leak

**Severity:** Critical (Memory Leak)
**File:** `Social/Games/WordsWithWoW/WordGame.lua:196-203`
**Status:** 🔴 BROKEN

**Problem:**
No CleanupGame() function. OnDestroy only calls DestroyGameWindow() but doesn't clean:
- FontStrings: p1ScoreText, p2ScoreText, boardText, turnText, lastMoveText
- ScrollFrame: boardFrame
- Game data: board, moveHistory

**Impact:** Memory leak on every game completion. FontStrings and frames persist after game ends.

**Fix Procedure:**

```lua
-- Add to WordGame.lua after OnEnd function

function WordGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    -- Clear FontString references
    game.data.p1ScoreText = nil
    game.data.p2ScoreText = nil
    game.data.boardText = nil
    game.data.turnText = nil
    game.data.lastMoveText = nil

    -- Clear frame references
    if game.data.boardFrame then
        game.data.boardFrame:Hide()
        game.data.boardFrame:SetParent(nil)
        game.data.boardFrame = nil
    end

    -- Clear game data
    game.data.board = nil
    game.data.moveHistory = nil

    -- Destroy window
    if self.GameUI then
        self.GameUI:DestroyGameWindow(gameId)
    end
end

-- Update OnDestroy to call cleanup
function WordGame:OnDestroy(gameId)
    self:CleanupGame(gameId)
    self.games[gameId] = nil
end
```

**Testing:**
1. Start Words game: `/hope words <player>`
2. Play several rounds
3. End game
4. Check memory usage with `/run UpdateAddOnMemoryUsage(); print(GetAddOnMemoryUsage("HopeAddon"))`
5. Repeat - memory should stabilize, not grow indefinitely

**Priority:** Immediate - affects all Words games

---

### Issue C2: Pong Ball Position Desync

**Severity:** Critical (Multiplayer Integrity)
**File:** `Social/Games/Pong/PongGame.lua:556-611`
**Status:** 🔴 BROKEN

**Problem:**
Only paddle positions are synchronized at 10Hz. Ball physics run locally on both clients, causing divergence and inconsistent scoring.

**Current Network Message:**
```lua
-- Only sends paddle position and velocity
local data = string.format("PADDLE|%.2f|%.2f", paddle1.y, paddle1.dy)
GameComms:SendMove(game.data.opponent, "PONG", gameId, data)
```

**Impact:** Remote opponents see different ball positions. Score discrepancies inevitable.

**Fix Procedure (Server-Authoritative Model):**

```lua
-- Step 1: Determine host (player who sent invite is host)
function PongGame:OnCreate(gameId, game)
    -- Add to existing OnCreate
    game.data.isHost = (game.mode == HopeAddon.GameCore.GAME_MODE.LOCAL) or
                       (game.data.invitedBy == nil) -- We sent the invite
end

-- Step 2: Host sends ball updates with paddle
function PongGame:SendPaddlePosition(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local ball = game.data.ball
    local paddle1 = game.data.paddle1

    if game.data.isHost then
        -- Host sends: PADDLE + BALL
        local data = string.format("STATE|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f",
            paddle1.y, paddle1.dy,  -- Paddle
            ball.x, ball.y, ball.dx, ball.dy  -- Ball
        )
        self.GameComms:SendMove(game.data.opponent, "PONG", gameId, data)
    else
        -- Client sends: PADDLE only
        local data = string.format("PADDLE|%.2f|%.2f", paddle1.y, paddle1.dy)
        self.GameComms:SendMove(game.data.opponent, "PONG", gameId, data)
    end
end

-- Step 3: Client receives and applies ball state
function PongGame:OnMoveReceived(fromPlayer, gameId, moveData)
    local game = self.games[gameId]
    if not game then return end

    local parts = { strsplit("|", moveData) }
    local msgType = parts[1]

    if msgType == "STATE" and not game.data.isHost then
        -- Client receives authoritative ball state from host
        game.data.paddle2.y = tonumber(parts[2])
        game.data.paddle2.dy = tonumber(parts[3])
        game.data.ball.x = tonumber(parts[4])
        game.data.ball.y = tonumber(parts[5])
        game.data.ball.dx = tonumber(parts[6])
        game.data.ball.dy = tonumber(parts[7])

    elseif msgType == "PADDLE" and game.data.isHost then
        -- Host receives client paddle update
        game.data.paddle2.y = tonumber(parts[2])
        game.data.paddle2.dy = tonumber(parts[3])
        -- Host continues running ball physics locally
    end
end

-- Step 4: Client disables local ball physics
function PongGame:UpdateBallPhysics(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    -- Only host runs ball physics
    if not game.data.isHost then
        return -- Client just renders received ball position
    end

    -- Existing ball physics code here (host only)
    -- ...
end
```

**Testing:**
1. Start Pong game between two clients
2. Play full match (11 points)
3. Compare final scores - should match exactly
4. Observer should see smooth ball movement on both screens
5. Test paddle collision edge cases (corner hits, etc.)

**Priority:** Immediate - affects all remote Pong games

---

### Issue C3: Words Board Rendering Performance

**Severity:** Critical (Performance)
**File:** `Social/Games/WordsWithWoW/WordGame.lua:610-670`
**Status:** 🔴 BROKEN

**Problem:**
Entire board re-rendered as concatenated string on every update. 15x15 grid = 225 cells, each generating string fragments. O(n²) string operations cause frame drops.

**Current Pattern:**
```lua
function WordGame:UpdateDisplay(gameId)
    local boardText = self:RenderBoard(game.data.board)  -- Full rebuild every time
    game.data.boardText:SetText(boardText)
end

function WordGame:RenderBoard(board)
    local lines = {}
    for row = 1, 15 do
        local line = ""
        for col = 1, 15 do
            line = line .. board[row][col] .. " "  -- String concat per cell
        end
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")  -- Another concatenation
end
```

**Fix Procedure (Row Caching):**

```lua
-- Step 1: Add cached rows to board initialization
function WordGame:InitializeBoard()
    local board = {}
    board.cachedRows = {}  -- NEW: Cache for rendered rows

    for row = 1, 15 do
        board[row] = {}
        for col = 1, 15 do
            board[row][col] = "·"
        end
    end

    return board
end

-- Step 2: Invalidate cache when cell changes
function WordGame:PlaceWord(board, word, direction, startRow, startCol)
    -- Existing placement logic...

    if direction == "H" then
        for i = 1, #word do
            board[startRow][startCol + i - 1] = word:sub(i, i)
            board.cachedRows[startRow] = nil  -- Invalidate this row
        end
    else -- Vertical
        for i = 1, #word do
            board[startRow + i - 1][startCol] = word:sub(i, i)
            board.cachedRows[startRow + i - 1] = nil  -- Invalidate affected rows
        end
    end
end

-- Step 3: Use cache in rendering
function WordGame:RenderBoard(board)
    local lines = {}

    for row = 1, 15 do
        if not board.cachedRows[row] then
            -- Rebuild this row only if cache invalid
            local line = ""
            for col = 1, 15 do
                line = line .. board[row][col] .. " "
            end
            board.cachedRows[row] = line
        end
        table.insert(lines, board.cachedRows[row])
    end

    return table.concat(lines, "\n")
end

-- Step 4: Clear cache on board reset
function WordGame:ResetBoard(gameId)
    local game = self.games[gameId]
    if not game then return end

    game.data.board = self:InitializeBoard()  -- Creates new board with empty cache
    self:UpdateDisplay(gameId)
end
```

**Performance Improvement:**
- Before: 225 cell string operations per update
- After: ~15 row rebuilds only when rows change
- Expected: 15x speedup for typical moves (1 row affected)

**Testing:**
1. Start Words game
2. Place several words rapidly
3. Monitor FPS with `/run local fps = GetFramerate(); print("FPS:", fps)`
4. Should maintain 60 FPS throughout gameplay
5. Verify cache invalidation: change cell, verify row re-renders correctly

**Priority:** Immediate - affects all Words games, especially active gameplay

---

## Part 2: High Priority Issues

### Issue H1: Scroll Container Height Fallback Mismatch

**Severity:** High (Layout Bug)
**File:** `UI/Components.lua:635-636`, `Journal/Journal.lua` (throughout)
**Status:** 🟡 INCONSISTENT

**Problem:**
AddEntry uses 80px fallback when `frame:GetHeight() < 1`, but components have varying heights:
- Section headers: 25-45px (UNDER fallback)
- Spacers: 10-20px variable (UNDER fallback)
- Collapsible sections: 28px + content (UNDER fallback initially)
- Cards: 80-120px (matches fallback)

**Symptom:** First entries in tabs have double-spacing or compressed layout.

**Fix Procedure:**

```lua
-- Step 1: Add component type tracking
-- In Components.lua, update all Create* functions:

function Components:CreateSectionHeader(text, color)
    local header = CreateFrame("Frame", nil, parent)
    -- ... existing code ...

    header._componentType = "header"  -- NEW: Track type
    header._designHeight = 30         -- NEW: Track intended height

    return header
end

function Components:CreateSpacer(height)
    local spacer = CreateFrame("Frame", nil, parent)
    spacer:SetHeight(height or 10)

    spacer._componentType = "spacer"  -- NEW
    spacer._designHeight = height or 10  -- NEW

    return spacer
end

-- Similarly for CreateCollapsibleSection, CreateCard, etc.

-- Step 2: Update AddEntry to use component metadata
-- In Components.lua:634-641

function container:AddEntry(entryFrame)
    entryFrame:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -self.currentYOffset)
    entryFrame:SetPoint("RIGHT", self.content, "RIGHT", 0, 0)

    -- Force layout update
    entryFrame:Show()

    -- Measure actual height after layout
    local entryHeight = entryFrame:GetHeight()

    if entryHeight < 1 then
        -- Use component metadata if available
        if entryFrame._designHeight then
            entryHeight = entryFrame._designHeight
        elseif entryFrame._componentType == "header" then
            entryHeight = 30
        elseif entryFrame._componentType == "spacer" then
            entryHeight = 10  -- Minimum spacer
        elseif entryFrame._componentType == "collapsible" then
            entryHeight = 28  -- Header only when collapsed
        else
            entryHeight = 80  -- Default for cards
        end
    end

    self.currentYOffset = self.currentYOffset + entryHeight + Components.MARGIN_SMALL
    self.content:SetHeight(self.currentYOffset)

    table.insert(self.entries, entryFrame)
end

-- Step 3: Update RecalculatePositions to use same logic
function container:RecalculatePositions()
    local yOffset = 0

    for _, entryFrame in ipairs(self.entries) do
        entryFrame:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)

        local entryHeight = entryFrame:GetHeight()
        if entryHeight < 1 then
            entryHeight = entryFrame._designHeight or 80
        end

        yOffset = yOffset + entryHeight + Components.MARGIN_SMALL
    end

    self.content:SetHeight(yOffset)
end
```

**Testing:**
1. Open journal: `/hope`
2. Switch between all tabs
3. Verify no double-spacing at top of any tab
4. Check collapsible sections expand/collapse smoothly
5. Measure spacing between entries (should be consistent 5px)

**Priority:** High - affects all journal tabs

---

### Issue H2: Game Window Size Constants

**Severity:** High (UX Consistency)
**File:** `Social/Games/GameUI.lua:28-34`, `Social/Games/WordsWithWoW/WordGame.lua:459`
**Status:** 🟡 INCONSISTENT

**Problem:**
Words uses generic LARGE (600x500) but needs board-specific dimensions. Should have dedicated size constant for better board fit.

**Fix Procedure:**

```lua
-- Step 1: Add WORDS constant to GameUI.lua:28-34

WINDOW_SIZES = {
    SMALL = { width = 300, height = 200 },
    MEDIUM = { width = 450, height = 350 },
    LARGE = { width = 600, height = 500 },
    PONG = { width = 500, height = 400 },
    TETRIS = { width = 700, height = 550 },
    WORDS = { width = 650, height = 600 },  -- NEW: Optimized for 15x15 board + controls
}

-- Step 2: Update WordGame.lua:459

function WordGame:OnCreate(gameId, game)
    -- Create game window
    local window = self.GameUI:CreateGameWindow(
        gameId,
        "Words with WoW",
        "WORDS",  -- Changed from "LARGE"
        function() self:OnWindowClose(gameId) end
    )

    -- ... rest of creation code
end
```

**Rationale:**
- 650x600 provides better fit for 15x15 board (15 * 16px = 240px width + margins)
- Extra width allows for score displays without crowding
- Extra height accommodates instructions and turn indicators

**Testing:**
1. Start Words game: `/hope words <player>`
2. Verify board fits comfortably without scrolling
3. Check score displays visible without overlap
4. Resize window - should snap back to 650x600

**Priority:** High - improves UX for all Words games

---

### Issue H3: Frame Reference Storage Patterns

**Severity:** High (Maintainability)
**File:** All game implementations
**Status:** 🟡 INCONSISTENT

**Problem:**
Each game stores frame references differently, making cleanup patterns hard to maintain:

| Game | Pattern |
|------|---------|
| Tetris | `game.data.window`, `board.container`, `board.cellTextures[row][col]` |
| Pong | `game.data.window`, `game.data.paddle1Frame`, `game.data.ballFrame` |
| Words | `game.data.window`, `game.data.boardText`, `game.data.p1ScoreText` |

**Fix Procedure (Standardize Structure):**

```lua
-- Pattern for ALL games:

function GameName:OnCreate(gameId, game)
    -- Initialize standard structure
    game.data = {
        window = nil,  -- Will be set below
        ui = {
            -- All UI frame/fontstring references here
            -- NO game state mixed in
        },
        state = {
            -- All game state here
            -- NO UI references mixed in
        }
    }

    -- Example for Words:
    game.data.ui = {
        boardFrame = CreateFrame(...),
        boardText = boardFrame:CreateFontString(...),
        p1ScoreText = window:CreateFontString(...),
        p2ScoreText = window:CreateFontString(...),
        turnText = window:CreateFontString(...),
        lastMoveText = window:CreateFontString(...),
    }

    game.data.state = {
        board = self:InitializeBoard(),
        scores = {0, 0},
        currentPlayer = 1,
        moveHistory = {},
        tileBag = self:GenerateTileBag(),
    }
end

-- Standard cleanup becomes:
function GameName:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game or not game.data then return end

    -- Clear all UI references
    if game.data.ui then
        for key, frame in pairs(game.data.ui) do
            if type(frame) == "table" and frame.Hide then
                frame:Hide()
                frame:SetParent(nil)
            end
            game.data.ui[key] = nil
        end
        game.data.ui = nil
    end

    -- Clear state
    if game.data.state then
        for key, _ in pairs(game.data.state) do
            game.data.state[key] = nil
        end
        game.data.state = nil
    end

    -- Destroy window
    if self.GameUI then
        self.GameUI:DestroyGameWindow(gameId)
    end

    game.data.window = nil
end
```

**Migration Plan:**
1. Update Words first (has the cleanup bug)
2. Update Pong next (has the desync bug)
3. Update Tetris (already good, just standardize structure)
4. Update Death Roll last (simple structure)

**Testing:**
1. Play each game to completion
2. Destroy game
3. Check memory: `/run UpdateAddOnMemoryUsage(); print(GetAddOnMemoryUsage("HopeAddon"))`
4. Repeat 10 times - memory should stabilize

**Priority:** High - enables consistent cleanup patterns, prevents future leaks

---

### Issue H4: Words Network Score Validation

**Severity:** High (Multiplayer Integrity)
**File:** `Social/Games/WordsWithWoW/WordGame.lua:337-341`
**Status:** 🟡 MISSING

**Problem:**
Score sent in move message but not validated by opponent. If dictionaries differ or scoring bugs exist, scores diverge.

**Current Code:**
```lua
local moveData = string.format("%s|%s|%d|%d|%d", word, dir, startRow, startCol, totalScore)
self.GameComms:SendMove(game.opponent, "WORDS", gameId, moveData)
```

**Fix Procedure:**

```lua
-- Step 1: Update OnMoveReceived to recalculate and validate score

function WordGame:OnMoveReceived(fromPlayer, gameId, moveData)
    local game = self.games[gameId]
    if not game then return end

    local parts = { strsplit("|", moveData) }
    local word = parts[1]
    local dir = parts[2]
    local startRow = tonumber(parts[3])
    local startCol = tonumber(parts[4])
    local claimedScore = tonumber(parts[5])

    -- Validate word placement first
    if not self.WordBoard:IsValidPlacement(game.data.state.board, word, dir, startRow, startCol) then
        HopeAddon:Print(string.format(
            "ERROR: %s sent invalid word placement: %s at (%d,%d) %s",
            fromPlayer, word, startRow, startCol, dir
        ))
        -- Could auto-forfeit here or prompt for manual resolution
        return
    end

    -- Recalculate score locally
    local calculatedScore = self:CalculateScore(game.data.state.board, word, dir, startRow, startCol)

    -- Compare scores
    if calculatedScore ~= claimedScore then
        HopeAddon:Print(string.format(
            "|cFFFF0000WARNING: Score mismatch!|r %s claimed %d but local calculation shows %d for word '%s'",
            fromPlayer, claimedScore, calculatedScore, word
        ))

        -- Trust local calculation (our dictionary is authoritative for us)
        game.data.state.scores[2] = game.data.state.scores[2] + calculatedScore
    else
        -- Scores match - good!
        game.data.state.scores[2] = game.data.state.scores[2] + claimedScore
    end

    -- Apply the move
    self.WordBoard:PlaceWord(game.data.state.board, word, dir, startRow, startCol)

    -- Update display
    self:UpdateDisplay(gameId)

    -- Switch turns
    game.data.state.currentPlayer = 1  -- Back to local player
end

-- Step 2: Add CalculateScore function (if not exists)
function WordGame:CalculateScore(board, word, direction, startRow, startCol)
    local score = 0
    local wordMultiplier = 1

    for i = 1, #word do
        local row, col
        if direction == "H" then
            row, col = startRow, startCol + i - 1
        else
            row, col = startRow + i - 1, startCol
        end

        local letter = word:sub(i, i)
        local letterValue = self.WordDictionary:GetLetterValue(letter)
        local bonusType = self.WordBoard:GetBonusType(row, col)

        -- Apply bonus if cell was empty (new placement)
        if board[row][col] == "·" then
            if bonusType == "DL" then
                letterValue = letterValue * 2
            elseif bonusType == "TL" then
                letterValue = letterValue * 3
            elseif bonusType == "DW" then
                wordMultiplier = wordMultiplier * 2
            elseif bonusType == "TW" then
                wordMultiplier = wordMultiplier * 3
            end
        end

        score = score + letterValue
    end

    score = score * wordMultiplier

    -- Bingo bonus (all 7 tiles used)
    if #word == 7 then
        score = score + 50
    end

    return score
end
```

**Testing:**
1. Start Words game between two clients
2. Artificially inject score mismatch (temporarily modify one client's dictionary)
3. Verify warning appears in chat
4. Verify local calculation is used
5. Restore dictionaries and verify normal play

**Priority:** High - ensures fair play in multiplayer Words games

---

## Part 3: Code Duplication & Refactoring

### Duplication D1: CreateBackdropFrame Wrapper

**Severity:** Medium (Code Bloat)
**Files:** 8 files duplicate ~70 lines total
**Status:** 🟡 DUPLICATED

**Problem:**
CreateBackdropFrame compatibility wrapper duplicated in:
1. `HopeAddon/Journal/Journal.lua:81-104`
2. `HopeAddon/Social/Directory.lua`
3. `HopeAddon/Social/MinigamesUI.lua`
4. `HopeAddon/Social/Games/DeathRoll/DeathRollUI.lua`
5. `HopeAddon/Social/Games/Tetris/TetrisGame.lua`
6. `HopeAddon/Social/Games/Pong/PongGame.lua`
7. `HopeAddon/Social/Games/WordsWithWoW/WordGame.lua`
8. `HopeAddon/UI/Components.lua` (master version)

**Refactoring Plan:**

```lua
-- Step 1: Keep the master version in Components.lua (lines 121-123)
-- This is already the canonical implementation

-- Step 2: Make it globally accessible via HopeAddon namespace
-- In Core/Core.lua, after Components is loaded:

function HopeAddon:CreateBackdropFrame(frameType, parent, name, template)
    return self.Components:CreateBackdropFrame(frameType, parent, name, template)
end

-- Step 3: Update all 7 other files to use the global version

-- Example for Journal.lua:81-104
-- DELETE these lines:
-- local function CreateBackdropFrame(...)
--     ... 20 lines ...
-- end

-- REPLACE usage with:
local mainFrame = HopeAddon:CreateBackdropFrame("Frame", UIParent, "HopeJournal", "BackdropTemplate")

-- Repeat for all 7 files

-- Step 4: Add deprecation warning for direct Components usage
-- In Components.lua:121

function Components:CreateBackdropFrame(frameType, parent, name, template)
    -- Existing implementation stays
    -- Just add comment:
    -- NOTE: Prefer HopeAddon:CreateBackdropFrame() for global access
end
```

**Benefits:**
- Removes ~70 lines of duplicated code
- Single point of maintenance
- Consistent behavior across all modules

**Migration Order:**
1. Add global wrapper to Core.lua
2. Update Journal.lua (most complex)
3. Update MinigamesUI.lua
4. Update game implementations (DeathRoll, Tetris, Pong, Words)
5. Update Directory.lua
6. Remove old local functions

**Testing:**
1. `/reload` after each file update
2. Open journal - should work: `/hope`
3. Start each minigame - should work
4. Check for any "attempt to call nil" errors

**Priority:** Medium - improves maintainability, no user-facing impact

---

### Duplication D2: Manual Y-Offset Tracking

**Severity:** Medium (Maintainability)
**Files:** ProfileEditor.lua, multiple tab populate functions
**Status:** 🟡 DUPLICATED

**Problem:**
Manual Y-offset tracking pattern repeated 6+ times:

```lua
local yOffset = -20
field1:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
yOffset = yOffset - 30
field2:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
yOffset = yOffset - 40
-- ... repeated
```

**Refactoring Plan:**

```lua
-- Step 1: Add LayoutBuilder helper to Components.lua

function Components:CreateLayoutBuilder(parent)
    local builder = {
        parent = parent,
        currentY = -20,  -- Default starting Y
        lastFrame = nil,
    }

    function builder:AddFrame(frame, spacing)
        spacing = spacing or Components.MARGIN_NORMAL

        if not self.lastFrame then
            -- First frame
            frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 10, self.currentY)
        else
            -- Subsequent frames anchor to previous
            frame:SetPoint("TOPLEFT", self.lastFrame, "BOTTOMLEFT", 0, -spacing)
        end

        self.lastFrame = frame
        return self  -- Chaining
    end

    function builder:AddSpacer(height)
        if not self.lastFrame then return self end

        local spacer = CreateFrame("Frame", nil, self.parent)
        spacer:SetSize(1, height or Components.MARGIN_LARGE)
        spacer:SetPoint("TOPLEFT", self.lastFrame, "BOTTOMLEFT", 0, 0)
        self.lastFrame = spacer
        return self
    end

    function builder:SetStartY(y)
        self.currentY = y
        return self
    end

    function builder:Reset()
        self.currentY = -20
        self.lastFrame = nil
        return self
    end

    return builder
end

-- Step 2: Refactor ProfileEditor.lua using builder

function ProfileEditor:PopulateEditor(content)
    -- Create builder
    local layout = HopeAddon.Components:CreateLayoutBuilder(content)

    -- Title
    local titleText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetText("Edit Your Profile")
    titleText:SetTextColor(HopeAddon.colors.GOLD_BRIGHT.r, HopeAddon.colors.GOLD_BRIGHT.g, HopeAddon.colors.GOLD_BRIGHT.b)
    layout:AddFrame(titleText, 0)

    -- Backstory section
    local backstoryLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    backstoryLabel:SetText("Backstory:")
    layout:AddFrame(backstoryLabel, 15)

    local backstoryBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    backstoryBox:SetSize(450, 100)
    backstoryBox:SetMultiLine(true)
    backstoryBox:SetAutoFocus(false)
    layout:AddFrame(backstoryBox, 5)

    -- Personality section
    layout:AddSpacer(20)

    local personalityLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalityLabel:SetText("Personality Traits:")
    layout:AddFrame(personalityLabel, 10)

    local personalityBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    personalityBox:SetSize(450, 80)
    personalityBox:SetMultiLine(true)
    personalityBox:SetAutoFocus(false)
    layout:AddFrame(personalityBox, 5)

    -- ... continue pattern for all fields
end

-- Step 3: Use in other modules with manual offsets

-- Example: Journal.lua PopulateTimeline
function Journal:PopulateTimeline()
    local scrollContainer = self.mainFrame.scrollContainer
    scrollContainer:ClearEntries(self.containerPool)

    -- Can still use scroll container's AddEntry for pooled frames
    -- Or use layout builder for non-pooled frames
end
```

**Benefits:**
- Eliminates error-prone manual offset tracking
- Fluent API with method chaining
- Easy to add spacers and adjust spacing
- Consistent layout across all forms

**Migration Priority:**
1. ProfileEditor (most complex, 6+ fields)
2. Game settings screens if added
3. Any new form-based UIs

**Testing:**
1. Open profile editor: `/hope` → Directory tab → Edit Profile button
2. Verify all fields positioned correctly
3. Add/remove fields - should be easier to maintain
4. Test scroll behavior

**Priority:** Medium - improves maintainability for form-heavy UIs

---

## Part 4: Missing Abstractions

### Abstraction A1: Labeled Control Factory

**Status:** 🔴 MISSING
**Impact:** High (DRY principle)

**Problem:**
Pattern repeated 20+ times across UI:

```lua
local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetText("Field Name:")
label:SetPoint(...)

local control = CreateFrame("EditBox", ...)
control:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
```

**Implementation:**

```lua
-- Add to Components.lua

function Components:CreateLabeledEditBox(parent, labelText, width, height, multiLine)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, (height or 30) + 20)  -- +20 for label

    -- Label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(labelText)
    label:SetTextColor(HopeAddon.colors.GOLD_BRIGHT.r, HopeAddon.colors.GOLD_BRIGHT.g, HopeAddon.colors.GOLD_BRIGHT.b)

    -- Edit box
    local editBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    editBox:SetSize(width, height or 30)
    editBox:SetAutoFocus(false)

    if multiLine then
        editBox:SetMultiLine(true)
        editBox:SetMaxLetters(0)  -- Unlimited
    end

    -- API
    container.label = label
    container.editBox = editBox

    function container:GetText()
        return self.editBox:GetText()
    end

    function container:SetText(text)
        self.editBox:SetText(text or "")
    end

    function container:SetEnabled(enabled)
        self.editBox:SetEnabled(enabled)
        self.label:SetTextColor(
            enabled and 1 or 0.5,
            enabled and 0.84 or 0.5,
            enabled and 0 or 0.5
        )
    end

    return container
end

-- Similar for other control types:

function Components:CreateLabeledDropdown(parent, labelText, width, options)
    -- Dropdown with label
end

function Components:CreateLabeledCheckbox(parent, labelText)
    -- Checkbox with label
end

function Components:CreateLabeledSlider(parent, labelText, min, max, step)
    -- Slider with label
end
```

**Usage Example:**

```lua
-- Before:
local backstoryLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
backstoryLabel:SetText("Backstory:")
backstoryLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20)

local backstoryBox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
backstoryBox:SetPoint("TOPLEFT", backstoryLabel, "BOTTOMLEFT", 0, -5)
backstoryBox:SetSize(450, 100)
backstoryBox:SetMultiLine(true)
backstoryBox:SetAutoFocus(false)

-- After:
local backstoryControl = HopeAddon.Components:CreateLabeledEditBox(
    content, "Backstory:", 450, 100, true
)
backstoryControl:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20)
```

**Benefits:**
- Reduces 8-10 lines to 3 lines per control
- Consistent styling automatically
- Built-in GetText/SetText/SetEnabled API
- Easy to extend with validation

**Priority:** High - improves ProfileEditor, future settings panels

---

### Abstraction A2: Color Helper Utilities

**Status:** 🔴 MISSING
**Impact:** Medium (Code clarity)

**Problem:**
Color application pattern repeated 50+ times:

```lua
frame:SetBackdropBorderColor(color.r, color.g, color.b, alpha or 1)
fontString:SetTextColor(color.r, color.g, color.b)
texture:SetVertexColor(color.r, color.g, color.b, alpha)
```

**Implementation:**

```lua
-- Add to Core/Core.lua after color definitions

-- Apply color to different frame types
function HopeAddon:ApplyColor(frame, color, alpha)
    alpha = alpha or 1

    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(color.r, color.g, color.b, alpha)
    end

    if frame.SetBackdropColor then
        frame:SetBackdropColor(color.r, color.g, color.b, alpha)
    end

    if frame.SetTextColor then
        frame:SetTextColor(color.r, color.g, color.b)
    end

    if frame.SetVertexColor then
        frame:SetVertexColor(color.r, color.g, color.b, alpha)
    end
end

-- Lighten color by percentage
function HopeAddon:LightenColor(color, amount)
    amount = amount or 0.2
    return {
        r = math.min(1, color.r + amount),
        g = math.min(1, color.g + amount),
        b = math.min(1, color.b + amount),
    }
end

-- Darken color by percentage
function HopeAddon:DarkenColor(color, amount)
    amount = amount or 0.2
    return {
        r = math.max(0, color.r - amount),
        g = math.max(0, color.g - amount),
        b = math.max(0, color.b - amount),
    }
end

-- Desaturate color (grayscale)
function HopeAddon:DesaturateColor(color, amount)
    amount = amount or 0.5
    local gray = (color.r + color.g + color.b) / 3
    return {
        r = color.r * (1 - amount) + gray * amount,
        g = color.g * (1 - amount) + gray * amount,
        b = color.b * (1 - amount) + gray * amount,
    }
end

-- Blend two colors
function HopeAddon:BlendColors(color1, color2, ratio)
    ratio = ratio or 0.5
    return {
        r = color1.r * (1 - ratio) + color2.r * ratio,
        g = color1.g * (1 - ratio) + color2.g * ratio,
        b = color1.b * (1 - ratio) + color2.b * ratio,
    }
end

-- Convert hex to RGB
function HopeAddon:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return {
        r = tonumber(hex:sub(1, 2), 16) / 255,
        g = tonumber(hex:sub(3, 4), 16) / 255,
        b = tonumber(hex:sub(5, 6), 16) / 255,
    }
end

-- Convert RGB to hex
function HopeAddon:RGBToHex(color)
    return string.format("%02X%02X%02X",
        math.floor(color.r * 255),
        math.floor(color.g * 255),
        math.floor(color.b * 255)
    )
end
```

**Usage Examples:**

```lua
-- Before:
local hoverColor = {
    r = math.min(1, baseColor.r + 0.2),
    g = math.min(1, baseColor.g + 0.2),
    b = math.min(1, baseColor.b + 0.2),
}
button:SetBackdropBorderColor(hoverColor.r, hoverColor.g, hoverColor.b, 1)

-- After:
local hoverColor = HopeAddon:LightenColor(baseColor, 0.2)
HopeAddon:ApplyColor(button, hoverColor)

-- Before (desaturating locked icons):
local locked = (color.r + color.g + color.b) / 3
icon:SetVertexColor(locked, locked, locked, 1)

-- After:
local grayColor = HopeAddon:DesaturateColor(color)
HopeAddon:ApplyColor(icon, grayColor)
```

**Benefits:**
- Cleaner, more readable color operations
- Consistent color math across codebase
- Easy to adjust hover/disabled states
- Supports hex colors from external sources

**Priority:** Medium - improves code clarity, especially for hover states

---

### Abstraction A3: Button Factory with States

**Status:** 🔴 MISSING
**Impact:** High (Consistency)

**Problem:**
Button creation with hover/pressed states manually implemented 30+ times across UI. Inconsistent animation timing and colors.

**Implementation:**

```lua
-- Add to Components.lua

function Components:CreateStyledButton(parent, text, width, height, colorScheme)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 100, height or 30)

    -- Use provided color scheme or default
    colorScheme = colorScheme or "default"
    local colors = {
        default = {
            normal = HopeAddon.colors.PARCHMENT_BG,
            hover = HopeAddon:LightenColor(HopeAddon.colors.PARCHMENT_BG, 0.2),
            pressed = HopeAddon:DarkenColor(HopeAddon.colors.PARCHMENT_BG, 0.1),
            disabled = HopeAddon:DesaturateColor(HopeAddon.colors.PARCHMENT_BG, 0.5),
            border = HopeAddon.colors.PARCHMENT_BORDER,
            borderHover = HopeAddon.colors.GOLD_BRIGHT,
        },
        primary = {
            normal = HopeAddon.colors.ARCANE_PURPLE,
            hover = HopeAddon:LightenColor(HopeAddon.colors.ARCANE_PURPLE, 0.2),
            pressed = HopeAddon:DarkenColor(HopeAddon.colors.ARCANE_PURPLE, 0.1),
            disabled = HopeAddon:DesaturateColor(HopeAddon.colors.ARCANE_PURPLE, 0.5),
            border = HopeAddon.colors.VOID_PURPLE,
            borderHover = HopeAddon.colors.GOLD_BRIGHT,
        },
        success = {
            normal = HopeAddon.colors.FEL_GREEN,
            hover = HopeAddon:LightenColor(HopeAddon.colors.FEL_GREEN, 0.2),
            pressed = HopeAddon:DarkenColor(HopeAddon.colors.FEL_GREEN, 0.1),
            disabled = HopeAddon:DesaturateColor(HopeAddon.colors.FEL_GREEN, 0.5),
            border = HopeAddon.colors.FEL_GLOW,
            borderHover = HopeAddon.colors.GOLD_BRIGHT,
        },
        danger = {
            normal = HopeAddon.colors.HELLFIRE_RED,
            hover = HopeAddon:LightenColor(HopeAddon.colors.HELLFIRE_RED, 0.2),
            pressed = HopeAddon:DarkenColor(HopeAddon.colors.HELLFIRE_RED, 0.1),
            disabled = HopeAddon:DesaturateColor(HopeAddon.colors.HELLFIRE_RED, 0.5),
            border = HopeAddon.colors.HELLFIRE_ORANGE,
            borderHover = HopeAddon.colors.GOLD_BRIGHT,
        },
    }

    local scheme = colors[colorScheme]
    button._colorScheme = scheme
    button._currentState = "normal"

    -- Backdrop
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    button:SetBackdropColor(scheme.normal.r, scheme.normal.g, scheme.normal.b, 1)
    button:SetBackdropBorderColor(scheme.border.r, scheme.border.g, scheme.border.b, 1)

    -- Text
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER", button, "CENTER", 0, 0)
    buttonText:SetText(text)
    buttonText:SetTextColor(1, 1, 1)
    button.text = buttonText

    -- State management
    function button:SetState(state)
        if self._currentState == state then return end
        self._currentState = state

        local targetColor = self._colorScheme[state] or self._colorScheme.normal

        -- Animate transition
        HopeAddon.Animations:FadeTo(self, 1, 0.15, nil, function(frame, progress)
            -- Interpolate color during animation
            local currentColor = self._colorScheme[self._lastState or "normal"]
            local r = currentColor.r + (targetColor.r - currentColor.r) * progress
            local g = currentColor.g + (targetColor.g - currentColor.g) * progress
            local b = currentColor.b + (targetColor.b - currentColor.b) * progress
            self:SetBackdropColor(r, g, b, 1)
        end)

        self._lastState = state
    end

    function button:SetEnabled(enabled)
        self:Enable()
        if enabled then
            self:SetState("normal")
        else
            self:SetState("disabled")
        end
    end

    -- Hover handling
    button:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetState("hover")
            self:SetBackdropBorderColor(self._colorScheme.borderHover.r, self._colorScheme.borderHover.g, self._colorScheme.borderHover.b, 1)

            -- Play hover sound
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayHover()
            end

            -- Show tooltip if provided
            if self.tooltipText then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(self.tooltipText)
                GameTooltip:Show()
            end
        end
    end)

    button:SetScript("OnLeave", function(self)
        self:SetState("normal")
        self:SetBackdropBorderColor(self._colorScheme.border.r, self._colorScheme.border.g, self._colorScheme.border.b, 1)
        GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            self:SetState("pressed")
        end
    end)

    button:SetScript("OnMouseUp", function(self)
        if self:IsEnabled() then
            self:SetState("hover")
        end
    end)

    -- Click handling
    button:RegisterForClicks("LeftButtonUp")

    return button
end
```

**Usage Examples:**

```lua
-- Before (30+ lines):
local button = CreateFrame("Button", nil, parent)
button:SetSize(100, 30)
button:SetBackdrop(...)
button:SetBackdropColor(...)
button:SetScript("OnEnter", function(self)
    self:SetBackdropColor(...)
    self:SetBackdropBorderColor(...)
end)
-- ... more scripts ...

-- After (3 lines):
local button = HopeAddon.Components:CreateStyledButton(parent, "Click Me", 100, 30, "primary")
button:SetPoint("CENTER", parent, "CENTER", 0, 0)
button:SetScript("OnClick", function() HandleClick() end)

-- Different color schemes:
local acceptBtn = Components:CreateStyledButton(parent, "Accept", 80, 25, "success")
local declineBtn = Components:CreateStyledButton(parent, "Decline", 80, 25, "danger")
local normalBtn = Components:CreateStyledButton(parent, "Cancel", 80, 25, "default")
```

**Benefits:**
- Consistent 0.15s hover transitions
- Automatic color interpolation
- Built-in tooltip support
- Disabled state handling
- Reduces button code by 90%

**Priority:** High - would eliminate most button duplication

---

## Part 5: Animation & Effects Integration

### Animation Gap A1: Hover Transitions

**Severity:** Medium (Polish)
**Files:** Journal.lua, Components.lua, GameUI.lua (30+ button locations)
**Status:** 🟡 MISSING

**Problem:**
Most buttons use instant color changes on hover. UI_ORGANIZATION_GUIDE.md specifies 0.15s smooth transitions.

**Current Pattern:**
```lua
button:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Instant gold
end)
```

**Should Be:**
```lua
button:SetScript("OnEnter", function(self)
    -- Smooth 0.15s transition to gold
    HopeAddon.Animations:ColorTransition(self, "border",
        self.defaultBorderColor,
        HopeAddon.colors.GOLD_BRIGHT,
        0.15
    )
end)
```

**Fix Procedure:**

```lua
-- Step 1: Add ColorTransition to Animations.lua

function Animations:ColorTransition(frame, property, fromColor, toColor, duration, callback)
    duration = duration or 0.15

    local startTime = GetTime()
    local endTime = startTime + duration

    local ticker = C_Timer.NewTicker(0.03, function()
        local now = GetTime()
        if now >= endTime then
            -- End state
            if property == "border" then
                frame:SetBackdropBorderColor(toColor.r, toColor.g, toColor.b, 1)
            elseif property == "background" then
                frame:SetBackdropColor(toColor.r, toColor.g, toColor.b, toColor.a or 1)
            elseif property == "text" then
                frame:SetTextColor(toColor.r, toColor.g, toColor.b)
            end

            ticker:Cancel()
            if callback then callback() end
        else
            -- Interpolate
            local progress = (now - startTime) / duration
            local r = fromColor.r + (toColor.r - fromColor.r) * progress
            local g = fromColor.g + (toColor.g - fromColor.g) * progress
            local b = fromColor.b + (toColor.b - fromColor.b) * progress

            if property == "border" then
                frame:SetBackdropBorderColor(r, g, b, 1)
            elseif property == "background" then
                local a = (fromColor.a or 1) + ((toColor.a or 1) - (fromColor.a or 1)) * progress
                frame:SetBackdropColor(r, g, b, a)
            elseif property == "text" then
                frame:SetTextColor(r, g, b)
            end
        end
    end)

    return ticker
end

-- Step 2: Update Components:CreateStyledButton to use it (see Abstraction A3 above)

-- Step 3: Batch update existing buttons
-- Priority list:
-- 1. Journal tab buttons (8 buttons)
-- 2. Directory game cards (4 buttons)
-- 3. Profile editor buttons (3 buttons)
-- 4. Game UI buttons (20+ buttons across games)
```

**Testing:**
1. Hover over buttons and observe smooth color transitions
2. Rapid hover on/off should not stack animations
3. Verify 0.15s duration feels responsive

**Priority:** Medium - polish item, affects UX feel

---

### Animation Gap A2: Celebration Effects Missing

**Severity:** Medium (Feature Gap)
**Files:** GameUI.lua, Journal.lua
**Status:** 🔴 MISSING

**Problem:**
Game over screens don't have celebration effects. Progress bars complete without sparkles. Milestones unlock without fanfare.

**Required Integrations:**

```lua
-- Step 1: Add celebration helper to Effects.lua

function Effects:Celebrate(frame, intensity)
    intensity = intensity or "normal"

    if intensity == "minor" then
        -- Small achievement (quest complete, level up)
        self:Sparkles(frame, 1.0)
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayLevelUp()
        end

    elseif intensity == "normal" then
        -- Medium achievement (milestone, badge unlock)
        self:Glow(frame, "achievement", 2.0)
        self:Sparkles(frame, 2.0)
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayAchievement()
        end

    elseif intensity == "major" then
        -- Major achievement (raid boss, attunement)
        self:Glow(frame, "legendary", 3.0)
        self:Sparkles(frame, 3.0)
        HopeAddon.Animations:Bounce(frame, 0.5, 3)
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayEpicWin()
        end
    end
end

-- Step 2: Integrate in GameUI ShowGameOver

function GameUI:ShowGameOver(gameId, result)
    -- ... existing code to create overlay ...

    -- Add celebration
    if result == "WIN" then
        HopeAddon.Effects:Celebrate(overlay, "normal")
    end
end

-- Step 3: Integrate in Journal badge unlock

function Journal:OnBadgeUnlocked(badgeId)
    -- ... existing notification code ...

    -- Add celebration to notification
    HopeAddon.Effects:Celebrate(notification, "normal")
end

-- Step 4: Integrate in progress bar completion

function Components:CreateProgressBar(parent, width)
    -- ... existing code ...

    function bar:SetProgress(value)
        AnimateTo(value, 0.5)

        if value >= 100 and not bar._celebrated then
            bar._celebrated = true
            HopeAddon.Effects:Celebrate(bar, "minor")
        end
    end
end
```

**Testing:**
1. Complete attunement chapter - should see sparkles
2. Win game - should see glow + sparkles + bounce
3. Unlock badge - should see full celebration
4. Complete progress bar - should see minor sparkles

**Priority:** Medium - adds polish and player feedback

---

### Animation Gap A3: PlayHover Undefined

**Severity:** High (Error)
**File:** `Social/Games/GameUI.lua:72`
**Status:** 🔴 BROKEN

**Problem:**
GameUI.lua calls `HopeAddon.Sounds:PlayHover()` but function doesn't exist in Sounds.lua. Causes error on button hover.

**Fix Procedure:**

```lua
-- Add to Sounds.lua

function Sounds:PlayHover()
    if not self.settings.soundEnabled then return end

    PlaySound(1217, "SFX")  -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    -- This is a subtle UI tick sound used for menu interactions
end

-- Alternative sounds to consider:
-- PlaySound(1115, "SFX") -- SOUNDKIT.IG_QUEST_LIST_SELECT (softer)
-- PlaySound(1202, "SFX") -- SOUNDKIT.IG_MAINMENU_OPTION (mechanical)
```

**Testing:**
1. Hover over game UI buttons
2. Should hear subtle tick sound
3. No Lua errors
4. Respect sound settings: `/hope sound`

**Priority:** High - fixes error, improves UX

---

### Animation Gap A4: Collapsible Section Animation

**Severity:** Low (Polish)
**File:** `UI/Components.lua` (CreateCollapsibleSection)
**Status:** 🟡 INCOMPLETE

**Problem:**
Collapsible sections toggle instantly. Should have 0.3s fade + slide animation per UI_ORGANIZATION_GUIDE.md.

**Fix Procedure:**

```lua
-- Update Components:CreateCollapsibleSection toggle function

function section:Toggle()
    self.isExpanded = not self.isExpanded

    if self.isExpanded then
        -- Expand with slide down + fade in
        self.toggleIcon:SetText("▼")
        self.contentContainer:Show()
        self.contentContainer:SetAlpha(0)
        self.contentContainer:SetHeight(0)

        -- Animate height
        local targetHeight = self.contentHeight
        local startTime = GetTime()
        local duration = 0.3

        local ticker = C_Timer.NewTicker(0.03, function()
            local now = GetTime()
            local progress = math.min(1, (now - startTime) / duration)

            -- Ease out cubic
            local eased = 1 - math.pow(1 - progress, 3)

            self.contentContainer:SetHeight(targetHeight * eased)
            self.contentContainer:SetAlpha(eased)

            if progress >= 1 then
                ticker:Cancel()
                if self.onToggle then
                    self.onToggle()
                end
            end
        end)
    else
        -- Collapse with slide up + fade out
        self.toggleIcon:SetText("▶")

        local startHeight = self.contentHeight
        local startTime = GetTime()
        local duration = 0.3

        local ticker = C_Timer.NewTicker(0.03, function()
            local now = GetTime()
            local progress = math.min(1, (now - startTime) / duration)

            -- Ease in cubic
            local eased = math.pow(progress, 3)

            self.contentContainer:SetHeight(startHeight * (1 - eased))
            self.contentContainer:SetAlpha(1 - eased)

            if progress >= 1 then
                self.contentContainer:Hide()
                ticker:Cancel()
                if self.onToggle then
                    self.onToggle()
                end
            end
        end)
    end

    self:UpdateHeight()
end
```

**Testing:**
1. Open Raids tab
2. Toggle T4/T5/T6 sections
3. Should see smooth 0.3s fade + slide
4. No jittery motion

**Priority:** Low - polish item, not blocking

---

## Part 6: Implementation Roadmap

### Phase 1: Critical Stability (Week 1)

**Goal:** Fix memory leaks and multiplayer integrity issues

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| Words CleanupGame | WordGame.lua | 2 hours | P0 |
| Pong Ball Sync | PongGame.lua | 4 hours | P0 |
| Words Board Caching | WordGame.lua | 3 hours | P0 |
| PlayHover Function | Sounds.lua | 30 min | P1 |

**Success Criteria:**
- [ ] No memory leaks after 10 consecutive game sessions
- [ ] Pong scores match exactly between remote players
- [ ] Words board renders < 5ms per update
- [ ] No Lua errors on button hover

**Testing Protocol:**
1. Play each game 10 times in succession
2. Monitor memory: `/run UpdateAddOnMemoryUsage(); print(GetAddOnMemoryUsage("HopeAddon"))`
3. Verify scores match in remote play
4. Check FPS during active gameplay

---

### Phase 2: Layout Consistency (Week 2)

**Goal:** Fix layout bugs and component inconsistencies

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| Scroll Height Fallback | Components.lua | 2 hours | P1 |
| Words Window Size | GameUI.lua, WordGame.lua | 30 min | P1 |
| Frame Reference Patterns | All games | 4 hours | P1 |
| Words Score Validation | WordGame.lua | 2 hours | P1 |

**Success Criteria:**
- [ ] No double-spacing in any journal tab
- [ ] Words game window fits board comfortably
- [ ] All games use ui/state structure
- [ ] Score mismatches logged and handled

**Testing Protocol:**
1. Open all journal tabs, verify spacing
2. Test collapsible section toggle (no layout shift)
3. Play all games, verify cleanup
4. Test score validation with modified dictionary

---

### Phase 3: Code Refactoring (Week 3)

**Goal:** Eliminate duplication and add missing abstractions

| Task | Est. Time | Priority |
|------|-----------|----------|
| CreateBackdropFrame Global | Core.lua + 7 files | 2 hours | P2 |
| LayoutBuilder Component | Components.lua | 3 hours | P2 |
| Labeled Control Factories | Components.lua | 4 hours | P2 |
| Color Helper Utilities | Core.lua | 2 hours | P2 |
| Styled Button Factory | Components.lua | 4 hours | P2 |

**Success Criteria:**
- [ ] ~70 lines of duplication removed
- [ ] ProfileEditor uses LayoutBuilder
- [ ] All forms use labeled controls
- [ ] All color operations use helpers
- [ ] All buttons use factory

**Testing Protocol:**
1. `/reload` after each refactor
2. Test affected UI (journal, games, profile editor)
3. Verify no visual regressions
4. Check for any "attempt to call nil" errors

---

### Phase 4: Animation Integration (Week 4)

**Goal:** Add smooth transitions and celebration effects

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| ColorTransition Function | Animations.lua | 2 hours | P2 |
| Hover Transitions (30+ buttons) | Multiple | 4 hours | P2 |
| Celebrate Helper | Effects.lua | 2 hours | P2 |
| GameOver Celebrations | GameUI.lua | 1 hour | P2 |
| Badge Unlock Celebrations | Journal.lua | 1 hour | P2 |
| Progress Bar Sparkles | Components.lua | 1 hour | P2 |
| Collapsible Animations | Components.lua | 2 hours | P3 |

**Success Criteria:**
- [ ] All buttons have 0.15s hover transitions
- [ ] Game wins show celebration effects
- [ ] Badge unlocks show glow + sparkles
- [ ] Progress bars sparkle on completion
- [ ] Collapsible sections slide smoothly

**Testing Protocol:**
1. Hover rapidly over buttons (no animation stacking)
2. Win games and check for celebrations
3. Unlock badges and verify effects
4. Complete progress bars and check sparkles
5. Toggle collapsible sections (smooth 0.3s)

---

### Phase 5: TBC Theme Audit (Week 5)

**Goal:** Ensure full TBC/Outland aesthetic compliance

| Task | Est. Time | Priority |
|------|-----------|----------|
| Audit PARCHMENT Colors | Core.lua | 1 hour | P2 |
| Replace BROWN in Game Cards | Components.lua | 1 hour | P2 |
| Verify All Tab Colors | Journal.lua | 1 hour | P3 |
| Icon Organization Examples | Documentation | 2 hours | P3 |
| Update UI_ORGANIZATION_GUIDE | UI_ORGANIZATION_GUIDE.md | 2 hours | P3 |

**Success Criteria:**
- [ ] No classic WoW brown colors used
- [ ] All tabs use TBC palette (fel green, arcane purple)
- [ ] Game cards use proper theme colors
- [ ] Documentation shows icon layout examples
- [ ] Color guide updated with actual values

**Testing Protocol:**
1. Visual inspection of all UI elements
2. Compare against TBC zone screenshots (Netherstorm, Shadowmoon Valley)
3. Verify Directory tab uses arcane purple
4. Check game cards use TBC colors

---

### Phase 6: Documentation & Standards (Ongoing)

**Goal:** Keep documentation current with implementation

| Task | Est. Time | Priority |
|------|-----------|----------|
| Update CLAUDE.md with Changes | CLAUDE.md | 30 min per phase | P1 |
| Mark Issues Resolved | This document | 15 min per fix | P1 |
| Add Code Examples | This document | 1 hour per pattern | P2 |
| Create Migration Guides | New docs | 2 hours per major refactor | P2 |

**Success Criteria:**
- [ ] CLAUDE.md reflects current state
- [ ] All fixed issues marked with ✅
- [ ] Code examples match actual implementations
- [ ] Migration guides exist for breaking changes

---

## Part 7: Testing Procedures

### Memory Leak Testing

**Purpose:** Verify no frame/fontstring references persist after cleanup

**Procedure:**
```lua
-- 1. Get baseline memory
/run UpdateAddOnMemoryUsage(); local base = GetAddOnMemoryUsage("HopeAddon"); print("Baseline:", base, "KB")

-- 2. Perform test activity 10 times
--    - Start/end game
--    - Open/close journal
--    - Toggle tabs
--    - etc.

-- 3. Force garbage collection
/run collectgarbage("collect")

-- 4. Check memory again
/run UpdateAddOnMemoryUsage(); local after = GetAddOnMemoryUsage("HopeAddon"); print("After:", after, "KB")

-- 5. Repeat test activity 10 more times

-- 6. Final check
/run UpdateAddOnMemoryUsage(); local final = GetAddOnMemoryUsage("HopeAddon"); print("Final:", final, "KB")

-- Expected: final - base < 500 KB (some growth is normal)
-- Failure: final - base > 2000 KB (indicates leak)
```

**Test Cases:**
1. Words with WoW 10 games
2. Pong 10 games
3. Tetris 10 games
4. Death Roll 10 games
5. Journal tab switching 50 times
6. Profile editor open/close 20 times

---

### Network Synchronization Testing

**Purpose:** Verify game state stays consistent between remote players

**Setup:**
- Two WoW clients on same machine OR two machines
- Both running HopeAddon
- Both characters in same zone/group

**Procedure:**
```lua
-- Client A:
/hope pong <ClientB>

-- Client B accepts

-- Play full match (first to 11 points)

-- Both clients at end:
/run print("My score:", HopeAddon.GameCore.games[GAMEID].data.state.score1)
/run print("Opp score:", HopeAddon.GameCore.games[GAMEID].data.state.score2)

-- Scores MUST match exactly
```

**Test Cases:**
1. Pong - full match, edge cases (corner hits, simultaneous paddle collision)
2. Tetris - full match, rapid garbage exchanges
3. Words - 10 move game, verify board state matches
4. Death Roll - full match, verify roll history matches

**Failure Indicators:**
- Score mismatch
- Board state differs
- "Desync detected" messages
- Game hangs/freezes

---

### Layout Regression Testing

**Purpose:** Verify layout changes don't break existing tabs

**Procedure:**
```
1. Open journal: /hope
2. Screenshot each tab at 1920x1080
3. Apply layout changes
4. /reload
5. Screenshot each tab again
6. Compare screenshots pixel-by-pixel
```

**Checklist:**
- [ ] Timeline: No double-spacing, cards aligned
- [ ] Milestones: Collapsible acts expand/collapse smoothly
- [ ] Zones: Zone cards uniform height
- [ ] Attunements: Progress bars aligned, chapter icons visible
- [ ] Raids: Tier sections expand/collapse, boss cards uniform
- [ ] Reputation: Standing bars aligned, milestone entries visible
- [ ] Statistics: Stat rows aligned, death count visible
- [ ] Directory: Games Hall cards in 3-column grid, traveler list scrolls

---

### Animation Performance Testing

**Purpose:** Verify animations don't cause frame drops

**Procedure:**
```lua
-- 1. Get baseline FPS
/run local fps = GetFramerate(); print("FPS:", fps)

-- 2. Trigger animation-heavy actions:
--    - Rapid button hover on/off (20 times)
--    - Toggle collapsible section 10 times
--    - Win game (celebration effects)
--    - Unlock badge (glow + sparkles)

-- 3. Check FPS during animation
/run local fps = GetFramerate(); print("FPS:", fps)

-- Expected: FPS drop < 5 fps
-- Failure: FPS drop > 10 fps
```

**Test Cases:**
1. Hover 30 buttons rapidly
2. Toggle all collapsible sections
3. Win 5 games in a row (celebrations)
4. Unlock 5 badges (celebrations)
5. Complete 5 progress bars (sparkles)

---

## Part 8: Known Limitations & Future Work

### Current Limitations

1. **No Mobile/Console Support**
   - Addon is PC-only (WoW API limitation)
   - Touch-friendly UI not prioritized

2. **TBC Classic 2.4.3 API Constraints**
   - Some retail APIs unavailable (C_Widget, etc.)
   - Limited animation primitives (no AnimationGroup in TBC)
   - Timer system uses C_Timer polyfill

3. **Network Bandwidth**
   - Pong at 10Hz = 600 messages/minute
   - Tetris garbage floods could spike bandwidth
   - No bandwidth throttling implemented

4. **Dictionary Synchronization**
   - Words with WoW dictionary baked into addon
   - Players with different addon versions may have mismatched dictionaries
   - No runtime dictionary updates

5. **Frame Pool Limits**
   - Pools have no maximum size
   - Large journal entries (1000+ timeline entries) could exhaust memory
   - No pagination implemented

### Future Enhancements

**Planned:**
1. Settings panel in journal
2. Milestone detail modals
3. Attunement icon awards
4. Boss detection verification
5. More minigames (Chess, Hearthstone-like)

**Nice-to-Have:**
1. Customizable UI themes (color schemes)
2. Export/import profile data
3. Guild integration (shared achievements)
4. Raid calendar integration
5. Cross-realm Fellow Traveler detection

**Research Needed:**
1. Compression for network messages (reduce bandwidth)
2. Delta updates for board state (only send changes)
3. Predictive client-side physics with server correction (better Pong sync)
4. Frame pool eviction strategies (LRU cache)

---

## Part 9: Quick Reference for Developers

### How to Fix a Memory Leak

1. **Identify the leak:**
   ```lua
   /run UpdateAddOnMemoryUsage()
   /run print(GetAddOnMemoryUsage("HopeAddon"))
   -- Perform action 10 times
   /run collectgarbage("collect")
   /run UpdateAddOnMemoryUsage()
   /run print(GetAddOnMemoryUsage("HopeAddon"))
   ```

2. **Find unreleased references:**
   - Check for FontStrings not nil'd
   - Check for frames not Hide()/SetParent(nil)
   - Check for event frames not UnregisterAllEvents()
   - Check for timers not canceled

3. **Add cleanup to appropriate function:**
   - Games: `CleanupGame(gameId)`
   - Modules: `OnDisable()`
   - Pools: `resetFunc` in pool definition

4. **Verify fix:**
   - Repeat step 1
   - Memory should stabilize

### How to Add a New Component

1. **Add Create function to Components.lua:**
   ```lua
   function Components:CreateMyComponent(parent, ...)
       local frame = CreateFrame("Frame", nil, parent)
       -- Setup frame
       frame._componentType = "mycomponent"
       frame._designHeight = 50
       return frame
   end
   ```

2. **Update scroll container to recognize type:**
   ```lua
   -- In Components.lua AddEntry function
   elseif entryFrame._componentType == "mycomponent" then
       entryHeight = 50
   ```

3. **Use in populate functions:**
   ```lua
   function Journal:PopulateMyTab()
       local component = HopeAddon.Components:CreateMyComponent(...)
       scrollContainer:AddEntry(component)
   end
   ```

### How to Add a New Game

1. **Define in Constants.lua:**
   ```lua
   C.GAME_DEFINITIONS.MYGAME = {
       id = "MYGAME",
       name = "My Game",
       description = "Description",
       icon = "Interface\\Icons\\...",
       hasLocal = true,
       hasRemote = true,
       system = "turnbased",  -- or "realtime"
       color = HopeAddon.colors.FEL_GREEN,
   }
   ```

2. **Create game file:**
   ```lua
   -- Social/Games/MyGame/MyGame.lua
   local MyGame = {}
   HopeAddon:RegisterModule("MyGame", MyGame)

   function MyGame:OnCreate(gameId, game) end
   function MyGame:OnStart(gameId) end
   function MyGame:OnUpdate(gameId, dt) end  -- If realtime
   function MyGame:OnEnd(gameId, reason) end
   function MyGame:OnDestroy(gameId) end
   function MyGame:OnMoveReceived(fromPlayer, gameId, moveData) end
   function MyGame:CleanupGame(gameId) end
   ```

3. **Register with GameCore:**
   ```lua
   -- In MyGame:OnInitialize()
   HopeAddon.GameCore:RegisterGameType("MYGAME", self)
   ```

4. **Add to .toc file:**
   ```
   Social\Games\MyGame\MyGame.lua
   ```

5. **Test:**
   ```
   /hope mygame [player]
   ```

### How to Add a New Animation

1. **Add to Animations.lua:**
   ```lua
   function Animations:MyAnimation(frame, duration, ...)
       local startTime = GetTime()
       local ticker = C_Timer.NewTicker(0.03, function()
           local progress = (GetTime() - startTime) / duration
           if progress >= 1 then
               ticker:Cancel()
               return
           end
           -- Apply animation based on progress
       end)
       return ticker
   end
   ```

2. **Use in UI code:**
   ```lua
   HopeAddon.Animations:MyAnimation(frame, 0.5, ...)
   ```

3. **Clean up in OnDisable:**
   ```lua
   if self._animationTicker then
       self._animationTicker:Cancel()
       self._animationTicker = nil
   end
   ```

---

## Part 10: Glossary

**Terms Used in This Document:**

| Term | Meaning |
|------|---------|
| **Frame Pool** | Object pool pattern for reusing UI frames to reduce memory allocation |
| **TBC Theme** | Burning Crusade aesthetic (fel green, arcane purple, Outland-inspired) |
| **Server-Authoritative** | Network model where one client (host) controls game state |
| **O(n²) Performance** | Algorithmic complexity indicating quadratic time (inefficient) |
| **Layout Builder** | Pattern for programmatically positioning UI elements without manual offsets |
| **Color Interpolation** | Smooth transition between two colors over time |
| **Easing Function** | Mathematical function for non-linear animation (ease-in, ease-out) |
| **Component Type** | Metadata tag on frames to indicate their purpose (header, card, spacer) |
| **Design Height** | Intended height of a component used as fallback when GetHeight() fails |
| **FontString** | WoW API text rendering object |
| **Backdrop** | WoW API background/border texture system |
| **SavedVariables** | Persistent data stored between game sessions |
| **Slash Command** | In-game command starting with / (e.g., `/hope`) |

---

## Appendix A: File Line Reference

**Critical Issues:**

| Issue | File | Lines |
|-------|------|-------|
| C1: Words Memory Leak | WordGame.lua | 196-203 |
| C2: Pong Ball Desync | PongGame.lua | 556-611 |
| C3: Words Board Performance | WordGame.lua | 610-670 |

**High Priority Issues:**

| Issue | File | Lines |
|-------|------|-------|
| H1: Scroll Height Fallback | Components.lua | 635-636 |
| H2: Words Window Size | GameUI.lua, WordGame.lua | 28-34, 459 |
| H3: Frame Reference Patterns | All games | Throughout |
| H4: Words Score Validation | WordGame.lua | 337-341 |

**Duplications:**

| Duplication | Files | Lines |
|-------------|-------|-------|
| D1: CreateBackdropFrame | 8 files | ~70 lines total |
| D2: Manual Y-Offset | ProfileEditor.lua | 130-246 |

**Animation Gaps:**

| Gap | File | Lines |
|-----|------|-------|
| A1: Hover Transitions | Multiple | 30+ locations |
| A2: Celebration Effects | GameUI.lua, Journal.lua | Throughout |
| A3: PlayHover Undefined | GameUI.lua | 72 |
| A4: Collapsible Animation | Components.lua | CreateCollapsibleSection |

---

## Appendix B: Color Reference

**TBC Palette (from UI_ORGANIZATION_GUIDE.md):**

```lua
-- Fel Green Spectrum
FEL_GREEN = {r=0.20, g=0.80, b=0.20}        -- #32CD32
FEL_GLOW = {r=0.40, g=1.00, b=0.40}         -- #66FF66
OUTLAND_TEAL = {r=0.00, g=0.81, b=0.82}     -- #00CED1

-- Arcane Purple Spectrum
ARCANE_PURPLE = {r=0.61, g=0.19, b=1.00}    -- #9B30FF
NETHER_LAVENDER = {r=0.69, g=0.53, b=0.93}  -- #B088EE
VOID_PURPLE = {r=0.50, g=0.00, b=0.50}      -- #800080

-- Achievement Gold
GOLD_BRIGHT = {r=1.00, g=0.84, b=0.00}      -- #FFD700
GOLD_PALE = {r=1.00, g=0.93, b=0.55}        -- #FFEE8C
BRONZE = {r=0.80, g=0.50, b=0.20}           -- #CD853F

-- Item Quality Colors
POOR = {r=0.62, g=0.62, b=0.62}             -- #9D9D9D (gray)
COMMON = {r=1.00, g=1.00, b=1.00}           -- #FFFFFF (white)
UNCOMMON = {r=0.12, g=1.00, b=0.00}         -- #1EFF00 (green)
RARE = {r=0.00, g=0.44, b=0.87}             -- #0070DD (blue)
EPIC = {r=0.64, g=0.21, b=0.93}             -- #A335EE (purple)
LEGENDARY = {r=1.00, g=0.50, b=0.00}        -- #FF8000 (orange)
```

---

## Document Metadata

**Created:** 2026-01-19
**Status:** Active - v1.0
**Companion Document:** UI_ORGANIZATION_GUIDE.md
**Target Audience:** AI assistants, future developers
**Maintenance:** Update after each fix/refactor phase

---

## Summary

This implementation guide provides:
✓ Complete gap analysis (16 issues across 4 severity levels)
✓ Step-by-step fix procedures with code examples
✓ Refactoring plans to eliminate ~70 lines of duplication
✓ Missing abstractions with implementation templates
✓ Animation integration guide with exact timing specs
✓ Prioritized 6-phase roadmap (5 weeks)
✓ Testing procedures for memory leaks, network sync, layout, performance
✓ Developer quick reference for common tasks

**Use this document to:**
1. Understand what's broken and why
2. Follow fix procedures step-by-step
3. Implement missing features and abstractions
4. Track progress through phased roadmap
5. Verify fixes with provided testing procedures

**Keep this document updated as issues are resolved and new gaps are discovered.**
