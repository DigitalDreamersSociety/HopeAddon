--[[
    HopeAddon Wordle - UI Rendering
    6x5 letter grid, virtual keyboard, and animations

    All dimensions and colors are sourced from HopeAddon.Constants:
    - C.WORDLE_UI: Window/grid/keyboard dimensions
    - C.WORDLE_COLORS: Letter box and keyboard colors
    - C.WORDLE: Animation timings and game rules
]]

local WordleGame = HopeAddon.WordleGame

--============================================================
-- CONSTANTS REFERENCE (from Core/Constants.lua)
--============================================================

-- Helper to get UI constants with fallbacks
local function GetUI()
    local C = HopeAddon.Constants
    return C and C.WORDLE_UI or {
        WINDOW_WIDTH = 420,
        WINDOW_HEIGHT = 680,
        BOX_SIZE = 56,
        BOX_GAP = 8,
        GRID_TOP = -60,
        KEY_WIDTH = 36,
        KEY_HEIGHT = 52,
        KEY_GAP = 6,
        KEYBOARD_TOP = -460,
        TOAST_TOP = -60,
        STATUS_BOTTOM = 15,
        TOAST_PADDING = 32,
        LETTER_FONT_SIZE = 28,
        KEY_FONT_SIZE = 14,
        TOAST_FONT_SIZE = 14,
        KEYBOARD_ROWS = { "QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM" },
    }
end

-- Helper to get color constants with fallbacks
local function GetColors()
    local C = HopeAddon.Constants
    return C and C.WORDLE_COLORS or {
        CORRECT = { r = 0.42, g = 0.67, b = 0.39 },
        PRESENT = { r = 0.79, g = 0.71, b = 0.35 },
        ABSENT = { r = 0.47, g = 0.49, b = 0.49 },
        EMPTY = { r = 0.07, g = 0.07, b = 0.08 },
        TYPING = { r = 0.15, g = 0.15, b = 0.16 },
        BORDER = { r = 0.21, g = 0.22, b = 0.24 },
        BORDER_TYPING = { r = 0.34, g = 0.35, b = 0.36 },
        BORDER_FILLED = { r = 0.55, g = 0.55, b = 0.57 },
        KEY_DEFAULT = { r = 0.5, g = 0.5, b = 0.52 },
        KEY_BORDER = { r = 0.3, g = 0.3, b = 0.3 },
        TEXT_WHITE = { r = 1, g = 1, b = 1 },
        TOAST_SUCCESS = { r = 0, g = 1, b = 0 },
        TOAST_FAILURE = { r = 1, g = 0.3, b = 0.3 },
        TOAST_DEFAULT = { r = 1, g = 1, b = 1 },
        TEXT_DARK = { r = 0.1, g = 0.1, b = 0.1 },
    }
end

--============================================================
-- UI STATE
--============================================================

-- UI frame references
WordleGame.ui = {
    frame = nil,            -- Main window
    letterBoxes = {},       -- [row][col] = box frame
    keyboardKeys = {},      -- [letter] = key button
    statusText = nil,       -- Status line
    title = nil,            -- Title text
    -- Issue #28: Track animation timers for cleanup
    animationTimers = {},   -- Array of timer handles for cancellation
}

--============================================================
-- MAIN WINDOW CREATION
--============================================================

--[[
    Show the Wordle UI
    @param gameId string
]]
function WordleGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then
        return
    end

    -- Create frame if needed
    if not self.ui.frame then
        self:CreateMainFrame()
    end

    -- Reset UI state
    self:ResetUIState()

    -- Update with current game state
    self:UpdateUI(gameId)

    -- Show frame
    self.ui.frame:Show()

    -- Set focus for keyboard input
    self.ui.frame:EnableKeyboard(true)
end

--[[
    Create the main game window
]]
function WordleGame:CreateMainFrame()
    local UI = GetUI()

    local frame = CreateFrame("Frame", "HopeWordleFrame", UIParent, "BackdropTemplate")
    frame:SetSize(UI.WINDOW_WIDTH, UI.WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)

    -- Make draggable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Apply TBC-themed backdrop
    if HopeAddon.Components and HopeAddon.Components.ApplyBackdrop then
        HopeAddon.Components:ApplyBackdrop(frame, "GAME_WINDOW", "DARK", "GOLD")
    else
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0.1, 0.1, 0.12, 0.95)
        frame:SetBackdropBorderColor(0.8, 0.6, 0.2, 1)
    end

    -- Close on Escape
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            WordleGame:CloseUI()
        else
            WordleGame:HandleKeyPress(key)
        end
    end)

    -- Title (combined header section)
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -12)
    title:SetText("|cFF6AAA64W|cFFC9B458o|cFF787C7EW|r |cFFFFD700Wordle|r")
    self.ui.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        WordleGame:CloseUI()
    end)

    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("|cFFAAAAAAGuess the 5-letter WoW word!|r")
    self.ui.subtitle = subtitle

    -- Header separator line (visual hierarchy)
    local headerLine = frame:CreateTexture(nil, "ARTWORK")
    headerLine:SetColorTexture(0.3, 0.3, 0.3, 0.5)
    headerLine:SetSize(UI.WINDOW_WIDTH - 40, 1)
    headerLine:SetPoint("TOP", subtitle, "BOTTOM", 0, -8)
    self.ui.headerLine = headerLine

    -- Create letter grid
    self:CreateLetterGrid(frame)

    -- Create keyboard
    self:CreateKeyboard(frame)

    -- Status text (positioned above bottom padding)
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("BOTTOM", frame, "BOTTOM", 0, UI.STATUS_BOTTOM or 15)
    statusText:SetText("Attempts: 0/" .. self.MAX_GUESSES)
    self.ui.statusText = statusText

    -- Store reference
    self.ui.frame = frame

    -- Initially hidden
    frame:Hide()
end

--============================================================
-- LETTER GRID
--============================================================

--[[
    Create the 6x5 grid of letter boxes
    @param parent frame
]]
function WordleGame:CreateLetterGrid(parent)
    local UI = GetUI()
    self.ui.letterBoxes = {}

    -- Calculate grid position (centered)
    local gridWidth = (UI.BOX_SIZE * self.WORD_LENGTH) + (UI.BOX_GAP * (self.WORD_LENGTH - 1))
    local startX = (UI.WINDOW_WIDTH - gridWidth) / 2

    for row = 1, self.MAX_GUESSES do
        self.ui.letterBoxes[row] = {}

        for col = 1, self.WORD_LENGTH do
            local box = self:CreateLetterBox(parent, row, col)
            local xOffset = startX + (col - 1) * (UI.BOX_SIZE + UI.BOX_GAP)
            local yOffset = UI.GRID_TOP - (row - 1) * (UI.BOX_SIZE + UI.BOX_GAP)

            box:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
            self.ui.letterBoxes[row][col] = box
        end
    end
end

--[[
    Create a single letter box
    @param parent frame
    @param row number
    @param col number
    @return frame
]]
function WordleGame:CreateLetterBox(parent, row, col)
    local UI = GetUI()
    local COLORS = GetColors()

    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(UI.BOX_SIZE, UI.BOX_SIZE)

    box:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })

    -- Default empty state
    local c = COLORS.EMPTY
    box:SetBackdropColor(c.r, c.g, c.b, 1)
    local bc = COLORS.BORDER
    box:SetBackdropBorderColor(bc.r, bc.g, bc.b, 1)

    -- Letter text (larger font for bigger boxes)
    local UI = GetUI()
    local letter = box:CreateFontString(nil, "OVERLAY")
    letter:SetFont("Fonts\\FRIZQT__.TTF", UI.LETTER_FONT_SIZE or 28, "OUTLINE")
    letter:SetPoint("CENTER")
    letter:SetText("")
    letter:SetTextColor(1, 1, 1, 1)
    box.letter = letter

    return box
end

--[[
    Update a letter box state
    @param row number
    @param col number
    @param letter string|nil
    @param state string|nil - "correct", "present", "absent", "typing", or nil for empty
]]
function WordleGame:UpdateLetterBox(row, col, letter, state)
    local COLORS = GetColors()

    local box = self.ui.letterBoxes[row] and self.ui.letterBoxes[row][col]
    if not box then
        return
    end

    -- Set letter
    box.letter:SetText(letter or "")

    -- Set colors based on state
    local bgColor, borderColor

    if state == "correct" then
        bgColor = COLORS.CORRECT
        borderColor = COLORS.CORRECT
    elseif state == "present" then
        bgColor = COLORS.PRESENT
        borderColor = COLORS.PRESENT
    elseif state == "absent" then
        bgColor = COLORS.ABSENT
        borderColor = COLORS.ABSENT
    elseif state == "typing" then
        bgColor = COLORS.TYPING
        -- Use brighter border when letter is present (standard Wordle behavior)
        if letter and letter ~= "" then
            borderColor = COLORS.BORDER_FILLED or COLORS.BORDER_TYPING
        else
            borderColor = COLORS.BORDER_TYPING
        end
    else
        bgColor = COLORS.EMPTY
        borderColor = COLORS.BORDER
    end

    box:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, 1)
    box:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

    -- Text color (dark on yellow for readability)
    if state == "present" then
        local tc = COLORS.TEXT_DARK
        box.letter:SetTextColor(tc.r, tc.g, tc.b, 1)
    else
        local tc = COLORS.TEXT_WHITE
        box.letter:SetTextColor(tc.r, tc.g, tc.b, 1)
    end
end

--============================================================
-- VIRTUAL KEYBOARD
--============================================================

--[[
    Create the on-screen keyboard
    @param parent frame
]]
function WordleGame:CreateKeyboard(parent)
    local UI = GetUI()
    self.ui.keyboardKeys = {}

    -- Special keys
    local ENTER_KEY = "ENTER"
    local BACK_KEY = "BACK"

    local keyboardRows = UI.KEYBOARD_ROWS or { "QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM" }

    for rowNum, rowLetters in ipairs(keyboardRows) do
        -- Calculate row width and starting position
        local rowKeys = {}

        -- Add special keys to bottom row
        if rowNum == 3 then
            table.insert(rowKeys, ENTER_KEY)
        end

        for i = 1, #rowLetters do
            table.insert(rowKeys, rowLetters:sub(i, i))
        end

        if rowNum == 3 then
            table.insert(rowKeys, BACK_KEY)
        end

        -- Calculate row width
        local rowWidth = 0
        for _, key in ipairs(rowKeys) do
            if key == ENTER_KEY or key == BACK_KEY then
                rowWidth = rowWidth + UI.KEY_WIDTH * 1.5 + UI.KEY_GAP
            else
                rowWidth = rowWidth + UI.KEY_WIDTH + UI.KEY_GAP
            end
        end
        rowWidth = rowWidth - UI.KEY_GAP -- Remove last gap

        local startX = (UI.WINDOW_WIDTH - rowWidth) / 2
        local currentX = startX

        for _, key in ipairs(rowKeys) do
            local keyWidth = UI.KEY_WIDTH
            local keyText = key

            if key == ENTER_KEY then
                keyWidth = UI.KEY_WIDTH * 1.5
                keyText = "ENT"
            elseif key == BACK_KEY then
                keyWidth = UI.KEY_WIDTH * 1.5
                keyText = "<"
            end

            local keyBtn = self:CreateKeyboardKey(parent, key, keyText, keyWidth)
            keyBtn:SetPoint("TOPLEFT", parent, "TOPLEFT",
                currentX, UI.KEYBOARD_TOP - (rowNum - 1) * (UI.KEY_HEIGHT + UI.KEY_GAP))

            self.ui.keyboardKeys[key] = keyBtn
            currentX = currentX + keyWidth + UI.KEY_GAP
        end
    end
end

--[[
    Create a single keyboard key
    @param parent frame
    @param key string - Key identifier
    @param text string - Display text
    @param width number
    @return button
]]
function WordleGame:CreateKeyboardKey(parent, key, text, width)
    local UI = GetUI()
    local COLORS = GetColors()

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, UI.KEY_HEIGHT)

    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })

    -- Default grey color
    local kc = COLORS.KEY_DEFAULT
    local kb = COLORS.KEY_BORDER
    btn:SetBackdropColor(kc.r, kc.g, kc.b, 1)
    btn:SetBackdropBorderColor(kb.r, kb.g, kb.b, 1)

    -- Key text (larger font for bigger keys)
    local keyText = btn:CreateFontString(nil, "OVERLAY")
    keyText:SetFont("Fonts\\FRIZQT__.TTF", UI.KEY_FONT_SIZE or 14, "OUTLINE")
    keyText:SetPoint("CENTER")
    keyText:SetText(text)
    keyText:SetTextColor(1, 1, 1, 1)
    btn.text = keyText

    -- Click handler
    btn:SetScript("OnClick", function()
        -- Don't accept input during reveal animation
        local game = WordleGame.currentGameId and WordleGame.games[WordleGame.currentGameId]
        if game and game.isRevealing then
            return
        end

        if key == "ENTER" then
            local success, result = WordleGame:SubmitCurrentInput(WordleGame.currentGameId)
            if not success and result then
                WordleGame:ShowFloatingMessage(result, true)
            end
        elseif key == "BACK" then
            WordleGame:RemoveLetter(WordleGame.currentGameId)
        else
            WordleGame:AddLetter(WordleGame.currentGameId, key)
        end
    end)

    -- Hover effect
    btn:SetScript("OnEnter", function(self)
        local r, g, b = self:GetBackdropColor()
        self:SetBackdropColor(r + 0.1, g + 0.1, b + 0.1, 1)
    end)

    btn:SetScript("OnLeave", function(self)
        -- Restore color based on state
        WordleGame:UpdateKeyColor(key)
    end)

    -- Key press feedback (darken on click)
    btn:SetScript("OnMouseDown", function(self)
        local r, g, b = self:GetBackdropColor()
        self:SetBackdropColor(r * 0.8, g * 0.8, b * 0.8, 1)
    end)

    btn:SetScript("OnMouseUp", function(self)
        -- Restore color based on state
        WordleGame:UpdateKeyColor(key)
    end)

    return btn
end

--[[
    Update keyboard key color based on letter state
    @param letter string
]]
function WordleGame:UpdateKeyColor(letter)
    local COLORS = GetColors()

    local key = self.ui.keyboardKeys[letter]
    if not key then
        return
    end

    local game = self:GetCurrentGame()
    if not game then
        return
    end

    local state = game.letterStates[letter]
    local color

    if state == self.RESULT.CORRECT then
        color = COLORS.CORRECT
    elseif state == self.RESULT.PRESENT then
        color = COLORS.PRESENT
    elseif state == self.RESULT.ABSENT then
        color = COLORS.ABSENT
    else
        color = COLORS.KEY_DEFAULT
    end

    key:SetBackdropColor(color.r, color.g, color.b, 1)

    -- Text color (dark on yellow)
    if state == self.RESULT.PRESENT then
        local tc = COLORS.TEXT_DARK
        key.text:SetTextColor(tc.r, tc.g, tc.b, 1)
    else
        local tc = COLORS.TEXT_WHITE
        key.text:SetTextColor(tc.r, tc.g, tc.b, 1)
    end
end

--============================================================
-- KEYBOARD INPUT HANDLING
--============================================================

--[[
    Handle physical keyboard input
    @param key string
]]
function WordleGame:HandleKeyPress(key)
    if not self.currentGameId then
        return
    end

    local game = self.games[self.currentGameId]
    if not game or game.state ~= self.STATE.PLAYING then
        return
    end

    -- Don't accept input during reveal animation
    if game.isRevealing then
        return
    end

    if key == "BACKSPACE" then
        self:RemoveLetter(self.currentGameId)
    elseif key == "ENTER" then
        local success, result = self:SubmitCurrentInput(self.currentGameId)
        if not success and result then
            -- Show floating error message
            self:ShowFloatingMessage(result, true)
        end
    elseif key:match("^[A-Za-z]$") then
        self:AddLetter(self.currentGameId, key)
    end
end

--============================================================
-- UI UPDATE
--============================================================

--[[
    Update the entire UI to match game state
    @param gameId string
]]
function WordleGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game or not self.ui.frame then
        return
    end

    -- Update letter grid
    for row = 1, self.MAX_GUESSES do
        for col = 1, self.WORD_LENGTH do
            local letter = nil
            local state = nil

            if row <= #game.guesses then
                -- Completed guess
                local guess = game.guesses[row]
                letter = guess.word:sub(col, col)
                state = guess.result[col]
            elseif row == #game.guesses + 1 and game.state == self.STATE.PLAYING then
                -- Current input row
                if col <= #game.currentInput then
                    letter = game.currentInput:sub(col, col)
                    state = "typing"
                end
            end

            self:UpdateLetterBox(row, col, letter, state)
        end
    end

    -- Update keyboard colors
    for letter, _ in pairs(self.ui.keyboardKeys) do
        if letter ~= "ENTER" and letter ~= "BACK" then
            self:UpdateKeyColor(letter)
        end
    end

    -- Update status text
    local statusText = "Attempts: " .. #game.guesses .. "/" .. self.MAX_GUESSES
    if game.opponent then
        statusText = statusText .. "  |  vs: " .. game.opponent
    end

    if game.state == self.STATE.ENDED then
        if game.winner == game.player then
            -- Get win message based on guess count (standard Wordle)
            local winMessages = GetWordleConstants().WIN_MESSAGES or {
                [1] = "Genius!",
                [2] = "Magnificent!",
                [3] = "Impressive!",
                [4] = "Splendid!",
                [5] = "Great!",
                [6] = "Phew!",
            }
            local winMessage = winMessages[#game.guesses] or "Nice!"
            statusText = "|cFF00FF00" .. winMessage .. "|r " .. #game.guesses .. "/" .. self.MAX_GUESSES
            if HopeAddon.Effects then
                HopeAddon.Effects:Celebrate(self.ui.frame, 2)
            end
        else
            statusText = "|cFFFF0000The word was:|r |cFFFFD700" .. game.secretWord .. "|r"
        end
    end

    self.ui.statusText:SetText(statusText)
end

--[[
    Reset UI to initial state
]]
function WordleGame:ResetUIState()
    local COLORS = GetColors()

    -- Clear all letter boxes
    for row = 1, self.MAX_GUESSES do
        for col = 1, self.WORD_LENGTH do
            self:UpdateLetterBox(row, col, nil, nil)
        end
    end

    -- Reset keyboard colors
    local kc = COLORS.KEY_DEFAULT
    local tc = COLORS.TEXT_WHITE
    for letter, key in pairs(self.ui.keyboardKeys) do
        if letter ~= "ENTER" and letter ~= "BACK" then
            key:SetBackdropColor(kc.r, kc.g, kc.b, 1)
            key.text:SetTextColor(tc.r, tc.g, tc.b, 1)
        end
    end
end

--[[
    Show a temporary message (legacy - use ShowFloatingMessage for in-UI toast)
    @param message string
]]
function WordleGame:ShowMessage(message)
    self:ShowFloatingMessage(message, false)
end

--============================================================
-- ANIMATION FUNCTIONS
--============================================================

-- Get Wordle animation constants
local function GetWordleConstants()
    local C = HopeAddon.Constants
    return C and C.WORDLE or {
        REVEAL_DELAY = 0.3,
        FLIP_DURATION = 0.25,
        SHAKE_DURATION = 0.4,
        SHAKE_INTENSITY = 8,
        BOUNCE_DELAY = 0.1,
        BOUNCE_HEIGHT = 12,
        BOUNCE_DURATION = 0.3,
        TOAST_DURATION = 2.0,
        POP_SCALE = 1.12,
        POP_DURATION = 0.05,
        WIN_MESSAGES = {
            [1] = "Genius!",
            [2] = "Magnificent!",
            [3] = "Impressive!",
            [4] = "Splendid!",
            [5] = "Great!",
            [6] = "Phew!",
        },
    }
end

--[[
    Show a floating message above the grid (toast notification)
    @param message string - Text to display
    @param isError boolean - True for error styling
]]
function WordleGame:ShowFloatingMessage(message, isError)
    if not self.ui or not self.ui.frame then
        -- Fallback to chat
        HopeAddon:Print("|cFFFFFF00[Wordle]|r " .. message)
        return
    end

    local constants = GetWordleConstants()
    local parent = self.ui.frame

    -- Create or reuse toast frame
    if not self.ui.toast then
        local UI = GetUI()
        local toast = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        toast:SetSize(200, 44)  -- Slightly taller for better padding
        toast:SetPoint("TOP", parent, "TOP", 0, UI.TOAST_TOP or -60)  -- Below subtitle/header line
        toast:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        toast:SetFrameLevel(parent:GetFrameLevel() + 50)

        local text = toast:CreateFontString(nil, "OVERLAY")
        text:SetFont("Fonts\\FRIZQT__.TTF", UI.TOAST_FONT_SIZE or 14, "OUTLINE")
        text:SetPoint("CENTER")
        toast.text = text

        toast:Hide()
        self.ui.toast = toast
    end

    local toast = self.ui.toast

    -- Set content
    toast.text:SetText(message)

    -- Style based on error state
    if isError then
        toast:SetBackdropColor(0.6, 0.2, 0.2, 0.95)
        toast:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
        toast.text:SetTextColor(1, 0.8, 0.8, 1)
    else
        toast:SetBackdropColor(0.2, 0.2, 0.2, 0.95)
        toast:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        toast.text:SetTextColor(1, 1, 1, 1)
    end

    -- Resize to fit text (more padding for better appearance)
    local UI = GetUI()
    local textWidth = toast.text:GetStringWidth() + (UI.TOAST_PADDING or 32)
    toast:SetWidth(math.max(120, textWidth))

    -- Show and fade out
    toast:SetAlpha(1)
    toast:Show()

    -- Cancel existing fade timer
    if self.ui.toastTimer then
        self.ui.toastTimer:Cancel()
    end

    -- Fade out after delay
    self.ui.toastTimer = HopeAddon.Timer:After(constants.TOAST_DURATION, function()
        if HopeAddon.Animations then
            HopeAddon.Animations:FadeTo(toast, 0, 0.3, function()
                toast:Hide()
            end)
        else
            toast:Hide()
        end
    end)
end

--[[
    Animate letter input with "pop" effect (standard Wordle typing feedback)
    @param row number - Current guess row
    @param col number - Column where letter was added
]]
function WordleGame:AnimateLetterInput(row, col)
    local box = self.ui.letterBoxes[row] and self.ui.letterBoxes[row][col]
    if not box then return end

    local constants = GetWordleConstants()
    local animEnabled = HopeAddon.db and HopeAddon.db.settings.animationsEnabled ~= false

    if not animEnabled then
        return
    end

    -- Quick scale up then restore
    local popScale = constants.POP_SCALE or 1.12
    local popDuration = constants.POP_DURATION or 0.05

    box:SetScale(popScale)

    -- Use timer to restore scale
    if HopeAddon.Timer then
        HopeAddon.Timer:After(popDuration, function()
            if box and box:IsShown() then
                box:SetScale(1.0)
            end
        end)
    else
        -- Fallback: immediate restore
        box:SetScale(1.0)
    end
end

--[[
    Sequential letter reveal with flip animation
    @param gameId string
    @param row number - Row to reveal
    @param results table - Array of result states
    @param onComplete function - Called when all letters revealed
]]
function WordleGame:RevealGuess(gameId, row, results, onComplete)
    local game = self.games[gameId]
    if not game or not self.ui.letterBoxes[row] then
        if onComplete then onComplete() end
        return
    end

    local constants = GetWordleConstants()
    local guess = game.guesses[row]
    if not guess then
        if onComplete then onComplete() end
        return
    end

    local word = guess.word
    local revealed = 0
    local totalLetters = self.WORD_LENGTH

    -- Issue #28: Clear any pending animation timers before starting new sequence
    self.ui.animationTimers = self.ui.animationTimers or {}

    -- Reveal each letter with delay
    for col = 1, totalLetters do
        local delay = (col - 1) * constants.REVEAL_DELAY

        local timer = HopeAddon.Timer:After(delay, function()
            local letter = word:sub(col, col)
            local state = results[col]

            -- Flip the letter box
            self:FlipLetterBox(row, col, letter, state)

            -- Update keyboard after each letter
            self:UpdateKeyColor(letter)

            -- Play tick sound
            if HopeAddon.Sounds then
                if state == self.RESULT.CORRECT then
                    HopeAddon.Sounds:PlayClick()
                end
            end

            revealed = revealed + 1

            -- Check if all revealed
            if revealed >= totalLetters then
                -- Small delay before callback to let last flip finish
                local finalTimer = HopeAddon.Timer:After(constants.FLIP_DURATION, function()
                    if onComplete then onComplete() end
                end)
                -- Issue #28: Track final timer
                if finalTimer then
                    table.insert(self.ui.animationTimers, finalTimer)
                end
            end
        end)
        -- Issue #28: Track timer for potential cancellation
        if timer then
            table.insert(self.ui.animationTimers, timer)
        end
    end
end

--[[
    Flip a letter box with scale animation (simulates 3D flip)
    @param row number
    @param col number
    @param letter string
    @param state string - Result state
]]
function WordleGame:FlipLetterBox(row, col, letter, state)
    local UI = GetUI()

    local box = self.ui.letterBoxes[row] and self.ui.letterBoxes[row][col]
    if not box then return end

    local constants = GetWordleConstants()
    local halfDuration = constants.FLIP_DURATION / 2

    -- Check if animations are enabled
    local animEnabled = HopeAddon.db and HopeAddon.db.settings.animationsEnabled ~= false

    if not animEnabled or not HopeAddon.Animations then
        -- No animation - instant update
        self:UpdateLetterBox(row, col, letter, state)
        return
    end

    -- Store original dimensions
    local originalWidth = UI.BOX_SIZE
    local originalHeight = UI.BOX_SIZE

    -- Phase 1: Shrink horizontally (simulate rotation away)
    HopeAddon.Animations:Tween(halfDuration, function(progress, eased)
        local scale = 1 - eased
        box:SetWidth(math.max(1, originalWidth * scale))
    end, function()
        -- At midpoint: change the content
        self:UpdateLetterBox(row, col, letter, state)

        -- Phase 2: Expand back (simulate rotation toward)
        HopeAddon.Animations:Tween(halfDuration, function(progress, eased)
            local scale = eased
            box:SetWidth(math.max(1, originalWidth * scale))
        end, function()
            -- Ensure full width restored
            box:SetWidth(originalWidth)
        end, HopeAddon.Animations.easing.easeOutQuad)
    end, HopeAddon.Animations.easing.easeInQuad)
end

--[[
    Shake the current input row (invalid word feedback)
    @param gameId string
]]
function WordleGame:ShakeCurrentRow(gameId)
    local game = self.games[gameId]
    if not game then return end

    local currentRow = #game.guesses + 1
    if currentRow > self.MAX_GUESSES then return end

    local constants = GetWordleConstants()
    local boxes = self.ui.letterBoxes[currentRow]
    if not boxes then return end

    -- Play error sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayError()
    end

    -- Check if animations enabled
    local animEnabled = HopeAddon.db and HopeAddon.db.settings.animationsEnabled ~= false

    if not animEnabled or not HopeAddon.Animations then
        return
    end

    -- Store original positions
    local originalPositions = {}
    for col = 1, self.WORD_LENGTH do
        local box = boxes[col]
        if box then
            local point, relativeTo, relativePoint, x, y = box:GetPoint()
            originalPositions[col] = { point = point, relativeTo = relativeTo, relativePoint = relativePoint, x = x, y = y }
        end
    end

    -- Shake pattern: alternating offsets that decrease
    local intensity = constants.SHAKE_INTENSITY
    local duration = constants.SHAKE_DURATION
    local shakeSteps = 9
    local stepTime = duration / shakeSteps

    local shakeOffsets = { intensity, -intensity, intensity * 0.75, -intensity * 0.75, intensity * 0.5, -intensity * 0.5, intensity * 0.25, -intensity * 0.25, 0 }

    for i, offset in ipairs(shakeOffsets) do
        HopeAddon.Timer:After((i - 1) * stepTime, function()
            for col = 1, self.WORD_LENGTH do
                local box = boxes[col]
                local orig = originalPositions[col]
                if box and orig then
                    box:ClearAllPoints()
                    box:SetPoint(orig.point, orig.relativeTo, orig.relativePoint, orig.x + offset, orig.y)
                end
            end
        end)
    end
end

--[[
    Bounce winning row letters sequentially
    @param gameId string
    @param row number
    @param onComplete function
]]
function WordleGame:BounceWinningRow(gameId, row, onComplete)
    local game = self.games[gameId]
    if not game then
        if onComplete then onComplete() end
        return
    end

    local boxes = self.ui.letterBoxes[row]
    if not boxes then
        if onComplete then onComplete() end
        return
    end

    local constants = GetWordleConstants()
    local animEnabled = HopeAddon.db and HopeAddon.db.settings.animationsEnabled ~= false

    if not animEnabled or not HopeAddon.Animations then
        if onComplete then onComplete() end
        return
    end

    local bounced = 0
    local totalLetters = self.WORD_LENGTH

    for col = 1, totalLetters do
        local delay = (col - 1) * constants.BOUNCE_DELAY

        HopeAddon.Timer:After(delay, function()
            local box = boxes[col]
            if not box then
                bounced = bounced + 1
                return
            end

            -- Get original position
            local point, relativeTo, relativePoint, origX, origY = box:GetPoint()
            origY = origY or 0

            local halfBounce = constants.BOUNCE_DURATION / 2

            -- Jump up
            HopeAddon.Animations:Tween(halfBounce, function(progress, eased)
                local offsetY = constants.BOUNCE_HEIGHT * eased
                box:ClearAllPoints()
                box:SetPoint(point, relativeTo, relativePoint, origX, origY + offsetY)
            end, function()
                -- Fall down with bounce easing
                HopeAddon.Animations:Tween(halfBounce, function(progress, eased)
                    local offsetY = constants.BOUNCE_HEIGHT * (1 - eased)
                    box:ClearAllPoints()
                    box:SetPoint(point, relativeTo, relativePoint, origX, origY + offsetY)
                end, function()
                    -- Restore exact position
                    box:ClearAllPoints()
                    box:SetPoint(point, relativeTo, relativePoint, origX, origY)

                    bounced = bounced + 1
                    if bounced >= totalLetters and onComplete then
                        onComplete()
                    end
                end, HopeAddon.Animations.easing.easeOutBounce)
            end, HopeAddon.Animations.easing.easeOutQuad)
        end)
    end
end

--[[
    Update only keyboard colors (without full UI refresh)
    @param gameId string
]]
function WordleGame:UpdateKeyboardColors(gameId)
    local game = self.games[gameId]
    if not game or not self.ui.keyboardKeys then return end

    for letter, _ in pairs(self.ui.keyboardKeys) do
        if letter ~= "ENTER" and letter ~= "BACK" then
            self:UpdateKeyColor(letter)
        end
    end
end

--[[
    Update only status text (without full UI refresh)
    @param gameId string
]]
function WordleGame:UpdateStatusText(gameId)
    local game = self.games[gameId]
    if not game or not self.ui.statusText then return end

    local statusText = "Attempts: " .. #game.guesses .. "/" .. self.MAX_GUESSES
    if game.opponent then
        statusText = statusText .. "  |  vs: " .. game.opponent
    end

    if game.state == self.STATE.ENDED then
        if game.winner == game.player then
            -- Get win message based on guess count (standard Wordle)
            local winMessages = GetWordleConstants().WIN_MESSAGES or {
                [1] = "Genius!",
                [2] = "Magnificent!",
                [3] = "Impressive!",
                [4] = "Splendid!",
                [5] = "Great!",
                [6] = "Phew!",
            }
            local winMessage = winMessages[#game.guesses] or "Nice!"
            statusText = "|cFF00FF00" .. winMessage .. "|r " .. #game.guesses .. "/" .. self.MAX_GUESSES
        else
            statusText = "|cFFFF0000The word was:|r |cFFFFD700" .. game.secretWord .. "|r"
        end
    end

    self.ui.statusText:SetText(statusText)
end

--============================================================
-- UI LIFECYCLE
--============================================================

--[[
    Close the Wordle UI
]]
function WordleGame:CloseUI()
    -- Cancel toast timer to prevent orphaned timer reference
    if self.ui.toastTimer then
        self.ui.toastTimer:Cancel()
        self.ui.toastTimer = nil
    end

    -- Issue #28: Cancel all pending animation timers
    if self.ui.animationTimers then
        for _, timer in ipairs(self.ui.animationTimers) do
            if timer and timer.Cancel then
                timer:Cancel()
            end
        end
        wipe(self.ui.animationTimers)
    end

    if self.ui.frame then
        self.ui.frame:Hide()
        self.ui.frame:EnableKeyboard(false)
    end

    -- Optionally cleanup game
    if self.currentGameId then
        local game = self.games[self.currentGameId]
        if game and game.state == self.STATE.ENDED then
            self:CloseGame(self.currentGameId)
        end
    end
end

--[[
    Toggle UI visibility
]]
function WordleGame:ToggleUI()
    if self.ui.frame and self.ui.frame:IsShown() then
        self:CloseUI()
    elseif self.currentGameId then
        self:ShowUI(self.currentGameId)
    end
end

HopeAddon:Debug("WordleUI module loaded")
