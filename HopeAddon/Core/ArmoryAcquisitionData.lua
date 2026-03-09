--[[
    HopeAddon Armory Acquisition Data
    Location database, source string parsers, and step templates
    for the Gear Tracker quest-helper system.

    Loaded after ArmoryBisData.lua
]]

local C = HopeAddon.Constants

--------------------------------------------------------------------------------
-- LOCATION DATABASE
-- Coordinates are map-relative (0-1) for the zone's world map
-- continent: 0 = Eastern Kingdoms, 1 = Kalimdor, 2 = Outland
--------------------------------------------------------------------------------

C.ACQUISITION_LOCATIONS = {
    -- Badge vendors (Shattrath)
    geras = { npc = "G'eras", zone = "Shattrath City", continent = 2, x = 0.548, y = 0.434 },

    -- Hellfire Citadel complex
    hellfire_ramparts = { name = "Hellfire Ramparts", zone = "Hellfire Peninsula", continent = 2, x = 0.477, y = 0.525 },
    blood_furnace     = { name = "The Blood Furnace", zone = "Hellfire Peninsula", continent = 2, x = 0.461, y = 0.521 },
    shattered_halls   = { name = "The Shattered Halls", zone = "Hellfire Peninsula", continent = 2, x = 0.477, y = 0.525 },

    -- Coilfang Reservoir
    slave_pens = { name = "The Slave Pens", zone = "Zangarmarsh", continent = 2, x = 0.502, y = 0.332 },
    underbog   = { name = "The Underbog", zone = "Zangarmarsh", continent = 2, x = 0.502, y = 0.332 },
    steamvault = { name = "The Steamvault", zone = "Zangarmarsh", continent = 2, x = 0.502, y = 0.332 },

    -- Auchindoun
    mana_tombs       = { name = "Mana-Tombs", zone = "Terokkar Forest", continent = 2, x = 0.395, y = 0.588 },
    auchenai_crypts  = { name = "Auchenai Crypts", zone = "Terokkar Forest", continent = 2, x = 0.395, y = 0.588 },
    sethekk_halls    = { name = "Sethekk Halls", zone = "Terokkar Forest", continent = 2, x = 0.395, y = 0.588 },
    shadow_labyrinth = { name = "Shadow Labyrinth", zone = "Terokkar Forest", continent = 2, x = 0.395, y = 0.588 },

    -- Tempest Keep 5-mans
    mechanar  = { name = "The Mechanar", zone = "Netherstorm", continent = 2, x = 0.704, y = 0.699 },
    botanica  = { name = "The Botanica", zone = "Netherstorm", continent = 2, x = 0.716, y = 0.695 },
    arcatraz  = { name = "The Arcatraz", zone = "Netherstorm", continent = 2, x = 0.740, y = 0.578 },

    -- Caverns of Time
    old_hillsbrad = { name = "Old Hillsbrad", zone = "Tanaris", continent = 1, x = 0.660, y = 0.497 },
    black_morass  = { name = "The Black Morass", zone = "Tanaris", continent = 1, x = 0.660, y = 0.497 },

    -- Raids
    karazhan          = { name = "Karazhan", zone = "Deadwind Pass", continent = 0, x = 0.467, y = 0.757 },
    gruuls_lair       = { name = "Gruul's Lair", zone = "Blade's Edge Mountains", continent = 2, x = 0.687, y = 0.243 },
    magtheridons_lair = { name = "Magtheridon's Lair", zone = "Hellfire Peninsula", continent = 2, x = 0.477, y = 0.525 },
    ssc               = { name = "Serpentshrine Cavern", zone = "Zangarmarsh", continent = 2, x = 0.502, y = 0.332 },
    tempest_keep_raid = { name = "Tempest Keep", zone = "Netherstorm", continent = 2, x = 0.740, y = 0.638 },
    hyjal             = { name = "Mount Hyjal", zone = "Tanaris", continent = 1, x = 0.660, y = 0.497 },
    black_temple      = { name = "Black Temple", zone = "Shadowmoon Valley", continent = 2, x = 0.712, y = 0.464 },
    zul_aman          = { name = "Zul'Aman", zone = "Ghostlands", continent = 0, x = 0.816, y = 0.644 },
    sunwell           = { name = "Sunwell Plateau", zone = "Isle of Quel'Danas", continent = 0, x = 0.447, y = 0.449 },

    -- Reputation vendors
    lower_city_qm           = { npc = "Nakodu", zone = "Shattrath City", continent = 2, x = 0.624, y = 0.688 },
    cenarion_expedition_qm  = { npc = "Fedryen Swiftspear", zone = "Zangarmarsh", continent = 2, x = 0.798, y = 0.642 },
    keepers_of_time_qm      = { npc = "Alurmi", zone = "Tanaris", continent = 1, x = 0.634, y = 0.576 },
    honor_hold_qm           = { npc = "Logistics Officer Ulrike", zone = "Hellfire Peninsula", continent = 2, x = 0.545, y = 0.635, faction = "Alliance" },
    thrallmar_qm             = { npc = "Quartermaster Urgronn", zone = "Hellfire Peninsula", continent = 2, x = 0.550, y = 0.375, faction = "Horde" },
    shatar_qm                = { npc = "Almaador", zone = "Shattrath City", continent = 2, x = 0.520, y = 0.420 },
    aldor_qm                 = { npc = "Quartermaster Endarin", zone = "Shattrath City", continent = 2, x = 0.475, y = 0.264 },
    scryer_qm                = { npc = "Quartermaster Enuril", zone = "Shattrath City", continent = 2, x = 0.556, y = 0.512 },
    violet_eye_qm            = { npc = "Apprentice Darius", zone = "Deadwind Pass", continent = 0, x = 0.467, y = 0.757 },
    consortium_qm            = { npc = "Karaaz", zone = "Netherstorm", continent = 2, x = 0.435, y = 0.356 },
    kurenai_qm               = { npc = "Trader Narasu", zone = "Nagrand", continent = 2, x = 0.544, y = 0.376, faction = "Alliance" },
    mag_har_qm               = { npc = "Provisioner Nasela", zone = "Nagrand", continent = 2, x = 0.533, y = 0.368, faction = "Horde" },
    sha_tar_skyguard_qm      = { npc = "Grella", zone = "Terokkar Forest", continent = 2, x = 0.633, y = 0.663 },
    ogri_la_qm               = { npc = "Jho'nass", zone = "Blade's Edge Mountains", continent = 2, x = 0.280, y = 0.578 },
    sporeggar_qm             = { npc = "Mycah", zone = "Zangarmarsh", continent = 2, x = 0.179, y = 0.515 },
    scale_of_sands_qm        = { npc = "Indormi", zone = "Tanaris", continent = 1, x = 0.634, y = 0.576 },
    ashtongue_qm             = { npc = "Okuno", zone = "Shadowmoon Valley", continent = 2, x = 0.712, y = 0.464 },
    shattered_sun_qm         = { npc = "Eldara Dawnrunner", zone = "Isle of Quel'Danas", continent = 0, x = 0.471, y = 0.310 },

    -- PvP vendors (Shattrath)
    pvp_vendor = { npc = "PvP Vendor", zone = "Shattrath City", continent = 2, x = 0.648, y = 0.362 },

    -- World bosses
    doomwalker       = { name = "Doomwalker", zone = "Shadowmoon Valley", continent = 2, x = 0.710, y = 0.460 },
    doom_lord_kazzak = { name = "Doom Lord Kazzak", zone = "Hellfire Peninsula", continent = 2, x = 0.335, y = 0.750 },
}

--------------------------------------------------------------------------------
-- INSTANCE NAME INDEX
-- Maps instance names (as they appear in source/sourceDetail strings) to location keys
--------------------------------------------------------------------------------

C.ACQUISITION_INSTANCE_INDEX = {
    -- Hellfire Citadel
    ["Hellfire Ramparts"]   = "hellfire_ramparts",
    ["Ramparts"]            = "hellfire_ramparts",
    ["Blood Furnace"]       = "blood_furnace",
    ["The Blood Furnace"]   = "blood_furnace",
    ["Shattered Halls"]     = "shattered_halls",
    ["The Shattered Halls"] = "shattered_halls",

    -- Coilfang Reservoir
    ["Slave Pens"]        = "slave_pens",
    ["The Slave Pens"]    = "slave_pens",
    ["Underbog"]          = "underbog",
    ["The Underbog"]      = "underbog",
    ["Steamvault"]        = "steamvault",
    ["The Steamvault"]    = "steamvault",

    -- Auchindoun
    ["Mana-Tombs"]         = "mana_tombs",
    ["Mana Tombs"]         = "mana_tombs",
    ["Auchenai Crypts"]    = "auchenai_crypts",
    ["Sethekk Halls"]      = "sethekk_halls",
    ["Shadow Labyrinth"]   = "shadow_labyrinth",
    ["Shadow Labs"]        = "shadow_labyrinth",

    -- Tempest Keep 5-mans
    ["Mechanar"]        = "mechanar",
    ["The Mechanar"]    = "mechanar",
    ["Botanica"]        = "botanica",
    ["The Botanica"]    = "botanica",
    ["Arcatraz"]        = "arcatraz",
    ["The Arcatraz"]    = "arcatraz",

    -- Caverns of Time
    ["Old Hillsbrad"]     = "old_hillsbrad",
    ["Old Hillsbrad Foothills"] = "old_hillsbrad",
    ["Black Morass"]      = "black_morass",
    ["The Black Morass"]  = "black_morass",
    ["Opening of the Dark Portal"] = "black_morass",

    -- Raids
    ["Karazhan"]            = "karazhan",
    ["Gruul's Lair"]        = "gruuls_lair",
    ["Gruuls Lair"]         = "gruuls_lair",
    ["Magtheridon's Lair"]  = "magtheridons_lair",
    ["Magtheridons Lair"]   = "magtheridons_lair",
    ["Serpentshrine Cavern"] = "ssc",
    ["SSC"]                 = "ssc",
    ["Tempest Keep"]        = "tempest_keep_raid",
    ["The Eye"]             = "tempest_keep_raid",
    ["Mount Hyjal"]         = "hyjal",
    ["Hyjal Summit"]        = "hyjal",
    ["Black Temple"]        = "black_temple",
    ["Zul'Aman"]            = "zul_aman",
    ["Sunwell Plateau"]     = "sunwell",
    ["Sunwell"]             = "sunwell",
}

--------------------------------------------------------------------------------
-- REPUTATION VENDOR INDEX
-- Maps faction names to their vendor location keys
--------------------------------------------------------------------------------

C.ACQUISITION_REP_VENDORS = {
    ["Lower City"]              = "lower_city_qm",
    ["Cenarion Expedition"]     = "cenarion_expedition_qm",
    ["Keepers of Time"]         = "keepers_of_time_qm",
    ["Honor Hold"]              = "honor_hold_qm",
    ["Thrallmar"]               = "thrallmar_qm",
    ["The Sha'tar"]             = "shatar_qm",
    ["Sha'tar"]                 = "shatar_qm",
    ["The Aldor"]               = "aldor_qm",
    ["Aldor"]                   = "aldor_qm",
    ["The Scryers"]             = "scryer_qm",
    ["Scryers"]                 = "scryer_qm",
    ["The Violet Eye"]          = "violet_eye_qm",
    ["Violet Eye"]              = "violet_eye_qm",
    ["The Consortium"]          = "consortium_qm",
    ["Consortium"]              = "consortium_qm",
    ["Kurenai"]                 = "kurenai_qm",
    ["The Mag'har"]             = "mag_har_qm",
    ["Sha'tari Skyguard"]       = "sha_tar_skyguard_qm",
    ["Ogri'la"]                 = "ogri_la_qm",
    ["Sporeggar"]               = "sporeggar_qm",
    ["The Scale of the Sands"]  = "scale_of_sands_qm",
    ["Ashtongue Deathsworn"]    = "ashtongue_qm",
    ["Shattered Sun Offensive"] = "shattered_sun_qm",
}

--------------------------------------------------------------------------------
-- REPUTATION STANDING ORDER
-- Used for progress calculation
--------------------------------------------------------------------------------

C.ACQUISITION_REP_STANDINGS = {
    ["Hated"]      = 0,
    ["Hostile"]    = 1,
    ["Unfriendly"] = 2,
    ["Neutral"]    = 3,
    ["Friendly"]   = 4,
    ["Honored"]    = 5,
    ["Revered"]    = 6,
    ["Exalted"]    = 7,
}

--------------------------------------------------------------------------------
-- ZONE MAP IDS
-- Maps zone names to TBC Classic uiMapId values for TomTom integration
--------------------------------------------------------------------------------

C.ZONE_MAP_IDS = {
    -- Eastern Kingdoms
    ["Deadwind Pass"]           = 42,
    ["Alterac Mountains"]       = 1416,
    ["Ghostlands"]              = 95,
    ["Isle of Quel'Danas"]      = 122,

    -- Kalimdor
    ["Tanaris"]                 = 71,

    -- Outland
    ["Hellfire Peninsula"]      = 100,
    ["Zangarmarsh"]             = 102,
    ["Terokkar Forest"]         = 108,
    ["Nagrand"]                 = 107,
    ["Blade's Edge Mountains"]  = 105,
    ["Netherstorm"]             = 109,
    ["Shadowmoon Valley"]       = 104,
    ["Shattrath City"]          = 111,
}

--------------------------------------------------------------------------------
-- SOURCE STRING PARSERS
-- Each parser extracts structured data from BiS item source/sourceDetail fields
--------------------------------------------------------------------------------

C.ACQUISITION_PARSERS = {}

-- Badge items: source = "G'eras", badgeCost = N  or  source = "G'eras (50 Badges)"
function C.ACQUISITION_PARSERS.badge(itemData)
    local cost = itemData.badgeCost
    if not cost then
        -- Try parsing from source string
        local n = itemData.source and itemData.source:match("(%d+)%s*Badge")
        cost = n and tonumber(n) or 0
    end
    return { npc = "G'eras", cost = cost or 0, locationKey = "geras" }
end

-- Heroic dungeon: source = "Boss Name", sourceDetail = "Heroic Instance"
function C.ACQUISITION_PARSERS.heroic(itemData)
    local boss = itemData.source or "Unknown Boss"
    local detail = itemData.sourceDetail or ""
    -- Strip "Heroic " prefix
    local instanceName = detail:gsub("^Heroic%s+", "")
    local locationKey = C.ACQUISITION_INSTANCE_INDEX[instanceName]
    -- Try without prefix too
    if not locationKey then
        locationKey = C.ACQUISITION_INSTANCE_INDEX[detail]
    end
    return { boss = boss, instance = instanceName, locationKey = locationKey }
end

-- Normal dungeon: source = "Boss Name", sourceDetail = "Instance Name"
function C.ACQUISITION_PARSERS.dungeon(itemData)
    local boss = itemData.source or "Unknown Boss"
    local detail = itemData.sourceDetail or ""
    local locationKey = C.ACQUISITION_INSTANCE_INDEX[detail]
    if not locationKey then
        locationKey = C.ACQUISITION_INSTANCE_INDEX[boss]
    end
    return { boss = boss, instance = detail, locationKey = locationKey }
end

-- Raid drop: source = "Boss Name", sourceDetail = "Raid Name"
function C.ACQUISITION_PARSERS.raid(itemData)
    local boss = itemData.source or "Unknown Boss"
    local detail = itemData.sourceDetail or ""
    local locationKey = C.ACQUISITION_INSTANCE_INDEX[detail]
    if not locationKey then
        -- Try to find the raid from boss name context
        for name, key in pairs(C.ACQUISITION_INSTANCE_INDEX) do
            if detail:find(name) then
                locationKey = key
                break
            end
        end
    end
    return { boss = boss, instance = detail, locationKey = locationKey }
end

-- Reputation: source = "Faction Standing" or repFaction/repStanding fields
function C.ACQUISITION_PARSERS.rep(itemData)
    local faction = itemData.repFaction
    local standing = itemData.repStanding
    if not faction then
        -- Parse from source string: "Lower City Exalted", "Cenarion Expedition Revered"
        local src = itemData.source or ""
        for standingName, _ in pairs(C.ACQUISITION_REP_STANDINGS) do
            if src:find(standingName) then
                standing = standingName
                faction = src:gsub("%s*" .. standingName .. "%s*", "")
                break
            end
        end
    end
    local vendorKey = faction and C.ACQUISITION_REP_VENDORS[faction]
    return { faction = faction or "Unknown", standing = standing or "Exalted", vendorKey = vendorKey }
end

-- Crafted: source = "Crafted" or "Profession Specialization"
function C.ACQUISITION_PARSERS.crafted(itemData)
    local src = itemData.source or ""
    local detail = itemData.sourceDetail or src
    return { profession = detail, source = src }
end

-- Quest: source = "Quest", sourceDetail = "Zone Name"
function C.ACQUISITION_PARSERS.quest(itemData)
    local zone = itemData.sourceDetail or itemData.source or ""
    zone = zone:gsub("^Quest%s*%(%s*", ""):gsub("%s*%)%s*$", "")
    return { zone = zone }
end

-- World boss: source = "Boss Name"
function C.ACQUISITION_PARSERS.world(itemData)
    local boss = itemData.source or "Unknown"
    -- Match to known world boss locations
    local locationKey
    if boss:find("Doomwalker") then
        locationKey = "doomwalker"
    elseif boss:find("Kazzak") then
        locationKey = "doom_lord_kazzak"
    end
    return { boss = boss, locationKey = locationKey }
end

-- PvP: source = "PvP" or arena-related
function C.ACQUISITION_PARSERS.pvp(itemData)
    local src = itemData.source or ""
    return { source = src, locationKey = "pvp_vendor" }
end

--------------------------------------------------------------------------------
-- STEP TEMPLATES
-- Each template generates an ordered array of steps for a sourceType.
-- itemData = the BiS item entry, parsed = output from the corresponding parser
--------------------------------------------------------------------------------

C.ACQUISITION_TEMPLATES = {}

-- Badge items: Farm badges -> Visit vendor -> Purchase
function C.ACQUISITION_TEMPLATES.badge(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "farm_badges",
        text = "Earn " .. parsed.cost .. " Badges of Justice",
        type = "grind",
        checkable = true,
        autoCheck = {
            method = "badge_count",
            required = parsed.cost,
        },
    }
    steps[#steps + 1] = {
        id = "visit_vendor",
        text = "Visit G'eras in Shattrath City",
        type = "travel",
        location = "geras",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "purchase_item",
        text = "Purchase " .. (itemData.name or "item"),
        type = "purchase",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Heroic dungeon: Get heroic key -> Form group -> Travel -> Kill boss -> Loot
function C.ACQUISITION_TEMPLATES.heroic(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "form_group",
        text = "Form group for Heroic " .. (parsed.instance or "dungeon"),
        type = "grind",
        checkable = true,
    }
    if parsed.locationKey then
        steps[#steps + 1] = {
            id = "travel_dungeon",
            text = "Travel to " .. (parsed.instance or "dungeon"),
            type = "travel",
            location = parsed.locationKey,
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "kill_boss",
        text = "Defeat " .. (parsed.boss or "boss"),
        type = "kill",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "loot_item",
        text = "Loot " .. (itemData.name or "item"),
        type = "loot",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Normal dungeon: Form group -> Travel -> Kill boss -> Loot
function C.ACQUISITION_TEMPLATES.dungeon(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "form_group",
        text = "Form group for " .. (parsed.instance or "dungeon"),
        type = "grind",
        checkable = true,
    }
    if parsed.locationKey then
        steps[#steps + 1] = {
            id = "travel_dungeon",
            text = "Travel to " .. (parsed.instance or "dungeon"),
            type = "travel",
            location = parsed.locationKey,
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "kill_boss",
        text = "Defeat " .. (parsed.boss or "boss"),
        type = "kill",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "loot_item",
        text = "Loot " .. (itemData.name or "item"),
        type = "loot",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Raid: Join raid -> Travel -> Kill boss -> Win loot
function C.ACQUISITION_TEMPLATES.raid(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "join_raid",
        text = "Join " .. (parsed.instance or "raid") .. " raid",
        type = "grind",
        checkable = true,
    }
    if parsed.locationKey then
        steps[#steps + 1] = {
            id = "travel_raid",
            text = "Travel to " .. (parsed.instance or "raid"),
            type = "travel",
            location = parsed.locationKey,
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "kill_boss",
        text = "Defeat " .. (parsed.boss or "boss"),
        type = "kill",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "win_loot",
        text = "Win " .. (itemData.name or "item"),
        type = "loot",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Reputation: Grind to standing -> Visit vendor -> Purchase
function C.ACQUISITION_TEMPLATES.rep(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "grind_rep",
        text = "Reach " .. (parsed.standing or "Exalted") .. " with " .. (parsed.faction or "faction"),
        type = "grind",
        checkable = true,
        autoCheck = {
            method = "rep_standing",
            faction = parsed.faction,
            required = parsed.standing,
        },
    }
    local vendorKey = parsed.vendorKey
    if vendorKey then
        local loc = C.ACQUISITION_LOCATIONS[vendorKey]
        local vendorName = loc and loc.npc or "vendor"
        steps[#steps + 1] = {
            id = "visit_vendor",
            text = "Visit " .. vendorName .. " in " .. (loc and loc.zone or "Shattrath"),
            type = "travel",
            location = vendorKey,
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "purchase_item",
        text = "Purchase " .. (itemData.name or "item"),
        type = "purchase",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Crafted: Obtain recipe -> Gather mats -> Craft
function C.ACQUISITION_TEMPLATES.crafted(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "obtain_recipe",
        text = "Obtain recipe for " .. (itemData.name or "item"),
        type = "grind",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "gather_mats",
        text = "Gather crafting materials",
        type = "grind",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "craft_item",
        text = "Craft or find crafter for " .. (itemData.name or "item"),
        type = "craft",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- Quest: Travel to zone -> Complete quest -> Choose reward
function C.ACQUISITION_TEMPLATES.quest(itemData, parsed)
    local steps = {}
    if parsed.zone and parsed.zone ~= "" then
        steps[#steps + 1] = {
            id = "travel_zone",
            text = "Travel to " .. parsed.zone,
            type = "travel",
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "complete_quest",
        text = "Find and complete quest",
        type = "grind",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "choose_reward",
        text = "Choose " .. (itemData.name or "item") .. " as reward",
        type = "loot",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- World boss: Form raid -> Travel to spawn -> Kill -> Loot
function C.ACQUISITION_TEMPLATES.world(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "form_raid",
        text = "Form raid group",
        type = "grind",
        checkable = true,
    }
    if parsed.locationKey then
        local loc = C.ACQUISITION_LOCATIONS[parsed.locationKey]
        steps[#steps + 1] = {
            id = "travel_spawn",
            text = "Travel to " .. (parsed.boss or "world boss") .. " in " .. (loc and loc.zone or "Outland"),
            type = "travel",
            location = parsed.locationKey,
            checkable = true,
        }
    end
    steps[#steps + 1] = {
        id = "kill_boss",
        text = "Defeat " .. (parsed.boss or "world boss"),
        type = "kill",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "loot_item",
        text = "Loot " .. (itemData.name or "item"),
        type = "loot",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

-- PvP: Earn points -> Purchase
function C.ACQUISITION_TEMPLATES.pvp(itemData, parsed)
    local steps = {}
    steps[#steps + 1] = {
        id = "earn_currency",
        text = "Earn PvP honor or arena points",
        type = "grind",
        checkable = true,
    }
    steps[#steps + 1] = {
        id = "purchase_item",
        text = "Purchase " .. (itemData.name or "item") .. " from PvP vendor",
        type = "purchase",
        location = "pvp_vendor",
        checkable = true,
        autoCheck = {
            method = "item_in_bags",
            itemId = itemData.id or itemData.itemId,
        },
    }
    return steps
end

--------------------------------------------------------------------------------
-- CROSS-ZONE DIRECTION MAP
-- Approximate bearing (radians) between Outland zones for edge-arrow
-- Key format: "fromZone>toZone"
--------------------------------------------------------------------------------

C.ACQUISITION_ZONE_DIRECTIONS = {
    -- From Hellfire Peninsula
    ["Hellfire Peninsula>Zangarmarsh"]      = 3.14,   -- West
    ["Hellfire Peninsula>Terokkar Forest"]  = 3.93,   -- Southwest
    ["Hellfire Peninsula>Nagrand"]          = 3.53,   -- West-southwest
    ["Hellfire Peninsula>Shattrath City"]   = 3.93,   -- Southwest
    ["Hellfire Peninsula>Blade's Edge Mountains"] = 2.36, -- Northwest
    ["Hellfire Peninsula>Netherstorm"]      = 1.57,   -- North
    ["Hellfire Peninsula>Shadowmoon Valley"] = 4.71,  -- South

    -- From Zangarmarsh
    ["Zangarmarsh>Hellfire Peninsula"]      = 0.0,    -- East
    ["Zangarmarsh>Terokkar Forest"]         = 4.71,   -- South
    ["Zangarmarsh>Nagrand"]                 = 3.93,   -- Southwest
    ["Zangarmarsh>Shattrath City"]          = 4.71,   -- South
    ["Zangarmarsh>Blade's Edge Mountains"]  = 1.57,   -- North

    -- From Terokkar Forest
    ["Terokkar Forest>Shattrath City"]      = 1.57,   -- North
    ["Terokkar Forest>Nagrand"]             = 3.14,   -- West
    ["Terokkar Forest>Zangarmarsh"]         = 1.57,   -- North
    ["Terokkar Forest>Shadowmoon Valley"]   = 0.0,    -- East
    ["Terokkar Forest>Hellfire Peninsula"]  = 0.79,   -- Northeast

    -- From Shattrath City (central hub - directions to all zones)
    ["Shattrath City>Hellfire Peninsula"]   = 0.79,   -- Northeast
    ["Shattrath City>Zangarmarsh"]          = 1.57,   -- North
    ["Shattrath City>Terokkar Forest"]      = 4.71,   -- South
    ["Shattrath City>Nagrand"]              = 3.14,   -- West
    ["Shattrath City>Blade's Edge Mountains"] = 1.18, -- North-northeast
    ["Shattrath City>Netherstorm"]          = 1.18,   -- North-northeast
    ["Shattrath City>Shadowmoon Valley"]    = 0.0,    -- East

    -- From Nagrand
    ["Nagrand>Shattrath City"]              = 0.0,    -- East
    ["Nagrand>Zangarmarsh"]                 = 0.79,   -- Northeast
    ["Nagrand>Terokkar Forest"]             = 0.0,    -- East

    -- From Netherstorm
    ["Netherstorm>Blade's Edge Mountains"]  = 3.93,   -- Southwest
    ["Netherstorm>Shattrath City"]          = 4.32,   -- South-southwest

    -- From Shadowmoon Valley
    ["Shadowmoon Valley>Shattrath City"]    = 3.14,   -- West
    ["Shadowmoon Valley>Terokkar Forest"]   = 3.14,   -- West
    ["Shadowmoon Valley>Hellfire Peninsula"] = 1.57,  -- North

    -- From Blade's Edge Mountains
    ["Blade's Edge Mountains>Zangarmarsh"]  = 4.71,   -- South
    ["Blade's Edge Mountains>Netherstorm"]  = 0.79,   -- Northeast
    ["Blade's Edge Mountains>Shattrath City"] = 4.71, -- South
}

--------------------------------------------------------------------------------
-- HELPER: Generate steps for an item
-- Main entry point used by GearTrackerSteps
--------------------------------------------------------------------------------

function C:GenerateAcquisitionSteps(itemData)
    local sourceType = itemData.sourceType or "world"
    local parser = C.ACQUISITION_PARSERS[sourceType]
    local template = C.ACQUISITION_TEMPLATES[sourceType]

    if not parser or not template then
        -- Fallback: generic "acquire item" step
        return {
            {
                id = "acquire_item",
                text = "Acquire " .. (itemData.name or "item"),
                type = "grind",
                checkable = true,
                autoCheck = {
                    method = "item_in_bags",
                    itemId = itemData.id or itemData.itemId,
                },
            },
        }
    end

    local parsed = parser(itemData)
    return template(itemData, parsed)
end
