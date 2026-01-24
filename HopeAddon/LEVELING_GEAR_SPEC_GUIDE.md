# TBC Leveling Gear Guide - Class & Spec Edition

## Overview

This document serves as the comprehensive research foundation for HopeAddon's leveling gear recommendations. Instead of generic role-based suggestions, we provide **spec-specific** recommendations for all 30 TBC specs across 3 level ranges.

**Goal:** Build item ID tables for `C.SPEC_LEVELING_GEAR` in Constants.lua

---

## Scope

### Classes & Specs (30 total)

| Class | Spec 1 | Spec 2 | Spec 3 |
|-------|--------|--------|--------|
| **Warrior** | Arms | Fury | Protection |
| **Paladin** | Holy | Protection | Retribution |
| **Hunter** | Beast Mastery | Marksmanship | Survival |
| **Rogue** | Assassination | Combat | Subtlety |
| **Priest** | Discipline | Holy | Shadow |
| **Shaman** | Elemental | Enhancement | Restoration |
| **Mage** | Arcane | Fire | Frost |
| **Warlock** | Affliction | Demonology | Destruction |
| **Druid** | Balance | Feral Combat | Restoration |

**Note:** TBC Classic has 9 classes (no Death Knights). However, listing 10 to account for future-proofing.

### Level Ranges (4 total)

| Range | Levels | Zone Focus | Dungeons | Phase |
|-------|--------|------------|----------|-------|
| **60-62** | Fresh 60 to mid Outland | Hellfire Peninsula | Hellfire Ramparts, Blood Furnace | Leveling |
| **63-65** | Mid Outland | Zangarmarsh, Terokkar | Slave Pens, Underbog, Mana-Tombs | Leveling |
| **66-67** | Late Outland | Terokkar, Nagrand, Blade's Edge | Auchenai Crypts, Sethekk Halls, Old Hillsbrad | Leveling |
| **68-70** | Fresh 70 / Pre-Heroic | Netherstorm, SMV, Shattrath | **NORMAL MODE ONLY:** Shadow Labyrinth, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass | Pre-Heroic Gearing |

### 68-70 "Pre-Heroic" Design Philosophy

At level 68-70, the addon shifts from "leveling gear" to "heroic preparation gear":

1. **NORMAL DUNGEONS ONLY** - No heroic drops until gearscore threshold met
2. **Gearscore Gate** - Once player reaches ~95 average item level, unlock heroic recommendations
3. **Reputation Emphasis** - Revered rep rewards are crucial for heroic keys + gear
4. **Quest Chains** - Netherstorm/SMV epic quest rewards (Cipher of Damnation, etc.)

#### Gearscore Threshold System

```
PHASE 1: Fresh 68-70 (iLvl < 95 avg)
├─ Recommend: Normal dungeon drops only
├─ Recommend: Revered reputation gear
├─ Recommend: Netherstorm/SMV quest epics
└─ Message: "Gear up in Normal dungeons before attempting Heroics"

PHASE 2: Heroic-Ready (iLvl >= 95 avg)
├─ Recommend: Heroic dungeon drops
├─ Recommend: Exalted reputation gear
├─ Recommend: Badge of Justice items
└─ Message: "You're ready for Heroic dungeons!"

PHASE 3: Raid-Ready (iLvl >= 110 avg)
├─ Recommend: Karazhan drops
├─ Show: Attunement progress
└─ Message: "Consider starting Karazhan attunement"
```

**Gearscore Calculation (TBC-style):**
- Sum of all equipped item levels ÷ 16 slots = Average iLvl
- Normal L70 dungeon gear: ~105-115 iLvl
- Heroic dungeon gear: ~110-125 iLvl
- Karazhan gear: ~115-125 iLvl

### Item Categories (per spec per range)

**Ranges 60-67 (Leveling):**
1. **Dungeon Drops** - 3 items from appropriate-level dungeons
2. **Quest Rewards** - 3 items from zone quests

**Range 68-70 (Pre-Heroic):**
1. **Normal Dungeon Drops** - 4 items from L70 normal dungeons
2. **Quest Rewards** - 3 items from Netherstorm/SMV/Shattrath
3. **Reputation Rewards** - 2 items from Revered standing

**Total Items:**
- Leveling (60-67): 27 specs × 3 ranges × 6 items = **486 items**
- Pre-Heroic (68-70): 27 specs × 1 range × 9 items = **243 items**
- **GRAND TOTAL: 729 items**

---

## Research Template

For each spec, research should follow this format:

```markdown
### [Class] - [Spec Name]

**Primary Stats:** [List priority stats]
**Armor Type:** [Cloth/Leather/Mail/Plate]
**Weapon Types:** [List usable weapons]

#### Level 60-62

**Dungeon Drops:**
| Item ID | Item Name | Slot | Stats | Source |
|---------|-----------|------|-------|--------|
| XXXXX | Name | Slot | +XX Stat, +XX Stat | Dungeon (Boss) |

**Quest Rewards:**
| Item ID | Item Name | Slot | Stats | Quest Name |
|---------|-----------|------|-------|------------|
| XXXXX | Name | Slot | +XX Stat, +XX Stat | Quest Name |

**Reputation:**
| Item ID | Item Name | Slot | Stats | Faction (Standing) |
|---------|-----------|------|-------|-------------------|
| XXXXX | Name | Slot | +XX Stat, +XX Stat | Honor Hold/Thrallmar (Honored) |

#### Level 63-65
[Same format]

#### Level 66-67
[Same format]
```

---

## Stat Priorities by Spec

### Warrior

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Arms | Strength, AP | Crit, Hit | Stamina |
| Fury | Strength, AP | Crit, Hit | Haste |
| Protection | Stamina, Defense | Block, Parry | Dodge |

### Paladin

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Holy | +Healing, Intellect | MP5, Spirit | Stamina |
| Protection | Stamina, Defense | Spell Power, Block | Strength |
| Retribution | Strength, AP | Crit, Hit | Spell Power |

### Hunter

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Beast Mastery | Agility, AP | Crit, Hit | Intellect |
| Marksmanship | Agility, AP | Crit, Hit | Intellect |
| Survival | Agility, AP | Crit, Hit | Stamina |

### Rogue

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Assassination | Agility, AP | Crit, Hit | Haste |
| Combat | Agility, AP | Hit, Crit | Expertise |
| Subtlety | Agility, AP | Crit, Hit | Haste |

### Priest

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Discipline | +Healing, Intellect | Spirit, MP5 | Stamina |
| Holy | +Healing, Intellect | Spirit, MP5 | Crit |
| Shadow | Spell Damage, Intellect | Crit, Hit | Spirit |

### Shaman

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Elemental | Spell Damage, Intellect | Crit, Hit | MP5 |
| Enhancement | Agility, AP, Strength | Crit, Hit | Intellect |
| Restoration | +Healing, Intellect | MP5, Spirit | Crit |

### Mage

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Arcane | Spell Damage, Intellect | Crit, Hit | Spirit |
| Fire | Spell Damage, Intellect | Crit, Hit | Stamina |
| Frost | Spell Damage, Intellect | Crit, Hit | Stamina |

### Warlock

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Affliction | Spell Damage, Intellect | Crit, Hit | Spirit |
| Demonology | Spell Damage, Stamina | Intellect, Hit | Spirit |
| Destruction | Spell Damage, Intellect | Crit, Hit | Stamina |

### Druid

| Spec | Primary | Secondary | Tertiary |
|------|---------|-----------|----------|
| Balance | Spell Damage, Intellect | Crit, Hit | Spirit |
| Feral Combat | Agility, AP, Strength | Crit, Hit | Stamina |
| Restoration | +Healing, Intellect | Spirit, MP5 | Crit |

---

## CLASS EQUIPMENT SPECIFICATIONS

This section provides **exact** weapon and armor restrictions for each class and spec. Agents MUST only recommend items that match these specifications.

---

### WARRIOR

**Armor:** Plate (can wear Mail, Leather, Cloth but should prioritize Plate)

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Default |
| 2H Swords | Yes | Trainer |
| 1H Axes | Yes | Trainer |
| 2H Axes | Yes | Trainer |
| 1H Maces | Yes | Default |
| 2H Maces | Yes | Trainer |
| Daggers | Yes | Trainer |
| Fist Weapons | Yes | Trainer |
| Polearms | Yes | Trainer |
| Staves | Yes | Trainer |
| Bows | Yes | Trainer |
| Crossbows | Yes | Trainer |
| Guns | Yes | Trainer |
| Thrown | Yes | Trainer |
| Shields | Yes | Default |

#### Arms (Tab 1)
**Preferred Weapons:** 2H Swords, 2H Axes, 2H Maces, Polearms
**Weapon Style:** Two-handed weapons (Mortal Strike requires 2H)
**Recommended Slots:**
- Main Hand: 2H Sword/Axe/Mace/Polearm
- Ranged: Bow/Gun/Crossbow/Thrown (stat stick)

#### Fury (Tab 2)
**Preferred Weapons:** Dual-wield 1H Swords, 1H Axes, 1H Maces, Fist Weapons
**Weapon Style:** Dual-wield (Bloodthirst works with any, Whirlwind benefits from dual-wield)
**Note:** Can also use 2H weapons but dual-wield is preferred at 60+
**Recommended Slots:**
- Main Hand: 1H Sword/Axe/Mace/Fist (slow speed preferred)
- Off Hand: 1H Sword/Axe/Mace/Fist (fast speed preferred)
- Ranged: Bow/Gun/Crossbow/Thrown (stat stick)

#### Protection (Tab 3)
**Preferred Weapons:** 1H Swords, 1H Axes, 1H Maces + Shield
**Weapon Style:** One-hand + Shield (Shield Slam, Shield Block)
**Recommended Slots:**
- Main Hand: 1H Sword/Axe/Mace (fast speed for more Heroic Strikes)
- Off Hand: Shield (high armor, block value, stamina)
- Ranged: Bow/Gun/Crossbow/Thrown (pulling)

---

### PALADIN

**Armor:** Plate (can wear Mail, Leather, Cloth but should prioritize Plate)

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Trainer |
| 2H Swords | Yes | Trainer |
| 1H Axes | Yes | Trainer |
| 2H Axes | Yes | Trainer |
| 1H Maces | Yes | Default |
| 2H Maces | Yes | Default |
| Polearms | Yes | Trainer |
| Shields | Yes | Default |
| Librams | Yes | Relic slot (TBC) |

**CANNOT Use:** Daggers, Fist Weapons, Staves, Ranged Weapons (Bows/Guns/Crossbows/Thrown)

#### Holy (Tab 1)
**Preferred Weapons:** 1H Mace/Sword + Shield, or 2H Mace for more spell power
**Weapon Style:** Caster weapon with +Healing/Spell Power + Shield for survivability
**Recommended Slots:**
- Main Hand: 1H Mace/Sword with +Healing or Intellect
- Off Hand: Shield with Intellect/Stamina OR Off-hand Frill with +Healing
- Relic: Libram with +Healing effects

#### Protection (Tab 2)
**Preferred Weapons:** 1H Sword/Mace/Axe + Shield
**Weapon Style:** Fast 1H weapon + Shield (more Holy Shield procs)
**Note:** Spell Power is valuable for threat (Consecration, Holy Shield)
**Recommended Slots:**
- Main Hand: 1H Sword/Mace/Axe (fast speed, spell power bonus)
- Off Hand: Shield (high armor, block value, stamina, spell power)
- Relic: Libram with tanking effects

#### Retribution (Tab 3)
**Preferred Weapons:** 2H Swords, 2H Axes, 2H Maces, Polearms
**Weapon Style:** Slow 2H weapon (Crusader Strike, Seal of Command proc)
**Note:** Slowest possible weapon speed is best (3.5-3.8 speed ideal)
**Recommended Slots:**
- Main Hand: 2H Sword/Axe/Mace/Polearm (SLOW speed critical)
- Relic: Libram with damage/seal effects

---

### HUNTER

**Armor:** Mail (at level 40+), can wear Leather

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Trainer |
| 2H Swords | Yes | Trainer |
| 1H Axes | Yes | Default |
| 2H Axes | Yes | Trainer |
| Daggers | Yes | Trainer |
| Fist Weapons | Yes | Trainer |
| Polearms | Yes | Trainer |
| Staves | Yes | Trainer |
| Bows | Yes | Default |
| Crossbows | Yes | Trainer |
| Guns | Yes | Trainer |
| Thrown | Yes | Trainer |

**CANNOT Use:** Maces (1H or 2H), Shields, Wands

#### Beast Mastery (Tab 1)
**Preferred Ranged:** Bows, Crossbows, Guns (Agility/AP/Crit)
**Preferred Melee:** 2H Axe, Polearm, Staff (stat sticks - rarely used in combat)
**Weapon Style:** Ranged primary, melee is stat stick only
**Recommended Slots:**
- Ranged: Bow/Gun/Crossbow (PRIMARY - this is your main weapon)
- Main Hand: 2H Axe/Polearm/Staff OR dual-wield 1H for stats
- Ammo: Arrows (Bow/Crossbow) or Bullets (Gun)

#### Marksmanship (Tab 2)
**Preferred Ranged:** Bows, Crossbows, Guns (Agility/AP/Crit)
**Preferred Melee:** 2H Axe, Polearm, Staff (stat sticks)
**Weapon Style:** Ranged primary, melee is stat stick only
**Recommended Slots:**
- Ranged: Bow/Gun/Crossbow (PRIMARY)
- Main Hand: 2H Axe/Polearm/Staff OR dual-wield 1H for stats

#### Survival (Tab 3)
**Preferred Ranged:** Bows, Crossbows, Guns (Agility/AP/Crit)
**Preferred Melee:** 2H Axe, Polearm, Staff (stat sticks)
**Weapon Style:** Ranged primary, melee is stat stick only
**Note:** Survival has some melee talents but still primarily ranged
**Recommended Slots:**
- Ranged: Bow/Gun/Crossbow (PRIMARY)
- Main Hand: 2H Axe/Polearm/Staff OR dual-wield 1H for stats

---

### ROGUE

**Armor:** Leather (can wear Cloth but should always use Leather)

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Trainer |
| 1H Maces | Yes | Trainer |
| Daggers | Yes | Default |
| Fist Weapons | Yes | Trainer |
| Bows | Yes | Trainer |
| Crossbows | Yes | Trainer |
| Guns | Yes | Trainer |
| Thrown | Yes | Default |

**CANNOT Use:** 2H Weapons (any), Axes, Polearms, Staves, Shields, Wands

#### Assassination (Tab 1)
**Preferred Weapons:** Daggers (both hands)
**Weapon Style:** Dual-wield Daggers (Mutilate, Backstab require daggers)
**Note:** MUST use daggers for core abilities
**Recommended Slots:**
- Main Hand: Dagger (slow speed preferred, 1.8+)
- Off Hand: Dagger (fast speed preferred, 1.3-1.5)
- Ranged: Thrown/Bow/Gun/Crossbow (pulling, stat stick)

#### Combat (Tab 2)
**Preferred Weapons:** 1H Swords, 1H Maces, Fist Weapons (main hand), Dagger or fast weapon (off hand)
**Weapon Style:** Dual-wield with Sword Specialization or Mace Specialization
**Note:** Combat Potency procs from off-hand, so fast OH is preferred
**Recommended Slots:**
- Main Hand: 1H Sword/Mace/Fist (slow speed, 2.4-2.8)
- Off Hand: Dagger or fast 1H (fast speed, 1.3-1.5)
- Ranged: Thrown/Bow/Gun/Crossbow

#### Subtlety (Tab 3)
**Preferred Weapons:** Daggers (both hands) for Backstab/Ambush
**Weapon Style:** Dual-wield Daggers
**Note:** Can use swords but daggers preferred for Backstab/Ambush
**Recommended Slots:**
- Main Hand: Dagger (slow speed)
- Off Hand: Dagger (fast speed)
- Ranged: Thrown/Bow/Gun/Crossbow

---

### PRIEST

**Armor:** Cloth ONLY

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Maces | Yes | Default |
| Daggers | Yes | Trainer |
| Staves | Yes | Trainer |
| Wands | Yes | Default |

**CANNOT Use:** Swords, Axes, Fist Weapons, Polearms, Shields, Any Ranged (except Wand)

#### Discipline (Tab 1)
**Preferred Weapons:** 1H Mace + Off-hand OR Staff
**Weapon Style:** +Healing/Intellect caster weapons
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with +Healing/Intellect
- Off Hand: Held In Off-hand (orb, book, etc.) with +Healing/Intellect
- OR Two-Hand: Staff with +Healing/Intellect
- Ranged: Wand (for damage when not healing)

#### Holy (Tab 2)
**Preferred Weapons:** 1H Mace + Off-hand OR Staff
**Weapon Style:** +Healing/Intellect caster weapons
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with +Healing/Intellect
- Off Hand: Held In Off-hand with +Healing/Intellect
- OR Two-Hand: Staff with +Healing/Intellect
- Ranged: Wand

#### Shadow (Tab 3)
**Preferred Weapons:** 1H Mace/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Intellect caster weapons (NOT +Healing)
**Note:** Shadow needs Spell DAMAGE, not +Healing
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Shadow damage wands preferred)

---

### SHAMAN

**Armor:** Mail (at level 40+), can wear Leather

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Axes | Yes | Trainer |
| 2H Axes | Yes | Trainer |
| 1H Maces | Yes | Default |
| 2H Maces | Yes | Trainer |
| Daggers | Yes | Trainer |
| Fist Weapons | Yes | Trainer |
| Staves | Yes | Default |
| Shields | Yes | Default |
| Totems | Yes | Relic slot (TBC) |

**CANNOT Use:** Swords (1H or 2H), Polearms, Bows, Crossbows, Guns, Thrown, Wands

**SPECIAL:** Enhancement learns Dual Wield at level 40 (talent)

#### Elemental (Tab 1)
**Preferred Weapons:** 1H Mace/Dagger + Shield OR Staff
**Weapon Style:** Spell Damage caster weapons + Shield for survivability
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with Spell Damage
- Off Hand: Shield with Intellect/Stamina
- OR Two-Hand: Staff with Spell Damage
- Relic: Totem with spell damage/crit effects

#### Enhancement (Tab 2)
**Preferred Weapons:** DUAL-WIELD 1H Axes, 1H Maces, Fist Weapons
**Weapon Style:** Dual-wield slow weapons (Windfury procs)
**Note:** MUST dual-wield for optimal DPS - talent unlocks at 40
**CRITICAL:** Slow main hand (2.6+), slow off-hand (2.4+) for Windfury
**Recommended Slots:**
- Main Hand: 1H Axe/Mace/Fist (SLOW speed 2.6-2.8)
- Off Hand: 1H Axe/Mace/Fist (SLOW speed 2.4-2.6)
- Relic: Totem with melee/Windfury effects

#### Restoration (Tab 3)
**Preferred Weapons:** 1H Mace + Shield OR Staff
**Weapon Style:** +Healing caster weapons + Shield
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with +Healing
- Off Hand: Shield with Intellect/MP5
- OR Two-Hand: Staff with +Healing
- Relic: Totem with healing effects

---

### MAGE

**Armor:** Cloth ONLY

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Trainer |
| Daggers | Yes | Trainer |
| Staves | Yes | Default |
| Wands | Yes | Default |

**CANNOT Use:** Maces, Axes, Fist Weapons, Polearms, 2H Swords, Shields, Any other Ranged

#### Arcane (Tab 1)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Intellect caster weapons
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage/Intellect
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Arcane damage preferred)

#### Fire (Tab 2)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Intellect/Crit caster weapons
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Fire damage preferred)

#### Frost (Tab 3)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Intellect caster weapons
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Frost damage preferred)

---

### WARLOCK

**Armor:** Cloth ONLY

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Swords | Yes | Trainer |
| Daggers | Yes | Default |
| Staves | Yes | Trainer |
| Wands | Yes | Default |

**CANNOT Use:** Maces, Axes, Fist Weapons, Polearms, 2H Swords, Shields, Any other Ranged

#### Affliction (Tab 1)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage caster weapons
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Shadow damage preferred)

#### Demonology (Tab 2)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage + Stamina caster weapons (pet scaling)
**Note:** Stamina is more valuable for Demo (Demonic Knowledge)
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage/Stamina
- Off Hand: Held In Off-hand with Spell Damage/Stamina
- OR Two-Hand: Staff with Spell Damage/Stamina
- Ranged: Wand

#### Destruction (Tab 3)
**Preferred Weapons:** 1H Sword/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Crit caster weapons
**Recommended Slots:**
- Main Hand: 1H Sword or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage
- Ranged: Wand (Fire/Shadow damage)

---

### DRUID

**Armor:** Leather (can wear Cloth but should always use Leather)

**Weapons Trainable:**
| Weapon Type | Trainable | Notes |
|-------------|-----------|-------|
| 1H Maces | Yes | Default |
| 2H Maces | Yes | Trainer |
| Daggers | Yes | Trainer |
| Fist Weapons | Yes | Trainer |
| Staves | Yes | Default |
| Idols | Yes | Relic slot (TBC) |

**CANNOT Use:** Swords, Axes, Polearms, Shields, Bows, Crossbows, Guns, Thrown, Wands

**SPECIAL:** In Cat/Bear form, weapon DPS does NOT matter - only stats count!

#### Balance (Tab 1)
**Preferred Weapons:** 1H Mace/Dagger + Off-hand OR Staff
**Weapon Style:** Spell Damage/Intellect caster weapons
**Note:** Leather caster gear is rare - may use cloth for some slots
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with Spell Damage
- Off Hand: Held In Off-hand with Spell Damage
- OR Two-Hand: Staff with Spell Damage (most common)
- Relic: Idol with Balance effects

#### Feral Combat (Tab 2)
**Preferred Weapons:** Staff, 2H Mace, or 1H + Off-hand with Agility/AP/Stamina
**Weapon Style:** STATS ONLY - weapon DPS is ignored in forms
**CRITICAL:** Feral Attack Power bonus on some items (look for "Increases attack power by X in Cat, Bear, Dire Bear, and Moonkin forms only")
**Note:** Cannot use Polearms, Swords, or Axes!
**Recommended Slots:**
- Two-Hand: Staff or 2H Mace with Agility/AP/Stamina/Feral AP
- OR Main Hand: 1H Mace/Dagger/Fist + Off-hand with Agility/Stamina
- Relic: Idol with Feral effects (Mangle, Shred, Rip, etc.)

#### Restoration (Tab 3)
**Preferred Weapons:** 1H Mace/Dagger + Off-hand OR Staff
**Weapon Style:** +Healing/Intellect caster weapons
**Recommended Slots:**
- Main Hand: 1H Mace or Dagger with +Healing
- Off Hand: Held In Off-hand with +Healing/Intellect
- OR Two-Hand: Staff with +Healing
- Relic: Idol with healing effects

---

---

## SPEC-FIRST AGENT RESEARCH CARDS

**THIS IS THE PRIMARY REFERENCE FOR AGENTS.**
Each card contains EVERYTHING an agent needs to research gear for ONE spec across ALL level ranges.

---

### WARRIOR - ARMS (Tab 1)

**Agent ID:** WARRIOR_ARMS

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate (required) |
| Weapon Style | Two-Handed |
| Weapon Types | 2H Sword, 2H Axe, 2H Mace, Polearm |
| Weapon Speed | SLOW (3.3-3.8) - Mortal Strike scales with weapon damage |
| Ranged Slot | Bow, Gun, Crossbow, Thrown (stat stick) |

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Strength, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Stamina |
| Avoid | Intellect, Spirit, Spell Power, Defense |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** Plate chest/legs/helm with Str/AP, slow 2H weapon

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Plate upgrades, better 2H weapon, neck/back with AP

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** Pre-raid BiS plate, epic 2H weapons

---

### WARRIOR - FURY (Tab 2)

**Agent ID:** WARRIOR_FURY

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate (required) |
| Weapon Style | Dual-Wield |
| Main Hand | 1H Sword, 1H Axe, 1H Mace, Fist Weapon (SLOW 2.5-2.8) |
| Off Hand | 1H Sword, 1H Axe, 1H Mace, Fist Weapon (FAST 1.5-1.8) |
| Ranged Slot | Bow, Gun, Crossbow, Thrown (stat stick) |

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Strength, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Haste, Stamina |
| Avoid | Intellect, Spirit, Spell Power, Defense |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** TWO 1H weapons (slow MH, fast OH), plate with Str

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Upgraded dual-wield weapons, plate chest/legs

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** Best 1H weapon pair, pre-raid plate

---

### WARRIOR - PROTECTION (Tab 3)

**Agent ID:** WARRIOR_PROT

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate (required - NO exceptions for tanks) |
| Weapon Style | One-Hand + Shield |
| Main Hand | 1H Sword, 1H Axe, 1H Mace (FAST 1.5-1.8 for more Heroic Strikes) |
| Off Hand | Shield (high armor, block value, stamina) |
| Ranged Slot | Bow, Gun, Crossbow, Thrown (for pulling) |

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Stamina, Defense Rating |
| Secondary | Block Value, Block Rating, Parry Rating |
| Tertiary | Dodge Rating, Strength |
| Avoid | Intellect, Spirit, Spell Power, Attack Power (some ok) |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** High stamina plate, shield with block, defense gear

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Better shield, defense cap gear, stamina stacking

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** Pre-raid tank set, 490 defense goal

---

### PALADIN - HOLY (Tab 1)

**Agent ID:** PALADIN_HOLY

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate preferred, Mail/Cloth acceptable for +Healing |
| Weapon Style | 1H + Shield OR 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, 1H Sword (with +Healing/Intellect) |
| Off Hand | Shield OR Held In Off-hand (with +Healing) |
| Relic | Libram with healing effects |

**CANNOT USE:** Daggers, Fist Weapons, Staves, Ranged Weapons

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | +Healing, Intellect |
| Secondary | MP5, Spirit |
| Tertiary | Stamina, Spell Critical |
| Avoid | Strength, Attack Power, Agility, Defense |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** +Healing gear (any armor type ok), mana regen

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Higher +Healing pieces, MP5 gear, Libram

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Sha'tar (Honored)
- **Look For:** Pre-raid healing set, +Healing weapon

---

### PALADIN - PROTECTION (Tab 2)

**Agent ID:** PALADIN_PROT

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate (required - NO exceptions for tanks) |
| Weapon Style | One-Hand + Shield |
| Main Hand | 1H Sword, 1H Mace, 1H Axe (FAST for Holy Shield procs) |
| Off Hand | Shield (stamina, block, SPELL POWER for threat) |
| Relic | Libram with tanking effects |

**CANNOT USE:** Daggers, Fist Weapons, Staves, Ranged Weapons
**SPECIAL:** Spell Power is VALUABLE for Paladin tanks (Consecration, Holy Shield threat)

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Stamina, Defense Rating |
| Secondary | Spell Power (for threat!), Block Value/Rating |
| Tertiary | Intellect (for mana), Strength |
| Avoid | Attack Power, Agility, Spirit |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** Stamina plate, spell power where possible, shield

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Defense gear, spell power + stamina pieces

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** Pre-raid tank set, spell damage shield

---

### PALADIN - RETRIBUTION (Tab 3)

**Agent ID:** PALADIN_RET

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Plate (required) |
| Weapon Style | Two-Handed |
| Weapon Types | 2H Sword, 2H Axe, 2H Mace, Polearm |
| Weapon Speed | VERY SLOW (3.5-3.8) - Seal of Command procs! |
| Relic | Libram with damage/seal effects |

**CANNOT USE:** Daggers, Fist Weapons, Staves, Ranged Weapons
**CRITICAL:** Slowest possible weapon is BEST. 3.8 speed >> 3.0 speed

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Strength, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Spell Power (for seals), Stamina |
| Avoid | Intellect, Spirit, Defense, +Healing |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** SLOW 2H weapon (3.5+ speed), Str plate

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Slower 2H weapon, plate with Str/Crit

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** 3.6-3.8 speed 2H weapon, pre-raid plate

---

### HUNTER - BEAST MASTERY (Tab 1)

**Agent ID:** HUNTER_BM

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable if better stats |
| Weapon Style | Ranged PRIMARY, Melee is stat stick |
| Ranged Weapon | Bow, Gun, Crossbow (this is your MAIN weapon!) |
| Melee Weapon | 2H Axe, Polearm, Staff, OR dual-wield 1H (stats only) |
| Ammo | Arrows (Bow/Crossbow) or Bullets (Gun) |

**CANNOT USE:** Maces (1H or 2H), Shields, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Intellect (for mana), Stamina |
| Avoid | Strength (minimal value), Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Reputation:** Honor Hold / Thrallmar (Honored)
- **Look For:** RANGED WEAPON first, then Agi mail/leather

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Reputation:** Cenarion Expedition (Honored)
- **Look For:** Better ranged weapon, mail with Agi/AP

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Reputation:** Lower City, Keepers of Time (Honored)
- **Look For:** Pre-raid ranged weapon, Agi accessories

---

### HUNTER - MARKSMANSHIP (Tab 2)

**Agent ID:** HUNTER_MM

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable |
| Weapon Style | Ranged PRIMARY |
| Ranged Weapon | Bow, Gun, Crossbow |
| Melee Weapon | 2H Axe, Polearm, Staff (stat stick) |

**CANNOT USE:** Maces, Shields, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Intellect, Stamina |
| Avoid | Strength, Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Ranged weapon with high DPS, Agi gear

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Better ranged weapon, hit rating gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid ranged weapon, crit gear

---

### HUNTER - SURVIVAL (Tab 3)

**Agent ID:** HUNTER_SURV

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable |
| Weapon Style | Ranged PRIMARY |
| Ranged Weapon | Bow, Gun, Crossbow |
| Melee Weapon | 2H Axe, Polearm, Staff (stat stick) |

**CANNOT USE:** Maces, Shields, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Stamina (survival focus) |
| Avoid | Strength, Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Ranged weapon, Agi mail with Stamina

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Better ranged weapon, balanced stats

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid setup, Expose Weakness synergy (Agi)

---

### ROGUE - ASSASSINATION (Tab 1)

**Agent ID:** ROGUE_ASSN

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (required) |
| Weapon Style | Dual-Wield DAGGERS ONLY |
| Main Hand | Dagger (SLOW 1.7-1.8 for Mutilate/Backstab damage) |
| Off Hand | Dagger (FAST 1.3-1.5 for poison procs) |
| Ranged | Thrown, Bow, Gun, Crossbow |

**CANNOT USE:** 2H weapons, Axes, Swords (for main abilities), Maces
**CRITICAL:** MUST use daggers - Mutilate and Backstab REQUIRE daggers

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Haste Rating |
| Avoid | Strength, Intellect, Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** TWO daggers (slow MH, fast OH), Agi leather

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Better dagger pair, hit rating gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid daggers, leather with Agi/AP/Crit

---

### ROGUE - COMBAT (Tab 2)

**Agent ID:** ROGUE_COMBAT

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (required) |
| Weapon Style | Dual-Wield (Sword or Mace MH preferred) |
| Main Hand | 1H Sword, 1H Mace, Fist Weapon (SLOW 2.4-2.8) |
| Off Hand | Dagger or fast 1H (FAST 1.3-1.5 for Combat Potency) |
| Ranged | Thrown, Bow, Gun, Crossbow |

**CANNOT USE:** 2H weapons, Axes
**NOTE:** Sword Specialization or Mace Specialization talents determine best MH

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Hit Rating, Critical Strike Rating |
| Tertiary | Expertise, Haste |
| Avoid | Strength, Intellect, Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Slow 1H sword/mace MH, fast OH, Agi leather

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Better weapon pair, hit cap gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid weapons, expertise gear

---

### ROGUE - SUBTLETY (Tab 3)

**Agent ID:** ROGUE_SUB

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (required) |
| Weapon Style | Dual-Wield DAGGERS |
| Main Hand | Dagger (slow for Backstab/Ambush) |
| Off Hand | Dagger (fast for procs) |
| Ranged | Thrown, Bow, Gun, Crossbow |

**CANNOT USE:** 2H weapons, Axes
**NOTE:** Daggers preferred for Backstab/Ambush, but can use swords

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Haste |
| Avoid | Strength, Intellect, Spirit, Spell Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Dagger pair, Agi leather

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Better daggers, crit gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid daggers, stealth-enhancing gear

---

### PRIEST - DISCIPLINE (Tab 1)

**Agent ID:** PRIEST_DISC

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, Dagger (with +Healing) |
| Off Hand | Held In Off-hand (orb, book) with +Healing |
| Ranged | Wand |

**CANNOT USE:** Swords, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | +Healing, Intellect |
| Secondary | Spirit, MP5 |
| Tertiary | Stamina |
| Avoid | Strength, Agility, Attack Power, Spell Damage (some ok) |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** +Healing cloth, mana regen pieces

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher +Healing, spirit gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid healing set

---

### PRIEST - HOLY (Tab 2)

**Agent ID:** PRIEST_HOLY

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, Dagger (with +Healing) |
| Off Hand | Held In Off-hand with +Healing |
| Ranged | Wand |

**CANNOT USE:** Swords, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | +Healing, Intellect |
| Secondary | Spirit, MP5 |
| Tertiary | Spell Critical |
| Avoid | Strength, Agility, Attack Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** +Healing cloth, spirit pieces

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher +Healing, crit where available

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid healing set

---

### PRIEST - SHADOW (Tab 3)

**Agent ID:** PRIEST_SHADOW

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, Dagger (with SPELL DAMAGE, not +Healing) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand (Shadow damage preferred) |

**CANNOT USE:** Swords, Axes, Fist Weapons, Shields
**CRITICAL:** Shadow needs SPELL DAMAGE, not +Healing!

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Spirit (for mana regen), Stamina |
| Avoid | +Healing only, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** SPELL DAMAGE cloth (not healing), shadow wand

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit rating

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid shadow set, crit gear

---

### SHAMAN - ELEMENTAL (Tab 1)

**Agent ID:** SHAMAN_ELE

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable for spell power |
| Weapon Style | 1H + Shield OR Staff |
| Main Hand | 1H Mace, Dagger (with Spell Damage) |
| Off Hand | Shield (Intellect/Stamina) for survivability |
| Relic | Totem with spell damage/crit effects |

**CANNOT USE:** Swords, Polearms, Bows, Guns, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | MP5, Stamina |
| Avoid | +Healing only, Strength, Agility, Attack Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage mail/leather, caster shield

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit cap gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid elemental set, totem relic

---

### SHAMAN - ENHANCEMENT (Tab 2)

**Agent ID:** SHAMAN_ENH

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable for AP/Agi |
| Weapon Style | DUAL-WIELD (unlocked at level 40 talent) |
| Main Hand | 1H Axe, 1H Mace, Fist Weapon (SLOW 2.6-2.8 for Windfury!) |
| Off Hand | 1H Axe, 1H Mace, Fist Weapon (SLOW 2.4-2.6 for Windfury!) |
| Relic | Totem with melee/Windfury effects |

**CANNOT USE:** Swords, Polearms, Bows, Guns, Wands
**CRITICAL:** BOTH weapons must be SLOW for Windfury procs! Fast weapons = bad!

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power, Strength |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Intellect (for shocks) |
| Avoid | Spell Damage, +Healing, Defense, Spirit |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** TWO SLOW 1H weapons (2.6+ speed each!), Agi mail

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Slower weapon upgrades, AP mail/leather

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Best slow 1H pair, pre-raid melee set

---

### SHAMAN - RESTORATION (Tab 3)

**Agent ID:** SHAMAN_RESTO

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Mail (preferred), Leather acceptable for +Healing |
| Weapon Style | 1H + Shield OR Staff |
| Main Hand | 1H Mace, Dagger (with +Healing) |
| Off Hand | Shield (Intellect/MP5) |
| Relic | Totem with healing effects |

**CANNOT USE:** Swords, Polearms, Bows, Guns, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | +Healing, Intellect |
| Secondary | MP5, Spirit |
| Tertiary | Spell Critical |
| Avoid | Spell Damage, Strength, Agility, Attack Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** +Healing mail/leather, mana regen

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher +Healing, MP5 gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid healing set, totem relic

---

### MAGE - ARCANE (Tab 1)

**Agent ID:** MAGE_ARCANE

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage/Intellect |
| Ranged | Wand (Arcane damage preferred) |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Spirit (for Arcane Meditation), Stamina |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage cloth, Intellect stacking

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, crit rating

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid caster set

---

### MAGE - FIRE (Tab 2)

**Agent ID:** MAGE_FIRE

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand (Fire damage preferred) |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating (Ignite!), Hit Rating |
| Tertiary | Stamina |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage cloth, crit rating (for Ignite)

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** More crit, spell damage

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid fire set, crit stacking

---

### MAGE - FROST (Tab 3)

**Agent ID:** MAGE_FROST

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand (Frost damage preferred) |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Stamina |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage cloth, intellect

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit cap

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid frost set

---

### WARLOCK - AFFLICTION (Tab 1)

**Agent ID:** WARLOCK_AFF

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand (Shadow damage preferred) |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Spirit (for Life Tap), Stamina |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage cloth, shadow wand

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit rating

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid affliction set

---

### WARLOCK - DEMONOLOGY (Tab 2)

**Agent ID:** WARLOCK_DEMO

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage + Stamina) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields
**SPECIAL:** Stamina is MORE valuable for Demo (Demonic Knowledge talent)

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Stamina (pet scaling!) |
| Secondary | Intellect, Hit Rating |
| Tertiary | Spirit |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage + stamina cloth

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Balanced spell damage/stamina

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid demo set, stamina stacking

---

### WARLOCK - DESTRUCTION (Tab 3)

**Agent ID:** WARLOCK_DESTRO

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Cloth ONLY |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Sword, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage |
| Ranged | Wand (Fire or Shadow damage) |

**CANNOT USE:** Maces, Axes, Fist Weapons, Shields

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Stamina |
| Avoid | +Healing, Strength, Agility |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage cloth, crit rating

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit cap

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid destro set, crit stacking

---

### DRUID - BALANCE (Tab 1)

**Agent ID:** DRUID_BALANCE

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (required), Cloth acceptable for big spell power upgrades |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, Dagger (with Spell Damage) |
| Off Hand | Held In Off-hand with Spell Damage |
| Relic | Idol with Balance effects |

**CANNOT USE:** Swords, Axes, Polearms, Shields, Bows, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Spell Damage, Intellect |
| Secondary | Critical Strike Rating, Hit Rating |
| Tertiary | Spirit |
| Avoid | +Healing only, Strength, Agility, Attack Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Spell damage leather (rare) or cloth, caster staff

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher spell damage, hit rating

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid balance set, idol

---

### DRUID - FERAL COMBAT (Tab 2)

**Agent ID:** DRUID_FERAL

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (REQUIRED - never cloth for feral) |
| Weapon Style | Staff OR 2H Mace OR 1H + Off-hand |
| Weapon Types | Staff, 2H Mace, 1H Mace, Dagger, Fist Weapon |
| Relic | Idol with Feral effects (Mangle, Shred, Rip) |

**CANNOT USE:** Swords, Axes, Polearms, Shields, Bows, Wands
**CRITICAL:** Weapon DPS is IGNORED in Cat/Bear form - ONLY STATS MATTER!
**SPECIAL:** Look for "Feral Attack Power" items - HUGE value!

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | Agility, Attack Power, Feral Attack Power |
| Secondary | Strength, Critical Strike Rating |
| Tertiary | Hit Rating, Stamina |
| Avoid | Intellect, Spirit, Spell Damage, +Healing |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** Agi leather, Feral AP items, staff with Agi/Str

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher Agi leather, Feral AP gear

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid feral set, Feral idol, Strength of the Clefthoof

---

### DRUID - RESTORATION (Tab 3)

**Agent ID:** DRUID_RESTO

#### Core Requirements
| Attribute | Value |
|-----------|-------|
| Armor Type | Leather (preferred), Cloth acceptable for +Healing |
| Weapon Style | 1H + Off-hand OR Staff |
| Main Hand | 1H Mace, Dagger (with +Healing) |
| Off Hand | Held In Off-hand with +Healing |
| Relic | Idol with healing effects |

**CANNOT USE:** Swords, Axes, Polearms, Shields, Bows, Wands

#### Stat Priority
| Priority | Stats |
|----------|-------|
| Primary | +Healing, Intellect |
| Secondary | Spirit, MP5 |
| Tertiary | Spell Critical |
| Avoid | Spell Damage, Strength, Agility, Attack Power |

#### Level 60-62 Search Parameters
- **Dungeons:** Hellfire Ramparts, Blood Furnace
- **Quests:** Hellfire Peninsula
- **Look For:** +Healing leather/cloth, spirit gear

#### Level 63-65 Search Parameters
- **Dungeons:** Slave Pens, Underbog, Mana-Tombs
- **Quests:** Zangarmarsh, Terokkar Forest
- **Look For:** Higher +Healing, MP5

#### Level 66-67 Search Parameters
- **Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad
- **Quests:** Terokkar, Nagrand, Blade's Edge
- **Look For:** Pre-raid resto set, healing idol

---

## SLOT COVERAGE GUIDELINES

To ensure diverse recommendations, agents should try to cover different gear slots:

### Armor Slots (8 total)
| Slot | Priority for Leveling |
|------|----------------------|
| Head | High - large stat budget |
| Shoulders | Medium - unlock at level 40 quest |
| Chest | High - large stat budget |
| Wrist | Low - small stat budget |
| Hands | Medium |
| Waist | Medium |
| Legs | High - large stat budget |
| Feet | Medium |

### Accessory Slots (5 total)
| Slot | Priority for Leveling |
|------|----------------------|
| Neck | Medium - often overlooked |
| Back | Medium - cloaks from quests |
| Ring x2 | Low - fewer leveling options |
| Trinket x2 | Low - fewer leveling options |

### Weapon Slots (varies by class)
| Slot | Notes |
|------|-------|
| Main Hand | Always prioritize |
| Off Hand | Shields, held items, or dual-wield |
| Two-Hand | Alternative to MH+OH |
| Ranged/Relic | Class-specific |

### Recommended Distribution per Spec (6 items)
- **2-3 Armor pieces** (prioritize Head, Chest, Legs)
- **1-2 Weapons** (main hand + off-hand or 2H)
- **1-2 Accessories** (Neck, Back, or Rings)

---

## WEAPON SPEED REQUIREMENTS

Weapon speed is CRITICAL for many specs. Agents must pay attention to this.

### Specs That Need SLOW Weapons (2.4+ speed)

| Class/Spec | Reason | Ideal Speed |
|------------|--------|-------------|
| **Warrior Arms** | Mortal Strike damage based on weapon damage | 3.3-3.8 (2H) |
| **Warrior Fury (MH)** | Bloodthirst, Whirlwind damage | 2.5-2.8 (1H) |
| **Paladin Retribution** | Seal of Command procs, Crusader Strike | 3.5-3.8 (2H) |
| **Rogue Assassination (MH)** | Mutilate/Backstab damage | 1.7-1.8 (Dagger) |
| **Rogue Combat (MH)** | Sinister Strike damage | 2.4-2.8 (1H) |
| **Shaman Enhancement (BOTH)** | Windfury procs - BOTH weapons slow | 2.6+ (MH), 2.4+ (OH) |

### Specs That Need FAST Weapons (1.3-1.8 speed)

| Class/Spec | Reason | Ideal Speed |
|------------|--------|-------------|
| **Warrior Fury (OH)** | More Whirlwind hits, rage generation | 1.5-1.8 (1H) |
| **Warrior Protection** | More Heroic Strike opportunities | 1.5-1.8 (1H) |
| **Rogue (OH - all specs)** | Combat Potency procs, poison applications | 1.3-1.5 |

### Specs Where Speed DOESN'T Matter

| Class/Spec | Reason |
|------------|--------|
| **Druid Feral** | Weapon DPS ignored in forms - STATS ONLY |
| **Hunter (melee)** | Melee is stat stick only, ranged is primary |
| **All Casters** | Weapon is stat stick, no auto-attacks |

---

## SPECIAL ITEM TYPES

### Feral Attack Power Items
Some items have "Increases attack power by X in Cat, Bear, Dire Bear, and Moonkin forms only."
This stat is EXTREMELY valuable for Feral Druids - prioritize these items!

Examples:
- Strength of the Clefthoof (Nagrand quest reward)
- Manimal's Cinch (Lower City Honored)
- Various dungeon drops

### Spell Damage vs +Healing
**+Healing** only affects healing spells
**Spell Damage** affects damage spells AND healing (at reduced rate in TBC)

| Spec | Wants |
|------|-------|
| Holy Paladin, Disc/Holy Priest, Resto Shaman/Druid | +Healing |
| Shadow Priest, Elemental Shaman, Balance Druid, Mage, Warlock | Spell Damage |
| Protection Paladin | Spell Damage (for threat) |

### Expertise (TBC Stat)
Reduces chance for attacks to be dodged/parried. Valuable for:
- Rogue Combat (front attacks)
- Warrior Fury/Arms
- Enhancement Shaman
- Feral Druid

### Defense Rating
Only valuable for TANKS:
- Warrior Protection
- Paladin Protection
- Feral Druid (Bear form tanking)

### Block Value/Rating
Only valuable for SHIELD users:
- Warrior Protection
- Paladin Protection
- Shaman (minor for Elemental/Resto with shield)

---

## ARMOR TYPE EXCEPTIONS

### When to Wear Lower Armor Types

**Hunters** (Mail class):
- Can wear Leather if it has significantly better Agility/AP
- Mail with intellect but no agility is worse than leather with agility

**Shamans** (Mail class):
- Enhancement: Leather with good AP/Agi often beats mail
- Elemental/Resto: May use cloth if spell power is much higher

**Paladins** (Plate class):
- Holy: Mail/Leather with +Healing may be better than Plate
- Protection: Always plate for armor
- Retribution: Plate preferred, but leather with AP sometimes ok

**Warriors** (Plate class):
- Protection: Always plate
- Arms/Fury: Plate preferred, but leather with high AP sometimes ok

**Druids** (Leather class):
- Balance/Resto: Cloth caster pieces are common and acceptable
- Feral: ALWAYS leather - never cloth

---

## Dungeon Reference

### Level 60-62 Dungeons

| Dungeon | Level Range | Zone | Notable Bosses |
|---------|-------------|------|----------------|
| **Hellfire Ramparts** | 60-62 | Hellfire Peninsula | Watchkeeper Gargolmar, Omor the Unscarred, Vazruden & Nazan |
| **Blood Furnace** | 61-63 | Hellfire Peninsula | The Maker, Broggok, Keli'dan the Breaker |

### Level 63-65 Dungeons

| Dungeon | Level Range | Zone | Notable Bosses |
|---------|-------------|------|----------------|
| **Slave Pens** | 62-64 | Zangarmarsh | Mennu the Betrayer, Rokmar the Crackler, Quagmirran |
| **Underbog** | 63-65 | Zangarmarsh | Hungarfen, Ghaz'an, Swamplord Musel'ek, Black Stalker |
| **Mana-Tombs** | 64-66 | Terokkar Forest | Pandemonius, Tavarok, Nexus-Prince Shaffar |

### Level 66-67 Dungeons

| Dungeon | Level Range | Zone | Notable Bosses |
|---------|-------------|------|----------------|
| **Auchenai Crypts** | 65-67 | Terokkar Forest | Shirrak the Dead Watcher, Exarch Maladaar |
| **Sethekk Halls** | 67-69 | Terokkar Forest | Darkweaver Syth, Talon King Ikiss |
| **Old Hillsbrad Foothills** | 66-68 | Caverns of Time | Lieutenant Drake, Captain Skarloc, Epoch Hunter |

---

## Reputation Rewards Reference

### Hellfire Peninsula (60-62)

| Faction | Alliance | Horde |
|---------|----------|-------|
| Primary | Honor Hold | Thrallmar |
| Rewards | Honored, Revered gear | Same items (different names) |

### Zangarmarsh (63-65)

| Faction | Both |
|---------|------|
| Primary | Cenarion Expedition |
| Rewards | Honored, Revered gear |

### Terokkar Forest (63-67)

| Faction | Both |
|---------|------|
| Primary | Lower City |
| Also | Sha'tar (Shattrath) |
| Rewards | Honored, Revered gear |

---

## Quest Hub Reference

### Level 60-62 Quest Hubs

| Zone | Alliance Hubs | Horde Hubs | Neutral Hubs |
|------|--------------|------------|--------------|
| Hellfire Peninsula | Honor Hold, Temple of Telhamat | Thrallmar, Falcon Watch | Cenarion Post |

**Key Quest Chains:**
- Weaken the Ramparts (dungeon quest)
- Heart of Rage (Blood Furnace quest)
- Overlord (zone finale)
- Fel Orc Scavengers
- Drilling for Corruption

### Level 63-65 Quest Hubs

| Zone | Alliance Hubs | Horde Hubs | Neutral Hubs |
|------|--------------|------------|--------------|
| Zangarmarsh | Telredor, Orebor Harborage | Zabra'jin, Swamprat Post | Cenarion Refuge, Sporeggar |
| Terokkar (early) | Allerian Stronghold | Stonebreaker Hold | Shattrath City |

**Key Quest Chains:**
- Lost in Action (Zangarmarsh)
- Wanted: Bogstrok (Cenarion Refuge)
- Undercutting the Competition (Mana-Tombs)
- The Daggerfen (Zangarmarsh)

### Level 66-67 Quest Hubs

| Zone | Alliance Hubs | Horde Hubs | Neutral Hubs |
|------|--------------|------------|--------------|
| Terokkar (late) | Allerian Stronghold | Stonebreaker Hold | Shattrath, Auchindoun |
| Nagrand | Telaar | Garadar | Consortium |
| Blade's Edge | Sylvanaar | Thunderlord Stronghold | Evergrove |

**Key Quest Chains:**
- Brother Against Brother (Auchenai Crypts)
- Return to Andormu (Caverns of Time)
- Terokk's Legacy (Terokkar)
- Everything Will Be Alright (Sethekk Halls)

---

## Research Status Tracking

### Warrior

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Arms | [ ] | [ ] | [ ] | Not Started |
| Fury | [ ] | [ ] | [ ] | Not Started |
| Protection | [ ] | [ ] | [ ] | Not Started |

### Paladin

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Holy | [ ] | [ ] | [ ] | Not Started |
| Protection | [ ] | [ ] | [ ] | Not Started |
| Retribution | [ ] | [ ] | [ ] | Not Started |

### Hunter

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Beast Mastery | [ ] | [ ] | [ ] | Not Started |
| Marksmanship | [ ] | [ ] | [ ] | Not Started |
| Survival | [ ] | [ ] | [ ] | Not Started |

### Rogue

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Assassination | [ ] | [ ] | [ ] | Not Started |
| Combat | [ ] | [ ] | [ ] | Not Started |
| Subtlety | [ ] | [ ] | [ ] | Not Started |

### Priest

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Discipline | [ ] | [ ] | [ ] | Not Started |
| Holy | [ ] | [ ] | [ ] | Not Started |
| Shadow | [ ] | [ ] | [ ] | Not Started |

### Shaman

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Elemental | [ ] | [ ] | [ ] | Not Started |
| Enhancement | [ ] | [ ] | [ ] | Not Started |
| Restoration | [ ] | [ ] | [ ] | Not Started |

### Mage

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Arcane | [ ] | [ ] | [ ] | Not Started |
| Fire | [ ] | [ ] | [ ] | Not Started |
| Frost | [ ] | [ ] | [ ] | Not Started |

### Warlock

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Affliction | [ ] | [ ] | [ ] | Not Started |
| Demonology | [ ] | [ ] | [ ] | Not Started |
| Destruction | [ ] | [ ] | [ ] | Not Started |

### Druid

| Spec | 60-62 | 63-65 | 66-67 | Status |
|------|-------|-------|-------|--------|
| Balance | [ ] | [ ] | [ ] | Not Started |
| Feral Combat | [ ] | [ ] | [ ] | Not Started |
| Restoration | [ ] | [ ] | [ ] | Not Started |

---

## Agent Research Plan - Detailed Batches

To research all 108 spec/level combinations (27 specs × 4 level ranges = 108 tasks), we organize into manageable batches.

**Note:** 9 classes × 3 specs = 27 specs (not 30 - TBC has no Death Knights)

**Research Sources (Priority Order):**
1. **https://tbc.wowhead.com/** - Primary source for all item data
2. **https://www.wowhead.com/tbc/** - Alternate TBC database URL
3. **TBC Classic Database filters:**
   - Filter by source: Dungeon, Quest, Reputation
   - Filter by level requirement
   - Filter by armor type / weapon type
   - Sort by item level for quality comparisons

---

## MASTER BATCH SCHEDULE

### Leveling Batches (60-67)

| Batch | Level Range | Classes | Specs | Agent Count | Items/Agent |
|-------|-------------|---------|-------|-------------|-------------|
| **1A** | 60-62 | Warrior, Paladin, Hunter | 9 specs | 9 | 6 |
| **1B** | 60-62 | Rogue, Priest, Shaman | 9 specs | 9 | 6 |
| **1C** | 60-62 | Mage, Warlock, Druid | 9 specs | 9 | 6 |
| **2A** | 63-65 | Warrior, Paladin, Hunter | 9 specs | 9 | 6 |
| **2B** | 63-65 | Rogue, Priest, Shaman | 9 specs | 9 | 6 |
| **2C** | 63-65 | Mage, Warlock, Druid | 9 specs | 9 | 6 |
| **3A** | 66-67 | Warrior, Paladin, Hunter | 9 specs | 9 | 6 |
| **3B** | 66-67 | Rogue, Priest, Shaman | 9 specs | 9 | 6 |
| **3C** | 66-67 | Mage, Warlock, Druid | 9 specs | 9 | 6 |
| **Subtotal** | | | | **81 agents** | **486 items** |

### Pre-Heroic Batches (68-70) - NORMAL DUNGEONS ONLY

| Batch | Level Range | Classes | Specs | Agent Count | Items/Agent |
|-------|-------------|---------|-------|-------------|-------------|
| **4A** | 68-70 | Warrior, Paladin, Hunter | 9 specs | 9 | 9 |
| **4B** | 68-70 | Rogue, Priest, Shaman | 9 specs | 9 | 9 |
| **4C** | 68-70 | Mage, Warlock, Druid | 9 specs | 9 | 9 |
| **Subtotal** | | | | **27 agents** | **243 items** |

### GRAND TOTAL: 108 agents, 729 items

---

## BATCH 1A: Level 60-62 - Warrior, Paladin, Hunter (9 agents)

**Dungeons:** Hellfire Ramparts, Blood Furnace
**Zones:** Hellfire Peninsula
**Reputation:** Honor Hold / Thrallmar (Honored)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 1A-01 | Warrior | Arms | 1 | Plate | Strength, AP, Crit, Hit |
| 1A-02 | Warrior | Fury | 2 | Plate | Strength, AP, Crit, Hit (dual-wield) |
| 1A-03 | Warrior | Protection | 3 | Plate | Stamina, Defense, Block, Parry |
| 1A-04 | Paladin | Holy | 1 | Plate/Mail | +Healing, Intellect, MP5, Spirit |
| 1A-05 | Paladin | Protection | 2 | Plate | Stamina, Defense, Spell Power, Block |
| 1A-06 | Paladin | Retribution | 3 | Plate | Strength, AP, Crit, Hit, Spell Power |
| 1A-07 | Hunter | Beast Mastery | 1 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 1A-08 | Hunter | Marksmanship | 2 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 1A-09 | Hunter | Survival | 3 | Mail/Leather | Agility, AP, Crit, Hit, Stamina |

---

## BATCH 1B: Level 60-62 - Rogue, Priest, Shaman (9 agents)

**Dungeons:** Hellfire Ramparts, Blood Furnace
**Zones:** Hellfire Peninsula
**Reputation:** Honor Hold / Thrallmar (Honored)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 1B-01 | Rogue | Assassination | 1 | Leather | Agility, AP, Crit, Hit |
| 1B-02 | Rogue | Combat | 2 | Leather | Agility, AP, Hit, Crit, Expertise |
| 1B-03 | Rogue | Subtlety | 3 | Leather | Agility, AP, Crit, Hit |
| 1B-04 | Priest | Discipline | 1 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 1B-05 | Priest | Holy | 2 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 1B-06 | Priest | Shadow | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1B-07 | Shaman | Elemental | 1 | Mail/Leather | Spell Damage, Intellect, Crit, Hit |
| 1B-08 | Shaman | Enhancement | 2 | Mail/Leather | Agility, AP, Strength, Crit, Hit |
| 1B-09 | Shaman | Restoration | 3 | Mail/Leather | +Healing, Intellect, MP5, Spirit |

---

## BATCH 1C: Level 60-62 - Mage, Warlock, Druid (9 agents)

**Dungeons:** Hellfire Ramparts, Blood Furnace
**Zones:** Hellfire Peninsula
**Reputation:** Honor Hold / Thrallmar (Honored)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 1C-01 | Mage | Arcane | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1C-02 | Mage | Fire | 2 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1C-03 | Mage | Frost | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1C-04 | Warlock | Affliction | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1C-05 | Warlock | Demonology | 2 | Cloth | Spell Damage, Stamina, Intellect, Hit |
| 1C-06 | Warlock | Destruction | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 1C-07 | Druid | Balance | 1 | Leather | Spell Damage, Intellect, Crit, Hit |
| 1C-08 | Druid | Feral Combat | 2 | Leather | Agility, AP, Strength, Crit, Hit |
| 1C-09 | Druid | Restoration | 3 | Leather | +Healing, Intellect, Spirit, MP5 |

---

## BATCH 2A: Level 63-65 - Warrior, Paladin, Hunter (9 agents)

**Dungeons:** Slave Pens, Underbog, Mana-Tombs
**Zones:** Zangarmarsh, Terokkar Forest (early)
**Reputation:** Cenarion Expedition (Honored), Lower City (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 2A-01 | Warrior | Arms | 1 | Plate | Strength, AP, Crit, Hit |
| 2A-02 | Warrior | Fury | 2 | Plate | Strength, AP, Crit, Hit (dual-wield) |
| 2A-03 | Warrior | Protection | 3 | Plate | Stamina, Defense, Block, Parry |
| 2A-04 | Paladin | Holy | 1 | Plate/Mail | +Healing, Intellect, MP5, Spirit |
| 2A-05 | Paladin | Protection | 2 | Plate | Stamina, Defense, Spell Power, Block |
| 2A-06 | Paladin | Retribution | 3 | Plate | Strength, AP, Crit, Hit, Spell Power |
| 2A-07 | Hunter | Beast Mastery | 1 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 2A-08 | Hunter | Marksmanship | 2 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 2A-09 | Hunter | Survival | 3 | Mail/Leather | Agility, AP, Crit, Hit, Stamina |

---

## BATCH 2B: Level 63-65 - Rogue, Priest, Shaman (9 agents)

**Dungeons:** Slave Pens, Underbog, Mana-Tombs
**Zones:** Zangarmarsh, Terokkar Forest (early)
**Reputation:** Cenarion Expedition (Honored), Lower City (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 2B-01 | Rogue | Assassination | 1 | Leather | Agility, AP, Crit, Hit |
| 2B-02 | Rogue | Combat | 2 | Leather | Agility, AP, Hit, Crit, Expertise |
| 2B-03 | Rogue | Subtlety | 3 | Leather | Agility, AP, Crit, Hit |
| 2B-04 | Priest | Discipline | 1 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 2B-05 | Priest | Holy | 2 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 2B-06 | Priest | Shadow | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2B-07 | Shaman | Elemental | 1 | Mail/Leather | Spell Damage, Intellect, Crit, Hit |
| 2B-08 | Shaman | Enhancement | 2 | Mail/Leather | Agility, AP, Strength, Crit, Hit |
| 2B-09 | Shaman | Restoration | 3 | Mail/Leather | +Healing, Intellect, MP5, Spirit |

---

## BATCH 2C: Level 63-65 - Mage, Warlock, Druid (9 agents)

**Dungeons:** Slave Pens, Underbog, Mana-Tombs
**Zones:** Zangarmarsh, Terokkar Forest (early)
**Reputation:** Cenarion Expedition (Honored), Lower City (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 2C-01 | Mage | Arcane | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2C-02 | Mage | Fire | 2 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2C-03 | Mage | Frost | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2C-04 | Warlock | Affliction | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2C-05 | Warlock | Demonology | 2 | Cloth | Spell Damage, Stamina, Intellect, Hit |
| 2C-06 | Warlock | Destruction | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 2C-07 | Druid | Balance | 1 | Leather | Spell Damage, Intellect, Crit, Hit |
| 2C-08 | Druid | Feral Combat | 2 | Leather | Agility, AP, Strength, Crit, Hit |
| 2C-09 | Druid | Restoration | 3 | Leather | +Healing, Intellect, Spirit, MP5 |

---

## BATCH 3A: Level 66-67 - Warrior, Paladin, Hunter (9 agents)

**Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
**Zones:** Terokkar Forest (late), Nagrand, Blade's Edge Mountains
**Reputation:** Lower City (Honored), Sha'tar (Friendly), Keepers of Time (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 3A-01 | Warrior | Arms | 1 | Plate | Strength, AP, Crit, Hit |
| 3A-02 | Warrior | Fury | 2 | Plate | Strength, AP, Crit, Hit (dual-wield) |
| 3A-03 | Warrior | Protection | 3 | Plate | Stamina, Defense, Block, Parry |
| 3A-04 | Paladin | Holy | 1 | Plate/Mail | +Healing, Intellect, MP5, Spirit |
| 3A-05 | Paladin | Protection | 2 | Plate | Stamina, Defense, Spell Power, Block |
| 3A-06 | Paladin | Retribution | 3 | Plate | Strength, AP, Crit, Hit, Spell Power |
| 3A-07 | Hunter | Beast Mastery | 1 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 3A-08 | Hunter | Marksmanship | 2 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 3A-09 | Hunter | Survival | 3 | Mail/Leather | Agility, AP, Crit, Hit, Stamina |

---

## BATCH 3B: Level 66-67 - Rogue, Priest, Shaman (9 agents)

**Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
**Zones:** Terokkar Forest (late), Nagrand, Blade's Edge Mountains
**Reputation:** Lower City (Honored), Sha'tar (Friendly), Keepers of Time (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 3B-01 | Rogue | Assassination | 1 | Leather | Agility, AP, Crit, Hit |
| 3B-02 | Rogue | Combat | 2 | Leather | Agility, AP, Hit, Crit, Expertise |
| 3B-03 | Rogue | Subtlety | 3 | Leather | Agility, AP, Crit, Hit |
| 3B-04 | Priest | Discipline | 1 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 3B-05 | Priest | Holy | 2 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 3B-06 | Priest | Shadow | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3B-07 | Shaman | Elemental | 1 | Mail/Leather | Spell Damage, Intellect, Crit, Hit |
| 3B-08 | Shaman | Enhancement | 2 | Mail/Leather | Agility, AP, Strength, Crit, Hit |
| 3B-09 | Shaman | Restoration | 3 | Mail/Leather | +Healing, Intellect, MP5, Spirit |

---

## BATCH 3C: Level 66-67 - Mage, Warlock, Druid (9 agents)

**Dungeons:** Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
**Zones:** Terokkar Forest (late), Nagrand, Blade's Edge Mountains
**Reputation:** Lower City (Honored), Sha'tar (Friendly), Keepers of Time (Friendly)

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 3C-01 | Mage | Arcane | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3C-02 | Mage | Fire | 2 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3C-03 | Mage | Frost | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3C-04 | Warlock | Affliction | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3C-05 | Warlock | Demonology | 2 | Cloth | Spell Damage, Stamina, Intellect, Hit |
| 3C-06 | Warlock | Destruction | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 3C-07 | Druid | Balance | 1 | Leather | Spell Damage, Intellect, Crit, Hit |
| 3C-08 | Druid | Feral Combat | 2 | Leather | Agility, AP, Strength, Crit, Hit |
| 3C-09 | Druid | Restoration | 3 | Leather | +Healing, Intellect, Spirit, MP5 |

---

## BATCH 4A: Level 68-70 Pre-Heroic - Warrior, Paladin, Hunter (9 agents)

**Dungeons (NORMAL MODE ONLY):**
- Shadow Labyrinth (70-72) - Lower City rep
- The Steamvault (70-72) - Cenarion Expedition rep
- The Shattered Halls (70-72) - Honor Hold/Thrallmar rep
- The Mechanar (70-72) - Sha'tar rep
- The Botanica (70-72) - Sha'tar rep
- The Arcatraz (70-72) - Sha'tar rep
- The Black Morass (70) - Keepers of Time rep

**Quest Zones:** Netherstorm, Shadowmoon Valley, Shattrath City (epic chains)

**Reputation (REVERED focus):**
- Honor Hold / Thrallmar (Revered) - Heroic key + gear
- Cenarion Expedition (Revered) - Heroic key + gear
- Lower City (Revered) - Heroic key + gear
- Sha'tar (Revered) - Gear
- Keepers of Time (Revered) - Heroic key + gear

**Items Per Agent: 9 (4 dungeon + 3 quest + 2 rep)**

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 4A-01 | Warrior | Arms | 1 | Plate | Strength, AP, Crit, Hit |
| 4A-02 | Warrior | Fury | 2 | Plate | Strength, AP, Crit, Hit (dual-wield) |
| 4A-03 | Warrior | Protection | 3 | Plate | Stamina, Defense, Block, Parry |
| 4A-04 | Paladin | Holy | 1 | Plate/Mail | +Healing, Intellect, MP5, Spirit |
| 4A-05 | Paladin | Protection | 2 | Plate | Stamina, Defense, Spell Power, Block |
| 4A-06 | Paladin | Retribution | 3 | Plate | Strength, AP, Crit, Hit, Spell Power |
| 4A-07 | Hunter | Beast Mastery | 1 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 4A-08 | Hunter | Marksmanship | 2 | Mail/Leather | Agility, AP, Crit, Hit, Intellect |
| 4A-09 | Hunter | Survival | 3 | Mail/Leather | Agility, AP, Crit, Hit, Stamina |

---

## BATCH 4B: Level 68-70 Pre-Heroic - Rogue, Priest, Shaman (9 agents)

**Dungeons (NORMAL MODE ONLY):** Shadow Labyrinth, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass

**Quest Zones:** Netherstorm, Shadowmoon Valley, Shattrath City

**Reputation (REVERED focus):** All 5 heroic key factions

**Items Per Agent: 9 (4 dungeon + 3 quest + 2 rep)**

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 4B-01 | Rogue | Assassination | 1 | Leather | Agility, AP, Crit, Hit (DAGGERS ONLY) |
| 4B-02 | Rogue | Combat | 2 | Leather | Agility, AP, Hit, Crit, Expertise |
| 4B-03 | Rogue | Subtlety | 3 | Leather | Agility, AP, Crit, Hit |
| 4B-04 | Priest | Discipline | 1 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 4B-05 | Priest | Holy | 2 | Cloth | +Healing, Intellect, Spirit, MP5 |
| 4B-06 | Priest | Shadow | 3 | Cloth | SPELL DAMAGE (not +Healing), Intellect, Crit, Hit |
| 4B-07 | Shaman | Elemental | 1 | Mail/Leather | Spell Damage, Intellect, Crit, Hit |
| 4B-08 | Shaman | Enhancement | 2 | Mail/Leather | Agility, AP, Strength, Crit, Hit (SLOW weapons!) |
| 4B-09 | Shaman | Restoration | 3 | Mail/Leather | +Healing, Intellect, MP5, Spirit |

---

## BATCH 4C: Level 68-70 Pre-Heroic - Mage, Warlock, Druid (9 agents)

**Dungeons (NORMAL MODE ONLY):** Shadow Labyrinth, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass

**Quest Zones:** Netherstorm, Shadowmoon Valley, Shattrath City

**Reputation (REVERED focus):** All 5 heroic key factions

**Items Per Agent: 9 (4 dungeon + 3 quest + 2 rep)**

| Agent # | Class | Spec | Tab | Armor | Primary Stats |
|---------|-------|------|-----|-------|---------------|
| 4C-01 | Mage | Arcane | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 4C-02 | Mage | Fire | 2 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 4C-03 | Mage | Frost | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 4C-04 | Warlock | Affliction | 1 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 4C-05 | Warlock | Demonology | 2 | Cloth | Spell Damage, Stamina, Intellect, Hit |
| 4C-06 | Warlock | Destruction | 3 | Cloth | Spell Damage, Intellect, Crit, Hit |
| 4C-07 | Druid | Balance | 1 | Leather | Spell Damage, Intellect, Crit, Hit |
| 4C-08 | Druid | Feral Combat | 2 | Leather | Agility, AP, Strength, Crit, Hit (STATS ONLY - weapon DPS ignored in forms) |
| 4C-09 | Druid | Restoration | 3 | Leather | +Healing, Intellect, Spirit, MP5 |

---

## LEVEL 70 NORMAL DUNGEON REFERENCE

### Coilfang Reservoir
| Dungeon | Bosses | Rep | Heroic Key |
|---------|--------|-----|------------|
| **The Steamvault** | Hydromancer Thespia, Mekgineer Steamrigger, Warlord Kalithresh | Cenarion Expedition | Reservoir Key (Revered) |

### Auchindoun
| Dungeon | Bosses | Rep | Heroic Key |
|---------|--------|-----|------------|
| **Shadow Labyrinth** | Ambassador Hellmaw, Blackheart the Inciter, Grandmaster Vorpil, Murmur | Lower City | Auchenai Key (Revered) |

### Hellfire Citadel
| Dungeon | Bosses | Rep | Heroic Key |
|---------|--------|-----|------------|
| **The Shattered Halls** | Grand Warlock Nethekurse, Blood Guard Porung, Warbringer O'mrogg, Warchief Kargath Bladefist | Honor Hold/Thrallmar | Flamewrought Key (Revered) |

### Tempest Keep
| Dungeon | Bosses | Rep | Heroic Key |
|---------|--------|-----|------------|
| **The Mechanar** | Mechano-Lord Capacitus, Nethermancer Sepethrea, Pathaleon the Calculator | Sha'tar | Warpforged Key (Revered) |
| **The Botanica** | Commander Sarannis, High Botanist Freywinn, Thorngrin the Tender, Laj, Warp Splinter | Sha'tar | Warpforged Key (Revered) |
| **The Arcatraz** | Zereketh the Unbound, Dalliah the Doomsayer, Wrath-Scryer Soccothrates, Harbinger Skyriss | Sha'tar | Warpforged Key (Revered) |

### Caverns of Time
| Dungeon | Bosses | Rep | Heroic Key |
|---------|--------|-----|------------|
| **The Black Morass** | Chrono Lord Deja, Temporus, Aeonus | Keepers of Time | Key of Time (Revered) |

---

## REVERED REPUTATION REWARDS REFERENCE

These are the key items available at Revered standing (the target for 68-70 gearing):

### Honor Hold / Thrallmar (Revered)
- Tank items, DPS plate items
- Epic helm enchant (Glyph of the Defender, Glyph of Ferocity)

### Cenarion Expedition (Revered)
- Caster/Healer items, some agility leather
- Epic helm enchant (Glyph of Nature Warding)

### Lower City (Revered)
- Cloth caster items, some melee items
- Epic helm enchant options

### Sha'tar (Revered)
- Caster items, some plate items
- Epic shoulder enchants (if Aldor/Scryer not applicable)

### Keepers of Time (Revered)
- Caster trinkets, some melee items
- Epic helm enchant (Glyph of Chromatic Warding)

---

## NETHERSTORM / SMV EPIC QUEST CHAINS

These level 70 quest chains reward pre-raid quality epics:

### Netherstorm
- **Dimensius the All-Devouring** chain - caster/healer rewards
- **Socrethar's Shadow** chain - various class rewards
- **Kael'thas Sunstrider (pre-raid)** chain - multiple epic rewards

### Shadowmoon Valley
- **Cipher of Damnation** chain - epic weapon rewards
- **Akama's Promise** chain - various class rewards
- **Netherwing Introduction** chain - misc rewards

### Shattrath City
- **The Aldor/Scryer** reputation items (Honored/Revered)
- **A'dal's questlines** - various epic rewards

---

## AGENT PROMPT TEMPLATES

### Template for Level 60-62 Agents

```
Research TBC Classic (2.4.3) leveling gear for {CLASS} {SPEC} spec at level range 60-62.

CLASS: {CLASS}
SPEC: {SPEC} (Talent Tab {TAB})
ARMOR TYPE: {ARMOR}
STAT PRIORITY: {STATS}

DUNGEONS TO SEARCH:
- Hellfire Ramparts (60-62): Watchkeeper Gargolmar, Omor the Unscarred, Vazruden & Nazan
- Blood Furnace (61-63): The Maker, Broggok, Keli'dan the Breaker

QUEST ZONES:
- Hellfire Peninsula (all quest hubs)

REPUTATION:
- Honor Hold / Thrallmar (Honored rewards)

REQUIREMENTS:
1. Find exactly 3 DUNGEON DROP items appropriate for this spec
2. Find exactly 3 QUEST REWARD items from Hellfire Peninsula
3. Items must match the armor type and stat priority
4. Include the Wowhead TBC Classic item ID for each item
5. Prioritize different gear slots (don't recommend 3 chest pieces)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]

Search Wowhead TBC Classic database: https://tbc.wowhead.com/
```

### Template for Level 63-65 Agents

```
Research TBC Classic (2.4.3) leveling gear for {CLASS} {SPEC} spec at level range 63-65.

CLASS: {CLASS}
SPEC: {SPEC} (Talent Tab {TAB})
ARMOR TYPE: {ARMOR}
STAT PRIORITY: {STATS}

DUNGEONS TO SEARCH:
- Slave Pens (62-64): Mennu the Betrayer, Rokmar the Crackler, Quagmirran
- Underbog (63-65): Hungarfen, Ghaz'an, Swamplord Musel'ek, Black Stalker
- Mana-Tombs (64-66): Pandemonius, Tavarok, Nexus-Prince Shaffar

QUEST ZONES:
- Zangarmarsh (primary)
- Terokkar Forest (early quests)

REPUTATION:
- Cenarion Expedition (Honored rewards)
- Lower City (Friendly/Honored rewards)

REQUIREMENTS:
1. Find exactly 3 DUNGEON DROP items appropriate for this spec
2. Find exactly 3 QUEST REWARD items from Zangarmarsh/Terokkar
3. Items must match the armor type and stat priority
4. Include the Wowhead TBC Classic item ID for each item
5. Prioritize different gear slots (don't recommend 3 chest pieces)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]

Search Wowhead TBC Classic database: https://tbc.wowhead.com/
```

### Template for Level 66-67 Agents

```
Research TBC Classic (2.4.3) leveling gear for {CLASS} {SPEC} spec at level range 66-67.

CLASS: {CLASS}
SPEC: {SPEC} (Talent Tab {TAB})
ARMOR TYPE: {ARMOR}
STAT PRIORITY: {STATS}

DUNGEONS TO SEARCH:
- Auchenai Crypts (65-67): Shirrak the Dead Watcher, Exarch Maladaar
- Sethekk Halls (67-69): Darkweaver Syth, Talon King Ikiss
- Old Hillsbrad Foothills (66-68): Lieutenant Drake, Captain Skarloc, Epoch Hunter

QUEST ZONES:
- Terokkar Forest (late quests, Auchindoun area)
- Nagrand
- Blade's Edge Mountains (early)

REPUTATION:
- Lower City (Honored rewards)
- Sha'tar (Friendly/Honored rewards)
- Keepers of Time (Friendly rewards)

REQUIREMENTS:
1. Find exactly 3 DUNGEON DROP items appropriate for this spec
2. Find exactly 3 QUEST REWARD items from Terokkar/Nagrand/Blade's Edge
3. Items must match the armor type and stat priority
4. Include the Wowhead TBC Classic item ID for each item
5. Prioritize different gear slots (don't recommend 3 chest pieces)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name]

Search Wowhead TBC Classic database: https://tbc.wowhead.com/
```

### Template for Level 68-70 Pre-Heroic Agents

```
Research TBC Classic (2.4.3) PRE-HEROIC gear for {CLASS} {SPEC} spec at level 68-70.

**IMPORTANT: NORMAL MODE DUNGEONS ONLY - NO HEROIC DROPS**

CLASS: {CLASS}
SPEC: {SPEC} (Talent Tab {TAB})
ARMOR TYPE: {ARMOR}
STAT PRIORITY: {STATS}

DUNGEONS TO SEARCH (NORMAL MODE ONLY):
- Shadow Labyrinth (70): Ambassador Hellmaw, Blackheart the Inciter, Grandmaster Vorpil, Murmur
- The Steamvault (70): Hydromancer Thespia, Mekgineer Steamrigger, Warlord Kalithresh
- The Shattered Halls (70): Grand Warlock Nethekurse, Blood Guard Porung, Warbringer O'mrogg, Warchief Kargath Bladefist
- The Mechanar (70): Mechano-Lord Capacitus, Nethermancer Sepethrea, Pathaleon the Calculator
- The Botanica (70): Commander Sarannis, High Botanist Freywinn, Thorngrin the Tender, Laj, Warp Splinter
- The Arcatraz (70): Zereketh the Unbound, Dalliah the Doomsayer, Wrath-Scryer Soccothrates, Harbinger Skyriss
- The Black Morass (70): Chrono Lord Deja, Temporus, Aeonus

QUEST ZONES:
- Netherstorm (epic quest chains: Dimensius, Socrethar's Shadow)
- Shadowmoon Valley (epic quest chains: Cipher of Damnation, Akama's Promise)
- Shattrath City (A'dal questlines)

REPUTATION (REVERED STANDING - for heroic key prep):
- Honor Hold / Thrallmar (Revered)
- Cenarion Expedition (Revered)
- Lower City (Revered)
- Sha'tar (Revered)
- Keepers of Time (Revered)

REQUIREMENTS:
1. Find exactly 4 NORMAL DUNGEON DROP items (NO HEROIC DROPS)
2. Find exactly 3 QUEST REWARD items from Netherstorm/SMV/Shattrath epic chains
3. Find exactly 2 REPUTATION REWARD items at REVERED standing
4. Items must match the armor type and stat priority
5. Include the Wowhead TBC Classic item ID for each item
6. Prioritize slots that will be upgraded last in heroics (trinkets, rings, weapons)

OUTPUT FORMAT:
NORMAL DUNGEON DROPS (4 items):
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)] | [Item Level]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)] | [Item Level]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)] | [Item Level]
4. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Source: Dungeon (Boss)] | [Item Level]

QUEST REWARDS (3 items):
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name (Zone)] | [Item Level]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name (Zone)] | [Item Level]
3. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Quest Name (Zone)] | [Item Level]

REPUTATION REWARDS (2 items at REVERED):
1. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Faction (Revered)] | [Item Level]
2. [ItemID] | [Item Name] | [Slot] | [Key Stats] | [Faction (Revered)] | [Item Level]

Search Wowhead TBC Classic database: https://tbc.wowhead.com/
Filter by: Source > Dungeon (Normal mode only), Quest, Reputation
Sort by item level to find best pre-heroic options
```

---

## EXECUTION PAYLOADS

**INSTRUCTIONS:** Execute each payload in order. Each payload is self-contained. Copy the entire payload and run it. No thinking required.

---

### PAYLOAD 1: BATCH 1A - Level 60-62 Warrior/Paladin/Hunter (9 agents)

**Status:** NOT STARTED
**Pre-check:** None required - this is the first payload

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 1A-01: WARRIOR ARMS 60-62
Research TBC Classic (2.4.3) leveling gear for WARRIOR ARMS spec at level range 60-62.

SPEC CARD REFERENCE: WARRIOR_ARMS
- Armor: Plate ONLY
- Weapons: 2H Sword, 2H Axe, 2H Mace, Polearm (SLOW 3.3-3.8 speed)
- Stats: Strength > Attack Power > Crit > Hit > Stamina
- AVOID: Intellect, Spirit, Spell Power, Defense

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (different slots)
- 3 Quest rewards (different slots)
- Prioritize: Chest, Legs, Helm, 2H Weapon

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-02: WARRIOR FURY 60-62
Research TBC Classic (2.4.3) leveling gear for WARRIOR FURY spec at level range 60-62.

SPEC CARD REFERENCE: WARRIOR_FURY
- Armor: Plate ONLY
- Weapons: DUAL-WIELD - MH 1H Sword/Axe/Mace/Fist (SLOW 2.5-2.8), OH (FAST 1.5-1.8)
- Stats: Strength > Attack Power > Crit > Hit > Haste
- AVOID: Intellect, Spirit, Spell Power, Defense

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include 2 one-hand weapons if possible)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-03: WARRIOR PROTECTION 60-62
Research TBC Classic (2.4.3) leveling gear for WARRIOR PROTECTION spec at level range 60-62.

SPEC CARD REFERENCE: WARRIOR_PROT
- Armor: Plate ONLY (NO exceptions for tanks)
- Weapons: 1H + Shield - 1H Sword/Axe/Mace (FAST 1.5-1.8), Shield (Block Value, Stamina)
- Stats: Stamina > Defense Rating > Block Value/Rating > Parry > Dodge
- AVOID: Intellect, Spirit, Spell Power, Attack Power (some ok)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include Shield)
- 3 Quest rewards (different slots)
- Prioritize: Shield, Chest, Legs, Helm with Defense/Stamina

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-04: PALADIN HOLY 60-62
Research TBC Classic (2.4.3) leveling gear for PALADIN HOLY spec at level range 60-62.

SPEC CARD REFERENCE: PALADIN_HOLY
- Armor: Plate preferred, Mail/Cloth acceptable for +Healing
- Weapons: 1H Mace/Sword + Shield OR 1H + Off-hand (with +Healing)
- Stats: +Healing > Intellect > MP5 > Spirit > Stamina
- CANNOT USE: Daggers, Fist Weapons, Staves, Ranged
- AVOID: Strength, Attack Power, Agility

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (prioritize +Healing pieces)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-05: PALADIN PROTECTION 60-62
Research TBC Classic (2.4.3) leveling gear for PALADIN PROTECTION spec at level range 60-62.

SPEC CARD REFERENCE: PALADIN_PROT
- Armor: Plate ONLY (NO exceptions for tanks)
- Weapons: 1H Sword/Mace/Axe (FAST) + Shield
- Stats: Stamina > Defense Rating > Spell Power (for threat!) > Block Value/Rating > Intellect
- CANNOT USE: Daggers, Fist Weapons, Staves, Ranged
- SPECIAL: Spell Power is VALUABLE for Prot Paladin threat (Consecration, Holy Shield)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include Shield, look for Spell Power + Stamina)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-06: PALADIN RETRIBUTION 60-62
Research TBC Classic (2.4.3) leveling gear for PALADIN RETRIBUTION spec at level range 60-62.

SPEC CARD REFERENCE: PALADIN_RET
- Armor: Plate ONLY
- Weapons: 2H Sword, 2H Axe, 2H Mace, Polearm (VERY SLOW 3.5-3.8 speed!)
- Stats: Strength > Attack Power > Crit > Hit > Spell Power (for seals)
- CANNOT USE: Daggers, Fist Weapons, Staves, Ranged
- CRITICAL: Slowest possible 2H weapon is BEST for Seal of Command procs!

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include slow 2H weapon if available)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-07: HUNTER BEAST MASTERY 60-62
Research TBC Classic (2.4.3) leveling gear for HUNTER BEAST MASTERY spec at level range 60-62.

SPEC CARD REFERENCE: HUNTER_BM
- Armor: Mail preferred, Leather acceptable for better Agility
- Weapons: RANGED IS PRIMARY (Bow/Gun/Crossbow), Melee is stat stick (2H Axe/Polearm/Staff)
- Stats: Agility > Attack Power > Crit > Hit > Intellect
- CANNOT USE: Maces, Shields, Wands
- CRITICAL: Ranged weapon is your MAIN weapon - prioritize it!

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-08: HUNTER MARKSMANSHIP 60-62
Research TBC Classic (2.4.3) leveling gear for HUNTER MARKSMANSHIP spec at level range 60-62.

SPEC CARD REFERENCE: HUNTER_MM
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED IS PRIMARY (Bow/Gun/Crossbow), Melee is stat stick
- Stats: Agility > Attack Power > Crit > Hit > Intellect
- CANNOT USE: Maces, Shields, Wands

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1A-09: HUNTER SURVIVAL 60-62
Research TBC Classic (2.4.3) leveling gear for HUNTER SURVIVAL spec at level range 60-62.

SPEC CARD REFERENCE: HUNTER_SURV
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED IS PRIMARY (Bow/Gun/Crossbow), Melee is stat stick
- Stats: Agility > Attack Power > Crit > Hit > Stamina (survival focus)
- CANNOT USE: Maces, Shields, Wands

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

**Post-Payload 1A Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section under each spec
3. Update Batch Status: `1A | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 2

---

### PAYLOAD 2: BATCH 1B - Level 60-62 Rogue/Priest/Shaman (9 agents)

**Status:** NOT STARTED
**Pre-check:** PAYLOAD 1 complete (optional - can run in parallel)

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 1B-01: ROGUE ASSASSINATION 60-62
Research TBC Classic (2.4.3) leveling gear for ROGUE ASSASSINATION spec at level range 60-62.

SPEC CARD REFERENCE: ROGUE_ASSN
- Armor: Leather ONLY
- Weapons: DUAL-WIELD DAGGERS ONLY - MH Dagger (SLOW 1.7-1.8), OH Dagger (FAST 1.3-1.5)
- Stats: Agility > Attack Power > Crit > Hit > Haste
- CANNOT USE: 2H weapons, Axes, Swords (for main abilities), Maces
- CRITICAL: MUST use daggers - Mutilate and Backstab REQUIRE daggers!

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include 2 daggers if possible - slow MH, fast OH)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-02: ROGUE COMBAT 60-62
Research TBC Classic (2.4.3) leveling gear for ROGUE COMBAT spec at level range 60-62.

SPEC CARD REFERENCE: ROGUE_COMBAT
- Armor: Leather ONLY
- Weapons: DUAL-WIELD - MH 1H Sword/Mace/Fist (SLOW 2.4-2.8), OH Dagger/fast 1H (FAST 1.3-1.5)
- Stats: Agility > Attack Power > Hit > Crit > Expertise
- CANNOT USE: 2H weapons, Axes
- NOTE: Sword Specialization or Mace Specialization talents determine best MH

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (include slow 1H sword/mace MH, fast OH)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-03: ROGUE SUBTLETY 60-62
Research TBC Classic (2.4.3) leveling gear for ROGUE SUBTLETY spec at level range 60-62.

SPEC CARD REFERENCE: ROGUE_SUB
- Armor: Leather ONLY
- Weapons: DUAL-WIELD DAGGERS - MH Dagger (slow), OH Dagger (fast)
- Stats: Agility > Attack Power > Crit > Hit > Haste
- CANNOT USE: 2H weapons, Axes
- NOTE: Daggers preferred for Backstab/Ambush

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (include daggers)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-04: PRIEST DISCIPLINE 60-62
Research TBC Classic (2.4.3) leveling gear for PRIEST DISCIPLINE spec at level range 60-62.

SPEC CARD REFERENCE: PRIEST_DISC
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with +Healing)
- Stats: +Healing > Intellect > Spirit > MP5 > Stamina
- CANNOT USE: Swords, Axes, Fist Weapons, Shields
- Ranged: Wand

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (prioritize +Healing cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-05: PRIEST HOLY 60-62
Research TBC Classic (2.4.3) leveling gear for PRIEST HOLY spec at level range 60-62.

SPEC CARD REFERENCE: PRIEST_HOLY
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with +Healing)
- Stats: +Healing > Intellect > Spirit > MP5 > Spell Crit
- CANNOT USE: Swords, Axes, Fist Weapons, Shields
- Ranged: Wand

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (prioritize +Healing cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-06: PRIEST SHADOW 60-62
Research TBC Classic (2.4.3) leveling gear for PRIEST SHADOW spec at level range 60-62.

SPEC CARD REFERENCE: PRIEST_SHADOW
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with SPELL DAMAGE, NOT +Healing!)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit
- CANNOT USE: Swords, Axes, Fist Weapons, Shields
- CRITICAL: Shadow needs SPELL DAMAGE, not +Healing!
- Ranged: Wand (Shadow damage preferred)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (SPELL DAMAGE cloth, NOT healing)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-07: SHAMAN ELEMENTAL 60-62
Research TBC Classic (2.4.3) leveling gear for SHAMAN ELEMENTAL spec at level range 60-62.

SPEC CARD REFERENCE: SHAMAN_ELE
- Armor: Mail preferred, Leather acceptable for spell power
- Weapons: 1H Mace/Dagger + Shield OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > MP5
- CANNOT USE: Swords, Polearms, Bows, Guns, Wands
- Relic: Totem

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage mail/leather, caster shield)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-08: SHAMAN ENHANCEMENT 60-62
Research TBC Classic (2.4.3) leveling gear for SHAMAN ENHANCEMENT spec at level range 60-62.

SPEC CARD REFERENCE: SHAMAN_ENH
- Armor: Mail preferred, Leather acceptable for AP/Agi
- Weapons: DUAL-WIELD - MH 1H Axe/Mace/Fist (SLOW 2.6-2.8), OH 1H Axe/Mace/Fist (SLOW 2.4-2.6)
- Stats: Agility > Attack Power > Strength > Crit > Hit
- CANNOT USE: Swords, Polearms, Bows, Guns, Wands
- CRITICAL: BOTH weapons must be SLOW for Windfury procs! Fast weapons = BAD!

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (MUST include 2 SLOW 1H weapons if possible - 2.6+ speed each!)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1B-09: SHAMAN RESTORATION 60-62
Research TBC Classic (2.4.3) leveling gear for SHAMAN RESTORATION spec at level range 60-62.

SPEC CARD REFERENCE: SHAMAN_RESTO
- Armor: Mail preferred, Leather acceptable for +Healing
- Weapons: 1H Mace/Dagger + Shield OR Staff (with +Healing)
- Stats: +Healing > Intellect > MP5 > Spirit > Spell Crit
- CANNOT USE: Swords, Polearms, Bows, Guns, Wands
- Relic: Totem with healing effects

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (+Healing mail/leather)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

**Post-Payload 2 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section under each spec
3. Update Batch Status: `1B | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 3

---

### PAYLOAD 3: BATCH 1C - Level 60-62 Mage/Warlock/Druid (9 agents)

**Status:** NOT STARTED
**Pre-check:** PAYLOAD 1-2 complete (optional - can run in parallel)

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 1C-01: MAGE ARCANE 60-62
Research TBC Classic (2.4.3) leveling gear for MAGE ARCANE spec at level range 60-62.

SPEC CARD REFERENCE: MAGE_ARCANE
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit (for Arcane Meditation)
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- Ranged: Wand (Arcane damage preferred)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-02: MAGE FIRE 60-62
Research TBC Classic (2.4.3) leveling gear for MAGE FIRE spec at level range 60-62.

SPEC CARD REFERENCE: MAGE_FIRE
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit (for Ignite!) > Hit > Stamina
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- Ranged: Wand (Fire damage preferred)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage cloth, crit rating)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-03: MAGE FROST 60-62
Research TBC Classic (2.4.3) leveling gear for MAGE FROST spec at level range 60-62.

SPEC CARD REFERENCE: MAGE_FROST
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Stamina
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- Ranged: Wand (Frost damage preferred)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-04: WARLOCK AFFLICTION 60-62
Research TBC Classic (2.4.3) leveling gear for WARLOCK AFFLICTION spec at level range 60-62.

SPEC CARD REFERENCE: WARLOCK_AFF
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit (for Life Tap)
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- Ranged: Wand (Shadow damage preferred)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage cloth, shadow wand)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-05: WARLOCK DEMONOLOGY 60-62
Research TBC Classic (2.4.3) leveling gear for WARLOCK DEMONOLOGY spec at level range 60-62.

SPEC CARD REFERENCE: WARLOCK_DEMO
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage + Stamina)
- Stats: Spell Damage > Stamina (pet scaling!) > Intellect > Hit > Spirit
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- SPECIAL: Stamina is MORE valuable for Demo (Demonic Knowledge talent)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage + stamina cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-06: WARLOCK DESTRUCTION 60-62
Research TBC Classic (2.4.3) leveling gear for WARLOCK DESTRUCTION spec at level range 60-62.

SPEC CARD REFERENCE: WARLOCK_DESTRO
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Stamina
- CANNOT USE: Maces, Axes, Fist Weapons, Shields
- Ranged: Wand (Fire or Shadow damage)

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage cloth, crit rating)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-07: DRUID BALANCE 60-62
Research TBC Classic (2.4.3) leveling gear for DRUID BALANCE spec at level range 60-62.

SPEC CARD REFERENCE: DRUID_BALANCE
- Armor: Leather preferred, Cloth acceptable for big spell power upgrades
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit
- CANNOT USE: Swords, Axes, Polearms, Shields, Bows, Wands
- Relic: Idol with Balance effects

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (spell damage leather/cloth, caster staff)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-08: DRUID FERAL COMBAT 60-62
Research TBC Classic (2.4.3) leveling gear for DRUID FERAL COMBAT spec at level range 60-62.

SPEC CARD REFERENCE: DRUID_FERAL
- Armor: Leather ONLY (NEVER cloth for feral)
- Weapons: Staff, 2H Mace, 1H Mace/Dagger/Fist + Off-hand (STATS ONLY - weapon DPS ignored in forms!)
- Stats: Agility > Attack Power > Feral Attack Power > Strength > Crit > Hit
- CANNOT USE: Swords, Axes, Polearms, Shields, Bows, Wands
- CRITICAL: Weapon DPS is IGNORED in Cat/Bear form - ONLY STATS MATTER!
- SPECIAL: Look for "Feral Attack Power" items - HUGE value!

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (Agi leather, Feral AP items, staff with Agi/Str)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 1C-09: DRUID RESTORATION 60-62
Research TBC Classic (2.4.3) leveling gear for DRUID RESTORATION spec at level range 60-62.

SPEC CARD REFERENCE: DRUID_RESTO
- Armor: Leather preferred, Cloth acceptable for +Healing
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with +Healing)
- Stats: +Healing > Intellect > Spirit > MP5 > Spell Crit
- CANNOT USE: Swords, Axes, Polearms, Shields, Bows, Wands
- Relic: Idol with healing effects

SEARCH LOCATIONS:
- Dungeons: Hellfire Ramparts, Blood Furnace
- Quests: Hellfire Peninsula
- Rep: Honor Hold/Thrallmar Honored

FIND EXACTLY:
- 3 Dungeon drops (+Healing leather/cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

**Post-Payload 3 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section under each spec
3. Update Batch Status: `1C | COMPLETE | 9/9 | 54/54`
4. **CHECKPOINT: Level 60-62 Complete (162 items)**
5. Proceed to PAYLOAD 4

---

### PAYLOAD 4: BATCH 2A - Level 63-65 Warrior/Paladin/Hunter (9 agents)

**Status:** NOT STARTED
**Pre-check:** Payloads 1-3 complete (Level 60-62 done)

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 2A-01: WARRIOR ARMS 63-65
Research TBC Classic (2.4.3) leveling gear for WARRIOR ARMS spec at level range 63-65.

SPEC CARD REFERENCE: WARRIOR_ARMS
- Armor: Plate ONLY
- Weapons: 2H Sword, 2H Axe, 2H Mace, Polearm (SLOW 3.3-3.8 speed)
- Stats: Strength > Attack Power > Crit > Hit > Stamina

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (different slots)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-02: WARRIOR FURY 63-65
Research TBC Classic (2.4.3) leveling gear for WARRIOR FURY spec at level range 63-65.

SPEC CARD REFERENCE: WARRIOR_FURY
- Armor: Plate ONLY
- Weapons: DUAL-WIELD - MH 1H (SLOW 2.5-2.8), OH 1H (FAST 1.5-1.8)
- Stats: Strength > Attack Power > Crit > Hit > Haste

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include 1H weapons)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-03: WARRIOR PROTECTION 63-65
Research TBC Classic (2.4.3) leveling gear for WARRIOR PROTECTION spec at level range 63-65.

SPEC CARD REFERENCE: WARRIOR_PROT
- Armor: Plate ONLY
- Weapons: 1H + Shield
- Stats: Stamina > Defense Rating > Block Value/Rating > Parry > Dodge

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include Shield)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-04: PALADIN HOLY 63-65
Research TBC Classic (2.4.3) leveling gear for PALADIN HOLY spec at level range 63-65.

SPEC CARD REFERENCE: PALADIN_HOLY
- Armor: Plate preferred, Mail/Cloth acceptable for +Healing
- Weapons: 1H + Shield/Off-hand (with +Healing)
- Stats: +Healing > Intellect > MP5 > Spirit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (+Healing pieces)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-05: PALADIN PROTECTION 63-65
Research TBC Classic (2.4.3) leveling gear for PALADIN PROTECTION spec at level range 63-65.

SPEC CARD REFERENCE: PALADIN_PROT
- Armor: Plate ONLY
- Weapons: 1H + Shield
- Stats: Stamina > Defense > Spell Power (for threat!) > Block

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include Shield, look for Spell Power + Stamina)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-06: PALADIN RETRIBUTION 63-65
Research TBC Classic (2.4.3) leveling gear for PALADIN RETRIBUTION spec at level range 63-65.

SPEC CARD REFERENCE: PALADIN_RET
- Armor: Plate ONLY
- Weapons: 2H Sword/Axe/Mace/Polearm (VERY SLOW 3.5-3.8 speed!)
- Stats: Strength > Attack Power > Crit > Hit > Spell Power

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include slow 2H weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-07: HUNTER BEAST MASTERY 63-65
Research TBC Classic (2.4.3) leveling gear for HUNTER BEAST MASTERY spec at level range 63-65.

SPEC CARD REFERENCE: HUNTER_BM
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY (Bow/Gun/Crossbow)
- Stats: Agility > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-08: HUNTER MARKSMANSHIP 63-65
Research TBC Classic (2.4.3) leveling gear for HUNTER MARKSMANSHIP spec at level range 63-65.

SPEC CARD REFERENCE: HUNTER_MM
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY
- Stats: Agility > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2A-09: HUNTER SURVIVAL 63-65
Research TBC Classic (2.4.3) leveling gear for HUNTER SURVIVAL spec at level range 63-65.

SPEC CARD REFERENCE: HUNTER_SURV
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY
- Stats: Agility > Attack Power > Crit > Hit > Stamina

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include ranged weapon)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

**Post-Payload 4 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section under each spec
3. Update Batch Status: `2A | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 5

---

### PAYLOAD 5: BATCH 2B - Level 63-65 Rogue/Priest/Shaman (9 agents)

**Status:** NOT STARTED
**Pre-check:** Can run parallel with Payloads 4 and 6

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 2B-01: ROGUE ASSASSINATION 63-65
Research TBC Classic (2.4.3) leveling gear for ROGUE ASSASSINATION spec at level range 63-65.

SPEC CARD REFERENCE: ROGUE_ASSN
- Armor: Leather ONLY
- Weapons: DUAL-WIELD DAGGERS ONLY - MH Dagger (SLOW 1.7-1.8), OH Dagger (FAST 1.3-1.5)
- Stats: Agility > Attack Power > Crit > Hit > Haste
- CRITICAL: MUST use daggers - Mutilate and Backstab REQUIRE daggers!

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include daggers - slow MH, fast OH)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-02: ROGUE COMBAT 63-65
Research TBC Classic (2.4.3) leveling gear for ROGUE COMBAT spec at level range 63-65.

SPEC CARD REFERENCE: ROGUE_COMBAT
- Armor: Leather ONLY
- Weapons: DUAL-WIELD - MH 1H Sword/Mace/Fist (SLOW 2.4-2.8), OH Dagger/fast 1H (FAST 1.3-1.5)
- Stats: Agility > Attack Power > Hit > Crit > Expertise

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (slow 1H sword/mace MH, fast OH)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-03: ROGUE SUBTLETY 63-65
Research TBC Classic (2.4.3) leveling gear for ROGUE SUBTLETY spec at level range 63-65.

SPEC CARD REFERENCE: ROGUE_SUB
- Armor: Leather ONLY
- Weapons: DUAL-WIELD DAGGERS
- Stats: Agility > Attack Power > Crit > Hit > Haste

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include daggers)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-04: PRIEST DISCIPLINE 63-65
Research TBC Classic (2.4.3) leveling gear for PRIEST DISCIPLINE spec at level range 63-65.

SPEC CARD REFERENCE: PRIEST_DISC
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with +Healing)
- Stats: +Healing > Intellect > Spirit > MP5

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (+Healing cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-05: PRIEST HOLY 63-65
Research TBC Classic (2.4.3) leveling gear for PRIEST HOLY spec at level range 63-65.

SPEC CARD REFERENCE: PRIEST_HOLY
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (with +Healing)
- Stats: +Healing > Intellect > Spirit > MP5 > Spell Crit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (+Healing cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-06: PRIEST SHADOW 63-65
Research TBC Classic (2.4.3) leveling gear for PRIEST SHADOW spec at level range 63-65.

SPEC CARD REFERENCE: PRIEST_SHADOW
- Armor: Cloth ONLY
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (SPELL DAMAGE, NOT +Healing!)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit
- CRITICAL: Shadow needs SPELL DAMAGE, not +Healing!

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (SPELL DAMAGE cloth)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-07: SHAMAN ELEMENTAL 63-65
Research TBC Classic (2.4.3) leveling gear for SHAMAN ELEMENTAL spec at level range 63-65.

SPEC CARD REFERENCE: SHAMAN_ELE
- Armor: Mail preferred, Leather acceptable
- Weapons: 1H Mace/Dagger + Shield OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > MP5

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (spell damage mail/leather)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-08: SHAMAN ENHANCEMENT 63-65
Research TBC Classic (2.4.3) leveling gear for SHAMAN ENHANCEMENT spec at level range 63-65.

SPEC CARD REFERENCE: SHAMAN_ENH
- Armor: Mail preferred, Leather acceptable
- Weapons: DUAL-WIELD - BOTH 1H weapons MUST be SLOW (2.6+ MH, 2.4+ OH)
- Stats: Agility > Attack Power > Strength > Crit > Hit
- CRITICAL: BOTH weapons must be SLOW for Windfury procs!

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (include 2 SLOW 1H weapons if possible)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

```
AGENT 2B-09: SHAMAN RESTORATION 63-65
Research TBC Classic (2.4.3) leveling gear for SHAMAN RESTORATION spec at level range 63-65.

SPEC CARD REFERENCE: SHAMAN_RESTO
- Armor: Mail preferred, Leather acceptable
- Weapons: 1H Mace/Dagger + Shield OR Staff (+Healing)
- Stats: +Healing > Intellect > MP5 > Spirit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY:
- 3 Dungeon drops (+Healing mail/leather)
- 3 Quest rewards (different slots)

OUTPUT FORMAT:
DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest Name]

Use https://tbc.wowhead.com/ for item research.
```

**Post-Payload 5 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section
3. Update Batch Status: `2B | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 6

---

### PAYLOAD 6: BATCH 2C - Level 63-65 Mage/Warlock/Druid (9 agents)

**Status:** NOT STARTED
**Pre-check:** Can run parallel with Payloads 4 and 5

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 2C-01: MAGE ARCANE 63-65
Research TBC Classic (2.4.3) leveling gear for MAGE ARCANE spec at level range 63-65.

SPEC CARD REFERENCE: MAGE_ARCANE
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest
- Rep: Cenarion Expedition Honored, Lower City Friendly

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-02: MAGE FIRE 63-65
Research TBC Classic (2.4.3) leveling gear for MAGE FIRE spec at level range 63-65.

SPEC CARD REFERENCE: MAGE_FIRE
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit (Ignite!) > Hit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-03: MAGE FROST 63-65
Research TBC Classic (2.4.3) leveling gear for MAGE FROST spec at level range 63-65.

SPEC CARD REFERENCE: MAGE_FROST
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-04: WARLOCK AFFLICTION 63-65
Research TBC Classic (2.4.3) leveling gear for WARLOCK AFFLICTION spec at level range 63-65.

SPEC CARD REFERENCE: WARLOCK_AFF
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit > Spirit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-05: WARLOCK DEMONOLOGY 63-65
Research TBC Classic (2.4.3) leveling gear for WARLOCK DEMONOLOGY spec at level range 63-65.

SPEC CARD REFERENCE: WARLOCK_DEMO
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage + Stamina)
- Stats: Spell Damage > Stamina (pet scaling!) > Intellect > Hit
- SPECIAL: Stamina MORE valuable for Demonic Knowledge

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-06: WARLOCK DESTRUCTION 63-65
Research TBC Classic (2.4.3) leveling gear for WARLOCK DESTRUCTION spec at level range 63-65.

SPEC CARD REFERENCE: WARLOCK_DESTRO
- Armor: Cloth ONLY
- Weapons: 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-07: DRUID BALANCE 63-65
Research TBC Classic (2.4.3) leveling gear for DRUID BALANCE spec at level range 63-65.

SPEC CARD REFERENCE: DRUID_BALANCE
- Armor: Leather preferred, Cloth acceptable
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (Spell Damage)
- Stats: Spell Damage > Intellect > Crit > Hit
- CANNOT USE: Swords, Axes, Polearms

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-08: DRUID FERAL COMBAT 63-65
Research TBC Classic (2.4.3) leveling gear for DRUID FERAL COMBAT spec at level range 63-65.

SPEC CARD REFERENCE: DRUID_FERAL
- Armor: Leather ONLY (NEVER cloth)
- Weapons: Staff, 2H Mace, 1H Mace/Dagger/Fist (STATS ONLY - weapon DPS ignored!)
- Stats: Agility > Attack Power > Feral Attack Power > Strength > Crit
- CANNOT USE: Swords, Axes, Polearms
- SPECIAL: Look for "Feral Attack Power" items!

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 2C-09: DRUID RESTORATION 63-65
Research TBC Classic (2.4.3) leveling gear for DRUID RESTORATION spec at level range 63-65.

SPEC CARD REFERENCE: DRUID_RESTO
- Armor: Leather preferred, Cloth acceptable
- Weapons: 1H Mace/Dagger + Off-hand OR Staff (+Healing)
- Stats: +Healing > Intellect > Spirit > MP5
- CANNOT USE: Swords, Axes, Polearms

SEARCH LOCATIONS:
- Dungeons: Slave Pens, Underbog, Mana-Tombs
- Quests: Zangarmarsh, Terokkar Forest

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

**Post-Payload 6 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section
3. Update Batch Status: `2C | COMPLETE | 9/9 | 54/54`
4. **CHECKPOINT: Level 63-65 Complete (162 items)**
5. Proceed to PAYLOAD 7

---

### PAYLOAD 7: BATCH 3A - Level 66-67 Warrior/Paladin/Hunter (9 agents)

**Status:** NOT STARTED
**Pre-check:** Payloads 1-6 complete (Level 60-65 done)

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 3A-01: WARRIOR ARMS 66-67
Research TBC Classic (2.4.3) leveling gear for WARRIOR ARMS spec at level range 66-67.

SPEC CARD REFERENCE: WARRIOR_ARMS
- Armor: Plate ONLY
- Weapons: 2H Sword/Axe/Mace/Polearm (SLOW 3.3-3.8)
- Stats: Strength > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards (different slots)

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-02: WARRIOR FURY 66-67
Research TBC Classic (2.4.3) leveling gear for WARRIOR FURY spec at level range 66-67.

SPEC CARD REFERENCE: WARRIOR_FURY
- Armor: Plate ONLY
- Weapons: DUAL-WIELD - MH 1H (SLOW 2.5-2.8), OH 1H (FAST 1.5-1.8)
- Stats: Strength > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include 1H weapons) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-03: WARRIOR PROTECTION 66-67
Research TBC Classic (2.4.3) leveling gear for WARRIOR PROTECTION spec at level range 66-67.

SPEC CARD REFERENCE: WARRIOR_PROT
- Armor: Plate ONLY
- Weapons: 1H + Shield
- Stats: Stamina > Defense Rating > Block Value/Rating > Parry
- Goal: Approaching 490 defense cap

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include Shield) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-04: PALADIN HOLY 66-67
Research TBC Classic (2.4.3) leveling gear for PALADIN HOLY spec at level range 66-67.

SPEC CARD REFERENCE: PALADIN_HOLY
- Armor: Plate preferred, Mail/Cloth acceptable for +Healing
- Weapons: 1H + Shield/Off-hand (+Healing)
- Stats: +Healing > Intellect > MP5 > Spirit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-05: PALADIN PROTECTION 66-67
Research TBC Classic (2.4.3) leveling gear for PALADIN PROTECTION spec at level range 66-67.

SPEC CARD REFERENCE: PALADIN_PROT
- Armor: Plate ONLY
- Weapons: 1H + Shield
- Stats: Stamina > Defense > Spell Power (threat!) > Block
- Goal: Approaching 490 defense cap

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include Shield) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-06: PALADIN RETRIBUTION 66-67
Research TBC Classic (2.4.3) leveling gear for PALADIN RETRIBUTION spec at level range 66-67.

SPEC CARD REFERENCE: PALADIN_RET
- Armor: Plate ONLY
- Weapons: 2H Sword/Axe/Mace/Polearm (VERY SLOW 3.5-3.8!)
- Stats: Strength > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include slow 2H) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-07: HUNTER BEAST MASTERY 66-67
Research TBC Classic (2.4.3) leveling gear for HUNTER BEAST MASTERY spec at level range 66-67.

SPEC CARD REFERENCE: HUNTER_BM
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY (Bow/Gun/Crossbow)
- Stats: Agility > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include ranged weapon) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-08: HUNTER MARKSMANSHIP 66-67
Research TBC Classic (2.4.3) leveling gear for HUNTER MARKSMANSHIP spec at level range 66-67.

SPEC CARD REFERENCE: HUNTER_MM
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY
- Stats: Agility > Attack Power > Crit > Hit

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include ranged weapon) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3A-09: HUNTER SURVIVAL 66-67
Research TBC Classic (2.4.3) leveling gear for HUNTER SURVIVAL spec at level range 66-67.

SPEC CARD REFERENCE: HUNTER_SURV
- Armor: Mail preferred, Leather acceptable
- Weapons: RANGED PRIMARY
- Stats: Agility > Attack Power > Crit > Hit > Stamina

SEARCH LOCATIONS:
- Dungeons: Auchenai Crypts, Sethekk Halls, Old Hillsbrad Foothills
- Quests: Terokkar Forest (late), Nagrand, Blade's Edge Mountains
- Rep: Lower City Honored, Sha'tar Friendly, Keepers of Time Friendly

FIND EXACTLY: 3 Dungeon drops (include ranged weapon) + 3 Quest rewards

OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

**Post-Payload 7 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section
3. Update Batch Status: `3A | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 8

---

### PAYLOAD 8: BATCH 3B - Level 66-67 Rogue/Priest/Shaman (9 agents)

**Status:** NOT STARTED
**Pre-check:** Can run parallel with Payloads 7 and 9

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 3B-01: ROGUE ASSASSINATION 66-67
Research TBC Classic (2.4.3) leveling gear for ROGUE ASSASSINATION spec at level range 66-67.

SPEC: Leather ONLY, DUAL-WIELD DAGGERS (slow MH 1.7-1.8, fast OH 1.3-1.5)
STATS: Agility > Attack Power > Crit > Hit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops (include daggers) + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-02: ROGUE COMBAT 66-67
Research TBC Classic (2.4.3) leveling gear for ROGUE COMBAT spec at level range 66-67.

SPEC: Leather ONLY, DUAL-WIELD (slow MH sword/mace 2.4-2.8, fast OH 1.3-1.5)
STATS: Agility > Attack Power > Hit > Crit > Expertise
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops (include weapons) + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-03: ROGUE SUBTLETY 66-67
Research TBC Classic (2.4.3) leveling gear for ROGUE SUBTLETY spec at level range 66-67.

SPEC: Leather ONLY, DUAL-WIELD DAGGERS
STATS: Agility > Attack Power > Crit > Hit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops (include daggers) + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-04: PRIEST DISCIPLINE 66-67
Research TBC Classic (2.4.3) leveling gear for PRIEST DISCIPLINE spec at level range 66-67.

SPEC: Cloth ONLY, 1H Mace/Dagger + Off-hand OR Staff (+Healing)
STATS: +Healing > Intellect > Spirit > MP5
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-05: PRIEST HOLY 66-67
Research TBC Classic (2.4.3) leveling gear for PRIEST HOLY spec at level range 66-67.

SPEC: Cloth ONLY, 1H Mace/Dagger + Off-hand OR Staff (+Healing)
STATS: +Healing > Intellect > Spirit > MP5 > Spell Crit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-06: PRIEST SHADOW 66-67
Research TBC Classic (2.4.3) leveling gear for PRIEST SHADOW spec at level range 66-67.

SPEC: Cloth ONLY, 1H Mace/Dagger + Off-hand OR Staff (SPELL DAMAGE, NOT +Healing!)
STATS: Spell Damage > Intellect > Crit > Hit
CRITICAL: Shadow needs SPELL DAMAGE, not +Healing!
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-07: SHAMAN ELEMENTAL 66-67
Research TBC Classic (2.4.3) leveling gear for SHAMAN ELEMENTAL spec at level range 66-67.

SPEC: Mail preferred, 1H + Shield OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit
CANNOT USE: Swords, Polearms
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-08: SHAMAN ENHANCEMENT 66-67
Research TBC Classic (2.4.3) leveling gear for SHAMAN ENHANCEMENT spec at level range 66-67.

SPEC: Mail preferred, DUAL-WIELD BOTH weapons SLOW (2.6+ MH, 2.4+ OH)
STATS: Agility > Attack Power > Strength > Crit > Hit
CRITICAL: BOTH weapons SLOW for Windfury!
CANNOT USE: Swords, Polearms
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops (include 2 SLOW 1H) + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3B-09: SHAMAN RESTORATION 66-67
Research TBC Classic (2.4.3) leveling gear for SHAMAN RESTORATION spec at level range 66-67.

SPEC: Mail preferred, 1H + Shield OR Staff (+Healing)
STATS: +Healing > Intellect > MP5 > Spirit
CANNOT USE: Swords, Polearms
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

**Post-Payload 8 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section
3. Update Batch Status: `3B | COMPLETE | 9/9 | 54/54`
4. Proceed to PAYLOAD 9

---

### PAYLOAD 9: BATCH 3C - Level 66-67 Mage/Warlock/Druid (9 agents)

**Status:** NOT STARTED
**Pre-check:** Can run parallel with Payloads 7 and 8

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 3C-01: MAGE ARCANE 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit > Spirit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-02: MAGE FIRE 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit (Ignite!) > Hit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-03: MAGE FROST 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-04: WARLOCK AFFLICTION 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit > Spirit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-05: WARLOCK DEMONOLOGY 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage + Stamina)
STATS: Spell Damage > Stamina (pet scaling!) > Intellect > Hit
SPECIAL: Stamina MORE valuable for Demonic Knowledge
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-06: WARLOCK DESTRUCTION 66-67
SPEC: Cloth ONLY, 1H Sword/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-07: DRUID BALANCE 66-67
SPEC: Leather preferred (Cloth acceptable), 1H Mace/Dagger + Off-hand OR Staff (Spell Damage)
STATS: Spell Damage > Intellect > Crit > Hit
CANNOT USE: Swords, Axes, Polearms
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-08: DRUID FERAL COMBAT 66-67
SPEC: Leather ONLY (NEVER cloth), Staff/2H Mace/1H+OH (STATS ONLY - weapon DPS ignored!)
STATS: Agility > Attack Power > Feral Attack Power > Strength > Crit
CANNOT USE: Swords, Axes, Polearms
SPECIAL: Look for "Feral Attack Power" items! (Strength of the Clefthoof from Nagrand!)
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand (Strength of the Clefthoof!), Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards (include Clefthoof set if possible)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

```
AGENT 3C-09: DRUID RESTORATION 66-67
SPEC: Leather preferred (Cloth acceptable), 1H Mace/Dagger + Off-hand OR Staff (+Healing)
STATS: +Healing > Intellect > Spirit > MP5
CANNOT USE: Swords, Axes, Polearms
DUNGEONS: Auchenai Crypts, Sethekk Halls, Old Hillsbrad
QUESTS: Terokkar (late), Nagrand, Blade's Edge
FIND: 3 Dungeon drops + 3 Quest rewards
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source]
Use https://tbc.wowhead.com/
```

**Post-Payload 9 Actions:**
1. Collect all 9 agent outputs
2. Copy results into "Completed Research" section
3. Update Batch Status: `3C | COMPLETE | 9/9 | 54/54`
4. **CHECKPOINT: Level 66-67 Complete (162 items)**
5. **LEVELING SUBTOTAL: 486 items researched**
6. Proceed to PAYLOAD 10 (Pre-Heroic 68-70)

---

### PAYLOAD 10: BATCH 4A - Level 68-70 Pre-Heroic Warrior/Paladin/Hunter (9 agents)

**Status:** NOT STARTED
**Pre-check:** Payloads 1-9 complete (optional - can run in parallel)

**CRITICAL: NORMAL DUNGEON DROPS ONLY - NO HEROIC ITEMS**

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 4A-01: WARRIOR ARMS 68-70 PRE-HEROIC
Research TBC Classic (2.4.3) PRE-HEROIC gear for WARRIOR ARMS spec at level 68-70.

SPEC CARD REFERENCE: WARRIOR_ARMS
- Armor: Plate ONLY
- Weapons: 2H Sword, 2H Axe, 2H Mace, Polearm (SLOW 3.3-3.8 speed)
- Stats: Strength > Attack Power > Crit > Hit > Stamina
- AVOID: Intellect, Spirit, Spell Power, Defense

**CRITICAL: NORMAL MODE DUNGEONS ONLY - NO HEROIC DROPS**

SEARCH LOCATIONS:
- NORMAL Dungeons: Shadow Labyrinth, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
- Quests: Netherstorm (Dimensius chain), SMV (Cipher of Damnation), Shattrath
- Rep: Honor Hold/Cenarion/Lower City/Sha'tar/Keepers of Time (REVERED)

FIND EXACTLY:
- 4 NORMAL Dungeon drops (NO HEROICS - check item source carefully!)
- 3 Quest rewards from Netherstorm/SMV epic chains
- 2 Reputation rewards at REVERED standing
- Include Item Level for each item

OUTPUT FORMAT:
NORMAL DUNGEON DROPS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)] | [iLvl]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)] | [iLvl]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)] | [iLvl]
4. [ItemID] | [Name] | [Slot] | [Stats] | [Dungeon (Boss)] | [iLvl]

QUEST REWARDS:
1. [ItemID] | [Name] | [Slot] | [Stats] | [Quest (Zone)] | [iLvl]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Quest (Zone)] | [iLvl]
3. [ItemID] | [Name] | [Slot] | [Stats] | [Quest (Zone)] | [iLvl]

REPUTATION (REVERED):
1. [ItemID] | [Name] | [Slot] | [Stats] | [Faction] | [iLvl]
2. [ItemID] | [Name] | [Slot] | [Stats] | [Faction] | [iLvl]

Use https://tbc.wowhead.com/ - Filter by NORMAL dungeon drops only!
```

```
AGENT 4A-02: WARRIOR FURY 68-70 PRE-HEROIC
SPEC: Plate ONLY, DUAL-WIELD (MH slow 2.5-2.8, OH fast 1.5-1.8)
STATS: Strength > Attack Power > Crit > Hit > Haste
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV (Cipher chain), Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include 2 1H weapons if possible) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-03: WARRIOR PROTECTION 68-70 PRE-HEROIC
SPEC: Plate ONLY, 1H + Shield (fast 1.5-1.8 weapon, shield with Block/Sta)
STATS: Stamina > Defense Rating > Block Value/Rating > Parry > Dodge
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath (tank quest rewards)
REP: All 5 factions at REVERED (get Glyph of the Defender!)
FIND: 4 Normal dungeon (MUST include Shield!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-04: PALADIN HOLY 68-70 PRE-HEROIC
SPEC: Plate preferred (Mail acceptable), 1H Mace/Sword + Shield OR Caster weapon
STATS: +Healing > Intellect > MP5 > Spirit > Stamina
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath (healer quest rewards)
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-05: PALADIN PROTECTION 68-70 PRE-HEROIC
SPEC: Plate ONLY, 1H + Shield (Spell Power helps for threat!)
STATS: Stamina > Defense > Spell Power > Block Value/Rating > Parry
**NORMAL MODE ONLY - NO HEROIC DROPS**
SPECIAL: Paladin tanks WANT spell power for Holy Shield/Consecration threat!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED (Glyph of the Defender!)
FIND: 4 Normal dungeon (MUST include Shield!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-06: PALADIN RETRIBUTION 68-70 PRE-HEROIC
SPEC: Plate ONLY, 2H Sword/Axe/Mace (VERY SLOW 3.5-3.8 for Seal of Command!)
STATS: Strength > Attack Power > Crit > Hit > Spell Power (some helps SoC)
**NORMAL MODE ONLY - NO HEROIC DROPS**
CRITICAL: 2H weapon MUST be 3.5-3.8 speed for Seal of Command procs!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV (Cipher of Damnation 2H rewards!), Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include SLOW 2H!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-07: HUNTER BEAST MASTERY 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable), Ranged weapon (bow/gun/xbow), 2H or DW melee stat sticks
STATS: Agility > Attack Power > Crit > Hit > Intellect
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include ranged weapon!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-08: HUNTER MARKSMANSHIP 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable), Ranged weapon (bow/gun/xbow), melee stat sticks
STATS: Agility > Attack Power > Crit > Hit > Intellect
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include ranged weapon!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4A-09: HUNTER SURVIVAL 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable), Ranged weapon, melee stat sticks
STATS: Agility > Attack Power > Crit > Hit > Stamina (more survivable)
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include ranged weapon!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

**Post-Payload 10 Actions:**
1. Collect all 9 agent outputs
2. **VERIFY: NO HEROIC DROPS** - Check each item source
3. Copy results into "Completed Research" section under 68-70
4. Update Batch Status: `4A | COMPLETE | 9/9 | 81/81`
5. Proceed to PAYLOAD 11

---

### PAYLOAD 11: BATCH 4B - Level 68-70 Pre-Heroic Rogue/Priest/Shaman (9 agents)

**Status:** NOT STARTED
**Pre-check:** None required (can run parallel with 4A)

**CRITICAL: NORMAL DUNGEON DROPS ONLY - NO HEROIC ITEMS**

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 4B-01: ROGUE ASSASSINATION 68-70 PRE-HEROIC
SPEC: Leather ONLY, DAGGERS ONLY (for Mutilate/Backstab)
STATS: Agility > Attack Power > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
CRITICAL: MUST use daggers - no swords/maces/fists for this spec!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include 2 DAGGERS!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-02: ROGUE COMBAT 68-70 PRE-HEROIC
SPEC: Leather ONLY, 1H Swords/Maces/Fists preferred (Combat Potency with fast OH)
STATS: Agility > Attack Power > Hit > Crit > Expertise
**NORMAL MODE ONLY - NO HEROIC DROPS**
NOTE: Combat can use daggers but prefers swords/maces for Sword/Mace specialization
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include 2 1H weapons!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-03: ROGUE SUBTLETY 68-70 PRE-HEROIC
SPEC: Leather ONLY, Daggers preferred (Hemorrhage works with any 1H)
STATS: Agility > Attack Power > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-04: PRIEST DISCIPLINE 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H Mace/Dagger + Off-hand OR Staff
STATS: +Healing > Intellect > Spirit > MP5 > Stamina
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-05: PRIEST HOLY 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H Mace/Dagger + Off-hand OR Staff
STATS: +Healing > Intellect > Spirit > MP5
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-06: PRIEST SHADOW 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff with SPELL DAMAGE (NOT +Healing!)
STATS: SPELL DAMAGE > Intellect > Crit > Hit > Spirit
**NORMAL MODE ONLY - NO HEROIC DROPS**
CRITICAL: Shadow Priests want SPELL DAMAGE, not +Healing! Different stat!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-07: SHAMAN ELEMENTAL 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable for +dmg), 1H + Shield OR Staff (caster)
STATS: Spell Damage > Intellect > Crit > Hit > MP5
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-08: SHAMAN ENHANCEMENT 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable for AP/Agi), DUAL-WIELD 1H Axe/Mace/Fist
STATS: Agility > Attack Power > Strength > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
CRITICAL: BOTH weapons must be SLOW (2.6+ MH, 2.4+ OH) for Windfury procs!
FAST WEAPONS = BAD for Enhancement! Windfury has internal cooldown!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon (include 2 SLOW 1H weapons!) + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4B-09: SHAMAN RESTORATION 68-70 PRE-HEROIC
SPEC: Mail preferred (Leather acceptable), 1H + Shield OR Staff
STATS: +Healing > Intellect > MP5 > Spirit
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

**Post-Payload 11 Actions:**
1. Collect all 9 agent outputs
2. **VERIFY: NO HEROIC DROPS** - Check each item source
3. Copy results into "Completed Research" section under 68-70
4. Update Batch Status: `4B | COMPLETE | 9/9 | 81/81`
5. Proceed to PAYLOAD 12

---

### PAYLOAD 12: BATCH 4C - Level 68-70 Pre-Heroic Mage/Warlock/Druid (9 agents)

**Status:** NOT STARTED
**Pre-check:** None required (can run parallel with 4A/4B)

**CRITICAL: NORMAL DUNGEON DROPS ONLY - NO HEROIC ITEMS**

**Launch Command:** Run these 9 agents IN PARALLEL:

```
AGENT 4C-01: MAGE ARCANE 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit > Spirit (for regen)
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-02: MAGE FIRE 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-03: MAGE FROST 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-04: WARLOCK AFFLICTION 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit > Stamina
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-05: WARLOCK DEMONOLOGY 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Stamina > Intellect > Hit > Spirit
**NORMAL MODE ONLY - NO HEROIC DROPS**
NOTE: Demo locks value Stamina more for Demonic Sacrifice / Soul Link
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-06: WARLOCK DESTRUCTION 68-70 PRE-HEROIC
SPEC: Cloth ONLY, 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit
**NORMAL MODE ONLY - NO HEROIC DROPS**
NOTE: Destro wants max spell damage and crit for Shadow Bolt spam
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-07: DRUID BALANCE 68-70 PRE-HEROIC
SPEC: Leather ONLY (NEVER cloth), 1H + Off-hand OR Staff
STATS: Spell Damage > Intellect > Crit > Hit > Spirit
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-08: DRUID FERAL COMBAT 68-70 PRE-HEROIC
SPEC: Leather ONLY (NEVER cloth), Staff/2H Mace/1H+OH
STATS: Agility > Attack Power > Feral Attack Power > Strength > Crit
**NORMAL MODE ONLY - NO HEROIC DROPS**
CRITICAL: Weapon DPS is IGNORED in forms! Only STATS matter!
Look for items with "Feral Attack Power" bonus - these are BiS!
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

```
AGENT 4C-09: DRUID RESTORATION 68-70 PRE-HEROIC
SPEC: Leather preferred (Cloth acceptable for +Healing), 1H + Off-hand OR Staff
STATS: +Healing > Intellect > Spirit > MP5
**NORMAL MODE ONLY - NO HEROIC DROPS**
DUNGEONS: Shadow Lab, Steamvault, Shattered Halls, Mechanar, Botanica, Arcatraz, Black Morass
QUESTS: Netherstorm, SMV, Shattrath
REP: All 5 factions at REVERED
FIND: 4 Normal dungeon + 3 Quest + 2 Rep (REVERED)
OUTPUT: [ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
Use https://tbc.wowhead.com/
```

**Post-Payload 12 Actions:**
1. Collect all 9 agent outputs
2. **VERIFY: NO HEROIC DROPS** - Check each item source
3. Copy results into "Completed Research" section under 68-70
4. Update Batch Status: `4C | COMPLETE | 9/9 | 81/81`
5. **CHECKPOINT: Pre-Heroic 68-70 Complete (243 items)**
6. **GRAND TOTAL: 729 items researched**
7. Proceed to PAYLOAD 13 (Data Consolidation)

---

### PAYLOAD 13: DATA CONSOLIDATION

**Status:** Run after all 12 batches complete (1A-3C + 4A-4C)
**Pre-check:** All batch statuses show COMPLETE

**Actions:**
1. Verify all 729 items have been collected:
   - 486 leveling items (60-67)
   - 243 pre-heroic items (68-70)
2. Check for duplicate item IDs across all ranges
3. Verify slot coverage (not all items are same slot)
4. Flag any missing weapon types per spec requirements
5. Verify NO heroic items in 68-70 range

**Quality Check Template - Leveling (60-67):**
```
For each spec, verify:
[ ] Has 3 dungeon drops per level range (9 total)
[ ] Has 3 quest rewards per level range (9 total)
[ ] Weapons match spec requirements (daggers for Assassination, slow 2H for Arms, etc.)
[ ] Armor type is correct (Plate for Warriors, Leather for Rogues, etc.)
[ ] Stats align with spec priorities
[ ] Different slots covered (not 3 chest pieces)
```

**Quality Check Template - Pre-Heroic (68-70):**
```
For each spec, verify:
[ ] Has 4 NORMAL dungeon drops (NO HEROICS!)
[ ] Has 3 quest rewards from Netherstorm/SMV/Shattrath
[ ] Has 2 reputation rewards at REVERED
[ ] Item level included for each item
[ ] All items from correct source (verify on Wowhead)
```

---

### PAYLOAD 14: BUILD CONSTANTS.LUA

**Status:** Run after PAYLOAD 13 complete
**Pre-check:** All 729 items verified

**Template for conversion:**
```lua
-- Add to Core/Constants.lua after existing data

C.SPEC_LEVELING_GEAR = {
    ["WARRIOR"] = {
        [1] = { -- Arms
            ["60-62"] = {
                dungeons = {
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE" },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE" },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE" },
                },
                quests = {
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME" },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME" },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME" },
                },
            },
            ["63-65"] = { ... },
            ["66-67"] = { ... },
            ["68-70"] = {
                dungeons = {  -- 4 items, NORMAL MODE ONLY
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "SOURCE", ilvl = 115 },
                },
                quests = {  -- 3 items
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "QUEST_NAME", ilvl = 115 },
                },
                reputation = {  -- 2 items at REVERED
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "FACTION", ilvl = 115 },
                    { id = ITEM_ID, name = "ITEM_NAME", slot = "SLOT", stats = "STATS", source = "FACTION", ilvl = 115 },
                },
            },
        },
        [2] = { ... }, -- Fury
        [3] = { ... }, -- Protection
    },
    -- Repeat for all 9 classes
}

-- Gearscore thresholds for heroic recommendations
C.GEAR_SCORE_THRESHOLDS = {
    PRE_HEROIC = 95,      -- Below this: recommend normal dungeons
    HEROIC_READY = 95,    -- At or above: recommend heroic dungeons
    RAID_READY = 110,     -- At or above: recommend Karazhan
}

-- Helper functions
function C:GetSpecLevelingGear(class, specTab, levelRange)
    local classData = C.SPEC_LEVELING_GEAR[class]
    if not classData then return nil end
    local specData = classData[specTab]
    if not specData then return nil end
    return specData[levelRange]
end

function C:GetRecommendedGearPhase(avgItemLevel)
    if avgItemLevel >= C.GEAR_SCORE_THRESHOLDS.RAID_READY then
        return "RAID_READY"
    elseif avgItemLevel >= C.GEAR_SCORE_THRESHOLDS.HEROIC_READY then
        return "HEROIC_READY"
    else
        return "PRE_HEROIC"
    end
end
```

**Conversion Script Pattern - Leveling (60-67):**
For each agent output row:
```
[ItemID] | [Name] | [Slot] | [Stats] | [Source]
```
Convert to:
```lua
{ id = ItemID, name = "Name", slot = "Slot", stats = "Stats", source = "Source" },
```

**Conversion Script Pattern - Pre-Heroic (68-70):**
For each agent output row:
```
[ItemID] | [Name] | [Slot] | [Stats] | [Source] | [iLvl]
```
Convert to:
```lua
{ id = ItemID, name = "Name", slot = "Slot", stats = "Stats", source = "Source", ilvl = iLvl },
```

---

## BATCH STATUS TRACKING

### Leveling Batches (60-67)

| Batch | Level | Classes | Status | Agents | Items |
|-------|-------|---------|--------|--------|-------|
| 1A | 60-62 | War/Pal/Hunt | NOT STARTED | 0/9 | 0/54 |
| 1B | 60-62 | Rog/Pri/Sha | NOT STARTED | 0/9 | 0/54 |
| 1C | 60-62 | Mag/War/Dru | NOT STARTED | 0/9 | 0/54 |
| 2A | 63-65 | War/Pal/Hunt | NOT STARTED | 0/9 | 0/54 |
| 2B | 63-65 | Rog/Pri/Sha | NOT STARTED | 0/9 | 0/54 |
| 2C | 63-65 | Mag/War/Dru | NOT STARTED | 0/9 | 0/54 |
| 3A | 66-67 | War/Pal/Hunt | NOT STARTED | 0/9 | 0/54 |
| 3B | 66-67 | Rog/Pri/Sha | NOT STARTED | 0/9 | 0/54 |
| 3C | 66-67 | Mag/War/Dru | NOT STARTED | 0/9 | 0/54 |
| **Leveling Subtotal** | | | | **0/81** | **0/486** |

### Pre-Heroic Batches (68-70) - NORMAL DUNGEONS ONLY

| Batch | Level | Classes | Status | Agents | Items |
|-------|-------|---------|--------|--------|-------|
| 4A | 68-70 | War/Pal/Hunt | NOT STARTED | 0/9 | 0/81 |
| 4B | 68-70 | Rog/Pri/Sha | NOT STARTED | 0/9 | 0/81 |
| 4C | 68-70 | Mag/War/Dru | NOT STARTED | 0/9 | 0/81 |
| **Pre-Heroic Subtotal** | | | | **0/27** | **0/243** |

### GRAND TOTAL

| Category | Agents | Items |
|----------|--------|-------|
| Leveling (60-67) | 81 | 486 |
| Pre-Heroic (68-70) | 27 | 243 |
| **GRAND TOTAL** | **108** | **729** |

---

## Data Structure Target

After research, data will be structured in Constants.lua as:

```lua
C.SPEC_LEVELING_GEAR = {
    ["WARRIOR"] = {
        [1] = { -- Arms (Tab 1)
            ["60-62"] = {
                dungeons = {
                    { id = 27453, name = "Hellreaver", slot = "2H Weapon", stats = "+30 Str, +27 Sta, +25 Crit", source = "Hellfire Ramparts (Vazruden)" },
                    -- 2 more items
                },
                quests = {
                    { id = 28041, name = "Handguards of Precision", slot = "Hands", stats = "+18 Agi, +26 AP", source = "Weaken the Ramparts" },
                    -- 2 more items
                },
            },
            ["63-65"] = { ... },
            ["66-67"] = { ... },
        },
        [2] = { ... }, -- Fury
        [3] = { ... }, -- Protection
    },
    ["PALADIN"] = { ... },
    -- etc for all 9 classes
}
```

---

## Completed Research

(This section will be populated as agents complete their research)

---

### WARRIOR

#### Arms (Tab 1) - Plate DPS

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Fury (Tab 2) - Plate DPS (Dual-Wield)

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Protection (Tab 3) - Plate Tank

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### PALADIN

#### Holy (Tab 1) - Plate/Mail Healer

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Protection (Tab 2) - Plate Tank

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Retribution (Tab 3) - Plate DPS

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### HUNTER

#### Beast Mastery (Tab 1) - Mail/Leather Ranged

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Marksmanship (Tab 2) - Mail/Leather Ranged

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Survival (Tab 3) - Mail/Leather Ranged

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### ROGUE

#### Assassination (Tab 1) - Leather Melee

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Combat (Tab 2) - Leather Melee

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Subtlety (Tab 3) - Leather Melee

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### PRIEST

#### Discipline (Tab 1) - Cloth Healer

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Holy (Tab 2) - Cloth Healer

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Shadow (Tab 3) - Cloth Caster DPS

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### SHAMAN

#### Elemental (Tab 1) - Mail/Leather Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Enhancement (Tab 2) - Mail/Leather Melee

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Restoration (Tab 3) - Mail/Leather Healer

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### MAGE

#### Arcane (Tab 1) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Fire (Tab 2) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Frost (Tab 3) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### WARLOCK

#### Affliction (Tab 1) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Demonology (Tab 2) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Destruction (Tab 3) - Cloth Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

### DRUID

#### Balance (Tab 1) - Leather Caster

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Feral Combat (Tab 2) - Leather Melee/Tank

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

#### Restoration (Tab 3) - Leather Healer

**Level 60-62:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 63-65:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

**Level 66-67:**
| Source | Item ID | Item Name | Slot | Stats | Location |
|--------|---------|-----------|------|-------|----------|
| Dungeon | | | | | |
| Dungeon | | | | | |
| Dungeon | | | | | |
| Quest | | | | | |
| Quest | | | | | |
| Quest | | | | | |

---

## Notes

### Spec-Specific Considerations

1. **Fury Warrior** - Prioritize dual-wield weapons; may need 2 different 1H weapons
2. **Enhancement Shaman** - Can use leather until 40, then mail; dual-wield unlocked at level 40
3. **Feral Druid** - Same gear works for both Cat (DPS) and Bear (Tank) while leveling
4. **Holy/Disc Priest** - Gear is largely interchangeable; focus on +Healing
5. **Shadow Priest** - Unique: wants Spell Damage, not +Healing
6. **Elemental vs Resto Shaman** - Different stats (Spell Damage vs +Healing)
7. **Demonology Warlock** - May want more Stamina than other lock specs
8. **Protection Paladin** - Unique: wants Spell Power for threat, not just Stamina

### Item Selection Criteria

1. **Obtainable while leveling** - No raid drops, no 70 heroics
2. **Appropriate armor type** - Cloth for casters, leather for rogues/druids, etc.
3. **Stat-appropriate** - Primary and secondary stats for the spec
4. **Diverse slots** - Try to cover different gear slots across recommendations
5. **Realistic availability** - Quest rewards > rare dungeon drops

---

## Changelog

### 2026-01-23
- Created comprehensive spec-based planning document
- Defined 90 research tasks (30 specs × 3 level ranges)
- Established agent research plan for parallel data gathering
- Set up tracking for research completion status
