--[[
    HopeAddon Crusade Critter Content
    Quip database organized by critter personality

    Quips are organized by:
    - Critter ID (chomp, snookimp, shred, emo, cosmo, boomer, diva)
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
    chomp = {
        name = "Chomp",
        description = "A ravenous Ravager from 2007 - was about to eat fast food for a month straight, then woke up here!",
        displayID = 17061,  -- Captive Ravager Hatchling (green Azuremyst model)
        glowColor = { r = 0.00, g = 0.60, b = 0.20 },  -- Dark Green
        soundOnAppear = "Sound\\Creature\\Ravager\\RavagerAggro.ogg",
        unlockLevel = 1,  -- Always available (starter)
    },
    snookimp = {
        name = "Snookimp",
        description = "Jersey Shore imp - GTL all day!",
        displayID = 4449,  -- Imp (VERIFIED - NPC #416)
        glowColor = { r = 1.00, g = 0.50, b = 0.00 },  -- Orange
        soundOnAppear = "Sound\\Creature\\Imp\\ImpAggro.ogg",
        unlockLevel = 60,  -- Hellfire Citadel dungeons
    },
    shred = {
        name = "Shred",
        description = "Extreme sports Sporebat - X Games energy!",
        displayID = 17752,  -- Greater Sporebat (VERIFIED - NPC #18129)
        glowColor = HopeAddon.colors.OUTLAND_TEAL,  -- Teal
        soundOnAppear = "Sound\\Creature\\Sporebat\\SporeBatAggro.ogg",
        unlockLevel = 62,  -- Coilfang Reservoir
    },
    emo = {
        name = "Emo",
        description = "Fall Out Boy scene kid bat - dark but deep",
        displayID = 1566,  -- Darkspear Bat (dark model)
        glowColor = { r = 0.40, g = 0.00, b = 0.40 },  -- Dark Purple
        soundOnAppear = "Sound\\Creature\\Bat\\BatPissed.ogg",
        unlockLevel = 64,  -- Auchindoun
        modelOffset = -0.5,  -- Push model back (negative Z = further from camera)
    },
    cosmo = {
        name = "Cosmo",
        description = "Dreamy space nerd moth - head in the stars",
        displayID = 19986,  -- Red Moth (VERIFIED - NPC #21009)
        glowColor = { r = 0.50, g = 0.70, b = 1.00 },  -- Light Blue
        soundOnAppear = "Sound\\Creature\\Moth\\MothAggro.ogg",
        unlockLevel = 68,  -- Tempest Keep
        modelOffset = -0.3,  -- Push model back (negative Z = further from camera)
    },
    boomer = {
        name = "Boomer",
        description = "OK Boomer energy owl - back in MY day...",
        displayID = 4877,  -- Ironbeak Owl (VERIFIED - NPC #7097)
        glowColor = { r = 0.80, g = 0.60, b = 0.30 },  -- Bronze
        soundOnAppear = "Sound\\Creature\\Owl\\OwlAggro.ogg",
        unlockLevel = 66,  -- Caverns of Time
    },
    diva = {
        name = "Diva",
        description = "Fabulous Phoenix-Hawk - fierce and glamorous!",
        displayID = 19298,  -- Phoenix-Hawk Hatchling (VERIFIED - NPC #20038)
        glowColor = HopeAddon.colors.GOLD_BRIGHT,  -- Gold
        soundOnAppear = "Sound\\Creature\\DragonHawk\\DragonHawkAggro.ogg",
        unlockLevel = 70,  -- Isle of Quel'Danas
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
    -- CHOMP (Starter) - Ravenous Ravager, fast food fiend, 2007
    --============================================================
    chomp = {
        idle = {
            "Man, I miss flip phones. You could SLAM those things shut when you were mad!",
            "Did you know Pluto got demoted in 2006? Still not over it...",
            "I wonder if my Neopets are still alive... probably not.",
            "Hey, remember when we had to WAIT for songs to download? Good times... terrible times.",
            "*checks imaginary MySpace* Still no friend requests. Story of 2007.",
        },
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
        idle = {
            "Yo, when's the next gym sesh? These demons ain't gonna SMUSH themselves!",
            "GTL, baby! Grind, Tan, LOOT! That's the life!",
            "You see my tan? The fel fire really brings out my glow!",
            "This situation is FRESH! We're looking GOOD out here!",
            "*flexes* These gains don't happen by accident, yo!",
        },
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
        idle = {
            "Dude, you ever just look at a cliff and think... 'I could SEND that'?",
            "The vibes here are totally tubular, bro! Maximum chill!",
            "I'm like 90% sure I could grind that railing. Just saying.",
            "Bro, life is like a half-pipe. You gotta commit or bail!",
            "*air guitars* SHRED IT, BRO! Oh wait, wrong kind of shred. Heh.",
        },
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
        idle = {
            "*sigh* Nobody understands the weight of existence like I do.",
            "I wrote a poem about this moment. It's called 'Waiting in Darkness.'",
            "The void stares back... and honestly? It gets me.",
            "My playlist is just Fall Out Boy and tears. It's fine. I'm fine.",
            "Sometimes I feel like a ghost haunting my own life... deep, right?",
        },
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
        idle = {
            "Did you know there are more stars than grains of sand on Earth? *stares wistfully*",
            "I wonder what's beyond the Twisting Nether... more nether? More twist?",
            "The cosmos is infinite... and so is my curiosity. *zones out*",
            "If light takes millions of years to reach us... are we seeing the past? Whoa.",
            "*staring upward* Sorry, what? I was thinking about black holes again.",
        },
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
        idle = {
            "Back in MY day, we didn't have quest markers. We READ the quest text!",
            "Kids these days with their flying mounts... we WALKED everywhere!",
            "You know what's wrong with games today? Too many tutorials!",
            "In vanilla, THIS would've been a 40-man raid. Just saying.",
            "*adjusts spectacles* The lawn isn't going to mow itself, you know.",
        },
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
        idle = {
            "Darling, excellence doesn't happen by accident. It takes WORK and GLAM!",
            "Is my feather ruffled? Someone check. Image is EVERYTHING!",
            "The spotlight isn't going to find itself, sweetie. We CREATE the moment!",
            "Fashion tip: fel green is SO last expansion. Gold is timeless!",
            "*preens dramatically* Mirror mirror on the wall... yes, still fabulous.",
        },
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
-- BOSS TIPS DATABASE
-- Personality-flavored mechanics explanations for boss teaching system
-- Tips marked with heroic = true only show in heroic mode
--============================================================

CritterContent.BOSS_TIPS = {
    --============================================================
    -- CHOMP (2007 references, fast food, old tech/memes)
    --============================================================
    chomp = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "This orc is like the AOL login screen - annoying but manageable!", heroic = false },
            { text = "He calls healing adds at 50% - burn them like spam emails!", heroic = false },
            { text = "Mortal Strike debuff on tank - watch HP like a Tamagotchi!", heroic = false },
            { text = "HEROIC: His Surge hits harder than a Razr phone bill - spread out!", heroic = true },
        },
        omor_the_unscarred = {
            { text = "This demon summons Felhounds - kill them FAST like you're closing pop-ups!", heroic = false },
            { text = "He does this fel fire thing... standing in green = bad, like buffering!", heroic = false },
            { text = "Tank him near the door for line-of-sight on Shadowbolt!", heroic = false },
            { text = "HEROIC: Treacherous Aura hits WAY harder - spread like away messages!", heroic = true },
        },
        nazan = {
            { text = "First kill Vazruden, then his dragon shows up - it's a two-parter like a flip phone!", heroic = false },
            { text = "Fire bombs on the ground - move out like your ringtone just went off!", heroic = false },
            { text = "When Nazan lands, tank him facing away - fireball is no joke!", heroic = false },
            { text = "HEROIC: The fire hits like a bad MySpace profile - stay mobile!", heroic = true },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control incoming! It's like getting your AIM hacked!", heroic = false },
            { text = "Exploding Beaker does major damage - interrupt it like spam!", heroic = false },
            { text = "Stay spread so Mind Control doesn't wreck the group!", heroic = false },
        },
        broggok = {
            { text = "Four waves of adds before the boss - like loading a webpage on dialup!", heroic = false },
            { text = "Poison clouds everywhere - don't stand in them, move around!", heroic = false },
            { text = "Tank him away from the cages for more room to move!", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Adds around the room - pull them first or face chaos!", heroic = false },
            { text = "When he yells 'Come closer' - RUN AWAY, it's an explosion!", heroic = false },
            { text = "Shadow Bolt Volley can be interrupted - get on that!", heroic = false },
            { text = "HEROIC: His Burning Nova hurts more than losing your Neopets!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices his adds for power - kill them fast before he consumes them!", heroic = false },
            { text = "Death Coil fears the tank - off-tank be ready to pick up!", heroic = false },
            { text = "Dark Spin is his whirlwind - melee get OUT!", heroic = false },
        },
        blood_guard_porung = {
            { text = "Heroic-only bonus boss - spawns with adds in the gauntlet!", heroic = true },
            { text = "Clear the adds first, then focus the Blood Guard!", heroic = true },
            { text = "He hits like a brick - tank cooldowns ready!", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two-headed ogre - they argue and swap threat, it's confusing like AIM drama!", heroic = false },
            { text = "Blast Wave knocks back - stay at range if you can!", heroic = false },
            { text = "Fear goes out periodically - tremor totem helps!", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet before him is the real boss - take your time!", heroic = false },
            { text = "Blade Dance makes him spin around - watch your threat!", heroic = false },
            { text = "He charges random targets - spread out!", heroic = false },
            { text = "HEROIC: His damage is cranked up like max volume on a boombox!", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems everywhere! Kill them like closing browser tabs!", heroic = false },
            { text = "Healing totem is priority - don't let him heal!", heroic = false },
            { text = "Lightning Shield hurts melee - casters have it easy here!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Big crab energy! Grievous Wound stacks on tank - heal through it!", heroic = false },
            { text = "Water Spit hits random targets - can't avoid it, just heal!", heroic = false },
            { text = "Frenzy at low health - burn him down fast at the end!", heroic = false },
        },
        quagmirran = {
            { text = "Poison Bolt Volley is nasty - nature resist helps!", heroic = false },
            { text = "Cleave is brutal - don't stand in front!", heroic = false },
            { text = "Acid Spray is a cone - tank face him away from the group!", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and explode - move away from them!", heroic = false },
            { text = "Spore Cloud reduces hit chance - annoying but manageable!", heroic = false },
            { text = "At 20% he goes frenzy - pop cooldowns!", heroic = false },
        },
        ghazan = {
            { text = "Giant hydra! Acid Spit is a frontal cone - tank aim carefully!", heroic = false },
            { text = "Tail Sweep hits behind - melee stay at the sides!", heroic = false },
            { text = "Acid Breath pools on ground - don't stand in the green!", heroic = false },
        },
        swamplord_muselek = {
            { text = "He has a pet bear - crowd control it if you can!", heroic = false },
            { text = "Freezing Trap on random targets - break them out fast!", heroic = false },
            { text = "Multi-Shot hurts - spread out a bit!", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning bounces - spread OUT like a proper playlist!", heroic = false },
            { text = "Static Charge marks someone - run away from the group!", heroic = false },
            { text = "Levitate puts people in the air - just wait it out!", heroic = false },
            { text = "HEROIC: Spawns Spore Striders - kill them or they explode!", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals spawn - tank them up and AoE down!", heroic = false },
            { text = "Enveloping Winds is a cyclone - wait it out!", heroic = false },
            { text = "Lung Burst does damage over time - healers stay alert!", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Gnome engineer with adds - kill the Mechanics first!", heroic = false },
            { text = "They heal him if not killed - priority targets!", heroic = false },
            { text = "Saw Blade is a frontal cone - tank face away!", heroic = false },
        },
        warlord_kalithresh = {
            { text = "Don't DPS him near the distillers - he uses them to buff!", heroic = false },
            { text = "Click the distiller when he channels to interrupt his buff!", heroic = false },
            { text = "Impale hurts the tank - save cooldowns!", heroic = false },
            { text = "HEROIC: His damage and buff are way stronger - distillers are CRITICAL!", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast hits like dial-up disconnecting mid-download - INTERRUPT!", heroic = false },
            { text = "Dark Shell reflects damage like a MySpace page with autoplay music - STOP DPS!", heroic = false },
            { text = "Purple void zone - move out like you're dodging pop-up ads!", heroic = false },
        },
        tavarok = {
            { text = "Earthquake shakes everyone like a flip phone on vibrate!", heroic = false },
            { text = "Crystal Prison is like getting stuck on a loading screen - break them out!", heroic = false },
            { text = "Arcing Smash frontal cleave - stay behind him like hiding your browser history!", heroic = false },
        },
        yor = {
            { text = "This void lord is like a corrupted download from LimeWire - sketchy!", heroic = false },
            { text = "Double Breath is frontal - don't stand there like a frozen Windows cursor!", heroic = false },
            { text = "Stomp knocks everyone back - brace yourself like dial-up connecting!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds spawn like AIM buddy notifications - kill them fast!", heroic = false },
            { text = "Frost Nova freezes everyone - more frozen than your Neopets account!", heroic = false },
            { text = "He Blinks around like switching between MSN and AIM - casters have it easier!", heroic = false },
            { text = "HEROIC: More adds than spam in your inbox - AoE is your friend!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic slows casting like 56k modem speeds - GET CLOSE to break it!", heroic = false },
            { text = "Carnivorous Bite hurts worse than your Tamagotchi dying - heal through it!", heroic = false },
            { text = "Focus Fire burns a spot - move out like your chair when mom walks in!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone like an unexpected phone call - tremor totem!", heroic = false },
            { text = "Ribbon of Souls chases you like chain emails - kite it away!", heroic = false },
            { text = "At 25% he summons an Avatar - kill it faster than deleting spam!", heroic = false },
            { text = "HEROIC: The Avatar hits like your dad's AOL bill - save cooldowns!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn like away messages on AIM - each one different!", heroic = false },
            { text = "Chain Lightning bounces like a forwarded email - spread out!", heroic = false },
            { text = "New elementals at health thresholds - more adds than your buddy list!", heroic = false },
        },
        anzu = {
            { text = "This raven god is like a corrupted MP3 file - dark and glitchy!", heroic = false },
            { text = "Spell Bomb marks you - run from the group like avoiding chain emails!", heroic = false },
            { text = "Cyclone of Feathers is AoE - move out like minimizing a virus popup!", heroic = false },
            { text = "HEROIC: He hits harder than a Blue Screen of Death - respect it!", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion is HUGE - hide behind a pillar like minimizing windows!", heroic = false },
            { text = "He Blinks like switching browser tabs - ranged stay close!", heroic = false },
            { text = "Slow debuff is annoying like waiting for a page to load!", heroic = false },
            { text = "HEROIC: Arcane Explosion can one-shot like a virus - pillars are LIFE!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish the Ritualists first - can't skip like unskippable DVD menus!", heroic = false },
            { text = "Fear is constant like pop-up ads - tremor totem is clutch!", heroic = false },
            { text = "Corrosive Acid melts armor like a scratched CD - hurts the tank!", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos - everyone fights like a MySpace comment war - spread out!", heroic = false },
            { text = "During Chaos you lose control like lag on dial-up - just accept it!", heroic = false },
            { text = "War Stomp stuns melee - back out faster than closing LimeWire!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers spawn from portals like download progress bars - AoE them!", heroic = false },
            { text = "Draw Shadows pulls everyone in like a chain letter - run away after!", heroic = false },
            { text = "Rain of Fire hurts like your phone bill after ringtone downloads!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom hits like speakers at max volume - GET CLOSE to reduce it!", heroic = false },
            { text = "Murmur's Touch is a bomb - run away like escaping a rickroll!", heroic = false },
            { text = "Thundering Storm hits ranged like surprise AOL updates - stay in melee!", heroic = false },
            { text = "HEROIC: Everything hits harder than reality after a LAN party!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift - match colors like sorting your iPod playlists!", heroic = false },
            { text = "Opposite charges hurt together like mixing AIM and MSN friends!", heroic = false },
            { text = "Head Crack hits harder than dropping your Razr phone!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase you like telemarketers - kite them!", heroic = false },
            { text = "Dragon's Breath cone - don't group up like a crowded AOL chatroom!", heroic = false },
            { text = "Arcane Blast interrupts your flow like buffering - interrupt back!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Nether Wraiths spawn like toolbar installations - AoE them fast!", heroic = false },
            { text = "Mind Control is random - kill the MC'd player like defragging!", heroic = false },
            { text = "Disgruntled Employees are adds - worse than IT support tickets!", heroic = false },
            { text = "HEROIC: His damage calculated like overdue library fees - HURTS!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "She summons adds like friend requests - AoE them down!", heroic = false },
            { text = "Arcane Resonance marks you like a poke notification - spread out!", heroic = false },
            { text = "Reinforcements at health thresholds - more waves than a Limewire queue!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "Seedling adds explode like chain emails - kill them fast!", heroic = false },
            { text = "Tree Form heals him like clearing your cookies - burn through it!", heroic = false },
            { text = "Nature's Blessing heals - interrupt like closing pop-ups!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice drains life like pay-per-minute internet - break them out!", heroic = false },
            { text = "Hellfire hurts everyone like sharing headphones - spread out!", heroic = false },
            { text = "Enrage at low health - burn him faster than a CD burner!", heroic = false },
        },
        laj = {
            { text = "Color shifts mean immunity - like mood rings but deadlier!", heroic = false },
            { text = "Each color immune to different schools - adapt like switching screen names!", heroic = false },
            { text = "Thorn Lasher adds spawn - more annoying than forum trolls!", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings walk to him like download progress - kill before they reach!", heroic = false },
            { text = "Saplings heal him if they reach - worse than losing your save file!", heroic = false },
            { text = "Arcane Volley is group damage like lag spikes - heal through it!", heroic = false },
            { text = "HEROIC: More saplings than browser tabs - DPS on point!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone spawns under you - MOVE like clicking 'X' on pop-ups!", heroic = false },
            { text = "Seed of Corruption spreads like a worm virus - dispel or spread out!", heroic = false },
            { text = "Shadow Nova hits everyone like a mass email - heal through it!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind is deadly - melee GET OUT like alt-tabbing from games!", heroic = false },
            { text = "Gift of the Doomsayer heals her - dispel it like spam filters!", heroic = false },
            { text = "Shadow Wave frontal cone - face away like hiding your screen!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire leaves burns on ground - move out like avoiding dial-up fees!", heroic = false },
            { text = "Charge knockback - stay away from edges like cliff-jumping in games!", heroic = false },
            { text = "Knock Away sends tank flying like an ejected floppy disk!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "He splits into copies like duplicating MP3s - kill the fakes!", heroic = false },
            { text = "Mind Rend DOT hurts like realizing you forgot to save - dispel it!", heroic = false },
            { text = "66% and 33% he copies - more dupes than burnt CDs!", heroic = false },
            { text = "HEROIC: Illusions hit hard as the real deal - no compression!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind spins like a loading cursor - melee BACK AWAY!", heroic = false },
            { text = "Mortal Strike debuff hurts like expired coupons - heal through it!", heroic = false },
            { text = "Simple fight - easier than setting up a printer in 2007!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight - he charges around like dial-up connecting - stay mobile!", heroic = false },
            { text = "Holy Light heals him like ctrl+z - INTERRUPT IT!", heroic = false },
            { text = "Consecration burns - move out like closing embarrassing tabs!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall like your Neopets - if he dies, you fail!", heroic = false },
            { text = "Wing Buffet knockback - position carefully like arranging desktop icons!", heroic = false },
            { text = "Sand Breath cone - face away from group like hiding your playlist!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss - kill him before the next one like closing browser tabs!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt like muting autoplay videos!", heroic = false },
            { text = "Time Lapse rewinds you like hitting back on your browser - disorienting!", heroic = false },
        },
        temporus = {
            { text = "Another portal boss - DPS race like downloading before mom picks up the phone!", heroic = false },
            { text = "Hasten speeds him up like switching to broadband - dangerous at low HP!", heroic = false },
            { text = "Mortal Wound stacks like unread emails - heal through it!", heroic = false },
        },
        aeonus = {
            { text = "Final boss - all portals led here like finishing a quest chain!", heroic = false },
            { text = "Sand Breath frontal cone - face away from group like a sneeze!", heroic = false },
            { text = "Time Stop freezes everyone like Windows crashing - wait it out!", heroic = false },
            { text = "HEROIC: He hits harder than your dad seeing the phone bill!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains mana crystals like charging a flip phone - destroy them!", heroic = false },
            { text = "Fel Explosion after draining - hits like realizing you're out of minutes!", heroic = false },
            { text = "Mana Rage is dangerous - focus crystals like blocking spyware!", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds chase you like pop-up ads - kill or kite!", heroic = false },
            { text = "Overload buffs damage but hurts - like overclocking your PC!", heroic = false },
            { text = "Chain Lightning bounces like a forwarded joke - spread out!", heroic = false },
            { text = "HEROIC: More Pure Energies than toolbar installs - chaos!", heroic = true },
        },
        priestess_delrissa = {
            { text = "4 random adds - like getting matched in a chatroom!", heroic = false },
            { text = "CC is key - control them like your buddy list permissions!", heroic = false },
            { text = "Kill order depends on adds - adapt like switching screen names!", heroic = false },
            { text = "HEROIC: Adds hit like angry forum mods - respect them!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Kill the Phoenix Egg - delete it like clearing your cache!", heroic = false },
            { text = "Flamestrike targets randoms - move out faster than closing pop-ups!", heroic = false },
            { text = "Gravity Lapse floats everyone - swim to him like navigating dial-up lag!", heroic = false },
            { text = "Pyroblast is like an unwanted download - INTERRUPT IT!", heroic = false },
            { text = "HEROIC: Phoenix respawns faster than spam - egg priority is critical!", heroic = true },
        },
    },

    --============================================================
    -- SNOOKIMP (GTL metaphors, gym/tan comparisons, Jersey Shore energy)
    --============================================================
    snookimp = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "Yo this orc is like a bouncer - hits hard but you can outsmooth him!", heroic = false },
            { text = "He calls healers at 50% - SMUSH them like protein shakes!", heroic = false },
            { text = "Mortal Strike is like skipping leg day - hurts!", heroic = false },
            { text = "HEROIC: His Surge is like a Jersey turnpike toll - painful!", heroic = true },
        },
        omor_the_unscarred = {
            { text = "This demon summons dogs - kick 'em out like bad club guests!", heroic = false },
            { text = "Green fire is NOT a tanning bed - don't stand in it!", heroic = false },
            { text = "Tank him by the door - tactical like finding parking at the Shore!", heroic = false },
        },
        nazan = {
            { text = "Kill the rider first, then the dragon's like 'I got next'!", heroic = false },
            { text = "Fire on the ground - dance around it like you're at Karma!", heroic = false },
            { text = "Dragon breaths fire - face him away from the squad!", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control! Someone's about to catch hands from their own team!", heroic = false },
            { text = "Exploding Beaker - interrupt that like a bad pickup line!", heroic = false },
            { text = "Spread out so MC doesn't wreck the whole shore house!", heroic = false },
        },
        broggok = {
            { text = "Four waves before the boss - cardio time, baby!", heroic = false },
            { text = "Poison clouds everywhere - worse than hairspray fumes!", heroic = false },
            { text = "Keep moving, stay fresh - that's the GTL way!", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear the adds first - can't have randos at your party!", heroic = false },
            { text = "He says 'Come closer' - NAH BRO, run away!", heroic = false },
            { text = "Shadow Bolts coming in - interrupt that drama!", heroic = false },
            { text = "HEROIC: Burning Nova hits like a bad spray tan - RUN!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices his boys for power - kill them before he gets JUICED!", heroic = false },
            { text = "Death Coil fears the tank - off-tank step UP!", heroic = false },
            { text = "Dark Spin is like a bar fight - melee get OUT!", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: Bonus boss bro! Spawns with his crew in the gauntlet!", heroic = true },
            { text = "HEROIC: Clear the adds first, then SMUSH the guard!", heroic = true },
            { text = "HEROIC: He hits like he lifts - tank cooldowns ready!", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two-headed ogre drama - they argue and swap aggro like exes!", heroic = false },
            { text = "Blast Wave knocks you back - stay at range like avoiding drama!", heroic = false },
            { text = "Fear is constant - tremor totem is your wingman!", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet before him is the REAL workout - pace yourself!", heroic = false },
            { text = "Blade Dance means he's spinning - respect the technique!", heroic = false },
            { text = "He charges random people - spread out like it's last call!", heroic = false },
            { text = "HEROIC: His damage is CRANKED - tank better be SWOLE!", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems everywhere like beach umbrellas - knock 'em down!", heroic = false },
            { text = "Healing totem is priority - don't let him recover!", heroic = false },
            { text = "Lightning Shield hurts melee - casters got the easy gains!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Big crab bro! Grievous wounds stack - healers stay focused!", heroic = false },
            { text = "Water Spit hits random - just heal through it!", heroic = false },
            { text = "Frenzy at low health - he's got that GTL energy!", heroic = false },
        },
        quagmirran = {
            { text = "Poison is nastier than gas station sushi - nature resist helps!", heroic = false },
            { text = "Don't stand in front - cleave is like a bouncer's punch!", heroic = false },
            { text = "Acid Spray cone - tank aims him away from the squad!", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and POP - move like you're dodging drama!", heroic = false },
            { text = "Spore Cloud messes with your hit - annoying but whatever!", heroic = false },
            { text = "At 20% he frenzies - pop those cooldowns like protein!", heroic = false },
        },
        ghazan = {
            { text = "Giant hydra bro! Acid Spit is frontal - tank aim careful!", heroic = false },
            { text = "Tail Sweep smacks the back - melee stay on the sides!", heroic = false },
            { text = "Green pools on ground - don't stand in that mess!", heroic = false },
        },
        swamplord_muselek = {
            { text = "He's got a bear bro - CC it if you can!", heroic = false },
            { text = "Freezing Trap catches people - break 'em out quick!", heroic = false },
            { text = "Multi-Shot sprays the squad - spread a little!", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning bounces - spread like you're avoiding drama!", heroic = false },
            { text = "Static Charge? Run from the group like you owe money!", heroic = false },
            { text = "Levitate just wait it out - like a hangover!", heroic = false },
            { text = "HEROIC: Spore Striders spawn - smush 'em or they explode!", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals spawn - AoE 'em like clearing the dance floor!", heroic = false },
            { text = "Enveloping Winds is a cyclone - just wait it out!", heroic = false },
            { text = "Lung Burst is a DOT - healers stay on it!", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Gnome engineer with his crew - kill the Mechanics first!", heroic = false },
            { text = "They heal him if you don't - priority targets bro!", heroic = false },
            { text = "Saw Blade is frontal - tank face him away!", heroic = false },
        },
        warlord_kalithresh = {
            { text = "Don't DPS near the distillers - he uses 'em to get JUICED!", heroic = false },
            { text = "Click the distiller when he channels - interrupt that pump!", heroic = false },
            { text = "Impale hurts the tank - save cooldowns!", heroic = false },
            { text = "HEROIC: His buff is CRANKED - distillers are CRITICAL!", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast hits hard - interrupt if you can!", heroic = false },
            { text = "Dark Shell REFLECTS - STOP DPS or you're hitting yourself!", heroic = false },
            { text = "Void zones spawn - move out of the purple!", heroic = false },
        },
        tavarok = {
            { text = "Giant rock dude! Earthquake shakes everyone - ride it out!", heroic = false },
            { text = "Crystal Prison stuns someone - break 'em out!", heroic = false },
            { text = "Arcing Smash is frontal - stay behind him!", heroic = false },
        },
        yor = {
            { text = "Yo this shadow bro is HUGE! More void than the club at 3am!", heroic = false },
            { text = "Double Breath? Don't stand in front unless you want your tan RUINED!", heroic = false },
            { text = "Stomp is like getting bounced from the club - stay on your feet!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds spawn - kill 'em fast like unwanted guests!", heroic = false },
            { text = "Frost Nova freezes the squad - dispel or trinket!", heroic = false },
            { text = "He Blinks around - casters got the easy life here!", heroic = false },
            { text = "HEROIC: MORE adds, MORE often - AoE is your FRIEND!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic slows casting - get CLOSE to remove it!", heroic = false },
            { text = "Carnivorous Bite is nasty on tank - heal through!", heroic = false },
            { text = "Focus Fire burns a spot - dance out of it!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone - tremor totem or fear ward!", heroic = false },
            { text = "Ribbon of Souls chases someone - kite it like an ex!", heroic = false },
            { text = "At 25% he summons an Avatar - SMUSH it, then finish him!", heroic = false },
            { text = "HEROIC: The Avatar is SWOLE - save cooldowns for it!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn - each one's got different drama!", heroic = false },
            { text = "Chain Lightning bounces - spread like it's a fire drill!", heroic = false },
            { text = "New elementals at health breakpoints - stay ready!", heroic = false },
        },
        anzu = {
            { text = "Yo this bird's got DARK energy! Like a club at 2am!", heroic = false },
            { text = "Spell Bomb means RUN - you're about to blow up the dance floor!", heroic = false },
            { text = "Feather storm coming - dodge like avoiding drama at the shore!", heroic = false },
            { text = "HEROIC: This raven is JUICED - tank better be ready!", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion is HUGE - run behind a pillar like it's paparazzi!", heroic = false },
            { text = "He Blinks around - ranged stay close to avoid issues!", heroic = false },
            { text = "Slow debuff on movement - annoying but manageable!", heroic = false },
            { text = "HEROIC: That explosion can ONE-SHOT - pillars are LIFE!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish the Ritualists first or he's UNKILLABLE!", heroic = false },
            { text = "Fear is CONSTANT - tremor totem is MVP!", heroic = false },
            { text = "Corrosive Acid melts armor - hurts the tank!", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos makes you fight your squad - SPREAD OUT!", heroic = false },
            { text = "During Chaos you can't control yourself - just accept the drama!", heroic = false },
            { text = "War Stomp stuns melee - back out before he casts!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers spawn from portals - AoE 'em down!", heroic = false },
            { text = "Draw Shadows pulls everyone to him - run away after!", heroic = false },
            { text = "Rain of Fire is deadly - get out of the fire!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - get close or you're getting BODIED!", heroic = false },
            { text = "Touch bomb? Run away like it's your ex at the club!", heroic = false },
            { text = "Stay in melee or Thundering Storm catches you!", heroic = false },
            { text = "HEROIC: Everything hits HARDER - positioning is KEY!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift - group up with same-colored people!", heroic = false },
            { text = "Positive and Negative charges - opposites DON'T attract here!", heroic = false },
            { text = "Head Crack hits the tank - heal through it!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase random people - KITE 'em!", heroic = false },
            { text = "Dragon's Breath is a cone - don't group up!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt when you can!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Summons Nether Wraiths - AoE 'em down fast!", heroic = false },
            { text = "Mind Control is random - CC the MC'd player (nicely)!", heroic = false },
            { text = "Disgruntled adds spawn - don't ignore 'em!", heroic = false },
            { text = "HEROIC: His damage is CALCULATED to hurt MORE!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "She summons Reservists - AoE 'em like clearing a club!", heroic = false },
            { text = "Arcane Resonance marks someone - spread from 'em!", heroic = false },
            { text = "More adds at health thresholds - stay ready!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "White Seedlings EXPLODE - kill 'em fast!", heroic = false },
            { text = "Tree Form heals him - burn through or CC adds!", heroic = false },
            { text = "Nature's Blessing heals - interrupt that recovery!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice stuns and drains - break 'em out!", heroic = false },
            { text = "Hellfire damages everyone nearby - range it if you can!", heroic = false },
            { text = "Enrages at low health - FINISH HIM!", heroic = false },
        },
        laj = {
            { text = "Color changes mean immunity - watch for the shift!", heroic = false },
            { text = "Each color is immune to different stuff - adjust DPS!", heroic = false },
            { text = "Thorn Lasher adds spawn - AoE 'em down!", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings walk to him - kill 'em before they arrive!", heroic = false },
            { text = "If saplings reach him, he HEALS - don't let that happen!", heroic = false },
            { text = "Arcane Volley is group damage - heal through!", heroic = false },
            { text = "HEROIC: MORE saplings, FASTER spawn - DPS stay focused!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone spawns under people - MOVE your feet!", heroic = false },
            { text = "Seed of Corruption on random targets - dispel or spread!", heroic = false },
            { text = "Shadow Nova is group damage - heal through!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind is DEADLY - melee get OUT!", heroic = false },
            { text = "Gift of the Doomsayer heals her - dispel it!", heroic = false },
            { text = "Shadow Wave is frontal - tank face her away!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire Shock leaves fire - move out!", heroic = false },
            { text = "Charge knocks back - stay away from edges!", heroic = false },
            { text = "Knock Away sends tank flying - position safe!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "Multi-phase fight - he splits into copies at health thresholds!", heroic = false },
            { text = "Mind Rend is a DOT - dispel it!", heroic = false },
            { text = "66% and 33% he splits - kill the fakes!", heroic = false },
            { text = "HEROIC: Illusions hit as hard as him - focus fire!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind is melee death - back up when he spins!", heroic = false },
            { text = "Mortal Strike on tank - heal through the debuff!", heroic = false },
            { text = "Simple fight - just respect the Whirlwind!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight! He charges around - stay mobile!", heroic = false },
            { text = "Holy Light heals him - INTERRUPT!", heroic = false },
            { text = "Consecration hurts - dance out of it!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall! If he dies, you FAIL!", heroic = false },
            { text = "Wing Buffet knocks back - position carefully!", heroic = false },
            { text = "Sand Breath is a cone - tank face him away!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss! Kill him before the next portal opens!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt it!", heroic = false },
            { text = "Time Lapse puts you back - disorienting but manageable!", heroic = false },
        },
        temporus = {
            { text = "Another portal boss! DPS race is REAL!", heroic = false },
            { text = "Hasten speeds him up - dangerous at low health!", heroic = false },
            { text = "Mortal Wound stacks on tank - heal through!", heroic = false },
        },
        aeonus = {
            { text = "Final boss of Black Morass - all the portals led to this!", heroic = false },
            { text = "Sand Breath is frontal - face away from group!", heroic = false },
            { text = "Time Stop freezes everyone - just wait it out!", heroic = false },
            { text = "HEROIC: He hits way harder - tank cooldowns READY!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains mana crystals for power - interrupt or destroy 'em!", heroic = false },
            { text = "Fel Explosion when he finishes draining - big damage!", heroic = false },
            { text = "Mana Rage is dangerous - focus those crystals!", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds run to players - kill or kite!", heroic = false },
            { text = "Overload from adds - increases damage but HURTS!", heroic = false },
            { text = "Chain Lightning bounces - spread out!", heroic = false },
            { text = "HEROIC: MORE Pure Energies - absolute CHAOS!", heroic = true },
        },
        priestess_delrissa = {
            { text = "She has 4 random adds - it's like a mini-PvP brawl!", heroic = false },
            { text = "Crowd control is key - CC as many as possible!", heroic = false },
            { text = "Kill order depends on the adds - ADAPT!", heroic = false },
            { text = "HEROIC: Adds hit like PLAYERS - respect them!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Kill the Phoenix Egg or it comes back like a bad tan!", heroic = false },
            { text = "Flamestrike - move your feet like you're dancing!", heroic = false },
            { text = "Gravity Lapse - swim to him and GET THOSE GAINS!", heroic = false },
            { text = "Pyroblast interrupt or someone's getting SMUSHED!", heroic = false },
            { text = "HEROIC: Phoenix respawns FASTER - egg priority is CRITICAL!", heroic = true },
        },
    },

    --============================================================
    -- SHRED (Extreme sports lingo, gnarly/radical, skateboard references)
    --============================================================
    shred = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "Dude, this orc is like a half-pipe - commit or bail!", heroic = false },
            { text = "Healers spawn at 50% - shred them like a sick rail!", heroic = false },
            { text = "Mortal Strike is gnarly - healers pump those heals!", heroic = false },
            { text = "HEROIC: His Surge is like a vert ramp drop - GNARLY damage!", heroic = true },
        },
        omor_the_unscarred = {
            { text = "Felhounds spawn - grind them down fast, bro!", heroic = false },
            { text = "Green fire is a WIPEOUT zone - carve around it!", heroic = false },
            { text = "Tank him by the door - optimal line, dude!", heroic = false },
        },
        nazan = {
            { text = "Two-stage trick! First the rider, then the SICK dragon drop-in!", heroic = false },
            { text = "Fire bombs - ollie over that nonsense!", heroic = false },
            { text = "Dragon lands - time for the FINAL SEND!", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control incoming - someone's about to go OFF-COURSE!", heroic = false },
            { text = "Exploding Beaker - interrupt that gnarly move!", heroic = false },
            { text = "Spread out so MC doesn't cause a WIPEOUT!", heroic = false },
        },
        broggok = {
            { text = "Four waves of adds - like a COMBO CHALLENGE, bro!", heroic = false },
            { text = "Poison clouds are HAZARDS - carve around 'em!", heroic = false },
            { text = "Keep moving, keep the FLOW going!", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear the adds first - clean the park before your RUN!", heroic = false },
            { text = "He yells 'Come closer' - BAIL OUT, dude!", heroic = false },
            { text = "Shadow Bolts incoming - interrupt those SICK!", heroic = false },
            { text = "HEROIC: Burning Nova is a MASSIVE wipeout - RUN!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices adds for power - SHRED them before he gets AMPED!", heroic = false },
            { text = "Death Coil fears the tank - off-tank ready to DROP IN!", heroic = false },
            { text = "Dark Spin is like a 900 - melee BAIL OUT!", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: Bonus boss in the gauntlet - SICK addition!", heroic = true },
            { text = "HEROIC: Clear adds first, then SEND IT on the guard!", heroic = true },
            { text = "HEROIC: He hits GNARLY - tank better be committed!", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two-headed ogre - threat swaps like a SWITCH STANCE!", heroic = false },
            { text = "Blast Wave knocks back - like eating concrete!", heroic = false },
            { text = "Fear goes out - tremor totem is your SPOTTER!", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet is the REAL halfpipe - pace yourself!", heroic = false },
            { text = "Blade Dance means he's SPINNING - watch the trick!", heroic = false },
            { text = "He charges random targets - spread like clearing a park!", heroic = false },
            { text = "HEROIC: Damage is CRANKED to X-Games level!", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems are like OBSTACLES - knock 'em down!", heroic = false },
            { text = "Healing totem is priority - don't let him RECOVER!", heroic = false },
            { text = "Lightning Shield hurts melee - casters got the easy LINE!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Big crab dude! Grievous Wound stacks - SICK damage!", heroic = false },
            { text = "Water Spit hits random - just ROLL with it!", heroic = false },
            { text = "Frenzy at low health - he's going for the BIG AIR!", heroic = false },
        },
        quagmirran = {
            { text = "Poison Volley is NASTY - nature resist helps!", heroic = false },
            { text = "Cleave is frontal - stay out of that LINE!", heroic = false },
            { text = "Acid Spray cone - tank AIMS him away!", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and POP - CARVE around 'em!", heroic = false },
            { text = "Spore Cloud messes with your accuracy - annoying OBSTACLE!", heroic = false },
            { text = "At 20% he frenzies - TIME TO SEND IT!", heroic = false },
        },
        ghazan = {
            { text = "Giant hydra! Acid Spit is frontal - tank pick your LINE!", heroic = false },
            { text = "Tail Sweep smacks the back - stay on the SIDES, bro!", heroic = false },
            { text = "Acid pools on ground - TERRAIN HAZARDS!", heroic = false },
        },
        swamplord_muselek = {
            { text = "He's got a bear - CC it like avoiding a WIPEOUT!", heroic = false },
            { text = "Freezing Trap catches people - break 'em out FAST!", heroic = false },
            { text = "Multi-Shot sprays - spread for safety, dude!", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning - spread like you're clearing a skate park!", heroic = false },
            { text = "Static Charge - DROP IN away from the crew!", heroic = false },
            { text = "Levitate is like catching air - enjoy the FLOAT, bro!", heroic = false },
            { text = "HEROIC: Spore Striders spawn - SHRED 'em or they explode!", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals spawn - AoE 'em down, CLEAR THE PARK!", heroic = false },
            { text = "Enveloping Winds is a cyclone - just RIDE IT OUT!", heroic = false },
            { text = "Lung Burst DOT - healers stay ON IT!", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Gnome with adds - kill the Mechanics FIRST!", heroic = false },
            { text = "They heal him - PRIORITY TARGETS, bro!", heroic = false },
            { text = "Saw Blade is frontal - tank AIMS away!", heroic = false },
        },
        warlord_kalithresh = {
            { text = "Don't DPS near distillers - he uses 'em to get AMPED!", heroic = false },
            { text = "Click distiller when he channels - INTERRUPT THE COMBO!", heroic = false },
            { text = "Impale hurts tank - save those COOLDOWNS!", heroic = false },
            { text = "HEROIC: His buff is GNARLY - distillers are CRITICAL!", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast hits hard - interrupt that MOVE!", heroic = false },
            { text = "Dark Shell REFLECTS - STOP DPS or you're hitting yourself!", heroic = false },
            { text = "Void zones spawn - CARVE around the purple!", heroic = false },
        },
        tavarok = {
            { text = "Giant rock dude! Earthquake shakes everyone - RIDE IT OUT!", heroic = false },
            { text = "Crystal Prison stuns - break 'em out FAST!", heroic = false },
            { text = "Arcing Smash is frontal - stay BEHIND him!", heroic = false },
        },
        yor = {
            { text = "Dude, void surfing! This guy's from the EXTREME dimension!", heroic = false },
            { text = "Double Breath is like a gnarly wipeout - stay to the sides!", heroic = false },
            { text = "Stomp sends everyone flying - stick the landing, bro!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds spawn - GRIND 'em down fast!", heroic = false },
            { text = "Frost Nova freezes - trinket or dispel, BREAK FREE!", heroic = false },
            { text = "He Blinks around - casters got the EASY LINE!", heroic = false },
            { text = "HEROIC: MORE adds, MORE often - AoE is RADICAL!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic slows casts - get CLOSE to remove it!", heroic = false },
            { text = "Carnivorous Bite is ROUGH on tank - heal through!", heroic = false },
            { text = "Focus Fire burns a spot - CARVE out of it!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone - tremor totem HELPS!", heroic = false },
            { text = "Ribbon of Souls chases - KITE IT, bro!", heroic = false },
            { text = "At 25% Avatar spawns - SHRED it, then finish!", heroic = false },
            { text = "HEROIC: Avatar is WAY stronger - save COOLDOWNS!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn - each one's a different OBSTACLE!", heroic = false },
            { text = "Chain Lightning bounces - SPREAD for safety!", heroic = false },
            { text = "New elementals at thresholds - STAY READY!", heroic = false },
        },
        anzu = {
            { text = "Dude, this raven is like a sick aerial trick gone WRONG! Gnarly!", heroic = false },
            { text = "Spell Bomb? Bail from the group before you wipe everyone out!", heroic = false },
            { text = "Feather cyclone is like a half-pipe of DOOM - stay mobile!", heroic = false },
            { text = "HEROIC: This bird shreds harder than Tony Hawk - extreme caution!", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion is HUGE - run behind a PILLAR!", heroic = false },
            { text = "He Blinks around - ranged stay TIGHT!", heroic = false },
            { text = "Slow debuff - annoying but MANAGEABLE!", heroic = false },
            { text = "HEROIC: That explosion can ONE-SHOT - pillars are MANDATORY!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish Ritualists first or he's UNKILLABLE!", heroic = false },
            { text = "Fear is CONSTANT - tremor is your SPOTTER!", heroic = false },
            { text = "Corrosive Acid melts armor - BRUTAL for tank!", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos makes you fight each other - SPREAD OUT!", heroic = false },
            { text = "Can't control during Chaos - just RIDE IT OUT!", heroic = false },
            { text = "War Stomp stuns melee - BAIL before he casts!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers from portals - AoE 'em, CLEAR THE PARK!", heroic = false },
            { text = "Draw Shadows pulls everyone - CARVE away after!", heroic = false },
            { text = "Rain of Fire - AVOID that terrain hazard!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - get close or you're gonna EAT IT!", heroic = false },
            { text = "Murmur's Touch - DROP IN away from the squad!", heroic = false },
            { text = "Thundering Storm hits ranged - stay tight, stay RADICAL!", heroic = false },
            { text = "HEROIC: Everything hits HARDER - positioning is KEY!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift - group with SAME COLORS!", heroic = false },
            { text = "Opposite charges HURT together - like a BAD COMBO!", heroic = false },
            { text = "Head Crack hits tank - heal through that SLAM!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase people - KITE 'em like avoiding a WIPEOUT!", heroic = false },
            { text = "Dragon's Breath is a cone - spread for SAFETY!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt that MOVE!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Nether Wraiths spawn - AoE 'em, SHRED FAST!", heroic = false },
            { text = "Mind Control is random - CC the victim NICELY!", heroic = false },
            { text = "Disgruntled adds - don't IGNORE 'em!", heroic = false },
            { text = "HEROIC: Damage is CRANKED - stay FOCUSED!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "Reservists spawn - AoE 'em down SICK!", heroic = false },
            { text = "Arcane Resonance marks someone - SPREAD from 'em!", heroic = false },
            { text = "More adds at thresholds - stay READY!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "White Seedlings EXPLODE - SHRED 'em fast!", heroic = false },
            { text = "Tree Form heals - burn through or CC ADDS!", heroic = false },
            { text = "Nature's Blessing heals - INTERRUPT that recovery!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice stuns and drains - break 'em OUT!", heroic = false },
            { text = "Hellfire damages nearby - RANGE it if you can!", heroic = false },
            { text = "Enrages low health - SEND IT to finish!", heroic = false },
        },
        laj = {
            { text = "Color changes mean immunity - watch the SHIFT!", heroic = false },
            { text = "Each color resists different stuff - ADJUST your line!", heroic = false },
            { text = "Thorn Lasher adds - AoE 'em RADICAL!", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings walk to him - SHRED 'em before they arrive!", heroic = false },
            { text = "Saplings heal him - DON'T let that happen!", heroic = false },
            { text = "Arcane Volley is group damage - RIDE IT OUT!", heroic = false },
            { text = "HEROIC: MORE saplings, FASTER - DPS stay GNARLY!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone spawns - CARVE out of there!", heroic = false },
            { text = "Seed of Corruption - dispel or SPREAD!", heroic = false },
            { text = "Shadow Nova is group damage - HEAL THROUGH!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind is DEADLY - melee BAIL OUT!", heroic = false },
            { text = "Gift of the Doomsayer heals her - DISPEL IT!", heroic = false },
            { text = "Shadow Wave is frontal - tank AIMS away!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire leaves fire - CARVE around it!", heroic = false },
            { text = "Charge knocks back - avoid the EDGES!", heroic = false },
            { text = "Knock Away sends tank flying - POSITION SAFE!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "Multi-phase - he SPLITS at health thresholds!", heroic = false },
            { text = "Mind Rend is a DOT - DISPEL IT!", heroic = false },
            { text = "66% and 33% splits - SHRED the illusions!", heroic = false },
            { text = "HEROIC: Illusions hit JUST as hard - focus FIRE!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind is melee DEATH - BAIL when he spins!", heroic = false },
            { text = "Mortal Strike on tank - heal through the DEBUFF!", heroic = false },
            { text = "Simple fight - just RESPECT the Whirlwind!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight! He charges - stay MOBILE!", heroic = false },
            { text = "Holy Light heals him - INTERRUPT that!", heroic = false },
            { text = "Consecration hurts - CARVE out of it!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall! He dies, you WIPE!", heroic = false },
            { text = "Wing Buffet knocks back - POSITION carefully!", heroic = false },
            { text = "Sand Breath is a cone - tank FACES away!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss! SHRED him before next portal!", heroic = false },
            { text = "Arcane Blast hits hard - INTERRUPT!", heroic = false },
            { text = "Time Lapse moves you back - DISORIENTING!", heroic = false },
        },
        temporus = {
            { text = "Another portal boss! DPS RACE is on!", heroic = false },
            { text = "Hasten speeds him up - DANGEROUS late!", heroic = false },
            { text = "Mortal Wound stacks on tank - HEAL through!", heroic = false },
        },
        aeonus = {
            { text = "Final boss! All portals led to this SEND!", heroic = false },
            { text = "Sand Breath frontal - FACE away!", heroic = false },
            { text = "Time Stop freezes everyone - WAIT it out!", heroic = false },
            { text = "HEROIC: Hits WAY harder - tank cooldowns READY!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains crystals for power - SHRED 'em first!", heroic = false },
            { text = "Fel Explosion after drain - BIG damage!", heroic = false },
            { text = "Mana Rage is dangerous - FOCUS crystals!", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds chase - KITE or kill!", heroic = false },
            { text = "Overload increases damage but HURTS you!", heroic = false },
            { text = "Chain Lightning bounces - SPREAD OUT!", heroic = false },
            { text = "HEROIC: MORE Pure Energies - GNARLY chaos!", heroic = true },
        },
        priestess_delrissa = {
            { text = "She has 4 random adds - mini-PvP FIGHT!", heroic = false },
            { text = "CC is key - control the CHAOS!", heroic = false },
            { text = "Kill order depends on adds - ADAPT your line!", heroic = false },
            { text = "HEROIC: Adds hit like PROS - respect them!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Phoenix Egg - DESTROY it or face a gnarly respawn!", heroic = false },
            { text = "Flamestrike - carve around the fire, dude!", heroic = false },
            { text = "Gravity Lapse - AERIAL TRICKS TIME, swim and shred!", heroic = false },
            { text = "Pyroblast - someone needs to SHUT THAT DOWN!", heroic = false },
            { text = "HEROIC: Phoenix respawns FASTER - egg priority is CRITICAL!", heroic = true },
        },
    },

    --============================================================
    -- EMO (Dark/dramatic descriptions, pain metaphors, poetry-like)
    --============================================================
    emo = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "This orc understands nothing of our suffering... destroy him.", heroic = false },
            { text = "He calls healers at 50%... like hope calling in the darkness.", heroic = false },
            { text = "Mortal Strike... pain is a familiar companion to the tank.", heroic = false },
            { text = "HEROIC: His Surge is like rejection... it hurts more when you least expect it.", heroic = true },
        },
        omor_the_unscarred = {
            { text = "A demon with hounds... the darkness has many faces.", heroic = false },
            { text = "Green fire burns... like the memories we try to forget.", heroic = false },
            { text = "Stand by the door... even in battle, we need escape routes.", heroic = false },
        },
        nazan = {
            { text = "First the rider falls... then the dragon... such is the cycle.", heroic = false },
            { text = "Fire everywhere... like my journal entries in 8th grade.", heroic = false },
            { text = "The dragon lands... and so does our melancholy victory.", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control... we're all puppets to something, aren't we?", heroic = false },
            { text = "Exploding Beaker... interrupt it, or don't. Pain is temporary.", heroic = false },
            { text = "Spread out... like we're already spreading apart in life.", heroic = false },
        },
        broggok = {
            { text = "Four waves of suffering before the real suffering begins...", heroic = false },
            { text = "Poison clouds... the air itself conspires against us.", heroic = false },
            { text = "Keep moving... the only way to outrun the darkness.", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear his followers first... false friends before the betrayer.", heroic = false },
            { text = "'Come closer' he whispers... like every bad decision I've made.", heroic = false },
            { text = "Shadow Bolts rain... like tears from a blackened sky.", heroic = false },
            { text = "HEROIC: Burning Nova... the pain is more intense, but pain is all we know.", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices his own... true villainy mirrors my last relationship.", heroic = false },
            { text = "Death Coil fears the tank... fear is just another emotion we suppress.", heroic = false },
            { text = "Dark Spin... he expresses his inner turmoil. I understand.", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: A bonus guardian of pain... how fitting.", heroic = true },
            { text = "HEROIC: Clear his entourage first... the lonely fall last.", heroic = true },
            { text = "HEROIC: He hits hard... but emotional damage cuts deeper.", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two heads, one body... a metaphor for my conflicted soul.", heroic = false },
            { text = "They argue and swap aggro... like the voices in my journal.", heroic = false },
            { text = "Fear is constant... just like in real life.", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet before him... life is one long gauntlet of pain.", heroic = false },
            { text = "Blade Dance... he spins like my thoughts at 3am.", heroic = false },
            { text = "He charges randomly... chaos, like existence itself.", heroic = false },
            { text = "HEROIC: The damage is amplified... much like heartbreak.", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems everywhere... false idols we cling to.", heroic = false },
            { text = "Healing totem is priority... healing is always fleeting.", heroic = false },
            { text = "Lightning Shield hurts melee... closeness always comes with pain.", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Grievous Wound stacks... wounds always stack in life too.", heroic = false },
            { text = "Water Spit hits random... the universe is cruel and indifferent.", heroic = false },
            { text = "Frenzy at low health... desperation, I understand.", heroic = false },
        },
        quagmirran = {
            { text = "Poison Volley... toxicity spreads, just like in my friend group.", heroic = false },
            { text = "Cleave is frontal... avoid those who face you with hostility.", heroic = false },
            { text = "Acid Spray cone... corrosive, like bitter words.", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and explode... beauty is fleeting and destructive.", heroic = false },
            { text = "Spore Cloud... even the air is against us here.", heroic = false },
            { text = "Frenzy at 20%... the final desperate act of a dying thing.", heroic = false },
        },
        ghazan = {
            { text = "Giant hydra... monsters come in all forms.", heroic = false },
            { text = "Tail Sweep from behind... betrayal from those closest to us.", heroic = false },
            { text = "Acid pools... the ground itself weeps poison.", heroic = false },
        },
        swamplord_muselek = {
            { text = "He has a bear companion... at least something loves him.", heroic = false },
            { text = "Freezing Trap... trapped, like my emotions.", heroic = false },
            { text = "Multi-Shot sprays... pain distributed equally.", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning... our pain connects us all.", heroic = false },
            { text = "Static Charge marks you... we're all marked, really.", heroic = false },
            { text = "Levitation... if only our spirits could float so easily.", heroic = false },
            { text = "HEROIC: Spore Striders spawn... more creatures born into suffering.", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals spawn... tears given form. Kill them.", heroic = false },
            { text = "Enveloping Winds tosses you around... the cyclone of my emotions. Stay grounded.", heroic = false },
            { text = "Lung Burst... breathing is hard when the soul is heavy. Dispel it.", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Gnome with minions... even he has friends. *sigh*", heroic = false },
            { text = "Mechanics heal him... must be nice to have support.", heroic = false },
            { text = "Saw Blade frontal... machinery is as cold as hearts.", heroic = false },
        },
        warlord_kalithresh = {
            { text = "He draws power from distillers... we all have our crutches.", heroic = false },
            { text = "Click the distiller... deny him his comfort. How cruel.", heroic = false },
            { text = "Impale hurts... like every word left unsaid.", heroic = false },
            { text = "HEROIC: His power is magnified... like grief, amplified by time.", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast hits hard... the void understands me.", heroic = false },
            { text = "Dark Shell reflects... our actions always return to us.", heroic = false },
            { text = "Void zones spawn... step carefully through the darkness.", heroic = false },
        },
        tavarok = {
            { text = "Earthquake shakes all... even the earth trembles with sorrow.", heroic = false },
            { text = "Crystal Prison stuns... trapped in crystallized pain.", heroic = false },
            { text = "Arcing Smash frontal... face the blow head on. Or don't.", heroic = false },
        },
        yor = {
            { text = "A being of pure shadow and void... *writes poetry frantically*", heroic = false },
            { text = "Double Breath... the void exhales its sorrow. Don't stand in front.", heroic = false },
            { text = "Stomp shakes the very foundation... like my faith in humanity.", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds spawn... phantoms of our past mistakes.", heroic = false },
            { text = "Frost Nova freezes... time stops, like during heartbreak.", heroic = false },
            { text = "He Blinks around... never staying, like everyone else.", heroic = false },
            { text = "HEROIC: More phantoms... the past never truly leaves.", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic... even our power is suppressed here.", heroic = false },
            { text = "Carnivorous Bite... he hungers, as we all do for understanding.", heroic = false },
            { text = "Focus Fire burns... focused pain is the worst kind.", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone... our souls know true terror.", heroic = false },
            { text = "Ribbon of Souls chases... the dead pursue us always.", heroic = false },
            { text = "At 25% the Avatar spawns... our shadow selves emerge.", heroic = false },
            { text = "HEROIC: The Avatar is stronger... our darkness grows with us.", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn... nature itself fractures.", heroic = false },
            { text = "Chain Lightning connects... binding us in shared suffering.", heroic = false },
            { text = "New adds at thresholds... each wound brings more pain.", heroic = false },
        },
        anzu = {
            { text = "A corrupted raven god of darkness... finally, someone who GETS me.", heroic = false },
            { text = "Spell Bomb marks your soul - run away before the darkness spreads!", heroic = false },
            { text = "Cyclone of Feathers... like my emotions. Chaotic. Dark. Beautiful.", heroic = false },
            { text = "HEROIC: The darkness is DEEPER here. *writes poetry*", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion... hide behind pillars like hiding from emotions.", heroic = false },
            { text = "He Blinks away... always fleeing, like my hope.", heroic = false },
            { text = "Slow debuff... time drags when the heart is heavy.", heroic = false },
            { text = "HEROIC: The explosion kills... like the death of innocence.", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish the Ritualists... their chanting echoes my thoughts.", heroic = false },
            { text = "Fear is constant... a familiar companion.", heroic = false },
            { text = "Corrosive Acid... like tears that burn.", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos... we turn on each other. How human.", heroic = false },
            { text = "No control during Chaos... like my spiral at 2am.", heroic = false },
            { text = "War Stomp stuns... paralyzed by overwhelming emotion.", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers from portals... the void sends messengers.", heroic = false },
            { text = "Draw Shadows pulls us in... the darkness beckons.", heroic = false },
            { text = "Rain of Fire... let the world burn. Metaphorically.", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom... the void demands proximity. Stay near.", heroic = false },
            { text = "His touch is a bomb... like love, explosive and fleeting.", heroic = false },
            { text = "Stay close to thunder... the storm within mirrors the storm without.", heroic = false },
            { text = "HEROIC: The pain intensifies... as it always does.", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift... we're all just charged particles in the void.", heroic = false },
            { text = "Opposite charges hurt... proximity breeds pain.", heroic = false },
            { text = "Head Crack... physical pain is almost refreshing.", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase... we're always running from something.", heroic = false },
            { text = "Dragon's Breath cone... even dragons breathe sorrow.", heroic = false },
            { text = "Arcane Blast... interrupt, or let it consume you.", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Nether Wraiths spawn... more lost souls joining our cause.", heroic = false },
            { text = "Mind Control... losing yourself is familiar territory.", heroic = false },
            { text = "Disgruntled adds... they understand workplace despair.", heroic = false },
            { text = "HEROIC: Calculated pain... mathematics of suffering.", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "Reservists spawn... soldiers of misfortune.", heroic = false },
            { text = "Arcane Resonance marks you... singled out for suffering.", heroic = false },
            { text = "More adds at thresholds... pain begets pain.", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "Seedlings explode... even plants know violence.", heroic = false },
            { text = "Tree Form heals him... nature shows him mercy we never get.", heroic = false },
            { text = "Nature's Blessing... a gift we must destroy. How fitting.", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice stuns and drains... he takes what he needs.", heroic = false },
            { text = "Hellfire damages everyone... shared suffering.", heroic = false },
            { text = "Enrages low health... desperate, like all of us.", heroic = false },
        },
        laj = {
            { text = "Colors shift like moods... ever-changing torment.", heroic = false },
            { text = "Each color resists differently... adapt or suffer.", heroic = false },
            { text = "Thorn Lasher adds... more pain to tend.", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings walk to him... even trees seek connection.", heroic = false },
            { text = "They heal him if they reach... comfort we deny.", heroic = false },
            { text = "Arcane Volley... pain washes over everyone equally.", heroic = false },
            { text = "HEROIC: More saplings seek him... loneliness kills.", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zones spawn... patches of pure darkness.", heroic = false },
            { text = "Seed of Corruption... we all carry corruption within.", heroic = false },
            { text = "Shadow Nova... the void pulses with our heartbeat.", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind of death... she dances in destruction.", heroic = false },
            { text = "Gift of the Doomsayer heals her... ironic name.", heroic = false },
            { text = "Shadow Wave frontal... face the darkness directly.", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire leaves burns... scars that don't fade.", heroic = false },
            { text = "Charge knocks back... pushed away, as always.", heroic = false },
            { text = "Knock Away... the world keeps pushing us.", heroic = false },
        },
        harbinger_skyriss = {
            { text = "He splits into copies... fragmented, like my psyche.", heroic = false },
            { text = "Mind Rend... he understands mental anguish.", heroic = false },
            { text = "Illusions at 66% and 33%... the further we go, the more we fracture.", heroic = false },
            { text = "HEROIC: Illusions are as real as he is... all pain is valid.", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind of violence... melee suffer most. Back away.", heroic = false },
            { text = "Mortal Strike... mortality haunts us all. Heal through it.", heroic = false },
            { text = "Simple fight... the simplest things hurt most.", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight... he charges through our ranks. Stay mobile.", heroic = false },
            { text = "Holy Light heals him... interrupt the faith we don't deserve.", heroic = false },
            { text = "Consecration burns... sacred ground rejects us. Move away.", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall... we protect what we cannot save. Guard him.", heroic = false },
            { text = "Wing Buffet pushes back... position against a wall.", heroic = false },
            { text = "Sand Breath cone... time itself attacks us. Face him away.", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss... racing against time, as always.", heroic = false },
            { text = "Arcane Blast... interrupt or accept the pain.", heroic = false },
            { text = "Time Lapse... reliving moments we'd rather forget.", heroic = false },
        },
        temporus = {
            { text = "Another portal boss... time waits for no one.", heroic = false },
            { text = "Hasten... he speeds toward our doom.", heroic = false },
            { text = "Mortal Wound stacks... each second adds more pain.", heroic = false },
        },
        aeonus = {
            { text = "Final boss... all timelines lead to endings.", heroic = false },
            { text = "Sand Breath... time devours us all.", heroic = false },
            { text = "Time Stop... frozen in this moment of despair.", heroic = false },
            { text = "HEROIC: He hits harder... the final blow always does.", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains crystals... we all drain something to survive.", heroic = false },
            { text = "Fel Explosion... consuming power has consequences.", heroic = false },
            { text = "Mana Rage... addiction given form.", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds chase... pure emotions consume us.", heroic = false },
            { text = "Overload hurts you... power always has a price.", heroic = false },
            { text = "Chain Lightning... connected in suffering.", heroic = false },
            { text = "HEROIC: More Pure Energies... overwhelming emotion.", heroic = true },
        },
        priestess_delrissa = {
            { text = "Random adds... chaos, like life itself.", heroic = false },
            { text = "CC is key... control what you can.", heroic = false },
            { text = "Kill order depends... adapt to survive.", heroic = false },
            { text = "HEROIC: Adds hit like players... the world fights back.", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "The Phoenix rises and falls... much like my emotions.", heroic = false },
            { text = "Flamestrike burns... but we've felt worse, haven't we?", heroic = false },
            { text = "Gravity fails us... we float in the void of existence.", heroic = false },
            { text = "Pyroblast... interrupt it, or accept the inevitable pain.", heroic = false },
            { text = "HEROIC: Phoenix returns faster... hope dies and rises, eternally.", heroic = true },
        },
    },

    --============================================================
    -- COSMO (Space/science analogies, dreamy explanations, constellation references)
    --============================================================
    cosmo = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "This orc's aggression is like a solar flare... predictable but dangerous.", heroic = false },
            { text = "Healers at 50%... like binary stars orbiting each other.", heroic = false },
            { text = "Mortal Strike... reducing HP like stellar radiation. *stares*", heroic = false },
            { text = "HEROIC: His Surge hits like a gamma ray burst... maintain distance.", heroic = true },
        },
        omor_the_unscarred = {
            { text = "Felhounds... like rogue asteroids, eliminate quickly.", heroic = false },
            { text = "Green fire... it's like a nebula, beautiful but deadly.", heroic = false },
            { text = "The door creates line of sight... geometry is universal.", heroic = false },
        },
        nazan = {
            { text = "Two-phase encounter... like a binary star system!", heroic = false },
            { text = "Fire bombs... impact craters on the floor. Avoid them.", heroic = false },
            { text = "The dragon is the final celestial body to overcome.", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control... like a parasitic organism hijacking the host. Fascinating.", heroic = false },
            { text = "Exploding Beaker... unstable chemical reaction. Interrupt the catalyst.", heroic = false },
            { text = "Spread out... like particles dispersing in a vacuum.", heroic = false },
        },
        broggok = {
            { text = "Four waves... like phases of a celestial event.", heroic = false },
            { text = "Poison clouds... toxic gas nebulae. Navigate around them.", heroic = false },
            { text = "Keep moving... orbital mechanics require constant adjustment.", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear satellites first... then approach the primary body.", heroic = false },
            { text = "'Come closer' triggers nova... maintain safe orbital distance!", heroic = false },
            { text = "Shadow Bolts... like dark matter projectiles. Interrupt.", heroic = false },
            { text = "HEROIC: Burning Nova... supernova-level explosion. Evacuate!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He absorbs his minions... like a black hole consuming satellites.", heroic = false },
            { text = "Death Coil fears... electromagnetic interference on tank systems.", heroic = false },
            { text = "Dark Spin... rotational force expels nearby objects.", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: Bonus celestial body in the gauntlet... *stares*", heroic = true },
            { text = "HEROIC: Clear orbiting debris first, then engage primary.", heroic = true },
            { text = "HEROIC: Impact force significant... reinforce hull.", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Binary consciousness... two stars sharing one gravitational center.", heroic = false },
            { text = "Blast Wave... stellar wind knockback. Range mitigates.", heroic = false },
            { text = "Fear pulses... like pulsar emissions. Predictable intervals.", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet... an asteroid field before the planet.", heroic = false },
            { text = "Blade Dance... rotational velocity increases. Maintain distance.", heroic = false },
            { text = "Random charge vectors... unpredictable trajectory. Spread formation.", heroic = false },
            { text = "HEROIC: Energy output increased... like a star going supergiant.", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems... like orbital satellites. Destroy them systematically.", heroic = false },
            { text = "Healing totem priority... it's the power source.", heroic = false },
            { text = "Lightning Shield... electrical field damages close orbit.", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Grievous Wound stacks... accumulating damage like radiation exposure.", heroic = false },
            { text = "Water Spit... random targeting. Probability distribution.", heroic = false },
            { text = "Frenzy at low HP... like a dying star's final burst.", heroic = false },
        },
        quagmirran = {
            { text = "Poison Volley... toxic particle emission. Nature resist helps.", heroic = false },
            { text = "Cleave is frontal... stay outside the cone angle.", heroic = false },
            { text = "Acid Spray... directional emission. Tank vector matters.", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and detonate... like proximity mines in space.", heroic = false },
            { text = "Spore Cloud... reduces accuracy. Sensor interference.", heroic = false },
            { text = "Frenzy at 20%... critical mass approaching.", heroic = false },
        },
        ghazan = {
            { text = "Hydra... multi-headed organism. Fascinating biology.", heroic = false },
            { text = "Tail Sweep from behind... rear arc vulnerability.", heroic = false },
            { text = "Acid pools... corrosive terrain. Avoid contact.", heroic = false },
        },
        swamplord_muselek = {
            { text = "Companion creature... like a moon orbiting a planet.", heroic = false },
            { text = "Freezing Trap... cryogenic stasis. Free targets quickly.", heroic = false },
            { text = "Multi-Shot... area bombardment. Spread formation.", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning arcs like solar wind... spread formation.", heroic = false },
            { text = "Static Charge... you're like a charged particle. Isolate yourself.", heroic = false },
            { text = "Levitation... *sighs* ...reminds me of microgravity environments.", heroic = false },
            { text = "HEROIC: Spore Striders... additional orbital threats.", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals... liquid-state constructs. AoE disperses them.", heroic = false },
            { text = "Cyclone... atmospheric vortex. Ride it out.", heroic = false },
            { text = "Lung Burst... internal pressure damage. Monitor vitals.", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Engineer with support drones... eliminate repair units first.", heroic = false },
            { text = "Mechanics heal primary... priority targeting required.", heroic = false },
            { text = "Saw Blade frontal... industrial cutting laser. Face away.", heroic = false },
        },
        warlord_kalithresh = {
            { text = "Distillers are power sources... don't let him recharge.", heroic = false },
            { text = "Click distiller during channel... interrupt energy transfer.", heroic = false },
            { text = "Impale... high impact damage on tank. Reinforce.", heroic = false },
            { text = "HEROIC: Power absorption magnified... distillers critical.", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast... dark energy projection. Interrupt.", heroic = false },
            { text = "Dark Shell reflects... energy barrier active. Cease fire.", heroic = false },
            { text = "Void zones... pockets of null space. Navigate around.", heroic = false },
        },
        tavarok = {
            { text = "Earthquake... seismic activity. Brace for impact.", heroic = false },
            { text = "Crystal Prison... solid-state containment. Free targets.", heroic = false },
            { text = "Arcing Smash frontal... maintain rear position.", heroic = false },
        },
        yor = {
            { text = "A void entity! Like dark matter given physical form... incredible!", heroic = false },
            { text = "Double Breath is like solar wind - avoid the frontal cone!", heroic = false },
            { text = "Stomp creates gravitational waves! *gets distracted by physics*", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds... phase-shifted entities. Eliminate quickly.", heroic = false },
            { text = "Frost Nova... cryogenic field. Dispel or wait.", heroic = false },
            { text = "Blink teleportation... spatial displacement. Ranged advantage.", heroic = false },
            { text = "HEROIC: Increased ethereal spawns... more phase entities.", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic... casting suppression field. Get CLOSE to break it.", heroic = false },
            { text = "Carnivorous Bite... organic damage on tank. Heal through.", heroic = false },
            { text = "Focus Fire... concentrated beam. Exit target zone.", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears... psychic wave emission.", heroic = false },
            { text = "Ribbon of Souls... pursuing energy. Kite trajectory.", heroic = false },
            { text = "Avatar at 25%... shadow manifestation. Priority target.", heroic = false },
            { text = "HEROIC: Avatar power increased... enhanced shadow entity.", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds... multi-spectrum energy constructs.", heroic = false },
            { text = "Chain Lightning... electrical arc propagation. Spread.", heroic = false },
            { text = "New adds at thresholds... phase-triggered spawns.", heroic = false },
        },
        anzu = {
            { text = "A void raven! Like a black hole with feathers... fascinating. *stares*", heroic = false },
            { text = "Spell Bomb is like a collapsing star - evacuate the area!", heroic = false },
            { text = "Feather cyclone... reminds me of spiral galaxies. So pretty.", heroic = false },
            { text = "HEROIC: The cosmic energy here is INTENSE. *zones out thinking about quasars*", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion... massive energy release. Use structural cover.", heroic = false },
            { text = "Blink displacement... stay in close orbit.", heroic = false },
            { text = "Slow debuff... temporal field effect. Manageable.", heroic = false },
            { text = "HEROIC: Explosion is lethal... cover is mandatory.", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Ritualists create barrier... banish to deactivate shield.", heroic = false },
            { text = "Fear... constant psychic interference.", heroic = false },
            { text = "Corrosive Acid... reduces structural integrity.", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos... neural hijacking. Spread to minimize.", heroic = false },
            { text = "No control during Chaos... ride the wave.", heroic = false },
            { text = "War Stomp stuns... concussive shockwave.", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers from portals... void entities manifesting.", heroic = false },
            { text = "Draw Shadows... gravitational pull. Escape velocity after.", heroic = false },
            { text = "Rain of Fire... incendiary bombardment. Relocate.", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom... sound waves at close range are survivable.", heroic = false },
            { text = "His touch creates an explosion radius... maintain safe orbital distance.", heroic = false },
            { text = "Thundering Storm hits at range... like cosmic ray bombardment.", heroic = false },
            { text = "HEROIC: All outputs magnified... recalibrate defense.", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift... electromagnetic charge assignment. Match polarities.", heroic = false },
            { text = "Opposite charges react... stay with same-charge particles.", heroic = false },
            { text = "Head Crack... high impact on tank. Heal through.", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals pursue... heat-seeking entities. Kite.", heroic = false },
            { text = "Dragon's Breath... thermal cone. Don't cluster.", heroic = false },
            { text = "Arcane Blast... energy projectile. Interrupt.", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Nether Wraiths... void constructs. AoE elimination.", heroic = false },
            { text = "Mind Control... neural override. CC affected.", heroic = false },
            { text = "Disgruntled adds... don't ignore auxiliary threats.", heroic = false },
            { text = "HEROIC: Calculations indicate increased threat level.", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "Reservists spawn... reinforcement wave. AoE.", heroic = false },
            { text = "Arcane Resonance... energy buildup. Disperse from target.", heroic = false },
            { text = "Threshold triggers... predictable spawn intervals.", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "Seedlings detonate... organic explosives. Eliminate fast.", heroic = false },
            { text = "Tree Form... regeneration phase. Push through or CC adds.", heroic = false },
            { text = "Nature's Blessing... healing protocol. Interrupt.", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice... life-drain tether. Break quickly.", heroic = false },
            { text = "Hellfire... area immolation. Range if possible.", heroic = false },
            { text = "Enrage... power surge at critical HP.", heroic = false },
        },
        laj = {
            { text = "Color spectrum shifts... immunity rotation. *stares* Fascinating.", heroic = false },
            { text = "Each color... different damage resistance. Adapt wavelength.", heroic = false },
            { text = "Thorn Lashers... organic additions. AoE.", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings converge... like gravity pulling matter.", heroic = false },
            { text = "Contact heals primary... prevent mass accumulation.", heroic = false },
            { text = "Arcane Volley... area bombardment. Heal through.", heroic = false },
            { text = "HEROIC: Sapling spawn rate increased... faster gravitational pull.", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone... null space pockets. Exit immediately.", heroic = false },
            { text = "Seed of Corruption... spreading void. Dispel or spread.", heroic = false },
            { text = "Shadow Nova... dark energy pulse. Heal through.", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind... rotational hazard. Melee evacuate.", heroic = false },
            { text = "Gift of the Doomsayer... healing transfer. Dispel.", heroic = false },
            { text = "Shadow Wave... directional blast. Tank faces away.", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire... persistent combustion. Relocate.", heroic = false },
            { text = "Charge... kinetic impact. Edge awareness.", heroic = false },
            { text = "Knock Away... momentum transfer. Position safely.", heroic = false },
        },
        harbinger_skyriss = {
            { text = "Phase splits... entity multiplication at thresholds.", heroic = false },
            { text = "Mind Rend... psychic DOT. Dispel.", heroic = false },
            { text = "Illusions at 66% and 33%... holographic projections.", heroic = false },
            { text = "HEROIC: Illusions full power... all projections are real.", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind... rotational melee hazard.", heroic = false },
            { text = "Mortal Strike... mortality damage amplification.", heroic = false },
            { text = "Simple orbital mechanics... respect the spin.", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted combat... mobile platform.", heroic = false },
            { text = "Holy Light... energy recovery. Interrupt.", heroic = false },
            { text = "Consecration... ground denial. Relocate.", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect the temporal anchor... Thrall. *stares* Fascinating specimen.", heroic = false },
            { text = "Wing Buffet... atmospheric displacement.", heroic = false },
            { text = "Sand Breath... particulate cone. Face away.", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal sequence... temporal urgency.", heroic = false },
            { text = "Arcane Blast... energy projectile. Interrupt.", heroic = false },
            { text = "Time Lapse... temporal displacement. Disorienting but brief.", heroic = false },
        },
        temporus = {
            { text = "Another temporal entity... DPS trajectory critical.", heroic = false },
            { text = "Hasten... time acceleration. Dangerous at low HP.", heroic = false },
            { text = "Mortal Wound... stacking temporal damage.", heroic = false },
        },
        aeonus = {
            { text = "Final temporal guardian... all timelines converge.", heroic = false },
            { text = "Sand Breath... frontal particle stream.", heroic = false },
            { text = "Time Stop... temporal stasis. Brief pause.", heroic = false },
            { text = "HEROIC: Temporal energy magnified... brace for impact.", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "Mana crystals... energy sources. Deny access.", heroic = false },
            { text = "Fel Explosion... energy overload after drain.", heroic = false },
            { text = "Mana Rage... unstable power state. Focus crystals.", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy... concentrated particles. Kite or eliminate.", heroic = false },
            { text = "Overload... energy absorption. Risk/reward calculation.", heroic = false },
            { text = "Chain Lightning... electrical propagation. Spread.", heroic = false },
            { text = "HEROIC: More Pure Energies... particle saturation.", heroic = true },
        },
        priestess_delrissa = {
            { text = "Random variables... tactical adaptation required.", heroic = false },
            { text = "CC... control chaotic elements.", heroic = false },
            { text = "Kill order... depends on variable configuration.", heroic = false },
            { text = "HEROIC: Variables at full power... respect all threats.", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "The Phoenix is like a star going supernova... destroy the core!", heroic = false },
            { text = "Flamestrike... solar flares on the ground. Evade.", heroic = false },
            { text = "Gravity Lapse! Zero-gravity phase! Navigate to the target!", heroic = false },
            { text = "Pyroblast... a focused plasma beam. Must be interrupted!", heroic = false },
            { text = "HEROIC: Phoenix respawn rate increased... stellar cycle accelerated.", heroic = true },
        },
    },

    --============================================================
    -- BOOMER (Back in my day comparisons, old-timer wisdom, simple explanations)
    --============================================================
    boomer = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "In MY day, orcs hit twice as hard! This one's easy.", heroic = false },
            { text = "Healers spawn at 50%? Back then we just DEALT with it!", heroic = false },
            { text = "Mortal Strike? Kids today don't know real tank damage!", heroic = false },
            { text = "HEROIC: His Surge hurts more? STILL easier than Ragnaros!", heroic = true },
        },
        omor_the_unscarred = {
            { text = "Demons with pets? Used to be just demons, no frills!", heroic = false },
            { text = "Fire on the ground - classic mechanic. Move your feet!", heroic = false },
            { text = "Line of sight the spells. We figured this out in MC!", heroic = false },
        },
        nazan = {
            { text = "Two bosses in one? Back in my day that was a RAID!", heroic = false },
            { text = "Fire patches - same as Ragnaros, younger and more obnoxious.", heroic = false },
            { text = "Kill the dragon. Simple. Effective. Like the old days.", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control? We dealt with this in Blackwing Lair! Nothing new!", heroic = false },
            { text = "Exploding Beaker - interrupt it. We had ONE interrupt in my day!", heroic = false },
            { text = "Spread out. Simple tactic. Works every time.", heroic = false },
        },
        broggok = {
            { text = "Four waves of adds? That's NOTHING compared to suppression room!", heroic = false },
            { text = "Poison clouds - same as the Onyxia whelp cave. Move around!", heroic = false },
            { text = "Keep your feet moving. Basic stuff, kids!", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear adds first. We learned this in UBRS!", heroic = false },
            { text = "He says 'Come closer' - that means RUN AWAY! Classic trap!", heroic = false },
            { text = "Shadow Bolts? Interrupt 'em! That's what kicks are FOR!", heroic = false },
            { text = "HEROIC: Nova hurts more but the STRATEGY is the same!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices adds? Seen it before in better raids!", heroic = false },
            { text = "Fear on tank - Death Coil. We've dealt with worse.", heroic = false },
            { text = "Whirlwind - melee back up. Same as ALWAYS.", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: Bonus boss? In MY day, EVERY boss was bonus!", heroic = true },
            { text = "HEROIC: Clear adds first. Standard procedure since '05!", heroic = true },
            { text = "HEROIC: He hits hard? So did Vael. Next!", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two-headed ogre? We had twins in AQ. This is simpler!", heroic = false },
            { text = "Blast Wave knockback - position yourself! Basic awareness!", heroic = false },
            { text = "Fear - drop a tremor totem. We had shamans for a REASON!", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet? Try the suppression room in BWL! This is EASY!", heroic = false },
            { text = "Blade Dance - he spins, you back up. Not rocket science!", heroic = false },
            { text = "Random charges? Spread out! Same tactic since vanilla!", heroic = false },
            { text = "HEROIC: More damage? Still easier than Chromaggus!", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems! Kill them! Shamans in MY day knew this!", heroic = false },
            { text = "Healing totem first - basic kill priority!", heroic = false },
            { text = "Lightning Shield? Ranged attacks exist for a reason!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Stacking debuff on tank - we healed through WORSE in MC!", heroic = false },
            { text = "Random damage? Just heal it. Not complicated!", heroic = false },
            { text = "Frenzy at low health - burn phase. Classic!", heroic = false },
        },
        quagmirran = {
            { text = "Poison damage? We had nature resist gear in MY day!", heroic = false },
            { text = "Cleave is frontal - don't stand there! Basic positioning!", heroic = false },
            { text = "Tank faces boss away. We've been doing this since Onyxia!", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Exploding mushrooms? We had similar in Maraudon. Move!", heroic = false },
            { text = "Debuff reduces hit? We dealt with blind drakes, we'll manage!", heroic = false },
            { text = "Frenzy at 20% - burn phase! Pop your cooldowns!", heroic = false },
        },
        ghazan = {
            { text = "Hydra? Three heads or not, tank and spank principles apply!", heroic = false },
            { text = "Tail swipe - don't stand behind it! Onyxia taught us this!", heroic = false },
            { text = "Green stuff on ground - don't stand in it. ALWAYS.", heroic = false },
        },
        swamplord_muselek = {
            { text = "Hunter boss with a pet? CC the pet! Basic strategy!", heroic = false },
            { text = "Freezing Trap - break people out fast!", heroic = false },
            { text = "Multi-Shot - spread out a BIT. Not hard!", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning? Saw this in Molten Core! SPREAD OUT!", heroic = false },
            { text = "Bomb debuff - you're the problem, run AWAY from the group!", heroic = false },
            { text = "Levitate? In MY day we stayed on the ground!", heroic = false },
            { text = "HEROIC: More adds? We cleared trash for HOURS in MC!", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals? AoE them! We had AoE packs in Strat!", heroic = false },
            { text = "Cyclone - wait it out. Patience! Kids these days!", heroic = false },
            { text = "DOT damage - healers stay awake! That's your JOB!", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Kill the healers first! Priority targeting since FOREVER!", heroic = false },
            { text = "Adds heal boss - this isn't NEW, people!", heroic = false },
            { text = "Frontal cone - tank faces away. Standard!", heroic = false },
        },
        warlord_kalithresh = {
            { text = "Don't let him get buffs - click the thing! INTERACT with the raid!", heroic = false },
            { text = "Interrupt his channel - we've had interrupts since DAY ONE!", heroic = false },
            { text = "Big damage on tank - heal it! That's healing!", heroic = false },
            { text = "HEROIC: Bigger buff? Still same strategy!", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast - interrupt it! Counterspell has existed forever!", heroic = false },
            { text = "Reflects damage? STOP ATTACKING! Read the mechanics!", heroic = false },
            { text = "Void zones - don't stand in purple. Or green. Or any color!", heroic = false },
        },
        tavarok = {
            { text = "Earthquake - we had this in Maraudon! Brace yourself!", heroic = false },
            { text = "Stun on a player - break them out! Teamwork!", heroic = false },
            { text = "Frontal cleave - stay behind the boss!", heroic = false },
        },
        yor = {
            { text = "Optional bosses? In MY day the boss was the ONLY boss and we LIKED IT!", heroic = false },
            { text = "Void breath? In vanilla we just stood in fire! But don't do that.", heroic = false },
            { text = "Stomp is like server lag - you just gotta ride it out!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Adds spawn constantly? Welcome to vanilla clearing!", heroic = false },
            { text = "Frost Nova - dispel or trinket. Tools exist for a REASON!", heroic = false },
            { text = "He teleports around? So did some mobs in AQ. Adapt!", heroic = false },
            { text = "HEROIC: More adds? Still fewer than UBRS!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Caster debuff - get close to remove it! Read your debuffs!", heroic = false },
            { text = "Tank takes damage - that's what healers are FOR!", heroic = false },
            { text = "Fire on ground - we've been avoiding this since MC!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Fear - we had fear in MC! Bring tremor totem!", heroic = false },
            { text = "Chasing thing - kite it! We kited things in VANILLA!", heroic = false },
            { text = "Adds spawn at thresholds - phase mechanics! Not new!", heroic = false },
            { text = "HEROIC: Stronger add? Still simpler than Twin Emps!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn? AoE them! We had AoE classes!", heroic = false },
            { text = "Chain Lightning - SPREAD. How many times?!", heroic = false },
            { text = "Adds at health thresholds - predictable! Plan for it!", heroic = false },
        },
        anzu = {
            { text = "In MY day, druids didn't need fancy ravens! They had CAT FORM and LIKED IT!", heroic = false },
            { text = "Spell Bomb? Back in MY day bombs were simple! Run away!", heroic = false },
            { text = "Feather storm - just like the weather in vanilla. We dealt with it!", heroic = false },
            { text = "HEROIC: NOW this is a proper challenge! Like the OLD dungeons!", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Big explosion - hide behind something! We did this with Shazzrah!", heroic = false },
            { text = "He blinks - stay close. Ranged had this problem forever.", heroic = false },
            { text = "Slow debuff - manageable. Not that bad!", heroic = false },
            { text = "HEROIC: One-shot explosion? Pillars exist for a REASON!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish adds first - crowd control! We INVENTED this!", heroic = false },
            { text = "Constant fear - tremor totem. Shamans are useful!", heroic = false },
            { text = "Armor reduction - healer problem. Not mine.", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "You fight each other? We had this in Naxx! Spread out!", heroic = false },
            { text = "No control - wait it out. Patience is a VIRTUE!", heroic = false },
            { text = "Stun - back out before cast. AWARENESS!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Adds from portals - AoE! Standard procedure!", heroic = false },
            { text = "Gets pulled to boss - run away after! Movement!", heroic = false },
            { text = "Fire rain - DON'T STAND IN IT! How is this still hard?!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - they recycled this from C'Thun! Get close!", heroic = false },
            { text = "Touch bomb - JUST LIKE THE OLD RAIDS. Run away!", heroic = false },
            { text = "Stay close or take damage. Simple rules, simple times.", heroic = false },
            { text = "HEROIC: More damage? Principles are the SAME!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity - group with same color! We did this in Naxx!", heroic = false },
            { text = "Opposite charges hurt - DON'T TOUCH! Basic physics!", heroic = false },
            { text = "Tank damage - healers do your JOB!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Adds chase people - KITE THEM! We've been kiting since vanilla!", heroic = false },
            { text = "Breath attack - don't group up! Spatial awareness!", heroic = false },
            { text = "Interrupt the cast - that's what interrupts are FOR!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "AoE the adds! We had AoE in vanilla!", heroic = false },
            { text = "Mind Control - CC them or carefully DPS. Not new!", heroic = false },
            { text = "Extra adds - handle them! We cleared more in UBRS!", heroic = false },
            { text = "HEROIC: More damage? Still easier than C'Thun!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "Adds spawn - AoE! Classic add management!", heroic = false },
            { text = "Someone gets marked - spread from them! Awareness!", heroic = false },
            { text = "Phases - predictable! Plan accordingly!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "Exploding adds? Kill them! Priority targeting!", heroic = false },
            { text = "He heals in tree form - push through or CC! Options!", heroic = false },
            { text = "Interrupt the heal! We've HAD interrupts!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Life drain tether - break it! Free your allies!", heroic = false },
            { text = "AoE damage - spread out or heal through!", heroic = false },
            { text = "Enrage - burn phase! Pop cooldowns!", heroic = false },
        },
        laj = {
            { text = "Color immunities? We had this in AQ! Adapt your DPS!", heroic = false },
            { text = "Different resists - switch damage type! Not hard!", heroic = false },
            { text = "Adds spawn - AoE! Standard!", heroic = false },
        },
        warp_splinter = {
            { text = "Adds walk to boss - kill them first! Priority!", heroic = false },
            { text = "They heal him if they reach - DON'T LET THEM!", heroic = false },
            { text = "Group damage - heal through it!", heroic = false },
            { text = "HEROIC: More adds? Handle them! We cleared Naxx!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zones - MOVE! We've been dodging since MC!", heroic = false },
            { text = "Spreading debuff - dispel or spread! Options!", heroic = false },
            { text = "Group damage - healers handle it!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind - melee BACK UP! Onyxia breath rules apply!", heroic = false },
            { text = "She heals? DISPEL IT! That's what dispels are for!", heroic = false },
            { text = "Frontal attack - tank faces away!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Fire on ground - MOVE! Always the same!", heroic = false },
            { text = "Knockback - stay away from edges! Awareness!", heroic = false },
            { text = "Tank gets knocked - position safely!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "He splits into copies - focus fire! Kill fakes!", heroic = false },
            { text = "DOT - dispel it! That's what dispels DO!", heroic = false },
            { text = "More splits at thresholds - expected! Handle it!", heroic = false },
            { text = "HEROIC: Copies hit hard? Still simpler than C'Thun!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind - back up! Same as every whirlwind ever!", heroic = false },
            { text = "Mortal Strike - heal through it! Tanks survived worse!", heroic = false },
            { text = "Simple fight. Finally, something straightforward!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted boss? He charges around. Stay mobile!", heroic = false },
            { text = "He heals himself? INTERRUPT! We've had kicks forever!", heroic = false },
            { text = "Ground effect - move out! Standard fare!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect the NPC! We've been protecting NPCs since Jailbreak!", heroic = false },
            { text = "Knockback - position yourself!", heroic = false },
            { text = "Frontal cone - face away from group!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Kill before next portal - DPS race! Classic!", heroic = false },
            { text = "Interrupt the blast! We have INTERRUPTS!", heroic = false },
            { text = "Get teleported back? Disorienting but manageable!", heroic = false },
        },
        temporus = {
            { text = "Another DPS race - push push push!", heroic = false },
            { text = "He speeds up at low health - burn phase!", heroic = false },
            { text = "Stacking debuff - heal the tank! Basics!", heroic = false },
        },
        aeonus = {
            { text = "Final boss! All that buildup for this? Easy!", heroic = false },
            { text = "Frontal breath - tank faces away!", heroic = false },
            { text = "Everyone gets stunned? Wait it out!", heroic = false },
            { text = "HEROIC: More damage? We healed through Patchwerk!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drinks crystals for power - destroy them! Basic!", heroic = false },
            { text = "Big damage after drain - expected! Heal through!", heroic = false },
            { text = "Focus the crystals! Kill the power source!", heroic = false },
        },
        vexallus = {
            { text = "Adds run to you? Kill or kite! Classic options!", heroic = false },
            { text = "Overload mechanic - risk vs reward! Make choices!", heroic = false },
            { text = "Chain Lightning - SPREAD! How many times?!", heroic = false },
            { text = "HEROIC: More adds? Still manageable!", heroic = true },
        },
        priestess_delrissa = {
            { text = "Random adds? ADAPT! We didn't have guides in MY day!", heroic = false },
            { text = "CC what you can! Crowd control exists!", heroic = false },
            { text = "Kill order depends - use your BRAIN!", heroic = false },
            { text = "HEROIC: They hit hard? So did players in BGs!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Phoenix mechanics? We had REAL phoenix problems in MC!", heroic = false },
            { text = "Fire on ground - some things NEVER change!", heroic = false },
            { text = "Flying phase? In MY day we stayed on the ground!", heroic = false },
            { text = "Interrupt the cast. Counterspell existed for a REASON!", heroic = false },
            { text = "HEROIC: Phoenix respawns faster? Handle it!", heroic = true },
        },
    },

    --============================================================
    -- DIVA (Fabulous commentary, fashion/drama metaphors, diva energy)
    --============================================================
    diva = {
        -- Hellfire Ramparts
        watchkeeper_gargolmar = {
            { text = "This orc's fashion is TRAGIC. Let's end his suffering!", heroic = false },
            { text = "Healers at 50%? The AUDACITY of calling for backup!", heroic = false },
            { text = "Mortal Strike? Honey, the tank has been through WORSE!", heroic = false },
            { text = "HEROIC: His Surge is giving main character energy - spread out, darlings!", heroic = true },
        },
        omor_the_unscarred = {
            { text = "Felhounds? Someone needs to leash their pets, HONESTLY!", heroic = false },
            { text = "Green fire is SO last season - don't step in it, darling!", heroic = false },
            { text = "Work that door angle - it's all about POSITIONING!", heroic = false },
        },
        nazan = {
            { text = "A rider AND a dragon? Double the drama, double the SLAY!", heroic = false },
            { text = "Fire on the ground? Move those FEET, honey!", heroic = false },
            { text = "The dragon is FIERCE but we are FIERCER!", heroic = false },
        },
        -- Blood Furnace
        the_maker = {
            { text = "Mind control? The DRAMA! Someone's about to betray the group!", heroic = false },
            { text = "Exploding Beaker - interrupt that MESS, darling!", heroic = false },
            { text = "Spread out - everyone needs their personal SPACE on this stage!", heroic = false },
        },
        broggok = {
            { text = "Four waves of adds? This is a GAUNTLET of fashion fails!", heroic = false },
            { text = "Poison clouds - TRAGIC for the complexion. Move, move, MOVE!", heroic = false },
            { text = "Keep moving, keep SERVING - that's the diva way!", heroic = false },
        },
        kelidan_the_breaker = {
            { text = "Clear his entourage first - the star comes LAST!", heroic = false },
            { text = "'Come closer' he says? The AUDACITY! Run away, darling!", heroic = false },
            { text = "Shadow Bolts? Interrupt that TACKY display!", heroic = false },
            { text = "HEROIC: Burning Nova is giving supernova realness - RUN!", heroic = true },
        },
        -- Shattered Halls
        grand_warlock_nethekurse = {
            { text = "He sacrifices his backup dancers? ICONIC villain behavior!", heroic = false },
            { text = "Death Coil fears the tank - off-tank, your moment to SHINE!", heroic = false },
            { text = "Dark Spin - melee need to EXIT the stage!", heroic = false },
        },
        blood_guard_porung = {
            { text = "HEROIC: Bonus boss? Extra drama, I LIVE for this!", heroic = true },
            { text = "HEROIC: Clear the chorus line first, then the STAR!", heroic = true },
            { text = "HEROIC: He hits hard - tank better be giving STURDY!", heroic = true },
        },
        warbringer_omrogg = {
            { text = "Two heads, one body? The internal DRAMA is immaculate!", heroic = false },
            { text = "They argue and swap aggro - relationship GOALS? Tragic!", heroic = false },
            { text = "Fear constantly - tremor totem is the real STAR!", heroic = false },
        },
        warchief_kargath_bladefist = {
            { text = "The gauntlet before him? That's the OPENING ACT, honey!", heroic = false },
            { text = "Blade Dance - he's trying to SERVE but we serve HARDER!", heroic = false },
            { text = "Random charges - spread out, give him SPACE to fail!", heroic = false },
            { text = "HEROIC: His damage is EXTRA - so are WE!", heroic = true },
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems everywhere? This stage is a MESS - clean it up!", heroic = false },
            { text = "Healing totem first - deny him his glow-up!", heroic = false },
            { text = "Lightning Shield? Melee are getting SHOCKED - literally!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Big crab energy! Grievous Wound stacks - TRAGIC for tanks!", heroic = false },
            { text = "Water Spit hits random - the universe is testing us, darling!", heroic = false },
            { text = "Frenzy at low health - he's giving DESPERATION!", heroic = false },
        },
        quagmirran = {
            { text = "Poison Volley? Nature damage is SO unprofessional!", heroic = false },
            { text = "Cleave is frontal - don't get caught in that MESS!", heroic = false },
            { text = "Tank faces boss away - SERVE the correct angle!", heroic = false },
        },
        -- Underbog
        hungarfen = {
            { text = "Mushrooms spawn and POP - this ambiance is CHAOTIC!", heroic = false },
            { text = "Spore Cloud? Bad for my FLAWLESS accuracy!", heroic = false },
            { text = "Frenzy at 20% - he's giving finale energy!", heroic = false },
        },
        ghazan = {
            { text = "Giant hydra? Three heads, zero TASTE!", heroic = false },
            { text = "Tail Sweep from behind - the AUDACITY! Stay on the sides!", heroic = false },
            { text = "Acid pools - this decor is OFFENSIVE. Avoid!", heroic = false },
        },
        swamplord_muselek = {
            { text = "He brought his pet bear? CC that UNNECESSARY plus-one!", heroic = false },
            { text = "Freezing Trap catches someone - FREE them immediately!", heroic = false },
            { text = "Multi-Shot sprays - spread for your personal SPOTLIGHT!", heroic = false },
        },
        the_black_stalker = {
            { text = "Chain Lightning? SPREAD out, give everyone their SPACE!", heroic = false },
            { text = "Static Charge? You're about to SERVE - away from the group!", heroic = false },
            { text = "Levitate is like being on a runway - FLOAT, baby!", heroic = false },
            { text = "HEROIC: Spore Striders spawn - more extras for us to SLAY!", heroic = true },
        },
        -- Steamvault
        hydromancer_thespia = {
            { text = "Water Elementals spawn - AoE these CRASHERS down!", heroic = false },
            { text = "Cyclone - wait it out, darling. Even divas need breathers!", heroic = false },
            { text = "Lung Burst DOT - healers, WERK those heals!", heroic = false },
        },
        mekgineer_steamrigger = {
            { text = "Gnome with minions? Kill the BACKUP dancers first!", heroic = false },
            { text = "They heal him? The AUDACITY! Priority targets!", heroic = false },
            { text = "Saw Blade frontal - tank SERVES the correct angle!", heroic = false },
        },
        warlord_kalithresh = {
            { text = "He's drinking from distillers? BAR SERVICE during a fight?!", heroic = false },
            { text = "Click the distiller - CUT HIM OFF, honey!", heroic = false },
            { text = "Impale hurts - tank is giving RESILIENCE!", heroic = false },
            { text = "HEROIC: His buff is EXTRA - deny him that glow-up!", heroic = true },
        },
        -- Mana-Tombs
        pandemonius = {
            { text = "Void Blast - interrupt that TACKY display!", heroic = false },
            { text = "Dark Shell REFLECTS - STOP! He's giving mirror!", heroic = false },
            { text = "Void zones - this floor is CURSED. Move!", heroic = false },
        },
        tavarok = {
            { text = "Earthquake? This venue is UNSTABLE, darling!", heroic = false },
            { text = "Crystal Prison - someone FREE that trapped queen!", heroic = false },
            { text = "Frontal cleave - stay BEHIND the disaster!", heroic = false },
        },
        yor = {
            { text = "All that shadow energy... needs HIGHLIGHTS, darling! So drab!", heroic = false },
            { text = "Double Breath? Sweetie, I am NOT getting void in my feathers!", heroic = false },
            { text = "Stomp is giving EARTHQUAKE DRAMA! Brace yourself fabulously!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds? More extras to ELIMINATE!", heroic = false },
            { text = "Frost Nova freezes - dispel or trinket, BREAK FREE!", heroic = false },
            { text = "He Blinks around - the DRAMA of it all!", heroic = false },
            { text = "HEROIC: More adds, more CHAOS - we THRIVE in chaos!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic? Get CLOSE to break that curse!", heroic = false },
            { text = "Carnivorous Bite - tank is getting EATEN, heal them!", heroic = false },
            { text = "Focus Fire burns - EXIT that spotlight, darling!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone - the DRAMA is real!", heroic = false },
            { text = "Ribbon of Souls chases - KITE it like it's paparazzi!", heroic = false },
            { text = "Avatar at 25% - shadow clone SPAWNS! Priority target, darling!", heroic = false },
            { text = "HEROIC: Avatar is EXTRA - give it the attention it craves, then destroy it!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn - each one's a different LOOK!", heroic = false },
            { text = "Chain Lightning - SPREAD! Personal space, people!", heroic = false },
            { text = "New adds at thresholds - the DRAMA never stops!", heroic = false },
        },
        anzu = {
            { text = "Those dark feathers are giving VILLAIN CHIC, darling! Work!", heroic = false },
            { text = "Spell Bomb? Sweetie, step AWAY from the spotlight before you ruin the show!", heroic = false },
            { text = "Cyclone of Feathers - it's giving DRAMA! Move gracefully!", heroic = false },
            { text = "HEROIC: The ferocity! The POWER! Iconic villain energy!", heroic = true },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion? Hide behind a pillar like paparazzi's coming!", heroic = false },
            { text = "He Blinks around - always making an ENTRANCE!", heroic = false },
            { text = "Slow debuff - tragic for our FIERCE movement!", heroic = false },
            { text = "HEROIC: That explosion is DEADLY - pillars save LIVES!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish the Ritualists - clear the OPENING ACT!", heroic = false },
            { text = "Constant fear - the DRAMA is nonstop, honey!", heroic = false },
            { text = "Acid melts armor - TRAGIC for the tank's outfit!", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos - we're fighting EACH OTHER? The BETRAYAL!", heroic = false },
            { text = "No control during Chaos - just ACCEPT the messiness!", heroic = false },
            { text = "War Stomp stuns - back out before the DRAMATIC stomp!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers from portals - uninvited GUESTS!", heroic = false },
            { text = "Draw Shadows pulls us in - how AGGRESSIVE! Run after!", heroic = false },
            { text = "Rain of Fire - this lighting is TERRIBLE! Move!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom? Get CLOSE to the sound - own that stage!", heroic = false },
            { text = "Touch bomb? Time to make a DRAMATIC exit from the group!", heroic = false },
            { text = "Thundering Storm hits at range - stay CLOSE to own that stage!", heroic = false },
            { text = "HEROIC: Everything hits HARDER - but we hit BACK!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift - group with your MATCHING colors, darlings!", heroic = false },
            { text = "Opposite charges hurt - some energies just DON'T mix!", heroic = false },
            { text = "Head Crack on tank - heal through that ASSAULT!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase people - KITE those obsessed fans!", heroic = false },
            { text = "Dragon's Breath cone - don't CLUSTER, have some ELEGANCE!", heroic = false },
            { text = "Arcane Blast - interrupt that TACKY move!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Nether Wraiths spawn - AoE these EXTRAS down!", heroic = false },
            { text = "Mind Control? Someone's being STOLEN - CC them gently!", heroic = false },
            { text = "Disgruntled adds - even his minions are OVER him!", heroic = false },
            { text = "HEROIC: More damage? We THRIVE under pressure!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "Reservists spawn - AoE these BACKUP dancers!", heroic = false },
            { text = "Arcane Resonance marks someone - SPREAD from the star!", heroic = false },
            { text = "More adds at thresholds - the DRAMA escalates!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "Seedlings EXPLODE - kill them before they make a SCENE!", heroic = false },
            { text = "Tree Form heals - he's trying to GLOW UP mid-fight!", heroic = false },
            { text = "Nature's Blessing - interrupt that SELF-CARE!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice stuns and drains - FREE that victim!", heroic = false },
            { text = "Hellfire everywhere - this aesthetic is CHAOTIC!", heroic = false },
            { text = "Enrages low health - FINISH him before the tantrum!", heroic = false },
        },
        laj = {
            { text = "Color changes? This boss has MULTIPLE looks - iconic!", heroic = false },
            { text = "Each color resists differently - ADAPT your damage, darling!", heroic = false },
            { text = "Thorn Lasher adds - more EXTRAS to eliminate!", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings walk to him - they're his FAN CLUB, destroy them!", heroic = false },
            { text = "They HEAL him? Cut off his SUPPORT system!", heroic = false },
            { text = "Arcane Volley - group damage, healers WERK!", heroic = false },
            { text = "HEROIC: More saplings, faster - his fans are RELENTLESS!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone spawns - this floor is CURSED! Move!", heroic = false },
            { text = "Seed of Corruption - dispel or spread that MESS!", heroic = false },
            { text = "Shadow Nova - group damage, we ENDURE!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind? Melee need to EXIT stage left!", heroic = false },
            { text = "Gift of the Doomsayer HEALS her - dispel that AUDACITY!", heroic = false },
            { text = "Shadow Wave frontal - tank SERVES the correct angle!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire leaves burns - this decor is HOSTILE!", heroic = false },
            { text = "Charge knocks back - stay away from the EDGES!", heroic = false },
            { text = "Knock Away - the RUDENESS! Position safe!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "He SPLITS? Trying to steal the spotlight with COPIES!", heroic = false },
            { text = "Mind Rend DOT - dispel that HEADACHE!", heroic = false },
            { text = "66% and 33% splits - more fakes to ELIMINATE!", heroic = false },
            { text = "HEROIC: Illusions hit just as hard - ALL stars need attention!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind? Melee BACK UP from that spinning mess!", heroic = false },
            { text = "Mortal Strike on tank - heal through that ASSAULT!", heroic = false },
            { text = "Simple fight - FINALLY, a straightforward SERVE!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight! He's making an ENTRANCE!", heroic = false },
            { text = "Holy Light heals him - INTERRUPT that self-care!", heroic = false },
            { text = "Consecration - this floor is HOT! Move!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall! He's the SPECIAL guest!", heroic = false },
            { text = "Wing Buffet knocks back - RUDE! Position carefully!", heroic = false },
            { text = "Sand Breath cone - tank SERVES away from the group!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss! Kill him before the next portal STEALS attention!", heroic = false },
            { text = "Arcane Blast - interrupt that DISPLAY!", heroic = false },
            { text = "Time Lapse moves you back - DISORIENTING but we persist!", heroic = false },
        },
        temporus = {
            { text = "Another portal boss! This is a TIME-SENSITIVE slay!", heroic = false },
            { text = "Hasten speeds him up - he's getting DESPERATE!", heroic = false },
            { text = "Mortal Wound stacks - tank is SUFFERING, heal them!", heroic = false },
        },
        aeonus = {
            { text = "Final boss! The FINALE is here, darlings!", heroic = false },
            { text = "Sand Breath frontal - FACE away from the audience!", heroic = false },
            { text = "Time Stop freezes everyone - dramatic PAUSE!", heroic = false },
            { text = "HEROIC: He hits harder - our FINALE must be PERFECT!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains crystals for power? The GREED!", heroic = false },
            { text = "Fel Explosion after drain - BIG dramatic damage!", heroic = false },
            { text = "Focus crystals - deny him his POWER-UP!", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds chase - OBSESSED fans incoming!", heroic = false },
            { text = "Overload increases damage but hurts - POWER comes with a PRICE!", heroic = false },
            { text = "Chain Lightning - SPREAD for your own spotlight!", heroic = false },
            { text = "HEROIC: More Pure Energies - the chaos is IMMACULATE!", heroic = true },
        },
        priestess_delrissa = {
            { text = "Random adds? ADAPT! Divas are VERSATILE!", heroic = false },
            { text = "CC as many as possible - control the STAGE!", heroic = false },
            { text = "Kill order depends - use your INSTINCTS!", heroic = false },
            { text = "HEROIC: Adds hit like STARS - respect the ensemble!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Phoenix? That bird needs to stay DOWN, darling!", heroic = false },
            { text = "Flamestrike? Move like you're on the RUNWAY!", heroic = false },
            { text = "Gravity Lapse - FLOAT to him with GRACE and VIOLENCE!", heroic = false },
            { text = "Pyroblast interrupt - someone shut that DRAMA down!", heroic = false },
            { text = "HEROIC: The Phoenix has better comebacks - destroy that egg FAST!", heroic = true },
        },
    },
}

-- Default tips for bosses without personality-specific content
CritterContent.DEFAULT_BOSS_TIPS = {
    watchkeeper_gargolmar = {
        { text = "Kill the healing adds when they spawn at 50% health.", heroic = false },
        { text = "Tank takes Mortal Strike - healers be ready!", heroic = false },
        { text = "HEROIC: Surge does more damage - spread out!", heroic = true },
    },
    omor_the_unscarred = {
        { text = "Kill Felhounds quickly when they spawn.", heroic = false },
        { text = "Don't stand in the green fel fire.", heroic = false },
        { text = "Tank near door for line of sight on Shadowbolt.", heroic = false },
    },
    nazan = {
        { text = "Kill Vazruden first, then the dragon lands.", heroic = false },
        { text = "Move out of fire bombs on the ground.", heroic = false },
        { text = "Tank dragon facing away from group.", heroic = false },
    },
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
        -- Fall back to chomp
        critterQuips = self.QUIPS.chomp
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

--[[
    Check if hub has any progress (any dungeon has been started/visited)
    Used for the new simplified unlock system where ANY boss kill unlocks the critter
    @param hubKey string - Hub key (e.g., "hellfire")
    @param completedDungeons table - Table of completed dungeon keys
    @return boolean - True if any dungeon in hub has been started
]]
function CritterContent:HasHubProgress(hubKey, completedDungeons)
    local hub = self.DUNGEON_HUBS[hubKey]
    if not hub then return false end

    -- Return true if ANY dungeon in hub has been started
    for _, dungeonKey in ipairs(hub.dungeons) do
        if completedDungeons[dungeonKey] then
            return true
        end
    end
    return false
end

--[[
    Get boss tips for the given critter and boss
    @param critterId string - Critter identifier
    @param bossKey string - Boss key (e.g., "watchkeeper_gargolmar")
    @param isHeroic boolean - Whether to include heroic-only tips
    @return table - Array of tip objects { text, heroic }
]]
function CritterContent:GetBossTips(critterId, bossKey, isHeroic)
    local tips = {}

    -- Try critter-specific tips first
    local critterTips = self.BOSS_TIPS[critterId]
    if critterTips and critterTips[bossKey] then
        for _, tip in ipairs(critterTips[bossKey]) do
            if not tip.heroic or isHeroic then
                table.insert(tips, tip)
            end
        end
        return tips
    end

    -- Fall back to chomp if no critter-specific tips
    if critterId ~= "chomp" then
        critterTips = self.BOSS_TIPS.chomp
        if critterTips and critterTips[bossKey] then
            for _, tip in ipairs(critterTips[bossKey]) do
                if not tip.heroic or isHeroic then
                    table.insert(tips, tip)
                end
            end
            return tips
        end
    end

    -- Fall back to default tips
    local defaultTips = self.DEFAULT_BOSS_TIPS[bossKey]
    if defaultTips then
        for _, tip in ipairs(defaultTips) do
            if not tip.heroic or isHeroic then
                table.insert(tips, tip)
            end
        end
    end

    return tips
end

--[[
    Get the count of tips available for a boss
    @param bossKey string - Boss key
    @param isHeroic boolean - Whether to count heroic-only tips
    @return number - Number of tips available
]]
function CritterContent:GetBossTipCount(bossKey, isHeroic)
    -- Check chomp tips as default (most complete)
    local critterTips = self.BOSS_TIPS.chomp
    local count = 0

    if critterTips and critterTips[bossKey] then
        for _, tip in ipairs(critterTips[bossKey]) do
            if not tip.heroic or isHeroic then
                count = count + 1
            end
        end
        return count
    end

    -- Fall back to default tips
    local defaultTips = self.DEFAULT_BOSS_TIPS[bossKey]
    if defaultTips then
        for _, tip in ipairs(defaultTips) do
            if not tip.heroic or isHeroic then
                count = count + 1
            end
        end
    end

    return count
end

--[[
    Check if tips exist for a given boss
    @param bossKey string - Boss key
    @return boolean - True if tips exist
]]
function CritterContent:HasBossTips(bossKey)
    -- Check any critter
    for critterId, critterTips in pairs(self.BOSS_TIPS) do
        if critterTips[bossKey] and #critterTips[bossKey] > 0 then
            return true
        end
    end

    -- Check defaults
    if self.DEFAULT_BOSS_TIPS[bossKey] and #self.DEFAULT_BOSS_TIPS[bossKey] > 0 then
        return true
    end

    return false
end

--============================================================
-- BOSS GUIDES (Dungeon entry quick guides for floating bubble)
-- Short 1-2 sentence tips per boss, shown on dungeon entry
--============================================================

CritterContent.BOSS_GUIDES = {
    -- Hellfire Ramparts
    ramparts = {
        { boss = "Watchkeeper Gargolmar", tip = "Tank faces him away - he does a frontal cleave. Kill the healers first!" },
        { boss = "Omor the Unscarred", tip = "Spread out to avoid his Treacherous Aura. Kill the Felhound quickly!" },
        { boss = "Vazruden and Nazan", tip = "Kill Vazruden first, then the dragon lands. Avoid the fire on the ground!" },
    },
    -- Blood Furnace
    blood_furnace = {
        { boss = "The Maker", tip = "He mind controls - don't stand near the edge! Interrupt his Domination." },
        { boss = "Broggok", tip = "Four waves of orcs before the boss. Save cooldowns for wave 4!" },
        { boss = "Keli'dan the Breaker", tip = "RUN OUT when he yells 'Closer... Come closer!' or you'll explode!" },
    },
    -- Shattered Halls
    shattered_halls = {
        { boss = "Grand Warlock Nethekurse", tip = "Kill his minions fast - he sacrifices them for power. Interrupt Dark Spin!" },
        { boss = "Blood Guard Porung", tip = "Heroic only! Kill adds first, then focus the Blood Guard." },
        { boss = "Warbringer O'mrogg", tip = "Two-headed ogre swaps threat between heads. Watch for Blast Wave!" },
        { boss = "Warchief Kargath Bladefist", tip = "The gauntlet is the real boss. Blade Dance means spread out!" },
    },
    -- Slave Pens
    slave_pens = {
        { boss = "Mennu the Betrayer", tip = "Kill his totems! Healing totem is top priority." },
        { boss = "Rokmar the Crackler", tip = "Grievous Wound stacks on tank - heal through it. Frenzy at low HP!" },
        { boss = "Quagmirran", tip = "Poison Bolt Volley hits hard. Tank faces him away from group!" },
    },
    -- Underbog
    underbog = {
        { boss = "Hungarfen", tip = "Mushrooms spawn and explode - move away! Frenzy at 20%." },
        { boss = "Ghaz'an", tip = "Frontal acid cone - tank carefully. Stay out of acid pools!" },
        { boss = "Swamplord Musel'ek", tip = "CC the bear if you can! Break Freezing Traps fast." },
        { boss = "The Black Stalker", tip = "Chain Lightning bounces - spread out! Run away with Static Charge!" },
    },
    -- Steamvault
    steamvault = {
        { boss = "Hydromancer Thespia", tip = "Water Elementals spawn - AoE them down. Wait out the Cyclone." },
        { boss = "Mekgineer Steamrigger", tip = "Kill the Mechanics first - they heal the boss!" },
        { boss = "Warlord Kalithresh", tip = "Click distillers when he channels! Don't let him get the buff!" },
    },
    -- Mana-Tombs
    mana_tombs = {
        { boss = "Pandemonius", tip = "STOP DPS during Dark Shell - it reflects! Move from void zones." },
        { boss = "Tavarok", tip = "Crystal Prison stuns - break them out! Stay behind him for Arcing Smash." },
        { boss = "Nexus-Prince Shaffar", tip = "Kill ethereal adds quickly! Frost Nova can be dispelled." },
    },
    -- Auchenai Crypts
    auchenai_crypts = {
        { boss = "Shirrak the Dead Watcher", tip = "Get close to remove Inhibit Magic! Move from Focus Fire." },
        { boss = "Exarch Maladaar", tip = "Fear ward or tremor totem helps. Kill the Avatar at 25%!" },
    },
    -- Sethekk Halls
    sethekk_halls = {
        { boss = "Darkweaver Syth", tip = "Elemental adds spawn at health thresholds - AoE them down!" },
        { boss = "Talon King Ikiss", tip = "Run behind a pillar for Arcane Explosion! It can one-shot!" },
    },
    -- Shadow Labyrinth
    shadow_lab = {
        { boss = "Ambassador Hellmaw", tip = "Banish Ritualists first or he's unkillable! Fear is constant." },
        { boss = "Blackheart the Inciter", tip = "Incite Chaos = PvP time. Spread out, you'll hit each other!" },
        { boss = "Grandmaster Vorpil", tip = "AoE the Voidwalkers! Run away after Draw Shadows!" },
        { boss = "Murmur", tip = "Get CLOSE for Sonic Boom! Run away if you have Murmur's Touch!" },
    },
    -- Mechanar
    mechanar = {
        { boss = "Mechano-Lord Capacitus", tip = "Polarity Shift - group with same colors! Opposite charges hurt together!" },
        { boss = "Nethermancer Sepethrea", tip = "Kite the Fire Elementals! Dragon's Breath is a cone." },
        { boss = "Pathaleon the Calculator", tip = "AoE the Nether Wraiths! Don't ignore the Disgruntled adds." },
    },
    -- Botanica
    botanica = {
        { boss = "Commander Sarannis", tip = "AoE the Reservists! Spread from Arcane Resonance target." },
        { boss = "High Botanist Freywinn", tip = "Kill White Seedlings before they explode! Interrupt Tree Form heals." },
        { boss = "Thorngrin the Tender", tip = "Break out Sacrifice targets! Hellfire hurts everyone nearby." },
        { boss = "Laj", tip = "Color changes mean immunity! Adjust DPS to the current color." },
        { boss = "Warp Splinter", tip = "Kill Saplings before they reach him - they heal the boss!" },
    },
    -- Arcatraz
    arcatraz = {
        { boss = "Zereketh the Unbound", tip = "Move from Void Zones! Dispel or spread for Seed of Corruption." },
        { boss = "Dalliah the Doomsayer", tip = "Melee get OUT during Whirlwind! Dispel Gift of the Doomsayer." },
        { boss = "Wrath-Scryer Soccothrates", tip = "Move from Felfire! Stay away from edges - Charge knocks back." },
        { boss = "Harbinger Skyriss", tip = "He splits into illusions at 66% and 33% - kill them fast!" },
    },
    -- Old Hillsbrad
    old_hillsbrad = {
        { boss = "Lieutenant Drake", tip = "Simple fight - just back away during Whirlwind!" },
        { boss = "Captain Skarloc", tip = "Interrupt Holy Light! Move from Consecration." },
        { boss = "Epoch Hunter", tip = "Protect Thrall! Face the dragon away from group." },
    },
    -- Black Morass
    black_morass = {
        { boss = "Chrono Lord Deja", tip = "Kill before next portal! Interrupt Arcane Blast." },
        { boss = "Temporus", tip = "DPS race! Mortal Wound stacks on tank - healers be ready." },
        { boss = "Aeonus", tip = "Final boss! Sand Breath is frontal. Time Stop is just a stun." },
    },
    -- Magisters' Terrace
    magisters_terrace = {
        { boss = "Selin Fireheart", tip = "Destroy mana crystals before he drains them! Fel Explosion hurts." },
        { boss = "Vexallus", tip = "Kill or kite Pure Energies! Overload increases your damage but hurts you." },
        { boss = "Priestess Delrissa", tip = "CC adds if you can! Kill order depends on which adds spawn." },
        { boss = "Kael'thas Sunstrider", tip = "Kill Phoenix Egg! Move from Flamestrike. Swim to him during Gravity Lapse!" },
    },
}

--============================================================
-- RAID BOSS TIPS (Universal tips for all critters)
-- Used by the Raid Guide Panel for boss strategy tips
--============================================================

CritterContent.RAID_BOSS_TIPS = {
    -- Gruul's Lair
    gruul = {
        high_king_maulgar = {
            { text = "Kill order: Blindeye (healer) -> Olm (warlock) -> Kiggler (shaman) -> Krosh (mage) -> Maulgar. Spellsteal Krosh's shield. Hunter pets tank Kiggler.", heroic = false },
        },
        gruul = {
            { text = "Growth stacks +15% damage every 30s - DPS race. Spread out for Ground Slam -> Shatter. Two tanks for Hurtful Strike. Move from Cave In circles.", heroic = false },
        },
    },
    -- Magtheridon's Lair
    magtheridon = {
        magtheridon = {
            { text = "Phase 1: Kill 5 Channelers in 2 min, interrupt Dark Mending. Phase 2: 5 players click Cubes together to stop Blast Nova. At 30% ceiling falls - avoid debris.", heroic = false },
        },
    },
    -- Karazhan
    karazhan = {
        attumen = {
            { text = "Phase 1: Tank Midnight, stack behind horse. Attumen spawns at 95%. Phase 2: They merge at 25% - increased damage. Tank faces away, avoid Charge.", heroic = false },
        },
        moroes = {
            { text = "AoE or CC adds - if not AoE then use kill order. Garrote DOT on random players - can't be dispelled, just heal through.", heroic = false },
        },
        maiden = {
            { text = "Repentance stuns entire raid every 30s - spread for Holy Fire that follows. Holy Ground aura damages melee. Dispel Holy Fire fast.", heroic = false },
        },
        opera = {
            { text = "Random event: Oz (kill adds then Crone), Red Riding Hood (kite Big Bad Wolf, don't get eaten), Romulo & Julianne (kill both within 10s).", heroic = false },
        },
        curator = {
            { text = "Kill Astral Flares as they spawn - they chain lightning. At 15% Curator Evocates (takes double damage) - save cooldowns for this burn phase.", heroic = false },
        },
        shade = {
            { text = "Don't move during Flame Wreath. Run from Blizzard. Run OUT during Arcane Explosion. Adds at 40%. Interrupt Pyroblast if you can.", heroic = false },
        },
        illhoof = {
            { text = "Demon Chains = swap immediately to free player. Imp adds need AoE. Kil'rek imp buffs boss - kill it when it spawns.", heroic = false },
        },
        netherspite = {
            { text = "Three beams from portals - must be soaked by players or boss gets buffed. Red=tank, Green=healer, Blue=DPS. Rotate soakers, stacks hurt. Banish phase = run out.", heroic = false },
        },
        chess = {
            { text = "Control chess pieces, not your character. King must survive. Move pieces to attack Medivh's side. Use abilities on cooldown. Protect your King, kill their King.", heroic = false },
        },
        prince = {
            { text = "Three phases with increasing damage. Infernals fall throughout - spread and avoid. Enfeeble = you have 1 HP, stay safe. Tank near wall.", heroic = false },
        },
        nightbane = {
            { text = "Dragon with air phases. Ground: tank away from raid. Air: AoE skeletons and move from fire. Returns to ground at HP breakpoints.", heroic = false },
        },
    },
    -- Serpentshrine Cavern
    ssc = {
        hydross = {
            { text = "Nature/Frost resist tanks swap at transitions. Kill adds during transitions. Don't cross the threshold accidentally.", heroic = false },
        },
        lurker = {
            { text = "Jump in water during Spout. Kill adds on platforms. Avoid Whirl knockback.", heroic = false },
        },
        leotheras = {
            { text = "Demon form = high tank damage. Inner Demons at 15% - kill your own demon. Whirlwind = run away.", heroic = false },
        },
        karathress = {
            { text = "Kill order: Caribdis -> Tidalvess -> Sharkkis -> Karathress. Boss gains abilities from dead adds.", heroic = false },
        },
        morogrim = {
            { text = "Murloc waves from graves - AoE them. Earthquake = spread. Watery Grave = heal the tombed.", heroic = false },
        },
        vashj = {
            { text = "Phase 2: Loot cores from Tainted Elementals, throw to players near generators. Phase 3: Burst DPS.", heroic = false },
        },
    },
    -- Tempest Keep
    tk = {
        alar = {
            { text = "Phase 1: Moves between platforms, tank swaps. Phase 2: Meteor = move away. Kill adds.", heroic = false },
        },
        void_reaver = {
            { text = "Simple fight. Spread for Arcane Orbs. Melee watch Pounding. Tank and spank.", heroic = false },
        },
        solarian = {
            { text = "Spread for Arcane Missiles. Bomb debuff = run to edge. Kill adds during split phase.", heroic = false },
        },
        kaelthas = {
            { text = "5 phases. Learn weapon abilities. Kill advisors in order. Phoenix eggs must die. Gravity Lapse = float and DPS.", heroic = false },
        },
    },
}

--[[
    Get boss guides for a dungeon (used by floating bubble on dungeon entry)
    @param dungeonKey string - Dungeon key (e.g., "ramparts")
    @return table - Array of { boss, tip } or empty table
]]
function CritterContent:GetBossGuides(dungeonKey)
    return self.BOSS_GUIDES[dungeonKey] or {}
end

--[[
    Get all critters (for debug panel)
    @return table - All critter data
]]
function CritterContent:GetAllCritters()
    return self.CRITTERS
end

--[[
    Get raid boss tips by looking up boss mechanics from Constants
    First checks RAID_BOSS_TIPS (universal tips), then falls back to BOSS_TIPS,
    then falls back to generating tips from boss mechanics data
    @param critterId string - Critter identifier
    @param raidKey string - Raid key (e.g., "karazhan")
    @param bossId string - Boss ID (e.g., "attumen")
    @return table - Array of tip objects { text, heroic }
]]
function CritterContent:GetRaidBossTips(critterId, raidKey, bossId)
    -- First check RAID_BOSS_TIPS (universal tips for all critters)
    if self.RAID_BOSS_TIPS and self.RAID_BOSS_TIPS[raidKey] then
        local raidTips = self.RAID_BOSS_TIPS[raidKey][bossId]
        if raidTips and #raidTips > 0 then
            return raidTips
        end
    end

    -- Then try to get from BOSS_TIPS if they exist
    local tips = self:GetBossTips(critterId, bossId, false)
    if tips and #tips > 0 then
        return tips
    end

    -- Fall back to generating tips from Constants mechanics
    local C = HopeAddon.Constants
    if not C then return {} end

    local bossTable = nil
    if raidKey == "karazhan" then
        bossTable = C.KARAZHAN_BOSSES
    elseif raidKey == "gruul" then
        bossTable = C.GRUUL_BOSSES
    elseif raidKey == "magtheridon" then
        bossTable = C.MAGTHERIDON_BOSSES
    elseif raidKey == "ssc" then
        bossTable = C.SSC_BOSSES
    elseif raidKey == "tk" then
        bossTable = C.TK_BOSSES
    end

    if not bossTable then return {} end

    -- Find the boss
    local bossData = nil
    for _, boss in ipairs(bossTable) do
        if boss.id == bossId then
            bossData = boss
            break
        end
    end

    if not bossData then return {} end

    -- Generate tips from mechanics
    local generatedTips = {}

    if bossData.mechanics then
        for _, mechanic in ipairs(bossData.mechanics) do
            table.insert(generatedTips, { text = mechanic, heroic = false })
        end
    end

    -- Add phase info if available
    if bossData.phases then
        for _, phase in ipairs(bossData.phases) do
            if phase.strategy then
                table.insert(generatedTips, { text = phase.name .. ": " .. phase.strategy, heroic = false })
            end
        end
    end

    -- Add council info if available
    if bossData.council then
        for _, member in ipairs(bossData.council) do
            if member.role then
                table.insert(generatedTips, { text = member.name .. " - " .. member.role, heroic = false })
            end
        end
    end

    -- Add strategy if available
    if bossData.strategy then
        table.insert(generatedTips, { text = bossData.strategy, heroic = false })
    end

    -- If still no tips, add a quote or lore as flavor
    if #generatedTips == 0 and bossData.lore then
        table.insert(generatedTips, { text = bossData.lore, heroic = false })
    end

    return generatedTips
end
