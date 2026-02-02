--[[
    HopeAddon Crusade Critter Core
    Mascot-driven storytelling and stats system for TBC dungeon grinds

    Features:
    - Boss kill detection via combat log
    - Dungeon run timing
    - Unlock progression
    - Event triggers for quips and popups
]]

local CrusadeCritter = {}
HopeAddon.CrusadeCritter = CrusadeCritter
HopeAddon:RegisterModule("CrusadeCritter", CrusadeCritter)

--============================================================
-- CONSTANTS
--============================================================

local COMBAT_LOG_EVENTS = {
    "UNIT_DIED",
    "PARTY_KILL",
}

-- All boss NPCs in TBC dungeons (for mid-boss detection)
-- Final bosses are in C.DUNGEON_BOSS_NPC_IDS
local DUNGEON_BOSS_NPCS = {
    -- Hellfire Ramparts
    [17306] = { name = "Watchkeeper Gargolmar", dungeon = "ramparts" },
    [17308] = { name = "Omor the Unscarred", dungeon = "ramparts" },
    [17536] = { name = "Nazan", dungeon = "ramparts", isFinal = true },
    -- Blood Furnace
    [17381] = { name = "The Maker", dungeon = "blood_furnace" },
    [17380] = { name = "Broggok", dungeon = "blood_furnace" },
    [17377] = { name = "Keli'dan the Breaker", dungeon = "blood_furnace", isFinal = true },
    -- Shattered Halls
    [16807] = { name = "Grand Warlock Nethekurse", dungeon = "shattered_halls" },
    [20923] = { name = "Blood Guard Porung", dungeon = "shattered_halls" },
    [16809] = { name = "Warbringer O'mrogg", dungeon = "shattered_halls" },
    [16808] = { name = "Warchief Kargath Bladefist", dungeon = "shattered_halls", isFinal = true },
    -- Slave Pens
    [17941] = { name = "Mennu the Betrayer", dungeon = "slave_pens" },
    [17991] = { name = "Rokmar the Crackler", dungeon = "slave_pens" },
    [17942] = { name = "Quagmirran", dungeon = "slave_pens", isFinal = true },
    -- Underbog
    [17770] = { name = "Hungarfen", dungeon = "underbog" },
    [18105] = { name = "Ghaz'an", dungeon = "underbog" },
    [17826] = { name = "Swamplord Musel'ek", dungeon = "underbog" },
    [17882] = { name = "The Black Stalker", dungeon = "underbog", isFinal = true },
    -- Steamvault
    [17797] = { name = "Hydromancer Thespia", dungeon = "steamvault" },
    [17796] = { name = "Mekgineer Steamrigger", dungeon = "steamvault" },
    [17798] = { name = "Warlord Kalithresh", dungeon = "steamvault", isFinal = true },
    -- Mana-Tombs
    [18341] = { name = "Pandemonius", dungeon = "mana_tombs" },
    [18343] = { name = "Tavarok", dungeon = "mana_tombs" },
    [22930] = { name = "Yor", dungeon = "mana_tombs" },
    [18344] = { name = "Nexus-Prince Shaffar", dungeon = "mana_tombs", isFinal = true },
    -- Auchenai Crypts
    [18371] = { name = "Shirrak the Dead Watcher", dungeon = "auchenai_crypts" },
    [18373] = { name = "Exarch Maladaar", dungeon = "auchenai_crypts", isFinal = true },
    -- Sethekk Halls
    [18472] = { name = "Darkweaver Syth", dungeon = "sethekk_halls" },
    [23035] = { name = "Anzu", dungeon = "sethekk_halls" },
    [18473] = { name = "Talon King Ikiss", dungeon = "sethekk_halls", isFinal = true },
    -- Shadow Labyrinth
    [18731] = { name = "Ambassador Hellmaw", dungeon = "shadow_lab" },
    [18667] = { name = "Blackheart the Inciter", dungeon = "shadow_lab" },
    [18732] = { name = "Grandmaster Vorpil", dungeon = "shadow_lab" },
    [18708] = { name = "Murmur", dungeon = "shadow_lab", isFinal = true },
    -- Mechanar
    [19218] = { name = "Mechano-Lord Capacitus", dungeon = "mechanar" },
    [19219] = { name = "Nethermancer Sepethrea", dungeon = "mechanar" },
    [19220] = { name = "Pathaleon the Calculator", dungeon = "mechanar", isFinal = true },
    -- Botanica
    [17976] = { name = "Commander Sarannis", dungeon = "botanica" },
    [17975] = { name = "High Botanist Freywinn", dungeon = "botanica" },
    [17978] = { name = "Thorngrin the Tender", dungeon = "botanica" },
    [17980] = { name = "Laj", dungeon = "botanica" },
    [17977] = { name = "Warp Splinter", dungeon = "botanica", isFinal = true },
    -- Arcatraz
    [20870] = { name = "Zereketh the Unbound", dungeon = "arcatraz" },
    [20885] = { name = "Dalliah the Doomsayer", dungeon = "arcatraz" },
    [20886] = { name = "Wrath-Scryer Soccothrates", dungeon = "arcatraz" },
    [20912] = { name = "Harbinger Skyriss", dungeon = "arcatraz", isFinal = true },
    -- Old Hillsbrad
    [17848] = { name = "Lieutenant Drake", dungeon = "old_hillsbrad" },
    [17862] = { name = "Captain Skarloc", dungeon = "old_hillsbrad" },
    [18096] = { name = "Epoch Hunter", dungeon = "old_hillsbrad", isFinal = true },
    -- Black Morass
    [17879] = { name = "Chrono Lord Deja", dungeon = "black_morass" },
    [17880] = { name = "Temporus", dungeon = "black_morass" },
    [17881] = { name = "Aeonus", dungeon = "black_morass", isFinal = true },
    -- Magisters' Terrace
    [24723] = { name = "Selin Fireheart", dungeon = "magisters_terrace" },
    [24744] = { name = "Vexallus", dungeon = "magisters_terrace" },
    [24560] = { name = "Priestess Delrissa", dungeon = "magisters_terrace" },
    [24664] = { name = "Kael'thas Sunstrider", dungeon = "magisters_terrace", isFinal = true },
    -- Stockades (Test Dungeon)
    [1666] = { name = "Kam Deepfury", dungeon = "stockades" },
    [1696] = { name = "Targorr the Dread", dungeon = "stockades" },
    [1717] = { name = "Hamhock", dungeon = "stockades" },
    [1663] = { name = "Dextren Ward", dungeon = "stockades" },
    [1716] = { name = "Bazil Thredd", dungeon = "stockades", isFinal = true },
}

-- Zone to dungeon hub mapping
local ZONE_HUB_MAP = {
    ["Hellfire Peninsula"] = "hellfire",
    ["Zangarmarsh"] = "coilfang",
    ["Terokkar Forest"] = "auchindoun",
    ["Netherstorm"] = "tempest_keep",
    ["Tanaris"] = "caverns",
    ["Isle of Quel'Danas"] = "queldanas",
}

--============================================================
-- MODULE STATE
--============================================================

CrusadeCritter.enabled = false
CrusadeCritter.currentRun = nil
CrusadeCritter.eventFrame = nil
CrusadeCritter.inCombat = false

--============================================================
-- DATABASE DEFAULTS
--============================================================

local DB_DEFAULTS = {
    enabled = true,
    selectedCritter = "flux",
    position = { x = -200, y = 0 },
    hideInCombat = true,
    housingOpen = false, -- Tab-out panel state persistence

    -- Unlock progress
    unlockedCritters = { "flux" },
    completedDungeons = {},

    -- Visit tracking
    visitedZones = {},
    visitedDungeons = {},

    -- Run stats per dungeon
    dungeonRuns = {},

    -- Boss stats
    bossStats = {},

    -- Current run state (cleared on logout)
    currentRun = nil,

    -- New unlock flag for tab badge
    hasNewUnlock = false,
}

--============================================================
-- INITIALIZATION
--============================================================

function CrusadeCritter:OnInitialize()
    -- Initialize database
    if not HopeAddon.db.crusadeCritter then
        HopeAddon.db.crusadeCritter = {}
    end

    -- Apply defaults
    for key, value in pairs(DB_DEFAULTS) do
        if HopeAddon.db.crusadeCritter[key] == nil then
            if type(value) == "table" then
                HopeAddon.db.crusadeCritter[key] = {}
                for k, v in pairs(value) do
                    HopeAddon.db.crusadeCritter[key][k] = v
                end
            else
                HopeAddon.db.crusadeCritter[key] = value
            end
        end
    end

    -- Clear stale current run
    HopeAddon.db.crusadeCritter.currentRun = nil
end

function CrusadeCritter:OnEnable()
    local db = HopeAddon.db and HopeAddon.db.crusadeCritter
    if not db or not db.enabled then
        return
    end

    self.enabled = true

    -- Create event frame
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end

    -- Register events
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("PLAYER_DEAD")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)

    -- Show mascot
    self:ShowMascot()

    -- Check current zone
    self:CheckZone()

    HopeAddon:Debug("CrusadeCritter enabled")
end

function CrusadeCritter:OnDisable()
    self.enabled = false

    -- Clear current run data
    self.currentRun = nil
    self.inCombat = false

    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
    end

    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:HideMascot()
    end

    HopeAddon:Debug("CrusadeCritter disabled")
end

--============================================================
-- EVENT HANDLING
--============================================================

function CrusadeCritter:OnEvent(event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        self:CheckZone()

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:OnCombatLogEvent(CombatLogGetCurrentEventInfo())

    elseif event == "PLAYER_REGEN_DISABLED" then
        self:OnCombatStart()

    elseif event == "PLAYER_REGEN_ENABLED" then
        self:OnCombatEnd()

    elseif event == "PLAYER_DEAD" then
        self:OnPlayerDeath()
    end
end

--============================================================
-- ZONE HANDLING
--============================================================

function CrusadeCritter:CheckZone()
    local zoneName = GetRealZoneText()
    local subZone = GetSubZoneText()
    local db = HopeAddon.db.crusadeCritter

    -- Check if in a TBC dungeon
    local dungeonData = HopeAddon.Constants.TBC_DUNGEONS[zoneName]
    if dungeonData then
        self:OnDungeonEnter(zoneName, dungeonData)
        return
    end

    -- Check if in a TBC zone
    local hub = ZONE_HUB_MAP[zoneName]
    if hub then
        local isFirstVisit = not db.visitedZones[zoneName]
        if isFirstVisit then
            db.visitedZones[zoneName] = true
            self:TriggerZoneQuip(zoneName, true)
        else
            -- Random chance for repeat visit quip
            if math.random() < 0.3 then
                self:TriggerZoneQuip(zoneName, false)
            end
        end
    end
end

function CrusadeCritter:OnDungeonEnter(dungeonName, dungeonData)
    local db = HopeAddon.db.crusadeCritter

    -- Start tracking run
    self.currentRun = {
        dungeonName = dungeonName,
        dungeonKey = dungeonData.key,
        startTime = nil, -- Set on first combat
        bossKills = {},
        bossTimestamps = {},
    }

    -- First visit?
    local isFirstVisit = not db.visitedDungeons[dungeonData.key]
    if isFirstVisit then
        db.visitedDungeons[dungeonData.key] = true
    end

    -- Trigger dungeon entry quip
    self:TriggerDungeonQuip(dungeonName, isFirstVisit)
end

--============================================================
-- COMBAT HANDLING
--============================================================

function CrusadeCritter:OnCombatStart()
    self.inCombat = true

    -- Start run timer on first combat in dungeon
    if self.currentRun and not self.currentRun.startTime then
        self.currentRun.startTime = GetTime()
    end

    -- Hide mascot during combat if setting enabled
    local db = HopeAddon.db.crusadeCritter
    if db.hideInCombat and HopeAddon.CritterUI then
        HopeAddon.CritterUI:OnCombatStart()
    end
end

function CrusadeCritter:OnCombatEnd()
    self.inCombat = false

    -- Resume mascot after combat
    local db = HopeAddon.db.crusadeCritter
    if db.hideInCombat and HopeAddon.CritterUI then
        HopeAddon.CritterUI:OnCombatEnd()
    end
end

function CrusadeCritter:OnCombatLogEvent(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags,
          sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

    if subevent ~= "UNIT_DIED" and subevent ~= "PARTY_KILL" then
        return
    end

    -- Check if it's a boss
    local npcID = self:GetNPCIDFromGUID(destGUID)
    if not npcID then return end

    local bossData = DUNGEON_BOSS_NPCS[npcID]
    if not bossData then return end

    self:OnBossKill(npcID, bossData)
end

function CrusadeCritter:GetNPCIDFromGUID(guid)
    if not guid then return nil end
    -- GUID format: Creature-0-XXXX-XXXX-XXXX-NPCID-SPAWNID
    local npcID = select(6, strsplit("-", guid))
    return npcID and tonumber(npcID)
end

--============================================================
-- BOSS KILL HANDLING
--============================================================

function CrusadeCritter:OnBossKill(npcID, bossData)
    local killTime = GetTime()

    -- Calculate boss kill time
    local bossKillTime = 0
    if self.currentRun and self.currentRun.startTime then
        -- Time since last boss or run start
        local lastBossTime = self.currentRun.lastBossKillTime or self.currentRun.startTime
        bossKillTime = killTime - lastBossTime
        self.currentRun.lastBossKillTime = killTime

        -- Record boss kill
        table.insert(self.currentRun.bossKills, {
            npcID = npcID,
            name = bossData.name,
            time = killTime,
            duration = bossKillTime,
        })
    end

    if bossData.isFinal then
        -- Final boss - show stats window
        self:OnDungeonComplete(bossData)
    else
        -- Mid-boss - show quick popup
        self:ShowBossKillPopup(bossData, bossKillTime)
    end
end

function CrusadeCritter:ShowBossKillPopup(bossData, killTime)
    local db = HopeAddon.db.crusadeCritter
    local critterId = db.selectedCritter or "flux"

    -- Get best time for this boss
    local bestTime = self:GetBestBossTime(bossData.name)

    -- Get quip (may be nil)
    local quip = nil
    if HopeAddon.CritterContent then
        quip = HopeAddon.CritterContent:GetQuip(critterId, "boss_kill")
    end

    -- Show popup (only if UI module is loaded)
    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:ShowBossPopup(bossData.name, killTime, bestTime, quip)
    end

    -- Save best time
    self:SaveBossTime(bossData.name, killTime)
end

function CrusadeCritter:OnDungeonComplete(bossData)
    local db = HopeAddon.db.crusadeCritter

    if not self.currentRun then return end

    local totalTime = GetTime() - (self.currentRun.startTime or GetTime())
    local dungeonKey = self.currentRun.dungeonKey
    local dungeonName = self.currentRun.dungeonName

    -- Get last/best times
    local runData = db.dungeonRuns[dungeonKey] or {}
    local lastTime = runData.lastTime
    local bestTime = runData.bestTime

    -- Update stats
    db.dungeonRuns[dungeonKey] = {
        lastTime = totalTime,
        bestTime = math.min(bestTime or totalTime, totalTime),
        totalRuns = (runData.totalRuns or 0) + 1,
    }

    -- Determine quip type based on performance
    local quipType = "boss_kill"
    if bestTime and totalTime < bestTime then
        quipType = "fast_run"
    elseif lastTime and totalTime > lastTime * 1.2 then
        quipType = "slow_run"
    end

    local critterId = db.selectedCritter or "flux"
    local quip = nil
    if HopeAddon.CritterContent then
        quip = HopeAddon.CritterContent:GetQuip(critterId, quipType)
    end

    -- Show stats window
    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:ShowStatsWindow({
            dungeonName = dungeonName,
            thisTime = totalTime,
            lastTime = lastTime,
            bestTime = db.dungeonRuns[dungeonKey].bestTime,
            bossCount = #self.currentRun.bossKills,
            totalBosses = self:GetTotalBossCount(dungeonKey),
        }, quip)
    end

    -- Check for critter unlock
    self:CheckUnlock(dungeonKey)

    -- Clear current run
    self.currentRun = nil
end

--============================================================
-- UNLOCK SYSTEM
--============================================================

function CrusadeCritter:CheckUnlock(completedDungeonKey)
    local db = HopeAddon.db.crusadeCritter
    local Content = HopeAddon.CritterContent

    if not Content then return end

    -- Mark dungeon complete
    db.completedDungeons[completedDungeonKey] = true

    -- Check each hub for completion
    for hubKey, hubData in pairs(Content.DUNGEON_HUBS) do
        if Content:IsHubComplete(hubKey, db.completedDungeons) then
            local critterId = Content:GetHubCritter(hubKey)
            if critterId and not self:IsCritterUnlocked(critterId) then
                self:UnlockCritter(critterId)
            end
        end
    end
end

function CrusadeCritter:IsCritterUnlocked(critterId)
    local db = HopeAddon.db and HopeAddon.db.crusadeCritter
    if not db or not db.unlockedCritters then
        -- Default: only flux is unlocked if db not initialized
        return critterId == "flux"
    end
    for _, id in ipairs(db.unlockedCritters) do
        if id == critterId then
            return true
        end
    end
    return false
end

function CrusadeCritter:UnlockCritter(critterId)
    local db = HopeAddon.db.crusadeCritter
    table.insert(db.unlockedCritters, critterId)

    -- Set new unlock flag for tab badge
    db.hasNewUnlock = true

    -- Show celebration
    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:ShowUnlockCelebration(critterId)
    end
end

--============================================================
-- PLAYER DEATH
--============================================================

function CrusadeCritter:OnPlayerDeath()
    local db = HopeAddon.db.crusadeCritter
    local critterId = db.selectedCritter or "flux"

    if not HopeAddon.CritterContent or not HopeAddon.CritterUI then return end

    local quip = HopeAddon.CritterContent:GetQuip(critterId, "player_death")
    if quip then
        HopeAddon.CritterUI:ShowSpeechBubble(quip, 5)
    end
end

--============================================================
-- QUIP TRIGGERS
--============================================================

function CrusadeCritter:TriggerZoneQuip(zoneName, isFirstVisit)
    local db = HopeAddon.db.crusadeCritter
    local critterId = db.selectedCritter or "flux"

    if not HopeAddon.CritterContent or not HopeAddon.CritterUI then return end

    -- Pass zone name as context for zone-specific quips
    local quip = HopeAddon.CritterContent:GetQuip(critterId, "zone_entry", zoneName)
    if quip then
        HopeAddon.CritterUI:ShowSpeechBubble(quip, 5)
    end
end

function CrusadeCritter:TriggerDungeonQuip(dungeonName, isFirstVisit)
    local db = HopeAddon.db.crusadeCritter
    local critterId = db.selectedCritter or "flux"

    if not HopeAddon.CritterContent or not HopeAddon.CritterUI then return end

    local quip = HopeAddon.CritterContent:GetQuip(critterId, "dungeon_entry")
    if quip then
        HopeAddon.CritterUI:ShowSpeechBubble(quip, 5)
    end
end

--============================================================
-- MASCOT MANAGEMENT
--============================================================

function CrusadeCritter:ShowMascot()
    if not HopeAddon.CritterUI then return end

    local db = HopeAddon.db.crusadeCritter
    local critterId = db.selectedCritter or "flux"

    HopeAddon.CritterUI:SetCritter(critterId)
    HopeAddon.CritterUI:ShowMascot()
end

function CrusadeCritter:SetSelectedCritter(critterId)
    local db = HopeAddon.db.crusadeCritter

    if not self:IsCritterUnlocked(critterId) then
        HopeAddon:Debug("Critter not unlocked: " .. critterId)
        return false
    end

    db.selectedCritter = critterId
    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:SetCritter(critterId)
    end
    return true
end

--============================================================
-- STATS HELPERS
--============================================================

function CrusadeCritter:GetBestBossTime(bossName)
    local db = HopeAddon.db.crusadeCritter
    local bossStats = db.bossStats or {}
    local data = bossStats[bossName]
    return data and data.bestTime
end

function CrusadeCritter:SaveBossTime(bossName, time)
    local db = HopeAddon.db.crusadeCritter
    if not db.bossStats then
        db.bossStats = {}
    end

    local current = db.bossStats[bossName] or {}
    db.bossStats[bossName] = {
        bestTime = math.min(current.bestTime or time, time),
        totalKills = (current.totalKills or 0) + 1,
    }
end

function CrusadeCritter:GetTotalBossCount(dungeonKey)
    -- Count bosses for this dungeon
    local count = 0
    for _, bossData in pairs(DUNGEON_BOSS_NPCS) do
        if bossData.dungeon == dungeonKey then
            count = count + 1
        end
    end
    return count
end

--============================================================
-- SETTINGS API
--============================================================

function CrusadeCritter:IsEnabled()
    return HopeAddon.db.crusadeCritter and HopeAddon.db.crusadeCritter.enabled
end

function CrusadeCritter:SetEnabled(enabled)
    HopeAddon.db.crusadeCritter.enabled = enabled
    if enabled then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function CrusadeCritter:GetUnlockedCritters()
    local db = HopeAddon.db.crusadeCritter
    if not HopeAddon.CritterContent then return {} end
    return HopeAddon.CritterContent:GetUnlockedCritters(db.unlockedCritters or { "flux" })
end

function CrusadeCritter:GetHubProgress(hubKey)
    local db = HopeAddon.db.crusadeCritter
    if not HopeAddon.CritterContent then return 0, 0 end
    return HopeAddon.CritterContent:GetHubProgress(hubKey, db.completedDungeons or {})
end

--============================================================
-- TEST MODE
--============================================================

function CrusadeCritter:EnterTestMode()
    -- Simulate entering Stockades
    self.currentRun = {
        dungeonName = "The Stockade",
        dungeonKey = "stockades",
        startTime = GetTime(),
        bossKills = {},
        bossTimestamps = {},
    }

    self.enabled = true

    -- Show mascot if not visible
    self:ShowMascot()

    -- Show test panel
    if HopeAddon.CritterUI then
        HopeAddon.CritterUI:ShowTestPanel()
    end

    print("|cff9B30FF[Test Mode]|r Simulated entering The Stockade")
    print("  /critter test boss  - Simulate mid-boss kill")
    print("  /critter test final - Simulate final boss + stats")
    print("  /critter test unlock - Show unlock celebration")
    print("  /critter test reset - Clear test run")
end

function CrusadeCritter:TestBossKill(isFinal)
    if not self.currentRun then
        print("|cffff0000Run /critter test first to enter test mode|r")
        return
    end

    local bossName, npcID
    if isFinal then
        bossName = "Bazil Thredd"
        npcID = 1716
    else
        -- Cycle through mid-bosses
        local midBosses = {
            { name = "Kam Deepfury", npcID = 1666 },
            { name = "Targorr the Dread", npcID = 1696 },
            { name = "Hamhock", npcID = 1717 },
            { name = "Dextren Ward", npcID = 1663 },
        }
        local idx = (#self.currentRun.bossKills % #midBosses) + 1
        local boss = midBosses[idx]
        bossName = boss.name
        npcID = boss.npcID
    end

    local bossData = {
        name = bossName,
        dungeon = "stockades",
        isFinal = isFinal,
    }

    print("|cff9B30FF[Test Mode]|r " .. (isFinal and "FINAL: " or "") .. bossName .. " killed!")

    self:OnBossKill(npcID, bossData)
end

--============================================================
-- STATISTICS API
--============================================================

--[[
    Reset all run statistics (preserves unlocks)
]]
function CrusadeCritter:ResetStatistics()
    local db = HopeAddon.db.crusadeCritter
    db.dungeonRuns = {}
    db.bossStats = {}
    print("|cff00ff00Crusade Critter statistics reset.|r")
end

--[[
    Show confirmation dialog before resetting statistics
    @param callback function - Called after successful reset
]]
function CrusadeCritter:ConfirmResetStatistics(callback)
    StaticPopupDialogs["HOPE_CRITTER_RESET_STATS"] = {
        text = "Are you sure you want to reset all Crusade Critter statistics?\n\nThis will clear run times and boss stats. Critter unlocks will be preserved.",
        button1 = "Reset",
        button2 = "Cancel",
        OnAccept = function()
            CrusadeCritter:ResetStatistics()
            if callback then callback() end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("HOPE_CRITTER_RESET_STATS")
end

--[[
    Get summary of run statistics
    @return table - { totalRuns, dungeonsCleared, fastestRun, fastestDungeon, mostRuns, mostRunsDungeon }
]]
function CrusadeCritter:GetStatsSummary()
    local db = HopeAddon.db.crusadeCritter
    local summary = {
        totalRuns = 0,
        dungeonsCleared = 0,
        fastestRun = nil,
        fastestDungeon = nil,
        mostRuns = 0,
        mostRunsDungeon = nil,
    }

    for key, data in pairs(db.dungeonRuns or {}) do
        summary.dungeonsCleared = summary.dungeonsCleared + 1
        summary.totalRuns = summary.totalRuns + (data.totalRuns or 0)

        if data.bestTime and (not summary.fastestRun or data.bestTime < summary.fastestRun) then
            summary.fastestRun = data.bestTime
            summary.fastestDungeon = key
        end

        if (data.totalRuns or 0) > summary.mostRuns then
            summary.mostRuns = data.totalRuns
            summary.mostRunsDungeon = key
        end
    end

    return summary
end

--============================================================
-- SLASH COMMANDS
--============================================================

local function PrintHelp()
    print("|cff9B30FF=== Crusade Critter Commands ===|r")
    print("|cffffff00/critter on|r|cffffffff/|r|cffffff00off|r  - Enable or disable")
    print("|cffffff00/critter select <name>|r - Select critter (flux, snookimp, shred, emo, cosmo, boomer, diva)")
    -- Reset command removed - housing uses fixed tab-out positioning
    print("|cffffff00/critter list|r - Show unlocked critters and progress")
    print("|cffffff00/critter test|r - Enter test mode (simulates Stockades)")
    print("|cffffff00/critter test boss|r - Simulate mid-boss kill")
    print("|cffffff00/critter test final|r - Simulate final boss kill")
    print("|cffffff00/critter test unlock|r - Show unlock celebration")
    print("|cffffff00/critter test reset|r - Clear test run data")
end

local function PrintStatus()
    local db = HopeAddon.db.crusadeCritter
    local status = db.enabled and "|cff00ff00ENABLED|r" or "|cffff0000DISABLED|r"
    local selected = db.selectedCritter or "flux"
    print("|cff9B30FFCrusade Critter:|r " .. status)
    print("  Selected: |cffffff00" .. selected .. "|r")
end

local function PrintCritterList()
    local db = HopeAddon.db.crusadeCritter
    local Content = HopeAddon.CritterContent

    print("|cff9B30FF=== Crusade Critter Collection ===|r")

    -- List all critters with unlock status
    local critterOrder = { "flux", "snookimp", "shred", "emo", "cosmo", "boomer", "diva" }
    for _, critterId in ipairs(critterOrder) do
        local critter = Content and Content.CRITTERS[critterId]
        if critter then
            local unlocked = CrusadeCritter:IsCritterUnlocked(critterId)
            local selected = (db.selectedCritter == critterId)

            local status = ""
            if selected then
                status = " |cff00ff00[SELECTED]|r"
            elseif unlocked then
                status = " |cff00ff00[UNLOCKED]|r"
            else
                -- Show unlock requirement
                local hub = critter.unlockHub
                if hub and Content.DUNGEON_HUBS[hub] then
                    local completed, total = CrusadeCritter:GetHubProgress(hub)
                    status = string.format(" |cffff6600[%d/%d %s]|r", completed, total, Content.DUNGEON_HUBS[hub].name)
                else
                    status = " |cff888888[LOCKED]|r"
                end
            end

            print(string.format("  |cffffff00%s|r - %s%s", critterId, critter.name, status))
        end
    end
end

local function SelectCritter(name)
    if not name or name == "" then
        print("|cffff0000Usage: /critter select <name>|r")
        print("Available: flux, snookimp, shred, emo, cosmo, boomer, diva")
        return
    end

    name = strlower(name)
    local Content = HopeAddon.CritterContent

    -- Check if critter exists
    if not Content or not Content.CRITTERS[name] then
        print("|cffff0000Unknown critter: " .. name .. "|r")
        print("Available: flux, snookimp, shred, emo, cosmo, boomer, diva")
        return
    end

    -- Check if unlocked
    if not CrusadeCritter:IsCritterUnlocked(name) then
        local critter = Content.CRITTERS[name]
        local hub = critter.unlockHub
        if hub and Content.DUNGEON_HUBS[hub] then
            local completed, total = CrusadeCritter:GetHubProgress(hub)
            print(string.format("|cffff0000%s is locked!|r Complete %s dungeons (%d/%d)", critter.name, Content.DUNGEON_HUBS[hub].name, completed, total))
        else
            print("|cffff0000That critter is locked!|r")
        end
        return
    end

    -- Select the critter
    if CrusadeCritter:SetSelectedCritter(name) then
        local critter = Content.CRITTERS[name]
        print("|cff00ff00Selected:|r " .. critter.name)
    end
end

-- Note: ResetPosition removed - housing uses fixed tab-out positioning (not draggable)

SLASH_CRITTER1 = "/critter"
SlashCmdList["CRITTER"] = function(msg)
    local cmd, arg = strsplit(" ", msg or "", 2)
    cmd = strlower(cmd or "")

    if cmd == "" or cmd == "help" then
        PrintHelp()
        PrintStatus()

    elseif cmd == "on" then
        HopeAddon.db.crusadeCritter.enabled = true
        CrusadeCritter:OnEnable()
        print("|cff00ff00Crusade Critter enabled.|r")

    elseif cmd == "off" then
        HopeAddon.db.crusadeCritter.enabled = false
        CrusadeCritter:OnDisable()
        print("|cffff0000Crusade Critter disabled.|r")

    elseif cmd == "select" then
        SelectCritter(arg)

    elseif cmd == "reset" then
        -- Position reset removed - housing uses fixed tab-out positioning
        print("|cffffff00Housing uses fixed positioning. No reset needed.|r")

    elseif cmd == "list" then
        PrintCritterList()

    elseif cmd == "status" then
        PrintStatus()

    elseif cmd == "test" then
        if arg == "boss" then
            -- Simulate mid-boss kill
            CrusadeCritter:TestBossKill(false)
        elseif arg == "final" then
            -- Simulate final boss kill
            CrusadeCritter:TestBossKill(true)
        elseif arg == "unlock" then
            -- Show unlock celebration
            if HopeAddon.CritterUI then
                HopeAddon.CritterUI:ShowUnlockCelebration("snookimp")
            end
        elseif arg == "reset" then
            -- Reset test run
            CrusadeCritter.currentRun = nil
            print("|cff00ff00Test run cleared.|r")
        else
            -- Enter test mode
            CrusadeCritter:EnterTestMode()
        end

    else
        print("|cffff0000Unknown command: " .. cmd .. "|r")
        PrintHelp()
    end
end
