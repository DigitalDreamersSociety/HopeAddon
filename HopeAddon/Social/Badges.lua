--[[
    HopeAddon Badges Module
    Badge definitions, unlock conditions, and reward management
]]

local Badges = {}
HopeAddon.Badges = Badges

--============================================================
-- BADGE DEFINITIONS
--============================================================
Badges.DEFINITIONS = {
    -- Level-based badges
    first_steps = {
        id = "first_steps",
        name = "First Steps",
        description = "Reach level 10",
        icon = "INV_Misc_Foot_Centaur",
        unlock = { type = "level", value = 10 },
        reward = { colorHex = "FF69B4", colorName = "Pink" },  -- Hot Pink
    },
    adventurer = {
        id = "adventurer",
        name = "Adventurer",
        description = "Reach level 30",
        icon = "INV_Misc_Map_01",
        unlock = { type = "level", value = 30 },
        reward = { colorHex = "00BFFF", colorName = "Sky Blue" },  -- Deep Sky Blue
    },
    veteran = {
        id = "veteran",
        name = "Veteran",
        description = "Reach level 58",
        icon = "Spell_Fire_FelFlameRing",
        unlock = { type = "level", value = 58 },
        reward = { colorHex = "32CD32", colorName = "Fel Green" },  -- Lime Green
    },
    hero_of_outland = {
        id = "hero_of_outland",
        name = "Hero of Outland",
        description = "Reach level 70",
        icon = "Achievement_Level_70",
        unlock = { type = "level", value = 70 },
        reward = { colorHex = "FFD700", colorName = "Gold", title = "Hero" },  -- Gold
    },

    -- Attunement-based badges
    karazhan_attuned = {
        id = "karazhan_attuned",
        name = "Keeper of the Key",
        description = "Complete Karazhan attunement",
        icon = "INV_Misc_Key_10",
        unlock = { type = "attunement", value = "karazhan" },
        reward = { colorHex = "9B30FF", colorName = "Arcane Purple", borderStyle = "arcane" },  -- Purple
    },
    ssc_attuned = {
        id = "ssc_attuned",
        name = "Fathom Lord's Chosen",
        description = "Complete SSC attunement",
        icon = "INV_Misc_MonsterClaw_03",
        unlock = { type = "attunement", value = "ssc" },
        reward = { colorHex = "00CED1", colorName = "Deep Teal", borderStyle = "water" },  -- Dark Turquoise
    },
    tk_attuned = {
        id = "tk_attuned",
        name = "Tempest's Eye",
        description = "Complete Tempest Keep attunement",
        icon = "Spell_Arcane_PortalShattrath",
        unlock = { type = "attunement", value = "tk" },
        reward = { colorHex = "FF8C00", colorName = "Tempest Orange", borderStyle = "arcane" },  -- Dark Orange
    },

    -- Raid boss badges
    prince_slayer = {
        id = "prince_slayer",
        name = "Prince Slayer",
        description = "Defeat Prince Malchezaar",
        icon = "Spell_Shadow_DeathPact",
        unlock = { type = "boss", value = "Prince Malchezaar" },
        reward = { colorHex = "A335EE", colorName = "Epic Purple", title = "Prince Slayer" },  -- Epic color
    },
    gruul_slayer = {
        id = "gruul_slayer",
        name = "Dragonkiller",
        description = "Defeat Gruul the Dragonkiller",
        icon = "Ability_Warrior_Rampage",
        unlock = { type = "boss", value = "Gruul the Dragonkiller" },
        reward = { colorHex = "8B4513", colorName = "Earth Brown", title = "Dragonkiller" },  -- Saddle Brown
    },
    magtheridon_slayer = {
        id = "magtheridon_slayer",
        name = "Pit Lord's Bane",
        description = "Defeat Magtheridon",
        icon = "Spell_Fire_FelFire",
        unlock = { type = "boss", value = "Magtheridon" },
        reward = { colorHex = "DC143C", colorName = "Crimson", title = "Pit Lord's Bane" },  -- Crimson
    },
    vashj_slayer = {
        id = "vashj_slayer",
        name = "Serpent's Bane",
        description = "Defeat Lady Vashj",
        icon = "INV_Misc_MonsterClaw_03",
        unlock = { type = "boss", value = "Lady Vashj" },
        reward = { colorHex = "20B2AA", colorName = "Sea Green", title = "Champion" },  -- Light Sea Green
    },
    kael_slayer = {
        id = "kael_slayer",
        name = "Sunstrider's End",
        description = "Defeat Kael'thas Sunstrider",
        icon = "Spell_Fire_FelFlameRing",
        unlock = { type = "boss", value = "Kael'thas Sunstrider" },
        reward = { colorHex = "FF4500", colorName = "Phoenix Orange", title = "Champion" },  -- Orange Red
    },

    -- Reputation-based badges
    exalted_first = {
        id = "exalted_first",
        name = "Exalted One",
        description = "Reach Exalted with any TBC faction",
        icon = "Achievement_Reputation_08",
        unlock = { type = "reputation", value = "any_exalted" },
        reward = { colorHex = "FFEE8C", colorName = "Pale Gold" },  -- Pale Gold
    },
    aldor_exalted = {
        id = "aldor_exalted",
        name = "The Aldor's Champion",
        description = "Reach Exalted with The Aldor",
        icon = "INV_Misc_Token_Aldor",
        unlock = { type = "reputation", value = "The Aldor" },
        reward = { colorHex = "FFFFFF", colorName = "Holy White", title = "of the Aldor" },  -- White
    },
    scryer_exalted = {
        id = "scryer_exalted",
        name = "Scryer's Chosen",
        description = "Reach Exalted with The Scryers",
        icon = "INV_Misc_Token_Scryer",
        unlock = { type = "reputation", value = "The Scryers" },
        reward = { colorHex = "6A5ACD", colorName = "Arcane Blue", title = "of the Scryers" },  -- Slate Blue
    },

    -- Special badges
    flying_mount = {
        id = "flying_mount",
        name = "Sky Rider",
        description = "Learn flying in Outland",
        icon = "Ability_Mount_Gryphon_01",
        unlock = { type = "spell", value = 34090 }, -- Apprentice Riding (Flying)
        reward = { colorHex = "87CEEB", colorName = "Sky Blue" },  -- Sky Blue
    },
    epic_flying = {
        id = "epic_flying",
        name = "Swift as the Wind",
        description = "Learn epic flying",
        icon = "Ability_Mount_Netherdrakepurple",
        unlock = { type = "spell", value = 34091 }, -- Artisan Riding
        reward = { colorHex = "4169E1", colorName = "Royal Blue", title = "Swiftwind" },  -- Royal Blue
    },
}

-- Sorted order for display
Badges.DISPLAY_ORDER = {
    "first_steps", "adventurer", "veteran", "hero_of_outland",
    "karazhan_attuned", "ssc_attuned", "tk_attuned",
    "prince_slayer", "gruul_slayer", "magtheridon_slayer", "vashj_slayer", "kael_slayer",
    "exalted_first", "aldor_exalted", "scryer_exalted",
    "flying_mount", "epic_flying",
}

-- Badge categories for organized display
Badges.BADGE_CATEGORIES = {
    {
        id = "progression",
        name = "Progression",
        color = "GOLD_BRIGHT",
        description = "Level milestones",
        badges = { "first_steps", "adventurer", "veteran", "hero_of_outland" },
    },
    {
        id = "attunements",
        name = "Attunements",
        color = "ARCANE_PURPLE",
        description = "Raid attunement chains",
        badges = { "karazhan_attuned", "ssc_attuned", "tk_attuned" },
    },
    {
        id = "boss_slayers",
        name = "Boss Slayers",
        color = "HELLFIRE_RED",
        description = "Major boss defeats",
        badges = { "prince_slayer", "gruul_slayer", "magtheridon_slayer", "vashj_slayer", "kael_slayer" },
    },
    {
        id = "reputation",
        name = "Reputation",
        color = "FEL_GREEN",
        description = "Faction standings",
        badges = { "exalted_first", "aldor_exalted", "scryer_exalted" },
    },
    {
        id = "special",
        name = "Special",
        color = "SKY_BLUE",
        description = "Unique achievements",
        badges = { "flying_mount", "epic_flying" },
    },
}

--============================================================
-- TBC FACTIONS LIST (for exalted check)
--============================================================
Badges.TBC_FACTIONS = {
    "Honor Hold",
    "Thrallmar",
    "Cenarion Expedition",
    "The Sha'tar",
    "Lower City",
    "The Aldor",
    "The Scryers",
    "Keepers of Time",
    "The Scale of the Sands",
    "The Violet Eye",
    "Ashtongue Deathsworn",
    "Netherwing",
    "Ogri'la",
    "Sha'tari Skyguard",
    "Sporeggar",
    "Kurenai",
    "The Mag'har",
    "The Consortium",
}

--============================================================
-- BADGE CHECKING FUNCTIONS
--============================================================

--[[
    Check if a specific badge is unlocked
    @param badgeId string - Badge identifier
    @return boolean
]]
function Badges:IsBadgeUnlocked(badgeId)
    local travelers = HopeAddon.charDb.travelers
    if not travelers.badges then return false end
    return travelers.badges[badgeId] and travelers.badges[badgeId].unlocked
end

--[[
    Unlock a badge
    @param badgeId string - Badge identifier
    @return boolean - True if newly unlocked, false if already had it
]]
function Badges:UnlockBadge(badgeId)
    local def = self.DEFINITIONS[badgeId]
    if not def then return false end

    local travelers = HopeAddon.charDb.travelers
    travelers.badges = travelers.badges or {}
    if travelers.badges[badgeId] and travelers.badges[badgeId].unlocked then
        return false -- Already unlocked
    end

    travelers.badges[badgeId] = {
        unlocked = true,
        date = HopeAddon:GetDate(),
    }

    -- Notify player
    HopeAddon:Print("Badge unlocked: |cFFFFD700" .. def.name .. "|r - " .. def.description)

    -- Fire notification through Journal if available
    local Journal = HopeAddon:GetModule("Journal")
    if Journal and Journal.ShowNotification then
        Journal:ShowNotification({
            title = "Badge Unlocked!",
            lines = {
                def.name,
                def.description,
            },
            icon = "Interface\\Icons\\" .. def.icon,
        })
    end

    return true
end

--[[
    Check all badge conditions and unlock any that are met
]]
function Badges:CheckAllUnlocks()
    for badgeId, def in pairs(self.DEFINITIONS) do
        if not self:IsBadgeUnlocked(badgeId) then
            if self:CheckUnlockCondition(def.unlock) then
                self:UnlockBadge(badgeId)
            end
        end
    end
end

--[[
    Check a specific unlock condition
    @param condition table - { type, value }
    @return boolean
]]
function Badges:CheckUnlockCondition(condition)
    if not condition then return false end

    local condType = condition.type
    local condValue = condition.value

    if condType == "level" then
        return UnitLevel("player") >= condValue

    elseif condType == "attunement" then
        -- Check attunement completion
        local attunements = HopeAddon.charDb.attunements
        return attunements[condValue] and attunements[condValue].completed

    elseif condType == "boss" then
        -- Check boss kills
        local bossKills = HopeAddon.charDb.journal.bossKills
        return bossKills[condValue] ~= nil

    elseif condType == "reputation" then
        if condValue == "any_exalted" then
            return self:HasAnyTBCExalted()
        else
            return self:HasFactionExalted(condValue)
        end

    elseif condType == "spell" then
        return IsSpellKnown(condValue)
    end

    return false
end

--[[
    Check if player has any TBC faction at Exalted
    @return boolean
]]
function Badges:HasAnyTBCExalted()
    for _, factionName in ipairs(self.TBC_FACTIONS) do
        if self:HasFactionExalted(factionName) then
            return true
        end
    end
    return false
end

--[[
    Check if player has a specific faction at Exalted
    @param factionName string
    @return boolean
]]
function Badges:HasFactionExalted(factionName)
    for i = 1, GetNumFactions() do
        local name, _, standingId = GetFactionInfo(i)
        if name == factionName and standingId == 8 then  -- 8 = Exalted
            return true
        end
    end
    return false
end

--============================================================
-- REWARD GETTERS
--============================================================

--[[
    Get all unlocked color options
    @return table - Array of { colorHex, colorName, badgeId }
]]
function Badges:GetUnlockedColors()
    local colors = {}
    local travelers = HopeAddon.charDb.travelers
    if not travelers.badges then return colors end

    for badgeId, badgeData in pairs(travelers.badges) do
        if badgeData.unlocked then
            local def = self.DEFINITIONS[badgeId]
            if def and def.reward and def.reward.colorHex then
                table.insert(colors, {
                    colorHex = def.reward.colorHex,
                    colorName = def.reward.colorName or def.name,
                    badgeId = badgeId,
                    badgeName = def.name,
                })
            end
        end
    end

    return colors
end

--[[
    Get all unlocked titles
    @return table - Array of { title, badgeId }
]]
function Badges:GetUnlockedTitles()
    local titles = {}
    local travelers = HopeAddon.charDb.travelers
    if not travelers.badges then return titles end

    for badgeId, badgeData in pairs(travelers.badges) do
        if badgeData.unlocked then
            local def = self.DEFINITIONS[badgeId]
            if def and def.reward and def.reward.title then
                table.insert(titles, {
                    title = def.reward.title,
                    badgeId = badgeId,
                    badgeName = def.name,
                })
            end
        end
    end

    return titles
end

--[[
    Get the player's selected display color
    @return string|nil - Hex color or nil for default
]]
function Badges:GetSelectedColor()
    local profile = HopeAddon.charDb.travelers.myProfile
    if profile.selectedColor then
        -- Verify it's still unlocked
        for _, colorData in ipairs(self:GetUnlockedColors()) do
            if colorData.colorHex == profile.selectedColor then
                return profile.selectedColor
            end
        end
    end
    return nil
end

--[[
    Get the player's selected title
    @return string|nil
]]
function Badges:GetSelectedTitle()
    local profile = HopeAddon.charDb.travelers.myProfile
    if profile.selectedTitle then
        -- Verify it's still unlocked
        for _, titleData in ipairs(self:GetUnlockedTitles()) do
            if titleData.title == profile.selectedTitle then
                return profile.selectedTitle
            end
        end
    end
    return nil
end

--[[
    Get the color for a specific title
    @param title string - The title to look up
    @return string - Hex color code (without |cFF prefix), defaults to FFFFFF
]]
function Badges:GetTitleColor(title)
    if not title or title == "" then
        return "FFFFFF"
    end

    for badgeId, def in pairs(self.DEFINITIONS) do
        if def.reward and def.reward.title == title then
            return def.reward.colorHex or "FFFFFF"
        end
    end
    return "FFFFFF" -- Default white
end

--[[
    Format a name with title in the badge's color
    @param name string - Player name
    @param title string|nil - Optional title
    @return string - Formatted name string with color codes
]]
function Badges:FormatNameWithTitle(name, title)
    if title and title ~= "" then
        local titleColor = self:GetTitleColor(title)
        return string.format("%s |cFF%s<%s>|r", name, titleColor, title)
    end
    return name
end

--[[
    Get badge definition by ID
    @param badgeId string
    @return table|nil
]]
function Badges:GetBadgeDefinition(badgeId)
    return self.DEFINITIONS[badgeId]
end

--[[
    Get all badges with their unlock status
    @return table - Array in display order
]]
function Badges:GetAllBadgesWithStatus()
    local result = {}
    local travelers = HopeAddon.charDb.travelers
    local badges = travelers.badges or {}

    for _, badgeId in ipairs(self.DISPLAY_ORDER) do
        local def = self.DEFINITIONS[badgeId]
        if def then
            local badgeData = badges[badgeId]
            table.insert(result, {
                id = badgeId,
                definition = def,
                unlocked = badgeData and badgeData.unlocked or false,
                unlockDate = badgeData and badgeData.date or nil,
            })
        end
    end

    return result
end

--[[
    Get badges organized by category with status info
    @return table - Array of { category, badges, earnedCount, totalCount }
]]
function Badges:GetBadgesByCategory()
    local result = {}
    local travelers = HopeAddon.charDb.travelers
    local badgesData = travelers.badges or {}

    for _, category in ipairs(self.BADGE_CATEGORIES) do
        local categoryBadges = {}
        local earnedCount = 0

        for _, badgeId in ipairs(category.badges) do
            local def = self.DEFINITIONS[badgeId]
            if def then
                local badgeData = badgesData[badgeId]
                local isUnlocked = badgeData and badgeData.unlocked or false

                table.insert(categoryBadges, {
                    id = badgeId,
                    definition = def,
                    unlocked = isUnlocked,
                    unlockDate = badgeData and badgeData.date or nil,
                })

                if isUnlocked then
                    earnedCount = earnedCount + 1
                end
            end
        end

        table.insert(result, {
            category = category,
            badges = categoryBadges,
            earnedCount = earnedCount,
            totalCount = #category.badges,
        })
    end

    return result
end

--============================================================
-- EVENT HOOKS (called from other modules)
--============================================================

--[[
    Called when player levels up
    @param newLevel number
]]
function Badges:OnPlayerLevelUp(newLevel)
    self:CheckAllUnlocks()
end

--[[
    Called when an attunement is completed
    @param attunementKey string
]]
function Badges:OnAttunementCompleted(attunementKey)
    self:CheckAllUnlocks()
end

--[[
    Called when a boss is killed
    @param bossName string
]]
function Badges:OnBossKilled(bossName)
    self:CheckAllUnlocks()
end

--[[
    Called when reputation changes
    @param factionName string
    @param newStanding number
]]
function Badges:OnReputationChanged(factionName, newStanding)
    self:CheckAllUnlocks()
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function Badges:OnInitialize()
    -- Initialize badges table if needed
    if HopeAddon.charDb and HopeAddon.charDb.travelers then
        if not HopeAddon.charDb.travelers.badges then
            HopeAddon.charDb.travelers.badges = {}
        end
    end
end

function Badges:OnEnable()
    -- Check for any badges that should be unlocked on enable
    if HopeAddon.charDb and HopeAddon.charDb.travelers then
        self:CheckAllUnlocks()
    end
    HopeAddon:Debug("Badges module enabled")
end

function Badges:OnDisable()
    -- Cleanup if needed
end

--============================================================
-- BOSS BADGE SYSTEM
-- Track individual boss kills with tier progression
--============================================================

--[[
    Get boss kill data for all tracked bosses
    @return table - Dictionary of [bossKey] = { kills, firstKill, tier }
]]
function Badges:GetBossKillData()
    local kills = HopeAddon.charDb.journal.bossKills or {}
    local result = {}

    for key, killData in pairs(kills) do
        local badge = HopeAddon.Constants.BOSS_BADGES[killData.bossId]
        if badge then
            local tier = HopeAddon.Constants:GetBossTier(killData.totalKills)
            result[killData.bossId] = {
                kills = killData.totalKills,
                firstKill = killData.firstKill,
                lastKill = killData.lastKill,
                tier = tier,
                badge = badge,
            }
        end
    end

    return result
end

--[[
    Get boss kill data for a specific boss
    @param bossId string - The boss identifier
    @return table|nil - Kill data with tier info
]]
function Badges:GetBossKill(bossId)
    local kills = HopeAddon.charDb.journal.bossKills or {}
    local key = nil

    -- Find the kill record for this boss
    for k, killData in pairs(kills) do
        if killData.bossId == bossId then
            local tier = HopeAddon.Constants:GetBossTier(killData.totalKills)
            local badge = HopeAddon.Constants.BOSS_BADGES[bossId]
            return {
                kills = killData.totalKills,
                firstKill = killData.firstKill,
                lastKill = killData.lastKill,
                tier = tier,
                badge = badge,
            }
        end
    end

    return nil
end

--[[
    Get the player's highest tier color based on all boss kills
    Returns the highest quality color achieved on any boss
    @return table|nil - { colorHex, quality, name } or nil if no kills
]]
function Badges:GetHighestBossTier()
    local kills = HopeAddon.charDb.journal.bossKills or {}
    local highestKillCount = 0

    -- Find highest kill count across all bosses
    for _, killData in pairs(kills) do
        if killData.totalKills and killData.totalKills > highestKillCount then
            highestKillCount = killData.totalKills
        end
    end

    if highestKillCount == 0 then
        return nil
    end

    return HopeAddon.Constants:GetBossTier(highestKillCount)
end

--[[
    Get the tier color for display (name color in chat/UI)
    If player has selected a badge color, uses that; otherwise uses highest boss tier
    @return string - Hex color code (without |c prefix)
]]
function Badges:GetDisplayColor()
    -- Check for badge-selected color first
    local selectedColor = self:GetSelectedColor()
    if selectedColor then
        return selectedColor
    end

    -- Fall back to highest boss tier color
    local highestTier = self:GetHighestBossTier()
    if highestTier then
        return highestTier.colorHex
    end

    -- Default to white if no kills
    return "FFFFFF"
end

--[[
    Get all boss badges organized by tier
    @return table - { T4 = {badges}, T5 = {badges}, T6 = {badges} }
]]
function Badges:GetBossBadgesByTier()
    local kills = HopeAddon.charDb.journal.bossKills or {}
    local C = HopeAddon.Constants

    local result = {
        T4 = {},
        T5 = {},
        T6 = {},
    }

    -- Build lookup table for kills by bossId (O(n) instead of O(n*m))
    local killsByBossId = {}
    for _, kd in pairs(kills) do
        if kd.bossId then
            killsByBossId[kd.bossId] = kd
        end
    end

    -- Now iterate badges and lookup kills directly
    for bossKey, badge in pairs(C.BOSS_BADGES) do
        local killData = killsByBossId[badge.bossId]

        local entry = {
            badge = badge,
            kills = killData and killData.totalKills or 0,
            firstKill = killData and killData.firstKill or nil,
            tier = killData and C:GetBossTier(killData.totalKills) or nil,
        }

        table.insert(result[badge.tier], entry)
    end

    return result
end

--[[
    Get total boss kill statistics
    @return table - { totalBosses, totalKills, highestTier, tierBreakdown }
]]
function Badges:GetBossStats()
    local kills = HopeAddon.charDb.journal.bossKills or {}
    local C = HopeAddon.Constants

    local stats = {
        totalBosses = 0,
        totalKills = 0,
        highestTier = nil,
        tierBreakdown = {
            POOR = 0,
            COMMON = 0,
            UNCOMMON = 0,
            RARE = 0,
            EPIC = 0,
            LEGENDARY = 0,
        },
        byRaid = {},
    }

    for _, killData in pairs(kills) do
        stats.totalBosses = stats.totalBosses + 1
        stats.totalKills = stats.totalKills + killData.totalKills

        local tier = C:GetBossTier(killData.totalKills)
        if tier then
            stats.tierBreakdown[tier.quality] = (stats.tierBreakdown[tier.quality] or 0) + 1
        end

        -- Track by raid
        local raid = killData.raidKey
        if not stats.byRaid[raid] then
            stats.byRaid[raid] = { bosses = 0, kills = 0 }
        end
        stats.byRaid[raid].bosses = stats.byRaid[raid].bosses + 1
        stats.byRaid[raid].kills = stats.byRaid[raid].kills + killData.totalKills
    end

    stats.highestTier = self:GetHighestBossTier()

    return stats
end

--[[
    Check if a boss badge should be unlocked
    Called when a boss is killed
    @param raidKey string - The raid identifier
    @param bossId string - The boss identifier
]]
function Badges:OnBossKillForBadge(raidKey, bossId)
    -- Boss badges are automatically tracked via RaidData
    -- This hook is for any additional badge logic

    -- Check if this boss kill unlocks any related badges
    self:CheckAllUnlocks()
end

-- Register with addon
HopeAddon:RegisterModule("Badges", Badges)
HopeAddon:Debug("Badges module loaded")
