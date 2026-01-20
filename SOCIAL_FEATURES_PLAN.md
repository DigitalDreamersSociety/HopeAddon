# HopeAddon Social System - Implementation Plan with Lua Payloads

## Current Status

| Phase | Status | Lines Added |
|-------|--------|-------------|
| Phase 1: Activity Feed | ✅ COMPLETE | ~550 lines |
| Phase 2: Rumors + Mugs | ✅ COMPLETE | +150 lines |
| Phase 3: Companions | ✅ COMPLETE | ~300 lines |
| Phase 4: Toast Notifications | ✅ COMPLETE | ~250 lines |

---

## Phase 2: Rumors + Mugs (~150 lines)

### Overview
Add manual "Rumors" (status posts) and "Raise a Mug" reactions to the activity feed.

### Constants to Add (ActivityFeed.lua)

```lua
-- Phase 2 constants
local RUMOR_MAX_LENGTH = 100
local RUMOR_COOLDOWN = 300  -- 5 minutes between rumors
local RUMOR_EXPIRY_HOURS = 24
local MUG_ICON = "Interface\\Icons\\INV_Drink_10"
```

### Data Structure Already Exists
```lua
-- Already in charDb.social (from Phase 1):
myRumors = {},       -- [timestamp] = { text, expires }
mugsGiven = {},      -- [activityId] = true
```

### New Functions for ActivityFeed.lua

**PAYLOAD 2A: Rumor Posting (~50 lines)**
```lua
--============================================================
-- PHASE 2: RUMORS
--============================================================

ActivityFeed.lastRumorTime = 0

--[[
    Post a new rumor (manual status update)
    @param text string - Rumor text (max 100 chars)
    @return boolean - Success
]]
function ActivityFeed:PostRumor(text)
    if not text or text == "" then return false end

    -- Rate limit
    local now = GetTime()
    if now - self.lastRumorTime < RUMOR_COOLDOWN then
        local remaining = math.ceil(RUMOR_COOLDOWN - (now - self.lastRumorTime))
        HopeAddon:Print("Please wait " .. remaining .. " seconds before posting another rumor.")
        return false
    end

    -- Truncate and sanitize
    text = text:sub(1, RUMOR_MAX_LENGTH)
    text = text:gsub("|", "")  -- Remove color codes

    local _, class = UnitClass("player")
    local activity = self:CreateActivity(
        ACTIVITY.RUMOR,
        UnitName("player"),
        class,
        text
    )

    -- Store in myRumors for expiry tracking
    local social = GetSocialData()
    if social then
        social.myRumors[activity.time] = {
            text = text,
            expires = time() + (RUMOR_EXPIRY_HOURS * 3600),
        }
    end

    self:QueueForBroadcast(activity)
    self.lastRumorTime = now

    HopeAddon:Print("Rumor posted!")
    return true
end

--[[
    Check if player can post a rumor (cooldown check)
    @return boolean, number - Can post, seconds remaining
]]
function ActivityFeed:CanPostRumor()
    local now = GetTime()
    local elapsed = now - self.lastRumorTime
    if elapsed >= RUMOR_COOLDOWN then
        return true, 0
    end
    return false, math.ceil(RUMOR_COOLDOWN - elapsed)
end
```

**PAYLOAD 2B: Mug Reactions (~40 lines)**
```lua
--============================================================
-- PHASE 2: MUG REACTIONS
--============================================================

--[[
    Give a mug (like) to an activity
    @param activityId string - Activity ID to mug
    @return boolean - Success
]]
function ActivityFeed:GiveMug(activityId)
    local social = GetSocialData()
    if not social then return false end

    -- Check if already mugged
    if social.mugsGiven[activityId] then
        HopeAddon:Debug("Already mugged this activity")
        return false
    end

    -- Find the activity in feed
    local activity = nil
    for _, act in ipairs(social.feed) do
        if act.id == activityId then
            activity = act
            break
        end
    end

    if not activity then
        HopeAddon:Debug("Activity not found:", activityId)
        return false
    end

    -- Mark as mugged locally
    social.mugsGiven[activityId] = true
    activity.mugs = (activity.mugs or 0) + 1

    -- Broadcast mug notification
    local _, class = UnitClass("player")
    local mugActivity = self:CreateActivity(
        ACTIVITY.MUG,
        UnitName("player"),
        class,
        activityId
    )
    self:QueueForBroadcast(mugActivity)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    return true
end

--[[
    Check if player has mugged an activity
    @param activityId string
    @return boolean
]]
function ActivityFeed:HasMugged(activityId)
    local social = GetSocialData()
    return social and social.mugsGiven[activityId] == true
end

--[[
    Handle incoming MUG activity (increment counter on target activity)
    @param mugActivity table - The MUG activity
]]
function ActivityFeed:HandleIncomingMug(mugActivity)
    local targetId = mugActivity.data
    local social = GetSocialData()
    if not social then return end

    for _, act in ipairs(social.feed) do
        if act.id == targetId then
            act.mugs = (act.mugs or 0) + 1
            HopeAddon:Debug("Mug received for activity:", targetId, "total:", act.mugs)
            break
        end
    end
end
```

**PAYLOAD 2C: UI Updates for Journal.lua (~60 lines)**
```lua
-- Add to CreateActivityFeedSection() after header:

-- Post Rumor button (top right of header)
local postBtn = CreateFrame("Button", nil, container)
postBtn:SetSize(60, 22)
postBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -12, -8)

local postBtnBg = postBtn:CreateTexture(nil, "BACKGROUND")
postBtnBg:SetAllPoints()
postBtnBg:SetColorTexture(0.4, 0.2, 0.6, 0.8)
postBtn.bg = postBtnBg

local postBtnText = postBtn:CreateFontString(nil, "OVERLAY")
postBtnText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
postBtnText:SetPoint("CENTER")
postBtnText:SetText("|cFFFFFFFF+ Post|r")

postBtn:SetScript("OnEnter", function(self)
    self.bg:SetColorTexture(0.5, 0.3, 0.7, 0.9)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Post a Rumor", 0.8, 0.4, 1)
    local canPost, remaining = ActivityFeed:CanPostRumor()
    if canPost then
        GameTooltip:AddLine("Share what's on your mind!", 0.8, 0.8, 0.8)
    else
        GameTooltip:AddLine("Cooldown: " .. remaining .. "s", 1, 0.3, 0.3)
    end
    GameTooltip:Show()
end)
postBtn:SetScript("OnLeave", function(self)
    self.bg:SetColorTexture(0.4, 0.2, 0.6, 0.8)
    GameTooltip:Hide()
end)
postBtn:SetScript("OnClick", function()
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    Journal:ShowRumorInput(container)
end)

-- Add to CreateActivityRow() for mug button:

-- Mug button (right side of row)
local mugBtn = CreateFrame("Button", nil, row)
mugBtn:SetSize(32, 20)
mugBtn:SetPoint("RIGHT", row, "RIGHT", -50, 0)

local mugIcon = mugBtn:CreateTexture(nil, "ARTWORK")
mugIcon:SetSize(16, 16)
mugIcon:SetPoint("LEFT", mugBtn, "LEFT", 0, 0)
mugIcon:SetTexture("Interface\\Icons\\INV_Drink_10")

local mugCount = mugBtn:CreateFontString(nil, "OVERLAY")
mugCount:SetFont(HopeAddon.assets.fonts.SMALL, 10)
mugCount:SetPoint("LEFT", mugIcon, "RIGHT", 2, 0)
local count = activity.mugs or 0
mugCount:SetText(count > 0 and ("|cFFFFD700" .. count .. "|r") or "")

local hasMugged = ActivityFeed:HasMugged(activity.id)
if hasMugged then
    mugIcon:SetVertexColor(1, 0.84, 0)  -- Gold tint
else
    mugIcon:SetVertexColor(0.6, 0.6, 0.6)  -- Grey
end

mugBtn:SetScript("OnClick", function()
    if not hasMugged then
        ActivityFeed:GiveMug(activity.id)
        mugIcon:SetVertexColor(1, 0.84, 0)
        mugCount:SetText("|cFFFFD700" .. ((activity.mugs or 0)) .. "|r")
    end
end)
mugBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Raise a Mug!", 1, 0.84, 0)
    if hasMugged then
        GameTooltip:AddLine("You've already cheered this!", 0.5, 0.5, 0.5)
    else
        GameTooltip:AddLine("Click to show appreciation", 0.8, 0.8, 0.8)
    end
    GameTooltip:Show()
end)
mugBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
```

**PAYLOAD 2D: Rumor Input Popup for Journal.lua (~40 lines)**
```lua
--[[
    Show inline rumor input box
    @param parent Frame - Parent container
]]
function Journal:ShowRumorInput(parent)
    -- Create or show existing input frame
    if not self.rumorInputFrame then
        local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        frame:SetSize(parent:GetWidth() - 24, 60)
        frame:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
        frame:SetBackdropBorderColor(0.5, 0.3, 0.7, 1)
        self.rumorInputFrame = frame

        local editBox = CreateFrame("EditBox", nil, frame)
        editBox:SetFont(HopeAddon.assets.fonts.BODY, 12)
        editBox:SetSize(frame:GetWidth() - 80, 20)
        editBox:SetPoint("LEFT", frame, "LEFT", 10, 0)
        editBox:SetMaxLetters(100)
        editBox:SetAutoFocus(true)
        editBox:SetTextInsets(5, 5, 0, 0)
        frame.editBox = editBox

        local bg = editBox:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

        local sendBtn = CreateFrame("Button", nil, frame)
        sendBtn:SetSize(50, 24)
        sendBtn:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        local sendBg = sendBtn:CreateTexture(nil, "BACKGROUND")
        sendBg:SetAllPoints()
        sendBg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
        local sendText = sendBtn:CreateFontString(nil, "OVERLAY")
        sendText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        sendText:SetPoint("CENTER")
        sendText:SetText("|cFFFFFFFFSend|r")

        sendBtn:SetScript("OnClick", function()
            local text = editBox:GetText()
            if HopeAddon.ActivityFeed:PostRumor(text) then
                editBox:SetText("")
                frame:Hide()
                self:RefreshSocialList()
            end
        end)

        editBox:SetScript("OnEnterPressed", function()
            sendBtn:Click()
        end)
        editBox:SetScript("OnEscapePressed", function()
            frame:Hide()
        end)
    end

    self.rumorInputFrame:SetParent(parent)
    self.rumorInputFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -45)
    self.rumorInputFrame:Show()
    self.rumorInputFrame.editBox:SetFocus()
end
```

---

## Phase 3: Companions (~250 lines)

### Overview
A favorites/friends list called "Companions" with online status tracking.

### New File: Social/Companions.lua

**PAYLOAD 3A: Module Setup (~40 lines)**
```lua
--[[
    HopeAddon Companions Module
    "Companions" - A favorites list of Fellow Travelers with online status
]]

local Companions = {}
HopeAddon.Companions = Companions
HopeAddon:RegisterModule("Companions", Companions)

--============================================================
-- CONSTANTS
--============================================================

local MSG_COMP_REQ = "COMP_REQ"   -- Companion request
local MSG_COMP_ACC = "COMP_ACC"   -- Accept request
local MSG_COMP_DEC = "COMP_DEC"   -- Decline request

local MAX_COMPANIONS = 50
local REQUEST_EXPIRY_HOURS = 24

--============================================================
-- MODULE STATE
--============================================================

Companions.eventFrame = nil

--============================================================
-- DATA HELPERS
--============================================================

local function GetCompanionData()
    if not HopeAddon.charDb then return nil end

    if not HopeAddon.charDb.social.companions then
        HopeAddon.charDb.social.companions = {
            list = {},         -- { [name] = { since, lastSeen, class, level } }
            outgoing = {},     -- { [name] = { timestamp } }
            incoming = {},     -- { [name] = { timestamp, class, level } }
        }
    end

    return HopeAddon.charDb.social.companions
end
```

**PAYLOAD 3B: Companion Management (~60 lines)**
```lua
--============================================================
-- COMPANION MANAGEMENT
--============================================================

--[[
    Send a companion request to a player
    @param playerName string
    @return boolean
]]
function Companions:SendRequest(playerName)
    local data = GetCompanionData()
    if not data then return false end

    -- Check if already a companion
    if data.list[playerName] then
        HopeAddon:Print(playerName .. " is already a companion!")
        return false
    end

    -- Check if request already pending
    if data.outgoing[playerName] then
        HopeAddon:Print("Request already sent to " .. playerName)
        return false
    end

    -- Check max companions
    local count = 0
    for _ in pairs(data.list) do count = count + 1 end
    if count >= MAX_COMPANIONS then
        HopeAddon:Print("Maximum companions reached (" .. MAX_COMPANIONS .. ")")
        return false
    end

    -- Send request via FellowTravelers
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_REQ, UnitName("player"))
    end

    -- Track outgoing
    data.outgoing[playerName] = { timestamp = time() }

    HopeAddon:Print("Companion request sent to " .. playerName)
    return true
end

--[[
    Accept a companion request
    @param playerName string
    @return boolean
]]
function Companions:AcceptRequest(playerName)
    local data = GetCompanionData()
    if not data then return false end

    local request = data.incoming[playerName]
    if not request then
        HopeAddon:Print("No request from " .. playerName)
        return false
    end

    -- Add to companions
    data.list[playerName] = {
        since = time(),
        lastSeen = time(),
        class = request.class,
        level = request.level,
    }

    -- Remove from incoming
    data.incoming[playerName] = nil

    -- Send acceptance
    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_ACC, UnitName("player"))
    end

    HopeAddon:Print(playerName .. " is now a companion!")
    return true
end

--[[
    Decline a companion request
    @param playerName string
]]
function Companions:DeclineRequest(playerName)
    local data = GetCompanionData()
    if not data then return end

    data.incoming[playerName] = nil

    local FellowTravelers = HopeAddon.FellowTravelers
    if FellowTravelers then
        FellowTravelers:SendDirectMessage(playerName, MSG_COMP_DEC, UnitName("player"))
    end
end

--[[
    Remove a companion
    @param playerName string
]]
function Companions:RemoveCompanion(playerName)
    local data = GetCompanionData()
    if not data then return end

    data.list[playerName] = nil
    HopeAddon:Print(playerName .. " removed from companions")
end
```

**PAYLOAD 3C: Network Handlers (~40 lines)**
```lua
--============================================================
-- NETWORK HANDLERS
--============================================================

function Companions:RegisterNetworkHandlers()
    local FellowTravelers = HopeAddon.FellowTravelers
    if not FellowTravelers then return end

    FellowTravelers:RegisterMessageCallback("Companions",
        function(msgType)
            return msgType == MSG_COMP_REQ or msgType == MSG_COMP_ACC or msgType == MSG_COMP_DEC
        end,
        function(msgType, sender, data)
            self:HandleMessage(msgType, sender, data)
        end
    )
end

function Companions:HandleMessage(msgType, sender, data)
    local compData = GetCompanionData()
    if not compData then return end

    if msgType == MSG_COMP_REQ then
        -- Incoming request
        local fellow = HopeAddon.FellowTravelers:GetFellow(sender)
        compData.incoming[sender] = {
            timestamp = time(),
            class = fellow and fellow.class or "UNKNOWN",
            level = fellow and fellow.level or 70,
        }
        HopeAddon:Print("|cFFFFD700" .. sender .. "|r wants to be companions!")

        -- Trigger toast notification (Phase 4)
        if HopeAddon.SocialToasts then
            HopeAddon.SocialToasts:Show("companion_request", sender)
        end

    elseif msgType == MSG_COMP_ACC then
        -- Our request was accepted
        if compData.outgoing[sender] then
            local fellow = HopeAddon.FellowTravelers:GetFellow(sender)
            compData.list[sender] = {
                since = time(),
                lastSeen = time(),
                class = fellow and fellow.class or "UNKNOWN",
                level = fellow and fellow.level or 70,
            }
            compData.outgoing[sender] = nil
            HopeAddon:Print("|cFF00FF00" .. sender .. "|r accepted your companion request!")
        end

    elseif msgType == MSG_COMP_DEC then
        -- Our request was declined
        compData.outgoing[sender] = nil
        HopeAddon:Print(sender .. " declined your companion request")
    end
end
```

**PAYLOAD 3D: Public API (~50 lines)**
```lua
--============================================================
-- PUBLIC API
--============================================================

--[[
    Check if player is a companion
    @param playerName string
    @return boolean
]]
function Companions:IsCompanion(playerName)
    local data = GetCompanionData()
    return data and data.list[playerName] ~= nil
end

--[[
    Get all companions with online status
    @return table - Array of { name, class, level, since, isOnline, lastSeen, zone }
]]
function Companions:GetAllCompanions()
    local data = GetCompanionData()
    if not data then return {} end

    local FellowTravelers = HopeAddon.FellowTravelers
    local result = {}
    local now = time()
    local ONLINE_THRESHOLD = 300  -- 5 minutes

    for name, info in pairs(data.list) do
        local fellow = FellowTravelers and FellowTravelers:GetFellow(name)
        local lastSeenTime = fellow and fellow.lastSeenTime or info.lastSeen or 0
        local isOnline = (now - lastSeenTime) < ONLINE_THRESHOLD

        table.insert(result, {
            name = name,
            class = fellow and fellow.class or info.class or "UNKNOWN",
            level = fellow and fellow.level or info.level or 70,
            since = info.since,
            isOnline = isOnline,
            lastSeen = lastSeenTime,
            zone = fellow and fellow.lastSeenZone or "Unknown",
            selectedTitle = fellow and fellow.selectedTitle,
        })
    end

    -- Sort: online first, then by name
    table.sort(result, function(a, b)
        if a.isOnline ~= b.isOnline then
            return a.isOnline
        end
        return a.name < b.name
    end)

    return result
end

--[[
    Get pending incoming requests
    @return table - Array of { name, class, level, timestamp }
]]
function Companions:GetIncomingRequests()
    local data = GetCompanionData()
    if not data then return {} end

    local result = {}
    local now = time()
    local expiry = REQUEST_EXPIRY_HOURS * 3600

    for name, info in pairs(data.incoming) do
        if (now - info.timestamp) < expiry then
            table.insert(result, {
                name = name,
                class = info.class,
                level = info.level,
                timestamp = info.timestamp,
            })
        end
    end

    return result
end

--[[
    Get count of online companions
    @return number
]]
function Companions:GetOnlineCount()
    local companions = self:GetAllCompanions()
    local count = 0
    for _, comp in ipairs(companions) do
        if comp.isOnline then count = count + 1 end
    end
    return count
end
```

**PAYLOAD 3E: Module Lifecycle (~20 lines)**
```lua
--============================================================
-- MODULE LIFECYCLE
--============================================================

function Companions:OnInitialize()
    GetCompanionData()  -- Ensure data structure
end

function Companions:OnEnable()
    self:RegisterNetworkHandlers()
    HopeAddon:Debug("Companions module enabled")
end

function Companions:OnDisable()
    if HopeAddon.FellowTravelers then
        HopeAddon.FellowTravelers:UnregisterMessageCallback("Companions")
    end
    HopeAddon:Debug("Companions module disabled")
end
```

**PAYLOAD 3F: Journal.lua UI Section (~60 lines)**
```lua
-- Add to PopulateSocial() after profile section:

--[[
    Create the Companions section
    @param parent Frame
    @return Frame
]]
function Journal:CreateCompanionsSection(parent)
    local Companions = HopeAddon.Companions
    local companions = Companions and Companions:GetAllCompanions() or {}
    local requests = Companions and Companions:GetIncomingRequests() or {}
    local onlineCount = Companions and Companions:GetOnlineCount() or 0

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local hasRequests = #requests > 0
    local contentHeight = 50 + (#companions * 35) + (hasRequests and 40 or 0)
    container:SetSize(parent:GetWidth() - 20, math.min(contentHeight, 200))
    container._componentType = "companionsSection"

    container:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    local goldColor = HopeAddon.colors.GOLD_BRIGHT
    container:SetBackdropBorderColor(goldColor.r, goldColor.g, goldColor.b, 1)

    -- Header
    local headerIcon = container:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(20, 20)
    headerIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerIcon:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")

    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    headerText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerText:SetText(HopeAddon:ColorText("COMPANIONS", "GOLD_BRIGHT"))

    local countText = container:CreateFontString(nil, "OVERLAY")
    countText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    countText:SetPoint("LEFT", headerText, "RIGHT", 8, 0)
    countText:SetText("|cFF00FF00(" .. onlineCount .. " online)|r")

    -- Divider
    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetSize(container:GetWidth() - 24, 1)
    divider:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -38)
    divider:SetColorTexture(goldColor.r, goldColor.g, goldColor.b, 0.4)

    local yOffset = -48

    -- Pending requests section
    if hasRequests then
        for _, req in ipairs(requests) do
            local reqRow = self:CreateCompanionRequestRow(container, req, yOffset)
            yOffset = yOffset - 40
        end
    end

    -- Companion rows
    if #companions == 0 and not hasRequests then
        local emptyText = container:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(HopeAddon.assets.fonts.BODY, 11)
        emptyText:SetPoint("CENTER", container, "CENTER", 0, -10)
        emptyText:SetText("|cFF808080No companions yet.\nAdd Fellows from the directory below!|r")
        emptyText:SetJustifyH("CENTER")
    else
        for _, comp in ipairs(companions) do
            local row = self:CreateCompanionRow(container, comp, yOffset)
            yOffset = yOffset - 35
        end
    end

    return container
end
```

---

## Phase 4: Toast Notifications (~150 lines)

### Overview
Non-intrusive popup notifications for social events.

### New File: Social/SocialToasts.lua

**PAYLOAD 4A: Module Setup (~30 lines)**
```lua
--[[
    HopeAddon SocialToasts Module
    Non-intrusive toast notifications for social events
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

-- Toast types and messages
local TOAST_TYPES = {
    companion_online = { icon = "Interface\\Icons\\Spell_Nature_Rejuvenation", color = {0, 1, 0} },
    companion_nearby = { icon = "Interface\\Icons\\INV_Misc_GroupLooking", color = {0, 0.75, 1} },
    companion_request = { icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend", color = {1, 0.84, 0} },
    mug_received = { icon = "Interface\\Icons\\INV_Drink_10", color = {1, 0.84, 0} },
    companion_lfrp = { icon = "Interface\\Icons\\INV_Valentineperfumebottle", color = {1, 0.2, 0.8} },
}

--============================================================
-- MODULE STATE
--============================================================

SocialToasts.activeToasts = {}
SocialToasts.toastPool = nil
```

**PAYLOAD 4B: Toast Frame Pool (~40 lines)**
```lua
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
    text:SetFont(HopeAddon.assets.fonts.BODY, 12)
    text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    text:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    frame.text = text

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetScript("OnClick", function()
        SocialToasts:DismissToast(frame)
    end)

    frame:Hide()
    return frame
end

local function ResetToastFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame.dismissTimer = nil
end

function SocialToasts:CreateFramePool()
    self.toastPool = HopeAddon.FramePool:NewNamed("SocialToasts", CreateToastFrame, ResetToastFrame)
end
```

**PAYLOAD 4C: Toast Display (~50 lines)**
```lua
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
    local settings = HopeAddon.charDb and HopeAddon.charDb.social and HopeAddon.charDb.social.toasts
    if settings and not settings.enabled then return end

    -- Check specific setting
    local typeKey = toastType:gsub("_", "")
    if settings and settings[typeKey] == false then return end

    local typeInfo = TOAST_TYPES[toastType]
    if not typeInfo then return end

    -- Check max toasts
    if #self.activeToasts >= MAX_TOASTS then
        self:DismissToast(self.activeToasts[1])
    end

    -- Acquire frame
    local frame = self.toastPool:Acquire()
    frame.icon:SetTexture(typeInfo.icon)
    frame:SetBackdropBorderColor(typeInfo.color[1], typeInfo.color[2], typeInfo.color[3], 1)

    -- Build message
    local message = customMessage
    if not message then
        if toastType == "companion_online" then
            message = "|cFF00FF00" .. playerName .. "|r is online"
        elseif toastType == "companion_nearby" then
            message = "|cFF00BFFF" .. playerName .. "|r is in your zone"
        elseif toastType == "companion_request" then
            message = "|cFFFFD700" .. playerName .. "|r wants to be companions!"
        elseif toastType == "mug_received" then
            message = "|cFFFFD700" .. playerName .. "|r raised a mug to you!"
        elseif toastType == "companion_lfrp" then
            message = "|cFFFF33CC" .. playerName .. "|r is Looking for RP"
        end
    end
    frame.text:SetText(message)

    -- Position
    local yOffset = -100 - (#self.activeToasts * TOAST_SPACING)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, yOffset)
    frame:Show()

    -- Track
    table.insert(self.activeToasts, frame)

    -- Auto-dismiss timer
    frame.dismissTimer = HopeAddon.Timer:After(TOAST_DURATION, function()
        self:DismissToast(frame)
    end)

    -- Play sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayNotification()
    end
end

--[[
    Dismiss a toast
    @param frame Frame
]]
function SocialToasts:DismissToast(frame)
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
        toast:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, yOffset)
    end

    self.toastPool:Release(frame)
end
```

**PAYLOAD 4D: Module Lifecycle and Settings (~30 lines)**
```lua
--============================================================
-- MODULE LIFECYCLE
--============================================================

function SocialToasts:OnInitialize()
    -- Ensure settings exist
    if HopeAddon.charDb and HopeAddon.charDb.social then
        HopeAddon.charDb.social.toasts = HopeAddon.charDb.social.toasts or {
            enabled = true,
            companionOnline = true,
            companionNearby = true,
            companionRequest = true,
            mugsReceived = true,
            companionLfrp = true,
        }
    end
end

function SocialToasts:OnEnable()
    self:CreateFramePool()
    HopeAddon:Debug("SocialToasts module enabled")
end

function SocialToasts:OnDisable()
    -- Dismiss all active toasts
    for _, toast in ipairs(self.activeToasts) do
        if toast.dismissTimer then
            toast.dismissTimer:Cancel()
        end
    end
    self.activeToasts = {}

    if self.toastPool then
        self.toastPool:Destroy()
        self.toastPool = nil
    end

    HopeAddon:Debug("SocialToasts module disabled")
end
```

---

## Implementation Checklist

### Phase 2: Rumors + Mugs ✅
- [x] Add PAYLOAD 2A: Rumor posting functions
- [x] Add PAYLOAD 2B: Mug reaction functions
- [x] Add PAYLOAD 2C: Update Journal UI for mug buttons
- [x] Add PAYLOAD 2D: Rumor input popup
- [x] Update HandleNetworkActivity for MUG type
- [ ] Test: Post rumor, verify cooldown, verify broadcast
- [ ] Test: Mug an activity, verify count increments

### Phase 3: Companions ✅
- [x] Create Social/Companions.lua
- [x] Add PAYLOAD 3A-3E to Companions.lua
- [x] Add PAYLOAD 3F: Journal UI section
- [x] Update HopeAddon.toc
- [x] Add charDb.social.companions defaults to Core.lua
- [x] Add "Add Companion" button to directory cards
- [ ] Test: Send/accept/decline requests
- [ ] Test: Online status updates

### Phase 4: Toast Notifications ✅
- [x] Create Social/SocialToasts.lua
- [x] Add PAYLOAD 4A-4D to SocialToasts.lua
- [x] Update HopeAddon.toc
- [x] Add charDb.social.toasts defaults to Core.lua
- [x] Hook toasts into Companions and ActivityFeed
- [ ] Test: Toasts appear and auto-dismiss
- [ ] Test: Settings toggle works

---

## Files to Create/Modify

| Phase | Action | File | Lines |
|-------|--------|------|-------|
| 2 | Modify | Social/ActivityFeed.lua | +90 |
| 2 | Modify | Journal/Journal.lua | +60 |
| 3 | Create | Social/Companions.lua | ~250 |
| 3 | Modify | Journal/Journal.lua | +60 |
| 3 | Modify | Core/Core.lua | +15 |
| 3 | Modify | HopeAddon.toc | +1 |
| 4 | Create | Social/SocialToasts.lua | ~150 |
| 4 | Modify | Core/Core.lua | +10 |
| 4 | Modify | HopeAddon.toc | +1 |
| **Total** | | | **~635** |
