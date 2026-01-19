--[[
    HopeAddon Timer Module
    TBC-compatible timer utilities (replacement for C_Timer)

    C_Timer.After() and C_Timer.NewTicker() are Retail-only (WoD 6.0+)
    This module provides compatible implementations for TBC Classic.

    Optimized to use a single shared OnUpdate frame with a timer queue
    instead of creating a new frame for each timer.
]]

-- Lua/WoW API caches for hot paths
local CreateFrame = CreateFrame
local table_remove = table.remove
local table_insert = table.insert
local pairs = pairs
local ipairs = ipairs

HopeAddon.Timer = {}
local Timer = HopeAddon.Timer

-- Single shared frame and timer queue
local timerQueue = {}
local timerFrame = CreateFrame("Frame")
local nextTimerId = 1

-- OnUpdate handler processes all active timers
timerFrame:SetScript("OnUpdate", function(self, dt)
    -- Process timers in reverse order to safely remove completed ones
    for i = #timerQueue, 1, -1 do
        local t = timerQueue[i]
        if not t.cancelled then
            t.elapsed = t.elapsed + dt
            if t.elapsed >= t.duration then
                -- Execute callback
                t.callback()

                if t.repeating then
                    -- Preserve remainder for accuracy in repeating timers
                    t.elapsed = t.elapsed - t.duration
                    t.count = t.count + 1

                    -- Check iteration limit
                    if t.iterations and t.count >= t.iterations then
                        table_remove(timerQueue, i)
                    end
                else
                    table_remove(timerQueue, i)
                end
            end
        else
            -- Remove cancelled timers
            table_remove(timerQueue, i)
        end
    end

    -- Hide frame when no timers active to avoid unnecessary OnUpdate calls
    if #timerQueue == 0 then
        self:Hide()
    end
end)

-- Start hidden (will show when timers are added)
timerFrame:Hide()

--[[
    Execute a callback after a delay
    @param delay number - Delay in seconds
    @param callback function - Function to call after delay
    @return table - Timer handle with Cancel() method
]]
function Timer:After(delay, callback)
    if not callback then return nil end

    local timerId = nextTimerId
    nextTimerId = nextTimerId + 1

    local timerEntry = {
        id = timerId,
        elapsed = 0,
        duration = delay,
        callback = callback,
        repeating = false,
        cancelled = false,
    }

    table_insert(timerQueue, timerEntry)

    -- Ensure frame is running
    if not timerFrame:IsShown() then
        timerFrame:Show()
    end

    -- Return handle with Cancel method for compatibility
    return {
        _entry = timerEntry,
        Cancel = function(self)
            self._entry.cancelled = true
        end,
        IsCancelled = function(self)
            return self._entry.cancelled
        end,
    }
end

--[[
    Create a repeating ticker
    @param interval number - Interval between callbacks in seconds
    @param callback function - Function to call on each tick
    @param iterations number|nil - Optional: number of iterations (nil for infinite)
    @return table - Ticker object with Cancel() method
]]
function Timer:NewTicker(interval, callback, iterations)
    if not callback then return nil end

    local timerId = nextTimerId
    nextTimerId = nextTimerId + 1

    local timerEntry = {
        id = timerId,
        elapsed = 0,
        duration = interval,
        callback = callback,
        repeating = true,
        iterations = iterations,
        count = 0,
        cancelled = false,
    }

    table_insert(timerQueue, timerEntry)

    -- Ensure frame is running
    if not timerFrame:IsShown() then
        timerFrame:Show()
    end

    -- Return ticker object with Cancel method
    local ticker = {
        _entry = timerEntry,
        _cancelled = false,
    }

    function ticker:Cancel()
        if not self._cancelled then
            self._entry.cancelled = true
            self._cancelled = true
        end
    end

    function ticker:IsCancelled()
        return self._cancelled
    end

    return ticker
end

--[[
    Schedule multiple callbacks with different delays
    @param callbacks table - Array of {delay, callback} pairs
]]
function Timer:ScheduleMultiple(callbacks)
    for _, item in ipairs(callbacks) do
        local delay, callback = item[1], item[2]
        self:After(delay, callback)
    end
end

--[[
    Get current active timer count (for debugging)
    @return number
]]
function Timer:GetActiveCount()
    return #timerQueue
end

--[[
    Cancel all active timers (for cleanup)
]]
function Timer:CancelAll()
    for _, t in ipairs(timerQueue) do
        t.cancelled = true
    end
    wipe(timerQueue)
    timerFrame:Hide()
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Timer module loaded (optimized single-frame)")
end
