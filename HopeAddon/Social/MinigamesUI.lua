--[[
    HopeAddon MinigamesUI Module
    UI components for Rock-Paper-Scissors minigame

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

-- Practice mode popup constants
local PRACTICE_MODE_WIDTH = 300
local PRACTICE_MODE_HEIGHT = 220

-- RPS Local Game UI Constants (organized for clarity)
local RPS_UI = {
    -- Frame dimensions (larger than default to fit all content)
    FRAME_WIDTH = 380,
    FRAME_HEIGHT = 420,
    BUTTON_SIZE = 64,
    CHOICE_SECTION_WIDTH = 120,
    CHOICE_SECTION_HEIGHT = 140,

    -- Font sizes (reduced from original to prevent overlap)
    TITLE_FONT_SIZE = 18,
    STATUS_FONT_SIZE = 18,      -- Reduced from 24
    RESULT_FONT_SIZE = 22,      -- Reduced from 28
    VS_FONT_SIZE = 20,
    LABEL_FONT_SIZE = 12,
    CHOICE_FONT_SIZE = 14,
    BUTTON_LABEL_SIZE = 10,

    -- Colors
    TITLE_COLOR = { 1, 0.84, 0 },         -- Gold
    YOUR_CHOICE_COLOR = { 0.3, 0.8, 0.3 }, -- Green
    AI_CHOICE_COLOR = { 0.8, 0.3, 0.3 },   -- Red
    VS_COLOR = { 1, 0.5, 0 },              -- Orange
    LABEL_COLOR = { 0.4, 0.4, 0.4 },       -- Grey

    -- Vertical offsets (from TOP of container unless noted)
    TITLE_OFFSET = -10,
    STATUS_OFFSET = -40,
    SECTIONS_OFFSET = -90,
    VS_OFFSET = -150,           -- Centered between sections
    RESULT_OFFSET = -250,
    BUTTONS_OFFSET = 85,        -- From BOTTOM
    PLAY_AGAIN_OFFSET = 20,     -- From BOTTOM

    -- Horizontal offsets for choice sections
    SECTION_H_OFFSET = 130,     -- Distance from center
}

-- RPS icons (using existing game icons)
local RPS_ICONS = {
    rock = "Interface\\Icons\\Spell_Nature_EarthShock",
    paper = "Interface\\Icons\\INV_Scroll_02",
    scissors = "Interface\\Icons\\INV_Weapon_ShortBlade_02",
}

-- Result display colors
local RESULT_DISPLAY = {
    win = { color = "00FF00", label = "YOU WIN!" },
    lose = { color = "FF0000", label = "YOU LOSE" },
    tie = { color = "FFFF00", label = "TIE!" },
}

-- Game ID to display name mapping (moved to top for early reference)
local GAME_NAMES = {
    rps = "Rock-Paper-Scissors",
    deathroll = "Death Roll",
    pong = "Pong of War",
    tetris = "Wowtris",
    words = "WoWdle",
    battleship = "Battleship",
    pacman = "Pac-Wow",
    RPS = "Rock-Paper-Scissors",
    DEATHROLL = "Death Roll",
    PONG = "Pong of War",
    TETRIS = "Wowtris",
    WORDS = "WoWdle",
    BATTLESHIP = "Battleship",
    PACMAN = "Pac-Wow",
    -- Score Challenge variants
    SCORE_TETRIS = "Wowtris Score Battle",
    SCORE_PONG = "Pong of War Score Battle",
    SCORE_PACMAN = "Pac-Wow Score Battle",
}

--============================================================
-- MODULE-SCOPE BUTTON HANDLERS
-- (Avoids creating closures on each frame creation)
--============================================================

-- Practice mode popup handlers
local function OnPracticeModeAI(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    -- Button is inside buttonContainer which is inside popup
    local popup = self:GetParent():GetParent()
    if popup.callback then
        popup.callback("ai")
    end
    popup:Hide()
end

local function OnPracticeModeLocal(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    -- Button is inside buttonContainer which is inside popup
    local popup = self:GetParent():GetParent()
    if popup.callback then
        popup.callback("local")
    end
    popup:Hide()
end

local function OnPracticeModeCancel(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    MinigamesUI:HidePracticeModePopup()
end

local function OnPracticeModeKeyDown(self, key)
    if key == "ESCAPE" then
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

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
    if challengeData.source == "scorechallenge" then
        -- Score Challenge system (Tetris/Pong Score Battle)
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:AcceptChallenge(challengeData.challenger)
        end
    elseif challengeData.source == "gamecore" then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:AcceptInvite(challengeData.challenger)
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
    if challengeData.source == "scorechallenge" then
        -- Score Challenge system (Tetris/Pong Score Battle)
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:DeclineChallenge(challengeData.challenger)
        end
    elseif challengeData.source == "gamecore" then
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:DeclineInvite(challengeData.challenger)
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
    -- Use HideGameFrame to reset size
    MinigamesUI:HideGameFrame()
end

local function OnGameFrameKeyDown(self, key)
    if key == "ESCAPE" then
        if self.Minigames and self.Minigames.activeGame then
            self.Minigames:CancelGame("user_cancelled")
        end
        -- Use HideGameFrame to reset size
        MinigamesUI:HideGameFrame()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

local function OnDoneButtonClick(self)
    -- Use HideGameFrame to reset size
    MinigamesUI:HideGameFrame()
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

    -- Use centralized challenge routing
    HopeAddon:SendChallenge(popup.targetName, gameDef.id)
    popup:Hide()
end

local function OnGameButtonEnter(self)
    self:SetBackdropBorderColor(1, 0.84, 0, 1)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayPageTurn()
    end
end

local function OnGameButtonLeave(self)
    local c = HopeAddon.colors.ARCANE_PURPLE
    self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
end

local function OnGameSelectionCancel(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
    MinigamesUI:HideGameSelectionPopup()
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
    -- Cancel challenge popup timer to prevent orphaned ticker
    if self.challengePopup then
        if self.challengePopup.timerTicker then
            self.challengePopup.timerTicker:Cancel()
            self.challengePopup.timerTicker = nil
        end
        self.challengePopup:Hide()
    end
    if self.gameFrame then
        self.gameFrame:Hide()
    end
end

--============================================================
-- FRAME SIZE MANAGEMENT
--============================================================

--[[
    Set frame to RPS-specific larger size with tiled parchment background
    Called when showing local RPS game
]]
function MinigamesUI:SetRPSFrameSize()
    local frame = self.gameFrame
    if frame then
        frame:SetSize(RPS_UI.FRAME_WIDTH, RPS_UI.FRAME_HEIGHT)
        -- Switch to PARCHMENT_TILED which scales properly at any size
        HopeAddon.Components:ApplyBackdrop(frame, "PARCHMENT_TILED", "PARCHMENT", "GOLD")
    end
end

--[[
    Reset frame to default size with original backdrop
    Called when hiding the game frame
]]
function MinigamesUI:ResetFrameSize()
    local frame = self.gameFrame
    if frame then
        frame:SetSize(GAME_WIDTH, GAME_HEIGHT)
        -- Switch back to original backdrop
        HopeAddon.Components:ApplyBackdrop(frame, "PARCHMENT_GOLD_SMALL", "PARCHMENT", "GOLD")
    end
end

--[[
    Hide game frame and reset to default size
]]
function MinigamesUI:HideGameFrame()
    if self.gameFrame then
        self.gameFrame:Hide()
        self:ResetFrameSize()
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("MINIGAME CHALLENGE", "GOLD_BRIGHT"))
    popup.title = title

    -- Challenge text
    local challengeText = popup:CreateFontString(nil, "OVERLAY")
    challengeText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    challengeText:SetPoint("TOP", title, "BOTTOM", 0, -15)
    challengeText:SetWidth(POPUP_WIDTH - 40)
    challengeText:SetJustifyH("CENTER")
    challengeText:SetTextColor(0.1, 0.1, 0.1, 1)
    popup.challengeText = challengeText

    -- Timer text
    local timerText = popup:CreateFontString(nil, "OVERLAY")
    timerText:SetFont(HopeAddon.assets.fonts.SMALL, 11, "")
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
    acceptBtn:SetScript("OnEnter", function(self)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    popup.acceptBtn = acceptBtn

    -- Decline button
    local declineBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    declineBtn:SetSize(80, 24)
    declineBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -40, 35)
    declineBtn:SetText("Decline")
    declineBtn:SetScript("OnClick", OnChallengeDecline)
    declineBtn:SetScript("OnEnter", function(self)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
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
    @param gameType string - Game type ID (e.g., "rps", "pong", "TETRIS")
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
    title:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.title = title

    -- Status text
    local statusText = frame:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    statusText:SetPoint("TOP", title, "BOTTOM", 0, -10)
    statusText:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.statusText = statusText

    -- Content container (for game-specific content)
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
    self:CreateRPSContainer(frame, content)
    self:CreateRPSResultContainer(frame, content)
    self:CreateWaitingContainer(frame, content)
    self:CreateDeclinedContainer(frame, content)
    self:CreateLocalRPSContainer(frame, content)

    frame:Hide()
    self.gameFrame = frame
    return frame
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
    instructions:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
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
        label:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        label:SetPoint("TOP", btn, "BOTTOM", 0, -5)
        label:SetText(choiceLabels[choice])
        label:SetTextColor(0.4, 0.4, 0.4, 1)

        btn.choice = choice
        btn:SetScript("OnClick", OnRPSChoiceClick)

        frame.rpsButtons[choice] = btn
    end

    -- Status area for waiting messages
    local waitStatus = container:CreateFontString(nil, "OVERLAY")
    waitStatus:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    myLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    myLabel:SetPoint("TOP", myIcon, "BOTTOM", 0, -5)
    myLabel:SetText("You")
    myLabel:SetTextColor(0.4, 0.4, 0.4, 1)

    -- VS text
    local vsText = container:CreateFontString(nil, "OVERLAY")
    vsText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
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
    oppLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    oppLabel:SetPoint("TOP", oppIcon, "BOTTOM", 0, -5)
    oppLabel:SetText("Them")
    oppLabel:SetTextColor(0.4, 0.4, 0.4, 1)

    -- Result text
    local resultText = container:CreateFontString(nil, "OVERLAY")
    resultText:SetFont(HopeAddon.assets.fonts.HEADER, 16, "")
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
    waitingText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
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
    msg:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    msg:SetPoint("CENTER", container, "CENTER", 0, 0)
    msg:SetTextColor(0.3, 0.3, 0.3, 1)
    frame.declinedMsg = msg
end

-- Container name to frame reference mapping
local CONTAINER_MAP = {
    rps = "rpsContainer",
    rpsResult = "rpsResultContainer",
    waiting = "waitingContainer",
    declined = "declinedContainer",
    localRPS = "localRPSContainer",
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
    @param containerType string - "rps", "rpsResult", "waiting", or "declined"
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

    -- Reset RPS buttons (TBC theme: arcane purple)
    local rpsColor = HopeAddon.colors.ARCANE_PURPLE
    for _, btn in pairs(frame.rpsButtons or {}) do
        btn:Enable()
        btn.icon:SetVertexColor(1, 1, 1, 1)
        btn:SetBackdropBorderColor(rpsColor.r, rpsColor.g, rpsColor.b, 1)
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

    -- Hide all buttons after selection
    for _, btn in pairs(frame.rpsButtons or {}) do
        btn:Hide()
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

    local gameLabel = GAME_NAMES[gameType] or "Rock-Paper-Scissors"
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
    self:HideGameFrame()
    self:HideChallengePopup()
end

--============================================================
-- GAME SELECTION POPUP (Challenge Initiation)
--============================================================

-- Game selection popup constants
local GAME_SELECTION_WIDTH = 400
local GAME_SELECTION_HEIGHT = 340  -- Increased from 280 to fit 3 rows of games (6 games total)
local GAME_ICON_SIZE = 48

-- Use centralized game definitions from Constants.lua (C.GAME_DEFINITIONS)
-- This avoids duplication and ensures consistency across the addon

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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("CHALLENGE", "GOLD_BRIGHT"))
    popup.title = title

    -- Target name
    local targetText = popup:CreateFontString(nil, "OVERLAY")
    targetText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    targetText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    targetText:SetTextColor(0.1, 0.6, 0.1, 1)
    popup.targetText = targetText

    -- Instructions
    local instructions = popup:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    instructions:SetPoint("TOP", targetText, "BOTTOM", 0, -10)
    instructions:SetText("Select a game:")
    instructions:SetTextColor(0.4, 0.4, 0.4, 1)

    -- Cache Minigames module reference for button handlers
    popup.Minigames = HopeAddon:GetModule("Minigames")

    -- Game buttons container (3 rows x 2 columns grid)
    local buttonContainer = CreateFrame("Frame", nil, popup)
    buttonContainer:SetSize(GAME_SELECTION_WIDTH - 40, 250)  -- Increased from 200 to fit 3 rows
    buttonContainer:SetPoint("TOP", instructions, "BOTTOM", 0, -15)

    -- Create buttons dynamically from centralized C.GAME_DEFINITIONS
    local BUTTON_SPACING_X = 20
    local BUTTON_SPACING_Y = 15
    local LABEL_OFFSET_Y = 5
    local COLS = 2
    local C = HopeAddon.Constants

    for i, gameDef in ipairs(C.GAME_DEFINITIONS) do
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

        -- Icon (use icon from Constants)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        icon:SetTexture(gameDef.icon)

        -- Highlight
        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetPoint("TOPLEFT", 3, -3)
        highlight:SetPoint("BOTTOMRIGHT", -3, 3)
        highlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
        highlight:SetBlendMode("ADD")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Label
        local label = buttonContainer:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
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
local RECENT_THRESHOLD = 300  -- 5 minutes - only show fellows seen within this time

-- Handler for traveler button click (module-level to avoid closure)
local function OnTravelerButtonClick(self)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    -- Use stored popup reference (button -> scrollContent -> scrollFrame -> popup)
    local popup = self.popup
    local gameId = popup and popup.selectedGameId
    local travelerName = self.travelerName

    if not gameId or not travelerName then
        HopeAddon:Debug("Invalid traveler picker state")
        if popup then popup:Hide() end
        return
    end

    -- Use centralized challenge routing
    HopeAddon:SendChallenge(travelerName, gameId)
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
    MinigamesUI:HideTravelerPickerPopup()
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("SELECT OPPONENT", "GOLD_BRIGHT"))
    popup.title = title

    -- Game name display
    local gameText = popup:CreateFontString(nil, "OVERLAY")
    gameText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    gameText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    gameText:SetTextColor(0.6, 0.2, 0.8, 1)  -- ARCANE_PURPLE
    popup.gameText = gameText

    -- Instructions
    local instructions = popup:CreateFontString(nil, "OVERLAY")
    instructions:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    noTravelersText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    noTravelersText:SetPoint("CENTER", scrollFrame, "CENTER", 0, 0)
    noTravelersText:SetText("No Fellow Travelers nearby.\n\nAddon users are discovered\nautomatically within ~300 yards.\n\nWait a moment or group up\nwith them to discover faster!")
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
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    nameText:SetPoint("LEFT", btn, "LEFT", 10, 4)
    btn.nameText = nameText

    -- Level/Class text
    local infoText = btn:CreateFontString(nil, "OVERLAY")
    infoText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
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

    -- Store reference to popup for click handler (avoids parent traversal issues)
    btn.popup = popup

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
    -- Only show fellows seen within RECENT_THRESHOLD (5 minutes) to ensure they're actually nearby/online
    local Directory = HopeAddon.Directory
    local fellows = {}
    local now = time()

    if Directory then
        local entries = Directory:GetFilteredEntries() or {}
        for _, entry in ipairs(entries) do
            if entry.isFellow then
                -- Filter by lastSeenTime - only show recently seen fellows
                local lastSeenTime = entry.lastSeenTime or 0
                if (now - lastSeenTime) <= RECENT_THRESHOLD then
                    -- Store the "last seen ago" for visual indicator
                    entry.lastSeenAgo = now - lastSeenTime
                    table.insert(fellows, entry)
                end
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

            -- Set name with class color and recency indicator
            local classColor = fellow.class and HopeAddon:GetClassColor(fellow.class) or { r = 1, g = 1, b = 1 }
            local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

            -- Add visual recency indicator
            local statusPrefix = ""
            local lastSeenAgo = fellow.lastSeenAgo or 0
            if lastSeenAgo < 60 then
                statusPrefix = "|cFF00FF00[Active]|r "  -- Green for <1 min
            elseif lastSeenAgo < 180 then
                statusPrefix = "|cFF00DD00[Recent]|r "  -- Light green for <3 min
            else
                statusPrefix = "|cFFFFFF00[Idle]|r "    -- Yellow for 3-5 min
            end
            btn.nameText:SetText(statusPrefix .. "|cFF" .. colorHex .. fellow.name .. "|r")

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

--============================================================
-- LOCAL RPS GAME (vs AI) - GAMESHOW STYLE UI
--============================================================

--[[
    Create persistent local RPS gameshow container
    Uses RPS_UI constants for organized sizing and positioning
]]
function MinigamesUI:CreateLocalRPSContainer(frame, content)
    local container = CreateFrame("Frame", nil, content)
    container:SetAllPoints()
    container:Hide()
    frame.localRPSContainer = container

    -- Title with opponent name (AI's name)
    local title = container:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, RPS_UI.TITLE_FONT_SIZE)
    title:SetPoint("TOP", container, "TOP", 0, RPS_UI.TITLE_OFFSET)
    title:SetTextColor(unpack(RPS_UI.TITLE_COLOR))
    frame.localRPSTitle = title

    -- Status text (reduced font size to prevent overlap)
    local statusText = container:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(HopeAddon.assets.fonts.HEADER, RPS_UI.STATUS_FONT_SIZE)
    statusText:SetPoint("TOP", container, "TOP", 0, RPS_UI.STATUS_OFFSET)
    statusText:SetWidth(280)  -- Constrain width to prevent overflow
    statusText:SetTextColor(1, 1, 1)
    frame.localRPSStatus = statusText

    -- Your choice section (left side, anchored from top)
    local yourSection = CreateFrame("Frame", nil, container)
    yourSection:SetSize(RPS_UI.CHOICE_SECTION_WIDTH, RPS_UI.CHOICE_SECTION_HEIGHT)
    yourSection:SetPoint("TOPLEFT", container, "TOP", -RPS_UI.SECTION_H_OFFSET, RPS_UI.SECTIONS_OFFSET)

    local yourLabel = yourSection:CreateFontString(nil, "OVERLAY")
    yourLabel:SetFont(HopeAddon.assets.fonts.BODY, RPS_UI.LABEL_FONT_SIZE)
    yourLabel:SetPoint("TOP", yourSection, "TOP", 0, 0)
    yourLabel:SetText("YOUR CHOICE")
    yourLabel:SetTextColor(unpack(RPS_UI.YOUR_CHOICE_COLOR))

    local yourIcon = yourSection:CreateTexture(nil, "ARTWORK")
    yourIcon:SetSize(RPS_UI.BUTTON_SIZE, RPS_UI.BUTTON_SIZE)
    yourIcon:SetPoint("CENTER", yourSection, "CENTER", 0, -10)
    yourIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.localRPSYourIcon = yourIcon

    local yourChoice = yourSection:CreateFontString(nil, "OVERLAY")
    yourChoice:SetFont(HopeAddon.assets.fonts.BODY, RPS_UI.CHOICE_FONT_SIZE)
    yourChoice:SetPoint("BOTTOM", yourSection, "BOTTOM", 0, 0)
    yourChoice:SetText("?")
    yourChoice:SetTextColor(1, 1, 1)
    frame.localRPSYourChoice = yourChoice

    -- VS text (centered between sections)
    local vsText = container:CreateFontString(nil, "OVERLAY")
    vsText:SetFont(HopeAddon.assets.fonts.HEADER, RPS_UI.VS_FONT_SIZE)
    vsText:SetPoint("TOP", container, "TOP", 0, RPS_UI.VS_OFFSET)
    vsText:SetText("VS")
    vsText:SetTextColor(unpack(RPS_UI.VS_COLOR))
    frame.localRPSVs = vsText

    -- AI choice section (right side, anchored from top)
    local aiSection = CreateFrame("Frame", nil, container)
    aiSection:SetSize(RPS_UI.CHOICE_SECTION_WIDTH, RPS_UI.CHOICE_SECTION_HEIGHT)
    aiSection:SetPoint("TOPRIGHT", container, "TOP", RPS_UI.SECTION_H_OFFSET, RPS_UI.SECTIONS_OFFSET)

    local aiLabel = aiSection:CreateFontString(nil, "OVERLAY")
    aiLabel:SetFont(HopeAddon.assets.fonts.BODY, RPS_UI.LABEL_FONT_SIZE)
    aiLabel:SetPoint("TOP", aiSection, "TOP", 0, 0)
    aiLabel:SetText("AI CHOICE")
    aiLabel:SetTextColor(unpack(RPS_UI.AI_CHOICE_COLOR))

    local aiIcon = aiSection:CreateTexture(nil, "ARTWORK")
    aiIcon:SetSize(RPS_UI.BUTTON_SIZE, RPS_UI.BUTTON_SIZE)
    aiIcon:SetPoint("CENTER", aiSection, "CENTER", 0, -10)
    aiIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.localRPSAIIcon = aiIcon

    local aiChoice = aiSection:CreateFontString(nil, "OVERLAY")
    aiChoice:SetFont(HopeAddon.assets.fonts.BODY, RPS_UI.CHOICE_FONT_SIZE)
    aiChoice:SetPoint("BOTTOM", aiSection, "BOTTOM", 0, 0)
    aiChoice:SetText("?")
    aiChoice:SetTextColor(1, 1, 1)
    frame.localRPSAIChoice = aiChoice

    -- Result text (reduced font, anchored from top for better positioning)
    local resultText = container:CreateFontString(nil, "OVERLAY")
    resultText:SetFont(HopeAddon.assets.fonts.HEADER, RPS_UI.RESULT_FONT_SIZE)
    resultText:SetPoint("TOP", container, "TOP", 0, RPS_UI.RESULT_OFFSET)
    resultText:SetWidth(300)  -- Constrain width
    resultText:SetText("")
    frame.localRPSResult = resultText

    -- Choice buttons (positioned higher from bottom)
    local buttonRow = CreateFrame("Frame", nil, container)
    buttonRow:SetSize(3 * RPS_UI.BUTTON_SIZE + 40, RPS_UI.BUTTON_SIZE + 30)
    buttonRow:SetPoint("BOTTOM", container, "BOTTOM", 0, RPS_UI.BUTTONS_OFFSET)

    local choices = {"rock", "paper", "scissors"}
    local choiceLabels = {rock = "Rock", paper = "Paper", scissors = "Scissors"}
    frame.localRPSButtons = {}

    for i, choice in ipairs(choices) do
        local btn = CreateBackdropFrame("Button", nil, buttonRow)
        btn:SetSize(RPS_UI.BUTTON_SIZE, RPS_UI.BUTTON_SIZE)
        btn:SetPoint("LEFT", buttonRow, "LEFT", (i - 1) * (RPS_UI.BUTTON_SIZE + 20), 10)

        -- Apply backdrop with TBC arcane purple theme
        if HopeAddon.Components then
            HopeAddon.Components:ApplyBackdrop(btn, "BORDER_ONLY_TOOLTIP", nil, "ARCANE_PURPLE")
        end

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

        -- Label below button
        local label = buttonRow:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.SMALL, RPS_UI.BUTTON_LABEL_SIZE)
        label:SetPoint("TOP", btn, "BOTTOM", 0, -3)
        label:SetText(choiceLabels[choice])
        label:SetTextColor(unpack(RPS_UI.LABEL_COLOR))
        btn.label = label

        btn.choice = choice
        btn:SetScript("OnClick", function(self)
            local MinigamesUI = HopeAddon:GetModule("MinigamesUI")
            if MinigamesUI then
                MinigamesUI:OnLocalRPSChoice(self.choice)
            end
        end)

        frame.localRPSButtons[choice] = btn
    end
    frame.localRPSButtonRow = buttonRow

    -- Play Again button (hidden initially, positioned lower)
    local playAgain = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    playAgain:SetSize(100, 24)
    playAgain:SetPoint("BOTTOM", container, "BOTTOM", 0, RPS_UI.PLAY_AGAIN_OFFSET)
    playAgain:SetText("Play Again")
    playAgain:SetScript("OnClick", function()
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:StartLocalRPSGame()
        end
    end)
    playAgain:Hide()
    frame.localRPSPlayAgain = playAgain
end

--[[
    Show local RPS game UI
    @param aiName string - AI opponent display name
]]
function MinigamesUI:ShowLocalRPSGame(aiName)
    self:HideChallengePopup()

    local frame = self:GetGameFrame()

    -- Set larger frame size for RPS (uses tiled parchment that scales)
    self:SetRPSFrameSize()

    self:ShowContainer("localRPS")

    -- Update header
    frame.title:SetText(HopeAddon:ColorText("ROCK PAPER SCISSORS", "ARCANE_PURPLE"))
    frame.statusText:SetText("vs |cFFFF6600" .. aiName .. "|r")

    -- Reset display
    frame.localRPSTitle:SetText(aiName)
    frame.localRPSStatus:SetText("CHOOSE YOUR WEAPON!")
    frame.localRPSStatus:SetTextColor(1, 0.84, 0)  -- Gold
    frame.localRPSYourIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.localRPSYourChoice:SetText("?")
    frame.localRPSAIIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    frame.localRPSAIChoice:SetText("?")
    frame.localRPSResult:SetText("")

    -- Enable all buttons and show button row
    local purple = HopeAddon.colors.ARCANE_PURPLE
    for _, btn in pairs(frame.localRPSButtons or {}) do
        btn:Enable()
        btn:Show()
        btn.icon:SetVertexColor(1, 1, 1, 1)
        if btn.SetBackdropBorderColor then
            btn:SetBackdropBorderColor(purple.r, purple.g, purple.b, 1)
        end
        if btn.label then btn.label:Show() end
    end
    if frame.localRPSButtonRow then
        frame.localRPSButtonRow:Show()
    end

    -- Hide play again button
    frame.localRPSPlayAgain:Hide()

    -- Play dramatic gong
    if HopeAddon.Sounds then
        HopeAddon.Sounds:Play("dramatic", "gong")
    end

    frame:Show()
end

--[[
    Handle local RPS choice click
    @param choice string - rock/paper/scissors
]]
function MinigamesUI:OnLocalRPSChoice(choice)
    local frame = self.gameFrame
    if not frame then return end

    -- Hide button row immediately after selection
    if frame.localRPSButtonRow then
        frame.localRPSButtonRow:Hide()
    end

    -- Show player choice immediately
    local choiceLabels = {rock = "ROCK", paper = "PAPER", scissors = "SCISSORS"}
    frame.localRPSYourIcon:SetTexture(RPS_ICONS[choice])
    frame.localRPSYourChoice:SetText(choiceLabels[choice])

    -- Play lock-in sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    -- Update status for dramatic effect
    frame.localRPSStatus:SetText("LOCKED IN!")
    frame.localRPSStatus:SetTextColor(0, 1, 0)

    -- Process choice through Minigames
    local Minigames = HopeAddon:GetModule("Minigames")
    if Minigames then
        Minigames:HandleLocalRPSChoice(choice)
    end
end

--[[
    Show dramatic gameshow reveal for local RPS
    @param game table - Local game state with playerChoice, aiChoice, result
]]
function MinigamesUI:ShowLocalRPSReveal(game)
    local frame = self.gameFrame
    if not frame then return end

    local choiceLabels = {rock = "ROCK", paper = "PAPER", scissors = "SCISSORS"}

    -- Initialize/clear timer storage for cleanup on tab hide
    self.localRPSTimers = self.localRPSTimers or {}
    wipe(self.localRPSTimers)

    -- Phase 1: AI "thinking" (0.5s)
    frame.localRPSStatus:SetText("AI IS CHOOSING...")
    frame.localRPSStatus:SetTextColor(1, 0.5, 0)  -- Orange

    if HopeAddon.Sounds then
        HopeAddon.Sounds:Play("dramatic", "magic")
    end

    -- Phase 2: Countdown (1.5s total)
    table.insert(self.localRPSTimers, HopeAddon.Timer:After(0.5, function()
        if not frame or not frame:IsShown() then return end
        frame.localRPSStatus:SetText("3...")
        frame.localRPSStatus:SetTextColor(1, 1, 0)  -- Yellow
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    end))

    table.insert(self.localRPSTimers, HopeAddon.Timer:After(1.0, function()
        if not frame or not frame:IsShown() then return end
        frame.localRPSStatus:SetText("2...")
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    end))

    table.insert(self.localRPSTimers, HopeAddon.Timer:After(1.5, function()
        if not frame or not frame:IsShown() then return end
        frame.localRPSStatus:SetText("1...")
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    end))

    -- Phase 3: AI reveal (2.0s)
    table.insert(self.localRPSTimers, HopeAddon.Timer:After(2.0, function()
        if not frame or not frame:IsShown() then return end

        -- Reveal AI choice with dramatic sound
        frame.localRPSAIIcon:SetTexture(RPS_ICONS[game.aiChoice])
        frame.localRPSAIChoice:SetText(choiceLabels[game.aiChoice])

        if HopeAddon.Sounds then
            HopeAddon.Sounds:Play("dramatic", "gong")
        end

        frame.localRPSStatus:SetText("REVEAL!")
        frame.localRPSStatus:SetTextColor(1, 0.84, 0)  -- Gold
    end))

    -- Phase 4: Result (2.8s)
    table.insert(self.localRPSTimers, HopeAddon.Timer:After(2.8, function()
        if not frame or not frame:IsShown() then return end

        local resultText, resultColor, soundCat, soundName

        if game.result == "win" then
            resultText = "YOU WIN!"
            resultColor = {0, 1, 0}  -- Green
            soundCat, soundName = "achievement", "complete"
            -- Victory celebration effect
            if HopeAddon.Effects then
                HopeAddon.Effects:Celebrate(frame.localRPSStatusFrame, 2.0, {
                    colorName = "GOLD_BRIGHT"
                })
            end
        elseif game.result == "lose" then
            resultText = "YOU LOSE!"
            resultColor = {1, 0, 0}  -- Red
            soundCat, soundName = "combat", "death"
        else
            resultText = "IT'S A TIE!"
            resultColor = {1, 1, 0}  -- Yellow
            soundCat, soundName = "dramatic", "magic"
        end

        frame.localRPSResult:SetText(resultText)
        frame.localRPSResult:SetTextColor(unpack(resultColor))
        frame.localRPSStatus:SetText("")

        if HopeAddon.Sounds then
            HopeAddon.Sounds:Play(soundCat, soundName)
        end

        -- Hide choice buttons and button row, show Play Again
        if frame.localRPSButtonRow then
            frame.localRPSButtonRow:Hide()
        end
        frame.localRPSPlayAgain:Show()
    end))
end

--============================================================
-- PRACTICE MODE SELECTION POPUP
-- Shows "Play vs AI" or "2-Player Local" choice for Tetris/Pong
--============================================================

--[[
    Create or return the practice mode selection popup
]]
function MinigamesUI:GetPracticeModePopup()
    if self.practiceModePopup then
        return self.practiceModePopup
    end

    -- Create popup frame with dark gold backdrop (tiles properly at any size)
    local popup = CreateBackdropFrame("Frame", "HopePracticeModePopup", UIParent)
    popup:SetSize(PRACTICE_MODE_WIDTH, PRACTICE_MODE_HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    HopeAddon.Components:ApplyBackdrop(popup, "DARK_FEL", "BLACK_SOLID", "FEL_GREEN")
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("PRACTICE MODE", "GOLD_BRIGHT"))
    popup.title = title

    -- Game name subtitle
    local gameText = popup:CreateFontString(nil, "OVERLAY")
    gameText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    gameText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    gameText:SetTextColor(0.1, 0.1, 0.1, 1)
    popup.gameText = gameText

    -- Button container
    local buttonContainer = CreateFrame("Frame", nil, popup)
    buttonContainer:SetSize(PRACTICE_MODE_WIDTH - 40, 120)
    buttonContainer:SetPoint("TOP", gameText, "BOTTOM", 0, -15)

    -- Play vs AI button (green)
    local aiBtn = CreateBackdropFrame("Button", nil, buttonContainer)
    aiBtn:SetSize(PRACTICE_MODE_WIDTH - 60, 36)
    aiBtn:SetPoint("TOP", buttonContainer, "TOP", 0, 0)
    HopeAddon.Components:ApplyBackdrop(aiBtn, "BORDER_ONLY_TOOLTIP", nil, "FEL_GREEN")

    local aiBtnText = aiBtn:CreateFontString(nil, "OVERLAY")
    aiBtnText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    aiBtnText:SetPoint("CENTER", aiBtn, "CENTER", 0, 4)
    aiBtnText:SetText("|cFF00FF00Play vs AI|r")

    local aiBtnDesc = aiBtn:CreateFontString(nil, "OVERLAY")
    aiBtnDesc:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    aiBtnDesc:SetPoint("CENTER", aiBtn, "CENTER", 0, -8)
    aiBtnDesc:SetText("Single player vs computer")
    aiBtnDesc:SetTextColor(0.4, 0.4, 0.4, 1)

    aiBtn:SetScript("OnClick", OnPracticeModeAI)
    aiBtn:SetScript("OnEnter", function(self)
        local c = HopeAddon.colors.GOLD_BRIGHT
        self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    aiBtn:SetScript("OnLeave", function(self)
        local c = HopeAddon.colors.FEL_GREEN
        self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
    end)
    popup.aiBtn = aiBtn

    -- 2-Player Local button (purple)
    local localBtn = CreateBackdropFrame("Button", nil, buttonContainer)
    localBtn:SetSize(PRACTICE_MODE_WIDTH - 60, 36)
    localBtn:SetPoint("TOP", aiBtn, "BOTTOM", 0, -10)
    HopeAddon.Components:ApplyBackdrop(localBtn, "BORDER_ONLY_TOOLTIP", nil, "ARCANE_PURPLE")

    local localBtnText = localBtn:CreateFontString(nil, "OVERLAY")
    localBtnText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    localBtnText:SetPoint("CENTER", localBtn, "CENTER", 0, 4)
    localBtnText:SetText("|cFF9B30FF2-Player Local|r")

    local localBtnDesc = localBtn:CreateFontString(nil, "OVERLAY")
    localBtnDesc:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    localBtnDesc:SetPoint("CENTER", localBtn, "CENTER", 0, -8)
    localBtnDesc:SetText("Two players, one keyboard")
    localBtnDesc:SetTextColor(0.4, 0.4, 0.4, 1)

    localBtn:SetScript("OnClick", OnPracticeModeLocal)
    localBtn:SetScript("OnEnter", function(self)
        local c = HopeAddon.colors.GOLD_BRIGHT
        self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    localBtn:SetScript("OnLeave", function(self)
        local c = HopeAddon.colors.ARCANE_PURPLE
        self:SetBackdropBorderColor(c.r, c.g, c.b, 1)
    end)
    popup.localBtn = localBtn

    -- Close (X) button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", OnPracticeModeCancel)

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 22)
    cancelBtn:SetPoint("BOTTOM", popup, "BOTTOM", 0, 15)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", OnPracticeModeCancel)

    -- Close on escape
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", OnPracticeModeKeyDown)

    popup:Hide()
    self.practiceModePopup = popup
    return popup
end

--[[
    Show practice mode selection popup
    @param gameId string - Game ID ("tetris" or "pong")
    @param callback function - Callback function(mode) where mode is "ai" or "local"
]]
function MinigamesUI:ShowPracticeModePopup(gameId, callback)
    if not gameId or not callback then return end

    -- Hide conflicting popups first
    self:HideGameSelectionPopup()
    self:HideChallengePopup()
    self:HideTravelerPickerPopup()

    local popup = self:GetPracticeModePopup()

    -- Store callback and game ID
    popup.callback = callback
    popup.gameId = gameId

    -- Get game display name
    local gameName = GAME_NAMES[gameId] or gameId
    popup.gameText:SetText(gameName)

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
    Hide practice mode selection popup
]]
function MinigamesUI:HidePracticeModePopup()
    if self.practiceModePopup then
        self.practiceModePopup:Hide()
    end
end

--[[
    Clean up resources when Games tab is hidden
    Called by Journal:HideGamesTab() on tab switch to prevent memory leaks
]]
function MinigamesUI:OnTabHide()
    -- Cancel any pending Local RPS animation timers
    if self.localRPSTimers then
        for _, timer in ipairs(self.localRPSTimers) do
            if timer and timer.Cancel then
                timer:Cancel()
            end
        end
        wipe(self.localRPSTimers)
    end

    -- Hide game frame if open
    if self.gameFrame then
        self.gameFrame:Hide()
    end

    -- Clear challenge popup timer
    if self.challengePopup and self.challengePopup.timerTicker then
        self.challengePopup.timerTicker:Cancel()
        self.challengePopup.timerTicker = nil
        self.challengePopup:Hide()
    end

    -- Hide traveler picker (buttons stay pooled but hidden)
    if self.travelerPickerPopup then
        self.travelerPickerPopup:Hide()
    end

    -- Hide practice mode popup
    if self.practiceModePopup then
        self.practiceModePopup:Hide()
    end

    -- Hide game selection popup
    if self.gameSelectionPopup then
        self.gameSelectionPopup:Hide()
    end
end

-- Register module
HopeAddon:RegisterModule("MinigamesUI", MinigamesUI)
HopeAddon:Debug("MinigamesUI module loaded")
