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
├── Journal/        # Main journal system (Journal, Pages, Milestones, ProfileEditor)
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
| Journal UI | ✅ COMPLETE | 7 tabs: Journey, Reputation, Raids, Attunements, Games, Social, Stats |
| Timeline | ✅ COMPLETE | Chronological entries, milestone progress bar |
| Milestones | ✅ COMPLETE | Level-based achievements (5-70), auto-triggers, shown in Journey timeline |
| Attunements | ✅ COMPLETE | All 6 chains (Kara, SSC, TK, Hyjal, BT, Cipher) |
| Reputation | ✅ COMPLETE | 5 TBC factions, milestone tracking |
| Fellow Travelers | ✅ COMPLETE | Addon-to-addon detection, profile sharing |
| RP Profiles | ✅ COMPLETE | Backstory, personality, appearance editor |
| Badges | ✅ COMPLETE | 20+ achievements with unlock conditions |
| Statistics | ✅ COMPLETE | Deaths, playtime, combat stats tracked |
| Data Persistence | ✅ COMPLETE | Migration, defaults, proper save/load |
| Minigames | ✅ COMPLETE | Dice Roll, RPS, Death Roll between Fellow Travelers |
| Tetris Battle | ✅ COMPLETE | Two-player Tetris with garbage mechanic, local & score challenge |
| Death Roll | ✅ COMPLETE | Gambling game with escrow system, 3-player support |
| Pong | ✅ COMPLETE | Classic 2-player Pong with physics, local & score challenge |
| Score Challenge | ✅ COMPLETE | Turn-based score comparison for Tetris/Pong vs remote players |
| Words with WoW | ✅ COMPLETE | Scrabble-style word game with WoW vocabulary, save/resume, async multiplayer |
| Battleship | ✅ COMPLETE | Classic naval battle with text commands, local AI & multiplayer modes |
| Game Chat | ✅ COMPLETE | Reusable /gc chat system for in-game communication |
| Games Hall UI | ✅ COMPLETE | Dedicated Games tab with Practice/Challenge options |
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
| `Social/Games/GameChat.lua` | Reusable in-game chat for all multiplayer games | ~5KB |
| `Social/Games/ScoreChallenge.lua` | Score-based challenges (Tetris/Pong vs remote) | ~12KB |
| `Social/Games/Battleship/BattleshipGame.lua` | Battleship main controller with multiplayer | ~28KB |
| `Social/Games/Battleship/BattleshipUI.lua` | Gameshow-style visual effects for Battleship | ~10KB |
| `Social/Games/Battleship/BattleshipBoard.lua` | 10x10 grid, ship placement, shot logic | ~10KB |
| `Social/Games/Battleship/BattleshipAI.lua` | Hunt/Target AI algorithm | ~8KB |
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
| `Social/Games/WordsWithWoW/WordGamePersistence.lua` | Game save/load, serialization | ~15KB |
| `Social/Games/WordsWithWoW/WordGameInvites.lua` | Async multiplayer invite system | ~17KB |

### UI Framework
| File | Purpose | Size |
|------|---------|------|
| `UI/Components.lua` | All reusable UI components | ~68KB |
| `UI/Glow.lua` | Glow effects | 11KB |
| `UI/Animations.lua` | Animation utilities | 12KB |
| `UI/MinimapButton.lua` | Draggable minimap button | ~6KB |

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
| **Journal.lua** | PLAYER_LEVEL_UP, QUEST_TURNED_IN, PLAYER_DEAD, TIME_PLAYED_MSG, COMBAT_LOG_EVENT_UNFILTERED, SKILL_LINES_CHANGED | Track all player activities |
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
| Layout Builder | `CreateLayoutBuilder()` | Form layout automation |
| Styled Button | `CreateStyledButton()` | Buttons with hover effects |
| Labeled EditBox | `CreateLabeledEditBox()` | Form inputs with labels |
| Labeled Dropdown | `CreateLabeledDropdown()` | Dropdowns with labels |
| Checkbox | `CreateCheckboxWithLabel()` | Checkboxes with labels |

**ScrollContainer Interface:**
```lua
container:AddEntry(frame)           -- Add frame to scroll content
container:ClearEntries(pool)        -- Release all entries to pool
container:RecalculatePositions()    -- Update layout after changes
```

**ColorUtils Namespace** (`HopeAddon.ColorUtils`):
```lua
ColorUtils:Lighten(color, percent)          -- Lighten color by percentage
ColorUtils:Darken(color, percent)           -- Darken color by percentage
ColorUtils:ApplyVertexColor(texture, name)  -- Apply from color name
ColorUtils:ApplyTextColor(fontString, name) -- Apply from color name
ColorUtils:Blend(color1, color2, ratio)     -- Blend two colors
ColorUtils:HexToRGB(hex)                    -- Convert hex to RGB table
```

**Celebration Effects** (`HopeAddon.Effects`):
```lua
Effects:Celebrate(frame, duration, opts)    -- Full effect: glow + sparkles + sound
Effects:IconGlow(frame, duration)           -- Subtle icon glow (1.5s default)
Effects:ProgressSparkles(bar, duration)     -- Progress bar completion sparkles
```

**Spec Detection Utilities** (`HopeAddon`):
```lua
HopeAddon:GetPlayerSpec()                   -- Returns specName, specTab, maxPoints
HopeAddon:GetSpecRole(classToken, specTab)  -- Returns role: "tank", "healer", "melee_dps", etc.
HopeAddon.SPEC_ROLE_MAP                     -- Table mapping class+spec to role
```

---

## Restricted Assets (Do Not Use)

These WoW assets have fixed dimensions and cannot be resized properly for arbitrary frame sizes:

| Asset | Path | Issue |
|-------|------|-------|
| Quest Parchment | `Interface\\QUESTFRAME\\QuestBG` | Locked to quest log dimensions |
| Quest BG Bottom | `Interface\\QUESTFRAME\\QuestBG-Bot` | Fixed quest footer |
| Quest BG Top | `Interface\\QUESTFRAME\\QuestBG-Top` | Fixed quest header |
| Achievement Parchment | `Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment` | Fixed achievement frame size |

**For scalable backgrounds, use these tiling textures:**
- `Interface\\DialogFrame\\UI-DialogBox-Background` (light tan, tiles properly)
- `Interface\\DialogFrame\\UI-DialogBox-Background-Dark` (dark tan, tiles properly)
- `Interface\\Tooltips\\UI-Tooltip-Background` (charcoal, tiles properly)

**Backdrop presets that scale properly:**
| Preset | Background | Border | Use For |
|--------|------------|--------|---------|
| `DARK_GOLD` | Dark tan (tiled) | Gold | Popups, notifications |
| `PARCHMENT_TILED` | Light tan (tiled) | Gold | Main frames |
| `GAME_WINDOW` | Charcoal (tiled) | Gold | Game windows |
| `TOOLTIP` | Charcoal (tiled) | Grey | Cards, inputs |
| `DARK_DIALOG` | Dark tan (tiled) | Grey | Dark frames |

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

<details>
<summary>Detailed Game Specifications (click to expand)</summary>

#### Tetris
- **TetrisGrid** - 10x20 grid with piece placement validation, row clearing, garbage system (local only)
- **TetrisBlocks** - All 7 standard pieces (I, O, T, S, Z, J, L) with SRS rotation and 7-bag randomizer
- **TetrisGame** - LOCAL: Side-by-side boards with garbage mechanic | SCORE_CHALLENGE: Single board, compare scores
- **Controls:** A/D move, W/Q rotate CW/CCW, S soft drop, Space hard drop

#### Pong
- **PongGame** - Classic arcade with ball physics, paddle collision, score to 5
- **LOCAL:** 2 players on same keyboard (W/S and Up/Down)
- **SCORE_CHALLENGE:** Player vs AI paddle, compare who beats AI faster/better
- **AI Paddle:** 85% tracking with prediction, beatable but challenging

<details>
<summary>Pong Core Loop Details (click to expand)</summary>

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

</details>

#### Death Roll
- **DeathRollGame** - Turn-based gambling (100 → N → 1, first to roll 1 loses), uses real `/roll` chat command
- **DeathRollEscrow** - 3-player escrow system with automatic payout, dispute resolution, trust verification

#### Words with WoW
- **WordGame** - Scrabble-style with WoW vocabulary, slash command input (`/word DRAGON H 8 8`), text-based 15x15 board, cross-word validation, pass system (2 consecutive passes ends game)
- **WordBoard** - 15x15 grid with bonus squares (double/triple letter/word), placement validation (connectivity, bounds, center), cross-word detection and scoring
- **WordDictionary** - ~500 WoW-themed words, hash table for O(1) validation, standard Scrabble letter values, tile bag generation

<details>
<summary>Words with WoW Core Loop Details (click to expand)</summary>

**Files:** 5 core files totaling ~3,880 lines
- `WordGame.lua` (2,067 lines) - Main controller, UI, game logic
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

**Scoring System:**

Letter Values (Scrabble standard):
- 1pt: E, A, I, O, N, R, T, L, S, U
- 2pt: D, G
- 3pt: B, C, M, P
- 4pt: F, H, V, W, Y
- 5pt: K
- 8pt: J, X
- 10pt: Q, Z

Bonus Squares (symmetric pattern):
| Type | Multiplier | Color | Count |
|------|------------|-------|-------|
| Double Letter | 2x letter | Green (DL) | 24 |
| Triple Letter | 3x letter | Blue (TL) | 24 |
| Double Word | 2x word | Purple (DW) | 17 |
| Triple Word | 3x word | Red (TW) | 11 |
| Center | 2x word | Gold (★) | 1 |

Scoring Formula:
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

**Multiplayer Protocol (via GameComms):**
| Type | Format | Purpose |
|------|--------|---------|
| MOVE | `word\|H/V\|row\|col\|score` | Word placement |
| PASS | (no data) | Pass turn |
| WINV | serialized state | Game invite |
| WACC | gameId | Accept invite |
| WDEC | gameId | Decline invite |
| WSYNC | full state | Resume sync |

Anti-Cheat: Local score recalculation on every received move. Mismatches logged but local calculation used.

**Persistence (Async Multiplayer):**

Storage: `HopeAddonCharDB.savedGames.words`
```lua
{
    games = { [opponentName] = serializedState },
    pendingInvites = { [sender] = { state, timestamp } },
    sentInvites = { [recipient] = { state, timestamp } },
}
```

Sparse Board Format (only cells with letters stored):
```lua
sparse = {
    [8] = { [8] = "D", [9] = "R", [10] = "A" },
    [9] = { [8] = "A" },
}
```

Timeouts:
- Invite expiry: 24 hours
- Inactivity forfeit: 30 days
- Max concurrent games: 10

**Game End Conditions:**
1. Both Pass Consecutively: `consecutivePasses >= 2` → automatic end
2. Forfeit: Player calls `/hope words forfeit <player>`
3. Winner: Highest score (ties: whoever finished turn last)

**Slash Commands:**
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

**Frame Pooling:**
- boardTile pool (~225 frames) - 15x15 grid tiles
- rackTile pool (~7 frames) - Player hand display
- toast pool - Animated score popups
- Lifecycle: `OnEnable` → CreateFramePools | Game → Acquire/Release | `OnDisable` → DestroyFramePools

**Key Functions Reference:**
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

</details>

#### Battleship
- **BattleshipGame** - Classic naval battle with 10x10 grid, place 5 ships, take turns firing
- **LOCAL:** vs Hunt/Target AI (20% error rate for beatable difficulty)
- **REMOTE:** True turn-based multiplayer with shot/result sync
- **Controls:** Click to place ships, R to rotate | `/fire A5` to shoot, `/ready` when placed, `/surrender` to forfeit
- **BattleshipBoard** - Grid management, ship placement validation, shot processing (HIT/MISS/SUNK)
- **BattleshipAI** - Hunt mode (checkerboard pattern) + Target mode (follow up hits)
- **GameChat** - Reusable `/gc` chat for in-game communication during any multiplayer game

<details>
<summary>Battleship Core Loop Details (click to expand)</summary>

**Files:**
| File | Lines | Purpose |
|------|-------|---------|
| `BattleshipGame.lua` | ~1200 | Main controller, UI, network handlers |
| `BattleshipBoard.lua` | ~400 | 10x10 grid, ship placement, shot logic |
| `BattleshipAI.lua` | ~280 | Hunt/Target AI algorithm |
| `BattleshipUI.lua` | ~680 | Gameshow-style animations (shot results, sunk celebrations, turn prompts) |

**State Machine:**

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

**Ship Definitions (BattleshipBoard.lua:25-31):**

| Ship | ID | Size |
|------|----|------|
| Carrier | `carrier` | 5 |
| Battleship | `battleship` | 4 |
| Cruiser | `cruiser` | 3 |
| Submarine | `submarine` | 3 |
| Destroyer | `destroyer` | 2 |

**Cell States (BattleshipBoard.lua:16-22):**
```lua
CELL = {
    EMPTY = 0,    -- Unshot water
    SHIP = 1,     -- Unshot ship (hidden from opponent)
    HIT = 2,      -- Hit but not sunk
    MISS = 3,     -- Miss
    SUNK = 4,     -- Ship sunk
}
```

**Key Functions:**

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

**Combat Turn Flow:**
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

**AI Algorithm (BattleshipAI.lua):**

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

**Network Protocol:**

| Type | Format | Purpose |
|------|--------|---------|
| `SHOT` | `SHOT\|row\|col` | Fire at coordinates |
| `RESULT` | `RESULT\|row\|col\|hit\|sunk\|shipName` | Shot result |
| `READY` | `READY` | Placement complete |
| `SURRENDER` | `SURRENDER` | Forfeit game |

**Network Flow:**
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

**UI Structure:**
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

**Grid Colors (BattleshipGame.lua:22-32):**

| State | RGB | Description |
|-------|-----|-------------|
| WATER | (0.1, 0.3, 0.5) | Default cell |
| WATER_HOVER | (0.15, 0.4, 0.6) | Hover effect |
| SHIP | (0.4, 0.4, 0.4) | Player's ship |
| HIT | (0.8, 0.2, 0.2) | Hit marker |
| MISS | (0.3, 0.3, 0.5) | Miss marker |
| SUNK | (0.5, 0.1, 0.1) | Sunk ship |

**GameCore Lifecycle:**

| Callback | Purpose |
|----------|---------|
| `OnCreate()` | Initialize boards, AI (local), UI data |
| `OnStart()` | Show UI, begin placement phase |
| `OnUpdate()` | Minimal (turn-based) |
| `OnEnd()` | Display result, play sound |
| `OnDestroy()` | CleanupGame |

**Complete Game Trace (Local Mode):**
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

</details>

</details>

### Score Challenge System

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

### Tetris Core Game Loop Deep Dive

The Tetris implementation is the most complex minigame in HopeAddon. This section documents the full game loop, state machine, and mechanics.

#### File Responsibilities

| File | Purpose | Lines |
|------|---------|-------|
| `TetrisGame.lua` | Main controller: lifecycle, input, UI, AI, networking | ~1950 |
| `TetrisGrid.lua` | 10x20 grid data structure with dirty tracking | ~407 |
| `TetrisBlocks.lua` | Tetromino definitions, colors, SRS wall kicks | ~319 |
| `GameCore.lua` | Shared game loop (60 FPS), state machine, utilities | ~477 |

#### Game Loop Flow (60 FPS)

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

#### Board Update Cycle (per board, per frame)

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

#### Key Timing Constants

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

#### Piece Lifecycle State Machine

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

#### Scoring System

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

#### Input System (DAS/ARR)

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

#### Wall Kicks (SRS)

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

#### T-Spin Detection

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

#### Garbage System

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

#### AI Opponent (60-70% player win rate)

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

#### Game Modes

| Mode | Boards | Garbage | Network |
|------|--------|---------|---------|
| LOCAL | 2 (side-by-side) | Yes | None |
| REMOTE | 1 | Yes | Via GameComms |
| SCORE_CHALLENGE | 1 | No | Status pings only |

#### UI Rendering Optimization

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

#### Board State Structure

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

---

## Testing Commands

```
/hope                          - Open journal
/hope debug                    - Toggle debug mode
/hope stats                    - Show stats in chat
/hope sound                    - Toggle sounds
/hope minimap                  - Toggle minimap button visibility
/hope demo                     - Populate sample data for UI testing
/hope reset demo               - Clear demo data
/hope reset confirm            - Reset all character data
/hope tetris [player]          - Start Tetris Battle (local or vs player)
/hope pong [player]            - Start Pong (local or vs player)
/hope deathroll [player]       - Start Death Roll (local or vs player)
/hope battleship [player]      - Start Battleship (local AI or vs player)
/hope words                    - Start local practice Words game
/hope words <player>           - Resume or start Words vs player
/hope words list               - Show all active Words games
/hope words forfeit <player>   - Forfeit a Words game
/hope words accept [player]    - Accept Words invite
/hope words decline [player]   - Decline Words invite
/word <word> <H/V> <row> <col> - Place word in active Words game (e.g., /word DRAGON H 8 8)
/pass                          - Pass your turn in active Words game
/fire <coord>                  - Fire at coordinate in Battleship (e.g., /fire A5)
/ready                         - Signal ships placed in Battleship
/surrender                     - Forfeit Battleship game
/gc <message>                  - Send chat to opponent in any game
/hope challenge <player> [game] - Challenge via game selection popup
/hope accept                   - Accept pending challenge
/hope decline                  - Decline pending challenge
/hope cancel                   - Cancel current game
```

---

## Recent Changes

See [CHANGELOG.md](CHANGELOG.md) for historical bug fixes (Phases 5-13).

### Phase 35: Fellow Traveler Discovery & Challenge System Fix (2026-01-19)

**Goal:** Fix the Challenge button flow - players standing nearby were not appearing in the Traveler Picker because the PING broadcast was not running continuously.

**Root Cause:** The `BROADCAST_INTERVAL = 15` constant existed but was ONLY used as a rate limiter. There was NO periodic ticker calling `BroadcastPresence()`. Broadcasts only happened on login (once), zone change, or party change.

**Bugs Fixed:**
1. **No Periodic PING Broadcast (CRITICAL)** - Added `broadcastTicker` that calls `BroadcastPresence()` every 15 seconds
2. **Traveler Picker Shows Stale Data** - Now filters by `lastSeenTime` (5-minute threshold)
3. **No Visual Recency Indicators** - Added [Active], [Recent], [Idle] status tags
4. **Silent Challenge Failures** - Improved error messages explaining why challenges fail
5. **YELL Throttling Risk** - YELL now only broadcasts every other cycle (30s) to reduce throttle risk

**Files Modified:**
- **Social/FellowTravelers.lua**
  - Added `broadcastTicker` module state variable
  - Added `yellCounter` for throttle-aware YELL broadcasting
  - `Initialize()` - Added `Timer:NewTicker(BROADCAST_INTERVAL, BroadcastPresence)`
  - `OnDisable()` - Added cleanup for `broadcastTicker`
  - `BroadcastPresence()` - YELL only every other broadcast

- **Social/MinigamesUI.lua**
  - Added `RECENT_THRESHOLD = 300` (5-minute filter)
  - `ShowTravelerPickerForGame()` - Filters fellows by `lastSeenTime`
  - Traveler buttons show recency: `[Active]` (<1m), `[Recent]` (<3m), `[Idle]` (3-5m)
  - Updated "No Fellow Travelers" message with discovery explanation

- **Social/Games/ScoreChallenge.lua**
  - `StartChallenge()` - Uses `GetFellow()` for detailed data
  - Improved error messages for undiscovered players
  - Warns if player was last seen >5 minutes ago

- **Social/Games/GameComms.lua**
  - `SendInvite()` - Added same fellow validation and recency checks
  - Improved error messages matching ScoreChallenge pattern

**WoW API Reference (for future developers):**
- `C_ChatInfo.SendAddonMessage(prefix, message, chatType, target)` - Max 255 chars, 16-char prefix
- YELL/SAY heavily throttled in Classic; WHISPER is NOT throttled outside instances
- Per-prefix allowance: 10 messages, regenerates 1/second
- Recipients must call `C_ChatInfo.RegisterAddonMessagePrefix(prefix)`

**Testing:**
1. Two characters in same zone should discover each other within 30 seconds
2. Traveler Picker should only show fellows seen in last 5 minutes
3. Challenge to undiscovered player shows helpful error
4. Challenge to stale (>5 min) player shows warning but still sends

### Phase 33: Battleship Gameshow UI Enhancement (2026-01-19)

**Goal:** Add gameshow-style visual effects to Battleship matching Death Roll's flashy UI pattern.

**New File Created:**
- **BattleshipUI.lua** (~380 lines) - Gameshow visual effects module
  - Frame pools: `shotResultPool`, `turnPromptPool`
  - `ShowShotResult(gameId, resultType, coord, shipName, isPlayerShot)` - Animated HIT/MISS/SUNK reveal
  - `ShowTurnPrompt(gameId, turnState, opponentName, shipInfo)` - Pulsing turn banner
  - `ShowShipSunkCelebration(gameId, shipName, isEnemy)` - Sparkles/shake effects
  - `ShowVictoryOverlay(gameId, didWin, stats)` - End-game overlay with stats

**Files Modified:**
- **Sounds.lua** - Added `battleship` sound category (shot, hit, miss, sunk, yourTurn, victory, defeat)
- **BattleshipGame.lua** - Integrated BattleshipUI calls:
  - `OnEnd()` - Shows victory/defeat overlay
  - `PlayerShoot()` - Shows shot result animation
  - `AITurn()` - Shows AI shot animation
  - `ProcessShotResult()` - Shows network shot animation
  - `UpdateStatus()` - Uses turn prompt banner
  - `CleanupGame()` - Releases UI frames
- **HopeAddon.toc** - Added BattleshipUI.lua to load order

**Animation Sequence (1.4s):**
1. Sound plays (hit/miss/sunk)
2. "HIT!" text pops in with color
3. Coordinate "[B5]" fades in
4. If SUNK: ship name + burst effect
5. Elements fade out, turn prompt appears

**Turn Prompt States:**
- `YOUR_TURN` - Green text, gold pulsing border, "/fire A5" hint
- `ENEMY_TURN` - Grey text, muted border, "Waiting for [name]..."
- `PLACEMENT` - Blue text, ship info, "R to rotate" hint

### Phase 34: Spec-Aware Loot Hotlist Expansion (2026-01-19)

**Goal:** Transform the Journey tab's Loot Hotlist from class-only reputation items to a comprehensive, spec-aware system with three collapsible item source categories.

**New Features:**
- ✅ **Spec Detection** - Determines player's primary spec by checking talent point distribution
- ✅ **Three Item Categories** - Reputation Rewards, Dungeon Drops, Crafted Gear (3 items each = 9 total)
- ✅ **Collapsible Sections** - Each category in its own collapsible section
- ✅ **27 Spec Configurations** - All 9 TBC classes × 3 specs with role-appropriate items

**New Core Functions (Core.lua:559-640):**
```lua
HopeAddon.SPEC_ROLE_MAP = {
    ["WARRIOR"] = { [1] = "melee_dps", [2] = "melee_dps", [3] = "tank" },
    ["PALADIN"] = { [1] = "healer", [2] = "tank", [3] = "melee_dps" },
    ["HUNTER"] = { [1] = "ranged_dps", [2] = "ranged_dps", [3] = "ranged_dps" },
    ["ROGUE"] = { [1] = "melee_dps", [2] = "melee_dps", [3] = "melee_dps" },
    ["PRIEST"] = { [1] = "healer", [2] = "healer", [3] = "caster_dps" },
    ["SHAMAN"] = { [1] = "caster_dps", [2] = "melee_dps", [3] = "healer" },
    ["MAGE"] = { [1] = "caster_dps", [2] = "caster_dps", [3] = "caster_dps" },
    ["WARLOCK"] = { [1] = "caster_dps", [2] = "caster_dps", [3] = "caster_dps" },
    ["DRUID"] = { [1] = "caster_dps", [2] = "tank", [3] = "healer" },
}

function HopeAddon:GetPlayerSpec()     -- Returns specName, specTab, maxPoints
function HopeAddon:GetSpecRole(classToken, specTab)  -- Returns role string
```

**New Data Structure (Constants.lua:3972+):**
```lua
C.CLASS_SPEC_LOOT_HOTLIST = {
    ["WARRIOR"] = {
        [1] = { -- Arms
            rep = { {itemId, name, icon, quality, slot, stats, faction, standing}, ... },
            drops = { {itemId, name, icon, quality, slot, stats, source, sourceType}, ... },
            crafted = { {itemId, name, icon, quality, slot, stats, profession, sourceType}, ... },
        },
        [2] = { ... }, -- Fury
        [3] = { ... }, -- Protection
    },
    -- All 9 classes with 3 specs each (27 configurations, ~243 items total)
}
```

**Updated Journal Functions (Journal.lua:1634-1841):**
- `CreateLootHotlist()` - Now detects spec and creates 3 collapsible sections
- `CreateLootCategorySection(parent, title, colorName, index, yOffset)` - Creates collapsible section frame
- `CreateLootCard(parent, item, cardKey)` - Updated to handle all source types:
  - Rep items: Purple text, faction progress bar
  - Drops: Blue text, "Dungeon Drop" tag
  - Crafted: Orange text, profession name

**UI Layout:**
```
[Your Class - Spec Name] (e.g., "WARRIOR - Protection")

[▼] Reputation Rewards (purple header)
    - Item 1 with faction progress bar
    - Item 2 with faction progress bar
    - Item 3 with faction progress bar

[▼] Dungeon Drops (green header)
    - Item 1 (source: Heroic Mechanar)
    - Item 2 (source: Normal Arcatraz)
    - Item 3 (source: Heroic Shadow Labyrinth)

[▼] Crafted Gear (gold header)
    - Item 1 (Blacksmithing)
    - Item 2 (Leatherworking)
    - Item 3 (Tailoring)
```

**Design Decisions:**
- Feral Druid (Tab 2): Recommends Tank (Bear) gear since tanks have stricter requirements
- Uses `GetTalentTabInfo()` API for TBC Classic 2.4.3 compatibility
- Items are pre-Karazhan BiS focused (normal/heroic 5-mans, rep rewards, BoE crafted)

**Files Modified:**
| File | Changes |
|------|---------|
| Core/Core.lua | Added SPEC_ROLE_MAP, GetPlayerSpec(), GetSpecRole() (~80 lines) |
| Core/Constants.lua | Added CLASS_SPEC_LOOT_HOTLIST (~900 lines of item data) |
| Journal/Journal.lua | Rewrote CreateLootHotlist, CreateLootCard, added CreateLootCategorySection (~200 lines) |

### Phase 32: Journey Tab Loot Hotlist (2026-01-19)

**Goal:** Initial implementation of class-specific "Loot Hotlist" showing Top 3 recommended items from reputation rewards.

**Note:** This phase was superseded by Phase 34 which added spec detection and multiple item categories.

**Original Implementation:**
- `C.CLASS_LOOT_HOTLIST` - Top 3 items per class (9 classes x 3 items = 27 entries)
- `C.ITEM_QUALITY_COLORS` - Epic, rare, uncommon, common color definitions
- `C.STANDING_NAMES` - Reputation standing name lookup (1-8)

### Phase 31: Battleship Multiplayer & Game Chat System (2026-01-19)

**Goal:** Implement true turn-based multiplayer for Battleship with text-based commands and create a reusable in-game chat system for all games.

**New Files Created:**
- ✅ **GameChat.lua** (~120 lines) - Reusable chat module for all multiplayer games
  - `/gc <message>` and `/gamechat <message>` slash commands
  - Auto-routes to active game's opponent
  - Embeddable chat display frame for game windows
  - Message history with timestamps

**Slash Commands Added (Core.lua):**
| Command | Usage | Description |
|---------|-------|-------------|
| `/fire` | `/fire A5` | Fire at coordinate (letter + number) |
| `/ready` | `/ready` | Signal ships placed, ready to play |
| `/surrender` | `/surrender` | Forfeit the current game |
| `/gc` | `/gc Good luck!` | Send chat to opponent (all games) |

**Network Protocol (BattleshipGame.lua):**
| Type | Format | Purpose |
|------|--------|---------|
| SHOT | `SHOT\|row\|col` | Fire at coordinates |
| RESULT | `RESULT\|row\|col\|hit\|sunk\|shipName` | Shot result response |
| READY | `READY` | Signal placement complete |
| SURRENDER | `SURRENDER` | Forfeit game |

**Key Functions Added:**
- `RegisterNetworkHandlers()` - Registers MOVE, STATE, END handlers with GameComms
- `HandleNetworkMove()` - Processes SHOT and RESULT messages
- `HandleNetworkState()` - Processes READY signals
- `HandleNetworkEnd()` - Processes SURRENDER
- `ProcessOpponentShot()` - Fires shot at player board, sends result
- `ProcessShotResult()` - Updates tracking board with hit/miss
- `SendShot()` / `SendShotResult()` / `SendReady()` - Network message senders
- `SignalReady()` - Validates placement and signals ready
- `Surrender()` - Forfeits game and notifies opponent

**Game State Additions:**
```lua
state = {
    playerReady = false,      -- Has local player signaled ready
    opponentReady = false,    -- Has opponent signaled ready (AI always true)
    isChallenger = bool,      -- Determines who shoots first
    sunkEnemyShips = 0,       -- Tracks win condition
    currentTurn = "waiting",  -- New state: awaiting shot result
}
```

**Game Flow (Multiplayer):**
1. `/hope battleship PlayerName` → Sends invite
2. Both players place ships, type `/ready`
3. "Waiting for opponent..." until both ready
4. Challenger shoots first with `/fire A5`
5. Turns alternate with shot/result sync
6. First to sink all 5 ships wins

**Files Modified:**
- `Core/Core.lua` - Added slash commands (~110 lines)
- `Social/Games/Battleship/BattleshipGame.lua` - Network handlers (~300 lines)
- `HopeAddon.toc` - Added GameChat.lua to load order

### Phase 30: Words with WoW TBC Cartoon UI Overhaul (2026-01-19)

**Goal:** Transform the minimal text-based Words UI into a visually rich, cartoon TBC-themed Scrabble experience.

**Major Changes:**

**Phase A: Board Visual Core**
- ✅ Frame-based 15x15 tile grid replacing ASCII text board
- ✅ Parchment background texture (`QUESTFRAME\QuestBG`)
- ✅ Color-coded bonus squares (TBC themed):
  - Fel green (Double Letter), Sky blue (Triple Letter)
  - Arcane purple (Double Word), Hellfire red (Triple Word)
  - Gold star (Center)
- ✅ MORPHEUS font letters with point values

**Phase B: Player Panels & Status**
- ✅ Tile hand tracking with 7-tile rack display
- ✅ Player panels with portrait icons and active glow
- ✅ Turn banner with "YOUR TURN!" pulsing glow

**Phase C: Animations & Feedback**
- ✅ Recently placed tiles show gold glow (3 seconds)
- ✅ Floating score popup toasts (rise + fade animation)
- ✅ Sound effects tied to score thresholds (GOOD/GREAT/AMAZING)

**Phase D: Game End & Polish**
- ✅ Parchment results overlay with:
  - Winner announcement with crown icon
  - Final scores for both players
  - Statistics: words played, turns, best word
  - Close button
- ✅ Hover tooltips for bonus squares showing multiplier info
- ✅ Hover tooltips for placed tiles showing who played them

**New Constants** (Constants.lua):
```lua
C.WORDS_BONUS_COLORS     -- TBC-themed colors for 6 bonus types
C.WORDS_BONUS_LABELS     -- Labels: DL, TL, DW, TW, ★
C.WORDS_BONUS_NAMES      -- Tooltip text for each bonus
C.WORDS_TILE_SIZE        -- 32 pixels
C.WORDS_TILE_COLORS      -- Placed, border, glow, letter, points colors
C.WORDS_SCORE_THRESHOLDS -- GOOD=20, GREAT=30, AMAZING=50
```

**New WordGame.lua Functions:**
- `CreateFramePools()` / `DestroyFramePools()` - Frame pool management
- `InitializeTileFrame()` / `AcquireTileFrame()` / `ReleaseTileFrame()` - Tile pooling
- `CreateTileBag()` / `DrawTiles()` / `RefillHand()` - Tile bag system
- `CreatePlayerPanel()` / `CreateTurnBanner()` / `CreateTileRack()` - UI creation
- `UpdateBoardTiles()` / `UpdateTileRack()` - Efficient updates
- `OnTileEnter()` / `OnTileLeave()` - Tooltip handlers
- `ShowScoreToast()` - Animated score popup
- `ShowGameOverScreen()` - Results overlay
- `MarkRecentlyPlaced()` - Glow tracking

**Window Size:** Changed from 650x600 to 700x720 to accommodate tile rack

**Files Modified:**
- `Social/Games/WordsWithWoW/WordGame.lua` - Complete UI overhaul (~500 lines added)
- `Social/Games/GameUI.lua` - Updated WORDS window size
- `Core/Constants.lua` - Added WORDS_* constants (~60 lines)

### Phase 29: Words with WoW Save/Resume & Async Multiplayer (2026-01-19)

**Goal:** Enable Words with WoW games to persist across sessions and support async multiplayer (play vs offline opponents).

**New Files Created:**
- ✅ **WordGamePersistence.lua** (~400 lines) - Save/load game state for async multiplayer
  - `SerializeGame(game)` / `DeserializeGame(data)` - Full game state serialization
  - `SerializeBoard(board)` - Sparse format (only cells with letters, bonuses calculated)
  - `SaveGame(opponentName, game)` / `LoadGame(opponentName)` / `ClearGame(opponentName)`
  - `SavePendingInvite()` / `SaveSentInvite()` - Invite tracking
  - `CleanupExpired()` - Removes 24h expired invites, 30d inactive games
  - `GenerateBoardHash()` / `BoardsMatch()` - State validation
  - Configuration: 24h invite timeout, 30d inactivity forfeit, 10 max concurrent games

- ✅ **WordGameInvites.lua** (~500 lines) - Multiplayer invite system
  - Message types: WINV (invite), WACC (accept), WDEC (decline), WSYNC (state sync), WRES (resume)
  - `SendInvite(opponent)` - Creates game, sends via GameComms GSYNC
  - `AcceptInvite(senderName)` / `DeclineInvite(senderName)` - Handle invites
  - `HandleInviteReceived()` / `HandleAcceptReceived()` / `HandleDeclineReceived()`
  - `HandleStateSync()` / `HandleResumeRequest()` - Game resumption
  - `SerializeState()` / `DeserializeState()` - Network serialization
  - Shows MinigamesUI popup when invite received

**Files Modified:**
- ✅ **WordGame.lua** - Added persistence hooks
  - `OnEnable()` now calls `RestoreSavedGames()` to resume games from previous session
  - `OnDisable()` now calls `SaveAllGames()` to persist active games
  - New functions: `SaveGame()`, `SaveAllGames()`, `RestoreSavedGames()`, `ResumeGame()`, `ListSavedGames()`, `ForfeitGame()`

- ✅ **Core.lua** - SavedVariables and slash commands
  - Added `savedGames.words` to default charDb with games, pendingInvites, sentInvites tables
  - Extended `/hope words` command: `list`, `forfeit <player>`, `accept [player]`, `decline [player]`
  - `/hope accept` and `/hope decline` now check Words invites first

- ✅ **HopeAddon.toc** - Added new files to load order

- ✅ **Components.lua** - Added active games badge to CreateGameCard
  - `card:SetActiveGames(count)` - Shows "X active" badge, changes Practice to "Continue"

- ✅ **Journal.lua** - Games tab integration
  - Shows active Words games count on game card
  - Uses `WordGamePersistence:GetGameCount()` to get count

**Network Protocol (via GSYNC):**
| Message | Format | Purpose |
|---------|--------|---------|
| WINV | `WINV:serializedState` | Game invite with initial board |
| WACC | `WACC:gameId` | Accept invite |
| WDEC | `WDEC:gameId` | Decline invite |
| WSYNC | `WSYNC:serializedState` | Full state sync for resume |
| WRES | `WRES:gameId` | Resume request (opponent online) |

**SavedVariables Structure:**
```lua
charDb.savedGames = {
    words = {
        games = {},             -- [opponentName] = serialized game state
        pendingInvites = {},    -- [senderName] = { state, timestamp }
        sentInvites = {},       -- [recipientName] = { state, timestamp }
    },
}
```

**Slash Commands:**
```
/hope words                    -- Start local practice game
/hope words <player>           -- Resume existing game or send new invite
/hope words list               -- Show all active games
/hope words forfeit <player>   -- Forfeit specific game
/hope words accept [player]    -- Accept pending invite
/hope words decline [player]   -- Decline pending invite
```

**Design Decisions:**
- Invite timeout: 24 hours
- Multiple simultaneous games: Yes (up to 10)
- Inactivity auto-forfeit: 30 days
- Board hash validation on resume to detect desync

### Phase 28: Social Tab RP Redesign (2026-01-19)

**Goal:** Transform Social tab into comprehensive RP-style experience with profile section and badge-based titles.

**New Features:**
- ✅ **Your Profile Section** (Journal.lua:2867-3057) - Lit-up container with golden glow at top of Social tab
  - Player name with selected title displayed in badge color
  - Class icon and level display
  - Title dropdown (shows only unlocked titles from badges)
  - RP Status dropdown (IC / OOC / Looking for RP)
  - Edit Profile button → Opens ProfileEditor for backstory/personality
- ✅ **Fellow Traveler Titles** (Journal.lua:3211-3270) - Cards now show player's selected title in badge color
  - Format: "PlayerName |cFFcolor<Title>|r"
  - Title color comes from the badge that granted it
- ✅ **Badges Section in Stats Tab** (Journal.lua:3568-3661) - Dedicated badge display
  - Shows all badges with earned/unearned status
  - Earned badges: Full color icon with badge-color border
  - Unearned badges: Greyed out, desaturated icon
  - Displays unlock date, title reward, color reward for each
- ✅ **Badge Helper Functions** (Badges.lua:420-445)
  - `GetTitleColor(title)` - Returns hex color for a title
  - `FormatNameWithTitle(name, title)` - Formats name with colored title
- ✅ **Demo Mode Badges** (Core.lua:1452-1474) - `/hope demo` now unlocks sample badges for testing

**Files Modified:**
- `Journal/Journal.lua` - Added CreateMyProfileSection, PopulateBadgesSection, modified PopulateSocial, CreateDirectoryCard
- `Social/Badges.lua` - Added GetTitleColor, FormatNameWithTitle, fixed DISPLAY_ORDER
- `Core/Core.lua` - Updated PopulateDemoData and ClearDemoData for badge testing

**Data Flow:**
```
User selects title → charDb.travelers.myProfile.selectedTitle updated
                   → UI updates immediately
                   → FellowTravelers broadcasts on next ping
                   → Other players see title in their Social tab
```

**Badges with Titles:**
| Badge | Title | Color |
|-------|-------|-------|
| hero_of_outland | "Hero" | Gold (#FFD700) |
| prince_slayer | "Prince Slayer" | Epic Purple (#A335EE) |
| gruul_slayer | "Dragonkiller" | Earth Brown (#8B4513) |
| magtheridon_slayer | "Pit Lord's Bane" | Crimson (#DC143C) |
| vashj_slayer | "Champion" | Sea Green (#20B2AA) |
| kael_slayer | "Champion" | Phoenix Orange (#FF4500) |
| aldor_exalted | "of the Aldor" | Holy White (#FFFFFF) |
| scryer_exalted | "of the Scryers" | Arcane Blue (#6A5ACD) |
| epic_flying | "Swiftwind" | Royal Blue (#4169E1) |

### Phase 27: Minimap Button (2026-01-19)

**Goal:** Add standard minimap button for easy journal access.

**New Features:**
- ✅ **Draggable Minimap Button** (UI/MinimapButton.lua) - Click to toggle journal
  - Left-click: Toggle journal open/closed
  - Right-click: Show help message
  - Drag: Reposition around minimap edge
  - Position saved account-wide in `HopeAddonDB.minimapButton.position`
- ✅ **Standard WoW Appearance** - Book icon with tracking border ring
- ✅ **Tooltip** - Shows addon name, version, click instructions
- ✅ **Toggle Command** - `/hope minimap` to show/hide button

**Files Created:**
- `UI/MinimapButton.lua` - Complete minimap button module (~200 lines)

**Files Modified:**
- `HopeAddon.toc` - Added MinimapButton.lua to load order
- `Core/Core.lua` - Added minimapButton defaults and `/hope minimap` command

**SavedVariables:**
```lua
HopeAddonDB.minimapButton = {
    position = 225,  -- Angle in degrees (225 = lower-left)
    enabled = true,  -- Show/hide button
}
```

### Phase 26: Death Roll Gameshow Enhancement (2026-01-19)

**Goal:** Transform Death Roll into an exciting gameshow experience with dramatic announcements, big number displays, and clear turn instructions.

**New Features:**
- ✅ **Big Number Display** (DeathRollUI.lua:557-591) - Large animated number reveals with danger-colored text
- ✅ **Danger Level System** (DeathRollUI.lua:25-52, 535-549) - 5 levels: SAFE, CAUTION, DANGER, CRITICAL, DEATH
  - Color-coded: Gold → Yellow → Orange → Red → Dark Red
  - Unique messages: "SAFE!" → "Getting risky..." → "DANGER ZONE!" → "ONE WRONG MOVE..." → "ELIMINATED!"
- ✅ **Turn Prompt Banner** (DeathRollUI.lua:599-636, 779-816) - Pulsing gold "YOUR TURN!" with `/roll` command hint
  - Uses `Effects:CreatePulsingGlow()` for attention
  - Shows "Waiting for [opponent]..." when not your turn
- ✅ **Animation Sequence** (DeathRollUI.lua:719-771) - Suspense → Reveal → Message → Turn Prompt flow
  - Shake effect on CRITICAL/DANGER rolls
  - Burst effect on DEATH rolls
  - 1.2s animation lock prevents double-rolls
- ✅ **Sound Effects** (Sounds.lua:72-82, 196-211) - New `deathroll` category with 8 sounds
  - suspense (gong), reveal, safe (tick), caution (bell), danger (error), critical, death, yourTurn
- ✅ **Frame Pooling Optimization** (DeathRollUI.lua:94-96, 117-216) - Memory-efficient UI
  - `bigNumberPool` and `turnPromptPool` using `HopeAddon.FramePool`
  - Frames acquired on game start, released on cleanup (not destroyed)
  - Pools destroyed on OnDisable, fallback to direct creation if pools unavailable

**Files Modified:**
- `Social/Games/DeathRoll/DeathRollUI.lua` - Added gameshow UI with frame pooling (~450 lines)
- `Social/Games/DeathRoll/DeathRollGame.lua` - Modified ProcessRoll/ShowUI for animations
- `Core/Sounds.lua` - Added deathroll sound category

**Key Functions:**
- `DeathRollUI:CreateFramePools()` - Initialize frame pools on enable
- `DeathRollUI:AcquireBigNumberFrame(parent)` - Get frame from pool
- `DeathRollUI:AcquireTurnPromptFrame(parent)` - Get frame from pool
- `DeathRollUI:GetDangerLevel(roll, max)` - Returns danger level string
- `DeathRollUI:ShowRollResult(gameId, roll, max, playerName, isLocalPlayer)` - Animated reveal
- `DeathRollUI:ShowTurnPrompt(gameId, maxRoll, isYourTurn, opponentName)` - Pulsing turn banner
- `DeathRollUI:InitializeGameshowFrames(gameId, contentFrame)` - Acquires frames from pools
- `DeathRollUI:CleanupGameshowFrames(gameId)` - Releases frames back to pools
- `DeathRollGame:ProcessRoll()` - Now triggers gameshow animations with 1.2s delay

**Testing:**
```
/hope deathroll           -- Local game (vs yourself)
/hope deathroll Thrall    -- Remote game (vs player)
```

### Phase 23: Journey Tab Enhancements (2026-01-19)

**New Features:**
- ✅ **Next Step Box** (Journal.lua:1652-1664) - Prominent WoWhead-style progression guidance at top of Journey tab
  - `GetNextStep()` function at line 1636 returns progression data
  - Adapts to 5 phases: PRE_OUTLAND, T4_ATTUNEMENT, T5_ATTUNEMENT, T6_ATTUNEMENT, RAID_PROGRESSION, ENDGAME
  - Shows current chapter, story text, progress bar with phase-colored fill
  - Phase-colored borders (FEL_GREEN for T4, ARCANE_PURPLE for T5, HELLFIRE_RED for T6, etc.)
- ✅ **Enhanced Reputation Summary** (Journal.lua:1607-1634) - Progress bars and reward tracking
  - Per-faction rows with progress bars showing rep within current standing
  - Shows heroic key status with [Key] indicator when Honored+
  - Color-coded standings and progress fills
- ✅ **New Constants** (Journal.lua:51-89) - HEROIC_KEY_ICONS, HEROIC_KEY_NAMES, REQUIREMENT_TYPE_ICONS, PHASE_COLORS, PHASE_NAMES, STANDING_THRESHOLDS, STANDING_NAMES

**Key Functions Added:**
- `Journal:GetNextStep()` (line 1636) - Returns comprehensive progression data for the Next Step box
- `Journal:CreateNextStepBox()` (line 1652) - Creates the prominent Next Step guidance UI
- Enhanced `Journal:CreateReputationSummary()` (line 1607) - Now shows progress bars and reward info
- `Journal:PopulateJourney()` (line 1703) - Updated to call CreateNextStepBox at top of Journey tab

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
- ✅ **Tab Color Verification** - Audited all 7 journal tabs, confirmed TBC palette usage:
  - Journey: GOLD_BRIGHT (primary), FEL_GREEN (Outland content)
  - Zones: FEL_GREEN (Outland Exploration)
  - Reputation: ARCANE_PURPLE (main header), GOLD_BRIGHT (categories)
  - Attunements: ARCANE_PURPLE (magic theme), tier colors
  - Raids: Tier colors (T4=GOLD_BRIGHT, T5=SKY_BLUE, T6=HELLFIRE_RED)
  - Games: ARCANE_PURPLE (Games Hall)
  - Social: FEL_GREEN (Fellow Travelers)
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

### Phase 18: Score Challenge System (2026-01-19)

**Problem:** Real-time multiplayer Tetris/Pong over WoW addon communication has 100-500ms+ latency, making gameplay feel laggy and requiring complex sync logic.

**Solution:** Score-based challenge mode - both players play their own local game simultaneously, compare scores at end.

**New Files:**
- ✅ **ScoreChallenge.lua** (~400 lines) - Complete challenge orchestration module
  - Challenge invite/accept/decline flow with 60s timeout
  - Status pings every 10 seconds show opponent progress
  - Simple anti-cheat with hash tokens (prevents casual injection)
  - Game end handling with score comparison
  - 600s game timeout, 120s wait for opponent timeout

**Modified Files:**
- ✅ **GameCore.lua** - Added `SCORE_CHALLENGE` to `GAME_MODE` enum
- ✅ **TetrisGame.lua** - Score challenge integration:
  - `isScoreChallenge` state tracking
  - Skip garbage mechanics in SCORE_CHALLENGE mode
  - Opponent status panel (`CreateOpponentPanel`, `UpdateOpponentPanel`)
  - Notify ScoreChallenge on score updates and game over
- ✅ **PongGame.lua** - AI paddle and score challenge:
  - `UpdateAIPaddle()` - 85% tracking with ball prediction, beatable but challenging
  - Opponent status panel for challenge mode
  - Player vs AI, compare who beats AI faster/better
- ✅ **GameComms.lua** - Routes `SCORE_TETRIS` and `SCORE_PONG` game types to ScoreChallenge module
- ✅ **GameUI.lua** - Added `UpdateOpponentStatus()` function to route updates to games
- ✅ **Core.lua** - Updated slash commands:
  - `/hope tetris [player]` uses ScoreChallenge when player specified
  - `/hope pong [player]` uses ScoreChallenge when player specified
  - `/hope accept/decline/cancel` check ScoreChallenge first
- ✅ **HopeAddon.toc** - Added ScoreChallenge.lua to load order

**Key Design Decisions:**
- Pong AI Paddle approach (user confirmed) - both players compete vs AI, compare scores
- Simple hash anti-cheat (user confirmed) - concatenated player names + score + gameId hash
- Reuses existing GameComms infrastructure with SCORE_ prefix game types
- No changes to local 2-player modes (preserved)

**UI Integration Fixes (2026-01-19):**
- ✅ **ScoreChallenge popup notification** (ScoreChallenge.lua:486-520) - Added call to `MinigamesUI:ShowChallengePopup()` when challenge received, plays bell sound
- ✅ **Accept/Decline routing** (MinigamesUI.lua:65-124) - Added `scorechallenge` source handling to route Accept/Decline to `ScoreChallenge:AcceptChallenge/DeclineChallenge`
- ✅ **GAME_NAMES table** (MinigamesUI.lua:45-60) - Added `SCORE_TETRIS` and `SCORE_PONG` display names ("Tetris Score Battle", "Pong Score Battle")
- ✅ **Traveler picker routing** (MinigamesUI.lua:1318-1365) - Games Hall Challenge button now routes Tetris/Pong to `ScoreChallenge:StartChallenge()` instead of `GameComms:SendInvite()`

**User Flow:**
1. Games Hall → Click "Challenge" on Tetris/Pong card → Traveler Picker popup
2. Select Fellow Traveler → ScoreChallenge sends invite via GameComms
3. Opponent receives popup with Accept/Decline buttons + bell sound
4. Both players start local game simultaneously with opponent status panel

### Phase 19: UI Organization & Documentation (2026-01-19)

**Low Priority Fixes (L1-L5):**
- ✅ **L1: Minimap Tooltip Icons** (MapPins.lua:30-55) - Added icon display using `TravelerIcons:GetHighestQualityIcon()`; falls back to default "INV_Misc_GroupLooking" icon
- ✅ **L2: Inline Handler Closures** - Verified already resolved; all handlers at module scope in MinigamesUI.lua
- ✅ **L3: Font Constants** (GameUI.lua:27-35) - Added `GAME_FONTS` centralized table with TITLE, SCORE, LABEL, STATUS, HINT, MONOSPACE
- ✅ **L4/L5: BROWN Color Elimination** - Replaced all hardcoded BROWN (0.6, 0.5, 0.3) with ARCANE_PURPLE:
  - Journal.lua: Card borders (line 408-409), button border (line 2963)
  - MinigamesUI.lua: Game button leave (line 229), dice frames (lines 545, 573), RPS buttons (line 948)

**Documentation Updates:**
- ✅ Updated UI_ORGANIZATION_GUIDE.md to v1.2:
  - All Low Priority issues marked resolved
  - Phase 4 marked complete
  - Added Phase 17 utility examples (LayoutBuilder, CreateStyledButton, Celebration Effects)
  - Updated Part 7 Critical Files to show resolved status
- ✅ Updated CLAUDE.md:
  - Added Phase 17 utilities to Shared UI Components table
  - Added ColorUtils and Celebration Effects documentation
  - Added this Phase 19 entry

**Files Modified:**
- Journal.lua (2 color replacements)
- MinigamesUI.lua (4 color replacements)
- MapPins.lua (tooltip icon support)
- GameUI.lua (GAME_FONTS table)
- UI_ORGANIZATION_GUIDE.md (v1.2 update)
- CLAUDE.md (utilities documentation, Phase 19)

### Phase 20: UI Rendering Fixes & Demo Mode (2026-01-19)

**Critical Fix: Scroll Content Frame Width**
- ✅ **Problem:** `CreateScrollFrame` calculated content width before `SetAllPoints` was called, resulting in 0 width
- ✅ **Fix:** Added `OnSizeChanged` handler to update content width when scroll frame is resized (Components.lua:620-630)
```lua
scrollFrame:SetScript("OnSizeChanged", function(self, newWidth, newHeight)
    if newWidth and newWidth > 0 then
        content:SetWidth(newWidth)
    end
end)
```

**Demo Data Mode for UI Testing**
- ✅ **Commands:** `/hope demo` (populate) and `/hope reset demo` (clear)
- ✅ **Implementation:** `PopulateDemoData()` and `ClearDemoData()` functions in Core.lua
- ✅ **Sample Data Includes:**
  - 6 level milestones (5, 10, 15, 20, 25, 30)
  - 3 zone discoveries (Hellfire, Zangarmarsh, Shattrath)
  - Stats: deaths, playtime, quests completed, creatures slain, largest hit
  - 3 sample travelers (Thrall, Jaina, Sylvanas)
  - 1 Fellow Traveler with RP profile (Arthas)
  - 1 relationship note

**Documentation:**
- ✅ Updated UI_COMPLETION_CHECKLIST.md - Marked P0/P1 complete, added fix details
- ✅ Updated CLAUDE.md Testing Commands - Added /hope demo commands
- ✅ Created new document UI_COMPLETION_CHECKLIST.md - Tracks UI completion tasks

**Files Modified:**
- Components.lua (scroll content width fix)
- Core.lua (PopulateDemoData, ClearDemoData, slash command handlers)
- UI_COMPLETION_CHECKLIST.md (status updates)
- CLAUDE.md (Phase 20, demo commands)

### Phase 21: Fellow Traveler Detection Improvements (2026-01-19)

**Discovery Notification Enhancements:**
- ✅ **Comedy Sound:** Added Murloc aggro sound (`FELLOW_DISCOVERY`) plays when new Fellow Traveler detected
- ✅ **Sound Cooldown:** Added 30-second cooldown (`DISCOVERY_SOUND_COOLDOWN`) to prevent audio spam in crowded areas (Shattrath, raids)
- ✅ **Enhanced Message:** Changed from plain text to colorful: `|cFF9B30FF[Fellow Traveler]|r |cFF00FF00Name|r discovered nearby! Mrglglgl!`
- ✅ **Faster Detection:** Reduced `BROADCAST_INTERVAL` from 30s to 15s for quicker discovery

**How Fellow Traveler Detection Works:**
1. Addon broadcasts PING on YELL (300yd), PARTY, RAID, GUILD channels every 15 seconds
2. Other addon users respond with PONG containing their info
3. On first discovery of a new player: Murloc sound plays + chat notification
4. Fellow Travelers appear on minimap pins and in Directory tab
5. Hovering over Fellow Travelers in-world shows full RP profile tooltip

**Existing Tooltip Features (already implemented):**
- Fellow Traveler badge
- Selected title
- RP Status (IC/OOC/LF_RP)
- Backstory excerpt (100 chars)
- Personality traits
- Appearance description
- RP Hooks/Rumors
- Pronouns
- First seen date

**Files Modified:**
- Core.lua (added FELLOW_DISCOVERY sound path)
- FellowTravelers.lua (broadcast interval 30→15s, discovery notification with sound)

### Phase 22: Gaming-Style Reputation Bar (2026-01-19)

**Goal:** Transform reputation bars into satisfying "gaming XP bar" experience with chunky segments and audio feedback.

**Visual Enhancements:**
- ✅ **Texture Swap** (Components.lua:1668) - Changed from `SKILLS_BAR` (striated) to `STATUS_BAR` (smooth metallic gradient)
- ✅ **Segment Dividers** (Components.lua:1718-1729) - 9 vertical dividers at 10% intervals for chunky gaming feel
- ✅ **Diamond Milestones** (Components.lua:1735-1746) - Replaced thin tick marks with rotated GLOW_STAR diamonds at 25/50/75%
- ✅ **Leading Edge Glow** (Components.lua:1799-1808) - Pulsing GLOW_BUTTON at progress front
- ✅ **Inner Bevel** (Components.lua:1678-1694) - Top shadow + bottom highlight for 3D depth effect

**Animation & Sound Integration:**
- ✅ **Segment Tracking** (Components.lua:AnimateProgress) - Tracks crossing 10% boundaries during animation
- ✅ **OnSegmentCrossed** (Components.lua:2028-2040) - Gold flash on divider + tick sound every 10%
- ✅ **OnMilestoneCrossed** (Components.lua:2043-2059) - Bell chime + burst effect at 25/50/75%
- ✅ **OnProgressComplete** (Components.lua:2062-2075) - Achievement sound + sparkles at 100%
- ✅ **Progress Sounds** (Sounds.lua) - Added `progress` category with tick, milestone, complete sounds

**Files Modified:**
- Components.lua (CreateReputationBar complete overhaul - texture, segments, diamonds, glow, bevel, callbacks)
- Sounds.lua (Added progress sound category and PlayProgressTick/PlayProgressMilestone/PlayProgressComplete)

**Design Pattern:**
```
[▓▓▓|▓▓▓|▓▓▓|▓▓▓|░░░|░░░|░░░|░░░|░░░|░░░]◆ [Honored]
     ↑   ↑   ↑   ↑
   10%  20%  30%  40% (current)

   ◆ = Diamond milestone markers at 25%/50%/75%
   | = Segment dividers every 10%
   ◆ = Leading edge glow (pulses at progress front)
```

### Phase 23: Remove Milestones Tab (2026-01-19)

**Goal:** Simplify journal UI by removing dedicated Milestones tab. Milestone entries still appear in Journey timeline.

**Changes:**
- ✅ **Tab Registration** (Journal.lua:728-737) - Removed milestones from tabData array
- ✅ **SelectTab Case** (Journal.lua:823-825) - Removed milestones case from tab selection switch
- ✅ **UI Code Cleanup** (Journal.lua) - Removed ~100 lines of Milestones-only code:
  - `MAJOR_MILESTONES` table
  - `CHRONICLE_ACTS` table (3-act structure)
  - `CreateMilestoneEntry()` function
  - `CreateActSection()` function
  - `PopulateMilestones()` function
- ✅ **Tab Migration** (Journal.lua:3761-3766) - Users with lastTab="milestones" now default to "journey"

**Preserved:**
- `Journal/Milestones.lua` module - Still tracks level-up events
- `CreateChronicleHeader()` - Still used by Journey tab for progress bar
- Milestone entries in Journey timeline
- Stats tab milestone counts
- Badge triggers on milestone completion

**Files Modified:**
- Journal.lua (tab removal, UI cleanup, migration fallback)
- CLAUDE.md (documentation updates)

### Phase 24: Remove Zones Tab (2026-01-19)

**Goal:** Simplify journal UI by removing the Zones tab entirely.

**Files Removed:**
- `Journal/Zones.lua` - Entire module deleted

**Files Modified:**
- **HopeAddon.toc** - Removed Zones.lua from load order
- **Journal.lua** - Removed:
  - Tab registration for "zones"
  - SelectTab case for zones
  - `PopulateZones()` function
  - `PopulateZones_placeholder()` function (dead code)
  - `OnZoneChanged()` event handler
  - `CountOutlandZonesExplored()` function
  - Zone-related stats cards in Stats tab
  - Zone references in GetCachedCounts(), footer
  - ZONE_CHANGED_NEW_AREA event registration
- **Core/Constants.lua** - Removed:
  - `C.ZONE_DISCOVERIES` table (~50 lines)
  - `C.OUTLAND_ZONES` list
- **Core/Core.lua** - Removed:
  - `zoneDiscoveries` from default charDb
  - Zone population in PopulateDemoData()
  - Zone clear in ClearDemoData()
  - Zone stats in PrintStats()
- **Social/Badges.lua** - Removed:
  - `through_portal` badge (zone-based unlock)
  - Zone unlock type handling in CheckUnlockCondition()
  - `OnZoneDiscovered()` callback
- **Social/TravelerIcons.lua** - Removed:
  - `OnZoneDiscovery()` function
  - `CheckZoneIcons()` function
  - `CheckAllZonesIcon()` function
  - `RecordZoneVisitedTogether()` function
  - `zonesVisitedTogether` from stats structures

**Impact:**
- Journal now has 7 tabs: Journey, Reputation, Raids, Attunements, Games, Social, Stats
- Existing `charDb.journal.zoneDiscoveries` data becomes orphaned (harmless)
- ~500 lines of code removed

### Phase 26: Games Tab Practice Mode (2026-01-19)

**Goal:** Fix Practice buttons so all applicable games work in solo/local mode.

**Issues Found:**
- Dice Roll: `Minigames:StartLocalDiceGame()` was called but didn't exist
- Death Roll: `Minigames:StartLocalDeathRoll()` was called but didn't exist
- Words with WoW: `hasLocal = false` despite having full local mode support

**Fixes Implemented:**

1. **Death Roll** - Wire to existing `DeathRollUI:QuickStartLocal()`
   - Changed Journal.lua to call `DeathRollUI:QuickStartLocal()` instead of non-existent function

2. **Words with WoW** - Enable local mode
   - Changed `hasLocal = false` → `true` in Constants.lua:3302
   - Added handler in Journal.lua to call `WordGame:StartGame(nil)`

3. **Dice Roll** - Implement local practice mode
   - Added `Minigames.localDiceGame` state table
   - Added `Minigames:StartLocalDiceGame()` - generates computer roll, shows UI
   - Added `Minigames:HandleLocalDiceGameRoll()` - compares rolls, shows result
   - Updated `Minigames:OnSystemMessage()` - checks for local game before multiplayer
   - Added `MinigamesUI:ShowLocalDiceGame()` - shows dice UI for practice mode
   - Updated `OnDiceRollClick()` - handles local game via `RandomRoll(1, 100)`

**Files Modified:**
- `Journal/Journal.lua` - Fixed StartLocalGame() handlers for deathroll, words
- `Core/Constants.lua` - Set hasLocal=true for words
- `Social/Minigames.lua` - Added StartLocalDiceGame(), HandleLocalDiceGameRoll(), updated OnSystemMessage()
- `Social/MinigamesUI.lua` - Added ShowLocalDiceGame(), updated OnDiceRollClick()

**Practice Mode Status (Final):**
| Game | Practice Button | Mode |
|------|-----------------|------|
| Dice Roll | ✅ Works | vs Computer (random roll) |
| RPS | ❌ Disabled | By design - requires 2 players |
| Death Roll | ✅ Works | vs Self (alternating rolls) |
| Pong | ✅ Works | 2-player local (W/S + Up/Down) |
| Tetris | ✅ Works | 2-player local with garbage |
| Words | ✅ Works | vs Self (alternating turns) |

### Phase 25: Separate Games and Social Tabs (2026-01-19)

**Goal:** Split the combined Directory tab into two focused tabs for better organization.

**Changes:**
- ✅ **New Games Tab** - Dedicated tab for minigames with Practice and Challenge buttons
  - `PopulateGames()` function (Journal.lua:2638)
  - Header: "GAMES HALL" with instructions text
  - 6 game cards in 3x2 grid layout
  - Practice button (green) - solo/local play
  - Challenge button (purple) - opens traveler picker
- ✅ **New Social Tab** - Renamed from Directory, Fellow Travelers only
  - `PopulateSocial()` function (Journal.lua:2730)
  - Header: "FELLOW TRAVELERS"
  - Stats summary (addon users, recent count)
  - Searchable player directory

**Files Modified:**
- Journal.lua:
  - Added "games" and "social" tabs to tabData (lines 775-776)
  - SelectTab routing for both tabs (lines 874-877)
  - Migration: "directory" → "social" (lines 858-861)
  - Removed old `PopulateDirectory()` function
  - Added `PopulateGames()` and `PopulateSocial()` functions

**User Flow:**
- Games Tab: Click Practice to play solo, Click Challenge to invite Fellow Traveler
- Social Tab: Browse Fellow Travelers, view profiles, challenge directly

### Previous Session Fixes

- ✅ **Card Pool Frame Type** (Journal.lua:149) - Changed `"Frame"` to `"Button"` to support OnClick scripts
- ✅ **Reputation Card Border Hover** (Journal.lua:1119) - Store standing color in `defaultBorderColor` so border returns to correct color after hover instead of grey
- ✅ **Section Header Components** (Components.lua:1809, Journal.lua:619) - Moved CreateSectionHeader and CreateCategoryHeader to Components.lua for reusability; Journal now delegates to Components
- ✅ **Spacer Component** (Components.lua:1867) - Added CreateSpacer helper to Components.lua for consistent vertical spacing
- ✅ **RaidData OnInitialize** (RaidData.lua:486) - Added missing OnInitialize stub for module pattern consistency

### Phase 14: Production Readiness (Memory Leaks & Error Resilience)

- ✅ **Module Lifecycle Protection** (Core.lua:499-508, 536-543) - Wrapped OnEnable/OnDisable calls in pcall to prevent one failing module from cascading
- ✅ **Combat Log Handler Protection** (Journal.lua:649-653, RaidData.lua:346-358) - Wrapped COMBAT_LOG_EVENT_UNFILTERED handlers in pcall for stability during raids
- ✅ **eventFrame Cleanup** (6 modules) - Added `self.eventFrame = nil` after UnregisterAllEvents to prevent memory leaks:
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

### Phase 30: Practice Mode Selection (AI vs 2-Player Local) (2026-01-19)

**Goal:** When clicking Practice on Tetris or Pong, show a popup to choose between "Play vs AI" and "2-Player Local" modes.

**Files Modified:**
- ✅ **MinigamesUI.lua** - Added practice mode selection popup
  - New constants: `PRACTICE_MODE_WIDTH`, `PRACTICE_MODE_HEIGHT`
  - New handlers: `OnPracticeModeAI()`, `OnPracticeModeLocal()`, `OnPracticeModeCancel()`, `OnPracticeModeKeyDown()`
  - New functions: `GetPracticeModePopup()`, `ShowPracticeModePopup(gameId, callback)`, `HidePracticeModePopup()`
  - Popup displays game name, two buttons (green "Play vs AI", purple "2-Player Local"), Cancel button

- ✅ **Journal.lua** - Modified practice button flow
  - `StartLocalGame()` - Now shows popup for tetris/pong instead of starting directly
  - `StartPracticeWithMode(gameId, mode)` - New function that starts game with selected mode
    - Tetris + "ai": Sets `isAIOpponent = true` in game state
    - Tetris + "local": Standard 2-player local mode
    - Pong + "ai": Uses SCORE_CHALLENGE mode (existing AI paddle)
    - Pong + "local": Uses LOCAL mode (both paddles human-controlled)

- ✅ **TetrisGame.lua** - Added AI opponent
  - `AI_SETTINGS` constants: think time (0.3-0.8s), move interval (0.05s), evaluation weights, 15% mistake chance
  - AI state in `CreateBoard()`: phase, timers, target position
  - `OnStart()` - Enables AI for board 2 when `isAIOpponent` flag is set
  - `UpdateBoard()` - Calls `UpdateAIBoard()` instead of `UpdateDASInput()` for AI board
  - `UpdateAIBoard(gameId, playerNum, dt)` - Three-phase AI: THINKING → MOVING → DROPPING
  - `EvaluateBestPlacement(board)` - Evaluates all rotations × columns (max 40 positions)
  - `FindLandingRow(grid, blocks, col)` - Simulates where piece lands
  - `EvaluateGrid(grid, linesCleared)` - Scores based on holes, height, bumpiness, line clears
  - `ResetAIState(board)` - Resets AI state for new piece
  - `SpawnPiece()` - Resets AI state when new piece spawns
  - `CreateBoardUI()` - Shows "AI" label (orange) instead of "Player 2" when AI enabled

**AI Design (60-70% player win rate):**
- 0.3-0.8 second thinking delay (visible hesitation)
- 15% chance to make suboptimal move (random column offset)
- No lookahead (evaluates current piece only)
- Simple evaluation (penalize holes, height, bumpiness; reward line clears)

**Practice Mode Status:**
| Game | "Play vs AI" | "2-Player Local" |
|------|-------------|------------------|
| Tetris | ✅ New AI opponent | ✅ Dual keyboard (WASD / Arrows) |
| Pong | ✅ Existing AI paddle | ✅ Dual keyboard (W/S / Up/Down) |
| Death Roll | N/A (single option) | vs Self (alternating) |
| Words | N/A (single option) | vs Self (alternating) |
| RPS | N/A (single option) | vs AI |
| Dice | N/A (single option) | vs Computer |

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
