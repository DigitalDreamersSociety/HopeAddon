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
    RUMOR = "RUM",        -- Legacy manual post (treat as IC_POST)
    MUG = "MUG",          -- Mug reaction
    LOOT = "LOOT",        -- Epic loot received (opt-in share)
    ROMANCE = "ROM",      -- Romance status change (proposed, dating, breakup)
    -- New post types (Phase 50)
    IC_POST = "IC",       -- In-character post (shows name + title)
    ANON = "ANON",        -- Anonymous tavern rumor (hidden identity)
    -- Calendar events (Phase 61)
    EVENT = "EVT",        -- Calendar event created/signup
}

-- Activity icons (Interface\Icons\ prefix) - TBC 2.4.3 compatible
local ACTIVITY_ICONS = {
    [ACTIVITY.STATUS] = "Spell_Shadow_MindTwisting",  -- RP mask
    [ACTIVITY.BOSS] = "Spell_Shadow_DeathPact",       -- Boss skull
    [ACTIVITY.LEVEL] = "Spell_Holy_ChampionsBond",    -- Level up glow
    [ACTIVITY.GAME] = "INV_Misc_Dice_02",
    [ACTIVITY.BADGE] = "INV_Jewelry_Talisman_07",     -- Badge/medal
    [ACTIVITY.RUMOR] = "INV_Scroll_03",               -- Legacy (treat as IC)
    [ACTIVITY.MUG] = "INV_Drink_10",
    [ACTIVITY.LOOT] = "INV_Misc_Bag_10",             -- Loot bag
    [ACTIVITY.ROMANCE] = "INV_ValentinesCard02",     -- Romance heart
    -- New post types (Phase 50)
    [ACTIVITY.IC_POST] = "Spell_Holy_MindVision",    -- Speech/RP icon
    [ACTIVITY.ANON] = "INV_Scroll_01",               -- Anonymous scroll
    -- Calendar events (Phase 61)
    [ACTIVITY.EVENT] = "INV_Misc_Note_02",           -- Calendar/event scroll
}

-- Activity display names
local ACTIVITY_NAMES = {
    [ACTIVITY.STATUS] = "Status",
    [ACTIVITY.BOSS] = "Boss Kill",
    [ACTIVITY.LEVEL] = "Level Up",
    [ACTIVITY.GAME] = "Game",
    [ACTIVITY.BADGE] = "Badge",
    [ACTIVITY.RUMOR] = "Post",                       -- Legacy
    [ACTIVITY.MUG] = "Raise a Mug",
    [ACTIVITY.LOOT] = "Loot",
    [ACTIVITY.ROMANCE] = "Romance",
    -- New post types (Phase 50)
    [ACTIVITY.IC_POST] = "IC Post",
    [ACTIVITY.ANON] = "Tavern Rumor",
    -- Calendar events (Phase 61)
    [ACTIVITY.EVENT] = "Event",
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

-- Phase 3: Loot Sharing
local LOOT_MIN_QUALITY = 4          -- Epic+ only
local LOOT_PROMPT_EXPIRE = 300      -- 5 minutes to decide
local LOOT_PROMPT_DELAY = 3         -- Seconds after combat to show prompt
local LOOT_COMMENT_MAX = 100        -- Max comment length
local LOOT_CONTEXT_TIMEOUT = 60     -- Seconds to keep encounter context after kill
local LOOT_PATTERN = "You receive loot: (.+)"

--============================================================
-- MODULE STATE
--============================================================

ActivityFeed.lastBroadcast = 0
ActivityFeed.pendingActivities = {}  -- Queue of activities to broadcast
ActivityFeed.eventFrame = nil
ActivityFeed.cleanupTicker = nil
ActivityFeed.lastRumorTime = 0  -- Legacy: Rate limit rumors
ActivityFeed.lastPostTime = 0   -- Phase 50: Shared cooldown for IC/Anonymous posts

-- Stored original functions for hook restoration (prevents memory leaks on /reload)
ActivityFeed.originalHooks = {
    OnBossKilled = nil,
    UpdateMyProfile = nil,
    EndGame = nil,
    UnlockBadge = nil,
}
ActivityFeed.hooksInstalled = false  -- Guard against double-hooking

-- Phase 3: Loot sharing state
ActivityFeed.pendingLootPrompts = {}  -- Queue of loot share prompts
ActivityFeed.currentPromptFrame = nil -- Active prompt UI
ActivityFeed.currentEncounter = {     -- Track current encounter context
    bossName = nil,
    raidName = nil,
    dungeonName = nil,
    startTime = nil,
    clearTime = nil,                  -- Time to clear context
}

-- Listener system for UI refresh notifications
-- Allows modules (like Journal) to be notified when new activities arrive
ActivityFeed.listeners = {}

--============================================================
-- LISTENER SYSTEM
--============================================================

--[[
    Register a listener for feed updates
    @param id string - Unique identifier for the listener
    @param callback function(activityCount) - Called when new activities arrive
]]
function ActivityFeed:RegisterListener(id, callback)
    if not id or not callback then return end
    self.listeners[id] = callback
    HopeAddon:Debug("ActivityFeed: Registered listener:", id)
end

--[[
    Unregister a listener
    @param id string - Listener identifier to remove
]]
function ActivityFeed:UnregisterListener(id)
    if not id then return end
    self.listeners[id] = nil
    HopeAddon:Debug("ActivityFeed: Unregistered listener:", id)
end

--[[
    Notify all listeners of new activities
    @param count number - Number of new activities
]]
function ActivityFeed:NotifyListeners(count)
    if not count or count <= 0 then return end
    for id, callback in pairs(self.listeners) do
        local ok, err = pcall(callback, count)
        if not ok then
            HopeAddon:Debug("ActivityFeed: Listener error:", id, err)
        end
    end
end

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
                showLoot = true,        -- Phase 3: Show loot activities
                promptForLoot = true,   -- Phase 3: Prompt to share loot
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
    @param data string - Message data after "ACT:version:" (format: "type:player:class:actData:timestamp")

    Note: FellowTravelers:OnAddonMessage already strips "ACT:version:" prefix,
    so we parse the remaining payload directly instead of reconstructing.
]]
function ActivityFeed:HandleNetworkActivity(sender, data)
    -- Parse payload directly (FellowTravelers already stripped ACT:version:)
    -- Expected format: "type:player:class:actData:timestamp"
    local actType, player, class, actData, timeStr = strsplit(":", data, 5)

    if not actType or not player then
        HopeAddon:Debug("ActivityFeed: Invalid activity from", sender, "- missing fields")
        return
    end

    -- Verify sender matches claimed player (anti-spoofing)
    if player ~= sender then
        HopeAddon:Debug("ActivityFeed: Sender mismatch:", sender, "vs", player)
        return
    end

    local timestamp = tonumber(timeStr) or time()

    -- Build activity structure
    local activity = {
        id = string.format("%s_%d_%d", player, timestamp, math.random(1000, 9999)),
        type = actType,
        player = player,
        class = class or "UNKNOWN",
        data = actData or "",
        time = timestamp,
        mugs = 0,
    }

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

    -- Notify listeners of new network activity
    self:NotifyListeners(1)
end

--[[
    Broadcast pending activities
    Called periodically or when piggybacking on FellowTravelers broadcast
]]
function ActivityFeed:BroadcastActivities()
    HopeAddon:Debug("ActivityFeed: BroadcastActivities called, pending:", #self.pendingActivities)

    if #self.pendingActivities == 0 then
        return
    end

    local now = GetTime()
    if now - self.lastBroadcast < BROADCAST_COOLDOWN then
        HopeAddon:Debug("ActivityFeed: Broadcast on cooldown")
        return
    end
    self.lastBroadcast = now

    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then
        HopeAddon:Debug("ActivityFeed: No FellowTravelers module")
        return
    end

    -- Send up to BROADCAST_BATCH_SIZE activities
    local count = 0
    while #self.pendingActivities > 0 and count < BROADCAST_BATCH_SIZE do
        local activity = table.remove(self.pendingActivities, 1)
        local msg = self:SerializeActivity(activity)

        HopeAddon:Debug("ActivityFeed: Broadcasting activity:", activity.type, "from", activity.player)

        -- Send via FellowTravelers channels
        FellowTravelers:BroadcastMessage(msg)
        count = count + 1

        -- Also add to our own feed
        self:AddToFeed(activity)
    end

    -- Notify listeners that we added our own activities
    if count > 0 then
        self:NotifyListeners(count)
        HopeAddon:Debug("ActivityFeed: Broadcast", count, "activities, feed size:", #(self:GetFeed()))
    end
end

--============================================================
-- EVENT HOOKS
-- Listen to existing addon events to generate activities
--============================================================

--[[
    Hook into existing events to generate activities automatically
    Uses module-level storage for originals to enable proper restoration in OnDisable
]]
function ActivityFeed:SetupEventHooks()
    -- Guard against double-hooking (prevents stack overflow on multiple /reload)
    if self.hooksInstalled then
        HopeAddon:Debug("ActivityFeed: Hooks already installed, skipping")
        return
    end

    -- Create event frame
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end

    -- Hook into boss kill events via Badges callback
    -- (Badges:OnBossKilled is called from raid modules)
    if HopeAddon.Badges and HopeAddon.Badges.OnBossKilled then
        -- Only store original if not already stored (prevents storing our own hook)
        if not self.originalHooks.OnBossKilled then
            self.originalHooks.OnBossKilled = HopeAddon.Badges.OnBossKilled
        end
        local originalFunc = self.originalHooks.OnBossKilled
        HopeAddon.Badges.OnBossKilled = function(badgesModule, bossName)
            originalFunc(badgesModule, bossName)
            self:OnBossKill(bossName)
        end
    end

    -- Hook into level up events via PLAYER_LEVEL_UP
    self.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

    -- Register loot event for loot share prompts (Phase 3)
    self.eventFrame:RegisterEvent("CHAT_MSG_LOOT")

    -- Register combat end event for delayed loot prompts (Phase 3)
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Hook into RP status changes by watching profile updates
    -- (FellowTravelers:UpdateMyProfile calls happen on status change)
    if HopeAddon.FellowTravelers and HopeAddon.FellowTravelers.UpdateMyProfile then
        if not self.originalHooks.UpdateMyProfile then
            self.originalHooks.UpdateMyProfile = HopeAddon.FellowTravelers.UpdateMyProfile
        end
        local originalFunc = self.originalHooks.UpdateMyProfile
        HopeAddon.FellowTravelers.UpdateMyProfile = function(ftModule, updates)
            local oldStatus = ftModule:GetMyProfile() and ftModule:GetMyProfile().status
            originalFunc(ftModule, updates)
            if updates.status and updates.status ~= oldStatus then
                self:OnStatusChange(updates.status)
            end
        end
    end

    -- Hook into GameCore for game end notifications
    if HopeAddon.GameCore and HopeAddon.GameCore.EndGame then
        if not self.originalHooks.EndGame then
            self.originalHooks.EndGame = HopeAddon.GameCore.EndGame
        end
        local originalFunc = self.originalHooks.EndGame
        HopeAddon.GameCore.EndGame = function(gcModule, gameId, reason)
            local game = gcModule.activeGames and gcModule.activeGames[gameId]
            originalFunc(gcModule, gameId, reason)
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
    if HopeAddon.Badges and HopeAddon.Badges.UnlockBadge then
        if not self.originalHooks.UnlockBadge then
            self.originalHooks.UnlockBadge = HopeAddon.Badges.UnlockBadge
        end
        local originalFunc = self.originalHooks.UnlockBadge
        HopeAddon.Badges.UnlockBadge = function(badgeModule, badgeId)
            originalFunc(badgeModule, badgeId)
            self:OnBadgeEarned(badgeId)
        end
    end

    -- Set up event handler
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            local newLevel = ...
            self:OnLevelUp(newLevel)
        elseif event == "CHAT_MSG_LOOT" then
            local message = ...
            -- Only process loot messages for the player ("You receive loot:")
            if message and message:find("You receive loot:") then
                self:OnLootReceived(message)
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            -- Combat ended - show pending loot prompts
            self:OnCombatEnd()
        end
    end)

    self.hooksInstalled = true
    HopeAddon:Debug("ActivityFeed: Event hooks installed")
end

--[[
    Restore original hooked functions
    Called from OnDisable to clean up function replacements and prevent memory leaks
]]
function ActivityFeed:RestoreEventHooks()
    if not self.hooksInstalled then return end

    -- Restore OnBossKilled
    if self.originalHooks.OnBossKilled and HopeAddon.Badges then
        HopeAddon.Badges.OnBossKilled = self.originalHooks.OnBossKilled
    end

    -- Restore UpdateMyProfile
    if self.originalHooks.UpdateMyProfile and HopeAddon.FellowTravelers then
        HopeAddon.FellowTravelers.UpdateMyProfile = self.originalHooks.UpdateMyProfile
    end

    -- Restore EndGame
    if self.originalHooks.EndGame and HopeAddon.GameCore then
        HopeAddon.GameCore.EndGame = self.originalHooks.EndGame
    end

    -- Restore UnlockBadge
    if self.originalHooks.UnlockBadge and HopeAddon.Badges then
        HopeAddon.Badges.UnlockBadge = self.originalHooks.UnlockBadge
    end

    -- Clear stored hooks
    self.originalHooks = {
        OnBossKilled = nil,
        UpdateMyProfile = nil,
        EndGame = nil,
        UnlockBadge = nil,
    }
    self.hooksInstalled = false

    HopeAddon:Debug("ActivityFeed: Event hooks restored to originals")
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

    -- Set encounter context for loot attribution (Phase 3)
    -- Try to determine raid name from boss
    local raidName = nil
    if HopeAddon.Constants and HopeAddon.Constants.BOSS_BADGES then
        for _, badge in ipairs(HopeAddon.Constants.BOSS_BADGES) do
            if badge.name == bossName or (badge.trigger and badge.trigger.boss == bossName) then
                raidName = badge.raid
                break
            end
        end
    end
    self:SetEncounterContext(bossName, raidName)

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

--[[
    Called when a romance event occurs
    @param eventType string - "PROPOSED", "DATING", "BREAKUP"
    @param partnerName string - Partner's name
    @param reason string|nil - Breakup reason (optional)
]]
function ActivityFeed:OnRomanceEvent(eventType, partnerName, reason)
    local _, class = UnitClass("player")
    local data = eventType .. "|" .. (partnerName or "") .. "|" .. (reason or "")
    local activity = self:CreateActivity(
        ACTIVITY.ROMANCE,
        UnitName("player"),
        class,
        data
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Romance event:", eventType, partnerName)
end

--[[
    Called when a calendar event is created
    @param action string - "CREATED", "UPDATED", "CANCELLED"
    @param event table - Event data
]]
function ActivityFeed:OnCalendarEvent(action, event)
    if not event then return end
    local _, class = UnitClass("player")
    local data = action .. "|" .. (event.title or "Event") .. "|" .. (event.raidKey or "") .. "|" .. (event.date or "") .. "|" .. (event.startTime or "")
    local activity = self:CreateActivity(
        ACTIVITY.EVENT,
        UnitName("player"),
        class,
        data
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Calendar event:", action, event.title)
end

--[[
    Called when someone signs up for a calendar event
    @param event table - Event data
    @param playerName string - Who signed up
    @param role string - Role they signed up as
]]
function ActivityFeed:OnCalendarSignup(event, playerName, role)
    if not event then return end
    local _, class = UnitClass("player")
    local data = "SIGNUP|" .. (event.title or "Event") .. "|" .. (playerName or "") .. "|" .. (role or "")
    local activity = self:CreateActivity(
        ACTIVITY.EVENT,
        UnitName("player"),
        class,
        data
    )
    self:QueueForBroadcast(activity)
    HopeAddon:Debug("ActivityFeed: Calendar signup:", playerName, "for", event.title)
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
    Get activity border color
    @param actType string - Activity type
    @return table - { r, g, b } color values
]]
function ActivityFeed:GetActivityBorderColor(actType)
    local C = HopeAddon.Constants
    if C and C.FEED_ACTIVITY_BORDERS and C.FEED_ACTIVITY_BORDERS[actType] then
        local color = C.FEED_ACTIVITY_BORDERS[actType]
        return color[1], color[2], color[3]
    end
    -- Default grey
    return 0.5, 0.5, 0.5
end

--[[
    Check if activity is an anonymous post
    @param activity table - Activity entry
    @return boolean - True if anonymous
]]
function ActivityFeed:IsAnonymousActivity(activity)
    return activity and activity.type == ACTIVITY.ANON
end

--[[
    Check if activity is a player-created post (IC or Anonymous)
    @param activity table - Activity entry
    @return boolean - True if user post
]]
function ActivityFeed:IsUserPost(activity)
    if not activity then return false end
    local t = activity.type
    return t == ACTIVITY.IC_POST or t == ACTIVITY.ANON or t == ACTIVITY.RUMOR
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
        -- Legacy: treat as IC post
        return string.format("|cFFFFD700%s|r: \"%s\"", player, data)

    elseif actType == ACTIVITY.IC_POST then
        -- In-character post: show player name + title + message
        local title = nil
        if HopeAddon.FellowTravelers then
            local fellowData = HopeAddon.FellowTravelers:GetFellow(player)
            if fellowData and fellowData.profile and fellowData.profile.selectedTitle then
                title = fellowData.profile.selectedTitle
            end
        end
        local attribution
        if title and title ~= "" then
            attribution = string.format("|cFFFFD700%s|r |cFF808080<%s>|r", player, title)
        else
            attribution = string.format("|cFFFFD700%s|r", player)
        end
        return string.format("%s: \"%s\"", attribution, data)

    elseif actType == ACTIVITY.ANON then
        -- Anonymous rumor: hide player identity
        local myName = UnitName("player")
        local isOwnPost = (player == myName)
        local attribution
        if isOwnPost then
            attribution = "|cFF9B30FFYou whispered|r"
        else
            attribution = "|cFF808080A patron whispers|r"
        end
        return string.format("%s: \"%s\"", attribution, data)

    elseif actType == ACTIVITY.LOOT then
        -- LOOT data format: itemLink|source|location|comment|isFirstKill
        local itemLink, source, location, comment, isFirstKill = strsplit("|", data, 5)
        -- Unescape item link (pipes were replaced with ~ for wire protocol)
        if itemLink then
            itemLink = itemLink:gsub("~", "|")
        end
        local firstKillTag = (isFirstKill == "1") and " |cFFFFD700(First Kill!)|r" or ""
        local commentText = (comment and comment ~= "") and string.format("\n\"%s\"", comment) or ""
        return string.format("|cFFA335EE%s|r received %s%s%s",
            player,
            itemLink or "[Unknown Item]",
            firstKillTag,
            commentText
        )

    elseif actType == ACTIVITY.ROMANCE then
        -- ROMANCE data format: eventType|partnerName|reason
        local eventType, partnerName, reason = strsplit("|", data, 3)
        if eventType == "PROPOSED" then
            return string.format("|cFFFF69B4%s|r proposed to |cFFFFD700%s|r! <3", player, partnerName or "someone")
        elseif eventType == "DATING" then
            return string.format("|cFFFF1493%s|r and |cFFFFD700%s|r are now dating! <3", player, partnerName or "someone")
        elseif eventType == "BREAKUP" then
            local reasonText = ""
            if reason and HopeAddon.Constants and HopeAddon.Constants.BREAKUP_REASON_TEXT then
                reasonText = " " .. (HopeAddon.Constants.BREAKUP_REASON_TEXT[reason] or "")
            end
            return string.format("|cFF808080%s|r and |cFFFFD700%s|r broke up. </3%s", player, partnerName or "someone", reasonText)
        else
            return string.format("|cFFFF69B4%s|r: Romance update", player)
        end

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
-- PHASE 2: RUMORS (Legacy)
-- PHASE 50: IC Posts & Anonymous Rumors
--============================================================

--[[
    Post a message to the activity feed (unified API for IC and Anonymous posts)
    @param text string - Message text (max 100 chars)
    @param isAnonymous boolean - True for anonymous "tavern rumor", false for IC post
    @return boolean - Success
]]
function ActivityFeed:PostMessage(text, isAnonymous)
    if not text or text == "" then return false end

    -- Rate limit (shared cooldown for both types)
    local now = GetTime()
    if now - self.lastPostTime < RUMOR_COOLDOWN then
        local remaining = math.ceil(RUMOR_COOLDOWN - (now - self.lastPostTime))
        HopeAddon:Print("Please wait " .. remaining .. " seconds before posting.")
        return false
    end

    -- Truncate and sanitize
    text = text:sub(1, RUMOR_MAX_LENGTH)
    text = text:gsub("|", "")  -- Remove color codes

    local _, class = UnitClass("player")
    local activityType = isAnonymous and ACTIVITY.ANON or ACTIVITY.IC_POST
    local activity = self:CreateActivity(
        activityType,
        UnitName("player"),
        class,
        text
    )

    -- Store in myRumors for expiry tracking
    local social = GetSocialData()
    if social then
        social.myRumors[activity.time] = {
            text = text,
            isAnonymous = isAnonymous,
            expires = time() + (RUMOR_EXPIRY_HOURS * 3600),
        }
    end

    self:QueueForBroadcast(activity)
    self.lastPostTime = now
    self.lastRumorTime = now  -- Keep legacy field updated for backward compat

    -- Broadcast immediately so it shows up right away (don't wait for ticker)
    self.lastBroadcast = 0
    self:BroadcastActivities()

    if isAnonymous then
        HopeAddon:Print("Tavern rumor posted anonymously!")
    else
        HopeAddon:Print("IC post shared!")
    end
    return true
end

--[[
    Convenience wrapper: Post an in-character message
    @param text string - Message text
    @return boolean - Success
]]
function ActivityFeed:PostICMessage(text)
    return self:PostMessage(text, false)
end

--[[
    Convenience wrapper: Post an anonymous tavern rumor
    @param text string - Message text
    @return boolean - Success
]]
function ActivityFeed:PostAnonymousRumor(text)
    return self:PostMessage(text, true)
end

--[[
    Legacy: Post a rumor (calls PostMessage with IC mode for backward compatibility)
    @param text string - Rumor text (max 100 chars)
    @return boolean - Success
]]
function ActivityFeed:PostRumor(text)
    -- Legacy function - treats as IC post
    return self:PostMessage(text, false)
end

--[[
    Check if player can post (cooldown check)
    @return boolean, number - Can post, seconds remaining
]]
function ActivityFeed:CanPost()
    local now = GetTime()
    local elapsed = now - self.lastPostTime
    if elapsed >= RUMOR_COOLDOWN then
        return true, 0
    end
    return false, math.ceil(RUMOR_COOLDOWN - elapsed)
end

--[[
    Legacy: Check if player can post a rumor (calls CanPost)
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
-- PHASE 3: LOOT SHARING
--============================================================

--[[
    Get current encounter context for loot attribution
    @return table - { source, location, isFirstKill }
]]
function ActivityFeed:GetLootContext()
    local now = GetTime()

    -- Check if we have valid encounter context
    if self.currentEncounter.bossName and self.currentEncounter.clearTime and now < self.currentEncounter.clearTime then
        local isFirstKill = false
        if HopeAddon.charDb and HopeAddon.charDb.journal and HopeAddon.charDb.journal.bossKills then
            local bossKills = HopeAddon.charDb.journal.bossKills[self.currentEncounter.bossName]
            -- First kill if count is 0 or 1 (just recorded)
            isFirstKill = not bossKills or (bossKills.totalKills or 0) <= 1
        end

        return {
            source = self.currentEncounter.bossName,
            location = self.currentEncounter.raidName or self.currentEncounter.dungeonName or GetZoneText(),
            isFirstKill = isFirstKill,
        }
    end

    -- Fallback: use zone name
    return {
        source = "Unknown",
        location = GetZoneText(),
        isFirstKill = false,
    }
end

--[[
    Set encounter context when boss is pulled/killed
    @param bossName string - Boss name
    @param raidName string|nil - Raid name if in raid
]]
function ActivityFeed:SetEncounterContext(bossName, raidName)
    self.currentEncounter = {
        bossName = bossName,
        raidName = raidName,
        dungeonName = not raidName and GetZoneText() or nil,
        startTime = GetTime(),
        clearTime = GetTime() + LOOT_CONTEXT_TIMEOUT,
    }
    HopeAddon:Debug("ActivityFeed: Set encounter context:", bossName, raidName or "dungeon")
end

--[[
    Clear encounter context
]]
function ActivityFeed:ClearEncounterContext()
    self.currentEncounter = {
        bossName = nil,
        raidName = nil,
        dungeonName = nil,
        startTime = nil,
        clearTime = nil,
    }
end

--[[
    Queue a loot share prompt for display after combat
    @param itemLink string - Item link
]]
function ActivityFeed:QueueLootSharePrompt(itemLink)
    if not itemLink then return end

    -- Check user settings
    local social = GetSocialData()
    if social and social.settings and social.settings.promptForLoot == false then
        HopeAddon:Debug("ActivityFeed: Loot prompts disabled by user")
        return
    end

    -- Get item info
    local _, _, quality, _, _, itemType, itemSubType, _, equipLoc, icon = GetItemInfo(itemLink)

    -- Only epic+ items
    if not quality or quality < LOOT_MIN_QUALITY then
        HopeAddon:Debug("ActivityFeed: Item quality too low:", quality)
        return
    end

    local context = self:GetLootContext()

    local prompt = {
        id = "loot_" .. time() .. "_" .. math.random(1000, 9999),
        type = "LOOT",
        timestamp = time(),
        expireAt = time() + LOOT_PROMPT_EXPIRE,
        data = {
            itemLink = itemLink,
            itemIcon = icon,
            itemQuality = quality,
            itemType = itemType,
            itemSubType = itemSubType,
            equipLoc = equipLoc,
            source = context.source,
            location = context.location,
            isFirstKill = context.isFirstKill,
        },
    }

    table.insert(self.pendingLootPrompts, prompt)
    HopeAddon:Debug("ActivityFeed: Queued loot prompt for:", itemLink)

    -- If not in combat, show immediately (after delay)
    if not InCombatLockdown() then
        HopeAddon.Timer:After(LOOT_PROMPT_DELAY, function()
            self:ShowNextLootPrompt()
        end)
    end
end

--[[
    Clean up expired loot prompts
]]
function ActivityFeed:CleanupExpiredPrompts()
    local now = time()
    local newPrompts = {}

    for _, prompt in ipairs(self.pendingLootPrompts) do
        if prompt.expireAt > now then
            table.insert(newPrompts, prompt)
        end
    end

    self.pendingLootPrompts = newPrompts
end

--[[
    Show the next pending loot prompt
]]
function ActivityFeed:ShowNextLootPrompt()
    -- Clean up expired first
    self:CleanupExpiredPrompts()

    -- Don't show if in combat
    if InCombatLockdown() then return end

    -- Get next prompt
    if #self.pendingLootPrompts == 0 then return end

    local prompt = self.pendingLootPrompts[1]
    self:ShowLootSharePrompt(prompt)
end

--[[
    Show loot share prompt UI
    @param prompt table - Prompt data
]]
function ActivityFeed:ShowLootSharePrompt(prompt)
    -- Hide existing prompt if any
    if self.currentPromptFrame then
        self.currentPromptFrame:Hide()
    end

    -- Create prompt frame
    local frame = CreateFrame("Frame", "HopeAddonLootSharePrompt", UIParent, "BackdropTemplate")
    frame:SetSize(350, 220)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Apply backdrop
    if HopeAddon.Components and HopeAddon.Components.ApplyBackdrop then
        HopeAddon.Components:ApplyBackdrop(frame, "DARK_GOLD", "DARK_SOLID", "GOLD")
    else
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
    end

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -12)
    title:SetText("|cFFFFD700Brag About Your Loot!|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        self:SkipLootPrompt(prompt)
    end)

    -- Item display container
    local itemBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    itemBox:SetSize(320, 60)
    itemBox:SetPoint("TOP", frame, "TOP", 0, -45)
    itemBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    itemBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    -- Item icon
    local icon = itemBox:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("LEFT", itemBox, "LEFT", 10, 0)
    if prompt.data.itemIcon then
        icon:SetTexture(prompt.data.itemIcon)
    else
        icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    -- Item link text
    local itemText = itemBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemText:SetPoint("LEFT", icon, "RIGHT", 10, 10)
    itemText:SetText(prompt.data.itemLink or "[Unknown Item]")

    -- Source info
    local sourceText = itemBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceText:SetPoint("LEFT", icon, "RIGHT", 10, -8)
    sourceText:SetTextColor(0.8, 0.8, 0.8)
    local sourceStr = prompt.data.source ~= "Unknown" and ("From: " .. prompt.data.source) or ""
    local locationStr = prompt.data.location and (" - " .. prompt.data.location) or ""
    sourceText:SetText(sourceStr .. locationStr)

    -- First kill badge
    if prompt.data.isFirstKill then
        local firstKill = itemBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        firstKill:SetPoint("TOPRIGHT", itemBox, "TOPRIGHT", -10, -8)
        firstKill:SetText("|cFFFFD700★ First Kill!|r")
    end

    -- Comment editbox label
    local commentLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    commentLabel:SetPoint("TOPLEFT", itemBox, "BOTTOMLEFT", 0, -10)
    commentLabel:SetText("Add a comment (optional):")
    commentLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Comment editbox
    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(300, 24)
    editBox:SetPoint("TOP", commentLabel, "BOTTOM", 0, -5)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(LOOT_COMMENT_MAX)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    frame.editBox = editBox

    -- Character count
    local charCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    charCount:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", 0, -2)
    charCount:SetText("0/" .. LOOT_COMMENT_MAX)
    charCount:SetTextColor(0.6, 0.6, 0.6)

    editBox:SetScript("OnTextChanged", function(self)
        local len = strlen(self:GetText())
        charCount:SetText(len .. "/" .. LOOT_COMMENT_MAX)
        if len >= LOOT_COMMENT_MAX then
            charCount:SetTextColor(1, 0.3, 0.3)
        else
            charCount:SetTextColor(0.6, 0.6, 0.6)
        end
    end)

    -- Share button
    local shareBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    shareBtn:SetSize(130, 26)
    shareBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 15)
    shareBtn:SetText("Brag About It!")
    shareBtn:SetScript("OnClick", function()
        local comment = editBox:GetText() or ""
        self:ShareLoot(prompt, comment)
    end)

    -- Skip button
    local skipBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    skipBtn:SetSize(100, 26)
    skipBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 15)
    skipBtn:SetText("Skip")
    skipBtn:SetScript("OnClick", function()
        self:SkipLootPrompt(prompt)
    end)

    -- "Don't ask" checkbox
    local dontAsk = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    dontAsk:SetSize(24, 24)
    dontAsk:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 25, 45)
    dontAsk.text = dontAsk:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dontAsk.text:SetPoint("LEFT", dontAsk, "RIGHT", 2, 0)
    dontAsk.text:SetText("Don't ask me about loot drops")
    dontAsk.text:SetTextColor(0.7, 0.7, 0.7)
    frame.dontAskCheckbox = dontAsk

    frame:Show()
    self.currentPromptFrame = frame

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end
end

--[[
    Share loot to activity feed
    @param prompt table - Prompt data
    @param comment string - Optional comment
]]
function ActivityFeed:ShareLoot(prompt, comment)
    -- Check "don't ask" checkbox
    if self.currentPromptFrame and self.currentPromptFrame.dontAskCheckbox then
        if self.currentPromptFrame.dontAskCheckbox:GetChecked() then
            local social = GetSocialData()
            if social and social.settings then
                social.settings.promptForLoot = false
                HopeAddon:Print("Loot share prompts disabled. Use '/hope settings' to re-enable.")
            end
        end
    end

    -- Remove from queue
    for i, p in ipairs(self.pendingLootPrompts) do
        if p.id == prompt.id then
            table.remove(self.pendingLootPrompts, i)
            break
        end
    end

    -- Hide prompt
    if self.currentPromptFrame then
        self.currentPromptFrame:Hide()
        self.currentPromptFrame = nil
    end

    -- Create activity
    local _, class = UnitClass("player")

    -- Encode data for wire: itemLink|source|location|comment|isFirstKill
    -- Escape pipes in itemLink with ~
    local escapedLink = prompt.data.itemLink:gsub("|", "~")
    local encodedData = string.format("%s|%s|%s|%s|%s",
        escapedLink,
        prompt.data.source or "",
        prompt.data.location or "",
        (comment or ""):sub(1, LOOT_COMMENT_MAX),
        prompt.data.isFirstKill and "1" or "0"
    )

    local activity = self:CreateActivity(
        ACTIVITY.LOOT,
        UnitName("player"),
        class,
        encodedData
    )

    self:QueueForBroadcast(activity)

    -- Play celebration sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    -- Show toast
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("loot_shared", nil, "Shared to your Fellow Travelers!")
    end

    HopeAddon:Print("Loot shared with your Fellow Travelers!")

    -- Show next prompt if any
    HopeAddon.Timer:After(0.5, function()
        self:ShowNextLootPrompt()
    end)
end

--[[
    Skip a loot share prompt
    @param prompt table - Prompt data
]]
function ActivityFeed:SkipLootPrompt(prompt)
    -- Check "don't ask" checkbox
    if self.currentPromptFrame and self.currentPromptFrame.dontAskCheckbox then
        if self.currentPromptFrame.dontAskCheckbox:GetChecked() then
            local social = GetSocialData()
            if social and social.settings then
                social.settings.promptForLoot = false
                HopeAddon:Print("Loot share prompts disabled. Use '/hope settings' to re-enable.")
            end
        end
    end

    -- Remove from queue
    for i, p in ipairs(self.pendingLootPrompts) do
        if p.id == prompt.id then
            table.remove(self.pendingLootPrompts, i)
            break
        end
    end

    -- Hide prompt
    if self.currentPromptFrame then
        self.currentPromptFrame:Hide()
        self.currentPromptFrame = nil
    end

    -- Show next prompt if any
    HopeAddon.Timer:After(0.5, function()
        self:ShowNextLootPrompt()
    end)
end

--[[
    Handle combat end - show pending loot prompts
]]
function ActivityFeed:OnCombatEnd()
    -- Clean up expired prompts
    self:CleanupExpiredPrompts()

    -- Show next prompt if any (after delay)
    if #self.pendingLootPrompts > 0 then
        HopeAddon.Timer:After(LOOT_PROMPT_DELAY, function()
            self:ShowNextLootPrompt()
        end)
    end
end

--[[
    Handle loot received event
    @param message string - Loot message
]]
function ActivityFeed:OnLootReceived(message)
    if not message then return end

    -- Parse loot message
    local itemLink = message:match(LOOT_PATTERN)
    if not itemLink then return end

    HopeAddon:Debug("ActivityFeed: Loot received:", itemLink)

    -- Queue for prompt
    self:QueueLootSharePrompt(itemLink)
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

    -- Start broadcast ticker (every 30 seconds - matches BROADCAST_COOLDOWN)
    -- This sends queued activities to the network and adds them to own feed
    self.broadcastTicker = HopeAddon.Timer:NewTicker(BROADCAST_COOLDOWN, function()
        ActivityFeed:BroadcastActivities()
    end)

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

    -- Restore hooked functions to originals (prevents memory leaks on /reload)
    self:RestoreEventHooks()

    -- Stop broadcast ticker
    if self.broadcastTicker then
        self.broadcastTicker:Cancel()
        self.broadcastTicker = nil
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

    -- Clean up loot prompt frame (Phase 3)
    if self.currentPromptFrame then
        self.currentPromptFrame:Hide()
        self.currentPromptFrame = nil
    end

    -- Clear pending loot prompts
    self.pendingLootPrompts = {}

    -- Clear encounter context
    self:ClearEncounterContext()

    -- Clear all listeners
    self.listeners = {}

    HopeAddon:Debug("ActivityFeed module disabled")
end

--============================================================
-- CONSTANTS EXPORT
--============================================================

ActivityFeed.ACTIVITY = ACTIVITY
ActivityFeed.STATUS_DISPLAY = STATUS_DISPLAY
