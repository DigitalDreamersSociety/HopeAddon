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

    Note: Words stored as space-separated strings to avoid Lua parser constant limits
]]

local WordDictionary = {}

-- Local references for performance
local upper = string.upper
local sub = string.sub
local gmatch = string.gmatch

-- Track word count during loading
local wordCount = 0

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

WordDictionary.WORDS = {}

-- Helper to add words from a space-separated string (avoids Lua constant limit)
local function AddWordString(str)
    local WORDS = WordDictionary.WORDS
    for word in gmatch(str, "%S+") do
        WORDS[upper(word)] = true
        wordCount = wordCount + 1
    end
end

-- Classes and Specs
AddWordString("WARRIOR PALADIN HUNTER ROGUE PRIEST SHAMAN MAGE WARLOCK DRUID ARMS FURY PROT HOLY DISC SHADOW FROST FIRE ARCANE RESTO FERAL BALANCE TANK HEALER DPS CASTER MELEE")

-- Races
AddWordString("HUMAN DWARF GNOME ELF DRAENEI ORC TROLL TAUREN UNDEAD FORSAKEN BLOOD NIGHT HORDE ALLIANCE FACTION")

-- Professions
AddWordString("ALCHEMY BLACKSMITH ENCHANT ENGINEER HERB JEWEL LEATHER MINING SKINNING TAILOR COOK FISH FIRST AID POTION ELIXIR FLASK GEM ORE BAR INGOT CLOTH BOLT SCALE HIDE")

-- Combat Terms
AddWordString("AGGRO THREAT TANK PULL WIPE PROC CRIT HIT MISS DODGE PARRY BLOCK RESIST ABSORB HEAL DAMAGE DOT HOT AOE CLEAVE STUN ROOT SLOW SILENCE FEAR CHARM SHEEP SAP BLIND KICK INTERRUPT DISPEL PURGE BUFF DEBUFF STACK SPAWN RESPAWN RESET ENRAGE BERSERK")

-- Raid/Dungeon Terms
AddWordString("RAID DUNGEON INSTANCE HEROIC NORMAL BOSS TRASH CLEAR LOOT ROLL NEED GREED PASS BIS GEAR TIER TOKEN DROP EPIC RARE LEGENDARY BIND SOULBOUND PICKUP LOCKOUT")

-- TBC Zones
AddWordString("OUTLAND HELLFIRE ZANGAR MARSH TEROKKAR NAGRAND BLADE EDGE NETHERSTORM SHADOWMOON VALLEY SHATTRATH AREA TEMPEST KEEP CITADEL AUCHINDOUN COILFANG")

-- TBC Raids
AddWordString("KARAZHAN GRUUL LAIR MAGTHERIDON SERPENT SHRINE HYJAL TEMPLE SUNWELL PLATEAU")

-- TBC Dungeons
AddWordString("RAMPARTS FURNACE SHATTERED HALLS SLAVE PENS UNDERBOG STEAMVAULT MANA TOMBS CRYPTS SETHEKK LABYRINTH MECHANAR BOTANICA ARCATRAZ MORASS ESCAPE DURNHOLDE")

-- Bosses (TBC)
AddWordString("ILLIDAN VASHJ KAEL THAS ARCHIMONDE AZGALOR RAGE WINTERCHILL ANETHERON KAZROGAL SUPREMUS AKAMA GURTOGG BLOODBOIL RELIQUARY SHAHRAZ COUNCIL PRINCE MALCHEZAAR NIGHTBANE NETHERSPITE CURATOR ARAN MOROES ATTUMEN MAIDEN OPERA")

-- Items/Gear
AddWordString("SWORD AXE MACE DAGGER STAFF WAND BOW GUN CROSSBOW POLEARM FIST SHIELD HELM CHEST LEGS BOOTS GLOVES BELT BRACERS SHOULDERS CLOAK RING TRINKET NECK RELIC IDOL TOTEM LIBRAM GLAIVE")

-- Famous Items
AddWordString("THUNDERFURY SULFURAS ATIESH WARGLAIVE AZZINOTH BLESSED WINDSEEKER HAND RAGNAROS ASHBRINGER")

-- Spells/Abilities - Healing & Buffs
AddWordString("HEAL FLASH GREATER PRAYER MENDING RENEW SHIELD WORD POWER FORTITUDE SPIRIT INTELLECT STRENGTH AGILITY STAMINA ARMOR MARK WILD THORNS REJUVENATION REGROWTH LIFEBLOOM SWIFTMEND MOONFIRE STARFIRE WRATH HURRICANE BARKSKIN")

-- Spells/Abilities - Melee Classes
AddWordString("STEALTH VANISH SPRINT EVASION GOUGE BACKSTAB SINISTER STRIKE EVISCERATE RUPTURE CHARGE EXECUTE MORTAL WHIRLWIND BLOODTHIRST SLAM OVERPOWER REND THUNDER CLAP SHOUT JUDGEMENT SEAL BLESSING AURA DEVOTION RETRIBUTION CONSECRATION EXORCISM HAMMER LAY HANDS")

-- Spells/Abilities - Hunter & Shaman
AddWordString("TRAP SHOT ASPECT HAWK MONKEY CHEETAH BEAST FEIGN DEATH MEND PET TAME CALL DISMISS EARTH SHOCK FLAME CHAIN TREMOR GROUNDING WINDFURY BLOODLUST HEROISM REINCARNATION")

-- Spells/Abilities - Warlock & Mage
AddWordString("FIREBALL FROSTBOLT SHADOWBOLT LIGHTNING BOLT HOWL TERROR CURSE AGONY DOOM TONGUES WEAKNESS ELEMENTS RECKLESSNESS CORRUPTION IMMOLATE CONFLAGRATE RAIN HELLFIRE SUMMON DEMON IMP VOIDWALKER SUCCUBUS FELHUNTER FELGUARD BLINK POLYMORPH COUNTERSPELL CONE COLD BLIZZARD MISSILES EXPLOSION BRILLIANCE EVOCATION ICE BARRIER")

-- Consumables
AddWordString("FOOD DRINK WATER BREAD BANDAGE HEALTHSTONE SOULSTONE HEALTH REJUV SUPERIOR MAJOR SUPER DESTRUCTION FORTIFICATION MIGHTY SPEED HASTE SPELL")

-- Factions/Reputation
AddWordString("ALDOR SCRYER SHATAR CENARION EXPEDITION HONOR HOLD KURENAI MAGHAR CONSORTIUM SPOREGGAR LOWER CITY OGRI SKYGUARD NETHERWING ASHTONGUE DEATHSWORN SANDS VIOLET EYE EXALTED REVERED HONORED FRIENDLY NEUTRAL UNFRIENDLY HOSTILE HATED")

-- Creatures/Mobs
AddWordString("ELEMENTAL HUMANOID DRAGON DRAGONKIN GIANT MECHANICAL ABERRATION CRITTER MURLOC NAGA OGRE INFERNAL DOOMGUARD EREDAR PITLORD OBSERVER BEHOLDER NETHER RAY WARP STALKER SPOREBAT SPORE WALKER")

-- WoW Slang
AddWordString("GANK CAMP FARM GRIND LEVEL DING GRATS WTB WTS WTT LFG LFM PST INV PORT HEARTH STONE MOUNT FLYING SWIFT NETHERDRAKE TALBUK ELEKK KODO RAPTOR WOLF AFAIK IMO BRB AFK OOM OOC TRADE GOLD")

-- Common English 3-letter words (part 1)
AddWordString("THE AND FOR ARE BUT NOT YOU ALL CAN HAD HER WAS ONE OUR OUT DAY GET HAS HIM HIS HOW ITS MAY NEW NOW OLD SEE WAY WHO BOY DID SAY SHE TOO USE ACE ADD AGE AGO AID AIM AIR ARM ART ASK ATE BAD BAG BED BIG BIT BOX BUS BUY CAR CUT DIE DIG DOG DRY DUE EAR EAT")

-- Common English 3-letter words (part 2)
AddWordString("END EYE FAR FAT FEW FIT FLY GOD GOT GUY HOT ILL JOB JOY KEY KID LAY LED LEG LET LIE LOT LOW MAN MAP MEN MET MIX MOM MUD NET NOR ODD OFF OIL OWN PAY PEN PIE PIN PIT POT PUT RAN RAT RAW RED RID RIP ROB ROD ROT ROW RUB RUG RUN SAD SAT SET SIT SIX SKY SON SUN TAX TEN TIE TIP TOP TOY TRY TWO VAN WAR WET WIN WON YET")

-- Common English 4-letter words (A-D)
AddWordString("ABLE ALSO BACK BEEN BEST BODY BOOK BOTH CAME COME DARK DEAD DEAL DEEP DOES DONE DOOR DOWN DRAW DROP")

-- Common English 4-letter words (E-G)
AddWordString("EACH EAST EASY ELSE EVEN EVER FACE FACT FALL FAST FEEL FEET FELL FILL FILM FIND FINE FOOT FORM FOUR FREE FROM FULL GAME GAVE GIVE GOES GONE GOOD GREW GROW")

-- Common English 4-letter words (H-K)
AddWordString("HAIR HALF HANG HARD HAVE HEAD HEAR HEAT HELD HELP HERE HIGH HILL HOME HOPE HOUR HUGE HUNG IDEA INTO IRON JUST KEEP KEPT KIND KNEW KNOW")

-- Common English 4-letter words (L-M)
AddWordString("LACK LADY LAND LAST LATE LEFT LESS LIFE LIKE LINE LIST LIVE LONG LOOK LORD LOSE LOST LOVE MADE MAIN MAKE MANY MASS MEAN MEET MIND MORE MOST MOVE MUCH MUST")

-- Common English 4-letter words (N-R)
AddWordString("NAME NEAR NEED NEWS NEXT NICE NONE NOTE ONCE ONLY OPEN OVER PAGE PAID PAIR PARK PART PAST PATH PICK PLAN PLAY PLUS POOR POST PULL PUSH RACE RATE READ REAL REST RICH RIDE RISE RISK ROAD ROCK ROLE ROOM ROSE RULE")

-- Common English 4-letter words (S)
AddWordString("SAFE SAID SAIL SAKE SALE SAME SAND SAVE SEAT SEEK SEEM SELF SELL SEND SENT SHIP SHOP SHOW SHUT SICK SIDE SIGN SING SITE SIZE SKIN SLOW SNOW SOFT SOIL SOLD SOLE SOME SONG SOON SORT SOUL SPOT STAR STAY STEP STOP SUCH SURE")

-- Common English 4-letter words (T)
AddWordString("TAIL TAKE TALK TALL TEAM TELL TEND TERM TEST TEXT THAN THAT THEM THEN THEY THIN THIS THUS TILL TIME TINY TOLD TONE TOOK TOOL TOUR TOWN TREE TRIP TRUE TURN TYPE")

-- Common English 4-letter words (U-Z)
AddWordString("UNIT UPON USED USER VARY VAST VERY VIEW VOTE WAIT WAKE WALK WALL WANT WARM WASH WAVE WEAK WEAR WEEK WELL WENT WERE WEST WHAT WHEN WIDE WIFE WILD WILL WIND WINE WING WIRE WISE WISH WITH WOOD WORE WORK YARD YEAH YEAR YOUR ZERO ZONE")

-- Additional useful words
AddWordString("NEVER PAIN LEAD CALL CITY MARK HAND HOLD FIRE RAIN SHOT")

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
    return self.WORDS[upper(word)] == true
end

--[[
    Get the point value of a word
    @param word string
    @return number
]]
function WordDictionary:GetWordValue(word)
    if not word then return 0 end

    local total = 0
    local values = self.LETTER_VALUES
    for i = 1, #word do
        local letter = sub(word, i, i)
        total = total + (values[upper(letter)] or 0)
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
    return self.LETTER_VALUES[upper(letter)] or 0
end

--[[
    Generate a bag of letter tiles
    @return table - Array of letters
]]
function WordDictionary:GenerateTileBag()
    local bag = {}
    local insert = table.insert
    local random = math.random

    for letter, count in pairs(self.LETTER_DISTRIBUTION) do
        for i = 1, count do
            insert(bag, letter)
        end
    end

    -- Fisher-Yates shuffle
    for i = #bag, 2, -1 do
        local j = random(i)
        bag[i], bag[j] = bag[j], bag[i]
    end

    return bag
end

--[[
    Get word count in dictionary (cached during load)
    @return number
]]
function WordDictionary:GetWordCount()
    return wordCount
end

--[[
    Search for words starting with prefix
    @param prefix string
    @param limit number
    @return table - Array of matching words
]]
function WordDictionary:SearchWords(prefix, limit)
    prefix = upper(prefix)
    limit = limit or 10
    local results = {}
    local prefixLen = #prefix
    local insert = table.insert

    for word in pairs(self.WORDS) do
        if sub(word, 1, prefixLen) == prefix then
            insert(results, word)
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
