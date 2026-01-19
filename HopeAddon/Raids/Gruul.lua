--[[
    HopeAddon Gruul Module
    Gruul's Lair-specific raid features and UI
]]

local Gruul = {}
HopeAddon.Gruul = Gruul

-- Gruul boss IDs for encounter detection
Gruul.ENCOUNTER_IDS = {
    MAULGAR = 649,
    GRUUL = 650,
}

-- High King Maulgar council members
Gruul.MAULGAR_COUNCIL = {
    { name = "High King Maulgar", npcId = 18831, role = "Main", tank = "Main Tank" },
    { name = "Kiggler the Crazed", npcId = 18835, role = "Shaman", tank = "Hunter/Lock Pet" },
    { name = "Blindeye the Seer", npcId = 18836, role = "Priest", tank = "Off Tank" },
    { name = "Olm the Summoner", npcId = 18834, role = "Warlock", tank = "Off Tank" },
    { name = "Krosh Firehand", npcId = 18832, role = "Mage", tank = "MAGE (Spellsteal)" },
}

--[[
    Get Gruul raid data
    @return table - Raid data from constants
]]
function Gruul:GetRaidData()
    return HopeAddon.Constants.GRUUL_BOSSES
end

--[[
    Get boss data by ID
    @param bossId string - Boss identifier (e.g., "gruul")
    @return table|nil - Boss data
]]
function Gruul:GetBossData(bossId)
    local bosses = self:GetRaidData()
    for _, boss in ipairs(bosses) do
        if boss.id == bossId then
            return boss
        end
    end
    return nil
end

--[[
    Get boss kill count
    @param bossId string - Boss identifier
    @return number - Kill count
]]
function Gruul:GetBossKillCount(bossId)
    local kills = HopeAddon.charDb.stats.raidClears.gruul
    if not kills then return 0 end
    return kills[bossId] or 0
end

--[[
    Record a boss kill
    @param bossId string - Boss identifier
]]
function Gruul:RecordBossKill(bossId)
    -- Initialize if needed
    if not HopeAddon.charDb.stats.raidClears.gruul then
        HopeAddon.charDb.stats.raidClears.gruul = {}
    end

    local kills = HopeAddon.charDb.stats.raidClears.gruul
    kills[bossId] = (kills[bossId] or 0) + 1

    local boss = self:GetBossData(bossId)
    if boss then
        -- Create journal entry for first kill
        if kills[bossId] == 1 then
            self:CreateFirstKillEntry(boss)
        end

        -- Check for full clear
        self:CheckFullClear()
    end
end

--[[
    Create a journal entry for first boss kill
    @param boss table - Boss data
]]
function Gruul:CreateFirstKillEntry(boss)
    local entry = {
        type = "boss_kill",
        title = boss.name .. " Defeated!",
        description = boss.lore,
        icon = "Interface\\Icons\\" .. boss.icon,
        raidName = "Gruul's Lair",
        bossId = boss.id,
        location = boss.location,
        timestamp = HopeAddon:GetTimestamp(),
        party = HopeAddon.FellowTravelers:GetPartySnapshot(),
    }

    table.insert(HopeAddon.charDb.journal.entries, entry)
    HopeAddon.charDb.journal.bossKills[boss.id] = entry

    -- Special message for Gruul
    if boss.id == "gruul" then
        HopeAddon:Print(HopeAddon:ColorText("THE DRAGONKILLER FALLS!", "GOLD_BRIGHT") ..
            " Gruul has been defeated!")
    else
        HopeAddon:Print(HopeAddon:ColorText("BOSS DEFEATED!", "GOLD_BRIGHT") .. " " .. boss.name)
    end

    HopeAddon.Sounds:PlayBossKill()

    -- Notify Badges module of boss kill
    if HopeAddon.Badges then
        HopeAddon.Badges:OnBossKilled(boss.name)
    end
end

--[[
    Check if all bosses have been killed (full clear)
]]
function Gruul:CheckFullClear()
    local requiredBosses = { "maulgar", "gruul" }
    local kills = HopeAddon.charDb.stats.raidClears.gruul or {}
    local allKilled = true

    for _, bossId in ipairs(requiredBosses) do
        if not kills[bossId] or kills[bossId] == 0 then
            allKilled = false
            break
        end
    end

    if allKilled then
        -- Check if this is the first full clear
        if not HopeAddon.charDb.stats.raidClears.gruul_full_clear then
            HopeAddon.charDb.stats.raidClears.gruul_full_clear = {
                date = HopeAddon:GetDate(),
                timestamp = HopeAddon:GetTimestamp(),
            }

            local entry = {
                type = "raid_clear",
                title = "Gruul's Lair Cleared!",
                description = "The Gronn Father has fallen! Dragon bones litter his empty throne.",
                icon = "Interface\\Icons\\Ability_Hunter_Pet_Devilsaur",
                raidName = "Gruul's Lair",
                timestamp = HopeAddon:GetTimestamp(),
            }
            table.insert(HopeAddon.charDb.journal.entries, entry)

            HopeAddon:Print(HopeAddon:ColorText("GRUUL'S LAIR CLEARED!", "BRONZE") ..
                " The Gronn's domain is yours!")
            HopeAddon.Sounds:PlayEpicFanfare()
        end
    end
end

--[[
    Get progress summary
    @return table - Progress data
]]
function Gruul:GetProgressSummary()
    local kills = HopeAddon.charDb.stats.raidClears.gruul or {}
    local bosses = self:GetRaidData()

    local killed = 0
    local total = #bosses

    for _, boss in ipairs(bosses) do
        if kills[boss.id] and kills[boss.id] > 0 then
            killed = killed + 1
        end
    end

    return {
        killed = killed,
        total = total,
        percentage = total > 0 and math.floor((killed / total) * 100) or 0,
        fullClear = HopeAddon.charDb.stats.raidClears.gruul_full_clear ~= nil,
        fullClearDate = HopeAddon.charDb.stats.raidClears.gruul_full_clear and
            HopeAddon.charDb.stats.raidClears.gruul_full_clear.date or nil,
    }
end

--[[
    Get tier token info for Gruul's Lair
    @return table - Token drop info
]]
function Gruul:GetTierTokens()
    local tokens = HopeAddon.Constants.T4_TOKENS
    local gruulTokens = {}

    for slot, data in pairs(tokens) do
        if data.raid == "Gruul's Lair" then
            gruulTokens[slot] = data
        end
    end

    return gruulTokens
end

--[[
    Get boss-specific tips
    @param bossId string - Boss identifier
    @return table - Array of tip strings
]]
function Gruul:GetBossTips(bossId)
    local tips = {
        maulgar = {
            "Council fight - all 5 must be controlled",
            "Kill order: Blindeye > Olm > Kiggler > Krosh > Maulgar",
            "Krosh REQUIRES a mage to spellsteal his shield and tank him",
            "Keep Maulgar CC'd (fear/hibernate) if possible",
            "Drops Tier 4 Shoulder tokens",
        },
        gruul = {
            "Growth: +15% damage every 30 sec (SOFT ENRAGE)",
            "Need 2 tanks: OT must be #2 threat for Hurtful Strike",
            "Ground Slam + Shatter: SPREAD OUT or chain damage!",
            "Move out of Cave In (falling rocks)",
            "DPS race - kill before Growth stacks too high",
            "Drops Tier 4 Leg tokens and Dragonspine Trophy",
        },
    }

    return tips[bossId] or {}
end

--[[
    Get Maulgar council assignment help
    @return table - Council info with tank assignments
]]
function Gruul:GetMaulgarAssignments()
    return self.MAULGAR_COUNCIL
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Gruul module loaded")
end
