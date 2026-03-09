--[[
    HopeAddon Crusade Critter UI
    Tab-out housing panel with mascot container, speech bubble, popups, and stats window

    Visual specs:
    - Tab button on right screen edge (24x60px)
    - Housing container slides out (120x140px)
    - 80x80 3D model with soft glow (112px)
    - Comic-style white speech bubble
    - Gentle bobbing animation (3px, 2sec cycle)
    - Critter selector popup on click
]]

local CritterUI = {}
HopeAddon.CritterUI = CritterUI
HopeAddon:RegisterModule("CritterUI", CritterUI)

--============================================================
-- CONSTANTS
--============================================================

local MODEL_SIZE = 80
local GLOW_SIZE = 112
local BUBBLE_WIDTH = 280
local BUBBLE_PADDING = 12
local BUBBLE_DURATION = 5
local POPUP_DURATION = 5
local BOB_AMPLITUDE = 3
local BOB_PERIOD = 2

-- Housing panel constants
local TAB_WIDTH = 24
local TAB_HEIGHT = 60
local HOUSING_WIDTH = 120
local HOUSING_HEIGHT = 140
local SLIDE_DURATION = 0.3
local HOUSING_OFFSET_X = 130 -- Distance from screen edge when open (clears minimap)
local HOUSING_Y_OFFSET = -150 -- Y position (below minimap)

-- Combined stats window constants
local COMBINED_STATS_WIDTH = 320
local COMBINED_STATS_HEIGHT = 220
local COMBINED_STATS_DURATION = 10 -- Seconds before auto-hide

-- Boss tips panel constants
local TIPS_PANEL_WIDTH = 320
local TIPS_PANEL_HEIGHT = 200
local TYPEWRITER_SPEED = 0.03 -- Seconds per character

-- Glow texture for soft circular effect
local GLOW_TEXTURE = "Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64"

-- Color Constants
local COLOR_GOLD = {1, 0.84, 0}
local COLOR_GOLD_BORDER_80 = {1, 0.84, 0, 0.8}
local COLOR_GOLD_BORDER = {1, 0.84, 0, 1}
local COLOR_LABEL_GRAY = {0.7, 0.7, 0.7}
local COLOR_DARK_BG = {0.1, 0.1, 0.1, 0.95}
local COLOR_DARK_BG_90 = {0.1, 0.1, 0.1, 0.9}
local COLOR_DARK_BG_FULL = {0.1, 0.1, 0.1, 1}

-- Common Textures
local TEX_WHITE8X8 = "Interface\\Buttons\\WHITE8x8"

-- Critter icon mappings (TBC-compatible icons)
local CRITTER_ICONS = {
    chomp = "Interface\\Icons\\Ability_Hunter_Pet_Ravager",
    snookimp = "Interface\\Icons\\Spell_Shadow_SummonImp",
    shred = "Interface\\Icons\\Ability_Creature_Poison_04",
    emo = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
    cosmo = "Interface\\Icons\\Spell_Arcane_Starfire",
    boomer = "Interface\\Icons\\Ability_EyeOfTheOwl",
    diva = "Interface\\Icons\\Ability_Hunter_Pet_DragonHawk",
}

--============================================================
-- MODULE STATE
--============================================================

CritterUI.tabButton = nil
CritterUI.housingContainer = nil
CritterUI.mascotFrame = nil
CritterUI.speechBubble = nil
CritterUI.bossPopup = nil
CritterUI.statsWindow = nil
CritterUI.bobbingTicker = nil
CritterUI.bubbleTimer = nil
CritterUI.currentCritter = nil
CritterUI.bossPopupTimer = nil
CritterUI.unlockTimer = nil
CritterUI.unlockPopup = nil
CritterUI.selectorPopup = nil
CritterUI.isHousingOpen = false
CritterUI.wasOpenBeforeCombat = false
CritterUI.slideAnimation = nil

-- Combined stats + tips system
CritterUI.combinedStatsWindow = nil
CritterUI.combinedStatsTimer = nil
CritterUI.bossTipsPanel = nil
CritterUI.bossTipsState = nil -- { tips, currentIndex, state, bossKey }
CritterUI.tipsTypewriterTicker = nil

-- Idle quip timer system
CritterUI.idleQuipTimer = nil
CritterUI.bubbleBounceAnim = nil

-- Instance Guide panel system (replaces old Raid Guide)
CritterUI.instanceGuidePanel = nil
CritterUI.instanceGuideTierDropdown = nil
CritterUI.instanceGuideInstanceDropdown = nil
CritterUI.instanceGuideIsExpanded = true
CritterUI.instanceGuideIsPlaying = false
CritterUI.instanceGuideTicker = nil
CritterUI.instanceGuideTipsQueue = {}
CritterUI.instanceGuideCurrentTipIndex = 0
CritterUI.instanceGuidePlayingBossKey = nil
CritterUI.instanceGuideSelectedTier = nil
CritterUI.instanceGuideSelectedInstance = nil
CritterUI.instanceGuideIsRaid = false

-- Instance Guide constants
local INSTANCE_GUIDE_WIDTH = 260
local INSTANCE_GUIDE_HEADER_HEIGHT = 24
local INSTANCE_GUIDE_COLLAPSED_HEIGHT = INSTANCE_GUIDE_HEADER_HEIGHT
local INSTANCE_GUIDE_CONTENT_HEIGHT = 310
local INSTANCE_GUIDE_ROW_HEIGHT = 18
local INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED = 20
local INSTANCE_GUIDE_ROW_HEIGHT_EXPANDED = 52
local INSTANCE_GUIDE_PLAY_BTN_SIZE = 16
local INSTANCE_GUIDE_BOSS_SCROLL_HEIGHT = 214
local INSTANCE_GUIDE_TIP_DURATION = 8

--============================================================
-- TAB BUTTON
--============================================================

--[[
    Create the tab button that sits on the right edge of the screen
    @return Frame - The tab button
]]
function CritterUI:CreateTabButton()
    if self.tabButton then
        return self.tabButton
    end

    local tab = CreateFrame("Button", "HopeCrusadeCritterTab", UIParent, "BackdropTemplate")
    tab:SetSize(TAB_WIDTH, TAB_HEIGHT)
    tab:SetFrameStrata("MEDIUM")
    tab:SetFrameLevel(99)

    -- Make moveable
    tab:SetMovable(true)
    tab:EnableMouse(true)
    tab:SetClampedToScreen(true)
    tab:RegisterForDrag("LeftButton")

    -- Load saved position or use default
    local savedPos = HopeAddon.db and HopeAddon.db.settings and HopeAddon.db.settings.critterTabPosition
    if savedPos then
        tab:SetPoint(savedPos.point, UIParent, savedPos.point, savedPos.x, savedPos.y)
    else
        -- Default position on right edge, below minimap
        tab:SetPoint("RIGHT", UIParent, "RIGHT", -50, HOUSING_Y_OFFSET)
    end

    -- Dark background with gold border (matches addon style)
    tab:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    tab:SetBackdropColor(unpack(COLOR_DARK_BG_90))
    tab:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER_80))

    -- Critter silhouette icon (using a simple texture for now)
    local icon = tab:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", tab, "CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Pet_ManaWyrm") -- Default icon
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon borders
    tab.icon = icon

    -- Arrow indicator (shows open/closed state)
    local arrow = tab:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(10, 10)
    arrow:SetPoint("BOTTOM", tab, "BOTTOM", 0, 6)
    arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    arrow:SetRotation(math.pi / 2) -- Point left initially
    tab.arrow = arrow

    -- Hover highlight
    local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(tab)
    highlight:SetTexture(TEX_WHITE8X8)
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.2)

    -- Drag handlers for moving
    tab:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    tab:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, _, x, y = self:GetPoint()
        if HopeAddon.db and HopeAddon.db.settings then
            HopeAddon.db.settings.critterTabPosition = { point = point, x = x, y = y }
        end
    end)

    -- Click handler (only fires if not dragging)
    tab:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            -- Right-click to reset position
            CritterUI:ResetTabPosition()
        else
            CritterUI:ToggleHousing()
        end
    end)
    tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Tooltip
    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Crusade Critter", unpack(COLOR_GOLD))
        GameTooltip:AddLine("Left-click to toggle mascot", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-click to reset position", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.tabButton = tab
    return tab
end

--[[
    Reset the tab button to its default position
]]
function CritterUI:ResetTabPosition()
    if not self.tabButton then return end

    self.tabButton:ClearAllPoints()
    self.tabButton:SetPoint("RIGHT", UIParent, "RIGHT", -50, HOUSING_Y_OFFSET)

    -- Clear saved position
    if HopeAddon.db and HopeAddon.db.settings then
        HopeAddon.db.settings.critterTabPosition = nil
    end
end

--[[
    Update the tab icon based on current critter
]]
function CritterUI:UpdateTabIcon()
    if not self.tabButton or not self.tabButton.icon then return end

    local critterId = "chomp"
    if self.currentCritter and self.currentCritter.id then
        critterId = self.currentCritter.id
    elseif HopeAddon.db and HopeAddon.db.crusadeCritter then
        critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
    end

    local icon = CRITTER_ICONS[critterId] or CRITTER_ICONS.chomp
    self.tabButton.icon:SetTexture(icon)
end

--[[
    Update the arrow direction based on housing state
]]
function CritterUI:UpdateTabArrow()
    if not self.tabButton or not self.tabButton.arrow then return end

    if self.isHousingOpen then
        -- Point right when open (indicates "click to close")
        self.tabButton.arrow:SetRotation(-math.pi / 2)
    else
        -- Point left when closed (indicates "click to open")
        self.tabButton.arrow:SetRotation(math.pi / 2)
    end
end

--============================================================
-- HOUSING CONTAINER
--============================================================

--[[
    Create the housing container that slides out
    @return Frame - The housing container
]]
function CritterUI:CreateHousingContainer()
    if self.housingContainer then
        return self.housingContainer
    end

    local housing = CreateFrame("Frame", "HopeCrusadeCritterHousing", UIParent, "BackdropTemplate")
    housing:SetSize(HOUSING_WIDTH, HOUSING_HEIGHT)
    housing:SetFrameStrata("MEDIUM")
    housing:SetFrameLevel(100) -- Above tab (99) for proper layering

    -- Position off-screen initially (will slide in)
    housing:SetPoint("RIGHT", UIParent, "RIGHT", HOUSING_WIDTH + TAB_WIDTH, HOUSING_Y_OFFSET)

    -- Dark background with subtle border
    housing:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    housing:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    housing:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)

    -- Inner glow frame for critter
    local glowFrame = CreateFrame("Frame", nil, housing)
    glowFrame:SetSize(GLOW_SIZE, GLOW_SIZE)
    glowFrame:SetPoint("CENTER", housing, "CENTER", 0, 5)
    housing.glowFrame = glowFrame

    -- Soft glow behind model (pulsing)
    local glow = glowFrame:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetBlendMode("ADD")
    glow:SetAllPoints(glowFrame)
    glow:SetAlpha(0.6)
    housing.glow = glow

    -- Glow pulse animation
    local glowAG = glow:CreateAnimationGroup()
    glowAG:SetLooping("BOUNCE")
    local pulse = glowAG:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.4)
    pulse:SetToAlpha(0.7)
    pulse:SetDuration(1.5)
    pulse:SetSmoothing("IN_OUT")
    housing.glowAG = glowAG

    -- 3D Model frame
    local model = CreateFrame("PlayerModel", nil, housing)
    model:SetSize(MODEL_SIZE, MODEL_SIZE)
    model:SetPoint("CENTER", glowFrame, "CENTER", 0, 0)
    model:SetFrameLevel(101) -- Housing (100) + 1
    housing.model = model

    -- Click handler for critter selector
    model:EnableMouse(true)
    model:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            self:ToggleCritterSelector()
        end
    end)

    -- Tooltip on hover
    housing:EnableMouse(true)
    housing:SetScript("OnEnter", function()
        local critterData = self.currentCritter
        if critterData then
            GameTooltip:SetOwner(housing, "ANCHOR_LEFT")
            GameTooltip:AddLine(critterData.name, unpack(COLOR_GOLD))
            GameTooltip:AddLine(critterData.description, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click critter to select mascot", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end
    end)
    housing:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Housing is now attached to tab button, not independently draggable
    housing:SetClampedToScreen(true)

    housing:Hide()
    self.housingContainer = housing

    -- Also store reference in mascotFrame for backward compatibility
    self.mascotFrame = housing

    -- Create stats button
    self:CreateStatsButton()

    return housing
end

--============================================================
-- SLIDE ANIMATION
--============================================================

--[[
    Toggle the housing panel open/closed
]]
function CritterUI:ToggleHousing()
    if self.isHousingOpen then
        self:SlideHousingOut()
    else
        self:SlideHousingIn()
    end
end

--[[
    Slide the housing container in (visible)
]]
function CritterUI:SlideHousingIn()
    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    -- Cancel any existing animation
    if self.slideAnimation then
        HopeAddon.Animations:Stop(self.slideAnimation)
        self.slideAnimation = nil
    end

    self.isHousingOpen = true
    self:UpdateTabArrow()
    self:SaveHousingState()

    -- Position housing relative to tab button (attached below it)
    self.housingContainer:ClearAllPoints()
    if self.tabButton then
        -- Anchor housing to appear below and slightly left of the tab button
        self.housingContainer:SetPoint("TOPRIGHT", self.tabButton, "BOTTOMRIGHT", 0, -5)
    else
        -- Fallback to old position if tab doesn't exist
        self.housingContainer:SetPoint("RIGHT", UIParent, "RIGHT", -(TAB_WIDTH + HOUSING_OFFSET_X), HOUSING_Y_OFFSET)
    end

    -- Start hidden (alpha 0) and fade in
    self.housingContainer:SetAlpha(0)
    self.housingContainer:Show()

    -- Start glow animation
    if self.housingContainer.glowAG then
        self.housingContainer.glowAG:Play()
    end

    -- Fade in animation
    self.slideAnimation = HopeAddon.Animations:FadeTo(
        self.housingContainer,
        1,
        SLIDE_DURATION,
        function()
            self.slideAnimation = nil
            -- Start bobbing after fade completes
            self:StartBobbing()
            -- Start idle quip timer
            self:StartIdleQuipTimer()
            -- Show instance guide panel
            self:ShowInstanceGuidePanel()
        end
    )
end

--[[
    Slide the housing container out (hidden)
]]
function CritterUI:SlideHousingOut()
    if not self.housingContainer then return end

    -- Cancel any existing animation
    if self.slideAnimation then
        HopeAddon.Animations:Stop(self.slideAnimation)
        self.slideAnimation = nil
    end

    self.isHousingOpen = false
    self:UpdateTabArrow()
    self:SaveHousingState()

    -- Stop bobbing
    self:StopBobbing()

    -- Stop idle quip timer
    self:StopIdleQuipTimer()

    -- Hide speech bubble
    self:HideSpeechBubble()

    -- Hide critter selector if open
    self:HideCritterSelector()

    -- Hide instance guide panel
    self:HideInstanceGuidePanel()

    -- Fade out animation
    self.slideAnimation = HopeAddon.Animations:FadeTo(
        self.housingContainer,
        0,
        SLIDE_DURATION,
        function()
            self.slideAnimation = nil
            self.housingContainer:Hide()
            self.housingContainer:SetAlpha(1) -- Reset alpha for next show
            -- Stop glow animation
            if self.housingContainer.glowAG then
                self.housingContainer.glowAG:Stop()
            end
        end
    )
end

--[[
    Save housing open/closed state to database
]]
function CritterUI:SaveHousingState()
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        HopeAddon.db.crusadeCritter.housingOpen = self.isHousingOpen
    end
end

--[[
    Save housing position to database
]]
function CritterUI:SaveHousingPosition()
    -- Housing is now attached to tab button, position is controlled by tab position
    -- This function is kept for backward compatibility but does nothing
end

--[[
    Reset housing position to default (anchored to tab button)
]]
function CritterUI:ResetHousingPosition()
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        HopeAddon.db.crusadeCritter.housingPosition = nil
    end
    if self.housingContainer and self.tabButton then
        self.housingContainer:ClearAllPoints()
        self.housingContainer:SetPoint("TOPRIGHT", self.tabButton, "BOTTOMRIGHT", 0, -5)
    end
end

--[[
    Load housing state from database
]]
function CritterUI:LoadHousingState()
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        return HopeAddon.db.crusadeCritter.housingOpen or false
    end
    return false
end

--============================================================
-- COMBAT AUTO-HIDE
--============================================================

--[[
    Handle combat start - hide housing
]]
function CritterUI:OnCombatStart()
    if self.isHousingOpen then
        self.wasOpenBeforeCombat = true
        self:SlideHousingOut()
    end

    -- Also hide the tab during combat
    if self.tabButton then
        self.tabButton:Hide()
    end
end

--[[
    Handle combat end - restore housing if it was open
]]
function CritterUI:OnCombatEnd()
    -- Show the tab again
    if self.tabButton then
        self.tabButton:Show()
    end

    -- Restore housing if it was open before combat
    if self.wasOpenBeforeCombat then
        self.wasOpenBeforeCombat = false
        -- Small delay to let combat fully end
        if HopeAddon.Timer then
            HopeAddon.Timer:After(0.5, function()
                self:SlideHousingIn()
            end)
        else
            self:SlideHousingIn()
        end
    end
end

--============================================================
-- CRITTER SELECTOR POPUP
--============================================================

--[[
    Create the critter selector popup
    @return Frame - The selector popup
]]
function CritterUI:CreateCritterSelector()
    if self.selectorPopup then
        return self.selectorPopup
    end

    -- Ensure housing container exists before creating selector
    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    local popup = CreateFrame("Frame", "HopeCrusadeCritterSelector", self.housingContainer, "BackdropTemplate")
    popup:SetSize(220, 180)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(200)

    -- Position to the left of housing
    popup:SetPoint("RIGHT", self.housingContainer, "LEFT", -10, 0)

    -- Dark background with gold border
    popup:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    popup:SetBackdropColor(unpack(COLOR_DARK_BG))
    popup:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    title:SetPoint("TOP", popup, "TOP", 0, -10)
    title:SetText("Select Mascot")
    title:SetTextColor(unpack(COLOR_GOLD))
    popup.title = title

    -- Critter grid container
    local grid = CreateFrame("Frame", nil, popup)
    grid:SetSize(200, 130)
    grid:SetPoint("TOP", title, "BOTTOM", 0, -8)
    popup.grid = grid

    -- Close on click outside
    popup:EnableMouse(true)
    popup:SetScript("OnShow", function()
        self:PopulateCritterSelector()
    end)

    popup:Hide()
    self.selectorPopup = popup
    return popup
end

--[[
    Populate the critter selector with icons
]]
function CritterUI:PopulateCritterSelector()
    if not self.selectorPopup or not self.selectorPopup.grid then return end

    local grid = self.selectorPopup.grid
    local Content = HopeAddon.CritterContent
    local Critter = HopeAddon.CrusadeCritter

    if not Content then return end

    -- Initialize icons table once (reused across calls)
    if not grid.icons then
        grid.icons = {}
    end

    local critterOrder = { "chomp", "snookimp", "shred", "emo", "cosmo", "boomer", "diva" }
    local iconSize = 40
    local spacing = 8
    local cols = 4
    local startX = 8
    local startY = -5

    local btnIndex = 0
    for i, critterId in ipairs(critterOrder) do
        local critterData = Content.CRITTERS[critterId]
        if critterData then
            btnIndex = btnIndex + 1
            local row = math.floor((i - 1) / cols)
            local col = (i - 1) % cols

            -- Reuse existing button or create a new one
            local btn = grid.icons[btnIndex]
            if not btn then
                btn = CreateFrame("Button", nil, grid)
                -- Create all sub-regions once (reused via Show/Hide)
                local tex = btn:CreateTexture(nil, "ARTWORK")
                tex:SetAllPoints(btn)
                tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                btn.icon = tex

                local highlight = btn:CreateTexture(nil, "OVERLAY")
                highlight:SetAllPoints(btn)
                highlight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                highlight:SetBlendMode("ADD")
                btn.selectedHighlight = highlight

                local hover = btn:CreateTexture(nil, "HIGHLIGHT")
                hover:SetAllPoints(btn)
                hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
                hover:SetBlendMode("ADD")

                local bg = btn:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints(btn)
                btn.lockedBg = bg

                local mystery = btn:CreateFontString(nil, "ARTWORK")
                mystery:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
                mystery:SetPoint("CENTER", btn, "CENTER", 0, 0)
                btn.mystery = mystery

                local lock = btn:CreateTexture(nil, "OVERLAY")
                lock:SetSize(14, 14)
                lock:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
                lock:SetTexture("Interface\\LFGFRAME\\LFG-Eye")
                btn.lock = lock

                grid.icons[btnIndex] = btn
            end

            btn:SetSize(iconSize, iconSize)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", grid, "TOPLEFT", startX + col * (iconSize + spacing), startY - row * (iconSize + spacing))

            -- Check if unlocked
            local isUnlocked = Critter and Critter:IsCritterUnlocked(critterId)
            local isSelected = HopeAddon.db and HopeAddon.db.crusadeCritter and
                               HopeAddon.db.crusadeCritter.selectedCritter == critterId

            if isUnlocked then
                -- Show icon, hide locked elements
                btn.icon:SetTexture(CRITTER_ICONS[critterId] or CRITTER_ICONS.chomp)
                btn.icon:SetDesaturated(false)
                btn.icon:SetVertexColor(1, 1, 1, 1)
                btn.icon:Show()
                btn.lockedBg:Hide()
                btn.mystery:Hide()
                btn.lock:Hide()

                -- Selection highlight
                if isSelected then
                    btn.selectedHighlight:SetVertexColor(1, 0.84, 0, 0.8)
                    btn.selectedHighlight:Show()
                else
                    btn.selectedHighlight:Hide()
                end

                -- Click to select
                btn:SetScript("OnClick", function()
                    self:SelectCritter(critterId)
                end)
            else
                -- Hide unlocked elements, show locked elements
                btn.icon:Hide()
                btn.selectedHighlight:Hide()
                btn.lockedBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
                btn.lockedBg:Show()
                btn.mystery:SetText("?")
                btn.mystery:SetTextColor(0.6, 0.6, 0.6)
                btn.mystery:Show()
                btn.lock:SetVertexColor(0.8, 0.2, 0.2, 1)
                btn.lock:Show()

                -- No click action for locked critters
                btn:SetScript("OnClick", nil)
            end

            -- Tooltip
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                if isUnlocked then
                    GameTooltip:AddLine(critterData.name, unpack(COLOR_GOLD))
                    GameTooltip:AddLine(critterData.description, 1, 1, 1, true)
                    if isSelected then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("Currently selected", 0.3, 1, 0.3)
                    end
                else
                    -- Mystery tooltip for locked critters
                    GameTooltip:AddLine("???", unpack(COLOR_GOLD))
                    GameTooltip:AddLine("Mystery Critter", 0.7, 0.7, 0.7)
                    GameTooltip:AddLine(" ")
                    local unlockLevel = critterData.unlockLevel or 1
                    GameTooltip:AddLine(string.format("Unlocks at Level %d", unlockLevel), 1, 0.5, 0)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btn:Show()
        end
    end

    -- Hide any excess buttons from a previous population (in case critterOrder shrinks)
    for j = btnIndex + 1, #grid.icons do
        grid.icons[j]:Hide()
    end
end

--[[
    Toggle the critter selector visibility
]]
function CritterUI:ToggleCritterSelector()
    if not self.selectorPopup then
        self:CreateCritterSelector()
    end

    if self.selectorPopup:IsShown() then
        self:HideCritterSelector()
    else
        self:ShowCritterSelector()
    end
end

--[[
    Show the critter selector
]]
function CritterUI:ShowCritterSelector()
    if not self.selectorPopup then
        self:CreateCritterSelector()
    end

    -- Position relative to housing
    if self.housingContainer then
        self.selectorPopup:ClearAllPoints()
        self.selectorPopup:SetPoint("RIGHT", self.housingContainer, "LEFT", -10, 0)
    end

    self.selectorPopup:Show()

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeIn(self.selectorPopup, 0.2)
    end
end

--[[
    Hide the critter selector
]]
function CritterUI:HideCritterSelector()
    if not self.selectorPopup then return end

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(self.selectorPopup, 0.2)
    else
        self.selectorPopup:Hide()
    end
end

--[[
    Select a critter and update the display
    @param critterId string - The critter to select
]]
function CritterUI:SelectCritter(critterId)
    if HopeAddon.CrusadeCritter then
        if HopeAddon.CrusadeCritter:SetSelectedCritter(critterId) then
            -- Update display
            self:SetCritter(critterId)
            self:UpdateTabIcon()

            -- Refresh boss tips panel if showing
            if self.bossTipsPanel and self.bossTipsPanel:IsShown() and self.bossTipsState then
                self:ShowBossTips(self.bossTipsState.bossKey, self.bossTipsState.bossName)
            end

            -- Refresh guide panel tooltip if visible
            if self.tipTooltip and self.tipTooltip:IsShown() then
                self:HideBossTipTooltip()
            end

            -- Hide selector
            self:HideCritterSelector()

            -- Play a sound
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlaySuccess()
            end
        end
    end
end

--============================================================
-- MASCOT DISPLAY (Modified for housing)
--============================================================

--[[
    Set the critter model and glow color
    @param critterId string - Critter ID from CritterContent
]]
function CritterUI:SetCritter(critterId)
    if not HopeAddon.CritterContent then
        HopeAddon:Debug("CritterUI: CritterContent not loaded")
        return
    end

    local critterData = HopeAddon.CritterContent:GetCritter(critterId)
    if not critterData then
        HopeAddon:Debug("CritterUI: Unknown critter ID: " .. tostring(critterId))
        return
    end

    -- Store critter data with ID
    self.currentCritter = critterData
    self.currentCritter.id = critterId

    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    -- Validate housingContainer is a valid frame (defensive check)
    if type(self.housingContainer) ~= "table" then
        HopeAddon:Debug("CritterUI: Invalid housingContainer type: " .. type(self.housingContainer))
        self.housingContainer = nil  -- Reset so next call recreates
        return
    end

    local model = self.housingContainer and self.housingContainer.model
    local glow = self.housingContainer and self.housingContainer.glow

    -- Set 3D model using displayID (TBC compatible)
    if critterData.displayID and model and type(model) == "table" then
        model:ClearModel()              -- Reset model state first
        model:Show()                    -- CRITICAL: Show BEFORE setting display!
        model:SetDisplayInfo(critterData.displayID)
        model:SetCamera(1)              -- Full body camera (not portrait/face zoom)
        -- Apply per-critter Z offset for zoom adjustment (negative = zoomed out)
        local zOffset = critterData.modelOffset or 0
        model:SetPosition(0, 0, zOffset)
        model:SetFacing(0)
        -- Enable lighting so model isn't black/invisible
        -- TBC SetLight: enabled, omni, dirX, dirY, dirZ, ambInt, ambR, ambG, ambB, dirInt, dirR, dirG, dirB
        if type(model.SetLight) == "function" then
            pcall(model.SetLight, model, true, false, 0, -0.707, -0.707, 0.8, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 1.0)
        end
    end

    -- Set glow color
    if critterData.glowColor and glow then
        local c = critterData.glowColor
        glow:SetVertexColor(c.r, c.g, c.b, 1)
    end

    -- Update tab icon
    self:UpdateTabIcon()

    -- Play creature sound
    if critterData.soundOnAppear then
        PlaySoundFile(critterData.soundOnAppear, "SFX")
    end
end

--[[
    Show the mascot (creates UI if needed, opens housing if closed)
]]
function CritterUI:ShowMascot()
    -- Create tab and housing if needed
    if not self.tabButton then
        self:CreateTabButton()
    end
    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    -- Show tab
    self.tabButton:Show()

    -- Load saved state and open if it was open
    if self:LoadHousingState() then
        self:SlideHousingIn()
    end

    -- Update tab icon
    self:UpdateTabIcon()
end

--[[
    Hide the mascot
]]
function CritterUI:HideMascot()
    -- Stop bobbing
    self:StopBobbing()

    -- Hide speech bubble
    self:HideSpeechBubble()

    -- Hide housing
    if self.housingContainer then
        if self.housingContainer.glowAG then
            self.housingContainer.glowAG:Stop()
        end
        self.housingContainer:Hide()
    end

    -- Hide tab
    if self.tabButton then
        self.tabButton:Hide()
    end

    -- Hide selector
    self:HideCritterSelector()

    -- Hide instance guide panel
    self:HideInstanceGuidePanel()

    self.isHousingOpen = false
end

--[[
    Start gentle bobbing animation
]]
function CritterUI:StartBobbing()
    if self.bobbingTicker then return end
    if not HopeAddon.Timer then return end
    if not self.housingContainer or not self.housingContainer.model then return end

    local elapsed = 0
    local model = self.housingContainer.model
    local glowFrame = self.housingContainer.glowFrame
    local startY = 0

    self.bobbingTicker = HopeAddon.Timer:NewTicker(0.033, function()
        elapsed = elapsed + 0.033
        local progress = (elapsed % BOB_PERIOD) / BOB_PERIOD
        local offset = math.sin(progress * 2 * math.pi) * BOB_AMPLITUDE

        if model then
            model:SetPoint("CENTER", glowFrame, "CENTER", 0, startY + offset)
        end
    end)
end

--[[
    Stop bobbing animation
]]
function CritterUI:StopBobbing()
    if self.bobbingTicker then
        self.bobbingTicker:Cancel()
        self.bobbingTicker = nil
    end
end

--[[
    Pause bobbing during combat (optional setting)
]]
function CritterUI:PauseBobbing()
    self:StopBobbing()
    if self.housingContainer and self.housingContainer.model then
        self.housingContainer.model:SetPaused(true)
    end
end

--[[
    Resume bobbing after combat
]]
function CritterUI:ResumeBobbing()
    if self.housingContainer and self.housingContainer.model then
        self.housingContainer.model:SetPaused(false)
    end
    if self.isHousingOpen then
        self:StartBobbing()
    end
end

--============================================================
-- SPEECH BUBBLE (Anchored to housing container)
--============================================================

--[[
    Create the speech bubble frame (classic comic style)
    @return Frame - The speech bubble
]]
function CritterUI:CreateSpeechBubble()
    if self.speechBubble then
        return self.speechBubble
    end

    -- Ensure housing container exists before creating speech bubble
    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    local bubble = CreateFrame("Frame", nil, self.housingContainer, "BackdropTemplate")
    bubble:SetSize(BUBBLE_WIDTH, 60) -- Height will adjust to text

    -- Classic comic book style: white background, black border
    bubble:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    bubble:SetBackdropColor(1, 1, 1, 0.95) -- White background
    bubble:SetBackdropBorderColor(0, 0, 0, 1) -- Black border

    -- Position above and to the left of housing container
    if self.housingContainer then
        bubble:SetPoint("BOTTOMRIGHT", self.housingContainer, "TOPLEFT", 20, -10)
    end

    -- Text
    local text = bubble:CreateFontString(nil, "OVERLAY")
    text:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    text:SetPoint("TOPLEFT", bubble, "TOPLEFT", BUBBLE_PADDING, -BUBBLE_PADDING)
    text:SetPoint("TOPRIGHT", bubble, "TOPRIGHT", -BUBBLE_PADDING, -BUBBLE_PADDING)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)
    text:SetTextColor(0.1, 0.1, 0.1, 1) -- Dark text on white
    bubble.text = text

    -- Tail pointing toward housing (simple triangle using textures)
    local tail = bubble:CreateTexture(nil, "ARTWORK")
    tail:SetTexture(TEX_WHITE8X8)
    tail:SetVertexColor(1, 1, 1, 0.95)
    tail:SetSize(16, 10)
    tail:SetPoint("TOPLEFT", bubble, "BOTTOMRIGHT", -30, 2)
    bubble.tail = tail

    bubble:SetFrameStrata("HIGH")
    bubble:SetFrameLevel(200)
    bubble:Hide()

    self.speechBubble = bubble
    return bubble
end

--[[
    Show a speech bubble with text (typewriter effect)
    @param message string - The message to display
    @param duration number - How long to show (default 5 sec)
    @param callback function - Called when bubble hides
]]
function CritterUI:ShowSpeechBubble(message, duration, callback)
    -- Only show if housing is open
    if not self.isHousingOpen then
        return
    end

    if not self.speechBubble then
        self:CreateSpeechBubble()
    end

    duration = duration or BUBBLE_DURATION

    -- Cancel existing timer
    if self.bubbleTimer then
        self.bubbleTimer:Cancel()
        self.bubbleTimer = nil
    end

    local bubble = self.speechBubble
    local text = bubble.text

    -- Re-anchor to housing container
    if self.housingContainer then
        bubble:SetParent(self.housingContainer)
        bubble:ClearAllPoints()
        bubble:SetPoint("BOTTOMRIGHT", self.housingContainer, "TOPLEFT", 20, -10)
    end

    -- Temporarily set full text to measure height
    text:SetText(message)
    local textHeight = text:GetStringHeight()
    local bubbleHeight = textHeight + (BUBBLE_PADDING * 2) + 4
    bubble:SetHeight(math.max(50, bubbleHeight))

    -- Clear text before animation
    text:SetText("")

    -- Cancel any existing bounce animation
    if self.bubbleBounceAnim then
        self.bubbleBounceAnim:Cancel()
        self.bubbleBounceAnim = nil
    end

    -- Bouncy pop-in animation
    if HopeAddon.Effects then
        self.bubbleBounceAnim = HopeAddon.Effects:BounceIn(bubble, 0.35, function()
            self.bubbleBounceAnim = nil
        end)
    else
        bubble:Show()
        bubble:SetAlpha(1)
    end

    -- Typewriter effect
    if HopeAddon.Effects then
        HopeAddon.Effects:TypewriterText(text, message, 0.03, function()
            -- Text complete, set timer to hide
            if HopeAddon.Timer then
                self.bubbleTimer = HopeAddon.Timer:After(duration - 1, function()
                    self:HideSpeechBubble(callback)
                end)
            end
        end)
    else
        text:SetText(message)
    end
end

--[[
    Hide the speech bubble
    @param callback function - Called after hide
]]
function CritterUI:HideSpeechBubble(callback)
    if not self.speechBubble then return end

    -- Cancel bounce animation if still running
    if self.bubbleBounceAnim then
        self.bubbleBounceAnim:Cancel()
        self.bubbleBounceAnim = nil
    end

    if self.bubbleTimer then
        self.bubbleTimer:Cancel()
        self.bubbleTimer = nil
    end

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(self.speechBubble, 0.3, callback)
    else
        self.speechBubble:Hide()
        if callback then callback() end
    end
end

--============================================================
-- IDLE QUIP TIMER SYSTEM
--============================================================

local IDLE_QUIP_INTERVAL = 30 -- Seconds between idle quips

--[[
    Start the idle quip timer (triggers random quips when housing is open)
]]
function CritterUI:StartIdleQuipTimer()
    -- Cancel existing timer if any
    self:StopIdleQuipTimer()

    if not HopeAddon.Timer then
        return
    end

    self.idleQuipTimer = HopeAddon.Timer:NewTicker(IDLE_QUIP_INTERVAL, function()
        -- Only trigger if housing is still open and not in combat
        if self.isHousingOpen and not UnitAffectingCombat("player") then
            self:TriggerIdleQuip()
        end
    end)

    HopeAddon:Debug("Idle quip timer started")
end

--[[
    Stop the idle quip timer
]]
function CritterUI:StopIdleQuipTimer()
    if self.idleQuipTimer then
        self.idleQuipTimer:Cancel()
        self.idleQuipTimer = nil
        HopeAddon:Debug("Idle quip timer stopped")
    end
end

--[[
    Trigger a random idle quip from the current critter
]]
function CritterUI:TriggerIdleQuip()
    -- Don't trigger if speech bubble is already showing
    if self.speechBubble and self.speechBubble:IsShown() then
        return
    end

    -- Get current critter ID
    local critterId = "chomp"
    if self.currentCritter and self.currentCritter.id then
        critterId = self.currentCritter.id
    elseif HopeAddon.db and HopeAddon.db.crusadeCritter then
        critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
    end

    -- Get random idle quip
    if HopeAddon.CritterContent then
        local quip = HopeAddon.CritterContent:GetQuip(critterId, "idle")
        if quip then
            self:ShowSpeechBubble(quip, 5)
            HopeAddon:Debug("Idle quip triggered: " .. quip)
        end
    end
end

--============================================================
-- BOSS KILL POPUP
--============================================================

--[[
    Create the boss kill popup (5 sec, shows quip + 2-bar chart)
    @return Frame - The popup frame
]]
function CritterUI:CreateBossPopup()
    if self.bossPopup then
        return self.bossPopup
    end

    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(300, 140)
    popup:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    popup:SetBackdropColor(unpack(COLOR_DARK_BG))
    popup:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    popup:SetFrameStrata("HIGH")
    popup:SetClampedToScreen(true)

    -- Title (boss name)
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    title:SetPoint("TOP", popup, "TOP", 0, -10)
    title:SetTextColor(unpack(COLOR_GOLD))
    popup.title = title

    -- Chart container
    local chartContainer = CreateFrame("Frame", nil, popup)
    chartContainer:SetSize(260, 60)
    chartContainer:SetPoint("TOP", title, "BOTTOM", 0, -10)
    popup.chartContainer = chartContainer

    -- Position near housing
    popup:SetPoint("LEFT", UIParent, "CENTER", 100, 0)

    popup:Hide()
    self.bossPopup = popup
    return popup
end

--[[
    Show boss kill popup with time comparison
    @param bossName string - Name of the boss
    @param thisTime number - This kill time in seconds
    @param bestTime number - Best kill time in seconds
    @param quip string - Critter quip to show
]]
function CritterUI:ShowBossPopup(bossName, thisTime, bestTime, quip)
    if not self.bossPopup then
        self:CreateBossPopup()
    end

    local popup = self.bossPopup
    popup.title:SetText(bossName)

    -- Clear old chart
    if popup.chart then
        self:CleanupChart(popup.chart)
        popup.chart = nil
    end

    -- Create time comparison chart
    if HopeAddon.Charts then
        local chartData = {
            { label = "This", timeSeconds = thisTime, color = HopeAddon.colors.TBC_PURPLE },
            { label = "Best", timeSeconds = bestTime or thisTime, color = HopeAddon.colors.TBC_GREEN },
        }

        local chart = HopeAddon.Charts:CreateTimeComparisonChart(popup.chartContainer, 260, chartData)
        chart:SetPoint("TOP", popup.chartContainer, "TOP", 0, 0)
        popup.chart = chart
    end

    -- Position near housing if visible
    if self.housingContainer and self.isHousingOpen then
        popup:ClearAllPoints()
        popup:SetPoint("RIGHT", self.housingContainer, "LEFT", -20, 30)
    end

    popup:Show()
    if HopeAddon.Effects then
        HopeAddon.Effects:FadeIn(popup, 0.3)
    end

    -- Show quip in speech bubble
    if quip then
        self:ShowSpeechBubble(quip, POPUP_DURATION)
    end

    -- Auto-hide after duration
    if HopeAddon.Timer then
        -- Cancel existing timer if any
        if self.bossPopupTimer then
            self.bossPopupTimer:Cancel()
        end
        self.bossPopupTimer = HopeAddon.Timer:After(POPUP_DURATION, function()
            self.bossPopupTimer = nil
            if HopeAddon.Effects then
                HopeAddon.Effects:FadeOut(popup, 0.3)
            else
                popup:Hide()
            end
        end)
    end
end

--[[
    Clean up chart frame properly
    @param chartFrame Frame - The chart to clean up
]]
function CritterUI:CleanupChart(chartFrame)
    if not chartFrame then return end
    chartFrame:Hide()
    chartFrame:ClearAllPoints()
    chartFrame:SetParent(nil)
end

--============================================================
-- STATS WINDOW (End of Run)
--============================================================

--[[
    Create the end-of-run stats window
    @return Frame - The stats window
]]
function CritterUI:CreateStatsWindow()
    if self.statsWindow then
        return self.statsWindow
    end

    local window = CreateFrame("Frame", "HopeCrusadeCritterStats", UIParent, "BackdropTemplate")
    window:SetSize(450, 280)
    window:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    window:SetBackdropColor(unpack(COLOR_DARK_BG))
    window:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    window:SetFrameStrata("DIALOG")
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    window:SetClampedToScreen(true)

    -- Title
    local title = window:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 16, "")
    title:SetPoint("TOP", window, "TOP", 0, -15)
    title:SetText("DUNGEON COMPLETE!")
    title:SetTextColor(unpack(COLOR_GOLD))
    window.title = title

    -- Decorative line
    local line = window:CreateTexture(nil, "ARTWORK")
    line:SetTexture(HopeAddon.assets.textures.SOLID)
    line:SetSize(350, 1)
    line:SetPoint("TOP", title, "BOTTOM", 0, -8)
    line:SetVertexColor(1, 0.84, 0, 0.5)

    -- Left section: Stats
    local statsContainer = CreateFrame("Frame", nil, window)
    statsContainer:SetSize(200, 180)
    statsContainer:SetPoint("TOPLEFT", window, "TOPLEFT", 20, -50)
    window.statsContainer = statsContainer

    -- Stats labels
    local statsY = 0
    local function AddStatLine(label, valueKey)
        local labelText = statsContainer:CreateFontString(nil, "OVERLAY")
        labelText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
        labelText:SetPoint("TOPLEFT", statsContainer, "TOPLEFT", 0, statsY)
        labelText:SetText(label)
        labelText:SetTextColor(unpack(COLOR_LABEL_GRAY))

        local valueText = statsContainer:CreateFontString(nil, "OVERLAY")
        valueText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
        valueText:SetPoint("TOPRIGHT", statsContainer, "TOPRIGHT", 0, statsY)
        valueText:SetTextColor(1, 1, 1)

        window[valueKey] = valueText
        statsY = statsY - 22
    end

    AddStatLine("Total Time:", "totalTimeText")
    AddStatLine("Last Run:", "lastTimeText")
    AddStatLine("Best Run:", "bestTimeText")
    AddStatLine("Bosses:", "bossCountText")

    -- Chart container (below stats)
    local chartContainer = CreateFrame("Frame", nil, statsContainer)
    chartContainer:SetSize(200, 80)
    chartContainer:SetPoint("TOP", statsContainer, "TOP", 0, -100)
    window.chartContainer = chartContainer

    -- Right section: Critter + bubble area (reserved)
    local critterArea = CreateFrame("Frame", nil, window)
    critterArea:SetSize(180, 180)
    critterArea:SetPoint("TOPRIGHT", window, "TOPRIGHT", -20, -50)
    window.critterArea = critterArea

    -- Quip text in critter area
    local quipText = critterArea:CreateFontString(nil, "OVERLAY")
    quipText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    quipText:SetPoint("TOP", critterArea, "TOP", 0, -10)
    quipText:SetWidth(160)
    quipText:SetJustifyH("CENTER")
    quipText:SetWordWrap(true)
    quipText:SetTextColor(0.9, 0.9, 0.9)
    window.quipText = quipText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", window, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        CritterUI:HideStatsWindow()
    end)

    -- Bottom close label
    local closeLabel = window:CreateFontString(nil, "OVERLAY")
    closeLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    closeLabel:SetPoint("BOTTOM", window, "BOTTOM", 0, 10)
    closeLabel:SetText("Click X to close")
    closeLabel:SetTextColor(0.5, 0.5, 0.5)

    window:Hide()
    self.statsWindow = window
    return window
end

--[[
    Show end-of-run stats window
    @param stats table - { thisTime, lastTime, bestTime, bossCount, totalBosses, dungeonName }
    @param quip string - Critter quip based on performance
]]
function CritterUI:ShowStatsWindow(stats, quip)
    if not self.statsWindow then
        self:CreateStatsWindow()
    end

    local window = self.statsWindow

    -- Update title with dungeon name
    if stats.dungeonName then
        window.title:SetText(stats.dungeonName .. " COMPLETE!")
    else
        window.title:SetText("DUNGEON COMPLETE!")
    end

    -- Format times using Charts helper if available
    local function formatTime(seconds)
        if HopeAddon.Charts then
            return HopeAddon.Charts:FormatTimeVerbose(seconds)
        elseif seconds then
            local mins = math.floor(seconds / 60)
            local secs = math.floor(seconds % 60)
            return string.format("%d:%02d", mins, secs)
        else
            return "N/A"
        end
    end

    window.totalTimeText:SetText(formatTime(stats.thisTime))
    window.lastTimeText:SetText(stats.lastTime and formatTime(stats.lastTime) or "N/A")
    window.bestTimeText:SetText(stats.bestTime and formatTime(stats.bestTime) or "N/A")
    window.bossCountText:SetText(string.format("%d/%d", stats.bossCount or 0, stats.totalBosses or 0))

    -- Clear old chart
    if window.chart then
        self:CleanupChart(window.chart)
        window.chart = nil
    end

    -- Create 3-bar comparison chart
    if HopeAddon.Charts then
        local chartData = {
            { label = "This", timeSeconds = stats.thisTime or 0, color = HopeAddon.colors.TBC_PURPLE },
            { label = "Last", timeSeconds = stats.lastTime or 0, color = { r = 0.5, g = 0.5, b = 0.5 } },
            { label = "Best", timeSeconds = stats.bestTime or stats.thisTime or 0, color = HopeAddon.colors.TBC_GREEN },
        }

        local chart = HopeAddon.Charts:CreateTimeComparisonChart(window.chartContainer, 200, chartData)
        chart:SetPoint("TOP", window.chartContainer, "TOP", 0, 0)
        window.chart = chart
    end

    -- Set quip
    window.quipText:SetText(quip or "")

    window:Show()
    if HopeAddon.Effects then
        HopeAddon.Effects:PopIn(window, 0.4)
    end

    -- Play victory sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayVictory()
    end
end

--[[
    Hide stats window
]]
function CritterUI:HideStatsWindow()
    if not self.statsWindow then return end
    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(self.statsWindow, 0.3)
    else
        self.statsWindow:Hide()
    end
end

--============================================================
-- COMBINED STATS + COMMENTARY WINDOW (New unified post-combat UI)
--============================================================

--[[
    Create the combined stats window showing boss kill info + critter commentary
    @return Frame - The combined stats window
]]
function CritterUI:CreateCombinedStatsWindow()
    if self.combinedStatsWindow then
        return self.combinedStatsWindow
    end

    local C = HopeAddon.Constants

    local window = CreateFrame("Frame", "HopeCrusadeCritterCombinedStats", UIParent, "BackdropTemplate")
    window:SetSize(COMBINED_STATS_WIDTH, COMBINED_STATS_HEIGHT)
    window:SetBackdrop(C.BACKDROPS and C.BACKDROPS.DARK_GOLD or {
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    window:SetBackdropColor(unpack(COLOR_DARK_BG))
    window:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    window:SetFrameStrata("HIGH")
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    window:SetClampedToScreen(true)

    -- Boss icon (left side)
    local bossIcon = window:CreateTexture(nil, "ARTWORK")
    bossIcon:SetSize(40, 40)
    bossIcon:SetPoint("TOPLEFT", window, "TOPLEFT", 15, -15)
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    window.bossIcon = bossIcon

    -- Boss name header
    local bossName = window:CreateFontString(nil, "OVERLAY")
    bossName:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    bossName:SetPoint("LEFT", bossIcon, "RIGHT", 10, 0)
    bossName:SetPoint("RIGHT", window, "RIGHT", -15, 0)
    bossName:SetJustifyH("LEFT")
    bossName:SetTextColor(unpack(COLOR_GOLD))
    window.bossName = bossName

    -- "DEFEATED" subtitle
    local defeatedText = window:CreateFontString(nil, "OVERLAY")
    defeatedText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    defeatedText:SetPoint("TOPLEFT", bossName, "BOTTOMLEFT", 0, -2)
    defeatedText:SetText("DEFEATED")
    defeatedText:SetTextColor(unpack(COLOR_LABEL_GRAY))
    window.defeatedText = defeatedText

    -- Decorative line
    local line = window:CreateTexture(nil, "ARTWORK")
    line:SetTexture(HopeAddon.assets.textures.SOLID or TEX_WHITE8X8)
    line:SetSize(COMBINED_STATS_WIDTH - 30, 1)
    line:SetPoint("TOP", window, "TOP", 0, -65)
    line:SetVertexColor(1, 0.84, 0, 0.5)

    -- Time stats section
    local statsY = -75

    -- This Kill time
    local thisLabel = window:CreateFontString(nil, "OVERLAY")
    thisLabel:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    thisLabel:SetPoint("TOPLEFT", window, "TOPLEFT", 20, statsY)
    thisLabel:SetText("This Kill:")
    thisLabel:SetTextColor(unpack(COLOR_LABEL_GRAY))

    local thisTime = window:CreateFontString(nil, "OVERLAY")
    thisTime:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    thisTime:SetPoint("LEFT", thisLabel, "RIGHT", 5, 0)
    thisTime:SetTextColor(1, 1, 1)
    window.thisTime = thisTime

    -- Best time
    local bestLabel = window:CreateFontString(nil, "OVERLAY")
    bestLabel:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    bestLabel:SetPoint("TOPLEFT", window, "TOPLEFT", 160, statsY)
    bestLabel:SetText("Best:")
    bestLabel:SetTextColor(unpack(COLOR_LABEL_GRAY))

    local bestTime = window:CreateFontString(nil, "OVERLAY")
    bestTime:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    bestTime:SetPoint("LEFT", bestLabel, "RIGHT", 5, 0)
    bestTime:SetTextColor(0.2, 0.8, 0.2)
    window.bestTime = bestTime

    -- Time comparison bar
    local barContainer = CreateFrame("Frame", nil, window)
    barContainer:SetSize(280, 16)
    barContainer:SetPoint("TOP", window, "TOP", 0, statsY - 20)
    window.barContainer = barContainer

    -- Bar background
    local barBg = barContainer:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints(barContainer)
    barBg:SetTexture(TEX_WHITE8X8)
    barBg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    barContainer.bg = barBg

    -- This kill bar (purple)
    local thisBar = barContainer:CreateTexture(nil, "ARTWORK")
    thisBar:SetHeight(16)
    thisBar:SetPoint("LEFT", barContainer, "LEFT", 0, 0)
    thisBar:SetTexture(TEX_WHITE8X8)
    thisBar:SetVertexColor(0.61, 0.19, 1.00, 1)
    window.thisBar = thisBar

    -- Best time marker
    local bestMarker = barContainer:CreateTexture(nil, "OVERLAY")
    bestMarker:SetSize(2, 20)
    bestMarker:SetTexture(TEX_WHITE8X8)
    bestMarker:SetVertexColor(0.2, 0.8, 0.2, 1)
    window.bestMarker = bestMarker

    -- Critter commentary box
    local quoteBox = CreateFrame("Frame", nil, window, "BackdropTemplate")
    quoteBox:SetSize(280, 50)
    quoteBox:SetPoint("TOP", barContainer, "BOTTOM", 0, -15)
    quoteBox:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    quoteBox:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    quoteBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
    window.quoteBox = quoteBox

    -- Quote text
    local quoteText = quoteBox:CreateFontString(nil, "OVERLAY")
    quoteText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    quoteText:SetPoint("TOPLEFT", quoteBox, "TOPLEFT", 8, -6)
    quoteText:SetPoint("BOTTOMRIGHT", quoteBox, "BOTTOMRIGHT", -8, 6)
    quoteText:SetJustifyH("CENTER")
    quoteText:SetJustifyV("TOP")
    quoteText:SetWordWrap(true)
    quoteText:SetTextColor(0.9, 0.9, 0.9)
    window.quoteText = quoteText

    -- Critter attribution
    local attribution = quoteBox:CreateFontString(nil, "OVERLAY")
    attribution:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    attribution:SetPoint("BOTTOMRIGHT", quoteBox, "BOTTOMRIGHT", -8, 4)
    attribution:SetTextColor(0.6, 0.6, 0.6)
    window.attribution = attribution

    -- "Learn Next Boss" button
    local learnBtn = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    learnBtn:SetSize(140, 24)
    learnBtn:SetPoint("BOTTOM", window, "BOTTOM", 0, 15)
    learnBtn:SetText("\226\150\182 Learn Next Boss") -- Unicode play symbol
    learnBtn:SetScript("OnClick", function()
        self:HideCombinedStats()
        if HopeAddon.CrusadeCritter then
            local nextBoss = HopeAddon.CrusadeCritter:GetNextBossForTips()
            if nextBoss then
                self:ShowBossTips(nextBoss.key, nextBoss.name)
            end
        end
    end)
    learnBtn:Hide() -- Shown after delay
    window.learnBtn = learnBtn

    -- Close button
    local closeBtn = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", window, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        CritterUI:HideCombinedStats()
    end)

    window:Hide()
    self.combinedStatsWindow = window
    return window
end

--[[
    Show the combined stats window after boss kill
    @param bossData table - { name, key, npcId, isFinal }
    @param killTime number - Time to kill this boss
    @param bestTime number|nil - Best time for this boss
    @param quip string - Critter quip text
    @param nextBossKey string|nil - Key of next boss (for Learn button)
]]
function CritterUI:ShowCombinedStats(bossData, killTime, bestTime, quip, nextBossKey)
    if not self.combinedStatsWindow then
        -- Defer first-time UI creation to next frame to avoid execution limit
        C_Timer.After(0, function()
            self:CreateCombinedStatsWindow()
            self:ShowCombinedStats(bossData, killTime, bestTime, quip, nextBossKey)
        end)
        return
    end

    local window = self.combinedStatsWindow
    local C = HopeAddon.Constants

    -- Cancel existing timer
    if self.combinedStatsTimer then
        self.combinedStatsTimer:Cancel()
        self.combinedStatsTimer = nil
    end

    -- Set boss icon
    local iconKey = bossData.key or string.lower(string.gsub(bossData.name, "[%s%-']", "_"))
    local iconPath = C.BOSS_ICONS and C.BOSS_ICONS[iconKey]
    if iconPath then
        window.bossIcon:SetTexture("Interface\\Icons\\" .. iconPath)
    else
        window.bossIcon:SetTexture(HopeAddon.DEFAULT_ICON_PATH)
    end

    -- Set boss name
    window.bossName:SetText(bossData.name)

    -- Format times
    local function formatTime(seconds)
        if not seconds or seconds == 0 then return "N/A" end
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%d:%02d", mins, secs)
    end

    window.thisTime:SetText(formatTime(killTime))
    window.bestTime:SetText(formatTime(bestTime or killTime))

    -- Update time bar
    local maxTime = math.max(killTime or 1, bestTime or 1)
    local barWidth = 280
    local thisWidth = math.min((killTime or 0) / maxTime * barWidth, barWidth)
    window.thisBar:SetWidth(math.max(thisWidth, 1))

    -- Position best time marker
    if bestTime and bestTime > 0 then
        local markerPos = (bestTime / maxTime) * barWidth
        window.bestMarker:SetPoint("LEFT", window.barContainer, "LEFT", markerPos - 1, 0)
        window.bestMarker:Show()
    else
        window.bestMarker:Hide()
    end

    -- Set quip text
    if quip then
        window.quoteText:SetText("\"" .. quip .. "\"")

        -- Set attribution
        local critterId = "chomp"
        if HopeAddon.db and HopeAddon.db.crusadeCritter then
            critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
        end
        local critterData = HopeAddon.CritterContent and HopeAddon.CritterContent:GetCritter(critterId)
        if critterData then
            window.attribution:SetText("- " .. critterData.name)
        else
            window.attribution:SetText("")
        end
    else
        window.quoteText:SetText("")
        window.attribution:SetText("")
    end

    -- Hide learn button initially
    window.learnBtn:Hide()

    -- Store next boss for learn button
    window.nextBossKey = nextBossKey

    -- Position near housing if open
    if self.housingContainer and self.isHousingOpen then
        window:ClearAllPoints()
        window:SetPoint("RIGHT", self.housingContainer, "LEFT", -20, 50)
    else
        window:ClearAllPoints()
        window:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    end

    window:Show()
    if HopeAddon.Effects then
        HopeAddon.Effects:FadeIn(window, 0.3)
    end

    -- Show learn button after 3 seconds
    if HopeAddon.Timer and nextBossKey then
        HopeAddon.Timer:After(3, function()
            if window:IsShown() then
                window.learnBtn:Show()
                if HopeAddon.Effects then
                    HopeAddon.Effects:FadeIn(window.learnBtn, 0.3)
                end
            end
        end)
    end

    -- Auto-hide after duration
    if HopeAddon.Timer then
        self.combinedStatsTimer = HopeAddon.Timer:After(COMBINED_STATS_DURATION, function()
            self.combinedStatsTimer = nil
            self:HideCombinedStats()
        end)
    end
end

--[[
    Hide the combined stats window
]]
function CritterUI:HideCombinedStats()
    if self.combinedStatsTimer then
        self.combinedStatsTimer:Cancel()
        self.combinedStatsTimer = nil
    end

    if not self.combinedStatsWindow then return end

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(self.combinedStatsWindow, 0.3)
    else
        self.combinedStatsWindow:Hide()
    end
end

--============================================================
-- BOSS TIPS PLAYABLE TEXT PANEL
--============================================================

--[[
    Create the boss tips panel with playable text system
    @return Frame - The tips panel
]]
function CritterUI:CreateBossTipsPanel()
    if self.bossTipsPanel then
        return self.bossTipsPanel
    end

    local C = HopeAddon.Constants

    local panel = CreateFrame("Frame", "HopeCrusadeCritterBossTips", UIParent, "BackdropTemplate")
    panel:SetSize(TIPS_PANEL_WIDTH, TIPS_PANEL_HEIGHT)
    panel:SetBackdrop(C.BACKDROPS and C.BACKDROPS.DARK_GOLD or {
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    panel:SetBackdropColor(unpack(COLOR_DARK_BG))
    panel:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    panel:SetFrameStrata("DIALOG")
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    panel:SetClampedToScreen(true)

    -- Boss icon (small)
    local bossIcon = panel:CreateTexture(nil, "ARTWORK")
    bossIcon:SetSize(32, 32)
    bossIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -12)
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    panel.bossIcon = bossIcon

    -- Boss name
    local bossName = panel:CreateFontString(nil, "OVERLAY")
    bossName:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    bossName:SetPoint("LEFT", bossIcon, "RIGHT", 8, 4)
    bossName:SetTextColor(unpack(COLOR_GOLD))
    panel.bossName = bossName

    -- Boss subtitle (e.g., dungeon name)
    local bossSubtitle = panel:CreateFontString(nil, "OVERLAY")
    bossSubtitle:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    bossSubtitle:SetPoint("TOPLEFT", bossName, "BOTTOMLEFT", 0, -2)
    bossSubtitle:SetTextColor(0.6, 0.6, 0.6)
    panel.bossSubtitle = bossSubtitle

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        CritterUI:HideBossTips()
    end)

    -- Progress indicator
    local progress = panel:CreateFontString(nil, "OVERLAY")
    progress:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    progress:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -5, -8)
    progress:SetTextColor(unpack(COLOR_LABEL_GRAY))
    panel.progress = progress

    -- Tip text container
    local tipContainer = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    tipContainer:SetSize(290, 80)
    tipContainer:SetPoint("TOP", panel, "TOP", 0, -55)
    tipContainer:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    tipContainer:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
    tipContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    panel.tipContainer = tipContainer

    -- Tip text
    local tipText = tipContainer:CreateFontString(nil, "OVERLAY")
    tipText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    tipText:SetPoint("TOPLEFT", tipContainer, "TOPLEFT", 10, -10)
    tipText:SetPoint("BOTTOMRIGHT", tipContainer, "BOTTOMRIGHT", -10, 10)
    tipText:SetJustifyH("LEFT")
    tipText:SetJustifyV("TOP")
    tipText:SetWordWrap(true)
    tipText:SetTextColor(1, 1, 1)
    panel.tipText = tipText

    -- Progress bar
    local progressBarBg = panel:CreateTexture(nil, "BACKGROUND")
    progressBarBg:SetSize(290, 6)
    progressBarBg:SetPoint("TOP", tipContainer, "BOTTOM", 0, -10)
    progressBarBg:SetTexture(TEX_WHITE8X8)
    progressBarBg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    panel.progressBarBg = progressBarBg

    local progressBar = panel:CreateTexture(nil, "ARTWORK")
    progressBar:SetHeight(6)
    progressBar:SetPoint("LEFT", progressBarBg, "LEFT", 0, 0)
    progressBar:SetTexture(TEX_WHITE8X8)
    progressBar:SetVertexColor(0.61, 0.19, 1.00, 1)
    panel.progressBar = progressBar

    -- Control buttons
    local btnY = -170
    local btnSpacing = 80

    -- Play/Pause button
    local playBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    playBtn:SetSize(70, 22)
    playBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 30, 15)
    playBtn:SetText("\226\150\182 Play")
    playBtn:SetScript("OnClick", function()
        self:ToggleTipsPlayback()
    end)
    panel.playBtn = playBtn

    -- Skip button
    local skipBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    skipBtn:SetSize(70, 22)
    skipBtn:SetPoint("LEFT", playBtn, "RIGHT", 10, 0)
    skipBtn:SetText("\226\143\173 Skip")
    skipBtn:SetScript("OnClick", function()
        self:SkipToNextTip()
    end)
    panel.skipBtn = skipBtn

    -- Close/Done button
    local doneBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    doneBtn:SetSize(70, 22)
    doneBtn:SetPoint("LEFT", skipBtn, "RIGHT", 10, 0)
    doneBtn:SetText("\226\156\149 Close")
    doneBtn:SetScript("OnClick", function()
        self:HideBossTips()
    end)
    panel.doneBtn = doneBtn

    panel:Hide()
    self.bossTipsPanel = panel
    return panel
end

--[[
    Show boss tips for a specific boss
    @param bossKey string - Boss key (e.g., "watchkeeper_gargolmar")
    @param bossName string - Display name of boss
]]
function CritterUI:ShowBossTips(bossKey, bossName)
    if not self.bossTipsPanel then
        self:CreateBossTipsPanel()
    end

    local panel = self.bossTipsPanel
    local Content = HopeAddon.CritterContent
    local C = HopeAddon.Constants

    if not Content then return end

    -- Get critter ID
    local critterId = "chomp"
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
    end

    -- Check if heroic (check instance difficulty)
    local isHeroic = false
    local _, instanceType, difficulty = GetInstanceInfo()
    if difficulty and difficulty == 2 then -- Heroic dungeon
        isHeroic = true
    end

    -- Get tips
    local tips = Content:GetBossTips(critterId, bossKey, isHeroic)
    if not tips or #tips == 0 then
        -- No tips available
        return
    end

    -- Initialize state
    self.bossTipsState = {
        tips = tips,
        currentIndex = 1,
        state = "idle", -- idle, playing, paused, complete, finished
        bossKey = bossKey,
        bossName = bossName,
    }

    -- Set boss icon
    local iconPath = C.BOSS_ICONS and C.BOSS_ICONS[bossKey]
    if iconPath then
        panel.bossIcon:SetTexture("Interface\\Icons\\" .. iconPath)
    else
        panel.bossIcon:SetTexture(HopeAddon.DEFAULT_ICON_PATH)
    end

    -- Set boss name
    panel.bossName:SetText(bossName or bossKey)
    panel.bossSubtitle:SetText(isHeroic and "Heroic Tips" or "Normal Tips")

    -- Update progress
    self:UpdateTipsProgress()

    -- Set initial tip text (empty, will typewriter in)
    panel.tipText:SetText("")

    -- Update buttons
    panel.playBtn:SetText("\226\150\182 Play")
    panel.playBtn:Enable()
    panel.skipBtn:Enable()

    -- Position near housing if open
    if self.housingContainer and self.isHousingOpen then
        panel:ClearAllPoints()
        panel:SetPoint("RIGHT", self.housingContainer, "LEFT", -20, 30)
    else
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    end

    panel:Show()
    if HopeAddon.Effects then
        HopeAddon.Effects:FadeIn(panel, 0.3)
    end

    -- Auto-start playback
    if HopeAddon.Timer then
        HopeAddon.Timer:After(0.5, function()
            if panel:IsShown() then
                self:PlayCurrentTip()
            end
        end)
    end
end

--[[
    Update the tips progress indicator
]]
function CritterUI:UpdateTipsProgress()
    if not self.bossTipsPanel or not self.bossTipsState then return end

    local state = self.bossTipsState
    local panel = self.bossTipsPanel

    panel.progress:SetText(string.format("Tip %d of %d", state.currentIndex, #state.tips))

    -- Update progress bar
    local progress = state.currentIndex / #state.tips
    panel.progressBar:SetWidth(math.max(290 * progress, 1))
end

--[[
    Play the current tip with typewriter effect
]]
function CritterUI:PlayCurrentTip()
    if not self.bossTipsPanel or not self.bossTipsState then return end

    local state = self.bossTipsState
    local panel = self.bossTipsPanel

    if state.currentIndex > #state.tips then
        -- All tips finished
        state.state = "finished"
        panel.playBtn:SetText("\226\156\147 Done")
        panel.playBtn:Disable()
        panel.skipBtn:Disable()
        return
    end

    state.state = "playing"
    panel.playBtn:SetText("\226\143\184 Pause")

    local tip = state.tips[state.currentIndex]
    local tipText = tip.text

    -- Mark heroic tips
    if tip.heroic then
        tipText = "|cffff6600[HEROIC]|r " .. tipText
    end

    -- Typewriter effect
    if HopeAddon.Effects then
        HopeAddon.Effects:TypewriterText(panel.tipText, tipText, TYPEWRITER_SPEED, function()
            -- Tip complete
            state.state = "complete"
            panel.playBtn:SetText("\226\150\182 Next")

            -- Auto-advance after delay if setting enabled
            local db = HopeAddon.db and HopeAddon.db.crusadeCritter
            if db and db.autoAdvanceTips then
                local delay = db.tipDisplayTime or 3
                if HopeAddon.Timer then
                    HopeAddon.Timer:After(delay, function()
                        if state.state == "complete" and panel:IsShown() then
                            self:AdvanceToNextTip()
                        end
                    end)
                end
            end
        end)
    else
        -- No effects - just set text
        panel.tipText:SetText(tipText)
        state.state = "complete"
        panel.playBtn:SetText("\226\150\182 Next")
    end
end

--[[
    Toggle playback (play/pause/next)
]]
function CritterUI:ToggleTipsPlayback()
    if not self.bossTipsState then return end

    local state = self.bossTipsState

    if state.state == "idle" or state.state == "complete" then
        -- Start playing or advance
        if state.state == "complete" then
            self:AdvanceToNextTip()
        else
            self:PlayCurrentTip()
        end
    elseif state.state == "playing" then
        -- Pause
        state.state = "paused"
        self.bossTipsPanel.playBtn:SetText("\226\150\182 Play")
        -- Stop typewriter effect
        if self.tipsTypewriterTicker then
            self.tipsTypewriterTicker:Cancel()
            self.tipsTypewriterTicker = nil
        end
    elseif state.state == "paused" then
        -- Resume
        self:PlayCurrentTip()
    end
end

--[[
    Skip to the next tip immediately
]]
function CritterUI:SkipToNextTip()
    if not self.bossTipsState then return end

    -- Stop any current typewriter
    if self.tipsTypewriterTicker then
        self.tipsTypewriterTicker:Cancel()
        self.tipsTypewriterTicker = nil
    end

    -- Show full current tip text
    local state = self.bossTipsState
    if state.currentIndex <= #state.tips then
        local tip = state.tips[state.currentIndex]
        local tipText = tip.text
        if tip.heroic then
            tipText = "|cffff6600[HEROIC]|r " .. tipText
        end
        self.bossTipsPanel.tipText:SetText(tipText)
    end

    -- Advance to next
    self:AdvanceToNextTip()
end

--[[
    Advance to the next tip
]]
function CritterUI:AdvanceToNextTip()
    if not self.bossTipsState then return end

    local state = self.bossTipsState
    state.currentIndex = state.currentIndex + 1

    if state.currentIndex > #state.tips then
        -- Finished all tips
        state.state = "finished"
        self.bossTipsPanel.playBtn:SetText("\226\156\147 Done")
        self.bossTipsPanel.playBtn:Disable()
        self.bossTipsPanel.skipBtn:Disable()
        self.bossTipsPanel.progress:SetText("Complete!")
        self.bossTipsPanel.progressBar:SetWidth(290)
    else
        self:UpdateTipsProgress()
        self:PlayCurrentTip()
    end
end

--[[
    Hide the boss tips panel
]]
function CritterUI:HideBossTips()
    -- Stop typewriter
    if self.tipsTypewriterTicker then
        self.tipsTypewriterTicker:Cancel()
        self.tipsTypewriterTicker = nil
    end

    self.bossTipsState = nil

    if not self.bossTipsPanel then return end

    if HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(self.bossTipsPanel, 0.3)
    else
        self.bossTipsPanel:Hide()
    end
end

--============================================================
-- STATS BUTTON (Housing chart icon)
--============================================================

--[[
    Create the stats button on housing panel (chart icon)
]]
function CritterUI:CreateStatsButton()
    if self.statsButton then
        return self.statsButton
    end

    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    local btn = CreateFrame("Button", nil, self.housingContainer, "BackdropTemplate")
    btn:SetSize(20, 20)
    btn:SetPoint("BOTTOMRIGHT", self.housingContainer, "BOTTOMRIGHT", -5, 5)
    btn:SetFrameLevel(self.housingContainer:GetFrameLevel() + 10)

    -- Background
    btn:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    btn:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER_80))

    -- Chart icon
    local icon = btn:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_06")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon

    -- Hover highlight
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    highlight:SetTexture(TEX_WHITE8X8)
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.3)

    -- Click handler - toggle instance guide expanded/collapsed
    btn:SetScript("OnClick", function()
        self:ToggleInstanceGuideExpanded()
    end)

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Dungeon Progress", unpack(COLOR_GOLD))
        GameTooltip:AddLine("View dungeon stats and critter unlocks", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.statsButton = btn
    return btn
end

--============================================================
-- UNLOCK CELEBRATION
--============================================================

--[[
    Show critter unlock celebration
    @param critterId string - The unlocked critter ID
]]
function CritterUI:ShowUnlockCelebration(critterId)
    if not HopeAddon.CritterContent then return end

    local critterData = HopeAddon.CritterContent:GetCritter(critterId)
    if not critterData then return end

    local message = HopeAddon.CritterContent.UNLOCK_MESSAGES[critterId]
        or ("NEW CRITTER UNLOCKED! " .. critterData.name .. " wants to join you!")

    -- Create celebration popup
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(350, 100)
    popup:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    popup:SetBackdropColor(unpack(COLOR_DARK_BG))
    popup:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    popup:SetFrameStrata("DIALOG")
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetClampedToScreen(true)

    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText("NEW CRITTER UNLOCKED!")
    title:SetTextColor(unpack(COLOR_GOLD))

    local text = popup:CreateFontString(nil, "OVERLAY")
    text:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    text:SetPoint("TOP", title, "BOTTOM", 0, -10)
    text:SetWidth(320)
    text:SetJustifyH("CENTER")
    text:SetText(critterData.name .. " wants to join your adventures!")
    text:SetTextColor(1, 1, 1)

    popup:Show()

    -- Celebration effects
    if HopeAddon.Effects then
        HopeAddon.Effects:Celebrate(popup, 3)
    end

    -- Auto-hide
    if HopeAddon.Timer then
        -- Store reference for cleanup
        self.unlockTimer = HopeAddon.Timer:After(5, function()
            self.unlockTimer = nil
            self.unlockPopup = nil
            if HopeAddon.Effects then
                HopeAddon.Effects:FadeOut(popup, 0.5, function()
                    popup:Hide()
                    popup:SetParent(nil)
                end)
            else
                popup:Hide()
                popup:SetParent(nil)
            end
        end)
    end
    -- Store popup reference
    self.unlockPopup = popup
end

--============================================================
-- DUNGEON PROGRESS STATS PANEL
--============================================================

-- Tier definitions for the stats panel
local STATS_TIERS = {
    { key = "t1_dungeon", name = "Tier 1 - Hellfire Citadel", hub = "hellfire" },
    { key = "t2_dungeon", name = "Tier 2 - Coilfang Reservoir", hub = "coilfang" },
    { key = "t3_dungeon", name = "Tier 3 - Auchindoun", hub = "auchindoun" },
    { key = "t4_dungeon", name = "Tier 4 - Tempest Keep", hub = "tempest_keep" },
    { key = "t5_dungeon", name = "Tier 5 - Caverns of Time", hub = "caverns" },
    { key = "t6_dungeon", name = "Tier 6 - Quel'Danas", hub = "queldanas" },
    { key = "p1_raid", name = "Phase 1 Raids", phase = 1 },
    { key = "p2_raid", name = "Phase 2 Raids", phase = 2 },
    { key = "p3_raid", name = "Phase 3 Raids", phase = 3 },
    { key = "p4_raid", name = "Phase 4 Raids", phase = 4 },
    { key = "p5_raid", name = "Phase 5 Raids", phase = 5 },
}

-- Raids by phase for stats panel
local RAIDS_BY_PHASE = {
    [1] = { { key = "karazhan", name = "Karazhan" }, { key = "gruul", name = "Gruul's Lair" }, { key = "magtheridon", name = "Magtheridon's Lair" } },
    [2] = { { key = "ssc", name = "Serpentshrine Cavern" }, { key = "tk", name = "The Eye" } },
    [3] = { { key = "hyjal", name = "Battle for Mount Hyjal" }, { key = "bt", name = "Black Temple" } },
    [4] = { { key = "za", name = "Zul'Aman" } },
    [5] = { { key = "sunwell", name = "Sunwell Plateau" } },
}

--[[
    Get the list of tiers for the stats panel
    @return table - Array of tier definitions
]]
function CritterUI:GetStatsTiers()
    return STATS_TIERS
end

--[[
    Get instances for a specific tier
    @param tierKey string - Tier key (e.g., "t1_dungeon")
    @return table - Array of { key, name } instances
]]
function CritterUI:GetTierInstances(tierKey)
    local Content = HopeAddon.CritterContent
    if not Content then return {} end

    -- Find the tier definition
    local tierDef = nil
    for _, tier in ipairs(STATS_TIERS) do
        if tier.key == tierKey then
            tierDef = tier
            break
        end
    end

    if not tierDef then return {} end

    -- Dungeon tiers use hub data
    if tierDef.hub then
        local hub = Content.DUNGEON_HUBS[tierDef.hub]
        if not hub then return {} end

        local instances = {}
        local C = HopeAddon.Constants
        for _, dungeonKey in ipairs(hub.dungeons) do
            -- Get dungeon display name from Constants if available
            local displayName = dungeonKey
            if C and C.TBC_DUNGEONS then
                for zoneName, data in pairs(C.TBC_DUNGEONS) do
                    if data.key == dungeonKey then
                        displayName = zoneName
                        break
                    end
                end
            end
            table.insert(instances, { key = dungeonKey, name = displayName })
        end
        return instances
    end

    -- Raid tiers use phase data
    if tierDef.phase then
        return RAIDS_BY_PHASE[tierDef.phase] or {}
    end

    return {}
end

--[[
    Create a simple dropdown for the stats panel
    @param parent Frame - Parent frame
    @param width number - Width of dropdown
    @param onChange function - Callback when selection changes
    @return Frame - The dropdown frame
]]
function CritterUI:CreateStatsDropdown(parent, width, onChange)
    local dropdown = CreateFrame("Button", nil, parent, "BackdropTemplate")
    dropdown:SetSize(width, 28)

    dropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    dropdown:SetBackdropColor(unpack(COLOR_DARK_BG_FULL))
    dropdown:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY")
    dropdown.text:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    dropdown.text:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    dropdown.text:SetPoint("RIGHT", dropdown, "RIGHT", -20, 0)
    dropdown.text:SetJustifyH("LEFT")
    dropdown.text:SetTextColor(0.9, 0.9, 0.9)

    local arrow = dropdown:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(10, 10)
    arrow:SetPoint("RIGHT", dropdown, "RIGHT", -6, 0)
    arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    arrow:SetTexCoord(0, 1, 1, 0)
    arrow:SetVertexColor(0.6, 0.6, 0.6)

    dropdown.options = {}
    dropdown.selectedIndex = 1
    dropdown.onChange = onChange
    dropdown.text:SetText("Select...")

    dropdown:SetScript("OnClick", function(self)
        self:ShowMenu()
    end)
    dropdown:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(COLOR_GOLD_BORDER))
    end)
    dropdown:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)

    function dropdown:SetOptions(options, preserveSelection)
        local previousKey = nil
        if preserveSelection and self.selectedIndex > 0 and self.options[self.selectedIndex] then
            previousKey = self.options[self.selectedIndex].key
        end

        self.options = options or {}
        if #self.options > 0 then
            -- Try to preserve previous selection if requested
            local foundPrevious = false
            if previousKey then
                for i, opt in ipairs(self.options) do
                    if opt.key == previousKey then
                        self.selectedIndex = i
                        self.text:SetText(opt.name or tostring(opt.key) or "Option " .. i)
                        foundPrevious = true
                        break
                    end
                end
            end

            -- Fall back to first option if not preserving or not found
            if not foundPrevious then
                self.selectedIndex = 1
                local firstOpt = self.options[1]
                if type(firstOpt) == "table" then
                    self.text:SetText(firstOpt.name or tostring(firstOpt.key) or "Option 1")
                else
                    self.text:SetText(tostring(firstOpt))
                end
            end
        else
            self.selectedIndex = 0
            self.text:SetText("No options")
        end
    end

    function dropdown:GetSelectedKey()
        if self.selectedIndex > 0 and self.options[self.selectedIndex] then
            return self.options[self.selectedIndex].key
        end
        return nil
    end

    function dropdown:SetSelectedByKey(key)
        for i, opt in ipairs(self.options) do
            if opt.key == key then
                self.selectedIndex = i
                self.text:SetText(opt.name or opt.key)
                return
            end
        end
    end

    function dropdown:ShowMenu()
        if self.menuFrame and self.menuFrame:IsShown() then
            self.menuFrame:Hide()
            return
        end

        local MAX_VISIBLE_HEIGHT = 200
        local ITEM_HEIGHT = 20
        local PADDING = 6

        if not self.menuFrame then
            self.menuFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
            self.menuFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            self.menuFrame:SetBackdropColor(unpack(COLOR_DARK_BG_FULL))
            self.menuFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            self.menuFrame:SetFrameStrata("TOOLTIP")
        end

        local menuHeight = math.min(#self.options * ITEM_HEIGHT + PADDING * 2, MAX_VISIBLE_HEIGHT)
        self.menuFrame:SetSize(self:GetWidth(), menuHeight)
        self.menuFrame:SetPoint("TOP", self, "BOTTOM", 0, -2)

        -- Hide existing buttons (reuse pattern - don't orphan frames)
        if not self.menuFrame.buttons then
            self.menuFrame.buttons = {}
        end
        for _, btn in ipairs(self.menuFrame.buttons) do
            btn:Hide()
        end

        for i, opt in ipairs(self.options) do
            local btn = self.menuFrame.buttons[i]

            -- Create new button only if needed
            if not btn then
                btn = CreateFrame("Button", nil, self.menuFrame)
                btn:SetSize(self:GetWidth() - PADDING * 2, ITEM_HEIGHT)

                local text = btn:CreateFontString(nil, "OVERLAY")
                text:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
                text:SetPoint("LEFT", btn, "LEFT", 4, 0)
                btn.text = text

                local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
                highlight:SetAllPoints(btn)
                highlight:SetTexture(TEX_WHITE8X8)
                highlight:SetBlendMode("ADD")
                highlight:SetVertexColor(1, 0.84, 0, 0.2)

                self.menuFrame.buttons[i] = btn
            end

            -- Update button position and text
            btn:SetPoint("TOPLEFT", self.menuFrame, "TOPLEFT", PADDING, -PADDING - (i - 1) * ITEM_HEIGHT)
            btn.text:SetText(opt.name or opt)
            btn.text:SetTextColor(0.9, 0.9, 0.9)

            -- Store option data for click handler
            btn.optIndex = i
            btn.optData = opt
            btn:SetScript("OnClick", function()
                self.selectedIndex = btn.optIndex
                self.text:SetText(btn.optData.name or btn.optData)
                self.menuFrame:Hide()
                if self.onChange then
                    self.onChange(btn.optData.key, btn.optData)
                end
            end)

            btn:Show()
        end

        self.menuFrame:Show()
    end

    return dropdown
end

--============================================================
-- TIP TOOLTIP SYSTEM (Hover tooltips for boss tips)
--============================================================

--[[
    Create the tip tooltip frame
    @return Frame - The tooltip frame
]]
function CritterUI:CreateTipTooltip()
    if self.guideTipTooltip then return self.guideTipTooltip end

    local tooltip = CreateFrame("Frame", "HopeCritterGuideTipTooltip", UIParent, "BackdropTemplate")
    tooltip:SetSize(280, 100)  -- height adjusts dynamically
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    tooltip:SetBackdropColor(unpack(COLOR_DARK_BG))
    tooltip:SetBackdropBorderColor(0.8, 0.6, 0, 1)  -- gold border
    tooltip:Hide()

    -- Boss name header
    tooltip.header = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tooltip.header:SetPoint("TOPLEFT", 10, -10)
    tooltip.header:SetTextColor(1, 0.82, 0)  -- gold

    -- Tips text (multi-line)
    tooltip.tips = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tooltip.tips:SetPoint("TOPLEFT", 10, -30)
    tooltip.tips:SetPoint("RIGHT", -10, 0)
    tooltip.tips:SetJustifyH("LEFT")
    tooltip.tips:SetSpacing(2)

    self.guideTipTooltip = tooltip
    return tooltip
end

--[[
    Show the boss tip tooltip
    @param bossKey string - Boss key for tip lookup
    @param bossName string - Display name for header
    @param anchorFrame Frame - Frame to anchor tooltip to
]]
function CritterUI:ShowBossTipTooltip(bossKey, bossName, anchorFrame)
    local Content = HopeAddon.CritterContent
    if not Content then return end

    -- Get critter ID (use current selection or default to chomp)
    local critterId
    if self.currentCritter and self.currentCritter.id then
        critterId = self.currentCritter.id
    else
        local db = HopeAddon.db and HopeAddon.db.crusadeCritter
        critterId = db and db.selectedCritter or "chomp"
    end

    -- Check if heroic (via instance info)
    local isHeroic = false
    local _, _, difficulty = GetInstanceInfo()
    if difficulty and difficulty == 2 then  -- Heroic dungeon
        isHeroic = true
    end

    -- Get tips for this boss
    local tips = Content:GetBossTips(critterId, bossKey, isHeroic)
    if not tips or #tips == 0 then return end

    local tooltip = self:CreateTipTooltip()
    tooltip.header:SetText(bossName)

    -- Build tip text with bullets
    local tipLines = {}
    for i, tip in ipairs(tips) do
        if i > 4 then break end  -- max 4 tips
        local prefix = tip.heroic and "|cffff6600[HEROIC]|r " or ""
        table.insert(tipLines, "â€¢ " .. prefix .. tip.text)
    end
    tooltip.tips:SetText(table.concat(tipLines, "\n"))

    -- Adjust height based on content
    local textHeight = tooltip.tips:GetStringHeight()
    tooltip:SetHeight(50 + textHeight)

    -- Position to LEFT of anchor (avoid screen edge)
    tooltip:ClearAllPoints()
    tooltip:SetPoint("RIGHT", anchorFrame, "LEFT", -10, 0)
    tooltip:Show()
end

--[[
    Hide the boss tip tooltip
]]
function CritterUI:HideBossTipTooltip()
    if self.guideTipTooltip then
        self.guideTipTooltip:Hide()
    end
end

--============================================================
-- INSTANCE GUIDE PANEL
--============================================================

--[[
    Get bosses for a raid from Constants
    @param raidKey string - Raid key (e.g., "karazhan")
    @return table - Array of boss options { key, name }
]]
function CritterUI:GetRaidBosses(raidKey)
    local C = HopeAddon.Constants
    if not C then
        return {}
    end

    local bossTable = nil
    if raidKey == "karazhan" then
        bossTable = C.KARAZHAN_BOSSES
    elseif raidKey == "gruul" then
        bossTable = C.GRUUL_BOSSES
    elseif raidKey == "magtheridon" then
        bossTable = C.MAGTHERIDON_BOSSES
    elseif raidKey == "ssc" then
        bossTable = C.SSC_BOSSES
    elseif raidKey == "tk" then
        bossTable = C.TK_BOSSES
    elseif raidKey == "hyjal" then
        bossTable = C.HYJAL_BOSSES
    elseif raidKey == "bt" then
        bossTable = C.BT_BOSSES
    elseif raidKey == "za" then
        bossTable = C.ZA_BOSSES
    elseif raidKey == "sunwell" then
        bossTable = C.SUNWELL_BOSSES
    end

    if not bossTable then
        return {}
    end

    local options = {}
    for _, boss in ipairs(bossTable) do
        -- Validate boss data before inserting
        if boss and boss.id and boss.name then
            table.insert(options, {
                key = boss.id,
                name = boss.name,
            })
        end
    end

    return options
end

--[[
    Create the collapsible instance guide panel (replaces old Boss Guide)
    Unified panel covering both dungeons and raids with stats grid
    @return Frame - The instance guide panel
]]
function CritterUI:CreateInstanceGuidePanel()
    if self.instanceGuidePanel then
        return self.instanceGuidePanel
    end

    if not self.housingContainer then
        self:CreateHousingContainer()
    end

    local panel = CreateFrame("Frame", "HopeCrusadeCritterInstanceGuide", self.housingContainer, "BackdropTemplate")
    panel:SetSize(INSTANCE_GUIDE_WIDTH, INSTANCE_GUIDE_HEADER_HEIGHT)
    panel:SetFrameStrata("MEDIUM")
    panel:SetFrameLevel(101)

    -- Position below housing
    panel:SetPoint("TOP", self.housingContainer, "BOTTOM", 0, -5)

    -- Dark background with border
    panel:SetBackdrop({
        bgFile = TEX_WHITE8X8,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    panel:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)

    -- Collapsible header button
    local header = CreateFrame("Button", nil, panel)
    header:SetSize(INSTANCE_GUIDE_WIDTH - 8, INSTANCE_GUIDE_HEADER_HEIGHT - 4)
    header:SetPoint("TOP", panel, "TOP", 0, -2)

    -- Header text
    local headerText = header:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER or "Fonts\\FRIZQT__.TTF", 11, "")
    headerText:SetPoint("LEFT", header, "LEFT", 8, 0)
    headerText:SetText("Instance Guide")
    headerText:SetTextColor(unpack(COLOR_GOLD))
    panel.headerText = headerText

    -- Expand/Collapse indicator
    local indicator = header:CreateTexture(nil, "OVERLAY")
    indicator:SetSize(10, 10)
    indicator:SetPoint("RIGHT", header, "RIGHT", -8, 0)
    indicator:SetTexture("Interface\\Buttons\\UI-SortArrow")
    if self.instanceGuideIsExpanded then
        indicator:SetTexCoord(0, 1, 1, 0) -- down arrow
    else
        indicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) -- right arrow
    end
    indicator:SetVertexColor(unpack(COLOR_LABEL_GRAY))
    panel.indicator = indicator

    -- Hover highlight
    local highlight = header:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(header)
    highlight:SetTexture(TEX_WHITE8X8)
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.1)

    -- Click to toggle
    header:SetScript("OnClick", function()
        self:ToggleInstanceGuideExpanded()
    end)

    panel.header = header

    -- Content area
    local content = CreateFrame("Frame", nil, panel)
    content:SetSize(INSTANCE_GUIDE_WIDTH - 10, INSTANCE_GUIDE_CONTENT_HEIGHT)
    content:SetPoint("TOP", header, "BOTTOM", 0, -2)
    panel.content = content

    local yOffset = 0
    local dropdownWidth = INSTANCE_GUIDE_WIDTH - 60

    -- Tier dropdown label
    local tierLabel = content:CreateFontString(nil, "OVERLAY")
    tierLabel:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
    tierLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    tierLabel:SetText("Tier:")
    tierLabel:SetTextColor(unpack(COLOR_LABEL_GRAY))

    -- Tier dropdown
    self.instanceGuideTierDropdown = self:CreateStatsDropdown(content, dropdownWidth, function(key, data)
        self:OnInstanceGuideTierSelect(key, data)
    end)
    self.instanceGuideTierDropdown:SetPoint("TOPLEFT", tierLabel, "TOPRIGHT", 5, 3)
    self.instanceGuideTierDropdown:SetOptions(STATS_TIERS)

    yOffset = yOffset - 28

    -- Instance dropdown label
    local instanceLabel = content:CreateFontString(nil, "OVERLAY")
    instanceLabel:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
    instanceLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    instanceLabel:SetText("Instance:")
    instanceLabel:SetTextColor(unpack(COLOR_LABEL_GRAY))
    panel.instanceLabel = instanceLabel

    -- Instance dropdown
    self.instanceGuideInstanceDropdown = self:CreateStatsDropdown(content, dropdownWidth, function(key, data)
        self:OnInstanceGuideInstanceSelect(key, data)
    end)
    self.instanceGuideInstanceDropdown:SetPoint("TOPLEFT", instanceLabel, "TOPRIGHT", 5, 3)
    self.instanceGuideInstanceDropdown:SetOptions({})

    yOffset = yOffset - 30

    -- Separator line
    local sep1 = content:CreateTexture(nil, "ARTWORK")
    sep1:SetSize(INSTANCE_GUIDE_WIDTH - 20, 1)
    sep1:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    sep1:SetTexture(TEX_WHITE8X8)
    sep1:SetVertexColor(1, 0.84, 0, 0.3)

    yOffset = yOffset - 6

    -- Instance header (name in caps)
    local instanceHeader = content:CreateFontString(nil, "OVERLAY")
    instanceHeader:SetFont(HopeAddon.assets.fonts.HEADER or "Fonts\\FRIZQT__.TTF", 10, "")
    instanceHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    instanceHeader:SetWidth(INSTANCE_GUIDE_WIDTH - 20)
    instanceHeader:SetJustifyH("LEFT")
    instanceHeader:SetText("")
    instanceHeader:SetTextColor(unpack(COLOR_GOLD))
    panel.instanceHeader = instanceHeader

    yOffset = yOffset - 14

    -- Stats line (Runs: X | Best: X:XX)
    local statsLine = content:CreateFontString(nil, "OVERLAY")
    statsLine:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
    statsLine:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    statsLine:SetWidth(INSTANCE_GUIDE_WIDTH - 20)
    statsLine:SetJustifyH("LEFT")
    statsLine:SetText("")
    statsLine:SetTextColor(unpack(COLOR_LABEL_GRAY))
    panel.statsLine = statsLine

    yOffset = yOffset - 14

    -- Separator line
    local sep2 = content:CreateTexture(nil, "ARTWORK")
    sep2:SetSize(INSTANCE_GUIDE_WIDTH - 20, 1)
    sep2:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    sep2:SetTexture(TEX_WHITE8X8)
    sep2:SetVertexColor(1, 0.84, 0, 0.3)

    yOffset = yOffset - 4

    -- Scroll container for boss list
    local bossScrollFrame = CreateFrame("ScrollFrame", nil, content)
    bossScrollFrame:SetSize(INSTANCE_GUIDE_WIDTH - 14, INSTANCE_GUIDE_BOSS_SCROLL_HEIGHT)
    bossScrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 2, yOffset)

    local bossListFrame = CreateFrame("Frame", nil, bossScrollFrame)
    bossListFrame:SetSize(INSTANCE_GUIDE_WIDTH - 20, 1) -- height set dynamically
    bossScrollFrame:SetScrollChild(bossListFrame)

    -- Mouse wheel scrolling
    bossScrollFrame:EnableMouseWheel(true)
    bossScrollFrame:SetScript("OnMouseWheel", function(scrollFrame, delta)
        CritterUI:ScrollBossList(delta)
    end)

    panel.bossScrollFrame = bossScrollFrame
    panel.bossListFrame = bossListFrame
    panel.bossRows = {}
    panel.bossListYOffset = yOffset -- remember where boss list starts
    panel.bossScrollOffset = 0

    -- Set initial size based on expanded state
    if self.instanceGuideIsExpanded then
        panel:SetHeight(INSTANCE_GUIDE_HEADER_HEIGHT + INSTANCE_GUIDE_CONTENT_HEIGHT)
        content:Show()
    else
        panel:SetHeight(INSTANCE_GUIDE_COLLAPSED_HEIGHT)
        content:Hide()
    end

    -- Initialize with first tier
    if #STATS_TIERS > 0 then
        self:OnInstanceGuideTierSelect(STATS_TIERS[1].key, STATS_TIERS[1])
    end

    panel:Hide()
    self.instanceGuidePanel = panel
    -- Backward compat: code referencing raidGuidePanel gets the new panel
    self.raidGuidePanel = panel
    return panel
end

--[[
    Toggle the instance guide panel expanded/collapsed state
]]
function CritterUI:ToggleInstanceGuideExpanded()
    self.instanceGuideIsExpanded = not self.instanceGuideIsExpanded

    if not self.instanceGuidePanel then return end

    local panel = self.instanceGuidePanel
    local content = panel.content
    local indicator = panel.indicator

    if self.instanceGuideIsExpanded then
        panel:SetHeight(INSTANCE_GUIDE_HEADER_HEIGHT + INSTANCE_GUIDE_CONTENT_HEIGHT)
        content:Show()
        indicator:SetTexCoord(0, 1, 1, 0) -- down arrow
    else
        panel:SetHeight(INSTANCE_GUIDE_COLLAPSED_HEIGHT)
        content:Hide()
        indicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) -- right arrow
    end

    -- Save state
    self:SaveInstanceGuideState()
end

--[[
    Save instance guide expanded state to database
]]
function CritterUI:SaveInstanceGuideState()
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        HopeAddon.db.crusadeCritter.instanceGuideExpanded = self.instanceGuideIsExpanded
    end
end

--[[
    Load instance guide expanded state from database (with backward compat)
]]
function CritterUI:LoadInstanceGuideState()
    if HopeAddon.db and HopeAddon.db.crusadeCritter then
        if HopeAddon.db.crusadeCritter.instanceGuideExpanded ~= nil then
            self.instanceGuideIsExpanded = HopeAddon.db.crusadeCritter.instanceGuideExpanded
        elseif HopeAddon.db.crusadeCritter.raidGuideExpanded ~= nil then
            -- Backward compat: read old key
            self.instanceGuideIsExpanded = HopeAddon.db.crusadeCritter.raidGuideExpanded
        end
    end
end

--[[
    Handle tier selection in the instance guide
    @param key string - Tier key (e.g., "t1_dungeon", "p1_raid")
    @param data table - Tier data
]]
function CritterUI:OnInstanceGuideTierSelect(key, data)
    self.instanceGuideSelectedTier = key

    -- Determine if this is a raid tier
    local isRaid = key and key:find("_raid") ~= nil
    self.instanceGuideIsRaid = isRaid

    -- Populate instance dropdown with instances for this tier
    local instances = self:GetTierInstances(key)
    if self.instanceGuideInstanceDropdown then
        self.instanceGuideInstanceDropdown:SetOptions(instances)
    end

    -- Update label
    if self.instanceGuidePanel and self.instanceGuidePanel.instanceLabel then
        self.instanceGuidePanel.instanceLabel:SetText(isRaid and "Raid:" or "Dungeon:")
    end

    -- Auto-select first instance
    if #instances > 0 then
        self:OnInstanceGuideInstanceSelect(instances[1].key, instances[1])
    else
        -- Clear display
        if self.instanceGuidePanel then
            self.instanceGuidePanel.instanceHeader:SetText("")
            self.instanceGuidePanel.statsLine:SetText("")
            if self.instanceGuidePanel.bossRows then
                for _, row in ipairs(self.instanceGuidePanel.bossRows) do
                    row:Hide()
                end
            end
        end
    end
end

--[[
    Handle instance selection in the instance guide
    @param key string - Instance key
    @param data table - Instance data
]]
function CritterUI:OnInstanceGuideInstanceSelect(key, data)
    self.instanceGuideSelectedInstance = key

    -- Stop any playing tips when switching instances
    if self.instanceGuideIsPlaying then
        self:StopInstanceGuideTips()
    end

    self:DisplayInstanceGuideStats(key, data)
end

--[[
    Display stats for a specific instance in the instance guide panel
    @param instanceKey string - Instance key
    @param instanceData table - Instance data { key, name }
]]
function CritterUI:DisplayInstanceGuideStats(instanceKey, instanceData)
    if not self.instanceGuidePanel then return end

    local panel = self.instanceGuidePanel
    local db = HopeAddon.db and HopeAddon.db.crusadeCritter
    local C = HopeAddon.Constants
    local Content = HopeAddon.CritterContent

    -- Update instance header
    local displayName = instanceData and instanceData.name or instanceKey
    panel.instanceHeader:SetText(string.upper(displayName))

    -- Get run stats
    local totalRuns = 0
    local bestTime = nil

    if self.instanceGuideIsRaid then
        -- For raids: count total kills from journal data
        local charDb = HopeAddon.charDb
        if charDb and charDb.journal and charDb.journal.bossKills then
            local bosses = self:GetRaidBosses(instanceKey)
            for _, boss in ipairs(bosses) do
                local killKey = instanceKey .. "_" .. boss.key
                local killData = charDb.journal.bossKills[killKey]
                if killData then
                    totalRuns = totalRuns + (killData.totalKills or 0)
                    if killData.bestTime then
                        if not bestTime or killData.bestTime < bestTime then
                            bestTime = killData.bestTime
                        end
                    end
                end
            end
        end
    else
        -- For dungeons: use dungeonRuns data
        local runData = db and db.dungeonRuns and db.dungeonRuns[instanceKey]
        totalRuns = runData and runData.totalRuns or 0
        bestTime = runData and runData.bestTime
    end

    local bestTimeStr = "--:--"
    if bestTime then
        local mins = math.floor(bestTime / 60)
        local secs = math.floor(bestTime % 60)
        bestTimeStr = string.format("%d:%02d", mins, secs)
    end

    panel.statsLine:SetText(string.format("Runs: %d | Best: %s", totalRuns, bestTimeStr))

    -- Hide existing boss rows
    if not panel.bossRows then
        panel.bossRows = {}
    end
    for _, row in ipairs(panel.bossRows) do
        row:Hide()
    end

    -- Get boss list
    local bosses = {}
    if C and C.DUNGEON_BOSS_ORDER and C.DUNGEON_BOSS_ORDER[instanceKey] then
        bosses = C.DUNGEON_BOSS_ORDER[instanceKey]
    else
        -- Try raid bosses
        local raidBosses = self:GetRaidBosses(instanceKey)
        if raidBosses and #raidBosses > 0 then
            for _, boss in ipairs(raidBosses) do
                table.insert(bosses, { key = boss.key, name = boss.name })
            end
        end
    end

    -- Create or reuse boss rows (expandable with per-boss play buttons)
    local contentWidth = INSTANCE_GUIDE_WIDTH - 20
    panel.bossCount = #bosses
    for i, bossData in ipairs(bosses) do
        local row = panel.bossRows[i]

        if not row then
            row = CreateFrame("Button", nil, panel.bossListFrame)
            row:SetSize(contentWidth, INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED)

            -- Expand indicator
            local expandInd = row:CreateFontString(nil, "OVERLAY")
            expandInd:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
            expandInd:SetPoint("LEFT", row, "LEFT", 0, 0)
            expandInd:SetText(">")
            expandInd:SetTextColor(unpack(COLOR_LABEL_GRAY))
            row.expandInd = expandInd

            -- Boss name (left-aligned, truncated)
            local bossNameText = row:CreateFontString(nil, "OVERLAY")
            bossNameText:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
            bossNameText:SetPoint("LEFT", expandInd, "RIGHT", 4, 0)
            bossNameText:SetWidth(contentWidth - 110)
            bossNameText:SetJustifyH("LEFT")
            row.nameText = bossNameText

            -- Best time (right area, before play button)
            local timeText = row:CreateFontString(nil, "OVERLAY")
            timeText:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
            timeText:SetPoint("RIGHT", row, "RIGHT", -55, 0)
            row.timeText = timeText

            -- Kill count
            local killsText = row:CreateFontString(nil, "OVERLAY")
            killsText:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
            killsText:SetPoint("RIGHT", row, "RIGHT", -25, 0)
            killsText:SetJustifyH("RIGHT")
            row.killsText = killsText

            -- Per-boss play button (16x16)
            local playBtn = CreateFrame("Button", nil, row)
            playBtn:SetSize(INSTANCE_GUIDE_PLAY_BTN_SIZE, INSTANCE_GUIDE_PLAY_BTN_SIZE)
            playBtn:SetPoint("RIGHT", row, "RIGHT", -2, 0)

            local playBg = playBtn:CreateTexture(nil, "BACKGROUND")
            playBg:SetAllPoints(playBtn)
            playBg:SetTexture(TEX_WHITE8X8)
            playBg:SetVertexColor(0.2, 0.5, 0.2, 0.8)
            playBtn.bg = playBg

            local playIcon = playBtn:CreateTexture(nil, "OVERLAY")
            playIcon:SetSize(12, 12)
            playIcon:SetPoint("CENTER", playBtn, "CENTER", 1, 0)
            playIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            playIcon:SetVertexColor(0.7, 1, 0.7)
            playBtn.icon = playIcon

            playBtn:SetScript("OnClick", function(btn)
                local r = btn:GetParent()
                CritterUI:PlayInstanceGuideTipsForBoss(r.bossKey, r.bossName)
            end)
            playBtn:SetScript("OnEnter", function(btn)
                btn.bg:SetVertexColor(0.3, 0.7, 0.3, 1)
            end)
            playBtn:SetScript("OnLeave", function(btn)
                if CritterUI.instanceGuidePlayingBossKey == btn:GetParent().bossKey then
                    btn.bg:SetVertexColor(0.5, 0.2, 0.2, 0.8)
                else
                    btn.bg:SetVertexColor(0.2, 0.5, 0.2, 0.8)
                end
            end)
            row.playBtn = playBtn

            -- Detail frame (hidden by default, shown when expanded)
            local detail = CreateFrame("Frame", nil, row)
            detail:SetSize(contentWidth - 14, 28)
            detail:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED + 2)

            local tipPreview = detail:CreateFontString(nil, "OVERLAY")
            tipPreview:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 8, "")
            tipPreview:SetPoint("TOPLEFT", detail, "TOPLEFT", 0, 0)
            tipPreview:SetWidth(contentWidth - 18)
            tipPreview:SetJustifyH("LEFT")
            tipPreview:SetJustifyV("TOP")
            tipPreview:SetMaxLines(2)
            tipPreview:SetTextColor(0.6, 0.6, 0.6)
            detail.tipPreview = tipPreview

            detail:Hide()
            row.detail = detail
            row.isExpanded = false

            -- Click row to expand/collapse
            row:SetScript("OnClick", function(rowFrame)
                CritterUI:ToggleBossRowExpanded(rowFrame)
            end)

            row:SetScript("OnEnter", function(rowFrame)
                rowFrame.nameText:SetTextColor(unpack(COLOR_GOLD))
            end)
            row:SetScript("OnLeave", function(rowFrame)
                rowFrame.nameText:SetTextColor(0.9, 0.9, 0.9)
            end)

            panel.bossRows[i] = row
        end

        -- Reset expansion state for this row
        row.isExpanded = false
        row.expandInd:SetText(">")
        row.detail:Hide()
        row:SetHeight(INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED)

        -- Update boss name
        row.nameText:SetText(bossData.name)
        row.nameText:SetTextColor(0.9, 0.9, 0.9)

        -- Get boss stats
        local bossBestTime = nil
        local bossKills = 0

        if self.instanceGuideIsRaid then
            -- Raid: use journal bossKills
            local charDb = HopeAddon.charDb
            if charDb and charDb.journal and charDb.journal.bossKills then
                local killKey = instanceKey .. "_" .. (bossData.key or "")
                local killData = charDb.journal.bossKills[killKey]
                if killData then
                    bossKills = killData.totalKills or 0
                    bossBestTime = killData.bestTime
                end
            end
        else
            -- Dungeon: use bossStats
            local bossStats = db and db.bossStats and db.bossStats[bossData.name]
            bossBestTime = bossStats and bossStats.bestTime
            bossKills = bossStats and bossStats.totalKills or 0
        end

        local bossTimeStr = "--:--"
        if bossBestTime then
            local mins = math.floor(bossBestTime / 60)
            local secs = math.floor(bossBestTime % 60)
            bossTimeStr = string.format("%d:%02d", mins, secs)
        end

        -- Update best time
        row.timeText:SetText(bossTimeStr)
        if bossBestTime then
            row.timeText:SetTextColor(0.2, 0.8, 0.2)
        else
            row.timeText:SetTextColor(0.5, 0.5, 0.5)
        end

        -- Update kill count
        row.killsText:SetText(tostring(bossKills))
        if bossKills > 0 then
            row.killsText:SetTextColor(0.9, 0.9, 0.9)
        else
            row.killsText:SetTextColor(0.5, 0.5, 0.5)
        end

        -- Store boss info on row
        row.bossKey = bossData.key or bossData.name:lower():gsub(" ", "_")
        row.bossName = bossData.name
        row.instanceKey = instanceKey

        -- Load tip preview text
        local Content = HopeAddon.CritterContent
        if Content then
            local critterId = "chomp"
            if self.currentCritter and self.currentCritter.id then
                critterId = self.currentCritter.id
            elseif HopeAddon.db and HopeAddon.db.crusadeCritter then
                critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
            end
            local tips
            if self.instanceGuideIsRaid then
                tips = Content:GetRaidBossTips(critterId, instanceKey, row.bossKey)
            else
                tips = Content:GetBossTips(critterId, row.bossKey, false)
            end
            if tips and #tips > 0 and tips[1].text then
                row.detail.tipPreview:SetText(tips[1].text)
            else
                row.detail.tipPreview:SetText("No tips available")
            end
        end

        -- Update play button state
        if self.instanceGuidePlayingBossKey == row.bossKey then
            row.playBtn.icon:SetTexture(TEX_WHITE8X8) -- stop square
            row.playBtn.icon:SetVertexColor(1, 0.5, 0.5)
            row.playBtn.bg:SetVertexColor(0.5, 0.2, 0.2, 0.8)
        else
            row.playBtn.icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up") -- play triangle
            row.playBtn.icon:SetVertexColor(0.7, 1, 0.7)
            row.playBtn.bg:SetVertexColor(0.2, 0.5, 0.2, 0.8)
        end

        row:Show()
    end

    -- Reflow rows and update scroll
    self:ReflowBossRows()

    -- "No data" fallback
    if #bosses == 0 then
        if not panel.noDataRow then
            panel.noDataRow = CreateFrame("Frame", nil, panel.bossListFrame)
            panel.noDataRow:SetSize(contentWidth, INSTANCE_GUIDE_ROW_HEIGHT)
            panel.noDataRow:SetPoint("TOPLEFT", panel.bossListFrame, "TOPLEFT", 0, 0)

            local text = panel.noDataRow:CreateFontString(nil, "OVERLAY")
            text:SetFont(HopeAddon.assets.fonts.BODY or "Fonts\\FRIZQT__.TTF", 9, "")
            text:SetPoint("CENTER", panel.noDataRow, "CENTER", 0, 0)
            text:SetText("No boss data available")
            text:SetTextColor(0.5, 0.5, 0.5)
        end
        panel.noDataRow:Show()
    elseif panel.noDataRow then
        panel.noDataRow:Hide()
    end
end

--[[
    Play boss tips for a specific boss (toggle: if already playing this boss, stop)
    @param bossKey string - Boss key
    @param bossName string - Boss display name
]]
function CritterUI:PlayInstanceGuideTipsForBoss(bossKey, bossName)
    -- Toggle: if already playing this boss, stop
    if self.instanceGuideIsPlaying and self.instanceGuidePlayingBossKey == bossKey then
        self:StopInstanceGuideTips()
        return
    end

    -- If playing a different boss, stop first
    if self.instanceGuideIsPlaying then
        self:StopInstanceGuideTips()
    end

    -- Get critter ID
    local critterId = "chomp"
    if self.currentCritter and self.currentCritter.id then
        critterId = self.currentCritter.id
    elseif HopeAddon.db and HopeAddon.db.crusadeCritter then
        critterId = HopeAddon.db.crusadeCritter.selectedCritter or "chomp"
    end

    -- Get tips for this boss (works for both dungeons and raids)
    local Content = HopeAddon.CritterContent
    if not Content then return end

    local tips
    local instanceKey = self.instanceGuideSelectedInstance
    if self.instanceGuideIsRaid then
        tips = Content:GetRaidBossTips(critterId, instanceKey, bossKey)
    else
        tips = Content:GetBossTips(critterId, bossKey, false)
    end

    if not tips or #tips == 0 then
        self:ShowSpeechBubble("No tips for " .. (bossName or "this boss") .. "!", 3)
        return
    end

    -- Setup playback state
    self.instanceGuideTipsQueue = tips
    self.instanceGuideCurrentTipIndex = 0
    self.instanceGuideIsPlaying = true
    self.instanceGuidePlayingBossKey = bossKey

    -- Update this boss row's play button
    self:UpdateBossRowPlayButton(bossKey, true)

    -- Show first tip
    self:ShowNextInstanceGuideTip()
end

--[[
    Show the next tip in the queue
]]
function CritterUI:ShowNextInstanceGuideTip()
    if not self.instanceGuideIsPlaying then return end

    self.instanceGuideCurrentTipIndex = self.instanceGuideCurrentTipIndex + 1

    if self.instanceGuideCurrentTipIndex > #self.instanceGuideTipsQueue then
        -- All tips shown, stop
        self:StopInstanceGuideTips()
        return
    end

    local tip = self.instanceGuideTipsQueue[self.instanceGuideCurrentTipIndex]
    if tip and tip.text then
        -- Show tip in speech bubble
        self:ShowSpeechBubble(tip.text, INSTANCE_GUIDE_TIP_DURATION, function()
            -- Schedule next tip after bubble hides
            if self.instanceGuideIsPlaying and HopeAddon.Timer then
                self.instanceGuideTicker = HopeAddon.Timer:After(0.5, function()
                    self:ShowNextInstanceGuideTip()
                end)
            end
        end)
    else
        -- Skip to next tip if this one is invalid
        self:ShowNextInstanceGuideTip()
    end
end

--[[
    Stop playing raid guide tips
]]
function CritterUI:StopInstanceGuideTips()
    local prevBossKey = self.instanceGuidePlayingBossKey

    self.instanceGuideIsPlaying = false
    self.instanceGuideTipsQueue = {}
    self.instanceGuideCurrentTipIndex = 0
    self.instanceGuidePlayingBossKey = nil

    -- Cancel any pending ticker
    if self.instanceGuideTicker then
        self.instanceGuideTicker:Cancel()
        self.instanceGuideTicker = nil
    end

    -- Hide speech bubble
    self:HideSpeechBubble()

    -- Reset the previously playing boss's button
    if prevBossKey then
        self:UpdateBossRowPlayButton(prevBossKey, false)
    end
end

--[[
    Update a specific boss row's play button appearance
    @param bossKey string - Boss key to find the row
    @param isPlaying boolean - Whether this boss is currently playing
]]
function CritterUI:UpdateBossRowPlayButton(bossKey, isPlaying)
    if not self.instanceGuidePanel or not self.instanceGuidePanel.bossRows then return end

    for _, row in ipairs(self.instanceGuidePanel.bossRows) do
        if row.bossKey == bossKey and row:IsShown() then
            if isPlaying then
                row.playBtn.icon:SetTexture(TEX_WHITE8X8) -- stop square
                row.playBtn.icon:SetVertexColor(1, 0.5, 0.5)
                row.playBtn.bg:SetVertexColor(0.5, 0.2, 0.2, 0.8)
            else
                row.playBtn.icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up") -- play triangle
                row.playBtn.icon:SetVertexColor(0.7, 1, 0.7)
                row.playBtn.bg:SetVertexColor(0.2, 0.5, 0.2, 0.8)
            end
            break
        end
    end
end

--[[
    Toggle a boss row between expanded and collapsed state
    @param row Frame - The boss row to toggle
]]
function CritterUI:ToggleBossRowExpanded(row)
    if not row then return end

    row.isExpanded = not row.isExpanded

    if row.isExpanded then
        row:SetHeight(INSTANCE_GUIDE_ROW_HEIGHT_EXPANDED)
        row.expandInd:SetText("v")
        row.detail:Show()
    else
        row:SetHeight(INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED)
        row.expandInd:SetText(">")
        row.detail:Hide()
    end

    self:ReflowBossRows()
end

--[[
    Reposition all visible boss rows after expand/collapse changes
]]
function CritterUI:ReflowBossRows()
    if not self.instanceGuidePanel then return end
    local panel = self.instanceGuidePanel
    if not panel.bossRows then return end

    local yOffset = 0
    local count = panel.bossCount or 0
    for i = 1, count do
        local row = panel.bossRows[i]
        if row and row:IsShown() then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", panel.bossListFrame, "TOPLEFT", 0, -yOffset)
            local rowH = row.isExpanded and INSTANCE_GUIDE_ROW_HEIGHT_EXPANDED or INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED
            yOffset = yOffset + rowH
        end
    end

    -- Update bossListFrame total height for scrolling
    panel.bossListFrame:SetHeight(math.max(yOffset, 1))

    -- Clamp scroll offset
    local maxScroll = math.max(0, yOffset - INSTANCE_GUIDE_BOSS_SCROLL_HEIGHT)
    panel.bossScrollOffset = panel.bossScrollOffset or 0
    if panel.bossScrollOffset > maxScroll then
        panel.bossScrollOffset = maxScroll
    end
    if panel.bossScrollFrame then
        panel.bossScrollFrame:SetVerticalScroll(panel.bossScrollOffset)
    end
end

--[[
    Handle mouse wheel scrolling of the boss list
    @param delta number - Scroll direction (+1 up, -1 down)
]]
function CritterUI:ScrollBossList(delta)
    if not self.instanceGuidePanel then return end
    local panel = self.instanceGuidePanel
    if not panel.bossScrollFrame then return end

    local scrollStep = INSTANCE_GUIDE_ROW_HEIGHT_COLLAPSED
    panel.bossScrollOffset = panel.bossScrollOffset or 0
    panel.bossScrollOffset = panel.bossScrollOffset - (delta * scrollStep)

    -- Clamp
    local totalHeight = panel.bossListFrame:GetHeight() or 0
    local maxScroll = math.max(0, totalHeight - INSTANCE_GUIDE_BOSS_SCROLL_HEIGHT)
    if panel.bossScrollOffset < 0 then
        panel.bossScrollOffset = 0
    elseif panel.bossScrollOffset > maxScroll then
        panel.bossScrollOffset = maxScroll
    end

    panel.bossScrollFrame:SetVerticalScroll(panel.bossScrollOffset)
end

--[[
    Show the instance guide panel
]]
function CritterUI:ShowInstanceGuidePanel()
    if not self.instanceGuidePanel then
        self:CreateInstanceGuidePanel()
    end

    -- Load saved state
    self:LoadInstanceGuideState()

    -- Update expanded state
    if self.instanceGuidePanel then
        local panel = self.instanceGuidePanel
        local content = panel.content
        local indicator = panel.indicator

        if self.instanceGuideIsExpanded then
            panel:SetHeight(INSTANCE_GUIDE_HEADER_HEIGHT + INSTANCE_GUIDE_CONTENT_HEIGHT)
            if content then content:Show() end
            if indicator then indicator:SetTexCoord(0, 1, 1, 0) end -- down arrow
        else
            panel:SetHeight(INSTANCE_GUIDE_COLLAPSED_HEIGHT)
            if content then content:Hide() end
            if indicator then indicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) end -- right arrow
        end

        panel:Show()
    end
end

--[[
    Hide the instance guide panel
]]
function CritterUI:HideInstanceGuidePanel()
    if self.instanceGuidePanel then
        self.instanceGuidePanel:Hide()
    end

    -- Stop any playing tips
    self:StopInstanceGuideTips()
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function CritterUI:OnInitialize()
    -- Create frames on demand
end

function CritterUI:OnEnable()
    HopeAddon:Debug("CritterUI module enabled")
end

function CritterUI:OnDisable()
    self:StopBobbing()

    -- Stop idle quip timer
    self:StopIdleQuipTimer()

    -- Cancel bubble bounce animation
    if self.bubbleBounceAnim then
        self.bubbleBounceAnim:Cancel()
        self.bubbleBounceAnim = nil
    end

    if self.bubbleTimer then
        self.bubbleTimer:Cancel()
        self.bubbleTimer = nil
    end

    -- Cancel popup timers
    if self.bossPopupTimer then
        self.bossPopupTimer:Cancel()
        self.bossPopupTimer = nil
    end

    if self.unlockTimer then
        self.unlockTimer:Cancel()
        self.unlockTimer = nil
    end

    if self.unlockPopup then
        self.unlockPopup:Hide()
        self.unlockPopup:SetParent(nil)
        self.unlockPopup = nil
    end

    -- Cancel slide animation
    if self.slideAnimation then
        HopeAddon.Animations:Stop(self.slideAnimation)
        self.slideAnimation = nil
    end

    -- Clean up any active charts
    if self.bossPopup and self.bossPopup.chart then
        self:CleanupChart(self.bossPopup.chart)
        self.bossPopup.chart = nil
    end

    if self.statsWindow and self.statsWindow.chart then
        self:CleanupChart(self.statsWindow.chart)
        self.statsWindow.chart = nil
    end

    if self.housingContainer then
        -- Stop glow animation
        if self.housingContainer.glowAG then
            self.housingContainer.glowAG:Stop()
        end
        self.housingContainer:Hide()
    end
    if self.tabButton then
        self.tabButton:Hide()
    end
    if self.speechBubble then
        self.speechBubble:Hide()
    end
    if self.bossPopup then
        self.bossPopup:Hide()
    end
    if self.statsWindow then
        self.statsWindow:Hide()
    end
    if self.selectorPopup then
        self.selectorPopup:Hide()
    end

    -- Clean up new combined stats and tips panels
    if self.combinedStatsTimer then
        self.combinedStatsTimer:Cancel()
        self.combinedStatsTimer = nil
    end
    if self.combinedStatsWindow then
        self.combinedStatsWindow:Hide()
    end
    if self.tipsTypewriterTicker then
        self.tipsTypewriterTicker:Cancel()
        self.tipsTypewriterTicker = nil
    end
    if self.bossTipsPanel then
        self.bossTipsPanel:Hide()
    end
    self.bossTipsState = nil

    -- Clean up instance guide panel
    self:StopInstanceGuideTips()
    if self.instanceGuidePanel then
        self.instanceGuidePanel:Hide()
    end
    if self.instanceGuideTierDropdown then
        self.instanceGuideTierDropdown:Hide()
    end
    if self.instanceGuideInstanceDropdown then
        self.instanceGuideInstanceDropdown:Hide()
    end
    self.instanceGuidePlayingBossKey = nil

    if self.statsButton then
        self.statsButton:Hide()
    end

    self.isHousingOpen = false

    HopeAddon:Debug("CritterUI module disabled")
end
