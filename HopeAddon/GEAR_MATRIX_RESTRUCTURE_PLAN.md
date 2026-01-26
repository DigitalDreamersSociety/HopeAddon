# Gear Matrix Restructure Plan

## Overview

Transform `LEVELING_GEAR_MATRIX` from role-based indexing to class/spec-based indexing for accurate gear recommendations that respect armor types and weapon restrictions.

---

## Part 1: Immediate Bug Fixes - ✅ COMPLETED (2026-01-25)

### 1.1 Items Removed

| Item | Location | Issue | Status |
|------|----------|-------|--------|
| Hellreaver | tank 60-62 quests | Polearm - Druids can't use, also wrong category | ✅ REMOVED |
| Hellreaver | melee_dps 60-62 dungeons | Rogues CAN'T use polearms (comment was wrong) | ✅ REMOVED |
| Diamond-Core Sledgemace | caster_dps 60-62 | 2H Mace - Mages/Warlocks can't use maces | ✅ REMOVED |
| Collar of Command | caster_dps 66-67 | +66 Heal focus - it's a healer item | ✅ REMOVED |
| Creepjacker | melee_dps 63-65 | Fist weapon - Ferals prefer 2H, Rogues need spec-specific | ✅ REMOVED |

### 1.2 Stats Fixed

| Item | Location | Old Stats | New Stats | Status |
|------|----------|-----------|-----------|--------|
| Sure-Step Boots | melee_dps 60-62 quests | "+16 Agi, +18 Sta" | "+20 Agi, +28 Sta, +38 AP" | ✅ FIXED |
| Perfectly Balanced Cape | melee_dps 60-62 quests | "+22 AP, +14 Crit" (uncommon) | "+15 Agi, +22 Sta, +30 AP" (rare) | ✅ FIXED |
| Dark Cloak of the Marsh | melee_dps 63-65 quests | "+28 AP, +14 Crit" (uncommon) | "+16 Agi, +24 Sta, +30 AP" (rare) | ✅ FIXED |
| Dark Cloak of the Marsh | ranged_dps 63-65 quests | "+16 Agi, +28 AP" (uncommon) | "+16 Agi, +24 Sta, +30 AP" (rare) | ✅ FIXED |
| Talon Lord's Collar | melee_dps 66-67 quests | itemId 29333, "+30 AP, +16 Crit" | itemId 29335, "+19 Sta, +21 Hit, +38 AP" | ✅ FIXED |
| Talon Lord's Collar | ranged_dps 66-67 quests | itemId 29333, "+20 Agi, +30 AP" | itemId 29335, "+19 Sta, +21 Hit, +38 AP" | ✅ FIXED |
| The Saga of Terokk | caster_dps 66-67 quests | itemId 29336, "+14 Int, +20 Spell" | itemId 29330, "+23 Int, +28 Spell" | ✅ FIXED |
| Mantle of Magical Might | caster_dps 60-62 quests | "+16 Int, +22 Spell" (uncommon) | "+17 Int, +16 Sta, +10 Spirit, +16 Crit, +19 Spell" (rare) | ✅ FIXED |
| Deadly Borer Leggings | caster_dps 60-62 quests | itemId 25713, "+18 Int, +16 Sta, +24 Spell" | itemId 25711, "+23 Int, +21 Sta, +15 Spirit, +22 Crit, +27 Spell" | ✅ FIXED |
| Crimson Pendant of Clarity | caster_dps 60-62 quests | "+14 Int, +20 Spell" (uncommon) | "+15 Int, +18 Spell, +6 mp5" (rare) | ✅ FIXED |
| Consortium Prince's Wrap | caster_dps 63-65 quests | "+16 Int, +22 Spell" (uncommon) | "+22 Crit, +30 Spell, +20 Spell Pen" (rare) | ✅ FIXED |
| Haramad's Leg Wraps | healer 63-65 quests | "+18 Int, +12 Spirit, +28 Heal" | "+29 Spirit, +24 Heal, +8 Spell, +11 mp5, 3 sockets" | ✅ FIXED |
| Haramad's Leg Wraps | caster_dps 63-65 quests | "+18 Int, +26 Spell" (uncommon) | "+29 Spirit, +24 Heal, +8 Spell, +11 mp5, 3 sockets" (rare) | ✅ FIXED |
| Consortium Prince's Wrap | healer 63-65 quests | "+16 Int, +22 Heal" | REMOVED - DPS item (+Crit, +Spell Pen, no +Heal) | ✅ REMOVED |

Sources:
- [Wowhead TBC Classic - Sure-Step Boots](https://www.wowhead.com/tbc/item=25717/sure-step-boots)
- [Wowhead TBC Classic - Perfectly Balanced Cape](https://www.wowhead.com/tbc/item=25712/perfectly-balanced-cape)
- [Wowhead TBC Classic - Dark Cloak of the Marsh](https://www.wowhead.com/tbc/item=25540/dark-cloak-of-the-marsh)
- [Wowhead TBC Classic - Talon Lord's Collar](https://www.wowhead.com/tbc/item=29335/talon-lords-collar)
- [Wowhead TBC Classic - The Saga of Terokk](https://www.wowhead.com/tbc/item=29330/the-saga-of-terokk)
- [Wowhead TBC Classic - Mantle of Magical Might](https://www.wowhead.com/tbc/item=25718/mantle-of-magical-might)
- [Wowhead TBC Classic - Deadly Borer Leggings](https://www.wowhead.com/tbc/item=25711/deadly-borer-leggings)
- [Wowhead TBC Classic - Crimson Pendant of Clarity](https://www.wowhead.com/tbc/item=25714/crimson-pendant-of-clarity)
- [Wowhead TBC Classic - Consortium Prince's Wrap](https://www.wowhead.com/tbc/item=29328/consortium-princes-wrap)
- [Wowhead TBC Classic - Haramad's Leg Wraps](https://www.wowhead.com/tbc/item=29345/haramads-leg-wraps)

### 1.3 Comments Updated ✅

melee_dps section now correctly documents:
- Rogues - NO polearms, NO 2H swords, NO axes
- Feral Druids - prefer 2H, NO axes/swords/polearms
- Enhancement Shamans - dual wield, NO swords/polearms
- Ret Paladins - 2H preferred
- Also removed outdated "Creepjacker remains best until 70" comment

---

## Part 2: New Data Structure Design

### 2.1 Architecture Decision: String Keys

Using string keys for readability and maintainability:
- Easy to understand in code: `GEAR_MATRIX["WARRIOR"]["Protection"]`
- Self-documenting
- Allows class-specific items with clear naming
- Supports future expansion without breaking numeric indices

### 2.2 New Structure

```lua
C.LEVELING_GEAR_MATRIX = {
    ["WARRIOR"] = {
        ["Arms"] = { ["60-62"] = {...}, ["63-65"] = {...}, ["66-67"] = {...} },
        ["Fury"] = { ["60-62"] = {...}, ["63-65"] = {...}, ["66-67"] = {...} },
        ["Protection"] = { ["60-62"] = {...}, ["63-65"] = {...}, ["66-67"] = {...} },
    },
    ["PALADIN"] = {
        ["Holy"] = { ... },      -- Cloth healing gear (acceptable for leveling)
        ["Protection"] = { ... }, -- Plate tank gear
        ["Retribution"] = { ... }, -- Plate Str/AP gear
    },
    ["HUNTER"] = {
        ["Beast Mastery"] = { ... }, -- Mail/Leather agility (best-in-slot mix)
        ["Marksmanship"] = { ... },
        ["Survival"] = { ... },
    },
    ["ROGUE"] = {
        ["Assassination"] = { ... }, -- Leather agility
        ["Combat"] = { ... },
        ["Subtlety"] = { ... },
    },
    ["PRIEST"] = {
        ["Discipline"] = { ... }, -- Cloth healing
        ["Holy"] = { ... },       -- Cloth healing
        ["Shadow"] = { ... },     -- Cloth spell damage
    },
    ["SHAMAN"] = {
        ["Elemental"] = { ... },   -- Cloth/Leather/Mail spell damage (best-in-slot)
        ["Enhancement"] = { ... }, -- Leather/Mail agility (best-in-slot mix)
        ["Restoration"] = { ... }, -- Cloth healing
    },
    ["MAGE"] = {
        ["Arcane"] = { ... }, -- Cloth spell damage
        ["Fire"] = { ... },
        ["Frost"] = { ... },
    },
    ["WARLOCK"] = {
        ["Affliction"] = { ... }, -- Cloth spell damage
        ["Demonology"] = { ... },
        ["Destruction"] = { ... },
    },
    ["DRUID"] = {
        ["Balance"] = { ... },     -- Cloth/Leather spell damage
        ["Feral Combat"] = { ... }, -- Leather agility (shared calc with Rogue)
        ["Restoration"] = { ... }, -- Cloth healing
    },
}
```

### 2.3 Gear Set Templates (Reusable)

Create shared gear templates to avoid duplication:

```lua
-- Internal templates (not exposed in final structure)
local LEATHER_AGILITY_GEAR = {
    ["60-62"] = {
        dungeons = {
            { itemId = 24396, name = "Vest of Vengeance", ... },
            { itemId = 24063, name = "Shifting Sash of Midnight", ... },
            -- NO WEAPONS - class-specific
        },
        quests = {
            { itemId = 25717, name = "Sure-Step Boots", stats = "+20 Agi, +28 Sta, +38 AP", ... },
            { itemId = 25712, name = "Perfectly Balanced Cape", ... },
        },
    },
    -- ... 63-65, 66-67
}

local CLOTH_SPELL_DAMAGE_GEAR = { ... }
local CLOTH_HEALING_GEAR = { ... }
local PLATE_TANK_GEAR = { ... }
local MAIL_AGILITY_GEAR = { ... }
```

### 2.4 Spec-to-Template Mapping

```lua
-- Which template each spec uses (with optional class-specific overrides)
C.SPEC_GEAR_TEMPLATE = {
    ["WARRIOR"] = {
        ["Arms"] = "PLATE_DPS",
        ["Fury"] = "PLATE_DPS",
        ["Protection"] = "PLATE_TANK",
    },
    ["ROGUE"] = {
        ["Assassination"] = "LEATHER_AGILITY",
        ["Combat"] = "LEATHER_AGILITY",
        ["Subtlety"] = "LEATHER_AGILITY",
    },
    ["DRUID"] = {
        ["Feral Combat"] = "LEATHER_AGILITY", -- Same template as Rogue
        ["Balance"] = "CLOTH_SPELL_DAMAGE",
        ["Restoration"] = "CLOTH_HEALING",
    },
    ["SHAMAN"] = {
        ["Enhancement"] = "LEATHER_MAIL_AGILITY_MIX", -- Best-in-slot from both
        ["Elemental"] = "CLOTH_SPELL_DAMAGE",
        ["Restoration"] = "CLOTH_HEALING",
    },
    -- etc.
}
```

---

## Part 3: Gear Templates Detail

### 3.1 LEATHER_AGILITY (Rogue, Feral Druid)

**Armor:** Leather only
**Stats:** Agility, Stamina, Attack Power, Crit, Hit
**Weapons:** Excluded (class-specific - daggers/fist for Rogue, maces/staves/fist for Druid)

### 3.2 LEATHER_MAIL_AGILITY_MIX (Enhancement Shaman, Hunter)

**Armor:** Best-in-slot from leather OR mail
**Stats:** Agility, Stamina, Attack Power, Crit, Hit
**Note:** Show leather items if they have better stats than available mail

### 3.3 PLATE_TANK (Warrior Protection, Paladin Protection)

**Armor:** Plate only
**Stats:** Stamina, Defense, Dodge, Parry, Block, Armor
**Weapons:** Excluded (class-specific)

### 3.4 PLATE_DPS (Warrior Arms/Fury, Paladin Retribution)

**Armor:** Plate only
**Stats:** Strength, Stamina, Attack Power, Crit, Hit
**Note:** Fury may prefer dual-wield stats, Arms prefers 2H

### 3.5 CLOTH_SPELL_DAMAGE (Mage, Warlock, Shadow Priest, Balance Druid, Ele Shaman)

**Armor:** Cloth (acceptable for all casters while leveling)
**Stats:** Intellect, Stamina, Spell Damage, Spell Crit, Spell Hit
**Weapons:** Staves, Daggers, 1H Swords (class-dependent)

### 3.6 CLOTH_HEALING (All healer specs)

**Armor:** Cloth (acceptable for all healers while leveling)
**Stats:** Intellect, Spirit, +Healing, mp5
**Note:** Healers prioritize +Heal over armor type during leveling

---

## Part 4: Updated Lookup Functions

### 4.1 New GetLevelingGear Function

```lua
function C:GetLevelingGear(className, specName, level)
    local rangeKey = self:GetLevelRangeKey(level)
    if not rangeKey then return nil end

    local classData = self.LEVELING_GEAR_MATRIX[className]
    if not classData then return nil end

    local specData = classData[specName]
    if not specData then return nil end

    return specData[rangeKey]
end
```

### 4.2 Spec Name Lookup Helper

```lua
-- Map from GetTalentTabInfo() spec names to our keys
C.SPEC_NAME_LOOKUP = {
    ["WARRIOR"] = {
        [1] = "Arms",
        [2] = "Fury",
        [3] = "Protection",
    },
    ["PALADIN"] = {
        [1] = "Holy",
        [2] = "Protection",
        [3] = "Retribution",
    },
    ["HUNTER"] = {
        [1] = "Beast Mastery",
        [2] = "Marksmanship",
        [3] = "Survival",
    },
    ["ROGUE"] = {
        [1] = "Assassination",
        [2] = "Combat",
        [3] = "Subtlety",
    },
    ["PRIEST"] = {
        [1] = "Discipline",
        [2] = "Holy",
        [3] = "Shadow",
    },
    ["SHAMAN"] = {
        [1] = "Elemental",
        [2] = "Enhancement",
        [3] = "Restoration",
    },
    ["MAGE"] = {
        [1] = "Arcane",
        [2] = "Fire",
        [3] = "Frost",
    },
    ["WARLOCK"] = {
        [1] = "Affliction",
        [2] = "Demonology",
        [3] = "Destruction",
    },
    ["DRUID"] = {
        [1] = "Balance",
        [2] = "Feral Combat",
        [3] = "Restoration",
    },
}

function C:GetSpecNameFromTab(className, specTab)
    local classSpecs = self.SPEC_NAME_LOOKUP[className]
    if classSpecs then
        return classSpecs[specTab]
    end
    return nil
end
```

### 4.3 Integration with Existing Code

Update `Journal.lua:PopulateJourneyLeveling()`:

```lua
-- Old code:
local role = HopeAddon:GetSpecRole(className, specTab)
local gearData = C:GetLevelingGear(role, playerLevel)

-- New code:
local specName = C:GetSpecNameFromTab(className, specTab)
local gearData = C:GetLevelingGear(className, specName, playerLevel)
```

---

## Part 5: Implementation Phases

### Phase 1: Bug Fixes (Can do immediately)
1. Delete 4 invalid items (Hellreaver x2, Sledgemace, Collar)
2. Fix Sure-Step Boots stats
3. Update melee_dps comments

### Phase 2: Create Templates
1. Define base gear templates (LEATHER_AGILITY, CLOTH_HEALING, etc.)
2. Populate with current valid items
3. Add SPEC_NAME_LOOKUP table

### Phase 3: Build New Structure
1. Create new LEVELING_GEAR_MATRIX with class/spec keys
2. Map each spec to appropriate template
3. Add any class-specific items or overrides

### Phase 4: Update Lookup Functions
1. Add GetSpecNameFromTab()
2. Update GetLevelingGear() signature
3. Update Journal.lua to use new API

### Phase 5: Cleanup
1. Remove old role-based code
2. Update CLAUDE.md documentation
3. Test all 27 spec combinations

---

## Part 6: Class/Spec Summary Table

| Class | Spec 1 | Spec 2 | Spec 3 |
|-------|--------|--------|--------|
| **WARRIOR** | Arms (Plate DPS) | Fury (Plate DPS) | Protection (Plate Tank) |
| **PALADIN** | Holy (Cloth Heal) | Protection (Plate Tank) | Retribution (Plate DPS) |
| **HUNTER** | Beast Mastery (Mail/Leather Agi) | Marksmanship (Mail/Leather Agi) | Survival (Mail/Leather Agi) |
| **ROGUE** | Assassination (Leather Agi) | Combat (Leather Agi) | Subtlety (Leather Agi) |
| **PRIEST** | Discipline (Cloth Heal) | Holy (Cloth Heal) | Shadow (Cloth Spell) |
| **SHAMAN** | Elemental (Cloth Spell) | Enhancement (Mail/Leather Agi) | Restoration (Cloth Heal) |
| **MAGE** | Arcane (Cloth Spell) | Fire (Cloth Spell) | Frost (Cloth Spell) |
| **WARLOCK** | Affliction (Cloth Spell) | Demonology (Cloth Spell) | Destruction (Cloth Spell) |
| **DRUID** | Balance (Cloth Spell) | Feral Combat (Leather Agi) | Restoration (Cloth Heal) |

**Total: 9 classes × 3 specs = 27 combinations**

**Unique Templates: 6**
- PLATE_TANK (2 specs)
- PLATE_DPS (3 specs)
- LEATHER_AGILITY (6 specs: 3 Rogue + 1 Feral + shared calc)
- MAIL_LEATHER_AGILITY_MIX (4 specs: 3 Hunter + 1 Enh Shaman)
- CLOTH_SPELL_DAMAGE (8 specs: 3 Mage + 3 Lock + 1 Shadow + 1 Balance + 1 Ele)
- CLOTH_HEALING (5 specs: 2 Priest + 1 Holy Pally + 1 Resto Shaman + 1 Resto Druid)

---

## Part 7: Items to Research/Add

### Missing Gear for New Specs

**PLATE_DPS (currently no data):**
- Arms/Fury Warrior need Str/AP plate
- Ret Paladin needs Str/AP plate
- Research TBC 60-67 plate DPS items

**Class-Specific Weapons:**
- Each melee spec needs appropriate weapon recommendations
- Casters need staff/dagger/wand recommendations

---

## Appendix: Weapon Proficiencies Reference

| Class | Daggers | Swords 1H | Swords 2H | Maces 1H | Maces 2H | Axes 1H | Axes 2H | Polearms | Staves | Fist |
|-------|---------|-----------|-----------|----------|----------|---------|---------|----------|--------|------|
| Warrior | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Paladin | - | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - | - |
| Hunter | ✓ | ✓ | ✓ | - | - | ✓ | ✓ | ✓ | ✓ | ✓ |
| Rogue | ✓ | ✓ | - | ✓ | - | - | - | - | - | ✓ |
| Priest | ✓ | - | - | ✓ | - | - | - | - | ✓ | - |
| Shaman | ✓ | - | - | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| Mage | ✓ | ✓ | - | - | - | - | - | - | ✓ | - |
| Warlock | ✓ | ✓ | - | - | - | - | - | - | ✓ | - |
| Druid | ✓ | - | - | ✓ | ✓ | - | - | - | ✓ | ✓ |

**Key Restrictions:**
- **Rogues**: NO polearms, NO 2H swords, NO axes, NO staves
- **Druids**: NO swords, NO axes, NO polearms
- **Shamans**: NO swords, NO polearms
- **Mages/Warlocks**: NO maces, NO axes, NO polearms, NO fist weapons
- **Priests**: NO swords, NO axes, NO polearms, NO fist weapons
