--[[
    HopeAddon EncounterTracker Module
    Combat log parser - collects per-player damage/healing/deaths during boss fights

    Designed to be simple and extensible:
    - Self-contained combat log parsing for TBC 2.4.3
    - Can accept external data from damage meters (Details, Recount, Skada) in future
    - Ephemeral data only - cleared after each encounter
]]

local EncounterTracker = {}
HopeAddon.EncounterTracker = EncounterTracker

-- Lua/WoW API caches
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitClass = UnitClass
local GetNumRaidMembers = GetNumRaidMembers or GetNumGroupMembers
local pairs = pairs
local select = select
local math_floor = math.floor

-- Encounter state (ephemeral, cleared each fight)
local encounterState = {
    active = false,
    startTime = nil,
    endTime = nil,
    raidMembers = {},    -- { [guid] = { name, class } }
    players = {},        -- { [guid] = { name, class, damage, healing, damageTaken, deaths } }
    deathLog = {},       -- { { name, class, timestamp, killerName, spellName }, ... }
    totalDamage = 0,
    totalHealing = 0,
}

-- O(1) lookup table for tracked combat log sub-events
local TRACKED_DAMAGE = {
    SWING_DAMAGE = true,
    SPELL_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
}

local TRACKED_HEALING = {
    SPELL_HEAL = true,
    SPELL_PERIODIC_HEAL = true,
}

--[[
    Snapshot raid members at encounter start
    Builds a GUID-keyed table for O(1) lookups during combat
]]
function EncounterTracker:SnapshotRaid()
    local members = {}

    local numMembers = GetNumRaidMembers()
    if numMembers > 0 then
        for i = 1, numMembers do
            local unit = "raid" .. i
            local guid = UnitGUID(unit)
            local name = UnitName(unit)
            local _, className = UnitClass(unit)
            if guid and name then
                members[guid] = { name = name, class = className or "UNKNOWN" }
            end
        end
    else
        -- Fallback: player only (shouldn't happen in raids)
        local guid = UnitGUID("player")
        local name = UnitName("player")
        local _, className = UnitClass("player")
        if guid then
            members[guid] = { name = name, class = className or "UNKNOWN" }
        end
    end

    return members
end

--[[
    Start tracking a new encounter
    Called on PLAYER_REGEN_DISABLED when in a raid instance
]]
function EncounterTracker:StartTracking()
    -- Snapshot raid composition
    local members = self:SnapshotRaid()

    -- Reset state
    encounterState.active = true
    encounterState.startTime = GetTime()
    encounterState.endTime = nil
    encounterState.raidMembers = members
    encounterState.totalDamage = 0
    encounterState.totalHealing = 0

    -- Initialize per-player stats from raid snapshot
    encounterState.players = {}
    for guid, info in pairs(members) do
        encounterState.players[guid] = {
            name = info.name,
            class = info.class,
            damage = 0,
            healing = 0,
            damageTaken = 0,
            deaths = 0,
        }
    end

    encounterState.deathLog = {}
end

--[[
    Process a single combat log event
    Fast path: check subevent via lookup table, check source/dest in raidMembers

    TBC 2.4.3 combat log args (NO hideCaster):
    arg1=timestamp, arg2=subEvent, arg3=srcGUID, arg4=srcName, arg5=srcFlags,
    arg6=destGUID, arg7=destName, arg8=destFlags, arg9+...=payload
]]
function EncounterTracker:ProcessCombatEvent(...)
    if not encounterState.active then return end

    local timestamp, subEvent, srcGUID, srcName, srcFlags, destGUID, destName, destFlags = ...

    -- UNIT_DIED: check if a raid member died
    if subEvent == "UNIT_DIED" then
        local player = encounterState.players[destGUID]
        if player then
            player.deaths = player.deaths + 1
            local elapsed = GetTime() - (encounterState.startTime or GetTime())
            table.insert(encounterState.deathLog, {
                name = player.name,
                class = player.class,
                timestamp = elapsed,
                killerName = nil,
                spellName = nil,
            })
        end
        return
    end

    -- Damage events: source must be a raid member
    if TRACKED_DAMAGE[subEvent] then
        local player = encounterState.players[srcGUID]
        if not player then return end

        local amount
        if subEvent == "SWING_DAMAGE" then
            amount = select(9, ...) -- arg9 = amount
        else
            amount = select(12, ...) -- arg12 = amount (after spellId, spellName, spellSchool)
        end

        amount = tonumber(amount) or 0
        player.damage = player.damage + amount
        encounterState.totalDamage = encounterState.totalDamage + amount

        -- Also track damage taken on dest if they're a raid member
        local destPlayer = encounterState.players[destGUID]
        if destPlayer then
            destPlayer.damageTaken = destPlayer.damageTaken + amount
        end
        return
    end

    -- Healing events: source must be a raid member
    if TRACKED_HEALING[subEvent] then
        local player = encounterState.players[srcGUID]
        if not player then return end

        local amount = select(12, ...) -- arg12 = amount
        local overhealing = select(13, ...) or 0 -- arg13 = overhealing
        amount = (tonumber(amount) or 0) - (tonumber(overhealing) or 0)
        if amount < 0 then amount = 0 end

        player.healing = player.healing + amount
        encounterState.totalHealing = encounterState.totalHealing + amount
        return
    end

    -- Damage taken from non-raid sources (boss/adds hitting raid members)
    -- SWING_DAMAGE/SPELL_DAMAGE where dest is raid member but source is NOT
    if subEvent == "SWING_DAMAGE" and not encounterState.players[srcGUID] then
        local destPlayer = encounterState.players[destGUID]
        if destPlayer then
            local amount = tonumber(select(9, ...)) or 0
            destPlayer.damageTaken = destPlayer.damageTaken + amount
        end
    elseif (subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE" or subEvent == "RANGE_DAMAGE")
           and not encounterState.players[srcGUID] then
        local destPlayer = encounterState.players[destGUID]
        if destPlayer then
            local amount = tonumber(select(12, ...)) or 0
            destPlayer.damageTaken = destPlayer.damageTaken + amount
        end
    end
end

--[[
    Finish tracking the current encounter (boss killed)
    Returns encounter duration
]]
function EncounterTracker:FinishEncounter()
    if not encounterState.active then return end
    encounterState.active = false
    encounterState.endTime = GetTime()
end

--[[
    Abort tracking (wipe/reset/leave combat without a kill)
]]
function EncounterTracker:AbortTracking()
    encounterState.active = false
    encounterState.startTime = nil
    encounterState.endTime = nil
    encounterState.raidMembers = {}
    encounterState.players = {}
    encounterState.deathLog = {}
    encounterState.totalDamage = 0
    encounterState.totalHealing = 0
end

--[[
    Check if tracker is currently active
]]
function EncounterTracker:IsActive()
    return encounterState.active
end

--[[
    Get sorted encounter summary for display
    Returns top 5 DPS, top 5 HPS, top 3 damage taken, all deaths

    @return table|nil - Summary data, or nil if no data
]]
function EncounterTracker:GetEncounterSummary()
    if not encounterState.startTime then return nil end

    local duration = (encounterState.endTime or GetTime()) - encounterState.startTime
    if duration <= 0 then duration = 1 end

    -- Collect all players with non-zero stats
    local dpsEntries = {}
    local hpsEntries = {}
    local dtEntries = {}

    for guid, player in pairs(encounterState.players) do
        if player.damage > 0 then
            table.insert(dpsEntries, {
                name = player.name,
                class = player.class,
                total = player.damage,
                perSecond = player.damage / duration,
            })
        end
        if player.healing > 0 then
            table.insert(hpsEntries, {
                name = player.name,
                class = player.class,
                total = player.healing,
                perSecond = player.healing / duration,
            })
        end
        if player.damageTaken > 0 then
            table.insert(dtEntries, {
                name = player.name,
                class = player.class,
                total = player.damageTaken,
            })
        end
    end

    -- Sort descending by total
    local function sortDesc(a, b) return a.total > b.total end
    table.sort(dpsEntries, sortDesc)
    table.sort(hpsEntries, sortDesc)
    table.sort(dtEntries, sortDesc)

    -- Trim to top N
    local function trimTo(t, n)
        while #t > n do table.remove(t) end
    end
    trimTo(dpsEntries, 5)
    trimTo(hpsEntries, 5)
    trimTo(dtEntries, 3)

    -- Count total deaths
    local totalDeaths = 0
    for _, player in pairs(encounterState.players) do
        totalDeaths = totalDeaths + player.deaths
    end

    return {
        duration = duration,
        totalDamage = encounterState.totalDamage,
        totalHealing = encounterState.totalHealing,
        topDPS = dpsEntries,
        topHPS = hpsEntries,
        topDamageTaken = dtEntries,
        deaths = encounterState.deathLog,
        totalDeaths = totalDeaths,
    }
end
