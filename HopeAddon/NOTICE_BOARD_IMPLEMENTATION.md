# Tavern Notice Board Implementation Guide

## Overview

This document contains exact, copy-paste ready code for implementing the Notice Board UI redesign. Each payload is self-contained and can be executed sequentially.

**Goal:** Replace the cluttered 360x380 popup with a clean 340x260 popup that has inline attribution instead of a separate preview box.

---

## PRE-IMPLEMENTATION: Verify Current State

Before starting, verify these files exist and contain the expected code:

```
□ HopeAddon/Core/Constants.lua - Contains C.SOCIAL_TAB (line ~4912)
□ HopeAddon/UI/Components.lua - Contains CreateStyledButton (line ~1238)
□ HopeAddon/Journal/Journal.lua - Contains GetRumorPopup (line ~5606)
```

---

## PAYLOAD 1: Add Constants

### Step 1.1: Edit Constants.lua

**File:** `HopeAddon/Core/Constants.lua`

**Action:** Find line containing `C.SOCIAL_TAB = {` (approximately line 4912) and locate the closing `}` of that table (approximately line 4951).

**Find this line:**
```lua
    LOOT_COMMENT_MAX = 100,
}
```

**Replace with:**
```lua
    LOOT_COMMENT_MAX = 100,

    -- Notice Board Popup (Phase 52 redesign)
    NOTICE_BOARD = {
        WIDTH = 340,
        HEIGHT = 260,
        COMPOSER_HEIGHT = 100,
        TOGGLE_WIDTH = 140,
        TOGGLE_HEIGHT = 28,
        TOGGLE_SPACING = 12,
        ATTRIBUTION_HEIGHT = 18,
        DIVIDER_HEIGHT = 1,
        PADDING = 16,
    },
}
```

**Verification:** After edit, the SOCIAL_TAB table should end with the NOTICE_BOARD sub-table.

---

## PAYLOAD 2: Add CreateToggleButtonGroup Component

### Step 2.1: Edit Components.lua

**File:** `HopeAddon/UI/Components.lua`

**Action:** Find the end of `CreateStyledButton` function. Search for the line:
```lua
    return button
end
```
that ends the CreateStyledButton function (approximately line 1330).

**Add AFTER that function (after its closing `end`):**

```lua

--[[
    Create a group of mutually-exclusive toggle buttons (radio-like behavior)
    @param parent Frame - Parent frame
    @param options table - Array of { id, label, icon, color, colorName }
    @param onSelect function - Called with (selectedId) when selection changes
    @param config table - Optional: { width, height, spacing, defaultId }
    @return Frame - Container frame with .buttons table and :SetSelected(id) method
]]
function Components:CreateToggleButtonGroup(parent, options, onSelect, config)
    config = config or {}
    local width = config.width or 140
    local height = config.height or 28
    local spacing = config.spacing or 8
    local defaultId = config.defaultId or (options[1] and options[1].id)

    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(height)

    local totalWidth = (#options * width) + ((#options - 1) * spacing)
    container:SetWidth(totalWidth)

    container.buttons = {}
    container.selectedId = defaultId

    local xOffset = 0
    for i, opt in ipairs(options) do
        -- Create button without click handler first
        local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
        btn:SetSize(width, height)
        btn:SetPoint("LEFT", container, "LEFT", xOffset, 0)

        -- Apply backdrop
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        btn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

        local optColor = opt.color or { 0.4, 0.4, 0.4 }
        btn:SetBackdropBorderColor(optColor[1], optColor[2], optColor[3], 0.6)

        -- Store option data
        btn.optionId = opt.id
        btn.optionData = opt

        -- Add icon if provided
        if opt.icon then
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", btn, "LEFT", 8, 0)
            icon:SetTexture(opt.icon)
            btn.icon = icon
        end

        -- Add text label
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if opt.icon then
            text:SetPoint("LEFT", btn, "LEFT", 28, 0)
        else
            text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        end
        text:SetText(opt.label or "Option")
        text:SetTextColor(0.7, 0.7, 0.7)
        btn.text = text

        -- Hover effects
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        end)

        btn:SetScript("OnLeave", function(self)
            -- Restore appropriate border color based on selection state
            if container.selectedId == self.optionId then
                self:SetBackdropBorderColor(1, 0.84, 0, 1)
            else
                local c = self.optionData.color or { 0.4, 0.4, 0.4 }
                self:SetBackdropBorderColor(c[1], c[2], c[3], 0.6)
            end
        end)

        -- Click handler
        btn:SetScript("OnClick", function(self)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            if container.selectedId ~= self.optionId then
                container:SetSelected(self.optionId)
                if onSelect then onSelect(self.optionId) end
            end
        end)

        container.buttons[i] = btn
        container.buttons[opt.id] = btn
        xOffset = xOffset + width + spacing
    end

    -- Selection method
    function container:SetSelected(id)
        self.selectedId = id
        for _, btn in ipairs(self.buttons) do
            if type(btn) == "table" and btn.optionId then
                local isSelected = (btn.optionId == id)
                if isSelected then
                    btn:SetBackdropColor(0.2, 0.2, 0.2, 1)
                    btn:SetBackdropBorderColor(1, 0.84, 0, 1)
                    btn.text:SetTextColor(1, 1, 1)
                else
                    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
                    local c = btn.optionData.color or { 0.4, 0.4, 0.4 }
                    btn:SetBackdropBorderColor(c[1], c[2], c[3], 0.6)
                    btn.text:SetTextColor(0.7, 0.7, 0.7)
                end
            end
        end
    end

    -- Initialize selection
    container:SetSelected(defaultId)

    return container
end
```

**Verification:** The new function should appear after CreateStyledButton in Components.lua.

---

## PAYLOAD 3: Replace GetRumorPopup Function

### Step 3.1: Delete Old Constants in Journal.lua

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Find and DELETE lines 5565-5600 (the local constants and POST_TYPE_OPTIONS table).

**DELETE this entire block:**
```lua
local POST_POPUP_WIDTH = 360
local POST_POPUP_HEIGHT = 380

-- Post type options (Phase 50)
local POST_TYPE_OPTIONS = {
    {
        id = "IC",
        label = "In Character",
        description = "Your name and title will be shown",
        color = { 0.2, 0.8, 0.2 },       -- Fel green
        icon = "Interface\\Icons\\Spell_Holy_MindVision",
        previewFormat = function(playerName, title)
            if title and title ~= "" then
                return string.format("|cFFFFD700%s|r |cFF808080<%s>|r:", playerName, title)
            end
            return string.format("|cFFFFD700%s|r:", playerName)
        end,
    },
    {
        id = "ANON",
        label = "Tavern Rumor",
        description = "Anonymous - 'A patron whispers...'",
        color = { 0.61, 0.19, 1.0 },     -- Arcane purple
        icon = "Interface\\Icons\\INV_Scroll_01",
        previewFormat = function()
            return "|cFF808080A patron whispers|r:"
        end,
    },
}

-- Status options for status mode (kept for backward compatibility)
local STATUS_OPTIONS = {
    { id = "IC", label = "In Character", color = {0.0, 1.0, 0.0}, hex = "00FF00" },
    { id = "OOC", label = "Out of Character", color = {0.5, 0.5, 0.5}, hex = "808080" },
    { id = "LF_RP", label = "Looking for RP", color = {1.0, 0.41, 0.71}, hex = "FF69B4" },
}
```

### Step 3.2: Replace GetRumorPopup Function

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Find the `GetRumorPopup` function (search for `function Journal:GetRumorPopup()`) and DELETE the entire function from its opening line to its closing `end` (approximately lines 5606-5876).

**REPLACE with this new implementation:**

```lua
--[[
    Get or create the notice board post popup (redesigned Phase 52)
    @return Frame - The popup frame
]]
function Journal:GetRumorPopup()
    if self.rumorPopup then
        return self.rumorPopup
    end

    local C = HopeAddon.Constants
    local NB = C.SOCIAL_TAB.NOTICE_BOARD
    local Components = HopeAddon.Components

    -- Create popup frame
    local popup = CreateFrame("Frame", "HopePostPopup", UIParent, "BackdropTemplate")
    popup:SetSize(NB.WIDTH, NB.HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(1.0, 0.84, 0.0, 1)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -12)
    title:SetText(HopeAddon:ColorText("TAVERN NOTICE BOARD", "GOLD_BRIGHT"))
    popup.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Content area
    local content = CreateFrame("Frame", nil, popup)
    content:SetPoint("TOPLEFT", popup, "TOPLEFT", NB.PADDING, -36)
    content:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -NB.PADDING, 50)
    popup.content = content

    -- ========================================
    -- COMPOSER FRAME (Attribution + Edit combined)
    -- ========================================
    local composerFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    composerFrame:SetHeight(NB.COMPOSER_HEIGHT)
    composerFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    composerFrame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    composerFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    composerFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    composerFrame:SetBackdropBorderColor(0.2, 0.8, 0.2, 0.8)
    popup.composerFrame = composerFrame

    -- Attribution text (dynamic based on post type)
    local attributionText = composerFrame:CreateFontString(nil, "OVERLAY")
    attributionText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    attributionText:SetPoint("TOPLEFT", composerFrame, "TOPLEFT", 10, -8)
    attributionText:SetPoint("TOPRIGHT", composerFrame, "TOPRIGHT", -10, -8)
    attributionText:SetJustifyH("LEFT")
    popup.attributionText = attributionText

    -- Subtle divider line
    local divider = composerFrame:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", attributionText, "BOTTOMLEFT", 0, -4)
    divider:SetPoint("TOPRIGHT", attributionText, "BOTTOMRIGHT", 0, -4)
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.5)

    -- Edit box (below attribution)
    local editBox = CreateFrame("EditBox", nil, composerFrame)
    editBox:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    editBox:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -4)
    editBox:SetPoint("BOTTOMRIGHT", composerFrame, "BOTTOMRIGHT", -10, 8)
    editBox:SetMaxLetters(100)
    editBox:SetAutoFocus(false)
    editBox:SetMultiLine(true)
    editBox:SetTextInsets(0, 0, 0, 0)
    editBox:SetTextColor(1, 1, 1)
    popup.editBox = editBox

    -- ========================================
    -- STATUS ROW (Cooldown + Character Counter)
    -- ========================================
    local statusRow = CreateFrame("Frame", nil, content)
    statusRow:SetHeight(16)
    statusRow:SetPoint("TOPLEFT", composerFrame, "BOTTOMLEFT", 0, -4)
    statusRow:SetPoint("TOPRIGHT", composerFrame, "BOTTOMRIGHT", 0, -4)

    -- Cooldown text (left side)
    local cooldownText = statusRow:CreateFontString(nil, "OVERLAY")
    cooldownText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    cooldownText:SetPoint("LEFT", statusRow, "LEFT", 0, 0)
    cooldownText:SetTextColor(1, 0.5, 0.5)
    cooldownText:Hide()
    popup.cooldownText = cooldownText

    -- Character counter (right side)
    local charCounter = statusRow:CreateFontString(nil, "OVERLAY")
    charCounter:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    charCounter:SetPoint("RIGHT", statusRow, "RIGHT", 0, 0)
    charCounter:SetText("0 / 100")
    charCounter:SetTextColor(0.6, 0.6, 0.6)
    popup.charCounter = charCounter

    -- ========================================
    -- TOGGLE BUTTONS (IC vs Anonymous)
    -- ========================================
    local toggleOptions = {
        {
            id = "IC",
            label = "IC Post",
            icon = "Interface\\Icons\\Spell_Holy_MindVision",
            color = { 0.2, 0.8, 0.2 },
        },
        {
            id = "ANON",
            label = "Anonymous",
            icon = "Interface\\Icons\\INV_Scroll_01",
            color = { 0.61, 0.19, 1.0 },
        },
    }

    local toggleGroup = Components:CreateToggleButtonGroup(content, toggleOptions, function(selectedId)
        popup.selectedPostType = selectedId
        Journal:UpdateNoticeboardAttribution()
    end, {
        width = NB.TOGGLE_WIDTH,
        height = NB.TOGGLE_HEIGHT,
        spacing = NB.TOGGLE_SPACING,
        defaultId = "IC",
    })
    toggleGroup:SetPoint("TOP", statusRow, "BOTTOM", 0, -12)
    popup.toggleGroup = toggleGroup
    popup.selectedPostType = "IC"

    -- ========================================
    -- ACTION BUTTONS
    -- ========================================
    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(90, 24)
    cancelBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", NB.PADDING, 12)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        popup:Hide()
    end)
    popup.cancelBtn = cancelBtn

    local postBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    postBtn:SetSize(90, 24)
    postBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -NB.PADDING, 12)
    postBtn:SetText("Post")
    popup.postBtn = postBtn

    postBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        local text = editBox:GetText()
        if text and text ~= "" and HopeAddon.ActivityFeed then
            local isAnonymous = (popup.selectedPostType == "ANON")
            if HopeAddon.ActivityFeed:PostMessage(text, isAnonymous) then
                editBox:SetText("")
                popup:Hide()
                if Journal.mainFrame and Journal.mainFrame:IsVisible() then
                    Journal:SelectSocialSubTab("feed")
                end
            end
        else
            HopeAddon:Print("Please enter a message to post.")
        end
    end)

    -- ========================================
    -- EDIT BOX SCRIPTS
    -- ========================================
    editBox:SetScript("OnTextChanged", function(self)
        local len = #self:GetText()
        charCounter:SetText(len .. " / 100")
        if len >= 100 then
            charCounter:SetTextColor(1, 0.3, 0.3)
        elseif len >= 80 then
            charCounter:SetTextColor(1, 0.8, 0)
        else
            charCounter:SetTextColor(0.6, 0.6, 0.6)
        end
    end)

    editBox:SetScript("OnEscapePressed", function()
        popup:Hide()
    end)

    -- Escape key handler for popup
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    popup:Hide()
    self.rumorPopup = popup
    return popup
end
```

**Verification:** The GetRumorPopup function should now be approximately 150 lines instead of 270 lines.

---

## PAYLOAD 4: Replace Update Functions

### Step 4.1: Delete Old Update Functions

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Find and DELETE both `UpdatePostTypeSelection` and `UpdatePostPreview` functions.

**DELETE this function (UpdatePostTypeSelection):**
```lua
--[[
    Update post type radio button selection visuals
]]
function Journal:UpdatePostTypeSelection()
    local popup = self.rumorPopup
    if not popup then return end

    for _, btn in ipairs(popup.postTypeButtons) do
        if popup.selectedPostType == btn.typeId then
            -- Selected state
            btn.radio:SetTexCoord(0.25, 0.5, 0, 1)  -- Checked
            btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            btn:SetBackdropBorderColor(btn.option.color[1], btn.option.color[2], btn.option.color[3], 1)
        else
            -- Unselected state
            btn.radio:SetTexCoord(0, 0.25, 0, 1)  -- Unchecked
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            btn:SetBackdropBorderColor(btn.option.color[1], btn.option.color[2], btn.option.color[3], 0.4)
        end
    end

    -- Update preview frame border to match selected type
    local selectedOption = nil
    for _, opt in ipairs(POST_TYPE_OPTIONS) do
        if opt.id == popup.selectedPostType then
            selectedOption = opt
            break
        end
    end
    if selectedOption then
        popup.previewFrame:SetBackdropBorderColor(selectedOption.color[1], selectedOption.color[2], selectedOption.color[3], 0.6)
    end
end
```

**DELETE this function (UpdatePostPreview):**
```lua
--[[
    Update the preview text based on current selection and text
]]
function Journal:UpdatePostPreview()
    local popup = self.rumorPopup
    if not popup then return end

    local text = popup.editBox:GetText()
    if not text or text == "" then
        popup.previewText:SetText("|cFF808080Your message will appear here...|r")
        return
    end

    -- Truncate for preview
    if #text > 50 then
        text = text:sub(1, 47) .. "..."
    end

    -- Get the format function for the selected type
    local selectedOption = nil
    for _, opt in ipairs(POST_TYPE_OPTIONS) do
        if opt.id == popup.selectedPostType then
            selectedOption = opt
            break
        end
    end

    if selectedOption and selectedOption.previewFormat then
        local playerName = UnitName("player")
        local title = nil
        if HopeAddon.FellowTravelers then
            local profile = HopeAddon.FellowTravelers:GetMyProfile()
            if profile and profile.selectedTitle then
                title = profile.selectedTitle
            end
        end
        local attribution = selectedOption.previewFormat(playerName, title)
        popup.previewText:SetText(attribution .. " \"" .. text .. "\"")
    else
        popup.previewText:SetText("\"" .. text .. "\"")
    end
end
```

### Step 4.2: Add New UpdateNoticeboardAttribution Function

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Add the new function in place of the deleted functions (same location).

**ADD this new function:**

```lua
--[[
    Update the attribution text and composer border based on selected post type
    Called when: popup opens, post type toggle changes
]]
function Journal:UpdateNoticeboardAttribution()
    local popup = self.rumorPopup
    if not popup then return end

    local C = HopeAddon.Constants

    -- Get player info for IC posts
    local playerName = UnitName("player")
    local title = nil
    if HopeAddon.FellowTravelers then
        local profile = HopeAddon.FellowTravelers:GetMyProfile()
        if profile and profile.selectedTitle then
            title = profile.selectedTitle
        end
    end

    -- Update attribution text and border color based on post type
    if popup.selectedPostType == "IC" then
        -- IC Post: Show player name with optional title
        if title and title ~= "" then
            popup.attributionText:SetText("|cFFFFD700" .. playerName .. "|r |cFF808080<" .. title .. ">|r:")
        else
            popup.attributionText:SetText("|cFFFFD700" .. playerName .. "|r:")
        end
        popup.composerFrame:SetBackdropBorderColor(0.2, 0.8, 0.2, 0.8)  -- Fel green
    else
        -- Anonymous: "A patron whispers"
        popup.attributionText:SetText("|cFF9B30FFA patron whispers|r:")
        popup.composerFrame:SetBackdropBorderColor(0.61, 0.19, 1.0, 0.8)  -- Arcane purple
    end
end
```

**Verification:** There should now be one `UpdateNoticeboardAttribution` function instead of two separate update functions.

---

## PAYLOAD 5: Update ShowRumorPopup Function

### Step 5.1: Replace ShowRumorPopup

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Find the `ShowRumorPopup` function and REPLACE it entirely.

**Find this function:**
```lua
function Journal:ShowRumorPopup()
    local popup = self:GetRumorPopup()
    popup:Show()
    popup.editBox:SetText("")
    popup.charCounter:SetText("0 / 100")
    popup.selectedPostType = "IC"  -- Default to IC Post

    -- Check cooldown
    if HopeAddon.ActivityFeed then
        local canPost, remaining = HopeAddon.ActivityFeed:CanPost()
        if not canPost then
            local mins = math.floor(remaining / 60)
            local secs = remaining % 60
            popup.cooldownText:SetText(string.format("Cooldown: %d:%02d", mins, secs))
            popup.cooldownText:Show()
            popup.postBtn:Disable()
        else
            popup.cooldownText:Hide()
            popup.postBtn:Enable()
        end
    end

    self:UpdatePostTypeSelection()
    self:UpdatePostPreview()
    popup.editBox:SetFocus()
end
```

**REPLACE with:**

```lua
--[[
    Show the notice board post popup
]]
function Journal:ShowRumorPopup()
    local popup = self:GetRumorPopup()
    popup:Show()

    -- Reset state
    popup.editBox:SetText("")
    popup.charCounter:SetText("0 / 100")
    popup.charCounter:SetTextColor(0.6, 0.6, 0.6)
    popup.selectedPostType = "IC"

    -- Reset toggle selection
    if popup.toggleGroup then
        popup.toggleGroup:SetSelected("IC")
    end

    -- Check cooldown
    if HopeAddon.ActivityFeed then
        local canPost, remaining = HopeAddon.ActivityFeed:CanPost()
        if not canPost then
            local mins = math.floor(remaining / 60)
            local secs = remaining % 60
            popup.cooldownText:SetText(string.format("Cooldown: %d:%02d", mins, secs))
            popup.cooldownText:Show()
            popup.postBtn:Disable()
        else
            popup.cooldownText:Hide()
            popup.postBtn:Enable()
        end
    end

    -- Update attribution for default selection
    self:UpdateNoticeboardAttribution()

    -- Focus edit box
    popup.editBox:SetFocus()
end
```

**Verification:** ShowRumorPopup should now call `UpdateNoticeboardAttribution()` instead of `UpdatePostTypeSelection()` and `UpdatePostPreview()`.

---

## PAYLOAD 6: Cleanup and Verification

### Step 6.1: Search for Dead References

**File:** `HopeAddon/Journal/Journal.lua`

**Action:** Search the entire file for these strings and verify they NO LONGER EXIST:

```
□ POST_TYPE_OPTIONS - Should NOT be found (deleted in Payload 3)
□ STATUS_OPTIONS - Should NOT be found (deleted in Payload 3)
□ postTypeButtons - Should NOT be found (replaced with toggleGroup)
□ previewFrame - Should NOT be found (removed, using inline attribution)
□ previewText - Should NOT be found (removed)
□ previewLabel - Should NOT be found (removed)
□ UpdatePostPreview - Should NOT be found (replaced with UpdateNoticeboardAttribution)
□ UpdatePostTypeSelection - Should NOT be found (replaced with UpdateNoticeboardAttribution)
```

### Step 6.2: Verify New References Exist

**Action:** Search and verify these NEW elements exist:

```
□ NOTICE_BOARD - Should be found in Constants.lua
□ CreateToggleButtonGroup - Should be found in Components.lua
□ UpdateNoticeboardAttribution - Should be found in Journal.lua
□ composerFrame - Should be found in Journal.lua GetRumorPopup
□ attributionText - Should be found in Journal.lua GetRumorPopup
□ toggleGroup - Should be found in Journal.lua GetRumorPopup
```

### Step 6.3: Test In-Game

**Testing Checklist:**

```
□ /reload - No Lua errors in chat
□ Open Social tab in Journal
□ Click "+ Share" button
□ Popup opens (should be 340x260, smaller than before)
□ Attribution shows "PlayerName:" or "PlayerName <Title>:"
□ Click "Anonymous" toggle button
□ Attribution changes to "A patron whispers:"
□ Border color changes from green to purple
□ Click "IC Post" toggle button
□ Attribution changes back to player name
□ Border color changes back to green
□ Type in edit box - text appears
□ Character counter updates (0/100, 50/100, etc.)
□ Counter turns yellow at 80 characters
□ Counter turns red at 100 characters
□ Press Escape - popup closes
□ Reopen popup - state is reset to IC, empty text
□ Click X button - popup closes
□ Click Cancel button - popup closes
□ Type message, click Post - popup closes, feed refreshes
□ Drag popup by title area - popup moves
□ If on cooldown: cooldown text shows, Post button disabled
```

---

## ROLLBACK PROCEDURE

If something breaks, restore from git or manually:

1. **Constants.lua:** Remove the `NOTICE_BOARD = { ... },` block from `C.SOCIAL_TAB`

2. **Components.lua:** Remove the entire `CreateToggleButtonGroup` function

3. **Journal.lua:** Restore the original code from git for lines 5565-5993

---

## SUMMARY OF CHANGES

| File | Lines Changed | Net Change |
|------|--------------|------------|
| Constants.lua | +12 lines (NOTICE_BOARD table) | +12 |
| Components.lua | +95 lines (CreateToggleButtonGroup) | +95 |
| Journal.lua | -270 lines (old), +180 lines (new) | -90 |
| **Total** | | **+17 lines** |

**Visual Result:**
- Popup size: 360x380 → 340x260 (38% smaller)
- Removed: Separate preview box, two radio button cards, preview label
- Added: Inline attribution, compact toggle buttons, cleaner layout
