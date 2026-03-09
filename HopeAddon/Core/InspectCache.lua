--[[
    InspectCache - Async gear inspection with throttling and caching
    Provides iLevel and GearScore for any nearby player via WoW's inspect API.

    Performance safeguards (standard addon patterns):
    - 1-second throttle between NotifyInspect calls
    - 5-minute cache expiry per player
    - Skips during combat
    - Only 1 pending inspect at a time
    - 3-second timeout for stale pending inspects
]]

local HopeAddon = HopeAddon
local InspectCache = {}
HopeAddon.InspectCache = InspectCache

-- Cache and throttle state
local inspectCache = {}           -- [name] = { avgILvl, gearScore, timestamp }
local CACHE_EXPIRY = 300          -- 5 minutes
local INSPECT_THROTTLE = 1.0     -- 1 second between inspects
local INSPECT_TIMEOUT = 3.0      -- Cancel stale inspects after 3 seconds
local lastInspectTime = 0
local pendingUnit = nil           -- Unit token of pending inspect
local pendingName = nil           -- Name of pending inspect
local pendingStartTime = 0       -- When inspect was requested
local inCombat = false

-- Slot IDs matching Core.lua GEAR_SLOTS (18 slots, skip shirt #4)
local GEAR_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
}

-- Quality multipliers matching Core.lua
local QUALITY_MULTIPLIERS = {
    [0] = 0.0, [1] = 0.5, [2] = 1.0, [3] = 1.5,
    [4] = 2.0, [5] = 2.5, [6] = 3.0, [7] = 2.0,
}

--[[
    Calculate gear score from a unit's equipped items (after inspect ready)
    @param unit string - Unit token (must have inspect data available)
    @return number avgILvl, number gearScore
]]
local function CalculateUnitGearScore(unit)
    local totalScore = 0
    local totalItemLevel = 0
    local itemCount = 0

    for _, slotId in ipairs(GEAR_SLOTS) do
        local itemLink = GetInventoryItemLink(unit, slotId)
        if itemLink then
            local _, _, quality, itemLevel = GetItemInfo(itemLink)
            if itemLevel and itemLevel > 0 then
                local multiplier = QUALITY_MULTIPLIERS[quality or 1] or 1.0
                totalScore = totalScore + (itemLevel * multiplier)
                totalItemLevel = totalItemLevel + itemLevel
                itemCount = itemCount + 1
            end
        end
    end

    local gs = math.floor(totalScore)
    local avgILvl = itemCount > 0 and math.floor(totalItemLevel / itemCount) or 0
    return avgILvl, gs
end

--[[
    Get gear info for a unit. Returns cached data or triggers async inspect.
    @param unit string - Unit token ("target", "mouseover", etc.)
    @return table|nil - { avgILvl, gearScore } or nil if not available yet
]]
function InspectCache:GetPlayerGearInfo(unit)
    if not unit or not UnitIsPlayer(unit) then return nil end

    local name = UnitName(unit)
    if not name then return nil end

    -- Self: use HopeAddon's cached gear score
    if UnitIsUnit(unit, "player") then
        local gs, avgILvl = HopeAddon:GetGearScore()
        if avgILvl and avgILvl > 0 then
            return { avgILvl = avgILvl, gearScore = gs }
        end
        return nil
    end

    -- Check cache first
    local cached = inspectCache[name]
    if cached and (time() - cached.timestamp) < CACHE_EXPIRY then
        return cached
    end

    -- Don't inspect during combat
    if inCombat then return cached end  -- return stale cache if available

    -- Check throttle
    local now = GetTime()
    if (now - lastInspectTime) < INSPECT_THROTTLE then return cached end

    -- Cancel stale pending inspect
    if pendingUnit and (now - pendingStartTime) > INSPECT_TIMEOUT then
        ClearInspectPlayer()
        pendingUnit = nil
        pendingName = nil
    end

    -- Don't start new inspect if one is already pending
    if pendingUnit then return cached end

    -- Check if unit is in range for inspect (must be nearby)
    if not CheckInteractDistance(unit, 1) then return cached end
    if not CanInspect(unit) then return cached end

    -- Start inspect
    pendingUnit = unit
    pendingName = name
    pendingStartTime = now
    lastInspectTime = now
    NotifyInspect(unit)

    return cached  -- Return stale cache while we wait
end

--[[
    Handle INSPECT_READY event - scan the inspected unit's gear
]]
function InspectCache:OnInspectReady()
    if not pendingUnit or not pendingName then return end

    -- Verify the unit is still valid and matches
    local unitName = UnitName(pendingUnit)
    if not unitName or unitName ~= pendingName then
        ClearInspectPlayer()
        pendingUnit = nil
        pendingName = nil
        return
    end

    -- Calculate gear info
    local avgILvl, gearScore = CalculateUnitGearScore(pendingUnit)

    if avgILvl > 0 then
        inspectCache[pendingName] = {
            avgILvl = avgILvl,
            gearScore = gearScore,
            timestamp = time(),
        }

        -- Refresh tooltip if still showing this unit
        self:RefreshTooltip(pendingUnit, pendingName)
    end

    ClearInspectPlayer()
    pendingUnit = nil
    pendingName = nil
end

--[[
    Refresh the tooltip if it's still showing the inspected unit
]]
function InspectCache:RefreshTooltip(unit, name)
    local _, tooltipUnit = GameTooltip:GetUnit()
    if not tooltipUnit then return end

    local tooltipName = UnitName(tooltipUnit)
    if tooltipName ~= name then return end

    -- Re-trigger the tooltip to pick up new data
    -- The OnTooltipSetUnit hook in FellowTravelers will see the cached data now
    GameTooltip:SetUnit(tooltipUnit)
end

--[[
    Called when tooltip is cleared - cancel pending inspects
]]
function InspectCache:OnTooltipCleared()
    -- Don't cancel - let the inspect complete so we have cached data
    -- for the next hover. This is the standard pattern used by TipTac etc.
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "INSPECT_READY" then
        InspectCache:OnInspectReady()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        if pendingUnit then
            ClearInspectPlayer()
            pendingUnit = nil
            pendingName = nil
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    end
end)

HopeAddon:Debug("InspectCache module loaded")
