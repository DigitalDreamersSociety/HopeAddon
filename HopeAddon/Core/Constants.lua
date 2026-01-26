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
    [70] = { title = "LEGEND",                icon = "INV_Weapon_Glaive_01",     story = "Your legend is written in the stars." },
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
    headerIcon = "INV_Weapon_Glaive_01",
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
            locationIcon = "INV_Weapon_Glaive_01",
            quests = {
                { id = 10949, name = "Entry Into the Black Temple" },
            },
        },
        {
            name = "A Distraction for Akama",
            story = "The final step - aid Akama's assault on the temple...",
            locationIcon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "INV_Weapon_Glaive_01",
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
        icon = "Interface\\Icons\\INV_Misc_Bomb_07",
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

-- AI opponent settings (Easy difficulty - ~70% player win rate)
C.WORDS_AI_SETTINGS = {
    -- Decision timing (humanlike delays)
    THINK_TIME_MIN = 1.0,           -- Minimum "thinking" time in seconds
    THINK_TIME_MAX = 3.0,           -- Maximum "thinking" time in seconds

    -- Difficulty tuning (Easy: makes mistakes, prefers shorter words)
    MISTAKE_CHANCE = 0.20,          -- 20% chance to pick suboptimal word
    MAX_WORD_LENGTH = 5,            -- AI prefers words this length or shorter
    SKIP_LONG_WORD_CHANCE = 0.4,    -- 40% chance to skip words > MAX_WORD_LENGTH

    -- Fallback behavior
    PASS_IF_NO_WORDS = true,        -- Pass turn if no valid words found
}

-- Online status indicator thresholds (for remote games)
C.WORDS_ONLINE_STATUS = {
    ACTIVE_THRESHOLD = 60,          -- Seconds - "Active" if seen within 1 minute
    RECENT_THRESHOLD = 300,         -- Seconds - "Online" if seen within 5 minutes
    STALE_THRESHOLD = 900,          -- Seconds - "Away" if seen within 15 minutes
    -- Beyond STALE_THRESHOLD = "Offline"
}

-- Hint system states (derived from game state in GetHintState)
C.WORDS_HINT_STATE = {
    FIRST_MOVE = "FIRST_MOVE",           -- First word, no tiles placed yet
    PLACE_TILES = "PLACE_TILES",         -- Your turn, no tiles on board yet
    KEEP_PLACING = "KEEP_PLACING",       -- Tiles placed but word incomplete/invalid
    INVALID_WORD = "INVALID_WORD",       -- Word formed but not in dictionary
    MUST_COVER_CENTER = "MUST_COVER_CENTER", -- First word doesn't cover center
    NOT_CONNECTED = "NOT_CONNECTED",     -- Word not connected to existing tiles
    READY_TO_PLAY = "READY_TO_PLAY",     -- Valid word ready, PLAY button enabled
    AI_THINKING = "AI_THINKING",         -- AI opponent's turn (practice mode)
    OPPONENT_TURN = "OPPONENT_TURN",     -- Remote opponent's turn
    GAME_OVER = "GAME_OVER",             -- Game has ended
}

-- Step indicator definitions (3-step flow)
C.WORDS_HINT_STEPS = {
    { id = "place", label = "1. Place", activeLabel = "Place Tiles", icon = "INV_Misc_Rune_01" },
    { id = "form",  label = "2. Form",  activeLabel = "Form Word",   icon = "INV_Misc_Rune_05" },
    { id = "play",  label = "3. Play",  activeLabel = "Play!",       icon = "Spell_Holy_SealOfRighteousness" },
}

-- Contextual hint messages (format strings with %s placeholders)
C.WORDS_HINT_MESSAGES = {
    FIRST_MOVE = "First word must cover the center ★ square",
    PLACE_TILES = "Drag a tile from your rack to the board",
    KEEP_PLACING = "Keep placing tiles to form a word",
    WORD_READY = "%s looks good! Click PLAY",
    INVALID_WORD = "%s is not in the dictionary",
    MUST_COVER_CENTER = "Word must cover the center ★ square",
    NOT_CONNECTED = "Word must connect to existing tiles",
    AI_THINKING = "Opponent is thinking...",
    OPPONENT_TURN = "Waiting for %s...",
    GAME_OVER = "",
}

-- Hint UI colors (TBC theme: gold, grey, green)
C.WORDS_HINT_COLORS = {
    STEP_ACTIVE = { r = 1.0, g = 0.84, b = 0, a = 1.0 },      -- Gold - current step
    STEP_PENDING = { r = 0.5, g = 0.5, b = 0.5, a = 0.6 },    -- Grey - future steps
    STEP_COMPLETE = { r = 0.3, g = 0.9, b = 0.3, a = 1.0 },   -- Green - completed steps
    HINT_TEXT = { r = 0.9, g = 0.85, b = 0.7, a = 1.0 },      -- Parchment text
    HINT_ERROR = { r = 1.0, g = 0.4, b = 0.4, a = 1.0 },      -- Red - error hints
    CENTER_PULSE = { r = 1.0, g = 0.84, b = 0, a = 0.8 },     -- Gold pulse for center
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
    -- NOTE: Previously used QuestBG which cannot tile/scale. Now uses tiling light parchment.
    PARCHMENT_GOLD = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
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
    -- NOTE: Previously used QuestBG which cannot tile/scale. Now uses tiling dark parchment.
    PARCHMENT_GOLD_SMALL = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    },

    -- Parchment with dialog border (zone pages, themed border color)
    -- NOTE: Previously used QuestBG which cannot tile/scale. Now uses tiling dark parchment.
    PARCHMENT_DIALOG = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
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
    -- NOTE: Previously used QuestBG which cannot tile/scale. Now uses tiling light parchment.
    PARCHMENT_SIMPLE = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 32,
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)",
                            "Turn in Oshu'gun Crystal Powder Samples (250 rep/10)",
                            "Consortium quests in Nagrand and Netherstorm",
                        },
                        statPriority = {
                            "Best pre-raid DPS neck for physical damage",
                            "+22 Hit Rating helps reach melee hit cap (9%)",
                            "Agility provides crit and dodge",
                        },
                        tips = {
                            "Farm Oshu'gun Powder from Nagrand ogres/ethereals",
                            "Mana-Tombs Heroic is fastest once keyed",
                            "Buy from Karaaz in Stormspire (Netherstorm)",
                        },
                        alternatives = {
                            "Natasha's Ember Necklace (Nagrand quest)",
                            "Necklace of the Deep (Fishing)",
                            "Worgen Claw Necklace (H Underbog)",
                        },
                    },
                },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k rep total)",
                        },
                        statPriority = {
                            "Best ranged slot for melee - stat stick",
                            "+16 Hit is huge for reaching hit cap",
                            "Better than Nerubian Slavemaker until Kara",
                        },
                        tips = {
                            "Should reach Revered just from questing",
                            "If short, run Shattered Halls (fastest)",
                            "Buy from Logistics Officer Ulrike in Honor Hold",
                        },
                        alternatives = {
                            "Nerubian Slavemaker (Naxx - if you have it)",
                            "Emberhawk Crossbow (H OHB)",
                            "Melmorta's Twilight Longbow (H BM)",
                        },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill, best rep/hour)",
                            "Hellfire Peninsula quests (Horde only)",
                        },
                        statPriority = {
                            "BiS trinket for physical DPS until T5",
                            "+72 AP passive + 278 AP on-use burst",
                            "20 sec duration, 2 min cooldown",
                        },
                        tips = {
                            "Shattered Halls spam is fastest to Exalted",
                            "Grind this early - used through T5",
                            "Buy from Quartermaster Urgronn in Thrallmar",
                        },
                        alternatives = {
                            "Abacus of Violent Odds (H Mech)",
                            "Hourglass of the Unraveller (H BM)",
                            "Core of Ar'kelos (Netherstorm quest)",
                        },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)",
                            "Turn in Oshu'gun Crystal Powder Samples (250 rep/10)",
                            "Consortium quests in Nagrand and Netherstorm",
                        },
                        statPriority = {
                            "Best pre-raid DPS neck for physical damage",
                            "+22 Hit Rating helps reach melee hit cap (9%)",
                            "Agility provides crit and dodge",
                        },
                        tips = {
                            "Farm Oshu'gun Powder from Nagrand ogres/ethereals",
                            "Mana-Tombs Heroic is fastest once keyed",
                            "Buy from Karaaz in Stormspire (Netherstorm)",
                        },
                        alternatives = {
                            "Natasha's Ember Necklace (Nagrand quest)",
                            "Necklace of the Deep (Fishing)",
                            "Worgen Claw Necklace (H Underbog)",
                        },
                    },
                },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k rep total)",
                        },
                        statPriority = {
                            "Best ranged slot for melee - stat stick",
                            "+16 Hit is huge for reaching hit cap",
                            "Better than Nerubian Slavemaker until Kara",
                        },
                        tips = {
                            "Should reach Revered just from questing",
                            "If short, run Shattered Halls (fastest)",
                            "Buy from Logistics Officer Ulrike in Honor Hold",
                        },
                        alternatives = {
                            "Nerubian Slavemaker (Naxx - if you have it)",
                            "Emberhawk Crossbow (H OHB)",
                            "Melmorta's Twilight Longbow (H BM)",
                        },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill, best rep/hour)",
                            "Hellfire Peninsula quests (Horde only)",
                        },
                        statPriority = {
                            "BiS trinket for physical DPS until T5",
                            "+72 AP passive + 278 AP on-use burst",
                            "20 sec duration, 2 min cooldown",
                        },
                        tips = {
                            "Shattered Halls spam is fastest to Exalted",
                            "Grind this early - used through T5",
                            "Buy from Quartermaster Urgronn in Thrallmar",
                        },
                        alternatives = {
                            "Abacus of Violent Odds (H Mech)",
                            "Hourglass of the Unraveller (H BM)",
                            "Core of Ar'kelos (Netherstorm quest)",
                        },
                    },
                },
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
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8,
                    hoverData = {
                        repSources = {
                            "Old Hillsbrad Foothills (8 rep/kill)",
                            "Black Morass (8 Normal, 25 Heroic rep/kill)",
                            "Caverns of Time attunement questline",
                        },
                        statPriority = {
                            "Best pre-raid tank bracers",
                            "+21 Defense helps reach 490 cap",
                            "+33 Stamina for effective health",
                        },
                        tips = {
                            "Black Morass Heroic is fastest at 70",
                            "Complete attunement first (required for Heroic)",
                            "Buy from Alurmi in Caverns of Time",
                        },
                        alternatives = {
                            "Bracers of Dignity (H Mechanar)",
                            "Bracers of the Green Fortress (BS BoE)",
                            "Vambraces of Courage (H SH)",
                        },
                    },
                },
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k total)",
                        },
                        statPriority = {
                            "Best pre-raid tank belt",
                            "+23 Defense + 22 Block Rating",
                            "+40 Stamina for massive EH",
                        },
                        tips = {
                            "Long grind - start early while leveling",
                            "Shattered Halls is most efficient",
                            "Buy from Logistics Officer Ulrike",
                        },
                        alternatives = {
                            "Sha'tari Vindicator's Waistguard (H Mech)",
                            "Girdle of the Immovable (H SL)",
                            "Belt of the Guardian (BS craft)",
                        },
                    },
                },
                { itemId = 29177, name = "Consortium Plated Legguards", icon = "INV_Pants_Plate_05", quality = "epic", slot = "Legs", stats = "+48 Sta, +27 Def", source = "The Consortium @ Revered", sourceType = "rep", faction = "The Consortium", standing = 7,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)",
                            "Oshu'gun Crystal Powder Samples (250 rep/10)",
                            "Consortium quests in Nagrand/Netherstorm",
                        },
                        statPriority = {
                            "Solid pre-raid tank legs at Revered",
                            "+27 Defense toward 490 cap",
                            "+48 Stamina is excellent",
                        },
                        tips = {
                            "Only need Revered (not Exalted)",
                            "Powder farming in Nagrand is relaxing",
                            "Buy from Karaaz in Stormspire",
                        },
                        alternatives = {
                            "Timewarden's Leggings (H BM)",
                            "Legguards of the Bold (H SH)",
                            "Felsteel Leggings (BS craft)",
                        },
                    },
                },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k rep total)",
                        },
                        statPriority = {
                            "Stat stick for Protection Warriors",
                            "+16 Hit Rating helps threat abilities land",
                            "Agility provides small dodge bonus",
                        },
                        tips = {
                            "Only need Revered - easy grind",
                            "Do all HFP quests first for fast rep",
                            "Buy from Logistics Officer Ulrike in Honor Hold",
                        },
                        alternatives = {
                            "Felsteel Whisper Knives (Engineering)",
                            "Low priority slot for tanks",
                        },
                    },
                },
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
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = {
                            "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill",
                            "Aldor/Scryer turn-ins also grant Sha'tar rep",
                            "TK dungeon quests give good rep bonus",
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
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
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
                { itemId = 29181, name = "Light's Justice", icon = "INV_Mace_37", quality = "epic", slot = "Main Hand", stats = "+264 Healing, +10 MP5", source = "The Aldor @ Exalted", sourceType = "rep", faction = "The Aldor", standing = 8,
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
                -- Non-rep item: Best pre-raid Holy Paladin Libram (dungeon drop)
                { itemId = 28296, name = "Libram of the Lightbringer", icon = "INV_Relics_LibramofHope", quality = "rare", slot = "Relic", stats = "+87 Healing to Holy Light", source = "Botanica (Normal)", sourceType = "dungeon",
                    hoverData = {
                        repSources = {
                            "Drops from Commander Sarannis in Botanica",
                            "Normal mode - no Heroic key needed",
                            "~15% drop rate",
                        },
                        statPriority = {
                            "BiS pre-raid Libram for Holy Paladins",
                            "+87 Healing per Holy Light cast",
                            "Massive throughput increase for tank healing",
                        },
                        tips = {
                            "Run Botanica until it drops",
                            "First boss - quick resets if needed",
                            "No reputation required",
                        },
                        alternatives = {
                            "Libram of Souls Redeemed (15 Badges)",
                            "Blessed Book of Nagrand (Quest)",
                        },
                    },
                },
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
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8,
                    hoverData = {
                        repSources = {
                            "Old Hillsbrad Foothills (10-25 rep/kill)",
                            "Black Morass (15-25 rep/kill)",
                            "Caverns of Time quests (~4.5k rep total)",
                        },
                        statPriority = {
                            "Best pre-raid tank bracers for Paladins",
                            "+21 Defense helps reach 490 def cap",
                            "+33 Stamina adds ~330 HP",
                        },
                        tips = {
                            "Long grind - start Heroics early once Revered",
                            "Black Morass gives more rep per run",
                            "Buy from Alurmi in Caverns of Time",
                        },
                        alternatives = {
                            "Bracers of the Green Fortress (Blacksmithing)",
                            "Sha'tari Wrought Armguards (Shattered Halls)",
                            "Mok'Nathal Hero's Bracers (Quest)",
                        },
                    },
                },
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~8k rep total)",
                        },
                        statPriority = {
                            "Excellent tank belt with triple stats",
                            "+23 Defense + +22 Block Rating",
                            "+40 Stamina is massive for HP",
                        },
                        tips = {
                            "Shattered Halls is fastest for rep",
                            "Do all HFP quests first for easy rep",
                            "Buy from Logistics Officer Ulrike (Honor Hold)",
                        },
                        alternatives = {
                            "Crimson Girdle of the Indomitable (H SH)",
                            "Belt of the Guardian (Blacksmithing)",
                            "Girdle of Living Flame (SV)",
                        },
                    },
                },
                { itemId = 29183, name = "Libram of Repentance", icon = "INV_Relics_LibramofHope", quality = "epic", slot = "Relic", stats = "Block Value +35", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = {
                            "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill",
                            "Aldor/Scryer turn-ins also grant Sha'tar rep",
                            "TK dungeon quests give good rep bonus",
                        },
                        statPriority = {
                            "+35 Block Value increases Shield of Righteousness damage",
                            "Also increases Holy Shield threat",
                            "Best threat libram for tanking",
                        },
                        tips = {
                            "Long grind - start TK dungeons early",
                            "Botanica is fastest rep (many mobs)",
                            "Buy from Almaador in Sha'tar base (Shattrath)",
                        },
                        alternatives = {
                            "Libram of Saints Departed (Auction House)",
                            "Libram of Divine Judgment (Arena)",
                            "Blessed Book of Nagrand (Quest)",
                        },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10 rep/kill, Heroic: 15-25 rep/kill)",
                            "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)",
                            "Complete Consortium quests in Nagrand and Netherstorm",
                        },
                        statPriority = {
                            "Best pre-raid DPS neck for physical damage dealers",
                            "+22 Hit Rating helps reach melee hit cap (9%)",
                            "Agility provides crit and some armor",
                        },
                        tips = {
                            "Farm Oshu'gun Powder in Nagrand (ogres, ethereals)",
                            "Mana-Tombs Heroic is fastest rep once keyed",
                            "Buy from Karaaz in Stormspire (Netherstorm)",
                        },
                        alternatives = {
                            "Natasha's Ember Necklace (Quest: Nagrand)",
                            "Necklace of the Deep (Fishing)",
                            "Worgen Claw Necklace (H Underbog)",
                        },
                    },
                },
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~8k rep total)",
                        },
                        statPriority = {
                            "Stat stick for Paladins (ranged slot rarely used)",
                            "+16 Hit Rating is valuable for reaching cap",
                            "Decent Agi and Stamina for passives",
                        },
                        tips = {
                            "Only need Revered - relatively easy grind",
                            "Do all HFP quests first for easy rep",
                            "Buy from Logistics Officer Ulrike (Honor Hold)",
                        },
                        alternatives = {
                            "Don Santos' Famous Hunting Rifle (AH)",
                            "Felsteel Whisper Knives (Throwing)",
                            "Skip this slot - low priority for Ret",
                        },
                    },
                },
                { itemId = 29182, name = "Libram of Avengement", icon = "INV_Relics_LibramofGrace", quality = "rare", slot = "Relic", stats = "+Crusader Strike dmg", source = "The Scryers @ Revered", sourceType = "rep", faction = "The Scryers", standing = 7,
                    hoverData = {
                        repSources = {
                            "Turn in Firewing Signets (25 rep each, until Honored)",
                            "Turn in Sunfury Signets (25 rep, Honored+)",
                            "Turn in Arcane Tomes (350 rep each)",
                        },
                        statPriority = {
                            "BiS Retribution libram for Crusader Strike builds",
                            "Increases CS damage for main DPS rotation",
                            "Essential for Ret Paladin raid DPS",
                        },
                        tips = {
                            "Scryer choice locks you out of Aldor rewards",
                            "Farm Sunfury camps in Netherstorm",
                            "Buy from Quartermaster Enuril (Scryer's Tier)",
                        },
                        alternatives = {
                            "Libram of Divine Purpose (Quest)",
                            "Libram of Hope (Auction House)",
                            "Blessed Book of Nagrand (Quest)",
                        },
                    },
                },
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
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Best pre-raid healing weapon for Disc", "+225 Healing massive for shields and heals" },
                        tips = { "Long grind - start TK dungeons early", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Light's Justice (Aldor Exalted)", "The Essence Focuser (H Mech)" },
                    },
                },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "+70 Healing passive, reduces Prayer of Healing cost", "Great for Disc's heavy use of PoH" },
                        tips = { "Only need Revered - easy grind", "Buy from Nakodu in Lower City (Shattrath)" },
                        alternatives = { "Bangle of Endless Blessings (H Arc)", "Essence of the Martyr (41 Badges)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 Healing", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (10-25 rep/kill)", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Great healer neck with balanced stats", "+35 Healing and +20 Int both valuable" },
                        tips = { "Only need Revered - moderate grind", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Natasha's Guardian Cord (Quest: Nagrand)", "Necklace of Eternal Hope (H Durnholde)" },
                    },
                },
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
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Best pre-raid healing weapon for Holy", "+225 Healing massive for Flash/Greater Heal" },
                        tips = { "Long grind - start TK dungeons early", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Light's Justice (Aldor Exalted)", "The Essence Focuser (H Mech)" },
                    },
                },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "+70 Healing passive, reduces Prayer of Healing cost", "Excellent for Holy's AoE healing style" },
                        tips = { "Only need Revered - easy grind", "Buy from Nakodu in Lower City (Shattrath)" },
                        alternatives = { "Bangle of Endless Blessings (H Arc)", "Essence of the Martyr (41 Badges)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 Healing", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (10-25 rep/kill)", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Great healer neck with balanced stats", "+35 Healing and +20 Int both valuable" },
                        tips = { "Only need Revered - moderate grind", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Natasha's Guardian Cord (Quest: Nagrand)", "Necklace of Eternal Hope (H Durnholde)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad/Black Morass (10-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Strong caster weapon with Hit Rating", "+8 Hit helps reach spell hit cap (16%)" },
                        tips = { "Only need Revered - moderate grind", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Greatsword of Horrid Dreams (H Arc)", "Nathrezim Mindblade (Attumen - Kara)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "Best pre-raid caster ring with Hit", "+23 Hit massive for Shadow's hit cap" },
                        tips = { "Shadow Lab is best rep but harder", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Exalted)", "Ring of Cryptic Dreams (H Mana-Tombs)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (10-25 rep/kill)", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Great caster neck for Shadow", "+35 SP scales well with talents" },
                        tips = { "Only need Revered - moderate grind", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Brooch of Heightened Potential (H Mech)", "Necklace of Eternal Hope (H Durnholde)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad/Black Morass (10-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Strong caster weapon with Hit Rating", "+8 Hit helps reach spell hit cap (16%)" },
                        tips = { "Only need Revered - moderate grind", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Greatsword of Horrid Dreams (H Arc)", "Nathrezim Mindblade (Attumen - Kara)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "Best pre-raid caster ring with Hit", "+23 Hit massive for reaching cap" },
                        tips = { "Shadow Lab is best rep but harder", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Exalted)", "Ring of Cryptic Dreams (H Mana-Tombs)" },
                    },
                },
                { itemId = 29172, name = "Idol of the Raven Goddess", icon = "INV_Relics_IdolofRejuvenation", quality = "epic", slot = "Relic", stats = "+Moonfire/Wrath dmg", source = "Cenarion Expedition @ Exalted", sourceType = "rep", faction = "Cenarion Expedition", standing = 8,
                    hoverData = {
                        repSources = { "Coilfang dungeons (10-25 rep/kill)", "Turn in Unidentified Plant Parts (250 rep/10)" },
                        statPriority = { "BiS Balance idol for Moonfire/Wrath", "Essential for raiding Balance Druid" },
                        tips = { "Long grind - start CE dungeons early", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Ivory Idol of the Moongoddess (N Slave Pens)", "Idol of the Moon (Quest)" },
                    },
                },
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
                { itemId = 29171, name = "Earthwarden", icon = "INV_Mace_52", quality = "epic", slot = "Two-Hand Mace", stats = "+43 Sta, +556 AP, +24 Def", source = "Cenarion Expedition @ Exalted", sourceType = "rep", faction = "Cenarion Expedition", standing = 8,
                    hoverData = {
                        repSources = { "Coilfang dungeons (Slave Pens, Underbog, SV) - 10-25 rep/kill", "Turn in Plant Parts (250 rep/10, until Honored)" },
                        statPriority = { "BiS Feral tank weapon through T4/T5", "+24 Defense helps reach 415 for crits", "+556 AP and Stamina huge for bear" },
                        tips = { "Long grind - start CE dungeons early", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Braxxis' Staff of Slumber (H Underbog)", "Terestian's Stranglestaff (Kara)" },
                    },
                },
                { itemId = 29170, name = "Windcaller's Orb", icon = "INV_Misc_Orb_02", quality = "epic", slot = "Off Hand", stats = "+27 Sta, +18 Int, +18 Spi", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Coilfang dungeons (10-25 rep/kill)", "Turn in Plant Parts (250 rep/10, until Honored)" },
                        statPriority = { "Good caster off-hand for Resto set", "+27 Stamina adds survivability", "Not used in Bear form (2H weapon)" },
                        tips = { "Only need Revered - moderate grind", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Lamp of Peaceful Repose (H Bot)", "Tears of Heaven (Aldor Exalted)" },
                    },
                },
                { itemId = 29173, name = "Idol of Ursoc", icon = "INV_Relics_IdolofFerocity", quality = "epic", slot = "Relic", stats = "+Maul damage +54", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Coilfang dungeons (10-25 rep/kill)", "Turn in Plant Parts (250 rep/10, until Honored)" },
                        statPriority = { "BiS Feral tank idol for threat", "+54 Maul damage massive for TPS" },
                        tips = { "Only need Revered - same faction as Earthwarden", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Idol of the Wild (Quest)", "Everbloom Idol (H Underbog)" },
                    },
                },
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
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = { "Tempest Keep dungeons (Mech, Bot, Arc) - 10-25 rep/kill", "Aldor/Scryer turn-ins also grant Sha'tar rep" },
                        statPriority = { "Best pre-raid healing weapon for Resto", "+225 Healing massive for HoTs" },
                        tips = { "Long grind - start TK dungeons early", "Buy from Almaador in Sha'tar base (Shattrath)" },
                        alternatives = { "Light's Justice (Aldor Exalted)", "The Essence Focuser (H Mech)" },
                    },
                },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "+70 Healing passive, excellent for any healer", "Solid until Badge of Justice trinkets" },
                        tips = { "Only need Revered - easy grind", "Buy from Nakodu in Lower City (Shattrath)" },
                        alternatives = { "Bangle of Endless Blessings (H Arc)", "Essence of the Martyr (41 Badges)" },
                    },
                },
                { itemId = 29170, name = "Windcaller's Orb", icon = "INV_Misc_Orb_02", quality = "epic", slot = "Off Hand", stats = "+27 Sta, +18 Int, +18 Spi", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Coilfang dungeons (10-25 rep/kill)", "Turn in Plant Parts (250 rep/10, until Honored)" },
                        statPriority = { "Good caster off-hand for Resto Druid", "+18 Spirit benefits mana regen" },
                        tips = { "Only need Revered - moderate grind", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Lamp of Peaceful Repose (H Bot)", "Tears of Heaven (Aldor Exalted)" },
                    },
                },
                -- Non-rep item: Best pre-raid Resto Druid Idol (badge vendor)
                { itemId = 27886, name = "Idol of the Emerald Queen", icon = "INV_Relics_IdolofRejuvenation", quality = "rare", slot = "Relic", stats = "+47 Healing to Lifebloom", source = "G'eras (15 Badges)", sourceType = "badge",
                    hoverData = {
                        repSources = {
                            "Badge of Justice vendor in Shattrath",
                            "15 Badges of Justice",
                            "Badges from Heroics and Karazhan",
                        },
                        statPriority = {
                            "BiS pre-raid Idol for Resto Druids",
                            "+47 Healing per Lifebloom tick",
                            "Core part of rolling Lifebloom rotation",
                        },
                        tips = {
                            "Priority badge purchase for Resto",
                            "Heroics drop 3-5 badges each",
                            "Karazhan drops many badges",
                        },
                        alternatives = {
                            "Harold's Rejuvenating Broach (Kara Quest)",
                            "Idol of Rejuvenation (Quest)",
                        },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Elemental Shamans", "+8 Hit helps reach spell hit cap (16%)", "High spell power for Lightning Bolt/Chain Lightning" },
                        tips = { "Can grind to Revered in ~5 normal runs", "Pair with Carved Witch Doctor's Stick for crit off-hand", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Bleeding Hollow Warhammer (Quest)", "Gladiator's Gavel (Arena)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Best caster DPS ring for Ele Shaman pre-raid", "+23 Int adds to mana pool and crit" },
                        tips = { "Arakkoa Feather turn-ins speed up the grind", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Mana-Etched Band (Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29389, name = "Totem of the Void", icon = "Spell_Nature_Groundingtotem", quality = "rare", slot = "Relic", stats = "+55 Lightning Bolt dmg", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "BiS pre-raid totem for Lightning Bolt builds", "+55 damage per Lightning Bolt is massive DPS boost", "Core piece for Elemental DPS rotation" },
                        tips = { "Get this at Revered - much faster than Exalted ring", "Stack with spell power gear for huge LB damage", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Totem of Impact (Quest)", "Totem of the Storm (The Sha'tar)", "Totem of Lightning (Cenarion Expedition)" },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "Best pre-raid neck for Enhancement Shaman", "+22 Hit helps reach dual-wield hit cap", "+20 Agility provides crit and AP" },
                        tips = { "Farm Crystal Powder in Nagrand (ogres, ethereals)", "Mana-Tombs Heroic is fastest rep once keyed", "Buy from Karaaz in Stormspire (Netherstorm)" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid trinket for physical DPS specs", "+72 permanent AP + 278 AP on use (2min CD)", "Stacks with all enhancement buffs" },
                        tips = { "Shattered Halls gives best rep per run", "Use on-use with Heroism/Bloodlust", "Buy from Quartermaster Urgronn in Thrallmar" },
                        alternatives = { "Hourglass of the Unraveller (H Black Morass)", "Abacus of Violent Odds (H Mechanar)", "Icon of Unyielding Courage (Quest)" },
                    },
                },
                { itemId = 29390, name = "Totem of the Astral Winds", icon = "Spell_Nature_Windfury", quality = "rare", slot = "Relic", stats = "+80 Stormstrike AP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid totem for Enhancement Shaman", "+80 AP on Stormstrike is huge (~5% DPS increase)", "Core piece for melee enhancement rotation" },
                        tips = { "Get this at Revered - very quick grind", "Stormstrike should be used on cooldown", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Totem of Impact (Quest)", "Totem of the Storm (Lower City)", "Totem of Lightning (Cenarion Expedition)" },
                    },
                },
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
                { itemId = 29175, name = "Gavel of Pure Light", icon = "INV_Mace_53", quality = "epic", slot = "Main Hand", stats = "+225 Healing, +22 Int, +14 Sta", source = "The Sha'tar @ Exalted", sourceType = "rep", faction = "The Sha'tar", standing = 8,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "Best pre-raid healing mace for Resto Shaman", "+225 Healing is massive (equivalent to 10+ gem slots)", "+22 Int improves mana pool and crit" },
                        tips = { "Long grind - start heroics once Revered for speed", "Pair with Shield of the Wayward Footman", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Shard of the Virtuous (Maiden - Kara)", "The Essence Focuser (H Botanica)", "Hammer of the Penitent (Heroic Mech)" },
                    },
                },
                { itemId = 30841, name = "Lower City Prayerbook", icon = "INV_Misc_Book_09", quality = "rare", slot = "Trinket", stats = "+70 Healing, Reduce cost", source = "Lower City @ Revered", sourceType = "rep", faction = "Lower City", standing = 7,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Strong healing trinket with mana reduction proc", "+70 Healing passive bonus always active", "Proc reduces heal cost by 22 - great for Chain Heal" },
                        tips = { "Arakkoa Feather turn-ins speed up the grind", "Get this at Revered - reasonable grind", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Bangle of Endless Blessings (H Slave Pens)", "Essence of the Martyr (41 Badges)", "Ribbon of Sacrifice (Opera - Kara)" },
                    },
                },
                { itemId = 29388, name = "Totem of Healing Rains", icon = "Spell_Nature_HealingWaveGreater", quality = "rare", slot = "Relic", stats = "+79 Chain Heal heal", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid totem for Resto Shaman", "+79 healing per Chain Heal is significant throughput", "Core piece for raid healing rotation" },
                        tips = { "Get this at Revered - same faction as Gavel", "Chain Heal is your primary raid heal", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Totem of Spontaneous Regrowth (H Underbog)", "Totem of the Plains (Quest)", "Totem of Sustaining (Steamvault)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Arcane Mage", "+8 Hit helps reach spell hit cap (16%)", "High spell power boosts Arcane Blast damage" },
                        tips = { "Can grind to Revered in ~5 normal runs", "Pair with Carved Witch Doctor's Stick", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Best caster DPS ring for Arcane Mage pre-raid", "+23 Int adds to mana pool and crit" },
                        tips = { "Arakkoa Feather turn-ins speed up the grind", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Arcane Mage", "+35 Spell Power is significant DPS boost", "+20 Int benefits mana-hungry Arcane rotation" },
                        tips = { "Get this at Revered - reasonable grind", "Sha'tar also gives Gavel (healers) at Exalted", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Fire Mage", "+8 Hit helps reach spell hit cap (16%)", "High spell power boosts Fireball and Pyroblast" },
                        tips = { "Can grind to Revered in ~5 normal runs", "Fire benefits from Spellfire set crafted gear", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Best caster DPS ring for Fire Mage pre-raid", "+23 Int adds to mana pool and crit" },
                        tips = { "Fire rotation is mana-efficient so Int less critical", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Fire Mage", "+35 Spell Power significantly boosts Fire damage", "Generic spell power works for all schools" },
                        tips = { "Get this at Revered - reasonable grind", "Pairs well with Spellfire tailoring set", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Frost Mage", "+8 Hit helps reach spell hit cap (16%)", "High spell power boosts Frostbolt and Ice Lance" },
                        tips = { "Can grind to Revered in ~5 normal runs", "Frost benefits from Frozen Shadoweave set", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Best caster DPS ring for Frost Mage pre-raid", "Hit is critical for Frost's single-target damage" },
                        tips = { "Frost shatter combos need high hit", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Frost Mage", "+35 Spell Power boosts all Frost damage", "Generic spell power better than Frost-specific here" },
                        tips = { "Get this at Revered - reasonable grind", "Consider Frozen Shadoweave set for Frost-specific", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Affliction Lock", "+8 Hit helps reach spell hit cap (16%)", "Spell power boosts all DoT damage" },
                        tips = { "Affliction's DoTs scale well with spell power", "Pair with Shadow Damage off-hand", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Critical for Affliction's DoT consistency", "Hit cap ensures no missed applications" },
                        tips = { "DoTs that miss = huge DPS loss", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Affliction Lock", "+35 Spell Power boosts all DoT ticks", "Generic SP applies to all Shadow spells" },
                        tips = { "Get this at Revered - reasonable grind", "Stacks with Frozen Shadoweave bonus", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Demo Lock", "+8 Hit helps reach spell hit cap (16%)", "Your pet benefits from your spell power too" },
                        tips = { "Demo scales spell power to Felguard", "Can grind to Revered in ~5 normal runs", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Demo uses Shadow Bolt and needs hit cap", "+23 Int helps with mana for pet abilities" },
                        tips = { "Hit affects both you and pet's threat", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Demo Lock", "+35 Spell Power boosts you and pet", "Demonic Knowledge scales with your stats" },
                        tips = { "Get this at Revered - reasonable grind", "Pet power increases with your gear", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29185, name = "Continuum Blade", icon = "INV_Sword_66", quality = "rare", slot = "One-Hand Sword", stats = "+190 Spell Power, +8 Hit", source = "Keepers of Time @ Revered", sourceType = "rep", faction = "Keepers of Time", standing = 7,
                    hoverData = {
                        repSources = { "Old Hillsbrad Foothills (10-25 rep/kill)", "Black Morass (15-25 rep/kill)", "Caverns of Time quests (~4.5k rep total)" },
                        statPriority = { "Best pre-raid caster sword for Destro Lock", "+8 Hit helps reach spell hit cap (16%)", "Fire damage from Spellfire set works great" },
                        tips = { "Destro uses Shadow Bolt AND Incinerate", "Pair with Spellfire set for Fire spells", "Buy from Alurmi in Caverns of Time" },
                        alternatives = { "Starlight Dagger (Heroic Mech)", "Gladiator's Gavel (Arena)", "Nether-Core's Control Rod (H Mech)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Underbog turn-ins (Arakkoa Feathers - 250 rep per 30)" },
                        statPriority = { "Massive +23 Hit Rating (nearly 2% spell hit)", "Critical for Destro's high-damage nukes", "Missed Incinerates = huge DPS loss" },
                        tips = { "Destro is burst spec - every hit matters", "Shadow Labyrinth gives best rep per run", "Buy from Nakodu in Shattrath Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Expedition Exalted)", "Band of the Guardian (Black Morass Quest)", "Sparking Arcanite Ring (Heroic Mech)" },
                    },
                },
                { itemId = 29179, name = "Xi'ri's Gift", icon = "INV_Jewelry_Necklace_17", quality = "epic", slot = "Neck", stats = "+22 Sta, +20 Int, +35 SP", source = "The Sha'tar @ Revered", sourceType = "rep", faction = "The Sha'tar", standing = 7,
                    hoverData = {
                        repSources = { "Botanica / Mechanar / Arcatraz (10-25 rep/kill)", "Sha'tar quests in Shattrath and Netherstorm (~4k rep)", "Aldor/Scryer spillover (50% of their rep gains)" },
                        statPriority = { "BiS pre-raid neck for Destro Lock", "+35 Spell Power applies to all schools", "Generic SP works for Shadow AND Fire" },
                        tips = { "Get this at Revered - reasonable grind", "Works with hybrid Fire/Shadow builds", "Buy from Almaador in Shattrath Terrace of Light" },
                        alternatives = { "Brooch of Heightened Potential (Nightbane)", "Manasurge Pendant (25 Badges)", "Pendant of the Lost Ages (H Arc)" },
                    },
                },
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
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "Best pre-raid bow for all Hunter specs", "+16 Hit helps reach ranged hit cap (9%)", "Weapon DPS is your most important stat" },
                        tips = { "Hellfire dungeons give rep even at 70", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Beast Mastery Hunter", "+22 Hit helps reach 9% ranged hit cap", "+20 Agility adds crit and RAP" },
                        tips = { "Farm Crystal Powder in Nagrand for fast rep", "Mana-Tombs Heroic once keyed", "Buy from Karaaz in Stormspire (Netherstorm)" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid trinket for all physical DPS", "+72 permanent AP + 278 AP on use (2min CD)", "Pop with Bestial Wrath for massive burst" },
                        tips = { "Use on-use with Kill Command and Bestial Wrath", "Shattered Halls gives best rep per run", "Buy from Quartermaster Urgronn in Thrallmar" },
                        alternatives = { "Hourglass of the Unraveller (H Black Morass)", "Abacus of Violent Odds (H Mechanar)", "Icon of Unyielding Courage (Quest)" },
                    },
                },
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
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid bow for Marksmanship Hunter", "+16 Hit critical for Aimed Shot hits", "Weapon DPS directly affects Aimed Shot damage" },
                        tips = { "MM Hunters need more hit than BM", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Marksmanship Hunter", "+22 Hit helps reach 9% ranged hit cap", "+20 Agility benefits Trueshot Aura" },
                        tips = { "Farm Crystal Powder in Nagrand for fast rep", "Mana-Tombs Heroic once keyed", "Buy from Karaaz in Stormspire (Netherstorm)" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid trinket for Marksmanship", "+72 permanent AP + 278 AP on use (2min CD)", "Use with Rapid Fire for burst damage" },
                        tips = { "Stack with Rapid Fire and haste effects", "Shattered Halls gives best rep per run", "Buy from Quartermaster Urgronn in Thrallmar" },
                        alternatives = { "Hourglass of the Unraveller (H Black Morass)", "Abacus of Violent Odds (H Mechanar)", "Icon of Unyielding Courage (Quest)" },
                    },
                },
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
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid bow for Survival Hunter", "+16 Hit critical for trap consistency", "Agility scales with Survival talents" },
                        tips = { "Survival benefits heavily from Agility", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Survival Hunter", "+22 Hit helps reach 9% ranged hit cap", "+20 Agility synergizes with Lightning Reflexes" },
                        tips = { "Farm Crystal Powder in Nagrand for fast rep", "Survival gets extra crit from Agility", "Buy from Karaaz in Stormspire (Netherstorm)" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Slave Pens / Underbog / Steamvault (10-25 rep/kill)", "Cenarion quests in Zangarmarsh/Blade's Edge (~6k rep)", "Unidentified Plant Parts turn-in (250 rep per 10)" },
                        statPriority = { "Solid Survival Hunter chest with high Agility", "+30 Agi benefits Lightning Reflexes talent", "Good alternative while farming Beast Lord" },
                        tips = { "Plant Parts turn-in works until Honored", "Steamvault Heroic is fastest Revered+", "Buy from Fedryen Swiftspear in Zangarmarsh" },
                        alternatives = { "Beast Lord Cuirass (Mana-Tombs)", "Stealthbinder's Chestguard (Shadow Lab)", "Fel Leather Vest (Leatherworking)" },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Assassination Rogues", "+22 Hit Rating crucial for poison application", "Agility boosts crit for Seal Fate procs" },
                        tips = { "Hit cap for poisons is 315 rating (24%)", "Farm Oshu'gun Powder from Nagrand ogres", "Mana-Tombs Heroic is fastest rep once keyed" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Arakkoa Feather turn-ins (250 rep per 30)" },
                        statPriority = { "Best pre-raid ring for melee DPS", "+23 Hit Rating helps cap special attacks", "+24 Agility provides crit for Mutilate builds" },
                        tips = { "Shadow Labyrinth gives most rep per run", "Pair with Garona's Signet Ring for hit stacking", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ring of Umbral Doom (H Sethekk)", "Delicate Eternium Ring (Jewelcrafting)", "A'dal's Command (The Sha'tar)" },
                    },
                },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Coilfang dungeons (Slave Pens, Underbog, Steamvault - 5-15 rep/kill)", "Unidentified Plant Parts turn-in (250 rep each, to Honored)", "Cenarion Expedition quests in Zangarmarsh/Blade's Edge" },
                        statPriority = { "Solid pre-raid leather chest for Assassination", "+30 Agility excellent for crit-based builds", "High stamina aids dungeon survival" },
                        tips = { "Get at Revered - easier than Exalted gear", "Steamvault gives most rep at higher levels", "Int is wasted but other stats are strong" },
                        alternatives = { "Stealthbinder's Chestguard (Shadow Lab)", "Primalstrike Vest (Leatherworking)", "Clefthoof Hide Tunic (Crafted)" },
                    },
                },
                -- Non-rep item: Best pre-raid thrown for Rogues (crafted)
                { itemId = 29204, name = "Felsteel Whisper Knives", icon = "INV_ThrowingKnife_03", quality = "rare", slot = "Thrown", stats = "+10 Agi, +9 Sta", source = "Engineering (365)", sourceType = "crafted",
                    hoverData = {
                        repSources = {
                            "Crafted by Engineers (365 skill)",
                            "Mats: 6 Felsteel Bar, 2 Hardened Adamantite Bar",
                            "Schematic from Shattered Halls (rare drop)",
                        },
                        statPriority = {
                            "Best pre-raid thrown for Rogues",
                            "+10 Agility adds crit chance",
                            "Ranged slot is low priority for melee",
                        },
                        tips = {
                            "Ask guild engineer to craft",
                            "Mats cost ~50-100g",
                            "One-time craft, lasts forever",
                        },
                        alternatives = {
                            "Vendor throwing weapons",
                            "Carved Bone Boomerang (Quest)",
                            "Low priority upgrade",
                        },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Combat Rogues", "+22 Hit Rating essential for white hit cap", "Agility boosts crit for Combat Potency procs" },
                        tips = { "Combat needs 363 hit rating for dual-wield cap", "Pair with other hit pieces early on", "Mana-Tombs Heroic is fastest rep once keyed" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Arakkoa Feather turn-ins (250 rep per 30)" },
                        statPriority = { "Best pre-raid ring for Combat Rogues", "+23 Hit Rating helps reach dual-wield cap", "+24 Agility boosts Sinister Strike crit chance" },
                        tips = { "Shadow Labyrinth gives most rep per run", "Essential for Combat Rogues stacking hit", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ring of Umbral Doom (H Sethekk)", "Delicate Eternium Ring (Jewelcrafting)", "A'dal's Command (The Sha'tar)" },
                    },
                },
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (5-25 rep/kill)", "Thrallmar quests in Hellfire Peninsula (~8k rep)", "Fel Orc Blood turn-ins (Honored to Exalted)" },
                        statPriority = { "BiS on-use trinket for Combat burst", "+72 passive AP always active", "Use effect stacks with Blade Flurry + Adrenaline Rush" },
                        tips = { "Macro to Blade Flurry for cleave burst", "2 min cooldown syncs with major cooldowns", "Buy from Quartermaster in Thrallmar" },
                        alternatives = { "Abacus of Violent Odds (H Mech)", "Hourglass of the Unraveller (Black Morass)", "Dragonspine Trophy (Gruul)" },
                    },
                },
                -- Non-rep item: Best pre-raid thrown for Rogues (crafted)
                { itemId = 29204, name = "Felsteel Whisper Knives", icon = "INV_ThrowingKnife_03", quality = "rare", slot = "Thrown", stats = "+10 Agi, +9 Sta", source = "Engineering (365)", sourceType = "crafted",
                    hoverData = {
                        repSources = {
                            "Crafted by Engineers (365 skill)",
                            "Mats: 6 Felsteel Bar, 2 Hardened Adamantite Bar",
                            "Schematic from Shattered Halls (rare drop)",
                        },
                        statPriority = {
                            "Best pre-raid thrown for Rogues",
                            "+10 Agility adds crit chance",
                            "Ranged slot is low priority for melee",
                        },
                        tips = {
                            "Ask guild engineer to craft",
                            "Mats cost ~50-100g",
                            "One-time craft, lasts forever",
                        },
                        alternatives = {
                            "Vendor throwing weapons",
                            "Carved Bone Boomerang (Quest)",
                            "Low priority upgrade",
                        },
                    },
                },
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
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Oshu'gun Crystal Powder Samples (250 rep per 10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Subtlety Rogues", "+22 Hit Rating vital for Hemorrhage uptime", "Agility boosts crit for Honor Among Thieves" },
                        tips = { "Subtlety needs consistent hit for debuff maintenance", "Farm Oshu'gun Powder from Nagrand ogres", "Mana-Tombs Heroic is fastest rep once keyed" },
                        alternatives = { "Natasha's Ember Necklace (Quest: Nagrand)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Agi, +22 Sta, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts / Sethekk Halls / Shadow Lab (10-25 rep/kill)", "Lower City quests in Terokkar (~6k rep)", "Arakkoa Feather turn-ins (250 rep per 30)" },
                        statPriority = { "Excellent ring for Subtlety builds", "+23 Hit Rating helps land finishers reliably", "+24 Agility provides crit for combo point generation" },
                        tips = { "Shadow Labyrinth gives most rep per run", "Subtlety excels in arena - gear appropriately", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ring of Umbral Doom (H Sethekk)", "Delicate Eternium Ring (Jewelcrafting)", "A'dal's Command (The Sha'tar)" },
                    },
                },
                { itemId = 25838, name = "Warden's Hauberk", icon = "INV_Chest_Leather_03", quality = "rare", slot = "Chest", stats = "+30 Agi, +27 Sta, +20 Int", source = "Cenarion Expedition @ Revered", sourceType = "rep", faction = "Cenarion Expedition", standing = 7,
                    hoverData = {
                        repSources = { "Coilfang dungeons (Slave Pens, Underbog, Steamvault - 5-15 rep/kill)", "Unidentified Plant Parts turn-in (250 rep each, to Honored)", "Cenarion Expedition quests in Zangarmarsh/Blade's Edge" },
                        statPriority = { "Solid leather chest for Subtlety Rogues", "+30 Agility excellent for crit and dodge", "High stamina aids survival in PvP" },
                        tips = { "Get at Revered - faster than Exalted gear", "Subtlety benefits from high agility stacking", "Int stat is wasted but other stats compensate" },
                        alternatives = { "Stealthbinder's Chestguard (Shadow Lab)", "Primalstrike Vest (Leatherworking)", "Gladiator's Leather Tunic (Arena)" },
                    },
                },
                -- Non-rep item: Best pre-raid thrown for Rogues (crafted)
                { itemId = 29204, name = "Felsteel Whisper Knives", icon = "INV_ThrowingKnife_03", quality = "rare", slot = "Thrown", stats = "+10 Agi, +9 Sta", source = "Engineering (365)", sourceType = "crafted",
                    hoverData = {
                        repSources = {
                            "Crafted by Engineers (365 skill)",
                            "Mats: 6 Felsteel Bar, 2 Hardened Adamantite Bar",
                            "Schematic from Shattered Halls (rare drop)",
                        },
                        statPriority = {
                            "Best pre-raid thrown for Rogues",
                            "+10 Agility adds crit chance",
                            "Ranged slot is low priority for melee",
                        },
                        tips = {
                            "Ask guild engineer to craft",
                            "Mats cost ~50-100g",
                            "One-time craft, lasts forever",
                        },
                        alternatives = {
                            "Vendor throwing weapons",
                            "Carved Bone Boomerang (Quest)",
                            "Low priority upgrade",
                        },
                    },
                },
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

--============================================================================
-- LEVELING GEAR MATRIX (Pre-68 Outland Content)
-- Organized by role -> level range -> source type (dungeon/quest)
-- Each category contains 3 recommended items for that leveling phase
--============================================================================

C.LEVELING_RANGES = {
    { key = "60-62", minLevel = 60, maxLevel = 62, label = "Level 60-62", dungeonGroup = "Hellfire Citadel" },
    { key = "63-65", minLevel = 63, maxLevel = 65, label = "Level 63-65", dungeonGroup = "Coilfang / Auchindoun" },
    { key = "66-67", minLevel = 66, maxLevel = 67, label = "Level 66-67", dungeonGroup = "Auchindoun / Caverns of Time" },
}

C.LEVELING_ROLES = {
    tank = { name = "Tank", icon = "Ability_Warrior_DefensiveStance", color = "SKY_BLUE" },
    healer = { name = "Healer", icon = "Spell_Holy_FlashHeal", color = "FEL_GREEN" },
    melee_dps = { name = "Melee DPS", icon = "Ability_MeleeDamage", color = "HELLFIRE_RED" },
    ranged_dps = { name = "Ranged DPS", icon = "Ability_Hunter_AimedShot", color = "GOLD_BRIGHT" },
    caster_dps = { name = "Caster DPS", icon = "Spell_Fire_FlameBolt", color = "ARCANE_PURPLE" },
}

C.LEVELING_DUNGEONS = {
    ["60-62"] = {
        { name = "Hellfire Ramparts", level = "60-62", zone = "Hellfire Peninsula" },
        { name = "Blood Furnace", level = "61-63", zone = "Hellfire Peninsula" },
    },
    ["63-65"] = {
        { name = "Slave Pens", level = "62-64", zone = "Zangarmarsh" },
        { name = "Underbog", level = "63-65", zone = "Zangarmarsh" },
        { name = "Mana-Tombs", level = "64-66", zone = "Terokkar Forest" },
    },
    ["66-67"] = {
        { name = "Auchenai Crypts", level = "65-67", zone = "Terokkar Forest" },
        { name = "Old Hillsbrad", level = "66-68", zone = "Caverns of Time" },
        { name = "Sethekk Halls", level = "67-69", zone = "Terokkar Forest" },
    },
}

C.LEVELING_GEAR_MATRIX = {
    --========================================================================
    -- TANK
    --========================================================================
    ["tank"] = {
        ["60-62"] = {
            dungeons = {
                { itemId = 24064, name = "Ironsole Clompers", icon = "INV_Boots_Plate_09", quality = "rare", slot = "Feet", stats = "+19 Sta, +14 Str, +19 Def", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Vazruden" },
                { itemId = 24091, name = "Tenacious Defender", icon = "INV_Belt_13", quality = "rare", slot = "Waist", stats = "+19 Sta, +15 Str, +14 Agi", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Omor" },
                { itemId = 24387, name = "Ironblade Gauntlets", icon = "INV_Gauntlets_28", quality = "rare", slot = "Hands", stats = "+20 Str, +14 Agi, +19 Sta, +6 Hit", source = "Blood Furnace", sourceType = "dungeon", boss = "The Maker" },
            },
            quests = {
                { itemId = 25715, name = "Jade Warrior Pauldrons", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Sta, +20 Str, +19 Agi", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25712, name = "Perfectly Balanced Cape", icon = "INV_Misc_Cape_14", quality = "rare", slot = "Back", stats = "+22 Sta, +15 Agi, +30 AP", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
                -- Note: Hellreaver polearm removed - Feral Druids can't use polearms, was also wrong category (dungeon drop, not quest)
            },
        },
        ["63-65"] = {
            dungeons = {
                { itemId = 24379, name = "Bogstrok Scale Cloak", icon = "INV_Misc_Cape_18", quality = "rare", slot = "Back", stats = "+22 Sta, +16 Def, +208 Armor", source = "Slave Pens", sourceType = "dungeon", boss = "Rokmar" },
                { itemId = 24363, name = "Unscarred Breastplate", icon = "INV_Chest_Plate_11", quality = "rare", slot = "Chest", stats = "+23 Sta, +26 Str, +21 Agi", source = "Slave Pens", sourceType = "dungeon", boss = "Quagmirran" },
                { itemId = 24463, name = "Pauldrons of Brute Force", icon = "INV_Shoulder_28", quality = "rare", slot = "Shoulder", stats = "+22 Sta, +16 Str, +18 Def", source = "Underbog", sourceType = "dungeon", boss = "Black Stalker" },
            },
            quests = {
                { itemId = 25540, name = "Dark Cloak of the Marsh", icon = "INV_Misc_Cape_16", quality = "rare", slot = "Back", stats = "+16 Agi, +24 Sta, +30 AP", source = "Lost in Action", sourceType = "quest", zone = "Zangarmarsh" },
                { itemId = 29336, name = "Mark of the Ravenguard", icon = "INV_Jewelry_Necklace_21", quality = "rare", slot = "Neck", stats = "+40 Sta, +17 Def", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29337, name = "The Exarch's Protector", icon = "INV_Chest_Plate_15", quality = "rare", slot = "Chest", stats = "+30 Str, +23 Def, +18 Crit", source = "Everything Will Be Alright", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
        ["66-67"] = {
            dungeons = {
                { itemId = 27436, name = "Iron Band of the Unbreakable", icon = "INV_Jewelry_Ring_36", quality = "rare", slot = "Ring", stats = "+27 Sta, +17 Def, +170 Armor", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Lt. Drake" },
                { itemId = 27427, name = "Durotan's Battle Harness", icon = "INV_Chest_Plate_14", quality = "rare", slot = "Chest", stats = "+34 Sta, +31 Str, +16 Crit", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Captain Skarloc" },
                { itemId = 27847, name = "Fanblade Pauldrons", icon = "INV_Shoulder_30", quality = "rare", slot = "Shoulder", stats = "+22 Sta, +16 Str, +20 Def, +15 Parry", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Shirrak" },
            },
            quests = {
                { itemId = 29316, name = "Warchief's Mantle", icon = "INV_Shoulder_32", quality = "rare", slot = "Shoulder", stats = "+27 Sta, +23 Str, +18 Parry", source = "Return to Andormu", sourceType = "quest", zone = "Tanaris" },
                { itemId = 29336, name = "Mark of the Ravenguard", icon = "INV_Jewelry_Necklace_21", quality = "rare", slot = "Neck", stats = "+40 Sta, +17 Def", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29337, name = "The Exarch's Protector", icon = "INV_Chest_Plate_15", quality = "rare", slot = "Chest", stats = "+30 Str, +23 Def, +18 Crit", source = "Everything Will Be Alright", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
    },

    --========================================================================
    -- HEALER
    --========================================================================
    ["healer"] = {
        ["60-62"] = {
            dungeons = {
                { itemId = 24083, name = "Lifegiver Britches", icon = "INV_Pants_Cloth_14", quality = "rare", slot = "Legs", stats = "+25 Int, +16 Sta, +12 Spirit, +44 Heal", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Vazruden" },
                { itemId = 24397, name = "Raiments of Divine Authority", icon = "INV_Chest_Cloth_43", quality = "rare", slot = "Chest", stats = "+21 Int, +16 Sta, +18 Spirit, +46 Heal", source = "Blood Furnace", sourceType = "dungeon", boss = "Keli'dan" },
                { itemId = 24096, name = "Heartblood Prayer Beads", icon = "INV_Jewelry_Necklace_19", quality = "rare", slot = "Neck", stats = "+15 Int, +15 Sta, +31 Heal, +4 mp5", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Omor" },
            },
            quests = {
                { itemId = 25718, name = "Mantle of Magical Might", icon = "INV_Shoulder_09", quality = "rare", slot = "Shoulder", stats = "+17 Int, +16 Sta, +10 Spirit, +16 Crit, +19 Spell", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25714, name = "Crimson Pendant of Clarity", icon = "INV_Jewelry_Necklace_17", quality = "rare", slot = "Neck", stats = "+15 Int, +18 Spell, +6 mp5", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25713, name = "Holy Healing Band", icon = "INV_Jewelry_Ring_33", quality = "rare", slot = "Ring", stats = "+15 Int, +33 Heal, +6 mp5", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
            },
        },
        ["63-65"] = {
            dungeons = {
                { itemId = 24378, name = "Coilfang Hammer of Renewal", icon = "INV_Hammer_16", quality = "rare", slot = "Mace", stats = "+13 Int, +10 Sta, +12 Spirit, +106 Heal", source = "Slave Pens", sourceType = "dungeon", boss = "Rokmar" },
                { itemId = 24481, name = "Robes of the Augurer", icon = "INV_Chest_Cloth_46", quality = "rare", slot = "Chest", stats = "+18 Int, +18 Sta, +11 Spirit, +28 Spell", source = "Underbog", sourceType = "dungeon", boss = "Black Stalker" },
                { itemId = 24359, name = "Princely Reign Leggings", icon = "INV_Pants_Cloth_15", quality = "rare", slot = "Legs", stats = "+28 Int, +18 Sta, +12 Spirit, +33 Heal", source = "Slave Pens", sourceType = "dungeon", boss = "Mennu" },
            },
            quests = {
                { itemId = 28029, name = "Goldenvine Wraps", icon = "INV_Bracer_07", quality = "rare", slot = "Wrist", stats = "+14 Int, +24 Heal", source = "Lost in Action", sourceType = "quest", zone = "Zangarmarsh" },
                { itemId = 29345, name = "Haramad's Leg Wraps", icon = "INV_Pants_Cloth_15", quality = "rare", slot = "Legs", stats = "+29 Spirit, +24 Heal, +8 Spell, +11 mp5, 3 sockets", source = "Undercutting the Competition", sourceType = "quest", zone = "Terokkar Forest" },
                -- Note: Consortium Prince's Wrap removed from healer - it's a caster DPS item (+Crit, +Spell Pen, no +Heal)
            },
        },
        ["66-67"] = {
            dungeons = {
                { itemId = 27412, name = "Ironstaff of Regeneration", icon = "INV_Staff_48", quality = "rare", slot = "Staff", stats = "+29 Int, +33 Sta, +35 Spirit, +143 Heal", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Exarch Maladaar" },
                { itemId = 27410, name = "Collar of Command", icon = "INV_Helmet_48", quality = "rare", slot = "Head", stats = "+23 Int, +29 Spirit, +66 Heal", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Shirrak" },
                { itemId = 27411, name = "Slippers of Serenity", icon = "INV_Boots_Cloth_10", quality = "rare", slot = "Feet", stats = "+22 Int, +10 Sta, +15 Spirit, +35 Heal, 2 sockets", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Exarch Maladaar" },
            },
            quests = {
                { itemId = 29317, name = "Tempest's Touch", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+20 Int, +10 Sta, +6 Spirit, +27 Spell, +10 Spell Pen, 2 sockets", source = "Return to Andormu", sourceType = "quest", zone = "Tanaris" },
                { itemId = 29334, name = "Sethekk Oracle's Focus", icon = "INV_Jewelry_Necklace_23", quality = "rare", slot = "Neck", stats = "+18 Int, +36 Heal", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29341, name = "Auchenai Anchorite's Robe", icon = "INV_Chest_Cloth_47", quality = "rare", slot = "Chest", stats = "+22 Int, +14 Spirit, +40 Heal", source = "Everything Will Be Alright", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
    },

    --========================================================================
    -- MELEE DPS
    --========================================================================
    ["melee_dps"] = {
        -- NOTE: Rogues can use daggers, 1H swords, 1H maces, fist weapons (NO polearms, NO 2H swords, NO axes)
        -- NOTE: Feral Druids can use daggers, maces (1H/2H), staves, fist weapons (NO axes/swords/polearms) - prefer 2H
        -- NOTE: Enhancement Shamans can use daggers, maces (1H/2H), axes, fist weapons (NO swords/polearms) - dual wield
        -- NOTE: Ret Paladins can use swords, maces, axes, polearms (2H preferred)
        -- WEAPON CONFLICT: Showing shared leather armor only; weapons excluded due to class conflicts
        ["60-62"] = {
            dungeons = {
                -- Note: Hellreaver polearm removed - Rogues CAN'T use polearms (only Warriors/Paladins/Hunters/Druids)
                -- Note: Druids also can't use polearms, so no melee_dps class here can use it
                { itemId = 24396, name = "Vest of Vengeance", icon = "INV_Chest_Leather_07", quality = "rare", slot = "Chest", stats = "+27 Agi, +18 Sta, +42 AP, +11 Hit", source = "Blood Furnace", sourceType = "dungeon", boss = "Keli'dan" },
                { itemId = 24063, name = "Shifting Sash of Midnight", icon = "INV_Belt_03", quality = "rare", slot = "Waist", stats = "+20 Agi, +19 Sta, +12 Hit", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Vazruden" },
            },
            quests = {
                -- Note: Handguards of Precision removed - it's MAIL armor, rogues/druids can't equip
                { itemId = 25717, name = "Sure-Step Boots", icon = "INV_Boots_Leather_07", quality = "uncommon", slot = "Feet", stats = "+20 Agi, +28 Sta, +38 AP", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25712, name = "Perfectly Balanced Cape", icon = "INV_Misc_Cape_14", quality = "rare", slot = "Back", stats = "+15 Agi, +22 Sta, +30 AP", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
            },
        },
        ["63-65"] = {
            dungeons = {
                -- Note: Creepjacker (fist weapon) removed - Ferals prefer 2H, Rogues have spec-specific weapon needs
                { itemId = 24365, name = "Deft Handguards", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+52 AP, +12 Crit, +18 Sta", source = "Slave Pens", sourceType = "dungeon", boss = "Quagmirran" },
                { itemId = 24466, name = "Skulldugger's Leggings", icon = "INV_Pants_Leather_11", quality = "rare", slot = "Legs", stats = "+40 AP, +21 Dodge, +16 Hit, +24 Sta", source = "Underbog", sourceType = "dungeon", boss = "Black Stalker" },
            },
            quests = {
                { itemId = 25540, name = "Dark Cloak of the Marsh", icon = "INV_Misc_Cape_16", quality = "rare", slot = "Back", stats = "+16 Agi, +24 Sta, +30 AP", source = "Lost in Action", sourceType = "quest", zone = "Zangarmarsh" },
                { itemId = 29343, name = "Haramad's Leggings of the Third Coin", icon = "INV_Pants_Leather_12", quality = "uncommon", slot = "Legs", stats = "+22 Agi, +20 Sta, +32 AP", source = "Undercutting the Competition", sourceType = "quest", zone = "Terokkar Forest" },
                -- Note: Cryo-mitts removed - it's a caster item (Int/Spirit/+Heal), not melee agility
            },
        },
        ["66-67"] = {
            dungeons = {
                { itemId = 27415, name = "Darkguard Face Mask", icon = "INV_Helmet_15", quality = "rare", slot = "Head", stats = "+29 Agi, +30 Sta, +20 Hit, +60 AP", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Exarch Maladaar" },
                -- Note: Weapons removed - Ferals prefer 2H, Rogues have spec-specific weapon needs; focus on armor upgrades
                { itemId = 27423, name = "Cloak of Impulsiveness", icon = "INV_Misc_Cape_10", quality = "rare", slot = "Back", stats = "+18 Agi, +19 Sta, +40 AP", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Lieutenant Drake" },
                { itemId = 27434, name = "Mantle of Perenolde", icon = "INV_Shoulder_23", quality = "rare", slot = "Shoulder", stats = "+24 Sta, +23 Hit, +23 Crit, +20 AP", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Epoch Hunter" },
            },
            quests = {
                { itemId = 29335, name = "Talon Lord's Collar", icon = "INV_Jewelry_Necklace_25", quality = "rare", slot = "Neck", stats = "+19 Sta, +21 Hit, +38 AP", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29340, name = "Auchenai Monk's Tunic", icon = "INV_Chest_Leather_01", quality = "uncommon", slot = "Chest", stats = "+24 Agi, +24 Dodge, +19 Hit, +18 AP", source = "Everything Will Be Alright", sourceType = "quest", zone = "Terokkar Forest" },
                -- Note: Terokk's Quill (polearm) removed - druids can't use polearms; no good melee weapon quest rewards at this level
            },
        },
    },

    --========================================================================
    -- RANGED DPS (Hunter)
    -- Note: Hunters can wear leather; mail boots with agility are scarce at 60-65
    --========================================================================
    ["ranged_dps"] = {
        ["60-62"] = {
            dungeons = {
                { itemId = 24389, name = "Legion Blunderbuss", icon = "INV_Weapon_Rifle_07", quality = "rare", slot = "Gun", stats = "+9 Agi, +24 AP", source = "Blood Furnace", sourceType = "dungeon", boss = "Broggok" },
                { itemId = 24022, name = "Scale Leggings of the Skirmisher", icon = "INV_Pants_Mail_10", quality = "rare", slot = "Legs", stats = "+22 Agi, +24 Sta, +32 AP", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Gargolmar" },
                { itemId = 24073, name = "Garrote-String Necklace", icon = "INV_Jewelry_Necklace_20", quality = "rare", slot = "Neck", stats = "+36 AP, +14 Crit, +16 Sta", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Omor" },
            },
            quests = {
                -- Note: Hunters can wear leather; mail agility quest rewards are very limited in 60-62
                { itemId = 25716, name = "Handguards of Precision", icon = "INV_Gauntlets_24", quality = "uncommon", slot = "Hands", stats = "+20 Agi, +28 Sta, +38 AP", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25717, name = "Sure-Step Boots", icon = "INV_Boots_Leather_07", quality = "uncommon", slot = "Feet", stats = "+20 Agi, +28 Sta, +38 AP", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
            },
        },
        ["63-65"] = {
            dungeons = {
                { itemId = 24381, name = "Coilfang Needler", icon = "INV_Weapon_Crossbow_07", quality = "rare", slot = "Crossbow", stats = "+12 Agi, +22 AP", source = "Slave Pens", sourceType = "dungeon", boss = "Rokmar" },
                { itemId = 24465, name = "Shamblehide Chestguard", icon = "INV_Chest_Chain_08", quality = "rare", slot = "Chest", stats = "+16 Sta, +19 Int, +21 Crit, +44 AP", source = "Underbog", sourceType = "dungeon", boss = "Black Stalker" },
                { itemId = 25946, name = "Nethershade Boots", icon = "INV_Boots_Leather_08", quality = "rare", slot = "Feet", stats = "+22 Agi, +21 Sta, +44 AP", source = "Mana-Tombs", sourceType = "dungeon", boss = "Tavarok" },
            },
            quests = {
                -- Note: Mail agility legs are scarce in quests; dungeon drops (Shamblehide/Nethershade) are primary upgrades
                { itemId = 25540, name = "Dark Cloak of the Marsh", icon = "INV_Misc_Cape_16", quality = "rare", slot = "Back", stats = "+16 Agi, +24 Sta, +30 AP", source = "Lost in Action", sourceType = "quest", zone = "Zangarmarsh" },
                { itemId = 29326, name = "Consortium Mantle of Phasing", icon = "INV_Shoulder_22", quality = "uncommon", slot = "Shoulder", stats = "+21 Crit, +46 AP", source = "Someone Else's Hard Work Pays Off", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
        ["66-67"] = {
            dungeons = {
                { itemId = 27413, name = "Ring of the Exarchs", icon = "INV_Jewelry_Ring_49", quality = "rare", slot = "Ring", stats = "+17 Agi, +24 Sta, +34 AP", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Exarch Maladaar" },
                { itemId = 27414, name = "Mok'Nathal Beast-Mask", icon = "INV_Helmet_50", quality = "rare", slot = "Head", stats = "+23 Agi, +22 Sta, +44 AP", source = "Auchenai Crypts", sourceType = "dungeon", boss = "Exarch Maladaar" },
                { itemId = 27430, name = "Scaled Greaves of Patience", icon = "INV_Pants_Mail_15", quality = "rare", slot = "Legs", stats = "+28 Agi, +13 Int, +46 AP, +24 Sta", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Captain Skarloc" },
            },
            quests = {
                { itemId = 29319, name = "Tarren Mill Defender's Cinch", icon = "INV_Belt_14", quality = "uncommon", slot = "Waist", stats = "+18 Agi, +16 Sta", source = "Return to Andormu", sourceType = "quest", zone = "Tanaris" },
                { itemId = 29335, name = "Talon Lord's Collar", icon = "INV_Jewelry_Necklace_25", quality = "rare", slot = "Neck", stats = "+19 Sta, +21 Hit, +38 AP", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29339, name = "Auchenai Tracker's Hauberk", icon = "INV_Chest_Chain_11", quality = "uncommon", slot = "Chest", stats = "+29 Int, +60 AP, +5 mp5", source = "Everything Will Be Alright", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
    },

    --========================================================================
    -- CASTER DPS
    --========================================================================
    ["caster_dps"] = {
        ["60-62"] = {
            dungeons = {
                { itemId = 24069, name = "Crystalfire Staff", icon = "INV_Staff_38", quality = "rare", slot = "Staff", stats = "+34 Int, +34 Sta, +46 Spell", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Omor" },
                -- Note: Diamond-Core Sledgemace removed - 2H Mace, Mages/Warlocks can't use maces
                { itemId = 24024, name = "Pauldrons of Arcane Rage", icon = "INV_Shoulder_18", quality = "rare", slot = "Shoulder", stats = "+18 Int, +18 Sta, +27 Spell", source = "Hellfire Ramparts", sourceType = "dungeon", boss = "Gargolmar" },
            },
            quests = {
                { itemId = 25718, name = "Mantle of Magical Might", icon = "INV_Shoulder_09", quality = "rare", slot = "Shoulder", stats = "+17 Int, +16 Sta, +10 Spirit, +16 Crit, +19 Spell", source = "Weaken the Ramparts", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25711, name = "Deadly Borer Leggings", icon = "INV_Pants_Cloth_13", quality = "rare", slot = "Legs", stats = "+23 Int, +21 Sta, +15 Spirit, +22 Crit, +27 Spell", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
                { itemId = 25714, name = "Crimson Pendant of Clarity", icon = "INV_Jewelry_Necklace_17", quality = "rare", slot = "Neck", stats = "+15 Int, +18 Spell, +6 mp5", source = "Heart of Rage", sourceType = "quest", zone = "Hellfire Peninsula" },
            },
        },
        ["63-65"] = {
            dungeons = {
                { itemId = 25950, name = "Staff of Polarities", icon = "INV_Staff_42", quality = "rare", slot = "Staff", stats = "+33 Int, +34 Sta, +28 Hit, +67 Spell", source = "Mana-Tombs", sourceType = "dungeon", boss = "Tavarok" },
                { itemId = 24462, name = "Luminous Pearls of Insight", icon = "INV_Jewelry_Necklace_16", quality = "rare", slot = "Neck", stats = "+15 Int, +11 Crit, +25 Spell", source = "Underbog", sourceType = "dungeon", boss = "Ghaz'an" },
                { itemId = 24362, name = "Spore-Soaked Vaneer", icon = "INV_Shoulder_15", quality = "rare", slot = "Shoulder", stats = "+15 Int, +15 Sta, +11 Crit, +19 Spell", source = "Slave Pens", sourceType = "dungeon", boss = "Quagmirran" },
            },
            quests = {
                { itemId = 25541, name = "Cenarion Ring of Casting", icon = "INV_Jewelry_Ring_38", quality = "uncommon", slot = "Ring", stats = "+14 Int, +18 Spell", source = "Lost in Action", sourceType = "quest", zone = "Zangarmarsh" },
                { itemId = 29328, name = "Consortium Prince's Wrap", icon = "INV_Belt_13", quality = "rare", slot = "Waist", stats = "+22 Crit, +30 Spell, +20 Spell Pen", source = "Mana-Tombs Quest", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29345, name = "Haramad's Leg Wraps", icon = "INV_Pants_Cloth_15", quality = "rare", slot = "Legs", stats = "+29 Spirit, +24 Heal, +8 Spell, +11 mp5, 3 sockets", source = "Undercutting the Competition", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
        ["66-67"] = {
            dungeons = {
                { itemId = 27431, name = "Time-Shifted Dagger", icon = "INV_Weapon_ShortBlade_42", quality = "rare", slot = "Dagger", stats = "+15 Int, +15 Sta, +13 Crit, +85 Spell", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Epoch Hunter" },
                { itemId = 27418, name = "Stormreaver Shadow-Kilt", icon = "INV_Pants_Cloth_17", quality = "rare", slot = "Legs", stats = "+26 Int, +19 Sta, +14 Spirit, +25 Crit, +30 Spell", source = "Old Hillsbrad", sourceType = "dungeon", boss = "Lieutenant Drake" },
                -- Note: Collar of Command removed - it's primarily a healer item (+66 Heal focus)
            },
            quests = {
                { itemId = 29317, name = "Tempest's Touch", icon = "INV_Gauntlets_17", quality = "rare", slot = "Hands", stats = "+20 Int, +10 Sta, +6 Spirit, +27 Spell, +10 Spell Pen, 2 sockets", source = "Return to Andormu", sourceType = "quest", zone = "Tanaris" },
                { itemId = 29333, name = "Torc of the Sethekk Prophet", icon = "INV_Jewelry_Necklace_24", quality = "rare", slot = "Neck", stats = "+18 Int, +21 Crit, +19 Spell, +19 Heal", source = "Brother Against Brother", sourceType = "quest", zone = "Terokkar Forest" },
                { itemId = 29330, name = "The Saga of Terokk", icon = "INV_Offhand_Stratholme_A_02", quality = "rare", slot = "Off-hand", stats = "+23 Int, +28 Spell", source = "Terokk's Legacy", sourceType = "quest", zone = "Terokkar Forest" },
            },
        },
    },
}

-- Helper function to get level range key from player level
function C:GetLevelRangeKey(level)
    if level >= 68 then return nil end -- Use endgame system
    if level >= 66 then return "66-67" end
    if level >= 63 then return "63-65" end
    if level >= 60 then return "60-62" end
    return nil -- Below 60, not in Outland content
end

-- Helper function to get leveling gear for a role and level
function C:GetLevelingGear(role, level)
    local rangeKey = self:GetLevelRangeKey(level)
    if not rangeKey then return nil end

    local roleData = self.LEVELING_GEAR_MATRIX[role]
    if not roleData then return nil end

    return roleData[rangeKey]
end

-- Helper function to get recommended dungeons for a level
function C:GetRecommendedDungeons(level)
    local rangeKey = self:GetLevelRangeKey(level)
    if not rangeKey then return nil end

    return self.LEVELING_DUNGEONS[rangeKey]
end

--============================================================
-- SOCIAL SECTION THEMES (TBC Visual Enhancement)
--============================================================
C.SOCIAL_SECTION_THEMES = {
    activity_feed = {
        icon = "Interface\\Icons\\Spell_Fire_FelFire",           -- Green fel fire
        borderColor = "ARCANE_PURPLE",
        glowColor = "FEL_GREEN",
        title = "COMMUNITY FEED",
        titleColor = "FEL_GREEN",
    },
    companions = {
        icon = "Interface\\Icons\\Spell_Nature_EyeOfTheStorm",   -- Arcane eye
        borderColor = "SKY_BLUE",
        glowColor = nil,
        title = "COMPANIONS",
        titleColor = "GOLD_BRIGHT",
    },
    lf_rp = {
        icon = "Interface\\Icons\\Spell_Holy_SurgeOfLight",      -- Radiant light
        borderColor = { 1, 0.2, 0.8 },                           -- Hot pink
        glowColor = "GOLD_BRIGHT",
        title = "LOOKING FOR RP",
        titleColor = nil,                                         -- Uses hot pink inline
    },
    fellow_travelers = {
        icon = "Interface\\Icons\\INV_Misc_Eye_01",              -- Demon eye
        borderColor = "FEL_GREEN",
        glowColor = nil,
        title = "FELLOW TRAVELERS",
        titleColor = "FEL_GREEN",
    },
}

-- Corner rune texture for decorative elements
C.CORNER_RUNE_TEXTURE = "Interface\\Buttons\\UI-ActionButton-Border"

--============================================================
-- SOCIAL TAB CONSTANTS
--============================================================

C.SOCIAL_TAB = {
    -- Tab bar
    TAB_WIDTH = 90,
    TAB_HEIGHT = 24,
    TAB_SPACING = 2,

    -- Status bar
    STATUS_BAR_HEIGHT = 36,
    RUMOR_INPUT_HEIGHT = 50,

    -- Feed
    FEED_ROW_HEIGHT = 48,
    FEED_VISIBLE_ROWS = 8,
    FEED_TIME_GROUPS = { "Now", "Earlier Today", "Yesterday", "This Week" },
    FEED_FILTERS = { "all", "status", "boss", "level", "game", "badge", "loot" },

    -- Travelers
    TRAVELER_ROW_HEIGHT = 44,
    TRAVELER_VISIBLE_ROWS = 8,
    QUICK_FILTERS = { "all", "online", "party", "lfrp" },

    -- Companions
    COMPANION_CARD_SIZE = 80,
    COMPANION_CARDS_PER_ROW = 4,
    COMPANION_SECTIONS = { "Online Now", "Away", "Offline" },

    -- Thresholds
    ONLINE_THRESHOLD = 300,   -- 5 minutes
    AWAY_THRESHOLD = 900,     -- 15 minutes

    -- Share prompts
    SHARE_PROMPT_EXPIRE = 300,
    SHARE_PROMPT_DELAY = 3,
    SHARE_PROMPT_WIDTH = 350,
    SHARE_PROMPT_HEIGHT = 280,

    -- Loot
    LOOT_MIN_QUALITY = 4,           -- Epic
    LOOT_COMMENT_MAX = 100,
}

--============================================================
-- FEED POST TYPES (IC Post vs Anonymous Rumor)
--============================================================

-- Post types for the Activity Feed
C.FEED_POST_TYPES = {
    IC_POST = {
        id = "IC",
        wireCode = "IC",
        label = "In Character",
        description = "Post as your character - your name and title will be shown",
        icon = "Interface\\Icons\\Spell_Holy_MindVision",
        borderColor = { 0.2, 0.8, 0.2 },  -- Fel green
        textColor = { 1.0, 0.84, 0 },      -- Gold for name
        -- Attribution function returns formatted name
        -- player: character name, title: optional title from badges
        formatAttribution = function(player, title, isOwnPost)
            if title and title ~= "" then
                return string.format("|cFFFFD700%s|r |cFF808080<%s>|r", player, title)
            end
            return string.format("|cFFFFD700%s|r", player)
        end,
    },
    ANON_RUMOR = {
        id = "ANON",
        wireCode = "ANON",
        label = "Tavern Rumor",
        description = "Post anonymously - 'A patron whispers...'",
        icon = "Interface\\Icons\\INV_Scroll_01",
        borderColor = { 0.61, 0.19, 1.0 },  -- Arcane purple
        textColor = { 0.7, 0.7, 0.7 },       -- Grey for anonymous
        -- Attribution function - isOwnPost lets you see your own posts
        formatAttribution = function(player, title, isOwnPost)
            if isOwnPost then
                return "|cFF9B30FFYou whispered|r"
            end
            return "|cFF808080A patron whispers|r"
        end,
    },
}

-- Helper to get post type by wire code
function C:GetPostTypeByCode(wireCode)
    for _, postType in pairs(self.FEED_POST_TYPES) do
        if postType.wireCode == wireCode then
            return postType
        end
    end
    return nil
end

-- Feed activity icons (keyed by wire codes from ActivityFeed.lua ACTIVITY table)
C.FEED_ACTIVITY_ICONS = {
    -- Wire codes match ActivityFeed.lua ACTIVITY values
    STA = "Interface\\Icons\\Spell_Holy_MindVision",      -- STATUS
    BOSS = "Interface\\Icons\\Achievement_Boss_Gruul",    -- BOSS
    LVL = "Interface\\Icons\\Spell_Holy_SurgeOfLight",    -- LEVEL
    GAME = "Interface\\Icons\\INV_Misc_Dice_02",          -- GAME
    BADGE = "Interface\\Icons\\Achievement_General",       -- BADGE
    LOOT = "Interface\\Icons\\INV_Misc_Bag_10",           -- LOOT
    ROM = "Interface\\Icons\\INV_ValentinesCard02",       -- ROMANCE
    MUG = "Interface\\Icons\\INV_Drink_04",               -- MUG
    -- New post types (Phase 50)
    IC = "Interface\\Icons\\Spell_Holy_MindVision",       -- IC_POST
    ANON = "Interface\\Icons\\INV_Scroll_01",             -- ANON
    -- Legacy RUMOR type
    RUM = "Interface\\Icons\\INV_Letter_15",              -- RUMOR (legacy)
}

-- Feed activity border colors (keyed by wire codes from ActivityFeed.lua ACTIVITY table)
C.FEED_ACTIVITY_BORDERS = {
    -- Wire codes match ActivityFeed.lua ACTIVITY values
    STA = { 0.5, 0.5, 0.5 },         -- STATUS: Grey (informational)
    BOSS = { 0.8, 0.2, 0.1 },        -- BOSS: Hellfire red
    LVL = { 0.2, 0.8, 0.2 },         -- LEVEL: Fel green
    GAME = { 0.61, 0.19, 1.0 },      -- GAME: Arcane purple
    BADGE = { 1.0, 0.84, 0 },        -- BADGE: Gold
    LOOT = { 0.64, 0.21, 0.93 },     -- LOOT: Epic purple
    ROM = { 1.0, 0.08, 0.58 },       -- ROMANCE: Deep pink
    MUG = { 1.0, 0.84, 0 },          -- MUG: Gold
    -- New post types (Phase 50)
    IC = { 0.2, 0.8, 0.2 },          -- IC_POST: Fel green
    ANON = { 0.61, 0.19, 1.0 },      -- ANON: Arcane purple
    -- Legacy
    RUM = { 0.2, 0.8, 0.2 },         -- RUMOR: Treat as IC (green)
}

C.RELATIONSHIP_TYPES = {
    NONE = { id = "NONE", label = "--", color = "808080", icon = nil, priority = 99 },
    ALLY = { id = "ALLY", label = "Ally", color = "00FF00", icon = "Achievement_Reputation_01", priority = 1 },
    FRIEND = { id = "FRIEND", label = "Friend", color = "00BFFF", icon = "INV_ValentinesCandy", priority = 2 },
    RIVAL = { id = "RIVAL", label = "Rival", color = "FF6600", icon = "Ability_DualWield", priority = 3 },
    MENTOR = { id = "MENTOR", label = "Mentor", color = "FFD700", icon = "Spell_Holy_AuraOfLight", priority = 4 },
    STUDENT = { id = "STUDENT", label = "Student", color = "9370DB", icon = "INV_Misc_Book_09", priority = 5 },
    FAMILY = { id = "FAMILY", label = "Family", color = "FF69B4", icon = "Spell_Holy_PrayerOfHealing", priority = 6 },
    ENEMY = { id = "ENEMY", label = "Enemy", color = "FF0000", icon = "Ability_Warrior_Rampage", priority = 7 },
}

C.SHARE_PROMPT_TYPES = {
    LOOT = { id = "LOOT", icon = "INV_Misc_Bag_10", label = "Loot Received", settingKey = "promptForLoot" },
    FIRST_KILL = { id = "FIRST_KILL", icon = "Achievement_Boss_Gruul", label = "First Boss Kill", settingKey = "promptForFirstKills" },
    ATTUNEMENT = { id = "ATTUNEMENT", icon = "INV_Misc_Key_03", label = "Attunement Complete", settingKey = "promptForAttunements" },
    GAME_WIN = { id = "GAME_WIN", icon = "INV_Misc_Dice_02", label = "Game Victory", settingKey = "promptForGameWins" },
}

C.RP_STATUS = {
    IC = { id = "IC", label = "In Character", color = "00FF00", icon = "Spell_Holy_MindVision" },
    OOC = { id = "OOC", label = "Out of Character", color = "808080", icon = "Spell_Nature_Sleep" },
    LF_RP = { id = "LF_RP", label = "Looking for RP", color = "FF33CC", icon = "INV_ValentinesCandy" },
}

--[[
    Romance System ("Azeroth Relationship Status")
    Public, exclusive one-partner romantic relationship system
    Like Facebook relationship status for WoW RP players
]]
C.ROMANCE_STATUS = {
    SINGLE = {
        id = "SINGLE",
        label = "Single",
        color = "808080",
        icon = "INV_ValentinesCard01",
        emoji = "",
    },
    PROPOSED = {
        id = "PROPOSED",
        label = "It's Pending...",
        color = "FF69B4",
        icon = "INV_ValentinesCandy",
        emoji = "<3",
    },
    DATING = {
        id = "DATING",
        label = "In a Relationship",
        color = "FF1493",
        icon = "INV_ValentinesCard02",
        emoji = "<3",
    },
}

-- Romance network message types (via WHISPER - not throttled)
C.ROMANCE_MSG = {
    REQUEST = "ROM_REQ",    -- Send romantic interest
    ACCEPT = "ROM_ACC",     -- Accept proposal
    DECLINE = "ROM_DEC",    -- Decline proposal
    BREAKUP = "ROM_BRK",    -- Break up
    SYNC = "ROM_SYN",       -- Sync status (broadcast)
}

-- Romance timing constants
C.ROMANCE_TIMINGS = {
    REJECTION_COOLDOWN = 86400,     -- 24 hours before re-proposing to same person
    REQUEST_EXPIRY = 604800,        -- 7 days for pending requests to expire
    BREAKUP_REASONS = {
        MUTUAL = "mutual",
        GREW_APART = "grew_apart",
        FOUND_ANOTHER = "found_another",
        ITS_NOT_YOU = "its_not_you",
    },
}

-- Breakup reason display text (humorous)
C.BREAKUP_REASON_TEXT = {
    mutual = "It was mutual.",
    grew_apart = "They grew apart.",
    found_another = "Someone else caught their eye.",
    its_not_you = "It's not you, it's me.",
}

--[[
    Default Social Data Structure
    Used by Core.lua for migration and initialization
    All social.ui access should go through HopeAddon:GetSocialUI()
]]
C.SOCIAL_DATA_DEFAULTS = {
    -- UI State (persisted across sessions)
    ui = {
        activeTab = "travelers",
        feed = {
            filter = "all",
            lastSeenTimestamp = 0,
        },
        travelers = {
            quickFilter = "all",
            searchText = "",
            sortOption = "last_seen",
        },
        companions = {},
    },

    -- Activity Feed
    feed = {},
    lastSeen = {},

    -- Settings
    settings = {
        showBoss = true,
        showLevel = true,
        showGame = true,
        showBadge = true,
        showStatus = true,
        showLoot = true,
        promptForLoot = true,
    },

    -- Rumors (Phase 2)
    myRumors = {},
    mugsGiven = {},

    -- Companions
    companions = {
        list = {},
        outgoing = {},
        incoming = {},
    },

    -- Share Prompts
    sharePrompts = {
        promptForLoot = true,
        promptForFirstKills = true,
        promptForAttunements = true,
        promptForGameWins = false,
    },

    -- Relationship Types
    relationshipTypes = {},

    -- Romance System ("Azeroth Relationship Status")
    romance = {
        status = "SINGLE",          -- SINGLE, PROPOSED, DATING
        partner = nil,              -- Partner name when DATING
        since = nil,                -- Unix timestamp of relationship start
        pendingOutgoing = nil,      -- { to = "name", timestamp = time() }
        pendingIncoming = {},       -- { [senderName] = { timestamp, class, level } }
        cooldowns = {},             -- { [name] = timestamp } 24h rejection cooldown
        history = {},               -- Array of past relationships for timeline
    },

    -- Toast Settings
    toasts = {
        enabled = true,
        CompanionOnline = true,
        CompanionNearby = true,
        CompanionRequest = true,
        MugReceived = true,
        CompanionLfrp = true,
        FellowDiscovered = true,
    },
}

--============================================================
-- ARMORY TAB CONSTANTS
--============================================================

-- Main container
C.ARMORY_CONTAINER = {
    WIDTH = "MATCH_PARENT",
    HEIGHT = "DYNAMIC",
    MIN_HEIGHT = 600,
    PADDING = 15,
    MARGIN_TOP = 0,
    MARGIN_BOTTOM = 20,
}

-- Phase bar (slim 35px bar replacing 50px tier bar)
C.ARMORY_PHASE_BAR = {
    HEIGHT = 35,
    WIDTH = "MATCH_PARENT",
    ANCHOR = "TOPLEFT",
    OFFSET_X = 0,
    OFFSET_Y = 0,
    PADDING_H = 12,
    PADDING_V = 5,
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.06, g = 0.06, b = 0.06, a = 0.95 },
    BORDER_COLOR = { r = 0.4, g = 0.35, b = 0.25, a = 1 },
    LABEL_TEXT = "PHASE",
    LABEL_WIDTH = 50,
    SPEC_DROPDOWN_RIGHT = -10,
}

-- Phase button (compact numbered buttons 1-5)
C.ARMORY_PHASE_BUTTON = {
    WIDTH = 32,
    HEIGHT = 24,
    GAP = 4,
    FIRST_OFFSET = 60,  -- After "PHASE" label
    FONT = "GameFontNormal",
    FONT_SIZE = 12,
    PHASES = {
        [1] = {
            label = "1",
            tooltip = "Phase 1: Karazhan Era",
            color = "FEL_GREEN",
            raids = { "Karazhan (10)", "Gruul's Lair (25)", "Magtheridon's Lair (25)" },
            gearSources = { "Raid Drops", "Heroic Dungeons", "Badge of Justice", "Reputation Rewards", "Crafted BoE" },
            recommendedILvl = "100-115",
        },
        [2] = {
            label = "2",
            tooltip = "Phase 2: Serpentshrine & Tempest Keep",
            color = "SKY_BLUE",
            raids = { "Serpentshrine Cavern (25)", "Tempest Keep: The Eye (25)" },
            gearSources = { "Raid Drops", "Heroic Badge Gear", "Nether Vortex Crafting" },
            recommendedILvl = "115-128",
        },
        [3] = {
            label = "3",
            tooltip = "Phase 3: Hyjal & Black Temple",
            color = "HELLFIRE_RED",
            raids = { "Hyjal Summit (25)", "Black Temple (25)" },
            gearSources = { "Raid Drops", "Hearts of Darkness Crafting" },
            recommendedILvl = "128-141",
        },
        [4] = {
            label = "4",
            tooltip = "Phase 4: Zul'Aman",
            color = "GOLD_BRIGHT",
            raids = { "Zul'Aman (10)" },
            gearSources = { "Raid Drops", "Bear Run Loot" },
            recommendedILvl = "128-138",
        },
        [5] = {
            label = "5",
            tooltip = "Phase 5: Sunwell Plateau",
            color = "LEGENDARY_ORANGE",
            raids = { "Sunwell Plateau (25)" },
            gearSources = { "Raid Drops", "Sunmote Crafting", "Isle of Quel'Danas" },
            recommendedILvl = "141-154",
        },
    },
    STATES = {
        active = { bgAlpha = 0.5, borderAlpha = 1.0, textAlpha = 1.0, showGlow = true },
        inactive = { bgAlpha = 0.15, borderAlpha = 0.4, textAlpha = 0.6, showGlow = false },
        hover = { bgAlpha = 0.35, borderAlpha = 0.8, textAlpha = 0.9, showGlow = false },
    },
}

-- Spec dropdown
C.ARMORY_SPEC_DROPDOWN = {
    WIDTH = 120,
    HEIGHT = 28,
    ANCHOR = "RIGHT",
    OFFSET_X = -10,
    OFFSET_Y = 0,
    MENU_WIDTH = 110,
}

-- Character View - Centered layout (replaces paperdoll + detail panel)
-- Full width container with model centered, slots symmetrically positioned
C.ARMORY_CHARACTER_VIEW = {
    WIDTH = "MATCH_PARENT",  -- Full container width
    HEIGHT = "FILL_REMAINING",  -- Fill space below phase bar and above footer
    COMPACT_HEIGHT = 380,    -- Compact height: 8 slots × 44px + weapons (54) + padding (10) = 380px
    ANCHOR = "TOPLEFT",
    OFFSET_X = 0,
    OFFSET_Y = -35,  -- Below phase bar (35px height)
    -- Layout zones (for reference)
    LEFT_COLUMN_WIDTH = 54,   -- 44px slot + 10px gap
    RIGHT_COLUMN_WIDTH = 54,
    MODEL_WIDTH = 180,        -- Centered between slot columns (compact: was 220)
    BOTTOM_ROW_HEIGHT = 54,   -- Weapons row (compact: was 60)
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    BG_COLOR = { r = 0.04, g = 0.04, b = 0.04, a = 0.3 },
    BORDER_COLOR = { r = 0.35, g = 0.3, b = 0.2, a = 1 },
}

-- Legacy alias for backwards compatibility
C.ARMORY_PAPERDOLL = C.ARMORY_CHARACTER_VIEW

-- Model frame - centered between slot columns (compact layout)
C.ARMORY_MODEL_FRAME = {
    WIDTH = 180,           -- Was 200 (10% narrower for compact layout)
    HEIGHT = 280,          -- Was 390 (28% shorter, still shows full body)
    ANCHOR = "TOP",
    OFFSET_X = 0,          -- Centered between left and right slot columns
    OFFSET_Y = -8,         -- Was -10
    DEFAULT_ROTATION = 0,
    ROTATION_SPEED = 0.01,
    DEFAULT_CAMERA = 0,
    BACKGROUND_COLOR = { r = 0.02, g = 0.02, b = 0.02, a = 1 },
    LIGHTING = {
        ambient = { r = 0.4, g = 0.4, b = 0.4 },
        diffuse = { r = 1.0, g = 0.95, b = 0.9 },
    },
}

-- Slots container - now spans full characterView for centered positioning
C.ARMORY_SLOTS_CONTAINER = {
    WIDTH = "MATCH_PARENT",  -- Full width of characterView
    HEIGHT = 420,  -- Full height including bottom weapons row
    ANCHOR = "TOP",
    OFFSET_X = 0,
    OFFSET_Y = 0,
    SLOT_SIZE = 44,
    SLOT_GAP = 6,
    COLUMN_GAP = 8,
}

-- Gear popup (floating popup near clicked slot) - Redesigned Phase 60
C.ARMORY_GEAR_POPUP = {
    -- Dimensions (expanded from 300x420)
    WIDTH = 480,
    MAX_HEIGHT = 520,
    MIN_HEIGHT = 280,

    -- Section heights
    HEADER_HEIGHT = 40,
    BIS_SECTION_HEIGHT = 100,      -- BiS showcase card
    FILTER_BAR_HEIGHT = 32,        -- Source filter buttons
    SCROLL_CONTENT_PADDING = 8,
    FOOTER_HEIGHT = 36,

    -- Item row styling
    ITEM_HEIGHT = 54,              -- Reduced from 64
    COMPACT_ITEM_HEIGHT = 44,      -- For dense lists
    ITEM_GAP = 4,                  -- Reduced from 6
    PADDING = 16,                  -- Increased from 12
    SECTION_GAP = 12,              -- Gap between grouped sections

    -- Limits
    MAX_ALTERNATIVES = 10,         -- Increased from 5

    -- Visual styling
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    BG_COLOR = { r = 0.05, g = 0.05, b = 0.05, a = 0.98 },
    BORDER_COLOR = { r = 0.8, g = 0.7, b = 0.2, a = 1 },

    -- Source type groupings for organized display
    SOURCE_GROUPS = {
        raid = {
            order = 1,
            label = "Raid Drops",
            color = "HELLFIRE_RED",
            icon = "Interface\\Icons\\INV_Helmet_06",
        },
        heroic = {
            order = 2,
            label = "Heroic Dungeon",
            color = "ARCANE_PURPLE",
            icon = "Interface\\Icons\\Spell_Holy_ChampionsBond",
        },
        dungeon = {
            order = 3,
            label = "Normal Dungeon",
            color = "SKY_BLUE",
            icon = "Interface\\Icons\\INV_Misc_Key_10",
        },
        crafted = {
            order = 4,
            label = "Crafted",
            color = "GOLD_BRIGHT",
            icon = "Interface\\Icons\\Trade_BlackSmithing",
        },
        badge = {
            order = 5,
            label = "Badge Vendor",
            color = "FEL_GREEN",
            icon = "Interface\\Icons\\Spell_Holy_ChampionsBond",
        },
        reputation = {
            order = 6,
            label = "Reputation",
            color = "GOLD_BRIGHT",
            icon = "Interface\\Icons\\INV_Misc_Note_02",
        },
        pvp = {
            order = 7,
            label = "PvP Rewards",
            color = "HELLFIRE_RED",
            icon = "Interface\\Icons\\INV_BannerPVP_01",
        },
        quest = {
            order = 8,
            label = "Quest Rewards",
            color = "GOLD_BRIGHT",
            icon = "Interface\\Icons\\INV_Misc_Note_01",
        },
        world = {
            order = 9,
            label = "World Drops",
            color = "FEL_GREEN",
            icon = "Interface\\Icons\\INV_Misc_Bag_10",
        },
    },

    -- Position offsets based on slot location (popup appears opposite side)
    POSITION_OFFSETS = {
        -- Left column slots: popup appears to the RIGHT
        head      = { side = "RIGHT", x = 10, y = 0 },
        neck      = { side = "RIGHT", x = 10, y = 0 },
        shoulders = { side = "RIGHT", x = 10, y = 0 },
        back      = { side = "RIGHT", x = 10, y = 0 },
        chest     = { side = "RIGHT", x = 10, y = 0 },
        shirt     = { side = "RIGHT", x = 10, y = 0 },
        tabard    = { side = "RIGHT", x = 10, y = 0 },
        wrist     = { side = "RIGHT", x = 10, y = 0 },
        -- Right column slots: popup appears to the LEFT
        hands     = { side = "LEFT", x = -10, y = 0 },
        waist     = { side = "LEFT", x = -10, y = 0 },
        legs      = { side = "LEFT", x = -10, y = 0 },
        feet      = { side = "LEFT", x = -10, y = 0 },
        ring1     = { side = "LEFT", x = -10, y = 0 },
        ring2     = { side = "LEFT", x = -10, y = 0 },
        trinket1  = { side = "LEFT", x = -10, y = 0 },
        trinket2  = { side = "LEFT", x = -10, y = 0 },
        -- Bottom row slots: popup appears ABOVE
        mainhand  = { side = "TOP", x = 0, y = 10 },
        offhand   = { side = "TOP", x = 0, y = 10 },
        ranged    = { side = "TOP", x = 0, y = 10 },
    },

    -- BiS card styling (featured item at top)
    BIS_CARD = {
        HEIGHT = 90,
        ICON_SIZE = 56,
        BORDER_COLOR = { r = 1, g = 0.84, b = 0 },      -- Gold
        GLOW_COLOR = { r = 1, g = 0.84, b = 0, a = 0.3 },
        NAME_FONT = "GameFontNormalLarge",
        STATS_FONT = "GameFontNormal",
    },

    -- Compact item row styling (for alternatives list)
    ITEM = {
        ICON_SIZE = 40,            -- Reduced from 44
        BIS_INDICATOR_SIZE = 16,   -- Reduced from 18
        BIS_COLOR = { r = 1, g = 0.84, b = 0 },  -- Gold star for BiS
        NAME_FONT = "GameFontNormal",
        SOURCE_FONT = "GameFontNormalSmall",
        ILEVEL_FONT = "GameFontNormalSmall",
        HOVER_BG = { r = 0.3, g = 0.3, b = 0.3, a = 0.3 },
    },

    -- Filter button styling
    FILTER = {
        BUTTON_HEIGHT = 24,
        BUTTON_PADDING = 8,
        ACTIVE_COLOR = { r = 0.3, g = 0.6, b = 0.3, a = 0.8 },
        INACTIVE_COLOR = { r = 0.2, g = 0.2, b = 0.2, a = 0.6 },
        ALL_LABEL = "All Sources",
    },

    -- Group header styling (collapsible sections)
    GROUP_HEADER = {
        HEIGHT = 28,
        FONT = "GameFontNormal",
        EXPAND_ICON = "Interface\\Buttons\\UI-PlusButton-UP",
        COLLAPSE_ICON = "Interface\\Buttons\\UI-MinusButton-UP",
        ICON_SIZE = 16,
    },
}

-- Slots to hide from Armory (cosmetic only, no BiS data)
C.ARMORY_HIDDEN_SLOTS = {
    shirt = true,
    tabard = true,
}

-- Slot button
C.ARMORY_SLOT_BUTTON = {
    SIZE = 44,
    ICON_SIZE = 36,
    ICON_INSET = 4,
    INDICATOR_SIZE = 16,
    INDICATOR_OFFSET = { x = 2, y = -2 },
    LABEL_HEIGHT = 12,
    LABEL_FONT = "GameFontNormalSmall",
    SLOTS = {
        -- Left column (armor)
        head      = { displayName = "HEAD",  slotId = 1 },
        neck      = { displayName = "NECK",  slotId = 2 },
        shoulders = { displayName = "SHLD",  slotId = 3 },
        back      = { displayName = "BACK",  slotId = 15 },
        chest     = { displayName = "CHEST", slotId = 5 },
        shirt     = { displayName = "SHIRT", slotId = 4 },
        tabard    = { displayName = "TABRD", slotId = 19 },
        wrist     = { displayName = "WRIST", slotId = 9 },
        -- Right column (accessories)
        hands     = { displayName = "HANDS", slotId = 10 },
        waist     = { displayName = "WAIST", slotId = 6 },
        legs      = { displayName = "LEGS",  slotId = 7 },
        feet      = { displayName = "FEET",  slotId = 8 },
        ring1     = { displayName = "RING",  slotId = 11 },
        ring2     = { displayName = "RING",  slotId = 12 },
        trinket1  = { displayName = "TRNK",  slotId = 13 },
        trinket2  = { displayName = "TRNK",  slotId = 14 },
        -- Bottom row (weapons)
        mainhand  = { displayName = "MH",    slotId = 16 },
        offhand   = { displayName = "OH",    slotId = 17 },
        ranged    = { displayName = "RNG",   slotId = 18 },
    },
    -- COMPACT Centered Character Screen Layout:
    -- LEFT column (6 slots): Head, Neck, Shoulders, Back, Chest, Wrist (shirt/tabard hidden)
    -- RIGHT column (8 slots): Hands, Waist, Legs, Feet, Ring1, Ring2, Trinket1, Trinket2
    -- BOTTOM row: MainHand, OffHand, Ranged (weapons anchored to model bottom, not container)
    -- 44px vertical spacing (compact), x = -130/+130 (tighter than before)
    POSITIONS = {
        -- LEFT column: 6 armor slots (shirt/tabard hidden via ARMORY_HIDDEN_SLOTS)
        -- x = -130 (moved in from -160 for tighter layout)
        -- 44px vertical spacing (was 50px)
        head      = { anchor = "TOP",  x = -130, y = -8 },
        neck      = { anchor = "TOP",  x = -130, y = -52 },
        shoulders = { anchor = "TOP",  x = -130, y = -96 },
        back      = { anchor = "TOP",  x = -130, y = -140 },
        chest     = { anchor = "TOP",  x = -130, y = -184 },
        wrist     = { anchor = "TOP",  x = -130, y = -228 },
        -- shirt/tabard still defined but hidden via ARMORY_HIDDEN_SLOTS
        shirt     = { anchor = "TOP",  x = -130, y = -272 },
        tabard    = { anchor = "TOP",  x = -130, y = -316 },

        -- RIGHT column: 8 accessory slots
        -- x = +130 (moved in from +160)
        hands     = { anchor = "TOP",  x = 130, y = -8 },
        waist     = { anchor = "TOP",  x = 130, y = -52 },
        legs      = { anchor = "TOP",  x = 130, y = -96 },
        feet      = { anchor = "TOP",  x = 130, y = -140 },
        ring1     = { anchor = "TOP",  x = 130, y = -184 },
        ring2     = { anchor = "TOP",  x = 130, y = -228 },
        trinket1  = { anchor = "TOP",  x = 130, y = -272 },
        trinket2  = { anchor = "TOP",  x = 130, y = -316 },

        -- BOTTOM row: Weapons anchor to MODEL_BOTTOM (special handling in Journal.lua)
        -- y = -10 means 10px below model bottom
        mainhand  = { anchor = "MODEL_BOTTOM", x = -54, y = -10 },
        offhand   = { anchor = "MODEL_BOTTOM", x = 0,   y = -10 },
        ranged    = { anchor = "MODEL_BOTTOM", x = 54,  y = -10 },
    },
    STATE_COLORS = {
        empty     = { border = "GREY",         indicator = nil },
        equipped  = { border = "ITEM_QUALITY", indicator = nil },
        bis       = { border = "GOLD_BRIGHT",  indicator = "GOLD_BRIGHT" },
        ok        = { border = "FEL_GREEN",    indicator = "FEL_GREEN" },
        minor     = { border = "FEL_GREEN",    indicator = "FEL_GREEN" },
        upgrade   = { border = "GOLD_BRIGHT",  indicator = "GOLD_BRIGHT" },
        major     = { border = "HELLFIRE_RED", indicator = "HELLFIRE_RED" },
        selected  = { border = "ARCANE_PURPLE",indicator = nil },
        wishlisted= { border = "EPIC_PURPLE",  indicator = "EPIC_PURPLE" },
    },
    INDICATOR_ICONS = {
        bis       = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "★" },
        ok        = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "✓" },
        minor     = { icon = "Interface\\BUTTONS\\UI-MicroStream-Green", symbol = "↑" },
        upgrade   = { icon = "Interface\\BUTTONS\\UI-MicroStream-Yellow", symbol = "↑↑" },
        major     = { icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew", symbol = "!!" },
        wishlisted= { icon = "Interface\\BUTTONS\\UI-GroupLoot-Coin-Up", symbol = "♥" },
        tier      = { icon = "Interface\\ICONS\\INV_Misc_Token_SoulTrader", symbol = "T" },
    },
}

-- Slot placeholder icons
C.ARMORY_SLOT_PLACEHOLDER_ICONS = {
    head      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head",
    neck      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck",
    shoulders = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder",
    back      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
    chest     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
    shirt     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shirt",
    tabard    = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Tabard",
    wrist     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists",
    hands     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands",
    waist     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist",
    legs      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs",
    feet      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet",
    ring1     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
    ring2     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
    trinket1  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
    trinket2  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
    mainhand  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand",
    offhand   = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand",
    ranged    = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged",
}

-- Slot info cards (44x44px cards showing iLvl + upgrade arrow)
C.ARMORY_INFO_CARD = {
    SIZE = 44,
    GAP = 2,  -- Gap between slot and card

    -- Upgrade thresholds (compared to average iLvl)
    THRESHOLD_GOOD = 5,   -- Above avg + 5 = green
    THRESHOLD_BAD = -5,   -- Below avg - 5 = red

    -- Arrow indicators
    ARROWS = {
        GOOD = { symbol = "↓", color = { r = 0.2, g = 1, b = 0.2 } },     -- Green (above avg)
        OKAY = { symbol = "→", color = { r = 1, g = 0.84, b = 0 } },      -- Gold (at avg)
        UPGRADE = { symbol = "↑", color = { r = 1, g = 0.2, b = 0.2 } },  -- Red (needs upgrade)
    },

    -- Visual style
    BACKDROP = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.04, g = 0.04, b = 0.04, a = 0.8 },
    BORDER_COLOR = { r = 0.6, g = 0.5, b = 0.2, a = 0.8 },
    HIGHLIGHT_COLOR = { r = 0.8, g = 0.7, b = 0.4, a = 1 },

    -- Card position offsets by slot (relative to slot button)
    -- LEFT column slots: cards extend LEFT (negative X)
    -- RIGHT column slots: cards extend RIGHT (positive X)
    -- WEAPON slots: cards extend DOWN (negative Y)
    POSITIONS = {
        -- LEFT column: extend LEFT (card RIGHT edge anchors to slot LEFT edge)
        head      = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },
        neck      = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },
        shoulders = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },
        back      = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },
        chest     = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },
        wrist     = { anchor = "RIGHT", relAnchor = "LEFT", x = -2, y = 0 },

        -- RIGHT column: extend RIGHT (card LEFT edge anchors to slot RIGHT edge)
        hands     = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        waist     = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        legs      = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        feet      = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        ring1     = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        ring2     = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        trinket1  = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },
        trinket2  = { anchor = "LEFT", relAnchor = "RIGHT", x = 2, y = 0 },

        -- Weapons: extend DOWN (card TOP anchors to slot BOTTOM)
        mainhand  = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -2 },
        offhand   = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -2 },
        ranged    = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -2 },
    },
}

-- NOTE: Detail panel constants removed - replaced by ARMORY_GEAR_POPUP
-- The gear popup now handles showing BiS and alternatives when clicking slots

-- Main footer
C.ARMORY_FOOTER = {
    HEIGHT = 35,
    ANCHOR = "BOTTOMLEFT",
    OFFSET_Y = 0,
    PADDING_H = 15,
    STAT_GAP = 30,
    STATS = {
        { id = "avgIlvl",       label = "Avg iLvl:",    format = "%d" },
        { id = "upgradesAvail", label = "Upgrades:",    format = "%d slots" },
        { id = "wishlisted",    label = "Wishlisted:",  format = "%d items" },
    },
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.06, g = 0.06, b = 0.06, a = 0.95 },
    BORDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
    LABEL_COLOR = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
    VALUE_COLOR = { r = 1, g = 0.84, b = 0, a = 1 },
    -- Action buttons (BIS on LEFT, RESET on RIGHT)
    BUTTONS = {
        GAP = 8,
        LEFT_MARGIN = 12,   -- For BIS button on left
        RIGHT_MARGIN = 12,  -- For RESET button on right

        BIS = {
            label = "BIS",
            width = 60,           -- Was 45, larger and more prominent
            height = 26,          -- Was 22
            position = "LEFT",    -- Position hint for Journal.lua
            tooltip = "Preview all Best in Slot items for this phase on your character model",
            borderColor = { r = 1, g = 0.84, b = 0, a = 1 },  -- Gold
            bgColor = { r = 0.2, g = 0.16, b = 0.05, a = 0.95 },
            hoverColor = { r = 0.3, g = 0.24, b = 0.08, a = 1 },
        },
        RESET = {
            label = "RESET",
            width = 60,           -- Was 55
            height = 26,          -- Was 22
            position = "RIGHT",   -- Position hint for Journal.lua
            tooltip = "Reset model to your current equipped gear",
            borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 },  -- Grey
            bgColor = { r = 0.12, g = 0.12, b = 0.12, a = 0.95 },
            hoverColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 },
        },
    },
}

-- Source type colors for Master List popup items
C.ARMORY_SOURCE_COLORS = {
    raid       = { r = 0.9, g = 0.2, b = 0.1 },   -- HELLFIRE_RED
    heroic     = { r = 0.61, g = 0.19, b = 1.0 }, -- ARCANE_PURPLE
    dungeon    = { r = 0.3, g = 0.7, b = 1.0 },   -- SKY_BLUE
    badge      = { r = 1, g = 0.84, b = 0 },      -- GOLD_BRIGHT
    crafted    = { r = 0.2, g = 0.8, b = 0.2 },   -- FEL_GREEN
    reputation = { r = 0.4, g = 0.8, b = 0.4 },   -- CENARION_GREEN
    pvp        = { r = 0.6, g = 0.6, b = 0.6 },   -- TITAN_GREY
    quest      = { r = 1, g = 1, b = 0 },         -- QUEST_YELLOW
    world      = { r = 0.12, g = 1, b = 0 },      -- UNCOMMON_GREEN
}

-- Upgrade card (pooled)
C.ARMORY_UPGRADE_CARD = {
    HEIGHT = 75,
    WIDTH = "MATCH_PARENT",
    PADDING = 10,
    ICON_SIZE = 44,
    ICON_OFFSET = { x = 10, y = -15 },
    RANK_OFFSET = { x = 10, y = -8 },
    NAME_OFFSET = { x = 64, y = -12 },
    ILEVEL_OFFSET = { x = 64, y = -28 },
    STATS_OFFSET = { x = 64, y = -44 },
    SOURCE_OFFSET = { x = 64, y = -60 },
    UPGRADE_BADGE_OFFSET = { x = -10, y = -12 },
    WISHLIST_OFFSET = { x = -10, y = -45 },
    RANK_BADGE_WIDTH = 45,
    RANK_BADGE_HEIGHT = 18,
    RANK_COLORS = {
        BEST = { bg = { r = 1, g = 0.84, b = 0 }, text = { r = 0.1, g = 0.1, b = 0.1 } },
        ALT  = { bg = { r = 0.5, g = 0.5, b = 0.5 }, text = { r = 1, g = 1, b = 1 } },
    },
    UPGRADE_BADGE_WIDTH = 50,
    UPGRADE_BADGE_HEIGHT = 20,
    WISHLIST_SIZE = 24,
    WISHLIST_ICON_ON = "Interface\\ICONS\\INV_ValentinesCard02",
    WISHLIST_ICON_OFF = "Interface\\ICONS\\INV_ValentinesCard01",
    BACKDROP = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
    BG_COLOR_BEST = { r = 0.15, g = 0.12, b = 0.05, a = 0.9 },
    BORDER_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 1 },
    BORDER_COLOR_BEST = { r = 1, g = 0.84, b = 0, a = 1 },
}

-- Section header (pooled)
C.ARMORY_SECTION_HEADER = {
    HEIGHT = 28,
    WIDTH = "MATCH_PARENT",
    PADDING_H = 10,
    ARROW_SIZE = 16,
    ICON_SIZE = 20,
    GAP = 8,
    ARROW_EXPANDED = "Interface\\Buttons\\UI-MinusButton-Up",
    ARROW_COLLAPSED = "Interface\\Buttons\\UI-PlusButton-Up",
    FONT = "GameFontNormal",
    COUNT_FONT = "GameFontNormalSmall",
    COUNT_COLOR = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
    BACKDROP = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = nil,
    },
    BG_ALPHA = 0.2,
}

-- Margins system
C.ARMORY_MARGINS = {
    CONTAINER_PADDING = 15,
    SECTION_SPACING = 20,
    SUBSECTION_SPACING = 12,
    COMPONENT_GAP_SM = 4,
    COMPONENT_GAP_MD = 8,
    COMPONENT_GAP_LG = 16,
    CARD_PADDING = 12,
    CARD_MARGIN = 8,
    CARD_BORDER = 2,
    HEADER_MARGIN_TOP = 16,
    HEADER_MARGIN_BOTTOM = 8,
    BUTTON_PADDING_H = 12,
    BUTTON_PADDING_V = 6,
    BUTTON_SPACING = 8,
    TIER_BAR_PADDING = 10,
    TIER_BUTTON_GAP = 12,
    DETAIL_HEADER_HEIGHT = 40,
    DETAIL_CONTENT_PADDING = 15,
    DETAIL_SCROLL_WIDTH = 16,
    FOOTER_PADDING = 10,
}

-- WoW Assets for Armory
C.ARMORY_ASSETS = {
    BACKGROUNDS = {
        DARK_PANEL = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        TOOLTIP = "Interface\\Tooltips\\UI-Tooltip-Background",
        PARCHMENT = "Interface\\QUESTFRAME\\QuestBG",
    },
    BORDERS = {
        TOOLTIP = "Interface\\Tooltips\\UI-Tooltip-Border",
        GOLD = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    },
    GLOWS = {
        ACTION_BUTTON = "Interface\\BUTTONS\\UI-ActionButton-Border",
        GLOW = "Interface\\BUTTONS\\CheckButtonGlow",
    },
    QUALITY_FRAMES = {
        UNCOMMON = "Interface\\Common\\WhiteIconFrame",
        RARE = "Interface\\Common\\WhiteIconFrame",
        EPIC = "Interface\\Common\\WhiteIconFrame",
        LEGENDARY = "Interface\\Common\\WhiteIconFrame",
    },
    SOURCE_ICONS = {
        raid = "Interface\\ICONS\\INV_Misc_Head_Dragon_01",
        heroic = "Interface\\ICONS\\Spell_Holy_SealOfBlood",
        badge = "Interface\\ICONS\\Spell_Holy_ChampionsBond",
        rep = "Interface\\ICONS\\INV_Misc_Token_argentdawn",
        crafted = "Interface\\ICONS\\Trade_BlackSmithing",
    },
}

--============================================================
-- ARMORY TAB: GEAR DATABASE (T4 BiS Recommendations)
--============================================================

-- Phase definitions with metadata (Phase-based, not Tier-based)
C.ARMORY_PHASES = {
    [1] = {
        name = "Phase 1",
        content = "Karazhan, Gruul, Magtheridon, Heroics, Badge Gear, Reputation",
        color = "ARCANE_PURPLE",  -- Karazhan purple theme
        raids = { "karazhan", "gruul", "magtheridon" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    [2] = {
        name = "Phase 2",
        content = "Serpentshrine Cavern, Tempest Keep",
        color = "SKY_BLUE",  -- Serpentshrine blue theme
        raids = { "ssc", "tk" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    [3] = {
        name = "Phase 3",
        content = "Hyjal Summit, Black Temple",
        color = "FEL_GREEN",  -- TBC green theme
        raids = { "hyjal", "bt" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    [4] = {
        name = "Phase 4",
        content = "Zul'Aman",
        color = "HELLFIRE_RED",  -- Zul'Aman troll/blood red theme
        raids = { "za" },
        sources = { "raid", "badge" },
    },
    [5] = {
        name = "Phase 5",
        content = "Sunwell Plateau",
        color = "GOLD_BRIGHT",  -- Sunwell golden theme
        raids = { "sunwell" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
}

-- Legacy alias for backwards compatibility
C.ARMORY_TIERS = C.ARMORY_PHASES

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

-- Equipment slot definitions for UI layout
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
-- Structure: [phase][role][slot] = { best = {...}, alternatives = {...} }
C.ARMORY_GEAR_DATABASE = {
    -------------------------------------------------
    -- PHASE 1: Karazhan, Gruul, Magtheridon, Heroics
    -------------------------------------------------
    [1] = {
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
                best = { itemId = 30724, name = "Barrel-Blade Longrifle", icon = "INV_Weapon_Rifle_23", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Doomwalker", sourceType = "world", weaponType = "gun" },
                alternatives = {
                    { itemId = 29115, name = "Consortium Blaster", icon = "INV_Weapon_Rifle_22", quality = "rare", iLvl = 105, stats = "+Sta", source = "Consortium Exalted", sourceType = "rep", repFaction = "The Consortium", repStanding = "Exalted", weaponType = "gun" },
                    -- Paladin/Druid alternatives (libram/idol)
                    { itemId = 28296, name = "Libram of Repentance", icon = "INV_Relics_LibramofGrace", quality = "rare", iLvl = 100, stats = "+Block Value", source = "Badge Vendor", sourceType = "badge", badgeCost = 15, weaponType = "libram" },
                    { itemId = 28064, name = "Idol of Terror", icon = "INV_Relics_IdolofFerocity", quality = "epic", iLvl = 115, stats = "+Agility proc", source = "Heroic Mana-Tombs", sourceType = "heroic", weaponType = "idol" },
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
                    { itemId = 27525, name = "Jeweled Boots of Sanctification", icon = "INV_Boots_Cloth_11", quality = "rare", iLvl = 112, stats = "+25 Int, +22 Sta, +29 Spell, +6 mp5", source = "Warbringer O'mrogg", sourceType = "dungeon" },
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
                best = { itemId = 28592, name = "Libram of Souls Redeemed", icon = "INV_Relics_LibramofHope", quality = "epic", iLvl = 115, stats = "+Healing to Flash of Light", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan", weaponType = "libram" },
                alternatives = {
                    { itemId = 28296, name = "Libram of Mending", icon = "INV_Relics_LibramofGrace", quality = "rare", iLvl = 100, stats = "+Healing", source = "Badge Vendor", sourceType = "badge", badgeCost = 15, weaponType = "libram" },
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
                best = { itemId = 28772, name = "Sunfury Bow of the Phoenix", icon = "INV_Weapon_Bow_26", quality = "epic", iLvl = 115, stats = "+Agi, +Crit", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan", weaponType = "bow" },
                alternatives = {
                    { itemId = 29151, name = "Veteran's Musket", icon = "INV_Weapon_Rifle_24", quality = "rare", iLvl = 100, stats = "+Agi", source = "Honor Hold Exalted", sourceType = "rep", repFaction = "Honor Hold", repStanding = "Exalted", weaponType = "gun" },
                    { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_25", quality = "rare", iLvl = 100, stats = "+Agi", source = "Thrallmar Exalted", sourceType = "rep", repFaction = "Thrallmar", repStanding = "Exalted", weaponType = "bow" },
                    -- Paladin alternative (libram)
                    { itemId = 23203, name = "Libram of Avengement", icon = "INV_Relics_LibramofTruth", quality = "rare", iLvl = 65, stats = "+Crit Rating", source = "Cenarion Hold Rep", sourceType = "rep", repFaction = "Cenarion Circle", repStanding = "Revered", weaponType = "libram" },
                    -- Druid alternative (idol)
                    { itemId = 28064, name = "Idol of the Wild", icon = "INV_Relics_IdolofFerocity", quality = "epic", iLvl = 115, stats = "+AP proc", source = "Heroic Mana-Tombs", sourceType = "heroic", weaponType = "idol" },
                    -- Shaman alternative (totem)
                    { itemId = 27947, name = "Totem of the Astral Winds", icon = "INV_Relics_Totem04", quality = "rare", iLvl = 115, stats = "+AP", source = "Anzu", sourceType = "heroic", sourceDetail = "Heroic Sethekk Halls", weaponType = "totem" },
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
                best = { itemId = 28772, name = "Sunfury Bow of the Phoenix", icon = "INV_Weapon_Bow_26", quality = "epic", iLvl = 115, stats = "+High DPS, +Agi", source = "Prince Malchezaar", sourceType = "raid", sourceDetail = "Karazhan", weaponType = "bow" },
                alternatives = {
                    { itemId = 30724, name = "Barrel-Blade Longrifle", icon = "INV_Weapon_Rifle_23", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Doomwalker", sourceType = "world", weaponType = "gun" },
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
                best = { itemId = 28783, name = "Eredar Wand of Obliteration", icon = "INV_Wand_22", quality = "epic", iLvl = 120, stats = "+15 Sta, +12 Spell Dmg", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair", weaponType = "wand" },
                alternatives = {
                    { itemId = 28673, name = "Tirisfal Wand of Ascendancy", icon = "INV_Wand_21", quality = "epic", iLvl = 115, stats = "+12 Sta, +10 Spell Dmg, +8 Hit", source = "Shade of Aran", sourceType = "raid", sourceDetail = "Karazhan", weaponType = "wand" },
                },
            },
        },
    },

    -- Phase 2, 3, 5 placeholders for future expansion
    [2] = {},
    [3] = {},
    [5] = {},
}

-- Helper function to get gear for a slot/role/phase
function C:GetArmoryGear(phase, role, slot)
    if not C.ARMORY_GEAR_DATABASE[phase] then return nil end
    if not C.ARMORY_GEAR_DATABASE[phase][role] then return nil end
    return C.ARMORY_GEAR_DATABASE[phase][role][slot]
end

-- Helper function to get all slots for a role/phase
function C:GetArmorySlots(phase, role)
    if not C.ARMORY_GEAR_DATABASE[phase] then return {} end
    if not C.ARMORY_GEAR_DATABASE[phase][role] then return {} end
    return C.ARMORY_GEAR_DATABASE[phase][role]
end

-- Get phase metadata
function C:GetArmoryPhase(phase)
    return C.ARMORY_PHASES[phase]
end

-- Check if phase has gear data
function C:HasArmoryPhaseData(phase)
    local data = C.ARMORY_GEAR_DATABASE[phase]
    if not data then return false end
    -- Check if any role has data
    for role, slots in pairs(data) do
        if next(slots) then return true end
    end
    return false
end

-- Class weapon restrictions for Armory filtering
-- Maps each class to the weapon types they can equip
C.CLASS_WEAPON_ALLOWED = {
    WARRIOR = { "sword", "axe", "mace", "polearm", "staff", "dagger", "fist", "gun", "bow", "crossbow", "thrown" },
    PALADIN = { "sword", "axe", "mace", "polearm", "libram" },
    HUNTER = { "sword", "axe", "polearm", "staff", "dagger", "fist", "gun", "bow", "crossbow" },
    ROGUE = { "sword", "mace", "dagger", "fist", "gun", "bow", "crossbow", "thrown" },
    PRIEST = { "mace", "staff", "dagger", "wand" },
    SHAMAN = { "axe", "mace", "staff", "dagger", "fist", "totem" },
    MAGE = { "sword", "staff", "dagger", "wand" },
    WARLOCK = { "sword", "staff", "dagger", "wand" },
    DRUID = { "mace", "polearm", "staff", "dagger", "fist", "idol" },
}

-- Helper to check if a class can use a weapon type
function C:CanClassUseWeapon(classToken, weaponType)
    local allowed = C.CLASS_WEAPON_ALLOWED[classToken]
    if not allowed then return true end -- Unknown class, allow
    if not weaponType then return true end -- No weapon type specified, allow
    for _, wtype in ipairs(allowed) do
        if wtype == weaponType then
            return true
        end
    end
    return false
end

-- Build the boss name lookup table now that all boss data is defined
C:BuildBossNameLookup()
