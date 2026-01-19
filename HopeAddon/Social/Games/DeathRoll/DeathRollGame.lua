--[[
    HopeAddon Death Roll Game
    A gambling game where players take turns rolling until someone rolls 1

    Rules:
    1. Player A rolls 1-1000 (or custom max)
    2. Player B rolls 1-[Player A's result]
    3. Continue alternating until someone rolls 1
    4. The player who rolls 1 loses

    Works both in-person and at distance (turn-based)
]]

local DeathRollGame = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game states specific to Death Roll
DeathRollGame.ROLL_STATE = {
    WAITING_TO_START = "WAITING_TO_START",
    PLAYER1_TURN = "PLAYER1_TURN",
    PLAYER2_TURN = "PLAYER2_TURN",
    FINISHED = "FINISHED",
}

-- Default starting roll
DeathRollGame.DEFAULT_MAX_ROLL = 1000

-- Proximity requirement for remote games (to verify rolls via chat)
DeathRollGame.PROXIMITY_REQUIRED = true

-- Roll detection pattern (from CHAT_MSG_SYSTEM)
-- Format: "PlayerName rolls X (1-Y)"
DeathRollGame.ROLL_PATTERN = "(.+) rolls (%d+) %(1%-(%d+)%)"

--============================================================
-- MODULE STATE
--============================================================

-- Active death roll games
DeathRollGame.games = {}

-- Event frame for roll detection
DeathRollGame.eventFrame = nil

--============================================================
-- LIFECYCLE
--============================================================

function DeathRollGame:OnInitialize()
    HopeAddon:Debug("DeathRollGame initializing...")
end

function DeathRollGame:OnEnable()
    -- Register with GameCore
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:RegisterGame(GameCore.GAME_TYPE.DEATH_ROLL, self)
    end

    -- Create event frame for roll detection
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
    self.eventFrame:SetScript("OnEvent", function(_, event, msg)
        if event == "CHAT_MSG_SYSTEM" then
            self:OnSystemMessage(msg)
        end
    end)

    -- Register communication handlers
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:RegisterHandler("DEATH_ROLL", "MOVE", function(sender, gameId, data)
            self:HandleRemoteRoll(sender, gameId, data)
        end)
        GameComms:RegisterHandler("DEATH_ROLL", "STATE", function(sender, gameId, data)
            self:HandleRemoteState(sender, gameId, data)
        end)
    end

    HopeAddon:Debug("DeathRollGame enabled")
end

function DeathRollGame:OnDisable()
    -- Clean up all active games
    for gameId in pairs(self.games or {}) do
        self:OnDestroy(gameId)
    end
    self.games = {}

    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
    end
end

--============================================================
-- GAME LIFECYCLE (Called by GameCore)
--============================================================

--[[
    Called when game is created
]]
function DeathRollGame:OnCreate(gameId, game)
    -- Initialize death roll specific data
    game.data = {
        maxRoll = self.DEFAULT_MAX_ROLL,
        currentMax = self.DEFAULT_MAX_ROLL,
        rollHistory = {},
        rollState = self.ROLL_STATE.WAITING_TO_START,
        betAmount = 0,
        escrowEnabled = false,
        escrowHouse = nil,
    }

    -- Store reference
    self.games[gameId] = game

    HopeAddon:Debug("DeathRoll game created:", gameId)
end

--[[
    Called when game starts
]]
function DeathRollGame:OnStart(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Check proximity for remote games
    local GameCore = HopeAddon:GetModule("GameCore")
    if self.PROXIMITY_REQUIRED and GameCore and game.mode == GameCore.GAME_MODE.REMOTE then
        local inProximity, reason = self:IsOpponentInProximity(game.opponent)
        if not inProximity then
            HopeAddon:Print("|cFFFF0000Death Roll requires proximity!|r")
            HopeAddon:Print(reason)
            HopeAddon:Print("Both players must be visible to each other for verified rolls.")
            GameCore:EndGame(gameId, "proximity_required")
            return
        end
        -- Store initial proximity status
        game.data.proximityVerified = true
    end

    -- Determine who goes first (coin flip or initiator)
    game.data.rollState = self.ROLL_STATE.PLAYER1_TURN

    -- Show UI
    self:ShowUI(gameId)

    HopeAddon:Print("Death Roll started! " .. game.player1 .. " rolls first.")
    HopeAddon:Print("Type /roll " .. game.data.currentMax .. " to roll")
end

--[[
    Called when game ends
]]
function DeathRollGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    game.data.rollState = self.ROLL_STATE.FINISHED

    -- Determine loser/winner
    if game.winner then
        local loser = game.winner == game.player1 and game.player2 or game.player1
        HopeAddon:Print("Death Roll ended! " .. loser .. " loses!")

        if game.data.betAmount > 0 then
            HopeAddon:Print(loser .. " owes " .. HopeAddon:FormatGold(game.data.betAmount * 10000))
        end
    end

    -- Record stats for remote games
    if game.mode == GameCore.GAME_MODE.REMOTE and game.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames and Minigames.RecordGameResult then
            local playerName = UnitName("player")
            local result = (game.winner == playerName) and "win" or "lose"
            local betAmount = game.data.betAmount or 0
            Minigames:RecordGameResult(game.opponent, "deathroll", result, betAmount)
        end
    end

    -- Show game over UI
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        local stats = {
            ["Total Rolls"] = #game.data.rollHistory,
            ["Starting Max"] = game.data.maxRoll,
        }
        if game.data.betAmount > 0 then
            stats["Bet"] = HopeAddon:FormatGold(game.data.betAmount * 10000)
        end
        GameUI:ShowGameOver(gameId, game.winner, stats)
    end
end

--[[
    Called when game is destroyed
]]
function DeathRollGame:OnDestroy(gameId)
    self.games[gameId] = nil
end

--============================================================
-- ROLL DETECTION
--============================================================

--[[
    Handle system messages for roll detection
]]
function DeathRollGame:OnSystemMessage(msg)
    -- Parse roll message
    local playerName, rollResult, maxRoll = msg:match(self.ROLL_PATTERN)

    if not playerName then return end

    rollResult = tonumber(rollResult)
    maxRoll = tonumber(maxRoll)

    HopeAddon:Debug("Detected roll:", playerName, "rolled", rollResult, "max", maxRoll)

    -- Find active game this roll belongs to
    for gameId, game in pairs(self.games) do
        if self:IsValidRoll(game, playerName, maxRoll) then
            self:ProcessRoll(gameId, playerName, rollResult, maxRoll)
            return
        end
    end
end

--[[
    Check if a roll is valid for the given game
]]
function DeathRollGame:IsValidRoll(game, playerName, maxRoll)
    if game.data.rollState == self.ROLL_STATE.FINISHED then
        return false
    end

    -- Check if player is in this game
    local isPlayer1 = playerName == game.player1
    local isPlayer2 = playerName == game.player2

    if not isPlayer1 and not isPlayer2 then
        return false
    end

    -- Check if it's their turn
    if game.data.rollState == self.ROLL_STATE.PLAYER1_TURN and not isPlayer1 then
        return false
    end
    if game.data.rollState == self.ROLL_STATE.PLAYER2_TURN and not isPlayer2 then
        return false
    end

    -- Check max roll matches expected
    if maxRoll ~= game.data.currentMax then
        return false
    end

    -- Check proximity for remote games (warn if opponent not visible)
    local GameCore = HopeAddon:GetModule("GameCore")
    if self.PROXIMITY_REQUIRED and GameCore and game.mode == GameCore.GAME_MODE.REMOTE then
        local myName = UnitName("player")
        local opponentName = (playerName == myName) and game.opponent or nil
        if opponentName then
            local inProximity, reason = self:IsOpponentInProximity(opponentName)
            if not inProximity then
                HopeAddon:Print("|cFFFF0000Cannot verify roll!|r " .. reason)
                HopeAddon:Print("Both players should be in the same area for Death Roll.")
                -- Still allow the roll, but warn the player
            end
        end
    end

    return true
end

--[[
    Process a valid roll
]]
function DeathRollGame:ProcessRoll(gameId, playerName, rollResult, maxRoll)
    local game = self.games[gameId]
    if not game then return end

    -- Record roll
    table.insert(game.data.rollHistory, {
        player = playerName,
        roll = rollResult,
        max = maxRoll,
        timestamp = GetTime(),
    })

    -- Update UI
    self:UpdateUI(gameId)

    -- Check for loss (rolled 1)
    if rollResult == 1 then
        -- This player loses
        local winner = playerName == game.player1 and game.player2 or game.player1
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:SetWinner(gameId, winner)
        end
        return
    end

    -- Update current max and switch turns
    game.data.currentMax = rollResult

    if game.data.rollState == self.ROLL_STATE.PLAYER1_TURN then
        game.data.rollState = self.ROLL_STATE.PLAYER2_TURN
        HopeAddon:Print(game.player2 .. "'s turn. /roll " .. rollResult)
    else
        game.data.rollState = self.ROLL_STATE.PLAYER1_TURN
        HopeAddon:Print(game.player1 .. "'s turn. /roll " .. rollResult)
    end

    -- Send update to remote player if networked
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore and game.mode == GameCore.GAME_MODE.REMOTE then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            local stateData = string.format("%d|%s", rollResult, playerName)
            GameComms:SendState(game.opponent, "DEATH_ROLL", gameId, stateData)
        end
    end
end

--============================================================
-- REMOTE GAME HANDLING
--============================================================

--[[
    Handle roll from remote player
]]
function DeathRollGame:HandleRemoteRoll(sender, gameId, data)
    local rollResult, maxRoll = strsplit("|", data)
    rollResult = tonumber(rollResult)
    maxRoll = tonumber(maxRoll)

    local game = self.games[gameId]
    if not game then return end

    -- Process as if we detected it locally
    self:ProcessRoll(gameId, sender, rollResult, maxRoll)
end

--[[
    Handle state sync from remote player
]]
function DeathRollGame:HandleRemoteState(sender, gameId, data)
    local rollResult, playerName = strsplit("|", data)
    rollResult = tonumber(rollResult)

    local game = self.games[gameId]
    if not game then return end

    -- Sync our state
    game.data.currentMax = rollResult

    HopeAddon:Debug("Synced death roll state:", rollResult)
end

--============================================================
-- PROXIMITY CHECKS
--============================================================

--[[
    Check if opponent is in proximity for roll verification
    @param opponentName string - The opponent's character name
    @return boolean - True if opponent is nearby and visible
    @return string|nil - Error message if not in proximity
]]
function DeathRollGame:IsOpponentInProximity(opponentName)
    if not opponentName then
        return false, "No opponent specified"
    end

    -- Check if opponent is targetable/visible
    -- First, try to check if they're in our party/raid
    local inGroup = UnitInParty(opponentName) or UnitInRaid(opponentName)

    -- If we can target them directly, check visibility
    if UnitExists(opponentName) then
        if not UnitIsVisible(opponentName) then
            return false, opponentName .. " is not visible"
        end
        return true
    end

    -- If they're in our group but not targetable by name, they might be far away
    if inGroup then
        -- Try targeting by name doesn't work if too far
        return false, opponentName .. " is too far away"
    end

    -- Not in group and not targetable - can't verify
    return false, "Cannot find " .. opponentName
end

--============================================================
-- UI
--============================================================

--[[
    Show Death Roll UI
]]
function DeathRollGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    -- Create game window
    local window = GameUI:CreateGameWindow(gameId, "Death Roll", "SMALL")
    if not window then return end

    local content = window.content

    -- Player names
    local p1Label = GameUI:CreateLabel(content, game.player1, "GameFontNormal")
    p1Label:SetPoint("TOPLEFT", 10, -10)
    p1Label:SetTextColor(0.2, 0.8, 0.2)

    local vsLabel = GameUI:CreateLabel(content, "vs", "GameFontNormalSmall")
    vsLabel:SetPoint("TOP", 0, -10)
    vsLabel:SetTextColor(0.6, 0.6, 0.6)

    local p2Label = GameUI:CreateLabel(content, game.player2, "GameFontNormal")
    p2Label:SetPoint("TOPRIGHT", -10, -10)
    p2Label:SetTextColor(0.8, 0.2, 0.2)

    -- Current max roll display
    local maxLabel = GameUI:CreateLabel(content, "Current Max", "GameFontNormalSmall")
    maxLabel:SetPoint("TOP", 0, -40)
    maxLabel:SetTextColor(0.6, 0.6, 0.6)

    local maxValue = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    maxValue:SetPoint("TOP", maxLabel, "BOTTOM", 0, -5)
    maxValue:SetText(tostring(game.data.currentMax))
    maxValue:SetTextColor(1, 0.84, 0)
    game.data.maxValueText = maxValue

    -- Turn indicator
    local turnLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    turnLabel:SetPoint("TOP", maxValue, "BOTTOM", 0, -15)
    turnLabel:SetText("Waiting to start...")
    turnLabel:SetTextColor(0.8, 0.8, 0.8)
    game.data.turnText = turnLabel

    -- Roll history scroll
    local historyLabel = GameUI:CreateLabel(content, "Roll History", "GameFontNormalSmall")
    historyLabel:SetPoint("BOTTOMLEFT", 10, 55)
    historyLabel:SetTextColor(0.6, 0.6, 0.6)

    local historyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    historyText:SetPoint("BOTTOMLEFT", 10, 10)
    historyText:SetPoint("BOTTOMRIGHT", -10, 10)
    historyText:SetHeight(40)
    historyText:SetJustifyH("LEFT")
    historyText:SetJustifyV("BOTTOM")
    historyText:SetText("")
    historyText:SetTextColor(0.7, 0.7, 0.7)
    game.data.historyText = historyText

    -- Bet display (if betting)
    if game.data.betAmount > 0 then
        local betLabel = GameUI:CreateLabel(content, "Bet: " .. HopeAddon:FormatGold(game.data.betAmount * 10000), "GameFontNormalSmall")
        betLabel:SetPoint("BOTTOM", 0, 60)
        betLabel:SetTextColor(1, 0.84, 0)
    end

    -- Proximity status indicator (for remote games)
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore and game.mode == GameCore.GAME_MODE.REMOTE then
        local proximityText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        proximityText:SetPoint("BOTTOM", content, "BOTTOM", 0, 3)
        if game.data.proximityVerified then
            proximityText:SetText("|cFF00FF00Opponent nearby - rolls verified|r")
        else
            proximityText:SetText("|cFFFFFF00Proximity not verified|r")
        end
        game.data.proximityText = proximityText
    end

    window:Show()

    -- Update turn display
    self:UpdateUI(gameId)
end

--[[
    Update UI elements
]]
function DeathRollGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Update max value
    if game.data.maxValueText then
        game.data.maxValueText:SetText(tostring(game.data.currentMax))
    end

    -- Update turn indicator
    if game.data.turnText then
        local turnText = ""
        if game.data.rollState == self.ROLL_STATE.PLAYER1_TURN then
            turnText = game.player1 .. "'s turn"
        elseif game.data.rollState == self.ROLL_STATE.PLAYER2_TURN then
            turnText = game.player2 .. "'s turn"
        elseif game.data.rollState == self.ROLL_STATE.FINISHED then
            turnText = "Game Over!"
        else
            turnText = "Waiting to start..."
        end
        game.data.turnText:SetText(turnText)
    end

    -- Update history
    if game.data.historyText then
        local historyLines = {}
        local startIdx = math.max(1, #game.data.rollHistory - 4)  -- Show last 5
        for i = startIdx, #game.data.rollHistory do
            local roll = game.data.rollHistory[i]
            table.insert(historyLines, roll.player .. ": " .. roll.roll)
        end
        game.data.historyText:SetText(table.concat(historyLines, " > "))
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Start a new Death Roll game
    @param opponent string|nil - Opponent name (nil for local)
    @param betAmount number|nil - Gold bet in gold units
    @param maxRoll number|nil - Starting max (default 1000)
    @return string - Game ID
]]
function DeathRollGame:StartGame(opponent, betAmount, maxRoll)
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return nil end

    local mode = opponent and GameCore.GAME_MODE.REMOTE or GameCore.GAME_MODE.LOCAL
    local gameId = GameCore:CreateGame(GameCore.GAME_TYPE.DEATH_ROLL, mode, opponent)

    local game = GameCore:GetGame(gameId)
    if game then
        game.data.maxRoll = maxRoll or self.DEFAULT_MAX_ROLL
        game.data.currentMax = game.data.maxRoll
        game.data.betAmount = betAmount or 0
    end

    -- If local, set player 2 as the local player
    if not opponent then
        game.player2 = UnitName("player") .. " (2)"
    end

    GameCore:StartGame(gameId)

    return gameId
end

--[[
    Get active games
    @return table
]]
function DeathRollGame:GetActiveGames()
    return self.games
end

--[[
    Get game by ID
    @param gameId string
    @return table|nil
]]
function DeathRollGame:GetGame(gameId)
    return self.games[gameId]
end

-- Register with addon
HopeAddon:RegisterModule("DeathRollGame", DeathRollGame)
HopeAddon.DeathRollGame = DeathRollGame

HopeAddon:Debug("DeathRollGame module loaded")
