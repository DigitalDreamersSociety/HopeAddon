--[[
    HopeAddon Magtheridon Module
    Magtheridon's Lair-specific raid features and UI
]]

local Magtheridon = {}
HopeAddon.Magtheridon = Magtheridon

-- Magtheridon boss ID for encounter detection
Magtheridon.ENCOUNTER_IDS = {
    MAGTHERIDON = 651,
}

-- Cube clicker positions (for raid assignment help)
Magtheridon.CUBE_POSITIONS = {
    { position = "North", x = 0, y = 1 },
    { position = "Northeast", x = 0.7, y = 0.7 },
    { position = "East", x = 1, y = 0 },
    { position = "Southeast", x = 0.7, y = -0.7 },
    { position = "South", x = 0, y = -1 },
}

-- Phase thresholds
Magtheridon.PHASES = {
    CHANNELERS = { start = 100, name = "Phase 1: Channelers" },
    MAGTHERIDON = { start = 100, name = "Phase 2: Magtheridon" },
    COLLAPSE = { start = 30, name = "Phase 3: Collapse" },
}

--[[
    Get Magtheridon raid data
    @return table - Raid data from constants
]]
function Magtheridon:GetRaidData()
    return HopeAddon.Constants.MAGTHERIDON_BOSSES
end

--[[
    Get boss data
    @return table - Magtheridon boss data
]]
function Magtheridon:GetBossData()
    local bosses = self:GetRaidData()
    return bosses[1] -- Only one boss
end

--[[
    Get boss kill count
    @return number - Kill count
]]
function Magtheridon:GetBossKillCount()
    local kills = HopeAddon.charDb.stats.raidClears.magtheridon
    if not kills then return 0 end
    return kills.magtheridon or 0
end

--[[
    Record a boss kill
]]
function Magtheridon:RecordBossKill()
    -- Initialize if needed
    if not HopeAddon.charDb.stats.raidClears.magtheridon then
        HopeAddon.charDb.stats.raidClears.magtheridon = {}
    end

    local kills = HopeAddon.charDb.stats.raidClears.magtheridon
    kills.magtheridon = (kills.magtheridon or 0) + 1

    local boss = self:GetBossData()

    -- Create journal entry for first kill
    if kills.magtheridon == 1 then
        self:CreateFirstKillEntry(boss)
    end

    -- Mag is a single-boss raid, so first kill = full clear
    self:RecordFullClear()
end

--[[
    Create a journal entry for first boss kill
    @param boss table - Boss data
]]
function Magtheridon:CreateFirstKillEntry(boss)
    local entry = {
        type = "boss_kill",
        title = "Magtheridon Defeated!",
        description = boss.lore,
        icon = "Interface\\Icons\\" .. boss.icon,
        raidName = "Magtheridon's Lair",
        bossId = "magtheridon",
        location = boss.location,
        timestamp = HopeAddon:GetTimestamp(),
        party = HopeAddon.FellowTravelers:GetPartySnapshot(),
    }

    table.insert(HopeAddon.charDb.journal.entries, entry)
    HopeAddon.charDb.journal.bossKills.magtheridon = entry

    HopeAddon:Print(HopeAddon:ColorText("THE PIT LORD FALLS!", "FEL_GREEN") ..
        " Magtheridon has been defeated!")

    HopeAddon.Sounds:PlayBossKill()

    -- Notify Badges module of boss kill
    if HopeAddon.Badges then
        HopeAddon.Badges:OnBossKilled("Magtheridon")
    end
end

--[[
    Record full clear (same as boss kill for this raid)
]]
function Magtheridon:RecordFullClear()
    if not HopeAddon.charDb.stats.raidClears.magtheridon_full_clear then
        HopeAddon.charDb.stats.raidClears.magtheridon_full_clear = {
            date = HopeAddon:GetDate(),
            timestamp = HopeAddon:GetTimestamp(),
        }

        local entry = {
            type = "raid_clear",
            title = "Magtheridon's Lair Cleared!",
            description = "The Pit Lord is no more! Hellfire Citadel trembles at your victory.",
            icon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
            raidName = "Magtheridon's Lair",
            timestamp = HopeAddon:GetTimestamp(),
        }
        table.insert(HopeAddon.charDb.journal.entries, entry)

        HopeAddon:Print(HopeAddon:ColorText("MAGTHERIDON'S LAIR CLEARED!", "FEL_GREEN") ..
            " The Pit Lord's prison is empty!")
        HopeAddon.Sounds:PlayEpicFanfare()
    end
end

--[[
    Get progress summary
    @return table - Progress data
]]
function Magtheridon:GetProgressSummary()
    local kills = HopeAddon.charDb.stats.raidClears.magtheridon or {}

    return {
        killed = kills.magtheridon and kills.magtheridon > 0 and 1 or 0,
        total = 1,
        percentage = kills.magtheridon and kills.magtheridon > 0 and 100 or 0,
        fullClear = HopeAddon.charDb.stats.raidClears.magtheridon_full_clear ~= nil,
        fullClearDate = HopeAddon.charDb.stats.raidClears.magtheridon_full_clear and
            HopeAddon.charDb.stats.raidClears.magtheridon_full_clear.date or nil,
        totalKills = kills.magtheridon or 0,
    }
end

--[[
    Get tier token info for Magtheridon's Lair
    @return table - Token drop info
]]
function Magtheridon:GetTierTokens()
    local tokens = HopeAddon.Constants.T4_TOKENS
    local magTokens = {}

    for slot, data in pairs(tokens) do
        if data.raid == "Magtheridon's Lair" then
            magTokens[slot] = data
        end
    end

    return magTokens
end

--[[
    Get boss-specific tips
    @return table - Array of tip strings
]]
function Magtheridon:GetBossTips()
    return {
        -- Phase 1
        "Phase 1: Kill all 5 Hellfire Channelers before Mag breaks free",
        "Assign 1 tank per Channeler - interrupt Dark Mending!",
        "Channelers must all die within ~2 minutes",

        -- Phase 2
        "Phase 2: Use Manticron Cubes to interrupt Blast Nova",
        "5 cube clickers required - coordinate perfectly!",
        "After clicking, you get Mind Exhaustion (90 sec cooldown)",
        "Have backup clickers ready",

        -- Phase 3
        "Phase 3 (<30%): Ceiling collapses - avoid fire debris",
        "Still need to interrupt Blast Nova during collapse!",
        "Burn phase - use Bloodlust/Heroism",

        -- General
        "Drops Tier 4 Chest tokens",
        "Magtheridon's Head starts quest for epic ring reward",
    }
end

--[[
    Get cube clicker assignment template
    @return table - Cube positions with assignment slots
]]
function Magtheridon:GetCubeAssignmentTemplate()
    local template = {}

    for i, cube in ipairs(self.CUBE_POSITIONS) do
        table.insert(template, {
            cubeNumber = i,
            position = cube.position,
            primary = nil,   -- Fill in with player name
            backup = nil,    -- Fill in with backup player
        })
    end

    return template
end

--[[
    Get phase breakdown for display
    @return table - Phase information
]]
function Magtheridon:GetPhaseBreakdown()
    local boss = self:GetBossData()
    return boss.phases or {}
end

--[[
    Get head quest info
    @return table - Quest reward information
]]
function Magtheridon:GetHeadQuestInfo()
    return {
        questName = "The Fall of Magtheridon",
        turnIn = {
            alliance = "Force Commander Danath Trollbane (Honor Hold)",
            horde = "Nazgrel (Thrallmar)",
        },
        rewards = {
            "A'dal's Signet of Defense (Tank ring)",
            "Naaru Lightwarden's Band (Healer ring)",
            "Ring of the Recalcitrant (DPS ring)",
        },
    }
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Magtheridon module loaded")
end
