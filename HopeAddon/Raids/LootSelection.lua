--[[
    LootSelection - Post-kill popup for recording which items actually dropped.
    Shown after KillFlash fades, lists all possible boss drops with checkboxes.
    Checked items are saved to the kill history for display on the Records tab.
]]
local LootSelection = {}
HopeAddon.LootSelection = LootSelection

local C_LSP -- lazy reference to C.LOOT_SELECTION_POPUP

-- Frame pool for item rows
LootSelection.itemRowPool = nil
LootSelection._activeRows = {}

local function GetConstants()
    if not C_LSP then
        C_LSP = HopeAddon.Constants.LOOT_SELECTION_POPUP
    end
    return C_LSP
end

--------------------------------------------------------------------------------
-- Item Row Pool
--------------------------------------------------------------------------------

local function CreateItemRow(parent)
    local LSP = GetConstants()
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(LSP.ROW_HEIGHT)

    -- Checkbox
    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(LSP.CHECKBOX_SIZE, LSP.CHECKBOX_SIZE)
    cb:SetPoint("LEFT", row, "LEFT", 4, 0)
    cb:SetHitRectInsets(0, 0, 0, 0)
    row.checkbox = cb

    -- Item icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(LSP.ICON_SIZE, LSP.ICON_SIZE)
    icon:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    -- Icon border
    local border = row:CreateTexture(nil, "OVERLAY")
    border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    row.border = border

    -- Item name
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    nameText:SetPoint("LEFT", icon, "RIGHT", 8, 4)
    nameText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    -- Item type/slot text
    local typeText = row:CreateFontString(nil, "OVERLAY")
    typeText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    typeText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -1)
    typeText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    typeText:SetJustifyH("LEFT")
    typeText:SetTextColor(0.5, 0.5, 0.5)
    row.typeText = typeText

    -- Tooltip on hover
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if self.itemId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. self.itemId)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return row
end

local function ResetItemRow(row)
    row:Hide()
    row:ClearAllPoints()
    row:SetParent(nil)
    row.checkbox:SetChecked(false)
    row.icon:SetTexture(nil)
    row.border:SetVertexColor(1, 1, 1, 1)
    row.nameText:SetText("")
    row.typeText:SetText("")
    row.itemId = nil
end

function LootSelection:EnsurePool()
    if not self.itemRowPool then
        self.itemRowPool = CreateFramePool("Frame", UIParent, nil, ResetItemRow, false, CreateItemRow)
    end
    return self.itemRowPool
end

--------------------------------------------------------------------------------
-- Lazy Singleton Popup
--------------------------------------------------------------------------------

function LootSelection:GetPopup()
    if self.popup then return self.popup end

    local LSP = GetConstants()
    local fonts = HopeAddon.assets.fonts

    local popup = CreateFrame("Frame", "HopeLootSelectionPopup", UIParent, "BackdropTemplate")
    popup:SetSize(LSP.WIDTH, LSP.MAX_HEIGHT)
    popup:SetPoint("RIGHT", UIParent, "RIGHT", -40, 0)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(200)
    popup:SetBackdrop(LSP.BACKDROP)
    popup:SetBackdropColor(LSP.BG_COLOR.r, LSP.BG_COLOR.g, LSP.BG_COLOR.b, LSP.BG_COLOR.a)
    popup:SetBackdropBorderColor(LSP.BORDER_COLOR.r, LSP.BORDER_COLOR.g, LSP.BORDER_COLOR.b, LSP.BORDER_COLOR.a)
    popup:SetMovable(true)
    popup:EnableMouse(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
    popup:Hide()

    -- Header: boss icon + title + close
    local header = CreateFrame("Frame", nil, popup)
    header:SetPoint("TOPLEFT", popup, "TOPLEFT", LSP.PADDING, -LSP.PADDING)
    header:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -LSP.PADDING, -LSP.PADDING)
    header:SetHeight(LSP.HEADER_HEIGHT)

    local bossIcon = header:CreateTexture(nil, "ARTWORK")
    bossIcon:SetSize(28, 28)
    bossIcon:SetPoint("LEFT", header, "LEFT", 0, 0)
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    popup.bossIcon = bossIcon

    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(fonts.HEADER, 13, "")
    titleText:SetPoint("LEFT", bossIcon, "RIGHT", 8, 0)
    titleText:SetTextColor(1, 0.84, 0)
    titleText:SetText("LOOT DROPS")
    popup.titleText = titleText

    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", 4, 0)
    closeBtn:SetScript("OnClick", function()
        LootSelection:DismissWithoutSaving()
    end)

    -- Scroll area
    local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -28, LSP.FOOTER_HEIGHT + LSP.PADDING)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetWidth(LSP.WIDTH - LSP.PADDING * 2 - 20)
    scrollContent:SetHeight(1)
    scrollFrame:SetScrollChild(scrollContent)
    popup.scrollContent = scrollContent

    -- Footer: count text + save button
    local footer = CreateFrame("Frame", nil, popup)
    footer:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", LSP.PADDING, LSP.PADDING)
    footer:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -LSP.PADDING, LSP.PADDING)
    footer:SetHeight(LSP.FOOTER_HEIGHT)

    local countText = footer:CreateFontString(nil, "OVERLAY")
    countText:SetFont(fonts.BODY, 10, "")
    countText:SetPoint("LEFT", footer, "LEFT", 4, 0)
    countText:SetTextColor(0.6, 0.6, 0.6)
    popup.countText = countText

    local saveBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 24)
    saveBtn:SetPoint("RIGHT", footer, "RIGHT", -4, 0)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        LootSelection:SaveAndHide()
    end)
    popup.saveBtn = saveBtn

    -- Escape key closes
    popup:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            LootSelection:DismissWithoutSaving()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    popup:EnableKeyboard(true)

    self.popup = popup
    return popup
end

--------------------------------------------------------------------------------
-- Show / Hide
--------------------------------------------------------------------------------

function LootSelection:ShowForBoss(raidKey, bossId, bossName, bossIcon)
    -- Guard: skip if in combat
    if InCombatLockdown() then return end

    -- Guard: need loot data for this boss
    local Constants = HopeAddon.Constants
    local lootIds = Constants.BOSS_LOOT_IDS and Constants.BOSS_LOOT_IDS[bossName]
    if not lootIds or #lootIds == 0 then return end

    local LSP = GetConstants()
    local popup = self:GetPopup()
    local pool = self:EnsurePool()

    -- Store context for saving
    self._raidKey = raidKey
    self._bossId = bossId
    self._bossName = bossName

    -- Release previous rows
    for _, row in ipairs(self._activeRows) do
        pool:Release(row)
    end
    wipe(self._activeRows)

    -- Set boss icon
    if bossIcon then
        popup.bossIcon:SetTexture(bossIcon)
        popup.bossIcon:Show()
    else
        popup.bossIcon:Hide()
    end

    popup.titleText:SetText("LOOT DROPS")

    -- Create rows for each item
    local scrollContent = popup.scrollContent
    local yOffset = 0

    for i, itemId in ipairs(lootIds) do
        local row = pool:Acquire()
        row:SetParent(scrollContent)
        row:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, -yOffset)
        row:SetPoint("RIGHT", scrollContent, "RIGHT", 0, 0)
        row.itemId = itemId

        -- Populate item data (may be cached or need async load)
        self:PopulateItemRow(row, itemId)

        row:Show()
        table.insert(self._activeRows, row)
        yOffset = yOffset + LSP.ROW_HEIGHT + LSP.ROW_GAP
    end

    scrollContent:SetHeight(math.max(1, yOffset))
    self:UpdateCountText()

    -- Size popup to fit content (up to max)
    local contentHeight = yOffset
    local totalHeight = LSP.PADDING + LSP.HEADER_HEIGHT + 4 + contentHeight + LSP.FOOTER_HEIGHT + LSP.PADDING
    popup:SetHeight(math.min(totalHeight, LSP.MAX_HEIGHT))

    -- Register for async item info
    if not self._eventFrame then
        self._eventFrame = CreateFrame("Frame")
        self._eventFrame:SetScript("OnEvent", function(_, event, itemId)
            if event == "GET_ITEM_INFO_RECEIVED" then
                LootSelection:OnItemInfoReceived(itemId)
            end
        end)
    end
    self._eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

    -- Show with fade
    popup:Show()
    if HopeAddon.Effects then
        popup:SetAlpha(0)
        HopeAddon.Effects:FadeIn(popup, 0.2)
    end

    -- Auto-dismiss timer
    self:StartAutoDismiss()

    -- Wire up checkbox count updates
    for _, row in ipairs(self._activeRows) do
        row.checkbox:SetScript("OnClick", function()
            LootSelection:UpdateCountText()
        end)
    end
end

function LootSelection:PopulateItemRow(row, itemId)
    local LSP = GetConstants()
    local itemName, _, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, itemIcon = GetItemInfo(itemId)

    if itemIcon then
        row.icon:SetTexture(itemIcon)
    else
        row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    if itemName then
        -- Color by quality
        local qualityColor = LSP.QUALITY_COLORS[itemQuality or 4]
        if qualityColor then
            row.nameText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
        else
            row.nameText:SetTextColor(1, 1, 1)
        end
        row.nameText:SetText(itemName)

        -- Border color by quality
        if itemQuality then
            local r, g, b = GetItemQualityColor(itemQuality)
            if r then
                row.border:SetVertexColor(r, g, b, 0.8)
            end
        end

        -- Slot/type text
        local slotText = itemEquipLoc and _G[itemEquipLoc] or ""
        local typeInfo = itemSubType or itemType or ""
        if slotText and slotText ~= "" then
            row.typeText:SetText(slotText .. " - " .. typeInfo)
        else
            row.typeText:SetText(typeInfo)
        end
    else
        row.nameText:SetText("Loading... (ID: " .. itemId .. ")")
        row.nameText:SetTextColor(0.5, 0.5, 0.5)
        row.typeText:SetText("")
    end
end

function LootSelection:OnItemInfoReceived(itemId)
    if not self._activeRows then return end
    for _, row in ipairs(self._activeRows) do
        if row.itemId == itemId then
            self:PopulateItemRow(row, itemId)
        end
    end
end

function LootSelection:UpdateCountText()
    local popup = self.popup
    if not popup then return end

    local checked = 0
    for _, row in ipairs(self._activeRows) do
        if row.checkbox:GetChecked() then
            checked = checked + 1
        end
    end
    popup.countText:SetText(checked .. " item" .. (checked ~= 1 and "s" or "") .. " selected")
end

function LootSelection:StartAutoDismiss()
    self:CancelAutoDismiss()
    local LSP = GetConstants()
    if HopeAddon.Timer then
        self._autoDismissTimer = HopeAddon.Timer:After(LSP.AUTO_DISMISS_TIMEOUT, function()
            self._autoDismissTimer = nil
            self:DismissWithoutSaving()
        end)
    end
end

function LootSelection:CancelAutoDismiss()
    if self._autoDismissTimer then
        self._autoDismissTimer:Cancel()
        self._autoDismissTimer = nil
    end
end

function LootSelection:SaveAndHide()
    self:CancelAutoDismiss()

    -- Collect checked item IDs
    local checkedIds = {}
    for _, row in ipairs(self._activeRows) do
        if row.checkbox:GetChecked() and row.itemId then
            table.insert(checkedIds, row.itemId)
        end
    end

    -- Save to combat records
    if #checkedIds > 0 and self._raidKey and self._bossId then
        if HopeAddon.CombatRecords then
            HopeAddon.CombatRecords:RecordDroppedLoot(self._raidKey, self._bossId, checkedIds)
        end
    end

    self:HidePopup()
end

function LootSelection:DismissWithoutSaving()
    self:CancelAutoDismiss()
    self:HidePopup()
end

function LootSelection:HidePopup()
    local popup = self.popup
    if not popup or not popup:IsShown() then return end

    -- Unregister item info events
    if self._eventFrame then
        self._eventFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    end

    -- Release rows
    if self.itemRowPool then
        for _, row in ipairs(self._activeRows) do
            self.itemRowPool:Release(row)
        end
    end
    wipe(self._activeRows)

    -- Clear context
    self._raidKey = nil
    self._bossId = nil
    self._bossName = nil

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(popup, 0.15, function()
            popup:Hide()
        end)
    else
        popup:Hide()
    end
end
