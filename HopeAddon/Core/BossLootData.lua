HopeAddon = HopeAddon or {}
HopeAddon.Constants = HopeAddon.Constants or {}
local C = HopeAddon.Constants

--[[
    Boss Loot Item ID Database

    Comprehensive loot tables for all TBC raid bosses.
    Item IDs only - display properties (name, icon, quality, type) derived
    from GetItemInfo() at runtime.

    Structure: C.BOSS_LOOT_IDS = { ["Boss Name"] = { itemId1, itemId2, ... } }
    Boss names must exactly match the "name" field in Constants.lua boss definitions.

    Adding a boss: just add ["Boss Name"] = { id1, id2, ... }
    WoW handles all display info automatically via GetItemInfo().
]]

C.BOSS_LOOT_IDS = {

    --============================================================
    -- KARAZHAN (Phase 1) - 11 bosses
    --============================================================

    ["Attumen the Huntsman"] = {
        30480, -- Fiery Warhorse's Reins (mount)
        28510, -- Spectral Band of Innervation
        28509, -- Worgen Claw Necklace
        28508, -- Gloves of Saintly Blessings
        28507, -- Handwraps of Flowing Thought
        28477, -- Harbinger Bands
        28506, -- Gloves of Dexterous Manipulation
        28453, -- Bracers of the White Stag
        28503, -- Whirlwind Bracers
        28454, -- Stalker's War Bands
        28505, -- Gauntlets of Renewed Hope
        28502, -- Vambraces of Courage
        28504, -- Steelhawk Crossbow
        23809, -- Schematic: Stabilized Eternium Scope
    },

    ["Moroes"] = {
        28529, -- Royal Cloak of Arathi Kings
        28570, -- Shadow-Cloak of Dalaran
        28565, -- Nethershard Girdle
        28545, -- Edgewalker Longboots
        28528, -- Moroes' Lucky Pocket Watch
        28525, -- Signet of Unshakable Faith
        28530, -- Brooch of Unquenchable Fury
        28524, -- Emerald Ripper
        28567, -- Belt of Gale Force
        28566, -- Crimson Girdle of the Indomitable
        28569, -- Boots of Valiance
        28568, -- Idol of the Avian Heart
        22559, -- Formula: Enchant Weapon - Mongoose
    },

    ["Maiden of Virtue"] = {
        28511, -- Bands of Indwelling
        28515, -- Bands of Nefarious Deeds
        28517, -- Boots of Foretelling
        28514, -- Bracers of Maliciousness
        28521, -- Mitts of the Treemender
        28520, -- Gloves of Centering
        28519, -- Gloves of Quickening
        28518, -- Iron Gauntlets of the Maiden
        28516, -- Barbed Choker of Discipline
        28512, -- Bracers of Justice
        28522, -- Shard of the Virtuous
        28523, -- Totem of Healing Rains
    },

    ["Opera Event"] = {
        28578, -- Masquerade Gown
        28579, -- Romulo's Poison Vial
        28572, -- Blade of the Unrequited
        28573, -- Despair
        28587, -- Legacy
        28588, -- Blue Diamond Witchband
        28589, -- Beastmaw Pauldrons
        28590, -- Ribbon of Sacrifice
        28583, -- Big Bad Wolf's Head
        28584, -- Big Bad Wolf's Paw
        28585, -- Ruby Slippers
        28586, -- Wicked Witch's Hat
        28581, -- Wolfslayer Sniper Rifle
        28591, -- Earthsoul Leggings
        28592, -- Pants of the Naaru
        28593, -- Eternium Greathelm
        28594, -- Trial-Fire Trousers
        28596, -- Libram of Zeal
    },

    ["The Curator"] = {
        28612, -- Pauldrons of the Solace-Giver
        28647, -- Forest Wind Shoulderpads
        28631, -- Dragon-Quake Shoulderguards
        28621, -- Wrynn Dynasty Greaves
        28649, -- Garona's Signet Ring
        28633, -- Staff of Infinite Mysteries
        29757, -- Gloves of the Fallen Champion (T4 token)
        29758, -- Gloves of the Fallen Defender (T4 token)
        29756, -- Gloves of the Fallen Hero (T4 token)
    },

    ["Shade of Aran"] = {
        28672, -- Drape of the Dark Reavers
        28726, -- Mantle of the Mind Flayer
        28670, -- Boots of the Infernal Coven
        28663, -- Boots of the Incorrupt
        28669, -- Rapscallion Boots
        28666, -- Pauldrons of the Justice-Seeker
        28674, -- Saberclaw Talisman
        28675, -- Shermanar Great-Ring
        28671, -- Steelspine Faceguard
        28673, -- Tirisfal Wand of Ascendancy
        28727, -- Pendant of the Violet Eye
        22560, -- Formula: Enchant Weapon - Sunfire
    },

    ["Terestian Illhoof"] = {
        28652, -- Cincture of Will
        28653, -- Shadowvine Cloak of Infusion
        28660, -- Gilded Thorium Cloak
        28654, -- Malefic Girdle
        28658, -- Terestian's Stranglestaff
        28655, -- Cord of Nature's Sustenance
        28656, -- Girdle of the Prowler
        28657, -- Fool's Bane
        28661, -- Mender's Heart-Ring
        28662, -- Breastplate of the Lightbinder
        28659, -- Xavian Stiletto
        28785, -- The Lightning Capacitor
        22561, -- Formula: Enchant Weapon - Soulfrost
    },

    ["Netherspite"] = {
        28744, -- Uni-Mind Headdress
        28742, -- Pantaloons of Repentance
        28735, -- Earthblood Chestguard
        28740, -- Rip-Flayer Leggings
        28743, -- Mantle of Abrahmis
        28732, -- Cowl of Defiance
        28741, -- Skulker's Greaves
        28731, -- Shining Chain of the Afterworld
        28733, -- Girdle of Truth
        28734, -- Jewel of Infinite Possibilities
        28729, -- Spiteblade
        28730, -- Mithril Band of the Unscarred
    },

    ["Chess Event"] = {
        28756, -- Headdress of the High Potentate
        28755, -- Bladed Shoulderpads of the Merciless
        28750, -- Girdle of Treachery
        28752, -- Forestlord Striders
        28751, -- Heart-Flame Leggings
        28748, -- Legplates of the Innocent
        28746, -- Fiend Slayer Boots
        28747, -- Battlescar Boots
        28749, -- King's Defender
        28745, -- Mithril Chain of Heroism
        28753, -- Ring of Recurrence
        28754, -- Triptych Shield of the Ancients
    },

    ["Prince Malchezaar"] = {
        28773, -- Gorehowl
        28770, -- Nathrezim Mindblade
        28771, -- Light's Justice
        28772, -- Sunfury Bow of the Phoenix
        28762, -- Adornment of Stolen Souls
        28763, -- Jade Ring of the Everliving
        28764, -- Farstrider Wildercloak
        28766, -- Stainless Cloak of the Pure Hearted
        28765, -- Skulker's Greaves
        28768, -- Malchazeen
        28767, -- The Decapitator
        29760, -- Helm of the Fallen Champion (T4 token)
        29761, -- Helm of the Fallen Defender (T4 token)
        29759, -- Helm of the Fallen Hero (T4 token)
    },

    ["Nightbane"] = {
        28602, -- Robe of the Elder Scribes
        28600, -- Stonebough Jerkin
        28601, -- Chestguard of the Conniver
        28599, -- Scaled Breastplate of Carnage
        28608, -- Ironstriders of Urgency
        28597, -- Panzar'Thar Breastplate
        28610, -- Ferocious Swift-Kickers
        28606, -- Shield of Impenetrable Darkness
        28603, -- Talisman of Nightbane
        28604, -- Nightstaff of the Everliving
        28611, -- Dragonheart Flameshield
        28609, -- Emberspur Talisman
    },

    --============================================================
    -- GRUUL'S LAIR (Phase 1) - 2 bosses
    --============================================================

    ["High King Maulgar"] = {
        29763, -- Pauldrons of the Fallen Champion (T4 token)
        29764, -- Pauldrons of the Fallen Defender (T4 token)
        29762, -- Pauldrons of the Fallen Hero (T4 token)
        28797, -- Brute Cloak of the Ogre-Magi
        28799, -- Belt of Divine Inspiration
        28796, -- Malefic Mask of the Shadows
        28801, -- Maulgar's Warhelm
        28795, -- Bladespire Warbands
        28800, -- Hammer of the Naaru
    },

    ["Gruul the Dragonkiller"] = {
        29766, -- Leggings of the Fallen Champion (T4 token)
        29767, -- Leggings of the Fallen Defender (T4 token)
        29765, -- Leggings of the Fallen Hero (T4 token)
        28830, -- Dragonspine Trophy
        28823, -- Eye of Gruul
        28822, -- Teeth of Gruul
        28824, -- Gauntlets of Martial Perfection
        28827, -- Gauntlets of the Dragonslayer
        28810, -- Windshear Boots
        28825, -- Aldori Legacy Defender
        28826, -- Shuriken of Negation
        28828, -- Gronn-Stitched Girdle
        28804, -- Collar of Cho'gall
        28803, -- Cowl of Nature's Breath
    },

    --============================================================
    -- MAGTHERIDON'S LAIR (Phase 1) - 1 boss
    --============================================================

    ["Magtheridon"] = {
        29754, -- Chestguard of the Fallen Champion (T4 token)
        29753, -- Chestguard of the Fallen Defender (T4 token)
        29755, -- Chestguard of the Fallen Hero (T4 token)
        32385, -- Magtheridon's Head (quest)
        28789, -- Eye of Magtheridon
        28783, -- Eredar Wand of Obliteration
        28778, -- Terror Pit Girdle
        28775, -- Thundering Greathelm
        28779, -- Girdle of the Endless Pit
        28780, -- Soul-Eater's Handwraps
        28777, -- Cloak of the Pit Stalker
        28774, -- Glaive of the Pit
        28776, -- Liar's Tongue Gloves
        28781, -- Karaborian Talisman
        28782, -- Crystalheart Pulse-Staff
    },

    --============================================================
    -- SERPENTSHRINE CAVERN (Phase 2) - 6 bosses
    --============================================================

    ["Hydross the Unstable"] = {
        30056, -- Robe of Hateful Echoes
        30050, -- Boots of the Shifting Nightmare
        30055, -- Shoulderpads of the Stranger
        30047, -- Blackfathom Warbands
        30054, -- Ranger-General's Chestguard
        30048, -- Brighthelm of Justice
        30052, -- Ring of Lethality
        30664, -- Living Root of the Wildheart
        30629, -- Scarab of Displacement
        30049, -- Fathomstone
        30051, -- Band of Vile Aggression
        30053, -- Pauldrons of the Wardancer
    },

    ["The Lurker Below"] = {
        30058, -- Mallet of the Tides
        30059, -- Choker of Animalistic Fury
        30060, -- Boots of Effortless Striking
        30061, -- Ancestral Ring of Conquest
        30062, -- Grove-Bands of Remulos
        30063, -- Libram of Absolute Truth
        30064, -- Cord of Screaming Terrors
        30065, -- Glowing Breastplate of Truth
        30066, -- Tempest-Strider Boots
        30067, -- Velvet Boots of the Guardian
        30665, -- Earring of Soulful Meditation
        33054, -- The Seal of Danzalar
    },

    ["Morogrim Tidewalker"] = {
        30008, -- Pendant of the Lost Ages
        30068, -- Girdle of the Tidal Call
        30075, -- Gnarled Chestpiece of the Ancients
        30079, -- Illidari Shoulderpads
        30080, -- Luminescent Rod of the Naaru
        30081, -- Warboots of Obliteration
        30082, -- Talon of Azshara
        30083, -- Ring of Sundered Souls
        30084, -- Pauldrons of the Argent Sentinel
        30085, -- Mantle of the Tireless Tracker
        30098, -- Razor-Scale Battlecloak
        30720, -- Serpent-Coil Braid
        33058, -- Band of the Vigilant
    },

    ["Fathom-Lord Karathress"] = {
        30245, -- Leggings of the Vanquished Champion (T5 token)
        30246, -- Leggings of the Vanquished Defender (T5 token)
        30247, -- Leggings of the Vanquished Hero (T5 token)
        30090, -- World Breaker
        30099, -- Frayed Tether of the Drowned
        30100, -- Soul-Strider Boots
        30101, -- Bloodsea Brigand's Vest
        30626, -- Sextant of Unstable Currents
        30663, -- Fathom-Brooch of the Tidewalker
    },

    ["Leotheras the Blind"] = {
        30091, -- True-Aim Stalker Bands
        30092, -- Orca-Hide Boots
        30095, -- Fang of the Leviathan
        30096, -- Girdle of the Invulnerable
        30097, -- Coral-Barbed Shoulderpads
        30239, -- Gloves of the Vanquished Champion (T5 token)
        30240, -- Gloves of the Vanquished Defender (T5 token)
        30241, -- Gloves of the Vanquished Hero (T5 token)
        30627, -- Tsunami Talisman
    },

    ["Lady Vashj"] = {
        30107, -- Vestments of the Sea-Witch
        30111, -- Runetotem's Mantle
        30106, -- Belt of One Hundred Deaths
        30112, -- Glorious Gauntlets of Crestfall
        30108, -- Lightfathom Scepter
        30110, -- Coral Band of the Revived
        30109, -- Ring of Endless Coils
        30621, -- Prism of Inner Calm
        30105, -- Serpent Spine Longbow
        29906, -- Vashj's Vial Remnant (quest)
        31338, -- Charlotte's Ivy
    },

    --============================================================
    -- TEMPEST KEEP: THE EYE (Phase 2) - 4 bosses
    --============================================================

    ["Al'ar"] = {
        29921, -- Fire Crest Breastplate
        29922, -- Band of Al'ar
        29925, -- Phoenix-Wing Cloak
        29918, -- Mindstorm Wristbands
        29947, -- Gloves of the Searing Grip
        29924, -- Netherbane
        29920, -- Phoenix-Ring of Rebirth
        29923, -- Talisman of the Sun King
        29949, -- Arcanite Steam-Pistol
        29919, -- Eagle-Crested Wargrips
        32944, -- Talon of the Phoenix
    },

    ["Void Reaver"] = {
        29986, -- Cowl of the Grand Engineer
        29984, -- Girdle of Zaetar
        29985, -- Void Reaver Greaves
        29983, -- Fel-Steel Warhelm
        32515, -- Wristguards of Determination
        30619, -- Fel Reaver's Piston
        30450, -- Warp-Spring Coil
        30248, -- Pauldrons of the Vanquished Champion (T5 token)
        30249, -- Pauldrons of the Vanquished Defender (T5 token)
        30250, -- Pauldrons of the Vanquished Hero (T5 token)
    },

    ["High Astromancer Solarian"] = {
        29950, -- Greaves of the Bloodwarder
        29951, -- Star-Strider Boots
        29962, -- Heartrazor
        29965, -- Girdle of the Righteous Path
        29966, -- Vambraces of Ending
        29972, -- Trousers of the Astromancer
        29976, -- Worldstorm Gauntlets
        29977, -- Star-Soul Breeches
        29981, -- Ethereum Life-Staff
        29982, -- Wand of the Forgotten Star
        30446, -- Solarian's Sapphire
        30449, -- Void Star Talisman
    },

    ["Kael'thas Sunstrider"] = {
        32458, -- Ashes of Al'ar (mount)
        30236, -- Chestguard of the Vanquished Champion (T5 token)
        30237, -- Chestguard of the Vanquished Defender (T5 token)
        30238, -- Chestguard of the Vanquished Hero (T5 token)
        29987, -- Gauntlets of the Sun King
        29988, -- The Nexus Key
        29990, -- Crown of the Sun
        29991, -- Sunhawk Leggings
        29993, -- Twinblade of the Phoenix
        29994, -- Thalassian Wildercloak
        29995, -- Leggings of Murderous Intent
        29996, -- Rod of the Sun King
        29997, -- Band of the Ranger-General
        29998, -- Royal Gauntlets of Silvermoon
        30316, -- Devastation
        32405, -- Verdant Sphere (quest)
    },

    --============================================================
    -- BATTLE FOR MOUNT HYJAL (Phase 3) - 5 bosses
    --============================================================

    ["Rage Winterchill"] = {
        30862, -- Blessed Adamantite Bracers
        30863, -- Deadly Cuffs
        30864, -- Bracers of the Pathfinder
        30865, -- Tracker's Blade
        30866, -- Blood-Stained Pauldrons
        30868, -- Rejuvenating Bracers
        30869, -- Howling Wind Bracers
        30870, -- Cuffs of Devastation
        30871, -- Bracers of Martyrdom
        30872, -- Chronicle of Dark Secrets
        30873, -- Stillwater Boots
    },

    ["Anetheron"] = {
        30874, -- The Unbreakable Will
        30878, -- Glimmering Steel Mantle
        30879, -- Don Alejandro's Money Belt
        30880, -- Quickstrider Moccasins
        30881, -- Blade of Infamy
        30882, -- Bastion of Light
        30883, -- Pillar of Ferocity
        30884, -- Hatefury Mantle
        30885, -- Archbishop's Slippers
        30886, -- Enchanted Leather Sandals
        30887, -- Golden Links of Restoration
        30888, -- Anetheron's Noose
    },

    ["Kaz'rogal"] = {
        30889, -- Kaz'rogal's Hardened Heart
        30891, -- Black Featherlight Boots
        30892, -- Beast-Tamer's Shoulders
        30893, -- Sun-Touched Chain Leggings
        30894, -- Blue Suede Shoes
        30895, -- Angelista's Sash
        30914, -- Belt of the Crescent Moon
        30915, -- Belt of Seething Fury
        30916, -- Leggings of Channeled Elements
        30917, -- Razorfury Mantle
        30918, -- Hammer of Atonement
        30919, -- Valestalker Girdle
    },

    ["Azgalor"] = {
        30896, -- Glory of the Defender
        30897, -- Girdle of Hope
        30898, -- Shady Dealer's Pantaloons
        30899, -- Don Rodrigo's Poncho
        30900, -- Bow-Stitched Leggings
        30901, -- Boundless Agony
    },

    ["Archimonde"] = {
        30902, -- Cataclysm's Edge
        30903, -- Legguards of Endless Rage
        30904, -- Savior's Grasp
        30905, -- Midnight Chestguard
        30906, -- Bristleblitz Striker
        30907, -- Mail of Fevered Pursuit
        30908, -- Apostle of Argus
        30909, -- Antonidas's Aegis of Rapt Concentration
        30910, -- Tempest of Chaos
        30911, -- Scepter of Purification
        30912, -- Leggings of Eternity
        30913, -- Robes of Rhonin
        31095, -- Helm of the Forgotten Protector (T6 token)
        31096, -- Helm of the Forgotten Vanquisher (T6 token)
        31097, -- Helm of the Forgotten Conqueror (T6 token)
    },

    --============================================================
    -- BLACK TEMPLE (Phase 3) - 9 bosses
    --============================================================

    ["High Warlord Naj'entus"] = {
        32239, -- The Maelstrom's Fury
        32232, -- Wraps of Precise Flight
        32234, -- Fists of Mukoa
        32238, -- Ring of Captured Storms
        32237, -- Ring of Calming Waves
        32240, -- Boots of Oceanic Fury
        32241, -- Helm of Soothing Currents
        32236, -- Rising Tide
        32233, -- Guise of the Tidal Lurker
        32248, -- Halberd of Desolation
    },

    ["Supremus"] = {
        32256, -- Waistwrap of Infinity
        32252, -- Nether Shadow Tunic
        32259, -- Bands of the Coming Storm
        32260, -- Syphon of the Nathrezim
        32251, -- Pauldrons of Abyssal Fury
        32258, -- Choker of Endless Nightmares
        32253, -- Naturalist's Preserving Cinch
        32254, -- The Brutalizer
        32255, -- Felstone Bulwark
        32257, -- Idol of the White Stag
    },

    ["Shade of Akama"] = {
        32273, -- Amice of Brilliant Light
        32270, -- Focused Mana Bindings
        32513, -- Wristbands of Divine Influence
        32265, -- Shadow-Walker's Cord
        32271, -- Kilt of Immortal Nature
        32264, -- Spiritwalker Gauntlets
        32275, -- Ring of Deceitful Intent
        32276, -- Flashfire Girdle
        32266, -- The Seeker's Wristguards
        32267, -- Praetorian's Legguards
    },

    ["Teron Gorefiend"] = {
        32323, -- Shadowmoon Destroyer's Drape
        32327, -- Robe of the Shadow Council
        32280, -- Gauntlets of Enforcement
        32510, -- Softstep Boots of Tracking
        32328, -- Botanist's Gloves of Growth
        32512, -- Girdle of Lordaeron's Fallen
        32324, -- Insidious Bands
        32279, -- Soul Cleaver
        32326, -- Twisted Blades of Zarak
        32325, -- Rifle of the Stoic Guardian
    },

    ["Gurtogg Bloodboil"] = {
        32337, -- Shroud of Forgiveness
        32338, -- Blood-Cursed Shoulderpads
        32339, -- Belt of Primal Majesty
        32335, -- Unstoppable Aggressor's Ring
        32334, -- Vest of Mounting Assault
        32333, -- Girdle of Stability
        32340, -- Garments of Temperance
        32341, -- Leggings of Divine Retribution
        32342, -- Girdle of Mighty Resolve
        32343, -- Wand of Prismatic Focus
        32344, -- Staff of Immaculate Recovery
        32501, -- Shadowmoon Insignia
    },

    ["Reliquary of Souls"] = {
        32332, -- Torch of the Damned
        32345, -- Dreadboots of the Legion
        32346, -- Boneweave Girdle
        32347, -- Grips of Damnation
        32349, -- Translucent Spellthread Necklace
        32350, -- Touch of Inspiration
        32351, -- Elunite Empowered Bracers
        32352, -- Naturewarden's Treads
        32353, -- Gloves of Unfailing Faith
        32354, -- Crown of Empowered Fate
        32362, -- Pendant of Titans
        32363, -- Naaru-Blessed Life Rod
        32517, -- The Wavemender's Mantle
    },

    ["Mother Shahraz"] = {
        32367, -- Leggings of Devastation
        32366, -- Shadowmaster's Boots
        32370, -- Nadina's Pendant of Purity
        32365, -- Heartshatter Breastplate
        32368, -- Tome of the Lightbringer
        32369, -- Blade of Savagery
        31101, -- Pauldrons of the Forgotten Conqueror (T6 token)
        31102, -- Pauldrons of the Forgotten Vanquisher (T6 token)
        31103, -- Pauldrons of the Forgotten Protector (T6 token)
    },

    ["The Illidari Council"] = {
        32331, -- Cloak of the Illidari Council
        32373, -- Helm of the Illidari Shatterer
        32376, -- Forest Prowler's Helm
        32505, -- Madness of the Betrayer
        32518, -- Veil of Turning Leaves
        32519, -- Belt of Divine Guidance
        31098, -- Leggings of the Forgotten Conqueror (T6 token)
        31099, -- Leggings of the Forgotten Vanquisher (T6 token)
        31100, -- Leggings of the Forgotten Protector (T6 token)
    },

    ["Illidan Stormrage"] = {
        32837, -- Warglaive of Azzinoth (main hand)
        32838, -- Warglaive of Azzinoth (off hand)
        32471, -- Shard of Azzinoth
        32500, -- Crystal Spire of Karabor
        31089, -- Chestguard of the Forgotten Conqueror (T6 token)
        31090, -- Chestguard of the Forgotten Vanquisher (T6 token)
        31091, -- Chestguard of the Forgotten Protector (T6 token)
        32524, -- Shroud of the Highborne
        32525, -- Cowl of the Illidari High Lord
        32235, -- Cursed Vision of Sargeras
        32497, -- Stormrage Signet Ring
        32336, -- Black Bow of the Betrayer
        32483, -- The Skull of Gul'dan
        32521, -- Faceplate of the Impenetrable
        32496, -- Memento of Tyrande
    },

    --============================================================
    -- ZUL'AMAN (Phase 4) - 6 bosses
    --============================================================

    ["Nalorakk"] = {
        33191, -- Jungle Stompers
        33203, -- Robes of Heavenly Purpose
        33206, -- Pauldrons of Primal Fury
        33211, -- Bladeangel's Money Belt
        33285, -- Fury of the Ursine
        33327, -- Mask of Introspection
        33640, -- Fury
    },

    ["Akil'zon"] = {
        33214, -- Akil'zon's Talonblade
        33215, -- Bloodstained Elven Battlevest
        33216, -- Chestguard of Hidden Purpose
        33281, -- Brooch of Nature's Mercy
        33283, -- Amani Punisher
        33286, -- Mojo-mender's Mask
        33293, -- Signet of Ancient Magics
    },

    ["Jan'alai"] = {
        33326, -- Bulwark of the Amani Empire
        33328, -- Arrow-fall Chestguard
        33329, -- Shadowtooth Trollskin Cuirass
        33332, -- Enamelled Disc of Mojo
        33354, -- Wub's Cursed Hexblade
        33356, -- Helm of Natural Regeneration
        33357, -- Footpads of Madness
    },

    ["Halazzi"] = {
        33297, -- The Savage's Choker
        33299, -- Spaulders of the Advocate
        33300, -- Shoulderpads of Dancing Blades
        33303, -- Skullshatter Warboots
        33317, -- Robe of Departed Spirits
        33322, -- Shimmer-pelt Vest
        33533, -- Avalanche Leggings
    },

    ["Hex Lord Malacrass"] = {
        33298, -- Prowler's Strikeblade
        33388, -- Heartless
        33389, -- Dagger of Bad Mojo
        33421, -- Battleworn Tuskguard
        33432, -- Coif of the Jungle Stalker
        33446, -- Girdle of Stromgarde's Hope
        33453, -- Hood of Hexing
        33463, -- Hood of the Third Eye
        33464, -- Hex Lord's Voodoo Pauldrons
        33465, -- Staff of Primal Fury
        33592, -- Cloak of Ancient Rituals
        33828, -- Tome of Diabolic Remedy
        33829, -- Hex Shrunken Head
        34029, -- Tiny Voodoo Mask
    },

    ["Zul'jin"] = {
        33466, -- Loop of Cursed Bones
        33467, -- Blade of Twisted Visions
        33468, -- Dark Blessing
        33469, -- Hauberk of the Empire's Champion
        33471, -- Two-toed Sandals
        33473, -- Chestguard of the Warlord
        33474, -- Ancient Amani Longbow
        33476, -- Cleaver of the Unforgiving
        33478, -- Jin'rohk, The Great Apocalypse
        33479, -- Grimgrin Faceguard
        33830, -- Ancient Aqir Artifact
        33831, -- Berserker's Call
    },

    --============================================================
    -- SUNWELL PLATEAU (Phase 5) - 6 bosses
    --============================================================

    ["Kalecgos"] = {
        34164, -- Dragonscale-Encrusted Longblade
        34165, -- Fang of Kalecgos
        34166, -- Band of Lucent Beams
        34167, -- Legplates of the Holy Juggernaut
        34168, -- Starstalker Legguards
        34169, -- Breeches of Natural Aggression
        34170, -- Pantaloons of Calming Strife
        34848, -- Bracers of the Forgotten Conqueror (T6 token)
        34851, -- Bracers of the Forgotten Protector (T6 token)
        34852, -- Bracers of the Forgotten Vanquisher (T6 token)
    },

    ["Brutallus"] = {
        34176, -- Reign of Misery
        34177, -- Clutch of Demise
        34178, -- Collar of the Pit Lord
        34179, -- Heart of the Pit
        34180, -- Felfury Legplates
        34181, -- Leggings of Calamity
        34853, -- Belt of the Forgotten Conqueror (T6 token)
        34854, -- Belt of the Forgotten Protector (T6 token)
        34855, -- Belt of the Forgotten Vanquisher (T6 token)
    },

    ["Felmyst"] = {
        34182, -- Grand Magister's Staff of Torrents
        34184, -- Brooch of the Highborne
        34185, -- Sword Breaker's Bulwark
        34186, -- Chain Links of the Tumultuous Storm
        34188, -- Leggings of the Immortal Night
        34352, -- Borderland Fortress Grips
        34856, -- Boots of the Forgotten Conqueror (T6 token)
        34857, -- Boots of the Forgotten Protector (T6 token)
        34858, -- Boots of the Forgotten Vanquisher (T6 token)
    },

    ["Eredar Twins"] = {
        34189, -- Band of Ruinous Delight
        34190, -- Crimson Paragon's Cover
        34197, -- Shiv of Exsanguination
        34199, -- Archon's Gavel
        34202, -- Shawl of Wonderment
        34203, -- Grip of Mannoroth
        34204, -- Amulet of Unfettered Magics
        34205, -- Shroud of Redeemed Souls
        34206, -- Book of Highborne Hymns
        34208, -- Equilibrium Epaulets
        34209, -- Spaulders of Reclamation
        34210, -- Amice of the Convoker
    },

    ["M'uru"] = {
        34211, -- Harness of Carnal Instinct
        34212, -- Sunglow Vest
        34213, -- Ring of Hardened Resolve
        34214, -- Muramasa
        34215, -- Warharness of Reckless Fury
        34216, -- Heroic Judicator's Chestguard
        34228, -- Vicious Hawkstrider Hauberk
        34229, -- Garments of Serene Shores
        34230, -- Ring of Omnipotence
        34231, -- Aegis of Angelic Fortune
        34234, -- Shadowed Gauntlets of Paroxysm
        34240, -- Gauntlets of the Soothed Soul
    },

    ["Kil'jaeden"] = {
        34247, -- Apolyon, the Soul-Render
        34329, -- Crux of the Apocalypse
        34331, -- Hand of the Deceiver
        34332, -- Cowl of Gul'dan
        34333, -- Coif of Alleria
        34334, -- Thori'dal, the Stars' Fury (legendary)
        34335, -- Hammer of Sanctification
        34336, -- Sunflare
        34337, -- Golden Staff of the Sin'dorei
        34339, -- Cowl of Light's Purity
        34340, -- Dark Conjuror's Collar
        34341, -- Borderland Paingrips
        34342, -- Handguards of the Dawn
        34343, -- Thalassian Ranger Gauntlets
        34344, -- Handguards of Defiled Worlds
        34345, -- Crown of Anasterian
    },
}

--[[
    Warm up item cache for boss loot items.
    Pre-calls GetItemInfo() for all items so they're cached when user opens popup.
    Called when Raids tab is first populated.
]]
function C:WarmBossLootCache()
    if not C.BOSS_LOOT_IDS then return end
    for _, itemIds in pairs(C.BOSS_LOOT_IDS) do
        for _, itemId in ipairs(itemIds) do
            GetItemInfo(itemId)
        end
    end
end
