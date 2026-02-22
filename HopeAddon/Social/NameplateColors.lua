--[[
    HopeAddon NameplateColors Module
    Colors friendly nameplates for Fellow Travelers based on RP status

    Colors:
    - IC (In Character): Bright Green (#33FF33)
    - OOC (Out of Character): Sky Blue (#00BFFF)
    - LF_RP (Looking for RP): Hot Pink (#FF33CC)
]]

local NameplateColors = {}
HopeAddon.NameplateColors = NameplateColors
HopeAddon:RegisterModule("NameplateColors", NameplateColors)

--============================================================
-- CONSTANTS
--============================================================

-- RP Status colors - use centralized constants
local function GetRPStatusColors()
    return HopeAddon.Constants.RP_STATUS_COLORS
end

-- Update interval (250ms is responsive but less CPU intensive)
local UPDATE_INTERVAL = 0.25

-- Cache for nameplate name texts to avoid repeated GetText() calls
local nameplateCache = {}

-- Fix #1: Reusable tables for WorldFrame:GetChildren() and GetRegions()
-- Avoids creating new tables every 0.1 seconds
local childrenCache = {}
local regionsCache = {}

--============================================================
-- STATE
--============================================================

NameplateColors.enabled = true
NameplateColors.updateFrame = nil
NameplateColors.timer = 0
NameplateColors.disabledByConflict = nil

--============================================================
-- ADDON CONFLICT DETECTION
--============================================================

-- Known nameplate addon detection
local CONFLICTING_NAMEPLATE_ADDONS = {
    "ElvUI",            -- ElvUI has complete nameplate system
    "TidyPlates",       -- Tidy Plates
    "TidyPlatesThreat", -- Threat Plates
    "ThreatPlates",     -- Threat Plates standalone
    "Plater",           -- Plater Nameplates
    "Kui_Nameplates",   -- KuiNameplates
    "NeatPlates",       -- NeatPlates
    -- UI suites that replace nameplates
    "Tukui",            -- Tukui has nameplate module
    "ShadowedUnitFrames", -- SUF has nameplate options
    "Altz_UI",          -- Altz UI suite
    "RealUI",           -- RealUI suite
    "bdNameplates",     -- bdUI nameplates
}

local function HasConflictingNameplateAddon()
    for _, addonName in ipairs(CONFLICTING_NAMEPLATE_ADDONS) do
        local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
        if loaded(addonName) then
            return addonName
        end
    end
    return nil
end

--============================================================
-- HELPER FUNCTIONS
--============================================================

--[[
    Get the color for a Fellow Traveler based on their RP status
    @param fellowName string - The Fellow's name
    @return table - RGB color table { r, g, b }
]]
local function GetFellowColor(fellowName)
    local colors = GetRPStatusColors()
    if not HopeAddon.FellowTravelers then
        return colors.DEFAULT
    end

    local fellow = HopeAddon.FellowTravelers:GetFellow(fellowName)
    if not fellow then
        return colors.DEFAULT
    end

    -- Get RP status from profile
    local status = nil
    if fellow.profile and fellow.profile.status then
        status = fellow.profile.status
    end

    -- Return appropriate color
    if status and colors[status] then
        return colors[status]
    end

    return colors.DEFAULT
end

--[[
    Check if nameplate coloring is enabled
    @return boolean
]]
local function IsEnabled()
    if not NameplateColors.enabled then return false end

    local settings = HopeAddon.charDb and HopeAddon.charDb.travelers
        and HopeAddon.charDb.travelers.fellowSettings

    if settings and settings.colorNameplates == false then
        return false
    end

    return true
end

--[[
    Extract player name from nameplate text
    Handles server names like "Thrall-Proudmoore"
    @param text string - The nameplate text
    @return string - Just the player name
]]
local function ExtractPlayerName(text)
    if not text then return nil end
    -- Remove server suffix if present
    local name = text:match("^([^%-]+)")
    return name or text
end

--============================================================
-- NAMEPLATE SCANNING
--============================================================

--[[
    Scan all visible nameplates and color Fellow Travelers
    Uses TBC Classic nameplate naming convention
]]
local function ScanNameplates()
    if not IsEnabled() then return end
    if not HopeAddon.FellowTravelers then return end

    -- TBC Classic uses WorldFrame children for nameplates
    -- We need to iterate through children of WorldFrame
    -- Fix #1: Reuse childrenCache table to avoid creating new tables every 0.1s
    wipe(childrenCache)
    for i = 1, select("#", WorldFrame:GetChildren()) do
        childrenCache[i] = select(i, WorldFrame:GetChildren())
    end

    for _, frame in ipairs(childrenCache) do
        -- Check if this looks like a nameplate
        -- TBC nameplates have specific regions we can check
        if frame:IsVisible() and frame:GetName() == nil then
            -- Try to find the name region
            -- Fix #1: Reuse regionsCache table to avoid creating new tables per nameplate
            wipe(regionsCache)
            for i = 1, select("#", frame:GetRegions()) do
                regionsCache[i] = select(i, frame:GetRegions())
            end
            for _, region in ipairs(regionsCache) do
                if region:GetObjectType() == "FontString" then
                    local text = region:GetText()
                    if text and text ~= "" then
                        local playerName = ExtractPlayerName(text)

                        -- Check if this is a Fellow Traveler
                        if playerName and HopeAddon.FellowTravelers:IsFellow(playerName) then
                            local color = GetFellowColor(playerName)
                            region:SetTextColor(color.r, color.g, color.b)
                        end
                    end
                end
            end
        end
    end

    -- Also try the numbered nameplate approach (some addons use this)
    for i = 1, 40 do
        local nameplate = _G["NamePlate" .. i]
        if nameplate and nameplate:IsVisible() then
            -- Try common nameplate structures
            local nameText = nameplate.name or nameplate.Name
            if nameText and nameText.GetText then
                local text = nameText:GetText()
                if text then
                    local playerName = ExtractPlayerName(text)

                    if playerName and HopeAddon.FellowTravelers:IsFellow(playerName) then
                        local color = GetFellowColor(playerName)
                        nameText:SetTextColor(color.r, color.g, color.b)
                    end
                end
            end
        end
    end
end

--============================================================
-- UPDATE HANDLER
--============================================================

local function OnUpdate(self, elapsed)
    if not IsEnabled() then return end

    NameplateColors.timer = NameplateColors.timer + elapsed

    if NameplateColors.timer >= UPDATE_INTERVAL then
        NameplateColors.timer = 0
        ScanNameplates()
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Toggle nameplate coloring on/off
    @return boolean - New enabled state
]]
function NameplateColors:Toggle()
    self.enabled = not self.enabled

    -- Update setting
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellowSettings then
        HopeAddon.charDb.travelers.fellowSettings.colorNameplates = self.enabled
    end

    return self.enabled
end

--[[
    Enable nameplate coloring
]]
function NameplateColors:Enable()
    self.enabled = true
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellowSettings then
        HopeAddon.charDb.travelers.fellowSettings.colorNameplates = true
    end
end

--[[
    Disable nameplate coloring
]]
function NameplateColors:Disable()
    self.enabled = false
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellowSettings then
        HopeAddon.charDb.travelers.fellowSettings.colorNameplates = false
    end
end

--[[
    Check if nameplate coloring is currently enabled
    @return boolean
]]
function NameplateColors:IsEnabled()
    return IsEnabled()
end

--[[
    Get the color for a specific RP status
    @param status string - "IC", "OOC", or "LF_RP"
    @return table - RGB color table
]]
function NameplateColors:GetStatusColor(status)
    local colors = GetRPStatusColors()
    return colors[status] or colors.DEFAULT
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function NameplateColors:OnInitialize()
    -- Nothing to initialize
end

function NameplateColors:OnEnable()
    -- Check for conflicting nameplate addons FIRST
    local conflictAddon = HasConflictingNameplateAddon()
    if conflictAddon then
        HopeAddon:Debug("NameplateColors: Disabled due to conflict with " .. conflictAddon)
        self.enabled = false
        self.disabledByConflict = conflictAddon
        -- Inform user why nameplate coloring is disabled
        C_Timer.After(3, function()
            if self.disabledByConflict then
                HopeAddon:Print("Fellow Traveler nameplate coloring disabled - " ..
                    self.disabledByConflict .. " detected")
            end
        end)
        return  -- Don't create update frame
    end

    -- Load setting
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellowSettings then
        local setting = HopeAddon.charDb.travelers.fellowSettings.colorNameplates
        if setting ~= nil then
            self.enabled = setting
        end
    end

    -- Create update frame
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
        self.updateFrame:SetScript("OnUpdate", OnUpdate)
    end

    self.updateFrame:Show()

    HopeAddon:Debug("NameplateColors module enabled, coloring:", self.enabled and "ON" or "OFF")
end

function NameplateColors:OnDisable()
    if self.updateFrame then
        self.updateFrame:SetScript("OnUpdate", nil)
        self.updateFrame:Hide()
    end

    HopeAddon:Debug("NameplateColors module disabled")
end
