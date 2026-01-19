--[[
    HopeAddon Core
    Foundation module - loads first, provides utilities
]]

-- WoW API caches for hot paths
local date = date
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel

-- Create global addon table (may already exist from Constants.lua)
HopeAddon = HopeAddon or {}
HopeAddon.name = "HopeAddon"
HopeAddon.version = "1.0.0"

-- Saved variables references (populated on ADDON_LOADED)
HopeAddon.db = nil        -- Account-wide data
HopeAddon.charDb = nil    -- Character-specific data

-- Module registry
HopeAddon.modules = {}

--[[
    Color Definitions
    All colors as {r, g, b, a} tables with hex for display
]]
HopeAddon.colors = {
    -- Fel/Outland Greens
    FEL_GREEN       = { r = 0.20, g = 0.80, b = 0.20, a = 1.0, hex = "32CD32" },
    FEL_GLOW        = { r = 0.40, g = 1.00, b = 0.40, a = 1.0, hex = "66FF66" },
    OUTLAND_TEAL    = { r = 0.00, g = 0.81, b = 0.82, a = 1.0, hex = "00CED1" },

    -- Hellfire Reds/Oranges
    HELLFIRE_RED    = { r = 1.00, g = 0.27, b = 0.27, a = 1.0, hex = "FF4444" },
    HELLFIRE_ORANGE = { r = 1.00, g = 0.55, b = 0.00, a = 1.0, hex = "FF8C00" },
    LAVA_ORANGE     = { r = 1.00, g = 0.65, b = 0.00, a = 1.0, hex = "FFA500" },

    -- Netherstorm Purples
    ARCANE_PURPLE   = { r = 0.61, g = 0.19, b = 1.00, a = 1.0, hex = "9B30FF" },
    NETHER_LAVENDER = { r = 0.69, g = 0.53, b = 0.93, a = 1.0, hex = "B088EE" },
    VOID_PURPLE     = { r = 0.50, g = 0.00, b = 0.50, a = 1.0, hex = "800080" },

    -- Achievement/UI Gold
    GOLD_BRIGHT     = { r = 1.00, g = 0.84, b = 0.00, a = 1.0, hex = "FFD700" },
    GOLD_PALE       = { r = 1.00, g = 0.93, b = 0.55, a = 1.0, hex = "FFEE8C" },
    BRONZE          = { r = 0.80, g = 0.50, b = 0.20, a = 1.0, hex = "CD853F" },

    -- Sky/Water Blues
    SKY_BLUE        = { r = 0.00, g = 0.75, b = 1.00, a = 1.0, hex = "00BFFF" },
    DEEP_BLUE       = { r = 0.25, g = 0.41, b = 0.88, a = 1.0, hex = "4169E1" },
    FROST_BLUE      = { r = 0.53, g = 0.81, b = 0.92, a = 1.0, hex = "87CEEB" },

    -- Special
    PINK_JOY        = { r = 1.00, g = 0.41, b = 0.71, a = 1.0, hex = "FF69B4" },
    NATURE_GREEN    = { r = 0.13, g = 0.55, b = 0.13, a = 1.0, hex = "228B22" },
    SHADOW_GREY     = { r = 0.41, g = 0.41, b = 0.41, a = 1.0, hex = "696969" },

    -- UI Standard
    WHITE           = { r = 1.00, g = 1.00, b = 1.00, a = 1.0, hex = "FFFFFF" },
    BLACK           = { r = 0.00, g = 0.00, b = 0.00, a = 1.0, hex = "000000" },
    GREY            = { r = 0.50, g = 0.50, b = 0.50, a = 1.0, hex = "808080" },

    -- Item quality colors
    POOR            = { r = 0.62, g = 0.62, b = 0.62, a = 1.0, hex = "9D9D9D" },
    COMMON          = { r = 1.00, g = 1.00, b = 1.00, a = 1.0, hex = "FFFFFF" },
    UNCOMMON        = { r = 0.12, g = 1.00, b = 0.00, a = 1.0, hex = "1EFF00" },
    RARE            = { r = 0.00, g = 0.44, b = 0.87, a = 1.0, hex = "0070DD" },
    EPIC            = { r = 0.64, g = 0.21, b = 0.93, a = 1.0, hex = "A335EE" },
    LEGENDARY       = { r = 1.00, g = 0.50, b = 0.00, a = 1.0, hex = "FF8000" },
}

--[[
    Background Colors
    Standardized backdrop colors for UI consistency
]]
HopeAddon.bgColors = {
    -- Standard dark backgrounds
    DARK_TRANSPARENT = { r = 0.1, g = 0.1, b = 0.1, a = 0.7 },
    DARK_SOLID = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
    DARK_OPAQUE = { r = 0.1, g = 0.1, b = 0.1, a = 0.95 },
    DARK_FAINT = { r = 0.1, g = 0.1, b = 0.1, a = 0.6 },

    -- Very dark (for inputs, tracks)
    INPUT_BG = { r = 0.05, g = 0.05, b = 0.05, a = 0.9 },

    -- Purple-tinted (for arcane/nether themed elements)
    PURPLE_TINT = { r = 0.1, g = 0.08, b = 0.15, a = 0.95 },
    PURPLE_DARK = { r = 0.15, g = 0.05, b = 0.2, a = 0.95 },

    -- Blue-tinted (for frost/water themed elements)
    BLUE_TINT = { r = 0.05, g = 0.1, b = 0.15, a = 0.95 },

    -- Red-tinted (for hellfire/combat themed elements)
    RED_TINT = { r = 0.1, g = 0.05, b = 0.05, a = 0.95 },

    -- Green-tinted (for success/complete states)
    GREEN_TINT = { r = 0.1, g = 0.2, b = 0.1, a = 0.8 },

    -- Transparent (for overlays, note boxes)
    OVERLAY = { r = 0, g = 0, b = 0, a = 0.3 },
}

--[[
    Text Colors
    Standardized grayscale text colors for UI hierarchy
]]
HopeAddon.textColors = {
    -- Primary text (titles, important labels)
    PRIMARY = { r = 1, g = 1, b = 1, a = 1 },

    -- Bright text (emphasized content)
    BRIGHT = { r = 0.9, g = 0.9, b = 0.9, a = 1 },

    -- Secondary text (body copy, descriptions)
    SECONDARY = { r = 0.8, g = 0.8, b = 0.8, a = 1 },

    -- Tertiary text (less important info)
    TERTIARY = { r = 0.7, g = 0.7, b = 0.7, a = 1 },

    -- Subtle text (timestamps, hints)
    SUBTLE = { r = 0.6, g = 0.6, b = 0.6, a = 1 },

    -- Disabled/placeholder text
    DISABLED = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
}

-- Background color helper: returns r, g, b, a from bgColors table
function HopeAddon:GetBgColor(colorName)
    local c = self.bgColors[colorName]
    if c then
        return c.r, c.g, c.b, c.a
    end
    return 0.1, 0.1, 0.1, 0.95 -- default DARK_OPAQUE
end

-- Text color helper: returns r, g, b, a from textColors table
function HopeAddon:GetTextColor(colorName)
    local c = self.textColors[colorName]
    if c then
        return c.r, c.g, c.b, c.a
    end
    return 0.8, 0.8, 0.8, 1 -- default SECONDARY
end

--[[
    Asset Paths
    Centralized paths for all textures, sounds, fonts
]]
HopeAddon.assets = {
    textures = {
        -- Backgrounds
        PARCHMENT = "Interface\\QUESTFRAME\\QuestBG",
        PARCHMENT_DARK = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        DIALOG_BG = "Interface\\DialogFrame\\UI-DialogBox-Background",
        TOOLTIP_BG = "Interface\\Tooltips\\UI-Tooltip-Background",
        MARBLE = "Interface\\FrameGeneral\\UI-Background-Marble",

        -- Borders
        GOLD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        DIALOG_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border",
        TOOLTIP_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border",

        -- Progress Bars
        STATUS_BAR = "Interface\\TARGETINGFRAME\\UI-StatusBar",
        SKILLS_BAR = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
        SOLID = "Interface\\BUTTONS\\WHITE8X8",

        -- Glows
        GLOW_ICON = "Interface\\SpellActivationOverlay\\IconAlert",
        GLOW_STAR = "Interface\\Cooldown\\star4",
        GLOW_BUTTON = "Interface\\Buttons\\UI-ActionButton-Border",
        GLOW_CIRCLE = "Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64",

        -- Misc
        HIGHLIGHT = "Interface\\Buttons\\ButtonHilight-Square",
        DIVIDER = "Interface\\QUESTFRAME\\UI-QuestLogTitleHighlight",
        CHECK = "Interface\\Buttons\\UI-CheckBox-Check",
    },

    sounds = {
        -- Journal interaction
        JOURNAL_OPEN = "Sound\\Interface\\WriteQuest.ogg",
        JOURNAL_CLOSE = "Sound\\Interface\\DropOnGround.ogg",
        PAGE_TURN = "Sound\\Interface\\TurnPageA.ogg",
        NEW_ENTRY = "Sound\\Interface\\iQuestUpdate.ogg",

        -- Achievements/Milestones
        LEVEL_UP = "Sound\\Spells\\LevelUp.ogg",
        ACHIEVEMENT = "Sound\\Interface\\iQuestComplete.ogg",
        BELL = "Sound\\Spells\\ShaysBell.ogg",
        CHARACTER_CREATE = "Sound\\Interface\\iCreateCharacterA.ogg",

        -- UI feedback
        CLICK = "Sound\\Interface\\uChatScrollButton.ogg",
        ERROR = "Sound\\Interface\\Error.ogg",
        CHECKBOX = "Sound\\Interface\\igMainMenuOptionCheckBoxOn.ogg",

        -- Dramatic events
        PORTAL_OPEN = "Sound\\Spells\\PortalOpen.ogg",
        BELL_TOLL = "Sound\\Doodad\\BellTollAlliance.ogg",
        HORN = "Sound\\Doodad\\HornGoober.ogg",

        -- Combat
        ABILITIES_FINAL = "Sound\\Interface\\iAbilitiesFinalB.ogg",
        RAID_WARNING = "Sound\\Interface\\RaidWarning.ogg",
    },

    fonts = {
        TITLE = "Fonts\\MORPHEUS.TTF",
        HEADER = "Fonts\\FRIZQT__.TTF",
        BODY = "Fonts\\FRIZQT__.TTF",
        SMALL = "Fonts\\ARIALN.TTF",
    },

    icons = {
        -- General
        JOURNAL = "Interface\\Icons\\INV_Misc_Book_09",
        BOOK_OPEN = "Interface\\Icons\\INV_Misc_Book_11",
        SCROLL = "Interface\\Icons\\INV_Scroll_03",
        STAR = "Interface\\Icons\\INV_Misc_QirajiCrystal_01",
        SKULL = "Interface\\Icons\\Ability_Creature_Cursed_02",
        HEART = "Interface\\Icons\\INV_ValentinesCard01",
        GOLD = "Interface\\Icons\\INV_Misc_Coin_02",
        CROWN = "Interface\\Icons\\Achievement_Reputation_08",

        -- Journal milestones
        POCKET_WATCH = "Interface\\Icons\\INV_Misc_PocketWatch_01",
        NOTE = "Interface\\Icons\\INV_Misc_Note_01",
        HELMET = "Interface\\Icons\\INV_Helmet_06",
        DUAL_WIELD = "Interface\\Icons\\Ability_DualWield",
        MAP = "Interface\\Icons\\INV_Misc_Map_01",
        MAP_OUTLAND = "Interface\\Icons\\INV_Misc_Map_08",
        ARGENT_TOKEN = "Interface\\Icons\\INV_Misc_Token_ArgentDawn",

        -- Keys
        KEY_HEROIC = "Interface\\Icons\\INV_Misc_Key_13",
        KEY_MASTER = "Interface\\Icons\\INV_Misc_Key_14",

        -- Mounts
        GRYPHON = "Interface\\Icons\\Ability_Mount_GryphonRiding",
        NETHER_DRAKE = "Interface\\Icons\\Ability_Mount_NetherDrakeElite",

        -- Creatures/Summons
        INFERNAL = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
        DEVILSAUR = "Interface\\Icons\\Ability_Hunter_Pet_Devilsaur",
        FEL_GUARD = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
    },

    -- TBC Attunement themed textures
    statusIcons = {
        CHECK_READY = "Interface\\RAIDFRAME\\ReadyCheck-Ready",
        CHECK_NOT_READY = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
        QUEST_BANG = "Interface\\GossipFrame\\AvailableQuestIcon",
        QUEST_TURN_IN = "Interface\\GossipFrame\\ActiveQuestIcon",
    },

    -- Raid icons for attunement pages
    raidIcons = {
        KARAZHAN = "Interface\\Icons\\INV_Misc_Key_10",
        SSC = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
        TK = "Interface\\Icons\\Spell_Arcane_PortalShattrath",
        HYJAL = "Interface\\Icons\\Spell_Fire_Burnout",
        BT = "Interface\\Icons\\Achievement_Boss_Illidan",
    },

    -- Dungeon icons for attunement chapters
    dungeonIcons = {
        SHADOW_LAB = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
        STEAMVAULT = "Interface\\Icons\\INV_Gizmo_02",
        ARCATRAZ = "Interface\\Icons\\Spell_Arcane_Arcane01",
        BLACK_MORASS = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar",
        SLAVE_PENS = "Interface\\Icons\\INV_Misc_Fish_14",
        SHATTERED_HALLS = "Interface\\Icons\\Ability_Warrior_Rampage",
        MECHANAR = "Interface\\Icons\\INV_Misc_Gear_08",
        BOTANICA = "Interface\\Icons\\Spell_Nature_ProtectionformNature",
    },

    -- Faction icons
    factionIcons = {
        ALDOR = "Interface\\Icons\\INV_Misc_Token_Aldor",
        SCRYER = "Interface\\Icons\\INV_Misc_Token_Scryer",
        SHATAR = "Interface\\Icons\\Spell_Holy_ChampionsBond",
        CENARION = "Interface\\Icons\\INV_Misc_Idol_03",
    },
}

--[[
    Utility Functions
]]

-- Color helper: returns r, g, b, a from color table
function HopeAddon:GetColor(colorName)
    local c = self.colors[colorName]
    if c then
        return c.r, c.g, c.b, c.a or 1.0
    end
    return 1, 1, 1, 1 -- default white
end

-- Safe color helper: returns color table with fallback
function HopeAddon:GetSafeColor(colorName, fallback)
    fallback = fallback or "GOLD_BRIGHT"
    return self.colors[colorName] or self.colors[fallback]
end

-- Color helper: returns hex string for text coloring
function HopeAddon:GetColorHex(colorName)
    local c = self.colors[colorName]
    if c and c.hex then
        return "|cFF" .. c.hex
    end
    return "|cFFFFFFFF"
end

-- Format text with color
function HopeAddon:ColorText(text, colorName)
    return self:GetColorHex(colorName) .. text .. "|r"
end

-- Play sound safely
function HopeAddon:PlaySound(soundKey)
    if self.db and not self.db.settings.soundEnabled then return end

    local soundPath = self.assets.sounds[soundKey]
    if soundPath then
        PlaySoundFile(soundPath, "Master")
    end
end

-- Get icon path from name (prepends Interface\Icons\)
function HopeAddon:GetIconPath(iconName)
    return "Interface\\Icons\\" .. iconName
end

-- Get current timestamp formatted
function HopeAddon:GetTimestamp()
    return date("%Y-%m-%d %H:%M:%S")
end

-- Get date only
function HopeAddon:GetDate()
    return date("%Y-%m-%d")
end

-- Get formatted time
function HopeAddon:GetTime()
    return date("%H:%M")
end

-- Debug print (only if debug mode enabled)
function HopeAddon:Debug(...)
    if self.db and self.db.debug then
        print("|cFF9B30FF[Hope Debug]|r", ...)
    end
end

-- Print to chat
function HopeAddon:Print(...)
    print("|cFF9B30FF[Hope]|r", ...)
end

-- Format gold value
function HopeAddon:FormatGold(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop = copper % 100

    if gold > 0 then
        return string.format("%dg %ds %dc", gold, silver, cop)
    elseif silver > 0 then
        return string.format("%ds %dc", silver, cop)
    else
        return string.format("%dc", cop)
    end
end

-- Pre-computed class colors (cached at module level to avoid table creation per call)
local CLASS_COLORS = {
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
    ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45 },
    ["ROGUE"] = { r = 1.00, g = 0.96, b = 0.41 },
    ["PRIEST"] = { r = 1.00, g = 1.00, b = 1.00 },
    ["SHAMAN"] = { r = 0.00, g = 0.44, b = 0.87 },
    ["MAGE"] = { r = 0.41, g = 0.80, b = 0.94 },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
    ["DRUID"] = { r = 1.00, g = 0.49, b = 0.04 },
}
local DEFAULT_COLOR = { r = 1, g = 1, b = 1 }

-- Get player class color (uses cached table)
function HopeAddon:GetClassColor(className)
    return CLASS_COLORS[className] or DEFAULT_COLOR
end

--[[
    Module Registration System
]]
function HopeAddon:RegisterModule(name, module)
    self.modules[name] = module
    if module.OnInitialize then
        module:OnInitialize()
    end
end

function HopeAddon:GetModule(name)
    return self.modules[name]
end

--[[
    Event Frame & Handler
]]
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "HopeAddon" then
            HopeAddon:OnAddonLoaded()
        end
    elseif event == "PLAYER_LOGIN" then
        HopeAddon:OnPlayerLogin()
    elseif event == "PLAYER_LOGOUT" then
        HopeAddon:OnPlayerLogout()
    end
end)

--[[
    Lifecycle Handlers
]]

--[[
    Migrate old saved data to ensure new fields exist
    Called on addon load to handle data structure changes
]]
function HopeAddon:MigrateCharacterData()
    local db = self.charDb
    if not db then return end

    -- Ensure travelers structure exists
    db.travelers = db.travelers or {}
    db.travelers.known = db.travelers.known or {}
    db.travelers.fellows = db.travelers.fellows or {}
    db.travelers.badges = db.travelers.badges or {}
    db.travelers.myProfile = db.travelers.myProfile or {
        backstory = "",
        personality = {},
        appearance = "",
        rpHooks = "",
        pronouns = "",
        status = "OOC",
        selectedTitle = nil,
        selectedColor = nil,
    }
    db.travelers.fellowSettings = db.travelers.fellowSettings or {
        enabled = true,
        colorChat = true,
        shareProfile = true,
        showTooltips = true,
    }

    -- Ensure reputation structure exists
    db.reputation = db.reputation or {}
    db.reputation.milestones = db.reputation.milestones or {}
    db.reputation.currentStandings = db.reputation.currentStandings or {}
end

function HopeAddon:OnAddonLoaded()
    -- Initialize saved variables with defaults
    HopeAddonDB = HopeAddonDB or self:GetDefaultDB()
    HopeAddonCharDB = HopeAddonCharDB or self:GetDefaultCharDB()

    self.db = HopeAddonDB
    self.charDb = HopeAddonCharDB

    -- Migrate old saved data: ensure new fields exist
    self:MigrateCharacterData()

    self:Debug("Addon loaded, saved variables initialized")

    -- If player is already in world (reload scenario), enable modules now
    -- PLAYER_LOGIN won't fire again on /reload
    if IsLoggedIn() then
        self:OnPlayerLogin()
    end
end

function HopeAddon:OnPlayerLogin()
    -- Prevent double-initialization (reload + PLAYER_LOGIN race)
    if self.modulesEnabled then return end
    self.modulesEnabled = true

    -- Initialize all registered modules
    for name, module in pairs(self.modules) do
        if module.OnEnable then
            module:OnEnable()
            self:Debug("Module enabled:", name)
        end
    end

    -- Record character creation date if not set
    if not self.charDb.characterCreated then
        self.charDb.characterCreated = self:GetDate()
        self.charDb.characterInfo = {
            name = UnitName("player"),
            class = select(2, UnitClass("player")),
            race = select(2, UnitRace("player")),
            level = UnitLevel("player"),
        }
    end

    -- Show welcome or intro based on state
    if not self.charDb.hasSeenIntro then
        -- First time - show welcome
        self:Print("Welcome, adventurer! Type /hope to open your journal.")
        self.charDb.hasSeenIntro = true
    else
        -- Returning player
        local name = UnitName("player")
        local level = UnitLevel("player")
        self:Print("Welcome back, " .. name .. "! (Level " .. level .. ")")
    end
end

function HopeAddon:OnPlayerLogout()
    -- Save any pending data
    for name, module in pairs(self.modules) do
        if module.OnDisable then
            module:OnDisable()
        end
    end
end

--[[
    Default Database Structures
]]
function HopeAddon:GetDefaultDB()
    return {
        debug = false,
        version = self.version,

        -- Global settings
        settings = {
            soundEnabled = true,
            glowEnabled = true,
            animationsEnabled = true,
            notificationsEnabled = true,
        },
    }
end

function HopeAddon:GetDefaultCharDB()
    return {
        -- Story progress
        hasSeenIntro = false,
        characterCreated = nil,
        characterInfo = nil,

        -- Journal entries
        journal = {
            entries = {},           -- Array of all entries
            levelMilestones = {},   -- [level] = entry data
            zoneDiscoveries = {},   -- [zoneName] = entry data
            bossKills = {},         -- [bossName] = entry data
            customNotes = {},       -- User-added notes
        },

        -- Attunement progress
        attunements = {
            karazhan = {
                started = false,
                completed = false,
                completedDate = nil,
                chapters = {},
            },
        },

        -- Statistics
        stats = {
            deaths = {
                total = 0,
                byZone = {},
                byBoss = {},
            },
            playtime = 0,               -- Total /played time in seconds
            dungeonClears = {},         -- Legacy field
            raidClears = {},            -- Legacy field
            questsCompleted = 0,
            goldEarned = 0,
            -- New TBC stats
            creaturesSlain = 0,         -- Combat log creature kills
            largestHit = 0,             -- Highest damage dealt
            dungeonRuns = {},           -- [dungeonKey] = { normal = n, heroic = n }
            flyingUnlocked = nil,       -- Date string when flying was unlocked
            epicFlyingUnlocked = nil,   -- Date string when epic flying was unlocked
        },

        -- Fellow travelers
        travelers = {
            known = {},  -- [playerName] = { lastSeen, class, level }
            fellows = {}, -- [playerName] = { detected addon users + cached profiles }

            -- Player's own RP profile
            myProfile = {
                backstory = "",
                personality = {},       -- Array of trait strings
                appearance = "",
                rpHooks = "",
                pronouns = "",
                status = "OOC",         -- IC, OOC, LF_RP
                selectedTitle = nil,    -- From unlocked badges
                selectedColor = nil,    -- Hex color from badges
            },

            -- Unlocked badges
            badges = {},    -- [badge_id] = { unlocked = true, date = "..." }

            -- Fellow traveler settings
            fellowSettings = {
                enabled = true,
                colorChat = true,
                shareProfile = true,
                showTooltips = true,
            },
        },

        -- Reputation tracking
        reputation = {
            milestones = {},        -- [factionName][standingId] = entry
            aldorScryerChoice = nil, -- { chosen, opposing, date }
            currentStandings = {},   -- snapshot cache
        },
    }
end

--[[
    Slash Commands
]]
SLASH_HOPE1 = "/hope"
SLASH_HOPE2 = "/journal"
SlashCmdList["HOPE"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "" or cmd == "show" then
        HopeAddon:ToggleJournal()
    elseif cmd == "debug" then
        HopeAddon.db.debug = not HopeAddon.db.debug
        HopeAddon:Print("Debug mode:", HopeAddon.db.debug and "ON" or "OFF")
    elseif cmd == "reset" then
        HopeAddon:Print("Type /hope reset confirm to reset all character data")
    elseif cmd == "reset confirm" then
        HopeAddonCharDB = HopeAddon:GetDefaultCharDB()
        HopeAddon.charDb = HopeAddonCharDB
        HopeAddon:Print("Character data reset!")
        ReloadUI()
    elseif cmd == "stats" then
        HopeAddon:ShowStats()
    elseif cmd == "sound" then
        HopeAddon.db.settings.soundEnabled = not HopeAddon.db.settings.soundEnabled
        HopeAddon:Print("Sounds:", HopeAddon.db.settings.soundEnabled and "ON" or "OFF")
    elseif cmd:find("^tetris") then
        -- /hope tetris [player] - Start Tetris Battle game
        local _, _, targetName = cmd:find("^tetris%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Challenge player to Tetris
            local GameComms = HopeAddon:GetModule("GameComms")
            if GameComms then
                GameComms:SendInvite(targetName, "TETRIS")
                HopeAddon:Print("Challenging", targetName, "to Tetris Battle!")
            else
                HopeAddon:Print("GameComms module not loaded!")
            end
        else
            -- Start local Tetris game
            local TetrisGame = HopeAddon:GetModule("TetrisGame")
            if TetrisGame then
                TetrisGame:StartGame()
                HopeAddon:Print("Starting local Tetris Battle!")
            else
                HopeAddon:Print("TetrisGame module not loaded!")
            end
        end
    elseif cmd:find("^pong") then
        -- /hope pong [player] - Start Pong game
        local _, _, targetName = cmd:find("^pong%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Challenge player to Pong
            local GameComms = HopeAddon:GetModule("GameComms")
            if GameComms then
                GameComms:SendInvite(targetName, "PONG")
                HopeAddon:Print("Challenging", targetName, "to Pong!")
            else
                HopeAddon:Print("GameComms module not loaded!")
            end
        else
            -- Start local Pong game
            local PongGame = HopeAddon:GetModule("PongGame")
            if PongGame then
                PongGame:StartGame()
                HopeAddon:Print("Starting local Pong game!")
            else
                HopeAddon:Print("PongGame module not loaded!")
            end
        end
    elseif cmd:find("^challenge") then
        -- /hope challenge <player> [dice|rps]
        local _, _, targetName, gameType = cmd:find("^challenge%s+(%S+)%s*(%S*)")
        if not targetName then
            HopeAddon:Print("Usage: /hope challenge <player> [dice|rps]")
            HopeAddon:Print("  Example: /hope challenge Thrall dice")
        else
            local Minigames = HopeAddon:GetModule("Minigames")
            if Minigames then
                gameType = gameType ~= "" and gameType or "dice"
                Minigames:SendChallenge(targetName, gameType)
            else
                HopeAddon:Print("Minigames module not loaded!")
            end
        end
    elseif cmd == "accept" then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:AcceptChallenge()
        end
    elseif cmd == "decline" then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:DeclineChallenge()
        end
    elseif cmd == "cancel" then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:CancelGame("user_cancelled")
        end
    else
        HopeAddon:Print("Commands:")
        HopeAddon:Print("  /hope - Open journal")
        HopeAddon:Print("  /hope debug - Toggle debug mode")
        HopeAddon:Print("  /hope stats - Show statistics")
        HopeAddon:Print("  /hope sound - Toggle sounds")
        HopeAddon:Print("  /hope tetris [player] - Start Tetris Battle (local or vs player)")
        HopeAddon:Print("  /hope pong [player] - Start Pong (local or vs player)")
        HopeAddon:Print("  /hope challenge <player> [dice|rps] - Challenge a Fellow Traveler")
        HopeAddon:Print("  /hope accept/decline - Respond to challenge")
        HopeAddon:Print("  /hope cancel - Cancel current game")
        HopeAddon:Print("  /hope reset confirm - Reset all data")
    end
end

-- Show stats in chat
function HopeAddon:ShowStats()
    local stats = self.charDb.stats
    local deathTitle, deathColor
    if self.Constants and self.Constants.GetDeathTitle then
        deathTitle, deathColor = self.Constants:GetDeathTitle(stats.deaths.total)
    end
    deathTitle = deathTitle or "Unknown"
    deathColor = deathColor or "ffffff"

    self:Print("--- Your Adventure Stats ---")
    self:Print("Deaths: " .. self:ColorText(tostring(stats.deaths.total), deathColor) .. " (" .. deathTitle .. ")")
    self:Print("Quests Completed: " .. stats.questsCompleted)

    -- Use Journal's cached counts if available
    local Journal = self:GetModule("Journal")
    local zoneCount, milestoneCount
    if Journal and Journal.GetCachedCounts then
        local counts = Journal:GetCachedCounts()
        zoneCount = counts.zones
        milestoneCount = counts.milestones
    else
        -- Fallback to iteration if Journal not loaded
        zoneCount = 0
        for _ in pairs(self.charDb.journal.zoneDiscoveries) do
            zoneCount = zoneCount + 1
        end
        milestoneCount = 0
        for _ in pairs(self.charDb.journal.levelMilestones) do
            milestoneCount = milestoneCount + 1
        end
    end

    self:Print("Zones Discovered: " .. zoneCount)
    self:Print("Milestones Reached: " .. milestoneCount)
end

-- Toggle journal (will be implemented by Journal module)
function HopeAddon:ToggleJournal()
    local journal = self:GetModule("Journal")
    if journal and journal.Toggle then
        journal:Toggle()
    else
        self:Print("Journal module not loaded yet!")
    end
end
