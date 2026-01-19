--[[
    HopeAddon TravelerIcons Module
    Earnable achievement icons for shared accomplishments with fellow travelers
]]

local TravelerIcons = {}
HopeAddon.TravelerIcons = TravelerIcons

--============================================================
-- CONSTANTS
--============================================================
local OUTLAND_ZONES = {
    "Hellfire Peninsula",
    "Zangarmarsh",
    "Terokkar Forest",
    "Nagrand",
    "Blade's Edge Mountains",
    "Netherstorm",
    "Shadowmoon Valley",
    "Shattrath City",
}

-- Raid tier mappings
local RAID_TIERS = {
    karazhan = "T4",
    gruul = "T4",
    magtheridon = "T4",
    ssc = "T5",
    tk = "T5",
    hyjal = "T6",
    bt = "T6",
}

--============================================================
-- MODULE LIFECYCLE
--============================================================

function TravelerIcons:OnInitialize()
    -- Nothing to initialize yet
end

function TravelerIcons:OnEnable()
    HopeAddon:Debug("TravelerIcons module enabled")
end

function TravelerIcons:OnDisable()
    -- Cleanup if needed
end

--============================================================
-- ICON MANAGEMENT
--============================================================

--[[
    Award an icon to a traveler
    @param travelerName string - Name of the traveler
    @param iconId string - Icon identifier
    @param context table - Optional context data (date, zone, etc.)
    @return boolean - True if newly awarded, false if already had
]]
function TravelerIcons:AwardIcon(travelerName, iconId, context)
    if not travelerName or not iconId then return false end

    local iconData = HopeAddon.Constants:GetTravelerIcon(iconId)
    if not iconData then
        HopeAddon:Debug("Unknown icon:", iconId)
        return false
    end

    -- Get or create traveler entry
    local travelers = HopeAddon.charDb.travelers.known
    if not travelers[travelerName] then
        HopeAddon:Debug("Traveler not found:", travelerName)
        return false
    end

    -- Ensure icons table exists
    if not travelers[travelerName].icons then
        travelers[travelerName].icons = {}
    end

    -- Check if already earned
    if travelers[travelerName].icons[iconId] then
        HopeAddon:Debug("Icon already earned:", iconId, "for", travelerName)
        return false
    end

    -- Award the icon
    travelers[travelerName].icons[iconId] = {
        earnedDate = HopeAddon:GetDate(),
        earnedTimestamp = HopeAddon:GetTimestamp(),
        context = context or {},
    }

    HopeAddon:Debug("Awarded icon:", iconId, "to", travelerName)

    -- Show notification
    self:ShowIconNotification(travelerName, iconData)

    return true
end

--[[
    Check if a traveler has an icon
    @param travelerName string
    @param iconId string
    @return boolean
]]
function TravelerIcons:HasIcon(travelerName, iconId)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.icons then
        return false
    end

    return traveler.icons[iconId] ~= nil
end

--[[
    Get all icons for a traveler
    @param travelerName string
    @return table - Array of icon data sorted by quality (highest first)
]]
function TravelerIcons:GetIcons(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.icons then
        return {}
    end

    local icons = {}
    for iconId, earnedData in pairs(traveler.icons) do
        local iconData = HopeAddon.Constants:GetTravelerIcon(iconId)
        if iconData then
            table.insert(icons, {
                id = iconId,
                data = iconData,
                earned = earnedData,
            })
        end
    end

    -- Sort by quality (descending), then by name
    table.sort(icons, function(a, b)
        local qualityA = HopeAddon.Constants:GetQualityOrder(a.data.quality)
        local qualityB = HopeAddon.Constants:GetQualityOrder(b.data.quality)
        if qualityA ~= qualityB then
            return qualityA > qualityB
        end
        return a.data.name < b.data.name
    end)

    return icons
end

--[[
    Get icon count for a traveler
    @param travelerName string
    @return number
]]
function TravelerIcons:GetIconCount(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.icons then
        return 0
    end

    local count = 0
    for _ in pairs(traveler.icons) do
        count = count + 1
    end
    return count
end

--[[
    Get the highest quality icon for a traveler
    @param travelerName string
    @return table|nil - Icon data or nil
]]
function TravelerIcons:GetHighestQualityIcon(travelerName)
    local icons = self:GetIcons(travelerName)
    return icons[1] -- Already sorted by quality descending
end

--============================================================
-- TRIGGER HANDLERS
--============================================================

--[[
    Handle boss kill event - award relevant icons
    @param raidKey string - Raid identifier (karazhan, gruul, etc.)
    @param bossId string - Boss identifier
    @param partyMembers table - Array of party member data
]]
function TravelerIcons:OnBossKill(raidKey, bossId, partyMembers)
    if not partyMembers or #partyMembers == 0 then return end

    HopeAddon:Debug("TravelerIcons:OnBossKill", raidKey, bossId, "#party:", #partyMembers)

    local tier = RAID_TIERS[raidKey]
    local context = {
        raid = raidKey,
        boss = bossId,
        zone = GetZoneText(),
    }

    for _, member in ipairs(partyMembers) do
        local name = member.name

        -- Update stats
        self:IncrementBossKillsTogether(name)
        self:IncrementTierKills(name, tier)

        -- Check for specific boss icons
        self:CheckBossIcons(name, raidKey, bossId, context)

        -- Check for tier first kill icons
        self:CheckTierIcons(name, tier, context)

        -- Check for social milestone icons
        self:CheckSocialMilestones(name)
    end
end

--[[
    Handle zone discovery event - award relevant icons
    @param zoneName string - Zone name
    @param partyMembers table - Array of party member data
]]
function TravelerIcons:OnZoneDiscovery(zoneName, partyMembers)
    if not partyMembers or #partyMembers == 0 then return end

    HopeAddon:Debug("TravelerIcons:OnZoneDiscovery", zoneName, "#party:", #partyMembers)

    local context = {
        zone = zoneName,
    }

    for _, member in ipairs(partyMembers) do
        local name = member.name

        -- Record zone visited together
        self:RecordZoneVisitedTogether(name, zoneName)

        -- Check for zone-specific icons
        self:CheckZoneIcons(name, zoneName, context)

        -- Check for all-zones icon
        self:CheckAllZonesIcon(name, context)
    end
end

--[[
    Handle group formed/joined - award first group icon
    @param partyMembers table
]]
function TravelerIcons:OnGroupFormed(partyMembers)
    if not partyMembers or #partyMembers == 0 then return end

    local context = {
        zone = GetZoneText(),
    }

    for _, member in ipairs(partyMembers) do
        local name = member.name

        -- Check for first group icon
        local travelers = HopeAddon.charDb.travelers.known
        local traveler = travelers[name]

        if traveler then
            -- Ensure stats exist
            if not traveler.stats then
                traveler.stats = {
                    groupCount = 0,
                    bossKillsTogether = 0,
                    zonesVisitedTogether = {},
                }
            end

            -- Award first_friends on first group
            if traveler.stats.groupCount == 1 then
                self:AwardIcon(name, "first_friends", context)
            end

            -- Check group count milestones
            self:CheckGroupCountIcons(name)
        end
    end
end

--============================================================
-- ICON CHECK FUNCTIONS
--============================================================

--[[
    Check and award boss-specific icons
]]
function TravelerIcons:CheckBossIcons(travelerName, raidKey, bossId, context)
    local bossIcons = HopeAddon.Constants:GetIconsByTrigger("boss")

    for _, iconData in ipairs(bossIcons) do
        if iconData.trigger.raid == raidKey and iconData.trigger.boss == bossId then
            self:AwardIcon(travelerName, iconData.id, context)
        end
    end
end

--[[
    Check and award tier first-kill icons
]]
function TravelerIcons:CheckTierIcons(travelerName, tier, context)
    if not tier then return end

    local tierIcons = HopeAddon.Constants:GetIconsByTrigger("boss_tier")

    for _, iconData in ipairs(tierIcons) do
        if iconData.trigger.tier == tier then
            -- Check if this is the first boss of this tier together
            local travelers = HopeAddon.charDb.travelers.known
            local traveler = travelers[travelerName]

            if traveler and traveler.stats then
                local tierKills = traveler.stats["tierKills_" .. tier] or 0

                if tierKills >= iconData.trigger.count then
                    self:AwardIcon(travelerName, iconData.id, context)
                end
            end
        end
    end
end

--[[
    Check and award zone exploration icons
]]
function TravelerIcons:CheckZoneIcons(travelerName, zoneName, context)
    local zoneIcons = HopeAddon.Constants:GetIconsByTrigger("zone")

    for _, iconData in ipairs(zoneIcons) do
        if iconData.trigger.zone == zoneName then
            self:AwardIcon(travelerName, iconData.id, context)
        end
    end
end

--[[
    Check if all Outland zones have been visited together
]]
function TravelerIcons:CheckAllZonesIcon(travelerName, context)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.stats or not traveler.stats.zonesVisitedTogether then
        return
    end

    local allVisited = true
    for _, zone in ipairs(OUTLAND_ZONES) do
        if not traveler.stats.zonesVisitedTogether[zone] then
            allVisited = false
            break
        end
    end

    if allVisited then
        self:AwardIcon(travelerName, "outland_explorers", context)
    end
end

--[[
    Check and award social milestone icons
]]
function TravelerIcons:CheckSocialMilestones(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.stats then return end

    local bossKills = traveler.stats.bossKillsTogether or 0
    local context = { bossKills = bossKills }

    -- Battle Brothers (50 kills)
    if bossKills >= 50 then
        self:AwardIcon(travelerName, "battle_brothers", context)
    end

    -- Veteran's Bond (100 kills)
    if bossKills >= 100 then
        self:AwardIcon(travelerName, "veterans_bond", context)
    end
end

--[[
    Check and award group count icons
]]
function TravelerIcons:CheckGroupCountIcons(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.stats then return end

    local groupCount = traveler.stats.groupCount or 0
    local context = { groupCount = groupCount }

    -- Frequent Allies (10 groups)
    if groupCount >= 10 then
        self:AwardIcon(travelerName, "frequent_allies", context)
    end

    -- Trusted Companions (50 groups)
    if groupCount >= 50 then
        self:AwardIcon(travelerName, "trusted_companions", context)
    end
end

--============================================================
-- STAT TRACKING
--============================================================

--[[
    Increment boss kills together counter
]]
function TravelerIcons:IncrementBossKillsTogether(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler then return end

    if not traveler.stats then
        traveler.stats = {
            groupCount = 0,
            bossKillsTogether = 0,
            zonesVisitedTogether = {},
        }
    end

    traveler.stats.bossKillsTogether = (traveler.stats.bossKillsTogether or 0) + 1

    HopeAddon:Debug("Boss kills together with", travelerName, ":", traveler.stats.bossKillsTogether)
end

--[[
    Increment tier kill counter
]]
function TravelerIcons:IncrementTierKills(travelerName, tier)
    if not tier then return end

    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler then return end

    if not traveler.stats then
        traveler.stats = {
            groupCount = 0,
            bossKillsTogether = 0,
            zonesVisitedTogether = {},
        }
    end

    local key = "tierKills_" .. tier
    traveler.stats[key] = (traveler.stats[key] or 0) + 1
end

--[[
    Record a zone visited together
]]
function TravelerIcons:RecordZoneVisitedTogether(travelerName, zoneName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler then return end

    if not traveler.stats then
        traveler.stats = {
            groupCount = 0,
            bossKillsTogether = 0,
            zonesVisitedTogether = {},
        }
    end

    if not traveler.stats.zonesVisitedTogether then
        traveler.stats.zonesVisitedTogether = {}
    end

    if not traveler.stats.zonesVisitedTogether[zoneName] then
        traveler.stats.zonesVisitedTogether[zoneName] = HopeAddon:GetDate()
        HopeAddon:Debug("Recorded zone visit together:", zoneName, "with", travelerName)
    end
end

--[[
    Get traveler statistics
    @param travelerName string
    @return table
]]
function TravelerIcons:GetTravelerStats(travelerName)
    local travelers = HopeAddon.charDb.travelers.known
    local traveler = travelers[travelerName]

    if not traveler or not traveler.stats then
        return {
            groupCount = 0,
            bossKillsTogether = 0,
            zonesVisitedTogether = {},
        }
    end

    return traveler.stats
end

--============================================================
-- NOTIFICATIONS
--============================================================

--[[
    Show icon earned notification
]]
function TravelerIcons:ShowIconNotification(travelerName, iconData)
    if not HopeAddon.db or not HopeAddon.db.settings.notificationsEnabled then
        return
    end

    -- Get quality color
    local qualityColor = HopeAddon.colors[iconData.quality]
    local colorHex = qualityColor and qualityColor.hex or "FFFFFF"

    -- Print notification
    HopeAddon:Print(string.format(
        "Icon Earned with |cFFFFFFFF%s|r: |cFF%s[%s]|r - %s",
        travelerName,
        colorHex,
        iconData.name,
        iconData.description
    ))

    -- Play sound
    if HopeAddon.Sounds and HopeAddon.Sounds.PlayAchievement then
        HopeAddon.Sounds:PlayAchievement()
    else
        HopeAddon:PlaySound("ACHIEVEMENT")
    end
end

--============================================================
-- ATTUNEMENT INTEGRATION
--============================================================

--[[
    Check for attunement-based icons
    Called when attunement status is checked/updated
    @param travelerName string
]]
function TravelerIcons:CheckAttunementIcons(travelerName)
    -- This would need to check if both players have completed an attunement
    -- For now, we'll need attunement data from both players
    -- This is a placeholder for future addon-to-addon communication
    HopeAddon:Debug("CheckAttunementIcons for", travelerName, "- requires addon communication")
end

--============================================================
-- UTILITY FUNCTIONS
--============================================================

--[[
    Get icons grouped by category
    @param travelerName string
    @return table - { [category] = { icons... } }
]]
function TravelerIcons:GetIconsByCategory(travelerName)
    local icons = self:GetIcons(travelerName)
    local byCategory = {}

    for _, icon in ipairs(icons) do
        local category = icon.data.category or "other"
        if not byCategory[category] then
            byCategory[category] = {}
        end
        table.insert(byCategory[category], icon)
    end

    return byCategory
end

--[[
    Get all travelers with icons
    @return table - Array of traveler names with icon counts
]]
function TravelerIcons:GetTravelersWithIcons()
    local result = {}
    local travelers = HopeAddon.charDb.travelers.known

    for name, traveler in pairs(travelers) do
        if traveler.icons then
            local count = 0
            for _ in pairs(traveler.icons) do
                count = count + 1
            end
            if count > 0 then
                table.insert(result, {
                    name = name,
                    iconCount = count,
                    class = traveler.class,
                    level = traveler.level,
                })
            end
        end
    end

    -- Sort by icon count descending
    table.sort(result, function(a, b)
        return a.iconCount > b.iconCount
    end)

    return result
end

-- Register with addon
HopeAddon:RegisterModule("TravelerIcons", TravelerIcons)
HopeAddon:Debug("TravelerIcons module loaded")
