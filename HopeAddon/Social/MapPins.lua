--[[
    HopeAddon MapPins Module
    Show fellow addon users on minimap and world map
]]

local MapPins = {}
HopeAddon.MapPins = MapPins

--============================================================
-- CONSTANTS
--============================================================
local PIN_UPDATE_INTERVAL = 5  -- Seconds between pin updates
local LOCATION_STALE_TIME = 300  -- 5 minutes - consider location stale
local MAX_PINS = 50  -- Maximum pins to display at once

-- RP Status colors (matching NameplateColors module)
local RP_STATUS_COLORS = {
    IC = { r = 0.2, g = 1.0, b = 0.2 },      -- Bright Green - In Character
    OOC = { r = 0.0, g = 0.75, b = 1.0 },    -- Sky Blue - Out of Character
    LF_RP = { r = 1.0, g = 0.2, b = 0.8 },   -- Hot Pink - Looking for RP
    DEFAULT = { r = 0.0, g = 0.75, b = 1.0 }, -- Default to OOC (Sky Blue)
}

-- Star icon texture for Fellow Travelers
local FELLOW_PIN_ICON = "Interface\\MINIMAP\\TRACKING\\BattleMaster"  -- Sword star icon
local FELLOW_PIN_SIZE = 20  -- Slightly larger for visibility

--============================================================
-- STATE
--============================================================
MapPins.pins = {}  -- Active pin frames
MapPins.pinPool = {}  -- Reusable pin frames
MapPins.lastUpdate = 0
MapPins.enabled = true
MapPins.eventFrame = nil
MapPins.updateTicker = nil

--============================================================
-- PIN HANDLERS (module scope for efficiency)
--============================================================

local function PinOnEnter(self)
    if self.playerName then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

        -- Show highest quality icon if available
        if HopeAddon.TravelerIcons then
            local iconInfo = HopeAddon.TravelerIcons:GetHighestQualityIcon(self.playerName)
            if iconInfo and iconInfo.data and iconInfo.data.icon then
                GameTooltip:AddTexture(iconInfo.data.icon)
            else
                -- Default Fellow Traveler icon
                GameTooltip:AddTexture("Interface\\Icons\\INV_Misc_GroupLooking")
            end
        end

        GameTooltip:AddLine(self.playerName, 1, 1, 1)
        if self.playerClass then
            local classColor = HopeAddon:GetClassColor(self.playerClass)
            GameTooltip:AddLine(self.playerClass, classColor.r, classColor.g, classColor.b)
        end
        if self.playerLevel then
            GameTooltip:AddLine("Level " .. self.playerLevel, 0.8, 0.8, 0.8)
        end
        GameTooltip:AddLine("|cFF00FF00[Fellow Traveler]|r", 0, 1, 0)
        GameTooltip:Show()
    end
end

local function PinOnLeave(self)
    GameTooltip:Hide()
end

--============================================================
-- PIN CREATION
--============================================================

--[[
    Create a new minimap pin frame
    @return Frame - Pin frame
]]
function MapPins:CreatePin()
    local pin = CreateFrame("Frame", nil, Minimap)
    pin:SetSize(FELLOW_PIN_SIZE, FELLOW_PIN_SIZE)
    pin:SetFrameStrata("MEDIUM")
    pin:SetFrameLevel(5)

    -- Icon texture - bright star icon instead of generic dot
    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints()
    pin.icon:SetTexture(FELLOW_PIN_ICON)

    -- Glow effect for extra visibility
    pin.glow = pin:CreateTexture(nil, "BACKGROUND")
    pin.glow:SetSize(FELLOW_PIN_SIZE + 8, FELLOW_PIN_SIZE + 8)
    pin.glow:SetPoint("CENTER")
    pin.glow:SetTexture("Interface\\GLUES\\MODELS\\UI_BLOODELF\\GenericGlow64")
    pin.glow:SetBlendMode("ADD")
    pin.glow:SetAlpha(0.5)

    -- Highlight on mouseover (handlers defined at module scope)
    pin:EnableMouse(true)
    pin:SetScript("OnEnter", PinOnEnter)
    pin:SetScript("OnLeave", PinOnLeave)

    pin:Hide()
    return pin
end

--[[
    Acquire a pin from the pool or create a new one
    @return Frame - Pin frame
]]
function MapPins:AcquirePin()
    local pin = table.remove(self.pinPool)
    if not pin then
        pin = self:CreatePin()
    end
    return pin
end

--[[
    Release a pin back to the pool
    @param pin Frame - Pin frame
]]
function MapPins:ReleasePin(pin)
    pin:Hide()
    pin:ClearAllPoints()
    pin.playerName = nil
    pin.playerClass = nil
    pin.playerLevel = nil
    pin.playerStatus = nil
    pin.x = nil
    pin.y = nil
    table.insert(self.pinPool, pin)
end

--[[
    Release all active pins
]]
function MapPins:ReleaseAllPins()
    for _, pin in pairs(self.pins) do
        self:ReleasePin(pin)
    end
    self.pins = {}
end

--============================================================
-- COORDINATE HANDLING
--============================================================

--[[
    Convert zone coordinates to minimap position
    Note: TBC API for minimap positioning is limited
    This uses a simplified approach based on player distance
    @param x number - Zone X coordinate (0-1)
    @param y number - Zone Y coordinate (0-1)
    @param playerX number - Player X coordinate
    @param playerY number - Player Y coordinate
    @return number, number - Minimap position offset
]]
function MapPins:ZoneToMinimapCoords(x, y, playerX, playerY)
    if not x or not y or not playerX or not playerY then
        return nil, nil
    end

    -- Calculate offset from player
    local dx = x - playerX
    local dy = y - playerY

    -- Get minimap radius (approximate)
    local minimapRadius = Minimap:GetWidth() / 2

    -- Scale factor (this varies by zone, using approximate)
    local scale = minimapRadius / 0.025  -- Rough scale for nearby range

    local mapX = dx * scale
    local mapY = dy * scale

    -- Clamp to minimap bounds
    local distance = math.sqrt(mapX * mapX + mapY * mapY)
    if distance > minimapRadius - 8 then
        local factor = (minimapRadius - 8) / distance
        mapX = mapX * factor
        mapY = mapY * factor
    end

    return mapX, -mapY  -- Y is inverted
end

--[[
    Get the RP status color for a Fellow Traveler
    @param fellowName string - The Fellow's name
    @return table - RGB color table { r, g, b }
]]
function MapPins:GetFellowStatusColor(fellowName)
    if not HopeAddon.FellowTravelers then
        return RP_STATUS_COLORS.DEFAULT
    end

    local fellow = HopeAddon.FellowTravelers:GetFellow(fellowName)
    if not fellow then
        return RP_STATUS_COLORS.DEFAULT
    end

    -- Get RP status from profile
    local status = nil
    if fellow.profile and fellow.profile.status then
        status = fellow.profile.status
    end

    -- Return appropriate color
    if status and RP_STATUS_COLORS[status] then
        return RP_STATUS_COLORS[status]
    end

    return RP_STATUS_COLORS.DEFAULT
end

--[[
    Check if pin coloring is enabled
    @return boolean
]]
function MapPins:IsPinColoringEnabled()
    local settings = HopeAddon.charDb and HopeAddon.charDb.travelers
        and HopeAddon.charDb.travelers.fellowSettings

    if settings and settings.colorMinimapPins == false then
        return false
    end

    return true
end

--============================================================
-- LOCATION DATA
--============================================================

-- Reusable result table to reduce garbage
local nearbyFellowsCache = {}

--[[
    Get fellow travelers with recent location data
    @return table - Array of { name, x, y, zone, class, level, lastUpdate }
]]
function MapPins:GetNearbyFellows()
    -- Reuse and wipe table to reduce garbage
    local result = nearbyFellowsCache
    wipe(result)

    local currentZone = GetZoneText()
    local now = GetTime()

    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then
        return result
    end

    local fellows = HopeAddon.charDb.travelers.fellows or {}

    for name, data in pairs(fellows) do
        -- Only show fellows in the same zone with recent location
        if data.lastSeenZone == currentZone then
            local locationTime = data.locationTime or 0
            if now - locationTime < LOCATION_STALE_TIME then
                if data.x and data.y then
                    table.insert(result, {
                        name = name,
                        x = data.x,
                        y = data.y,
                        zone = data.lastSeenZone,
                        class = data.class,
                        level = data.level,
                        lastUpdate = locationTime,
                    })
                end
            end
        end
    end

    -- Limit to MAX_PINS efficiently
    local count = #result
    if count > MAX_PINS then
        -- Sort by most recent
        table.sort(result, function(a, b)
            return a.lastUpdate > b.lastUpdate
        end)
        -- Truncate by setting length (more efficient than repeated remove)
        for i = MAX_PINS + 1, count do
            result[i] = nil
        end
    end

    return result
end

--[[
    Update a fellow's location data
    Called from FellowTravelers when receiving location updates
    @param name string - Player name
    @param x number - X coordinate (0-1)
    @param y number - Y coordinate (0-1)
    @param zone string - Zone name
]]
function MapPins:UpdateFellowLocation(name, x, y, zone)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end

    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows or not fellows[name] then return end

    fellows[name].x = x
    fellows[name].y = y
    fellows[name].lastSeenZone = zone
    fellows[name].locationTime = GetTime()

    HopeAddon:Debug("Updated location for", name, ":", x, y, zone)
end

--[[
    Get the player's current location for sharing
    TBC-compatible: C_Map doesn't exist in TBC Classic
    @return number, number, string - x, y, zone or nil
]]
function MapPins:GetPlayerLocation()
    -- TBC-compatible check: verify all required C_Map functions exist
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                return pos.x, pos.y, GetZoneText()
            end
        end
    end

    -- TBC fallback - coordinates not available without WorldMapFrame open
    -- Return zone name only
    return nil, nil, GetZoneText()
end

--============================================================
-- PIN UPDATES
--============================================================

--[[
    Update all minimap pins
]]
function MapPins:UpdatePins()
    if not self.enabled then
        self:ReleaseAllPins()
        return
    end

    local now = GetTime()
    if now - self.lastUpdate < PIN_UPDATE_INTERVAL then
        return
    end
    self.lastUpdate = now

    -- Get player position
    local playerX, playerY, playerZone = self:GetPlayerLocation()

    -- Get nearby fellows
    local fellows = self:GetNearbyFellows()

    -- Release existing pins
    self:ReleaseAllPins()

    -- Cache function reference for loop efficiency
    local GetClassColor = HopeAddon.GetClassColor

    -- Check if RP status coloring is enabled
    local useStatusColors = self:IsPinColoringEnabled()

    -- Create new pins
    for _, fellow in ipairs(fellows) do
        if playerX and playerY then
            local mapX, mapY = self:ZoneToMinimapCoords(fellow.x, fellow.y, playerX, playerY)
            if mapX and mapY then
                local pin = self:AcquirePin()
                pin.playerName = fellow.name
                pin.playerClass = fellow.class
                pin.playerLevel = fellow.level
                pin.x = fellow.x
                pin.y = fellow.y

                -- Color by RP status (bright neon colors)
                local color
                if useStatusColors then
                    color = self:GetFellowStatusColor(fellow.name)
                else
                    -- Fallback to class color if status coloring disabled
                    if fellow.class then
                        color = GetClassColor(HopeAddon, fellow.class)
                    else
                        color = RP_STATUS_COLORS.DEFAULT
                    end
                end

                pin.icon:SetVertexColor(color.r, color.g, color.b)

                -- Glow matches icon color but more saturated
                if pin.glow then
                    pin.glow:SetVertexColor(color.r, color.g, color.b)
                end

                -- Position on minimap
                pin:SetPoint("CENTER", Minimap, "CENTER", mapX, mapY)
                pin:Show()

                self.pins[fellow.name] = pin
            end
        end
    end
end

--============================================================
-- SETTINGS
--============================================================

--[[
    Enable or disable map pins
    @param enabled boolean
]]
function MapPins:SetEnabled(enabled)
    self.enabled = enabled

    if not enabled then
        self:ReleaseAllPins()
    else
        self:UpdatePins()
    end

    -- Save preference
    if HopeAddon.charDb and HopeAddon.charDb.travelers then
        HopeAddon.charDb.travelers.fellowSettings = HopeAddon.charDb.travelers.fellowSettings or {}
        HopeAddon.charDb.travelers.fellowSettings.showMapPins = enabled
    end
end

--[[
    Toggle pin coloring on/off
    @return boolean - New enabled state
]]
function MapPins:TogglePinColoring()
    local settings = HopeAddon.charDb and HopeAddon.charDb.travelers
        and HopeAddon.charDb.travelers.fellowSettings

    if not settings then return true end

    local newState = not (settings.colorMinimapPins ~= false)
    settings.colorMinimapPins = newState

    -- Force pin update to apply new colors
    self:UpdatePins()

    return newState
end

--[[
    Check if map pins are enabled
    @return boolean
]]
function MapPins:IsEnabled()
    return self.enabled
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function MapPins:OnInitialize()
    -- Load setting
    if HopeAddon.charDb and HopeAddon.charDb.travelers and
       HopeAddon.charDb.travelers.fellowSettings then
        self.enabled = HopeAddon.charDb.travelers.fellowSettings.showMapPins ~= false
    end
end

function MapPins:OnEnable()
    -- Create update frame
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:RegisterEvent("ZONE_CHANGED")
    self.eventFrame:SetScript("OnEvent", function(_, event)
        if event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
            self:UpdatePins()
        end
    end)

    -- Periodic update
    self.updateTicker = HopeAddon.Timer:NewTicker(PIN_UPDATE_INTERVAL, function()
        MapPins:UpdatePins()
    end)

    -- Initial update
    self:UpdatePins()

    HopeAddon:Debug("MapPins module enabled")
end

function MapPins:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    if self.updateTicker then
        self.updateTicker:Cancel()
        self.updateTicker = nil
    end

    self:ReleaseAllPins()
end

-- Register with addon
HopeAddon:RegisterModule("MapPins", MapPins)
HopeAddon:Debug("MapPins module loaded")
