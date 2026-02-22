# HopeAddon - AI Development Guide

Quick reference for AI assistants. **This addon is built entirely by AI.** Documentation accuracy is critical for session continuity.

---

## Quick Start

**Module Pattern:** All modules register via `HopeAddon:RegisterModule("Name", Module)` and implement `OnInitialize()`, `OnEnable()`, `OnDisable()`

**Data Storage:**
- Character data: `HopeAddon.charDb` (alias for `HopeAddonCharDB`)
- Account data: `HopeAddon.db`

**Frame Pooling:** UI elements use pools to prevent memory leaks. Always release frames in `OnDisable()`

**Cross-Module Calls:** Use `HopeAddon.ModuleName:Function()` pattern (e.g., `HopeAddon.Badges:OnPlayerLevelUp(level)`)

**Common Tasks:**
- Add new journal entry type -> `Journal/Journal.lua` + update `Constants.lua`
- Add new badge -> `Core/Constants.lua` (BADGES table) + trigger in relevant module
- Add new game -> Create in `Social/Games/`, register with `GameCore`, add to `C.GAME_DEFINITIONS`
- Track player interaction -> `Social/FellowTravelers.lua` handles addon communication

---

## Documentation Map

| Document | Purpose | Use For |
|----------|---------|---------|
| **CLAUDE.md** (this) | AI quick reference | Making code changes, understanding dependencies |
| **MODULE_API_REFERENCE.md** | Full module APIs, data schemas | Module integration, data structures |
| **UI_ORGANIZATION_GUIDE.md** | UI specs, colors, components, pooling | UI work, styling, layout decisions |
| **GAME_SYSTEM_DOCS.md** | Game loops, state machines, algorithms | Building or debugging minigames |
| **CHANGELOG.md** | Historical bug fixes (Phases 5-71) | Learning what's been tried |
| **docs/GAME_UI_PATTERNS.md** | Minigame UI standards | Creating or modifying minigames |
| **docs/BOSS_RECAP_DOCS.md** | Boss kill recap system spec | Boss breakdown UI, encounter tracking |
| **docs/PACWOW_COMPONENTS.md** | PacMan game reference | PacMan game mechanics, ghost AI, maps |

---

## Architecture

```
HopeAddon/
+-- Core/           # Foundation (FramePool, Constants, ArmoryBisData, Timer, Core, Sounds, Effects)
+-- UI/             # Reusable components (Components, Glow, Animations, MinimapButton)
+-- Journal/        # Main journal system (Journal, Pages, Milestones, ProfileEditor)
+-- Raids/          # Raid tracking (RaidData, Attunements, Karazhan, Gruul, Magtheridon)
+-- Reputation/     # Faction tracking (ReputationData, Reputation)
+-- Social/         # Multiplayer features (Badges, Directory, FellowTravelers, Minigames, etc.)
|   +-- Games/      # Game system (GameCore, GameUI, GameComms, Tetris, Pong, DeathRoll, Battleship, Wordle, PacMan)
```

**SavedVariables:**
- `HopeAddonDB` - Account-wide settings
- `HopeAddonCharDB` - Per-character data (journal, stats, attunements, travelers, reputation)

---

## Feature Status

| Feature | Status | Feature | Status |
|---------|--------|---------|--------|
| Journal UI (7 tabs) | DONE | Score Challenge | DONE |
| Timeline | DONE | PacMan | DONE |
| Milestones | DONE | Battleship | DONE |
| Attunements (6 chains) | DONE | WoW Wordle | DONE |
| Reputation (18 factions) | DONE | Games Hall UI | DONE |
| Fellow Travelers | DONE | Activity Feed | PARTIAL |
| RP Profiles | DONE | Rumors | DONE |
| Badges (20+) | DONE | Mug Reactions | DONE |
| Statistics | DONE | Companions | DONE |
| Minigames | DONE | Social Toasts | DONE |
| Tetris Battle | DONE | Romance System | DONE |
| Death Roll | DONE | Armory Tab | DONE |
| Pong | DONE | Calendar | DONE |
| Calendar Validation | DONE | Soft Reserve | DONE |
| Raids Tab (P1-P5) | DONE | Guild System | DONE |
| Boss Kill Recap | DONE | Crusade Critter | DONE |
| Nameplate Colors | DONE | | |

---

## Known Incomplete Items

### 1. Milestone Detail Modal (Low Priority)
**File:** `Journal/Journal.lua`
**Issue:** Clicking milestone cards plays sound but doesn't open a detail modal
**Needed:** Full modal dialog showing milestone details

### 2. CheckAttunementIcons Placeholder (Medium Priority)
**File:** `Social/TravelerIcons.lua`
**Issue:** Function is stubbed - waiting on addon communication protocol
**Needed:** Logic to check if both players completed an attunement together

### 3. Settings Panel (Low Priority)
**Issue:** Settings scattered across slash commands, no dedicated UI panel
**Current:** `/hope debug`, `/hope sound`, `/hope reset`
**Needed:** Optional - dedicated settings tab in journal

### 4. Feed Mug Reactions UI (Low Priority)
**File:** `Journal/Journal.lua`
**Issue:** Mug counts tracked in `activity.mugs` but not visually displayed
**Needed:** Add clickable mug icon with count display on each feed row

---

## File Index

### Core Files
| File | Purpose |
|------|---------|
| `Core/Core.lua` | Main init, utilities, slash commands |
| `Core/Constants.lua` | All static data (milestones, raids, badges, loot) |
| `Core/ArmoryBisData.lua` | Phase-based BiS gear data for Armory tab |
| `Core/Effects.lua` | Visual effect utilities |
| `Core/FramePool.lua` | Generic object pooling |
| `Core/Sounds.lua` | Sound effect playback |
| `Core/Timer.lua` | TBC-compatible timer system |
| `Core/Charts.lua` | Chart/graph rendering utilities |

### Journal System
| File | Purpose |
|------|---------|
| `Journal/Journal.lua` | Main UI, tabs, event tracking |
| `Journal/Pages.lua` | Page templates and rendering |
| `Journal/Milestones.lua` | Level milestone tracking |
| `Journal/ProfileEditor.lua` | Character profile UI |

### Raid & Reputation
| File | Purpose |
|------|---------|
| `Raids/Attunements.lua` | Quest chain tracking, progress calc |
| `Raids/RaidData.lua` | Raid definitions (Phase 1-5, all 9 TBC raids) |
| `Raids/EncounterTracker.lua` | Boss encounter event tracking & stats collection |
| `Raids/BossBreakdown.lua` | Post-kill breakdown panel UI |
| `Reputation/ReputationData.lua` | Faction definitions and standings |

### Social System
| File | Purpose |
|------|---------|
| `Social/Badges.lua` | Achievement definitions |
| `Social/Guild.lua` | Guild Hall - roster caching, activity tracking |
| `Social/Directory.lua` | Searchable player directory |
| `Social/FellowTravelers.lua` | Addon-to-addon communication |
| `Social/ActivityFeed.lua` | Activity feed (Notice Board) |
| `Social/Minigames.lua` | Dice, RPS, Death Roll logic |
| `Social/Calendar.lua` | Event scheduling and raid signups |
| `Social/CalendarValidation.lua` | Event/signup validation rules |
| `Social/Treasures.lua` | Soft Reserve (SR) loot system |
| `Social/NameplateColors.lua` | Fellow Traveler nameplate coloring |
| `Social/CrusadeCritter.lua` | Crusade Critter mascot core logic |
| `Social/CrusadeCritterUI.lua` | Crusade Critter mascot UI system |
| `Social/CrusadeCritterContent.lua` | Crusade Critter speech/tip content |
| `Social/Companions.lua` | Companion pet system |
| `Social/Romance.lua` | Romance/relationship system |
| `Social/SocialToasts.lua` | Social notification toasts |
| `Social/MinigamesUI.lua` | Minigames UI (dice, RPS, Death Roll) |
| `Social/CalendarUI.lua` | Calendar UI rendering |

### Game System
| File | Purpose |
|------|---------|
| `Social/Games/GameCore.lua` | Game loop, state machine |
| `Social/Games/GameUI.lua` | Shared UI components |
| `Social/Games/GameComms.lua` | Addon messaging for multiplayer |
| `Social/Games/Tetris/*.lua` | Tetris implementation |
| `Social/Games/Pong/PongGame.lua` | Pong implementation |
| `Social/Games/DeathRoll/*.lua` | Death Roll gambling game |
| `Social/Games/PacMan/*.lua` | PacMan arcade game with ghost AI |
| `Social/Games/Battleship/*.lua` | Battleship implementation |
| `Social/Games/Wordle/*.lua` | WoW Wordle implementation |
| `Social/Games/ScoreChallenge.lua` | Multiplayer score challenge system |
| `Social/Games/GameChat.lua` | In-game opponent chat |

### UI Framework
| File | Purpose |
|------|---------|
| `UI/Components.lua` | All reusable UI components |
| `UI/Glow.lua` | Glow effects |
| `UI/Animations.lua` | Animation utilities |
| `UI/MinimapButton.lua` | Draggable minimap button |

**Full module APIs: See MODULE_API_REFERENCE.md**

---

## Module Dependencies

**Load Order:**
1. Core Foundation (FramePool, Constants, Timer, Core, Sounds, Effects)
2. UI Components (Components, Glow, Animations)
3. Journal System (Journal, Pages, Milestones, ProfileEditor)
4. Raid & Reputation (RaidData, EncounterTracker, BossBreakdown, Attunements, Reputation)
5. Social Features (Badges, FellowTravelers, Directory, Relationships, Minigames, NameplateColors, CrusadeCritter)
6. Game System (GameCore, GameUI, GameComms, game implementations)

**Key Relationships:**
| Module | Depends On | Called By |
|--------|------------|-----------|
| **Badges** | Constants | Milestones, RaidData, Attunements, Reputation |
| **FellowTravelers** | Timer, Core | Directory, Minigames, GameComms, TravelerIcons |
| **Directory** | FellowTravelers, Relationships | Journal (UI) |
| **Journal** | All UI modules, Effects, Sounds | Core (main entry point) |
| **GameComms** | FellowTravelers, GameCore | Game implementations |

---

## Data Structures

**Essential Character Data (`HopeAddonCharDB`):**
- `journal.entries` - All journal entries chronologically
- `journal.levelMilestones[level]` - Level milestone entries
- `journal.bossKills[bossName]` - Boss kill counts
- `attunements[raidKey]` - Quest chain progress per raid
- `stats.deaths` - Death tracking by zone/boss
- `stats.playtime` - Total playtime in seconds
- `guild.roster[playerName]` - Cached guild member data
- `travelers.known[playerName]` - All encountered players
- `travelers.fellows[playerName]` - Addon users only
- `travelers.myProfile` - Player's RP profile
- `relationships[playerName]` - Player notes

**Full schema: See MODULE_API_REFERENCE.md**

---

## Constants Reference

**Key Categories in `Core/Constants.lua`:**
| Category | Constant | Structure |
|----------|----------|-----------|
| Milestones | `C.LEVEL_MILESTONES` | `[level] = { title, icon, story }` |
| Attunements | `C.[RAID]_ATTUNEMENT` | `{ chapters, questIds }` |
| Bosses | `C.[RAID]_BOSSES` | `{ id, name, location, lore, mechanics, loot }` |
| Icons | `C.TRAVELER_ICONS` | `{ id, name, icon, quality, category, trigger }` |
| Raid Phases | `C.RAID_PHASES` | `[raidKey] = 1/2/3/4/5` |
| Games | `C.GAME_DEFINITIONS` | `{ id, name, description, icon, hasLocal, hasRemote }` |

**Lookup Functions:**
- `C.ATTUNEMENT_QUEST_LOOKUP[questId]` -> `{ raid, chapter }`
- `C.ENCOUNTER_TO_BOSS[encounterId]` -> `{ raid, boss }`
- `C:GetRaidPhase(raidKey)` -> `1/2/3/4/5 or nil`
- `C:GetGameDefinition(gameId)` -> game definition table

### Hardcoded Calendar Events

**Location:** `HopeAddon/Core/Constants.lua` - `C.APP_WIDE_EVENTS` table (around line 8661)

These are server-wide milestone events displayed as banners at the top of the Calendar tab.

**Data Structure:**
| Field | Required | Description |
|-------|----------|-------------|
| id | Yes | Unique identifier (e.g., "app_dark_portal") |
| title | Yes | Short display title for banner |
| description | Yes | Full description shown in tooltip |
| startDate | Yes | "YYYY-MM-DD" format |
| endDate | No | End date for multi-day events (defaults to startDate) |
| time | Yes | "HH:MM" (24h format) or "WEEKLY_RESET" |
| colorName | Yes | Theme key from APP_WIDE_EVENT_COLORS |
| icon | Yes | Full path like "Interface\\Icons\\IconName" |

**Available Color Themes:**
- `FEL_GREEN` - Fel/Outland theme (green) - Dark Portal, TBC content
- `BLOOD_RED` - Combat/PvP theme (red) - Arena seasons, battlegrounds
- `ARCANE_PURPLE` - Arcane/magic theme (purple) - Raids, dungeons
- `GOLD` - Default/general theme (gold) - Anniversaries, general events

**To Add New Event:**
1. Add entry to `C.APP_WIDE_EVENTS` table in `Constants.lua`
2. Choose appropriate icon from WoW assets (browse at wowhead.com/icons)
3. Select color theme matching the event's mood
4. Test by opening Journal > Social > Calendar and navigating to event month

### Calendar Event Types

The calendar displays two types of events:

**Guild Events** (User-Created)
- Created via Calendar UI or `/hope calendar` commands
- Support signups with tank/healer/dps/standby roles
- Synced to other Fellow Travelers via network
- Can be edited/deleted by creator
- Time conflicts shown as warnings (informational only, don't block signups)
- Use case: Raid nights, dungeon runs, guild RP events

**Server Events** (Hardcoded)
- Defined in `C.SERVER_EVENTS` in Constants.lua
- Read-only, no signups
- Everyone sees the same events (no network sync needed)
- Gold/legendary border and "SERVER EVENT" label
- Use case: Dark Portal opening, server-wide RP, seasonal events
- Updated by addon maintainer ~2 weeks in advance

**Server Events Data Format:**
```lua
{
    id = "unique_id",           -- Unique identifier
    title = "Event Name",       -- Display title
    eventType = "SERVER",       -- Always "SERVER"
    date = "YYYY-MM-DD",        -- Date string
    startTime = "HH:MM",        -- Start time (or "All Day")
    description = "...",        -- Event description (no length limit)
    icon = "Interface\\Icons\\IconName",  -- Full icon path
    permanent = false,          -- true = repeating yearly, false = one-time
}
```

---

## UI Components

**Shared components from `UI/Components.lua`:**
| Component | Function | Usage |
|-----------|----------|-------|
| Parchment Frame | `CreateParchmentFrame()` | Main container |
| Tab Button | `CreateTabButton()` | Tab headers |
| Scroll Frame | `CreateScrollFrame()` | Content scrolling |
| Entry Card | `CreateEntryCard()` | All tab entries |
| Progress Bar | `CreateProgressBar()` | Attunements, Rep |
| Collapsible Section | `CreateCollapsibleSection()` | Acts, Raids |
| Game Card | `CreateGameCard()` | Games Hall cards |
| Layout Builder | `CreateLayoutBuilder()` | Form layout |
| Styled Button | `CreateStyledButton()` | Buttons with hover |

**Full UI specs: See UI_ORGANIZATION_GUIDE.md**

---

## Patterns

### Module Pattern
```lua
local ModuleName = {}
HopeAddon:RegisterModule("ModuleName", ModuleName)

function ModuleName:OnInitialize() end  -- Called during load
function ModuleName:OnEnable() end      -- Called on PLAYER_LOGIN
function ModuleName:OnDisable() end     -- Called on PLAYER_LOGOUT
```

### Tab Population Pattern
```lua
function Journal:PopulateXXX()
    local scrollContainer = self.mainFrame.scrollContainer
    scrollContainer:ClearEntries(self.containerPool)

    local header = self:CreateSectionHeader("TITLE", "COLOR")
    scrollContainer:AddEntry(header)

    for _, item in ipairs(data) do
        local card = self:AcquireCard(scrollContainer.content, itemData)
        scrollContainer:AddEntry(card)
    end

    self:UpdateFooter()
end
```

### Naming Conventions
| Pattern | Example | Purpose |
|---------|---------|---------|
| `Create*` | `CreateSectionHeader()` | Constructor |
| `Populate*` | `PopulateTimeline()` | Tab rendering |
| `Acquire*` | `AcquireCard()` | Pool retrieval |
| `Get*` | `GetTimestamp()` | Data retrieval |
| `Format*` | `FormatPlaytime()` | String formatting |
| `On*` | `OnEnable()` | Event handlers |
| `Update*` | `UpdateFooter()` | UI refresh |

---

## Testing Commands

```
/hope (or /journal)            - Open journal
/hope debug                    - Toggle debug mode
/hope stats                    - Show stats in chat
/hope sound                    - Toggle sounds
/hope combathide               - Toggle auto-hide UI during combat
/hope minimap                  - Toggle minimap button visibility
/hope nameplates               - Toggle Fellow nameplate coloring
/hope demo                     - Populate sample data for UI testing
/hope reset demo               - Clear demo data
/hope reset confirm            - Reset all character data
/hope tetris [player]          - Start Tetris Battle
/hope pong [player]            - Start Pong
/hope deathroll [player]       - Start Death Roll
/hope battleship [player]      - Start Battleship
/hope wordle                   - Start WoW Wordle (practice)
/hope wordle <player>          - Challenge player to Wordle
/hope wordle stats             - Show Wordle statistics
/hope words                    - Start local practice Words game
/hope words <player>           - Resume or start Words vs player
/hope words list               - Show all active Words games
/hope words forfeit <player>   - Forfeit a Words game
/word <word> <H/V> <row> <col> - Place word in Words game
/pass                          - Pass turn in Words game
/fire <coord>                  - Fire in Battleship (e.g., /fire A5)
/ready                         - Signal ships placed in Battleship
/surrender                     - Forfeit Battleship game
/gc <message>                  - Send chat to opponent in any game
/hope challenge <player>       - Challenge via game selection popup
/hope accept                   - Accept pending challenge
/hope decline                  - Decline pending challenge
/hope sr <raid> <item>         - Set soft reserve
/hope sr list                  - Show your soft reserves
/hope sr clear <raid>          - Clear soft reserve
/hope sr guild [raid]          - Show guild soft reserves
```

**Run tests:** `/run LoadAddOn("HopeAddon_Tests")` then `/wordtest all`

---

## Documentation Maintenance

**This project has no human developer.** Documentation accuracy directly impacts future AI sessions.

### When to Update

| Event | Action |
|-------|--------|
| Feature completed | Update Feature Status table |
| Bug fixed | Add to CHANGELOG.md |
| New issue found | Add to Known Incomplete Items |
| New file/module | Add to File Index |
| Data structure changed | Update MODULE_API_REFERENCE.md |

### Session Handoff Checklist

Before ending a session:
- [ ] All changes reflected in documentation
- [ ] New dependencies/modules documented
- [ ] Issues added to Known Incomplete Items
- [ ] Feature status accurate
- [ ] Recent changes added to CHANGELOG.md
