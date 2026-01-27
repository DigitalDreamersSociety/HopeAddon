--[[
    HopeAddon Calendar UI Module
    UI components for the raid calendar system
]]

local CalendarUI = {}
HopeAddon:RegisterModule("CalendarUI", CalendarUI)

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

-- Frame pools
local dayCellPool = nil
local eventCardPool = nil

-- UI State
local monthGrid = nil
local selectedDayPanel = nil
local currentYear = nil
local currentMonth = nil
local eventDetailPopup = nil
local createEventPopup = nil

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

    -- Destroy pools
    if dayCellPool then dayCellPool:Destroy() end
    if eventCardPool then eventCardPool:Destroy() end

    -- Hide popups
    if eventDetailPopup then eventDetailPopup:Hide() end
    if createEventPopup then createEventPopup:Hide() end

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
        cell.eventDots:SetText("")
        cell.isToday = false
        cell.dateStr = nil
        cell:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
    end)

    -- Event card pool
    eventCardPool = FramePool:New(function()
        return self:CreateEventCardFrame()
    end, function(card)
        card:Hide()
        card:ClearAllPoints()
        card.eventId = nil
    end)
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

    -- Event dots (bottom, centered)
    cell.eventDots = cell:CreateFontString(nil, "OVERLAY")
    cell.eventDots:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    cell.eventDots:SetPoint("BOTTOM", cell, "BOTTOM", 0, 3)
    cell.eventDots:SetTextColor(1, 0.84, 0)

    -- Hover effect
    cell:SetScript("OnEnter", function(self)
        if self.dateStr then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end
    end)
    cell:SetScript("OnLeave", function(self)
        if self.isToday then
            self:SetBackdropBorderColor(1, 0.84, 0, 0.8)
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        end
    end)

    return cell
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

    -- Raid icon
    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(32, 32)
    card.icon:SetPoint("LEFT", card, "LEFT", 8, 0)

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

                -- Show event indicators
                local eventCount = eventsForMonth[dateStr]
                if eventCount and eventCount > 0 then
                    local dots = ""
                    for i = 1, math.min(eventCount, 3) do
                        dots = dots .. string.char(226, 128, 162) -- bullet •
                    end
                    if eventCount > 3 then
                        dots = dots .. "+"
                    end
                    cell.eventDots:SetText(dots)
                else
                    cell.eventDots:SetText("")
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
                cell.eventDots:SetText("")
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
    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    panel.scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -30)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)

    panel.scrollChild = CreateFrame("Frame", nil, panel.scrollFrame)
    panel.scrollChild:SetSize(panel.scrollFrame:GetWidth(), 1)
    panel.scrollFrame:SetScrollChild(panel.scrollChild)

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

    -- Icon based on event type
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    card.icon:SetTexture("Interface\\Icons\\" .. eventType.icon)

    -- Title
    card.title:SetText(event.title or "Event")

    -- Subtitle (time and leader)
    local subtitle = event.startTime or "TBD"
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

    -- Title
    popup.title:SetText(event.title or "Event")

    -- Date/Time
    local year, month, day = Calendar:ParseDate(event.date)
    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    popup.dateTime:SetText(dayName .. ", " .. monthName .. " " .. day .. " at " .. (event.startTime or "TBD"))

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

        -- Set up role button callbacks
        for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
            local btn = popup["btn_" .. roleKey]
            if btn then
                btn:SetScript("OnClick", function()
                    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                    local success, err = Calendar:SignUp(event.id, roleKey, "confirmed")
                    if success then
                        HopeAddon:Print("Signed up as " .. C.CALENDAR_ROLES[roleKey].name .. "!")
                        self:ShowEventDetail(event)  -- Refresh
                    else
                        HopeAddon:Print("Failed to sign up: " .. (err or "Unknown error"))
                    end
                end)
            end
        end
    end

    popup:Show()
end

--[[
    Populate signup list grouped by role
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

    -- Group signups by role
    local byRole = { tank = {}, healer = {}, dps = {} }
    for playerName, signup in pairs(event.signups or {}) do
        if signup.status ~= "declined" then
            local role = signup.role or "dps"
            if byRole[role] then
                table.insert(byRole[role], { name = playerName, data = signup })
            end
        end
    end

    -- Display each role section
    for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local roleData = C.CALENDAR_ROLES[roleKey]
        local roleCount = counts[roleKey]

        -- Role header
        local header = content:CreateFontString(nil, "OVERLAY")
        header:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
        header:SetText(roleData.name .. " (" .. roleCount.current .. "/" .. roleCount.max .. ")")
        local color = HopeAddon.colors[roleData.color]
        header:SetTextColor(color.r, color.g, color.b)
        yOffset = yOffset + 18

        -- Players in this role
        if #byRole[roleKey] > 0 then
            for _, entry in ipairs(byRole[roleKey]) do
                local row = content:CreateFontString(nil, "OVERLAY")
                row:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -yOffset)

                local classColor = RAID_CLASS_COLORS[entry.data.class] or { r = 0.8, g = 0.8, b = 0.8 }
                local statusIcon = C.CALENDAR_SIGNUP_STATUS[entry.data.status]
                local icon = statusIcon and statusIcon.icon or "?"

                row:SetText(icon .. " |cFF" .. string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. entry.name .. "|r")
                yOffset = yOffset + 14
            end
        end

        -- Open slots
        local openSlots = roleCount.max - roleCount.current
        for i = 1, openSlots do
            local slot = content:CreateFontString(nil, "OVERLAY")
            slot:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
            slot:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -yOffset)
            slot:SetText("[ ] Open slot")
            slot:SetTextColor(0.4, 0.4, 0.4)
            yOffset = yOffset + 14
        end

        yOffset = yOffset + 8  -- Spacing between roles
    end

    content:SetHeight(math.max(yOffset, 50))
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

    -- Reset fields to defaults
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

-- Make module accessible
HopeAddon.CalendarUI = CalendarUI

return CalendarUI
