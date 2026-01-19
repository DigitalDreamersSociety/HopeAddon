--[[
    HopeAddon Milestones Module
    Level milestone tracking and management
]]

local Milestones = {}
HopeAddon.Milestones = Milestones

--[[
    Module lifecycle: OnInitialize
]]
function Milestones:OnInitialize()
end

--[[
    Module lifecycle: OnEnable
]]
function Milestones:OnEnable()
end

--[[
    Module lifecycle: OnDisable
]]
function Milestones:OnDisable()
end

-- Milestone level thresholds
Milestones.LEVELS = { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 58, 60, 65, 70 }

-- Major milestone levels (get special treatment)
Milestones.MAJOR_LEVELS = { 40, 58, 60, 70 }

--[[
    Check if a level is a milestone
    @param level number - Player level
    @return boolean
]]
function Milestones:IsMilestone(level)
    for _, milestoneLevel in ipairs(self.LEVELS) do
        if level == milestoneLevel then
            return true
        end
    end
    return false
end

--[[
    Check if a level is a major milestone
    @param level number - Player level
    @return boolean
]]
function Milestones:IsMajorMilestone(level)
    for _, majorLevel in ipairs(self.MAJOR_LEVELS) do
        if level == majorLevel then
            return true
        end
    end
    return false
end

--[[
    Get milestone data for a level
    @param level number - Player level
    @return table|nil - Milestone data or nil
]]
function Milestones:GetMilestoneData(level)
    return HopeAddon.Constants.LEVEL_MILESTONES[level]
end

--[[
    Get the next milestone level
    @param currentLevel number - Current player level
    @return number|nil - Next milestone level or nil if at max
]]
function Milestones:GetNextMilestone(currentLevel)
    for _, level in ipairs(self.LEVELS) do
        if level > currentLevel then
            return level
        end
    end
    return nil
end

--[[
    Get progress to next milestone as percentage
    @param currentLevel number - Current level
    @return number, number - Percentage, levels remaining
]]
function Milestones:GetProgressToNext(currentLevel)
    local nextMilestone = self:GetNextMilestone(currentLevel)
    if not nextMilestone then
        return 100, 0
    end

    -- Find previous milestone
    local prevMilestone = 1
    for i = #self.LEVELS, 1, -1 do
        if self.LEVELS[i] < currentLevel then
            prevMilestone = self.LEVELS[i]
            break
        end
    end

    local totalLevels = nextMilestone - prevMilestone
    local levelsCompleted = currentLevel - prevMilestone
    local percentage = (levelsCompleted / totalLevels) * 100

    return percentage, nextMilestone - currentLevel
end

--[[
    Record a milestone achievement
    @param level number - Milestone level
    @return table - The created entry
]]
function Milestones:RecordMilestone(level)
    local milestoneData = self:GetMilestoneData(level)
    if not milestoneData then
        HopeAddon:Debug("No milestone data for level", level)
        return nil
    end

    -- Check if already recorded
    if HopeAddon.charDb.journal.levelMilestones[level] then
        HopeAddon:Debug("Milestone already recorded for level", level)
        return HopeAddon.charDb.journal.levelMilestones[level]
    end

    -- Create entry
    local entry = {
        type = "level_milestone",
        level = level,
        title = milestoneData.title,
        story = milestoneData.story,
        icon = "Interface\\Icons\\" .. milestoneData.icon,
        zone = GetZoneText(),
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),

        -- Stats snapshot
        stats = {
            deaths = HopeAddon.charDb.stats.deaths.total,
            quests = HopeAddon.charDb.stats.questsCompleted,
            zonesDiscovered = 0, -- Will be counted
        },
    }

    -- Count zones
    for _ in pairs(HopeAddon.charDb.journal.zoneDiscoveries) do
        entry.stats.zonesDiscovered = entry.stats.zonesDiscovered + 1
    end

    -- Save
    HopeAddon.charDb.journal.levelMilestones[level] = entry
    table.insert(HopeAddon.charDb.journal.entries, entry)

    HopeAddon:Debug("Recorded milestone:", milestoneData.title)

    -- Notify Badges module of level up
    if HopeAddon.Badges then
        HopeAddon.Badges:OnPlayerLevelUp(level)
    end

    return entry
end

--[[
    Get all recorded milestones
    @return table - Array of milestone entries sorted by level
]]
function Milestones:GetRecordedMilestones()
    local recorded = {}

    for level, entry in pairs(HopeAddon.charDb.journal.levelMilestones) do
        entry.level = level
        table.insert(recorded, entry)
    end

    table.sort(recorded, function(a, b)
        return a.level < b.level
    end)

    return recorded
end

--[[
    Get milestone completion stats
    @return number, number - Completed count, total count
]]
function Milestones:GetCompletionStats()
    local completed = 0
    local playerLevel = UnitLevel("player")

    for _, level in ipairs(self.LEVELS) do
        if level <= playerLevel then
            completed = completed + 1
        end
    end

    return completed, #self.LEVELS
end

--[[
    Check and record any missed milestones
    Called on login to catch up milestones for existing characters
]]
function Milestones:CatchUpMilestones()
    local playerLevel = UnitLevel("player")

    for _, level in ipairs(self.LEVELS) do
        if level <= playerLevel and not HopeAddon.charDb.journal.levelMilestones[level] then
            -- Record retroactively
            local milestoneData = self:GetMilestoneData(level)
            if milestoneData then
                local entry = {
                    type = "level_milestone",
                    level = level,
                    title = milestoneData.title,
                    story = milestoneData.story,
                    icon = "Interface\\Icons\\" .. milestoneData.icon,
                    zone = "Unknown (Retroactive)",
                    timestamp = HopeAddon:GetTimestamp(),
                    date = "Retroactive",
                    retroactive = true,
                }

                HopeAddon.charDb.journal.levelMilestones[level] = entry
                table.insert(HopeAddon.charDb.journal.entries, entry)

                HopeAddon:Debug("Retroactively recorded milestone:", milestoneData.title)
            end
        end
    end
end

--[[
    Get the act name for a level
    @param level number - Player level
    @return string - Act name
]]
function Milestones:GetActName(level)
    if level <= 20 then
        return "The Awakening"
    elseif level <= 57 then
        return "The Journey"
    else
        return "Through the Dark Portal"
    end
end

--[[
    Get chapter number for a level
    @param level number - Milestone level
    @return number - Chapter number (1-18)
]]
function Milestones:GetChapterNumber(level)
    local HERO_PAGES = HopeAddon.Constants.HERO_PAGES
    for _, page in ipairs(HERO_PAGES) do
        if page.level == level then
            return page.chapter
        end
    end
    return 0
end

--============================================================
-- ATTUNEMENT MILESTONES
--============================================================

--[[
    Record attunement completion milestone
    @param raidKey string - Raid identifier
    @return table|nil - The created entry or nil
]]
function Milestones:RecordAttunementMilestone(raidKey)
    local C = HopeAddon.Constants
    local milestoneData = C.ATTUNEMENT_MILESTONES[raidKey]
    if not milestoneData then
        HopeAddon:Debug("No attunement milestone data for:", raidKey)
        return nil
    end

    -- Initialize storage
    HopeAddon.charDb.journal.attunementMilestones = HopeAddon.charDb.journal.attunementMilestones or {}

    -- Check if already recorded
    if HopeAddon.charDb.journal.attunementMilestones[raidKey] then
        HopeAddon:Debug("Attunement milestone already recorded:", raidKey)
        return HopeAddon.charDb.journal.attunementMilestones[raidKey]
    end

    -- Create entry
    local entry = {
        type = "attunement_milestone",
        raidKey = raidKey,
        title = milestoneData.title,
        story = milestoneData.story,
        icon = "Interface\\Icons\\" .. milestoneData.icon,
        zone = GetZoneText(),
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),
    }

    -- Save
    HopeAddon.charDb.journal.attunementMilestones[raidKey] = entry
    table.insert(HopeAddon.charDb.journal.entries, entry)

    HopeAddon:Debug("Recorded attunement milestone:", milestoneData.title)

    return entry
end

--============================================================
-- BOSS KILL MILESTONES
--============================================================

--[[
    Record boss kill milestone
    @param bossId string - Boss identifier
    @param raidKey string - Raid identifier
    @param bossName string - Boss display name
    @return table|nil - The created entry or nil
]]
function Milestones:RecordBossMilestone(bossId, raidKey, bossName)
    local C = HopeAddon.Constants
    local milestoneData = C.BOSS_MILESTONES[bossId]
    if not milestoneData then
        -- Check if this is a final boss without specific milestone
        return nil
    end

    -- Initialize storage
    HopeAddon.charDb.journal.bossMilestones = HopeAddon.charDb.journal.bossMilestones or {}

    -- Check if already recorded
    local key = raidKey .. "_" .. bossId
    if HopeAddon.charDb.journal.bossMilestones[key] then
        HopeAddon:Debug("Boss milestone already recorded:", key)
        return HopeAddon.charDb.journal.bossMilestones[key]
    end

    -- Create entry
    local entry = {
        type = "boss_milestone",
        bossId = bossId,
        raidKey = raidKey,
        bossName = bossName,
        title = milestoneData.title,
        story = milestoneData.story,
        icon = "Interface\\Icons\\" .. milestoneData.icon,
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),
    }

    -- Save
    HopeAddon.charDb.journal.bossMilestones[key] = entry
    table.insert(HopeAddon.charDb.journal.entries, entry)

    HopeAddon:Debug("Recorded boss milestone:", milestoneData.title)

    return entry
end

--[[
    Check for tier milestones on boss kill
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
]]
function Milestones:CheckTierMilestone(raidKey, bossId)
    local C = HopeAddon.Constants

    -- Initialize storage
    HopeAddon.charDb.journal.tierMilestones = HopeAddon.charDb.journal.tierMilestones or {}

    -- Determine tier from raid
    local tier = HopeAddon.Constants:GetRaidTier(raidKey)
    if not tier then return end

    -- Check for first boss in tier
    local tierKey = "first_" .. string.lower(tier) .. "_boss"
    if not HopeAddon.charDb.journal.tierMilestones[tierKey] then
        local milestoneData = C.BOSS_MILESTONES[tierKey]
        if milestoneData then
            local entry = {
                type = "tier_milestone",
                tier = tier,
                title = milestoneData.title,
                story = milestoneData.story,
                icon = "Interface\\Icons\\" .. milestoneData.icon,
                timestamp = HopeAddon:GetTimestamp(),
                date = HopeAddon:GetDate(),
                firstRaid = raidKey,
                firstBoss = bossId,
            }

            HopeAddon.charDb.journal.tierMilestones[tierKey] = entry
            table.insert(HopeAddon.charDb.journal.entries, entry)

            HopeAddon:Debug("Recorded tier milestone:", milestoneData.title)
        end
    end

    -- Check for final boss milestones
    local finalBosses = {
        prince = { tier = "T4", raid = "karazhan" },
        gruul = { tier = "T4", raid = "gruul" },
        magtheridon = { tier = "T4", raid = "magtheridon" },
        vashj = { tier = "T5", raid = "ssc" },
        kaelthas = { tier = "T5", raid = "tk" },
        archimonde = { tier = "T6", raid = "hyjal" },
        illidan = { tier = "T6", raid = "bt" },
    }

    if finalBosses[bossId] and finalBosses[bossId].raid == raidKey then
        local milestoneData = C.BOSS_MILESTONES[bossId]
        if milestoneData then
            local key = raidKey .. "_final"
            if not HopeAddon.charDb.journal.bossMilestones[key] then
                HopeAddon.charDb.journal.bossMilestones = HopeAddon.charDb.journal.bossMilestones or {}

                local entry = {
                    type = "final_boss_milestone",
                    bossId = bossId,
                    raidKey = raidKey,
                    title = milestoneData.title,
                    story = milestoneData.story,
                    icon = "Interface\\Icons\\" .. milestoneData.icon,
                    timestamp = HopeAddon:GetTimestamp(),
                    date = HopeAddon:GetDate(),
                }

                HopeAddon.charDb.journal.bossMilestones[key] = entry
                table.insert(HopeAddon.charDb.journal.entries, entry)

                -- Check for raid leader milestone (first final boss ever)
                if not HopeAddon.charDb.journal.raidLeaderMilestone then
                    local raidLeaderData = C.BOSS_MILESTONES.raid_leader
                    if raidLeaderData then
                        local raidLeaderEntry = {
                            type = "raid_leader_milestone",
                            title = raidLeaderData.title,
                            story = raidLeaderData.story,
                            icon = "Interface\\Icons\\" .. raidLeaderData.icon,
                            timestamp = HopeAddon:GetTimestamp(),
                            date = HopeAddon:GetDate(),
                            firstFinalBoss = bossId,
                            firstFinalRaid = raidKey,
                        }

                        HopeAddon.charDb.journal.raidLeaderMilestone = raidLeaderEntry
                        table.insert(HopeAddon.charDb.journal.entries, raidLeaderEntry)

                        HopeAddon:Debug("Recorded raid leader milestone!")
                    end
                end

                HopeAddon:Debug("Recorded final boss milestone:", milestoneData.title)
            end
        end
    end
end

--[[
    Get all attunement milestones
    @return table - Array of attunement milestone entries
]]
function Milestones:GetAttunementMilestones()
    local milestones = HopeAddon.charDb.journal.attunementMilestones or {}
    local result = {}

    for raidKey, entry in pairs(milestones) do
        entry.raidKey = raidKey
        table.insert(result, entry)
    end

    table.sort(result, function(a, b)
        return (a.timestamp or "") < (b.timestamp or "")
    end)

    return result
end

--[[
    Get all boss milestones
    @return table - Array of boss milestone entries
]]
function Milestones:GetBossMilestones()
    local milestones = HopeAddon.charDb.journal.bossMilestones or {}
    local result = {}

    for key, entry in pairs(milestones) do
        table.insert(result, entry)
    end

    table.sort(result, function(a, b)
        return (a.timestamp or "") < (b.timestamp or "")
    end)

    return result
end

-- Register with addon
HopeAddon:RegisterModule("Milestones", Milestones)
if HopeAddon.Debug then
    HopeAddon:Debug("Milestones module loaded")
end
