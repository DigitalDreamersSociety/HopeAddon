--[[
    HopeAddon Companions Module
    "Companions" - A favorites list of Fellow Travelers with online status

    Features:
    - Add/remove companions (favorites)
    - Send/accept/decline companion requests
    - Track online status via FellowTravelers lastSeenTime
    - 50 max companions, 24h request expiry
]]

local Companions = {}
HopeAddon.Companions = Companions
HopeAddon:RegisterModule("Companions", Companions)

--============================================================
-- CONSTANTS
--============================================================

local MSG_COMP_REQ = "COMP_REQ"   -- Companion request
local MSG_COMP_ACC = "COMP_ACC"   -- Accept request
local MSG_COMP_DEC = "COMP_DEC"   -- Decline request

local MAX_COMPANIONS = 50
local REQUEST_EXPIRY_HOURS = 24
local ONLINE_THRESHOLD = 300  -- 5 minutes = "online"

--============================================================
-- MODULE STATE
--============================================================

Companions.eventFrame = nil

--============================================================
-- DATA HELPERS
--============================================================

local function GetCompanionData()
    if not HopeAddon.charDb then return nil end

    if not HopeAddon.charDb.social then
        HopeAddon.charDb.social = {}
    end

    if not HopeAddon.charDb.social.companions then
        HopeAddon.charDb.social.companions = {
            list = {},         -- { [name] = { since, lastSeen, class, level } }
            outgoing = {},     -- { [name] = { timestamp } }
            incoming = {},     -- { [name] = { timestamp, class, level } }
        }
    end

    return HopeAddon.charDb.social.companions
end

--============================================================
-- COMPANION MANAGEMENT
--============================================================

--[[
    Send a companion request to a player
    @param playerName string
    @return boolean
]]
function Companions:SendRequest(playerName)
    local data = GetCompanionData()
    if not data then return false end

    -- Check if already a companion
    if data.list[playerName] then
        HopeAddon:Print(playerName .. " is already a companion!")
        return false
    end

    -- Check if request already pending
    if data.outgoing[playerName] then
        HopeAddon:Print("Request already sent to " .. playerName)
        return false
    end

    -- Check max companions
    local count = 0
    for _ in pairs(data.list) do count = count + 1 end
    if count >= MAX_COMPANIONS then
        HopeAddon:Print("Maximum companions reached (" .. MAX_COMPANIONS .. ")")
        return false
    end

    -- Send request via FellowTravelers
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_REQ, UnitName("player"))
    end

    -- Track outgoing
    data.outgoing[playerName] = { timestamp = time() }

    HopeAddon:Print("Companion request sent to " .. playerName)
    return true
end

--[[
    Accept a companion request
    @param playerName string
    @return boolean
]]
function Companions:AcceptRequest(playerName)
    local data = GetCompanionData()
    if not data then return false end

    local request = data.incoming[playerName]
    if not request then
        HopeAddon:Print("No request from " .. playerName)
        return false
    end

    -- Add to companions
    data.list[playerName] = {
        since = time(),
        lastSeen = time(),
        class = request.class,
        level = request.level,
    }

    -- Remove from incoming
    data.incoming[playerName] = nil

    -- Send acceptance
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_ACC, UnitName("player"))
    end

    HopeAddon:Print(playerName .. " is now a companion!")

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayNotification()
    end

    return true
end

--[[
    Decline a companion request
    @param playerName string
]]
function Companions:DeclineRequest(playerName)
    local data = GetCompanionData()
    if not data then return end

    data.incoming[playerName] = nil

    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_DEC, UnitName("player"))
    end

    HopeAddon:Print("Declined companion request from " .. playerName)
end

--[[
    Remove a companion
    @param playerName string
]]
function Companions:RemoveCompanion(playerName)
    local data = GetCompanionData()
    if not data then return end

    data.list[playerName] = nil
    HopeAddon:Print(playerName .. " removed from companions")
end

--============================================================
-- NETWORK HANDLERS
--============================================================

function Companions:RegisterNetworkHandlers()
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then return end

    FellowTravelers:RegisterMessageCallback("Companions",
        function(msgType)
            return msgType == MSG_COMP_REQ or msgType == MSG_COMP_ACC or msgType == MSG_COMP_DEC
        end,
        function(msgType, sender, data)
            self:HandleMessage(msgType, sender, data)
        end
    )
end

function Companions:HandleMessage(msgType, sender, data)
    local compData = GetCompanionData()
    if not compData then return end

    if msgType == MSG_COMP_REQ then
        -- Incoming request
        local fellow = HopeAddon.FellowTravelers and HopeAddon.FellowTravelers:GetFellow(sender)
        compData.incoming[sender] = {
            timestamp = time(),
            class = fellow and fellow.class or "UNKNOWN",
            level = fellow and fellow.level or 70,
        }
        HopeAddon:Print("|cFFFFD700" .. sender .. "|r wants to be companions!")

        -- Trigger toast notification (Phase 4)
        if HopeAddon.SocialToasts then
            HopeAddon.SocialToasts:Show("companion_request", sender)
        end

        -- Play notification sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayNotification()
        end

    elseif msgType == MSG_COMP_ACC then
        -- Our request was accepted
        if compData.outgoing[sender] then
            local fellow = HopeAddon.FellowTravelers and HopeAddon.FellowTravelers:GetFellow(sender)
            compData.list[sender] = {
                since = time(),
                lastSeen = time(),
                class = fellow and fellow.class or "UNKNOWN",
                level = fellow and fellow.level or 70,
            }
            compData.outgoing[sender] = nil
            HopeAddon:Print("|cFF00FF00" .. sender .. "|r accepted your companion request!")

            -- Play notification sound
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayNotification()
            end
        end

    elseif msgType == MSG_COMP_DEC then
        -- Our request was declined
        compData.outgoing[sender] = nil
        HopeAddon:Print(sender .. " declined your companion request")
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Check if player is a companion
    @param playerName string
    @return boolean
]]
function Companions:IsCompanion(playerName)
    local data = GetCompanionData()
    return data and data.list[playerName] ~= nil
end

--[[
    Get all companions with online status
    @return table - Array of { name, class, level, since, isOnline, lastSeen, zone, selectedTitle }
]]
function Companions:GetAllCompanions()
    local data = GetCompanionData()
    if not data then return {} end

    local FellowTravelers = HopeAddon.FellowTravelers
    local result = {}
    local now = time()

    for name, info in pairs(data.list) do
        local fellow = FellowTravelers and FellowTravelers:GetFellow(name)
        local lastSeenTime = fellow and fellow.lastSeenTime or info.lastSeen or 0
        local isOnline = (now - lastSeenTime) < ONLINE_THRESHOLD

        table.insert(result, {
            name = name,
            class = fellow and fellow.class or info.class or "UNKNOWN",
            level = fellow and fellow.level or info.level or 70,
            since = info.since,
            isOnline = isOnline,
            lastSeen = lastSeenTime,
            zone = fellow and fellow.lastSeenZone or "Unknown",
            selectedTitle = fellow and fellow.selectedTitle,
        })
    end

    -- Sort: online first, then by name
    table.sort(result, function(a, b)
        if a.isOnline ~= b.isOnline then
            return a.isOnline
        end
        return a.name < b.name
    end)

    return result
end

--[[
    Get pending incoming requests
    @return table - Array of { name, class, level, timestamp }
]]
function Companions:GetIncomingRequests()
    local data = GetCompanionData()
    if not data then return {} end

    local result = {}
    local now = time()
    local expiry = REQUEST_EXPIRY_HOURS * 3600

    for name, info in pairs(data.incoming) do
        if (now - info.timestamp) < expiry then
            table.insert(result, {
                name = name,
                class = info.class,
                level = info.level,
                timestamp = info.timestamp,
            })
        else
            -- Clean up expired request
            data.incoming[name] = nil
        end
    end

    return result
end

--[[
    Get pending outgoing requests
    @return table - Array of { name, timestamp }
]]
function Companions:GetOutgoingRequests()
    local data = GetCompanionData()
    if not data then return {} end

    local result = {}
    local now = time()
    local expiry = REQUEST_EXPIRY_HOURS * 3600

    for name, info in pairs(data.outgoing) do
        if (now - info.timestamp) < expiry then
            table.insert(result, {
                name = name,
                timestamp = info.timestamp,
            })
        else
            -- Clean up expired request
            data.outgoing[name] = nil
        end
    end

    return result
end

--[[
    Get count of online companions
    @return number
]]
function Companions:GetOnlineCount()
    local companions = self:GetAllCompanions()
    local count = 0
    for _, comp in ipairs(companions) do
        if comp.isOnline then count = count + 1 end
    end
    return count
end

--[[
    Get total count of companions
    @return number
]]
function Companions:GetCount()
    local data = GetCompanionData()
    if not data then return 0 end

    local count = 0
    for _ in pairs(data.list) do count = count + 1 end
    return count
end

--[[
    Check if there are pending incoming requests
    @return boolean
]]
function Companions:HasPendingRequests()
    local requests = self:GetIncomingRequests()
    return #requests > 0
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function Companions:OnInitialize()
    GetCompanionData()  -- Ensure data structure
end

function Companions:OnEnable()
    self:RegisterNetworkHandlers()
    HopeAddon:Debug("Companions module enabled")
end

function Companions:OnDisable()
    if HopeAddon.FellowTravelers then
        HopeAddon.FellowTravelers:UnregisterMessageCallback("Companions")
    end
    HopeAddon:Debug("Companions module disabled")
end
