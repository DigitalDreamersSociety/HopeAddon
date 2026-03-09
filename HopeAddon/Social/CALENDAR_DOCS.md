# Calendar System Documentation

Reference for AI assistants and future development of the HopeAddon calendar system.

## 1. Overview

Calendar is part of the Social tab system (5 sub-tabs: Guild, Travelers, Companions, **Calendar**, Feed).

**Source files:**
- `Calendar.lua` - Data & logic (~2197 lines)
- `CalendarUI.lua` - Rendering (~6495 lines)
- `CalendarValidation.lua` - Validation (~271 lines)
- Calendar constants in `Constants.lua` lines 8990-9771

## 2. Data Structures

### Persisted Storage (`HopeAddon.charDb.social.calendar`)

```
myEvents = {}           -- Events I created (keyed by eventId)
fellowEvents = {}       -- Events from guild/fellows (keyed by eventId)
mySignups = {}          -- My signups (keyed by eventId)
notifiedEvents = {}     -- Notification flags (keyed by "eventId_1hr" etc.)
templates = {}          -- Saved event templates (max 10)
settings = {
    defaultView = "month",
    showPastEvents = true,
    pastEventDays = 7,
    defaultNotify1hr = true,
    defaultNotify15min = true,
}
```

### Event Object

```
id              string    "evt_PlayerName_timestamp_random"
title           string    Event name
eventType       string    "RAID"|"DUNGEON"|"RP_EVENT"|"OTHER"|"SERVER"
raidKey         string?   "karazhan", "gruul", etc. (from CALENDAR_RAID_OPTIONS)
date            string    "YYYY-MM-DD"
startTime       string    "HH:MM"
endTime         string?   "HH:MM" (optional, displayed in tooltips)
raidSize        number    10 or 25
maxTanks        number    Default 2
maxHealers      number    Default 3
maxDPS          number    Default 5
description     string?   Max 200 chars
createdAt       number    Unix timestamp
updatedAt       number    Unix timestamp
leader          string    Creator's name
leaderClass     string    "WARRIOR" etc.
signups         table     { [playerName] = {class, role, status, joinedAt, isFellow} }
autoAcceptFellows  bool
softReserveLink string?
eventColor      string?   Color preset key
discordLink     string?
locked          bool      Prevents new signups
lockedAt        number?   When locked
autoLock24Hours bool      Lock 24hrs before start
roster          table     { [playerName] = "TEAM"|"ALTERNATE"|"DECLINED" }
```

### Signup Object (`mySignups[eventId]`)

```
role        string    "tank"|"healer"|"dps"
status      string    "confirmed"|"tentative"
notify1hr   bool
notify15min bool
```

### Server Event Object (one-time, read-only)

```
id                  string    Unique identifier
title               string    Display name
eventType           string    Always "SERVER"
date                string    "YYYY-MM-DD"
startTime           string    "HH:MM"
description         string    Event description
icon                string    Texture path
permanent           bool      false for one-time events
backgroundTexture   string?   Texture for themed day background
themeColor          table?    { r, g, b } for calendar cell theming
```

### Permanent Event Object (recurring, generated from `C.PERMANENT_GUILD_EVENTS`)

```
id                  string    Template identifier (e.g. "weekly_kara_meetup")
title               string    Display name
eventType           string    Always "SERVER"
dayOfWeek           number    Lua wday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
startTime           string    "HH:MM"
description         string    Event description
icon                string    Texture path
backgroundTexture   string    Texture for themed day background
themeColor          table     { r, g, b } for calendar cell theming
-- Generated fields (added at runtime):
date                string    "YYYY-MM-DD" (set when expanded for a specific date)
permanent           bool      Always true (set when expanded)
```

### Event Field Requirements by Source

Which fields are present on events depending on their origin. **R**=required/always present, **O**=optional/may be nil, **-**=absent.

| Field | User-Created | Permanent Guild | Server Event | Deserialized Fellow | Mini-Card (month) |
|-------|:---:|:---:|:---:|:---:|:---:|
| id | R | R | R | R | R |
| title | R | R | R | R | R |
| eventType | R | R (`SERVER`) | R (`SERVER`) | R | R |
| date | R | R (generated) | R | R | R |
| startTime | R | R | R | R | R |
| endTime | O | - | - | O | - |
| raidKey | O | - | - | O | O |
| description | O | R | R | O (50 char) | - |
| leader | R | - | - | R | - |
| leaderClass | R | - | - | R | - |
| signups | R | - | - | R | - |
| eventColor | O | - | - | O | O |
| locked | O | - | - | O | O |
| autoLock24Hours | O | - | - | - | - |
| themeColor | - | R | O | - | O |
| icon | - | R | R | - | O |
| permanent | - | R (`true`) | R (`false`) | - | O |
| backgroundTexture | - | R | O | - | - |
| spanPosition | - | - | - | - | O |

**Nil-safety principle:** All card rendering paths in CalendarUI.lua use `FALLBACK_COLOR = {r=0.5, g=0.5, b=0.5}` and `FALLBACK_CLASS_COLOR = {r=0.8, g=0.8, b=0.8}` as final guards before `.r/.g/.b` access.

## 3. Hardcoded Events

### One-Time Server Events (`C.SERVER_EVENTS`, Constants.lua:9215-9255)

| ID | Title | Date | Time |
|----|-------|------|------|
| dark_portal_opening | The Dark Portal Opens | 2026-02-05 | 17:00 |
| karazhan_release | Karazhan Opens | 2026-02-19 | 17:00 |

### Permanent Recurring Guild Events (`C.PERMANENT_GUILD_EVENTS`)

Guild events are defined as 3 permanent recurring templates in `C.PERMANENT_GUILD_EVENTS` (Constants.lua:9265). Each template specifies a `dayOfWeek` and is dynamically expanded for any date range by Calendar.lua.

| ID | Title | Day | Time | Theme Color | Icon |
|----|-------|-----|------|-------------|------|
| weekly_kara_meetup | Kara Meetup | Tuesday (wday 3) | 18:00 | Purple `{0.6, 0.2, 0.8}` | `INV_Misc_Key_07` |
| weekly_guild_hangout | Guild Hangout | Thursday (wday 5) | 18:00 | Teal `{0.2, 0.8, 0.8}` | `INV_Drink_04` |
| weekly_gruul_mag | Gruul's & Mag's Night | Saturday (wday 7) | 17:00 | Orange `{1.0, 0.5, 0.0}` | `INV_Misc_MonsterClaw_04` |

**Helper:** `C:GetPermanentEventsForDate(dateStr)` (Constants.lua:9302) - Returns an array of event copies for any matching day of week, with `date` and `permanent=true` fields set.

**Expansion points in Calendar.lua:**
- `GetServerEventsForDate()` - calls `C:GetPermanentEventsForDate()` to include recurring events for a single date
- `GetUpcomingEvents()` - generates next occurrence only per template (max 3 permanent events), leaving room for user-created events
- `GetEventsForMonth()` - generates instances for every matching day in the requested month

To add a new recurring event, add an entry to `C.PERMANENT_GUILD_EVENTS` with the appropriate `dayOfWeek`. No changes to Calendar.lua needed.

**Permanent events double-display pattern:** Permanent events appear twice in the month grid:
1. **Mini-card** via `addEventForDate()` — actionable list entry, clickable to open detail
2. **Themed background** via `addServerEventForDate()` — visual day indicator with colored bg/border

The first server event encountered for a given day wins the themed background slot; all server events for that day get mini-cards.

### App-Wide Banner Events (`C.APP_WIDE_EVENTS`)

App-wide milestone events displayed as colored banners. Defined in `C.APP_WIDE_EVENTS` (Constants.lua:9360).

| ID | Title | Date | Time | Color Theme |
|----|-------|------|------|-------------|
| app_dark_portal | The Dark Portal Opens | 2026-02-05 | 15:00 PST | FEL_GREEN |
| app_pvp_season1 | PvP Arena Season 1 Begins | 2026-02-17 | WEEKLY_RESET | BLOOD_RED |
| app_raids_unlock | Raids Unlock: Karazhan, Gruul, Magtheridon | 2026-02-19 | 15:00 PST | ARCANE_PURPLE |

**Data format:** Each entry has `id`, `title`, `description`, `startDate`, `endDate`, `time`, `colorName`, `icon`.

**Color themes** (`C.APP_WIDE_EVENT_COLORS`, Constants.lua:9395) - 4 themes, each with `bg`, `border`, `title`, `text` color tables:
- `FEL_GREEN` - green glow (Dark Portal)
- `BLOOD_RED` - red glow (PvP)
- `ARCANE_PURPLE` - purple glow (raids)
- `GOLD` - default/fallback

**UI config** (`C.CALENDAR_BANNER_UI`, Constants.lua:9424): max 4 banners, 32px height, 2px spacing, 24px icons, 280px tooltip width.

**Helper functions:**
- `C:GetActiveAppWideEvents()` (Constants.lua:9434) - Returns upcoming/recent events (within 7 days past end date), sorted by start date
- `C:GetAppWideEventsForMonth(year, month)` (Constants.lua:9455) - Returns events overlapping the given month
- `C:FormatBannerTime(timeStr)` (Constants.lua:9492) - Formats time for banner display (handles "WEEKLY_RESET" and 24h→12h AM/PM PST conversion)

## 4. Key Functions by File

### Calendar.lua - Data & Logic

| Function | Line | Purpose |
|----------|------|---------|
| `EnsureCalendarData()` | 78 | Init calendar storage |
| `GetTodayString()` | 159 | Current date as "YYYY-MM-DD" string |
| `ParseDate(dateStr)` | 168 | Parse "YYYY-MM-DD" to year, month, day numbers |
| `CreateEvent(eventData)` | 413 | Create + validate + broadcast |
| `UpdateEvent(eventId, updates)` | 499 | Update + broadcast |
| `DeleteEvent(eventId)` | 533 | Delete + broadcast |
| `GetEvent(eventId)` | 555 | Lookup in myEvents + fellowEvents |
| `GetServerEventsForDate(dateStr)` | 610 | Server events + permanent recurring guild events for a date |
| `IsServerEvent(event)` | 630 | Check if event.eventType == "SERVER" |
| `GetEventsForDate(dateStr)` | 644 | All events for a date |
| `GetUpcomingEvents(limit)` | 702 | Future events sorted (myEvents + fellowEvents + SERVER_EVENTS + permanent events for 30 days) |
| `GetPastEvents()` | 794 | Past events within configured days |
| `GetEventsForMonth(year, month)` | 863 | Full month grid data |
| `SignUp(eventId, role, status)` | 999 | Sign up with validation |
| `CancelSignup(eventId)` | 1120 | Remove signup |
| `GetSignupCounts(event)` | 1166 | {tank, healer, dps} counts |
| `GetSignupsByRole(event)` | 1205 | Grouped by role + status |
| `SaveTemplate(eventId, name)` | 1319 | Save event as template |
| `LoadTemplate(templateId)` | 1404 | Load template data |
| `CheckNotifications()` | 1476 | 1hr/15min reminder check |
| `CleanupExpiredEvents()` | 1541 | Remove events > 30 days old |
| `SerializeEvent(event)` | 1631 | Pipe-delimited for network |
| `DeserializeEvent(data)` | 1656 | Parse from network |
| `BroadcastEvent(event, action)` | 1685 | Send to guild/party |
| `LockEvent(eventId)` | 1842 | Lock signups |
| `UnlockEvent(eventId)` | 1867 | Unlock signups |
| `SetPlayerRosterStatus(...)` | 1908 | Set TEAM/ALTERNATE/DECLINED |
| `CyclePlayerRosterStatus(...)` | 1941 | Cycle through statuses |
| `GetRosterByStatus(event)` | 1980 | Get roster grouped by status |
| `ExportEventDetails(event)` | 2058 | Plain text export |

### CalendarUI.lua - Rendering

| Function | Line | Purpose |
|----------|------|---------|
| `CreatePools()` | 173 | dayCellPool + eventCardPool |
| `CreateDayCellFrame()` | 241 | Month grid cell (80x60px) |
| `CreateMiniEventCard(parent)` | 392 | Small event card in cell (60x14px, click routes SERVER→detail popup, others→unified day popup) |
| `PopulateMiniCards(cell, events, dateStr)` | 635 | Fill cell with event cards |
| `ConfigureMiniCard(card, event)` | 708 | Configure mini card (uses `event.themeColor` for stripe, `C:GetCalendarEventIcon` for icon) |
| `ApplyServerEventTheme(cell, event)` | 791 | Themed background for server events |
| `CreateCalendarHeader(parent)` | 1729 | "RAID CALENDAR" + Create button |
| `CreateMonthNavigation(parent)` | 1786 | < Month Year > navigation |
| `NavigateMonth(delta)` | 1839 | Move month forward/back |
| `NavigateToDate(y, m, d)` | 1874 | Jump to specific date |
| `CreateMonthGrid(parent)` | 1910 | 7x6 grid layout |
| `PopulateMonthGrid(grid)` | 1946 | Two-pass: create cells, align heights |
| `CreateWeekCalendar(parent)` | 2102 | Continuous week view |
| `AcquireEventCard(event)` | 2318 | Full event card for popups (uses `C:GetCalendarEventIcon` for icon, `event.themeColor` for stripe) |
| `GetEventDetailPopup()` | 2436 | 600x700px event detail |
| `ShowEventDetail(event)` | 2882 | Populate detail popup |
| `GetServerEventPopup()` | 3152 | Read-only server event popup (border/title colored by `event.themeColor`) |
| `ShowServerEventDetail(event)` | 3268 | Populate and show server event popup (called by mini-card click for SERVER events) |
| `GetUnifiedDayPopup()` | 3477 | Master-detail day view (680x520px) |
| `ShowUnifiedDayPopup(dateStr, selectedEventId, openCreateMode)` | 4954 | Main entry for day popup |
| `PopulateSignupList(content, event)` | 5160 | Signup matrix display |
| `PopulateRosterManagement(...)` | 5443 | Owner roster management |

### CalendarValidation.lua - Validation

| Function | Line | Purpose |
|----------|------|---------|
| `ValidateEventCreate(eventData)` | 66 | Date/time/role/size validation |
| `FindTimeConflicts(player, event)` | 169 | Overlap detection |
| `ValidateSignup(eventId, player, role)` | 209 | Role capacity + conflict checks |

## 5. Constants Reference

All in `Constants.lua`:

| Constant | Line | Purpose |
|----------|------|---------|
| `C.CALENDAR_TIMINGS` | 8990 | Max events (10), expiry (720hr), notification intervals |
| `C.CALENDAR_MSG` | 9000 | Network message type strings |
| `C.CALENDAR_UI` | 9008 | Grid dimensions, popup sizes, day/month names |
| `C.CALENDAR_SLOT_UI` | 9027 | Slot indicator sizes |
| `C.CALENDAR_MINI_CARD` | 9039 | Mini card dimensions (60x14, max 6 visible) |
| `C.CALENDAR_EVENT_PRIORITY` | 9053 | Sort priority (SERVER=1 highest) |
| `C.CALENDAR_WEEK_VIEW` | 9062 | Week view dimensions |
| `C.CALENDAR_DAY_POPUP` | 9071 | Day popup dimensions |
| `C.CALENDAR_UNIFIED_POPUP` | 9079 | Unified popup dimensions (680x520) |
| `C.CALENDAR_MONTH_COLORS` | 9090 | Per-month accent colors |
| `C.CALENDAR_EVENT_TYPES` | 9105 | RAID/DUNGEON/RP_EVENT/OTHER/SERVER icons |
| `C.CALENDAR_EVENT_COLORS` | 9114 | Event type color coding |
| `C.CALENDAR_ROLES` | 9122 | Tank (blue)/Healer (green)/DPS (red) |
| `C.CALENDAR_RAID_OPTIONS` | 9128 | 9 raids + dungeon spam + leveling + custom |
| `C.CALENDAR_RAID_SIZES` | 9146 | Default role splits for 10/25-man |
| `C.CALENDAR_SIGNUP_STATUS` | 9151 | Accepted/Declined/Tentative/Pending icons |
| `C.CALENDAR_EVENT_COLOR_PRESETS` | 9159 | 8 custom color options |
| `C.CALENDAR_ROSTER_STATUS` | 9171 | TEAM/ALTERNATE/DECLINED |
| `C.CALENDAR_VALIDATION` | 9181 | Min 30min notice, max 60 days, role enforcement |
| `C.SERVER_EVENTS` | 9215 | Hardcoded one-time milestone events (Dark Portal, Karazhan Opens, etc.) |
| `C.PERMANENT_GUILD_EVENTS` | 9265 | Recurring guild events defined by dayOfWeek (3 entries) |
| `C:GetPermanentEventsForDate()` | 9302 | Helper to expand permanent events for a specific date |
| `C:GetServerEventsForDate()` | 9320 | Helper to get one-time server events for a specific date |
| `C:IsServerEvent()` | 9331 | Check if event.eventType == "SERVER" |
| `C.APP_WIDE_EVENTS` | 9360 | App-wide milestone banner events (Dark Portal, PvP Season, Raids) |
| `C.APP_WIDE_EVENT_COLORS` | 9395 | Banner color themes (FEL_GREEN, BLOOD_RED, ARCANE_PURPLE, GOLD) |
| `C.CALENDAR_BANNER_UI` | 9424 | Banner display config (max 4 banners, 32px height, 24px icons) |
| `C:GetActiveAppWideEvents()` | 9434 | Upcoming/recent app-wide events |
| `C:GetAppWideEventsForMonth()` | 9455 | App-wide events for a specific month |
| `C:AddDaysToDate()` | 9478 | Add N days to a date string, returns new date string |
| `C:FormatBannerTime()` | 9492 | Banner time formatting (24h→12h AM/PM PST) |
| `C.JOURNEY_NEXT_EVENT` | 9525 | Journey tab next event card dimensions |
| `C.JOURNEY_UPCOMING_CARD` | 9532 | Journey tab upcoming event card config |
| `C.CALENDAR_RAID_ICONS` | 9541 | Raid-specific icons keyed by raidKey |
| `C.CALENDAR_EVENT_CARD_THEMES` | 9554 | Color themes for event cards by eventType (bg/border/title/text) |
| `C:GetCalendarEventIcon(event)` | 9588 | Icon priority: event.icon > raidKey > eventType > DEFAULT_ICON_PATH |
| `C:GetCalendarEventTheme(eventType)` | 9604 | Card theme by eventType (falls back to OTHER) |
| `C:GetEventCardTheme(event)` | 9609 | Event-aware card theme (derives from `event.themeColor` or falls back to `GetCalendarEventTheme`) |
| `C:GetNextAppWideEvent()` | 9623 | Next upcoming (or most recent) app-wide event |
| `C:GetAppWideEventTimestamp(event)` | 9647 | Unix timestamp for app-wide event |
| `C:GetTimeUntilAppWideEvent(event)` | 9661 | Seconds until event (negative if past) |
| `C:FormatAppWideEventDate(dateStr)` | 9666 | Date formatting ("Feb 19, 2026") |
| `C.HAPPENING_NOW_EVENTS` | 9697 | Active world bonus events (Sign of Battle, etc.) |
| `C.HAPPENING_NOW_UI` | 9716 | Happening Now banner dimensions (48px height, 32px icon) |
| `C:GetHappeningNowEvents()` | 9726 | Currently active Happening Now events |
| `C:GetHappeningNowDaysRemaining(event)` | 9748 | Days remaining for a Happening Now event |

## 6. Icon Priority Chain

`C:GetCalendarEventIcon(event)` (Constants.lua:9588) resolves icons in this order:

```
1. event.icon              -- permanent/server events set their own icon
2. C.CALENDAR_RAID_ICONS[event.raidKey]   -- raid-specific (karazhan, gruul, etc.)
3. C.CALENDAR_EVENT_TYPES[event.eventType].icon  -- type default (RAID, DUNGEON, etc.)
4. HopeAddon.DEFAULT_ICON_PATH            -- ultimate fallback
```

## 7. GetEventCardTheme Algorithm

`C:GetEventCardTheme(event)` (Constants.lua:9609) builds a full card theme:

**If `event.themeColor` is present** (permanent guild events, server events with themeColor):
- `bg` = themeColor * 0.25, alpha 0.95
- `border` = themeColor, alpha 1.0
- `title` = themeColor * 1.2, clamped to 1.0, alpha 1.0
- `text` = themeColor * 0.7 + 0.3, clamped to 1.0, alpha 1.0

**Fallback chain:** `GetCalendarEventTheme(event.eventType)` → `CALENDAR_EVENT_CARD_THEMES[eventType]` → `CALENDAR_EVENT_CARD_THEMES.OTHER`

## 8. Network Protocol

```
Event Create:   CAL_CREATE:1:id|title|type|raidKey|date|time|size|tanks|healers|dps|desc|leader|class|discordLink
Event Update:   CAL_UPDATE:1:id|title|type|raidKey|date|time|size|tanks|healers|dps|desc|leader|class|discordLink
Event Delete:   CAL_DELETE:1:eventId
Signup:         CAL_SIGNUP:1:eventId|playerName|playerClass|role|status
Signup Update:  CAL_SIGNUP_UPD:1:eventId|playerName|playerClass|role|status
```

- Pipes in text fields escaped
- Description truncated to 50 chars for network
- Broadcast via `FellowTravelers:BroadcastMessage()` (guild/party channel)
- Direct signups via `FellowTravelers:SendDirectMessage()` (whisper to leader)

## 9. Integration Points

- **Journey tab**: `Journal:CreateUpcomingEventsSection()` shows up to 8 upcoming events (including server events) with local time conversion via `Calendar:GetDualTimes()`. Uses `C:GetEventCardTheme(event)` for per-event theming and `C:GetCalendarEventIcon(event)` for icons.
- **Social tab**: Calendar is sub-tab #4, rendered by `Journal:PopulateSocialCalendar()`
- **Activity feed**: `ActivityFeed:OnCalendarEvent()` and `OnCalendarSignup()` post entries
- **Toasts**: `SocialToasts:Show("event_reminder/event_signup", ...)` for notifications
- **Badge**: Social Calendar tab shows upcoming event count badge
