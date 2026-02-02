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
local weekCalendar = nil
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

-- Confirmation dialog for event deletion
StaticPopupDialogs["HOPE_CONFIRM_DELETE_EVENT"] = {
    text = "Delete event \"%s\"?\n\nThis cannot be undone.",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, data)
        local success = Calendar:DeleteEvent(data.eventId)
        if success then
            HopeAddon:Print("|cFFFF4444Event deleted|r")
            data.popup:Hide()
            CalendarUI:Refresh()
        else
            HopeAddon:Print("|cFFFF0000Failed to delete event|r")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

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
        "HopeCalendarDayEvents",
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

--[[
    Clear all content from a container (children + regions)
    Used to prevent overlapping text when populating popup content
    @param content Frame - The container to clear
]]
function CalendarUI:ClearContentContainer(content)
    -- Clear child frames
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    -- Clear font strings and textures (regions)
    for _, region in ipairs({ content:GetRegions() }) do
        region:Hide()
        -- Note: SetParent doesn't work on regions, but Hide() is sufficient
    end
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
        cell:SetParent(nil)
        cell.dayNumber:SetText("")
        -- Clear mini-cards
        CalendarUI:ClearMiniCards(cell)
        -- Clear server event theming
        CalendarUI:ClearServerEventTheme(cell)
        -- Reset dynamic height
        cell.calculatedHeight = C.CALENDAR_UI.CELL_HEIGHT
        cell:SetHeight(C.CALENDAR_UI.CELL_HEIGHT)
        cell.isToday = false
        cell.dateStr = nil
        cell:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        -- Clear scripts to release closures
        cell:SetScript("OnEnter", nil)
        cell:SetScript("OnLeave", nil)
        cell:SetScript("OnClick", nil)
    end)
    -- Store as module field for reliable OnDisable access
    self.dayCellPool = dayCellPool

    -- Event card pool
    eventCardPool = FramePool:New(function()
        return self:CreateEventCardFrame()
    end, function(card)
        card:Hide()
        card:ClearAllPoints()
        card:SetParent(nil)

        -- Clear data references
        card.eventId = nil
        card.eventData = nil

        -- Clear text fields
        if card.titleText then card.titleText:SetText("") end
        if card.timeText then card.timeText:SetText("") end

        -- Reset color stripe to default
        if card.colorStripe then
            card.colorStripe:SetColorTexture(0.6, 0.6, 0.6, 1)
        end
        -- Reset border color to default
        card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

        -- Clear scripts to release closures
        card:SetScript("OnEnter", nil)
        card:SetScript("OnLeave", nil)
        card:SetScript("OnClick", nil)

        -- Clear tooltip data
        card.tooltipData = nil

        -- Ensure view button is shown (will be hidden for server events)
        if card.viewBtn then
            card.viewBtn:Show()
            card.viewBtn:SetScript("OnClick", nil)
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

    -- Server event themed background (subtle overlay for special days)
    cell.eventBackground = cell:CreateTexture(nil, "BACKGROUND", nil, 1)
    cell.eventBackground:SetPoint("TOPLEFT", cell, "TOPLEFT", 2, -2)
    cell.eventBackground:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -2, 2)
    cell.eventBackground:SetAlpha(0.25)
    cell.eventBackground:Hide()

    -- Server event indicator icon (small corner badge)
    cell.serverEventIcon = cell:CreateTexture(nil, "OVERLAY", nil, 2)
    cell.serverEventIcon:SetSize(14, 14)
    cell.serverEventIcon:SetPoint("TOPRIGHT", cell, "TOPRIGHT", -3, -3)
    cell.serverEventIcon:Hide()

    -- Day number (top-left)
    cell.dayNumber = cell:CreateFontString(nil, "OVERLAY")
    cell.dayNumber:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    cell.dayNumber:SetPoint("TOPLEFT", cell, "TOPLEFT", 4, -3)
    cell.dayNumber:SetTextColor(0.8, 0.8, 0.8)

    -- Initialize mini-cards array (created on demand in PopulateMiniCards)
    cell.miniCards = {}

    -- Overflow indicator (shows "+N more" when events exceed max visible)
    -- Created on demand in PopulateMiniCards

    -- Dynamic height tracking
    cell.calculatedHeight = C.CALENDAR_UI.CELL_HEIGHT

    -- Hover effect (simplified - no day tooltip since mini-cards show event info)
    cell:SetScript("OnEnter", function(self)
        if self.dateStr then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end
    end)
    cell:SetScript("OnLeave", function(self)
        if self.isToday then
            self:SetBackdropBorderColor(1, 0.84, 0, 0.8)
        elseif self.hasServerEvent then
            -- Keep themed border for server event days
            local color = self.serverEventColor or { r = 1, g = 0.84, b = 0 }
            self:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        end
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

--============================================================
-- MINI EVENT CARDS (Calendar Day Cell Display)
--============================================================

--[[
    Create a mini event card for calendar day cells
    60×14px horizontal card with color stripe, icon, time, and truncated title
    @param parent Frame - Parent frame to attach card to
    @return Button card - The mini card frame
]]
function CalendarUI:CreateMiniEventCard(parent)
    local MC = C.CALENDAR_MINI_CARD
    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(MC.WIDTH, MC.HEIGHT)

    card:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    card:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    card:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- Left color stripe (event type indicator)
    card.colorStripe = card:CreateTexture(nil, "ARTWORK")
    card.colorStripe:SetSize(MC.STRIPE_WIDTH, MC.HEIGHT)
    card.colorStripe:SetPoint("LEFT", card, "LEFT", 0, 0)
    card.colorStripe:SetColorTexture(0.6, 0.6, 0.6, 1)

    -- Event type icon
    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(MC.ICON_SIZE, MC.ICON_SIZE)
    card.icon:SetPoint("LEFT", card.colorStripe, "RIGHT", 2, 0)

    -- Time text (abbreviated, e.g., "7:30p")
    card.timeText = card:CreateFontString(nil, "OVERLAY")
    card.timeText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    card.timeText:SetPoint("LEFT", card.icon, "RIGHT", 2, 0)
    card.timeText:SetWidth(MC.TIME_WIDTH)
    card.timeText:SetJustifyH("LEFT")
    card.timeText:SetTextColor(0.7, 0.7, 0.7)

    -- Title text (truncated)
    card.titleText = card:CreateFontString(nil, "OVERLAY")
    card.titleText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    card.titleText:SetPoint("LEFT", card.timeText, "RIGHT", 1, 0)
    card.titleText:SetPoint("RIGHT", card, "RIGHT", -2, 0)
    card.titleText:SetJustifyH("LEFT")
    card.titleText:SetTextColor(0.9, 0.9, 0.9)
    card.titleText:SetWordWrap(false)

    -- Multi-day span indicators
    card.leftBar = card:CreateTexture(nil, "ARTWORK", nil, 1)
    card.leftBar:SetSize(3, MC.HEIGHT)
    card.leftBar:SetPoint("RIGHT", card, "LEFT", 1, 0)
    card.leftBar:Hide()

    card.rightBar = card:CreateTexture(nil, "ARTWORK", nil, 1)
    card.rightBar:SetSize(3, MC.HEIGHT)
    card.rightBar:SetPoint("LEFT", card, "RIGHT", -1, 0)
    card.rightBar:Hide()

    -- Hover effect
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
        -- Show tooltip with full event info
        if self.event then
            CalendarUI:ShowMiniCardTooltip(self, self.event)
        end
    end)
    card:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)
        GameTooltip:Hide()
    end)

    -- Click opens unified day popup with this event selected
    card:SetScript("OnClick", function(self)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        if self.event then
            CalendarUI:ShowUnifiedDayPopup(self.event.date, self.event.id)
        end
    end)

    card:Hide()
    return card
end

--[[
    Show tooltip for mini event card
    @param card Frame - The mini card frame
    @param event table - Event data
]]
function CalendarUI:ShowMiniCardTooltip(card, event)
    GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    -- Title with event type color
    local color = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER
    GameTooltip:AddLine(event.title or "Event", color.r, color.g, color.b)

    -- Event type
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    GameTooltip:AddLine(eventType.name, 0.7, 0.7, 0.7)

    -- Time (with local time conversion)
    if event.startTime then
        local timeStr = Calendar:FormatDualTime(event.startTime)
        if event.endTime then
            local endTimeStr = Calendar:FormatDualTime(event.endTime)
            -- If dual time format, extract just the first part for range display
            if timeStr:find(" R /") then
                local startRealm = timeStr:match("^(%d+:%d+) R")
                local startLocal = timeStr:match("/ (%d+:%d+) L$")
                local endRealm = endTimeStr:match("^(%d+:%d+) R")
                local endLocal = endTimeStr:match("/ (%d+:%d+) L$")
                if startRealm and endRealm then
                    GameTooltip:AddLine(startRealm .. " - " .. endRealm .. " (Realm)", 1, 1, 1)
                    if startLocal and endLocal then
                        GameTooltip:AddLine(startLocal .. " - " .. endLocal .. " (Local)", 0.6, 0.8, 0.6)
                    end
                else
                    GameTooltip:AddLine(timeStr, 1, 1, 1)
                end
            else
                -- Same timezone, just show simple range
                GameTooltip:AddLine(event.startTime .. " - " .. event.endTime, 1, 1, 1)
            end
        else
            GameTooltip:AddLine(timeStr, 1, 1, 1)
        end
    end

    -- Leader (for guild events)
    if event.leader then
        GameTooltip:AddLine("Leader: " .. event.leader, 0.6, 0.8, 1)
    end

    -- Looking For roles (for guild events)
    if event.maxTanks or event.maxHealers or event.maxDPS then
        local lfParts = {}
        if (event.maxTanks or 0) > 0 then table.insert(lfParts, event.maxTanks .. " Tank") end
        if (event.maxHealers or 0) > 0 then table.insert(lfParts, event.maxHealers .. " Healer") end
        if (event.maxDPS or 0) > 0 then table.insert(lfParts, event.maxDPS .. " DPS") end
        if #lfParts > 0 then
            GameTooltip:AddLine("LF: " .. table.concat(lfParts, ", "), 0.6, 0.8, 0.6)
        end
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click to view details", 0.5, 0.5, 0.5)

    GameTooltip:Show()
end

--[[
    Format time for mini-card display (abbreviated)
    @param timeStr string - Time in "HH:MM" format
    @return string - Abbreviated time like "7:30p" or "All"
]]
function CalendarUI:FormatMiniCardTime(timeStr)
    if not timeStr or timeStr == "" or timeStr == "All Day" then
        return "All"
    end

    local hour, min = timeStr:match("(%d+):(%d+)")
    if not hour then return timeStr:sub(1, 5) end

    hour = tonumber(hour)
    local suffix = "a"
    if hour >= 12 then
        suffix = "p"
        if hour > 12 then hour = hour - 12 end
    elseif hour == 0 then
        hour = 12
    end

    if min == "00" then
        return hour .. suffix
    else
        return hour .. ":" .. min:sub(1, 2) .. suffix
    end
end

--[[
    Check if an event is imminent (within 24 hours of reference date)
    @param event table - Event data
    @param referenceDate string - YYYY-MM-DD date to compare against
    @return boolean - True if event is imminent
]]
function CalendarUI:IsEventImminent(event, referenceDate)
    if not event.date or not referenceDate then return false end
    -- Event on same date is considered imminent
    return event.date == referenceDate
end

--[[
    Sort events by priority for display
    Priority: Imminent > Event Type > Start Time
    @param events table - Array of events
    @param referenceDate string - YYYY-MM-DD for imminence check
    @return table - Sorted events array
]]
function CalendarUI:SortEventsByPriority(events, referenceDate)
    if not events or #events == 0 then return events end

    -- Create a copy to avoid modifying original
    local sorted = {}
    for i, evt in ipairs(events) do
        sorted[i] = evt
    end

    table.sort(sorted, function(a, b)
        -- Imminent events first
        local aImminent = self:IsEventImminent(a, referenceDate)
        local bImminent = self:IsEventImminent(b, referenceDate)
        if aImminent ~= bImminent then return aImminent end

        -- Then by event type priority
        local aPriority = C.CALENDAR_EVENT_PRIORITY[a.eventType] or 99
        local bPriority = C.CALENDAR_EVENT_PRIORITY[b.eventType] or 99
        if aPriority ~= bPriority then return aPriority < bPriority end

        -- Finally by start time
        return (a.startTime or "") < (b.startTime or "")
    end)

    return sorted
end

--[[
    Calculate cell height based on number of events
    @param eventCount number - Number of events to display
    @return number - Cell height in pixels
]]
function CalendarUI:CalculateCellHeight(eventCount)
    local MC = C.CALENDAR_MINI_CARD
    local visibleEvents = math.min(eventCount, MC.MAX_VISIBLE)
    local cardHeight = MC.HEIGHT + MC.SPACING
    local height = MC.BASE_CELL_HEIGHT + (visibleEvents * cardHeight)
    return math.min(height, MC.MAX_CELL_HEIGHT)
end

--[[
    Populate mini-cards in a day cell
    @param cell Frame - The day cell frame
    @param events table - Array of events for this day
    @param dateStr string - YYYY-MM-DD date string
]]
function CalendarUI:PopulateMiniCards(cell, events, dateStr)
    local MC = C.CALENDAR_MINI_CARD

    -- Clear existing mini-cards
    if cell.miniCards then
        for _, card in ipairs(cell.miniCards) do
            card:Hide()
            card:ClearAllPoints()
        end
    end
    cell.miniCards = cell.miniCards or {}

    -- Hide overflow text
    if cell.overflowText then
        cell.overflowText:Hide()
    end

    if not events or #events == 0 then
        cell.calculatedHeight = C.CALENDAR_UI.CELL_HEIGHT  -- Default height
        return
    end

    -- Sort events by priority
    local sortedEvents = self:SortEventsByPriority(events, dateStr)

    -- Calculate required height
    cell.calculatedHeight = self:CalculateCellHeight(#sortedEvents)

    -- Create/reuse mini-cards for each event (up to max visible)
    local visibleCount = math.min(#sortedEvents, MC.MAX_VISIBLE)
    local yOffset = -18  -- Start below day number

    for i = 1, visibleCount do
        local evt = sortedEvents[i]

        -- Get or create card
        local card = cell.miniCards[i]
        if not card then
            card = self:CreateMiniEventCard(cell)
            cell.miniCards[i] = card
        end

        -- Configure card
        self:ConfigureMiniCard(card, evt)

        -- Position card
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", cell, "TOPLEFT", 4, yOffset)
        card:Show()

        yOffset = yOffset - (MC.HEIGHT + MC.SPACING)
    end

    -- Show overflow indicator if needed
    if #sortedEvents > MC.MAX_VISIBLE then
        local overflow = #sortedEvents - MC.MAX_VISIBLE
        if not cell.overflowText then
            cell.overflowText = cell:CreateFontString(nil, "OVERLAY")
            cell.overflowText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
            cell.overflowText:SetTextColor(0.6, 0.8, 1)
        end
        cell.overflowText:SetText("+" .. overflow .. " more")
        cell.overflowText:ClearAllPoints()
        cell.overflowText:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 4, 2)
        cell.overflowText:Show()
    end
end

--[[
    Configure a mini-card with event data
    @param card Frame - The mini card frame
    @param event table - Event data
]]
function CalendarUI:ConfigureMiniCard(card, event)
    local MC = C.CALENDAR_MINI_CARD

    -- Store event reference for click/tooltip
    card.event = event

    -- Set color stripe based on event type or custom color
    local color = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER

    -- Check for custom event color override
    if event.eventColor then
        for _, preset in ipairs(C.CALENDAR_EVENT_COLOR_PRESETS) do
            if preset.key == event.eventColor and preset.color then
                color = preset.color
                break
            end
        end
    end

    card.colorStripe:SetColorTexture(color.r, color.g, color.b, 1)

    -- Set icon
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    card.icon:SetTexture(eventType.icon)
    card.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- Trim icon borders

    -- Set time (abbreviated)
    local timeStr = self:FormatMiniCardTime(event.startTime)
    -- Add lock indicator if event is locked
    if event.locked then
        timeStr = "|cFFFF4444*|r" .. timeStr
    end
    card.timeText:SetText(timeStr)

    -- Set title (will auto-truncate due to width constraints)
    card.titleText:SetText(event.title or "Event")

    -- Multi-day span indicators
    local span = event.spanPosition or "single"
    if span == "start" or span == "middle" then
        card.rightBar:SetColorTexture(color.r, color.g, color.b, 0.7)
        card.rightBar:Show()
    else
        card.rightBar:Hide()
    end
    if span == "end" or span == "middle" then
        card.leftBar:SetColorTexture(color.r, color.g, color.b, 0.7)
        card.leftBar:Show()
    else
        card.leftBar:Hide()
    end
end

--[[
    Clear all mini-cards from a cell
    @param cell Frame - The day cell frame
]]
function CalendarUI:ClearMiniCards(cell)
    if cell.miniCards then
        for _, card in ipairs(cell.miniCards) do
            card:Hide()
            card.event = nil
        end
    end
    if cell.overflowText then
        cell.overflowText:Hide()
    end
    cell.calculatedHeight = nil
end

--[[
    Apply themed background styling for server events
    Server events (Dark Portal opening, maintenance, etc.) get special themed backgrounds
    to make them visually distinct from regular user-created events.
    @param cell Frame - The day cell frame
    @param serverEvent table - Full server event object from Constants.lua
]]
function CalendarUI:ApplyServerEventTheme(cell, serverEvent)
    if not cell or not serverEvent then return end

    -- Default theme color (gold/legendary) if not specified
    local themeColor = serverEvent.themeColor or { r = 1, g = 0.84, b = 0 }

    -- Apply background texture or tinted color overlay
    if cell.eventBackground then
        if serverEvent.backgroundTexture then
            cell.eventBackground:SetTexture(serverEvent.backgroundTexture)
            cell.eventBackground:SetTexCoord(0, 1, 0, 1)
        else
            -- Fallback: use a subtle color tint
            cell.eventBackground:SetColorTexture(themeColor.r, themeColor.g, themeColor.b, 1)
        end
        cell.eventBackground:SetAlpha(0.2)
        cell.eventBackground:Show()
    end

    -- Show server event icon in corner
    if cell.serverEventIcon then
        if serverEvent.icon then
            cell.serverEventIcon:SetTexture(serverEvent.icon)
            cell.serverEventIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            cell.serverEventIcon:Show()
        else
            cell.serverEventIcon:Hide()
        end
    end

    -- Apply themed border color
    cell:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.6)

    -- Store state for hover/leave handling
    cell.hasServerEvent = true
    cell.serverEventColor = themeColor
    cell.serverEventData = serverEvent
end

--[[
    Clear server event theming from a cell
    @param cell Frame - The day cell frame
]]
function CalendarUI:ClearServerEventTheme(cell)
    if not cell then return end

    if cell.eventBackground then
        cell.eventBackground:Hide()
    end
    if cell.serverEventIcon then
        cell.serverEventIcon:Hide()
    end

    cell.hasServerEvent = false
    cell.serverEventColor = nil
    cell.serverEventData = nil

    -- Reset border to default (unless it's today)
    if not cell.isToday then
        cell:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
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
    card.title:SetWordWrap(false)

    -- Subtitle (time + leader)
    card.subtitle = card:CreateFontString(nil, "OVERLAY")
    card.subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    card.subtitle:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -2)
    card.subtitle:SetTextColor(0.7, 0.7, 0.7)
    card.subtitle:SetWidth(180)
    card.subtitle:SetWordWrap(false)

    -- Signups count
    card.signups = card:CreateFontString(nil, "OVERLAY")
    card.signups:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    card.signups:SetPoint("BOTTOMLEFT", card.icon, "BOTTOMRIGHT", 8, 2)
    card.signups:SetTextColor(0.6, 0.8, 0.6)
    card.signups:SetWidth(180)
    card.signups:SetWordWrap(false)

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

    -- Local Time (shown below PST time)
    tooltip.localTime = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.localTime:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    tooltip.localTime:SetPoint("TOPLEFT", tooltip.dateTime, "BOTTOMLEFT", 0, -2)
    tooltip.localTime:SetTextColor(0.6, 0.8, 0.6)

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

    -- Date/Time (PST)
    local dateTimeStr = self:FormatBannerDateInfo(event)
    tooltip.dateTime:SetText(dateTimeStr)

    -- Show local time if event has a time and user is not in PST
    if event.time and event.time ~= "WEEKLY_RESET" then
        local localTimeStr = Calendar:FormatLocalTimeFromPST(event.time)
        if localTimeStr then
            tooltip.localTime:SetText("Your Local Time: " .. localTimeStr)
            tooltip.localTime:Show()
        else
            tooltip.localTime:Hide()
        end
    else
        tooltip.localTime:Hide()
    end

    -- Description
    local desc = event.description or "No additional details."
    tooltip.description:SetText(desc)

    -- Calculate dynamic height based on description and local time
    local descHeight = tooltip.description:GetStringHeight()
    local baseHeight = 80  -- Icon + header + divider + padding
    local localTimeHeight = tooltip.localTime:IsShown() and 16 or 0
    tooltip:SetHeight(baseHeight + localTimeHeight + descHeight + 12)

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
        -- Open unified popup in create mode for today's date
        local todayStr = date("%Y-%m-%d")
        self:ShowUnifiedDayPopup(todayStr, nil, true)
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

--[[
    Navigate directly to a specific date
    @param year number
    @param month number
    @param day number
]]
function CalendarUI:NavigateToDate(year, month, day)
    -- Update current month/year to match target
    currentMonth = month
    currentYear = year

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

    -- Show events for the specific date
    local dateStr = string.format("%04d-%02d-%02d", year, month, day)
    self:ShowUnifiedDayPopup(dateStr)
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
    Populate the month grid with day cells (mini-card version with dynamic heights)
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

    -- Store cells by row for height alignment
    local gridCells = {}
    for row = 1, UI.GRID_ROWS do
        gridCells[row] = {}
    end

    -- First pass: Create cells and calculate heights
    local cellIndex = 1
    for row = 1, UI.GRID_ROWS do
        for col = 1, UI.GRID_COLS do
            local cell = dayCellPool:Acquire()
            cell:SetParent(gridContainer.gridArea)

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

                -- Populate mini-cards (this calculates cell.calculatedHeight)
                local eventData = eventsForMonth[dateStr]
                if eventData and eventData.events and #eventData.events > 0 then
                    self:PopulateMiniCards(cell, eventData.events, dateStr)
                else
                    self:ClearMiniCards(cell)
                    cell.calculatedHeight = UI.CELL_HEIGHT
                end

                -- Apply server event themed background (if present)
                if eventData and eventData.serverEvent then
                    self:ApplyServerEventTheme(cell, eventData.serverEvent)
                else
                    self:ClearServerEventTheme(cell)
                end

                -- Click handler (show unified day popup)
                cell:SetScript("OnClick", function()
                    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                    self:ShowUnifiedDayPopup(dateStr)
                end)

                cell:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            else
                -- Empty cell (outside current month)
                cell.dayNumber:SetText("")
                self:ClearMiniCards(cell)
                self:ClearServerEventTheme(cell)
                cell.calculatedHeight = UI.CELL_HEIGHT
                cell.dateStr = nil
                cell:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
                cell:SetScript("OnClick", nil)
            end

            -- Store for row alignment
            gridCells[row][col] = cell
            table.insert(activeDayCells, cell)
            cellIndex = cellIndex + 1
        end
    end

    -- Second pass: Align row heights and position cells
    local yOffset = 0
    for row = 1, UI.GRID_ROWS do
        -- Find max height in this row
        local maxRowHeight = UI.CELL_HEIGHT
        for col = 1, UI.GRID_COLS do
            local cell = gridCells[row][col]
            if cell and cell.calculatedHeight then
                maxRowHeight = math.max(maxRowHeight, cell.calculatedHeight)
            end
        end

        -- Apply height and position to all cells in row
        for col = 1, UI.GRID_COLS do
            local cell = gridCells[row][col]
            if cell then
                cell:SetHeight(maxRowHeight)
                local xOffset = (col - 1) * (UI.CELL_WIDTH + UI.CELL_SPACING)
                cell:ClearAllPoints()
                cell:SetPoint("TOPLEFT", gridContainer.gridArea, "TOPLEFT", xOffset, -yOffset)
                cell:Show()
            end
        end

        -- Accumulate Y offset for next row
        yOffset = yOffset + maxRowHeight + UI.CELL_SPACING
    end

    -- Update grid area size to fit dynamic content
    if gridContainer.gridArea then
        gridContainer.gridArea:SetHeight(yOffset)
    end
end

--============================================================
-- CONTINUOUS WEEK CALENDAR VIEW
--============================================================

local activeWeekCells = {}

--[[
    Create the continuous week calendar (scrollable, current week at top)
    @param parent Frame
    @return Frame weekContainer
]]
function CalendarUI:CreateWeekCalendar(parent)
    local UI = C.CALENDAR_UI
    local WEEK = C.CALENDAR_WEEK_VIEW

    local container = CreateFrame("Frame", nil, parent)
    local gridWidth = (WEEK.DAY_CELL_WIDTH + WEEK.DAY_CELL_SPACING) * 7 - WEEK.DAY_CELL_SPACING
    container:SetWidth(gridWidth)
    container:SetHeight(1)  -- Will be set dynamically by PopulateWeekCalendar

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
        local xOffset = (i - 1) * (WEEK.DAY_CELL_WIDTH + WEEK.DAY_CELL_SPACING) + WEEK.DAY_CELL_WIDTH / 2
        label:SetPoint("TOP", headerRow, "TOPLEFT", xOffset, 0)
    end

    -- Content frame for weeks (no separate scroll - uses parent's scroll)
    local contentFrame = CreateFrame("Frame", nil, container)
    contentFrame:SetPoint("TOPLEFT", headerRow, "BOTTOMLEFT", 0, -4)
    contentFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -4)
    contentFrame:SetWidth(gridWidth)
    contentFrame:SetHeight(1) -- Will be set by PopulateWeekCalendar
    container.scrollChild = contentFrame  -- Keep property name for compatibility

    weekCalendar = container
    return container
end

--[[
    Populate the continuous week calendar with weeks starting from current week
    @param weekContainer Frame
]]
function CalendarUI:PopulateWeekCalendar(weekContainer)
    if not weekContainer or not weekContainer.scrollChild then return end

    local UI = C.CALENDAR_UI
    local WEEK = C.CALENDAR_WEEK_VIEW
    local MONTH_COLORS = C.CALENDAR_MONTH_COLORS

    -- Release existing cells
    for _, cell in ipairs(activeWeekCells) do
        if dayCellPool then
            dayCellPool:Release(cell)
        end
    end
    wipe(activeWeekCells)

    -- Clear any month headers
    for _, child in ipairs({weekContainer.scrollChild:GetChildren()}) do
        if child.isMonthHeader then
            child:Hide()
            child:SetParent(nil)
        end
    end
    for _, region in ipairs({weekContainer.scrollChild:GetRegions()}) do
        if region.isMonthLabel then
            region:Hide()
        end
    end

    -- Get today and calculate start of current week (Sunday)
    local today = date("*t")
    local todayStr = string.format("%04d-%02d-%02d", today.year, today.month, today.day)

    -- Calculate days since Sunday (wday: 1=Sun, 7=Sat)
    local daysSinceSunday = today.wday - 1
    local weekStartTime = time(today) - (daysSinceSunday * 86400)
    local weekStart = date("*t", weekStartTime)

    -- Store cells by row for height alignment
    local gridCells = {}
    local monthHeaders = {}
    local yOffset = 0

    -- Create weeks
    for week = 1, WEEK.WEEKS_TO_SHOW do
        gridCells[week] = {}

        -- Calculate the week's starting date
        local weekOffset = (week - 1) * 7
        local firstDayTime = weekStartTime + (weekOffset * 86400)

        -- Check if we need a month header (first day of this week row is day 1-7 of a month)
        local firstDayOfWeek = date("*t", firstDayTime)
        local needsMonthHeader = false
        local monthHeaderMonth = nil

        -- Check each day in this week for the 1st of a month
        for d = 0, 6 do
            local dayTime = firstDayTime + (d * 86400)
            local dayInfo = date("*t", dayTime)
            if dayInfo.day == 1 then
                needsMonthHeader = true
                monthHeaderMonth = dayInfo.month
                break
            end
        end

        -- Add month header if needed
        if needsMonthHeader and monthHeaderMonth then
            local monthColor = MONTH_COLORS[monthHeaderMonth]
            local monthName = monthColor and monthColor.name or UI.MONTH_NAMES[monthHeaderMonth]

            local headerFrame = CreateFrame("Frame", nil, weekContainer.scrollChild)
            headerFrame:SetHeight(22)
            headerFrame:SetPoint("TOPLEFT", weekContainer.scrollChild, "TOPLEFT", 0, -yOffset)
            headerFrame:SetPoint("TOPRIGHT", weekContainer.scrollChild, "TOPRIGHT", 0, -yOffset)
            headerFrame.isMonthHeader = true

            local monthLabel = headerFrame:CreateFontString(nil, "OVERLAY")
            monthLabel:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
            monthLabel:SetPoint("LEFT", headerFrame, "LEFT", 4, 0)
            monthLabel:SetText(monthName)
            if monthColor then
                monthLabel:SetTextColor(monthColor.r, monthColor.g, monthColor.b)
            else
                monthLabel:SetTextColor(1, 0.84, 0)
            end
            monthLabel.isMonthLabel = true

            table.insert(monthHeaders, headerFrame)
            yOffset = yOffset + 22
        end

        -- Find max height for this row
        local maxRowHeight = WEEK.WEEK_ROW_HEIGHT

        -- First pass: Create cells and calculate heights
        for col = 1, 7 do
            local dayOffset = (col - 1)
            local dayTime = firstDayTime + (dayOffset * 86400)
            local dayInfo = date("*t", dayTime)

            local cell = dayCellPool:Acquire()
            cell:SetParent(weekContainer.scrollChild)
            cell:SetWidth(WEEK.DAY_CELL_WIDTH)

            local dateStr = string.format("%04d-%02d-%02d", dayInfo.year, dayInfo.month, dayInfo.day)
            cell.dateStr = dateStr
            cell.dayNumber:SetText(tostring(dayInfo.day))

            -- Highlight today
            if dateStr == todayStr then
                cell.isToday = true
                cell:SetBackdropBorderColor(1, 0.84, 0, 0.8)
                cell.dayNumber:SetTextColor(1, 0.84, 0)
            else
                cell.isToday = false
                cell.dayNumber:SetTextColor(0.9, 0.9, 0.9)
            end

            -- Get events for this day (exclude server events from mini-cards)
            local events = Calendar and Calendar:GetEventsForDate(dateStr, false) or {}
            if #events > 0 then
                self:PopulateMiniCards(cell, events, dateStr)
            else
                self:ClearMiniCards(cell)
                cell.calculatedHeight = WEEK.WEEK_ROW_HEIGHT
            end

            -- Apply server event themed background (if present)
            local serverEvent = Calendar and Calendar:GetServerEventForDate(dateStr)
            if serverEvent then
                self:ApplyServerEventTheme(cell, serverEvent)
            else
                self:ClearServerEventTheme(cell)
            end

            -- Track max height
            maxRowHeight = math.max(maxRowHeight, cell.calculatedHeight or WEEK.WEEK_ROW_HEIGHT)

            -- Click handler - show unified day popup
            cell:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                self:ShowUnifiedDayPopup(dateStr)
            end)

            cell:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

            gridCells[week][col] = cell
            table.insert(activeWeekCells, cell)
        end

        -- Second pass: Apply heights and positions
        for col = 1, 7 do
            local cell = gridCells[week][col]
            if cell then
                cell:SetHeight(maxRowHeight)
                local xOffset = (col - 1) * (WEEK.DAY_CELL_WIDTH + WEEK.DAY_CELL_SPACING)
                cell:ClearAllPoints()
                cell:SetPoint("TOPLEFT", weekContainer.scrollChild, "TOPLEFT", xOffset, -yOffset)
                cell:Show()
            end
        end

        yOffset = yOffset + maxRowHeight + WEEK.DAY_CELL_SPACING
    end

    -- Update content height
    weekContainer.scrollChild:SetHeight(yOffset)
    weekContainer:SetHeight(yOffset + 22)  -- +22 for day name headers
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

    -- Color stripe based on event type or custom color
    local eventColor = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER

    -- Check for custom event color override
    if event.eventColor then
        for _, preset in ipairs(C.CALENDAR_EVENT_COLOR_PRESETS) do
            if preset.key == event.eventColor and preset.color then
                eventColor = preset.color
                break
            end
        end
    end

    card.colorStripe:SetColorTexture(eventColor.r, eventColor.g, eventColor.b, 1)

    -- Title with lock indicator if locked
    local titleText = event.title or "Event"
    if event.locked then
        titleText = "|cFFFF4444[LOCKED]|r " .. titleText
    end
    card.title:SetText(titleText)

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

        -- Card click shows unified popup with server event selected
        card:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowUnifiedDayPopup(event.date, event.id)
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

        -- Looking For roles display
        local lfParts = {}
        local maxTanks = event.maxTanks or 2
        local maxHealers = event.maxHealers or 3
        local maxDPS = event.maxDPS or 5

        if maxTanks > 0 then
            table.insert(lfParts, "|cFF4169E1" .. maxTanks .. "T|r")
        end
        if maxHealers > 0 then
            table.insert(lfParts, "|cFF00FF00" .. maxHealers .. "H|r")
        end
        if maxDPS > 0 then
            table.insert(lfParts, "|cFFFF4444" .. maxDPS .. "D|r")
        end

        if #lfParts > 0 then
            card.signups:SetText("LF: " .. table.concat(lfParts, " "))
        else
            card.signups:SetText("")
        end

        -- Show view button for guild events
        card.viewBtn:Show()

        -- View button click - show unified popup with this event selected
        card.viewBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowUnifiedDayPopup(event.date, event.id)
        end)

        -- Card click (same as view)
        card:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self:ShowUnifiedDayPopup(event.date, event.id)
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

    -- Close button (top right)
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    --============================================================
    -- HEADER SECTION
    --============================================================

    -- Title (event name)
    popup.title = popup:CreateFontString(nil, "OVERLAY")
    popup.title:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    popup.title:SetPoint("TOP", popup, "TOP", 0, -25)
    popup.title:SetTextColor(1, 0.84, 0)

    -- Event type subtitle (e.g., "RAID - 10-man")
    popup.subtitle = popup:CreateFontString(nil, "OVERLAY")
    popup.subtitle:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.subtitle:SetPoint("TOP", popup.title, "BOTTOM", 0, -4)
    popup.subtitle:SetTextColor(0.7, 0.7, 0.7)

    --============================================================
    -- INFO CARDS SECTION (Two-column layout)
    --============================================================

    local cardWidth = 185
    local cardHeight = 80
    local cardSpacing = 10
    local cardsTopOffset = -60

    -- Helper to create info card container
    local function createInfoCard(parent, anchorPoint, xOffset)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetSize(cardWidth, cardHeight)
        card:SetPoint("TOP", parent, "TOP", xOffset, cardsTopOffset)
        card:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        card:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
        return card
    end

    -- LEFT CARD: "WHEN" (Date & Time)
    local whenCard = createInfoCard(popup, "TOPLEFT", -cardWidth/2 - cardSpacing/2)
    popup.whenCard = whenCard

    local whenLabel = whenCard:CreateFontString(nil, "OVERLAY")
    whenLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    whenLabel:SetPoint("TOPLEFT", whenCard, "TOPLEFT", 10, -8)
    whenLabel:SetText("WHEN")
    whenLabel:SetTextColor(1, 0.84, 0)

    popup.dayName = whenCard:CreateFontString(nil, "OVERLAY")
    popup.dayName:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    popup.dayName:SetPoint("TOPLEFT", whenLabel, "BOTTOMLEFT", 0, -4)
    popup.dayName:SetTextColor(0.9, 0.9, 0.9)

    popup.dateText = whenCard:CreateFontString(nil, "OVERLAY")
    popup.dateText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.dateText:SetPoint("TOPLEFT", popup.dayName, "BOTTOMLEFT", 0, -2)
    popup.dateText:SetTextColor(0.8, 0.8, 0.8)

    -- Small divider in the card
    local timeDivider = whenCard:CreateTexture(nil, "ARTWORK")
    timeDivider:SetColorTexture(0.4, 0.4, 0.4, 0.4)
    timeDivider:SetSize(cardWidth - 20, 1)
    timeDivider:SetPoint("TOPLEFT", popup.dateText, "BOTTOMLEFT", 0, -6)

    popup.realmTime = whenCard:CreateFontString(nil, "OVERLAY")
    popup.realmTime:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.realmTime:SetPoint("TOPLEFT", timeDivider, "BOTTOMLEFT", 0, -6)
    popup.realmTime:SetTextColor(0.9, 0.9, 0.9)

    popup.localTime = whenCard:CreateFontString(nil, "OVERLAY")
    popup.localTime:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.localTime:SetPoint("TOPLEFT", popup.realmTime, "BOTTOMLEFT", 0, -2)
    popup.localTime:SetTextColor(0.6, 0.6, 0.6)

    -- RIGHT CARD: "ORGANIZER" (Leader info)
    local orgCard = createInfoCard(popup, "TOPRIGHT", cardWidth/2 + cardSpacing/2)
    popup.orgCard = orgCard

    local orgLabel = orgCard:CreateFontString(nil, "OVERLAY")
    orgLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    orgLabel:SetPoint("TOPLEFT", orgCard, "TOPLEFT", 10, -8)
    orgLabel:SetText("ORGANIZER")
    orgLabel:SetTextColor(1, 0.84, 0)

    popup.leaderName = orgCard:CreateFontString(nil, "OVERLAY")
    popup.leaderName:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    popup.leaderName:SetPoint("TOPLEFT", orgLabel, "BOTTOMLEFT", 0, -6)
    popup.leaderName:SetTextColor(0.9, 0.9, 0.9)

    popup.guildName = orgCard:CreateFontString(nil, "OVERLAY")
    popup.guildName:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.guildName:SetPoint("TOPLEFT", popup.leaderName, "BOTTOMLEFT", 0, -4)
    popup.guildName:SetTextColor(0.6, 0.6, 0.6)

    --============================================================
    -- DESCRIPTION SECTION
    --============================================================

    local descTopOffset = cardsTopOffset - cardHeight - 12

    popup.descLabel = popup:CreateFontString(nil, "OVERLAY")
    popup.descLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.descLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, descTopOffset)
    popup.descLabel:SetText("DESCRIPTION")
    popup.descLabel:SetTextColor(1, 0.84, 0)

    -- Description container
    popup.descContainer = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    popup.descContainer:SetPoint("TOPLEFT", popup.descLabel, "BOTTOMLEFT", 0, -4)
    popup.descContainer:SetPoint("RIGHT", popup, "RIGHT", -20, 0)
    popup.descContainer:SetHeight(45)
    popup.descContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.descContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
    popup.descContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)

    popup.description = popup.descContainer:CreateFontString(nil, "OVERLAY")
    popup.description:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.description:SetPoint("TOPLEFT", popup.descContainer, "TOPLEFT", 8, -6)
    popup.description:SetPoint("BOTTOMRIGHT", popup.descContainer, "BOTTOMRIGHT", -8, 6)
    popup.description:SetJustifyH("LEFT")
    popup.description:SetJustifyV("TOP")
    popup.description:SetTextColor(0.85, 0.85, 0.85)

    --============================================================
    -- LOOKING FOR SECTION
    --============================================================

    -- Divider before Looking For
    popup.signupDivider = popup:CreateTexture(nil, "ARTWORK")
    popup.signupDivider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    popup.signupDivider:SetHeight(2)
    popup.signupDivider:SetPoint("LEFT", popup, "LEFT", 15, 0)
    popup.signupDivider:SetPoint("RIGHT", popup, "RIGHT", -15, 0)
    popup.signupDivider:SetPoint("TOP", popup.descContainer, "BOTTOM", 0, -10)
    popup.signupDivider:SetVertexColor(0.5, 0.5, 0.5, 0.5)

    -- Looking For header
    popup.signupsHeader = popup:CreateFontString(nil, "OVERLAY")
    popup.signupsHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    popup.signupsHeader:SetPoint("TOPLEFT", popup.signupDivider, "BOTTOMLEFT", 5, -8)
    popup.signupsHeader:SetText("LOOKING FOR")
    popup.signupsHeader:SetTextColor(1, 0.84, 0)

    -- Hidden but kept for backward compat (not displayed)
    popup.needsIndicator = popup:CreateFontString(nil, "OVERLAY")
    popup.needsIndicator:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.needsIndicator:SetPoint("TOPRIGHT", popup.signupDivider, "BOTTOMRIGHT", -5, -8)
    popup.needsIndicator:SetTextColor(0.8, 0.8, 0.8)
    popup.needsIndicator:Hide()

    -- Role boxes container
    popup.roleBoxContainer = CreateFrame("Frame", nil, popup)
    popup.roleBoxContainer:SetSize(340, 55)
    popup.roleBoxContainer:SetPoint("TOPLEFT", popup.signupsHeader, "BOTTOMLEFT", 0, -8)

    -- Create role display boxes (populated in ShowEventDetail)
    popup.roleBoxes = {}
    local roleOrder = { "tank", "healer", "dps" }
    local boxWidth = 100
    local boxSpacing = 10
    for i, roleKey in ipairs(roleOrder) do
        local roleData = C.CALENDAR_ROLES[roleKey]
        local color = roleData.color

        local box = CreateFrame("Frame", nil, popup.roleBoxContainer, "BackdropTemplate")
        box:SetSize(boxWidth, 50)
        box:SetPoint("TOPLEFT", popup.roleBoxContainer, "TOPLEFT", (i - 1) * (boxWidth + boxSpacing), 0)
        box:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        box:SetBackdropColor(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.9)
        box:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.8)

        box.numText = box:CreateFontString(nil, "OVERLAY")
        box.numText:SetFont(HopeAddon.assets.fonts.HEADER, 18, "")
        box.numText:SetPoint("TOP", box, "TOP", 0, -6)
        box.numText:SetText("0")
        box.numText:SetTextColor(color.r, color.g, color.b)

        box.roleText = box:CreateFontString(nil, "OVERLAY")
        box.roleText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        box.roleText:SetPoint("BOTTOM", box, "BOTTOM", 0, 6)
        box.roleText:SetText(roleData.name:upper())
        box.roleText:SetTextColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)

        popup.roleBoxes[roleKey] = box
    end

    -- Discord CTA button
    popup.discordBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    popup.discordBtn:SetSize(340, 40)
    popup.discordBtn:SetPoint("TOP", popup.roleBoxContainer, "BOTTOM", 0, -10)
    popup.discordBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    popup.discordBtn:SetBackdropColor(0.2, 0.25, 0.35, 1)
    popup.discordBtn:SetBackdropBorderColor(0.4, 0.5, 0.8, 1)

    popup.discordBtnTitle = popup.discordBtn:CreateFontString(nil, "OVERLAY")
    popup.discordBtnTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    popup.discordBtnTitle:SetPoint("TOP", popup.discordBtn, "TOP", 0, -6)
    popup.discordBtnTitle:SetText("|cFF7289DAJOIN US ON DISCORD|r")

    popup.discordBtnSubtext = popup.discordBtn:CreateFontString(nil, "OVERLAY")
    popup.discordBtnSubtext:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    popup.discordBtnSubtext:SetPoint("BOTTOM", popup.discordBtn, "BOTTOM", 0, 6)
    popup.discordBtnSubtext:SetText("|cFF888888Click to copy invite link|r")

    -- Hidden signup scroll area (kept for backward compat with PopulateSignupList/PopulateRosterManagement calls)
    popup.signupScroll = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    popup.signupScroll:SetPoint("TOPLEFT", popup.discordBtn, "BOTTOMLEFT", 0, -5)
    popup.signupScroll:SetSize(1, 1)
    popup.signupScroll:Hide()

    popup.signupContent = CreateFrame("Frame", nil, popup.signupScroll)
    popup.signupContent:SetSize(1, 1)
    popup.signupScroll:SetScrollChild(popup.signupContent)

    --============================================================
    -- ACTION SECTION (Bottom)
    --============================================================

    -- Hidden your status label (kept for backward compat)
    popup.yourStatus = popup:CreateFontString(nil, "OVERLAY")
    popup.yourStatus:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.yourStatus:SetPoint("BOTTOM", popup, "BOTTOM", 0, 105)
    popup.yourStatus:SetTextColor(0.8, 0.8, 0.8)
    popup.yourStatus:Hide()

    -- Hidden role buttons container (kept for backward compat)
    popup.roleButtons = CreateFrame("Frame", nil, popup)
    popup.roleButtons:SetSize(340, 30)
    popup.roleButtons:SetPoint("BOTTOM", popup, "BOTTOM", 0, 65)
    popup.roleButtons:Hide()

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

    -- Lock/Unlock button (for event owners)
    popup.lockBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    popup.lockBtn:SetSize(80, 26)
    popup.lockBtn:SetPoint("LEFT", popup.saveTemplateBtn, "RIGHT", 8, 0)
    popup.lockBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.lockBtn:SetBackdropColor(0.3, 0.25, 0.2, 1)
    popup.lockBtn:SetBackdropBorderColor(0.8, 0.6, 0.4, 1)

    popup.lockBtnText = popup.lockBtn:CreateFontString(nil, "OVERLAY")
    popup.lockBtnText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    popup.lockBtnText:SetPoint("CENTER")
    popup.lockBtnText:SetText("Lock")
    popup.lockBtnText:SetTextColor(0.8, 0.6, 0.4)

    popup.lockBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    popup.lockBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.8, 0.6, 0.4, 1)
    end)
    popup.lockBtn:Hide()  -- Hidden by default, shown for owners

    -- Delete button (for event owners)
    popup.deleteBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    popup.deleteBtn:SetSize(70, 26)
    popup.deleteBtn:SetPoint("LEFT", popup.lockBtn, "RIGHT", 8, 0)
    popup.deleteBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.deleteBtn:SetBackdropColor(0.3, 0.15, 0.15, 1)
    popup.deleteBtn:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)

    popup.deleteBtnText = popup.deleteBtn:CreateFontString(nil, "OVERLAY")
    popup.deleteBtnText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    popup.deleteBtnText:SetPoint("CENTER")
    popup.deleteBtnText:SetText("Delete")
    popup.deleteBtnText:SetTextColor(1, 0.4, 0.4)

    popup.deleteBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    popup.deleteBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
    end)
    popup.deleteBtn:Hide()  -- Hidden by default, shown for owners

    -- Export button (for event owners)
    popup.exportBtn = CreateFrame("Button", nil, popup, "BackdropTemplate")
    popup.exportBtn:SetSize(70, 26)
    popup.exportBtn:SetPoint("LEFT", popup.deleteBtn, "RIGHT", 8, 0)
    popup.exportBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.exportBtn:SetBackdropColor(0.2, 0.25, 0.3, 1)
    popup.exportBtn:SetBackdropBorderColor(0.4, 0.5, 0.7, 1)

    popup.exportBtnText = popup.exportBtn:CreateFontString(nil, "OVERLAY")
    popup.exportBtnText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    popup.exportBtnText:SetPoint("CENTER")
    popup.exportBtnText:SetText("Export")
    popup.exportBtnText:SetTextColor(0.6, 0.7, 0.9)

    popup.exportBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    popup.exportBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.5, 0.7, 1)
    end)
    popup.exportBtn:Hide()  -- Hidden by default, shown for owners

    -- Discord note (shown below signups)
    popup.discordNote = popup:CreateFontString(nil, "OVERLAY")
    popup.discordNote:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    popup.discordNote:SetPoint("BOTTOM", popup.yourStatus, "TOP", 0, 5)
    popup.discordNote:SetWidth(popup:GetWidth() - 30)
    popup.discordNote:SetJustifyH("CENTER")
    popup.discordNote:SetText("Note: Official signups tracked on Discord. In-app signups are for convenience.")
    popup.discordNote:SetTextColor(0.5, 0.5, 0.45)

    -- Lock indicator icon (shown in title area when locked)
    popup.lockIcon = popup:CreateFontString(nil, "OVERLAY")
    popup.lockIcon:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    popup.lockIcon:SetPoint("LEFT", popup.title, "RIGHT", 5, 0)
    popup.lockIcon:SetText("|cFFFF4444[LOCKED]|r")
    popup.lockIcon:Hide()

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

    -- Show/hide Lock button for event owners
    local isLocked = event.locked == true
    if popup.lockBtn then
        if isOwner then
            popup.lockBtn:Show()
            -- Update button text based on current lock state
            if isLocked then
                popup.lockBtnText:SetText("Unlock")
                popup.lockBtn:SetBackdropColor(0.2, 0.3, 0.2, 1)
                popup.lockBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
                popup.lockBtnText:SetTextColor(0.6, 0.9, 0.6)
            else
                popup.lockBtnText:SetText("Lock")
                popup.lockBtn:SetBackdropColor(0.3, 0.25, 0.2, 1)
                popup.lockBtn:SetBackdropBorderColor(0.8, 0.6, 0.4, 1)
                popup.lockBtnText:SetTextColor(0.8, 0.6, 0.4)
            end
            popup.lockBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                if isLocked then
                    local success, err = Calendar:UnlockEvent(event.id)
                    if success then
                        HopeAddon:Print("|cFF00FF00Event unlocked|r - signups are now open")
                        CalendarUI:ShowEventDetail(event)  -- Refresh
                    else
                        HopeAddon:Print("|cFFFF0000Failed to unlock:|r " .. (err or "Unknown error"))
                    end
                else
                    local success, err = Calendar:LockEvent(event.id)
                    if success then
                        HopeAddon:Print("|cFFFFAA00Event locked|r - signups are now closed")
                        CalendarUI:ShowEventDetail(event)  -- Refresh
                    else
                        HopeAddon:Print("|cFFFF0000Failed to lock:|r " .. (err or "Unknown error"))
                    end
                end
            end)
        else
            popup.lockBtn:Hide()
        end
    end

    -- Show/hide Delete button for event owners
    if popup.deleteBtn then
        if isOwner then
            popup.deleteBtn:Show()
            popup.deleteBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                -- Show confirmation dialog
                StaticPopup_Show("HOPE_CONFIRM_DELETE_EVENT", event.title, nil, {
                    eventId = event.id,
                    popup = popup
                })
            end)
        else
            popup.deleteBtn:Hide()
        end
    end

    -- Show/hide Export button for event owners
    if popup.exportBtn then
        if isOwner then
            popup.exportBtn:Show()
            popup.exportBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                local text = Calendar:ExportEventDetails(event)
                Calendar:ShowExportPopup(text)
            end)
        else
            popup.exportBtn:Hide()
        end
    end

    -- Show/hide lock indicator
    if popup.lockIcon then
        if isLocked then
            popup.lockIcon:Show()
        else
            popup.lockIcon:Hide()
        end
    end

    --============================================================
    -- HEADER SECTION
    --============================================================

    -- Title (event name)
    popup.title:SetText(event.title or "Event")

    -- Event type subtitle (e.g., "RAID - 10-man - LF: 2T 3H 5D")
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    local lfParts = {}
    if (event.maxTanks or 0) > 0 then table.insert(lfParts, event.maxTanks .. "T") end
    if (event.maxHealers or 0) > 0 then table.insert(lfParts, event.maxHealers .. "H") end
    if (event.maxDPS or 0) > 0 then table.insert(lfParts, event.maxDPS .. "D") end
    local lfText = #lfParts > 0 and ("LF: " .. table.concat(lfParts, " ")) or ""
    popup.subtitle:SetText(eventType.name:upper() .. " - " .. (event.raidSize or 10) .. "-man" .. (#lfParts > 0 and (" - " .. lfText) or ""))

    --============================================================
    -- INFO CARDS
    --============================================================

    -- Parse date for the WHEN card
    local year, month, day = Calendar:ParseDate(event.date)
    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]

    -- WHEN card fields
    popup.dayName:SetText(dayName)
    popup.dateText:SetText(monthName .. " " .. day)

    -- Time display (realm and local)
    local realmTime, localTime = Calendar:GetDualTimes(event.startTime)
    if realmTime then
        popup.realmTime:SetText(realmTime .. " (Realm)")
        if localTime and localTime ~= realmTime then
            popup.localTime:SetText(localTime .. " (Local)")
            popup.localTime:Show()
        else
            popup.localTime:SetText("")
            popup.localTime:Hide()
        end
    else
        popup.realmTime:SetText(event.startTime or "TBD")
        popup.localTime:SetText("")
        popup.localTime:Hide()
    end

    -- ORGANIZER card fields
    if event.leader then
        local classColor = RAID_CLASS_COLORS[event.leaderClass] or { r = 0.9, g = 0.9, b = 0.9 }
        local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
        popup.leaderName:SetText("|cFF" .. colorHex .. event.leader .. "|r")
    else
        popup.leaderName:SetText("Unknown")
    end

    -- Guild name (if available via traveler data or guild data)
    local guildText = ""
    if event.leaderGuild and event.leaderGuild ~= "" then
        guildText = "<" .. event.leaderGuild .. ">"
    end
    popup.guildName:SetText(guildText)

    --============================================================
    -- DESCRIPTION SECTION
    --============================================================

    if event.description and event.description ~= "" then
        popup.description:SetText(event.description)
        popup.descLabel:Show()
        popup.descContainer:Show()
    else
        popup.description:SetText("")
        popup.descLabel:Hide()
        popup.descContainer:Hide()
    end

    --============================================================
    -- LOOKING FOR SECTION
    --============================================================

    -- Update role boxes with the event's needed roles
    if popup.roleBoxes then
        if popup.roleBoxes.tank then
            popup.roleBoxes.tank.numText:SetText(tostring(event.maxTanks or 2))
        end
        if popup.roleBoxes.healer then
            popup.roleBoxes.healer.numText:SetText(tostring(event.maxHealers or 3))
        end
        if popup.roleBoxes.dps then
            popup.roleBoxes.dps.numText:SetText(tostring(event.maxDPS or 5))
        end
    end

    -- Update Discord CTA button
    if popup.discordBtn then
        if event.discordLink and event.discordLink ~= "" then
            popup.discordBtnSubtext:SetText("|cFF888888Click to copy invite link|r")
            popup.discordBtn:SetBackdropColor(0.2, 0.25, 0.35, 1)
            popup.discordBtn:SetBackdropBorderColor(0.4, 0.5, 0.8, 1)
            popup.discordBtnTitle:SetTextColor(0.45, 0.54, 0.85)

            popup.discordBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                -- Show copy dialog
                local copyFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                copyFrame:SetSize(350, 80)
                copyFrame:SetPoint("CENTER")
                copyFrame:SetFrameStrata("DIALOG")
                copyFrame:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
                    edgeSize = 24,
                    insets = { left = 6, right = 6, top = 6, bottom = 6 },
                })
                copyFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.98)

                local titleText = copyFrame:CreateFontString(nil, "OVERLAY")
                titleText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
                titleText:SetPoint("TOP", copyFrame, "TOP", 0, -12)
                titleText:SetText("Discord Link - Press Ctrl+C to copy")
                titleText:SetTextColor(1, 0.84, 0)

                local editBox = CreateFrame("EditBox", nil, copyFrame, "InputBoxTemplate")
                editBox:SetSize(310, 20)
                editBox:SetPoint("CENTER", copyFrame, "CENTER", 0, -5)
                editBox:SetAutoFocus(true)
                editBox:SetText(event.discordLink)
                editBox:HighlightText()
                editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
                editBox:SetScript("OnEnterPressed", function() copyFrame:Hide() end)

                local closeBtn = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
                closeBtn:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT", -2, -2)
                closeBtn:SetScript("OnClick", function() copyFrame:Hide() end)

                HopeAddon:Print("|cFF7289DADiscord link ready to copy!|r")
            end)
            popup.discordBtn:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(1, 0.84, 0, 1)
            end)
            popup.discordBtn:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(0.4, 0.5, 0.8, 1)
            end)
        else
            popup.discordBtnSubtext:SetText("|cFF666666No Discord link provided|r")
            popup.discordBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
            popup.discordBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
            popup.discordBtnTitle:SetTextColor(0.5, 0.5, 0.5)
            popup.discordBtn:SetScript("OnClick", nil)
            popup.discordBtn:SetScript("OnEnter", nil)
            popup.discordBtn:SetScript("OnLeave", nil)
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

--============================================================
-- DAY EVENTS POPUP (shown when clicking a day in week view)
--============================================================

local dayEventsPopup = nil

--[[
    Get or create the day events popup
    @return Frame popup
]]
function CalendarUI:GetDayEventsPopup()
    if dayEventsPopup then return dayEventsPopup end

    local POPUP = C.CALENDAR_DAY_POPUP
    local popup = CreateFrame("Frame", "HopeCalendarDayEvents", UIParent, "BackdropTemplate")
    popup:SetSize(POPUP.WIDTH, POPUP.HEIGHT)
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

    -- Close button (top right)
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Date header
    popup.dateHeader = popup:CreateFontString(nil, "OVERLAY")
    popup.dateHeader:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    popup.dateHeader:SetPoint("TOP", popup, "TOP", 0, -20)
    popup.dateHeader:SetTextColor(1, 0.84, 0)

    -- Event count
    popup.eventCount = popup:CreateFontString(nil, "OVERLAY")
    popup.eventCount:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.eventCount:SetPoint("TOP", popup.dateHeader, "BOTTOM", 0, -4)
    popup.eventCount:SetTextColor(0.6, 0.6, 0.6)

    -- Scroll area for event cards
    local Comp = HopeAddon.Components
    local C_MARGIN = Comp and Comp.MARGIN_NORMAL or 10
    local C_SCROLLBAR = Comp and Comp.SCROLLBAR_WIDTH or 25

    popup.scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    popup.scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", C_MARGIN, -60)
    popup.scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -(C_MARGIN + C_SCROLLBAR), C_MARGIN)

    popup.scrollChild = CreateFrame("Frame", nil, popup.scrollFrame)
    popup.scrollFrame:SetScrollChild(popup.scrollChild)

    -- Use OnSizeChanged to handle scrollChild width after layout
    popup.scrollFrame:SetScript("OnSizeChanged", function(self, newWidth, newHeight)
        if newWidth and newWidth > 0 then
            popup.scrollChild:SetWidth(newWidth)
        end
    end)

    -- Set initial width with fallback
    local initialWidth = popup.scrollFrame:GetWidth()
    if initialWidth and initialWidth > 0 then
        popup.scrollChild:SetWidth(initialWidth)
    else
        popup.scrollChild:SetWidth(280)  -- Reasonable fallback
    end
    popup.scrollChild:SetHeight(1)

    -- Store reference to active event cards in popup
    popup.activeCards = {}

    dayEventsPopup = popup
    return popup
end

--[[
    Show day events popup for a specific date
    @param dateStr string - YYYY-MM-DD format
]]
function CalendarUI:ShowDayEvents(dateStr)
    if not dateStr then return end

    local popup = self:GetDayEventsPopup()
    local POPUP = C.CALENDAR_DAY_POPUP

    -- Clear existing cards
    for _, card in ipairs(popup.activeCards or {}) do
        if eventCardPool then
            eventCardPool:Release(card)
        end
    end
    wipe(popup.activeCards)

    -- Clear any leftover font strings (no events message)
    self:ClearContentContainer(popup.scrollChild)

    -- Parse date for display
    local year, month, day = Calendar:ParseDate(dateStr)
    if not year then return end

    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    local displayDate = dayName .. ", " .. monthName .. " " .. day

    -- Get events for this date
    local events = Calendar:GetEventsForDate(dateStr)

    -- Update header
    popup.dateHeader:SetText(displayDate)
    popup.eventCount:SetText(#events .. " event" .. (#events ~= 1 and "s" or ""))

    -- Create event cards
    local yOffset = 0
    for _, event in ipairs(events) do
        local card = self:AcquireEventCard(event)
        card:SetParent(popup.scrollChild)
        card:SetPoint("TOPLEFT", popup.scrollChild, "TOPLEFT", 0, -yOffset)
        card:SetPoint("RIGHT", popup.scrollChild, "RIGHT", 0, 0)
        card:SetHeight(POPUP.EVENT_CARD_HEIGHT)
        card:Show()

        table.insert(popup.activeCards, card)
        yOffset = yOffset + POPUP.EVENT_CARD_HEIGHT + POPUP.EVENT_CARD_SPACING
    end

    -- No events message
    if #events == 0 then
        local noEvents = popup.scrollChild:CreateFontString(nil, "OVERLAY")
        noEvents:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        noEvents:SetPoint("TOP", popup.scrollChild, "TOP", 0, -20)
        noEvents:SetText("No events scheduled for this day")
        noEvents:SetTextColor(0.5, 0.5, 0.5)
        noEvents:Show()
    end

    -- Update scroll child height
    popup.scrollChild:SetHeight(math.max(yOffset, 50))

    popup:Show()
end

--============================================================
-- UNIFIED DAY POPUP (Master-Detail View)
--============================================================

local unifiedDayPopup = nil

--[[
    Get or create the unified day popup (master-detail layout)
    @return Frame popup
]]
function CalendarUI:GetUnifiedDayPopup()
    if unifiedDayPopup then return unifiedDayPopup end

    local UNIFIED = C.CALENDAR_UNIFIED_POPUP
    local popup = CreateFrame("Frame", "HopeCalendarUnifiedDay", UIParent, "BackdropTemplate")
    popup:SetSize(UNIFIED.WIDTH, UNIFIED.HEIGHT)
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

    -- Enable escape key to close popup
    popup:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    popup:EnableKeyboard(true)

    -- Close button (top right)
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Date header at top
    popup.dateHeader = popup:CreateFontString(nil, "OVERLAY")
    popup.dateHeader:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    popup.dateHeader:SetPoint("TOP", popup, "TOP", 0, -20)
    popup.dateHeader:SetTextColor(1, 0.84, 0)

    --============================================================
    -- LEFT PANEL (Event List)
    --============================================================
    popup.leftPanel = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    popup.leftPanel:SetPoint("TOPLEFT", popup, "TOPLEFT", 15, -50)
    popup.leftPanel:SetSize(UNIFIED.LEFT_PANEL_WIDTH, UNIFIED.HEIGHT - 70)
    popup.leftPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.leftPanel:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    popup.leftPanel:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    -- Left panel header
    popup.leftHeader = popup.leftPanel:CreateFontString(nil, "OVERLAY")
    popup.leftHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    popup.leftHeader:SetPoint("TOP", popup.leftPanel, "TOP", 0, -8)
    popup.leftHeader:SetText("EVENTS")
    popup.leftHeader:SetTextColor(0.8, 0.8, 0.8)

    -- Scroll frame for event cards
    popup.leftScroll = CreateFrame("ScrollFrame", nil, popup.leftPanel, "UIPanelScrollFrameTemplate")
    popup.leftScroll:SetPoint("TOPLEFT", popup.leftPanel, "TOPLEFT", 5, -28)
    popup.leftScroll:SetPoint("BOTTOMRIGHT", popup.leftPanel, "BOTTOMRIGHT", -25, 8)

    popup.leftContent = CreateFrame("Frame", nil, popup.leftScroll)
    popup.leftContent:SetWidth(UNIFIED.LEFT_PANEL_WIDTH - 35)
    popup.leftContent:SetHeight(1)
    popup.leftScroll:SetScrollChild(popup.leftContent)

    --============================================================
    -- VERTICAL DIVIDER
    --============================================================
    popup.divider = popup:CreateTexture(nil, "ARTWORK")
    popup.divider:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    popup.divider:SetSize(UNIFIED.DIVIDER_WIDTH, UNIFIED.HEIGHT - 70)
    popup.divider:SetPoint("LEFT", popup.leftPanel, "RIGHT", 5, 0)

    --============================================================
    -- RIGHT PANEL (Event Details)
    --============================================================
    popup.rightPanel = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    popup.rightPanel:SetPoint("TOPLEFT", popup.divider, "TOPRIGHT", 5, 0)
    popup.rightPanel:SetSize(UNIFIED.RIGHT_PANEL_WIDTH - 20, UNIFIED.HEIGHT - 70)
    popup.rightPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup.rightPanel:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    popup.rightPanel:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    -- State tracking
    popup.currentDateStr = nil
    popup.currentEvent = nil
    popup.selectedEventId = nil
    popup.activeLeftCards = {}
    popup.isCreateMode = false     -- true when create card is selected
    popup.createForm = {}          -- references to create form elements

    popup:Hide()
    unifiedDayPopup = popup
    return popup
end

--[[
    Create a compact event card for the left panel
    @param parent Frame - Parent frame (leftContent)
    @param event table - Event data
    @param isSelected boolean - Whether this card is selected
    @return Frame card
]]
function CalendarUI:CreateUnifiedEventCard(parent, event, isSelected)
    local UNIFIED = C.CALENDAR_UNIFIED_POPUP
    local isServerEvent = Calendar:IsServerEvent(event)

    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(parent:GetWidth() - 4, UNIFIED.EVENT_CARD_HEIGHT)
    card:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    -- Color based on selection and event type
    if isSelected then
        card:SetBackdropColor(0.2, 0.18, 0.1, 1)
        card:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold border for selected
    elseif isServerEvent then
        card:SetBackdropColor(0.15, 0.12, 0.05, 0.9)
        card:SetBackdropBorderColor(1, 0.84, 0, 0.6)  -- Faint gold for server events
    else
        card:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
    end

    -- Color stripe on left
    local eventColor = C.CALENDAR_EVENT_COLORS[event.eventType] or C.CALENDAR_EVENT_COLORS.OTHER
    if event.eventColor then
        for _, preset in ipairs(C.CALENDAR_EVENT_COLOR_PRESETS) do
            if preset.key == event.eventColor and preset.color then
                eventColor = preset.color
                break
            end
        end
    end

    local stripe = card:CreateTexture(nil, "ARTWORK")
    stripe:SetColorTexture(eventColor.r, eventColor.g, eventColor.b, 1)
    stripe:SetSize(3, UNIFIED.EVENT_CARD_HEIGHT - 8)
    stripe:SetPoint("LEFT", card, "LEFT", 4, 0)

    -- Event title
    local title = card:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    title:SetPoint("TOPLEFT", stripe, "TOPRIGHT", 6, -4)
    title:SetPoint("RIGHT", card, "RIGHT", -6, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    local titleText = event.title or "Event"
    if event.locked then
        titleText = "|cFFFF4444[L]|r " .. titleText
    end
    title:SetText(titleText)
    title:SetTextColor(0.95, 0.95, 0.95)

    -- Time
    local timeText = card:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    timeText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    timeText:SetText(event.startTime or "TBD")
    timeText:SetTextColor(0.7, 0.7, 0.7)

    -- Signup count or server event indicator
    local infoText = card:CreateFontString(nil, "OVERLAY")
    infoText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    infoText:SetPoint("BOTTOMLEFT", stripe, "BOTTOMRIGHT", 6, 4)

    if isServerEvent then
        infoText:SetText("|cFFFFD700SERVER|r")
    else
        local signupCount = 0
        for _ in pairs(event.signups or {}) do
            signupCount = signupCount + 1
        end
        infoText:SetText(signupCount .. "/" .. (event.raidSize or 10))
        infoText:SetTextColor(0.6, 0.6, 0.6)
    end

    -- Store event reference
    card.event = event

    -- Hover effects
    card:SetScript("OnEnter", function(self)
        if not isSelected then
            self:SetBackdropBorderColor(1, 0.84, 0, 0.8)
        end
    end)
    card:SetScript("OnLeave", function(self)
        if not isSelected then
            if isServerEvent then
                self:SetBackdropBorderColor(1, 0.84, 0, 0.6)
            else
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
            end
        end
    end)

    return card
end

--[[
    Create a "+ Create Event" card for the left panel
    @param parent Frame - Parent frame (leftContent)
    @param isSelected boolean - Whether this card is selected (create mode active)
    @return Frame card
]]
function CalendarUI:CreateUnifiedCreateCard(parent, isSelected)
    local UNIFIED = C.CALENDAR_UNIFIED_POPUP

    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(parent:GetWidth() - 4, UNIFIED.EVENT_CARD_HEIGHT)
    card:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    -- Color based on selection
    if isSelected then
        card:SetBackdropColor(0.15, 0.25, 0.15, 1)
        card:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold border for selected
    else
        card:SetBackdropColor(0.1, 0.18, 0.1, 0.9)
        card:SetBackdropBorderColor(0.4, 0.8, 0.4, 0.8)  -- Green accent
    end

    -- Green "+" stripe on left
    local stripe = card:CreateTexture(nil, "ARTWORK")
    stripe:SetColorTexture(0.3, 0.8, 0.3, 1)
    stripe:SetSize(3, UNIFIED.EVENT_CARD_HEIGHT - 8)
    stripe:SetPoint("LEFT", card, "LEFT", 4, 0)

    -- "+" icon
    local plusIcon = card:CreateFontString(nil, "OVERLAY")
    plusIcon:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    plusIcon:SetPoint("LEFT", stripe, "RIGHT", 6, 0)
    plusIcon:SetText("+")
    plusIcon:SetTextColor(0.5, 1, 0.5)

    -- Title text
    local title = card:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    title:SetPoint("LEFT", plusIcon, "RIGHT", 4, 0)
    title:SetPoint("RIGHT", card, "RIGHT", -6, 0)
    title:SetJustifyH("LEFT")
    title:SetText("Create New Event")
    title:SetTextColor(0.5, 1, 0.5)

    -- Store selection state for hover handling
    card.isSelected = isSelected

    -- Hover effects
    card:SetScript("OnEnter", function(self)
        if not self.isSelected then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end
    end)
    card:SetScript("OnLeave", function(self)
        if not self.isSelected then
            self:SetBackdropBorderColor(0.4, 0.8, 0.4, 0.8)
        end
    end)

    return card
end

--[[
    Populate the left panel with event cards
    @param popup Frame - The unified popup
    @param events table - Array of events
    @param selectedEventId string - ID of selected event (optional)
    @param isCreateMode boolean - Whether create mode is active (optional)
]]
function CalendarUI:PopulateUnifiedLeftPanel(popup, events, selectedEventId, isCreateMode)
    local UNIFIED = C.CALENDAR_UNIFIED_POPUP

    -- Clear existing cards
    for _, card in ipairs(popup.activeLeftCards or {}) do
        card:Hide()
        card:SetParent(nil)
    end
    wipe(popup.activeLeftCards)
    self:ClearContentContainer(popup.leftContent)

    -- Update header
    popup.leftHeader:SetText("EVENTS (" .. #events .. ")")

    local yOffset = 4

    -- Handle no events case - show message but still show create card
    if #events == 0 then
        local noEvents = popup.leftContent:CreateFontString(nil, "OVERLAY")
        noEvents:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        noEvents:SetPoint("TOP", popup.leftContent, "TOP", 0, -15)
        noEvents:SetWidth(popup.leftContent:GetWidth() - 10)
        noEvents:SetText("No events scheduled")
        noEvents:SetTextColor(0.5, 0.5, 0.5)
        noEvents:SetJustifyH("CENTER")

        yOffset = 45
    else
        -- Create event cards
        for _, event in ipairs(events) do
            -- In create mode, no event is selected
            local isSelected = not isCreateMode and (selectedEventId and event.id == selectedEventId)
            local card = self:CreateUnifiedEventCard(popup.leftContent, event, isSelected)
            card:SetPoint("TOPLEFT", popup.leftContent, "TOPLEFT", 2, -yOffset)
            card:Show()

            -- Click handler - select this event
            card:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                popup.selectedEventId = event.id
                popup.currentEvent = event
                popup.isCreateMode = false
                -- Refresh left panel to update selection highlighting
                self:PopulateUnifiedLeftPanel(popup, events, event.id, false)
                -- Populate right panel with selected event
                self:PopulateUnifiedRightPanel(popup, event)
            end)

            table.insert(popup.activeLeftCards, card)
            yOffset = yOffset + UNIFIED.EVENT_CARD_HEIGHT + UNIFIED.EVENT_CARD_SPACING
        end
    end

    -- Add "+ Create Event" card at the bottom
    local createCard = self:CreateUnifiedCreateCard(popup.leftContent, isCreateMode)
    createCard:SetPoint("TOPLEFT", popup.leftContent, "TOPLEFT", 2, -yOffset)
    createCard:Show()

    createCard:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        popup.selectedEventId = nil
        popup.currentEvent = nil
        popup.isCreateMode = true
        self:PopulateUnifiedLeftPanel(popup, events, nil, true)
        self:PopulateUnifiedRightPanelCreate(popup, popup.currentDateStr)
    end)

    table.insert(popup.activeLeftCards, createCard)
    yOffset = yOffset + UNIFIED.EVENT_CARD_HEIGHT + UNIFIED.EVENT_CARD_SPACING

    popup.leftContent:SetHeight(math.max(yOffset, 50))
end

--[[
    Populate the right panel with event details
    @param popup Frame - The unified popup
    @param event table - Event data (or nil for placeholder)
]]
function CalendarUI:PopulateUnifiedRightPanel(popup, event)
    -- Clear existing content
    self:ClearContentContainer(popup.rightPanel)

    -- Clear any previously created child frames
    for _, child in ipairs({ popup.rightPanel:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local rightWidth = popup.rightPanel:GetWidth()

    -- No event selected - show placeholder
    if not event then
        local placeholder = popup.rightPanel:CreateFontString(nil, "OVERLAY")
        placeholder:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
        placeholder:SetPoint("CENTER", popup.rightPanel, "CENTER", 0, 0)
        placeholder:SetText("Select an event to view details")
        placeholder:SetTextColor(0.5, 0.5, 0.5)
        return
    end

    popup.currentEvent = event
    local isServerEvent = Calendar:IsServerEvent(event)
    local isOwner = not isServerEvent and Calendar:IsMyEvent(event.id)
    local isLocked = event.locked == true

    --============================================================
    -- HEADER: Title + Lock indicator
    --============================================================
    local title = popup.rightPanel:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    title:SetPoint("TOP", popup.rightPanel, "TOP", 0, -12)
    title:SetWidth(rightWidth - 20)
    title:SetWordWrap(false)
    local titleText = event.title or "Event"
    if isLocked then
        titleText = titleText .. " |cFFFF4444[LOCKED]|r"
    end
    title:SetText(titleText)
    title:SetTextColor(1, 0.84, 0)

    -- Subtitle (event type + size)
    local eventType = C.CALENDAR_EVENT_TYPES[event.eventType] or C.CALENDAR_EVENT_TYPES.OTHER
    local subtitle = popup.rightPanel:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)

    if isServerEvent then
        subtitle:SetText("|cFFFFD700SERVER EVENT|r")
    else
        local lfParts = {}
        if (event.maxTanks or 0) > 0 then table.insert(lfParts, event.maxTanks .. "T") end
        if (event.maxHealers or 0) > 0 then table.insert(lfParts, event.maxHealers .. "H") end
        if (event.maxDPS or 0) > 0 then table.insert(lfParts, event.maxDPS .. "D") end
        local lfText = #lfParts > 0 and ("LF: " .. table.concat(lfParts, " ")) or ""
        subtitle:SetText(eventType.name:upper() .. " - " .. (event.raidSize or 10) .. "-man" .. (#lfParts > 0 and (" - " .. lfText) or ""))
    end
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    --============================================================
    -- INFO CARDS (When / Organizer)
    --============================================================
    local cardWidth = 170
    local cardHeight = 75
    local cardSpacing = 10
    local cardsTopOffset = -55

    -- WHEN card
    local whenCard = CreateFrame("Frame", nil, popup.rightPanel, "BackdropTemplate")
    whenCard:SetSize(cardWidth, cardHeight)
    whenCard:SetPoint("TOP", popup.rightPanel, "TOP", -cardWidth/2 - cardSpacing/2, cardsTopOffset)
    whenCard:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    whenCard:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
    whenCard:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local whenLabel = whenCard:CreateFontString(nil, "OVERLAY")
    whenLabel:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    whenLabel:SetPoint("TOPLEFT", whenCard, "TOPLEFT", 8, -6)
    whenLabel:SetText("WHEN")
    whenLabel:SetTextColor(1, 0.84, 0)

    -- Parse date
    local year, month, day = Calendar:ParseDate(event.date)
    local dayName = ""
    local monthName = ""
    if year then
        dayName = date("%A", time({ year = year, month = month, day = day }))
        monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    end

    local dayNameText = whenCard:CreateFontString(nil, "OVERLAY")
    dayNameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    dayNameText:SetPoint("TOPLEFT", whenLabel, "BOTTOMLEFT", 0, -4)
    dayNameText:SetText(dayName)
    dayNameText:SetTextColor(0.9, 0.9, 0.9)

    local dateText = whenCard:CreateFontString(nil, "OVERLAY")
    dateText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    dateText:SetPoint("TOPLEFT", dayNameText, "BOTTOMLEFT", 0, -2)
    dateText:SetText(monthName .. " " .. (day or ""))
    dateText:SetTextColor(0.8, 0.8, 0.8)

    -- Time display
    local realmTime, localTime = Calendar:GetDualTimes(event.startTime)
    local timeDisplay = whenCard:CreateFontString(nil, "OVERLAY")
    timeDisplay:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    timeDisplay:SetPoint("TOPLEFT", dateText, "BOTTOMLEFT", 0, -4)
    if realmTime then
        timeDisplay:SetText(realmTime .. " (Realm)")
    else
        timeDisplay:SetText(event.startTime or "TBD")
    end
    timeDisplay:SetTextColor(0.9, 0.9, 0.9)

    -- ORGANIZER card (only for guild events)
    local orgCard = CreateFrame("Frame", nil, popup.rightPanel, "BackdropTemplate")
    orgCard:SetSize(cardWidth, cardHeight)
    orgCard:SetPoint("TOP", popup.rightPanel, "TOP", cardWidth/2 + cardSpacing/2, cardsTopOffset)
    orgCard:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    orgCard:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
    orgCard:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local orgLabel = orgCard:CreateFontString(nil, "OVERLAY")
    orgLabel:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    orgLabel:SetPoint("TOPLEFT", orgCard, "TOPLEFT", 8, -6)
    orgLabel:SetText("ORGANIZER")
    orgLabel:SetTextColor(1, 0.84, 0)

    if isServerEvent then
        local serverText = orgCard:CreateFontString(nil, "OVERLAY")
        serverText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
        serverText:SetPoint("TOPLEFT", orgLabel, "BOTTOMLEFT", 0, -6)
        serverText:SetText("|cFFFFD700Server|r")

        local infoText = orgCard:CreateFontString(nil, "OVERLAY")
        infoText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        infoText:SetPoint("TOPLEFT", serverText, "BOTTOMLEFT", 0, -4)
        infoText:SetText("No signup required")
        infoText:SetTextColor(0.6, 0.6, 0.6)
    else
        local leaderName = orgCard:CreateFontString(nil, "OVERLAY")
        leaderName:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
        leaderName:SetPoint("TOPLEFT", orgLabel, "BOTTOMLEFT", 0, -6)
        if event.leader then
            local classColor = RAID_CLASS_COLORS[event.leaderClass] or { r = 0.9, g = 0.9, b = 0.9 }
            local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
            leaderName:SetText("|cFF" .. colorHex .. event.leader .. "|r")
        else
            leaderName:SetText("Unknown")
            leaderName:SetTextColor(0.9, 0.9, 0.9)
        end

        if event.leaderGuild and event.leaderGuild ~= "" then
            local guildText = orgCard:CreateFontString(nil, "OVERLAY")
            guildText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
            guildText:SetPoint("TOPLEFT", leaderName, "BOTTOMLEFT", 0, -4)
            guildText:SetText("<" .. event.leaderGuild .. ">")
            guildText:SetTextColor(0.6, 0.6, 0.6)
        end
    end

    --============================================================
    -- DESCRIPTION
    --============================================================
    local descTopOffset = cardsTopOffset - cardHeight - 10

    if event.description and event.description ~= "" then
        local descLabel = popup.rightPanel:CreateFontString(nil, "OVERLAY")
        descLabel:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        descLabel:SetPoint("TOPLEFT", popup.rightPanel, "TOPLEFT", 15, descTopOffset)
        descLabel:SetText("DESCRIPTION")
        descLabel:SetTextColor(1, 0.84, 0)

        local descContainer = CreateFrame("Frame", nil, popup.rightPanel, "BackdropTemplate")
        descContainer:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -4)
        descContainer:SetPoint("RIGHT", popup.rightPanel, "RIGHT", -15, 0)
        descContainer:SetHeight(40)
        descContainer:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        descContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
        descContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)

        local descText = descContainer:CreateFontString(nil, "OVERLAY")
        descText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        descText:SetPoint("TOPLEFT", descContainer, "TOPLEFT", 6, -6)
        descText:SetPoint("BOTTOMRIGHT", descContainer, "BOTTOMRIGHT", -6, 6)
        descText:SetJustifyH("LEFT")
        descText:SetJustifyV("TOP")
        descText:SetText(event.description)
        descText:SetTextColor(0.85, 0.85, 0.85)

        descTopOffset = descTopOffset - 60
    end

    -- Server event - show info text and stop here
    if isServerEvent then
        local infoText = popup.rightPanel:CreateFontString(nil, "OVERLAY")
        infoText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        infoText:SetPoint("BOTTOM", popup.rightPanel, "BOTTOM", 0, 20)
        infoText:SetText("|cFF888888This is a server-wide announcement.\nNo signup required.|r")
        infoText:SetJustifyH("CENTER")
        return
    end

    --============================================================
    -- LOOKING FOR SECTION (Guild events only)
    --============================================================
    local lookingForTopOffset = descTopOffset - 5

    -- Divider
    local lfDivider = popup.rightPanel:CreateTexture(nil, "ARTWORK")
    lfDivider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    lfDivider:SetHeight(2)
    lfDivider:SetPoint("LEFT", popup.rightPanel, "LEFT", 10, 0)
    lfDivider:SetPoint("RIGHT", popup.rightPanel, "RIGHT", -10, 0)
    lfDivider:SetPoint("TOP", popup.rightPanel, "TOP", 0, lookingForTopOffset)
    lfDivider:SetVertexColor(0.5, 0.5, 0.5, 0.5)

    -- Looking For header
    local lfHeader = popup.rightPanel:CreateFontString(nil, "OVERLAY")
    lfHeader:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    lfHeader:SetPoint("TOPLEFT", lfDivider, "BOTTOMLEFT", 5, -6)
    lfHeader:SetText("LOOKING FOR")
    lfHeader:SetTextColor(1, 0.84, 0)

    -- Role boxes container
    local roleBoxContainer = CreateFrame("Frame", nil, popup.rightPanel)
    roleBoxContainer:SetSize(320, 60)
    roleBoxContainer:SetPoint("TOP", lfHeader, "BOTTOM", 0, -8)
    roleBoxContainer:SetPoint("LEFT", popup.rightPanel, "LEFT", 10, 0)
    roleBoxContainer:SetPoint("RIGHT", popup.rightPanel, "RIGHT", -10, 0)

    -- Create role boxes
    local roleOrder = { "tank", "healer", "dps" }
    local boxWidth = 85
    local boxSpacing = 10
    local totalWidth = (boxWidth * 3) + (boxSpacing * 2)
    local startX = (roleBoxContainer:GetWidth() - totalWidth) / 2

    for i, roleKey in ipairs(roleOrder) do
        local roleData = C.CALENDAR_ROLES[roleKey]
        local color = roleData.color
        local needed = event["max" .. roleKey:sub(1,1):upper() .. roleKey:sub(2) .. "s"] or 0
        if roleKey == "dps" then needed = event.maxDPS or 5 end
        if roleKey == "tank" then needed = event.maxTanks or 2 end
        if roleKey == "healer" then needed = event.maxHealers or 3 end

        local box = CreateFrame("Frame", nil, roleBoxContainer, "BackdropTemplate")
        box:SetSize(boxWidth, 50)
        box:SetPoint("TOPLEFT", roleBoxContainer, "TOPLEFT", startX + (i - 1) * (boxWidth + boxSpacing), 0)
        box:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        box:SetBackdropColor(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.9)
        box:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.8)

        -- Number
        local numText = box:CreateFontString(nil, "OVERLAY")
        numText:SetFont(HopeAddon.assets.fonts.HEADER, 18, "")
        numText:SetPoint("TOP", box, "TOP", 0, -6)
        numText:SetText(tostring(needed))
        numText:SetTextColor(color.r, color.g, color.b)

        -- Role name
        local roleText = box:CreateFontString(nil, "OVERLAY")
        roleText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        roleText:SetPoint("BOTTOM", box, "BOTTOM", 0, 6)
        roleText:SetText(roleData.name:upper())
        roleText:SetTextColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
    end

    --============================================================
    -- DISCORD CTA SECTION
    --============================================================
    local discordBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
    discordBtn:SetSize(280, 40)
    discordBtn:SetPoint("TOP", roleBoxContainer, "BOTTOM", 0, -15)
    discordBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    discordBtn:SetBackdropColor(0.2, 0.25, 0.35, 1)
    discordBtn:SetBackdropBorderColor(0.4, 0.5, 0.8, 1)

    local discordIcon = discordBtn:CreateFontString(nil, "OVERLAY")
    discordIcon:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    discordIcon:SetPoint("TOP", discordBtn, "TOP", 0, -6)
    discordIcon:SetText("|cFF7289DAJOIN US ON DISCORD|r")

    local discordSubtext = discordBtn:CreateFontString(nil, "OVERLAY")
    discordSubtext:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    discordSubtext:SetPoint("BOTTOM", discordBtn, "BOTTOM", 0, 6)

    if event.discordLink and event.discordLink ~= "" then
        discordSubtext:SetText("|cFF888888Click to copy invite link|r")
        discordBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            -- Copy to clipboard (WoW doesn't have real clipboard, so we show an edit box)
            local copyFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            copyFrame:SetSize(350, 80)
            copyFrame:SetPoint("CENTER")
            copyFrame:SetFrameStrata("DIALOG")
            copyFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
                edgeSize = 24,
                insets = { left = 6, right = 6, top = 6, bottom = 6 },
            })
            copyFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.98)

            local titleText = copyFrame:CreateFontString(nil, "OVERLAY")
            titleText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
            titleText:SetPoint("TOP", copyFrame, "TOP", 0, -12)
            titleText:SetText("Discord Link - Press Ctrl+C to copy")
            titleText:SetTextColor(1, 0.84, 0)

            local editBox = CreateFrame("EditBox", nil, copyFrame, "InputBoxTemplate")
            editBox:SetSize(310, 20)
            editBox:SetPoint("CENTER", copyFrame, "CENTER", 0, -5)
            editBox:SetAutoFocus(true)
            editBox:SetText(event.discordLink)
            editBox:HighlightText()
            editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
            editBox:SetScript("OnEnterPressed", function() copyFrame:Hide() end)

            local closeBtn = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
            closeBtn:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT", -2, -2)
            closeBtn:SetScript("OnClick", function() copyFrame:Hide() end)

            HopeAddon:Print("|cFF7289DADiscord link ready to copy!|r")
        end)
    else
        discordSubtext:SetText("|cFF666666No Discord link provided|r")
        discordBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
        discordBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
        discordIcon:SetTextColor(0.5, 0.5, 0.5)
    end

    discordBtn:SetScript("OnEnter", function(self)
        if event.discordLink and event.discordLink ~= "" then
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end
    end)
    discordBtn:SetScript("OnLeave", function(self)
        if event.discordLink and event.discordLink ~= "" then
            self:SetBackdropBorderColor(0.4, 0.5, 0.8, 1)
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
        end
    end)

    -- Owner buttons (Save Template, Lock, Delete)
    if isOwner then
        -- Save as Template
        local saveTemplateBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
        saveTemplateBtn:SetSize(100, 24)
        saveTemplateBtn:SetPoint("BOTTOMLEFT", popup.rightPanel, "BOTTOMLEFT", 10, 10)
        saveTemplateBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        saveTemplateBtn:SetBackdropColor(0.2, 0.25, 0.3, 1)
        saveTemplateBtn:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)

        local saveText = saveTemplateBtn:CreateFontString(nil, "OVERLAY")
        saveText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
        saveText:SetPoint("CENTER")
        saveText:SetText("Save Template")
        saveText:SetTextColor(0.6, 0.8, 1)

        saveTemplateBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        saveTemplateBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)
        end)
        saveTemplateBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            CalendarUI:ShowSaveTemplateDialog(event)
        end)

        -- Lock/Unlock button
        local lockBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
        lockBtn:SetSize(70, 24)
        lockBtn:SetPoint("LEFT", saveTemplateBtn, "RIGHT", 6, 0)
        lockBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        local lockText = lockBtn:CreateFontString(nil, "OVERLAY")
        lockText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
        lockText:SetPoint("CENTER")

        if isLocked then
            lockBtn:SetBackdropColor(0.2, 0.3, 0.2, 1)
            lockBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
            lockText:SetText("Unlock")
            lockText:SetTextColor(0.6, 0.9, 0.6)
        else
            lockBtn:SetBackdropColor(0.3, 0.25, 0.2, 1)
            lockBtn:SetBackdropBorderColor(0.8, 0.6, 0.4, 1)
            lockText:SetText("Lock")
            lockText:SetTextColor(0.8, 0.6, 0.4)
        end

        lockBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        lockBtn:SetScript("OnLeave", function(self)
            if isLocked then
                self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
            else
                self:SetBackdropBorderColor(0.8, 0.6, 0.4, 1)
            end
        end)
        lockBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            if isLocked then
                local success, err = Calendar:UnlockEvent(event.id)
                if success then
                    HopeAddon:Print("|cFF00FF00Event unlocked|r - signups are now open")
                    self:RefreshUnifiedRightPanel()
                else
                    HopeAddon:Print("|cFFFF0000Failed to unlock:|r " .. (err or "Unknown error"))
                end
            else
                local success, err = Calendar:LockEvent(event.id)
                if success then
                    HopeAddon:Print("|cFFFFAA00Event locked|r - signups are now closed")
                    self:RefreshUnifiedRightPanel()
                else
                    HopeAddon:Print("|cFFFF0000Failed to lock:|r " .. (err or "Unknown error"))
                end
            end
        end)

        -- Delete button
        local deleteBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
        deleteBtn:SetSize(60, 24)
        deleteBtn:SetPoint("LEFT", lockBtn, "RIGHT", 6, 0)
        deleteBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        deleteBtn:SetBackdropColor(0.3, 0.15, 0.15, 1)
        deleteBtn:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)

        local deleteText = deleteBtn:CreateFontString(nil, "OVERLAY")
        deleteText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
        deleteText:SetPoint("CENTER")
        deleteText:SetText("Delete")
        deleteText:SetTextColor(1, 0.4, 0.4)

        deleteBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        deleteBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
        end)
        deleteBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            StaticPopup_Show("HOPE_CONFIRM_DELETE_EVENT", event.title, nil, {
                eventId = event.id,
                popup = popup
            })
        end)

        -- Export button
        local exportBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
        exportBtn:SetSize(60, 24)
        exportBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 6, 0)
        exportBtn:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        exportBtn:SetBackdropColor(0.2, 0.25, 0.3, 1)
        exportBtn:SetBackdropBorderColor(0.4, 0.5, 0.7, 1)

        local exportText = exportBtn:CreateFontString(nil, "OVERLAY")
        exportText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
        exportText:SetPoint("CENTER")
        exportText:SetText("Export")
        exportText:SetTextColor(0.6, 0.7, 0.9)

        exportBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        exportBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.4, 0.5, 0.7, 1)
        end)
        exportBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            local text = Calendar:ExportEventDetails(event)
            Calendar:ShowExportPopup(text)
        end)
    end

    -- Close button at bottom right
    local closeBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
    closeBtn:SetSize(70, 24)
    closeBtn:SetPoint("BOTTOMRIGHT", popup.rightPanel, "BOTTOMRIGHT", -10, 10)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    closeBtn:SetBackdropColor(0.2, 0.2, 0.2, 1)
    closeBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    closeText:SetPoint("CENTER")
    closeText:SetText("Close")
    closeText:SetTextColor(0.8, 0.8, 0.8)

    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end)
end

--[[
    Populate the right panel with the create event form
    @param popup Frame - The unified popup
    @param dateStr string - The date to pre-fill (YYYY-MM-DD format)
]]
function CalendarUI:PopulateUnifiedRightPanelCreate(popup, dateStr)
    -- Clear existing content
    self:ClearContentContainer(popup.rightPanel)

    -- Clear any previously created child frames
    for _, child in ipairs({ popup.rightPanel:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local rightWidth = popup.rightPanel:GetWidth()
    popup.createForm = {}

    -- Parse date for pre-filling
    local targetMonth, targetDay, targetYear
    if dateStr then
        local y, m, d = Calendar:ParseDate(dateStr)
        if y then
            targetYear = y
            targetMonth = m
            targetDay = d
        end
    end

    -- Fall back to current date if not provided
    if not targetMonth then
        targetMonth = currentMonth
        targetDay = tonumber(date("%d"))
        targetYear = currentYear
    end

    --============================================================
    -- HEADER: Create New Event
    --============================================================
    local title = popup.rightPanel:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.TITLE, 14, "")
    title:SetPoint("TOP", popup.rightPanel, "TOP", 0, -10)
    title:SetText("CREATE NEW EVENT")
    title:SetTextColor(0.5, 1, 0.5)

    -- Scrollable content area for the form
    local scrollFrame = CreateFrame("ScrollFrame", nil, popup.rightPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", popup.rightPanel, "TOPLEFT", 5, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", popup.rightPanel, "BOTTOMRIGHT", -25, 45)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(rightWidth - 40)
    content:SetHeight(450)
    scrollFrame:SetScrollChild(content)

    local yOffset = 0
    local fieldWidth = rightWidth - 55

    --============================================================
    -- ACTIVITY DROPDOWN (Raids + Dungeons)
    --============================================================
    local activityLabel = content:CreateFontString(nil, "OVERLAY")
    activityLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    activityLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    activityLabel:SetText("Activity:")
    activityLabel:SetTextColor(0.8, 0.8, 0.8)

    local activityOptions = {}
    for _, opt in ipairs(C.CALENDAR_RAID_OPTIONS) do
        table.insert(activityOptions, opt.name)
    end
    popup.createForm.activityDropdown = self:CreateSimpleDropdown(content, activityOptions, 1)
    popup.createForm.activityDropdown:SetPoint("TOPLEFT", activityLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.activityDropdown:SetSize(fieldWidth, 26)

    yOffset = yOffset + 52

    --============================================================
    -- CUSTOM SIZE CONTAINER (shown when "Custom Event" selected)
    --============================================================
    popup.createForm.customSizeContainer = CreateFrame("Frame", nil, content)
    popup.createForm.customSizeContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    popup.createForm.customSizeContainer:SetSize(fieldWidth, 50)
    popup.createForm.customSizeContainer:Hide()

    local customSizeLabel = popup.createForm.customSizeContainer:CreateFontString(nil, "OVERLAY")
    customSizeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    customSizeLabel:SetPoint("TOPLEFT", popup.createForm.customSizeContainer, "TOPLEFT", 0, 0)
    customSizeLabel:SetText("Custom Size:")
    customSizeLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.createForm.customSizeDropdown = self:CreateSimpleDropdown(popup.createForm.customSizeContainer, { "5-man", "10-man", "15-man", "20-man", "25-man", "40-man" }, 2)
    popup.createForm.customSizeDropdown:SetPoint("TOPLEFT", customSizeLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.customSizeDropdown:SetSize(100, 26)

    -- Auto-show/hide custom size based on activity selection
    popup.createForm.activityDropdown.onSelect = function(index)
        local activityOption = C.CALENDAR_RAID_OPTIONS[index]
        if activityOption and activityOption.key == "custom" then
            popup.createForm.customSizeContainer:Show()
        else
            popup.createForm.customSizeContainer:Hide()
        end
    end

    --============================================================
    -- TITLE INPUT
    --============================================================
    local titleLabel = content:CreateFontString(nil, "OVERLAY")
    titleLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    titleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    titleLabel:SetText("Title (optional):")
    titleLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.createForm.titleInput = CreateFrame("EditBox", nil, content, "BackdropTemplate")
    popup.createForm.titleInput:SetSize(fieldWidth, 24)
    popup.createForm.titleInput:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.titleInput:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    popup.createForm.titleInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
    popup.createForm.titleInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    popup.createForm.titleInput:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    popup.createForm.titleInput:SetTextColor(0.9, 0.9, 0.9)
    popup.createForm.titleInput:SetTextInsets(8, 8, 0, 0)
    popup.createForm.titleInput:SetAutoFocus(false)
    popup.createForm.titleInput:SetMaxLetters(50)

    yOffset = yOffset + 52

    --============================================================
    -- DATE SELECTION
    --============================================================
    local dateLabel = content:CreateFontString(nil, "OVERLAY")
    dateLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    dateLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    dateLabel:SetText("Date:")
    dateLabel:SetTextColor(0.8, 0.8, 0.8)

    local UI = C.CALENDAR_UI

    -- Month dropdown
    popup.createForm.monthDropdown = self:CreateSimpleDropdown(content, UI.MONTH_NAMES, targetMonth)
    popup.createForm.monthDropdown:SetPoint("TOPLEFT", dateLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.monthDropdown:SetSize(80, 26)

    -- Day dropdown
    local days = {}
    for i = 1, 31 do table.insert(days, tostring(i)) end
    popup.createForm.dayDropdown = self:CreateSimpleDropdown(content, days, targetDay)
    popup.createForm.dayDropdown:SetPoint("LEFT", popup.createForm.monthDropdown, "RIGHT", 5, 0)
    popup.createForm.dayDropdown:SetSize(45, 26)

    -- Year dropdown
    local thisYear = tonumber(date("%Y"))
    local years = {}
    for i = 0, 4 do
        table.insert(years, tostring(thisYear + i))
    end
    local yearIndex = (targetYear == thisYear) and 1 or 2
    popup.createForm.yearDropdown = self:CreateSimpleDropdown(content, years, yearIndex)
    popup.createForm.yearDropdown:SetPoint("LEFT", popup.createForm.dayDropdown, "RIGHT", 5, 0)
    popup.createForm.yearDropdown:SetSize(60, 26)

    yOffset = yOffset + 52

    --============================================================
    -- TIME SELECTION
    --============================================================
    local timeLabel = content:CreateFontString(nil, "OVERLAY")
    timeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    timeLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    timeLabel:SetText("Time:")
    timeLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Hour dropdown
    local hours = {}
    for i = 1, 12 do table.insert(hours, tostring(i)) end
    popup.createForm.hourDropdown = self:CreateSimpleDropdown(content, hours, 7)
    popup.createForm.hourDropdown:SetPoint("TOPLEFT", timeLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.hourDropdown:SetSize(45, 26)

    -- Minute dropdown
    popup.createForm.minuteDropdown = self:CreateSimpleDropdown(content, { "00", "15", "30", "45" }, 1)
    popup.createForm.minuteDropdown:SetPoint("LEFT", popup.createForm.hourDropdown, "RIGHT", 2, 0)
    popup.createForm.minuteDropdown:SetSize(45, 26)

    -- AM/PM dropdown
    popup.createForm.ampmDropdown = self:CreateSimpleDropdown(content, { "PM", "AM" }, 1)
    popup.createForm.ampmDropdown:SetPoint("LEFT", popup.createForm.minuteDropdown, "RIGHT", 5, 0)
    popup.createForm.ampmDropdown:SetSize(45, 26)

    yOffset = yOffset + 52

    --============================================================
    -- DESCRIPTION INPUT
    --============================================================
    local descLabel = content:CreateFontString(nil, "OVERLAY")
    descLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    descLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    descLabel:SetText("Description (100 char max):")
    descLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.createForm.descInput = CreateFrame("EditBox", nil, content, "BackdropTemplate")
    popup.createForm.descInput:SetSize(fieldWidth, 40)
    popup.createForm.descInput:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.descInput:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    popup.createForm.descInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
    popup.createForm.descInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    popup.createForm.descInput:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    popup.createForm.descInput:SetTextColor(0.9, 0.9, 0.9)
    popup.createForm.descInput:SetTextInsets(8, 8, 4, 4)
    popup.createForm.descInput:SetAutoFocus(false)
    popup.createForm.descInput:SetMaxLetters(100)
    popup.createForm.descInput:SetMultiLine(true)

    yOffset = yOffset + 68

    --============================================================
    -- EVENT COLOR DROPDOWN
    --============================================================
    local colorLabel = content:CreateFontString(nil, "OVERLAY")
    colorLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    colorLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    colorLabel:SetText("Event Color:")
    colorLabel:SetTextColor(0.8, 0.8, 0.8)

    local colorOptions = {}
    for _, preset in ipairs(C.CALENDAR_EVENT_COLOR_PRESETS) do
        table.insert(colorOptions, preset.name)
    end
    popup.createForm.colorDropdown = self:CreateSimpleDropdown(content, colorOptions, 1)
    popup.createForm.colorDropdown:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.colorDropdown:SetSize(110, 26)

    -- Color preview swatch
    popup.createForm.colorSwatch = content:CreateTexture(nil, "ARTWORK")
    popup.createForm.colorSwatch:SetSize(20, 20)
    popup.createForm.colorSwatch:SetPoint("LEFT", popup.createForm.colorDropdown, "RIGHT", 8, 0)
    popup.createForm.colorSwatch:SetColorTexture(1, 0.5, 0, 1)  -- Default orange

    -- Update swatch when color changes
    popup.createForm.colorDropdown.onSelect = function(index)
        local preset = C.CALENDAR_EVENT_COLOR_PRESETS[index]
        if preset and preset.color then
            popup.createForm.colorSwatch:SetColorTexture(preset.color.r, preset.color.g, preset.color.b, 1)
        else
            popup.createForm.colorSwatch:SetColorTexture(1, 0.5, 0, 1)
        end
    end

    yOffset = yOffset + 35

    -- Discord Link input (optional)
    local discordLabel = content:CreateFontString(nil, "OVERLAY")
    discordLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    discordLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    discordLabel:SetText("Discord Link (optional):")
    discordLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.createForm.discordInput = Components:CreateEditBox(content, 260, 26)
    popup.createForm.discordInput:SetPoint("TOPLEFT", discordLabel, "BOTTOMLEFT", 0, -4)
    popup.createForm.discordInput:SetMaxLetters(200)

    yOffset = yOffset + 50

    -- Update content height
    content:SetHeight(yOffset + 30)

    --============================================================
    -- BOTTOM BUTTONS (outside scroll)
    --============================================================
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMLEFT", popup.rightPanel, "BOTTOMLEFT", 10, 10)
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
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        -- Switch back to first event or placeholder
        local events = Calendar:GetEventsForDate(popup.currentDateStr)
        popup.isCreateMode = false
        if #events > 0 then
            popup.selectedEventId = events[1].id
            popup.currentEvent = events[1]
            self:PopulateUnifiedLeftPanel(popup, events, events[1].id, false)
            self:PopulateUnifiedRightPanel(popup, events[1])
        else
            popup.selectedEventId = nil
            popup.currentEvent = nil
            self:PopulateUnifiedLeftPanel(popup, events, nil, false)
            self:PopulateUnifiedRightPanel(popup, nil)
        end
    end)
    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.6, 0.4, 0.4, 1)
    end)

    -- Create button
    local createBtn = CreateFrame("Button", nil, popup.rightPanel, "BackdropTemplate")
    createBtn:SetSize(100, 28)
    createBtn:SetPoint("BOTTOMRIGHT", popup.rightPanel, "BOTTOMRIGHT", -10, 10)
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
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:HandleUnifiedCreateEvent(popup)
    end)
    createBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    createBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
    end)
end

--[[
    Handle event creation from the unified popup create form
    @param popup Frame - The unified popup with createForm data
]]
function CalendarUI:HandleUnifiedCreateEvent(popup)
    if not popup or not popup.createForm then return end

    local form = popup.createForm

    -- Gather form data - infer event type from activity selection
    local activityIndex = form.activityDropdown:GetValue()
    local activityOption = C.CALENDAR_RAID_OPTIONS[activityIndex]
    local eventType = activityOption and activityOption.eventType or "OTHER"

    local raidOption = activityOption  -- Same thing, just renamed for clarity below

    local title = form.titleInput:GetText()
    if title == "" then
        title = raidOption and raidOption.name or "Event"
    end

    local monthIndex = form.monthDropdown:GetValue()
    local dayIndex = form.dayDropdown:GetValue()
    local yearIndex, yearStr = form.yearDropdown:GetValue()
    local year = tonumber(yearStr)

    local dateStr = string.format("%04d-%02d-%02d", year, monthIndex, dayIndex)

    local hourIndex = form.hourDropdown:GetValue()
    local minuteIndex = form.minuteDropdown:GetValue()
    local ampmIndex = form.ampmDropdown:GetValue()
    local minutes = { "00", "15", "30", "45" }

    local hour = hourIndex
    if ampmIndex == 1 then  -- PM
        if hour < 12 then hour = hour + 12 end
    else  -- AM
        if hour == 12 then hour = 0 end
    end

    local startTime = string.format("%02d:%s", hour, minutes[minuteIndex])

    -- Determine raid size
    local raidSize = 10
    local maxTanks, maxHealers, maxDPS = 2, 3, 5

    if raidOption and raidOption.key == "custom" then
        local customSizeIndex = form.customSizeDropdown and form.customSizeDropdown:GetValue() or 2
        local customSizes = { 5, 10, 15, 20, 25, 40 }
        raidSize = customSizes[customSizeIndex] or 10

        if raidSize == 5 then
            maxTanks, maxHealers, maxDPS = 1, 1, 3
        elseif raidSize == 10 then
            maxTanks, maxHealers, maxDPS = 2, 3, 5
        elseif raidSize == 15 then
            maxTanks, maxHealers, maxDPS = 2, 4, 9
        elseif raidSize == 20 then
            maxTanks, maxHealers, maxDPS = 3, 5, 12
        elseif raidSize == 25 then
            maxTanks, maxHealers, maxDPS = 3, 7, 15
        elseif raidSize == 40 then
            maxTanks, maxHealers, maxDPS = 4, 12, 24
        end
    elseif raidOption and raidOption.size then
        raidSize = raidOption.size
        if raidOption.size == 10 then
            maxTanks, maxHealers, maxDPS = 2, 3, 5
        elseif raidOption.size == 25 then
            maxTanks, maxHealers, maxDPS = 3, 7, 15
        elseif raidOption.size == 5 then
            maxTanks, maxHealers, maxDPS = 1, 1, 3
        end
    end

    local description = form.descInput:GetText()

    -- Get event color preset
    local colorIndex = form.colorDropdown and form.colorDropdown:GetValue() or 1
    local colorPreset = C.CALENDAR_EVENT_COLOR_PRESETS[colorIndex]
    local eventColor = (colorPreset and colorPreset.key ~= "default") and colorPreset.key or nil

    -- Get Discord link (optional)
    local discordLink = form.discordInput and form.discordInput:GetText() or ""
    if discordLink == "" then discordLink = nil end

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
        eventColor = eventColor,
        discordLink = discordLink,
    })

    if eventId then
        HopeAddon:Print("|cFF00FF00Event created:|r " .. title)

        -- Refresh calendar grids
        if monthGrid then
            self:PopulateMonthGrid(monthGrid)
        end
        if weekCalendar then
            self:PopulateWeekCalendar(weekCalendar)
        end

        -- Switch to showing the new event
        popup.isCreateMode = false
        local events = Calendar:GetEventsForDate(dateStr)

        -- Find the new event
        local newEvent = nil
        for _, e in ipairs(events) do
            if e.id == eventId then
                newEvent = e
                break
            end
        end

        popup.currentDateStr = dateStr
        popup.selectedEventId = eventId
        popup.currentEvent = newEvent

        -- Update header with new date if it changed
        local year, month, day = Calendar:ParseDate(dateStr)
        if year then
            local dayName = date("%A", time({ year = year, month = month, day = day }))
            local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
            popup.dateHeader:SetText(dayName .. ", " .. monthName .. " " .. day)
        end

        -- Refresh panels
        self:PopulateUnifiedLeftPanel(popup, events, eventId, false)
        self:PopulateUnifiedRightPanel(popup, newEvent)
    else
        HopeAddon:Print("|cFFFF0000Failed to create event:|r " .. (err or "Unknown error"))
    end
end

--[[
    Refresh the right panel with current event data
    Used after signup, lock/unlock, or other state changes
]]
function CalendarUI:RefreshUnifiedRightPanel()
    local popup = unifiedDayPopup
    if not popup or not popup:IsShown() then return end

    -- Don't refresh if in create mode
    if popup.isCreateMode then return end

    local event = popup.currentEvent
    if not event then return end

    -- Re-fetch the event to get updated data
    local events = Calendar:GetEventsForDate(popup.currentDateStr)
    for _, e in ipairs(events) do
        if e.id == event.id then
            event = e
            popup.currentEvent = e
            break
        end
    end

    -- Refresh both panels
    self:PopulateUnifiedLeftPanel(popup, events, event.id, false)
    self:PopulateUnifiedRightPanel(popup, event)
end

--[[
    Show unified day popup for a specific date
    @param dateStr string - YYYY-MM-DD format
    @param selectedEventId string - Optional ID of event to pre-select
    @param openCreateMode boolean - Optional, if true opens in create mode
]]
function CalendarUI:ShowUnifiedDayPopup(dateStr, selectedEventId, openCreateMode)
    if not dateStr then return end

    local popup = self:GetUnifiedDayPopup()

    -- Parse date for display
    local year, month, day = Calendar:ParseDate(dateStr)
    if not year then return end

    local dayName = date("%A", time({ year = year, month = month, day = day }))
    local monthName = C.CALENDAR_UI.MONTH_NAMES[month]
    local displayDate = dayName .. ", " .. monthName .. " " .. day

    -- Store current date
    popup.currentDateStr = dateStr

    -- Update header
    popup.dateHeader:SetText(displayDate)

    -- Get events for this date
    local events = Calendar:GetEventsForDate(dateStr)

    -- Handle create mode
    if openCreateMode then
        popup.isCreateMode = true
        popup.selectedEventId = nil
        popup.currentEvent = nil

        -- Populate left panel with create card selected
        self:PopulateUnifiedLeftPanel(popup, events, nil, true)

        -- Populate right panel with create form
        self:PopulateUnifiedRightPanelCreate(popup, dateStr)

        popup:Show()
        return
    end

    -- Normal mode - determine which event to select
    popup.isCreateMode = false
    local eventToSelect = nil
    if selectedEventId then
        -- Find the specified event
        for _, event in ipairs(events) do
            if event.id == selectedEventId then
                eventToSelect = event
                break
            end
        end
    end

    -- If no specified event or not found, select first event
    if not eventToSelect and #events > 0 then
        eventToSelect = events[1]
    end

    popup.selectedEventId = eventToSelect and eventToSelect.id or nil
    popup.currentEvent = eventToSelect

    -- Populate left panel
    self:PopulateUnifiedLeftPanel(popup, events, popup.selectedEventId, false)

    -- Populate right panel
    self:PopulateUnifiedRightPanel(popup, eventToSelect)

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
    -- Clear existing content (children + regions like font strings and textures)
    self:ClearContentContainer(content)

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

    -- Get alternate counts by role
    local altCounts = Calendar:GetAlternateCountsByRole(event)

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

        -- Build header text with alternate count
        local headerText = roleData.name:upper() .. " (" .. roleCount.current .. "/" .. roleCount.max .. ")"
        local altCount = altCounts[roleKey] or 0
        if altCount > 0 then
            headerText = headerText .. " |cFFFFAA00+" .. altCount .. " alts|r"
        end

        header:SetText(headerText)
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
                    statusIcon = "|cFF00FF00[+]|r "  -- Green confirmed
                else
                    statusIcon = "|cFFFFAA00[?]|r "  -- Orange tentative
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

--[[
    Create a clickable player entry for roster management
    @param parent Frame - Parent frame
    @param playerData table - Player signup data with name, class, role
    @param event table - Event data
    @param xOffset number - X position offset
    @param yOffset number - Y position offset (negative)
    @return Button - The clickable player button
]]
function CalendarUI:CreateRosterPlayerEntry(parent, playerData, event, xOffset, yOffset)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(95, 16)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, -yOffset)

    btn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    -- Get roster status
    local rosterStatus = event.roster and event.roster[playerData.name] or "TEAM"
    local statusData = C.CALENDAR_ROSTER_STATUS[rosterStatus] or C.CALENDAR_ROSTER_STATUS.TEAM

    -- Color based on roster status
    btn:SetBackdropColor(statusData.color.r * 0.2, statusData.color.g * 0.2, statusData.color.b * 0.2, 0.8)
    btn:SetBackdropBorderColor(statusData.color.r, statusData.color.g, statusData.color.b, 0.8)

    -- Player name with class color
    local classColor = RAID_CLASS_COLORS[playerData.class] or { r = 0.8, g = 0.8, b = 0.8 }
    local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

    local nameStr = playerData.name or "Unknown"
    if #nameStr > 9 then
        nameStr = nameStr:sub(1, 8) .. "."
    end

    btn.text = btn:CreateFontString(nil, "OVERLAY")
    btn.text:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    btn.text:SetPoint("LEFT", btn, "LEFT", 3, 0)
    btn.text:SetText(statusData.icon .. " |cFF" .. colorHex .. nameStr .. "|r")

    -- Tooltip with signup timestamp
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(playerData.name, classColor.r, classColor.g, classColor.b)
        GameTooltip:AddLine("Status: " .. statusData.name, statusData.color.r, statusData.color.g, statusData.color.b)
        if playerData.joinedAt then
            GameTooltip:AddLine("Signed up: " .. date("%b %d at %H:%M", playerData.joinedAt), 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to change status", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(statusData.color.r, statusData.color.g, statusData.color.b, 0.8)
        GameTooltip:Hide()
    end)

    -- Click to cycle status
    btn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        local newStatus, err = Calendar:CyclePlayerRosterStatus(event.id, playerData.name)
        if newStatus then
            local newStatusData = C.CALENDAR_ROSTER_STATUS[newStatus]
            HopeAddon:Print(playerData.name .. " is now: |cFF" .. string.format("%02x%02x%02x", newStatusData.color.r * 255, newStatusData.color.g * 255, newStatusData.color.b * 255) .. newStatusData.name .. "|r")
            -- Refresh the appropriate popup
            if unifiedDayPopup and unifiedDayPopup:IsShown() then
                CalendarUI:RefreshUnifiedRightPanel()
            else
                CalendarUI:ShowEventDetail(event)
            end
        else
            HopeAddon:Print("|cFFFF0000Failed:|r " .. (err or "Unknown error"))
        end
    end)

    return btn
end

--[[
    Populate roster management UI for event owners
    Shows TEAM and ALTERNATES sections with clickable player entries
    @param content Frame - Content frame
    @param event table - Event data
]]
function CalendarUI:PopulateRosterManagement(content, event)
    -- Clear existing content (children + regions like font strings and textures)
    self:ClearContentContainer(content)

    local yOffset = 0
    local roster = Calendar:GetRosterByStatus(event)

    -- ============================================================
    -- TEAM SECTION
    -- ============================================================
    local teamHeader = content:CreateFontString(nil, "OVERLAY")
    teamHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    teamHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    teamHeader:SetText("|cFF00FF00TEAM|r (" .. #roster.team .. "/" .. (event.raidSize or 10) .. ")")

    yOffset = yOffset + 18

    -- Team members in a grid (3 columns)
    local columnWidth = 100
    local columnSpacing = 5
    if #roster.team > 0 then
        for i, player in ipairs(roster.team) do
            local col = ((i - 1) % 3)
            local row = math.floor((i - 1) / 3)
            local xOff = 5 + col * (columnWidth + columnSpacing)
            local yOff = yOffset + row * 18
            self:CreateRosterPlayerEntry(content, player, event, xOff, yOff)
        end
        yOffset = yOffset + (math.ceil(#roster.team / 3)) * 18 + 5
    else
        local noTeam = content:CreateFontString(nil, "OVERLAY")
        noTeam:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        noTeam:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        noTeam:SetText("|cFF666666No team members yet|r")
        yOffset = yOffset + 16
    end

    -- Divider
    local divider = content:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    divider:SetSize(content:GetWidth() - 20, 1)
    divider:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
    yOffset = yOffset + 8

    -- ============================================================
    -- ALTERNATES SECTION
    -- ============================================================
    local altHeader = content:CreateFontString(nil, "OVERLAY")
    altHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    altHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    altHeader:SetText("|cFFFFAA00ALTERNATES|r (" .. #roster.alternates .. ")")

    yOffset = yOffset + 18

    if #roster.alternates > 0 then
        for i, player in ipairs(roster.alternates) do
            local col = ((i - 1) % 3)
            local row = math.floor((i - 1) / 3)
            local xOff = 5 + col * (columnWidth + columnSpacing)
            local yOff = yOffset + row * 18
            self:CreateRosterPlayerEntry(content, player, event, xOff, yOff)
        end
        yOffset = yOffset + (math.ceil(#roster.alternates / 3)) * 18 + 5
    else
        local noAlts = content:CreateFontString(nil, "OVERLAY")
        noAlts:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        noAlts:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        noAlts:SetText("|cFF666666No alternates|r")
        yOffset = yOffset + 16
    end

    -- ============================================================
    -- DECLINED SECTION (if any)
    -- ============================================================
    if #roster.declined > 0 then
        local divider2 = content:CreateTexture(nil, "ARTWORK")
        divider2:SetColorTexture(0.4, 0.4, 0.4, 0.5)
        divider2:SetSize(content:GetWidth() - 20, 1)
        divider2:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        yOffset = yOffset + 8

        local declinedHeader = content:CreateFontString(nil, "OVERLAY")
        declinedHeader:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
        declinedHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
        declinedHeader:SetText("|cFFFF4444DECLINED|r (" .. #roster.declined .. ")")

        yOffset = yOffset + 18

        for i, player in ipairs(roster.declined) do
            local col = ((i - 1) % 3)
            local row = math.floor((i - 1) / 3)
            local xOff = 5 + col * (columnWidth + columnSpacing)
            local yOff = yOffset + row * 18
            self:CreateRosterPlayerEntry(content, player, event, xOff, yOff)
        end
        yOffset = yOffset + (math.ceil(#roster.declined / 3)) * 18
    end

    -- Help text
    yOffset = yOffset + 5
    local helpText = content:CreateFontString(nil, "OVERLAY")
    helpText:SetFont(HopeAddon.assets.fonts.BODY, 8, "")
    helpText:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
    helpText:SetText("|cFF888888Click player to cycle: Team -> Alternate -> Declined|r")

    content:SetHeight(math.max(yOffset + 20, 50))
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

    -- Template dropdown (for loading saved templates)
    local templateLabel = popup:CreateFontString(nil, "OVERLAY")
    templateLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    templateLabel:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    templateLabel:SetText("Template:")
    templateLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.templateDropdown = self:CreateSimpleDropdown(popup, { "-- None --" }, 1)
    popup.templateDropdown:SetPoint("TOPLEFT", templateLabel, "BOTTOMLEFT", 0, -4)
    popup.templateDropdown:SetSize(200, 26)

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

    -- Auto-set size when raid is selected and show/hide custom size input
    popup.raidDropdown.onSelect = function(index)
        local raidOption = C.CALENDAR_RAID_OPTIONS[index]
        if raidOption and raidOption.key == "custom" then
            -- Show custom size controls
            if popup.customSizeContainer then
                popup.customSizeContainer:Show()
            end
        else
            -- Hide custom size controls
            if popup.customSizeContainer then
                popup.customSizeContainer:Hide()
            end
        end
    end

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

    -- Custom size container (only shown when "Custom" raid option is selected)
    popup.customSizeContainer = CreateFrame("Frame", nil, popup)
    popup.customSizeContainer:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, yOffset)
    popup.customSizeContainer:SetSize(UI.CREATE_POPUP_WIDTH - 40, 50)
    popup.customSizeContainer:Hide()  -- Hidden by default

    local customSizeLabel = popup.customSizeContainer:CreateFontString(nil, "OVERLAY")
    customSizeLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    customSizeLabel:SetPoint("TOPLEFT", popup.customSizeContainer, "TOPLEFT", 0, 0)
    customSizeLabel:SetText("Custom Size:")
    customSizeLabel:SetTextColor(0.8, 0.8, 0.8)

    popup.customSizeDropdown = self:CreateSimpleDropdown(popup.customSizeContainer, { "5-man", "10-man", "15-man", "20-man", "25-man", "40-man" }, 2)
    popup.customSizeDropdown:SetPoint("TOPLEFT", customSizeLabel, "BOTTOMLEFT", 0, -4)
    popup.customSizeDropdown:SetSize(100, 26)

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

    -- Event Color dropdown
    local colorLabel = popup:CreateFontString(nil, "OVERLAY")
    colorLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    colorLabel:SetPoint("TOPLEFT", popup.descInput, "BOTTOMLEFT", 0, -10)
    colorLabel:SetText("Event Color:")
    colorLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Build color options with preview swatches
    local colorOptions = {}
    for _, preset in ipairs(C.CALENDAR_EVENT_COLOR_PRESETS) do
        table.insert(colorOptions, preset.name)
    end
    popup.colorDropdown = self:CreateSimpleDropdown(popup, colorOptions, 1)
    popup.colorDropdown:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -4)
    popup.colorDropdown:SetSize(120, 26)

    -- Color preview swatch
    popup.colorSwatch = popup:CreateTexture(nil, "ARTWORK")
    popup.colorSwatch:SetSize(20, 20)
    popup.colorSwatch:SetPoint("LEFT", popup.colorDropdown, "RIGHT", 8, 0)
    popup.colorSwatch:SetColorTexture(1, 0.5, 0, 1)  -- Default orange (raid color)

    -- Update swatch when color selection changes
    popup.colorDropdown.onSelect = function(index)
        local preset = C.CALENDAR_EVENT_COLOR_PRESETS[index]
        if preset and preset.color then
            popup.colorSwatch:SetColorTexture(preset.color.r, preset.color.g, preset.color.b, 1)
        else
            -- Default uses event type color (show orange for raids)
            popup.colorSwatch:SetColorTexture(1, 0.5, 0, 1)
        end
    end

    -- Discord Link input (optional)
    local discordLabel2 = popup:CreateFontString(nil, "OVERLAY")
    discordLabel2:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    discordLabel2:SetPoint("TOPLEFT", popup.colorDropdown, "BOTTOMLEFT", 0, -10)
    discordLabel2:SetText("Discord Link (optional):")
    discordLabel2:SetTextColor(0.8, 0.8, 0.8)

    popup.discordInput = Components:CreateEditBox(popup, 260, 26)
    popup.discordInput:SetPoint("TOPLEFT", discordLabel2, "BOTTOMLEFT", 0, -4)
    popup.discordInput:SetMaxLetters(200)

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
            self.menuFrame:SetBackdropColor(0.08, 0.08, 0.08, 1)
            self.menuFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            self.menuFrame:SetFrameStrata("TOOLTIP")

            -- Create scroll frame for long lists
            self.menuFrame.scrollFrame = CreateFrame("ScrollFrame", nil, self.menuFrame, "UIPanelScrollFrameTemplate")
            self.menuFrame.scrollFrame:SetPoint("TOPLEFT", 3, -3)
            self.menuFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -22, 3)

            -- Content frame inside scroll
            self.menuFrame.content = CreateFrame("Frame", nil, self.menuFrame.scrollFrame)
            self.menuFrame.content:SetSize(self:GetWidth() - 25, 100)
            self.menuFrame.scrollFrame:SetScrollChild(self.menuFrame.content)

            -- Style the scrollbar
            local scrollBar = self.menuFrame.scrollFrame.ScrollBar
            if scrollBar then
                scrollBar:ClearAllPoints()
                scrollBar:SetPoint("TOPRIGHT", self.menuFrame, "TOPRIGHT", -4, -18)
                scrollBar:SetPoint("BOTTOMRIGHT", self.menuFrame, "BOTTOMRIGHT", -4, 18)
            end

            -- Enable mouse wheel scrolling on menu frame
            self.menuFrame:EnableMouseWheel(true)
            self.menuFrame:SetScript("OnMouseWheel", function(_, delta)
                local scrollBar = self.menuFrame.scrollFrame.ScrollBar
                if scrollBar then
                    local current = scrollBar:GetValue()
                    local step = ITEM_HEIGHT * 2
                    scrollBar:SetValue(current - (delta * step))
                end
            end)
        end

        -- Clear existing menu items
        if self.menuFrame.content then
            for _, child in ipairs({ self.menuFrame.content:GetChildren() }) do
                child:Hide()
                child:SetParent(nil)
            end
        end

        local menuContentHeight = #self.options * ITEM_HEIGHT
        local menuFrameHeight = math.min(menuContentHeight + PADDING, MAX_VISIBLE_HEIGHT)
        local needsScroll = menuContentHeight + PADDING > MAX_VISIBLE_HEIGHT

        self.menuFrame:SetSize(self:GetWidth(), menuFrameHeight)
        self.menuFrame:SetPoint("TOP", self, "BOTTOM", 0, -2)

        -- Update content size
        local contentWidth = needsScroll and (self:GetWidth() - 25) or (self:GetWidth() - 6)
        self.menuFrame.content:SetSize(contentWidth, menuContentHeight)

        -- Show/hide scrollbar based on need
        local scrollBar = self.menuFrame.scrollFrame.ScrollBar
        if scrollBar then
            if needsScroll then
                scrollBar:Show()
                self.menuFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -22, 3)
            else
                scrollBar:Hide()
                self.menuFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -3, 3)
            end
        end

        for i, opt in ipairs(self.options) do
            local item = CreateFrame("Button", nil, self.menuFrame.content)
            item:SetSize(contentWidth, 18)
            item:SetPoint("TOPLEFT", self.menuFrame.content, "TOPLEFT", 0, -(i - 1) * ITEM_HEIGHT)

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

        -- Reset scroll position to top
        self.menuFrame.scrollFrame:SetVerticalScroll(0)

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
    @param dateStr string|nil - Optional date string (YYYY-MM-DD) to pre-fill
]]
function CalendarUI:ShowCreateEventPopup(dateStr)
    local popup = self:GetCreateEventPopup()

    -- Populate template dropdown
    self:RefreshTemplateDropdown(popup)

    -- Parse date if provided, otherwise use current date
    local targetMonth, targetDay, targetYear
    if dateStr then
        local y, m, d = Calendar:ParseDate(dateStr)
        if y then
            targetYear = y
            targetMonth = m
            targetDay = d
        end
    end

    -- Fall back to current date if not provided or invalid
    if not targetMonth then
        targetMonth = currentMonth
        targetDay = tonumber(date("%d"))
        targetYear = currentYear
    end

    -- Reset fields to defaults
    popup.templateDropdown:SetValue(1)
    popup.eventTypeDropdown:SetValue(1)
    popup.raidDropdown:SetValue(1)
    popup.titleInput:SetText("")
    popup.monthDropdown:SetValue(targetMonth)
    popup.dayDropdown:SetValue(targetDay)
    -- Year dropdown index (1 = current year, 2 = next year)
    local yearIndex = (targetYear == currentYear) and 1 or 2
    popup.yearDropdown:SetValue(yearIndex)
    popup.hourDropdown:SetValue(7)
    popup.minuteDropdown:SetValue(1)
    popup.ampmDropdown:SetValue(1)
    popup.descInput:SetText("")
    if popup.discordInput then
        popup.discordInput:SetText("")
    end

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
    @param popup Frame - Can be createEventPopup or unifiedDayPopup with createForm
    @param templateId string
]]
function CalendarUI:ApplyTemplate(popup, templateId)
    local template = Calendar:LoadTemplate(templateId)
    if not template then return end

    -- Get form references - supports both old standalone popup and new unified popup createForm
    local form = popup.createForm or popup

    -- Activity selection (unified dropdown handles both event type and raid/dungeon)
    if form.activityDropdown then
        for i, opt in ipairs(C.CALENDAR_RAID_OPTIONS) do
            if opt.key == template.raidKey then
                form.activityDropdown:SetValue(i)
                break
            end
        end
    elseif form.eventTypeDropdown and form.raidDropdown then
        -- Legacy support for old standalone popup
        local eventTypes = { "RAID", "DUNGEON", "RP_EVENT", "OTHER" }
        for i, evtType in ipairs(eventTypes) do
            if evtType == template.eventType then
                form.eventTypeDropdown:SetValue(i)
                break
            end
        end
        for i, opt in ipairs(C.CALENDAR_RAID_OPTIONS) do
            if opt.key == template.raidKey then
                form.raidDropdown:SetValue(i)
                break
            end
        end
    end

    -- Description
    if template.description then
        form.descInput:SetText(template.description)
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

        form.hourDropdown:SetValue(hour)
        form.ampmDropdown:SetValue(ampm)

        local minuteOptions = { 0, 15, 30, 45 }
        for i, m in ipairs(minuteOptions) do
            if minute == m then
                form.minuteDropdown:SetValue(i)
                break
            end
        end
    end

    -- Raid size (handled via customSizeDropdown when using custom raid)
    if template.raidSize and form.customSizeDropdown then
        -- Map size to customSizeDropdown index: 5=1, 10=2, 15=3, 20=4, 25=5, 40=6
        local sizeMap = { [5]=1, [10]=2, [15]=3, [20]=4, [25]=5, [40]=6 }
        local sizeIndex = sizeMap[template.raidSize] or 2
        form.customSizeDropdown:SetValue(sizeIndex)
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

    -- Determine raid size from raid option or custom dropdown
    local raidSize = 10
    local maxTanks, maxHealers, maxDPS = 2, 3, 5

    if raidOption and raidOption.key == "custom" then
        -- Custom size selected - use custom size dropdown
        local customSizeIndex = popup.customSizeDropdown and popup.customSizeDropdown:GetValue() or 2
        local customSizes = { 5, 10, 15, 20, 25, 40 }
        raidSize = customSizes[customSizeIndex] or 10

        -- Set role slots based on custom size
        if raidSize == 5 then
            maxTanks, maxHealers, maxDPS = 1, 1, 3
        elseif raidSize == 10 then
            maxTanks, maxHealers, maxDPS = 2, 3, 5
        elseif raidSize == 15 then
            maxTanks, maxHealers, maxDPS = 2, 4, 9
        elseif raidSize == 20 then
            maxTanks, maxHealers, maxDPS = 3, 5, 12
        elseif raidSize == 25 then
            maxTanks, maxHealers, maxDPS = 3, 7, 15
        elseif raidSize == 40 then
            maxTanks, maxHealers, maxDPS = 4, 12, 24
        end
    elseif raidOption and raidOption.size then
        -- Raid option has fixed size
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

    -- Get event color preset
    local colorIndex = popup.colorDropdown and popup.colorDropdown:GetValue() or 1
    local colorPreset = C.CALENDAR_EVENT_COLOR_PRESETS[colorIndex]
    local eventColor = (colorPreset and colorPreset.key ~= "default") and colorPreset.key or nil

    -- Get Discord link (optional)
    local discordLink = popup.discordInput and popup.discordInput:GetText() or ""
    if discordLink == "" then discordLink = nil end

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
        eventColor = eventColor,
        discordLink = discordLink,
    })

    if eventId then
        HopeAddon:Print("|cFF00FF00Event created:|r " .. title)
        popup:Hide()

        -- Refresh calendar if viewing the same month
        if monthGrid then
            self:PopulateMonthGrid(monthGrid)
        end

        -- Refresh week calendar if it exists
        if weekCalendar then
            self:PopulateWeekCalendar(weekCalendar)
        end

        -- Show the event's date in unified popup with new event selected
        self:ShowUnifiedDayPopup(dateStr, eventId)
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
    local counts = Calendar:GetSignupCounts(event)

    for _, roleKey in ipairs({ "tank", "healer", "dps" }) do
        local btn = popup["btn_" .. roleKey]
        if btn then
            local isFull = Calendar:IsRoleFull(event, roleKey)
            local roleData = C.CALENDAR_ROLES[roleKey]
            local roleCount = counts[roleKey]
            local openSlots = roleCount.max - roleCount.current

            if isFull then
                -- Show as standby option (full)
                btn:SetAlpha(0.6)
                if btn.text then
                    btn.text:SetText(roleData.name .. " (Full)")
                    btn.text:SetTextColor(0.7, 0.7, 0.7)
                end
                btn.isFull = true
            else
                -- Normal state - show open slot count
                btn:SetAlpha(1.0)
                if btn.text then
                    btn.text:SetText(roleData.name .. " (" .. openSlots .. " open)")
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
                    -- Clear any error tooltips and restore hover behavior
                    btn:SetScript("OnEnter", function(self)
                        if self:IsEnabled() then
                            self:SetBackdropBorderColor(1, 0.84, 0, 1)
                        end
                    end)
                    btn:SetScript("OnLeave", function(self)
                        if self:IsEnabled() then
                            local c = self.baseColor
                            self:SetBackdropBorderColor(c.r, c.g, c.b, 0.8)
                        end
                    end)
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
    if weekCalendar then
        self:PopulateWeekCalendar(weekCalendar)
    end
end

-- Make module accessible and register
HopeAddon.CalendarUI = CalendarUI
HopeAddon:RegisterModule("CalendarUI", CalendarUI)

return CalendarUI
