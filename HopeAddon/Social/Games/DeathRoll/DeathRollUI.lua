--[[
    HopeAddon Death Roll UI
    Extended UI components for Death Roll game
]]

local DeathRollUI = {}

--============================================================
-- CONSTANTS
--============================================================

-- Colors
local COLORS = {
    WINNER = { r = 0.2, g = 1, b = 0.2 },
    LOSER = { r = 1, g = 0.2, b = 0.2 },
    GOLD = { r = 1, g = 0.84, b = 0 },
    MUTED = { r = 0.6, g = 0.6, b = 0.6 },
}

-- Window sizes
DeathRollUI.SETUP_WINDOW = { width = 320, height = 280 }
DeathRollUI.HISTORY_WINDOW = { width = 250, height = 300 }

-- Layout constants
DeathRollUI.MARGINS = { top = 16, left = 20, vertical = 12, label = 5 }
DeathRollUI.INPUT_HEIGHT = 24
DeathRollUI.BUTTON_HEIGHT = 32

-- Consistent backdrop for windows
DeathRollUI.WINDOW_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

--============================================================
-- MODULE STATE
--============================================================

DeathRollUI.setupWindow = nil
DeathRollUI.historyWindows = {}

--============================================================
-- LIFECYCLE
--============================================================

function DeathRollUI:OnInitialize()
    HopeAddon:Debug("DeathRollUI initializing...")
end

function DeathRollUI:OnEnable()
    HopeAddon:Debug("DeathRollUI enabled")
end

function DeathRollUI:OnDisable()
    if self.setupWindow then
        self.setupWindow:Hide()
        self.setupWindow:SetParent(nil)
        -- Clear child frame references to prevent memory leaks
        self.setupWindow.opponentInput = nil
        self.setupWindow.maxInput = nil
        self.setupWindow.betInput = nil
        self.setupWindow.escrowCheck = nil
        self.setupWindow = nil
    end

    -- Clean up history windows
    for gameId, window in pairs(self.historyWindows) do
        if window then
            window:Hide()
            window:SetParent(nil)
        end
    end
    wipe(self.historyWindows)
end

--============================================================
-- GAME SETUP WINDOW
--============================================================

--[[
    Show the Death Roll setup window
    Allows configuring bet amount, max roll, and opponent
]]
function DeathRollUI:ShowSetupWindow()
    if not self.setupWindow then
        self:CreateSetupWindow()
    end

    self.setupWindow:Show()
end

function DeathRollUI:CreateSetupWindow()
    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    -- Create window frame
    local window = CreateFrame("Frame", "HopeDeathRollSetup", UIParent)
    window:SetSize(self.SETUP_WINDOW.width, self.SETUP_WINDOW.height)
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata("DIALOG")

    window:SetBackdrop(self.WINDOW_BACKDROP)
    window:SetBackdropColor(0.1, 0.1, 0.15, 0.95)

    -- Make draggable
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)

    -- Title
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Death Roll Setup")
    title:SetTextColor(1, 0.84, 0)

    -- Opponent input
    local oppLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    oppLabel:SetPoint("TOPLEFT", self.MARGINS.left, -50)
    oppLabel:SetText("Opponent (leave blank for local):")
    oppLabel:SetTextColor(0.9, 0.9, 0.9)

    local oppInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    oppInput:SetSize(200, self.INPUT_HEIGHT)
    oppInput:SetPoint("TOPLEFT", oppLabel, "BOTTOMLEFT", 0, -self.MARGINS.label)
    oppInput:SetAutoFocus(false)
    oppInput:SetText("")
    window.opponentInput = oppInput

    -- Target button (auto-fill target name)
    local targetBtn = GameUI:CreateButton(window, "Target", 60, 22)
    targetBtn:SetPoint("LEFT", oppInput, "RIGHT", self.MARGINS.label, 0)
    targetBtn:SetScript("OnClick", function()
        if UnitIsPlayer("target") then
            oppInput:SetText(UnitName("target"))
        end
    end)

    -- Max roll input
    local maxLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxLabel:SetPoint("TOPLEFT", oppInput, "BOTTOMLEFT", 0, -self.MARGINS.vertical)
    maxLabel:SetText("Starting Max Roll:")
    maxLabel:SetTextColor(0.9, 0.9, 0.9)

    local maxInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    maxInput:SetSize(100, self.INPUT_HEIGHT)
    maxInput:SetPoint("TOPLEFT", maxLabel, "BOTTOMLEFT", 0, -self.MARGINS.label)
    maxInput:SetAutoFocus(false)
    maxInput:SetText("1000")
    maxInput:SetNumeric(true)
    window.maxInput = maxInput

    -- Bet amount input
    local betLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    betLabel:SetPoint("TOPLEFT", maxInput, "BOTTOMLEFT", 0, -self.MARGINS.vertical)
    betLabel:SetText("Bet Amount (gold, 0 for none):")
    betLabel:SetTextColor(0.9, 0.9, 0.9)

    local betInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    betInput:SetSize(100, self.INPUT_HEIGHT)
    betInput:SetPoint("TOPLEFT", betLabel, "BOTTOMLEFT", 0, -self.MARGINS.label)
    betInput:SetAutoFocus(false)
    betInput:SetText("0")
    betInput:SetNumeric(true)
    window.betInput = betInput

    -- Escrow checkbox
    local escrowCheck = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
    escrowCheck:SetPoint("TOPLEFT", betInput, "BOTTOMLEFT", 0, -self.MARGINS.vertical)
    escrowCheck:SetChecked(false)
    window.escrowCheck = escrowCheck

    local escrowLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    escrowLabel:SetPoint("LEFT", escrowCheck, "RIGHT", 5, 0)
    escrowLabel:SetText("Use Escrow (requires third party)")
    escrowLabel:SetTextColor(0.7, 0.7, 0.7)

    -- Start button
    local startBtn = GameUI:CreateButton(window, "Start Game", 120, self.BUTTON_HEIGHT)
    startBtn:SetPoint("BOTTOMLEFT", 30, self.MARGINS.left)
    startBtn:SetScript("OnClick", function()
        self:StartGameFromSetup()
    end)

    -- Cancel button
    local cancelBtn = GameUI:CreateButton(window, "Cancel", 100, self.BUTTON_HEIGHT)
    cancelBtn:SetPoint("BOTTOMRIGHT", -30, self.MARGINS.left)
    cancelBtn:SetScript("OnClick", function()
        window:Hide()
    end)

    -- Close on escape
    window:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)

    window:Hide()
    self.setupWindow = window
end

--[[
    Start game from setup window values
]]
function DeathRollUI:StartGameFromSetup()
    local window = self.setupWindow
    if not window then return end

    local opponent = window.opponentInput:GetText()
    if opponent == "" then opponent = nil end

    local maxRoll = tonumber(window.maxInput:GetText()) or 1000
    local betAmount = tonumber(window.betInput:GetText()) or 0
    local useEscrow = window.escrowCheck:GetChecked()

    -- Validate
    if maxRoll < 2 then
        HopeAddon:Print("Max roll must be at least 2")
        return
    end

    if betAmount > 0 and opponent and not HopeAddon.FellowTravelers:IsFellow(opponent) then
        HopeAddon:Print("Warning: " .. opponent .. " may not have the addon installed")
    end

    -- Start the game
    local DeathRollGame = HopeAddon:GetModule("DeathRollGame")
    if DeathRollGame then
        local gameId = DeathRollGame:StartGame(opponent, betAmount, maxRoll)
        if gameId and useEscrow and betAmount > 0 then
            local Escrow = HopeAddon:GetModule("DeathRollEscrow")
            local GameCore = HopeAddon:GetModule("GameCore")
            if Escrow and GameCore then
                local game = GameCore:GetGame(gameId)
                if game then
                    Escrow:InitiateAsHouse(gameId, betAmount, game.player1, game.player2)
                end
            end
        end
    end

    window:Hide()
end

--============================================================
-- HISTORY WINDOW
--============================================================

--[[
    Show roll history for a game
    @param gameId string
]]
function DeathRollUI:ShowHistory(gameId)
    local DeathRollGame = HopeAddon:GetModule("DeathRollGame")
    if not DeathRollGame then return end

    local game = DeathRollGame:GetGame(gameId)
    if not game then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    -- Close existing history window for this game if any
    if self.historyWindows[gameId] then
        self.historyWindows[gameId]:Hide()
        self.historyWindows[gameId]:SetParent(nil)
        self.historyWindows[gameId] = nil
    end

    -- Create history window
    local window = CreateFrame("Frame", "HopeDeathRollHistory_" .. gameId, UIParent)
    window:SetSize(self.HISTORY_WINDOW.width, self.HISTORY_WINDOW.height)
    window:SetPoint("CENTER", 200, 0)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata("DIALOG")

    window:SetBackdrop(self.WINDOW_BACKDROP)
    window:SetBackdropColor(0.1, 0.1, 0.1, 0.95)

    -- Track window for cleanup
    self.historyWindows[gameId] = window

    -- Make draggable
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)

    -- Title
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Roll History")
    title:SetTextColor(1, 0.84, 0)

    -- Scroll frame for history
    local scrollFrame = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(200, 1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Populate history
    local yOffset = 0
    for i, roll in ipairs(game.data.rollHistory) do
        local line = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        line:SetPoint("TOPLEFT", 5, -yOffset)
        line:SetWidth(190)
        line:SetJustifyH("LEFT")

        local color = roll.roll == 1 and COLORS.LOSER or COLORS.MUTED
        local text = string.format("%d. %s: %d (1-%d)", i, roll.player, roll.roll, roll.max)
        line:SetText(text)
        line:SetTextColor(color.r, color.g, color.b)

        yOffset = yOffset + 16
    end

    scrollChild:SetHeight(math.max(yOffset, 10))

    -- Close button
    local closeBtn = CreateFrame("Button", nil, window)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function() window:Hide() end)

    window:Show()
end

--============================================================
-- QUICK START FUNCTIONS
--============================================================

--[[
    Quick start a local death roll (vs yourself for testing)
]]
function DeathRollUI:QuickStartLocal()
    local DeathRollGame = HopeAddon:GetModule("DeathRollGame")
    if DeathRollGame then
        DeathRollGame:StartGame(nil, 0, 1000)
    end
end

--[[
    Quick invite target to death roll
    @param betAmount number|nil
]]
function DeathRollUI:InviteTarget(betAmount)
    if not UnitIsPlayer("target") then
        HopeAddon:Print("No player targeted")
        return
    end

    local targetName = UnitName("target")
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:SendInvite(targetName, "DEATH_ROLL", betAmount)
    end
end

-- Register with addon
HopeAddon:RegisterModule("DeathRollUI", DeathRollUI)
HopeAddon.DeathRollUI = DeathRollUI

HopeAddon:Debug("DeathRollUI module loaded")
