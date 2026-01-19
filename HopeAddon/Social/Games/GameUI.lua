--[[
    HopeAddon Game UI
    Shared UI components for mini-games (game window, invite dialogs, etc.)
]]

local GameUI = {}

-- TBC 2.4.3 compatibility helper
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    local Components = HopeAddon.Components
    if Components and Components.CreateBackdropFrame then
        return Components.CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    end
    local template = additionalTemplate and (additionalTemplate .. ", BackdropTemplate") or "BackdropTemplate"
    local frame = CreateFrame(frameType or "Frame", name, parent, template)
    if not frame.SetBackdrop then
        frame:Hide()
        frame = CreateFrame(frameType or "Frame", name, parent, additionalTemplate)
    end
    return frame
end

--============================================================
-- CONSTANTS
--============================================================

-- Default game window sizes
GameUI.WINDOW_SIZES = {
    SMALL = { width = 300, height = 200 },
    MEDIUM = { width = 450, height = 350 },
    LARGE = { width = 600, height = 500 },
    PONG = { width = 500, height = 400 },
    TETRIS = { width = 700, height = 550 },
}

-- Colors
local COLORS = {
    WINDOW_BG = { r = 0.1, g = 0.1, b = 0.1, a = 0.95 },
    TITLE_BG = { r = 0.2, g = 0.15, b = 0.3, a = 1 },
    BORDER = { r = 0.4, g = 0.3, b = 0.5, a = 1 },
    TEXT_TITLE = { r = 1, g = 0.84, b = 0, a = 1 },
    TEXT_NORMAL = { r = 0.9, g = 0.9, b = 0.9, a = 1 },
    TEXT_MUTED = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
    BUTTON_NORMAL = { r = 0.3, g = 0.25, b = 0.4, a = 1 },
    BUTTON_HOVER = { r = 0.4, g = 0.35, b = 0.55, a = 1 },
    BUTTON_PRESSED = { r = 0.25, g = 0.2, b = 0.35, a = 1 },
    GREEN = { r = 0.2, g = 0.8, b = 0.2, a = 1 },
    RED = { r = 0.8, g = 0.2, b = 0.2, a = 1 },
}

-- Module-level handlers (no closures, prevent memory leaks)

-- ESC key handler for game windows
local function OnGameWindowKeyDown(self, key)
    if key == "ESCAPE" then
        local gameId = self.gameId
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "CLOSED")
        end
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

-- Button handlers
local function OnButtonEnter(self)
    self:SetBackdropColor(COLORS.BUTTON_HOVER.r, COLORS.BUTTON_HOVER.g, COLORS.BUTTON_HOVER.b, COLORS.BUTTON_HOVER.a)
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayHover()
    end
end

local function OnButtonLeave(self)
    self:SetBackdropColor(COLORS.BUTTON_NORMAL.r, COLORS.BUTTON_NORMAL.g, COLORS.BUTTON_NORMAL.b, COLORS.BUTTON_NORMAL.a)
end

local function OnButtonMouseDown(self)
    self:SetBackdropColor(COLORS.BUTTON_PRESSED.r, COLORS.BUTTON_PRESSED.g, COLORS.BUTTON_PRESSED.b, COLORS.BUTTON_PRESSED.a)
end

local function OnButtonMouseUp(self)
    self:SetBackdropColor(COLORS.BUTTON_HOVER.r, COLORS.BUTTON_HOVER.g, COLORS.BUTTON_HOVER.b, COLORS.BUTTON_HOVER.a)
end

--============================================================
-- MODULE STATE
--============================================================

-- Active game windows
GameUI.gameWindows = {}

-- Invite dialog reference
GameUI.inviteDialog = nil

--============================================================
-- LIFECYCLE
--============================================================

function GameUI:OnInitialize()
    HopeAddon:Debug("GameUI initializing...")
end

function GameUI:OnEnable()
    HopeAddon:Debug("GameUI enabled")
end

function GameUI:OnDisable()
    -- Properly destroy all windows
    for gameId, window in pairs(self.gameWindows) do
        if window then
            window:Hide()
            window:SetParent(nil)
        end
    end
    self.gameWindows = {}

    if self.inviteDialog then
        self.inviteDialog:Hide()
        self.inviteDialog:SetParent(nil)
        self.inviteDialog = nil
    end
end

--============================================================
-- GAME WINDOW CREATION
--============================================================

--[[
    Create a game window
    @param gameId string - Game ID
    @param title string - Window title
    @param size table|string - { width, height } or size key (SMALL, MEDIUM, LARGE, etc.)
    @return Frame
]]
function GameUI:CreateGameWindow(gameId, title, size)
    -- Resolve size
    if type(size) == "string" then
        size = self.WINDOW_SIZES[size] or self.WINDOW_SIZES.MEDIUM
    end
    size = size or self.WINDOW_SIZES.MEDIUM

    -- Create main frame
    local window = CreateBackdropFrame("Frame", "HopeGameWindow_" .. gameId, UIParent)
    window:SetSize(size.width, size.height)
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:SetClampedToScreen(true)
    window:SetFrameStrata("DIALOG")

    -- Background
    window:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window:SetBackdropColor(COLORS.WINDOW_BG.r, COLORS.WINDOW_BG.g, COLORS.WINDOW_BG.b, COLORS.WINDOW_BG.a)
    window:SetBackdropBorderColor(COLORS.BORDER.r, COLORS.BORDER.g, COLORS.BORDER.b, COLORS.BORDER.a)

    -- Title bar
    local titleBar = CreateBackdropFrame("Frame", nil, window)
    titleBar:SetHeight(28)
    titleBar:SetPoint("TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", -4, -4)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = nil,
        tile = true,
        tileSize = 16,
    })
    titleBar:SetBackdropColor(COLORS.TITLE_BG.r, COLORS.TITLE_BG.g, COLORS.TITLE_BG.b, COLORS.TITLE_BG.a)
    window.titleBar = titleBar

    -- Make title bar draggable
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() window:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)

    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("CENTER")
    titleText:SetText(title)
    titleText:SetTextColor(COLORS.TEXT_TITLE.r, COLORS.TEXT_TITLE.g, COLORS.TEXT_TITLE.b)
    window.titleText = titleText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -4, 0)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetScript("OnClick", function()
        window:Hide()
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "CLOSED")
        end
    end)
    window.closeBtn = closeBtn

    -- Store gameId for ESC handler
    window.gameId = gameId

    -- ESC key handling
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", OnGameWindowKeyDown)

    -- Content area
    local content = CreateFrame("Frame", nil, window)
    content:SetPoint("TOPLEFT", 8, -36)
    content:SetPoint("BOTTOMRIGHT", -8, 8)
    window.content = content

    -- Store reference
    self.gameWindows[gameId] = window

    return window
end

--[[
    Get a game window
    @param gameId string
    @return Frame|nil
]]
function GameUI:GetGameWindow(gameId)
    return self.gameWindows[gameId]
end

--[[
    Close and destroy a game window
    @param gameId string
]]
function GameUI:DestroyGameWindow(gameId)
    local window = self.gameWindows[gameId]
    if window then
        window:Hide()
        window:SetParent(nil)
        self.gameWindows[gameId] = nil
    end
end

--============================================================
-- COMMON UI ELEMENTS
--============================================================

--[[
    Create a styled button
    @param parent Frame
    @param text string
    @param width number
    @param height number
    @return Button
]]
function GameUI:CreateButton(parent, text, width, height)
    width = width or 100
    height = height or 28

    local button = CreateBackdropFrame("Button", nil, parent)
    button:SetSize(width, height)

    button:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    button:SetBackdropColor(COLORS.BUTTON_NORMAL.r, COLORS.BUTTON_NORMAL.g, COLORS.BUTTON_NORMAL.b, COLORS.BUTTON_NORMAL.a)
    button:SetBackdropBorderColor(COLORS.BORDER.r, COLORS.BORDER.g, COLORS.BORDER.b, 0.8)

    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER")
    buttonText:SetText(text)
    buttonText:SetTextColor(COLORS.TEXT_NORMAL.r, COLORS.TEXT_NORMAL.g, COLORS.TEXT_NORMAL.b)
    button.text = buttonText

    -- Hover effects (use module-level handlers to avoid closure memory leaks)
    button:SetScript("OnEnter", OnButtonEnter)
    button:SetScript("OnLeave", OnButtonLeave)
    button:SetScript("OnMouseDown", OnButtonMouseDown)
    button:SetScript("OnMouseUp", OnButtonMouseUp)

    return button
end

--[[
    Create a score display
    @param parent Frame
    @param label string
    @return Frame, FontString (label), FontString (value)
]]
function GameUI:CreateScoreDisplay(parent, label)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(80, 50)

    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    labelText:SetPoint("TOP", 0, 0)
    labelText:SetText(label)
    labelText:SetTextColor(COLORS.TEXT_MUTED.r, COLORS.TEXT_MUTED.g, COLORS.TEXT_MUTED.b)

    local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    valueText:SetPoint("TOP", labelText, "BOTTOM", 0, -4)
    valueText:SetText("0")
    valueText:SetTextColor(COLORS.TEXT_TITLE.r, COLORS.TEXT_TITLE.g, COLORS.TEXT_TITLE.b)

    container.label = labelText
    container.value = valueText

    return container
end

--[[
    Create a timer display
    @param parent Frame
    @return Frame
]]
function GameUI:CreateTimerDisplay(parent)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(60, 30)

    local timeText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    timeText:SetPoint("CENTER")
    timeText:SetText("0:00")
    timeText:SetTextColor(COLORS.TEXT_NORMAL.r, COLORS.TEXT_NORMAL.g, COLORS.TEXT_NORMAL.b)

    container.timeText = timeText

    return container
end

--[[
    Create a status bar (health, progress, etc.)
    @param parent Frame
    @param width number
    @param height number
    @param color table - { r, g, b }
    @return StatusBar
]]
function GameUI:CreateStatusBar(parent, width, height, color)
    width = width or 200
    height = height or 20
    color = color or COLORS.GREEN

    local bar = CreateBackdropFrame("StatusBar", nil, parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar:SetStatusBarColor(color.r, color.g, color.b)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(100)

    bar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    bar:SetBackdropColor(0, 0, 0, 0.5)
    bar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Value text
    local valueText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("CENTER")
    valueText:SetText("100%")
    bar.valueText = valueText

    return bar
end

--============================================================
-- INVITE DIALOG
--============================================================

--[[
    Show game invite dialog
    @param sender string - Player who sent invite
    @param gameType string - Type of game
    @param betAmount number|nil - Gold amount
]]
function GameUI:ShowInviteDialog(sender, gameType, betAmount)
    if not self.inviteDialog then
        self:CreateInviteDialog()
    end

    local dialog = self.inviteDialog

    -- Update text
    local gameNames = {
        DEATH_ROLL = "Death Roll",
        PONG = "Pong",
        TETRIS = "Tetris Battle",
        WORDS = "Words with WoW",
    }
    local gameName = gameNames[gameType] or gameType

    local msgText = sender .. " challenges you to " .. gameName .. "!"
    if betAmount and betAmount > 0 then
        msgText = msgText .. "\nBet: " .. HopeAddon:FormatGold(betAmount * 10000)
    end
    dialog.messageText:SetText(msgText)

    -- Store invite info
    dialog.sender = sender
    dialog.gameType = gameType
    dialog.betAmount = betAmount

    -- Show and play sound
    dialog:Show()
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end
end

function GameUI:CreateInviteDialog()
    local dialog = CreateBackdropFrame("Frame", "HopeGameInviteDialog", UIParent)
    dialog:SetSize(300, 150)
    dialog:SetPoint("CENTER", 0, 100)
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel(100)

    dialog:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    dialog:SetBackdropColor(0.1, 0.1, 0.15, 0.95)

    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Game Challenge!")
    title:SetTextColor(1, 0.84, 0)

    -- Message
    local message = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    message:SetPoint("TOP", title, "BOTTOM", 0, -16)
    message:SetWidth(260)
    message:SetText("")
    dialog.messageText = message

    -- Accept button
    local acceptBtn = self:CreateButton(dialog, "Accept", 100, 28)
    acceptBtn:SetPoint("BOTTOMLEFT", 30, 20)
    acceptBtn:SetScript("OnClick", function()
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:AcceptInvite(dialog.sender)
        end
        dialog:Hide()
    end)

    -- Decline button
    local declineBtn = self:CreateButton(dialog, "Decline", 100, 28)
    declineBtn:SetPoint("BOTTOMRIGHT", -30, 20)
    declineBtn:SetScript("OnClick", function()
        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms then
            GameComms:DeclineInvite(dialog.sender)
        end
        dialog:Hide()
    end)

    dialog:Hide()
    self.inviteDialog = dialog
end

--[[
    Hide invite dialog
]]
function GameUI:HideInviteDialog()
    if self.inviteDialog then
        self.inviteDialog:Hide()
    end
end

--============================================================
-- GAME OVER DISPLAY
--============================================================

--[[
    Show game over screen
    @param gameId string
    @param winner string - "Player 1", "Player 2", or "DRAW"
    @param stats table|nil - Additional stats to display
]]
function GameUI:ShowGameOver(gameId, winner, stats)
    local window = self.gameWindows[gameId]
    if not window or not window.content then return end

    -- Create overlay
    local overlay = CreateBackdropFrame("Frame", nil, window.content)
    overlay:SetAllPoints()
    overlay:SetFrameLevel(window.content:GetFrameLevel() + 10)

    overlay:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    })
    overlay:SetBackdropColor(0, 0, 0, 0.85)

    -- Result text
    local resultText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    resultText:SetPoint("CENTER", 0, 30)

    if winner == "DRAW" then
        resultText:SetText("DRAW!")
        resultText:SetTextColor(0.8, 0.8, 0.2)
    elseif winner == UnitName("player") then
        resultText:SetText("VICTORY!")
        resultText:SetTextColor(0.2, 1, 0.2)
    else
        resultText:SetText("DEFEAT")
        resultText:SetTextColor(0.8, 0.2, 0.2)
    end

    -- Stats text
    if stats then
        local statsText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statsText:SetPoint("TOP", resultText, "BOTTOM", 0, -20)
        local statsStr = ""
        for k, v in pairs(stats) do
            statsStr = statsStr .. k .. ": " .. tostring(v) .. "\n"
        end
        statsText:SetText(statsStr)
        statsText:SetTextColor(0.9, 0.9, 0.9)
    end

    -- Close button
    local closeBtn = self:CreateButton(overlay, "Close", 120, 32)
    closeBtn:SetPoint("BOTTOM", 0, 30)
    closeBtn:SetScript("OnClick", function()
        overlay:Hide()
        window:Hide()
        self:DestroyGameWindow(gameId)
    end)

    -- Play end sound
    if HopeAddon.Sounds then
        if winner == UnitName("player") then
            HopeAddon.Sounds:PlayAchievement()
        else
            HopeAddon.Sounds:PlayClick()
        end
    end

    window.gameOverOverlay = overlay
end

--============================================================
-- HELPER FUNCTIONS
--============================================================

--[[
    Create a simple text label
    @param parent Frame
    @param text string
    @param fontObject string
    @return FontString
]]
function GameUI:CreateLabel(parent, text, fontObject)
    fontObject = fontObject or "GameFontNormal"
    local label = parent:CreateFontString(nil, "OVERLAY", fontObject)
    label:SetText(text or "")
    label:SetTextColor(COLORS.TEXT_NORMAL.r, COLORS.TEXT_NORMAL.g, COLORS.TEXT_NORMAL.b)
    return label
end

--[[
    Create a simple colored rectangle
    @param parent Frame
    @param width number
    @param height number
    @param color table - { r, g, b, a }
    @return Texture
]]
function GameUI:CreateRect(parent, width, height, color)
    local texture = parent:CreateTexture(nil, "ARTWORK")
    texture:SetSize(width, height)
    texture:SetColorTexture(color.r, color.g, color.b, color.a or 1)
    return texture
end

--[[
    Create a game playing area (bordered container)
    @param parent Frame
    @param width number
    @param height number
    @return Frame
]]
function GameUI:CreatePlayArea(parent, width, height)
    local area = CreateBackdropFrame("Frame", nil, parent)
    area:SetSize(width, height)

    area:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    area:SetBackdropColor(0.05, 0.05, 0.08, 1)
    area:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    return area
end

-- Register with addon
HopeAddon:RegisterModule("GameUI", GameUI)
HopeAddon.GameUI = GameUI

HopeAddon:Debug("GameUI module loaded")
