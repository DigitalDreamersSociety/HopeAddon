--[[
    HopeAddon Charts Module
    Bar chart rendering component for statistics display
]]

local Charts = {}
HopeAddon.Charts = Charts
HopeAddon:RegisterModule("Charts", Charts)

-- Cache
local math_floor = math.floor
local math_max = math.max
local math_min = math.min

-- TBC-themed colors for charts
local CHART_COLORS = {
    PRIMARY = { r = 0.61, g = 0.19, b = 1.00 },   -- TBC purple
    SECONDARY = { r = 0.20, g = 0.80, b = 0.20 }, -- TBC green
    TERTIARY = { r = 1.00, g = 0.84, b = 0.00 },  -- Gold
    BACKGROUND = { r = 0.1, g = 0.1, b = 0.1 },
}

--[[
    Create a horizontal bar chart
    @param parent Frame - Parent frame
    @param width number - Chart width
    @param height number - Height per bar
    @param data table - Array of { label, value, maxValue, color }
    @return Frame - The chart container
]]
function Charts:CreateHorizontalBarChart(parent, width, height, data)
    local barHeight = height or 20
    local spacing = 4
    local labelWidth = 60
    local valueWidth = 50
    local barAreaWidth = width - labelWidth - valueWidth - 20

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, (#data * (barHeight + spacing)) - spacing)

    container.bars = {}

    for i, entry in ipairs(data) do
        local yOffset = -((i - 1) * (barHeight + spacing))

        -- Label
        local label = container:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
        label:SetSize(labelWidth, barHeight)
        label:SetJustifyH("LEFT")
        label:SetJustifyV("MIDDLE")
        label:SetText(entry.label or "")
        label:SetTextColor(0.9, 0.9, 0.9)

        -- Bar background
        local barBg = container:CreateTexture(nil, "BACKGROUND")
        barBg:SetTexture(HopeAddon.assets.textures.SOLID)
        barBg:SetPoint("LEFT", label, "RIGHT", 5, 0)
        barBg:SetSize(barAreaWidth, barHeight - 4)
        barBg:SetVertexColor(0.15, 0.15, 0.15, 0.9)

        -- Bar fill
        local barFill = container:CreateTexture(nil, "ARTWORK")
        barFill:SetTexture(HopeAddon.assets.textures.STATUS_BAR)
        barFill:SetPoint("LEFT", barBg, "LEFT", 0, 0)
        barFill:SetHeight(barHeight - 4)

        -- Calculate fill width
        local maxVal = entry.maxValue or 1
        local value = entry.value or 0
        local fillPercent = maxVal > 0 and math_min(1, value / maxVal) or 0
        local fillWidth = math_max(1, barAreaWidth * fillPercent)
        barFill:SetWidth(fillWidth)

        -- Apply color
        local color = entry.color or CHART_COLORS.PRIMARY
        if type(color) == "string" then
            color = CHART_COLORS[color] or HopeAddon.colors[color] or CHART_COLORS.PRIMARY
        end
        barFill:SetVertexColor(color.r, color.g, color.b, 1)

        -- Value text
        local valueText = container:CreateFontString(nil, "OVERLAY")
        valueText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        valueText:SetPoint("LEFT", barBg, "RIGHT", 5, 0)
        valueText:SetSize(valueWidth, barHeight)
        valueText:SetJustifyH("RIGHT")
        valueText:SetJustifyV("MIDDLE")
        valueText:SetText(entry.valueText or tostring(value))
        valueText:SetTextColor(0.8, 0.8, 0.8)

        container.bars[i] = {
            label = label,
            barBg = barBg,
            barFill = barFill,
            valueText = valueText,
        }
    end

    -- Method to update bar values
    function container:UpdateBar(index, value, maxValue, valueText)
        local bar = self.bars[index]
        if not bar then return end

        local fillPercent = maxValue > 0 and math_min(1, value / maxValue) or 0
        local barAreaWidth = bar.barBg:GetWidth()
        local fillWidth = math_max(1, barAreaWidth * fillPercent)
        bar.barFill:SetWidth(fillWidth)

        if valueText then
            bar.valueText:SetText(valueText)
        end
    end

    return container
end

--[[
    Create a time comparison bar chart (specialized for dungeon stats)
    Shows times as horizontal bars with MM:SS format

    @param parent Frame - Parent frame
    @param width number - Total width
    @param data table - Array of { label, timeSeconds, color }
    @return Frame - The chart container
]]
function Charts:CreateTimeComparisonChart(parent, width, data)
    local barHeight = 22
    local spacing = 6
    local labelWidth = 45
    local valueWidth = 50
    local barAreaWidth = width - labelWidth - valueWidth - 16

    -- Find max time for scaling
    local maxTime = 0
    for _, entry in ipairs(data) do
        if entry.timeSeconds and entry.timeSeconds > maxTime then
            maxTime = entry.timeSeconds
        end
    end
    -- Add 10% padding to max
    maxTime = maxTime * 1.1

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, (#data * (barHeight + spacing)) - spacing)

    container.bars = {}

    for i, entry in ipairs(data) do
        local yOffset = -((i - 1) * (barHeight + spacing))

        -- Label
        local label = container:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, yOffset)
        label:SetSize(labelWidth, barHeight)
        label:SetJustifyH("LEFT")
        label:SetJustifyV("MIDDLE")
        label:SetText(entry.label or "")
        label:SetTextColor(0.8, 0.8, 0.8)

        -- Bar background
        local barBg = container:CreateTexture(nil, "BACKGROUND")
        barBg:SetTexture(HopeAddon.assets.textures.SOLID)
        barBg:SetPoint("LEFT", label, "RIGHT", 5, 0)
        barBg:SetSize(barAreaWidth, barHeight - 6)
        barBg:SetVertexColor(0.12, 0.12, 0.12, 0.9)

        -- Bar fill
        local barFill = container:CreateTexture(nil, "ARTWORK")
        barFill:SetTexture(HopeAddon.assets.textures.STATUS_BAR)
        barFill:SetPoint("LEFT", barBg, "LEFT", 0, 0)
        barFill:SetHeight(barHeight - 6)

        -- Calculate fill width
        local timeVal = entry.timeSeconds or 0
        local fillPercent = maxTime > 0 and math_min(1, timeVal / maxTime) or 0
        local fillWidth = math_max(1, barAreaWidth * fillPercent)
        barFill:SetWidth(fillWidth)

        -- Apply color
        local color = entry.color or CHART_COLORS.PRIMARY
        if type(color) == "string" then
            color = CHART_COLORS[color] or HopeAddon.colors[color] or CHART_COLORS.PRIMARY
        end
        barFill:SetVertexColor(color.r, color.g, color.b, 1)

        -- Time text
        local timeText = container:CreateFontString(nil, "OVERLAY")
        timeText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        timeText:SetPoint("LEFT", barBg, "RIGHT", 5, 0)
        timeText:SetSize(valueWidth, barHeight)
        timeText:SetJustifyH("LEFT")
        timeText:SetJustifyV("MIDDLE")
        timeText:SetText(Charts:FormatTime(timeVal))
        timeText:SetTextColor(0.9, 0.9, 0.9)

        container.bars[i] = {
            label = label,
            barBg = barBg,
            barFill = barFill,
            timeText = timeText,
            color = color,
        }
    end

    -- Store max time for updates
    container.maxTime = maxTime
    container.barAreaWidth = barAreaWidth

    -- Method to update bar values
    function container:UpdateBar(index, timeSeconds, newLabel)
        local bar = self.bars[index]
        if not bar then return end

        local fillPercent = self.maxTime > 0 and math_min(1, timeSeconds / self.maxTime) or 0
        local fillWidth = math_max(1, self.barAreaWidth * fillPercent)
        bar.barFill:SetWidth(fillWidth)
        bar.timeText:SetText(Charts:FormatTime(timeSeconds))

        if newLabel then
            bar.label:SetText(newLabel)
        end
    end

    return container
end

--[[
    Format seconds to MM:SS string
    @param seconds number - Time in seconds
    @return string - Formatted time
]]
function Charts:FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return "--:--"
    end
    local mins = math_floor(seconds / 60)
    local secs = math_floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

--[[
    Format seconds to verbose time string (e.g., "18:42")
    @param seconds number - Time in seconds
    @return string - Formatted time
]]
function Charts:FormatTimeVerbose(seconds)
    if not seconds or seconds <= 0 then
        return "N/A"
    end
    local mins = math_floor(seconds / 60)
    local secs = math_floor(seconds % 60)
    if mins >= 60 then
        local hours = math_floor(mins / 60)
        mins = mins % 60
        return string.format("%d:%02d:%02d", hours, mins, secs)
    end
    return string.format("%d:%02d", mins, secs)
end

-- Module lifecycle
function Charts:OnInitialize()
    -- Nothing to initialize
end

function Charts:OnEnable()
    HopeAddon:Debug("Charts module enabled")
end

function Charts:OnDisable()
    HopeAddon:Debug("Charts module disabled")
end
