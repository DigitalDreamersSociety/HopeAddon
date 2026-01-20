--[[
    HopeAddon Sounds Module
    Audio helpers and sound effect management
]]

-- WoW API cache for hot path
local PlaySoundFile = PlaySoundFile

local Sounds = {}
HopeAddon.Sounds = Sounds

-- Reference centralized sound assets
local assets = HopeAddon.assets.sounds

-- Sound paths organized by category (referencing centralized assets)
Sounds.library = {
    -- Journal interaction sounds
    journal = {
        open = assets.JOURNAL_OPEN,
        close = assets.JOURNAL_CLOSE,
        pageTurn = assets.PAGE_TURN,
        newEntry = assets.NEW_ENTRY,
        write = assets.JOURNAL_OPEN,
    },

    -- Achievement/milestone sounds
    achievement = {
        levelUp = assets.LEVEL_UP,
        complete = assets.ACHIEVEMENT,
        milestone = assets.BELL,
        discovery = assets.CHARACTER_CREATE,
    },

    -- UI feedback sounds
    ui = {
        click = assets.CLICK,
        error = assets.ERROR,
        success = assets.CHARACTER_CREATE,
        hover = assets.CHECKBOX,
    },

    -- Dramatic event sounds
    dramatic = {
        portalOpen = assets.PORTAL_OPEN,
        gong = assets.BELL_TOLL,
        horn = assets.HORN,
        magic = assets.BELL,
    },

    -- Combat sounds
    combat = {
        death = assets.ABILITIES_FINAL,
        victory = assets.RAID_WARNING,
        bossKill = assets.ACHIEVEMENT,
    },

    -- Reputation milestone sounds
    reputation = {
        friendly = assets.CHARACTER_CREATE,
        honored = assets.BELL,
        revered = assets.ACHIEVEMENT,
        exalted = assets.LEVEL_UP,
    },

    -- Progress bar feedback sounds (gaming-style)
    progress = {
        tick = assets.CHECKBOX,      -- Subtle tick for 10% segments
        milestone = assets.BELL,     -- Bell chime at 25/50/75%
        complete = assets.ACHIEVEMENT, -- Full completion fanfare
    },

    -- Death Roll gameshow sounds
    deathroll = {
        suspense = assets.BELL_TOLL,      -- Pre-reveal tension (dramatic gong)
        reveal = assets.RAID_WARNING,     -- Number reveal whoosh
        safe = assets.CHECKBOX,           -- Safe roll (subtle tick)
        caution = assets.BELL,            -- Getting risky (bell)
        danger = assets.ERROR,            -- Warning tone
        critical = assets.ABILITIES_FINAL, -- Near death (dramatic)
        death = assets.ABILITIES_FINAL,   -- Player eliminated
        yourTurn = assets.BELL,           -- Turn notification
    },

    -- Death comedy sounds (WoW built-in sound IDs for Bumblebee-style sequence)
    deathComedy = {
        questFailed = 847,   -- igQuestFailed (sad failure sound)
        bagClose = 863,      -- IG_BACKPACK_CLOSE (punctuation beat)
        murlocAggro = 416,   -- MurlocAggro (comic punchline "Mrglglgl!")
    },

    -- Battleship gameshow sounds
    battleship = {
        shot = assets.CLICK,              -- Shot fired
        hit = assets.ERROR,               -- Hit explosion
        miss = assets.CHECKBOX,           -- Water splash (subtle)
        sunk = assets.ABILITIES_FINAL,    -- Ship destroyed (dramatic)
        yourTurn = assets.BELL,           -- Turn notification
        victory = assets.ACHIEVEMENT,     -- Victory fanfare
        defeat = assets.ERROR,            -- Defeat sound
    },
}

-- Sound channel preferences
Sounds.channels = {
    ui = "Master",
    music = "Music",
    ambient = "Ambience",
    sfx = "SFX",
}

-- Store sequence timer handles for cancellation
Sounds.sequenceTimers = {}

--[[
    Play a sound from the library
    @param category string - Category name (journal, achievement, etc.)
    @param soundName string - Sound name within category
    @param channel string - Optional: audio channel (defaults to Master)
]]
function Sounds:Play(category, soundName, channel)
    -- Check if sounds are enabled
    if HopeAddon.db and not HopeAddon.db.settings.soundEnabled then
        return
    end

    local cat = self.library[category]
    if not cat then
        HopeAddon:Debug("Sound category not found:", category)
        return
    end

    local soundPath = cat[soundName]
    if not soundPath then
        HopeAddon:Debug("Sound not found:", category, soundName)
        return
    end

    channel = channel or self.channels.ui
    PlaySoundFile(soundPath, channel)
end

--[[
    Quick play functions for common sounds
]]
function Sounds:PlayJournalOpen()
    self:Play("journal", "open")
end

function Sounds:PlayJournalClose()
    self:Play("journal", "close")
end

function Sounds:PlayPageTurn()
    self:Play("journal", "pageTurn")
end

function Sounds:PlayNewEntry()
    self:Play("journal", "newEntry")
end

function Sounds:PlayLevelUp()
    self:Play("achievement", "levelUp")
end

function Sounds:PlayMilestone()
    self:Play("achievement", "milestone")
end

function Sounds:PlayDiscovery()
    self:Play("achievement", "discovery")
end

function Sounds:PlayClick()
    self:Play("ui", "click")
end

function Sounds:PlayError()
    self:Play("ui", "error")
end

function Sounds:PlaySuccess()
    self:Play("ui", "success")
end

function Sounds:PlayHover()
    self:Play("ui", "hover")
end

function Sounds:PlayBell()
    self:Play("ui", "milestone")  -- Uses BELL sound asset
end

function Sounds:PlayDeath()
    self:Play("combat", "death")
end

function Sounds:PlayVictory()
    self:Play("combat", "victory")
end

function Sounds:PlayBossKill()
    self:Play("combat", "bossKill")
end

-- Progress bar sounds (gaming-style feedback)
function Sounds:PlayProgressTick()
    self:Play("progress", "tick")
end

function Sounds:PlayProgressMilestone()
    self:Play("progress", "milestone")
end

function Sounds:PlayProgressComplete()
    self:Play("progress", "complete")
end

-- Death Roll gameshow sounds
function Sounds:PlayDeathRoll(soundName)
    self:Play("deathroll", soundName)
end

function Sounds:PlayDeathRollSuspense()
    self:Play("deathroll", "suspense")
end

function Sounds:PlayDeathRollReveal()
    self:Play("deathroll", "reveal")
end

function Sounds:PlayDeathRollYourTurn()
    self:Play("deathroll", "yourTurn")
end

-- Battleship gameshow sounds
function Sounds:PlayBattleship(soundName)
    self:Play("battleship", soundName)
end

function Sounds:PlayBattleshipHit()
    self:Play("battleship", "hit")
end

function Sounds:PlayBattleshipMiss()
    self:Play("battleship", "miss")
end

function Sounds:PlayBattleshipSunk()
    self:Play("battleship", "sunk")
end

function Sounds:PlayBattleshipYourTurn()
    self:Play("battleship", "yourTurn")
end

--[[
    Play funny "Sad Trombone" death comedy sequence
    Uses WoW's built-in PlaySound API with numeric sound IDs
    Sequence: Quest Failed → Bag Close → Murloc Aggro
]]
function Sounds:PlayDeathComedy()
    if HopeAddon.db and not HopeAddon.db.settings.soundEnabled then
        return
    end

    -- Cancel any existing sequence
    self:CancelSequence()

    -- Play using WoW's PlaySound API (numeric IDs)
    local ids = self.library.deathComedy
    PlaySound(ids.questFailed, "Master")  -- Quest Failed - immediate

    local handle1 = HopeAddon.Timer:After(0.3, function()
        PlaySound(ids.bagClose, "Master")  -- Bag Close
    end)
    table.insert(self.sequenceTimers, handle1)

    local handle2 = HopeAddon.Timer:After(0.5, function()
        PlaySound(ids.murlocAggro, "Master")  -- Murloc Aggro "Mrglglgl!"
    end)
    table.insert(self.sequenceTimers, handle2)
end

--[[
    Play a custom sound file
    @param soundPath string - Full path to sound file
    @param channel string - Optional audio channel
]]
function Sounds:PlayCustom(soundPath, channel)
    if HopeAddon.db and not HopeAddon.db.settings.soundEnabled then
        return
    end

    channel = channel or self.channels.ui
    PlaySoundFile(soundPath, channel)
end

--[[
    Cancel any currently playing sound sequence
]]
function Sounds:CancelSequence()
    for _, handle in ipairs(self.sequenceTimers) do
        if handle and handle.Cancel then handle:Cancel() end
    end
    self.sequenceTimers = {}
end

--[[
    Play a sequence of sounds with delays
    @param sounds table - Array of {category, soundName, delay} tables
]]
function Sounds:PlaySequence(sounds)
    if HopeAddon.db and not HopeAddon.db.settings.soundEnabled then
        return
    end

    -- Cancel any existing sequence to prevent overlapping sounds
    self:CancelSequence()

    local totalDelay = 0
    for _, soundData in ipairs(sounds) do
        local category, soundName, delay = soundData[1], soundData[2], soundData[3] or 0
        totalDelay = totalDelay + delay

        local handle = HopeAddon.Timer:After(totalDelay, function()
            self:Play(category, soundName)
        end)
        table.insert(self.sequenceTimers, handle)
    end
end

--[[
    Play achievement fanfare (level up + milestone)
]]
function Sounds:PlayAchievementFanfare()
    self:PlaySequence({
        { "achievement", "levelUp", 0 },
        { "achievement", "milestone", 0.5 },
    })
end

-- Alias for backwards compatibility
Sounds.PlayAchievement = Sounds.PlayAchievementFanfare

--[[
    Play epic moment fanfare (for major milestones)
]]
function Sounds:PlayEpicFanfare()
    self:PlaySequence({
        { "dramatic", "gong", 0 },
        { "achievement", "complete", 1.0 },
        { "dramatic", "magic", 1.5 },
    })
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Sounds module loaded")
end
