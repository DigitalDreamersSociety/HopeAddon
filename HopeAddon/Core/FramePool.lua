--[[
    HopeAddon Frame Pool System
    Generic object pool for reusing UI frames instead of creating/destroying

    Usage:
        local pool = HopeAddon.FramePool:New(createFunc, resetFunc)
        local frame = pool:Acquire()
        -- use frame...
        pool:Release(frame)
        pool:ReleaseAll()
]]

HopeAddon = HopeAddon or {}

local FramePool = {}
FramePool.__index = FramePool

--[[
    Create a new frame pool
    @param createFunc function - Function that creates a new frame
    @param resetFunc function - Function that resets a frame before returning to pool
    @return FramePool instance
]]
function FramePool:New(createFunc, resetFunc)
    local pool = setmetatable({}, self)
    pool.available = {}      -- Stack of available frames
    pool.active = {}         -- Currently in use (keyed by frame)
    pool.activeCount = 0     -- Cached count of active frames (avoids O(n) iteration)
    pool.createFunc = createFunc
    pool.resetFunc = resetFunc or function(f) f:Hide() end
    pool.created = 0         -- Total frames created
    pool.name = "UnnamedPool"
    return pool
end

--[[
    Create a named pool (useful for debugging)
    @param name string - Pool name for debugging
    @param createFunc function - Function that creates a new frame
    @param resetFunc function - Function that resets a frame before returning to pool
    @return FramePool instance
]]
function FramePool:NewNamed(name, createFunc, resetFunc)
    local pool = self:New(createFunc, resetFunc)
    pool.name = name
    return pool
end

--[[
    Acquire a frame from the pool
    Returns an existing frame if available, otherwise creates a new one
    @return frame
]]
function FramePool:Acquire()
    local frame = table.remove(self.available)

    if not frame then
        self.created = self.created + 1
        frame = self.createFunc()
        if frame then
            frame._poolIndex = self.created
        end
    end

    if frame then
        self.active[frame] = true
        self.activeCount = self.activeCount + 1
        frame:Show()
    end

    return frame
end

--[[
    Release a frame back to the pool
    @param frame - The frame to release
]]
function FramePool:Release(frame)
    if not frame then return end

    if self.active[frame] then
        self.active[frame] = nil
        self.activeCount = self.activeCount - 1
        self.resetFunc(frame)
        table.insert(self.available, frame)
    end
end

--[[
    Release all active frames back to the pool
]]
function FramePool:ReleaseAll()
    -- Collect frames first to avoid modifying table during iteration
    local toRelease = {}
    for frame in pairs(self.active) do
        toRelease[#toRelease + 1] = frame
    end
    for _, frame in ipairs(toRelease) do
        self:Release(frame)
    end
end

--[[
    Get the number of currently active frames
    @return number
]]
function FramePool:GetActiveCount()
    return self.activeCount
end

--[[
    Get the number of available (pooled) frames
    @return number
]]
function FramePool:GetAvailableCount()
    return #self.available
end

--[[
    Get the total number of frames created
    @return number
]]
function FramePool:GetTotalCreated()
    return self.created
end

--[[
    Get pool statistics
    @return table with active, available, created counts
]]
function FramePool:GetStats()
    return {
        name = self.name,
        active = self:GetActiveCount(),
        available = self:GetAvailableCount(),
        created = self.created,
    }
end

--[[
    Enumerate all active frames
    @param callback function(frame) - Called for each active frame
]]
function FramePool:ForEachActive(callback)
    for frame in pairs(self.active) do
        callback(frame)
    end
end

--[[
    Check if a frame is from this pool and currently active
    @param frame - The frame to check
    @return boolean
]]
function FramePool:IsActive(frame)
    return self.active[frame] == true
end

--[[
    Destroy the pool and all frames
    Useful for cleanup on addon unload
]]
function FramePool:Destroy()
    -- Release all active frames first
    self:ReleaseAll()

    -- Hide and clear all pooled frames
    for _, frame in ipairs(self.available) do
        frame:Hide()
        frame:SetParent(nil)
    end

    self.available = {}
    self.active = {}
    self.activeCount = 0
    self.created = 0
end

-- Export to addon namespace
HopeAddon.FramePool = FramePool

-- Debug message
if HopeAddon.Debug then
    HopeAddon:Debug("FramePool module loaded")
end
