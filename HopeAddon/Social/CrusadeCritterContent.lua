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
-- BOSS TIPS DATABASE
-- Personality-flavored mechanics explanations for boss teaching system
-- Tips marked with heroic = true only show in heroic mode
--============================================================

CritterContent.BOSS_TIPS = {
    --============================================================
    -- FLUX (2007 references, old tech/memes, MySpace/AIM/flip phones)
    --============================================================
    flux = {
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
            { text = "Void Blast hits hard - interrupt it if you can!", heroic = false },
            { text = "Dark Shell reflects damage - STOP DPS when he casts it!", heroic = false },
            { text = "He does a void zone - move out of the purple!", heroic = false },
        },
        tavarok = {
            { text = "Giant rock elemental - Earthquake makes everyone shake!", heroic = false },
            { text = "Crystal Prison stuns a target - break them out!", heroic = false },
            { text = "Arcing Smash is frontal cleave - stay behind him!", heroic = false },
        },
        nexus_prince_shaffar = {
            { text = "Ethereal adds spawn throughout - kill them fast!", heroic = false },
            { text = "Frost Nova freezes everyone - be ready to trinket or dispel!", heroic = false },
            { text = "Blink puts him all over - casters have it easier!", heroic = false },
            { text = "HEROIC: More adds, more often - AoE is your friend!", heroic = true },
        },
        -- Auchenai Crypts
        shirrak_the_dead_watcher = {
            { text = "Inhibit Magic reduces casting speed - get close to remove it!", heroic = false },
            { text = "Carnivorous Bite is nasty on the tank - heal through it!", heroic = false },
            { text = "Focus Fire burns a spot - move out of it!", heroic = false },
        },
        exarch_maladaar = {
            { text = "Soul Scream fears everyone - tremor totem or fear ward!", heroic = false },
            { text = "Ribbon of Souls chases someone - kite it away!", heroic = false },
            { text = "At 25% he summons an Avatar - kill it fast, then finish him!", heroic = false },
            { text = "HEROIC: The Avatar is much stronger - save cooldowns for it!", heroic = true },
        },
        -- Sethekk Halls
        darkweaver_syth = {
            { text = "Elemental adds spawn - each one has different attacks!", heroic = false },
            { text = "Chain Lightning bounces - spread out!", heroic = false },
            { text = "He summons new elementals at health thresholds - be ready!", heroic = false },
        },
        talon_king_ikiss = {
            { text = "Arcane Explosion is HUGE - run behind a pillar!", heroic = false },
            { text = "He Blinks around - ranged stay close to avoid issues!", heroic = false },
            { text = "Slow debuff reduces movement - annoying but survivable!", heroic = false },
            { text = "HEROIC: Arcane Explosion can one-shot - pillars are LIFE!", heroic = true },
        },
        -- Shadow Labyrinth
        ambassador_hellmaw = {
            { text = "Banish the Ritualists first or he's unkillable!", heroic = false },
            { text = "Fear is constant - tremor totem is clutch!", heroic = false },
            { text = "Corrosive Acid reduces armor - hurts the tank!", heroic = false },
        },
        blackheart_the_inciter = {
            { text = "Incite Chaos makes everyone fight each other - spread out!", heroic = false },
            { text = "During Chaos, you can't control your character - just accept it!", heroic = false },
            { text = "War Stomp stuns melee - back out before he casts it!", heroic = false },
        },
        grandmaster_vorpil = {
            { text = "Voidwalkers spawn from portals - AoE them down!", heroic = false },
            { text = "Draw Shadows pulls everyone to him - run away after!", heroic = false },
            { text = "Rain of Fire is deadly - move out of the fire!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom does massive damage - get close to reduce it!", heroic = false },
            { text = "Murmur's Touch is a bomb - run away from the group!", heroic = false },
            { text = "Thundering Storm hits anyone not in melee - stay close!", heroic = false },
            { text = "HEROIC: Everything hits harder - positioning is key!", heroic = true },
        },
        -- Mechanar
        mechano_lord_capacitus = {
            { text = "Polarity Shift - group up with same-colored people!", heroic = false },
            { text = "Positive and Negative charges - opposite charges HURT together!", heroic = false },
            { text = "Head Crack is a big hit on tank - heal through it!", heroic = false },
        },
        nethermancer_sepethrea = {
            { text = "Fire Elementals chase random people - kite them!", heroic = false },
            { text = "Dragon's Breath is a cone - don't group up!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt when possible!", heroic = false },
        },
        pathaleon_the_calculator = {
            { text = "Summons Nether Wraiths - AoE them down fast!", heroic = false },
            { text = "Mind Control is random - kill the MC'd player if needed (nicely)!", heroic = false },
            { text = "Disgruntled Employees are adds - don't ignore them!", heroic = false },
            { text = "HEROIC: His damage is calculated to hurt MORE!", heroic = true },
        },
        -- Botanica
        commander_sarannis = {
            { text = "She summons Bloodwarder Reservists - AoE them down!", heroic = false },
            { text = "Arcane Resonance marks someone - spread out from them!", heroic = false },
            { text = "Summon Reinforcements happens at health thresholds - be ready!", heroic = false },
        },
        high_botanist_freywinn = {
            { text = "White Seedling adds explode - kill them fast!", heroic = false },
            { text = "Tree Form heals him - burn through or crowd control adds!", heroic = false },
            { text = "Nature's Blessing heals - interrupt it!", heroic = false },
        },
        thorngrin_the_tender = {
            { text = "Sacrifice stuns someone and drains life - break them out!", heroic = false },
            { text = "Hellfire damages everyone nearby - range it if you can!", heroic = false },
            { text = "Enrage at low health - burn him fast!", heroic = false },
        },
        laj = {
            { text = "Color changes mean immunity! Watch for red/green/blue shifts!", heroic = false },
            { text = "Each color is immune to certain schools - adjust DPS!", heroic = false },
            { text = "Summons Thorn Lasher adds - AoE them down!", heroic = false },
        },
        warp_splinter = {
            { text = "Saplings spawn and walk to him - kill them before they reach!", heroic = false },
            { text = "If saplings reach him, he heals - don't let that happen!", heroic = false },
            { text = "Arcane Volley is group damage - heal through it!", heroic = false },
            { text = "HEROIC: More saplings, faster spawn - DPS on point!", heroic = true },
        },
        -- Arcatraz
        zereketh_the_unbound = {
            { text = "Void Zone spawns under people - MOVE!", heroic = false },
            { text = "Seed of Corruption on random targets - dispel or spread!", heroic = false },
            { text = "Shadow Nova is group damage - heal through it!", heroic = false },
        },
        dalliah_the_doomsayer = {
            { text = "Whirlwind is deadly - melee get OUT!", heroic = false },
            { text = "Gift of the Doomsayer heals her - dispel it!", heroic = false },
            { text = "Shadow Wave is a frontal cone - tank face her away!", heroic = false },
        },
        wrath_scryer_soccothrates = {
            { text = "Felfire Shock leaves fire on ground - move out!", heroic = false },
            { text = "Charge knocks back - stay away from edges!", heroic = false },
            { text = "Knock Away sends tank flying - be positioned safely!", heroic = false },
        },
        harbinger_skyriss = {
            { text = "Multi-phase fight - he splits into copies at health thresholds!", heroic = false },
            { text = "Mind Rend is a DOT - dispel it!", heroic = false },
            { text = "66% and 33% he splits - kill the illusions!", heroic = false },
            { text = "HEROIC: Illusions hit just as hard as him - focus fire!", heroic = true },
        },
        -- Old Hillsbrad
        lieutenant_drake = {
            { text = "Whirlwind is melee death - back away when he spins!", heroic = false },
            { text = "Mortal Strike on tank - heal through the debuff!", heroic = false },
            { text = "Simple tank and spank - just respect the Whirlwind!", heroic = false },
        },
        captain_skarloc = {
            { text = "Mounted fight! He charges around - stay mobile!", heroic = false },
            { text = "Holy Light heals him - interrupt it!", heroic = false },
            { text = "Consecration hurts - move out of it!", heroic = false },
        },
        epoch_hunter = {
            { text = "Protect Thrall! If he dies, you fail!", heroic = false },
            { text = "Wing Buffet knocks back - position carefully!", heroic = false },
            { text = "Sand Breath is a cone - tank face him away!", heroic = false },
        },
        -- Black Morass
        chrono_lord_deja = {
            { text = "Portal boss! Kill him before the next portal opens!", heroic = false },
            { text = "Arcane Blast hits hard - interrupt it!", heroic = false },
            { text = "Time Lapse puts you back to where you were - disorienting!", heroic = false },
        },
        temporus = {
            { text = "Another portal boss! DPS race is real!", heroic = false },
            { text = "Hasten speeds him up - dangerous at low health!", heroic = false },
            { text = "Mortal Wound stacks on tank - heal through it!", heroic = false },
        },
        aeonus = {
            { text = "Final boss of Black Morass - all the portals led to this!", heroic = false },
            { text = "Sand Breath is frontal cone - face away from group!", heroic = false },
            { text = "Time Stop freezes everyone briefly - just wait it out!", heroic = false },
            { text = "HEROIC: He hits way harder - tank cooldowns ready!", heroic = true },
        },
        -- Magisters' Terrace
        selin_fireheart = {
            { text = "He drains mana crystals for power - interrupt or destroy them!", heroic = false },
            { text = "Fel Explosion when he finishes draining - big damage!", heroic = false },
            { text = "Mana Rage is dangerous - focus down the crystals!", heroic = false },
        },
        vexallus = {
            { text = "Pure Energy adds spawn and run to players - kill or kite!", heroic = false },
            { text = "Overload when adds reach you - increases your damage but hurts!", heroic = false },
            { text = "Chain Lightning bounces - spread out!", heroic = false },
            { text = "HEROIC: More Pure Energies spawn - chaos incarnate!", heroic = true },
        },
        priestess_delrissa = {
            { text = "She has 4 random adds - it's like a mini-PvP fight!", heroic = false },
            { text = "Crowd control is key - CC as many adds as possible!", heroic = false },
            { text = "Kill order depends on the adds you get - adapt!", heroic = false },
            { text = "HEROIC: Adds hit like players - respect them!", heroic = true },
        },
        kaelthas_sunstrider = {
            { text = "Phase 1: Kill the Phoenix Egg when Kael summons it!", heroic = false },
            { text = "Flamestrike targets random players - move out of fire!", heroic = false },
            { text = "Gravity Lapse floats everyone - swim to him and DPS!", heroic = false },
            { text = "Pyroblast is interruptible - someone MUST interrupt!", heroic = false },
            { text = "HEROIC: Phoenix respawns faster - egg priority is critical!", heroic = true },
        },
        -- Stockades (Test)
        kam_deepfury = {
            { text = "Basic boss - tank and spank like it's 2007!", heroic = false },
            { text = "Shield Slam hits hard but nothing special!", heroic = false },
        },
        targorr_the_dread = {
            { text = "Enrage at low health - burn him fast!", heroic = false },
            { text = "Nothing too scary here - good warmup!", heroic = false },
        },
        hamhock = {
            { text = "He chains lightning - spread out a bit!", heroic = false },
            { text = "Bloodlust makes him hit faster - save cooldowns!", heroic = false },
        },
        dextren_ward = {
            { text = "Rend causes bleed - healers watch the tank!", heroic = false },
            { text = "Intimidating Shout fears - be ready!", heroic = false },
        },
        bazil_thredd = {
            { text = "Final boss vibes! Smoke Bomb blinds melee!", heroic = false },
            { text = "Battle Shout buffs him - dispel or burn fast!", heroic = false },
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
        },
        -- Slave Pens
        mennu_the_betrayer = {
            { text = "Totems everywhere like beach umbrellas - knock 'em down!", heroic = false },
            { text = "Healing totem is priority - don't let him recover!", heroic = false },
        },
        rokmar_the_crackler = {
            { text = "Big crab bro! Grievous wounds stack - healers stay focused!", heroic = false },
            { text = "Frenzy at low health - he's got that GTL energy!", heroic = false },
        },
        quagmirran = {
            { text = "Poison is nastier than gas station sushi - nature resist helps!", heroic = false },
            { text = "Don't stand in front - cleave is like a bouncer's punch!", heroic = false },
        },
        -- Continue pattern for remaining bosses...
        -- (Abbreviated for space - same style continues)
        the_black_stalker = {
            { text = "Chain Lightning bounces - spread like you're avoiding drama!", heroic = false },
            { text = "Static Charge? Run from the group like you owe money!", heroic = false },
            { text = "Levitate just wait it out - like a hangover!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - get close or you're getting BODIED!", heroic = false },
            { text = "Touch bomb? Run away like it's your ex at the club!", heroic = false },
            { text = "Stay in melee or Thundering Storm catches you!", heroic = false },
        },
        kaelthas_sunstrider = {
            { text = "Kill the Phoenix Egg or it comes back like a bad tan!", heroic = false },
            { text = "Flamestrike - move your feet like you're dancing!", heroic = false },
            { text = "Gravity Lapse - swim to him and GET THOSE GAINS!", heroic = false },
            { text = "Pyroblast interrupt or someone's getting SMUSHED!", heroic = false },
        },
    },

    --============================================================
    -- SHRED (Extreme sports lingo, gnarly/radical, skateboard references)
    --============================================================
    shred = {
        watchkeeper_gargolmar = {
            { text = "Dude, this orc is like a half-pipe - commit or bail!", heroic = false },
            { text = "Healers spawn at 50% - shred them like a sick rail!", heroic = false },
            { text = "Mortal Strike is gnarly - healers pump those heals!", heroic = false },
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
        the_black_stalker = {
            { text = "Chain Lightning - spread like you're clearing a skate park!", heroic = false },
            { text = "Static Charge - DROP IN away from the crew!", heroic = false },
            { text = "Levitate is like catching air - enjoy the float, bro!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - get close or you're gonna EAT IT!", heroic = false },
            { text = "Murmur's Touch - drop in AWAY from the squad!", heroic = false },
            { text = "Thundering Storm hits ranged - stay tight, stay RADICAL!", heroic = false },
        },
        kaelthas_sunstrider = {
            { text = "Phoenix Egg - DESTROY it or face a gnarly respawn!", heroic = false },
            { text = "Flamestrike - carve around the fire, dude!", heroic = false },
            { text = "Gravity Lapse - AERIAL TRICKS TIME, swim and shred!", heroic = false },
            { text = "Pyroblast - someone needs to SHUT THAT DOWN!", heroic = false },
        },
    },

    --============================================================
    -- EMO (Dark/dramatic descriptions, pain metaphors, poetry-like)
    --============================================================
    emo = {
        watchkeeper_gargolmar = {
            { text = "This orc understands nothing of our suffering... destroy him.", heroic = false },
            { text = "He calls healers at 50%... like hope calling in the darkness.", heroic = false },
            { text = "Mortal Strike... pain is a familiar companion to the tank.", heroic = false },
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
        the_black_stalker = {
            { text = "Chain Lightning... our pain connects us all.", heroic = false },
            { text = "Static Charge marks you... we're all marked, really.", heroic = false },
            { text = "Levitation... if only our spirits could float so easily.", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom... get close to the void, embrace it.", heroic = false },
            { text = "His touch is a bomb... like love, explosive and fleeting.", heroic = false },
            { text = "Stay close to thunder... the storm within mirrors the storm without.", heroic = false },
        },
        kaelthas_sunstrider = {
            { text = "The Phoenix rises and falls... much like my emotions.", heroic = false },
            { text = "Flamestrike burns... but we've felt worse, haven't we?", heroic = false },
            { text = "Gravity fails us... we float in the void of existence.", heroic = false },
            { text = "Pyroblast... interrupt or embrace the sweet release.", heroic = false },
        },
    },

    --============================================================
    -- COSMO (Space/science analogies, dreamy explanations, constellation references)
    --============================================================
    cosmo = {
        watchkeeper_gargolmar = {
            { text = "This orc's aggression is like a solar flare... predictable but dangerous.", heroic = false },
            { text = "Healers at 50%... like binary stars orbiting each other.", heroic = false },
            { text = "Mortal Strike... reducing HP like stellar radiation. *stares*", heroic = false },
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
        the_black_stalker = {
            { text = "Chain Lightning arcs like solar wind... spread formation.", heroic = false },
            { text = "Static Charge... you're like a charged particle. Isolate yourself.", heroic = false },
            { text = "Levitation... *sighs* ...reminds me of microgravity environments.", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom... sound waves at close range are survivable.", heroic = false },
            { text = "His touch creates an explosion radius... maintain safe orbital distance.", heroic = false },
            { text = "Thundering Storm hits at range... like cosmic ray bombardment.", heroic = false },
        },
        kaelthas_sunstrider = {
            { text = "The Phoenix is like a star going supernova... destroy the core!", heroic = false },
            { text = "Flamestrike... solar flares on the ground. Evade.", heroic = false },
            { text = "Gravity Lapse! We're in zero-G! *eyes light up* Navigate to the target!", heroic = false },
            { text = "Pyroblast... a focused plasma beam. Must be interrupted!", heroic = false },
        },
    },

    --============================================================
    -- BOOMER (Back in my day comparisons, old-timer wisdom, simple explanations)
    --============================================================
    boomer = {
        watchkeeper_gargolmar = {
            { text = "In MY day, orcs hit twice as hard! This one's easy.", heroic = false },
            { text = "Healers spawn at 50%? Back then we just DEALT with it!", heroic = false },
            { text = "Mortal Strike? Kids today don't know real tank damage!", heroic = false },
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
        the_black_stalker = {
            { text = "Chain Lightning? Saw this in Molten Core! SPREAD OUT!", heroic = false },
            { text = "Bomb debuff - you're the problem, run AWAY from the group!", heroic = false },
            { text = "Levitate? In MY day we stayed on the ground!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom - they recycled this from C'Thun! Get close!", heroic = false },
            { text = "Touch bomb - JUST LIKE THE OLD RAIDS. Run away!", heroic = false },
            { text = "Stay close or take damage. Simple rules, simple times.", heroic = false },
        },
        kaelthas_sunstrider = {
            { text = "Phoenix mechanics? We had REAL phoenix problems in MC!", heroic = false },
            { text = "Fire on ground - some things NEVER change!", heroic = false },
            { text = "Flying phase? In MY day we stayed on the ground!", heroic = false },
            { text = "Interrupt the cast. Counterspell existed for a REASON!", heroic = false },
        },
    },

    --============================================================
    -- DIVA (Fabulous commentary, fashion/drama metaphors, diva energy)
    --============================================================
    diva = {
        watchkeeper_gargolmar = {
            { text = "This orc's fashion is TRAGIC. Let's end his suffering!", heroic = false },
            { text = "Healers at 50%? The AUDACITY of calling for backup!", heroic = false },
            { text = "Mortal Strike? Honey, the tank has been through WORSE!", heroic = false },
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
        the_black_stalker = {
            { text = "Chain Lightning? SPREAD out, give everyone their SPACE!", heroic = false },
            { text = "Static Charge? You're about to SERVE - away from the group!", heroic = false },
            { text = "Levitate is like being on a runway - FLOAT, baby!", heroic = false },
        },
        murmur = {
            { text = "Sonic Boom? Get CLOSE to the sound - own that stage!", heroic = false },
            { text = "Touch bomb? Time to make a DRAMATIC exit from the group!", heroic = false },
            { text = "Thundering Storm catches the distant ones - stay in the SPOTLIGHT!", heroic = false },
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

    -- Fall back to flux if no critter-specific tips
    if critterId ~= "flux" then
        critterTips = self.BOSS_TIPS.flux
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
    -- Check flux tips as default (most complete)
    local critterTips = self.BOSS_TIPS.flux
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
    -- Test Dungeon (Stockades)
    stockades = {
        { boss = "Kam Deepfury", tip = "Basic tank and spank - nothing special here!" },
        { boss = "Targorr the Dread", tip = "Enrages at low health - burn him down fast!" },
        { boss = "Hamhock", tip = "Spread out for Chain Lightning! Bloodlust makes him faster." },
        { boss = "Dextren Ward", tip = "Rend causes bleed - healers watch the tank!" },
        { boss = "Bazil Thredd", tip = "Smoke Bomb blinds melee. Battle Shout can be dispelled." },
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
