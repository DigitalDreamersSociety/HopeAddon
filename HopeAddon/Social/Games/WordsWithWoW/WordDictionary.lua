--[[
    HopeAddon Words with WoW Dictionary
    WoW-themed word list for the word game

    Categories:
    - Item names (weapons, armor, consumables)
    - Spell names
    - Zone/Location names
    - NPC/Boss names
    - Class/Race/Profession terms
    - WoW slang and terminology
    - Common English words (subset)
]]

local WordDictionary = {}

--============================================================
-- LETTER VALUES (Scrabble-style)
--============================================================

WordDictionary.LETTER_VALUES = {
    A = 1, B = 3, C = 3, D = 2, E = 1, F = 4, G = 2, H = 4, I = 1,
    J = 8, K = 5, L = 1, M = 3, N = 1, O = 1, P = 3, Q = 10, R = 1,
    S = 1, T = 1, U = 1, V = 4, W = 4, X = 8, Y = 4, Z = 10,
}

-- Letter distribution for drawing tiles
WordDictionary.LETTER_DISTRIBUTION = {
    A = 9, B = 2, C = 2, D = 4, E = 12, F = 2, G = 3, H = 2, I = 9,
    J = 1, K = 1, L = 4, M = 2, N = 6, O = 8, P = 2, Q = 1, R = 6,
    S = 4, T = 6, U = 4, V = 2, W = 2, X = 1, Y = 2, Z = 1,
}

--============================================================
-- WOW-THEMED WORD DICTIONARY
--============================================================

-- Words organized by category for maintainability
-- All words stored in UPPERCASE for consistency

WordDictionary.WORDS = {}

-- Helper to add words
local function AddWords(...)
    for _, word in ipairs({...}) do
        WordDictionary.WORDS[word:upper()] = true
    end
end

-- Classes and Specs
AddWords(
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN",
    "MAGE", "WARLOCK", "DRUID", "ARMS", "FURY", "PROT", "HOLY",
    "DISC", "SHADOW", "FROST", "FIRE", "ARCANE", "RESTO", "FERAL",
    "BALANCE", "TANK", "HEALER", "DPS", "CASTER", "MELEE"
)

-- Races
AddWords(
    "HUMAN", "DWARF", "GNOME", "ELF", "DRAENEI", "ORC", "TROLL",
    "TAUREN", "UNDEAD", "FORSAKEN", "BLOOD", "NIGHT", "HORDE",
    "ALLIANCE", "FACTION"
)

-- Professions
AddWords(
    "ALCHEMY", "BLACKSMITH", "ENCHANT", "ENGINEER", "HERB", "JEWEL",
    "LEATHER", "MINING", "SKINNING", "TAILOR", "COOK", "FISH",
    "FIRST", "AID", "POTION", "ELIXIR", "FLASK", "GEM", "ORE",
    "BAR", "INGOT", "CLOTH", "BOLT", "LEATHER", "SCALE", "HIDE"
)

-- Combat Terms
AddWords(
    "AGGRO", "THREAT", "TANK", "PULL", "WIPE", "PROC", "CRIT",
    "HIT", "MISS", "DODGE", "PARRY", "BLOCK", "RESIST", "ABSORB",
    "HEAL", "DAMAGE", "DOT", "HOT", "AOE", "CLEAVE", "STUN",
    "ROOT", "SLOW", "SILENCE", "FEAR", "CHARM", "SHEEP", "SAP",
    "BLIND", "KICK", "INTERRUPT", "DISPEL", "PURGE", "BUFF", "DEBUFF",
    "STACK", "SPAWN", "RESPAWN", "RESET", "ENRAGE", "BERSERK"
)

-- Raid/Dungeon Terms
AddWords(
    "RAID", "DUNGEON", "INSTANCE", "HEROIC", "NORMAL", "BOSS",
    "TRASH", "CLEAR", "LOOT", "ROLL", "NEED", "GREED", "PASS",
    "BIS", "GEAR", "TIER", "TOKEN", "DROP", "EPIC", "RARE",
    "LEGENDARY", "BIND", "SOULBOUND", "PICKUP", "RAID", "LOCKOUT"
)

-- TBC Zones
AddWords(
    "OUTLAND", "HELLFIRE", "ZANGAR", "MARSH", "TEROKKAR", "NAGRAND",
    "BLADE", "EDGE", "NETHERSTORM", "SHADOWMOON", "VALLEY", "SHATTRATH",
    "AREA", "TEMPEST", "KEEP", "CITADEL", "AUCHINDOUN", "COILFANG"
)

-- TBC Raids
AddWords(
    "KARAZHAN", "GRUUL", "LAIR", "MAGTHERIDON", "SERPENT", "SHRINE",
    "TEMPEST", "HYJAL", "TEMPLE", "SUNWELL", "PLATEAU"
)

-- TBC Dungeons
AddWords(
    "RAMPARTS", "FURNACE", "SHATTERED", "HALLS", "SLAVE", "PENS",
    "UNDERBOG", "STEAMVAULT", "MANA", "TOMBS", "CRYPTS", "SETHEKK",
    "SHADOW", "LABYRINTH", "MECHANAR", "BOTANICA", "ARCATRAZ",
    "MORASS", "ESCAPE", "DURNHOLDE"
)

-- Bosses (TBC)
AddWords(
    "ILLIDAN", "VASHJ", "KAEL", "THAS", "ARCHIMONDE", "AZGALOR",
    "RAGE", "WINTERCHILL", "ANETHERON", "KAZROGAL", "SUPREMUS",
    "AKAMA", "GURTOGG", "BLOODBOIL", "RELIQUARY", "SHAHRAZ",
    "COUNCIL", "PRINCE", "MALCHEZAAR", "NIGHTBANE", "NETHERSPITE",
    "CURATOR", "ARAN", "MOROES", "ATTUMEN", "MAIDEN", "OPERA"
)

-- Items/Gear
AddWords(
    "SWORD", "AXE", "MACE", "DAGGER", "STAFF", "WAND", "BOW",
    "GUN", "CROSSBOW", "POLEARM", "FIST", "SHIELD", "HELM",
    "CHEST", "LEGS", "BOOTS", "GLOVES", "BELT", "BRACERS",
    "SHOULDERS", "CLOAK", "RING", "TRINKET", "NECK", "RELIC",
    "IDOL", "TOTEM", "LIBRAM", "GLAIVE"
)

-- Famous Items
AddWords(
    "THUNDERFURY", "SULFURAS", "ATIESH", "WARGLAIVE", "AZZINOTH",
    "BLESSED", "WINDSEEKER", "HAND", "RAGNAROS", "ASHBRINGER"
)

-- Spells/Abilities (Common)
AddWords(
    "FIREBALL", "FROSTBOLT", "SHADOWBOLT", "LIGHTNING", "BOLT",
    "HEAL", "FLASH", "GREATER", "PRAYER", "MENDING", "RENEW",
    "SHIELD", "WORD", "POWER", "FORTITUDE", "SPIRIT", "INTELLECT",
    "STRENGTH", "AGILITY", "STAMINA", "ARMOR", "MARK", "WILD",
    "THORNS", "REJUVENATION", "REGROWTH", "LIFEBLOOM", "SWIFTMEND",
    "MOONFIRE", "STARFIRE", "WRATH", "HURRICANE", "BARKSKIN",
    "STEALTH", "VANISH", "SPRINT", "EVASION", "KICK", "GOUGE",
    "BACKSTAB", "SINISTER", "STRIKE", "EVISCERATE", "RUPTURE",
    "CHARGE", "EXECUTE", "MORTAL", "WHIRLWIND", "BLOODTHIRST",
    "SLAM", "OVERPOWER", "REND", "THUNDER", "CLAP", "SHOUT",
    "JUDGEMENT", "SEAL", "BLESSING", "AURA", "DEVOTION", "RETRIBUTION",
    "CONSECRATION", "EXORCISM", "HAMMER", "WRATH", "LAY", "HANDS",
    "TRAP", "SHOT", "ASPECT", "HAWK", "MONKEY", "CHEETAH", "BEAST",
    "FEIGN", "DEATH", "MEND", "PET", "TAME", "CALL", "DISMISS",
    "EARTH", "SHOCK", "FLAME", "FROST", "CHAIN", "TOTEM", "TREMOR",
    "GROUNDING", "WINDFURY", "BLOODLUST", "HEROISM", "REINCARNATION",
    "FEAR", "HOWL", "TERROR", "CURSE", "AGONY", "DOOM", "TONGUES",
    "WEAKNESS", "ELEMENTS", "SHADOW", "RECKLESSNESS", "CORRUPTION",
    "IMMOLATE", "CONFLAGRATE", "RAIN", "FIRE", "HELLFIRE", "SUMMON",
    "DEMON", "IMP", "VOIDWALKER", "SUCCUBUS", "FELHUNTER", "FELGUARD",
    "BLINK", "POLYMORPH", "COUNTERSPELL", "CONE", "COLD", "BLIZZARD",
    "ARCANE", "MISSILES", "EXPLOSION", "INTELLECT", "BRILLIANCE",
    "EVOCATION", "MANA", "SHIELD", "ICE", "BARRIER", "BLOCK"
)

-- Consumables
AddWords(
    "POTION", "ELIXIR", "FLASK", "FOOD", "DRINK", "WATER", "BREAD",
    "BANDAGE", "HEALTHSTONE", "SOULSTONE", "MANA", "HEALTH", "REJUV",
    "SUPERIOR", "MAJOR", "SUPER", "DESTRUCTION", "FORTIFICATION",
    "MIGHTY", "RAGE", "SPEED", "HASTE", "SPELL", "POWER"
)

-- Factions/Reputation
AddWords(
    "ALDOR", "SCRYER", "SHATAR", "CENARION", "EXPEDITION", "HONOR",
    "HOLD", "KURENAI", "MAGHAR", "CONSORTIUM", "SPOREGGAR", "LOWER",
    "CITY", "OGRI", "SKYGUARD", "NETHERWING", "ASHTONGUE", "DEATHSWORN",
    "SCALE", "SANDS", "VIOLET", "EYE", "EXALTED", "REVERED", "HONORED",
    "FRIENDLY", "NEUTRAL", "UNFRIENDLY", "HOSTILE", "HATED"
)

-- Creatures/Mobs
AddWords(
    "DEMON", "ELEMENTAL", "BEAST", "HUMANOID", "UNDEAD", "DRAGON",
    "DRAGONKIN", "GIANT", "MECHANICAL", "ABERRATION", "CRITTER",
    "MURLOC", "NAGA", "OGRE", "FELGUARD", "INFERNAL", "DOOMGUARD",
    "EREDAR", "PITLORD", "VOIDWALKER", "OBSERVER", "BEHOLDER",
    "NETHER", "RAY", "WARP", "STALKER", "SPOREBAT", "SPORE", "WALKER"
)

-- WoW Slang
AddWords(
    "GANK", "CAMP", "FARM", "GRIND", "LEVEL", "DING", "GRATS",
    "WTB", "WTS", "WTT", "LFG", "LFM", "LF", "PST", "INV", "SUMMON",
    "PORT", "HEARTH", "STONE", "MOUNT", "EPIC", "FLYING", "SWIFT",
    "NETHERDRAKE", "TALBUK", "ELEKK", "KODO", "RAPTOR", "WOLF",
    "AFAIK", "IMO", "BRB", "AFK", "OOM", "OOC", "IC", "TRADE", "GOLD"
)

-- Common English words that fit the game
AddWords(
    "THE", "AND", "FOR", "ARE", "BUT", "NOT", "YOU", "ALL", "CAN",
    "HAD", "HER", "WAS", "ONE", "OUR", "OUT", "DAY", "GET", "HAS",
    "HIM", "HIS", "HOW", "ITS", "MAY", "NEW", "NOW", "OLD", "SEE",
    "WAY", "WHO", "BOY", "DID", "SAY", "SHE", "TOO", "USE", "ACE",
    "ADD", "AGE", "AGO", "AID", "AIM", "AIR", "ARM", "ART", "ASK",
    "ATE", "BAD", "BAG", "BED", "BIG", "BIT", "BOX", "BUS", "BUY",
    "CAR", "CUT", "DIE", "DIG", "DOG", "DRY", "DUE", "EAR", "EAT",
    "END", "EYE", "FAR", "FAT", "FEW", "FIT", "FLY", "GOD", "GOT",
    "GUN", "GUY", "HOT", "ICE", "ILL", "JOB", "JOY", "KEY", "KID",
    "LAY", "LED", "LEG", "LET", "LIE", "LOT", "LOW", "MAN", "MAP",
    "MEN", "MET", "MIX", "MOM", "MUD", "NET", "NOR", "ODD", "OFF",
    "OIL", "OWN", "PAY", "PEN", "PET", "PIE", "PIN", "PIT", "POT",
    "PUT", "RAN", "RAT", "RAW", "RED", "RID", "RIP", "ROB", "ROD",
    "ROT", "ROW", "RUB", "RUG", "RUN", "SAD", "SAT", "SET", "SIT",
    "SIX", "SKY", "SON", "SUN", "TAX", "TEN", "TIE", "TIP", "TOP",
    "TOY", "TRY", "TWO", "VAN", "WAR", "WAS", "WET", "WIN", "WON",
    "YET", "ABLE", "ALSO", "BACK", "BEEN", "BEST", "BODY", "BOOK",
    "BOTH", "CALL", "CAME", "CITY", "COME", "DARK", "DEAD", "DEAL",
    "DEEP", "DOES", "DONE", "DOOR", "DOWN", "DRAW", "DROP", "EACH",
    "EAST", "EASY", "EDGE", "ELSE", "EVEN", "EVER", "FACE", "FACT",
    "FALL", "FAST", "FEEL", "FEET", "FELL", "FILL", "FILM", "FIND",
    "FINE", "FOOT", "FORM", "FOUR", "FREE", "FROM", "FULL", "GAME",
    "GAVE", "GIVE", "GOES", "GONE", "GOOD", "GREW", "GROW", "HAIR",
    "HALF", "HAND", "HANG", "HARD", "HAVE", "HEAD", "HEAR", "HEAT",
    "HELD", "HELP", "HERE", "HIGH", "HILL", "HOLD", "HOME", "HOPE",
    "HOUR", "HUGE", "HUNG", "IDEA", "INTO", "IRON", "JUST", "KEEP",
    "KEPT", "KIND", "KNEW", "KNOW", "LACK", "LADY", "LAND", "LAST",
    "LATE", "LEAD", "LEFT", "LESS", "LIFE", "LIKE", "LINE", "LIST",
    "LIVE", "LONG", "LOOK", "LORD", "LOSE", "LOST", "LOVE", "MADE",
    "MAIN", "MAKE", "MANY", "MARK", "MASS", "MEAN", "MEET", "MIND",
    "MORE", "MOST", "MOVE", "MUCH", "MUST", "NAME", "NEAR", "NEED",
    "NEVER", "NEWS", "NEXT", "NICE", "NONE", "NOTE", "ONCE", "ONLY",
    "OPEN", "OVER", "PAGE", "PAID", "PAIN", "PAIR", "PARK", "PART",
    "PAST", "PATH", "PICK", "PLAN", "PLAY", "PLUS", "POOR", "POST",
    "PULL", "PUSH", "RACE", "RAIN", "RATE", "READ", "REAL", "REST",
    "RICH", "RIDE", "RING", "RISE", "RISK", "ROAD", "ROCK", "ROLE",
    "ROOM", "ROSE", "RULE", "SAFE", "SAID", "SAIL", "SAKE", "SALE",
    "SAME", "SAND", "SAVE", "SEAT", "SEEK", "SEEM", "SELF", "SELL",
    "SEND", "SENT", "SHIP", "SHOP", "SHOT", "SHOW", "SHUT", "SICK",
    "SIDE", "SIGN", "SING", "SITE", "SIZE", "SKIN", "SLOW", "SNOW",
    "SOFT", "SOIL", "SOLD", "SOLE", "SOME", "SONG", "SOON", "SORT",
    "SOUL", "SPOT", "STAR", "STAY", "STEP", "STOP", "SUCH", "SURE",
    "TAIL", "TAKE", "TALK", "TALL", "TEAM", "TELL", "TEND", "TERM",
    "TEST", "TEXT", "THAN", "THAT", "THEM", "THEN", "THEY", "THIN",
    "THIS", "THUS", "TILL", "TIME", "TINY", "TOLD", "TONE", "TOOK",
    "TOOL", "TOUR", "TOWN", "TREE", "TRIP", "TRUE", "TURN", "TYPE",
    "UNIT", "UPON", "USED", "USER", "VARY", "VAST", "VERY", "VIEW",
    "VOTE", "WAIT", "WAKE", "WALK", "WALL", "WANT", "WARM", "WASH",
    "WAVE", "WEAK", "WEAR", "WEEK", "WELL", "WENT", "WERE", "WEST",
    "WHAT", "WHEN", "WIDE", "WIFE", "WILD", "WILL", "WIND", "WINE",
    "WING", "WIRE", "WISE", "WISH", "WITH", "WOOD", "WORD", "WORE",
    "WORK", "YARD", "YEAH", "YEAR", "YOUR", "ZERO", "ZONE"
)

--============================================================
-- API FUNCTIONS
--============================================================

--[[
    Check if a word is valid
    @param word string
    @return boolean
]]
function WordDictionary:IsValidWord(word)
    if not word or word == "" then return false end
    return self.WORDS[word:upper()] == true
end

--[[
    Get the point value of a word
    @param word string
    @return number
]]
function WordDictionary:GetWordValue(word)
    if not word then return 0 end

    local total = 0
    for i = 1, #word do
        local letter = word:sub(i, i):upper()
        total = total + (self.LETTER_VALUES[letter] or 0)
    end
    return total
end

--[[
    Get point value of a single letter
    @param letter string
    @return number
]]
function WordDictionary:GetLetterValue(letter)
    if not letter then return 0 end
    return self.LETTER_VALUES[letter:upper()] or 0
end

--[[
    Generate a bag of letter tiles
    @return table - Array of letters
]]
function WordDictionary:GenerateTileBag()
    local bag = {}

    for letter, count in pairs(self.LETTER_DISTRIBUTION) do
        for i = 1, count do
            table.insert(bag, letter)
        end
    end

    -- Shuffle
    for i = #bag, 2, -1 do
        local j = math.random(i)
        bag[i], bag[j] = bag[j], bag[i]
    end

    return bag
end

--[[
    Get word count in dictionary
    @return number
]]
function WordDictionary:GetWordCount()
    local count = 0
    for _ in pairs(self.WORDS) do
        count = count + 1
    end
    return count
end

--[[
    Search for words starting with prefix
    @param prefix string
    @param limit number
    @return table - Array of matching words
]]
function WordDictionary:SearchWords(prefix, limit)
    prefix = prefix:upper()
    limit = limit or 10
    local results = {}

    for word in pairs(self.WORDS) do
        if word:sub(1, #prefix) == prefix then
            table.insert(results, word)
            if #results >= limit then
                break
            end
        end
    end

    return results
end

-- Export
HopeAddon.WordDictionary = WordDictionary

HopeAddon:Debug("WordDictionary loaded with", WordDictionary:GetWordCount(), "words")
