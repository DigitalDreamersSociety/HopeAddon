--[[
    HopeAddon Constants
    All static data: milestones, zones, raids, quests
]]

HopeAddon = HopeAddon or {}
HopeAddon.Constants = HopeAddon.Constants or {}
local C = HopeAddon.Constants

--============================================================
-- JOURNAL SETTINGS (Issue #71.6)
--============================================================
C.MAX_JOURNAL_ENTRIES = 1000  -- Maximum entries before pruning oldest

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
    -- Test Dungeon (Stockades)
    ["Stockades"] = {
        key = "stockades",
        zone = "Stormwind City",
        finalBoss = "Bazil Thredd",
        finalBossNPC = 1716,
        icon = "INV_Misc_Key_10",
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
-- PREREQUISITE ICONS AND STATUS COLORS
--============================================================
C.PREREQUISITE_ICONS = {
    key = "INV_Misc_Key_10",
    reputation = "Achievement_Reputation_01",
    dungeon = "INV_Misc_Rune_07",
    quest = "INV_Misc_Note_01",
    item = "INV_Misc_Bag_10",
    default = "INV_Misc_QuestionMark",
}

C.PREREQUISITE_STATUS_COLORS = {
    completed = { bg = { 0.1, 0.3, 0.1, 0.8 }, border = "FEL_GREEN" },
    progress = { bg = { 0.3, 0.25, 0.1, 0.8 }, border = "GOLD_BRIGHT" },
    pending = { bg = { 0.15, 0.15, 0.15, 0.8 }, border = "SHADOW_GREY" },  -- Use SHADOW_GREY from HopeAddon.colors
}

--============================================================
-- PHASE BORDER COLORS (for attunement card theming)
--============================================================
C.PHASE_BORDER_COLORS = {
    [1] = { 0.50, 0.30, 0.70, 1.0 },  -- KARA_PURPLE (T4)
    [2] = { 0.20, 0.60, 0.90, 1.0 },  -- SSC_BLUE (T5)
    [3] = { 0.30, 0.80, 0.30, 1.0 },  -- BT_FEL (T6)
}

--============================================================
-- PREREQUISITE CARD DIMENSIONS
--============================================================
C.PREREQUISITE_CARD_HEIGHT = 42  -- Taller for better readability

--============================================================
-- ATTUNEMENT HEADER CARD DIMENSIONS
--============================================================
C.ATTUNEMENT_HEADER_CARD = {
    HEIGHT = 58,
    ICON_SIZE = 40,
    ICON_BORDER = 2,
    PADDING = 10,
    RAID_ICONS = {
        karazhan = "INV_Misc_Key_10",
        ssc = "INV_Misc_MonsterClaw_03",
        tk = "Spell_Arcane_PortalShattrath",
        hyjal = "Spell_Fire_Burnout",
        bt = "INV_Weapon_Glaive_01",
        cipher = "INV_Misc_Book_06",
    },
}

--============================================================
-- ATTUNEMENT PHASE HEADER STYLING
--============================================================
C.ATTUNEMENT_PHASE_HEADER = {
    HEIGHT = 32,
    ICONS = {
        [1] = "INV_Misc_Key_10",           -- Karazhan key theme
        [2] = "INV_Misc_MonsterClaw_03",   -- SSC serpent theme
        [3] = "Spell_Shadow_Possession",   -- BT demon theme
    },
    DESCRIPTIONS = {
        [1] = "Tier 4 Content",
        [2] = "Tier 5 Content",
        [3] = "Tier 6 Content",
    },
    COLORS = {
        [1] = "KARA_PURPLE",
        [2] = "SSC_BLUE",
        [3] = "BT_FEL",
    },
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
            story = "Haunted tower needs heroes. Alturus is hiring - no resume required!",
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
            story = "This couldn't be a magical email? Nope. Hand-deliver to Cedric. In the mountains. Fun.",
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
            story = "Cedric says this is above his pay grade. Go find Khadgar in Shattrath - he's the key guy.",
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
            story = "Key fragment #1: Shadow Labyrinth. It's a maze full of shadows. Shocking, I know.",
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
            story = "Fragment #2: underwater in Steamvault. #3: space prison. Pack swim trunks AND a rocket.",
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
            story = "Key needs Medivh's blessing. He's dead. Solution? Time travel! Protect past-Medivh at Black Morass.",
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
            story = "FINALLY. Bring the blessed key to Khadgar. You've earned your ticket to the haunted house.",
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
        {
            name = "Shadow Labyrinth Key",
            source = "Drops from Talon King Ikiss in Sethekk Halls",
            type = "key",
            icon = "INV_Misc_Key_07",
            checkMethod = "item",
            checkId = 27991,  -- Entry to the Black Morass (Shadow Lab Key)
            required = true,
        },
        {
            name = "Arcatraz Key",
            source = "Warden's Cage quest chain in Netherstorm (or Rogue 350 Lockpicking)",
            type = "key",
            icon = "INV_Misc_Key_11",
            checkMethod = "item",
            checkId = 31084,  -- Key to the Arcatraz
            required = true,
        },
        {
            name = "Keepers of Time - Friendly",
            source = "Complete Old Hillsbrad Foothills dungeon",
            type = "reputation",
            icon = "Achievement_Reputation_01",
            checkMethod = "reputation",
            checkId = 989,  -- Keepers of Time faction ID
            checkStanding = 4,  -- Friendly = 4
            required = true,
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
            story = "Skar'this needs fancy rings to make a stick. Collect elemental signets from heroics!",
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
            story = "A'dal says 'prove yourself.' Four trials stand between you and space elves.",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10883, name = "The Tempest Key" },
            },
        },
        {
            name = "Trial of the Naaru: Mercy",
            story = "Heroic Shattered Halls speedrun! Save the prisoners before... well, you know.",
            locationIcon = "Ability_Warrior_Rampage",
            quests = {
                { id = 10884, name = "Trial of the Naaru: Mercy", dungeon = "Heroic Shattered Halls", requires = "Save prisoners, obtain Executioner's Axe" },
            },
        },
        {
            name = "Trial of the Naaru: Strength",
            story = "Strength test: grab loot from TWO heroic dungeons. Do you even lift, adventurer?",
            locationIcon = "INV_Gizmo_02",
            quests = {
                { id = 10885, name = "Trial of the Naaru: Strength", dungeons = {"Heroic Steamvault", "Heroic Shadow Labyrinth"}, requires = "Kalithresh's Trident + Murmur's Essence" },
            },
        },
        {
            name = "Trial of the Naaru: Tenacity",
            story = "Keep the loudmouth gnome alive in space prison. Tenacity indeed.",
            locationIcon = "Spell_Arcane_Arcane01",
            quests = {
                { id = 10886, name = "Trial of the Naaru: Tenacity", dungeon = "Heroic Arcatraz", requires = "Keep Millhouse Manastorm alive" },
            },
        },
        {
            name = "Trial of the Naaru: Magtheridon",
            story = "There's a Pit Lord under Hellfire Citadel. Make him not alive anymore.",
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
            story = "Bad vibes at Gul'dan's hand-shaped volcano. Time to poke around!",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10680, name = "The Hand of Gul'dan", faction = "Horde" },
                { id = 10681, name = "The Hand of Gul'dan", faction = "Alliance" },
            },
        },
        {
            name = "Enraged Spirits",
            story = "Spirits are throwing a tantrum. Someone corrupted their home. Fix it!",
            locationIcon = "Spell_Fire_Burnout",
            quests = {
                { id = 10458, name = "Enraged Spirits of Fire and Earth" },
                { id = 10480, name = "Enraged Spirits of Water" },
                { id = 10481, name = "Enraged Spirits of Air" },
            },
        },
        {
            name = "Oronok's Legacy",
            story = "Oronok has Cipher info, but it's a family affair. Hope you like errands!",
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
            story = "Grom'tor doesn't have friends, he has family. Help him get his fragment. Ride or die.",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10520, name = "Grom'tor, Son of Oronok" },
                { id = 10521, name = "The Cipher of Damnation - Grom'tor's Charge" },
                { id = 10522, name = "The Cipher of Damnation - The First Fragment Recovered" },
            },
        },
        {
            name = "Ar'tor's Fragment",
            story = "Son #2 got grabbed. This rescue? It's one last job... until the next one.",
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
            story = "Last brother, last fragment. Cross the finish line for the family!",
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
            story = "All fragments ready! Time to hit the NOS and burn down Cyrukh!",
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
            story = "Dragon needs bottle service. VIP bottles only - from Vashj and Kael'thas.",
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
            story = "The Aldor want tablets about snake people. Holy homework time!",
            locationIcon = "INV_Misc_Token_Aldor",
            quests = {
                { id = 10568, name = "Tablets of Baa'ri" },
            },
        },
        {
            name = "Oronu the Elder (Aldor)",
            story = "Find the old wise guy. The Aldor say he knows stuff.",
            locationIcon = "INV_Misc_Token_Aldor",
            quests = {
                { id = 10571, name = "Oronu the Elder" },
            },
        },
        {
            name = "The Ashtongue Corruptors (Aldor)",
            story = "Light's cleanup crew reporting for duty. Eliminate the corruptors!",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10574, name = "The Ashtongue Corruptors" },
            },
        },
        {
            name = "The Warden's Cage (Aldor)",
            story = "Find Akama's cage. Time to go full Michael Scofield on this temple.",
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
            story = "Get the tablets. The Scryers are updating their Burn Book on the Ashtongue.",
            locationIcon = "INV_Misc_Token_Scryer",
            quests = {
                { id = 10683, name = "Tablets of Baa'ri" },
            },
        },
        {
            name = "Oronu the Elder (Scryer)",
            story = "Get in loser, we're going to see Oronu. The Scryers need his secrets.",
            locationIcon = "INV_Misc_Token_Scryer",
            quests = {
                { id = 10684, name = "Oronu the Elder" },
            },
        },
        {
            name = "The Ashtongue Corruptors (Scryer)",
            story = "On Wednesdays, we eliminate corruptors. You can't sit with us, Ashtongue!",
            locationIcon = "Spell_Shadow_SummonFelHunter",
            quests = {
                { id = 10685, name = "The Ashtongue Corruptors" },
            },
        },
        {
            name = "The Warden's Cage (Scryer)",
            story = "Locate the prison. Illidan doesn't even GO here but we're rescuing Akama anyway.",
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
            story = "'What's the job?' Kill Zandras. 'I'm listening.'",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10622, name = "Proof of Allegiance", requires = "Kill Zandras" },
            },
        },
        {
            name = "Akama",
            story = "Meet Akama. He's the mastermind. He's got a plan. It's crazy enough to work.",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10628, name = "Akama" },
            },
        },
        {
            name = "A Mysterious Portent",
            story = "Need intel? Seer Udalo's our inside man. He's in space prison. Minor detail.",
            locationIcon = "Spell_Arcane_Arcane01",
            quests = {
                { id = 10706, name = "A Mysterious Portent", dungeon = "The Arcatraz" },
            },
        },
        {
            name = "The Ata'mal Terrace",
            story = "The Heart of Fury - our MacGuffin. Grab it from Shadowmoon. Don't trigger alarms.",
            locationIcon = "Spell_Shadow_Possession",
            quests = {
                { id = 10707, name = "The Ata'mal Terrace", requires = "Heart of Fury" },
            },
        },
        {
            name = "Akama's Promise",
            story = "A'dal's the backer. Tell the glowing orb that Akama's in. Deal's on.",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10708, name = "Akama's Promise" },
            },
        },
        {
            name = "The Secret Compromised",
            story = "Karathress knows too much. In heist terms: loose end. Handle it.",
            locationIcon = "INV_Misc_MonsterClaw_03",
            quests = {
                { id = 10944, name = "The Secret Compromised", raid = "Serpentshrine Cavern", boss = "Fathom-Lord Karathress" },
            },
        },
        {
            name = "Ruse of the Ashtongue",
            story = "Every heist needs face work. Put on the cowl, blend in, eliminate the target.",
            locationIcon = "Spell_Arcane_PortalShattrath",
            quests = {
                { id = 10946, name = "Ruse of the Ashtongue", raid = "Tempest Keep", boss = "Al'ar", requires = "Wear Ashtongue Cowl" },
            },
        },
        {
            name = "An Artifact From the Past",
            story = "The phylactery job. Get in, grab the artifact, get out. Classic heist.",
            locationIcon = "Spell_Fire_Burnout",
            quests = {
                { id = 10947, name = "An Artifact From the Past", raid = "Mount Hyjal", boss = "Rage Winterchill" },
            },
        },
        {
            name = "The Hostage Soul",
            story = "I pity the soul trapped in this medallion. Ask A'dal how to free it!",
            locationIcon = "Spell_Holy_SurgeOfLight",
            quests = {
                { id = 10948, name = "The Hostage Soul" },
            },
        },
        {
            name = "Entry into the Black Temple",
            story = "Meet Xi'ri at the rendezvous point. The Black Temple job starts NOW.",
            locationIcon = "INV_Weapon_Glaive_01",
            quests = {
                { id = 10949, name = "Entry Into the Black Temple" },
            },
        },
        {
            name = "A Distraction for Akama",
            story = "Create the distraction. Akama makes the grab. This is the big score!",
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
    { key = "karazhan", data = C.KARAZHAN_ATTUNEMENT, tier = "T4", phase = 1, order = 1 },
    { key = "ssc", data = C.SSC_ATTUNEMENT, tier = "T5", phase = 2, order = 2 },
    { key = "tk", data = C.TK_ATTUNEMENT, tier = "T5", phase = 2, order = 3, prerequisite = "cipher" },
    { key = "hyjal", data = C.HYJAL_ATTUNEMENT, tier = "T6", phase = 3, order = 4 },
    { key = "bt", data = C.BT_ATTUNEMENT, tier = "T6", phase = 3, order = 5 },
}

-- Helper to get attunement phase by raid key
function C:GetAttunementPhase(raidKey)
    for _, attInfo in ipairs(C.ALL_ATTUNEMENTS) do
        if attInfo.key == raidKey then return attInfo.phase end
    end
    if raidKey == "cipher" then return 2 end
    return nil
end

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
        story = "Welcome to Karazhan! Free admission to the spookiest tower in Azeroth.",
        icon = "INV_Misc_Key_10",
    },
    ssc = {
        title = "Into the Depths",
        story = "Fin-ally! Swim on down to Vashj's place. Don't forget to hold your breath!",
        icon = "Spell_Frost_SummonWaterElemental",
    },
    tk = {
        title = "The Trials Complete",
        story = "Trials complete! Time to visit the space elves. Bring sunscreen for The Eye.",
        icon = "Spell_Fire_BurnoutGreen",
    },
    hyjal = {
        title = "Witness to History",
        story = "Got the vials? You're now cleared to witness the most epic battle ever. Don't blink!",
        icon = "INV_Potion_101",
    },
    bt = {
        title = "Illidan Awaits",
        story = "Heist complete. The Medallion's yours. Illidan never saw it coming.",
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
    -- Zul'Aman (Phase 4)
    [1189] = { raid = "za", boss = "nalorakk" },
    [1190] = { raid = "za", boss = "akilzon" },
    [1191] = { raid = "za", boss = "janalai" },
    [1192] = { raid = "za", boss = "halazzi" },
    [1193] = { raid = "za", boss = "hexlord" },
    [1194] = { raid = "za", boss = "zuljin" },
    -- Sunwell Plateau (Phase 5)
    [724]  = { raid = "sunwell", boss = "kalecgos" },
    [725]  = { raid = "sunwell", boss = "brutallus" },
    [726]  = { raid = "sunwell", boss = "felmyst" },
    [727]  = { raid = "sunwell", boss = "eredar_twins" },
    [728]  = { raid = "sunwell", boss = "muru" },
    [729]  = { raid = "sunwell", boss = "kiljaeden" },
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
    -- Zul'Aman (Phase 4)
    [23576] = { raid = "za", boss = "nalorakk" },        -- Nalorakk
    [23574] = { raid = "za", boss = "akilzon" },         -- Akil'zon
    [23578] = { raid = "za", boss = "janalai" },         -- Jan'alai
    [23577] = { raid = "za", boss = "halazzi" },         -- Halazzi
    [24239] = { raid = "za", boss = "hexlord" },         -- Hex Lord Malacrass
    [23863] = { raid = "za", boss = "zuljin" },          -- Zul'jin
    -- Sunwell Plateau (Phase 5)
    [24850] = { raid = "sunwell", boss = "kalecgos" },   -- Kalecgos
    [24892] = { raid = "sunwell", boss = "kalecgos" },   -- Sathrovarr (demon inside Kalecgos)
    [24882] = { raid = "sunwell", boss = "brutallus" },  -- Brutallus
    [25038] = { raid = "sunwell", boss = "felmyst" },    -- Felmyst
    [25165] = { raid = "sunwell", boss = "eredar_twins" }, -- Lady Sacrolash
    [25166] = { raid = "sunwell", boss = "eredar_twins" }, -- Grand Warlock Alythess
    [25741] = { raid = "sunwell", boss = "muru" },       -- M'uru
    [25840] = { raid = "sunwell", boss = "muru" },       -- Entropius (void god form)
    [25315] = { raid = "sunwell", boss = "kiljaeden" },  -- Kil'jaeden
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
        { raidKey = "za", bosses = C.ZA_BOSSES },
        { raidKey = "sunwell", bosses = C.SUNWELL_BOSSES },
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

-- Validation function to check all boss loot has itemIds
-- Returns array of missing entries or empty array if all valid
function C:ValidateBossLoot()
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

    local missing = {}

    for _, raidData in ipairs(raidBossTables) do
        if raidData.bosses then
            for _, boss in ipairs(raidData.bosses) do
                if boss.notableLoot then
                    for _, item in ipairs(boss.notableLoot) do
                        if not item.itemId or item.itemId == 0 then
                            table.insert(missing, raidData.raidKey .. "/" .. boss.name .. ": " .. (item.name or "Unknown"))
                        end
                    end
                end
            end
        end
    end

    return missing
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
            { name = "Fiery Warhorse's Reins", type = "Mount", dropRate = "~1%", itemId = 30480 },
            { name = "Spectral Band of Innervation", type = "Ring", itemId = 28510 },
            { name = "Worgen Claw Necklace", type = "Amulet", itemId = 28509 },
            { name = "Gloves of Saintly Blessings", type = "Cloth Hands", itemId = 28508 },
            { name = "Handwraps of Flowing Thought", type = "Cloth Hands", itemId = 28507 },
            { name = "Harbinger Bands", type = "Cloth Wrist", itemId = 28477 },
            { name = "Gloves of Dexterous Manipulation", type = "Leather Hands", itemId = 28506 },
            { name = "Bracers of the White Stag", type = "Leather Wrist", itemId = 28453 },
            { name = "Whirlwind Bracers", type = "Mail Wrist", itemId = 28503 },
            { name = "Stalker's War Bands", type = "Mail Wrist", itemId = 28454 },
            { name = "Gauntlets of Renewed Hope", type = "Plate Hands", itemId = 28505 },
            { name = "Vambraces of Courage", type = "Plate Wrist", itemId = 28502 },
            { name = "Steelhawk Crossbow", type = "Crossbow", itemId = 28504 },
            { name = "Schematic: Stabilized Eternium Scope", type = "Recipe", itemId = 23809 },
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
            { name = "Moroes' Lucky Pocket Watch", type = "Trinket", itemId = 28528 },
            { name = "Brooch of Unquenchable Fury", type = "Amulet", itemId = 28530 },
            { name = "Signet of Unshakable Faith", type = "Off-Hand", itemId = 28525 },
            { name = "Royal Cloak of Arathi Kings", type = "Cloak", itemId = 28529 },
            { name = "Shadow-Cloak of Dalaran", type = "Cloak", itemId = 28570 },
            { name = "Nethershard Girdle", type = "Cloth Waist", itemId = 28565 },
            { name = "Edgewalker Longboots", type = "Leather Feet", itemId = 28545 },
            { name = "Belt of Gale Force", type = "Mail Waist", itemId = 28567 },
            { name = "Boots of Valiance", type = "Plate Feet", itemId = 28569 },
            { name = "Crimson Girdle of the Indomitable", type = "Plate Waist", itemId = 28566 },
            { name = "Emerald Ripper", type = "Dagger", itemId = 28524 },
            { name = "Idol of the Avian Heart", type = "Idol", itemId = 28568 },
            { name = "Formula: Enchant Weapon - Mongoose", type = "Recipe", itemId = 22559 },
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
        notableLoot = {
            { name = "Shard of the Virtuous", type = "Mace", itemId = 28522 },
            { name = "Barbed Choker of Discipline", type = "Amulet", itemId = 28516 },
            { name = "Bands of Indwelling", type = "Cloth Wrist", itemId = 28511 },
            { name = "Bands of Nefarious Deeds", type = "Cloth Wrist", itemId = 28515 },
            { name = "Boots of Foretelling", type = "Cloth Feet", itemId = 28517 },
            { name = "Bracers of Maliciousness", type = "Leather Wrist", itemId = 28514 },
            { name = "Mitts of the Treemender", type = "Leather Hands", itemId = 28521 },
            { name = "Gloves of Centering", type = "Mail Hands", itemId = 28520 },
            { name = "Gloves of Quickening", type = "Mail Hands", itemId = 28519 },
            { name = "Bracers of Justice", type = "Plate Wrist", itemId = 28512 },
            { name = "Iron Gauntlets of the Maiden", type = "Plate Hands", itemId = 28518 },
            { name = "Totem of Healing Rains", type = "Totem", itemId = 28523 },
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
        notableLoot = {
            -- Shared drops (all variants)
            { name = "Ribbon of Sacrifice", type = "Trinket", itemId = 28590 },
            { name = "Trial-Fire Trousers", type = "Cloth Legs", itemId = 28594 },
            { name = "Earthsoul Leggings", type = "Leather Legs", itemId = 28591 },
            { name = "Beastmaw Pauldrons", type = "Mail Shoulders", itemId = 28589 },
            { name = "Eternium Greathelm", type = "Plate Head", itemId = 28593 },
            { name = "Libram of Souls Redeemed", type = "Libram", itemId = 28592 },
            -- Wizard of Oz
            { name = "Ruby Slippers", type = "Cloth Feet", itemId = 28585 },
            { name = "Wicked Witch's Hat", type = "Cloth Head", itemId = 28586 },
            { name = "Legacy", type = "2H Axe", itemId = 28587 },
            { name = "Blue Diamond Witchwand", type = "Wand", itemId = 28588 },
            -- Big Bad Wolf
            { name = "Red Riding Hood's Cloak", type = "Cloak", itemId = 28582 },
            { name = "Big Bad Wolf's Head", type = "Mail Head", itemId = 28583 },
            { name = "Big Bad Wolf's Paw", type = "Fist Weapon", itemId = 28584 },
            { name = "Wolfslayer Sniper Rifle", type = "Gun", itemId = 28581 },
            -- Romulo and Julianne
            { name = "Romulo's Poison Vial", type = "Trinket", itemId = 28579 },
            { name = "Masquerade Gown", type = "Cloth Chest", itemId = 28578 },
            { name = "Blade of the Unrequited", type = "Dagger", itemId = 28572 },
            { name = "Despair", type = "2H Sword", itemId = 28573 },
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
            { name = "Gloves of the Fallen Hero", type = "Tier Token", itemId = 29756 },
            { name = "Gloves of the Fallen Champion", type = "Tier Token", itemId = 29757 },
            { name = "Gloves of the Fallen Defender", type = "Tier Token", itemId = 29758 },
            { name = "Garona's Signet Ring", type = "Ring", itemId = 28649 },
            { name = "Pauldrons of the Solace-Giver", type = "Cloth Shoulders", itemId = 28612 },
            { name = "Forest Wind Shoulderpads", type = "Leather Shoulders", itemId = 28647 },
            { name = "Dragon-Quake Shoulderguards", type = "Mail Shoulders", itemId = 28631 },
            { name = "Wrynn Dynasty Greaves", type = "Plate Legs", itemId = 28621 },
            { name = "Staff of Infinite Mysteries", type = "Staff", itemId = 28633 },
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
        notableLoot = {
            { name = "Pendant of the Violet Eye", type = "Trinket", itemId = 28727 },
            { name = "Shermanar Great-Ring", type = "Ring", itemId = 28675 },
            { name = "Saberclaw Talisman", type = "Amulet", itemId = 28674 },
            { name = "Drape of the Dark Reavers", type = "Cloak", itemId = 28672 },
            { name = "Boots of the Incorrupt", type = "Cloth Feet", itemId = 28663 },
            { name = "Boots of the Infernal Coven", type = "Cloth Feet", itemId = 28670 },
            { name = "Mantle of the Mind Flayer", type = "Cloth Shoulders", itemId = 28726 },
            { name = "Rapscallion Boots", type = "Leather Feet", itemId = 28669 },
            { name = "Steelspine Faceguard", type = "Mail Head", itemId = 28671 },
            { name = "Pauldrons of the Justice-Seeker", type = "Plate Shoulders", itemId = 28666 },
            { name = "Aran's Soothing Sapphire", type = "Off-Hand", itemId = 28728 },
            { name = "Tirisfal Wand of Ascendancy", type = "Wand", itemId = 28673 },
            { name = "Formula: Enchant Weapon - Sunfire", type = "Recipe", itemId = 22560 },
            { name = "Medivh's Journal", type = "Quest Item", itemId = 23933 },
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
        notableLoot = {
            { name = "The Lightning Capacitor", type = "Trinket", itemId = 28785 },
            { name = "Mender's Heart-Ring", type = "Ring", itemId = 28661 },
            { name = "Gilded Thorium Cloak", type = "Cloak", itemId = 28660 },
            { name = "Shadowvine Cloak of Infusion", type = "Cloak", itemId = 28653 },
            { name = "Cincture of Will", type = "Cloth Wrist", itemId = 28652 },
            { name = "Malefic Girdle", type = "Cloth Waist", itemId = 28654 },
            { name = "Cord of Nature's Sustenance", type = "Leather Waist", itemId = 28655 },
            { name = "Girdle of the Prowler", type = "Mail Waist", itemId = 28656 },
            { name = "Breastplate of the Lightbinder", type = "Plate Chest", itemId = 28662 },
            { name = "Fool's Bane", type = "Mace", itemId = 28657 },
            { name = "Xavian Stiletto", type = "Thrown", itemId = 28659 },
            { name = "Terestian's Stranglestaff", type = "Staff", itemId = 28658 },
            { name = "Formula: Enchant Weapon - Soulfrost", type = "Recipe", itemId = 22561 },
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
        notableLoot = {
            { name = "Mithril Band of the Unscarred", type = "Ring", itemId = 28730 },
            { name = "Shining Chain of the Afterworld", type = "Amulet", itemId = 28731 },
            { name = "Uni-Mind Headdress", type = "Cloth Head", itemId = 28744 },
            { name = "Pantaloons of Repentance", type = "Cloth Legs", itemId = 28742 },
            { name = "Cowl of Defiance", type = "Leather Head", itemId = 28732 },
            { name = "Skulker's Greaves", type = "Leather Legs", itemId = 28741 },
            { name = "Earthblood Chestguard", type = "Mail Chest", itemId = 28735 },
            { name = "Rip-Flayer Leggings", type = "Mail Legs", itemId = 28740 },
            { name = "Mantle of Abrahmis", type = "Plate Shoulders", itemId = 28743 },
            { name = "Girdle of Truth", type = "Plate Waist", itemId = 28733 },
            { name = "Spiteblade", type = "Sword", itemId = 28729 },
            { name = "Jewel of Infinite Possibilities", type = "Off-Hand", itemId = 28734 },
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
        notableLoot = {
            { name = "Ring of Recurrence", type = "Ring", itemId = 28753 },
            { name = "Mithril Chain of Heroism", type = "Amulet", itemId = 28745 },
            { name = "Headdress of the High Potentate", type = "Cloth Head", itemId = 28756 },
            { name = "Bladed Shoulderpads of the Merciless", type = "Leather Shoulders", itemId = 28755 },
            { name = "Forestlord Striders", type = "Leather Feet", itemId = 28752 },
            { name = "Girdle of Treachery", type = "Leather Waist", itemId = 28750 },
            { name = "Fiend Slayer Boots", type = "Mail Feet", itemId = 28746 },
            { name = "Heart-Flame Leggings", type = "Mail Legs", itemId = 28751 },
            { name = "Legplates of the Innocent", type = "Plate Legs", itemId = 28748 },
            { name = "Battlescar Boots", type = "Plate Feet", itemId = 28747 },
            { name = "Triptych Shield of the Ancients", type = "Shield", itemId = 28754 },
            { name = "King's Defender", type = "Sword (Tank)", itemId = 28749 },
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
            { name = "Helm of the Fallen Hero", type = "Tier Token", itemId = 29759 },
            { name = "Helm of the Fallen Defender", type = "Tier Token", itemId = 29761 },
            { name = "Helm of the Fallen Champion", type = "Tier Token", itemId = 29760 },
            { name = "Farstrider Wildercloak", type = "Cloak", itemId = 28764 },
            { name = "Ruby Drape of the Mysticant", type = "Cloak", itemId = 28766 },
            { name = "Stainless Cloak of the Pure Hearted", type = "Cloak", itemId = 28765 },
            { name = "Jade Ring of the Everliving", type = "Ring", itemId = 28763 },
            { name = "Ring of a Thousand Marks", type = "Ring", itemId = 28757 },
            { name = "Adornment of Stolen Souls", type = "Amulet", itemId = 28762 },
            { name = "Malchazeen", type = "Dagger", itemId = 28768 },
            { name = "Nathrezim Mindblade", type = "Dagger", itemId = 28770 },
            { name = "The Decapitator", type = "1H Axe", itemId = 28767 },
            { name = "Light's Justice", type = "Mace (Healer)", itemId = 28771 },
            { name = "Gorehowl", type = "2H Axe", itemId = 28773 },
            { name = "Sunfury Bow of the Phoenix", type = "Bow", itemId = 28772 },
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
            { name = "Emberspur Talisman", type = "Amulet", itemId = 28609 },
            { name = "Robe of the Elder Scribes", type = "Cloth Chest", itemId = 28602 },
            { name = "Stonebough Jerkin", type = "Leather Chest", itemId = 28600 },
            { name = "Chestguard of the Conniver", type = "Leather Chest", itemId = 28601 },
            { name = "Scaled Breastplate of Carnage", type = "Mail Chest", itemId = 28599 },
            { name = "Ferocious Swift-Kickers", type = "Mail Feet", itemId = 28610 },
            { name = "Ironstriders of Urgency", type = "Plate Feet", itemId = 28608 },
            { name = "Panzar'Thar Breastplate", type = "Plate Chest", itemId = 28597 },
            { name = "Nightstaff of the Everliving", type = "Staff", itemId = 28604 },
            { name = "Talisman of Nightbane", type = "Off-Hand", itemId = 28603 },
            { name = "Dragonheart Flameshield", type = "Shield", itemId = 28611 },
            { name = "Shield of Impenetrable Darkness", type = "Shield", itemId = 28606 },
            { name = "Blazing Signet", type = "Quest Item", itemId = 31751 },
            { name = "Faint Arcane Essence", type = "Quest Item", itemId = 24139 },
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
            { name = "Pauldrons of the Fallen Hero", type = "Tier Token", itemId = 29763 },
            { name = "Hammer of the Naaru", type = "2H Mace (Healer)", itemId = 28800 },
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
            { name = "Leggings of the Fallen Hero", type = "Tier Token", itemId = 29766 },
            { name = "Dragonspine Trophy", type = "Trinket (Physical DPS)", itemId = 28830 },
            { name = "Eye of Gruul", type = "Trinket (Caster)", itemId = 28823 },
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
            { name = "Chestguard of the Fallen Hero", type = "Tier Token", itemId = 29754 },
            { name = "Eredar Wand of Obliteration", type = "Wand", itemId = 28734 },
            { name = "Eye of Magtheridon", type = "Trinket", itemId = 28789 },
            { name = "Magtheridon's Head", type = "Quest Item (Ring reward)", itemId = 32385 },
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
            { name = "Shoulderpads of the Stranger", type = "Leather Shoulders", itemId = 30021 },
            { name = "Fathomstone", type = "Caster Off-Hand", itemId = 30084 },
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
            { name = "Earring of Soulful Meditation", type = "Trinket (Healer)", itemId = 30026 },
            { name = "Mallet of the Tides", type = "1H Mace", itemId = 30058 },
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
            { name = "Talon of Azshara", type = "Dagger", itemId = 30095 },
            { name = "Girdle of the Tidal Call", type = "Mail Belt", itemId = 30057 },
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
            { name = "Fathom-Brooch of the Tidewalker", type = "Trinket", itemId = 30085 },
            { name = "World Breaker", type = "2H Mace", itemId = 30082 },
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
            { name = "Tsunami Talisman", type = "Trinket (Physical DPS)", itemId = 30627 },
            { name = "True-Aim Stalker Bands", type = "Mail Wrists", itemId = 30041 },
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
            { name = "Crown of the Vanquished Hero", type = "Tier Token", itemId = 30244 },
            { name = "Vashj's Vial Remnant", type = "Quest Item (Hyjal attune)", itemId = 31341 },
            { name = "Serpent Spine Longbow", type = "Bow", itemId = 30112 },
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
            { name = "Talon of the Phoenix", type = "Fist Weapon", itemId = 29948 },
            { name = "Phoenix-Wing Cloak", type = "Back", itemId = 29950 },
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
            { name = "Mantle of the Vanquished Hero", type = "Tier Token", itemId = 30249 },
            { name = "Warp-Spring Coil", type = "Trinket", itemId = 29984 },
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
            { name = "Void Star Talisman", type = "Neck", itemId = 30018 },
            { name = "Girdle of the Righteous Path", type = "Plate Belt", itemId = 30064 },
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
            { name = "Chestguard of the Vanquished Hero", type = "Tier Token", itemId = 30236 },
            { name = "Kael's Vial Remnant", type = "Quest Item (Hyjal attune)", itemId = 31339 },
            { name = "Ashes of Al'ar", type = "Mount (~1%)", itemId = 32458 },
            { name = "Verdant Sphere", type = "Off-Hand", itemId = 30449 },
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
        dropsToken = "gloves",
        mechanics = {
            "8 trash waves before boss",
            "Icebolt - frozen in place, healers dispel",
            "Death and Decay - MOVE out immediately",
            "Frost Armor - tank damage reduction",
            "DPS race - relatively simple boss",
        },
        notableLoot = {
            { name = "Gloves of the Forgotten Vanquisher", type = "Tier Token", itemId = 31095 },
            { name = "Chronicle of Dark Secrets", type = "Off-Hand", itemId = 30872 },
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
        dropsToken = "belt",
        mechanics = {
            "8 trash waves before boss",
            "Carrion Swarm - frontal cone, face away",
            "Infernals rain from sky - avoid fire!",
            "Vampiric Aura - heals from damage dealt",
            "Sleep - healers be ready to dispel",
        },
        notableLoot = {
            { name = "Belt of the Forgotten Vanquisher", type = "Tier Token", itemId = 31089 },
            { name = "Don Rodrigo's Poncho", type = "Leather Chest", itemId = 30916 },
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
        dropsToken = "boots",
        mechanics = {
            "8 trash waves before boss",
            "Mark of Kaz'rogal - mana drain, EXPLODE when OOM!",
            "Mana users run out before exploding",
            "War Stomp - AoE stun + damage",
            "Enrage timer - burn fast",
        },
        notableLoot = {
            { name = "Boots of the Forgotten Vanquisher", type = "Tier Token", itemId = 31092 },
            { name = "Hammer of Atonement", type = "1H Mace", itemId = 30881 },
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
        dropsToken = "helm",
        mechanics = {
            "8 trash waves before boss",
            "Doom - 20 sec timer, run out and die alone!",
            "Lesser Doomguard spawns from Doom deaths",
            "Rain of Fire - move out of fire",
            "Howl of Azgalor - 5 sec silence",
        },
        notableLoot = {
            { name = "Helm of the Forgotten Vanquisher", type = "Tier Token", itemId = 31097 },
            { name = "Boundless Agony", type = "Dagger", itemId = 30901 },
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
        dropsToken = "shoulders",
        mechanics = {
            "No trash waves - straight to boss",
            "Air Burst - USE YOUR TEARS immediately!",
            "Tears of the Goddess slow fall - SPAM IT",
            "Doomfire - trails of fire, don't stand in it",
            "Soul Charge - on death, damages raid",
            "Fear + Grip - expect movement",
        },
        notableLoot = {
            { name = "Pauldrons of the Forgotten Vanquisher", type = "Tier Token", itemId = 31103 },
            { name = "Cataclysm's Edge", type = "2H Sword", itemId = 30903 },
            { name = "Tempest of Chaos", type = "Staff", itemId = 30910 },
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
            { name = "Halberd of Desolation", type = "Polearm", itemId = 32254 },
            { name = "Fists of Mukoa", type = "Leather Gloves", itemId = 32466 },
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
            { name = "Syphon of the Nathrezim", type = "Wand", itemId = 32262 },
            { name = "Band of the Abyssal Lord", type = "Ring", itemId = 32361 },
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
            { name = "Amice of Brilliant Light", type = "Cloth Shoulders", itemId = 32264 },
            { name = "Shadow-Walker's Cord", type = "Leather Belt", itemId = 32265 },
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
            { name = "Shadowmoon Destroyer's Drape", type = "Back", itemId = 32252 },
            { name = "Girdle of Lordaeron's Fallen", type = "Plate Belt", itemId = 32232 },
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
            { name = "Girdle of Mighty Resolve", type = "Plate Belt", itemId = 32251 },
            { name = "Shadowmoon Insignia", type = "Trinket", itemId = 32496 },
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
            { name = "Naaru-Blessed Life Rod", type = "Wand", itemId = 32348 },
            { name = "Translucent Spellthread Necklace", type = "Neck", itemId = 32352 },
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
            { name = "Leggings of the Forgotten Vanquisher", type = "Tier Token", itemId = 31101 },
            { name = "Heartshatter Breastplate", type = "Plate Chest", itemId = 32365 },
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
            { name = "Madness of the Betrayer", type = "Trinket (Physical DPS)", itemId = 32505 },
            { name = "Tome of the Lightbringer", type = "Relic", itemId = 32363 },
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
            { name = "Chestguard of the Forgotten Vanquisher", type = "Tier Token", itemId = 31090 },
            { name = "Warglaive of Azzinoth (MH)", type = "Legendary", itemId = 32837 },
            { name = "Warglaive of Azzinoth (OH)", type = "Legendary", itemId = 32838 },
            { name = "Bulwark of Azzinoth", type = "Shield (Tank)", itemId = 32375 },
            { name = "Skull of Gul'dan", type = "Trinket (Caster)", itemId = 32483 },
        },
    },
}

--============================================================
-- PHASE 4 RAID BOSS DATA - ZUL'AMAN
--============================================================
C.ZA_BOSSES = {
    {
        id = "nalorakk",
        name = "Nalorakk",
        location = "Bear Den",
        optional = false,
        order = 1,
        lore = "The Bear Avatar of the Amani. His savage strength is matched only by his cunning.",
        quote = "You be da first to charge, but da last to fall!",
        icon = "Ability_Druid_ChallangingRoar",
        mechanics = {
            "Two phases: Troll Form and Bear Form",
            "Troll Form: Brutal Strike (cleave), Mangle",
            "Bear Form: Lacerating Slash (bleed), Deafening Roar",
            "Surge - charges furthest target, have ranged stack",
            "Tank swap on Mangle debuff",
        },
        notableLoot = {
            { name = "Fury of the Ursine", type = "Fist Weapon", itemId = 33497 },
            { name = "Pauldrons of Primal Fury", type = "Plate Shoulders", itemId = 33516 },
            { name = "Bladeangel's Money Belt", type = "Leather Belt", itemId = 33490 },
        },
    },
    {
        id = "akilzon",
        name = "Akil'zon",
        location = "Eagle's Nest",
        optional = false,
        order = 2,
        lore = "The Eagle Avatar commands the storms. His lightning strikes without warning.",
        quote = "I be da predator! You be da prey!",
        icon = "Spell_Nature_CallStorm",
        mechanics = {
            "Electrical Storm - lifted player needs to be stacked under",
            "ALL raid must collapse under lifted player or wipe",
            "Static Disruption - AoE damage, spread when not collapsing",
            "Soaring Eagles - add spawns, kill quickly",
            "Call Lightning - random target damage",
        },
        notableLoot = {
            { name = "Akil'zon's Talonblade", type = "Dagger", itemId = 33188 },
            { name = "Signet of Ancient Magics", type = "Ring (Caster)", itemId = 33504 },
            { name = "Brooch of Nature's Mercy", type = "Neck (Healer)", itemId = 33281 },
        },
    },
    {
        id = "janalai",
        name = "Jan'alai",
        location = "Dragonhawk Platform",
        optional = false,
        order = 3,
        lore = "The Dragonhawk Avatar breeds an army of fiery minions.",
        quote = "Burn, you gonna burn!",
        icon = "Ability_Hunter_Pet_DragonHawk",
        mechanics = {
            "Two Hatchers spawn eggs on each side",
            "Control egg hatching - don't let too many hatch at once",
            "Kill one Hatcher early, let other hatch slowly",
            "At 35% ALL remaining eggs hatch - be ready for AoE",
            "Flame Breath - frontal cone, tank faces away",
            "Fire Bombs - avoid red patches on ground",
        },
        notableLoot = {
            { name = "Amani Divining Staff", type = "Staff (Healer)", itemId = 33324 },
            { name = "Jan'alai's Spaulders", type = "Mail Shoulders", itemId = 33463 },
            { name = "Bulwark of the Amani Empire", type = "Shield (Tank)", itemId = 33329 },
        },
    },
    {
        id = "halazzi",
        name = "Halazzi",
        location = "Lynx Temple",
        optional = false,
        order = 4,
        lore = "The Lynx Avatar is swift and deadly. His spirit cannot be contained.",
        quote = "Get on ya knees and bow to da fang and claw!",
        icon = "Ability_Mount_JungleTiger",
        mechanics = {
            "Phase 1: Normal tanking, Saber Lash (split damage)",
            "Phase 2 (at 75%, 50%, 25%): Spirit splits off",
            "Kill Spirit of the Lynx to return to Phase 1",
            "Corrupted Lightning Totem - KILL IT IMMEDIATELY",
            "Flame Shock - dispel if possible",
            "Enrage at low health - burn fast",
        },
        notableLoot = {
            { name = "Avalanche Leggings", type = "Mail Legs", itemId = 33380 },
            { name = "The Savage's Choker", type = "Neck (Melee)", itemId = 33505 },
            { name = "Wub's Cursed Hexblade", type = "Sword (Caster)", itemId = 33479 },
        },
    },
    {
        id = "hexlord",
        name = "Hex Lord Malacrass",
        location = "Malacrass's Terrace",
        optional = false,
        order = 5,
        lore = "The dark prophet steals the powers of his enemies to use against them.",
        quote = "Da shadow gonna fall on you!",
        icon = "Spell_Shadow_ShadowWordPain",
        mechanics = {
            "STEALS abilities from random raid members",
            "Stolen abilities depend on class composition",
            "Interrupt Spirit Bolts at all costs",
            "Siphon Soul - drains random player, heals boss",
            "2 random adds from a pool - CC or kill based on type",
            "Bring classes with interruptible abilities only",
        },
        notableLoot = {
            { name = "Tome of Diabolic Remedy", type = "Off-Hand (Healer)", itemId = 33509 },
            { name = "Tiny Voodoo Mask", type = "Trinket", itemId = 33506 },
            { name = "Hex Lord's Voodoo Pauldrons", type = "Cloth Shoulders", itemId = 33453 },
        },
    },
    {
        id = "zuljin",
        name = "Zul'jin",
        location = "Zul'jin's Arena",
        optional = false,
        finalBoss = true,
        order = 6,
        lore = "The legendary Amani warlord. He sacrificed his own arm to escape captivity, and now commands all four animal spirits.",
        quote = "Nobody baddah den me!",
        icon = "Spell_Nature_BloodLust",
        phases = {
            { name = "Phase 1: Troll", description = "Whirlwind and Grievous Throw" },
            { name = "Phase 2: Bear (80%)", description = "Creeping Paralysis - keep moving!" },
            { name = "Phase 3: Eagle (60%)", description = "Energy Storm - cannot cast, use instants" },
            { name = "Phase 4: Lynx (40%)", description = "Claw Rage - increased attack speed" },
            { name = "Phase 5: Dragonhawk (20%)", description = "Flame Pillars - fire everywhere!" },
        },
        mechanics = {
            "Phase 1: Avoid Whirlwind, heal Grievous Throw to full",
            "Phase 2: KEEP MOVING or Paralysis wipes raid",
            "Phase 3: NO CASTING - use wands, instants, melee only",
            "Phase 4: High tank damage, Lynx Rush charges random",
            "Phase 5: Avoid fire columns, burn boss FAST",
            "Timed event - kill fast for extra loot chest!",
        },
        notableLoot = {
            { name = "Cleaver of the Unforgiving", type = "Axe (2H)", itemId = 33466 },
            { name = "Chestguard of the Warlord", type = "Plate Chest", itemId = 33296 },
            { name = "Loop of Cursed Apathy", type = "Ring (Caster)", itemId = 33498 },
            { name = "Amani War Bear", type = "Mount (Timed Run)", dropRate = "Timed chest", itemId = 33809 },
        },
    },
}

--============================================================
-- PHASE 5 RAID BOSS DATA - SUNWELL PLATEAU
--============================================================
C.SUNWELL_BOSSES = {
    {
        id = "kalecgos",
        name = "Kalecgos",
        location = "Outer Courtyard",
        optional = false,
        order = 1,
        lore = "A blue dragon corrupted by the dreadlord Sathrovarr. Save him from within!",
        quote = "I will not be beaten back! Not again!",
        icon = "Spell_Arcane_PortalIronforge",
        phases = {
            { name = "Normal Realm", description = "Fight Kalecgos the dragon" },
            { name = "Demon Realm", description = "Fight Sathrovarr inside Kalecgos" },
        },
        mechanics = {
            "Raid splits between two realms via portals",
            "Normal Realm: Tank dragon, avoid Frost Breath",
            "Spectral Blast - teleports players to Demon Realm",
            "Demon Realm: Fight Sathrovarr, curse management",
            "Both bosses share health - damage either",
            "Coordinate DPS between realms",
            "Corrupting Strike - tank debuff in demon realm",
        },
        notableLoot = {
            { name = "Fang of Kalecgos", type = "Dagger (Caster)", itemId = 34346 },
            { name = "Legplates of the Holy Juggernaut", type = "Plate Legs (Healer)", itemId = 34384 },
            { name = "Bracers of the Forgotten Conqueror", type = "Tier Token", itemId = 34848 },
        },
    },
    {
        id = "brutallus",
        name = "Brutallus",
        location = "Dead Scar",
        optional = false,
        order = 2,
        lore = "A pit lord of immense power. Pure DPS race - no gimmicks, just survival.",
        quote = "Gorgonna, Madrigosa... you'll need more help than that!",
        icon = "Spell_Shadow_SummonFelGuard",
        mechanics = {
            "PURE DPS RACE - ~6 minute enrage",
            "Meteor Slash - stacks debuff, need 2 tank groups",
            "Burn - DoT that spreads to nearby players",
            "Burned players MUST spread out immediately",
            "Stomp - massive tank damage",
            "Requires extremely high raid DPS",
            "Tank swap at 3-4 Meteor Slash stacks",
        },
        notableLoot = {
            { name = "Heart of the Pit", type = "Trinket (Caster)", itemId = 34179 },
            { name = "Leggings of Calamity", type = "Cloth Legs", itemId = 34386 },
            { name = "Collar of Bones", type = "Neck (Physical DPS)", itemId = 34358 },
        },
    },
    {
        id = "felmyst",
        name = "Felmyst",
        location = "Dead Scar",
        optional = false,
        order = 3,
        lore = "Madrigosa reborn as an undead fel dragon. She guards the path to the Sunwell.",
        quote = "I am stronger than ever before!",
        icon = "Spell_Shadow_Possession",
        phases = {
            { name = "Ground Phase", description = "Tank and spank with positioning" },
            { name = "Air Phase", description = "Avoid breath, kill skeletons" },
        },
        mechanics = {
            "Ground Phase: Gas Nova (nature damage), Encapsulate",
            "Encapsulate - player floats up, raid must move away",
            "Corrosion - frontal cone, tank faces away from raid",
            "Air Phase: Deep Breath down the raid - MOVE!",
            "Fog of Corruption - AVOID THE GREEN FOG",
            "Mind Control from fog = instant wipe risk",
            "Skeleton adds spawn during air phase",
        },
        notableLoot = {
            { name = "Sword Breaker's Bulwark", type = "Shield (Tank)", itemId = 34185 },
            { name = "Borderland Paingrips", type = "Leather Gloves", itemId = 34370 },
            { name = "Bracers of the Forgotten Protector", type = "Tier Token", itemId = 34851 },
        },
    },
    {
        id = "eredar_twins",
        name = "Eredar Twins",
        location = "Witch's Sanctum",
        optional = false,
        order = 4,
        lore = "Lady Sacrolash and Grand Warlock Alythess. Sisters bound by shadow and flame.",
        quote = "Sacrolash: Your are not alone in this struggle! | Alythess: With my power, you cannot fall!",
        icon = "Spell_Fire_Burnout",
        council = {
            { name = "Lady Sacrolash", role = "Shadow - melee tank, Confounding Blow" },
            { name = "Grand Warlock Alythess", role = "Fire - ranged tank, Conflagration" },
        },
        mechanics = {
            "Two bosses with shared health pool",
            "Sacrolash (Shadow): Tank away from Alythess",
            "Alythess (Fire): Ranged tank, Conflagration spreads",
            "Shadow Nova/Flame Sear - raid-wide damage",
            "Confounding Blow - tank swap mechanic",
            "Conflagration - move away from raid immediately",
            "Dark Strike needs high melee tank threat",
        },
        notableLoot = {
            { name = "Grip of Mannoroth", type = "Plate Gloves (DPS)", itemId = 34342 },
            { name = "Grand Magister's Staff of Torrents", type = "Staff (Caster)", itemId = 34182 },
            { name = "Sin'dorei Band of Salvation", type = "Ring (Healer)", itemId = 34362 },
        },
    },
    {
        id = "muru",
        name = "M'uru",
        location = "Shrine of the Eclipse",
        optional = false,
        order = 5,
        lore = "A captured naaru, drained of light and transformed into a void god.",
        quote = nil, -- M'uru is silent, void whispers only
        icon = "Spell_Holy_PrayerOfSpirit",
        phases = {
            { name = "Phase 1: M'uru", description = "Naaru form with add waves" },
            { name = "Phase 2: Entropius", description = "Void god form - burn phase" },
        },
        mechanics = {
            "Phase 1: M'uru is stationary, spawns adds",
            "Void Sentinels - must be tanked and killed",
            "Shadowsword adds from portals - humanoids first",
            "Darkness - pulsing shadow damage",
            "Phase 2 (at 0% M'uru): Transforms to Entropius",
            "Entropius: Pure burn phase, black holes spawn",
            "Black Holes pull players in - avoid at all costs",
            "Considered hardest boss of TBC",
        },
        notableLoot = {
            { name = "Blade of Harbingers", type = "Sword (Tank)", itemId = 34247 },
            { name = "Sin'dorei Band of Triumph", type = "Ring (Physical DPS)", itemId = 34189 },
            { name = "Bracers of the Forgotten Vanquisher", type = "Tier Token", itemId = 34852 },
        },
    },
    {
        id = "kiljaeden",
        name = "Kil'jaeden",
        location = "Sunwell",
        optional = false,
        finalBoss = true,
        order = 6,
        lore = "The Deceiver himself. The lord of the Burning Legion attempts to enter Azeroth through the Sunwell.",
        quote = "You are not prepared for what awaits you in the Sunwell!",
        icon = "Spell_Fire_FelFlameRing",
        phases = {
            { name = "Phase 1 (100-85%)", description = "Introduction, basic abilities" },
            { name = "Phase 2 (85-55%)", description = "Shield Orbs, Flame Darts" },
            { name = "Phase 3 (55-25%)", description = "Shadow Spikes, Armageddon" },
            { name = "Phase 4 (25-0%)", description = "Darkness of a Thousand Souls" },
            { name = "Dragon Phase", description = "Blue dragons assist periodically" },
        },
        mechanics = {
            "Phase 1: Soul Flay tank damage, Fire Bloom on raid",
            "Phase 2: Shield Orbs - destroy them quickly",
            "Flame Darts - spread out, don't chain",
            "Phase 3: Shadow Spikes - MOVE from ground effects",
            "Armageddon - massive meteors, heal through",
            "Phase 4: Darkness - use Dragon Orbs to shield raid",
            "Blue Dragon Orbs activate periodically - CRITICAL",
            "Sinister Reflection - copies of players spawn",
            "Final boss of TBC - the ultimate challenge",
        },
        notableLoot = {
            { name = "Thori'dal, the Stars' Fury", type = "Legendary Bow", dropRate = "~5%", itemId = 34334 },
            { name = "Helm of Burning Righteousness", type = "Plate Helm (Tank)", itemId = 34244 },
            { name = "Cover of Ursol the Wise", type = "Leather Helm (Caster)", itemId = 34245 },
            { name = "Sunflare", type = "Dagger (Caster)", itemId = 34336 },
            { name = "Golden Staff of the Sin'dorei", type = "Staff (Healer)", itemId = 34337 },
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
    za = "T6",        -- Phase 4: Catch-up raid with T6-equivalent gear
    sunwell = "T6",   -- Phase 5: Final tier
}

-- All raid keys (includes non-attunement raids like Gruul/Magtheridon/ZA/Sunwell)
C.ALL_RAID_KEYS = { "karazhan", "gruul", "magtheridon", "ssc", "tk", "hyjal", "bt", "za", "sunwell" }

-- Attunement-only raid keys (raids with attunement quest chains)
C.ATTUNEMENT_RAID_KEYS = { "karazhan", "ssc", "tk", "hyjal", "bt" }

-- Raids organized by tier (for UI display)
C.RAIDS_BY_TIER = {
    T4 = { "karazhan", "gruul", "magtheridon" },
    T5 = { "ssc", "tk" },
    T6 = { "hyjal", "bt", "za", "sunwell" },
}

-- Get tier for a given raid key
function C:GetRaidTier(raidKey)
    return self.RAID_TIERS[raidKey]
end

-- Raid phase mapping (Phase 1-5 for TBC content)
C.RAID_PHASES = {
    karazhan = 1,
    gruul = 1,
    magtheridon = 1,
    ssc = 2,
    tk = 2,
    hyjal = 3,
    bt = 3,
    za = 4,
    sunwell = 5,
}

-- Raids organized by phase (for UI display)
C.RAIDS_BY_PHASE = {
    [1] = { "karazhan", "gruul", "magtheridon" },  -- Phase 1: T4 raids
    [2] = { "ssc", "tk" },                          -- Phase 2: T5 raids
    [3] = { "hyjal", "bt" },                        -- Phase 3: T6 raids
    [4] = { "za" },                                 -- Phase 4: Zul'Aman
    [5] = { "sunwell" },                            -- Phase 5: Sunwell Plateau
}

-- Get phase for a given raid key
function C:GetRaidPhase(raidKey)
    return self.RAID_PHASES[raidKey]
end

-- Raid visual theming data (for Raids tab UI)
C.RAID_THEMES = {
    karazhan    = { accentColor = "KARA_ACCENT",  bgTint = "KARA_BG_TINT",  icon = "INV_Misc_Key_10" },
    gruul       = { accentColor = "GRUUL_ACCENT", bgTint = "GRUUL_BG_TINT", icon = "Ability_Hunter_Pet_Devilsaur" },
    magtheridon = { accentColor = "MAG_ACCENT",   bgTint = "MAG_BG_TINT",   icon = "Spell_Shadow_SummonFelGuard" },
    ssc         = { accentColor = "SSC_ACCENT",   bgTint = "SSC_BG_TINT",   icon = "Spell_Frost_SummonWaterElemental" },
    tk          = { accentColor = "TK_ACCENT",    bgTint = "TK_BG_TINT",    icon = "Spell_Fire_BurnoutGreen" },
    hyjal       = { accentColor = "HYJAL_ACCENT", bgTint = "HYJAL_BG_TINT", icon = "INV_Misc_Herb_AncientLichen" },
    bt          = { accentColor = "BT_ACCENT",    bgTint = "BT_BG_TINT",    icon = "INV_Weapon_Glaive_01" },
    za          = { accentColor = "ZA_ACCENT",    bgTint = "ZA_BG_TINT",    icon = "Spell_Nature_BloodLust" },
    sunwell     = { accentColor = "SW_ACCENT",    bgTint = "SW_BG_TINT",    icon = "Spell_Holy_SummonLightwell" },
}

function C:GetRaidTheme(raidKey)
    return self.RAID_THEMES[raidKey]
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
        name = "Pong of War",
        description = "Classic arcade paddle action - local 2P or challenge a friend!",
        icon = "Interface\\Icons\\INV_Misc_PunchCards_Yellow",
        hasLocal = true,
        hasRemote = true,  -- Score Challenge mode
        system = "gamecore",
        color = "SKY_BLUE",
    },
    {
        id = "tetris",
        name = "Wowtris",
        description = "Clear lines! Local 2P with garbage or Score Challenge vs friends",
        icon = "Interface\\Icons\\INV_Misc_Gem_Variety_01",
        hasLocal = true,
        hasRemote = true,  -- Score Challenge mode
        system = "gamecore",
        color = "ARCANE_PURPLE",
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
    {
        id = "wordle",
        name = "WoWdle",
        description = "Guess the 5-letter WoW word in 6 tries!",
        icon = "Interface\\Icons\\INV_Misc_Note_06",
        hasLocal = true,
        hasRemote = true,
        system = "gamecore",
        color = "FEL_GREEN",
    },
    {
        id = "pacman",
        name = "Pac-Wow",
        description = "Classic arcade maze game - eat pellets, avoid ghosts!",
        icon = "Interface\\Icons\\INV_Misc_Food_11",
        hasLocal = true,
        hasRemote = true,  -- Score Challenge mode
        system = "gamecore",
        color = "GOLD",
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
-- WOW WORDLE CONSTANTS
-- Settings for the Wordle-style word guessing game
--============================================================

-- Game rules
C.WORDLE = {
    WORD_LENGTH = 5,
    MAX_GUESSES = 6,

    -- Animation timings (in seconds)
    REVEAL_DELAY = 0.3,             -- Delay between each letter reveal
    FLIP_DURATION = 0.25,           -- Total flip animation duration (shrink + expand)
    SHAKE_DURATION = 0.4,           -- Row shake duration for invalid word
    SHAKE_INTENSITY = 8,            -- Horizontal shake distance in pixels
    BOUNCE_DELAY = 0.1,             -- Delay between each letter bounce on win
    BOUNCE_HEIGHT = 12,             -- Jump height in pixels
    BOUNCE_DURATION = 0.3,          -- Single bounce duration
    TOAST_DURATION = 2.0,           -- Floating message duration
    POP_SCALE = 1.12,               -- Scale factor for typing pop animation
    POP_DURATION = 0.05,            -- Pop animation duration

    -- Win messages based on guess count (standard Wordle)
    WIN_MESSAGES = {
        [1] = "Genius!",
        [2] = "Magnificent!",
        [3] = "Impressive!",
        [4] = "Splendid!",
        [5] = "Great!",
        [6] = "Phew!",
    },
}

-- Wordle letter box colors (standard Wordle colors with TBC twist)
C.WORDLE_COLORS = {
    -- Letter box states
    CORRECT = { r = 0.42, g = 0.67, b = 0.39 },     -- Green (#6AAA64)
    PRESENT = { r = 0.79, g = 0.71, b = 0.35 },     -- Yellow (#C9B458)
    ABSENT = { r = 0.47, g = 0.49, b = 0.49 },      -- Grey (#787C7E)
    EMPTY = { r = 0.07, g = 0.07, b = 0.08 },       -- Dark (#121213)
    TYPING = { r = 0.15, g = 0.15, b = 0.16 },      -- Slightly lighter for current input
    BORDER = { r = 0.21, g = 0.22, b = 0.24 },      -- Border (#3A3A3C)
    BORDER_TYPING = { r = 0.34, g = 0.35, b = 0.36 }, -- Active border (#565758)
    BORDER_FILLED = { r = 0.55, g = 0.55, b = 0.57 }, -- Brighter border when letter typed (#8C8C91)

    -- Keyboard default
    KEY_DEFAULT = { r = 0.5, g = 0.5, b = 0.52 },   -- Grey key
    KEY_BORDER = { r = 0.3, g = 0.3, b = 0.3 },     -- Key border

    -- Text colors
    TEXT_WHITE = { r = 1, g = 1, b = 1 },
    TEXT_DARK = { r = 0.1, g = 0.1, b = 0.1 },

    -- P2.5-2.7: Toast colors (centralized from hardcoded RGB values)
    TOAST_SUCCESS = { r = 0, g = 1, b = 0 },      -- Victory toast
    TOAST_FAILURE = { r = 1, g = 0.3, b = 0.3 },  -- Game over toast
    TOAST_DEFAULT = { r = 1, g = 1, b = 1 },      -- Standard toast
}

-- Wordle UI dimensions (expanded for better layout)
C.WORDLE_UI = {
    -- Window dimensions (increased for hint button area)
    WINDOW_WIDTH = 460,             -- Was 420, +40px for breathing room
    WINDOW_HEIGHT = 720,            -- Was 680, +40px for hint button area

    -- Letter box dimensions
    BOX_SIZE = 56,
    BOX_GAP = 8,
    GRID_TOP = -100,                -- Was -60, pushed down for hint button

    -- Keyboard dimensions (slightly larger keys)
    KEY_WIDTH = 36,                 -- Was 32
    KEY_HEIGHT = 52,                -- Was 48
    KEY_GAP = 6,                    -- Was 4
    KEYBOARD_TOP = -500,            -- Was -460, pushed down to maintain spacing

    -- Position offsets
    TOAST_TOP = -100,               -- Toast position below hint button
    STATUS_BOTTOM = 15,             -- Status text offset from bottom
    TOAST_PADDING = 12,             -- P2.7: Toast frame padding

    -- Font sizes (P2.5: centralized from hardcoded values)
    LETTER_FONT_SIZE = 28,          -- Letter box text
    KEY_FONT_SIZE = 14,             -- Keyboard key text
    TOAST_FONT_SIZE = 14,           -- Toast message text

    -- Keyboard layout
    KEYBOARD_ROWS = {
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    },
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

    -- Dark fel green theme (TBC/Outland aesthetic - notifications, popups)
    DARK_FEL = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Grayscale, tintable (unlike DialogBox-Border)
        tile = true,
        tileSize = 16,
        edgeSize = 12,  -- Tooltip border uses smaller edge size
        insets = { left = 3, right = 3, top = 3, bottom = 3 }  -- Match tooltip insets
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
    DARK_TRANSPARENT = { 0.1, 0.1, 0.1, 0.9 },
    DARK_SOLID = { 0.05, 0.05, 0.05, 0.9 },
    BLACK_SOLID = { 0.02, 0.02, 0.02, 0.95 },  -- Very dark for fel theme
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
    FEL_GREEN = { 0.2, 0.8, 0.2, 1 },  -- Alias for Outland fel theme borders
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
-- CENTRALIZED UI CONSTANTS
-- Single source of truth for common sizes and colors
--============================================================

-- Standard UI element sizes (pixels)
C.UI_SIZES = {
    ICON_TINY = 16,
    ICON_SMALL = 20,
    ICON_MEDIUM = 32,
    ICON_LARGE = 40,
    ICON_XL = 56,
    ROW_HEIGHT = 28,
    HEADER_HEIGHT = 24,
    DIVIDER_HEIGHT = 2,
    BUTTON_HEIGHT = 22,
}

-- Common UI colors (r, g, b format for SetTextColor, etc.)
C.UI_COLORS = {
    GOLD = { r = 1, g = 0.84, b = 0 },
    GOLD_DIM = { r = 0.8, g = 0.67, b = 0 },
    GREY_MUTED = { r = 0.6, g = 0.6, b = 0.6 },
    GREY_LIGHT = { r = 0.8, g = 0.8, b = 0.8 },
    GREEN_BRIGHT = { r = 0.2, g = 0.8, b = 0.2 },
    GREEN_HEAL = { r = 0.2, g = 1.0, b = 0.2 },
    RED_DEFEAT = { r = 1, g = 0.2, b = 0.2 },
    RED_DIM = { r = 0.8, g = 0.3, b = 0.3 },
    BLUE_INFO = { r = 0.4, g = 0.6, b = 1.0 },
}

-- RP Status colors (bright, neon-style for visibility)
-- Used by: MapPins, NameplateColors, FellowTravelers
C.RP_STATUS_COLORS = {
    IC = { r = 0.2, g = 1.0, b = 0.2 },       -- Bright Green - In Character
    OOC = { r = 0.0, g = 0.75, b = 1.0 },     -- Sky Blue - Out of Character
    LF_RP = { r = 1.0, g = 0.2, b = 0.8 },    -- Hot Pink - Looking for RP
    DEFAULT = { r = 0.0, g = 0.75, b = 1.0 }, -- Default to OOC (Sky Blue)
}

--============================================================
-- CLASS LOOT HOTLIST (Top 3 items per class from rep/dungeons)
-- Focus on reputation rewards and normal dungeon drops
-- No heroics, no raids
--============================================================
C.CLASS_LOOT_HOTLIST = {
    -- Standing values: 5=Friendly, 6=Honored, 7=Revered, 8=Exalted
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
                -- Alliance: Honor Hold ranged weapon
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
                -- Horde: Thrallmar ranged weapon
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
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
                            "Buy from Quartermaster Urgronn in Thrallmar",
                        },
                        alternatives = {
                            "Nerubian Slavemaker (Naxx - if you have it)",
                            "Emberhawk Crossbow (H OHB)",
                            "Melmorta's Twilight Longbow (H BM)",
                        },
                    },
                },
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = {
                            "Heroic dungeons (1 badge per boss)",
                            "Karazhan bosses (1-2 badges each)",
                            "Gruul/Magtheridon (2 badges each)",
                        },
                        statPriority = {
                            "BiS trinket for physical DPS until T5",
                            "+72 AP passive + 278 AP on-use burst",
                            "20 sec duration, 2 min cooldown",
                        },
                        tips = {
                            "Priority badge purchase for melee/hunters",
                            "Use on-use with Heroism/Bloodlust",
                            "Buy from G'eras in Shattrath (Terrace of Light)",
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
                -- Alliance: Honor Hold ranged weapon
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
                -- Horde: Thrallmar ranged weapon
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
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
                            "Buy from Quartermaster Urgronn in Thrallmar",
                        },
                        alternatives = {
                            "Nerubian Slavemaker (Naxx - if you have it)",
                            "Emberhawk Crossbow (H OHB)",
                            "Melmorta's Twilight Longbow (H BM)",
                        },
                    },
                },
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = {
                            "Heroic dungeons (1 badge per boss)",
                            "Karazhan bosses (1-2 badges each)",
                            "Gruul/Magtheridon (2 badges each)",
                        },
                        statPriority = {
                            "BiS trinket for physical DPS until T5",
                            "+72 AP passive + 278 AP on-use burst",
                            "20 sec duration, 2 min cooldown",
                        },
                        tips = {
                            "Priority badge purchase for melee/hunters",
                            "Use on-use with Heroism/Bloodlust",
                            "Buy from G'eras in Shattrath (Terrace of Light)",
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
                { itemId = 29527, name = "Timewarden's Leggings", icon = "INV_Pants_Plate_17", quality = "epic", slot = "Legs", stats = "+55 Sta, +23 Def Rating, +22 Dodge", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8,
                    hoverData = {
                        repSources = {
                            "Old Hillsbrad Foothills (8 rep/kill)",
                            "Black Morass (8 Normal, 25 Heroic rep/kill)",
                            "Caverns of Time attunement questline",
                        },
                        statPriority = {
                            "Excellent pre-raid tank legs",
                            "+23 Defense helps reach 490 cap",
                            "+55 Stamina for effective health",
                        },
                        tips = {
                            "Black Morass Heroic is fastest at 70",
                            "Complete attunement first (required for Heroic)",
                            "Buy from Alurmi in Caverns of Time",
                        },
                        alternatives = {
                            "Timewarden's Leggings (same source)",
                            "Felsteel Leggings (Blacksmithing)",
                            "Legplates of the Bold (H MgT)",
                        },
                    },
                },
                { itemId = 27672, name = "Girdle of the Immovable", icon = "INV_Belt_29", quality = "rare", slot = "Waist", stats = "+33 Sta, +21 Def, +23 Shield Block", source = "Quagmirran (Slave Pens)", sourceType = "dungeon",
                    hoverData = {
                        dropInfo = {
                            "Drops from Quagmirran in Slave Pens",
                            "~18% drop rate on Normal",
                            "Also available in Heroic mode",
                        },
                        statPriority = {
                            "Excellent early tank belt",
                            "+21 Defense + 23 Shield Block Rating",
                            "+33 Stamina for solid HP",
                        },
                        tips = {
                            "Easy to farm - Slave Pens is quick",
                            "Good stepping stone to raid gear",
                            "Quagmirran is the final boss",
                        },
                        alternatives = {
                            "Sha'tari Vindicator's Waistguard (H Mech)",
                            "Belt of the Guardian (BS craft)",
                            "Crimson Girdle of the Indomitable (H SH)",
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
                -- Alliance: Honor Hold ranged weapon
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
                -- Horde: Thrallmar ranged weapon
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
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
                            "Buy from Quartermaster Urgronn in Thrallmar",
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
                { itemId = 28771, name = "Light's Justice", icon = "INV_Mace_37", quality = "epic", slot = "Main Hand", stats = "+264 Healing, +22 Int, +10 MP5", source = "Prince Malchezaar (Karazhan)", sourceType = "raid",
                    hoverData = {
                        dropInfo = {
                            "Drops from Prince Malchezaar (final boss)",
                            "Karazhan raid (10-man)",
                            "~15% drop rate",
                        },
                        statPriority = {
                            "+264 Healing - highest pre-raid weapon",
                            "+22 Intellect for larger mana pool",
                            "+10 MP5 for sustained healing",
                        },
                        tips = {
                            "Best pre-raid healing mace in TBC",
                            "Prince can be challenging - practice fight",
                            "Competes with caster DPS for drop",
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
                { itemId = 29527, name = "Timewarden's Leggings", icon = "INV_Pants_Plate_17", quality = "epic", slot = "Legs", stats = "+55 Sta, +23 Def Rating, +22 Dodge", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8,
                    hoverData = {
                        repSources = {
                            "Old Hillsbrad Foothills (10-25 rep/kill)",
                            "Black Morass (15-25 rep/kill)",
                            "Caverns of Time quests (~4.5k rep total)",
                        },
                        statPriority = {
                            "Excellent pre-raid tank legs for Paladins",
                            "+23 Defense helps reach 490 def cap",
                            "+55 Stamina adds ~550 HP",
                        },
                        tips = {
                            "Long grind - start Heroics early once Revered",
                            "Black Morass gives more rep per run",
                            "Buy from Alurmi in Caverns of Time",
                        },
                        alternatives = {
                            "Felsteel Leggings (Blacksmithing)",
                            "Sha'tari Wrought Armguards (Shattered Halls)",
                            "Bold Legplates (Quest)",
                        },
                    },
                },
                { itemId = 27672, name = "Girdle of the Immovable", icon = "INV_Belt_29", quality = "rare", slot = "Waist", stats = "+33 Sta, +21 Def, +23 Shield Block", source = "Quagmirran (Slave Pens)", sourceType = "dungeon",
                    hoverData = {
                        dropInfo = {
                            "Drops from Quagmirran in Slave Pens",
                            "~18% drop rate on Normal",
                            "Also available in Heroic mode",
                        },
                        statPriority = {
                            "Excellent early tank belt",
                            "+21 Defense + 23 Shield Block Rating",
                            "+33 Stamina for solid HP",
                        },
                        tips = {
                            "Easy to farm - Slave Pens is quick",
                            "Good stepping stone to raid gear",
                            "Quagmirran is the final boss",
                        },
                        alternatives = {
                            "Sha'tari Vindicator's Waistguard (H Mech)",
                            "Belt of the Guardian (BS craft)",
                            "Crimson Girdle of the Indomitable (H SH)",
                        },
                    },
                },
                { itemId = 29388, name = "Libram of Repentance", icon = "INV_Relics_LibramofHope", quality = "epic", slot = "Relic", stats = "Block Value +35", source = "G'eras (15 Badges)", sourceType = "badge",
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
                -- Alliance: Honor Hold ranged weapon
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
                -- Horde: Thrallmar ranged weapon
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
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
                            "Buy from Quartermaster Urgronn (Thrallmar)",
                        },
                        alternatives = {
                            "Don Santos' Famous Hunting Rifle (AH)",
                            "Felsteel Whisper Knives (Throwing)",
                            "Skip this slot - low priority for Ret",
                        },
                    },
                },
                { itemId = 27484, name = "Libram of Avengement", icon = "INV_Relics_LibramofGrace", quality = "rare", slot = "Relic", stats = "+Crusader Strike dmg", source = "The Maker (Blood Furnace)", sourceType = "dungeon", faction = "The Scryers", standing = 7,
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
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "Best pre-raid caster ring with Hit", "+23 Hit massive for reaching cap" },
                        tips = { "Shadow Lab is best rep but harder", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ashyen's Gift (Cenarion Exalted)", "Ring of Cryptic Dreams (H Mana-Tombs)" },
                    },
                },
                { itemId = 32387, name = "Idol of the Raven Goddess", icon = "INV_Relics_IdolofRejuvenation", quality = "epic", slot = "Relic", stats = "+Moonfire/Wrath dmg", source = "Quest: Vanquish the Raven God", sourceType = "quest", faction = "Cenarion Expedition", standing = 8,
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
                { itemId = 27744, name = "Idol of Ursoc", icon = "INV_Relics_IdolofFerocity", quality = "rare", slot = "Relic", stats = "+Maul damage +54", source = "Hungarfen (Heroic Underbog)", sourceType = "heroic", faction = "Cenarion Expedition", standing = 7,
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
                { itemId = 29170, name = "Windcaller's Orb", icon = "INV_Misc_Orb_02", quality = "epic", slot = "Off Hand", stats = "+27 Sta, +18 Int, +18 Spi", source = "Cenarion Expedition @ Exalted", sourceType = "rep", faction = "Cenarion Expedition", standing = 8,
                    hoverData = {
                        repSources = { "Coilfang dungeons (10-25 rep/kill)", "Turn in Plant Parts (250 rep/10, until Honored)" },
                        statPriority = { "Good caster off-hand for Resto Druid", "+18 Spirit benefits mana regen" },
                        tips = { "Long grind to Exalted - start CE dungeons early", "Buy from Fedryen Swiftspear in Cenarion Refuge" },
                        alternatives = { "Lamp of Peaceful Repose (H Bot)", "Tears of Heaven (Aldor Exalted)" },
                    },
                },
                -- Non-rep item: Best pre-raid Resto Druid Idol (dungeon drop)
                { itemId = 27886, name = "Idol of the Emerald Queen", icon = "INV_Relics_IdolofRejuvenation", quality = "rare", slot = "Relic", stats = "+88 Lifebloom periodic heal", source = "Ambassador Hellmaw (Shadow Lab)", sourceType = "dungeon",
                    hoverData = {
                        repSources = {
                            "Drops from Ambassador Hellmaw in Shadow Labyrinth",
                            "Normal mode - no Heroic key needed",
                            "~15-20% drop rate",
                        },
                        statPriority = {
                            "BiS pre-raid Idol for Resto Druids",
                            "+88 Healing per Lifebloom tick",
                            "Core part of rolling Lifebloom rotation",
                        },
                        tips = {
                            "First boss in Shadow Lab - quick runs",
                            "Normal mode works fine for this drop",
                            "No reputation required",
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
        -- Tab 4: Feral (Cat DPS)
        [4] = {
            rep = {
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = { "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)", "Turn in Oshu'gun Crystal Powder Samples (250 rep/10)", "Consortium quests in Nagrand and Netherstorm" },
                        statPriority = { "BiS pre-raid neck for Cat DPS", "+22 Hit Rating helps reach melee hit cap (9%)", "+20 Agility provides crit and AP" },
                        tips = { "Farm Oshu'gun Powder from Nagrand ogres/ethereals", "Mana-Tombs Heroic is fastest once keyed", "Buy from Karaaz in Stormspire (Netherstorm)" },
                        alternatives = { "Natasha's Ember Necklace (Nagrand quest)", "Necklace of the Deep (Fishing)", "Worgen Claw Necklace (H Underbog)" },
                    },
                },
                { itemId = 30834, name = "Shapeshifter's Signet", icon = "INV_Jewelry_Ring_51naxxramas", quality = "epic", slot = "Ring", stats = "+24 Sta, +23 Int, +23 Hit", source = "Lower City @ Exalted", sourceType = "rep", faction = "Lower City", standing = 8,
                    hoverData = {
                        repSources = { "Auchenai Crypts/Sethekk Halls (10 rep/kill)", "Shadow Labyrinth (12-25 rep/kill)" },
                        statPriority = { "Excellent ring with Hit for Cat DPS", "+23 Hit helps reach dual-wield cap for abilities", "Stamina adds survivability" },
                        tips = { "Shadow Lab is best rep but harder", "Buy from Nakodu in Lower City" },
                        alternatives = { "Ring of Umbral Doom (H Sethekk)", "Delicate Eternium Ring (Jewelcrafting)" },
                    },
                },
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = { "Heroic dungeons (1 badge per boss)", "Karazhan bosses (1-2 badges each)", "Gruul/Magtheridon (2 badges each)" },
                        statPriority = { "BiS trinket for Cat DPS", "+72 AP passive + 278 AP on-use burst", "20 sec duration, 2 min cooldown" },
                        tips = { "Priority badge purchase for melee", "Use on-use with Tiger's Fury", "Buy from G'eras in Shattrath (Terrace of Light)" },
                        alternatives = { "Hourglass of the Unraveller (H BM)", "Abacus of Violent Odds (H Mech)" },
                    },
                },
            },
            drops = {
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 27890, name = "Girdle of Ferocity", icon = "INV_Belt_13", quality = "epic", slot = "Waist", stats = "+31 Str, +16 Agi, +36 Sta", source = "Heroic Shattered Halls", sourceType = "drops" },
                { itemId = 27994, name = "Spaulders of Dementia", icon = "INV_Shoulder_25", quality = "rare", slot = "Shoulder", stats = "+28 Str, +28 Sta, +22 Crit", source = "Heroic Sethekk Halls", sourceType = "drops" },
            },
            crafted = {
                { itemId = 25695, name = "Fel Leather Gloves", icon = "INV_Gauntlets_25", quality = "rare", slot = "Hands", stats = "+27 Agi, +26 Sta, +15 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25696, name = "Fel Leather Leggings", icon = "INV_Pants_Leather_09", quality = "rare", slot = "Legs", stats = "+30 Agi, +29 Sta, +17 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
                { itemId = 25697, name = "Fel Leather Boots", icon = "INV_Boots_Chain_08", quality = "rare", slot = "Feet", stats = "+24 Agi, +23 Sta, +14 Hit", source = "Leatherworking", sourceType = "crafted", profession = "Leatherworking" },
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
                { itemId = 28248, name = "Totem of the Void", icon = "Spell_Nature_Groundingtotem", quality = "rare", slot = "Relic", stats = "+55 Lightning Bolt dmg", source = "Cache of the Legion (Mechanar)", sourceType = "dungeon",
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
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = { "Heroic dungeons (1 badge per boss)", "Karazhan bosses (1-2 badges each)", "Gruul/Magtheridon (2 badges each)" },
                        statPriority = { "BiS pre-raid trinket for physical DPS specs", "+72 permanent AP + 278 AP on use (2min CD)", "Stacks with all enhancement buffs" },
                        tips = { "Priority badge purchase for melee/hunters", "Use on-use with Heroism/Bloodlust", "Buy from G'eras in Shattrath (Terrace of Light)" },
                        alternatives = { "Hourglass of the Unraveller (H Black Morass)", "Abacus of Violent Odds (H Mechanar)", "Icon of Unyielding Courage (Quest)" },
                    },
                },
                { itemId = 27815, name = "Totem of the Astral Winds", icon = "Spell_Nature_Windfury", quality = "rare", slot = "Relic", stats = "+80 Stormstrike AP", source = "Pandemonius (Mana-Tombs)", sourceType = "dungeon", faction = "The Sha'tar", standing = 7,
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
                -- Non-rep item: Best pre-raid totem for Resto Shaman (dungeon drop)
                { itemId = 27544, name = "Totem of Spontaneous Regrowth", icon = "INV_Relics_Totem03", quality = "rare", slot = "Relic", stats = "+88 Healing Wave heal", source = "Mennu the Betrayer (Slave Pens)", sourceType = "dungeon",
                    hoverData = {
                        repSources = {
                            "Drops from Mennu the Betrayer in Slave Pens",
                            "Available in Normal and Heroic modes",
                            "~15-20% drop rate",
                        },
                        statPriority = {
                            "BiS pre-raid totem for Resto Shaman",
                            "+88 Healing to Healing Wave is massive throughput",
                            "Healing Wave is your primary tank heal",
                        },
                        tips = {
                            "First boss in Slave Pens - quick runs",
                            "Normal mode works fine for this drop",
                            "No reputation required",
                        },
                        alternatives = {
                            "Totem of Healing Rains (Maiden - Karazhan)",
                            "Totem of the Plains (Quest)",
                            "Totem of Life (25 Badges)",
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
                -- Alliance: Honor Hold bow
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "Best pre-raid bow for all Hunter specs", "+16 Hit helps reach ranged hit cap (9%)", "Weapon DPS is your most important stat" },
                        tips = { "Hellfire dungeons give rep even at 70", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                -- Horde: Thrallmar crossbow
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "Best pre-raid crossbow for all Hunter specs", "+16 Hit helps reach ranged hit cap (9%)", "Weapon DPS is your most important stat" },
                        tips = { "Hellfire dungeons give rep even at 70", "Shattered Halls Heroic is fastest", "Buy from Quartermaster Urgronn in Thrallmar" },
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
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = { "Heroic dungeons (1 badge per boss)", "Karazhan bosses (1-2 badges each)", "Gruul/Magtheridon (2 badges each)" },
                        statPriority = { "BiS pre-raid trinket for all physical DPS", "+72 permanent AP + 278 AP on use (2min CD)", "Pop with Bestial Wrath for massive burst" },
                        tips = { "Use on-use with Kill Command and Bestial Wrath", "Priority badge purchase for hunters", "Buy from G'eras in Shattrath (Terrace of Light)" },
                        alternatives = { "Hourglass of the Unraveller (H Black Morass)", "Abacus of Violent Odds (H Mechanar)", "Icon of Unyielding Courage (Quest)" },
                    },
                },
            },
            drops = {
                { itemId = 28275, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_12", quality = "rare", slot = "Chest", stats = "+32 Agi, +32 Sta, +25 Int", source = "Mana-Tombs (Normal)", sourceType = "drops" },
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
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
                -- Alliance: Honor Hold bow
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid bow for Marksmanship Hunter", "+16 Hit critical for Aimed Shot hits", "Weapon DPS directly affects Aimed Shot damage" },
                        tips = { "MM Hunters need more hit than BM", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                -- Horde: Thrallmar crossbow
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid crossbow for Marksmanship Hunter", "+16 Hit critical for Aimed Shot hits", "Weapon DPS directly affects Aimed Shot damage" },
                        tips = { "MM Hunters need more hit than BM", "Shattered Halls Heroic is fastest", "Buy from Quartermaster Urgronn in Thrallmar" },
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
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = { "Heroic dungeons (1 badge per boss)", "Karazhan bosses (1-2 badges each)", "Gruul/Magtheridon (2 badges each)" },
                        statPriority = { "BiS pre-raid trinket for Marksmanship", "+72 permanent AP + 278 AP on use (2min CD)", "Use with Rapid Fire for burst damage" },
                        tips = { "Stack with Rapid Fire and haste effects", "Priority badge purchase for hunters", "Buy from G'eras in Shattrath (Terrace of Light)" },
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
                -- Alliance: Honor Hold bow
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Honor Hold PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid bow for Survival Hunter", "+16 Hit critical for trap consistency", "Agility scales with Survival talents" },
                        tips = { "Survival benefits heavily from Agility", "Shattered Halls Heroic is fastest", "Buy from Logistics Officer Ulrike in Honor Hold" },
                        alternatives = { "Sunfury Bow of the Phoenix (Kael)", "Wrathtide Longbow (H Underbog)", "Steelhawk Crossbow (Quest)" },
                    },
                },
                -- Horde: Thrallmar crossbow
                { itemId = 29151, name = "Warsong Crossbow", icon = "INV_Weapon_Crossbow_10", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Thrallmar @ Revered", sourceType = "rep", faction = "Thrallmar", standing = 7,
                    hoverData = {
                        repSources = { "Hellfire Ramparts / Blood Furnace / Shattered Halls (10-25 rep/kill)", "Hellfire Peninsula quests (~8k rep)", "Marks of Thrallmar PvP turn-in (250 rep per mark)" },
                        statPriority = { "BiS pre-raid crossbow for Survival Hunter", "+16 Hit critical for trap consistency", "Agility scales with Survival talents" },
                        tips = { "Survival benefits heavily from Agility", "Shattered Halls Heroic is fastest", "Buy from Quartermaster Urgronn in Thrallmar" },
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
                        alternatives = { "Beast Lord Cuirass (Mana-Tombs)", "Fel Leather Vest (Leatherworking)", "Primalstrike Vest (Leatherworking)" },
                    },
                },
            },
            drops = {
                { itemId = 28034, name = "Hourglass of the Unraveller", icon = "INV_Misc_PocketWatch_01", quality = "rare", slot = "Trinket", stats = "+32 Hit, Haste proc", source = "Black Morass (Normal)", sourceType = "drops" },
                { itemId = 28275, name = "Beast Lord Cuirass", icon = "INV_Chest_Chain_12", quality = "rare", slot = "Chest", stats = "+32 Agi, +32 Sta, +25 Int", source = "Mana-Tombs (Normal)", sourceType = "drops" },
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
                        alternatives = { "Primalstrike Vest (Leatherworking)", "Clefthoof Hide Tunic (Crafted)", "Fel Leather Vest (Leatherworking)" },
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
                { itemId = 29383, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "G'eras (41 Badges)", sourceType = "badge",
                    hoverData = {
                        badgeSources = { "Heroic dungeons (1 badge per boss)", "Karazhan bosses (1-2 badges each)", "Gruul/Magtheridon (2 badges each)" },
                        statPriority = { "BiS on-use trinket for Combat burst", "+72 passive AP always active", "Use effect stacks with Blade Flurry + Adrenaline Rush" },
                        tips = { "Macro to Blade Flurry for cleave burst", "2 min cooldown syncs with major cooldowns", "Buy from G'eras in Shattrath (Terrace of Light)" },
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
                        alternatives = { "Primalstrike Vest (Leatherworking)", "Gladiator's Leather Tunic (Arena)", "Fel Leather Vest (Leatherworking)" },
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
-- GUILD SYSTEM CONSTANTS
--============================================================

-- Guild Hall theming
C.GUILD_HALL = {
    -- Header styling
    HEADER_HEIGHT = 50,
    MOTD_HEIGHT = 40,

    -- Member cards
    MEMBER_ROW_HEIGHT = 44,
    MEMBER_VISIBLE_ROWS = 10,

    -- Activity chronicles
    ACTIVITY_ROW_HEIGHT = 36,
    ACTIVITY_VISIBLE_ROWS = 5,
    MAX_ACTIVITY_ENTRIES = 100,
    ACTIVITY_RETENTION_DAYS = 7,

    -- Online thresholds (matches SOCIAL_TAB for consistency)
    ONLINE_THRESHOLD = 300,   -- 5 minutes
    AWAY_THRESHOLD = 900,     -- 15 minutes

    -- Roster refresh
    ROSTER_REFRESH_INTERVAL = 30,  -- seconds
}

-- Guild activity types (wire codes for storage)
C.GUILD_ACTIVITY_TYPES = {
    LOGIN = "LOGIN",
    LOGOUT = "LOGOUT",
    LEVELUP = "LEVELUP",
    ZONE = "ZONE",
    RANK = "RANK",
    JOIN = "JOIN",
    LEAVE = "LEAVE",
}

-- RP-flavored activity messages for Guild Chronicles
C.GUILD_ACTIVITY_MESSAGES = {
    LOGIN = "%s has entered the hall",
    LOGOUT = "%s has departed for distant lands",
    LEVELUP = "%s has grown stronger (Level %d)",
    ZONE = "%s ventures into %s",
    RANK = "%s has been promoted to %s",
    JOIN = "%s has joined the guild",
    LEAVE = "%s has left the guild",
}

-- Activity icons for Guild Chronicles
C.GUILD_ACTIVITY_ICONS = {
    LOGIN = "Interface\\Icons\\Spell_Holy_Resurrection",
    LOGOUT = "Interface\\Icons\\Spell_Shadow_Teleport",
    LEVELUP = "Interface\\Icons\\Spell_Holy_SurgeOfLight",
    ZONE = "Interface\\Icons\\INV_Misc_Map_01",
    RANK = "Interface\\Icons\\INV_Crown_02",
    JOIN = "Interface\\Icons\\Spell_Holy_AuraOfLight",
    LEAVE = "Interface\\Icons\\Ability_Vanish",
}

-- Activity border colors (themed to match addon)
C.GUILD_ACTIVITY_BORDERS = {
    LOGIN = { 0.2, 0.8, 0.2 },      -- Fel green
    LOGOUT = { 0.5, 0.5, 0.5 },     -- Grey
    LEVELUP = { 1.0, 0.84, 0 },     -- Gold
    ZONE = { 0.4, 0.6, 1.0 },       -- Light blue
    RANK = { 0.64, 0.21, 0.93 },    -- Epic purple
    JOIN = { 0.2, 0.8, 0.2 },       -- Fel green
    LEAVE = { 0.8, 0.2, 0.1 },      -- Hellfire red
}

-- Sort options for guild roster
C.GUILD_SORT_OPTIONS = {
    { id = "online", label = "Online First" },
    { id = "name", label = "Name (A-Z)" },
    { id = "rank", label = "Rank" },
    { id = "level", label = "Level (High-Low)" },
    { id = "class", label = "Class" },
}

-- Quick filter options for guild roster
C.GUILD_FILTERS = {
    { id = "all", label = "All" },
    { id = "online", label = "Online" },
}

-- Badge indicators for guild members
C.GUILD_BADGES = {
    GUILD_ONLY = { icon = "G", color = { 0.5, 0.8, 0.3 }, tooltip = "Guild Member" },
    FELLOW_ONLY = { icon = "F", color = { 0.61, 0.19, 1.0 }, tooltip = "Fellow Traveler" },
    BOTH = { icon = "GF", color = { 1.0, 0.84, 0 }, tooltip = "Guild Member with Addon" },
}

-- Default guild data structure (used by EnsureGuildData)
C.GUILD_DATA_DEFAULTS = {
    name = "",
    rank = "",
    rankIndex = 0,
    roster = {},
    activity = {},
    motd = "",
    lastRosterUpdate = 0,
    settings = {
        trackActivity = true,
        showOffline = true,
        sortBy = "online",
    },
}

--============================================================
-- SOCIAL TAB CONSTANTS
--============================================================

C.SOCIAL_TAB = {
    -- Tab bar
    TAB_WIDTH = 77,   -- Width to fit 6 tabs including "Buddy" label
    TAB_HEIGHT = 24,
    TAB_SPACING = 3,  -- Wider gaps for visual balance

    -- Status bar
    STATUS_BAR_HEIGHT = 36,
    RUMOR_INPUT_HEIGHT = 50,

    -- Guild Hall
    GUILD_HEADER_HEIGHT = 50,
    GUILD_MOTD_HEIGHT = 40,
    GUILD_ROW_HEIGHT = 44,
    GUILD_ACTIVITY_HEIGHT = 36,

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

    -- Guild Loot Board (Phase 62)
    LOOT_BOARD_MAX_VISIBLE = 10,
    LOOT_BOARD_ROW_HEIGHT = 48,
    LOOT_BOARD_HEADER_HEIGHT = 32,
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
    ROM = "Interface\\Icons\\Spell_Holy_SealOfRighteousness",  -- ROMANCE/OATH
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
    ROM = { 1, 0.65, 0 },            -- ROMANCE/OATH: Orange-Gold
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

C.RP_STATUS = {
    IC = { id = "IC", label = "In Character", color = "00FF00", icon = "Spell_Holy_MindVision" },
    OOC = { id = "OOC", label = "Out of Character", color = "808080", icon = "Spell_Nature_Sleep" },
    LF_RP = { id = "LF_RP", label = "Looking for RP", color = "FF33CC", icon = "INV_ValentinesCandy" },
}

--[[
    Oath System ("Sacred Oath Bond")
    Public, exclusive one-partner oath system
    RPG-friendly, gender-neutral bonding mechanic
]]
C.ROMANCE_STATUS = {
    SINGLE = {
        id = "SINGLE",
        label = "Unbound",
        color = "808080",
        icon = "Spell_Holy_SealOfWisdom",
        emoji = "",
    },
    PROPOSED = {
        id = "PROPOSED",
        label = "Oath Pending...",
        color = "FFD700",
        icon = "Spell_Holy_DivineIllumination",
        emoji = "✦",
    },
    DATING = {
        id = "DATING",
        label = "Oath-Bound",
        color = "FFA500",
        icon = "Spell_Holy_SealOfRighteousness",
        emoji = "✦",
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

-- Breakup reason display text (oath-themed)
C.BREAKUP_REASON_TEXT = {
    mutual = "The oath was dissolved by mutual consent.",
    grew_apart = "Their paths diverged.",
    found_another = "A new oath called to them.",
    its_not_you = "The oath could not be upheld.",
}

--[[
    Default Social Data Structure
    Used by Core.lua for migration and initialization
    All social.ui access should go through HopeAddon:GetSocialUI()
]]
C.SOCIAL_DATA_DEFAULTS = {
    -- UI State (persisted across sessions)
    ui = {
        activeTab = "guild",  -- Default to Guild Hall tab
        guild = {
            quickFilter = "all",
            searchText = "",
            sortOption = "online",
            showActivity = true,
        },
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
        calendar = {
            selectedMonth = nil,
            selectedYear = nil,
            selectedDay = nil,
        },
        notes = {},
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

    -- Calendar System
    calendar = {
        events = {},           -- [eventId] = event data
        mySignups = {},        -- [eventId] = signup status
        notifications = {},    -- pending notifications
        lastSync = 0,
        templates = {},        -- [templateId] = template data (saved event configs)
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
            color = "KARA_PURPLE",
            raids = { "Karazhan (10)", "Gruul's Lair (25)", "Magtheridon's Lair (25)" },
            gearSources = { "Raid Drops", "Heroic Dungeons", "Badge of Justice", "Reputation Rewards", "Crafted BoE" },
            recommendedILvl = "100-115",
        },
        [2] = {
            label = "2",
            tooltip = "Phase 2: Serpentshrine & Tempest Keep",
            color = "SSC_BLUE",
            raids = { "Serpentshrine Cavern (25)", "Tempest Keep: The Eye (25)" },
            gearSources = { "Raid Drops", "Heroic Badge Gear", "Nether Vortex Crafting" },
            recommendedILvl = "115-128",
        },
        [3] = {
            label = "3",
            tooltip = "Phase 3: Hyjal & Black Temple",
            color = "BT_FEL",
            raids = { "Hyjal Summit (25)", "Black Temple (25)" },
            gearSources = { "Raid Drops", "Hearts of Darkness Crafting" },
            recommendedILvl = "128-141",
        },
        [4] = {
            label = "4",
            tooltip = "Phase 4: Zul'Aman",
            color = "ZA_TRIBAL",
            raids = { "Zul'Aman (10)" },
            gearSources = { "Raid Drops", "Bear Run Loot" },
            recommendedILvl = "128-138",
        },
        [5] = {
            label = "5",
            tooltip = "Phase 5: Sunwell Plateau",
            color = "SUNWELL_GOLD",
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

--============================================================
-- ATTUNEMENT PHASE BUTTON CONFIGURATION
--============================================================

-- Phase bar container for Attunements tab
C.ATTUNEMENT_PHASE_BAR = {
    HEIGHT = 32,
    PADDING_H = 10,
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
}

-- Attunement Phase Button Configuration
C.ATTUNEMENT_PHASE_BUTTON = {
    WIDTH = 38,
    HEIGHT = 24,
    GAP = 4,
    FIRST_OFFSET = 60,  -- After "PHASE" label
    FONT = "GameFontNormal",
    FONT_SIZE = 11,
    PHASES = {
        [0] = {
            label = "All",
            tooltip = "Show All Attunements",
            color = "ARCANE_PURPLE",
            attunements = {},  -- Shows all
        },
        [1] = {
            label = "1",
            tooltip = "Phase 1: Karazhan",
            color = "KARA_PURPLE",
            attunements = { "karazhan" },
        },
        [2] = {
            label = "2",
            tooltip = "Phase 2: SSC & Tempest Keep",
            color = "SSC_BLUE",
            attunements = { "ssc", "tk", "cipher" },
        },
        [3] = {
            label = "3",
            tooltip = "Phase 3: Hyjal & Black Temple",
            color = "BT_FEL",
            attunements = { "hyjal", "bt" },
        },
    },
    STATES = {
        active = { bgAlpha = 0.5, borderAlpha = 1.0, textAlpha = 1.0, showGlow = true },
        inactive = { bgAlpha = 0.15, borderAlpha = 0.4, textAlpha = 0.6, showGlow = false },
        hover = { bgAlpha = 0.35, borderAlpha = 0.8, textAlpha = 0.9, showGlow = false },
    },
}

-- Returns the phase color name for a given item level
-- Uses boundary-based logic (higher phases take priority at boundaries)
function C:GetPhaseColorForItemLevel(iLvl)
    if not iLvl or iLvl < 100 then
        return nil  -- Pre-raid gear, use default gray
    elseif iLvl >= 141 then
        return "SUNWELL_GOLD"   -- Phase 5
    elseif iLvl >= 128 then
        return "BT_FEL"         -- Phase 3 (skip Phase 4 ZA catch-up)
    elseif iLvl >= 115 then
        return "SSC_BLUE"       -- Phase 2
    else
        return "KARA_PURPLE"    -- Phase 1 (100-114)
    end
end

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

-- Gear popup (floating popup near clicked slot) - Redesigned Phase 61
C.ARMORY_GEAR_POPUP = {
    -- Dimensions (expanded for filter cards)
    WIDTH = 640,
    MAX_HEIGHT = 680,
    MIN_HEIGHT = 480,  -- Increased from 360 to ensure scroll area of at least ~2.5 items visible

    -- Section heights
    HEADER_HEIGHT = 40,
    BIS_SECTION_HEIGHT = 100,      -- BiS showcase card
    FILTER_SECTION_HEIGHT = 120,   -- Compact: 3 rows @ 28px + header + minimal gaps
    SCROLL_CONTENT_PADDING = 8,
    FOOTER_HEIGHT = 36,

    -- Filter card specifications (Phase 61, compacted Phase 66)
    FILTER_CARD = {
        WIDTH = 180,
        HEIGHT = 28,               -- Reduced from 52 (single-line compact)
        ICON_SIZE = 22,            -- Reduced from 36
        COLUMNS = 3,
        GAP = 4,                   -- Reduced from 12
        ACTIVE_GLOW = 0.6,
    },

    -- Item row styling
    ITEM_HEIGHT = 48,              -- Reduced from 54 to match smaller icons
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
        ICON_SIZE = 52,            -- Reduced from 56 to allow larger border
        BORDER_OFFSET = 8,         -- 52 + 8 = 60px border (15% ratio for visible quality color)
        BORDER_COLOR = { r = 1, g = 0.84, b = 0 },      -- Gold
        GLOW_COLOR = { r = 1, g = 0.84, b = 0, a = 0.3 },
        NAME_FONT = "GameFontNormalLarge",
        STATS_FONT = "GameFontNormal",
    },

    -- Compact item row styling (for alternatives list)
    ITEM = {
        ICON_SIZE = 36,            -- Reduced from 40 to allow larger border
        BORDER_OFFSET = 6,         -- 36 + 6 = 42px border (17% ratio for visible quality color)
        BIS_INDICATOR_SIZE = 16,   -- Reduced from 18
        BIS_COLOR = { r = 1, g = 0.84, b = 0 },  -- Gold star for BiS
        NAME_FONT = "GameFontNormal",
        SOURCE_FONT = "GameFontNormalSmall",
        ILEVEL_FONT = "GameFontNormalSmall",
        HOVER_BG = { r = 0.3, g = 0.3, b = 0.3, a = 0.3 },
    },

    -- Filter card styling (Phase 61 redesign)
    FILTER = {
        -- Card appearance
        ACTIVE_BORDER = { r = 0.8, g = 0.7, b = 0.2, a = 1 },     -- Gold border when active
        INACTIVE_BORDER = { r = 0.3, g = 0.3, b = 0.3, a = 0.6 }, -- Grey border when inactive
        ACTIVE_BG = { r = 0.2, g = 0.2, b = 0.15, a = 0.9 },      -- Slightly lit background
        INACTIVE_BG = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },     -- Dark background
        DIMMED_ALPHA = 0.4,                                        -- Alpha for zero-count cards
        HOVER_ALPHA = 0.7,                                         -- Alpha for hover state on inactive
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
    },
    INDICATOR_ICONS = {
        bis       = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "★" },
        ok        = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "✓" },
        minor     = { icon = "Interface\\BUTTONS\\UI-MicroStream-Green", symbol = "↑" },
        upgrade   = { icon = "Interface\\BUTTONS\\UI-MicroStream-Yellow", symbol = "↑↑" },
        major     = { icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew", symbol = "!!" },
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

-- Slot info cards (60x44px "Upgrade Banners" showing iLvl + delta + chevron)
C.ARMORY_INFO_CARD = {
    WIDTH = 60,           -- Expanded from 44px for better readability
    HEIGHT = 44,          -- Same height as slot
    GAP = 4,              -- Gap from slot button

    -- Content layout
    ILVL_FONT = "GameFontNormalLarge",
    DELTA_FONT = "GameFontNormalSmall",
    CHEVRON_SIZE = 14,    -- Click indicator "›" size
    STAR_SIZE = 14,       -- BiS star icon size

    -- Rank-based colors using WoW item quality (brighter for visibility)
    -- #1 = BiS (bright gold), #2 = Epic purple, #3-5 = Rare blue, #6+ = Uncommon green, nil = Muted grey
    RANK_COLORS = {
        [1] = { r = 1.00, g = 0.84, b = 0.00 },  -- GOLD (bright, matches Battleship victory)
        [2] = { r = 0.64, g = 0.21, b = 0.93 },  -- EPIC (purple) - 2nd best
        [3] = { r = 0.00, g = 0.44, b = 0.87 },  -- RARE (blue) - good alternatives
        [4] = { r = 0.00, g = 0.44, b = 0.87 },  -- RARE (blue)
        [5] = { r = 0.00, g = 0.44, b = 0.87 },  -- RARE (blue)
        DEFAULT = { r = 0.12, g = 1.00, b = 0.00 },  -- UNCOMMON (green) for rank 6+
        NONE = { r = 0.6, g = 0.6, b = 0.6 },       -- MUTED grey for not on list (not white - too bright)
    },

    -- Visual style - RPG parchment theme with colorizable gold border
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",  -- More colorizable than Tooltip-Border
        edgeSize = 12,  -- Increased from 8 for visibility
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    BG_COLOR = { r = 0.08, g = 0.06, b = 0.04, a = 0.9 },
    BORDER_COLOR = { r = 0.6, g = 0.5, b = 0.2, a = 0.8 },
    HIGHLIGHT_COLOR = { r = 1.0, g = 0.84, b = 0.0, a = 1.0 },  -- Bright gold on hover

    -- Glow overlay for hover effect
    GLOW_INTENSITY = 0.6,

    -- iLvl vs Average thresholds for grade system
    -- Compares slot iLvl to player's average equipped iLvl
    THRESHOLD_EXCELLENT = 10,   -- >=+10 above average (epic purple)
    THRESHOLD_GOOD = 3,         -- +3 to +9 above average (rare blue)
    THRESHOLD_UPGRADE = -3,     -- -3 to -9 below average (common white)
    THRESHOLD_URGENT = -10,     -- <=-10 below average (poor grey/red)
    -- Note: -2 to +2 = OKAY (uncommon green)

    -- Grade indicator icons and colors (traffic light style)
    -- Uses WoW's built-in indicator textures with vertex coloring
    GRADE_ICONS = {
        EXCELLENT = {
            icon = "Interface\\COMMON\\Indicator-Green",  -- Will be recolored purple
            color = { r = 0.64, g = 0.21, b = 0.93 },     -- Epic purple
        },
        GOOD = {
            icon = "Interface\\COMMON\\Indicator-Green",  -- Will be recolored blue
            color = { r = 0.00, g = 0.70, b = 1.00 },     -- Bright blue
        },
        OKAY = {
            icon = "Interface\\COMMON\\Indicator-Green",  -- Native green
            color = { r = 0.12, g = 1.00, b = 0.00 },     -- Uncommon green
        },
        UPGRADE = {
            icon = "Interface\\COMMON\\Indicator-Yellow", -- Native yellow
            color = { r = 1.00, g = 0.82, b = 0.00 },     -- Yellow/gold
        },
        URGENT = {
            icon = "Interface\\COMMON\\Indicator-Red",    -- Native red
            color = { r = 1.00, g = 0.20, b = 0.20 },     -- Bright red
        },
    },

    -- Card position offsets by slot (relative to slot button)
    -- LEFT column slots: cards extend LEFT (negative X)
    -- RIGHT column slots: cards extend RIGHT (positive X)
    -- WEAPON slots: cards extend DOWN (negative Y)
    POSITIONS = {
        -- LEFT column: extend LEFT (card RIGHT edge anchors to slot LEFT edge)
        head      = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },
        neck      = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },
        shoulders = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },
        back      = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },
        chest     = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },
        wrist     = { anchor = "RIGHT", relAnchor = "LEFT", x = -4, y = 0 },

        -- RIGHT column: extend RIGHT (card LEFT edge anchors to slot RIGHT edge)
        hands     = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        waist     = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        legs      = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        feet      = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        ring1     = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        ring2     = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        trinket1  = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },
        trinket2  = { anchor = "LEFT", relAnchor = "RIGHT", x = 4, y = 0 },

        -- Weapons: extend DOWN (card TOP anchors to slot BOTTOM)
        mainhand  = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -4 },
        offhand   = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -4 },
        ranged    = { anchor = "TOP", relAnchor = "BOTTOM", x = 0, y = -4 },
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
    PHASE_COLOR = { r = 0.3, g = 0.8, b = 1.0, a = 1 },  -- Cyan for phase indicator
    DIVIDER_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 1 }, -- Grey dividers between stats
    LAYOUT = {
        STATS_RIGHT_MARGIN = 15,
        STAT_GAP = 16,
    },
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
    RANK_BADGE_WIDTH = 45,
    RANK_BADGE_HEIGHT = 18,
    RANK_COLORS = {
        BEST = { bg = { r = 1, g = 0.84, b = 0 }, text = { r = 0.1, g = 0.1, b = 0.1 } },
        ALT  = { bg = { r = 0.5, g = 0.5, b = 0.5 }, text = { r = 1, g = 1, b = 1 } },
    },
    UPGRADE_BADGE_WIDTH = 50,
    UPGRADE_BADGE_HEIGHT = 20,
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

-- Issue #71.4: Boss Loot Popup constants (used by Journal.lua boss loot pools)
C.BOSS_LOOT_POPUP = {
    -- Dimensions
    WIDTH = 380,
    MIN_HEIGHT = 200,
    MAX_HEIGHT = 450,
    HEADER_HEIGHT = 44,
    INFO_SECTION_HEIGHT = 50,
    FOOTER_HEIGHT = 28,
    PADDING = 12,
    ROW_HEIGHT = 44,
    ROW_GAP = 4,
    ICON_SIZE = 36,
    BIS_STAR_SIZE = 14,
    BIS_COLOR = { r = 1, g = 0.84, b = 0 },  -- Gold star for BiS

    -- Backdrop styling
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    BG_COLOR = { r = 0.08, g = 0.06, b = 0.04, a = 0.95 },
    BORDER_COLOR = { r = 0.8, g = 0.7, b = 0.3, a = 1 },

    -- Quality colors for loot items
    QUALITY_COLORS = {
        common = { r = 0.62, g = 0.62, b = 0.62 },
        uncommon = { r = 0.12, g = 1.0, b = 0.0 },
        rare = { r = 0.0, g = 0.44, b = 0.87 },
        epic = { r = 0.64, g = 0.21, b = 0.93 },
        legendary = { r = 1.0, g = 0.5, b = 0.0 },
    },
}

-- Reputation Loot Popup (similar to boss loot popup)
C.REPUTATION_LOOT_POPUP = {
    -- Dimensions
    WIDTH = 400,
    MIN_HEIGHT = 250,
    MAX_HEIGHT = 500,
    HEADER_HEIGHT = 50,
    TIER_HEADER_HEIGHT = 24,
    FOOTER_HEIGHT = 32,
    PADDING = 12,
    ROW_HEIGHT = 40,
    ROW_GAP = 3,
    ICON_SIZE = 32,
    CHECKBOX_SIZE = 20,
    TRACKED_STAR_SIZE = 14,
    GOAL_COLOR = { r = 1, g = 0.84, b = 0 },  -- Gold for goal item

    -- Backdrop styling
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    BG_COLOR = { r = 0.08, g = 0.06, b = 0.04, a = 0.95 },
    BORDER_COLOR = { r = 0.8, g = 0.7, b = 0.3, a = 1 },

    -- Quality colors for loot items
    QUALITY_COLORS = {
        [0] = { r = 0.62, g = 0.62, b = 0.62 },  -- Poor (grey)
        [1] = { r = 1.0, g = 1.0, b = 1.0 },     -- Common (white)
        [2] = { r = 0.12, g = 1.0, b = 0.0 },    -- Uncommon (green)
        [3] = { r = 0.0, g = 0.44, b = 0.87 },   -- Rare (blue)
        [4] = { r = 0.64, g = 0.21, b = 0.93 },  -- Epic (purple)
        [5] = { r = 1.0, g = 0.5, b = 0.0 },     -- Legendary (orange)
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
                    { itemId = 29388, name = "Libram of Repentance", icon = "INV_Relics_LibramofGrace", quality = "epic", iLvl = 110, stats = "+Block Value", source = "Badge Vendor", sourceType = "badge", badgeCost = 15, weaponType = "libram" },
                    { itemId = 28990, name = "Idol of the Raven Goddess", icon = "INV_Relics_IdolofFerocity", quality = "rare", iLvl = 115, stats = "+AP in cat/bear", source = "Sethekk Halls", sourceType = "dungeon", sourceDetail = "Sethekk Halls", weaponType = "idol" },
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
                    { itemId = 31329, name = "Lifegiving Cloak", icon = "INV_Misc_Cape_17", quality = "epic", iLvl = 110, stats = "+15 Int, +40 Healing", source = "World Drop", sourceType = "world" },
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
                    { itemId = 27538, name = "Epoch-Mender", icon = "INV_Mace_40", quality = "rare", iLvl = 115, stats = "+20 Int, +48 Healing, +7 mp5", source = "Temporus", sourceType = "dungeon", sourceDetail = "Black Morass" },
                    { itemId = 27772, name = "Hammer of the Penitent", icon = "INV_Mace_42", quality = "rare", iLvl = 112, stats = "+18 Int, +42 Healing", source = "Blackheart the Inciter", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                },
            },
            ["offhand"] = {
                best = { itemId = 29458, name = "Aegis of the Vindicator", icon = "INV_Shield_32", quality = "epic", iLvl = 120, stats = "+18 Int, +48 Healing", source = "Magtheridon", sourceType = "raid", sourceDetail = "Magtheridon's Lair" },
                alternatives = {
                    { itemId = 27477, name = "Faol's Signet of Cleansing", icon = "INV_Jewelry_Talisman_10", quality = "rare", iLvl = 115, stats = "+15 Int, +40 Healing", source = "Murmur", sourceType = "heroic", sourceDetail = "Heroic Shadow Labyrinth" },
                    { itemId = 28753, name = "Triptych Shield of the Ancients", icon = "INV_Shield_35", quality = "epic", iLvl = 115, stats = "+15 Int, +40 Healing, +7 mp5", source = "Chess Event", sourceType = "raid", sourceDetail = "Karazhan" },
                    { itemId = 29274, name = "Lamp of Peaceful Radiance", icon = "INV_Offhand_1h_Draenei_A_01", quality = "rare", iLvl = 105, stats = "+12 Int, +33 Healing, +8 mp5", source = "G'eras", sourceType = "badge", badgeCost = 35 },
                },
            },
            ["ranged"] = {
                best = { itemId = 28592, name = "Libram of Souls Redeemed", icon = "INV_Relics_LibramofHope", quality = "epic", iLvl = 115, stats = "+Healing to Flash of Light", source = "Opera Event", sourceType = "raid", sourceDetail = "Karazhan", weaponType = "libram" },
                alternatives = {
                    { itemId = 28296, name = "Libram of the Lightbringer", icon = "INV_Relics_LibramofGrace", quality = "rare", iLvl = 115, stats = "+Healing to Holy Light", source = "Botanica (Normal)", sourceType = "dungeon", weaponType = "libram" },
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
                best = { itemId = 28438, name = "Dragonmaw", icon = "INV_Sword_59", quality = "epic", iLvl = 115, stats = "+Str, +Agi", source = "Blacksmithing", sourceType = "crafted" },
                alternatives = {
                    { itemId = 28295, name = "Gladiator's Slicer", icon = "INV_Sword_58", quality = "epic", iLvl = 115, stats = "+Sta, +Crit", source = "Arena Season 1", sourceType = "pvp" },
                    { itemId = 31332, name = "Blinkstrike", icon = "INV_Sword_57", quality = "epic", iLvl = 115, stats = "+Agi, Teleport proc", source = "World Drop", sourceType = "world" },
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
                    { itemId = 27484, name = "Libram of Avengement", icon = "INV_Relics_LibramofTruth", quality = "rare", iLvl = 115, stats = "+Crit Rating", source = "The Maker (Blood Furnace)", sourceType = "dungeon", weaponType = "libram" },
                    -- Druid alternative (idol)
                    { itemId = 28064, name = "Idol of the Wild", icon = "INV_Relics_IdolofFerocity", quality = "epic", iLvl = 115, stats = "+AP proc", source = "Heroic Mana-Tombs", sourceType = "heroic", weaponType = "idol" },
                    -- Shaman alternative (totem)
                    { itemId = 27815, name = "Totem of the Astral Winds", icon = "INV_Relics_Totem04", quality = "rare", iLvl = 115, stats = "+AP", source = "Pandemonius (Mana-Tombs)", sourceType = "dungeon", weaponType = "totem" },
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
                    { itemId = 25686, name = "Boots of the Endless Hunt", icon = "INV_Boots_Chain_08", quality = "rare", iLvl = 110, stats = "+24 Agi, +22 Sta, +18 Hit", source = "G'eras", sourceType = "badge", badgeCost = 60 },
                    { itemId = 29791, name = "Boots of the Crimson Hawk", icon = "INV_Boots_Chain_07", quality = "epic", iLvl = 115, stats = "+26 Agi, +24 Sta, +52 AP", source = "Quest: The Tempest Key", sourceType = "quest", sourceDetail = "Tempest Key Quest Chain" },
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

-- ============================================================================
-- CALENDAR SYSTEM CONSTANTS
-- ============================================================================

C.CALENDAR_TIMINGS = {
    MAX_EVENTS_PER_PLAYER = 10,
    MAX_DESCRIPTION_LENGTH = 200,
    NOTIFICATION_CHECK_INTERVAL = 60,  -- seconds
    NOTIFICATION_1HR = 3600,           -- 1 hour in seconds
    NOTIFICATION_15MIN = 900,          -- 15 min in seconds
    EVENT_EXPIRY_HOURS = 720,          -- 30 days after event ends (720 hours)
    MAX_TEMPLATES = 10,                -- max saved templates per character
}

C.CALENDAR_MSG = {
    EVENT_CREATE = "CAL_CREATE",
    EVENT_UPDATE = "CAL_UPDATE",
    EVENT_DELETE = "CAL_DELETE",
    SIGNUP = "CAL_SIGNUP",
    SIGNUP_UPDATE = "CAL_SIGNUP_UPD",
}

C.CALENDAR_UI = {
    CELL_WIDTH = 68,
    CELL_HEIGHT = 55,
    CELL_SPACING = 2,
    GRID_COLS = 7,
    GRID_ROWS = 6,
    EVENT_CARD_HEIGHT = 50,            -- Increased for color stripe
    EVENT_CARD_SPACING = 4,
    DAY_PANEL_HEIGHT = 200,
    DETAIL_POPUP_WIDTH = 420,          -- Wider for info cards layout
    DETAIL_POPUP_HEIGHT = 500,         -- Taller for improved sections
    CREATE_POPUP_WIDTH = 400,
    CREATE_POPUP_HEIGHT = 560,         -- Taller for template dropdown
    DAY_NAMES = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" },
    MONTH_NAMES = { "January", "February", "March", "April", "May", "June",
                   "July", "August", "September", "October", "November", "December" },
}

-- Calendar slot-based event indicators (colored squares in day cells)
C.CALENDAR_SLOT_UI = {
    SLOT_SIZE = 10,           -- 10x10px squares
    SLOT_SPACING = 2,         -- Gap between squares
    SERVER_SLOTS = 2,         -- Hardcoded event slots (top row)
    GUILD_SLOTS = 2,          -- Guild event slots (bottom row)
    SERVER_ROW_Y = 14,        -- Y offset from slot container bottom for server row
    GUILD_ROW_Y = 2,          -- Y offset from slot container bottom for guild row
    OVERFLOW_FONT_SIZE = 8,   -- Font size for "+N" overflow indicator
}

-- Mini event cards for calendar day cells
-- Each event displays as a small horizontal card with icon, time, and title
C.CALENDAR_MINI_CARD = {
    WIDTH = 60,               -- Card width in pixels
    HEIGHT = 14,              -- Card height in pixels
    ICON_SIZE = 10,           -- Event type icon size
    STRIPE_WIDTH = 3,         -- Left color stripe width
    TIME_WIDTH = 28,          -- Width allocated for time text
    SPACING = 1,              -- Vertical spacing between cards
    MAX_VISIBLE = 6,          -- Max cards before showing overflow
    BASE_CELL_HEIGHT = 30,    -- Day number + padding (minimum)
    MAX_CELL_HEIGHT = 110,    -- Maximum cell height
}

-- Event priority for display order in calendar cells
-- Lower number = higher priority (shown first)
C.CALENDAR_EVENT_PRIORITY = {
    SERVER = 1,               -- Server events always first
    RAID = 2,                 -- Raids second
    DUNGEON = 3,              -- Dungeons third
    RP_EVENT = 4,             -- RP events fourth
    OTHER = 5,                -- Everything else last
}

-- Continuous week calendar view settings
C.CALENDAR_WEEK_VIEW = {
    WEEK_ROW_HEIGHT = 70,     -- Height of each week row
    WEEKS_TO_SHOW = 8,        -- Number of weeks to display
    DAY_CELL_WIDTH = 68,      -- Width of each day cell in week view
    DAY_CELL_SPACING = 2,     -- Spacing between cells
    SCROLL_HEIGHT = 500,      -- Scroll frame height
}

-- Day events popup dimensions (shown when clicking a day)
C.CALENDAR_DAY_POPUP = {
    WIDTH = 320,
    HEIGHT = 350,
    EVENT_CARD_HEIGHT = 50,
    EVENT_CARD_SPACING = 4,
}

-- Unified day popup dimensions (master-detail view)
C.CALENDAR_UNIFIED_POPUP = {
    WIDTH = 680,
    HEIGHT = 520,
    LEFT_PANEL_WIDTH = 220,
    DIVIDER_WIDTH = 2,
    RIGHT_PANEL_WIDTH = 440,
    EVENT_CARD_HEIGHT = 60,
    EVENT_CARD_SPACING = 4,
}

-- Month header colors for first-of-month display
C.CALENDAR_MONTH_COLORS = {
    [1]  = { r = 0.7, g = 0.85, b = 1.0, name = "January" },     -- Icy blue (winter)
    [2]  = { r = 1.0, g = 0.4, b = 0.6, name = "February" },     -- Pink (love)
    [3]  = { r = 0.4, g = 0.9, b = 0.4, name = "March" },        -- Green (spring)
    [4]  = { r = 0.6, g = 0.8, b = 1.0, name = "April" },        -- Light blue (rain)
    [5]  = { r = 1.0, g = 0.95, b = 0.4, name = "May" },         -- Yellow (flowers)
    [6]  = { r = 1.0, g = 0.6, b = 0.2, name = "June" },         -- Orange (summer)
    [7]  = { r = 1.0, g = 0.3, b = 0.3, name = "July" },         -- Red (hot)
    [8]  = { r = 1.0, g = 0.7, b = 0.0, name = "August" },       -- Golden (harvest)
    [9]  = { r = 0.8, g = 0.5, b = 0.2, name = "September" },    -- Brown (autumn)
    [10] = { r = 1.0, g = 0.5, b = 0.0, name = "October" },      -- Orange (halloween)
    [11] = { r = 0.6, g = 0.4, b = 0.2, name = "November" },     -- Brown (thanksgiving)
    [12] = { r = 0.3, g = 0.6, b = 0.9, name = "December" },     -- Blue (winter)
}

C.CALENDAR_EVENT_TYPES = {
    RAID = { name = "Raid", icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal" },
    DUNGEON = { name = "Dungeon", icon = "Interface\\Icons\\INV_Misc_Key_10" },
    RP_EVENT = { name = "RP Event", icon = "Interface\\Icons\\INV_Drink_02" },
    OTHER = { name = "Other", icon = "Interface\\Icons\\INV_Misc_Note_01" },
    SERVER = { name = "Server Event", icon = "Interface\\Icons\\INV_Misc_Note_06" },
}

-- Event Type Color Coding for calendar grid and cards
C.CALENDAR_EVENT_COLORS = {
    RAID = { r = 1.0, g = 0.5, b = 0.0 },      -- Orange
    DUNGEON = { r = 0.0, g = 0.7, b = 1.0 },   -- Blue
    RP_EVENT = { r = 0.8, g = 0.2, b = 0.8 },  -- Purple
    OTHER = { r = 0.6, g = 0.6, b = 0.6 },     -- Grey
    SERVER = { r = 1.0, g = 0.84, b = 0.0 },   -- Gold (legendary)
}

C.CALENDAR_ROLES = {
    tank = { name = "Tank", color = { r = 0.2, g = 0.5, b = 1.0 } },
    healer = { name = "Healer", color = { r = 0.2, g = 0.8, b = 0.2 } },
    dps = { name = "DPS", color = { r = 0.8, g = 0.2, b = 0.2 } },
}

C.CALENDAR_RAID_OPTIONS = {
    -- TBC Raids
    { name = "Karazhan (10-man)", key = "karazhan", size = 10, eventType = "RAID" },
    { name = "Gruul's Lair (25-man)", key = "gruul", size = 25, eventType = "RAID" },
    { name = "Magtheridon's Lair (25-man)", key = "magtheridon", size = 25, eventType = "RAID" },
    { name = "Serpentshrine Cavern (25-man)", key = "ssc", size = 25, eventType = "RAID" },
    { name = "Tempest Keep (25-man)", key = "tk", size = 25, eventType = "RAID" },
    { name = "Hyjal Summit (25-man)", key = "hyjal", size = 25, eventType = "RAID" },
    { name = "Black Temple (25-man)", key = "bt", size = 25, eventType = "RAID" },
    { name = "Zul'Aman (10-man)", key = "za", size = 10, eventType = "RAID" },
    { name = "Sunwell Plateau (25-man)", key = "sunwell", size = 25, eventType = "RAID" },
    -- Dungeon Options
    { name = "Dungeon Spamming (5-man)", key = "dungeon_spam", size = 5, eventType = "DUNGEON" },
    { name = "Character Leveling (5-man)", key = "char_leveling", size = 5, eventType = "DUNGEON" },
    -- Custom
    { name = "Custom Event", key = "custom", eventType = "OTHER" },
}

C.CALENDAR_RAID_SIZES = {
    [10] = { maxPlayers = 10, defaultTanks = 2, defaultHealers = 2, defaultDPS = 6 },
    [25] = { maxPlayers = 25, defaultTanks = 3, defaultHealers = 6, defaultDPS = 16 },
}

C.CALENDAR_SIGNUP_STATUS = {
    ACCEPTED = { name = "Accepted", icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready" },
    DECLINED = { name = "Declined", icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady" },
    TENTATIVE = { name = "Tentative", icon = "Interface\\RAIDFRAME\\ReadyCheck-Waiting" },
    PENDING = { name = "Pending", icon = "Interface\\Icons\\INV_Misc_QuestionMark" },
}

-- Custom event color presets for calendar events
C.CALENDAR_EVENT_COLOR_PRESETS = {
    { name = "Default", key = "default" },  -- Uses event type color
    { name = "Orange", key = "orange", color = { r = 1.0, g = 0.5, b = 0.0 } },
    { name = "Blue", key = "blue", color = { r = 0.0, g = 0.7, b = 1.0 } },
    { name = "Purple", key = "purple", color = { r = 0.8, g = 0.2, b = 0.8 } },
    { name = "Green", key = "green", color = { r = 0.2, g = 0.8, b = 0.2 } },
    { name = "Red", key = "red", color = { r = 0.8, g = 0.2, b = 0.2 } },
    { name = "Gold", key = "gold", color = { r = 1.0, g = 0.84, b = 0.0 } },
    { name = "Teal", key = "teal", color = { r = 0.0, g = 0.8, b = 0.6 } },
}

-- Roster status for finalized event rosters (set by event creator)
C.CALENDAR_ROSTER_STATUS = {
    TEAM = { name = "In Team", color = { r = 0.2, g = 0.8, b = 0.2 }, icon = "+" },
    ALTERNATE = { name = "Alternate", color = { r = 1.0, g = 0.84, b = 0.0 }, icon = "~" },
    DECLINED = { name = "Declined", color = { r = 0.8, g = 0.2, b = 0.2 }, icon = "-" },
}

-- ============================================================================
-- CALENDAR VALIDATION CONSTANTS
-- ============================================================================

C.CALENDAR_VALIDATION = {
    MIN_NOTICE_MINUTES = 30,        -- Events must be 30+ min in future
    MAX_FUTURE_DAYS = 60,           -- Max 60 days in advance
    ALLOW_PAST_EVENTS = false,      -- Prevent past date events
    ENFORCE_ROLE_LIMITS = true,     -- Enforce tank/healer/dps caps
    ENFORCE_RAID_SIZE = true,       -- Enforce total raid size
    -- Note: Signup limits removed - time conflicts shown as warnings only
}

-- ============================================================================
-- SERVER EVENTS (Hardcoded, read-only announcements)
-- ============================================================================

--[[
    Server Events are hardcoded, read-only events for server-wide announcements.
    - No signups - these are informational only
    - Everyone sees the same events (no network sync needed)
    - Gold/legendary color coding
    - Updated by addon maintainer ~2 weeks in advance

    Data format:
    {
        id = "unique_id",           -- Unique identifier
        title = "Event Name",       -- Display title
        eventType = "SERVER",       -- Always "SERVER"
        date = "YYYY-MM-DD",        -- Date string
        startTime = "HH:MM",        -- Start time (or "All Day" for all-day events)
        description = "...",        -- Event description (no length limit)
        icon = "Icon_Name",         -- Icon texture path (full path)
        permanent = false,          -- true = repeating yearly, false = one-time
        backgroundTexture = "...",  -- (Optional) Texture path for themed day background
        themeColor = { r, g, b },   -- (Optional) Theme color for border/tint
    }
]]
C.SERVER_EVENTS = {
    -- Example: Dark Portal opening (historical for flavor)
    {
        id = "dark_portal_opening",
        title = "The Dark Portal Opens",
        eventType = "SERVER",
        date = "2026-02-05",
        startTime = "00:01",
        description = "The Dark Portal has reopened! Journey through to Outland awaits all heroes of Azeroth. Speak with your faction's representative in the Blasted Lands to begin your adventure.",
        icon = "Interface\\Icons\\Spell_Arcane_PortalUndercity",
        permanent = false,
        backgroundTexture = "Interface\\Icons\\Spell_Arcane_PortalUndercity",
        themeColor = { r = 0.4, g = 0.8, b = 0.2 },  -- Fel green
    },
    -- Test event for verifying server event display (remove after testing)
    {
        id = "test_server_2026",
        title = "Server Maintenance",
        eventType = "SERVER",
        date = "2026-02-04",  -- First Tuesday of Feb 2026
        startTime = "07:00",
        description = "Weekly server maintenance. Expect approximately 2 hours of downtime.",
        icon = "Interface\\Icons\\Spell_Holy_Resurrection",
        permanent = false,
        backgroundTexture = "Interface\\Icons\\Spell_Holy_Resurrection",
        themeColor = { r = 1, g = 0.84, b = 0 },  -- Gold
    },
    -- Add future server events here as needed
    -- Example format for a future event:
    -- {
    --     id = "burning_legion_invasion",
    --     title = "Burning Legion Assault",
    --     eventType = "SERVER",
    --     date = "2007-03-15",
    --     startTime = "All Day",
    --     description = "The Burning Legion has launched an assault on Outland! Defend Shattrath and the surrounding zones.",
    --     icon = "Interface\\Icons\\Spell_Fire_FelFlameRing",
    --     permanent = false,
    -- },
}

-- Helper function to get server events for a specific date
function C:GetServerEventsForDate(dateStr)
    local events = {}
    for _, event in ipairs(C.SERVER_EVENTS) do
        if event.date == dateStr then
            table.insert(events, event)
        end
    end
    return events
end

-- Helper function to check if an event is a server event
function C:IsServerEvent(event)
    return event and event.eventType == "SERVER"
end

-- ============================================================================
-- APP-WIDE MILESTONE EVENTS (Banner Events)
-- ============================================================================

--[[
    App-Wide Events are major milestone announcements displayed as banners
    at the top of the calendar. These support multi-day spans and themed colors.

    - Displayed as colored banners above the calendar grid
    - Can span multiple days (endDate optional for single-day)
    - Themed colors for visual distinction
    - Everyone sees the same events (no network sync needed)

    Data format:
    {
        id = "unique_id",           -- Unique identifier
        title = "Event Name",       -- Display title (keep short for banner)
        description = "...",        -- Full description for tooltip
        startDate = "YYYY-MM-DD",   -- Start date
        endDate = "YYYY-MM-DD",     -- End date (optional, defaults to startDate)
        time = "HH:MM",             -- Start time (or "WEEKLY_RESET" for reset events)
        colorName = "COLOR_KEY",    -- Key from APP_WIDE_EVENT_COLORS
        icon = "IconPath",          -- Full icon path
    }
]]
C.APP_WIDE_EVENTS = {
    {
        id = "app_dark_portal",
        title = "The Dark Portal Opens",
        description = "Step through the Dark Portal and begin your journey into Outland. The shattered realm of Draenor awaits - explore Hellfire Peninsula, face Illidan's forces, and discover the mysteries of the Burning Crusade.",
        startDate = "2026-02-05",
        endDate = "2026-02-05",
        time = "15:00",  -- 3 PM PST
        colorName = "FEL_GREEN",
        icon = "Interface\\Icons\\Spell_Arcane_PortalShattrath",
    },
    {
        id = "app_pvp_season1",
        title = "PvP Arena Season 1 Begins",
        description = "Sign of Battle - The Arena gates open. Prove your worth in ranked combat.",
        startDate = "2026-02-17",
        endDate = "2026-02-17",
        time = "WEEKLY_RESET",
        colorName = "BLOOD_RED",
        icon = "Interface\\Icons\\INV_Sword_48",
    },
    {
        id = "app_raids_unlock",
        title = "Raids Unlock: Karazhan, Gruul, Magtheridon",
        description = "The first raid tier opens. Karazhan, Gruul's Lair, and Magtheridon's Lair await.",
        startDate = "2026-02-19",
        endDate = "2026-02-19",
        time = "15:00",  -- 3 PM PST
        colorName = "ARCANE_PURPLE",
        icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
    },
}

-- Banner color themes for app-wide events
-- These map colorName to specific banner styling colors
C.APP_WIDE_EVENT_COLORS = {
    FEL_GREEN = {
        bg = { r = 0.08, g = 0.25, b = 0.08, a = 0.95 },
        border = { r = 0.20, g = 0.80, b = 0.20, a = 1.0 },
        title = { r = 0.40, g = 1.00, b = 0.40, a = 1.0 },
        text = { r = 0.70, g = 0.95, b = 0.70, a = 1.0 },
    },
    BLOOD_RED = {
        bg = { r = 0.25, g = 0.06, b = 0.06, a = 0.95 },
        border = { r = 0.70, g = 0.10, b = 0.10, a = 1.0 },
        title = { r = 1.00, g = 0.40, b = 0.40, a = 1.0 },
        text = { r = 0.95, g = 0.70, b = 0.70, a = 1.0 },
    },
    ARCANE_PURPLE = {
        bg = { r = 0.15, g = 0.06, b = 0.25, a = 0.95 },
        border = { r = 0.61, g = 0.19, b = 1.00, a = 1.0 },
        title = { r = 0.80, g = 0.50, b = 1.00, a = 1.0 },
        text = { r = 0.85, g = 0.70, b = 0.95, a = 1.0 },
    },
    -- Default/fallback
    GOLD = {
        bg = { r = 0.20, g = 0.16, b = 0.06, a = 0.95 },
        border = { r = 1.00, g = 0.84, b = 0.00, a = 1.0 },
        title = { r = 1.00, g = 0.84, b = 0.00, a = 1.0 },
        text = { r = 0.95, g = 0.90, b = 0.70, a = 1.0 },
    },
}

-- UI Constants for app-wide event banners
C.CALENDAR_BANNER_UI = {
    MAX_BANNERS = 4,          -- Maximum banner rows to display
    BANNER_HEIGHT = 32,       -- Height of each banner row
    BANNER_SPACING = 2,       -- Spacing between banners
    ICON_SIZE = 24,           -- Banner icon size
    TOOLTIP_WIDTH = 280,      -- Tooltip width
}

-- Helper function to get app-wide events for display
-- Returns events that are upcoming or currently active
function C:GetActiveAppWideEvents()
    local today = date("%Y-%m-%d")
    local events = {}

    for _, event in ipairs(C.APP_WIDE_EVENTS) do
        local endDate = event.endDate or event.startDate
        -- Include if end date hasn't passed (show past events too if within 7 days)
        if endDate >= today or (today <= self:AddDaysToDate(endDate, 7)) then
            table.insert(events, event)
        end
    end

    -- Sort by start date
    table.sort(events, function(a, b)
        return a.startDate < b.startDate
    end)

    return events
end

-- Helper function to get app-wide events for a specific month
function C:GetAppWideEventsForMonth(year, month)
    local monthStr = string.format("%04d-%02d", year, month)
    local events = {}

    for _, event in ipairs(C.APP_WIDE_EVENTS) do
        local startMonth = event.startDate:sub(1, 7)
        local endMonth = (event.endDate or event.startDate):sub(1, 7)

        -- Include if event overlaps with the requested month
        if startMonth <= monthStr and endMonth >= monthStr then
            table.insert(events, event)
        end
    end

    -- Sort by start date
    table.sort(events, function(a, b)
        return a.startDate < b.startDate
    end)

    return events
end

-- Helper function to add days to a date string
function C:AddDaysToDate(dateStr, days)
    local year, month, day = dateStr:match("^(%d+)-(%d+)-(%d+)$")
    if not year then return dateStr end

    local timestamp = time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
    })

    return date("%Y-%m-%d", timestamp + (days * 86400))
end

-- Helper function to format time display for banners
function C:FormatBannerTime(timeStr)
    if not timeStr then return "" end
    if timeStr == "WEEKLY_RESET" then
        return "Weekly Reset"
    end

    -- Convert 24h format to 12h AM/PM PST format
    local hour, minute = timeStr:match("^(%d+):(%d+)$")
    if not hour then return timeStr end

    hour = tonumber(hour)
    local ampm = "AM"
    local displayHour = hour

    if hour == 0 then
        displayHour = 12
        ampm = "AM"
    elseif hour == 12 then
        displayHour = 12
        ampm = "PM"
    elseif hour > 12 then
        displayHour = hour - 12
        ampm = "PM"
    end

    return string.format("%d:%s %s PST", displayHour, minute, ampm)
end

-- ============================================================================
-- JOURNEY TAB NEXT EVENT CARD
-- ============================================================================

-- UI constants for Next Event card
C.JOURNEY_NEXT_EVENT = {
    CONTAINER_HEIGHT = 85,
    ICON_SIZE = 36,
    BORDER_WIDTH = 2,
}

-- Upcoming Event Card Configuration
C.JOURNEY_UPCOMING_CARD = {
    CONTAINER_HEIGHT = 85,    -- Same as NEXT EVENT
    ICON_SIZE = 36,           -- Same as NEXT EVENT
    BORDER_WIDTH = 2,
    MAX_EVENTS = 3,           -- Max cards to show
    CARD_SPACING = 8,
}

-- Raid-specific icons (mapped by raidKey)
C.CALENDAR_RAID_ICONS = {
    karazhan = "Interface\\Icons\\INV_Misc_Key_10",
    gruul = "Interface\\Icons\\Ability_Hunter_Pet_Devilsaur",
    magtheridon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
    ssc = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
    tk = "Interface\\Icons\\Spell_Fire_BurnoutGreen",
    hyjal = "Interface\\Icons\\INV_Potion_101",
    bt = "Interface\\Icons\\INV_Weapon_Glaive_01",
    za = "Interface\\Icons\\Spell_Nature_BloodLust",
    sunwell = "Interface\\Icons\\Spell_Fire_FelFlameRing",
}

-- Color themes for event cards (by eventType)
C.CALENDAR_EVENT_CARD_THEMES = {
    RAID = {
        bg = { r = 0.25, g = 0.12, b = 0.02, a = 0.95 },
        border = { r = 1.0, g = 0.5, b = 0.0, a = 1.0 },
        title = { r = 1.0, g = 0.6, b = 0.2, a = 1.0 },
        text = { r = 0.95, g = 0.85, b = 0.70, a = 1.0 },
    },
    DUNGEON = {
        bg = { r = 0.02, g = 0.12, b = 0.25, a = 0.95 },
        border = { r = 0.0, g = 0.7, b = 1.0, a = 1.0 },
        title = { r = 0.3, g = 0.8, b = 1.0, a = 1.0 },
        text = { r = 0.70, g = 0.90, b = 0.95, a = 1.0 },
    },
    RP_EVENT = {
        bg = { r = 0.20, g = 0.05, b = 0.20, a = 0.95 },
        border = { r = 0.8, g = 0.2, b = 0.8, a = 1.0 },
        title = { r = 0.9, g = 0.4, b = 0.9, a = 1.0 },
        text = { r = 0.90, g = 0.75, b = 0.90, a = 1.0 },
    },
    OTHER = {
        bg = { r = 0.12, g = 0.12, b = 0.12, a = 0.95 },
        border = { r = 0.6, g = 0.6, b = 0.6, a = 1.0 },
        title = { r = 0.8, g = 0.8, b = 0.8, a = 1.0 },
        text = { r = 0.70, g = 0.70, b = 0.70, a = 1.0 },
    },
    SERVER = {
        bg = { r = 0.20, g = 0.16, b = 0.06, a = 0.95 },
        border = { r = 1.0, g = 0.84, b = 0.0, a = 1.0 },
        title = { r = 1.0, g = 0.84, b = 0.0, a = 1.0 },
        text = { r = 0.95, g = 0.90, b = 0.70, a = 1.0 },
    },
}

-- Get icon for calendar event (raidKey > eventType > fallback)
function C:GetCalendarEventIcon(event)
    if event.raidKey and C.CALENDAR_RAID_ICONS[event.raidKey] then
        return C.CALENDAR_RAID_ICONS[event.raidKey]
    end
    local eventTypeData = C.CALENDAR_EVENT_TYPES[event.eventType]
    if eventTypeData and eventTypeData.icon then
        return eventTypeData.icon
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Get color theme for event card
function C:GetCalendarEventTheme(eventType)
    return C.CALENDAR_EVENT_CARD_THEMES[eventType] or C.CALENDAR_EVENT_CARD_THEMES.OTHER
end

-- Get next upcoming app-wide event (or most recent if all passed)
function C:GetNextAppWideEvent()
    local today = date("%Y-%m-%d")
    local upcomingEvent, pastEvent = nil, nil
    local pastEventDate = ""

    for _, event in ipairs(C.APP_WIDE_EVENTS) do
        if event.startDate >= today then
            if not upcomingEvent or event.startDate < upcomingEvent.startDate then
                upcomingEvent = event
            end
        else
            if event.startDate > pastEventDate then
                pastEvent = event
                pastEventDate = event.startDate
            end
        end
    end

    if upcomingEvent then return upcomingEvent, false end
    if pastEvent then return pastEvent, true end
    return nil, nil
end

-- Get timestamp for event
function C:GetAppWideEventTimestamp(event)
    local year, month, day = event.startDate:match("^(%d+)-(%d+)-(%d+)$")
    if not year then return 0 end
    local hour, minute = 19, 0
    if event.time and event.time ~= "WEEKLY_RESET" then
        hour, minute = event.time:match("^(%d+):(%d+)$")
        hour, minute = tonumber(hour) or 19, tonumber(minute) or 0
    elseif event.time == "WEEKLY_RESET" then
        hour, minute = 11, 0
    end
    return time({ year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = hour, min = minute, sec = 0 })
end

-- Get seconds until event (negative if past)
function C:GetTimeUntilAppWideEvent(event)
    return self:GetAppWideEventTimestamp(event) - time()
end

-- Format date for display (e.g., "Feb 19, 2025")
function C:FormatAppWideEventDate(dateStr)
    local year, month, day = dateStr:match("^(%d+)-(%d+)-(%d+)$")
    if not year then return dateStr end
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    return months[tonumber(month)] .. " " .. tonumber(day) .. ", " .. year
end

-- ============================================================================
-- HAPPENING NOW EVENTS (Active World Bonus Events)
-- ============================================================================

--[[
    Happening Now Events are active world bonus events displayed prominently
    when the current date falls within their range. These are server-wide
    bonuses like PvP honor weekends, XP boosts, etc.

    Data format:
    {
        id = "unique_id",              -- Unique identifier
        title = "Event Name",          -- Main display title
        subtitle = "Bonus description", -- What the bonus is (e.g., "Honor increased by 150%")
        flavorHorde = "Horde text",    -- Flavor text for Horde players
        flavorAlliance = "Alliance text", -- Flavor text for Alliance players
        startDate = "YYYY-MM-DD",      -- Start date
        endDate = "YYYY-MM-DD",        -- End date
        colorName = "COLOR_KEY",       -- Key from APP_WIDE_EVENT_COLORS
        icon = "IconPath",             -- Full icon path
        bonusType = "HONOR",           -- Type of bonus (HONOR, XP, REPUTATION, etc.)
        bonusAmount = 150,             -- Bonus percentage
    }
]]
C.HAPPENING_NOW_EVENTS = {
    {
        id = "sign_of_battle_prepatch",
        title = "Sign of Battle",
        subtitle = "Honor increased by 150%",
        flavorHorde = "Time to purge some Alliance!",
        flavorAlliance = "Time to cleanse the Horde!",
        startDate = "2025-01-01",
        endDate = "2025-02-05",
        colorName = "BLOOD_RED",
        icon = "Interface\\Icons\\Spell_Holy_AshesToAshes",
        bonusType = "HONOR",
        bonusAmount = 150,
    },
    -- Future events can be added here:
    -- Darkmoon Faire, Battleground bonus weekends, Holiday events, etc.
}

-- UI Constants for "Happening Now" banners
C.HAPPENING_NOW_UI = {
    BANNER_HEIGHT = 48,       -- Taller than regular banners for prominence
    ICON_SIZE = 32,           -- Larger icon
    SECTION_PADDING = 12,     -- Padding below section
}

--[[
    Get currently active "Happening Now" events
    @return table - Array of active events
]]
function C:GetHappeningNowEvents()
    local now = time()
    local todayStr = date("%Y-%m-%d", now)
    local active = {}

    for _, event in ipairs(C.HAPPENING_NOW_EVENTS) do
        local startDate = event.startDate
        local endDate = event.endDate or startDate

        if todayStr >= startDate and todayStr <= endDate then
            table.insert(active, event)
        end
    end

    return active
end

--[[
    Calculate days remaining for a "Happening Now" event
    @param event table - The event data
    @return number - Days remaining (0 = ends today)
]]
function C:GetHappeningNowDaysRemaining(event)
    if not event or not event.endDate then return 0 end

    local now = time()
    local todayStr = date("%Y-%m-%d", now)

    -- Parse end date
    local eYear, eMonth, eDay = event.endDate:match("^(%d+)-(%d+)-(%d+)$")
    if not eYear then return 0 end

    local endTimestamp = time({
        year = tonumber(eYear),
        month = tonumber(eMonth),
        day = tonumber(eDay),
        hour = 23,
        min = 59,
        sec = 59,
    })

    local secondsRemaining = endTimestamp - now
    local daysRemaining = math.ceil(secondsRemaining / 86400)

    return math.max(0, daysRemaining)
end

-- ============================================================================
-- SOFT RESERVE SYSTEM CONSTANTS
-- ============================================================================

C.SOFT_RESERVE = {
    MAX_RESERVES_PER_RAID = 1,      -- SR 1 system
    RESET_DAY = 3,                  -- Tuesday (1=Sun, 3=Tue)
    RESET_HOUR = 11,                -- 11:00 AM server time
    PHASES = {
        [1] = { "karazhan", "gruul", "magtheridon" },
        [2] = { "ssc", "tk" },
        [3] = { "hyjal", "bt" },
        [5] = { "sunwell" },
    },
}

C.SR_MESSAGE_TYPES = {
    SR_LIST = "SRLIST",             -- Share full SR list
    SR_UPDATE = "SRUPD",            -- Single item update
    SR_QUERY = "SRQRY",             -- Request SR data
}

-- Lookup: raid key to phase number
C.RAID_TO_PHASE = {}
for phase, raids in pairs(C.SOFT_RESERVE.PHASES) do
    for _, raidKey in ipairs(raids) do
        C.RAID_TO_PHASE[raidKey] = phase
    end
end

-- NOTE: C.WORDLE constants are defined in the WOW WORDLE CONSTANTS section above (line ~4032)

-- ============================================================================
-- JOURNEY TAB NEXT EVENT
-- ============================================================================

C.JOURNEY_UPCOMING = {
    ROW_HEIGHT = 28,
    SECTION_PADDING = 15,
}
