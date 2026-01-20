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

-- Combat UI auto-hide state
local combatUIState = {
    wasJournalOpen = false,
    wasProfileEditorOpen = false,
    hiddenGameWindows = {},  -- [gameId] = true for games that were visible
    isHiddenForCombat = false,
}

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
        -- Backgrounds (NOTE: QuestBG removed - cannot tile/scale, use DIALOG_BG instead)
        PARCHMENT = "Interface\\DialogFrame\\UI-DialogBox-Background",
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

        -- Fellow Traveler discovery (comedy Murloc sound)
        FELLOW_DISCOVERY = "Sound\\Creature\\Murloc\\mMurlocAggroOld.ogg",
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

--[[
    SafeCall - Execute function with error protection
    @param func function - Function to call
    @param ... - Arguments to pass
    @return boolean success, any result or error
]]
function HopeAddon:SafeCall(func, ...)
    if type(func) ~= "function" then
        self:Debug("SafeCall: not a function")
        return false, "not a function"
    end
    return pcall(func, ...)
end

--[[
    SendChallenge - Central challenge routing function
    Routes to the correct module based on game type.

    @param targetName string - Player to challenge
    @param gameId string - Game ID (rps, deathroll, pong, tetris, words, battleship)
    @param betAmount number|nil - Optional bet for death roll
    @return boolean - True if challenge was sent
]]
function HopeAddon:SendChallenge(targetName, gameId, betAmount)
    if not targetName or targetName == "" then
        self:Print("Invalid target name")
        return false
    end

    gameId = gameId:lower()

    -- Legacy games (RPS, Dice, Death Roll) use Minigames module
    if gameId == "rps" or gameId == "dice" then
        local Minigames = self:GetModule("Minigames")
        if Minigames then
            Minigames:SendChallenge(targetName, gameId)
            return true
        end
    -- Death Roll uses GameComms with optional bet
    elseif gameId == "deathroll" or gameId == "death_roll" then
        local GameComms = self:GetModule("GameComms")
        if GameComms then
            GameComms:SendInvite(targetName, "DEATH_ROLL", betAmount or 0)
            return true
        end
    -- Tetris and Pong use Score Challenge for remote play
    elseif gameId == "tetris" or gameId == "pong" then
        local ScoreChallenge = self:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:StartChallenge(targetName, gameId:upper())
            return true
        end
    -- Words and Battleship use GameComms
    elseif gameId == "words" or gameId == "battleship" then
        local GameComms = self:GetModule("GameComms")
        if GameComms then
            GameComms:SendInvite(targetName, gameId:upper(), 0)
            return true
        end
    else
        self:Print("Unknown game: " .. gameId)
        return false
    end

    self:Print("Required module not loaded for " .. gameId)
    return false
end

--[[
    CreateBackdropFrame - Create backdrop-compatible frame
    Handles TBC Classic vs original TBC 2.4.3 differences

    @param frameType string - Frame type (e.g., "Frame", "Button", "ScrollFrame")
    @param name string|nil - Frame name
    @param parent Frame - Parent frame
    @param additionalTemplate string|nil - Additional template(s)
    @return Frame
]]
function HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    local frame

    -- Check if BackdropTemplateMixin exists (TBC Classic / Retail)
    if BackdropTemplateMixin then
        -- TBC Classic: Use BackdropTemplate
        local template = additionalTemplate and (additionalTemplate .. ", BackdropTemplate") or "BackdropTemplate"
        frame = CreateFrame(frameType or "Frame", name, parent, template)

        -- Double-check SetBackdrop was applied; if not, manually apply mixin
        if not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
            -- Initialize backdrop hooks if needed
            if frame.OnBackdropLoaded then
                frame:OnBackdropLoaded()
            end
        end
    else
        -- Original TBC 2.4.3: SetBackdrop is native to all frames
        frame = CreateFrame(frameType or "Frame", name, parent, additionalTemplate)
    end

    return frame
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
    COLOR UTILITIES
    Helper functions for color manipulation and application
]]
HopeAddon.ColorUtils = {}

--[[
    Lighten a color by percentage
    @param color table - {r, g, b, a}
    @param percent number - 0.0 to 1.0 (e.g., 0.2 = 20% lighter)
    @return table - New color table
]]
function HopeAddon.ColorUtils:Lighten(color, percent)
    return {
        r = math.min(1, color.r + (color.r * percent)),
        g = math.min(1, color.g + (color.g * percent)),
        b = math.min(1, color.b + (color.b * percent)),
        a = color.a
    }
end

--[[
    Darken a color by percentage
    @param color table - {r, g, b, a}
    @param percent number - 0.0 to 1.0 (e.g., 0.2 = 20% darker)
    @return table - New color table
]]
function HopeAddon.ColorUtils:Darken(color, percent)
    return {
        r = math.max(0, color.r - (color.r * percent)),
        g = math.max(0, color.g - (color.g * percent)),
        b = math.max(0, color.b - (color.b * percent)),
        a = color.a
    }
end

--[[
    Apply vertex color from color name
    @param texture Texture
    @param colorName string - Key from HopeAddon.colors
]]
function HopeAddon.ColorUtils:ApplyVertexColor(texture, colorName)
    local color = HopeAddon.colors[colorName]
    if color then
        texture:SetVertexColor(color.r, color.g, color.b, color.a or 1)
    else
        HopeAddon:Debug("ColorUtils:ApplyVertexColor: Unknown color", colorName)
    end
end

--[[
    Apply text color from color name
    @param fontString FontString
    @param colorName string - Key from HopeAddon.colors
]]
function HopeAddon.ColorUtils:ApplyTextColor(fontString, colorName)
    local color = HopeAddon.colors[colorName]
    if color then
        fontString:SetTextColor(color.r, color.g, color.b, color.a or 1)
    else
        HopeAddon:Debug("ColorUtils:ApplyTextColor: Unknown color", colorName)
    end
end

--[[
    Blend two colors
    @param color1 table - {r, g, b, a}
    @param color2 table - {r, g, b, a}
    @param ratio number - 0.0 to 1.0 (0 = color1, 1 = color2, 0.5 = midpoint)
    @return table - New blended color
]]
function HopeAddon.ColorUtils:Blend(color1, color2, ratio)
    ratio = math.max(0, math.min(1, ratio))  -- Clamp to 0-1
    local invRatio = 1 - ratio
    return {
        r = (color1.r * invRatio) + (color2.r * ratio),
        g = (color1.g * invRatio) + (color2.g * ratio),
        b = (color1.b * invRatio) + (color2.b * ratio),
        a = (color1.a or 1) * invRatio + (color2.a or 1) * ratio
    }
end

--[[
    Convert hex string to color table
    @param hex string - Hex color like "FF9B30" or "#FF9B30"
    @return table - {r, g, b, a} with values 0-1
]]
function HopeAddon.ColorUtils:HexToRGB(hex)
    -- Remove # if present
    hex = hex:gsub("#", "")

    if #hex == 6 then
        return {
            r = tonumber(hex:sub(1, 2), 16) / 255,
            g = tonumber(hex:sub(3, 4), 16) / 255,
            b = tonumber(hex:sub(5, 6), 16) / 255,
            a = 1
        }
    elseif #hex == 8 then
        return {
            r = tonumber(hex:sub(1, 2), 16) / 255,
            g = tonumber(hex:sub(3, 4), 16) / 255,
            b = tonumber(hex:sub(5, 6), 16) / 255,
            a = tonumber(hex:sub(7, 8), 16) / 255
        }
    else
        HopeAddon:Debug("ColorUtils:HexToRGB: Invalid hex format", hex)
        return { r = 1, g = 1, b = 1, a = 1 }
    end
end

--[[
    SPEC / TALENT DETECTION UTILITIES
    For determining player's primary specialization based on talent point distribution
]]

-- Role mapping: class token -> spec tab index -> role
-- Roles: "tank", "healer", "melee_dps", "ranged_dps", "caster_dps"
HopeAddon.SPEC_ROLE_MAP = {
    ["WARRIOR"] = {
        [1] = "melee_dps",  -- Arms
        [2] = "melee_dps",  -- Fury
        [3] = "tank",       -- Protection
    },
    ["PALADIN"] = {
        [1] = "healer",     -- Holy
        [2] = "tank",       -- Protection
        [3] = "melee_dps",  -- Retribution
    },
    ["PRIEST"] = {
        [1] = "healer",     -- Discipline
        [2] = "healer",     -- Holy
        [3] = "caster_dps", -- Shadow
    },
    ["DRUID"] = {
        [1] = "caster_dps", -- Balance
        [2] = "melee_dps",  -- Feral (cat DPS - uses same leather agility gear as rogues)
        [3] = "healer",     -- Restoration
    },
    ["SHAMAN"] = {
        [1] = "caster_dps", -- Elemental
        [2] = "melee_dps",  -- Enhancement
        [3] = "healer",     -- Restoration
    },
    ["MAGE"] = {
        [1] = "caster_dps", -- Arcane
        [2] = "caster_dps", -- Fire
        [3] = "caster_dps", -- Frost
    },
    ["WARLOCK"] = {
        [1] = "caster_dps", -- Affliction
        [2] = "caster_dps", -- Demonology
        [3] = "caster_dps", -- Destruction
    },
    ["HUNTER"] = {
        [1] = "ranged_dps", -- Beast Mastery
        [2] = "ranged_dps", -- Marksmanship
        [3] = "ranged_dps", -- Survival
    },
    ["ROGUE"] = {
        [1] = "melee_dps",  -- Assassination
        [2] = "melee_dps",  -- Combat
        [3] = "melee_dps",  -- Subtlety
    },
}

--[[
    Get the player's primary specialization by reading talent point distribution
    @return specName string - Name of the spec (e.g., "Protection", "Restoration")
    @return specTab number - Tab index (1, 2, or 3)
    @return pointsSpent number - Points invested in that tree
]]
function HopeAddon:GetPlayerSpec()
    local maxPoints = 0
    local specTab = 1
    local specName = "Unknown"

    -- TBC Classic supports GetNumTalentTabs() and GetTalentTabInfo()
    local numTabs = GetNumTalentTabs() or 3

    for tab = 1, numTabs do
        local _, name, _, _, points = GetTalentTabInfo(tab)
        if points and points > maxPoints then
            maxPoints = points
            specTab = tab
            specName = name or "Unknown"
        end
    end

    return specName, specTab, maxPoints
end

--[[
    Get the role for a given class and spec tab
    @param classToken string - e.g., "WARRIOR", "PRIEST"
    @param specTab number - Tab index (1, 2, or 3)
    @return role string - "tank", "healer", "melee_dps", "ranged_dps", or "caster_dps"
]]
function HopeAddon:GetSpecRole(classToken, specTab)
    local classRoles = self.SPEC_ROLE_MAP[classToken]
    if classRoles then
        return classRoles[specTab] or "melee_dps"
    end
    return "melee_dps" -- Default fallback
end

--[[
    Check if a role is a DPS role
    @param role string - Role from GetSpecRole
    @return boolean
]]
function HopeAddon:IsDPSRole(role)
    return role == "melee_dps" or role == "ranged_dps" or role == "caster_dps"
end

--[[
    TIME FORMATTING UTILITIES
]]

--[[
    Format seconds into M:SS or MM:SS format
    @param seconds number - Time in seconds
    @return string - Formatted time (e.g., "3:45" or "--:--" if nil)
]]
function HopeAddon:FormatTime(seconds)
    if not seconds or seconds < 0 then return "--:--" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
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
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Combat start
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Combat end

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
    elseif event == "PLAYER_REGEN_DISABLED" then
        HopeAddon:OnCombatStart()
    elseif event == "PLAYER_REGEN_ENABLED" then
        HopeAddon:OnCombatEnd()
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
        colorNameplates = true,
        colorMinimapPins = true,
    }
    -- Ensure new settings exist for existing users
    if db.travelers.fellowSettings.colorNameplates == nil then
        db.travelers.fellowSettings.colorNameplates = true
    end
    if db.travelers.fellowSettings.colorMinimapPins == nil then
        db.travelers.fellowSettings.colorMinimapPins = true
    end

    -- Ensure reputation structure exists
    db.reputation = db.reputation or {}
    db.reputation.milestones = db.reputation.milestones or {}
    db.reputation.currentStandings = db.reputation.currentStandings or {}

    -- Migrate bossKills to include kill time tracking fields
    if db.journal and db.journal.bossKills then
        for key, killData in pairs(db.journal.bossKills) do
            -- Ensure new time tracking fields exist (nil is fine for untracked)
            if killData.killTimes == nil then
                killData.killTimes = {}
            end
        end
    end

    -- Ensure social feed structure exists
    db.social = db.social or {}
    db.social.feed = db.social.feed or {}
    db.social.lastSeen = db.social.lastSeen or {}
    db.social.settings = db.social.settings or {
        showBoss = true,
        showLevel = true,
        showGame = true,
        showBadge = true,
        showStatus = true,
    }
    db.social.myRumors = db.social.myRumors or {}
    db.social.mugsGiven = db.social.mugsGiven or {}
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

    -- Initialize all registered modules with error protection
    for name, module in pairs(self.modules) do
        if module.OnEnable then
            local success, err = pcall(module.OnEnable, module)
            if success then
                self:Debug("Module enabled:", name)
            else
                self:Print("|cFFFF0000ERROR:|r Module " .. name .. " failed to enable: " .. tostring(err))
            end
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
        self:Print("Welcome, traveler! Type /hope to open your journal.")
        self.charDb.hasSeenIntro = true
    else
        -- Returning player
        local name = UnitName("player")
        local level = UnitLevel("player")
        self:Print("Welcome back, " .. name .. "! (Level " .. level .. ")")
    end
end

function HopeAddon:OnPlayerLogout()
    -- Save any pending data with error protection
    for name, module in pairs(self.modules) do
        if module.OnDisable then
            local success, err = pcall(module.OnDisable, module)
            if not success then
                self:Debug("Module", name, "disable error:", tostring(err))
            end
        end
    end
end

--[[
    Combat UI Auto-Hide System
    Hides all addon UI when entering combat, restores when leaving
]]
function HopeAddon:OnCombatStart()
    -- Check if feature is enabled
    if not self.db or not self.db.settings.hideUIDuringCombat then
        return
    end

    -- Reset state
    combatUIState.wasJournalOpen = false
    combatUIState.wasProfileEditorOpen = false
    wipe(combatUIState.hiddenGameWindows)

    local hidSomething = false

    -- Hide Journal
    local Journal = self.Journal
    if Journal and Journal.isOpen and Journal.mainFrame then
        combatUIState.wasJournalOpen = true
        Journal.mainFrame:Hide()
        hidSomething = true
    end

    -- Hide ProfileEditor
    local ProfileEditor = self.ProfileEditor
    if ProfileEditor and ProfileEditor.isOpen and ProfileEditor.frame then
        combatUIState.wasProfileEditorOpen = true
        ProfileEditor.frame:Hide()
        hidSomething = true
    end

    -- Hide and pause active game windows
    local GameCore = self.GameCore
    if GameCore and GameCore.activeGames then
        for gameId, game in pairs(GameCore.activeGames) do
            if game.data and game.data.ui and game.data.ui.window then
                local window = game.data.ui.window
                if window:IsShown() then
                    combatUIState.hiddenGameWindows[gameId] = true
                    window:Hide()
                    -- Pause the game
                    GameCore:PauseGame(gameId)
                    hidSomething = true
                end
            end
        end
    end

    combatUIState.isHiddenForCombat = hidSomething

    -- Show notification if we hid something
    if hidSomething and self.db.settings.notificationsEnabled then
        self:Print("|cFFFFD700UI hidden during combat|r")
    end
end

function HopeAddon:OnCombatEnd()
    -- Only restore if we actually hid things
    if not combatUIState.isHiddenForCombat then
        return
    end

    -- Restore Journal
    if combatUIState.wasJournalOpen then
        local Journal = self.Journal
        if Journal and Journal.mainFrame then
            Journal.mainFrame:Show()
        end
    end

    -- Restore ProfileEditor
    if combatUIState.wasProfileEditorOpen then
        local ProfileEditor = self.ProfileEditor
        if ProfileEditor and ProfileEditor.frame then
            ProfileEditor.frame:Show()
        end
    end

    -- Restore and unpause game windows
    local GameCore = self.GameCore
    if GameCore and GameCore.activeGames then
        for gameId, wasVisible in pairs(combatUIState.hiddenGameWindows) do
            if wasVisible then
                local game = GameCore.activeGames[gameId]
                if game and game.data and game.data.ui and game.data.ui.window then
                    game.data.ui.window:Show()
                    -- Unpause the game
                    GameCore:ResumeGame(gameId)
                end
            end
        end
    end

    -- Reset state
    combatUIState.isHiddenForCombat = false
    wipe(combatUIState.hiddenGameWindows)

    -- Show notification
    if self.db and self.db.settings.notificationsEnabled then
        self:Print("|cFF00FF00UI restored|r")
    end
end

function HopeAddon:IsUIHiddenForCombat()
    return combatUIState.isHiddenForCombat
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
            hideUIDuringCombat = true,  -- Auto-hide UI when entering combat
        },

        -- Minimap button settings
        minimapButton = {
            position = 225,  -- Angle in degrees (225 = lower-left)
            enabled = true,
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
                colorNameplates = true,     -- Color Fellow nameplates by RP status
                colorMinimapPins = true,    -- Color minimap pins by RP status
            },
        },

        -- Reputation tracking
        reputation = {
            milestones = {},        -- [factionName][standingId] = entry
            aldorScryerChoice = nil, -- { chosen, opposing, date }
            currentStandings = {},   -- snapshot cache
        },

        -- Saved games (for async multiplayer)
        savedGames = {
            words = {
                games = {},             -- [opponentName] = serialized game state
                pendingInvites = {},    -- [senderName] = { state, timestamp }
                sentInvites = {},       -- [recipientName] = { state, timestamp }
            },
        },

        -- Relationships/notes about players
        relationships = {},             -- [playerName] = { note, addedDate }

        -- Social activity feed (Tavern Notice Board)
        social = {
            feed = {},           -- Array of { id, type, player, class, data, time, mugs }
            lastSeen = {},       -- [activityId] = true (deduplication)
            settings = {
                showBoss = true,
                showLevel = true,
                showGame = true,
                showBadge = true,
                showStatus = true,
            },
            -- Phase 2: Rumors and reactions
            myRumors = {},       -- [timestamp] = { text, expires }
            mugsGiven = {},      -- [activityId] = true

            -- Phase 3: Companions (favorites list)
            companions = {
                list = {},       -- { [name] = { since, lastSeen, class, level } }
                outgoing = {},   -- { [name] = { timestamp } }
                incoming = {},   -- { [name] = { timestamp, class, level } }
            },

            -- Phase 4: Toast notification settings
            toasts = {
                enabled = true,
                CompanionOnline = true,
                CompanionNearby = true,
                CompanionRequest = true,
                MugReceived = true,
                CompanionLfrp = true,
                FellowDiscovered = true,
            },
        },
    }
end

--[[
    Slash Commands
]]
-- Player name validation constants
local MAX_PLAYER_NAME_LENGTH = 12  -- WoW max character name length

-- Validate player name input
local function ValidatePlayerName(name)
    if not name or name == "" then
        return false, "Player name required"
    end
    if #name > MAX_PLAYER_NAME_LENGTH then
        return false, "Player name too long (max " .. MAX_PLAYER_NAME_LENGTH .. " characters)"
    end
    -- WoW names are alphanumeric only (no special chars except accents)
    if not name:match("^[%a]+$") then
        return false, "Invalid player name format"
    end
    return true
end

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
    elseif cmd == "combathide" then
        HopeAddon.db.settings.hideUIDuringCombat = not HopeAddon.db.settings.hideUIDuringCombat
        HopeAddon:Print("Combat UI hide:", HopeAddon.db.settings.hideUIDuringCombat and "ON" or "OFF")
    elseif cmd == "nameplates" then
        -- Toggle Fellow Traveler nameplate coloring
        local NameplateColors = HopeAddon:GetModule("NameplateColors")
        if NameplateColors then
            local enabled = NameplateColors:Toggle()
            HopeAddon:Print("Fellow nameplate colors:", enabled and "|cFF33FF33ON|r" or "|cFFFF3333OFF|r")
            if enabled then
                HopeAddon:Print("  |cFF33FF33IC|r = Green, |cFF00BFFFOOC|r = Blue, |cFFFF33CCLF_RP|r = Pink")
            end
        end
    elseif cmd == "pins" then
        -- Toggle minimap pin RP status coloring
        if HopeAddon.MapPins then
            local enabled = HopeAddon.MapPins:TogglePinColoring()
            HopeAddon:Print("Fellow minimap pin colors:", enabled and "|cFF33FF33ON|r" or "|cFFFF3333OFF|r")
            if enabled then
                HopeAddon:Print("  |cFF33FF33IC|r = Green, |cFF00BFFFOOC|r = Blue, |cFFFF33CCLF_RP|r = Pink")
            end
        end
    elseif cmd:find("^tetris") then
        -- /hope tetris [player] - Start Tetris game (local or score challenge)
        local _, _, targetName = cmd:find("^tetris%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Challenge player to Tetris Score Battle
            local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
            if ScoreChallenge then
                ScoreChallenge:StartChallenge(targetName, "TETRIS")
            else
                HopeAddon:Print("ScoreChallenge module not loaded!")
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
        -- /hope pong [player] - Start Pong game (local or score challenge)
        local _, _, targetName = cmd:find("^pong%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Challenge player to Pong Score Battle
            local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
            if ScoreChallenge then
                ScoreChallenge:StartChallenge(targetName, "PONG")
            else
                HopeAddon:Print("ScoreChallenge module not loaded!")
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
    elseif cmd:find("^deathroll") then
        -- /hope deathroll [player]
        local _, _, targetName = cmd:find("^deathroll%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Challenge player to Death Roll
            local GameComms = HopeAddon:GetModule("GameComms")
            if GameComms then
                GameComms:SendInvite(targetName, "DEATH_ROLL")
                HopeAddon:Print("Challenging", targetName, "to Death Roll!")
            else
                HopeAddon:Print("GameComms module not loaded!")
            end
        else
            -- Start local Death Roll game
            local DeathRollGame = HopeAddon:GetModule("DeathRollGame")
            if DeathRollGame then
                DeathRollGame:StartGame()
                HopeAddon:Print("Starting local Death Roll!")
            else
                HopeAddon:Print("DeathRollGame module not loaded!")
            end
        end
    elseif cmd:find("^words") then
        -- /hope words <player|list|forfeit>
        local _, _, subCmd = cmd:find("^words%s*(%S*)")
        local WordGame = HopeAddon:GetModule("WordGame")

        if not subCmd or subCmd == "" then
            -- No argument - start local practice game
            if WordGame then
                WordGame:StartGame(nil)
            else
                HopeAddon:Print("WordGame module not loaded!")
            end
        elseif subCmd == "list" then
            -- List saved games
            if WordGame then
                WordGame:ListSavedGames()
            else
                HopeAddon:Print("WordGame module not loaded!")
            end
        elseif subCmd:find("^forfeit%s*") then
            -- Forfeit a game: /hope words forfeit <player>
            local _, _, opponentName = cmd:find("^words%s+forfeit%s+(%S+)")
            if opponentName and opponentName ~= "" then
                local valid, err = ValidatePlayerName(opponentName)
                if not valid then
                    HopeAddon:Print("|cFFFF0000Error:|r " .. err)
                    return
                end
                if WordGame then
                    WordGame:ForfeitGame(opponentName)
                else
                    HopeAddon:Print("WordGame module not loaded!")
                end
            else
                HopeAddon:Print("Usage: /hope words forfeit <player>")
            end
        elseif subCmd == "accept" then
            -- Accept pending Words invite: /hope words accept [player]
            local _, _, senderName = cmd:find("^words%s+accept%s*(%S*)")
            local WordGameInvites = HopeAddon:GetModule("WordGameInvites")
            if WordGameInvites then
                if senderName and senderName ~= "" then
                    WordGameInvites:AcceptInvite(senderName)
                elseif WordGameInvites:HasPendingInvites() then
                    -- Accept first pending
                    for challenger, _ in pairs(WordGameInvites:GetPendingInvites()) do
                        WordGameInvites:AcceptInvite(challenger)
                        break
                    end
                else
                    HopeAddon:Print("No pending Words invites.")
                end
            else
                HopeAddon:Print("WordGameInvites module not loaded!")
            end
        elseif subCmd == "decline" then
            -- Decline pending Words invite: /hope words decline [player]
            local _, _, senderName = cmd:find("^words%s+decline%s*(%S*)")
            local WordGameInvites = HopeAddon:GetModule("WordGameInvites")
            if WordGameInvites then
                if senderName and senderName ~= "" then
                    WordGameInvites:DeclineInvite(senderName)
                elseif WordGameInvites:HasPendingInvites() then
                    for challenger, _ in pairs(WordGameInvites:GetPendingInvites()) do
                        WordGameInvites:DeclineInvite(challenger)
                        break
                    end
                else
                    HopeAddon:Print("No pending Words invites.")
                end
            else
                HopeAddon:Print("WordGameInvites module not loaded!")
            end
        else
            -- Assume it's a player name - resume existing game or send invite
            local targetName = subCmd
            local valid, err = ValidatePlayerName(targetName)
            if not valid then
                HopeAddon:Print("|cFFFF0000Error:|r " .. err)
                return
            end

            -- Try to resume existing game first
            local Persistence = HopeAddon:GetModule("WordGamePersistence")
            if Persistence and Persistence:HasGame(targetName) then
                if WordGame then
                    local gameId, resumeErr = WordGame:ResumeGame(targetName)
                    if not gameId then
                        HopeAddon:Print("|cFFFF0000Error:|r " .. (resumeErr or "Failed to resume game"))
                    end
                else
                    HopeAddon:Print("WordGame module not loaded!")
                end
            else
                -- No saved game - send invite
                local WordGameInvites = HopeAddon:GetModule("WordGameInvites")
                if WordGameInvites then
                    WordGameInvites:SendInvite(targetName)
                else
                    HopeAddon:Print("WordGameInvites module not loaded!")
                end
            end
        end
    elseif cmd:find("^battleship") then
        -- /hope battleship [player]
        local _, _, targetName = cmd:find("^battleship%s*(%S*)")
        if targetName and targetName ~= "" then
            -- Validate player name
            local valid, err = ValidatePlayerName(targetName)
            if not valid then
                HopeAddon:Print("|cFFFF0000Error:|r " .. err)
                return
            end
            -- Challenge player to Battleship
            local GameComms = HopeAddon:GetModule("GameComms")
            if GameComms then
                GameComms:SendInvite(targetName, "BATTLESHIP")
                HopeAddon:Print("Challenging", targetName, "to Battleship!")
            else
                HopeAddon:Print("GameComms module not loaded!")
            end
        else
            -- Start local Battleship game
            local GameCore = HopeAddon:GetModule("GameCore")
            if GameCore then
                local gameId = GameCore:CreateGame("BATTLESHIP", GameCore.GAME_MODE.LOCAL, nil)
                if gameId then
                    GameCore:StartGame(gameId)
                    HopeAddon:Print("Starting Battleship vs AI!")
                end
            else
                HopeAddon:Print("GameCore module not loaded!")
            end
        end
    elseif cmd:find("^challenge") then
        -- /hope challenge <player> [rps]
        local _, _, targetName, gameType = cmd:find("^challenge%s+(%S+)%s*(%S*)")
        if not targetName then
            HopeAddon:Print("Usage: /hope challenge <player> [rps]")
            HopeAddon:Print("  Example: /hope challenge Thrall rps")
        else
            -- Validate player name
            local valid, err = ValidatePlayerName(targetName)
            if not valid then
                HopeAddon:Print("|cFFFF0000Error:|r " .. err)
                return
            end
            local Minigames = HopeAddon:GetModule("Minigames")
            if Minigames then
                gameType = gameType ~= "" and gameType or "rps"
                Minigames:SendChallenge(targetName, gameType)
            else
                HopeAddon:Print("Minigames module not loaded!")
            end
        end
    elseif cmd:find("^accept") then
        -- Check for pending challenges in order: Words, ScoreChallenge, Minigames
        local _, _, targetName = cmd:find("^accept%s*(%S*)")

        -- Check Words invites first
        local WordGameInvites = HopeAddon:GetModule("WordGameInvites")
        if WordGameInvites and WordGameInvites:HasPendingInvites() then
            if targetName and targetName ~= "" then
                WordGameInvites:AcceptInvite(targetName)
            else
                -- Accept first pending Words invite
                for challenger, _ in pairs(WordGameInvites:GetPendingInvites()) do
                    WordGameInvites:AcceptInvite(challenger)
                    break
                end
            end
            return
        end

        -- Check ScoreChallenge
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge and ScoreChallenge:HasPendingChallenges() then
            if targetName and targetName ~= "" then
                ScoreChallenge:AcceptChallenge(targetName)
            else
                for challenger, _ in pairs(ScoreChallenge.pendingChallenges) do
                    ScoreChallenge:AcceptChallenge(challenger)
                    break
                end
            end
            return
        end

        -- Fall back to Minigames accept
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:AcceptChallenge()
        end

    elseif cmd:find("^decline") then
        -- Check for pending challenges in order: Words, ScoreChallenge, Minigames
        local _, _, targetName = cmd:find("^decline%s*(%S*)")

        -- Check Words invites first
        local WordGameInvites = HopeAddon:GetModule("WordGameInvites")
        if WordGameInvites and WordGameInvites:HasPendingInvites() then
            if targetName and targetName ~= "" then
                WordGameInvites:DeclineInvite(targetName)
            else
                for challenger, _ in pairs(WordGameInvites:GetPendingInvites()) do
                    WordGameInvites:DeclineInvite(challenger)
                    break
                end
            end
            return
        end

        -- Check ScoreChallenge
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge and ScoreChallenge:HasPendingChallenges() then
            if targetName and targetName ~= "" then
                ScoreChallenge:DeclineChallenge(targetName)
            else
                for challenger, _ in pairs(ScoreChallenge.pendingChallenges) do
                    ScoreChallenge:DeclineChallenge(challenger)
                    break
                end
            end
            return
        end

        -- Fall back to Minigames decline
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:DeclineChallenge()
        end
    elseif cmd == "cancel" then
        -- Check for active score challenge first
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge and ScoreChallenge:IsInChallenge() then
            ScoreChallenge:CancelChallenge("USER_QUIT")
        else
            -- Fall back to Minigames cancel
            local Minigames = HopeAddon:GetModule("Minigames")
            if Minigames then
                Minigames:CancelGame("user_cancelled")
            end
        end
    elseif cmd == "demo" then
        -- Populate sample data for testing the UI
        HopeAddon:PopulateDemoData()
    elseif cmd == "reset demo" then
        -- Clear demo data and reset to defaults
        HopeAddon:ClearDemoData()
    elseif cmd == "testbar" then
        -- Show a demo gaming-style reputation bar
        HopeAddon:ShowTestBar()
    elseif cmd == "minimap" then
        -- Toggle minimap button visibility
        local minimapBtn = HopeAddon:GetModule("MinimapButton")
        if minimapBtn and minimapBtn.Toggle then
            minimapBtn:Toggle()
        end
    else
        HopeAddon:Print("Commands:")
        HopeAddon:Print("  /hope - Open journal")
        HopeAddon:Print("  /hope debug - Toggle debug mode")
        HopeAddon:Print("  /hope stats - Show statistics")
        HopeAddon:Print("  /hope sound - Toggle sounds")
        HopeAddon:Print("  /hope minimap - Toggle minimap button")
        HopeAddon:Print("  /hope tetris [player] - Start Tetris Battle (local or vs player)")
        HopeAddon:Print("  /hope pong [player] - Start Pong (local or vs player)")
        HopeAddon:Print("  /hope deathroll [player] - Start Death Roll (local or vs player)")
        HopeAddon:Print("  /hope words <player> - Challenge to Words with WoW")
        HopeAddon:Print("  /word <word> <H/V> <row> <col> - Place word in active Words game")
        HopeAddon:Print("  /pass - Pass your turn in active Words game")
        HopeAddon:Print("  /hope battleship [player] - Start Battleship (local or vs player)")
        HopeAddon:Print("  /fire <coord> - Fire at coordinate in Battleship (e.g., /fire A5)")
        HopeAddon:Print("  /ready - Signal ships placed in Battleship")
        HopeAddon:Print("  /surrender - Forfeit current Battleship game")
        HopeAddon:Print("  /gc <message> - Send chat to opponent during any game")
        HopeAddon:Print("  /hope challenge <player> [rps] - Challenge to Rock-Paper-Scissors")
        HopeAddon:Print("  /hope accept/decline - Respond to challenge")
        HopeAddon:Print("  /hope cancel - Cancel current game")
        HopeAddon:Print("  /hope demo - Populate sample data for UI testing")
        HopeAddon:Print("  /hope reset demo - Clear demo data")
        HopeAddon:Print("  /hope reset confirm - Reset all data")
        HopeAddon:Print("  /hope testbar - Show gaming-style reputation bar demo")
    end
end

-- /word slash command for Words with WoW gameplay
SLASH_WORD1 = "/word"
SlashCmdList["WORD"] = function(msg)
    local WordGame = HopeAddon:GetModule("WordGame")
    if not WordGame then
        HopeAddon:Print("WordGame module not loaded!")
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then
        HopeAddon:Print("GameCore module not loaded!")
        return
    end

    -- Find active Words with WoW game for this player
    local playerName = UnitName("player")
    local activeGame = nil
    local activeGameId = nil

    for gameId, game in pairs(WordGame:GetActiveGames()) do
        if game.player1 == playerName or game.player2 == playerName then
            activeGame = game
            activeGameId = gameId
            break
        end
    end

    if not activeGame then
        HopeAddon:Print("You are not in an active Words with WoW game!")
        HopeAddon:Print("Use /hope words <player> to start a game")
        return
    end

    -- Parse command: /word <word> <H/V> <row> <col>
    local word, direction, row, col = strsplit(" ", msg)

    local success, message = WordGame:ParseAndPlaceWord(activeGameId, word, direction, row, col, playerName)

    if not success then
        HopeAddon:Print("|cFFFF0000Error:|r " .. message)
    end
end

-- /pass slash command for Words with WoW gameplay
SLASH_PASS1 = "/pass"
SlashCmdList["PASS"] = function(msg)
    local WordGame = HopeAddon:GetModule("WordGame")
    if not WordGame then
        HopeAddon:Print("WordGame module not loaded!")
        return
    end

    -- Find active Words with WoW game for this player
    local playerName = UnitName("player")
    local activeGame = nil
    local activeGameId = nil

    for gameId, game in pairs(WordGame:GetActiveGames()) do
        if game.player1 == playerName or game.player2 == playerName then
            activeGame = game
            activeGameId = gameId
            break
        end
    end

    if not activeGame then
        HopeAddon:Print("You are not in an active Words with WoW game!")
        return
    end

    local success, message = WordGame:PassTurn(activeGameId, playerName)

    if not success then
        HopeAddon:Print("|cFFFF0000Error:|r " .. message)
    end
end

-- /fire slash command for Battleship gameplay
SLASH_FIRE1 = "/fire"
SlashCmdList["FIRE"] = function(msg)
    local BattleshipGame = HopeAddon:GetModule("BattleshipGame")
    if not BattleshipGame then
        HopeAddon:Print("BattleshipGame module not loaded!")
        return
    end

    -- Find active Battleship game
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then
        HopeAddon:Print("GameCore module not loaded!")
        return
    end

    local activeGameId = nil
    for gameId, game in pairs(GameCore.activeGames) do
        if game.gameType == "BATTLESHIP" and game.state == GameCore.STATE.PLAYING then
            activeGameId = gameId
            break
        end
    end

    if not activeGameId then
        HopeAddon:Print("You are not in an active Battleship game!")
        HopeAddon:Print("Use /hope battleship to start a game")
        return
    end

    -- Parse coordinate: "A5" -> row=5, col=1
    local coord = msg:upper():gsub("%s+", "")
    if not coord or coord == "" then
        HopeAddon:Print("Usage: /fire <coord> (e.g., /fire A5, /fire B10)")
        return
    end

    local Board = HopeAddon.BattleshipBoard
    if not Board then
        HopeAddon:Print("BattleshipBoard not loaded!")
        return
    end

    local row, col = Board:ParseCoord(coord)

    if not row or not col or row < 1 or row > 10 or col < 1 or col > 10 then
        HopeAddon:Print("Invalid coordinate! Use A-J and 1-10 (e.g., A5, B10)")
        return
    end

    BattleshipGame:PlayerShoot(activeGameId, row, col)
end

-- /ready slash command for Battleship
SLASH_READY1 = "/ready"
SlashCmdList["READY"] = function(msg)
    local BattleshipGame = HopeAddon:GetModule("BattleshipGame")
    if not BattleshipGame then
        HopeAddon:Print("BattleshipGame module not loaded!")
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    for gameId, game in pairs(GameCore.activeGames) do
        if game.gameType == "BATTLESHIP" and game.state ~= GameCore.STATE.ENDED then
            BattleshipGame:SignalReady(gameId)
            return
        end
    end

    HopeAddon:Print("No active Battleship game found!")
end

-- /surrender slash command for Battleship
SLASH_SURRENDER1 = "/surrender"
SlashCmdList["SURRENDER"] = function(msg)
    local BattleshipGame = HopeAddon:GetModule("BattleshipGame")
    if not BattleshipGame then
        HopeAddon:Print("BattleshipGame module not loaded!")
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    for gameId, game in pairs(GameCore.activeGames) do
        if game.gameType == "BATTLESHIP" and game.state ~= GameCore.STATE.ENDED then
            BattleshipGame:Surrender(gameId)
            return
        end
    end

    HopeAddon:Print("No active Battleship game found!")
end

-- /gc or /gamechat for in-game chat during multiplayer games
SLASH_GAMECHAT1 = "/gc"
SLASH_GAMECHAT2 = "/gamechat"
SlashCmdList["GAMECHAT"] = function(msg)
    if not msg or msg == "" then
        HopeAddon:Print("Usage: /gc <message>")
        return
    end

    local GameChat = HopeAddon:GetModule("GameChat")
    if GameChat then
        GameChat:SendMessage(msg)
    else
        HopeAddon:Print("GameChat module not loaded!")
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

    self:Print("--- Your Journey Stats ---")
    self:Print("Deaths: " .. self:ColorText(tostring(stats.deaths.total), deathColor) .. " (" .. deathTitle .. ")")
    self:Print("Quests Completed: " .. stats.questsCompleted)

    -- Use Journal's cached counts if available
    local Journal = self:GetModule("Journal")
    local milestoneCount
    if Journal and Journal.GetCachedCounts then
        local counts = Journal:GetCachedCounts()
        milestoneCount = counts.milestones
    else
        -- Fallback to iteration if Journal not loaded
        milestoneCount = 0
        for _ in pairs(self.charDb.journal.levelMilestones) do
            milestoneCount = milestoneCount + 1
        end
    end

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

--[[
    Populate demo data for UI testing
    Creates sample milestones, zone discoveries, journal entries, and travelers
]]
function HopeAddon:PopulateDemoData()
    local charDb = self.charDb
    local C = self.Constants
    local playerName = UnitName("player")
    local timestamp = date("%Y-%m-%d %H:%M")

    -- Mark as having demo data
    charDb._hasDemoData = true

    -- Add level milestones (5, 10, 15, 20, 25, 30)
    local demoLevels = { 5, 10, 15, 20, 25, 30 }
    for _, level in ipairs(demoLevels) do
        local milestoneData = C.LEVEL_MILESTONES[level]
        if milestoneData and not charDb.journal.levelMilestones[level] then
            local entry = {
                type = "milestone",
                title = milestoneData.title,
                description = milestoneData.story,
                icon = "Interface\\Icons\\" .. milestoneData.icon,
                timestamp = timestamp,
                level = level,
            }
            charDb.journal.levelMilestones[level] = entry
            table.insert(charDb.journal.entries, entry)
        end
    end

    -- Add some stats
    charDb.stats.deaths.total = 5
    charDb.stats.deaths.byZone["Hellfire Peninsula"] = 3
    charDb.stats.deaths.byZone["Zangarmarsh"] = 2
    charDb.stats.playtime = 72000  -- 20 hours
    charDb.stats.questsCompleted = 150
    charDb.stats.creaturesSlain = 2500
    charDb.stats.largestHit = 1250

    -- Add sample travelers
    local demoTravelers = {
        { name = "Thrall", class = "SHAMAN", level = 70, zone = "Nagrand" },
        { name = "Jaina", class = "MAGE", level = 70, zone = "Shattrath City" },
        { name = "Sylvanas", class = "HUNTER", level = 68, zone = "Shadowmoon Valley" },
    }
    for _, traveler in ipairs(demoTravelers) do
        if not charDb.travelers.known[traveler.name] then
            charDb.travelers.known[traveler.name] = {
                class = traveler.class,
                level = traveler.level,
                lastSeen = timestamp,
                lastSeenZone = traveler.zone,
                lastSeenTime = time(),
                firstSeen = timestamp,
            }
        end
    end

    -- Add a sample fellow traveler (addon user)
    if not charDb.travelers.fellows["Arthas"] then
        charDb.travelers.fellows["Arthas"] = {
            class = "PALADIN",
            level = 70,
            lastSeen = timestamp,
            lastSeenZone = "Hellfire Peninsula",
            lastSeenTime = time(),
            firstSeen = timestamp,
            profile = {
                backstory = "Once a noble prince, now seeking redemption.",
                personality = { "Determined", "Brooding" },
            },
        }
        charDb.travelers.known["Arthas"] = charDb.travelers.fellows["Arthas"]
    end

    -- Add sample relationship note
    if not charDb.relationships["Thrall"] then
        charDb.relationships["Thrall"] = {
            note = "Great tank, helped me clear Ramparts. Good guy.",
            addedDate = timestamp,
        }
    end

    -- Add sample minigame stats for testing the Stats tab
    -- Thrall: Good at RPS, plays death roll
    charDb.travelers.known["Thrall"].stats = {
        minigames = {
            rps = { wins = 7, losses = 3, ties = 2, lastPlayed = timestamp },
            deathroll = { wins = 1, losses = 2, ties = 0, highestBet = 50, lastPlayed = timestamp },
        }
    }

    -- Jaina: Even record, plays pong
    charDb.travelers.known["Jaina"].stats = {
        minigames = {
            pong = { wins = 3, losses = 2, highestScore = 5, lastPlayed = timestamp },
            tetris = { wins = 1, losses = 3, highestScore = 2500, lastPlayed = timestamp },
            battleship = { wins = 2, losses = 1, lastPlayed = timestamp },
        }
    }

    -- Sylvanas: Tough opponent, great at words
    charDb.travelers.known["Sylvanas"].stats = {
        minigames = {
            rps = { wins = 6, losses = 2, ties = 0, lastPlayed = timestamp },
            words = { wins = 4, losses = 1, highestScore = 185, lastPlayed = timestamp },
        }
    }

    -- Arthas: Fellow traveler, lots of games
    charDb.travelers.known["Arthas"].stats = {
        minigames = {
            rps = { wins = 4, losses = 4, ties = 2, lastPlayed = timestamp },
            pong = { wins = 2, losses = 1, highestScore = 5, lastPlayed = timestamp },
            tetris = { wins = 3, losses = 2, highestScore = 4200, lastPlayed = timestamp },
            deathroll = { wins = 2, losses = 3, ties = 0, highestBet = 100, lastPlayed = timestamp },
            battleship = { wins = 1, losses = 2, lastPlayed = timestamp },
        }
    }

    -- Add sample badges for testing title system
    charDb.travelers.badges = charDb.travelers.badges or {}

    -- Level badges (unlocked based on demo milestones)
    charDb.travelers.badges["first_steps"] = { unlocked = true, date = timestamp }
    charDb.travelers.badges["adventurer"] = { unlocked = true, date = timestamp }
    charDb.travelers.badges["veteran"] = { unlocked = true, date = timestamp }
    charDb.travelers.badges["hero_of_outland"] = { unlocked = true, date = timestamp }

    -- Attunement badge
    charDb.travelers.badges["karazhan_attuned"] = { unlocked = true, date = timestamp }

    -- Boss badges
    charDb.travelers.badges["prince_slayer"] = { unlocked = true, date = timestamp }

    -- Flying badges
    charDb.travelers.badges["flying_mount"] = { unlocked = true, date = timestamp }

    -- Set demo title on Arthas (fellow traveler)
    if charDb.travelers.fellows["Arthas"] then
        charDb.travelers.fellows["Arthas"].selectedTitle = "Hero"
        charDb.travelers.known["Arthas"].selectedTitle = "Hero"
    end

    -- Invalidate caches
    local journal = self:GetModule("Journal")
    if journal and journal.InvalidateCounts then
        journal:InvalidateCounts()
    end

    self:Print("|cFF00FF00Demo data populated!|r")
    self:Print("Open the journal with /hope to see the sample entries.")
    self:Print("Use /hope reset demo to clear demo data.")
end

--[[
    Clear demo data and reset to clean state
]]
function HopeAddon:ClearDemoData()
    local charDb = self.charDb

    if not charDb._hasDemoData then
        self:Print("No demo data to clear.")
        return
    end

    -- Reset journal entries
    charDb.journal.entries = {}
    charDb.journal.levelMilestones = {}
    charDb.journal.bossKills = {}

    -- Reset stats
    charDb.stats.deaths = { total = 0, byZone = {}, byBoss = {} }
    charDb.stats.playtime = 0
    charDb.stats.questsCompleted = 0
    charDb.stats.creaturesSlain = 0
    charDb.stats.largestHit = 0

    -- Clear demo travelers (keep any real ones that might exist)
    local demoNames = { "Thrall", "Jaina", "Sylvanas", "Arthas" }
    for _, name in ipairs(demoNames) do
        charDb.travelers.known[name] = nil
        charDb.travelers.fellows[name] = nil
        charDb.relationships[name] = nil
    end

    -- Clear demo badges
    local demoBadges = { "first_steps", "adventurer", "veteran", "hero_of_outland",
                         "karazhan_attuned", "prince_slayer", "flying_mount" }
    for _, badgeId in ipairs(demoBadges) do
        if charDb.travelers.badges then
            charDb.travelers.badges[badgeId] = nil
        end
    end

    charDb._hasDemoData = nil

    -- Invalidate caches
    local journal = self:GetModule("Journal")
    if journal and journal.InvalidateCounts then
        journal:InvalidateCounts()
    end

    self:Print("|cFFFF0000Demo data cleared!|r")
    self:Print("Use /hope demo to populate sample data again.")
end

--[[
    Show a test gaming-style reputation bar to demonstrate the new visuals
]]
function HopeAddon:ShowTestBar()
    local Components = self.Components

    -- Close any existing test bar
    if self._testBarFrame then
        self._testBarFrame:Hide()
        self._testBarFrame = nil
    end

    -- Create test frame
    local frame = self:CreateBackdropFrame("Frame", "HopeTestBarFrame", UIParent)
    frame:SetSize(450, 120)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Apply backdrop
    local C = self.Constants
    frame:SetBackdrop(C.BACKDROPS.PARCHMENT_DARK)
    frame:SetBackdropColor(0.1, 0.08, 0.12, 0.95)
    frame:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont(self.assets.fonts.HEADER, 14)
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("|cFFFFD700Gaming-Style Reputation Bar Demo|r")

    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(self.assets.fonts.BODY, 10)
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("Watch it fill up with segment sounds and effects!")
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    -- Create the reputation bar
    local bar = Components:CreateReputationBar(frame, 350, 16, {
        compact = false,
        showStandingBadge = true,
        showTickMarks = true,
        showAnimations = true,
    })
    bar:SetPoint("CENTER", frame, "CENTER", -20, -5)

    -- Set initial state (Honored, 35%)
    bar:SetReputation("Test Faction", 35, 100, 6) -- Honored standing

    -- Instructions
    local instructions = frame:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(self.assets.fonts.SMALL, 9)
    instructions:SetPoint("BOTTOM", frame, "BOTTOM", 0, 25)
    instructions:SetText("Click |cFF00FF00[Fill]|r to animate progress  |  |cFFFF0000[X]|r to close")
    instructions:SetTextColor(0.8, 0.8, 0.8)

    -- Fill button
    local fillBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    fillBtn:SetSize(60, 22)
    fillBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 100, 8)
    fillBtn:SetText("Fill")
    fillBtn._targetValue = 75

    fillBtn:SetScript("OnClick", function(self)
        if bar then
            -- Cycle through different fill amounts
            local newTarget = self._targetValue
            bar:AnimateProgress(newTarget, 1.5)

            -- Cycle: 75 -> 100 -> 25 -> 50 -> 75
            if newTarget >= 100 then
                self._targetValue = 25
            elseif newTarget >= 75 then
                self._targetValue = 100
            elseif newTarget >= 50 then
                self._targetValue = 75
            else
                self._targetValue = 50
            end
        end
    end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        HopeAddon._testBarFrame = nil
    end)

    frame:Show()
    self._testBarFrame = frame

    self:Print("|cFF00FF00Test bar shown!|r Click [Fill] to see the gaming bar animation with segment sounds.")
    self:Print("Type /hope testbar again to close it.")
end
