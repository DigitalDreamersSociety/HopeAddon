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

--============================================================
-- MODULE STATE
--============================================================

DeathRollUI.setupWindow = nil

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
    end
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
    local window = CreateFrame("Frame", "HopeDeathRollSetup", UIParent, "BackdropTemplate")
    window:SetSize(320, 280)
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata("DIALOG")

    window:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
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
    oppLabel:SetPoint("TOPLEFT", 20, -50)
    oppLabel:SetText("Opponent (leave blank for local):")
    oppLabel:SetTextColor(0.9, 0.9, 0.9)

    local oppInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    oppInput:SetSize(200, 24)
    oppInput:SetPoint("TOPLEFT", oppLabel, "BOTTOMLEFT", 5, -5)
    oppInput:SetAutoFocus(false)
    oppInput:SetText("")
    window.opponentInput = oppInput

    -- Target button (auto-fill target name)
    local targetBtn = GameUI:CreateButton(window, "Target", 60, 22)
    targetBtn:SetPoint("LEFT", oppInput, "RIGHT", 5, 0)
    targetBtn:SetScript("OnClick", function()
        if UnitIsPlayer("target") then
            oppInput:SetText(UnitName("target"))
        end
    end)

    -- Max roll input
    local maxLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxLabel:SetPoint("TOPLEFT", oppInput, "BOTTOMLEFT", -5, -20)
    maxLabel:SetText("Starting Max Roll:")
    maxLabel:SetTextColor(0.9, 0.9, 0.9)

    local maxInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    maxInput:SetSize(100, 24)
    maxInput:SetPoint("TOPLEFT", maxLabel, "BOTTOMLEFT", 5, -5)
    maxInput:SetAutoFocus(false)
    maxInput:SetText("1000")
    maxInput:SetNumeric(true)
    window.maxInput = maxInput

    -- Bet amount input
    local betLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    betLabel:SetPoint("TOPLEFT", maxInput, "BOTTOMLEFT", -5, -20)
    betLabel:SetText("Bet Amount (gold, 0 for none):")
    betLabel:SetTextColor(0.9, 0.9, 0.9)

    local betInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    betInput:SetSize(100, 24)
    betInput:SetPoint("TOPLEFT", betLabel, "BOTTOMLEFT", 5, -5)
    betInput:SetAutoFocus(false)
    betInput:SetText("0")
    betInput:SetNumeric(true)
    window.betInput = betInput

    -- Escrow checkbox
    local escrowCheck = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
    escrowCheck:SetPoint("TOPLEFT", betInput, "BOTTOMLEFT", -5, -15)
    escrowCheck:SetChecked(false)
    window.escrowCheck = escrowCheck

    local escrowLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    escrowLabel:SetPoint("LEFT", escrowCheck, "RIGHT", 5, 0)
    escrowLabel:SetText("Use Escrow (requires third party)")
    escrowLabel:SetTextColor(0.7, 0.7, 0.7)

    -- Start button
    local startBtn = GameUI:CreateButton(window, "Start Game", 120, 32)
    startBtn:SetPoint("BOTTOMLEFT", 30, 20)
    startBtn:SetScript("OnClick", function()
        self:StartGameFromSetup()
    end)

    -- Cancel button
    local cancelBtn = GameUI:CreateButton(window, "Cancel", 100, 32)
    cancelBtn:SetPoint("BOTTOMRIGHT", -30, 20)
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
            if Escrow then
                Escrow:InitiateEscrow(gameId, betAmount)
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

    -- Create history window
    local window = CreateFrame("Frame", "HopeDeathRollHistory_" .. gameId, UIParent, "BackdropTemplate")
    window:SetSize(250, 300)
    window:SetPoint("CENTER", 200, 0)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:SetFrameStrata("DIALOG")

    window:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window:SetBackdropColor(0.1, 0.1, 0.1, 0.95)

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
