# Journey Tab - Component Reference

> **Audience:** AI assistants modifying journey code in `Journal.lua`.
> **Scope:** Level 70 endgame system (`PopulateJourneyEndgame`), with brief coverage of pre-60 and leveling modes.

---

## 1. Architecture Overview

### What the Journey Tab Does

The Journey tab is a **single-player progression dashboard** showing what the player should do next in TBC Classic. It adapts to the player's level:

| Level Range | Mode | Entry Point |
|-------------|------|-------------|
| < 60 | Pre-Outland encouragement | `PopulateJourneyPre60()` |
| 60-67 | Leveling gear recommendations | `PopulateJourneyLeveling()` |
| >= 68 | **Endgame progression** | `PopulateJourneyEndgame()` |

### File Map

All journey code lives in `HopeAddon/Journal/Journal.lua`.
Line numbers shift as the file evolves; use function names as anchors.

Key functions (search by name):
- `CreateJourneyPools()` - creates 5 journey-specific frame pools
- `AcquireCollapsibleSection()` - pool-based collapsible UI
- `AcquireContainer()` - generic container pool
- `GetTierStatus()`, `GetAttunementSummary()`, `GetKeyReputationSummary()`, `GetNextFocus()`
- `CreateJourneySummaryHeader()`, `CreateTierProgressSection()`, `CreateFocusPanel()`
- `CreateAttunementSummary()`, `CreateHeroicKeysSummary()`
- `CreateLootHotlist()`, `CreateLootCategorySection()`, `CreateLootCard()`
- `GetFactionProgress()`, `GetNextStep()`, `CreateNextStepBox()`
- `CreateTimelineSeparator()`, `PopulateJourney()` (dispatcher)
- `PopulateJourneyPre60()`, `PopulateJourneyEndgame()`, `PopulateJourneyLeveling()`
- `CreateNextEventCollapsibleSection()`, `PopulateEventCard()` (shared helper)
- `CreateNextEventCardContent()`, `CreateNextEventCard()` (legacy)
- `CreateUpcomingEventCard()`, `CreateLevelingGearCard()`
- `GetFactionStanding()`

### Journey Pools (`self.journeyPools`)

Created by `CreateJourneyPools()`, called from `OnEnable` before `CreateMainFrame`. Five named pools:

| Pool Key | Pool Name | Max Active | Replaces |
|----------|-----------|------------|----------|
| `nextStepCard` | JourneyNextStep | 1 | `self._nextStepFrame` singleton |
| `eventCard` | JourneyEventCard | 1 | `self._nextEventFrame` singleton |
| `tierCard` | JourneyTierCard | 3 | `container["tierCard"..key]` inline |
| `lootCard` | JourneyLootCard | ~9 | `parent[cardKey]` inline in `CreateLootCard` + `CreateLevelingGearCard` |
| `upcomingEventCard` | JourneyUpcomingEvent | 3 | `parent["_upcomingEventCard"..i]` inline |

**Lifecycle:**
- Released on tab switch (before card/collapsible/container pools)
- Destroyed on `OnDisable` (before armory pools)
- `lootCard` pool is shared between endgame (72px, 32x32 icon) and leveling (70px, 36x36 icon); each populate function sets sizes/fonts explicitly, reset restores endgame defaults

### Level 70 Endgame Layout (ASCII)

```
+=============================================+
| [-] UPCOMING EVENTS           (collapsible) |
|   [Next Event Card]  [Calendar Events]      |
+=============================================+
| YOUR NEXT STEP          [Phase Badge]       |
| [icon] Title                                |
|         Subtitle                            |
| "Story text..."                             |
| [====== progress bar ======] 3/7            |
+=============================================+
| CURRENT FOCUS                               |
|   KARAZHAN ATTUNEMENT                       |
|   The Master's Key                          |
|   [X] Step 1 complete                       |
|   [ ] Step 2 (current)                      |
|   [ ] Step 3                                |
+=============================================+
|         YOU ARE PREPARED                    |
|    The journey of PlayerName through Outland |
+=============================================+
| RAID PROGRESSION                            |
|  +--------+  +--------+  +--------+        |
|  | Tier 4 |  | Tier 5 |  | Tier 6 |        |
|  | 5/14   |  | 0/10   |  | LOCKED |        |
|  | [X] Kz |  | [ ] SSC|  | [ ] Hyj|        |
|  | [-] Gr |  | [ ] TK |  | [ ] BT |        |
|  | [ ] Mg |  +--------+  +--------+        |
|  +--------+                                 |
+=============================================+
| ATTUNEMENTS                                 |
|   [X] Karazhan    [-] SSC (3/5)            |
|   [ ] TK          [ ] Hyjal   [ ] BT       |
+=============================================+
| HEROIC DUNGEON KEYS          (3/5)          |
|   [X] Flamewrought  Honor Hold  Revered     |
|   [X] Reservoir     CE          Revered     |
|   [ ] Auchenai      Lower City  Honored     |
|   [X] Warpforged    Sha'tar     Revered     |
|   [ ] Key of Time   KoT         Friendly    |
+=============================================+
| WARRIOR - Arms   (GS: 112)                 |
|  [Reputation Rewards]                       |
|    [item card] [item card] [item card]      |
|  [Dungeon Drops]                            |
|    [item card] [item card] [item card]      |
|  [Crafted Gear]                             |
|    [item card] [item card] [item card]      |
+=============================================+
```

---

## 2. Level-Based Branching

### PopulateJourney() - Dispatcher

```
PopulateJourney()
  ├─ playerLevel < 60  → PopulateJourneyPre60(playerLevel)
  ├─ playerLevel < 68  → PopulateJourneyLeveling(playerLevel)
  └─ playerLevel >= 68 → PopulateJourneyEndgame()
```

Called from the tab selection handler when the Journey tab is selected.

### PopulateJourneyPre60()

Shows a "JOURNEY TO OUTLAND" header box with:
- Level display and progress bar (1-60)
- Motivational text that changes based on proximity to 60
- "WHAT AWAITS IN OUTLAND" bullet points
- Next event card (uses `CreateNextEventCard`, the legacy standalone version)
- Upcoming events section

### PopulateJourneyLeveling()

Shows gear recommendations for leveling:
- Upcoming events collapsible section (same as endgame)
- Level progress box (`CreateLevelingProgressBox`)
- Gear recommendations header with role/spec info
- Dungeon drops and quest reward sections
- Recommended dungeons list
- Data sources: `C.LEVELING_RANGES`, `C.LEVELING_ROLES`, `C:GetLevelingGear()`, `C:GetRecommendedDungeons()`

### PopulateJourneyEndgame()

**The main focus of this document.** Builds 8 sections in order:

```lua
function Journal:PopulateJourneyEndgame()
    local scrollContainer = self.mainFrame.scrollContainer
    -- 1. Upcoming Events (collapsible)
    self:CreateNextEventCollapsibleSection(scrollContainer)
    -- 2. Your Next Step (guidance box)
    scrollContainer:AddEntry(self:CreateNextStepBox())
    -- 3. Current Focus (checklist)
    scrollContainer:AddEntry(self:CreateFocusPanel())
    -- 4. YOU ARE PREPARED header
    scrollContainer:AddEntry(self:CreateJourneySummaryHeader())
    -- 5. Tier Progress (T4/T5/T6 cards)
    scrollContainer:AddEntry(self:CreateTierProgressSection())
    -- 6. Attunement Summary
    scrollContainer:AddEntry(self:CreateAttunementSummary())
    -- 7. Heroic Keys
    scrollContainer:AddEntry(self:CreateHeroicKeysSummary())
    -- 8. Loot Hotlist
    scrollContainer:AddEntry(self:CreateLootHotlist())
end
```

---

## 3. Component Breakdown

### 3.1 Upcoming Events (Collapsible)

**Function:** `CreateNextEventCollapsibleSection(scrollContainer)`

**Purpose:** Shows app-wide events and calendar events in a collapsible section at the top of the Journey tab.

**Call flow:**
```
CreateNextEventCollapsibleSection(scrollContainer)
  ├─ C:GetNextAppWideEvent()           → app-wide event data or nil
  ├─ Calendar:GetUpcomingEvents(1)     → calendar events array
  ├─ AcquireCollapsibleSection(...)    → pooled collapsible frame
  ├─ CreateNextEventCardContent(section.contentContainer)  → acquires from journeyPools.eventCard
  │    └─ PopulateEventCard()          → shared helper for event card population
  └─ CreateUpcomingEventsContent(section.contentContainer)  → calendar content
```

**PopulateEventCard(container, parent, event, isPast, colorTheme):**
Shared helper used by both `CreateNextEventCardContent()` and `CreateNextEventCard()` (legacy). Populates a pooled `journeyPools.eventCard` frame with:
- Event icon (36x36) with colored border
- Event title and date/time text
- Color theme applied to border and text (from `C.APP_WIDE_EVENT_COLORS` or calendar defaults)
- `isPast` flag dims the card for expired events
- Click handler navigates to Social > Calendar tab

**Data sources:**
- `C:GetNextAppWideEvent()` - hardcoded events from Constants.lua
- `Calendar:GetUpcomingEvents(1)` - player's calendar events via Calendar module

**Constants:** `C.JOURNEY_NEXT_EVENT` - `{ CONTAINER_HEIGHT = 85, ICON_SIZE = 36, BORDER_WIDTH = 2 }`

**Key behavior:**
- Section is omitted entirely if no events exist
- Both `CreateNextEventCardContent()` and `CreateNextEventCard()` acquire from `journeyPools.eventCard` and delegate to shared `PopulateEventCard()` helper
- `section.onToggle` calls `scrollContainer:RecalculatePositions()` to fix layout after collapse/expand
- Click on event card navigates to Social > Calendar tab

---

### 3.2 Next Step Box

**Functions:**
- `GetNextStep()` - determines current progression phase
- `CreateNextStepBox()` - renders the guidance box

**Purpose:** A prominent box showing the player's current progression goal with an icon, descriptive text, and a progress bar.

**Call flow:**
```
CreateNextStepBox()
  ├─ GetNextStep()                → stepData { phase, title, subtitle, story, icon, progress }
  ├─ PHASE_COLORS[phase]          → color key for border/text
  ├─ PHASE_NAMES[phase]           → display name for badge
  └─ Renders: header, icon, title, subtitle, story, progress bar, phase badge
```

**GetNextStep() progression order:**

| Priority | Phase Key | Condition | Title Example |
|----------|-----------|-----------|---------------|
| 1 | `PRE_OUTLAND` | level < 58 | "Reach the Dark Portal" |
| 2 | `T4_ATTUNEMENT` | Kara not complete | "Karazhan Attunement" |
| 3 | `HEROIC_KEYS` | Missing heroic keys | "Earn Heroic Keys" |
| 4 | `T5_ATTUNEMENT` | SSC or TK not attuned | "SSC/TK Attunement" |
| 5 | `T6_ATTUNEMENT` | Hyjal or BT not attuned | "Hyjal/BT Attunement" |
| 6 | `RAID_PROGRESSION` | T6 not cleared | "Clear [raid name]" |
| 7 | `ENDGAME` | Everything done | "Legend of Outland" |

**stepData shape:**
```lua
{
    phase = "T4_ATTUNEMENT",    -- key into PHASE_COLORS/PHASE_NAMES
    title = "Karazhan Attunement",
    subtitle = "Chapter 3 of 7",
    story = "Complete the Karazhan attunement chain.",
    icon = "Interface\\Icons\\INV_Misc_Key_07",
    progress = {
        current = 2,
        total = 7,
        percentage = 28,
        label = "2 / 7"
    }
}
```

**Data sources:**
- `HopeAddon.Attunements:GetProgress(raidKey)` - attunement chapter completion
- `HopeAddon.Attunements:GetTotalChapters(raidKey)` - chapter count
- `C.HEROIC_KEY_ORDER`, `C.HEROIC_KEYS` - heroic key definitions
- `Journal:GetFactionStanding(factionId)` - rep lookups
- `Journal:GetTierStatus("T6")` - raid boss kill tracking

**UI notes:**
- Uses `journeyPools.nextStepCard` pool (max 1 active)
- Border color matches the phase color
- Phase badge appears in top-right corner
- Progress bar width is `(CONTAINER_WIDTH - 44) * (pct / 100)`

**Constants (local tables in Journal.lua):**

```lua
PHASE_COLORS = {
    PRE_OUTLAND = "GOLD_BRIGHT", T4_ATTUNEMENT = "FEL_GREEN",
    HEROIC_KEYS = "KARA_PURPLE", T5_ATTUNEMENT = "ARCANE_PURPLE",
    T6_ATTUNEMENT = "HELLFIRE_RED", RAID_PROGRESSION = "SKY_BLUE",
    ENDGAME = "GOLD_BRIGHT",
}

PHASE_NAMES = {
    PRE_OUTLAND = "The Journey Begins", T4_ATTUNEMENT = "Tier 4 Attunement",
    HEROIC_KEYS = "Heroic Dungeon Keys", T5_ATTUNEMENT = "Tier 5 Attunement",
    T6_ATTUNEMENT = "Tier 6 Attunement", RAID_PROGRESSION = "Raid Progression",
    ENDGAME = "Legend of Outland",
}
```

---

### 3.3 Focus Panel

**Functions:**
- `GetNextFocus()` - generates a checklist based on progression
- `CreateFocusPanel()` - renders the checklist UI

**Purpose:** A dynamic checklist showing the immediate tasks the player should complete, drilling into the current progression step.

**Call flow:**
```
CreateFocusPanel()
  ├─ GetNextFocus()            → { title, subtitle, items[] }
  ├─ AcquireContainer(height = 95 + #items * 16)
  └─ Renders: section title "CURRENT FOCUS", focus title, subtitle, checklist items
```

**GetNextFocus() progression order:**

| Priority | Title | Condition |
|----------|-------|-----------|
| 1 | "REACH THE DARK PORTAL" | level < 58 |
| 2 | "KARAZHAN ATTUNEMENT" | Kara not complete - shows chapter steps |
| 3 | "EARN HEROIC KEYS" | Missing keys - shows each key + faction |
| 4 | "TIER 5 ATTUNEMENTS" | SSC/TK not complete - shows quest steps |
| 5 | "TIER 6 ATTUNEMENTS" | Hyjal/BT not complete - shows requirements |
| 6 | "CONQUER TIER 6" | T6 not cleared - shows raid clear status |
| 7 | "LEGEND OF OUTLAND" | Everything done - all items checked |

**Focus item shape:**
```lua
{ text = "Step name", done = true/false, current = true/false }
```

**Rendering:**
- Done items: green `[X]` + green text
- Current item: grey `[ ]` + white text
- Future items: grey `[ ]` + grey text
- Container height dynamically adjusts: `95 + (#items * 16)` pixels
- Hides excess items (up to 10 slots pre-allocated)

**Data sources:**
- `HopeAddon.Attunements` - attunement state and chapter progress
- `C.HEROIC_KEY_ORDER`, `C.HEROIC_KEYS` - heroic key data
- `Journal:GetFactionStanding()` - rep standing for key checks
- `Journal:GetTierStatus("T6")` - raid clear status

---

### 3.4 Summary Header

**Function:** `CreateJourneySummaryHeader()`

**Purpose:** Displays "YOU ARE PREPARED" title in fel green with a subtitle containing the player's class-colored name.

**Call flow:**
```
CreateJourneySummaryHeader()
  ├─ AcquireContainer(height = 70)
  ├─ Title: "YOU ARE PREPARED" in FEL_GREEN (24pt TITLE font)
  └─ Subtitle: "The journey of [PlayerName] through Outland" (12pt BODY font, class-colored name)
```

**Data sources:**
- `UnitName("player")` - player name
- `UnitClass("player")` - class for color lookup
- `HopeAddon:GetClassColor(class)` - class color RGB

---

### 3.5 Tier Progress Cards

**Function:** `CreateTierProgressSection()`

**Purpose:** Shows 3 side-by-side cards (T4, T5, T6) with boss kill counts, status, and per-raid breakdown.

**Call flow:**
```
CreateTierProgressSection()
  ├─ AcquireContainer(height = 140)
  ├─ Section title "RAID PROGRESSION" in GOLD_BRIGHT
  └─ For each tier in { "T4", "T5", "T6" }:
      ├─ journeyPools.tierCard:Acquire()  → pooled tier card frame
      ├─ GetTierStatus(tierKey) → { status, bossesKilled, totalBosses, raids[], color, name }
      └─ Renders card: tier name, status text, boss count, per-raid checklist
```

Each tier card is acquired from `journeyPools.tierCard` pool (max 3 active) and parented to the container.

**GetTierStatus():**

Returns tier status by aggregating boss kills across tier raids:
```lua
{
    status = "LOCKED" | "READY" | "IN_PROGRESS" | "CLEARED",
    bossesKilled = 5,
    totalBosses = 14,
    raids = {
        { key="karazhan", name="Karazhan", bossesKilled=5, totalBosses=11,
          attuned=true, cleared=false, attuneProgress=7, attuneTotal=7 },
        ...
    },
    color = "UNCOMMON",  -- from TIER_INFO
    name = "Tier 4",
}
```

**Status determination logic:**
- `CLEARED` = all bosses killed
- `IN_PROGRESS` = some bosses killed
- `READY` = at least one raid attuned, no kills yet
- `LOCKED` = no attunements, no kills

**Card layout:**
- 3 cards, each 150x100px, with 10px spacing, centered in container
- Background/border color varies by status (green=cleared, yellow=in-progress, blue=ready, red=locked)
- Each card shows: tier name (colored), status text, boss count "X / Y bosses", per-raid checklist

**Local data tables (Journal.lua):**
```lua
TIER_INFO = {
    T4 = { name = "Tier 4", color = "UNCOMMON", raids = { "karazhan", "gruul", "magtheridon" } },
    T5 = { name = "Tier 5", color = "RARE", raids = { "ssc", "tk" } },
    T6 = { name = "Tier 6", color = "EPIC", raids = { "hyjal", "bt" } },
}

RAID_NAMES = {
    karazhan = "Karazhan", gruul = "Gruul's Lair", magtheridon = "Magtheridon's Lair",
    ssc = "Serpentshrine Cavern", tk = "Tempest Keep",
    hyjal = "Hyjal Summit", bt = "Black Temple",
}

RAID_BOSS_COUNTS = {
    karazhan = 11, gruul = 2, magtheridon = 1,
    ssc = 6, tk = 4, hyjal = 5, bt = 9,
}
```

**Data sources:**
- `HopeAddon.charDb.journal.bossKills` - boss kill tracking (table keyed by boss ID)
- `C[RAID_KEY .. "_BOSSES"]` - boss lists per raid (e.g., `C.KARAZHAN_BOSSES`)
- `HopeAddon.Attunements:GetState(raidKey)` / `:GetProgress(raidKey)` - attunement state
- Gruul and Magtheridon are always marked `attuned = true` (no attunement required)

---

### 3.6 Attunement Summary

**Functions:**
- `GetAttunementSummary()` - collects attunement progress
- `CreateAttunementSummary()` - renders compact checklist

**Purpose:** A 5-item checklist showing attunement status for all TBC raids.

**Call flow:**
```
CreateAttunementSummary()
  ├─ GetAttunementSummary()    → array of { name, state, completed, total, isComplete }
  ├─ AcquireContainer(height = 90)
  ├─ Section title "ATTUNEMENTS" in GOLD_BRIGHT
  └─ For each attunement:
      └─ Renders: status icon + colored name
```

**GetAttunementSummary():**
- Iterates `{ "karazhan", "ssc", "tk", "hyjal", "bt" }` in order
- For each: queries `Attunements:GetState()` and `:GetProgress()`
- Returns array of `{ name, state, completed, total, isComplete }`

**Rendering:**
- Complete: green `[X]` + green text
- In progress: yellow `[N/M]` + yellow text
- Not started: grey `[ ]` + grey text
- Items spaced 13px apart vertically

---

### 3.7 Heroic Keys Summary

**Function:** `CreateHeroicKeysSummary()`

**Purpose:** Shows 5 heroic dungeon keys with faction name, current standing, and obtained status.

**Call flow:**
```
CreateHeroicKeysSummary()
  ├─ AcquireContainer(height = 120)
  ├─ Section title "HEROIC DUNGEON KEYS" in KARA_PURPLE (with count suffix)
  └─ For each keyId in C.HEROIC_KEY_ORDER:
      ├─ Resolve faction-specific keys (Alliance vs Horde)
      ├─ GetFactionStanding(factionId)
      └─ Renders: checkmark + key name + faction name (purple) + standing/requirement
```

**Data sources:**
- `C.HEROIC_KEY_ORDER`: `{ "flamewrought", "reservoir", "auchenai", "warpforged", "key_of_time" }`
- `C.HEROIC_KEYS`: key definitions with faction data
- `Journal:GetFactionStanding(factionId)`: iterates `GetFactionInfo` to find standing

**Heroic key data shape** (from `C.HEROIC_KEYS`):
```lua
{
    name = "Flamewrought Key",
    icon = "INV_Misc_Key_13",
    dungeons = { "Hellfire Ramparts", "The Blood Furnace", "The Shattered Halls" },
    dungeonGroup = "Hellfire Citadel",
    -- Single-faction:
    faction = "Cenarion Expedition",   factionId = 942,
    -- OR faction-specific:
    factionAlliance = "Honor Hold",    factionHorde = "Thrallmar",
    factionId = { alliance = 946, horde = 947 },
    requiredStanding = 7,  -- Revered
    description = "...",
    tips = { "..." },
}
```

**Rendering:**
- Obtained: green `[X]` + green name
- Not obtained, Honored+: yellow standing color
- Not obtained, below Honored: red standing color
- Each entry shows: `[X/O] KeyName  FactionName  Standing / Required`
- Section title includes count: `"HEROIC DUNGEON KEYS  (3/5)"`
- Items spaced 16px apart vertically

---

### 3.8 Loot Hotlist

**Functions:**
- `CreateLootHotlist()` - main container with 3 category sections
- `CreateLootCategorySection()` - collapsible category header
- `CreateLootCard()` - individual item card with tooltip

**Purpose:** Shows spec-specific recommended items across 3 categories: reputation rewards, dungeon drops, and crafted gear.

**Call flow:**
```
CreateLootHotlist()
  ├─ HopeAddon:GetPlayerSpec() → specName, specTab, specPoints
  ├─ C.CLASS_SPEC_LOOT_HOTLIST[classToken][specTab]  → { rep={}, drops={}, crafted={} }
  ├─ Fallback: C.CLASS_LOOT_HOTLIST[classToken]  → legacy data (rep only)
  ├─ AcquireContainer(calculated height)
  ├─ Section title: "CLASSNAME - SpecName (GearScore)"
  └─ For each category { rep, drops, crafted }:
      ├─ CreateLootCategorySection(...)   → collapsible section frame
      └─ For each item:
          └─ CreateLootCard(sectionFrame, item)
```

**CreateLootCategorySection():**
- Creates a collapsible section with colored border and expand/collapse toggle
- Categories: `{ key="rep", title="Reputation Rewards", color="ARCANE_PURPLE" }`, `{ key="drops", title="Dungeon Drops", color="FEL_GREEN" }`, `{ key="crafted", title="Crafted Gear", color="GOLD_BRIGHT" }`

**CreateLootCard(parent, item):**
- Acquires from `journeyPools.lootCard` pool (shared with `CreateLevelingGearCard`)
- 72px tall card with: source text, 32x32 item icon with quality border, item name, slot text, stats text
- Bottom area varies by `sourceType`:
  - `rep`: progress bar showing reputation progress (colored by standing), text "Honored - Need Revered" or checkmark
  - `drops`: "Dungeon Drop" label in blue
  - `crafted`: profession name in orange
- Mouse hover shows GameTooltip via `SetHyperlink("item:" .. itemId)` or fallback text tooltip
- Card border color matches item quality

**Data sources:**
- `C.CLASS_SPEC_LOOT_HOTLIST` - primary spec-based data
- `C.CLASS_LOOT_HOTLIST` - legacy class-only fallback
- `HopeAddon:GetPlayerSpec()` - current spec detection
- `HopeAddon:GetGearScoreText()` - gear score for header
- `Journal:GetFactionProgress(factionName)` - rep progress for bars
- `HopeAddon.Constants.ITEM_QUALITY_COLORS` - quality color lookup

---

### 3.9 Leveling Gear Card

**Function:** `CreateLevelingGearCard(parent, item, sourceType)`

**Purpose:** Renders a gear recommendation card for the leveling mode (levels 60-67). Shares the `journeyPools.lootCard` pool with `CreateLootCard()` but applies leveling-specific styling.

**Called by:** `PopulateJourneyLeveling()` when building dungeon drop and quest reward sections.

**Differences from `CreateLootCard()`:**

| Property | `CreateLootCard` (endgame) | `CreateLevelingGearCard` (leveling) |
|----------|---------------------------|-------------------------------------|
| Card height | 72px | 70px |
| Icon size | 32x32 | 36x36 |
| Icon border | 36x36 | 40x40 |
| Item name font | 10pt BODY | 11pt BODY |
| Slot/stats font | 8pt SMALL | 9pt SMALL |
| Progress bar | Shown (rep items) | Hidden |
| Source types | `rep` / `drops` / `crafted` | `dungeon` / quest |

**Key behavior:**
- Acquires from `journeyPools.lootCard` pool, same as endgame cards
- Explicitly sets leveling-specific sizes and fonts on the pooled frame (pool reset restores endgame defaults)
- Hides progress bar elements (`progressBg`, `progressFill`, `progressText`)
- Source text color: `FEL_GREEN` for dungeon drops, `GOLD_BRIGHT` for quest rewards
- Source format: dungeon shows `"BossName - DungeonName"`, quest shows `"Quest: QuestName (Zone)"`
- Tooltip uses `SetHyperlink("item:" .. itemId)` with fallback text tooltip

---

## 4. Progression System

### GetNextStep() Logic

`GetNextStep()` returns **one** step representing the player's highest-priority incomplete goal. It checks in strict order:

1. **Level < 58** → PRE_OUTLAND
2. **Karazhan attunement incomplete** → T4_ATTUNEMENT (counts completed chapters)
3. **Missing heroic keys** → HEROIC_KEYS (counts keys obtained, identifies worst faction)
4. **SSC or TK attunement incomplete** → T5_ATTUNEMENT (picks first incomplete)
5. **Hyjal or BT attunement incomplete** → T6_ATTUNEMENT (picks first incomplete)
6. **T6 raids not fully cleared** → RAID_PROGRESSION (identifies first uncleared raid)
7. **Everything done** → ENDGAME (100% complete)

Each returns a consistent `stepData` table (see Section 3.2).

### GetNextFocus() Logic

`GetNextFocus()` follows the same priority order as `GetNextStep()` but returns a **detailed checklist** instead of a summary. Key differences:

- Kara focus shows individual chapter names from `Attunements:GetChaptersForRaid("karazhan")`
- Heroic keys focus shows each key with faction name and obtained status
- T5 focus shows SSC and TK quest steps separately, prefixed with `[SSC]` / `[TK]`
- T6 focus shows specific boss kill requirements (Vashj, Kael'thas) and quest steps
- Raid progression focus shows per-raid clear status with boss counts
- Items are capped (e.g., max 4 Kara steps, max 3 SSC steps, max 5 total T5)

### Phase Colors and Names

Defined as local tables in Journal.lua:

| Phase Key | Color | Display Name |
|-----------|-------|-------------|
| PRE_OUTLAND | GOLD_BRIGHT | "The Journey Begins" |
| T4_ATTUNEMENT | FEL_GREEN | "Tier 4 Attunement" |
| HEROIC_KEYS | KARA_PURPLE | "Heroic Dungeon Keys" |
| T5_ATTUNEMENT | ARCANE_PURPLE | "Tier 5 Attunement" |
| T6_ATTUNEMENT | HELLFIRE_RED | "Tier 6 Attunement" |
| RAID_PROGRESSION | SKY_BLUE | "Raid Progression" |
| ENDGAME | GOLD_BRIGHT | "Legend of Outland" |

Colors reference named color keys in `HopeAddon.colors`.

### Boss Kill Tracking

- Stored in `HopeAddon.charDb.journal.bossKills` (table, keyed by boss ID → boolean)
- Boss lists per raid stored in Constants: `C.KARAZHAN_BOSSES`, `C.SSC_BOSSES`, etc.
- `GetTierStatus()` iterates boss lists and checks kills

### Attunement State Queries

All go through `HopeAddon.Attunements`:
- `Attunements:GetState(raidKey)` → returns `Attunements.STATE.COMPLETED` or other states
- `Attunements:GetProgress(raidKey)` → `{ completed, chapters = { [i] = { complete } } }`
- `Attunements:GetTotalChapters(raidKey)` → number
- `Attunements:GetChaptersForRaid(raidKey)` → `{ { name = "Step name" }, ... }`
- `Attunements:GetAttunementData(raidKey)` → full attunement definition

Raid keys: `"karazhan"`, `"ssc"`, `"tk"`, `"hyjal"`, `"bt"`

---

## 5. Loot Hotlist Data

### C.CLASS_SPEC_LOOT_HOTLIST Structure

**Location:** Constants.lua, search for `C.CLASS_SPEC_LOOT_HOTLIST`

**Coverage:** All 9 TBC classes (WARRIOR, PALADIN, HUNTER, ROGUE, PRIEST, SHAMAN, MAGE, WARLOCK, DRUID)

```lua
C.CLASS_SPEC_LOOT_HOTLIST = {
    ["WARRIOR"] = {
        [1] = {  -- Tab 1: Arms
            rep = { item, item, ... },
            drops = { item, item, ... },
            crafted = { item, item, ... },
        },
        [2] = {  -- Tab 2: Fury
            rep = { ... }, drops = { ... }, crafted = { ... },
        },
        [3] = {  -- Tab 3: Protection
            rep = { ... }, drops = { ... }, crafted = { ... },
        },
    },
    ["PALADIN"] = { ... },
    -- etc.
}
```

Keyed by `classToken` (uppercase string) → `specTab` (1-indexed talent tab number) → category.

### Item Data Shape

```lua
{
    -- Required fields
    itemId = 29119,                 -- WoW item ID (used for tooltip hyperlink)
    name = "Haramad's Bargain",     -- Display name
    icon = "INV_Jewelry_Necklace_30naxxramas",  -- Icon filename (no "Interface\\Icons\\" prefix)
    quality = "epic",               -- "common", "uncommon", "rare", "epic" (lookup in C.ITEM_QUALITY_COLORS)
    slot = "Neck",                  -- Equipment slot name
    stats = "+20 Agi, +24 Sta, +22 Hit",  -- Stats summary string
    source = "The Consortium @ Exalted",    -- Source description
    sourceType = "rep",             -- "rep" | "drops" | "crafted" | "badge"

    -- Rep-specific fields (sourceType == "rep")
    faction = "The Consortium",     -- Faction name (used in GetFactionProgress lookup)
    standing = 8,                   -- Required standing ID (7=Revered, 8=Exalted)

    -- Crafted-specific fields (sourceType == "crafted")
    profession = "Blacksmithing",   -- Profession name

    -- Optional hover data (rich tooltip, rep items)
    hoverData = {
        repSources = { "Farm method 1", "Farm method 2" },
        statPriority = { "Why this item is good" },
        tips = { "How to obtain faster" },
        alternatives = { "Alt item 1", "Alt item 2" },
        badgeSources = { "Badge source 1" },  -- for badge items
    },
}
```

### How Cards Are Rendered

Each `CreateLootCard()` creates a 72px-tall frame:

```
+------------------------------------------------------------+
| [Source Text - purple for rep, blue for drops, orange craft]|
| [32x32 icon] Item Name (quality colored)                   |
|              Slot Name                                      |
|              Stats text (green)                             |
| [======= rep progress bar =======] Standing / Required     |
+------------------------------------------------------------+
```

- Icon has a quality-colored glowing border (`UI-ActionButton-Border` with `SetVertexColor`)
- Card border color is quality-based (dimmed to 70%)
- Rep items show a 6px progress bar filled based on current standing progress
- Standing colors: Hated=red, Hostile=red, Unfriendly=orange, Neutral=yellow, Friendly=green, Honored=cyan, Revered=blue, Exalted=purple
- Non-rep items show a text label instead of a progress bar

### Rep Progress Bar Integration

For `sourceType == "rep"`:
1. `GetFactionProgress(factionName)` maps faction name to ID and iterates `GetFactionInfo` to find standing
2. Calculates `pct = (currentRep / maxRep) * 100` within current standing
3. If `standingId >= item.standing`, shows green checkmark instead
4. Progress bar fill width: `max(1, barWidth * (pct / 100))`

Supported factions in `GetFactionProgress()`:
- Cenarion Expedition, Honor Hold, Thrallmar, Lower City, The Sha'tar
- Keepers of Time, The Consortium, Sporeggar, The Aldor, The Scryers

---

## 6. Key Flows

### Flow 1: Tab Open

```
User clicks Journey tab
  → Journal:PopulateJourney()
    → UnitLevel("player") >= 68?
      → Journal:PopulateJourneyEndgame()
        → CreateNextEventCollapsibleSection()
        → CreateNextStepBox()
           → GetNextStep()
        → CreateFocusPanel()
           → GetNextFocus()
        → CreateJourneySummaryHeader()
        → CreateTierProgressSection()
           → GetTierStatus("T4"/"T5"/"T6")
        → CreateAttunementSummary()
           → GetAttunementSummary()
        → CreateHeroicKeysSummary()
        → CreateLootHotlist()
           → HopeAddon:GetPlayerSpec()
           → C.CLASS_SPEC_LOOT_HOTLIST[class][tab]
           → CreateLootCategorySection() * 3
           → CreateLootCard() * N
```

### Flow 2: Next Step Resolution

```
GetNextStep()
  1. Level < 58? → PRE_OUTLAND
  2. Attunements:GetProgress("karazhan")
     → not completed? → T4_ATTUNEMENT (count chapters)
  3. C.HEROIC_KEY_ORDER loop
     → GetFactionStanding() per key
     → missing keys? → HEROIC_KEYS (count, find worst)
  4. Attunements:GetProgress("ssc"/"tk")
     → either incomplete? → T5_ATTUNEMENT
  5. Attunements:GetProgress("hyjal"/"bt")
     → either incomplete? → T6_ATTUNEMENT
  6. GetTierStatus("T6")
     → not CLEARED? → RAID_PROGRESSION
  7. Default → ENDGAME (100% complete)
```

### Flow 3: Loot Card Render

```
CreateLootHotlist()
  → GetPlayerSpec() → specName, specTab
  → C.CLASS_SPEC_LOOT_HOTLIST[classToken][specTab]
     → { rep = [...], drops = [...], crafted = [...] }
  → For each category (rep, drops, crafted):
      → CreateLootCategorySection()
         → Collapsible frame with colored header
      → For each item:
          → CreateLootCard(section, item)               [pooled]
             → Set icon, name, slot, stats
             → sourceType == "rep"?
                → GetFactionProgress(item.faction)
                → Render progress bar with standing color
             → sourceType == "drops"?
                → Show "Dungeon Drop" label
             → sourceType == "crafted"?
                → Show profession label
             → Enable tooltip on hover (item hyperlink)
```

---

## 7. Constants & Data Sources

### Journey-Related Constants (Constants.lua)

| Constant | Purpose |
|----------|---------|
| `C.HEROIC_KEYS` | Heroic key definitions (5 keys with faction/standing data) |
| `C.HEROIC_KEY_ORDER` | Display order array |
| `C.CLASS_SPEC_LOOT_HOTLIST` | Spec-based loot recommendations (all 9 classes) |
| `C.CLASS_LOOT_HOTLIST` | Legacy class-only loot data (fallback) |
| `C.JOURNEY_NEXT_EVENT` | Event card dimensions `{ CONTAINER_HEIGHT=85, ICON_SIZE=36, BORDER_WIDTH=2 }` |
| `C.JOURNEY_UPCOMING_CARD` | Upcoming event card config |
| `C.APP_WIDE_EVENT_COLORS` | Color themes for event cards |
| `C.ITEM_QUALITY_COLORS` | Quality color lookup (common/uncommon/rare/epic) |
| `C.LEVELING_RANGES` | Level range definitions (used by leveling mode) |
| `C.LEVELING_ROLES` | Role info for leveling gear |

### Journey-Related Locals (Journal.lua)

| Variable | Purpose |
|----------|---------|
| `PHASE_COLORS` | Phase key → color name mapping |
| `PHASE_NAMES` | Phase key → display name mapping |
| `STANDING_THRESHOLDS` | Standing ID → rep required for next standing |
| `TIER_INFO` | Tier key → `{ name, color, raids[] }` |
| `RAID_NAMES` | Raid key → display name |
| `RAID_BOSS_COUNTS` | Raid key → boss count (informational, actual counts come from boss arrays) |
| `KEY_REPUTATIONS` | 7 reputation entries for rep summary (used by `GetKeyReputationSummary`) |
| `CONTAINER_WIDTH` | 485px (frame 550 - margins 40 - scrollbar 25) |

### Real-Time Data Sources

| Source | Access Pattern | Used By |
|--------|---------------|---------|
| Player level | `UnitLevel("player")` | `PopulateJourney`, `GetNextStep`, `GetNextFocus` |
| Player class | `UnitClass("player")` → classToken | `CreateLootHotlist`, `CreateJourneySummaryHeader` |
| Player spec | `HopeAddon:GetPlayerSpec()` → specName, specTab | `CreateLootHotlist` |
| Player faction | `UnitFactionGroup("player")` | `GetKeyReputationSummary`, `CreateHeroicKeysSummary`, `GetNextFocus` |
| Boss kills | `HopeAddon.charDb.journal.bossKills` | `GetTierStatus` |
| Attunement state | `HopeAddon.Attunements:GetState/GetProgress/GetChaptersForRaid` | `GetNextStep`, `GetNextFocus`, `GetTierStatus`, `GetAttunementSummary` |
| Reputation standing | `GetFactionInfo(i)` via `GetFactionStanding()` or `GetFactionProgress()` | Heroic keys, loot hotlist rep items |
| Gear score | `HopeAddon:GetGearScoreText()` | `CreateLootHotlist` header |
| Calendar events | `HopeAddon:GetModule("Calendar"):GetUpcomingEvents()` | `CreateNextEventCollapsibleSection` |
| App-wide events | `C:GetNextAppWideEvent()` | `CreateNextEventCollapsibleSection` |

### Tier Info Structures

```lua
-- Input: TIER_INFO (local in Journal.lua)
T4 = { name = "Tier 4", color = "UNCOMMON", raids = { "karazhan", "gruul", "magtheridon" } }
T5 = { name = "Tier 5", color = "RARE", raids = { "ssc", "tk" } }
T6 = { name = "Tier 6", color = "EPIC", raids = { "hyjal", "bt" } }

-- Output: GetTierStatus() return value
{
    status = "LOCKED" | "READY" | "IN_PROGRESS" | "CLEARED",
    bossesKilled = number,
    totalBosses = number,
    raids = {
        {
            key = "karazhan",
            name = "Karazhan",
            bossesKilled = 5,
            totalBosses = 11,
            attuned = true,
            attuneProgress = 7,
            attuneTotal = 7,
            cleared = false,
        },
        ...
    },
    color = "UNCOMMON",
    name = "Tier 4",
}
```
