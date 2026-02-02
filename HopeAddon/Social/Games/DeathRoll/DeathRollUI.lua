--[[
    HopeAddon Death Roll UI
    Extended UI components for Death Roll game
]]

local DeathRollUI = {}

-- Use centralized backdrop frame creation from Core.lua
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

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

-- Danger level colors and messages for gameshow effect
local DANGER_LEVELS = {
    SAFE = {
        color = { r = 1, g = 0.84, b = 0 },       -- Gold
        message = "SAFE!",
        sound = "safe",
    },
    CAUTION = {
        color = { r = 1, g = 0.8, b = 0 },        -- Yellow
        message = "Getting risky...",
        sound = "caution",
    },
    DANGER = {
        color = { r = 1, g = 0.5, b = 0 },        -- Orange
        message = "DANGER ZONE!",
        sound = "danger",
    },
    CRITICAL = {
        color = { r = 1, g = 0.2, b = 0.2 },      -- Red
        message = "ONE WRONG MOVE...",
        sound = "critical",
    },
    DEATH = {
        color = { r = 0.5, g = 0, b = 0 },        -- Dark red
        message = "ELIMINATED!",
        sound = "death",
    },
}

-- Animation timing constants (in seconds)
local ANIMATION_TIMING = {
    SUSPENSE_DELAY = 0.05,      -- Time before showing number
    REVEAL_DURATION = 0.4,      -- PopIn animation duration
    MESSAGE_DELAY = 0.15,       -- Delay before showing danger message
    MESSAGE_FADE = 0.8,         -- How long danger message stays
    TURN_PROMPT_DELAY = 1.2,    -- Delay before showing turn prompt
    TOTAL_SEQUENCE = 1.5,       -- Total animation lock time
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

-- Gameshow UI frames (per game)
DeathRollUI.gameshowFrames = {}  -- [gameId] = { bigNumber, turnPrompt }
DeathRollUI.animationTimers = {}  -- [gameId] = { timer handles }

-- Frame pools for efficient memory management
DeathRollUI.bigNumberPool = nil
DeathRollUI.turnPromptPool = nil

--============================================================
-- LIFECYCLE
--============================================================

function DeathRollUI:OnInitialize()
    HopeAddon:Debug("DeathRollUI initializing...")
end

function DeathRollUI:OnEnable()
    HopeAddon:Debug("DeathRollUI enabled")

    -- Create frame pools for gameshow UI
    self:CreateFramePools()
end

--[[
    Create frame pools for gameshow UI components
    Uses HopeAddon.FramePool for efficient memory management
]]
function DeathRollUI:CreateFramePools()
    local FramePool = HopeAddon.FramePool
    if not FramePool then
        HopeAddon:Debug("FramePool not available, pools disabled")
        return
    end

    -- Big number frame pool
    self.bigNumberPool = FramePool:NewNamed("DeathRoll_BigNumber",
        -- Create function
        function()
            local container = CreateFrame("Frame", nil, UIParent)
            container:SetSize(1, 120)  -- Width set dynamically when parented

            -- Semi-transparent background for focus
            local bg = container:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0, 0, 0, 0.3)
            container.bg = bg

            -- The big number text (using largest available font)
            local numberText = container:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
            numberText:SetPoint("CENTER", container, "CENTER", 0, 15)
            numberText:SetText("")
            container.numberText = numberText

            -- Danger message below number
            local dangerMessage = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            dangerMessage:SetPoint("TOP", numberText, "BOTTOM", 0, -5)
            dangerMessage:SetText("")
            container.dangerMessage = dangerMessage

            container:Hide()
            return container
        end,
        -- Reset function
        function(frame)
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)  -- Park at UIParent when pooled
            frame:SetAlpha(1)  -- Reset to visible for next acquire
            frame.numberText:SetText("")
            frame.numberText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
            frame.dangerMessage:SetText("")
            -- Stop any active effects
            if HopeAddon.Effects then
                HopeAddon.Effects:StopGlowsOnParent(frame)
            end
        end
    )

    -- Turn prompt frame pool
    self.turnPromptPool = FramePool:NewNamed("DeathRoll_TurnPrompt",
        -- Create function
        function()
            local frame = CreateBackdropFrame("Frame", nil, UIParent)
            frame:SetSize(1, 70)  -- Width set dynamically when parented (increased for button)

            frame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            frame:SetBackdropColor(0.1, 0.08, 0.15, 0.95)

            -- Main prompt text
            local promptText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            promptText:SetPoint("TOP", frame, "TOP", 0, -6)
            promptText:SetText("")
            frame.promptText = promptText

            -- Roll button (big clickable button)
            local rollBtn = CreateFrame("Button", nil, frame)
            rollBtn:SetSize(100, 28)
            rollBtn:SetPoint("TOP", promptText, "BOTTOM", 0, -4)

            -- Button background
            local btnBg = rollBtn:CreateTexture(nil, "BACKGROUND")
            btnBg:SetAllPoints()
            btnBg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
            rollBtn.bg = btnBg

            -- Button border
            local btnBorder = rollBtn:CreateTexture(nil, "BORDER")
            btnBorder:SetPoint("TOPLEFT", -2, 2)
            btnBorder:SetPoint("BOTTOMRIGHT", 2, -2)
            btnBorder:SetColorTexture(0.8, 0.7, 0.2, 1)
            rollBtn.border = btnBorder

            -- Button text
            local btnText = rollBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            btnText:SetPoint("CENTER")
            btnText:SetText("ROLL!")
            btnText:SetTextColor(1, 1, 1)
            rollBtn.text = btnText

            -- Hover effects
            rollBtn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.3, 0.8, 0.3, 1)
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayHover()
                end
            end)
            rollBtn:SetScript("OnLeave", function(self)
                self.bg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
            end)

            rollBtn:Hide()  -- Hidden by default, shown when it's your turn
            frame.rollBtn = rollBtn

            -- Command hint text (below button)
            local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            hintText:SetPoint("TOP", rollBtn, "BOTTOM", 0, -3)
            hintText:SetText("")
            frame.hintText = hintText

            frame:Hide()
            return frame
        end,
        -- Reset function
        function(frame)
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)  -- Park at UIParent when pooled
            frame:SetAlpha(1)  -- Reset to visible for next acquire
            frame:SetBackdropBorderColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b, 1)
            frame.promptText:SetText("")
            frame.hintText:SetText("")
            -- Reset roll button
            if frame.rollBtn then
                frame.rollBtn:Hide()
                frame.rollBtn:SetScript("OnClick", nil)
                frame.rollBtn.bg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
            end
            -- Stop any active effects
            if HopeAddon.Effects then
                HopeAddon.Effects:StopGlowsOnParent(frame)
            end
        end
    )

    HopeAddon:Debug("DeathRollUI frame pools created")
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

    -- Clean up gameshow frames (releases back to pools)
    for gameId, _ in pairs(self.gameshowFrames) do
        self:CleanupGameshowFrames(gameId)
    end
    wipe(self.gameshowFrames)

    -- Cancel all animation timers
    for gameId, timers in pairs(self.animationTimers) do
        for _, timer in ipairs(timers) do
            if timer and timer.Cancel then timer:Cancel() end
        end
    end
    wipe(self.animationTimers)

    -- Destroy frame pools
    if self.bigNumberPool then
        self.bigNumberPool:Destroy()
        self.bigNumberPool = nil
    end
    if self.turnPromptPool then
        self.turnPromptPool:Destroy()
        self.turnPromptPool = nil
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
    local window = CreateBackdropFrame("Frame", "HopeDeathRollSetup", UIParent)
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
    local window = CreateBackdropFrame("Frame", "HopeDeathRollHistory_" .. gameId, UIParent)
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
    closeBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Close History", 1, 0.82, 0)
        GameTooltip:Show()
    end)
    closeBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    window:Show()
end

--============================================================
-- GAMESHOW UI COMPONENTS
--============================================================

--[[
    Calculate danger level based on roll result and max
    @param roll number - The roll result
    @param max number - The maximum possible roll
    @return string - Danger level key (SAFE, CAUTION, DANGER, CRITICAL, DEATH)
]]
function DeathRollUI:GetDangerLevel(roll, max)
    if roll == 1 then
        return "DEATH"
    end

    local ratio = roll / max
    if ratio <= 0.10 then
        return "CRITICAL"  -- 2-10%
    elseif ratio <= 0.25 then
        return "DANGER"    -- 10-25%
    elseif ratio <= 0.50 then
        return "CAUTION"   -- 25-50%
    else
        return "SAFE"      -- 50%+
    end
end

--[[
    Acquire and configure a big number frame from the pool
    @param parent Frame - Parent frame (game window content)
    @return Frame - The big number container frame
]]
function DeathRollUI:AcquireBigNumberFrame(parent)
    local container

    if self.bigNumberPool then
        container = self.bigNumberPool:Acquire()
    else
        -- Fallback: create frame directly if pool not available
        container = CreateFrame("Frame", nil, parent)
        local bg = container:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.3)
        container.bg = bg
        local numberText = container:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
        numberText:SetPoint("CENTER", container, "CENTER", 0, 15)
        container.numberText = numberText
        local dangerMessage = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        dangerMessage:SetPoint("TOP", numberText, "BOTTOM", 0, -5)
        container.dangerMessage = dangerMessage
    end

    -- Configure for this parent
    container:SetParent(parent)
    container:SetSize(parent:GetWidth() - 20, 120)
    container:ClearAllPoints()
    container:SetPoint("CENTER", parent, "CENTER", 0, 20)
    container:SetAlpha(0)
    container:Hide()

    -- Reset text styling
    container.numberText:SetText("")
    container.numberText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
    container.dangerMessage:SetText("")
    container.dangerMessage:SetTextColor(1, 1, 1)

    return container
end

--[[
    Acquire and configure a turn prompt frame from the pool
    @param parent Frame - Parent frame (game window content)
    @return Frame - The turn prompt frame
]]
function DeathRollUI:AcquireTurnPromptFrame(parent)
    local frame

    if self.turnPromptPool then
        frame = self.turnPromptPool:Acquire()
    else
        -- Fallback: create frame directly if pool not available
        frame = CreateBackdropFrame("Frame", nil, parent)
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        frame:SetBackdropColor(0.1, 0.08, 0.15, 0.95)
        local promptText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        promptText:SetPoint("TOP", frame, "TOP", 0, -6)
        frame.promptText = promptText

        -- Create roll button for fallback
        local rollBtn = CreateFrame("Button", nil, frame)
        rollBtn:SetSize(100, 28)
        rollBtn:SetPoint("TOP", promptText, "BOTTOM", 0, -4)
        local btnBg = rollBtn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
        rollBtn.bg = btnBg
        local btnBorder = rollBtn:CreateTexture(nil, "BORDER")
        btnBorder:SetPoint("TOPLEFT", -2, 2)
        btnBorder:SetPoint("BOTTOMRIGHT", 2, -2)
        btnBorder:SetColorTexture(0.8, 0.7, 0.2, 1)
        rollBtn.border = btnBorder
        local btnText = rollBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        btnText:SetPoint("CENTER")
        btnText:SetText("ROLL!")
        btnText:SetTextColor(1, 1, 1)
        rollBtn.text = btnText
        rollBtn:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(0.3, 0.8, 0.3, 1)
        end)
        rollBtn:SetScript("OnLeave", function(self)
            self.bg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
        end)
        rollBtn:Hide()
        frame.rollBtn = rollBtn

        local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hintText:SetPoint("TOP", rollBtn, "BOTTOM", 0, -3)
        frame.hintText = hintText
    end

    -- Configure for this parent
    frame:SetParent(parent)
    frame:SetSize(parent:GetWidth() - 30, 70)  -- Increased height for button
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOM", parent, "BOTTOM", 0, 50)
    frame:SetBackdropBorderColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b, 1)
    frame:Hide()

    -- Reset text
    frame.promptText:SetText("YOUR TURN!")
    frame.promptText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
    frame.hintText:SetText("or type /roll")
    frame.hintText:SetTextColor(0.6, 0.6, 0.6)

    -- Reset button
    if frame.rollBtn then
        frame.rollBtn:Hide()
        frame.rollBtn:SetScript("OnClick", nil)
    end

    return frame
end

--[[
    Initialize gameshow frames for a game (acquires from pools)
    @param gameId string - Game ID
    @param contentFrame Frame - The game window content frame
]]
function DeathRollUI:InitializeGameshowFrames(gameId, contentFrame)
    if self.gameshowFrames[gameId] then
        -- Already initialized
        return
    end

    local bigNumber = self:AcquireBigNumberFrame(contentFrame)
    local turnPrompt = self:AcquireTurnPromptFrame(contentFrame)

    self.gameshowFrames[gameId] = {
        bigNumber = bigNumber,
        turnPrompt = turnPrompt,
        contentFrame = contentFrame,
    }

    self.animationTimers[gameId] = {}
    HopeAddon:Debug("Gameshow frames initialized for", gameId)
end

--[[
    Cleanup gameshow frames for a game (releases back to pools)
    @param gameId string - Game ID
]]
function DeathRollUI:CleanupGameshowFrames(gameId)
    local frames = self.gameshowFrames[gameId]
    if not frames then return end

    -- Cancel timers first to prevent callbacks on released frames
    local timers = self.animationTimers[gameId]
    if timers then
        for _, timer in ipairs(timers) do
            if timer and timer.Cancel then timer:Cancel() end
        end
    end
    self.animationTimers[gameId] = nil

    -- Release big number frame back to pool
    if frames.bigNumber then
        if self.bigNumberPool then
            self.bigNumberPool:Release(frames.bigNumber)
        else
            -- Fallback: destroy if no pool
            frames.bigNumber:Hide()
            frames.bigNumber:SetParent(nil)
        end
    end

    -- Release turn prompt frame back to pool
    if frames.turnPrompt then
        if self.turnPromptPool then
            self.turnPromptPool:Release(frames.turnPrompt)
        else
            -- Fallback: destroy if no pool
            frames.turnPrompt:Hide()
            frames.turnPrompt:SetParent(nil)
        end
    end

    self.gameshowFrames[gameId] = nil
    HopeAddon:Debug("Gameshow frames cleaned up for", gameId)
end

--[[
    Add a timer to the game's timer list for cleanup
    @param gameId string - Game ID
    @param timer table - Timer handle with Cancel method
]]
function DeathRollUI:AddTimer(gameId, timer)
    if not self.animationTimers[gameId] then
        self.animationTimers[gameId] = {}
    end
    table.insert(self.animationTimers[gameId], timer)
end

--[[
    Show roll result with gameshow animation sequence
    @param gameId string - Game ID
    @param roll number - The roll result
    @param max number - The maximum possible roll
    @param playerName string - Who rolled
    @param isLocalPlayer boolean - Is this the local player's roll
]]
function DeathRollUI:ShowRollResult(gameId, roll, max, playerName, isLocalPlayer)
    local frames = self.gameshowFrames[gameId]
    if not frames or not frames.bigNumber then
        HopeAddon:Debug("No gameshow frames for", gameId)
        return
    end

    local bigNumber = frames.bigNumber
    local dangerLevel = self:GetDangerLevel(roll, max)
    local dangerInfo = DANGER_LEVELS[dangerLevel]

    -- Hide turn prompt during roll reveal
    if frames.turnPrompt then
        frames.turnPrompt:Hide()
        if HopeAddon.Effects then
            HopeAddon.Effects:StopGlowsOnParent(frames.turnPrompt)
        end
    end

    -- Play suspense sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayDeathRollSuspense()
    end

    -- Short suspense delay before reveal
    local revealTimer = HopeAddon.Timer:After(ANIMATION_TIMING.SUSPENSE_DELAY, function()
        -- Set the number
        bigNumber.numberText:SetText(tostring(roll))
        bigNumber.numberText:SetTextColor(dangerInfo.color.r, dangerInfo.color.g, dangerInfo.color.b)

        -- Clear danger message initially
        bigNumber.dangerMessage:SetText("")

        -- Show frame
        bigNumber:Show()

        -- Pop in animation
        if HopeAddon.Effects then
            HopeAddon.Effects:PopIn(bigNumber, ANIMATION_TIMING.REVEAL_DURATION)
        else
            bigNumber:SetAlpha(1)
        end

        -- Play reveal sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayDeathRollReveal()
        end

        -- Show danger message after brief delay
        local messageTimer = HopeAddon.Timer:After(ANIMATION_TIMING.MESSAGE_DELAY, function()
            bigNumber.dangerMessage:SetText(dangerInfo.message)
            bigNumber.dangerMessage:SetTextColor(dangerInfo.color.r, dangerInfo.color.g, dangerInfo.color.b)

            -- Play danger-appropriate sound
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayDeathRoll(dangerInfo.sound)
            end

            -- Shake effect for dangerous rolls
            if (dangerLevel == "CRITICAL" or dangerLevel == "DANGER") and HopeAddon.Effects then
                HopeAddon.Effects:Shake(bigNumber, 6, 0.3)
            end

            -- Burst effect for death roll
            if dangerLevel == "DEATH" and HopeAddon.Effects then
                HopeAddon.Effects:CreateBurstEffect(bigNumber, "HELLFIRE_RED")
            end
        end)
        self:AddTimer(gameId, messageTimer)

        -- Fade message after delay (but keep number visible)
        local fadeTimer = HopeAddon.Timer:After(ANIMATION_TIMING.MESSAGE_FADE, function()
            bigNumber.dangerMessage:SetText("")
        end)
        self:AddTimer(gameId, fadeTimer)
    end)
    self:AddTimer(gameId, revealTimer)
end

--[[
    Show turn prompt for the next player
    @param gameId string - Game ID
    @param maxRoll number - The current max roll for hint text
    @param isYourTurn boolean - Is it the local player's turn
    @param opponentName string|nil - Opponent name if waiting
]]
function DeathRollUI:ShowTurnPrompt(gameId, maxRoll, isYourTurn, opponentName)
    local frames = self.gameshowFrames[gameId]
    if not frames or not frames.turnPrompt then return end

    local turnPrompt = frames.turnPrompt

    -- Stop any existing glow
    if HopeAddon.Effects then
        HopeAddon.Effects:StopGlowsOnParent(turnPrompt)
    end

    if isYourTurn then
        -- YOUR TURN - pulsing gold
        turnPrompt.promptText:SetText("YOUR TURN!")
        turnPrompt.promptText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
        turnPrompt.hintText:SetText("or type /roll 1-" .. maxRoll)
        turnPrompt:SetBackdropBorderColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b, 1)

        -- Show and configure the roll button
        if turnPrompt.rollBtn then
            turnPrompt.rollBtn.text:SetText("ROLL 1-" .. maxRoll)
            turnPrompt.rollBtn.maxRoll = maxRoll  -- Store on button to avoid closure capture
            turnPrompt.rollBtn:SetScript("OnClick", function(self)
                -- Execute the roll command (reference from self, not outer scope)
                RandomRoll(1, self.maxRoll)
                -- Play click sound
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayClick()
                end
            end)
            turnPrompt.rollBtn:Show()
        end

        -- Add pulsing glow effect
        if HopeAddon.Effects then
            HopeAddon.Effects:CreatePulsingGlow(turnPrompt, "GOLD_BRIGHT", 0.6)
        end

        -- Play turn notification sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayDeathRollYourTurn()
        end
    else
        -- Waiting for opponent - hide roll button
        if turnPrompt.rollBtn then
            turnPrompt.rollBtn:Hide()
            turnPrompt.rollBtn:SetScript("OnClick", nil)
        end

        local name = opponentName or "opponent"
        turnPrompt.promptText:SetText("Waiting for " .. name .. "...")
        turnPrompt.promptText:SetTextColor(0.6, 0.6, 0.6)
        turnPrompt.hintText:SetText("They must /roll 1-" .. maxRoll)
        turnPrompt:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end

    turnPrompt:Show()
end

--[[
    Hide turn prompt
    @param gameId string - Game ID
]]
function DeathRollUI:HideTurnPrompt(gameId)
    local frames = self.gameshowFrames[gameId]
    if not frames or not frames.turnPrompt then return end

    -- Hide the roll button too
    if frames.turnPrompt.rollBtn then
        frames.turnPrompt.rollBtn:Hide()
    end

    frames.turnPrompt:Hide()
    if HopeAddon.Effects then
        HopeAddon.Effects:StopGlowsOnParent(frames.turnPrompt)
    end
end

--[[
    Update the big number display without animation (for UI refresh)
    @param gameId string - Game ID
    @param currentMax number - Current max roll value
]]
function DeathRollUI:UpdateBigNumber(gameId, currentMax)
    local frames = self.gameshowFrames[gameId]
    if not frames or not frames.bigNumber then return end

    frames.bigNumber.numberText:SetText(tostring(currentMax))
    frames.bigNumber.numberText:SetTextColor(COLORS.GOLD.r, COLORS.GOLD.g, COLORS.GOLD.b)
    frames.bigNumber.dangerMessage:SetText("")
    frames.bigNumber:SetAlpha(1)
    frames.bigNumber:Show()
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
