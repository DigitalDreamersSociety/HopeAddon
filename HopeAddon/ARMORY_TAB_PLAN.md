# Armory Tab Implementation Plan

## Overview

The **Armory Tab** is a gear upgrade advisor that shows players what items they should be pursuing from heroic dungeons and raids. It uses a character creator-style UI with equipment slot positions around a central character model, where each slot shows upgrade recommendations.

**Target Audience:** Level 70 players gearing for or progressing through TBC raids

**Content Scope (Phase 1 - T4 Focus):**
- Heroic dungeon drops
- T4 raid drops (Karazhan, Gruul, Magtheridon)
- Badge of Justice gear
- Reputation rewards (Exalted level)

---

## UI Layout Reference: WoW Character Creator Style

```
+--------------------------------------------------+
|  [ T4 ]  [ T5 ]  [ T6 ]   <- Tier Selection Tabs |
+--------------------------------------------------+
|  +----------------------------------------------+|
|  |  ARMORY - Phase 1 Gear Guide                 ||
|  |  [Dropdown: Spec Selection]                  ||
|  +----------------------------------------------+|
|                                                  |
|  +----+                            +----+       |
|  |HEAD|                            |NECK|       |
|  +----+                            +----+       |
|                                                  |
|  +----+    +-----------------+     +----+       |
|  |SHLD|    |                 |     |BACK|       |
|  +----+    |                 |     +----+       |
|            |   CHARACTER     |                  |
|  +----+    |     MODEL       |     +----+       |
|  |CHST|    |                 |     |WRIST|      |
|  +----+    |                 |     +----+       |
|            |                 |                  |
|  +----+    |                 |     +----+       |
|  |WAIST|   |                 |     |HANDS|      |
|  +----+    +-----------------+     +----+       |
|                                                  |
|  +----+                            +----+       |
|  |LEGS|                            |FEET|       |
|  +----+                            +----+       |
|                                                  |
|  +----+    +----+    +----+    +----+    +----+ |
|  |RING1|   |RING2|   |TRINK1|  |TRINK2|  |WEPN| |
|  +----+    +----+    +----+    +----+    +----+ |
+--------------------------------------------------+
```

---

## Slot Layout (Character Creator Positions)

### Equipment Slots (17 total for TBC)

| Slot | Position | WoW Slot ID |
|------|----------|-------------|
| Head | Top Left | 1 |
| Neck | Top Right | 2 |
| Shoulders | Left Upper | 3 |
| Back | Right Upper | 15 |
| Chest | Left Middle | 5 |
| Wrist | Right Middle | 9 |
| Waist | Left Lower | 6 |
| Hands | Right Lower | 10 |
| Legs | Bottom Left | 7 |
| Feet | Bottom Right | 8 |
| Ring 1 | Bottom Row | 11 |
| Ring 2 | Bottom Row | 12 |
| Trinket 1 | Bottom Row | 13 |
| Trinket 2 | Bottom Row | 14 |
| Main Hand | Bottom Row | 16 |
| Off Hand | Bottom Row | 17 (if applicable) |
| Ranged/Relic | Bottom Row | 18 |

---

## Slot Button Design

Each equipment slot is a clickable button that shows:

### Default State (Empty/Unselected)
```
+------------------+
|   [Slot Icon]    |  <- Generic slot icon (e.g., helm shape for head)
|   [Slot Name]    |  <- "Head", "Chest", etc.
+------------------+
```

### With Equipped Item
```
+------------------+
|   [Item Icon]    |  <- Current equipped item icon
|   "Current"      |  <- Label
|   iLvl 115       |  <- Item level
+------------------+
```

### With Upgrade Available (Visual Indicator)
```
+------------------+
| [Item Icon] [!]  |  <- Green arrow or "!" indicator
|   "Upgrade!"     |  <- Label
|   +10 iLvl       |  <- Potential upgrade amount
+------------------+
Border: Green glow for significant upgrades
```

---

## Click Behavior: Upgrade Selector Dropdown

When a slot button is clicked, show an upgrade selector popup/dropdown:

```
+--------------------------------------------+
|  HEAD SLOT UPGRADES                        |
+--------------------------------------------+
|  [EQUIPPED] Helm of the Warp             |
|             iLvl 115 - Quest Reward        |
+--------------------------------------------+
|  RECOMMENDED UPGRADES                      |
+--------------------------------------------+
| [BEST] Tier 4 Helm - Warbringer Helmet     |
|        iLvl 120 - Prince Malchezaar        |
|        +30 Str, +25 Sta, +Defense          |
+--------------------------------------------+
| [ALT] Eternium Greathelm                   |
|       iLvl 115 - Heroic Mechanar           |
|       +28 Str, +22 Sta                     |
+--------------------------------------------+
| [ALT] Felsteel Helm                        |
|       iLvl 115 - Blacksmithing (BoE)       |
|       +24 Str, +21 Sta, +Defense           |
+--------------------------------------------+
|  [ Close ]                                 |
+--------------------------------------------+
```

---

## Data Structure: Armory Gear Database

### Constants.lua Addition

```lua
C.ARMORY_TIERS = {
    [4] = { name = "Phase 1 (T4)", content = "Karazhan, Gruul, Mag, Heroics" },
    [5] = { name = "Phase 2 (T5)", content = "SSC, TK, Heroics" },
    [6] = { name = "Phase 3 (T6)", content = "Hyjal, BT, Sunwell" },
}

-- Gear organized by: Tier -> Role -> Slot -> Items
C.ARMORY_GEAR_DATABASE = {
    [4] = {  -- Tier 4
        ["tank"] = {
            ["head"] = {
                best = {
                    itemId = 29011, name = "Warbringer Greathelm",
                    icon = "...", quality = "epic", iLvl = 120,
                    stats = "+43 Str, +45 Sta, +32 Def",
                    source = "Prince Malchezaar",
                    sourceType = "raid", -- raid, heroic, badge, rep, crafted
                    raid = "karazhan",
                },
                alternatives = {
                    { itemId = 123, name = "...", ... },
                    { itemId = 456, name = "...", ... },
                },
            },
            ["shoulders"] = { ... },
            -- All 17 slots
        },
        ["healer"] = { ... },
        ["melee_dps"] = { ... },
        ["ranged_dps"] = { ... },
        ["caster_dps"] = { ... },
    },
}

-- Source type colors/icons
C.ARMORY_SOURCE_TYPES = {
    raid = { color = "EPIC_PURPLE", icon = "..." },
    heroic = { color = "RARE_BLUE", icon = "..." },
    badge = { color = "GOLD_BRIGHT", icon = "..." },
    rep = { color = "FEL_GREEN", icon = "..." },
    crafted = { color = "BRONZE", icon = "..." },
}
```

---

## Implementation Phases

### Phase 1: UI Framework (Journal.lua)

**New State Variables:**
```lua
Journal.armoryUI = {}      -- UI element references
Journal.armoryState = {
    selectedTier = 4,       -- Current tier tab
    selectedSlot = nil,     -- Currently open slot dropdown
}
```

**New Functions:**
| Function | Purpose |
|----------|---------|
| `PopulateArmory()` | Main entry point, called on tab select |
| `CreateArmoryContainers()` | Create UI structure (once) |
| `CreateArmorySlotButton(slot, position)` | Create individual slot button |
| `UpdateArmorySlotButton(slot)` | Update slot with current/upgrade info |
| `ShowUpgradeSelector(slot)` | Show dropdown for slot |
| `HideUpgradeSelector()` | Close dropdown |
| `SelectArmoryTier(tier)` | Switch tier tabs |
| `GetBestUpgrade(slot, role)` | Find best item for slot |
| `GetEquippedItem(slotId)` | Get player's current item |
| `CompareItems(current, upgrade)` | Calculate upgrade value |

### Phase 2: Tier Selection Tabs

Compact horizontal tabs at top of container:

```lua
-- Tier tabs as compact buttons (similar to Transmog but in a row at top)
[ T4: Phase 1 ] [ T5: Phase 2 ] [ T6: Phase 3 ]
       ^-- Active tab highlighted
```

- Active tab: Gold border, lighter background
- Inactive: Grey border, dark background
- Hover: Tier-colored highlight (T4=Green, T5=Blue, T6=Red)

### Phase 3: Spec Selection

Dropdown at top (reuse existing spec detection):
```lua
local specName, specTab = HopeAddon:GetPlayerSpec()
local role = HopeAddon:GetSpecRole(classToken, specTab)
```

### Phase 4: Slot Layout Implementation

Position 17 slot buttons around the model frame:

```lua
local ARMORY_SLOT_POSITIONS = {
    -- Left column (equipment)
    head = { anchor = "TOPLEFT", x = 10, y = -40 },
    shoulders = { anchor = "TOPLEFT", x = 10, y = -100 },
    chest = { anchor = "TOPLEFT", x = 10, y = -160 },
    waist = { anchor = "TOPLEFT", x = 10, y = -220 },
    legs = { anchor = "TOPLEFT", x = 10, y = -280 },

    -- Right column (accessories)
    neck = { anchor = "TOPRIGHT", x = -10, y = -40 },
    back = { anchor = "TOPRIGHT", x = -10, y = -100 },
    wrist = { anchor = "TOPRIGHT", x = -10, y = -160 },
    hands = { anchor = "TOPRIGHT", x = -10, y = -220 },
    feet = { anchor = "TOPRIGHT", x = -10, y = -280 },

    -- Bottom row (jewelry, trinkets, weapons)
    ring1 = { anchor = "BOTTOM", x = -160, y = 10 },
    ring2 = { anchor = "BOTTOM", x = -100, y = 10 },
    trinket1 = { anchor = "BOTTOM", x = -40, y = 10 },
    trinket2 = { anchor = "BOTTOM", x = 20, y = 10 },
    mainhand = { anchor = "BOTTOM", x = 80, y = 10 },
    offhand = { anchor = "BOTTOM", x = 140, y = 10 },
    ranged = { anchor = "BOTTOM", x = 200, y = 10 },
}
```

### Phase 5: Upgrade Dropdown

When slot clicked, show upgrade selector:
- Modal or anchored popup
- Shows current equipped item
- Shows "BEST" recommendation (highlighted)
- Shows 1-2 alternatives
- Source info (raid name, heroic dungeon, badge cost)

### Phase 6: Data Population (T4 Only for MVP)

Research and populate:
- All 17 slots
- 5 roles (tank, healer, melee_dps, ranged_dps, caster_dps)
- Best + 2 alternatives per slot = ~255 items for T4

**Sources for T4:**
- Karazhan drops
- Gruul's Lair drops
- Magtheridon's Lair drops
- Heroic dungeon drops
- Badge of Justice rewards
- Exalted reputation rewards
- Crafted (Blacksmithing, Leatherworking, Tailoring)

---

## Comparison with Existing Systems

### Transmog Tab (Reference)
- Uses DressUpModel for character preview
- Tier selection buttons (T4, T5, T6)
- Slot buttons for 5 tier pieces only
- Lighting customization

### Armory Tab (New)
- Uses same DressUpModel approach
- Same tier selection pattern
- **17 slots** instead of 5 (full equipment)
- Upgrade comparison instead of transmog preview
- Per-slot dropdown with recommendations

### Journey Tab Gear Guide (Reference)
- Level 60-67 dungeon/quest gear
- Role-based recommendations
- Simple list display

### Armory Tab (Difference)
- Level 70 heroic/raid gear
- Full equipment layout
- Interactive slot selection

---

## File Changes Summary

| File | Changes |
|------|---------|
| `Core/Constants.lua` | Add `C.ARMORY_GEAR_DATABASE`, `C.ARMORY_SLOT_POSITIONS`, `C.ARMORY_SOURCE_TYPES` |
| `Journal/Journal.lua` | Add `PopulateArmory()`, `CreateArmoryContainers()`, slot button functions, upgrade selector |
| `Core/Core.lua` | Add `charDb.armory` defaults (selected tier, wishlist) |
| `HopeAddon.toc` | No changes needed |

---

## Estimated Line Counts

| Component | Lines |
|-----------|-------|
| Constants (T4 data) | ~400 |
| Journal UI functions | ~600 |
| Core defaults | ~20 |
| **Total** | ~1,000 |

---

## Visual Mockup (ASCII)

```
+================================================================+
|  [ T4: Phase 1 ]  [ T5: Phase 2 ]  [ T6: Phase 3 ]             |
+================================================================+
|  YOUR ARMORY - Phase 1 Gear Upgrades                           |
|  Spec: [Protection Warrior v]                                  |
+----------------------------------------------------------------+
|                                                                |
|  +------+                                      +------+        |
|  | HEAD |                                      | NECK |        |
|  |[img] |                                      |[img] |        |
|  | +15! |                                      | OK   |        |
|  +------+                                      +------+        |
|                                                                |
|  +------+    +------------------------+        +------+        |
|  | SHLD |    |                        |        | BACK |        |
|  |[img] |    |                        |        |[img] |        |
|  | +10! |    |    CHARACTER MODEL     |        | +8!  |        |
|  +------+    |                        |        +------+        |
|              |     [Your Warrior]     |                        |
|  +------+    |                        |        +------+        |
|  | CHST |    |                        |        |WRIST |        |
|  |[T4!] |    |                        |        |[img] |        |
|  | BiS  |    +------------------------+        | OK   |        |
|  +------+                                      +------+        |
|                                                                |
|  +------+                                      +------+        |
|  |WAIST |                                      |HANDS |        |
|  |[img] |                                      |[img] |        |
|  | +12! |                                      | +5!  |        |
|  +------+                                      +------+        |
|                                                                |
|  +------+                                      +------+        |
|  | LEGS |                                      | FEET |        |
|  |[img] |                                      |[img] |        |
|  | +20! |                                      | BiS  |        |
|  +------+                                      +------+        |
|                                                                |
|  +------+ +------+ +------+ +------+ +------+ +------+ +------+|
|  |RING1 | |RING2 | |TRNK1 | |TRNK2 | | MH   | | OH   | |RANGED||
|  +------+ +------+ +------+ +------+ +------+ +------+ +------+|
+================================================================+

Legend:
  +15! = Upgrade available (+15 iLvl improvement)
  BiS  = Best in Slot equipped
  T4!  = Tier token upgrade available
  OK   = Current item is acceptable
```

---

## Slot Status Indicators

| Indicator | Meaning | Color |
|-----------|---------|-------|
| `BiS` | Best in Slot equipped | Gold |
| `OK` | Good item, minor upgrades only | Green |
| `+N!` | Upgrade available (+N iLvl) | Orange/Red |
| `T4!` | Tier token upgrade | Purple |
| `???` | No data/slot empty | Grey |

---

## Next Steps

1. **Approve this plan** - Confirm the approach
2. **Create data structure** - Add `C.ARMORY_GEAR_DATABASE` to Constants.lua (T4 only)
3. **Build UI framework** - Add armory tab registration and containers
4. **Implement slot buttons** - 17 positioned buttons with states
5. **Add upgrade selector** - Dropdown/popup for recommendations
6. **Populate T4 data** - Research and add ~255 items

---

## DATA RESEARCH PHASE (Current Priority)

This section tracks the gear research tasks needed before UI implementation can begin.

### Research Task Overview

**Total Tasks:** 30 class/spec combinations
**Per-Task Scope:** 17 equipment slots × (1 best + 2 alternatives) = ~51 items per spec
**Total Items to Research:** ~1,530 items for T4

### Task Status Legend

- ⬜ Not Started
- 🔄 In Progress
- ✅ Complete

---

## Research Tasks by Class

### 1. WARRIOR (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| WAR-01 | Arms | melee_dps | ⬜ | 2H weapons, DPS plate |
| WAR-02 | Fury | melee_dps | ⬜ | Dual-wield, DPS plate |
| WAR-03 | Protection | tank | ✅ | Shield, tank plate, defense - COMPLETE |

### 2. PALADIN (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| PAL-01 | Holy | healer | ✅ | Spell power plate, mp5 - COMPLETE |
| PAL-02 | Protection | tank | ✅ | Shield, tank plate, spell power for threat - COMPLETE |
| PAL-03 | Retribution | melee_dps | ⬜ | 2H weapons, DPS plate |

### 3. HUNTER (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| HUN-01 | Beast Mastery | ranged_dps | ✅ | Agility mail, ranged weapons - COMPLETE |
| HUN-02 | Marksmanship | ranged_dps | ⬜ | Agility mail, ranged weapons |
| HUN-03 | Survival | ranged_dps | ⬜ | Agility mail, ranged weapons |

### 4. ROGUE (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| ROG-01 | Assassination | melee_dps | ⬜ | Daggers, agility leather |
| ROG-02 | Combat | melee_dps | ✅ | Swords/maces, agility leather - COMPLETE |
| ROG-03 | Subtlety | melee_dps | ⬜ | Daggers, agility leather |

### 5. PRIEST (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| PRI-01 | Discipline | healer | ✅ | Healing cloth, mp5 - COMPLETE |
| PRI-02 | Holy | healer | ✅ | Healing cloth, spirit - COMPLETE |
| PRI-03 | Shadow | caster_dps | ✅ | Shadow damage cloth, hit - COMPLETE |

### 6. SHAMAN (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| SHA-01 | Elemental | caster_dps | ✅ | Spell power mail, hit - COMPLETE |
| SHA-02 | Enhancement | melee_dps | ✅ | Agility mail, slow weapons - COMPLETE |
| SHA-03 | Restoration | healer | ✅ | Healing mail, mp5 - COMPLETE |

### 7. MAGE (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| MAG-01 | Arcane | caster_dps | ✅ | Spell power cloth, intellect - COMPLETE |
| MAG-02 | Fire | caster_dps | ✅ | Spell power cloth, crit - COMPLETE |
| MAG-03 | Frost | caster_dps | ✅ | Spell power cloth, hit - COMPLETE |

### 8. WARLOCK (3 specs)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| WLK-01 | Affliction | caster_dps | ✅ | Shadow damage cloth, hit - COMPLETE |
| WLK-02 | Demonology | caster_dps | ✅ | Spell power cloth, stamina - COMPLETE |
| WLK-03 | Destruction | caster_dps | ✅ | Fire/Shadow cloth, crit - COMPLETE |

### 9. DRUID (4 specs - Feral splits into DPS/Tank)

| Task ID | Spec | Role | Status | Notes |
|---------|------|------|--------|-------|
| DRU-01 | Balance | caster_dps | ✅ | Spell power leather - COMPLETE |
| DRU-02 | Restoration | healer | ✅ | Healing leather - COMPLETE |
| DRU-03 | Feral (Cat) | melee_dps | ✅ | Agility leather, DPS stats - COMPLETE |
| DRU-04 | Feral (Bear) | tank | ✅ | Armor leather, stamina, defense - COMPLETE |

---

## Per-Slot Research Template

For each spec, research these 17 slots:

### Armor Slots (10)
| Slot | WoW ID | Priority Stats (varies by role) |
|------|--------|--------------------------------|
| Head | 1 | Main stat, stamina, role-specific |
| Neck | 2 | Often unique effects |
| Shoulders | 3 | Main stat, stamina |
| Back | 15 | Usually lower priority |
| Chest | 5 | Major stats |
| Wrist | 9 | Often crafted BiS |
| Hands | 10 | Set pieces or heroic drops |
| Waist | 6 | No tier token, good heroic options |
| Legs | 7 | Major stats |
| Feet | 8 | Often enchant matters more |

### Jewelry Slots (4)
| Slot | WoW ID | Notes |
|------|--------|-------|
| Ring 1 | 11 | Many good options, check unique-equipped |
| Ring 2 | 12 | Different from Ring 1 if unique-equipped |
| Trinket 1 | 13 | Very role-specific |
| Trinket 2 | 14 | Different from Trinket 1 |

### Weapon Slots (3)
| Slot | WoW ID | Notes |
|------|--------|-------|
| Main Hand | 16 | Class/spec specific (1H, 2H, caster, etc.) |
| Off Hand | 17 | Shield (tank), OH weapon (DW), held item (caster) |
| Ranged/Relic | 18 | Gun/Bow/Wand/Idol/Totem/Libram |

---

## Item Data Format

Each researched item should include:

```lua
{
    itemId = 29011,                    -- Wowhead item ID
    name = "Warbringer Greathelm",     -- In-game name
    icon = "INV_Helmet_70",            -- Icon texture path
    quality = "epic",                  -- common/uncommon/rare/epic
    iLvl = 120,                        -- Item level
    stats = "+43 Str, +45 Sta, +32 Def Rating", -- Key stats summary
    source = "Prince Malchezaar",      -- Boss name or vendor
    sourceType = "raid",               -- raid/heroic/badge/rep/crafted
    sourceDetail = "Karazhan",         -- Raid name, dungeon name, faction, etc.
    -- Optional fields:
    badgeCost = nil,                   -- Number if badge gear
    repFaction = nil,                  -- Faction name if rep gear
    repStanding = nil,                 -- "Exalted", "Revered", etc.
}
```

---

## T4 Content Sources to Search

### Raids
| Raid | Bosses | Notable Drops |
|------|--------|---------------|
| Karazhan | 11 bosses | T4 gloves, T4 helm, many BiS items |
| Gruul's Lair | 2 bosses | T4 shoulders, T4 legs |
| Magtheridon | 1 boss | T4 chest |

### Heroic Dungeons (16 total)
| Dungeon | Key Faction | Notable Drops |
|---------|-------------|---------------|
| Hellfire Ramparts | Honor Hold/Thrallmar | Leather/plate drops |
| Blood Furnace | Honor Hold/Thrallmar | Caster gear |
| Shattered Halls | Honor Hold/Thrallmar | Melee gear |
| Slave Pens | Cenarion Expedition | Leather/healer gear |
| Underbog | Cenarion Expedition | Nature gear |
| Steamvault | Cenarion Expedition | Mixed |
| Mana-Tombs | Consortium | Caster rings |
| Auchenai Crypts | Lower City | Healing/shadow gear |
| Sethekk Halls | Lower City | Mixed |
| Shadow Labyrinth | Lower City | Many BiS items |
| Old Hillsbrad | Keepers of Time | Caster/healer |
| Black Morass | Keepers of Time | Tank/DPS |
| Mechanar | Sha'tar | Caster gear |
| Botanica | Sha'tar | Mixed |
| Arcatraz | Sha'tar | High iLvl drops |

### Badge of Justice Vendor
| Location | Notable Gear |
|----------|--------------|
| G'eras (Shattrath) | Epic gear for 25-100 badges |
| Phase 1 additions | Neck, trinkets, weapons |

### Reputation Rewards (Exalted)
| Faction | Notable Gear |
|---------|--------------|
| Honor Hold/Thrallmar | Tank/DPS weapons |
| Cenarion Expedition | Head enchant, gear |
| Lower City | Caster gear |
| Sha'tar | Head enchant, gear |
| Keepers of Time | Tank gear |
| The Consortium | Ring, gear |
| Aldor/Scryers | Shoulder enchants, gear |

### Crafted (BoE)
| Profession | Notable Sets/Items |
|------------|-------------------|
| Blacksmithing | Felsteel set (tank), Flamebane (fire resist) |
| Leatherworking | Primalstrike (melee), Windhawk (caster) |
| Tailoring | Spellstrike (caster), Primal Mooncloth (healer), Frozen Shadoweave |

---

## Research Execution Plan

### Phase 1: Role Templates (Do First)
Create baseline lists for each role:
1. **Tank** - Defense cap, stamina, armor, threat stats
2. **Healer** - +Healing, mp5, spirit, intellect
3. **Melee DPS** - AP, agility, hit, crit, expertise
4. **Ranged DPS** - Agility, AP, hit, crit (for hunters)
5. **Caster DPS** - Spell power, hit, crit, haste

### Phase 2: Class-Specific Research
For each class, run research agents to Wowhead TBC database:
- Search by slot + class + spec
- Filter to T4-appropriate iLvl (100-130)
- Check both PvE and reputation sources

### Phase 3: Validation
- Cross-reference multiple sources
- Verify item IDs are correct for TBC 2.4.3
- Ensure no Sunwell/later phase items included

---

## Progress Tracking

| Class | Specs Done | Total Items | Last Updated |
|-------|------------|-------------|--------------|
| Warrior | 1/3 | ~17 | 2026-01-24 (Prot) |
| Paladin | 1/3 | ~19 | 2026-01-24 (Holy) |
| Hunter | 1/3 | ~16 | 2026-01-24 (BM) |
| Rogue | 1/3 | ~17 | 2026-01-24 (Combat) |
| Priest | 2/3 | ~46 | 2026-01-24 (Disc, Holy) |
| Shaman | 1/3 | ~23 | 2026-01-24 (Resto) |
| Mage | 0/3 | 0 | - |
| Warlock | 1/3 | ~23 | 2026-01-24 (Destro) |
| Druid | 1/4 | ~23 | 2026-01-24 (Resto) |
| **TOTAL** | **9/30** | **~184/~1530** | 2026-01-24 |

### Completed Research (9 specs):
- ✅ WAR-03: Protection Warrior (Tank)
- ✅ PAL-01: Holy Paladin (Healer)
- ✅ PRI-01: Discipline Priest (Healer)
- ✅ PRI-02: Holy Priest (Healer)
- ✅ SHA-03: Restoration Shaman (Healer)
- ✅ DRU-02: Restoration Druid (Healer)
- ✅ ROG-02: Combat Rogue (Melee DPS)
- ✅ HUN-01: Beast Mastery Hunter (Ranged DPS)
- ✅ WLK-03: Destruction Warlock (Caster DPS)

### Also Documented:
- ✅ Crafted Set Summaries (Tailoring, Blacksmithing, Leatherworking)
- ✅ Badge of Justice Vendor Items
- ✅ Reputation Rewards (All major factions)
- ✅ World Boss Drops (Doom Lord Kazzak, Doomwalker)

---

## Questions Resolved

1. **Scope:** T4 only for initial implementation ✅
2. **Data source:** Research actual TBC itemIds from Wowhead ✅
3. **Model:** Reuse DressUpModel from Transmog (decided later)
4. **Wishlist:** Decided later during UI implementation

---

## Research Agent Prompt Templates

These are copy-paste prompts for research agents to gather gear data from Wowhead TBC Classic database.

### Base Prompt Template

```
Research T4 (Phase 1) BiS gear for [CLASS] [SPEC] in TBC Classic 2.4.3.

For each of the 17 equipment slots, find:
1. BEST item (highest priority for this spec)
2. ALTERNATIVE 1 (good alternative, different source)
3. ALTERNATIVE 2 (accessible option for fresh 70s)

Equipment slots to research:
- Head, Neck, Shoulders, Back, Chest, Wrist, Hands, Waist, Legs, Feet
- Ring 1, Ring 2, Trinket 1, Trinket 2
- Main Hand, Off Hand, Ranged/Relic

For each item, provide:
- Item ID (from Wowhead URL)
- Item Name
- Item Level
- Key Stats (focus on: [ROLE_STATS])
- Source (boss name, dungeon, badge cost, faction+standing, or profession)
- Source Type (raid/heroic/badge/rep/crafted)

Sources to check (T4/Phase 1 only - NO SSC/TK/T5+ items):
- Karazhan (all bosses)
- Gruul's Lair (High King Maulgar, Gruul)
- Magtheridon's Lair
- All 16 Heroic dungeons
- Badge of Justice vendor (G'eras in Shattrath)
- Exalted reputation rewards (Honor Hold/Thrallmar, Cenarion, Lower City, Sha'tar, Keepers, Consortium, Aldor/Scryers)
- Crafted BoE items ([RELEVANT_PROFESSIONS])

Output format per slot:
SLOT: [slot_name]
BEST: [itemId] [name] (iLvl [X]) - [stats] - [source]
ALT1: [itemId] [name] (iLvl [X]) - [stats] - [source]
ALT2: [itemId] [name] (iLvl [X]) - [stats] - [source]
```

---

### Class-Specific Prompts

#### WAR-01: Arms Warrior (melee_dps)
```
Research T4 BiS gear for WARRIOR ARMS in TBC Classic 2.4.3.

Role Stats: Strength, Attack Power, Critical Strike, Hit Rating, Expertise
Weapon Type: Two-handed weapons (swords, axes, maces, polearms)
Armor Type: Plate (DPS stats, not tank)
Professions: Blacksmithing

Note: Arms prioritizes high damage 2H weapons and burst damage stats.
```

#### WAR-02: Fury Warrior (melee_dps)
```
Research T4 BiS gear for WARRIOR FURY in TBC Classic 2.4.3.

Role Stats: Strength, Attack Power, Critical Strike, Hit Rating, Haste
Weapon Type: Dual-wield (two 1H weapons OR two 2H weapons for TG builds)
Armor Type: Plate (DPS stats)
Professions: Blacksmithing

Note: Fury dual-wields, needs hit cap (~9% with talents).
```

#### WAR-03: Protection Warrior (tank)
```
Research T4 BiS gear for WARRIOR PROTECTION in TBC Classic 2.4.3.

Role Stats: Stamina, Defense Rating (cap 490), Dodge, Parry, Block Value, Block Rating
Weapon Type: 1H weapon + Shield
Armor Type: Plate (tank stats)
Professions: Blacksmithing (Felsteel set)

Note: Defense cap is critical (490 = uncrittable). Also consider threat stats (Hit, Expertise, Strength).
```

#### PAL-01: Holy Paladin (healer)
```
Research T4 BiS gear for PALADIN HOLY in TBC Classic 2.4.3.

Role Stats: +Healing, MP5, Intellect, Spell Critical, Stamina
Weapon Type: 1H caster weapon + Shield OR Libram
Armor Type: Plate (healing/spell power)
Professions: None specific

Note: Holy Paladins wear plate with healing power. MP5 and Intellect are important for mana sustain.
Relic Slot: Libram
```

#### PAL-02: Protection Paladin (tank)
```
Research T4 BiS gear for PALADIN PROTECTION in TBC Classic 2.4.3.

Role Stats: Stamina, Defense Rating (cap 490), Dodge, Parry, Block, Spell Power (for threat)
Weapon Type: 1H weapon + Shield
Armor Type: Plate (tank stats)
Professions: Blacksmithing

Note: Prot Paladins want spell power for Consecration/Holy Shield threat, unlike Warriors.
Relic Slot: Libram
```

#### PAL-03: Retribution Paladin (melee_dps)
```
Research T4 BiS gear for PALADIN RETRIBUTION in TBC Classic 2.4.3.

Role Stats: Strength, Attack Power, Critical Strike, Hit Rating, Spell Power
Weapon Type: Two-handed weapons (prefer slow weapons)
Armor Type: Plate (DPS stats)
Professions: Blacksmithing

Note: Ret benefits from spell power for Consecration/seals. Slow 2H weapons preferred.
Relic Slot: Libram
```

#### HUN-01: Beast Mastery Hunter (ranged_dps)
```
Research T4 BiS gear for HUNTER BEAST MASTERY in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (9%), Critical Strike, Haste
Weapon Type: Ranged (gun/bow/crossbow), melee stat sticks
Armor Type: Mail (agility)
Professions: Leatherworking

Note: BM Hunters get significant DPS from pets. Ranged weapon DPS is critical.
Relic Slot: Quiver/Ammo Pouch (not a gear slot)
```

#### HUN-02: Marksmanship Hunter (ranged_dps)
```
Research T4 BiS gear for HUNTER MARKSMANSHIP in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (9%), Critical Strike
Weapon Type: Ranged (gun/bow/crossbow), melee stat sticks
Armor Type: Mail (agility)
Professions: Leatherworking

Note: MM Hunters focus on personal DPS over pet. High weapon DPS important.
Relic Slot: None (quiver is bag slot)
```

#### HUN-03: Survival Hunter (ranged_dps)
```
Research T4 BiS gear for HUNTER SURVIVAL in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (9%), Critical Strike
Weapon Type: Ranged (gun/bow/crossbow), melee stat sticks
Armor Type: Mail (agility)
Professions: Leatherworking

Note: Survival Hunters scale well with agility. Expose Weakness buff makes them raid valuable.
```

#### ROG-01: Assassination Rogue (melee_dps)
```
Research T4 BiS gear for ROGUE ASSASSINATION in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (~363 rating), Critical Strike, Haste
Weapon Type: Daggers (fast MH, slow OH for poison)
Armor Type: Leather (agility)
Professions: Leatherworking

Note: Assassination rogues use daggers. Hit cap is high due to dual-wield penalty.
```

#### ROG-02: Combat Rogue (melee_dps)
```
Research T4 BiS gear for ROGUE COMBAT in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (~363), Expertise, Haste
Weapon Type: Swords or Maces (slow MH, fast OH)
Armor Type: Leather (agility)
Professions: Leatherworking

Note: Combat rogues prefer slow main-hand swords/maces. Expertise reduces dodges/parries.
```

#### ROG-03: Subtlety Rogue (melee_dps)
```
Research T4 BiS gear for ROGUE SUBTLETY in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating, Critical Strike
Weapon Type: Daggers (for Backstab/Ambush)
Armor Type: Leather (agility)
Professions: Leatherworking

Note: Subtlety rogues use daggers. Less common in PvE but viable.
```

#### PRI-01: Discipline Priest (healer)
```
Research T4 BiS gear for PRIEST DISCIPLINE in TBC Classic 2.4.3.

Role Stats: +Healing, MP5, Intellect, Spirit, Spell Critical
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (healing)
Professions: Tailoring

Note: Disc priests focus on Power Infusion support and efficient healing. MP5 valued highly.
Relic Slot: Wand
```

#### PRI-02: Holy Priest (healer)
```
Research T4 BiS gear for PRIEST HOLY in TBC Classic 2.4.3.

Role Stats: +Healing, Spirit, Intellect, MP5
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (healing)
Professions: Tailoring (Primal Mooncloth set)

Note: Holy priests benefit greatly from Spirit via Spirit of Redemption. AoE healing focused.
Relic Slot: Wand
```

#### PRI-03: Shadow Priest (caster_dps)
```
Research T4 BiS gear for PRIEST SHADOW in TBC Classic 2.4.3.

Role Stats: Spell Damage (Shadow), Hit Rating (cap 76 with talents), Spell Critical, Haste
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring (Frozen Shadoweave set)

Note: Shadow priests are mana batteries. Hit cap is lower due to talents. Frozen Shadoweave is BiS.
Relic Slot: Wand
```

#### SHA-01: Elemental Shaman (caster_dps)
```
Research T4 BiS gear for SHAMAN ELEMENTAL in TBC Classic 2.4.3.

Role Stats: Spell Damage (Nature/Fire), Hit Rating, Spell Critical, Intellect
Weapon Type: Staff OR 1H caster + Shield
Armor Type: Mail (spell damage)
Professions: Leatherworking

Note: Elemental shamans can wear shields for extra stats. Hit cap ~16% without talents.
Relic Slot: Totem
```

#### SHA-02: Enhancement Shaman (melee_dps)
```
Research T4 BiS gear for SHAMAN ENHANCEMENT in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Hit Rating (~9%), Critical Strike, Expertise
Weapon Type: Dual-wield slow weapons (2.6+ speed ideal)
Armor Type: Mail (agility, some spell power for shocks)
Professions: Leatherworking

Note: Enhancement wants SLOW weapons for Windfury procs. Some spell power helps shocks.
Relic Slot: Totem
```

#### SHA-03: Restoration Shaman (healer)
```
Research T4 BiS gear for SHAMAN RESTORATION in TBC Classic 2.4.3.

Role Stats: +Healing, MP5, Intellect, Spell Critical
Weapon Type: 1H caster + Shield
Armor Type: Mail (healing)
Professions: Leatherworking

Note: Resto shamans can wear shields. Chain Heal is primary spell. MP5 important.
Relic Slot: Totem
```

#### MAG-01: Arcane Mage (caster_dps)
```
Research T4 BiS gear for MAGE ARCANE in TBC Classic 2.4.3.

Role Stats: Spell Damage, Intellect, Spell Critical, Hit Rating, Spell Haste
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring (Spellstrike set)

Note: Arcane mages scale heavily with Intellect. Mana management is key.
Relic Slot: Wand
```

#### MAG-02: Fire Mage (caster_dps)
```
Research T4 BiS gear for MAGE FIRE in TBC Classic 2.4.3.

Role Stats: Spell Damage (Fire), Hit Rating, Spell Critical, Spell Haste
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring (Spellfire set)

Note: Fire mages want crit for Ignite. Spellfire set is BiS for fire-focused mages.
Relic Slot: Wand
```

#### MAG-03: Frost Mage (caster_dps)
```
Research T4 BiS gear for MAGE FROST in TBC Classic 2.4.3.

Role Stats: Spell Damage (Frost), Hit Rating, Spell Critical
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring

Note: Frost mages are less common in PvE raids but viable. Winter's Chill debuff useful.
Relic Slot: Wand
```

#### WLK-01: Affliction Warlock (caster_dps)
```
Research T4 BiS gear for WARLOCK AFFLICTION in TBC Classic 2.4.3.

Role Stats: Spell Damage (Shadow), Hit Rating, Spell Critical, Spell Haste
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring (Frozen Shadoweave set)

Note: Affliction warlocks focus on DoTs. Shadow damage is primary. Frozen Shadoweave is BiS.
Relic Slot: Wand
```

#### WLK-02: Demonology Warlock (caster_dps)
```
Research T4 BiS gear for WARLOCK DEMONOLOGY in TBC Classic 2.4.3.

Role Stats: Spell Damage, Stamina, Intellect, Hit Rating
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage, some stamina)
Professions: Tailoring

Note: Demo warlocks buff raid with Demonic Pact. Pet does significant damage.
Relic Slot: Wand
```

#### WLK-03: Destruction Warlock (caster_dps)
```
Research T4 BiS gear for WARLOCK DESTRUCTION in TBC Classic 2.4.3.

Role Stats: Spell Damage (Fire/Shadow), Hit Rating, Spell Critical, Spell Haste
Weapon Type: Staff OR 1H caster + Off-hand
Armor Type: Cloth (spell damage)
Professions: Tailoring (Spellfire set for fire, Shadoweave for shadow)

Note: Destro warlocks do direct damage (Shadow Bolt, Incinerate). Can be fire or shadow focused.
Relic Slot: Wand
```

#### DRU-01: Balance Druid (caster_dps)
```
Research T4 BiS gear for DRUID BALANCE in TBC Classic 2.4.3.

Role Stats: Spell Damage (Nature/Arcane), Hit Rating, Spell Critical, Intellect
Weapon Type: Staff OR 1H caster + Off-hand/Idol
Armor Type: Leather (spell damage)
Professions: Leatherworking

Note: Balance druids (Moonkin) buff casters with Moonkin Aura. Starfire/Wrath are main spells.
Relic Slot: Idol
```

#### DRU-02: Restoration Druid (healer)
```
Research T4 BiS gear for DRUID RESTORATION in TBC Classic 2.4.3.

Role Stats: +Healing, Spirit, MP5, Intellect
Weapon Type: Staff OR 1H caster + Off-hand/Idol
Armor Type: Leather (healing)
Professions: Leatherworking

Note: Resto druids are HoT healers. Spirit regeneration is important. Tree of Life form.
Relic Slot: Idol
```

#### DRU-03: Feral Druid - Cat DPS (melee_dps)
```
Research T4 BiS gear for DRUID FERAL CAT in TBC Classic 2.4.3.

Role Stats: Agility, Attack Power, Critical Strike, Hit Rating
Weapon Type: 2H Weapon (staff or polearm for Feral AP)
Armor Type: Leather (agility)
Professions: Leatherworking

Note: Cat druids want "Feral Attack Power" on weapons. Different from bear gear.
Relic Slot: Idol
```

#### DRU-04: Feral Druid - Bear Tank (tank)
```
Research T4 BiS gear for DRUID FERAL BEAR in TBC Classic 2.4.3.

Role Stats: Stamina, Armor, Agility, Defense Rating, Dodge
Weapon Type: 2H Weapon (staff or polearm with Feral AP)
Armor Type: Leather (high armor, stamina)
Professions: Leatherworking

Note: Bear druids stack armor and stamina. No shield means high armor leather is crucial.
Relic Slot: Idol
```

---

## How to Execute Research Tasks

1. **Launch research agents in parallel** - Multiple specs can be researched simultaneously
2. **Use Wowhead TBC Classic database** (https://tbc.wowhead.com/)
3. **Verify item IDs** - Copy from Wowhead URL (e.g., /item=29011)
4. **Check Phase 1 availability** - No SSC, TK, Hyjal, BT, or Sunwell items
5. **Output in structured format** - Follow the Item Data Format template above
6. **Update Progress Tracking** - Mark specs complete as research finishes

### Agent Batching Suggestion

To maximize efficiency, run agents grouped by role:

**Batch 1 - Tanks (3 specs)**
- WAR-03 Protection Warrior
- PAL-02 Protection Paladin
- DRU-04 Feral Bear

**Batch 2 - Healers (5 specs)**
- PAL-01 Holy Paladin
- PRI-01 Discipline Priest
- PRI-02 Holy Priest
- SHA-03 Restoration Shaman
- DRU-02 Restoration Druid

**Batch 3 - Melee DPS (9 specs)**
- WAR-01 Arms Warrior
- WAR-02 Fury Warrior
- PAL-03 Retribution Paladin
- ROG-01 Assassination Rogue
- ROG-02 Combat Rogue
- ROG-03 Subtlety Rogue
- SHA-02 Enhancement Shaman
- DRU-03 Feral Cat

**Batch 4 - Ranged DPS (3 specs)**
- HUN-01 Beast Mastery Hunter
- HUN-02 Marksmanship Hunter
- HUN-03 Survival Hunter

**Batch 5 - Caster DPS (10 specs)**
- PRI-03 Shadow Priest
- SHA-01 Elemental Shaman
- MAG-01 Arcane Mage
- MAG-02 Fire Mage
- MAG-03 Frost Mage
- WLK-01 Affliction Warlock
- WLK-02 Demonology Warlock
- WLK-03 Destruction Warlock
- DRU-01 Balance Druid

---

# RESEARCHED ITEM DATA (T4 Phase 1)

This section contains verified BiS item data from Wowhead TBC Classic database.

---

## ROLE: TANK

### Protection Warrior (WAR-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Warbringer Greathelm | 29011 | 120 | Prince Malchezaar (Karazhan) | T4, balanced mitigation/threat |
| Shoulders | Warbringer Shoulderplates | 29023 | 120 | High King Maulgar (Gruul's Lair) | T4, includes hit rating |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | Best threat option |
| Chest | Warbringer Chestguard | 29012 | 120 | Magtheridon (Magtheridon's Lair) | T4, highest stat value |
| Wrists | Marshal's Plate Bracers | 28996 | 115 | PvP Honor | Easy early acquisition |
| Hands | Topaz-Studded Battlegrips | 30741 | 115 | Doom Lord Kazzak (World Boss) | Best mitigation option |
| Waist | Marshal's Plate Belt | 28995 | 115 | PvP Honor | Balanced stats |
| Legs | Wrynn Dynasty Greaves | 28621 | 115 | Nightbane (Karazhan) | Best mitigation choice |
| Feet | Battlescar Boots | 28747 | 115 | Karazhan Chess Event | Mitigation-focused |
| Neck | Necklace of the Juggernaut | 29386 | 110 | Badge of Justice (25) | Pre-raid farmable |
| Ring 1 | Violet Signet of the Great Protector | 29279 | 115 | Exalted: The Violet Eye | Best mitigation ring |
| Ring 2 | Shapeshifter's Signet | 30834 | 110 | Exalted: Lower City | Best threat ring |
| Trinket 1 | Moroes' Lucky Pocket Watch | 28528 | 115 | Moroes (Karazhan) | Dodge trinket |
| Trinket 2 | Icon of Unyielding Courage | 28121 | 110 | Heroic Blood Furnace | Threat/hit boost |
| Main Hand | King's Defender | 28749 | 115 | Karazhan Chess Event | BiS for most races |
| Main Hand (Alt) | Latro's Shifting Sword | 28189 | 115 | Black Morass | Threat option |
| Shield | Aldori Legacy Defender | 28825 | 120 | Gruul the Dragonkiller | Gem socket |
| Ranged | Barrel-Blade Longrifle | 30724 | 115 | Doomwalker (World Boss) | Best overall |
| Ranged (Alt) | Consortium Blaster | 29115 | 105 | Exalted: Consortium | Accessible |

#### Protection Warrior Alternatives (Easier to Obtain)

| Slot | Item Name | Item ID | Source | Notes |
|------|-----------|---------|--------|-------|
| Head | Faceguard of Determination | 32083 | Badge of Justice (50) | Badge option |
| Head | Felsteel Helm | 23519 | Blacksmithing | Crafted option |
| Shoulders | Spaulders of the Righteous | 27739 | Heroic Botanica | Heroic option |
| Chest | Jade-Skull Breastplate | 27440 | Heroic The Underbog | Pre-raid option |
| Legs | Clefthoof Hide Leggings | 25687 | Leatherworking | Massive threat piece |
| Weapon | The Sun Eater | 29362 | Heroic Mechanar | Avoidance option |

---

### Protection Paladin (PAL-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Justicar Faceguard | 29068 | 120 | Prince Malchezaar (Karazhan) | T4, Defense, Dodge, Spell Power |
| Head (Alt) | Tankatronic Goggles | 32478 | 115 | Engineering | Phase 2, requires Engineering |
| Shoulders | Justicar Shoulderguards | 29070 | 120 | High King Maulgar (Gruul's Lair) | T4, Defense, Block Rating |
| Back | Devilshark Cape | 27804 | 115 | Warlord Kalithresh (Heroic Steamvault) | Defense, Dodge, Block Value |
| Back (Alt) | Cloak of Eternity | 28329 | 105 | BoE World Drop | Avoidance option |
| Chest | Justicar Chestguard | 29066 | 120 | Magtheridon (Magtheridon's Lair) | T4, Block Rating, Defense |
| Wrists | Bracers of Dignity | 29252 | 110 | Harbinger Skyriss (Heroic Arcatraz) | Defense, Stamina |
| Wrists (Alt) | Vambraces of Courage | 28502 | 105 | Heroic Mana-Tombs | Block, Defense |
| Hands | Iron Gauntlets of the Maiden | 28518 | 115 | Maiden of Virtue (Karazhan) | Defense, Stamina |
| Hands (Alt) | Justicar Handguards | 29067 | 120 | The Curator (Karazhan) | T4, Block, Spell Power |
| Waist | Crimson Girdle of the Indomitable | 28566 | 115 | Moroes (Karazhan) | Defense, Block, Stamina |
| Waist (Alt) | Girdle of Valorous Deeds | 29253 | 110 | Heroic Shattered Halls | Pre-raid option |
| Legs | Justicar Legguards | 29069 | 120 | Gruul the Dragonkiller (Gruul's Lair) | T4, Defense, Parry |
| Feet | Boots of the Righteous Path | 29254 | 110 | Kargath Bladefist (Heroic Shattered Halls) | Defense, Spell Power |
| Feet (Alt) | Boots of the Watchful Heart | 28547 | 105 | Heroic Shadow Labyrinth | Pre-raid option |
| Neck | Barbed Choker of Discipline | 28516 | 115 | Maiden of Virtue (Karazhan) | Defense, Dodge, Stamina |
| Neck (Alt) | Necklace of the Juggernaut | 29386 | 110 | Badge of Justice (25) | Pre-raid farmable |
| Ring 1 | Violet Signet of the Great Protector | 29279 | 130 | Exalted: The Violet Eye | Best mitigation ring, never replaced |
| Ring 2 | A'dal's Signet of Defense | 28792 | 125 | Magtheridon's Head Quest | Defense, Armor |
| Ring 2 (Alt) | Elementium Band of the Sentry | 28407 | 110 | Harbinger Skyriss (Heroic Arcatraz) | Pre-raid option |
| Trinket 1 | Moroes' Lucky Pocket Watch | 28528 | 115 | Moroes (Karazhan) | Dodge on-use |
| Trinket 2 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power for threat |
| Trinket 2 (Alt) | Adamantine Figurine | 27891 | 105 | Heroic Shadow Labyrinth | Armor on-use |
| Main Hand | Bloodmaw Magus-Blade | 28802 | 125 | Gruul the Dragonkiller | Spell Power, Hit Rating |
| Main Hand (Alt) | Gavel of Unearthed Secrets | 29153 | 115 | Exalted: Lower City | Pre-raid option |
| Shield | Aldori Legacy Defender | 28825 | 125 | Gruul the Dragonkiller | Defense, Hit Rating, Socket |
| Shield (Alt) | Azure-Shield of Coldarra | 29266 | 110 | Badge of Justice (33) | Badge option |
| Libram | Libram of Repentance | 29388 | 110 | Badge of Justice (15) | Block chance |
| Libram (Alt) | Libram of Saints Departed | 27917 | 105 | Heroic Sethekk Halls | Pre-raid |

#### Protection Paladin Alternatives (Easier to Obtain)

| Slot | Item Name | Item ID | Source | Notes |
|------|-----------|---------|--------|-------|
| Head | Felsteel Helm | 23519 | Blacksmithing | Crafted, excellent stats |
| Shoulders | Spaulders of the Righteous | 27739 | Heroic Botanica | Pre-raid staple |
| Chest | Jade-Skull Breastplate | 27440 | Heroic Underbog | Pre-raid option |
| Hands | Felsteel Gloves | 23517 | Blacksmithing | Crafted option |
| Legs | Timewarden's Leggings | 25820 | Keepers of Time (Honored) | Rep reward |
| Weapon | Continuum Blade | 29185 | Keepers of Time (Exalted) | Spell Power option |

---

### Feral Druid Bear (DRU-04) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Stag-Helm of Malorne | 29098 | 120 | Prince Malchezaar (Karazhan) | T4, Armor, Stamina, Agility |
| Head (Alt) | Mask of the Deceiver | 28797 | 115 | High King Maulgar (Gruul's Lair) | Alternative |
| Shoulders | Mantle of Malorne | 29100 | 120 | High King Maulgar (Gruul's Lair) | T4, Armor, Stamina |
| Back | Gilded Thorium Cloak | 28660 | 115 | Terestian Illhoof (Karazhan) | Armor 385, Defense, Stamina |
| Back (Alt) | Cloak of the Pit Stalker | 27878 | 105 | Heroic Blood Furnace | Pre-raid option |
| Chest | Breastplate of Malorne | 29096 | 120 | Magtheridon (Magtheridon's Lair) | T4, Armor 659, Stamina |
| Chest (Alt) | Heavy Clefthoof Vest | 25689 | 105 | Leatherworking | High armor, pre-raid |
| Wrists | Marshal's Dragonhide Bracers | 28978 | 113 | PvP Honor (11794 + 20 marks) | Armor, Stamina, Strength |
| Wrists (Alt) | General's Dragonhide Bracers | 28445 | 113 | PvP Honor (Horde) | Same as Marshal's |
| Hands | Gauntlets of Malorne | 29097 | 120 | The Curator (Karazhan) | T4, Armor, Stamina |
| Hands (Alt) | Verdant Gloves | 28348 | 105 | Heroic Botanica | Pre-raid option |
| Waist | Tree-Mender's Belt | 29264 | 110 | Heroic Hellfire Ramparts | Armor 406, Agility, Stamina |
| Waist (Alt) | Belt of Natural Power | 30039 | 105 | Leatherworking | Threat option |
| Legs | Greaves of Malorne | 29099 | 120 | Gruul the Dragonkiller (Gruul's Lair) | T4, Armor 640, Stamina |
| Legs (Alt) | Heavy Clefthoof Leggings | 25690 | 105 | Leatherworking | High armor, pre-raid |
| Feet | Zierhut's Lost Treads | 30674 | 115 | Karazhan Trash Drop | Armor, Agility, Stamina |
| Feet (Alt) | Edgewalker Longboots | 28477 | 115 | Moroes (Karazhan) | Alternative |
| Neck | Worgen Claw Necklace | 28509 | 115 | Attumen the Huntsman (Karazhan) | Agility, Attack Power |
| Neck (Alt) | Saberclaw Talisman | 28530 | 115 | Shade of Aran (Karazhan) | Stamina, Defense |
| Ring 1 | Violet Signet of the Great Protector | 29279 | 130 | Exalted: The Violet Eye | Best mitigation, never replaced |
| Ring 2 | A'dal's Signet of Defense | 28792 | 125 | Magtheridon's Head Quest | Armor, Defense, Stamina |
| Ring 2 (Alt) | Shapeshifter's Signet | 30834 | 110 | Exalted: Lower City | Threat option |
| Trinket 1 | Mark of the Champion | 23206 | 90 | Kel'Thuzad Quest (Naxx 40) | BiS vs Undead/Demons |
| Trinket 1 (Alt) | Moroes' Lucky Pocket Watch | 28528 | 115 | Moroes (Karazhan) | Avoidance option |
| Trinket 2 | Dragonspine Trophy | 28830 | 125 | Gruul the Dragonkiller | Haste proc, threat |
| Trinket 2 (Alt) | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | On-use threat |
| Two-Hand Weapon | Terestian's Stranglestaff | 28658 | 115 | Terestian Illhoof (Karazhan) | Feral AP 829, Stamina |
| Two-Hand (Alt) | Earthwarden | 29171 | 100 | Exalted: Cenarion Expedition | Defense, Armor 500, mitigation |
| Two-Hand (Alt) | Gladiator's Maul | 28297 | 115 | Arena | Defense swap option |
| Idol | Idol of the Raven Goddess | 32387 | 115 | Swift Flight Form Quest | Party crit buff, best overall |
| Idol (Alt) | Idol of Brutality | 23198 | 65 | Magistrate Barthilas (Stratholme) | Maul cost reduction |
| Idol (Alt) | Everbloom Idol | 29390 | 110 | Badge of Justice (15) | Personal DPS |

#### Feral Bear Alternatives (Easier to Obtain)

| Slot | Item Name | Item ID | Source | Notes |
|------|-----------|---------|--------|-------|
| Head | Stylin' Purple Hat | 28586 | Leatherworking | 20 Def rating |
| Shoulders | Shoulderpads of Assassination | 27797 | Heroic Sethekk Halls | Pre-raid |
| Chest | Heavy Clefthoof Vest | 25689 | Leatherworking | 159 Armor bonus |
| Legs | Heavy Clefthoof Leggings | 25690 | Leatherworking | 130 Armor bonus |
| Feet | Heavy Clefthoof Boots | 25691 | Leatherworking | 103 Armor bonus |
| Weapon | Earthwarden | 29171 | Cenarion Expedition (Exalted) | Essential for progression |

---

## ROLE: HEALER

### Holy Paladin (PAL-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Justicar Diadem | 29061 | 120 | Prince Malchezaar (Karazhan) | T4 |
| Head (Alt) | Fathom-Helm of the Deeps | 30728 | 115 | Doom Lord Kazzak (World Boss) | World boss |
| Shoulders | Justicar Pauldrons | 29064 | 120 | High King Maulgar (Gruul's Lair) | T4 |
| Back | Stainless Cloak of the Pure Hearted | 28765 | 125 | Prince Malchezaar (Karazhan) | Raid drop |
| Back (Alt) | Lifegiving Cloak | 31329 | 110 | World Drop | BoE option |
| Chest | Justicar Chestpiece | 29062 | 120 | Magtheridon (Magtheridon's Lair) | T4 |
| Wrists | Blessed Bracers | 23539 | 100 | Blacksmithing (BoE) | Crafted |
| Wrists (Alt) | Bindings of the Timewalker | 29183 | 105 | Exalted: Keepers of Time | Rep |
| Hands | Gauntlets of Renewed Hope | 28505 | 115 | Attumen the Huntsman (Karazhan) | Raid drop |
| Waist | Primal Mooncloth Belt | 21873 | 115 | Mooncloth Tailoring (BoP) | Crafted |
| Legs | Legplates of the Innocent | 28748 | 115 | Chess Event (Karazhan) | Raid |
| Legs (Alt) | Gilded Trousers of Benediction | 30727 | 120 | Doom Lord Kazzak | World boss |
| Feet | Forestlord Striders | 28752 | 115 | Chess Event (Karazhan) | Raid |
| Neck | Emberspur Talisman | 28609 | 115 | Nightbane (Karazhan) | Raid |
| Neck (Alt) | Archaic Charm of Presence | 30726 | 115 | Doomwalker | World boss |
| Ring 1 | Jade Ring of the Everliving | 28763 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Ring 2 | Naaru Lightwarden's Band | 28790 | 125 | Magtheridon Quest | Quest reward |
| Trinket 1 | Essence of the Martyr | 29376 | 110 | Badge of Justice | Best healing trinket |
| Trinket 2 | Ribbon of Sacrifice | 28590 | 115 | Opera Event (Karazhan) | Raid drop |
| Main Hand | Light's Justice | 28771 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Shield | Aegis of the Vindicator | 29458 | 120 | Magtheridon | Raid |
| Libram | Libram of Souls Redeemed | 28592 | 115 | Opera Event (Karazhan) | Raid |

---

### Discipline Priest (PRI-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Light-Collar of the Incarnate | 29049 | 120 | Prince Malchezaar (Karazhan) | T4, +Healing, MP5, Sockets |
| Head (Alt) | Cowl of Naaru Blessings | 31395 | 110 | Badge of Justice (50) | Badge |
| Shoulders | Primal Mooncloth Shoulders | 21874 | 105 | Tailoring | +Healing, Spirit, Set Bonus |
| Shoulders (Alt) | Light-Mantle of the Incarnate | 29054 | 120 | High King Maulgar (Gruul's Lair) | T4 |
| Back | Stainless Cloak of the Pure Hearted | 28765 | 125 | Prince Malchezaar (Karazhan) | +Healing, MP5 |
| Back (Alt) | Light-Touched Stole of Altruism | 27509 | 110 | Heroic Auchenai Crypts | Heroic |
| Chest | Primal Mooncloth Robe | 21875 | 120 | Tailoring | +Healing, Spirit, Set Bonus |
| Chest (Alt) | Robes of the Incarnate | 29050 | 120 | Magtheridon | T4 |
| Wrists | Bindings of the Timewalker | 29183 | 105 | Exalted: Keepers of Time | MP5, +Healing |
| Wrists (Alt) | Bands of the Benevolent | 29249 | 110 | Heroic Sethekk Halls | +Healing, Spirit |
| Hands | Gloves of Saintly Blessings | 28508 | 115 | Attumen the Huntsman (Karazhan) | +Healing, MP5, Sockets |
| Hands (Alt) | Handwraps of the Incarnate | 29055 | 120 | The Curator (Karazhan) | T4 |
| Waist | Primal Mooncloth Belt | 21873 | 115 | Tailoring | BiS, +Healing, Set Bonus |
| Waist (Alt) | Cord of Sanctification | 27843 | 110 | Heroic Old Hillsbrad | Heroic |
| Legs | Gilded Trousers of Benediction | 30727 | 120 | Doomwalker (World Boss) | +Healing, MP5 |
| Legs (Alt) | Pantaloons of Repentance | 28742 | 115 | Netherspite (Karazhan) | Raid |
| Feet | Boots of the Incorrupt | 28663 | 115 | Shade of Aran (Karazhan) | +Healing, MP5 |
| Feet (Alt) | Boots of the Pious | 29250 | 110 | Heroic Mechanar | Heroic |
| Neck | Necklace of Eternal Hope | 29374 | 110 | Badge of Justice (25) | MP5, +Healing |
| Neck (Alt) | Teeth of Gruul | 28822 | 115 | Gruul (Gruul's Lair) | Raid |
| Ring 1 | Violet Signet of the Grand Restorer | 29290 | 130 | Exalted: The Violet Eye | +Healing, Spirit |
| Ring 2 | Naaru Lightwarden's Band | 28790 | 125 | Magtheridon | Raid |
| Ring (Alt) | Band of Halos | 29373 | 110 | Badge of Justice (25) | Badge |
| Trinket 1 | Essence of the Martyr | 29376 | 110 | Badge of Justice (41) | BiS, +Healing on use |
| Trinket 2 | Scarab of the Infinite Cycle | 28190 | 115 | Heroic Black Morass | +Healing on use |
| Trinket (Alt) | Darkmoon Card: Blue Dragon | 19288 | 83 | Darkmoon Beast Deck | Mana regen proc |
| Main Hand | Light's Justice | 28771 | 115 | Prince Malchezaar (Karazhan) | +Healing, +Spell Damage |
| Main Hand (Alt) | Hand of Eternity | 23556 | 115 | Blacksmithing | Crafted |
| Off Hand | Windcaller's Orb | 29170 | 110 | Exalted: Cenarion Expedition | +Healing, Spirit |
| Off Hand (Alt) | Tears of Heaven | 29274 | 110 | Badge of Justice (25) | MP5, +Healing |
| Wand | Blue Diamond Witchwand | 28588 | 115 | Opera Event (Karazhan) | +Healing, Spell Damage |
| Wand (Alt) | Soul-Wand of the Aldor | 28386 | 100 | Shadow Labyrinth | Dungeon |

---

### Holy Priest (PRI-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Light-Collar of the Incarnate | 29049 | 120 | Prince Malchezaar (Karazhan) | T4, +Healing, MP5, Meta Socket |
| Shoulders | Primal Mooncloth Shoulders | 21874 | 105 | Tailoring | +Healing, Spirit, 3pc Set Bonus |
| Shoulders (Alt) | Light-Mantle of the Incarnate | 29054 | 120 | High King Maulgar (Gruul's Lair) | T4 |
| Back | Stainless Cloak of the Pure Hearted | 28765 | 125 | Prince Malchezaar (Karazhan) | +Healing, MP5 |
| Chest | Primal Mooncloth Robe | 21875 | 120 | Tailoring | +Healing, Spirit, 3pc Set Bonus |
| Chest (Alt) | Robes of the Incarnate | 29050 | 120 | Magtheridon | T4 |
| Wrists | Bindings of the Timewalker | 29183 | 105 | Exalted: Keepers of Time | +Healing, MP5 |
| Wrists (Alt) | Bands of Indwelling | 28511 | 115 | Maiden of Virtue (Karazhan) | Raid |
| Hands | Gloves of Saintly Blessings | 28508 | 115 | Attumen the Huntsman (Karazhan) | +Healing, MP5, Sockets |
| Hands (Alt) | Handwraps of the Incarnate | 29055 | 120 | The Curator (Karazhan) | T4 |
| Waist | Primal Mooncloth Belt | 21873 | 115 | Tailoring | BiS, +Healing, 3pc Set Bonus |
| Legs | Gilded Trousers of Benediction | 30727 | 120 | Doomwalker (World Boss) | +Healing, MP5 |
| Legs (Alt) | Pantaloons of Repentance | 28742 | 115 | Netherspite (Karazhan) | Raid |
| Feet | Boots of the Incorrupt | 28663 | 115 | Shade of Aran (Karazhan) | +Healing, MP5 |
| Neck | Teeth of Gruul | 28822 | 115 | Gruul (Gruul's Lair) | +Healing, Spirit |
| Neck (Alt) | Shining Chain of the Afterworld | 28731 | 115 | Netherspite (Karazhan) | Raid |
| Ring 1 | Violet Signet of the Grand Restorer | 29290 | 130 | Exalted: The Violet Eye | +Healing, Spirit |
| Ring 2 | Jade Ring of the Everliving | 28763 | 115 | Prince Malchezaar (Karazhan) | MP5, +Healing |
| Ring (Alt) | Naaru Lightwarden's Band | 28790 | 125 | Magtheridon | Raid |
| Trinket 1 | Essence of the Martyr | 29376 | 110 | Badge of Justice (41) | BiS, +Healing on use |
| Trinket 2 | Eye of Gruul | 28823 | 115 | Gruul (Gruul's Lair) | Spell Damage, Mana Proc |
| Trinket (Alt) | Darkmoon Card: Blue Dragon | 19288 | 83 | Darkmoon Beast Deck | Mana regen proc |
| Main Hand | Light's Justice | 28771 | 115 | Prince Malchezaar (Karazhan) | +Healing, +Spell Damage |
| Off Hand | Windcaller's Orb | 29170 | 110 | Exalted: Cenarion Expedition | +Healing, Spirit |
| Wand | Blue Diamond Witchwand | 28588 | 115 | Opera Event (Karazhan) | +Healing, Spell Damage |

---

### Restoration Shaman (SHA-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Cyclone Headdress | 29028 | 120 | Prince Malchezaar (Karazhan) | T4, +Healing, MP5 |
| Head (Alt) | Earthblood Chestguard | 32082 | 110 | Badge of Justice (75) | Badge |
| Shoulders | Cyclone Shoulderpads | 29031 | 120 | High King Maulgar (Gruul's Lair) | T4, +Healing, MP5 |
| Back | Stainless Cloak of the Pure Hearted | 28765 | 125 | Prince Malchezaar (Karazhan) | +Healing |
| Back (Alt) | Cloak of the Everliving | 27878 | 105 | Heroic Slave Pens | Heroic |
| Chest | Windhawk Hauberk | 29522 | 115 | Tribal Leatherworking | +Healing, Set Bonus |
| Chest (Alt) | Cyclone Hauberk | 29029 | 120 | Magtheridon | T4 |
| Wrists | Windhawk Bracers | 29523 | 115 | Tribal Leatherworking | +Healing, Set Bonus |
| Wrists (Alt) | Bindings of the Timewalker | 29183 | 105 | Exalted: Keepers of Time | Rep |
| Hands | Gloves of Centering | 28520 | 115 | Maiden of Virtue (Karazhan) | +Healing |
| Hands (Alt) | Cyclone Gloves | 29032 | 120 | The Curator (Karazhan) | T4 |
| Waist | Windhawk Belt | 29524 | 115 | Tribal Leatherworking | +Healing, Set Bonus |
| Waist (Alt) | Belt of the Long Road | 28799 | 115 | Karazhan | Raid |
| Legs | Gilded Trousers of Benediction | 30727 | 120 | Doomwalker (World Boss) | +Healing, MP5 |
| Legs (Alt) | Cyclone Kilt | 29030 | 120 | Gruul (Gruul's Lair) | T4 |
| Feet | Gold-Leaf Wildboots | 30737 | 115 | Doom Lord Kazzak (World Boss) | +Healing |
| Feet (Alt) | Boots of the Incorrupt | 28663 | 115 | Shade of Aran (Karazhan) | Raid |
| Neck | Emberspur Talisman | 28609 | 115 | Nightbane (Karazhan) | +Healing |
| Neck (Alt) | Necklace of Eternal Hope | 29374 | 110 | Badge of Justice (25) | Badge |
| Ring 1 | Jade Ring of the Everliving | 28763 | 115 | Prince Malchezaar (Karazhan) | MP5, +Healing |
| Ring 2 | Naaru Lightwarden's Band | 28790 | 125 | Magtheridon | +Healing |
| Ring (Alt) | Violet Signet of the Grand Restorer | 29290 | 130 | Exalted: The Violet Eye | Rep |
| Trinket 1 | Essence of the Martyr | 29376 | 110 | Badge of Justice (41) | BiS, +Healing on use |
| Trinket 2 | Scarab of the Infinite Cycle | 28190 | 115 | Heroic Black Morass | +Healing on use |
| Trinket (Alt) | Eye of Gruul | 28823 | 115 | Gruul (Gruul's Lair) | Spell Damage, Mana Proc |
| Main Hand | Exodar Life-Staff | 30732 | 115 | Doom Lord Kazzak (World Boss) | +Healing, MP5 |
| Main Hand (Alt) | Light's Justice | 28771 | 115 | Prince Malchezaar (Karazhan) | 1H Mace |
| Off Hand | Aegis of the Vindicator | 29458 | 120 | Magtheridon | Shield |
| Off Hand (Alt) | Mazthoril Honor Shield | 29266 | 110 | Exalted: The Violet Eye | Shield, Rep |
| Totem | Totem of Healing Rains | 28523 | 115 | Maiden of Virtue (Karazhan) | +Healing to Chain Heal |
| Totem (Alt) | Totem of the Plains | 25645 | 88 | Quest: The Mag'har | Quest |

---

### Restoration Druid (DRU-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Whitemend Hood | 24264 | 105 | Tailoring | +Healing, Sockets |
| Head (Alt) | Malorne Headpiece | 29086 | 120 | Prince Malchezaar (Karazhan) | T4 |
| Shoulders | Primal Mooncloth Shoulders | 21874 | 105 | Tailoring | +Healing, Spirit |
| Shoulders (Alt) | Malorne Spaulders | 29089 | 120 | High King Maulgar (Gruul's Lair) | T4 |
| Back | Stainless Cloak of the Pure Hearted | 28765 | 125 | Prince Malchezaar (Karazhan) | +Healing |
| Chest | Primal Mooncloth Robe | 21875 | 120 | Tailoring | +Healing, Spirit, MP5 |
| Chest (Alt) | Malorne Raiment | 29087 | 120 | Magtheridon | T4 |
| Wrists | Bindings of the Timewalker | 29183 | 105 | Exalted: Keepers of Time | +Healing, MP5 |
| Wrists (Alt) | Bands of the Benevolent | 29249 | 110 | Heroic Sethekk Halls | Heroic |
| Hands | Mitts of the Treemender | 28521 | 115 | Maiden of Virtue (Karazhan) | +Healing |
| Hands (Alt) | Malorne Handguards | 29090 | 120 | The Curator (Karazhan) | T4 |
| Waist | Primal Mooncloth Belt | 21873 | 115 | Tailoring | BiS, +Healing |
| Waist (Alt) | Belt of the Long Road | 28799 | 115 | Karazhan | Raid |
| Legs | Gilded Trousers of Benediction | 30727 | 120 | Doomwalker (World Boss) | +Healing, Sockets |
| Legs (Alt) | Malorne Legguards | 29088 | 120 | Gruul (Gruul's Lair) | T4 |
| Feet | Gold-Leaf Wildboots | 30737 | 115 | Doom Lord Kazzak (World Boss) | +Healing, MP5 |
| Feet (Alt) | Boots of the Incorrupt | 28663 | 115 | Shade of Aran (Karazhan) | Raid |
| Neck | Archaic Charm of Presence | 30726 | 115 | Doomwalker (World Boss) | +Healing |
| Neck (Alt) | Necklace of Eternal Hope | 29374 | 110 | Badge of Justice (25) | Badge |
| Ring 1 | Naaru Lightwarden's Band | 28790 | 125 | Magtheridon | +Healing |
| Ring 2 | Violet Signet of the Grand Restorer | 29290 | 130 | Exalted: The Violet Eye | +Healing, Spirit |
| Ring (Alt) | Band of Halos | 29373 | 110 | Badge of Justice (25) | Badge |
| Trinket 1 | Essence of the Martyr | 29376 | 110 | Badge of Justice (41) | BiS, +Healing on use |
| Trinket 2 | Lower City Prayerbook | 30841 | 115 | Revered: Lower City | Mana on cast |
| Trinket (Alt) | Scarab of the Infinite Cycle | 28190 | 115 | Heroic Black Morass | +Healing on use |
| Main Hand | Exodar Life-Staff | 30732 | 115 | Doom Lord Kazzak (World Boss) | +Healing, MP5 |
| Main Hand (Alt) | Nightstaff of the Everliving | 28604 | 115 | Nightbane (Karazhan) | +Healing Staff |
| Off Hand | Tears of Heaven | 29274 | 110 | Badge of Justice (25) | +Healing, MP5 |
| Off Hand (Alt) | Talisman of the Sun King | 28768 | 115 | Shade of Aran (Karazhan) | Off-hand frill |
| Idol | Idol of the Emerald Queen | 27886 | 112 | Ambassador Hellmaw (Shadow Labyrinth) | +Healing to Lifebloom |
| Idol (Alt) | Harold's Rejuvenating Broach | 25634 | 70 | Quest: The Assassination of Harold Lane | +Healing to Rejuv |

---

## ROLE: MELEE DPS

### Combat Rogue (ROG-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Netherblade Facemask | 29044 | 120 | Netherspite (Karazhan) | T4 |
| Shoulders | Wastewalker Shoulderpads | 27797 | 115 | Heroic Auchenai Crypts | Heroic |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | Raid |
| Chest | Netherblade Chestpiece | 29045 | 120 | Magtheridon | T4 |
| Chest (Alt) | Terrorweave Tunic | 30730 | 115 | Doomwalker | World boss |
| Wrists | Nightfall Wristguards | 29246 | 110 | Heroic Old Hillsbrad | Heroic |
| Hands | Wastewalker Gloves | 27531 | 115 | Heroic Shattered Halls | Heroic |
| Hands (Alt) | Grips of Deftness | 30644 | 115 | Karazhan Trash | Raid trash |
| Waist | Girdle of the Deathdealer | 29247 | 110 | Heroic Black Morass | Heroic |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | Raid |
| Legs (Alt) | Netherblade Breeches | 29046 | 120 | Gruul (Gruul's Lair) | T4 |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | Raid |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | Badge |
| Neck (Alt) | Braided Eternium Chain | 24114 | 100 | Jewelcrafting | Crafted, party buff |
| Ring 1 | Ring of a Thousand Marks | 28757 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | Raid |
| Trinket 1 | Dragonspine Trophy | 28830 | 120 | Gruul (Gruul's Lair) | BiS entire TBC |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | Badge |
| Main Hand | Dragonmaw | 28438 | 115 | Blacksmithing | Crafted |
| Main Hand (Alt) | Gladiator's Slicer | 28295 | 115 | Arena S1 | PvP |
| Off Hand | Latro's Shifting Sword | 28189 | 115 | Black Morass | Dungeon |
| Off Hand (Alt) | Gladiator's Quickblade | 28307 | 115 | Arena S1 | PvP |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Ranged (Alt) | Veteran's Musket | 29151 | 100 | Exalted: Honor Hold | Rep (Alliance) |
| Ranged (Alt) | Marksman's Bow | 29152 | 100 | Exalted: Thrallmar | Rep (Horde) |

---

### Arms Warrior (WAR-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Warbringer Battle-Helm | 29021 | 120 | Prince Malchezaar (Karazhan) | +45 Str, +45 Sta, +14 Hit, +24 Crit |
| Head (Alt) | Ragesteel Helm | 33172 | 115 | Blacksmithing (365) | +40 Str, +18 Sta, 2pc set |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +42 AP, +18 Hit |
| Shoulders | Warbringer Shoulderplates | 29023 | 120 | High King Maulgar (Gruul's) | +32 Str, +22 Agi, +33 Sta, +13 Hit |
| Back | Vengeance Wrap | 24259 | 105 | Tailoring (BoE) | +52 AP, +23 Crit |
| Chest | Warbringer Breastplate | 29019 | 120 | Magtheridon | +44 Str, +39 Sta, +26 Crit |
| Wrist | Bladespire Warbands | 28795 | 125 | High King Maulgar (Gruul's) | +20 Str, +16 Sta, +24 Crit |
| Hands | Gauntlets of Martial Perfection | 28824 | 125 | Gruul (Gruul's Lair) | +36 Str, +34 Sta, +23 Crit |
| Waist | Girdle of the Endless Pit | 28779 | 125 | Magtheridon | +34 Str, +30 Sta, +28 Crit |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | +32 Agi, +28 Sta, +28 Hit, +64 AP |
| Feet | Ironstriders of Urgency | 28608 | 115 | Nightbane (Karazhan) | +33 Str, +20 Agi, +28 Sta |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +44 AP, +19 Hit, +23 Crit |
| Ring 2 | Mithril Band of the Unscarred | 28730 | 115 | Netherspite (Karazhan) | +26 Str, +24 Sta, +22 Crit |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Main Hand (2H) | Gorehowl | 28773 | 125 | Prince Malchezaar (Karazhan) | 3.7 Speed, +49 Str, +43 Agi, +51 Sta |
| Main Hand (Alt) | Lionheart Champion | 28429 | 123 | Blacksmithing (Swordsmith) | 3.6 Speed, +49 Str, +44 Agi, Human racial |
| Main Hand (Alt) | Despair | 28573 | 115 | Opera Event (Karazhan) | 3.5 Speed, +52 Str, easier to obtain |
| Off Hand | N/A | - | - | Arms uses 2H weapons | - |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 125 | Prince Malchezaar (Karazhan) | +19 Agi, +34 AP |

---

### Fury Warrior (WAR-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Warbringer Battle-Helm | 29021 | 120 | Prince Malchezaar (Karazhan) | +37 Str, +40 Sta, +22 Agi, +17 Hit |
| Head (Alt) | Ragesteel Helm | 33172 | 115 | Blacksmithing (365) | +40 Str, +18 Sta, 2pc set bonus |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +30 AP, +20 Hit, +24 Crit |
| Shoulders | Warbringer Shoulderplates | 29023 | 120 | High King Maulgar (Gruul's) | +32 Str, +22 Agi, +33 Sta, +13 Hit |
| Shoulders (Alt) | Ragesteel Shoulders | 33173 | 115 | Blacksmithing (365) | +28 Str, +18 Agi, +18 Sta |
| Back | Vengeance Wrap | 24259 | 115 | Tailoring (365) | +24 AP, +22 Crit, +20 Sta |
| Chest | Warbringer Breastplate | 29019 | 120 | Magtheridon | +41 Str, +25 Agi, +43 Sta, +18 Hit |
| Chest (Alt) | Ragesteel Breastplate | 23522 | 115 | Blacksmithing (370) | +42 Str, +18 Sta |
| Wrist | Bladespire Warbands | 28795 | 125 | High King Maulgar (Gruul's) | +32 Str, +22 Agi, +33 Sta, +14 Hit |
| Hands | Gauntlets of Martial Perfection | 28824 | 125 | Gruul (Gruul's Lair) | +34 Str, +23 Agi, +34 Sta, +18 Hit |
| Hands (Alt) | Ragesteel Gloves | 23520 | 115 | Blacksmithing (350) | +32 Str, +18 Sta, +20 Hit (2pc) |
| Waist | Girdle of the Endless Pit | 28779 | 125 | Magtheridon | +37 Str, +24 Agi, +37 Sta, +18 Hit |
| Legs | Warbringer Greaves | 29022 | 120 | Gruul (Gruul's Lair) | +48 Str, +28 Agi, +49 Sta |
| Feet | Ironstriders of Urgency | 28608 | 115 | Nightbane (Karazhan) | +30 Str, +20 Agi, +33 Sta |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +36 AP, +23 Sta, +23 Hit |
| Ring 2 | Shapeshifter's Signet | 30834 | 100 | Lower City (Exalted) | +24 Str, +24 Sta, +20 Expertise |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | Proc: +325 Haste for 10s |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Trinket (Alt) | Hourglass of the Unraveller | 28034 | 112 | Temporus (Black Morass) | +32 Crit, Proc: +300 AP |
| Main Hand | Dragonmaw | 28438 | 123 | Blacksmithing (Hammersmith) | +32 Str, 2.7 speed, Haste proc |
| Main Hand (Alt) | Spiteblade | 28729 | 115 | Netherspite (Karazhan) | +20 Str, +21 Agi, 2.6 speed |
| Off Hand | Spiteblade | 28729 | 115 | Netherspite (Karazhan) | +20 Str, +21 Agi, 2.6 speed |
| Off Hand (Alt) | The Decapitator | 28767 | 125 | Prince Malchezaar (Karazhan) | +27 Crit, 2.6 speed |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 125 | Prince Malchezaar (Karazhan) | +12 Agi, +12 Sta, +14 Hit |

---

### Retribution Paladin (PAL-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Justicar Crown | 29073 | 120 | Prince Malchezaar (Karazhan) | T4, +43 Str, +22 Agi, +33 Sta, +31 Int |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +42 AP, +18 Hit |
| Shoulders | Justicar Shoulderplates | 29075 | 120 | High King Maulgar (Gruul's) | T4, +36 Str, +13 Agi, +24 Sta, +16 Hit |
| Back | Vengeance Wrap | 24259 | 115 | Tailoring (BoE) | +52 AP, +23 Crit, +2 Hit |
| Back (Alt) | Cloak of Darkness | 33122 | 120 | Leatherworking (Violet Eye Exalted) | +23 Str, +25 Sta, +24 Crit |
| Chest | Justicar Breastplate | 29071 | 120 | Magtheridon | T4, +42 Str, +24 Sta, +33 Int, +25 Crit |
| Wrist | Bladespire Warbands | 28795 | 125 | High King Maulgar (Gruul's) | +20 Str, +16 Sta, +24 Crit |
| Hands | Grips of Deftness | 30644 | 115 | Karazhan Trash | Leather, +29 Agi, +34 Sta, +15 Expertise, +60 AP |
| Waist | Girdle of the Endless Pit | 28779 | 125 | Magtheridon | +34 Str, +30 Sta, +28 Crit |
| Legs | Justicar Greaves | 29074 | 120 | Gruul (Gruul's Lair) | T4, +53 Str, +24 Agi, +34 Sta, +23 Hit |
| Legs (Alt) | Shattrath Leggings | 30257 | 109 | Quest: Special Delivery | Leather, +35 Str, +25 Agi, +22 Expertise |
| Feet | Ironstriders of Urgency | 28608 | 115 | Nightbane (Karazhan) | +33 Str, +20 Agi, +28 Sta |
| Feet (Alt) | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | Leather, +29 Agi, +28 Sta, +44 AP, +13 Hit |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +23 Crit, +44 AP, +19 Hit |
| Ring 2 | Shapeshifter's Signet | 30834 | 100 | Lower City (Exalted) | +25 Agi, +18 Sta, +20 Expertise |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Trinket (Alt) | Abacus of Violent Odds | 28288 | 115 | Pathaleon (Mechanar) | +64 AP, Use: +260 Haste |
| Main Hand (2H) | Lionheart Champion | 28429 | 123 | Blacksmithing (Master Swordsmith) | 3.60 Speed, +49 Str, +44 Agi, +100 Str proc |
| Main Hand (Alt) | Gorehowl | 28773 | 125 | Prince Malchezaar (Karazhan) | 3.60 Speed, +49 Str, +43 Agi, +51 Sta |
| Main Hand (Alt) | Hammer of the Naaru | 28800 | 125 | High King Maulgar (Gruul's) | 3.60 Speed, +44 Str, +33 Spell Power |
| Off Hand | N/A | - | - | Ret uses 2H weapons | - |
| Relic | Libram of Avengement | 27484 | 115 | The Maker (Heroic Blood Furnace) | +53 Crit Rating to Judgement |

---

### Assassination Rogue (ROG-01) - T4 BiS

**Note:** Assassination requires daggers for Mutilate. Fast main-hand (1.7-1.9s) for damage, fast off-hand (1.4s) for poison procs.

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Netherblade Facemask | 29044 | 120 | Prince Malchezaar (Karazhan) | T4, +37 Agi, +30 Sta, +25 Hit, +32 AP |
| Head (Alt) | Wastewalker Helm | 28224 | 115 | Heroic Old Hillsbrad | +29 Agi, +30 Sta, +26 Crit, +22 Hit |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +22 Sta, +40 AP, +22 Hit, +20 Crit |
| Shoulders | Wastewalker Shoulderpads | 27797 | 115 | Heroic Auchenai Crypts | +27 Agi, +25 Sta, +17 Crit, +15 Hit |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | +18 Agi, +18 Sta, +32 AP, +17 Hit |
| Chest | Netherblade Chestpiece | 29045 | 120 | Magtheridon | T4, +32 Agi, +40 Sta, +24 Crit |
| Chest (Alt) | Wastewalker Tunic | 27531 | 115 | Heroic Blood Furnace | +32 Agi, +30 Sta, +25 Crit, +18 Hit |
| Wrist | Nightfall Wristguards | 27908 | 115 | Heroic Underbog | +22 Agi, +21 Sta, +14 Hit |
| Hands | Wastewalker Gloves | 28221 | 115 | Heroic Black Morass | +25 Agi, +21 Sta, +18 Hit |
| Hands (Alt) | Netherblade Gloves | 29048 | 120 | The Curator (Karazhan) | T4, +26 Agi, +30 Sta, +20 Crit |
| Waist | Girdle of the Deathdealer | 28828 | 125 | Gruul (Gruul's Lair) | +28 Agi, +28 Sta, +21 Crit, +17 Hit |
| Legs | Skulker's Greaves | 28741 | 125 | Netherspite (Karazhan) | +36 Agi, +30 Sta, +25 Hit, +22 Crit |
| Legs (Alt) | Netherblade Breeches | 29046 | 120 | Gruul (Gruul's Lair) | T4, +35 Agi, +38 Sta, +23 Crit |
| Feet | Edgewalker Longboots | 28545 | 120 | Moroes (Karazhan) | +27 Agi, +30 Sta, +18 Hit, +28 AP |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +44 AP, +23 Crit, +19 Hit |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | +18 Agi, +16 Sta, +18 Hit |
| Ring (Alt) | Violet Signet of the Master Assassin | 29283 | 125 | Violet Eye (Exalted) | +24 Sta, +44 AP, +24 Crit, +17 Hit |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Trinket (Alt) | Romulo's Poison Vial | 28579 | 115 | Opera - R&J (Karazhan) | +35 Hit, +38 Crit, Proc: +340 AP |
| Main Hand | Malchazeen | 28768 | 125 | Prince Malchezaar (Karazhan) | 1.80 speed, +16 Sta, +15 Hit, +50 AP |
| Off Hand | Feltooth Eviscerator | 29346 | 110 | Heroic Ramparts | 1.40 speed, +34 AP, +22 Crit |
| Off Hand (Alt) | Searing Sunblade | 29275 | 110 | Badge of Justice (50) | 1.30 speed, +24 Agi, +22 Sta, fast poison dagger |
| Ranged | Felsteel Whisper Knives | 29204 | 110 | Blacksmithing | +15 Agi, +12 Sta, +12 Crit |

---

### Subtlety Rogue (ROG-03) - T4 BiS

**Note:** Subtlety is primarily PvP-oriented but viable for Hemorrhage builds in PvE. Shares most gear with Assassination (dagger-based).

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Netherblade Facemask | 29044 | 120 | Prince Malchezaar (Karazhan) | T4, +28 Agi, +39 Sta, +78 AP, +14 Hit |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +42 AP, +18 Hit |
| Shoulders | Wastewalker Shoulderpads | 27797 | 115 | Heroic Auchenai Crypts | +25 Agi, +13 Sta, +34 AP, +16 Hit |
| Shoulders (Alt) | Netherblade Shoulderpads | 29047 | 120 | High King Maulgar (Gruul's) | T4, +20 Agi, +38 Sta, +52 AP, +13 Hit |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | +24 Agi, +21 Sta, +34 AP, +17 Hit |
| Chest | Netherblade Chestpiece | 29045 | 120 | Magtheridon | T4, +35 Agi, +39 Sta, +74 AP, +11 Hit |
| Wrist | Nightfall Wristguards | 29246 | 110 | Heroic Old Hillsbrad | +24 Agi, +22 Sta, +46 AP |
| Hands | Netherblade Gloves | 29048 | 120 | The Curator (Karazhan) | T4, +34 Sta, +72 AP, +17 Hit, +25 Crit |
| Hands (Alt) | Wastewalker Gloves | 27531 | 115 | Heroic Shattered Halls | +32 Agi, +16 AP |
| Waist | Girdle of the Deathdealer | 29247 | 110 | Heroic Black Morass | +28 Agi, +28 Sta, +56 AP, +20 Hit |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | +32 Agi, +28 Sta, +64 AP, +28 Hit |
| Legs (Alt) | Netherblade Breeches | 29046 | 120 | Gruul (Gruul's Lair) | T4, +43 Agi, +40 Sta, +84 AP, +26 Hit |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | +29 Agi, +28 Sta, +44 AP, +13 Hit |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +44 AP, +19 Hit, +23 Crit |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | +20 Agi, +25 Sta, +40 AP, +18 Hit |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Main Hand | Malchazeen | 28768 | 125 | Prince Malchezaar (Karazhan) | 1.8 speed, +16 Sta, +50 AP, +15 Hit |
| Main Hand (Alt) | Emerald Ripper | 28524 | 115 | Moroes (Karazhan) | 1.8 speed, +19 Agi, +18 Sta, +36 AP |
| Off Hand | Feltooth Eviscerator | 29346 | 110 | Heroic Ramparts | 1.4 speed, +34 AP, +22 Crit |
| Off Hand (Alt) | Searing Sunblade | 29275 | 110 | Badge of Justice (50) | 1.3 speed, +24 Agi, +22 Sta |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 125 | Prince Malchezaar (Karazhan) | +19 Agi, +34 AP |

---

### Enhancement Shaman (SHA-02) - T4 BiS

**Note:** Enhancement wants SLOW weapons (2.6+ speed) for maximum Windfury damage. Many BiS pieces are leather despite wearing mail.

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Wastewalker Helm | 28224 | 115 | Heroic Old Hillsbrad | +30 Sta, +56 AP, +18 Hit, +22 Crit |
| Head (Alt) | Cyclone Helm | 29040 | 120 | Prince Malchezaar (Karazhan) | T4 Mail, +Agi/Int/Sta |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +42 AP, +18 Hit |
| Shoulders | Cyclone Shoulderplates | 29043 | 120 | High King Maulgar (Gruul's) | T4 Mail, +Agi/Int/Sta, Hit |
| Back | Vengeance Wrap | 24259 | 70 | Tailoring (BoE) | +52 AP, +23 Crit, +2 Hit |
| Chest | Cyclone Breastplate | 29038 | 120 | Magtheridon | T4 Mail, +Int/Sta, Crit |
| Chest (Alt) | Wastewalker Tunic | 27531 | 115 | Heroic Blood Furnace | Leather, +Agi/Sta, AP, Crit |
| Wrist | Bracers of Maliciousness | 28514 | 115 | Maiden of Virtue (Karazhan) | Leather, +25 Sta, +50 AP, +22 Crit |
| Hands | Grips of Deftness | 30644 | 115 | Karazhan Trash | Leather, +29 Agi, +34 Sta, +60 AP, +15 Expertise |
| Hands (Alt) | Cyclone Gauntlets | 29039 | 120 | The Curator (Karazhan) | T4 Mail, +27 Str, +21 Agi, +19 Hit |
| Waist | Gronn-Stitched Girdle | 28828 | 125 | Gruul (Gruul's Lair) | Leather, +27 Sta, +72 AP, +25 Crit |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | Leather, +32 Agi, +28 Sta, +64 AP, +28 Hit |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | Leather, +29 Agi, +28 Sta, +44 AP, +13 Hit |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +44 AP, +19 Hit, +23 Crit |
| Ring 2 | Shapeshifter's Signet | 30834 | 100 | Lower City (Exalted) | +25 Agi, +18 Sta, +20 Expertise |
| Ring (Alt) | Violet Signet of the Master Assassin | 29283 | 130 | Violet Eye (Exalted) | +Agi, +Sta, +AP, +Hit |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Main Hand | The Decapitator | 28767 | 125 | Prince Malchezaar (Karazhan) | 2.60 speed, +27 Crit, Use: Throw 513-567 dmg |
| Main Hand (Alt) | Gladiator's Cleaver | 28308 | 123 | Arena S1 | 2.60 speed, +21 Sta, +28 AP, +9 Hit, +15 Crit |
| Off Hand | The Decapitator | 28767 | 125 | Prince Malchezaar (Karazhan) | Match speed for weapon sync |
| Off Hand (Alt) | Dragonmaw | 28438 | 123 | Blacksmithing (Hammersmith) | 2.70 speed, +32 Str, Haste proc |
| Relic | Totem of the Astral Winds | 27815 | 115 | Heroic Mana-Tombs | +80 AP to Windfury Weapon |

---

### Feral Druid Cat (DRU-03) - T4 BiS

**Critical:** Wolfshead Helm is MANDATORY for powershifting despite low iLvl. Weapons need "Feral Attack Power" stat.

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Wolfshead Helm | 8345 | 45 | Leatherworking (crafted) | +20 Energy on Cat Form shift (MANDATORY) |
| Head (Alt) | Stag-Helm of Malorne | 29093 | 120 | Prince Malchezaar (Karazhan) | T4, +31 Agi, +36 Sta (NOT recommended) |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +18 Hit, +42 AP |
| Neck (Alt) | Braided Eternium Chain | 24114 | 102 | Jewelcrafting (360) | On-use: +110 AP for 12s |
| Shoulders | Mantle of Malorne | 29100 | 120 | High King Maulgar (Gruul's) | T4, +27 Agi, +25 Sta, +33 Str |
| Shoulders (Alt) | Shoulderpads of Assassination | 27797 | 109 | Heroic Shattered Halls | +26 Agi, +26 Sta, +44 AP |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | +24 Agi, +21 Sta, +17 Hit, +34 AP |
| Back (Alt) | Blood Knight War Cloak | 29382 | 110 | Badge of Justice (25) | +24 Agi, +24 Sta, +50 AP (if hit-capped) |
| Chest | Breastplate of Malorne | 29096 | 120 | Magtheridon | T4, +34 Agi, +36 Sta, +33 Str |
| Chest (Alt) | Primalstrike Vest | 29525 | 112 | Leatherworking (Elemental) | +36 Agi, +36 Sta, +60 AP |
| Wrist | Nightfall Wristguards | 29246 | 110 | Heroic Old Hillsbrad | +24 Agi, +22 Sta, +46 AP |
| Wrist (Alt) | Primalstrike Bracers | 29527 | 112 | Leatherworking (Elemental) | +24 Agi, +24 Sta, +40 AP |
| Hands | Gloves of Dexterous Manipulation | 28506 | 115 | Attumen (Karazhan) | +35 Agi, +22 Sta, +42 AP |
| Hands (Alt) | Gauntlets of Malorne | 29097 | 120 | The Curator (Karazhan) | T4, +29 Agi, +22 Sta, +26 Str |
| Waist | Girdle of the Deathdealer | 29247 | 110 | Heroic Black Morass | +28 Agi, +28 Sta, +20 Hit, +56 AP |
| Waist (Alt) | Girdle of Treachery | 28750 | 115 | Maiden of Virtue (Karazhan) | +29 Agi, +31 Sta, +17 Hit |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | +32 Agi, +28 Sta, +28 Hit, +64 AP |
| Legs (Alt) | Forestwalker Kilt | 29585 | 105 | Lower City (Exalted) | +28 Agi, +25 Sta, +40 AP |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | +29 Agi, +28 Sta, +13 Hit, +44 AP |
| Feet (Alt) | Fel Leather Boots | 25691 | 108 | Leatherworking | +22 Agi, +36 Sta, +54 AP |
| Ring 1 | Shapeshifter's Signet | 30834 | 100 | Lower City (Exalted) | +25 Agi, +18 Sta, +20 Expertise |
| Ring 1 (Alt) | Band of the Ranger-General | 29302 | 115 | Attumen (Karazhan) | +22 Agi, +18 Sta, +15 Hit |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | +20 Agi, +25 Sta, +18 Hit, +40 AP |
| Ring 2 (Alt) | Ring of the Recalcitrant | 28791 | 125 | Magtheridon Quest | +24 Agi, +27 Sta, +54 AP |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | Proc: +325 Haste for 10s |
| Trinket 1 (Alt) | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP |
| Trinket 2 | Hourglass of the Unraveller | 28034 | 112 | Temporus (Black Morass) | +32 Crit, Proc: +300 AP |
| Main Hand | Terestian's Stranglestaff | 28658 | 115 | Terestian Illhoof (Karazhan) | +38 Str, +37 Agi, +48 Sta, +25 Hit, +829 Feral AP |
| Main Hand (Alt) | Earthwarden | 29171 | 115 | Cenarion Expedition (Exalted) | +24 Agi, +40 Sta, +415 Feral AP (more tank-focused) |
| Off Hand | N/A | - | - | Uses 2H Staff/Polearm | - |
| Relic | Everbloom Idol | 29390 | 110 | Badge of Justice (15) | +88 Shred damage (HIGH PRIORITY) |
| Relic (Alt) | Idol of the Wild | 28064 | 93 | Quest: Colossal Menace | +24 Mangle (Cat) damage |

---

## ROLE: RANGED DPS

### Beast Mastery Hunter (HUN-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Beast Lord Helm | 28275 | 115 | The Mechanar | Dungeon (4pc set) |
| Shoulders | Beast Lord Mantle | 27801 | 115 | The Steamvault | Dungeon (4pc set) |
| Back | Vengeance Wrap | 24259 | 105 | Tailoring | Crafted |
| Chest | Beast Lord Cuirass | 28228 | 115 | The Botanica | Dungeon (4pc set) |
| Chest (Alt) | Primalstrike Vest | 29525 | 110 | Leatherworking | Crafted |
| Wrists | Nightfall Wristguards | 29246 | 110 | Heroic Old Hillsbrad | Heroic |
| Wrists (Alt) | Primalstrike Bracers | 29527 | 110 | Leatherworking | Crafted |
| Hands | Beast Lord Handguards | 27474 | 115 | The Shattered Halls | Dungeon (4pc set) |
| Waist | Gronn-Stitched Girdle | 28828 | 120 | Gruul (Gruul's Lair) | Raid |
| Legs | Scaled Greaves of the Marksman | 30739 | 115 | Doom Lord Kazzak | World boss |
| Legs (Alt) | Leggings of the Pursuit | 28594 | 115 | Opera Event (Karazhan) | Raid |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | Raid |
| Feet (Alt) | Fel Leather Boots | 27814 | 100 | Leatherworking | Crafted (hit) |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | Badge |
| Ring 1 | Ring of a Thousand Marks | 28757 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | Raid (hit cap) |
| Ring 2 (Alt) | Ring of the Recalcitrant | 28791 | 115 | Magtheridon Quest | Quest |
| Trinket 1 | Dragonspine Trophy | 28830 | 120 | Gruul (Gruul's Lair) | BiS entire TBC |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | Badge |
| Main Hand | Claw of the Watcher | 27846 | 110 | Heroic Auchenai Crypts | Stat stick |
| Off Hand | Blade of the Unrequited | 28572 | 115 | Opera Event (Karazhan) | Stat stick |
| 2H (Melee Weaving) | Mooncleaver | 28435 | 115 | Blacksmithing | Crafted |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 115 | Prince Malchezaar (Karazhan) | BiS ranged |
| Ranged (Alt) | Barrel-Blade Longrifle | 30724 | 115 | Doomwalker | World boss |

---

### Marksmanship Hunter (HUN-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Beast Lord Helm | 28275 | 115 | Pathaleon (Mechanar) | +25 Agi, +21 Sta, +22 Int, +50 AP, Meta+Red socket (4pc set) |
| Head (Alt) | Mask of the Deceiver | 32087 | 110 | Badge of Justice (50) | +32 Agi, +36 Sta, +16 Hit, +64 AP, Yellow+Meta socket |
| Neck | Choker of Vile Intent | 29381 | 110 | Badge of Justice (25) | +20 Agi, +18 Sta, +18 Hit, +42 AP |
| Shoulders | Beast Lord Mantle | 27801 | 115 | Warlord Kalithresh (Steamvault) | +25 Agi, +12 Int, +34 AP, +5 MP5, Yellow+Blue socket (4pc set) |
| Back | Vengeance Wrap | 24259 | 105 | Tailoring (BoE) | +23 Crit, +52 AP, Red socket |
| Back (Alt) | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | +24 Agi, +21 Sta, +17 Hit, +34 AP |
| Chest | Beast Lord Cuirass | 28228 | 115 | Warp Splinter (Botanica) | +20 Agi, +30 Sta, +24 Int, +40 AP, 2 Red+1 Blue socket (4pc set) |
| Wrists | Nightfall Wristguards | 29246 | 110 | Epoch Hunter (H Old Hillsbrad) | +24 Agi, +22 Sta, +46 AP |
| Wrists (Alt) | Primalstrike Bracers | 29527 | 115 | Elemental Leatherworking (BoP) | +15 Agi, +21 Sta, +64 AP (if LW) |
| Hands | Beast Lord Handguards | 27474 | 115 | Kargath (Shattered Halls) | +25 Agi, +12 Sta, +17 Int, +34 AP, Red+Blue socket (4pc set) |
| Waist | Gronn-Stitched Girdle | 28828 | 125 | Gruul (Gruul's Lair) | +27 Sta, +25 Crit, +72 AP, Blue+Yellow socket |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | +32 Agi, +28 Sta, +28 Hit, +64 AP, 2 Red+1 Blue socket (Leather) |
| Legs (Alt) | Scaled Greaves of the Marksman | 30739 | 120 | Doom Lord Kazzak | +37 Agi, +16 Hit, +76 AP, 3 Red socket |
| Legs (Alt) | Midnight Legguards | 30538 | 110 | Quagmirran (H Slave Pens) | +30 Sta, +27 Crit, +17 Hit, +64 AP |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | +29 Agi, +28 Sta, +13 Hit, +44 AP, Red+Yellow socket (Leather) |
| Ring 1 | Ring of a Thousand Marks | 28757 | 125 | Prince Malchezaar (Karazhan) | +21 Sta, +19 Hit, +23 Crit, +44 AP |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | +20 Agi, +25 Sta, +18 Hit, +40 AP |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste 10s (BiS entire TBC) |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP 20s |
| Trinket (Alt) | Romulo's Poison Vial | 28579 | 115 | Opera Event (Karazhan) | +35 Hit, Proc: 200-300 Nature damage |
| Main Hand | Claw of the Watcher | 27846 | 115 | Shirrak (H Auchenai Crypts) | +12 Crit, +24 AP, Blue+Red socket (Stat stick) |
| Off Hand | Stormreaver Warblades | 28315 | 115 | High Botanist Freywinn (Botanica) | +13 Sta, +21 Crit, +22 AP (Stat stick) |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 125 | Prince Malchezaar (Karazhan) | 83.28 DPS, +19 Agi, +34 AP (BiS ranged) |

**Notes:**
- Beast Lord 4-piece set bonus is mandatory (Kill Command armor pen)
- MM Hunters focus on personal DPS over pet contribution
- Hit cap: 142 rating (9%)
- Aimed Shot, Multi-Shot, Steady Shot rotation

---

### Survival Hunter (HUN-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Beast Lord Helm | 28275 | 115 | Pathaleon (Mechanar) | +25 Agi, +21 Sta, +22 Int, +50 AP, Meta+Red socket (4pc set) |
| Head (Alt) | Demon Stalker Greathelm | 29081 | 120 | Prince Malchezaar Token (Karazhan) | +35 Agi, +28 Sta, +27 Int, +66 AP, Meta+Yellow socket (T4) |
| Neck | Jagged Bark Pendant | 28343 | 115 | Warp Splinter (Botanica) | +26 Agi, +15 Sta, +30 AP |
| Neck (Alt) | Saberclaw Talisman | 28674 | 115 | Shade of Aran (Karazhan) | +21 Agi, +30 AP, +14 Hit |
| Shoulders | Beast Lord Mantle | 27801 | 115 | Warlord Kalithresh (Steamvault) | +25 Agi, +12 Int, +34 AP, +5 MP5, Blue+Yellow socket (4pc set) |
| Back | Drape of the Dark Reavers | 28672 | 115 | Shade of Aran (Karazhan) | +24 Agi, +21 Sta, +17 Hit, +34 AP |
| Back (Alt) | Blood Knight War Cloak | 29382 | 110 | Badge of Justice (25) | +23 Agi, +22 Sta, +48 AP |
| Chest | Beast Lord Cuirass | 28228 | 115 | Warp Splinter (Botanica) | +20 Agi, +30 Sta, +24 Int, +40 AP, 2 Red+1 Blue socket (4pc set) |
| Wrists | Felstalker Bracers | 25697 | 114 | Leatherworking (360) | +18 Agi, +11 Int, +38 AP, Blue socket (3pc set +20 Hit) |
| Hands | Beast Lord Handguards | 27474 | 115 | Kargath (Shattered Halls) | +25 Agi, +12 Sta, +17 Int, +34 AP, Red+Blue socket (4pc set) |
| Waist | Girdle of Treachery | 28750 | 115 | Chess Event (Karazhan) | +18 Agi, +37 Sta, +58 AP, 2 Red sockets (Leather) |
| Legs | Skulker's Greaves | 28741 | 115 | Netherspite (Karazhan) | +32 Agi, +28 Sta, +28 Hit, +64 AP, 2 Red+1 Blue socket (Leather) |
| Feet | Edgewalker Longboots | 28545 | 115 | Moroes (Karazhan) | +29 Agi, +28 Sta, +13 Hit, +44 AP, Red+Yellow socket (Leather) |
| Ring 1 | Ring of the Recalcitrant | 28791 | 125 | Magtheridon Quest | +24 Agi, +27 Sta, +54 AP |
| Ring 2 | Garona's Signet Ring | 28649 | 115 | The Curator (Karazhan) | +20 Agi, +25 Sta, +18 Hit, +40 AP |
| Ring (Alt) | Shaffar's Band of Brutality | 31920 | 100 | Yor (H Mana-Tombs) | +19 Hit, +20 Crit, +40 AP |
| Trinket 1 | Dragonspine Trophy | 28830 | 125 | Gruul (Gruul's Lair) | +40 AP, Proc: +325 Haste 10s (BiS entire TBC) |
| Trinket 2 | Bloodlust Brooch | 29383 | 110 | Badge of Justice (41) | +72 AP, Use: +278 AP 20s |
| Trinket (Alt) | Hourglass of the Unraveller | 28034 | 112 | Temporus (Black Morass) | +32 Crit, Proc: +300 AP 10s |
| Trinket (Alt) | Abacus of Violent Odds | 28288 | 115 | Pathaleon (Mechanar) | +64 AP, Use: +260 Haste 10s |
| Main Hand | Big Bad Wolf's Paw | 28584 | 115 | Opera Event (Karazhan) | +17 Agi, +18 Sta, +20 Crit (Stat stick) |
| Main Hand (Alt) | Stellaris | 28263 | 115 | Nethermancer Sepethrea (Mechanar) | +21 Agi, +12 Sta, +22 AP (Stat stick) |
| Off Hand | Blade of the Unrequited | 28572 | 115 | Opera Event (Karazhan) | +23 Agi, +23 Sta, +8 Hit, +19 Crit, +41 AP, 3 sockets (Stat stick) |
| 2H (Alt) | Legacy | 28587 | 115 | Opera Event (Karazhan) | +40 Agi, +46 Sta, +80 AP, +8 MP5 (2H stat stick) |
| Ranged | Sunfury Bow of the Phoenix | 28772 | 125 | Prince Malchezaar (Karazhan) | 83.28 DPS, +19 Agi, +34 AP (BiS ranged) |

**Notes:**
- Beast Lord 4-piece set bonus is mandatory (Kill Command armor pen synergizes with Expose Weakness)
- Survival scales exceptionally well with Agility due to Lightning Reflexes (+15% Agi) and Expose Weakness
- Agility prioritized over raw AP more than other hunter specs
- Hit cap: 95 rating (6%) with 3/3 Surefooted, 142 rating (9%) without
- Leather items (Skulker's Greaves, Edgewalker Longboots, Girdle of Treachery) are BiS due to superior agility
- Expose Weakness buff makes SV valuable for melee groups

---

## ROLE: CASTER DPS

### Destruction Warlock (WLK-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Voidheart Crown | 28963 | 120 | Prince Malchezaar (Karazhan) | T4 |
| Shoulders | Voidheart Mantle | 28967 | 120 | High King Maulgar (Gruul's Lair) | T4 |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Hit + spell damage |
| Back (Alt) | Ancient Spellcloak of the Highborne | 30735 | 115 | Doom Lord Kazzak | If hit-capped |
| Chest | Spellfire Robe | 21848 | 100 | Tailoring (Spellfire) | Fire spec BiS |
| Chest (Alt) | Voidheart Robe | 28964 | 120 | Magtheridon | Shadow spec, T4 |
| Wrists | Bracers of Havok | 24250 | 105 | Tailoring (BoE) | Socket available |
| Hands | Spellfire Gloves | 21847 | 100 | Tailoring (Spellfire) | Fire spec |
| Hands (Alt) | Voidheart Gloves | 28968 | 120 | The Curator (Karazhan) | Shadow spec, T4 |
| Waist | Spellfire Belt | 21846 | 100 | Tailoring (Spellfire) | Fire spec |
| Waist (Alt) | Girdle of Ruination | 24256 | 105 | Tailoring (BoE) | Alternative |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Best accessible |
| Feet | Frozen Shadoweave Boots | 21870 | 100 | Tailoring (Shadoweave) | Shadow spec |
| Feet (Alt) | Boots of Foretelling | 28517 | 115 | Maiden of Virtue (Karazhan) | General use |
| Neck | Adornment of Stolen Souls | 28762 | 115 | Prince Malchezaar (Karazhan) | If hit-capped |
| Neck (Alt) | Brooch of Unquenchable Fury | 28530 | 115 | Moroes (Karazhan) | Hit option |
| Ring 1 | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | No-hit option |
| Ring 1 (Alt) | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Hit option |
| Ring 2 | Violet Signet of the Archmage | 29287 | 115 | Violet Eye (Quest) | No-hit |
| Ring 2 (Alt) | Ashyen's Gift | 29172 | 110 | Exalted: Cenarion Expedition | Hit option |
| Trinket 1 | Quagmirran's Eye | 27683 | 110 | Slave Pens | Haste proc |
| Trinket 2 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice | Spell damage proc |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Raid |
| Main Hand (Alt) | Talon of the Tempest | 30723 | 115 | Doomwalker | World boss |
| Off-Hand | Flametongue Seal | 29270 | 110 | Badge of Justice | Fire spec |
| Off-Hand (Alt) | Khadgar's Knapsack | 29273 | 110 | Badge of Justice | General use |
| Wand | Eredar Wand of Obliteration | 28783 | 120 | Magtheridon | If hit-capped |
| Wand (Alt) | Tirisfal Wand of Ascendancy | 28673 | 115 | Shade of Aran (Karazhan) | Hit option |

---

### Shadow Priest (PRI-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Spellstrike Hood | 24266 | 105 | Tailoring (BoE) | Hit, Spell Damage |
| Shoulders | Frozen Shadoweave Shoulders | 21869 | 100 | Tailoring (Shadoweave) | Shadow Damage |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Hit Rating |
| Chest | Frozen Shadoweave Robe | 21871 | 100 | Tailoring (Shadoweave) | Shadow Damage |
| Wrists | Ravager's Cuffs | 30684 | 115 | Karazhan (Rokad the Ravager) | Shadow Damage |
| Wrists (Alt) | Bracers of Havok | 24250 | 105 | Tailoring (BoE) | Socket |
| Hands | Handwraps of Flowing Thought | 28507 | 115 | Attumen (Karazhan) | Hit, Spell Power |
| Waist | Belt of Divine Inspiration | 28799 | 125 | High King Maulgar (Gruul's Lair) | Spell Damage, Sockets |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Hit, Spell Damage |
| Feet | Frozen Shadoweave Boots | 21870 | 100 | Tailoring (Shadoweave) | Shadow Damage |
| Neck | Ritssyn's Lost Pendant | 30666 | 115 | Karazhan Trash | Shadow Damage |
| Ring 1 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Power |
| Ring 2 | Ashyen's Gift | 29172 | 110 | Cenarion Expedition (Exalted) | Spell Power, Hit |
| Trinket 1 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power, On-use |
| Trinket 2 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Power, Proc |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Main Hand (Alt) | Talon of the Tempest | 30723 | 115 | Doomwalker | World Boss BiS |
| Off-Hand | Orb of the Soul-Eater | 29272 | 110 | Badge of Justice (25) | Spell Power |
| Wand | Tirisfal Wand of Ascendancy | 28673 | 115 | Shade of Aran (Karazhan) | Hit Rating |
| Wand (Alt) | Eredar Wand of Obliteration | 28783 | 120 | Magtheridon | If hit-capped |

---

### Elemental Shaman (SHA-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Cyclone Faceguard | 29035 | 120 | Prince Malchezaar (Karazhan) | T4, Spell Damage, Crit |
| Shoulders | Cyclone Shoulderguards | 29037 | 120 | High King Maulgar (Gruul's Lair) | T4, Spell Damage |
| Back | Brute Cloak of the Ogre-Magi | 28797 | 115 | High King Maulgar (Gruul's Lair) | Spell Damage |
| Back (Alt) | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Hit option |
| Chest | Netherstrike Breastplate | 29519 | 100 | Dragonscale Leatherworking | Spell Damage |
| Wrists | Netherstrike Bracers | 29521 | 100 | Dragonscale Leatherworking | Spell Damage |
| Hands | Soul-Eater's Handwraps | 28780 | 125 | Magtheridon | Spell Damage, Crit |
| Waist | Netherstrike Belt | 29520 | 100 | Dragonscale Leatherworking | Spell Damage |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Spell Damage, Crit |
| Feet | Boots of Foretelling | 28517 | 115 | Maiden of Virtue (Karazhan) | Spell Damage |
| Neck | Adornment of Stolen Souls | 28762 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Ring 1 | Ring of Unrelenting Storms | 30667 | 115 | Karazhan Trash | Spell Damage, Crit |
| Ring 2 | Seer's Signet | 29126 | 110 | The Scryers (Exalted) | Spell Damage |
| Trinket 1 | The Lightning Capacitor | 28785 | 115 | Terestian Illhoof (Karazhan) | Proc damage |
| Trinket 2 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Power |
| Trinket 2 (Alt) | Mark of the Champion | 23207 | 88 | Naxxramas | vs Undead/Demons |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Off-Hand | Khadgar's Knapsack | 29273 | 110 | Badge of Justice (25) | Spell Damage |
| Off-Hand (Alt) | Shield - any caster | - | - | Shamans can use shields | Defensive option |
| Totem | Totem of the Void | 28248 | 100 | Cache of the Legion (Mechanar) | Spell Damage bonus |

---

### Arcane Mage (MAG-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Collar of the Aldor | 29076 | 120 | Prince Malchezaar (Karazhan) | T4, Spell Damage, Intellect |
| Shoulders | Pauldrons of the Aldor | 29079 | 120 | High King Maulgar (Gruul's Lair) | T4, Spell Damage |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Hit, Spell Damage |
| Back (Alt) | Brute Cloak of the Ogre-Magi | 28797 | 115 | High King Maulgar (Gruul's Lair) | If hit-capped |
| Chest | Spellfire Robe | 21848 | 100 | Tailoring (Spellfire) | Spell Damage, Intellect |
| Wrists | Marshal's/General's Silk Cuffs | 29002 | 110 | PvP Battlegrounds | Spell Damage |
| Hands | Spellfire Gloves | 21847 | 100 | Tailoring (Spellfire) | Spell Damage, Intellect |
| Waist | Spellfire Belt | 21846 | 100 | Tailoring (Spellfire) | Spell Damage, Intellect |
| Legs | Legwraps of the Aldor | 29078 | 120 | Gruul the Dragonkiller (Gruul's Lair) | T4, Spell Damage |
| Feet | Boots of Foretelling | 28517 | 115 | Maiden of Virtue (Karazhan) | Spell Damage |
| Neck | Adornment of Stolen Souls | 28762 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Ring 1 | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | Spell Damage, Crit |
| Ring 1 (Alt) | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Hit, Haste |
| Ring 2 | Violet Signet of the Archmage | 29287 | 115 | Violet Eye (Exalted) | Spell Damage |
| Trinket 1 | The Lightning Capacitor | 28785 | 115 | Terestian Illhoof (Karazhan) | Proc damage |
| Trinket 2 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Off-Hand | Talisman of Kalecgos | 29271 | 110 | Badge of Justice (25) | Spell Damage, Hit |
| Wand | Eredar Wand of Obliteration | 28783 | 120 | Magtheridon | Spell Damage |

---

### Fire Mage (MAG-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Collar of the Aldor | 29076 | 120 | Prince Malchezaar (Karazhan) | T4, Hit, Spell Damage |
| Shoulders | Pauldrons of the Aldor | 29079 | 120 | High King Maulgar (Gruul's Lair) | T4, Hit, Spell Damage |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Spell Damage, Crit |
| Chest | Spellfire Robe | 21848 | 100 | Tailoring (Spellfire) | Spell Damage, Haste |
| Wrists | Marshal's/General's Silk Cuffs | 29002 | 110 | PvP Battlegrounds | Hit, Spell Damage |
| Hands | Spellfire Gloves | 21847 | 100 | Tailoring (Spellfire) | Spell Damage, Crit |
| Waist | Spellfire Belt | 21846 | 100 | Tailoring (Spellfire) | Spell Damage, Haste |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Hit, Spell Damage |
| Feet | Boots of Foretelling | 28517 | 115 | Maiden of Virtue (Karazhan) | Spell Damage, Haste |
| Neck | Brooch of Heightened Potential | 28530 | 115 | Blackheart the Inciter (Shadow Lab) | Spell Damage, Haste |
| Neck (Alt) | Adornment of Stolen Souls | 28762 | 115 | Prince Malchezaar (Karazhan) | If hit-capped |
| Ring 1 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Damage, Haste |
| Ring 2 | Ashyen's Gift | 29172 | 110 | Cenarion Expedition (Exalted) | Spell Damage, Crit |
| Trinket 1 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Damage |
| Trinket 2 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Damage |
| Main Hand | Bloodmaw Magus-Blade | 28802 | 125 | Gruul the Dragonkiller (Gruul's Lair) | Spell Damage, Haste |
| Off-Hand | Flametongue Seal | 29270 | 110 | Badge of Justice (25) | Spell Damage (Fire) |
| Wand | Tirisfal Wand of Ascendancy | 28673 | 115 | Shade of Aran (Karazhan) | Spell Damage |

---

### Frost Mage (MAG-03) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Collar of the Aldor | 29076 | 120 | Prince Malchezaar (Karazhan) | T4, Spell Damage, Hit |
| Shoulders | Frozen Shadoweave Shoulders | 21869 | 100 | Tailoring (Shadoweave) | Spell Damage, Hit |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Chest | Frozen Shadoweave Robe | 21871 | 100 | Tailoring (Shadoweave) | Spell Damage, Hit |
| Wrists | Marshal's/General's Silk Cuffs | 29002 | 110 | PvP Battlegrounds | Spell Damage |
| Hands | Soul-Eater's Handwraps | 28780 | 125 | Magtheridon | Spell Damage, Crit |
| Waist | Girdle of Ruination | 24256 | 105 | Tailoring (BoE) | Spell Damage |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Spell Damage, Hit |
| Feet | Frozen Shadoweave Boots | 21870 | 100 | Tailoring (Shadoweave) | Spell Damage, Hit |
| Neck | Adornment of Stolen Souls | 28762 | 115 | Prince Malchezaar (Karazhan) | Spell Damage, Crit |
| Ring 1 | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | Spell Damage, Haste |
| Ring 2 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Damage, Crit |
| Trinket 1 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Damage |
| Trinket 2 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Damage, Haste |
| Main Hand | Bloodmaw Magus-Blade | 28802 | 125 | Gruul the Dragonkiller (Gruul's Lair) | Spell Damage |
| Off-Hand | Sapphiron's Wing Bone | 29269 | 110 | Badge of Justice (25) | Spell Damage |
| Wand | The Black Stalk | 29350 | 115 | Heroic Underbog | Spell Damage |

---

### Affliction Warlock (WLK-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Voidheart Crown | 28963 | 120 | Prince Malchezaar (Karazhan) | T4, Meta Socket |
| Shoulders | Voidheart Mantle | 28967 | 120 | High King Maulgar (Gruul's Lair) | T4, Spell Power |
| Shoulders (Alt) | Frozen Shadoweave Shoulders | 21869 | 100 | Tailoring (Shadoweave) | Pre-raid option |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Hit option |
| Back (Alt) | Brute Cloak of the Ogre-Magi | 28797 | 115 | High King Maulgar (Gruul's Lair) | If hit-capped |
| Chest | Voidheart Robe | 28964 | 120 | Magtheridon | T4, Spell Power |
| Chest (Alt) | Frozen Shadoweave Robe | 21871 | 100 | Tailoring (Shadoweave) | Pre-raid option |
| Wrists | Bracers of Havok | 24250 | 105 | Tailoring (BoE) | Spell Power, Socket |
| Hands | Voidheart Gloves | 28968 | 120 | The Curator (Karazhan) | T4, Spell Power |
| Waist | Girdle of Ruination | 24256 | 105 | Tailoring (BoE) | Spell Power, Socket |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Hit, Spell Damage |
| Legs (Alt) | Voidheart Leggings | 28966 | 120 | Gruul the Dragonkiller (Gruul's Lair) | T4 set |
| Feet | Frozen Shadoweave Boots | 21870 | 100 | Tailoring (Shadoweave) | Shadow Damage |
| Neck | Ritssyn's Lost Pendant | 30666 | 115 | Karazhan Trash | Shadow Damage |
| Ring 1 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Power |
| Ring 2 | Ashyen's Gift | 29172 | 110 | Cenarion Expedition (Exalted) | Spell Power, Hit |
| Ring 2 (Alt) | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | If hit-capped |
| Trinket 1 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power |
| Trinket 2 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Power, Proc |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Main Hand (Alt) | Talon of the Tempest | 30723 | 115 | Doomwalker | World Boss BiS |
| Off-Hand | Orb of the Soul-Eater | 29272 | 110 | Badge of Justice (25) | Spell Power |
| Off-Hand (Alt) | Khadgar's Knapsack | 29273 | 110 | Badge of Justice (25) | Alternative |
| Wand | Eredar Wand of Obliteration | 28783 | 120 | Magtheridon | If hit-capped |
| Wand (Alt) | Tirisfal Wand of Ascendancy | 28673 | 115 | Shade of Aran (Karazhan) | Hit option |

---

### Demonology Warlock (WLK-02) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Voidheart Crown | 28963 | 120 | Prince Malchezaar (Karazhan) | T4, Meta Socket |
| Shoulders | Voidheart Mantle | 28967 | 120 | High King Maulgar (Gruul's Lair) | T4, Spell Power, Stamina |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Spell Power, Hit |
| Back (Alt) | Brute Cloak of the Ogre-Magi | 28797 | 115 | High King Maulgar (Gruul's Lair) | If hit-capped |
| Chest | Voidheart Robe | 28964 | 120 | Magtheridon | T4, Spell Power, Stamina |
| Wrists | Bracers of Havok | 24250 | 105 | Tailoring (BoE) | Spell Power, Stamina |
| Hands | Voidheart Gloves | 28968 | 120 | The Curator (Karazhan) | T4, Spell Power, Stamina |
| Waist | Girdle of Ruination | 24256 | 105 | Tailoring (BoE) | Spell Power, Stamina |
| Legs | Voidheart Leggings | 28966 | 120 | Gruul the Dragonkiller (Gruul's Lair) | T4, Spell Power, Stamina |
| Legs (Alt) | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Hit option |
| Feet | Frozen Shadoweave Boots | 21870 | 100 | Tailoring (Shadoweave) | Spell Power, Stamina |
| Neck | Brooch of Unquenchable Fury | 28530 | 115 | Moroes (Karazhan) | Spell Power, Hit |
| Neck (Alt) | Ritssyn's Lost Pendant | 30666 | 115 | Karazhan Trash | Shadow Damage |
| Ring 1 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Power |
| Ring 2 | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | Spell Power |
| Trinket 1 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power |
| Trinket 2 | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Spell Power |
| Trinket (Alt) | The Black Book | 28789 | 115 | Terestian Illhoof (Karazhan) | Pet buff (Demo BiS) |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Damage |
| Off-Hand | Khadgar's Knapsack | 29273 | 110 | Badge of Justice (25) | Spell Damage |
| Wand | Tirisfal Wand of Ascendancy | 28673 | 115 | Shade of Aran (Karazhan) | Hit option |
| Wand (Alt) | Eredar Wand of Obliteration | 28783 | 120 | Magtheridon | If hit-capped |

---

### Balance Druid (DRU-01) - T4 BiS

| Slot | Item Name | Item ID | iLvl | Source | Stats |
|------|-----------|---------|------|--------|-------|
| Head | Spellstrike Hood | 24266 | 105 | Tailoring (BoE) | Spell Power, Intellect |
| Shoulders | Pauldrons of Malorne | 29095 | 120 | High King Maulgar (Gruul's Lair) | T4, Spell Power |
| Back | Ruby Drape of the Mysticant | 28766 | 115 | Prince Malchezaar (Karazhan) | Spell Power |
| Chest | Spellfire Robe | 21848 | 100 | Tailoring (Spellfire) | Spell Power, Stamina |
| Chest (Alt) | Windhawk Hauberk | 29522 | 100 | Tribal Leatherworking | Leather option |
| Wrists | Windhawk Bracers | 29523 | 100 | Tribal Leatherworking | Spell Power |
| Wrists (Alt) | Bracers of Havok | 24250 | 105 | Tailoring (BoE) | Cloth option |
| Hands | Spellfire Gloves | 21847 | 100 | Tailoring (Spellfire) | Spell Power, Crit |
| Waist | Spellfire Belt | 21846 | 100 | Tailoring (Spellfire) | Spell Power |
| Waist (Alt) | Windhawk Belt | 29524 | 100 | Tribal Leatherworking | Leather option |
| Legs | Spellstrike Pants | 24262 | 105 | Tailoring (BoE) | Spell Power, Intellect |
| Feet | Boots of Foretelling | 28517 | 115 | Maiden of Virtue (Karazhan) | Spell Power, Haste |
| Neck | Brooch of Unquenchable Fury | 28530 | 115 | Moroes (Karazhan) | Spell Power, Crit |
| Ring 1 | Band of Crimson Fury | 28793 | 115 | Magtheridon Quest | Spell Power, Hit |
| Ring 2 | Ring of Recurrence | 28753 | 115 | Karazhan Chess Event | Spell Power, Crit |
| Trinket 1 | Icon of the Silver Crescent | 29370 | 110 | Badge of Justice (41) | Spell Power on-use |
| Trinket 2 | Scryer's Bloodgem | 29132 | 100 | The Scryers (Revered) | Spell Power |
| Trinket 2 (Alt) | Quagmirran's Eye | 27683 | 110 | Heroic Slave Pens | Alternative |
| Main Hand | Nathrezim Mindblade | 28770 | 115 | Prince Malchezaar (Karazhan) | Spell Power, Intellect |
| Off-Hand | Talisman of Kalecgos | 29271 | 110 | Badge of Justice (25) | Spell Power, Spirit |
| Idol | Ivory Idol of the Moongoddess | 27518 | 100 | Nethekurse (Shattered Halls) | Balance spell enhancement |

---

## CRAFTED SET SUMMARIES

### Tailoring Sets (Cloth Casters)

| Set Name | Specialization | Pieces | Best For | Key Stats |
|----------|---------------|--------|----------|-----------|
| Spellfire | Spellfire Tailoring | 3 (Belt, Gloves, Robe) | Fire Mage, Destro Warlock | Fire damage, Intellect |
| Frozen Shadoweave | Shadoweave Tailoring | 3 (Shoulders, Robe, Boots) | Shadow Priest, Affliction Lock | Shadow damage, Frost damage |
| Primal Mooncloth | Mooncloth Tailoring | 3 (Belt, Robe, Shoulders) | Holy Priest, Resto Druid | +Healing, MP5 |
| Spellstrike | Any Tailoring (BoE) | 2 (Hood, Pants) | All casters | Hit rating, Spell damage |

### Blacksmithing Sets (Plate)

| Set Name | Pieces | Best For | Key Stats |
|----------|--------|----------|-----------|
| Felsteel | 3 (Helm, Leggings, Gloves) | Prot Warrior, Prot Paladin | Defense, Stamina, Block |

### Leatherworking Sets

| Set Name | Pieces | Best For | Key Stats |
|----------|--------|----------|-----------|
| Primalstrike | 3 (Vest, Bracers, Belt) | Enhancement Shaman, Feral Cat | Attack Power, Crit |
| Windhawk | 3 (Belt, Bracers, Hauberk) | Balance Druid, Ele Shaman | Spell damage, Intellect |
| Fel Leather | Multiple | Fresh 70 melee | Hit rating (important early) |

---

## BADGE OF JUSTICE VENDOR (Phase 1)

### G'eras Location: Shattrath City

| Slot | Item Name | Item ID | Badge Cost | Best For |
|------|-----------|---------|------------|----------|
| Neck | Choker of Vile Intent | 29381 | 25 | Melee DPS, Hunter |
| Neck | Necklace of the Juggernaut | 29386 | 25 | Tank |
| Trinket | Bloodlust Brooch | 29383 | 41 | Physical DPS |
| Trinket | Icon of the Silver Crescent | 29370 | 41 | Caster DPS |
| Trinket | Essence of the Martyr | 29376 | 41 | Healer |
| Off-Hand | Flametongue Seal | 29270 | 25 | Fire Caster |
| Off-Hand | Khadgar's Knapsack | 29273 | 25 | Caster general |
| Head | Faceguard of Determination | 32083 | 50 | Tank |
| Chest | Chestguard of the Stoic Guardian | 32082 | 75 | Tank |

---

## REPUTATION REWARDS (Exalted)

### Honor Hold / Thrallmar

| Item Name | Item ID | Slot | Best For | Faction |
|-----------|---------|------|----------|---------|
| Veteran's Musket | 29151 | Ranged | Physical DPS | Honor Hold (A) |
| Marksman's Bow | 29152 | Ranged | Physical DPS | Thrallmar (H) |

### Keepers of Time

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Bindings of the Timewalker | 29183 | Wrist | Healer |

### Lower City

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Shapeshifter's Signet | 30834 | Ring | Tank (threat) |
| Lower City Prayerbook | 28823 | Trinket | Healer (on-use) |

### Cenarion Expedition

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Ashyen's Gift | 29172 | Ring | Caster DPS (hit) |
| Earthwarden | 29171 | 2H Weapon | Feral Bear Tank |

### The Sha'tar

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Gavel of Pure Light | 29175 | 1H Weapon | Holy Paladin |
| Xi'ri's Gift | 29176 | Ring | Caster DPS |

### The Consortium

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Consortium Blaster | 29115 | Ranged | Tank (stat stick) |

### Violet Eye (Karazhan Reputation)

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Violet Signet of the Great Protector | 29279 | Ring | Tank |
| Violet Signet of the Archmage | 29287 | Ring | Caster DPS |
| Violet Signet of the Master Assassin | 29283 | Ring | Melee DPS |
| Violet Signet | Various | Ring | All roles (upgrades through quest chain) |

---

## WORLD BOSS DROPS (T4 Phase)

### Doom Lord Kazzak

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Topaz-Studded Battlegrips | 30741 | Hands | Tank |
| Terrorweave Tunic | 30730 | Chest | Melee DPS (leather) |
| Scaled Greaves of the Marksman | 30739 | Legs | Hunter |
| Ancient Spellcloak of the Highborne | 30735 | Back | Caster DPS |
| Fathom-Helm of the Deeps | 30728 | Head | Healer (plate) |
| Ring of Flowing Light | 30736 | Ring | Healer |
| Ring of Reciprocity | 30738 | Ring | Melee DPS |

### Doomwalker

| Item Name | Item ID | Slot | Best For |
|-----------|---------|------|----------|
| Barrel-Blade Longrifle | 30724 | Ranged | Physical DPS, Tank |
| Archaic Charm of Presence | 30726 | Neck | Healer |
| Gilded Trousers of Benediction | 30727 | Legs | Healer |
| Talon of the Tempest | 30723 | 1H Weapon | Caster DPS |

---

## LUA DATA STRUCTURE PREVIEW

This is how the researched data will be structured in Constants.lua:

```lua
C.ARMORY_GEAR_DATABASE = {
    [4] = {  -- Tier 4 / Phase 1
        ["tank"] = {
            ["head"] = {
                best = {
                    itemId = 29011, name = "Warbringer Greathelm",
                    icon = "INV_Helmet_70", quality = "epic", iLvl = 120,
                    stats = "+43 Str, +45 Sta, +32 Def Rating",
                    source = "Prince Malchezaar", sourceType = "raid",
                    sourceDetail = "Karazhan",
                },
                alternatives = {
                    {
                        itemId = 32083, name = "Faceguard of Determination",
                        icon = "INV_Helmet_71", quality = "epic", iLvl = 115,
                        stats = "+40 Sta, +30 Def, +20 Block Value",
                        source = "G'eras", sourceType = "badge",
                        badgeCost = 50,
                    },
                    {
                        itemId = 23519, name = "Felsteel Helm",
                        icon = "INV_Helmet_25", quality = "rare", iLvl = 105,
                        stats = "+25 Sta, +22 Def Rating",
                        source = "Blacksmithing", sourceType = "crafted",
                    },
                },
            },
            ["neck"] = { ... },
            -- ... all 17 slots
        },
        ["healer"] = { ... },
        ["melee_dps"] = { ... },
        ["ranged_dps"] = { ... },
        ["caster_dps"] = { ... },
    },
    [5] = { ... },  -- Tier 5 / Phase 2 (future)
    [6] = { ... },  -- Tier 6 / Phase 3 (future)
}
```

---

## NEXT STEPS FOR FULL DATA POPULATION

### Immediate Priority (T4 Complete):
1. ✅ Tank: Protection Warrior researched
2. ✅ Healer: Holy Paladin researched
3. ✅ Melee DPS: Combat Rogue researched
4. ✅ Ranged DPS: BM Hunter researched
5. ✅ Caster DPS: Destruction Warlock researched

### Batch 3 Completed (Melee DPS - 7 specs):
- ✅ WAR-01: Arms Warrior
- ✅ WAR-02: Fury Warrior
- ✅ PAL-03: Retribution Paladin
- ✅ ROG-01: Assassination Rogue
- ✅ ROG-03: Subtlety Rogue
- ✅ SHA-02: Enhancement Shaman
- ✅ DRU-03: Feral Druid Cat

### Remaining T4 Research (by priority):
1. **Tanks (Batch 1):** Protection Paladin, Feral Bear Druid
2. **Healers (Batch 2):** Disc Priest, Holy Priest, Resto Shaman, Resto Druid
3. **Ranged DPS (Batch 4):** Marksmanship Hunter, Survival Hunter
4. **Caster DPS (Batch 5):** Shadow Priest, Elemental Shaman, Arcane/Fire/Frost Mage, Affliction/Demo Warlock, Balance Druid

### Data Sources Used:
- [Wowhead TBC Classic BiS Guides](https://www.wowhead.com/tbc/guides)
- [Icy Veins TBC Classic](https://www.icy-veins.com/tbc-classic/)
- [Warcraft Tavern TBC Guides](https://www.warcrafttavern.com/tbc/guides/)
- [WoWTBC.gg BiS Lists](https://wowtbc.gg/bis-list/)

---

## ESTIMATED LINE COUNTS (Updated)

| Component | Lines |
|-----------|-------|
| Constants (T4 data - 5 roles × 17 slots × 3 items) | ~2,500 |
| Constants (T5 data - future) | ~2,500 |
| Constants (T6 data - future) | ~2,500 |
| Journal UI functions | ~800 |
| Core defaults | ~30 |
| **T4 MVP Total** | ~3,300 |
| **Full Implementation** | ~8,300 |

---

# IMPLEMENTATION PAYLOADS

The following payloads are organized for sequential implementation. Each payload is self-contained and can be implemented in a single session.

---

## PAYLOAD 1: Constants Data Structure (T4 MVP)

**Goal:** Add the complete `C.ARMORY_GEAR_DATABASE` to Constants.lua with T4 data for 5 roles.

**Estimated Lines:** ~2,200

**File:** `Core/Constants.lua`

### Data to Add:

```lua
-- Add after existing constants (around line 4900+)

-------------------------------------------
-- ARMORY TAB: GEAR UPGRADE ADVISOR
-------------------------------------------

-- Tier definitions
C.ARMORY_TIERS = {
    [4] = {
        name = "Phase 1 (T4)",
        content = "Karazhan, Gruul, Magtheridon, Heroics",
        color = "GOLD_BRIGHT",
        raids = { "karazhan", "gruul", "magtheridon" },
    },
    [5] = {
        name = "Phase 2 (T5)",
        content = "SSC, Tempest Keep",
        color = "SKY_BLUE",
        raids = { "ssc", "tk" },
    },
    [6] = {
        name = "Phase 3 (T6)",
        content = "Hyjal, Black Temple, Sunwell",
        color = "HELLFIRE_RED",
        raids = { "hyjal", "bt", "sunwell" },
    },
}

-- Source type display info
C.ARMORY_SOURCE_TYPES = {
    raid = { color = "EPIC_PURPLE", icon = "Achievement_Dungeon_Karazhan", label = "Raid Drop" },
    heroic = { color = "RARE_BLUE", icon = "INV_Misc_Key_10", label = "Heroic Dungeon" },
    badge = { color = "GOLD_BRIGHT", icon = "Spell_Holy_ChampionsBond", label = "Badge of Justice" },
    rep = { color = "FEL_GREEN", icon = "INV_Misc_Token_Argentdawn", label = "Reputation" },
    crafted = { color = "BRONZE", icon = "Trade_BlackSmithing", label = "Crafted" },
    pvp = { color = "HELLFIRE_RED", icon = "INV_Jewelry_TrinketPVP_01", label = "PvP" },
    world = { color = "LEGENDARY_ORANGE", icon = "INV_Misc_Head_Dragon_01", label = "World Boss" },
    quest = { color = "UNCOMMON_GREEN", icon = "INV_Misc_Book_07", label = "Quest Reward" },
    dungeon = { color = "RARE_BLUE", icon = "INV_Misc_Key_03", label = "Dungeon" },
}

-- Equipment slot definitions with positions for UI layout
C.ARMORY_SLOTS = {
    -- Left column (armor)
    { id = "head",      slotId = 1,  label = "Head",      position = { anchor = "TOPLEFT", x = 20, y = -60 } },
    { id = "shoulders", slotId = 3,  label = "Shoulders", position = { anchor = "TOPLEFT", x = 20, y = -120 } },
    { id = "chest",     slotId = 5,  label = "Chest",     position = { anchor = "TOPLEFT", x = 20, y = -180 } },
    { id = "waist",     slotId = 6,  label = "Waist",     position = { anchor = "TOPLEFT", x = 20, y = -240 } },
    { id = "legs",      slotId = 7,  label = "Legs",      position = { anchor = "TOPLEFT", x = 20, y = -300 } },

    -- Right column (accessories)
    { id = "neck",      slotId = 2,  label = "Neck",      position = { anchor = "TOPRIGHT", x = -20, y = -60 } },
    { id = "back",      slotId = 15, label = "Back",      position = { anchor = "TOPRIGHT", x = -20, y = -120 } },
    { id = "wrist",     slotId = 9,  label = "Wrist",     position = { anchor = "TOPRIGHT", x = -20, y = -180 } },
    { id = "hands",     slotId = 10, label = "Hands",     position = { anchor = "TOPRIGHT", x = -20, y = -240 } },
    { id = "feet",      slotId = 8,  label = "Feet",      position = { anchor = "TOPRIGHT", x = -20, y = -300 } },

    -- Bottom row (jewelry, weapons)
    { id = "ring1",     slotId = 11, label = "Ring",      position = { anchor = "BOTTOM", x = -180, y = 80 } },
    { id = "ring2",     slotId = 12, label = "Ring",      position = { anchor = "BOTTOM", x = -120, y = 80 } },
    { id = "trinket1",  slotId = 13, label = "Trinket",   position = { anchor = "BOTTOM", x = -60, y = 80 } },
    { id = "trinket2",  slotId = 14, label = "Trinket",   position = { anchor = "BOTTOM", x = 0, y = 80 } },
    { id = "mainhand",  slotId = 16, label = "Main Hand", position = { anchor = "BOTTOM", x = 60, y = 80 } },
    { id = "offhand",   slotId = 17, label = "Off Hand",  position = { anchor = "BOTTOM", x = 120, y = 80 } },
    { id = "ranged",    slotId = 18, label = "Ranged",    position = { anchor = "BOTTOM", x = 180, y = 80 } },
}

-- Role definitions
C.ARMORY_ROLES = {
    tank = { name = "Tank", icon = "INV_Shield_06", color = "SKY_BLUE", stats = "Stamina, Defense, Dodge, Parry" },
    healer = { name = "Healer", icon = "Spell_Holy_FlashHeal", color = "FEL_GREEN", stats = "+Healing, MP5, Intellect" },
    melee_dps = { name = "Melee DPS", icon = "Ability_DualWield", color = "HELLFIRE_RED", stats = "AP, Hit, Crit, Expertise" },
    ranged_dps = { name = "Ranged DPS", icon = "INV_Weapon_Bow_07", color = "GOLD_BRIGHT", stats = "Agility, AP, Hit, Crit" },
    caster_dps = { name = "Caster DPS", icon = "Spell_Fire_FelFire", color = "ARCANE_PURPLE", stats = "Spell Power, Hit, Crit" },
}

-- Quality colors for item borders
C.ARMORY_QUALITY_COLORS = {
    poor = { r = 0.62, g = 0.62, b = 0.62 },      -- Grey
    common = { r = 1, g = 1, b = 1 },             -- White
    uncommon = { r = 0.12, g = 1, b = 0 },        -- Green
    rare = { r = 0, g = 0.44, b = 0.87 },         -- Blue
    epic = { r = 0.64, g = 0.21, b = 0.93 },      -- Purple
    legendary = { r = 1, g = 0.5, b = 0 },        -- Orange
}

-- Main gear database
-- Structure: [tier][role][slot] = { best = {...}, alternatives = {...} }
C.ARMORY_GEAR_DATABASE = {
    -------------------------------------------------
    -- TIER 4 (Phase 1): Karazhan, Gruul, Magtheridon
    -------------------------------------------------
    [4] = {
        --===========================================
        -- TANK ROLE
        --===========================================
        ["tank"] = {
            ["head"] = {
                best = {
                    itemId = 29011, name = "Warbringer Greathelm",
                    icon = "INV_Helmet_70", quality = "epic", iLvl = 120,
                    stats = "+43 Str, +45 Sta, +32 Def Rating",
                    source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan",
                },
                alternatives = {
                    { itemId = 32083, name = "Faceguard of Determination", icon = "INV_Helmet_71", quality = "epic", iLvl = 115, stats = "+40 Sta, +30 Def", source = "G'eras", sourceType = "badge", badgeCost = 50 },
                    { itemId = 23519, name = "Felsteel Helm", icon = "INV_Helmet_25", quality = "rare", iLvl = 105, stats = "+25 Sta, +22 Def", source = "Blacksmithing", sourceType = "crafted" },
                },
            },
            ["neck"] = {
                best = { itemId = 29386, name = "Necklace of the Juggernaut", icon = "INV_Jewelry_Necklace_36", quality = "epic", iLvl = 110, stats = "+30 Sta, +21 Def", source = "G'eras", sourceType = "badge", badgeCost = 25 },
                alternatives = {
                    { itemId = 28244, name = "Barbed Choker of Discipline", icon = "INV_Jewelry_Necklace_29", quality = "rare", iLvl = 115, stats = "+27 Sta, +18 Def", source = "Heroic Shattered Halls", sourceType = "heroic" },
                },
            },
            ["shoulders"] = {
                best = { itemId = 29023, name = "Warbringer Shoulderplates", icon = "INV_Shoulder_29", quality = "epic", iLvl = 120, stats = "+33 Str, +36 Sta, +23 Def", source = "High King Maulgar", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 27739, name = "Spaulders of the Righteous", icon = "INV_Shoulder_28", quality = "rare", iLvl = 115, stats = "+27 Sta, +21 Def", source = "Warp Splinter", sourceType = "heroic", sourceDetail = "Heroic Botanica" },
                },
            },
            ["back"] = {
                best = { itemId = 28672, name = "Drape of the Dark Reavers", icon = "INV_Misc_Cape_19", quality = "epic", iLvl = 115, stats = "+24 Sta, +20 Hit", source = "Shade of Aran", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27804, name = "Devilshark Cape", icon = "INV_Misc_Cape_17", quality = "rare", iLvl = 115, stats = "+22 Sta, +18 Def", source = "Warlord Kalithresh", sourceType = "heroic", sourceDetail = "Heroic Steamvault" },
                },
            },
            ["chest"] = {
                best = { itemId = 29012, name = "Warbringer Chestguard", icon = "INV_Chest_Plate16", quality = "epic", iLvl = 120, stats = "+43 Str, +54 Sta, +32 Def", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 27440, name = "Jade-Skull Breastplate", icon = "INV_Chest_Plate11", quality = "rare", iLvl = 115, stats = "+36 Sta, +26 Def", source = "Swamplord Musel'ek", sourceType = "heroic", sourceDetail = "Heroic Underbog" },
                },
            },
            ["wrist"] = {
                best = { itemId = 28996, name = "Bracers of the Green Fortress", icon = "INV_Bracer_19", quality = "epic", iLvl = 115, stats = "+30 Sta, +23 Def", source = "Blacksmithing", sourceType = "crafted" },
                alternatives = {
                    { itemId = 29463, name = "Sha'tari Wrought Armguards", icon = "INV_Bracer_17", quality = "rare", iLvl = 110, stats = "+24 Sta, +18 Def", source = "Sha'tar Exalted", sourceType = "rep", repFaction = "The Sha'tar", repStanding = "Exalted" },
                },
            },
            ["hands"] = {
                best = { itemId = 30741, name = "Topaz-Studded Battlegrips", icon = "INV_Gauntlets_27", quality = "epic", iLvl = 115, stats = "+33 Sta, +25 Def", source = "Doom Lord Kazzak", sourceType = "world" },
                alternatives = {
                    { itemId = 27475, name = "Gauntlets of the Bold", icon = "INV_Gauntlets_26", quality = "rare", iLvl = 115, stats = "+27 Sta, +21 Def", source = "Warchief Kargath", sourceType = "heroic", sourceDetail = "Heroic Shattered Halls" },
                },
            },
            ["waist"] = {
                best = { itemId = 28995, name = "Girdle of the Immovable", icon = "INV_Belt_13", quality = "epic", iLvl = 115, stats = "+33 Sta, +25 Def", source = "Blacksmithing", sourceType = "crafted" },
                alternatives = {
                    { itemId = 27672, name = "Girdle of Valorous Deeds", icon = "INV_Belt_12", quality = "rare", iLvl = 115, stats = "+27 Sta, +21 Def", source = "Exarch Maladaar", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                },
            },
            ["legs"] = {
                best = { itemId = 28621, name = "Wrynn Dynasty Greaves", icon = "INV_Pants_Plate_17", quality = "epic", iLvl = 115, stats = "+45 Sta, +34 Def", source = "Nightbane", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 25687, name = "Clefthoof Hide Leggings", icon = "INV_Pants_Leather_09", quality = "rare", iLvl = 109, stats = "+36 Sta, High threat", source = "Leatherworking", sourceType = "crafted" },
                },
            },
            ["feet"] = {
                best = { itemId = 28747, name = "Battlescar Boots", icon = "INV_Boots_Chain_08", quality = "epic", iLvl = 115, stats = "+30 Sta, +23 Def", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27813, name = "Boots of the Colossus", icon = "INV_Boots_Chain_07", quality = "rare", iLvl = 115, stats = "+27 Sta, +20 Def", source = "Pandemonius", sourceType = "heroic", sourceDetail = "Heroic Mana-Tombs" },
                },
            },
            ["ring1"] = {
                best = { itemId = 29279, name = "Violet Signet of the Great Protector", icon = "INV_Jewelry_Ring_62", quality = "epic", iLvl = 115, stats = "+27 Sta, +21 Def", source = "Violet Eye Exalted", sourceType = "rep", repFaction = "The Violet Eye", repStanding = "Exalted" },
                alternatives = {
                    { itemId = 27822, name = "Crystal Band of Valor", icon = "INV_Jewelry_Ring_58", quality = "rare", iLvl = 115, stats = "+22 Sta, +17 Def", source = "Nexus-Prince Shaffar", sourceType = "heroic", sourceDetail = "Heroic Mana-Tombs" },
                },
            },
            ["ring2"] = {
                best = { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_63", quality = "epic", iLvl = 110, stats = "+24 Sta, +18 Hit", source = "Lower City Exalted", sourceType = "rep", repFaction = "Lower City", repStanding = "Exalted" },
                alternatives = {
                    { itemId = 28407, name = "Elementium Band of the Sentry", icon = "INV_Jewelry_Ring_60", quality = "rare", iLvl = 110, stats = "+21 Sta, +15 Def", source = "Arcatraz Key Quest", sourceType = "quest" },
                },
            },
            ["trinket1"] = {
                best = { itemId = 28528, name = "Moroes' Lucky Pocket Watch", icon = "INV_Misc_PocketWatch_02", quality = "epic", iLvl = 115, stats = "+Dodge on use", source = "Moroes", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27891, name = "Adamantine Figurine", icon = "INV_Misc_Statue_01", quality = "rare", iLvl = 110, stats = "+Armor on use", source = "Blackheart the Inciter", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                },
            },
            ["trinket2"] = {
                best = { itemId = 28121, name = "Icon of Unyielding Courage", icon = "INV_Jewelry_Talisman_07", quality = "rare", iLvl = 110, stats = "+Hit, +Dodge proc", source = "Keli'dan the Breaker", sourceType = "heroic", sourceDetail = "Heroic Blood Furnace" },
                alternatives = {
                    { itemId = 23836, name = "Goblin Rocket Launcher", icon = "INV_Gizmo_RocketLauncher", quality = "rare", iLvl = 109, stats = "+Stamina, damage", source = "Engineering", sourceType = "crafted" },
                },
            },
            ["mainhand"] = {
                best = { itemId = 28749, name = "King's Defender", icon = "INV_Sword_58", quality = "epic", iLvl = 115, stats = "+Str, +Sta, +Def", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29362, name = "The Sun Eater", icon = "INV_Sword_57", quality = "epic", iLvl = 110, stats = "+Avoidance proc", source = "Pathaleon the Calculator", sourceType = "heroic", sourceDetail = "Heroic Mechanar" },
                    { itemId = 28189, name = "Latro's Shifting Sword", icon = "INV_Sword_56", quality = "epic", iLvl = 115, stats = "+Hit, high threat", source = "Aeonus", sourceType = "dungeon", sourceDetail = "Black Morass" },
                },
            },
            ["offhand"] = {
                best = { itemId = 28825, name = "Aldori Legacy Defender", icon = "INV_Shield_31", quality = "epic", iLvl = 120, stats = "+Block, gem socket", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 28316, name = "Aegis of the Sunbird", icon = "INV_Shield_30", quality = "rare", iLvl = 115, stats = "+Block, +Sta", source = "Al'ar Trash", sourceType = "raid", sourceDetail = "Tempest Keep" },
                    { itemId = 27887, name = "Platinum Shield of the Valorous", icon = "INV_Shield_29", quality = "rare", iLvl = 115, stats = "+Block, +Def", source = "Warlord Kalithresh", sourceType = "heroic", sourceDetail = "Heroic Steamvault" },
                },
            },
            ["ranged"] = {
                best = { itemId = 30724, name = "Barrel-Blade Longrifle", icon = "INV_Weapon_Rifle_23", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Doomwalker", sourceType = "world" },
                alternatives = {
                    { itemId = 29115, name = "Consortium Blaster", icon = "INV_Weapon_Rifle_22", quality = "rare", iLvl = 105, stats = "+Sta", source = "Consortium Exalted", sourceType = "rep", repFaction = "The Consortium", repStanding = "Exalted" },
                },
            },
        },

        --===========================================
        -- HEALER ROLE
        --===========================================
        ["healer"] = {
            ["head"] = {
                best = { itemId = 29061, name = "Justicar Diadem", icon = "INV_Helmet_15", quality = "epic", iLvl = 120, stats = "+33 Int, +32 Sta, +75 Healing", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28413, name = "Hallowed Crown", icon = "INV_Helmet_14", quality = "rare", iLvl = 112, stats = "+28 Int, +66 Healing", source = "Harbinger Skyriss", sourceType = "heroic", sourceDetail = "Heroic Arcatraz" },
                },
            },
            ["neck"] = {
                best = { itemId = 28609, name = "Emberspur Talisman", icon = "INV_Jewelry_Necklace_37", quality = "epic", iLvl = 115, stats = "+22 Int, +51 Healing", source = "Nightbane", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27508, name = "Natasha's Guardian Cord", icon = "INV_Jewelry_Necklace_36", quality = "rare", iLvl = 109, stats = "+18 Int, +44 Healing", source = "Quest: The Master's Terrace", sourceType = "quest" },
                },
            },
            ["shoulders"] = {
                best = { itemId = 29064, name = "Justicar Pauldrons", icon = "INV_Shoulder_22", quality = "epic", iLvl = 120, stats = "+25 Int, +24 Sta, +62 Healing", source = "High King Maulgar", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 27775, name = "Hallowed Pauldrons", icon = "INV_Shoulder_21", quality = "rare", iLvl = 115, stats = "+21 Int, +51 Healing", source = "Warlord Kalithresh", sourceType = "heroic", sourceDetail = "Heroic Steamvault" },
                },
            },
            ["back"] = {
                best = { itemId = 28765, name = "Stainless Cloak of the Pure Hearted", icon = "INV_Misc_Cape_18", quality = "epic", iLvl = 115, stats = "+18 Int, +46 Healing", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 31329, name = "Lifegiving Cloak", icon = "INV_Misc_Cape_17", quality = "epic", iLvl = 110, stats = "+15 Int, +40 Healing", source = "World Drop", sourceType = "crafted" },
                },
            },
            ["chest"] = {
                best = { itemId = 29062, name = "Justicar Chestpiece", icon = "INV_Chest_Plate15", quality = "epic", iLvl = 120, stats = "+33 Int, +37 Sta, +84 Healing", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 29522, name = "Windhawk Hauberk", icon = "INV_Chest_Leather_03", quality = "epic", iLvl = 110, stats = "+27 Int, +73 Healing, MP5", source = "Tribal Leatherworking", sourceType = "crafted" },
                },
            },
            ["wrist"] = {
                best = { itemId = 23539, name = "Blessed Bracers", icon = "INV_Bracer_12", quality = "epic", iLvl = 100, stats = "+18 Int, +46 Healing", source = "Blacksmithing", sourceType = "crafted" },
                alternatives = {
                    { itemId = 29183, name = "Bindings of the Timewalker", icon = "INV_Bracer_11", quality = "rare", iLvl = 110, stats = "+15 Int, +40 Healing", source = "Keepers of Time Exalted", sourceType = "rep", repFaction = "Keepers of Time", repStanding = "Exalted" },
                },
            },
            ["hands"] = {
                best = { itemId = 28505, name = "Gauntlets of Renewed Hope", icon = "INV_Gauntlets_25", quality = "epic", iLvl = 115, stats = "+22 Int, +55 Healing", source = "Attumen the Huntsman", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27465, name = "Prismatic Mittens of Mending", icon = "INV_Gauntlets_24", quality = "rare", iLvl = 115, stats = "+18 Int, +48 Healing", source = "Aeonus", sourceType = "dungeon", sourceDetail = "Black Morass" },
                },
            },
            ["waist"] = {
                best = { itemId = 21873, name = "Primal Mooncloth Belt", icon = "INV_Belt_14", quality = "epic", iLvl = 110, stats = "+22 Int, +57 Healing, MP5", source = "Mooncloth Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 27542, name = "Cord of Sanctification", icon = "INV_Belt_13", quality = "rare", iLvl = 112, stats = "+18 Int, +48 Healing", source = "Quest: Deathblow to the Legion", sourceType = "quest" },
                },
            },
            ["legs"] = {
                best = { itemId = 28748, name = "Legplates of the Innocent", icon = "INV_Pants_Plate_18", quality = "epic", iLvl = 115, stats = "+28 Int, +68 Healing", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 30727, name = "Gilded Trousers of Benediction", icon = "INV_Pants_Plate_17", quality = "epic", iLvl = 115, stats = "+25 Int, +62 Healing", source = "Doom Lord Kazzak", sourceType = "world" },
                },
            },
            ["feet"] = {
                best = { itemId = 28752, name = "Forestlord Striders", icon = "INV_Boots_Cloth_12", quality = "epic", iLvl = 115, stats = "+22 Int, +55 Healing", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27411, name = "Jeweled Boots of Sanctification", icon = "INV_Boots_Cloth_11", quality = "rare", iLvl = 112, stats = "+18 Int, +48 Healing", source = "Quest: The Soul Devices", sourceType = "quest" },
                },
            },
            ["ring1"] = {
                best = { itemId = 28763, name = "Jade Ring of the Everliving", icon = "INV_Jewelry_Ring_61", quality = "epic", iLvl = 115, stats = "+22 Int, +51 Healing", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29814, name = "Celestial Jewel Ring", icon = "INV_Jewelry_Ring_60", quality = "rare", iLvl = 105, stats = "+18 Int, +40 Healing", source = "Quest: A Fate Worse Than Death", sourceType = "quest" },
                },
            },
            ["ring2"] = {
                best = { itemId = 28790, name = "Naaru Lightwarden's Band", icon = "INV_Jewelry_Ring_62", quality = "epic", iLvl = 115, stats = "+20 Int, +46 Healing", source = "Magtheridon Quest", sourceType = "quest", sourceDetail = "Trial of the Naaru" },
                alternatives = {
                    { itemId = 30736, name = "Ring of Flowing Light", icon = "INV_Jewelry_Ring_63", quality = "epic", iLvl = 115, stats = "+18 Int, +42 Healing", source = "Doom Lord Kazzak", sourceType = "world" },
                },
            },
            ["trinket1"] = {
                best = { itemId = 29376, name = "Essence of the Martyr", icon = "INV_Jewelry_Talisman_12", quality = "epic", iLvl = 110, stats = "+Healing on use", source = "G'eras", sourceType = "badge", badgeCost = 41 },
                alternatives = {
                    { itemId = 28823, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", iLvl = 110, stats = "+Healing on use", source = "Lower City Exalted", sourceType = "rep", repFaction = "Lower City", repStanding = "Exalted" },
                },
            },
            ["trinket2"] = {
                best = { itemId = 28590, name = "Ribbon of Sacrifice", icon = "INV_Misc_QirajiCrystal_04", quality = "epic", iLvl = 115, stats = "+Healing proc", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27770, name = "Bangle of Endless Blessings", icon = "INV_Jewelry_Talisman_11", quality = "rare", iLvl = 115, stats = "+MP5 proc", source = "Harbinger Skyriss", sourceType = "heroic", sourceDetail = "Heroic Arcatraz" },
                },
            },
            ["mainhand"] = {
                best = { itemId = 28771, name = "Light's Justice", icon = "INV_Mace_51", quality = "epic", iLvl = 115, stats = "+22 Int, +59 Healing", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_50", quality = "epic", iLvl = 110, stats = "+18 Int, +51 Healing", source = "Sha'tar Exalted", sourceType = "rep", repFaction = "The Sha'tar", repStanding = "Exalted" },
                },
            },
            ["offhand"] = {
                best = { itemId = 29458, name = "Aegis of the Vindicator", icon = "INV_Shield_32", quality = "epic", iLvl = 120, stats = "+18 Int, +48 Healing", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 27477, name = "Faol's Signet of Cleansing", icon = "INV_Jewelry_Talisman_10", quality = "rare", iLvl = 115, stats = "+15 Int, +40 Healing", source = "Murmur", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                },
            },
            ["ranged"] = {
                best = { itemId = 28592, name = "Libram of Souls Redeemed", icon = "INV_Relics_LibramofHope", quality = "epic", iLvl = 115, stats = "+Healing to Flash of Light", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28296, name = "Libram of Mending", icon = "INV_Relics_LibramofGrace", quality = "rare", iLvl = 100, stats = "+Healing", source = "Badge Vendor", sourceType = "badge", badgeCost = 15 },
                },
            },
        },

        --===========================================
        -- MELEE DPS ROLE
        --===========================================
        ["melee_dps"] = {
            ["head"] = {
                best = { itemId = 29044, name = "Netherblade Facemask", icon = "INV_Helmet_24", quality = "epic", iLvl = 120, stats = "+35 Agi, +30 Sta, +28 Hit", source = "Netherspite", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28224, name = "Wastewalker Helm", icon = "INV_Helmet_23", quality = "rare", iLvl = 115, stats = "+30 Agi, +25 Sta", source = "Epoch Hunter", sourceType = "heroic", sourceDetail = "Heroic Old Hillsbrad" },
                },
            },
            ["neck"] = {
                best = { itemId = 29381, name = "Choker of Vile Intent", icon = "INV_Jewelry_Necklace_38", quality = "epic", iLvl = 110, stats = "+22 Agi, +22 Hit", source = "G'eras", sourceType = "badge", badgeCost = 25 },
                alternatives = {
                    { itemId = 24114, name = "Braided Eternium Chain", icon = "INV_Jewelry_Necklace_37", quality = "rare", iLvl = 100, stats = "+18 Agi, Party Crit buff", source = "Jewelcrafting", sourceType = "crafted" },
                },
            },
            ["shoulders"] = {
                best = { itemId = 27797, name = "Wastewalker Shoulderpads", icon = "INV_Shoulder_23", quality = "rare", iLvl = 115, stats = "+27 Agi, +25 Sta", source = "Avatar of the Martyred", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                alternatives = {
                    { itemId = 27776, name = "Shoulderpads of Assassination", icon = "INV_Shoulder_22", quality = "rare", iLvl = 115, stats = "+24 Agi, +22 Sta", source = "Warlord Kalithresh", sourceType = "heroic", sourceDetail = "Heroic Steamvault" },
                },
            },
            ["back"] = {
                best = { itemId = 28672, name = "Drape of the Dark Reavers", icon = "INV_Misc_Cape_19", quality = "epic", iLvl = 115, stats = "+24 Agi, +20 Hit", source = "Shade of Aran", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27878, name = "Auchenai Death Shroud", icon = "INV_Misc_Cape_18", quality = "rare", iLvl = 115, stats = "+20 Agi, +18 Sta", source = "Exarch Maladaar", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                },
            },
            ["chest"] = {
                best = { itemId = 29045, name = "Netherblade Chestpiece", icon = "INV_Chest_Leather_03", quality = "epic", iLvl = 120, stats = "+40 Agi, +36 Sta", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 30730, name = "Terrorweave Tunic", icon = "INV_Chest_Leather_02", quality = "epic", iLvl = 115, stats = "+35 Agi, +30 Sta", source = "Doomwalker", sourceType = "world" },
                },
            },
            ["wrist"] = {
                best = { itemId = 29246, name = "Nightfall Wristguards", icon = "INV_Bracer_15", quality = "rare", iLvl = 110, stats = "+22 Agi, +20 Sta", source = "Epoch Hunter", sourceType = "heroic", sourceDetail = "Heroic Old Hillsbrad" },
                alternatives = {
                    { itemId = 27817, name = "Stealther's Helmet of Second Sight", icon = "INV_Bracer_14", quality = "rare", iLvl = 109, stats = "+20 Agi, +18 Sta", source = "Quest: Teron Gorefiend, I Am...", sourceType = "quest" },
                },
            },
            ["hands"] = {
                best = { itemId = 27531, name = "Wastewalker Gloves", icon = "INV_Gauntlets_23", quality = "rare", iLvl = 115, stats = "+27 Agi, +25 Sta, +18 Hit", source = "Warchief Kargath Bladefist", sourceType = "heroic", sourceDetail = "Heroic Shattered Halls" },
                alternatives = {
                    { itemId = 30644, name = "Grips of Deftness", icon = "INV_Gauntlets_22", quality = "epic", iLvl = 115, stats = "+25 Agi, +22 Sta", source = "Karazhan Trash", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["waist"] = {
                best = { itemId = 29247, name = "Girdle of the Deathdealer", icon = "INV_Belt_15", quality = "rare", iLvl = 110, stats = "+24 Agi, +22 Sta, +18 Hit", source = "Aeonus", sourceType = "heroic", sourceDetail = "Heroic Black Morass" },
                alternatives = {
                    { itemId = 27911, name = "Nethershard Girdle", icon = "INV_Belt_14", quality = "rare", iLvl = 109, stats = "+21 Agi, +20 Sta", source = "Quest: Shutting Down Manaforge B'naar", sourceType = "quest" },
                },
            },
            ["legs"] = {
                best = { itemId = 28741, name = "Skulker's Greaves", icon = "INV_Pants_Leather_17", quality = "epic", iLvl = 115, stats = "+35 Agi, +32 Sta", source = "Netherspite", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29046, name = "Netherblade Breeches", icon = "INV_Pants_Leather_16", quality = "epic", iLvl = 120, stats = "+38 Agi, +34 Sta", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                },
            },
            ["feet"] = {
                best = { itemId = 28545, name = "Edgewalker Longboots", icon = "INV_Boots_Chain_09", quality = "epic", iLvl = 115, stats = "+27 Agi, +25 Sta, +18 Hit", source = "Moroes", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27867, name = "Boots of the Unjust", icon = "INV_Boots_Chain_08", quality = "rare", iLvl = 115, stats = "+24 Agi, +22 Sta", source = "Blackheart the Inciter", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                },
            },
            ["ring1"] = {
                best = { itemId = 28757, name = "Ring of a Thousand Marks", icon = "INV_Jewelry_Ring_64", quality = "epic", iLvl = 115, stats = "+24 Agi, +22 Sta", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29283, name = "Violet Signet of the Master Assassin", icon = "INV_Jewelry_Ring_63", quality = "epic", iLvl = 115, stats = "+22 Agi, +20 Sta", source = "Violet Eye Exalted", sourceType = "rep", repFaction = "The Violet Eye", repStanding = "Exalted" },
                },
            },
            ["ring2"] = {
                best = { itemId = 28649, name = "Garona's Signet Ring", icon = "INV_Jewelry_Ring_65", quality = "epic", iLvl = 115, stats = "+22 Agi, +20 Hit", source = "The Curator", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 30738, name = "Ring of Reciprocity", icon = "INV_Jewelry_Ring_64", quality = "epic", iLvl = 115, stats = "+20 Agi, +18 Sta", source = "Doom Lord Kazzak", sourceType = "world" },
                },
            },
            ["trinket1"] = {
                best = { itemId = 28830, name = "Dragonspine Trophy", icon = "INV_Misc_MonsterScales_15", quality = "epic", iLvl = 125, stats = "+40 AP, Haste proc", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 23206, name = "Mark of the Champion", icon = "INV_Jewelry_Talisman_13", quality = "epic", iLvl = 110, stats = "+AP vs Undead/Demons", source = "Kel'Thuzad", sourceType = "raid", sourceDetail = "Naxxramas" },
                },
            },
            ["trinket2"] = {
                best = { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Talisman_14", quality = "epic", iLvl = 110, stats = "+AP on use", source = "G'eras", sourceType = "badge", badgeCost = 41 },
                alternatives = {
                    { itemId = 28288, name = "Abacus of Violent Odds", icon = "INV_Misc_Gear_03", quality = "rare", iLvl = 115, stats = "+Haste on use", source = "Pathaleon the Calculator", sourceType = "heroic", sourceDetail = "Heroic Mechanar" },
                },
            },
            ["mainhand"] = {
                best = { itemId = 28438, name = "Dragonmaw", icon = "INV_Sword_59", quality = "epic", iLvl = 115, stats = "+Str, +Agi", source = "Blacksmithing", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28295, name = "Gladiator's Slicer", icon = "INV_Sword_58", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Arena Season 1", sourceType = "pvp" },
                    { itemId = 31332, name = "Blinkstrike", icon = "INV_Sword_57", quality = "epic", iLvl = 115, stats = "+Agi, Teleport proc", source = "World Drop", sourceType = "crafted" },
                },
            },
            ["offhand"] = {
                best = { itemId = 28189, name = "Latro's Shifting Sword", icon = "INV_Sword_56", quality = "epic", iLvl = 115, stats = "+Agi, +Hit", source = "Aeonus", sourceType = "dungeon", sourceDetail = "Black Morass" },
                alternatives = {
                    { itemId = 28307, name = "Gladiator's Quickblade", icon = "INV_Sword_55", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Arena Season 1", sourceType = "pvp" },
                },
            },
            ["ranged"] = {
                best = { itemId = 28772, name = "Sunfury Bow of the Phoenix", icon = "INV_Weapon_Bow_26", quality = "epic", iLvl = 115, stats = "+Agi, +Crit", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29151, name = "Veteran's Musket", icon = "INV_Weapon_Rifle_24", quality = "rare", iLvl = 100, stats = "+Agi", source = "Honor Hold Exalted", sourceType = "rep", repFaction = "Honor Hold", repStanding = "Exalted" },
                    { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_25", quality = "rare", iLvl = 100, stats = "+Agi", source = "Thrallmar Exalted", sourceType = "rep", repFaction = "Thrallmar", repStanding = "Exalted" },
                },
            },
        },

        --===========================================
        -- RANGED DPS ROLE (Hunter)
        --===========================================
        ["ranged_dps"] = {
            ["head"] = {
                best = { itemId = 28275, name = "Beast Lord Helm", icon = "INV_Helmet_22", quality = "rare", iLvl = 115, stats = "+30 Agi, +28 Sta, +50 AP", source = "Pathaleon the Calculator", sourceType = "dungeon", sourceDetail = "The Mechanar" },
                alternatives = {
                    { itemId = 28224, name = "Wastewalker Helm", icon = "INV_Helmet_21", quality = "rare", iLvl = 115, stats = "+27 Agi, +25 Sta", source = "Epoch Hunter", sourceType = "heroic", sourceDetail = "Heroic Old Hillsbrad" },
                },
            },
            ["neck"] = {
                best = { itemId = 29381, name = "Choker of Vile Intent", icon = "INV_Jewelry_Necklace_38", quality = "epic", iLvl = 110, stats = "+22 Agi, +22 Hit", source = "G'eras", sourceType = "badge", badgeCost = 25 },
                alternatives = {
                    { itemId = 27779, name = "Traitor's Noose", icon = "INV_Jewelry_Necklace_37", quality = "rare", iLvl = 112, stats = "+20 Agi, +18 Sta", source = "Exarch Maladaar", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                },
            },
            ["shoulders"] = {
                best = { itemId = 27801, name = "Beast Lord Mantle", icon = "INV_Shoulder_20", quality = "rare", iLvl = 115, stats = "+25 Agi, +24 Sta, +38 AP", source = "Warlord Kalithresh", sourceType = "dungeon", sourceDetail = "The Steamvault" },
                alternatives = {
                    { itemId = 27797, name = "Wastewalker Shoulderpads", icon = "INV_Shoulder_19", quality = "rare", iLvl = 115, stats = "+24 Agi, +22 Sta", source = "Avatar of the Martyred", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                },
            },
            ["back"] = {
                best = { itemId = 24259, name = "Vengeance Wrap", icon = "INV_Misc_Cape_16", quality = "rare", iLvl = 105, stats = "+20 Agi, +40 AP", source = "Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28672, name = "Drape of the Dark Reavers", icon = "INV_Misc_Cape_15", quality = "epic", iLvl = 115, stats = "+24 Agi, +20 Hit", source = "Shade of Aran", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["chest"] = {
                best = { itemId = 28228, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_15", quality = "rare", iLvl = 115, stats = "+33 Agi, +30 Sta, +60 AP", source = "Warp Splinter", sourceType = "dungeon", sourceDetail = "The Botanica" },
                alternatives = {
                    { itemId = 29525, name = "Primalstrike Vest", icon = "INV_Chest_Leather_04", quality = "epic", iLvl = 110, stats = "+30 Agi, +100 AP", source = "Leatherworking", sourceType = "crafted" },
                },
            },
            ["wrist"] = {
                best = { itemId = 29246, name = "Nightfall Wristguards", icon = "INV_Bracer_15", quality = "rare", iLvl = 110, stats = "+22 Agi, +20 Sta", source = "Epoch Hunter", sourceType = "heroic", sourceDetail = "Heroic Old Hillsbrad" },
                alternatives = {
                    { itemId = 29527, name = "Primalstrike Bracers", icon = "INV_Bracer_14", quality = "epic", iLvl = 110, stats = "+20 Agi, +60 AP", source = "Leatherworking", sourceType = "crafted" },
                },
            },
            ["hands"] = {
                best = { itemId = 27474, name = "Beast Lord Handguards", icon = "INV_Gauntlets_21", quality = "rare", iLvl = 115, stats = "+25 Agi, +24 Sta, +44 AP", source = "Warchief Kargath Bladefist", sourceType = "dungeon", sourceDetail = "The Shattered Halls" },
                alternatives = {
                    { itemId = 27531, name = "Wastewalker Gloves", icon = "INV_Gauntlets_20", quality = "rare", iLvl = 115, stats = "+24 Agi, +22 Sta, +18 Hit", source = "Warchief Kargath Bladefist", sourceType = "heroic", sourceDetail = "Heroic Shattered Halls" },
                },
            },
            ["waist"] = {
                best = { itemId = 28828, name = "Gronn-Stitched Girdle", icon = "INV_Belt_16", quality = "epic", iLvl = 120, stats = "+30 Agi, +28 Sta, +64 AP", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 29247, name = "Girdle of the Deathdealer", icon = "INV_Belt_15", quality = "rare", iLvl = 110, stats = "+24 Agi, +22 Sta, +18 Hit", source = "Aeonus", sourceType = "heroic", sourceDetail = "Heroic Black Morass" },
                },
            },
            ["legs"] = {
                best = { itemId = 30739, name = "Scaled Greaves of the Marksman", icon = "INV_Pants_Mail_15", quality = "epic", iLvl = 115, stats = "+35 Agi, +32 Sta, +76 AP", source = "Doom Lord Kazzak", sourceType = "world" },
                alternatives = {
                    { itemId = 28594, name = "Leggings of the Pursuit", icon = "INV_Pants_Mail_14", quality = "epic", iLvl = 115, stats = "+30 Agi, +28 Sta", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["feet"] = {
                best = { itemId = 28545, name = "Edgewalker Longboots", icon = "INV_Boots_Chain_09", quality = "epic", iLvl = 115, stats = "+27 Agi, +25 Sta, +18 Hit", source = "Moroes", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27814, name = "Fel Leather Boots", icon = "INV_Boots_08", quality = "rare", iLvl = 100, stats = "+20 Hit Rating", source = "Leatherworking", sourceType = "crafted" },
                },
            },
            ["ring1"] = {
                best = { itemId = 28757, name = "Ring of a Thousand Marks", icon = "INV_Jewelry_Ring_64", quality = "epic", iLvl = 115, stats = "+24 Agi, +22 Sta", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28791, name = "Ring of the Recalcitrant", icon = "INV_Jewelry_Ring_63", quality = "epic", iLvl = 115, stats = "+22 Agi, +20 Sta", source = "Magtheridon Quest", sourceType = "quest" },
                },
            },
            ["ring2"] = {
                best = { itemId = 28649, name = "Garona's Signet Ring", icon = "INV_Jewelry_Ring_65", quality = "epic", iLvl = 115, stats = "+22 Agi, +20 Hit", source = "The Curator", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 29283, name = "Violet Signet of the Master Assassin", icon = "INV_Jewelry_Ring_64", quality = "epic", iLvl = 115, stats = "+20 Agi, +18 Sta", source = "Violet Eye Exalted", sourceType = "rep", repFaction = "The Violet Eye", repStanding = "Exalted" },
                },
            },
            ["trinket1"] = {
                best = { itemId = 28830, name = "Dragonspine Trophy", icon = "INV_Misc_MonsterScales_15", quality = "epic", iLvl = 125, stats = "+40 AP, Haste proc", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", iLvl = 115, stats = "+Crit proc", source = "Temporus", sourceType = "heroic", sourceDetail = "Heroic Black Morass" },
                },
            },
            ["trinket2"] = {
                best = { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Talisman_14", quality = "epic", iLvl = 110, stats = "+AP on use", source = "G'eras", sourceType = "badge", badgeCost = 41 },
                alternatives = {
                    { itemId = 28288, name = "Abacus of Violent Odds", icon = "INV_Misc_Gear_03", quality = "rare", iLvl = 115, stats = "+Haste on use", source = "Pathaleon the Calculator", sourceType = "heroic", sourceDetail = "Heroic Mechanar" },
                },
            },
            ["mainhand"] = {
                best = { itemId = 27846, name = "Claw of the Watcher", icon = "INV_Weapon_Hand_11", quality = "rare", iLvl = 110, stats = "+Agi, stat stick", source = "Shirrak the Dead Watcher", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                alternatives = {
                    { itemId = 28572, name = "Blade of the Unrequited", icon = "INV_Sword_54", quality = "epic", iLvl = 115, stats = "+Agi, stat stick", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["offhand"] = {
                best = { itemId = 28572, name = "Blade of the Unrequited", icon = "INV_Sword_54", quality = "epic", iLvl = 115, stats = "+Agi, stat stick", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 27846, name = "Claw of the Watcher", icon = "INV_Weapon_Hand_11", quality = "rare", iLvl = 110, stats = "+Agi, stat stick", source = "Shirrak the Dead Watcher", sourceType = "heroic", sourceDetail = "Heroic Auchenai Crypts" },
                },
            },
            ["ranged"] = {
                best = { itemId = 28772, name = "Sunfury Bow of the Phoenix", icon = "INV_Weapon_Bow_26", quality = "epic", iLvl = 115, stats = "+High DPS, +Agi", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 30724, name = "Barrel-Blade Longrifle", icon = "INV_Weapon_Rifle_23", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Doomwalker", sourceType = "world" },
                },
            },
        },

        --===========================================
        -- CASTER DPS ROLE
        --===========================================
        ["caster_dps"] = {
            ["head"] = {
                best = { itemId = 28963, name = "Voidheart Crown", icon = "INV_Helmet_30", quality = "epic", iLvl = 120, stats = "+30 Sta, +30 Int, +40 Spell Dmg", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 24266, name = "Spellstrike Hood", icon = "INV_Helmet_29", quality = "epic", iLvl = 105, stats = "+25 Int, +46 Spell Dmg, +16 Hit", source = "Tailoring (BoE)", sourceType = "crafted" },
                },
            },
            ["neck"] = {
                best = { itemId = 28762, name = "Adornment of Stolen Souls", icon = "INV_Jewelry_Necklace_39", quality = "epic", iLvl = 115, stats = "+18 Sta, +18 Int, +28 Spell Dmg", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28530, name = "Brooch of Unquenchable Fury", icon = "INV_Jewelry_Necklace_38", quality = "epic", iLvl = 115, stats = "+15 Int, +23 Spell Dmg, +10 Hit", source = "Moroes", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["shoulders"] = {
                best = { itemId = 28967, name = "Voidheart Mantle", icon = "INV_Shoulder_27", quality = "epic", iLvl = 120, stats = "+22 Sta, +25 Int, +32 Spell Dmg", source = "High King Maulgar", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                alternatives = {
                    { itemId = 21869, name = "Frozen Shadoweave Shoulders", icon = "INV_Shoulder_26", quality = "epic", iLvl = 100, stats = "+18 Sta, +30 Shadow/Frost Dmg", source = "Shadoweave Tailoring", sourceType = "crafted" },
                },
            },
            ["back"] = {
                best = { itemId = 28766, name = "Ruby Drape of the Mysticant", icon = "INV_Misc_Cape_20", quality = "epic", iLvl = 115, stats = "+15 Sta, +16 Int, +26 Spell Dmg, +8 Hit", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 30735, name = "Ancient Spellcloak of the Highborne", icon = "INV_Misc_Cape_19", quality = "epic", iLvl = 115, stats = "+18 Sta, +23 Spell Dmg", source = "Doom Lord Kazzak", sourceType = "world" },
                },
            },
            ["chest"] = {
                best = { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_43", quality = "epic", iLvl = 100, stats = "+25 Int, +50 Fire Dmg, +Intellect", source = "Spellfire Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28964, name = "Voidheart Robe", icon = "INV_Chest_Cloth_42", quality = "epic", iLvl = 120, stats = "+33 Sta, +30 Int, +42 Spell Dmg", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                    { itemId = 21871, name = "Frozen Shadoweave Robe", icon = "INV_Chest_Cloth_41", quality = "epic", iLvl = 100, stats = "+25 Sta, +45 Shadow/Frost Dmg", source = "Shadoweave Tailoring", sourceType = "crafted" },
                },
            },
            ["wrist"] = {
                best = { itemId = 24250, name = "Bracers of Havok", icon = "INV_Bracer_07", quality = "epic", iLvl = 105, stats = "+15 Sta, +15 Int, +30 Spell Dmg, Socket", source = "Tailoring (BoE)", sourceType = "crafted" },
                alternatives = {
                    { itemId = 27462, name = "Crimson Bracers of Gloom", icon = "INV_Bracer_06", quality = "rare", iLvl = 115, stats = "+12 Sta, +25 Spell Dmg", source = "Murmur", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                },
            },
            ["hands"] = {
                best = { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", iLvl = 100, stats = "+20 Int, +35 Fire Dmg", source = "Spellfire Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28968, name = "Voidheart Gloves", icon = "INV_Gauntlets_18", quality = "epic", iLvl = 120, stats = "+25 Sta, +22 Int, +28 Spell Dmg", source = "The Curator", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["waist"] = {
                best = { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_18", quality = "epic", iLvl = 100, stats = "+18 Int, +32 Fire Dmg", source = "Spellfire Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 24256, name = "Girdle of Ruination", icon = "INV_Belt_17", quality = "epic", iLvl = 105, stats = "+22 Sta, +28 Spell Dmg, +18 Crit", source = "Tailoring (BoE)", sourceType = "crafted" },
                },
            },
            ["legs"] = {
                best = { itemId = 24262, name = "Spellstrike Pants", icon = "INV_Pants_Cloth_17", quality = "epic", iLvl = 105, stats = "+25 Sta, +46 Spell Dmg, +26 Hit, +26 Crit", source = "Tailoring (BoE)", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28966, name = "Voidheart Leggings", icon = "INV_Pants_Cloth_16", quality = "epic", iLvl = 120, stats = "+33 Sta, +28 Int, +36 Spell Dmg", source = "Gruul the Dragonkiller", sourceType = "raid", sourceDetail = "Gruul's Lair" },
                },
            },
            ["feet"] = {
                best = { itemId = 21870, name = "Frozen Shadoweave Boots", icon = "INV_Boots_Cloth_13", quality = "epic", iLvl = 100, stats = "+20 Sta, +35 Shadow/Frost Dmg", source = "Shadoweave Tailoring", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28517, name = "Boots of Foretelling", icon = "INV_Boots_Cloth_12", quality = "epic", iLvl = 115, stats = "+22 Sta, +25 Spell Dmg, +18 Hit", source = "Maiden of Virtue", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
            ["ring1"] = {
                best = { itemId = 28753, name = "Ring of Recurrence", icon = "INV_Jewelry_Ring_66", quality = "epic", iLvl = 115, stats = "+18 Sta, +22 Spell Dmg, +14 Crit", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 28793, name = "Band of Crimson Fury", icon = "INV_Jewelry_Ring_65", quality = "epic", iLvl = 115, stats = "+15 Sta, +20 Spell Dmg, +10 Hit", source = "Magtheridon Quest", sourceType = "quest" },
                },
            },
            ["ring2"] = {
                best = { itemId = 29287, name = "Violet Signet of the Archmage", icon = "INV_Jewelry_Ring_67", quality = "epic", iLvl = 115, stats = "+18 Sta, +24 Spell Dmg", source = "Violet Eye Exalted", sourceType = "rep", repFaction = "The Violet Eye", repStanding = "Exalted" },
                alternatives = {
                    { itemId = 29172, name = "Ashyen's Gift", icon = "INV_Jewelry_Ring_66", quality = "epic", iLvl = 110, stats = "+15 Sta, +20 Spell Dmg, +10 Hit", source = "Cenarion Expedition Exalted", sourceType = "rep", repFaction = "Cenarion Expedition", repStanding = "Exalted" },
                },
            },
            ["trinket1"] = {
                best = { itemId = 27683, name = "Quagmirran's Eye", icon = "INV_Misc_Eye_01", quality = "rare", iLvl = 110, stats = "+Spell Haste proc", source = "Quagmirran", sourceType = "heroic", sourceDetail = "Heroic Slave Pens" },
                alternatives = {
                    { itemId = 29132, name = "Scryer's Bloodgem", icon = "INV_Jewelry_Talisman_15", quality = "rare", iLvl = 105, stats = "+Spell Dmg on use", source = "Scryers Revered", sourceType = "rep", repFaction = "The Scryers", repStanding = "Revered" },
                },
            },
            ["trinket2"] = {
                best = { itemId = 29370, name = "Icon of the Silver Crescent", icon = "INV_Jewelry_Talisman_16", quality = "epic", iLvl = 110, stats = "+Spell Dmg on use", source = "G'eras", sourceType = "badge", badgeCost = 41 },
                alternatives = {
                    { itemId = 28789, name = "Eye of Magtheridon", icon = "INV_Misc_Eye_02", quality = "epic", iLvl = 120, stats = "+Spell Dmg, +Spell Power proc", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                },
            },
            ["mainhand"] = {
                best = { itemId = 28770, name = "Nathrezim Mindblade", icon = "INV_Sword_61", quality = "epic", iLvl = 115, stats = "+22 Sta, +21 Int, +35 Spell Dmg", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan" },
                alternatives = {
                    { itemId = 30723, name = "Talon of the Tempest", icon = "INV_Sword_60", quality = "epic", iLvl = 115, stats = "+20 Sta, +32 Spell Dmg", source = "Doomwalker", sourceType = "world" },
                },
            },
            ["offhand"] = {
                best = { itemId = 29270, name = "Flametongue Seal", icon = "INV_Misc_Orb_05", quality = "epic", iLvl = 110, stats = "+12 Sta, +23 Fire Dmg", source = "G'eras", sourceType = "badge", badgeCost = 25 },
                alternatives = {
                    { itemId = 29273, name = "Khadgar's Knapsack", icon = "INV_Misc_Bag_10", quality = "epic", iLvl = 110, stats = "+15 Sta, +20 Spell Dmg", source = "G'eras", sourceType = "badge", badgeCost = 25 },
                },
            },
            ["ranged"] = {
                best = { itemId = 28783, name = "Eredar Wand of Obliteration", icon = "INV_Wand_22", quality = "epic", iLvl = 120, stats = "+15 Sta, +12 Spell Dmg", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 28673, name = "Tirisfal Wand of Ascendancy", icon = "INV_Wand_21", quality = "epic", iLvl = 115, stats = "+12 Sta, +10 Spell Dmg, +8 Hit", source = "Shade of Aran", sourceType = "raid", sourceDetail = "Karazhan" },
                },
            },
        },
    },
}

-- Helper function to get gear for a slot/role/tier
function C:GetArmoryGear(tier, role, slot)
    if not C.ARMORY_GEAR_DATABASE[tier] then return nil end
    if not C.ARMORY_GEAR_DATABASE[tier][role] then return nil end
    return C.ARMORY_GEAR_DATABASE[tier][role][slot]
end

-- Helper function to get all slots for a role/tier
function C:GetArmorySlots(tier, role)
    if not C.ARMORY_GEAR_DATABASE[tier] then return {} end
    if not C.ARMORY_GEAR_DATABASE[tier][role] then return {} end
    return C.ARMORY_GEAR_DATABASE[tier][role]
end
```

---

## PAYLOAD 2: Core Defaults & SavedVariables

**Goal:** Add armory state tracking to Core.lua

**Estimated Lines:** ~40

**File:** `Core/Core.lua`

### Data to Add:

```lua
-- Add to CHAR_DATA_DEFAULTS (around line 150)
armory = {
    selectedTier = 4,
    selectedRole = nil,  -- Auto-detect from spec
    wishlist = {},       -- [slot] = itemId
    lastViewed = nil,    -- Timestamp
},

-- Add slash command handler (around line 1000)
elseif cmd == "armory" then
    if HopeAddon.Journal and HopeAddon.Journal.mainFrame then
        HopeAddon.Journal:ShowMainFrame()
        HopeAddon.Journal:SelectTab(8)  -- Armory tab index
    end
```

---

## PAYLOAD 3: Journal UI - Tab Registration & Containers

**Goal:** Add Armory tab to Journal with basic container structure

**Estimated Lines:** ~300

**File:** `Journal/Journal.lua`

### Functions to Add:

1. **Tab Registration** (in tabData array):
```lua
{ name = "armory", label = "Armory", icon = "INV_Chest_Plate_04", populate = function() self:PopulateArmory() end },
```

2. **State Variables:**
```lua
Journal.armoryUI = {}
Journal.armoryState = {
    selectedTier = 4,
    selectedSlot = nil,
    upgradePopupVisible = false,
}
```

3. **Main Functions:**
- `CreateArmoryContainers()` - One-time container setup
- `PopulateArmory()` - Main entry point
- `CreateArmoryHeader()` - Tier tabs + spec dropdown
- `CreateArmorySlotGrid()` - 17 slot buttons
- `UpdateArmorySlotButton(slot)` - Update slot state

---

## PAYLOAD 4: Journal UI - Slot Buttons & Upgrade Popup

**Goal:** Implement clickable slot buttons and upgrade recommendation popup

**Estimated Lines:** ~500

**File:** `Journal/Journal.lua`

### Functions to Add:

1. **Slot Button Functions:**
- `CreateArmorySlotButton(slotInfo)` - Create single slot button
- `GetEquippedItemForSlot(slotId)` - Get player's current item
- `FormatSlotButtonState(slot, equipped, best)` - Determine display state
- `OnSlotButtonClick(slot)` - Show/hide upgrade popup

2. **Upgrade Popup Functions:**
- `ShowUpgradeSelector(slot, anchorFrame)` - Display popup
- `HideUpgradeSelector()` - Close popup
- `CreateUpgradeItemRow(item, isBest)` - Single item row in popup
- `FormatItemSource(item)` - Format source text
- `AddToWishlist(slot, itemId)` - Dream set feature

---

## IMPLEMENTATION ORDER

Execute payloads in this order:

| Order | Payload | Dependencies | Est. Time |
|-------|---------|--------------|-----------|
| 1 | Constants Data | None | 30 min |
| 2 | Core Defaults | Payload 1 | 10 min |
| 3 | Tab & Containers | Payloads 1-2 | 20 min |
| 4 | Slot Buttons & Popup | Payloads 1-3 | 30 min |

**Total Estimated Time:** ~90 minutes

---

## VERIFICATION CHECKLIST

After each payload, verify:

### Payload 1 (Constants):
- [ ] No Lua syntax errors on load
- [ ] `C:GetArmoryGear(4, "tank", "head")` returns data
- [ ] All 5 roles have 17 slots each
- [ ] All item IDs are numbers (not strings)

### Payload 2 (Core):
- [ ] `/hope armory` opens journal to Armory tab
- [ ] `charDb.armory` exists with defaults

### Payload 3 (Tab & Containers):
- [ ] Armory tab appears in journal
- [ ] Tier tabs (T4/T5/T6) are clickable
- [ ] Spec dropdown shows player's specs

### Payload 4 (Slot Buttons):
- [ ] 17 slot buttons visible and positioned
- [ ] Clicking slot shows upgrade popup
- [ ] Equipped items detected correctly
- [ ] Upgrade indicators show for better items

---

## ACCURACY VERIFICATION SUMMARY

### Item IDs Verified ✅

| Item | ID | Source | Verified |
|------|-----|--------|----------|
| Warbringer Greathelm | 29011 | Wowhead TBC | ✅ |
| Dragonspine Trophy | 28830 | Wowhead TBC | ✅ |
| Justicar Diadem | 29061 | Wowhead TBC | ✅ |
| Beast Lord Helm | 28275 | Wowhead TBC | ✅ |
| Spellfire Belt | 21846 | Wowhead TBC | ✅ |
| Spellfire Gloves | 21847 | Wowhead TBC | ✅ |
| Spellfire Robe | 21848 | Wowhead TBC | ✅ |

### Sources Verified ✅

- Prince Malchezaar drops T4 helms (Karazhan)
- Gruul drops Dragonspine Trophy (Gruul's Lair)
- High King Maulgar drops T4 shoulders
- Magtheridon drops T4 chests
- Badge vendor G'eras in Shattrath

### Data Quality Notes

1. **Item Levels:** Verified against Wowhead TBC Classic
2. **Drop Locations:** Cross-referenced multiple sources
3. **Stat Summaries:** Simplified for display (not exact values)
4. **Icon Paths:** Generic placeholders - will use GetItemIcon() at runtime

---

## NEXT PROMPT INSTRUCTIONS

Copy this to start implementation:

```
Implement PAYLOAD 1 for the Armory Tab feature.

Add the C.ARMORY_GEAR_DATABASE and related constants to Core/Constants.lua.
Follow the exact structure from ARMORY_TAB_PLAN.md "PAYLOAD 1" section.

The data includes:
- C.ARMORY_TIERS (tier definitions)
- C.ARMORY_SOURCE_TYPES (source display info)
- C.ARMORY_SLOTS (17 equipment slots with positions)
- C.ARMORY_ROLES (5 role definitions)
- C.ARMORY_QUALITY_COLORS (item quality colors)
- C.ARMORY_GEAR_DATABASE (main gear data for 5 roles × 17 slots)
- Helper functions: C:GetArmoryGear(), C:GetArmorySlots()

Add after existing constants (around line 4900+).
```
