# Tavern Notice Board UI Redesign Plan

## Problem Statement

The current "Tavern Notice Board" popup has visual issues:
1. **Preview box sticks out** - The "Your message will appear here..." preview frame is a separate container that creates visual discontinuity
2. **Cluttered layout** - Multiple distinct sections (edit box, post type buttons, preview, action buttons) don't flow cohesively
3. **Wasted space** - The popup is 360x380 but the content doesn't fill it elegantly

---

## Current Architecture Analysis

### Entry Point
- **Status Bar** (`CreateSocialStatusBar`, Journal.lua:6038-6132) at top of Social tab
- Green "+ Share" button (lines 6101-6129)
- Clicking calls `Journal:ShowRumorPopup()`

### Current Popup Elements (GetRumorPopup, lines 5606-5876)

| Element | Type | Size | Line | Purpose |
|---------|------|------|------|---------|
| `popup` | Frame | 360x380 | 5612-5630 | Main container, BackdropTemplate, draggable |
| `title` | FontString | - | 5632-5637 | "TAVERN NOTICE BOARD" |
| `subtitle` | FontString | - | 5639-5643 | "Share with Fellow Travelers" |
| `closeBtn` | Button | - | 5646-5650 | UIPanelCloseButton template |
| `content` | Frame | fill | 5652-5656 | Inner content container |
| `editBoxFrame` | Frame | 320x60 | 5658-5669 | BackdropTemplate wrapper for edit |
| `editBox` | EditBox | fill | 5671-5680 | Multi-line text input, 100 char max |
| `charCounter` | FontString | - | 5682-5688 | "0 / 100" character count |
| `cooldownText` | FontString | - | 5690-5696 | "Cooldown: X:XX" (hidden by default) |
| `howToLabel` | FontString | - | 5716-5720 | "Choose how to post:" |
| `postTypeButtons[1]` | Button | 320x50 | 5727-5792 | IC Post radio button |
| `postTypeButtons[2]` | Button | 320x50 | 5727-5792 | Anonymous radio button |
| `previewLabel` | FontString | - | 5795-5800 | "Preview:" **← PROBLEM** |
| `previewFrame` | Frame | 320x36 | 5802-5813 | Preview container **← PROBLEM** |
| `previewText` | FontString | - | 5815-5822 | "Your message will appear here..." **← PROBLEM** |
| `cancelBtn` | Button | 90x24 | 5826-5835 | UIPanelButtonTemplate |
| `postBtn` | Button | 90x24 | 5837-5860 | UIPanelButtonTemplate |

### Support Functions
| Function | Line | Purpose |
|----------|------|---------|
| `UpdatePostTypeSelection()` | 5881-5910 | Updates radio visuals + preview border color |
| `UpdatePostPreview()` | 5915-5953 | Updates preview text based on type + message |
| `ShowRumorPopup()` | 5958-5983 | Shows popup, resets state, checks cooldown |
| `HideRumorPopup()` | 5988-5992 | Hides popup |

### Local Constants (Journal.lua)
```lua
-- Line 5565-5566
local POST_POPUP_WIDTH = 360
local POST_POPUP_HEIGHT = 380

-- Lines 5568-5593
local POST_TYPE_OPTIONS = {
    { id = "IC", label = "In Character", description = "...", color = {...}, icon = "...", previewFormat = function() },
    { id = "ANON", label = "Tavern Rumor", description = "...", color = {...}, icon = "...", previewFormat = function() },
}
```

### Global Constants (Constants.lua)
```lua
-- Line 4912-4951
C.SOCIAL_TAB = {
    STATUS_BAR_HEIGHT = 36,
    RUMOR_INPUT_HEIGHT = 50,
    -- ... other constants
}

-- Lines 4958-4992
C.FEED_POST_TYPES = {
    IC_POST = { id = "IC", wireCode = "IC", label = "In Character", ... },
    ANON_RUMOR = { id = "ANON", wireCode = "ANON", label = "Tavern Rumor", ... },
}
```

### ActivityFeed API (ActivityFeed.lua)
```lua
-- Line 89
RUMOR_COOLDOWN = 300  -- 5 minutes

-- Line 1013
function ActivityFeed:PostMessage(text, isAnonymous)

-- Line 1095
function ActivityFeed:CanPost()  -- Returns (canPost, remainingSeconds)
```

---

## Redesign Specification

### Visual Goal
```
┌─────────────────────────────────────┐
│  TAVERN NOTICE BOARD       [X]     │  <- Title bar
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ Thrall <Hero>:                │ │  <- Attribution (live, styled)
│  │ ───────────────────────────── │ │  <- Subtle divider
│  │ Looking for raiders for       │ │  <- Edit box (multi-line)
│  │ Karazhan tonight!             │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│  Cooldown: 4:32          32 / 100  │  <- Status row (cooldown + counter)
│                                     │
│  ┌─────────────┐ ┌─────────────┐   │  <- Toggle buttons (side by side)
│  │ [✓] IC Post │ │ [ ] Anon    │   │
│  └─────────────┘ └─────────────┘   │
│                                     │
│  [Cancel]              [Post]      │  <- Action buttons
└─────────────────────────────────────┘
```

### Size Reduction
- **Before:** 360x380 (143,200 px²)
- **After:** 340x260 (88,400 px²) - 38% smaller

---

## Payload Organization

### PAYLOAD 1: Constants & Types (15 min)

**File: Constants.lua**

Add new popup constants to `C.SOCIAL_TAB`:
```lua
-- Add to C.SOCIAL_TAB (line ~4951)
    -- Notice Board Popup (Phase 52 redesign)
    NOTICE_BOARD = {
        WIDTH = 340,
        HEIGHT = 260,
        COMPOSER_HEIGHT = 100,      -- Attribution + edit area combined
        TOGGLE_WIDTH = 140,
        TOGGLE_HEIGHT = 28,
        TOGGLE_SPACING = 12,
        ATTRIBUTION_HEIGHT = 18,    -- Height for attribution text line
        DIVIDER_HEIGHT = 1,
        PADDING = 16,
    },
```

**File: Journal.lua**

Update local constants:
```lua
-- Replace lines 5565-5566
local POST_POPUP_WIDTH = HopeAddon.Constants.SOCIAL_TAB.NOTICE_BOARD.WIDTH or 340
local POST_POPUP_HEIGHT = HopeAddon.Constants.SOCIAL_TAB.NOTICE_BOARD.HEIGHT or 260
```

**Checklist:**
- [ ] Add `NOTICE_BOARD` sub-table to `C.SOCIAL_TAB` in Constants.lua
- [ ] Update local constants in Journal.lua to reference new values
- [ ] Verify constants load correctly

---

### PAYLOAD 2: New Reusable Component - CreateToggleButtonGroup (20 min)

**File: Components.lua**

Add new component function:
```lua
--[[
    Create a group of mutually-exclusive toggle buttons (radio-like behavior)
    @param parent Frame - Parent frame
    @param options table - Array of { id, label, icon, color }
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
        local btn = self:CreateStyledButton(container, opt.label, width, height, function()
            if container.selectedId ~= opt.id then
                container:SetSelected(opt.id)
                if onSelect then onSelect(opt.id) end
            end
        end, { colorName = opt.colorName or "ARCANE_PURPLE" })

        btn:SetPoint("LEFT", container, "LEFT", xOffset, 0)
        btn.optionId = opt.id
        btn.optionData = opt

        -- Add icon if provided
        if opt.icon then
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", btn, "LEFT", 8, 0)
            icon:SetTexture(opt.icon)
            btn.icon = icon
            btn.text:SetPoint("CENTER", 10, 0)  -- Shift text right for icon
        end

        container.buttons[i] = btn
        container.buttons[opt.id] = btn  -- Also index by id
        xOffset = xOffset + width + spacing
    end

    -- Selection method
    function container:SetSelected(id)
        self.selectedId = id
        for _, btn in ipairs(self.buttons) do
            local isSelected = (btn.optionId == id)
            -- Visual update
            if isSelected then
                btn:SetBackdropColor(0.2, 0.2, 0.2, 1)
                btn:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold border
                btn.text:SetTextColor(1, 1, 1)
                -- Could add checkmark icon here
            else
                btn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
                local color = btn.optionData.color or { 0.4, 0.4, 0.4 }
                btn:SetBackdropBorderColor(color[1], color[2], color[3], 0.6)
                btn.text:SetTextColor(0.7, 0.7, 0.7)
            end
        end
    end

    -- Initialize selection
    container:SetSelected(defaultId)

    return container
end
```

**Checklist:**
- [ ] Add `CreateToggleButtonGroup` to Components.lua
- [ ] Test with simple two-option case
- [ ] Verify selection state changes visually
- [ ] Verify callback fires on selection change

---

### PAYLOAD 3: Rewrite GetRumorPopup - Frame Structure (30 min)

**File: Journal.lua**

Replace `GetRumorPopup()` (lines 5606-5876) with new structure:

```lua
function Journal:GetRumorPopup()
    if self.rumorPopup then
        return self.rumorPopup
    end

    local C = HopeAddon.Constants
    local NB = C.SOCIAL_TAB.NOTICE_BOARD
    local Components = HopeAddon.Components

    -- Create popup frame (smaller than before)
    local popup = CreateFrame("Frame", "HopePostPopup", UIParent, "BackdropTemplate")
    popup:SetSize(NB.WIDTH, NB.HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 32, edgeSize = 16,
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
    closeBtn:SetScript("OnClick", function() popup:Hide() end)

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
    composerFrame:SetBackdropBorderColor(0.2, 0.8, 0.2, 0.8)  -- Default: IC green
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
            colorName = "FEL_GREEN",
        },
        {
            id = "ANON",
            label = "Anonymous",
            icon = "Interface\\Icons\\INV_Scroll_01",
            color = { 0.61, 0.19, 1.0 },
            colorName = "ARCANE_PURPLE",
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

**Checklist:**
- [ ] Replace `GetRumorPopup()` with new implementation
- [ ] Remove old `previewLabel`, `previewFrame`, `previewText` creation
- [ ] Remove old `postTypeButtons` array creation
- [ ] Remove old `howToLabel` creation
- [ ] Verify popup opens with correct size
- [ ] Verify close button works
- [ ] Verify dragging works
- [ ] Verify escape key closes popup

---

### PAYLOAD 4: New Attribution Update Function (15 min)

**File: Journal.lua**

Replace `UpdatePostTypeSelection()` and `UpdatePostPreview()` with single new function:

```lua
--[[
    Update the attribution text and composer border based on selected post type
    Called when: popup opens, post type toggle changes
]]
function Journal:UpdateNoticeboardAttribution()
    local popup = self.rumorPopup
    if not popup then return end

    local C = HopeAddon.Constants
    local postType = C.FEED_POST_TYPES[popup.selectedPostType == "IC" and "IC_POST" or "ANON_RUMOR"]

    -- Get player info for IC posts
    local playerName = UnitName("player")
    local title = nil
    if HopeAddon.FellowTravelers then
        local profile = HopeAddon.FellowTravelers:GetMyProfile()
        if profile and profile.selectedTitle then
            title = profile.selectedTitle
        end
    end

    -- Update attribution text
    if popup.selectedPostType == "IC" then
        local attribution = postType.formatAttribution(playerName, title, true)
        popup.attributionText:SetText(attribution .. ":")
    else
        popup.attributionText:SetText("|cFF9B30FFA patron whispers|r:")
    end

    -- Update composer border color
    local borderColor = postType.borderColor
    popup.composerFrame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 0.8)
end
```

**Delete these functions:**
- `UpdatePostTypeSelection()` (lines 5881-5910)
- `UpdatePostPreview()` (lines 5915-5953)

**Checklist:**
- [ ] Add `UpdateNoticeboardAttribution()` function
- [ ] Delete `UpdatePostTypeSelection()`
- [ ] Delete `UpdatePostPreview()`
- [ ] Verify attribution updates when toggling IC/Anonymous
- [ ] Verify border color changes with selection

---

### PAYLOAD 5: Update ShowRumorPopup (10 min)

**File: Journal.lua**

Update `ShowRumorPopup()` to work with new structure:

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

**Checklist:**
- [ ] Update `ShowRumorPopup()` with new initialization
- [ ] Verify popup resets correctly on open
- [ ] Verify cooldown display works
- [ ] Verify edit box gets focus
- [ ] Verify toggle group resets to IC

---

### PAYLOAD 6: Cleanup & Testing (15 min)

**File: Journal.lua**

1. **Remove unused local table:**
```lua
-- DELETE lines 5568-5593 (POST_TYPE_OPTIONS)
-- This is now handled by C.FEED_POST_TYPES in Constants.lua
```

2. **Remove unused STATUS_OPTIONS if not used elsewhere:**
```lua
-- DELETE lines 5595-5600 (STATUS_OPTIONS) if not referenced
```

3. **Update any remaining references:**
- Search for `postTypeButtons` - should be none after refactor
- Search for `previewFrame` - should be none after refactor
- Search for `UpdatePostPreview` - should be none after refactor

**Testing Checklist:**
- [ ] `/reload` - No Lua errors
- [ ] Click "+ Share" button in Social tab
- [ ] Popup opens at correct size (340x260)
- [ ] Attribution shows "PlayerName <Title>:" for IC
- [ ] Click "Anonymous" toggle → Attribution changes to "A patron whispers:"
- [ ] Border color changes (green for IC, purple for Anonymous)
- [ ] Type in edit box → Character counter updates
- [ ] Counter turns yellow at 80, red at 100
- [ ] Press Escape → Popup closes
- [ ] Click X button → Popup closes
- [ ] Click Cancel → Popup closes
- [ ] Type message, click Post → Message appears in Feed
- [ ] Reopen popup → State is reset
- [ ] Wait for cooldown to expire and test again
- [ ] Drag popup by title bar → Works

---

## Summary

| Payload | Description | Est. Time | Files |
|---------|-------------|-----------|-------|
| 1 | Constants & Types | 15 min | Constants.lua, Journal.lua |
| 2 | CreateToggleButtonGroup component | 20 min | Components.lua |
| 3 | Rewrite GetRumorPopup structure | 30 min | Journal.lua |
| 4 | New UpdateNoticeboardAttribution | 15 min | Journal.lua |
| 5 | Update ShowRumorPopup | 10 min | Journal.lua |
| 6 | Cleanup & Testing | 15 min | Journal.lua |
| **Total** | | **~105 min** | |

---

## Rollback Plan

If issues arise, the old implementation can be restored by:
1. Reverting Journal.lua lines 5565-5993
2. Removing new constants from Constants.lua
3. Removing CreateToggleButtonGroup from Components.lua

No database/SavedVariables changes are needed - this is purely UI refactoring.

---

## Future Enhancements (Not in Scope)

- Add placeholder text in edit box ("What's on your mind?")
- Add emoji/icon picker for messages
- Add scheduled posting (post at a specific time)
- Add draft saving (remember unposted message)
- Add image/screenshot attachment support
