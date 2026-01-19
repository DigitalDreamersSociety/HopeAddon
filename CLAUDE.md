# HopeAddon - Feature Status & Organization Guide

## Quick Reference for AI Assistants

This document tracks feature completion status to help AI assistants understand what's done and what needs work.

**This addon is being built entirely by AI.** Documentation accuracy is critical for continuity between sessions.

---

## AI Assistant Quick Start

**Before making changes, understand:**

1. **Module Pattern** - All modules register via `HopeAddon:RegisterModule("Name", Module)` and implement `OnInitialize()`, `OnEnable()`, `OnDisable()`
2. **Data Storage** - Character data in `HopeAddon.charDb` (alias for `HopeAddonCharDB`), account data in `HopeAddon.db`
3. **Frame Pooling** - UI elements use pools to prevent memory leaks. Always release frames in `OnDisable()`
4. **Cross-Module Calls** - Use `HopeAddon.ModuleName:Function()` pattern (e.g., `HopeAddon.Badges:OnPlayerLevelUp(level)`)

**Common Tasks:**
- Add new journal entry type → `Journal/Journal.lua` + update `Constants.lua`
- Add new badge → `Core/Constants.lua` (BADGES table) + trigger in relevant module
- Add new game → Create in `Social/Games/`, register with `GameCore`, add to `C.GAME_DEFINITIONS`
- Track new player interaction → `Social/FellowTravelers.lua` handles addon communication

---

## Documentation Navigation

This project uses multiple specialized guides:

**CLAUDE.md** (This file) - AI development quick reference
- Feature status, module patterns, architecture essentials
- For: Making code changes, understanding dependencies

**UI_ORGANIZATION_GUIDE.md** - Complete UI/UX specifications
- Design specs, component standards, color system, frame pooling
- For: UI work, styling, layout decisions

**DESIGN_DOCUMENT.md** - Player experience philosophy
- Outland adventure narrative, emotional themes
- For: Understanding design intent

**CHANGELOG.md** - Historical bug fixes (Phases 5-13)
- Previous optimization work and patterns
- For: Learning what's been tried

**README.md** - User documentation
- Installation, features, commands

---

## Architecture Overview

```
HopeAddon/
├── Core/           # Foundation (FramePool, Constants, Timer, Core, Sounds, Effects)
├── UI/             # Reusable components (Components, Glow, Animations)
├── Journal/        # Main journal system (Journal, Pages, Milestones, Zones, ProfileEditor)
├── Raids/          # Raid tracking (RaidData, Attunements, Karazhan, Gruul, Magtheridon)
├── Reputation/     # Faction tracking (ReputationData, Reputation)
├── Social/         # Multiplayer features (Badges, Directory, FellowTravelers, Minigames, MapPins, Relationships, TravelerIcons)
│   └── Games/      # Game system (GameCore, GameUI, GameComms, Tetris, DeathRoll, Pong, Words)
└── Tests/          # Test suite (WordGameTests.lua, README.md)
```

**SavedVariables:**
- `HopeAddonDB` - Account-wide settings
- `HopeAddonCharDB` - Per-character data (journal, stats, attunements, travelers, reputation)

---

## Feature Status Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Journal UI | ✅ COMPLETE | Multi-tab interface, frame pooling, polished |
| Timeline | ✅ COMPLETE | Chronological entries, working |
| Milestones | ✅ COMPLETE | Level-based achievements (5-70), auto-triggers |
| Zone Discovery | ✅ COMPLETE | 17 zones tracked, auto-detects |
| Attunements | ✅ COMPLETE | All 6 chains (Kara, SSC, TK, Hyjal, BT, Cipher) |
| Reputation | ✅ COMPLETE | 5 TBC factions, milestone tracking |
| Fellow Travelers | ✅ COMPLETE | Addon-to-addon detection, profile sharing |
| RP Profiles | ✅ COMPLETE | Backstory, personality, appearance editor |
| Badges | ✅ COMPLETE | 20+ achievements with unlock conditions |
| Statistics | ✅ COMPLETE | Deaths, playtime, combat stats tracked |
| Data Persistence | ✅ COMPLETE | Migration, defaults, proper save/load |
| Minigames | ✅ COMPLETE | Dice Roll, RPS, Death Roll between Fellow Travelers |
| Tetris Battle | ✅ COMPLETE | Two-player Tetris with garbage mechanic, local & remote |
| Death Roll | ✅ COMPLETE | Gambling game with escrow system, 3-player support |
| Pong | ✅ COMPLETE | Classic 2-player Pong with physics, local & remote |
| Words with WoW | ✅ COMPLETE | Scrabble-style word game with WoW vocabulary |
| Games Hall UI | ✅ COMPLETE | Storybook-style game selection in Directory tab |
| Test Suite | ✅ COMPLETE | Comprehensive automated tests for Words with WoW |

---

## Known Incomplete Items

### 1. Milestone Detail Modal (Low Priority)
**File:** `Journal/Journal.lua:831`
**Issue:** Clicking milestone cards plays sound and prints message but doesn't open a detail modal
```lua
-- Current: Just plays click sound and prints
HopeAddon.Sounds:PlayClick()
HopeAddon:Print("Viewing milestone: " .. titleText)
```
**Needed:** Full modal dialog showing milestone details

---

### 2. CheckAttunementIcons Placeholder (Medium Priority)
**File:** `Social/TravelerIcons.lua:558-563`
**Issue:** Function is stubbed - waiting on addon communication protocol
```lua
function TravelerIcons:CheckAttunementIcons(travelerName)
    -- This is a placeholder for future addon-to-addon communication
    HopeAddon:Debug("CheckAttunementIcons for", travelerName, "- requires addon communication")
end
```
**Needed:** Logic to check if both players completed an attunement together

---

### 3. Settings Panel (Low Priority)
**Issue:** Settings scattered across slash commands, no dedicated UI panel
**Current:** `/hope debug`, `/hope sound`, `/hope reset`
**Needed:** Optional - dedicated settings tab in journal

---

## File Quick Reference

### Core Files (Entry Points)
| File | Purpose | Size |
|------|---------|------|
| `Core/Core.lua` | Main init, utilities, slash commands | 22KB |
| `Core/Constants.lua` | All static data (milestones, zones, raids, badges) | 97KB |
| `Core/Effects.lua` | Visual effect utilities | ~20KB |
| `Core/FramePool.lua` | Generic object pooling | 5KB |
| `Core/Sounds.lua` | Sound effect playback | ~8KB |
| `Core/Timer.lua` | TBC-compatible timer system | ~8KB |

### Journal System
| File | Purpose | Size |
|------|---------|------|
| `Journal/Journal.lua` | Main UI, tabs, event tracking | 86KB |
| `Journal/Pages.lua` | Page templates and rendering | 30KB |
| `Journal/Milestones.lua` | Level milestone tracking | 8KB |
| `Journal/Zones.lua` | Zone discovery tracking | 6KB |
| `Journal/ProfileEditor.lua` | Character profile UI | 12KB |

### Raid System
| File | Purpose | Size |
|------|---------|------|
| `Raids/Attunements.lua` | Quest chain tracking, progress calc | 15KB |
| `Raids/RaidData.lua` | Raid definitions (T4/T5/T6) | 10KB |
| `Raids/Karazhan.lua` | Karazhan specifics | 4KB |
| `Raids/Gruul.lua` | Gruul's Lair specifics | ~3KB |
| `Raids/Magtheridon.lua` | Magtheridon's Lair specifics | ~3KB |

### Reputation System
| File | Purpose | Size |
|------|---------|------|
| `Reputation/ReputationData.lua` | Faction definitions and standings | ~5KB |
| `Reputation/Reputation.lua` | Reputation tracking logic | ~5KB |

### Social System
| File | Purpose | Size |
|------|---------|------|
| `Social/Badges.lua` | Achievement definitions | 17KB |
| `Social/Directory.lua` | Searchable player directory | ~11KB |
| `Social/FellowTravelers.lua` | Addon-to-addon communication | 33KB |
| `Social/MapPins.lua` | Minimap pins for Fellow Travelers | ~8KB |
| `Social/Minigames.lua` | Dice, RPS, Death Roll logic, protocol, stats | 42KB |
| `Social/MinigamesUI.lua` | Game selection popup, game boards, results | 41KB |
| `Social/Relationships.lua` | Player notes system | ~8KB |
| `Social/TravelerIcons.lua` | Icon rendering | 12KB |

<details>
<summary>FellowTravelers Module Details (Communication Hub) - click to expand</summary>

- Addon prefix: `HOPEADDON`, protocol version 1
- Message types: PING, PONG, PREQ (profile request), PROF (profile data), LOC (location)
- Key public API:
  - `IsFellow(name)` - Check if player uses the addon
  - `GetFellow(name)` / `GetFellowProfile(name)` - Get fellow data
  - `GetTraveler(name)` / `GetAllTravelers()` - Get any known player
  - `GetPartyMembers()` - Get current party/raid members
  - `GetPartySnapshot()` - Snapshot with timestamps for shared achievements
  - `GetMyProfile()` / `UpdateMyProfile(updates)` - Manage own RP profile
  - `RegisterMessageCallback(id, matchFunc, handler)` - For other modules to receive messages
- Stores: `charDb.travelers.known`, `charDb.travelers.fellows`, `charDb.travelers.myProfile`
</details>

<details>
<summary>Directory Module Details - click to expand</summary>

- Combines `travelers.known` + `travelers.fellows` into unified list
- Sort options: name (A-Z/Z-A), class, level (high/low), last seen
- Search filters by name, class, or zone
- Integrates with Relationships for note display (`hasNote` field)
- Read-only module - does not write to SavedVariables
- Key functions:
  - `GetAllEntries()` - Get all directory entries
  - `GetFilteredEntries(filter, sort)` - Get filtered/sorted entries
  - `GetEntry(name)` - Get specific player entry
  - `GetEntryCount()` - Optimized count without building entries
  - `GetFellowCount()` - Count addon users only
  - `GetStats()` - Statistics: total, fellows, byClass, recentCount
  - `FormatEntryForDisplay(entry)` - Format for UI display
  - `IsPlayerNearby(name)` - Check if player in party/raid
</details>

<details>
<summary>Relationships Module Details - click to expand</summary>

- Simple key-value note storage: `charDb.relationships[playerName] = { note, addedDate }`
- 256 character note limit (NOTE_MAX_LENGTH)
- Key functions:
  - `GetNote(name)` / `SetNote(name, note)` / `RemoveNote(name)` / `HasNote(name)` - CRUD
  - `GetRelationship(name)` - Get full data { note, addedDate }
  - `GetAllNotes()` - Get all notes dictionary
  - `GetNoteCount()` - Count of players with notes
  - `GetPlayersWithNotes()` - Sorted array of player names
  - `SearchNotes(text)` - Search notes by name or content
  - `AddNoteFromTarget(note)` - Add note for current target
  - `AddNoteFromChat(name, note)` - Add note from chat link
  - `ExportNotes()` / `ImportNotes(data)` - Backup/restore
- Integrates with Directory for UI display
</details>

### Game System
| File | Purpose | Size |
|------|---------|------|
| `Social/Games/GameCore.lua` | Game loop, state machine, utilities | 14KB |
| `Social/Games/GameUI.lua` | Shared UI components (windows, buttons) | 18KB |
| `Social/Games/GameComms.lua` | Addon messaging for multiplayer | 16KB |
| `Social/Games/Tetris/TetrisGame.lua` | Tetris battle logic and UI | 28KB |
| `Social/Games/Tetris/TetrisBlocks.lua` | Tetromino definitions, rotation, SRS | 9KB |
| `Social/Games/Tetris/TetrisGrid.lua` | 10x20 grid data structure | 10KB |
| `Social/Games/DeathRoll/DeathRollGame.lua` | Death roll turn-based mechanics | 15KB |
| `Social/Games/DeathRoll/DeathRollUI.lua` | Death roll gameplay UI | 11KB |
| `Social/Games/DeathRoll/DeathRollEscrow.lua` | 3-player escrow for gambling | 16KB |
| `Social/Games/Pong/PongGame.lua` | Pong physics and gameplay | 19KB |
| `Social/Games/WordsWithWoW/WordBoard.lua` | Word game board mechanics | 14KB |
| `Social/Games/WordsWithWoW/WordDictionary.lua` | WoW-themed word list | 13KB |
| `Social/Games/WordsWithWoW/WordGame.lua` | Words with WoW main controller | 23KB |

### UI Framework
| File | Purpose | Size |
|------|---------|------|
| `UI/Components.lua` | All reusable UI components | 59KB |
| `UI/Glow.lua` | Glow effects | 11KB |
| `UI/Animations.lua` | Animation utilities | 12KB |

### Test Suite
| File | Purpose | Size |
|------|---------|------|
| `Tests/WordGameTests.lua` | Comprehensive automated tests for Words with WoW | 17KB |
| `Tests/README.md` | Test documentation and procedures | 10KB |

**Run tests:** `/run LoadAddOn("HopeAddon_Tests")` then `/wordtest all` (see Tests/README.md for details)

---

## Module Dependencies & Data Flow

Understanding how modules interact is critical for making changes without breaking the addon.

### Load Order Summary

**Phase 1:** Core Foundation (FramePool, Constants, Timer, Core, Sounds, Effects)
**Phase 2:** UI Components (Components, Glow, Animations)
**Phase 3:** Journal System (Journal, Pages, Milestones, Zones, ProfileEditor)
**Phase 4:** Raid & Reputation (RaidData, Attunements, Reputation)
**Phase 5:** Social Features (Badges, FellowTravelers, Directory, Relationships, Minigames, MapPins)
**Phase 6:** Game System (GameCore, GameUI, GameComms, game implementations)

### Key Module Relationships

| Module | Depends On | Called By |
|--------|------------|-----------|
| **Badges** | Constants | Milestones, Zones, RaidData, Attunements, Reputation |
| **FellowTravelers** | Timer, Core | Directory, Minigames, GameComms, TravelerIcons, MapPins |
| **Directory** | FellowTravelers, Relationships | Journal (UI) |
| **Relationships** | Core (charDb) | Directory |
| **Journal** | All UI modules, Effects, Sounds | Core (main entry point) |
| **GameComms** | FellowTravelers, GameCore | Game implementations |

### Event Flow Examples

**Player reaches level 30:**
```
PLAYER_LEVEL_UP → Journal:OnLevelUp(30)
                  ├─ Adds entry to charDb.journal.entries
                  └─ Calls Badges:OnPlayerLevelUp(30)
```

**Player kills raid boss:**
```
COMBAT_LOG_EVENT_UNFILTERED → RaidData:OnCombatLogEvent()
                               ├─ Matches NPC ID in C.BOSS_NPC_IDS
                               ├─ Adds journal entry
                               └─ Calls Badges:OnBossKilled(bossName)
```

### WoW Event Handlers by Module

| Module | Events | Purpose |
|--------|--------|---------|
| **Core.lua** | ADDON_LOADED, PLAYER_LOGIN, PLAYER_LOGOUT | Init, enable/disable modules |
| **Journal.lua** | PLAYER_LEVEL_UP, ZONE_CHANGED_NEW_AREA, QUEST_TURNED_IN, PLAYER_DEAD, TIME_PLAYED_MSG, COMBAT_LOG_EVENT_UNFILTERED, SKILL_LINES_CHANGED | Track all player activities |
| **Zones.lua** | ZONE_CHANGED_NEW_AREA, PLAYER_ENTERING_WORLD | Zone discovery |
| **RaidData.lua** | ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED | Boss kill detection |
| **Reputation.lua** | UPDATE_FACTION, PLAYER_LOGIN | Reputation changes |
| **FellowTravelers.lua** | GROUP_ROSTER_UPDATE, GUILD_ROSTER_UPDATE, CHAT_MSG_ADDON, ZONE_CHANGED_NEW_AREA, PLAYER_TARGET_CHANGED | Player detection & communication |
| **Minigames.lua** | CHAT_MSG_SYSTEM | Detect /roll results |
| **DeathRollGame.lua** | CHAT_MSG_SYSTEM | Detect /roll results |
| **DeathRollEscrow.lua** | TRADE_SHOW, TRADE_MONEY_CHANGED, TRADE_ACCEPT_UPDATE, TRADE_CLOSED | Escrow trading |
| **MapPins.lua** | ZONE_CHANGED_NEW_AREA, ZONE_CHANGED | Update minimap pins |

---

## Data Structures

### Character Data (`HopeAddonCharDB`)

**Essential Fields:**
- `journal.entries` - All journal entries chronologically
- `journal.levelMilestones[level]` - Level milestone entries
- `journal.zoneDiscoveries[zoneName]` - Zone discovery entries
- `journal.bossKills[bossName]` - Boss kill counts
- `attunements[raidKey]` - Quest chain progress per raid
- `stats.deaths` - Death tracking by zone/boss
- `stats.playtime` - Total playtime in seconds
- `travelers.known[playerName]` - All encountered players
- `travelers.fellows[playerName]` - Addon users only
- `travelers.myProfile` - Player's RP profile
- `relationships[playerName]` - Player notes

<details>
<summary>Full Character Data Structure (click to expand)</summary>

```lua
{
    journal = {
        entries = {},              -- All journal entries chronologically
        levelMilestones = {},      -- [level] = entry
        zoneDiscoveries = {},      -- [zoneName] = entry
        bossKills = {},            -- [bossName] = count
        attunementMilestones = {}, -- [raidKey] = entry
        bossMilestones = {},       -- [tierKey] = entry
        tierMilestones = {},       -- [tierKey] = entry
        lastTab = "timeline",
    },
    attunements = {
        karazhan = { started = bool, completed = bool, chapters = { [questId] = true } },
        ssc = { ... }, tk = { ... }, hyjal = { ... }, bt = { ... }, cipher = { ... }
    },
    stats = {
        deaths = { total = 0, byZone = {}, byBoss = {} },
        playtime = 0,
        questsCompleted = 0,
        creaturesSlain = 0,
        largestHit = 0,
        dungeonRuns = { [dungeonKey] = { normal = 0, heroic = 0 } }
    },
    travelers = {
        known = {
            [playerName] = {
                class = "WARRIOR",
                level = 70,
                lastSeen = "2024-01-15",
                lastSeenZone = "Shattrath",
                lastSeenTime = 1705334400,
                firstSeen = "2024-01-10",
                selectedColor = "FF8000",
                selectedTitle = "Hero",
                profile = { backstory, personality, ... },
                icons = { [iconId] = { earnedDate, earnedTimestamp, context } },
                stats = { minigames = { dice = {...}, rps = {...} } },
            },
        },
        fellows = {},              -- Same structure
        myProfile = {
            backstory = "",
            personality = {},
            appearance = "",
            rpHooks = "",
            pronouns = "",
            status = "OOC",
            selectedTitle = nil,
            selectedColor = nil,
        },
        badges = {},
        fellowSettings = { enabled = true, colorChat = true, shareProfile = true, showTooltips = true },
    },
    reputation = {
        milestones = {},           -- [faction][standing] = entry
        currentStandings = {},     -- [faction] = standing
        aldorScryerChoice = nil    -- "aldor" | "scryer" | nil
    },
    relationships = {
        [playerName] = {
            note = "Friendly healer, met in Karazhan",
            addedDate = "2024-01-15",
            updatedDate = "2024-01-20",
        },
    },
}
```
</details>

### Account Data (`HopeAddonDB`)
```lua
{
    version = "1.0.0",
    debug = false,
    settings = {
        soundEnabled = true,
        glowEnabled = true,
        animationsEnabled = true,
        notificationsEnabled = true,
    }
}
```

---

## Frame Pooling Patterns

The addon uses specialized frame pools for efficient UI management. All pools follow the standard lifecycle:

**Quick Reference:**

| Pool | Frame Type | Purpose | Location |
|------|------------|---------|----------|
| `notificationPool` | Frame + BackdropTemplate | Pop-up notifications | Journal.lua:130-175 |
| `containerPool` | Frame | Headers, spacers, sections | Journal.lua:179-205 |
| `cardPool` | Button + BackdropTemplate | Entry cards | Journal.lua:207-285 |
| `collapsiblePool` | Frame | Collapsible sections | Journal.lua:288-345 |
| `bossInfoPool` | Frame | Raid metadata frames | Journal.lua:347-375 |
| `gameCardPool` | Button + BackdropTemplate | Games Hall cards | Journal.lua:377-430 |
| `pinPool` | Table-based | Minimap pins | MapPins.lua:20 |

**Lifecycle:** OnEnable → Create pools | SelectTab → ReleaseAll + ClearEntries | OnDisable → Destroy pools

**For detailed pooling patterns, see UI_ORGANIZATION_GUIDE.md §2.2 Frame Pooling**

---

## Constants & Enumerates Reference

Key constant categories in `Core/Constants.lua`:

| Category | Constant | Key Structure |
|----------|----------|---------------|
| Milestones | `C.LEVEL_MILESTONES` | `[level] = { title, icon, story }` |
| Zones | `C.ZONE_DISCOVERIES` | `[zoneName] = { title, flavor, icon, levelRange }` |
| Attunements | `C.[RAID]_ATTUNEMENT` | `{ chapters = { ... }, questIds = { ... } }` |
| Bosses | `C.[RAID]_BOSSES` | `{ id, name, location, lore, mechanics, loot }` |
| Tokens | `C.T[4/5/6]_TOKENS` | `{ slot, dropsFrom, raid, classes }` |
| Icons | `C.TRAVELER_ICONS` | `{ id, name, icon, quality, category, trigger }` |
| Deaths | `C.DEATH_TITLES` | `{ min, max, title, color }` |
| Raid Tiers | `C.RAID_TIERS` | `[raidKey] = "T4"/"T5"/"T6"` |
| Raid Lists | `C.ALL_RAID_KEYS` | `{ "karazhan", "gruul", ... }` |
| Raid Lists | `C.ATTUNEMENT_RAID_KEYS` | `{ "karazhan", "ssc", ... }` (no Gruul/Mag) |
| Raid Lists | `C.RAIDS_BY_TIER` | `{ T4 = {...}, T5 = {...}, T6 = {...} }` |
| Games | `C.GAME_DEFINITIONS` | `{ id, name, description, icon, hasLocal, hasRemote, system, color }` |

**Lookup Tables:**
```lua
C.ATTUNEMENT_QUEST_LOOKUP[questId]  -- → { raid, chapter }
C.ENCOUNTER_TO_BOSS[encounterId]    -- → { raid, boss }
C.BOSS_NPC_IDS[npcId]               -- → { raid, boss }
C:GetRaidTier(raidKey)              -- → "T4"/"T5"/"T6" or nil
C:GetGameDefinition(gameId)         -- → { id, name, description, ... }
```

---

## Shared UI Components

Reusable components from `UI/Components.lua`:

| Component | Function | Usage |
|-----------|----------|-------|
| Parchment Frame | `CreateParchmentFrame()` | Main container |
| Tab Button | `CreateTabButton()` | Tab headers |
| Scroll Frame | `CreateScrollFrame()` | Content scrolling |
| Entry Card | `CreateEntryCard()` | All tab entries |
| Progress Bar | `CreateProgressBar()` | Attunements, Rep |
| Collapsible Section | `CreateCollapsibleSection()` | Acts, Raids |
| Reputation Bar | `CreateReputationBar()` | Reputation tab |
| Section Header | `CreateSectionHeader()` | Tab section headers |
| Category Header | `CreateCategoryHeader()` | Category labels |
| Spacer | `CreateSpacer()` | Vertical spacing |
| Divider | `CreateDivider()` | Visual separator |
| Game Card | `CreateGameCard()` | Games Hall minigame cards |

**ScrollContainer Interface:**
```lua
container:AddEntry(frame)           -- Add frame to scroll content
container:ClearEntries(pool)        -- Release all entries to pool
container:RecalculatePositions()    -- Update layout after changes
```

---

## Naming Conventions

Consistent function naming patterns:

| Pattern | Example | Purpose |
|---------|---------|---------|
| `Create*` | `CreateSectionHeader()` | Constructor |
| `Populate*` | `PopulateTimeline()` | Tab rendering |
| `Acquire*` | `AcquireCard()` | Pool retrieval |
| `Get*` | `GetTimestamp()` | Data retrieval |
| `Format*` | `FormatPlaytime()` | String formatting |
| `Count*` | `CountDungeonRuns()` | Statistics |
| `On*` | `OnEnable()` | Event handlers |
| `Update*` | `UpdateFooter()` | UI refresh |

**Color Naming:** `UPPERCASE_WITH_UNDERSCORES` (e.g., `FEL_GREEN`, `GOLD_BRIGHT`)

**Asset Paths:** `HopeAddon.assets.[type].[NAME]`

**Variable Naming:**
- Local: `camelCase`
- Module tables: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`

---

## Tab Implementation Pattern

Standard pattern for populating journal tabs:

```lua
function Journal:PopulateXXX()
    local scrollContainer = self.mainFrame.scrollContainer
    scrollContainer:ClearEntries(self.containerPool)

    -- Add header
    local header = self:CreateSectionHeader("TITLE", "COLOR")
    scrollContainer:AddEntry(header)

    -- Add entries from pool
    for _, item in ipairs(data) do
        local card = self:AcquireCard(scrollContainer.content, itemData)
        scrollContainer:AddEntry(card)
    end

    self:UpdateFooter()
end
```

**Tab Registration:**
```lua
-- In OnEnable:
self:RegisterTab("TabName", "icon", function() self:PopulateTabName() end)
```

**Tab Selection Flow:**
1. `SelectTab(tabIndex)` called
2. Release all pooled frames
3. Clear scroll container
4. Call populate function
5. Update footer statistics

---

## Color System

HopeAddon uses TBC/Outland themed colors (fel green, hellfire red, arcane purple, etc.).

**For complete color specifications with hex values, see UI_ORGANIZATION_GUIDE.md §1.1 Color Palette and §2.6 Color System**

**Usage:**
```lua
local color = HopeAddon.colors.GOLD_BRIGHT
fontString:SetTextColor(color.r, color.g, color.b)
texture:SetVertexColor(color.r, color.g, color.b, 0.8)
```

---

## Module Pattern

All modules follow this pattern:
```lua
local ModuleName = {}
HopeAddon:RegisterModule("ModuleName", ModuleName)

function ModuleName:OnInitialize() end  -- Called during load
function ModuleName:OnEnable() end      -- Called on PLAYER_LOGIN
function ModuleName:OnDisable() end     -- Called on PLAYER_LOGOUT
```

---

## Game System Architecture

The game system provides a framework for implementing multiplayer games with local and remote play modes.

### Core Components

**GameCore** - Game loop and state machine
- 30 FPS update loop with delta time
- State management (IDLE, WAITING, PLAYING, PAUSED, ENDED)
- Support for multiple game types (TETRIS, PONG, DEATH_ROLL, WORDS)
- Support for LOCAL, NEARBY, and REMOTE modes
- Input state tracking and utilities (collision, lerp, clamp)

**GameUI** - Shared UI framework
- Draggable game windows with title bars
- Styled buttons, score displays, timers
- Invite dialog system for multiplayer challenges
- Game over overlays with stats
- Window size definitions per game type

**GameComms** - Network communication
- Addon messaging protocol for multiplayer
- Invite/accept/decline flow with 60s timeout
- Game state synchronization
- Move/action messaging during gameplay
- Integration with FellowTravelers communication

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

**Quick Summary:** Tetris Battle (garbage mechanic), Death Roll (gambling + escrow), Pong (classic physics), Words with WoW (Scrabble-style)

<details>
<summary>Detailed Game Specifications (click to expand)</summary>

#### Tetris Battle
- **TetrisGrid** - 10x20 grid with piece placement validation, row clearing, garbage system
- **TetrisBlocks** - All 7 standard pieces (I, O, T, S, Z, J, L) with SRS rotation and 7-bag randomizer
- **TetrisGame** - Battle system with side-by-side boards, garbage mechanic, level progression, full scoring (100/300/500/800)
- **Controls:** P1: A/D move, W rotate, S soft drop, Space hard drop | P2: Arrows, Up rotate, Down soft drop, Enter hard drop

#### Death Roll
- **DeathRollGame** - Turn-based gambling (100 → N → 1, first to roll 1 loses), uses real `/roll` chat command
- **DeathRollEscrow** - 3-player escrow system with automatic payout, dispute resolution, trust verification

#### Pong
- **PongGame** - Classic arcade with ball physics, paddle collision, score to 11, increasing speed
- **Controls:** P1: W/S keys | P2: Up/Down arrows

#### Words with WoW
- **WordGame** - Scrabble-style with WoW vocabulary, slash command input (`/word DRAGON H 8 8`), text-based 15x15 board, cross-word validation, pass system (2 consecutive passes ends game)
- **WordBoard** - 15x15 grid with bonus squares (double/triple letter/word), placement validation (connectivity, bounds, center), cross-word detection and scoring
- **WordDictionary** - ~500 WoW-themed words, hash table for O(1) validation, standard Scrabble letter values, tile bag generation

</details>

---

## Testing Commands

```
/hope                          - Open journal
/hope debug                    - Toggle debug mode
/hope stats                    - Show stats in chat
/hope sound                    - Toggle sounds
/hope reset                    - Show reset options
/hope tetris [player]          - Start Tetris Battle (local or vs player)
/hope pong [player]            - Start Pong (local or vs player)
/hope deathroll [player]       - Start Death Roll (local or vs player)
/hope words <player>           - Start Words with WoW vs player
/word <word> <H/V> <row> <col> - Place word in active Words game (e.g., /word DRAGON H 8 8)
/pass                          - Pass your turn in active Words game
/hope challenge <player> [game] - Challenge via game selection popup
/hope accept                   - Accept pending challenge
/hope decline                  - Decline pending challenge
/hope cancel                   - Cancel current game
```

---

## Recent Changes

See [CHANGELOG.md](CHANGELOG.md) for historical bug fixes (Phases 5-13).

### Phase 16: Implementation Guide Execution (2026-01-19)

**Critical Fixes:**
- ✅ **Pong Ball Desync (C2)** (PongGame.lua:418-422) - Added host-only ball physics check; client receives ball state from network instead of running local physics
- ✅ **PlayHover Sound (A3)** (Sounds.lua:148-150) - Added missing `PlayHover()` function to fix error in GameUI button hover handlers

**High Priority Fixes:**
- ✅ **RecalculatePositions Consistency (M1)** (Components.lua:695-711) - Added component-type-aware fallback logic matching AddEntry; removed extra MARGIN_NORMAL from final height calculation to prevent layout shifts on collapsible toggle
- ✅ **Words Score Validation (H4)** (WordGame.lua:490-514) - Added score validation in HandleRemoteMove comparing remote claimed score vs locally calculated; mismatches logged to debug

**Documentation Updates:**
- ✅ Updated UI_ORGANIZATION_GUIDE.md: H3, M2, M3, M5 marked as "Won't Fix - By Design" with justifications
- ✅ Phase 2 (High Priority) and Phase 3 (Medium Priority) marked complete

**Previously Implemented (Verified This Session):**
- ✅ **Words Memory Leak (C1)** (WordGame.lua:201-258) - CleanupGame function with comprehensive FontString and frame cleanup
- ✅ **Words Board Performance (C3)** (WordGame.lua:735-792) - Row caching with dirtyRows tracking for O(1) rendering
- ✅ **Scroll Height Fallback (H1)** (Components.lua:654-666) - Component-type-aware fallbacks using `_componentType` metadata
- ✅ **Words Window Size (H2)** (GameUI.lua:34, WordGame.lua:532) - Dedicated WORDS constant (650x600)

### Phase 17: PAYLOADS 1-4 Implementation (2026-01-19)

**PAYLOAD 1: Layout Consistency Fixes (4 hours)**
- ✅ **Words ui/state Refactoring** (WordGame.lua) - Completed refactoring of 12 functions to use `game.data.ui.*` and `game.data.state.*` structure
  - OnStart, OnEnd, CleanupGame, GetCurrentPlayer
  - PlaceWord, PassTurn, NextTurn, HandleRemoteMove, HandleRemotePass
  - ShowUI, UpdateUI, RenderBoard, InvalidateRows
  - CRITICAL: Preserved `state.board` as WordBoard instance with methods intact
- ✅ **All Games Refactored** - Pong (17 functions), DeathRoll (11 functions), Tetris (30+ functions), Words (12 functions)
- ✅ **Memory Leak Prevention** - All games now have O(1) CleanupGame with proper frame lifecycle

**PAYLOAD 2: Code Refactoring (12 hours)**
- ✅ **CreateBackdropFrame Centralized** (Core.lua:378-411) - Eliminated ~150 lines of duplication across 8 files
  - Handles TBC Classic vs original TBC with BackdropTemplateMixin check
  - Replaced local implementations in: Components.lua, Journal.lua, ProfileEditor.lua, Pages.lua, MinigamesUI.lua, GameUI.lua, DeathRollUI.lua, Reputation.lua
- ✅ **LayoutBuilder Component** (Components.lua:697-764) - Automated form layout with yOffset tracking
  - AddRow(frame, spacing) - Auto-positions frames vertically
  - AddSpacer(height) - Adds vertical spacing
  - Reset() - Resets for multi-column layouts
- ✅ **Labeled Control Factories** (Components.lua:975-1084)
  - CreateLabeledEditBox(parent, labelText, placeholder, maxLetters)
  - CreateLabeledDropdown(parent, labelText, options)
  - CreateCheckboxWithLabel(parent, labelText, defaultChecked)
- ✅ **ColorUtils Namespace** (Core.lua:447-556)
  - Lighten(color, percent) / Darken(color, percent)
  - ApplyVertexColor(texture, colorName) / ApplyTextColor(fontString, colorName)
  - Blend(color1, color2, ratio)
  - HexToRGB(hex)
- ✅ **CreateStyledButton Factory** (Components.lua:1098-1176) - Consistent button styling with hover effects

**PAYLOAD 3: Animation Integration (10 hours)**
- ✅ **ColorTransition Function** (Animations.lua:202-244) - Smooth 150ms border color transitions using custom tween system
  - Uses easeOutQuad for smooth transitions
  - Stores current color for next transition
  - Respects animationsEnabled setting
- ✅ **Hover Transitions Applied** - All styled buttons and labeled dropdowns use ColorTransition
  - OnEnter: Transition to GOLD_BRIGHT (150ms)
  - OnLeave: Transition back to default border color (150ms)
- ✅ **Celebration Effects** (Effects.lua:645-741)
  - Celebrate(frame, duration, options) - Composite effect: glow + sparkles + sound
  - IconGlow(frame, duration) - Shorter icon celebration
  - ProgressSparkles(progressBar, duration) - Progress bar completion sparkles
- ✅ **Integration Points**
  - Progress bars at 100%: Sparkles + gold border (Components.lua:286-309)
  - Game victories: Full celebration effect (GameUI.lua:517-520)
  - Collapsible sections: 200ms fade animations (Components.lua:1302-1340)
- ✅ **TBC Compatibility** - All animations use HopeAddon.Timer and custom tween system (no retail APIs)

**PAYLOAD 4: TBC Theme Audit (5 hours)**
- ✅ **Game Card Colors Updated** (Components.lua:2465-2469) - Replaced BROWN with ARCANE_PURPLE (0.61, 0.19, 1.0)
- ✅ **MinigamesUI Colors Updated** (MinigamesUI.lua:627, 1196) - Replaced BROWN with ARCANE_PURPLE for RPS buttons and game icon buttons
- ✅ **Tab Color Verification** - Audited all 8 journal tabs, confirmed TBC palette usage:
  - Journey: GOLD_BRIGHT (primary), FEL_GREEN (Outland content)
  - Milestones: GOLD_BRIGHT, FEL_GREEN (Act III)
  - Zones: FEL_GREEN (Outland Exploration)
  - Reputation: ARCANE_PURPLE (main header), GOLD_BRIGHT (categories)
  - Attunements: ARCANE_PURPLE (magic theme), tier colors
  - Raids: Tier colors (T4=GOLD_BRIGHT, T5=SKY_BLUE, T6=HELLFIRE_RED)
  - Directory: ARCANE_PURPLE (Games Hall), FEL_GREEN (Fellow Travelers)
  - Stats: GOLD_BRIGHT, FEL_GREEN, ARCANE_PURPLE
- ✅ **BROWN Eliminated** - All UI elements now use TBC palette (only color definition remains in Constants.lua)
- ✅ **Documentation Verified** - All color values already documented with actual RGB values (no 0.XX placeholders)
- ✅ **Icon Organization Examples** - UI_ORGANIZATION_GUIDE.md already has comprehensive examples (no additions needed)

**Files Modified (Total: 12 files)**
- Core.lua (CreateBackdropFrame, ColorUtils)
- Components.lua (LayoutBuilder, labeled controls, CreateStyledButton, progress bar sparkles, collapsible animations, game card colors)
- Animations.lua (ColorTransition)
- Effects.lua (Celebrate, IconGlow, ProgressSparkles)
- GameUI.lua (victory celebrations)
- MinigamesUI.lua (ARCANE_PURPLE for RPS/game buttons)
- WordGame.lua (ui/state refactoring, 12 functions)
- 5 other files (CreateBackdropFrame centralized): Journal.lua, ProfileEditor.lua, Pages.lua, DeathRollUI.lua, Reputation.lua

**Results:**
- ~150 lines of duplication eliminated
- Consistent ui/state structure across all 4 games
- Smooth animations on all buttons (150ms color transitions)
- Celebration effects on victories and achievements
- 100% TBC aesthetic (arcane purple, fel green, gold - no brown)
- All TBC 2.4.3 compatible (no retail APIs used)

### Previous Session Fixes

- ✅ **Card Pool Frame Type** (Journal.lua:149) - Changed `"Frame"` to `"Button"` to support OnClick scripts
- ✅ **Reputation Card Border Hover** (Journal.lua:1119) - Store standing color in `defaultBorderColor` so border returns to correct color after hover instead of grey
- ✅ **Section Header Components** (Components.lua:1809, Journal.lua:619) - Moved CreateSectionHeader and CreateCategoryHeader to Components.lua for reusability; Journal now delegates to Components
- ✅ **Spacer Component** (Components.lua:1867) - Added CreateSpacer helper to Components.lua for consistent vertical spacing
- ✅ **RaidData OnInitialize** (RaidData.lua:486) - Added missing OnInitialize stub for module pattern consistency

### Phase 14: Production Readiness (Memory Leaks & Error Resilience)

- ✅ **Module Lifecycle Protection** (Core.lua:499-508, 536-543) - Wrapped OnEnable/OnDisable calls in pcall to prevent one failing module from cascading
- ✅ **Combat Log Handler Protection** (Journal.lua:649-653, RaidData.lua:346-358) - Wrapped COMBAT_LOG_EVENT_UNFILTERED handlers in pcall for stability during raids
- ✅ **eventFrame Cleanup** (7 modules) - Added `self.eventFrame = nil` after UnregisterAllEvents to prevent memory leaks:
  - Zones.lua:39-44
  - FellowTravelers.lua:140-152
  - MapPins.lua:391-404
  - Reputation.lua:29-39
  - DeathRollGame.lua:94-106
  - Journal.lua:100-131
  - RaidData.lua:508-514
- ✅ **SafeCall Utility** (Core.lua:364-376) - Added `HopeAddon:SafeCall(func, ...)` for protected function execution
- ✅ **Slash Command Validation** (Core.lua:665-681) - Added ValidatePlayerName() function with length and format checks for `/hope words` and `/hope challenge`
- ✅ **ENCOUNTER_END Documentation** (RaidData.lua:339-341) - Documented that ENCOUNTER_END doesn't exist in TBC Classic 2.4.3; boss detection relies on COMBAT_LOG UNIT_DIED
- ✅ **Pool Cleanup Enhancement** (Journal.lua:107-131) - Added nil assignments after Destroy() calls for all 6 frame pools

### Phase 15: Documentation Organization

- ✅ **AI Quick Start Section** - Added guidance for common tasks and module patterns at document top
- ✅ **Module Dependencies Section** - Added load order, dependency graph, key relationships table
- ✅ **Event Handlers Table** - Added WoW event handlers by module reference
- ✅ **Missing Files Added** - Added Directory.lua and Relationships.lua to File Quick Reference
- ✅ **Missing Pools Added** - Added collapsiblePool and bossInfoPool to Frame Pooling table
- ✅ **Pool Line Numbers Fixed** - Updated all pool line references to match actual code
- ✅ **File Sizes Updated** - Fixed Effects.lua (~20KB), Sounds.lua (~8KB), Timer.lua (~8KB)
- ✅ **Directory Module Details** - Added comprehensive API documentation with all 8 public functions
- ✅ **Relationships Module Details** - Added comprehensive API documentation with all 12 public functions
- ✅ **FellowTravelers Module Details** - Added communication hub documentation with key API
- ✅ **Data Structures Enhanced** - Expanded HopeAddonCharDB with relationships and full structure
- ✅ **Account Data Added** - Added HopeAddonDB structure documentation
- ✅ **AI Session Handoff Checklist** - Added checklist for session continuity
- ✅ **Boss Detection Resolved** - Removed from Known Incomplete (documented in Phase 14)
- ✅ **Game System Paths Fixed** - Corrected `Games/` to `Social/Games/` throughout
- ✅ **Tests Folder Corrected** - Fixed "LoadOnDemand" to actual files (WordGameTests.lua, README.md)

---

## Development Priorities

1. **Medium:** Implement CheckAttunementIcons for shared attunement icons
2. **Low:** Add milestone detail modal (clickable milestone cards)
3. **Low:** Create dedicated settings panel in journal UI

---

## Documentation Maintenance

**CRITICAL FOR AI CONTINUITY:** This project has no human developer. Documentation accuracy directly impacts whether future AI sessions can work effectively. When in doubt, document it.

### When to Update

| Event | Action |
|-------|--------|
| Feature completed | Move from "Known Incomplete Items" → "Feature Status Summary" with ✅ |
| Bug fixed | Add entry to "Recent Changes"; archive older phases to CHANGELOG.md periodically |
| New issue discovered | Add to "Known Incomplete Items" with file paths and code snippets |
| New file/module created | Add to appropriate "File Quick Reference" table + Architecture Overview |
| SavedVariables/events changed | Update Data Structures section or WoW Event Handlers table |
| Major refactor | Update Architecture Overview tree and Module Dependencies |

### Session Handoff Checklist

Before ending a session:
- [ ] All changes reflected in documentation
- [ ] New dependencies/modules documented
- [ ] Issues added to "Known Incomplete Items"
- [ ] Line numbers and file sizes approximately correct
- [ ] "Recent Changes" section updated
- [ ] Feature status and priorities accurate
