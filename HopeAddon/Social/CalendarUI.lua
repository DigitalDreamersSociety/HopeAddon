--[[
    HopeAddon Calendar UI Module
    UI components for the raid calendar system
]]

local CalendarUI = {}

-- Module references (set at load time since Constants loads first)
local C = HopeAddon.Constants
local Calendar = nil
local Components = nil
local FramePool = HopeAddon.FramePool

-- Safe function caller - errors don't crash the module
local function safecall(func, ...)
    if type(func) == "function" then
        return xpcall(func, geterrorhandler(), ...)
    end
end

-- Frame pools (stored as module fields for reliable OnDisable access)
-- Note: These are also assigned to CalendarUI.dayCellPool and CalendarUI.eventCardPool
-- in CreatePools() for proper cleanup in OnDisable()
local dayCellPool = nil
local eventCardPool = nil

-- UI State
local monthGrid = nil
local selectedDayPanel = nil
local currentYear = nil
local currentMonth = nil
local eventDetailPopup = nil
local createEventPopup = nil
local dayTooltip = nil  -- Singleton tooltip for day hover preview
local bannerSection = nil  -- App-wide event banner section

-- Tooltip row limit (prevents unbounded frame creation)
local MAX_TOOLTIP_ROWS = 8

-- Active cells for cleanup
local activeDayCells = {}
local activeEventCards = {}

--============================================================
-- INITIALIZATION
--============================================================

function CalendarUI:OnInitialize()
    C = HopeAddon.Constants
    HopeAddon:Debug("CalendarUI: Initialized")
end

function CalendarUI:OnEnable()
    -- Validate dependencies before proceeding
    if not C or not C.CALENDAR_UI then
        HopeAddon:Debug("CalendarUI: CALENDAR_UI constants not loaded, skipping enable")
        return
    end

    Calendar = HopeAddon.Calendar
    if not Calendar then
        HopeAddon:Debug("CalendarUI: Calendar module not loaded, skipping enable")
        return
    end

    Components = HopeAddon.Components

    -- Create frame pools
    self:CreatePools()

    -- Set initial month/year
    local today = date("*t")
    currentYear = today.year
    currentMonth = today.month

    HopeAddon:Debug("CalendarUI: Enabled")
end

function CalendarUI:OnDisable()
    -- Release all pooled frames
    self:ReleaseAllCells()
    self:ReleaseAllEventCards()

    -- Destroy pools (use module fields as fallback for proper scope access)
    local dayPool = dayCellPool or self.dayCellPool
    local eventPool = eventCardPool or self.eventCardPool

    if dayPool then
        dayPool:Destroy()
        dayCellPool = nil
        self.dayCellPool = nil
    end
    if eventPool then
        eventPool:Destroy()
        eventCardPool = nil
        self.eventCardPool = nil
    end

    -- Hide popups and tooltip
    if eventDetailPopup then eventDetailPopup:Hide() end
    if createEventPopup then createEventPopup:Hide() end
    if dayTooltip then dayTooltip:Hide() end

    -- P2.2: Cleanup named frames to prevent _G pollution across reloads
    local namedFrames = {
        "HopeCalendarBannerTooltip",
        "HopeCalendarDayTooltip",
        "HopeCalendarEventDetail",
        "HopeCalendarServerEvent",
        "HopeCalendarSaveTemplate",
        "HopeCalendarCreateEvent",
    }
    for _, name in ipairs(namedFrames) do
        local frame = _G[name]
        if frame then
            frame:Hide()
            frame:SetParent(nil)
            _G[name] = nil
        end
    end

    HopeAddon:Debug("CalendarUI: Disabled")
end

--============================================================
-- FRAME POOLS
--============================================================

function CalendarUI:CreatePools()
    -- Day cell pool (42 cells for 7x6 grid)
    dayCellPool = FramePool:New(function()
        return self:CreateDayCellFrame()
    end, function(cell)
        cell:Hide()
        cell:ClearAllPoints()
        cell.dayNumber:SetText("")
        -- Clear event slots
        if cell.serverSlots then
            CalendarUI:ClearEventSlots(cell.serverSlots)
        end
        if cell.guildSlots then
            CalendarUI:ClearEventSlots(cell.guildSlots)
        end
        if cell.overflowText then
            cell.overflowText:Hide()
        end
        cell.isToday = false
        cell.dateStr = nil
        cell:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
    end)
    -- Store as module field for reliable OnDisable access
    self.dayCellPool = dayCellPool

    -- Event card pool
    eventCardPool = FramePool:New(function()
        return self:CreateEventCardFrame()
    end, function(card)
        card:Hide()
        card:ClearAllPoints()
        card.eventId = nil
        -- Reset color stripe to default
        if card.colorStripe then
            card.colorStripe:SetColorTexture(0.6, 0.6, 0.6, 1)
        end
        -- Reset border color to default
        card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        -- Ensure view button is shown (will be hidden for server events)
        if card.viewBtn then
            card.viewBtn:Show()
        end
    end)
    -- Store as module field for reliable OnDisable access
    self.eventCardPool = eventCardPool
end

function CalendarUI:CreateDayCellFrame()
    local cell = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    cell:SetSize(C.CALENDAR_UI.CELL_WIDTH, C.CALENDAR_UI.CELL_HEIGHT)

    cell:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    cell:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    cell:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

    -- Day number (top-left)
    cell.dayNumber = cell:CreateFontString(nil, "OVERLAY")
    cell.dayNumber:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    cell.dayNumber:SetPoint("TOPLEFT", cell, "TOPLEFT", 4, -3)
    cell.dayNumber:SetTextColor(0.8, 0.8, 0.8)

    -- Slot container at bottom of cell for event indicators
    local SLOT = C.CALENDAR_SLOT_UI
    cell.slotContainer = CreateFrame("Frame", nil, cell)
    cell.slotContainer:SetSize(60, 28)
    cell.slotContainer:SetPoint("BOTTOM", cell, "BOTTOM", 0, 2)

    -- Server event slots (Row 1 - top row of slots)
    cell.serverSlots = {}
    for i = 1, SLOT.SERVER_SLOTS do
        local slot = self:CreateEventSlot(cell.slotContainer)
        slot:SetPoint("BOTTOMLEFT", cell.slotContainer, "BOTTOMLEFT",
            14 + (i - 1) * (SLOT.SLOT_SIZE + SLOT.SLOT_SPACING), SLOT.SERVER_ROW_Y)
        cell.serverSlots[i] = slot
    end

    -- Guild event slots (Row 2 - bottom row of slots)
    cell.guildSlots = {}
    for i = 1, SLOT.GUILD_SLOTS do
        local slot = self:CreateEventSlot(cell.slotContainer)
        slot:SetPoint("BOTTOMLEFT", cell.slotContainer, "BOTTOMLEFT",
            14 + (i - 1) * (SLOT.SLOT_SIZE + SLOT.SLOT_SPACING), SLOT.GUILD_ROW_Y)
        cell.guildSlots[i] = slot
    end

    -- Overflow indicator (shows "+N" when more events than slots)
    cell.overflowText = cell.slotContainer:CreateFontString(nil, "OVERLAY")
    cell.overflowText:SetFont(HopeAddon.assets.fonts.BODY, SLOT.OVERFLOW_FONT_SIZE, "")
    cell.overflowText:SetPoint("LEFT", cell.guildSlots[SLOT.GUILD_SLOTS], "RIGHT", 2, 0)
    cell.overflowText:SetTextColor(0.6, 0.6, 0.6)
    cell.overflowText:Hide()

    -- Hover effect with tooltip
    cell:SetScript("OnEnter", function(self)
        if self.dateStr then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)

            -- Show tooltip if day has events
            if Calendar then
                local events = Calendar:GetEventsForDate(self.dateStr)
                if events and #events > 0 then
                    CalendarUI:ShowDayTooltip(self, self.dateStr, events)
                end
            end
        end
    end)
    cell:SetScript("OnLeave", function(self)
        if self.isToday then
            self:SetBackdropBorderColor(1, 0.84, 0, 0.8)
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        end

        -- Hide tooltip
        CalendarUI:HideDayTooltip()
    end)

    return cell
end

--[[
    Create an event slot (colored square) for day cell indicators
    @param parent Frame - Parent frame to attach slot to
    @return Frame slot - The slot frame with fill and connector textures
]]
function CalendarUI:CreateEventSlot(parent)
    local SLOT = C.CALENDAR_SLOT_UI
    local slot = CreateFrame("Frame", nil, parent)
    slot:SetSize(SLOT.SLOT_SIZE, SLOT.SLOT_SIZE)

    -- Main square fill
    slot.fill = slot:CreateTexture(nil, "ARTWORK")
    slot.fill:SetAllPoints()
    slot.fill:SetColorTexture(0.3, 0.3, 0.3, 0.3)

    -- Left connector (for middle/end of multi-day events)
    slot.leftBar = slot:CreateTexture(nil, "ARTWORK", nil, 1)
    slot.leftBar:SetSize(3, SLOT.SLOT_SIZE)
    slot.leftBar:SetPoint("RIGHT", slot, "LEFT", 1, 0)
    slot.leftBar:Hide()

    -- Right connector (for start/middle of multi-day events)
    slot.rightBar = slot:CreateTexture(nil, "ARTWORK", nil, 1)
    slot.rightBar:SetSize(3, SLOT.SLOT_SIZE)
    slot.rightBar:SetPoint("LEFT", slot, "RIGHT", -1, 0)
    slot.rightBar:Hide()

    slot:Hide()
    return slot
end

--[[
    Populate event slots with colored squares
    @param slots table - Array of slot frames
    @param events table - Array of event data { eventType, spanPosition, ... }
    @return number - Count of events that didn't fit (overflow)
]]
function CalendarUI:PopulateEventSlots(slots, events)
    self:ClearEventSlots(slots)
    local overflow = 0

    for i, evt in ipairs(events) do
        if i <= #slots then
            local slot = slots[i]
            local color = C.CALENDAR_EVENT_COLORS[evt.eventType] or C.CALENDAR_EVENT_COLORS.OTHER
            slot.fill:SetColorTexture(color.r, color.g, color.b, 0.9)

            -- Multi-day span indicators
            local span = evt.spanPosition or "single"
            if span == "start" or span == "middle" then
                slot.rightBar:SetColorTexture(color.r, color.g, color.b, 0.7)
                slot.rightBar:Show()
            end
            if span == "end" or span == "middle" then
                slot.leftBar:SetColorTexture(color.r, color.g, color.b, 0.7)
                slot.leftBar:Show()
            end

            slot:Show()
        else
            overflow = overflow + 1
        end
    end

    return overflow
end

--[[
    Clear all event slots (hide and reset connectors)
    @param slots table - Array of slot frames
]]
function CalendarUI:ClearEventSlots(slots)
    for _, slot in ipairs(slots) do
        slot:Hide()
        slot.leftBar:Hide()
        slot.rightBar:Hide()
    end
end

function CalendarUI:CreateEventCardFrame()
    local card = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    card:SetSize(300, C.CALENDAR_UI.EVENT_CARD_HEIGHT)

    card:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    card:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- Event type color stripe on left edge
    card.colorStripe = card:CreateTexture(nil, "ARTWORK")
    card.colorStripe:SetSize(4, C.CALENDAR_UI.EVENT_CARD_HEIGHT - 8)
    card.colorStripe:SetPoint("LEFT", card, "LEFT", 4, 0)
    card.colorStripe:SetColorTexture(1, 1, 1, 1)

    -- Raid icon
    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(32, 32)
    card.icon:SetPoint("LEFT", card, "LEFT", 12, 0)

    -- Title
    card.title = card:CreateFontString(nil, "OVERLAY")
    card.title:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    card.title:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 8, -2)
    card.title:SetPoint("RIGHT", card, "RIGHT", -60, 0)
    card.title:SetJustifyH("LEFT")
    card.title:SetTextColor(1, 0.84, 0)

    -- Subtitle (time + leader)
    card.subtitle = card:CreateFontString(nil, "OVERLAY")
    card.subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    card.subtitle:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -2)
    card.subtitle:SetTextColor(0.7, 0.7, 0.7)

    -- Signups count
    card.signups = card:CreateFontString(nil, "OVERLAY")
    card.signups:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    card.signups:SetPoint("BOTTOMLEFT", card.icon, "BOTTOMRIGHT", 8, 2)
    card.signups:SetTextColor(0.6, 0.8, 0.6)

    -- View button
    card.viewBtn = CreateFrame("Button", nil, card, "BackdropTemplate")
    card.viewBtn:SetSize(50, 22)
    card.viewBtn:SetPoint("RIGHT", card, "RIGHT", -6, 0)
    card.viewBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    card.viewBtn:SetBackdropColor(0.2, 0.3, 0.2, 1)
    card.viewBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)

    card.viewBtnText = card.viewBtn:CreateFontString(nil, "OVERLAY")
    card.viewBtnText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    card.viewBtnText:SetPoint("CENTER")
    card.viewBtnText:SetText("View")
    card.viewBtnText:SetTextColor(0.6, 1, 0.6)

    card.viewBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    card.viewBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
    end)

    -- Card hover
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end)
    card:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)

    return card
end

function CalendarUI:ReleaseAllCells()
    if not dayCellPool then return end
    for _, cell in ipairs(activeDayCells or {}) do
        dayCellPool:Release(cell)
    end
    wipe(activeDayCells)
end

function CalendarUI:ReleaseAllEventCards()
    if not eventCardPool then return end
    for _, card in ipairs(activeEventCards or {}) do
        eventCardPool:Release(card)
    end
    wipe(activeEventCards)
end

--============================================================
-- APP-WIDE EVENT BANNERS
--============================================================

-- Storage for active banner frames
local activeBanners = {}
local bannerTooltip = nil

--[[
    Create the banner section container for app-wide events
    @param parent Frame - The parent frame
    @return Frame bannerSection
]]
function CalendarUI:CreateBannerSection(parent)
    local UI = C.CALENDAR_BANNER_UI
    if not UI then
        HopeAddon:Debug("CalendarUI: CALENDAR_BANNER_UI constants not loaded")
        return nil
    end

    local section = CreateFrame("Frame", nil, parent)
    local totalHeight = (UI.BANNER_HEIGHT + UI.BANNER_SPACING) * UI.MAX_BANNERS
    section:SetHeight(totalHeight)

    -- Inherit parent width via OnSizeChanged to handle dynamic sizing
    section:SetScript("OnSizeChanged", function(self, width, height)
        -- Propagate width to banners that anchor to this section
        if width and width > 0 then
            for _, banner in ipairs(self.banners or {}) do
                if banner and banner:IsShown() then
                    -- Banners anchor via SetPoint, they'll resize automatically
                end
            end
        end
    end)

    section.banners = {}

    -- Store reference for month navigation updates
    bannerSection = section

    return section
end

--[[
    Create a single banner frame
    @param parent Frame
    @param index number
    @return Frame banner
]]
function CalendarUI:CreateBannerFrame(parent, index)
    local UI = C.CALENDAR_BANNER_UI
    local banner = CreateFrame("Button", nil, parent, "BackdropTemplate")

    banner:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    -- Icon (left side)
    banner.icon = banner:CreateTexture(nil, "ARTWORK")
    banner.icon:SetSize(UI.ICON_SIZE, UI.ICON_SIZE)
    banner.icon:SetPoint("LEFT", banner, "LEFT", 8, 0)

    -- Title (center-left)
    banner.title = banner:CreateFontString(nil, "OVERLAY")
    banner.title:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    banner.title:SetPoint("LEFT", banner.icon, "RIGHT", 8, 0)
    banner.title:SetJustifyH("LEFT")

    -- Date/Time info (right side)
    banner.dateInfo = banner:CreateFontString(nil, "OVERLAY")
    banner.dateInfo:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    banner.dateInfo:SetPoint("RIGHT", banner, "RIGHT", -10, 0)
    banner.dateInfo:SetJustifyH("RIGHT")

    -- Hover effect
    banner:SetScript("OnEnter", function(self)
        if self.eventData then
            CalendarUI:ShowBannerTooltip(self, self.eventData)
        end
        -- Highlight border
        local colors = self.themeColors
        if colors then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold highlight
        end
    end)

    banner:SetScript("OnLeave", function(self)
        CalendarUI:HideBannerTooltip()
        -- Restore themed border
        local colors = self.themeColors
        if colors and colors.border then
            self:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a or 1)
        end
    end)

    banner:Hide()
    return banner
end

--[[
    Populate the banner section with app-wide events for the current month
    @param bannerSection Frame
    @param year number
    @param month number
]]
function CalendarUI:PopulateBanners(bannerSection, year, month)
    if not bannerSection then return end

    local UI = C.CALENDAR_BANNER_UI
    if not UI then return end

    -- Hide all existing banners
    for _, banner in ipairs(activeBanners) do
        banner:Hide()
    end
    wipe(activeBanners)

    -- Get app-wide events for this month
    local events = C:GetAppWideEventsForMonth(year, month)
    if not events or #events == 0 then
        bannerSection:SetHeight(1)  -- Collapse if no events
        return
    end

    -- Limit to max banners
    local displayCount = math.min(#events, UI.MAX_BANNERS)

    -- Create/reuse banner frames
    for i = 1, displayCount do
        local event = events[i]

        -- Get or create banner frame
        local banner = bannerSection.banners[i]
        if not banner then
            banner = self:CreateBannerFrame(bannerSection, i)
            bannerSection.banners[i] = banner
        end

        -- Get color theme
        local colorName = event.colorName or "GOLD"
        local colors = C.APP_WIDE_EVENT_COLORS[colorName] or C.APP_WIDE_EVENT_COLORS.GOLD
        banner.themeColors = colors

        -- Apply theme colors
        banner:SetBackdropColor(colors.bg.r, colors.bg.g, colors.bg.b, colors.bg.a or 0.95)
        banner:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a or 1)

        -- Set icon
        if event.icon then
            banner.icon:SetTexture(event.icon)
            banner.icon:Show()
        else
            banner.icon:Hide()
        end

        -- Set title
        banner.title:SetText(event.title or "Event")
        banner.title:SetTextColor(colors.title.r, colors.title.g, colors.title.b, colors.title.a or 1)

        -- Format date info
        local dateText = self:FormatBannerDateInfo(event)
        banner.dateInfo:SetText(dateText)
        banner.dateInfo:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a or 1)

        -- Store event data for tooltip
        banner.eventData = event

        -- Position banner
        local yOffset = -(i - 1) * (UI.BANNER_HEIGHT + UI.BANNER_SPACING)
        banner:ClearAllPoints()
        banner:SetPoint("TOPLEFT", bannerSection, "TOPLEFT", 0, yOffset)
        banner:SetPoint("RIGHT", bannerSection, "RIGHT", 0, 0)
        banner:SetHeight(UI.BANNER_HEIGHT)

        banner:Show()
        table.insert(activeBanners, banner)
    end

    -- Update section height (don't include trailing spacing after last banner)
    local totalHeight = displayCount * UI.BANNER_HEIGHT + math.max(0, displayCount - 1) * UI.BANNER_SPACING
    bannerSection:SetHeight(totalHeight)
end

--[[
    Format the date/time info for a banner
    @param event table
    @return string
]]
function CalendarUI:FormatBannerDateInfo(event)
    if not event then return "" end

    local startDate = event.startDate
    local endDate = event.endDate or startDate
    local timeStr = C:FormatBannerTime(event.time)

    -- Parse dates for display
    local sYear, sMonth, sDay = startDate:match("^(%d+)-(%d+)-(%d+)$")
    if not sYear then return timeStr end

    local monthNames = C.CALENDAR_UI.MONTH_NAMES
    local startMonthName = monthNames[tonumber(sMonth)]

    -- Format based on whether it's multi-day or single day
    if startDate == endDate then
        -- Single day event
        return startMonthName .. " " .. tonumber(sDay) .. " | " .. timeStr
    else
        -- Multi-day event
        local eYear, eMonth, eDay = endDate:match("^(%d+)-(%d+)-(%d+)$")
        if sMonth == eMonth then
            return startMonthName .. " " .. tonumber(sDay) .. "-" .. tonumber(eDay)
        else
            local endMonthName = monthNames[tonumber(eMonth)]
            return startMonthName .. " " .. tonumber(sDay) .. " - " .. endMonthName .. " " .. tonumber(eDay)
        end
    end
end

--============================================================
-- BANNER TOOLTIP
--============================================================

--[[
    Get or create the banner tooltip frame
    @return Frame tooltip
]]
function CalendarUI:GetBannerTooltip()
    if bannerTooltip then return bannerTooltip end

    local UI = C.CALENDAR_BANNER_UI
    local tooltip = CreateFrame("Frame", "HopeCalendarBannerTooltip", UIParent, "BackdropTemplate")
    tooltip:SetSize(UI.TOOLTIP_WIDTH, 120)
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetFrameLevel(100)

    tooltip:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.98)

    -- Icon (larger for tooltip)
    tooltip.icon = tooltip:CreateTexture(nil, "ARTWORK")
    tooltip.icon:SetSize(40, 40)
    tooltip.icon:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 12, -12)

    -- Title
    tooltip.title = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.title:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    tooltip.title:SetPoint("TOPLEFT", tooltip.icon, "TOPRIGHT", 10, -2)
    tooltip.title:SetPoint("RIGHT", tooltip, "RIGHT", -12, 0)
    tooltip.title:SetJustifyH("LEFT")

    -- Date/Time
    tooltip.dateTime = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.dateTime:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    tooltip.dateTime:SetPoint("TOPLEFT", tooltip.title, "BOTTOMLEFT", 0, -4)
    tooltip.dateTime:SetTextColor(0.8, 0.8, 0.8)

    -- Divider
    tooltip.divider = tooltip:CreateTexture(nil, "ARTWORK")
    tooltip.divider:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    tooltip.divider:SetHeight(1)
    tooltip.divider:SetPoint("LEFT", tooltip, "LEFT", 12, 0)
    tooltip.divider:SetPoint("RIGHT", tooltip, "RIGHT", -12, 0)
    tooltip.divider:SetPoint("TOP", tooltip.icon, "BOTTOM", 0, -8)

    -- Description
    tooltip.description = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.description:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    tooltip.description:SetPoint("TOPLEFT", tooltip.divider, "BOTTOMLEFT", 0, -8)
    tooltip.description:SetPoint("RIGHT", tooltip, "RIGHT", -12, 0)
    tooltip.description:SetJustifyH("LEFT")
    tooltip.description:SetTextColor(0.9, 0.9, 0.9)
    tooltip.description:SetWordWrap(true)

    tooltip:Hide()
    bannerTooltip = tooltip
    return tooltip
end

--[[
    Show the banner tooltip
    @param anchorFrame Frame
    @param event table
]]
function CalendarUI:ShowBannerTooltip(anchorFrame, event)
    if not event then return end

    local tooltip = self:GetBannerTooltip()

    -- Get color theme for border
    local colorName = event.colorName or "GOLD"
    local colors = C.APP_WIDE_EVENT_COLORS[colorName] or C.APP_WIDE_EVENT_COLORS.GOLD

    -- Apply themed border
    tooltip:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a or 1)

    -- Icon
    if event.icon then
        tooltip.icon:SetTexture(event.icon)
        tooltip.icon:Show()
    else
        tooltip.icon:Hide()
    end

    -- Title with theme color
    tooltip.title:SetText(event.title or "Event")
    tooltip.title:SetTextColor(colors.title.r, colors.title.g, colors.title.b, colors.title.a or 1)

    -- Date/Time
    local dateTimeStr = self:FormatBannerDateInfo(event)
    tooltip.dateTime:SetText(dateTimeStr)

    -- Description
    local desc = event.description or "No additional details."
    tooltip.description:SetText(desc)

    -- Calculate dynamic height based on description
    local descHeight = tooltip.description:GetStringHeight()
    local baseHeight = 80  -- Icon + header + divider + padding
    tooltip:SetHeight(baseHeight + descHeight + 12)

    -- Position below the banner
    tooltip:ClearAllPoints()
    tooltip:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)

    tooltip:Show()
end

--[[
    Hide the banner tooltip
]]
function CalendarUI:HideBannerTooltip()
    if bannerTooltip then
        bannerTooltip:Hide()
    end
end

--============================================================
-- HAPPENING NOW SECTION (Active World Bonus Events)
--============================================================

-- Storage for the "Happening Now" section frame
local happeningNowSection = nil
local happeningNowBanner = nil

--[[
    Create the "Happening Now" section container
    @param parent Frame - The parent frame
    @return Frame section
]]
function CalendarUI:CreateHappeningNowSection(parent)
    local UI = C.HAPPENING_NOW_UI
    if not UI then
        HopeAddon:Debug("CalendarUI: HAPPENING_NOW_UI constants not loaded")
        return nil
    end

    local section = CreateFrame("Frame", nil, parent)
    section:SetHeight(UI.BANNER_HEIGHT + UI.SECTION_PADDING)

    -- Store reference
    happeningNowSection = section

    return section
end

--[[
    Create the "Happening Now" banner frame
    @param parent Frame
    @return Frame banner
]]
function CalendarUI:CreateHappeningNowBanner(parent)
    local UI = C.HAPPENING_NOW_UI
    local banner = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    banner:SetHeight(UI.BANNER_HEIGHT)

    banner:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    -- Glow border texture (overlays the base border for glow effect)
    banner.glowBorder = CreateFrame("Frame", nil, banner, "BackdropTemplate")
    banner.glowBorder:SetPoint("TOPLEFT", banner, "TOPLEFT", -3, 3)
    banner.glowBorder:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", 3, -3)
    banner.glowBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
    })
    banner.glowBorder:SetFrameLevel(banner:GetFrameLevel() - 1)

    -- Icon (left side, larger)
    banner.icon = banner:CreateTexture(nil, "ARTWORK")
    banner.icon:SetSize(UI.ICON_SIZE, UI.ICON_SIZE)
    banner.icon:SetPoint("LEFT", banner, "LEFT", 10, 0)

    -- Title (large, bold)
    banner.title = banner:CreateFontString(nil, "OVERLAY")
    banner.title:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    banner.title:SetPoint("TOPLEFT", banner.icon, "TOPRIGHT", 10, -2)
    banner.title:SetJustifyH("LEFT")

    -- Subtitle (bonus description)
    banner.subtitle = banner:CreateFontString(nil, "OVERLAY")
    banner.subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    banner.subtitle:SetPoint("TOPLEFT", banner.title, "BOTTOMLEFT", 0, -2)
    banner.subtitle:SetJustifyH("LEFT")

    -- Flavor text (italic, faction-colored)
    banner.flavor = banner:CreateFontString(nil, "OVERLAY")
    banner.flavor:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    banner.flavor:SetPoint("TOPLEFT", banner.subtitle, "BOTTOMLEFT", 0, -1)
    banner.flavor:SetJustifyH("LEFT")

    -- "Ends in X days" countdown (right side)
    banner.countdown = banner:CreateFontString(nil, "OVERLAY")
    banner.countdown:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    banner.countdown:SetPoint("RIGHT", banner, "RIGHT", -12, 0)
    banner.countdown:SetJustifyH("RIGHT")

    -- "HAPPENING NOW" label (above countdown)
    banner.label = banner:CreateFontString(nil, "OVERLAY")
    banner.label:SetFont(HopeAddon.assets.fonts.HEADER, 8, "OUTLINE")
    banner.label:SetPoint("BOTTOM", banner.countdown, "TOP", 0, 2)
    banner.label:SetJustifyH("RIGHT")
    banner.label:SetText("HAPPENING NOW")

    banner:Hide()
    return banner
end

--[[
    Populate the "Happening Now" section with active events
    @param section Frame
    @return number - Height of the section (0 if no active events)
]]
function CalendarUI:PopulateHappeningNow(section)
    if not section then return 0 end

    local UI = C.HAPPENING_NOW_UI
    if not UI then return 0 end

    -- Get active "Happening Now" events
    local events = C:GetHappeningNowEvents()
    if not events or #events == 0 then
        section:SetHeight(1)
        if happeningNowBanner then
            happeningNowBanner:Hide()
        end
        return 0
    end

    -- For now, show only the first active event (most important)
    local event = events[1]

    -- Get or create the banner
    if not happeningNowBanner then
        happeningNowBanner = self:CreateHappeningNowBanner(section)
    end
    happeningNowBanner:SetParent(section)
    happeningNowBanner:ClearAllPoints()
    happeningNowBanner:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    happeningNowBanner:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)

    -- Get color theme
    local colorName = event.colorName or "BLOOD_RED"
    local colors = C.APP_WIDE_EVENT_COLORS[colorName] or C.APP_WIDE_EVENT_COLORS.BLOOD_RED

    -- Apply theme colors with slightly more intensity for "Happening Now"
    local bgColor = colors.bg
    happeningNowBanner:SetBackdropColor(bgColor.r * 1.2, bgColor.g * 1.2, bgColor.b * 1.2, bgColor.a or 0.98)
    happeningNowBanner:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a or 1)

    -- Apply glow border color (brighter for emphasis)
    happeningNowBanner.glowBorder:SetBackdropBorderColor(
        colors.border.r * 0.7,
        colors.border.g * 0.7,
        colors.border.b * 0.7,
        0.4
    )

    -- Set icon
    if event.icon then
        happeningNowBanner.icon:SetTexture(event.icon)
        happeningNowBanner.icon:Show()
    else
        happeningNowBanner.icon:Hide()
    end

    -- Set title
    happeningNowBanner.title:SetText(event.title or "Event")
    happeningNowBanner.title:SetTextColor(colors.title.r, colors.title.g, colors.title.b, colors.title.a or 1)

    -- Set subtitle (bonus description)
    happeningNowBanner.subtitle:SetText(event.subtitle or "")
    happeningNowBanner.subtitle:SetTextColor(colors.text.r, colors.text.g, colors.text.b, colors.text.a or 1)

    -- Set faction-appropriate flavor text
    local faction = UnitFactionGroup("player")
    local flavorText = ""
    if faction == "Horde" and event.flavorHorde then
        flavorText = '"' .. event.flavorHorde .. '"'
    elseif faction == "Alliance" and event.flavorAlliance then
        flavorText = '"' .. event.flavorAlliance .. '"'
    elseif event.flavorHorde then
        -- Default to Horde if faction can't be determined
        flavorText = '"' .. event.flavorHorde .. '"'
    end
    happeningNowBanner.flavor:SetText(flavorText)
    -- Faction color for flavor text
    if faction == "Horde" then
        happeningNowBanner.flavor:SetTextColor(0.9, 0.3, 0.3, 0.9)
    else
        happeningNowBanner.flavor:SetTextColor(0.3, 0.5, 0.9, 0.9)
    end

    -- Set countdown
    local daysRemaining = C:GetHappeningNowDaysRemaining(event)
    local countdownText
    if daysRemaining == 0 then
        countdownText = "Ends today!"
    elseif daysRemaining == 1 then
        countdownText = "Ends in 1 day"
    else
        countdownText = "Ends in " .. daysRemaining .. " days"
    end
    happeningNowBanner.countdown:SetText(countdownText)
    happeningNowBanner.countdown:SetTextColor(colors.text.r, colors.text.g, colors.text.b, 0.9)

    -- "HAPPENING NOW" label color
    happeningNowBanner.label:SetTextColor(colors.title.r, colors.title.g, colors.title.b, 0.8)

    happeningNowBanner:Show()

    -- Update section height
    local totalHeight = UI.BANNER_HEIGHT + UI.SECTION_PADDING
    section:SetHeight(totalHeight)

    return totalHeight
end

--============================================================
-- DAY HOVER TOOLTIP
--============================================================

--[[
    Get or create the day hover tooltip frame
    @return Frame tooltip
]]
function CalendarUI:GetDayTooltip()
    if dayTooltip then return dayTooltip end

    local tooltip = CreateFrame("Frame", "HopeCalendarDayTooltip", UIParent, "BackdropTemplate")
    tooltip:SetSize(200, 100)  -- Will resize dynamically
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetFrameLevel(100)

    -- Tooltip style backdrop (compact, subtle)
    tooltip:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    tooltip:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.9)

    -- Date header (gold text)
    tooltip.header = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.header:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    tooltip.header:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 8, -8)
    tooltip.header:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", -8, -8)
    tooltip.header:SetJustifyH("LEFT")
    tooltip.header:SetTextColor(1, 0.84, 0)

    -- Storage for event row frames
    tooltip.eventRows = {}

    tooltip:Hide()
    dayTooltip = tooltip
    return tooltip
end

--[[
    Get or create an event row in the tooltip
    @param index number - Row index (1-based)
    @return Frame eventRow
]]
function CalendarUI:GetTooltipEventRow(index)
    -- Guard: prevent unbounded frame creation
    if index > MAX_TOOLTIP_ROWS then
        return nil
    end

    local tooltip = self:GetDayTooltip()

    if tooltip.eventRows[index] then
        return tooltip.eventRows[index]
    end

    -- Create a new event row
    local row = CreateFrame("Frame", nil, tooltip)
    row:SetHeight(16)
    row:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 8, -26 - (index - 1) * 16)
    row:SetPoint("RIGHT", tooltip, "RIGHT", -8, 0)

    -- Color dot (event type indicator)
    row.colorDot = row:CreateTexture(nil, "ARTWORK")
    row.colorDot:SetSize(8, 8)
    row.colorDot:SetPoint("LEFT", row, "LEFT", 0, 0)

    -- Time text
    row.time = row:CreateFontString(nil, "OVERLAY")
    row.time:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    row.time:SetPoint("LEFT", row.colorDot, "RIGHT", 4, 0)
    row.time:SetWidth(40)
    row.time:SetJustifyH("LEFT")
    row.time:SetTextColor(0.7, 0.7, 0.7)

    -- Title text
    row.title = row:CreateFontString(nil, "OVERLAY")
    row.title:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    row.title:SetPoint("LEFT", row.time, "RIGHT", 4, 0)
    row.title:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.title:SetJustifyH("LEFT")
    row.title:SetTextColor(0.9, 0.9, 0.9)

    row:Hide()
    tooltip.eventRows[index] = row
    return row
end

--[[
    Show the day tooltip with events
    @param anchorFrame Frame - The day cell to anchor to
    @param dateStr string - YYYY-MM-DD format
    @param events table - Array of events for this day
]]
function CalendarUI:ShowDayTooltip(anchorFrame, dateStr, events)
    if not events or #events == 0 then return end

    local tooltip = self:GetDayTooltip()

    -- Parse date for display
    local year, month, day = Calendar:ParseDate(dateStr)
    if not year then return end

    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    tooltip.header:SetText(dayName .. ", " .. monthName .. " " .. day)

    -- Hide all existing rows first
    for _, row in ipairs(tooltip.eventRows) do
        row:Hide()
    end

    -- Populate event rows (max 5 to prevent tooltip from being too tall)
    local maxEvents = math.min(#events, 5)
    local displayedEvents = 0
    for i = 1, maxEvents do
        local event = events[i]
        local row = self:GetTooltipEventRow(i)
        if not row then break end  -- Guard against row limit

        -- Color dot based on event type
        local eventColor = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER
        row.colorDot:SetColorTexture(eventColor.r, eventColor.g, eventColor.b, 1)

        -- Time (or TBD if not set) - show dual time if different timezone
        row.time:SetText(Calendar:FormatDualTime(event.startTime) or "TBD")

        -- Title (truncate if too long)
        local title = event.title or "Event"
        if #title > 20 then
            title = title:sub(1, 18) .. "..."
        end
        row.title:SetText(title)

        row:Show()
        displayedEvents = displayedEvents + 1
    end

    -- Add "and X more..." if there are more events
    local extraRowIndex = displayedEvents + 1
    local remainingEvents = #events - displayedEvents
    if remainingEvents > 0 then
        local moreRow = self:GetTooltipEventRow(extraRowIndex)
        if moreRow then
            moreRow.colorDot:SetColorTexture(0.5, 0.5, 0.5, 0)  -- Invisible dot
            moreRow.time:SetText("")
            moreRow.title:SetText("|cFF888888... and " .. remainingEvents .. " more|r")
            moreRow:Show()
            extraRowIndex = extraRowIndex + 1
        end
    end

    -- Calculate tooltip height
    local rowCount = displayedEvents + (remainingEvents > 0 and 1 or 0)
    local tooltipHeight = 32 + rowCount * 16 + 8  -- Header + rows + padding

    tooltip:SetHeight(tooltipHeight)
    tooltip:SetWidth(240)  -- Wider for dual time display

    -- Position tooltip to the right of the cell (smart positioning)
    tooltip:ClearAllPoints()

    -- Get screen dimensions to check if tooltip would go off-screen
    local screenWidth = GetScreenWidth()
    local cellRight = anchorFrame:GetRight()

    if cellRight and cellRight + 210 > screenWidth then
        -- Position to the left if it would go off the right edge
        tooltip:SetPoint("RIGHT", anchorFrame, "LEFT", -5, 0)
    else
        -- Default: position to the right
        tooltip:SetPoint("LEFT", anchorFrame, "RIGHT", 5, 0)
    end

    tooltip:Show()
end

--[[
    Hide the day tooltip
]]
function CalendarUI:HideDayTooltip()
    if dayTooltip then
        dayTooltip:Hide()
    end
end

--============================================================
-- CALENDAR HEADER
--============================================================

--[[
    Create calendar header with month navigation and create button
    @param parent Frame
    @return Frame header
]]
function CalendarUI:CreateCalendarHeader(parent)
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(40)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    title:SetPoint("LEFT", header, "LEFT", 10, 0)
    title:SetText("RAID CALENDAR")
    title:SetTextColor(1, 0.84, 0)

    -- Create Event button
    local createBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    createBtn:SetSize(100, 26)
    createBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
    createBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    createBtn:SetBackdropColor(0.15, 0.3, 0.15, 1)
    createBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)

    local createText = createBtn:CreateFontString(nil, "OVERLAY")
    createText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    createText:SetPoint("CENTER")
    createText:SetText("+ Create Event")
    createText:SetTextColor(0.5, 1, 0.5)

    createBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:ShowCreateEventPopup()
    end)
    createBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    createBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
    end)

    return header
end

--============================================================
-- MONTH NAVIGATION
--============================================================

--[[
    Create month navigation bar
    @param parent Frame
    @return Frame navBar
]]
function CalendarUI:CreateMonthNavigation(parent)
    local navBar = CreateFrame("Frame", nil, parent)
    navBar:SetHeight(30)

    -- Previous month button
    local prevBtn = CreateFrame("Button", nil, navBar)
    prevBtn:SetSize(30, 24)
    prevBtn:SetPoint("LEFT", navBar, "LEFT", 10, 0)

    local prevText = prevBtn:CreateFontString(nil, "OVERLAY")
    prevText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    prevText:SetPoint("CENTER")
    prevText:SetText("<")
    prevText:SetTextColor(0.8, 0.8, 0.8)

    prevBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:NavigateMonth(-1)
    end)
    prevBtn:SetScript("OnEnter", function() prevText:SetTextColor(1, 0.84, 0) end)
    prevBtn:SetScript("OnLeave", function() prevText:SetTextColor(0.8, 0.8, 0.8) end)

    -- Month/Year display
    navBar.monthLabel = navBar:CreateFontString(nil, "OVERLAY")
    navBar.monthLabel:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    navBar.monthLabel:SetPoint("CENTER", navBar, "CENTER", 0, 0)
    navBar.monthLabel:SetTextColor(1, 1, 1)

    -- Next month button
    local nextBtn = CreateFrame("Button", nil, navBar)
    nextBtn:SetSize(30, 24)
    nextBtn:SetPoint("RIGHT", navBar, "RIGHT", -10, 0)

    local nextText = nextBtn:CreateFontString(nil, "OVERLAY")
    nextText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    nextText:SetPoint("CENTER")
    nextText:SetText(">")
    nextText:SetTextColor(0.8, 0.8, 0.8)

    nextBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:NavigateMonth(1)
    end)
    nextBtn:SetScript("OnEnter", function() nextText:SetTextColor(1, 0.84, 0) end)
    nextBtn:SetScript("OnLeave", function() nextText:SetTextColor(0.8, 0.8, 0.8) end)

    return navBar
end

--[[
    Navigate to previous/next month
    @param delta number - -1 for previous, 1 for next
]]
function CalendarUI:NavigateMonth(delta)
    currentMonth = currentMonth + delta

    if currentMonth > 12 then
        currentMonth = 1
        currentYear = currentYear + 1
    elseif currentMonth < 1 then
        currentMonth = 12
        currentYear = currentYear - 1
    end

    -- Update UI state
    local socialUI = HopeAddon:GetSocialUI()
    if socialUI and socialUI.calendar then
        socialUI.calendar.viewMonth = currentMonth
        socialUI.calendar.viewYear = currentYear
    end

    -- Refresh the banner section for the new month
    if bannerSection then
        self:PopulateBanners(bannerSection, currentYear, currentMonth)
    end

    -- Refresh the grid
    if monthGrid then
        self:PopulateMonthGrid(monthGrid)
    end
end

--============================================================
-- MONTH GRID
--============================================================

--[[
    Create the full month grid with day headers and cells
    @param parent Frame
    @return Frame gridContainer
]]
function CalendarUI:CreateMonthGrid(parent)
    local UI = C.CALENDAR_UI

    local container = CreateFrame("Frame", nil, parent)
    local gridWidth = (UI.CELL_WIDTH + UI.CELL_SPACING) * UI.GRID_COLS - UI.CELL_SPACING
    local gridHeight = 20 + (UI.CELL_HEIGHT + UI.CELL_SPACING) * UI.GRID_ROWS - UI.CELL_SPACING
    container:SetSize(gridWidth, gridHeight)

    -- Day name headers (Sun, Mon, Tue, ...)
    local headerRow = CreateFrame("Frame", nil, container)
    headerRow:SetHeight(18)
    headerRow:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    headerRow:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    for i, dayName in ipairs(UI.DAY_NAMES) do
        local label = headerRow:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        label:SetTextColor(0.6, 0.6, 0.6)
        label:SetText(dayName)
        local xOffset = (i - 1) * (UI.CELL_WIDTH + UI.CELL_SPACING) + UI.CELL_WIDTH / 2
        label:SetPoint("TOP", headerRow, "TOPLEFT", xOffset, 0)
    end

    -- Grid area
    container.gridArea = CreateFrame("Frame", nil, container)
    container.gridArea:SetPoint("TOPLEFT", headerRow, "BOTTOMLEFT", 0, -4)
    container.gridArea:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)

    monthGrid = container
    return container
end

--[[
    Populate the month grid with day cells
    @param gridContainer Frame
]]
function CalendarUI:PopulateMonthGrid(gridContainer)
    if not gridContainer or not gridContainer.gridArea then return end

    local UI = C.CALENDAR_UI

    -- Release existing cells
    self:ReleaseAllCells()

    -- Update month label in navigation
    local navBar = gridContainer:GetParent() and gridContainer:GetParent().navBar
    if navBar and navBar.monthLabel then
        navBar.monthLabel:SetText(UI.MONTH_NAMES[currentMonth] .. " " .. currentYear)
    end

    -- Get first day of month and days in month
    local firstDay = date("*t", time({ year = currentYear, month = currentMonth, day = 1 }))
    local firstDayOfWeek = firstDay.wday  -- 1 = Sunday, 7 = Saturday

    -- Days in current month
    local daysInMonth = 31
    if currentMonth == 4 or currentMonth == 6 or currentMonth == 9 or currentMonth == 11 then
        daysInMonth = 30
    elseif currentMonth == 2 then
        -- Leap year check
        if (currentYear % 4 == 0 and currentYear % 100 ~= 0) or (currentYear % 400 == 0) then
            daysInMonth = 29
        else
            daysInMonth = 28
        end
    end

    -- Get today for highlighting
    local today = date("*t")
    local todayStr = string.format("%04d-%02d-%02d", today.year, today.month, today.day)

    -- Get events for this month
    local eventsForMonth = Calendar and Calendar:GetEventsForMonth(currentYear, currentMonth) or {}

    -- Create cells
    local cellIndex = 1
    for row = 1, UI.GRID_ROWS do
        for col = 1, UI.GRID_COLS do
            local cell = dayCellPool:Acquire()
            cell:SetParent(gridContainer.gridArea)

            local xOffset = (col - 1) * (UI.CELL_WIDTH + UI.CELL_SPACING)
            local yOffset = -(row - 1) * (UI.CELL_HEIGHT + UI.CELL_SPACING)
            cell:SetPoint("TOPLEFT", gridContainer.gridArea, "TOPLEFT", xOffset, yOffset)

            -- Calculate which day this cell represents
            local dayNum = cellIndex - firstDayOfWeek + 1

            if dayNum >= 1 and dayNum <= daysInMonth then
                cell.dayNumber:SetText(tostring(dayNum))
                cell.dayNumber:SetTextColor(0.9, 0.9, 0.9)

                local dateStr = string.format("%04d-%02d-%02d", currentYear, currentMonth, dayNum)
                cell.dateStr = dateStr

                -- Highlight today
                if dateStr == todayStr then
                    cell.isToday = true
                    cell:SetBackdropBorderColor(1, 0.84, 0, 0.8)
                    cell.dayNumber:SetTextColor(1, 0.84, 0)
                else
                    cell.isToday = false
                end

                -- Show event indicators in structured slots
                local eventData = eventsForMonth[dateStr]
                if eventData and eventData.events then
                    -- Separate events by category
                    local serverEvents, guildEvents = {}, {}
                    for _, evt in ipairs(eventData.events) do
                        if evt.eventType == "SERVER" then
                            table.insert(serverEvents, evt)
                        else
                            table.insert(guildEvents, evt)
                        end
                    end

                    -- Populate server slots (top row)
                    self:PopulateEventSlots(cell.serverSlots, serverEvents)

                    -- Populate guild slots (bottom row) with overflow
                    local overflow = self:PopulateEventSlots(cell.guildSlots, guildEvents)
                    if overflow > 0 then
                        cell.overflowText:SetText("+" .. overflow)
                        cell.overflowText:Show()
                    else
                        cell.overflowText:Hide()
                    end
                else
                    self:ClearEventSlots(cell.serverSlots)
                    self:ClearEventSlots(cell.guildSlots)
                    cell.overflowText:Hide()
                end

                -- Click handler
                cell:SetScript("OnClick", function()
                    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                    self:SelectDate(dateStr)
                end)

                cell:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            else
                -- Empty cell (outside current month)
                cell.dayNumber:SetText("")
                self:ClearEventSlots(cell.serverSlots)
                self:ClearEventSlots(cell.guildSlots)
                cell.overflowText:Hide()
                cell.dateStr = nil
                cell:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
                cell:SetScript("OnClick", nil)
            end

            cell:Show()
            table.insert(activeDayCells, cell)
            cellIndex = cellIndex + 1
        end
    end
end

--============================================================
-- SELECTED DAY PANEL
--============================================================

--[[
    Create the selected day events panel
    @param parent Frame
    @return Frame panel
]]
function CalendarUI:CreateSelectedDayPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetHeight(C.CALENDAR_UI.DAY_PANEL_HEIGHT)

    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    panel:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

    -- Header
    panel.header = panel:CreateFontString(nil, "OVERLAY")
    panel.header:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    panel.header:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
    panel.header:SetText("Select a day to view events")
    panel.header:SetTextColor(0.7, 0.7, 0.7)

    -- Event count
    panel.eventCount = panel:CreateFontString(nil, "OVERLAY")
    panel.eventCount:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    panel.eventCount:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -12, -10)
    panel.eventCount:SetTextColor(0.6, 0.6, 0.6)

    -- Scroll area for event cards
    local Comp = HopeAddon.Components
    local C_MARGIN = Comp and Comp.MARGIN_NORMAL or 10
    local C_SCROLLBAR = Comp and Comp.SCROLLBAR_WIDTH or 25

    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    panel.scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", C_MARGIN, -30)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -(C_MARGIN + C_SCROLLBAR), C_MARGIN)

    panel.scrollChild = CreateFrame("Frame", nil, panel.scrollFrame)
    panel.scrollFrame:SetScrollChild(panel.scrollChild)

    -- Use OnSizeChanged to handle scrollChild width after layout
    panel.scrollFrame:SetScript("OnSizeChanged", function(self, newWidth, newHeight)
        if newWidth and newWidth > 0 then
            panel.scrollChild:SetWidth(newWidth)
        end
    end)

    -- Set initial width with fallback
    local initialWidth = panel.scrollFrame:GetWidth()
    if initialWidth and initialWidth > 0 then
        panel.scrollChild:SetWidth(initialWidth)
    else
        panel.scrollChild:SetWidth(300)  -- Reasonable fallback until layout completes
    end
    panel.scrollChild:SetHeight(1)

    selectedDayPanel = panel
    return panel
end

--[[
    Select a date and show its events
    @param dateStr string - YYYY-MM-DD
]]
function CalendarUI:SelectDate(dateStr)
    if not selectedDayPanel then return end

    -- Update UI state
    local socialUI = HopeAddon:GetSocialUI()
    if socialUI and socialUI.calendar then
        socialUI.calendar.selectedDate = dateStr
    end

    -- Release existing event cards
    self:ReleaseAllEventCards()

    -- Parse date for display
    local year, month, day = Calendar:ParseDate(dateStr)
    if not year then return end

    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    local displayDate = dayName .. ", " .. monthName .. " " .. day

    -- Get events for this date
    local events = Calendar:GetEventsForDate(dateStr)

    -- Update header
    selectedDayPanel.header:SetText("SELECTED: " .. displayDate)
    selectedDayPanel.header:SetTextColor(1, 0.84, 0)

    selectedDayPanel.eventCount:SetText(#events .. " event" .. (#events ~= 1 and "s" or ""))

    -- Create event cards
    local yOffset = 0
    for _, event in ipairs(events) do
        local card = self:AcquireEventCard(event)
        card:SetParent(selectedDayPanel.scrollChild)
        card:SetPoint("TOPLEFT", selectedDayPanel.scrollChild, "TOPLEFT", 0, -yOffset)
        card:SetPoint("RIGHT", selectedDayPanel.scrollChild, "RIGHT", 0, 0)
        card:Show()

        table.insert(activeEventCards, card)
        yOffset = yOffset + C.CALENDAR_UI.EVENT_CARD_HEIGHT + C.CALENDAR_UI.EVENT_CARD_SPACING
    end

    -- No events message
    if #events == 0 then
        local noEvents = selectedDayPanel.scrollChild:CreateFontString(nil, "OVERLAY")
        noEvents:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        noEvents:SetPoint("TOP", selectedDayPanel.scrollChild, "TOP", 0, -20)
        noEvents:SetText("No events scheduled for this day")
        noEvents:SetTextColor(0.5, 0.5, 0.5)
        -- Store for cleanup (will be cleared with card pool)
    end

    -- Update scroll child height
    selectedDayPanel.scrollChild:SetHeight(math.max(yOffset, 50))
end

--[[
    Acquire and populate an event card
    @param event table
    @return Frame card
]]
function CalendarUI:AcquireEventCard(event)
    local card = eventCardPool:Acquire()
    card.eventId = event.id

    -- Check if this is a server event (read-only, no signups)
    local isServerEvent = Calendar:IsServerEvent(event)

    -- Icon based on event type
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    card.icon:SetTexture(eventType.icon)

    -- Color stripe based on event type
    local eventColor = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER
    card.colorStripe:SetColorTexture(eventColor.r, eventColor.g, eventColor.b, 1)

    -- Title
    card.title:SetText(event.title or "Event")

    if isServerEvent then
        -- Server event styling
        card:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold border

        -- Subtitle (time only, no leader for server events) - show dual time
        local subtitle = Calendar:FormatDualTime(event.startTime) or "All Day"
        card.subtitle:SetText(subtitle)

        -- Show "SERVER EVENT" label instead of signup count
        card.signups:SetText("|cFFFFD700SERVER EVENT|r")

        -- Hide view button for server events (no signups)
        card.viewBtn:Hide()

        -- Card click shows description popup for server events
        card:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowServerEventDetail(event)
        end)
    else
        -- Guild event styling (default)
        card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

        -- Subtitle (time and leader) - show dual time
        local subtitle = Calendar:FormatDualTime(event.startTime) or "TBD"
        if event.leader then
            local classColor = RAID_CLASS_COLORS[event.leaderClass] or { r = 0.8, g = 0.8, b = 0.8 }
            subtitle = subtitle .. " | |cFF" .. string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. event.leader .. "|r"
        end
        card.subtitle:SetText(subtitle)

        -- Signup count
        local signupCount = 0
        for _ in pairs(event.signups or {}) do
            signupCount = signupCount + 1
        end
        card.signups:SetText(signupCount .. "/" .. (event.raidSize or 10) .. " signed up")

        -- Show view button for guild events
        card.viewBtn:Show()

        -- View button click
        card.viewBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowEventDetail(event)
        end)

        -- Card click (same as view)
        card:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowEventDetail(event)
        end)
    end

    return card
end

--============================================================
-- EVENT DETAIL POPUP
--============================================================

--[[
    Get or create the event detail popup
    @return Frame popup
]]
function CalendarUI:GetEventDetailPopup()
    if eventDetailPopup then return eventDetailPopup end

    local UI = C.CALENDAR_UI
    local popup = CreateFrame("Frame", "HopeCalendarEventDetail", UIParent, "BackdropTemplate")
    popup:SetSize(UI.DETAIL_POPUP_WIDTH, UI.DETAIL_POPUP_HEIGHT)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(100)

    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    popup:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)

    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Title
    popup.title = popup:CreateFontString(nil, "OVERLAY")
    popup.title:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    popup.title:SetPoint("TOP", popup, "TOP", 0, -20)
    popup.title:SetTextColor(1, 0.84, 0)

    -- Date/Time
    popup.dateTime = popup:CreateFontString(nil, "OVERLAY")
    popup.dateTime:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.dateTime:SetPoint("TOP", popup.title, "BOTTOM", 0, -6)
    popup.dateTime:SetTextColor(0.8, 0.8, 0.8)

    -- Leader
    popup.leader = popup:CreateFontString(nil, "OVERLAY")
    popup.leader:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.leader:SetPoint("TOP", popup.dateTime, "BOTTOM", 0, -12)
    popup.leader:SetTextColor(0.7, 0.7, 0.7)

    -- Status
    popup.status = popup:CreateFontString(nil, "OVERLAY")
    popup.status:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.status:SetPoint("TOP", popup.leader, "BOTTOM", 0, -4)
    popup.status:SetTextColor(0.7, 0.7, 0.7)

    -- Description
    popup.description = popup:CreateFontString(nil, "OVERLAY")
    popup.description:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.description:SetPoint("TOP", popup.status, "BOTTOM", 0, -12)
    popup.description:SetPoint("LEFT", popup, "LEFT", 20, 0)
    popup.description:SetPoint("RIGHT", popup, "RIGHT", -20, 0)
    popup.description:SetJustifyH("CENTER")
    popup.description:SetTextColor(0.9, 0.9, 0.9)

    -- Divider
    local divider = popup:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:SetPoint("LEFT", popup, "LEFT", 15, 0)
    divider:SetPoint("RIGHT", popup, "RIGHT", -15, 0)
    divider:SetPoint("TOP", popup.description, "BOTTOM", 0, -15)
    divider:SetVertexColor(0.5, 0.5, 0.5, 0.5)

    -- Signups header
    popup.signupsHeader = popup:CreateFontString(nil, "OVERLAY")
    popup.signupsHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    popup.signupsHeader:SetPoint("TOP", divider, "BOTTOM", 0, -10)
    popup.signupsHeader:SetText("SIGNUPS")
    popup.signupsHeader:SetTextColor(1, 0.84, 0)

    -- Signup scroll area
    popup.signupScroll = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    popup.signupScroll:SetPoint("TOPLEFT", popup.signupsHeader, "BOTTOMLEFT", -10, -8)
    popup.signupScroll:SetPoint("RIGHT", popup, "RIGHT", -30, 0)
    popup.signupScroll:SetHeight(150)

    popup.signupContent = CreateFrame("Frame", nil, popup.signupScroll)
    popup.signupContent:SetSize(popup.signupScroll:GetWidth(), 1)
    popup.signupScroll:SetScrollChild(popup.signupContent)

    -- Your status label
    popup.yourStatus = popup:CreateFontString(nil, "OVERLAY")
    popup.yourStatus:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.yourStatus:SetPoint("BOTTOM", popup, "BOTTOM", 0, 100)
    popup.yourStatus:SetTextColor(0.8, 0.8, 0.8)

    -- Role buttons container
    popup.roleButtons = CreateFrame("Frame", nil, popup)
    popup.roleButtons:SetSize(360, 30)
    popup.roleButtons:SetPoint("BOTTOM", popup, "BOTTOM", 0, 60)

    -- Create role signup buttons
    local roleOrder = { "tank", "healer", "dps" }
    local btnWidth = 110
    local btnSpacing = 10
    local totalWidth = (btnWidth * 3) + (btnSpacing * 2)
    local startX = -totalWidth / 2 + btnWidth / 2

    for i, roleKey in ipairs(roleOrder) do
        local roleData = C.CALENDAR_ROLES[roleKey]
        local btn = CreateFrame("Button", nil, popup.roleButtons, "BackdropTemplate")
        btn:SetSize(btnWidth, 26)
        btn:SetPoint("CENTER", popup.roleButtons, "CENTER", startX + (i - 1) * (btnWidth + btnSpacing), 0)

        btn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        local color = HopeAddon.colors[roleData.color]
        btn:SetBackdropColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, 1)
        btn:SetBackdropBorderColor(color.r, color.g, color.b, 0.8)

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        text:SetPoint("CENTER")
        text:SetText("Sign Up: " .. roleData.name)
        text:SetTextColor(color.r, color.g, color.b)

        btn.roleKey = roleKey
        btn.borderColor = color  -- Store for OnLeave closure
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            local c = self.borderColor
            self:SetBackdropBorderColor(c.r, c.g, c.b, 0.8)
        end)

        popup["btn_" .. roleKey] = btn
    end

    -- Save as Template button (for event owners)
    popup.saveTemplateBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    popup.saveTemplateBtn:SetSize(110, 26)
    popup.saveTemplateBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 15, 15)
    popup.saveTemplateBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.saveTemplateBtn:SetBackdropColor(0.2, 0.25, 0.3, 1)
    popup.saveTemplateBtn:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)

    local saveTemplateText = popup.saveTemplateBtn:CreateFontString(nil, "OVERLAY")
    saveTemplateText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    saveTemplateText:SetPoint("CENTER")
    saveTemplateText:SetText("Save as Template")
    saveTemplateText:SetTextColor(0.6, 0.8, 1)

    popup.saveTemplateBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    popup.saveTemplateBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)
    end)

    -- Close button at bottom
    local closeBottom = CreateFrame("Button", nil, popup, "BackdropTemplate")
    closeBottom:SetSize(80, 26)
    closeBottom:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -15, 15)
    closeBottom:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    closeBottom:SetBackdropColor(0.2, 0.2, 0.2, 1)
    closeBottom:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    local closeText = closeBottom:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    closeText:SetPoint("CENTER")
    closeText:SetText("Close")
    closeText:SetTextColor(0.8, 0.8, 0.8)

    closeBottom:SetScript("OnClick", function()
        popup:Hide()
    end)
    closeBottom:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    closeBottom:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end)

    popup:Hide()
    eventDetailPopup = popup
    return popup
end

--[[
    Show event detail popup
    @param event table
]]
function CalendarUI:ShowEventDetail(event)
    if not event then return end

    local popup = self:GetEventDetailPopup()
    popup.currentEvent = event

    -- Show/hide Save as Template button for event owners
    local isOwner = Calendar:IsMyEvent(event.id)
    if popup.saveTemplateBtn then
        if isOwner then
            popup.saveTemplateBtn:Show()
            popup.saveTemplateBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                CalendarUI:ShowSaveTemplateDialog(event)
            end)
        else
            popup.saveTemplateBtn:Hide()
        end
    end

    -- Title
    popup.title:SetText(event.title or "Event")

    -- Date/Time - show dual time if different timezone
    local year, month, day = Calendar:ParseDate(event.date)
    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    local timeDisplay = Calendar:FormatDualTime(event.startTime) or "TBD"
    popup.dateTime:SetText(dayName .. ", " .. monthName .. " " .. day .. " at " .. timeDisplay)

    -- Leader
    local leaderText = "Leader: "
    if event.leader then
        local classColor = RAID_CLASS_COLORS[event.leaderClass] or { r = 0.8, g = 0.8, b = 0.8 }
        leaderText = leaderText .. "|cFF" .. string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. event.leader .. "|r"
    else
        leaderText = leaderText .. "Unknown"
    end
    popup.leader:SetText(leaderText)

    -- Status
    local signupCount = 0
    for _ in pairs(event.signups or {}) do
        signupCount = signupCount + 1
    end
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    popup.status:SetText(eventType.name .. " | " .. (event.raidSize or 10) .. "-man | " .. signupCount .. " signed up")

    -- Description
    if event.description and event.description ~= "" then
        popup.description:SetText("\"" .. event.description .. "\"")
    else
        popup.description:SetText("")
    end

    -- Populate signup list by role
    self:PopulateSignupList(popup.signupContent, event)

    -- Your signup status
    local mySignup = Calendar:GetMySignup(event.id)
    if mySignup then
        local statusText = C.CALENDAR_SIGNUP_STATUS[mySignup.status]
        local roleText = C.CALENDAR_ROLES[mySignup.role]
        popup.yourStatus:SetText("YOUR STATUS: " .. (statusText and statusText.name or "Unknown") .. " as " .. (roleText and roleText.name or ""))
        popup.roleButtons:Hide()
    else
        popup.yourStatus:SetText("YOUR STATUS: Not signed up")
        popup.roleButtons:Show()

        -- Update signup button states based on validation
        self:UpdateSignupButtons(popup, event)

        -- Set up role button callbacks
        for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
            local btn = popup["btn_" .. roleKey]
            if btn then
                btn:SetScript("OnClick", function()
                    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                    local success, err = Calendar:SignUp(event.id, roleKey, "confirmed")
                    if success then
                        local statusMsg = btn.isFull and "standby" or C.CALENDAR_ROLES[roleKey].name
                        HopeAddon:Print("Signed up as " .. statusMsg .. "!")
                        self:ShowEventDetail(event)  -- Refresh
                    else
                        HopeAddon:Print("Failed to sign up: " .. (err or "Unknown error"))
                        self:ShowValidationErrors({ err })
                    end
                end)
            end
        end
    end

    popup:Show()
end

--============================================================
-- SERVER EVENT DETAIL POPUP
--============================================================

-- Singleton popup for server event details
local serverEventPopup = nil

--[[
    Get or create the server event detail popup
    @return Frame popup
]]
function CalendarUI:GetServerEventPopup()
    if serverEventPopup then return serverEventPopup end

    local popup = CreateFrame("Frame", "HopeCalendarServerEvent", UIParent, "BackdropTemplate")
    popup:SetSize(400, 280)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(100)

    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    popup:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold border for server events

    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Server Event badge
    popup.badge = popup:CreateFontString(nil, "OVERLAY")
    popup.badge:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.badge:SetPoint("TOP", popup, "TOP", 0, -12)
    popup.badge:SetText("|cFFFFD700★ SERVER EVENT ★|r")

    -- Title
    popup.title = popup:CreateFontString(nil, "OVERLAY")
    popup.title:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    popup.title:SetPoint("TOP", popup.badge, "BOTTOM", 0, -8)
    popup.title:SetTextColor(1, 0.84, 0)

    -- Date/Time
    popup.dateTime = popup:CreateFontString(nil, "OVERLAY")
    popup.dateTime:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    popup.dateTime:SetPoint("TOP", popup.title, "BOTTOM", 0, -10)
    popup.dateTime:SetTextColor(0.9, 0.9, 0.9)

    -- Divider
    local divider = popup:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:SetPoint("LEFT", popup, "LEFT", 20, 0)
    divider:SetPoint("RIGHT", popup, "RIGHT", -20, 0)
    divider:SetPoint("TOP", popup.dateTime, "BOTTOM", 0, -15)
    divider:SetVertexColor(1, 0.84, 0, 0.5)

    -- Description
    popup.description = popup:CreateFontString(nil, "OVERLAY")
    popup.description:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.description:SetPoint("TOP", divider, "BOTTOM", 0, -15)
    popup.description:SetPoint("LEFT", popup, "LEFT", 25, 0)
    popup.description:SetPoint("RIGHT", popup, "RIGHT", -25, 0)
    popup.description:SetJustifyH("CENTER")
    popup.description:SetTextColor(0.85, 0.85, 0.85)
    popup.description:SetWordWrap(true)

    -- Info text (no signups)
    popup.infoText = popup:CreateFontString(nil, "OVERLAY")
    popup.infoText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    popup.infoText:SetPoint("BOTTOM", popup, "BOTTOM", 0, 50)
    popup.infoText:SetText("|cFF888888This is a server-wide announcement. No signup required.|r")

    -- Close button at bottom
    local closeBottom = CreateFrame("Button", nil, popup, "BackdropTemplate")
    closeBottom:SetSize(80, 26)
    closeBottom:SetPoint("BOTTOM", popup, "BOTTOM", 0, 15)
    closeBottom:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    closeBottom:SetBackdropColor(0.2, 0.2, 0.2, 1)
    closeBottom:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    local closeText = closeBottom:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    closeText:SetPoint("CENTER")
    closeText:SetText("Close")
    closeText:SetTextColor(0.8, 0.8, 0.8)

    closeBottom:SetScript("OnClick", function()
        popup:Hide()
    end)
    closeBottom:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    closeBottom:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end)

    popup:Hide()
    serverEventPopup = popup
    return popup
end

--[[
    Show server event detail popup (read-only, no signups)
    @param event table - Server event data
]]
function CalendarUI:ShowServerEventDetail(event)
    if not event then return end

    local popup = self:GetServerEventPopup()

    -- Title
    popup.title:SetText(event.title or "Server Event")

    -- Date/Time - show dual time if different timezone
    local year, month, day = Calendar:ParseDate(event.date)
    if year then
        local dayName = date("%A", time({ year = year, month = month, day = day }))
        local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
        local timeStr = Calendar:FormatDualTime(event.startTime) or "All Day"
        popup.dateTime:SetText(dayName .. ", " .. monthName .. " " .. day .. " | " .. timeStr)
    else
        local timeStr = Calendar:FormatDualTime(event.startTime) or "All Day"
        popup.dateTime:SetText(event.date .. " | " .. timeStr)
    end

    -- Description
    if event.description and event.description ~= "" then
        popup.description:SetText(event.description)
    else
        popup.description:SetText("No additional details available.")
    end

    popup:Show()
end

--[[
    Show dialog to save event as template
    @param event table
]]
function CalendarUI:ShowSaveTemplateDialog(event)
    if not event then return end

    -- Create a simple input dialog if it doesn't exist
    if not self.saveTemplateDialog then
        local dialog = CreateFrame("Frame", "HopeCalendarSaveTemplate", UIParent, "BackdropTemplate")
        dialog:SetSize(300, 120)
        dialog:SetPoint("CENTER")
        dialog:SetFrameStrata("DIALOG")
        dialog:SetFrameLevel(150)

        dialog:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 20,
            insets = { left = 5, right = 5, top = 5, bottom = 5 },
        })
        dialog:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
        dialog:SetBackdropBorderColor(1, 0.84, 0, 1)

        dialog:EnableMouse(true)
        dialog:SetMovable(true)
        dialog:RegisterForDrag("LeftButton")
        dialog:SetScript("OnDragStart", dialog.StartMoving)
        dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

        -- Title
        dialog.title = dialog:CreateFontString(nil, "OVERLAY")
        dialog.title:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
        dialog.title:SetPoint("TOP", dialog, "TOP", 0, -15)
        dialog.title:SetText("Save as Template")
        dialog.title:SetTextColor(1, 0.84, 0)

        -- Label
        local label = dialog:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        label:SetPoint("TOPLEFT", dialog, "TOPLEFT", 20, -40)
        label:SetText("Template Name:")
        label:SetTextColor(0.8, 0.8, 0.8)

        -- Input
        dialog.input = CreateFrame("EditBox", nil, dialog, "BackdropTemplate")
        dialog.input:SetSize(260, 24)
        dialog.input:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        dialog.input:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        dialog.input:SetBackdropColor(0.1, 0.1, 0.1, 1)
        dialog.input:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        dialog.input:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        dialog.input:SetTextColor(0.9, 0.9, 0.9)
        dialog.input:SetTextInsets(8, 8, 0, 0)
        dialog.input:SetAutoFocus(false)
        dialog.input:SetMaxLetters(50)

        -- Cancel button
        dialog.cancelBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
        dialog.cancelBtn:SetSize(70, 24)
        dialog.cancelBtn:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 20, 12)
        dialog.cancelBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        dialog.cancelBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
        dialog.cancelBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local cancelText = dialog.cancelBtn:CreateFontString(nil, "OVERLAY")
        cancelText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        cancelText:SetPoint("CENTER")
        cancelText:SetText("Cancel")
        cancelText:SetTextColor(0.8, 0.8, 0.8)

        dialog.cancelBtn:SetScript("OnClick", function()
            dialog:Hide()
        end)

        -- Save button
        dialog.saveBtn = CreateFrame("Button", nil, dialog, "BackdropTemplate")
        dialog.saveBtn:SetSize(70, 24)
        dialog.saveBtn:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -20, 12)
        dialog.saveBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        dialog.saveBtn:SetBackdropColor(0.2, 0.3, 0.2, 1)
        dialog.saveBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)

        local saveText = dialog.saveBtn:CreateFontString(nil, "OVERLAY")
        saveText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        saveText:SetPoint("CENTER")
        saveText:SetText("Save")
        saveText:SetTextColor(0.6, 1, 0.6)

        dialog:Hide()
        self.saveTemplateDialog = dialog
    end

    -- Set up for this event
    local dialog = self.saveTemplateDialog
    dialog.input:SetText(event.title or "")
    dialog.currentEvent = event

    dialog.saveBtn:SetScript("OnClick", function()
        local name = dialog.input:GetText()
        if name and name ~= "" then
            local templateId, err = Calendar:SaveTemplate(event.id, name)
            if templateId then
                HopeAddon:Print("|cFF00FF00Template saved:|r " .. name)
                dialog:Hide()
            else
                HopeAddon:Print("|cFFFF0000Failed:|r " .. (err or "Unknown error"))
            end
        else
            HopeAddon:Print("|cFFFFFF00Enter a template name|r")
        end
    end)

    dialog:Show()
    dialog.input:SetFocus()
end

--[[
    Populate signup matrix UI (LOIHCal-inspired)
    Shows needs bar at top, role columns with confirmed/tentative, and standby section
    @param content Frame - Content frame
    @param event table
]]
function CalendarUI:PopulateSignupList(content, event)
    -- Clear existing content
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = 0
    local counts = Calendar:GetSignupCounts(event)
    local signupsByRole = Calendar:GetSignupsByRole(event)

    -- ============================================================
    -- NEEDS BAR - Shows unfilled slots with color coding
    -- ============================================================
    local needsBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    needsBar:SetSize(content:GetWidth() - 10, 24)
    needsBar:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    needsBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    needsBar:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    needsBar:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- Build needs text
    local needs = {}
    local allFilled = true
    for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local roleCount = counts[roleKey]
        local needed = roleCount.max - roleCount.current
        if needed > 0 then
            allFilled = false
            local roleData = C.CALENDAR_ROLES[roleKey]
            local color = roleData.color
            local colorHex = string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
            table.insert(needs, "|cFF" .. colorHex .. needed .. " " .. roleData.name .. "|r")
        end
    end

    local needsText = needsBar:CreateFontString(nil, "OVERLAY")
    needsText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    needsText:SetPoint("CENTER", needsBar, "CENTER", 0, 0)

    if allFilled then
        needsText:SetText("|cFF00FF00RAID READY - All slots filled!|r")
        needsBar:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
    else
        needsText:SetText("NEED: " .. table.concat(needs, " | "))
        needsBar:SetBackdropBorderColor(0.8, 0.5, 0.2, 1)
    end

    yOffset = yOffset + 30

    -- ============================================================
    -- ROLE COLUMNS HEADER
    -- ============================================================
    local columnWidth = 100
    local columnSpacing = 5
    local startX = 5

    -- Column headers
    for i, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local roleData = C.CALENDAR_ROLES[roleKey]
        local roleCount = counts[roleKey]
        local color = roleData.color

        local header = content:CreateFontString(nil, "OVERLAY")
        header:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", startX + (i - 1) * (columnWidth + columnSpacing), -yOffset)
        header:SetWidth(columnWidth)
        header:SetJustifyH("CENTER")
        header:SetText(roleData.name:upper() .. " (" .. roleCount.current .. "/" .. roleCount.max .. ")")
        header:SetTextColor(color.r, color.g, color.b)
    end

    yOffset = yOffset + 16

    -- ============================================================
    -- ROLE COLUMNS - Players with status icons
    -- ============================================================
    -- Find max rows needed across all columns
    local maxRows = 0
    for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local roleData = signupsByRole[roleKey]
        local totalInRole = #roleData.confirmed + #roleData.tentative
        local openSlots = math.max(0, counts[roleKey].max - totalInRole)
        maxRows = math.max(maxRows, totalInRole + openSlots)
    end

    -- Create rows for each column
    for row = 1, maxRows do
        for i, roleKey in ipairs({ "tank", "healer", "dps" }) do
            local roleData = signupsByRole[roleKey]
            local allSignups = {}

            -- Add confirmed first, then tentative
            for _, signup in ipairs(roleData.confirmed) do
                table.insert(allSignups, { signup = signup, status = "confirmed" })
            end
            for _, signup in ipairs(roleData.tentative) do
                table.insert(allSignups, { signup = signup, status = "tentative" })
            end

            local roleCount = counts[roleKey]
            local openSlots = math.max(0, roleCount.max - #allSignups)

            local cellText = content:CreateFontString(nil, "OVERLAY")
            cellText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
            cellText:SetPoint("TOPLEFT", content, "TOPLEFT", startX + (i - 1) * (columnWidth + columnSpacing), -(yOffset + (row - 1) * 14))
            cellText:SetWidth(columnWidth)
            cellText:SetJustifyH("LEFT")

            if row <= #allSignups then
                -- Player entry
                local entry = allSignups[row]
                local classColor = RAID_CLASS_COLORS[entry.signup.class] or { r = 0.8, g = 0.8, b = 0.8 }
                local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

                local statusIcon = ""
                if entry.status == "confirmed" then
                    statusIcon = "|cFF00FF00[Y]|r "  -- Green checkmark
                else
                    statusIcon = "|cFFFFAA00[~]|r "  -- Orange tentative
                end

                local nameStr = entry.signup.name or "Unknown"
                if #nameStr > 10 then
                    nameStr = nameStr:sub(1, 9) .. "."
                end

                cellText:SetText(statusIcon .. "|cFF" .. colorHex .. nameStr .. "|r")
            elseif row <= #allSignups + openSlots then
                -- Open slot
                cellText:SetText("|cFF666666[ ] Open|r")
            else
                cellText:SetText("")
            end
        end
    end

    yOffset = yOffset + maxRows * 14 + 8

    -- ============================================================
    -- STANDBY SECTION - Players who signed up after slots filled
    -- ============================================================
    local standby = Calendar:GetStandbySignups(event)
    if #standby > 0 then
        -- Divider
        local divider = content:CreateTexture(nil, "ARTWORK")
        divider:SetColorTexture(0.4, 0.4, 0.4, 0.5)
        divider:SetSize(content:GetWidth() - 20, 1)
        divider:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        yOffset = yOffset + 6

        -- Standby header
        local standbyHeader = content:CreateFontString(nil, "OVERLAY")
        standbyHeader:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        standbyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
        standbyHeader:SetText("STANDBY (" .. #standby .. ")")
        standbyHeader:SetTextColor(0.7, 0.7, 0.7)
        yOffset = yOffset + 16

        -- Standby list (compact horizontal)
        local standbyNames = {}
        for _, signup in ipairs(standby) do
            local classColor = RAID_CLASS_COLORS[signup.class] or { r = 0.8, g = 0.8, b = 0.8 }
            local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
            local roleData = C.CALENDAR_ROLES[signup.role or "dps"]
            local roleIcon = roleData and roleData.name:sub(1, 1) or "D"
            table.insert(standbyNames, "[" .. roleIcon .. "] |cFF" .. colorHex .. signup.name .. "|r")
        end

        local standbyText = content:CreateFontString(nil, "OVERLAY")
        standbyText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        standbyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        standbyText:SetWidth(content:GetWidth() - 20)
        standbyText:SetJustifyH("LEFT")
        standbyText:SetText(table.concat(standbyNames, ", "))
        yOffset = yOffset + 14 * math.ceil(#standby / 3)  -- Approximate height
    end

    content:SetHeight(math.max(yOffset + 10, 50))
end

--============================================================
-- CREATE EVENT POPUP
--============================================================

--[[
    Get or create the create event popup
    @return Frame popup
]]
function CalendarUI:GetCreateEventPopup()
    if createEventPopup then return createEventPopup end

    local UI = C.CALENDAR_UI
    local popup = CreateFrame("Frame", "HopeCalendarCreateEvent", UIParent, "BackdropTemplate")
    popup:SetSize(UI.CREATE_POPUP_WIDTH, UI.CREATE_POPUP_HEIGHT)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(100)

    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    popup:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
    popup:SetBackdropBorderColor(1, 0.84, 0, 1)

    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText("CREATE EVENT")
    title:SetTextColor(1, 0.84, 0)

    local yOffset = -45

    -- Template dropdown (at top for quick loading)
    local templateLabel = popup:CreateFontString(nil, "OVERLAY")
    templateLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    templateLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    templateLabel:SetText("Load Template:")
    templateLabel:SetTextColor(0.7, 0.9, 0.7)

    popup.templateDropdown = self:CreateSimpleDropdown(popup, { "-- None --" }, 1)
    popup.templateDropdown:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -4)
    popup.templateDropdown:SetSize(180, 26)
    popup.templateDropdown.isTemplateDropdown = true

    yOffset = yOffset - 55

    -- Event Type dropdown
    local typeLabel = popup:CreateFontString(nil, "OVERLAY")
    typeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    typeLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    typeLabel:SetText("Event Type:")
    typeLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.eventTypeDropdown = self:CreateSimpleDropdown(popup, { "Raid", "Dungeon", "RP Event", "Other" }, 1)
    popup.eventTypeDropdown:SetPoint("TOPLEFT", typeLabel, "BOTTOMLEFT", 0, -4)
    popup.eventTypeDropdown:SetSize(160, 26)

    yOffset = yOffset - 55

    -- Raid selector dropdown
    local raidLabel = popup:CreateFontString(nil, "OVERLAY")
    raidLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    raidLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    raidLabel:SetText("Raid/Dungeon:")
    raidLabel:SetTextColor(0.8, 0.8, 0.8)

    local raidOptions = {}
    for _, opt in ipairs(C.CALENDAR_RAID_OPTIONS) do
        table.insert(raidOptions, opt.name)
    end
    popup.raidDropdown = self:CreateSimpleDropdown(popup, raidOptions, 1)
    popup.raidDropdown:SetPoint("TOPLEFT", raidLabel, "BOTTOMLEFT", 0, -4)
    popup.raidDropdown:SetSize(200, 26)

    yOffset = yOffset - 55

    -- Title input
    local titleLabel = popup:CreateFontString(nil, "OVERLAY")
    titleLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    titleLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    titleLabel:SetText("Title (optional):")
    titleLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.titleInput = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
    popup.titleInput:SetSize(200, 24)
    popup.titleInput:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -4)
    popup.titleInput:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    popup.titleInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
    popup.titleInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    popup.titleInput:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.titleInput:SetTextColor(0.9, 0.9, 0.9)
    popup.titleInput:SetTextInsets(8, 8, 0, 0)
    popup.titleInput:SetAutoFocus(false)
    popup.titleInput:SetMaxLetters(50)

    yOffset = yOffset - 55

    -- Date selection
    local dateLabel = popup:CreateFontString(nil, "OVERLAY")
    dateLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    dateLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    dateLabel:SetText("Date:")
    dateLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Month dropdown
    popup.monthDropdown = self:CreateSimpleDropdown(popup, UI.MONTH_NAMES, currentMonth)
    popup.monthDropdown:SetPoint("TOPLEFT", dateLabel, "BOTTOMLEFT", 0, -4)
    popup.monthDropdown:SetSize(90, 26)

    -- Day dropdown
    local days = {}
    for i = 1, 31 do table.insert(days, tostring(i)) end
    popup.dayDropdown = self:CreateSimpleDropdown(popup, days, tonumber(date("%d")))
    popup.dayDropdown:SetPoint("LEFT", popup.monthDropdown, "RIGHT", 5, 0)
    popup.dayDropdown:SetSize(50, 26)

    -- Year dropdown (5 years: current + 4)
    local thisYear = tonumber(date("%Y"))
    local years = {}
    for i = 0, 4 do
        table.insert(years, tostring(thisYear + i))
    end
    popup.yearDropdown = self:CreateSimpleDropdown(popup, years, 1)
    popup.yearDropdown:SetPoint("LEFT", popup.dayDropdown, "RIGHT", 5, 0)
    popup.yearDropdown:SetSize(65, 26)

    yOffset = yOffset - 55

    -- Time selection
    local timeLabel = popup:CreateFontString(nil, "OVERLAY")
    timeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    timeLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    timeLabel:SetText("Time:")
    timeLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Hour dropdown
    local hours = {}
    for i = 1, 12 do table.insert(hours, tostring(i)) end
    popup.hourDropdown = self:CreateSimpleDropdown(popup, hours, 7)
    popup.hourDropdown:SetPoint("TOPLEFT", timeLabel, "BOTTOMLEFT", 0, -4)
    popup.hourDropdown:SetSize(50, 26)

    -- Minute dropdown
    popup.minuteDropdown = self:CreateSimpleDropdown(popup, { "00", "15", "30", "45" }, 1)
    popup.minuteDropdown:SetPoint("LEFT", popup.hourDropdown, "RIGHT", 2, 0)
    popup.minuteDropdown:SetSize(50, 26)

    -- AM/PM dropdown
    popup.ampmDropdown = self:CreateSimpleDropdown(popup, { "PM", "AM" }, 1)
    popup.ampmDropdown:SetPoint("LEFT", popup.minuteDropdown, "RIGHT", 5, 0)
    popup.ampmDropdown:SetSize(50, 26)

    yOffset = yOffset - 55

    -- Raid size
    local sizeLabel = popup:CreateFontString(nil, "OVERLAY")
    sizeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    sizeLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    sizeLabel:SetText("Raid Size:")
    sizeLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.sizeDropdown = self:CreateSimpleDropdown(popup, { "10-man", "25-man", "Custom" }, 1)
    popup.sizeDropdown:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -4)
    popup.sizeDropdown:SetSize(100, 26)

    yOffset = yOffset - 55

    -- Description
    local descLabel = popup:CreateFontString(nil, "OVERLAY")
    descLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    descLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    descLabel:SetText("Description (100 char max):")
    descLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.descInput = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
    popup.descInput:SetSize(UI.CREATE_POPUP_WIDTH - 40, 40)
    popup.descInput:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -4)
    popup.descInput:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    popup.descInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
    popup.descInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    popup.descInput:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.descInput:SetTextColor(0.9, 0.9, 0.9)
    popup.descInput:SetTextInsets(8, 8, 4, 4)
    popup.descInput:SetAutoFocus(false)
    popup.descInput:SetMaxLetters(100)
    popup.descInput:SetMultiLine(true)

    -- Buttons at bottom
    local cancelBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 20, 15)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    cancelBtn:SetBackdropColor(0.3, 0.2, 0.2, 1)
    cancelBtn:SetBackdropBorderColor(0.6, 0.4, 0.4, 1)

    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY")
    cancelText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    cancelText:SetPoint("CENTER")
    cancelText:SetText("Cancel")
    cancelText:SetTextColor(1, 0.6, 0.6)

    cancelBtn:SetScript("OnClick", function()
        popup:Hide()
    end)
    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.6, 0.4, 0.4, 1)
    end)

    local createBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    createBtn:SetSize(100, 28)
    createBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -20, 15)
    createBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    createBtn:SetBackdropColor(0.2, 0.35, 0.2, 1)
    createBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)

    local createText = createBtn:CreateFontString(nil, "OVERLAY")
    createText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    createText:SetPoint("CENTER")
    createText:SetText("Create Event")
    createText:SetTextColor(0.5, 1, 0.5)

    createBtn:SetScript("OnClick", function()
        self:HandleCreateEvent()
    end)
    createBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    createBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
    end)

    popup:Hide()
    createEventPopup = popup
    return popup
end

--[[
    Create a simple dropdown button
    @param parent Frame
    @param options table - Array of option strings
    @param defaultIndex number
    @return Button
]]
function CalendarUI:CreateSimpleDropdown(parent, options, defaultIndex)
    local dropdown = CreateFrame("Button", nil, parent, "BackdropTemplate")
    dropdown:SetSize(150, 26)

    dropdown:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    dropdown:SetBackdropColor(0.1, 0.1, 0.1, 1)
    dropdown:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY")
    dropdown.text:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    dropdown.text:SetPoint("LEFT", dropdown, "LEFT", 8, 0)
    dropdown.text:SetTextColor(0.9, 0.9, 0.9)

    local arrow = dropdown:CreateFontString(nil, "OVERLAY")
    arrow:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    arrow:SetPoint("RIGHT", dropdown, "RIGHT", -6, 0)
    arrow:SetText("v")
    arrow:SetTextColor(0.6, 0.6, 0.6)

    dropdown.options = options or {}
    dropdown.selectedIndex = defaultIndex or 1
    dropdown.text:SetText(dropdown.options[dropdown.selectedIndex] or "Select...")

    dropdown:SetScript("OnClick", function(self)
        self:ShowMenu()
    end)
    dropdown:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    dropdown:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)

    function dropdown:ShowMenu()
        -- Simple menu using a frame with buttons
        if self.menuFrame and self.menuFrame:IsShown() then
            self.menuFrame:Hide()
            return
        end

        if not self.menuFrame then
            self.menuFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
            self.menuFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            self.menuFrame:SetBackdropColor(0.08, 0.08, 0.08, 1)
            self.menuFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            self.menuFrame:SetFrameStrata("TOOLTIP")
        end

        -- Clear existing menu items
        for _, child in ipairs({ self.menuFrame:GetChildren() }) do
            child:Hide()
            child:SetParent(nil)
        end

        local menuHeight = #self.options * 20 + 6
        self.menuFrame:SetSize(self:GetWidth(), math.min(menuHeight, 200))
        self.menuFrame:SetPoint("TOP", self, "BOTTOM", 0, -2)

        for i, opt in ipairs(self.options) do
            local item = CreateFrame("Button", nil, self.menuFrame)
            item:SetSize(self:GetWidth() - 6, 18)
            item:SetPoint("TOPLEFT", self.menuFrame, "TOPLEFT", 3, -3 - (i - 1) * 20)

            local itemText = item:CreateFontString(nil, "OVERLAY")
            itemText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
            itemText:SetPoint("LEFT", item, "LEFT", 5, 0)
            itemText:SetText(opt)
            itemText:SetTextColor(0.8, 0.8, 0.8)

            item:SetScript("OnEnter", function()
                itemText:SetTextColor(1, 0.84, 0)
            end)
            item:SetScript("OnLeave", function()
                itemText:SetTextColor(0.8, 0.8, 0.8)
            end)
            item:SetScript("OnClick", function()
                self.selectedIndex = i
                self.text:SetText(opt)
                self.menuFrame:Hide()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                -- Call onSelect callback if defined
                if self.onSelect then
                    self.onSelect(i)
                end
            end)
        end

        self.menuFrame:Show()
    end

    function dropdown:GetValue()
        return self.selectedIndex, self.options[self.selectedIndex]
    end

    function dropdown:SetValue(index)
        self.selectedIndex = index
        self.text:SetText(self.options[index] or "")
    end

    return dropdown
end

--[[
    Show the create event popup
]]
function CalendarUI:ShowCreateEventPopup()
    local popup = self:GetCreateEventPopup()

    -- Populate template dropdown
    self:RefreshTemplateDropdown(popup)

    -- Reset fields to defaults
    popup.templateDropdown:SetValue(1)
    popup.eventTypeDropdown:SetValue(1)
    popup.raidDropdown:SetValue(1)
    popup.titleInput:SetText("")
    popup.monthDropdown:SetValue(currentMonth)
    popup.dayDropdown:SetValue(tonumber(date("%d")))
    popup.yearDropdown:SetValue(1)
    popup.hourDropdown:SetValue(7)
    popup.minuteDropdown:SetValue(1)
    popup.ampmDropdown:SetValue(1)
    popup.sizeDropdown:SetValue(1)
    popup.descInput:SetText("")

    popup:Show()
end

--[[
    Refresh the template dropdown with current templates
    @param popup Frame
]]
function CalendarUI:RefreshTemplateDropdown(popup)
    if not popup or not popup.templateDropdown then return end

    local templates = Calendar:GetTemplatesList()
    local options = { "-- None --" }
    local templateIds = { nil }  -- Store template IDs for lookup

    for _, template in ipairs(templates) do
        table.insert(options, template.name)
        table.insert(templateIds, template.id)
    end

    popup.templateDropdown.options = options
    popup.templateDropdown.templateIds = templateIds
    popup.templateDropdown.selectedIndex = 1
    popup.templateDropdown.text:SetText(options[1])

    -- Set up selection callback
    local originalShowMenu = popup.templateDropdown.ShowMenu
    popup.templateDropdown.ShowMenu = function(self)
        -- Refresh options before showing
        local freshTemplates = Calendar:GetTemplatesList()
        local freshOptions = { "-- None --" }
        local freshIds = { nil }
        for _, template in ipairs(freshTemplates) do
            table.insert(freshOptions, template.name)
            table.insert(freshIds, template.id)
        end
        self.options = freshOptions
        self.templateIds = freshIds
        originalShowMenu(self)
    end

    -- Handle template selection to auto-fill form
    popup.templateDropdown.onSelect = function(index)
        if index <= 1 then return end  -- "None" selected

        local templateId = popup.templateDropdown.templateIds[index]
        if templateId then
            CalendarUI:ApplyTemplate(popup, templateId)
        end
    end
end

--[[
    Apply a template to the create event form
    @param popup Frame
    @param templateId string
]]
function CalendarUI:ApplyTemplate(popup, templateId)
    local template = Calendar:LoadTemplate(templateId)
    if not template then return end

    -- Event type
    local eventTypes = { "RAID", "DUNGEON", "RP_EVENT", "OTHER" }
    for i, evtType in ipairs(eventTypes) do
        if evtType == template.eventType then
            popup.eventTypeDropdown:SetValue(i)
            break
        end
    end

    -- Raid/dungeon selection
    for i, opt in ipairs(C.CALENDAR_RAID_OPTIONS) do
        if opt.key == template.raidKey then
            popup.raidDropdown:SetValue(i)
            break
        end
    end

    -- Description
    if template.description then
        popup.descInput:SetText(template.description)
    end

    -- Default time
    if template.defaultTime then
        local hour, minute = template.defaultTime:match("^(%d+):(%d+)$")
        hour = tonumber(hour) or 19
        minute = tonumber(minute) or 0

        local ampm = 1  -- PM
        if hour < 12 then
            ampm = 2  -- AM
            if hour == 0 then hour = 12 end
        elseif hour > 12 then
            hour = hour - 12
        end

        popup.hourDropdown:SetValue(hour)
        popup.ampmDropdown:SetValue(ampm)

        local minuteOptions = { 0, 15, 30, 45 }
        for i, m in ipairs(minuteOptions) do
            if minute == m then
                popup.minuteDropdown:SetValue(i)
                break
            end
        end
    end

    -- Raid size
    if template.raidSize then
        if template.raidSize == 10 then
            popup.sizeDropdown:SetValue(1)
        elseif template.raidSize == 25 then
            popup.sizeDropdown:SetValue(2)
        else
            popup.sizeDropdown:SetValue(3)  -- Custom
        end
    end

    HopeAddon:Print("Template loaded: " .. (template.name or "Unknown"))
end

--[[
    Handle create event button click
]]
function CalendarUI:HandleCreateEvent()
    local popup = createEventPopup
    if not popup then return end

    -- Gather form data
    local eventTypeIndex = popup.eventTypeDropdown:GetValue()
    local eventTypes = { "RAID", "DUNGEON", "RP_EVENT", "OTHER" }
    local eventType = eventTypes[eventTypeIndex] or "RAID"

    local raidIndex = popup.raidDropdown:GetValue()
    local raidOption = C.CALENDAR_RAID_OPTIONS[raidIndex]

    local title = popup.titleInput:GetText()
    if title == "" then
        title = raidOption and raidOption.name or "Event"
    end

    local monthIndex = popup.monthDropdown:GetValue()
    local dayIndex = popup.dayDropdown:GetValue()
    local yearIndex, yearStr = popup.yearDropdown:GetValue()
    local year = tonumber(yearStr)

    local dateStr = string.format("%04d-%02d-%02d", year, monthIndex, dayIndex)

    local hourIndex = popup.hourDropdown:GetValue()
    local minuteIndex = popup.minuteDropdown:GetValue()
    local ampmIndex = popup.ampmDropdown:GetValue()
    local minutes = { "00", "15", "30", "45" }

    local hour = hourIndex
    if ampmIndex == 1 then  -- PM
        if hour < 12 then hour = hour + 12 end
    else  -- AM
        if hour == 12 then hour = 0 end
    end

    local startTime = string.format("%02d:%s", hour, minutes[minuteIndex])

    local sizeIndex = popup.sizeDropdown:GetValue()
    local sizePreset = C.CALENDAR_RAID_SIZES[sizeIndex]

    local raidSize = sizePreset and sizePreset.maxPlayers or 10
    local maxTanks = sizePreset and sizePreset.defaultTanks or 2
    local maxHealers = sizePreset and sizePreset.defaultHealers or 3
    local maxDPS = sizePreset and sizePreset.defaultDPS or 5

    -- If raid option specifies size, use it
    if raidOption and raidOption.size then
        raidSize = raidOption.size
        if raidOption.size == 10 then
            maxTanks, maxHealers, maxDPS = 2, 3, 5
        elseif raidOption.size == 25 then
            maxTanks, maxHealers, maxDPS = 3, 7, 15
        elseif raidOption.size == 5 then
            maxTanks, maxHealers, maxDPS = 1, 1, 3
        end
    end

    local description = popup.descInput:GetText()

    -- Create the event
    local eventId, err = Calendar:CreateEvent({
        title = title,
        eventType = eventType,
        raidKey = raidOption and raidOption.key,
        date = dateStr,
        startTime = startTime,
        raidSize = raidSize,
        maxTanks = maxTanks,
        maxHealers = maxHealers,
        maxDPS = maxDPS,
        description = description,
    })

    if eventId then
        HopeAddon:Print("|cFF00FF00Event created:|r " .. title)
        popup:Hide()

        -- Refresh calendar if viewing the same month
        if monthGrid then
            self:PopulateMonthGrid(monthGrid)
        end

        -- Select the event's date
        self:SelectDate(dateStr)
    else
        HopeAddon:Print("|cFFFF0000Failed to create event:|r " .. (err or "Unknown error"))
    end
end

--============================================================
-- VALIDATION FEEDBACK
--============================================================

--[[
    Show validation errors in chat
    @param errors table - Array of error strings
]]
function CalendarUI:ShowValidationErrors(errors)
    if not errors or #errors == 0 then return end

    for _, err in ipairs(errors) do
        HopeAddon:Print("|cFFFF6666[Calendar]|r " .. err)
    end
end

--[[
    Update signup buttons based on validation state
    Shows which roles are full and adjusts button appearance
    @param popup Frame - The event detail popup
    @param event table - The event data
]]
function CalendarUI:UpdateSignupButtons(popup, event)
    if not popup or not event then return end

    local CalendarValidation = HopeAddon.CalendarValidation
    local playerName = UnitName("player")

    for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local btn = popup["btn_" .. roleKey]
        if btn then
            local isFull = Calendar:IsRoleFull(event, roleKey)
            local roleData = C.CALENDAR_ROLES[roleKey]

            if isFull then
                -- Show as standby option
                btn:SetAlpha(0.6)
                if btn.text then
                    btn.text:SetText(roleData.name .. "\n(Standby)")
                    btn.text:SetTextColor(0.7, 0.7, 0.7)
                end
                btn.isFull = true
            else
                -- Normal state
                btn:SetAlpha(1.0)
                if btn.text then
                    btn.text:SetText(roleData.name)
                    local color = roleData.color
                    btn.text:SetTextColor(color.r, color.g, color.b)
                end
                btn.isFull = false
            end

            -- Run validation to check for other issues
            if CalendarValidation then
                local isValid, errors, _ = CalendarValidation:ValidateSignup(event.id, playerName, roleKey)
                if not isValid then
                    -- Disable button entirely if there's a blocking error
                    btn:SetAlpha(0.3)
                    if btn.text then
                        btn.text:SetTextColor(0.5, 0.5, 0.5)
                    end
                    btn:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Cannot Sign Up", 1, 0.3, 0.3)
                        for _, err in ipairs(errors) do
                            GameTooltip:AddLine(err, 0.8, 0.8, 0.8, true)
                        end
                        GameTooltip:Show()
                    end)
                    btn:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                else
                    -- Clear any error tooltips
                    btn:SetScript("OnEnter", nil)
                    btn:SetScript("OnLeave", nil)
                end
            end
        end
    end
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Get current view month/year
    @return number year, number month
]]
function CalendarUI:GetCurrentView()
    return currentYear, currentMonth
end

--[[
    Refresh the calendar display
]]
function CalendarUI:Refresh()
    if monthGrid then
        self:PopulateMonthGrid(monthGrid)
    end
end

-- Make module accessible and register
HopeAddon.CalendarUI = CalendarUI
HopeAddon:RegisterModule("CalendarUI", CalendarUI)

return CalendarUI
