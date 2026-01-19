# HopeAddon - Feature Status & Organization Guide

## Quick Reference for AI Assistants

This document tracks feature completion status to help AI assistants understand what's done and what needs work.

---

## Architecture Overview

```
HopeAddon/
├── Core/           # Foundation (FramePool, Constants, Timer, Core, Sounds, Effects)
├── UI/             # Reusable components (Components, Glow, Animations)
├── Journal/        # Main journal system (Journal, Pages, Milestones, Zones, ProfileEditor)
├── Raids/          # Raid tracking (RaidData, Attunements, Karazhan, Gruul, Magtheridon)
├── Reputation/     # Faction tracking (ReputationData, Reputation)
├── Social/         # Multiplayer features (Badges, FellowTravelers, TravelerIcons, Minigames, MapPins)
│   └── Games/      # Game system (GameCore, GameUI, GameComms, Tetris, DeathRoll, Pong, Words)
└── Tests/          # Test suite (WordGameTests, LoadOnDemand)
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

### 3. Boss Defeat Detection (Medium Priority)
**Files:** `Journal/Journal.lua`, `Raids/RaidData.lua`
**Issue:** UI and data structures complete, but actual boss kill detection needs verification
**Needed:** Verify `COMBAT_LOG_EVENT_UNFILTERED` properly detects raid boss kills

---

### 4. Settings Panel (Low Priority)
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
| `Core/FramePool.lua` | Generic object pooling | 5KB |
| `Core/Timer.lua` | TBC-compatible timer system | 3KB |
| `Core/Sounds.lua` | Sound effect playback | ~3KB |
| `Core/Effects.lua` | Visual effect utilities | ~3KB |

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
| `Social/FellowTravelers.lua` | Addon-to-addon communication | 33KB |
| `Social/Badges.lua` | Achievement definitions | 17KB |
| `Social/TravelerIcons.lua` | Icon rendering | 12KB |
| `Social/Minigames.lua` | Dice, RPS, Death Roll logic, protocol, stats | 42KB |
| `Social/MinigamesUI.lua` | Game selection popup, game boards, results | 41KB |
| `Social/MapPins.lua` | Minimap pins for Fellow Travelers | ~8KB |

### Game System
| File | Purpose | Size |
|------|---------|------|
| `Games/GameCore.lua` | Game loop, state machine, utilities | 14KB |
| `Games/GameUI.lua` | Shared UI components (windows, buttons) | 18KB |
| `Games/GameComms.lua` | Addon messaging for multiplayer | 16KB |
| `Games/Tetris/TetrisGame.lua` | Tetris battle logic and UI | 28KB |
| `Games/Tetris/TetrisBlocks.lua` | Tetromino definitions, rotation, SRS | 9KB |
| `Games/Tetris/TetrisGrid.lua` | 10x20 grid data structure | 10KB |
| `Games/DeathRoll/DeathRollGame.lua` | Death roll turn-based mechanics | 15KB |
| `Games/DeathRoll/DeathRollUI.lua` | Death roll gameplay UI | 11KB |
| `Games/DeathRoll/DeathRollEscrow.lua` | 3-player escrow for gambling | 16KB |
| `Games/Pong/PongGame.lua` | Pong physics and gameplay | 19KB |
| `Games/WordsWithWoW/WordBoard.lua` | Word game board mechanics | 14KB |
| `Games/WordsWithWoW/WordDictionary.lua` | WoW-themed word list | 13KB |
| `Games/WordsWithWoW/WordGame.lua` | Words with WoW main controller | 23KB |

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

**Test Coverage:**
- Dictionary validation (valid/invalid words, letter values, tile bag)
- Board placement rules (center, connectivity, bounds, conflicts)
- Scoring mechanics (bonus squares, multipliers, cross-words)
- Cross-word detection and validation
- Game flow (state management, turn switching, pass system)
- Network sync (manual test procedure for remote play)

**Running Tests:**
```
/run LoadAddOn("HopeAddon_Tests")  -- Load test addon
/wordtest all                       -- Run all tests
/wordtest dict                      -- Test dictionary only
/wordtest board                     -- Test board placement
/wordtest score                     -- Test scoring
/wordtest cross                     -- Test cross-words
/wordtest flow                      -- Test game flow
```

---

## Data Structures

### Character Data (`HopeAddonCharDB`)
```lua
{
    journal = {
        entries = {},           -- All journal entries
        levelMilestones = {},   -- [level] = entry
        zoneDiscoveries = {},   -- [zoneName] = entry
        bossKills = {},         -- [bossName] = entry
    },
    attunements = {
        karazhan = { started, completed, chapters = {} },
        ssc = { ... }, tk = { ... }, hyjal = { ... }, bt = { ... }
    },
    stats = {
        deaths = { total, byZone, byBoss },
        playtime, questsCompleted, creaturesSlain, largestHit,
        dungeonRuns = { [key] = { normal, heroic } }
    },
    travelers = {
        known = {               -- Detected addon users
            [name] = {
                stats = {
                    minigames = {
                        dice = { wins, losses, ties, highestRoll, lastPlayed },
                        rps = { wins, losses, ties, lastPlayed },
                    },
                },
            },
        },
        fellows = {},           -- Cached profiles
        myProfile = {},         -- Player's RP profile
        badges = {},            -- Unlocked badges
    },
    reputation = {
        milestones = {},        -- [faction][standing] = entry
        aldorScryerChoice = nil
    }
}
```

---

## Frame Pooling Patterns

The addon uses specialized frame pools for efficient UI management:

| Pool | Frame Type | Purpose | Location |
|------|------------|---------|----------|
| `notificationPool` | Frame + BackdropTemplate | Pop-up notifications | Journal.lua:70-100 |
| `containerPool` | Frame | Headers, spacers, sections | Journal.lua:102-130 |
| `cardPool` | Button + BackdropTemplate | Entry cards | Journal.lua:132-193 |
| `gameCardPool` | Button + BackdropTemplate | Games Hall game cards | Journal.lua:377-420 |
| `pinPool` | Table-based | Minimap Fellow Traveler pins | MapPins.lua:20 |

**Lifecycle Pattern:**
```
OnEnable → Create pools
SelectTab → ReleaseAll + ClearEntries
OnDisable → Destroy pools
```

**Acquire/Release Pattern:**
```lua
local card = self:AcquireCard(parent, data)
scrollContainer:AddEntry(card)
-- On tab switch:
scrollContainer:ClearEntries(pool)  -- Releases pooled frames
```

**Pool Methods:**
- `pool:Acquire()` - Get frame from pool (creates if needed)
- `pool:Release(frame)` - Return frame to pool
- `pool:ReleaseAll()` - Return all active frames
- `pool:GetNumActive()` - Count frames in use

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

Color categories from `Core/Core.lua`:

| Category | Colors |
|----------|--------|
| Outland | `FEL_GREEN`, `FEL_GLOW`, `OUTLAND_TEAL` |
| Hellfire | `HELLFIRE_RED`, `HELLFIRE_ORANGE`, `LAVA_ORANGE` |
| Arcane | `ARCANE_PURPLE`, `NETHER_LAVENDER`, `VOID_PURPLE` |
| Achievement | `GOLD_BRIGHT`, `GOLD_PALE`, `BRONZE` |
| Item Quality | `POOR`, `COMMON`, `UNCOMMON`, `RARE`, `EPIC`, `LEGENDARY` |
| UI | `PARCHMENT_BG`, `PARCHMENT_BORDER`, `TEXT_DARK`, `TEXT_LIGHT` |

**Color Usage:**
```lua
local color = HopeAddon.colors.GOLD_BRIGHT
fontString:SetTextColor(color.r, color.g, color.b)
-- Or with alpha:
texture:SetVertexColor(color.r, color.g, color.b, 0.8)
```

---

## Future Patterns (Planned)

Patterns for features in development:

### Settings Panel
Will use existing tab pattern + `CreateCollapsibleSection`:
```lua
-- Planned structure
self:CreateCollapsibleSection("Sound Settings", {
    { type = "checkbox", label = "Enable Sounds", key = "soundEnabled" },
    { type = "slider", label = "Volume", key = "soundVolume", min = 0, max = 1 },
})
```

### Boss Detection Verification
Verify `COMBAT_LOG_EVENT_UNFILTERED` patterns:
```lua
-- Expected event for boss kills:
-- UNIT_DIED with destGUID matching C.BOSS_NPC_IDS
```

### Milestone Modal
Will reuse notification pool styling with expanded content area.

### Attunement Icons
Requires addon communication protocol extension for comparing attunement completion timestamps between players.

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

#### Tetris Battle

**TetrisGrid** - 10x20 grid with piece placement validation, row clearing, and garbage system

**TetrisBlocks** - All 7 standard pieces (I, O, T, S, Z, J, L) with SRS rotation and 7-bag randomizer

**TetrisGame** - Battle system with:
- Side-by-side boards for local mode
- Garbage mechanic (cleared rows → opponent garbage)
- Level progression with increasing speed
- Full scoring (100/300/500/800 for 1/2/3/4 lines)
- Keyboard controls:
  - Player 1: A/D move, W rotate, S soft drop, Space hard drop
  - Player 2: Arrows, Up rotate, Down soft drop, Enter hard drop
- Remote multiplayer via GameComms

#### Death Roll

**DeathRollGame** - Turn-based gambling game:
- Players roll decreasing dice (100 → N → ... → 1)
- First player to roll 1 loses
- Uses real `/roll` chat command for verification

**DeathRollEscrow** - 3-player escrow system:
- Third player holds stakes during match
- Automatic payout on game completion
- Dispute resolution for disconnects
- Trust verification via addon communication

#### Pong

**PongGame** - Classic arcade game:
- Ball physics with angle reflection
- Paddle collision detection
- Score to 11 to win
- Controls:
  - Player 1: W/S keys
  - Player 2: Up/Down arrows
- Increasing ball speed over time

#### Words with WoW

**WordGame** - Turn-based word game controller:
- Scrabble-style gameplay with WoW vocabulary
- Slash command input: `/word DRAGON H 8 8`
- Text-based 15x15 board display
- Score tracking with bonus squares
- Cross-word validation and scoring
- Pass system (2 consecutive passes ends game)
- Remote multiplayer via GameComms

**WordBoard** - Board mechanics:
- 15x15 grid with bonus squares (double/triple letter/word)
- Word placement validation (connectivity, bounds, first word center)
- Cross-word detection and scoring
- Bonus multiplier calculations

**WordDictionary** - Vocabulary system:
- ~500 WoW-themed words (classes, zones, bosses, items, spells)
- Hash table for O(1) validation
- Standard Scrabble letter values
- Tile bag generation

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

## Recent Bug Fixes

- ✅ **Card Pool Frame Type** (Journal.lua:149) - Changed `"Frame"` to `"Button"` to support OnClick scripts
- ✅ **Reputation Card Border Hover** (Journal.lua:1119) - Store standing color in `defaultBorderColor` so border returns to correct color after hover instead of grey
- ✅ **Section Header Components** (Components.lua:1809, Journal.lua:619) - Moved CreateSectionHeader and CreateCategoryHeader to Components.lua for reusability; Journal now delegates to Components
- ✅ **Spacer Component** (Components.lua:1867) - Added CreateSpacer helper to Components.lua for consistent vertical spacing
- ✅ **RaidData OnInitialize** (RaidData.lua:486) - Added missing OnInitialize stub for module pattern consistency

### Phase 5: Pooling & Performance Optimizations

- ✅ **COMBAT_LOG Early Filter** (Journal.lua:2356) - Check subEvent with `select(2, ...)` BEFORE unpacking all values; reduces unnecessary work on 50,000+ events per raid session
- ✅ **Card Glow Tracking/Cleanup** (Journal.lua:198-209) - Added `_glowEffect` and `_sparkles` cleanup to card pool reset function; prevents memory leaks from orphaned glow effects
- ✅ **Timeline Entry Caching** (Journal.lua:674-685) - Cache sorted timeline entries; invalidated via `InvalidateCounts()` when entries change
- ✅ **Riding Skill Caching** (Journal.lua:2243-2259) - New `GetRidingSkill()` function with cache invalidation on `SKILL_LINES_CHANGED`; avoids O(n) linear search through 30-50 skills
- ✅ **Stats Batching** (Journal.lua:2149-2226) - New `GetCachedStatsData()` computes all counts in single pass; individual count functions now check cache first
- ✅ **Glow Parent Index** (Glow.lua:16, 30-55, 374-377, 415-428) - Added `glowsByParent` map for O(1) lookup when stopping glows by parent frame
- ✅ **Comprehensive OnDisable Cleanup** (Journal.lua:64-120) - Added cleanup for Effects, Glow registries, sparkles, and cached data
- ✅ **Boss Info Card Pool** (Journal.lua:341-386, 1676-1681) - New pool for raid metadata frames used in Raids tab

### Phase 6: Challenge Button Memory Leak Fixes

- ✅ **Card Pool challengeBtn/noteIcon Cleanup** (Journal.lua:255-268) - Added cleanup for challengeBtn (all 5 handlers + targetName) and noteIcon in card pool resetFunc; prevents closure memory leaks
- ✅ **OnClick Inside Creation Block** (Journal.lua:1920-1928) - Moved SetScript("OnClick") inside button creation block so handlers are set once, not on every render; eliminates N new closures per Directory tab render
- ✅ **OnCardClick Callback Cleanup** (Journal.lua:272) - Clear `card.OnCardClick` in resetFunc to prevent stale closure references from Milestones and Directory tabs

### Phase 7: Minigames Enhancements

- ✅ **GRES Result Validation** (Minigames.lua:962-1011) - Added `HandleResult()` function to validate incoming result messages match local calculation; warns on mismatch
- ✅ **Challenge Rate Limiting** (Minigames.lua:37, 70, 95, 234-246) - Added 30-second cooldown between challenges to same player; prevents spam
- ✅ **RPS Hash Enforcement** (Minigames.lua:40, 785-795) - Added `ENFORCE_HASH_INTEGRITY` option that cancels game if opponent's reveal doesn't match their commit hash; enabled by default

### Phase 5b: Remaining Performance Optimizations

- ✅ **SlideIn Animation Tracking** (Effects.lua:400-452) - Added `_slideAnimGroup` tracking to `SlideIn()` like `FadeIn()`/`FadeOut()` have; prevents animation stacking and memory leaks
- ✅ **PageFlip Timer Cleanup** (Animations.lua:206-270) - Clear `pageFlipTimers` array on animation completion; prevents timer handle references persisting after use
- ✅ **Centralized Raid Constants** (Constants.lua:2979-3011) - Added `C.RAID_TIERS`, `C.ALL_RAID_KEYS`, `C.ATTUNEMENT_RAID_KEYS`, `C.RAIDS_BY_TIER`, and `C:GetRaidTier()` helper function
- ✅ **Journal Raid List Deduplication** (Journal.lua:1593, 2277, 2297, 2378, 2422) - Replaced 5 duplicate raid list definitions with centralized Constants references
- ✅ **Milestones GetRaidTier** (Milestones.lua:375-377) - Replaced inline tier conditional with `Constants:GetRaidTier()` call

### Phase 8: Real /roll Detection for Dice Game

- ✅ **DICE_ROLL_PATTERN Constant** (Minigames.lua:42-44) - Added pattern to parse `CHAT_MSG_SYSTEM` roll messages: `"PlayerName rolls 42 (1-100)"`
- ✅ **Event Frame for Roll Detection** (Minigames.lua:78, 88-98, 111-114) - Created event frame in `OnEnable()`, registered `CHAT_MSG_SYSTEM`, cleanup in `OnDisable()`
- ✅ **OnSystemMessage Handler** (Minigames.lua:129-158) - Parses roll messages, validates 1-100 range, routes to local or opponent handlers
- ✅ **HandleLocalDiceRoll** (Minigames.lua:165-185) - Processes local player's roll from chat, sends to opponent via addon message, updates UI
- ✅ **HandleOpponentDiceRoll** (Minigames.lua:191-198) - Stores opponent's chat-detected roll for verification against addon message
- ✅ **MakeDiceMove Refactor** (Minigames.lua:622-640) - Replaced `math.random()` with `RandomRoll(1, 100)`, added `rollRequested` state tracking
- ✅ **Roll Verification** (Minigames.lua:670-675) - Verifies opponent's addon message roll against chat-detected roll; trusts chat if mismatch
- ✅ **OnRollRequested UI Function** (MinigamesUI.lua:847-853) - Updates button to show "Rolling..." state while waiting for chat result
- ✅ **Dice Label Centering** (MinigamesUI.lua:508, 543) - Changed player/opponent labels from TOP anchor to CENTER-based positioning
- ✅ **RPS Button Row Centering** (MinigamesUI.lua:605) - Removed arbitrary Y offset from button row positioning
- ✅ **Status Text Enhancement** (MinigamesUI.lua:791) - Added "Click to /roll" hint to dice game status text

### Phase 9: Pong Game Resource Management Fixes

- ✅ **Countdown Timer Leak** (PongGame.lua:234-278) - Store countdown timer in `game.data.countdownTimer` for cancellation; re-fetch game each tick to avoid stale closure references; cancel timer in CleanupGame
- ✅ **Nil Check Chaining** (PongGame.lua:160-174) - Split nil check in OnUpdate to prevent accessing `game.data` when game is nil
- ✅ **GameCore Validation** (PongGame.lua:326, 348) - Added nil checks for GameCore in UpdateLocalPaddle and UpdateLocalPaddles before calling GameCore methods
- ✅ **Window Reference Storage** (PongGame.lua:620) - Store window reference in `game.data.window` for proper cleanup
- ✅ **Comprehensive UI Cleanup** (PongGame.lua:800-860) - Release all frame references (paddle1Frame, paddle2Frame, ballFrame, playArea, window) with Hide + SetParent(nil); clear text references; cancel countdown timer

### Phase 10: Minigames UI & Slash Command Improvements

- ✅ **Directory Tab Custom Color** (Components.lua:237-314, Journal.lua:640) - Added `customColor` parameter to `CreateTabButton()` for per-tab color theming; Directory tab now uses `ARCANE_PURPLE` to visually distinguish social/games features
- ✅ **Tab Highlight Color** (Components.lua:254-263) - Hover highlight now uses custom color when provided instead of default gold
- ✅ **Selected Indicator Color** (Components.lua:298-307) - Selected state indicator bar now uses custom color when provided
- ✅ **Death Roll Slash Command** (Core.lua:710-731) - Added `/hope deathroll [player]` command supporting both local and remote play
- ✅ **Words Slash Command** (Core.lua:732-747) - Added `/hope words <player>` command for remote play with helpful usage message
- ✅ **Help Text Update** (Core.lua:786-787) - Updated help output to include new deathroll and words commands

### Phase 11: Death Roll Resource Management Fixes

- ✅ **CleanupGame Function Added** (DeathRollGame.lua:217-254) - Created comprehensive cleanup function with window, text references, and escrow cleanup following Tetris/Pong patterns
- ✅ **OnDestroy Refactor** (DeathRollGame.lua:209-211) - Updated OnDestroy to call CleanupGame for proper resource cleanup
- ✅ **FontString Cleanup** (DeathRollGame.lua:243-247) - Clear maxValueText, turnText, historyText, proximityText references to prevent memory leaks
- ✅ **Escrow Cleanup on Destroy** (DeathRollGame.lua:226-231) - Call Escrow:CancelEscrow when game destroyed with active bet
- ✅ **Nil Check Guards** (DeathRollGame.lua:169) - Added game.data nil check in OnEnd to prevent accessing nil data
- ✅ **GameUI Window Destruction** (DeathRollGame.lua:250-252) - Call GameUI:DestroyGameWindow to unregister window from GameUI registry
- ✅ **Escrow Timer Management** (DeathRollEscrow.lua:362) - Store cleanup timer handle in session.cleanupTimer for cancellation
- ✅ **CancelEscrow Function** (DeathRollEscrow.lua:436-451) - Added CancelEscrow function to cancel escrow sessions and cleanup timers
- ✅ **FindSessionByGameId Helper** (DeathRollEscrow.lua:453-461) - Added helper function to find session by game ID
- ✅ **Function Call Bug Fix** (DeathRollUI.lua:233-241) - Fixed InitiateEscrow → InitiateAsHouse with correct parameters (gameId, betAmount, player1, player2)

### Phase 12: Games Hall UI Enhancement

- ✅ **GAME_DEFINITIONS Constant** (Constants.lua:3018-3090) - Added centralized game definitions with id, name, description, icon, hasLocal, hasRemote, system, color properties
- ✅ **CreateGameCard Component** (Components.lua:2049-2274) - New storybook-style game card component with icon, title, description, stats row, Practice and Challenge buttons
- ✅ **gameCardPool** (Journal.lua:377-420) - New frame pool for game cards with proper reset function to prevent memory leaks
- ✅ **AcquireGameCard** (Journal.lua:430-441) - Pool acquisition function for game cards
- ✅ **PopulateDirectory Refactor** (Journal.lua:1817-1954) - Added collapsible "GAMES HALL" section at top of Directory tab with 3x2 game card grid
- ✅ **GetGameStats** (Journal.lua:1961-1982) - Aggregate win/loss/tie stats across all travelers for a game
- ✅ **StartLocalGame** (Journal.lua:1988-2016) - Handler for Practice button to start local games (dice, deathroll, pong, tetris)
- ✅ **ShowTravelerPickerForGame** (MinigamesUI.lua:1527-1609) - New popup for selecting Fellow Traveler to challenge from Games Hall
- ✅ **GetTravelerPickerPopup** (MinigamesUI.lua:1377-1463) - Creates traveler picker popup with scroll frame
- ✅ **GetTravelerButton** (MinigamesUI.lua:1471-1521) - Reusable traveler selection buttons for picker

### Phase 13: Words with WoW Test Suite

- ✅ **WordGameTests.lua** (Tests/WordGameTests.lua) - Comprehensive automated test suite for Words with WoW game system
- ✅ **Dictionary Tests** - Validate word validation, letter values, tile bag generation, case insensitivity
- ✅ **Board Placement Tests** - Test center rule, connectivity, bounds checking, conflict detection
- ✅ **Scoring Tests** - Verify bonus squares (DW, TW, DL, TL), multiplier calculations, cross-word scoring
- ✅ **Cross-Word Tests** - Test cross-word detection, validation, GetHorizontalWord/GetVerticalWord
- ✅ **Game Flow Tests** - Test state management, turn switching, pass system, game completion
- ✅ **Test Infrastructure** - Assert/AssertEquals utilities, test counters, summary reports
- ✅ **Slash Commands** - `/wordtest all`, `/wordtest dict`, `/wordtest board`, `/wordtest score`, `/wordtest cross`, `/wordtest flow`
- ✅ **Test Documentation** (Tests/README.md) - Complete test coverage documentation, manual test procedures, troubleshooting guide
- ✅ **Separate Test Addon** (HopeAddon_Tests.toc) - LoadOnDemand test addon that doesn't load by default in production
- ✅ **50+ Test Cases** - Comprehensive coverage of all Words with WoW functionality
- ✅ **Manual Network Test Procedure** - Step-by-step guide for testing remote multiplayer with 2 clients

---

## Development Priorities

1. **High:** Verify boss kill detection is working
2. **Medium:** Implement CheckAttunementIcons for social feature
3. **Low:** Add milestone detail modal
4. **Low:** Create dedicated settings panel

---

## Documentation Maintenance

This document should be treated as **living documentation**. Keep it updated as the codebase evolves.

### When to Update

| Event | Action |
|-------|--------|
| Feature completed | Move from "Known Incomplete Items" → "Feature Status Summary" with ✅ |
| Bug fixed | Add entry to "Recent Bug Fixes" with `file:line` reference |
| New issue discovered | Add to "Known Incomplete Items" with file paths and code snippets |
| New file created | Add to appropriate "File Quick Reference" table |
| Major refactor | Update "Architecture Overview" tree and file references |
| Data schema changed | Update "Data Structures" section |
| Priority completed | Update "Development Priorities" list |

### Entry Format Examples

**Feature Status:**
```
| Feature Name | ✅ COMPLETE | Brief description of functionality |
```

**Known Incomplete Item:**
```
### N. Feature Name (Priority)
**File:** `Path/File.lua:line`
**Issue:** Description of current state
**Needed:** What needs to be implemented
```

**Bug Fix:**
```
- ✅ **Short Description** (File.lua:line) - What was changed
```

### Verification Checklist

Before committing CLAUDE.md changes, verify:
- [ ] Feature status accurately reflects current implementation
- [ ] Known incomplete items have file:line references where applicable
- [ ] Development priorities are current and ordered correctly
- [ ] No stale/outdated information remains
- [ ] File sizes are approximate but reasonable
