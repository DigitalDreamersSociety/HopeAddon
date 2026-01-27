--[[
    HopeAddon Guild Module
    "The Guild Hall" - Guild roster tracking and activity chronicles

    This module provides guild member tracking without requiring the addon,
    using WoW's built-in guild API. Enhanced features for addon users.
]]

local Guild = {}

--============================================================
-- CONSTANTS
--============================================================

-- Activity types for Guild Chronicles
local ACTIVITY_TYPE = {
    LOGIN = "LOGIN",
    LOGOUT = "LOGOUT",
    LEVELUP = "LEVELUP",
    ZONE = "ZONE",
    RANK = "RANK",
    JOIN = "JOIN",
    LEAVE = "LEAVE",
}

-- RP-flavored activity messages
local ACTIVITY_MESSAGES = {
    LOGIN = "%s has entered the hall",
    LOGOUT = "%s has departed for distant lands",
    LEVELUP = "%s has grown stronger (Level %d)",
    ZONE = "%s ventures into %s",
    RANK = "%s has been promoted to %s",
    JOIN = "%s has joined the guild",
    LEAVE = "%s has left the guild",
}

-- Limits
local MAX_ACTIVITY_ENTRIES = 100
local ACTIVITY_RETENTION_DAYS = 7
local ROSTER_REFRESH_INTERVAL = 30  -- seconds between auto-refresh
local ONLINE_CHECK_INTERVAL = 60    -- seconds between online status broadcasts

--============================================================
-- API COMPATIBILITY
--============================================================

-- GuildRoster() was replaced with C_GuildInfo.GuildRoster() in Retail
local function RequestGuildRoster()
    if GuildRoster then
        GuildRoster()
    elseif C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    end
end

--============================================================
-- MODULE STATE
--============================================================

Guild.eventFrame = nil
Guild.listeners = {}  -- Registered UI listeners
Guild.listenerCount = 0
Guild.previousRoster = {}  -- For change detection
Guild.lastRosterUpdate = 0
Guild.refreshTicker = nil
Guild.isInitialized = false
Guild.pendingRefresh = nil  -- Timer deduplication

--============================================================
-- LIFECYCLE
--============================================================

function Guild:OnInitialize()
    -- Nothing to do here - we need charDb which isn't available yet
end

function Guild:OnEnable()
    self:Initialize()
end

function Guild:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    if self.refreshTicker then
        self.refreshTicker:Cancel()
        self.refreshTicker = nil
    end

    if self.pendingRefresh then
        self.pendingRefresh:Cancel()
        self.pendingRefresh = nil
    end

    -- Issue #20: Clear listeners to prevent callback accumulation
    wipe(self.listeners)
    self.listenerCount = 0
end

--============================================================
-- INITIALIZATION
--============================================================

function Guild:Initialize()
    if self.isInitialized then return end

    -- Ensure data structure exists
    self:EnsureGuildData()

    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
    self.eventFrame:RegisterEvent("GUILD_MOTD")
    self.eventFrame:RegisterEvent("CHAT_MSG_GUILD")  -- For activity tracking

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "GUILD_ROSTER_UPDATE" then
            self:OnGuildRosterUpdate()
        elseif event == "PLAYER_GUILD_UPDATE" then
            self:OnPlayerGuildUpdate()
        elseif event == "GUILD_MOTD" then
            self:OnGuildMOTD(...)
        elseif event == "CHAT_MSG_GUILD" then
            -- Could parse for level up announcements, etc.
            self:OnGuildChat(...)
        end
    end)

    -- Initial roster request
    if IsInGuild() then
        RequestGuildRoster()  -- Triggers GUILD_ROSTER_UPDATE

        -- Store guild info
        local guildData = self:GetGuildData()
        guildData.name = GetGuildInfo("player") or ""
        local _, _, rankIndex = GetGuildInfo("player")
        guildData.rankIndex = rankIndex or 0
    end

    -- Set up periodic refresh ticker
    self.refreshTicker = HopeAddon.Timer:NewTicker(ROSTER_REFRESH_INTERVAL, function()
        if IsInGuild() then
            RequestGuildRoster()
        end
    end)

    self.isInitialized = true
    HopeAddon:Debug("Guild module initialized")
end

--============================================================
-- DATA STRUCTURE
--============================================================

--[[
    Ensure guild data structure exists in charDb
    @return table - The guild data table
]]
function Guild:EnsureGuildData()
    local charDb = HopeAddon.charDb
    if not charDb then return nil end

    if not charDb.guild then
        charDb.guild = {
            name = "",
            rank = "",
            rankIndex = 0,
            roster = {},
            activity = {},
            motd = "",
            lastRosterUpdate = 0,
            settings = {
                trackActivity = true,
                showOffline = true,
                sortBy = "online",  -- "online", "name", "rank", "level"
            },
        }
    end

    -- Ensure all required fields exist (migration)
    local guild = charDb.guild
    guild.roster = guild.roster or {}
    guild.activity = guild.activity or {}
    guild.settings = guild.settings or {}
    guild.settings.trackActivity = guild.settings.trackActivity ~= false
    guild.settings.showOffline = guild.settings.showOffline ~= false
    guild.settings.sortBy = guild.settings.sortBy or "online"

    return charDb.guild
end

--[[
    Get the guild data table
    @return table|nil - Guild data or nil if not available
]]
function Guild:GetGuildData()
    return self:EnsureGuildData()
end

--============================================================
-- ROSTER MANAGEMENT
--============================================================

--[[
    Handle guild roster update event
    Caches all guild member data and tracks activity changes
]]
function Guild:OnGuildRosterUpdate()
    if not IsInGuild() then
        self:ClearRoster()
        return
    end

    local guildData = self:GetGuildData()
    if not guildData then return end

    local numMembers = GetNumGuildMembers()
    local newRoster = {}
    local now = time()

    for i = 1, numMembers do
        local name, rank, rankIndex, level, class, zone,
              note, officerNote, isOnline, status, classFile,
              achievementPoints, achievementRank, isMobile, canSoR, repStanding = GetGuildRosterInfo(i)

        if name then
            -- Strip realm from name (TBC format: "Name-Realm")
            local shortName = strsplit("-", name)

            -- Get class token (uppercase) - classFile is the token in TBC
            local classToken = classFile or class:upper():gsub(" ", "")

            newRoster[shortName] = {
                fullName = name,
                level = level or 0,
                class = class or "Unknown",
                classToken = classToken,
                zone = zone or "Unknown",
                isOnline = isOnline or false,
                note = note or "",
                officerNote = officerNote or "",
                rank = rank or "Member",
                rankIndex = rankIndex or 0,
                lastOnline = isOnline and now or (guildData.roster[shortName] and guildData.roster[shortName].lastOnline or nil),
                status = status,  -- 0 = online, 1 = AFK, 2 = DND
            }

            -- Track activity changes
            if guildData.settings.trackActivity then
                local oldEntry = guildData.roster[shortName]
                if oldEntry then
                    -- Login detection
                    if not oldEntry.isOnline and isOnline then
                        self:RecordActivity(ACTIVITY_TYPE.LOGIN, shortName)
                    -- Logout detection
                    elseif oldEntry.isOnline and not isOnline then
                        self:RecordActivity(ACTIVITY_TYPE.LOGOUT, shortName)
                    -- Zone change detection (only for online players)
                    elseif isOnline and oldEntry.zone ~= zone and zone and zone ~= "" then
                        self:RecordActivity(ACTIVITY_TYPE.ZONE, shortName, zone)
                    -- Level up detection
                    elseif oldEntry.level and level and level > oldEntry.level then
                        self:RecordActivity(ACTIVITY_TYPE.LEVELUP, shortName, level)
                    -- Rank change detection
                    elseif oldEntry.rankIndex and rankIndex and rankIndex ~= oldEntry.rankIndex then
                        self:RecordActivity(ACTIVITY_TYPE.RANK, shortName, rank)
                    end
                else
                    -- New member (or first time seeing them)
                    -- Only record if we have previous roster data (not first load)
                    if next(guildData.roster) then
                        self:RecordActivity(ACTIVITY_TYPE.JOIN, shortName)
                    end
                end
            end
        end
    end

    -- Check for members who left (were in old roster but not in new)
    if guildData.settings.trackActivity and next(guildData.roster) then
        for oldName, _ in pairs(guildData.roster) do
            if not newRoster[oldName] then
                self:RecordActivity(ACTIVITY_TYPE.LEAVE, oldName)
            end
        end
    end

    -- Update roster
    guildData.roster = newRoster
    guildData.lastRosterUpdate = now

    -- Update guild info
    local guildName, guildRank, guildRankIndex = GetGuildInfo("player")
    guildData.name = guildName or ""
    guildData.rank = guildRank or ""
    guildData.rankIndex = guildRankIndex or 0

    -- Notify listeners
    self:NotifyListeners("roster")

    HopeAddon:Debug("Guild roster updated:", numMembers, "members")
end

--[[
    Handle player guild update (joined/left guild)
]]
function Guild:OnPlayerGuildUpdate()
    if IsInGuild() then
        -- Player joined a guild, request roster
        RequestGuildRoster()
    else
        -- Player left guild, clear data
        self:ClearRoster()
    end

    self:NotifyListeners("membership")
end

--[[
    Handle MOTD update
    @param motd string - Message of the day
]]
function Guild:OnGuildMOTD(motd)
    local guildData = self:GetGuildData()
    if guildData then
        guildData.motd = motd or ""
        self:NotifyListeners("motd")
    end
end

--[[
    Handle guild chat messages for activity detection
    @param message string - Chat message
    @param sender string - Sender name
]]
function Guild:OnGuildChat(message, sender)
    -- Could parse for specific patterns like level-up announcements
    -- For now, this is a placeholder for future enhancement
end

--[[
    Clear roster data (when leaving guild)
]]
function Guild:ClearRoster()
    local guildData = self:GetGuildData()
    if guildData then
        wipe(guildData.roster)
        guildData.name = ""
        guildData.rank = ""
        guildData.rankIndex = 0
        guildData.motd = ""
    end
    self:NotifyListeners("membership")
end

--============================================================
-- ACTIVITY TRACKING
--============================================================

--[[
    Record a guild activity
    @param activityType string - Type from ACTIVITY_TYPE
    @param playerName string - Player name
    @param data any - Additional data (level, zone, rank)
]]
function Guild:RecordActivity(activityType, playerName, data)
    local guildData = self:GetGuildData()
    if not guildData or not guildData.settings.trackActivity then return end

    local entry = {
        type = activityType,
        player = playerName,
        data = data,
        timestamp = time(),
    }

    -- Insert at beginning (newest first)
    table.insert(guildData.activity, 1, entry)

    -- Trim to max entries
    while #guildData.activity > MAX_ACTIVITY_ENTRIES do
        table.remove(guildData.activity)
    end

    -- Clean old entries
    self:CleanOldActivity()

    HopeAddon:Debug("Guild activity:", activityType, playerName, data or "")
end

--[[
    Clean activity entries older than retention period
]]
function Guild:CleanOldActivity()
    local guildData = self:GetGuildData()
    if not guildData then return end

    local cutoff = time() - (ACTIVITY_RETENTION_DAYS * 24 * 60 * 60)
    local activity = guildData.activity

    -- Remove from end (oldest entries) until we hit one within retention
    while #activity > 0 and activity[#activity].timestamp < cutoff do
        table.remove(activity)
    end
end

--[[
    Format an activity entry for display
    @param entry table - Activity entry
    @return string - Formatted message
]]
function Guild:FormatActivity(entry)
    if not entry then return "" end

    local template = ACTIVITY_MESSAGES[entry.type]
    if not template then return "" end

    if entry.type == ACTIVITY_TYPE.LEVELUP then
        return string.format(template, entry.player, entry.data or 0)
    elseif entry.type == ACTIVITY_TYPE.ZONE or entry.type == ACTIVITY_TYPE.RANK then
        return string.format(template, entry.player, entry.data or "")
    else
        return string.format(template, entry.player)
    end
end

--[[
    Get recent activity entries
    @param limit number - Max entries to return (default 20)
    @return table - Array of activity entries
]]
function Guild:GetRecentActivity(limit)
    local guildData = self:GetGuildData()
    if not guildData then return {} end

    limit = limit or 20
    local result = {}

    for i = 1, math.min(limit, #guildData.activity) do
        table.insert(result, guildData.activity[i])
    end

    return result
end

--============================================================
-- ROSTER QUERIES
--============================================================

--[[
    Get all roster entries
    @return table - Array of member entries
]]
function Guild:GetRoster()
    local guildData = self:GetGuildData()
    if not guildData then return {} end

    local result = {}
    for name, data in pairs(guildData.roster) do
        local entry = {
            name = name,
            level = data.level,
            class = data.class,
            classToken = data.classToken,
            zone = data.zone,
            isOnline = data.isOnline,
            note = data.note,
            officerNote = data.officerNote,
            rank = data.rank,
            rankIndex = data.rankIndex,
            lastOnline = data.lastOnline,
            status = data.status,
        }
        table.insert(result, entry)
    end

    return result
end

--[[
    Get roster sorted by specified criteria
    @param sortBy string - Sort criteria: "online", "name", "rank", "level", "class"
    @return table - Sorted array of member entries
]]
function Guild:GetSortedRoster(sortBy)
    local roster = self:GetRoster()

    sortBy = sortBy or "online"

    if sortBy == "online" then
        -- Online first, then by name
        table.sort(roster, function(a, b)
            if a.isOnline ~= b.isOnline then
                return a.isOnline  -- Online first
            end
            return (a.name or "") < (b.name or "")
        end)
    elseif sortBy == "name" then
        table.sort(roster, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    elseif sortBy == "rank" then
        table.sort(roster, function(a, b)
            if a.rankIndex ~= b.rankIndex then
                return a.rankIndex < b.rankIndex
            end
            return (a.name or "") < (b.name or "")
        end)
    elseif sortBy == "level" then
        table.sort(roster, function(a, b)
            if a.level ~= b.level then
                return (a.level or 0) > (b.level or 0)
            end
            return (a.name or "") < (b.name or "")
        end)
    elseif sortBy == "class" then
        table.sort(roster, function(a, b)
            if a.class ~= b.class then
                return (a.class or "") < (b.class or "")
            end
            return (a.name or "") < (b.name or "")
        end)
    end

    return roster
end

--[[
    Get filtered roster
    @param filter table - Filter options { showOffline, rankFilter, classFilter, searchText }
    @param sortBy string - Sort criteria
    @return table - Filtered and sorted roster
]]
function Guild:GetFilteredRoster(filter, sortBy)
    local roster = self:GetSortedRoster(sortBy)

    if not filter then return roster end

    local result = {}
    for _, member in ipairs(roster) do
        local include = true

        -- Online filter
        if filter.showOffline == false and not member.isOnline then
            include = false
        end

        -- Rank filter
        if include and filter.rankFilter and filter.rankFilter ~= "" then
            if member.rank ~= filter.rankFilter then
                include = false
            end
        end

        -- Class filter
        if include and filter.classFilter and filter.classFilter ~= "" then
            if member.classToken ~= filter.classFilter then
                include = false
            end
        end

        -- Search text filter
        if include and filter.searchText and filter.searchText ~= "" then
            local search = filter.searchText:lower()
            local nameMatch = member.name and member.name:lower():find(search, 1, true)
            local zoneMatch = member.zone and member.zone:lower():find(search, 1, true)
            local noteMatch = member.note and member.note:lower():find(search, 1, true)
            if not (nameMatch or zoneMatch or noteMatch) then
                include = false
            end
        end

        if include then
            table.insert(result, member)
        end
    end

    return result
end

--[[
    Get a specific guild member's data
    @param name string - Member name
    @return table|nil - Member data or nil if not found
]]
function Guild:GetMember(name)
    local guildData = self:GetGuildData()
    if not guildData or not guildData.roster then return nil end
    return guildData.roster[name]
end

--[[
    Get count of online guild members
    @return number - Online member count
]]
function Guild:GetOnlineCount()
    local guildData = self:GetGuildData()
    if not guildData then return 0 end

    local count = 0
    for _, member in pairs(guildData.roster) do
        if member.isOnline then
            count = count + 1
        end
    end
    return count
end

--[[
    Get total guild member count
    @return number - Total member count
]]
function Guild:GetMemberCount()
    local guildData = self:GetGuildData()
    if not guildData or not guildData.roster then return 0 end

    local count = 0
    for _ in pairs(guildData.roster) do
        count = count + 1
    end
    return count
end

--[[
    Get guild name
    @return string - Guild name or empty string
]]
function Guild:GetGuildName()
    local guildData = self:GetGuildData()
    return guildData and guildData.name or ""
end

--[[
    Get MOTD
    @return string - Message of the day
]]
function Guild:GetMOTD()
    local guildData = self:GetGuildData()
    return guildData and guildData.motd or ""
end

--[[
    Check if a player is in the guild
    @param name string - Player name
    @return boolean - True if in guild
]]
function Guild:IsGuildMember(name)
    return self:GetMember(name) ~= nil
end

--[[
    Check if a player is a Fellow Traveler (has addon)
    @param name string - Player name
    @return boolean - True if has addon
]]
function Guild:IsFellowTraveler(name)
    if not HopeAddon.FellowTravelers then return false end
    return HopeAddon.FellowTravelers:IsFellow(name)
end

--[[
    Get all unique ranks in the guild
    @return table - Array of { rank, rankIndex } sorted by index
]]
function Guild:GetRanks()
    local guildData = self:GetGuildData()
    if not guildData then return {} end

    local ranks = {}
    local seen = {}

    for _, member in pairs(guildData.roster) do
        if member.rank and not seen[member.rank] then
            seen[member.rank] = true
            table.insert(ranks, {
                rank = member.rank,
                rankIndex = member.rankIndex,
            })
        end
    end

    -- Sort by rank index
    table.sort(ranks, function(a, b)
        return a.rankIndex < b.rankIndex
    end)

    return ranks
end

--============================================================
-- LISTENER SYSTEM
--============================================================

--[[
    Register a listener for guild updates
    @param id string - Unique listener ID
    @param callback function(eventType) - Callback function
]]
function Guild:RegisterListener(id, callback)
    if not id or not callback then return end

    self.listeners[id] = callback
    self.listenerCount = self.listenerCount + 1

    HopeAddon:Debug("Guild listener registered:", id)
end

--[[
    Unregister a listener
    @param id string - Listener ID
]]
function Guild:UnregisterListener(id)
    if self.listeners[id] then
        self.listeners[id] = nil
        self.listenerCount = self.listenerCount - 1
        HopeAddon:Debug("Guild listener unregistered:", id)
    end
end

--[[
    Notify all registered listeners
    @param eventType string - Type of event (roster, activity, membership, motd)
]]
function Guild:NotifyListeners(eventType)
    for id, callback in pairs(self.listeners) do
        local success, err = pcall(callback, eventType)
        if not success then
            HopeAddon:Debug("Guild listener error:", id, err)
        end
    end
end

--============================================================
-- SETTINGS
--============================================================

--[[
    Get current sort setting
    @return string - Sort option
]]
function Guild:GetSortSetting()
    local guildData = self:GetGuildData()
    return guildData and guildData.settings.sortBy or "online"
end

--[[
    Set sort setting
    @param sortBy string - Sort option
]]
function Guild:SetSortSetting(sortBy)
    local guildData = self:GetGuildData()
    if guildData then
        guildData.settings.sortBy = sortBy
    end
end

--[[
    Get show offline setting
    @return boolean - True if showing offline members
]]
function Guild:GetShowOffline()
    local guildData = self:GetGuildData()
    return guildData and guildData.settings.showOffline ~= false
end

--[[
    Set show offline setting
    @param show boolean - Show offline members
]]
function Guild:SetShowOffline(show)
    local guildData = self:GetGuildData()
    if guildData then
        guildData.settings.showOffline = show
    end
end

--[[
    Get activity tracking setting
    @return boolean - True if tracking activity
]]
function Guild:GetTrackActivity()
    local guildData = self:GetGuildData()
    return guildData and guildData.settings.trackActivity ~= false
end

--[[
    Set activity tracking setting
    @param track boolean - Track activity
]]
function Guild:SetTrackActivity(track)
    local guildData = self:GetGuildData()
    if guildData then
        guildData.settings.trackActivity = track
    end
end

--============================================================
-- UTILITY
--============================================================

--[[
    Format relative time for display
    @param timestamp number - Unix timestamp
    @return string - Formatted time ("2m ago", "1h ago", "3d ago")
]]
function Guild:FormatRelativeTime(timestamp)
    if not timestamp then return "Unknown" end

    local elapsed = time() - timestamp

    if elapsed < 60 then
        return "Just now"
    elseif elapsed < 3600 then
        local mins = math.floor(elapsed / 60)
        return mins .. "m ago"
    elseif elapsed < 86400 then
        local hours = math.floor(elapsed / 3600)
        return hours .. "h ago"
    else
        local days = math.floor(elapsed / 86400)
        return days .. "d ago"
    end
end

--[[
    Get class color for a class token
    @param classToken string - Class token (WARRIOR, MAGE, etc.)
    @return table - { r, g, b } color values
]]
function Guild:GetClassColor(classToken)
    if not classToken then return { r = 1, g = 1, b = 1 } end

    local color = RAID_CLASS_COLORS[classToken]
    if color then
        return { r = color.r, g = color.g, b = color.b }
    end

    return { r = 1, g = 1, b = 1 }
end

--[[
    Force a roster refresh
]]
function Guild:RefreshRoster()
    if IsInGuild() then
        RequestGuildRoster()
    end
end

--============================================================
-- MODULE REGISTRATION
--============================================================

HopeAddon:RegisterModule("Guild", Guild)
