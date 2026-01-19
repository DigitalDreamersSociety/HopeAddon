--[[
    HopeAddon Death Roll Escrow
    3-player escrow system for gambling

    How it works:
    1. Three players involved: Player A, Player B, and House (escrow holder)
    2. House initiates an escrow session
    3. Both players trade their bet amount to the House
    4. After game ends, House trades winnings to winner
    5. All three must have addon installed for tracking

    Note: This is trust-based - WoW API doesn't support actual escrow mechanics
    The addon tracks and verifies amounts but relies on House honesty
]]

local DeathRollEscrow = {}

--============================================================
-- CONSTANTS
--============================================================

-- Escrow states
DeathRollEscrow.STATE = {
    NONE = "NONE",                      -- No escrow active
    INITIATED = "INITIATED",            -- House started session
    AWAITING_TRADES = "AWAITING_TRADES", -- Waiting for player trades
    PLAYER1_PAID = "PLAYER1_PAID",      -- Player 1 has traded
    PLAYER2_PAID = "PLAYER2_PAID",      -- Player 2 has traded
    FUNDED = "FUNDED",                  -- Both players paid
    GAME_IN_PROGRESS = "GAME_IN_PROGRESS",
    AWAITING_PAYOUT = "AWAITING_PAYOUT", -- Waiting for house to pay winner
    COMPLETED = "COMPLETED",            -- Escrow completed
    DISPUTED = "DISPUTED",              -- Something went wrong
}

-- Tolerance for copper amount comparison (1 copper)
DeathRollEscrow.COPPER_TOLERANCE = 1

-- Message types for escrow communication
local MSG_ESCROW_INIT = "EINIT"         -- House initiates escrow
local MSG_ESCROW_JOIN = "EJOIN"         -- Player joins escrow
local MSG_ESCROW_CONFIRM = "ECONF"      -- Trade confirmed
local MSG_ESCROW_READY = "ERDY"         -- Escrow fully funded
local MSG_ESCROW_PAYOUT = "EPAY"        -- Payout initiated
local MSG_ESCROW_COMPLETE = "EDONE"     -- Escrow completed
local MSG_ESCROW_DISPUTE = "EDIS"       -- Dispute raised

--============================================================
-- MODULE STATE
--============================================================

-- Active escrow sessions
DeathRollEscrow.sessions = {}

-- Trade tracking
DeathRollEscrow.pendingTrades = {}

-- Event frame
DeathRollEscrow.eventFrame = nil

--============================================================
-- LIFECYCLE
--============================================================

function DeathRollEscrow:OnInitialize()
    HopeAddon:Debug("DeathRollEscrow initializing...")
end

function DeathRollEscrow:OnEnable()
    -- Create event frame for trade tracking
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("TRADE_ACCEPT_UPDATE")
    self.eventFrame:RegisterEvent("TRADE_CLOSED")
    self.eventFrame:RegisterEvent("TRADE_MONEY_CHANGED")
    self.eventFrame:RegisterEvent("TRADE_SHOW")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)

    -- Register communication handlers
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:RegisterHandler("DEATH_ROLL", "ESCROW", function(sender, gameId, data)
            self:HandleEscrowMessage(sender, gameId, data)
        end)
    end

    HopeAddon:Debug("DeathRollEscrow enabled")
end

function DeathRollEscrow:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
end

--============================================================
-- EVENT HANDLING
--============================================================

function DeathRollEscrow:OnEvent(event, ...)
    if event == "TRADE_SHOW" then
        self:OnTradeShow()
    elseif event == "TRADE_MONEY_CHANGED" then
        self:OnTradeMoneyChanged()
    elseif event == "TRADE_ACCEPT_UPDATE" then
        local playerAccepted, targetAccepted = ...
        self:OnTradeAcceptUpdate(playerAccepted, targetAccepted)
    elseif event == "TRADE_CLOSED" then
        self:OnTradeClosed()
    end
end

function DeathRollEscrow:OnTradeShow()
    -- Check if this trade is relevant to any escrow session
    local tradeName = GetUnitName("NPC", true) or UnitName("NPC")
    if not tradeName then return end

    HopeAddon:Debug("Trade opened with:", tradeName)

    -- Find relevant session
    for sessionId, session in pairs(self.sessions) do
        if session.state == self.STATE.AWAITING_TRADES or
           session.state == self.STATE.PLAYER1_PAID or
           session.state == self.STATE.PLAYER2_PAID then
            -- Check if trade partner is in this session
            if tradeName == session.house or
               tradeName == session.player1 or
               tradeName == session.player2 then
                self.pendingTrades[sessionId] = {
                    partner = tradeName,
                    expectedAmount = session.betAmount,
                }
                HopeAddon:Print("Escrow trade detected for session: " .. sessionId)
            end
        end
    end
end

function DeathRollEscrow:OnTradeMoneyChanged()
    -- Track money being traded
    local playerMoney = GetPlayerTradeMoney()
    local targetMoney = GetTargetTradeMoney()

    for sessionId, trade in pairs(self.pendingTrades) do
        if trade then
            trade.playerMoney = playerMoney
            trade.targetMoney = targetMoney
        end
    end
end

function DeathRollEscrow:OnTradeAcceptUpdate(playerAccepted, targetAccepted)
    -- Both accepted - trade will complete
    if playerAccepted == 1 and targetAccepted == 1 then
        for sessionId, trade in pairs(self.pendingTrades) do
            if trade then
                trade.accepted = true
            end
        end
    end
end

function DeathRollEscrow:OnTradeClosed()
    -- Process completed trades
    for sessionId, trade in pairs(self.pendingTrades) do
        if trade and trade.accepted then
            self:ProcessCompletedTrade(sessionId, trade)
        end
    end

    wipe(self.pendingTrades)
end

function DeathRollEscrow:ProcessCompletedTrade(sessionId, trade)
    local session = self.sessions[sessionId]
    if not session then return end

    local myName = UnitName("player")
    local amountTraded = trade.playerMoney or 0

    HopeAddon:Debug("Trade completed:", trade.partner, "amount:", amountTraded)

    -- Determine role and update session
    if myName == session.house then
        -- House received money from a player
        if trade.partner == session.player1 then
            session.player1Paid = true
            session.player1Amount = trade.targetMoney or 0
            self:UpdateSessionState(sessionId)
        elseif trade.partner == session.player2 then
            session.player2Paid = true
            session.player2Amount = trade.targetMoney or 0
            self:UpdateSessionState(sessionId)
        end
    elseif myName == session.player1 or myName == session.player2 then
        -- Player paid house
        if trade.partner == session.house then
            HopeAddon:Print("Your bet of " .. HopeAddon:FormatGold(amountTraded) .. " has been received by " .. session.house)
            self:SendEscrowMessage(session.house, MSG_ESCROW_CONFIRM, sessionId, tostring(amountTraded))
        end
    end
end

--============================================================
-- ESCROW SESSION MANAGEMENT
--============================================================

--[[
    Initiate an escrow session (called by house)
    @param gameId string - Associated game ID
    @param betAmount number - Bet amount in gold
    @param player1 string - First player name
    @param player2 string - Second player name
    @return string - Session ID
]]
function DeathRollEscrow:InitiateAsHouse(gameId, betAmount, player1, player2)
    local myName = UnitName("player")
    local sessionId = gameId .. "_ESCROW"

    local session = {
        id = sessionId,
        gameId = gameId,
        house = myName,
        player1 = player1,
        player2 = player2,
        betAmount = betAmount * 10000, -- Convert to copper
        state = self.STATE.INITIATED,
        player1Paid = false,
        player2Paid = false,
        player1Amount = 0,
        player2Amount = 0,
        winner = nil,
        createdAt = GetTime(),
    }

    self.sessions[sessionId] = session

    -- Notify players
    self:SendEscrowMessage(player1, MSG_ESCROW_INIT, sessionId, string.format("%s|%s|%d", player1, player2, betAmount))
    self:SendEscrowMessage(player2, MSG_ESCROW_INIT, sessionId, string.format("%s|%s|%d", player1, player2, betAmount))

    session.state = self.STATE.AWAITING_TRADES

    HopeAddon:Print("Escrow session started. Waiting for trades from " .. player1 .. " and " .. player2)
    HopeAddon:Print("Expected amount: " .. HopeAddon:FormatGold(session.betAmount) .. " from each player")

    return sessionId
end

--[[
    Called when escrow initiation is received
]]
function DeathRollEscrow:HandleEscrowInit(sender, sessionId, data)
    local player1, player2, betAmount = strsplit("|", data)
    betAmount = tonumber(betAmount)

    local myName = UnitName("player")

    local session = {
        id = sessionId,
        gameId = sessionId:gsub("_ESCROW$", ""),
        house = sender,
        player1 = player1,
        player2 = player2,
        betAmount = betAmount * 10000,
        state = self.STATE.AWAITING_TRADES,
        player1Paid = false,
        player2Paid = false,
        winner = nil,
    }

    self.sessions[sessionId] = session

    HopeAddon:Print(sender .. " is holding escrow for Death Roll!")
    HopeAddon:Print("Bet: " .. HopeAddon:FormatGold(session.betAmount))
    HopeAddon:Print("Trade " .. sender .. " to place your bet")
end

--[[
    Update session state based on payments
]]
function DeathRollEscrow:UpdateSessionState(sessionId)
    local session = self.sessions[sessionId]
    if not session then return end

    if session.player1Paid and not session.player2Paid then
        session.state = self.STATE.PLAYER1_PAID
        HopeAddon:Print(session.player1 .. " has paid. Waiting for " .. session.player2)
    elseif session.player2Paid and not session.player1Paid then
        session.state = self.STATE.PLAYER2_PAID
        HopeAddon:Print(session.player2 .. " has paid. Waiting for " .. session.player1)
    elseif session.player1Paid and session.player2Paid then
        -- Verify amounts
        local expectedCopper = session.betAmount

        if math.abs(session.player1Amount - expectedCopper) > self.COPPER_TOLERANCE or
           math.abs(session.player2Amount - expectedCopper) > self.COPPER_TOLERANCE then
            session.state = self.STATE.DISPUTED
            HopeAddon:Print("WARNING: Payment amounts don't match expected bet!")
            HopeAddon:Print("Expected: " .. HopeAddon:FormatGold(expectedCopper))
            HopeAddon:Print(session.player1 .. " paid: " .. HopeAddon:FormatGold(session.player1Amount))
            HopeAddon:Print(session.player2 .. " paid: " .. HopeAddon:FormatGold(session.player2Amount))
            return
        end

        session.state = self.STATE.FUNDED
        HopeAddon:Print("Escrow fully funded! Game can begin.")

        -- Notify players
        self:SendEscrowMessage(session.player1, MSG_ESCROW_READY, sessionId, "")
        self:SendEscrowMessage(session.player2, MSG_ESCROW_READY, sessionId, "")
    end
end

--[[
    Set the winner and initiate payout
    @param sessionId string
    @param winner string - Winner's name
]]
function DeathRollEscrow:SetWinner(sessionId, winner)
    local session = self.sessions[sessionId]
    if not session then return end

    session.winner = winner
    session.state = self.STATE.AWAITING_PAYOUT

    local totalPot = session.player1Amount + session.player2Amount
    local loser = winner == session.player1 and session.player2 or session.player1

    HopeAddon:Print("=== DEATH ROLL RESULT ===")
    HopeAddon:Print("Winner: " .. winner)
    HopeAddon:Print("Loser: " .. loser)
    HopeAddon:Print("Pot: " .. HopeAddon:FormatGold(totalPot))

    local myName = UnitName("player")
    if myName == session.house then
        HopeAddon:Print("Trade " .. winner .. " to pay out " .. HopeAddon:FormatGold(totalPot))
    end
end

--[[
    Mark escrow as completed
    @param sessionId string
]]
function DeathRollEscrow:CompleteEscrow(sessionId)
    local session = self.sessions[sessionId]
    if not session then return end

    session.state = self.STATE.COMPLETED

    -- Notify players
    self:SendEscrowMessage(session.player1, MSG_ESCROW_COMPLETE, sessionId, session.winner or "")
    self:SendEscrowMessage(session.player2, MSG_ESCROW_COMPLETE, sessionId, session.winner or "")

    HopeAddon:Print("Escrow completed successfully!")

    -- Clean up after delay
    session.cleanupTimer = HopeAddon.Timer:After(60, function()
        if self.sessions[sessionId] then
            self.sessions[sessionId] = nil
        end
    end)
end

--============================================================
-- COMMUNICATION
--============================================================

function DeathRollEscrow:SendEscrowMessage(target, msgType, sessionId, data)
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    local fullData = string.format("%s|%s|%s", msgType, sessionId, data or "")
    GameComms:SendGameMessage(target, "GSTA", "DEATH_ROLL", sessionId, fullData)
end

function DeathRollEscrow:HandleEscrowMessage(sender, gameId, data)
    local msgType, sessionId, payload = strsplit("|", data, 3)

    if msgType == MSG_ESCROW_INIT then
        self:HandleEscrowInit(sender, sessionId, payload)
    elseif msgType == MSG_ESCROW_CONFIRM then
        self:HandleTradeConfirm(sender, sessionId, payload)
    elseif msgType == MSG_ESCROW_READY then
        self:HandleEscrowReady(sender, sessionId)
    elseif msgType == MSG_ESCROW_COMPLETE then
        self:HandleEscrowComplete(sender, sessionId, payload)
    elseif msgType == MSG_ESCROW_DISPUTE then
        self:HandleDispute(sender, sessionId, payload)
    end
end

function DeathRollEscrow:HandleTradeConfirm(sender, sessionId, amountStr)
    local session = self.sessions[sessionId]
    if not session then return end

    local amount = tonumber(amountStr) or 0
    HopeAddon:Debug("Trade confirm from", sender, "amount:", amount)
end

function DeathRollEscrow:HandleEscrowReady(sender, sessionId)
    HopeAddon:Print("Escrow is ready! " .. sender .. " is holding the pot.")
    HopeAddon:Print("Let the Death Roll begin!")
end

function DeathRollEscrow:HandleEscrowComplete(sender, sessionId, winner)
    local session = self.sessions[sessionId]
    if session then
        session.state = self.STATE.COMPLETED
        session.winner = winner
    end

    if winner ~= "" then
        HopeAddon:Print("Escrow completed. " .. winner .. " won the pot!")
    end
end

function DeathRollEscrow:HandleDispute(sender, sessionId, reason)
    local session = self.sessions[sessionId]
    if session then
        session.state = self.STATE.DISPUTED
    end

    HopeAddon:Print("DISPUTE raised by " .. sender .. ": " .. (reason or "Unknown reason"))
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Cancel escrow session and clean up resources
    @param gameId string
]]
function DeathRollEscrow:CancelEscrow(gameId)
    local sessionId = self:FindSessionByGameId(gameId)
    if not sessionId then return end

    local session = self.sessions[sessionId]
    if not session then return end

    -- Cancel cleanup timer if exists
    if session.cleanupTimer then
        session.cleanupTimer:Cancel()
        session.cleanupTimer = nil
    end

    -- Remove session
    self.sessions[sessionId] = nil
    HopeAddon:Debug("Cancelled escrow session:", sessionId)
end

--[[
    Find session by game ID
    @param gameId string
    @return string|nil - Session ID
]]
function DeathRollEscrow:FindSessionByGameId(gameId)
    for sessionId, session in pairs(self.sessions) do
        if session.gameId == gameId then
            return sessionId
        end
    end
    return nil
end

--[[
    Get session by ID
    @param sessionId string
    @return table|nil
]]
function DeathRollEscrow:GetSession(sessionId)
    return self.sessions[sessionId]
end

--[[
    Get session by game ID
    @param gameId string
    @return table|nil
]]
function DeathRollEscrow:GetSessionByGame(gameId)
    local sessionId = gameId .. "_ESCROW"
    return self.sessions[sessionId]
end

--[[
    Check if a game has active escrow
    @param gameId string
    @return boolean
]]
function DeathRollEscrow:HasEscrow(gameId)
    local session = self:GetSessionByGame(gameId)
    return session ~= nil and session.state ~= self.STATE.COMPLETED
end

--[[
    Called when game ends - triggers payout
    @param gameId string
    @param winner string
]]
function DeathRollEscrow:OnGameEnd(gameId, winner)
    local session = self:GetSessionByGame(gameId)
    if not session then return end

    self:SetWinner(session.id, winner)
end

-- Register with addon
HopeAddon:RegisterModule("DeathRollEscrow", DeathRollEscrow)
HopeAddon.DeathRollEscrow = DeathRollEscrow

HopeAddon:Debug("DeathRollEscrow module loaded")
