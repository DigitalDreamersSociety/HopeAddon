--[[
    KillFlash - Compact boss kill side toast
    Small right-side toast with boss icon, name, kill count, and time.
    Replaces the older fullscreen kill overlay.
]]
local KillFlash = {}
HopeAddon.KillFlash = KillFlash

-- Layout constants
local TOAST_WIDTH    = 260
local TOAST_HEIGHT   = 52
local TOAST_PADDING  = 20  -- distance from screen edge
local TOAST_TOP      = -100
local TOAST_SPACING  = 56
local MAX_TOASTS     = 3

local ICON_SIZE      = 32
local SLIDE_DISTANCE = 40
local FADE_IN        = 0.2
local FADE_OUT       = 0.3
local HOLD_DURATION  = 4.0

-- Active toast list (oldest first)
KillFlash.activeToasts = {}
-- All created frames (for HideFlash sweep)
KillFlash.allFrames = {}

local function CreateToastFrame()
    local fonts = HopeAddon.assets.fonts

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(TOAST_WIDTH, TOAST_HEIGHT)
    frame:SetBackdrop(HopeAddon.Constants.BACKDROPS.DARK_GOLD)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:Hide()
    frame:EnableMouse(true)

    local iconContainer = CreateFrame("Frame", nil, frame)
    iconContainer:SetSize(ICON_SIZE, ICON_SIZE)
    iconContainer:SetPoint("LEFT", frame, "LEFT", 10, 0)
    frame.iconContainer = iconContainer

    local bossIcon = iconContainer:CreateTexture(nil, "ARTWORK")
    bossIcon:SetAllPoints()
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.bossIcon = bossIcon

    local bossNameText = frame:CreateFontString(nil, "OVERLAY")
    bossNameText:SetFont(fonts.TITLE, 12, "")
    bossNameText:SetTextColor(1, 1, 1, 1)
    bossNameText:SetPoint("TOPLEFT", iconContainer, "TOPRIGHT", 8, -2)
    bossNameText:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
    bossNameText:SetJustifyH("LEFT")
    bossNameText:SetWordWrap(false)
    frame.bossNameText = bossNameText

    local statsText = frame:CreateFontString(nil, "OVERLAY")
    statsText:SetFont(fonts.SMALL, 10, "")
    statsText:SetPoint("BOTTOMLEFT", iconContainer, "BOTTOMRIGHT", 8, 2)
    statsText:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    statsText:SetJustifyH("LEFT")
    statsText:SetWordWrap(false)
    frame.statsText = statsText

    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(fonts.SMALL, 14, "")
    closeText:SetPoint("CENTER")
    closeText:SetText("|cFF808080\195\151|r")  -- dim ×
    closeBtn.text = closeText
    closeBtn:SetScript("OnEnter", function(self) self.text:SetText("|cFFFFFFFF\195\151|r") end)
    closeBtn:SetScript("OnLeave", function(self) self.text:SetText("|cFF808080\195\151|r") end)
    closeBtn:SetScript("OnClick", function() KillFlash:DismissToast(frame) end)
    frame.closeBtn = closeBtn

    frame:SetScript("OnMouseDown", function() KillFlash:DismissToast(frame) end)

    return frame
end

local function RepositionToasts()
    for i, toast in ipairs(KillFlash.activeToasts) do
        local yOffset = TOAST_TOP - ((i - 1) * TOAST_SPACING)
        toast:ClearAllPoints()
        toast:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -TOAST_PADDING, yOffset)
    end
end

local function AcquireToast()
    for _, frame in ipairs(KillFlash.allFrames) do
        if not frame:IsShown() then
            return frame
        end
    end
    local frame = CreateToastFrame()
    table.insert(KillFlash.allFrames, frame)
    return frame
end

--[[
    ShowFlash - Display a compact kill toast on the right edge of the screen.
    @param raidKey string
    @param bossId string
    @param killData table - {icon, bossName, totalKills, lastTime, ...}
    @param encounterSummary table|nil - Unused; kept for API compatibility.
]]
function KillFlash:ShowFlash(raidKey, bossId, killData, encounterSummary)
    local db = HopeAddon.db
    if db and db.settings and db.settings.bossKillFlashEnabled == false then
        return
    end

    -- Drop oldest if at cap
    if #self.activeToasts >= MAX_TOASTS then
        self:DismissToast(self.activeToasts[1])
    end

    local frame = AcquireToast()

    -- Resolve phase color for subtitle accent
    local RaidData = HopeAddon.RaidData
    local colorName = RaidData and RaidData:GetPhaseColorName(raidKey) or "KARA_PURPLE"
    local phaseColor = HopeAddon.colors[colorName] or { r = 0.85, g = 0.7, b = 1 }

    -- Border tinted with phase color
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)
    end

    if killData.icon then
        frame.bossIcon:SetTexture(killData.icon)
    end
    frame.bossNameText:SetText(killData.bossName or "Unknown")

    local subtitle = "Kill #" .. (killData.totalKills or 1)
        .. "  \194\183  "
        .. HopeAddon:FormatTime(killData.lastTime or 0)
    frame.statsText:SetText(subtitle)
    frame.statsText:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)

    -- Position based on current stack
    local yOffset = TOAST_TOP - (#self.activeToasts * TOAST_SPACING)
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -TOAST_PADDING, yOffset)

    -- Cancel any prior dismiss timer (in case frame was reused)
    if frame.dismissTimer then
        frame.dismissTimer:Cancel()
        frame.dismissTimer = nil
    end

    table.insert(self.activeToasts, frame)

    local animated = db and db.settings and db.settings.animationsEnabled ~= false
    local Effects = HopeAddon.Effects

    if animated and Effects then
        -- SlideIn handles fade-in internally (alpha 0→1 + translation)
        Effects:SlideIn(frame, "RIGHT", SLIDE_DISTANCE, FADE_IN)
    else
        frame:SetAlpha(1)
        frame:Show()
    end

    -- Sound (preserved from previous behavior)
    if HopeAddon.Sounds then
        local isFinal = RaidData and RaidData:IsFinalBoss(raidKey, bossId)
        if isFinal then
            HopeAddon.Sounds:PlayVictory()
        else
            HopeAddon.Sounds:PlayBossKill()
        end
    end

    if HopeAddon.Timer then
        frame.dismissTimer = HopeAddon.Timer:After(HOLD_DURATION, function()
            KillFlash:DismissToast(frame)
        end)
    end
end

--[[
    DismissToast - Fade and hide a single toast, then reposition the rest.
]]
function KillFlash:DismissToast(frame)
    if not frame or not frame:IsShown() then return end

    if frame.dismissTimer then
        frame.dismissTimer:Cancel()
        frame.dismissTimer = nil
    end

    for i, toast in ipairs(self.activeToasts) do
        if toast == frame then
            table.remove(self.activeToasts, i)
            break
        end
    end

    local animated = HopeAddon.db and HopeAddon.db.settings and HopeAddon.db.settings.animationsEnabled ~= false
    if animated and HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(frame, FADE_OUT, function()
            frame:Hide()
            RepositionToasts()
        end)
    else
        frame:Hide()
        RepositionToasts()
    end
end

--[[
    HideFlash - Dismiss all active toasts (called on module disable / cleanup).
]]
function KillFlash:HideFlash()
    while #self.activeToasts > 0 do
        self:DismissToast(self.activeToasts[1])
    end
end

--[[
    TestFlash - Debug entry point.
]]
function KillFlash:TestFlash()
    local fakeKillData = {
        icon = "Interface\\Icons\\Spell_Shadow_Charm",
        bossName = "Attumen the Huntsman",
        totalKills = 7,
        lastTime = 154,
    }
    self:ShowFlash("karazhan", "ATTUMEN", fakeKillData, nil)
end

SLASH_FLASHTEST1 = "/flashtest"
SlashCmdList["FLASHTEST"] = function()
    if HopeAddon.db and HopeAddon.db.debug then
        KillFlash:TestFlash()
    end
end
