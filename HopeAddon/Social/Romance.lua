--[[
    HopeAddon Romance Module
    "Azeroth Relationship Status" - Public, exclusive romantic relationship system

    Like Facebook relationship status for WoW RP players:
    - One partner at a time (exclusive)
    - Public status visible to all Fellow Travelers
    - Proposal/Accept/Decline flow
    - Breakups create timeline events
    - 24-hour cooldown after rejection

    Network Protocol (via WHISPER - not throttled):
    - ROM_REQ: Send romantic proposal
    - ROM_ACC: Accept proposal
    - ROM_DEC: Decline proposal
    - ROM_BRK: Break up
]]

local Romance = {}
HopeAddon.Romance = Romance
HopeAddon:RegisterModule("Romance", Romance)

--============================================================
-- CONSTANTS
--============================================================

local C = HopeAddon.Constants

-- Message type shortcuts
local MSG_REQUEST = "ROM_REQ"
local MSG_ACCEPT = "ROM_ACC"
local MSG_DECLINE = "ROM_DEC"
local MSG_BREAKUP = "ROM_BRK"

-- Status shortcuts
local STATUS_SINGLE = "SINGLE"
local STATUS_PROPOSED = "PROPOSED"
local STATUS_DATING = "DATING"

-- Timing
local REJECTION_COOLDOWN = 86400  -- 24 hours
local REQUEST_EXPIRY = 604800     -- 7 days

-- Data limits
local MAX_HISTORY_ENTRIES = 100   -- Maximum relationship history entries to prevent unbounded growth

--============================================================
-- MODULE STATE
--============================================================

Romance.eventFrame = nil

--============================================================
-- DATA HELPERS
--============================================================

--[[
    Get romance data with automatic initialization
    @return table - The romance data table
]]
local function GetRomanceData()
    return HopeAddon:GetSocialRomance()
end

--[[
    Add entry to romance history with size limit
    Removes oldest entries when limit exceeded
    @param data table - Romance data table
    @param entry table - History entry to add
]]
local function AddHistoryEntry(data, entry)
    data.history = data.history or {}
    table.insert(data.history, entry)

    -- Limit history size to prevent unbounded growth
    while #data.history > MAX_HISTORY_ENTRIES do
        table.remove(data.history, 1)  -- Remove oldest
    end
end

--[[
    Check if a player is on rejection cooldown
    @param playerName string
    @return boolean, number - On cooldown, seconds remaining
]]
function Romance:IsOnCooldown(playerName)
    local data = GetRomanceData()
    if not data or not data.cooldowns then return false, 0 end

    local cooldownEnd = data.cooldowns[playerName]
    if not cooldownEnd then return false, 0 end

    local now = time()
    if now >= cooldownEnd then
        data.cooldowns[playerName] = nil
        return false, 0
    end

    return true, cooldownEnd - now
end

--[[
    Set rejection cooldown for a player
    @param playerName string
]]
local function SetCooldown(playerName)
    local data = GetRomanceData()
    if not data then return end

    data.cooldowns = data.cooldowns or {}
    data.cooldowns[playerName] = time() + REJECTION_COOLDOWN
end

--[[
    Clean up expired requests and cooldowns
]]
function Romance:CleanupExpired()
    local data = GetRomanceData()
    if not data then return end

    local now = time()

    -- Clean expired incoming requests
    if data.pendingIncoming then
        for name, info in pairs(data.pendingIncoming) do
            if info.timestamp and (now - info.timestamp) > REQUEST_EXPIRY then
                data.pendingIncoming[name] = nil
                HopeAddon:Debug("Romance: Expired request from", name)
            end
        end
    end

    -- Clean expired outgoing request
    if data.pendingOutgoing and data.pendingOutgoing.timestamp then
        if (now - data.pendingOutgoing.timestamp) > REQUEST_EXPIRY then
            data.pendingOutgoing = nil
            data.status = STATUS_SINGLE
            HopeAddon:Debug("Romance: Expired outgoing request")
        end
    end

    -- Clean expired cooldowns
    if data.cooldowns then
        for name, cooldownEnd in pairs(data.cooldowns) do
            if now >= cooldownEnd then
                data.cooldowns[name] = nil
            end
        end
    end
end

--[[
    Sync romance status to FellowTravelers profile for broadcasting
]]
local function SyncToProfile()
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then return end

    local data = GetRomanceData()
    local status = data and data.status or STATUS_SINGLE
    local partner = data and data.partner or nil

    FellowTravelers:UpdateMyProfile({
        romanceStatus = status,
        romancePartner = partner,
    })

    HopeAddon:Debug("Romance: Synced status to profile -", status, partner or "none")
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Get current romance status
    @return table - { status, partner, since, pendingOutgoing, pendingIncoming }
]]
function Romance:GetStatus()
    local data = GetRomanceData()
    if not data then
        return { status = STATUS_SINGLE }
    end

    return {
        status = data.status or STATUS_SINGLE,
        partner = data.partner,
        since = data.since,
        pendingOutgoing = data.pendingOutgoing,
        pendingIncoming = data.pendingIncoming or {},
    }
end

--[[
    Check if player is available for romance (single or not proposed)
    @return boolean
]]
function Romance:IsAvailable()
    local data = GetRomanceData()
    if not data then return true end
    return data.status == STATUS_SINGLE and not data.pendingOutgoing
end

--[[
    Check if currently dating someone
    @return boolean, string|nil - Is dating, partner name
]]
function Romance:IsDating()
    local data = GetRomanceData()
    if not data then return false, nil end
    return data.status == STATUS_DATING, data.partner
end

--[[
    Get partner info if dating
    @return table|nil - Partner info from FellowTravelers
]]
function Romance:GetPartnerInfo()
    local data = GetRomanceData()
    if not data or data.status ~= STATUS_DATING or not data.partner then
        return nil
    end

    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        return FellowTravelers:GetFellow(data.partner)
    end
    return nil
end

--[[
    Check if we have a pending incoming request from a player
    @param playerName string
    @return boolean
]]
function Romance:HasRequestFrom(playerName)
    local data = GetRomanceData()
    if not data or not data.pendingIncoming then return false end
    return data.pendingIncoming[playerName] ~= nil
end

--[[
    Get all pending incoming requests
    @return table - Array of { name, timestamp, class, level }
]]
function Romance:GetIncomingRequests()
    local data = GetRomanceData()
    if not data or not data.pendingIncoming then return {} end

    local result = {}
    for name, info in pairs(data.pendingIncoming) do
        table.insert(result, {
            name = name,
            timestamp = info.timestamp,
            class = info.class,
            level = info.level,
        })
    end

    -- Sort by timestamp (newest first)
    table.sort(result, function(a, b) return a.timestamp > b.timestamp end)
    return result
end

--[[
    Get relationship history (past relationships)
    @return table - Array of { partner, started, ended, reason, duration }
]]
function Romance:GetRelationshipHistory()
    local data = GetRomanceData()
    if not data or not data.history then return {} end

    local result = {}
    for _, relationship in ipairs(data.history) do
        -- Only include ended relationships
        if relationship.ended then
            local duration = relationship.ended - relationship.started
            table.insert(result, {
                partner = relationship.partner,
                started = relationship.started,
                ended = relationship.ended,
                reason = relationship.reason or "mutual",
                duration = duration,
            })
        end
    end

    -- Sort by ended date (newest first)
    table.sort(result, function(a, b) return a.ended > b.ended end)
    return result
end

--[[
    Format duration as human-readable string
    @param seconds number - Duration in seconds
    @return string - Formatted duration
]]
function Romance:FormatDuration(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)

    if days > 0 then
        if days == 1 then
            return "1 day"
        else
            return days .. " days"
        end
    elseif hours > 0 then
        if hours == 1 then
            return "1 hour"
        else
            return hours .. " hours"
        end
    else
        return "Less than an hour"
    end
end

--============================================================
-- ROMANCE ACTIONS
--============================================================

--[[
    Send a romantic proposal to a player
    @param targetName string - Player to propose to
    @return boolean, string - Success, error message
]]
function Romance:ProposeToPlayer(targetName)
    if not targetName or targetName == "" then
        return false, "Invalid player name"
    end

    -- Can't propose to yourself
    if targetName == UnitName("player") then
        return false, "You can't date yourself... or can you?"
    end

    local data = GetRomanceData()
    if not data then
        return false, "Romance data not available"
    end

    -- Check if already dating
    if data.status == STATUS_DATING then
        return false, "You're already in a relationship with " .. (data.partner or "someone") .. "!"
    end

    -- Check if already proposed to someone
    if data.pendingOutgoing then
        return false, "You already have a pending proposal to " .. data.pendingOutgoing.to
    end

    -- Check rejection cooldown
    local onCooldown, remaining = self:IsOnCooldown(targetName)
    if onCooldown then
        local hours = math.ceil(remaining / 3600)
        return false, targetName .. " needs more time. Try again in " .. hours .. " hour(s)."
    end

    -- Check if they're a Fellow Traveler (has the addon)
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers or not FellowTravelers:IsFellow(targetName) then
        return false, targetName .. " doesn't have HopeAddon. They need it to receive your proposal!"
    end

    -- Send the proposal
    local timestamp = time()
    FellowTravelers:SendDirectMessage(targetName, MSG_REQUEST, tostring(timestamp))

    -- Store pending outgoing
    data.pendingOutgoing = {
        to = targetName,
        timestamp = timestamp,
    }
    data.status = STATUS_PROPOSED

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    -- Broadcast to activity feed
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:OnRomanceEvent("PROPOSED", targetName)
    end

    HopeAddon:Print("|cFFFF69B4<3 You proposed to " .. targetName .. "!|r Waiting for their response...")
    return true
end

--[[
    Accept a romantic proposal
    @param senderName string - Player who proposed
    @return boolean, string - Success, error message
]]
function Romance:AcceptProposal(senderName)
    local data = GetRomanceData()
    if not data then
        return false, "Romance data not available"
    end

    -- Check if we have a request from them
    if not data.pendingIncoming or not data.pendingIncoming[senderName] then
        return false, "No proposal from " .. senderName
    end

    -- Check if already dating someone else
    if data.status == STATUS_DATING and data.partner ~= senderName then
        return false, "You're already dating " .. (data.partner or "someone") .. "! Break up first."
    end

    -- Accept!
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(senderName, MSG_ACCEPT, tostring(time()))
    end

    -- Clear incoming request
    data.pendingIncoming[senderName] = nil

    -- Clear any outgoing we had
    data.pendingOutgoing = nil

    -- Set as dating
    data.status = STATUS_DATING
    data.partner = senderName
    data.since = time()

    -- Add to history (with size limit)
    AddHistoryEntry(data, {
        partner = senderName,
        started = time(),
        ended = nil,
        reason = nil,
    })

    -- Play celebration sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    -- Broadcast to activity feed
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:OnRomanceEvent("DATING", senderName)
    end

    -- Toast notification
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("romance_accepted", senderName)
    end

    -- Sync to profile for broadcasting
    SyncToProfile()

    HopeAddon:Print("|cFFFF1493<3 You and " .. senderName .. " are now dating!|r")
    return true
end

--[[
    Decline a romantic proposal
    @param senderName string - Player who proposed
    @return boolean, string - Success, error message
]]
function Romance:DeclineProposal(senderName)
    local data = GetRomanceData()
    if not data then
        return false, "Romance data not available"
    end

    -- Check if we have a request from them
    if not data.pendingIncoming or not data.pendingIncoming[senderName] then
        return false, "No proposal from " .. senderName
    end

    -- Send decline
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(senderName, MSG_DECLINE, tostring(time()))
    end

    -- Clear the request
    data.pendingIncoming[senderName] = nil

    -- Reset status if we were only pending
    if data.status == STATUS_PROPOSED and not data.pendingOutgoing then
        data.status = STATUS_SINGLE
    end

    HopeAddon:Print("You declined " .. senderName .. "'s proposal.")
    return true
end

--[[
    Break up with current partner
    @param reason string|nil - Breakup reason (from C.ROMANCE_TIMINGS.BREAKUP_REASONS)
    @return boolean, string - Success, error message
]]
function Romance:BreakUp(reason)
    local data = GetRomanceData()
    if not data then
        return false, "Romance data not available"
    end

    if data.status ~= STATUS_DATING or not data.partner then
        return false, "You're not dating anyone!"
    end

    local exPartner = data.partner
    reason = reason or "mutual"

    -- Send breakup notification
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(exPartner, MSG_BREAKUP, reason)
    end

    -- Update history
    if data.history and #data.history > 0 then
        local lastRelationship = data.history[#data.history]
        if lastRelationship.partner == exPartner and not lastRelationship.ended then
            lastRelationship.ended = time()
            lastRelationship.reason = reason
        end
    end

    -- Reset status
    data.status = STATUS_SINGLE
    data.partner = nil
    data.since = nil

    -- Play sad sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayError()
    end

    -- Broadcast to activity feed
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:OnRomanceEvent("BREAKUP", exPartner, reason)
    end

    -- Sync to profile for broadcasting
    SyncToProfile()

    local reasonText = C.BREAKUP_REASON_TEXT and C.BREAKUP_REASON_TEXT[reason] or "It's over."
    HopeAddon:Print("|cFF808080</3 You and " .. exPartner .. " broke up. " .. reasonText .. "|r")
    return true
end

--[[
    Cancel an outgoing proposal
    @return boolean, string - Success, error message
]]
function Romance:CancelProposal()
    local data = GetRomanceData()
    if not data then
        return false, "Romance data not available"
    end

    if not data.pendingOutgoing then
        return false, "No pending proposal to cancel"
    end

    local target = data.pendingOutgoing.to
    data.pendingOutgoing = nil
    data.status = STATUS_SINGLE

    HopeAddon:Print("Cancelled proposal to " .. target)
    return true
end

--============================================================
-- NETWORK HANDLERS
--============================================================

--[[
    Register message callbacks with FellowTravelers
]]
function Romance:RegisterNetworkHandlers()
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then return end

    FellowTravelers:RegisterMessageCallback("Romance",
        function(msgType)
            return msgType == MSG_REQUEST or
                   msgType == MSG_ACCEPT or
                   msgType == MSG_DECLINE or
                   msgType == MSG_BREAKUP
        end,
        function(msgType, sender, data)
            self:HandleMessage(msgType, sender, data)
        end
    )

    HopeAddon:Debug("Romance: Network handlers registered")
end

--[[
    Handle incoming romance messages
    @param msgType string - Message type
    @param sender string - Sender name
    @param msgData string - Message data
]]
function Romance:HandleMessage(msgType, sender, msgData)
    local data = GetRomanceData()
    if not data then return end

    HopeAddon:Debug("Romance: Received", msgType, "from", sender)

    if msgType == MSG_REQUEST then
        self:HandleProposalReceived(sender, msgData)

    elseif msgType == MSG_ACCEPT then
        self:HandleProposalAccepted(sender, msgData)

    elseif msgType == MSG_DECLINE then
        self:HandleProposalDeclined(sender, msgData)

    elseif msgType == MSG_BREAKUP then
        self:HandleBreakupReceived(sender, msgData)
    end
end

--[[
    Handle receiving a proposal
    @param sender string
    @param msgData string - Timestamp
]]
function Romance:HandleProposalReceived(sender, msgData)
    local data = GetRomanceData()
    if not data then return end

    -- If we're already dating someone, ignore
    if data.status == STATUS_DATING then
        HopeAddon:Debug("Romance: Ignoring proposal from", sender, "- already dating")
        return
    end

    -- Get sender info from FellowTravelers
    local FellowTravelers = HopeAddon.FellowTravelers
    local fellow = FellowTravelers and FellowTravelers:GetFellow(sender)

    -- Store incoming request
    data.pendingIncoming = data.pendingIncoming or {}
    data.pendingIncoming[sender] = {
        timestamp = tonumber(msgData) or time(),
        class = fellow and fellow.class or "UNKNOWN",
        level = fellow and fellow.level or 70,
    }

    -- Play romantic sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    -- Show toast
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("romance_proposal", sender)
    end

    HopeAddon:Print("|cFFFF69B4<3 " .. sender .. " wants to date you!|r Type /hope romance accept " .. sender .. " or /hope romance decline " .. sender)
end

--[[
    Handle our proposal being accepted
    @param sender string - The person who accepted
    @param msgData string - Timestamp
]]
function Romance:HandleProposalAccepted(sender, msgData)
    local data = GetRomanceData()
    if not data then return end

    -- Verify this was our pending proposal
    if not data.pendingOutgoing or data.pendingOutgoing.to ~= sender then
        HopeAddon:Debug("Romance: Got accept from", sender, "but no pending proposal to them")
        return
    end

    -- Clear pending
    data.pendingOutgoing = nil

    -- Set as dating!
    data.status = STATUS_DATING
    data.partner = sender
    data.since = time()

    -- Add to history (with size limit)
    AddHistoryEntry(data, {
        partner = sender,
        started = time(),
        ended = nil,
        reason = nil,
    })

    -- Celebration!
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    -- Broadcast to activity feed
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:OnRomanceEvent("DATING", sender)
    end

    -- Toast
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("romance_accepted", sender)
    end

    -- Sync to profile for broadcasting
    SyncToProfile()

    HopeAddon:Print("|cFFFF1493<3 " .. sender .. " accepted! You're now dating!|r")
end

--[[
    Handle our proposal being declined
    @param sender string - The person who declined
    @param msgData string - Timestamp
]]
function Romance:HandleProposalDeclined(sender, msgData)
    local data = GetRomanceData()
    if not data then return end

    -- Verify this was our pending proposal
    if not data.pendingOutgoing or data.pendingOutgoing.to ~= sender then
        return
    end

    -- Clear pending
    data.pendingOutgoing = nil
    data.status = STATUS_SINGLE

    -- Set cooldown
    SetCooldown(sender)

    -- Sad sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayError()
    end

    -- Toast
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("romance_declined", sender)
    end

    HopeAddon:Print("|cFF808080</3 " .. sender .. " declined your proposal.|r Better luck next time!")
end

--[[
    Handle being broken up with
    @param sender string - The person breaking up with us
    @param msgData string - Reason
]]
function Romance:HandleBreakupReceived(sender, msgData)
    local data = GetRomanceData()
    if not data then return end

    -- Verify we were dating them
    if data.status ~= STATUS_DATING or data.partner ~= sender then
        HopeAddon:Debug("Romance: Got breakup from", sender, "but not dating them")
        return
    end

    local reason = msgData or "mutual"

    -- Update history
    if data.history and #data.history > 0 then
        local lastRelationship = data.history[#data.history]
        if lastRelationship.partner == sender and not lastRelationship.ended then
            lastRelationship.ended = time()
            lastRelationship.reason = reason
        end
    end

    -- Reset status
    data.status = STATUS_SINGLE
    data.partner = nil
    data.since = nil

    -- Sad sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayError()
    end

    -- Broadcast to activity feed
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:OnRomanceEvent("BREAKUP", sender, reason)
    end

    -- Toast
    if HopeAddon.SocialToasts then
        HopeAddon.SocialToasts:Show("romance_breakup", sender)
    end

    -- Sync to profile for broadcasting
    SyncToProfile()

    local reasonText = C.BREAKUP_REASON_TEXT and C.BREAKUP_REASON_TEXT[reason] or "It's over."
    HopeAddon:Print("|cFF808080</3 " .. sender .. " broke up with you. " .. reasonText .. "|r")
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function Romance:OnInitialize()
    -- Ensure data structure exists
    GetRomanceData()
end

function Romance:OnEnable()
    -- Register network handlers
    self:RegisterNetworkHandlers()

    -- Cleanup expired data
    self:CleanupExpired()

    -- Sync current status to profile (in case player logs in while dating)
    SyncToProfile()

    HopeAddon:Debug("Romance module enabled")
end

function Romance:OnDisable()
    -- Unregister network handlers
    if HopeAddon.FellowTravelers then
        HopeAddon.FellowTravelers:UnregisterMessageCallback("Romance")
    end

    HopeAddon:Debug("Romance module disabled")
end
