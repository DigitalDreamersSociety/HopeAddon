--[[
    HopeAddon Directory Module
    Searchable list of encountered addon users (Fellow Travelers)
]]

local Directory = {}
HopeAddon.Directory = Directory

--============================================================
-- SORT OPTIONS
--============================================================
Directory.SORT_OPTIONS = {
    { id = "name_asc", label = "Name (A-Z)" },
    { id = "name_desc", label = "Name (Z-A)" },
    { id = "class", label = "Class" },
    { id = "level_desc", label = "Level (High-Low)" },
    { id = "level_asc", label = "Level (Low-High)" },
    { id = "last_seen", label = "Last Seen" },
}

Directory.currentSort = "last_seen"
Directory.searchFilter = ""

--============================================================
-- DATA ACCESS
--============================================================

--[[
    Get all directory entries (Fellow Travelers only - addon users)
    @return table - Array of player entries
]]
function Directory:GetAllEntries()
    local entries = {}

    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then
        return entries
    end

    -- Only show Fellow Travelers (addon users with RP profiles)
    local fellows = HopeAddon.charDb.travelers.fellows or {}
    for name, data in pairs(fellows) do
        table.insert(entries, self:BuildEntry(name, data, true))
    end

    return entries
end

--[[
    Build a standardized entry from traveler data
    @param name string - Player name
    @param data table - Raw traveler data
    @param isFellow boolean - Whether they're a fellow addon user
    @return table - Standardized entry
]]
function Directory:BuildEntry(name, data, isFellow)
    local Relationships = HopeAddon.Relationships
    local note = Relationships and Relationships:GetNote(name) or nil

    return {
        name = name,
        class = data.class,
        level = data.level,
        lastSeen = data.lastSeen,
        lastSeenZone = data.lastSeenZone,
        lastSeenTime = data.lastSeenTime,
        firstSeen = data.firstSeen,
        isFellow = isFellow,
        selectedColor = data.selectedColor,
        selectedTitle = data.selectedTitle,
        profile = data.profile,
        hasNote = note ~= nil,
        note = note,
        stats = data.stats,
    }
end

--[[
    Get filtered and sorted entries
    @param filter string - Search filter
    @param sortOption string - Sort option ID
    @return table - Array of filtered/sorted entries
]]
function Directory:GetFilteredEntries(filter, sortOption)
    local entries = self:GetAllEntries()
    filter = filter or self.searchFilter
    sortOption = sortOption or self.currentSort

    -- Apply filter
    if filter and filter ~= "" then
        local filtered = {}
        local filterLower = filter:lower()
        for _, entry in ipairs(entries) do
            local nameLower = (entry.name or ""):lower()
            local classLower = (entry.class or ""):lower()
            local zoneLower = (entry.lastSeenZone or ""):lower()

            if nameLower:find(filterLower, 1, true) or
               classLower:find(filterLower, 1, true) or
               zoneLower:find(filterLower, 1, true) then
                table.insert(filtered, entry)
            end
        end
        entries = filtered
    end

    -- Apply sort
    self:SortEntries(entries, sortOption)

    return entries
end

--[[
    Sort entries by the specified option
    @param entries table - Array to sort (in-place)
    @param sortOption string - Sort option ID
]]
function Directory:SortEntries(entries, sortOption)
    if sortOption == "name_asc" then
        table.sort(entries, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    elseif sortOption == "name_desc" then
        table.sort(entries, function(a, b)
            return (a.name or "") > (b.name or "")
        end)
    elseif sortOption == "class" then
        table.sort(entries, function(a, b)
            if (a.class or "") == (b.class or "") then
                return (a.name or "") < (b.name or "")
            end
            return (a.class or "") < (b.class or "")
        end)
    elseif sortOption == "level_desc" then
        table.sort(entries, function(a, b)
            if (a.level or 0) == (b.level or 0) then
                return (a.name or "") < (b.name or "")
            end
            return (a.level or 0) > (b.level or 0)
        end)
    elseif sortOption == "level_asc" then
        table.sort(entries, function(a, b)
            if (a.level or 0) == (b.level or 0) then
                return (a.name or "") < (b.name or "")
            end
            return (a.level or 0) < (b.level or 0)
        end)
    elseif sortOption == "last_seen" then
        table.sort(entries, function(a, b)
            -- Sort by lastSeenTime (timestamp) if available, else lastSeen (date string)
            local aTime = a.lastSeenTime or 0
            local bTime = b.lastSeenTime or 0
            if aTime ~= bTime then
                return aTime > bTime
            end
            return (a.lastSeen or "") > (b.lastSeen or "")
        end)
    end
end

--[[
    Get entry count (optimized - doesn't build full entries)
    Now only counts Fellow Travelers (addon users)
    @return number
]]
function Directory:GetEntryCount()
    local count = 0
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then
        return 0
    end

    local fellows = HopeAddon.charDb.travelers.fellows or {}
    for _ in pairs(fellows) do
        count = count + 1
    end

    return count
end

--[[
    Get fellow count (addon users only)
    @return number
]]
function Directory:GetFellowCount()
    local count = 0
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellows then
        for _ in pairs(HopeAddon.charDb.travelers.fellows) do
            count = count + 1
        end
    end
    return count
end

--[[
    Get a specific entry by name
    @param name string - Player name
    @return table|nil - Entry or nil
]]
function Directory:GetEntry(name)
    local entries = self:GetAllEntries()
    for _, entry in ipairs(entries) do
        if entry.name == name then
            return entry
        end
    end
    return nil
end

--[[
    Check if player is online (in current party/raid/guild zone)
    Note: This is a best-effort check, may not be accurate
    @param name string - Player name
    @return boolean
]]
function Directory:IsPlayerNearby(name)
    -- Check party/raid
    local numMembers = GetNumGroupMembers()
    if numMembers > 0 then
        local isRaid = IsInRaid()
        local prefix = isRaid and "raid" or "party"
        local maxIndex = isRaid and 40 or 4

        for i = 1, maxIndex do
            local unit = prefix .. i
            if UnitExists(unit) then
                local unitName = UnitName(unit)
                if unitName == name then
                    return true
                end
            end
        end
    end

    return false
end

--============================================================
-- STATISTICS
--============================================================

--[[
    Get directory statistics (Fellow Travelers only)
    @return table - { fellows, byClass, recentCount }
]]
function Directory:GetStats()
    local entries = self:GetAllEntries()
    local stats = {
        fellows = #entries,  -- All entries are now Fellow Travelers
        byClass = {},
        recentCount = 0, -- Seen in last 7 days
    }

    local sevenDaysAgo = time() - (7 * 24 * 60 * 60)

    for _, entry in ipairs(entries) do
        if entry.class then
            stats.byClass[entry.class] = (stats.byClass[entry.class] or 0) + 1
        end

        if entry.lastSeenTime and entry.lastSeenTime >= sevenDaysAgo then
            stats.recentCount = stats.recentCount + 1
        end
    end

    return stats
end

--============================================================
-- UI HELPERS
--============================================================

--[[
    Format an entry for display
    @param entry table - Directory entry
    @return table - { name, classColor, levelText, locationText, statusText }
]]
function Directory:FormatEntryForDisplay(entry)
    local classColor = HopeAddon:GetClassColor(entry.class)
    local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

    -- Use tier color if available
    if entry.selectedColor then
        colorHex = entry.selectedColor
    end

    local levelText = entry.level and ("Level " .. entry.level) or "Unknown Level"
    local locationText = entry.lastSeenZone or "Unknown Location"
    local statusText = entry.isFellow and "|cFF00FF00[Fellow Traveler]|r" or ""

    return {
        name = entry.name,
        coloredName = "|cFF" .. colorHex .. entry.name .. "|r",
        classColor = classColor,
        colorHex = colorHex,
        levelText = levelText,
        locationText = locationText,
        statusText = statusText,
        lastSeenText = entry.lastSeen or "Never",
        hasNote = entry.hasNote,
    }
end

-- Class icon lookup (cached at module level)
local CLASS_ICONS = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
    PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
    ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
    PRIEST = "Interface\\Icons\\ClassIcon_Priest",
    SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
    MAGE = "Interface\\Icons\\ClassIcon_Mage",
    WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    DRUID = "Interface\\Icons\\ClassIcon_Druid",
}
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

--[[
    Get class icon for display
    @param class string - Class name
    @return string - Icon path
]]
function Directory:GetClassIcon(class)
    return CLASS_ICONS[class] or DEFAULT_ICON
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function Directory:OnInitialize()
    -- Nothing special needed
end

function Directory:OnEnable()
    HopeAddon:Debug("Directory module enabled")
end

function Directory:OnDisable()
    -- Cleanup if needed
end

-- Register with addon
HopeAddon:RegisterModule("Directory", Directory)
HopeAddon:Debug("Directory module loaded")
