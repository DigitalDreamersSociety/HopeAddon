--[[
    HopeAddon BossBreakdown Module
    Power BI-style breakdown panel showing DPS/HPS/Damage Taken/Deaths
    after a boss kill celebration flash

    Visual: Dark panel with class-colored bars, animated fill, staggered reveal
    Flow: Called after the celebratory flash fades → slides in → stays 30s or click to dismiss
]]

local BossBreakdown = {}
HopeAddon.BossBreakdown = BossBreakdown

-- Lua/WoW API caches
local CreateFrame = CreateFrame
local GetTime = GetTime
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local string_format = string.format
local table_insert = table.insert
local unpack = unpack

-- Layout constants
local PANEL_WIDTH = 480
local PANEL_HEIGHT = 420
local BAR_HEIGHT = 16
local BAR_SPACING = 2
local BAR_WIDTH = 180
local SECTION_SPACING = 8
local COLUMN_LEFT_X = 15
local COLUMN_RIGHT_X = 250
local AUTO_HIDE_DURATION = 30

-- Texture refs
local TEX_WHITE8X8 = "Interface\\BUTTONS\\WHITE8X8"
local TEX_STATUS_BAR = "Interface\\TARGETINGFRAME\\UI-StatusBar"

-- Number formatting
local function FormatNumber(n)
    if not n or n == 0 then return "0" end
    if n >= 1000000 then
        return string_format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string_format("%.1fK", n / 1000)
    else
        return tostring(math_floor(n))
    end
end

-- Format time as M:SS
local function FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "0:00" end
    local m = math_floor(seconds / 60)
    local s = math_floor(seconds % 60)
    return string_format("%d:%02d", m, s)
end

-- Active timers for cleanup
local activeTimers = {}

local function AddTimer(timer)
    table_insert(activeTimers, timer)
end

local function ClearTimers()
    for _, t in ipairs(activeTimers) do
        if t and t.Cancel then
            t:Cancel()
        end
    end
    activeTimers = {}
end

--[[
    Create a single stat bar row (class-colored fill bar + name + value)
    @param parent Frame - Parent frame
    @param yOffset number - Y offset from parent top
    @param xOffset number - X offset from parent left
    @return table - { bar, nameText, valueText, barFill }
]]
local function CreateBarRow(parent, yOffset, xOffset)
    local barBg = parent:CreateTexture(nil, "BACKGROUND")
    barBg:SetTexture(TEX_WHITE8X8)
    barBg:SetVertexColor(0.12, 0.12, 0.12, 0.9)
    barBg:SetSize(BAR_WIDTH, BAR_HEIGHT)
    barBg:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, -yOffset)

    local barFill = parent:CreateTexture(nil, "ARTWORK")
    barFill:SetTexture(TEX_STATUS_BAR)
    barFill:SetHeight(BAR_HEIGHT)
    barFill:SetPoint("LEFT", barBg, "LEFT", 0, 0)
    barFill:SetWidth(0.001)

    local nameText = parent:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    nameText:SetPoint("LEFT", barBg, "LEFT", 4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetTextColor(1, 1, 1)

    local valueText = parent:CreateFontString(nil, "OVERLAY")
    valueText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    valueText:SetPoint("RIGHT", barBg, "RIGHT", -4, 0)
    valueText:SetJustifyH("RIGHT")
    valueText:SetTextColor(1, 1, 1)

    return {
        bg = barBg,
        fill = barFill,
        nameText = nameText,
        valueText = valueText,
    }
end

--[[
    Create the breakdown panel frame (lazy, called once)
]]
function BossBreakdown:CreateBreakdownPanel()
    if self.panel then return self.panel end

    local panel = CreateFrame("Frame", "HopeBossBreakdown", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    HopeAddon.Components:ApplyBackdropRaw(panel, "DARK_FEL",
        0.08, 0.08, 0.08, 0.95,
        0.5, 0.3, 0.7, 1)
    panel:SetFrameStrata("HIGH")
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetClampedToScreen(true)

    -- Click to dismiss
    panel:EnableMouse(true)
    panel:SetScript("OnMouseDown", function()
        BossBreakdown:HideBreakdown()
    end)

    -- Header: Boss icon
    local bossIcon = panel:CreateTexture(nil, "ARTWORK")
    bossIcon:SetSize(36, 36)
    bossIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -12)
    bossIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    panel.bossIcon = bossIcon

    -- Header: Boss name
    local bossName = panel:CreateFontString(nil, "OVERLAY")
    bossName:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    bossName:SetPoint("TOPLEFT", bossIcon, "TOPRIGHT", 10, -2)
    bossName:SetPoint("RIGHT", panel, "RIGHT", -15, 0)
    bossName:SetJustifyH("LEFT")
    bossName:SetTextColor(1, 1, 1)
    panel.bossName = bossName

    -- Header: Subtitle (Raid Name | Kill #X | Duration)
    local subtitle = panel:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    subtitle:SetPoint("TOPLEFT", bossName, "BOTTOMLEFT", 0, -2)
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    panel.subtitle = subtitle

    -- Title text
    local titleText = panel:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    titleText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -15, -12)
    titleText:SetText("ENCOUNTER BREAKDOWN")
    titleText:SetTextColor(0.5, 0.5, 0.5)
    panel.titleText = titleText

    -- Separator under header
    local headerSep = panel:CreateTexture(nil, "ARTWORK")
    headerSep:SetTexture(TEX_WHITE8X8)
    headerSep:SetSize(PANEL_WIDTH - 30, 1)
    headerSep:SetPoint("TOP", panel, "TOP", 0, -56)
    headerSep:SetVertexColor(0.5, 0.3, 0.7, 0.6)
    panel.headerSep = headerSep

    -- Section headers
    local dpsHeader = panel:CreateFontString(nil, "OVERLAY")
    dpsHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    dpsHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", COLUMN_LEFT_X, -66)
    dpsHeader:SetText("TOP DAMAGE (DPS)")
    local gold = HopeAddon.colors.GOLD_BRIGHT
    dpsHeader:SetTextColor(gold.r, gold.g, gold.b)
    panel.dpsHeader = dpsHeader

    local hpsHeader = panel:CreateFontString(nil, "OVERLAY")
    hpsHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    hpsHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", COLUMN_RIGHT_X, -66)
    hpsHeader:SetText("TOP HEALING (HPS)")
    hpsHeader:SetTextColor(gold.r, gold.g, gold.b)
    panel.hpsHeader = hpsHeader

    -- Create DPS bar rows (5)
    panel.dpsBars = {}
    for i = 1, 5 do
        local yOff = 82 + (i - 1) * (BAR_HEIGHT + BAR_SPACING)
        panel.dpsBars[i] = CreateBarRow(panel, yOff, COLUMN_LEFT_X)
    end

    -- Create HPS bar rows (5)
    panel.hpsBars = {}
    for i = 1, 5 do
        local yOff = 82 + (i - 1) * (BAR_HEIGHT + BAR_SPACING)
        panel.hpsBars[i] = CreateBarRow(panel, yOff, COLUMN_RIGHT_X)
    end

    -- Middle separator
    local midSep = panel:CreateTexture(nil, "ARTWORK")
    midSep:SetTexture(TEX_WHITE8X8)
    midSep:SetSize(PANEL_WIDTH - 30, 1)
    midSep:SetPoint("TOP", panel, "TOP", 0, -178)
    midSep:SetVertexColor(0.3, 0.3, 0.3, 0.5)
    panel.midSep = midSep

    -- Damage Taken header
    local dtHeader = panel:CreateFontString(nil, "OVERLAY")
    dtHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    dtHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", COLUMN_LEFT_X, -188)
    dtHeader:SetText("DAMAGE TAKEN")
    dtHeader:SetTextColor(gold.r, gold.g, gold.b)
    panel.dtHeader = dtHeader

    -- Deaths header
    local deathHeader = panel:CreateFontString(nil, "OVERLAY")
    deathHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    deathHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", COLUMN_RIGHT_X, -188)
    deathHeader:SetText("DEATHS")
    deathHeader:SetTextColor(gold.r, gold.g, gold.b)
    panel.deathHeader = deathHeader

    -- Create Damage Taken bar rows (3)
    panel.dtBars = {}
    for i = 1, 3 do
        local yOff = 204 + (i - 1) * (BAR_HEIGHT + BAR_SPACING)
        panel.dtBars[i] = CreateBarRow(panel, yOff, COLUMN_LEFT_X)
    end

    -- Create death text entries (up to 5)
    panel.deathTexts = {}
    for i = 1, 5 do
        local yOff = 204 + (i - 1) * 15

        local nameText = panel:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        nameText:SetPoint("TOPLEFT", panel, "TOPLEFT", COLUMN_RIGHT_X, -yOff)
        nameText:SetJustifyH("LEFT")
        nameText:SetTextColor(1, 1, 1)

        local timeText = panel:CreateFontString(nil, "OVERLAY")
        timeText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        timeText:SetPoint("TOPLEFT", nameText, "TOPRIGHT", 5, 0)
        timeText:SetJustifyH("LEFT")
        timeText:SetTextColor(0.8, 0.3, 0.3)

        panel.deathTexts[i] = { nameText = nameText, timeText = timeText }
    end

    -- Dismiss hint
    local dismissText = panel:CreateFontString(nil, "OVERLAY")
    dismissText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    dismissText:SetPoint("BOTTOM", panel, "BOTTOM", 0, 8)
    dismissText:SetText("Click anywhere to dismiss")
    dismissText:SetTextColor(0.4, 0.4, 0.4)
    panel.dismissText = dismissText

    -- "No data" fallback text
    local noDataText = panel:CreateFontString(nil, "OVERLAY")
    noDataText:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    noDataText:SetPoint("CENTER", panel, "CENTER", 0, -20)
    noDataText:SetText("No encounter data available")
    noDataText:SetTextColor(0.5, 0.5, 0.5)
    noDataText:Hide()
    panel.noDataText = noDataText

    panel:Hide()
    self.panel = panel
    return panel
end

--[[
    Populate bar rows with data and animate them
    @param bars table - Array of bar row tables
    @param entries table - Data entries { name, class, total, perSecond? }
    @param maxVal number - Maximum value (for bar width proportion)
    @param baseDelay number - Animation start delay
    @param showPerSecond boolean - Show per-second value instead of total
    @return number - Delay after all bars animated
]]
local function PopulateBars(bars, entries, maxVal, baseDelay, showPerSecond)
    local delay = baseDelay
    local animationsEnabled = not HopeAddon.db or HopeAddon.db.settings.animationsEnabled ~= false

    for i, bar in ipairs(bars) do
        local entry = entries[i]
        if entry then
            -- Show this row
            bar.bg:Show()
            bar.fill:Show()
            bar.nameText:Show()
            bar.valueText:Show()

            -- Class color
            local cc = HopeAddon:GetClassColor(entry.class)
            bar.fill:SetVertexColor(cc.r, cc.g, cc.b, 0.85)

            -- Set text
            bar.nameText:SetText(entry.name)
            local displayVal = showPerSecond and entry.perSecond or entry.total
            bar.valueText:SetText(FormatNumber(displayVal))

            -- Calculate target width
            local proportion = maxVal > 0 and (entry.total / maxVal) or 0
            local targetWidth = math_max(1, proportion * BAR_WIDTH)

            if animationsEnabled then
                -- Start at zero, animate with stagger
                bar.fill:SetWidth(0.001)
                bar.nameText:SetAlpha(0)
                bar.valueText:SetAlpha(0)

                local barDelay = delay + (i - 1) * 0.1
                AddTimer(HopeAddon.Timer:After(barDelay, function()
                    if not bar.bg:IsShown() then return end
                    HopeAddon.Animations:AnimateValue(0.001, targetWidth, 0.3, function(current)
                        bar.fill:SetWidth(math_max(0.001, current))
                    end)
                    bar.nameText:SetAlpha(1)
                    bar.valueText:SetAlpha(1)
                end))
            else
                bar.fill:SetWidth(targetWidth)
                bar.nameText:SetAlpha(1)
                bar.valueText:SetAlpha(1)
            end
        else
            -- Hide unused rows
            bar.bg:Hide()
            bar.fill:Hide()
            bar.nameText:Hide()
            bar.valueText:Hide()
        end
    end

    local usedCount = math_min(#entries, #bars)
    return delay + usedCount * 0.1 + 0.3
end

--[[
    Show the breakdown panel with encounter data
    @param raidKey string - Raid identifier
    @param bossId string - Boss identifier
    @param killData table - Kill record from RecordBossKill
    @param encounterSummary table - From EncounterTracker:GetEncounterSummary()
    @param isFinal boolean - Is this the final boss of the raid
]]
function BossBreakdown:ShowBreakdown(raidKey, bossId, killData, encounterSummary, isFinal)
    if not self.panel then
        self:CreateBreakdownPanel()
    end

    local panel = self.panel

    -- Cancel any existing auto-hide timer
    ClearTimers()

    local boss = HopeAddon.RaidData:GetBoss(raidKey, bossId)
    local raid = HopeAddon.RaidData:GetRaid(raidKey)
    if not boss or not raid then return end

    -- Phase color for border
    local colorName = HopeAddon.RaidData:GetPhaseColorName(raidKey)
    local phaseColor = HopeAddon.colors[colorName] or HopeAddon.colors.KARA_PURPLE

    panel:SetBackdropBorderColor(phaseColor.r, phaseColor.g, phaseColor.b, 1)
    panel.headerSep:SetVertexColor(phaseColor.r, phaseColor.g, phaseColor.b, 0.6)

    -- Boss icon
    if killData and killData.icon then
        panel.bossIcon:SetTexture(killData.icon)
    else
        panel.bossIcon:SetTexture("Interface\\Icons\\" .. (boss.icon or raid.icon))
    end

    -- Boss name
    panel.bossName:SetText(boss.name)

    -- Subtitle
    local subtitleParts = { raid.name }
    if killData then
        table_insert(subtitleParts, "Kill #" .. killData.totalKills)
    end
    if encounterSummary and encounterSummary.duration then
        table_insert(subtitleParts, FormatDuration(encounterSummary.duration))
    end
    panel.subtitle:SetText(table.concat(subtitleParts, "  |  "))

    -- Handle no encounter data
    if not encounterSummary or (#encounterSummary.topDPS == 0 and #encounterSummary.topHPS == 0) then
        -- Hide all bars and sections, show "no data"
        self:HideAllSections()
        panel.noDataText:Show()
    else
        panel.noDataText:Hide()
        self:ShowAllSections()

        -- Find max values for bar proportions
        local maxDPS = encounterSummary.topDPS[1] and encounterSummary.topDPS[1].total or 1
        local maxHPS = encounterSummary.topHPS[1] and encounterSummary.topHPS[1].total or 1
        local maxDT = encounterSummary.topDamageTaken[1] and encounterSummary.topDamageTaken[1].total or 1

        -- Populate bars with staggered animation
        local dpsDelay = PopulateBars(panel.dpsBars, encounterSummary.topDPS, maxDPS, 0.3, true)
        local hpsDelay = PopulateBars(panel.hpsBars, encounterSummary.topHPS, maxHPS, dpsDelay, true)
        local dtDelay = PopulateBars(panel.dtBars, encounterSummary.topDamageTaken, maxDT, hpsDelay, false)

        -- Deaths header with count
        panel.deathHeader:SetText("DEATHS (" .. (encounterSummary.totalDeaths or 0) .. ")")

        -- Populate death entries
        local deaths = encounterSummary.deaths or {}
        local animationsEnabled = not HopeAddon.db or HopeAddon.db.settings.animationsEnabled ~= false
        for i, deathRow in ipairs(panel.deathTexts) do
            local death = deaths[i]
            if death then
                local cc = HopeAddon:GetClassColor(death.class)
                deathRow.nameText:SetText(death.name)
                deathRow.nameText:SetTextColor(cc.r, cc.g, cc.b)
                deathRow.nameText:Show()

                local timeStr = "(" .. FormatDuration(death.timestamp) .. ")"
                deathRow.timeText:SetText(timeStr)
                deathRow.timeText:Show()

                if animationsEnabled then
                    deathRow.nameText:SetAlpha(0)
                    deathRow.timeText:SetAlpha(0)
                    AddTimer(HopeAddon.Timer:After(dtDelay, function()
                        deathRow.nameText:SetAlpha(1)
                        deathRow.timeText:SetAlpha(1)
                    end))
                else
                    deathRow.nameText:SetAlpha(1)
                    deathRow.timeText:SetAlpha(1)
                end
            else
                deathRow.nameText:Hide()
                deathRow.timeText:Hide()
            end
        end
    end

    -- Resize panel based on content
    local hasDeaths = encounterSummary and #(encounterSummary.deaths or {}) > 0
    local deathCount = encounterSummary and math_min(#(encounterSummary.deaths or {}), 5) or 0
    local bottomY = hasDeaths and (204 + deathCount * 15 + 30) or 270
    panel:SetHeight(math_max(bottomY, 280))

    -- Position and show
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetAlpha(0)
    panel:Show()

    -- Fade in
    HopeAddon.Effects:FadeIn(panel, 0.4)

    -- Auto-hide timer
    AddTimer(HopeAddon.Timer:After(AUTO_HIDE_DURATION, function()
        self:HideBreakdown()
    end))
end

--[[
    Hide all data sections (used when no encounter data)
]]
function BossBreakdown:HideAllSections()
    local panel = self.panel
    if not panel then return end

    panel.dpsHeader:Hide()
    panel.hpsHeader:Hide()
    panel.dtHeader:Hide()
    panel.deathHeader:Hide()
    panel.midSep:Hide()

    for _, bar in ipairs(panel.dpsBars) do
        bar.bg:Hide(); bar.fill:Hide(); bar.nameText:Hide(); bar.valueText:Hide()
    end
    for _, bar in ipairs(panel.hpsBars) do
        bar.bg:Hide(); bar.fill:Hide(); bar.nameText:Hide(); bar.valueText:Hide()
    end
    for _, bar in ipairs(panel.dtBars) do
        bar.bg:Hide(); bar.fill:Hide(); bar.nameText:Hide(); bar.valueText:Hide()
    end
    for _, row in ipairs(panel.deathTexts) do
        row.nameText:Hide(); row.timeText:Hide()
    end
end

--[[
    Show all data section headers
]]
function BossBreakdown:ShowAllSections()
    local panel = self.panel
    if not panel then return end

    panel.dpsHeader:Show()
    panel.hpsHeader:Show()
    panel.dtHeader:Show()
    panel.deathHeader:Show()
    panel.midSep:Show()
end

--[[
    Hide the breakdown panel with fade out
]]
function BossBreakdown:HideBreakdown()
    ClearTimers()

    local panel = self.panel
    if not panel or not panel:IsShown() then return end

    HopeAddon.Effects:FadeOut(panel, 0.4, function()
        panel:Hide()
    end)
end
