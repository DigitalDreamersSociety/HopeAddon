--[[
    HopeAddon Karazhan Module
    Karazhan-specific raid features and UI
]]

local Karazhan = {}
HopeAddon.Karazhan = Karazhan

-- Karazhan boss IDs for encounter detection
Karazhan.ENCOUNTER_IDS = {
    ATTUMEN = 652,
    MOROES = 653,
    MAIDEN = 654,
    OPERA = 655,
    CURATOR = 656,
    ARAN = 658,
    ILLHOOF = 657,
    NETHERSPITE = 659,
    CHESS = 660,
    PRINCE = 661,
    NIGHTBANE = 662,
}

-- Opera event variants
Karazhan.OPERA_VARIANTS = {
    [17521] = "Wizard of Oz",
    [17603] = "Big Bad Wolf",
    [17533] = "Romulo and Julianne",
}

--[[
    Get Karazhan raid data
    @return table - Raid data from constants
]]
function Karazhan:GetRaidData()
    return HopeAddon.Constants.KARAZHAN_BOSSES
end

--[[
    Get boss data by ID
    @param bossId string - Boss identifier (e.g., "prince")
    @return table|nil - Boss data
]]
function Karazhan:GetBossData(bossId)
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
function Karazhan:GetBossKillCount(bossId)
    local kills = HopeAddon.charDb.stats.raidClears.karazhan
    if not kills then return 0 end
    return kills[bossId] or 0
end

--[[
    Record a boss kill
    @param bossId string - Boss identifier
]]
function Karazhan:RecordBossKill(bossId)
    -- Initialize if needed
    if not HopeAddon.charDb.stats.raidClears.karazhan then
        HopeAddon.charDb.stats.raidClears.karazhan = {}
    end

    local kills = HopeAddon.charDb.stats.raidClears.karazhan
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
function Karazhan:CreateFirstKillEntry(boss)
    local entry = {
        type = "boss_kill",
        title = boss.name .. " Defeated!",
        description = boss.lore,
        icon = "Interface\\Icons\\" .. boss.icon,
        raidName = "Karazhan",
        bossId = boss.id,
        location = boss.location,
        timestamp = HopeAddon:GetTimestamp(),
        party = HopeAddon.FellowTravelers:GetPartySnapshot(),
    }

    table.insert(HopeAddon.charDb.journal.entries, entry)
    HopeAddon.charDb.journal.bossKills[boss.id] = entry

    -- Notification
    HopeAddon:Print(HopeAddon:ColorText("BOSS DEFEATED!", "GOLD_BRIGHT") .. " " .. boss.name)
    HopeAddon.Sounds:PlayBossKill()

    -- Notify Badges module of boss kill
    if HopeAddon.Badges then
        HopeAddon.Badges:OnBossKilled(boss.name)
    end
end

--[[
    Check if all bosses have been killed (full clear)
]]
function Karazhan:CheckFullClear()
    local requiredBosses = {
        "attumen", "moroes", "maiden", "opera",
        "curator", "aran", "illhoof", "netherspite",
        "chess", "prince"
    }

    local kills = HopeAddon.charDb.stats.raidClears.karazhan or {}
    local allKilled = true

    for _, bossId in ipairs(requiredBosses) do
        if not kills[bossId] or kills[bossId] == 0 then
            allKilled = false
            break
        end
    end

    if allKilled then
        -- Check if this is the first full clear
        if not HopeAddon.charDb.stats.raidClears.karazhan_full_clear then
            HopeAddon.charDb.stats.raidClears.karazhan_full_clear = {
                date = HopeAddon:GetDate(),
                timestamp = HopeAddon:GetTimestamp(),
            }

            local entry = {
                type = "raid_clear",
                title = "Karazhan Cleared!",
                description = "You have conquered the Ivory Tower! All bosses defeated.",
                icon = "Interface\\Icons\\INV_Misc_Key_10",
                raidName = "Karazhan",
                timestamp = HopeAddon:GetTimestamp(),
            }
            table.insert(HopeAddon.charDb.journal.entries, entry)

            HopeAddon:Print(HopeAddon:ColorText("KARAZHAN CLEARED!", "ARCANE_PURPLE") ..
                " The Ivory Tower has fallen!")
            HopeAddon.Sounds:PlayEpicFanfare()
        end
    end
end

--[[
    Get progress summary
    @return table - Progress data
]]
function Karazhan:GetProgressSummary()
    local kills = HopeAddon.charDb.stats.raidClears.karazhan or {}
    local bosses = self:GetRaidData()

    local killed = 0
    local total = 0

    for _, boss in ipairs(bosses) do
        if not boss.summoned then -- Don't count Nightbane as required
            total = total + 1
            if kills[boss.id] and kills[boss.id] > 0 then
                killed = killed + 1
            end
        end
    end

    return {
        killed = killed,
        total = total,
        percentage = total > 0 and math.floor((killed / total) * 100) or 0,
        fullClear = HopeAddon.charDb.stats.raidClears.karazhan_full_clear ~= nil,
        fullClearDate = HopeAddon.charDb.stats.raidClears.karazhan_full_clear and
            HopeAddon.charDb.stats.raidClears.karazhan_full_clear.date or nil,
    }
end

--[[
    Get attunement summary
    @return table - Attunement data
]]
function Karazhan:GetAttunementSummary()
    return HopeAddon.Attunements:GetSummary("karazhan")
end

--[[
    Check if player is attuned
    @return boolean
]]
function Karazhan:IsAttuned()
    return HopeAddon.Attunements:IsAttuned("karazhan")
end

--[[
    Get tier token info for Karazhan
    @return table - Token drop info
]]
function Karazhan:GetTierTokens()
    local tokens = HopeAddon.Constants.T4_TOKENS
    local karaTokens = {}

    for slot, data in pairs(tokens) do
        if data.raid == "Karazhan" then
            karaTokens[slot] = data
        end
    end

    return karaTokens
end

--[[
    Get boss-specific tips
    @param bossId string - Boss identifier
    @return table - Array of tip strings
]]
function Karazhan:GetBossTips(bossId)
    local tips = {
        attumen = {
            "Tank Midnight until Attumen spawns at 95%",
            "At 25% they merge - increased damage",
            "Rare mount drop: Fiery Warhorse (~1%)",
        },
        moroes = {
            "4 random adds spawn - CC them",
            "Kill order: Priest > Holy Paladin > Others",
            "Garrote DOT cannot be removed in combat",
        },
        maiden = {
            "Spread out to avoid Holy Ground chains",
            "Interrupt Holy Fire for massive damage reduction",
            "Repentance: 12 second raid incapacitate",
        },
        opera = {
            "Random event: Wizard of Oz, Big Bad Wolf, or Romulo & Julianne",
            "Oz: Kill Dorothee > Tito > Roar > Strawman > Tinhead > Crone",
            "Wolf: RUN if you get Little Red Riding Hood!",
            "R&J: Kill Julianne first, then Romulo, then both together",
        },
        curator = {
            "Kill Astral Flares immediately when they spawn",
            "Evocation phase = 200% damage taken, BURN!",
            "Drops Tier 4 Gloves token",
        },
        aran = {
            "FLAME WREATH: DO NOT MOVE!",
            "Blizzard: Avoid the moving frost AoE",
            "Arcane Explosion: Run to the wall",
            "Cannot be tanked - no threat table",
        },
        illhoof = {
            "Free Sacrificed players from Demon Chains FAST",
            "Kil'rek imp respawns - offtank or ignore",
            "AoE the imps from portals",
        },
        netherspite = {
            "THREE BEAMS - must be soaked by designated players",
            "Red = Tank, Green = Healer, Blue = DPS",
            "Rotate soakers to manage debuff stacks",
            "Banish phase: Spread out and heal up",
        },
        chess = {
            "Control pieces with abilities: Move, Attack, Special",
            "Focus the enemy King, protect your King",
            "Medivh cheats - move out of fire on the board",
            "Can be soloed with practice",
        },
        prince = {
            "Phase 1 (100-60%): Dodge Enfeeble",
            "Phase 2 (60-30%): Avoid flying axes!",
            "Phase 3 (<30%): Burn phase - use cooldowns",
            "Enfeeble reduces HP to 1 - stay away from Infernals!",
            "Drops Tier 4 Helm token and Gorehowl",
        },
        nightbane = {
            "Requires Blackened Urn from quest chain to summon",
            "Air phase at 75%, 50%, 25%: Kill skeleton adds",
            "Avoid Charred Earth ground effect",
            "Bellowing Roar causes fear - use tremor totem",
        },
    }

    return tips[bossId] or {}
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Karazhan module loaded")
end
