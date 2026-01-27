-- ArmoryBisData.lua
-- BiS gear database organized by phase and spec
-- Auto-generated from Wowhead TBC Classic guides

-- Use global HopeAddon table (consistent with Constants.lua)
HopeAddon = HopeAddon or {}
HopeAddon.Constants = HopeAddon.Constants or {}
local C = HopeAddon.Constants

-- Issue #71.3: Module-level cache for BiS lookup (prevents Constants table mutation)
local bisLookupCache = nil

-----------------------------------------------------------
-- ARMORY SPECS: Maps class to available specs with guide keys
-----------------------------------------------------------
C.ARMORY_SPECS = {
    WARRIOR = {
        { id = "arms", name = "Arms", role = "melee_dps", guideKey = "warrior-dps" },
        { id = "fury", name = "Fury", role = "melee_dps", guideKey = "warrior-dps" },
        { id = "protection", name = "Protection", role = "tank", guideKey = "protection-warrior-tank" },
    },
    PALADIN = {
        { id = "holy", name = "Holy", role = "healer", guideKey = "holy-paladin-healer" },
        { id = "protection", name = "Protection", role = "tank", guideKey = "paladin-tank" },
        { id = "retribution", name = "Retribution", role = "melee_dps", guideKey = "retribution-paladin-dps" },
    },
    HUNTER = {
        { id = "beastmastery", name = "Beast Mastery", role = "ranged_dps", guideKey = "hunter-dps" },
        { id = "marksmanship", name = "Marksmanship", role = "ranged_dps", guideKey = "hunter-dps" },
        { id = "survival", name = "Survival", role = "ranged_dps", guideKey = "hunter-dps" },
    },
    ROGUE = {
        { id = "assassination", name = "Assassination", role = "melee_dps", guideKey = "rogue-dps" },
        { id = "combat", name = "Combat", role = "melee_dps", guideKey = "rogue-dps" },
        { id = "subtlety", name = "Subtlety", role = "melee_dps", guideKey = "rogue-dps" },
    },
    PRIEST = {
        { id = "discipline", name = "Discipline", role = "healer", guideKey = "priest-healer" },
        { id = "holy", name = "Holy", role = "healer", guideKey = "priest-healer" },
        { id = "shadow", name = "Shadow", role = "caster_dps", guideKey = "shadow-priest-dps" },
    },
    SHAMAN = {
        { id = "elemental", name = "Elemental", role = "caster_dps", guideKey = "elemental-shaman-dps" },
        { id = "enhancement", name = "Enhancement", role = "melee_dps", guideKey = "enhancement-shaman-dps" },
        { id = "restoration", name = "Restoration", role = "healer", guideKey = "shaman-healer" },
    },
    MAGE = {
        { id = "arcane", name = "Arcane", role = "caster_dps", guideKey = "mage-dps" },
        { id = "fire", name = "Fire", role = "caster_dps", guideKey = "mage-dps" },
        { id = "frost", name = "Frost", role = "caster_dps", guideKey = "mage-dps" },
    },
    WARLOCK = {
        { id = "affliction", name = "Affliction", role = "caster_dps", guideKey = "warlock-dps" },
        { id = "demonology", name = "Demonology", role = "caster_dps", guideKey = "warlock-dps" },
        { id = "destruction", name = "Destruction", role = "caster_dps", guideKey = "warlock-dps" },
    },
    DRUID = {
        { id = "balance", name = "Balance", role = "caster_dps", guideKey = "balance-druid-dps" },
        { id = "feral_cat", name = "Feral (Cat)", role = "melee_dps", guideKey = "feral-druid-dps" },
        { id = "feral_bear", name = "Feral (Bear)", role = "tank", guideKey = "feral-druid-tank" },
        { id = "restoration", name = "Restoration", role = "healer", guideKey = "druid-healer" },
    },
}

-----------------------------------------------------------
-- ARMORY PHASES: Extended labels for spec database
-- NOTE: Main ARMORY_PHASES definition is in Constants.lua
-- This just adds spec-database-specific labels if needed
-----------------------------------------------------------
-- (Removed duplicate definition - use C.ARMORY_PHASES from Constants.lua)

-----------------------------------------------------------
-- SPEC BiS DATABASE
-- Structure: [phase][guideKey][slot] = { bis = {...}, alts = {...} }
-----------------------------------------------------------
C.ARMORY_SPEC_BIS_DATABASE = {
    -------------------------------------------------
    -- PHASE 1: Pre-Raid + Karazhan/Gruul/Mag
    -------------------------------------------------
    [1] = {
        -------------------------------------------
        -- WARRIOR DPS (Arms/Fury)
        -------------------------------------------
        ["warrior-dps"] = {
            head = {
                bis = { id = 29021, name = "Warbringer Battle-Helm", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32087, name = "Mask of the Deceiver", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29023, name = "Warbringer Shoulderplates", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 27434, name = "Mantle of Perenolde", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28582, name = "Red Riding Hood's Cloak", source = "Opera Event", sourceType = "raid" },
                    { id = 27878, name = "Auchenai Death Shroud", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            chest = {
                bis = { id = 29019, name = "Warbringer Breastplate", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28597, name = "Panzar'Thar Breastplate", source = "Nightbane", sourceType = "raid" },
                    { id = 28403, name = "Doomplate Chestguard", source = "Harbinger Skyriss", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 28795, name = "Bladespire Warbands", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 23537, name = "Black Felsteel Bracers", source = "Blacksmithing", sourceType = "crafted" },
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quests", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 30644, name = "Grips of Deftness", source = "Karazhan Trash", sourceType = "raid" },
                alts = {
                    { id = 29020, name = "Warbringer Handguards", source = "The Curator", sourceType = "raid" },
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                    { id = 27911, name = "Dunewind Sash", source = "Nexus-Prince Shaffar", sourceType = "dungeon" },
                }
            },
            legs = {
                bis = { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29022, name = "Warbringer Greaves", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30257, name = "Shattrath Leggings", source = "Quest", sourceType = "quest" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 25686, name = "Fel Leather Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29379, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28323, name = "Ring of Umbral Doom", source = "Thorngrin the Tender", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28438, name = "Dragonmaw", source = "Master Hammersmith", sourceType = "crafted" },
                alts = {
                    { id = 28773, name = "Gorehowl", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28572, name = "Despair", source = "Opera Event", sourceType = "raid" },
                    { id = 28767, name = "The Decapitator", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28429, name = "Lionheart Champion", source = "Master Swordsmith", sourceType = "crafted" },
                }
            },
            offhand = {
                bis = { id = 28657, name = "Fool's Bane", source = "Terestian Illhoof", sourceType = "raid" },
                alts = {
                    { id = 27872, name = "The Harvester of Souls", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 28295, name = "Gladiator's Slicer", source = "Arena Season 1", sourceType = "pvp" },
                }
            },
            ranged = {
                bis = { id = 30724, name = "Barrel-Blade Longrifle", source = "Doomwalker", sourceType = "world" },
                alts = {
                    { id = 28504, name = "Steelhawk Crossbow", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29115, name = "Consortium Blaster", source = "Consortium Exalted", sourceType = "reputation" },
                }
            },
        },

        -------------------------------------------
        -- PROTECTION WARRIOR
        -------------------------------------------
        ["protection-warrior-tank"] = {
            head = {
                bis = { id = 29011, name = "Warbringer Greathelm", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32083, name = "Faceguard of Determination", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 23519, name = "Felsteel Helm", source = "Blacksmithing", sourceType = "crafted" },
                }
            },
            neck = {
                bis = { id = 28516, name = "Barbed Choker of Discipline", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 29386, name = "Necklace of the Juggernaut", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 27792, name = "Mark of the Ravenguard", source = "Anzu", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29016, name = "Warbringer Shoulderguards", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27739, name = "Spaulders of the Righteous", source = "Warp Splinter", sourceType = "heroic" },
                    { id = 27847, name = "Fanblade Pauldrons", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28660, name = "Gilded Thorium Cloak", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 29385, name = "Slikk's Cloak of Placation", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 27804, name = "Devilshark Cape", source = "Warlord Kalithresh", sourceType = "heroic" },
                }
            },
            chest = {
                bis = { id = 29012, name = "Warbringer Chestguard", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 27440, name = "Jade-Skull Breastplate", source = "Swamplord Musel'ek", sourceType = "heroic" },
                    { id = 23522, name = "Ragesteel Breastplate", source = "Blacksmithing", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 23538, name = "Bracers of the Green Fortress", source = "Blacksmithing", sourceType = "crafted" },
                alts = {
                    { id = 29463, name = "Sha'tari Wrought Armguards", source = "Sha'tar Exalted", sourceType = "reputation" },
                    { id = 28502, name = "Vambraces of Courage", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            hands = {
                bis = { id = 30741, name = "Topaz-Studded Battlegrips", source = "Doom Lord Kazzak", sourceType = "world" },
                alts = {
                    { id = 29017, name = "Warbringer Handguards", source = "The Curator", sourceType = "raid" },
                    { id = 27475, name = "Gauntlets of the Bold", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 27672, name = "Girdle of the Immovable", source = "Quagmirran (Slave Pens)", sourceType = "dungeon" },
                alts = {
                    { id = 28566, name = "Crimson Girdle of the Indomitable", source = "Moroes", sourceType = "raid" },
                    { id = 27460, name = "Girdle of Many Blessings", source = "Warlord Kalithresh", sourceType = "heroic" },
                }
            },
            legs = {
                bis = { id = 28621, name = "Wrynn Dynasty Greaves", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29015, name = "Warbringer Legguards", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 27839, name = "Legplates of the Righteous", source = "Aeonus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28747, name = "Battlescar Boots", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27813, name = "Boots of the Colossus", source = "Pandemonius", sourceType = "heroic" },
                    { id = 25690, name = "Heavy Clefthoof Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 29279, name = "Violet Signet of the Great Protector", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28792, name = "A'dal's Signet of Defense", source = "Magtheridon Quest", sourceType = "quest" },
                    { id = 27822, name = "Crystal Band of Valor", source = "Nexus-Prince Shaffar", sourceType = "heroic" },
                }
            },
            ring2 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28675, name = "Shermanar Great-Ring", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28407, name = "Elementium Band of the Sentry", source = "Arcatraz Key Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 28528, name = "Moroes' Lucky Pocket Watch", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 27891, name = "Adamantine Figurine", source = "Blackheart the Inciter", sourceType = "heroic" },
                    { id = 29181, name = "Dabiri's Enigma", source = "Dimensius the All-Devouring", sourceType = "quest" },
                }
            },
            trinket2 = {
                bis = { id = 28121, name = "Icon of Unyielding Courage", source = "Keli'dan the Breaker", sourceType = "heroic" },
                alts = {
                    { id = 23836, name = "Goblin Rocket Launcher", source = "Engineering", sourceType = "crafted" },
                    { id = 27770, name = "Argussian Compass", source = "The Black Stalker", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28749, name = "King's Defender", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 29362, name = "The Sun Eater", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28189, name = "Latro's Shifting Sword", source = "Aeonus", sourceType = "heroic" },
                }
            },
            offhand = {
                bis = { id = 28825, name = "Aldori Legacy Defender", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28606, name = "Shield of Impenetrable Darkness", source = "Nightbane", sourceType = "raid" },
                    { id = 29266, name = "Azure-Shield of Coldarra", source = "G'eras (33 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 30724, name = "Barrel-Blade Longrifle", source = "Doomwalker", sourceType = "world" },
                alts = {
                    { id = 29115, name = "Consortium Blaster", source = "Consortium Exalted", sourceType = "reputation" },
                    { id = 28504, name = "Steelhawk Crossbow", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
        },

        -------------------------------------------
        -- HOLY PALADIN
        -------------------------------------------
        ["holy-paladin-healer"] = {
            head = {
                bis = { id = 29061, name = "Justicar Diadem", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32090, name = "Cowl of Naaru Blessings", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28413, name = "Hallowed Crown", source = "Harbinger Skyriss", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28609, name = "Emberspur Talisman", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29374, name = "Necklace of Eternal Hope", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 31691, name = "Natasha's Guardian Cord", source = "Quest: The Hound-Master", sourceType = "quest" },
                }
            },
            shoulders = {
                bis = { id = 29064, name = "Justicar Pauldrons", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27775, name = "Hallowed Pauldrons", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 21874, name = "Primal Mooncloth Shoulders", source = "Tailoring", sourceType = "crafted" },
                }
            },
            back = {
                bis = { id = 28765, name = "Stainless Cloak of the Pure Hearted", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29375, name = "Bishop's Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 31329, name = "Lifegiving Cloak", source = "World Drop", sourceType = "boe" },
                }
            },
            chest = {
                bis = { id = 29062, name = "Justicar Chestpiece", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29522, name = "Windhawk Hauberk", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 21875, name = "Primal Mooncloth Robe", source = "Tailoring", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29183, name = "Bindings of the Timewalker", source = "Keepers of Time Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29523, name = "Windhawk Bracers", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 29249, name = "Bands of the Benevolent", source = "Talon King Ikiss", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 28505, name = "Gauntlets of Renewed Hope", source = "Attumen the Huntsman", sourceType = "raid" },
                alts = {
                    { id = 29063, name = "Justicar Handguards", source = "The Curator", sourceType = "raid" },
                    { id = 28304, name = "Prismatic Mittens of Mending", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                }
            },
            waist = {
                bis = { id = 21873, name = "Primal Mooncloth Belt", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29524, name = "Windhawk Belt", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 27542, name = "Cord of Sanctification", source = "Quest", sourceType = "quest" },
                }
            },
            legs = {
                bis = { id = 28748, name = "Legplates of the Innocent", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 29065, name = "Justicar Leggings", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30543, name = "Pontifex Kilt", source = "Warlord Kalithresh", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28752, name = "Forestlord Striders", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27411, name = "Slippers of Serenity", source = "Exarch Maladaar", sourceType = "dungeon" },
                    { id = 29251, name = "Boots of the Pious", source = "Pathaleon the Calculator", sourceType = "heroic" },
                }
            },
            ring1 = {
                bis = { id = 28763, name = "Jade Ring of the Everliving", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 29373, name = "Band of Halos", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29169, name = "Ring of Convalescence", source = "Honor Hold/Thrallmar Exalted", sourceType = "reputation" },
                    { id = 29814, name = "Celestial Jewel Ring", source = "Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 29376, name = "Essence of the Martyr", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                }
            },
            trinket2 = {
                bis = { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                    { id = 27828, name = "Warp-Scarab Brooch", source = "Pandemonius", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28771, name = "Light's Justice", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28522, name = "Shard of the Virtuous", source = "Maiden of Virtue", sourceType = "raid" },
                    { id = 29175, name = "Gavel of Pure Light", source = "Aldor Exalted", sourceType = "reputation" },
                }
            },
            offhand = {
                bis = { id = 29170, name = "Windcaller's Orb", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29274, name = "Tears of Heaven", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 28728, name = "Aran's Soothing Sapphire", source = "Shade of Aran", sourceType = "raid" },
                }
            },
            ranged = {
                bis = { id = 28296, name = "Libram of the Lightbringer", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                alts = {
                    { id = 23201, name = "Libram of Divinity", source = "Naxxramas Legacy", sourceType = "raid" },
                    { id = 28065, name = "Libram of Wracking", source = "Hellfire Peninsula Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- ROGUE DPS
        -------------------------------------------
        ["rogue-dps"] = {
            head = {
                bis = { id = 29044, name = "Netherblade Facemask", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32087, name = "Mask of the Deceiver", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 27779, name = "Bone Chain Necklace", source = "The Black Stalker", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29047, name = "Netherblade Shoulderpads", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 28755, name = "Bladed Shoulderpads of the Merciless", source = "Chess Event", sourceType = "raid" },
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                alts = {
                    { id = 28582, name = "Red Riding Hood's Cloak", source = "Opera Event", sourceType = "raid" },
                    { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                    { id = 29382, name = "Blood Knight War Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29045, name = "Netherblade Chestpiece", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28601, name = "Chestguard of the Conniver", source = "Nightbane", sourceType = "raid" },
                    { id = 28204, name = "Tunic of Assassination", source = "Pathaleon the Calculator", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                alts = {
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                    { id = 27430, name = "Dreghood Bands", source = "Omor the Unscarred", sourceType = "dungeon" },
                }
            },
            hands = {
                bis = { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                alts = {
                    { id = 29046, name = "Netherblade Gloves", source = "The Curator", sourceType = "raid" },
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                alts = {
                    { id = 28750, name = "Girdle of Treachery", source = "Moroes", sourceType = "raid" },
                    { id = 27911, name = "Dunewind Sash", source = "Nexus-Prince Shaffar", sourceType = "dungeon" },
                }
            },
            legs = {
                bis = { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29048, name = "Netherblade Breeches", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 28221, name = "Wastewalker Leggings", source = "Murmur", sourceType = "dungeon" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 29248, name = "Shadowstep Striders", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                    { id = 25686, name = "Fel Leather Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29384, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 31920, name = "Shaffar's Band of Brutality", source = "Nexus-Prince Shaffar", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28579, name = "Romulo's Poison Vial", source = "Opera Event", sourceType = "raid" },
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28579, name = "Romulo's Poison Vial", source = "Opera Event", sourceType = "raid" },
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28768, name = "Malchazeen", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28573, name = "Blade of the Unrequited", source = "Opera Event", sourceType = "raid" },
                    { id = 28295, name = "Gladiator's Shiv", source = "Arena Season 1", sourceType = "pvp" },
                    { id = 28438, name = "Dragonmaw", source = "Master Hammersmith", sourceType = "crafted" },
                }
            },
            offhand = {
                bis = { id = 28768, name = "Malchazeen", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28573, name = "Blade of the Unrequited", source = "Opera Event", sourceType = "raid" },
                    { id = 28657, name = "Fool's Bane", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 27872, name = "The Harvester of Souls", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            ranged = {
                bis = { id = 30724, name = "Barrel-Blade Longrifle", source = "Doomwalker", sourceType = "world" },
                alts = {
                    { id = 28504, name = "Steelhawk Crossbow", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 30278, name = "Lightsworn Hammer", source = "Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- HUNTER DPS
        -------------------------------------------
        ["hunter-dps"] = {
            head = {
                bis = { id = 29081, name = "Demon Stalker Greathelm", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28583, name = "Big Bad Wolf's Head", source = "Opera Event", sourceType = "raid" },
                    { id = 32087, name = "Mask of the Deceiver", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 27516, name = "Malefic Mask of the Shadows", source = "High King Maulgar", sourceType = "raid" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29084, name = "Demon Stalker Shoulderguards", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 28755, name = "Bladed Shoulderpads of the Merciless", source = "Chess Event", sourceType = "raid" },
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                alts = {
                    { id = 28582, name = "Red Riding Hood's Cloak", source = "Opera Event", sourceType = "raid" },
                    { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                    { id = 29382, name = "Blood Knight War Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29082, name = "Demon Stalker Harness", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29525, name = "Primalstrike Vest", source = "Elemental Leatherworking", sourceType = "crafted" },
                    { id = 28228, name = "Beast Lord Cuirass", source = "Warp Splinter", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                alts = {
                    { id = 29527, name = "Primalstrike Bracers", source = "Elemental Leatherworking", sourceType = "crafted" },
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 29083, name = "Demon Stalker Gauntlets", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 27474, name = "Beast Lord Handguards", source = "Warchief Kargath", sourceType = "dungeon" },
                    { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28567, name = "Belt of Gale Force", source = "Moroes", sourceType = "raid" },
                    { id = 29526, name = "Primalstrike Belt", source = "Elemental Leatherworking", sourceType = "crafted" },
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                }
            },
            legs = {
                bis = { id = 30739, name = "Scaled Greaves of the Marksman", source = "Doom Lord Kazzak", sourceType = "world" },
                alts = {
                    { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                    { id = 28348, name = "Beast Lord Leggings", source = "Aeonus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 27915, name = "Beast Lord Boots", source = "Nethekurse", sourceType = "dungeon" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29384, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 31077, name = "Slayer's Mark of the Redemption", source = "Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 29776, name = "Core of Ar'kelos", source = "Quest", sourceType = "quest" },
                }
            },
            mainhand = {
                bis = { id = 28587, name = "Legacy", source = "Opera Event", sourceType = "raid" },
                alts = {
                    { id = 28767, name = "The Decapitator", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28438, name = "Dragonmaw", source = "Master Hammersmith", sourceType = "crafted" },
                }
            },
            offhand = {
                bis = { id = 0, name = "N/A (2H Stat Stick)", source = "N/A", sourceType = "none" },
                alts = {}
            },
            ranged = {
                bis = { id = 28772, name = "Sunfury Bow of the Phoenix", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28435, name = "Gladiator's Longbow", source = "Arena Season 1", sourceType = "pvp" },
                    { id = 28504, name = "Steelhawk Crossbow", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
        },

        -------------------------------------------
        -- MAGE DPS
        -------------------------------------------
        ["mage-dps"] = {
            head = {
                bis = { id = 24266, name = "Spellstrike Hood", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29076, name = "Collar of the Aldor", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28415, name = "Hood of Oblivion", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28762, name = "Adornment of Stolen Souls", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28530, name = "Brooch of Unquenchable Fury", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28134, name = "Brooch of Heightened Potential", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29079, name = "Pauldrons of the Aldor", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27796, name = "Mana-Etched Spaulders", source = "Rokmar the Crackler", sourceType = "heroic" },
                    { id = 27778, name = "Spaulders of Oblivion", source = "Ambassador Hellmaw", sourceType = "dungeon" },
                }
            },
            back = {
                bis = { id = 28766, name = "Ruby Drape of the Mysticant", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28570, name = "Shadow-Cloak of Dalaran", source = "Moroes", sourceType = "raid" },
                    { id = 27981, name = "Sethekk Oracle Cloak", source = "Talon King Ikiss", sourceType = "dungeon" },
                }
            },
            chest = {
                bis = { id = 21848, name = "Spellfire Robe", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28578, name = "Masquerade Gown", source = "Opera Event", sourceType = "raid" },
                    { id = 29077, name = "Robe of the Aldor", source = "Magtheridon", sourceType = "raid" },
                    { id = 28230, name = "Hallowed Garments", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 24250, name = "Bracers of Havok", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 27462, name = "Crimson Bracers of Gloom", source = "Omor the Unscarred", sourceType = "heroic" },
                    { id = 28174, name = "Shattrath Wraps", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 21847, name = "Spellfire Gloves", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28507, name = "Handwraps of Flowing Thought", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 27493, name = "Gloves of the Deadwatcher", source = "Shirrak the Dead Watcher", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 21846, name = "Spellfire Belt", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28569, name = "Nethershard Girdle", source = "Moroes", sourceType = "raid" },
                    { id = 24256, name = "Girdle of Ruination", source = "Tailoring", sourceType = "crafted" },
                    { id = 28799, name = "Belt of Divine Inspiration", source = "Terestian Illhoof", sourceType = "raid" },
                }
            },
            legs = {
                bis = { id = 24262, name = "Spellstrike Pants", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28594, name = "Trial-Fire Trousers", source = "Opera Event", sourceType = "raid" },
                    { id = 27838, name = "Breeches of the Occultist", source = "Temporus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28517, name = "Boots of Foretelling", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 28585, name = "Ruby Slippers", source = "Opera Event", sourceType = "raid" },
                    { id = 28179, name = "Shattrath Jumpers", source = "Quest", sourceType = "quest" },
                }
            },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                }
            },
            ring2 = {
                bis = { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29126, name = "Seer's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                    { id = 28227, name = "Sparking Arcanite Ring", source = "Sunseeker Astromage", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28789, name = "Eye of Magtheridon", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                    { id = 29132, name = "Scryer's Bloodgem", source = "Scryers Revered", sourceType = "reputation" },
                }
            },
            mainhand = {
                bis = { id = 28770, name = "Nathrezim Mindblade", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28633, name = "Staff of Infinite Mysteries", source = "The Curator", sourceType = "raid" },
                    { id = 30723, name = "Talon of the Tempest", source = "Doomwalker", sourceType = "world" },
                }
            },
            offhand = {
                bis = { id = 29270, name = "Flametongue Seal", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 29271, name = "Talisman of Kalecgos", source = "G'eras (35 Badges)", sourceType = "badge" },
                    { id = 28734, name = "Jewel of Infinite Possibilities", source = "Netherspite", sourceType = "raid" },
                }
            },
            ranged = {
                bis = { id = 28783, name = "Eredar Wand of Obliteration", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28673, name = "Tirisfal Wand of Ascendancy", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28386, name = "Nether Core's Control Rod", source = "Dalliah the Doomsayer (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
        },

        -------------------------------------------
        -- WARLOCK DPS
        -------------------------------------------
        ["warlock-dps"] = {
            head = {
                bis = { id = 24266, name = "Spellstrike Hood", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28963, name = "Voidheart Crown", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28415, name = "Hood of Oblivion", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28762, name = "Adornment of Stolen Souls", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28530, name = "Brooch of Unquenchable Fury", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28134, name = "Brooch of Heightened Potential", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 28967, name = "Voidheart Mantle", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27778, name = "Spaulders of Oblivion", source = "Ambassador Hellmaw", sourceType = "dungeon" },
                    { id = 27796, name = "Mana-Etched Spaulders", source = "Rokmar the Crackler", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28766, name = "Ruby Drape of the Mysticant", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28570, name = "Shadow-Cloak of Dalaran", source = "Moroes", sourceType = "raid" },
                    { id = 27981, name = "Sethekk Oracle Cloak", source = "Talon King Ikiss", sourceType = "dungeon" },
                }
            },
            chest = {
                bis = { id = 21848, name = "Spellfire Robe", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28578, name = "Masquerade Gown", source = "Opera Event", sourceType = "raid" },
                    { id = 28964, name = "Voidheart Robe", source = "Magtheridon", sourceType = "raid" },
                    { id = 28230, name = "Hallowed Garments", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 24250, name = "Bracers of Havok", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28515, name = "Bands of Nefarious Deeds", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 27462, name = "Crimson Bracers of Gloom", source = "Omor the Unscarred", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 21847, name = "Spellfire Gloves", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28507, name = "Handwraps of Flowing Thought", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 27493, name = "Gloves of the Deadwatcher", source = "Shirrak the Dead Watcher", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 21846, name = "Spellfire Belt", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28569, name = "Nethershard Girdle", source = "Moroes", sourceType = "raid" },
                    { id = 24256, name = "Girdle of Ruination", source = "Tailoring", sourceType = "crafted" },
                    { id = 28799, name = "Belt of Divine Inspiration", source = "Terestian Illhoof", sourceType = "raid" },
                }
            },
            legs = {
                bis = { id = 24262, name = "Spellstrike Pants", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28966, name = "Voidheart Leggings", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 27838, name = "Breeches of the Occultist", source = "Temporus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28517, name = "Boots of Foretelling", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 28585, name = "Ruby Slippers", source = "Opera Event", sourceType = "raid" },
                    { id = 28179, name = "Shattrath Jumpers", source = "Quest", sourceType = "quest" },
                }
            },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                }
            },
            ring2 = {
                bis = { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29126, name = "Seer's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                    { id = 28227, name = "Sparking Arcanite Ring", source = "Sunseeker Astromage", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28789, name = "Eye of Magtheridon", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                    { id = 29132, name = "Scryer's Bloodgem", source = "Scryers Revered", sourceType = "reputation" },
                }
            },
            mainhand = {
                bis = { id = 28770, name = "Nathrezim Mindblade", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28633, name = "Staff of Infinite Mysteries", source = "The Curator", sourceType = "raid" },
                    { id = 30723, name = "Talon of the Tempest", source = "Doomwalker", sourceType = "world" },
                }
            },
            offhand = {
                bis = { id = 28734, name = "Jewel of Infinite Possibilities", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29271, name = "Talisman of Kalecgos", source = "G'eras (35 Badges)", sourceType = "badge" },
                    { id = 29273, name = "Khadgar's Knapsack", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 28783, name = "Eredar Wand of Obliteration", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28673, name = "Tirisfal Wand of Ascendancy", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28386, name = "Nether Core's Control Rod", source = "Dalliah the Doomsayer (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
        },

        -------------------------------------------
        -- SHADOW PRIEST
        -------------------------------------------
        ["shadow-priest-dps"] = {
            head = {
                bis = { id = 24266, name = "Spellstrike Hood", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29058, name = "Soul-Collar of the Incarnate", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28415, name = "Hood of Oblivion", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28762, name = "Adornment of Stolen Souls", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28530, name = "Brooch of Unquenchable Fury", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28134, name = "Brooch of Heightened Potential", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29060, name = "Soul-Mantle of the Incarnate", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 21869, name = "Frozen Shadoweave Shoulders", source = "Shadoweave Tailoring", sourceType = "crafted" },
                    { id = 27778, name = "Spaulders of Oblivion", source = "Ambassador Hellmaw", sourceType = "dungeon" },
                }
            },
            back = {
                bis = { id = 28766, name = "Ruby Drape of the Mysticant", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28570, name = "Shadow-Cloak of Dalaran", source = "Moroes", sourceType = "raid" },
                    { id = 27981, name = "Sethekk Oracle Cloak", source = "Talon King Ikiss", sourceType = "dungeon" },
                }
            },
            chest = {
                bis = { id = 21871, name = "Frozen Shadoweave Robe", source = "Shadoweave Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28578, name = "Masquerade Gown", source = "Opera Event", sourceType = "raid" },
                    { id = 29056, name = "Shroud of the Incarnate", source = "Magtheridon", sourceType = "raid" },
                    { id = 28230, name = "Hallowed Garments", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 24250, name = "Bracers of Havok", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28515, name = "Bands of Nefarious Deeds", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 27462, name = "Crimson Bracers of Gloom", source = "Omor the Unscarred", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 28507, name = "Handwraps of Flowing Thought", source = "Attumen the Huntsman", sourceType = "raid" },
                alts = {
                    { id = 21847, name = "Spellfire Gloves", source = "Spellfire Tailoring", sourceType = "crafted" },
                    { id = 27493, name = "Gloves of the Deadwatcher", source = "Shirrak the Dead Watcher", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 24256, name = "Girdle of Ruination", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28569, name = "Nethershard Girdle", source = "Moroes", sourceType = "raid" },
                    { id = 28799, name = "Belt of Divine Inspiration", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 28654, name = "Malefic Girdle", source = "Terestian Illhoof", sourceType = "raid" },
                }
            },
            legs = {
                bis = { id = 24262, name = "Spellstrike Pants", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29057, name = "Leggings of the Incarnate", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 27838, name = "Breeches of the Occultist", source = "Temporus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 21870, name = "Frozen Shadoweave Boots", source = "Shadoweave Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28517, name = "Boots of Foretelling", source = "Maiden of Virtue", sourceType = "raid" },
                    { id = 28179, name = "Shattrath Jumpers", source = "Quest", sourceType = "quest" },
                }
            },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                }
            },
            ring2 = {
                bis = { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29126, name = "Seer's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                    { id = 28227, name = "Sparking Arcanite Ring", source = "Sunseeker Astromage", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28789, name = "Eye of Magtheridon", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                    { id = 29132, name = "Scryer's Bloodgem", source = "Scryers Revered", sourceType = "reputation" },
                }
            },
            mainhand = {
                bis = { id = 28770, name = "Nathrezim Mindblade", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28633, name = "Staff of Infinite Mysteries", source = "The Curator", sourceType = "raid" },
                    { id = 30723, name = "Talon of the Tempest", source = "Doomwalker", sourceType = "world" },
                }
            },
            offhand = {
                bis = { id = 28734, name = "Jewel of Infinite Possibilities", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29271, name = "Talisman of Kalecgos", source = "G'eras (35 Badges)", sourceType = "badge" },
                    { id = 29273, name = "Khadgar's Knapsack", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 28783, name = "Eredar Wand of Obliteration", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28673, name = "Tirisfal Wand of Ascendancy", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28386, name = "Nether Core's Control Rod", source = "Dalliah the Doomsayer (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
        },

        -------------------------------------------
        -- BALANCE DRUID
        -------------------------------------------
        ["balance-druid-dps"] = {
            head = {
                bis = { id = 24266, name = "Spellstrike Hood", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28744, name = "Uni-Mind Headdress", source = "Netherspite", sourceType = "raid" },
                    { id = 28415, name = "Hood of Oblivion", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28762, name = "Adornment of Stolen Souls", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28530, name = "Brooch of Unquenchable Fury", source = "Moroes", sourceType = "raid" },
                    { id = 28134, name = "Brooch of Heightened Potential", source = "Blackheart the Inciter", sourceType = "dungeon" },
                }
            },
            shoulders = {
                bis = { id = 29095, name = "Pauldrons of Malorne", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27778, name = "Spaulders of Oblivion", source = "Ambassador Hellmaw", sourceType = "dungeon" },
                    { id = 27796, name = "Mana-Etched Spaulders", source = "Rokmar the Crackler", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28766, name = "Ruby Drape of the Mysticant", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28570, name = "Shadow-Cloak of Dalaran", source = "Moroes", sourceType = "raid" },
                    { id = 27981, name = "Sethekk Oracle Cloak", source = "Talon King Ikiss", sourceType = "dungeon" },
                }
            },
            chest = {
                bis = { id = 21848, name = "Spellfire Robe", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28578, name = "Masquerade Gown", source = "Opera Event", sourceType = "raid" },
                    { id = 29091, name = "Chestpiece of Malorne", source = "Magtheridon", sourceType = "raid" },
                    { id = 29522, name = "Windhawk Hauberk", source = "Tribal Leatherworking", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29523, name = "Windhawk Bracers", source = "Tribal Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 24250, name = "Bracers of Havok", source = "Tailoring", sourceType = "crafted" },
                    { id = 27462, name = "Crimson Bracers of Gloom", source = "Omor the Unscarred", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 21847, name = "Spellfire Gloves", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 28507, name = "Handwraps of Flowing Thought", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 27493, name = "Gloves of the Deadwatcher", source = "Shirrak the Dead Watcher", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 21846, name = "Spellfire Belt", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 24256, name = "Girdle of Ruination", source = "Tailoring", sourceType = "crafted" },
                    { id = 29524, name = "Windhawk Belt", source = "Tribal Leatherworking", sourceType = "crafted" },
                }
            },
            legs = {
                bis = { id = 24262, name = "Spellstrike Pants", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 30531, name = "Leggings of the Seventh Circle", source = "Doomwalker", sourceType = "world" },
                    { id = 27838, name = "Breeches of the Occultist", source = "Temporus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28517, name = "Boots of Foretelling", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 28585, name = "Ruby Slippers", source = "Opera Event", sourceType = "raid" },
                    { id = 28179, name = "Shattrath Jumpers", source = "Quest", sourceType = "quest" },
                }
            },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 29172, name = "Ashyen's Gift", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                }
            },
            ring2 = {
                bis = { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28227, name = "Sparking Arcanite Ring", source = "Sunseeker Astromage", sourceType = "heroic" },
                    { id = 29126, name = "Seer's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                }
            },
            trinket1 = {
                bis = { id = 28789, name = "Eye of Magtheridon", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 29132, name = "Scryer's Bloodgem", source = "Scryers Revered", sourceType = "reputation" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28770, name = "Nathrezim Mindblade", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28633, name = "Staff of Infinite Mysteries", source = "The Curator", sourceType = "raid" },
                    { id = 28297, name = "Gladiator's Spellblade", source = "Arena Season 1", sourceType = "pvp" },
                }
            },
            offhand = {
                bis = { id = 28734, name = "Jewel of Infinite Possibilities", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29271, name = "Talisman of Kalecgos", source = "G'eras (35 Badges)", sourceType = "badge" },
                    { id = 29273, name = "Khadgar's Knapsack", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 27518, name = "Ivory Idol of the Moongoddess", source = "Grand Warlock Nethekurse", sourceType = "dungeon" },
                alts = {
                    { id = 32387, name = "Idol of the Raven Goddess", source = "Quest: Vanquish the Raven God", sourceType = "quest" },
                    { id = 25643, name = "Harold's Rejuvenating Broach", source = "Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- FERAL DRUID DPS (Cat)
        -------------------------------------------
        ["feral-druid-dps"] = {
            head = {
                bis = { id = 8345, name = "Wolfshead Helm", source = "Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                    { id = 29098, name = "Stag-Helm of Malorne", source = "Prince Malchezaar", sourceType = "raid" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29100, name = "Mantle of Malorne", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 27434, name = "Mantle of Perenolde", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                alts = {
                    { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                    { id = 29382, name = "Blood Knight War Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29096, name = "Breastplate of Malorne", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28228, name = "Beast Lord Cuirass", source = "Warp Splinter", sourceType = "dungeon" },
                    { id = 25689, name = "Heavy Clefthoof Vest", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                alts = {
                    { id = 25697, name = "Fel Leather Gloves", source = "Leatherworking", sourceType = "crafted" },
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                alts = {
                    { id = 29097, name = "Gloves of Malorne", source = "The Curator", sourceType = "raid" },
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                    { id = 28750, name = "Girdle of Treachery", source = "Moroes", sourceType = "raid" },
                }
            },
            legs = {
                bis = { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29099, name = "Greaves of Malorne", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 28221, name = "Wastewalker Leggings", source = "Murmur", sourceType = "dungeon" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 25686, name = "Fel Leather Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29384, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28323, name = "Ring of Umbral Doom", source = "Thorngrin the Tender", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28658, name = "Terestian's Stranglestaff", source = "Terestian Illhoof", sourceType = "raid" },
                alts = {
                    { id = 29171, name = "Earthwarden", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                    { id = 27846, name = "Claw of the Watcher", source = "Warp Splinter", sourceType = "heroic" },
                }
            },
            offhand = {
                bis = { id = 0, name = "(Staff - No Offhand)", source = "N/A", sourceType = "none" },
                alts = {}
            },
            ranged = {
                bis = { id = 29390, name = "Everbloom Idol", source = "G'eras (15 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28064, name = "Idol of the Wild", source = "Quest: Colossal Menace", sourceType = "quest" },
                    { id = 28372, name = "Idol of Feral Shadows", source = "Zereketh the Unbound (Arcatraz)", sourceType = "dungeon" },
                }
            },
        },

        -------------------------------------------
        -- FERAL DRUID TANK (Bear)
        -------------------------------------------
        ["feral-druid-tank"] = {
            head = {
                bis = { id = 29098, name = "Stag-Helm of Malorne", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                    { id = 29503, name = "Warhelm of the Bold", source = "Consortium Exalted", sourceType = "reputation" },
                }
            },
            neck = {
                bis = { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                alts = {
                    { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29100, name = "Mantle of Malorne", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 27434, name = "Mantle of Perenolde", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28660, name = "Gilded Thorium Cloak", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 29385, name = "Slikk's Cloak of Placation", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 27878, name = "Auchenai Death Shroud", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            chest = {
                bis = { id = 29096, name = "Breastplate of Malorne", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 25689, name = "Heavy Clefthoof Vest", source = "Leatherworking", sourceType = "crafted" },
                    { id = 28264, name = "Wastewalker Tunic", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                alts = {
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                    { id = 25697, name = "Fel Leather Gloves", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            hands = {
                bis = { id = 29097, name = "Gloves of Malorne", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                    { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                    { id = 25691, name = "Heavy Clefthoof Belt", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            legs = {
                bis = { id = 29099, name = "Greaves of Malorne", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                    { id = 25690, name = "Heavy Clefthoof Leggings", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 25692, name = "Heavy Clefthoof Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29279, name = "Violet Signet of the Great Protector", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28792, name = "A'dal's Signet of Defense", source = "Magtheridon Quest", sourceType = "quest" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 28675, name = "Shermanar Great-Ring", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28323, name = "Ring of Umbral Doom", source = "Thorngrin the Tender", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 27891, name = "Adamantine Figurine", source = "Blackheart the Inciter", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 28121, name = "Icon of Unyielding Courage", source = "Keli'dan the Breaker", sourceType = "heroic" },
                alts = {
                    { id = 28528, name = "Moroes' Lucky Pocket Watch", source = "Moroes", sourceType = "raid" },
                    { id = 27770, name = "Argussian Compass", source = "The Black Stalker", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 29171, name = "Earthwarden", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28658, name = "Terestian's Stranglestaff", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 27846, name = "Claw of the Watcher", source = "Warp Splinter", sourceType = "heroic" },
                }
            },
            offhand = {
                bis = { id = 0, name = "(Staff - No Offhand)", source = "N/A", sourceType = "none" },
                alts = {}
            },
            ranged = {
                bis = { id = 29390, name = "Everbloom Idol", source = "G'eras (15 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28064, name = "Idol of the Wild", source = "Quest: Colossal Menace", sourceType = "quest" },
                    { id = 27744, name = "Idol of Ursoc", source = "Hungarfen (Heroic Underbog)", sourceType = "heroic" },
                }
            },
        },

        -------------------------------------------
        -- RESTORATION DRUID
        -------------------------------------------
        ["druid-healer"] = {
            head = {
                bis = { id = 29086, name = "Crown of Malorne", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32090, name = "Cowl of Naaru Blessings", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28413, name = "Hallowed Crown", source = "Harbinger Skyriss", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28609, name = "Emberspur Talisman", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29374, name = "Necklace of Eternal Hope", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 31691, name = "Natasha's Guardian Cord", source = "Quest: The Hound-Master", sourceType = "quest" },
                }
            },
            shoulders = {
                bis = { id = 29089, name = "Shoulderguards of Malorne", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27775, name = "Hallowed Pauldrons", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 21874, name = "Primal Mooncloth Shoulders", source = "Tailoring", sourceType = "crafted" },
                }
            },
            back = {
                bis = { id = 28765, name = "Stainless Cloak of the Pure Hearted", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29375, name = "Bishop's Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 29354, name = "Light-Touched Stole of Altruism", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29087, name = "Chestguard of Malorne", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29522, name = "Windhawk Hauberk", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 21875, name = "Primal Mooncloth Robe", source = "Tailoring", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29523, name = "Windhawk Bracers", source = "Tribal Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 29183, name = "Bindings of the Timewalker", source = "Keepers of Time Exalted", sourceType = "reputation" },
                    { id = 29249, name = "Bands of the Benevolent", source = "Talon King Ikiss", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 29088, name = "Gloves of Malorne", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 28304, name = "Prismatic Mittens of Mending", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                    { id = 28521, name = "Gloves of Centering", source = "Maiden of Virtue", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 29524, name = "Windhawk Belt", source = "Tribal Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 21873, name = "Primal Mooncloth Belt", source = "Tailoring", sourceType = "crafted" },
                    { id = 27542, name = "Cord of Sanctification", source = "Quest", sourceType = "quest" },
                }
            },
            legs = {
                bis = { id = 29090, name = "Legguards of Malorne", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28591, name = "Earthsoul Leggings", source = "Opera Event", sourceType = "raid" },
                    { id = 30543, name = "Pontifex Kilt", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 27875, name = "Kirin Tor Master's Trousers", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28752, name = "Forestlord Striders", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27411, name = "Slippers of Serenity", source = "Exarch Maladaar", sourceType = "dungeon" },
                    { id = 29251, name = "Boots of the Pious", source = "Pathaleon the Calculator", sourceType = "heroic" },
                }
            },
            ring1 = {
                bis = { id = 28763, name = "Jade Ring of the Everliving", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 29373, name = "Band of Halos", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29172, name = "Ashyen's Gift", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                    { id = 29169, name = "Ring of Convalescence", source = "Honor Hold/Thrallmar Exalted", sourceType = "reputation" },
                }
            },
            trinket1 = {
                bis = { id = 29376, name = "Essence of the Martyr", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                }
            },
            trinket2 = {
                bis = { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                    { id = 27828, name = "Warp-Scarab Brooch", source = "Pandemonius", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28771, name = "Light's Justice", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28522, name = "Shard of the Virtuous", source = "Maiden of Virtue", sourceType = "raid" },
                    { id = 29175, name = "Gavel of Pure Light", source = "Aldor Exalted", sourceType = "reputation" },
                }
            },
            offhand = {
                bis = { id = 29170, name = "Windcaller's Orb", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29274, name = "Tears of Heaven", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 28728, name = "Aran's Soothing Sapphire", source = "Shade of Aran", sourceType = "raid" },
                }
            },
            ranged = {
                bis = { id = 27886, name = "Idol of the Emerald Queen", source = "Ambassador Hellmaw (Shadow Labyrinth)", sourceType = "dungeon" },
                alts = {
                    { id = 22398, name = "Idol of Rejuvenation", source = "Naxxramas Legacy", sourceType = "raid" },
                    { id = 25643, name = "Harold's Rejuvenating Broach", source = "Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- ELEMENTAL SHAMAN
        -------------------------------------------
        ["elemental-shaman-dps"] = {
            head = {
                bis = { id = 29035, name = "Cyclone Faceguard", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 24266, name = "Spellstrike Hood", source = "Tailoring", sourceType = "crafted" },
                    { id = 28415, name = "Hood of Oblivion", source = "Harbinger Skyriss (Heroic Arcatraz)", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28762, name = "Adornment of Stolen Souls", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28530, name = "Brooch of Unquenchable Fury", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28134, name = "Brooch of Heightened Potential", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29037, name = "Cyclone Shoulderguards", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27778, name = "Spaulders of Oblivion", source = "Ambassador Hellmaw", sourceType = "dungeon" },
                    { id = 27796, name = "Mana-Etched Spaulders", source = "Rokmar the Crackler", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28766, name = "Ruby Drape of the Mysticant", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28570, name = "Shadow-Cloak of Dalaran", source = "Moroes", sourceType = "raid" },
                    { id = 27981, name = "Sethekk Oracle Cloak", source = "Talon King Ikiss", sourceType = "dungeon" },
                }
            },
            chest = {
                bis = { id = 29033, name = "Cyclone Chestguard", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28578, name = "Masquerade Gown", source = "Opera Event", sourceType = "raid" },
                    { id = 21848, name = "Spellfire Robe", source = "Spellfire Tailoring", sourceType = "crafted" },
                    { id = 28230, name = "Hallowed Garments", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 24250, name = "Bracers of Havok", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 27462, name = "Crimson Bracers of Gloom", source = "Omor the Unscarred", sourceType = "heroic" },
                    { id = 28174, name = "Shattrath Wraps", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 29034, name = "Cyclone Gloves", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 21847, name = "Spellfire Gloves", source = "Spellfire Tailoring", sourceType = "crafted" },
                    { id = 27493, name = "Gloves of the Deadwatcher", source = "Shirrak the Dead Watcher", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 21846, name = "Spellfire Belt", source = "Spellfire Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 24256, name = "Girdle of Ruination", source = "Tailoring", sourceType = "crafted" },
                    { id = 28799, name = "Belt of Divine Inspiration", source = "Terestian Illhoof", sourceType = "raid" },
                }
            },
            legs = {
                bis = { id = 24262, name = "Spellstrike Pants", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29036, name = "Cyclone Legguards", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 27838, name = "Breeches of the Occultist", source = "Temporus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28517, name = "Boots of Foretelling", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 28585, name = "Ruby Slippers", source = "Opera Event", sourceType = "raid" },
                    { id = 28179, name = "Shattrath Jumpers", source = "Quest", sourceType = "quest" },
                }
            },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                }
            },
            ring2 = {
                bis = { id = 28753, name = "Ring of Recurrence", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 28510, name = "Spectral Band of Innervation", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 29126, name = "Seer's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                    { id = 28227, name = "Sparking Arcanite Ring", source = "Sunseeker Astromage", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28789, name = "Eye of Magtheridon", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29370, name = "Icon of the Silver Crescent", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 27683, name = "Quagmirran's Eye", source = "Quagmirran", sourceType = "heroic" },
                    { id = 29132, name = "Scryer's Bloodgem", source = "Scryers Revered", sourceType = "reputation" },
                }
            },
            mainhand = {
                bis = { id = 28770, name = "Nathrezim Mindblade", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28633, name = "Staff of Infinite Mysteries", source = "The Curator", sourceType = "raid" },
                    { id = 30723, name = "Talon of the Tempest", source = "Doomwalker", sourceType = "world" },
                }
            },
            offhand = {
                bis = { id = 29270, name = "Flametongue Seal", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28734, name = "Jewel of Infinite Possibilities", source = "Netherspite", sourceType = "raid" },
                    { id = 29271, name = "Talisman of Kalecgos", source = "G'eras (35 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 28248, name = "Totem of the Void", source = "Cache of the Legion (Mechanar)", sourceType = "dungeon" },
                alts = {
                    { id = 23199, name = "Totem of the Storm", source = "Naxxramas Legacy", sourceType = "raid" },
                    { id = 28066, name = "Totem of Lightning", source = "Quest: Colossal Menace", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- ENHANCEMENT SHAMAN
        -------------------------------------------
        ["enhancement-shaman-dps"] = {
            head = {
                bis = { id = 29040, name = "Cyclone Helm", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28583, name = "Big Bad Wolf's Head", source = "Opera Event", sourceType = "raid" },
                    { id = 32087, name = "Mask of the Deceiver", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29043, name = "Cyclone Shoulderplates", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 28593, name = "Beastmaw Pauldrons", source = "Opera Event", sourceType = "raid" },
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 27434, name = "Mantle of Perenolde", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                alts = {
                    { id = 28582, name = "Red Riding Hood's Cloak", source = "Opera Event", sourceType = "raid" },
                    { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                    { id = 29382, name = "Blood Knight War Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29038, name = "Cyclone Breastplate", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29525, name = "Primalstrike Vest", source = "Elemental Leatherworking", sourceType = "crafted" },
                    { id = 28264, name = "Wastewalker Tunic", source = "Murmur", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 29527, name = "Primalstrike Bracers", source = "Elemental Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 29039, name = "Cyclone Gauntlets", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                    { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28567, name = "Belt of Gale Force", source = "Moroes", sourceType = "raid" },
                    { id = 29526, name = "Primalstrike Belt", source = "Elemental Leatherworking", sourceType = "crafted" },
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                }
            },
            legs = {
                bis = { id = 30739, name = "Scaled Greaves of the Marksman", source = "Doom Lord Kazzak", sourceType = "world" },
                alts = {
                    { id = 29042, name = "Cyclone War-Kilt", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 28221, name = "Wastewalker Leggings", source = "Murmur", sourceType = "dungeon" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 25686, name = "Fel Leather Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29384, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28323, name = "Ring of Umbral Doom", source = "Thorngrin the Tender", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28767, name = "The Decapitator", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28438, name = "Dragonmaw", source = "Master Hammersmith", sourceType = "crafted" },
                    { id = 27872, name = "The Harvester of Souls", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            offhand = {
                bis = { id = 28767, name = "The Decapitator", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28657, name = "Fool's Bane", source = "Terestian Illhoof", sourceType = "raid" },
                    { id = 27872, name = "The Harvester of Souls", source = "Avatar of the Martyred", sourceType = "heroic" },
                }
            },
            ranged = {
                bis = { id = 27815, name = "Totem of the Astral Winds", source = "Pandemonius (Heroic Mana-Tombs)", sourceType = "heroic" },
                alts = {
                    { id = 23200, name = "Totem of Rage", source = "Naxxramas Legacy", sourceType = "raid" },
                    { id = 22395, name = "Totem of the Maelstrom", source = "Naxxramas Legacy", sourceType = "raid" },
                }
            },
        },

        -------------------------------------------
        -- RESTORATION SHAMAN
        -------------------------------------------
        ["shaman-healer"] = {
            head = {
                bis = { id = 29028, name = "Cyclone Headdress", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32090, name = "Cowl of Naaru Blessings", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28413, name = "Hallowed Crown", source = "Harbinger Skyriss", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28609, name = "Emberspur Talisman", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29374, name = "Necklace of Eternal Hope", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 31691, name = "Natasha's Guardian Cord", source = "Quest: The Hound-Master", sourceType = "quest" },
                }
            },
            shoulders = {
                bis = { id = 29031, name = "Cyclone Shoulderpads", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27775, name = "Hallowed Pauldrons", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 21874, name = "Primal Mooncloth Shoulders", source = "Tailoring", sourceType = "crafted" },
                }
            },
            back = {
                bis = { id = 28765, name = "Stainless Cloak of the Pure Hearted", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29375, name = "Bishop's Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 29354, name = "Light-Touched Stole of Altruism", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29029, name = "Cyclone Hauberk", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 29522, name = "Windhawk Hauberk", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 21875, name = "Primal Mooncloth Robe", source = "Tailoring", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29523, name = "Windhawk Bracers", source = "Tribal Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 29183, name = "Bindings of the Timewalker", source = "Keepers of Time Exalted", sourceType = "reputation" },
                    { id = 29249, name = "Bands of the Benevolent", source = "Talon King Ikiss", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 29030, name = "Cyclone Handguards", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 28304, name = "Prismatic Mittens of Mending", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                    { id = 28521, name = "Gloves of Centering", source = "Maiden of Virtue", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 29524, name = "Windhawk Belt", source = "Tribal Leatherworking", sourceType = "crafted" },
                alts = {
                    { id = 21873, name = "Primal Mooncloth Belt", source = "Tailoring", sourceType = "crafted" },
                    { id = 27542, name = "Cord of Sanctification", source = "Quest", sourceType = "quest" },
                }
            },
            legs = {
                bis = { id = 29032, name = "Cyclone Kilt", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 30543, name = "Pontifex Kilt", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 27875, name = "Kirin Tor Master's Trousers", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28752, name = "Forestlord Striders", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27411, name = "Slippers of Serenity", source = "Exarch Maladaar", sourceType = "dungeon" },
                    { id = 29251, name = "Boots of the Pious", source = "Pathaleon the Calculator", sourceType = "heroic" },
                }
            },
            ring1 = {
                bis = { id = 28763, name = "Jade Ring of the Everliving", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 29373, name = "Band of Halos", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29169, name = "Ring of Convalescence", source = "Honor Hold/Thrallmar Exalted", sourceType = "reputation" },
                    { id = 29814, name = "Celestial Jewel Ring", source = "Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 29376, name = "Essence of the Martyr", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                }
            },
            trinket2 = {
                bis = { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                    { id = 27828, name = "Warp-Scarab Brooch", source = "Pandemonius", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28771, name = "Light's Justice", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28522, name = "Shard of the Virtuous", source = "Maiden of Virtue", sourceType = "raid" },
                    { id = 29175, name = "Gavel of Pure Light", source = "Aldor Exalted", sourceType = "reputation" },
                }
            },
            offhand = {
                bis = { id = 29458, name = "Aegis of the Vindicator", source = "Cenarion Expedition Revered", sourceType = "reputation" },
                alts = {
                    { id = 29274, name = "Tears of Heaven", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 28728, name = "Aran's Soothing Sapphire", source = "Shade of Aran", sourceType = "raid" },
                }
            },
            ranged = {
                bis = { id = 28523, name = "Totem of Healing Rains", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 22396, name = "Totem of Sustaining", source = "Naxxramas Legacy", sourceType = "raid" },
                    { id = 23198, name = "Totem of Life", source = "Naxxramas Legacy", sourceType = "raid" },
                }
            },
        },

        -------------------------------------------
        -- RETRIBUTION PALADIN
        -------------------------------------------
        ["retribution-paladin-dps"] = {
            head = {
                bis = { id = 29073, name = "Justicar Crown", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32087, name = "Mask of the Deceiver", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28224, name = "Wastewalker Helm", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 29381, name = "Choker of Vile Intent", source = "G'eras (25 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28509, name = "Worgen Claw Necklace", source = "Attumen the Huntsman", sourceType = "raid" },
                    { id = 28745, name = "Mithril Chain of Heroism", source = "Nightbane", sourceType = "raid" },
                }
            },
            shoulders = {
                bis = { id = 29075, name = "Justicar Shoulderplates", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27797, name = "Wastewalker Shoulderpads", source = "Avatar of the Martyred", sourceType = "heroic" },
                    { id = 27434, name = "Mantle of Perenolde", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28672, name = "Drape of the Dark Reavers", source = "Shade of Aran", sourceType = "raid" },
                alts = {
                    { id = 24259, name = "Vengeance Wrap", source = "Tailoring", sourceType = "crafted" },
                    { id = 29382, name = "Blood Knight War Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29071, name = "Justicar Breastplate", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 28597, name = "Panzar'Thar Breastplate", source = "Nightbane", sourceType = "raid" },
                    { id = 28403, name = "Doomplate Chestguard", source = "Harbinger Skyriss", sourceType = "dungeon" },
                }
            },
            wrist = {
                bis = { id = 28795, name = "Bladespire Warbands", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 29246, name = "Nightfall Wristguards", source = "Epoch Hunter", sourceType = "heroic" },
                    { id = 28171, name = "Spymistress's Wristguards", source = "Quest", sourceType = "quest" },
                }
            },
            hands = {
                bis = { id = 29072, name = "Justicar Gauntlets", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 27531, name = "Wastewalker Gloves", source = "Warchief Kargath", sourceType = "heroic" },
                    { id = 28506, name = "Gloves of Dexterous Manipulation", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 28828, name = "Gronn-Stitched Girdle", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29247, name = "Girdle of the Deathdealer", source = "Aeonus", sourceType = "heroic" },
                    { id = 27911, name = "Dunewind Sash", source = "Nexus-Prince Shaffar", sourceType = "dungeon" },
                }
            },
            legs = {
                bis = { id = 28741, name = "Skulker's Greaves", source = "Netherspite", sourceType = "raid" },
                alts = {
                    { id = 29074, name = "Justicar Legguards", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 28221, name = "Wastewalker Leggings", source = "Murmur", sourceType = "dungeon" },
                }
            },
            feet = {
                bis = { id = 28545, name = "Edgewalker Longboots", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 28746, name = "Fiend Slayer Boots", source = "Karazhan Trash", sourceType = "raid" },
                    { id = 25686, name = "Fel Leather Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28757, name = "Ring of a Thousand Marks", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 29384, name = "Ring of Arathi Warlords", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 28649, name = "Garona's Signet Ring", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 29283, name = "Violet Signet of the Master Assassin", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 28323, name = "Ring of Umbral Doom", source = "Thorngrin the Tender", sourceType = "heroic" },
                }
            },
            trinket1 = {
                bis = { id = 28830, name = "Dragonspine Trophy", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            trinket2 = {
                bis = { id = 29383, name = "Bloodlust Brooch", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28288, name = "Abacus of Violent Odds", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 28034, name = "Hourglass of the Unraveller", source = "Temporus", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28429, name = "Lionheart Champion", source = "Master Swordsmith", sourceType = "crafted" },
                alts = {
                    { id = 28767, name = "The Decapitator", source = "Prince Malchezaar", sourceType = "raid" },
                    { id = 28438, name = "Dragonmaw", source = "Master Hammersmith", sourceType = "crafted" },
                }
            },
            offhand = {
                bis = { id = 0, name = "(Two-Hand Weapon)", source = "N/A", sourceType = "none" },
                alts = {}
            },
            ranged = {
                bis = { id = 27484, name = "Libram of Avengement", source = "The Maker (Heroic Blood Furnace)", sourceType = "heroic" },
                alts = {
                    { id = 28296, name = "Libram of the Lightbringer", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                    { id = 28065, name = "Libram of Wracking", source = "Hellfire Peninsula Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- PROTECTION PALADIN
        -------------------------------------------
        ["paladin-tank"] = {
            head = {
                bis = { id = 29068, name = "Justicar Faceguard", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32083, name = "Faceguard of Determination", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 23519, name = "Felsteel Helm", source = "Blacksmithing", sourceType = "crafted" },
                }
            },
            neck = {
                bis = { id = 28516, name = "Barbed Choker of Discipline", source = "Maiden of Virtue", sourceType = "raid" },
                alts = {
                    { id = 29386, name = "Necklace of the Juggernaut", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 27792, name = "Mark of the Ravenguard", source = "Anzu", sourceType = "heroic" },
                }
            },
            shoulders = {
                bis = { id = 29070, name = "Justicar Shoulderguards", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27739, name = "Spaulders of the Righteous", source = "Warp Splinter", sourceType = "heroic" },
                    { id = 27847, name = "Fanblade Pauldrons", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            back = {
                bis = { id = 28660, name = "Gilded Thorium Cloak", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 29385, name = "Slikk's Cloak of Placation", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 27804, name = "Devilshark Cape", source = "Warlord Kalithresh", sourceType = "heroic" },
                }
            },
            chest = {
                bis = { id = 29066, name = "Justicar Chestguard", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 27440, name = "Jade-Skull Breastplate", source = "Swamplord Musel'ek", sourceType = "heroic" },
                    { id = 23522, name = "Ragesteel Breastplate", source = "Blacksmithing", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 23538, name = "Bracers of the Green Fortress", source = "Blacksmithing", sourceType = "crafted" },
                alts = {
                    { id = 29463, name = "Sha'tari Wrought Armguards", source = "Sha'tar Exalted", sourceType = "reputation" },
                    { id = 28502, name = "Vambraces of Courage", source = "Attumen the Huntsman", sourceType = "raid" },
                }
            },
            hands = {
                bis = { id = 30741, name = "Topaz-Studded Battlegrips", source = "Doom Lord Kazzak", sourceType = "world" },
                alts = {
                    { id = 29067, name = "Justicar Handguards", source = "The Curator", sourceType = "raid" },
                    { id = 27475, name = "Gauntlets of the Bold", source = "Warchief Kargath", sourceType = "heroic" },
                }
            },
            waist = {
                bis = { id = 27672, name = "Girdle of the Immovable", source = "Quagmirran (Slave Pens)", sourceType = "dungeon" },
                alts = {
                    { id = 28566, name = "Crimson Girdle of the Indomitable", source = "Moroes", sourceType = "raid" },
                    { id = 27460, name = "Girdle of Many Blessings", source = "Warlord Kalithresh", sourceType = "heroic" },
                }
            },
            legs = {
                bis = { id = 28621, name = "Wrynn Dynasty Greaves", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29069, name = "Justicar Legguards", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 27839, name = "Legplates of the Righteous", source = "Aeonus", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28747, name = "Battlescar Boots", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27813, name = "Boots of the Colossus", source = "Pandemonius", sourceType = "heroic" },
                    { id = 25690, name = "Heavy Clefthoof Boots", source = "Leatherworking", sourceType = "crafted" },
                }
            },
            ring1 = {
                bis = { id = 29279, name = "Violet Signet of the Great Protector", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28792, name = "A'dal's Signet of Defense", source = "Magtheridon Quest", sourceType = "quest" },
                    { id = 27822, name = "Crystal Band of Valor", source = "Nexus-Prince Shaffar", sourceType = "heroic" },
                }
            },
            ring2 = {
                bis = { id = 30834, name = "Shapeshifter's Signet", source = "Lower City Exalted", sourceType = "reputation" },
                alts = {
                    { id = 28675, name = "Shermanar Great-Ring", source = "Shade of Aran", sourceType = "raid" },
                    { id = 28407, name = "Elementium Band of the Sentry", source = "Arcatraz Key Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 28528, name = "Moroes' Lucky Pocket Watch", source = "Moroes", sourceType = "raid" },
                alts = {
                    { id = 27891, name = "Adamantine Figurine", source = "Blackheart the Inciter", sourceType = "heroic" },
                    { id = 29181, name = "Dabiri's Enigma", source = "Dimensius the All-Devouring", sourceType = "quest" },
                }
            },
            trinket2 = {
                bis = { id = 28121, name = "Icon of Unyielding Courage", source = "Keli'dan the Breaker", sourceType = "heroic" },
                alts = {
                    { id = 23836, name = "Goblin Rocket Launcher", source = "Engineering", sourceType = "crafted" },
                    { id = 27770, name = "Argussian Compass", source = "The Black Stalker", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28749, name = "King's Defender", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 29362, name = "The Sun Eater", source = "Pathaleon the Calculator", sourceType = "heroic" },
                    { id = 29155, name = "Continuum Blade", source = "Keepers of Time Revered", sourceType = "reputation" },
                }
            },
            offhand = {
                bis = { id = 28825, name = "Aldori Legacy Defender", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28606, name = "Shield of Impenetrable Darkness", source = "Nightbane", sourceType = "raid" },
                    { id = 29266, name = "Azure-Shield of Coldarra", source = "G'eras (33 Badges)", sourceType = "badge" },
                }
            },
            ranged = {
                bis = { id = 29388, name = "Libram of Repentance", source = "G'eras (15 Badges)", sourceType = "badge" },
                alts = {
                    { id = 27917, name = "Libram of the Eternal Rest", source = "Darkweaver Syth (Sethekk Halls)", sourceType = "dungeon" },
                    { id = 28065, name = "Libram of Wracking", source = "Hellfire Peninsula Quest", sourceType = "quest" },
                }
            },
        },

        -------------------------------------------
        -- PRIEST HEALER (Holy/Discipline)
        -------------------------------------------
        ["priest-healer"] = {
            head = {
                bis = { id = 29049, name = "Light-Collar of the Incarnate", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 32090, name = "Cowl of Naaru Blessings", source = "G'eras (50 Badges)", sourceType = "badge" },
                    { id = 28413, name = "Hallowed Crown", source = "Harbinger Skyriss", sourceType = "heroic" },
                }
            },
            neck = {
                bis = { id = 28609, name = "Emberspur Talisman", source = "Nightbane", sourceType = "raid" },
                alts = {
                    { id = 29374, name = "Necklace of Eternal Hope", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 31691, name = "Natasha's Guardian Cord", source = "Quest: The Hound-Master", sourceType = "quest" },
                }
            },
            shoulders = {
                bis = { id = 29054, name = "Light-Mantle of the Incarnate", source = "High King Maulgar", sourceType = "raid" },
                alts = {
                    { id = 27775, name = "Hallowed Pauldrons", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 21874, name = "Primal Mooncloth Shoulders", source = "Tailoring", sourceType = "crafted" },
                }
            },
            back = {
                bis = { id = 28765, name = "Stainless Cloak of the Pure Hearted", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29375, name = "Bishop's Cloak", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 29354, name = "Light-Touched Stole of Altruism", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            chest = {
                bis = { id = 29050, name = "Robes of the Incarnate", source = "Magtheridon", sourceType = "raid" },
                alts = {
                    { id = 21875, name = "Primal Mooncloth Robe", source = "Tailoring", sourceType = "crafted" },
                    { id = 29522, name = "Windhawk Hauberk", source = "Tribal Leatherworking", sourceType = "crafted" },
                }
            },
            wrist = {
                bis = { id = 29183, name = "Bindings of the Timewalker", source = "Keepers of Time Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29523, name = "Windhawk Bracers", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 29249, name = "Bands of the Benevolent", source = "Talon King Ikiss", sourceType = "heroic" },
                }
            },
            hands = {
                bis = { id = 29055, name = "Handwraps of the Incarnate", source = "The Curator", sourceType = "raid" },
                alts = {
                    { id = 28304, name = "Prismatic Mittens of Mending", source = "Commander Sarannis (Botanica)", sourceType = "dungeon" },
                    { id = 28521, name = "Gloves of Centering", source = "Maiden of Virtue", sourceType = "raid" },
                }
            },
            waist = {
                bis = { id = 21873, name = "Primal Mooncloth Belt", source = "Tailoring", sourceType = "crafted" },
                alts = {
                    { id = 29524, name = "Windhawk Belt", source = "Tribal Leatherworking", sourceType = "crafted" },
                    { id = 27542, name = "Cord of Sanctification", source = "Quest", sourceType = "quest" },
                }
            },
            legs = {
                bis = { id = 29053, name = "Trousers of the Incarnate", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 30543, name = "Pontifex Kilt", source = "Warlord Kalithresh", sourceType = "heroic" },
                    { id = 27875, name = "Kirin Tor Master's Trousers", source = "Epoch Hunter", sourceType = "heroic" },
                }
            },
            feet = {
                bis = { id = 28752, name = "Forestlord Striders", source = "Chess Event", sourceType = "raid" },
                alts = {
                    { id = 27411, name = "Slippers of Serenity", source = "Exarch Maladaar", sourceType = "dungeon" },
                    { id = 29251, name = "Boots of the Pious", source = "Pathaleon the Calculator", sourceType = "heroic" },
                }
            },
            ring1 = {
                bis = { id = 28763, name = "Jade Ring of the Everliving", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                    { id = 29373, name = "Band of Halos", source = "G'eras (25 Badges)", sourceType = "badge" },
                }
            },
            ring2 = {
                bis = { id = 29290, name = "Violet Signet of the Grand Restorer", source = "Violet Eye Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29169, name = "Ring of Convalescence", source = "Honor Hold/Thrallmar Exalted", sourceType = "reputation" },
                    { id = 29814, name = "Celestial Jewel Ring", source = "Quest", sourceType = "quest" },
                }
            },
            trinket1 = {
                bis = { id = 29376, name = "Essence of the Martyr", source = "G'eras (41 Badges)", sourceType = "badge" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                }
            },
            trinket2 = {
                bis = { id = 28823, name = "Eye of Gruul", source = "Gruul the Dragonkiller", sourceType = "raid" },
                alts = {
                    { id = 28590, name = "Ribbon of Sacrifice", source = "Opera Event", sourceType = "raid" },
                    { id = 30841, name = "Lower City Prayerbook", source = "Lower City Honored", sourceType = "reputation" },
                    { id = 27828, name = "Warp-Scarab Brooch", source = "Pandemonius", sourceType = "heroic" },
                }
            },
            mainhand = {
                bis = { id = 28771, name = "Light's Justice", source = "Prince Malchezaar", sourceType = "raid" },
                alts = {
                    { id = 28522, name = "Shard of the Virtuous", source = "Maiden of Virtue", sourceType = "raid" },
                    { id = 29175, name = "Gavel of Pure Light", source = "Aldor Exalted", sourceType = "reputation" },
                }
            },
            offhand = {
                bis = { id = 29170, name = "Windcaller's Orb", source = "Cenarion Expedition Exalted", sourceType = "reputation" },
                alts = {
                    { id = 29274, name = "Tears of Heaven", source = "G'eras (25 Badges)", sourceType = "badge" },
                    { id = 28728, name = "Aran's Soothing Sapphire", source = "Shade of Aran", sourceType = "raid" },
                }
            },
            ranged = {
                bis = { id = 28588, name = "Blue Diamond Witchwand", source = "Opera Event", sourceType = "raid" },
                alts = {
                    { id = 28386, name = "Nether Core's Control Rod", source = "Dalliah the Doomsayer (Heroic Arcatraz)", sourceType = "heroic" },
                    { id = 27885, name = "Soul-Wand of the Aldor", source = "Ambassador Hellmaw (Shadow Labyrinth)", sourceType = "dungeon" },
                }
            },
        },
    },

    -------------------------------------------------
    -- PHASE 2-5: Placeholders for future expansion
    -------------------------------------------------
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
}

-----------------------------------------------------------
-- HELPER FUNCTIONS
-----------------------------------------------------------

-- Get BiS data for a specific slot/spec/phase
function C:GetSpecBisGear(phase, specKey, slot)
    if not C.ARMORY_SPEC_BIS_DATABASE[phase] then return nil end
    if not C.ARMORY_SPEC_BIS_DATABASE[phase][specKey] then return nil end
    return C.ARMORY_SPEC_BIS_DATABASE[phase][specKey][slot]
end

-- Get all slots for a spec/phase
function C:GetSpecBisSlots(phase, specKey)
    if not C.ARMORY_SPEC_BIS_DATABASE[phase] then return {} end
    if not C.ARMORY_SPEC_BIS_DATABASE[phase][specKey] then return {} end
    return C.ARMORY_SPEC_BIS_DATABASE[phase][specKey]
end

-- Get spec info for a class
function C:GetClassSpecs(classToken)
    return C.ARMORY_SPECS[classToken] or {}
end

-- Get spec by guideKey
function C:GetSpecByGuideKey(guideKey)
    for className, specs in pairs(C.ARMORY_SPECS) do
        for _, spec in ipairs(specs) do
            if spec.guideKey == guideKey then
                return spec, className
            end
        end
    end
    return nil
end

-- COMPATIBILITY ADAPTER: Convert new structure to old Journal.lua format
-- Converts: { bis = { id = ... }, alts = {...} }
-- To:       { best = { itemId = ... }, alternatives = {...} }
local function ConvertToLegacyFormat(slotData)
    if not slotData then return nil end

    local result = {}

    -- Convert bis -> best
    if slotData.bis then
        result.best = {
            itemId = slotData.bis.id,
            name = slotData.bis.name,
            source = slotData.bis.source,
            sourceType = slotData.bis.sourceType,
            -- Legacy fields that Journal.lua may expect (can be nil)
            icon = slotData.bis.icon,
            quality = slotData.bis.quality or "epic",
            iLvl = slotData.bis.iLvl or 0,
            stats = slotData.bis.stats,
            sourceDetail = slotData.bis.sourceDetail,
        }
    end

    -- Convert alts -> alternatives
    if slotData.alts and #slotData.alts > 0 then
        result.alternatives = {}
        for _, alt in ipairs(slotData.alts) do
            table.insert(result.alternatives, {
                itemId = alt.id,
                name = alt.name,
                source = alt.source,
                sourceType = alt.sourceType,
                icon = alt.icon,
                quality = alt.quality or "rare",
                iLvl = alt.iLvl or 0,
                stats = alt.stats,
                sourceDetail = alt.sourceDetail,
            })
        end
    end

    return result
end

-- Get BiS data for a spec/phase/slot in LEGACY format (for Journal.lua compatibility)
-- Usage: C:GetSpecBisGearLegacy(1, "warrior-dps", "head")
function C:GetSpecBisGearLegacy(phase, specKey, slot)
    local slotData = self:GetSpecBisGear(phase, specKey, slot)
    return ConvertToLegacyFormat(slotData)
end

-- Map tier to phase (T4=1, T5=2, T6=3-5)
local TIER_TO_PHASE = {
    [4] = 1,  -- T4 = Phase 1
    [5] = 2,  -- T5 = Phase 2
    [6] = 3,  -- T6 = Phase 3 (BT/Hyjal), could also be 4 or 5
}

-- Map role to guideKey for the player's class
-- This bridges the old role-based system to the new spec-based system
function C:GetGuideKeyForRole(classToken, role)
    local specs = C.ARMORY_SPECS[classToken]
    if not specs then return nil end

    -- Find first spec matching the role
    for _, spec in ipairs(specs) do
        if spec.role == role then
            return spec.guideKey
        end
    end
    return nil
end

-- OVERRIDE: Make GetArmoryGear use the new spec database
-- This replaces the old tier/role based lookup with phase/spec based lookup
-- Now: GetArmoryGear(tier, role, slot) -> looks up in ARMORY_SPEC_BIS_DATABASE
function C:GetArmoryGearFromSpec(tier, role, slot, classToken)
    local phase = TIER_TO_PHASE[tier] or 1
    local guideKey = self:GetGuideKeyForRole(classToken, role)

    if not guideKey then
        return nil  -- Fallback to old database if no mapping found
    end

    return self:GetSpecBisGearLegacy(phase, guideKey, slot)
end

-- =====================================================
-- BiS LOOKUP HELPERS (for Raids Tab integration)
-- =====================================================

-- Check if an item from a boss is BiS for a given spec
-- Returns: { isBis = true, slot = "head", phase = 1 } or nil
function C:IsItemBisForSpec(itemName, bossName, guideKey, raidPhase)
    if not itemName or not bossName or not guideKey then return nil end

    -- Check all phases from current down to 1 (items may be BiS from earlier phases)
    for phase = raidPhase, 1, -1 do
        local specData = C.ARMORY_SPEC_BIS_DATABASE[phase] and C.ARMORY_SPEC_BIS_DATABASE[phase][guideKey]
        if specData then
            for slot, slotData in pairs(specData) do
                if slotData.bis and slotData.bis.name == itemName and slotData.bis.source == bossName then
                    return { isBis = true, slot = slot, phase = phase }
                end
            end
        end
    end
    return nil
end

-- Get the guide key for the current player's spec
function C:GetCurrentPlayerGuideKey()
    local specName, specTab = HopeAddon:GetPlayerSpec()
    if not specTab then return nil end

    local _, classToken = UnitClass("player")
    local role = HopeAddon:GetSpecRole(classToken, specTab)
    if not role then return nil end

    return C:GetGuideKeyForRole(classToken, role)
end

-- =====================================================
-- REPUTATION BiS INTEGRATION
-- =====================================================

-- Maps Armory source strings to ReputationData faction names and standings
C.ARMORY_REP_SOURCE_MAP = {
    -- Lower City
    ["Lower City Exalted"] = { faction = "Lower City", standing = 8 },
    ["Lower City Honored"] = { faction = "Lower City", standing = 6 },
    ["Lower City Revered"] = { faction = "Lower City", standing = 7 },

    -- Violet Eye (Karazhan)
    ["Violet Eye Exalted"] = { faction = "The Violet Eye", standing = 8 },
    ["Violet Eye Revered"] = { faction = "The Violet Eye", standing = 7 },
    ["Violet Eye Honored"] = { faction = "The Violet Eye", standing = 6 },

    -- Sha'tar
    ["Sha'tar Exalted"] = { faction = "The Sha'tar", standing = 8 },
    ["Sha'tar Revered"] = { faction = "The Sha'tar", standing = 7 },
    ["Sha'tar Honored"] = { faction = "The Sha'tar", standing = 6 },

    -- Consortium
    ["Consortium Exalted"] = { faction = "The Consortium", standing = 8 },
    ["Consortium Revered"] = { faction = "The Consortium", standing = 7 },
    ["Consortium Honored"] = { faction = "The Consortium", standing = 6 },

    -- Cenarion Expedition
    ["Cenarion Expedition Exalted"] = { faction = "Cenarion Expedition", standing = 8 },
    ["Cenarion Expedition Revered"] = { faction = "Cenarion Expedition", standing = 7 },
    ["Cenarion Expedition Honored"] = { faction = "Cenarion Expedition", standing = 6 },

    -- Keepers of Time
    ["Keepers of Time Exalted"] = { faction = "Keepers of Time", standing = 8 },
    ["Keepers of Time Revered"] = { faction = "Keepers of Time", standing = 7 },
    ["Keepers of Time Honored"] = { faction = "Keepers of Time", standing = 6 },

    -- Aldor
    ["Aldor Exalted"] = { faction = "The Aldor", standing = 8 },
    ["Aldor Revered"] = { faction = "The Aldor", standing = 7 },
    ["Aldor Honored"] = { faction = "The Aldor", standing = 6 },

    -- Scryers
    ["Scryers Exalted"] = { faction = "The Scryers", standing = 8 },
    ["Scryers Revered"] = { faction = "The Scryers", standing = 7 },
    ["Scryers Honored"] = { faction = "The Scryers", standing = 6 },

    -- Honor Hold / Thrallmar (faction-specific)
    ["Honor Hold/Thrallmar Exalted"] = { factionAlliance = "Honor Hold", factionHorde = "Thrallmar", standing = 8 },
    ["Honor Hold/Thrallmar Revered"] = { factionAlliance = "Honor Hold", factionHorde = "Thrallmar", standing = 7 },
    ["Honor Hold/Thrallmar Honored"] = { factionAlliance = "Honor Hold", factionHorde = "Thrallmar", standing = 6 },
    ["Honor Hold Exalted"] = { faction = "Honor Hold", standing = 8 },
    ["Honor Hold Revered"] = { faction = "Honor Hold", standing = 7 },
    ["Thrallmar Exalted"] = { faction = "Thrallmar", standing = 8 },
    ["Thrallmar Revered"] = { faction = "Thrallmar", standing = 7 },
}

-- Parse reputation source string to faction and standing
-- @param source string - Source string like "Lower City Exalted"
-- @return table|nil - { faction = "Lower City", standing = 8 } or nil
function C:ParseReputationSource(source)
    if not source then return nil end

    -- Check direct mapping first
    local mapped = C.ARMORY_REP_SOURCE_MAP[source]
    if mapped then
        if mapped.factionAlliance then
            local playerFaction = UnitFactionGroup("player")
            return {
                faction = playerFaction == "Alliance" and mapped.factionAlliance or mapped.factionHorde,
                standing = mapped.standing
            }
        end
        return { faction = mapped.faction, standing = mapped.standing }
    end

    -- Fallback: Parse dynamically (e.g., "Some Faction Exalted")
    local standingNames = { ["Exalted"] = 8, ["Revered"] = 7, ["Honored"] = 6, ["Friendly"] = 5 }
    for standingName, standingId in pairs(standingNames) do
        if source:find(standingName) then
            local factionPart = source:gsub(" " .. standingName, "")
            -- Try with/without "The" prefix
            if HopeAddon.ReputationData and HopeAddon.ReputationData.TBC_FACTIONS then
                if HopeAddon.ReputationData.TBC_FACTIONS[factionPart] then
                    return { faction = factionPart, standing = standingId }
                elseif HopeAddon.ReputationData.TBC_FACTIONS["The " .. factionPart] then
                    return { faction = "The " .. factionPart, standing = standingId }
                end
            end
        end
    end
    return nil
end

-- Get all reputation BiS items for a spec organized by faction and standing
-- @param guideKey string - Spec guide key like "WARRIOR_TANK"
-- @param phase number - Raid phase (default 1)
-- @return table - { [factionName] = { [standingId] = { items... } } }
function C:GetSpecReputationBisItems(guideKey, phase)
    phase = phase or 1
    local result = {}

    local specData = C.ARMORY_SPEC_BIS_DATABASE[phase] and C.ARMORY_SPEC_BIS_DATABASE[phase][guideKey]
    if not specData then return result end

    for slot, slotData in pairs(specData) do
        -- Check BiS item
        if slotData.bis and slotData.bis.sourceType == "reputation" then
            local repInfo = C:ParseReputationSource(slotData.bis.source)
            if repInfo then
                result[repInfo.faction] = result[repInfo.faction] or {}
                result[repInfo.faction][repInfo.standing] = result[repInfo.faction][repInfo.standing] or {}
                table.insert(result[repInfo.faction][repInfo.standing], {
                    itemId = slotData.bis.id,
                    name = slotData.bis.name,
                    slot = slot,
                    isBis = true,
                })
            end
        end

        -- Check alts array
        if slotData.alts then
            for _, altItem in ipairs(slotData.alts) do
                if altItem.sourceType == "reputation" then
                    local repInfo = C:ParseReputationSource(altItem.source)
                    if repInfo then
                        result[repInfo.faction] = result[repInfo.faction] or {}
                        result[repInfo.faction][repInfo.standing] = result[repInfo.faction][repInfo.standing] or {}
                        table.insert(result[repInfo.faction][repInfo.standing], {
                            itemId = altItem.id,
                            name = altItem.name,
                            slot = slot,
                            isBis = false,
                        })
                    end
                end
            end
        end
    end

    return result
end

-- =====================================================
-- BiS LOOKUP TABLES (Inverted Indexes for O(1) Queries)
-- =====================================================

-- Main lookup structure - rebuilt when spec/phase changes
-- Structure:
--   byFaction[factionName] = { { itemId, name, slot, standing, isBis, raidKey }, ... }
--   byBoss[bossName] = { { itemId, name, slot, isBis, raidKey }, ... }
--   byItemId[itemId] = { slot, isBis, sourceType, source }
--   meta = { guideKey, phase, buildTime }
-- Issue #71.3: Moved to module-level bisLookupCache to avoid Constants mutation

-- Build boss-to-raid reverse map from Constants boss tables
-- Uses existing BOSS_NAME_LOOKUP if available, otherwise builds from scratch
function C:GetBossRaidKey(bossName)
    if not bossName then return nil end

    -- Use existing lookup if available
    if C.BOSS_NAME_LOOKUP then
        local entry = C.BOSS_NAME_LOOKUP[bossName:lower()]
        if entry then return entry.raid end
    end

    -- Fallback: Search through raid boss tables
    local raidBossTables = {
        { raidKey = "karazhan", bosses = C.KARAZHAN_BOSSES },
        { raidKey = "gruul", bosses = C.GRUUL_BOSSES },
        { raidKey = "magtheridon", bosses = C.MAGTHERIDON_BOSSES },
        { raidKey = "ssc", bosses = C.SSC_BOSSES },
        { raidKey = "tk", bosses = C.TK_BOSSES },
        { raidKey = "hyjal", bosses = C.HYJAL_BOSSES },
        { raidKey = "bt", bosses = C.BT_BOSSES },
        { raidKey = "za", bosses = C.ZA_BOSSES },
        { raidKey = "sunwell", bosses = C.SUNWELL_BOSSES },
    }

    local lowerBossName = bossName:lower()
    for _, raidData in ipairs(raidBossTables) do
        if raidData.bosses then
            for _, boss in ipairs(raidData.bosses) do
                if boss.name:lower() == lowerBossName then
                    return raidData.raidKey
                end
            end
        end
    end

    return nil
end

-- Index a single BiS item into the lookup tables
-- @param item table - Item data from BiS database
-- @param slot string - Equipment slot
-- @param isBis boolean - True if this is the BiS item (not an alt)
-- @param phase number - Raid phase
function C:IndexBisItem(item, slot, isBis, phase)
    if not bisLookupCache or not item then return end

    local lookup = bisLookupCache

    -- Index by item ID for quick existence checks
    if item.id and item.id > 0 then
        lookup.byItemId[item.id] = {
            slot = slot,
            isBis = isBis,
            sourceType = item.sourceType,
            source = item.source,
        }
    end

    -- Index by faction (reputation items)
    if item.sourceType == "reputation" and item.source then
        local repInfo = self:ParseReputationSource(item.source)
        if repInfo and repInfo.faction then
            lookup.byFaction[repInfo.faction] = lookup.byFaction[repInfo.faction] or {}
            table.insert(lookup.byFaction[repInfo.faction], {
                itemId = item.id,
                name = item.name,
                slot = slot,
                standing = repInfo.standing,
                isBis = isBis,
            })
        end
    end

    -- Index by boss (raid items)
    if item.sourceType == "raid" and item.source then
        local raidKey = self:GetBossRaidKey(item.source)
        lookup.byBoss[item.source] = lookup.byBoss[item.source] or {}
        table.insert(lookup.byBoss[item.source], {
            itemId = item.id,
            name = item.name,
            slot = slot,
            isBis = isBis,
            raidKey = raidKey,
        })
    end
end

-- Build inverted lookup tables for fast O(1) queries
-- @param guideKey string - Spec guide key (e.g., "warrior-dps")
-- @param phase number - Raid phase (default 1)
function C:BuildBisLookupTables(guideKey, phase)
    phase = phase or 1
    local startTime = debugprofilestop and debugprofilestop() or 0

    -- Initialize fresh lookup structure
    bisLookupCache = {
        byFaction = {},
        byBoss = {},
        byItemId = {},
        meta = {
            guideKey = guideKey,
            phase = phase,
            buildTime = 0,
        }
    }

    local specData = C.ARMORY_SPEC_BIS_DATABASE[phase] and C.ARMORY_SPEC_BIS_DATABASE[phase][guideKey]
    if not specData then
        if HopeAddon.debug then
            HopeAddon:Debug("BIS_LOOKUP: No data for", guideKey, "phase", phase)
        end
        return
    end

    -- Index all items from this spec
    for slot, slotData in pairs(specData) do
        -- Index BiS item
        if slotData.bis then
            self:IndexBisItem(slotData.bis, slot, true, phase)
        end

        -- Index alternative items
        if slotData.alts then
            for _, altItem in ipairs(slotData.alts) do
                self:IndexBisItem(altItem, slot, false, phase)
            end
        end
    end

    -- Record build time
    local endTime = debugprofilestop and debugprofilestop() or 0
    bisLookupCache.meta.buildTime = endTime - startTime

    if HopeAddon.debug then
        local factionCount = 0
        for _ in pairs(bisLookupCache.byFaction) do factionCount = factionCount + 1 end
        local bossCount = 0
        for _ in pairs(bisLookupCache.byBoss) do bossCount = bossCount + 1 end
        local itemCount = 0
        for _ in pairs(bisLookupCache.byItemId) do itemCount = itemCount + 1 end

        HopeAddon:Debug(string.format(
            "BIS_LOOKUP built: %s phase %d - %d factions, %d bosses, %d items (%.2fms)",
            guideKey, phase, factionCount, bossCount, itemCount, bisLookupCache.meta.buildTime
        ))
    end
end

-- Ensure lookup tables are current for the given spec/phase
-- Rebuilds if cache is stale
-- @param guideKey string - Spec guide key
-- @param phase number - Raid phase
function C:EnsureBisLookupCurrent(guideKey, phase)
    phase = phase or 1

    -- Check if current lookup matches request
    if bisLookupCache and bisLookupCache.meta then
        local meta = bisLookupCache.meta
        if meta.guideKey == guideKey and meta.phase == phase then
            return -- Already current
        end
    end

    -- Rebuild lookup tables
    self:BuildBisLookupTables(guideKey, phase)
end

-- Get all BiS items for a given faction
-- @param factionName string - Faction name (e.g., "Lower City")
-- @return table - Array of { itemId, name, slot, standing, isBis }
function C:GetBisItemsForFaction(factionName)
    if not bisLookupCache or not bisLookupCache.byFaction then
        return {}
    end
    return bisLookupCache.byFaction[factionName] or {}
end

-- Get all BiS items that drop from a given boss
-- @param bossName string - Boss name (e.g., "Prince Malchezaar")
-- @return table - Array of { itemId, name, slot, isBis, raidKey }
function C:GetBisItemsForBoss(bossName)
    if not bisLookupCache or not bisLookupCache.byBoss then
        return {}
    end
    return bisLookupCache.byBoss[bossName] or {}
end

-- Get BiS info for an item by ID
-- @param itemId number - Item ID
-- @return table|nil - { slot, isBis, sourceType, source } or nil
function C:GetBisInfoForItem(itemId)
    if not bisLookupCache or not bisLookupCache.byItemId then
        return nil
    end
    return bisLookupCache.byItemId[itemId]
end

-- Check if an item is BiS for the currently indexed spec
-- @param itemId number - Item ID
-- @return boolean - True if item is BiS
function C:IsItemBisInLookup(itemId)
    local info = self:GetBisInfoForItem(itemId)
    return info and info.isBis or false
end

-- Get the currently active lookup metadata
-- @return table|nil - { guideKey, phase, buildTime } or nil
function C:GetBisLookupMeta()
    return bisLookupCache and bisLookupCache.meta
end

-- Issue #71.3: Getter for external access to lookup cache
-- @return table|nil - The BiS lookup cache or nil
function C:GetBisLookup()
    return bisLookupCache
end
