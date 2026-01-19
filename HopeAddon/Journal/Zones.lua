--[[
    HopeAddon Zones Module
    Zone discovery tracking and management
]]

local Zones = {}
HopeAddon.Zones = Zones

--[[
    Module lifecycle: OnInitialize
]]
function Zones:OnInitialize()
end

--[[
    Module lifecycle: OnEnable
]]
function Zones:OnEnable()
    -- Register for zone change events to check party zone icons
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
            if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
                -- Delay slightly to ensure zone data is available
                HopeAddon.Timer:After(1, function()
                    Zones:CheckCurrentZone()
                    Zones:CheckZoneWithParty()
                end)
            end
        end)
    end
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

--[[
    Module lifecycle: OnDisable
]]
function Zones:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
    end
end

-- TBC Outland zones
Zones.TBC_ZONES = {
    "Hellfire Peninsula",
    "Zangarmarsh",
    "Terokkar Forest",
    "Nagrand",
    "Blade's Edge Mountains",
    "Netherstorm",
    "Shadowmoon Valley",
    "Shattrath City",
}

-- Zone categories
Zones.CATEGORIES = {
    STARTING = "starting",
    CLASSIC = "classic",
    TBC = "tbc",
    CITY = "city",
    DUNGEON = "dungeon",
    RAID = "raid",
}

--[[
    Check if a zone is trackable
    @param zoneName string - Zone name
    @return boolean
]]
function Zones:IsTrackable(zoneName)
    return HopeAddon.Constants.ZONE_DISCOVERIES[zoneName] ~= nil
end

--[[
    Check if a zone is a TBC zone
    @param zoneName string - Zone name
    @return boolean
]]
function Zones:IsTBCZone(zoneName)
    for _, tbcZone in ipairs(self.TBC_ZONES) do
        if tbcZone == zoneName then
            return true
        end
    end
    return false
end

--[[
    Get zone data
    @param zoneName string - Zone name
    @return table|nil - Zone data or nil
]]
function Zones:GetZoneData(zoneName)
    return HopeAddon.Constants.ZONE_DISCOVERIES[zoneName]
end

--[[
    Check if a zone has been discovered
    @param zoneName string - Zone name
    @return boolean
]]
function Zones:IsDiscovered(zoneName)
    return HopeAddon.charDb.journal.zoneDiscoveries[zoneName] ~= nil
end

--[[
    Record a zone discovery
    @param zoneName string - Zone name
    @return table|nil - The created entry or nil
]]
function Zones:RecordDiscovery(zoneName)
    local zoneData = self:GetZoneData(zoneName)
    if not zoneData then
        HopeAddon:Debug("No zone data for", zoneName)
        return nil
    end

    -- Check if already discovered
    if self:IsDiscovered(zoneName) then
        HopeAddon:Debug("Zone already discovered:", zoneName)
        return HopeAddon.charDb.journal.zoneDiscoveries[zoneName]
    end

    -- Create entry
    local entry = {
        type = "zone_discovery",
        zone = zoneName,
        title = zoneData.title,
        flavor = zoneData.flavor,
        icon = "Interface\\Icons\\" .. zoneData.icon,
        levelRange = zoneData.levelRange,
        level = UnitLevel("player"),
        timestamp = HopeAddon:GetTimestamp(),
        firstVisit = HopeAddon:GetDate(),
    }

    -- Save
    HopeAddon.charDb.journal.zoneDiscoveries[zoneName] = entry
    table.insert(HopeAddon.charDb.journal.entries, entry)

    HopeAddon:Debug("Recorded zone discovery:", zoneData.title)

    return entry
end

--[[
    Get all discovered zones
    @return table - Array of zone entries
]]
function Zones:GetDiscoveredZones()
    local discovered = {}

    for zoneName, entry in pairs(HopeAddon.charDb.journal.zoneDiscoveries) do
        entry.zoneName = zoneName
        table.insert(discovered, entry)
    end

    -- Sort by discovery date
    table.sort(discovered, function(a, b)
        return (a.timestamp or "") < (b.timestamp or "")
    end)

    return discovered
end

--[[
    Get TBC zone discovery progress
    @return number, number - Discovered count, total count
]]
function Zones:GetTBCProgress()
    local discovered = 0

    for _, zoneName in ipairs(self.TBC_ZONES) do
        if self:IsDiscovered(zoneName) then
            discovered = discovered + 1
        end
    end

    return discovered, #self.TBC_ZONES
end

--[[
    Get zone theme colors
    @param zoneName string - Zone name
    @return table - Theme colors {primary, secondary, accent}
]]
function Zones:GetZoneTheme(zoneName)
    return HopeAddon.Glow.zoneThemes[zoneName] or {
        primary = "GOLD_BRIGHT",
        secondary = "GREY",
        accent = "WHITE",
    }
end

--[[
    Get recommended level range for a zone
    @param zoneName string - Zone name
    @return string - Level range string
]]
function Zones:GetLevelRange(zoneName)
    local zoneData = self:GetZoneData(zoneName)
    if zoneData and zoneData.levelRange then
        return zoneData.levelRange
    end
    return "Unknown"
end

--[[
    Check current zone and record if new
    Called automatically on zone changes
]]
function Zones:CheckCurrentZone()
    local zoneName = GetZoneText()

    if self:IsTrackable(zoneName) and not self:IsDiscovered(zoneName) then
        local entry = self:RecordDiscovery(zoneName)
        if entry then
            -- Notify Badges module of zone discovery
            if HopeAddon.Badges then
                HopeAddon.Badges:OnZoneDiscovered(zoneName)
            end
            -- Notify TravelerIcons if in a group
            if HopeAddon.TravelerIcons and HopeAddon.FellowTravelers and IsInGroup() then
                local party = HopeAddon.FellowTravelers:GetPartyMembers()
                if #party > 0 then
                    HopeAddon.TravelerIcons:OnZoneDiscovery(zoneName, party)
                end
            end
            return entry
        end
    end

    return nil
end

--[[
    Notify TravelerIcons when entering a known zone while grouped
    This handles the case where we enter a zone we've already discovered,
    but we're with new party members who haven't earned the zone icon with us
]]
function Zones:CheckZoneWithParty()
    local zoneName = GetZoneText()

    if not HopeAddon.TravelerIcons or not HopeAddon.FellowTravelers then return end
    if not IsInGroup() then return end

    local party = HopeAddon.FellowTravelers:GetPartyMembers()
    if #party > 0 then
        HopeAddon.TravelerIcons:OnZoneDiscovery(zoneName, party)
    end
end

--[[
    Get zone discovery statistics
    @return table - Stats table
]]
function Zones:GetStats()
    local tbcDiscovered, tbcTotal = self:GetTBCProgress()

    local totalDiscovered = 0
    for _ in pairs(HopeAddon.charDb.journal.zoneDiscoveries) do
        totalDiscovered = totalDiscovered + 1
    end

    return {
        tbcDiscovered = tbcDiscovered,
        tbcTotal = tbcTotal,
        tbcPercent = tbcTotal > 0 and math.floor((tbcDiscovered / tbcTotal) * 100) or 0,
        totalDiscovered = totalDiscovered,
    }
end

--[[
    Get undiscovered TBC zones
    @return table - Array of zone names
]]
function Zones:GetUndiscoveredTBCZones()
    local undiscovered = {}

    for _, zoneName in ipairs(self.TBC_ZONES) do
        if not self:IsDiscovered(zoneName) then
            table.insert(undiscovered, zoneName)
        end
    end

    return undiscovered
end

-- Register with addon
HopeAddon:RegisterModule("Zones", Zones)
if HopeAddon.Debug then
    HopeAddon:Debug("Zones module loaded")
end
