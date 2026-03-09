--[[
    KillFlash - Fullscreen boss kill overlay
    Replaces the old Stats Window + Breakdown Panel with a single animated flash.
]]
local KillFlash = {}
HopeAddon.KillFlash = KillFlash

-- Local constants
local FLASH_DURATION_NORMAL = 2.0
local FLASH_DURATION_FINAL  = 3.0
local FLASH_FADEOUT          = 0.3
local CONTENT_TOP_OFFSET     = -80
local DPS_MAX_BARS           = 3

local ICON_SIZE   = 48
local BAR_WIDTH   = 220
local BAR_HEIGHT  = 16
local BAR_SPACING = 4

-- Timer management
local activeTimers = {}

local function AddTimer(t)
    table.insert(activeTimers, t)
end

local function ClearTimers()
    for _, t in ipairs(activeTimers) do
        if t and t.Cancel then t:Cancel() end
    end
    activeTimers = {}
end

--[[
    CreateFlashFrame - Lazy singleton, builds the entire frame hierarchy
]]
function KillFlash:CreateFlashFrame()
    if self.flashFrame then return self.flashFrame end

    local fonts = HopeAddon.assets.fonts

    -- Root fullscreen frame
    local flashFrame = CreateFrame("Frame", "HopeKillFlash", UIParent)
    flashFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    flashFrame:SetAllPoints(UIParent)
    flashFrame:Hide()
    flashFrame:EnableMouse(true)  -- Block clicks through

    -- Vignette overlay
    local vignette = flashFrame:CreateTexture(nil, "BACKGROUND")
    vignette:SetAllPoints()
    vignette:SetColorTexture(0, 0, 0, 0.6)
    flashFrame.vignette = vignette

    -- Content anchor (centered upper area)
    local contentAnchor = CreateFrame("Frame", nil, flashFrame)
    contentAnchor:SetSize(400, 300)
    contentAnchor:SetPoint("TOP", UIParent, "TOP", 0, CONTENT_TOP_OFFSET)
    flashFrame.contentAnchor = contentAnchor

    -- Boss icon container
    local iconContainer = CreateFrame("Frame", nil, contentAnchor)
    iconContainer:SetSize(ICON_SIZE, ICON_SIZE)
    iconContainer:SetPoint("TOP", contentAnchor, "TOP", 0, -30)
    flashFrame.iconContainer = iconContainer

    local bossIcon = iconContainer:CreateTexture(nil, "ARTWORK")
    bossIcon:SetAllPoints()
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    flashFrame.bossIcon = bossIcon

    -- Boss name text
    local bossNameText = contentAnchor:CreateFontString(nil, "OVERLAY")
    bossNameText:SetFont(fonts.TITLE, 18, "")
    bossNameText:SetTextColor(1, 1, 1, 1)
    bossNameText:SetPoint("TOP", iconContainer, "BOTTOM", 0, -12)
    bossNameText:SetText("Boss Name")
    flashFrame.bossNameText = bossNameText

    -- Defeated container
    local defeatedContainer = CreateFrame("Frame", nil, contentAnchor)
    defeatedContainer:SetSize(200, 20)
    defeatedContainer:SetPoint("TOP", bossNameText, "BOTTOM", 0, -6)
    flashFrame.defeatedContainer = defeatedContainer

    local defeatedText = defeatedContainer:CreateFontString(nil, "OVERLAY")
    defeatedText:SetFont(fonts.HEADER, 14, "")
    defeatedText:SetPoint("CENTER")
    defeatedText:SetText("D E F E A T E D")
    flashFrame.defeatedText = defeatedText

    -- Stats text
    local statsText = contentAnchor:CreateFontString(nil, "OVERLAY")
    statsText:SetFont(fonts.BODY, 12, "")
    statsText:SetTextColor(0.7, 0.7, 0.7, 1)
    statsText:SetPoint("TOP", defeatedContainer, "BOTTOM", 0, -8)
    statsText:SetText("Kill #1  ·  0:00")
    flashFrame.statsText = statsText

    -- Bars container
    local barsContainer = CreateFrame("Frame", nil, contentAnchor)
    barsContainer:SetSize(BAR_WIDTH, (BAR_HEIGHT + BAR_SPACING) * DPS_MAX_BARS)
    barsContainer:SetPoint("TOP", statsText, "BOTTOM", 0, -14)
    flashFrame.barsContainer = barsContainer

    -- DPS bars (1..3)
    local dpsBars = {}
    for i = 1, DPS_MAX_BARS do
        local barFrame = CreateFrame("Frame", nil, barsContainer)
        barFrame:SetSize(BAR_WIDTH, BAR_HEIGHT)
        if i == 1 then
            barFrame:SetPoint("TOP", barsContainer, "TOP", 0, 0)
        else
            barFrame:SetPoint("TOP", dpsBars[i - 1], "BOTTOM", 0, -BAR_SPACING)
        end

        -- Bar background
        local barBg = barFrame:CreateTexture(nil, "BACKGROUND")
        barBg:SetAllPoints()
        barBg:SetColorTexture(0.12, 0.12, 0.12, 0.8)
        barFrame.barBg = barBg

        -- Bar fill (class-colored, anchored LEFT)
        local barFill = barFrame:CreateTexture(nil, "ARTWORK")
        barFill:SetPoint("TOPLEFT")
        barFill:SetPoint("BOTTOMLEFT")
        barFill:SetWidth(BAR_WIDTH)
        barFill:SetColorTexture(1, 1, 1, 0.7)
        barFrame.barFill = barFill

        -- Rank text (#1, #2, #3)
        local rankText = barFrame:CreateFontString(nil, "OVERLAY")
        rankText:SetFont(fonts.SMALL, 10, "")
        rankText:SetPoint("LEFT", barFrame, "LEFT", 4, 0)
        rankText:SetTextColor(1, 1, 1, 0.6)
        rankText:SetText("#" .. i)
        barFrame.rankText = rankText

        -- Name text
        local nameText = barFrame:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(fonts.SMALL, 10, "")
        nameText:SetPoint("LEFT", rankText, "RIGHT", 4, 0)
        nameText:SetTextColor(1, 1, 1, 1)
        barFrame.nameText = nameText

        -- Value text (DPS)
        local valueText = barFrame:CreateFontString(nil, "OVERLAY")
        valueText:SetFont(fonts.SMALL, 10, "")
        valueText:SetPoint("RIGHT", barFrame, "RIGHT", -4, 0)
        valueText:SetTextColor(1, 1, 1, 1)
        barFrame.valueText = valueText

        dpsBars[i] = barFrame
    end
    flashFrame.dpsBars = dpsBars

    -- Click to dismiss
    flashFrame:SetScript("OnMouseDown", function()
        KillFlash:HideFlash()
    end)

    self.flashFrame = flashFrame
    return flashFrame
end

--[[
    ShowFlash - Main entry point for boss kill overlay
    @param raidKey string - Raid identifier (e.g. "karazhan")
    @param bossId string - Boss identifier (e.g. "ATTUMEN")
    @param killData table - {icon, bossName, totalKills, lastTime, bestTime}
    @param encounterSummary table|nil - From EncounterTracker:GetEncounterSummary()
]]
function KillFlash:ShowFlash(raidKey, bossId, killData, encounterSummary)
    local f = self:CreateFlashFrame()
    local db = HopeAddon.db

    -- Check setting
    if db and db.settings and db.settings.bossKillFlashEnabled == false then
        return
    end

    -- Clear previous state
    ClearTimers()
    if HopeAddon.Glow then
        HopeAddon.Glow:StopAllFor(f.iconContainer)
    end

    -- Resolve boss metadata
    local RaidData = HopeAddon.RaidData
    local C = HopeAddon.Constants
    local isFinal = RaidData and RaidData:IsFinalBoss(raidKey, bossId)

    -- Colors
    local colorName = RaidData and RaidData:GetPhaseColorName(raidKey) or "KARA_PURPLE"
    local theme = C and C:GetRaidTheme(raidKey)
    local accentColorName = theme and theme.accentColor or "KARA_ACCENT"
    local ac = HopeAddon.colors[accentColorName] or { r = 0.4, g = 0.25, b = 0.55 }
    local phaseColor = HopeAddon.colors[colorName] or { r = 0.5, g = 0.3, b = 0.7 }

    -- Set vignette tint
    f.vignette:SetVertexColor(ac.r * 0.15, ac.g * 0.15, ac.b * 0.15)

    -- Set boss icon
    if killData.icon then
        f.bossIcon:SetTexture(killData.icon)
    end

    -- Set boss name
    f.bossNameText:SetText(killData.bossName or "Unknown")

    -- Set defeated text color to phase color
    f.defeatedText:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)

    -- Build stats line
    local statsLine = "Kill #" .. (killData.totalKills or 1) .. "  \194\183  " .. HopeAddon:FormatTime(killData.lastTime)
    f.statsText:SetText(statsLine)

    -- Populate DPS bars
    local topDPS = encounterSummary and encounterSummary.topDPS
    local hasBarData = topDPS and #topDPS > 0
    if hasBarData then
        f.barsContainer:Show()
        local maxDPS = topDPS[1] and topDPS[1].perSecond or 1
        if maxDPS <= 0 then maxDPS = 1 end
        for i = 1, DPS_MAX_BARS do
            local bar = f.dpsBars[i]
            local entry = topDPS[i]
            if entry then
                local cc = HopeAddon:GetClassColor(entry.class)
                bar.barFill:SetColorTexture(cc.r, cc.g, cc.b, 0.7)
                bar.barFill:SetWidth(math.max(1, BAR_WIDTH * (entry.perSecond / maxDPS)))
                bar.nameText:SetText(entry.name or "")
                bar.valueText:SetText(HopeAddon:FormatNumber(entry.perSecond) .. " DPS")
                bar:Show()
            else
                bar:Hide()
            end
        end
    else
        f.barsContainer:Hide()
        for i = 1, DPS_MAX_BARS do
            f.dpsBars[i]:Hide()
        end
    end

    -- Check if animations are enabled
    local animated = db and db.settings and db.settings.animationsEnabled ~= false

    if animated then
        -- Reset all child alphas to 0 before showing
        f:SetAlpha(0)
        f.iconContainer:SetAlpha(0)
        f.iconContainer:SetScale(1.0)
        f.bossNameText:SetAlpha(0)
        f.defeatedContainer:SetAlpha(0)
        f.statsText:SetAlpha(0)
        if hasBarData then
            f.barsContainer:SetAlpha(1)  -- Container visible, bars slide in
            for i = 1, DPS_MAX_BARS do
                f.dpsBars[i]:SetAlpha(0)
            end
        end
        f:Show()

        -- Animation schedule
        local Effects = HopeAddon.Effects
        local Glow = HopeAddon.Glow
        local Animations = HopeAddon.Animations

        -- 0.0s: Fade in frame + bounce icon + glow + burst
        Effects:FadeIn(f, 0.15)
        Effects:BounceIn(f.iconContainer, 0.25)
        if Glow then Glow:CreateEpicGlow(f.iconContainer, colorName) end
        Effects:CreateBurstEffect(f.iconContainer, colorName)

        -- 0.1s: Fade in boss name
        AddTimer(HopeAddon.Timer:After(0.1, function()
            Effects:FadeIn(f.bossNameText, 0.15)
        end))

        -- 0.2s: Fade in defeated + pulsing glow
        AddTimer(HopeAddon.Timer:After(0.2, function()
            Effects:FadeIn(f.defeatedContainer, 0.15)
            Effects:CreatePulsingGlow(f.defeatedContainer, colorName, 0.4)
        end))

        -- 0.3s: Fade in stats
        AddTimer(HopeAddon.Timer:After(0.3, function()
            Effects:FadeIn(f.statsText, 0.15)
        end))

        -- 0.4-0.6s: Slide in DPS bars
        if hasBarData then
            for i = 1, math.min(#topDPS, DPS_MAX_BARS) do
                local delay = 0.3 + (i * 0.1)
                AddTimer(HopeAddon.Timer:After(delay, function()
                    Effects:SlideIn(f.dpsBars[i], "RIGHT", 60, 0.2)
                end))
            end
        end

        -- Final boss extras
        if isFinal then
            AddTimer(HopeAddon.Timer:After(0.5, function()
                if Animations then Animations:Shake(f, 4, 0.2) end
            end))
            AddTimer(HopeAddon.Timer:After(0.8, function()
                if Animations then Animations:CelebrateAchievement(f.bossNameText) end
            end))
        end
    else
        -- No animations: show everything immediately
        f:SetAlpha(1)
        f.iconContainer:SetAlpha(1)
        f.iconContainer:SetScale(1.0)
        f.bossNameText:SetAlpha(1)
        f.defeatedContainer:SetAlpha(1)
        f.statsText:SetAlpha(1)
        if hasBarData then
            f.barsContainer:SetAlpha(1)
            for i = 1, DPS_MAX_BARS do
                f.dpsBars[i]:SetAlpha(1)
            end
        end
        f:Show()
    end

    -- Play sound
    if HopeAddon.Sounds then
        if isFinal then
            HopeAddon.Sounds:PlayVictory()
        else
            HopeAddon.Sounds:PlayBossKill()
        end
    end

    -- Auto-hide timer
    local duration = isFinal and FLASH_DURATION_FINAL or FLASH_DURATION_NORMAL
    AddTimer(HopeAddon.Timer:After(duration, function()
        KillFlash:HideFlash()
    end))
end

--[[
    HideFlash - Dismiss the kill flash overlay
]]
function KillFlash:HideFlash()
    local f = self.flashFrame
    if not f or not f:IsShown() then return end

    ClearTimers()

    if HopeAddon.Glow then
        HopeAddon.Glow:StopAllFor(f.iconContainer)
    end

    local animated = HopeAddon.db and HopeAddon.db.settings and HopeAddon.db.settings.animationsEnabled ~= false
    if animated and HopeAddon.Effects then
        HopeAddon.Effects:FadeOut(f, FLASH_FADEOUT, function()
            f:Hide()
        end)
    else
        f:Hide()
    end
end

--[[
    TestFlash - Debug function, shows flash with dummy data via ShowFlash
]]
function KillFlash:TestFlash()
    local fakeKillData = {
        icon = "Interface\\Icons\\Spell_Shadow_Charm",
        bossName = "Attumen the Huntsman",
        totalKills = 7,
        lastTime = 154,  -- 2:34
        bestTime = 132,
    }

    local fakeEncounterSummary = {
        duration = 154,
        totalDamage = 1250000,
        topDPS = {
            { name = "Legolas", class = "HUNTER", total = 192500, perSecond = 1250 },
            { name = "Gandalf", class = "MAGE", total = 169400, perSecond = 1100 },
            { name = "Aragorn", class = "WARRIOR", total = 150920, perSecond = 980 },
        },
    }

    self:ShowFlash("karazhan", "ATTUMEN", fakeKillData, fakeEncounterSummary)
end

-- Register slash command (debug only)
SLASH_FLASHTEST1 = "/flashtest"
SlashCmdList["FLASHTEST"] = function()
    if HopeAddon.db and HopeAddon.db.debug then
        KillFlash:TestFlash()
    end
end
