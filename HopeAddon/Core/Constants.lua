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

--============================================================
-- ATTUNEMENT DIFFICULTY LEVELS
--============================================================
C.ATTUNEMENT_DIFFICULTY = {
    SOLO = { label = "Solo", color = "FEL_GREEN" },
    GROUP_5 = { label = "5-Player", color = "SKY_BLUE" },
    HEROIC_5 = { label = "Heroic 5-Player", color = "ARCANE_PURPLE" },
    RAID_10 = { label = "10-Player Raid", color = "GOLD_BRIGHT" },
    RAID_25 = { label = "25-Player Raid", color = "HELLFIRE_RED" },
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
    minLevel = 68,
    recommendedLevel = 70,

    chapters = {
        {
            name = "The Call",
            story = "Strange energies emanate from the ancient tower of Karazhan. Archmage Alturus of the Violet Eye has sensed these disturbances and seeks adventurers brave enough to investigate.",
            locationIcon = "Spell_Arcane_PortalShattrath",
            questGiver = "Archmage Alturus",
            location = "Deadwind Pass (47.0, 75.6)",
            difficulty = "SOLO",
            minLevel = 68,
            objectives = {
                "Use the Violet Scrying Crystal at the Underground Well",
                "Use the Violet Scrying Crystal at the Underground Pond",
                "Collect 10 Ghostly Essences from spirits in the caves",
            },
            rewards = {
                xp = 12650,
                reputation = { name = "The Violet Eye", amount = 75 },
            },
            tips = {
                "Archmage Alturus stands at the entrance path to Karazhan",
                "Accept BOTH quests (Arcane Disturbances + Restless Activity) at once",
                "The caves are just south of the tower entrance",
                "Ghosts are level 68-70 - soloable but bring potions",
            },
            quests = {
                { id = 9824, name = "Arcane Disturbances" },
                { id = 9825, name = "Restless Activity" },
            },
        },
        {
            name = "Contact from Dalaran",
            story = "Alturus's findings must be delivered to Archmage Cedric, who studies the magical barrier around the ruins of Dalaran in the Alterac Mountains.",
            locationIcon = "Spell_Holy_MindSooth",
            questGiver = "Archmage Alturus",
            location = "Deadwind Pass",
            turnIn = "Archmage Cedric - Alterac Mountains (15.6, 54.4)",
            difficulty = "SOLO",
            minLevel = 68,
            objectives = {
                "Deliver Alturus's Report to Archmage Cedric in Alterac Mountains",
            },
            rewards = {
                xp = 1150,
            },
            tips = {
                "Long journey - fly to Southshore (Alliance) or Tarren Mill (Horde)",
                "Cedric is at the Dalaran Crater bubble, not inside the ruins",
                "The crater is in the center-north of Alterac Mountains",
            },
            quests = {
                { id = 9826, name = "Contact from Dalaran" },
            },
        },
        {
            name = "Khadgar",
            story = "Archmage Cedric recognizes the severity of the situation and directs you to seek the legendary Khadgar in Shattrath City - the only mage powerful enough to forge a new key to Karazhan.",
            locationIcon = "Spell_Arcane_PortalShattrath",
            questGiver = "Archmage Cedric",
            location = "Alterac Mountains (15.6, 54.4)",
            turnIn = "Khadgar - Shattrath City (54.8, 44.6)",
            difficulty = "SOLO",
            minLevel = 68,
            objectives = {
                "Deliver Cedric's Report to Khadgar in Shattrath City",
            },
            rewards = {
                xp = 1150,
            },
            tips = {
                "Khadgar is in the center of Shattrath near A'dal",
                "He stands on the upper terrace overlooking the Terrace of Light",
                "Use the portal to Shattrath from any capital city",
            },
            quests = {
                { id = 9829, name = "Khadgar" },
            },
        },
        {
            name = "The First Fragment",
            story = "Khadgar explains that the original key was shattered long ago. To forge a new Master's Key, you must recover three key fragments hidden in Outland's most dangerous dungeons. The first lies within Shadow Labyrinth.",
            locationIcon = "Spell_Shadow_ShadeTrueSight",
            questGiver = "Khadgar",
            location = "Shattrath City (54.8, 44.6)",
            difficulty = "GROUP_5",
            minLevel = 68,
            dungeon = "Shadow Labyrinth",
            dungeonLevel = "70-72",
            prerequisite = "Shadow Labyrinth Key (drops from Talon King Ikiss in Sethekk Halls)",
            objectives = {
                "Enter Shadow Labyrinth in Auchindoun",
                "Clear to the final boss room (Murmur)",
                "Loot the Arcane Container on the ledge left of Murmur's pool",
                "Defeat the First Fragment Guardian that spawns",
                "Retrieve the First Key Fragment",
            },
            rewards = {
                xp = 25300,
                reputation = { name = "The Violet Eye", amount = 250 },
            },
            tips = {
                "PREREQUISITE: Get Shadow Labyrinth Key from Sethekk Halls first!",
                "Kill Murmur BEFORE looting the container - Guardian is tough",
                "The container is on a ledge to the LEFT of Murmur's pool",
                "Bring a balanced group - Shadow Lab is challenging at 70",
                "Normal mode is sufficient - Heroic not required",
            },
            quests = {
                { id = 9831, name = "Entry Into Karazhan" },
            },
        },
        {
            name = "The Second and Third Fragments",
            story = "With the first fragment secured, Khadgar sends you to retrieve the remaining two pieces. The second lies beneath the waters of the Steamvault, while the third is locked away in the Arcatraz prison.",
            locationIcon = "INV_Gizmo_02",
            questGiver = "Khadgar",
            location = "Shattrath City (54.8, 44.6)",
            difficulty = "GROUP_5",
            minLevel = 68,
            dungeons = { "The Steamvault", "The Arcatraz" },
            dungeonLevel = "70-72",
            prerequisite = "Arcatraz Key (from Warden's Cage quest chain in Netherstorm) OR Rogue with 350 Lockpicking",
            objectives = {
                "STEAMVAULT: Dive into the water pool before Hydromancer Thespia",
                "Locate the Arcane Container underwater at coords (53.0, 24.08)",
                "Defeat the Second Fragment Guardian and loot the fragment",
                "ARCATRAZ: Clear to the room after Zereketh the Unbound",
                "Find the Arcane Container among the voidwalkers",
                "Defeat the Third Fragment Guardian and loot the fragment",
            },
            rewards = {
                xp = 25300,
                reputation = { name = "The Violet Eye", amount = 250 },
            },
            tips = {
                "Steamvault fragment does NOT require killing any bosses!",
                "Stealth classes can potentially solo the Steamvault fragment",
                "ARCATRAZ KEY: Complete 'Warden's Cage' quest chain in Netherstorm",
                "Alternative: Rogue with 350 Lockpicking can open Arcatraz door",
                "Flying mount required to reach Arcatraz (Tempest Keep)",
                "Do these in any order - both must be completed",
            },
            quests = {
                { id = 9832, name = "The Second and Third Fragments" },
            },
        },
        {
            name = "The Master's Touch",
            story = "With all three fragments recovered, Khadgar can now forge the key - but it requires the touch of Medivh himself. You must travel through time to the Black Morass and protect Medivh during the Opening of the Dark Portal.",
            locationIcon = "Spell_Arcane_PortalOrgrimmar",
            questGiver = "Khadgar",
            location = "Shattrath City (54.8, 44.6)",
            difficulty = "GROUP_5",
            minLevel = 68,
            dungeon = "The Black Morass",
            dungeonLevel = "70",
            prerequisite = "Keepers of Time - Friendly reputation (complete Old Hillsbrad Foothills first)",
            objectives = {
                "Travel to Caverns of Time in Tanaris",
                "Enter the Black Morass instance",
                "Protect Medivh while he opens the Dark Portal",
                "Survive all 18 waves of Infinite Dragonflight attackers",
                "Speak with Medivh after the portal opens",
            },
            rewards = {
                xp = 25300,
                reputation = { name = "The Violet Eye", amount = 250 },
                reputation2 = { name = "Keepers of Time", amount = 8000 },
            },
            tips = {
                "PREREQUISITE: Complete Old Hillsbrad Foothills dungeon first!",
                "Old Hillsbrad unlocks at Keepers of Time - Friendly",
                "If Medivh dies, the dungeon FAILS and must be restarted",
                "18 waves of enemies - pace yourselves on cooldowns",
                "Rift Lords spawn portals - kill them quickly to prevent adds",
                "Final bosses: Chrono Lord Deja (wave 6), Temporus (wave 12), Aeonus (wave 18)",
                "After Aeonus dies, speak with Medivh to complete the quest",
            },
            quests = {
                { id = 9836, name = "The Master's Touch" },
            },
        },
        {
            name = "Return to Khadgar",
            story = "Medivh has blessed your restored key with his power. Return to Khadgar in Shattrath to complete the attunement and claim your Master's Key - the artifact that will grant you entry to the haunted halls of Karazhan.",
            locationIcon = "INV_Misc_Key_10",
            questGiver = "Medivh",
            location = "The Black Morass (after completion)",
            turnIn = "Khadgar - Shattrath City (54.8, 44.6)",
            difficulty = "SOLO",
            minLevel = 68,
            objectives = {
                "Return to Khadgar in Shattrath City",
                "Receive The Master's Key",
            },
            rewards = {
                xp = 19000,
                reputation = { name = "The Violet Eye", amount = 500 },
                item = "The Master's Key",
            },
            tips = {
                "Congratulations! You are now attuned to Karazhan!",
                "The Master's Key is used to open Karazhan's front door",
                "Only ONE person in the raid needs the key to open the door",
                "Key is NOT consumed - keep it for future raids",
            },
            quests = {
                { id = 9837, name = "Return to Khadgar" },
            },
        },
    },

    -- Summary of all prerequisites
    prerequisites = {
        { name = "Shadow Labyrinth Key", source = "Drops from Talon King Ikiss in Sethekk Halls", required = true },
        { name = "Arcatraz Key", source = "Warden's Cage quest chain in Netherstorm (or Rogue 350 Lockpicking)", required = true },
        { name = "Keepers of Time - Friendly", source = "Complete Old Hillsbrad Foothills dungeon", required = true },
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
-- HEROIC DUNGEON KEYS
--============================================================
C.HEROIC_KEYS = {
    flamewrought = {
        name = "Flamewrought Key",
        icon = "INV_Misc_Key_13",
        dungeons = { "Hellfire Ramparts", "The Blood Furnace", "The Shattered Halls" },
        dungeonGroup = "Hellfire Citadel",
        factionAlliance = "Honor Hold",
        factionHorde = "Thrallmar",
        factionId = { alliance = 946, horde = 947 },
        requiredStanding = 7,  -- Revered
        description = "Grants access to Heroic Hellfire Citadel dungeons.",
        tips = {
            "Farm Hellfire dungeons on normal for fastest reputation",
            "Shattered Halls gives most rep per run",
        },
    },
    reservoir = {
        name = "Reservoir Key",
        icon = "INV_Misc_Key_11",
        dungeons = { "The Slave Pens", "The Underbog", "The Steamvault" },
        dungeonGroup = "Coilfang Reservoir",
        faction = "Cenarion Expedition",
        factionId = 942,
        requiredStanding = 7,  -- Revered
        description = "Grants access to Heroic Coilfang Reservoir dungeons.",
        tips = {
            "Steamvault gives most rep at level 70",
            "Unidentified Plant Parts turn-in until Honored",
            "Coilfang Armaments for additional rep",
        },
    },
    auchenai = {
        name = "Auchenai Key",
        icon = "INV_Misc_Key_12",
        dungeons = { "Mana-Tombs", "Auchenai Crypts", "Sethekk Halls", "Shadow Labyrinth" },
        dungeonGroup = "Auchindoun",
        faction = "Lower City",
        factionId = 1011,
        requiredStanding = 7,  -- Revered
        description = "Grants access to Heroic Auchindoun dungeons.",
        tips = {
            "Auchenai Crypts and Sethekk Halls give most rep",
            "Arakkoa Feathers turn-in until Honored",
            "Shadow Labyrinth gives rep through Revered",
        },
    },
    warpforged = {
        name = "Warpforged Key",
        icon = "INV_Misc_Key_09",
        dungeons = { "The Mechanar", "The Botanica", "The Arcatraz" },
        dungeonGroup = "Tempest Keep",
        faction = "The Sha'tar",
        factionId = 935,
        requiredStanding = 7,  -- Revered
        description = "Grants access to Heroic Tempest Keep dungeons.",
        tips = {
            "Mechanar and Botanica give good rep",
            "Aldor/Scryer rep spillover contributes to Sha'tar",
            "Normal mode runs until Honored, then Heroics",
        },
    },
    key_of_time = {
        name = "Key of Time",
        icon = "INV_Misc_PocketWatch_02",
        dungeons = { "Old Hillsbrad Foothills", "The Black Morass" },
        dungeonGroup = "Caverns of Time",
        faction = "Keepers of Time",
        factionId = 989,
        requiredStanding = 7,  -- Revered
        description = "Grants access to Heroic Caverns of Time dungeons.",
        tips = {
            "Complete both dungeons for rep",
            "Black Morass gives more rep per run",
            "Required for Karazhan attunement anyway",
        },
    },
}

-- Heroic key order for display
C.HEROIC_KEY_ORDER = { "flamewrought", "reservoir", "auchenai", "warpforged", "key_of_time" }

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

-- Reverse lookup: Boss display name -> { raid, boss }
-- Built dynamically after boss definitions are loaded
-- Used for correlating DBM/BigWigs kill announcements
C.BOSS_NAME_LOOKUP = {}

-- Function to build the name lookup (called after all boss data is defined)
function C:BuildBossNameLookup()
    local raidBossTables = {
        { raidKey = "karazhan", bosses = C.KARAZHAN_BOSSES },
        { raidKey = "gruul", bosses = C.GRUUL_BOSSES },
        { raidKey = "magtheridon", bosses = C.MAGTHERIDON_BOSSES },
        { raidKey = "ssc", bosses = C.SSC_BOSSES },
        { raidKey = "tk", bosses = C.TK_BOSSES },
        { raidKey = "hyjal", bosses = C.HYJAL_BOSSES },
        { raidKey = "bt", bosses = C.BT_BOSSES },
    }

    for _, raidData in ipairs(raidBossTables) do
        if raidData.bosses then
            for _, boss in ipairs(raidData.bosses) do
                -- Primary: Full name lowercase
                C.BOSS_NAME_LOOKUP[boss.name:lower()] = {
                    raid = raidData.raidKey,
                    boss = boss.id
                }

                -- Also add without "the" prefix for fuzzy matching
                local shortName = boss.name:lower():gsub("^the ", "")
                if shortName ~= boss.name:lower() then
                    C.BOSS_NAME_LOOKUP[shortName] = {
                        raid = raidData.raidKey,
                        boss = boss.id
                    }
                end
            end
        end
    end
end

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

--============================================================
-- MINIGAME DEFINITIONS
-- Centralized game data for Games Hall UI
--============================================================

C.GAME_DEFINITIONS = {
    {
        id = "rps",
        name = "Rock Paper Scissors",
        description = "The classic game of wits and reflexes",
        icon = "Interface\\Icons\\Spell_Nature_EarthShock",
        hasLocal = true,
        hasRemote = true,
        system = "legacy",
        color = "NATURE_GREEN",
    },
    {
        id = "deathroll",
        name = "Death Roll",
        description = "Gambling with your gold - roll 1 and you lose!",
        icon = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
        hasLocal = true,
        hasRemote = true,
        system = "legacy",
        color = "HELLFIRE_RED",
    },
    {
        id = "pong",
        name = "Pong",
        description = "Classic arcade paddle action - local 2P or challenge a friend!",
        icon = "Interface\\Icons\\INV_Misc_PunchCards_Yellow",
        hasLocal = true,
        hasRemote = true,  -- Score Challenge mode
        system = "gamecore",
        color = "SKY_BLUE",
    },
    {
        id = "tetris",
        name = "Tetris Battle",
        description = "Clear lines! Local 2P with garbage or Score Challenge vs friends",
        icon = "Interface\\Icons\\INV_Misc_Gem_Variety_01",
        hasLocal = true,
        hasRemote = true,  -- Score Challenge mode
        system = "gamecore",
        color = "ARCANE_PURPLE",
    },
    {
        id = "words",
        name = "Words with WoW",
        description = "Scrabble-style word game with WoW vocabulary",
        icon = "Interface\\Icons\\INV_Misc_Book_07",
        hasLocal = true,
        hasRemote = true,
        system = "gamecore",
        color = "BRONZE",
    },
    {
        id = "battleship",
        name = "Battleship",
        description = "Hunt and sink your opponent's fleet",
        icon = "Interface\\Icons\\INV_Misc_Anchor",
        hasLocal = true,
        hasRemote = true,
        system = "gamecore",
        color = "SKY_BLUE",
    },
}

-- Game ID to definition lookup
C.GAME_BY_ID = {}
for _, game in ipairs(C.GAME_DEFINITIONS) do
    C.GAME_BY_ID[game.id] = game
end

-- Get game definition by ID
function C:GetGameDefinition(gameId)
    return self.GAME_BY_ID[gameId]
end

--============================================================
-- WORDS WITH WOW UI CONSTANTS
-- TBC-themed visual styling for the word game board
--============================================================

-- Bonus square colors (TBC themed: fel green, sky blue, arcane purple, hellfire red, gold)
C.WORDS_BONUS_COLORS = {
    [0] = { r = 0.95, g = 0.90, b = 0.75, a = 1.0 },   -- NONE: Parchment tan
    [1] = { r = 0.3,  g = 0.8,  b = 0.6,  a = 0.7 },   -- DOUBLE_LETTER: Fel green
    [2] = { r = 0.4,  g = 0.6,  b = 1.0,  a = 0.7 },   -- TRIPLE_LETTER: Sky blue
    [3] = { r = 0.8,  g = 0.4,  b = 0.8,  a = 0.7 },   -- DOUBLE_WORD: Arcane purple
    [4] = { r = 1.0,  g = 0.3,  b = 0.2,  a = 0.7 },   -- TRIPLE_WORD: Hellfire red
    [5] = { r = 1.0,  g = 0.84, b = 0,    a = 0.9 },   -- CENTER: Gold star
}

-- Bonus square labels
C.WORDS_BONUS_LABELS = {
    [0] = "",      -- Empty
    [1] = "DL",    -- Double Letter
    [2] = "TL",    -- Triple Letter
    [3] = "DW",    -- Double Word
    [4] = "TW",    -- Triple Word
    [5] = "★",     -- Center star
}

-- Bonus square tooltip text
C.WORDS_BONUS_NAMES = {
    [0] = "",
    [1] = "Double Letter Score",
    [2] = "Triple Letter Score",
    [3] = "Double Word Score",
    [4] = "Triple Word Score",
    [5] = "Center - Start Here!",
}

-- Tile appearance
C.WORDS_TILE_SIZE = 32  -- Pixels per tile
C.WORDS_TILE_COLORS = {
    PLACED = { r = 0.95, g = 0.90, b = 0.80, a = 1.0 },      -- Placed tile background
    PLACED_BORDER = { r = 0.6, g = 0.5, b = 0.35, a = 1.0 }, -- Placed tile border
    NEW_GLOW = { r = 1.0, g = 0.84, b = 0, a = 0.6 },        -- Recently placed glow
    LETTER = { r = 0.15, g = 0.10, b = 0.05, a = 1.0 },      -- Letter text color
    POINTS = { r = 0.4, g = 0.35, b = 0.25, a = 1.0 },       -- Point value color
}

-- Score thresholds for celebrations
C.WORDS_SCORE_THRESHOLDS = {
    GOOD = 20,      -- Play sound
    GREAT = 30,     -- Sparkles
    AMAZING = 50,   -- Full celebration
}

-- Drag and drop colors
C.WORDS_DRAG_COLORS = {
    VALID_DROP = { r = 0.3, g = 0.9, b = 0.3, a = 0.5 },      -- Green glow for valid squares
    VALID_HOVER = { r = 0.4, g = 1.0, b = 0.4, a = 0.7 },     -- Brighter green on hover
    INVALID_DROP = { r = 0.9, g = 0.3, b = 0.3, a = 0.3 },    -- Red tint for invalid
    PENDING_TILE = { r = 0.9, g = 0.85, b = 0.6, a = 1.0 },   -- Slightly different for pending
    PENDING_BORDER = { r = 0.8, g = 0.6, b = 0.2, a = 1.0 },  -- Gold border for pending
    DRAG_SHADOW = { r = 0, g = 0, b = 0, a = 0.4 },           -- Shadow under drag tile
    RACK_HIGHLIGHT = { r = 1.0, g = 0.84, b = 0, a = 0.3 },   -- Highlight available rack tiles
}

-- Words with Friends style bonuses
C.WORDS_BINGO_BONUS = 35  -- Bonus for using all 7 tiles in one turn

-- Button bar colors (Words with Friends style)
C.WORDS_BUTTON_COLORS = {
    SHUFFLE = { r = 0.3, g = 0.5, b = 0.8 },   -- Blue
    SWAP = { r = 0.9, g = 0.6, b = 0.2 },      -- Orange
    RECALL = { r = 0.9, g = 0.8, b = 0.3 },    -- Yellow
    PASS = { r = 0.5, g = 0.5, b = 0.5 },      -- Gray
    PLAY = { r = 0.3, g = 0.8, b = 0.3 },      -- Green
    DISABLED = { r = 0.3, g = 0.3, b = 0.3 },  -- Disabled gray
}

--============================================================
-- BACKDROP DEFINITIONS
-- Centralized backdrop templates for TBC Classic compatibility
-- Naming convention: [TYPE]_[DESCRIPTION]
--============================================================

C.BACKDROPS = {
    -- Standard tooltip-style (cards, entry items, buttons, input boxes)
    -- Used by: entry cards, game cards, progress bars, input containers
    TOOLTIP = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    },

    -- Smaller tooltip border (for compact elements)
    TOOLTIP_SMALL = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    },

    -- Parchment with gold border (main frames, popups, notifications)
    -- Used by: journal frame, challenge popups, milestone notifications
    PARCHMENT_GOLD = {
        bgFile = "Interface\\QUESTFRAME\\QuestBG",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = false,
        tileSize = 0,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    },

    -- Border only (no background - use explicit texture layer for parchment)
    -- Used by: CreateParchmentFrame when explicit texture control is needed
    PARCHMENT_BORDER_ONLY = {
        bgFile = nil,
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = false,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    },

    -- Parchment-style tiled background with gold border (scales to any size)
    -- Uses UI-DialogBox-Background which tiles properly unlike QuestBG
    -- Used by: CreateParchmentFrame for main journal window
    PARCHMENT_TILED = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    },

    -- Parchment with gold border (smaller edge for pages)
    PARCHMENT_GOLD_SMALL = {
        bgFile = "Interface\\QUESTFRAME\\QuestBG",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    },

    -- Parchment with dialog border (zone pages, themed border color)
    PARCHMENT_DIALOG = {
        bgFile = "Interface\\QUESTFRAME\\QuestBG",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    },

    -- Dark parchment with gold border (boss pages, smaller edge)
    DARK_GOLD_SMALL = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    },

    -- Dark parchment with standard border (raid content, dark frames)
    DARK_DIALOG = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    },

    -- Dark parchment with gold border (notifications, alerts)
    DARK_GOLD = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    },

    -- Dark background with gold border (game windows)
    GAME_WINDOW = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    },

    -- Minimal overlay (game overlays, title bars)
    OVERLAY = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = nil,
        tile = true,
        tileSize = 16,
    },

    -- Border only (reputation bars, decorative borders)
    BORDER_ONLY_TOOLTIP = {
        bgFile = nil,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    },

    -- Border only with gold (exalted rep bars)
    BORDER_ONLY_GOLD = {
        bgFile = nil,
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 16,
    },

    -- Parchment with tooltip border (game cards, lighter frames)
    PARCHMENT_SIMPLE = {
        bgFile = "Interface\\QUESTFRAME\\QuestBG",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    },

    -- Button style (small buttons with minimal chrome)
    BUTTON_SIMPLE = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    },

    -- Solid color with tooltip border (tier cards, colored cards)
    SOLID_TOOLTIP = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    },
}

-- Backdrop color presets (r, g, b, a)
C.BACKDROP_COLORS = {
    -- Background colors
    PARCHMENT = { 1, 1, 1, 1 },
    PARCHMENT_DARK = { 0.1, 0.1, 0.15, 0.95 },
    DARK_TRANSPARENT = { 0.1, 0.1, 0.1, 0.8 },
    DARK_SOLID = { 0.05, 0.05, 0.05, 0.9 },
    DARK_FAINT = { 0.1, 0.1, 0.1, 0.5 },
    PURPLE_TINT = { 0.15, 0.1, 0.2, 0.9 },
    BLUE_TINT = { 0.1, 0.15, 0.2, 0.9 },
    RED_TINT = { 0.2, 0.1, 0.1, 0.9 },
    GREEN_TINT = { 0.1, 0.15, 0.1, 0.9 },
    INPUT_BG = { 0.05, 0.05, 0.05, 0.8 },

    -- Border colors
    GOLD = { 1, 0.84, 0, 1 },
    GREY = { 0.5, 0.5, 0.5, 1 },
    GREY_DARK = { 0.4, 0.4, 0.4, 1 },
    GREY_LIGHT = { 0.6, 0.6, 0.6, 1 },
    BROWN = { 0.6, 0.5, 0.3, 1 },
    GREEN = { 0.2, 0.8, 0.2, 1 },
    GREEN_DARK = { 0.4, 0.5, 0.4, 1 },
    GREEN_BTN_BG = { 0.2, 0.3, 0.2, 0.9 },
    ARCANE_BTN_BG = { 0.3, 0.15, 0.4, 0.9 },
    ARCANE_BORDER = { 0.5, 0.3, 0.6, 1 },
    RED = { 0.8, 0.2, 0.2, 1 },
    ARCANE = { 0.61, 0.19, 1, 1 },
}

-- Game card background tints (dark versions of game theme colors)
C.GAME_BG_TINTS = {
    GOLD_BRIGHT = { 0.2, 0.17, 0.05, 0.9 },
    NATURE_GREEN = { 0.1, 0.2, 0.1, 0.9 },
    HELLFIRE_RED = { 0.25, 0.1, 0.1, 0.9 },
    SKY_BLUE = { 0.1, 0.15, 0.25, 0.9 },
    ARCANE_PURPLE = { 0.18, 0.1, 0.25, 0.9 },
    BRONZE = { 0.18, 0.12, 0.08, 0.9 },
}

--============================================================
-- CLASS LOOT HOTLIST (Top 3 items per class from rep/dungeons)
-- Focus on reputation rewards and normal dungeon drops
-- No heroics, no raids
--============================================================
C.CLASS_LOOT_HOTLIST = {
    -- Standing values: 4=Friendly, 5=Honored, 6=Revered, 7=Revered, 8=Exalted
    ["DRUID"] = {
        {
            source = "Cenarion Expedition @ Exalted",
            sourceType = "rep",
            faction = "Cenarion Expedition",
            standing = 8,
            itemId = 29171,
            name = "Earthwarden",
            icon = "INV_Mace_52",
            stats = "+43 Sta, +556 Feral AP, +24 Def",
            quality = "epic",
            slot = "Weapon",
        },
        {
            source = "Cenarion Expedition @ Revered",
            sourceType = "rep",
            faction = "Cenarion Expedition",
            standing = 6,
            itemId = 25838,
            name = "Warden's Hauberk",
            icon = "INV_Chest_Leather_03",
            stats = "+30 Agi, +27 Sta, +20 Int",
            quality = "rare",
            slot = "Chest",
        },
        {
            source = "Lower City @ Revered",
            sourceType = "rep",
            faction = "Lower City",
            standing = 6,
            itemId = 30841,
            name = "Lower City Prayerbook",
            icon = "INV_Misc_Book_09",
            stats = "+70 Healing, Reduce spell cost",
            quality = "rare",
            slot = "Trinket",
        },
    },
    ["WARRIOR"] = {
        {
            source = "Keepers of Time @ Revered",
            sourceType = "rep",
            faction = "Keepers of Time",
            standing = 6,
            itemId = 29185,
            name = "Continuum Blade",
            icon = "INV_Sword_66",
            stats = "+190 Spell Power, +8 Hit Rating",
            quality = "rare",
            slot = "One-Hand Sword",
        },
        {
            source = "Honor Hold/Thrallmar @ Revered",
            sourceType = "rep",
            faction = "Honor Hold",
            standing = 6,
            itemId = 29152,
            name = "Marksman's Bow",
            icon = "INV_Weapon_Bow_18",
            stats = "+14 Agi, +8 Sta, +16 Hit Rating",
            quality = "epic",
            slot = "Ranged",
        },
        {
            source = "The Consortium @ Exalted",
            sourceType = "rep",
            faction = "The Consortium",
            standing = 8,
            itemId = 29119,
            name = "Haramad's Bargain",
            icon = "INV_Jewelry_Necklace_30naxxramas",
            stats = "+20 Agi, +24 Sta, +22 Hit Rating",
            quality = "epic",
            slot = "Neck",
        },
    },
    ["PALADIN"] = {
        {
            source = "The Sha'tar @ Exalted",
            sourceType = "rep",
            faction = "The Sha'tar",
            standing = 8,
            itemId = 29175,
            name = "Gavel of Pure Light",
            icon = "INV_Mace_53",
            stats = "+225 Healing, +22 Int, +14 Sta",
            quality = "epic",
            slot = "Main Hand Mace",
        },
        {
            source = "Keepers of Time @ Revered",
            sourceType = "rep",
            faction = "Keepers of Time",
            standing = 6,
            itemId = 29185,
            name = "Continuum Blade",
            icon = "INV_Sword_66",
            stats = "+190 Spell Power, +8 Hit Rating",
            quality = "rare",
            slot = "One-Hand Sword",
        },
        {
            source = "Lower City @ Revered",
            sourceType = "rep",
            faction = "Lower City",
            standing = 6,
            itemId = 30841,
            name = "Lower City Prayerbook",
            icon = "INV_Misc_Book_09",
            stats = "+70 Healing, Reduce spell cost",
            quality = "rare",
            slot = "Trinket",
        },
    },
    ["HUNTER"] = {
        {
            source = "Honor Hold/Thrallmar @ Revered",
            sourceType = "rep",
            faction = "Honor Hold",
            standing = 6,
            itemId = 29152,
            name = "Marksman's Bow",
            icon = "INV_Weapon_Bow_18",
            stats = "+14 Agi, +8 Sta, +16 Hit Rating",
            quality = "epic",
            slot = "Ranged",
        },
        {
            source = "Cenarion Expedition @ Revered",
            sourceType = "rep",
            faction = "Cenarion Expedition",
            standing = 6,
            itemId = 25838,
            name = "Warden's Hauberk",
            icon = "INV_Chest_Leather_03",
            stats = "+30 Agi, +27 Sta, +20 Int",
            quality = "rare",
            slot = "Chest",
        },
        {
            source = "The Consortium @ Exalted",
            sourceType = "rep",
            faction = "The Consortium",
            standing = 8,
            itemId = 29119,
            name = "Haramad's Bargain",
            icon = "INV_Jewelry_Necklace_30naxxramas",
            stats = "+20 Agi, +24 Sta, +22 Hit Rating",
            quality = "epic",
            slot = "Neck",
        },
    },
    ["MAGE"] = {
        {
            source = "Keepers of Time @ Revered",
            sourceType = "rep",
            faction = "Keepers of Time",
            standing = 6,
            itemId = 29185,
            name = "Continuum Blade",
            icon = "INV_Sword_66",
            stats = "+190 Spell Power, +8 Hit Rating",
            quality = "rare",
            slot = "One-Hand Sword",
        },
        {
            source = "The Sha'tar @ Exalted",
            sourceType = "rep",
            faction = "The Sha'tar",
            standing = 8,
            itemId = 29175,
            name = "Gavel of Pure Light",
            icon = "INV_Mace_53",
            stats = "+225 Healing, +22 Int, +14 Sta",
            quality = "epic",
            slot = "Main Hand Mace",
        },
        {
            source = "Lower City @ Revered",
            sourceType = "rep",
            faction = "Lower City",
            standing = 6,
            itemId = 30841,
            name = "Lower City Prayerbook",
            icon = "INV_Misc_Book_09",
            stats = "+70 Healing, Reduce spell cost",
            quality = "rare",
            slot = "Trinket",
        },
    },
    ["WARLOCK"] = {
        {
            source = "Keepers of Time @ Revered",
            sourceType = "rep",
            faction = "Keepers of Time",
            standing = 6,
            itemId = 29185,
            name = "Continuum Blade",
            icon = "INV_Sword_66",
            stats = "+190 Spell Power, +8 Hit Rating",
            quality = "rare",
            slot = "One-Hand Sword",
        },
        {
            source = "The Sha'tar @ Exalted",
            sourceType = "rep",
            faction = "The Sha'tar",
            standing = 8,
            itemId = 29175,
            name = "Gavel of Pure Light",
            icon = "INV_Mace_53",
            stats = "+225 Healing, +22 Int, +14 Sta",
            quality = "epic",
            slot = "Main Hand Mace",
        },
        {
            source = "Lower City @ Exalted",
            sourceType = "rep",
            faction = "Lower City",
            standing = 8,
            itemId = 30834,
            name = "Shapeshifter's Signet",
            icon = "INV_Jewelry_Ring_51naxxramas",
            stats = "+24 Agi, +22 Sta, +23 Hit Rating",
            quality = "epic",
            slot = "Ring",
        },
    },
    ["PRIEST"] = {
        {
            source = "Lower City @ Revered",
            sourceType = "rep",
            faction = "Lower City",
            standing = 6,
            itemId = 30841,
            name = "Lower City Prayerbook",
            icon = "INV_Misc_Book_09",
            stats = "+70 Healing, Reduce spell cost",
            quality = "rare",
            slot = "Trinket",
        },
        {
            source = "The Sha'tar @ Exalted",
            sourceType = "rep",
            faction = "The Sha'tar",
            standing = 8,
            itemId = 29175,
            name = "Gavel of Pure Light",
            icon = "INV_Mace_53",
            stats = "+225 Healing, +22 Int, +14 Sta",
            quality = "epic",
            slot = "Main Hand Mace",
        },
        {
            source = "Keepers of Time @ Revered",
            sourceType = "rep",
            faction = "Keepers of Time",
            standing = 6,
            itemId = 29185,
            name = "Continuum Blade",
            icon = "INV_Sword_66",
            stats = "+190 Spell Power, +8 Hit Rating",
            quality = "rare",
            slot = "One-Hand Sword",
        },
    },
    ["ROGUE"] = {
        {
            source = "Cenarion Expedition @ Revered",
            sourceType = "rep",
            faction = "Cenarion Expedition",
            standing = 6,
            itemId = 25838,
            name = "Warden's Hauberk",
            icon = "INV_Chest_Leather_03",
            stats = "+30 Agi, +27 Sta, +20 Int",
            quality = "rare",
            slot = "Chest",
        },
        {
            source = "Lower City @ Exalted",
            sourceType = "rep",
            faction = "Lower City",
            standing = 8,
            itemId = 30834,
            name = "Shapeshifter's Signet",
            icon = "INV_Jewelry_Ring_51naxxramas",
            stats = "+24 Agi, +22 Sta, +23 Hit Rating",
            quality = "epic",
            slot = "Ring",
        },
        {
            source = "The Consortium @ Exalted",
            sourceType = "rep",
            faction = "The Consortium",
            standing = 8,
            itemId = 29119,
            name = "Haramad's Bargain",
            icon = "INV_Jewelry_Necklace_30naxxramas",
            stats = "+20 Agi, +24 Sta, +22 Hit Rating",
            quality = "epic",
            slot = "Neck",
        },
    },
    ["SHAMAN"] = {
        {
            source = "Lower City @ Revered",
            sourceType = "rep",
            faction = "Lower City",
            standing = 6,
            itemId = 30841,
            name = "Lower City Prayerbook",
            icon = "INV_Misc_Book_09",
            stats = "+70 Healing, Reduce spell cost",
            quality = "rare",
            slot = "Trinket",
        },
        {
            source = "The Sha'tar @ Exalted",
            sourceType = "rep",
            faction = "The Sha'tar",
            standing = 8,
            itemId = 29175,
            name = "Gavel of Pure Light",
            icon = "INV_Mace_53",
            stats = "+225 Healing, +22 Int, +14 Sta",
            quality = "epic",
            slot = "Main Hand Mace",
        },
        {
            source = "The Consortium @ Exalted",
            sourceType = "rep",
            faction = "The Consortium",
            standing = 8,
            itemId = 29119,
            name = "Haramad's Bargain",
            icon = "INV_Jewelry_Necklace_30naxxramas",
            stats = "+20 Agi, +24 Sta, +22 Hit Rating",
            quality = "epic",
            slot = "Neck",
        },
    },
}

-- Quality colors for item display
C.ITEM_QUALITY_COLORS = {
    epic = { r = 0.64, g = 0.21, b = 0.93 },     -- Purple
    rare = { r = 0.0, g = 0.44, b = 0.87 },      -- Blue
    uncommon = { r = 0.12, g = 0.75, b = 0.12 }, -- Green
    common = { r = 1.0, g = 1.0, b = 1.0 },      -- White
}

-- Standing names for display
C.STANDING_NAMES = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

--[[
    SPEC-BASED LOOT HOTLIST
    Organized by class -> spec tab (1-3) -> source type (rep/drops/crafted)
    Each category contains 3 recommended pre-raid items
    Standing values: 5=Friendly, 6=Honored, 7=Revered, 8=Exalted
]]
C.CLASS_SPEC_LOOT_HOTLIST = {
    --============================================================================
    -- WARRIOR
    --============================================================================
    ["WARRIOR"] = {
        -- Tab 1: Arms (Melee DPS)
        [1] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
            },
            drops = {
                { itemId = 28776, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Magtheridon's Lair", sourceType = "drops" },
                { itemId = 27994, name = "Spaulders of Dementia", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Str, +28 Sta, +22 Crit", source = "Heroic Sethekk Halls", sourceType = "drops" },
                { itemId = 28401, name = "Hauberk of Desolation", icon = "INV_Chest_Chain_15", quality = "epic", slot = "Chest", stats = "+38 Str, +48 Sta, +26 Crit", source = "Heroic Blood Furnace", sourceType = "drops" },
            },
            crafted = {
                { itemId = 23536, name = "Felsteel Gloves", icon = "INV_Gauntlets_29", quality = "rare", slot = "Hands", stats = "+26 Str, +25 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23537, name = "Felsteel Leggings", icon = "INV_Pants_Plate_17", quality = "rare", slot = "Legs", stats = "+34 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23538, name = "Felsteel Helm", icon = "INV_Helmet_24", quality = "rare", slot = "Head", stats = "+31 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
        -- Tab 2: Fury (Melee DPS)
        [2] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
            },
            drops = {
                { itemId = 27538, name = "Greaves of Desolation", icon = "INV_Pants_Plate_10", quality = "epic", slot = "Legs", stats = "+38 Str, +27 Agi, +37 Sta", source = "Heroic Black Morass", sourceType = "drops" },
                { itemId = 28776, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Magtheridon's Lair", sourceType = "drops" },
                { itemId = 27890, name = "Girdle of Ferocity", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+31 Str, +16 Agi, +36 Sta", source = "Heroic Shattered Halls", sourceType = "drops" },
            },
            crafted = {
                { itemId = 23536, name = "Felsteel Gloves", icon = "INV_Gauntlets_29", quality = "rare", slot = "Hands", stats = "+26 Str, +25 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23537, name = "Felsteel Leggings", icon = "INV_Pants_Plate_17", quality = "rare", slot = "Legs", stats = "+34 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 28484, name = "Bulwark of Kings", icon = "INV_Shield_32", quality = "epic", slot = "Shield", stats = "+54 Sta, +24 Def, +22 Block", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
        -- Tab 3: Protection (Tank)
        [3] = {
            rep = {
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8 },
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8 },
                { itemId = 29177, name = "Consortium Plated Legguards", icon = "INV_Pants_Plate_05", quality = "epic", slot = "Legs", stats = "+48 Sta, +27 Def", source = "The Consortium @ Revered", sourceType = "rep", faction = "The Consortium", standing = 7 },
            },
            drops = {
                { itemId = 29362, name = "The Sun Eater", icon = "INV_Sword_76", quality = "epic", slot = "One-Hand Sword", stats = "+24 Sta, +17 Def, Dodge proc", source = "Heroic Mechanar", sourceType = "drops" },
                { itemId = 27475, name = "Gauntlets of the Bold", icon = "INV_Gauntlets_30", quality = "rare", slot = "Hands", stats = "+27 Sta, +18 Def, +17 Hit", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28203, name = "Breastplate of the Bold", icon = "INV_Chest_Plate16", quality = "rare", slot = "Chest", stats = "+36 Sta, +24 Def", source = "Steamvault", sourceType = "drops" },
            },
            crafted = {
                { itemId = 23535, name = "Felsteel Shield Spike", icon = "INV_Misc_ArmorKit_07", quality = "rare", slot = "Shield Enhancement", stats = "+26 Shield Block Value", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 28484, name = "Bulwark of Kings", icon = "INV_Shield_32", quality = "epic", slot = "Shield", stats = "+54 Sta, +24 Def, +22 Block", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23538, name = "Felsteel Helm", icon = "INV_Helmet_24", quality = "rare", slot = "Head", stats = "+31 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
    },
    --============================================================================
    -- PALADIN
    --============================================================================
    ["PALADIN"] = {
        -- Tab 1: Holy (Healer)
        [1] = {
            rep = {
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
                { itemId = 29181, name = "Light's Justice", icon = "INV_Mace_37", quality = "epic", slot = "Main Hand", stats = "+264 Healing, +10 MP5", source = "The Aldor @ Exalted", sourceType = "rep", faction = "The Aldor", standing = 8 },
            },
            drops = {
                { itemId = 27828, name = "Warp Infused Drape", icon = "INV_Misc_Cape_12", quality = "rare", slot = "Back", stats = "+24 Int, +21 Spi, +44 Healing", source = "Botanica (Normal)", sourceType = "drops" },
                { itemId = 27775, name = "Hallowed Handwraps", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+26 Int, +17 Spi, +55 Healing", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28187, name = "Lamp of Peaceful Repose", icon = "INV_Offhand_1h_Draenei_C_01", quality = "epic", slot = "Off Hand", stats = "+22 Int, +15 Spi, +51 Healing", source = "Heroic Botanica", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21873, name = "Primal Mooncloth Robe", icon = "INV_Chest_Cloth_44", quality = "epic", slot = "Chest", stats = "+30 Sta, +24 Int, +92 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21874, name = "Primal Mooncloth Shoulders", icon = "INV_Shoulder_25", quality = "epic", slot = "Shoulder", stats = "+21 Sta, +18 Int, +68 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21875, name = "Primal Mooncloth Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +17 Int, +55 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Protection (Tank)
        [2] = {
            rep = {
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8 },
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8 },
                { itemId = 29183, name = "Libram of Repentance", icon = "INV_Relics_LibramofHope", quality = "epic", slot = "Relic", stats = "Block Value +35", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
            },
            drops = {
                { itemId = 27475, name = "Gauntlets of the Bold", icon = "INV_Gauntlets_30", quality = "rare", slot = "Hands", stats = "+27 Sta, +18 Def, +17 Hit", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28203, name = "Breastplate of the Bold", icon = "INV_Chest_Plate16", quality = "rare", slot = "Chest", stats = "+36 Sta, +24 Def", source = "Steamvault", sourceType = "drops" },
                { itemId = 27804, name = "Devilshark Cape", icon = "INV_Misc_Cape_16", quality = "rare", slot = "Back", stats = "+27 Sta, +15 Def, +15 Dodge", source = "Steamvault", sourceType = "drops" },
            },
            crafted = {
                { itemId = 28484, name = "Bulwark of Kings", icon = "INV_Shield_32", quality = "epic", slot = "Shield", stats = "+54 Sta, +24 Def, +22 Block", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23536, name = "Felsteel Gloves", icon = "INV_Gauntlets_29", quality = "rare", slot = "Hands", stats = "+26 Str, +25 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23538, name = "Felsteel Helm", icon = "INV_Helmet_24", quality = "rare", slot = "Head", stats = "+31 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
        -- Tab 3: Retribution (Melee DPS)
        [3] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29182, name = "Libram of Avengement", icon = "INV_Relics_LibramofGrace", quality = "rare", slot = "Relic", stats = "+Crusader Strike dmg", source = "The Scryers @ Revered", sourceType = "rep", faction = "The Scryers", standing = 7 },
            },
            drops = {
                { itemId = 28776, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Magtheridon's Lair", sourceType = "drops" },
                { itemId = 27994, name = "Spaulders of Dementia", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Str, +28 Sta, +22 Crit", source = "Heroic Sethekk Halls", sourceType = "drops" },
                { itemId = 27538, name = "Greaves of Desolation", icon = "INV_Pants_Plate_10", quality = "epic", slot = "Legs", stats = "+38 Str, +27 Agi, +37 Sta", source = "Heroic Black Morass", sourceType = "drops" },
            },
            crafted = {
                { itemId = 23536, name = "Felsteel Gloves", icon = "INV_Gauntlets_29", quality = "rare", slot = "Hands", stats = "+26 Str, +25 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23537, name = "Felsteel Leggings", icon = "INV_Pants_Plate_17", quality = "rare", slot = "Legs", stats = "+34 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 23538, name = "Felsteel Helm", icon = "INV_Helmet_24", quality = "rare", slot = "Head", stats = "+31 Str, +37 Sta", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
    },
    --============================================================================
    -- PRIEST
    --============================================================================
    ["PRIEST"] = {
        -- Tab 1: Discipline (Healer)
        [1] = {
            rep = {
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 Healing", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 27828, name = "Warp Infused Drape", icon = "INV_Misc_Cape_12", quality = "rare", slot = "Back", stats = "+24 Int, +21 Spi, +44 Healing", source = "Botanica (Normal)", sourceType = "drops" },
                { itemId = 27775, name = "Hallowed Handwraps", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+26 Int, +17 Spi, +55 Healing", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 27456, name = "Cord of Belief", icon = "INV_Belt_13", quality = "rare", slot = "Waist", stats = "+22 Int, +20 Spi, +51 Healing", source = "Arcatraz (Normal)", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21873, name = "Primal Mooncloth Robe", icon = "INV_Chest_Cloth_44", quality = "epic", slot = "Chest", stats = "+30 Sta, +24 Int, +92 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21874, name = "Primal Mooncloth Shoulders", icon = "INV_Shoulder_25", quality = "epic", slot = "Shoulder", stats = "+21 Sta, +18 Int, +68 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21875, name = "Primal Mooncloth Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +17 Int, +55 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Holy (Healer)
        [2] = {
            rep = {
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 Healing", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 27828, name = "Warp Infused Drape", icon = "INV_Misc_Cape_12", quality = "rare", slot = "Back", stats = "+24 Int, +21 Spi, +44 Healing", source = "Botanica (Normal)", sourceType = "drops" },
                { itemId = 27775, name = "Hallowed Handwraps", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+26 Int, +17 Spi, +55 Healing", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28187, name = "Lamp of Peaceful Repose", icon = "INV_Offhand_1h_Draenei_C_01", quality = "epic", slot = "Off Hand", stats = "+22 Int, +15 Spi, +51 Healing", source = "Heroic Botanica", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21873, name = "Primal Mooncloth Robe", icon = "INV_Chest_Cloth_44", quality = "epic", slot = "Chest", stats = "+30 Sta, +24 Int, +92 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21874, name = "Primal Mooncloth Shoulders", icon = "INV_Shoulder_25", quality = "epic", slot = "Shoulder", stats = "+21 Sta, +18 Int, +68 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21875, name = "Primal Mooncloth Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +17 Int, +55 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 3: Shadow (Caster DPS)
        [3] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 28229, name = "Incanter's Trousers", icon = "INV_Pants_Cloth_14", quality = "rare", slot = "Legs", stats = "+27 Sta, +28 Int, +35 SP", source = "Botanica", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21869, name = "Frozen Shadoweave Robe", icon = "INV_Chest_Cloth_43", quality = "epic", slot = "Chest", stats = "+24 Sta, +18 Int, +73 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21870, name = "Frozen Shadoweave Shoulders", icon = "INV_Shoulder_02", quality = "epic", slot = "Shoulder", stats = "+15 Sta, +12 Int, +54 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21871, name = "Frozen Shadoweave Boots", icon = "INV_Boots_Cloth_05", quality = "epic", slot = "Feet", stats = "+18 Sta, +17 Int, +50 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
    },
    --============================================================================
    -- DRUID
    --============================================================================
    ["DRUID"] = {
        -- Tab 1: Balance (Caster DPS)
        [1] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29172, name = "Idol of the Raven Goddess", icon = "INV_Relics_IdolofRejuvenation", quality = "epic", slot = "Relic", stats = "+Moonfire/Wrath dmg", source = "Cenarion Expedition @ Exalted", sourceType = "rep", faction = "Cenarion Expedition", standing = 8 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 27518, name = "Ivory Idol of the Moongoddess", icon = "INV_Relics_IdolofRejuvenation", quality = "rare", slot = "Relic", stats = "+Starfire bonus", source = "Slave Pens (Normal)", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_39", quality = "epic", slot = "Chest", stats = "+23 Sta, +20 Int, +75 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", slot = "Hands", stats = "+15 Sta, +14 Int, +50 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +16 Int, +46 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Feral (Tank - Bear)
        [2] = {
            rep = {
                { itemId = 29171, name = "Earthwarden", icon = "INV_Mace_52", quality = "epic", slot = "Two-Hand Mace", stats = "+43 Sta, +556 AP, +24 Def", source = "Cenarion Expedition @ Exalted", sourceType = "rep", faction = "Cenarion Expedition", standing = 8 },
                { itemId = 29170, name = "Windcaller's Orb", icon = "INV_Misc_Orb_02", quality = "epic", slot = "Off Hand", stats = "+27 Sta, +18 Int, +18 Spi", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
                { itemId = 29173, name = "Idol of Ursoc", icon = "INV_Relics_IdolofFerocity", quality = "epic", slot = "Relic", stats = "+Maul damage +54", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
            },
            drops = {
                { itemId = 28139, name = "Heavy Clefthoof Boots", icon = "INV_Boots_Plate_04", quality = "rare", slot = "Feet", stats = "+45 Sta, +30 Agi, Armor", source = "Leatherworking/AH", sourceType = "drops" },
                { itemId = 28140, name = "Heavy Clefthoof Leggings", icon = "INV_Pants_Leather_25", quality = "rare", slot = "Legs", stats = "+51 Sta, +36 Agi, Armor", source = "Leatherworking/AH", sourceType = "drops" },
                { itemId = 28141, name = "Heavy Clefthoof Vest", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+54 Sta, +42 Agi, Armor", source = "Leatherworking/AH", sourceType = "drops" },
            },
            crafted = {
                { itemId = 28139, name = "Heavy Clefthoof Boots", icon = "INV_Boots_Plate_04", quality = "rare", slot = "Feet", stats = "+45 Sta, +30 Agi, Armor", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 28140, name = "Heavy Clefthoof Leggings", icon = "INV_Pants_Leather_25", quality = "rare", slot = "Legs", stats = "+51 Sta, +36 Agi, Armor", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 28141, name = "Heavy Clefthoof Vest", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+54 Sta, +42 Agi, Armor", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
        -- Tab 3: Restoration (Healer)
        [3] = {
            rep = {
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
                { itemId = 29170, name = "Windcaller's Orb", icon = "INV_Misc_Orb_02", quality = "epic", slot = "Off Hand", stats = "+27 Sta, +18 Int, +18 Spi", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
            },
            drops = {
                { itemId = 27828, name = "Warp Infused Drape", icon = "INV_Misc_Cape_12", quality = "rare", slot = "Back", stats = "+24 Int, +21 Spi, +44 Healing", source = "Botanica (Normal)", sourceType = "drops" },
                { itemId = 27775, name = "Hallowed Handwraps", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+26 Int, +17 Spi, +55 Healing", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28187, name = "Lamp of Peaceful Repose", icon = "INV_Offhand_1h_Draenei_C_01", quality = "epic", slot = "Off Hand", stats = "+22 Int, +15 Spi, +51 Healing", source = "Heroic Botanica", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21873, name = "Primal Mooncloth Robe", icon = "INV_Chest_Cloth_44", quality = "epic", slot = "Chest", stats = "+30 Sta, +24 Int, +92 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21874, name = "Primal Mooncloth Shoulders", icon = "INV_Shoulder_25", quality = "epic", slot = "Shoulder", stats = "+21 Sta, +18 Int, +68 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21875, name = "Primal Mooncloth Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +17 Int, +55 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
    },
    --============================================================================
    -- SHAMAN
    --============================================================================
    ["SHAMAN"] = {
        -- Tab 1: Elemental (Caster DPS)
        [1] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29389, name = "Totem of the Void", icon = "Spell_Nature_Groundingtotem", quality = "rare", slot = "Relic", stats = "+55 Lightning Bolt dmg", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 27905, name = "Greaves of the Iron Guardian", icon = "INV_Boots_Plate_01", quality = "rare", slot = "Legs", stats = "+21 Sta, +21 Int, +28 SP", source = "Mechanar (Normal)", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_39", quality = "epic", slot = "Chest", stats = "+23 Sta, +20 Int, +75 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", slot = "Hands", stats = "+15 Sta, +14 Int, +50 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +16 Int, +46 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Enhancement (Melee DPS)
        [2] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
                { itemId = 29390, name = "Totem of the Astral Winds", icon = "Spell_Nature_Windfury", quality = "rare", slot = "Relic", stats = "+80 Stormstrike AP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 27846, name = "Claw of the Watcher", icon = "INV_Weapon_Hand_14", quality = "rare", slot = "Fist Weapon", stats = "+23 Agi, +15 Sta, +12 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 27994, name = "Spaulders of Dementia", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Str, +28 Sta, +22 Crit", source = "Heroic Sethekk Halls", sourceType = "drops" },
                { itemId = 28401, name = "Hauberk of Desolation", icon = "INV_Chest_Chain_15", quality = "epic", slot = "Chest", stats = "+38 Str, +48 Sta, +26 Crit", source = "Heroic Blood Furnace", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25686, name = "Fel Iron Chain Coif", icon = "INV_Helmet_44", quality = "uncommon", slot = "Head", stats = "+24 Sta, +16 Int, +26 AP", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 25687, name = "Fel Iron Chain Gloves", icon = "INV_Gauntlets_26", quality = "uncommon", slot = "Hands", stats = "+18 Sta, +12 Int, +20 AP", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
                { itemId = 25688, name = "Fel Iron Chain Bracers", icon = "INV_Bracer_07", quality = "uncommon", slot = "Wrist", stats = "+15 Sta, +10 Int, +16 AP", source = "Blacksmithing", sourceType = "crafted", profession = "Blacksmithing" },
            },
        },
        -- Tab 3: Restoration (Healer)
        [3] = {
            rep = {
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8 },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7 },
                { itemId = 29388, name = "Totem of Healing Rains", icon = "Spell_Nature_HealingWaveGreater", quality = "rare", slot = "Relic", stats = "+79 Chain Heal heal", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 27828, name = "Warp Infused Drape", icon = "INV_Misc_Cape_12", quality = "rare", slot = "Back", stats = "+24 Int, +21 Spi, +44 Healing", source = "Botanica (Normal)", sourceType = "drops" },
                { itemId = 27775, name = "Hallowed Handwraps", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+26 Int, +17 Spi, +55 Healing", source = "Shattered Halls (Normal)", sourceType = "drops" },
                { itemId = 28187, name = "Lamp of Peaceful Repose", icon = "INV_Offhand_1h_Draenei_C_01", quality = "epic", slot = "Off Hand", stats = "+22 Int, +15 Spi, +51 Healing", source = "Heroic Botanica", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21873, name = "Primal Mooncloth Robe", icon = "INV_Chest_Cloth_44", quality = "epic", slot = "Chest", stats = "+30 Sta, +24 Int, +92 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21874, name = "Primal Mooncloth Shoulders", icon = "INV_Shoulder_25", quality = "epic", slot = "Shoulder", stats = "+21 Sta, +18 Int, +68 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21875, name = "Primal Mooncloth Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +17 Int, +55 Healing", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
    },
    --============================================================================
    -- MAGE
    --============================================================================
    ["MAGE"] = {
        -- Tab 1: Arcane (Caster DPS)
        [1] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 28180, name = "Incanter's Robe", icon = "INV_Chest_Cloth_04", quality = "rare", slot = "Chest", stats = "+24 Sta, +24 Int, +30 SP", source = "Botanica (Normal)", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_39", quality = "epic", slot = "Chest", stats = "+23 Sta, +20 Int, +75 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", slot = "Hands", stats = "+15 Sta, +14 Int, +50 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +16 Int, +46 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Fire (Caster DPS)
        [2] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 28188, name = "Stitch Soul Cloak", icon = "INV_Misc_Cape_17", quality = "epic", slot = "Back", stats = "+22 Sta, +18 Int, +32 SP", source = "Heroic Old Hillsbrad", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_39", quality = "epic", slot = "Chest", stats = "+23 Sta, +20 Int, +75 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", slot = "Hands", stats = "+15 Sta, +14 Int, +50 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +16 Int, +46 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 3: Frost (Caster DPS)
        [3] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 27891, name = "Stillwater Boots", icon = "INV_Boots_Cloth_07", quality = "rare", slot = "Feet", stats = "+27 Sta, +26 Int, +28 SP", source = "Steamvault", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21869, name = "Frozen Shadoweave Robe", icon = "INV_Chest_Cloth_43", quality = "epic", slot = "Chest", stats = "+24 Sta, +18 Int, +73 Frost SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21870, name = "Frozen Shadoweave Shoulders", icon = "INV_Shoulder_02", quality = "epic", slot = "Shoulder", stats = "+15 Sta, +12 Int, +54 Frost SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21871, name = "Frozen Shadoweave Boots", icon = "INV_Boots_Cloth_05", quality = "epic", slot = "Feet", stats = "+18 Sta, +17 Int, +50 Frost SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
    },
    --============================================================================
    -- WARLOCK
    --============================================================================
    ["WARLOCK"] = {
        -- Tab 1: Affliction (Caster DPS)
        [1] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 27891, name = "Stillwater Boots", icon = "INV_Boots_Cloth_07", quality = "rare", slot = "Feet", stats = "+27 Sta, +26 Int, +28 SP", source = "Steamvault", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21869, name = "Frozen Shadoweave Robe", icon = "INV_Chest_Cloth_43", quality = "epic", slot = "Chest", stats = "+24 Sta, +18 Int, +73 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21870, name = "Frozen Shadoweave Shoulders", icon = "INV_Shoulder_02", quality = "epic", slot = "Shoulder", stats = "+15 Sta, +12 Int, +54 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21871, name = "Frozen Shadoweave Boots", icon = "INV_Boots_Cloth_05", quality = "epic", slot = "Feet", stats = "+18 Sta, +17 Int, +50 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 2: Demonology (Caster DPS)
        [2] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 28180, name = "Incanter's Robe", icon = "INV_Chest_Cloth_04", quality = "rare", slot = "Chest", stats = "+24 Sta, +24 Int, +30 SP", source = "Botanica (Normal)", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21869, name = "Frozen Shadoweave Robe", icon = "INV_Chest_Cloth_43", quality = "epic", slot = "Chest", stats = "+24 Sta, +18 Int, +73 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21870, name = "Frozen Shadoweave Shoulders", icon = "INV_Shoulder_02", quality = "epic", slot = "Shoulder", stats = "+15 Sta, +12 Int, +54 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21871, name = "Frozen Shadoweave Boots", icon = "INV_Boots_Cloth_05", quality = "epic", slot = "Feet", stats = "+18 Sta, +17 Int, +50 Shadow SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
        -- Tab 3: Destruction (Caster DPS)
        [3] = {
            rep = {
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7 },
            },
            drops = {
                { itemId = 28230, name = "Hallowed Garments", icon = "INV_Chest_Cloth_52", quality = "epic", slot = "Chest", stats = "+30 Sta, +28 Int, +37 SP", source = "Heroic Slave Pens", sourceType = "drops" },
                { itemId = 27796, name = "Mana-Etched Pantaloons", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+24 Sta, +25 Int, +29 SP, +18 Hit", source = "Arcatraz (Normal)", sourceType = "drops" },
                { itemId = 28188, name = "Stitch Soul Cloak", icon = "INV_Misc_Cape_17", quality = "epic", slot = "Back", stats = "+22 Sta, +18 Int, +32 SP", source = "Heroic Old Hillsbrad", sourceType = "drops" },
            },
            crafted = {
                { itemId = 21848, name = "Spellfire Robe", icon = "INV_Chest_Cloth_39", quality = "epic", slot = "Chest", stats = "+23 Sta, +20 Int, +75 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21847, name = "Spellfire Gloves", icon = "INV_Gauntlets_19", quality = "epic", slot = "Hands", stats = "+15 Sta, +14 Int, +50 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
                { itemId = 21846, name = "Spellfire Belt", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+18 Sta, +16 Int, +46 Fire/Arcane SP", source = "Tailoring", sourceType = "crafted", profession = "Tailoring" },
            },
        },
    },
    --============================================================================
    -- HUNTER
    --============================================================================
    ["HUNTER"] = {
        -- Tab 1: Beast Mastery (Ranged DPS)
        [1] = {
            rep = {
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
            },
            drops = {
                { itemId = 28275, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_12", quality = "rare", slot = "Chest", stats = "+32 Agi, +32 Sta, +25 Int", source = "Mana-Tombs (Normal)", sourceType = "drops" },
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 27815, name = "Stealthbinder's Chestguard", icon = "INV_Chest_Leather_04", quality = "rare", slot = "Chest", stats = "+26 Agi, +22 Sta, +44 AP", source = "Shadow Labyrinth", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
        -- Tab 2: Marksmanship (Ranged DPS)
        [2] = {
            rep = {
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
            },
            drops = {
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 28275, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_12", quality = "rare", slot = "Chest", stats = "+32 Agi, +32 Sta, +25 Int", source = "Mana-Tombs (Normal)", sourceType = "drops" },
                { itemId = 27994, name = "Spaulders of Dementia", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Str, +28 Sta, +22 Crit", source = "Heroic Sethekk Halls", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
        -- Tab 3: Survival (Ranged DPS)
        [3] = {
            rep = {
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
            },
            drops = {
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 28275, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_12", quality = "rare", slot = "Chest", stats = "+32 Agi, +32 Sta, +25 Int", source = "Mana-Tombs (Normal)", sourceType = "drops" },
                { itemId = 27815, name = "Stealthbinder's Chestguard", icon = "INV_Chest_Leather_04", quality = "rare", slot = "Chest", stats = "+26 Agi, +22 Sta, +44 AP", source = "Shadow Labyrinth", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
    },
    --============================================================================
    -- ROGUE
    --============================================================================
    ["ROGUE"] = {
        -- Tab 1: Assassination (Melee DPS)
        [1] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
            },
            drops = {
                { itemId = 28189, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Heroic Mechanar", sourceType = "drops" },
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 27815, name = "Stealthbinder's Chestguard", icon = "INV_Chest_Leather_04", quality = "rare", slot = "Chest", stats = "+26 Agi, +22 Sta, +44 AP", source = "Shadow Labyrinth", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
        -- Tab 2: Combat (Melee DPS)
        [2] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
            },
            drops = {
                { itemId = 28189, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Heroic Mechanar", sourceType = "drops" },
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 27890, name = "Girdle of Ferocity", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+31 Str, +16 Agi, +36 Sta", source = "Heroic Shattered Halls", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
        -- Tab 3: Subtlety (Melee DPS)
        [3] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8 },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7 },
            },
            drops = {
                { itemId = 28189, name = "Liar's Tongue Gloves", icon = "INV_Gauntlets_25", quality = "epic", slot = "Hands", stats = "+32 Agi, +32 Sta, +24 Hit", source = "Heroic Mechanar", sourceType = "drops" },
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 27815, name = "Stealthbinder's Chestguard", icon = "INV_Chest_Leather_04", quality = "rare", slot = "Chest", stats = "+26 Agi, +22 Sta, +44 AP", source = "Shadow Labyrinth", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
            },
        },
    },
}

-- Build the boss name lookup table now that all boss data is defined
C:BuildBossNameLookup()
