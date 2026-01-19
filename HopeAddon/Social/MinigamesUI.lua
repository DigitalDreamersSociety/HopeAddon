--[[
    HopeAddon MinigamesUI Module
    UI components for Dice Rolling and Rock-Paper-Scissors minigames

    Refactored to create UI elements once and reuse them to prevent memory leaks
]]

local MinigamesUI = {}
HopeAddon.MinigamesUI = MinigamesUI

-- Use centralized backdrop frame creation from Core.lua
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

-- Local references
local Components = nil  -- Set in OnEnable

-- Frame references
MinigamesUI.challengePopup = nil
MinigamesUI.gameFrame = nil

-- Constants
local POPUP_WIDTH = 300
local POPUP_HEIGHT = 150
local GAME_WIDTH = 350
local GAME_HEIGHT = 280
local RPS_BUTTON_SIZE = 64

-- RPS icons (using existing game icons)
local RPS_ICONS = {
    rock = "Interface\\Icons\\Spell_Nature_EarthShock",
    paper = "Interface\\Icons\\INV_Scroll_02",
    scissors = "Interface\\Icons\\INV_Weapon_ShortBlade_02",
}

-- Result display colors (deduplicated from ShowDiceResult/ShowRPSResult)
local RESULT_DISPLAY = {
    win = { color = "00FF00", label = "YOU WIN!" },
    lose = { color = "FF0000", label = "YOU LOSE" },
    tie = { color = "FFFF00", label = "TIE!" },
}

-- Game ID to display name mapping (moved to top for early reference)
local GAME_NAMES = {
    dice = "Dice Roll",
    rps = "Rock-Paper-Scissors",
    deathroll = "Death Roll",
    pong = "Pong",
    tetris = "Tetris Battle",
    words = "Words with Wow",
    DICE = "Dice Roll",
    RPS = "Rock-Paper-Scissors",
    DEATHROLL = "Death Roll",
    PONG = "Pong",
    TETRIS = "Tetris Battle",
    WORDS = "Words with Wow",
}

--============================================================
-- MODULE-SCOPE BUTTON HANDLERS
-- (Avoids creating closures on each frame creation)
--============================================================

-- Challenge popup handlers
local function OnChallengeAccept(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    local popup = self:GetParent()
    local challengeData = popup.challengeData

    if not challengeData then
        HopeAddon:Debug("No challenge data found")
        popup:Hide()
        return
    end

    -- Route based on system
    if challengeData.source == "gamecore" then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:SendAccept(challengeData.challenger, challengeData.sessionId, challengeData.gameType)
        end
    else
        -- Legacy system
        if popup.Minigames then
            popup.Minigames:AcceptChallenge()
        end
    end

    popup:Hide()
end

local function OnChallengeDecline(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    local popup = self:GetParent()
    local challengeData = popup.challengeData

    if not challengeData then
        HopeAddon:Debug("No challenge data found")
        popup:Hide()
        return
    end

    -- Route based on system
    if challengeData.source == "gamecore" then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:SendDecline(challengeData.challenger, challengeData.sessionId, challengeData.gameType)
        end
    else
        -- Legacy system
        if popup.Minigames then
            popup.Minigames:DeclineChallenge()
        end
    end

    popup:Hide()
end

-- Game frame handlers
local function OnGameFrameClose(self)
    local frame = self:GetParent()
    if frame.Minigames and frame.Minigames.activeGame then
        frame.Minigames:CancelGame("user_cancelled")
    end
    frame:Hide()
end

local function OnGameFrameKeyDown(self, key)
    if key == "ESCAPE" then
        if self.Minigames and self.Minigames.activeGame then
            self.Minigames:CancelGame("user_cancelled")
        end
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

local function OnDoneButtonClick(self)
    local buttonContainer = self:GetParent()
    local frame = buttonContainer:GetParent()
    frame:Hide()
end

-- Dice game handlers
local function OnDiceRollClick(self)
    local container = self:GetParent()
    local content = container:GetParent()
    local frame = content:GetParent()
    if frame.Minigames then
        frame.Minigames:MakeMove()
    end
    self:Disable()
    self:SetText("Rolling...")
end

-- RPS game handlers
local function OnRPSChoiceClick(self)
    local buttonRow = self:GetParent()
    local container = buttonRow:GetParent()
    local content = container:GetParent()
    local frame = content:GetParent()
    if frame.Minigames then
        frame.Minigames:MakeMove(self.choice)
    end
end

-- Cancel button handler (waiting for accept screen)
local function OnWaitingCancelClick(self)
    local container = self:GetParent()
    local content = container:GetParent()
    local frame = content:GetParent()
    if frame.Minigames then
        frame.Minigames:CancelGame("user_cancelled")
    end
    frame:Hide()
end

-- Game selection popup handlers
local function OnGameButtonClick(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    local popup = self:GetParent():GetParent()
    local gameDef = self.gameDef

    if not popup.targetName or not gameDef then
        HopeAddon:Debug("Invalid game selection state")
        popup:Hide()
        return
    end

    -- Route based on game system
    if gameDef.system == "legacy" then
        -- Use legacy challenge system
        if popup.Minigames then
            popup.Minigames:SendChallenge(popup.targetName, gameDef.id)
        end
    else
        -- Use GameCore challenge system
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:SendInvite(popup.targetName, gameDef.id:upper(), 0)
        end
    end

    popup:Hide()
end

local function OnGameButtonEnter(self)
    self:SetBackdropBorderColor(1, 0.84, 0, 1)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayPageTurn()
    end
end

local function OnGameButtonLeave(self)
    self:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
end

local function OnGameSelectionCancel(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    self:GetParent():Hide()
end

local function OnGameSelectionKeyDown(self, key)
    if key == "ESCAPE" then
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

-- Challenge popup ESC handler
local function OnChallengePopupKeyDown(self, key)
    if key == "ESCAPE" then
        -- Treat ESC as decline
        OnChallengeDecline(self.declineBtn)
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

--============================================================
-- LIFECYCLE
--============================================================

function MinigamesUI:OnInitialize()
    -- Nothing at init
end

function MinigamesUI:OnEnable()
    Components = HopeAddon.Components
    HopeAddon:Debug("MinigamesUI module enabled")
end

function MinigamesUI:OnDisable()
    -- Hide all frames
    if self.challengePopup then
        self.challengePopup:Hide()
    end
    if self.gameFrame then
        self.gameFrame:Hide()
    end
end

--============================================================
-- CHALLENGE POPUP
--============================================================

--[[
    Create or return the challenge popup frame
]]
function MinigamesUI:GetChallengePopup()
    if self.challengePopup then
        return self.challengePopup
    end

    -- Create popup frame
    local popup = CreateBackdropFrame("Frame", "HopeMinigameChallengePopup", UIParent)
    popup:SetSize(POPUP_WIDTH, POPUP_HEIGHT)
    popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
    popup:SetFrameStrata("DIALOG")
    HopeAddon.Components:ApplyBackdrop(popup, "PARCHMENT_GOLD_SMALL", "PARCHMENT", "GOLD")
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("MINIGAME CHALLENGE", "GOLD_BRIGHT"))
    popup.title = title

    -- Challenge text
    local challengeText = popup:CreateFontString(nil, "OVERLAY")
    challengeText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    challengeText:SetPoint("TOP", title, "BOTTOM", 0, -15)
    challengeText:SetWidth(POPUP_WIDTH - 40)
    challengeText:SetJustifyH("CENTER")
    challengeText:SetTextColor(0.1, 0.1, 0.1, 1)
    popup.challengeText = challengeText

    -- Timer text
    local timerText = popup:CreateFontString(nil, "OVERLAY")
    timerText:SetFont(HopeAddon.assets.fonts.SMALL, 11)
    timerText:SetPoint("BOTTOM", popup, "BOTTOM", 0, 15)
    timerText:SetTextColor(0.5, 0.5, 0.5, 1)
    popup.timerText = timerText

    -- Cache Minigames module reference for button handlers
    popup.Minigames = HopeAddon:GetModule("Minigames")

    -- Accept button
    local acceptBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    acceptBtn:SetSize(80, 24)
    acceptBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 40, 35)
    acceptBtn:SetText("Accept")
    acceptBtn:SetScript("OnClick", OnChallengeAccept)
    popup.acceptBtn = acceptBtn

    -- Decline button
    local declineBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    declineBtn:SetSize(80, 24)
    declineBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -40, 35)
    declineBtn:SetText("Decline")
    declineBtn:SetScript("OnClick", OnChallengeDecline)
    popup.declineBtn = declineBtn

    -- Close (X) button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function(self)
        OnChallengeDecline(self:GetParent().declineBtn)
    end)

    -- ESC key handling
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", OnChallengePopupKeyDown)

    -- Timer update
    popup.timerTicker = nil
    popup.expiresAt = 0

    popup:Hide()
    self.challengePopup = popup
    return popup
end

--[[
    Show challenge popup
    @param challenger string - Challenger name
    @param gameType string - Game type ID (e.g., "dice", "pong", "TETRIS")
    @param sessionId string - Challenge session ID
    @param source string - "legacy" or "gamecore" (defaults to "legacy" for backwards compatibility)
]]
function MinigamesUI:ShowChallengePopup(challenger, gameType, sessionId, source)
    local popup = self:GetChallengePopup()

    -- Default to legacy for backwards compatibility
    source = source or "legacy"

    -- Store challenge data for Accept/Decline handlers
    popup.challengeData = {
        challenger = challenger,
        gameType = gameType,
        sessionId = sessionId,
        source = source,
    }

    -- Get game display name
    local gameLabel = GAME_NAMES[gameType] or gameType
    popup.challengeText:SetText("|cFF00FF00" .. challenger .. "|r\nchallenges you to\n|cFFFFD700" .. gameLabel .. "|r!")

    -- Start countdown
    popup.expiresAt = GetTime() + 30
    popup.timerText:SetText("Expires in: 30s")

    -- Cancel existing ticker
    if popup.timerTicker then
        popup.timerTicker:Cancel()
    end

    -- Start new ticker
    popup.timerTicker = HopeAddon.Timer:NewTicker(1, function()
        local remaining = math.max(0, math.floor(popup.expiresAt - GetTime()))
        popup.timerText:SetText("Expires in: " .. remaining .. "s")

        if remaining <= 0 then
            popup.timerTicker:Cancel()
            popup.timerTicker = nil
        end
    end)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    popup:Show()
end

--[[
    Hide challenge popup
]]
function MinigamesUI:HideChallengePopup()
    if self.challengePopup then
        if self.challengePopup.timerTicker then
            self.challengePopup.timerTicker:Cancel()
            self.challengePopup.timerTicker = nil
        end
        self.challengePopup:Hide()
    end
end

--============================================================
-- GAME FRAME
--============================================================

--[[
    Create or return the game frame with all persistent UI elements
]]
function MinigamesUI:GetGameFrame()
    if self.gameFrame then
        return self.gameFrame
    end

    -- Create main game frame
    local frame = CreateBackdropFrame("Frame", "HopeMinigameFrame", UIParent)
    frame:SetSize(GAME_WIDTH, GAME_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    frame:SetFrameStrata("DIALOG")
    HopeAddon.Components:ApplyBackdrop(frame, "PARCHMENT_GOLD_SMALL", "PARCHMENT", "GOLD")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Cache Minigames module reference for button handlers
    frame.Minigames = HopeAddon:GetModule("Minigames")

    -- ESC key handling
    frame:EnableKeyboard(true)
    frame:SetScript("OnKeyDown", OnGameFrameKeyDown)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", OnGameFrameClose)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.title = title

    -- Status text
    local statusText = frame:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    statusText:SetPoint("TOP", title, "BOTTOM", 0, -10)
    statusText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.statusText = statusText

    -- Content container (for dice/RPS specific content)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -70)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 50)
    frame.content = content

    -- Bottom buttons container
    local buttonContainer = CreateFrame("Frame", nil, frame)
    buttonContainer:SetHeight(40)
    buttonContainer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 10)
    buttonContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 10)
    frame.buttonContainer = buttonContainer

    -- Play Again button (hidden by default)
    local playAgainBtn = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    playAgainBtn:SetSize(100, 24)
    playAgainBtn:SetPoint("LEFT", buttonContainer, "LEFT", 20, 0)
    playAgainBtn:SetText("Play Again")
    playAgainBtn:Hide()
    frame.playAgainBtn = playAgainBtn

    -- Close/Done button
    local doneBtn = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    doneBtn:SetSize(80, 24)
    doneBtn:SetPoint("RIGHT", buttonContainer, "RIGHT", -20, 0)
    doneBtn:SetText("Close")
    doneBtn:SetScript("OnClick", OnDoneButtonClick)
    doneBtn:Hide()
    frame.doneBtn = doneBtn

    -- Create all persistent game containers
    self:CreateDiceContainer(frame, content)
    self:CreateRPSContainer(frame, content)
    self:CreateRPSResultContainer(frame, content)
    self:CreateWaitingContainer(frame, content)
    self:CreateDeclinedContainer(frame, content)

    frame:Hide()
    self.gameFrame = frame
    return frame
end

--[[
    Create persistent dice game container
]]
function MinigamesUI:CreateDiceContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.diceContainer = container

    -- Player roll display (left side)
    local playerLabel = container:CreateFontString(nil, "OVERLAY")
    playerLabel:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    playerLabel:SetPoint("CENTER", container, "CENTER", -70, 60)
    playerLabel:SetText("You")
    playerLabel:SetTextColor(0.2, 0.2, 0.2, 1)
    frame.dicePlayerLabel = playerLabel

    local playerRollFrame = CreateBackdropFrame("Frame", nil, container)
    playerRollFrame:SetSize(80, 80)
    playerRollFrame:SetPoint("TOP", playerLabel, "BOTTOM", 0, -10)
    HopeAddon.Components:ApplyBackdropRaw(playerRollFrame, "TOOLTIP", 0.95, 0.95, 0.9, 1, 0.6, 0.5, 0.3, 1)

    local playerRollText = playerRollFrame:CreateFontString(nil, "OVERLAY")
    playerRollText:SetFont(HopeAddon.assets.fonts.TITLE, 32)
    playerRollText:SetPoint("CENTER", playerRollFrame, "CENTER", 0, 0)
    playerRollText:SetText("?")
    playerRollText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.playerRollText = playerRollText

    -- VS text
    local vsText = container:CreateFontString(nil, "OVERLAY")
    vsText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    vsText:SetPoint("CENTER", container, "CENTER", 0, 20)
    vsText:SetText("vs")
    vsText:SetTextColor(0.5, 0.5, 0.5, 1)

    -- Opponent roll display (right side)
    local oppLabel = container:CreateFontString(nil, "OVERLAY")
    oppLabel:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    oppLabel:SetPoint("CENTER", container, "CENTER", 70, 60)
    oppLabel:SetText("Opponent")
    oppLabel:SetTextColor(0.2, 0.2, 0.2, 1)
    frame.diceOppLabel = oppLabel

    local oppRollFrame = CreateBackdropFrame("Frame", nil, container)
    oppRollFrame:SetSize(80, 80)
    oppRollFrame:SetPoint("TOP", oppLabel, "BOTTOM", 0, -10)
    HopeAddon.Components:ApplyBackdropRaw(oppRollFrame, "TOOLTIP", 0.95, 0.95, 0.9, 1, 0.6, 0.5, 0.3, 1)

    local oppRollText = oppRollFrame:CreateFontString(nil, "OVERLAY")
    oppRollText:SetFont(HopeAddon.assets.fonts.TITLE, 32)
    oppRollText:SetPoint("CENTER", oppRollFrame, "CENTER", 0, 0)
    oppRollText:SetText("?")
    oppRollText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.oppRollText = oppRollText

    -- Roll button
    local rollBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    rollBtn:SetSize(100, 28)
    rollBtn:SetPoint("BOTTOM", container, "BOTTOM", 0, 10)
    rollBtn:SetText("Roll Dice!")
    rollBtn:SetScript("OnClick", OnDiceRollClick)
    frame.rollBtn = rollBtn

    -- Result text (hidden initially)
    local resultText = container:CreateFontString(nil, "OVERLAY")
    resultText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    resultText:SetPoint("BOTTOM", rollBtn, "TOP", 0, 15)
    resultText:SetText("")
    resultText:Hide()
    frame.diceResultText = resultText
end

--[[
    Create persistent RPS game container
]]
function MinigamesUI:CreateRPSContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.rpsContainer = container

    -- Instructions
    local instructions = container:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(HopeAddon.assets.fonts.BODY, 12)
    instructions:SetPoint("TOP", container, "TOP", 0, 0)
    instructions:SetText("Choose your weapon:")
    instructions:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.rpsInstructions = instructions

    -- Choice buttons container
    local buttonRow = CreateFrame("Frame", nil, container)
    buttonRow:SetSize(3 * RPS_BUTTON_SIZE + 40, RPS_BUTTON_SIZE + 20)
    buttonRow:SetPoint("CENTER", container, "CENTER", 0, 0)

    local choices = {"rock", "paper", "scissors"}
    local choiceLabels = {rock = "Rock", paper = "Paper", scissors = "Scissors"}
    frame.rpsButtons = {}

    for i, choice in ipairs(choices) do
        local btn = CreateBackdropFrame("Button", nil, buttonRow)
        btn:SetSize(RPS_BUTTON_SIZE, RPS_BUTTON_SIZE)
        btn:SetPoint("LEFT", buttonRow, "LEFT", (i - 1) * (RPS_BUTTON_SIZE + 20), 0)
        -- TBC Theme: Using ARCANE_PURPLE for minigames UI (matches social theme)
        HopeAddon.Components:ApplyBackdrop(btn, "BORDER_ONLY_TOOLTIP", nil, "ARCANE_PURPLE")

        -- Icon texture
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        icon:SetTexture(RPS_ICONS[choice])
        btn.icon = icon

        -- Highlight
        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetPoint("TOPLEFT", 3, -3)
        highlight:SetPoint("BOTTOMRIGHT", -3, 3)
        highlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
        highlight:SetBlendMode("ADD")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Label below
        local label = buttonRow:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        label:SetPoint("TOP", btn, "BOTTOM", 0, -5)
        label:SetText(choiceLabels[choice])
        label:SetTextColor(0.4, 0.4, 0.4, 1)

        btn.choice = choice
        btn:SetScript("OnClick", OnRPSChoiceClick)

        frame.rpsButtons[choice] = btn
    end

    -- Status area for waiting messages
    local waitStatus = container:CreateFontString(nil, "OVERLAY")
    waitStatus:SetFont(HopeAddon.assets.fonts.BODY, 11)
    waitStatus:SetPoint("BOTTOM", container, "BOTTOM", 0, 20)
    waitStatus:SetText("")
    waitStatus:SetTextColor(0.5, 0.5, 0.5, 1)
    frame.rpsWaitStatus = waitStatus
end

--[[
    Create persistent RPS result container
]]
function MinigamesUI:CreateRPSResultContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.rpsResultContainer = container

    -- Your choice icon
    local myIcon = container:CreateTexture(nil, "ARTWORK")
    myIcon:SetSize(48, 48)
    myIcon:SetPoint("LEFT", container, "CENTER", -80, 10)
    frame.rpsResultMyIcon = myIcon

    -- Your label
    local myLabel = container:CreateFontString(nil, "OVERLAY")
    myLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    myLabel:SetPoint("TOP", myIcon, "BOTTOM", 0, -5)
    myLabel:SetText("You")
    myLabel:SetTextColor(0.4, 0.4, 0.4, 1)

    -- VS text
    local vsText = container:CreateFontString(nil, "OVERLAY")
    vsText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    vsText:SetPoint("CENTER", container, "CENTER", 0, 10)
    vsText:SetText("vs")
    vsText:SetTextColor(0.5, 0.5, 0.5, 1)

    -- Opponent choice icon
    local oppIcon = container:CreateTexture(nil, "ARTWORK")
    oppIcon:SetSize(48, 48)
    oppIcon:SetPoint("RIGHT", container, "CENTER", 80, 10)
    frame.rpsResultOppIcon = oppIcon

    -- Opponent label
    local oppLabel = container:CreateFontString(nil, "OVERLAY")
    oppLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    oppLabel:SetPoint("TOP", oppIcon, "BOTTOM", 0, -5)
    oppLabel:SetText("Them")
    oppLabel:SetTextColor(0.4, 0.4, 0.4, 1)

    -- Result text
    local resultText = container:CreateFontString(nil, "OVERLAY")
    resultText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    resultText:SetPoint("BOTTOM", container, "BOTTOM", 0, 20)
    frame.rpsResultText = resultText
end

--[[
    Create persistent waiting container
]]
function MinigamesUI:CreateWaitingContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.waitingContainer = container

    -- Waiting message
    local waitingText = container:CreateFontString(nil, "OVERLAY")
    waitingText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    waitingText:SetPoint("CENTER", container, "CENTER", 0, 20)
    waitingText:SetJustifyH("CENTER")
    waitingText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.waitingText = waitingText

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    cancelBtn:SetSize(100, 24)
    cancelBtn:SetPoint("BOTTOM", container, "BOTTOM", 0, 10)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", OnWaitingCancelClick)
    frame.waitingCancelBtn = cancelBtn
end

--[[
    Create persistent declined container
]]
function MinigamesUI:CreateDeclinedContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.declinedContainer = container

    -- Declined message
    local msg = container:CreateFontString(nil, "OVERLAY")
    msg:SetFont(HopeAddon.assets.fonts.BODY, 12)
    msg:SetPoint("CENTER", container, "CENTER", 0, 0)
    msg:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.declinedMsg = msg
end

-- Container name to frame reference mapping
local CONTAINER_MAP = {
    dice = "diceContainer",
    rps = "rpsContainer",
    rpsResult = "rpsResultContainer",
    waiting = "waitingContainer",
    declined = "declinedContainer",
}

--[[
    Hide all game containers
]]
function MinigamesUI:HideAllContainers()
    local frame = self.gameFrame
    if not frame then return end

    for _, containerKey in pairs(CONTAINER_MAP) do
        if frame[containerKey] then
            frame[containerKey]:Hide()
        end
    end

    -- Reset buttons
    if frame.playAgainBtn then frame.playAgainBtn:Hide() end
    if frame.doneBtn then frame.doneBtn:Hide() end
end

--[[
    Show a specific container by name, hiding all others
    @param containerType string - "dice", "rps", "rpsResult", "waiting", or "declined"
]]
function MinigamesUI:ShowContainer(containerType)
    local frame = self.gameFrame
    if not frame then return end

    self:HideAllContainers()

    local containerKey = CONTAINER_MAP[containerType]
    if containerKey and frame[containerKey] then
        frame[containerKey]:Show()
    end
end

--[[
    Clear game frame content (no longer orphans frames)
]]
function MinigamesUI:ClearGameContent()
    self:HideAllContainers()
end

--============================================================
-- DICE GAME UI
--============================================================

--[[
    Show dice game board
    @param opponent string - Opponent name
]]
function MinigamesUI:ShowDiceGame(opponent)
    self:HideChallengePopup()

    local frame = self:GetGameFrame()
    self:ShowContainer("dice")

    -- Update header
    frame.title:SetText(HopeAddon:ColorText("DICE ROLL", "GOLD_BRIGHT"))
    frame.statusText:SetText("vs |cFF00FF00" .. opponent .. "|r - Click to /roll")

    -- Reset dice display
    frame.diceOppLabel:SetText(opponent)
    frame.playerRollText:SetText("?")
    frame.playerRollText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.oppRollText:SetText("?")
    frame.oppRollText:SetTextColor(0.3, 0.3, 0.3, 1)

    -- Reset roll button
    frame.rollBtn:Enable()
    frame.rollBtn:SetText("Roll Dice!")
    frame.rollBtn:Show()

    -- Hide result text
    frame.diceResultText:SetText("")
    frame.diceResultText:Hide()

    frame:Show()
end

--[[
    Update dice roll display
    @param roll number - Roll value
    @param isPlayer boolean - Is this the player's roll?
]]
function MinigamesUI:OnDiceRolled(roll, isPlayer)
    local frame = self.gameFrame
    if not frame then return end

    if isPlayer then
        if frame.playerRollText then
            frame.playerRollText:SetText(tostring(roll))
            frame.playerRollText:SetTextColor(0.1, 0.1, 0.1, 1)
        end
        if frame.rollBtn then
            frame.rollBtn:SetText("Rolled!")
        end
    else
        if frame.oppRollText then
            frame.oppRollText:SetText(tostring(roll))
            frame.oppRollText:SetTextColor(0.1, 0.1, 0.1, 1)
        end
    end

    -- Play dice sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Handle roll requested - update button to show "Rolling..."
]]
function MinigamesUI:OnRollRequested()
    local frame = self.gameFrame
    if not frame or not frame.rollBtn then return end

    frame.rollBtn:Disable()
    frame.rollBtn:SetText("Rolling...")
end

--[[
    Show dice game result
    @param myRoll number
    @param oppRoll number
    @param result string - "win", "lose", or "tie"
]]
function MinigamesUI:ShowDiceResult(myRoll, oppRoll, result)
    local frame = self.gameFrame
    if not frame then return end

    -- Update result text using RESULT_DISPLAY table
    if frame.diceResultText then
        local display = RESULT_DISPLAY[result] or RESULT_DISPLAY.tie
        frame.diceResultText:SetText("|cFF" .. display.color .. display.label .. "|r")
        frame.diceResultText:Show()
    end

    -- Hide roll button, show done button
    if frame.rollBtn then
        frame.rollBtn:Hide()
    end
    if frame.doneBtn then
        frame.doneBtn:Show()
    end

    -- Play result sound
    if HopeAddon.Sounds then
        if result == "win" then
            HopeAddon.Sounds:PlayAchievement()
        else
            HopeAddon.Sounds:PlayClick()
        end
    end
end

--============================================================
-- RPS GAME UI
--============================================================

--[[
    Show Rock-Paper-Scissors game board
    @param opponent string - Opponent name
]]
function MinigamesUI:ShowRPSGame(opponent)
    self:HideChallengePopup()

    local frame = self:GetGameFrame()
    self:ShowContainer("rps")

    -- Update header
    frame.title:SetText(HopeAddon:ColorText("ROCK PAPER SCISSORS", "ARCANE_PURPLE"))
    frame.statusText:SetText("vs |cFF00FF00" .. opponent .. "|r")

    -- Reset RPS buttons
    for _, btn in pairs(frame.rpsButtons or {}) do
        btn:Enable()
        btn.icon:SetVertexColor(1, 1, 1, 1)
        btn:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
    end

    -- Reset instructions and status
    frame.rpsInstructions:SetText("Choose your weapon:")
    frame.rpsWaitStatus:SetText("")

    frame:Show()
end

--[[
    Handle player RPS choice made
    @param choice string
]]
function MinigamesUI:OnRPSChoiceMade(choice)
    local frame = self.gameFrame
    if not frame then return end

    -- Disable all buttons and highlight selected
    for c, btn in pairs(frame.rpsButtons or {}) do
        if c == choice then
            btn:SetBackdropBorderColor(0, 1, 0, 1)  -- Green border on selected
            btn:Disable()
        else
            btn.icon:SetVertexColor(0.5, 0.5, 0.5, 1)  -- Grey out others
            btn:Disable()
        end
    end

    -- Update status
    if frame.rpsWaitStatus then
        frame.rpsWaitStatus:SetText("Choice locked! Waiting for opponent...")
    end

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Handle opponent RPS committed (but not revealed)
]]
function MinigamesUI:OnOpponentRPSCommitted()
    local frame = self.gameFrame
    if not frame then return end

    if frame.rpsWaitStatus then
        local current = frame.rpsWaitStatus:GetText() or ""
        if current:find("Waiting") then
            frame.rpsWaitStatus:SetText("Opponent ready! Revealing...")
        end
    end
end

--[[
    Show RPS game result
    @param myChoice string
    @param oppChoice string
    @param result string - "win", "lose", or "tie"
]]
function MinigamesUI:ShowRPSResult(myChoice, oppChoice, result)
    local frame = self.gameFrame
    if not frame then return end

    self:ShowContainer("rpsResult")

    -- Update result icons
    if frame.rpsResultMyIcon then
        frame.rpsResultMyIcon:SetTexture(RPS_ICONS[myChoice])
    end
    if frame.rpsResultOppIcon then
        frame.rpsResultOppIcon:SetTexture(RPS_ICONS[oppChoice])
    end

    -- Update result text using RESULT_DISPLAY table
    if frame.rpsResultText then
        local display = RESULT_DISPLAY[result] or RESULT_DISPLAY.tie
        frame.rpsResultText:SetText("|cFF" .. display.color .. display.label .. "|r")
    end

    -- Show done button
    if frame.doneBtn then
        frame.doneBtn:Show()
    end

    -- Play result sound
    if HopeAddon.Sounds then
        if result == "win" then
            HopeAddon.Sounds:PlayAchievement()
        else
            HopeAddon.Sounds:PlayClick()
        end
    end
end

--============================================================
-- WAITING/STATUS UI
--============================================================

--[[
    Show waiting for accept state
    @param opponent string
    @param gameType string
]]
function MinigamesUI:ShowWaitingForAccept(opponent, gameType)
    self:HideChallengePopup()

    local frame = self:GetGameFrame()
    self:ShowContainer("waiting")

    local gameLabel = gameType == "dice" and "Dice Roll" or "Rock-Paper-Scissors"
    frame.title:SetText(HopeAddon:ColorText("CHALLENGE SENT", "GOLD_BRIGHT"))
    frame.statusText:SetText("")

    -- Update waiting text
    frame.waitingText:SetText("Waiting for |cFF00FF00" .. opponent .. "|r\nto accept your " .. gameLabel .. " challenge...")

    frame:Show()
end

--[[
    Handle challenge rejected
    @param opponent string
    @param reason string
]]
function MinigamesUI:OnChallengeRejected(opponent, reason)
    local frame = self.gameFrame
    if not frame then return end

    self:ShowContainer("declined")

    frame.title:SetText(HopeAddon:ColorText("CHALLENGE DECLINED", "HELLFIRE_RED"))

    local reasonText = reason == "busy" and " (busy)" or ""
    if frame.declinedMsg then
        frame.declinedMsg:SetText(opponent .. " declined your challenge" .. reasonText)
    end

    -- Show done button
    if frame.doneBtn then
        frame.doneBtn:Show()
    end
end

--[[
    Handle game cancelled
    @param reason string
]]
function MinigamesUI:OnGameCancelled(reason)
    if self.gameFrame then
        self.gameFrame:Hide()
    end
    self:HideChallengePopup()
end

--============================================================
-- GAME SELECTION POPUP (Challenge Initiation)
--============================================================

-- Game selection popup constants
local GAME_SELECTION_WIDTH = 400
local GAME_SELECTION_HEIGHT = 280
local GAME_ICON_SIZE = 48

-- Game icons
local GAME_ICONS = {
    dice = "Interface\\Icons\\INV_Misc_Dice_02",
    rps = "Interface\\Icons\\Spell_Nature_EarthShock",
    deathroll = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
    pong = "Interface\\Icons\\INV_Misc_PunchCards_Yellow",
    tetris = "Interface\\Icons\\INV_Misc_Gem_Variety_01",
    words = "Interface\\Icons\\INV_Misc_Book_07",
}

-- Game definitions for selection popup
local GAME_DEFINITIONS = {
    {id = "dice", name = "Dice Roll", system = "legacy"},
    {id = "rps", name = "Rock Paper Scissors", system = "legacy"},
    {id = "deathroll", name = "Death Roll", system = "legacy"},
    {id = "pong", name = "Pong", system = "gamecore"},
    {id = "tetris", name = "Tetris Battle", system = "gamecore"},
    {id = "words", name = "Words with Wow", system = "gamecore"},
}

--[[
    Create or return the game selection popup
]]
function MinigamesUI:GetGameSelectionPopup()
    if self.gameSelectionPopup then
        return self.gameSelectionPopup
    end

    -- Create popup frame with parchment backdrop
    local popup = CreateBackdropFrame("Frame", "HopeGameSelectionPopup", UIParent)
    popup:SetSize(GAME_SELECTION_WIDTH, GAME_SELECTION_HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    HopeAddon.Components:ApplyBackdrop(popup, "PARCHMENT_GOLD_SMALL", "PARCHMENT", "GOLD")
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("CHALLENGE", "GOLD_BRIGHT"))
    popup.title = title

    -- Target name
    local targetText = popup:CreateFontString(nil, "OVERLAY")
    targetText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    targetText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    targetText:SetTextColor(0.1, 0.6, 0.1, 1)
    popup.targetText = targetText

    -- Instructions
    local instructions = popup:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    instructions:SetPoint("TOP", targetText, "BOTTOM", 0, -10)
    instructions:SetText("Select a game:")
    instructions:SetTextColor(0.4, 0.4, 0.4, 1)

    -- Cache Minigames module reference for button handlers
    popup.Minigames = HopeAddon:GetModule("Minigames")

    -- Game buttons container (3 rows x 2 columns grid)
    local buttonContainer = CreateFrame("Frame", nil, popup)
    buttonContainer:SetSize(GAME_SELECTION_WIDTH - 40, 200)
    buttonContainer:SetPoint("TOP", instructions, "BOTTOM", 0, -15)

    -- Create buttons dynamically from GAME_DEFINITIONS
    local BUTTON_SPACING_X = 20
    local BUTTON_SPACING_Y = 15
    local LABEL_OFFSET_Y = 5
    local COLS = 2

    for i, gameDef in ipairs(GAME_DEFINITIONS) do
        local row = math.floor((i - 1) / COLS)
        local col = (i - 1) % COLS

        -- Calculate position
        local xOffset = 40 + col * (GAME_ICON_SIZE + BUTTON_SPACING_X + 50)
        local yOffset = -10 - row * (GAME_ICON_SIZE + BUTTON_SPACING_Y + 15)

        -- Create button
        local btn = CreateBackdropFrame("Button", nil, buttonContainer)
        btn:SetSize(GAME_ICON_SIZE, GAME_ICON_SIZE)
        btn:SetPoint("TOPLEFT", buttonContainer, "TOPLEFT", xOffset, yOffset)
        -- TBC Theme: Using ARCANE_PURPLE for minigames UI (matches social theme)
        HopeAddon.Components:ApplyBackdrop(btn, "BORDER_ONLY_TOOLTIP", nil, "ARCANE_PURPLE")

        -- Store game definition reference
        btn.gameDef = gameDef

        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        icon:SetTexture(GAME_ICONS[gameDef.id])

        -- Highlight
        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetPoint("TOPLEFT", 3, -3)
        highlight:SetPoint("BOTTOMRIGHT", -3, 3)
        highlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
        highlight:SetBlendMode("ADD")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Label
        local label = buttonContainer:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.SMALL, 9)
        label:SetPoint("TOP", btn, "BOTTOM", 0, -LABEL_OFFSET_Y)
        label:SetText(gameDef.name)
        label:SetTextColor(0.4, 0.4, 0.4, 1)

        -- Attach handlers
        btn:SetScript("OnClick", OnGameButtonClick)
        btn:SetScript("OnEnter", OnGameButtonEnter)
        btn:SetScript("OnLeave", OnGameButtonLeave)
    end

    -- Close (X) button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", OnGameSelectionCancel)

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 22)
    cancelBtn:SetPoint("BOTTOM", popup, "BOTTOM", 0, 15)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", OnGameSelectionCancel)

    -- Close on escape
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", OnGameSelectionKeyDown)

    popup:Hide()
    self.gameSelectionPopup = popup
    return popup
end

--[[
    Show game selection popup for challenging a player
    @param targetName string - Name of the player to challenge
]]
function MinigamesUI:ShowGameSelectionPopup(targetName)
    if not targetName or targetName == "" then return end

    -- Hide conflicting popups first
    self:HideTravelerPickerPopup()
    self:HideChallengePopup()

    local popup = self:GetGameSelectionPopup()

    -- Store target
    popup.targetName = targetName

    -- Update display
    popup.targetText:SetText(targetName)

    -- Position (center of screen)
    popup:ClearAllPoints()
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    popup:Show()
end

--[[
    Hide game selection popup
]]
function MinigamesUI:HideGameSelectionPopup()
    if self.gameSelectionPopup then
        self.gameSelectionPopup:Hide()
    end
end

--============================================================
-- TRAVELER PICKER POPUP (Challenge from Games Hall)
--============================================================

-- Traveler picker popup constants
local TRAVELER_PICKER_WIDTH = 300
local TRAVELER_PICKER_HEIGHT = 350
local TRAVELER_BUTTON_HEIGHT = 36

-- Handler for traveler button click (module-level to avoid closure)
local function OnTravelerButtonClick(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    local popup = self:GetParent():GetParent()
    local gameId = popup.selectedGameId
    local travelerName = self.travelerName

    if not gameId or not travelerName then
        HopeAddon:Debug("Invalid traveler picker state")
        popup:Hide()
        return
    end

    -- Get game definition
    local Constants = HopeAddon.Constants
    local gameDef = Constants and Constants:GetGameDefinition(gameId)

    if not gameDef then
        HopeAddon:Debug("Unknown game:", gameId)
        popup:Hide()
        return
    end

    -- Route based on game system
    if gameDef.system == "legacy" then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:SendChallenge(travelerName, gameId)
        end
    else
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:SendInvite(travelerName, gameId:upper(), 0)
        end
    end

    popup:Hide()
end

local function OnTravelerButtonEnter(self)
    self:SetBackdropBorderColor(1, 0.84, 0, 1)
end

local function OnTravelerButtonLeave(self)
    self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function OnTravelerPickerCancel(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    self:GetParent():Hide()
end

local function OnTravelerPickerKeyDown(self, key)
    if key == "ESCAPE" then
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

--[[
    Create or return the traveler picker popup
]]
function MinigamesUI:GetTravelerPickerPopup()
    if self.travelerPickerPopup then
        return self.travelerPickerPopup
    end

    -- Create popup frame with parchment backdrop
    local popup = CreateBackdropFrame("Frame", "HopeTravelerPickerPopup", UIParent)
    popup:SetSize(TRAVELER_PICKER_WIDTH, TRAVELER_PICKER_HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    HopeAddon.Components:ApplyBackdrop(popup, "PARCHMENT_GOLD_SMALL", "PARCHMENT", "GOLD")
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("SELECT OPPONENT", "GOLD_BRIGHT"))
    popup.title = title

    -- Game name display
    local gameText = popup:CreateFontString(nil, "OVERLAY")
    gameText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    gameText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    gameText:SetTextColor(0.6, 0.2, 0.8, 1)  -- ARCANE_PURPLE
    popup.gameText = gameText

    -- Instructions
    local instructions = popup:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    instructions:SetPoint("TOP", gameText, "BOTTOM", 0, -10)
    instructions:SetText("Choose a Fellow Traveler to challenge:")
    instructions:SetTextColor(0.4, 0.4, 0.4, 1)

    -- Scroll frame for traveler list
    local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", 15, -75)
    scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -35, 55)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetWidth(scrollFrame:GetWidth())
    scrollContent:SetHeight(1)
    scrollFrame:SetScrollChild(scrollContent)

    popup.scrollFrame = scrollFrame
    popup.scrollContent = scrollContent

    -- Traveler buttons pool
    popup.travelerButtons = {}

    -- Store origin context (set when opening from Games Hall)
    popup.originGameId = nil

    -- Close (X) button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", OnTravelerPickerCancel)

    -- Back button (left side, only shown when there's navigation history)
    local backBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    backBtn:SetSize(80, 22)
    backBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 15, 15)
    backBtn:SetText("Back")
    backBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayClick()
        end
        popup:Hide()
        -- Back just closes the popup (Games Hall remains visible)
    end)
    backBtn:Hide()  -- Only show when there's navigation history
    popup.backBtn = backBtn

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 22)
    cancelBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -15, 15)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", OnTravelerPickerCancel)

    -- No travelers message
    local noTravelersText = popup:CreateFontString(nil, "OVERLAY")
    noTravelersText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    noTravelersText:SetPoint("CENTER", scrollFrame, "CENTER", 0, 0)
    noTravelersText:SetText("No Fellow Travelers online.\n\nGroup up with addon users\nto discover them!")
    noTravelersText:SetTextColor(0.5, 0.5, 0.5, 1)
    noTravelersText:SetJustifyH("CENTER")
    noTravelersText:Hide()
    popup.noTravelersText = noTravelersText

    -- Close on escape
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", OnTravelerPickerKeyDown)

    popup:Hide()
    self.travelerPickerPopup = popup
    return popup
end

--[[
    Create or reuse a traveler button for the picker list
    @param index number - Button index
    @param parent Frame - Parent frame
    @return Button - Traveler selection button
]]
function MinigamesUI:GetTravelerButton(index, parent)
    local popup = self.travelerPickerPopup
    if not popup then return nil end

    -- Reuse existing button if available
    if popup.travelerButtons[index] then
        return popup.travelerButtons[index]
    end

    -- Create new button
    local btn = CreateBackdropFrame("Button", nil, parent)
    btn:SetSize(TRAVELER_PICKER_WIDTH - 50, TRAVELER_BUTTON_HEIGHT)
    HopeAddon.Components:ApplyBackdrop(btn, "TOOLTIP_SMALL", "DARK_TRANSPARENT", "GREY")

    -- Name text
    local nameText = btn:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    nameText:SetPoint("LEFT", btn, "LEFT", 10, 4)
    btn.nameText = nameText

    -- Level/Class text
    local infoText = btn:CreateFontString(nil, "OVERLAY")
    infoText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
    infoText:SetPoint("LEFT", btn, "LEFT", 10, -8)
    infoText:SetTextColor(0.6, 0.6, 0.6, 1)
    btn.infoText = infoText

    -- Highlight
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.2)

    -- Handlers
    btn:SetScript("OnClick", OnTravelerButtonClick)
    btn:SetScript("OnEnter", OnTravelerButtonEnter)
    btn:SetScript("OnLeave", OnTravelerButtonLeave)

    popup.travelerButtons[index] = btn
    return btn
end

--[[
    Show traveler picker popup for a specific game
    @param gameId string - Game ID to challenge with
]]
function MinigamesUI:ShowTravelerPickerForGame(gameId)
    if not gameId then return end

    -- Hide conflicting popups first
    self:HideGameSelectionPopup()
    self:HideChallengePopup()

    local popup = self:GetTravelerPickerPopup()
    local Constants = HopeAddon.Constants

    -- Store selected game and origin context
    popup.selectedGameId = gameId
    popup.originGameId = gameId  -- Mark that we came from Games Hall

    -- Show Back button when opened from Games Hall
    if popup.backBtn then
        popup.backBtn:Show()
    end

    -- Get game display name
    local gameDef = Constants and Constants:GetGameDefinition(gameId)
    local gameName = gameDef and gameDef.name or gameId
    popup.gameText:SetText(gameName)

    -- Clear existing buttons
    for _, btn in ipairs(popup.travelerButtons) do
        btn:Hide()
    end

    -- Get fellow travelers from Directory module
    local Directory = HopeAddon.Directory
    local fellows = {}

    if Directory then
        local entries = Directory:GetFilteredEntries() or {}
        for _, entry in ipairs(entries) do
            if entry.isFellow then
                table.insert(fellows, entry)
            end
        end
    end

    -- Show/hide no travelers message (TBC compatible - no SetShown)
    if #fellows == 0 then
        popup.noTravelersText:Show()
    else
        popup.noTravelersText:Hide()
    end
    if #fellows > 0 then
        popup.scrollContent:Show()
    else
        popup.scrollContent:Hide()
    end

    if #fellows > 0 then
        -- Create buttons for each fellow traveler
        local yOffset = 0
        for i, fellow in ipairs(fellows) do
            local btn = self:GetTravelerButton(i, popup.scrollContent)

            -- Configure button
            btn.travelerName = fellow.name

            -- Set name with class color
            local classColor = fellow.class and HopeAddon:GetClassColor(fellow.class) or { r = 1, g = 1, b = 1 }
            local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
            btn.nameText:SetText("|cFF" .. colorHex .. fellow.name .. "|r")

            -- Set info text
            local infoParts = {}
            if fellow.level then
                table.insert(infoParts, "Level " .. fellow.level)
            end
            if fellow.class then
                table.insert(infoParts, fellow.class)
            end
            btn.infoText:SetText(table.concat(infoParts, " - "))

            -- Position
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", popup.scrollContent, "TOPLEFT", 0, -yOffset)
            btn:Show()

            yOffset = yOffset + TRAVELER_BUTTON_HEIGHT + 5
        end

        -- Update content height for scrolling
        popup.scrollContent:SetHeight(yOffset)
    end

    -- Position popup
    popup:ClearAllPoints()
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayBell()
    end

    popup:Show()
end

--[[
    Hide traveler picker popup
]]
function MinigamesUI:HideTravelerPickerPopup()
    if self.travelerPickerPopup then
        self.travelerPickerPopup:Hide()
    end
end

-- Register module
HopeAddon:RegisterModule("MinigamesUI", MinigamesUI)
HopeAddon:Debug("MinigamesUI module loaded")
