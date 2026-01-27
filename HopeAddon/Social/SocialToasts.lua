--[[
    HopeAddon SocialToasts Module
    Non-intrusive toast notifications for social events

    Features:
    - Slide-in notifications from top right
    - Auto-dismiss after 5 seconds
    - Click to dismiss
    - Stack up to 3 toasts
    - Different colors/icons per event type
]]

local SocialToasts = {}
HopeAddon.SocialToasts = SocialToasts
HopeAddon:RegisterModule("SocialToasts", SocialToasts)

--============================================================
-- CONSTANTS
--============================================================

local TOAST_DURATION = 5  -- seconds
local TOAST_WIDTH = 250
local TOAST_HEIGHT = 50
local MAX_TOASTS = 3
local TOAST_SPACING = 55
local TOAST_PADDING = 20  -- From edge of screen

-- Toast types and their configurations
local TOAST_TYPES = {
    companion_online = {
        icon = "Interface\\Icons\\Spell_Nature_Rejuvenation",
        color = { 0, 1, 0 },
        sound = "notification",
    },
    companion_request = {
        icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
        color = { 1, 0.84, 0 },
        sound = "notification",
    },
    mug_received = {
        icon = "Interface\\Icons\\INV_Drink_10",
        color = { 1, 0.84, 0 },
        sound = "click",
    },
    loot_shared = {
        icon = "Interface\\Icons\\INV_Misc_Bag_10_Green",
        color = { 0.5, 1, 0.5 },
        sound = "notification",
    },
    -- Romance toasts
    romance_proposal = {
        icon = "Interface\\Icons\\INV_ValentinesCandy",
        color = { 1, 0.41, 0.71 },  -- Hot pink
        sound = "notification",
    },
    romance_accepted = {
        icon = "Interface\\Icons\\INV_ValentinesCard02",
        color = { 1, 0.08, 0.58 },  -- Deep pink
        sound = "notification",
    },
    romance_declined = {
        icon = "Interface\\Icons\\INV_ValentinesCard01",
        color = { 0.5, 0.5, 0.5 },  -- Grey
        sound = "notification",
    },
    romance_breakup = {
        icon = "Interface\\Icons\\Spell_Shadow_SoulLeech_3",  -- Dark sad icon
        color = { 0.5, 0.5, 0.5 },
        sound = "notification",
    },
    -- Calendar event toasts
    event_reminder = {
        icon = "Interface\\Icons\\INV_Misc_Note_02",  -- Calendar scroll
        color = { 1, 0.84, 0 },  -- Gold
        sound = "notification",
    },
    event_signup = {
        icon = "Interface\\Icons\\Spell_Holy_ChampionsBond",  -- Person icon
        color = { 0.4, 0.8, 0.4 },  -- Green
        sound = "click",
    },
}

--============================================================
-- MODULE STATE
--============================================================

SocialToasts.activeToasts = {}
SocialToasts.toastPool = nil

--============================================================
-- FRAME POOL
--============================================================

local function CreateToastFrame()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(TOAST_WIDTH, TOAST_HEIGHT)
    frame:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)

    -- Icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", frame, "LEFT", 10, 0)
    frame.icon = icon

    -- Message text
    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    text:SetPoint("RIGHT", frame, "RIGHT", -30, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    frame.text = text

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

    local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(HopeAddon.assets.fonts.SMALL, 14, "")
    closeText:SetPoint("CENTER")
    closeText:SetText("|cFF808080×|r")
    closeBtn.text = closeText

    closeBtn:SetScript("OnEnter", function(self)
        self.text:SetText("|cFFFFFFFF×|r")
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self.text:SetText("|cFF808080×|r")
    end)
    closeBtn:SetScript("OnClick", function()
        SocialToasts:DismissToast(frame)
    end)

    -- Also dismiss on clicking anywhere on the toast
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function()
        SocialToasts:DismissToast(frame)
    end)

    frame:Hide()
    return frame
end

local function ResetToastFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    if frame.dismissTimer then
        frame.dismissTimer:Cancel()
        frame.dismissTimer = nil
    end
end

function SocialToasts:CreateFramePool()
    self.toastPool = HopeAddon.FramePool:NewNamed("SocialToasts", CreateToastFrame, ResetToastFrame)
end

--============================================================
-- TOAST DISPLAY
--============================================================

--[[
    Show a toast notification
    @param toastType string - Type from TOAST_TYPES
    @param playerName string - Player involved
    @param customMessage string|nil - Optional custom message
]]
function SocialToasts:Show(toastType, playerName, customMessage)
    -- Check if enabled
    local social = HopeAddon.charDb and HopeAddon.charDb.social
    local settings = social and social.toasts

    if settings and not settings.enabled then return end

    -- Check specific setting (convert toast_type to camelCase key)
    local typeKey = toastType:gsub("_(%l)", string.upper):gsub("^%l", string.upper)
    if settings and settings[typeKey] == false then return end

    local typeInfo = TOAST_TYPES[toastType]
    if not typeInfo then
        HopeAddon:Debug("SocialToasts: Unknown toast type:", toastType)
        return
    end

    -- Check max toasts - dismiss oldest if at limit
    if #self.activeToasts >= MAX_TOASTS then
        self:DismissToast(self.activeToasts[1])
    end

    -- Acquire frame from pool
    local frame = self.toastPool:Acquire()
    frame.icon:SetTexture(typeInfo.icon)
    frame:SetBackdropBorderColor(typeInfo.color[1], typeInfo.color[2], typeInfo.color[3], 1)

    -- Build message
    local message = customMessage
    if not message then
        if toastType == "companion_online" then
            message = "|cFF00FF00" .. playerName .. "|r is online"
        elseif toastType == "companion_request" then
            message = "|cFFFFD700" .. playerName .. "|r wants to be companions!"
        elseif toastType == "mug_received" then
            message = "|cFFFFD700" .. playerName .. "|r raised a mug to you!"
        elseif toastType == "loot_shared" then
            message = customMessage or "Loot shared!"
        else
            message = playerName or customMessage or ""
        end
    end
    frame.text:SetText(message)

    -- Position (slide in from right)
    local yOffset = -100 - (#self.activeToasts * TOAST_SPACING)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -TOAST_PADDING, yOffset)
    frame:Show()

    -- Track
    table.insert(self.activeToasts, frame)

    -- Auto-dismiss timer
    frame.dismissTimer = HopeAddon.Timer:After(TOAST_DURATION, function()
        self:DismissToast(frame)
    end)

    -- Play sound
    if HopeAddon.Sounds and typeInfo.sound then
        if typeInfo.sound == "notification" then
            HopeAddon.Sounds:PlayNotification()
        elseif typeInfo.sound == "click" then
            HopeAddon.Sounds:PlayClick()
        end
    end
end

--[[
    Dismiss a toast
    @param frame Frame - Toast frame to dismiss
]]
function SocialToasts:DismissToast(frame)
    if not frame then return end

    -- Cancel timer if exists
    if frame.dismissTimer then
        frame.dismissTimer:Cancel()
        frame.dismissTimer = nil
    end

    -- Remove from active list
    for i, toast in ipairs(self.activeToasts) do
        if toast == frame then
            table.remove(self.activeToasts, i)
            break
        end
    end

    -- Reposition remaining toasts
    for i, toast in ipairs(self.activeToasts) do
        local yOffset = -100 - ((i - 1) * TOAST_SPACING)
        toast:ClearAllPoints()
        toast:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -TOAST_PADDING, yOffset)
    end

    -- Release back to pool
    self.toastPool:Release(frame)
end

--[[
    Dismiss all active toasts
]]
function SocialToasts:DismissAll()
    while #self.activeToasts > 0 do
        self:DismissToast(self.activeToasts[1])
    end
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function SocialToasts:OnInitialize()
    -- Ensure settings exist
    if HopeAddon.charDb and HopeAddon.charDb.social then
        HopeAddon.charDb.social.toasts = HopeAddon.charDb.social.toasts or {
            enabled = true,
            CompanionOnline = true,
            CompanionNearby = true,
            CompanionRequest = true,
            MugReceived = true,
            CompanionLfrp = true,
            FellowDiscovered = true,
        }
    end
end

function SocialToasts:OnEnable()
    self:CreateFramePool()
    HopeAddon:Debug("SocialToasts module enabled")
end

function SocialToasts:OnDisable()
    -- Dismiss all active toasts
    self:DismissAll()

    if self.toastPool then
        self.toastPool:Destroy()
        self.toastPool = nil
    end

    HopeAddon:Debug("SocialToasts module disabled")
end
