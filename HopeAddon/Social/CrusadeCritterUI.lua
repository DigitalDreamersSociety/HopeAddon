--[[
    HopeAddon Crusade Critter UI
    Tab-out housing panel with mascot container, speech bubble, popups, and stats window

    Visual specs:
    - Tab button on right screen edge (24x60px)
    - Housing container slides out (120x140px)
    - 64x64 3D model with soft glow (96px)
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

local MODEL_SIZE = 64
local GLOW_SIZE = 96
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

-- Glow texture for soft circular effect
local GLOW_TEXTURE = "Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64"

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
CritterUI.testPanel = nil
CritterUI.selectorPopup = nil
CritterUI.isHousingOpen = false
CritterUI.wasOpenBeforeCombat = false
CritterUI.slideAnimation = nil

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

    local tab = CreateFrame("Button", "HopeCrusadeCritterTab", UIParent)
    tab:SetSize(TAB_WIDTH, TAB_HEIGHT)
    tab:SetFrameStrata("MEDIUM")
    tab:SetFrameLevel(99)

    -- Position on right edge, below minimap
    tab:SetPoint("RIGHT", UIParent, "RIGHT", -50, HOUSING_Y_OFFSET)

    -- Dark background with gold border (matches addon style)
    tab:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    tab:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    tab:SetBackdropBorderColor(1, 0.84, 0, 0.8)

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
    highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 0.84, 0, 0.2)

    -- Click handler
    tab:SetScript("OnClick", function()
        self:ToggleHousing()
    end)

    -- Tooltip
    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Crusade Critter", 1, 0.84, 0)
        GameTooltip:AddLine("Click to toggle mascot", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.tabButton = tab
    return tab
end

--[[
    Update the tab icon based on current critter
]]
function CritterUI:UpdateTabIcon()
    if not self.tabButton or not self.tabButton.icon then return end

    -- Map critter IDs to appropriate icons
    local iconMap = {
        flux = "Interface\\Icons\\INV_Pet_ManaWyrm",
        snookimp = "Interface\\Icons\\Spell_Shadow_SummonImp",
        shred = "Interface\\Icons\\INV_Mushroom_10",
        emo = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
        cosmo = "Interface\\Icons\\INV_Moth",
        boomer = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
        diva = "Interface\\Icons\\INV_Pet_PhoenixPet",
    }

    local critterId = "flux"
    if self.currentCritter and self.currentCritter.id then
        critterId = self.currentCritter.id
    elseif HopeAddon.db and HopeAddon.db.crusadeCritter then
        critterId = HopeAddon.db.crusadeCritter.selectedCritter or "flux"
    end

    local icon = iconMap[critterId] or iconMap.flux
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

    local housing = CreateFrame("Frame", "HopeCrusadeCritterHousing", UIParent)
    housing:SetSize(HOUSING_WIDTH, HOUSING_HEIGHT)
    housing:SetFrameStrata("MEDIUM")
    housing:SetFrameLevel(100) -- Above tab (99) for proper layering

    -- Position off-screen initially (will slide in)
    housing:SetPoint("RIGHT", UIParent, "RIGHT", HOUSING_WIDTH + TAB_WIDTH, HOUSING_Y_OFFSET)

    -- Dark background with subtle border
    housing:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
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
            GameTooltip:AddLine(critterData.name, 1, 0.84, 0)
            GameTooltip:AddLine(critterData.description, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click critter to select mascot", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end
    end)
    housing:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    housing:Hide()
    self.housingContainer = housing

    -- Also store reference in mascotFrame for backward compatibility
    self.mascotFrame = housing

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

    -- Show and position at starting point (off-screen)
    self.housingContainer:ClearAllPoints()
    self.housingContainer:SetPoint("RIGHT", UIParent, "RIGHT", HOUSING_WIDTH + TAB_WIDTH, HOUSING_Y_OFFSET)
    self.housingContainer:Show()

    -- Start glow animation
    if self.housingContainer.glowAG then
        self.housingContainer.glowAG:Play()
    end

    -- Animate to visible position
    local targetX = -(TAB_WIDTH + HOUSING_OFFSET_X)
    self.slideAnimation = HopeAddon.Animations:MoveTo(
        self.housingContainer,
        targetX,
        HOUSING_Y_OFFSET,
        SLIDE_DURATION,
        function()
            self.slideAnimation = nil
            -- Start bobbing after slide completes
            self:StartBobbing()
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

    -- Hide speech bubble
    self:HideSpeechBubble()

    -- Hide critter selector if open
    self:HideCritterSelector()

    -- Animate to off-screen position
    local targetX = HOUSING_WIDTH + TAB_WIDTH
    self.slideAnimation = HopeAddon.Animations:MoveTo(
        self.housingContainer,
        targetX,
        HOUSING_Y_OFFSET,
        SLIDE_DURATION,
        function()
            self.slideAnimation = nil
            self.housingContainer:Hide()
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

    local popup = CreateFrame("Frame", "HopeCrusadeCritterSelector", self.housingContainer)
    popup:SetSize(200, 180)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(200)

    -- Position to the left of housing
    popup:SetPoint("RIGHT", self.housingContainer, "LEFT", -10, 0)

    -- Dark background with gold border
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    title:SetPoint("TOP", popup, "TOP", 0, -10)
    title:SetText("Select Mascot")
    title:SetTextColor(1, 0.84, 0)
    popup.title = title

    -- Critter grid container
    local grid = CreateFrame("Frame", nil, popup)
    grid:SetSize(180, 130)
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

    -- Clear existing icons
    if grid.icons then
        for _, icon in ipairs(grid.icons) do
            icon:Hide()
            icon:SetParent(nil)
        end
    end
    grid.icons = {}

    -- Icon map for critters
    local iconMap = {
        flux = "Interface\\Icons\\INV_Pet_ManaWyrm",
        snookimp = "Interface\\Icons\\Spell_Shadow_SummonImp",
        shred = "Interface\\Icons\\INV_Mushroom_10",
        emo = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
        cosmo = "Interface\\Icons\\INV_Moth",
        boomer = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
        diva = "Interface\\Icons\\INV_Pet_PhoenixPet",
    }

    local critterOrder = { "flux", "snookimp", "shred", "emo", "cosmo", "boomer", "diva" }
    local iconSize = 40
    local spacing = 8
    local cols = 4
    local startX = 10
    local startY = -5

    for i, critterId in ipairs(critterOrder) do
        local critterData = Content.CRITTERS[critterId]
        if critterData then
            local row = math.floor((i - 1) / cols)
            local col = (i - 1) % cols

            local btn = CreateFrame("Button", nil, grid)
            btn:SetSize(iconSize, iconSize)
            btn:SetPoint("TOPLEFT", grid, "TOPLEFT", startX + col * (iconSize + spacing), startY - row * (iconSize + spacing))

            -- Icon texture
            local tex = btn:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(btn)
            tex:SetTexture(iconMap[critterId] or iconMap.flux)
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            btn.icon = tex

            -- Check if unlocked
            local isUnlocked = Critter and Critter:IsCritterUnlocked(critterId)
            local isSelected = HopeAddon.db and HopeAddon.db.crusadeCritter and
                               HopeAddon.db.crusadeCritter.selectedCritter == critterId

            if isUnlocked then
                -- Unlocked - full color
                tex:SetDesaturated(false)
                tex:SetVertexColor(1, 1, 1, 1)

                -- Selection highlight
                if isSelected then
                    local highlight = btn:CreateTexture(nil, "OVERLAY")
                    highlight:SetAllPoints(btn)
                    highlight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                    highlight:SetBlendMode("ADD")
                    highlight:SetVertexColor(1, 0.84, 0, 0.8)
                    btn.selectedHighlight = highlight
                end

                -- Click to select
                btn:SetScript("OnClick", function()
                    self:SelectCritter(critterId)
                end)

                -- Hover highlight
                local hover = btn:CreateTexture(nil, "HIGHLIGHT")
                hover:SetAllPoints(btn)
                hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
                hover:SetBlendMode("ADD")
            else
                -- Locked - grayed out
                tex:SetDesaturated(true)
                tex:SetVertexColor(0.5, 0.5, 0.5, 1)

                -- Lock overlay
                local lock = btn:CreateTexture(nil, "OVERLAY")
                lock:SetSize(16, 16)
                lock:SetPoint("CENTER", btn, "CENTER", 0, 0)
                lock:SetTexture("Interface\\LFGFRAME\\LFG-Eye")
                lock:SetVertexColor(0.8, 0.2, 0.2, 1)
                btn.lock = lock
            end

            -- Tooltip
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:AddLine(critterData.name, 1, 0.84, 0)
                GameTooltip:AddLine(critterData.description, 1, 1, 1, true)
                if not isUnlocked then
                    GameTooltip:AddLine(" ")
                    local hub = critterData.unlockHub
                    if hub and Content.DUNGEON_HUBS[hub] then
                        local completed, total = 0, 0
                        if Critter then
                            completed, total = Critter:GetHubProgress(hub)
                        end
                        GameTooltip:AddLine(string.format("Complete %s (%d/%d)",
                            Content.DUNGEON_HUBS[hub].name, completed, total), 1, 0.3, 0.3)
                    else
                        GameTooltip:AddLine("Locked", 1, 0.3, 0.3)
                    end
                elseif isSelected then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Currently selected", 0.3, 1, 0.3)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            table.insert(grid.icons, btn)
        end
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

    local model = self.housingContainer.model
    local glow = self.housingContainer.glow

    -- Set 3D model using displayID (TBC compatible)
    if critterData.displayID then
        model:SetDisplayInfo(critterData.displayID)
        model:SetPosition(0, 0, 0)
        model:SetFacing(0)
    end

    -- Set glow color
    if critterData.glowColor then
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

    local bubble = CreateFrame("Frame", nil, self.housingContainer)
    bubble:SetSize(BUBBLE_WIDTH, 60) -- Height will adjust to text

    -- Classic comic book style: white background, black border
    bubble:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
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
    tail:SetTexture("Interface\\Buttons\\WHITE8x8")
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

    -- Clear and start typewriter
    text:SetText("")
    bubble:Show()
    bubble:SetAlpha(1)

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

    local popup = CreateFrame("Frame", nil, UIParent)
    popup:SetSize(300, 140)
    popup:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)
    popup:SetFrameStrata("HIGH")
    popup:SetClampedToScreen(true)

    -- Title (boss name)
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    title:SetPoint("TOP", popup, "TOP", 0, -10)
    title:SetTextColor(1, 0.84, 0)
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
            { label = "This", timeSeconds = thisTime, color = HopeAddon.colors.TBC_PURPLE or { r = 0.61, g = 0.19, b = 1.00 } },
            { label = "Best", timeSeconds = bestTime or thisTime, color = HopeAddon.colors.TBC_GREEN or { r = 0.20, g = 0.80, b = 0.20 } },
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

    local window = CreateFrame("Frame", "HopeCrusadeCritterStats", UIParent)
    window:SetSize(450, 280)
    window:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    window:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    window:SetBackdropBorderColor(1, 0.84, 0, 1)
    window:SetFrameStrata("DIALOG")
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    window:SetClampedToScreen(true)

    -- Title
    local title = window:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 16, "")
    title:SetPoint("TOP", window, "TOP", 0, -15)
    title:SetText("DUNGEON COMPLETE!")
    title:SetTextColor(1, 0.84, 0)
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
        labelText:SetTextColor(0.7, 0.7, 0.7)

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
            { label = "This", timeSeconds = stats.thisTime or 0, color = HopeAddon.colors.TBC_PURPLE or { r = 0.61, g = 0.19, b = 1.00 } },
            { label = "Last", timeSeconds = stats.lastTime or 0, color = { r = 0.5, g = 0.5, b = 0.5 } },
            { label = "Best", timeSeconds = stats.bestTime or stats.thisTime or 0, color = HopeAddon.colors.TBC_GREEN or { r = 0.20, g = 0.80, b = 0.20 } },
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
    local popup = CreateFrame("Frame", nil, UIParent)
    popup:SetSize(350, 100)
    popup:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)
    popup:SetFrameStrata("DIALOG")
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetClampedToScreen(true)

    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText("NEW CRITTER UNLOCKED!")
    title:SetTextColor(1, 0.84, 0)

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
-- TEST PANEL
--============================================================

--[[
    Create the test panel with buttons for testing Crusade Critter features
    @return Frame - The test panel
]]
function CritterUI:CreateTestPanel()
    if self.testPanel then
        return self.testPanel
    end

    local panel = CreateFrame("Frame", "HopeCritterTestPanel", UIParent)
    panel:SetSize(140, 180)
    panel:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    panel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    panel:SetBackdropBorderColor(0.6, 0.2, 1, 1) -- Purple for test mode
    panel:SetFrameStrata("HIGH")
    panel:SetPoint("LEFT", UIParent, "CENTER", -300, 0)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetClampedToScreen(true)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    title:SetPoint("TOP", panel, "TOP", 0, -8)
    title:SetText("[TEST MODE]")
    title:SetTextColor(0.6, 0.2, 1) -- Purple

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 2, 2)
    closeBtn:SetScale(0.8)
    closeBtn:SetScript("OnClick", function()
        CritterUI:HideTestPanel()
    end)

    -- Helper to create buttons
    local buttonY = -30
    local function AddButton(label, onClick)
        local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetSize(120, 22)
        btn:SetPoint("TOP", panel, "TOP", 0, buttonY)
        btn:SetText(label)
        btn:SetScript("OnClick", onClick)
        buttonY = buttonY - 28
        return btn
    end

    -- Buttons
    AddButton("Kill Boss", function()
        if HopeAddon.CrusadeCritter then
            HopeAddon.CrusadeCritter:TestBossKill(false)
        end
    end)

    AddButton("Kill Final Boss", function()
        if HopeAddon.CrusadeCritter then
            HopeAddon.CrusadeCritter:TestBossKill(true)
        end
    end)

    AddButton("Show Unlock", function()
        CritterUI:ShowUnlockCelebration("snookimp")
    end)

    AddButton("Reset Run", function()
        if HopeAddon.CrusadeCritter then
            HopeAddon.CrusadeCritter.currentRun = nil
            HopeAddon.CrusadeCritter:EnterTestMode()
        end
    end)

    AddButton("Exit Test", function()
        if HopeAddon.CrusadeCritter then
            HopeAddon.CrusadeCritter.currentRun = nil
        end
        CritterUI:HideTestPanel()
        print("|cff9B30FF[Test Mode]|r Exited test mode")
    end)

    panel:Hide()
    self.testPanel = panel
    return panel
end

--[[
    Show the test panel
]]
function CritterUI:ShowTestPanel()
    if not self.testPanel then
        self:CreateTestPanel()
    end
    self.testPanel:Show()
end

--[[
    Hide the test panel
]]
function CritterUI:HideTestPanel()
    if self.testPanel then
        self.testPanel:Hide()
    end
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
    if self.testPanel then
        self.testPanel:Hide()
    end
    if self.selectorPopup then
        self.selectorPopup:Hide()
    end

    self.isHousingOpen = false

    HopeAddon:Debug("CritterUI module disabled")
end
