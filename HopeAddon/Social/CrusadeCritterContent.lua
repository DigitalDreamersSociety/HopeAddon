--[[
    HopeAddon Crusade Critter Content
    Quip database organized by critter personality

    Quips are organized by:
    - Critter ID (flux, snookimp, shred, emo, cosmo, boomer, diva)
    - Event type (boss_kill, fast_run, slow_run, player_death, zone_entry, dungeon_entry, unlock)

    3D Models use SetDisplayInfo(displayID) for TBC Classic compatibility
    (SetCreature was added in WotLK 3.0.2)

    Zone-specific quips: zone_entry can be either:
    - An array of quips (random selection)
    - A table with zone name keys + 'default' key for fallback

    Display IDs need verification in-game: /script print(UnitDisplayInfo("target"))
]]

local CritterContent = {}
HopeAddon.CritterContent = CritterContent

-- Critter definitions with 3D model data
-- Display IDs VERIFIED via wowhead.com TBC Classic database
-- In-game verification: /script print(UnitDisplayInfo("target"))
--
-- Creature Locations for verification:
-- - Mana Wyrms: Eversong Woods, Netherstorm (Mana Wyrmlings)
-- - Imps: Warlock pet, Blasted Lands, Hellfire Peninsula
-- - Sporebats: Zangarmarsh (Greater Sporebat has blue/green glow)
-- - Bats: Karazhan (Shadowbats), Terokkar caves
-- - Moths: Netherstorm Eco-Domes (Red Moth from pet vendor)
-- - Owls: Dun Morogh (Ironbeak Owl), Teldrassil
-- - Phoenix-Hawks: Tempest Keep (The Eye raid, also in Botanica)
CritterContent.CRITTERS = {
    flux = {
        name = "Flux",
        description = "A panicked Mana Wyrm who accidentally time-traveled to 2007",
        displayID = 5839,  -- Mana Wyrm (VERIFIED - NPC #15274)
        glowColor = { r = 0.61, g = 0.19, b = 1.00 },  -- TBC Purple
        soundOnAppear = "Sound\\Creature\\ManaWyrm\\ManaWyrmAggro.ogg",
        unlocked = true, -- Always unlocked as starter
    },
    snookimp = {
        name = "Snookimp",
        description = "Jersey Shore imp - GTL all day!",
        displayID = 4449,  -- Imp (VERIFIED - NPC #416)
        glowColor = { r = 1.00, g = 0.50, b = 0.00 },  -- Orange
        soundOnAppear = "Sound\\Creature\\Imp\\ImpAggro.ogg",
        unlockHub = "hellfire",
    },
    shred = {
        name = "Shred",
        description = "Extreme sports Sporebat - X Games energy!",
        displayID = 17752,  -- Greater Sporebat (VERIFIED - NPC #18129)
        glowColor = { r = 0.00, g = 0.80, b = 0.80 },  -- Teal
        soundOnAppear = "Sound\\Creature\\Sporebat\\SporeBatAggro.ogg",
        unlockHub = "coilfang",
    },
    emo = {
        name = "Emo",
        description = "Fall Out Boy scene kid bat - dark but deep",
        displayID = 10357,  -- Purple-Red Bat (verify in-game)
        glowColor = { r = 0.40, g = 0.00, b = 0.40 },  -- Dark Purple
        soundOnAppear = "Sound\\Creature\\Bat\\BatPissed.ogg",
        unlockHub = "auchindoun",
    },
    cosmo = {
        name = "Cosmo",
        description = "Dreamy space nerd moth - head in the stars",
        displayID = 19986,  -- Red Moth (VERIFIED - NPC #21009)
        glowColor = { r = 0.50, g = 0.70, b = 1.00 },  -- Light Blue
        soundOnAppear = "Sound\\Creature\\Moth\\MothAggro.ogg",
        unlockHub = "tempest_keep",
    },
    boomer = {
        name = "Boomer",
        description = "OK Boomer energy owl - back in MY day...",
        displayID = 4877,  -- Ironbeak Owl (VERIFIED - NPC #7097)
        glowColor = { r = 0.80, g = 0.60, b = 0.30 },  -- Bronze
        soundOnAppear = "Sound\\Creature\\Owl\\OwlAggro.ogg",
        unlockHub = "caverns",
    },
    diva = {
        name = "Diva",
        description = "Fabulous Phoenix-Hawk - fierce and glamorous!",
        displayID = 19298,  -- Phoenix-Hawk Hatchling (VERIFIED - NPC #20038)
        glowColor = { r = 1.00, g = 0.84, b = 0.00 },  -- Gold
        soundOnAppear = "Sound\\Creature\\DragonHawk\\DragonHawkAggro.ogg",
        unlockHub = "queldanas",
    },
}

-- Dungeon hub definitions for unlock tracking
CritterContent.DUNGEON_HUBS = {
    hellfire = {
        name = "Hellfire Citadel",
        dungeons = { "ramparts", "blood_furnace", "shattered_halls" },
        critter = "snookimp",
    },
    coilfang = {
        name = "Coilfang Reservoir",
        dungeons = { "slave_pens", "underbog", "steamvault" },
        critter = "shred",
    },
    auchindoun = {
        name = "Auchindoun",
        dungeons = { "mana_tombs", "auchenai_crypts", "sethekk_halls", "shadow_lab" },
        critter = "emo",
    },
    tempest_keep = {
        name = "Tempest Keep",
        dungeons = { "mechanar", "botanica", "arcatraz" },
        critter = "cosmo",
    },
    caverns = {
        name = "Caverns of Time",
        dungeons = { "old_hillsbrad", "black_morass" },
        critter = "boomer",
    },
    queldanas = {
        name = "Isle of Quel'Danas",
        dungeons = { "magisters_terrace" },
        critter = "diva",
    },
}

-- Dungeon key to hub mapping
CritterContent.DUNGEON_TO_HUB = {}
for hubKey, hubData in pairs(CritterContent.DUNGEON_HUBS) do
    for _, dungeonKey in ipairs(hubData.dungeons) do
        CritterContent.DUNGEON_TO_HUB[dungeonKey] = hubKey
    end
end

--============================================================
-- QUIP DATABASE
--============================================================

CritterContent.QUIPS = {
    --============================================================
    -- FLUX (Starter) - Panicked Nether Ray, 2007 time traveler
    --============================================================
    flux = {
        boss_kill = {
            "Boss down! Now excuse me, I need to update my MySpace top 8.",
            "OMG that was smoother than my iPod Nano's click wheel!",
            "That fight was shorter than Britney's 2007 haircut!",
            "Owned harder than MySpace got owned by Facebook!",
            "Boss down! That was cleaner than my freshly burned mix CD!",
            "You think 2007 is bad? Wait till you hear about TikTok.",
            "We won! Let me just update my Friendster... wait, is that still a thing?",
        },
        fast_run = {
            "You beat that faster than Facebook beat MySpace!",
            "That run was as good as a Steve Jobs turtleneck!",
            "Faster than loading a webpage on 56k... which isn't hard but STILL!",
        },
        slow_run = {
            "That run felt like Wii remote straight to the TV.",
            "We're moving slower than a Vista laptop, but progress is progress!",
            "Long run! But at least we didn't have to install Windows updates!",
        },
        player_death = {
            "Wiped! At least we didn't get Rick Rolled. ...or DID we?",
            "Setback! But at least we didn't lose our Neopets!",
            "Back in my day this repair cost 2 copper.",
        },
        zone_entry = {
            ["Hellfire Peninsula"] = "2007?! Flip phones! Low-rise jeans! The Dark Portal is REAL?!",
            ["Zangarmarsh"] = "Glowing mushrooms? This is like that screensaver I had on my Dell!",
            ["Terokkar Forest"] = "Bone Wastes... darker than my emo poetry phase. Wait, I had one of those?",
            ["Nagrand"] = "Floating islands! The physics make less sense than my MySpace layout!",
            ["Netherstorm"] = "Purple lightning! It's like a Windows Media Player visualizer!",
            ["Shadowmoon Valley"] = "Green fire everywhere... like my AIM buddy icon went nuclear.",
            default = {
                "Trucker hats? Soulja Boy? ...Actually that slaps, tell 'em!",
                "The Dark Portal... more ominous than my dial-up modem.",
                "Outland! It's like stepping into the Matrix... if the Matrix was on fire.",
            },
        },
        dungeon_entry = {
            "Into the dungeon! Hopefully better than my eBay auction luck.",
            "Let's do this! I've got a raid in 2024 to get back to.",
        },
    },

    --============================================================
    -- SNOOKIMP (Hellfire Citadel)
    --============================================================
    snookimp = {
        boss_kill = {
            "That boss's tan was WEAK. Needed more fel fire!",
            "Gym, Tan, LOOT-ry! Just smushed that boss!",
            "Look at that loot glow! Almost as orange as my beautiful fel tan!",
            "That boss got smooshed harder than my hair in a rainstorm!",
            "That boss had NO GAME! We showed 'em what GTL is all about!",
            "YEAAAH! That boss got BODIED! Shore style, baby!",
            "The situation is OVER! And by situation I mean that boss!",
            "Yo the vibes in here are IMMACULATE after that kill!",
            "SMUSHED! That boss got absolutely SMUSHED!",
        },
        fast_run = {
            "Sprint through the dungeon like it's dollar drink night!",
            "FAST! Like running to the shore before the tide comes in!",
        },
        slow_run = {
            "Slow but we looked GOOD doing it. That's all that matters!",
            "Slow but STYLISH! Perfection takes TIME!",
            "Took a while but we looked GOOD doing it! That's what matters!",
        },
        player_death = {
            "We got BODIED! But we're coming BACK! Shore strong, baby!",
            "That was messier than Pauly D drama! We bounce back!",
        },
        zone_entry = {
            ["Hellfire Peninsula"] = "Hellfire Peninsula! The REDDEST place I've ever seen! Love it!",
            ["Zangarmarsh"] = "Swamp vibes! Not ideal for the hair, but the GLOW is everything!",
            ["Terokkar Forest"] = "Bones? Spooky! But we stay FRESH even in graveyards!",
            ["Nagrand"] = "Green hills! Finally somewhere good for my post-dungeon tan!",
            default = {
                "This place needs a hot tub and some techno music.",
                "New zone, new GAINS! Let's GO!",
            },
        },
        dungeon_entry = {
            "Time to get our gym on! GTL means Grind Tank Loot!",
            "Let's SMUSH some demons!",
        },
    },

    --============================================================
    -- SHRED (Coilfang Reservoir)
    --============================================================
    shred = {
        boss_kill = {
            "SICK run, bro! That kill was totally X Games worthy!",
            "That was a perfect 10 from the judges! Tony Hawk approves!",
            "Drop in, shred out! Another boss in the bag!",
            "Radical! That boss got sent to the SHADOW REALM of shred!",
            "That boss BAILED so hard! Full scorpion, bro!",
            "Full commit, no bail! That's how we SHRED bosses!",
            "That kill was SICK! Tony Hawk Pro Skater combo level sick!",
        },
        fast_run = {
            "Speed run! Faster than a half-pipe drop! RADICAL!",
            "That was LIGHTNING! Like a downhill bomb run!",
        },
        slow_run = {
            "Cruisin' the scenic route. Style points matter!",
            "Chill run! Sometimes you gotta cruise and enjoy the vibes, bro!",
            "Chill run! Like a scenic chairlift ride!",
        },
        player_death = {
            "Bailed hard, but that's how you learn! Back on the board!",
            "WIPEOUT! But like, metaphorically! Get back up and SEND IT!",
        },
        zone_entry = {
            ["Hellfire Peninsula"] = "Red rocks! Perfect for some GNARLY tricks! Let's SHRED!",
            ["Zangarmarsh"] = "Zangarmarsh! The mushrooms here are GNARLY terrain features!",
            ["Terokkar Forest"] = "Bone ramps! Nature's skate park, bro!",
            ["Nagrand"] = "Floating islands! The ULTIMATE aerial zone!",
            ["Netherstorm"] = "Purple lightning and floating rocks! EXTREME conditions!",
            default = {
                "Dude, these floating spores are like terrain features! SICK!",
                "New zone to SHRED! Let's GO!",
            },
        },
        dungeon_entry = {
            "Time to drop in! Let's SHRED!",
            "Entering the half-pipe of DOOM! Let's go!",
        },
    },

    --============================================================
    -- EMO (Auchindoun)
    --============================================================
    emo = {
        boss_kill = {
            "Thnks fr th Mmrs... of killing that boss!",
            "Sugar, we're goin' down... the dungeon. To victory.",
            "Victory darker than my eyeliner. That's saying something.",
            "We won! This calls for a celebratory Twilight marathon! Team Edward btw.",
            "Boss down. Like my expectations of ever being understood.",
            "Another victory for the kids who sit alone at lunch. WE RISE!",
        },
        fast_run = {
            "Faster than unfriending people who don't get my playlist!",
            "That was quick. Like happiness. Fleeting. ...Okay that was too dark even for me.",
        },
        slow_run = {
            "This run had more filler than a Panic! At The Disco song title.",
            "Long run... like my suffering. But we endure.",
            "Long run... like waiting for MCR's next album.",
            "Slow run. Sometimes art takes time. This was art. Dark art.",
        },
        player_death = {
            "*changes AIM away message to 'dead inside'* Let's go again.",
            "We died. *sigh* At least the pain is real.",
            "The world is ugly, but we're beautiful. Let's run it back!",
        },
        zone_entry = {
            ["Hellfire Peninsula"] = "All this fire and brimstone... finally, aesthetics that MATCH my soul.",
            ["Zangarmarsh"] = "Glowing fungus... like the neon signs at that one venue. *sighs*",
            ["Terokkar Forest"] = "Terokkar Forest... the desolation speaks to my soul. Beautiful.",
            ["Nagrand"] = "It's pretty. I hate how much I don't hate it.",
            ["Shadowmoon Valley"] = "Green fire, eternal darkness... this is my VIBE.",
            default = {
                "The Bone Wastes. Finally, a place that understands me.",
                "Auchindoun... a monument to sorrow. I feel at home.",
            },
        },
        dungeon_entry = {
            "Into the darkness. Where I belong.",
            "This place gets me. Dark, misunderstood, full of ghosts.",
        },
    },

    --============================================================
    -- COSMO (Tempest Keep)
    --============================================================
    cosmo = {
        boss_kill = {
            "The space magic is strong with this group!",
            "May the loot be with you!",
            "That's one small step for DPS, one giant leap for our run!",
            "To infinity and beyond the trash! ...Wait what were we doing?",
            "This victory sparkles like a distant galaxy!",
            "Boss down! ...Did you know there are billions of stars out there?",
            "Victory! Almost as beautiful as a supernova. *sighs wistfully*",
        },
        fast_run = {
            "That's hyperdrive efficiency!",
            "Speed of light! Well, not literally but... *trails off*",
            "Fast! Like a shooting star! I love shooting stars.",
            "Zoom! We're like comets! Beautiful, fast comets.",
        },
        slow_run = {
            "Long journey... like light traveling across galaxies. Worth it.",
            "Takes time... like stellar formation. Beautiful, really.",
            "The universe doesn't rush. Neither did we! *stares up*",
        },
        player_death = {
            "Houston, we HAD a problem. Going again!",
            "We died... like stars eventually do. But we respawn!",
            "Setback! *stares at sky* At least the cosmos continues.",
        },
        zone_entry = {
            ["Hellfire Peninsula"] = "Red planet detected! Engaging exploration mode!",
            ["Zangarmarsh"] = "Swamp planet vibes! Classic sci-fi terrain!",
            ["Terokkar Forest"] = "Ooh bones! *stares at sky* Sorry, was thinking about nebulas.",
            ["Nagrand"] = "Anti-gravity islands! The physics here are WILD!",
            ["Netherstorm"] = "Deep space territory! Scanners at maximum!",
            ["Shadowmoon Valley"] = "Green glow everywhere... *zones out thinking about galaxies*",
            default = {
                "Look at those ethereals... I wonder if they've seen nebulas.",
                "The stars here are different... *trails off*",
            },
        },
        dungeon_entry = {
            "Engaging exploration mode! *stares at nearest light source*",
            "Into the unknown... like the Voyager probes. So inspiring.",
        },
    },

    --============================================================
    -- BOOMER (Caverns of Time)
    --============================================================
    boomer = {
        boss_kill = {
            "We wiped 40 times on that boss back in my day!",
            "We walked uphill BOTH WAYS to this dungeon!",
            "Attunement quests built CHARACTER! Kids these days...",
            "That's how we did it in VANILLA! Well, mostly we wiped, but STILL!",
            "Nice! Nothing like my Ragnaros kill, but close.",
            "That boss got what was coming! Just like retail got what was coming!",
            "Victory! BRB, lawn needs mowing. At 6am. As one does.",
            "That's a kill! Now hold on, I need to go check the thermostat. Who touched it?",
            "That boss went down like gas prices used to! Remember $1 gas?",
        },
        fast_run = {
            "Fast! Back in my day, dungeons took 4 hours and we LIKED it!",
            "Fast! Though in MY day, fast meant finishing before the server crashed!",
        },
        slow_run = {
            "NOW this is a proper dungeon pace! Savoring the content like we used to!",
            "NOW this is a proper dungeon pace! Like the old days!",
        },
        player_death = {
            "Youngsters these days can't handle ONE wipe! In my day, we wiped for FUN!",
            "Wiped! In MY day we walked back 20 minutes. Uphill. Both ways.",
        },
        zone_entry = {
            ["Tanaris"] = "Tanaris! Kids fly over it now. We WALKED every inch!",
            ["Caverns of Time"] = "The Caverns of Time! Where REAL gamers relive REAL content!",
            default = {
                "Back in MY day, this whole zone was contested PvP!",
                "Another zone? In MY day, we only had two continents!",
            },
        },
        dungeon_entry = {
            "Time travel? In MY day we just REMEMBERED the good old days!",
            "Let's show these youngsters how REAL adventurers do it!",
        },
    },

    --============================================================
    -- DIVA (Isle of Quel'Danas / Magisters' Terrace)
    --============================================================
    diva = {
        boss_kill = {
            "That boss was SO last season!",
            "Fierce! Absolutely FIERCE!",
            "The loot? *chef's kiss* Exquisite!",
            "That kill was EVERYTHING, darling!",
            "Slay! And I don't just mean the boss!",
            "Stunning! Gorgeous! Perfect execution, darling!",
            "That boss tried it, and we ATE them UP!",
            "Victory looks FABULOUS on you, sweetie!",
            "The drama! The action! The LOOK! We're serving excellence!",
        },
        fast_run = {
            "Efficiency is the new black, darling!",
            "Speed? We invented it. You're welcome.",
            "Fast AND fabulous! That's our signature look!",
        },
        slow_run = {
            "Fashionably late is STILL fashionable!",
            "We're not slow, we're SAVORING the moment!",
            "Excellence takes TIME, darling. And we are EXCELLENT.",
        },
        player_death = {
            "Drama! But we RISE, darling!",
            "A setback? Please. Stars fall before they shine!",
            "That was just a costume change, honey. We're BACK!",
        },
        zone_entry = {
            ["Isle of Quel'Danas"] = "Isle of Quel'Danas! The most FABULOUS island in all of Azeroth!",
            default = {
                "Sun, drama, and demons? My kind of vacation!",
                "Finally, a zone worthy of MY presence!",
            },
        },
        dungeon_entry = {
            "Magisters' Terrace! Where the ELITE demons fall!",
            "Time to show Kael'thas what REAL style looks like!",
            "This terrace needs some redecorating. With VIOLENCE!",
        },
    },
}

--============================================================
-- UNLOCK MESSAGES
--============================================================

CritterContent.UNLOCK_MESSAGES = {
    snookimp = "NEW CRITTER UNLOCKED! Snookimp wants to GTL with you!",
    shred = "NEW CRITTER UNLOCKED! Shred is ready to send it!",
    emo = "NEW CRITTER UNLOCKED! Emo wants to share their playlist...",
    cosmo = "NEW CRITTER UNLOCKED! Cosmo is stargazing in your direction!",
    boomer = "NEW CRITTER UNLOCKED! Boomer has some opinions to share...",
    diva = "NEW CRITTER UNLOCKED! Diva is ready to slay with you, darling!",
}

--============================================================
-- API FUNCTIONS
--============================================================

--[[
    Get a random quip for the given critter and event
    @param critterId string - Critter identifier
    @param eventType string - Event type (boss_kill, fast_run, etc.)
    @param context string|nil - Optional context (e.g., zone name for zone_entry)
    @return string|nil - Random quip or nil if none available
]]
function CritterContent:GetQuip(critterId, eventType, context)
    local critterQuips = self.QUIPS[critterId]
    if not critterQuips then
        -- Fall back to flux
        critterQuips = self.QUIPS.flux
    end

    local eventQuips = critterQuips[eventType]
    if not eventQuips then
        return nil
    end

    -- Check if eventQuips is a zone-specific table (has string keys or 'default')
    if eventQuips.default or (context and eventQuips[context]) then
        -- Zone-specific quip table
        if context and eventQuips[context] then
            -- Direct zone match - return the string
            return eventQuips[context]
        elseif eventQuips.default then
            -- Fall back to default pool
            local defaultQuips = eventQuips.default
            if type(defaultQuips) == "table" and #defaultQuips > 0 then
                return defaultQuips[math.random(#defaultQuips)]
            elseif type(defaultQuips) == "string" then
                return defaultQuips
            end
        end
        return nil
    end

    -- Standard array of quips
    if #eventQuips == 0 then
        return nil
    end

    return eventQuips[math.random(#eventQuips)]
end

--[[
    Get critter data
    @param critterId string - Critter identifier
    @return table|nil - Critter data table
]]
function CritterContent:GetCritter(critterId)
    return self.CRITTERS[critterId]
end

--[[
    Get all unlocked critters
    @param unlockedList table - List of unlocked critter IDs
    @return table - Array of critter data with IDs
]]
function CritterContent:GetUnlockedCritters(unlockedList)
    local result = {}
    for _, critterId in ipairs(unlockedList) do
        local critter = self.CRITTERS[critterId]
        if critter then
            local data = {}
            for k, v in pairs(critter) do
                data[k] = v
            end
            data.id = critterId
            table.insert(result, data)
        end
    end
    return result
end

--[[
    Check if a hub is complete (all dungeons done)
    @param hubKey string - Hub identifier
    @param completedDungeons table - Table of completed dungeon keys
    @return boolean - True if all dungeons in hub are complete
]]
function CritterContent:IsHubComplete(hubKey, completedDungeons)
    local hub = self.DUNGEON_HUBS[hubKey]
    if not hub then return false end

    for _, dungeonKey in ipairs(hub.dungeons) do
        if not completedDungeons[dungeonKey] then
            return false
        end
    end
    return true
end

--[[
    Get the critter unlocked by completing a hub
    @param hubKey string - Hub identifier
    @return string|nil - Critter ID that would be unlocked
]]
function CritterContent:GetHubCritter(hubKey)
    local hub = self.DUNGEON_HUBS[hubKey]
    return hub and hub.critter
end

--[[
    Get hub progress
    @param hubKey string - Hub identifier
    @param completedDungeons table - Table of completed dungeon keys
    @return number, number - Completed count, total count
]]
function CritterContent:GetHubProgress(hubKey, completedDungeons)
    local hub = self.DUNGEON_HUBS[hubKey]
    if not hub then return 0, 0 end

    local completed = 0
    local total = #hub.dungeons
    for _, dungeonKey in ipairs(hub.dungeons) do
        if completedDungeons[dungeonKey] then
            completed = completed + 1
        end
    end
    return completed, total
end
