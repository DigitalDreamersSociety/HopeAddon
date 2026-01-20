# HopeAddon Game UI Organization Patterns

## Quick Reference for AI Assistants

This document standardizes UI organization across all minigames in HopeAddon.

---

## 1. Window Sizing (GameUI.lua)

All games use centralized window sizes defined in `GameUI.lua:18-27`:

| Key | Dimensions | Use Case |
|-----|------------|----------|
| `SMALL` | 300x200 | Simple games (RPS) |
| `MEDIUM` | 450x350 | Standard games |
| `PONG` | 500x400 | Pong game |
| `TETRIS` | 700x550 | Tetris LOCAL (2 boards) |
| `TETRIS_REMOTE` | 480x520 | Tetris REMOTE (1 board + opponent) |
| `BATTLESHIP` | 700x680 | Battleship (2 grids + instructions) |
| `WORDS` | 700x720 | Words with WoW (15x15 board + rack) |

**Usage:**
```lua
local window = GameUI:CreateGameWindow(gameId, "BATTLESHIP")
```

---

## 2. File Architecture Patterns

### Pattern A: Single File (Recommended for new games)
Used by: **Pong**, **Tetris**, **Words**
- All game logic and UI in one file
- Simpler to maintain
- Good for games with moderate UI complexity

### Pattern B: Dual File (For complex visual effects)
Used by: **DeathRoll** (DeathRollGame.lua + DeathRollUI.lua), **Battleship** (BattleshipGame.lua + BattleshipUI.lua)
- Game logic in `*Game.lua`
- Gameshow animations/frame pools in `*UI.lua`
- Use when: extensive animations, frame pooling, complex visual effects

---

## 3. Standard Data Structure

All games MUST use this structure:

```lua
self.games[gameId] = {
    data = {
        ui = {
            window = nil,           -- Main game window
            -- Game-specific UI elements
        },
        state = {
            phase = "PLACEMENT",    -- Game phase
            -- Game-specific state
        },
    },
}
```

**Examples by game:**

### Pong
```lua
ui = { window, scoreText={p1,p2}, playArea, paddles={p1,p2}, ball, countdown, opponentPanel }
state = { playWidth, playHeight, isRemote, isScoreChallenge, paddle1, paddle2, ball }
```

### Tetris
```lua
ui = { window, countdownText, opponentPanel, boards={[1]={container,gridFrame,cells,labels}, [2]=...} }
state = { boards={[1]=board,[2]=board}, isScoreChallenge, countdown, gameOver }
```

### Battleship
```lua
ui = { window, instructionsPanel, playerGrid, enemyGrid, cells={player={},enemy={}}, statusText }
state = { phase, playerBoard, enemyBoard, currentTurn, playerReady, opponentReady, isLocalGame }
```

---

## 4. Game Lifecycle Callbacks

All games implement these GameCore callbacks:

```lua
function Game:OnCreate(gameId, game)   -- Initialize data structure
function Game:OnStart(gameId)          -- Create UI, show window
function Game:OnUpdate(gameId, dt)     -- Update logic (if needed)
function Game:OnEnd(gameId, reason)    -- Show game over
function Game:OnDestroy(gameId)        -- Cleanup resources
```

---

## 5. Game Modes

### LOCAL Mode
- Two players on same keyboard
- Shows full UI for both players (two boards, etc.)
- "VS" separator in center
- Controls hint shows both player keys

### REMOTE Mode
- Real-time multiplayer via addon messages
- Turn-based synchronization
- Shows opponent name prominently

### SCORE_CHALLENGE Mode
- Both players play independently
- Compare final scores at end
- **Opponent Panel** shows real-time status (see below)

---

## 6. Opponent Panel (SCORE_CHALLENGE Only)

When `isScoreChallenge = true`, show opponent panel:

**Standard Size:** 120x150
**Position:** Right side of main game area
**Contents:**
```
+------------------------+
| VS: OpponentName       |  (gold title)
| Score: 12500          |  (white value)
| Lines: 45             |  (secondary stat)
| [PLAYING]             |  (status label)
+------------------------+
```

**Status Label Colors:**
- `[PLAYING]` - Green (#00FF00)
- `[WAITING]` - Yellow (#FFFF00)
- `[FINISHED]` - Orange (#FF8800)

---

## 7. Vertical Layout Guidelines

### Standard Game Layout (Top to Bottom)

1. **Phase/Title Bar** - Current game phase or title
2. **Main Game Area** - Boards, grids, play area
3. **Status/Instructions** - Turn info, hints
4. **Controls Hint** - Keyboard shortcuts (optional)

### Battleship Specific Layout

```
+--------------------------------------------------+
| STEP 2 OF 5: Place your BATTLESHIP (4 squares)   | ← Instructions Panel (70px)
| Click any cell on YOUR FLEET grid to place       |
| Press R to rotate | Currently: HORIZONTAL →      |
+--------------------------------------------------+
|                                                  |
| [HIT!/MISS!/SUNK! animations appear here]        | ← Announcements Area (100px)
|                                                  |
+--------------------------------------------------+
|  YOUR FLEET          ENEMY WATERS               |
|  +----------+        +----------+               | ← Grids (~316px each)
|  |1234567890|        |1234567890|               |
|  |A · · · · |        |A ? ? ? ? |               |
|  |B █ █ █ █ |        |B ? ? ? ? |               |
|  |C · · · · |        |C X ? ? ? |               |
|  |D · · · · |        |D ? O ? ? |               |
|  |...       |        |...       |               |
|  +----------+        +----------+               |
+--------------------------------------------------+
| [Error messages]                                 | ← Error/Status area
| [Rotate (R)]                                     |
+--------------------------------------------------+
```

---

## 8. Avoiding Duplicate Displays

**CRITICAL:** Each piece of information should appear in ONE place only.

| Information | Where to Show | NOT Here |
|-------------|---------------|----------|
| Turn status | Instructions Panel | BattleshipUI turn prompt |
| Current phase | Instructions Panel | Separate phase text |
| Ship placement | Instructions Panel | Status text |
| Shot results | Announcements (animated) | Multiple places |
| Game over | Victory overlay | Status text |

**Anti-Pattern (Don't do this):**
```lua
-- BAD: Duplicate turn indicators
ui.instructionsText:SetText("YOUR TURN!")  -- Here...
BattleshipUI:ShowTurnPrompt("YOUR_TURN")   -- AND here!
```

**Correct Pattern:**
```lua
-- GOOD: Single source of truth
if state.phase == "PLAYING" then
    ui.instructionsPanel:Show()  -- Instructions panel is THE turn indicator
    BattleshipUI:HideTurnPrompt(gameId)  -- Hide the duplicate
end
```

---

## 9. Cell/Grid Rendering Pattern

Follow Tetris pattern for efficient grid rendering:

```lua
-- Create cells once
for row = 1, gridSize do
    cells[row] = {}
    for col = 1, gridSize do
        local cell = gridFrame:CreateTexture(nil, "BACKGROUND")
        cell:SetSize(cellSize - 1, cellSize - 1)  -- Gap for separation
        cell:SetPoint("TOPLEFT", gridFrame, "TOPLEFT",
            col * cellSize, -(HEADER_HEIGHT + row * cellSize))
        cell:SetColorTexture(0.1, 0.3, 0.5, 1)  -- Default water color
        cells[row][col] = cell
    end
end

-- Update cells efficiently (only changed cells)
function UpdateCell(cells, row, col, state)
    local color = COLORS[state]
    cells[row][col]:SetColorTexture(color.r, color.g, color.b, 1)
end
```

---

## 10. Color Standards

### Battleship Cell Colors
```lua
COLORS = {
    WATER = { r = 0.1, g = 0.3, b = 0.5 },       -- Blue (empty)
    WATER_HOVER = { r = 0.15, g = 0.4, b = 0.6 }, -- Light blue (hover)
    SHIP = { r = 0.4, g = 0.4, b = 0.4 },        -- Gray (your ships)
    HIT = { r = 0.8, g = 0.2, b = 0.2 },         -- Red (hit)
    MISS = { r = 0.3, g = 0.3, b = 0.5 },        -- Light blue (miss)
    SUNK = { r = 0.5, g = 0.1, b = 0.1 },        -- Dark red (sunk)
}
```

### Status Text Colors
```lua
YOUR_TURN = "|cFF00FF00>>> YOUR TURN! <<<|r"     -- Green
ENEMY_TURN = "|cFFFFFF00AI'S TURN|r"            -- Yellow
WAITING = "|cFFFFFF00WAITING...|r"              -- Yellow
ERROR = "|cFFFF3333message|r"                   -- Red
SUCCESS = "|cFF00FF00message|r"                 -- Green
GOLD_HINT = "|cFFFFD700hint text|r"             -- Gold
```

---

## 11. Phase-Based UI Visibility

Show/hide UI elements based on current phase:

```lua
function UpdateUIForPhase(gameId)
    local phase = state.phase

    if phase == "PLACEMENT" then
        ui.instructionsPanel:Show()
        ui.rotateBtn:Show()
        -- Enemy grid can be hidden or shown as "fog of war"

    elseif phase == "WAITING_OPPONENT" then
        ui.instructionsPanel:Show()
        ui.rotateBtn:Hide()

    elseif phase == "PLAYING" then
        ui.instructionsPanel:Show()  -- Shows turn info
        ui.rotateBtn:Hide()
        -- Both grids visible

    elseif phase == "ENDED" then
        ui.instructionsPanel:Hide()
        -- Show victory overlay instead
    end
end
```

---

## 12. Frame Pool Usage (Dual-File Pattern)

When using a separate UI module for animations:

```lua
-- In *UI.lua OnEnable:
function UI:OnEnable()
    self:CreateFramePools()
end

function UI:CreateFramePools()
    self.shotResultPool = FramePool:NewNamed("Battleship_ShotResult", createFunc, resetFunc)
    self.turnPromptPool = FramePool:NewNamed("Battleship_TurnPrompt", createFunc, resetFunc)
end

-- Acquire frames per-game:
function UI:InitializeGameFrames(gameId, parent)
    self.gameFrames[gameId] = {
        shotResult = self:AcquireShotResultFrame(parent),
    }
end

-- Release on cleanup:
function UI:CleanupGameFrames(gameId)
    if self.shotResultPool then
        self.shotResultPool:Release(frames.shotResult)
    end
    self.gameFrames[gameId] = nil
end
```

---

## 13. Checklist for New Games

- [ ] Define window size in GameUI.lua
- [ ] Use `game.data.ui` and `game.data.state` structure
- [ ] Implement all 5 lifecycle callbacks
- [ ] Single source for each piece of information
- [ ] Phase-based UI visibility
- [ ] Consistent color scheme
- [ ] Controls hints for keyboard shortcuts
- [ ] Opponent panel if SCORE_CHALLENGE mode
- [ ] Frame pools for animated elements (if dual-file)
- [ ] CleanupGame releases all resources

---

## 14. File Reference

| Game | Main File | UI File | Lines |
|------|-----------|---------|-------|
| Pong | PongGame.lua | (none) | ~1200 |
| Tetris | TetrisGame.lua | (none) | ~1950 |
| DeathRoll | DeathRollGame.lua | DeathRollUI.lua | ~600 + ~400 |
| Battleship | BattleshipGame.lua | BattleshipUI.lua | ~1440 + ~690 |
| Words | WordGame.lua | (none) | ~3940 |
