--[[
    HopeAddon CommsAuthority

    Single chokepoint for outbound addon-message transport.

    Public surface:
      - CanSendToPlayer(name, msgType)              gate predicate
      - SendDirect(target, prefix, msgType, body)   gated WHISPER executor
      - Broadcast(prefix, msg, audience)            channel-ladder broadcast
      - IsInInstanceGroup() / IsInRealRaid() / IsInRealParty() / IsNameInOurGroup(name)

    First migration target: FellowTravelers. Other addon-message senders
    (GameComms, Attunements survey, etc.) are NOT migrated yet and continue
    to use their own transports.

    Distinct from Core/BehaviorPolicy.lua: BehaviorPolicy is the chat-whisper
    gate (hostile-whisperer storms, justified-target evidence). CommsAuthority
    is the addon-message transport layer.
]]

local CommsAuthority = {}

--============================================================
-- TRANSPORT (file-local)
--============================================================

local CachedSendAddonMessage = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage

-- pcall-wrapped send: silently swallows raid-disband / leaving-BG edge cases.
-- Note: this does NOT suppress "player not present" system messages - those
-- are emitted by the game post-send and must be prevented at the gate.
local function SafeSend(prefix, msg, channel, target)
    if not CachedSendAddonMessage then return end
    local ok, err = pcall(CachedSendAddonMessage, prefix, msg, channel, target)
    if not ok and HopeAddon and HopeAddon.db and HopeAddon.db.debug then
        HopeAddon:Debug("CommsAuthority send failed:", channel, err)
    end
end

--============================================================
-- STATE (session-only)
--============================================================

CommsAuthority.yellCounter = 0  -- 1:2 throttle for "presence" audience YELLs

--============================================================
-- CONTEXT HELPERS
--============================================================

-- True for battlegrounds, arenas, and dungeons - all use INSTANCE_CHAT.
function CommsAuthority:IsInInstanceGroup()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    return instanceType == "pvp" or instanceType == "arena" or instanceType == "party"
end

-- True only for a real raid (not a BG raid). GetRealNumRaidMembers returns 0 in BGs.
function CommsAuthority:IsInRealRaid()
    if self:IsInInstanceGroup() then return false end
    if GetRealNumRaidMembers then
        return GetRealNumRaidMembers() > 0
    end
    return IsInRaid()
end

-- True only for a real party (not a BG party).
function CommsAuthority:IsInRealParty()
    if self:IsInInstanceGroup() then return false end
    if GetRealNumPartyMembers then
        return GetRealNumPartyMembers() > 0
    end
    return IsInGroup() and not IsInRaid()
end

-- True if `playerName` (short name or "Name-Realm") is in our current party/raid.
-- Used to gate WHISPERs in PvP instances where opponents are not whisperable.
function CommsAuthority:IsNameInOurGroup(playerName)
    if not playerName or playerName == "" then return false end
    local queryName = playerName:match("^([^-]+)") or playerName
    local n = GetNumGroupMembers() or 0
    if n == 0 then return false end
    local prefix = IsInRaid() and "raid" or "party"
    local count = IsInRaid() and n or (n - 1)
    for i = 1, count do
        local memberName = UnitName(prefix .. i)
        if memberName == queryName then return true end
    end
    return false
end

--============================================================
-- GATE
--============================================================

-- Decide whether an outbound WHISPER addon-message to `name` is allowed.
-- @param name    string - target player name
-- @param msgType string - protocol message type (debug-only today)
-- @return bool ok, string|nil denyReason
function CommsAuthority:CanSendToPlayer(name, msgType)
    if not name or name == "" then return false, "empty-name" end

    -- Arena/BG opponents are not whisperable - sending produces a
    -- "player not present" system message per attempt.
    local _, instanceType = IsInInstance()
    if instanceType == "arena" or instanceType == "pvp" then
        if not self:IsNameInOurGroup(name) then
            return false, "pvp-instance-not-in-group"
        end
    end

    return true
end

--============================================================
-- EXECUTORS
--============================================================

-- Gated WHISPER send. Caller is responsible for the wire format of `body`.
-- @return bool sent
function CommsAuthority:SendDirect(target, prefix, msgType, body)
    local ok, denyReason = self:CanSendToPlayer(target, msgType)
    if not ok then
        if HopeAddon and HopeAddon.db and HopeAddon.db.debug then
            HopeAddon:Debug("CommsAuthority:SendDirect denied", target, msgType, denyReason)
        end
        return false
    end
    SafeSend(prefix, body, "WHISPER", target)
    return true
end

-- Channel-ladder broadcast.
-- @param audience "presence" - YELLs every other call (matches BroadcastPresence pattern)
--                 "message"  - YELLs every call (matches BroadcastMessage pattern)
function CommsAuthority:Broadcast(prefix, msg, audience)
    local inInstance  = self:IsInInstanceGroup()
    local inRealRaid  = self:IsInRealRaid()
    local inRealParty = self:IsInRealParty()

    if inInstance then
        SafeSend(prefix, msg, "INSTANCE_CHAT")
    elseif inRealRaid then
        SafeSend(prefix, msg, "RAID")
    elseif inRealParty then
        SafeSend(prefix, msg, "PARTY")
    end

    if IsInGuild() then
        SafeSend(prefix, msg, "GUILD")
    end

    if not inInstance and not inRealRaid then
        if audience == "presence" then
            self.yellCounter = self.yellCounter + 1
            if self.yellCounter % 2 == 0 then
                SafeSend(prefix, msg, "YELL")
            end
        else
            SafeSend(prefix, msg, "YELL")
        end
    end
end

--============================================================
-- LIFECYCLE
--============================================================

function CommsAuthority:OnInitialize()
    if HopeAddon and HopeAddon.Debug then
        HopeAddon:Debug("CommsAuthority initializing...")
    end
end

--============================================================
-- REGISTER WITH ADDON
--============================================================

if HopeAddon and HopeAddon.RegisterModule then
    HopeAddon:RegisterModule("CommsAuthority", CommsAuthority)
end
HopeAddon = HopeAddon or {}
HopeAddon.CommsAuthority = CommsAuthority

if HopeAddon.Debug then HopeAddon:Debug("CommsAuthority module loaded") end
