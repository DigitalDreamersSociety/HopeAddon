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
-- Set to false since we now send rolls over network
DeathRollGame.PROXIMITY_REQUIRED = false

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

-- Cached module references
DeathRollGame.GameCore = nil
DeathRollGame.GameComms = nil
DeathRollGame.GameUI = nil

--============================================================
-- LIFECYCLE
--============================================================

function DeathRollGame:OnInitialize()
    HopeAddon:Debug("DeathRollGame initializing...")
end

function DeathRollGame:OnEnable()
    -- Cache module references
    self.GameCore = HopeAddon:GetModule("GameCore")
    self.GameComms = HopeAddon:GetModule("GameComms")
    self.GameUI = HopeAddon:GetModule("GameUI")

    -- Register with GameCore
    if self.GameCore then
        self.GameCore:RegisterGame(self.GameCore.GAME_TYPE.DEATH_ROLL, self)
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
    if self.GameComms then
        self.GameComms:RegisterHandler("DEATH_ROLL", "MOVE", function(sender, gameId, data)
            self:HandleRemoteRoll(sender, gameId, data)
        end)
        self.GameComms:RegisterHandler("DEATH_ROLL", "STATE", function(sender, gameId, data)
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
        self.eventFrame = nil
    end
end

--============================================================
-- GAME LIFECYCLE (Called by GameCore)
--============================================================

--[[
    Called when game is created
]]
function DeathRollGame:OnCreate(gameId, game)
    -- Initialize death roll specific data with ui/state structure
    game.data = {
        ui = {
            window = nil,
            maxValueText = nil,
            turnText = nil,
            historyText = nil,
            proximityText = nil,
        },
        state = {
            maxRoll = self.DEFAULT_MAX_ROLL,
            currentMax = self.DEFAULT_MAX_ROLL,
            rollHistory = {},
            rollState = self.ROLL_STATE.WAITING_TO_START,
            betAmount = 0,
            escrowEnabled = false,
            escrowHouse = nil,
            proximityVerified = false,
            animating = false,  -- Block rolls during gameshow animation
        },
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

    local state = game.data.state

    -- Check proximity for remote games
    if self.PROXIMITY_REQUIRED and self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE then
        local inProximity, reason = self:IsOpponentInProximity(game.opponent)
        if not inProximity then
            HopeAddon:Print("|cFFFF0000Death Roll requires proximity!|r")
            HopeAddon:Print(reason)
            HopeAddon:Print("Both players must be visible to each other for verified rolls.")
            self.GameCore:EndGame(gameId, "proximity_required")
            return
        end
        -- Store initial proximity status
        state.proximityVerified = true
    end

    -- Determine who goes first (coin flip or initiator)
    state.rollState = self.ROLL_STATE.PLAYER1_TURN

    -- Show UI
    self:ShowUI(gameId)

    -- Check if practice mode for funny messages
    local isPracticeMode = self.GameCore and game.mode == self.GameCore.GAME_MODE.LOCAL

    if isPracticeMode then
        HopeAddon:Print("Death Roll Practice started! Time to battle... yourself!")
        HopeAddon:Print("Type /roll " .. state.currentMax .. " (you'll be rolling for both sides)")
    else
        HopeAddon:Print("Death Roll started! " .. game.player1 .. " rolls first.")
        HopeAddon:Print("Type /roll " .. state.currentMax .. " to roll")
    end
end

-- Funny practice mode messages (random selection)
DeathRollGame.PRACTICE_JOKES = {
    "Congratulations, you beat yourself!",
    "You won! ...against yourself. We won't tell anyone.",
    "Victory! Your other hand is crying.",
    "You defeated your inner demons! (It was just you.)",
    "Winner winner! But also loser loser?",
    "Flawless victory over... yourself!",
    "You're your own worst enemy. Literally.",
    "At least you can't lose to yourself... wait.",
}

--[[
    Called when game ends
]]
function DeathRollGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    if not game.data then return end

    local state = game.data.state

    state.rollState = self.ROLL_STATE.FINISHED

    -- Check if this is a practice/local game (playing against yourself)
    local playerName = UnitName("player")
    local isPracticeMode = self.GameCore and game.mode == self.GameCore.GAME_MODE.LOCAL

    -- Determine loser/winner
    if game.winner then
        local loser = game.winner == game.player1 and game.player2 or game.player1

        if isPracticeMode then
            -- Funny message for practice mode
            HopeAddon:Print("Death Roll Practice ended!")
        else
            HopeAddon:Print("Death Roll ended! " .. loser .. " loses!")
        end

        if state.betAmount > 0 then
            HopeAddon:Print(loser .. " owes " .. HopeAddon:FormatGold(state.betAmount * 10000))
        end
    end

    -- Record stats for remote games
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE and game.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames and Minigames.RecordGameResult then
            local result = (game.winner == playerName) and "win" or "lose"
            local betAmount = state.betAmount or 0
            Minigames:RecordGameResult(game.opponent, "deathroll", result, betAmount)
        end
    end

    -- Show game over UI
    if self.GameUI then
        local stats = {
            ["Total Rolls"] = #state.rollHistory,
            ["Starting Max"] = state.maxRoll,
        }
        if state.betAmount > 0 then
            stats["Bet"] = HopeAddon:FormatGold(state.betAmount * 10000)
        end

        -- Add funny joke for practice mode
        if isPracticeMode then
            local joke = self.PRACTICE_JOKES[math.random(#self.PRACTICE_JOKES)]
            stats[""] = joke  -- Empty key for clean display
        end

        -- For practice mode, always show as "victory" since you won against yourself
        local displayWinner = isPracticeMode and playerName or game.winner
        self.GameUI:ShowGameOver(gameId, displayWinner, stats)
    end
end

--[[
    Called when game is destroyed
]]
function DeathRollGame:OnDestroy(gameId)
    self:CleanupGame(gameId)
end

--[[
    Cleanup all game resources
]]
function DeathRollGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game then
        self.games[gameId] = nil
        return
    end

    -- Cleanup escrow session if active
    if game.data and game.data.state then
        local state = game.data.state
        if state.betAmount and state.betAmount > 0 then
            local Escrow = HopeAddon:GetModule("DeathRollEscrow")
            if Escrow then
                Escrow:CancelEscrow(gameId)
            end
        end
    end

    -- Cleanup gameshow UI frames
    local DeathRollUI = HopeAddon:GetModule("DeathRollUI")
    if DeathRollUI then
        DeathRollUI:CleanupGameshowFrames(gameId)
    end

    -- Release UI frame references
    if game.data and game.data.ui then
        local ui = game.data.ui

        if ui.window then
            ui.window:Hide()
            ui.window = nil
        end

        -- Wipe entire ui table to ensure all references are cleared
        wipe(ui)
    end

    -- GameUI handles window destruction
    if self.GameUI then
        self.GameUI:DestroyGameWindow(gameId)
    end

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
            -- fromNetwork=false because we detected this from CHAT_MSG_SYSTEM (local roll)
            self:ProcessRoll(gameId, playerName, rollResult, maxRoll, false)
            return
        end
    end
end

--[[
    Check if a roll is valid for the given game
]]
function DeathRollGame:IsValidRoll(game, playerName, maxRoll)
    if not game.data then return false end

    local state = game.data.state

    -- Game must be in progress
    if state.rollState == self.ROLL_STATE.FINISHED then
        return false
    end

    if state.rollState == self.ROLL_STATE.WAITING_TO_START then
        return false
    end

    -- Block rolls during animation sequence
    if state.animating then
        return false
    end

    -- Check max roll matches expected
    if maxRoll ~= state.currentMax then
        return false
    end

    -- Validate roll is within expected bounds (sanity check)
    -- Note: actual roll value is validated in ProcessRoll
    if maxRoll < 1 then
        return false
    end

    -- Check if this is practice mode (playing against yourself)
    local isPracticeMode = self.GameCore and game.mode == self.GameCore.GAME_MODE.LOCAL
    local localPlayerName = UnitName("player")

    if isPracticeMode then
        -- In practice mode, the local player rolls for both sides
        -- The roll message will always say their actual name (not "Name (2)")
        if playerName ~= localPlayerName then
            return false
        end
        -- Allow roll for either turn since it's the same person
        return true
    end

    -- Remote game: check if player is in this game
    local isPlayer1 = playerName == game.player1
    local isPlayer2 = playerName == game.player2

    if not isPlayer1 and not isPlayer2 then
        return false
    end

    -- Check if it's their turn
    if state.rollState == self.ROLL_STATE.PLAYER1_TURN and not isPlayer1 then
        return false
    end
    if state.rollState == self.ROLL_STATE.PLAYER2_TURN and not isPlayer2 then
        return false
    end

    return true
end

--[[
    Process a valid roll with gameshow animation sequence
    @param fromNetwork boolean - True if this roll came from network (don't re-send)
]]
function DeathRollGame:ProcessRoll(gameId, playerName, rollResult, maxRoll, fromNetwork)
    local game = self.games[gameId]
    if not game then return end

    if not game.data or not game.data.state then
        HopeAddon:Debug("ProcessRoll: Invalid game data for", gameId)
        return
    end

    local state = game.data.state

    -- Validate roll result is within expected bounds
    if type(rollResult) ~= "number" or rollResult < 1 or rollResult > maxRoll then
        HopeAddon:Debug("ProcessRoll: Invalid roll result", rollResult, "max", maxRoll)
        return
    end

    -- Validate maxRoll matches expected
    if maxRoll ~= state.currentMax then
        HopeAddon:Debug("ProcessRoll: Max mismatch - expected", state.currentMax, "got", maxRoll)
        return
    end

    local localPlayerName = UnitName("player")
    local isLocalPlayer = (playerName == localPlayerName)

    -- Block further rolls during animation
    state.animating = true

    -- If this is a LOCAL roll (detected from our /roll), send it to the opponent
    -- Do this BEFORE animation so opponent receives it promptly
    if isLocalPlayer and not fromNetwork then
        if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE then
            if self.GameComms then
                local moveData = string.format("%d|%d", rollResult, maxRoll)
                self.GameComms:SendMove(game.opponent, "DEATH_ROLL", gameId, moveData)
                HopeAddon:Debug("Sent roll to opponent:", rollResult, "/", maxRoll)
            end
        end
    end

    -- Record roll
    table.insert(state.rollHistory, {
        player = playerName,
        roll = rollResult,
        max = maxRoll,
        timestamp = GetTime(),
    })

    -- Trigger gameshow animation sequence
    local DeathRollUI = HopeAddon:GetModule("DeathRollUI")
    if DeathRollUI then
        DeathRollUI:ShowRollResult(gameId, rollResult, maxRoll, playerName, isLocalPlayer)
    end

    -- Update basic UI (history, etc.)
    self:UpdateUI(gameId)

    -- Delay game state update for animation (1.2 seconds)
    local ANIMATION_DELAY = 1.2

    HopeAddon.Timer:After(ANIMATION_DELAY, function()
        -- Re-fetch game in case it was destroyed
        local currentGame = self.games[gameId]
        if not currentGame or not currentGame.data then return end

        local currentState = currentGame.data.state

        -- Check for loss (rolled 1)
        if rollResult == 1 then
            -- This player loses
            local winner = playerName == currentGame.player1 and currentGame.player2 or currentGame.player1
            currentState.animating = false
            if self.GameCore then
                self.GameCore:SetWinner(gameId, winner)
            end
            return
        end

        -- Update current max and switch turns
        currentState.currentMax = rollResult

        -- Check if this is practice mode (playing against yourself)
        local isPracticeMode = self.GameCore and currentGame.mode == self.GameCore.GAME_MODE.LOCAL

        local nextPlayerName
        local isYourTurn = false

        if currentState.rollState == self.ROLL_STATE.PLAYER1_TURN then
            currentState.rollState = self.ROLL_STATE.PLAYER2_TURN
            nextPlayerName = currentGame.player2
            -- In practice mode, it's always your turn (you're both players)
            isYourTurn = isPracticeMode or (nextPlayerName == localPlayerName)
        else
            currentState.rollState = self.ROLL_STATE.PLAYER1_TURN
            nextPlayerName = currentGame.player1
            -- In practice mode, it's always your turn (you're both players)
            isYourTurn = isPracticeMode or (nextPlayerName == localPlayerName)
        end

        -- Show turn prompt with gameshow style
        if DeathRollUI then
            local opponentName = isYourTurn and nil or nextPlayerName
            DeathRollUI:ShowTurnPrompt(gameId, rollResult, isYourTurn, opponentName)
        end

        -- Print turn message to chat (backup for non-gameshow clients)
        if isPracticeMode then
            -- Funny message for practice mode turns
            local turnSide = currentState.rollState == self.ROLL_STATE.PLAYER1_TURN and "You" or "Also You"
            HopeAddon:Print(turnSide .. "'s turn. /roll " .. rollResult)
        else
            HopeAddon:Print(nextPlayerName .. "'s turn. /roll " .. rollResult)
        end

        -- Unblock rolls
        currentState.animating = false
    end)
end

--============================================================
-- REMOTE GAME HANDLING
--============================================================

--[[
    Handle roll from remote player
]]
function DeathRollGame:HandleRemoteRoll(sender, gameId, data)
    -- Validate sender
    if not sender or sender == "" then
        HopeAddon:Debug("HandleRemoteRoll: Invalid sender")
        return
    end

    -- Validate data format
    if not data or data == "" then
        HopeAddon:Debug("HandleRemoteRoll: Empty data")
        return
    end

    local rollResult, maxRoll = strsplit("|", data)
    rollResult = tonumber(rollResult)
    maxRoll = tonumber(maxRoll)

    if not rollResult or not maxRoll then
        HopeAddon:Debug("HandleRemoteRoll: Invalid data format -", data)
        return
    end

    local game = self.games[gameId]
    if not game then
        HopeAddon:Debug("HandleRemoteRoll: Game not found:", gameId)
        return
    end

    -- Validate sender is our opponent (security check)
    if game.opponent and sender ~= game.opponent then
        HopeAddon:Debug("HandleRemoteRoll: Sender mismatch - expected", game.opponent, "got", sender)
        return
    end

    -- Validate the roll is legitimate
    if not self:IsValidRoll(game, sender, maxRoll) then
        HopeAddon:Debug("HandleRemoteRoll: Invalid roll from", sender, "- not their turn or wrong max")
        return
    end

    -- Validate roll result is within bounds
    if rollResult < 1 or rollResult > maxRoll then
        HopeAddon:Debug("HandleRemoteRoll: Roll out of bounds:", rollResult, "max:", maxRoll)
        return
    end

    HopeAddon:Debug("Received remote roll from", sender, ":", rollResult, "/", maxRoll)

    -- Process the roll with fromNetwork=true so we don't re-send it
    self:ProcessRoll(gameId, sender, rollResult, maxRoll, true)
end

--[[
    Handle state sync from remote player
]]
function DeathRollGame:HandleRemoteState(sender, gameId, data)
    -- Validate sender
    if not sender or sender == "" then
        HopeAddon:Debug("HandleRemoteState: Invalid sender")
        return
    end

    -- Validate data
    if not data or data == "" then
        HopeAddon:Debug("HandleRemoteState: Empty data")
        return
    end

    local rollResult, playerName = strsplit("|", data)
    rollResult = tonumber(rollResult)

    if not rollResult then
        HopeAddon:Debug("HandleRemoteState: Invalid roll result in data")
        return
    end

    local game = self.games[gameId]
    if not game or not game.data then
        HopeAddon:Debug("HandleRemoteState: Game not found:", gameId)
        return
    end

    -- Validate sender is our opponent
    if game.opponent and sender ~= game.opponent then
        HopeAddon:Debug("HandleRemoteState: Sender mismatch - expected", game.opponent, "got", sender)
        return
    end

    local state = game.data.state
    if not state then
        HopeAddon:Debug("HandleRemoteState: Invalid game state")
        return
    end

    -- Validate roll result is reasonable (sanity check)
    if rollResult < 1 or rollResult > 1000000 then
        HopeAddon:Debug("HandleRemoteState: Invalid roll value:", rollResult)
        return
    end

    -- Sync our state
    state.currentMax = rollResult

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
    Show Death Roll UI with gameshow-style layout
]]
function DeathRollGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    if not self.GameUI then return end

    local ui = game.data.ui
    local state = game.data.state
    local localPlayerName = UnitName("player")

    -- Check if practice mode (playing against yourself)
    local isPracticeMode = self.GameCore and game.mode == self.GameCore.GAME_MODE.LOCAL

    -- Create larger game window for gameshow display (fun title for practice)
    local windowTitle = isPracticeMode and "DEATH ROLL (Solo Edition)" or "DEATH ROLL"
    local window = self.GameUI:CreateGameWindow(gameId, windowTitle, "MEDIUM")
    if not window then return end

    -- Store window reference for cleanup
    ui.window = window

    local content = window.content

    -- Player names header (funny names for practice mode)
    local p1Name = isPracticeMode and "You" or game.player1
    local p2Name = isPracticeMode and "Also You" or game.player2

    local p1Label = self.GameUI:CreateLabel(content, p1Name, "GameFontNormalLarge")
    p1Label:SetPoint("TOPLEFT", 15, -10)
    p1Label:SetTextColor(0.2, 0.9, 0.2)

    local vsLabel = self.GameUI:CreateLabel(content, "VS", "GameFontNormal")
    vsLabel:SetPoint("TOP", 0, -12)
    vsLabel:SetTextColor(0.7, 0.7, 0.7)

    local p2Label = self.GameUI:CreateLabel(content, p2Name, "GameFontNormalLarge")
    p2Label:SetPoint("TOPRIGHT", -15, -10)
    p2Label:SetTextColor(0.9, 0.2, 0.2)

    -- Initialize gameshow UI frames (big number, turn prompt)
    local DeathRollUI = HopeAddon:GetModule("DeathRollUI")
    if DeathRollUI then
        DeathRollUI:InitializeGameshowFrames(gameId, content)
        -- Show initial max as the big number
        DeathRollUI:UpdateBigNumber(gameId, state.currentMax)
    end

    -- Roll history at bottom
    local historyLabel = self.GameUI:CreateLabel(content, "History", "GameFontNormalSmall")
    historyLabel:SetPoint("BOTTOMLEFT", 15, 35)
    historyLabel:SetTextColor(0.5, 0.5, 0.5)

    local historyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    historyText:SetPoint("BOTTOMLEFT", 15, 10)
    historyText:SetPoint("BOTTOMRIGHT", -15, 10)
    historyText:SetHeight(20)
    historyText:SetJustifyH("LEFT")
    historyText:SetJustifyV("BOTTOM")
    historyText:SetText("")
    historyText:SetTextColor(0.6, 0.6, 0.6)
    ui.historyText = historyText

    -- Bet display (if betting)
    if state.betAmount > 0 then
        local betLabel = self.GameUI:CreateLabel(content, "Pot: " .. HopeAddon:FormatGold(state.betAmount * 2 * 10000), "GameFontNormal")
        betLabel:SetPoint("TOP", content, "TOP", 0, -35)
        betLabel:SetTextColor(1, 0.84, 0)
    end

    -- Proximity status indicator (for remote games)
    if self.GameCore and game.mode == self.GameCore.GAME_MODE.REMOTE then
        local proximityText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        proximityText:SetPoint("BOTTOM", content, "BOTTOM", 0, 3)
        if state.proximityVerified then
            proximityText:SetText("|cFF00FF00Rolls verified|r")
        else
            proximityText:SetText("|cFFFFFF00Unverified|r")
        end
        ui.proximityText = proximityText
    end

    window:Show()

    -- Show initial turn prompt
    -- In practice mode, it's always your turn (you're both players)
    local isYourTurn
    if isPracticeMode then
        isYourTurn = true  -- Always your turn in practice mode
    else
        isYourTurn = (state.rollState == self.ROLL_STATE.PLAYER1_TURN and game.player1 == localPlayerName)
            or (state.rollState == self.ROLL_STATE.PLAYER2_TURN and game.player2 == localPlayerName)
    end
    local opponentName = isYourTurn and nil or (state.rollState == self.ROLL_STATE.PLAYER1_TURN and game.player1 or game.player2)

    if DeathRollUI then
        DeathRollUI:ShowTurnPrompt(gameId, state.currentMax, isYourTurn, opponentName)
    end

    -- Update basic UI
    self:UpdateUI(gameId)
end

--[[
    Update UI elements
]]
function DeathRollGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Update max value
    if ui.maxValueText then
        ui.maxValueText:SetText(tostring(state.currentMax))
    end

    -- Update turn indicator
    if ui.turnText then
        local turnText = ""
        if state.rollState == self.ROLL_STATE.PLAYER1_TURN then
            turnText = game.player1 .. "'s turn"
        elseif state.rollState == self.ROLL_STATE.PLAYER2_TURN then
            turnText = game.player2 .. "'s turn"
        elseif state.rollState == self.ROLL_STATE.FINISHED then
            turnText = "Game Over!"
        else
            turnText = "Waiting to start..."
        end
        ui.turnText:SetText(turnText)
    end

    -- Update history
    if ui.historyText then
        local historyLines = {}
        local startIdx = math.max(1, #state.rollHistory - 4)  -- Show last 5
        for i = startIdx, #state.rollHistory do
            local roll = state.rollHistory[i]
            table.insert(historyLines, roll.player .. ": " .. roll.roll)
        end
        ui.historyText:SetText(table.concat(historyLines, " > "))
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Start a new Death Roll game
    @param opponent string|nil - Opponent name (nil for local/practice)
    @param betAmount number|nil - Gold bet in gold units
    @param maxRoll number|nil - Starting max (default 1000)
    @return string|nil - Game ID or nil if validation fails
]]
function DeathRollGame:StartGame(opponent, betAmount, maxRoll)
    if not self.GameCore then
        HopeAddon:Debug("StartGame failed: GameCore not available")
        return nil
    end

    -- Validate maxRoll
    maxRoll = maxRoll or self.DEFAULT_MAX_ROLL
    if type(maxRoll) ~= "number" or maxRoll < 2 then
        HopeAddon:Print("|cFFFF0000Invalid max roll!|r Must be at least 2.")
        return nil
    end
    if maxRoll > 1000000 then
        HopeAddon:Print("|cFFFF0000Max roll too high!|r Maximum is 1,000,000.")
        return nil
    end

    -- Validate betAmount
    betAmount = betAmount or 0
    if type(betAmount) ~= "number" or betAmount < 0 then
        betAmount = 0
    end

    -- Validate opponent name (if provided)
    if opponent then
        if type(opponent) ~= "string" or opponent == "" then
            HopeAddon:Print("|cFFFF0000Invalid opponent name!|r")
            return nil
        end
        -- Can't play against yourself in remote mode
        if opponent == UnitName("player") then
            HopeAddon:Print("|cFFFFFF00Want to practice? Use the Practice button instead!|r")
            return nil
        end
    end

    -- Check for existing active game (prevent multiple games)
    for existingGameId, existingGame in pairs(self.games) do
        if existingGame.data and existingGame.data.state then
            local existingState = existingGame.data.state
            if existingState.rollState ~= self.ROLL_STATE.FINISHED then
                HopeAddon:Print("|cFFFF0000You already have an active Death Roll game!|r")
                HopeAddon:Print("Finish or cancel it first.")
                return nil
            end
        end
    end

    local mode = opponent and self.GameCore.GAME_MODE.REMOTE or self.GameCore.GAME_MODE.LOCAL
    local gameId = self.GameCore:CreateGame(self.GameCore.GAME_TYPE.DEATH_ROLL, mode, opponent)

    if not gameId then
        HopeAddon:Print("|cFFFF0000Failed to create game!|r")
        return nil
    end

    local game = self.GameCore:GetGame(gameId)
    if not game or not game.data or not game.data.state then
        HopeAddon:Print("|cFFFF0000Failed to initialize game!|r")
        return nil
    end

    local state = game.data.state
    state.maxRoll = maxRoll
    state.currentMax = state.maxRoll
    state.betAmount = betAmount

    -- If local/practice mode, set player 2 as the local player
    if not opponent then
        game.player2 = UnitName("player") .. " (2)"
    end

    self.GameCore:StartGame(gameId)

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
