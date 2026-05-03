--[[
    HopeAddon BehaviorPolicy
    Central place to ask "should this automation fire?".

    Phase 1 scope (this file is intentionally small):
      - Context()              minimal context probe (combat / arena / BG / instance)
      - NoteInboundWhisper()   record someone whispered us (justified-target evidence)
      - CanSendToPlayer()      gate for outbound whispers (and, later, addon comms)

    No SavedVariables. Session-only state. Not yet wired to UI restore /
    FellowTravelers / GameComms - those come in later phases.

    Failure addressed by phase 1: F-spam (RouletteSlice.lua hostile-whisperer
    rejection storms - any unknown sender could trigger unbounded outbound
    rejection whispers).
]]

local BehaviorPolicy = {}

--============================================================
-- CONSTANTS
--============================================================

-- Per-kind outbound cooldowns (seconds). Tuned to be invisible to legitimate
-- traffic while breaking flood loops.
local COOLDOWN = {
    WHISPER_REPLY    = 2,    -- replying to someone who whispered us
    WHISPER_HOST_RPC = 1,    -- player-initiated whisper to a host (e.g. /cs join, /cs bet)
}

-- Inbound whisper "freshness" window. After this, replies to that name
-- are no longer treated as responsive.
local KNOWN_WHISPER_TTL_SEC = 300

--============================================================
-- STATE (session-only, not persisted)
--============================================================

BehaviorPolicy.state = {
    recentSends            = {},   -- [kind][name] = sendTime
    knownInboundWhisperers = {},   -- [name]       = lastSeenTime
}

--============================================================
-- LIFECYCLE
--============================================================

function BehaviorPolicy:OnInitialize()
    if HopeAddon and HopeAddon.Debug then
        HopeAddon:Debug("BehaviorPolicy initializing...")
    end
end

function BehaviorPolicy:OnEnable()
    -- Listen for incoming whispers ourselves so callers don't have to
    -- explicitly call NoteInboundWhisper everywhere.
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
    self.eventFrame:SetScript("OnEvent", function(_, event, _msg, sender)
        if event == "CHAT_MSG_WHISPER" and sender then
            self:NoteInboundWhisper(sender)
        end
    end)
end

function BehaviorPolicy:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
    wipe(self.state.recentSends)
    wipe(self.state.knownInboundWhisperers)
end

--============================================================
-- CONTEXT
--============================================================

--[[
    Compute the current player context. On-demand (no cache yet - cache is
    a phase-2 concern when more gates start consulting Context).
    @return table {
        inCombat, inArena, inBG, inInstanceGroup, lockedDown
    }
]]
function BehaviorPolicy:Context()
    local inCombat = (InCombatLockdown and InCombatLockdown()) or false
    local inArena, inBG, inInstanceGroup = false, false, false

    if IsInInstance then
        local _, instanceType = IsInInstance()
        if instanceType == "arena" then
            inArena, inInstanceGroup = true, true
        elseif instanceType == "pvp" then
            inBG, inInstanceGroup = true, true
        elseif instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
            inInstanceGroup = true
        end
    end

    return {
        inCombat        = inCombat,
        inArena         = inArena,
        inBG            = inBG,
        inInstanceGroup = inInstanceGroup,
        lockedDown      = inCombat,
    }
end

--============================================================
-- INBOUND WHISPER TRACKING
--============================================================

--[[
    Record that `name` whispered us. Used as evidence that future
    WHISPER_REPLY traffic to that name is responsive, not unsolicited.

    Called automatically from OnEnable's CHAT_MSG_WHISPER handler; also
    exposed publicly so callers can prime it explicitly if needed.
]]
function BehaviorPolicy:NoteInboundWhisper(name)
    if not name or name == "" then return end
    self.state.knownInboundWhisperers[name] = GetTime()
end

--============================================================
-- SEND GATE
--============================================================

--[[
    Decide whether an outbound chat/addon message to `name` is allowed.
    On ok=true the gate also marks the send time, so an immediate
    follow-up call to the same target rate-limits.

    @param name  string  - target player name (raw form is fine; whatever
                           the caller has is whatever was stored from the
                           inbound whisper event)
    @param ctx   table   - { kind = "WHISPER_REPLY" | "WHISPER_HOST_RPC" }
                           kind defaults to "WHISPER_REPLY"
    @return ok boolean, reason string|nil
]]
function BehaviorPolicy:CanSendToPlayer(name, ctx)
    if not name or name == "" then return false, "empty name" end

    -- Self-whispers are always allowed: they cannot be spam (only we receive them)
    -- and the slice's host self-betting flow uses a self-whisper to display the
    -- "Bet locked" confirmation. No inbound check, no cooldown, no mark.
    if name == UnitName("player") then return true end

    local kind = (ctx and ctx.kind) or "WHISPER_REPLY"
    local cooldown = COOLDOWN[kind] or 1
    local now = GetTime()

    -- Cooldown
    local kindSends = self.state.recentSends[kind]
    if kindSends and kindSends[name] then
        if (now - kindSends[name]) < cooldown then
            return false, "cooldown"
        end
    end

    -- Justified-target check (kind-specific)
    if kind == "WHISPER_REPLY" then
        local lastIn = self.state.knownInboundWhisperers[name]
        if not lastIn or (now - lastIn) > KNOWN_WHISPER_TTL_SEC then
            return false, "no recent inbound whisper from target"
        end
    end
    -- WHISPER_HOST_RPC: no further check; user explicitly initiated.

    -- Mark sent
    if not self.state.recentSends[kind] then
        self.state.recentSends[kind] = {}
    end
    self.state.recentSends[kind][name] = now

    return true
end

--============================================================
-- REGISTER WITH ADDON
--============================================================

if HopeAddon and HopeAddon.RegisterModule then
    HopeAddon:RegisterModule("BehaviorPolicy", BehaviorPolicy)
end
HopeAddon = HopeAddon or {}
HopeAddon.BehaviorPolicy = BehaviorPolicy

if HopeAddon.Debug then HopeAddon:Debug("BehaviorPolicy module loaded") end
