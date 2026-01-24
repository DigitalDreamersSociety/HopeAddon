# Activity Feed Implementation Plan

## Overview

Transform the Activity Feed ("Tavern Notice Board") into a polished, real-time social experience with proper refresh mechanics, clean architecture, and scalable foundation.

**Design Philosophy:**
- Lightweight and performant (30-second refresh cycle)
- Simple callback system for future extensibility
- Hybrid refresh: auto when at top, banner when scrolled
- Unread badge for passive awareness

---

## Current State Summary

### What Works
- 9 activity types auto-captured (boss, level, status, game, badge, rumor, mug, loot, romance)
- Network broadcast every 30 seconds via FellowTravelers
- Basic feed display with time grouping
- Mug reactions functional

### Critical Issues
1. Debug print spam in `BroadcastActivities()` (lines 410-446)
2. No real-time refresh - feed only updates on manual tab switch
3. Unread badge exists but never updates dynamically
4. Romance module doesn't call `OnRomanceEvent()`

---

## Implementation Phases

### Phase A: Foundation & Cleanup (Day 1)
**Goal:** Clean codebase, establish callback pattern

#### A1: Remove Debug Spam
**File:** `Social/ActivityFeed.lua`
**Lines:** 410, 414, 419, 427, 436, 446

Replace `HopeAddon:Print("[Debug]...")` with `HopeAddon:Debug(...)` (only shows when debug mode enabled).

```lua
-- Before (line 410)
HopeAddon:Print("[Debug] BroadcastActivities called, pending: " .. #self.pendingActivities)

-- After
HopeAddon:Debug("ActivityFeed: BroadcastActivities called, pending:", #self.pendingActivities)
```

#### A2: Add Listener Registration System
**File:** `Social/ActivityFeed.lua`
**Location:** After module state section (~line 120)

```lua
-- Listener system for UI refresh notifications
ActivityFeed.listeners = {}

--[[
    Register a listener for feed updates
    @param id string - Unique identifier for the listener
    @param callback function(activityCount) - Called when new activities arrive
]]
function ActivityFeed:RegisterListener(id, callback)
    self.listeners[id] = callback
    HopeAddon:Debug("ActivityFeed: Registered listener:", id)
end

function ActivityFeed:UnregisterListener(id)
    self.listeners[id] = nil
end

-- Internal: Notify all listeners
local function NotifyListeners(count)
    for id, callback in pairs(ActivityFeed.listeners) do
        local ok, err = pcall(callback, count)
        if not ok then
            HopeAddon:Debug("ActivityFeed: Listener error:", id, err)
        end
    end
end
```

#### A3: Call Listeners on New Activity
**File:** `Social/ActivityFeed.lua`
**Function:** `HandleNetworkActivity()` (line 370)

Add at end of function (after `AddToFeed`):
```lua
-- Notify listeners of new activity
NotifyListeners(1)
```

Also in `BroadcastActivities()` after adding own activities to feed.

---

### Phase B: Journal Integration (Day 2)
**Goal:** Wire up Journal to listen for updates, implement unread badge

#### B1: Register Journal as Listener
**File:** `Journal/Journal.lua`
**Location:** In `OnEnable()` or when Social tab initializes

```lua
-- Register for activity feed updates
if HopeAddon.ActivityFeed then
    HopeAddon.ActivityFeed:RegisterListener("Journal", function(count)
        Journal:OnNewActivity(count)
    end)
end
```

#### B2: Implement OnNewActivity Handler
**File:** `Journal/Journal.lua`
**New function:**

```lua
--[[
    Called when new activities arrive from network
    @param count number - Number of new activities
]]
function Journal:OnNewActivity(count)
    -- Update unread badge if not currently viewing feed
    self:UpdateSocialTabBadges()

    -- If viewing feed and scrolled to top, auto-refresh
    -- If viewing feed and scrolled down, show "new activities" indicator
    if self.currentTab == "social" then
        local socialUI = HopeAddon:GetSocialUI()
        if socialUI and socialUI.activeTab == "feed" then
            self:HandleFeedActivityArrival(count)
        end
    end
end
```

#### B3: Fix UpdateSocialTabBadges
**File:** `Journal/Journal.lua`
**Function:** `UpdateSocialTabBadges()` (line 6301)

Current code calculates unread but may not persist `lastSeenTimestamp` correctly. Verify:
- `lastSeenTimestamp` is set when viewing feed (already done at line 6755)
- Badge clears when feed is opened
- Badge shows count when feed has unseen items

---

### Phase C: Hybrid Refresh UX (Day 3)
**Goal:** Implement smart refresh behavior

#### C1: Track Scroll Position
**File:** `Journal/Journal.lua`

Add scroll position tracking to the feed's scroll frame:
```lua
-- In PopulateSocialFeed or scroll frame creation
scrollFrame:SetScript("OnScrollRangeChanged", function(self, xrange, yrange)
    -- Track if user is at top (within 20px tolerance)
    local atTop = self:GetVerticalScroll() < 20
    Journal.feedAtTop = atTop
end)
```

#### C2: Implement HandleFeedActivityArrival
**File:** `Journal/Journal.lua`

```lua
function Journal:HandleFeedActivityArrival(count)
    if self.feedAtTop then
        -- Auto-refresh silently
        self:PopulateSocialFeed()
    else
        -- Show "new activities" indicator
        self:ShowNewActivitiesBanner(count)
    end
end
```

#### C3: New Activities Banner
**File:** `Journal/Journal.lua`

Simple sticky banner at top of feed area:
```lua
function Journal:ShowNewActivitiesBanner(count)
    if not self.newActivitiesBanner then
        -- Create banner frame (only once)
        local banner = CreateFrame("Button", nil, self.socialContainers.content, "BackdropTemplate")
        banner:SetHeight(28)
        banner:SetPoint("TOPLEFT", 0, 0)
        banner:SetPoint("TOPRIGHT", 0, 0)
        banner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
        })
        banner:SetBackdropColor(0.2, 0.6, 0.2, 0.9)  -- Green tint
        banner:SetBackdropBorderColor(0.3, 0.8, 0.3, 1)

        local text = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("CENTER")
        text:SetTextColor(1, 1, 1)
        banner.text = text

        banner:SetScript("OnClick", function()
            banner:Hide()
            Journal.pendingActivityCount = 0
            Journal:PopulateSocialFeed()
        end)

        self.newActivitiesBanner = banner
    end

    -- Update count and show
    self.pendingActivityCount = (self.pendingActivityCount or 0) + count
    self.newActivitiesBanner.text:SetText("↑ " .. self.pendingActivityCount .. " new " ..
        (self.pendingActivityCount == 1 and "activity" or "activities") .. " - Click to refresh")
    self.newActivitiesBanner:Show()
end
```

---

### Phase D: Activity Request on Login (Day 4)
**Goal:** Request recent activities from Fellows on login/tab open

#### D1: Extend PING Protocol
**File:** `Social/FellowTravelers.lua`

Add optional flag to PING message requesting recent activities:
```
PING:version:wantActivities
```

When receiving PING with `wantActivities=1`, respond with recent activities in next broadcast cycle.

#### D2: Request Activities on Tab Open
**File:** `Journal/Journal.lua`
**Function:** `SelectSocialSubTab("feed")`

```lua
-- When opening feed tab, request activities from nearby Fellows
if HopeAddon.FellowTravelers then
    HopeAddon.FellowTravelers:RequestActivities()
end
```

#### D3: Implement RequestActivities
**File:** `Social/FellowTravelers.lua`

```lua
function FellowTravelers:RequestActivities()
    -- Send a targeted PING with activity request flag
    -- Fellows who receive this will include their recent activities in response
    self:BroadcastPresence(true)  -- true = request activities
end
```

---

### Phase E: Polish & Testing (Day 5)
**Goal:** Edge cases, performance, cleanup

#### E1: Edge Cases
- [ ] Handle rapid tab switching (debounce refresh)
- [ ] Clear banner when switching away from feed
- [ ] Don't request activities if feed is empty (first time user)
- [ ] Handle offline/online transitions gracefully

#### E2: Performance Verification
- [ ] Confirm 30-second ticker doesn't cause UI stutter
- [ ] Verify listener callbacks don't leak memory
- [ ] Test with 50 activities (max feed size)

#### E3: Cleanup OnDisable
- [ ] Unregister Journal listener in `OnDisable`
- [ ] Cancel any pending refresh timers
- [ ] Hide banner on disable

#### E4: Romance Integration
**File:** `Social/Romance.lua`

Add calls to ActivityFeed when romance events happen:
```lua
-- In ProposeToPlayer after successful proposal
if HopeAddon.ActivityFeed then
    HopeAddon.ActivityFeed:OnRomanceEvent("PROPOSED", targetName, nil)
end

-- In AcceptProposal
if HopeAddon.ActivityFeed then
    HopeAddon.ActivityFeed:OnRomanceEvent("DATING", partnerName, nil)
end

-- In BreakUp
if HopeAddon.ActivityFeed then
    HopeAddon.ActivityFeed:OnRomanceEvent("BREAKUP", partnerName, reason)
end
```

---

## UI Mockup: Feed Tab

```
┌─────────────────────────────────────────────────────────┐
│ [Feed (3)]  [Travelers]  [Companions]                   │  ← Unread badge
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │  ↑ 2 new activities - Click to refresh              │ │  ← Banner (when scrolled)
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ─── Now ───                                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [📜] Thrall: "Looking for Kara group!"    2m   [🍺] │ │
│ └─────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [⚔️] Jaina slew Attumen the Huntsman      15m  [🍺] │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ─── Earlier Today ───                                   │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [⬆️] Arthas reached level 70              3h   [🍺1]│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [+ Share]                                               │  ← Post rumor button
└─────────────────────────────────────────────────────────┘
```

---

## File Changes Summary

| File | Changes |
|------|---------|
| `Social/ActivityFeed.lua` | Remove debug spam, add listener system, notify on new activity |
| `Journal/Journal.lua` | Register listener, OnNewActivity handler, banner UI, scroll tracking |
| `Social/FellowTravelers.lua` | Activity request flag in PING protocol |
| `Social/Romance.lua` | Call OnRomanceEvent for proposal/accept/breakup |

---

## Testing Checklist

### Phase A
- [ ] No debug spam in chat during normal play
- [ ] Debug messages appear when `/hope debug` enabled
- [ ] Listeners can register/unregister without errors

### Phase B
- [ ] Unread badge shows correct count
- [ ] Badge clears when viewing feed
- [ ] Journal receives activity notifications

### Phase C
- [ ] Auto-refresh when scrolled to top
- [ ] Banner appears when scrolled down
- [ ] Click banner refreshes and hides banner
- [ ] Banner count accumulates correctly

### Phase D
- [ ] Activities populate faster on login
- [ ] Opening feed tab triggers activity request
- [ ] No duplicate activities from requests

### Phase E
- [ ] Romance events appear in feed
- [ ] No memory leaks after extended use
- [ ] Performance acceptable with full feed

---

## Success Criteria

1. **Responsive:** New activities appear within 30 seconds
2. **Non-intrusive:** No jarring UI jumps when auto-refreshing
3. **Aware:** Unread badge gives passive visibility
4. **Scalable:** Listener pattern ready for future modules
5. **Lightweight:** Minimal CPU/memory overhead

---

## Notes

- 30-second refresh matches existing broadcast interval (no extra network traffic)
- Simple callbacks preferred over event bus (less complexity)
- Banner is opt-in interaction (user controls when to see new content)
- Activity request piggybacks on existing PING (no new message types needed initially)
