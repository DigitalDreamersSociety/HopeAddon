# Reputation Tab hoverData - Future Payloads

## Overview

This document contains the remaining payloads to add enhanced tooltips (`hoverData`) to all classes in `CLASS_SPEC_LOOT_HOTLIST`. The WARRIOR class is already complete (Phase 60).

**Total Remaining Work:** 8 classes × 3 specs × 3 rep items = 72 items

---

## Completed

| Class | Items | Status |
|-------|-------|--------|
| WARRIOR | 9 | ✅ COMPLETE |

---

## Priority Order

Based on popularity and role diversity:

| Priority | Class | Specs | Unique Items | Est. Time |
|----------|-------|-------|--------------|-----------|
| 1 | PALADIN | Holy, Protection, Retribution | 7 unique | 45 min |
| 2 | DRUID | Balance, Feral, Restoration | 7 unique | 45 min |
| 3 | PRIEST | Discipline, Holy, Shadow | 6 unique | 40 min |
| 4 | SHAMAN | Elemental, Enhancement, Restoration | 7 unique | 45 min |
| 5 | MAGE | Arcane, Fire, Frost | 3 unique | 25 min |
| 6 | WARLOCK | Affliction, Demonology, Destruction | 3 unique | 25 min |
| 7 | HUNTER | Beast Mastery, Marksmanship, Survival | 3 unique | 25 min |
| 8 | ROGUE | Assassination, Combat, Subtlety | 3 unique | 25 min |

**Note:** Many items are shared across specs. "Unique items" counts distinct items needing hoverData.

---

## PAYLOAD 3: PALADIN (Lines 4296-4351)

### Tab 1: Holy (Healer) - Lines 4300-4302

**Item 1: Gavel of Pure Light** (Line 4300)
```lua
{ itemId = 29175, name = "Gavel of Pure Light", ... faction = "The Sha'tar", standing = 8,
    hoverData = {
        repSources = {
            "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill",
            "Shattered Sun Offensive dailies (once available)",
            "Aldor/Scryer turn-ins also grant Sha'tar rep",
        },
        statPriority = {
            "Best pre-raid healing weapon for Paladins",
            "+225 Healing is massive for Holy Light spam",
            "Good stamina for survival",
        },
        tips = {
            "Long grind - start TK dungeons early",
            "Botanica is fastest rep (many mobs)",
            "Buy from Almaador in Sha'tar base (Shattrath)",
        },
        alternatives = {
            "Light's Justice (Aldor Exalted)",
            "Crystalheart Pulse-Staff (H Arc - 2H)",
            "The Essence Focuser (H Mech)",
        },
    },
},
```

**Item 2: Lower City Prayerbook** (Line 4301)
```lua
{ itemId = 30841, name = "Lower City Prayerbook", ... faction = "Lower City", standing = 7,
    hoverData = {
        repSources = {
            "Auchenai Crypts/Sethekk Halls (10 rep/kill)",
            "Shadow Labyrinth (12-25 rep/kill)",
            "Auchindoun quests (~6k rep total)",
        },
        statPriority = {
            "+70 Healing passive, excellent for any healer",
            "Reduces mana cost of Prayer of Healing",
            "Solid until Badge of Justice trinkets",
        },
        tips = {
            "Only need Revered (easy grind)",
            "Shadow Lab is best rep but harder",
            "Buy from Nakodu in Lower City (Shattrath)",
        },
        alternatives = {
            "Scarab of the Infinite Cycle (H BM)",
            "Bangle of Endless Blessings (H Arc)",
            "Essence of the Martyr (41 Badges)",
        },
    },
},
```

**Item 3: Light's Justice** (Line 4302)
```lua
{ itemId = 29181, name = "Light's Justice", ... faction = "The Aldor", standing = 8,
    hoverData = {
        repSources = {
            "Turn in Marks of Kil'jaeden (25 rep each, until Honored)",
            "Turn in Marks of Sargeras (25 rep, Honored+)",
            "Turn in Fel Armaments (350 rep each)",
        },
        statPriority = {
            "+264 Healing - highest pre-raid weapon",
            "+10 MP5 for sustained healing",
            "Slightly better than Gavel for pure output",
        },
        tips = {
            "Expensive grind - need 1000s of turn-ins",
            "Farm Marks at Shadow Council camps (Nagrand)",
            "Buy from Quartermaster Endarin (Aldor Rise)",
        },
        alternatives = {
            "Gavel of Pure Light (Sha'tar Exalted)",
            "Crystalheart Pulse-Staff (H Arc - 2H)",
            "Hammer of the Penitent (H SH)",
        },
    },
},
```

### Tab 2: Protection (Tank) - Lines 4318-4320

**Item 1: Bladespire Warbands** (Line 4318)
- SAME AS WARRIOR Prot - copy hoverData

**Item 2: Veteran's Plate Belt** (Line 4319)
- SAME AS WARRIOR Prot - copy hoverData

**Item 3: Libram of Repentance** (Line 4320)
```lua
{ itemId = 29183, name = "Libram of Repentance", ... faction = "The Sha'tar", standing = 8,
    hoverData = {
        repSources = {
            "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill",
            "Shattered Sun Offensive dailies (once available)",
            "Aldor/Scryer turn-ins also grant Sha'tar rep",
        },
        statPriority = {
            "+35 Block Value - huge for Paladin tanks",
            "Increases Holy Shield and Shield of Righteousness",
            "Best tanking libram until T5",
        },
        tips = {
            "Same grind as Gavel of Pure Light",
            "Botanica spam is most efficient",
            "Buy from Almaador in Sha'tar base",
        },
        alternatives = {
            "Libram of Saints Departed (25 Badges)",
            "Libram of Divine Purpose (Kara trash)",
            "Libram of Truth (SL quest)",
        },
    },
},
```

### Tab 3: Retribution (Melee DPS) - Lines 4336-4338

**Item 1: Haramad's Bargain** (Line 4336)
- SAME AS WARRIOR Arms - copy hoverData

**Item 2: Marksman's Bow** (Line 4337)
- SAME AS WARRIOR Arms - copy hoverData (note: Paladins can't use bows - this is a data error but keep consistent)

**Item 3: Libram of Avengement** (Line 4338)
```lua
{ itemId = 29182, name = "Libram of Avengement", ... faction = "The Scryers", standing = 7,
    hoverData = {
        repSources = {
            "Turn in Firewing Signets (25 rep each, until Honored)",
            "Turn in Sunfury Signets (25 rep, Honored+)",
            "Turn in Arcane Tomes (350 rep each)",
        },
        statPriority = {
            "Increases Crusader Strike damage significantly",
            "Core Retribution libram until T5",
            "Only need Revered (reasonable grind)",
        },
        tips = {
            "Farm Signets at Firewing Point (Terokkar)",
            "Sunfury camps in Netherstorm for Honored+",
            "Buy from Quartermaster Enuril (Scryer's Tier)",
        },
        alternatives = {
            "Libram of Divine Purpose (Kara trash)",
            "Libram of Zeal (crafted)",
            "Tome of the Lightbringer (BM quest)",
        },
    },
},
```

---

## PAYLOAD 4: DRUID (Lines 4414-4469)

### Tab 1: Balance (Caster DPS) - Lines 4418-4420

**Item 1: Continuum Blade** (Line 4418)
```lua
{ itemId = 29185, name = "Continuum Blade", ... faction = "Keepers of Time", standing = 7,
    hoverData = {
        repSources = {
            "Old Hillsbrad Foothills (8 rep/kill)",
            "Black Morass (8 Normal, 25 Heroic rep/kill)",
            "Caverns of Time attunement questline",
        },
        statPriority = {
            "+190 Spell Power - solid caster dagger",
            "+8 Hit Rating helps reach spell hit cap (16%)",
            "Good for Balance until Kara weapons",
        },
        tips = {
            "Only need Revered (easy grind)",
            "Black Morass spam at 70 is fastest",
            "Buy from Alurmi in Caverns of Time",
        },
        alternatives = {
            "Gladiator's Spellblade (Arena)",
            "Nathrezim Mindblade (Prince - Kara)",
            "Scryer's Blade of Focus (BoE)",
        },
    },
},
```

**Item 2: Shapeshifter's Signet** (Line 4419)
```lua
{ itemId = 30834, name = "Shapeshifter's Signet", ... faction = "Lower City", standing = 8,
    hoverData = {
        repSources = {
            "Auchenai Crypts/Sethekk Halls (10 rep/kill)",
            "Shadow Labyrinth (12-25 rep/kill)",
            "Auchindoun quests (~6k rep total)",
        },
        statPriority = {
            "+23 Spell Hit - huge for reaching cap",
            "+24 Stamina for survivability",
            "BiS caster ring until Kara",
        },
        tips = {
            "Long grind to Exalted - start early",
            "Shadow Lab is best but harder",
            "Buy from Nakodu in Lower City",
        },
        alternatives = {
            "Sparking Arcanite Ring (BoE craft)",
            "Ashyen's Gift (CE Exalted)",
            "Band of the Guardian (CoT quest)",
        },
    },
},
```

**Item 3: Idol of the Raven Goddess** (Line 4420)
```lua
{ itemId = 29172, name = "Idol of the Raven Goddess", ... faction = "Cenarion Expedition", standing = 8,
    hoverData = {
        repSources = {
            "Coilfang dungeons (SP, UB, SV) - 10-25 rep/kill",
            "Unidentified Plant Parts (250 rep/10, until Honored)",
            "Coilfang Armaments (75 rep each, Honored+)",
        },
        statPriority = {
            "Increases Moonfire and Wrath damage",
            "Best Balance idol for raiding",
            "Huge DPS increase for DoT uptime",
        },
        tips = {
            "Long grind - collect Plant Parts while leveling",
            "Steamvault spam at 70 is fastest",
            "Buy from Fedryen Swiftspear in Zangarmarsh",
        },
        alternatives = {
            "Ivory Idol of the Moongoddess (SP Normal)",
            "Idol of the Avenger (25 Badges)",
            "Harold's Rejuvenating Broach (Kara)",
        },
    },
},
```

### Tab 2: Feral (Tank - Bear) - Lines 4436-4438

**Item 1: Earthwarden** (Line 4436)
```lua
{ itemId = 29171, name = "Earthwarden", ... faction = "Cenarion Expedition", standing = 8,
    hoverData = {
        repSources = {
            "Coilfang dungeons (SP, UB, SV) - 10-25 rep/kill",
            "Unidentified Plant Parts (250 rep/10, until Honored)",
            "Coilfang Armaments (75 rep each, Honored+)",
        },
        statPriority = {
            "Best pre-raid Feral tank weapon - no contest",
            "+556 AP in Bear form is massive",
            "+24 Defense helps reach uncrittable",
        },
        tips = {
            "MUST HAVE for Feral tanks - prioritize this grind",
            "Steamvault spam at 70",
            "Buy from Fedryen Swiftspear in Zangarmarsh",
        },
        alternatives = {
            "Braxxis' Staff of Slumber (H UB - worse)",
            "Staff of Beasts (Kara - side grade)",
            "Nothing else compares pre-raid",
        },
    },
},
```

**Item 2: Windcaller's Orb** (Line 4437)
```lua
{ itemId = 29170, name = "Windcaller's Orb", ... faction = "Cenarion Expedition", standing = 7,
    hoverData = {
        repSources = {
            "Coilfang dungeons (SP, UB, SV) - 10-25 rep/kill",
            "Unidentified Plant Parts (250 rep/10, until Honored)",
            "Zangarmarsh/Blade's Edge CE quests",
        },
        statPriority = {
            "+27 Stamina for Bear form EH",
            "+18 Int/Spi for caster form utility",
            "Decent stat stick off-hand",
        },
        tips = {
            "Only need Revered - get on way to Earthwarden",
            "Same rep grind as Earthwarden",
            "Buy from Fedryen Swiftspear",
        },
        alternatives = {
            "Lamp of Peaceful Repose (H Bot)",
            "Netherwing Spiritualist's Charm (quest)",
            "Khorium Locket (JC craft)",
        },
    },
},
```

**Item 3: Idol of Ursoc** (Line 4438)
```lua
{ itemId = 29173, name = "Idol of Ursoc", ... faction = "Cenarion Expedition", standing = 7,
    hoverData = {
        repSources = {
            "Coilfang dungeons (SP, UB, SV) - 10-25 rep/kill",
            "Unidentified Plant Parts (250 rep/10, until Honored)",
            "Zangarmarsh/Blade's Edge CE quests",
        },
        statPriority = {
            "+54 Maul damage - core Bear tanking ability",
            "Significant threat increase",
            "Best Feral tank idol pre-raid",
        },
        tips = {
            "Only need Revered - easy",
            "Get while grinding for Earthwarden",
            "Buy from Fedryen Swiftspear",
        },
        alternatives = {
            "Idol of Brutality (25 Badges)",
            "Idol of the Wild (quest)",
            "Idol of Ferocity (MC - if you have it)",
        },
    },
},
```

### Tab 3: Restoration (Healer) - Lines 4454-4456

**Item 1: Gavel of Pure Light** (Line 4454)
- SAME AS PALADIN Holy - copy hoverData

**Item 2: Lower City Prayerbook** (Line 4455)
- SAME AS PALADIN Holy - copy hoverData

**Item 3: Windcaller's Orb** (Line 4456)
- SAME AS DRUID Feral - copy hoverData

---

## PAYLOAD 5: PRIEST (Lines 4355-4410)

### Tab 1: Discipline (Healer) - Lines 4359-4361

**Item 1: Gavel of Pure Light** (Line 4359)
- SAME AS PALADIN Holy - copy hoverData

**Item 2: Lower City Prayerbook** (Line 4360)
- SAME AS PALADIN Holy - copy hoverData

**Item 3: Xi'ri's Gift** (Line 4361)
```lua
{ itemId = 29179, name = "Xi'ri's Gift", ... faction = "The Sha'tar", standing = 7,
    hoverData = {
        repSources = {
            "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill",
            "Aldor/Scryer turn-ins also grant Sha'tar rep",
            "TK dungeon quests give good rep",
        },
        statPriority = {
            "+35 Healing on a neck slot",
            "+22 Stamina for survivability",
            "Solid pre-raid healer necklace",
        },
        tips = {
            "Only need Revered - easy grind",
            "Get while doing TK attunement",
            "Buy from Almaador in Sha'tar base",
        },
        alternatives = {
            "Necklace of Eternal Hope (H SH)",
            "Teeth of Gruul (Gruul's Lair)",
            "Brooch of Heightened Potential (Kara)",
        },
    },
},
```

### Tab 2: Holy (Healer) - Lines 4377-4379

- ALL THREE SAME AS Tab 1 - copy hoverData

### Tab 3: Shadow (Caster DPS) - Lines 4395-4397

**Item 1: Continuum Blade** (Line 4395)
- SAME AS DRUID Balance - copy hoverData

**Item 2: Shapeshifter's Signet** (Line 4396)
- SAME AS DRUID Balance - copy hoverData

**Item 3: Xi'ri's Gift** (Line 4397)
- SAME AS Tab 1 but note stats show +35 SP instead of Healing

---

## PAYLOAD 6: SHAMAN (Lines 4473-4528)

### Tab 1: Elemental (Caster DPS) - Lines 4477-4479

**Item 1: Continuum Blade** (Line 4477)
- SAME AS DRUID Balance - copy hoverData

**Item 2: Shapeshifter's Signet** (Line 4478)
- SAME AS DRUID Balance - copy hoverData

**Item 3: Totem of the Void** (Line 4479)
```lua
{ itemId = 29389, name = "Totem of the Void", ... faction = "Lower City", standing = 7,
    hoverData = {
        repSources = {
            "Auchenai Crypts/Sethekk Halls (10 rep/kill)",
            "Shadow Labyrinth (12-25 rep/kill)",
            "Auchindoun quests (~6k rep total)",
        },
        statPriority = {
            "+55 Lightning Bolt damage",
            "Core Elemental totem for raids",
            "Significant DPS increase",
        },
        tips = {
            "Only need Revered - easy grind",
            "Get while doing Auchenai dungeons",
            "Buy from Nakodu in Lower City",
        },
        alternatives = {
            "Totem of the Pulsing Earth (25 Badges)",
            "Totem of Spontaneous Regrowth (SSC)",
            "Totem of Lightning (quest)",
        },
    },
},
```

### Tab 2: Enhancement (Melee DPS) - Lines 4495-4497

**Item 1: Haramad's Bargain** (Line 4495)
- SAME AS WARRIOR Arms - copy hoverData

**Item 2 & 3:** Check actual items in Constants.lua and add appropriate hoverData

### Tab 3: Restoration (Healer) - Lines 4513-4515

**Item 1: Gavel of Pure Light**
- SAME AS PALADIN Holy - copy hoverData

**Item 2: Lower City Prayerbook**
- SAME AS PALADIN Holy - copy hoverData

**Item 3:** Check actual item

---

## PAYLOAD 7: MAGE (Lines 4532-4587)

All 3 specs (Arcane, Fire, Frost) use identical caster items:

**Common Items:**
- Continuum Blade - SAME AS DRUID Balance
- Shapeshifter's Signet - SAME AS DRUID Balance
- One spec-specific item per tab

---

## PAYLOAD 8: WARLOCK (Lines 4591-4646)

All 3 specs (Affliction, Demonology, Destruction) use identical caster items:
- Similar to MAGE - share hoverData

---

## PAYLOAD 9: HUNTER (Lines 4650-4705)

All 3 specs (BM, MM, Survival) use identical ranged DPS items:
- Likely share items with WARRIOR/melee for some (Haramad's Bargain)
- Hunter-specific rep items need unique hoverData

---

## PAYLOAD 10: ROGUE (Lines 4709-4764)

All 3 specs (Assassination, Combat, Subtlety) use identical melee DPS items:
- Likely share many items with WARRIOR Arms/Fury
- Rogue-specific items need unique hoverData

---

## Implementation Notes

### Shared Item Reference Table

Many items repeat across classes. Create once, copy to all:

| Item | Classes Using | hoverData Location |
|------|---------------|-------------------|
| Haramad's Bargain | WARRIOR, PALADIN Ret, SHAMAN Enh, ROGUE, HUNTER | WARRIOR Arms |
| Marksman's Bow | WARRIOR, HUNTER | WARRIOR Arms |
| Bloodlust Brooch | WARRIOR, ROGUE, HUNTER | WARRIOR Arms |
| Bladespire Warbands | WARRIOR Prot, PALADIN Prot | WARRIOR Prot |
| Veteran's Plate Belt | WARRIOR Prot, PALADIN Prot | WARRIOR Prot |
| Gavel of Pure Light | PALADIN Holy, PRIEST, DRUID Resto, SHAMAN Resto | PALADIN Holy |
| Lower City Prayerbook | PALADIN Holy, PRIEST, DRUID Resto, SHAMAN Resto | PALADIN Holy |
| Continuum Blade | DRUID Balance, PRIEST Shadow, SHAMAN Ele, MAGE, WARLOCK | DRUID Balance |
| Shapeshifter's Signet | DRUID Balance, PRIEST Shadow, SHAMAN Ele, MAGE, WARLOCK | DRUID Balance |

### Execution Order

1. **PALADIN** - 7 unique items (2 shared with Warrior, 2 shared healer items)
2. **DRUID** - 7 unique items (establishes caster/healer shared items)
3. **PRIEST** - 6 unique items (mostly shared from above)
4. **SHAMAN** - 7 unique items (mix of melee/caster/healer)
5. **MAGE** - 3 unique items (pure caster, shares most)
6. **WARLOCK** - 3 unique items (pure caster, shares most)
7. **HUNTER** - 3 unique items (shares melee items)
8. **ROGUE** - 3 unique items (shares melee items)

### Time Estimates

| Payload | Class | New hoverData | Copy Existing | Est. Time |
|---------|-------|---------------|---------------|-----------|
| 3 | PALADIN | 4 | 5 | 45 min |
| 4 | DRUID | 5 | 4 | 50 min |
| 5 | PRIEST | 1 | 8 | 20 min |
| 6 | SHAMAN | 2 | 7 | 30 min |
| 7 | MAGE | 1 | 8 | 15 min |
| 8 | WARLOCK | 1 | 8 | 15 min |
| 9 | HUNTER | 2 | 7 | 25 min |
| 10 | ROGUE | 1 | 8 | 15 min |
| **Total** | | **17** | **55** | **~3.5 hours** |

---

## Verification Checklist

After each payload:
- [ ] No Lua syntax errors (balanced braces, commas)
- [ ] Items without hoverData still show basic tooltip
- [ ] Items WITH hoverData show all 4 sections
- [ ] Colors match TBC theme (green, purple, orange, blue)
- [ ] Word wrap working on long lines
- [ ] Hover sound still plays

---

## Quick Copy Templates

### Healer Item Template
```lua
hoverData = {
    repSources = {
        "Dungeon name (rep/kill)",
        "Turn-in item (rep amount)",
        "Quest chain (~total rep)",
    },
    statPriority = {
        "Main stat benefit",
        "Secondary stat benefit",
        "Comparison to alternatives",
    },
    tips = {
        "Best farming method",
        "When to start grinding",
        "Vendor location",
    },
    alternatives = {
        "Alternative 1 (source)",
        "Alternative 2 (source)",
        "Alternative 3 (source)",
    },
},
```

### Melee DPS Item Template
```lua
hoverData = {
    repSources = {
        "Dungeon name (rep/kill)",
        "Best rep/hour method",
        "Quest rep total",
    },
    statPriority = {
        "Why this stat matters for DPS",
        "Hit cap consideration",
        "Comparison to raid gear",
    },
    tips = {
        "Fastest grind method",
        "Priority relative to other rep",
        "Vendor location",
    },
    alternatives = {
        "Pre-raid alternative",
        "Dungeon drop alternative",
        "Crafted alternative",
    },
},
```

### Tank Item Template
```lua
hoverData = {
    repSources = {
        "Dungeon name (rep/kill)",
        "Best rep/hour method",
        "Quest rep total",
    },
    statPriority = {
        "Defense/avoidance benefit",
        "Stamina/EH benefit",
        "Threat generation if applicable",
    },
    tips = {
        "Priority for tanks",
        "Grind method",
        "Vendor location",
    },
    alternatives = {
        "Dungeon alternative",
        "Crafted alternative",
        "Badge alternative",
    },
},
```
