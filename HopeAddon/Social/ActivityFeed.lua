--[[
    HopeAddon ActivityFeed Module
    "Tavern Notice Board" - Activity feed showing recent events from Fellow Travelers

    Phase 1: Auto-populated activity feed from existing events
    Phase 2: Rumors (manual posts) + Mugs (reactions)

    Wire format: ACT:version:type:player:data (~20-50 bytes per activity)
    Storage: charDb.social.feed (max 50 entries, 48-hour retention)
]]

local ActivityFeed = {}
HopeAddon.ActivityFeed = ActivityFeed
HopeAddon:RegisterModule("ActivityFeed", ActivityFeed)

--============================================================
-- CONSTANTS
--============================================================

local PROTOCOL_VERSION = 1
local MSG_PREFIX = "ACT"

-- Activity types
local ACTIVITY = {
    STATUS = "STA",       -- RP status change (IC/OOC/LF_RP)
    BOSS = "BOSS",        -- Boss kill
    LEVEL = "LVL",        -- Level up
    GAME = "GAME",        -- Game win/loss
    BADGE = "BADGE",      -- Badge earned
    RUMOR = "RUM",        -- Manual status post (Phase 2)
    MUG = "MUG",          -- Mug reaction (Phase 2)
}

-- Activity icons (Interface\Icons\ prefix)
local ACTIVITY_ICONS = {
    [ACTIVITY.STATUS] = "Spell_Shadow_MindTwisting",  -- RP mask
    [ACTIVITY.BOSS] = "Achievement_Boss_Prince_Malchezaar",
    [ACTIVITY.LEVEL] = "Achievement_Level_70",
    [ACTIVITY.GAME] = "INV_Misc_Dice_02",
    [ACTIVITY.BADGE] = "Achievement_General",
    [ACTIVITY.RUMOR] = "INV_Scroll_03",
    [ACTIVITY.MUG] = "INV_Drink_10",
}

-- Activity display names
local ACTIVITY_NAMES = {
    [ACTIVITY.STATUS] = "Status",
    [ACTIVITY.BOSS] = "Boss Kill",
    [ACTIVITY.LEVEL] = "Level Up",
    [ACTIVITY.GAME] = "Game",
    [ACTIVITY.BADGE] = "Badge",
    [ACTIVITY.RUMOR] = "Rumor",
    [ACTIVITY.MUG] = "Raise a Mug",
}

-- Status display strings
local STATUS_DISPLAY = {
    IC = "|cFF00FF00In Character|r",
    OOC = "|cFF808080Out of Character|r",
    LF_RP = "|cFFFFD700Looking for RP|r",
}

-- Feed limits
local MAX_FEED_ENTRIES = 50
local FEED_RETENTION_HOURS = 48
local FEED_RETENTION_SECONDS = FEED_RETENTION_HOURS * 3600

-- Broadcast settings
local BROADCAST_BATCH_SIZE = 3  -- Max activities per broadcast
local BROADCAST_COOLDOWN = 30   -- Seconds between activity broadcasts (separate from FellowTravelers)

-- Phase 2: Rumors & Mugs
local RUMOR_MAX_LENGTH = 100
local RUMOR_COOLDOWN = 300  -- 5 minutes between rumors
local RUMOR_EXPIRY_HOURS = 24
local MUG_ICON = "Interface\\Icons\\INV_Drink_10"

--============================================================
-- MODULE STATE
--============================================================

ActivityFeed.lastBroadcast = 0
ActivityFeed.pendingActivities = {}  -- Queue of activities to broadcast
ActivityFeed.eventFrame = nil
ActivityFeed.cleanupTicker = nil
ActivityFeed.lastRumorTime = 0  -- Phase 2: Rate limit rumors

--============================================================
-- DATA HELPERS
--============================================================

--[[
    Generate unique activity ID
    @return string - Unique ID for activity
]]
local function GenerateActivityId()
    return string.format("%s_%d_%d", UnitName("player"), time(), math.random(1000, 9999))
end

--[[
    Get social data table (creates if needed)
    @return table - charDb.social
]]
local function GetSocialData()
    if not HopeAddon.charDb then return nil end

    if not HopeAddon.charDb.social then
        HopeAddon.charDb.social = {
            feed = {},
            lastSeen = {},
            settings = {
                showBoss = true,
                showLevel = true,
                showGame = true,
                showBadge = true,
                showStatus = true,
            },
            -- Phase 2
            myRumors = {},
            mugsGiven = {},
        }
    end

    return HopeAddon.charDb.social
end

--[[
    Check if activity has been seen (deduplication)
    @param activityId string
    @return boolean
]]
local function HasSeenActivity(activityId)
    local social = GetSocialData()
    if not social then return true end
    return social.lastSeen[activityId] == true
end

--[[
    Mark activity as seen
    @param activityId string
]]
local function MarkActivitySeen(activityId)
    local social = GetSocialData()
    if not social then return end
    social.lastSeen[activityId] = true
end

--[[
    Clean up old activities and lastSeen entries
]]
local function CleanupOldActivities()
    local social = GetSocialData()
    if not social then return end

    local now = time()
    local cutoff = now - FEED_RETENTION_SECONDS

    -- Clean up feed
    local newFeed = {}
    for _, activity in ipairs(social.feed) do
        if activity.time and activity.time > cutoff then
            table.insert(newFeed, activity)
        end
    end
    social.feed = newFeed

    -- Clean up lastSeen (keep entries for recent activities)
    local activeIds = {}
    for _, activity in ipairs(social.feed) do
        if activity.id then
            activeIds[activity.id] = true
        end
    end

    local newLastSeen = {}
    for id, _ in pairs(social.lastSeen) do
        if activeIds[id] then
            newLastSeen[id] = true
        end
    end
    social.lastSeen = newLastSeen

    HopeAddon:Debug("ActivityFeed cleanup: ", #social.feed, "activities retained")
end

--============================================================
-- ACTIVITY CREATION
--============================================================

--[[
    Create an activity entry
    @param actType string - Activity type from ACTIVITY enum
    @param player string - Player name
    @param playerClass string - Player class
    @param data string - Activity-specific data
    @return table - Activity entry
]]
function ActivityFeed:CreateActivity(actType, player, playerClass, data)
    return {
        id = GenerateActivityId(),
        type = actType,
        player = player,
        class = playerClass or "UNKNOWN",
        data = data,
        time = time(),
        mugs = 0,  -- Phase 2: reaction count
    }
end

--[[
    Add activity to local feed
    @param activity table - Activity entry
]]
function ActivityFeed:AddToFeed(activity)
    local social = GetSocialData()
    if not social then return end

    -- Check deduplication
    if HasSeenActivity(activity.id) then
        HopeAddon:Debug("ActivityFeed: Duplicate activity ignored:", activity.id)
        return
    end

    -- Mark as seen
    MarkActivitySeen(activity.id)

    -- Add to feed (newest first)
    table.insert(social.feed, 1, activity)

    -- Trim to max size
    while #social.feed > MAX_FEED_ENTRIES do
        table.remove(social.feed)
    end

    HopeAddon:Debug("ActivityFeed: Added activity:", activity.type, "from", activity.player)
end

--[[
    Queue activity for broadcast
    @param activity table - Activity entry
]]
function ActivityFeed:QueueForBroadcast(activity)
    table.insert(self.pendingActivities, activity)
    HopeAddon:Debug("ActivityFeed: Queued for broadcast:", activity.type)
end

--============================================================
-- WIRE PROTOCOL
--============================================================

--[[
    Serialize activity for network transmission
    Format: ACT:version:type:player:class:data
    @param activity table
    @return string - Wire format message
]]
function ActivityFeed:SerializeActivity(activity)
    -- Truncate data to keep within 255 byte limit
    local data = activity.data or ""
    if #data > 100 then
        data = data:sub(1, 100)
    end

    return string.format("%s:%d:%s:%s:%s:%s:%d",
        MSG_PREFIX,
        PROTOCOL_VERSION,
        activity.type,
        activity.player,
        activity.class,
        data,
        activity.time
    )
end

--[[
    Parse activity from network message
    @param message string - Wire format message
    @return table|nil - Activity entry or nil if invalid
]]
function ActivityFeed:ParseActivity(message)
    local prefix, version, actType, player, class, data, timeStr = strsplit(":", message, 7)

    if prefix ~= MSG_PREFIX then return nil end

    local ver = tonumber(version) or 0
    if ver > PROTOCOL_VERSION then
        HopeAddon:Debug("ActivityFeed: Newer protocol version:", ver)
    end

    local timestamp = tonumber(timeStr) or time()

    return {
        id = string.format("%s_%d_%d", player, timestamp, math.random(1000, 9999)),
        type = actType,
        player = player,
        class = class or "UNKNOWN",
        data = data or "",
        time = timestamp,
        mugs = 0,
    }
end

--============================================================
-- NETWORK COMMUNICATION
--============================================================

--[[
    Register message callback with FellowTravelers
]]
function ActivityFeed:RegisterNetworkHandler()
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then
        HopeAddon:Debug("ActivityFeed: FellowTravelers not available")
        return
    end

    FellowTravelers:RegisterMessageCallback("ActivityFeed",
        function(msgType)
            return msgType == MSG_PREFIX
        end,
        function(msgType, sender, data)
            self:HandleNetworkActivity(sender, data)
        end
    )

    HopeAddon:Debug("ActivityFeed: Registered network handler")
end

--[[
    Handle incoming activity from network
    @param sender string - Sender name
    @param data string - Message data (everything after ACT:)
]]
function ActivityFeed:HandleNetworkActivity(sender, data)
    -- Reconstruct full message for parsing
    local fullMsg = MSG_PREFIX .. ":" .. data
    local activity = self:ParseActivity(fullMsg)

    if not activity then
        HopeAddon:Debug("ActivityFeed: Invalid activity from", sender)
        return
    end

    -- Verify sender matches claimed player
    if activity.player ~= sender then
        HopeAddon:Debug("ActivityFeed: Sender mismatch:", sender, "vs", activity.player)
        return
    end

    -- Special handling for MUG type (Phase 2)
    if activity.type == ACTIVITY.MUG then
        self:HandleIncomingMug(activity)
        return  -- Don't add MUG activities to the feed directly
    end

    -- Check if activity type should be shown
    local social = GetSocialData()
    if social and social.settings then
        local settingKey = "show" .. ACTIVITY_NAMES[activity.type]:gsub(" ", "")
        if social.settings[settingKey] == false then
            return
        end
    end

    -- Add to feed
    self:AddToFeed(activity)
end

--[[
    Broadcast pending activities
    Called periodically or when piggybacking on FellowTravelers broadcast
]]
function ActivityFeed:BroadcastActivities()
    if #self.pendingActivities == 0 then return end

    local now = GetTime()
    if now - self.lastBroadcast < BROADCAST_COOLDOWN then return end
    self.lastBroadcast = now

    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then return end

    -- Send up to BROADCAST_BATCH_SIZE activities
    local count = 0
    while #self.pendingActivities > 0 and count < BROADCAST_BATCH_SIZE do
        local activity = table.remove(self.pendingActivities, 1)
        local msg = self:SerializeActivity(activity)

        -- Send via FellowTravelers channels
        FellowTravelers:BroadcastMessage(msg)
        count = count + 1

        -- Also add to our own feed
        self:AddToFeed(activity)
    end

    HopeAddon:Debug("ActivityFeed: Broadcast", count, "activities")
end

--============================================================
-- EVENT HOOKS
-- Listen to existing addon events to generate activities
--============================================================

--[[
    Hook into existing events to generate activities automatically
]]
function ActivityFeed:SetupEventHooks()
    -- Create event frame
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end

    -- Hook into boss kill events via Badges callback
    -- (Badges:OnBossKilled is called from raid modules)
    local originalOnBossKilled = HopeAddon.Badges and HopeAddon.Badges.OnBossKilled
    if originalOnBossKilled then
        HopeAddon.Badges.OnBossKilled = function(badgesModule, bossName)
            -- Call original
            originalOnBossKilled(badgesModule, bossName)
            -- Generate activity
            self:OnBossKill(bossName)
        end
    end

    -- Hook into level up events via PLAYER_LEVEL_UP
    self.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

    -- Hook into RP status changes by watching profile updates
    -- (FellowTravelers:UpdateMyProfile calls happen on status change)
    local originalUpdateMyProfile = HopeAddon.FellowTravelers and HopeAddon.FellowTravelers.UpdateMyProfile
    if originalUpdateMyProfile then
        HopeAddon.FellowTravelers.UpdateMyProfile = function(ftModule, updates)
            local oldStatus = ftModule:GetMyProfile() and ftModule:GetMyProfile().status
            originalUpdateMyProfile(ftModule, updates)
            -- Check if status changed
            if updates.status and updates.status ~= oldStatus then
                self:OnStatusChange(updates.status)
            end
        end
    end

    -- Hook into GameCore for game end notifications
    local GameCore = HopeAddon.GameCore
    if GameCore then
        local originalEndGame = GameCore.EndGame
        GameCore.EndGame = function(gcModule, gameId, reason)
            -- Call original
            local game = gcModule.activeGames and gcModule.activeGames[gameId]
            originalEndGame(gcModule, gameId, reason)

            -- Generate activity if it was a win/loss
            if game and reason and (reason == "WIN" or reason == "LOSS") then
                local gameType = game.gameType
                local gameDef = HopeAddon.Constants and HopeAddon.Constants:GetGameDefinition(gameType:lower())
                local gameName = gameDef and gameDef.name or gameType
                local result = reason == "WIN" and "W" or "L"
                self:OnGameEnd(gameName, result)
            end
        end
    end

    -- Hook into badge unlocks
    local Badges = HopeAddon.Badges
    if Badges and Badges.UnlockBadge then
        local originalUnlockBadge = Badges.UnlockBadge
        Badges.UnlockBadge = function(badgeModule, badgeId)
            originalUnlockBadge(badgeModule, badgeId)
            -- Generate activity for badge unlock
            self:OnBadgeEarned(badgeId)
        end
    end

    -- Set up event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            local newLevel = ...
            self:OnLevelUp(newLevel)
        end
    end)

    HopeAddon:Debug("ActivityFeed: Event hooks set up")
end

--[[
    Called when player kills a boss
    @param bossName string
]]
function ActivityFeed:OnBossKill(bossName)
    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.BOSS,
        UnitName("player"),
        class,
        bossName
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Boss kill activity:", bossName)
end

--[[
    Called when player levels up
    @param newLevel number
]]
function ActivityFeed:OnLevelUp(newLevel)
    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.LEVEL,
        UnitName("player"),
        class,
        tostring(newLevel)
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Level up activity:", newLevel)
end

--[[
    Called when player changes RP status
    @param newStatus string - "IC", "OOC", or "LF_RP"
]]
function ActivityFeed:OnStatusChange(newStatus)
    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.STATUS,
        UnitName("player"),
        class,
        newStatus
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Status change activity:", newStatus)
end

--[[
    Called when player wins/loses a game
    @param gameName string - Game name
    @param result string - "W" for win, "L" for loss
]]
function ActivityFeed:OnGameEnd(gameName, result)
    local _, class = UnitClass("player")
    local data = gameName .. "|" .. result
    local activity = self:CreateActivity(
        ACTIVITY.GAME,
        UnitName("player"),
        class,
        data
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Game end activity:", gameName, result)
end

--[[
    Called when player earns a badge
    @param badgeId string - Badge identifier
]]
function ActivityFeed:OnBadgeEarned(badgeId)
    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.BADGE,
        UnitName("player"),
        class,
        badgeId
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Badge earned activity:", badgeId)
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Get all feed entries
    @return table - Array of activity entries
]]
function ActivityFeed:GetFeed()
    local social = GetSocialData()
    if not social then return {} end
    return social.feed or {}
end

--[[
    Get recent feed entries (for display)
    @param maxCount number - Maximum entries to return (default 20)
    @return table - Array of activity entries
]]
function ActivityFeed:GetRecentFeed(maxCount)
    maxCount = maxCount or 20
    local feed = self:GetFeed()
    local result = {}

    for i = 1, math.min(#feed, maxCount) do
        table.insert(result, feed[i])
    end

    return result
end

--[[
    Get activity icon path
    @param actType string - Activity type
    @return string - Full icon path
]]
function ActivityFeed:GetActivityIcon(actType)
    local icon = ACTIVITY_ICONS[actType] or "INV_Misc_QuestionMark"
    return "Interface\\Icons\\" .. icon
end

--[[
    Get activity display name
    @param actType string - Activity type
    @return string - Display name
]]
function ActivityFeed:GetActivityName(actType)
    return ACTIVITY_NAMES[actType] or "Unknown"
end

--[[
    Format activity for display
    @param activity table - Activity entry
    @return string - Formatted display string
]]
function ActivityFeed:FormatActivity(activity)
    local actType = activity.type
    local player = activity.player
    local data = activity.data or ""

    if actType == ACTIVITY.STATUS then
        local statusDisplay = STATUS_DISPLAY[data] or data
        return string.format("|cFFFFD700%s|r is %s", player, statusDisplay)

    elseif actType == ACTIVITY.BOSS then
        return string.format("|cFFFF3333%s|r slew |cFFFF8000%s|r", player, data)

    elseif actType == ACTIVITY.LEVEL then
        return string.format("|cFF00FF00%s|r reached level |cFFFFD700%s|r", player, data)

    elseif actType == ACTIVITY.GAME then
        local gameName, result = strsplit("|", data, 2)
        local resultText = result == "W" and "|cFF00FF00won|r" or "|cFFFF3333lost|r"
        return string.format("|cFF9B30FF%s|r %s at |cFF00BFFF%s|r", player, resultText, gameName or "a game")

    elseif actType == ACTIVITY.BADGE then
        -- Try to get badge display name
        local badgeName = data
        if HopeAddon.Badges and HopeAddon.Badges.GetBadgeById then
            local badge = HopeAddon.Badges:GetBadgeById(data)
            if badge then
                badgeName = badge.name
            end
        end
        return string.format("|cFFA335EE%s|r earned |cFFFFD700%s|r", player, badgeName)

    elseif actType == ACTIVITY.RUMOR then
        return string.format("|cFFFFFFFF%s|r: \"%s\"", player, data)

    else
        return string.format("%s: %s", player, data)
    end
end

--[[
    Get relative time string
    @param timestamp number - Unix timestamp
    @return string - Relative time (e.g., "2m", "1h", "3d")
]]
function ActivityFeed:GetRelativeTime(timestamp)
    local now = time()
    local diff = now - timestamp

    if diff < 60 then
        return "now"
    elseif diff < 3600 then
        return string.format("%dm", math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format("%dh", math.floor(diff / 3600))
    else
        return string.format("%dd", math.floor(diff / 86400))
    end
end

--============================================================
-- PHASE 2: RUMORS
--============================================================

--[[
    Post a new rumor (manual status update)
    @param text string - Rumor text (max 100 chars)
    @return boolean - Success
]]
function ActivityFeed:PostRumor(text)
    if not text or text == "" then return false end

    -- Rate limit
    local now = GetTime()
    if now - self.lastRumorTime < RUMOR_COOLDOWN then
        local remaining = math.ceil(RUMOR_COOLDOWN - (now - self.lastRumorTime))
        HopeAddon:Print("Please wait " .. remaining .. " seconds before posting another rumor.")
        return false
    end

    -- Truncate and sanitize
    text = text:sub(1, RUMOR_MAX_LENGTH)
    text = text:gsub("|", "")  -- Remove color codes

    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.RUMOR,
        UnitName("player"),
        class,
        text
    )

    -- Store in myRumors for expiry tracking
    local social = GetSocialData()
    if social then
        social.myRumors[activity.time] = {
            text = text,
            expires = time() + (RUMOR_EXPIRY_HOURS * 3600),
        }
    end

    self:QueueForBroadcast(activity)
    self.lastRumorTime = now

    HopeAddon:Print("Rumor posted!")
    return true
end

--[[
    Check if player can post a rumor (cooldown check)
    @return boolean, number - Can post, seconds remaining
]]
function ActivityFeed:CanPostRumor()
    local now = GetTime()
    local elapsed = now - self.lastRumorTime
    if elapsed >= RUMOR_COOLDOWN then
        return true, 0
    end
    return false, math.ceil(RUMOR_COOLDOWN - elapsed)
end

--============================================================
-- PHASE 2: MUG REACTIONS
--============================================================

--[[
    Give a mug (like) to an activity
    @param activityId string - Activity ID to mug
    @return boolean - Success
]]
function ActivityFeed:GiveMug(activityId)
    local social = GetSocialData()
    if not social then return false end

    -- Check if already mugged
    if social.mugsGiven[activityId] then
        HopeAddon:Debug("Already mugged this activity")
        return false
    end

    -- Find the activity in feed
    local activity = nil
    for _, act in ipairs(social.feed) do
        if act.id == activityId then
            activity = act
            break
        end
    end

    if not activity then
        HopeAddon:Debug("Activity not found:", activityId)
        return false
    end

    -- Mark as mugged locally
    social.mugsGiven[activityId] = true
    activity.mugs = (activity.mugs or 0) + 1

    -- Broadcast mug notification
    local _, class = UnitClass("player")
    local mugActivity = self:CreateActivity(
        ACTIVITY.MUG,
        UnitName("player"),
        class,
        activityId
    )
    self:QueueForBroadcast(mugActivity)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    return true
end

--[[
    Check if player has mugged an activity
    @param activityId string
    @return boolean
]]
function ActivityFeed:HasMugged(activityId)
    local social = GetSocialData()
    return social and social.mugsGiven[activityId] == true
end

--[[
    Handle incoming MUG activity (increment counter on target activity)
    @param mugActivity table - The MUG activity
]]
function ActivityFeed:HandleIncomingMug(mugActivity)
    local targetId = mugActivity.data
    local social = GetSocialData()
    if not social then return end

    for _, act in ipairs(social.feed) do
        if act.id == targetId then
            act.mugs = (act.mugs or 0) + 1
            HopeAddon:Debug("Mug received for activity:", targetId, "total:", act.mugs)

            -- Trigger toast if it was OUR activity that got mugged
            if act.player == UnitName("player") and HopeAddon.SocialToasts then
                HopeAddon.SocialToasts:Show("mug_received", mugActivity.player)
            end
            break
        end
    end
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function ActivityFeed:OnInitialize()
    -- Ensure data structure exists
    GetSocialData()
end

function ActivityFeed:OnEnable()
    -- Register network handler
    self:RegisterNetworkHandler()

    -- Set up event hooks
    self:SetupEventHooks()

    -- Start cleanup ticker (every 30 minutes)
    self.cleanupTicker = HopeAddon.Timer:NewTicker(1800, function()
        CleanupOldActivities()
    end)

    -- Do initial cleanup
    CleanupOldActivities()

    HopeAddon:Debug("ActivityFeed module enabled")
end

function ActivityFeed:OnDisable()
    -- Unregister network handler
    if HopeAddon.FellowTravelers then
        HopeAddon.FellowTravelers:UnregisterMessageCallback("ActivityFeed")
    end

    -- Stop cleanup ticker
    if self.cleanupTicker then
        self.cleanupTicker:Cancel()
        self.cleanupTicker = nil
    end

    -- Clean up event frame
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    HopeAddon:Debug("ActivityFeed module disabled")
end

--============================================================
-- CONSTANTS EXPORT
--============================================================

ActivityFeed.ACTIVITY = ACTIVITY
ActivityFeed.STATUS_DISPLAY = STATUS_DISPLAY
