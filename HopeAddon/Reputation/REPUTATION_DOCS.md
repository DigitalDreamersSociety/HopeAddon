# Reputation Tab - Component Reference

> **Audience:** AI assistants modifying reputation code.
> **Last updated:** 2026-03-01

---

## 1. Architecture Overview

The Reputation tab is a TBC faction tracking system built into the HopeAddon guild journal. It tracks standing progress across 18 Outland factions organized into 8 categories, creates narrative journal entries at milestone standings, displays spec-specific upgrade recommendations from reputation vendors, and shows visual progress via segmented reputation bars. The system spans ~2700 lines of Lua across four files plus a constants block.

### File Map

| File | Lines | Content |
|------|-------|---------|
| `Reputation/Reputation.lua` | 1-526 | Event handling, standing cache, milestone entries, notifications |
| `Reputation/ReputationData.lua` | 1-1177 | 18 faction definitions, 8 standings, 8 categories, lore/quips, rewards, hover data, helper functions |
| `Journal/Journal.lua` | 4888-5452 | Reputation tab UI: `PopulateReputation`, `CreateRecommendedUpgradesSection`, `CreateReputationCard`, `BuildFactionTooltip` |
| `Journal/Journal.lua` | 977-1296 | Reputation bar pool (`CreateReputationBarPool`, `AcquireReputationBar`) and loot pool (`CreateReputationLootPool`) |
| `Journal/Journal.lua` | 7370-7875 | Reputation loot popup: `GetReputationLootPopup`, `ShowReputationLootPopup`, item tracking functions |
| `Journal/Journal.lua` | 14782-14795 | Reputation loot state declarations (`reputationLootUI`, `reputationLootState`, `reputationLootPools`) |
| `Journal/Journal.lua` | 1619-1765 | `AcquireUpgradeCard` (shared pool for upgrade item cards) |
| `Core/Constants.lua` | 4900-6594 | `CLASS_SPEC_LOOT_HOTLIST` - per-class/spec reputation item recommendations |
| `Core/Constants.lua` | 8177-8212 | `C.REPUTATION_LOOT_POPUP` - loot popup dimensions, colors, backdrop |
| `UI/Components.lua` | 2574-2815 | `CreateSegmentedReputationBar` - 5-segment visual bar |

### Visual Layout

```
+--------------------------------------------------------------+
|  FACTION STANDING                                             |  <- Section Header
+--------------------------------------------------------------+
|  RECOMMENDED UPGRADES (Shadow)                                |  <- Spec-specific
|  +--- Upgrade Card -----------------------------------+       |
|  | [Icon] Haramad's Bargain    Neck  +20 Agi  BUY NOW|       |
|  |        The Consortium @ Exalted   [========] 72%   |       |
|  +----------------------------------------------------+       |
|  ... more upgrade cards ...                                   |
+--------------------------------------------------------------+
|  [Aldor/Scryer Choice Card - conditional]                     |
+--------------------------------------------------------------+
|  HELLFIRE CAMPAIGN                                            |  <- Category Header
|  +--- Faction Card (110px) ---------------------------+       |
|  | Honor Hold                              Honored    |       |
|  | "You get to use the good outhouse now"     45%     |       |
|  |                                          2 BiS     |       |
|  | [Neutral|Friendly|===Honored===|Revered|Exalted]   |       |
|  |                                    [Rep Items]     |       |
|  +----------------------------------------------------+       |
|  ... more faction cards ...                                   |
+--------------------------------------------------------------+
|  ZANGARMARSH                                                  |
|  ... more categories ...                                      |
+--------------------------------------------------------------+
```

---

## 2. Data Layer

### 2a. Standings (ReputationData.lua:15-27)

`Data.STANDINGS` - 8 standing levels with visual metadata:

| ID | Name | Color (r/g/b) | Hex | Threshold |
|----|------|---------------|-----|-----------|
| 1 | Hated | 0.8/0.0/0.0 | `CC0000` | -42000 |
| 2 | Hostile | 1.0/0.2/0.2 | `FF3333` | -6000 |
| 3 | Unfriendly | 1.0/0.5/0.0 | `FF8000` | -3000 |
| 4 | Neutral | 1.0/1.0/0.0 | `FFFF00` | 0 |
| 5 | Friendly | 0.0/0.8/0.0 | `00CC00` | 3000 |
| 6 | Honored | 0.0/0.6/0.8 | `0099CC` | 6000 |
| 7 | Revered | 0.0/0.4/0.8 | `0066CC` | 12000 |
| 8 | Exalted | 0.6/0.2/1.0 | `9933FF` | 21000 |

`Data.MILESTONE_STANDINGS = { 5, 6, 7, 8 }` - Only Friendly, Honored, Revered, and Exalted create journal entries.

### 2b. Categories (ReputationData.lua:33-82)

`Data.CATEGORIES` - 8 zone-based groupings keyed by string ID:

| Order | ID | Name | Icon |
|-------|----|------|------|
| 1 | `hellfire` | Hellfire Campaign | `INV_Misc_Platnumdisks` |
| 2 | `zangarmarsh` | Zangarmarsh | `INV_Mushroom_11` |
| 3 | `nagrand` | Nagrand | `INV_Misc_Herb_WhisperVine` |
| 4 | `shattrath` | City of Light | `INV_Jewelry_Ring_54` |
| 5 | `caverns` | Caverns of Time | `INV_Misc_PocketWatch_01` |
| 6 | `netherstorm` | Netherstorm | `INV_Elemental_Mote_Nether` |
| 7 | `raids` | Raid Factions | `INV_Misc_Key_14` |
| 8 | `special` | Special Factions | `INV_Misc_Gem_Variety_02` |

Each category has: `name`, `icon`, `description`, `order`.

### 2c. TBC Factions (ReputationData.lua:88-1042)

`Data.TBC_FACTIONS` - 18 factions keyed by name string:

| Faction | ID | Category | Side | Heroic Key | Special |
|---|---|---|---|---|---|
| Honor Hold | 946 | `hellfire` | Alliance | Flamewrought (Honored) | |
| Thrallmar | 947 | `hellfire` | Horde | Flamewrought (Honored) | |
| Cenarion Expedition | 942 | `zangarmarsh` | Both | Reservoir (Honored) | |
| Sporeggar | 970 | `zangarmarsh` | Both | - | |
| Kurenai | 978 | `nagrand` | Alliance | - | |
| The Mag'har | 941 | `nagrand` | Horde | - | |
| Lower City | 1011 | `shattrath` | Both | Auchenai (Honored) | |
| The Sha'tar | 935 | `shattrath` | Both | Warpforged (Honored) | |
| The Aldor | 932 | `shattrath` | Both | - | `isChoice`, opposing: The Scryers |
| The Scryers | 934 | `shattrath` | Both | - | `isChoice`, opposing: The Aldor |
| Keepers of Time | 989 | `caverns` | Both | Key of Time (Honored) | |
| The Consortium | 933 | `netherstorm` | Both | - | |
| The Violet Eye | 967 | `raids` | Both | - | |
| Ashtongue Deathsworn | 1012 | `raids` | Both | - | |
| Netherwing | 1015 | `special` | Both | - | |
| Ogri'la | 1038 | `special` | Both | - | |
| Sha'tari Skyguard | 1031 | `special` | Both | - | |
| Shattered Sun Offensive | 1077 | `special` | Both | - | |

**Faction data shape:**

```lua
{
    id          = number,       -- WoW faction ID (e.g. 946)
    category    = string,       -- Category key (e.g. "hellfire")
    icon        = string,       -- Icon texture name
    faction     = string,       -- "Alliance", "Horde", or "Both"
    description = string,       -- Short flavor text
    lore = {                    -- Standing-keyed narrative text
        [5] = string,           -- Friendly lore
        [6] = string,           -- Honored lore
        [7] = string,           -- Revered lore
        [8] = string,           -- Exalted lore
    },
    quips = {                   -- Standing-keyed humorous remarks
        [0] = string,           -- Not started yet
        [5] = string,           -- Friendly quip
        [6] = string,           -- Honored quip
        [7] = string,           -- Revered quip
        [8] = string,           -- Exalted quip
    },
    rewards = {                 -- Standing-keyed reward text (display only)
        [6] = string,           -- e.g. "Honored: Flamewrought Key (Heroic Hellfire Citadel)"
        [8] = string,           -- e.g. "Exalted: Honor Hold Tabard"
    },
    hoverData = {               -- Tooltip data
        repSources = { string, ... },       -- How to gain rep
        rewards = {                         -- Actual item data per standing
            [standingId] = { { itemId, name, icon }, ... },
        },
        tips = { string, ... },             -- Strategy tips
        prerequisites = { string, ... },    -- Requirements (optional)
    },
    -- Choice factions only (Aldor/Scryers):
    isChoice        = boolean,  -- true for Aldor and Scryers
    opposingFaction = string,   -- Name of the opposing faction
    choiceLore      = string,   -- Narrative text for the choice moment
}
```

### 2d. Helper Functions (ReputationData.lua:1044-1177)

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1046 | `FACTION_ID_MAP` | (auto-built) | Reverse lookup: faction ID -> faction name |
| 1051 | `GetFactionById` | `(factionId)` -> `data, name` | Faction ID -> faction data + name |
| 1060 | `IsFactionAvailable` | `(factionName)` -> `boolean` | Checks Alliance/Horde/Both against player faction |
| 1073 | `GetOrderedCategories` | `()` -> `{ {id, data}, ... }` | Categories sorted by `order` field |
| 1085 | `GetFactionsByCategory` | `(categoryId)` -> `{ {name, data}, ... }` | Factions in a category, filtered by player faction, sorted alphabetically |
| 1100 | `GetStandingInfo` | `(standingId)` -> `{ name, color, hex, threshold }` | Standing metadata |
| 1105 | `GetStandingColor` | `(standingId)` -> `r, g, b` | RGB color for a standing |
| 1114 | `IsMilestoneStanding` | `(standingId)` -> `boolean` | True if standing is 5, 6, 7, or 8 |
| 1127 | `GetRewardsAtStanding` | `(factionName, standingId)` -> `{ {itemId, name, icon}, ... }` or nil | Items available at a specific standing |
| 1138 | `GetAllRewards` | `(factionName)` -> `{ [standingId] = { items }, ... }` or nil | All rewards organized by standing |
| 1149 | `GetHoverData` | `(factionName)` -> `hoverData` or nil | Tooltip data (repSources, tips, rewards) |
| 1161 | `GetNextReward` | `(factionName, currentStandingId)` -> `standingId, items` or nil | Next standing that has rewards after current |

---

## 3. Per-Class/Spec Reputation Recommendations

### 3a. Structure: `C.CLASS_SPEC_LOOT_HOTLIST` (Constants.lua:4900-6594)

The hotlist provides per-spec gear recommendations displayed in the "RECOMMENDED UPGRADES" section of the Reputation tab. Indexed by class token and spec tab number.

```lua
C.CLASS_SPEC_LOOT_HOTLIST = {
    ["WARRIOR"] = {
        [1] = {   -- Tab 1: Arms
            rep = { ... },      -- Rep vendor items
            drops = { ... },    -- Dungeon/raid drops
            crafted = { ... },  -- Crafted items
        },
        [2] = { ... },  -- Tab 2: Fury
        [3] = { ... },  -- Tab 3: Protection
    },
    -- ... 9 classes
}
```

### 3b. Classes and Spec Tabs

| Class | Line | [1] | [2] | [3] | [4] |
|-------|------|-----|-----|-----|-----|
| WARRIOR | 4902 | Arms (Melee DPS) | Fury (Melee DPS) | Protection (Tank) | - |
| PALADIN | 5268 | Holy (Healer) | Protection (Tank) | Retribution (Melee DPS) | - |
| PRIEST | 5584 | Discipline (Healer) | Holy (Healer) | Shadow (Caster DPS) | - |
| DRUID | 5698 | Balance (Caster DPS) | Feral (Bear Tank) | Restoration (Healer) | Feral (Cat DPS) |
| SHAMAN | 5867 | Elemental (Caster DPS) | Enhancement (Melee DPS) | Restoration (Healer) | - |
| MAGE | 6006 | Arcane (Caster DPS) | Fire (Caster DPS) | Frost (Caster DPS) | - |
| WARLOCK | 6128 | Affliction (Caster DPS) | Demonology (Caster DPS) | Destruction (Caster DPS) | - |
| HUNTER | 6250 | Beast Mastery (Ranged DPS) | Marksmanship (Ranged DPS) | Survival (Ranged DPS) | - |
| ROGUE | 6400 | Assassination (Melee DPS) | Combat (Melee DPS) | Subtlety (Melee DPS) | - |

**Total:** 9 classes, 28 spec tabs (Druid has 4 tabs for separate Bear/Cat, all others have 3).

### 3c. Item Schema

Each entry in the `rep` array:

```lua
{
    itemId     = number,        -- WoW item ID
    name       = string,        -- "Haramad's Bargain"
    icon       = string,        -- Texture name
    quality    = string,        -- "epic", "rare", etc.
    slot       = string,        -- "Neck", "Trinket", "Ranged", etc.
    stats      = string,        -- "+20 Agi, +24 Sta, +22 Hit"
    source     = string,        -- "The Consortium @ Exalted" or "G'eras (41 Badges)"
    sourceType = string,        -- "rep", "badge", "drops", "crafted"
    -- Rep items only:
    faction    = string|nil,    -- "The Consortium" (nil for badge/drop items)
    standing   = number|nil,    -- 7 (Revered), 8 (Exalted)
    -- Optional detailed tooltip data:
    hoverData = {
        repSources   = { string, ... },  -- How to gain rep for this faction
        statPriority = { string, ... },  -- Why this item matters for the spec
        tips         = { string, ... },  -- Acquisition tips
        alternatives = { string, ... },  -- Alternative items
        -- Badge items use:
        badgeSources = { string, ... },  -- How to earn badges
    },
}
```

### 3d. Role-Based Faction Priority Summary

| Role | Priority Factions |
|------|-------------------|
| Tanks | Honor Hold/Thrallmar (Revered), Keepers of Time (Revered), The Sha'tar (Exalted) |
| Melee DPS | The Consortium (Exalted), Honor Hold/Thrallmar (Revered), Cenarion Expedition (Revered) |
| Caster DPS | Lower City (Revered), The Sha'tar (Exalted), Keepers of Time (Revered) |
| Healers | Lower City (Revered), The Sha'tar (Exalted), Honor Hold/Thrallmar (Revered) |

---

## 4. UI Components

### 4a. Reputation Tab Layout (Journal.lua:4888-4972)

**`PopulateReputation()`** - Main entry point, called when the Reputation tab is selected.

**Call flow:**

```
PopulateReputation()                             -- :4888
  -> EnsureBisLookupCurrent(guideKey, 1)         -- Pre-warm BiS cache for current spec
  -> CreateSectionHeader("FACTION STANDING")      -- Header
  -> CreateRecommendedUpgradesSection()           -- :4978 (spec-specific items)
  -> [if Aldor/Scryer choice + Honored]:
       CreateReputationCard({ isSpecial })        -- Choice card
  -> GetOrderedCategories()                       -- 8 categories sorted by order
  -> for each category:
       GetFactionsByCategory(catId)               -- Filtered by player faction
       CreateCategoryHeader(catName)              -- Category header
       for each faction:
         [skip opposing choice faction]
         CreateReputationCard({ name, data })     -- Faction card
```

### 4b. Recommended Upgrades Section (Journal.lua:4978-5078)

**`CreateRecommendedUpgradesSection()`** - Displays spec-specific rep items sorted by obtainability.

**Call flow:**

```
CreateRecommendedUpgradesSection()               -- :4978
  -> GetPlayerSpec() -> classToken, specTab
  -> CLASS_SPEC_LOOT_HOTLIST[classToken][specTab].rep
  -> for each item:
       GetFactionStanding(item.faction)           -- Current standing
       GetProgressInStanding(item.faction)        -- Current/max rep
       Calculate priority:
         0 = obtainable (standing >= required)
         1 = non-rep item (always available)
         N = distance from requirement
  -> Sort by priority (obtainable first, closest next)
  -> CreateCategoryHeader("RECOMMENDED UPGRADES (specName)")
  -> AcquireUpgradeCard(parent, item, factionProgress)  -- :1619
```

### 4c. Faction Card (Journal.lua:5085-5344)

**`CreateReputationCard(info)`** - Creates a card for a single faction.

**Card dimensions:** 110px regular factions, 85px special cards (e.g. "The Choice").

**Elements:**

| Element | Position | Content |
|---------|----------|---------|
| `title` | Top-left | Faction name |
| `description` | Below title | Quip text (standing-keyed humor) or description |
| `timestamp` (repurposed) | Top-right | Standing name (colored by standing) |
| `standingProgress` | Below standing | Progress percentage (e.g. "45%") |
| `bisBadge` | Below progress | BiS count (e.g. "2 BiS") - gold text, shown if > 0 |
| `trackedBadge` | Below BiS badge | Tracked count (e.g. "1 Tracked") - green text |
| `reputationBar` | Bottom, centered | Segmented reputation bar (80% of card width) |
| `repItemsBtn` | Bottom-right | "Rep Items" button (70x20, opens loot popup) |

**Border colors:**
- Gold (`1, 0.84, 0`) - default for regular factions
- Grey (`0.4, 0.4, 0.4`) - "not started" factions (standing <= 4 with no progress)
- Standing-colored - special cards

**Visual effects:**
- Golden pulsing glow for Exalted factions (`Effects:CreatePulsingGlow`)
- Border highlight on hover (white), restored on leave

**Click handlers:**
- `OnEnter` - Play hover sound, highlight border, show `BuildFactionTooltip`
- `OnLeave` - Restore border color, hide tooltip
- `OnMouseUp` (left) - Play click sound, open `ShowReputationLootPopup`
- `repItemsBtn OnClick` - Same as OnMouseUp (opens loot popup)

### 4d. Upgrade Card (Journal.lua:1619-1765)

**`AcquireUpgradeCard(parent, itemData, factionProgress)`** - Shared pool card for recommended items.

**Elements:**

| Element | Size/Position | Content |
|---------|---------------|---------|
| `icon` | 32x32, left | Item icon with quality-colored border |
| `nameText` | Right of icon | Item name (quality-colored) |
| `statsText` | Below name | Slot + stats string (grey) |
| `factionText` | Below stats | "Faction @ Standing" or source name |
| `statusBadge` | Right side | Status indicator |
| `progressBar` | Bottom, right of icon | Rep progress bar (rep items only) |
| `standingLabel` | Right of bar | Current standing name or source type label |

**Status badges:**

| Badge | Color | Condition |
|-------|-------|-----------|
| `BUY NOW` | Green | Rep item, standing >= required |
| `AVAILABLE` | Light blue | Non-rep item (badge/dungeon/crafted) |
| `72%` | Gold | Rep item, in progress (total rep percentage) |

**Sorting:** Obtainable items first (priority 0), then non-rep items (priority 1), then by proximity to required standing.

**Non-rep items** (`faction` is nil): Icon is full color, source type label replaces progress bar, no faction text. Source type labels: "Dungeon Drop", "Badge Vendor", "Crafted", "Quest Reward".

**Greyed out:** Icon desaturated + grey vertex color when not obtainable.

### 4e. Segmented Reputation Bar (Components.lua:2574-2815)

**`CreateSegmentedReputationBar(parent, width, height, options)`** - 5-segment visual bar showing Neutral through Exalted progress.

**Segment proportions** (based on rep required, total 42000):

| Segment | Standing | Rep | Width % |
|---------|----------|-----|---------|
| 1 | Neutral | 3000 | ~6.3% (of 88%) |
| 2 | Friendly | 6000 | ~12.5% (of 88%) |
| 3 | Honored | 12000 | ~25.1% (of 88%) |
| 4 | Revered | 21000 | ~44.0% (of 88%) |
| 5 | Exalted | endpoint | 12% (fixed) |

**Visual elements:**
- Dark background (`0.05, 0.05, 0.05`)
- Faded standing-colored segment backgrounds (30% brightness)
- Bright standing-colored fill textures (using `UI-StatusBar`)
- Dividers between segments (2px grey)
- Standing labels above each segment (8pt, highlighted to 9pt OUTLINE for current)
- Diamond progress marker (tracks total progress position)
- Border frame (tooltip-style)

**Border color changes:**
- Default: grey (`0.4, 0.4, 0.4`)
- Revered+: gold (`1, 0.84, 0`)
- Exalted: purple (`0.6, 0.2, 1.0`)

**Methods:**

| Method | Purpose |
|--------|---------|
| `SetProgress(standingId, current, max)` | Updates fill widths and marker position |
| `SetStandingHighlight(standingId)` | Highlights current standing label, updates border |
| `Cleanup()` | Resets all fills, labels, border, marker, and effects for pooling |

### 4f. Faction Tooltip (Journal.lua:5350-5452)

**`BuildFactionTooltip(factionName, factionData, currentStandingId, anchorFrame)`**

Builds a rich GameTooltip with 6 sections:

| Section | Header Color | Content |
|---------|-------------|---------|
| Title | Gold | Faction name |
| Standing | Standing-colored | Current standing name |
| Description | Grey | Faction description text |
| How to Gain Rep | Green (`0.4, 1, 0.4`) | `hoverData.repSources` list |
| Tips | Orange (`1, 0.5, 0`) | `hoverData.tips` list |
| Next Reward | Purple (`0.61, 0.19, 1.0`) | Next standing with rewards (if not Exalted) |
| BiS for Your Spec | Gold (`1, 0.84, 0`) | BiS items from lookup cache (green if obtainable, grey if not) |
| Requirements | Red (`0.9, 0.2, 0.1`) | `hoverData.prerequisites` list |

### 4g. Item Tracking System (Journal.lua:7812-7875)

Allows players to track specific reputation vendor items and set a goal item. Tracked items are shown as green badges on faction cards and gold stars in the loot popup.

**Functions:**

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 7812 | `ToggleReputationItemTracking` | `(itemId, factionName, standingId, itemName)` | Toggle tracking on/off for an item. Clears goal if tracked item is untracked |
| 7847 | `SetReputationGoalItem` | `(itemId, factionName, standingId, itemName)` | Toggle goal status. Auto-tracks item if not yet tracked |

**Tracked badge on faction card** (Journal.lua:5231-5259):
- Counts items in `charDb.reputation.trackedItems` matching the faction name
- Displays `"|cFF88FF88{N} Tracked|r"` in green below the BiS badge (or below standing progress if no BiS badge)
- Font: `SMALL` 9pt OUTLINE
- Hidden when `trackedCount == 0`

**Goal star in loot popup** (Journal.lua:1198-1204):
- Gold star icon (`Interface\COMMON\ReputationStar`) sized `C.TRACKED_STAR_SIZE` (14px)
- Positioned left of the standing badge
- Colored with `C.GOAL_COLOR` (`{ r = 1, g = 0.84, b = 0 }` - gold)
- Shown only for the item matching `charDb.reputation.goalItem.itemId`

**Tracking checkbox in loot popup** (Journal.lua:1164-1168):
- `UICheckButtonTemplate` sized `C.CHECKBOX_SIZE` (20px), leftmost element in each item row
- `OnClick` handler calls `ToggleReputationItemTracking()` then `RefreshReputationLootPopup()`
- Right-click on the row calls `SetReputationGoalItem()` then refreshes

**Saved data shape:**

```lua
charDb.reputation.trackedItems = {
    [itemId] = {
        factionName = "The Sha'tar",    -- Faction this item belongs to
        standingId = 7,                  -- Required standing (5=Friendly..8=Exalted)
        dateAdded = "Mar 01, 2026",      -- HopeAddon:GetDate() timestamp
    },
}
charDb.reputation.goalItem = {           -- nil if no goal set; only one goal at a time
    itemId = 29175,
    factionName = "The Sha'tar",
    standingId = 7,
}
```

### 4h. Reputation Loot Popup (Journal.lua:7370-7790)

A modal popup showing all faction vendor rewards organized by standing tier (Friendly -> Honored -> Revered -> Exalted) with item tracking checkboxes.

**Visual Layout:**

```
+----------------------------------------------+
| [Icon] FACTION NAME                      [X] |  <- Header (draggable, 50px)
|         Standing: Honored (4200/12000)        |
|----------------------------------------------|
| -- FRIENDLY (3 items) --                      |  <- Tier header (standing-colored)
| [x] [icon] Item Name        Available        |  <- Item row (40px, checkbox + icon + name + badge)
| [ ] [icon] Item Name        Available        |
| ...                                           |
| -- HONORED (2 items) --                       |
| [x] [icon] Item Name  [★]   Available        |  <- Goal star shown for goal item
| ...                                           |
|----------------------------------------------|
| Tracking: 2 items              Check to track |  <- Footer (32px)
+----------------------------------------------+
```

**Lifecycle functions:**

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 7378 | `GetReputationLootPopup` | `()` -> `popup` | Lazy singleton, creates popup on first call. Frame strata DIALOG, level 100 |
| 7563 | `ShowReputationLootPopup` | `(factionName, factionData)` | Release old frames, set header, populate tier-grouped items, position center, adjust height |
| 7549 | `HideReputationLootPopup` | `()` | Hide popup, clear state (popupVisible, currentFaction, currentData) |
| 7525 | `ReleaseReputationLootPopupFrames` | `()` | Release all pooled itemRows and tierHeaders back to pools |
| 7796 | `RefreshReputationLootPopup` | `()` | Re-calls ShowReputationLootPopup with current faction if visible |

**Popup frame elements** (created in GetReputationLootPopup):

| Element | Line | Details |
|---------|------|---------|
| Header (draggable) | 7402-7415 | EnableMouse, RegisterForDrag("LeftButton"), OnDragStart/OnDragStop |
| Faction icon | 7418-7422 | 32x32, left of title |
| Title text | 7425-7428 | GameFontNormalLarge |
| Standing text | 7431-7434 | GameFontNormalSmall, grey, below title |
| Close button | 7437-7446 | 20x20, MinimizeButton textures, calls HideReputationLootPopup |
| Header divider | 7449-7453 | 1px gold-brown line |
| Scroll frame | 7460-7468 | UIPanelScrollFrameTemplate, between header and footer |
| Footer divider | 7473-7477 | 1px gold-brown line |
| Tracked count | 7486-7489 | Left side of footer, green text ("Tracking: N items") |
| Hint text | 7492-7495 | Right side of footer, grey ("Check to track") |

**Event handlers:**

| Line | Event | Handler |
|------|-------|---------|
| 7506 | `OnHide` | Calls `ReleaseReputationLootPopupFrames()` |
| 7511 | `OnKeyDown` | ESC key -> `HideReputationLootPopup()` |
| 7516 | `SetPropagateKeyboardInput(true)` | Allows ESC to pass through |

**Population flow** (ShowReputationLootPopup:7563):

```
ShowReputationLootPopup(factionName, factionData)
  -> ReleaseReputationLootPopupFrames()              -- Clean up previous
  -> Update reputationLootState (faction, data, visible)
  -> Set header icon + title + standing text
  -> Data:GetAllRewards(factionName)                 -- Get all rewards
  -> Count trackedItemsForFaction from charDb
  -> for each tier in {5, 6, 7, 8}:                  -- Friendly -> Exalted
       [if tier has rewards]:
         tierHeader pool:Acquire()                   -- Standing-colored header
         for each item:
           itemRow pool:Acquire()
           GetItemInfo(itemId)                       -- Icon, quality, type
           Set name (with "[BiS]" prefix if applicable)
           Set standing badge ("Available" if obtainable, standing name if not)
           Check charDb.trackedItems -> checkbox state
           Check charDb.goalItem -> goal star visibility
           checkbox OnClick -> ToggleReputationItemTracking + Refresh
           row OnMouseUp(RightButton) -> SetReputationGoalItem + Refresh
  -> scrollContent:SetHeight(yOffset)
  -> Update footer tracked count text
  -> Position popup centered on screen
  -> Clamp height between MIN_HEIGHT and MAX_HEIGHT
```

### 4i. Reputation Bar & Loot Pool System (Journal.lua:977-1296)

Frame pools for reputation bars and loot popup elements, initialized during Journal:OnEnable (line 214-216).

**Pool initialization calls** (Journal.lua:210-216):

```lua
self:CreateReputationBarPool()    -- line 214
self:CreateBossLootPool()         -- line 215 (raids tab, not reputation)
self:CreateReputationLootPool()   -- line 216
```

**Reputation Bar Pool:**

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 977 | `CreateReputationBarPool` | `()` | Creates pool named "ReputationBars" using `Components:CreateSegmentedReputationBar` |
| 1006 | `AcquireReputationBar` | `(parent, width)` -> bar | Acquires bar from pool, sets parent and width |

- **Create function** (line 980): Creates a `CreateSegmentedReputationBar(UIParent, 300, 18)`, hides it
- **Reset function** (line 987): Calls `bar:Cleanup()` (resets visual state), hides, unparents, clears points
- **Pool name**: `"ReputationBars"` via `FramePool:NewNamed()`

**Reputation Loot Pool:**

| Line | Function | Purpose |
|------|----------|---------|
| 1149 | `CreateReputationLootPool` | Creates both `itemRow` and `tierHeader` pools |

**itemRow pool** (line 1154-1269):

Created as a `Button` with `BackdropTemplate`. Elements per row:

| Element | Size | Position | Details |
|---------|------|----------|---------|
| `highlight` | full row | AllPoints | ColorTexture, alpha 0 (0.3 on hover) |
| `checkbox` | `CHECKBOX_SIZE` (20px) | LEFT | UICheckButtonTemplate, tracking toggle |
| `icon` | `ICON_SIZE` (32px) | RIGHT of checkbox +6 | Item icon texture |
| `iconBorder` | ICON_SIZE+2 | CENTER of icon | ActionButton border, ADD blend |
| `nameText` | auto | TOPRIGHT of icon +8 | GameFontNormal, left-justified |
| `typeText` | auto | below nameText | GameFontNormalSmall, grey (0.6) |
| `standingBadge` | auto | RIGHT -8 | Standing requirement or "Available" |
| `goalStar` | `TRACKED_STAR_SIZE` (14px) | LEFT of standingBadge -4 | ReputationStar, gold, hidden by default |

Row event handlers:
- `OnEnter`: highlight alpha 0.3, play hover sound, show GameTooltip (SetHyperlink if itemId, else manual). Shows tracked/goal status and click hints
- `OnLeave`: reset highlight, hide tooltip

Reset function clears: highlight, icon, texts, checkbox, goalStar, all click handlers, all per-row state (`itemId`, `itemName`, `itemType`, `qualityColor`, `factionName`, `standingId`, `isTracked`, `isGoal`)

**tierHeader pool** (line 1272-1296):

Simple frame with:

| Element | Details |
|---------|---------|
| `divider` | 1px ColorTexture, gold-brown (0.4, 0.35, 0.25, 0.6) |
| `text` | GameFontNormalSmall, left-justified, standing-colored |

Height: `C.TIER_HEADER_HEIGHT` (24px). Format: `"-- HONORED (3 items) --"`

---

## 5. Event System (Reputation.lua)

### 5a. Module State (Reputation.lua:14-18)

```lua
Reputation.initialized = false           -- Set true in OnEnable() after setup
Reputation.cachedStandings = {}          -- { [factionName] = { standingId, earnedValue, factionId } }
Reputation.notificationPool = nil        -- FramePool for notification frames (created in OnEnable:28)
Reputation.pendingTimers = {}            -- Timer handle tracking for cleanup (cancelled in OnDisable:37-42)
```

**Journal-side state** (Journal.lua:14782-14795):

```lua
Journal.reputationLootUI = {
    popup = nil,               -- Singleton popup frame (lazy, created by GetReputationLootPopup:7378)
}
Journal.reputationLootState = {
    currentFaction = nil,      -- Currently displayed faction name
    currentData = nil,         -- Currently displayed faction data table
    popupVisible = false,      -- Whether loot popup is currently shown
}
Journal.reputationLootPools = {
    itemRow = nil,             -- Pooled item rows with tracking checkboxes (created by CreateReputationLootPool:1149)
    tierHeader = nil,          -- Pooled tier section headers (created by CreateReputationLootPool:1272)
}
```

### 5b. Initialization & Events (Reputation.lua:23-132)

**`OnEnable()`** (line 27):
1. `CreateNotificationPool()` - Frame pool with pre-created font strings
2. `RegisterEvents()` - Creates event frame, registers `UPDATE_FACTION` and `PLAYER_LOGIN`
3. `CacheCurrentStandings()` - Initial standing snapshot

**`OnDisable()`** (line 35):
1. Cancels all pending `Timer:After` handles
2. Unregisters all events and clears event frame
3. Destroys notification pool

**Registered events:**
- `UPDATE_FACTION` -> `OnFactionUpdate()`
- `PLAYER_LOGIN` -> `CacheCurrentStandings()` (delayed 2 seconds via Timer:After)

### 5c. Standing Cache (Reputation.lua:137-169)

**`CacheCurrentStandings()`** - Iterates all factions via `GetNumFactions()` / `GetFactionInfo(i)`.

For each non-header faction:
1. Looks up in `Data:GetFactionById(factionID)` to check if it's a tracked TBC faction
2. Caches in `self.cachedStandings[factionName]` = `{ standingId, earnedValue, factionId }`
3. Persists to `charDb.reputation.currentStandings[factionName]` = standingId

### 5d. Faction Update Handler (Reputation.lua:174-209)

**`OnFactionUpdate()`** - Called on every `UPDATE_FACTION` event.

For each TBC faction found in the WoW API:
1. **Standing increase detection:** If `standingId > cached.standingId` -> `OnStandingIncreased()`
2. **Aldor/Scryer choice detection:** If `isChoice` faction reaches Friendly (standingId >= 5) for the first time -> `OnAldorScryerChoice()`
3. **Cache update:** Updates both in-memory cache and charDb

### 5e. Standing Increased Handler (Reputation.lua:214-223)

**`OnStandingIncreased(factionName, factionData, oldStanding, newStanding)`**

Iterates from `oldStanding + 1` to `newStanding`, checking each via `IsMilestoneStanding()`. Creates a milestone entry for each milestone reached (handles multi-level jumps).

### 5f. Milestone Journal Entries (Reputation.lua:228-281)

**`CreateMilestoneEntry(factionName, factionData, standingId)`**

Creates a journal entry:

```lua
{
    type        = "reputation_milestone",
    faction     = factionName,
    factionId   = factionData.id,
    standing    = standingId,
    standingName = standingInfo.name,
    title       = "Honor Hold - Honored",
    description = loreText .. reward text,
    story       = loreText,
    icon        = "Interface\\Icons\\" .. factionData.icon,
    zone        = GetZoneText(),
    timestamp   = HopeAddon:GetTimestamp(),
    date        = HopeAddon:GetDate(),
    category    = factionData.category,
    reward      = factionData.rewards[standingId],  -- if applicable
}
```

**Side effects:**
1. Saves to `charDb.reputation.milestones[factionName][standingId]`
2. Appends to `charDb.journal.entries`
3. Shows notification (`ShowReputationNotification`)
4. Plays sound (`PlayMilestoneSound`)
5. Prints colored chat message
6. Notifies Badges module (`Badges:OnReputationChanged`)

### 5g. Aldor/Scryer Choice (Reputation.lua:286-328)

**`OnAldorScryerChoice(factionName, factionData)`**

Records the choice once (no-ops if already recorded):

```lua
charDb.reputation.aldorScryerChoice = {
    chosen    = "The Aldor",
    opposing  = "The Scryers",
    date      = HopeAddon:GetDate(),
    timestamp = HopeAddon:GetTimestamp(),
}
```

Creates journal entry with `type = "faction_choice"`, shows dramatic notification, plays epic fanfare, prints chat message.

### 5h. Sound Effects (Reputation.lua:333-345)

**`PlayMilestoneSound(standingId)`**

| Standing | Sound |
|----------|-------|
| 5 (Friendly) | `Sounds:Play("reputation", "friendly")` |
| 6 (Honored) | `Sounds:Play("reputation", "honored")` |
| 7 (Revered) | `Sounds:Play("reputation", "revered")` |
| 8 (Exalted) | `Sounds:PlayEpicFanfare()` |

### 5i. Notifications (Reputation.lua:351-478)

Uses `FramePool` named "ReputationNotifications" to avoid frame leaks. Each notification frame has pre-created font strings (`titleText`, `line1`, `line2`, `line3`).

**Regular milestone notification** (`ShowReputationNotification`, line 351):
- Size: 380x110
- Border: Standing-colored
- Background: `PURPLE_TINT`
- Content: "REPUTATION: HONORED" title, faction name, lore quote
- Display time: 4 seconds (6 for Exalted)
- Exalted extras: border glow (ARCANE_PURPLE), sparkles (GOLD_BRIGHT, 10 particles), burst effect
- Animation: `NotificationSlideIn` -> delay -> `NotificationSlideOut` -> release to pool

**Aldor/Scryer choice notification** (`ShowChoiceNotification`, line 416):
- Size: 420x140
- Border: Gold (`1, 0.84, 0`)
- Background: `PURPLE_DARK`
- Content: "A FATEFUL CHOICE" title (20pt), chosen faction name, lore quote, opposing faction warning
- Display time: 7 seconds
- Effects: border glow (GOLD_BRIGHT), sparkles (ARCANE_PURPLE, 12 particles), burst
- Animation: same slide pattern

### 5j. Helper Functions (Reputation.lua:483-525)

| Line | Function | Purpose |
|------|----------|---------|
| 483 | `GetFactionStanding(factionName)` | Returns cached standing data for a faction |
| 487 | `GetProgressInStanding(factionName)` | Queries WoW API for current/max rep within standing |
| 508 | `IsTBCFaction(factionId)` | Checks if a faction ID is in the TBC faction map |
| 513 | `HasReachedMilestone(factionName, standingId)` | Checks charDb milestones |
| 518 | `GetAldorScryerChoice()` | Returns stored Aldor/Scryer choice data |

---

## 6. Saved Data Schema

```lua
charDb.reputation = {
    milestones = {
        -- [factionName] = { [standingId] = journalEntry }
        ["Honor Hold"] = {
            [5] = { type="reputation_milestone", ... },
            [6] = { type="reputation_milestone", ... },
        },
    },
    aldorScryerChoice = {       -- nil until choice is made
        chosen    = "The Aldor",
        opposing  = "The Scryers",
        date      = "Feb 15, 2026",
        timestamp = 1739600000,
    },
    currentStandings = {
        -- [factionName] = standingId (persisted in CacheCurrentStandings:137)
        ["Honor Hold"] = 6,
        ["The Sha'tar"] = 5,
    },
    trackedItems = {
        -- [itemId] = trackData  (managed by ToggleReputationItemTracking:7812)
        [29175] = {
            factionName = "The Sha'tar",     -- Faction this item belongs to
            standingId = 7,                   -- Required standing (5-8)
            dateAdded = "Mar 01, 2026",       -- HopeAddon:GetDate() at time of tracking
        },
        [29176] = {
            factionName = "The Sha'tar",
            standingId = 8,
            dateAdded = "Mar 01, 2026",
        },
    },
    goalItem = {                -- nil if no goal set (managed by SetReputationGoalItem:7847)
        itemId = 29175,          -- Single goal item at a time (toggle on/off)
        factionName = "The Sha'tar",
        standingId = 7,
    },
}
```

**Schema notes:**
- `trackedItems` is initialized lazily (`charDb.reputation.trackedItems = charDb.reputation.trackedItems or {}`) on first access
- Untracking an item that is also the `goalItem` automatically clears the goal (ToggleReputationItemTracking:7826-7828)
- Setting a goal item auto-tracks it if not already tracked (SetReputationGoalItem:7854-7861)

---

## 7. Key Data Flows

### Flow 1: Tab Display

```
1. PopulateReputation()                          -- Journal.lua:4888
2.   EnsureBisLookupCurrent(guideKey, 1)         -- Warm BiS cache
3.   CreateSectionHeader("FACTION STANDING")
4.   CreateRecommendedUpgradesSection()           -- :4978
5.     GetPlayerSpec() -> classToken, specTab
6.     CLASS_SPEC_LOOT_HOTLIST[classToken][specTab].rep
7.     for each item:
8.       GetFactionStanding(item.faction)          -- Reputation.lua:483
9.       GetProgressInStanding(item.faction)        -- :487
10.      Calculate priority (obtainable=0, distance)
11.    Sort by priority
12.    AcquireUpgradeCard() x N                    -- :1619
13.  [if aldorScryerChoice + Honored]:
14.    CreateReputationCard({ isSpecial })
15.  GetOrderedCategories()                        -- ReputationData.lua:1073
16.  for each category:
17.    GetFactionsByCategory(catId)                 -- :1085
18.    CreateCategoryHeader(catName)
19.    for each faction:
20.      CreateReputationCard({ name, data })       -- Journal.lua:5085
21.        GetFactionStanding(name)
22.        GetStandingColor(standingId)
23.        GetBisItemsForFaction(name)              -- BiS count badge
24.        AcquireReputationBar(card, width)         -- Components.lua:2574
25.          SetProgress(standingId, current, max)
26.          SetStandingHighlight(standingId)
```

### Flow 2: Standing Change (Event-Driven)

```
1. WoW fires UPDATE_FACTION event
2. OnFactionUpdate()                              -- Reputation.lua:174
3.   GetFactionInfo(i) for all factions
4.   GetFactionById(factionID)                     -- ReputationData.lua:1051
5.   [if standingId > cached]:
6.     OnStandingIncreased(name, data, old, new)   -- :214
7.       for each milestone in range:
8.         IsMilestoneStanding(standingId)          -- :1114
9.         CreateMilestoneEntry(name, data, id)     -- :228
10.          Create journal entry
11.          Save to charDb.reputation.milestones
12.          Append to charDb.journal.entries
13.          ShowReputationNotification()           -- :351
14.            notificationPool:Acquire()
15.            Configure notification frame
16.            [if Exalted]: glow + sparkles + burst
17.            NotificationSlideIn -> Timer:After -> NotificationSlideOut -> Release
18.          PlayMilestoneSound(standingId)         -- :333
19.          Print to chat
20.          Badges:OnReputationChanged()
21.  [if isChoice + first Friendly]:
22.    OnAldorScryerChoice(name, data)              -- :286
23.      Record choice in charDb
24.      Create "faction_choice" journal entry
25.      ShowChoiceNotification()                   -- :416
26.      PlayEpicFanfare()
27.  Update cache
```

### Flow 3: Loot Popup Interaction

```
1. User clicks faction card (OnMouseUp) or "Rep Items" btn   -- Journal.lua:5330-5331
2.   ShowReputationLootPopup(factionName, factionData)         -- :7563
3.     GetReputationLootPopup()                                -- :7378 (lazy singleton)
4.     ReleaseReputationLootPopupFrames()                      -- :7525
5.     Update reputationLootState (faction, data, visible)
6.     Set header: icon, title, standing text with color
7.     Data:GetAllRewards(factionName)                         -- ReputationData.lua:1138
8.     Count trackedItemsForFaction from charDb
9.     for tier in {5, 6, 7, 8}:  (Friendly -> Exalted)
10.      tierHeader = reputationLootPools.tierHeader:Acquire()
11.      for each item in tier:
12.        row = reputationLootPools.itemRow:Acquire()
13.        GetItemInfo(itemId) -> icon, quality, type
14.        Set checkbox state from charDb.trackedItems
15.        Set goalStar from charDb.goalItem
16.    scrollContent:SetHeight(totalYOffset)
17.    Update footer text
18.    Position centered, clamp height (MIN_HEIGHT..MAX_HEIGHT)
19.  [User checks checkbox]:
20.    ToggleReputationItemTracking(itemId, ...)               -- :7812
21.    RefreshReputationLootPopup()                            -- :7796
22.  [User right-clicks row]:
23.    SetReputationGoalItem(itemId, ...)                      -- :7847
24.    RefreshReputationLootPopup()
25.  [User clicks close or presses ESC]:
26.    HideReputationLootPopup()                               -- :7549
27.      popup:Hide() -> OnHide -> ReleaseReputationLootPopupFrames()
28.      Clear state (popupVisible, currentFaction, currentData)
```

---

## 8. Modification Guide

### Add a new faction

1. **ReputationData.lua** `Data.TBC_FACTIONS`: Add entry with `id`, `category`, `icon`, `faction`, `description`, `lore`, `quips`, `rewards`, `hoverData`
2. **ReputationData.lua** (optional): Add new category in `Data.CATEGORIES` if needed
3. The `FACTION_ID_MAP` auto-builds on load, so no manual update needed

### Add spec rep items

1. **Constants.lua** `C.CLASS_SPEC_LOOT_HOTLIST[CLASS][specTab].rep`: Add item entry with `itemId`, `name`, `icon`, `quality`, `slot`, `stats`, `source`, `sourceType`, `faction`, `standing`, `hoverData`
2. Non-rep items (badge/dungeon): Omit `faction` and `standing` fields

### Change standing colors

1. **ReputationData.lua** `Data.STANDINGS[standingId]`: Modify `color` (r/g/b) and `hex` fields
2. Colors propagate automatically to bars, badges, notifications, and tooltips

### Add rewards to a faction

1. **ReputationData.lua** `TBC_FACTIONS[name].rewards[standingId]`: Add display text string
2. **ReputationData.lua** `TBC_FACTIONS[name].hoverData.rewards[standingId]`: Add `{ itemId, name, icon }` entries

### Change notification behavior

1. **Reputation.lua** `ShowReputationNotification()` (line 351): Modify size, timing, effects
2. Display time: line 407 (`isExalted and 6 or 4`)
3. Choice notification: `ShowChoiceNotification()` (line 416), 7-second display

### Add a new milestone standing

1. **ReputationData.lua** `Data.MILESTONE_STANDINGS`: Add standing ID to the array
2. **ReputationData.lua** `TBC_FACTIONS[name].lore[standingId]`: Add lore text for new standing
3. **ReputationData.lua** `TBC_FACTIONS[name].quips[standingId]`: Add quip text
4. **Reputation.lua** `PlayMilestoneSound()` (line 333): Add sound for new standing

---

## 9. Constants Reference (Constants.lua:8177-8212)

`C.REPUTATION_LOOT_POPUP` - All dimensions, colors, and styling for the reputation loot popup:

### Dimensions

| Constant | Value | Purpose |
|----------|-------|---------|
| `WIDTH` | 400 | Popup frame width |
| `MIN_HEIGHT` | 250 | Minimum popup height (clamped) |
| `MAX_HEIGHT` | 500 | Maximum popup height (clamped) |
| `HEADER_HEIGHT` | 50 | Header area height |
| `TIER_HEADER_HEIGHT` | 24 | Standing tier divider height |
| `FOOTER_HEIGHT` | 32 | Footer area height |
| `PADDING` | 12 | Internal padding |
| `ROW_HEIGHT` | 40 | Item row height |
| `ROW_GAP` | 3 | Gap between item rows |
| `ICON_SIZE` | 32 | Item icon size |
| `CHECKBOX_SIZE` | 20 | Tracking checkbox size |
| `TRACKED_STAR_SIZE` | 14 | Goal star indicator size |

### Colors

| Constant | Value | Purpose |
|----------|-------|---------|
| `GOAL_COLOR` | `{ r=1, g=0.84, b=0 }` | Gold color for goal item star |
| `BG_COLOR` | `{ r=0.08, g=0.06, b=0.04, a=0.95 }` | Dark backdrop background |
| `BORDER_COLOR` | `{ r=0.8, g=0.7, b=0.3, a=1 }` | Gold-brown border |

### Quality Colors

| Quality | Key | RGB | Color |
|---------|-----|-----|-------|
| Poor | `[0]` | 0.62/0.62/0.62 | Grey |
| Common | `[1]` | 1.0/1.0/1.0 | White |
| Uncommon | `[2]` | 0.12/1.0/0.0 | Green |
| Rare | `[3]` | 0.0/0.44/0.87 | Blue |
| Epic | `[4]` | 0.64/0.21/0.93 | Purple |
| Legendary | `[5]` | 1.0/0.5/0.0 | Orange |

### Backdrop

```lua
BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
```

---

## Appendix: Function Count Summary

| Subsystem | Functions |
|-----------|-----------|
| **Reputation.lua** | |
| Initialization | 3 (OnInitialize, OnEnable, OnDisable) |
| Notification Pool | 2 (CreateNotificationPool, ReleaseNotification) |
| Events | 1 (RegisterEvents) |
| Cache | 1 (CacheCurrentStandings) |
| Update Handlers | 3 (OnFactionUpdate, OnStandingIncreased, OnAldorScryerChoice) |
| Milestone | 1 (CreateMilestoneEntry) |
| Sound | 1 (PlayMilestoneSound) |
| Notifications | 2 (ShowReputationNotification, ShowChoiceNotification) |
| Helpers | 5 (GetFactionStanding, GetProgressInStanding, IsTBCFaction, HasReachedMilestone, GetAldorScryerChoice) |
| **Reputation.lua subtotal** | **19** |
| **ReputationData.lua** | |
| Data Tables | 4 (STANDINGS, MILESTONE_STANDINGS, CATEGORIES, TBC_FACTIONS) |
| Helpers | 11 (GetFactionById, IsFactionAvailable, GetOrderedCategories, GetFactionsByCategory, GetStandingInfo, GetStandingColor, IsMilestoneStanding, GetRewardsAtStanding, GetAllRewards, GetHoverData, GetNextReward) |
| **ReputationData.lua subtotal** | **11 functions + 4 tables** |
| **Journal.lua (Reputation UI)** | |
| Tab Population | 2 (PopulateReputation, CreateRecommendedUpgradesSection) |
| Card Creation | 2 (CreateReputationCard, AcquireUpgradeCard) |
| Tooltip | 1 (BuildFactionTooltip) |
| Loot Popup | 5 (GetReputationLootPopup, ShowReputationLootPopup, HideReputationLootPopup, ReleaseReputationLootPopupFrames, RefreshReputationLootPopup) |
| Item Tracking | 2 (ToggleReputationItemTracking, SetReputationGoalItem) |
| Pools | 3 (CreateReputationBarPool, AcquireReputationBar, CreateReputationLootPool) |
| **Journal.lua subtotal** | **15** |
| **Components.lua** | |
| Bar | 1 (CreateSegmentedReputationBar) + 3 methods |
| **Components.lua subtotal** | **1 + 3 methods** |
| **Grand total** | **46 functions + 3 methods + 4 tables** |
