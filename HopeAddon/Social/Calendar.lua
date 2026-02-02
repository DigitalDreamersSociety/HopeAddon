--[[
    HopeAddon Calendar Module
    Core event management for raid/event scheduling
]]

local Calendar = {}

-- Module references (populated on enable)
local C = nil
local Timer = nil
local FellowTravelers = nil
local ActivityFeed = nil
local SocialToasts = nil
local CalendarValidation = nil

-- Protocol version for network sync
local PROTOCOL_VERSION = 1

-- Local state
local notificationTicker = nil

--============================================================
-- INITIALIZATION
--============================================================

function Calendar:OnInitialize()
    C = HopeAddon.Constants
    HopeAddon:Debug("Calendar: Initialized")
end

function Calendar:OnEnable()
    Timer = HopeAddon.Timer
    FellowTravelers = HopeAddon.FellowTravelers
    ActivityFeed = HopeAddon.ActivityFeed
    SocialToasts = HopeAddon.SocialToasts
    CalendarValidation = HopeAddon.CalendarValidation

    -- Ensure calendar data exists
    self:EnsureCalendarData()

    -- Register network message callbacks
    self:RegisterNetworkHandlers()

    -- Start notification checker (runs every minute)
    self:StartNotificationChecker()

    -- Clean up expired events
    self:CleanupExpiredEvents()

    HopeAddon:Debug("Calendar: Enabled")
end

function Calendar:OnDisable()
    -- Stop notification ticker
    if notificationTicker then
        notificationTicker:Cancel()
        notificationTicker = nil
    end

    -- Unregister network message callbacks
    if FellowTravelers then
        FellowTravelers:UnregisterMessageCallback("calendar_event")
        FellowTravelers:UnregisterMessageCallback("calendar_delete")
        FellowTravelers:UnregisterMessageCallback("calendar_signup")
    end

    HopeAddon:Debug("Calendar: Disabled")
end

--============================================================
-- DATA ACCESS
--============================================================

--[[
    Ensure calendar data structure exists
    @return table - The calendar data table
]]
function Calendar:EnsureCalendarData()
    local social = HopeAddon:EnsureSocialData()
    if not social then return nil end

    -- Use defaults from constants if calendar doesn't exist
    if not social.calendar then
        local defaults = C and C.SOCIAL_DATA_DEFAULTS and C.SOCIAL_DATA_DEFAULTS.calendar
        if defaults then
            social.calendar = {}
            for k, v in pairs(defaults) do
                if type(v) == "table" then
                    social.calendar[k] = {}
                    for k2, v2 in pairs(v) do
                        social.calendar[k][k2] = v2
                    end
                else
                    social.calendar[k] = v
                end
            end
        else
            social.calendar = {
                myEvents = {},
                fellowEvents = {},
                mySignups = {},
                notifiedEvents = {},
                templates = {},  -- Event templates
                settings = {
                    defaultView = "month",
                    showPastEvents = true,
                    pastEventDays = 7,
                    defaultNotify1hr = true,
                    defaultNotify15min = true,
                },
            }
        end
    end

    return social.calendar
end

--[[
    Get calendar data
    @return table - Calendar data or nil
]]
function Calendar:GetCalendarData()
    local social = HopeAddon.charDb and HopeAddon.charDb.social
    return social and social.calendar
end

--[[
    Get calendar settings
    @return table - Calendar settings
]]
function Calendar:GetSettings()
    local cal = self:GetCalendarData()
    return cal and cal.settings or {}
end

--============================================================
-- EVENT ID GENERATION
--============================================================

--[[
    Generate unique event ID
    @return string - Unique event ID
]]
function Calendar:GenerateEventId()
    local playerName = UnitName("player")
    local timestamp = time()
    local random = math.random(1000, 9999)
    return string.format("evt_%s_%d_%d", playerName, timestamp, random)
end

--============================================================
-- DATE/TIME UTILITIES
--============================================================

--[[
    Get current date as YYYY-MM-DD string
    @return string
]]
function Calendar:GetTodayString()
    return date("%Y-%m-%d")
end

--[[
    Parse date string to components
    @param dateStr string - YYYY-MM-DD format
    @return number year, number month, number day
]]
function Calendar:ParseDate(dateStr)
    if not dateStr then return nil end
    local year, month, day = dateStr:match("^(%d+)-(%d+)-(%d+)$")
    return tonumber(year), tonumber(month), tonumber(day)
end

--[[
    Get Unix timestamp for event start time
    @param event table - Event data with date and startTime
    @return number - Unix timestamp
]]
function Calendar:GetEventTimestamp(event)
    if not event or not event.date or not event.startTime then return 0 end

    local year, month, day = self:ParseDate(event.date)
    if not year then return 0 end

    local hour, minute = event.startTime:match("^(%d+):(%d+)$")
    hour = tonumber(hour) or 19
    minute = tonumber(minute) or 0

    return time({
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = 0,
    })
end

--[[
    Get time until event starts
    @param event table
    @return number - Seconds until event (negative if past)
]]
function Calendar:GetTimeUntilEvent(event)
    local eventTime = self:GetEventTimestamp(event)
    return eventTime - time()
end

--[[
    Format countdown string
    @param seconds number
    @return string - Human readable countdown
]]
function Calendar:FormatCountdown(seconds)
    if seconds < 0 then
        return "Started"
    elseif seconds < 60 then
        return "< 1 min"
    elseif seconds < 3600 then
        local mins = math.floor(seconds / 60)
        return mins .. " min"
    elseif seconds < 86400 then
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        if mins > 0 then
            return hours .. "h " .. mins .. "m"
        end
        return hours .. " hour" .. (hours > 1 and "s" or "")
    else
        local days = math.floor(seconds / 86400)
        return days .. " day" .. (days > 1 and "s" or "")
    end
end

--============================================================
-- TIME ZONE UTILITIES
--============================================================

--[[
    Calculate the offset between local time and realm time in seconds
    Uses GetGameTime() which returns realm hour/minute
    @return number - Offset in seconds (positive = realm is ahead)
]]
function Calendar:CalculateRealmOffset()
    local realmHour, realmMinute = GetGameTime()
    local localTime = date("*t")

    -- Convert both to minutes from midnight
    local realmMinutes = realmHour * 60 + realmMinute
    local localMinutes = localTime.hour * 60 + localTime.min

    -- Calculate difference (accounting for day boundary)
    local diff = realmMinutes - localMinutes
    if diff > 720 then diff = diff - 1440 end  -- Cross midnight backward
    if diff < -720 then diff = diff + 1440 end -- Cross midnight forward

    return diff * 60  -- Return as seconds
end

--[[
    Format time string showing both realm and local time
    @param timeStr string - "HH:MM" time string (assumed realm time)
    @return string - Formatted dual time display
]]
function Calendar:FormatDualTime(timeStr)
    if not timeStr or timeStr == "All Day" or timeStr == "TBD" then
        return timeStr
    end

    local hour, minute = timeStr:match("^(%d+):(%d+)$")
    if not hour then return timeStr end

    -- Get realm offset in hours
    local offset = self:CalculateRealmOffset()
    local offsetHours = math.floor(offset / 3600)

    -- Same timezone - no dual display needed
    if offsetHours == 0 then
        return timeStr
    end

    -- Calculate local time from realm time
    local realmHour = tonumber(hour)
    local localHour = realmHour - offsetHours

    -- Handle day wrap
    if localHour < 0 then localHour = localHour + 24 end
    if localHour >= 24 then localHour = localHour - 24 end

    return string.format("%02d:%s R / %02d:%s L", realmHour, minute, localHour, minute)
end

--[[
    Convert PST time to local time for display
    PST is UTC-8 (standard Pacific Time)
    @param timeStr string - "HH:MM" in PST
    @return string - Formatted local time, or nil if same timezone
]]
function Calendar:FormatLocalTimeFromPST(timeStr)
    if not timeStr then return nil end

    local hour, minute = timeStr:match("^(%d+):(%d+)$")
    if not hour then return nil end

    -- PST is UTC-8
    local pstOffsetHours = -8

    -- Get local UTC offset
    local now = time()
    local utcNow = date("!*t", now)
    local localNow = date("*t", now)
    local localOffsetHours = localNow.hour - utcNow.hour
    if localOffsetHours > 12 then localOffsetHours = localOffsetHours - 24 end
    if localOffsetHours < -12 then localOffsetHours = localOffsetHours + 24 end

    -- Calculate difference from PST to local
    local diffHours = localOffsetHours - pstOffsetHours

    -- If same timezone, don't show duplicate
    if math.abs(diffHours) < 0.5 then
        return nil
    end

    -- Convert PST hour to local hour
    local pstHour = tonumber(hour)
    local localHour = pstHour + diffHours

    -- Handle day wrap
    if localHour < 0 then localHour = localHour + 24 end
    if localHour >= 24 then localHour = localHour - 24 end

    -- Format as 12h AM/PM
    local ampm = "AM"
    local displayHour = localHour

    if localHour == 0 then
        displayHour = 12
        ampm = "AM"
    elseif localHour == 12 then
        displayHour = 12
        ampm = "PM"
    elseif localHour > 12 then
        displayHour = localHour - 12
        ampm = "PM"
    end

    return string.format("%d:%s %s", math.floor(displayHour), minute, ampm)
end

--[[
    Get realm and local time as separate strings
    @param timeStr string - "HH:MM" time string (assumed realm time)
    @return string realmTime, string|nil localTime
]]
function Calendar:GetDualTimes(timeStr)
    if not timeStr or timeStr == "All Day" or timeStr == "TBD" then
        return timeStr, nil
    end

    local hour, minute = timeStr:match("^(%d+):(%d+)$")
    if not hour then return timeStr, nil end

    local realmHour = tonumber(hour)
    local realmTimeFormatted = string.format("%02d:%s", realmHour, minute)

    -- Get realm offset in hours
    local offset = self:CalculateRealmOffset()
    local offsetHours = math.floor(offset / 3600)

    -- Same timezone - no local time needed
    if offsetHours == 0 then
        return realmTimeFormatted, nil
    end

    -- Calculate local time from realm time
    local localHour = realmHour - offsetHours

    -- Handle day wrap
    if localHour < 0 then localHour = localHour + 24 end
    if localHour >= 24 then localHour = localHour - 24 end

    local localTimeFormatted = string.format("%02d:%s", localHour, minute)
    return realmTimeFormatted, localTimeFormatted
end

--[[
    Check if event is in the past
    @param event table
    @return boolean
]]
function Calendar:IsEventPast(event)
    return self:GetTimeUntilEvent(event) < 0
end

--[[
    Check if date is today
    @param dateStr string - YYYY-MM-DD
    @return boolean
]]
function Calendar:IsToday(dateStr)
    return dateStr == self:GetTodayString()
end

--============================================================
-- EVENT MANAGEMENT
--============================================================

--[[
    Create a new event
    @param eventData table - Event details
    @return string eventId, string|nil error
]]
function Calendar:CreateEvent(eventData)
    local cal = self:EnsureCalendarData()
    if not cal then
        return nil, "Calendar data not available"
    end

    -- Run validation if module available
    if CalendarValidation then
        local isValid, errors = CalendarValidation:ValidateEventCreate(eventData)
        if not isValid then
            return nil, table.concat(errors, "; ")
        end
    else
        -- Fallback validation: required fields only
        if not eventData.date then
            return nil, "Date is required"
        end
        if not eventData.startTime then
            return nil, "Start time is required"
        end
    end

    -- Check event limit
    local eventCount = 0
    if cal.myEvents then
        for _ in pairs(cal.myEvents) do
            eventCount = eventCount + 1
        end
    end
    if eventCount >= C.CALENDAR_TIMINGS.MAX_EVENTS_PER_PLAYER then
        return nil, "Maximum events reached (" .. C.CALENDAR_TIMINGS.MAX_EVENTS_PER_PLAYER .. ")"
    end

    -- Generate event ID and populate event
    local eventId = self:GenerateEventId()
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")

    local event = {
        id = eventId,
        title = eventData.title or "Event",
        eventType = eventData.eventType or "RAID",
        raidKey = eventData.raidKey,
        date = eventData.date,
        startTime = eventData.startTime,
        raidSize = eventData.raidSize or 10,
        maxTanks = eventData.maxTanks or 2,
        maxHealers = eventData.maxHealers or 3,
        maxDPS = eventData.maxDPS or 5,
        description = eventData.description and eventData.description:sub(1, C.CALENDAR_TIMINGS.MAX_DESCRIPTION_LENGTH) or "",
        createdAt = time(),
        updatedAt = time(),
        leader = playerName,
        leaderClass = playerClass,
        signups = {},
        autoAcceptFellows = eventData.autoAcceptFellows or false,
        softReserveLink = eventData.softReserveLink,
        eventColor = eventData.eventColor,  -- Custom color preset key (nil = use type color)
        discordLink = eventData.discordLink,  -- Optional Discord invite URL
        locked = false,                      -- Whether signups are locked
        lockedAt = nil,                      -- Timestamp when locked
        autoLock24Hours = eventData.autoLock24Hours or false,  -- Lock signups 24hrs before event
        roster = {},                         -- Player roster status overrides { playerName = "TEAM"|"ALTERNATE"|"DECLINED" }
    }

    -- Store event
    cal.myEvents[eventId] = event

    -- Broadcast to fellows
    self:BroadcastEvent(event, "CREATE")

    -- Post to activity feed
    if ActivityFeed then
        ActivityFeed:OnCalendarEvent("CREATED", event)
    end

    HopeAddon:Debug("Calendar: Created event", eventId, event.title)
    return eventId, nil
end

--[[
    Update an existing event
    @param eventId string
    @param updates table - Fields to update
    @return boolean success, string|nil error
]]
function Calendar:UpdateEvent(eventId, updates)
    local cal = self:GetCalendarData()
    if not cal then return false, "Calendar not available" end

    local event = cal.myEvents[eventId]
    if not event then
        return false, "Event not found"
    end

    -- Apply updates
    for key, value in pairs(updates) do
        if key ~= "id" and key ~= "leader" and key ~= "createdAt" and key ~= "signups" then
            if key == "description" then
                event[key] = value:sub(1, C.CALENDAR_TIMINGS.MAX_DESCRIPTION_LENGTH)
            else
                event[key] = value
            end
        end
    end

    event.updatedAt = time()

    -- Broadcast update
    self:BroadcastEvent(event, "UPDATE")

    HopeAddon:Debug("Calendar: Updated event", eventId)
    return true, nil
end

--[[
    Delete an event
    @param eventId string
    @return boolean success
]]
function Calendar:DeleteEvent(eventId)
    local cal = self:GetCalendarData()
    if not cal then return false end

    local event = cal.myEvents[eventId]
    if not event then return false end

    -- Broadcast deletion
    self:BroadcastEventDeletion(eventId)

    -- Remove from storage
    cal.myEvents[eventId] = nil

    HopeAddon:Debug("Calendar: Deleted event", eventId)
    return true
end

--[[
    Get event by ID (checks both myEvents and fellowEvents)
    @param eventId string
    @return table|nil event
]]
function Calendar:GetEvent(eventId)
    local cal = self:GetCalendarData()
    if not cal then return nil end

    local event = cal.myEvents[eventId] or cal.fellowEvents[eventId]

    -- Check for auto-lock if this is our event
    if event and cal.myEvents[eventId] then
        self:CheckAutoLock(event)
    end

    return event
end

--[[
    Check if an event should be auto-locked (24 hours before start)
    @param event table - Event data
    @return boolean - True if event was auto-locked by this call
]]
function Calendar:CheckAutoLock(event)
    if not event then return false end
    if not event.autoLock24Hours then return false end
    if event.locked then return false end

    local timeUntil = self:GetTimeUntilEvent(event)
    if timeUntil > 0 and timeUntil <= 86400 then  -- 24 hours in seconds
        event.locked = true
        event.lockedAt = time()
        event.autoLocked = true  -- Flag to distinguish from manual lock
        HopeAddon:Debug("Calendar: Auto-locked event", event.id, "- less than 24hrs until start")
        return true
    end
    return false
end

--[[
    Check if player owns an event
    @param eventId string
    @return boolean
]]
function Calendar:IsMyEvent(eventId)
    local cal = self:GetCalendarData()
    return cal and cal.myEvents[eventId] ~= nil
end

--============================================================
-- SERVER EVENTS (Hardcoded, read-only)
--============================================================

--[[
    Get server events for a specific date
    Server events are hardcoded in Constants.lua and are read-only announcements
    @param dateStr string - YYYY-MM-DD
    @return table - Array of server events
]]
function Calendar:GetServerEventsForDate(dateStr)
    local events = {}
    for _, event in ipairs(C.SERVER_EVENTS or {}) do
        if event.date == dateStr then
            table.insert(events, event)
        end
    end
    return events
end

--[[
    Check if an event is a server event (read-only)
    Server events have no signups and cannot be edited
    @param event table
    @return boolean
]]
function Calendar:IsServerEvent(event)
    return event and event.eventType == "SERVER"
end

--============================================================
-- EVENT QUERIES
--============================================================

--[[
    Get all events for a specific date (guild events + server events)
    @param dateStr string - YYYY-MM-DD
    @param includeServerEvents boolean - If true, includes server events in the array (default true for backward compat)
    @return table - Array of events
]]
function Calendar:GetEventsForDate(dateStr, includeServerEvents)
    if includeServerEvents == nil then includeServerEvents = true end

    local cal = self:GetCalendarData()
    local events = {}

    -- Guild events (myEvents + fellowEvents)
    if cal then
        -- My events
        if cal.myEvents then
            for _, event in pairs(cal.myEvents) do
                if event.date == dateStr then
                    table.insert(events, event)
                end
            end
        end

        -- Fellow events
        if cal.fellowEvents then
            for _, event in pairs(cal.fellowEvents) do
                if event.date == dateStr then
                    table.insert(events, event)
                end
            end
        end
    end

    -- Server events (hardcoded, read-only) - only if requested
    if includeServerEvents then
        local serverEvents = self:GetServerEventsForDate(dateStr)
        for _, event in ipairs(serverEvents) do
            table.insert(events, event)
        end
    end

    -- Sort by start time
    table.sort(events, function(a, b)
        return (a.startTime or "00:00") < (b.startTime or "00:00")
    end)

    return events
end

--[[
    Get the first server event for a specific date (for themed backgrounds)
    @param dateStr string - YYYY-MM-DD
    @return table|nil - Server event or nil
]]
function Calendar:GetServerEventForDate(dateStr)
    local serverEvents = C:GetServerEventsForDate(dateStr)
    return serverEvents[1]  -- Return first one for background theming
end

--[[
    Get upcoming events (from today onwards)
    @param limit number - Max events to return (default 20)
    @return table - Array of events sorted by date/time
]]
function Calendar:GetUpcomingEvents(limit)
    limit = limit or 20
    local cal = self:GetCalendarData()
    if not cal then return {} end

    local today = self:GetTodayString()
    local events = {}

    -- Collect future events from my events (check auto-lock)
    if cal.myEvents then
        for _, event in pairs(cal.myEvents) do
            if event.date >= today then
                self:CheckAutoLock(event)  -- Check and apply auto-lock if needed
                table.insert(events, event)
            end
        end
    end
    -- Collect future events from fellow events
    if cal.fellowEvents then
        for _, event in pairs(cal.fellowEvents) do
            if event.date >= today then
                table.insert(events, event)
            end
        end
    end

    -- Sort by date and time
    table.sort(events, function(a, b)
        if a.date == b.date then
            return (a.startTime or "00:00") < (b.startTime or "00:00")
        end
        return a.date < b.date
    end)

    -- Limit results
    local result = {}
    for i = 1, math.min(#events, limit) do
        table.insert(result, events[i])
    end

    return result
end

--[[
    Get past events within configured days
    @return table - Array of past events
]]
function Calendar:GetPastEvents()
    local cal = self:GetCalendarData()
    if not cal then return {} end

    local settings = cal.settings or {}
    if not settings.showPastEvents then return {} end

    local today = self:GetTodayString()
    local cutoffDays = settings.pastEventDays or 7
    local cutoffTime = time() - (cutoffDays * 86400)

    local events = {}

    if cal.myEvents then
        for _, event in pairs(cal.myEvents) do
            if event.date < today and event.createdAt >= cutoffTime then
                table.insert(events, event)
            end
        end
    end
    if cal.fellowEvents then
        for _, event in pairs(cal.fellowEvents) do
            if event.date < today and event.createdAt >= cutoffTime then
                table.insert(events, event)
            end
        end
    end

    -- Sort descending (most recent first)
    table.sort(events, function(a, b)
        if a.date == b.date then
            return (a.startTime or "00:00") > (b.startTime or "00:00")
        end
        return a.date > b.date
    end)

    return events
end

--[[
    Get span position for a date within an event's range
    @param event table - Event with date and optional endDate
    @param dateStr string - The date to check (YYYY-MM-DD)
    @return string - "single", "start", "middle", or "end"
]]
local function getSpanPosition(event, dateStr)
    local startDate = event.date
    local endDate = event.endDate or startDate

    if startDate == endDate then
        return "single"
    elseif dateStr == startDate then
        return "start"
    elseif dateStr == endDate then
        return "end"
    else
        return "middle"
    end
end

--[[
    Get events for a month (for calendar grid display)
    @param year number
    @param month number (1-12)
    @return table - Map of date string to { count = number, events = { eventType, title, spanPosition }, serverEvent = event|nil }

    Note: Server events are returned as full objects in the serverEvent field (first one for that day)
    for themed background rendering, rather than as stripped mini-card data in the events array.
]]
function Calendar:GetEventsForMonth(year, month)
    local cal = self:GetCalendarData()

    local monthStr = string.format("%04d-%02d", year, month)
    local eventsByDate = {}

    -- Helper to add event entry for a specific date
    local function addEventForDate(event, dateStr, spanPosition)
        if not eventsByDate[dateStr] then
            eventsByDate[dateStr] = { count = 0, events = {} }
        end
        eventsByDate[dateStr].count = eventsByDate[dateStr].count + 1
        table.insert(eventsByDate[dateStr].events, {
            eventType = event.eventType or "OTHER",
            title = event.title,
            spanPosition = spanPosition,
        })
    end

    -- Helper to add server event for themed background (keeps full object)
    local function addServerEventForDate(event, dateStr)
        if not eventsByDate[dateStr] then
            eventsByDate[dateStr] = { count = 0, events = {} }
        end
        -- Only store first server event for background theming
        if not eventsByDate[dateStr].serverEvent then
            eventsByDate[dateStr].serverEvent = event
        end
    end

    -- Process an event, handling multi-day spans
    local function addEvent(event)
        if not event.date then return end

        local startDate = event.date
        local endDate = event.endDate or startDate

        -- Single-day event: check if it's in this month
        if startDate == endDate then
            if startDate:sub(1, 7) == monthStr then
                addEventForDate(event, startDate, "single")
            end
            return
        end

        -- Multi-day event: iterate through all dates in range
        local startYear, startMonth, startDay = self:ParseDate(startDate)
        local endYear, endMonth, endDay = self:ParseDate(endDate)
        if not startYear or not endYear then return end

        -- Convert to timestamps for iteration
        local startTime = time({ year = startYear, month = startMonth, day = startDay, hour = 0 })
        local endTime = time({ year = endYear, month = endMonth, day = endDay, hour = 0 })

        -- Iterate day by day
        local currentTime = startTime
        while currentTime <= endTime do
            local dt = date("*t", currentTime)
            local dateStr = string.format("%04d-%02d-%02d", dt.year, dt.month, dt.day)

            -- Only add dates that are in the requested month
            if dateStr:sub(1, 7) == monthStr then
                local spanPos = getSpanPosition(event, dateStr)
                addEventForDate(event, dateStr, spanPos)
            end

            -- Advance to next day (86400 seconds = 1 day)
            currentTime = currentTime + 86400
        end
    end

    -- Guild events
    if cal then
        if cal.myEvents then
            for _, event in pairs(cal.myEvents) do
                addEvent(event)
            end
        end

        if cal.fellowEvents then
            for _, event in pairs(cal.fellowEvents) do
                addEvent(event)
            end
        end
    end

    -- Server events (hardcoded, read-only) - store as themed backgrounds, not mini-cards
    for _, event in ipairs(C.SERVER_EVENTS or {}) do
        if event.date and event.date:sub(1, 7) == monthStr then
            addServerEventForDate(event, event.date)
        end
    end

    return eventsByDate
end

--============================================================
-- SIGNUP MANAGEMENT
--============================================================

--[[
    Sign up for an event
    @param eventId string
    @param role string - "tank", "healer", or "dps"
    @param status string - "confirmed" or "tentative"
    @return boolean success, string|nil error
]]
function Calendar:SignUp(eventId, role, status)
    local cal = self:EnsureCalendarData()
    if not cal then return false, "Calendar not available" end

    status = status or "confirmed"

    local event = self:GetEvent(eventId)
    if not event then
        return false, "Event not found"
    end

    -- Check if event is locked (owner can still manage roster)
    local playerName = UnitName("player")
    if event.locked and event.leader ~= playerName then
        return false, "Event signups are locked"
    end

    local _, playerClass = UnitClass("player")

    -- Run validation if module available
    if CalendarValidation then
        local isValid, errors, shouldStandby, warnings = CalendarValidation:ValidateSignup(eventId, playerName, role)
        if not isValid then
            return false, table.concat(errors, "; ")
        end
        -- If role/raid full but validation passed, mark as standby
        if shouldStandby then
            status = "standby"
            HopeAddon:Debug("Calendar: Automatically assigning standby status due to full slots")
        end
        -- Show warnings for time conflicts (informational, doesn't block signup)
        if warnings and #warnings > 0 then
            for _, warning in ipairs(warnings) do
                HopeAddon:Print("|cFFFFD700[Calendar Warning]|r " .. warning)
            end
        end
    end

    -- Check if already signed up
    if event.signups[playerName] then
        -- Update existing signup
        event.signups[playerName].role = role
        event.signups[playerName].status = status
    else
        -- Add new signup
        event.signups[playerName] = {
            class = playerClass,
            role = role,
            status = status,
            joinedAt = time(),
            isFellow = true,
        }
    end

    -- Store my signup preferences
    cal.mySignups[eventId] = {
        role = role,
        status = status,
        notify1hr = cal.settings.defaultNotify1hr,
        notify15min = cal.settings.defaultNotify15min,
    }

    -- If it's a fellow's event, send signup message
    if not self:IsMyEvent(eventId) and event.leader then
        self:SendSignupMessage(eventId, event.leader, role, status)
    end

    -- Notify event leader via toast
    if event.leader ~= playerName and SocialToasts then
        -- Signup notification will be shown on the leader's end when they receive the message
    end

    HopeAddon:Debug("Calendar: Signed up for", eventId, "as", role)
    return true, nil
end

--[[
    Update signup status
    @param eventId string
    @param status string
    @return boolean
]]
function Calendar:UpdateSignupStatus(eventId, status)
    local cal = self:GetCalendarData()
    if not cal then return false end

    local signup = cal.mySignups[eventId]
    if not signup then return false end

    -- Check if event is locked
    local event = self:GetEvent(eventId)
    if event and event.locked then
        local playerName = UnitName("player")
        if event.leader ~= playerName then
            return false
        end
    end

    signup.status = status

    -- Update event signup if we have it
    if event then
        local playerName = UnitName("player")
        if event.signups[playerName] then
            event.signups[playerName].status = status
        end

        -- Notify leader
        if not self:IsMyEvent(eventId) and event.leader then
            self:SendSignupMessage(eventId, event.leader, signup.role, status)
        end
    end

    return true
end

--[[
    Cancel signup for an event
    @param eventId string
    @return boolean
]]
function Calendar:CancelSignup(eventId)
    local cal = self:GetCalendarData()
    if not cal then return false end

    -- Check if event is locked
    local event = self:GetEvent(eventId)
    if event and event.locked then
        local playerName = UnitName("player")
        if event.leader ~= playerName then
            return false
        end
    end

    -- Remove from mySignups
    cal.mySignups[eventId] = nil

    -- Remove from event signups
    if event then
        local playerName = UnitName("player")
        event.signups[playerName] = nil

        -- Notify leader
        if not self:IsMyEvent(eventId) and event.leader then
            self:SendSignupMessage(eventId, event.leader, nil, "declined")
        end
    end

    return true
end

--[[
    Get my signup for an event
    @param eventId string
    @return table|nil - Signup data
]]
function Calendar:GetMySignup(eventId)
    local cal = self:GetCalendarData()
    if not cal then return nil end
    return cal.mySignups[eventId]
end

--[[
    Get signup counts by role
    @param event table
    @return table - { tank = {current, max}, healer = {...}, dps = {...} }
]]
function Calendar:GetSignupCounts(event)
    if not event then return {} end

    local counts = {
        tank = { current = 0, max = event.maxTanks or 2 },
        healer = { current = 0, max = event.maxHealers or 3 },
        dps = { current = 0, max = event.maxDPS or 5 },
    }

    for _, signup in pairs(event.signups or {}) do
        if signup.status ~= "declined" then
            local role = signup.role
            if counts[role] then
                counts[role].current = counts[role].current + 1
            end
        end
    end

    return counts
end

--[[
    Check if signup slots are full for a role
    @param event table
    @param role string
    @return boolean
]]
function Calendar:IsRoleFull(event, role)
    local counts = self:GetSignupCounts(event)
    local roleCount = counts[role]
    if not roleCount then return true end
    return roleCount.current >= roleCount.max
end

--[[
    Get signups grouped by role with standby overflow
    @param event table
    @return table - { tank = { confirmed = {}, tentative = {}, standby = {} }, ... }
]]
function Calendar:GetSignupsByRole(event)
    if not event then return {} end

    local result = {
        tank = { confirmed = {}, tentative = {}, standby = {} },
        healer = { confirmed = {}, tentative = {}, standby = {} },
        dps = { confirmed = {}, tentative = {}, standby = {} },
    }

    local counts = self:GetSignupCounts(event)

    -- First pass: sort by status and join time
    local byRole = { tank = {}, healer = {}, dps = {} }
    for playerName, signup in pairs(event.signups or {}) do
        if signup.status ~= "declined" then
            local role = signup.role or "dps"
            if byRole[role] then
                table.insert(byRole[role], {
                    name = playerName,
                    class = signup.class,
                    status = signup.status,
                    joinedAt = signup.joinedAt or 0,
                    isFellow = signup.isFellow,
                })
            end
        end
    end

    -- Second pass: assign to confirmed/tentative/standby based on max slots
    for role, signups in pairs(byRole) do
        -- Sort by joinedAt (first come first served)
        table.sort(signups, function(a, b)
            return (a.joinedAt or 0) < (b.joinedAt or 0)
        end)

        local maxSlots = counts[role] and counts[role].max or 0
        local filledSlots = 0

        for _, signup in ipairs(signups) do
            if filledSlots < maxSlots then
                -- Has a slot
                if signup.status == "confirmed" then
                    table.insert(result[role].confirmed, signup)
                else
                    table.insert(result[role].tentative, signup)
                end
                filledSlots = filledSlots + 1
            else
                -- Standby
                table.insert(result[role].standby, signup)
            end
        end
    end

    return result
end

--[[
    Get all standby signups across all roles
    @param event table
    @return table - Array of standby signups
]]
function Calendar:GetStandbySignups(event)
    local byRole = self:GetSignupsByRole(event)
    local standby = {}

    for _, roleData in pairs(byRole) do
        for _, signup in ipairs(roleData.standby) do
            table.insert(standby, signup)
        end
    end

    -- Sort by join time
    table.sort(standby, function(a, b)
        return (a.joinedAt or 0) < (b.joinedAt or 0)
    end)

    return standby
end

--============================================================
-- EVENT TEMPLATES
--============================================================

--[[
    Ensure templates table exists in calendar data
    @return table - Templates table
]]
function Calendar:EnsureTemplates()
    local cal = self:EnsureCalendarData()
    if not cal then return {} end

    if not cal.templates then
        cal.templates = {}
    end

    return cal.templates
end

--[[
    Get all templates
    @return table - Templates dictionary
]]
function Calendar:GetTemplates()
    local cal = self:GetCalendarData()
    return cal and cal.templates or {}
end

--[[
    Save an event as a template
    @param eventId string - Event ID to save as template
    @param templateName string - Name for the template
    @return string templateId, string|nil error
]]
function Calendar:SaveTemplate(eventId, templateName)
    local event = self:GetEvent(eventId)
    if not event then
        return nil, "Event not found"
    end

    local templates = self:EnsureTemplates()

    -- Check template limit
    local count = 0
    for _ in pairs(templates) do
        count = count + 1
    end
    if count >= C.CALENDAR_TIMINGS.MAX_TEMPLATES then
        return nil, "Maximum templates reached (" .. C.CALENDAR_TIMINGS.MAX_TEMPLATES .. ")"
    end

    -- Generate template ID
    local templateId = "tpl_" .. time() .. "_" .. math.random(1000, 9999)

    -- Create template from event
    templates[templateId] = {
        name = templateName or event.title or "Template",
        eventType = event.eventType,
        raidKey = event.raidKey,
        raidSize = event.raidSize,
        maxTanks = event.maxTanks,
        maxHealers = event.maxHealers,
        maxDPS = event.maxDPS,
        description = event.description,
        defaultTime = event.startTime,
        createdAt = time(),
    }

    HopeAddon:Debug("Calendar: Saved template", templateId, templateName)
    return templateId, nil
end

--[[
    Save a new template from raw data
    @param templateData table - Template data
    @return string templateId, string|nil error
]]
function Calendar:SaveTemplateFromData(templateData)
    if not templateData or not templateData.name then
        return nil, "Template name required"
    end

    local templates = self:EnsureTemplates()

    -- Check template limit
    local count = 0
    for _ in pairs(templates) do
        count = count + 1
    end
    if count >= C.CALENDAR_TIMINGS.MAX_TEMPLATES then
        return nil, "Maximum templates reached (" .. C.CALENDAR_TIMINGS.MAX_TEMPLATES .. ")"
    end

    -- Generate template ID
    local templateId = "tpl_" .. time() .. "_" .. math.random(1000, 9999)

    -- Store template
    templates[templateId] = {
        name = templateData.name,
        eventType = templateData.eventType or "RAID",
        raidKey = templateData.raidKey,
        raidSize = templateData.raidSize or 10,
        maxTanks = templateData.maxTanks or 2,
        maxHealers = templateData.maxHealers or 3,
        maxDPS = templateData.maxDPS or 5,
        description = templateData.description or "",
        defaultTime = templateData.defaultTime or "19:00",
        createdAt = time(),
    }

    HopeAddon:Debug("Calendar: Saved template from data", templateId, templateData.name)
    return templateId, nil
end

--[[
    Load a template by ID
    @param templateId string
    @return table|nil - Template data
]]
function Calendar:LoadTemplate(templateId)
    local templates = self:GetTemplates()
    return templates[templateId]
end

--[[
    Delete a template
    @param templateId string
    @return boolean success
]]
function Calendar:DeleteTemplate(templateId)
    local templates = self:EnsureTemplates()
    if not templates[templateId] then
        return false
    end

    templates[templateId] = nil
    HopeAddon:Debug("Calendar: Deleted template", templateId)
    return true
end

--[[
    Get templates as array sorted by name
    @return table - Array of { id, name, ... }
]]
function Calendar:GetTemplatesList()
    local templates = self:GetTemplates()
    local list = {}

    for id, template in pairs(templates) do
        table.insert(list, {
            id = id,
            name = template.name,
            eventType = template.eventType,
            raidKey = template.raidKey,
            raidSize = template.raidSize,
            maxTanks = template.maxTanks,
            maxHealers = template.maxHealers,
            maxDPS = template.maxDPS,
            description = template.description,
            defaultTime = template.defaultTime,
        })
    end

    -- Sort by name
    table.sort(list, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    return list
end

--============================================================
-- NOTIFICATION SYSTEM
--============================================================

--[[
    Start the notification checker
]]
function Calendar:StartNotificationChecker()
    if notificationTicker then return end

    notificationTicker = Timer:NewTicker(C.CALENDAR_TIMINGS.NOTIFICATION_CHECK_INTERVAL, function()
        self:CheckNotifications()
    end)

    HopeAddon:Debug("Calendar: Notification checker started")
end

--[[
    Check for events that need notifications
]]
function Calendar:CheckNotifications()
    local cal = self:GetCalendarData()
    if not cal then return end

    local now = time()

    -- Check events I'm signed up for
    if not cal.mySignups then return end
    for eventId, signup in pairs(cal.mySignups) do
        local event = self:GetEvent(eventId)
        if event then
            local timeUntil = self:GetTimeUntilEvent(event)

            -- 1 hour notification
            if signup.notify1hr and timeUntil > 0 and timeUntil <= C.CALENDAR_TIMINGS.NOTIFICATION_1HR then
                local notifyKey = eventId .. "_1hr"
                if not cal.notifiedEvents[notifyKey] then
                    cal.notifiedEvents[notifyKey] = true
                    self:ShowEventNotification(event, "1 hour")
                end
            end

            -- 15 minute notification
            if signup.notify15min and timeUntil > 0 and timeUntil <= C.CALENDAR_TIMINGS.NOTIFICATION_15MIN then
                local notifyKey = eventId .. "_15min"
                if not cal.notifiedEvents[notifyKey] then
                    cal.notifiedEvents[notifyKey] = true
                    self:ShowEventNotification(event, "15 minutes")
                end
            end
        end
    end
end

--[[
    Show event notification
    @param event table
    @param timeFrame string - "1 hour" or "15 minutes"
]]
function Calendar:ShowEventNotification(event, timeFrame)
    if not event then return end

    local message = event.title .. " starts in " .. timeFrame .. "!"

    -- Toast notification
    if SocialToasts then
        SocialToasts:Show("event_reminder", event.leader, message)
    end

    -- Chat notification
    HopeAddon:Print("|cFFFFD700[Calendar]|r " .. message)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayNotification()
    end
end

--============================================================
-- CLEANUP
--============================================================

--[[
    Clean up expired events
]]
function Calendar:CleanupExpiredEvents()
    local cal = self:GetCalendarData()
    if not cal then return end

    local expiryTime = C.CALENDAR_TIMINGS.EVENT_EXPIRY_HOURS * 3600

    -- Clean my events
    local toRemove = {}
    if cal.myEvents then
        for eventId, event in pairs(cal.myEvents) do
            local eventTime = self:GetEventTimestamp(event)
            if time() - eventTime > expiryTime then
                table.insert(toRemove, eventId)
            end
        end
        for _, eventId in ipairs(toRemove) do
            cal.myEvents[eventId] = nil
            HopeAddon:Debug("Calendar: Cleaned up expired event", eventId)
        end
    end

    -- Clean fellow events
    toRemove = {}
    if cal.fellowEvents then
        for eventId, event in pairs(cal.fellowEvents) do
            local eventTime = self:GetEventTimestamp(event)
            if time() - eventTime > expiryTime then
                table.insert(toRemove, eventId)
            end
        end
        for _, eventId in ipairs(toRemove) do
            cal.fellowEvents[eventId] = nil
        end
    end

    -- Clean old signups
    if cal.mySignups then
        for eventId in pairs(cal.mySignups) do
            if not self:GetEvent(eventId) then
                cal.mySignups[eventId] = nil
            end
        end
    end

    -- Clean old notification flags
    -- (Keep them around for a while to prevent re-notification)
end

--============================================================
-- NETWORK PROTOCOL
--============================================================

--[[
    Register network message handlers with FellowTravelers
]]
function Calendar:RegisterNetworkHandlers()
    if not FellowTravelers then
        HopeAddon:Debug("Calendar: FellowTravelers not available for network registration")
        return
    end

    -- Event create/update
    FellowTravelers:RegisterMessageCallback("calendar_event", function(msgType)
        return msgType == C.CALENDAR_MSG.EVENT_CREATE or msgType == C.CALENDAR_MSG.EVENT_UPDATE
    end, function(msgType, sender, data)
        self:HandleNetworkEvent(sender, data, msgType == C.CALENDAR_MSG.EVENT_UPDATE)
    end)

    -- Event delete
    FellowTravelers:RegisterMessageCallback("calendar_delete", function(msgType)
        return msgType == C.CALENDAR_MSG.EVENT_DELETE
    end, function(msgType, sender, data)
        self:HandleEventDeletion(sender, data)
    end)

    -- Signup
    FellowTravelers:RegisterMessageCallback("calendar_signup", function(msgType)
        return msgType == C.CALENDAR_MSG.SIGNUP or msgType == C.CALENDAR_MSG.SIGNUP_UPDATE
    end, function(msgType, sender, data)
        self:HandleSignupMessage(sender, data)
    end)

    HopeAddon:Debug("Calendar: Network handlers registered")
end

--[[
    Serialize event for network transmission
    @param event table
    @return string
]]
function Calendar:SerializeEvent(event)
    -- Format: id|title|type|raidKey|date|time|size|tanks|healers|dps|desc|leader|class|discordLink
    return string.format("%s|%s|%s|%s|%s|%s|%d|%d|%d|%d|%s|%s|%s|%s",
        event.id or "",
        (event.title or ""):gsub("|", ""),
        event.eventType or "RAID",
        event.raidKey or "",
        event.date or "",
        event.startTime or "",
        event.raidSize or 10,
        event.maxTanks or 2,
        event.maxHealers or 3,
        event.maxDPS or 5,
        (event.description or ""):gsub("|", ""):sub(1, 50),
        event.leader or "",
        event.leaderClass or "",
        (event.discordLink or ""):gsub("|", "")
    )
end

--[[
    Deserialize event from network data
    @param data string
    @return table|nil event
]]
function Calendar:DeserializeEvent(data)
    local parts = { strsplit("|", data) }
    if #parts < 13 then return nil end

    return {
        id = parts[1],
        title = parts[2],
        eventType = parts[3],
        raidKey = parts[4] ~= "" and parts[4] or nil,
        date = parts[5],
        startTime = parts[6],
        raidSize = tonumber(parts[7]) or 10,
        maxTanks = tonumber(parts[8]) or 2,
        maxHealers = tonumber(parts[9]) or 3,
        maxDPS = tonumber(parts[10]) or 5,
        description = parts[11],
        leader = parts[12],
        leaderClass = parts[13],
        discordLink = parts[14] and parts[14] ~= "" and parts[14] or nil,
        signups = {},
        receivedAt = time(),
    }
end

--[[
    Broadcast event to fellows
    @param event table
    @param action string - "CREATE" or "UPDATE"
]]
function Calendar:BroadcastEvent(event, action)
    if not FellowTravelers then return end

    local msgType = action == "UPDATE" and C.CALENDAR_MSG.EVENT_UPDATE or C.CALENDAR_MSG.EVENT_CREATE
    local eventData = self:SerializeEvent(event)

    -- Format: MSGTYPE:VERSION:DATA
    local msg = string.format("%s:%d:%s", msgType, PROTOCOL_VERSION, eventData)

    -- Broadcast to guild and party
    FellowTravelers:BroadcastMessage(msg)

    HopeAddon:Debug("Calendar: Broadcast event", event.id, action)
end

--[[
    Broadcast event deletion
    @param eventId string
]]
function Calendar:BroadcastEventDeletion(eventId)
    if not FellowTravelers then return end

    -- Format: MSGTYPE:VERSION:EVENTID
    local msg = string.format("%s:%d:%s", C.CALENDAR_MSG.EVENT_DELETE, PROTOCOL_VERSION, eventId)
    FellowTravelers:BroadcastMessage(msg)
end

--[[
    Handle incoming event from network
    @param sender string
    @param data string - The serialized event data (version already stripped by FellowTravelers)
    @param isUpdate boolean
]]
function Calendar:HandleNetworkEvent(sender, data, isUpdate)
    local cal = self:EnsureCalendarData()
    if not cal then return end

    -- Data is the serialized event (FellowTravelers already stripped msgType and version)
    local event = self:DeserializeEvent(data)
    if not event or not event.id then
        HopeAddon:Debug("Calendar: Failed to deserialize event from", sender)
        return
    end

    -- Don't store our own events as fellow events
    if event.leader == UnitName("player") then
        return
    end

    -- Store in fellowEvents
    cal.fellowEvents[event.id] = event

    -- Show toast for new events
    if not isUpdate and SocialToasts then
        SocialToasts:Show("event_signup", event.leader, "created: " .. (event.title or "Event"))
    end

    HopeAddon:Debug("Calendar: Received event from", sender, event.id)
end

--[[
    Handle event deletion from network
    @param sender string
    @param data string - The event ID (version already stripped by FellowTravelers)
]]
function Calendar:HandleEventDeletion(sender, data)
    local cal = self:GetCalendarData()
    if not cal then return end

    -- Data is just the event ID
    local eventId = data
    if not eventId or eventId == "" then return end

    cal.fellowEvents[eventId] = nil
    cal.mySignups[eventId] = nil

    HopeAddon:Debug("Calendar: Event deleted by", sender, eventId)
end

--[[
    Send signup message to event leader
    @param eventId string
    @param leader string
    @param role string
    @param status string
]]
function Calendar:SendSignupMessage(eventId, leader, role, status)
    if not FellowTravelers then return end

    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")

    local data = string.format("%s|%s|%s|%s|%s",
        eventId,
        playerName,
        playerClass,
        role or "",
        status or "confirmed"
    )

    FellowTravelers:SendDirectMessage(leader, C.CALENDAR_MSG.SIGNUP, data)
end

--[[
    Handle incoming signup message
    @param sender string
    @param data string - The signup data (version already stripped by FellowTravelers)
]]
function Calendar:HandleSignupMessage(sender, data)
    local cal = self:GetCalendarData()
    if not cal then return end

    -- Data format: eventId|playerName|playerClass|role|status
    local eventId, playerName, playerClass, role, status = strsplit("|", data)
    if not eventId or not playerName then return end

    -- Only process if it's my event
    local event = cal.myEvents[eventId]
    if not event then return end

    -- Update signup
    if status == "declined" then
        event.signups[playerName] = nil
    else
        event.signups[playerName] = {
            class = playerClass,
            role = role,
            status = status,
            joinedAt = time(),
            isFellow = true,
        }
    end

    event.updatedAt = time()

    -- Show toast
    if SocialToasts and status ~= "declined" then
        SocialToasts:Show("event_signup", playerName, "signed up for " .. (event.title or "your event"))
    end

    -- Post to activity feed
    if ActivityFeed and status ~= "declined" then
        ActivityFeed:OnCalendarSignup(event, playerName, role)
    end

    HopeAddon:Debug("Calendar: Received signup from", sender, "for", eventId)
end

--============================================================
-- EVENT LOCKING
--============================================================

--[[
    Lock an event to prevent new signups
    @param eventId string
    @return boolean success, string|nil error
]]
function Calendar:LockEvent(eventId)
    local cal = self:GetCalendarData()
    if not cal then return false, "Calendar not available" end

    local event = cal.myEvents[eventId]
    if not event then
        return false, "Event not found or not owned by you"
    end

    event.locked = true
    event.lockedAt = time()
    event.updatedAt = time()

    -- Broadcast update
    self:BroadcastEvent(event, "UPDATE")

    HopeAddon:Debug("Calendar: Locked event", eventId)
    return true, nil
end

--[[
    Unlock an event to allow signups again
    @param eventId string
    @return boolean success, string|nil error
]]
function Calendar:UnlockEvent(eventId)
    local cal = self:GetCalendarData()
    if not cal then return false, "Calendar not available" end

    local event = cal.myEvents[eventId]
    if not event then
        return false, "Event not found or not owned by you"
    end

    event.locked = false
    event.lockedAt = nil
    event.updatedAt = time()

    -- Broadcast update
    self:BroadcastEvent(event, "UPDATE")

    HopeAddon:Debug("Calendar: Unlocked event", eventId)
    return true, nil
end

--[[
    Check if an event is locked
    @param eventId string
    @return boolean
]]
function Calendar:IsEventLocked(eventId)
    local event = self:GetEvent(eventId)
    return event and event.locked == true
end

--============================================================
-- ROSTER MANAGEMENT
--============================================================

--[[
    Set a player's roster status (only event owner can do this)
    @param eventId string
    @param playerName string
    @param rosterStatus string - "TEAM", "ALTERNATE", or "DECLINED"
    @return boolean success, string|nil error
]]
function Calendar:SetPlayerRosterStatus(eventId, playerName, rosterStatus)
    local cal = self:GetCalendarData()
    if not cal then return false, "Calendar not available" end

    local event = cal.myEvents[eventId]
    if not event then
        return false, "Event not found or not owned by you"
    end

    -- Validate roster status
    if not C.CALENDAR_ROSTER_STATUS[rosterStatus] then
        return false, "Invalid roster status"
    end

    -- Initialize roster table if needed
    if not event.roster then
        event.roster = {}
    end

    -- Set the player's roster status
    event.roster[playerName] = rosterStatus
    event.updatedAt = time()

    HopeAddon:Debug("Calendar: Set roster status for", playerName, "to", rosterStatus, "in event", eventId)
    return true, nil
end

--[[
    Cycle a player's roster status (TEAM -> ALTERNATE -> DECLINED -> TEAM)
    @param eventId string
    @param playerName string
    @return string|nil newStatus, string|nil error
]]
function Calendar:CyclePlayerRosterStatus(eventId, playerName)
    local cal = self:GetCalendarData()
    if not cal then return nil, "Calendar not available" end

    local event = cal.myEvents[eventId]
    if not event then
        return nil, "Event not found or not owned by you"
    end

    -- Initialize roster table if needed
    if not event.roster then
        event.roster = {}
    end

    -- Get current status and cycle to next
    local currentStatus = event.roster[playerName] or "TEAM"
    local statusOrder = { "TEAM", "ALTERNATE", "DECLINED" }
    local nextIndex = 1

    for i, status in ipairs(statusOrder) do
        if status == currentStatus then
            nextIndex = (i % #statusOrder) + 1
            break
        end
    end

    local newStatus = statusOrder[nextIndex]
    event.roster[playerName] = newStatus
    event.updatedAt = time()

    HopeAddon:Debug("Calendar: Cycled roster status for", playerName, "to", newStatus)
    return newStatus, nil
end

--[[
    Get roster organized by status
    @param event table
    @return table - { team = {}, alternates = {}, declined = {} }
]]
function Calendar:GetRosterByStatus(event)
    if not event then return { team = {}, alternates = {}, declined = {} } end

    local result = {
        team = {},
        alternates = {},
        declined = {},
    }

    -- Get all signups that aren't declined via normal signup status
    for playerName, signup in pairs(event.signups or {}) do
        if signup.status ~= "declined" then
            -- Check roster override first
            local rosterStatus = event.roster and event.roster[playerName]

            local playerData = {
                name = playerName,
                class = signup.class,
                role = signup.role,
                status = signup.status,
                joinedAt = signup.joinedAt,
                isFellow = signup.isFellow,
                rosterStatus = rosterStatus or "TEAM",
            }

            if rosterStatus == "DECLINED" then
                table.insert(result.declined, playerData)
            elseif rosterStatus == "ALTERNATE" then
                table.insert(result.alternates, playerData)
            else
                -- Default to team (TEAM or nil)
                table.insert(result.team, playerData)
            end
        end
    end

    -- Sort each list by join time
    local function sortByJoinTime(a, b)
        return (a.joinedAt or 0) < (b.joinedAt or 0)
    end

    table.sort(result.team, sortByJoinTime)
    table.sort(result.alternates, sortByJoinTime)
    table.sort(result.declined, sortByJoinTime)

    return result
end

--[[
    Get alternate count for a specific role
    @param event table
    @return table - { tank = count, healer = count, dps = count }
]]
function Calendar:GetAlternateCountsByRole(event)
    if not event then return { tank = 0, healer = 0, dps = 0 } end

    local counts = { tank = 0, healer = 0, dps = 0 }
    local roster = self:GetRosterByStatus(event)

    for _, player in ipairs(roster.alternates) do
        local role = player.role or "dps"
        if counts[role] then
            counts[role] = counts[role] + 1
        end
    end

    return counts
end

--============================================================
-- EXPORT FUNCTIONALITY
--============================================================

--[[
    Export event details as plain text for copying
    @param event table - Event data
    @return string - Formatted text export
]]
function Calendar:ExportEventDetails(event)
    if not event then return "" end

    local lines = {}
    table.insert(lines, "=== " .. (event.title or "Event") .. " ===")
    table.insert(lines, "Date: " .. (event.date or "TBD") .. " at " .. (event.startTime or "TBD"))
    table.insert(lines, "Leader: " .. (event.leader or "Unknown"))
    table.insert(lines, "")

    -- Group signups by roster status first, then by role
    local rosterGroups = self:GetRosterByStatus(event)

    if #rosterGroups.team > 0 then
        table.insert(lines, "-- TEAM --")
        for _, signup in ipairs(rosterGroups.team) do
            local ts = signup.joinedAt and date("%m/%d %H:%M", signup.joinedAt) or "N/A"
            table.insert(lines, string.format("  [%s] %s (%s) - signed %s",
                (signup.role or "dps"):sub(1, 1):upper(), signup.name, signup.class or "Unknown", ts))
        end
    end

    if #rosterGroups.alternates > 0 then
        table.insert(lines, "")
        table.insert(lines, "-- ALTERNATES --")
        for _, signup in ipairs(rosterGroups.alternates) do
            local ts = signup.joinedAt and date("%m/%d %H:%M", signup.joinedAt) or "N/A"
            table.insert(lines, string.format("  [%s] %s (%s) - signed %s",
                (signup.role or "dps"):sub(1, 1):upper(), signup.name, signup.class or "Unknown", ts))
        end
    end

    return table.concat(lines, "\n")
end

-- Local reference for export popup
local exportPopup = nil

--[[
    Show export popup with copyable text
    @param text string - The text to display for copying
]]
function Calendar:ShowExportPopup(text)
    if not exportPopup then
        exportPopup = CreateFrame("Frame", "HopeCalendarExport", UIParent, "BackdropTemplate")
        exportPopup:SetSize(400, 300)
        exportPopup:SetPoint("CENTER")
        exportPopup:SetFrameStrata("DIALOG")
        exportPopup:SetFrameLevel(200)

        exportPopup:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 24,
            insets = { left = 6, right = 6, top = 6, bottom = 6 },
        })
        exportPopup:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
        exportPopup:SetBackdropBorderColor(1, 0.84, 0, 1)

        exportPopup:EnableMouse(true)
        exportPopup:SetMovable(true)
        exportPopup:RegisterForDrag("LeftButton")
        exportPopup:SetScript("OnDragStart", exportPopup.StartMoving)
        exportPopup:SetScript("OnDragStop", exportPopup.StopMovingOrSizing)

        -- Title
        local title = exportPopup:CreateFontString(nil, "OVERLAY")
        title:SetFont(HopeAddon.assets.fonts.TITLE, 14, "")
        title:SetPoint("TOP", exportPopup, "TOP", 0, -15)
        title:SetText("Export Roster")
        title:SetTextColor(1, 0.84, 0)

        -- Instructions
        local instructions = exportPopup:CreateFontString(nil, "OVERLAY")
        instructions:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        instructions:SetPoint("TOP", title, "BOTTOM", 0, -4)
        instructions:SetText("Select all (Ctrl+A) and copy (Ctrl+C)")
        instructions:SetTextColor(0.6, 0.6, 0.6)

        -- Scroll frame for edit box
        local scrollFrame = CreateFrame("ScrollFrame", nil, exportPopup, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", exportPopup, "TOPLEFT", 15, -50)
        scrollFrame:SetPoint("BOTTOMRIGHT", exportPopup, "BOTTOMRIGHT", -35, 50)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontHighlightSmall)
        editBox:SetWidth(scrollFrame:GetWidth() - 10)
        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            exportPopup:Hide()
        end)
        scrollFrame:SetScrollChild(editBox)
        exportPopup.editBox = editBox

        -- Close button
        local closeBtn = CreateFrame("Button", nil, exportPopup, "BackdropTemplate")
        closeBtn:SetSize(80, 26)
        closeBtn:SetPoint("BOTTOM", exportPopup, "BOTTOM", 0, 15)
        closeBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        closeBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
        closeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
        closeText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        closeText:SetPoint("CENTER")
        closeText:SetText("Close")
        closeText:SetTextColor(0.8, 0.8, 0.8)

        closeBtn:SetScript("OnClick", function()
            exportPopup:Hide()
        end)
        closeBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        closeBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end)
    end

    exportPopup.editBox:SetText(text)
    exportPopup.editBox:HighlightText()  -- Select all for easy copy
    exportPopup.editBox:SetFocus()
    exportPopup:Show()
end

--============================================================
-- PUBLIC API
--============================================================

-- Make module accessible and register
HopeAddon.Calendar = Calendar
HopeAddon:RegisterModule("Calendar", Calendar)

return Calendar
