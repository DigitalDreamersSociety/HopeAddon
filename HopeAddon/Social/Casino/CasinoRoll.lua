--[[
    HopeAddon CasinoRoll
    Public /roll detection + validation for casino games (Roulette/Keno/Craps).

    Scope: detection only. No game logic, no UI, no escrow.
    A casino game module calls Expect() before the host types /roll N. The first
    valid roll (correct host, correct max) resolves the request. Everything else
    -- non-host rolls, wrong-size rolls, late rolls, duplicates -- is dropped.

    See plan: ~/.claude/plans/focus-this-window-only-greedy-papert.md
]]

local CasinoRoll = {}

--============================================================
-- CONSTANTS
--============================================================

-- enUS CHAT_MSG_SYSTEM format: "PlayerName rolls 37 (1-100)"
-- Lower bound forced to literal 1: hosts must use /roll N, never /roll M N.
CasinoRoll.PATTERN = "^(.+) rolls (%d+) %(1%-(%d+)%)$"

CasinoRoll.DEFAULT_TIMEOUT_SEC = 30

CasinoRoll.STATUS = {
    PENDING   = "PENDING",
    RESOLVED  = "RESOLVED",
    TIMEOUT   = "TIMEOUT",
    CANCELLED = "CANCELLED",
}

--============================================================
-- MODULE STATE
--============================================================

CasinoRoll.eventFrame = nil
CasinoRoll.pending = nil   -- single in-flight request, or nil

--============================================================
-- LIFECYCLE
--============================================================

function CasinoRoll:OnInitialize()
    HopeAddon:Debug("CasinoRoll initializing...")
end

function CasinoRoll:OnEnable()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
    self.eventFrame:SetScript("OnEvent", function(_, event, msg)
        if event == "CHAT_MSG_SYSTEM" then
            self:OnSystemMessage(msg)
        end
    end)
    HopeAddon:Debug("CasinoRoll enabled")
end

function CasinoRoll:OnDisable()
    if self.pending then
        self:Cancel(self.pending.requestId)
    end
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
end

--============================================================
-- PARSING (pure)
--============================================================

--[[
    Extract (name, result, max) from a CHAT_MSG_SYSTEM string.
    Returns nil for non-roll lines or out-of-bounds values.
    Pure: no state, no side effects.
]]
function CasinoRoll.ParseRoll(msg)
    if not msg then return nil end
    local name, result, max = msg:match(CasinoRoll.PATTERN)
    if not name then return nil end

    result = tonumber(result)
    max    = tonumber(max)
    if not result or not max then return nil end
    if max < 1 or result < 1 or result > max then return nil end

    -- Defensive realm strip; should not occur on Anniversary
    local dash = name:find("-", 1, true)
    if dash then name = name:sub(1, dash - 1) end

    return name, result, max
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Register a pending roll request. Only one may be active at a time.
    @param req table {
        requestId   = string,           -- opaque, returned in callback
        host        = string,           -- exact character name expected to roll
        expectedMax = number,           -- must equal max captured from system msg
        timeoutSec  = number|nil,       -- default DEFAULT_TIMEOUT_SEC
        onResolved  = function(outcome) -- called exactly once
    }
    @return true on success, or false, errorMsg on failure
]]
function CasinoRoll:Expect(req)
    if type(req) ~= "table" then
        return false, "req must be a table"
    end
    if not req.requestId or not req.host or not req.expectedMax or not req.onResolved then
        return false, "missing required field"
    end
    if self.pending then
        return false, "another roll request is already pending"
    end

    local timeoutSec = req.timeoutSec or self.DEFAULT_TIMEOUT_SEC

    local pending = {
        requestId   = req.requestId,
        host        = req.host,
        expectedMax = req.expectedMax,
        onResolved  = req.onResolved,
        status      = self.STATUS.PENDING,
        createdAt   = GetTime(),
    }

    pending.timer = HopeAddon.Timer:After(timeoutSec, function()
        if self.pending == pending and pending.status == CasinoRoll.STATUS.PENDING then
            self:Resolve(pending, CasinoRoll.STATUS.TIMEOUT, nil, nil, nil)
        end
    end)

    self.pending = pending
    HopeAddon:Debug(("CasinoRoll:Expect %s host=%s max=%d timeout=%ds"):format(
        req.requestId, req.host, req.expectedMax, timeoutSec))
    return true
end

--[[
    Cancel a pending request. No-op if requestId doesn't match the current pending.
]]
function CasinoRoll:Cancel(requestId)
    local p = self.pending
    if not p or p.requestId ~= requestId then return end
    if p.status ~= self.STATUS.PENDING then return end
    self:Resolve(p, self.STATUS.CANCELLED, nil, nil, nil)
end

function CasinoRoll:GetPending()
    return self.pending
end

--============================================================
-- INTERNAL
--============================================================

function CasinoRoll:OnSystemMessage(msg)
    local name, result, max = CasinoRoll.ParseRoll(msg)
    if not name then return end
    self:RouteRoll(name, result, max)
end

function CasinoRoll:RouteRoll(name, result, max)
    local p = self.pending
    if not p or p.status ~= self.STATUS.PENDING then return end
    if name ~= p.host then return end
    if max ~= p.expectedMax then return end

    self:Resolve(p, self.STATUS.RESOLVED, name, result, max)
end

function CasinoRoll:Resolve(pending, status, name, result, max)
    pending.status = status
    if pending.timer then
        pending.timer:Cancel()
        pending.timer = nil
    end
    if self.pending == pending then
        self.pending = nil
    end

    local outcome = {
        requestId = pending.requestId,
        status    = status,
        name      = name,
        result    = result,
        max       = max,
        at        = GetTime(),
    }

    -- Wrap callback so a buggy game module can't break the listener
    local ok, err = pcall(pending.onResolved, outcome)
    if not ok then
        HopeAddon:Debug("CasinoRoll onResolved error:", err)
    end
end

--============================================================
-- REGISTRATION
--============================================================

HopeAddon:RegisterModule("CasinoRoll", CasinoRoll)
HopeAddon.CasinoRoll = CasinoRoll

HopeAddon:Debug("CasinoRoll module loaded")
