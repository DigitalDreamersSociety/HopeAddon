--[[
    HopeAddon RaidData Module
    T4 raid boss information and tracking
]]

local RaidData = {}
HopeAddon.RaidData = RaidData

-- Combat state tracking for kill time measurement
local combatState = {
    inCombat = false,
    combatStartTime = nil,
    recentDBMTime = nil,       -- Kill time captured from DBM/BigWigs
    recentDBMBoss = nil,       -- Boss name from DBM announcement
    recentDBMTimestamp = nil,  -- When the DBM time was captured
}

-- DBM/BigWigs kill message patterns
-- Order matters: more specific patterns first, greedy patterns last
-- Using (.+) for boss name capture (works because "down after" etc. is unique)
local DBM_PATTERNS = {
    -- With decimal (must be before standard): "Boss Name down after 3:45.2!"
    { pattern = "(.+) down after (%d+):(%d+)%.(%d+)", hasMs = true },
    -- New record format (must be before standard): "Boss down after 3:45! This is a new record"
    { pattern = "(.+) down after (%d+):(%d+)[!.]? This is a new record", hasMs = false },
    -- Standard DBM: "Boss Name down after 3:45!" or "Boss Name down after 3:45"
    { pattern = "(.+) down after (%d+):(%d+)", hasMs = false },
    -- BigWigs alternatives
    { pattern = "(.+) killed in (%d+):(%d+)", hasMs = false },
    { pattern = "(.+) defeated after (%d+):(%d+)", hasMs = false },
}

-- Seconds-only pattern (separate due to different capture groups)
-- Handles: "Boss down after 45 seconds!" or "Boss down after 45 second!"
local DBM_SECONDS_PATTERN = "(.+) down after (%d+) seconds?!?"

--[[
    Parse kill time from DBM/BigWigs chat message
    @param msg string - Chat message text
    @return string|nil, number|nil - Boss name, kill time in seconds
]]
local function ParseKillTimeMessage(msg)
    if not msg or msg == "" then return nil, nil end

    -- Try minutes:seconds patterns (ordered by specificity)
    for _, patternData in ipairs(DBM_PATTERNS) do
        local bossName, mins, secs, ms
        if patternData.hasMs then
            bossName, mins, secs, ms = msg:match(patternData.pattern)
        else
            bossName, mins, secs = msg:match(patternData.pattern)
        end

        if bossName and mins and secs then
            local totalSeconds = tonumber(mins) * 60 + tonumber(secs)
            if ms then
                totalSeconds = totalSeconds + tonumber(ms) / 10
            end
            -- Trim whitespace from boss name
            bossName = bossName:match("^%s*(.-)%s*$") or bossName
            return bossName, totalSeconds
        end
    end

    -- Try seconds-only pattern
    local bossName, secsOnly = msg:match(DBM_SECONDS_PATTERN)
    if bossName and secsOnly then
        bossName = bossName:match("^%s*(.-)%s*$") or bossName
        return bossName, tonumber(secsOnly)
    end

    return nil, nil
end

-- Raid phases (TBC content release phases)
RaidData.PHASES = {
    [1] = {
        name = "Phase 1",
        raids = { "Karazhan", "Gruul's Lair", "Magtheridon's Lair" },
    },
    [2] = {
        name = "Phase 2",
        raids = { "Serpentshrine Cavern", "Tempest Keep: The Eye" },
    },
    [3] = {
        name = "Phase 3",
        raids = { "Mount Hyjal", "Black Temple" },
    },
    [4] = {
        name = "Phase 4",
        raids = { "Zul'Aman" },
    },
    [5] = {
        name = "Phase 5",
        raids = { "Sunwell Plateau" },
    },
}

-- Backward compatibility alias
RaidData.TIERS = RaidData.PHASES

-- Raid categories
RaidData.RAIDS = {
    -- Phase 1 Raids
    karazhan = {
        name = "Karazhan",
        shortName = "Kara",
        size = 10,
        phase = 1,
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
        phase = 1,
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
        phase = 1,
        location = "Hellfire Citadel",
        requiresAttunement = false,
        icon = "Spell_Shadow_SummonFelGuard",
        lore = "The former Lord of Outland, Magtheridon was defeated by Illidan and imprisoned.",
        bosses = HopeAddon.Constants.MAGTHERIDON_BOSSES,
    },
    -- Phase 2 Raids
    ssc = {
        name = "Serpentshrine Cavern",
        shortName = "SSC",
        size = 25,
        phase = 2,
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
        phase = 2,
        location = "Netherstorm",
        requiresAttunement = true,
        attunementKey = "tk",
        icon = "Spell_Fire_BurnoutGreen",
        lore = "Kael'thas Sunstrider plots his return to power from this floating fortress.",
        bosses = HopeAddon.Constants.TK_BOSSES,
    },
    -- Phase 3 Raids
    hyjal = {
        name = "Mount Hyjal",
        shortName = "Hyjal",
        size = 25,
        phase = 3,
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
        phase = 3,
        location = "Shadowmoon Valley",
        requiresAttunement = true,
        attunementKey = "bt",
        icon = "INV_Weapon_Glaive_01",
        lore = "Illidan Stormrage rules Outland from the Black Temple, former Temple of Karabor.",
        bosses = HopeAddon.Constants.BT_BOSSES,
    },
    -- Phase 4 Raids
    za = {
        name = "Zul'Aman",
        shortName = "ZA",
        size = 10,
        phase = 4,
        location = "Ghostlands",
        requiresAttunement = false,
        timedEvent = true,
        icon = "Spell_Nature_BloodLust",
        lore = "The Amani trolls have rebuilt their forces in Zul'Aman. Time is of the essence!",
        bosses = HopeAddon.Constants.ZA_BOSSES,
    },
    -- Phase 5 Raids
    sunwell = {
        name = "Sunwell Plateau",
        shortName = "SWP",
        size = 25,
        phase = 5,
        location = "Isle of Quel'Danas",
        requiresAttunement = false,
        icon = "Spell_Fire_FelFlameRing",
        lore = "The Legion's final assault on Azeroth. Kil'jaeden himself awaits.",
        bosses = HopeAddon.Constants.SUNWELL_BOSSES,
    },
}

-- Phase color name mapping (maps phase number to HopeAddon.colors key)
local PHASE_COLOR_NAMES = {
    [1] = "KARA_PURPLE",
    [2] = "SSC_BLUE",
    [3] = "BT_FEL",
    [4] = "ZA_TRIBAL",
    [5] = "SUNWELL_GOLD",
}

-- Raid stats window sizing
local RAID_STATS_WIDTH = 340
local RAID_STATS_HEIGHT = 240
local RAID_STATS_DURATION = 2.0        -- Auto-hide seconds for mid-boss (snappy flash)
local RAID_STATS_FINAL_DURATION = 3.0  -- Auto-hide seconds for final boss (snappy flash)
local RAID_STATS_ENHANCED_WIDTH = 400
local RAID_STATS_ENHANCED_HEIGHT = 300

--[[
    Get phase color name for a raid
    @param raidKey string - Raid identifier
    @return string - Color name key (e.g., "KARA_PURPLE")
]]
function RaidData:GetPhaseColorName(raidKey)
    local phase = HopeAddon.Constants.RAID_PHASES[raidKey]
    return PHASE_COLOR_NAMES[phase] or "KARA_PURPLE"
end

--[[
    Check if a boss is the final boss of its raid
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @return boolean
]]
function RaidData:IsFinalBoss(raidKey, bossId)
    local boss = self:GetBoss(raidKey, bossId)
    return boss and boss.finalBoss == true
end

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
    -- Early guard for data availability
    if not HopeAddon.charDb or not HopeAddon.charDb.journal then
        HopeAddon:Debug("RecordBossKill: charDb not ready")
        return nil
    end

    local boss = self:GetBoss(raidKey, bossId)
    if not boss then
        HopeAddon:Debug("Unknown boss:", raidKey, bossId)
        return nil
    end

    local raid = self:GetRaid(raidKey)
    local key = raidKey .. "_" .. bossId

    -- Ensure bossKills table exists
    if not HopeAddon.charDb.journal.bossKills then
        HopeAddon.charDb.journal.bossKills = {}
    end

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
            -- Kill time tracking fields
            bestTime = nil,
            bestTimeDate = nil,
            lastTime = nil,
            killTimes = {},
        }
    end

    kills[key].totalKills = kills[key].totalKills + 1
    kills[key].lastKill = HopeAddon:GetDate()

    -- Try to capture kill time from DBM/BigWigs or manual timer
    local killTime = nil
    local timeSource = nil

    -- Check for DBM/BigWigs kill time (captured within last 30 seconds)
    if combatState.recentDBMTime and combatState.recentDBMTimestamp
       and (GetTime() - combatState.recentDBMTimestamp) < 30 then
        -- Verify the boss name matches (fuzzy match)
        local dbmBossLower = combatState.recentDBMBoss:lower()
        local ourBossLower = boss.name:lower()

        -- Try exact match first, then partial match
        if dbmBossLower == ourBossLower
           or dbmBossLower:find(ourBossLower, 1, true)
           or ourBossLower:find(dbmBossLower, 1, true) then
            killTime = combatState.recentDBMTime
            timeSource = "DBM"
            HopeAddon:Debug("Matched DBM time to boss:", boss.name, HopeAddon:FormatTime(killTime))
        end
    end

    -- Fallback: Use manual combat timer if available and no DBM time
    if not killTime and combatState.combatStartTime then
        killTime = GetTime() - combatState.combatStartTime
        timeSource = "Manual"
        HopeAddon:Debug("Using manual timer for:", boss.name, HopeAddon:FormatTime(killTime))
    end

    -- Record kill time if we have one
    if killTime and killTime > 0 then
        self:RecordKillTime(key, killTime, timeSource)
    end

    -- Clear combat state after processing
    combatState.recentDBMTime = nil
    combatState.recentDBMBoss = nil
    combatState.recentDBMTimestamp = nil
    combatState.combatStartTime = nil

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
    local kills = HopeAddon.charDb and HopeAddon.charDb.journal
        and HopeAddon.charDb.journal.bossKills
    local stats = {
        totalBossKills = 0,
        uniqueBosses = 0,
        raids = {},
    }

    if not kills then return stats end

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
-- RAID BOSS STATS WINDOW
--============================================================

local TEX_WHITE8X8 = "Interface\\BUTTONS\\WHITE8X8"
local TEX_STATUS_BAR = "Interface\\TARGETINGFRAME\\UI-StatusBar"

--[[
    Create the raid boss stats popup window
    @return Frame - The raid stats window
]]
function RaidData:CreateRaidStatsWindow()
    if self.raidStatsWindow then
        return self.raidStatsWindow
    end

    local C = HopeAddon.Constants

    -- Main window
    local window = CreateFrame("Frame", "HopeRaidBossStats", UIParent, "BackdropTemplate")
    window:SetSize(RAID_STATS_WIDTH, RAID_STATS_HEIGHT)
    HopeAddon.Components:ApplyBackdropRaw(window, "DARK_FEL",
        0.1, 0.1, 0.1, 0.95,
        0.5, 0.3, 0.7, 1)
    window:SetFrameStrata("HIGH")
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    window:SetClampedToScreen(true)

    -- Boss icon (top-left)
    local bossIcon = window:CreateTexture(nil, "ARTWORK")
    bossIcon:SetSize(44, 44)
    bossIcon:SetPoint("TOPLEFT", window, "TOPLEFT", 15, -15)
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    window.bossIcon = bossIcon

    -- Boss name
    local bossName = window:CreateFontString(nil, "OVERLAY")
    bossName:SetFont(HopeAddon.assets.fonts.HEADER, 15, "")
    bossName:SetPoint("LEFT", bossIcon, "RIGHT", 12, 0)
    bossName:SetPoint("RIGHT", window, "RIGHT", -40, 0)
    bossName:SetJustifyH("LEFT")
    bossName:SetTextColor(1, 1, 1)
    window.bossName = bossName

    -- "DEFEATED" subtitle
    local defeatedText = window:CreateFontString(nil, "OVERLAY")
    defeatedText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    defeatedText:SetPoint("TOPLEFT", bossName, "BOTTOMLEFT", 0, -2)
    defeatedText:SetText("DEFEATED")
    defeatedText:SetTextColor(0.5, 0.3, 0.7)
    window.defeatedText = defeatedText

    -- Raid name + kill count
    local raidName = window:CreateFontString(nil, "OVERLAY")
    raidName:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    raidName:SetPoint("TOPLEFT", defeatedText, "BOTTOMLEFT", 0, -1)
    raidName:SetTextColor(0.7, 0.7, 0.7)
    window.raidName = raidName

    -- Separator line
    local separatorLine = window:CreateTexture(nil, "ARTWORK")
    separatorLine:SetTexture(HopeAddon.assets.textures.SOLID or TEX_WHITE8X8)
    separatorLine:SetSize(RAID_STATS_WIDTH - 30, 1)
    separatorLine:SetPoint("TOP", window, "TOP", 0, -68)
    separatorLine:SetVertexColor(0.5, 0.3, 0.7, 0.6)
    window.separatorLine = separatorLine

    -- Stats container
    local statsContainer = CreateFrame("Frame", nil, window)
    statsContainer:SetSize(300, 40)
    statsContainer:SetPoint("TOP", window, "TOP", 0, -78)
    window.statsContainer = statsContainer

    -- "Kill Time:" label
    local thisKillLabel = statsContainer:CreateFontString(nil, "OVERLAY")
    thisKillLabel:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    thisKillLabel:SetPoint("TOPLEFT", statsContainer, "TOPLEFT", 0, 0)
    thisKillLabel:SetText("Kill Time:")
    thisKillLabel:SetTextColor(0.7, 0.7, 0.7)

    -- Kill time value
    local thisKillTime = statsContainer:CreateFontString(nil, "OVERLAY")
    thisKillTime:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    thisKillTime:SetPoint("LEFT", thisKillLabel, "RIGHT", 5, 0)
    thisKillTime:SetTextColor(1, 1, 1)
    window.thisKillTime = thisKillTime

    -- "Best:" label
    local bestTimeLabel = statsContainer:CreateFontString(nil, "OVERLAY")
    bestTimeLabel:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    bestTimeLabel:SetPoint("TOPLEFT", statsContainer, "TOPLEFT", 160, 0)
    bestTimeLabel:SetText("Best:")
    bestTimeLabel:SetTextColor(0.7, 0.7, 0.7)

    -- Best time value
    local bestTimeValue = statsContainer:CreateFontString(nil, "OVERLAY")
    bestTimeValue:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    bestTimeValue:SetPoint("LEFT", bestTimeLabel, "RIGHT", 5, 0)
    bestTimeValue:SetTextColor(0.2, 0.8, 0.2)
    window.bestTimeValue = bestTimeValue

    -- "Kill #X" text (right-aligned)
    local totalKillsText = statsContainer:CreateFontString(nil, "OVERLAY")
    totalKillsText:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    totalKillsText:SetPoint("TOPRIGHT", statsContainer, "TOPRIGHT", 0, 0)
    totalKillsText:SetTextColor(1, 1, 1)
    window.totalKillsText = totalKillsText

    -- Time comparison bar container
    local barContainer = CreateFrame("Frame", nil, window)
    barContainer:SetSize(300, 18)
    barContainer:SetPoint("TOP", statsContainer, "BOTTOM", 0, -10)
    window.barContainer = barContainer

    -- Bar background
    local barBg = barContainer:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints(barContainer)
    barBg:SetTexture(TEX_WHITE8X8)
    barBg:SetVertexColor(0.15, 0.15, 0.15, 0.8)

    -- Current kill time bar (phase-colored)
    local thisBar = barContainer:CreateTexture(nil, "ARTWORK")
    thisBar:SetHeight(18)
    thisBar:SetPoint("LEFT", barContainer, "LEFT", 0, 0)
    thisBar:SetTexture(TEX_STATUS_BAR)
    thisBar:SetVertexColor(0.5, 0.3, 0.7, 1)
    thisBar:SetWidth(0.001)
    window.thisBar = thisBar

    -- Best time marker (green vertical line)
    local bestMarker = barContainer:CreateTexture(nil, "OVERLAY")
    bestMarker:SetSize(2, 22)
    bestMarker:SetTexture(TEX_WHITE8X8)
    bestMarker:SetVertexColor(0.2, 0.8, 0.2, 1)
    bestMarker:Hide()
    window.bestMarker = bestMarker

    -- Personal best badge
    local pbBadge = window:CreateFontString(nil, "OVERLAY")
    pbBadge:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    pbBadge:SetPoint("TOP", barContainer, "BOTTOM", 0, -5)
    pbBadge:SetText("NEW PERSONAL BEST!")
    pbBadge:SetTextColor(1, 0.84, 0)
    pbBadge:Hide()
    window.pbBadge = pbBadge

    -- Boss quote container (final boss only)
    local quoteContainer = CreateFrame("Frame", nil, window, "BackdropTemplate")
    quoteContainer:SetSize(300, 50)
    quoteContainer:SetPoint("TOP", pbBadge, "BOTTOM", 0, -8)
    HopeAddon.Components:ApplyBackdropRaw(quoteContainer, "TOOLTIP_SMALL",
        0.12, 0.12, 0.12, 0.9,
        0.35, 0.21, 0.49, 0.6)
    quoteContainer:Hide()
    window.quoteContainer = quoteContainer

    -- Quote text
    local quoteText = quoteContainer:CreateFontString(nil, "OVERLAY")
    quoteText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    quoteText:SetPoint("TOPLEFT", quoteContainer, "TOPLEFT", 8, -6)
    quoteText:SetPoint("BOTTOMRIGHT", quoteContainer, "BOTTOMRIGHT", -8, 16)
    quoteText:SetJustifyH("CENTER")
    quoteText:SetJustifyV("TOP")
    quoteText:SetWordWrap(true)
    quoteText:SetTextColor(0.85, 0.85, 0.85)
    window.quoteText = quoteText

    -- Quote attribution
    local quoteAttribution = quoteContainer:CreateFontString(nil, "OVERLAY")
    quoteAttribution:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    quoteAttribution:SetPoint("BOTTOMRIGHT", quoteContainer, "BOTTOMRIGHT", -8, 4)
    quoteAttribution:SetTextColor(0.5, 0.5, 0.5)
    window.quoteAttribution = quoteAttribution

    -- Raid progress text (final boss only)
    local progressText = window:CreateFontString(nil, "OVERLAY")
    progressText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    progressText:SetPoint("BOTTOM", window, "BOTTOM", 0, 15)
    progressText:SetTextColor(0.7, 0.7, 0.7)
    progressText:Hide()
    window.progressText = progressText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", window, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        RaidData:HideRaidBossStats()
    end)

    window:Hide()
    self.raidStatsWindow = window
    return window
end

--[[
    Show the raid boss stats popup after a kill
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @param killData table - Kill record from RecordBossKill
]]
function RaidData:ShowRaidBossStats(raidKey, bossId, killData)
    if not self.raidStatsWindow then
        self:CreateRaidStatsWindow()
    end

    local window = self.raidStatsWindow
    local boss = self:GetBoss(raidKey, bossId)
    local raid = self:GetRaid(raidKey)
    if not boss or not raid then return end

    -- Cancel existing auto-hide timer
    if self.raidStatsTimer then
        self.raidStatsTimer:Cancel()
        self.raidStatsTimer = nil
    end

    -- Stop any existing glows
    if HopeAddon.Glow then
        HopeAddon.Glow:StopAllFor(window.bossIcon)
    end

    -- Determine final boss status and phase color
    local isFinal = self:IsFinalBoss(raidKey, bossId)
    local colorName = self:GetPhaseColorName(raidKey)
    local phaseColor = HopeAddon.colors[colorName] or HopeAddon.colors.KARA_PURPLE

    -- Resize window for final boss
    if isFinal then
        window:SetSize(RAID_STATS_ENHANCED_WIDTH, RAID_STATS_ENHANCED_HEIGHT)
        window.separatorLine:SetWidth(RAID_STATS_ENHANCED_WIDTH - 30)
    else
        window:SetSize(RAID_STATS_WIDTH, RAID_STATS_HEIGHT)
        window.separatorLine:SetWidth(RAID_STATS_WIDTH - 30)
    end

    -- Set backdrop border color to phase color
    window:SetBackdropBorderColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)

    -- Set boss icon
    if killData.icon then
        window.bossIcon:SetTexture(killData.icon)
    else
        window.bossIcon:SetTexture("Interface\\Icons\\" .. (boss.icon or raid.icon))
    end

    -- Set boss name
    window.bossName:SetText(boss.name)

    -- Set "DEFEATED" subtitle in phase color
    window.defeatedText:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b)

    -- Set raid name + kill count
    window.raidName:SetText(raid.name .. "  |  Kill #" .. killData.totalKills)

    -- Set separator line color
    window.separatorLine:SetVertexColor(phaseColor.r, phaseColor.g, phaseColor.b, 0.6)

    -- Set kill time and best time
    local killTime = killData.lastTime
    local bestTime = killData.bestTime
    local hasTime = killTime and killTime > 0

    window.thisKillTime:SetText(hasTime and HopeAddon:FormatTime(killTime) or "--:--")
    window.bestTimeValue:SetText(bestTime and HopeAddon:FormatTime(bestTime) or "--:--")

    -- Check for new personal best
    local isNewPB = hasTime and bestTime and killTime <= bestTime and killData.totalKills > 1
    if isNewPB then
        window.bestTimeValue:SetTextColor(1, 0.84, 0) -- gold for new PB
    else
        window.bestTimeValue:SetTextColor(0.2, 0.8, 0.2) -- green normally
    end

    -- Set kill count text (will be animated)
    window.totalKillsText:SetText("Kill #" .. killData.totalKills)

    -- Set time bar color to phase color
    window.thisBar:SetVertexColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)
    window.thisBar:SetWidth(0.001)

    -- Handle time comparison bar
    if hasTime then
        window.barContainer:Show()

        -- Calculate bar proportions
        local barWidth = isFinal and 360 or 300
        window.barContainer:SetWidth(barWidth)

        local maxTime = killTime
        if bestTime and bestTime > maxTime then maxTime = bestTime end
        maxTime = maxTime * 1.1 -- 10% padding

        local targetBarWidth = (killTime / maxTime) * barWidth

        -- Position best marker
        if bestTime and bestTime > 0 and not isNewPB then
            local markerX = (bestTime / maxTime) * barWidth - 1
            window.bestMarker:ClearAllPoints()
            window.bestMarker:SetPoint("LEFT", window.barContainer, "LEFT", markerX, 0)
            window.bestMarker:Show()
        else
            window.bestMarker:Hide()
        end

        -- Animate bar width (delayed 0.3s)
        HopeAddon.Timer:After(0.3, function()
            if not window:IsShown() then return end
            HopeAddon.Animations:AnimateValue(0.001, targetBarWidth, 0.3, function(current)
                if window:IsShown() then
                    window.thisBar:SetWidth(math.max(0.001, current))
                end
            end)
        end)
    else
        window.barContainer:Hide()
    end

    -- PB Badge
    window.pbBadge:Hide()
    if isNewPB then
        HopeAddon.Timer:After(0.5, function()
            if not window:IsShown() then return end
            HopeAddon.Effects:PopIn(window.pbBadge, 0.3)
        end)
    end

    -- Final boss extras
    if isFinal then
        -- Boss quote
        if boss.quote and boss.quote ~= "" then
            window.quoteText:SetText("\"" .. boss.quote .. "\"")
            window.quoteAttribution:SetText("- " .. boss.name)
            -- Tint quote container border with phase color
            window.quoteContainer:SetBackdropBorderColor(
                phaseColor.r * 0.7, phaseColor.g * 0.7, phaseColor.b * 0.7, 0.6)
            window.quoteContainer:Show()
        else
            window.quoteContainer:Hide()
        end

        -- Raid progress
        local killed, total = self:GetRaidProgress(raidKey)
        if killed >= total then
            window.progressText:SetText("RAID COMPLETE!")
            window.progressText:SetTextColor(1, 0.84, 0)
        else
            window.progressText:SetText(raid.name .. ": " .. killed .. "/" .. total .. " Bosses Cleared")
            window.progressText:SetTextColor(0.7, 0.7, 0.7)
        end
        window.progressText:Show()
    else
        window.quoteContainer:Hide()
        window.progressText:Hide()
    end

    -- Position for entrance animation (start slightly high)
    window:ClearAllPoints()
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 130)
    window:SetAlpha(0)
    window:Show()

    -- Play sound
    if HopeAddon.Sounds then
        if isFinal then
            HopeAddon.Sounds:PlayVictory()
        else
            HopeAddon.Sounds:PlayBossKill()
        end
    end

    -- Entrance animation: FadeIn + slide down (snappy)
    local slideDuration = isFinal and 0.35 or 0.3
    HopeAddon.Effects:FadeIn(window, slideDuration)
    HopeAddon.Animations:MoveTo(window, 0, 100, slideDuration)

    -- Animate kill count (delayed, snappy)
    local countDelay = isFinal and 0.4 or 0.25
    HopeAddon.Timer:After(countDelay, function()
        if not window:IsShown() then return end
        HopeAddon.Animations:CountUp(window.totalKillsText, 0, killData.totalKills, 0.5,
            function(v) return "Kill #" .. math.floor(v) end)
    end)

    -- Final boss enhanced effects
    if isFinal then
        -- Shake effect at 0.5s (shorter duration)
        HopeAddon.Timer:After(0.5, function()
            if not window:IsShown() then return end
            HopeAddon.Animations:Shake(window, 4, 0.2)
        end)

        -- EpicGlow on boss icon at 0.5s
        if HopeAddon.Glow then
            HopeAddon.Timer:After(0.5, function()
                if not window:IsShown() then return end
                HopeAddon.Glow:CreateEpicGlow(window.bossIcon, colorName)
            end)
        end

        -- CelebrateAchievement bounce on title at 0.8s
        HopeAddon.Timer:After(0.8, function()
            if not window:IsShown() then return end
            HopeAddon.Animations:CelebrateAchievement(window.bossName)
        end)
    end

    -- Store context for breakdown chain
    self._lastRecapContext = {
        raidKey = raidKey,
        bossId = bossId,
        killData = killData,
        isFinal = isFinal,
    }

    -- Auto-hide timer → chain to breakdown panel if encounter data available
    local duration = isFinal and RAID_STATS_FINAL_DURATION or RAID_STATS_DURATION
    self.raidStatsTimer = HopeAddon.Timer:After(duration, function()
        self:HideRaidBossStats(function()
            -- Chain to breakdown panel if encounter data exists
            if HopeAddon.BossBreakdown and HopeAddon.EncounterTracker then
                local summary = HopeAddon.EncounterTracker:GetEncounterSummary()
                if summary and (#summary.topDPS > 0 or #summary.topHPS > 0) then
                    local ctx = self._lastRecapContext
                    if ctx then
                        HopeAddon.BossBreakdown:ShowBreakdown(
                            ctx.raidKey, ctx.bossId, ctx.killData, summary, ctx.isFinal)
                    end
                end
            end
        end)
    end)
end

--[[
    Hide the raid boss stats popup
]]
function RaidData:HideRaidBossStats(callback)
    if self.raidStatsTimer then
        self.raidStatsTimer:Cancel()
        self.raidStatsTimer = nil
    end

    local window = self.raidStatsWindow
    if not window or not window:IsShown() then
        if callback then callback() end
        return
    end

    -- Stop glows
    if HopeAddon.Glow then
        HopeAddon.Glow:StopAllFor(window.bossIcon)
    end

    -- FadeOut then hide, then chain to callback (breakdown panel)
    HopeAddon.Effects:FadeOut(window, 0.5, function()
        window:Hide()
        if callback then callback() end
    end)
end

--============================================================
-- EVENT HANDLING FOR AUTOMATIC BOSS KILL DETECTION
--============================================================

-- Track which bosses we've already recorded kills for this session
-- (prevents duplicate tracking from both ENCOUNTER_END and COMBAT_LOG)
local recentKills = {}

--[[
    Register for combat events
]]
function RaidData:RegisterEvents()
    -- Create event frame on self for proper cleanup in OnDisable
    self.eventFrame = CreateFrame("Frame")

    -- NOTE: ENCOUNTER_END does NOT exist in TBC Classic 2.4.3
    -- Boss detection relies on COMBAT_LOG_EVENT_UNFILTERED UNIT_DIED
    -- Keeping registration for potential compatibility, but it will silently fail to fire
    self.eventFrame:RegisterEvent("ENCOUNTER_END")
    -- Always register COMBAT_LOG as fallback (definitely exists in TBC Classic)
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- Chat events for DBM/BigWigs kill time capture
    self.eventFrame:RegisterEvent("CHAT_MSG_RAID")
    self.eventFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
    self.eventFrame:RegisterEvent("CHAT_MSG_PARTY")
    self.eventFrame:RegisterEvent("CHAT_MSG_SAY")

    -- Combat state tracking (for manual timer fallback)
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
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
            -- Forward to encounter tracker for DPS/HPS/death collection
            if HopeAddon.EncounterTracker and HopeAddon.EncounterTracker:IsActive() then
                pcall(HopeAddon.EncounterTracker.ProcessCombatEvent, HopeAddon.EncounterTracker, ...)
            end
        elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_WARNING"
               or event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_SAY" then
            local success, err = pcall(RaidData.OnChatMessage, RaidData, event, ...)
            if not success then
                HopeAddon:Debug("Chat message handler error:", err)
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            RaidData:OnCombatStart()
        elseif event == "PLAYER_REGEN_ENABLED" then
            RaidData:OnCombatEnd()
        end
    end)
end

--[[
    Extract NPC ID from GUID
    @param guid string - Unit GUID
    @return number|nil - NPC ID or nil

    TBC Classic 2.4.3 GUID formats:
    - Creature: "0xF130NNNNNN000000" where NNNNNN is NPC ID in hex (positions 5-10)
    - Player: "0x0000000000XXXXXX"

    Modern WoW (for compatibility):
    - "Creature-0-XXXX-XXXX-XXXX-NPCID-INSTANCEID"
]]
local function GetNpcIdFromGuid(guid)
    if not guid then return nil end

    -- Try modern format first (hyphen-separated)
    if guid:find("-") then
        local npcId = select(6, strsplit("-", guid))
        if npcId then
            return tonumber(npcId)
        end
    end

    -- TBC Classic format: "0xF130NNNNNN000000" or "0xF1300000NNNNNN00"
    -- The NPC ID is encoded in the hex GUID
    -- Format: 0xF13 + type(0) + NPC_ID(6 hex) + spawn_ID(8 hex)
    if guid:sub(1, 2) == "0x" then
        -- Check if it's a creature (starts with 0xF13)
        local typeFlag = guid:sub(3, 5)
        if typeFlag == "F13" or typeFlag == "f13" then
            -- Extract NPC ID from positions 6-11 (6 hex digits after type marker)
            local npcHex = guid:sub(6, 11)
            local npcId = tonumber(npcHex, 16)
            if npcId and npcId > 0 then
                return npcId
            end
        end
    end

    return nil
end

--[[
    Handle combat log event (UNIT_DIED fallback for boss detection)

    TBC Classic 2.4.3 COMBAT_LOG_EVENT_UNFILTERED arguments:
    1: timestamp
    2: event/subEvent
    3: srcGUID
    4: srcName
    5: srcFlags
    6: dstGUID (destGuid)
    7: dstName (destName)
    8: dstFlags

    Note: Modern WoW has hideCaster at position 3, shifting everything.
    TBC 2.4.3 does NOT have hideCaster.
]]
function RaidData:OnCombatLogEvent(...)
    -- TBC 2.4.3 format: timestamp, subEvent, srcGUID, srcName, srcFlags, destGuid, destName, destFlags
    local args = {...}
    if #args < 7 then return end  -- Guard against malformed combat log events
    local timestamp, subEvent, srcGuid, srcName, srcFlags, destGuid, destName = unpack(args)

    -- Only care about deaths
    if not subEvent or subEvent ~= "UNIT_DIED" then return end

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

    -- Finish encounter tracking before recording (captures final stats)
    if HopeAddon.EncounterTracker and HopeAddon.EncounterTracker:IsActive() then
        HopeAddon.EncounterTracker:FinishEncounter()
    end

    local killData = self:RecordBossKill(mapping.raid, mapping.boss)
    if killData then
        self:ShowRaidBossStats(mapping.raid, mapping.boss, killData)

        if killData.totalKills == 1 then
            -- First kill - also show journal notification + milestones
            local Journal = HopeAddon:GetModule("Journal")
            if Journal and Journal.ShowBossKillNotification then
                Journal:ShowBossKillNotification(killData)
            end

            -- Check for tier/boss milestones
            if HopeAddon.Milestones then
                HopeAddon.Milestones:CheckTierMilestone(mapping.raid, mapping.boss)
            end
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

    -- Finish encounter tracking before recording (captures final stats)
    if HopeAddon.EncounterTracker and HopeAddon.EncounterTracker:IsActive() then
        HopeAddon.EncounterTracker:FinishEncounter()
    end

    local killData = self:RecordBossKill(mapping.raid, mapping.boss)
    if killData then
        self:ShowRaidBossStats(mapping.raid, mapping.boss, killData)

        if killData.totalKills == 1 then
            -- First kill - also show journal notification + milestones
            local Journal = HopeAddon:GetModule("Journal")
            if Journal and Journal.ShowBossKillNotification then
                Journal:ShowBossKillNotification(killData)
            end

            -- Check for tier/boss milestones
            if HopeAddon.Milestones then
                HopeAddon.Milestones:CheckTierMilestone(mapping.raid, mapping.boss)
            end
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
    Handle chat messages for DBM/BigWigs kill time capture
    @param event string - Event type
    @param msg string - Message text
    @param sender string - Who sent the message
]]
function RaidData:OnChatMessage(event, msg, sender)
    local bossName, killTime = ParseKillTimeMessage(msg)
    if bossName and killTime then
        combatState.recentDBMTime = killTime
        combatState.recentDBMBoss = bossName
        combatState.recentDBMTimestamp = GetTime()
        HopeAddon:Debug("Captured DBM kill time:", bossName, HopeAddon:FormatTime(killTime))
    end
end

--[[
    Handle entering combat (for manual timer fallback)
]]
function RaidData:OnCombatStart()
    -- Only track if we're in a raid instance
    local _, instanceType = IsInInstance()
    if instanceType ~= "raid" then return end

    combatState.inCombat = true
    combatState.combatStartTime = GetTime()
    HopeAddon:Debug("Combat started, manual timer active")

    -- Cancel any pending encounter abort timer
    if self._encounterAbortTimer then
        self._encounterAbortTimer:Cancel()
        self._encounterAbortTimer = nil
    end

    -- Start encounter tracking for breakdown panel
    if HopeAddon.EncounterTracker then
        HopeAddon.EncounterTracker:StartTracking()
    end
end

--[[
    Handle leaving combat
]]
function RaidData:OnCombatEnd()
    combatState.inCombat = false
    -- Don't clear combatStartTime - let RecordBossKill use it if needed
    HopeAddon:Debug("Combat ended")

    -- Set a 5-second abort timer for encounter tracker
    -- If the encounter wasn't finished by a boss kill, abort tracking
    if HopeAddon.EncounterTracker and HopeAddon.EncounterTracker:IsActive() then
        self._encounterAbortTimer = HopeAddon.Timer:After(5, function()
            if HopeAddon.EncounterTracker and HopeAddon.EncounterTracker:IsActive() then
                HopeAddon.EncounterTracker:AbortTracking()
                HopeAddon:Debug("Encounter tracker aborted (no boss kill detected)")
            end
        end)
    end
end

--[[
    Record a kill time for a boss
    @param key string - Boss key (raidKey_bossId)
    @param killTime number - Kill time in seconds
    @param source string - "DBM", "BigWigs", or "Manual"
    @return boolean - True if new personal best
]]
function RaidData:RecordKillTime(key, killTime, source)
    local kills = HopeAddon.charDb.journal.bossKills
    local killData = kills[key]
    if not killData then return false end

    -- Update last time
    killData.lastTime = killTime

    -- Check for new personal best
    local isNewBest = false
    if not killData.bestTime or killTime < killData.bestTime then
        local previousBest = killData.bestTime
        killData.bestTime = killTime
        killData.bestTimeDate = HopeAddon:GetDate()
        isNewBest = true

        -- Announce personal best
        if previousBest then
            local improvement = previousBest - killTime
            HopeAddon:Print(string.format(
                "|cFF00FF00NEW PERSONAL BEST!|r %s in %s (%.1fs faster!)",
                killData.bossName,
                HopeAddon:FormatTime(killTime),
                improvement
            ))
        else
            HopeAddon:Print(string.format(
                "|cFFFFD700First timed kill!|r %s in %s",
                killData.bossName,
                HopeAddon:FormatTime(killTime)
            ))
        end
    end

    -- Store in history (keep last 5 kills)
    killData.killTimes = killData.killTimes or {}
    table.insert(killData.killTimes, 1, {
        time = killTime,
        date = HopeAddon:GetDate(),
        source = source,
    })
    while #killData.killTimes > 5 do
        table.remove(killData.killTimes)
    end

    HopeAddon:Debug("Recorded kill time:", killData.bossName, HopeAddon:FormatTime(killTime), "source:", source, isNewBest and "(NEW PB!)" or "")

    return isNewBest
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
    -- Note: Running alongside damage meters (for debug awareness)
    if not self.combatLogAddonNoted then
        local combatLogAddons = { "Details", "Recount", "Skada", "TinyDPS" }
        for _, addon in ipairs(combatLogAddons) do
            local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
            if loaded(addon) then
                HopeAddon:Debug("RaidData: Running alongside " .. addon .. " - combat log events shared")
                break
            end
        end
        self.combatLogAddonNoted = true
    end

    self:RegisterEvents()
end

--[[
    Module disable hook
]]
function RaidData:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
    -- Clear recent kills cache
    if recentKills then
        wipe(recentKills)
    end
    -- Clean up raid stats window
    if self.raidStatsTimer then
        self.raidStatsTimer:Cancel()
        self.raidStatsTimer = nil
    end
    if self.raidStatsWindow then
        self.raidStatsWindow:Hide()
    end
end

-- Register with addon
HopeAddon:RegisterModule("RaidData", RaidData)
if HopeAddon.Debug then
    HopeAddon:Debug("RaidData module loaded")
end
