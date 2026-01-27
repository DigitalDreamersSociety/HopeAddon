--[[
    HopeAddon Calendar Module
    Core event management for raid/event scheduling
]]

local Calendar = {}
HopeAddon:RegisterModule("Calendar", Calendar)

-- Module references (populated on enable)
local C = nil
local Timer = nil
local FellowTravelers = nil
local ActivityFeed = nil
local SocialToasts = nil

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

    -- Validate required fields
    if not eventData.date then
        return nil, "Date is required"
    end
    if not eventData.startTime then
        return nil, "Start time is required"
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

    return cal.myEvents[eventId] or cal.fellowEvents[eventId]
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
-- EVENT QUERIES
--============================================================

--[[
    Get all events for a specific date
    @param dateStr string - YYYY-MM-DD
    @return table - Array of events
]]
function Calendar:GetEventsForDate(dateStr)
    local cal = self:GetCalendarData()
    if not cal then return {} end

    local events = {}

    -- My events
    for _, event in pairs(cal.myEvents) do
        if event.date == dateStr then
            table.insert(events, event)
        end
    end

    -- Fellow events
    for _, event in pairs(cal.fellowEvents) do
        if event.date == dateStr then
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

    -- Collect future events
    for _, event in pairs(cal.myEvents) do
        if event.date >= today then
            table.insert(events, event)
        end
    end
    for _, event in pairs(cal.fellowEvents) do
        if event.date >= today then
            table.insert(events, event)
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

    for _, event in pairs(cal.myEvents) do
        if event.date < today and event.createdAt >= cutoffTime then
            table.insert(events, event)
        end
    end
    for _, event in pairs(cal.fellowEvents) do
        if event.date < today and event.createdAt >= cutoffTime then
            table.insert(events, event)
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
    Get events for a month (for calendar grid display)
    @param year number
    @param month number (1-12)
    @return table - Map of date string to event count
]]
function Calendar:GetEventsForMonth(year, month)
    local cal = self:GetCalendarData()
    if not cal then return {} end

    local monthStr = string.format("%04d-%02d", year, month)
    local eventsByDate = {}

    for _, event in pairs(cal.myEvents) do
        if event.date and event.date:sub(1, 7) == monthStr then
            eventsByDate[event.date] = (eventsByDate[event.date] or 0) + 1
        end
    end

    for _, event in pairs(cal.fellowEvents) do
        if event.date and event.date:sub(1, 7) == monthStr then
            eventsByDate[event.date] = (eventsByDate[event.date] or 0) + 1
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

    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")

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

    signup.status = status

    -- Update event signup if we have it
    local event = self:GetEvent(eventId)
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

    -- Remove from mySignups
    cal.mySignups[eventId] = nil

    -- Remove from event signups
    local event = self:GetEvent(eventId)
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

--============================================================
-- NOTIFICATION SYSTEM
--============================================================

--[[
    Start the notification checker
]]
function Calendar:StartNotificationChecker()
    if notificationTicker then return end

    notificationTicker = Timer:Every(C.CALENDAR_TIMINGS.NOTIFICATION_CHECK_INTERVAL, function()
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

    -- Clean fellow events
    toRemove = {}
    for eventId, event in pairs(cal.fellowEvents) do
        local eventTime = self:GetEventTimestamp(event)
        if time() - eventTime > expiryTime then
            table.insert(toRemove, eventId)
        end
    end
    for _, eventId in ipairs(toRemove) do
        cal.fellowEvents[eventId] = nil
    end

    -- Clean old signups
    for eventId in pairs(cal.mySignups) do
        if not self:GetEvent(eventId) then
            cal.mySignups[eventId] = nil
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
    -- Format: id|title|type|raidKey|date|time|size|tanks|healers|dps|desc|leader|class
    return string.format("%s|%s|%s|%s|%s|%s|%d|%d|%d|%d|%s|%s|%s",
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
        event.leaderClass or ""
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
-- PUBLIC API
--============================================================

-- Make module accessible
HopeAddon.Calendar = Calendar

return Calendar
