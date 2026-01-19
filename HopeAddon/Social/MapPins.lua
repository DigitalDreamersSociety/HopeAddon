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
    pin:SetSize(16, 16)
    pin:SetFrameStrata("MEDIUM")
    pin:SetFrameLevel(5)

    -- Icon texture
    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints()
    pin.icon:SetTexture("Interface\\Minimap\\PartyRaidBlips")
    pin.icon:SetTexCoord(0.5, 0.625, 0, 0.25)  -- Green dot by default

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

                -- Color by class
                if fellow.class then
                    local classColor = GetClassColor(HopeAddon, fellow.class)
                    pin.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
                else
                    pin.icon:SetVertexColor(0, 1, 0)  -- Default green
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
