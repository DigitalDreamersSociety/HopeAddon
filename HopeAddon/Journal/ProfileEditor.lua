--[[
    HopeAddon ProfileEditor Module
    UI for editing RP profiles and selecting badges/colors
]]

local ProfileEditor = {}
HopeAddon.ProfileEditor = ProfileEditor

-- UI State
ProfileEditor.frame = nil
ProfileEditor.isOpen = false

-- Constants
local FRAME_WIDTH = 450
local FRAME_HEIGHT = 550
local MARGIN = 12
local ROW_HEIGHT = 24

--============================================================
-- MAIN FRAME CREATION
--============================================================

--[[
    Create the main profile editor frame
]]
function ProfileEditor:CreateFrame()
    if self.frame then return self.frame end

    local frame = CreateFrame("Frame", "HopeAddonProfileEditor", UIParent)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    -- Backdrop
    frame:SetBackdrop({
        bgFile = HopeAddon.assets.textures.DIALOG_BG,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(HopeAddon:GetBgColor("DARK_OPAQUE"))

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    title:SetPoint("TOP", 0, -16)
    title:SetText("|cFFFFD700RP Profile|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() ProfileEditor:Hide() end)

    -- Create scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -36, 50)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(FRAME_WIDTH - 60, 700)
    scrollFrame:SetScrollChild(content)
    frame.content = content

    -- Build UI elements
    self:CreateProfileFields(content)
    self:CreateBadgeSection(content)
    self:CreateSettingsSection(content)

    -- Save button
    local saveBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 24)
    saveBtn:SetPoint("BOTTOM", 0, 16)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function() ProfileEditor:SaveProfile() end)

    self.frame = frame
    return frame
end

--============================================================
-- PROFILE FIELDS
--============================================================

function ProfileEditor:CreateProfileFields(parent)
    local yOffset = -10
    local fieldWidth = FRAME_WIDTH - 80

    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    header:SetPoint("TOPLEFT", MARGIN, yOffset)
    header:SetText("|cFF00BFFFCharacter Profile|r")
    yOffset = yOffset - 25

    -- Status dropdown
    local statusLabel = parent:CreateFontString(nil, "OVERLAY")
    statusLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    statusLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    statusLabel:SetText("RP Status:")
    yOffset = yOffset - 20

    local statusDropdown = self:CreateDropdown(parent, "StatusDropdown", fieldWidth, yOffset)
    self.statusDropdown = statusDropdown
    yOffset = yOffset - 35

    -- Pronouns
    local pronounsLabel = parent:CreateFontString(nil, "OVERLAY")
    pronounsLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    pronounsLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    pronounsLabel:SetText("Pronouns (optional):")
    yOffset = yOffset - 18

    local pronounsBox = self:CreateEditBox(parent, fieldWidth, 24)
    pronounsBox:SetPoint("TOPLEFT", MARGIN, yOffset)
    pronounsBox:SetMaxLetters(30)
    self.pronounsBox = pronounsBox
    yOffset = yOffset - 32

    -- Backstory
    local backstoryLabel = parent:CreateFontString(nil, "OVERLAY")
    backstoryLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    backstoryLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    backstoryLabel:SetText("Backstory:")
    yOffset = yOffset - 18

    local backstoryBox = self:CreateMultiLineEditBox(parent, fieldWidth, 80)
    backstoryBox:SetPoint("TOPLEFT", MARGIN, yOffset)
    backstoryBox:SetMaxLetters(500)
    self.backstoryBox = backstoryBox
    yOffset = yOffset - 88

    -- Appearance
    local appearanceLabel = parent:CreateFontString(nil, "OVERLAY")
    appearanceLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    appearanceLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    appearanceLabel:SetText("Physical Appearance:")
    yOffset = yOffset - 18

    local appearanceBox = self:CreateMultiLineEditBox(parent, fieldWidth, 60)
    appearanceBox:SetPoint("TOPLEFT", MARGIN, yOffset)
    appearanceBox:SetMaxLetters(300)
    self.appearanceBox = appearanceBox
    yOffset = yOffset - 68

    -- RP Hooks
    local hooksLabel = parent:CreateFontString(nil, "OVERLAY")
    hooksLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    hooksLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    hooksLabel:SetText("RP Hooks / Rumors:")
    yOffset = yOffset - 18

    local hooksBox = self:CreateMultiLineEditBox(parent, fieldWidth, 60)
    hooksBox:SetPoint("TOPLEFT", MARGIN, yOffset)
    hooksBox:SetMaxLetters(300)
    self.hooksBox = hooksBox
    yOffset = yOffset - 68

    -- Personality traits
    local traitsLabel = parent:CreateFontString(nil, "OVERLAY")
    traitsLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    traitsLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    traitsLabel:SetText("Personality Traits (select up to 5):")
    yOffset = yOffset - 20

    self.traitCheckboxes = {}
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    local traits = FellowTravelers and FellowTravelers.PERSONALITY_TRAITS or {}
    local col = 0
    local row = 0
    local checkWidth = 110

    for i, trait in ipairs(traits) do
        local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        checkbox:SetSize(20, 20)
        checkbox:SetPoint("TOPLEFT", MARGIN + (col * checkWidth), yOffset - (row * 22))

        local label = checkbox:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
        label:SetText(trait)
        checkbox.traitName = trait

        checkbox:SetScript("OnClick", function(self)
            ProfileEditor:OnTraitToggled(self)
        end)

        self.traitCheckboxes[trait] = checkbox

        col = col + 1
        if col >= 3 then
            col = 0
            row = row + 1
        end
    end

    yOffset = yOffset - (math.ceil(#traits / 3) * 22) - 10
    self.traitsEndY = yOffset

    return yOffset
end

--============================================================
-- BADGE SECTION
--============================================================

function ProfileEditor:CreateBadgeSection(parent)
    local yOffset = self.traitsEndY or -400

    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    header:SetPoint("TOPLEFT", MARGIN, yOffset)
    header:SetText("|cFFFFD700Badge Rewards|r")
    yOffset = yOffset - 25

    -- Name color dropdown
    local colorLabel = parent:CreateFontString(nil, "OVERLAY")
    colorLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    colorLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    colorLabel:SetText("Display Color (from badges):")
    yOffset = yOffset - 20

    local colorDropdown = self:CreateDropdown(parent, "ColorDropdown", FRAME_WIDTH - 80, yOffset)
    self.colorDropdown = colorDropdown
    yOffset = yOffset - 35

    -- Title dropdown
    local titleLabel = parent:CreateFontString(nil, "OVERLAY")
    titleLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    titleLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    titleLabel:SetText("Display Title (from badges):")
    yOffset = yOffset - 20

    local titleDropdown = self:CreateDropdown(parent, "TitleDropdown", FRAME_WIDTH - 80, yOffset)
    self.titleDropdown = titleDropdown
    yOffset = yOffset - 35

    -- Badge list preview
    local badgeLabel = parent:CreateFontString(nil, "OVERLAY")
    badgeLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    badgeLabel:SetPoint("TOPLEFT", MARGIN, yOffset)
    badgeLabel:SetText("Unlocked Badges:")
    yOffset = yOffset - 18

    self.badgeListText = parent:CreateFontString(nil, "OVERLAY")
    self.badgeListText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    self.badgeListText:SetPoint("TOPLEFT", MARGIN, yOffset)
    self.badgeListText:SetWidth(FRAME_WIDTH - 80)
    self.badgeListText:SetJustifyH("LEFT")
    self.badgeListText:SetText("None unlocked yet")

    self.badgeSectionEndY = yOffset - 40
    return yOffset
end

--============================================================
-- SETTINGS SECTION
--============================================================

function ProfileEditor:CreateSettingsSection(parent)
    local yOffset = self.badgeSectionEndY or -500

    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    header:SetPoint("TOPLEFT", MARGIN, yOffset)
    header:SetText("|cFF00FF00Fellow Traveler Settings|r")
    yOffset = yOffset - 25

    -- Enable feature
    local enableCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    enableCheck:SetSize(20, 20)
    enableCheck:SetPoint("TOPLEFT", MARGIN, yOffset)
    local enableLabel = enableCheck:CreateFontString(nil, "OVERLAY")
    enableLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 4, 0)
    enableLabel:SetText("Enable Fellow Traveler detection")
    self.enableCheck = enableCheck
    yOffset = yOffset - 24

    -- Color chat names
    local chatColorCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    chatColorCheck:SetSize(20, 20)
    chatColorCheck:SetPoint("TOPLEFT", MARGIN, yOffset)
    local chatLabel = chatColorCheck:CreateFontString(nil, "OVERLAY")
    chatLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    chatLabel:SetPoint("LEFT", chatColorCheck, "RIGHT", 4, 0)
    chatLabel:SetText("Color fellow traveler names in chat")
    self.chatColorCheck = chatColorCheck
    yOffset = yOffset - 24

    -- Share profile
    local shareCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    shareCheck:SetSize(20, 20)
    shareCheck:SetPoint("TOPLEFT", MARGIN, yOffset)
    local shareLabel = shareCheck:CreateFontString(nil, "OVERLAY")
    shareLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    shareLabel:SetPoint("LEFT", shareCheck, "RIGHT", 4, 0)
    shareLabel:SetText("Share my profile with other users")
    self.shareCheck = shareCheck
    yOffset = yOffset - 24

    -- Show tooltips
    local tooltipCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    tooltipCheck:SetSize(20, 20)
    tooltipCheck:SetPoint("TOPLEFT", MARGIN, yOffset)
    local tooltipLabel = tooltipCheck:CreateFontString(nil, "OVERLAY")
    tooltipLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    tooltipLabel:SetPoint("LEFT", tooltipCheck, "RIGHT", 4, 0)
    tooltipLabel:SetText("Show profiles in tooltips")
    self.tooltipCheck = tooltipCheck

    return yOffset
end

--============================================================
-- UI HELPERS
--============================================================

function ProfileEditor:CreateEditBox(parent, width, height)
    local box = CreateFrame("EditBox", nil, parent)
    box:SetSize(width, height)
    box:SetAutoFocus(false)
    box:SetFontObject(ChatFontNormal)
    box:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 8, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    box:SetBackdropColor(HopeAddon:GetBgColor("DARK_SOLID"))
    box:SetTextInsets(5, 5, 3, 3)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return box
end

function ProfileEditor:CreateMultiLineEditBox(parent, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width, height)
    scrollFrame:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true, tileSize = 8, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    scrollFrame:SetBackdropColor(HopeAddon:GetBgColor("DARK_SOLID"))

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(width - 30)
    editBox:SetTextInsets(5, 5, 3, 3)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame.editBox = editBox

    -- Return the editBox but keep reference to scrollFrame
    editBox.scrollFrame = scrollFrame
    editBox.SetPoint = function(self, ...)
        self.scrollFrame:SetPoint(...)
    end

    return editBox
end

function ProfileEditor:CreateDropdown(parent, name, width, yOffset)
    local dropdown = CreateFrame("Frame", "HopeAddonProfileEditor" .. name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", MARGIN - 15, yOffset)
    UIDropDownMenu_SetWidth(dropdown, width - 40)
    return dropdown
end

--============================================================
-- DATA LOADING/SAVING
--============================================================

function ProfileEditor:LoadProfile()
    local profile = HopeAddon.charDb.travelers.myProfile
    local settings = HopeAddon.charDb.travelers.fellowSettings

    -- Load text fields
    if self.pronounsBox then
        self.pronounsBox:SetText(profile.pronouns or "")
    end
    if self.backstoryBox then
        self.backstoryBox:SetText(profile.backstory or "")
    end
    if self.appearanceBox then
        self.appearanceBox:SetText(profile.appearance or "")
    end
    if self.hooksBox then
        self.hooksBox:SetText(profile.rpHooks or "")
    end

    -- Load personality traits
    local selectedTraits = {}
    for _, trait in ipairs(profile.personality or {}) do
        selectedTraits[trait] = true
    end
    for trait, checkbox in pairs(self.traitCheckboxes) do
        checkbox:SetChecked(selectedTraits[trait] or false)
    end

    -- Load settings checkboxes
    if self.enableCheck then
        self.enableCheck:SetChecked(settings.enabled)
    end
    if self.chatColorCheck then
        self.chatColorCheck:SetChecked(settings.colorChat)
    end
    if self.shareCheck then
        self.shareCheck:SetChecked(settings.shareProfile)
    end
    if self.tooltipCheck then
        self.tooltipCheck:SetChecked(settings.showTooltips)
    end

    -- Initialize dropdowns
    self:InitializeStatusDropdown()
    self:InitializeColorDropdown()
    self:InitializeTitleDropdown()
    self:UpdateBadgeList()
end

function ProfileEditor:SaveProfile()
    local profile = HopeAddon.charDb.travelers.myProfile
    local settings = HopeAddon.charDb.travelers.fellowSettings

    -- Save text fields
    profile.pronouns = self.pronounsBox and self.pronounsBox:GetText() or ""
    profile.backstory = self.backstoryBox and self.backstoryBox:GetText() or ""
    profile.appearance = self.appearanceBox and self.appearanceBox:GetText() or ""
    profile.rpHooks = self.hooksBox and self.hooksBox:GetText() or ""

    -- Save personality traits
    profile.personality = {}
    for trait, checkbox in pairs(self.traitCheckboxes) do
        if checkbox:GetChecked() then
            table.insert(profile.personality, trait)
        end
    end

    -- Save settings
    settings.enabled = self.enableCheck and self.enableCheck:GetChecked() or false
    settings.colorChat = self.chatColorCheck and self.chatColorCheck:GetChecked() or false
    settings.shareProfile = self.shareCheck and self.shareCheck:GetChecked() or false
    settings.showTooltips = self.tooltipCheck and self.tooltipCheck:GetChecked() or false

    HopeAddon:Print("Profile saved!")
    self:Hide()
end

--============================================================
-- DROPDOWN INITIALIZATION
--============================================================

function ProfileEditor:InitializeStatusDropdown()
    local dropdown = self.statusDropdown
    if not dropdown then return end

    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    local options = FellowTravelers and FellowTravelers.STATUS_OPTIONS or {}
    local profile = HopeAddon.charDb.travelers.myProfile

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, opt in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = "|cFF" .. opt.color .. opt.label .. "|r"
            info.value = opt.id
            info.func = function()
                profile.status = opt.id
                UIDropDownMenu_SetText(dropdown, "|cFF" .. opt.color .. opt.label .. "|r")
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Set current value
    local currentStatus = profile.status or "OOC"
    for _, opt in ipairs(options) do
        if opt.id == currentStatus then
            UIDropDownMenu_SetText(dropdown, "|cFF" .. opt.color .. opt.label .. "|r")
            break
        end
    end
end

function ProfileEditor:InitializeColorDropdown()
    local dropdown = self.colorDropdown
    if not dropdown then return end

    local Badges = HopeAddon.Badges
    local profile = HopeAddon.charDb.travelers.myProfile

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        -- Default option
        local info = UIDropDownMenu_CreateInfo()
        info.text = "|cFF00FF00Default (Green)|r"
        info.value = nil
        info.func = function()
            profile.selectedColor = nil
            UIDropDownMenu_SetText(dropdown, "|cFF00FF00Default (Green)|r")
        end
        UIDropDownMenu_AddButton(info, level)

        -- Unlocked colors from badges
        if Badges then
            local colors = Badges:GetUnlockedColors()
            for _, colorData in ipairs(colors) do
                info = UIDropDownMenu_CreateInfo()
                info.text = "|cFF" .. colorData.colorHex .. colorData.colorName .. "|r (" .. colorData.badgeName .. ")"
                info.value = colorData.colorHex
                info.func = function()
                    profile.selectedColor = colorData.colorHex
                    UIDropDownMenu_SetText(dropdown, "|cFF" .. colorData.colorHex .. colorData.colorName .. "|r")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Set current value
    local currentColor = profile.selectedColor
    if currentColor then
        local Badges = HopeAddon.Badges
        if Badges then
            local colors = Badges:GetUnlockedColors()
            for _, colorData in ipairs(colors) do
                if colorData.colorHex == currentColor then
                    UIDropDownMenu_SetText(dropdown, "|cFF" .. colorData.colorHex .. colorData.colorName .. "|r")
                    return
                end
            end
        end
    end
    UIDropDownMenu_SetText(dropdown, "|cFF00FF00Default (Green)|r")
end

function ProfileEditor:InitializeTitleDropdown()
    local dropdown = self.titleDropdown
    if not dropdown then return end

    local Badges = HopeAddon.Badges
    local profile = HopeAddon.charDb.travelers.myProfile

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        -- No title option
        local info = UIDropDownMenu_CreateInfo()
        info.text = "None"
        info.value = nil
        info.func = function()
            profile.selectedTitle = nil
            UIDropDownMenu_SetText(dropdown, "None")
        end
        UIDropDownMenu_AddButton(info, level)

        -- Unlocked titles from badges
        if Badges then
            local titles = Badges:GetUnlockedTitles()
            for _, titleData in ipairs(titles) do
                info = UIDropDownMenu_CreateInfo()
                info.text = "|cFFFFD700" .. titleData.title .. "|r (" .. titleData.badgeName .. ")"
                info.value = titleData.title
                info.func = function()
                    profile.selectedTitle = titleData.title
                    UIDropDownMenu_SetText(dropdown, "|cFFFFD700" .. titleData.title .. "|r")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Set current value
    local currentTitle = profile.selectedTitle
    if currentTitle then
        UIDropDownMenu_SetText(dropdown, "|cFFFFD700" .. currentTitle .. "|r")
    else
        UIDropDownMenu_SetText(dropdown, "None")
    end
end

function ProfileEditor:UpdateBadgeList()
    if not self.badgeListText then return end

    local Badges = HopeAddon.Badges
    if not Badges then
        self.badgeListText:SetText("Badge system not loaded")
        return
    end

    local allBadges = Badges:GetAllBadgesWithStatus()
    local unlockedNames = {}

    for _, badge in ipairs(allBadges) do
        if badge.unlocked then
            table.insert(unlockedNames, "|cFFFFD700" .. badge.definition.name .. "|r")
        end
    end

    if #unlockedNames > 0 then
        self.badgeListText:SetText(table.concat(unlockedNames, ", "))
    else
        self.badgeListText:SetText("|cFF808080None unlocked yet - keep adventuring!|r")
    end
end

--============================================================
-- TRAIT HANDLING
--============================================================

function ProfileEditor:OnTraitToggled(checkbox)
    -- Count selected traits
    local count = 0
    for _, cb in pairs(self.traitCheckboxes) do
        if cb:GetChecked() then
            count = count + 1
        end
    end

    -- Limit to 5 traits
    if count > 5 then
        checkbox:SetChecked(false)
        HopeAddon:Print("You can only select up to 5 personality traits.")
    end
end

--============================================================
-- SHOW/HIDE
--============================================================

function ProfileEditor:Show()
    if not self.frame then
        self:CreateFrame()
    end
    self:LoadProfile()
    self.frame:Show()
    self.isOpen = true
end

function ProfileEditor:Hide()
    if self.frame then
        self.frame:Hide()
    end
    self.isOpen = false
end

function ProfileEditor:Toggle()
    if self.isOpen then
        self:Hide()
    else
        self:Show()
    end
end

--============================================================
-- SLASH COMMAND
--============================================================

SLASH_HOPEPROFILE1 = "/hopeprofile"
SLASH_HOPEPROFILE2 = "/profile"
SlashCmdList["HOPEPROFILE"] = function(msg)
    ProfileEditor:Toggle()
end

HopeAddon:Debug("ProfileEditor module loaded")
