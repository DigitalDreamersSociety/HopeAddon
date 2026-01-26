--[[
    HopeAddon FellowTravelers Module
    Addon-to-addon detection, RP profiles, and social features
]]

local FellowTravelers = {}

--============================================================
-- CONSTANTS
--============================================================
local ADDON_PREFIX = "HOPEADDON"
local PROTOCOL_VERSION = 1

-- Message types
local MSG_PING = "PING"         -- Announce presence
local MSG_PONG = "PONG"         -- Response to ping
local MSG_PROFILE_REQ = "PREQ"  -- Request profile
local MSG_PROFILE = "PROF"      -- Profile data
local MSG_LOCATION = "LOC"      -- Location update

-- Throttling
local BROADCAST_INTERVAL = 15   -- Seconds between broadcasts (faster detection)
local PROFILE_CACHE_TIME = 3600 -- 1 hour cache for profiles
local PING_COOLDOWN = 5         -- Minimum seconds between pings to same player
local DISCOVERY_SOUND_COOLDOWN = 30  -- Cooldown for Murloc sound to prevent spam in crowded areas

-- RP Status options
FellowTravelers.STATUS_OPTIONS = {
    { id = "OOC", label = "Out of Character", color = "808080" },
    { id = "IC", label = "In Character", color = "00FF00" },
    { id = "LF_RP", label = "Looking for RP", color = "FFD700" },
}

-- Personality trait options
FellowTravelers.PERSONALITY_TRAITS = {
    "Stoic", "Curious", "Battle-hardened", "Cheerful", "Mysterious",
    "Reckless", "Cautious", "Loyal", "Cunning", "Compassionate",
    "Gruff", "Scholarly", "Devout", "Cynical", "Optimistic",
    "Noble", "Roguish", "Fierce", "Gentle", "Haunted",
}

--============================================================
-- MODULE STATE
--============================================================
FellowTravelers.lastBroadcast = 0
FellowTravelers.pingCooldowns = {}  -- [playerName] = lastPingTime
FellowTravelers.eventFrame = nil
FellowTravelers.originalAddMessage = nil  -- For chat hook
FellowTravelers.pendingBroadcast = nil  -- Timer deduplication
FellowTravelers.profileRequestCooldowns = {}  -- [playerName] = lastRequestTime
FellowTravelers.lastDiscoverySoundTime = 0  -- Cooldown tracking for Murloc sound
FellowTravelers.cleanupTicker = nil  -- Periodic cleanup timer handle
FellowTravelers.broadcastTicker = nil  -- Periodic broadcast timer handle for continuous discovery
FellowTravelers.messageCallbacks = {}  -- Registered message handlers for extensibility
FellowTravelers.yellCounter = 0  -- Counter for throttle-aware YELL broadcasting

-- Cleanup constants
local MAX_PING_COOLDOWNS = 100
local MAX_FELLOWS = 200
local FELLOW_EXPIRY_DAYS = 30
local PROFILE_REQUEST_COOLDOWN = 60  -- seconds between profile requests per player

--============================================================
-- COMPATIBILITY HELPERS
--============================================================

-- Cache SendAddonMessage function at load time (TBC optimization)
-- This avoids if/else check on every call
local CachedSendAddonMessage = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage

-- Safe wrapper for SendAddonMessage using cached function
-- Uses pcall to silently handle edge cases (leaving BGs, raid disbands, etc.)
local function SafeSendAddonMessage(prefix, msg, channel, target)
    if CachedSendAddonMessage then
        local success, err = pcall(CachedSendAddonMessage, prefix, msg, channel, target)
        if not success and HopeAddon.db and HopeAddon.db.debug then
            HopeAddon:Debug("SendAddonMessage failed:", channel, err)
        end
    end
end

-- Check if player is in an instance (dungeon, raid instance, battleground, arena)
-- When in an instance, we should use INSTANCE_CHAT instead of RAID/PARTY
-- This is available in TBC Classic 2.5+ and prevents "You are not in a raid group" spam
local function IsInInstanceGroup()
    -- IsInInstance() returns: inInstance, instanceType
    -- instanceType: "none", "pvp" (battleground), "arena", "party" (dungeon), "raid"
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    -- Return true for battlegrounds, arenas, and dungeons where INSTANCE_CHAT should be used
    return instanceType == "pvp" or instanceType == "arena" or instanceType == "party"
end

-- Check if player is in a REAL raid (not a battleground raid)
-- In battlegrounds, IsInRaid() returns true but SendAddonMessage to "RAID" can fail
-- GetRealNumRaidMembers() returns 0 in BGs but the actual raid size outside BGs
-- This prevents "You are not in a raid group" spam when entering/leaving BGs
local function IsInRealRaid()
    -- First check: if we're in a BG/arena/dungeon instance, we're NOT in a "real" raid
    if IsInInstanceGroup() then
        return false
    end
    -- GetRealNumRaidMembers exists in TBC Classic and returns 0 in BGs
    if GetRealNumRaidMembers then
        return GetRealNumRaidMembers() > 0
    end
    -- Fallback for compatibility (shouldn't hit in TBC 2.4.3)
    return IsInRaid()
end

-- Check if player is in a REAL party (not a battleground party)
local function IsInRealParty()
    -- First check: if we're in a BG/arena/dungeon instance, we're NOT in a "real" party
    if IsInInstanceGroup() then
        return false
    end
    -- GetRealNumPartyMembers exists in TBC Classic and returns 0 in BGs
    if GetRealNumPartyMembers then
        return GetRealNumPartyMembers() > 0
    end
    -- Fallback
    return IsInGroup() and not IsInRaid()
end

-- Escape special Lua pattern characters for safe use in gsub
local function EscapePattern(str)
    if not str then return "" end
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Schedule a broadcast with timer deduplication
local function ScheduleBroadcast(delay)
    if FellowTravelers.pendingBroadcast then
        -- Timer already pending, skip to avoid stacking
        return
    end
    FellowTravelers.pendingBroadcast = HopeAddon.Timer:After(delay, function()
        FellowTravelers.pendingBroadcast = nil
        FellowTravelers:BroadcastPresence()
    end)
end

--============================================================
-- MESSAGE CALLBACK REGISTRATION
-- Allows other modules to register handlers without hooking
--============================================================

--[[
    Register a callback for specific message types
    @param callbackId string - Unique identifier for this callback
    @param matchFunc function(msgType) - Returns true if this callback should handle the message
    @param handler function(msgType, sender, data) - Handler function
]]
function FellowTravelers:RegisterMessageCallback(callbackId, matchFunc, handler)
    self.messageCallbacks[callbackId] = {
        match = matchFunc,
        handler = handler,
    }
    HopeAddon:Debug("Registered message callback:", callbackId)
end

--[[
    Unregister a message callback
    @param callbackId string
]]
function FellowTravelers:UnregisterMessageCallback(callbackId)
    if self.messageCallbacks[callbackId] then
        self.messageCallbacks[callbackId] = nil
        HopeAddon:Debug("Unregistered message callback:", callbackId)
    end
end

--============================================================
-- LIFECYCLE
--============================================================

function FellowTravelers:OnInitialize()
    -- Register addon message prefix (with compatibility check)
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
    elseif RegisterAddonMessagePrefix then
        -- Fallback for older API
        RegisterAddonMessagePrefix(ADDON_PREFIX)
    end
end

function FellowTravelers:OnEnable()
    self:Initialize()
end

function FellowTravelers:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
    self:UnhookChat()
    -- Cancel periodic cleanup ticker
    if self.cleanupTicker then
        self.cleanupTicker:Cancel()
        self.cleanupTicker = nil
    end
    -- Cancel periodic broadcast ticker
    if self.broadcastTicker then
        self.broadcastTicker:Cancel()
        self.broadcastTicker = nil
    end
end

function FellowTravelers:Initialize()
    self.eventFrame = CreateFrame("Frame")

    -- Register events
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "GROUP_ROSTER_UPDATE" then
            self:OnPartyChanged()
        elseif event == "CHAT_MSG_ADDON" then
            self:OnAddonMessage(...)
        elseif event == "ZONE_CHANGED_NEW_AREA" then
            self:OnZoneChanged()
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:OnTargetChanged()
        end
    end)

    -- Hook tooltip
    self:HookTooltip()

    -- Hook chat frames for name coloring
    self:HookChat()

    -- Initial broadcast after short delay (uses deduplication)
    ScheduleBroadcast(5)

    -- Run initial table cleanup
    self:CleanupTables()

    -- Run periodic cleanup every 5 minutes to prevent table growth during long sessions
    self.cleanupTicker = HopeAddon.Timer:NewTicker(300, function()
        FellowTravelers:CleanupTables()
    end)

    -- Periodic broadcast for continuous discovery of nearby addon users
    -- This is the key fix - without this, players only discover each other on login/zone change
    local ticker = HopeAddon.Timer:NewTicker(BROADCAST_INTERVAL, function()
        FellowTravelers:BroadcastPresence()
    end)
    if ticker then
        self.broadcastTicker = ticker
    end

    HopeAddon:Debug("FellowTravelers module initialized with addon communication")
end

--============================================================
-- ADDON MESSAGE PROTOCOL
--============================================================

-- Message handler lookup table for O(1) routing
local MESSAGE_HANDLERS = {
    [MSG_PING] = "HandlePing",
    [MSG_PONG] = "HandlePong",
    [MSG_PROFILE_REQ] = "HandleProfileRequest",
    [MSG_PROFILE] = "HandleProfileData",
}

--[[
    Broadcast presence to nearby players
]]
function FellowTravelers:BroadcastPresence()
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.enabled then return end

    local now = GetTime()
    if now - self.lastBroadcast < BROADCAST_INTERVAL then return end
    self.lastBroadcast = now

    local zone = GetZoneText() or ""

    -- Get player location for sharing
    local x, y = nil, nil
    local MapPins = HopeAddon.MapPins
    if MapPins then
        x, y = MapPins:GetPlayerLocation()
    end

    -- Include location in ping if available
    local locStr = ""
    if x and y then
        locStr = string.format("|%.3f|%.3f", x, y)
    end

    local msg = string.format("%s:%d:%s%s", MSG_PING, PROTOCOL_VERSION, zone, locStr)

    -- Send to different channels based on context
    -- Priority: INSTANCE_CHAT (for BGs/dungeons) > RAID > PARTY > GUILD > YELL
    -- Using INSTANCE_CHAT in instances avoids "You are not in a raid group" spam
    local inInstance = IsInInstanceGroup()
    local inRealRaid = IsInRealRaid()
    local inRealParty = IsInRealParty()

    if inInstance then
        -- In battleground, arena, or dungeon - use INSTANCE_CHAT
        SafeSendAddonMessage(ADDON_PREFIX, msg, "INSTANCE_CHAT")
    elseif inRealRaid then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "RAID")
    elseif inRealParty then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "PARTY")
    end

    if IsInGuild() then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "GUILD")
    end

    -- Yell for nearby non-grouped players (skip when in instance or real raid - redundant)
    -- Only YELL every other broadcast (every 30s) to reduce throttle risk in busy areas
    if not inInstance and not inRealRaid then
        self.yellCounter = (self.yellCounter or 0) + 1
        if self.yellCounter % 2 == 0 then
            SafeSendAddonMessage(ADDON_PREFIX, msg, "YELL")
        end
    end

    HopeAddon:Debug("Broadcast presence:", msg)
end

--[[
    Send a direct message to a specific player
    @param target string - Player name
    @param msgType string - Message type
    @param data string - Message data
]]
function FellowTravelers:SendDirectMessage(target, msgType, data)
    local msg = string.format("%s:%d:%s", msgType, PROTOCOL_VERSION, data or "")
    SafeSendAddonMessage(ADDON_PREFIX, msg, "WHISPER", target)
end

--[[
    Broadcast a raw message to all channels (for other modules like ActivityFeed)
    @param msg string - Complete message to broadcast
]]
function FellowTravelers:BroadcastMessage(msg)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.enabled then return end

    -- Send to different channels based on context
    -- Priority: INSTANCE_CHAT (for BGs/dungeons) > RAID > PARTY > GUILD > YELL
    -- Using INSTANCE_CHAT in instances avoids "You are not in a raid group" spam
    local inInstance = IsInInstanceGroup()
    local inRealRaid = IsInRealRaid()
    local inRealParty = IsInRealParty()

    if inInstance then
        -- In battleground, arena, or dungeon - use INSTANCE_CHAT
        SafeSendAddonMessage(ADDON_PREFIX, msg, "INSTANCE_CHAT")
    elseif inRealRaid then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "RAID")
    elseif inRealParty then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "PARTY")
    end

    if IsInGuild() then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "GUILD")
    end

    -- YELL for nearby non-grouped players (skip when in instance or real raid)
    if not inInstance and not inRealRaid then
        SafeSendAddonMessage(ADDON_PREFIX, msg, "YELL")
    end

    HopeAddon:Debug("Broadcast message:", msg:sub(1, 50))
end

--[[
    Handle incoming addon messages
]]
function FellowTravelers:OnAddonMessage(prefix, message, channel, sender)
    if prefix ~= ADDON_PREFIX then return end

    -- Don't process our own messages
    local playerName = UnitName("player")
    if sender == playerName or sender == playerName .. "-" .. GetRealmName() then
        return
    end

    -- Parse sender name (remove realm if present)
    local senderName = strsplit("-", sender)

    -- Parse message
    local msgType, version, data = strsplit(":", message, 3)
    version = tonumber(version) or 0

    -- Version check (allow older versions for compatibility)
    if version > PROTOCOL_VERSION then
        HopeAddon:Debug("Received message from newer protocol version:", version)
    end

    -- Check registered callbacks first (for extensibility)
    for _, callback in pairs(self.messageCallbacks) do
        if callback.match(msgType) then
            callback.handler(msgType, senderName, data)
            return  -- Message handled by callback
        end
    end

    -- Handle core FellowTravelers messages using O(1) lookup
    local handler = MESSAGE_HANDLERS[msgType]
    if handler then
        -- HandlePing needs the channel parameter
        if msgType == MSG_PING then
            self[handler](self, senderName, data, channel)
        else
            self[handler](self, senderName, data)
        end
        return
    end

    -- Forward to Minigames module
    local Minigames = HopeAddon:GetModule("Minigames")
    if Minigames and Minigames:IsMinigameMessage(msgType) then
        Minigames:HandleMessage(msgType, senderName, data)
    end
end

--[[
    Handle PING message - another addon user announced presence
]]
function FellowTravelers:HandlePing(sender, zoneData, channel)
    -- Parse zone and optional location from zoneData
    -- Format: "ZoneName" or "ZoneName|x|y"
    local zone, xStr, yStr = strsplit("|", zoneData, 3)
    local x = xStr and tonumber(xStr) or nil
    local y = yStr and tonumber(yStr) or nil

    HopeAddon:Debug("Received PING from", sender, "in zone", zone, "loc:", x, y)

    -- Record as fellow traveler with location
    self:RegisterFellow(sender, {
        zone = zone,
        x = x,
        y = y,
    })

    -- Update MapPins if location available
    if x and y and zone then
        local MapPins = HopeAddon.MapPins
        if MapPins then
            MapPins:UpdateFellowLocation(sender, x, y, zone)
        end
    end

    -- Respond with PONG (if not on cooldown)
    local now = GetTime()
    local cooldown = self.pingCooldowns[sender] or 0
    if now - cooldown >= PING_COOLDOWN then
        self:AddPingCooldown(sender)

        -- Build PONG response with basic info and location
        local _, class = UnitClass("player")
        local level = UnitLevel("player")
        local color = HopeAddon.Badges and HopeAddon.Badges:GetSelectedColor() or nil
        local title = HopeAddon.Badges and HopeAddon.Badges:GetSelectedTitle() or nil

        -- Get our location
        local myX, myY, myZone = nil, nil, GetZoneText()
        local MapPins = HopeAddon.MapPins
        if MapPins then
            myX, myY, myZone = MapPins:GetPlayerLocation()
        end

        -- Build response - only include location if we have valid coords
        local responseData
        if myX and myY then
            responseData = string.format("%d|%s|%s|%s|%s|%.3f|%.3f",
                level,
                class or "",
                color or "",
                title or "",
                myZone or "",
                myX,
                myY
            )
        else
            responseData = string.format("%d|%s|%s|%s|%s||",
                level,
                class or "",
                color or "",
                title or "",
                myZone or ""
            )
        end

        self:SendDirectMessage(sender, MSG_PONG, responseData)
    end
end

--[[
    Handle PONG message - response to our ping
]]
function FellowTravelers:HandlePong(sender, data)
    HopeAddon:Debug("Received PONG from", sender, "data:", data)

    -- Parse response data (extended format with location)
    -- Format: level|class|color|title|zone|x|y
    local level, class, color, title, zone, xStr, yStr = strsplit("|", data, 7)
    level = tonumber(level)
    local x = xStr and tonumber(xStr) or nil
    local y = yStr and tonumber(yStr) or nil

    -- Register/update fellow
    self:RegisterFellow(sender, {
        level = level,
        class = class ~= "" and class or nil,
        selectedColor = color ~= "" and color or nil,
        selectedTitle = title ~= "" and title or nil,
        zone = zone ~= "" and zone or nil,
        x = x,
        y = y,
    })

    -- Update MapPins if location available
    if x and y and zone and x ~= 0 and y ~= 0 then
        local MapPins = HopeAddon.MapPins
        if MapPins then
            MapPins:UpdateFellowLocation(sender, x, y, zone)
        end
    end

    -- Request full profile if we don't have it cached
    local fellow = self:GetFellow(sender)
    if fellow and not fellow.profile then
        self:RequestProfile(sender)
    end
end

--[[
    Request a player's full profile
    Includes cooldown to prevent spam when hovering tooltips
]]
function FellowTravelers:RequestProfile(playerName)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.enabled then return end

    -- Check cooldown to prevent request spam
    local now = GetTime()
    local lastRequest = self.profileRequestCooldowns[playerName]
    if lastRequest and (now - lastRequest) < PROFILE_REQUEST_COOLDOWN then
        return  -- Skip, requested recently
    end
    self:AddProfileRequestCooldown(playerName)

    self:SendDirectMessage(playerName, MSG_PROFILE_REQ, "")
    HopeAddon:Debug("Requesting profile from", playerName)
end

--[[
    Handle profile request from another player
]]
function FellowTravelers:HandleProfileRequest(sender)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.shareProfile then return end

    local profile = HopeAddon.charDb.travelers.myProfile
    local data = self:SerializeProfile(profile)
    self:SendDirectMessage(sender, MSG_PROFILE, data)
    HopeAddon:Debug("Sent profile to", sender)
end

--[[
    Handle received profile data
]]
function FellowTravelers:HandleProfileData(sender, data)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return end

    local profile = self:DeserializeProfile(data)
    if profile then
        if fellows[sender] then
            fellows[sender].profile = profile
            fellows[sender].profileCachedAt = time()
            HopeAddon:Debug("Cached profile for", sender)
        end
    end
end

--============================================================
-- PROFILE SERIALIZATION
--============================================================

--[[
    Serialize profile for transmission (simple encoding for TBC)
    @param profile table
    @return string
]]
function FellowTravelers:SerializeProfile(profile)
    if not profile then return "" end

    -- Use a simple format: field1=value1;field2=value2
    -- Escape special characters
    local function escape(str)
        if not str or str == "" then return "" end
        return str:gsub("([;=|])", "\\%1"):gsub("\n", "\\n")
    end

    -- Get romance status to include
    local romanceStatus = ""
    local romancePartner = ""
    if HopeAddon.Romance then
        local romanceData = HopeAddon.Romance:GetStatus()
        romanceStatus = romanceData.status or "SINGLE"
        romancePartner = romanceData.partner or ""
    end

    local parts = {
        "b=" .. escape(profile.backstory or ""):sub(1, 200),  -- Truncate long fields
        "a=" .. escape(profile.appearance or ""):sub(1, 150),
        "h=" .. escape(profile.rpHooks or ""):sub(1, 150),
        "p=" .. escape(profile.pronouns or ""):sub(1, 30),
        "s=" .. (profile.status or "OOC"),
        "t=" .. table.concat(profile.personality or {}, ","),
        "c=" .. (profile.selectedColor or ""),
        "n=" .. escape(profile.selectedTitle or ""),
        "rs=" .. romanceStatus,
        "rp=" .. escape(romancePartner),
    }

    return table.concat(parts, ";")
end

--[[
    Deserialize profile from transmission
    @param data string
    @return table|nil
]]
function FellowTravelers:DeserializeProfile(data)
    if not data or data == "" then return nil end

    local function unescape(str)
        if not str then return "" end
        return str:gsub("\\n", "\n"):gsub("\\([;=|])", "%1")
    end

    local profile = {
        backstory = "",
        appearance = "",
        rpHooks = "",
        pronouns = "",
        status = "OOC",
        personality = {},
        selectedColor = nil,
        selectedTitle = nil,
        romanceStatus = "SINGLE",
        romancePartner = nil,
    }

    for part in data:gmatch("[^;]+") do
        local key, value = strsplit("=", part, 2)
        if key and value then
            value = unescape(value)
            if key == "b" then
                profile.backstory = value
            elseif key == "a" then
                profile.appearance = value
            elseif key == "h" then
                profile.rpHooks = value
            elseif key == "p" then
                profile.pronouns = value
            elseif key == "s" then
                profile.status = value
            elseif key == "t" and value ~= "" then
                for trait in value:gmatch("[^,]+") do
                    table.insert(profile.personality, trait)
                end
            elseif key == "c" and value ~= "" then
                profile.selectedColor = value
            elseif key == "n" and value ~= "" then
                profile.selectedTitle = value
            elseif key == "rs" then
                profile.romanceStatus = value
            elseif key == "rp" and value ~= "" then
                profile.romancePartner = value
            end
        end
    end

    return profile
end

--============================================================
-- FELLOW TRAVELER MANAGEMENT
--============================================================

--[[
    Register or update a fellow traveler
    @param name string
    @param info table - { level, class, zone, selectedColor, selectedTitle, x, y }
]]
function FellowTravelers:RegisterFellow(name, info)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return end

    local isNewFellow = not fellows[name]

    if isNewFellow then
        fellows[name] = {
            firstSeen = HopeAddon:GetDate(),
        }
        -- Play Murloc sound with cooldown to prevent spam in crowded areas (Shattrath, raids)
        local now = GetTime()
        if now - self.lastDiscoverySoundTime >= DISCOVERY_SOUND_COOLDOWN then
            HopeAddon:PlaySound("FELLOW_DISCOVERY")
            self.lastDiscoverySoundTime = now
        end
        HopeAddon:Print("|cFF9B30FF[Fellow Traveler]|r |cFF00FF00" .. name .. "|r discovered nearby! Mrglglgl!")
    end

    -- Check for companion online transition (offline -> online)
    -- Only for existing fellows (not new discoveries - they get their own notification)
    local fellow = fellows[name]
    if not isNewFellow then
        local COMPANION_ONLINE_THRESHOLD = 300  -- 5 minutes
        local oldLastSeenTime = fellow.lastSeenTime or 0
        local wasOffline = (time() - oldLastSeenTime) >= COMPANION_ONLINE_THRESHOLD

        -- If they were offline and are now coming back, check if they're a companion
        if wasOffline then
            local Companions = HopeAddon.Companions
            local SocialToasts = HopeAddon.SocialToasts
            if Companions and Companions:IsCompanion(name) and SocialToasts then
                SocialToasts:Show("companion_online", name)
            end
        end
    end

    -- Update info
    fellow.lastSeen = HopeAddon:GetDate()
    fellow.lastSeenTime = time()

    if info.level then fellow.level = info.level end
    if info.class then fellow.class = info.class end
    if info.zone then fellow.lastSeenZone = info.zone end
    if info.selectedColor then fellow.selectedColor = info.selectedColor end
    if info.selectedTitle then fellow.selectedTitle = info.selectedTitle end

    -- Update location data for map pins
    if info.x and info.y then
        fellow.x = info.x
        fellow.y = info.y
        fellow.locationTime = GetTime()
    end

    -- Also update known travelers for compatibility
    self:UpdateKnownTraveler(name, info.class, info.level)
end

--[[
    Get fellow traveler info
    @param name string
    @return table|nil
]]
function FellowTravelers:GetFellow(name)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return nil end
    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return nil end
    return fellows[name]
end

--[[
    Check if a player is a fellow traveler
    @param name string
    @return boolean
]]
function FellowTravelers:IsFellow(name)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return false end
    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return false end
    return fellows[name] ~= nil
end

--[[
    Get fellow's cached profile
    @param name string
    @return table|nil
]]
function FellowTravelers:GetFellowProfile(name)
    local fellow = self:GetFellow(name)
    if not fellow or not fellow.profile then return nil end

    -- Check cache expiry
    if fellow.profileCachedAt and (time() - fellow.profileCachedAt) > PROFILE_CACHE_TIME then
        fellow.profile = nil
        return nil
    end

    return fellow.profile
end

--[[
    Clean up tables to prevent unbounded growth
    Called on login and can be called periodically
]]
function FellowTravelers:CleanupTables()
    local now = GetTime()

    -- Clean pingCooldowns - remove expired entries and limit size
    local pingCount = 0
    for name, timestamp in pairs(self.pingCooldowns) do
        pingCount = pingCount + 1
        -- Remove if expired (5 minutes) or if we have too many
        if now - timestamp > 300 or pingCount > MAX_PING_COOLDOWNS then
            self.pingCooldowns[name] = nil
        end
    end

    -- Clean profileRequestCooldowns - remove expired entries
    for name, timestamp in pairs(self.profileRequestCooldowns) do
        if now - timestamp > PROFILE_REQUEST_COOLDOWN then
            self.profileRequestCooldowns[name] = nil
        end
    end

    -- Clean old fellows from SavedVariables
    if HopeAddon.charDb and HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellows then
        local fellows = HopeAddon.charDb.travelers.fellows
        local cutoff = time() - (FELLOW_EXPIRY_DAYS * 86400)
        local fellowCount = 0

        -- First pass: count and remove expired
        for name, data in pairs(fellows) do
            fellowCount = fellowCount + 1
            if data.lastSeenTime and data.lastSeenTime < cutoff then
                fellows[name] = nil
                fellowCount = fellowCount - 1
            end
        end

        -- If still too many, clear profile caches to save memory
        if fellowCount > MAX_FELLOWS then
            for name, data in pairs(fellows) do
                data.profile = nil
            end
            HopeAddon:Debug("Cleared profile caches due to fellow count:", fellowCount)
        end
    end

    HopeAddon:Debug("CleanupTables completed - pingCooldowns:", pingCount)
end

--[[
    Add a ping cooldown entry with proactive pruning
    @param name string - Player name
]]
function FellowTravelers:AddPingCooldown(name)
    -- Prune if over limit BEFORE adding
    local count = 0
    for _ in pairs(self.pingCooldowns) do
        count = count + 1
    end

    if count >= MAX_PING_COOLDOWNS then
        -- Find and remove oldest entry
        local oldestName, oldestTime = nil, math.huge
        for pname, timestamp in pairs(self.pingCooldowns) do
            if timestamp < oldestTime then
                oldestTime = timestamp
                oldestName = pname
            end
        end
        if oldestName then
            self.pingCooldowns[oldestName] = nil
        end
    end

    self.pingCooldowns[name] = GetTime()
end

--[[
    Add a profile request cooldown entry with proactive pruning
    @param name string - Player name
]]
function FellowTravelers:AddProfileRequestCooldown(name)
    -- Prune expired entries if table is growing large
    local count = 0
    for _ in pairs(self.profileRequestCooldowns) do
        count = count + 1
    end

    if count >= 100 then
        local now = GetTime()
        for pname, timestamp in pairs(self.profileRequestCooldowns) do
            if now - timestamp > PROFILE_REQUEST_COOLDOWN then
                self.profileRequestCooldowns[pname] = nil
            end
        end
    end

    self.profileRequestCooldowns[name] = GetTime()
end

--============================================================
-- TOOLTIP INTEGRATION
--============================================================

-- Module-scope tooltip handler (avoids closure)
local function OnTooltipSetUnit(tooltip)
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers then return end

    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.showTooltips then return end

    local _, unit = tooltip:GetUnit()
    if not unit or not UnitIsPlayer(unit) then return end

    local name = UnitName(unit)
    if not name then return end

    local fellow = FellowTravelers:GetFellow(name)
    if not fellow then return end

    -- Add separator
    tooltip:AddLine(" ")
    tooltip:AddLine("|cFF00FF00[Fellow Traveler]|r", 0, 1, 0)

    -- Show title if available
    if fellow.selectedTitle then
        tooltip:AddLine("\"" .. fellow.selectedTitle .. "\"", 1, 0.84, 0)
    end

    -- Show profile if available
    local profile = FellowTravelers:GetFellowProfile(name)
    if profile then
        -- Status
        local statusColor = "808080"
        for _, opt in ipairs(FellowTravelers.STATUS_OPTIONS) do
            if opt.id == profile.status then
                statusColor = opt.color
                tooltip:AddLine("Status: |cFF" .. statusColor .. opt.label .. "|r")
                break
            end
        end

        -- Backstory excerpt
        if profile.backstory and profile.backstory ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine("BACKSTORY:", 0.7, 0.7, 0.7)
            local excerpt = profile.backstory:sub(1, 100)
            if #profile.backstory > 100 then excerpt = excerpt .. "..." end
            tooltip:AddLine("\"" .. excerpt .. "\"", 1, 1, 1, true)
        end

        -- Personality traits
        if profile.personality and #profile.personality > 0 then
            tooltip:AddLine(" ")
            local traits = table.concat(profile.personality, ", ")
            tooltip:AddLine("Personality: " .. traits, 0.8, 0.8, 0.6, true)
        end

        -- Appearance
        if profile.appearance and profile.appearance ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine("APPEARANCE:", 0.7, 0.7, 0.7)
            local excerpt = profile.appearance:sub(1, 80)
            if #profile.appearance > 80 then excerpt = excerpt .. "..." end
            tooltip:AddLine(excerpt, 0.9, 0.9, 0.9, true)
        end

        -- RP Hooks
        if profile.rpHooks and profile.rpHooks ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine("RUMORS:", 0.7, 0.7, 0.7)
            local excerpt = profile.rpHooks:sub(1, 80)
            if #profile.rpHooks > 80 then excerpt = excerpt .. "..." end
            tooltip:AddLine("\"" .. excerpt .. "\"", 0.8, 0.8, 0.6, true)
        end

        -- Pronouns
        if profile.pronouns and profile.pronouns ~= "" then
            tooltip:AddLine("Pronouns: " .. profile.pronouns, 0.6, 0.6, 0.6)
        end
    else
        -- Request profile if not cached
        FellowTravelers:RequestProfile(name)
    end

    -- First seen date
    if fellow.firstSeen then
        tooltip:AddLine(" ")
        tooltip:AddLine("First seen: " .. fellow.firstSeen, 0.5, 0.5, 0.5)
    end

    tooltip:Show()
end

function FellowTravelers:HookTooltip()
    GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
end

--============================================================
-- CHAT COLORING
--============================================================

function FellowTravelers:HookChat()
    local settings = HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.colorChat then return end

    -- Hook each chat frame
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            self:HookChatFrame(chatFrame)
        end
    end
end

function FellowTravelers:HookChatFrame(chatFrame)
    if chatFrame._hopeHooked then return end
    chatFrame._hopeHooked = true

    local originalAddMessage = chatFrame.AddMessage
    chatFrame.AddMessage = function(self, msg, r, g, b, ...)
        -- Early exit check: only process if addon enabled and colorChat enabled
        local settings = HopeAddon.charDb and HopeAddon.charDb.travelers
            and HopeAddon.charDb.travelers.fellowSettings
        if msg and settings and settings.enabled and settings.colorChat then
            msg = FellowTravelers:ColorFellowNames(msg)
        end
        return originalAddMessage(self, msg, r, g, b, ...)
    end
end

function FellowTravelers:UnhookChat()
    -- Note: Can't truly unhook, but the coloring checks settings
end

--[[
    Color fellow traveler names in a message
    Optimized: extracts names from message first, only processes matching fellows
    @param msg string
    @return string
]]
function FellowTravelers:ColorFellowNames(msg)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return msg end
    local settings = HopeAddon.charDb.travelers.fellowSettings
    if not settings or not settings.colorChat then return msg end

    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return msg end

    -- Build a set of names that appear in this message for O(1) lookup
    -- Extract all bracketed names from the message: [Name]
    local namesInMessage = {}
    for name in msg:gmatch("%[([^%]]+)%]") do
        namesInMessage[name] = true
    end

    -- If no bracketed names found, skip processing
    if not next(namesInMessage) then return msg end

    -- Only process fellows whose names appear in the message
    for name in pairs(namesInMessage) do
        local fellow = fellows[name]
        if fellow then
            local color = fellow.selectedColor or "00FF00"  -- Default green

            -- Escape special pattern characters in player name to prevent crashes
            local escapedName = EscapePattern(name)

            -- Pattern for bracketed names (simple case)
            local pattern1 = "%[" .. escapedName .. "%]"
            local replacement1 = "|cFF" .. color .. "[" .. name .. "]|r"

            -- Pattern for player links (clickable names)
            local pattern2 = "(|Hplayer:" .. escapedName .. "[^|]*|h)%[" .. escapedName .. "%](|h)"
            local replacement2 = "%1|cFF" .. color .. "[" .. name .. "]|r%2"

            msg = msg:gsub(pattern1, replacement1)
            msg = msg:gsub(pattern2, replacement2)
        end
    end

    return msg
end

--============================================================
-- EVENT HANDLERS
--============================================================

-- Track last known party members for detecting new joiners
FellowTravelers.lastKnownParty = {}

function FellowTravelers:OnPartyChanged()
    -- Get current party members
    local currentParty = {}
    local newMembers = {}

    local numMembers = GetNumGroupMembers()
    if numMembers > 0 then
        local isRaid = IsInRaid()
        local prefix = isRaid and "raid" or "party"
        local maxIndex = isRaid and 40 or 4

        for i = 1, maxIndex do
            local unit = prefix .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local name = UnitName(unit)
                if name then
                    currentParty[name] = true

                    -- Check if this is a new member
                    if not self.lastKnownParty[name] then
                        local _, class = UnitClass(unit)
                        local level = UnitLevel(unit)
                        table.insert(newMembers, {
                            name = name,
                            class = class,
                            level = level,
                            unit = unit,
                        })
                    end
                end
            end
        end
    end

    -- Update known travelers (new members get isNewGroup = true)
    -- Also re-register any party members who were previously fellows (updates lastSeenTime)
    for _, member in ipairs(newMembers) do
        self:UpdateKnownTraveler(member.name, member.class, member.level, true)

        -- If this party member was previously a fellow, update their lastSeenTime
        -- This ensures they show up in the "IN YOUR PARTY" section immediately
        if self:IsFellow(member.name) then
            self:RegisterFellow(member.name, {
                class = member.class,
                level = member.level,
            })
        end
    end

    -- Update last known party
    self.lastKnownParty = currentParty
end

function FellowTravelers:OnZoneChanged()
    -- Broadcast presence in new zone (uses deduplication)
    ScheduleBroadcast(2)
end

function FellowTravelers:OnTargetChanged()
    -- If targeting a player, check if they're a fellow
    if UnitIsPlayer("target") then
        local name = UnitName("target")
        if name and self:IsFellow(name) then
            local fellow = self:GetFellow(name)
            if fellow and not fellow.profile then
                self:RequestProfile(name)
            end
        end
    end
end

--============================================================
-- LEGACY FUNCTIONS (for compatibility with existing code)
--============================================================

--[[
    Get current party members
    @return table - Array of party member info
]]
function FellowTravelers:GetPartyMembers()
    local members = {}

    local numMembers = GetNumGroupMembers()
    if numMembers == 0 then
        return members
    end

    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local maxIndex = isRaid and 40 or 4

    for i = 1, maxIndex do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            local level = UnitLevel(unit)

            if name then
                table.insert(members, {
                    name = name,
                    class = class,
                    level = level,
                    unit = unit,
                })
                -- Note: Known traveler tracking is handled by OnPartyChanged event
            end
        end
    end

    return members
end

--[[
    Update a known traveler's information
    Preserves icons and stats from existing entry
    @param name string - Player name
    @param class string - Class name
    @param level number - Player level
    @param isNewGroup boolean - If true, increment group count
]]
function FellowTravelers:UpdateKnownTraveler(name, class, level, isNewGroup)
    if not name then return end
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end

    local travelers = HopeAddon.charDb.travelers.known
    if not travelers then return end
    local existing = travelers[name] or {}
    local isFirstGroup = not existing.stats or (existing.stats.groupCount or 0) == 0

    -- Preserve existing icons and stats
    travelers[name] = {
        class = class or existing.class,
        level = level or existing.level,
        lastSeen = HopeAddon:GetDate(),
        lastSeenZone = GetZoneText(),
        firstSeen = existing.firstSeen or HopeAddon:GetDate(),
        icons = existing.icons or {},
        stats = existing.stats or {
            groupCount = 0,
            bossKillsTogether = 0,
            zonesVisitedTogether = {},
        },
    }

    -- Increment group count if this is a new group session
    if isNewGroup then
        travelers[name].stats.groupCount = (travelers[name].stats.groupCount or 0) + 1
        HopeAddon:Debug("Group count with", name, ":", travelers[name].stats.groupCount)
    end
end

--[[
    Get information about a known traveler
    @param name string - Player name
    @return table|nil - Traveler info or nil
]]
function FellowTravelers:GetTraveler(name)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return nil end
    local known = HopeAddon.charDb.travelers.known
    if not known then return nil end
    return known[name]
end

--[[
    Get all known travelers
    @return table - Dictionary of travelers
]]
function FellowTravelers:GetAllTravelers()
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return {} end
    return HopeAddon.charDb.travelers.known or {}
end

--[[
    Get count of known travelers
    @return number
]]
function FellowTravelers:GetTravelerCount()
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return 0 end
    local known = HopeAddon.charDb.travelers.known
    if not known then return 0 end

    local count = 0
    for _ in pairs(known) do
        count = count + 1
    end
    return count
end

--[[
    Get count of fellow travelers (addon users)
    @return number
]]
function FellowTravelers:GetFellowCount()
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return 0 end
    local fellows = HopeAddon.charDb.travelers.fellows
    if not fellows then return 0 end

    local count = 0
    for _ in pairs(fellows) do
        count = count + 1
    end
    return count
end

--[[
    Format party members for display
    @return string - Formatted string of party members
]]
function FellowTravelers:FormatPartyForDisplay()
    local members = self:GetPartyMembers()

    if #members == 0 then
        return "Solo"
    end

    local names = {}
    for _, member in ipairs(members) do
        local classColor = HopeAddon:GetClassColor(member.class)
        local coloredName = string.format("|cFF%02x%02x%02x%s|r",
            classColor.r * 255, classColor.g * 255, classColor.b * 255,
            member.name)
        table.insert(names, coloredName)
    end

    return table.concat(names, ", ")
end

--[[
    Get party composition for milestone recording
    @return table - Party snapshot
]]
function FellowTravelers:GetPartySnapshot()
    local members = self:GetPartyMembers()

    return {
        size = #members + 1,
        isRaid = IsInRaid(),
        isParty = IsInGroup() and not IsInRaid(),
        isSolo = #members == 0,
        members = members,
        zone = GetZoneText(),
        timestamp = HopeAddon:GetTimestamp(),
    }
end

--[[
    Get travelers seen recently (within days)
    @param days number - Number of days
    @return table - Array of recent travelers
]]
function FellowTravelers:GetRecentTravelers(days)
    days = days or 7
    local recent = {}
    local cutoffTime = time() - (days * 24 * 60 * 60)

    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return recent end
    local known = HopeAddon.charDb.travelers.known
    if not known then return recent end

    for name, info in pairs(known) do
        if info.lastSeen then
            local year, month, day = info.lastSeen:match("(%d+)-(%d+)-(%d+)")
            if year and month and day then
                local lastSeenTime = time({
                    year = tonumber(year),
                    month = tonumber(month),
                    day = tonumber(day),
                })

                if lastSeenTime >= cutoffTime then
                    table.insert(recent, {
                        name = name,
                        class = info.class,
                        level = info.level,
                        lastSeen = info.lastSeen,
                        lastSeenZone = info.lastSeenZone,
                    })
                end
            end
        end
    end

    table.sort(recent, function(a, b)
        return (a.lastSeen or "") > (b.lastSeen or "")
    end)

    return recent
end

--[[
    Check if currently in a guild group
    @return boolean
]]
function FellowTravelers:IsGuildGroup()
    if not IsInGuild() then return false end

    local guildName = GetGuildInfo("player")
    if not guildName then return false end

    local partyMembers = self:GetPartyMembers()
    if #partyMembers == 0 then return false end

    local guildLookup = {}
    local numGuildMembers = GetNumGuildMembers()
    for i = 1, numGuildMembers do
        local memberName = GetGuildRosterInfo(i)
        if memberName then
            guildLookup[strsplit("-", memberName)] = true
        end
    end

    local guildMemberCount = 0
    for _, member in ipairs(partyMembers) do
        if guildLookup[member.name] then
            guildMemberCount = guildMemberCount + 1
        end
    end

    return guildMemberCount > (#partyMembers / 2)
end

--============================================================
-- PROFILE HELPERS
--============================================================

--[[
    Get the player's own profile
    @return table
]]
function FellowTravelers:GetMyProfile()
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return nil end
    return HopeAddon.charDb.travelers.myProfile
end

--[[
    Update the player's own profile
    @param updates table - Fields to update
]]
function FellowTravelers:UpdateMyProfile(updates)
    if not HopeAddon.charDb or not HopeAddon.charDb.travelers then return end
    local profile = HopeAddon.charDb.travelers.myProfile
    if not profile then return end

    for key, value in pairs(updates) do
        profile[key] = value
    end
end

--[[
    Get status display info
    @param statusId string
    @return table|nil
]]
function FellowTravelers:GetStatusInfo(statusId)
    for _, opt in ipairs(self.STATUS_OPTIONS) do
        if opt.id == statusId then
            return opt
        end
    end
    return nil
end

-- Register with addon
HopeAddon:RegisterModule("FellowTravelers", FellowTravelers)
HopeAddon:Debug("FellowTravelers module loaded")
