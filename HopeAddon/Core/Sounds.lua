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

function Sounds:PlayDeath()
    self:Play("combat", "death")
end

function Sounds:PlayVictory()
    self:Play("combat", "victory")
end

function Sounds:PlayBossKill()
    self:Play("combat", "bossKill")
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
