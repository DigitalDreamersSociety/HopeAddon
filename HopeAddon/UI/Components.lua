--[[
    HopeAddon UI Components
    Reusable UI elements with TBC theming
]]

local Components = {}
HopeAddon.Components = Components

-- Cache asset references for hot paths (60+ usages in this file)
local AssetFonts = HopeAddon.assets.fonts
local AssetTextures = HopeAddon.assets.textures
local Colors = HopeAddon.colors

-- TBC 2.4.3 compatibility: BackdropTemplate handling
-- In TBC Classic: BackdropTemplateMixin is required for SetBackdrop
-- In original TBC (2.4.3): SetBackdrop is native to all frames
-- Use centralized backdrop frame creation from Core.lua
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

-- Export for other modules
Components.CreateBackdropFrame = CreateBackdropFrame

--[[
    APPLY BACKDROP HELPER
    Applies a centralized backdrop from Constants with optional colors

    @param frame - Frame with BackdropTemplate
    @param backdropKey - Key from C.BACKDROPS (e.g., "TOOLTIP", "PARCHMENT_GOLD")
    @param bgColorKey - Optional key from C.BACKDROP_COLORS for background (default: nil = no change)
    @param borderColorKey - Optional key from C.BACKDROP_COLORS for border (default: nil = no change)

    Usage:
        Components:ApplyBackdrop(frame, "TOOLTIP", "DARK_TRANSPARENT", "GREY")
        Components:ApplyBackdrop(frame, "PARCHMENT_GOLD", "PARCHMENT", "GOLD")
]]
function Components:ApplyBackdrop(frame, backdropKey, bgColorKey, borderColorKey)
    local C = HopeAddon.Constants
    local backdrop = C.BACKDROPS[backdropKey]

    if not backdrop then
        HopeAddon:Debug("ApplyBackdrop: Unknown backdrop key:", backdropKey)
        return
    end

    frame:SetBackdrop(backdrop)

    -- Apply background color if specified
    if bgColorKey then
        local bgColor = C.BACKDROP_COLORS[bgColorKey]
        if bgColor then
            frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 1)
        else
            HopeAddon:Debug("ApplyBackdrop: Unknown bg color key:", bgColorKey)
        end
    end

    -- Apply border color if specified
    if borderColorKey then
        local borderColor = C.BACKDROP_COLORS[borderColorKey]
        if borderColor then
            frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
        else
            HopeAddon:Debug("ApplyBackdrop: Unknown border color key:", borderColorKey)
        end
    end
end

--[[
    APPLY BACKDROP WITH RAW COLORS
    Applies a centralized backdrop with raw color values (not from constants)
    Useful when colors are dynamic or computed

    @param frame - Frame with BackdropTemplate
    @param backdropKey - Key from C.BACKDROPS
    @param bgR, bgG, bgB, bgA - Background color components (optional)
    @param borderR, borderG, borderB, borderA - Border color components (optional)
]]
function Components:ApplyBackdropRaw(frame, backdropKey, bgR, bgG, bgB, bgA, borderR, borderG, borderB, borderA)
    local C = HopeAddon.Constants
    local backdrop = C.BACKDROPS[backdropKey]

    if not backdrop then
        HopeAddon:Debug("ApplyBackdropRaw: Unknown backdrop key:", backdropKey)
        return
    end

    frame:SetBackdrop(backdrop)

    if bgR then
        frame:SetBackdropColor(bgR, bgG or 0, bgB or 0, bgA or 1)
    end

    if borderR then
        frame:SetBackdropBorderColor(borderR, borderG or 0, borderB or 0, borderA or 1)
    end
end

-- Standard margin constants for consistent spacing
Components.MARGIN_SMALL = 5
Components.MARGIN_NORMAL = 10
Components.MARGIN_LARGE = 20
Components.SECTION_SPACER = 15       -- Standard spacer between content sections

-- Additional layout constants
Components.PADDING_INTERNAL = 4      -- For progress bar fill insets
Components.INPUT_PADDING = 8         -- For text input editbox
Components.SCROLLBAR_WIDTH = 25      -- Space for scrollbar
Components.ICON_SIZE_STANDARD = 40   -- Standard icon size in cards

-- Component type constants for type-aware height fallbacks (H1 fix)
Components.COMPONENT_TYPE = {
    CARD = "card",
    SECTION_HEADER = "section_header",
    CATEGORY_HEADER = "category_header",
    SPACER = "spacer",
    COLLAPSIBLE = "collapsible",
    DIVIDER = "divider",
}

-- Fallback heights by component type (for frames not yet laid out)
Components.FALLBACK_HEIGHTS = {
    card = 80,            -- Entry cards
    section_header = 30,  -- Section headers
    category_header = 20, -- Category headers
    spacer = 10,          -- Default spacer
    collapsible = 28,     -- Collapsible section headers
    divider = 20,         -- Dividers
    default = 80,         -- Default fallback
}

-- Module-level handlers (no closures, prevent memory leaks)
local function OnParchmentKeyDown(self, key)
    if key == "ESCAPE" then
        self:Hide()
    end
end

local function OnTabEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(self._tooltipTitle, 1, 0.84, 0)
    if self._tooltipText then
        GameTooltip:AddLine(self._tooltipText, 1, 1, 1, true)
    end
    GameTooltip:Show()
end

local function OnTabLeave(self)
    GameTooltip:Hide()
end

--[[
    PARCHMENT FRAME
    Main container with journal-style background
    Uses explicit texture layer for parchment to ensure proper fill
]]
function Components:CreateParchmentFrame(name, parent, width, height)
    local frame = CreateBackdropFrame("Frame", name, parent or UIParent)
    frame:SetSize(width or 400, height or 500)

    -- Use PARCHMENT_TILED which uses UI-DialogBox-Background (tiles properly at any size)
    -- The QuestBG texture is locked to quest log dimensions and can't scale
    self:ApplyBackdrop(frame, "PARCHMENT_TILED", "PARCHMENT", "GOLD")

    -- Make draggable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Close on Escape (use module-level handler to avoid closure)
    frame:SetScript("OnKeyDown", OnParchmentKeyDown)
    frame:SetPropagateKeyboardInput(true)

    return frame
end

--[[
    DARK FRAME
    For dramatic/raid content
]]
function Components:CreateDarkFrame(name, parent, width, height)
    local frame = CreateBackdropFrame("Frame", name, parent or UIParent)
    frame:SetSize(width or 400, height or 500)
    self:ApplyBackdrop(frame, "DARK_DIALOG", "DARK_SOLID", "GREY_LIGHT")

    return frame
end

--[[
    TITLE BAR
    Decorative title for frames
]]
function Components:CreateTitleBar(parent, titleText, colorName)
    colorName = colorName or "GOLD_BRIGHT"

    local titleBar = CreateFrame("Frame", nil, parent)
    titleBar:SetHeight(40)
    titleBar:SetPoint("TOPLEFT", parent, "TOPLEFT", Components.MARGIN_LARGE, -15)
    titleBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Components.MARGIN_LARGE, -15)

    -- Title text
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    title:SetFont(AssetFonts.TITLE, 22)
    title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    title:SetText(HopeAddon:ColorText(titleText, colorName))
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 0.8)

    -- Decorative line under title
    local line = titleBar:CreateTexture(nil, "ARTWORK")
    line:SetTexture(AssetTextures.DIVIDER)
    line:SetHeight(2)
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -20, -5)
    line:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 20, -5)
    line:SetVertexColor(HopeAddon:GetColor(colorName))

    titleBar.title = title
    titleBar.line = line

    return titleBar
end

--[[
    CLOSE BUTTON
]]
function Components:CreateCloseButton(parent)
    local closeBtn = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Components.MARGIN_SMALL, -Components.MARGIN_SMALL)
    closeBtn:SetScript("OnClick", function()
        parent:Hide()
        HopeAddon.Sounds:PlayJournalClose()
    end)

    return closeBtn
end

--[[
    PROGRESS BAR
    Animated progress bar with glow
]]
function Components:CreateProgressBar(parent, width, height, colorName)
    width = width or 200
    height = height or 20
    colorName = colorName or "GOLD_BRIGHT"
    local color = HopeAddon:GetSafeColor(colorName)

    -- Container
    local container = CreateBackdropFrame("Frame", nil, parent)
    container:SetSize(width, height)
    self:ApplyBackdrop(container, "TOOLTIP", "DARK_SOLID", "GREY_DARK")

    -- Fill bar
    local fill = container:CreateTexture(nil, "ARTWORK")
    fill:SetTexture(AssetTextures.STATUS_BAR)
    fill:SetPoint("TOPLEFT", container, "TOPLEFT", Components.PADDING_INTERNAL, -Components.PADDING_INTERNAL)
    fill:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", Components.PADDING_INTERNAL, Components.PADDING_INTERNAL)
    fill:SetWidth(1) -- Start empty
    fill:SetVertexColor(color.r, color.g, color.b, 1)

    -- Glow overlay on fill
    local glow = container:CreateTexture(nil, "OVERLAY")
    glow:SetTexture(AssetTextures.HIGHLIGHT)
    glow:SetBlendMode("ADD")
    glow:SetAllPoints(fill)
    glow:SetVertexColor(1, 1, 1, 0.3)

    -- Percentage text
    local text = container:CreateFontString(nil, "OVERLAY")
    text:SetFont(AssetFonts.BODY, 12)
    text:SetPoint("CENTER", container, "CENTER", 0, 0)
    text:SetTextColor(1, 1, 1, 1)
    text:SetShadowOffset(1, -1)
    text:SetText("0%")

    -- Methods
    container.fill = fill
    container.glow = glow
    container.text = text
    container.maxWidth = width - 2 * Components.PADDING_INTERNAL

    function container:SetProgress(percent)
        percent = math.max(0, math.min(100, percent))
        local fillWidth = (percent / 100) * self.maxWidth
        self.fill:SetWidth(math.max(1, fillWidth))
        self.text:SetText(math.floor(percent) .. "%")
    end

    function container:AnimateToProgress(targetPercent, duration)
        duration = duration or 0.5
        local startPercent = tonumber(self.text:GetText():match("%d+")) or 0
        local elapsed = 0

        local ticker
        ticker = HopeAddon.Timer:NewTicker(0.02, function()
            elapsed = elapsed + 0.02
            local progress = math.min(elapsed / duration, 1)
            local currentPercent = startPercent + (targetPercent - startPercent) * progress
            self:SetProgress(currentPercent)

            if progress >= 1 then
                ticker:Cancel()

                -- Celebration at 100% completion
                if targetPercent >= 100 and HopeAddon.Effects then
                    HopeAddon.Effects:ProgressSparkles(self, 1.5)
                    -- Gold border flash
                    self:SetBackdropBorderColor(Colors.GOLD_BRIGHT.r, Colors.GOLD_BRIGHT.g, Colors.GOLD_BRIGHT.b, 1)
                end
            end
        end)
    end

    function container:SetColor(newColorName)
        local newColor = HopeAddon.colors[newColorName]
        if newColor then
            self.fill:SetVertexColor(newColor.r, newColor.g, newColor.b, 1)
        end
    end

    return container
end

--[[
    TAB BUTTON
]]
function Components:CreateTabButton(parent, text, width, height, tooltip, customColor)
    width = width or 100
    height = height or 30

    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(width, height)

    -- Store custom color for selected state (color name string, e.g., "ARCANE_PURPLE")
    tab.customColor = customColor

    -- Background
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(AssetTextures.DIALOG_BG)
    bg:SetAllPoints(tab)
    bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    tab.bg = bg

    -- Highlight (use custom color if provided)
    local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(AssetTextures.HIGHLIGHT)
    highlight:SetAllPoints(tab)
    if customColor then
        local hColor = HopeAddon:GetSafeColor(customColor)
        highlight:SetVertexColor(hColor.r, hColor.g, hColor.b, 0.3)
    else
        highlight:SetVertexColor(1, 0.84, 0, 0.3)
    end

    -- Text (using 11pt for better fit with many tabs)
    local label = tab:CreateFontString(nil, "OVERLAY")
    label:SetFont(AssetFonts.HEADER, 11)
    label:SetPoint("CENTER", tab, "CENTER", 0, 0)
    label:SetText(text)
    label:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    tab.label = label

    -- Selected state indicator
    local selected = tab:CreateTexture(nil, "OVERLAY")
    selected:SetTexture(AssetTextures.SOLID)
    selected:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 2, 0)
    selected:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -2, 0)
    selected:SetHeight(3)
    selected:SetVertexColor(HopeAddon:GetColor("GOLD_BRIGHT"))
    selected:Hide()
    tab.selectedIndicator = selected

    -- Disabled overlay
    local disabled = tab:CreateTexture(nil, "OVERLAY", nil, 1)
    disabled:SetTexture(AssetTextures.SOLID)
    disabled:SetAllPoints(tab)
    disabled:SetVertexColor(0.3, 0.3, 0.3, 0.6)
    disabled:Hide()
    tab.disabledOverlay = disabled

    -- Tooltip support (use module-level handlers to avoid closure memory leaks)
    if tooltip then
        tab._tooltipTitle = text
        tab._tooltipText = tooltip
        tab:SetScript("OnEnter", OnTabEnter)
        tab:SetScript("OnLeave", OnTabLeave)
    end

    -- State methods
    function tab:SetSelected(isSelected)
        if isSelected then
            -- Use custom color if provided, otherwise default gold
            if self.customColor then
                local color = HopeAddon:GetSafeColor(self.customColor)
                self.bg:SetVertexColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
                self.label:SetTextColor(color.r, color.g, color.b, 1)
                self.selectedIndicator:SetVertexColor(color.r, color.g, color.b, 1)
            else
                self.bg:SetVertexColor(0.3, 0.25, 0.1, 0.9)
                self.label:SetTextColor(1, 0.84, 0, 1)
                self.selectedIndicator:SetVertexColor(HopeAddon:GetColor("GOLD_BRIGHT"))
            end
            self.selectedIndicator:Show()
        else
            self.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
            self.label:SetTextColor(0.8, 0.8, 0.8, 1)
            self.selectedIndicator:Hide()
        end
    end

    -- Disabled state method
    function tab:SetButtonEnabled(enabled)
        if enabled then
            self:EnableMouse(true)
            self.disabledOverlay:Hide()
            self.label:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
        else
            self:EnableMouse(false)
            self.disabledOverlay:Show()
            self.label:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
        end
    end

    -- Click sound
    tab:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
    end)

    -- Pressed state (visual feedback on mouse down)
    tab:SetScript("OnMouseDown", function(self)
        if self:IsMouseEnabled() then
            self.bg:SetVertexColor(0.15, 0.15, 0.15, 0.9)
        end
    end)
    tab:SetScript("OnMouseUp", function(self)
        if self:IsMouseEnabled() then
            self.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        end
    end)

    return tab
end

--[[
    NAV BUTTON
    Small navigation/jump button with color theming
    Used for tier navigation, section jumps, etc.
]]
function Components:CreateNavButton(parent, text, width, colorName, onClick)
    width = width or 60
    local height = 22
    colorName = colorName or "GOLD_BRIGHT"
    local color = HopeAddon:GetSafeColor(colorName)

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)

    -- Background with tinted color
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(AssetTextures.DIALOG_BG)
    bg:SetAllPoints(btn)
    bg:SetVertexColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
    btn.bg = bg

    -- Text
    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont(AssetFonts.HEADER, 11)
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    label:SetText(text)
    label:SetTextColor(color.r, color.g, color.b, 1)
    btn.label = label

    -- Highlight
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(AssetTextures.HIGHLIGHT)
    highlight:SetAllPoints(btn)
    highlight:SetVertexColor(color.r, color.g, color.b, 0.4)

    -- Disabled overlay
    local disabled = btn:CreateTexture(nil, "OVERLAY", nil, 1)
    disabled:SetTexture(AssetTextures.SOLID)
    disabled:SetAllPoints(btn)
    disabled:SetVertexColor(0.3, 0.3, 0.3, 0.6)
    disabled:Hide()
    btn.disabledOverlay = disabled

    -- Click handler with sound
    btn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        if onClick then
            onClick()
        end
    end)

    -- Pressed state (visual feedback on mouse down)
    btn:SetScript("OnMouseDown", function(self)
        if self:IsMouseEnabled() then
            self.bg:SetVertexColor(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.95)
        end
    end)
    btn:SetScript("OnMouseUp", function(self)
        if self:IsMouseEnabled() then
            self.bg:SetVertexColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
        end
    end)

    -- Disabled state method
    function btn:SetButtonEnabled(enabled)
        if enabled then
            self:EnableMouse(true)
            self.disabledOverlay:Hide()
            self.label:SetTextColor(self.color.r, self.color.g, self.color.b, 1)
        else
            self:EnableMouse(false)
            self.disabledOverlay:Show()
            self.label:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
        end
    end

    -- Store color for external access
    btn.colorName = colorName
    btn.color = color

    return btn
end

--[[
    ICON BUTTON
    Button with icon and optional text
]]
function Components:CreateIconButton(parent, iconPath, size, tooltip)
    size = size or 32

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(size, size)

    -- Icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconPath)
    icon:SetAllPoints(btn)
    btn.icon = icon

    -- Border
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture(AssetTextures.TOOLTIP_BORDER)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
    btn.border = border

    -- Highlight
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(AssetTextures.HIGHLIGHT)
    highlight:SetAllPoints(btn)
    highlight:SetVertexColor(1, 1, 1, 0.3)

    -- Disabled overlay
    local disabled = btn:CreateTexture(nil, "OVERLAY", nil, 1)
    disabled:SetTexture(AssetTextures.SOLID)
    disabled:SetAllPoints(btn)
    disabled:SetVertexColor(0.3, 0.3, 0.3, 0.6)
    disabled:Hide()
    btn.disabledOverlay = disabled

    -- Tooltip
    if tooltip then
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    -- Pressed state (visual feedback on mouse down)
    btn:SetScript("OnMouseDown", function(self)
        if self:IsMouseEnabled() then
            self.icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        end
    end)
    btn:SetScript("OnMouseUp", function(self)
        if self:IsMouseEnabled() then
            self.icon:SetVertexColor(1, 1, 1, 1)
        end
    end)

    -- Disabled state method
    function btn:SetButtonEnabled(enabled)
        if enabled then
            self:EnableMouse(true)
            self.disabledOverlay:Hide()
            self.icon:SetDesaturated(false)
            self.icon:SetAlpha(1)
        else
            self:EnableMouse(false)
            self.disabledOverlay:Show()
            self.icon:SetDesaturated(true)
            self.icon:SetAlpha(0.5)
        end
    end

    return btn
end

--[[
    SCROLL FRAME
    Scrollable content area
]]
function Components:CreateScrollFrame(parent, width, height)
    width = width or 350
    height = height or 400

    -- Container
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, height)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", Components.MARGIN_SMALL, -Components.MARGIN_SMALL)
    scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -Components.SCROLLBAR_WIDTH, Components.MARGIN_SMALL)

    -- Content frame (child of scroll)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetHeight(1) -- Will grow as content added
    scrollFrame:SetScrollChild(content)

    -- Update content width when scroll frame is resized (fixes width calculation timing issue)
    -- This ensures content width is set correctly even when SetAllPoints is called after creation
    scrollFrame:SetScript("OnSizeChanged", function(self, newWidth, newHeight)
        if newWidth and newWidth > 0 then
            content:SetWidth(newWidth)
        end
    end)

    -- Set initial width (may be 0 if not laid out yet, OnSizeChanged will fix it)
    local initialWidth = scrollFrame:GetWidth()
    if initialWidth and initialWidth > 0 then
        content:SetWidth(initialWidth)
    else
        content:SetWidth(width - Components.SCROLLBAR_WIDTH - 2 * Components.MARGIN_SMALL)
    end

    container.scrollFrame = scrollFrame
    container.content = content

    -- Method to add entry - track cumulative height incrementally to avoid O(n²)
    container.entries = {}
    container.currentYOffset = 0  -- Track cumulative height

    function container:AddEntry(entryFrame)
        entryFrame:SetParent(self.content)
        entryFrame:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -self.currentYOffset)
        entryFrame:SetPoint("RIGHT", self.content, "RIGHT", 0, 0)
        entryFrame:Show()  -- Ensure pooled frames are visible

        table.insert(self.entries, entryFrame)

        -- Get entry height - use component-type-aware fallback if not laid out yet (H1 fix)
        local entryHeight = entryFrame:GetHeight()
        if entryHeight < 1 then
            -- Use stored component type for appropriate fallback, or check _spacerHeight for spacers
            local componentType = entryFrame._componentType
            if componentType and Components.FALLBACK_HEIGHTS[componentType] then
                entryHeight = Components.FALLBACK_HEIGHTS[componentType]
            elseif entryFrame._spacerHeight then
                entryHeight = entryFrame._spacerHeight
            else
                entryHeight = Components.FALLBACK_HEIGHTS.default  -- Default card height fallback
            end
        end

        -- Update cumulative offset and content height
        self.currentYOffset = self.currentYOffset + entryHeight + Components.MARGIN_SMALL
        self.content:SetHeight(self.currentYOffset)
    end

    function container:ClearEntries(pool)
        for _, entry in ipairs(self.entries) do
            if pool and entry._pooled then
                pool:Release(entry)
            else
                entry:Hide()
                entry:SetParent(nil)
            end
        end
        table.wipe(self.entries)  -- Reuse table memory instead of creating new
        self.currentYOffset = 0  -- Reset cumulative height
        self.content:SetHeight(1)
    end

    -- Recalculate positions after collapsible section toggle
    function container:RecalculatePositions()
        local yOffset = 0
        for _, entry in ipairs(self.entries) do
            entry:ClearAllPoints()
            entry:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("RIGHT", self.content, "RIGHT", 0, 0)

            -- Use same fallback logic as AddEntry for consistency (M1 fix)
            local entryHeight = entry:GetHeight()
            if entryHeight < 1 then
                local componentType = entry._componentType
                if componentType and Components.FALLBACK_HEIGHTS[componentType] then
                    entryHeight = Components.FALLBACK_HEIGHTS[componentType]
                elseif entry._spacerHeight then
                    entryHeight = entry._spacerHeight
                else
                    entryHeight = Components.FALLBACK_HEIGHTS.default
                end
            end

            yOffset = yOffset + entryHeight + Components.MARGIN_SMALL
        end
        -- M1 fix: Match AddEntry height calculation (no extra padding)
        self.content:SetHeight(yOffset)
    end

    return container
end

--[[
    LAYOUT BUILDER
    Automates vertical form layout by tracking yOffset automatically

    Usage:
        local layout = Components:CreateLayoutBuilder(content, { startY = -20, startX = 10, spacing = 10 })
        layout:AddRow(titleText, 0)        -- Custom spacing for this row
        layout:AddSpacer(10)               -- 10px vertical space
        layout:AddRow(backstoryBox, 5)    -- 5px spacing after
        layout:AddRow(personalityBox)     -- Uses default spacing

    @param parent Frame - Parent frame to anchor elements to
    @param config table - { startY, startX, spacing }
    @return LayoutBuilder
]]
function Components:CreateLayoutBuilder(parent, config)
    config = config or {}

    local builder = {
        parent = parent,
        lastFrame = nil,
        yOffset = config.startY or -20,
        xOffset = config.startX or 10,
        spacing = config.spacing or 10,
    }

    --[[
        Add a frame to the layout
        @param frame Frame - Frame to add
        @param spacing number|nil - Override spacing for this row (nil = use default)
        @return Frame - The added frame
    ]]
    function builder:AddRow(frame, spacing)
        local actualSpacing = spacing or self.spacing

        if not self.lastFrame then
            -- First element: anchor to parent top-left
            frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self.xOffset, self.yOffset)
        else
            -- Subsequent elements: anchor below last frame
            frame:SetPoint("TOPLEFT", self.lastFrame, "BOTTOMLEFT", 0, -actualSpacing)
        end

        self.lastFrame = frame
        return frame
    end

    --[[
        Add vertical spacing (empty space)
        @param height number - Height of spacer in pixels
    ]]
    function builder:AddSpacer(height)
        local spacer = CreateFrame("Frame", nil, self.parent)
        spacer:SetSize(1, height or 10)
        self:AddRow(spacer, 0)  -- No additional spacing after spacer
    end

    --[[
        Reset layout to start position
        Useful for creating multiple columns
    ]]
    function builder:Reset()
        self.lastFrame = nil
        self.yOffset = config.startY or -20
    end

    return builder
end

--[[
    JOURNAL ENTRY CARD
    Individual entry display with text overflow protection and click support
]]
function Components:CreateEntryCard(parent, entryData)
    local card = CreateBackdropFrame("Frame", nil, parent)
    card:SetHeight(80)
    card._componentType = Components.COMPONENT_TYPE.CARD  -- H1 fix
    self:ApplyBackdrop(card, "TOOLTIP", "DARK_TRANSPARENT", "GREY")

    -- Store original border color for hover restoration
    card.defaultBorderColor = HopeAddon.Constants.BACKDROP_COLORS.GREY

    -- Icon
    local iconOffset = Components.MARGIN_NORMAL
    if entryData.icon then
        local icon = card:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(entryData.icon)
        icon:SetSize(Components.ICON_SIZE_STANDARD, Components.ICON_SIZE_STANDARD)
        icon:SetPoint("LEFT", card, "LEFT", Components.MARGIN_NORMAL, 0)
        card.icon = icon
        iconOffset = Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL
    end

    -- Title
    local title = card:CreateFontString(nil, "OVERLAY")
    title:SetFont(AssetFonts.HEADER, 14)
    title:SetPoint("TOPLEFT", card, "TOPLEFT", iconOffset, -Components.MARGIN_NORMAL)
    title:SetPoint("RIGHT", card, "RIGHT", -Components.MARGIN_NORMAL, 0)
    title:SetText(HopeAddon:ColorText(entryData.title or "Entry", "GOLD_BRIGHT"))
    card.title = title

    -- Description - limit to prevent overflow into timestamp area
    local desc = card:CreateFontString(nil, "OVERLAY")
    desc:SetFont(AssetFonts.BODY, 11)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -Components.MARGIN_SMALL)
    desc:SetPoint("RIGHT", card, "RIGHT", -Components.MARGIN_NORMAL, 0)
    desc:SetPoint("BOTTOM", card, "BOTTOM", 0, 22) -- Leave room for timestamp
    desc:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")
    desc:SetWordWrap(true)
    -- Truncate long descriptions to avoid overflow
    local descText = entryData.description or ""
    local maxDescLength = 120
    local fullDescription = descText
    if #descText > maxDescLength then
        descText = string.sub(descText, 1, maxDescLength - 3) .. "..."
    end
    desc:SetText(descText)
    card.desc = desc
    card.fullDescription = fullDescription

    -- Timestamp
    local timestamp = card:CreateFontString(nil, "OVERLAY")
    timestamp:SetFont(AssetFonts.SMALL, 10)
    timestamp:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -Components.MARGIN_NORMAL, 8)
    timestamp:SetText(entryData.timestamp or "")
    timestamp:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
    card.timestamp = timestamp

    -- Store entry data for click handlers
    card.entryData = entryData

    -- Hover effect with tooltip for truncated text
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(HopeAddon:GetColor("GOLD_BRIGHT"))
        -- Show tooltip with full description if truncated
        if self.fullDescription and #self.fullDescription > maxDescLength then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(entryData.title or "Entry", 1, 0.84, 0)
            GameTooltip:AddLine(self.fullDescription, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    card:SetScript("OnLeave", function(self)
        local c = self.defaultBorderColor
        self:SetBackdropBorderColor(c[1], c[2], c[3], c[4])
        GameTooltip:Hide()
    end)

    -- Click handler support - callers can set card.OnCardClick
    card:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.OnCardClick then
            self.OnCardClick(self, self.entryData)
        end
    end)

    -- Method to update border color and store it for hover restoration
    function card:SetDefaultBorderColor(r, g, b, a)
        self.defaultBorderColor = { r, g, b, a or 1 }
        self:SetBackdropBorderColor(r, g, b, a or 1)
    end

    return card
end

--[[
    DIVIDER LINE
    Horizontal separator with optional text
]]
function Components:CreateDivider(parent, text)
    local divider = CreateFrame("Frame", nil, parent)
    divider:SetHeight(20)
    divider._componentType = Components.COMPONENT_TYPE.DIVIDER  -- H1 fix

    local line = divider:CreateTexture(nil, "ARTWORK")
    line:SetTexture(AssetTextures.DIVIDER)
    line:SetHeight(2)

    if text then
        local label = divider:CreateFontString(nil, "OVERLAY")
        label:SetFont(AssetFonts.SMALL, 10)
        label:SetPoint("CENTER", divider, "CENTER", 0, 0)
        label:SetText(HopeAddon:ColorText(text, "GREY"))
        divider.label = label

        line:SetPoint("LEFT", divider, "LEFT", 0, 0)
        line:SetPoint("RIGHT", label, "LEFT", -Components.MARGIN_NORMAL, 0)

        local line2 = divider:CreateTexture(nil, "ARTWORK")
        line2:SetTexture(AssetTextures.DIVIDER)
        line2:SetHeight(2)
        line2:SetPoint("LEFT", label, "RIGHT", Components.MARGIN_NORMAL, 0)
        line2:SetPoint("RIGHT", divider, "RIGHT", 0, 0)
        divider.line2 = line2
    else
        line:SetPoint("LEFT", divider, "LEFT", 0, 0)
        line:SetPoint("RIGHT", divider, "RIGHT", 0, 0)
    end

    divider.line = line

    return divider
end

--[[
    CHECKBOX
]]
function Components:CreateCheckbox(parent, label, initialValue)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)

    local text = checkbox:CreateFontString(nil, "OVERLAY")
    text:SetFont(AssetFonts.BODY, 12)
    text:SetPoint("LEFT", checkbox, "RIGHT", Components.MARGIN_SMALL, 0)
    text:SetText(label or "")
    text:SetTextColor(HopeAddon:GetTextColor("BRIGHT"))
    checkbox.label = text

    if initialValue then
        checkbox:SetChecked(true)
    end

    checkbox:SetScript("OnClick", function(self)
        HopeAddon.Sounds:PlayClick()
    end)

    return checkbox
end

--[[
    TEXT INPUT
]]
function Components:CreateTextInput(parent, width, height, placeholder)
    width = width or 200
    height = height or 30

    local container = CreateBackdropFrame("Frame", nil, parent)
    container:SetSize(width, height)
    self:ApplyBackdrop(container, "TOOLTIP", "INPUT_BG", "GREY_DARK")

    local editBox = CreateFrame("EditBox", nil, container)
    editBox:SetPoint("TOPLEFT", container, "TOPLEFT", Components.INPUT_PADDING, -Components.MARGIN_SMALL)
    editBox:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -Components.INPUT_PADDING, Components.MARGIN_SMALL)
    editBox:SetFont(AssetFonts.BODY, 12)
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetAutoFocus(false)
    editBox:SetMultiLine(false)

    if placeholder then
        editBox:SetText(placeholder)
        editBox:SetTextColor(HopeAddon:GetTextColor("DISABLED"))

        editBox:SetScript("OnEditFocusGained", function(self)
            if self:GetText() == placeholder then
                self:SetText("")
                self:SetTextColor(1, 1, 1, 1)
            end
        end)

        editBox:SetScript("OnEditFocusLost", function(self)
            if self:GetText() == "" then
                self:SetText(placeholder)
                self:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
            end
        end)
    end

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    container.editBox = editBox

    return container
end

--[[
    LABELED EDIT BOX
    EditBox with label above it - common form pattern

    @param parent Frame
    @param labelText string - Label text
    @param placeholder string - Placeholder text
    @param maxLetters number - Max character limit
    @return Frame - Container with .label and .editBox properties
]]
function Components:CreateLabeledEditBox(parent, labelText, placeholder, maxLetters)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(60)  -- Label + spacing + editBox

    -- Label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(labelText or "")
    label:SetTextColor(Colors.GOLD_BRIGHT.r, Colors.GOLD_BRIGHT.g, Colors.GOLD_BRIGHT.b)

    -- EditBox (using existing CreateTextInput)
    local editBox = self:CreateTextInput(container, 200, 30, placeholder)
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    editBox:SetPoint("RIGHT", container, "RIGHT", 0, 0)

    if maxLetters then
        editBox.editBox:SetMaxLetters(maxLetters)
    end

    container.label = label
    container.editBox = editBox

    return container
end

--[[
    LABELED DROPDOWN
    Dropdown with label above it - common form pattern

    @param parent Frame
    @param labelText string - Label text
    @param options table - Array of option strings
    @param defaultIndex number - Default selected index (1-based)
    @return Frame - Container with .label and .dropdown properties
]]
function Components:CreateLabeledDropdown(parent, labelText, options, defaultIndex)
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(60)  -- Label + spacing + dropdown

    -- Label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(labelText or "")
    label:SetTextColor(Colors.GOLD_BRIGHT.r, Colors.GOLD_BRIGHT.g, Colors.GOLD_BRIGHT.b)

    -- Dropdown button
    local dropdown = CreateFrame("Button", nil, container)
    dropdown:SetSize(200, 30)
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    dropdown:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    self:ApplyBackdrop(dropdown, "TOOLTIP", "DARK_TRANSPARENT", "GREY")

    -- Dropdown text
    local dropdownText = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownText:SetPoint("LEFT", dropdown, "LEFT", 10, 0)
    dropdownText:SetText(options and options[defaultIndex or 1] or "Select...")
    dropdownText:SetTextColor(0.9, 0.9, 0.9)

    -- Dropdown arrow icon
    local arrow = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("RIGHT", dropdown, "RIGHT", -10, 0)
    arrow:SetText("▼")
    arrow:SetTextColor(0.6, 0.6, 0.6)

    dropdown.text = dropdownText
    dropdown.options = options or {}
    dropdown.selectedIndex = defaultIndex or 1

    -- Click handler would open a menu (not implementing full dropdown here for brevity)
    dropdown:SetScript("OnClick", function(self)
        HopeAddon.Sounds:PlayClick()
        HopeAddon:Print("Dropdown clicked - full menu implementation needed")
    end)

    -- Hover effects with smooth color transition
    dropdown:SetScript("OnEnter", function(self)
        if HopeAddon.Animations then
            HopeAddon.Animations:ColorTransition(self, Colors.GOLD_BRIGHT, 0.15)
        else
            self:SetBackdropBorderColor(Colors.GOLD_BRIGHT.r, Colors.GOLD_BRIGHT.g, Colors.GOLD_BRIGHT.b, 1)
        end
    end)
    dropdown:SetScript("OnLeave", function(self)
        if HopeAddon.Animations then
            HopeAddon.Animations:ColorTransition(self, Colors.GREY, 0.15)
        else
            self:SetBackdropBorderColor(Colors.GREY.r, Colors.GREY.g, Colors.GREY.b, 1)
        end
    end)

    container.label = label
    container.dropdown = dropdown

    return container
end

--[[
    CHECKBOX WITH LABEL
    Checkbox with label on the right - improved version of CreateCheckbox

    @param parent Frame
    @param labelText string - Label text
    @param defaultChecked boolean - Initial checked state
    @return CheckButton - Checkbox with .label property
]]
function Components:CreateCheckboxWithLabel(parent, labelText, defaultChecked)
    return self:CreateCheckbox(parent, labelText, defaultChecked)
end

--[[
    STYLED BUTTON
    General-purpose button with consistent styling, hover effects, and sound

    @param parent Frame
    @param text string - Button label
    @param width number - Button width (default 100)
    @param height number - Button height (default 22)
    @param onClick function - Click handler
    @param options table - Optional { colorName, disabled }
    @return Button
]]
function Components:CreateStyledButton(parent, text, width, height, onClick, options)
    options = options or {}
    width = width or 100
    height = height or 22
    local colorName = options.colorName or "ARCANE_PURPLE"

    local button = CreateBackdropFrame("Button", nil, parent)
    button:SetSize(width, height)
    self:ApplyBackdrop(button, "TOOLTIP", "PURPLE_TINT", colorName)

    -- Store default border color for hover restoration
    local defaultBorderColor = HopeAddon.colors[colorName]
    button.defaultBorderColor = defaultBorderColor

    -- Text
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER")
    button.text:SetText(text or "Button")
    button.text:SetTextColor(0.9, 0.9, 0.9)

    -- Hover effects with smooth color transition
    button:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then return end

        -- Smooth border color transition (gold highlight)
        if HopeAddon.Animations then
            HopeAddon.Animations:ColorTransition(self, Colors.GOLD_BRIGHT, 0.15)
        else
            self:SetBackdropBorderColor(Colors.GOLD_BRIGHT.r, Colors.GOLD_BRIGHT.g, Colors.GOLD_BRIGHT.b, 1)
        end

        -- Play hover sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayHover()
        end
    end)

    button:SetScript("OnLeave", function(self)
        -- Restore original border color with smooth transition
        if self.defaultBorderColor then
            if HopeAddon.Animations then
                HopeAddon.Animations:ColorTransition(self, self.defaultBorderColor, 0.15)
            else
                self:SetBackdropBorderColor(
                    self.defaultBorderColor.r,
                    self.defaultBorderColor.g,
                    self.defaultBorderColor.b,
                    1
                )
            end
        end
    end)

    -- Click handler
    if onClick then
        button:SetScript("OnClick", function(self)
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            onClick(self)
        end)
    end

    -- Disabled state
    if options.disabled then
        button:Disable()
        button.text:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Helper to update text
    function button:SetButtonText(newText)
        self.text:SetText(newText)
    end

    -- Helper to enable/disable
    function button:SetButtonEnabled(enabled)
        if enabled then
            self:Enable()
            self.text:SetTextColor(0.9, 0.9, 0.9)
        else
            self:Disable()
            self.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end

    return button
end

--[[
    COLLAPSIBLE SECTION
    Expandable/collapsible section header for organizing content
]]
function Components:CreateCollapsibleSection(parent, title, colorName, startExpanded)
    colorName = colorName or "GOLD_BRIGHT"
    startExpanded = startExpanded ~= false -- Default to expanded

    -- Main container
    local section = CreateFrame("Frame", nil, parent)
    section:SetHeight(28)
    section._componentType = Components.COMPONENT_TYPE.COLLAPSIBLE  -- H1 fix

    -- Header bar (clickable)
    local header = CreateFrame("Button", nil, section)
    header:SetHeight(26)
    header:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)

    -- Background for header
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetTexture(AssetTextures.DIALOG_BG)
    headerBg:SetAllPoints(header)
    headerBg:SetVertexColor(0.15, 0.15, 0.15, 0.9)

    -- Expand/collapse indicator
    local indicator = header:CreateFontString(nil, "OVERLAY")
    indicator:SetFont(AssetFonts.HEADER, 14)
    indicator:SetPoint("LEFT", header, "LEFT", Components.INPUT_PADDING, 0)
    indicator:SetText(startExpanded and "[-]" or "[+]")
    indicator:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
    section.indicator = indicator

    -- Title
    local titleText = header:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(AssetFonts.HEADER, 13)
    titleText:SetPoint("LEFT", indicator, "RIGHT", Components.INPUT_PADDING, 0)
    titleText:SetText(HopeAddon:ColorText(title, colorName))
    section.titleText = titleText

    -- Highlight on hover
    local highlight = header:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(AssetTextures.HIGHLIGHT)
    highlight:SetAllPoints(header)
    highlight:SetVertexColor(1, 0.84, 0, 0.2)

    -- Disabled overlay
    local disabled = header:CreateTexture(nil, "OVERLAY", nil, 1)
    disabled:SetTexture(AssetTextures.SOLID)
    disabled:SetAllPoints(header)
    disabled:SetVertexColor(0.3, 0.3, 0.3, 0.6)
    disabled:Hide()
    section.disabledOverlay = disabled
    section.headerBg = headerBg

    -- Content container (holds child entries)
    local contentContainer = CreateFrame("Frame", nil, section)
    contentContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", Components.MARGIN_NORMAL, -Components.MARGIN_SMALL)
    contentContainer:SetPoint("RIGHT", section, "RIGHT", 0, 0)
    contentContainer:SetHeight(1)
    section.contentContainer = contentContainer

    -- Track expansion state and child entries
    section.isExpanded = startExpanded
    section.childEntries = {}
    section.contentHeight = 0

    -- Method to add child entry
    function section:AddChild(childFrame)
        childFrame:SetParent(self.contentContainer)
        childFrame:SetPoint("TOPLEFT", self.contentContainer, "TOPLEFT", 0, -self.contentHeight)
        childFrame:SetPoint("RIGHT", self.contentContainer, "RIGHT", 0, 0)

        table.insert(self.childEntries, childFrame)
        self.contentHeight = self.contentHeight + childFrame:GetHeight() + Components.MARGIN_SMALL

        -- Update container height
        self.contentContainer:SetHeight(self.contentHeight)

        -- Update section total height
        self:UpdateHeight()

        -- Show/hide based on expanded state (TBC compatible - no SetShown)
        if self.isExpanded then
            childFrame:Show()
        else
            childFrame:Hide()
        end
    end

    -- Update total section height
    function section:UpdateHeight()
        if self.isExpanded then
            self:SetHeight(28 + self.contentHeight + Components.MARGIN_SMALL)
            self.contentContainer:Show()
        else
            self:SetHeight(28)
            self.contentContainer:Hide()
        end
    end

    -- Toggle expansion with smooth animation
    function section:Toggle()
        self.isExpanded = not self.isExpanded
        self.indicator:SetText(self.isExpanded and "[-]" or "[+]")

        if self.isExpanded then
            -- Expanding: Show then fade in
            for _, child in ipairs(self.childEntries) do
                child:SetAlpha(0)
                child:Show()
                if HopeAddon.Animations then
                    HopeAddon.Animations:FadeTo(child, 1, 0.2)
                else
                    child:SetAlpha(1)
                end
            end
        else
            -- Collapsing: Fade out then hide
            for _, child in ipairs(self.childEntries) do
                if HopeAddon.Animations then
                    HopeAddon.Animations:FadeTo(child, 0, 0.2, function()
                        child:Hide()
                        child:SetAlpha(1)  -- Reset for next expand
                    end)
                else
                    child:Hide()
                end
            end
        end

        self:UpdateHeight()

        -- Notify parent scroll container to recalculate
        if self.onToggle then
            self.onToggle(self, self.isExpanded)
        end

        HopeAddon.Sounds:PlayClick()
    end

    -- Set expansion state
    function section:SetExpanded(expanded)
        if self.isExpanded ~= expanded then
            self:Toggle()
        end
    end

    -- Get item count text
    function section:SetItemCount(count, total)
        if total then
            self.titleText:SetText(HopeAddon:ColorText(title .. " (" .. count .. "/" .. total .. ")", colorName))
        else
            self.titleText:SetText(HopeAddon:ColorText(title .. " (" .. count .. ")", colorName))
        end
    end

    -- Click handler
    header:SetScript("OnClick", function()
        section:Toggle()
    end)

    -- Pressed state (visual feedback on mouse down)
    header:SetScript("OnMouseDown", function()
        if header:IsMouseEnabled() then
            headerBg:SetVertexColor(0.1, 0.1, 0.1, 0.95)
        end
    end)
    header:SetScript("OnMouseUp", function()
        if header:IsMouseEnabled() then
            headerBg:SetVertexColor(0.15, 0.15, 0.15, 0.9)
        end
    end)

    -- Disabled state method
    function section:SetButtonEnabled(enabled)
        if enabled then
            header:EnableMouse(true)
            self.disabledOverlay:Hide()
            indicator:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
        else
            header:EnableMouse(false)
            self.disabledOverlay:Show()
            indicator:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
        end
    end

    -- Initialize height
    section:UpdateHeight()

    return section
end

--[[
    STANDING VISUAL CONFIGURATION
    Defines visual styling per reputation standing
]]
local STANDING_VISUALS = {
    [1] = { -- Hated
        border = "TOOLTIP",
        showTickMarks = false,
        glowType = nil,
        showCornerFlourishes = false,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "POOR",
        badgeGlow = nil,
    },
    [2] = { -- Hostile
        border = "TOOLTIP",
        showTickMarks = false,
        glowType = nil,
        showCornerFlourishes = false,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "POOR",
        badgeGlow = nil,
    },
    [3] = { -- Unfriendly
        border = "TOOLTIP",
        showTickMarks = false,
        glowType = nil,
        showCornerFlourishes = false,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "COMMON",
        badgeGlow = nil,
    },
    [4] = { -- Neutral
        border = "TOOLTIP",
        showTickMarks = false,
        glowType = nil,
        showCornerFlourishes = false,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "COMMON",
        badgeGlow = nil,
    },
    [5] = { -- Friendly
        border = "TOOLTIP",
        showTickMarks = true,
        glowType = nil,
        showCornerFlourishes = false,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "UNCOMMON",
        badgeGlow = "subtle",  -- intensity 0.3
    },
    [6] = { -- Honored
        border = "GOLD",
        showTickMarks = true,
        glowType = "subtle",
        showCornerFlourishes = true,
        showSparkles = false,
        showCrown = false,
        badgeQuality = "RARE",
        badgeGlow = "rare",    -- intensity 0.5
    },
    [7] = { -- Revered
        border = "GOLD",
        showTickMarks = true,
        glowType = "pulsing",
        showCornerFlourishes = true,
        showSparkles = true,
        showCrown = false,
        badgeQuality = "EPIC",
        badgeGlow = "epic",    -- intensity 0.7, pulsing
    },
    [8] = { -- Exalted
        border = "GOLD_DOUBLE",
        showTickMarks = true,
        glowType = "epic",
        showCornerFlourishes = true,
        showSparkles = true,
        showCrown = true,
        badgeQuality = "LEGENDARY",
        badgeGlow = "legendary", -- intensity 1.0, pulsing
    },
}

-- Standing names for badge display
local STANDING_NAMES = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

--[[
    REPUTATION BAR HELPERS
    Extracted from CreateReputationBar to reduce function size
]]

-- Create a bouncing alpha animation on a texture
-- @param texture Texture - The texture to animate
-- @param fromAlpha number - Starting alpha
-- @param toAlpha number - Ending alpha
-- @param duration number - Animation duration
-- @return AnimationGroup
local function CreateGlowAnimation(texture, fromAlpha, toAlpha, duration)
    local ag = texture:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(fromAlpha)
    pulse:SetToAlpha(toAlpha)
    pulse:SetDuration(duration)
    pulse:SetSmoothing("IN_OUT")

    return ag
end

-- Create flourish animations for corner decorations
-- @param flourishes table - Array of flourish textures
-- @param effectsList table - Effects tracking table
local function CreateFlourishAnimations(flourishes, effectsList)
    for _, flourish in ipairs(flourishes) do
        local fag = flourish:CreateAnimationGroup()
        fag:SetLooping("BOUNCE")

        local fpulse = fag:CreateAnimation("Alpha")
        fpulse:SetFromAlpha(0.5)
        fpulse:SetToAlpha(1.0)
        fpulse:SetDuration(0.6)
        fpulse:SetSmoothing("IN_OUT")

        local fscale = fag:CreateAnimation("Scale")
        fscale:SetFromScale(0.9, 0.9)
        fscale:SetToScale(1.1, 1.1)
        fscale:SetDuration(0.6)
        fscale:SetSmoothing("IN_OUT")

        fag:Play()
        table.insert(effectsList, { animGroup = fag })
    end
end

-- Clean up sparkle data (textures and timers)
-- @param sparkles table|nil - Array of sparkle data
local function CleanupRepSparkles(sparkles)
    if not sparkles then return end

    for _, sparkData in ipairs(sparkles) do
        if sparkData.startupTimer and sparkData.startupTimer.Cancel then
            sparkData.startupTimer:Cancel()
        end
        if sparkData.animGroup then
            sparkData.animGroup:Stop()
        end
        if sparkData.texture then
            sparkData.texture:Hide()
            sparkData.texture:SetParent(nil)
        end
    end
end

-- Clean up effect data (animation groups, tickers, textures)
-- @param effects table - Array of effect data
local function CleanupRepEffects(effects)
    for _, effect in ipairs(effects) do
        if effect.startupTimer and effect.startupTimer.Cancel then
            effect.startupTimer:Cancel()
        end
        if effect.animGroup then
            effect.animGroup:Stop()
        end
        if effect.ticker and effect.ticker.Cancel then
            effect.ticker:Cancel()
        end
        if effect.texture then
            effect.texture:Hide()
        end
    end
end

--[[
    REPUTATION BAR
    RPG-themed progress bar with standing-based visual enhancements

    Options:
    - showTickMarks = true     -- Show 25/50/75% markers
    - showAnimations = true    -- Enable hover/progress animations
    - compact = false          -- Compact mode for card integration
    - showStandingBadge = true -- Show standing name badge
]]
function Components:CreateReputationBar(parent, width, height, options)
    width = width or 200
    height = height or 14
    options = options or {}

    -- Default options
    local showTickMarks = options.showTickMarks ~= false
    local showAnimations = options.showAnimations ~= false
    local compact = options.compact or false
    local showStandingBadge = options.showStandingBadge ~= false

    -- Container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, height)

    -- Store references and state
    container.currentStanding = 4 -- Default neutral
    container.currentValue = 0
    container.maxValue = 1
    container.factionName = ""
    container.options = options
    container._effects = {} -- Track active effects for cleanup

    --[[
        LAYER 1: Ambient Glow (Background, behind everything)
        Only created for Revered+ standings
    ]]
    local ambientGlow = container:CreateTexture(nil, "BACKGROUND", nil, -2)
    ambientGlow:SetTexture(AssetTextures.GLOW_CIRCLE)
    ambientGlow:SetBlendMode("ADD")
    ambientGlow:SetPoint("CENTER", container, "CENTER", 0, 0)
    ambientGlow:SetSize(width * 1.5, height * 3)
    ambientGlow:SetVertexColor(1, 0.84, 0, 0) -- Start invisible
    ambientGlow:Hide()
    container.ambientGlow = ambientGlow

    --[[
        LAYER 2: Background Track
        Dark background for the bar
    ]]
    local bgTrack = container:CreateTexture(nil, "BACKGROUND", nil, -1)
    bgTrack:SetTexture(AssetTextures.SOLID)
    bgTrack:SetAllPoints(container)
    bgTrack:SetVertexColor(0.05, 0.05, 0.05, 0.9)
    container.bgTrack = bgTrack

    --[[
        LAYER 3: Fill Bar (Status Bar texture)
        Smooth metallic gradient for gaming-style progress feel
    ]]
    local fillBar = container:CreateTexture(nil, "ARTWORK", nil, 0)
    fillBar:SetTexture(AssetTextures.STATUS_BAR)
    fillBar:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -2)
    fillBar:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 2, 2)
    fillBar:SetWidth(1) -- Start empty
    fillBar:SetVertexColor(0.2, 0.8, 0.2, 1) -- Default friendly green
    container.fillBar = fillBar
    container.maxFillWidth = width - 4 -- Account for 2px padding each side

    --[[
        LAYER 3.5: Inner Bevel (3D depth effect)
        Top shadow and bottom highlight for gaming-style depth
    ]]
    local topShadow = container:CreateTexture(nil, "ARTWORK", nil, 1)
    topShadow:SetTexture(AssetTextures.SOLID)
    topShadow:SetHeight(2)
    topShadow:SetPoint("TOPLEFT", fillBar, "TOPLEFT", 0, 0)
    topShadow:SetPoint("TOPRIGHT", fillBar, "TOPRIGHT", 0, 0)
    topShadow:SetVertexColor(0, 0, 0, 0.35)
    container.topShadow = topShadow

    local bottomHighlight = container:CreateTexture(nil, "ARTWORK", nil, 1)
    bottomHighlight:SetTexture(AssetTextures.SOLID)
    bottomHighlight:SetHeight(1)
    bottomHighlight:SetPoint("BOTTOMLEFT", fillBar, "BOTTOMLEFT", 0, 0)
    bottomHighlight:SetPoint("BOTTOMRIGHT", fillBar, "BOTTOMRIGHT", 0, 0)
    bottomHighlight:SetVertexColor(1, 1, 1, 0.2)
    container.bottomHighlight = bottomHighlight

    --[[
        LAYER 4: Shine Overlay (ADD blend for highlights)
    ]]
    local shineOverlay = container:CreateTexture(nil, "ARTWORK", nil, 1)
    shineOverlay:SetTexture(AssetTextures.HIGHLIGHT)
    shineOverlay:SetBlendMode("ADD")
    shineOverlay:SetAllPoints(fillBar)
    shineOverlay:SetVertexColor(1, 1, 1, 0.15)
    container.shineOverlay = shineOverlay

    --[[
        LAYER 4.5: Segment Dividers (Gaming XP-bar style)
        9 vertical dividers at 10%, 20%, ... 90% for chunky segment feel
    ]]
    container.segmentDividers = {}
    for i = 1, 9 do
        local pct = i * 0.10
        local divider = container:CreateTexture(nil, "ARTWORK", nil, 2)
        divider:SetTexture(AssetTextures.SOLID)
        divider:SetSize(1, height - 4)
        divider:SetPoint("CENTER", container, "LEFT", width * pct, 0)
        divider:SetVertexColor(0, 0, 0, 0.4)
        container.segmentDividers[i] = divider
    end

    --[[
        LAYER 5: Diamond Milestone Markers at 25%, 50%, 75%
        Rotated star4 diamonds that glow when crossed
    ]]
    container.tickMarks = {}
    local tickPositions = { 0.25, 0.50, 0.75 }
    for i, pct in ipairs(tickPositions) do
        local tick = container:CreateTexture(nil, "ARTWORK", nil, 4)
        tick:SetTexture(AssetTextures.GLOW_STAR)
        tick:SetSize(10, 10)
        tick:SetPoint("CENTER", container, "LEFT", width * pct, 0)
        tick:SetVertexColor(0.4, 0.4, 0.4, 0.6)
        tick:SetRotation(math.rad(45)) -- Diamond orientation
        tick:Hide() -- Hidden until enabled by standing
        container.tickMarks[i] = tick
    end

    --[[
        LAYER 6: Border Frame
        Switches between tooltip border (low) and gold border (high)
    ]]
    local borderFrame = CreateBackdropFrame("Frame", nil, container)
    borderFrame:SetPoint("TOPLEFT", container, "TOPLEFT", -3, 3)
    borderFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 3, -3)
    self:ApplyBackdrop(borderFrame, "BORDER_ONLY_TOOLTIP", nil, "GREY_DARK")
    container.borderFrame = borderFrame

    -- Secondary border for "double gold" effect (Exalted)
    local outerBorder = CreateBackdropFrame("Frame", nil, container)
    outerBorder:SetPoint("TOPLEFT", container, "TOPLEFT", -6, 6)
    outerBorder:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 6, -6)
    self:ApplyBackdropRaw(outerBorder, "BORDER_ONLY_GOLD", nil, nil, nil, nil, 1, 0.84, 0, 0.8)
    outerBorder:Hide()
    container.outerBorder = outerBorder

    --[[
        LAYER 7: Corner Flourishes (star4 texture)
        Decorative corners for Honored+ standings
    ]]
    container.flourishes = {}
    local flourishSize = 12
    local flourishPositions = {
        { point = "TOPLEFT", x = -2, y = 2 },
        { point = "TOPRIGHT", x = 2, y = 2 },
        { point = "BOTTOMLEFT", x = -2, y = -2 },
        { point = "BOTTOMRIGHT", x = 2, y = -2 },
    }
    for i, pos in ipairs(flourishPositions) do
        local flourish = container:CreateTexture(nil, "OVERLAY", nil, 1)
        flourish:SetTexture(AssetTextures.GLOW_STAR)
        flourish:SetSize(flourishSize, flourishSize)
        flourish:SetPoint("CENTER", container, pos.point, pos.x, pos.y)
        flourish:SetVertexColor(1, 0.84, 0, 0.7)
        flourish:SetBlendMode("ADD")
        flourish:Hide()
        container.flourishes[i] = flourish
    end

    --[[
        LAYER 8: Crown Icon (Exalted only)
        Small crown/achievement icon above the bar
    ]]
    local crownIcon = container:CreateTexture(nil, "OVERLAY", nil, 2)
    crownIcon:SetTexture(HopeAddon.assets.icons.CROWN)
    crownIcon:SetSize(16, 16)
    crownIcon:SetPoint("TOP", container, "TOP", 0, 12)
    crownIcon:Hide()
    container.crownIcon = crownIcon

    --[[
        LAYER 9: Leading Edge Glow
        Pulsing glow at the progress front for gaming feel
    ]]
    local leadingGlow = container:CreateTexture(nil, "ARTWORK", nil, 5)
    leadingGlow:SetTexture(AssetTextures.GLOW_BUTTON)
    leadingGlow:SetBlendMode("ADD")
    leadingGlow:SetSize(20, height * 2.5)
    leadingGlow:SetVertexColor(1, 1, 1, 0.5)
    leadingGlow:Hide()
    container.leadingGlow = leadingGlow

    --[[
        Standing Badge
        Small frame showing current standing name with loot glow effect
    ]]
    if showStandingBadge then
        local badgeFrame = CreateFrame("Frame", nil, container)
        badgeFrame:SetSize(60, height)
        badgeFrame:SetPoint("LEFT", container, "RIGHT", 4, 0)

        -- Loot glow texture (behind text)
        local badgeGlow = badgeFrame:CreateTexture(nil, "BACKGROUND")
        badgeGlow:SetTexture(AssetTextures.GLOW_BUTTON)
        badgeGlow:SetBlendMode("ADD")
        badgeGlow:SetPoint("CENTER", badgeFrame, "CENTER", 0, 0)
        badgeGlow:SetSize(70, height * 2.5)
        badgeGlow:Hide()
        container.badgeGlow = badgeGlow

        local badgeText = badgeFrame:CreateFontString(nil, "OVERLAY")
        badgeText:SetFont(AssetFonts.SMALL, compact and 9 or 10)
        badgeText:SetPoint("LEFT", badgeFrame, "LEFT", 0, 0)
        badgeText:SetText("Neutral")
        badgeText:SetTextColor(1, 1, 1, 1)

        container.badgeFrame = badgeFrame
        container.badgeText = badgeText
    end

    --[[
        Sparkle Container (for animated sparkles)
        Created lazily for Revered+ standings
    ]]
    container.sparkles = nil

    --[[
        METHODS
    ]]

    -- Update the visual styling based on standing
    function container:SetStanding(standingId)
        standingId = math.max(1, math.min(8, standingId or 4))
        self.currentStanding = standingId

        local visuals = STANDING_VISUALS[standingId]
        if not visuals then return end

        -- Clean up previous effects
        self:CleanupEffects()

        -- Update border style using centralized backdrops
        local C = HopeAddon.Constants
        if visuals.border == "GOLD" then
            self.borderFrame:SetBackdrop(C.BACKDROPS.BORDER_ONLY_GOLD)
            self.borderFrame:SetBackdropBorderColor(C.BACKDROP_COLORS.GOLD[1], C.BACKDROP_COLORS.GOLD[2], C.BACKDROP_COLORS.GOLD[3], 1)
            self.outerBorder:Hide()
        elseif visuals.border == "GOLD_DOUBLE" then
            self.borderFrame:SetBackdrop(C.BACKDROPS.BORDER_ONLY_GOLD)
            self.borderFrame:SetBackdropBorderColor(C.BACKDROP_COLORS.GOLD[1], C.BACKDROP_COLORS.GOLD[2], C.BACKDROP_COLORS.GOLD[3], 1)
            self.outerBorder:Show()
        else -- TOOLTIP
            self.borderFrame:SetBackdrop(C.BACKDROPS.BORDER_ONLY_TOOLTIP)
            self.borderFrame:SetBackdropBorderColor(C.BACKDROP_COLORS.GREY_DARK[1], C.BACKDROP_COLORS.GREY_DARK[2], C.BACKDROP_COLORS.GREY_DARK[3], 1)
            self.outerBorder:Hide()
        end

        -- Update tick marks visibility (TBC compatible - no SetShown)
        for _, tick in ipairs(self.tickMarks) do
            if visuals.showTickMarks then
                tick:Show()
            else
                tick:Hide()
            end
        end

        -- Update corner flourishes (TBC compatible - no SetShown)
        for _, flourish in ipairs(self.flourishes) do
            if visuals.showCornerFlourishes then
                flourish:Show()
            else
                flourish:Hide()
            end
        end

        -- Update crown icon (TBC compatible - no SetShown)
        if visuals.showCrown then
            self.crownIcon:Show()
        else
            self.crownIcon:Hide()
        end

        -- Update badge with item quality colors and loot glow
        if self.badgeText then
            local standingName = STANDING_NAMES[standingId] or "Unknown"
            self.badgeText:SetText(standingName)

            -- Get item quality color
            local qualityColor = HopeAddon.colors[visuals.badgeQuality]
            if qualityColor then
                self.badgeText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
            end

            -- Setup badge glow effect
            if self.badgeGlow then
                if visuals.badgeGlow and HopeAddon.db and HopeAddon.db.settings.glowEnabled then
                    self.badgeGlow:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
                    self.badgeGlow:Show()
                    self:StartBadgeGlow(visuals.badgeGlow)
                else
                    self.badgeGlow:Hide()
                end
            end
        end

        -- Setup glow effects
        if HopeAddon.db and HopeAddon.db.settings.glowEnabled then
            if visuals.glowType == "subtle" then
                self.ambientGlow:SetVertexColor(1, 0.84, 0, 0.15)
                self.ambientGlow:Show()
            elseif visuals.glowType == "pulsing" then
                self.ambientGlow:SetVertexColor(1, 0.84, 0, 0.25)
                self.ambientGlow:Show()
                self:StartPulsingGlow()
            elseif visuals.glowType == "epic" then
                self.ambientGlow:SetVertexColor(0.64, 0.21, 0.93, 0.35)
                self.ambientGlow:Show()
                self:StartEpicGlow()
            else
                self.ambientGlow:Hide()
            end

            -- Setup sparkles for Revered+
            if visuals.showSparkles then
                self:CreateSparkles()
            end
        end
    end

    -- Set the reputation progress
    function container:SetReputation(factionName, current, max, standingId)
        self.factionName = factionName or ""
        self.currentValue = current or 0
        self.maxValue = math.max(1, max or 1)

        -- Update standing visuals
        self:SetStanding(standingId)

        -- Update fill bar
        local percent = self.currentValue / self.maxValue
        local fillWidth = math.max(1, self.maxFillWidth * percent)
        self.fillBar:SetWidth(fillWidth)

        -- Update fill bar color based on standing
        local Data = HopeAddon.ReputationData
        if Data and Data.GetStandingColor then
            local r, g, b = Data:GetStandingColor(standingId)
            self.fillBar:SetVertexColor(r, g, b, 1)
        end

        -- Update leading edge glow
        self:UpdateLeadingGlow()
    end

    -- Animate progress to a target value with gaming-style segment feedback
    function container:AnimateProgress(targetValue, duration)
        duration = duration or 0.5

        -- Cancel any existing progress animation to prevent overlap
        if self._progressTicker then
            self._progressTicker:Cancel()
            self._progressTicker = nil
        end

        if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
            -- Just set directly if animations disabled
            self.currentValue = targetValue
            local percent = self.currentValue / self.maxValue
            local fillWidth = math.max(1, self.maxFillWidth * percent)
            self.fillBar:SetWidth(fillWidth)
            self:UpdateLeadingGlow()
            return
        end

        local startValue = self.currentValue
        local elapsed = 0

        -- Track segment crossings (every 10%)
        local startPercent = startValue / self.maxValue
        local lastSegment = math.floor(startPercent * 10)

        -- Track milestone crossings (25%, 50%, 75%)
        local lastMilestoneIdx = 0
        if startPercent >= 0.75 then lastMilestoneIdx = 3
        elseif startPercent >= 0.50 then lastMilestoneIdx = 2
        elseif startPercent >= 0.25 then lastMilestoneIdx = 1
        end

        self._progressTicker = HopeAddon.Timer:NewTicker(0.02, function()
            elapsed = elapsed + 0.02
            local progress = math.min(elapsed / duration, 1)
            -- Ease out quad
            local eased = progress * (2 - progress)

            local currentVal = startValue + (targetValue - startValue) * eased
            self.currentValue = currentVal

            local percent = currentVal / self.maxValue
            local fillWidth = math.max(1, self.maxFillWidth * percent)
            self.fillBar:SetWidth(fillWidth)

            -- Update leading edge glow position
            self:UpdateLeadingGlow()

            -- Check for segment crossing (every 10%)
            local currentSegment = math.floor(percent * 10)
            if currentSegment > lastSegment and currentSegment <= 10 then
                self:OnSegmentCrossed(currentSegment)
                lastSegment = currentSegment
            end

            -- Check for milestone crossing (25%, 50%, 75%)
            local currentMilestoneIdx = 0
            if percent >= 0.75 then currentMilestoneIdx = 3
            elseif percent >= 0.50 then currentMilestoneIdx = 2
            elseif percent >= 0.25 then currentMilestoneIdx = 1
            end
            if currentMilestoneIdx > lastMilestoneIdx then
                self:OnMilestoneCrossed(currentMilestoneIdx)
                lastMilestoneIdx = currentMilestoneIdx
            end

            if progress >= 1 then
                self._progressTicker:Cancel()
                self._progressTicker = nil

                -- Check for 100% completion
                if percent >= 1.0 then
                    self:OnProgressComplete()
                end
            end
        end)

        table.insert(self._effects, { ticker = self._progressTicker })
    end

    -- Update leading edge glow position
    function container:UpdateLeadingGlow()
        if not self.leadingGlow then return end
        local percent = self.currentValue / self.maxValue
        if percent > 0.02 and percent < 0.98 then
            self.leadingGlow:ClearAllPoints()
            self.leadingGlow:SetPoint("CENTER", self.fillBar, "RIGHT", 0, 0)
            self.leadingGlow:Show()
        else
            self.leadingGlow:Hide()
        end
    end

    -- Called when crossing 10% segment boundaries
    function container:OnSegmentCrossed(segmentNumber)
        -- Play subtle tick sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayProgressTick()
        end

        -- Flash the segment divider gold briefly
        local divider = self.segmentDividers and self.segmentDividers[segmentNumber - 1]
        if divider then
            divider:SetVertexColor(1, 0.84, 0, 0.9)
            HopeAddon.Timer:After(0.15, function()
                if divider then divider:SetVertexColor(0, 0, 0, 0.4) end
            end)
        end
    end

    -- Called when crossing 25%, 50%, or 75% milestones
    function container:OnMilestoneCrossed(milestoneIndex)
        -- Play bell chime
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayProgressMilestone()
        end

        -- Flash the diamond marker gold
        local marker = self.tickMarks and self.tickMarks[milestoneIndex]
        if marker then
            marker:SetVertexColor(1, 0.84, 0, 1)
            marker:Show()

            -- Burst effect at the marker position
            if HopeAddon.Effects and HopeAddon.Effects.CreateBurstEffect then
                local burstFrame = CreateFrame("Frame", nil, self)
                burstFrame:SetPoint("CENTER", marker, "CENTER", 0, 0)
                burstFrame:SetSize(1, 1)
                HopeAddon.Effects:CreateBurstEffect(burstFrame, "GOLD_BRIGHT")
            end
        end
    end

    -- Called when progress reaches 100%
    function container:OnProgressComplete()
        -- Play completion sound
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayProgressComplete()
        end

        -- Hide leading glow at completion
        if self.leadingGlow then
            self.leadingGlow:Hide()
        end

        -- Celebration sparkles
        if HopeAddon.Effects and HopeAddon.Effects.ProgressSparkles then
            HopeAddon.Effects:ProgressSparkles(self, 1.5)
        end
    end

    -- Stop all glow animations and reset flags (allows re-triggering)
    function container:StopGlowAnimations()
        -- Stop animation groups for glow effects
        for i = #self._effects, 1, -1 do
            local effect = self._effects[i]
            if effect.animGroup then
                effect.animGroup:Stop()
            end
        end

        -- Reset ambient glow to base state
        if self.ambientGlow then
            self.ambientGlow:SetAlpha(0)
        end

        -- Reset badge glow
        if self.badgeGlow then
            self.badgeGlow:SetAlpha(0)
        end

        -- Reset all animation flags so they can retrigger
        self._pulsingActive = nil
        self._epicActive = nil
        self._badgeActive = nil
    end

    -- Start pulsing glow animation (Revered)
    function container:StartPulsingGlow()
        if not self.ambientGlow then return end
        self:StopGlowAnimations()
        self._pulsingActive = true

        local ag = CreateGlowAnimation(self.ambientGlow, 0.15, 0.35, 1.2)
        ag:Play()
        table.insert(self._effects, { animGroup = ag })
    end

    -- Start epic glow animation (Exalted)
    function container:StartEpicGlow()
        if not self.ambientGlow then return end
        self:StopGlowAnimations()
        self._epicActive = true

        local ag = CreateGlowAnimation(self.ambientGlow, 0.25, 0.5, 0.8)
        ag:Play()
        table.insert(self._effects, { animGroup = ag })

        -- Also animate flourishes
        CreateFlourishAnimations(self.flourishes, self._effects)
    end

    -- Start badge loot glow animation
    function container:StartBadgeGlow(glowType)
        if not self.badgeGlow then return end
        self:StopGlowAnimations()
        self._badgeActive = true

        -- Glow parameters by type
        local glowParams = {
            subtle = { intensity = 0.3, duration = nil },
            rare = { intensity = 0.5, duration = 1.5 },
            epic = { intensity = 0.7, duration = 1.0 },
            legendary = { intensity = 1.0, duration = 0.8 },
        }

        local params = glowParams[glowType]
        if not params then return end

        self.badgeGlow:SetAlpha(params.intensity)

        if params.duration then
            local ag = CreateGlowAnimation(self.badgeGlow, params.intensity * 0.5, params.intensity, params.duration)
            ag:Play()
            table.insert(self._effects, { animGroup = ag })
        end
    end

    -- Create floating sparkles
    function container:CreateSparkles()
        if self.sparkles then return end -- Already created

        self.sparkles = {}
        local sparkleCount = 4

        for i = 1, sparkleCount do
            local spark = self:CreateTexture(nil, "OVERLAY", nil, 3)
            spark:SetTexture(AssetTextures.GLOW_STAR)
            spark:SetBlendMode("ADD")
            spark:SetSize(5 + math.random(3), 5 + math.random(3))
            spark:SetVertexColor(1, 0.84, 0, 0.8)

            -- Random position along the bar
            local xOff = math.random(4, width - 4)
            local yOff = math.random(-2, 2)
            spark:SetPoint("LEFT", self, "LEFT", xOff, yOff)

            -- Animation
            local ag = spark:CreateAnimationGroup()
            ag:SetLooping("REPEAT")

            -- Float upward
            local move = ag:CreateAnimation("Translation")
            move:SetOffset(math.random(-8, 8), 12 + math.random(8))
            move:SetDuration(1.5 + math.random() * 1.0)
            move:SetSmoothing("OUT")

            -- Fade cycle
            local fadeIn = ag:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(0.8)
            fadeIn:SetDuration(0.4)
            fadeIn:SetOrder(1)

            local fadeOut = ag:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(0.8)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.4)
            fadeOut:SetOrder(2)
            fadeOut:SetStartDelay(0.8 + math.random() * 0.5)

            -- Stagger start (store timer handle for proper cancellation)
            local timerHandle = HopeAddon.Timer:After(math.random() * 1.5, function()
                if spark:IsShown() then
                    ag:Play()
                end
            end)

            table.insert(self.sparkles, { texture = spark, animGroup = ag, startupTimer = timerHandle })
            table.insert(self._effects, { animGroup = ag, texture = spark, startupTimer = timerHandle })
        end
    end

    -- Cleanup all active effects
    function container:CleanupEffects()
        CleanupRepEffects(self._effects)
        self._effects = {}

        -- Clear sparkles
        CleanupRepSparkles(self.sparkles)
        self.sparkles = nil

        -- Reset ambient glow
        self.ambientGlow:Hide()

        -- Reset badge glow
        if self.badgeGlow then
            self.badgeGlow:Hide()
        end

        -- Reset leading glow
        if self.leadingGlow then
            self.leadingGlow:Hide()
        end

        -- Reset segment dividers to default color
        if self.segmentDividers then
            for _, divider in ipairs(self.segmentDividers) do
                divider:SetVertexColor(0, 0, 0, 0.4)
            end
        end

        -- Reset diamond markers to default
        if self.tickMarks then
            for _, marker in ipairs(self.tickMarks) do
                marker:SetVertexColor(0.4, 0.4, 0.4, 0.6)
            end
        end

        -- Reset animation state flags
        self._pulsingActive = nil
        self._epicActive = nil
        self._badgeActive = nil
    end

    -- Hover effects
    container:EnableMouse(true)
    container:SetScript("OnEnter", function(self)
        -- Brighten the bar slightly
        self.shineOverlay:SetVertexColor(1, 1, 1, 0.3)

        -- Show tooltip
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(self.factionName, 1, 0.84, 0)

        local standingName = STANDING_NAMES[self.currentStanding] or "Unknown"
        local progress = string.format("%d / %d", self.currentValue, self.maxValue)
        local percent = math.floor((self.currentValue / self.maxValue) * 100)

        GameTooltip:AddLine(standingName .. " (" .. percent .. "%)", 1, 1, 1)
        GameTooltip:AddLine(progress, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    container:SetScript("OnLeave", function(self)
        -- Reset shine
        self.shineOverlay:SetVertexColor(1, 1, 1, 0.15)
        GameTooltip:Hide()
    end)

    return container
end

--[[
    TRAVELER ICON DISPLAY
    Single icon with quality-colored border and glow
    @param parent Frame - Parent frame
    @param iconData table - Icon definition from Constants.TRAVELER_ICONS
    @param size number - Icon size (default 24)
    @return Frame - Icon display frame
]]
function Components:CreateTravelerIconDisplay(parent, iconData, size)
    size = size or 24

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)

    -- Icon texture
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\" .. (iconData.icon or "INV_Misc_QuestionMark"))
    icon:SetAllPoints(frame)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the icon edges
    frame.icon = icon

    -- Quality-colored border
    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetTexture(AssetTextures.TOOLTIP_BORDER)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)

    -- Set border color based on quality
    local qualityColor = HopeAddon.colors[iconData.quality] or HopeAddon.colors.COMMON
    border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
    frame.border = border

    -- Quality glow (for Epic and Legendary)
    if iconData.quality == "EPIC" or iconData.quality == "LEGENDARY" then
        local glow = frame:CreateTexture(nil, "BACKGROUND")
        glow:SetTexture(AssetTextures.GLOW_BUTTON)
        glow:SetBlendMode("ADD")
        glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
        glow:SetSize(size * 1.8, size * 1.8)
        glow:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b, 0.5)
        frame.glow = glow

        -- Animate glow for Legendary
        if iconData.quality == "LEGENDARY" and HopeAddon.db and HopeAddon.db.settings.glowEnabled then
            local ag = glow:CreateAnimationGroup()
            ag:SetLooping("BOUNCE")

            local pulse = ag:CreateAnimation("Alpha")
            pulse:SetFromAlpha(0.3)
            pulse:SetToAlpha(0.7)
            pulse:SetDuration(1.0)
            pulse:SetSmoothing("IN_OUT")

            ag:Play()
            frame.glowAnim = ag
        end
    end

    -- Tooltip
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        -- Title with quality color
        local colorHex = qualityColor.hex or "FFFFFF"
        GameTooltip:SetText("|cFF" .. colorHex .. iconData.name .. "|r")

        -- Description
        GameTooltip:AddLine(iconData.description, 1, 1, 1, true)

        -- Category
        local categoryData = HopeAddon.Constants.ICON_CATEGORIES[iconData.category]
        if categoryData then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Category: " .. categoryData.name, 0.7, 0.7, 0.7)
        end

        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Store data reference
    frame.iconData = iconData

    return frame
end

--[[
    TRAVELER ICON ROW
    Horizontal row of icons for a traveler entry
    @param parent Frame - Parent frame
    @param travelerName string - Name of the traveler
    @param maxIcons number - Maximum icons to display (default 5)
    @return Frame - Icon row frame
]]
function Components:CreateTravelerIconRow(parent, travelerName, maxIcons)
    maxIcons = maxIcons or 5
    local iconSize = 20
    local spacing = 4

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(iconSize)

    -- Store references
    frame.icons = {}
    frame.travelerName = travelerName

    -- Method to update icons
    function frame:UpdateIcons()
        -- Clear existing icons
        for _, iconFrame in ipairs(self.icons) do
            iconFrame:Hide()
            iconFrame:SetParent(nil)
        end
        self.icons = {}

        -- Get icons for this traveler
        if not HopeAddon.TravelerIcons then return end

        local travelerIcons = HopeAddon.TravelerIcons:GetIcons(self.travelerName)
        local displayCount = math.min(#travelerIcons, maxIcons)

        -- Calculate row width
        local rowWidth = (displayCount * iconSize) + (math.max(0, displayCount - 1) * spacing)
        self:SetWidth(math.max(1, rowWidth))

        -- Create icon displays
        for i = 1, displayCount do
            local iconEntry = travelerIcons[i]
            local iconFrame = Components:CreateTravelerIconDisplay(self, iconEntry.data, iconSize)
            iconFrame:SetPoint("LEFT", self, "LEFT", (i - 1) * (iconSize + spacing), 0)

            -- Add earned date to tooltip
            local originalOnEnter = iconFrame:GetScript("OnEnter")
            iconFrame:SetScript("OnEnter", function(btn)
                originalOnEnter(btn)
                if iconEntry.earned and iconEntry.earned.earnedDate then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Earned: " .. iconEntry.earned.earnedDate, 0.5, 0.5, 0.5)
                    GameTooltip:Show()
                end
            end)

            table.insert(self.icons, iconFrame)
        end

        -- Show "+N" if there are more icons
        if #travelerIcons > maxIcons then
            local moreText = self:CreateFontString(nil, "OVERLAY")
            moreText:SetFont(AssetFonts.SMALL, 10)
            moreText:SetPoint("LEFT", self, "LEFT", displayCount * (iconSize + spacing), 0)
            moreText:SetText("+" .. (#travelerIcons - maxIcons))
            moreText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
            table.insert(self.icons, moreText)

            -- Adjust width for "+N" text
            self:SetWidth(rowWidth + moreText:GetStringWidth() + spacing)
        end
    end

    -- Initial update
    frame:UpdateIcons()

    return frame
end

--[[
    TRAVELER CARD WITH ICONS
    Enhanced traveler display card showing name, class, level, and icons
    @param parent Frame - Parent frame
    @param travelerData table - { name, class, level, lastSeen, icons }
    @return Frame - Traveler card frame
]]
function Components:CreateTravelerCard(parent, travelerData)
    local card = CreateBackdropFrame("Frame", nil, parent)
    card:SetHeight(50)
    self:ApplyBackdrop(card, "TOOLTIP", "DARK_TRANSPARENT", "GREY")

    -- Class-colored name
    local classColor = HopeAddon:GetClassColor(travelerData.class)
    local nameText = card:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(AssetFonts.HEADER, 13)
    nameText:SetPoint("TOPLEFT", card, "TOPLEFT", Components.MARGIN_NORMAL, -Components.MARGIN_NORMAL)
    nameText:SetText(string.format("|cFF%02x%02x%02x%s|r",
        classColor.r * 255, classColor.g * 255, classColor.b * 255,
        travelerData.name or "Unknown"))
    card.nameText = nameText

    -- Level
    local levelText = card:CreateFontString(nil, "OVERLAY")
    levelText:SetFont(AssetFonts.SMALL, 10)
    levelText:SetPoint("LEFT", nameText, "RIGHT", Components.MARGIN_SMALL, 0)
    if travelerData.level then
        levelText:SetText("(" .. travelerData.level .. ")")
    end
    levelText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
    card.levelText = levelText

    -- Last seen
    local lastSeenText = card:CreateFontString(nil, "OVERLAY")
    lastSeenText:SetFont(AssetFonts.SMALL, 9)
    lastSeenText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", Components.MARGIN_NORMAL, Components.MARGIN_SMALL)
    if travelerData.lastSeen then
        lastSeenText:SetText("Last seen: " .. travelerData.lastSeen)
    elseif travelerData.lastSeenZone then
        lastSeenText:SetText(travelerData.lastSeenZone)
    end
    lastSeenText:SetTextColor(HopeAddon:GetTextColor("DISABLED"))
    card.lastSeenText = lastSeenText

    -- Icon row
    local iconRow = Components:CreateTravelerIconRow(card, travelerData.name, 4)
    iconRow:SetPoint("TOPRIGHT", card, "TOPRIGHT", -Components.MARGIN_NORMAL, -Components.MARGIN_NORMAL)
    card.iconRow = iconRow

    -- Stats summary
    if travelerData.stats then
        local statsText = card:CreateFontString(nil, "OVERLAY")
        statsText:SetFont(AssetFonts.SMALL, 9)
        statsText:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -Components.MARGIN_NORMAL, Components.MARGIN_SMALL)

        local statParts = {}
        if travelerData.stats.groupCount and travelerData.stats.groupCount > 0 then
            table.insert(statParts, travelerData.stats.groupCount .. " groups")
        end
        if travelerData.stats.bossKillsTogether and travelerData.stats.bossKillsTogether > 0 then
            table.insert(statParts, travelerData.stats.bossKillsTogether .. " kills")
        end

        if #statParts > 0 then
            statsText:SetText(table.concat(statParts, " | "))
            statsText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
        end
        card.statsText = statsText
    end

    -- Hover effect
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(HopeAddon:GetColor("GOLD_BRIGHT"))
    end)
    card:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end)

    -- Store data reference
    card.travelerData = travelerData

    return card
end

--[[
    SECTION HEADER
    Large header for tab sections with optional subtext
    @param parent Frame - Parent frame
    @param title string - Header title text
    @param colorName string - Color constant name (default "GOLD_BRIGHT")
    @param subtext string - Optional subtitle text
    @return Frame - Header container frame
]]
function Components:CreateSectionHeader(parent, title, colorName, subtext)
    colorName = colorName or "GOLD_BRIGHT"

    local headerHeight = subtext and 45 or 25
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(headerHeight)
    container._componentType = Components.COMPONENT_TYPE.SECTION_HEADER  -- H1 fix

    -- Header font string
    local header = container:CreateFontString(nil, "OVERLAY")
    header:SetFont(AssetFonts.HEADER, 16)
    header:SetPoint("TOPLEFT", container, "TOPLEFT", Components.MARGIN_NORMAL, -5)
    header:SetText(HopeAddon:ColorText(title, colorName))
    container.headerText = header

    -- Subheader font string (if provided)
    if subtext then
        local subheader = container:CreateFontString(nil, "OVERLAY")
        subheader:SetFont(AssetFonts.BODY, 11)
        subheader:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -3)
        subheader:SetText(subtext)
        subheader:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
        container.subText = subheader
    end

    return container
end

--[[
    CATEGORY HEADER
    Smaller header for categories within sections
    @param parent Frame - Parent frame
    @param title string - Header title text
    @param colorName string - Color constant name (default "GOLD_BRIGHT")
    @return Frame - Header container frame
]]
function Components:CreateCategoryHeader(parent, title, colorName)
    colorName = colorName or "GOLD_BRIGHT"

    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(25)
    container._componentType = Components.COMPONENT_TYPE.CATEGORY_HEADER  -- H1 fix

    -- Header font string
    local header = container:CreateFontString(nil, "OVERLAY")
    header:SetFont(AssetFonts.HEADER, 13)
    header:SetPoint("TOPLEFT", container, "TOPLEFT", Components.MARGIN_NORMAL, -3)
    header:SetText(HopeAddon:ColorText(title, colorName))
    container.headerText = header

    return container
end

--[[
    SPACER
    Simple vertical spacer frame
    @param parent Frame - Parent frame
    @param height number - Spacer height (default 10)
    @return Frame - Spacer frame
]]
function Components:CreateSpacer(parent, height)
    local spacer = CreateFrame("Frame", nil, parent)
    local spacerHeight = height or 10
    spacer:SetHeight(spacerHeight)
    spacer._componentType = Components.COMPONENT_TYPE.SPACER  -- H1 fix
    spacer._spacerHeight = spacerHeight  -- Store actual height for fallback
    return spacer
end

--[[
    GAME CARD
    Card component for displaying a game in the Games Hall
    Shows icon, name, description, stats, and Practice/Challenge buttons

    @param parent Frame - Parent frame
    @param gameData table - Game definition from Constants.GAME_DEFINITIONS
    @param onPractice function - Callback for Practice button click (gameId)
    @param onChallenge function - Callback for Challenge button click (gameId)
    @return Frame - Game card frame with all elements
]]
function Components:CreateGameCard(parent, gameData, onPractice, onChallenge)
    local CARD_WIDTH = 230
    local CARD_HEIGHT = 110
    local ICON_SIZE = 40
    local BUTTON_WIDTH = 70
    local BUTTON_HEIGHT = 22

    local card = CreateBackdropFrame("Button", nil, parent)
    card:SetSize(CARD_WIDTH, CARD_HEIGHT)
    -- Use SOLID_TOOLTIP with dark tint - color will be set per game in SetGameData
    self:ApplyBackdropRaw(card, "SOLID_TOOLTIP", 0.15, 0.1, 0.2, 0.9, 0.61, 0.19, 1.0, 1)

    -- Store default border color (ARCANE_PURPLE) - will be updated per game
    card.defaultBorderColor = HopeAddon.Constants.BACKDROP_COLORS.ARCANE

    -- Icon (left side)
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("TOPLEFT", card, "TOPLEFT", 6, -6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon edges
    card.icon = icon

    -- Title (GOLD_BRIGHT, right of icon)
    local title = card:CreateFontString(nil, "OVERLAY")
    title:SetFont(AssetFonts.HEADER, 12, "OUTLINE")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    title:SetPoint("RIGHT", card, "RIGHT", -8, 0)
    title:SetJustifyH("LEFT")
    title:SetTextColor(1, 0.84, 0, 1) -- GOLD_BRIGHT
    card.title = title

    -- Description (secondary text, below title)
    local desc = card:CreateFontString(nil, "OVERLAY")
    desc:SetFont(AssetFonts.BODY, 9)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", card, "RIGHT", -8, 0)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")
    desc:SetWordWrap(true)
    desc:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    card.desc = desc

    -- Stats row (W: X L: X T: X)
    local stats = card:CreateFontString(nil, "OVERLAY")
    stats:SetFont(AssetFonts.SMALL, 9)
    stats:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 2)
    stats:SetTextColor(0.6, 0.6, 0.6, 1)
    card.stats = stats

    -- Practice button (left)
    local practiceBtn = CreateBackdropFrame("Button", nil, card)
    practiceBtn:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    practiceBtn:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 6, 6)
    self:ApplyBackdrop(practiceBtn, "BUTTON_SIMPLE", "GREEN_BTN_BG", "GREEN_DARK")

    local practiceBtnText = practiceBtn:CreateFontString(nil, "OVERLAY")
    practiceBtnText:SetFont(AssetFonts.SMALL, 10)
    practiceBtnText:SetPoint("CENTER", practiceBtn, "CENTER", 0, 0)
    practiceBtnText:SetText("Practice")
    practiceBtnText:SetTextColor(0.8, 1.0, 0.8, 1)
    practiceBtn.text = practiceBtnText

    -- Practice button highlight
    local practiceHighlight = practiceBtn:CreateTexture(nil, "HIGHLIGHT")
    practiceHighlight:SetTexture(AssetTextures.HIGHLIGHT)
    practiceHighlight:SetAllPoints()
    practiceHighlight:SetVertexColor(0.2, 0.8, 0.2, 0.3)

    -- Practice button disabled overlay
    local practiceDisabled = practiceBtn:CreateTexture(nil, "OVERLAY", nil, 1)
    practiceDisabled:SetTexture(AssetTextures.SOLID)
    practiceDisabled:SetAllPoints()
    practiceDisabled:SetVertexColor(0.3, 0.3, 0.3, 0.6)
    practiceDisabled:Hide()
    practiceBtn.disabledOverlay = practiceDisabled

    card.practiceBtn = practiceBtn

    -- Challenge button (right)
    local challengeBtn = CreateBackdropFrame("Button", nil, card)
    challengeBtn:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    challengeBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -6, 6)
    self:ApplyBackdrop(challengeBtn, "BUTTON_SIMPLE", "ARCANE_BTN_BG", "ARCANE_BORDER")

    local challengeBtnText = challengeBtn:CreateFontString(nil, "OVERLAY")
    challengeBtnText:SetFont(AssetFonts.SMALL, 10)
    challengeBtnText:SetPoint("CENTER", challengeBtn, "CENTER", 0, 0)
    challengeBtnText:SetText("Challenge")
    challengeBtnText:SetTextColor(1.0, 0.8, 1.0, 1)
    challengeBtn.text = challengeBtnText

    -- Challenge button highlight
    local challengeHighlight = challengeBtn:CreateTexture(nil, "HIGHLIGHT")
    challengeHighlight:SetTexture(AssetTextures.HIGHLIGHT)
    challengeHighlight:SetAllPoints()
    challengeHighlight:SetVertexColor(0.6, 0.2, 0.8, 0.3)

    card.challengeBtn = challengeBtn

    -- Card highlight on hover
    local highlight = card:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(AssetTextures.HIGHLIGHT)
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.1)

    -- Card enter/leave for border highlight
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    card:SetScript("OnLeave", function(self)
        local c = self.defaultBorderColor
        self:SetBackdropBorderColor(c[1], c[2], c[3], c[4])
    end)

    -- Store gameData reference
    card.gameData = gameData

    -- Method to configure the card with game data
    function card:SetGameData(data, practiceCallback, challengeCallback)
        self.gameData = data
        if not data then return end

        -- Set icon
        self.icon:SetTexture(data.icon)

        -- Set title with color
        local color = Colors[data.color] or Colors.GOLD_BRIGHT
        self.title:SetText(data.name)
        self.title:SetTextColor(color.r, color.g, color.b, 1)

        -- Set background tint based on game color
        local C = HopeAddon.Constants
        local tint = C.GAME_BG_TINTS and C.GAME_BG_TINTS[data.color]
        if tint then
            self:SetBackdropColor(tint[1], tint[2], tint[3], tint[4])
        end

        -- Set border color to match game theme (darker shade)
        local borderColor = Colors[data.color] or Colors.ARCANE_PURPLE
        self:SetBackdropBorderColor(borderColor.r * 0.7, borderColor.g * 0.7, borderColor.b * 0.7, 1)
        self.defaultBorderColor = { borderColor.r * 0.7, borderColor.g * 0.7, borderColor.b * 0.7, 1 }

        -- Set description
        self.desc:SetText(data.description)

        -- Reset stats (will be set externally)
        self.stats:SetText("")

        -- Configure Practice button
        if data.hasLocal then
            self.practiceBtn:Enable()
            self.practiceBtn.disabledOverlay:Hide()
            self.practiceBtn.text:SetTextColor(0.8, 1.0, 0.8, 1)
            self.practiceBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayClick()
                end
                if practiceCallback then
                    practiceCallback(data.id)
                end
            end)
        else
            self.practiceBtn:Disable()
            self.practiceBtn.disabledOverlay:Show()
            self.practiceBtn.text:SetTextColor(0.5, 0.5, 0.5, 1)
            self.practiceBtn:SetScript("OnClick", nil)
        end

        -- Configure Challenge button
        self.challengeBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            if challengeCallback then
                challengeCallback(data.id)
            end
        end)
    end

    -- Method to set stats text
    function card:SetStats(wins, losses, ties)
        local parts = {}
        if wins and wins > 0 then
            table.insert(parts, "|cFF00FF00W:" .. wins .. "|r")
        end
        if losses and losses > 0 then
            table.insert(parts, "|cFFFF0000L:" .. losses .. "|r")
        end
        if ties and ties > 0 then
            table.insert(parts, "|cFF888888T:" .. ties .. "|r")
        end
        if #parts > 0 then
            self.stats:SetText(table.concat(parts, "  "))
        else
            self.stats:SetText("|cFF666666No games played|r")
        end
    end

    -- Active games badge (top-right corner)
    local badge = card:CreateFontString(nil, "OVERLAY")
    badge:SetFont(AssetFonts.SMALL, 9, "OUTLINE")
    badge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -6)
    badge:SetTextColor(0, 1, 0, 1)  -- Green
    badge:Hide()
    card.activeBadge = badge

    -- Method to show active games count
    function card:SetActiveGames(count)
        if count and count > 0 then
            self.activeBadge:SetText("|cFF00FF00" .. count .. " active|r")
            self.activeBadge:Show()
            -- Change Practice button to "Continue" when games active
            self.practiceBtn.text:SetText("Continue")
        else
            self.activeBadge:Hide()
            self.practiceBtn.text:SetText("Practice")
        end
    end

    -- Initial setup if gameData provided
    if gameData then
        card:SetGameData(gameData, onPractice, onChallenge)
    end

    return card
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Components module loaded")
end
