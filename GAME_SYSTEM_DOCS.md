# HopeAddon Game System Documentation

This document contains detailed game implementation specifications, state machines, and core loop documentation for all minigames in HopeAddon.

For quick reference and API summaries, see [CLAUDE.md](CLAUDE.md).

---

## Game System Architecture

The game system provides a framework for implementing multiplayer games with local and remote play modes.

### Core Components

**GameCore** - Game loop and state machine
- 60 FPS update loop with delta time
- State management (IDLE, WAITING, PLAYING, PAUSED, ENDED)
- Support for multiple game types (TETRIS, PONG, DEATH_ROLL, WORDS)
- Support for LOCAL, NEARBY, REMOTE, and SCORE_CHALLENGE modes
- Input state tracking and utilities (collision, lerp, clamp)

**GameUI** - Shared UI framework
- Draggable game windows with title bars
- Styled buttons, score displays, timers
- Invite dialog system for multiplayer challenges
- Game over overlays with stats
- Window size definitions per game type
- Opponent status panels for SCORE_CHALLENGE mode

**GameComms** - Network communication
- Addon messaging protocol for multiplayer
- Invite/accept/decline flow with 60s timeout
- Game state synchronization
- Move/action messaging during gameplay
- Integration with FellowTravelers communication
- Routes SCORE_ game types to ScoreChallenge module

**ScoreChallenge** - Turn-based multiplayer for real-time games
- Converts Tetris/Pong to score-based challenges (play locally, compare scores)
- Status pings every 10 seconds show opponent progress
- Simple anti-cheat with hash tokens
- Handles invite/accept/decline separately from real-time games
- Timeouts: 60s challenge accept, 600s game, 120s wait for opponent

### Game Lifecycle

```lua
-- 1. Create game instance
GameCore:CreateGame(GAME_TYPE.TETRIS, GAME_MODE.REMOTE, opponent)

-- 2. Initialize (calls TetrisGame:OnCreate)
TetrisGame:OnCreate(gameId, game)

-- 3. Start game (calls TetrisGame:OnStart)
GameCore:StartGame(gameId)

-- 4. Update loop (30 FPS)
GameCore:OnUpdate(dt) → TetrisGame:OnUpdate(gameId, dt)

-- 5. End game (calls TetrisGame:OnEnd)
GameCore:EndGame(gameId, reason)

-- 6. Cleanup (calls TetrisGame:OnDestroy)
GameCore:DestroyGame(gameId)
```

### Network Protocol

Messages follow format: `TYPE:VERSION:GAMETYPE:GAMEID:DATA`

| Type | Purpose | Example |
|------|---------|---------|
| GINV | Game invite | `GINV:1:TETRIS::` |
| GACC | Accept invite | `GACC:1:TETRIS:abc123:` |
| GDEC | Decline invite | `GDEC:1:TETRIS::` |
| GMOV | Game action/move | `GMOV:1:TETRIS:abc123:GARBAGE\|4` |
| GEND | Game ended | `GEND:1:TETRIS:abc123:LOSS\|1250` |

### Game Implementations

**Quick Summary:** Tetris (local 2P or score challenge), Pong (local 2P or vs AI score challenge), Death Roll (gambling + escrow), Words with WoW (Scrabble-style), Battleship (local AI or true multiplayer)

---

## Pong

### Overview
- **PongGame** - Classic arcade with ball physics, paddle collision, score to 5
- **LOCAL:** 2 players on same keyboard (W/S and Up/Down)
- **SCORE_CHALLENGE:** Player vs AI paddle, compare who beats AI faster/better
- **AI Paddle:** 85% tracking with prediction, beatable but challenging

### Core Loop Details

**File:** `Social/Games/Pong/PongGame.lua` (~1193 lines)

**Constants (SETTINGS):**
| Setting | Value | Description |
|---------|-------|-------------|
| PLAY_WIDTH | 400 | Play area width in pixels |
| PLAY_HEIGHT | 300 | Play area height in pixels |
| PADDLE_WIDTH | 10 | Paddle width |
| PADDLE_HEIGHT | 60 | Paddle height |
| PADDLE_SPEED | 300 | Pixels per second |
| PADDLE_MARGIN | 20 | Distance from edge |
| BALL_SIZE | 10 | Ball dimensions |
| BALL_INITIAL_SPEED | 200 | Starting ball speed |
| BALL_MAX_SPEED | 400 | Maximum ball speed |
| BALL_SPEED_INCREMENT | 10 | Speed increase per paddle hit |
| WINNING_SCORE | 5 | Score to win |
| NETWORK_UPDATE_HZ | 10 | Network sync rate (remote mode) |

**Game Data Structure:**
```lua
game.data = {
    ui = {
        window = Frame,           -- Main game window
        scoreText = { p1, p2 },   -- Score FontStrings
        playArea = Frame,         -- Play area container
        paddles = { p1, p2 },     -- Paddle frames
        ball = Frame,             -- Ball frame
        countdown = { text, timer }, -- Countdown display
        opponentPanel = Frame,    -- Score challenge opponent panel
    },
    state = {
        playWidth = 400,          -- Play area bounds
        playHeight = 300,
        isRemote = bool,          -- REMOTE mode flag
        isScoreChallenge = bool,  -- SCORE_CHALLENGE mode flag
        isHost = bool,            -- Host controls ball physics
        opponent = string,        -- Opponent name
        paddleSyncTimer = 0,      -- Network throttle timer
        lastOpponentMessage = timestamp, -- Disconnect detection
        paddle1 = { x, y, width, height, dy },
        paddle2 = { x, y, width, height, dy },
        ball = { x, y, size, dx, dy, speed },
        serving = 1|2,            -- Who serves next
        paused = false,
        countdown = 3,            -- Pre-serve countdown
    },
}
```

**Core Loop Flow:**
```
OnUpdate(gameId, dt)
    │
    ├─ Check opponent disconnect (REMOTE: 10s timeout)
    │
    ├─ Skip if paused or countdown > 0
    │
    ├─ UpdatePaddles(gameId, dt)
    │   ├─ SCORE_CHALLENGE: UpdateLocalPaddle + UpdateAIPaddle
    │   ├─ REMOTE: UpdateLocalPaddle + SendPaddlePosition
    │   └─ LOCAL: UpdateLocalPaddles (both via keyboard)
    │
    ├─ UpdateBall(gameId, dt)
    │   ├─ Skip if REMOTE client (host controls ball)
    │   ├─ Move ball: x += dx*dt, y += dy*dt
    │   ├─ Wall collision: Bounce off top/bottom
    │   ├─ Paddle collision: Reverse dx, add spin from hit position
    │   ├─ Speed increase: min(speed + 10, 400)
    │   └─ Score detection: ball past paddle edge
    │
    └─ UpdateUI(gameId) - Position all visual elements
```

**Paddle Update Modes:**

| Mode | paddle1 | paddle2 |
|------|---------|---------|
| LOCAL | W/S keys | Up/Down keys |
| REMOTE | W/S keys | Network sync |
| SCORE_CHALLENGE | W/S keys | AI controlled |

**AI Paddle Logic (UpdateAIPaddle):**
1. Only reacts when ball moving toward paddle2 (dx > 0)
2. Predicts ball intersection point at paddle2.x
3. Moves toward predicted Y at 85% tracking speed
4. When ball moving away, slowly returns to center
5. Beatable due to slight lag and imperfect tracking

**Ball Physics:**
- Velocity normalized after paddle hit via `NormalizeBallSpeed()`
- Spin added based on hit position: `dy += normalizedHit * 100`
  - normalizedHit = (ballCenterY - paddleCenterY) / (paddleHeight / 2)
- Speed increases by 10 per hit, capped at 400

**Collision Detection:**
- Uses `GameCore:CheckCollision()` (AABB)
- Ball repositioned on collision to prevent tunneling
- Bounce triggers PlayBounceSound() or PlayHitSound()

**Network Sync (REMOTE mode):**
- Host sends paddle position + ball state at 10 Hz
- Client receives and applies opponent paddle/ball updates
- Message format: `PADDLE|y|dy` or `BALL|x|y|dx|dy|speed`
- 10-second disconnect timeout

**Lifecycle Functions:**
| Function | Purpose |
|----------|---------|
| OnCreate | Initialize state structure, determine host |
| OnStart | CreateUI, StartCountdown |
| OnUpdate | Main loop (paddles, ball, UI) |
| OnPause/OnResume | Toggle paused flag |
| OnEnd | Record stats, show GameOver overlay |
| OnDestroy | CleanupGame (release UI, clear key states) |

**Key Entry Points:**
- `PongGame:StartGame()` - Create LOCAL game (public API)
- `GameCore:CreateGame(PONG, mode, opponent)` - Internal creation
- Keyboard: W/S (paddle1), Up/Down (paddle2 in LOCAL)
- Escape toggles pause

---

## Death Roll

- **DeathRollGame** - Turn-based gambling (100 → N → 1, first to roll 1 loses), uses real `/roll` chat command
- **DeathRollEscrow** - 3-player escrow system with automatic payout, dispute resolution, trust verification

---

## Words with WoW

### Overview
- **WordGame** - Scrabble-style with WoW vocabulary, slash command input (`/word DRAGON H 8 8`), text-based 15x15 board, cross-word validation, pass system (2 consecutive passes ends game)
- **WordBoard** - 15x15 grid with bonus squares (double/triple letter/word), placement validation (connectivity, bounds, center), cross-word detection and scoring
- **WordDictionary** - ~500 WoW-themed words, hash table for O(1) validation, standard Scrabble letter values, tile bag generation

### Core Loop Details

**Files:** 5 core files totaling ~5,750 lines
- `WordGame.lua` (~3,940 lines) - Main controller, UI, AI, game logic
- `WordBoard.lua` (464 lines) - 15x15 grid, placement validation, scoring
- `WordDictionary.lua` (250 lines) - Word validation, letter values
- `WordGamePersistence.lua` (528 lines) - Save/load for async multiplayer
- `WordGameInvites.lua` (571 lines) - Multiplayer invite protocol

**Game Lifecycle:**
```
StartGame(opponent)
    ↓
GameCore:CreateGame(WORDS, mode)  →  OnCreate(gameId)  →  OnStart(gameId)
    ↓                                     ↓                    ↓
mode = LOCAL or REMOTE           Initialize state      Create tile bag
                                 Create UI pools       Deal 7 tiles each
                                                       Set PLAYER1_TURN
                                                       ShowUI()
```

**State Machine:**
```
WAITING_TO_START
       ↓ (OnStart)
PLAYER1_TURN ←→ PLAYER2_TURN  (via NextTurn after each move/pass)
       ↓              ↓
       └──────────────┴──→ FINISHED (when consecutivePasses >= 2)
```

**Game Data Structure:**
```lua
game.data = {
    ui = {
        window,                    -- Main game window
        boardContainer,            -- 15x15 grid parent
        tileFrames[row][col],      -- 225 tile frames (pooled)
        rackFrame, rackTiles[],    -- Player's 7-tile hand
        turnBanner,                -- "YOUR TURN!" display
        p1Frame, p2Frame,          -- Player score panels
    },
    state = {
        board = WordBoard:New(),   -- 15x15 grid instance
        gameState = "PLAYER1_TURN",
        scores = { [p1] = 0, [p2] = 0 },
        moveHistory = {},          -- All moves with scores
        consecutivePasses = 0,     -- Triggers end at 2
        turnCount = 0,
        tileBag = {},              -- Remaining drawable tiles
        playerHands = {
            [player1] = { "A", "E", ... },  -- 7 tiles max
            [player2] = { ... },
        },
        recentlyPlaced = {},       -- For glow effect (3s)
    }
}
```

**Word Placement Flow (`/word DRAGON H 8 8`):**
```
ParseAndPlaceWord("DRAGON", "H", "8", "8", playerName)
    ↓
1. Validate syntax (word, direction ∈ {H,V}, row/col numbers)
    ↓
2. PlaceWord(gameId, "DRAGON", horizontal=true, row=8, col=8)
    ↓
3. Validation Pipeline (WordBoard:CanPlaceWord):
   a. Bounds check: word fits within 1-15 grid
   b. Dictionary check: IsValidWord(word) - O(1) hash lookup
   c. Connectivity: First word must cover CENTER (8,8)
                    Subsequent words must connect to existing tiles
   d. Tile conflicts: If cell occupied, new letter must match
   e. Cross-word validation: All perpendicular words formed must be valid
    ↓
4. board:PlaceWord() - Write letters to cells
    ↓
5. FindFormedWords() - Get all words created (main + cross-words)
    ↓
6. CalculateScore() for each formed word
    ↓
7. Update scores, moveHistory, consecutivePasses=0
    ↓
8. RefillHand() - Draw replacement tiles from bag
    ↓
9. ShowScoreToast() + PlaySound()
    ↓
10. NextTurn() - Switch to other player
    ↓
11. If REMOTE: Send move via GameComms
```

### Scoring System

**Letter Values (Scrabble standard):**
- 1pt: E, A, I, O, N, R, T, L, S, U
- 2pt: D, G
- 3pt: B, C, M, P
- 4pt: F, H, V, W, Y
- 5pt: K
- 8pt: J, X
- 10pt: Q, Z

**Bonus Squares (symmetric pattern):**
| Type | Multiplier | Color | Count |
|------|------------|-------|-------|
| Double Letter | 2x letter | Green (DL) | 24 |
| Triple Letter | 3x letter | Blue (TL) | 24 |
| Double Word | 2x word | Purple (DW) | 17 |
| Triple Word | 3x word | Red (TW) | 11 |
| Center | 2x word | Gold (★) | 1 |

**Scoring Formula:**
```lua
totalScore = 0
wordMultiplier = 1

for each letter in word:
    value = LETTER_VALUES[letter]
    if tile is NEW (just placed):
        if DOUBLE_LETTER: value *= 2
        if TRIPLE_LETTER: value *= 3
        if DOUBLE_WORD or CENTER: wordMultiplier *= 2
        if TRIPLE_WORD: wordMultiplier *= 3
    totalScore += value

return totalScore * wordMultiplier
```
Note: Bonuses only apply to newly placed tiles, not existing ones.

### Multiplayer Protocol (via GameComms)
| Type | Format | Purpose |
|------|--------|---------|
| MOVE | `word\|H/V\|row\|col\|score` | Word placement |
| PASS | (no data) | Pass turn |
| WINV | serialized state | Game invite |
| WACC | gameId | Accept invite |
| WDEC | gameId | Decline invite |
| WSYNC | full state | Resume sync |

Anti-Cheat: Local score recalculation on every received move. Mismatches logged but local calculation used.

### Persistence (Async Multiplayer)

**Storage:** `HopeAddonCharDB.savedGames.words`
```lua
{
    games = { [opponentName] = serializedState },
    pendingInvites = { [sender] = { state, timestamp } },
    sentInvites = { [recipient] = { state, timestamp } },
}
```

**Sparse Board Format (only cells with letters stored):**
```lua
sparse = {
    [8] = { [8] = "D", [9] = "R", [10] = "A" },
    [9] = { [8] = "A" },
}
```

**Timeouts:**
- Invite expiry: 24 hours
- Inactivity forfeit: 30 days
- Max concurrent games: 10

**Game End Conditions:**
1. Both Pass Consecutively: `consecutivePasses >= 2` → automatic end
2. Forfeit: Player calls `/hope words forfeit <player>`
3. Winner: Highest score (ties: whoever finished turn last)

### Slash Commands
| Command | Description |
|---------|-------------|
| `/hope words` | Start local practice game |
| `/hope words <player>` | Resume or start vs player |
| `/hope words list` | Show all active games |
| `/hope words forfeit <player>` | Forfeit specific game |
| `/hope words accept [player]` | Accept pending invite |
| `/hope words decline [player]` | Decline pending invite |
| `/word <word> <H/V> <row> <col>` | Place word (e.g., `/word DRAGON H 8 8`) |
| `/pass` | Pass your turn |

### Frame Pooling
- boardTile pool (~225 frames) - 15x15 grid tiles
- rackTile pool (~7 frames) - Player hand display
- toast pool - Animated score popups
- Lifecycle: `OnEnable` → CreateFramePools | Game → Acquire/Release | `OnDisable` → DestroyFramePools

### Key Functions Reference
| Function | File | Purpose |
|----------|------|---------|
| `StartGame(opponent)` | WordGame | Entry point |
| `OnCreate/OnStart/OnEnd` | WordGame | Lifecycle hooks |
| `PlaceWord()` | WordGame | Main placement logic |
| `PassTurn()` | WordGame | Handle pass action |
| `NextTurn()` | WordGame | Switch active player |
| `HandleRemoteMove/Pass()` | WordGame | Network handlers |
| `ShowUI/UpdateUI()` | WordGame | Rendering |
| `CanPlaceWord()` | WordBoard | Full validation |
| `PlaceWord()` | WordBoard | Write letters |
| `CalculateWordScore()` | WordBoard | Scoring with bonuses |
| `FindFormedWords()` | WordBoard | Cross-word detection |
| `IsValidWord()` | WordDictionary | O(1) dictionary check |
| `SaveGame/LoadGame()` | Persistence | Async storage |
| `SendInvite/AcceptInvite()` | Invites | Multiplayer flow |

---

## Battleship

### Overview
- **BattleshipGame** - Classic naval battle with 10x10 grid, place 5 ships, take turns firing
- **LOCAL:** vs Hunt/Target AI (20% error rate for beatable difficulty)
- **REMOTE:** True turn-based multiplayer with shot/result sync
- **Controls:** Click to place ships, R to rotate | `/fire A5` to shoot, `/ready` when placed, `/surrender` to forfeit
- **BattleshipBoard** - Grid management, ship placement validation, shot processing (HIT/MISS/SUNK)
- **BattleshipAI** - Hunt mode (checkerboard pattern) + Target mode (follow up hits)
- **GameChat** - Reusable `/gc` chat for in-game communication during any multiplayer game

### Core Loop Details

**Files:**
| File | Lines | Purpose |
|------|-------|---------|
| `BattleshipGame.lua` | ~1200 | Main controller, UI, network handlers |
| `BattleshipBoard.lua` | ~400 | 10x10 grid, ship placement, shot logic |
| `BattleshipAI.lua` | ~280 | Hunt/Target AI algorithm |
| `BattleshipUI.lua` | ~680 | Gameshow-style animations (shot results, sunk celebrations, turn prompts) |

### State Machine

| State | Description | Valid Transitions |
|-------|-------------|-------------------|
| `PLACEMENT` | Initial - player placing ships | → `WAITING_OPPONENT` (network) or → `PLAYING` (local) |
| `WAITING_OPPONENT` | Network - awaiting opponent ready | → `PLAYING` when both ready |
| `PLAYING` | Active gameplay - alternating shots | → `ENDED` on win/loss/surrender |
| `ENDED` | Game concluded | None (terminal) |

**State Transition Diagram:**
```
┌──────────────┐
│  PLACEMENT   │
└──────┬───────┘
       │ AllShipsPlaced()
       ├──────────────────────────────┐
       ▼                              ▼
┌──────────────┐              ┌──────────────────┐
│   PLAYING    │◄─────────────│ WAITING_OPPONENT │
│   (local)    │  Both ready  │    (network)     │
└──────┬───────┘              └──────────────────┘
       │ Win/Loss/Surrender
       ▼
┌──────────────┐
│    ENDED     │
└──────────────┘
```

**Game Data Structure (BattleshipGame.lua:82-108):**
```lua
self.games[gameId] = {
    data = {
        ui = {
            window = nil,           -- Main game window frame
            playerGrid = nil,       -- Player's fleet grid
            enemyGrid = nil,        -- Enemy tracking grid
            statusText = nil,       -- Status display
            shipButtons = {},       -- Ship selection buttons
            cells = { player = {}, enemy = {} }, -- [row][col] = cellFrame
        },
        state = {
            phase = "PLACEMENT",    -- PLACEMENT | WAITING_OPPONENT | PLAYING | ENDED
            playerBoard = Board,    -- Player's board data (BattleshipBoard)
            enemyBoard = Board,     -- Enemy's board data
            currentTurn = nil,      -- "player" | "enemy" | "waiting"
            placementOrientation = "H",  -- Ship rotation (H or V)
            isLocalGame = bool,     -- true = vs AI, false = vs player
            aiState = nil,          -- BattleshipAI instance (local only)
            winner = nil,           -- "player" | "enemy" | nil
            shotsFired = 0,         -- Statistics counter
            -- Network-specific:
            playerReady = false,    -- Has local player signaled ready
            opponentReady = bool,   -- AI always true
            isChallenger = bool,    -- Determines first shooter
            sunkEnemyShips = 0,     -- Win condition counter (network)
        },
    },
}
```

**Note:** The game uses `BattleshipUI` module for enhanced gameshow-style animations (shot results, ship sunk celebrations, turn prompts). Falls back to simple sounds if BattleshipUI is unavailable.

### Ship Definitions (BattleshipBoard.lua:25-31)

| Ship | ID | Size |
|------|----|------|
| Carrier | `carrier` | 5 |
| Battleship | `battleship` | 4 |
| Cruiser | `cruiser` | 3 |
| Submarine | `submarine` | 3 |
| Destroyer | `destroyer` | 2 |

### Cell States (BattleshipBoard.lua:16-22)
```lua
CELL = {
    EMPTY = 0,    -- Unshot water
    SHIP = 1,     -- Unshot ship (hidden from opponent)
    HIT = 2,      -- Hit but not sunk
    MISS = 3,     -- Miss
    SUNK = 4,     -- Ship sunk
}
```

### Key Functions

| Function | File:Line | Purpose |
|----------|-----------|---------|
| `PlaceShip()` | BattleshipGame.lua:392-424 | Place ship at coordinates |
| `ToggleOrientation()` | BattleshipGame.lua:427-437 | Rotate H ↔ V (R key) |
| `SignalReady()` | BattleshipGame.lua:905-942 | Signal placement complete |
| `PlayerShoot()` | BattleshipGame.lua:225-316 | Player fires shot |
| `AITurn()` | BattleshipGame.lua:318-386 | AI takes turn |
| `ProcessOpponentShot()` | BattleshipGame.lua:989-1036 | Handle incoming shot |
| `ProcessShotResult()` | BattleshipGame.lua:1058-1126 | Handle shot result |
| `CanPlaceShip()` | BattleshipBoard.lua:79-105 | Validate placement |
| `FireShot()` | BattleshipBoard.lua:203-255 | Execute shot on grid |
| `AllShipsSunk()` | BattleshipBoard.lua:278-291 | Check win condition |

### Combat Turn Flow
```
PLAYER'S TURN:
    /fire A5 → ParseCoord("A5") → row=5, col=1
         │
         ▼
    PlayerShoot(gameId, 5, 1)
         │
         ├─ LOCAL MODE:
         │   FireShot(enemyBoard, row, col)
         │   UpdateEnemyCell() → Sound feedback
         │   Check AllShipsSunk()? → EndGame or switch turn
         │   Timer:After(0.8s) → AITurn()
         │
         └─ NETWORK MODE:
             SendShot(gameId, row, col)
             Set currentTurn = "waiting"
             Wait for RESULT message
```

### AI Algorithm (BattleshipAI.lua)

| Mode | Behavior |
|------|----------|
| HUNT | Random shots in checkerboard pattern |
| TARGET | Follow up hits - check adjacent cells |

```
GetNextShot(aiState, board):
    1. Roll for error (20% chance) → random valid cell
    2. If TARGET mode → return next from hitStack
    3. HUNT mode → checkerboard pattern cell
```

### Network Protocol

| Type | Format | Purpose |
|------|--------|---------|
| `SHOT` | `SHOT\|row\|col` | Fire at coordinates |
| `RESULT` | `RESULT\|row\|col\|hit\|sunk\|shipName` | Shot result |
| `READY` | `READY` | Placement complete |
| `SURRENDER` | `SURRENDER` | Forfeit game |

### Network Flow
```
Player A                           Player B
    │ /ready → SendReady()             │
    ├──────────────────────────────────►
    │            STATE: "READY"        │
    │◄──────────────────────────────────
    │            STATE: "READY"        │
    │ Both ready → PLAYING phase       │
    │                                  │
    │ /fire A5 → SendShot()            │
    ├──────────────────────────────────►
    │            MOVE: "SHOT|5|1"      │
    │                                  │
    │                ProcessOpponentShot()
    │                SendShotResult()
    │◄──────────────────────────────────
    │      MOVE: "RESULT|5|1|1|0|Battleship"
    │ ProcessShotResult()              │
    │ Switch turns                     │
```

### UI Structure
```
Window frame (GameUI:CreateGameWindow)
├─ Content frame
│   ├─ Player Grid (11×11 cells)
│   │   ├─ Header: "YOUR FLEET"
│   │   ├─ Column labels: A-J
│   │   ├─ Row labels: 1-10
│   │   └─ 100 interactive cells
│   │
│   ├─ Enemy Grid (11×11 cells)
│   │   ├─ Header: "ENEMY WATERS"
│   │   └─ 100 interactive cells
│   │
│   ├─ Status text
│   └─ Rotate button [R]
│
└─ Keyboard handler (R=rotate, ESC=quit)
```

### Grid Colors (BattleshipGame.lua:22-32)

| State | RGB | Description |
|-------|-----|-------------|
| WATER | (0.1, 0.3, 0.5) | Default cell |
| WATER_HOVER | (0.15, 0.4, 0.6) | Hover effect |
| SHIP | (0.4, 0.4, 0.4) | Player's ship |
| HIT | (0.8, 0.2, 0.2) | Hit marker |
| MISS | (0.3, 0.3, 0.5) | Miss marker |
| SUNK | (0.5, 0.1, 0.1) | Sunk ship |

### GameCore Lifecycle

| Callback | Purpose |
|----------|---------|
| `OnCreate()` | Initialize boards, AI (local), UI data |
| `OnStart()` | Show UI, begin placement phase |
| `OnUpdate()` | Minimal (turn-based) |
| `OnEnd()` | Display result, play sound |
| `OnDestroy()` | CleanupGame |

### Complete Game Trace (Local Mode)
```
1. /hope battleship
   └─ GameCore:CreateGame("BATTLESHIP", "LOCAL")
      └─ OnCreate():
         ├─ Create playerBoard + enemyBoard (Board:Create())
         ├─ Create AI instance (AI:Create())
         └─ AI places ships on enemyBoard (AI:PlaceShips())

2. PLACEMENT PHASE (phase = "PLACEMENT")
   └─ Player clicks cells → OnCellClick() → PlaceShip()
      ├─ Board:PlaceShip() validates and records ship
      ├─ UpdatePlayerGrid() refreshes UI
      └─ When all 5 placed → StartPlaying()

3. COMBAT PHASE (phase = "PLAYING")
   └─ StartPlaying():
      ├─ Random first turn (50/50)
      └─ If AI first: Timer:After(0.8s) → AITurn()

   Player's turn (currentTurn = "player"):
   └─ /fire A5 → PlayerShoot()
      ├─ Board:FireShot(enemyBoard) → result
      ├─ BattleshipUI:ShowShotResult() (animation)
      ├─ Check AllShipsSunk()? → EndGame("WIN")
      ├─ currentTurn = "enemy"
      └─ Timer:After(animDelay + 0.3s) → AITurn()

   AI's turn (currentTurn = "enemy"):
   └─ AITurn()
      ├─ AI:GetNextShot() → row, col
      ├─ Board:FireShot(playerBoard) → result
      ├─ AI:ProcessResult() (update AI state)
      ├─ BattleshipUI:ShowShotResult() (animation)
      ├─ Check AllShipsSunk()? → EndGame("LOSS")
      ├─ currentTurn = "player"
      └─ Timer:After(animDelay) → UpdateStatus()

4. GAME END (phase = "ENDED")
   └─ GameCore:EndGame(gameId, "WIN"/"LOSS")
      └─ OnEnd():
         ├─ Set winner = "player"/"enemy"
         ├─ Display result message
         └─ Play victory/defeat sound

5. CLEANUP
   └─ CleanupGame():
      ├─ BattleshipUI:CleanupGameFrames()
      ├─ Hide window, clear key handlers
      └─ Remove from self.games registry
```

---

## Score Challenge System

For real-time games (Tetris, Pong), the SCORE_CHALLENGE mode provides reliable multiplayer over WoW's latency-prone addon communication:

1. **Challenge Flow:**
   - `/hope tetris PlayerName` or `/hope pong PlayerName` sends challenge
   - Opponent receives notification, uses `/hope accept` or `/hope decline`
   - Both players start their own local game simultaneously

2. **During Game:**
   - Status pings every 10 seconds show opponent's score/lines/level
   - Opponent panel displays in game UI
   - Pong: Play against AI paddle, not directly against opponent

3. **Game End:**
   - When local game ends, wait for opponent (up to 2 minutes)
   - Compare final scores, declare winner
   - Tie-breaker: whoever finished first wins

4. **Messages:** Uses SCORE_TETRIS / SCORE_PONG as game types
   - GINV/GACC/GDEC for invite flow (routed to ScoreChallenge)
   - GMOV for status pings during game
   - GEND for final score notification

---

## Tetris Core Game Loop Deep Dive

The Tetris implementation is the most complex minigame in HopeAddon. This section documents the full game loop, state machine, and mechanics.

### File Responsibilities

| File | Purpose | Lines |
|------|---------|-------|
| `TetrisGame.lua` | Main controller: lifecycle, input, UI, AI, networking | ~1950 |
| `TetrisGrid.lua` | 10x20 grid data structure with dirty tracking | ~407 |
| `TetrisBlocks.lua` | Tetromino definitions, colors, SRS wall kicks | ~319 |
| `GameCore.lua` | Shared game loop (60 FPS), state machine, utilities | ~477 |

### Game Loop Flow (60 FPS)

```
GameCore:OnUpdate(elapsed)
  │
  ├─► Throttle to 60 FPS (FRAME_TIME = 1/60)
  │
  └─► For each active game in STATE.PLAYING:
        │
        └─► TetrisGame:OnUpdate(gameId, dt)
              │
              ├─► Check paused/countdown/gameOver → return early
              │
              └─► For each board (1 or 2 depending on mode):
                    │
                    └─► UpdateBoard(gameId, playerNum, dt)
```

### Board Update Cycle (per board, per frame)

```lua
UpdateBoard(gameId, playerNum, dt)
  │
  ├─► 1. Handle Entry Delay (ARE)
  │     if waitingForEntry:
  │       entryDelayTimer += dt
  │       if timer >= ENTRY_DELAY (0.1s): waitingForEntry = false
  │       else: return (don't spawn yet)
  │
  ├─► 2. Spawn Piece if Needed
  │     if not currentPiece:
  │       SpawnPiece() → check game over if blocked
  │       return
  │
  ├─► 3. Input Processing
  │     if AI enabled: UpdateAIBoard()
  │     else: UpdateDASInput() (Delayed Auto Shift)
  │
  ├─► 4. Lock Delay Handling
  │     if isLocking:
  │       lockTimer += dt
  │       if timer >= LOCK_DELAY (0.5s): LockPiece()
  │       return
  │
  └─► 5. Automatic Drop
        dropTimer += dt
        dropInterval = softDropping ? SOFT_DROP_INTERVAL : board.dropInterval
        if dropTimer >= dropInterval:
          dropTimer = 0
          MovePiece(dRow=1, dCol=0) → drop one row
```

### Key Timing Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `INITIAL_DROP_INTERVAL` | 1.0s | Starting gravity speed |
| `MIN_DROP_INTERVAL` | 0.1s | Max gravity speed (level 10+) |
| `SOFT_DROP_INTERVAL` | 0.05s | Speed when holding down |
| `LOCK_DELAY` | 0.5s | Time before piece locks on landing |
| `MAX_LOCK_MOVES` | 15 | Moves/rotations allowed during lock delay |
| `DAS_DELAY` | 0.167s | Initial delay before auto-repeat (~10 frames) |
| `ARR_INTERVAL` | 0.033s | Auto-repeat speed (~2 frames) |
| `ENTRY_DELAY` | 0.1s | Spawn delay after locking (ARE) |

### Piece Lifecycle State Machine

```
SPAWN
  │ SpawnPiece()
  │ - Get next from 7-bag queue
  │ - Set position (row 1 or 0 for I)
  │ - Check game over if spawn blocked
  │ - Process incoming garbage (cancel/apply)
  │ - Reset timers
  ▼
FALLING
  │ UpdateBoard() each frame
  │ - Process input (move/rotate)
  │ - Auto drop every dropInterval
  │
  ├── MovePiece(down) succeeds → continue FALLING
  │
  └── MovePiece(down) fails → enter LOCKING
        │
        ▼
LOCKING
  │ isLocking = true
  │ lockTimer counting up
  │
  ├── Move/rotate resets lockTimer (up to MAX_LOCK_MOVES)
  │
  └── lockTimer >= LOCK_DELAY → LockPiece()
        │
        ▼
LOCKED
  │ LockPiece()
  │ - Detect T-Spin
  │ - PlaceBlocks on grid
  │ - Award soft drop points
  │ - Clear piece, set waitingForEntry = true
  │ - CheckLineClears()
  │
  ▼
ENTRY_DELAY (ARE)
  │ waitingForEntry = true
  │ entryDelayTimer counting up
  │
  └── timer >= ENTRY_DELAY → back to SPAWN
```

### Scoring System

| Action | Points | Garbage Sent |
|--------|--------|--------------|
| Single | 100 × level | 0 |
| Double | 300 × level | 1 |
| Triple | 500 × level | 2 |
| Tetris | 800 × level | 4 |
| T-Spin Single | 800 × level | 3 |
| T-Spin Double | 1200 × level | 6 |
| T-Spin Triple | 1600 × level | 7 |
| Mini T-Spin | 100 × level | 0 |
| Soft Drop | 1 per cell | - |
| Hard Drop | 2 per cell | - |
| Back-to-Back | +50% points | - |
| Combo | (combo-1) × 50 × level | - |

**Level Progression:**
- 10 lines per level
- Drop speed: `INITIAL_DROP_INTERVAL * 0.85^(level-1)`
- Capped at `MIN_DROP_INTERVAL` (0.1s)

### Input System (DAS/ARR)

```lua
-- DAS = Delayed Auto Shift (initial hold delay)
-- ARR = Auto Repeat Rate (repeat speed after DAS)

UpdateDASInput(gameId, playerNum, dt):
  for direction in [left, right]:
    input = board.inputState[direction]
    if input.pressed:
      input.timer += dt

      if not input.repeating:
        -- Still in DAS phase
        if input.timer >= DAS_DELAY (0.167s):
          input.repeating = true
          input.timer = 0
      else:
        -- In ARR phase (fast repeat)
        if input.timer >= ARR_INTERVAL (0.033s):
          MovePiece(0, direction)
          input.timer = 0

-- Key down: immediate first move + start DAS timer
-- Key up: clear pressed flag
```

### Wall Kicks (SRS)

The game uses standard Super Rotation System (SRS) wall kicks:

**JLSTZ Pieces:**
| Rotation | Kick Tests |
|----------|-----------|
| 0→1 | (0,0), (-1,0), (-1,1), (0,-2), (-1,-2) |
| 1→2 | (0,0), (1,0), (1,-1), (0,2), (1,2) |
| 2→3 | (0,0), (1,0), (1,1), (0,-2), (1,-2) |
| 3→0 | (0,0), (-1,0), (-1,-1), (0,2), (-1,2) |

**I Piece:**
| Rotation | Kick Tests |
|----------|-----------|
| 0→1 | (0,0), (-2,0), (1,0), (-2,-1), (1,2) |
| 1→2 | (0,0), (-1,0), (2,0), (-1,2), (2,-1) |
| 2→3 | (0,0), (2,0), (-1,0), (2,1), (-1,-2) |
| 3→0 | (0,0), (1,0), (-2,0), (1,-2), (-2,1) |

Counter-clockwise uses negated offsets of the next state's clockwise kicks.

### T-Spin Detection

```lua
DetectTSpin():
  1. Must be T-piece
  2. Must have rotated (lastActionWasRotation = true)
  3. Check 4 corners of 3×3 bounding box around piece center
  4. Count filled corners (cells or walls)
  5. Identify "front" corners (direction T is pointing)

  if filledCorners >= 3:
    return true (T-Spin)
  if filledCorners == 2 AND (frontCorners == 0 OR no kick):
    return true (Mini T-Spin)
  return false
```

### Garbage System

```lua
-- Garbage is queued, not immediately applied
-- Canceling: outgoing cancels incoming before spawn

ProcessGarbage(gameId, playerNum):
  canceled = min(incomingGarbage, outgoingGarbage)
  incomingGarbage -= canceled
  outgoingGarbage -= canceled

  -- Send remaining outgoing to opponent
  if outgoingGarbage > 0:
    SendGarbage(opponentNum, outgoingGarbage)
    outgoingGarbage = 0

  -- Return remaining incoming to be applied
  return incomingGarbage

-- Garbage rows added from bottom with random gap
AddGarbageRows(count):
  1. Check if blocks in top rows would overflow (game over)
  2. Shift all rows up by count
  3. Add gray garbage rows at bottom
  4. Each row has 1 random empty column (gap)
```

### AI Opponent (60-70% player win rate)

```lua
AI_SETTINGS:
  THINK_TIME_MIN = 0.3      -- Visible "thinking" delay
  THINK_TIME_MAX = 0.8
  MOVE_INTERVAL = 0.05      -- Simulates key presses
  MISTAKE_CHANCE = 0.15     -- 15% suboptimal placement

UpdateAIBoard(gameId, playerNum, dt):
  Phase: THINKING
    - Wait random 0.3-0.8 seconds
    - EvaluateBestPlacement() → targetCol, targetRotation
    - 15% chance: offset targetCol by -2 to +2 (mistake)
    - Transition to MOVING

  Phase: MOVING
    - Every MOVE_INTERVAL (0.05s):
      - If rotation wrong: RotatePiece(clockwise)
      - Elif col wrong: MovePiece(left/right)
      - Else: transition to DROPPING

  Phase: DROPPING
    - HardDrop()
    - ResetAIState() for next piece

EvaluateGrid(grid, linesCleared):
  score = 0
  score += linesCleared * WEIGHT_LINES (1.5)
  score += totalHeight * WEIGHT_HEIGHT (-0.5)
  score += holes * WEIGHT_HOLES (-4.0)
  score += bumpiness * WEIGHT_BUMPINESS (-0.3)
  return score
```

### Game Modes

| Mode | Boards | Garbage | Network |
|------|--------|---------|---------|
| LOCAL | 2 (side-by-side) | Yes | None |
| REMOTE | 1 | Yes | Via GameComms |
| SCORE_CHALLENGE | 1 | No | Status pings only |

### UI Rendering Optimization

```lua
-- Dirty cell tracking prevents redrawing entire grid

UpdateBoardUI():
  1. Mark old piece position as dirty
  2. Mark new piece position as dirty
  3. Get dirty cells from grid
  4. Redraw only dirty cells
  5. Draw current piece (always fresh, not from grid)
  6. Clear dirty flags
  7. Update score/level/lines labels (only if changed)
```

### Board State Structure

```lua
board = {
  -- Grid
  grid = TetrisGrid instance,

  -- Current piece
  currentPiece = "T",        -- nil when no active piece
  pieceRow = 5,
  pieceCol = 5,
  pieceRotation = 1,         -- 1-4

  -- Dirty tracking for rendering
  lastPieceRow = nil,
  lastPieceCol = nil,
  lastPieceRotation = nil,
  lastPieceType = nil,

  -- Piece queue (7-bag randomizer)
  nextPieces = {"I", "O", "T"},
  pieceBag = {"S", "Z", "J", "L"},

  -- Timing
  dropTimer = 0,
  dropInterval = 1.0,        -- Decreases with level
  lockTimer = 0,
  lockMoveCount = 0,
  isLocking = false,
  softDropping = false,
  softDropDistance = 0,
  entryDelayTimer = 0,
  waitingForEntry = false,

  -- DAS/ARR input state
  inputState = {
    left = { pressed, timer, repeating },
    right = { pressed, timer, repeating },
  },

  -- Stats
  level = 1,
  lines = 0,
  score = 0,

  -- Garbage
  incomingGarbage = 0,
  outgoingGarbage = 0,

  -- T-Spin detection
  lastActionWasRotation = false,
  lastRotationKicked = false,

  -- Combo system
  backToBack = false,
  comboCount = 0,

  -- AI (board 2 only when enabled)
  ai = {
    enabled = false,
    phase = "THINKING",
    decisionTimer = 0,
    decisionDelay = 0.5,
    targetCol = nil,
    targetRotation = nil,
    moveTimer = 0,
  },
}
```
