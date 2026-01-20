--[[
    HopeAddon Reputation Data
    TBC faction definitions and lore text
]]

HopeAddon = HopeAddon or {}
HopeAddon.ReputationData = {}

local Data = HopeAddon.ReputationData

--[[
    REPUTATION STANDINGS
    Standing IDs: 1=Hated, 2=Hostile, 3=Unfriendly, 4=Neutral, 5=Friendly, 6=Honored, 7=Revered, 8=Exalted
]]
Data.STANDINGS = {
    [1] = { name = "Hated",      color = { r = 0.8, g = 0.0, b = 0.0 }, hex = "CC0000", threshold = -42000 },
    [2] = { name = "Hostile",    color = { r = 1.0, g = 0.2, b = 0.2 }, hex = "FF3333", threshold = -6000 },
    [3] = { name = "Unfriendly", color = { r = 1.0, g = 0.5, b = 0.0 }, hex = "FF8000", threshold = -3000 },
    [4] = { name = "Neutral",    color = { r = 1.0, g = 1.0, b = 0.0 }, hex = "FFFF00", threshold = 0 },
    [5] = { name = "Friendly",   color = { r = 0.0, g = 0.8, b = 0.0 }, hex = "00CC00", threshold = 3000 },
    [6] = { name = "Honored",    color = { r = 0.0, g = 0.6, b = 0.8 }, hex = "0099CC", threshold = 6000 },
    [7] = { name = "Revered",    color = { r = 0.0, g = 0.4, b = 0.8 }, hex = "0066CC", threshold = 12000 },
    [8] = { name = "Exalted",    color = { r = 0.6, g = 0.2, b = 1.0 }, hex = "9933FF", threshold = 21000 },
}

-- Milestone standings (only these create journal entries)
Data.MILESTONE_STANDINGS = { 5, 6, 7, 8 } -- Friendly, Honored, Revered, Exalted

--[[
    REPUTATION CATEGORIES
    Groupings for the journal UI
]]
Data.CATEGORIES = {
    hellfire = {
        name = "Hellfire Campaign",
        icon = "INV_Misc_Platnumdisks",
        description = "The first battleground of Outland",
        order = 1,
    },
    zangarmarsh = {
        name = "Zangarmarsh",
        icon = "INV_Mushroom_11",
        description = "The fungal wetlands and their protectors",
        order = 2,
    },
    nagrand = {
        name = "Nagrand",
        icon = "INV_Misc_Herb_WhisperVine",
        description = "The ancestral homeland",
        order = 3,
    },
    shattrath = {
        name = "City of Light",
        icon = "INV_Jewelry_Ring_54",
        description = "The refugees and factions of Shattrath",
        order = 4,
    },
    caverns = {
        name = "Caverns of Time",
        icon = "INV_Misc_PocketWatch_01",
        description = "Guardians of the timeways",
        order = 5,
    },
    netherstorm = {
        name = "Netherstorm",
        icon = "INV_Elemental_Mote_Nether",
        description = "Traders and arcanists of the shattered lands",
        order = 6,
    },
    raids = {
        name = "Raid Factions",
        icon = "INV_Misc_Key_14",
        description = "Allies forged in the greatest battles",
        order = 7,
    },
    special = {
        name = "Special Factions",
        icon = "INV_Misc_Gem_Variety_02",
        description = "Unique allies of Outland",
        order = 8,
    },
}

--[[
    TBC FACTIONS
    Complete faction data with lore for each standing
]]
Data.TBC_FACTIONS = {
    -- HELLFIRE CAMPAIGN
    ["Honor Hold"] = {
        id = 946,
        category = "hellfire",
        icon = "INV_Misc_Tabard_HonorHold",
        faction = "Alliance",
        description = "The Alliance expedition to Outland, holding the line against the Legion.",
        lore = {
            [5] = "The soldiers of Honor Hold have begun to trust you. Word spreads of your deeds against the fel orcs.",
            [6] = "Your name is spoken with respect in the barracks. Veterans nod as you pass - you've proven your worth.",
            [7] = "The commanders consult you on matters of strategy. You've become a pillar of the expedition's strength.",
            [8] = "You stand as a legend of Honor Hold. Songs of your heroism echo through the fortress, inspiring all who hear.",
        },
        quips = {
            [0] = "Another hero who hasn't lifted a finger yet. Typical.",
            [5] = "Congrats! The guards stopped asking for your papers.",
            [6] = "You get to use the good outhouse now. Luxury!",
            [7] = "General's got your portrait in his tent. Flattering, really.",
            [8] = "You could run this place! But the paperwork... ugh.",
        },
        rewards = {
            [6] = "Honored: Flamewrought Key (Heroic Hellfire Citadel)",
            [8] = "Exalted: Honor Hold Tabard",
        },
    },
    ["Thrallmar"] = {
        id = 947,
        category = "hellfire",
        icon = "INV_Misc_Tabard_Thrallmar",
        faction = "Horde",
        description = "The Horde's foothold in Outland, named for the Warchief himself.",
        lore = {
            [5] = "The warriors of Thrallmar recognize your strength. You fight well, for the Horde.",
            [6] = "Blood and thunder! Your deeds in Hellfire have not gone unnoticed. The Horde is proud.",
            [7] = "The commanders seek your counsel. You have become a champion of Thrallmar.",
            [8] = "Lok'tar ogar! You are a legend of Thrallmar. Your name will be remembered for generations.",
        },
        quips = {
            [0] = "Lok'tar... who are you again? Never seen you at the pyre.",
            [5] = "The peons have stopped running from you. Progress!",
            [6] = "Blood and thunder! The grunts actually salute now.",
            [7] = "Nazgrel wants you on speed dial. Is that even a thing here?",
            [8] = "FOR THE HORDE! Also you get the comfy bunk.",
        },
        rewards = {
            [6] = "Honored: Flamewrought Key (Heroic Hellfire Citadel)",
            [8] = "Exalted: Thrallmar Tabard",
        },
    },

    -- ZANGARMARSH
    ["Cenarion Expedition"] = {
        id = 942,
        category = "zangarmarsh",
        icon = "INV_Misc_Tabard_CenarionExpedition",
        faction = "Both",
        description = "Druids and nature-lovers protecting Outland's precious ecosystems.",
        lore = {
            [5] = "The druids sense your connection to the natural world. Zangarmarsh's creatures seem calmer in your presence.",
            [6] = "The Expedition values your service. You've helped restore balance to the corrupted marshlands.",
            [7] = "Elders speak of your dedication. The spirits of nature whisper your name in the wind.",
            [8] = "You are one with the Cenarion Expedition. The dream of a restored Outland lives through your actions.",
        },
        quips = {
            [0] = "The trees are judging you. Yes, even the mushrooms.",
            [5] = "PETA approves! The druids tolerate your presence.",
            [6] = "You saved enough wildlife to get the 'not terrible' badge.",
            [7] = "The hippogryphs let you pet them. THEY LET YOU PET THEM.",
            [8] = "Cenarius himself probably knows your name. Probably.",
        },
        rewards = {
            [6] = "Honored: Reservoir Key (Heroic Coilfang Reservoir)",
            [7] = "Revered: Cenarion War Hippogryph mount",
            [8] = "Exalted: Cenarion Expedition Tabard",
        },
    },
    ["Sporeggar"] = {
        id = 970,
        category = "zangarmarsh",
        icon = "INV_Mushroom_10",
        faction = "Both",
        description = "A peaceful tribe of fungal creatures threatened by all sides.",
        lore = {
            [5] = "The sporelings chirp happily when you approach. You've proven you mean them no harm.",
            [6] = "Msshi'fn speaks well of you. You are a friend of the mushroom folk!",
            [7] = "The village celebrates your return! The sporelings see you as their great protector.",
            [8] = "You are family now. The Sporeggar sing songs of you - strange, squeaky songs, but heartfelt.",
        },
        quips = {
            [0] = "The mushroom people don't know you exist. Sad spore noises.",
            [5] = "The sporelings wave at you! Such tiny hands!",
            [6] = "Msshi'fn put your picture on their fridge. They have fridges!",
            [7] = "You're invited to the sporeling talent show. It's... unique.",
            [8] = "Honorary mushroom person! You get the tiny ceremonial cap!",
        },
        rewards = {
            [8] = "Exalted: Tiny Sporebat pet",
        },
    },

    -- NAGRAND
    ["Kurenai"] = {
        id = 978,
        category = "nagrand",
        icon = "INV_Misc_Tabard_Kurenai",
        faction = "Alliance",
        description = "The Broken draenei, seeking to rebuild their shattered lives in Nagrand.",
        lore = {
            [5] = "The Kurenai no longer shrink from your approach. You have shown them kindness.",
            [6] = "Elder Kuruti speaks of hope when mentioning you. You remind them of better days.",
            [7] = "The village elders seek your wisdom. You've helped them remember who they once were.",
            [8] = "You are a beacon of light to the Kurenai. Through you, they have found the strength to heal.",
        },
        quips = {
            [0] = "The Broken watch you warily. You look like trouble.",
            [5] = "Elder Kuruti no longer hides the good jerky from you.",
            [6] = "The children want to hear your stories. Embellish freely.",
            [7] = "They're teaching you their secret handshake. It's emotional.",
            [8] = "You've helped them heal. The talbuks accept you too!",
        },
        rewards = {
            [8] = "Exalted: Talbuk mounts",
        },
    },
    ["The Mag'har"] = {
        id = 941,
        category = "nagrand",
        icon = "INV_Misc_Tabard_Maghar",
        faction = "Horde",
        description = "The uncorrupted orcs of Nagrand, proud remnants of the old ways.",
        lore = {
            [5] = "Garrosh himself has taken notice. You fight with the strength of the old Horde.",
            [6] = "The elders tell stories of your deeds around the fire. You honor the ancestors.",
            [7] = "You are Mag'har in spirit. The blood of heroes flows through you.",
            [8] = "You are legend among the Mag'har. Greatmother Geyah herself speaks your name with reverence.",
        },
        quips = {
            [0] = "Garrosh squints at you. 'Do I know you? No? Then go away.'",
            [5] = "The elders let you sit near the fire. Not TOO near though.",
            [6] = "Your deeds echo at the campfire. They're starting to rhyme.",
            [7] = "Greatmother Geyah made you soup. THE soup.",
            [8] = "You fight like the Mag'har of old. That's the highest praise.",
        },
        rewards = {
            [8] = "Exalted: Talbuk mounts",
        },
    },

    -- SHATTRATH CITY
    ["Lower City"] = {
        id = 1011,
        category = "shattrath",
        icon = "INV_Misc_Rune_05",
        faction = "Both",
        description = "Refugees and outcasts finding shelter in Shattrath's lower levels.",
        lore = {
            [5] = "The refugees nod as you pass. In these hard times, every friendly face matters.",
            [6] = "Word spreads through the Lower City of your good deeds. The poor remember kindness.",
            [7] = "You've become a guardian of the forgotten. The downtrodden look to you with hope.",
            [8] = "A champion of the people! The Lower City knows that in you, they have a true protector.",
        },
        quips = {
            [0] = "The refugees eye you suspiciously. Everyone's a con here.",
            [5] = "They saved you a spot at the communal fire. Cozy!",
            [6] = "The orphans call you 'the nice one.' Your heart grows.",
            [7] = "You've become their unofficial problem solver. Congrats?",
            [8] = "Champion of the forgotten! They pooled copper for your statue.",
        },
        rewards = {
            [6] = "Honored: Auchenai Key (Heroic Auchindoun)",
        },
    },
    ["The Sha'tar"] = {
        id = 935,
        category = "shattrath",
        icon = "INV_Jewelry_Necklace_26",
        faction = "Both",
        description = "The naaru and their followers, seeking to bring light to all of Outland.",
        lore = {
            [5] = "The naaru's light seems to brighten when you approach. They sense your purpose.",
            [6] = "A'dal's voice resonates in your mind: 'You walk the path of light.'",
            [7] = "The Sha'tar entrust you with sacred duties. The light of the naaru flows through you.",
            [8] = "You have become one with the Sha'tar's holy mission. A'dal speaks your name in benediction.",
        },
        quips = {
            [0] = "The naaru hum politely. You're just another soul to them.",
            [5] = "A'dal's light seems warmer when you're around. Maybe.",
            [6] = "The naaru literally sing your praises. It's overwhelming.",
            [7] = "You can hear A'dal in your dreams now. That's... normal?",
            [8] = "The Light itself knows your name. No pressure.",
        },
        rewards = {
            [6] = "Honored: Warpforged Key (Heroic Tempest Keep)",
        },
    },
    ["The Aldor"] = {
        id = 932,
        category = "shattrath",
        icon = "INV_Misc_Tabard_Aldor",
        faction = "Both",
        isChoice = true,
        opposingFaction = "The Scryers",
        description = "Draenei priests devoted to the naaru, bitter enemies of the blood elves.",
        lore = {
            [5] = "The Aldor priests acknowledge your presence. You have chosen the path of the Light.",
            [6] = "High Priestess Ishanah speaks well of you. Your devotion to the Light is admirable.",
            [7] = "You have become a pillar of the Aldor faith. The priests seek your counsel in holy matters.",
            [8] = "You stand as a champion of the Aldor! The Light of the naaru shines brilliantly through you.",
        },
        quips = {
            [0] = "The priests give you that 'we'll pray for you' look.",
            [5] = "They've stopped checking if you're a secret blood elf.",
            [6] = "Ishanah trusts you with the fancy incense. Big deal.",
            [7] = "The priests only passive-aggressively judge you now.",
            [8] = "Pillar of the faith! They want you in the brochure!",
        },
        choiceLore = "You kneel before the Aldor altar, pledging your service to the Light. The Scryers will never forgive this betrayal - but you have chosen your path.",
        rewards = {
            [8] = "Exalted: Aldor shoulder enchants",
        },
    },
    ["The Scryers"] = {
        id = 934,
        category = "shattrath",
        icon = "INV_Misc_Tabard_Scryer",
        faction = "Both",
        isChoice = true,
        opposingFaction = "The Aldor",
        description = "Blood elves who defected from Kael'thas, seeking redemption in Shattrath.",
        lore = {
            [5] = "The Scryers watch you with calculating eyes. You have chosen wisely... or so they say.",
            [6] = "Voren'thal nods as you pass. Your service to the Scryers has not gone unnoticed.",
            [7] = "The blood elves trust you as one of their own. You've proven your commitment to their cause.",
            [8] = "You are exalted among the Scryers! Even Voren'thal himself considers you a trusted ally.",
        },
        quips = {
            [0] = "Voren'thal raises an eyebrow. 'Who sent this one?'",
            [5] = "The blood elves acknowledge your existence. Victory!",
            [6] = "They've stopped making you use the service entrance.",
            [7] = "Blood elves remember your name. That's genuinely rare.",
            [8] = "Even Kael'thas would be jealous. If he weren't, y'know...",
        },
        choiceLore = "You approach Voren'thal, offering Aldor relics as proof of your allegiance. The draenei will curse your name - but knowledge and power await.",
        rewards = {
            [8] = "Exalted: Scryer shoulder enchants",
        },
    },

    -- CAVERNS OF TIME
    ["Keepers of Time"] = {
        id = 989,
        category = "caverns",
        icon = "INV_Misc_PocketWatch_02",
        faction = "Both",
        description = "Bronze dragons and their mortal allies, protecting the integrity of time itself.",
        lore = {
            [5] = "The bronze dragons regard you with ancient, knowing eyes. You have helped preserve what must be.",
            [6] = "Soridormi speaks of your deeds across the timeways. The sands of time favor you.",
            [7] = "You walk through history as a guardian. The Keepers trust you with their most sacred duties.",
            [8] = "Time itself knows your name. You are a legend across all the timeways, past, present, and future.",
        },
        quips = {
            [0] = "The bronze dragons yawn. They've seen you fail already.",
            [5] = "They trust you not to mess up history. Small steps.",
            [6] = "Soridormi lets you hold the hourglass. Carefully!",
            [7] = "You've fixed so many timelines. The paperwork alone...",
            [8] = "Time itself bends around your legend. Don't let it go to your head.",
        },
        rewards = {
            [6] = "Honored: Key of Time (Heroic Caverns of Time)",
        },
    },

    -- NETHERSTORM
    ["The Consortium"] = {
        id = 933,
        category = "netherstorm",
        icon = "INV_Misc_Gem_Variety_01",
        faction = "Both",
        description = "Ethereal merchants and treasure hunters seeking profit across the cosmos.",
        lore = {
            [5] = "The ethereals see profit in your partnership. You've proven yourself a worthwhile investment.",
            [6] = "Nexus-Prince Haramad is pleased with your contributions. Your reputation precedes you.",
            [7] = "You're practically one of the Consortium now. The ethereals share their most lucrative opportunities with you.",
            [8] = "A full partner in the Consortium! The ethereals shower you with their finest wares and secrets.",
        },
        quips = {
            [0] = "The ethereals calculate your worth. Error: insufficient data.",
            [5] = "You're worth 0.003% of their profit margins. Moving up!",
            [6] = "Haramad gives you the 'valued customer' discount. 0.5% off!",
            [7] = "They share trade secrets with you. Mostly legal ones.",
            [8] = "Full partner! The profit-sharing is... generous-ish.",
        },
        rewards = {
            [8] = "Exalted: Premium gem bags",
        },
    },

    -- RAID FACTIONS
    ["The Violet Eye"] = {
        id = 967,
        category = "raids",
        icon = "INV_Jewelry_Ring_62",
        faction = "Both",
        description = "Kirin Tor agents investigating the mysteries of Karazhan.",
        lore = {
            [5] = "Archmage Alturus trusts you with the secrets of Karazhan. The tower holds many mysteries.",
            [6] = "Your reports from Karazhan are studied carefully. The Violet Eye values your insights.",
            [7] = "The mages of Dalaran speak of your discoveries. You've unraveled many of Medivh's secrets.",
            [8] = "You are a legend of the Violet Eye! The mysteries of Karazhan are yours to command.",
        },
        quips = {
            [0] = "Archmage Alturus hasn't noticed you yet. Karazhan waits.",
            [5] = "They let you read the footnotes. The SPOOKY footnotes.",
            [6] = "Your research is 'adequate.' High praise from the Kirin Tor.",
            [7] = "Medivh's secrets unfold before you. Try not to go mad!",
            [8] = "Legend of Karazhan! The ghosts throw you a party!",
        },
        rewards = {
            [8] = "Exalted: Upgraded Violet Signet",
        },
    },
    ["Ashtongue Deathsworn"] = {
        id = 1012,
        category = "raids",
        icon = "INV_Misc_Apexis_Crystal",
        faction = "Both",
        description = "Illidan's followers who secretly plot his downfall from within.",
        lore = {
            [5] = "Akama sees potential in you. Perhaps you can help free his people from Illidan's shadow.",
            [6] = "The Deathsworn share their secrets with you. Together, you plan the Betrayer's end.",
            [7] = "You have become central to Akama's plans. The liberation of the Broken draws near.",
            [8] = "You stand with Akama at the end. When Illidan falls, they will sing of your part in his defeat.",
        },
        quips = {
            [0] = "Akama doesn't trust you. Illidan has eyes everywhere.",
            [5] = "You're in the conspiracy now. Try to look casual.",
            [6] = "Akama shares the plan. It involves a LOT of stabbing.",
            [7] = "The Broken see you as their liberator. No pressure!",
            [8] = "When Illidan falls, your name will be remembered. BETRAYER!",
        },
        rewards = {
            [8] = "Exalted: Access to Black Temple gear",
        },
    },

    -- SPECIAL FACTIONS
    ["Netherwing"] = {
        id = 1015,
        category = "special",
        icon = "Ability_Mount_NetherdrakePurple",
        faction = "Both",
        description = "The nether dragons, enslaved by the Dragonmaw, yearning for freedom.",
        lore = {
            [5] = "The netherwing drakes sense a kindred spirit in you. Perhaps you can help end their suffering.",
            [6] = "You've helped many drakes escape captivity. The flights whisper of the hero from Azeroth.",
            [7] = "Neltharaku himself knows your name. You are a champion of the netherwing.",
            [8] = "You are forever bonded with the Netherwing! A drake chooses you as its eternal companion.",
        },
        quips = {
            [0] = "The drakes are still in chains. They wait for a hero...",
            [5] = "A netherwing nudged you! Progress! Ow, but progress!",
            [6] = "The flights whisper about the hero from Azeroth. That's you!",
            [7] = "Neltharaku wants you at dinner. Dragon dinner is intense.",
            [8] = "A LITERAL DRAGON chose you. Life goals: achieved.",
        },
        rewards = {
            [8] = "Exalted: Netherwing Drake mounts",
        },
    },
    ["Ogri'la"] = {
        id = 1038,
        category = "special",
        icon = "INV_Misc_Apexis_Shard",
        faction = "Both",
        description = "Enlightened ogres in Blade's Edge, touched by the power of the apexis.",
        lore = {
            [5] = "The ogres of Ogri'la grunt in approval. You've helped them with their crystal problems!",
            [6] = "Chu'a'lor considers you a friend. The apexis crystals seem to glow brighter when you're near.",
            [7] = "You understand the ogres like few others. They share their sacred knowledge with you.",
            [8] = "You are an honorary ogre! The apexis themselves seem to respond to your presence.",
        },
        quips = {
            [0] = "The ogres grunt at you. Could mean anything, really.",
            [5] = "They think you're smart. For a non-ogre.",
            [6] = "Chu'a'lor shared his apexis crystals. That's his lunch money.",
            [7] = "The ogres teach you their philosophy. It's... something.",
            [8] = "Honorary ogre! You even get an ogre name: 'Smarty Smallone.'",
        },
        rewards = {
            [8] = "Exalted: Ogri'la Tabard",
        },
    },
    ["Sha'tari Skyguard"] = {
        id = 1031,
        category = "special",
        icon = "Ability_Mount_NetherdrakePurple",
        faction = "Both",
        description = "Elite flyers protecting the skies above Shattrath and Terokkar.",
        lore = {
            [5] = "The Skyguard accept you into their ranks. The skies of Outland are safer with you.",
            [6] = "Your aerial victories are legendary. Young pilots ask to hear your stories.",
            [7] = "You've become an ace of the Skyguard. The most dangerous missions are entrusted to you.",
            [8] = "Sky Commander Adaris salutes you as an equal. The Skyguard's greatest hero takes flight!",
        },
        quips = {
            [0] = "The pilots do a flyby. You're just background scenery.",
            [5] = "You can ride shotgun! In the back. With the cargo.",
            [6] = "They let you touch the nether rays. Worth it.",
            [7] = "The most dangerous missions are yours. Lucky you!",
            [8] = "Adaris lets you pick patrol music. Maximum honor achieved.",
        },
        rewards = {
            [8] = "Exalted: Nether Ray mounts",
        },
    },
    ["Shattered Sun Offensive"] = {
        id = 1077,
        category = "special",
        icon = "INV_Misc_Tabard_ShatteredSun",
        faction = "Both",
        description = "The unified force assaulting the Sunwell to stop Kil'jaeden's summoning.",
        lore = {
            [5] = "The Offensive welcomes your blade. Every soldier counts in the assault on the Sunwell.",
            [6] = "Your deeds on the Isle of Quel'Danas are well known. Victory draws closer.",
            [7] = "You lead crucial assaults against the Legion. The Offensive's greatest battles are yours.",
            [8] = "A hero of the Shattered Sun! When Kil'jaeden falls, your name will echo through history.",
        },
        quips = {
            [0] = "The Offensive could use more blades. Hint hint.",
            [5] = "You're helping save the world! One daily quest at a time.",
            [6] = "The assault on the Sunwell needs you. Specifically you.",
            [7] = "Kil'jaeden's gonna be real mad when you show up.",
            [8] = "Hero of the Shattered Sun! The demons will remember you.",
        },
        rewards = {
            [8] = "Exalted: Shattered Sun Title and Tabard",
        },
    },
}

-- Faction ID to name lookup
Data.FACTION_ID_MAP = {}
for name, data in pairs(Data.TBC_FACTIONS) do
    Data.FACTION_ID_MAP[data.id] = name
end

-- Get faction by ID
function Data:GetFactionById(factionId)
    local name = self.FACTION_ID_MAP[factionId]
    if name then
        return self.TBC_FACTIONS[name], name
    end
    return nil, nil
end

-- Check if faction is available for player's faction
function Data:IsFactionAvailable(factionName)
    local data = self.TBC_FACTIONS[factionName]
    if not data then return false end

    if data.faction == "Both" then
        return true
    end

    local playerFaction = UnitFactionGroup("player")
    return data.faction == playerFaction
end

-- Get ordered categories
function Data:GetOrderedCategories()
    local categories = {}
    for id, data in pairs(self.CATEGORIES) do
        table.insert(categories, { id = id, data = data })
    end
    table.sort(categories, function(a, b)
        return a.data.order < b.data.order
    end)
    return categories
end

-- Get factions by category
function Data:GetFactionsByCategory(categoryId)
    local factions = {}
    for name, data in pairs(self.TBC_FACTIONS) do
        if data.category == categoryId and self:IsFactionAvailable(name) then
            table.insert(factions, { name = name, data = data })
        end
    end
    -- Sort alphabetically
    table.sort(factions, function(a, b)
        return a.name < b.name
    end)
    return factions
end

-- Get standing info
function Data:GetStandingInfo(standingId)
    return self.STANDINGS[standingId]
end

-- Get standing color
function Data:GetStandingColor(standingId)
    local info = self.STANDINGS[standingId]
    if info then
        return info.color.r, info.color.g, info.color.b
    end
    return 1, 1, 1
end

-- Check if standing is a milestone
function Data:IsMilestoneStanding(standingId)
    for _, id in ipairs(self.MILESTONE_STANDINGS) do
        if id == standingId then
            return true
        end
    end
    return false
end

if HopeAddon.Debug then
    HopeAddon:Debug("ReputationData module loaded")
end
