--[[
    HopeAddon Roulette Slice
    Vertical slice — proves the casino loop end-to-end before any shared
    layer is built. Plan: ~/.claude/plans/casino-vertical-slice.md.

    Scope: European single-zero Roulette, Straight Up bets only,
    1-100g stakes, host runs /roll 37, auto-settles on roll capture.
    Players whisper /cs bet to the host. No GameComms, no escrow, no UI.
    /reload ends the table.

    Slash command: /cs (Casino Slice)
]]

--============================================================
-- CONSTANTS
--============================================================

local WHEEL_POCKETS = 37
local MIN_STAKE_GOLD = 1
local MAX_STAKE_GOLD = 100
local PAYOUT_RATIO = 35           -- winnings = stake * 35; total returned = stake * 36
local HISTORY_KEEP = 10
local PREFIX = "[Casino] "

-- European red pockets (cosmetic display only - not used for resolution)
local RED_NUMBERS = {
    [1]=true,[3]=true,[5]=true,[7]=true,[9]=true,[12]=true,
    [14]=true,[16]=true,[18]=true,[19]=true,[21]=true,[23]=true,
    [25]=true,[27]=true,[30]=true,[32]=true,[34]=true,[36]=true,
}

local function NumberColor(n)
    if n == 0 then return "GREEN" end
    return RED_NUMBERS[n] and "RED" or "BLACK"
end

--============================================================
-- MODULE
--============================================================

local RouletteSlice = {}

-- Host-side authoritative state. nil when not hosting.
local HostTable = nil

-- Player-side state. nil when not joined to any table.
local PlayerSession = nil

-- Most recently observed table-open broadcast (so /cs join knows where to go)
local LastSeenHost = nil

--============================================================
-- OUTPUT HELPERS
--============================================================

local function PrintLocal(msg)
    if HopeAddon and HopeAddon.Print then
        HopeAddon:Print(msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
    end
end

local function BroadcastGuild(msg)
    -- Default off: prefer /say to avoid spamming guild chat during testing.
    -- Host can pass `guild` arg to /cs open to switch to guild chat.
    local channel = (HostTable and HostTable.broadcastChannel) or "SAY"
    pcall(SendChatMessage, PREFIX .. msg, channel)
end

local function WhisperPlayer(name, msg)
    if not name or name == "" or not msg then return end

    -- Gate via BehaviorPolicy if loaded. Enforces:
    --   - per-target cooldown so a hostile whisperer cannot trigger
    --     unbounded rejection-reply storms
    --   - WHISPER_REPLY: only reply to someone who recently whispered us
    --   - WHISPER_HOST_RPC: player-initiated, no inbound check
    -- Heuristic: outbound /cs ... is host-RPC; everything else is a reply.
    local Policy = HopeAddon and HopeAddon.GetModule and HopeAddon:GetModule("BehaviorPolicy")
    if Policy and Policy.CanSendToPlayer then
        local kind = (msg:sub(1, 3) == "/cs") and "WHISPER_HOST_RPC" or "WHISPER_REPLY"
        local ok = Policy:CanSendToPlayer(name, { kind = kind })
        if not ok then return end
    end

    pcall(SendChatMessage, PREFIX .. msg, "WHISPER", nil, name)
end

local function FormatWithColor(n)
    local color = NumberColor(n)
    if color == "RED"   then return ("|cFFFF5555%d|r"):format(n) end
    if color == "BLACK" then return ("|cFFCCCCCC%d|r"):format(n) end
    return ("|cFF55FF55%d|r"):format(n)
end

--============================================================
-- VALIDATION
--============================================================

local function ValidateNumber(s)
    local n = tonumber(s)
    if not n or n ~= math.floor(n) then return nil, "number must be 0-36." end
    if n < 0 or n > 36 then return nil, "number must be 0-36." end
    return n
end

local function ValidateStake(s)
    local n = tonumber(s)
    if not n or n ~= math.floor(n) then return nil, "stake must be 1-100 gold." end
    if n < MIN_STAKE_GOLD or n > MAX_STAKE_GOLD then
        return nil, ("stake must be %d-%d gold."):format(MIN_STAKE_GOLD, MAX_STAKE_GOLD)
    end
    return n
end

--============================================================
-- HOST: TABLE LIFECYCLE
--============================================================

local function HostName()
    return UnitName("player")
end

local function StartNewRound(roundN)
    HostTable.round = {
        n = roundN or ((HostTable.round and HostTable.round.n or 0) + 1),
        state = "BETS_OPEN",
        bets = {},               -- [playerName] = { number, stake, placedAt, status }
        winningNumber = nil,
        payouts = nil,
    }
end

local function Cmd_Open(arg)
    if HostTable and HostTable.active then
        PrintLocal("|cFFFFAA00You already have a table open. /cs close it first.|r")
        return
    end
    HostTable = {
        active = true,
        host = HostName(),
        broadcastChannel = (arg == "guild") and "GUILD" or "SAY",
        history = {},
    }
    StartNewRound(1)

    BroadcastGuild(("%s opened a Roulette table. Whisper \"/cs join\" to play, then \"/cs bet <0-36> <gold>\" to bet."):format(HostTable.host))
    PrintLocal(("|cFF55FF55Table opened.|r Round 1 bets are open. When ready: |cFFFFD700/cs lock|r then |cFFFFD700/roll %d|r."):format(WHEEL_POCKETS))
end

-- forward decl (Cmd_Settle is assigned later but referenced from Cmd_Lock's
-- onResolved callback; local must be in scope before Cmd_Lock is defined)
local Cmd_Settle

local function _GetCasinoRoll()
    return HopeAddon and HopeAddon.GetModule and HopeAddon:GetModule("CasinoRoll")
end

local function _CancelPendingRoll()
    if not HostTable or not HostTable.round then return end
    local rid = HostTable.round.rollRequestId
    if not rid then return end
    local CR = _GetCasinoRoll()
    if CR then CR:Cancel(rid) end
    HostTable.round.rollRequestId = nil
end

local function Cmd_Lock()
    if not HostTable or not HostTable.active then
        PrintLocal("No table open.")
        return
    end
    if not HostTable.round or HostTable.round.state ~= "BETS_OPEN" then
        PrintLocal(("|cFFFFAA00Cannot lock: round state is %s|r"):format(
            HostTable.round and HostTable.round.state or "(none)"))
        return
    end

    HostTable.round.state = "BETS_LOCKED"

    BroadcastGuild(("Round %d bets locked. /roll 37 to spin."):format(HostTable.round.n))

    -- Register roll expectation with CasinoRoll (shared primitive).
    -- Non-RESOLVED outcomes (TIMEOUT, CANCELLED) are treated as disconnect:
    -- the round stays BETS_LOCKED until the host runs /cs next or /cs close.
    local CR = _GetCasinoRoll()
    if CR then
        local roundN = HostTable.round.n
        local rid = ("RSLICE_R%d_%d"):format(roundN, math.floor(GetTime() * 1000))
        HostTable.round.rollRequestId = rid
        CR:Expect({
            requestId   = rid,
            host        = HostTable.host,
            expectedMax = WHEEL_POCKETS,
            timeoutSec  = 600,
            onResolved  = function(outcome)
                if outcome.status ~= "RESOLVED" then return end
                if not HostTable or not HostTable.active then return end
                local round = HostTable.round
                if not round or round.state ~= "BETS_LOCKED" then return end
                if round.n ~= roundN then return end
                round.winningNumber = outcome.result - 1   -- /roll 37 -> pocket 0..36
                round.rollRequestId = nil
                Cmd_Settle()
            end,
        })
    else
        PrintLocal("|cFFFF5555CasinoRoll module unavailable — /roll capture is disabled. /cs close and /reload.|r")
    end
end

-- Compute payouts for a finished round.
local function ComputePayouts(bets, winningNumber)
    local payouts = {}
    for player, bet in pairs(bets) do
        if bet.number == winningNumber then
            -- winnings = stake * 35; total returned = stake * 36
            payouts[player] = bet.stake * 36 * 10000   -- copper
            bet.status = "WON"
        else
            -- 0 (host already conceptually has the stake)
            bet.status = "LOST"
        end
    end
    return payouts
end

-- Format gold from copper for display
local function FormatGold(copper)
    if HopeAddon and HopeAddon.FormatGold then
        return HopeAddon:FormatGold(copper)
    end
    local g = math.floor(copper / 10000)
    return g .. "g"
end

Cmd_Settle = function()
    if not HostTable or not HostTable.active then return end
    local round = HostTable.round
    if not round or round.state ~= "BETS_LOCKED" then return end

    round.payouts = ComputePayouts(round.bets, round.winningNumber)
    round.state = "SETTLED"

    -- One combined broadcast: pocket + every bettor's outcome.
    local parts = {}
    for player, bet in pairs(round.bets) do
        if bet.status == "WON" then
            local copper = round.payouts[player] or 0
            table.insert(parts, ("%s won %s"):format(player, FormatGold(copper)))
        else
            table.insert(parts, ("%s lost %dg"):format(player, bet.stake))
        end
    end

    local resultLine
    if #parts == 0 then
        resultLine = ("Round %d: pocket %s (%s)."):format(
            round.n, FormatWithColor(round.winningNumber), NumberColor(round.winningNumber))
    else
        resultLine = ("Round %d: pocket %s (%s). %s."):format(
            round.n, FormatWithColor(round.winningNumber), NumberColor(round.winningNumber),
            table.concat(parts, "; "))
    end
    BroadcastGuild(resultLine)

    -- Host-only payout reminder (one line per winner; nothing if no winners).
    for player, copper in pairs(round.payouts) do
        PrintLocal(("|cFFFFD700Pay %s %s|r"):format(player, FormatGold(copper)))
    end

    -- Append to history (keep last N)
    table.insert(HostTable.history, 1, {
        n = round.n,
        winningNumber = round.winningNumber,
        bets = round.bets,
        payouts = round.payouts,
    })
    while #HostTable.history > HISTORY_KEEP do
        table.remove(HostTable.history)
    end

    PrintLocal("Next: |cFFFFD700/cs next|r for a new round, or |cFFFFD700/cs close|r to end.")
end

local function Cmd_Next()
    if not HostTable or not HostTable.active then
        PrintLocal("No table open.")
        return
    end
    local round = HostTable.round

    -- Refuse if the current round still has live bets that would be silently
    -- discarded. Stuck rounds with no bets are still recoverable by /cs next.
    if round and (round.state == "BETS_OPEN" or round.state == "BETS_LOCKED") then
        local k = 0
        for _ in pairs(round.bets) do k = k + 1 end
        if k > 0 then
            PrintLocal(("|cFFFFAA00Cannot start next round: round %d is %s with %d bet(s). /cs lock then /roll, or /cs close to discard.|r"):format(
                round.n, round.state, k))
            return
        end
    end

    _CancelPendingRoll()
    StartNewRound((round and round.n or 0) + 1)
    BroadcastGuild(("Round %d open. /cs bet <0-36> <gold>."):format(HostTable.round.n))
end

local function Cmd_Close()
    if not HostTable or not HostTable.active then
        PrintLocal("No table open.")
        return
    end
    _CancelPendingRoll()
    BroadcastGuild(("%s closed the Roulette table."):format(HostTable.host))
    HostTable = nil
end

--============================================================
-- HOST: BET PLACEMENT (called from whisper parser OR self)
--============================================================

local function PlaceBet(senderName, numberStr, stakeStr)
    -- Guard: must be hosting
    if not HostTable or not HostTable.active then
        WhisperPlayer(senderName, "Bet rejected: no table open here.")
        return
    end
    local round = HostTable.round
    if not round then
        WhisperPlayer(senderName, "Bet rejected: round has not opened.")
        return
    end
    if round.state ~= "BETS_OPEN" then
        WhisperPlayer(senderName, "Bet rejected: round is locked.")
        return
    end

    local n, nerr = ValidateNumber(numberStr)
    if not n then WhisperPlayer(senderName, "Bet rejected: " .. nerr); return end

    local stake, serr = ValidateStake(stakeStr)
    if not stake then WhisperPlayer(senderName, "Bet rejected: " .. serr); return end

    if round.bets[senderName] then
        WhisperPlayer(senderName, "Bet rejected: you already have a bet this round.")
        return
    end

    round.bets[senderName] = {
        number = n,
        stake = stake,
        placedAt = GetTime(),
        status = "PENDING",
    }

    BroadcastGuild(("%s bet %dg on %d."):format(senderName, stake, n))
end

--============================================================
-- HOST: WHISPER PARSER (incoming bet/join)
--============================================================

local WHISPER_BET_PATTERN  = "^/cs%s+bet%s+(%-?%d+)%s+(%-?%d+)%s*$"
local WHISPER_JOIN_PATTERN = "^/cs%s+join%s*$"

local function OnWhisperReceived(message, sender)
    if not message or not sender then return end

    -- Player /cs commands routed via WhisperPlayer arrive with PREFIX
    -- prepended (e.g. "[Casino] /cs join"). Strip it so the /cs patterns
    -- below match.
    if message:sub(1, #PREFIX) == PREFIX then
        message = message:sub(#PREFIX + 1)
    end

    -- Strip server suffix
    local senderBase = sender:match("^([^-]+)") or sender

    if message:match(WHISPER_JOIN_PATTERN) then
        if not HostTable or not HostTable.active then
            WhisperPlayer(senderBase, "Join rejected: no table open here.")
            return
        end
        -- Acknowledge; bets from non-joined players are still accepted.
        WhisperPlayer(senderBase, ("Joined %s's Roulette table."):format(HostTable.host))
        return
    end

    local n, s = message:match(WHISPER_BET_PATTERN)
    if n and s then
        if HostTable and HostTable.active then
            PlaceBet(senderBase, n, s)
        else
            -- Not hosting; ignore so we don't whisper-spam friends running tests
        end
    end
end

--============================================================
-- PLAYER SIDE
--============================================================

local function Player_Cmd_Join()
    if PlayerSession and PlayerSession.joinedHost then
        if PlayerSession.joinedHost == LastSeenHost or not LastSeenHost then
            PrintLocal(("|cFFFFAA00Already joined %s's table.|r"):format(PlayerSession.joinedHost))
        else
            PrintLocal(("|cFFFFAA00Already joined %s's table; ignoring %s's announcement. /reload to switch.|r"):format(
                PlayerSession.joinedHost, LastSeenHost))
        end
        return
    end
    if not LastSeenHost then
        PrintLocal("|cFFFFAA00No table announcement seen recently. Wait for a host to /cs open.|r")
        return
    end

    PlayerSession = {
        joinedHost = LastSeenHost,
    }

    -- Whisper the host to register
    WhisperPlayer(LastSeenHost, "/cs join")
    PrintLocal(("Sent join request to %s. Bet via /cs bet -- host will whisper rejection if the table is closed."):format(LastSeenHost))
end

local function Player_Cmd_Bet(numberStr, stakeStr)
    -- Validate locally for fast feedback
    local n, nerr = ValidateNumber(numberStr)
    if not n then PrintLocal("|cFFFFAA00" .. nerr .. "|r"); return end
    local s, serr = ValidateStake(stakeStr)
    if not s then PrintLocal("|cFFFFAA00" .. serr .. "|r"); return end

    local myName = HostName()

    -- If hosting, place directly
    if HostTable and HostTable.active and HostTable.host == myName then
        PlaceBet(myName, numberStr, stakeStr)
        return
    end

    -- Else, whisper the host
    if not PlayerSession or not PlayerSession.joinedHost then
        PrintLocal("|cFFFFAA00Bet rejected: not joined to any table. Try /cs join first.|r")
        return
    end
    WhisperPlayer(PlayerSession.joinedHost, ("/cs bet %d %d"):format(n, s))
    PrintLocal(("Bet sent: %dg on %d to %s."):format(s, n, PlayerSession.joinedHost))
end

--============================================================
-- TABLE-OPEN BROADCAST DETECTION (player-side)
--============================================================

-- Message format we send: "[Casino] {host} opened a Roulette table. ..."
local TABLE_OPEN_PATTERN = "^%[Casino%] (.+) opened a Roulette table"

local function OnChatMessage(message, sender)
    if not message or not sender then return end

    -- Ignore our own broadcasts (host's /cs open echoes via /say to self)
    local senderBase = sender:match("^([^-]+)") or sender
    if senderBase == HostName() then return end

    local host = message:match(TABLE_OPEN_PATTERN)
    if host then
        local hostBase = host:match("^([^-]+)") or host
        LastSeenHost = hostBase
    end
end

-- Surface a hint when the host runs a wrong-sized /roll while bets are locked
-- (CasinoRoll silently drops mismatched rolls; this gives the host feedback).
local function OnSystemMessage(msg)
    if not HostTable or not HostTable.active then return end
    local round = HostTable.round
    if not round or round.state ~= "BETS_LOCKED" then return end
    local CR = _GetCasinoRoll()
    if not CR or not CR.ParseRoll then return end
    local name, _, max = CR.ParseRoll(msg)
    if not name then return end
    if name ~= HostName() then return end
    if max == WHEEL_POCKETS then return end
    PrintLocal(("|cFFFFAA00Roll ignored:|r expected |cFFFFD700/roll %d|r, got /roll %d."):format(WHEEL_POCKETS, max))
end

--============================================================
-- SLASH COMMAND DISPATCH
--============================================================

local HOST_CMDS = {
    open    = Cmd_Open,
    lock    = Cmd_Lock,
    next    = Cmd_Next,
    close   = Cmd_Close,
}

local PLAYER_CMDS = {
    join   = Player_Cmd_Join,
    bet    = Player_Cmd_Bet,
}

local function PrintHelp()
    PrintLocal("Roulette Slice commands:")
    PrintLocal("  Host:   /cs open [guild] | lock | next | close")
    PrintLocal("  Player: /cs join | bet <0-36> <gold>")
end

local function HandleSlash(input)
    input = input or ""
    -- Tokenize whitespace
    local args = {}
    for w in input:gmatch("%S+") do table.insert(args, w) end

    local cmd = args[1] and args[1]:lower() or nil
    if not cmd or cmd == "" or cmd == "help" or cmd == "?" then
        PrintHelp()
        return
    end

    if HOST_CMDS[cmd] then
        HOST_CMDS[cmd](args[2])
        return
    end

    if PLAYER_CMDS[cmd] then
        if cmd == "bet" then
            PLAYER_CMDS[cmd](args[2], args[3])
        else
            PLAYER_CMDS[cmd]()
        end
        return
    end

    PrintLocal("|cFFFFAA00Unknown subcommand:|r " .. tostring(cmd))
    PrintHelp()
end

SLASH_HOPECASINO1 = "/cs"
SlashCmdList["HOPECASINO"] = HandleSlash

--============================================================
-- EVENT WIRING
--============================================================

-- /roll detection is delegated to CasinoRoll (registered in Cmd_Lock).
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
-- Listen for table-open broadcasts on /say and /guild
eventFrame:RegisterEvent("CHAT_MSG_SAY")
eventFrame:RegisterEvent("CHAT_MSG_GUILD")
-- Listen for /roll system messages so we can warn on wrong-sized rolls
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:SetScript("OnEvent", function(_, event, msg, sender)
    if event == "CHAT_MSG_WHISPER" then
        OnWhisperReceived(msg, sender)
    elseif event == "CHAT_MSG_SAY" or event == "CHAT_MSG_GUILD" then
        OnChatMessage(msg, sender)
    elseif event == "CHAT_MSG_SYSTEM" then
        OnSystemMessage(msg)
    end
end)

--============================================================
-- REGISTER (lightweight, no module lifecycle hooks needed)
--============================================================

if HopeAddon and HopeAddon.RegisterModule then
    HopeAddon:RegisterModule("RouletteSlice", RouletteSlice)
    HopeAddon.RouletteSlice = RouletteSlice
end

if HopeAddon and HopeAddon.Debug then
    HopeAddon:Debug("RouletteSlice loaded - /cs to play")
end
