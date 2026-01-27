--[[
    HopeAddon Wordle - Word Dictionary
    WoW-themed 5-letter words for the Wordle game
]]

local WordleWords = {}

--============================================================
-- 5-LETTER WOW WORDS DICTIONARY
-- All words must be exactly 5 letters
--============================================================

WordleWords.VALID_WORDS = {
    -- Classes
    "ROGUE", "DRUID", "MAGES",

    -- Races
    "GNOME", "DWARF", "TROLL", "BLOOD", "NIGHT", "ELVES", "HUMAN", "TAURE",

    -- Creatures/Enemies
    "DEMON", "GHOUL", "DRAKE", "WHELP", "BEAST", "GNOLL", "SPAWN", "WYRMS",
    "IMPS", "NAGA", "SATYR", "ORGE", "WORGS", "CROWS", "BATS",
    "GIANT", "GOLEM", "HYDRA", "HOUND", "VIPER", "COBRA", "CRABS",
    "TIGER", "LIONS", "BEARS", "BOARS", "OWLS", "HAWKS", "RAVEN",
    "SHARK", "SQUID", "WHALE", "CROCS", "GATOR", "SPORE", "SLIME",
    "SHADE", "WRAITH", "SPECTER", "UNDEAD",

    -- Equipment/Items
    "MOUNT", "ARMOR", "SWORD", "STAFF", "WANDS", "CAPES", "CLOAK",
    "RINGS", "CLOTH", "PLATE", "CHAIN", "ROBES", "HELMS", "BOOTS",
    "GLOVE", "BELTS", "CHEST", "PANTS", "HEADS", "BACKS", "NECKS",
    "AXELS", "BOWS", "MACES", "DAGGERS",
    "POUCH", "FLASK", "FOODS", "DRINK", "ELIXS",
    "TORCH", "TOOLS", "PICKS", "BOMBS", "WANDS",

    -- Guild/Social
    "GUILD", "PARTY", "GROUP", "RAIDS", "REALM", "SHARD", "WORLD",
    "HORDE", "ALLIS", "TEAMS", "SQUAD", "CLANS",

    -- Gameplay/Actions
    "AGGRO", "WIPES", "PULLS", "HEALS", "TANKS", "CASTS", "BUFFS",
    "PROCS", "CRITS", "DODGE", "BLOCK", "PARRY", "STUNS", "ROOTS",
    "FEARS", "CHARMS", "SLEEPS",
    "LOOT", "ROLLS", "GREED", "NEEDS", "NINJA", "TRADE",
    "QUEST", "SPELLS", "SKILL", "LEVEL", "GRIND", "FARMS",
    "DUELS", "ARENA", "KILLS", "DEATH", "SPAWN", "RESET",

    -- Magic/Elements
    "FROST", "FIRES", "LIGHT", "ARCANE", "CHAOS", "HOLY", "SHADOW",
    "STORM", "SHOCK", "BLAZE", "FLAME", "CHILL", "WINDS",
    "EARTH", "WATER", "NATRE",

    -- Zones/Places (abbreviated or 5-letter)
    "MARSH", "HILLS", "WOODS", "PEAKS", "WILDS", "FORGE",
    "TOWER", "KEEPS", "GATES", "WALLS", "RUINS", "CAVES",
    "MINES", "TOMBS", "ALTAR", "NEXUS",
    "DUNES", "OASIS", "COAST", "PORTS", "DOCKS", "SHIPS",

    -- Professions/Skills
    "MINER", "SMITH", "HERBS", "SKINS", "JEWEL", "COOKS",
    "CRAFT", "FORGE", "TAILR",

    -- Combat Terms
    "MELEE", "RANGE", "MAGIC", "TANKS", "DPSRS",
    "TRASH", "BOSSS", "PHASE", "ADDON", "MACRO",
    "COMBO", "BURST", "PURGE", "CURSE", "DISPEL",

    -- Quality/Rarity
    "EPICS", "BLUES", "GREEN", "GRAYS", "PURPS", "GOLDS",
    "RARES", "COMMON",

    -- Emotes/Social
    "CHEER", "DANCE", "SALUT", "WAVES", "BOWS", "LAUGH",
    "CRIES", "POINT", "SHRUG", "FLEX", "SLEEP",

    -- Misc WoW Terms
    "AFFIX", "HONOR", "MARKS", "BADGE", "TOKEN", "POINT",
    "STACK", "PROCS", "SPAWN", "RESET", "PATCH",
    "NERF", "BUFFS", "NERFS",
    "WIPED", "OWNED", "PWNED",
    "MOUNT", "FLYER", "SPEED",
    "HEART", "SOULS", "BLOOD", "BONES",

    -- Outland/TBC Specific
    "NAARU", "DRAEN", "ILLIS", "OUTLD",
    "SHATT", "AUCHD", "TEMPEST",
    "KAEL", "VASHJ", "ILLID",
    "BADGE", "HONOR", "ARENA",

    -- Common Short Words
    "MANA", "RAGE", "POWER",
    "GOLD", "COIN", "GEMS",
    "HEAL", "HURT", "PAIN", "DOOM",
    "TRAP", "TOTEM",
    "WARD", "AURA", "BUFF", "NERF",
    "WAND", "ORB", "RUNE", "SIGIL",
}

--============================================================
-- BUILD LOOKUP TABLE
--============================================================

WordleWords.WORD_LOOKUP = {}
WordleWords.FIVE_LETTER_WORDS = {}

-- Filter to only exactly 5-letter words and build lookup
for _, word in ipairs(WordleWords.VALID_WORDS) do
    if #word == 5 then
        local upperWord = word:upper()
        if not WordleWords.WORD_LOOKUP[upperWord] then
            WordleWords.WORD_LOOKUP[upperWord] = true
            table.insert(WordleWords.FIVE_LETTER_WORDS, upperWord)
        end
    end
end

HopeAddon:Debug("WordleWords: Loaded", #WordleWords.FIVE_LETTER_WORDS, "valid 5-letter words")

--============================================================
-- PUBLIC API
--============================================================

--[[
    Check if a word is valid (exists in dictionary)
    @param word string - Word to check
    @return boolean
]]
function WordleWords:IsValidWord(word)
    if not word or #word ~= 5 then
        return false
    end
    return self.WORD_LOOKUP[word:upper()] == true
end

--[[
    Get a random word from the dictionary
    @return string - Random 5-letter word
]]
function WordleWords:GetRandomWord()
    if #self.FIVE_LETTER_WORDS == 0 then
        return "ERROR"
    end
    local index = math.random(1, #self.FIVE_LETTER_WORDS)
    return self.FIVE_LETTER_WORDS[index]
end

--[[
    Get all valid words (for debugging/testing)
    @return table - Array of valid words
]]
function WordleWords:GetAllWords()
    return self.FIVE_LETTER_WORDS
end

--[[
    Get word count
    @return number
]]
function WordleWords:GetWordCount()
    return #self.FIVE_LETTER_WORDS
end

-- Export
HopeAddon.WordleWords = WordleWords

HopeAddon:Debug("WordleWords module loaded")
