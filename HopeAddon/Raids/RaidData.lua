--[[
    HopeAddon RaidData Module
    T4 raid boss information and tracking
]]

local RaidData = {}
HopeAddon.RaidData = RaidData

-- Raid tiers
RaidData.TIERS = {
    T4 = {
        name = "Tier 4",
        raids = { "Karazhan", "Gruul's Lair", "Magtheridon's Lair" },
    },
    T5 = {
        name = "Tier 5",
        raids = { "Serpentshrine Cavern", "Tempest Keep: The Eye" },
    },
    T6 = {
        name = "Tier 6",
        raids = { "Mount Hyjal", "Black Temple" },
    },
}

-- Raid categories
RaidData.RAIDS = {
    karazhan = {
        name = "Karazhan",
        shortName = "Kara",
        size = 10,
        tier = "T4",
        location = "Deadwind Pass",
        requiresAttunement = true,
        icon = "INV_Misc_Key_10",
        lore = "Once the home of the Guardian Medivh, Karazhan is a nexus of magical energies.",
        bosses = HopeAddon.Constants.KARAZHAN_BOSSES,
    },
    gruul = {
        name = "Gruul's Lair",
        shortName = "Gruul",
        size = 25,
        tier = "T4",
        location = "Blade's Edge Mountains",
        requiresAttunement = false,
        icon = "Ability_Hunter_Pet_Devilsaur",
        lore = "Gruul the Dragonkiller earned his name by slaughtering the black dragonflight.",
        bosses = HopeAddon.Constants.GRUUL_BOSSES,
    },
    magtheridon = {
        name = "Magtheridon's Lair",
        shortName = "Mag",
        size = 25,
        tier = "T4",
        location = "Hellfire Citadel",
        requiresAttunement = false,
        icon = "Spell_Shadow_SummonFelGuard",
        lore = "The former Lord of Outland, Magtheridon was defeated by Illidan and imprisoned.",
        bosses = HopeAddon.Constants.MAGTHERIDON_BOSSES,
    },
    -- Tier 5 Raids
    ssc = {
        name = "Serpentshrine Cavern",
        shortName = "SSC",
        size = 25,
        tier = "T5",
        location = "Coilfang Reservoir, Zangarmarsh",
        requiresAttunement = true,
        attunementKey = "ssc",
        icon = "Spell_Frost_SummonWaterElemental",
        lore = "Lady Vashj commands the naga from the depths of Coilfang Reservoir.",
        bosses = HopeAddon.Constants.SSC_BOSSES,
    },
    tk = {
        name = "Tempest Keep: The Eye",
        shortName = "TK",
        size = 25,
        tier = "T5",
        location = "Netherstorm",
        requiresAttunement = true,
        attunementKey = "tk",
        icon = "Spell_Fire_BurnoutGreen",
        lore = "Kael'thas Sunstrider plots his return to power from this floating fortress.",
        bosses = HopeAddon.Constants.TK_BOSSES,
    },
    -- Tier 6 Raids
    hyjal = {
        name = "Mount Hyjal",
        shortName = "Hyjal",
        size = 25,
        tier = "T6",
        location = "Caverns of Time, Tanaris",
        requiresAttunement = true,
        attunementKey = "hyjal",
        icon = "INV_Potion_101",
        lore = "Travel through time to witness the Battle for Mount Hyjal and help defend the World Tree.",
        bosses = HopeAddon.Constants.HYJAL_BOSSES,
    },
    bt = {
        name = "Black Temple",
        shortName = "BT",
        size = 25,
        tier = "T6",
        location = "Shadowmoon Valley",
        requiresAttunement = true,
        attunementKey = "bt",
        icon = "Achievement_Boss_Illidan",
        lore = "Illidan Stormrage rules Outland from the Black Temple, former Temple of Karabor.",
        bosses = HopeAddon.Constants.BT_BOSSES,
    },
}

--[[
    Get raid data by key
    @param raidKey string - Raid identifier (karazhan, gruul, magtheridon)
    @return table|nil - Raid data
]]
function RaidData:GetRaid(raidKey)
    return self.RAIDS[raidKey]
end

--[[
    Get all bosses for a raid
    @param raidKey string - Raid identifier
    @return table - Array of boss data
]]
function RaidData:GetBosses(raidKey)
    local raid = self:GetRaid(raidKey)
    if raid and raid.bosses then
        return raid.bosses
    end
    return {}
end

--[[
    Get boss by ID
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @return table|nil - Boss data
]]
function RaidData:GetBoss(raidKey, bossId)
    local bosses = self:GetBosses(raidKey)
    for _, boss in ipairs(bosses) do
        if boss.id == bossId then
            return boss
        end
    end
    return nil
end

--[[
    Get T4 token information
    @param tokenSlot string - Token slot (helm, shoulders, gloves, legs, chest)
    @return table|nil - Token data
]]
function RaidData:GetTokenInfo(tokenSlot)
    return HopeAddon.Constants.T4_TOKENS[tokenSlot]
end

--[[
    Get which classes can use a token
    @param tokenSlot string - Token slot
    @param tokenName string - Token name (Fallen Champion, etc.)
    @return table - Array of class names
]]
function RaidData:GetTokenClasses(tokenSlot, tokenName)
    local tokenInfo = self:GetTokenInfo(tokenSlot)
    if tokenInfo and tokenInfo.classes then
        return tokenInfo.classes[tokenName] or {}
    end
    return {}
end

--[[
    Record a boss kill
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @return table - Kill entry
]]
function RaidData:RecordBossKill(raidKey, bossId)
    local boss = self:GetBoss(raidKey, bossId)
    if not boss then
        HopeAddon:Debug("Unknown boss:", raidKey, bossId)
        return nil
    end

    local raid = self:GetRaid(raidKey)
    local key = raidKey .. "_" .. bossId

    -- Initialize or update kill record
    local kills = HopeAddon.charDb.journal.bossKills
    if not kills[key] then
        kills[key] = {
            type = "boss_kill",
            raidKey = raidKey,
            bossId = bossId,
            bossName = boss.name,
            raidName = raid.name,
            location = boss.location,
            lore = boss.lore,
            firstKill = HopeAddon:GetDate(),
            firstKillTimestamp = HopeAddon:GetTimestamp(),
            totalKills = 0,
            icon = "Interface\\Icons\\" .. (boss.icon or raid.icon),
        }
    end

    kills[key].totalKills = kills[key].totalKills + 1
    kills[key].lastKill = HopeAddon:GetDate()

    -- Add to timeline on first kill
    if kills[key].totalKills == 1 then
        local entry = {
            type = "boss_kill",
            title = "Victory: " .. boss.name,
            description = boss.lore,
            bossName = boss.name,
            dungeonName = raid.name,
            icon = kills[key].icon,
            timestamp = HopeAddon:GetTimestamp(),
            firstKill = kills[key].firstKill,
        }
        table.insert(HopeAddon.charDb.journal.entries, entry)
    end

    HopeAddon:Debug("Recorded boss kill:", boss.name, "Total:", kills[key].totalKills)

    return kills[key]
end

--[[
    Get boss kill statistics
    @param raidKey string - Optional: filter by raid
    @return table - Kill statistics
]]
function RaidData:GetKillStats(raidKey)
    local kills = HopeAddon.charDb.journal.bossKills
    local stats = {
        totalBossKills = 0,
        uniqueBosses = 0,
        raids = {},
    }

    for key, killData in pairs(kills) do
        if not raidKey or killData.raidKey == raidKey then
            stats.totalBossKills = stats.totalBossKills + killData.totalKills
            stats.uniqueBosses = stats.uniqueBosses + 1

            if not stats.raids[killData.raidKey] then
                stats.raids[killData.raidKey] = {
                    kills = 0,
                    bosses = 0,
                }
            end
            stats.raids[killData.raidKey].kills = stats.raids[killData.raidKey].kills + killData.totalKills
            stats.raids[killData.raidKey].bosses = stats.raids[killData.raidKey].bosses + 1
        end
    end

    return stats
end

--[[
    Get raid completion progress
    @param raidKey string - Raid identifier
    @return number, number - Killed count, total bosses
]]
function RaidData:GetRaidProgress(raidKey)
    local bosses = self:GetBosses(raidKey)
    local kills = HopeAddon.charDb.journal.bossKills

    local killed = 0
    local total = 0

    for _, boss in ipairs(bosses) do
        if not boss.optional or boss.finalBoss then
            total = total + 1
            local key = raidKey .. "_" .. boss.id
            if kills[key] then
                killed = killed + 1
            end
        end
    end

    return killed, total
end

--[[
    Check if a raid has been cleared
    @param raidKey string - Raid identifier
    @return boolean
]]
function RaidData:IsRaidCleared(raidKey)
    local killed, total = self:GetRaidProgress(raidKey)
    return killed >= total
end

--[[
    Get boss mechanics summary
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @return table - Array of mechanic descriptions
]]
function RaidData:GetBossMechanics(raidKey, bossId)
    local boss = self:GetBoss(raidKey, bossId)
    if boss and boss.mechanics then
        return boss.mechanics
    end
    return {}
end

--[[
    Get notable loot for a boss
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @return table - Array of loot items
]]
function RaidData:GetBossLoot(raidKey, bossId)
    local boss = self:GetBoss(raidKey, bossId)
    if boss and boss.notableLoot then
        return boss.notableLoot
    end
    return {}
end

--============================================================
-- EVENT HANDLING FOR AUTOMATIC BOSS KILL DETECTION
--============================================================

local eventFrame = CreateFrame("Frame")

-- Track which bosses we've already recorded kills for this session
-- (prevents duplicate tracking from both ENCOUNTER_END and COMBAT_LOG)
local recentKills = {}

--[[
    Register for combat events
]]
function RaidData:RegisterEvents()
    -- NOTE: ENCOUNTER_END does NOT exist in TBC Classic 2.4.3
    -- Boss detection relies on COMBAT_LOG_EVENT_UNFILTERED UNIT_DIED
    -- Keeping registration for potential compatibility, but it will silently fail to fire
    eventFrame:RegisterEvent("ENCOUNTER_END")
    -- Always register COMBAT_LOG as fallback (definitely exists in TBC Classic)
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "ENCOUNTER_END" then
            local success, err = pcall(RaidData.OnEncounterEnd, RaidData, ...)
            if not success then
                HopeAddon:Debug("ENCOUNTER_END handler error:", err)
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local success, err = pcall(RaidData.OnCombatLogEvent, RaidData, ...)
            if not success then
                HopeAddon:Debug("Combat log handler error:", err)
            end
        end
    end)
end

--[[
    Extract NPC ID from GUID
    @param guid string - Unit GUID
    @return number|nil - NPC ID or nil
]]
local function GetNpcIdFromGuid(guid)
    if not guid then return nil end
    -- GUID format: "Creature-0-XXXX-XXXX-XXXX-NPCID-INSTANCEID"
    -- or in TBC: "0xF130NPCID..." format
    local npcId = select(6, strsplit("-", guid))
    if npcId then
        return tonumber(npcId)
    end
    -- Fallback for older GUID format (0xF130...)
    local id = guid:match("Creature%-.-%-.-%-.-%-.-%-(%d+)")
    return id and tonumber(id)
end

--[[
    Handle combat log event (UNIT_DIED fallback for boss detection)
]]
function RaidData:OnCombatLogEvent(...)
    local _, subEvent, _, _, _, _, _, destGuid, destName = ...

    -- Only care about deaths
    if subEvent ~= "UNIT_DIED" then return end

    -- Check if the dying unit is a raid boss
    local npcId = GetNpcIdFromGuid(destGuid)
    if not npcId then return end

    local mapping = HopeAddon.Constants.BOSS_NPC_IDS[npcId]
    if not mapping then return end

    -- Prevent duplicate recording (in case ENCOUNTER_END also fired)
    local killKey = mapping.raid .. "_" .. mapping.boss
    local now = GetTime()

    -- Clean expired entries (15 sec expiry with buffer beyond 10)
    for key, timestamp in pairs(recentKills) do
        if now - timestamp > 15 then
            recentKills[key] = nil
        end
    end

    if recentKills[killKey] and (now - recentKills[killKey]) < 10 then
        return  -- Already recorded this kill within 10 seconds
    end
    recentKills[killKey] = now

    HopeAddon:Debug("Boss death detected via COMBAT_LOG:", destName, "(" .. npcId .. ")")

    local killData = self:RecordBossKill(mapping.raid, mapping.boss)
    if killData and killData.totalKills == 1 then
        -- First kill - show notification
        local Journal = HopeAddon:GetModule("Journal")
        if Journal and Journal.ShowBossKillNotification then
            Journal:ShowBossKillNotification(killData)
        end

        -- Check for tier/boss milestones
        if HopeAddon.Milestones then
            HopeAddon.Milestones:CheckTierMilestone(mapping.raid, mapping.boss)
        end
    end

    -- Notify TravelerIcons module for icon awards
    if HopeAddon.TravelerIcons and HopeAddon.FellowTravelers then
        local party = HopeAddon.FellowTravelers:GetPartyMembers()
        if #party > 0 then
            HopeAddon.TravelerIcons:OnBossKill(mapping.raid, mapping.boss, party)
        end
    end
end

--[[
    Handle encounter end event (preferred method, may not exist in TBC Classic)
    @param encounterID number - The encounter ID
    @param encounterName string - Name of the encounter
    @param difficultyID number - Difficulty setting
    @param groupSize number - Size of the group
    @param success number - 1 if successful, 0 if wipe
]]
function RaidData:OnEncounterEnd(encounterID, encounterName, difficultyID, groupSize, success)
    if success ~= 1 then return end  -- Only track kills, not wipes

    local mapping = HopeAddon.Constants.ENCOUNTER_TO_BOSS[encounterID]
    if not mapping then return end

    -- Prevent duplicate recording (in case COMBAT_LOG also detected this)
    local killKey = mapping.raid .. "_" .. mapping.boss
    local now = GetTime()

    -- Clean expired entries (15 sec expiry with buffer beyond 10)
    for key, timestamp in pairs(recentKills) do
        if now - timestamp > 15 then
            recentKills[key] = nil
        end
    end

    if recentKills[killKey] and (now - recentKills[killKey]) < 10 then
        return  -- Already recorded this kill within 10 seconds
    end
    recentKills[killKey] = now

    HopeAddon:Debug("Boss kill detected via ENCOUNTER_END:", encounterName, "(" .. encounterID .. ")")

    local killData = self:RecordBossKill(mapping.raid, mapping.boss)
    if killData and killData.totalKills == 1 then
        -- First kill - show notification
        local Journal = HopeAddon:GetModule("Journal")
        if Journal and Journal.ShowBossKillNotification then
            Journal:ShowBossKillNotification(killData)
        end

        -- Check for tier/boss milestones
        if HopeAddon.Milestones then
            HopeAddon.Milestones:CheckTierMilestone(mapping.raid, mapping.boss)
        end
    end

    -- Notify TravelerIcons module for icon awards
    if HopeAddon.TravelerIcons and HopeAddon.FellowTravelers then
        local party = HopeAddon.FellowTravelers:GetPartyMembers()
        if #party > 0 then
            HopeAddon.TravelerIcons:OnBossKill(mapping.raid, mapping.boss, party)
        end
    end
end

--[[
    Module initialize hook
]]
function RaidData:OnInitialize()
    -- Initialization handled in OnEnable
end

--[[
    Module enable hook
]]
function RaidData:OnEnable()
    self:RegisterEvents()
end

--[[
    Module disable hook
]]
function RaidData:OnDisable()
    if eventFrame then
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
        eventFrame = nil
    end
    -- Clear recent kills cache
    if recentKills then
        wipe(recentKills)
    end
end

-- Register with addon
HopeAddon:RegisterModule("RaidData", RaidData)
if HopeAddon.Debug then
    HopeAddon:Debug("RaidData module loaded")
end
