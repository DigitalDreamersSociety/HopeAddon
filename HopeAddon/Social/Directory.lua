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
    { id = "ilvl_desc", label = "iLevel" },
    { id = "gearscore_desc", label = "Gear Score" },
    { id = "level_desc", label = "Level" },
    { id = "veteran", label = "Veteran" },
    { id = "last_seen", label = "Recently Active" },
    { id = "name_asc", label = "Name (A-Z)" },
    { id = "class", label = "By Class" },
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

    -- Insert self-entry (live data, not from fellows table)
    local selfEntry = self:BuildSelfEntry()
    if selfEntry then
        table.insert(entries, selfEntry)
    end

    -- Only show Fellow Travelers (addon users with RP profiles)
    local fellows = HopeAddon.charDb.travelers.fellows or {}
    for name, data in pairs(fellows) do
        table.insert(entries, self:BuildEntry(name, data, true))
    end

    return entries
end

--[[
    Build a self-entry for the local player using live data
    @return table|nil - Standardized entry with isSelf=true
]]
function Directory:BuildSelfEntry()
    local playerName = UnitName("player")
    if not playerName then return nil end

    local _, classToken = UnitClass("player")
    local level = UnitLevel("player")
    local gearScore, avgILvl = HopeAddon:GetGearScore()
    local zone = GetZoneText() or "Unknown"

    local Badges = HopeAddon.Badges
    local selectedColor = Badges and Badges:GetSelectedColor() or nil
    local selectedTitle = Badges and Badges:GetSelectedTitle() or nil

    local profile = HopeAddon.charDb and HopeAddon.charDb.travelers
        and HopeAddon.charDb.travelers.myProfile or nil

    local Relationships = HopeAddon.Relationships
    local note = Relationships and Relationships:GetNote(playerName) or nil

    return {
        name = playerName,
        class = classToken,
        level = level,
        lastSeen = HopeAddon:GetDate(),
        lastSeenZone = zone,
        lastSeenTime = time(),
        firstSeen = nil,
        isFellow = true,
        isSelf = true,
        selectedColor = selectedColor,
        selectedTitle = selectedTitle,
        profile = profile,
        hasNote = note ~= nil,
        note = note,
        stats = nil,
        avgILvl = avgILvl,
        gearScore = gearScore,
        avgILvlTime = time(),
    }
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
        avgILvl = data.avgILvl,
        gearScore = data.gearScore,
        avgILvlTime = data.avgILvlTime,
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
    elseif sortOption == "last_seen" then
        table.sort(entries, function(a, b)
            local aTime = a.lastSeenTime or 0
            local bTime = b.lastSeenTime or 0
            if aTime ~= bTime then
                return aTime > bTime
            end
            return (a.lastSeen or "") > (b.lastSeen or "")
        end)
    elseif sortOption == "ilvl_desc" then
        table.sort(entries, function(a, b)
            if (a.avgILvl or 0) == (b.avgILvl or 0) then
                return (a.name or "") < (b.name or "")
            end
            return (a.avgILvl or 0) > (b.avgILvl or 0)
        end)
    elseif sortOption == "gearscore_desc" then
        table.sort(entries, function(a, b)
            if (a.gearScore or 0) == (b.gearScore or 0) then
                return (a.name or "") < (b.name or "")
            end
            return (a.gearScore or 0) > (b.gearScore or 0)
        end)
    elseif sortOption == "veteran" then
        table.sort(entries, function(a, b)
            -- Oldest firstSeen first (lower timestamp = seen earlier = more veteran)
            local aFirst = a.firstSeen and a.firstSeen or "9999"
            local bFirst = b.firstSeen and b.firstSeen or "9999"
            if aFirst == bFirst then
                return (a.name or "") < (b.name or "")
            end
            return aFirst < bFirst
        end)
    end
end

--[[
    Get color hex for item level display based on gear quality tiers
    @param ilvl number - Average item level
    @return string - Hex color string (without |cFF prefix)
]]
function Directory:GetILvlColor(ilvl)
    if not ilvl or ilvl <= 0 then return "555555" end
    if ilvl >= 130 then return "a335ee" end  -- Epic (T5+)
    if ilvl >= 115 then return "0070dd" end  -- Rare (T4+)
    if ilvl >= 100 then return "1eff00" end  -- Uncommon (Pre-raid)
    return "FFFFFF"                          -- White (Leveling)
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

--[[
    Get leaderboard stats for the stats header
    @param entries table - Sorted array of entries (already filtered and sorted)
    @param sortOption string - Current sort option ID
    @return table - { total, online, selfRank, avgValue, topValue, recentCount, maxLevel }
]]
function Directory:GetLeaderboardStats(entries, sortOption)
    local stats = {
        total = #entries,
        online = 0,
        selfRank = nil,
        avgValue = 0,
        topValue = 0,
        recentCount = 0,
        maxLevel = 0,
    }

    local C = HopeAddon.Constants
    local sevenDaysAgo = time() - (7 * 24 * 60 * 60)
    local valueSum = 0
    local valueCount = 0

    for i, entry in ipairs(entries) do
        -- Find self rank
        if entry.isSelf then
            stats.selfRank = i
        end

        -- Count online
        if entry.lastSeenTime then
            local elapsed = time() - entry.lastSeenTime
            if elapsed < C.SOCIAL_TAB.ONLINE_THRESHOLD then
                stats.online = stats.online + 1
            end
        end
        -- Count recent (7 days)
        if entry.lastSeenTime and entry.lastSeenTime >= sevenDaysAgo then
            stats.recentCount = stats.recentCount + 1
        end

        -- Track max level at 70
        if entry.level and entry.level >= 70 then
            stats.maxLevel = stats.maxLevel + 1
        end

        -- Accumulate values based on sort category
        if sortOption == "ilvl_desc" then
            if entry.avgILvl and entry.avgILvl > 0 then
                valueSum = valueSum + entry.avgILvl
                valueCount = valueCount + 1
                if i == 1 then stats.topValue = entry.avgILvl end
            end
        elseif sortOption == "gearscore_desc" then
            if entry.gearScore and entry.gearScore > 0 then
                valueSum = valueSum + entry.gearScore
                valueCount = valueCount + 1
                if i == 1 then stats.topValue = entry.gearScore end
            end
        elseif sortOption == "level_desc" then
            if entry.level and entry.level > 0 then
                valueSum = valueSum + entry.level
                valueCount = valueCount + 1
                if i == 1 then stats.topValue = entry.level end
            end
        end
    end

    if valueCount > 0 then
        stats.avgValue = math.floor(valueSum / valueCount)
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

--[[
    Get class icon for display
    @param class string - Class name
    @return string - Icon path
]]
function Directory:GetClassIcon(class)
    return CLASS_ICONS[class] or HopeAddon.DEFAULT_ICON_PATH
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
