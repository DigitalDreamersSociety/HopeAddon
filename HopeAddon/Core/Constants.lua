--[[
    HopeAddon Constants
    All static data: milestones, zones, raids, quests
]]

HopeAddon = HopeAddon or {}
HopeAddon.Constants = HopeAddon.Constants or {}
local C = HopeAddon.Constants

--============================================================
-- LEVEL MILESTONES (Every 5 levels + special)
--============================================================
C.LEVEL_MILESTONES = {
    [5]  = { title = "First Blood",           icon = "Ability_Warrior_Charge",       story = "Your journey has truly begun." },
    [10] = { title = "The Path Chosen",       icon = "Spell_Holy_SealOfValor",       story = "You have chosen your destiny." },
    [15] = { title = "Into the Unknown",      icon = "Ability_Spy",                   story = "The world expands before you." },
    [20] = { title = "The Road Stretches On", icon = "INV_Misc_Spyglass_03",         story = "Miles traveled, miles to go." },
    [25] = { title = "Seasoned Traveler",     icon = "INV_Misc_Map_01",              story = "Experience hardens the spirit." },
    [30] = { title = "Halfway to Glory",      icon = "INV_Misc_Book_09",             story = "The summit is in sight." },
    [35] = { title = "Tempered by Battle",    icon = "Ability_Warrior_BattleShout",  story = "Scars tell your story." },
    [40] = { title = "Mount Up, Hero!",       icon = "Ability_Mount_RidingHorse",    story = "The world grew smaller today." },
    [45] = { title = "The Final Stretch",     icon = "Spell_Holy_CrusaderStrike",    story = "Power courses through you." },
    [50] = { title = "Legend in the Making",  icon = "INV_Misc_QirajiCrystal_01",    story = "They speak your name in hushed tones." },
    [55] = { title = "The Portal Beckons",    icon = "Spell_Arcane_TeleportStonard", story = "Green fire haunts your dreams." },
    [58] = { title = "Outland Awaits",        icon = "Spell_Fire_FelFlameRing",      story = "You are ready. The Portal calls." },
    [60] = { title = "Old World Champion",    icon = "Spell_Holy_ChampionsBond",     story = "Azeroth bows to your might." },
    [65] = { title = "Outland Veteran",       icon = "Spell_Arcane_PortalShattrath", story = "This strange land becomes home." },
    [70] = { title = "LEGEND",                icon = "Achievement_Boss_Illidan",     story = "Your legend is written in the stars." },
}

--============================================================
-- ZONE DISCOVERIES (TBC Zones)
--============================================================
C.ZONE_DISCOVERIES = {
    ["Hellfire Peninsula"] = {
        title = "Through the Portal",
        flavor = "The sky burns red. This is not Azeroth anymore.",
        icon = "Spell_Fire_FelFlameRing",
        levelRange = "58-63",
    },
    ["Zangarmarsh"] = {
        title = "The Mushroom Kingdom",
        flavor = "Bioluminescent wonder stretches in every direction.",
        icon = "INV_Mushroom_11",
        levelRange = "60-64",
    },
    ["Terokkar Forest"] = {
        title = "Among the Bones",
        flavor = "Draenei spirits linger in the shadow of Auchindoun.",
        icon = "Spell_Shadow_SoulGem",
        levelRange = "62-65",
    },
    ["Nagrand"] = {
        title = "Paradise Found",
        flavor = "Floating islands and endless grasslands. Beauty exists even here.",
        icon = "INV_Misc_Flower_01",
        levelRange = "64-67",
    },
    ["Blade's Edge Mountains"] = {
        title = "The Razor's Edge",
        flavor = "Giant blades of stone pierce the sky. Ogres rule this land.",
        icon = "INV_Sword_23",
        levelRange = "65-68",
    },
    ["Netherstorm"] = {
        title = "The Shattered Land",
        flavor = "Reality itself fractures at the edge of existence.",
        icon = "Spell_Arcane_Arcane02",
        levelRange = "67-70",
    },
    ["Shadowmoon Valley"] = {
        title = "Heart of Darkness",
        flavor = "The Black Temple looms. Illidan watches.",
        icon = "Spell_Shadow_Possession",
        levelRange = "67-70",
    },
    ["Shattrath City"] = {
        title = "City of Light",
        flavor = "Neutral ground. Aldor and Scryer. Choose wisely.",
        icon = "Spell_Arcane_PortalShattrath",
        levelRange = "All",
    },
}

--============================================================
-- TBC DUNGEONS (for stats tracking)
--============================================================
C.TBC_DUNGEONS = {
    -- Hellfire Citadel
    ["Hellfire Ramparts"] = {
        key = "ramparts",
        zone = "Hellfire Peninsula",
        finalBoss = "Nazan",
        finalBossNPC = 17536,
        icon = "Ability_Warrior_Rampage",
    },
    ["The Blood Furnace"] = {
        key = "blood_furnace",
        zone = "Hellfire Peninsula",
        finalBoss = "Keli'dan the Breaker",
        finalBossNPC = 17377,
        icon = "Spell_Shadow_RitualOfSacrifice",
    },
    ["The Shattered Halls"] = {
        key = "shattered_halls",
        zone = "Hellfire Peninsula",
        finalBoss = "Warchief Kargath Bladefist",
        finalBossNPC = 16808,
        icon = "Ability_Warrior_Rampage",
    },
    -- Coilfang Reservoir
    ["The Slave Pens"] = {
        key = "slave_pens",
        zone = "Zangarmarsh",
        finalBoss = "Quagmirran",
        finalBossNPC = 17942,
        icon = "INV_Misc_Fish_14",
    },
    ["The Underbog"] = {
        key = "underbog",
        zone = "Zangarmarsh",
        finalBoss = "The Black Stalker",
        finalBossNPC = 17882,
        icon = "Ability_Hunter_Pet_Spider",
    },
    ["The Steamvault"] = {
        key = "steamvault",
        zone = "Zangarmarsh",
        finalBoss = "Warlord Kalithresh",
        finalBossNPC = 17798,
        icon = "INV_Gizmo_02",
    },
    -- Auchindoun
    ["Mana-Tombs"] = {
        key = "mana_tombs",
        zone = "Terokkar Forest",
        finalBoss = "Nexus-Prince Shaffar",
        finalBossNPC = 18344,
        icon = "Spell_Arcane_PortalShattrath",
    },
    ["Auchenai Crypts"] = {
        key = "auchenai_crypts",
        zone = "Terokkar Forest",
        finalBoss = "Exarch Maladaar",
        finalBossNPC = 18373,
        icon = "Spell_Shadow_DeathPact",
    },
    ["Sethekk Halls"] = {
        key = "sethekk_halls",
        zone = "Terokkar Forest",
        finalBoss = "Talon King Ikiss",
        finalBossNPC = 18473,
        icon = "Ability_Hunter_Pet_Owl",
    },
    ["Shadow Labyrinth"] = {
        key = "shadow_lab",
        zone = "Terokkar Forest",
        finalBoss = "Murmur",
        finalBossNPC = 18708,
        icon = "Spell_Shadow_ShadeTrueSight",
    },
    -- Tempest Keep
    ["The Mechanar"] = {
        key = "mechanar",
        zone = "Netherstorm",
        finalBoss = "Pathaleon the Calculator",
        finalBossNPC = 19220,
        icon = "INV_Misc_Gear_08",
    },
    ["The Botanica"] = {
        key = "botanica",
        zone = "Netherstorm",
        finalBoss = "Warp Splinter",
        finalBossNPC = 17977,
        icon = "Spell_Nature_ProtectionformNature",
    },
    ["The Arcatraz"] = {
        key = "arcatraz",
        zone = "Netherstorm",
        finalBoss = "Harbinger Skyriss",
        finalBossNPC = 20912,
        icon = "Spell_Arcane_Arcane01",
    },
    -- Caverns of Time
    ["Old Hillsbrad Foothills"] = {
        key = "old_hillsbrad",
        zone = "Tanaris",
        finalBoss = "Epoch Hunter",
        finalBossNPC = 18096,
        icon = "Spell_Arcane_PortalOrgrimmar",
    },
    ["The Black Morass"] = {
        key = "black_morass",
        zone = "Tanaris",
        finalBoss = "Aeonus",
        finalBossNPC = 17881,
        icon = "Spell_Arcane_PortalOrgrimmar",
    },
    -- Isle of Quel'Danas
    ["Magisters' Terrace"] = {
        key = "magisters_terrace",
        zone = "Isle of Quel'Danas",
        finalBoss = "Kael'thas Sunstrider",
        finalBossNPC = 24664,
        icon = "Spell_Fire_BurnoutGreen",
    },
}

-- Reverse lookup: NPC ID -> dungeon key
C.DUNGEON_BOSS_NPC_IDS = {}
for dungeonName, data in pairs(C.TBC_DUNGEONS) do
    if data.finalBossNPC then
        C.DUNGEON_BOSS_NPC_IDS[data.finalBossNPC] = {
            dungeon = data.key,
            name = dungeonName,
        }
    end
end

-- Outland zones list (for counting Outland exploration)
C.OUTLAND_ZONES = {
    "Hellfire Peninsula",
    "Zangarmarsh",
    "Terokkar Forest",
    "Nagrand",
    "Blade's Edge Mountains",
    "Netherstorm",
    "Shadowmoon Valley",
    "Shattrath City",
}

--============================================================
-- KARAZHAN ATTUNEMENT DATA
--============================================================
C.KARAZHAN_ATTUNEMENT = {
    name = "The Master's Key",
    icon = "INV_Misc_Key_10",
    headerIcon = "INV_Misc_Key_10",
    raidName = "Karazhan",
    raidKey = "karazhan",

    chapters = {
        {
            name = "The Call",
            story = "Strange energies draw you to Deadwind Pass...",
            locationIcon = "Spell_Arcane_PortalShattrath",
            quests = {
                { id = 9824, name = "Arcane Disturbances" },
                { id = 9825, name = "Restless Activity" },
            },
        },
        {
            name = "Contact from Dalaran",
            story = "Archmage Cedric in Alterac Mountains awaits...",
            locationIcon = "Spell_Holy_MindSooth",
            quests = {
                { id = 9826, name = "Contact from Dalaran" },
            },
        },
        {
            name = "Khadgar's Request",
            story = "The Archmage needs your help to forge a new key...",
            locationIcon = "Spell_Arcane_PortalShattrath",
            quests = {
                { id = 9829, name = "Khadgar" },
            },
        },
        {
            name = "The First Fragment",
            story = "Shadow Labyrinth holds the first piece...",
            locationIcon = "Spell_Shadow_ShadeTrueSight",
            quests = {
                { id = 9831, name = "Entry Into Karazhan", dungeon = "Shadow Labyrinth" },
            },
        },
        {
            name = "The Second and Third Fragments",
            story = "The Steamvault and Arcatraz hold the remaining pieces...",
            locationIcon = "INV_Gizmo_02",
            quests = {
                { id = 9832, name = "The Second and Third Fragments", dungeons = {"The Steamvault", "The Arcatraz"} },
            },
        },
        {
            name = "The Master's Touch",
            story = "Travel through time to forge the key...",
            locationIcon = "Spell_Arcane_PortalOrgrimmar",
            quests = {
                { id = 9836, name = "The Master's Touch", dungeon = "The Black Morass" },
            },
        },
        {
            name = "The Key is Yours",
            story = "Return to Khadgar with your completed key...",
            locationIcon = "INV_Misc_Key_10",
            quests = {
                { id = 9837, name = "Return to Khadgar", reward = "The Master's Key" },
            },
        },
    },
}

-- Quest ID lookup by chapter for fast checking
C.KARAZHAN_QUEST_IDS = {
    [1] = { 9824, 9825 },
    [2] = { 9826 },
    [3] = { 9829 },
    [4] = { 9831 },
    [5] = { 9832 },
    [6] = { 9836 },
    [7] = { 9837 },
}

-- Pre-build quest ID to chapter lookup for O(1) access
C.QUEST_TO_CHAPTER = {}
for chapter, quests in ipairs(C.KARAZHAN_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.QUEST_TO_CHAPTER[questId] = chapter
    end
end

-- O(1) lookup instead of iterating
function C:GetChapterForQuest(questId)
    return self.QUEST_TO_CHAPTER[questId]
end

--============================================================
-- SERPENTSHRINE CAVERN ATTUNEMENT
--============================================================
C.SSC_ATTUNEMENT = {
    name = "The Cudgel of Kar'desh",
    icon = "INV_Wand_07",
    headerIcon = "INV_Misc_MonsterClaw_03",
    raidName = "Serpentshrine Cavern",
    raidKey = "ssc",
    title = "Champion of the Naaru",

    chapters = {
        {
            name = "The Cudgel of Kar'desh",
            story = "Skar'this the Heretic in the Slave Pens needs the signets of the elements to forge the Cudgel...",
            locationIcon = "INV_Misc_Fish_14",
            quests = {
                { id = 10901, name = "The Cudgel of Kar'desh", requires = {"Earthen Signet (Gruul)", "Blazing Signet (Nightbane)"} },
            },
        },
    },
}

C.SSC_QUEST_IDS = {
    [1] = { 10901 },
}

--============================================================
-- TEMPEST KEEP (THE EYE) ATTUNEMENT
--============================================================
C.TK_ATTUNEMENT = {
    name = "The Tempest Key",
    icon = "Spell_Fire_BurnoutGreen",
    headerIcon = "Spell_Arcane_PortalShattrath",
    raidName = "Tempest Keep: The Eye",
    raidKey = "tk",
    prerequisite = "Cipher of Damnation",

    chapters = {
        {
            name = "The Tempest Key",
            story = "A'dal in Shattrath recognizes your deeds and begins your trials...",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10883, name = "The Tempest Key" },
            },
        },
        {
            name = "Trial of the Naaru: Mercy",
            story = "Save the prisoners in Heroic Shattered Halls before they are executed...",
            locationIcon = "Ability_Warrior_Rampage",
            quests = {
                { id = 10884, name = "Trial of the Naaru: Mercy", dungeon = "Heroic Shattered Halls", requires = "Save prisoners, obtain Executioner's Axe" },
            },
        },
        {
            name = "Trial of the Naaru: Strength",
            story = "Prove your strength by retrieving artifacts from two Heroic dungeons...",
            locationIcon = "INV_Gizmo_02",
            quests = {
                { id = 10885, name = "Trial of the Naaru: Strength", dungeons = {"Heroic Steamvault", "Heroic Shadow Labyrinth"}, requires = "Kalithresh's Trident + Murmur's Essence" },
            },
        },
        {
            name = "Trial of the Naaru: Tenacity",
            story = "Protect Millhouse Manastorm in Heroic Arcatraz...",
            locationIcon = "Spell_Arcane_Arcane01",
            quests = {
                { id = 10886, name = "Trial of the Naaru: Tenacity", dungeon = "Heroic Arcatraz", requires = "Keep Millhouse Manastorm alive" },
            },
        },
        {
            name = "Trial of the Naaru: Magtheridon",
            story = "Defeat the Pit Lord imprisoned beneath Hellfire Citadel...",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10888, name = "Trial of the Naaru: Magtheridon", raid = "Magtheridon's Lair (25-man)" },
            },
        },
    },
}

C.TK_QUEST_IDS = {
    [1] = { 10883 },
    [2] = { 10884 },
    [3] = { 10885 },
    [4] = { 10886 },
    [5] = { 10888 },
}

--============================================================
-- CIPHER OF DAMNATION (TK Prerequisite)
--============================================================
C.CIPHER_OF_DAMNATION = {
    name = "The Cipher of Damnation",
    icon = "INV_Misc_Book_06",
    headerIcon = "Spell_Shadow_Possession",
    zone = "Shadowmoon Valley",
    raidKey = "cipher",

    -- Starting quest is faction-specific
    startingQuests = {
        horde = 10680,    -- The Hand of Gul'dan (Horde)
        alliance = 10681, -- The Hand of Gul'dan (Alliance)
    },

    chapters = {
        {
            name = "The Hand of Gul'dan",
            story = "Investigate the corruption at the Hand of Gul'dan...",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10680, name = "The Hand of Gul'dan", faction = "Horde" },
                { id = 10681, name = "The Hand of Gul'dan", faction = "Alliance" },
            },
        },
        {
            name = "Enraged Spirits",
            story = "The elemental spirits are enraged by the corruption...",
            locationIcon = "Spell_Fire_Burnout",
            quests = {
                { id = 10458, name = "Enraged Spirits of Fire and Earth" },
                { id = 10480, name = "Enraged Spirits of Water" },
                { id = 10481, name = "Enraged Spirits of Air" },
            },
        },
        {
            name = "Oronok's Legacy",
            story = "Oronok Torn-heart holds the key to the Cipher...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10512, name = "Oronok Torn-heart" },
                { id = 10514, name = "I Was A Lot Of Things..." },
                { id = 10515, name = "A Lesson Learned" },
                { id = 10519, name = "The Cipher of Damnation - Truth and History" },
            },
        },
        {
            name = "Grom'tor's Fragment",
            story = "Oronok's first son guards a fragment of the Cipher...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10520, name = "Grom'tor, Son of Oronok" },
                { id = 10521, name = "The Cipher of Damnation - Grom'tor's Charge" },
                { id = 10522, name = "The Cipher of Damnation - The First Fragment Recovered" },
            },
        },
        {
            name = "Ar'tor's Fragment",
            story = "The second son requires your aid to recover his fragment...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10536, name = "Ar'tor, Son of Oronok" },
                { id = 10537, name = "Demonic Crystal Prisons" },
                { id = 10538, name = "Lohn'goron, Bow of the Torn-heart" },
                { id = 10540, name = "The Cipher of Damnation - Ar'tor's Charge" },
                { id = 10541, name = "The Cipher of Damnation - The Second Fragment Recovered" },
            },
        },
        {
            name = "Borak's Fragment",
            story = "The third son's fragment lies in dangerous territory...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10563, name = "Borak, Son of Oronok" },
                { id = 10564, name = "Of Thistleheads and Eggs..." },
                { id = 10566, name = "The Bundle of Bloodthistle" },
                { id = 10567, name = "To Catch A Thistlehead" },
                { id = 10578, name = "The Cipher of Damnation - Borak's Charge" },
                { id = 10579, name = "The Cipher of Damnation - The Third Fragment Recovered" },
            },
        },
        {
            name = "The Cipher Complete",
            story = "With all fragments assembled, face Cyrukh the Firelord...",
            locationIcon = "Spell_Fire_Burnout",
            quests = {
                { id = 10588, name = "The Cipher of Damnation", boss = "Cyrukh the Firelord" },
            },
        },
    },
}

C.CIPHER_QUEST_IDS = {
    [1] = { 10680, 10681 },
    [2] = { 10458, 10480, 10481 },
    [3] = { 10512, 10514, 10515, 10519 },
    [4] = { 10520, 10521, 10522 },
    [5] = { 10536, 10537, 10538, 10540, 10541 },
    [6] = { 10563, 10564, 10566, 10567, 10578, 10579 },
    [7] = { 10588 },
}

--============================================================
-- MOUNT HYJAL ATTUNEMENT
--============================================================
C.HYJAL_ATTUNEMENT = {
    name = "The Vials of Eternity",
    icon = "INV_Potion_101",
    headerIcon = "Spell_Fire_Burnout",
    raidName = "Mount Hyjal",
    raidKey = "hyjal",

    chapters = {
        {
            name = "The Vials of Eternity",
            story = "Soridormi in the Caverns of Time requires the vials held by the most powerful beings in Outland...",
            locationIcon = "Spell_Arcane_PortalOrgrimmar",
            quests = {
                { id = 10445, name = "The Vials of Eternity", requires = {"Vashj's Vial Remnant (Lady Vashj)", "Kael's Vial Remnant (Kael'thas)"} },
            },
        },
    },
}

C.HYJAL_QUEST_IDS = {
    [1] = { 10445 },
}

--============================================================
-- BLACK TEMPLE ATTUNEMENT
--============================================================
C.BT_ATTUNEMENT = {
    name = "Medallion of Karabor",
    icon = "INV_Jewelry_Necklace_36",
    headerIcon = "Achievement_Boss_Illidan",
    raidName = "Black Temple",
    raidKey = "bt",
    hasFactionStart = true,

    -- Aldor starting chain
    aldorChapters = {
        {
            name = "Tablets of Baa'ri (Aldor)",
            story = "The Aldor seek knowledge of the Ashtongue Deathsworn...",
            locationIcon = "INV_Misc_Token_Aldor",
            quests = {
                { id = 10568, name = "Tablets of Baa'ri" },
            },
        },
        {
            name = "Oronu the Elder (Aldor)",
            story = "Find and speak with Oronu the Elder...",
            locationIcon = "INV_Misc_Token_Aldor",
            quests = {
                { id = 10571, name = "Oronu the Elder" },
            },
        },
        {
            name = "The Ashtongue Corruptors (Aldor)",
            story = "Eliminate the Ashtongue corruptors...",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10574, name = "The Ashtongue Corruptors" },
            },
        },
        {
            name = "The Warden's Cage (Aldor)",
            story = "Find Akama's prison...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10575, name = "The Warden's Cage" },
            },
        },
    },

    -- Scryer starting chain
    scryerChapters = {
        {
            name = "Tablets of Baa'ri (Scryer)",
            story = "The Scryers seek knowledge of the Ashtongue Deathsworn...",
            locationIcon = "INV_Misc_Token_Scryer",
            quests = {
                { id = 10683, name = "Tablets of Baa'ri" },
            },
        },
        {
            name = "Oronu the Elder (Scryer)",
            story = "Find and speak with Oronu the Elder...",
            locationIcon = "INV_Misc_Token_Scryer",
            quests = {
                { id = 10684, name = "Oronu the Elder" },
            },
        },
        {
            name = "The Ashtongue Corruptors (Scryer)",
            story = "Eliminate the Ashtongue corruptors...",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10685, name = "The Ashtongue Corruptors" },
            },
        },
        {
            name = "The Warden's Cage (Scryer)",
            story = "Find Akama's prison...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10686, name = "The Warden's Cage" },
            },
        },
    },

    -- Shared chapters (after faction-specific)
    chapters = {
        {
            name = "Proof of Allegiance",
            story = "Prove your allegiance by eliminating Zandras...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10622, name = "Proof of Allegiance", requires = "Kill Zandras" },
            },
        },
        {
            name = "Akama",
            story = "Speak with Akama, leader of the Ashtongue Deathsworn...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10628, name = "Akama" },
            },
        },
        {
            name = "A Mysterious Portent",
            story = "Find Seer Udalo within the Arcatraz...",
            locationIcon = "Spell_Arcane_Arcane01",
            quests = {
                { id = 10706, name = "A Mysterious Portent", dungeon = "The Arcatraz" },
            },
        },
        {
            name = "The Ata'mal Terrace",
            story = "Retrieve the Heart of Fury from Shadowmoon Valley...",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10707, name = "The Ata'mal Terrace", requires = "Heart of Fury" },
            },
        },
        {
            name = "Akama's Promise",
            story = "Return to A'dal with Akama's promise...",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10708, name = "Akama's Promise" },
            },
        },
        {
            name = "The Secret Compromised",
            story = "Fathom-Lord Karathress must be eliminated...",
            locationIcon = "INV_Misc_MonsterClaw_03",
            quests = {
                { id = 10944, name = "The Secret Compromised", raid = "Serpentshrine Cavern", boss = "Fathom-Lord Karathress" },
            },
        },
        {
            name = "Ruse of the Ashtongue",
            story = "Don the Ashtongue Cowl and slay Al'ar in Tempest Keep...",
            locationIcon = "Spell_Arcane_PortalShattrath",
            quests = {
                { id = 10946, name = "Ruse of the Ashtongue", raid = "Tempest Keep", boss = "Al'ar", requires = "Wear Ashtongue Cowl" },
            },
        },
        {
            name = "An Artifact From the Past",
            story = "Journey to Mount Hyjal and retrieve a Time-Phased Phylactery...",
            locationIcon = "Spell_Fire_Burnout",
            quests = {
                { id = 10947, name = "An Artifact From the Past", raid = "Mount Hyjal", boss = "Rage Winterchill" },
            },
        },
        {
            name = "The Hostage Soul",
            story = "Speak with A'dal about the Medallion of Karabor...",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10948, name = "The Hostage Soul" },
            },
        },
        {
            name = "Entry into the Black Temple",
            story = "Xi'ri awaits at the gates of the Black Temple...",
            locationIcon = "Achievement_Boss_Illidan",
            quests = {
                { id = 10949, name = "Entry Into the Black Temple" },
            },
        },
        {
            name = "A Distraction for Akama",
            story = "The final step - aid Akama's assault on the temple...",
            locationIcon = "Achievement_Boss_Illidan",
            quests = {
                { id = 10985, name = "A Distraction for Akama", reward = "Medallion of Karabor" },
            },
        },
    },
}

C.BT_QUEST_IDS = {
    -- Aldor starting chain (1-4)
    aldor = {
        [1] = { 10568 },
        [2] = { 10571 },
        [3] = { 10574 },
        [4] = { 10575 },
    },
    -- Scryer starting chain (1-4)
    scryer = {
        [1] = { 10683 },
        [2] = { 10684 },
        [3] = { 10685 },
        [4] = { 10686 },
    },
    -- Shared chain (chapters 5-15, stored as 5-15)
    shared = {
        [5] = { 10622 },
        [6] = { 10628 },
        [7] = { 10706 },
        [8] = { 10707 },
        [9] = { 10708 },
        [10] = { 10944 },
        [11] = { 10946 },
        [12] = { 10947 },
        [13] = { 10948 },
        [14] = { 10949 },
        [15] = { 10985 },
    },
}

--============================================================
-- ALL ATTUNEMENTS LIST
--============================================================
C.ALL_ATTUNEMENTS = {
    { key = "karazhan", data = C.KARAZHAN_ATTUNEMENT, tier = "T4", order = 1 },
    { key = "ssc", data = C.SSC_ATTUNEMENT, tier = "T5", order = 2 },
    { key = "tk", data = C.TK_ATTUNEMENT, tier = "T5", order = 3, prerequisite = "cipher" },
    { key = "hyjal", data = C.HYJAL_ATTUNEMENT, tier = "T6", order = 4 },
    { key = "bt", data = C.BT_ATTUNEMENT, tier = "T6", order = 5 },
}

-- Pre-build lookup for all attunement quest IDs
C.ATTUNEMENT_QUEST_LOOKUP = {}

-- Add Karazhan quests
for chapter, quests in ipairs(C.KARAZHAN_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "karazhan", chapter = chapter }
    end
end

-- Add SSC quests
for chapter, quests in ipairs(C.SSC_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "ssc", chapter = chapter }
    end
end

-- Add TK quests
for chapter, quests in ipairs(C.TK_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "tk", chapter = chapter }
    end
end

-- Add Cipher quests (as TK prerequisite)
for chapter, quests in ipairs(C.CIPHER_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "cipher", chapter = chapter }
    end
end

-- Add Hyjal quests
for chapter, quests in ipairs(C.HYJAL_QUEST_IDS) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "hyjal", chapter = chapter }
    end
end

-- Add BT quests (Aldor)
for chapter, quests in pairs(C.BT_QUEST_IDS.aldor) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "bt", chapter = chapter, faction = "aldor" }
    end
end

-- Add BT quests (Scryer)
for chapter, quests in pairs(C.BT_QUEST_IDS.scryer) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "bt", chapter = chapter, faction = "scryer" }
    end
end

-- Add BT quests (Shared)
for chapter, quests in pairs(C.BT_QUEST_IDS.shared) do
    for _, questId in ipairs(quests) do
        C.ATTUNEMENT_QUEST_LOOKUP[questId] = { raid = "bt", chapter = chapter }
    end
end

-- Extended lookup function for all attunements
function C:GetAttunementForQuest(questId)
    return self.ATTUNEMENT_QUEST_LOOKUP[questId]
end

--============================================================
-- ATTUNEMENT COMPLETION MILESTONES
--============================================================
C.ATTUNEMENT_MILESTONES = {
    karazhan = {
        title = "Key to the Tower",
        story = "The Master's Key is yours. Karazhan awaits.",
        icon = "INV_Misc_Key_10",
    },
    ssc = {
        title = "Into the Depths",
        story = "The Cudgel of Kar'desh grants you passage. Lady Vashj's sanctum lies open before you.",
        icon = "Spell_Frost_SummonWaterElemental",
    },
    tk = {
        title = "The Trials Complete",
        story = "A'dal's trials are complete. The Eye awaits those who proved worthy.",
        icon = "Spell_Fire_BurnoutGreen",
    },
    hyjal = {
        title = "Witness to History",
        story = "With the Vials of Eternity, you may witness the Battle for Mount Hyjal.",
        icon = "INV_Potion_101",
    },
    bt = {
        title = "Illidan Awaits",
        story = "The Medallion of Karabor marks you as ally to Akama. The Black Temple opens its gates.",
        icon = "INV_Jewelry_Necklace_36",
    },
}

--============================================================
-- RAID BOSS DEFEAT MILESTONES
--============================================================
C.BOSS_MILESTONES = {
    -- First boss of each raid tier
    first_t4_boss = {
        title = "Tier 4 Begins",
        story = "Your first step into organized raiding.",
        icon = "INV_Misc_Key_10",
    },
    first_t5_boss = {
        title = "Tier 5 Begins",
        story = "The 25-player content of Outland opens before you.",
        icon = "Spell_Frost_SummonWaterElemental",
    },
    first_t6_boss = {
        title = "Tier 6 Begins",
        story = "The final challenges of Outland await.",
        icon = "Achievement_Boss_Illidan",
    },

    -- Final bosses
    prince = {
        title = "Karazhan Champion",
        story = "Prince Malchezaar has fallen. Karazhan is conquered.",
        icon = "Spell_Shadow_SummonFelGuard",
        raid = "karazhan",
    },
    gruul = {
        title = "Dragonkiller's End",
        story = "The mightiest of Gronn lies broken.",
        icon = "Ability_Hunter_Pet_Devilsaur",
        raid = "gruul",
    },
    magtheridon = {
        title = "Pit Lord Vanquished",
        story = "Magtheridon's chains are finally broken - by death.",
        icon = "Spell_Shadow_SummonFelGuard",
        raid = "magtheridon",
    },
    vashj = {
        title = "Lady of the Depths",
        story = "Lady Vashj, servant of Illidan, is no more.",
        icon = "Spell_Frost_SummonWaterElemental",
        raid = "ssc",
    },
    kaelthas = {
        title = "The Betrayer's Lieutenant",
        story = "Kael'thas Sunstrider has fallen. The Eye is cleared.",
        icon = "Spell_Fire_BurnoutGreen",
        raid = "tk",
    },
    archimonde = {
        title = "History Preserved",
        story = "Archimonde falls as he did in ages past. Time is preserved.",
        icon = "INV_Elemental_Primal_Shadow",
        raid = "hyjal",
    },
    illidan = {
        title = "The Betrayer's End",
        story = "Illidan Stormrage lies defeated. You are prepared.",
        icon = "Achievement_Boss_Illidan",
        raid = "bt",
    },

    -- Special milestones
    raid_leader = {
        title = "Raid Leader",
        story = "Your first final boss kill. A true leader of adventurers.",
        icon = "INV_Crown_01",
    },
}

--============================================================
-- TBC CLASSIC ENCOUNTER ID MAPPING
--============================================================
-- Maps encounter IDs to our internal boss/raid identifiers
-- Used for automatic boss kill detection via ENCOUNTER_END event
C.ENCOUNTER_TO_BOSS = {
    -- Karazhan (T4)
    [652]  = { raid = "karazhan", boss = "attumen" },
    [653]  = { raid = "karazhan", boss = "moroes" },
    [654]  = { raid = "karazhan", boss = "maiden" },
    [655]  = { raid = "karazhan", boss = "opera" },
    [656]  = { raid = "karazhan", boss = "curator" },
    [657]  = { raid = "karazhan", boss = "illhoof" },
    [658]  = { raid = "karazhan", boss = "aran" },
    [659]  = { raid = "karazhan", boss = "netherspite" },
    [660]  = { raid = "karazhan", boss = "chess" },
    [661]  = { raid = "karazhan", boss = "prince" },
    [662]  = { raid = "karazhan", boss = "nightbane" },
    -- Gruul's Lair (T4)
    [649]  = { raid = "gruul", boss = "maulgar" },
    [650]  = { raid = "gruul", boss = "gruul" },
    -- Magtheridon's Lair (T4)
    [651]  = { raid = "magtheridon", boss = "magtheridon" },
    -- Serpentshrine Cavern (T5)
    [623]  = { raid = "ssc", boss = "hydross" },
    [624]  = { raid = "ssc", boss = "lurker" },
    [625]  = { raid = "ssc", boss = "tidewalker" },
    [626]  = { raid = "ssc", boss = "karathress" },
    [627]  = { raid = "ssc", boss = "leotheras" },
    [628]  = { raid = "ssc", boss = "vashj" },
    -- Tempest Keep: The Eye (T5)
    [730]  = { raid = "tk", boss = "alar" },
    [731]  = { raid = "tk", boss = "voidreaver" },
    [732]  = { raid = "tk", boss = "solarian" },
    [733]  = { raid = "tk", boss = "kaelthas" },
    -- Battle for Mount Hyjal (T6)
    [618]  = { raid = "hyjal", boss = "winterchill" },
    [619]  = { raid = "hyjal", boss = "anetheron" },
    [620]  = { raid = "hyjal", boss = "kazrogal" },
    [621]  = { raid = "hyjal", boss = "azgalor" },
    [622]  = { raid = "hyjal", boss = "archimonde" },
    -- Black Temple (T6)
    [601]  = { raid = "bt", boss = "najentus" },
    [602]  = { raid = "bt", boss = "supremus" },
    [603]  = { raid = "bt", boss = "akama" },
    [604]  = { raid = "bt", boss = "gorefiend" },
    [605]  = { raid = "bt", boss = "bloodboil" },
    [606]  = { raid = "bt", boss = "reliquary" },
    [607]  = { raid = "bt", boss = "shahraz" },
    [608]  = { raid = "bt", boss = "council" },
    [609]  = { raid = "bt", boss = "illidan" },
}

--============================================================
-- BOSS NPC IDs FOR COMBAT_LOG FALLBACK
-- Used when ENCOUNTER_END event doesn't fire (TBC Classic compatibility)
--============================================================
C.BOSS_NPC_IDS = {
    -- Karazhan (T4)
    [15550] = { raid = "karazhan", boss = "attumen" },   -- Attumen the Huntsman
    [15687] = { raid = "karazhan", boss = "moroes" },    -- Moroes
    [16457] = { raid = "karazhan", boss = "maiden" },    -- Maiden of Virtue
    [17521] = { raid = "karazhan", boss = "opera" },     -- The Big Bad Wolf
    [17533] = { raid = "karazhan", boss = "opera" },     -- Romulo
    [17534] = { raid = "karazhan", boss = "opera" },     -- Julianne
    [18168] = { raid = "karazhan", boss = "opera" },     -- The Crone
    [15691] = { raid = "karazhan", boss = "curator" },   -- The Curator
    [16524] = { raid = "karazhan", boss = "aran" },      -- Shade of Aran
    [15688] = { raid = "karazhan", boss = "illhoof" },   -- Terestian Illhoof
    [15689] = { raid = "karazhan", boss = "netherspite" }, -- Netherspite
    [16152] = { raid = "karazhan", boss = "chess" },     -- King's chess piece (attumen)
    [15690] = { raid = "karazhan", boss = "prince" },    -- Prince Malchezaar
    [17225] = { raid = "karazhan", boss = "nightbane" }, -- Nightbane
    -- Gruul's Lair (T4)
    [18831] = { raid = "gruul", boss = "maulgar" },      -- High King Maulgar
    [19044] = { raid = "gruul", boss = "gruul" },        -- Gruul the Dragonkiller
    -- Magtheridon's Lair (T4)
    [17257] = { raid = "magtheridon", boss = "magtheridon" }, -- Magtheridon
    -- Serpentshrine Cavern (T5)
    [21216] = { raid = "ssc", boss = "hydross" },        -- Hydross the Unstable
    [21217] = { raid = "ssc", boss = "lurker" },         -- The Lurker Below
    [21213] = { raid = "ssc", boss = "tidewalker" },     -- Morogrim Tidewalker
    [21214] = { raid = "ssc", boss = "karathress" },     -- Fathom-Lord Karathress
    [21215] = { raid = "ssc", boss = "leotheras" },      -- Leotheras the Blind
    [21212] = { raid = "ssc", boss = "vashj" },          -- Lady Vashj
    -- Tempest Keep: The Eye (T5)
    [19514] = { raid = "tk", boss = "alar" },            -- Al'ar
    [19516] = { raid = "tk", boss = "voidreaver" },      -- Void Reaver
    [18805] = { raid = "tk", boss = "solarian" },        -- High Astromancer Solarian
    [19622] = { raid = "tk", boss = "kaelthas" },        -- Kael'thas Sunstrider
    -- Battle for Mount Hyjal (T6)
    [17767] = { raid = "hyjal", boss = "winterchill" },  -- Rage Winterchill
    [17808] = { raid = "hyjal", boss = "anetheron" },    -- Anetheron
    [17888] = { raid = "hyjal", boss = "kazrogal" },     -- Kaz'rogal
    [17842] = { raid = "hyjal", boss = "azgalor" },      -- Azgalor
    [17968] = { raid = "hyjal", boss = "archimonde" },   -- Archimonde
    -- Black Temple (T6)
    [22887] = { raid = "bt", boss = "najentus" },        -- High Warlord Naj'entus
    [22898] = { raid = "bt", boss = "supremus" },        -- Supremus
    [22841] = { raid = "bt", boss = "akama" },           -- Shade of Akama
    [22871] = { raid = "bt", boss = "gorefiend" },       -- Teron Gorefiend
    [22948] = { raid = "bt", boss = "bloodboil" },       -- Gurtogg Bloodboil
    [22856] = { raid = "bt", boss = "reliquary" },       -- Essence of Suffering (first of RoS)
    [22855] = { raid = "bt", boss = "reliquary" },       -- Essence of Desire (second of RoS)
    [22857] = { raid = "bt", boss = "reliquary" },       -- Essence of Anger (final of RoS)
    [22947] = { raid = "bt", boss = "shahraz" },         -- Mother Shahraz
    [22949] = { raid = "bt", boss = "council" },         -- Gathios the Shatterer
    [22950] = { raid = "bt", boss = "council" },         -- High Nethermancer Zerevor
    [22951] = { raid = "bt", boss = "council" },         -- Lady Malande
    [22952] = { raid = "bt", boss = "council" },         -- Veras Darkshadow
    [22917] = { raid = "bt", boss = "illidan" },         -- Illidan Stormrage
}

--============================================================
-- T4 RAID BOSS DATA
--============================================================

-- KARAZHAN BOSSES
C.KARAZHAN_BOSSES = {
    {
        id = "attumen",
        name = "Attumen the Huntsman",
        location = "Stables",
        optional = true,
        lore = "The Huntsman rides eternally, seeking prey in the tower's depths.",
        quote = "It was... a good hunt.",
        icon = "Ability_Mount_Undeadhorse",
        mechanics = {
            "Tank and spank with Midnight (horse)",
            "At 95%, Attumen spawns",
            "At 25%, they merge - increased damage",
        },
        notableLoot = {
            { name = "Fiery Warhorse", type = "Mount", dropRate = "~1%" },
            { name = "Stalker's War Bands", type = "Mail Bracers" },
        },
    },
    {
        id = "moroes",
        name = "Moroes",
        location = "Banquet Hall",
        optional = false,
        lore = "The steward of Karazhan hosts an eternal dinner party of the undead.",
        quote = "How terribly clumsy of me.",
        icon = "INV_Misc_Key_03",
        mechanics = {
            "4 random adds from a pool of 6",
            "Garrote - bleeds random target",
            "Gouge - stuns tank, have OT ready",
            "CC the adds, kill one at a time",
        },
        notableLoot = {
            { name = "Moroes' Lucky Pocket Watch", type = "Trinket" },
            { name = "Shadow-Cloak of Dalaran", type = "Back" },
        },
    },
    {
        id = "maiden",
        name = "Maiden of Virtue",
        location = "Guest Chambers",
        optional = true,
        lore = "A construct of holy energy, she punishes the impure.",
        quote = "Your eternities shall be spent in anguish!",
        icon = "Spell_Holy_HolyBolt",
        mechanics = {
            "Repentance - 12 sec incapacitate on all nearby",
            "Holy Fire - interruptible, heavy damage",
            "Holy Ground - consecration-like AoE",
        },
    },
    {
        id = "opera",
        name = "Opera Event",
        location = "Opera House",
        optional = false,
        lore = "The show must go on! One of three cursed performances.",
        quote = "Woe to each and every one of you, my eternities!",
        icon = "INV_Misc_Ticket_Tarot_Blessings",
        variants = {
            { name = "Wizard of Oz", strategy = "Kill order: Dorothee > Tito > Roar > Strawman > Tinhead > Crone" },
            { name = "Big Bad Wolf", strategy = "Run if you get Little Red Riding Hood debuff!" },
            { name = "Romulo and Julianne", strategy = "Kill Julianne first, then Romulo, then both together" },
        },
    },
    {
        id = "curator",
        name = "The Curator",
        location = "Menagerie",
        optional = false,
        lore = "The arcane guardian of Medivh's collection.",
        quote = "Gallery rules will be strictly enforced.",
        icon = "Spell_Arcane_Arcane01",
        dropsToken = "gloves",
        mechanics = {
            "Spawns Astral Flares - kill them FAST",
            "Hateful Bolt - hits highest HP in melee range",
            "Evocation - 200% damage taken, burn phase!",
        },
        notableLoot = {
            { name = "Tier 4 Gloves Token", type = "Tier Token" },
            { name = "Dragon-Quake Shoulderguards", type = "Plate" },
        },
    },
    {
        id = "aran",
        name = "Shade of Aran",
        location = "Guardian's Library",
        optional = true,
        lore = "The ghost of Medivh's father. DON'T MOVE DURING FLAME WREATH!",
        quote = "I'll not be tortured again!",
        icon = "Spell_Fire_Flameshock",
        mechanics = {
            "FLAME WREATH - DON'T MOVE!!!",
            "Blizzard - avoid the moving AoE",
            "Arcane Explosion - run to wall",
            "Water Elementals at 40%",
        },
    },
    {
        id = "illhoof",
        name = "Terestian Illhoof",
        location = "Repository",
        optional = true,
        lore = "A satyr demon conducting dark rituals.",
        icon = "Spell_Shadow_SummonImp",
        mechanics = {
            "Demon Chains - FREE THE SACRIFICE FAST",
            "Kil'rek imp respawns - just offtank",
            "Imps spawn from portals - AoE them",
        },
    },
    {
        id = "netherspite",
        name = "Netherspite",
        location = "Celestial Watch",
        optional = true,
        lore = "A nether dragon corrupted by the tower's energies.",
        quote = nil, -- Ambient roar - no speech
        icon = "Spell_Arcane_PortalOrgrimmar",
        mechanics = {
            "THREE BEAM COLORS - must be soaked!",
            "Red (Perseverance) - Tank soaks",
            "Green (Serenity) - Healer soaks",
            "Blue (Dominance) - DPS soaks",
            "Rotate soakers, avoid debuff stacks",
        },
    },
    {
        id = "chess",
        name = "Chess Event",
        location = "Gamesman's Hall",
        optional = false,
        lore = "Medivh's enchanted chess set. The pieces have a will of their own.",
        quote = "Checkmate.",
        icon = "INV_Misc_Rune_01",
        mechanics = {
            "Control chess pieces to defeat enemy king",
            "Focus enemy king, protect yours",
            "Medivh cheats - move out of fire",
        },
    },
    {
        id = "prince",
        name = "Prince Malchezaar",
        location = "Netherspace",
        optional = false,
        finalBoss = true,
        lore = "An Eredar prince from the Twisting Nether. Wields Gorehowl.",
        quote = "All realities, all dimensions are open to me!",
        icon = "Spell_Shadow_SummonFelGuard",
        dropsToken = "helm",
        mechanics = {
            "Phase 1 (100-60%): Tank and spank, dodge Enfeeble",
            "Phase 2 (60-30%): Summons axes, avoid them!",
            "Phase 3 (<30%): Berserker mode, burn fast",
            "Infernals throughout - avoid fire patches",
        },
        notableLoot = {
            { name = "Tier 4 Helm Token", type = "Tier Token" },
            { name = "Gorehowl", type = "2H Axe" },
            { name = "Light's Justice", type = "1H Mace (Healer)" },
        },
    },
    {
        id = "nightbane",
        name = "Nightbane",
        location = "Master's Terrace",
        optional = true,
        summoned = true,
        lore = "Arcanagos reborn as an undead dragon. Summoned by the Blackened Urn.",
        quote = "Miserable vermin. I shall exterminate you from the air!",
        icon = "Ability_Creature_Cursed_01",
        prereq = "Complete Nightbane quest chain (Blackened Urn)",
        mechanics = {
            "Ground Phase: Tank and spank, tail swipe",
            "Air Phase (75%, 50%, 25%): Skeleton adds spawn",
            "Kill skeletons, avoid Charred Earth",
        },
        notableLoot = {
            { name = "Shield of Impenetrable Darkness", type = "Shield (Tank)" },
            { name = "Talisman of Nightbane", type = "Trinket (Melee)" },
        },
    },
}

-- GRUUL'S LAIR BOSSES
C.GRUUL_BOSSES = {
    {
        id = "maulgar",
        name = "High King Maulgar",
        location = "Entrance Hall",
        optional = false,
        lore = "The ogre king and his council must all fall together.",
        quote = "Gruul will crush you!",
        icon = "Ability_Warrior_Cleave",
        dropsToken = "shoulders",
        council = {
            { name = "High King Maulgar", role = "Main Boss" },
            { name = "Kiggler the Crazed", role = "Shaman - Hunter pet tanks" },
            { name = "Blindeye the Seer", role = "Priest - INTERRUPT heals" },
            { name = "Olm the Summoner", role = "Warlock - Tank away" },
            { name = "Krosh Firehand", role = "Mage - SPELLSTEAL his shield" },
        },
        strategy = "Kill order: Blindeye > Olm > Kiggler > Krosh > Maulgar",
        notableLoot = {
            { name = "Tier 4 Shoulder Token", type = "Tier Token" },
            { name = "Hammer of the Naaru", type = "2H Mace (Healer)" },
        },
    },
    {
        id = "gruul",
        name = "Gruul the Dragonkiller",
        location = "Gruul's Chamber",
        optional = false,
        finalBoss = true,
        lore = "The most powerful Gronn alive. Dragon bones decorate his throne.",
        quote = "Come... and die.",
        icon = "Ability_Hunter_Pet_Devilsaur",
        dropsToken = "legs",
        mechanics = {
            "Growth - Damage increases 15% every 30 sec",
            "Hurtful Strike - Need 2 tanks",
            "Cave In - Move out of circles!",
            "Ground Slam + Shatter - SPREAD OUT!",
        },
        notableLoot = {
            { name = "Tier 4 Leg Token", type = "Tier Token" },
            { name = "Dragonspine Trophy", type = "Trinket (Physical DPS)" },
            { name = "Eye of Gruul", type = "Trinket (Caster)" },
        },
    },
}

-- MAGTHERIDON'S LAIR BOSSES
C.MAGTHERIDON_BOSSES = {
    {
        id = "magtheridon",
        name = "Magtheridon",
        location = "The Pit",
        optional = false,
        finalBoss = true,
        singleBossRaid = true,
        lore = "A Pit Lord of immense power, chained but not broken.",
        quote = "I... am... unleashed!",
        icon = "Spell_Shadow_SummonFelGuard",
        dropsToken = "chest",
        phases = {
            {
                name = "Phase 1: The Channelers",
                description = "Kill all 5 Hellfire Channelers before Magtheridon breaks free",
                duration = "2 minutes",
                strategy = "Assign 5 tanks, interrupt Dark Mending, kill all before timer",
            },
            {
                name = "Phase 2: Magtheridon",
                description = "The Pit Lord is free. Use the Cubes!",
                strategy = "5 players click Manticron Cubes simultaneously to interrupt Blast Nova",
            },
            {
                name = "Phase 3: Collapse (30%)",
                description = "Ceiling falls! Avoid debris, keep clicking cubes, burn boss",
            },
        },
        notableLoot = {
            { name = "Tier 4 Chest Token", type = "Tier Token" },
            { name = "Eredar Wand of Obliteration", type = "Wand" },
            { name = "Eye of Magtheridon", type = "Trinket" },
            { name = "Magtheridon's Head", type = "Quest Item (Ring reward)" },
        },
    },
}

--============================================================
-- T5 RAID BOSS DATA
--============================================================

-- SERPENTSHRINE CAVERN BOSSES
C.SSC_BOSSES = {
    {
        id = "hydross",
        name = "Hydross the Unstable",
        location = "Reservoir Entrance",
        optional = false,
        order = 1,
        lore = "The elemental lord shifts between water and poison forms.",
        quote = "You will drown in blood!",
        icon = "Spell_Frost_SummonWaterElemental_2",
        mechanics = {
            "Tank must be frost-immune OR nature-immune",
            "Boss shifts forms when pulled across thresholds",
            "Adds spawn on every phase transition",
            "Stack resistance sets - 365 minimum",
        },
        notableLoot = {
            { name = "Shoulderpads of the Stranger", type = "Leather Shoulders" },
            { name = "Fathomstone", type = "Caster Off-Hand" },
        },
    },
    {
        id = "lurker",
        name = "The Lurker Below",
        location = "The Serpentshrine",
        optional = false,
        order = 2,
        lore = "A massive beast that must be fished from the depths.",
        quote = nil, -- Silent hunter
        icon = "INV_Misc_Fish_35",
        mechanics = {
            "Fish him out with 300+ fishing skill",
            "Spout - rotates and knocks back, JUMP INTO WATER",
            "Whirl - melee damage + knockback",
            "Submerge phase - kill Coilfang adds",
        },
        notableLoot = {
            { name = "Earring of Soulful Meditation", type = "Trinket (Healer)" },
            { name = "Mallet of the Tides", type = "1H Mace" },
        },
    },
    {
        id = "tidewalker",
        name = "Morogrim Tidewalker",
        location = "The Serpentshrine",
        optional = false,
        order = 3,
        lore = "A sea giant guarding the depths of Coilfang.",
        quote = "Flood of the deep, take you!",
        icon = "Ability_Creature_Poison_03",
        mechanics = {
            "Tidal Wave - frontal cone, tank faces away",
            "Watery Grave - teleports players, healers be ready",
            "Earthquake - stunned, murloc adds spawn",
            "AoE murlocs quickly, they explode on death",
        },
        notableLoot = {
            { name = "Talon of Azshara", type = "Dagger" },
            { name = "Girdle of the Tidal Call", type = "Mail Belt" },
        },
    },
    {
        id = "karathress",
        name = "Fathom-Lord Karathress",
        location = "The Lurker's Pool",
        optional = false,
        order = 4,
        lore = "A council fight with three Fathom Guards.",
        quote = "Guards, attention! We have visitors...",
        icon = "Spell_Frost_SummonWaterElemental",
        council = {
            { name = "Fathom-Lord Karathress", role = "Main Boss" },
            { name = "Fathom-Guard Sharkkis", role = "Hunter - kill first" },
            { name = "Fathom-Guard Tidalvess", role = "Shaman - interrupt heals" },
            { name = "Fathom-Guard Caribdis", role = "Priest - kill last before boss" },
        },
        mechanics = {
            "Kill order: Sharkkis > Tidalvess > Caribdis > Karathress",
            "Karathress gains abilities as guards die",
            "Interrupt heals from Tidalvess",
            "Spread for Spitfire Totem",
        },
        notableLoot = {
            { name = "Fathom-Brooch of the Tidewalker", type = "Trinket" },
            { name = "World Breaker", type = "2H Mace" },
        },
    },
    {
        id = "leotheras",
        name = "Leotheras the Blind",
        location = "Serpent Cavern",
        optional = false,
        order = 5,
        lore = "A demon hunter who lost control of his inner demon.",
        quote = "Finally, my banishment ends!",
        icon = "Spell_Shadow_Metamorphosis",
        mechanics = {
            "Alternates between humanoid and demon form",
            "Demon form targets random players",
            "Whirlwind in humanoid form - MOVE AWAY",
            "At 15%, Inner Demon spawns for each player",
            "Kill YOUR inner demon or be mind-controlled!",
        },
        notableLoot = {
            { name = "Tsunami Talisman", type = "Trinket (Physical DPS)" },
            { name = "True-Aim Stalker Bands", type = "Mail Wrists" },
        },
    },
    {
        id = "vashj",
        name = "Lady Vashj",
        location = "Vashj's Throne",
        optional = false,
        finalBoss = true,
        order = 6,
        lore = "Former handmaiden of Queen Azshara, now servant of Illidan.",
        quote = "The time is now! Leave none standing!",
        icon = "Spell_Frost_SummonWaterElemental",
        dropsToken = "helm",
        phases = {
            {
                name = "Phase 1 (100-70%)",
                description = "Tank and spank with Static Charge movement",
            },
            {
                name = "Phase 2 (70-50%)",
                description = "Shield active! Kill Tainted Elementals, loot cores, throw to players near pillars",
            },
            {
                name = "Phase 3 (<50%)",
                description = "Burn phase - sporebats, striders, mind control",
            },
        },
        mechanics = {
            "Static Charge - spread out, move away from raid",
            "Phase 2: LOOTING TAINTED CORES is required!",
            "Pass cores to players near shield generators",
            "Kill sporebats in P3 or raid dies to poison",
        },
        notableLoot = {
            { name = "Tier 5 Helm Token", type = "Tier Token" },
            { name = "Vashj's Vial Remnant", type = "Quest Item (Hyjal attune)" },
            { name = "Serpent Spine Longbow", type = "Bow" },
        },
    },
}

-- TEMPEST KEEP: THE EYE BOSSES
C.TK_BOSSES = {
    {
        id = "alar",
        name = "Al'ar",
        location = "The Phoenix Hall",
        optional = false,
        order = 1,
        lore = "The phoenix that guards Kael'thas. It will rise again.",
        quote = nil, -- Phoenix cry
        icon = "Spell_Fire_Burnout",
        mechanics = {
            "Phase 1: Flies between platforms, tank on platforms",
            "Flame Buffet stacks - tank swaps needed",
            "Phase 2: Dive bombs, meteor adds spawn",
            "Phoenix resurrects once at 1 HP",
        },
        notableLoot = {
            { name = "Talon of the Phoenix", type = "Fist Weapon" },
            { name = "Phoenix-Wing Cloak", type = "Back" },
        },
    },
    {
        id = "voidreaver",
        name = "Void Reaver",
        location = "The Observatory",
        optional = false,
        order = 2,
        lore = "A mechanical construct of immense power. The easiest boss in TK.",
        quote = nil, -- Mechanical whirring
        icon = "Spell_Nature_WispSplode",
        mechanics = {
            "Arcane Orbs - move away from where they land",
            "Pounding - unavoidable AoE damage",
            "Simple tank and spank with orb awareness",
            "Often called 'Loot Reaver'",
        },
        notableLoot = {
            { name = "Tier 5 Shoulder Token", type = "Tier Token" },
            { name = "Warp-Spring Coil", type = "Trinket" },
        },
    },
    {
        id = "solarian",
        name = "High Astromancer Solarian",
        location = "The Mechanar Observatory",
        optional = false,
        order = 3,
        lore = "A blood elf astromancer who transforms into a voidwalker.",
        quote = "Tal anu'men no sin'dorei!",
        icon = "Spell_Arcane_Arcane02",
        mechanics = {
            "Wrath of the Astromancer - BOMB! Run out!",
            "Arcane Missiles - interruptible",
            "Split phase - agents spawn at doorways",
            "Voidwalker form at 20% - burn fast",
        },
        notableLoot = {
            { name = "Void Star Talisman", type = "Neck" },
            { name = "Girdle of the Righteous Path", type = "Plate Belt" },
        },
    },
    {
        id = "kaelthas",
        name = "Kael'thas Sunstrider",
        location = "The Throne of Kael'thas",
        optional = false,
        finalBoss = true,
        order = 4,
        lore = "The Prince of the Blood Elves, driven mad by his addiction to magic.",
        quote = "Tempest Keep was merely a setback!",
        icon = "Spell_Fire_BurnoutGreen",
        dropsToken = "chest",
        advisors = {
            { name = "Thaladred the Darkener", role = "Warrior - kite him, fixates random" },
            { name = "Lord Sanguinar", role = "Paladin - tank, fear mechanic" },
            { name = "Grand Astromancer Capernian", role = "Mage - ranged tank, conflag" },
            { name = "Master Engineer Telonicus", role = "Hunter - tank, bombs" },
        },
        phases = {
            { name = "Phase 1", description = "Kill advisors one by one" },
            { name = "Phase 2", description = "Weapons activate - kill all 7" },
            { name = "Phase 3", description = "Advisors resurrect - kill all 4 again" },
            { name = "Phase 4", description = "Kael'thas fights - MC, Pyroblast, Phoenix" },
            { name = "Phase 5 (50%)", description = "Gravity Lapse - float and shoot!" },
        },
        mechanics = {
            "Loot legendary weapons from P2 - you can use them!",
            "Staff of Disintegration dispels MC in P4",
            "Spread for Conflag, stack for Shield",
            "Gravity Lapse - swim in air, avoid orbs",
        },
        notableLoot = {
            { name = "Tier 5 Chest Token", type = "Tier Token" },
            { name = "Kael's Vial Remnant", type = "Quest Item (Hyjal attune)" },
            { name = "Ashes of Al'ar", type = "Mount (~1%)" },
            { name = "Verdant Sphere", type = "Off-Hand" },
        },
    },
}

--============================================================
-- T6 RAID BOSS DATA
--============================================================

-- BATTLE FOR MOUNT HYJAL BOSSES
C.HYJAL_BOSSES = {
    {
        id = "winterchill",
        name = "Rage Winterchill",
        location = "Alliance Base",
        optional = false,
        order = 1,
        camp = "Alliance",
        waves = 8,
        lore = "A lich commanding the Scourge assault on the Alliance base.",
        quote = "Your world is doomed.",
        icon = "Spell_Shadow_DarkRitual",
        mechanics = {
            "8 trash waves before boss",
            "Icebolt - frozen in place, healers dispel",
            "Death and Decay - MOVE out immediately",
            "Frost Armor - tank damage reduction",
            "DPS race - relatively simple boss",
        },
        notableLoot = {
            { name = "Tier 6 Gloves Token", type = "Tier Token" },
            { name = "Chronicle of Dark Secrets", type = "Off-Hand" },
        },
    },
    {
        id = "anetheron",
        name = "Anetheron",
        location = "Alliance Base",
        optional = false,
        order = 2,
        camp = "Alliance",
        waves = 8,
        lore = "A dreadlord leading the demon assault on the Alliance.",
        quote = "The Legion's final conquest has begun!",
        icon = "Spell_Shadow_CarrionSwarm",
        mechanics = {
            "8 trash waves before boss",
            "Carrion Swarm - frontal cone, face away",
            "Infernals rain from sky - avoid fire!",
            "Vampiric Aura - heals from damage dealt",
            "Sleep - healers be ready to dispel",
        },
        notableLoot = {
            { name = "Tier 6 Belt Token", type = "Tier Token" },
            { name = "Don Rodrigo's Poncho", type = "Leather Chest" },
        },
    },
    {
        id = "kazrogal",
        name = "Kaz'rogal",
        location = "Horde Base",
        optional = false,
        order = 3,
        camp = "Horde",
        waves = 8,
        lore = "A doom guard draining the life from Horde defenders.",
        quote = "Cry for mercy! Your meaningless lives will soon be forfeit!",
        icon = "Spell_Shadow_UnholyFrenzy",
        mechanics = {
            "8 trash waves before boss",
            "Mark of Kaz'rogal - mana drain, EXPLODE when OOM!",
            "Mana users run out before exploding",
            "War Stomp - AoE stun + damage",
            "Enrage timer - burn fast",
        },
        notableLoot = {
            { name = "Tier 6 Boots Token", type = "Tier Token" },
            { name = "Hammer of Atonement", type = "1H Mace" },
        },
    },
    {
        id = "azgalor",
        name = "Azgalor",
        location = "Horde Base",
        optional = false,
        order = 4,
        camp = "Horde",
        waves = 8,
        lore = "The pit lord commanding the Legion assault on the Horde.",
        quote = "Abandon all hope! The Legion has returned to finish what was begun!",
        icon = "Spell_Shadow_RainOfFire",
        mechanics = {
            "8 trash waves before boss",
            "Doom - 20 sec timer, run out and die alone!",
            "Lesser Doomguard spawns from Doom deaths",
            "Rain of Fire - move out of fire",
            "Howl of Azgalor - 5 sec silence",
        },
        notableLoot = {
            { name = "Tier 6 Helm Token", type = "Tier Token" },
            { name = "Tempest of Chaos", type = "Staff" },
        },
    },
    {
        id = "archimonde",
        name = "Archimonde",
        location = "World Tree",
        optional = false,
        finalBoss = true,
        order = 5,
        camp = "World Tree",
        waves = 0,
        lore = "The Defiler. Commander of the Burning Legion invasion.",
        quote = "Your resistance is insignificant.",
        icon = "INV_Elemental_Primal_Shadow",
        mechanics = {
            "No trash waves - straight to boss",
            "Air Burst - USE YOUR TEARS immediately!",
            "Tears of the Goddess slow fall - SPAM IT",
            "Doomfire - trails of fire, don't stand in it",
            "Soul Charge - on death, damages raid",
            "Fear + Grip - expect movement",
        },
        notableLoot = {
            { name = "Tier 6 Shoulder Token", type = "Tier Token" },
            { name = "Cataclysm's Edge", type = "2H Sword" },
            { name = "Tempest of Chaos", type = "Staff" },
        },
    },
}

-- BLACK TEMPLE BOSSES
C.BT_BOSSES = {
    {
        id = "najentus",
        name = "High Warlord Naj'entus",
        location = "Karabor Sewers",
        optional = false,
        order = 1,
        lore = "A naga lord guarding the entrance to the Black Temple.",
        quote = "You will die in the name of Lady Vashj!",
        icon = "Ability_Hunter_SilentHunter",
        mechanics = {
            "Impaling Spine - throw spines to break shield",
            "Tidal Shield - MUST be broken with spines",
            "Shield burst does massive raid damage",
            "High HP requirement - nature resistance helps",
        },
        notableLoot = {
            { name = "Halberd of Desolation", type = "Polearm" },
            { name = "Fists of Mukoa", type = "Leather Gloves" },
        },
    },
    {
        id = "supremus",
        name = "Supremus",
        location = "Temple Summit",
        optional = false,
        order = 2,
        lore = "An abyssal of immense size, patrolling the temple courtyard.",
        quote = nil, -- Volcanic roar
        icon = "Spell_Fire_Fireball02",
        mechanics = {
            "Phase 1: Tank and spank, hateful strike",
            "Molten Flame - volcanoes, don't stand in fire",
            "Phase 2: Fixates random target - KITE HIM!",
            "Gazed target must run, raid helps slow/root",
        },
        notableLoot = {
            { name = "Syphon of the Nathrezim", type = "Wand" },
            { name = "Band of the Abyssal Lord", type = "Ring" },
        },
    },
    {
        id = "akama",
        name = "Shade of Akama",
        location = "Sanctuary of Shadows",
        optional = false,
        order = 3,
        lore = "Akama's shade, controlled by Illidan's dark magic.",
        quote = "The betrayer's end draws near!",
        icon = "Ability_Rogue_ShadowDance",
        mechanics = {
            "Protect Akama from Channelers and adds",
            "Kill Channelers to break Akama's chains",
            "Adds spawn from doors - AoE them down",
            "Boss phase is easy once Akama is free",
        },
        notableLoot = {
            { name = "Amice of Brilliant Light", type = "Cloth Shoulders" },
            { name = "Shadow-Walker's Cord", type = "Leather Belt" },
        },
    },
    {
        id = "gorefiend",
        name = "Teron Gorefiend",
        location = "Hall of Souls",
        optional = false,
        order = 4,
        lore = "The first death knight, returned to serve Illidan.",
        quote = "I have use for you!",
        icon = "Spell_Shadow_Possession",
        mechanics = {
            "Shadow of Death - YOU BECOME A GHOST!",
            "Ghost players control Vengeful Spirit",
            "Use ghost abilities to kill Shadowy Constructs",
            "Practice ghost mechanics before the fight!",
            "Incinerate - high tank damage",
        },
        notableLoot = {
            { name = "Shadowmoon Destroyer's Drape", type = "Back" },
            { name = "Girdle of Lordaeron's Fallen", type = "Plate Belt" },
        },
    },
    {
        id = "bloodboil",
        name = "Gurtogg Bloodboil",
        location = "Demon Hold",
        optional = false,
        order = 5,
        lore = "A fel orc driven mad by demonic blood.",
        quote = "I'll rip the meat from your bones!",
        icon = "Spell_Shadow_Bloodboil",
        mechanics = {
            "Bloodboil - hits 5 furthest targets, rotate groups",
            "Fel Rage - random target becomes tank",
            "Fel Rage target gets buffs, healers focus them",
            "Arcing Smash - tank positioning matters",
            "Eject - tank knockback, need 2+ tanks",
        },
        notableLoot = {
            { name = "Girdle of Mighty Resolve", type = "Plate Belt" },
            { name = "Shadowmoon Insignia", type = "Trinket" },
        },
    },
    {
        id = "reliquary",
        name = "Reliquary of Souls",
        location = "Reliquary Chamber",
        optional = false,
        order = 6,
        lore = "A container of tortured souls - Suffering, Desire, and Anger.",
        quote = "Pain... suffering... chaos!",
        icon = "Spell_Shadow_SoulGem",
        phases = {
            { name = "Essence of Suffering", description = "No healing allowed! Drain soul ability." },
            { name = "Essence of Desire", description = "Reflects damage, Spirit Shock interrupt" },
            { name = "Essence of Anger", description = "Soul Scream, Spite - burn fast" },
        },
        mechanics = {
            "Phase 1: NO HEALING - use pots and healthstones",
            "Phase 2: Damage reflected to attacker",
            "Interrupt Spirit Shock or wipe",
            "Phase 3: Enrage, burn boss FAST",
        },
        notableLoot = {
            { name = "Naaru-Blessed Life Rod", type = "Wand" },
            { name = "Translucent Spellthread Necklace", type = "Neck" },
        },
    },
    {
        id = "shahraz",
        name = "Mother Shahraz",
        location = "Den of Mortal Delights",
        optional = false,
        order = 7,
        lore = "A shivarra priestess serving Illidan.",
        quote = "So... business or pleasure?",
        icon = "Spell_Shadow_PainSpike",
        mechanics = {
            "Shadow Resistance fight! 365 unbuffed",
            "Fatal Attraction - teleports 3 players together",
            "Silencing Shriek - interrupt healers",
            "Saber Lash - requires 3 tanks stacked",
            "Beam attacks - random targeting",
        },
        notableLoot = {
            { name = "Tier 6 Legs Token", type = "Tier Token" },
            { name = "Heartshatter Breastplate", type = "Plate Chest" },
        },
    },
    {
        id = "council",
        name = "The Illidari Council",
        location = "Council Chamber",
        optional = false,
        order = 8,
        lore = "Four of Illidan's most trusted lieutenants.",
        quote = "You wish to test me?",
        icon = "Spell_Holy_SealOfVengeance",
        council = {
            { name = "Gathios the Shatterer", role = "Paladin - tank, interrupts" },
            { name = "High Nethermancer Zerevor", role = "Mage - mage tank, interrupt" },
            { name = "Lady Malande", role = "Priest - interrupt heals!" },
            { name = "Veras Darkshadow", role = "Rogue - vanishes, deadly poison" },
        },
        mechanics = {
            "All 4 share health - damage any",
            "Interrupt Lady Malande's heals!",
            "Mage tank for Zerevor (spell reflect)",
            "Veras vanishes - watch for Deadly Poison",
            "Gathios Hammer of Justice must be tanked away",
        },
        notableLoot = {
            { name = "Madness of the Betrayer", type = "Trinket (Physical DPS)" },
            { name = "Tome of the Lightbringer", type = "Relic" },
        },
    },
    {
        id = "illidan",
        name = "Illidan Stormrage",
        location = "Temple Summit",
        optional = false,
        finalBoss = true,
        order = 9,
        lore = "The Betrayer. Lord of Outland. You are not prepared.",
        quote = "You are not prepared!",
        icon = "Achievement_Boss_Illidan",
        dropsToken = "chest",
        phases = {
            { name = "Phase 1", description = "Tank and spank, Shear debuff" },
            { name = "Phase 2 (65%)", description = "Flames of Azzinoth - 2 tanks needed!" },
            { name = "Phase 3 (30%)", description = "Illidan returns, increased damage" },
            { name = "Phase 4", description = "Demon form - Shadow resistance!" },
            { name = "Phase 5 (30% again)", description = "Maiev arrives, enrage mechanics" },
        },
        mechanics = {
            "Phase 1: Shear must be avoided - tanks use macro",
            "Phase 2: Two blades spawn Flames, each needs a tank",
            "Phase 3: Agonizing Flames - don't get hit",
            "Phase 4: Demon form - Shadow damage, Eye Beam",
            "Phase 5: Parasitic Shadowfiend - burn them fast",
            "Use Maiev's traps to stun during final phase",
        },
        notableLoot = {
            { name = "Tier 6 Chest Token", type = "Tier Token" },
            { name = "Warglaive of Azzinoth (MH)", type = "Legendary" },
            { name = "Warglaive of Azzinoth (OH)", type = "Legendary" },
            { name = "Bulwark of Azzinoth", type = "Shield (Tank)" },
            { name = "Skull of Gul'dan", type = "Trinket (Caster)" },
        },
    },
}

--============================================================
-- T5/T6 TIER TOKEN DATA
--============================================================
C.T5_TOKENS = {
    helm = {
        slot = "Head",
        dropsFrom = "Lady Vashj",
        raid = "Serpentshrine Cavern",
        classes = {
            ["Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Defender"] = { "Warrior", "Priest", "Druid" },
            ["Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    shoulders = {
        slot = "Shoulders",
        dropsFrom = "Void Reaver",
        raid = "Tempest Keep",
        classes = {
            ["Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Defender"] = { "Warrior", "Priest", "Druid" },
            ["Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    gloves = {
        slot = "Hands",
        dropsFrom = "Leotheras the Blind",
        raid = "Serpentshrine Cavern",
        classes = {
            ["Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Defender"] = { "Warrior", "Priest", "Druid" },
            ["Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    legs = {
        slot = "Legs",
        dropsFrom = "Fathom-Lord Karathress",
        raid = "Serpentshrine Cavern",
        classes = {
            ["Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Defender"] = { "Warrior", "Priest", "Druid" },
            ["Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    chest = {
        slot = "Chest",
        dropsFrom = "Kael'thas Sunstrider",
        raid = "Tempest Keep",
        classes = {
            ["Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Defender"] = { "Warrior", "Priest", "Druid" },
            ["Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
}

C.T6_TOKENS = {
    helm = {
        slot = "Head",
        dropsFrom = "Azgalor",
        raid = "Mount Hyjal",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    shoulders = {
        slot = "Shoulders",
        dropsFrom = "Archimonde",
        raid = "Mount Hyjal",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    gloves = {
        slot = "Hands",
        dropsFrom = "Rage Winterchill",
        raid = "Mount Hyjal",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    belt = {
        slot = "Waist",
        dropsFrom = "Anetheron",
        raid = "Mount Hyjal",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    boots = {
        slot = "Feet",
        dropsFrom = "Kaz'rogal",
        raid = "Mount Hyjal",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    legs = {
        slot = "Legs",
        dropsFrom = "Mother Shahraz",
        raid = "Black Temple",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
    chest = {
        slot = "Chest",
        dropsFrom = "Illidan Stormrage",
        raid = "Black Temple",
        classes = {
            ["Conquering"] = { "Paladin", "Priest", "Warlock" },
            ["Forgotten Conquering"] = { "Druid", "Mage", "Rogue" },
            ["Protector"] = { "Hunter", "Shaman", "Warrior" },
        },
    },
}

--============================================================
-- T4 TIER TOKEN DATA
--============================================================
C.T4_TOKENS = {
    helm = {
        slot = "Head",
        dropsFrom = "Prince Malchezaar",
        raid = "Karazhan",
        classes = {
            ["Fallen Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Fallen Defender"] = { "Warrior", "Priest", "Druid" },
            ["Fallen Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    shoulders = {
        slot = "Shoulders",
        dropsFrom = "High King Maulgar",
        raid = "Gruul's Lair",
        classes = {
            ["Fallen Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Fallen Defender"] = { "Warrior", "Priest", "Druid" },
            ["Fallen Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    gloves = {
        slot = "Hands",
        dropsFrom = "The Curator",
        raid = "Karazhan",
        classes = {
            ["Fallen Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Fallen Defender"] = { "Warrior", "Priest", "Druid" },
            ["Fallen Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    legs = {
        slot = "Legs",
        dropsFrom = "Gruul the Dragonkiller",
        raid = "Gruul's Lair",
        classes = {
            ["Fallen Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Fallen Defender"] = { "Warrior", "Priest", "Druid" },
            ["Fallen Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
    chest = {
        slot = "Chest",
        dropsFrom = "Magtheridon",
        raid = "Magtheridon's Lair",
        classes = {
            ["Fallen Champion"] = { "Rogue", "Shaman", "Paladin" },
            ["Fallen Defender"] = { "Warrior", "Priest", "Druid" },
            ["Fallen Hero"] = { "Hunter", "Mage", "Warlock" },
        },
    },
}

--============================================================
-- DEATH TITLES (Battle Scars)
--============================================================
C.DEATH_TITLES = {
    { min = 0, max = 0, title = "Immortal", color = "GOLD_BRIGHT" },
    { min = 1, max = 5, title = "Lucky", color = "FEL_GREEN" },
    { min = 6, max = 15, title = "Blooded", color = "SKY_BLUE" },
    { min = 16, max = 30, title = "Veteran", color = "BRONZE" },
    { min = 31, max = 50, title = "Floor Inspector", color = "HELLFIRE_ORANGE" },
    { min = 51, max = 100, title = "Professional Corpse", color = "HELLFIRE_RED" },
    { min = 101, max = 9999, title = "LEGEND", color = "ARCANE_PURPLE" },
}

-- Helper to get death title
function C:GetDeathTitle(deathCount)
    for _, data in ipairs(self.DEATH_TITLES) do
        if deathCount >= data.min and deathCount <= data.max then
            return data.title, data.color
        end
    end
    return "Unknown", "GREY"
end

--============================================================
-- HERO'S JOURNEY PAGE STRUCTURE
--============================================================
C.HERO_PAGES = {
    -- Act 1: The Awakening (Levels 1-20)
    { level = 1,  chapter = 1, title = "Who I Was Before", act = "The Awakening" },
    { level = 5,  chapter = 2, title = "First Steps", act = "The Awakening" },
    { level = 10, chapter = 3, title = "The Path Chosen", act = "The Awakening" },
    { level = 15, chapter = 4, title = "Beyond the Walls", act = "The Awakening" },
    { level = 20, chapter = 5, title = "The Road Opens", act = "The Awakening" },

    -- Act 2: The Journey (Levels 21-57)
    { level = 25, chapter = 6, title = "Seasoned Traveler", act = "The Journey" },
    { level = 30, chapter = 7, title = "Halfway to Glory", act = "The Journey" },
    { level = 35, chapter = 8, title = "Tempered by Battle", act = "The Journey" },
    { level = 40, chapter = 9, title = "Mount Up, Hero!", act = "The Journey", major = true },
    { level = 45, chapter = 10, title = "The Final Stretch", act = "The Journey" },
    { level = 50, chapter = 11, title = "Legend in the Making", act = "The Journey" },
    { level = 55, chapter = 12, title = "The Portal Beckons", act = "The Journey" },

    -- Act 3: Through the Dark Portal (Levels 58-70)
    { level = 58, chapter = 13, title = "Outland Awaits", act = "Through the Dark Portal", major = true },
    { level = 60, chapter = 14, title = "Old World Champion", act = "Through the Dark Portal" },
    { level = 62, chapter = 15, title = "Hellfire", act = "Through the Dark Portal" },
    { level = 65, chapter = 16, title = "Strange New Lands", act = "Through the Dark Portal" },
    { level = 70, chapter = 17, title = "LEGEND", act = "Through the Dark Portal", major = true },
    { level = 70, chapter = 18, title = "The Tower Calls", act = "Through the Dark Portal", special = "karazhan" },
}

--============================================================
-- TRAVELER ICONS (Earned with Fellow Travelers)
--============================================================
-- Icon quality tiers using WoW item quality colors
C.ICON_QUALITY_ORDER = { "UNCOMMON", "RARE", "EPIC", "LEGENDARY" }

-- Icon categories
C.ICON_CATEGORIES = {
    exploration = { name = "Exploration", icon = "INV_Misc_Map_01" },
    attunement = { name = "Attunement", icon = "INV_Misc_Key_10" },
    raiding = { name = "Raiding", icon = "INV_Helmet_06" },
    reputation = { name = "Reputation", icon = "INV_Misc_Token_Aldor" },
    social = { name = "Social", icon = "INV_ValentinesCard01" },
}

-- Traveler icon definitions
C.TRAVELER_ICONS = {
    --====================
    -- RAIDING ICONS
    --====================
    t4_companions = {
        id = "t4_companions",
        name = "T4 Companions",
        description = "Defeated your first Tier 4 raid boss together",
        icon = "INV_Misc_Key_10",
        quality = "RARE",
        category = "raiding",
        trigger = { type = "boss_tier", tier = "T4", count = 1 },
    },
    karazhan_cleared = {
        id = "karazhan_cleared",
        name = "Karazhan Cleared",
        description = "Defeated Prince Malchezaar together",
        icon = "Spell_Shadow_SummonFelGuard",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "karazhan", boss = "prince" },
    },
    dragonslayers = {
        id = "dragonslayers",
        name = "Dragonslayers",
        description = "Defeated Gruul the Dragonkiller together",
        icon = "Ability_Hunter_Pet_Devilsaur",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "gruul", boss = "gruul" },
    },
    pit_lord_slayers = {
        id = "pit_lord_slayers",
        name = "Pit Lord Slayers",
        description = "Defeated Magtheridon together",
        icon = "Spell_Shadow_SummonFelGuard",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "magtheridon", boss = "magtheridon" },
    },
    t5_veterans = {
        id = "t5_veterans",
        name = "T5 Veterans",
        description = "Defeated your first Tier 5 raid boss together",
        icon = "Spell_Frost_SummonWaterElemental",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss_tier", tier = "T5", count = 1 },
    },
    vashj_vanquishers = {
        id = "vashj_vanquishers",
        name = "Vashj Vanquishers",
        description = "Defeated Lady Vashj together",
        icon = "Spell_Frost_SummonWaterElemental",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "ssc", boss = "vashj" },
    },
    sunstrider_slayers = {
        id = "sunstrider_slayers",
        name = "Sunstrider Slayers",
        description = "Defeated Kael'thas Sunstrider together",
        icon = "Spell_Fire_BurnoutGreen",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "tk", boss = "kaelthas" },
    },
    t6_elite = {
        id = "t6_elite",
        name = "T6 Elite",
        description = "Defeated your first Tier 6 raid boss together",
        icon = "Achievement_Boss_Illidan",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss_tier", tier = "T6", count = 1 },
    },
    archimonde_allies = {
        id = "archimonde_allies",
        name = "Archimonde Allies",
        description = "Witnessed Archimonde's defeat together at Mount Hyjal",
        icon = "INV_Elemental_Primal_Shadow",
        quality = "EPIC",
        category = "raiding",
        trigger = { type = "boss", raid = "hyjal", boss = "archimonde" },
    },
    illidan_slayers = {
        id = "illidan_slayers",
        name = "Illidan Slayers",
        description = "Defeated Illidan Stormrage together - You were prepared!",
        icon = "Achievement_Boss_Illidan",
        quality = "LEGENDARY",
        category = "raiding",
        trigger = { type = "boss", raid = "bt", boss = "illidan" },
    },

    --====================
    -- ATTUNEMENT ICONS
    --====================
    key_masters = {
        id = "key_masters",
        name = "Key Masters",
        description = "Both completed the Karazhan attunement",
        icon = "INV_Misc_Key_10",
        quality = "RARE",
        category = "attunement",
        trigger = { type = "attunement", attunement = "karazhan" },
    },
    nether_keyholders = {
        id = "nether_keyholders",
        name = "Nether Keyholders",
        description = "Both obtained heroic dungeon keys",
        icon = "INV_Misc_Key_14",
        quality = "RARE",
        category = "attunement",
        trigger = { type = "heroic_keys" },
    },
    depths_delvers = {
        id = "depths_delvers",
        name = "Depths Delvers",
        description = "Both completed the Serpentshrine Cavern attunement",
        icon = "Spell_Frost_SummonWaterElemental",
        quality = "EPIC",
        category = "attunement",
        trigger = { type = "attunement", attunement = "ssc" },
    },
    champions_of_naaru = {
        id = "champions_of_naaru",
        name = "Champions of the Naaru",
        description = "Both completed the Tempest Keep attunement",
        icon = "Spell_Holy_SurgeOfLight",
        quality = "EPIC",
        category = "attunement",
        trigger = { type = "attunement", attunement = "tk" },
    },
    hand_of_adal = {
        id = "hand_of_adal",
        name = "Hand of A'dal",
        description = "Both completed the Hyjal/Black Temple attunement chain",
        icon = "INV_Jewelry_Necklace_36",
        quality = "EPIC",
        category = "attunement",
        trigger = { type = "attunement", attunement = "bt" },
    },
    cipher_scholars = {
        id = "cipher_scholars",
        name = "Cipher Scholars",
        description = "Both completed the Cipher of Damnation",
        icon = "INV_Misc_Book_06",
        quality = "RARE",
        category = "attunement",
        trigger = { type = "attunement", attunement = "cipher" },
    },

    --====================
    -- EXPLORATION ICONS
    --====================
    portal_pioneers = {
        id = "portal_pioneers",
        name = "Portal Pioneers",
        description = "Stepped through the Dark Portal together into Hellfire Peninsula",
        icon = "Spell_Fire_FelFlameRing",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Hellfire Peninsula" },
    },
    marsh_walkers = {
        id = "marsh_walkers",
        name = "Marsh Walkers",
        description = "Explored the mushroom forests of Zangarmarsh together",
        icon = "INV_Mushroom_11",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Zangarmarsh" },
    },
    bone_wanderers = {
        id = "bone_wanderers",
        name = "Bone Wanderers",
        description = "Walked among the spirits of Terokkar Forest together",
        icon = "Spell_Shadow_SoulGem",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Terokkar Forest" },
    },
    nagrand_nomads = {
        id = "nagrand_nomads",
        name = "Nagrand Nomads",
        description = "Roamed the floating islands of Nagrand together",
        icon = "INV_Misc_Flower_01",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Nagrand" },
    },
    edge_walkers = {
        id = "edge_walkers",
        name = "Edge Walkers",
        description = "Scaled the Blade's Edge Mountains together",
        icon = "INV_Sword_23",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Blade's Edge Mountains" },
    },
    void_travelers = {
        id = "void_travelers",
        name = "Void Travelers",
        description = "Ventured into the shattered Netherstorm together",
        icon = "Spell_Arcane_Arcane02",
        quality = "RARE",
        category = "exploration",
        trigger = { type = "zone", zone = "Netherstorm" },
    },
    shadow_seekers = {
        id = "shadow_seekers",
        name = "Shadow Seekers",
        description = "Entered the dark heart of Shadowmoon Valley together",
        icon = "Spell_Shadow_Possession",
        quality = "RARE",
        category = "exploration",
        trigger = { type = "zone", zone = "Shadowmoon Valley" },
    },
    light_bearers = {
        id = "light_bearers",
        name = "Light Bearers",
        description = "Found sanctuary in Shattrath City together",
        icon = "Spell_Arcane_PortalShattrath",
        quality = "UNCOMMON",
        category = "exploration",
        trigger = { type = "zone", zone = "Shattrath City" },
    },
    outland_explorers = {
        id = "outland_explorers",
        name = "Outland Explorers",
        description = "Discovered all Outland zones together",
        icon = "INV_Misc_Map_01",
        quality = "EPIC",
        category = "exploration",
        trigger = { type = "all_zones" },
    },

    --====================
    -- SOCIAL ICONS
    --====================
    battle_brothers = {
        id = "battle_brothers",
        name = "Battle Brothers",
        description = "Slain 50 raid bosses together",
        icon = "Ability_Warrior_BattleShout",
        quality = "RARE",
        category = "social",
        trigger = { type = "boss_kills_together", count = 50 },
    },
    veterans_bond = {
        id = "veterans_bond",
        name = "Veteran's Bond",
        description = "Slain 100 raid bosses together",
        icon = "Spell_Holy_ChampionsBond",
        quality = "EPIC",
        category = "social",
        trigger = { type = "boss_kills_together", count = 100 },
    },
    eternal_bond = {
        id = "eternal_bond",
        name = "Eternal Bond",
        description = "Spent 100+ hours grouped together",
        icon = "Spell_Holy_PrayerOfSpirit",
        quality = "LEGENDARY",
        category = "social",
        trigger = { type = "time_together", hours = 100 },
    },
    first_friends = {
        id = "first_friends",
        name = "First Friends",
        description = "Grouped together for the first time",
        icon = "INV_ValentinesCard01",
        quality = "UNCOMMON",
        category = "social",
        trigger = { type = "first_group" },
    },
    frequent_allies = {
        id = "frequent_allies",
        name = "Frequent Allies",
        description = "Grouped together 10+ times",
        icon = "INV_Misc_GroupLooking",
        quality = "UNCOMMON",
        category = "social",
        trigger = { type = "group_count", count = 10 },
    },
    trusted_companions = {
        id = "trusted_companions",
        name = "Trusted Companions",
        description = "Grouped together 50+ times",
        icon = "Ability_Rogue_Sprint",
        quality = "RARE",
        category = "social",
        trigger = { type = "group_count", count = 50 },
    },
}

-- Build reverse lookup: trigger type -> icon list
C.TRAVELER_ICON_TRIGGERS = {}
for iconId, iconData in pairs(C.TRAVELER_ICONS) do
    local triggerType = iconData.trigger.type
    if not C.TRAVELER_ICON_TRIGGERS[triggerType] then
        C.TRAVELER_ICON_TRIGGERS[triggerType] = {}
    end
    table.insert(C.TRAVELER_ICON_TRIGGERS[triggerType], iconData)
end

-- Get icons by trigger type
function C:GetIconsByTrigger(triggerType)
    return self.TRAVELER_ICON_TRIGGERS[triggerType] or {}
end

-- Get icon data by ID
function C:GetTravelerIcon(iconId)
    return self.TRAVELER_ICONS[iconId]
end

-- Get quality sort order (for sorting icons by quality)
function C:GetQualityOrder(quality)
    for i, q in ipairs(self.ICON_QUALITY_ORDER) do
        if q == quality then return i end
    end
    return 0
end

--============================================================
-- BOSS KILL TIER SYSTEM
-- Kill count thresholds using WoW's item quality colors
--============================================================
C.BOSS_TIER_THRESHOLDS = {
    { kills = 1,  quality = "POOR",      colorHex = "9D9D9D", name = "Poor" },
    { kills = 5,  quality = "COMMON",    colorHex = "FFFFFF", name = "Common" },
    { kills = 10, quality = "UNCOMMON",  colorHex = "1EFF00", name = "Uncommon" },
    { kills = 25, quality = "RARE",      colorHex = "0070DD", name = "Rare" },
    { kills = 50, quality = "EPIC",      colorHex = "A335EE", name = "Epic" },
    { kills = 69, quality = "LEGENDARY", colorHex = "FF8000", name = "Legendary" },
}

-- Get tier data for a given kill count
function C:GetBossTier(killCount)
    if not killCount or killCount < 1 then
        return nil
    end
    local result = self.BOSS_TIER_THRESHOLDS[1]
    for _, tier in ipairs(self.BOSS_TIER_THRESHOLDS) do
        if killCount >= tier.kills then
            result = tier
        else
            break
        end
    end
    return result
end

-- Get the next tier threshold for a given kill count
function C:GetNextBossTier(killCount)
    for _, tier in ipairs(self.BOSS_TIER_THRESHOLDS) do
        if killCount < tier.kills then
            return tier
        end
    end
    return nil -- Already at max tier
end

--============================================================
-- INDIVIDUAL BOSS BADGES
-- Each TBC raid boss gets its own trackable badge
--============================================================
C.BOSS_BADGES = {
    -- TIER 4: KARAZHAN (11 bosses)
    attumen = {
        id = "boss_attumen",
        bossId = "attumen",
        raid = "karazhan",
        tier = "T4",
        name = "Attumen the Huntsman",
        shortName = "Attumen",
        icon = "Ability_Mount_Undeadhorse",
        description = "Defeated Attumen the Huntsman in Karazhan",
    },
    moroes = {
        id = "boss_moroes",
        bossId = "moroes",
        raid = "karazhan",
        tier = "T4",
        name = "Moroes",
        shortName = "Moroes",
        icon = "INV_Misc_Key_03",
        description = "Defeated Moroes in Karazhan",
    },
    maiden = {
        id = "boss_maiden",
        bossId = "maiden",
        raid = "karazhan",
        tier = "T4",
        name = "Maiden of Virtue",
        shortName = "Maiden",
        icon = "Spell_Holy_HolyBolt",
        description = "Defeated Maiden of Virtue in Karazhan",
    },
    opera = {
        id = "boss_opera",
        bossId = "opera",
        raid = "karazhan",
        tier = "T4",
        name = "Opera Event",
        shortName = "Opera",
        icon = "INV_Misc_Ticket_Tarot_Blessings",
        description = "Completed the Opera Event in Karazhan",
    },
    curator = {
        id = "boss_curator",
        bossId = "curator",
        raid = "karazhan",
        tier = "T4",
        name = "The Curator",
        shortName = "Curator",
        icon = "Spell_Arcane_Arcane01",
        description = "Defeated The Curator in Karazhan",
    },
    aran = {
        id = "boss_aran",
        bossId = "aran",
        raid = "karazhan",
        tier = "T4",
        name = "Shade of Aran",
        shortName = "Aran",
        icon = "Spell_Fire_Flameshock",
        description = "Defeated Shade of Aran in Karazhan",
    },
    illhoof = {
        id = "boss_illhoof",
        bossId = "illhoof",
        raid = "karazhan",
        tier = "T4",
        name = "Terestian Illhoof",
        shortName = "Illhoof",
        icon = "Spell_Shadow_SummonImp",
        description = "Defeated Terestian Illhoof in Karazhan",
    },
    netherspite = {
        id = "boss_netherspite",
        bossId = "netherspite",
        raid = "karazhan",
        tier = "T4",
        name = "Netherspite",
        shortName = "Netherspite",
        icon = "Spell_Arcane_PortalOrgrimmar",
        description = "Defeated Netherspite in Karazhan",
    },
    chess = {
        id = "boss_chess",
        bossId = "chess",
        raid = "karazhan",
        tier = "T4",
        name = "Chess Event",
        shortName = "Chess",
        icon = "INV_Misc_Rune_01",
        description = "Completed the Chess Event in Karazhan",
    },
    prince = {
        id = "boss_prince",
        bossId = "prince",
        raid = "karazhan",
        tier = "T4",
        name = "Prince Malchezaar",
        shortName = "Prince",
        icon = "Spell_Shadow_SummonFelGuard",
        description = "Defeated Prince Malchezaar in Karazhan",
        finalBoss = true,
    },
    nightbane = {
        id = "boss_nightbane",
        bossId = "nightbane",
        raid = "karazhan",
        tier = "T4",
        name = "Nightbane",
        shortName = "Nightbane",
        icon = "Ability_Creature_Cursed_01",
        description = "Defeated Nightbane in Karazhan",
    },

    -- TIER 4: GRUUL'S LAIR (2 bosses)
    maulgar = {
        id = "boss_maulgar",
        bossId = "maulgar",
        raid = "gruul",
        tier = "T4",
        name = "High King Maulgar",
        shortName = "Maulgar",
        icon = "Ability_Warrior_Cleave",
        description = "Defeated High King Maulgar in Gruul's Lair",
    },
    gruul = {
        id = "boss_gruul",
        bossId = "gruul",
        raid = "gruul",
        tier = "T4",
        name = "Gruul the Dragonkiller",
        shortName = "Gruul",
        icon = "Ability_Hunter_Pet_Devilsaur",
        description = "Defeated Gruul the Dragonkiller",
        finalBoss = true,
    },

    -- TIER 4: MAGTHERIDON'S LAIR (1 boss)
    magtheridon = {
        id = "boss_magtheridon",
        bossId = "magtheridon",
        raid = "magtheridon",
        tier = "T4",
        name = "Magtheridon",
        shortName = "Magtheridon",
        icon = "Spell_Shadow_SummonFelGuard",
        description = "Defeated Magtheridon",
        finalBoss = true,
    },

    -- TIER 5: SERPENTSHRINE CAVERN (6 bosses)
    hydross = {
        id = "boss_hydross",
        bossId = "hydross",
        raid = "ssc",
        tier = "T5",
        name = "Hydross the Unstable",
        shortName = "Hydross",
        icon = "Spell_Frost_SummonWaterElemental_2",
        description = "Defeated Hydross the Unstable in Serpentshrine Cavern",
    },
    lurker = {
        id = "boss_lurker",
        bossId = "lurker",
        raid = "ssc",
        tier = "T5",
        name = "The Lurker Below",
        shortName = "Lurker",
        icon = "INV_Misc_Fish_35",
        description = "Defeated The Lurker Below in Serpentshrine Cavern",
    },
    tidewalker = {
        id = "boss_tidewalker",
        bossId = "tidewalker",
        raid = "ssc",
        tier = "T5",
        name = "Morogrim Tidewalker",
        shortName = "Tidewalker",
        icon = "Ability_Creature_Poison_03",
        description = "Defeated Morogrim Tidewalker in Serpentshrine Cavern",
    },
    karathress = {
        id = "boss_karathress",
        bossId = "karathress",
        raid = "ssc",
        tier = "T5",
        name = "Fathom-Lord Karathress",
        shortName = "Karathress",
        icon = "Spell_Frost_SummonWaterElemental",
        description = "Defeated Fathom-Lord Karathress in Serpentshrine Cavern",
    },
    leotheras = {
        id = "boss_leotheras",
        bossId = "leotheras",
        raid = "ssc",
        tier = "T5",
        name = "Leotheras the Blind",
        shortName = "Leotheras",
        icon = "Spell_Shadow_Metamorphosis",
        description = "Defeated Leotheras the Blind in Serpentshrine Cavern",
    },
    vashj = {
        id = "boss_vashj",
        bossId = "vashj",
        raid = "ssc",
        tier = "T5",
        name = "Lady Vashj",
        shortName = "Vashj",
        icon = "Spell_Frost_SummonWaterElemental",
        description = "Defeated Lady Vashj in Serpentshrine Cavern",
        finalBoss = true,
    },

    -- TIER 5: TEMPEST KEEP (4 bosses)
    alar = {
        id = "boss_alar",
        bossId = "alar",
        raid = "tk",
        tier = "T5",
        name = "Al'ar",
        shortName = "Al'ar",
        icon = "Spell_Fire_Burnout",
        description = "Defeated Al'ar in Tempest Keep",
    },
    voidreaver = {
        id = "boss_voidreaver",
        bossId = "voidreaver",
        raid = "tk",
        tier = "T5",
        name = "Void Reaver",
        shortName = "Void Reaver",
        icon = "Spell_Nature_WispSplode",
        description = "Defeated Void Reaver in Tempest Keep",
    },
    solarian = {
        id = "boss_solarian",
        bossId = "solarian",
        raid = "tk",
        tier = "T5",
        name = "High Astromancer Solarian",
        shortName = "Solarian",
        icon = "Spell_Arcane_Arcane02",
        description = "Defeated High Astromancer Solarian in Tempest Keep",
    },
    kaelthas = {
        id = "boss_kaelthas",
        bossId = "kaelthas",
        raid = "tk",
        tier = "T5",
        name = "Kael'thas Sunstrider",
        shortName = "Kael'thas",
        icon = "Spell_Fire_BurnoutGreen",
        description = "Defeated Kael'thas Sunstrider in Tempest Keep",
        finalBoss = true,
    },

    -- TIER 6: MOUNT HYJAL (5 bosses)
    winterchill = {
        id = "boss_winterchill",
        bossId = "winterchill",
        raid = "hyjal",
        tier = "T6",
        name = "Rage Winterchill",
        shortName = "Winterchill",
        icon = "Spell_Frost_IceStorm",
        description = "Defeated Rage Winterchill at Mount Hyjal",
    },
    anetheron = {
        id = "boss_anetheron",
        bossId = "anetheron",
        raid = "hyjal",
        tier = "T6",
        name = "Anetheron",
        shortName = "Anetheron",
        icon = "Spell_Shadow_Carrion",
        description = "Defeated Anetheron at Mount Hyjal",
    },
    kazrogal = {
        id = "boss_kazrogal",
        bossId = "kazrogal",
        raid = "hyjal",
        tier = "T6",
        name = "Kaz'rogal",
        shortName = "Kaz'rogal",
        icon = "Spell_Shadow_RaiseDead",
        description = "Defeated Kaz'rogal at Mount Hyjal",
    },
    azgalor = {
        id = "boss_azgalor",
        bossId = "azgalor",
        raid = "hyjal",
        tier = "T6",
        name = "Azgalor",
        shortName = "Azgalor",
        icon = "Spell_Shadow_AuraOfDarkness",
        description = "Defeated Azgalor at Mount Hyjal",
    },
    archimonde = {
        id = "boss_archimonde",
        bossId = "archimonde",
        raid = "hyjal",
        tier = "T6",
        name = "Archimonde",
        shortName = "Archimonde",
        icon = "INV_Elemental_Primal_Shadow",
        description = "Defeated Archimonde at Mount Hyjal",
        finalBoss = true,
    },

    -- TIER 6: BLACK TEMPLE (9 bosses)
    najentus = {
        id = "boss_najentus",
        bossId = "najentus",
        raid = "bt",
        tier = "T6",
        name = "High Warlord Naj'entus",
        shortName = "Naj'entus",
        icon = "INV_Weapon_Halberd_20",
        description = "Defeated High Warlord Naj'entus in Black Temple",
    },
    supremus = {
        id = "boss_supremus",
        bossId = "supremus",
        raid = "bt",
        tier = "T6",
        name = "Supremus",
        shortName = "Supremus",
        icon = "Spell_Fire_Lavaspawn",
        description = "Defeated Supremus in Black Temple",
    },
    akama = {
        id = "boss_akama",
        bossId = "akama",
        raid = "bt",
        tier = "T6",
        name = "Shade of Akama",
        shortName = "Akama",
        icon = "Spell_Shadow_Possession",
        description = "Defeated the Shade of Akama in Black Temple",
    },
    gorefiend = {
        id = "boss_gorefiend",
        bossId = "gorefiend",
        raid = "bt",
        tier = "T6",
        name = "Teron Gorefiend",
        shortName = "Gorefiend",
        icon = "Spell_Shadow_DeathPact",
        description = "Defeated Teron Gorefiend in Black Temple",
    },
    bloodboil = {
        id = "boss_bloodboil",
        bossId = "bloodboil",
        raid = "bt",
        tier = "T6",
        name = "Gurtogg Bloodboil",
        shortName = "Bloodboil",
        icon = "Ability_Warrior_BloodFrenzy",
        description = "Defeated Gurtogg Bloodboil in Black Temple",
    },
    reliquary = {
        id = "boss_reliquary",
        bossId = "reliquary",
        raid = "bt",
        tier = "T6",
        name = "Reliquary of Souls",
        shortName = "Reliquary",
        icon = "Spell_Shadow_SoulGem",
        description = "Defeated the Reliquary of Souls in Black Temple",
    },
    shahraz = {
        id = "boss_shahraz",
        bossId = "shahraz",
        raid = "bt",
        tier = "T6",
        name = "Mother Shahraz",
        shortName = "Shahraz",
        icon = "Spell_Shadow_PainSpike",
        description = "Defeated Mother Shahraz in Black Temple",
    },
    council = {
        id = "boss_council",
        bossId = "council",
        raid = "bt",
        tier = "T6",
        name = "Illidari Council",
        shortName = "Council",
        icon = "Spell_Shadow_ShadowWordDominate",
        description = "Defeated the Illidari Council in Black Temple",
    },
    illidan = {
        id = "boss_illidan",
        bossId = "illidan",
        raid = "bt",
        tier = "T6",
        name = "Illidan Stormrage",
        shortName = "Illidan",
        icon = "Achievement_Boss_Illidan",
        description = "Defeated Illidan Stormrage in Black Temple",
        finalBoss = true,
    },
}

-- Build lookup tables for boss badges
C.BOSS_BADGE_BY_RAID = {}
C.BOSS_BADGE_BY_ID = {}

for bossKey, badge in pairs(C.BOSS_BADGES) do
    -- Build by-raid lookup
    if not C.BOSS_BADGE_BY_RAID[badge.raid] then
        C.BOSS_BADGE_BY_RAID[badge.raid] = {}
    end
    C.BOSS_BADGE_BY_RAID[badge.raid][badge.bossId] = badge

    -- Build by-id lookup
    C.BOSS_BADGE_BY_ID[badge.id] = badge
end

-- Get boss badge for a specific raid and boss
function C:GetBossBadge(raid, bossId)
    if self.BOSS_BADGE_BY_RAID[raid] then
        return self.BOSS_BADGE_BY_RAID[raid][bossId]
    end
    return nil
end

-- Get all boss badges for a raid
function C:GetRaidBossBadges(raid)
    return self.BOSS_BADGE_BY_RAID[raid] or {}
end

-- Get all boss badges for a tier
function C:GetTierBossBadges(tier)
    local result = {}
    for _, badge in pairs(self.BOSS_BADGES) do
        if badge.tier == tier then
            table.insert(result, badge)
        end
    end
    return result
end

--============================================================
-- RAID TIER MAPPING
-- Centralized raid organization to eliminate duplicate lists
--============================================================

-- Raid tier mapping (raid key -> tier)
C.RAID_TIERS = {
    karazhan = "T4",
    gruul = "T4",
    magtheridon = "T4",
    ssc = "T5",
    tk = "T5",
    hyjal = "T6",
    bt = "T6",
}

-- All raid keys (includes non-attunement raids like Gruul/Magtheridon)
C.ALL_RAID_KEYS = { "karazhan", "gruul", "magtheridon", "ssc", "tk", "hyjal", "bt" }

-- Attunement-only raid keys (raids with attunement quest chains)
C.ATTUNEMENT_RAID_KEYS = { "karazhan", "ssc", "tk", "hyjal", "bt" }

-- Raids organized by tier (for UI display)
C.RAIDS_BY_TIER = {
    T4 = { "karazhan", "gruul", "magtheridon" },
    T5 = { "ssc", "tk" },
    T6 = { "hyjal", "bt" },
}

-- Get tier for a given raid key
function C:GetRaidTier(raidKey)
    return self.RAID_TIERS[raidKey]
end
