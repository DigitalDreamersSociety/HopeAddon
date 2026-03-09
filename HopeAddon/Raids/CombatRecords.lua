--[[
    HopeAddon CombatRecords Module
    Persists personal DPS/HPS/deaths after each boss kill.

    Reads from EncounterTracker (ephemeral) and stores to charDb.combatRecords (permanent).
    Only stores YOUR stats, not full raid snapshots.
]]

local CombatRecords = {}
HopeAddon.CombatRecords = CombatRecords

local UnitGUID = UnitGUID
local pairs = pairs
local math_floor = math.floor
local math_max = math.max
local time = time

--[[
    Ensure the combatRecords table exists in charDb
    @return table - The records table
]]
function CombatRecords:EnsureDB()
    if not HopeAddon.charDb then return nil end
    if not HopeAddon.charDb.combatRecords then
        HopeAddon.charDb.combatRecords = {
            version = 1,
            records = {},
        }
    end
    return HopeAddon.charDb.combatRecords
end

--[[
    Record player's combat stats after a boss kill.
    Called from RaidData after FinishEncounter but before AbortTracking.

    @param raidKey string - Raid identifier (e.g. "karazhan")
    @param bossId string - Boss identifier (e.g. "attumen")
    @param killData table - Kill record from RecordBossKill (contains bossName, raidName, icon, etc.)
]]
function CombatRecords:RecordEncounter(raidKey, bossId, killData)
    local db = self:EnsureDB()
    if not db then return end

    local tracker = HopeAddon.EncounterTracker
    if not tracker then return end

    local playerGUID = UnitGUID("player")
    if not playerGUID then return end

    -- Get player stats from EncounterTracker (still available, not yet cleared)
    local stats = tracker:GetPlayerStats(playerGUID)
    if not stats then
        HopeAddon:Debug("CombatRecords: No player stats found in EncounterTracker")
        return
    end

    local dpsRank = tracker:GetPlayerDPSRank(playerGUID)
    local hpsRank = tracker:GetPlayerHPSRank(playerGUID)
    local raidSize = tracker:GetRaidSize()

    -- Get kill time from killData (recorded by RaidData)
    local killTime = killData.lastTime or stats.duration

    -- Build kill history entry
    local killEntry = {
        timestamp = time(),
        date = HopeAddon:GetDate(),
        killTime = math_floor(killTime + 0.5),
        dps = math_floor(stats.dps * 10 + 0.5) / 10,   -- 1 decimal
        hps = math_floor(stats.hps * 10 + 0.5) / 10,
        damage = stats.damage,
        healing = stats.healing,
        damageTaken = stats.damageTaken,
        deaths = stats.deaths,
        dpsRank = dpsRank,
        hpsRank = hpsRank,
        raidSize = raidSize,
    }

    -- Get or create boss record
    local key = raidKey .. "_" .. bossId
    if not db.records[key] then
        db.records[key] = {
            bossName = killData.bossName or bossId,
            raidName = killData.raidName or raidKey,
            raidKey = raidKey,
            bossId = bossId,
            icon = killData.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
            bestDPS = nil,
            bestHPS = nil,
            fastestKill = nil,
            flawlessKills = 0,
            killHistory = {},
            totalKills = 0,
            totalDeaths = 0,
            avgDPS = 0,
        }
    end

    local record = db.records[key]

    -- Prepend to kill history, trim to MAX_KILL_HISTORY
    local maxHistory = HopeAddon.Constants.COMBAT_RECORDS.MAX_KILL_HISTORY or 10
    table.insert(record.killHistory, 1, killEntry)
    while #record.killHistory > maxHistory do
        table.remove(record.killHistory)
    end

    -- Update personal bests
    if killEntry.dps > 0 then
        if not record.bestDPS or killEntry.dps > record.bestDPS.value then
            record.bestDPS = {
                value = killEntry.dps,
                date = killEntry.date,
                killTime = killEntry.killTime,
            }
        end
    end

    if killEntry.hps > 0 then
        if not record.bestHPS or killEntry.hps > record.bestHPS.value then
            record.bestHPS = {
                value = killEntry.hps,
                date = killEntry.date,
                killTime = killEntry.killTime,
            }
        end
    end

    if killEntry.killTime > 0 then
        if not record.fastestKill or killEntry.killTime < record.fastestKill.time then
            record.fastestKill = {
                time = killEntry.killTime,
                date = killEntry.date,
                dps = killEntry.dps,
            }
        end
    end

    -- Flawless kill (0 deaths)
    if killEntry.deaths == 0 then
        record.flawlessKills = record.flawlessKills + 1
    end

    -- Recalculate aggregates
    record.totalKills = record.totalKills + 1
    record.totalDeaths = record.totalDeaths + killEntry.deaths

    -- Average DPS from kill history (last N kills)
    local totalDPS = 0
    local dpsCount = 0
    for _, entry in ipairs(record.killHistory) do
        if entry.dps > 0 then
            totalDPS = totalDPS + entry.dps
            dpsCount = dpsCount + 1
        end
    end
    record.avgDPS = dpsCount > 0 and (math_floor(totalDPS / dpsCount * 10 + 0.5) / 10) or 0

    HopeAddon:Debug("CombatRecords: Recorded", record.bossName,
        "DPS:", killEntry.dps, "HPS:", killEntry.hps, "Deaths:", killEntry.deaths)
end

--[[
    Get a specific boss's combat record
    @param raidKey string
    @param bossId string
    @return table|nil
]]
function CombatRecords:GetBossRecord(raidKey, bossId)
    local db = self:EnsureDB()
    if not db then return nil end
    return db.records[raidKey .. "_" .. bossId]
end

--[[
    Get all combat records
    @return table - The records table (keyed by "raidKey_bossId")
]]
function CombatRecords:GetAllRecords()
    local db = self:EnsureDB()
    if not db then return {} end
    return db.records
end

--[[
    Get cross-boss personal bests (for header cards)
    @return table - { bestDPS, bestHPS, fastestKill } each with value/bossName/date
]]
function CombatRecords:GetGlobalBests()
    local db = self:EnsureDB()
    if not db then return {} end

    local bests = {
        bestDPS = nil,
        bestHPS = nil,
        fastestKill = nil,
    }

    for _, record in pairs(db.records) do
        if record.bestDPS then
            if not bests.bestDPS or record.bestDPS.value > bests.bestDPS.value then
                bests.bestDPS = {
                    value = record.bestDPS.value,
                    bossName = record.bossName,
                    date = record.bestDPS.date,
                }
            end
        end
        if record.bestHPS then
            if not bests.bestHPS or record.bestHPS.value > bests.bestHPS.value then
                bests.bestHPS = {
                    value = record.bestHPS.value,
                    bossName = record.bossName,
                    date = record.bestHPS.date,
                }
            end
        end
        if record.fastestKill then
            if not bests.fastestKill or record.fastestKill.time < bests.fastestKill.time then
                bests.fastestKill = {
                    time = record.fastestKill.time,
                    bossName = record.bossName,
                    date = record.fastestKill.date,
                }
            end
        end
    end

    return bests
end

--[[
    Get aggregate stats across all bosses
    @return table - { totalKills, totalDeaths, flawlessKills, deathRate }
]]
function CombatRecords:GetAggregateStats()
    local db = self:EnsureDB()
    if not db then return { totalKills = 0, totalDeaths = 0, flawlessKills = 0, deathRate = 0 } end

    local totalKills = 0
    local totalDeaths = 0
    local flawlessKills = 0

    for _, record in pairs(db.records) do
        totalKills = totalKills + record.totalKills
        totalDeaths = totalDeaths + record.totalDeaths
        flawlessKills = flawlessKills + record.flawlessKills
    end

    local deathRate = totalKills > 0 and math_floor(totalDeaths / totalKills * 100 + 0.5) or 0

    return {
        totalKills = totalKills,
        totalDeaths = totalDeaths,
        flawlessKills = flawlessKills,
        deathRate = deathRate,
    }
end

--[[
    Clear all combat records
]]
function CombatRecords:ClearAllRecords()
    if HopeAddon.charDb and HopeAddon.charDb.combatRecords then
        HopeAddon.charDb.combatRecords = {
            version = 1,
            records = {},
        }
    end
end
