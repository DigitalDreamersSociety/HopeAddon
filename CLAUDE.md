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

**Social/Games/GAME_UI_PATTERNS.md** - Minigame UI standards
- Window sizing, layout patterns, data structures
- For: Creating or modifying minigames

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
| Journal UI | ✅ COMPLETE | 7 tabs: Journey, Reputation, Raids, Attunements, Games, Social, Armory |
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
| Words with WoW | ✅ COMPLETE | Scrabble-style word game with WoW vocabulary, AI opponent, save/resume, async multiplayer |
| Battleship | ✅ COMPLETE | Classic naval battle with text commands, local AI & multiplayer modes |
| Game Chat | ✅ COMPLETE | Reusable /gc chat system for in-game communication |
| Games Hall UI | ✅ COMPLETE | Dedicated Games tab with Practice/Challenge options |
| Test Suite | ✅ COMPLETE | Comprehensive automated tests for Words with WoW |
| Activity Feed | ✅ COMPLETE | "Tavern Notice Board" - real-time updates, hybrid refresh, listener system, network sync |
| Rumors | ✅ COMPLETE | Manual status posts with 5-min cooldown, 100 char limit |
| Mug Reactions | ✅ COMPLETE | "Raise a Mug" (like) reactions on activities |
| Companions | ✅ COMPLETE | Favorites list with request/accept/decline flow, online status |
| Social Toasts | ✅ COMPLETE | Non-intrusive notifications for social events |
| Leveling Gear Guide | ✅ COMPLETE | Level 60-67 gear recommendations by role (dungeons + quests) |
| Romance System | ✅ COMPLETE | "Azeroth Relationship Status" - one exclusive partner, public status, breakup timeline events |
| Armory Tab | ✅ COMPLETE | Phase-based gear upgrade advisor - Phase 1 data populated, Phase 2/3/5 placeholders |

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
| `Core/Core.lua` | Main init, utilities, slash commands | ~73KB |
| `Core/Constants.lua` | All static data (milestones, raids, badges, loot) | ~240KB |
| `Core/Effects.lua` | Visual effect utilities | ~20KB |
| `Core/FramePool.lua` | Generic object pooling | 5KB |
| `Core/Sounds.lua` | Sound effect playback | ~8KB |
| `Core/Timer.lua` | TBC-compatible timer system | ~8KB |

### Journal System
| File | Purpose | Size |
|------|---------|------|
| `Journal/Journal.lua` | Main UI, tabs, event tracking | ~231KB |
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
| `Social/Badges.lua` | Achievement definitions | ~25KB |
| `Social/Directory.lua` | Searchable player directory | ~11KB |
| `Social/FellowTravelers.lua` | Addon-to-addon communication | ~44KB |
| `Social/ActivityFeed.lua` | Activity feed (Notice Board) for social tab | ~15KB |
| `Social/MapPins.lua` | Minimap pins for Fellow Travelers | ~10KB |
| `Social/Minigames.lua` | Dice, RPS, Death Roll logic, protocol, stats | ~39KB |
| `Social/MinigamesUI.lua` | Game selection popup, game boards, results | ~68KB |
| `Social/NameplateColors.lua` | Fellow Traveler nameplate coloring | ~6KB |
| `Social/Relationships.lua` | Player notes system | ~8KB |
| `Social/TravelerIcons.lua` | Icon rendering | 12KB |
| `Social/ActivityFeed.lua` | Activity feed with rumors & mugs | ~18KB |
| `Social/Companions.lua` | Favorites list with online status | ~10KB |
| `Social/SocialToasts.lua` | Toast notifications for social events | ~6KB |
| `Social/Romance.lua` | Romance/relationship system with propose/accept/breakup flow | ~15KB |

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

<details>
<summary>ActivityFeed Module Details - click to expand</summary>

- "Tavern Notice Board" - Activity feed for social events
- Activity types: STATUS, BOSS, LEVEL, GAME, BADGE, RUMOR, MUG, LOOT, ROMANCE, IC_POST, ANON
- Wire protocol: `ACT:version:type:player:class:data:time` (~20-50 bytes)
- Limits: 50 max entries, 48-hour retention
- Broadcast interval: 30 seconds via `broadcastTicker`

**Network Architecture:**
```
Outgoing: QueueForBroadcast() → BroadcastActivities() → FellowTravelers:BroadcastMessage()
                                       ↓
                              SerializeActivity() → "ACT:1:BOSS:Player:CLASS:data:time"
                                       ↓
                              AddToFeed() (own copy) + NotifyListeners()

Incoming: CHAT_MSG_ADDON → FellowTravelers:OnAddonMessage()
                                       ↓
                              strsplit(":", message, 3) → msgType, version, data
                                       ↓
                              Callback match(msgType=="ACT") → handler(msgType, sender, data)
                                       ↓
                              ActivityFeed:HandleNetworkActivity(sender, data)
                                       ↓
                              Parse data directly → AddToFeed() → NotifyListeners()
```

**Listener System** (for real-time UI updates):
  - `RegisterListener(id, callback)` - Register to receive activity notifications
  - `UnregisterListener(id)` - Remove listener
  - `NotifyListeners(count)` - Internal: calls all registered listeners
- Key functions:
  - `PostRumor(text)` - Post manual status (5-min cooldown, 100 char max)
  - `CanPostRumor()` - Check cooldown status
  - `GiveMug(activityId)` - React to an activity
  - `HasMugged(activityId)` - Check if already mugged
  - `GetFeed()` / `GetRecentFeed(max)` - Get activities
  - `FormatActivity(activity)` - Get display string
  - `GetRelativeTime(timestamp)` - "2m", "1h", "3d" format
  - `OnRomanceEvent(eventType, partnerName, reason)` - Called by Romance module
- Stores: `charDb.social.feed`, `charDb.social.mugsGiven`, `charDb.social.myRumors`
</details>

<details>
<summary>Companions Module Details - click to expand</summary>

- Favorites list with request/accept/decline flow
- 50 max companions, 24h request expiry
- Online status based on FellowTravelers lastSeenTime (5-min threshold)
- Key functions:
  - `SendRequest(playerName)` - Send companion request
  - `AcceptRequest(playerName)` - Accept incoming request
  - `DeclineRequest(playerName)` - Decline request
  - `RemoveCompanion(playerName)` - Remove from list
  - `IsCompanion(playerName)` - Check status
  - `GetAllCompanions()` - Get all with online status
  - `GetIncomingRequests()` - Get pending requests
  - `GetOnlineCount()` / `GetCount()` - Statistics
- Network: COMP_REQ, COMP_ACC, COMP_DEC message types via FellowTravelers
- Stores: `charDb.social.companions.list`, `.outgoing`, `.incoming`
</details>

<details>
<summary>SocialToasts Module Details - click to expand</summary>

- Non-intrusive slide-in notifications from top right
- 5 second auto-dismiss, max 3 toasts stacked
- Toast types: companion_online, companion_nearby, companion_request, mug_received, companion_lfrp, fellow_discovered
- Key functions:
  - `Show(toastType, playerName, customMessage)` - Display toast
  - `DismissToast(frame)` - Manually dismiss
  - `DismissAll()` - Clear all toasts
- Uses frame pool for performance
- Settings: `charDb.social.toasts` (per-type toggles)
</details>

<details>
<summary>Romance Module Details - click to expand</summary>

- "Azeroth Relationship Status" - Facebook-style dating for WoW RP
- One exclusive partner at a time (monogamous)
- States: SINGLE → PROPOSED (pending) → DATING (accepted)
- 24-hour rejection cooldown, 7-day proposal expiry
- Key functions:
  - `ProposeToPlayer(playerName)` - Send proposal
  - `AcceptProposal(senderName)` - Accept incoming proposal
  - `DeclineProposal(senderName)` - Decline incoming proposal
  - `BreakUp(reason)` - End relationship
  - `CancelProposal()` - Cancel outgoing proposal
  - `GetStatus()` - Get current relationship status
  - `IsPartner(playerName)` - Check if player is current partner
  - `HasPendingProposal()` - Check for outgoing proposal
  - `GetPendingIncoming()` - Get array of incoming proposals
- Network: ROM_REQ, ROM_ACC, ROM_DEC, ROM_BRK message types via FellowTravelers WHISPER
- Stores: `charDb.social.romance` (status, partner, since, pendingOutgoing, pendingIncoming, cooldowns, history)
- Broadcasts breakups to ActivityFeed for timeline drama
</details>

### Game System
| File | Purpose | Size |
|------|---------|------|
| `Social/Games/GameCore.lua` | Game loop, state machine, utilities | ~12KB |
| `Social/Games/GameUI.lua` | Shared UI components (windows, buttons) | ~21KB |
| `Social/Games/GameComms.lua` | Addon messaging for multiplayer | ~19KB |
| `Social/Games/GameChat.lua` | Reusable in-game chat for all multiplayer games | ~8KB |
| `Social/Games/ScoreChallenge.lua` | Score-based challenges (Tetris/Pong vs remote) | ~24KB |
| `Social/Games/Battleship/BattleshipGame.lua` | Battleship main controller with multiplayer | ~50KB |
| `Social/Games/Battleship/BattleshipUI.lua` | Gameshow-style visual effects for Battleship | ~23KB |
| `Social/Games/Battleship/BattleshipBoard.lua` | 10x10 grid, ship placement, shot logic | ~11KB |
| `Social/Games/Battleship/BattleshipAI.lua` | Hunt/Target AI algorithm | ~10KB |
| `Social/Games/Tetris/TetrisGame.lua` | Tetris battle logic and UI | ~64KB |
| `Social/Games/Tetris/TetrisBlocks.lua` | Tetromino definitions, rotation, SRS | ~8KB |
| `Social/Games/Tetris/TetrisGrid.lua` | 10x20 grid data structure | 10KB |
| `Social/Games/DeathRoll/DeathRollGame.lua` | Death roll turn-based mechanics | ~22KB |
| `Social/Games/DeathRoll/DeathRollUI.lua` | Death roll gameplay UI | ~31KB |
| `Social/Games/DeathRoll/DeathRollEscrow.lua` | 3-player escrow for gambling | ~18KB |
| `Social/Games/Pong/PongGame.lua` | Pong physics and gameplay | ~35KB |
| `Social/Games/WordsWithWoW/WordBoard.lua` | Word game board mechanics | ~13KB |
| `Social/Games/WordsWithWoW/WordDictionary.lua` | WoW-themed word list | ~11KB |
| `Social/Games/WordsWithWoW/WordGame.lua` | Words with WoW main controller | ~123KB |
| `Social/Games/WordsWithWoW/WordGamePersistence.lua` | Game save/load, serialization | ~15KB |
| `Social/Games/WordsWithWoW/WordGameInvites.lua` | Async multiplayer invite system | ~18KB |

### UI Framework
| File | Purpose | Size |
|------|---------|------|
| `UI/Components.lua` | All reusable UI components | ~103KB |
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
**Phase 3:** Journal System (Journal, Pages, Milestones, ProfileEditor)
**Phase 4:** Raid & Reputation (RaidData, Attunements, Reputation)
**Phase 5:** Social Features (Badges, FellowTravelers, Directory, Relationships, Minigames, MapPins)
**Phase 6:** Game System (GameCore, GameUI, GameComms, game implementations)

### Key Module Relationships

| Module | Depends On | Called By |
|--------|------------|-----------|
| **Badges** | Constants | Milestones, RaidData, Attunements, Reputation |
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
- `savedGames.words` - Persistent Words with WoW game states

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
    savedGames = {
        words = {
            games = {},             -- [opponentName] = serialized game state
            pendingInvites = {},    -- [senderName] = { state, timestamp }
            sentInvites = {},       -- [recipientName] = { state, timestamp }
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
        hideUIDuringCombat = true,
    },
    minimapButton = {
        position = 225,  -- Angle in degrees
        enabled = true,
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

## Social Tab Architecture

The Social tab uses a sub-tabbed interface with three tabs: Feed, Travelers, and Companions.

### Container Structure

```lua
Journal.socialContainers = {
    statusBar = nil,      -- Top status bar with profile info
    tabBar = nil,         -- Sub-tab buttons (Feed, Travelers, Companions)
    content = nil,        -- Main content area (cleared on tab/filter switch)
    scrollFrame = nil,    -- Scroll frame wrapper
}

Journal.socialSubTabs = {
    feed = nil,           -- Activity feed tab button
    travelers = nil,      -- Fellow Travelers directory tab button
    companions = nil,     -- Companions list tab button
}

Journal.quickFilterButtons = {}      -- Filter buttons for Travelers tab (all, online, party, lfrp)
Journal.socialContentRegions = {}    -- FontStrings/Textures for manual cleanup
```

**Note:** `filterBar` is preserved across filter changes but cleared when switching sub-tabs.

### Content Clearing (CRITICAL)

**Before repopulating any social content, you MUST call `ClearSocialContent()`**

```lua
function Journal:ClearSocialContent(preserveFilterBar)
    -- Clears all child frames from content container
    -- Clears all tracked regions (FontStrings, Textures)
    -- Prevents frame stacking when switching filters/tabs
    -- If preserveFilterBar=true, keeps the Travelers filter bar
end
```

**When to preserve filter bar:**
- `ClearSocialContent(true)` - When refreshing Travelers list (filter change only)
- `ClearSocialContent()` - When switching sub-tabs (clears everything)

### Populate Functions

| Function | Purpose | Triggers |
|----------|---------|----------|
| `PopulateSocialFeed()` | Activity feed with rumors, mugs | Feed tab select, refresh |
| `PopulateSocialTravelers()` | Fellow Traveler directory with filters | Travelers tab select, filter change |
| `PopulateSocialCompanions()` | Companions list with requests | Companions tab select, accept/decline |

### Filter System (Travelers Tab)

State stored in `HopeAddon:GetSocialUI().travelers`:
```lua
{
    quickFilter = "all",     -- "all", "online", "party", "lfrp"
    searchText = "",         -- Search box text
    sortOption = "last_seen" -- Sort order
}
```

**Filter Functions:**
```lua
Journal:GetFilteredTravelerEntries(filterId)  -- Returns filtered array
Journal:GetFilterCount(filterId)              -- Returns count for button label
Journal:SetQuickFilter(filterId)              -- Sets filter and refreshes
Journal:RefreshTravelersList()                -- Clears + repopulates
```

### Refresh Flow

```
User clicks filter → SetQuickFilter(filterId)
                          │
                          ├─ Update socialUI.travelers.quickFilter
                          ├─ Update button visuals (on preserved buttons)
                          └─ RefreshTravelersList()
                                    │
                                    ├─ ClearSocialContent(true)  ← preserves filter bar
                                    └─ PopulateSocialTravelers()
                                              │
                                              ├─ GetFilteredTravelerEntries(filter)
                                              ├─ Reuse existing filterBar OR create new
                                              ├─ UpdateQuickFilterCounts() (if reusing)
                                              └─ CreateTravelerRow() for each entry
```

### Region Tracking

FontStrings and Textures are NOT returned by `frame:GetChildren()`, so they must be tracked manually:

```lua
-- When creating a FontString/Texture on social content:
local text = content:CreateFontString(nil, "OVERLAY")
self:TrackSocialRegion(text)  -- Adds to socialContentRegions for cleanup
```

---

## Constants & Enumerates Reference

Key constant categories in `Core/Constants.lua`:

| Category | Constant | Key Structure |
|----------|----------|---------------|
| Milestones | `C.LEVEL_MILESTONES` | `[level] = { title, icon, story }` |
| Attunements | `C.[RAID]_ATTUNEMENT` | `{ chapters = { ... }, questIds = { ... } }` |
| Bosses | `C.[RAID]_BOSSES` | `{ id, name, location, lore, mechanics, loot }` |
| Boss Badges | `C.BOSS_BADGES` | `{ id, name, icon, trigger, ... }` |
| Boss Tiers | `C.BOSS_TIER_THRESHOLDS` | `{ min, quality, color }` (kill count tiers) |
| Icons | `C.TRAVELER_ICONS` | `{ id, name, icon, quality, category, trigger }` |
| Deaths | `C.DEATH_TITLES` | `{ min, max, title, color }` |
| Raid Tiers | `C.RAID_TIERS` | `[raidKey] = "T4"/"T5"/"T6"` |
| Raid Lists | `C.ALL_RAID_KEYS` | `{ "karazhan", "gruul", ... }` |
| Raid Lists | `C.ATTUNEMENT_RAID_KEYS` | `{ "karazhan", "ssc", ... }` (no Gruul/Mag) |
| Raid Lists | `C.RAIDS_BY_TIER` | `{ T4 = {...}, T5 = {...}, T6 = {...} }` |
| Games | `C.GAME_DEFINITIONS` | `{ id, name, description, icon, hasLocal, hasRemote, system, color }` |
| Words UI | `C.WORDS_*` | Bonus colors, tile settings, AI settings, online thresholds |
| Loot | `C.CLASS_SPEC_LOOT_HOTLIST` | `[class][specTab] = { rep, drops, crafted }` |
| Leveling | `C.LEVELING_GEAR_MATRIX` | `[role][level_range] = { dungeons, quests }` |

**Lookup Tables:**
```lua
C.ATTUNEMENT_QUEST_LOOKUP[questId]  -- → { raid, chapter }
C.ENCOUNTER_TO_BOSS[encounterId]    -- → { raid, boss }
C.BOSS_NPC_IDS[npcId]               -- → { raid, boss }
C.BOSS_BADGE_BY_ID[bossId]          -- → badge definition
C:GetRaidTier(raidKey)              -- → "T4"/"T5"/"T6" or nil
C:GetGameDefinition(gameId)         -- → { id, name, description, ... }
C:GetLevelRangeKey(level)           -- → "60-62"/"63-65"/"66-67" or nil
C:GetLevelingGear(role, level)      -- → { dungeons, quests }
C:GetRecommendedDungeons(level)     -- → dungeon list for level range
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

-- Pulsing Glow (persistent until manually stopped)
-- Use for "victory box" or "active selection" effects
local glowData = Effects:CreatePulsingGlow(frame, colorName, intensity)
-- colorName: "FEL_GREEN", "GOLD_BRIGHT", "ARCANE_PURPLE", "HELLFIRE_RED", etc.
-- intensity: 0.3-1.0 (default 1.0), controls glow brightness
-- Returns glowData table for manual cleanup later

-- To stop the glow:
Effects:StopGlowsOnParent(frame)            -- Stops ALL glows on a frame

-- Example: Persistent victory glow
frame.myGlow = Effects:CreatePulsingGlow(frame, "FEL_GREEN", 0.7)
-- Later, when done:
Effects:StopGlowsOnParent(frame)
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

For complete game implementation documentation including core loops, state machines, AI algorithms, network protocols, and detailed pseudocode, see **[GAME_SYSTEM_DOCS.md](GAME_SYSTEM_DOCS.md)**.

**Quick Reference:**
- **GameCore** - 60 FPS game loop, state machine (IDLE→WAITING→PLAYING→PAUSED→ENDED)
- **GameUI** - Shared UI framework (windows, buttons, overlays)
- **GameComms** - Addon messaging protocol for multiplayer
- **ScoreChallenge** - Turn-based score comparison for Tetris/Pong

**Game Implementations:**
| Game | Local Mode | Remote Mode |
|------|------------|-------------|
| Tetris | 2P side-by-side + AI | Score Challenge |
| Pong | 2P keyboard + AI | Score Challenge |
| Death Roll | vs Self | Real-time turns |
| Words with WoW | vs AI | Async multiplayer |
| Battleship | vs AI | True multiplayer |




---

## Testing Commands

```
/hope (or /journal)            - Open journal
/hope debug                    - Toggle debug mode
/hope stats                    - Show stats in chat
/hope sound                    - Toggle sounds
/hope combathide               - Toggle auto-hide UI during combat
/hope minimap                  - Toggle minimap button visibility
/hope nameplates               - Toggle Fellow nameplate coloring (IC=green, OOC=blue, LF_RP=pink)
/hope pins                     - Toggle minimap pin RP status coloring
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
/gc (or /gamechat) <message>   - Send chat to opponent in any game
/hope challenge <player> [game] - Challenge via game selection popup
/hope accept                   - Accept pending challenge
/hope decline                  - Decline pending challenge
/hope cancel                   - Cancel current game
```

---

## Recent Changes

See [CHANGELOG.md](CHANGELOG.md) for complete change history (Phases 5-60).

---

## Development Priorities

### Armory Tab - ✅ RESTRUCTURED (Phase 58)
**Status:** Complete - Phase-based system implemented

The Armory Tab now uses a Phase-based system (not Tier-based):
- **Phase 1:** Karazhan, Gruul, Magtheridon, Heroics, Badge Gear, Reputation - DATA POPULATED
- **Phase 2:** Serpentshrine Cavern, Tempest Keep - placeholder
- **Phase 3:** Hyjal Summit, Black Temple - placeholder
- **Phase 4:** ZA (skipped - catch-up raid)
- **Phase 5:** Sunwell Plateau - placeholder

**Key Changes:**
- `ARMORY_TIERS` renamed to `ARMORY_PHASES`
- Database keys changed from `[4]`, `[5]`, `[6]` to `[1]`, `[2]`, `[3]`, `[5]`
- Removed `tier = phase + 3` conversion hack in `GetArmoryGearData()`
- Phase 4 button hidden in UI
- "No data for Phase X yet" message when selecting unpopulated phases

**Future Work:** Populate Phase 2, 3, 5 gear data when needed

### Other Priorities
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
