# PAC WOW - Component Reference

Comprehensive reference for the Pac-Man game implementation within HopeAddon.

---

## A. Game Architecture Overview

### Module Registration Pattern

Each component registers via the HopeAddon framework:

```lua
local PacManGame = {}
-- ... module implementation ...
HopeAddon:RegisterModule("PacManGame", PacManGame)
```

Modules are retrieved at runtime with `HopeAddon:GetModule("PacManGame")`.

### Game Lifecycle

```
OnCreate(gameId, game)   -- Initialize state, parse map, create ghost/pacman data
OnStart(gameId)          -- Show UI window, start 3-second countdown
OnUpdate(gameId, dt)     -- Main game loop (called every frame while PLAYING)
OnEnd(gameId, reason)    -- Cleanup, show game over or delegate to ScoreChallenge
```

### Integration Points

| System | Purpose |
|--------|---------|
| **GameCore** | 60fps game loop, dispatches OnUpdate with delta time |
| **GameUI** | Window creation (`CreateGameWindow`), play area, game over screen |
| **GameComms** | Networking for score challenge multiplayer messages |
| **ScoreChallenge** | Manages opponent pairing, score comparison, result display |
| **HopeAddon.Timer** | Countdown timers (`Timer:After`) |
| **HopeAddon.Sounds** | Click and achievement sound effects |

---

## B. Component Inventory

| Component | File | Lines | Purpose |
|-----------|------|-------|---------|
| **PacManGame** | `PacManGame.lua` | ~1420 | Main game module: state machine, game loop, UI, rendering |
| **PacManGhostAI** | `PacManGhostAI.lua` | 1-145 | Ghost targeting personalities & pathfinding |
| **PacManMaps** | `PacManMaps.lua` | 1-129 | Maze definition, cell types, walkability checks |
| **GhostReplay** | `GhostReplay.lua` | ~632 | Multiplayer score challenge ghost replay system |

---

## C. Constants & Configuration Reference

### Movement Speeds

| Constant | Value | Description |
|----------|-------|-------------|
| `PACMAN_MOVE_INTERVAL` | 0.12s | Pac-Man moves every 120ms |
| `GHOST_MOVE_INTERVAL` | 0.15s | Ghost base move interval |
| `FRIGHTENED_MOVE_INTERVAL` | 0.20s | Ghosts slow down when frightened |
| `EATEN_MOVE_INTERVAL` | 0.05s | Eaten ghosts rush back to house |

### Scoring

| Event | Points |
|-------|--------|
| Pellet | 10 |
| Power Pellet | 50 |
| Ghost chain | 200, 400, 800, 1600 (per power-up) |
| Extra life | Awarded at 10,000 points |

### Mode Sequence Timings (Scatter/Chase Cycle)

| Phase | Mode | Duration |
|-------|------|----------|
| 1 | SCATTER | 7s |
| 2 | CHASE | 20s |
| 3 | SCATTER | 7s |
| 4 | CHASE | 20s |
| 5 | SCATTER | 5s |
| 6 | CHASE | 20s |
| 7 | SCATTER | 5s |
| 8 | CHASE | forever |

### Ghost Release Timings

| Ghost | Release Time |
|-------|-------------|
| Blinky | 0s (immediate) |
| Pinky | 2s |
| Inky | 5s |
| Clyde | 8s |

### Difficulty Scaling (per level)

```
ghostSpeed    = baseSpeed * max(0.5, 1 - (level-1) * 0.05)   -- 5% faster/level, cap 50%
frightDuration = max(2, 8 - (level-1) * 0.5)                  -- -0.5s/level, min 2s
```

### Color Palette (Neon Theme)

| Entity | RGB |
|--------|-----|
| Wall | (0.1, 0.1, 0.5) - Dark blue |
| Path | (0.0, 0.0, 0.0) - Black |
| Pac-Man | (1.0, 1.0, 0.0) - Neon yellow |
| Blinky | (1.0, 0.1, 0.2) - Neon red |
| Pinky | (1.0, 0.0, 0.8) - Neon magenta |
| Inky | (0.0, 1.0, 1.0) - Neon cyan |
| Clyde | (1.0, 0.5, 0.0) - Neon orange |
| Frightened | (0.3, 0.3, 1.0) - Blue |
| Frightened Flash | (1.0, 1.0, 1.0) - White |
| Pellet | (1.0, 0.9, 0.5) - Warm yellow |
| Power Pellet | (1.0, 1.0, 1.0) - White |

---

## D. Entity System

### Pac-Man

```lua
pacman = {
    row, col,           -- Grid position (1-indexed)
    direction,          -- "UP" | "DOWN" | "LEFT" | "RIGHT"
    nextDirection,      -- Queued direction (applied when valid)
    moveTimer,          -- Accumulates dt, moves at PACMAN_MOVE_INTERVAL
    animTimer,          -- Sine wave accumulator for mouth animation
    mouthOpen,          -- Boolean flag
}
```

Spawn: row 15, col 11. Initial direction: LEFT.

### Ghosts (x4)

```lua
ghost = {
    name,       -- "BLINKY" | "PINKY" | "INKY" | "CLYDE"
    row, col,   -- Grid position
    direction,  -- Current movement direction
    mode,       -- "SCATTER" | "CHASE" | "FRIGHTENED" | "EATEN" | "HOUSE"
    released,   -- Boolean: has left the ghost house
    moveTimer,  -- Accumulates dt for movement timing
}
```

### Ghost Modes

| Mode | Behavior |
|------|----------|
| **SCATTER** | Each ghost targets its home corner |
| **CHASE** | Each ghost uses its unique targeting personality |
| **FRIGHTENED** | Random movement, vulnerable to eating, slower speed |
| **EATEN** | Eyes-only, rushes back to ghost house spawn at high speed |
| **HOUSE** | Waiting inside ghost house before release |

### Ghost AI Personalities

| Ghost | Strategy | Targeting |
|-------|----------|-----------|
| **Blinky** | Direct chase | Targets Pac-Man's exact position |
| **Pinky** | Ambush | Targets 4 tiles ahead of Pac-Man (with classic UP overflow bug) |
| **Inky** | Flank | Pivot 2 tiles ahead of Pac-Man, then double the vector from Blinky |
| **Clyde** | Shy | Chases when distance > 8; scatters to home corner when closer |

**Direction Priority** (tie-breaking): UP > LEFT > DOWN > RIGHT

**Frightened Mode**: Random valid direction (excluding reverse).

**Eaten Mode**: Pathfinds back to spawn position, then resumes current mode.

---

## E. Map System

### Cell Types

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | WALL | Impassable barrier |
| 1 | PATH | Empty walkable path |
| 2 | PELLET | Path with collectible pellet |
| 3 | POWER | Path with power pellet |
| 4 | GHOST_HOUSE | Ghost house interior (ghost-walkable only) |
| 5 | GHOST_DOOR | Ghost house entrance |
| 6 | TUNNEL | Horizontal wrap-around tunnel |

### Grid Dimensions

21 columns x 23 rows (1-indexed)

### Spawn Positions

| Entity | Row | Col |
|--------|-----|-----|
| Pac-Man | 15 | 11 |
| Blinky | 9 | 11 |
| Pinky | 11 | 10 |
| Inky | 11 | 11 |
| Clyde | 11 | 12 |

### Scatter Targets (Home Corners)

| Ghost | Row | Col | Corner |
|-------|-----|-----|--------|
| Blinky | 1 | 21 | Top-right |
| Pinky | 1 | 1 | Top-left |
| Inky | 23 | 21 | Bottom-right |
| Clyde | 23 | 1 | Bottom-left |

### Tunnel Wrapping

Horizontal only. When `col < 1`, wraps to `GRID_WIDTH`. When `col > GRID_WIDTH`, wraps to `1`.
Tunnel cells (6) appear on row 12 at cols 1-3 and 19-21.

### Walkability Rules

| Cell Type | Pac-Man | Ghost (normal) | Ghost (eaten) |
|-----------|---------|-----------------|---------------|
| WALL (0) | No | No | No |
| PATH (1) | Yes | Yes | Yes |
| PELLET (2) | Yes | Yes | Yes |
| POWER (3) | Yes | Yes | Yes |
| GHOST_HOUSE (4) | No | No | Yes |
| GHOST_DOOR (5) | Yes | Yes | Yes |
| TUNNEL (6) | Yes | Yes | Yes |

---

## F. Game Loop Pipeline (per frame)

```
OnUpdate(gameId, dt)
  |
  +-- state.gameTime += dt
  |
  +-- UpdateModeTimer(dt)         -- Advance scatter/chase cycle timer
  |                                  Switch phase when duration exceeded
  |                                  Reverse all active ghost directions on switch
  |
  +-- UpdatePowerTimer(dt)        -- Count down power-up duration
  |                                  Revert FRIGHTENED ghosts to currentMode when expired
  |
  +-- UpdateGhostRelease()        -- Check gameTime vs release thresholds
  |                                  Set released=true, teleport to exit (9,11), direction=UP
  |
  +-- UpdatePacMan(dt)            -- Accumulate moveTimer, attempt nextDirection
  |                                  Move forward, eat pellets/power, handle tunnel wrap
  |
  +-- UpdatePacManAnimation(dt)   -- Sine wave mouth chomp (12 rad/s, 55 deg max)
  |                                  Rotate mouth wedges per direction
  |
  +-- UpdateGhosts(dt)            -- Per ghost: accumulate moveTimer
  |                                  Get target based on mode + personality
  |                                  Choose direction (minimize distance to target)
  |                                  Move to next cell if walkable
  |
  +-- CheckCollisions()           -- Ghost/Pac-Man overlap detection
  |                                  FRIGHTENED: eat ghost (score chain), set EATEN
  |                                  Normal: lose life or game over
  |
  +-- LevelComplete()             -- If pelletsRemaining == 0, advance level
  |
  +-- UpdateEntityPositions()     -- Sync grid positions to pixel coordinates
  |                                  Update ghost visuals (color/mode state)
  |
  +-- GhostReplay (if active)     -- UpdateOutbound: batch & send pellet events
                                     UpdateReplay: replay opponent events with 3s delay
```

---

## G. UI Component Breakdown

### Window

- Size identifier: `"PACMAN"` (normal) or `"PACMAN_CHALLENGE"` (score challenge)
- Grid area: 336 x 368 px (21 cols x 23 rows x 16px/cell)
- Status bar: 30px header above grid

### Status Bar Contents

- **Score**: Left-aligned text
- **Level**: Center text ("Lv X")
- **Lives**: Right-aligned, 3 yellow circle icons (12x12 px each)

### Grid Rendering

- Cell size: 16px
- Background texture: 15x15 px per cell (1px gap)
- Pellet texture: 4x4 px centered in cell
- Power pellet texture: 10x10 px centered in cell
- Positioned via TOPLEFT anchoring: `(col-1)*16 + 1, -((row-1)*16 + 1)`

### Pac-Man Visual

- Yellow circle (body texture)
- Two triangular mouth wedges (mouthTop, mouthBot) - black, rotated per direction
- Mouth animation: `abs(sin(animTimer * 12)) * 55 degrees`
- Wedges rotate around center with directional offset (0/90/180/270 degrees)

### Ghost Visual

- **Body**: Colored rectangle (cellSize - 2)
- **Skirt**: 3 small bumps (5x5 px) along bottom edge
- **Eyes**: 2 white circles (5x5 px) using `Interface\COMMON\Indicator-Gray`
- **Pupils**: 2 dark circles (2x2 px) offset by direction for eye tracking

### Ghost State Visuals

| Mode | Body Color | Eyes | Animation |
|------|-----------|------|-----------|
| Normal | Ghost's color (red/pink/cyan/orange) | White + dark pupils | None |
| Frightened | Blue (0.3, 0.3, 1.0) | Hidden pupils | Pulsing scale animation |
| Frightened (warning) | Flashing white/blue | Hidden pupils | Faster pulsing |
| Eaten | Hidden body + bumps | Eyes only (white + pupils) | None |

---

## H. Multiplayer / Score Challenge (GhostReplay)

### Overview

The GhostReplay system creates a "ghost racing" effect in Score Challenge mode. Each player's pellet collection events are sent to the opponent, who sees a translucent cyan Pac-Man replaying those events with a fixed delay.

### Settings

| Setting | Value |
|---------|-------|
| Replay delay | 3.0 seconds |
| Batch interval | 0.5 seconds |
| Max batch size | 10 events |
| Ghost alpha | 0.5 |
| Ghost color | Cyan (0.4, 0.8, 1.0) |
| Trail length | 3 segments |
| Disconnect timeout | 5.0 seconds |
| Dimmed pellet alpha | 0.3 |

### Data Flow

```
Player A eats pellet
  -> RecordEvent(row, col, time, type)
  -> Batch accumulates for 0.5s
  -> SendBatch via GameComms ("GHOST_PACMAN", "MOVE")

Player B receives batch
  -> Parse message: "seq|time,row,col,type|..."
  -> Queue events sorted by replayAt = anchorTime + eventTime + REPLAY_DELAY
  -> Replay events in order, moving ghost Pac-Man
```

### Message Format

```
seq|centiseconds,row,col,type|centiseconds,row,col,type|...
```

- `seq`: Incrementing batch sequence number
- `centiseconds`: Event time relative to game start (in 1/100s)
- `row,col`: Grid position of eaten pellet
- `type`: Pellet type identifier

### Visual Elements

- Cyan-tinted translucent Pac-Man at 50% opacity
- 3-position trail with fading opacity
- Eaten pellets dimmed to 30% alpha on the grid
- Ghost fades out after 5s of no events (disconnect detection)

---

## I. pacwow_example Reference

The `pacwow_example/` directory contains 13 original Pac-Man arcade ROM binary files:

| File | Description |
|------|-------------|
| `pacman.6e`, `pacman.6f`, `pacman.6h`, `pacman.6j` | CPU program ROMs |
| `5e`, `5f` | Character/sprite ROMs |
| `82s123.7f` | Color PROM (palette) |
| `82s126.1m`, `82s126.3m`, `82s126.4a` | Color lookup PROMs |
| `u5`, `u6`, `u7` | Sound ROMs |

These are classic 1980 Namco arcade cabinet chip dumps. They serve as behavioral reference data for comparing ghost AI patterns and game mechanics. They are not source code and cannot be directly used as WoW addon code.
