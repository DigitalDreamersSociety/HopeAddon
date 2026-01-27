--[[
    HopeAddon Calendar Validation Module
    Validates event creation and signup attempts
]]

local CalendarValidation = {}

-- Module references (populated on enable)
local C = nil
local Calendar = nil

--============================================================
-- INITIALIZATION
--============================================================

function CalendarValidation:OnInitialize()
    C = HopeAddon.Constants
    HopeAddon:Debug("CalendarValidation: Initialized")
end

function CalendarValidation:OnEnable()
    Calendar = HopeAddon.Calendar
    HopeAddon:Debug("CalendarValidation: Enabled")
end

function CalendarValidation:OnDisable()
    HopeAddon:Debug("CalendarValidation: Disabled")
end

--============================================================
-- EVENT VALIDATION
--============================================================

--[[
    Get Unix timestamp for event based on date and startTime
    @param eventData table - Event data with date and startTime fields
    @return number - Unix timestamp (0 if invalid)
]]
function CalendarValidation:GetEventTimestamp(eventData)
    if not eventData or not eventData.date or not eventData.startTime then
        return 0
    end

    local year, month, day = eventData.date:match("^(%d+)-(%d+)-(%d+)$")
    if not year then return 0 end

    local hour, minute = eventData.startTime:match("^(%d+):(%d+)$")
    hour = tonumber(hour) or 19
    minute = tonumber(minute) or 0

    return time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = hour,
        min = minute,
        sec = 0,
    })
end

--[[
    Validate event creation
    @param eventData table - Event data to validate
    @return boolean isValid, table errors
]]
function CalendarValidation:ValidateEventCreate(eventData)
    local errors = {}
    local validation = C.CALENDAR_VALIDATION

    -- Check required fields
    if not eventData.date then
        table.insert(errors, "Date is required")
    end
    if not eventData.startTime then
        table.insert(errors, "Start time is required")
    end

    -- Early return if missing required fields
    if #errors > 0 then
        return false, errors
    end

    local eventTimestamp = self:GetEventTimestamp(eventData)

    -- Check date is not in past
    if not validation.ALLOW_PAST_EVENTS then
        if eventTimestamp > 0 and eventTimestamp < time() then
            table.insert(errors, "Event cannot be in the past")
        end
    end

    -- Check minimum notice
    if eventTimestamp > 0 then
        local minNotice = validation.MIN_NOTICE_MINUTES * 60
        if (eventTimestamp - time()) < minNotice then
            table.insert(errors, "Event must be at least " .. validation.MIN_NOTICE_MINUTES .. " minutes in the future")
        end
    end

    -- Check max future days
    if eventTimestamp > 0 then
        local maxFuture = validation.MAX_FUTURE_DAYS * 86400
        if (eventTimestamp - time()) > maxFuture then
            table.insert(errors, "Event cannot be more than " .. validation.MAX_FUTURE_DAYS .. " days in advance")
        end
    end

    -- Validate role slots add up correctly
    if eventData.raidSize then
        local totalSlots = (eventData.maxTanks or 0) + (eventData.maxHealers or 0) + (eventData.maxDPS or 0)
        if totalSlots > 0 and totalSlots ~= eventData.raidSize then
            -- This is a warning, not an error - just adjust
            HopeAddon:Debug("CalendarValidation: Role slots (" .. totalSlots .. ") don't match raid size (" .. eventData.raidSize .. ")")
        end
    end

    return #errors == 0, errors
end

--============================================================
-- SIGNUP VALIDATION
--============================================================

--[[
    Count total non-declined signups for an event
    @param event table - Event data
    @return number - Total signup count
]]
function CalendarValidation:CountSignups(event)
    if not event or not event.signups then return 0 end

    local count = 0
    for _, signup in pairs(event.signups) do
        if signup.status ~= "declined" then
            count = count + 1
        end
    end
    return count
end

--[[
    Count how many events a player is signed up for
    @param playerName string
    @return number - Signup count
]]
function CalendarValidation:CountPlayerSignups(playerName)
    if not Calendar then return 0 end

    local cal = Calendar:GetCalendarData()
    if not cal or not cal.mySignups then return 0 end

    local count = 0
    for eventId, signup in pairs(cal.mySignups) do
        -- Only count valid future events
        local event = Calendar:GetEvent(eventId)
        if event and not Calendar:IsEventPast(event) then
            count = count + 1
        end
    end
    return count
end

--[[
    Find overlapping events for a player
    @param playerName string
    @param newEvent table - Event being signed up for
    @return table - Array of conflicting events
]]
function CalendarValidation:FindTimeConflicts(playerName, newEvent)
    local conflicts = {}

    if not Calendar or not newEvent then return conflicts end

    local cal = Calendar:GetCalendarData()
    if not cal then return conflicts end

    local newStart = self:GetEventTimestamp(newEvent)
    if newStart == 0 then return conflicts end

    -- Assume 3 hour default duration
    local newEnd = newStart + (newEvent.duration or 10800)

    -- Check events player is signed up for
    for eventId, signup in pairs(cal.mySignups or {}) do
        local event = Calendar:GetEvent(eventId)
        if event and event.id ~= newEvent.id then
            local existStart = self:GetEventTimestamp(event)
            if existStart > 0 then
                local existEnd = existStart + (event.duration or 10800)

                -- Check overlap: newStart < existEnd AND newEnd > existStart
                if newStart < existEnd and newEnd > existStart then
                    table.insert(conflicts, event)
                end
            end
        end
    end

    return conflicts
end

--[[
    Validate signup attempt
    @param eventId string - Event to sign up for
    @param playerName string - Player signing up
    @param role string - Role being signed up for
    @return boolean isValid, table errors, boolean shouldStandby, table warnings
]]
function CalendarValidation:ValidateSignup(eventId, playerName, role)
    local errors = {}
    local warnings = {}
    local shouldStandby = false
    local validation = C.CALENDAR_VALIDATION

    if not Calendar then
        return false, { "Calendar module not available" }, false, {}
    end

    local event = Calendar:GetEvent(eventId)
    if not event then
        return false, { "Event not found" }, false, {}
    end

    -- Check if event is in the past
    if Calendar:IsEventPast(event) then
        table.insert(errors, "Cannot sign up for past events")
        return false, errors, false, {}
    end

    -- Check role capacity
    if validation.ENFORCE_ROLE_LIMITS then
        if Calendar:IsRoleFull(event, role) then
            -- Don't treat as error - suggest standby
            shouldStandby = true
            HopeAddon:Debug("CalendarValidation: Role full, suggesting standby for", role)
        end
    end

    -- Check total raid size
    if validation.ENFORCE_RAID_SIZE then
        local totalSignups = self:CountSignups(event)
        if totalSignups >= (event.raidSize or 10) then
            -- Allow signing up as standby even if full
            shouldStandby = true
            HopeAddon:Debug("CalendarValidation: Raid full (" .. totalSignups .. "/" .. event.raidSize .. "), suggesting standby")
        end
    end

    -- Time conflicts are now warnings, not errors (informational only)
    local conflicts = self:FindTimeConflicts(playerName, event)
    if #conflicts > 0 then
        for _, conflict in ipairs(conflicts) do
            local conflictName = conflict.title or "another event"
            local conflictTime = conflict.startTime or "TBD"
            table.insert(warnings, "Overlaps with: " .. conflictName .. " at " .. conflictTime)
        end
        HopeAddon:Debug("CalendarValidation: Found", #conflicts, "time conflict(s) - showing as warnings")
    end

    return #errors == 0, errors, shouldStandby, warnings
end

--============================================================
-- PUBLIC API
--============================================================

-- Make module accessible and register
HopeAddon.CalendarValidation = CalendarValidation
HopeAddon:RegisterModule("CalendarValidation", CalendarValidation)

return CalendarValidation
