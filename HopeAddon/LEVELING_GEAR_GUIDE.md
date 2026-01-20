# Leveling Gear Guide - Feature Documentation

## Overview

The Leveling Gear Guide appears in the Journey tab for characters level 60-67, providing role-based gear recommendations from dungeons and quests appropriate for their level range.

**Files:**
- `Core/Constants.lua` - Data definitions (LEVELING_RANGES, LEVELING_ROLES, LEVELING_DUNGEONS, LEVELING_GEAR_MATRIX)
- `Core/Core.lua` - SPEC_ROLE_MAP and GetPlayerSpec()/GetSpecRole() functions
- `Journal/Journal.lua` - PopulateJourneyLeveling() and related UI functions

---

## Level Range Coverage

| Range | Levels | Dungeon Group | Dungeons |
|-------|--------|---------------|----------|
| **60-62** | 60-62 | Hellfire Citadel | Hellfire Ramparts, Blood Furnace |
| **63-65** | 63-65 | Coilfang / Auchindoun | Slave Pens, Underbog, Mana-Tombs |
| **66-67** | 66-67 | Auchindoun / CoT | Auchenai Crypts, Old Hillsbrad, Sethekk Halls |

**Pre-60:** Shows "Journey to Outland" encouragement message
**68+:** Shows endgame attunement/raid progression

---

## Role Definitions

| Role | Display Name | Icon | Color | Used By |
|------|-------------|------|-------|---------|
| `tank` | Tank | Ability_Warrior_DefensiveStance | SKY_BLUE | Warrior Prot, Paladin Prot |
| `healer` | Healer | Spell_Holy_FlashHeal | FEL_GREEN | Paladin Holy, Priest Disc/Holy, Druid Resto, Shaman Resto |
| `melee_dps` | Melee DPS | Ability_MeleeDamage | HELLFIRE_RED | Warrior Arms/Fury, Paladin Ret, Druid Feral, Shaman Enh, Rogue (all) |
| `ranged_dps` | Ranged DPS | Ability_Hunter_AimedShot | GOLD_BRIGHT | Hunter (all specs) |
| `caster_dps` | Caster DPS | Spell_Fire_FlameBolt | ARCANE_PURPLE | Priest Shadow, Druid Balance, Shaman Elem, Mage (all), Warlock (all) |

---

## Spec-to-Role Mapping (27 specs)

### WARRIOR
| Spec | Tab | Role |
|------|-----|------|
| Arms | 1 | melee_dps |
| Fury | 2 | melee_dps |
| Protection | 3 | tank |

### PALADIN
| Spec | Tab | Role |
|------|-----|------|
| Holy | 1 | healer |
| Protection | 2 | tank |
| Retribution | 3 | melee_dps |

### PRIEST
| Spec | Tab | Role |
|------|-----|------|
| Discipline | 1 | healer |
| Holy | 2 | healer |
| Shadow | 3 | caster_dps |

### DRUID
| Spec | Tab | Role |
|------|-----|------|
| Balance | 1 | caster_dps |
| Feral | 2 | melee_dps |
| Restoration | 3 | healer |

**Note:** Feral Druid maps to melee_dps (not tank) because the melee gear works for both cat and bear forms at leveling stages.

### SHAMAN
| Spec | Tab | Role |
|------|-----|------|
| Elemental | 1 | caster_dps |
| Enhancement | 2 | melee_dps |
| Restoration | 3 | healer |

### MAGE
| Spec | Tab | Role |
|------|-----|------|
| Arcane | 1 | caster_dps |
| Fire | 2 | caster_dps |
| Frost | 3 | caster_dps |

### WARLOCK
| Spec | Tab | Role |
|------|-----|------|
| Affliction | 1 | caster_dps |
| Demonology | 2 | caster_dps |
| Destruction | 3 | caster_dps |

### HUNTER
| Spec | Tab | Role |
|------|-----|------|
| Beast Mastery | 1 | ranged_dps |
| Marksmanship | 2 | ranged_dps |
| Survival | 3 | ranged_dps |

### ROGUE
| Spec | Tab | Role |
|------|-----|------|
| Assassination | 1 | melee_dps |
| Combat | 2 | melee_dps |
| Subtlety | 3 | melee_dps |

---

## Item Matrix Status

### Summary

| Role | 60-62 | 63-65 | 66-67 | Total |
|------|-------|-------|-------|-------|
| **tank** | 3D + 3Q ✅ | 3D + 3Q ✅ | 3D + 3Q ✅ | 18 |
| **healer** | 3D + 3Q ✅ | 3D + 3Q ✅ | 3D + 3Q ✅ | 18 |
| **melee_dps** | 3D + 3Q ✅ | 3D + 3Q ✅ | 3D + 3Q ✅ | 18 |
| **ranged_dps** | 3D + 3Q ✅ | 3D + 3Q ✅ | 3D + 3Q ✅ | 18 |
| **caster_dps** | 3D + 3Q ✅ | 3D + 3Q ✅ | 3D + 3Q ✅ | 18 |
| **TOTAL** | 30 | 30 | 30 | **90** |

**Legend:** D = Dungeon items, Q = Quest items

---

## Detailed Item Lists

### TANK (Warrior Prot, Paladin Prot)

#### Level 60-62
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Jade-Skull Breastplate | Chest | +26 Str, +27 Sta, +23 Def | Blood Furnace (Keli'dan) |
| Ironsole Clompers | Feet | +21 Sta, +20 Def, +14 Parry | Blood Furnace (Broggok) |
| Mok'Nathal Wildercloak | Back | +18 Sta, +17 Def | Hellfire Ramparts (Vazruden) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Footman's Longsword | 1H Sword | +16 Sta, +14 Def | Weaken the Ramparts |
| Pilgrim's Cover | Back | +14 Sta, +12 Def | Heart of Rage |
| Watchman's Pauldrons | Shoulder | +18 Sta, +16 Def | Overlord |

#### Level 63-65
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Unscarred Breastplate | Chest | +26 Str, +21 Agi, +23 Sta, +20 Def | Slave Pens (Quagmirran) |
| Earthwarden's Coif | Head | +28 Sta, +24 Def, +18 Dodge | Underbog (Black Stalker) |
| Nexus-Guard's Pauldrons | Shoulder | +22 Sta, +18 Def, +14 Block | Mana-Tombs (Pandemonius) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Cenarion Thicket Legplates | Legs | +22 Sta, +18 Def | Lost in Action |
| Consortium Plated Legguards | Legs | +24 Sta, +20 Def | Undercutting the Competition |
| Sha'tari Vindicator's Waistguard | Waist | +16 Sta, +14 Def | The Aldor/Scryers quest |

#### Level 66-67
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Flesh Handler's Gauntlets | Hands | +24 Sta, +22 Def, +18 Parry | Auchenai Crypts (Shirrak) |
| Helm of the Crypt Lord | Head | +32 Sta, +28 Def, +22 Block | Auchenai Crypts (Exarch Maladaar) |
| Epoch's Whispering Cinch | Waist | +20 Sta, +18 Def, +16 Dodge | Old Hillsbrad (Epoch Hunter) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Tarren Mill Defender's Shield | Shield | +26 Sta, +24 Block | Return to Andormu |
| Auchenai Defender's Cape | Back | +18 Sta, +16 Def | Brother Against Brother |
| Sha'tari Defender's Girdle | Waist | +20 Sta, +18 Def | Terokk's Legacy |

---

### HEALER (Paladin Holy, Priest Disc/Holy, Druid Resto, Shaman Resto)

#### Level 60-62
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Light-Touched Stole of Altruism | Shoulder | +18 Int, +17 Spirit, +42 Heal | Blood Furnace (Keli'dan) |
| Lifegiver Britches | Legs | +22 Int, +20 Sta, +53 Heal | Hellfire Ramparts (Omor) |
| Cord of Belief | Waist | +15 Int, +14 Spirit, +35 Heal | Hellfire Ramparts (Gargolmar) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Light-Woven Slippers | Feet | +16 Int, +28 Heal | Weaken the Ramparts |
| Medic's Sash | Waist | +14 Int, +24 Heal | Heart of Rage |
| Spiritualist's Mark of the Sha'tar | Neck | +12 Int, +20 Heal | Overlord |

#### Level 63-65
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Primal Surge Bracers | Wrist | +14 Int, +13 Spirit, +35 Heal | Slave Pens (Quagmirran) |
| Helm of the Marsh | Head | +26 Int, +22 Spirit, +57 Heal | Underbog (Black Stalker) |
| Starlight Dew | Neck | +12 Int, +11 Crit, +33 Heal | Mana-Tombs (Tavarok) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Cenarion Ring of Casting | Ring | +14 Int, +18 Heal | Lost in Action |
| Swampstone Necklace | Neck | +16 Int, +28 Heal | Wanted: Bogstrok |
| Sha'tari Anchorite's Cloak | Back | +14 Int, +24 Heal | Mana-Tombs quest |

#### Level 66-67
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Light-Touched Stole of Altruism | Shoulder | +21 Int, +19 Spirit, +51 Heal | Auchenai Crypts (Shirrak) |
| Hallowed Pauldrons | Shoulder | +24 Int, +22 Spirit, +55 Heal | Old Hillsbrad (Captain Skarloc) |
| Auchenai Anchorite's Robe | Chest | +28 Int, +26 Spirit, +66 Heal | Auchenai Crypts (Exarch Maladaar) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Epoch Mender's Ring | Ring | +16 Int, +30 Heal | Return to Andormu |
| Auchenai Healer's Cloak | Back | +18 Int, +32 Heal | Brother Against Brother |
| Sha'tari Keeper's Band | Ring | +14 Int, +26 Heal | Terokk's Legacy |

---

### MELEE DPS (Warrior Arms/Fury, Paladin Ret, Druid Feral, Shaman Enh, Rogue all)

#### Level 60-62
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Hellreaver | Polearm | +30 Str, +27 Sta, +25 Crit | Hellfire Ramparts (Vazruden) |
| Vest of Vengeance | Chest | +27 Agi, +18 Sta, +42 AP, +11 Hit | Blood Furnace (Keli'dan) |
| Ironblade Gauntlets | Hands | +14 Agi, +19 Sta, +20 Str, +6 Hit | Blood Furnace (The Maker) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Handguards of Precision | Hands | +18 Agi, +26 AP | Weaken the Ramparts |
| Sure-Step Boots | Feet | +16 Agi, +18 Sta | Weaken the Ramparts |
| Perfectly Balanced Cape | Back | +22 AP, +14 Crit | Heart of Rage |

#### Level 63-65
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Creepjacker | Fist | +13 Sta, +13 Crit, +28 AP | Mana-Tombs (Pandemonius) |
| Deft Handguards | Hands | +52 AP, +12 Crit, +18 Sta | Slave Pens (Quagmirran) |
| Skulldugger's Leggings | Legs | +40 AP, +21 Dodge, +16 Hit, +24 Sta | Underbog (Black Stalker) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Dark Cloak of the Marsh | Back | +28 AP, +14 Crit | Lost in Action |
| Haramad's Leggings of the Third Coin | Legs | +22 Agi, +20 Sta, +32 AP | Undercutting the Competition |
| Cryo-mitts | Hands | +18 Agi, +16 Sta | Mana-Tombs Quest |

#### Level 66-67
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Darkguard Face Mask | Head | +29 Agi, +30 Sta, +20 Hit, +60 AP | Auchenai Crypts (Exarch Maladaar) |
| Amani Venom-Axe | 1H Axe | +26 AP, +15 Crit, +15 Sta | Old Hillsbrad (Captain Skarloc) |
| Cloak of Impulsiveness | Back | +18 Agi, +19 Sta, +40 AP | Old Hillsbrad (Lieutenant Drake) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Talon Lord's Collar | Neck | +30 AP, +16 Crit | Brother Against Brother |
| Auchenai Tracker's Hauberk | Chest | +24 Agi, +22 Sta, +38 AP | Everything Will Be Alright |
| Terokk's Quill | Polearm | +26 Str, +24 Sta, +44 AP | Terokk's Legacy |

---

### RANGED DPS (Hunter all specs)

#### Level 60-62
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Legion Blunderbuss | Gun | +9 Agi, +24 AP | Blood Furnace (Broggok) |
| Scale Leggings of the Skirmisher | Legs | +22 Agi, +24 Sta, +32 AP | Hellfire Ramparts (Gargolmar) |
| Garrote-String Necklace | Neck | +36 AP, +14 Crit, +16 Sta | Hellfire Ramparts (Omor) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Handguards of Precision | Hands | +18 Agi, +26 AP | Weaken the Ramparts |
| Scaled Legs of Ruination | Legs | +20 Agi, +18 Sta, +28 AP | Heart of Rage |
| Sure-Step Boots | Feet | +16 Agi, +18 Sta | Weaken the Ramparts |

#### Level 63-65
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Coilfang Needler | Crossbow | +12 Agi, +22 AP | Slave Pens (Rokmar) |
| Shamblehide Chestguard | Chest | +16 Sta, +19 Int, +21 Crit, +44 AP | Underbog (Black Stalker) |
| Nethershade Boots | Feet | +22 Agi, +21 Sta, +44 AP | Mana-Tombs (Tavarok) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Dark Cloak of the Marsh | Back | +16 Agi, +28 AP | Lost in Action |
| Consortium Mantle of Phasing | Shoulder | +18 Agi, +16 Sta | Mana-Tombs Quest |
| Haramad's Linked Chain Pantaloons | Legs | +20 Agi, +18 Sta, +14 Int | Undercutting the Competition |

#### Level 66-67
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Ring of the Exarchs | Ring | +17 Agi, +24 Sta, +34 AP | Auchenai Crypts (Exarch Maladaar) |
| Mok'Nathal Beast-Mask | Head | +23 Agi, +22 Sta, +44 AP | Auchenai Crypts (Exarch Maladaar) |
| Scaled Greaves of Patience | Legs | +28 Agi, +13 Int, +46 AP, +24 Sta | Old Hillsbrad (Captain Skarloc) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Tarren Mill Defender's Cinch | Waist | +18 Agi, +16 Sta | Return to Andormu |
| Talon Lord's Collar | Neck | +20 Agi, +30 AP | Brother Against Brother |
| Auchenai Tracker's Hauberk | Chest | +24 Agi, +22 Sta, +38 AP | Everything Will Be Alright |

---

### CASTER DPS (Priest Shadow, Druid Balance, Shaman Elem, Mage all, Warlock all)

#### Level 60-62
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Crystalfire Staff | Staff | +34 Int, +34 Sta, +46 Spell | Hellfire Ramparts (Omor) |
| Diamond-Core Sledgemace | 2H Mace | +12 Sta, +51 Spell | Blood Furnace (The Maker) |
| Pauldrons of Arcane Rage | Shoulder | +18 Int, +18 Sta, +27 Spell | Hellfire Ramparts (Gargolmar) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Mantle of Magical Might | Shoulder | +16 Int, +22 Spell | Weaken the Ramparts |
| Deadly Borer Leggings | Legs | +18 Int, +16 Sta, +24 Spell | Heart of Rage |
| Crimson Pendant of Clarity | Neck | +14 Int, +20 Spell | Heart of Rage |

#### Level 63-65
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Staff of Polarities | Staff | +33 Int, +34 Sta, +28 Hit, +67 Spell | Mana-Tombs (Tavarok) |
| Luminous Pearls of Insight | Neck | +15 Int, +11 Crit, +25 Spell | Underbog (Ghaz'an) |
| Spore-Soaked Vaneer | Shoulder | +15 Int, +15 Sta, +11 Crit, +19 Spell | Slave Pens (Quagmirran) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Cenarion Ring of Casting | Ring | +14 Int, +18 Spell | Lost in Action |
| Consortium Prince's Wrap | Waist | +16 Int, +22 Spell | Mana-Tombs Quest |
| Haramad's Leg Wraps | Legs | +18 Int, +26 Spell | Undercutting the Competition |

#### Level 66-67
**Dungeon Drops:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Time-Shifted Dagger | Dagger | +15 Int, +15 Sta, +13 Crit, +85 Spell | Old Hillsbrad (Epoch Hunter) |
| Stormreaver Shadow-Kilt | Legs | +26 Int, +19 Sta, +14 Spirit, +25 Crit, +30 Spell | Old Hillsbrad (Lieutenant Drake) |
| Collar of Command | Head | +23 Int, +22 Sta, +29 Spirit, +22 Spell, +66 Heal | Auchenai Crypts (Shirrak) |

**Quest Rewards:**
| Item | Slot | Stats | Source |
|------|------|-------|--------|
| Tempest's Touch | Hands | +18 Int, +28 Spell | Return to Andormu |
| Torc of the Sethekk Prophet | Neck | +16 Int, +24 Spell | Brother Against Brother |
| The Saga of Terokk | Off-hand | +14 Int, +20 Spell | Terokk's Legacy |

---

## Known Issues & Notes

### Armor Class Considerations
- **Melee DPS** gear is primarily leather/mail with agility - works for Rogues, Feral Druids, Enhancement Shamans
- **Tank** gear is plate-focused - works for Warriors and Paladins
- **Healer** gear is cloth/mail with healing power - works across all healer classes

### Feral Druid Note
Feral Druid (Tab 2) maps to `melee_dps` rather than `tank` because:
1. Leveling gear with agility/AP works for both cat and bear forms
2. At 60-67, dedicated tank gear matters less than at 70
3. Tank gear would be overly defensive for questing/leveling

### Enhancement Shaman Note
Enhancement Shaman uses `melee_dps` gear which includes:
- Agility leather and mail
- Attack power
- Crit rating
- Some items may be leather (equippable) rather than mail

---

## API Reference

### Helper Functions (Constants.lua)

```lua
-- Get level range key from player level
-- Returns: "60-62", "63-65", "66-67", or nil (for <60 or 68+)
C:GetLevelRangeKey(level)

-- Get leveling gear for a role and level
-- Returns: { dungeons = {...}, quests = {...} } or nil
C:GetLevelingGear(role, level)

-- Get recommended dungeons for a level
-- Returns: array of dungeon definitions
C:GetRecommendedDungeons(level)
```

### Helper Functions (Core.lua)

```lua
-- Get player's primary spec based on talent points
-- Returns: specName, specTab (1-3), maxPoints
HopeAddon:GetPlayerSpec()

-- Get role for a class and spec tab
-- Returns: "tank", "healer", "melee_dps", "ranged_dps", or "caster_dps"
HopeAddon:GetSpecRole(classToken, specTab)

-- Check if a role is a DPS role
-- Returns: boolean
HopeAddon:IsDPSRole(role)
```

---

## Changelog

### 2026-01-20
- Added pre-60 "Journey to Outland" message for characters below level 60
- Created this documentation file

### 2026-01-19 (Phase 37)
- Initial implementation of Leveling Gear Guide
- 5 roles × 3 level ranges × 6 items = 90 total items
- All 27 class/spec combinations mapped to appropriate roles
