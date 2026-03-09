# Social System - Component Reference

> **Audience:** AI assistants modifying social/directory/guild code.
> **Last updated:** 2026-03-03 (line numbers updated after dead code removal)

---

## 0. Architecture & File Map

The Social system handles addon-to-addon communication, RP profile sharing, player discovery, directory browsing, and guild roster management across 3 Lua modules.

| File | Lines | Module | Content |
|------|-------|--------|---------|
| `Social/FellowTravelers.lua` | 1-1501 | FellowTravelers | Addon communication, profile system, player discovery, chat coloring, tooltip integration |
| `Social/Directory.lua` | 1-412 | Directory | Searchable list of Fellow Travelers, sort/filter, stats, display formatting |
| `Social/Guild.lua` | 1-852 | Guild | Guild roster tracking, activity chronicles, listener system, settings |

### Module Dependencies

```
FellowTravelers (core communication)
  ├── Directory (reads charDb.travelers.fellows)
  ├── Guild (reads FellowTravelers:GetFellow for iLvl sort)
  ├── Companions (companion online detection)
  ├── SocialToasts (companion online toast)
  ├── Romance (profile serialization)
  ├── Badges (selected color/title for PONG)
  ├── Minigames (message forwarding)
  └── HopeAddon core (GetGearScore, GetClassColor, Timer, Sounds, charDb)
```

---

## 1. Constants & Configuration

### FellowTravelers Constants (FellowTravelers.lua:11-59)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 11 | `ADDON_PREFIX` | `"HOPEADDON"` | Addon message prefix registered with WoW API |
| 12 | `PROTOCOL_VERSION` | `2` | Message protocol version (v2: removed unused x/y fields from PING/PONG) |
| 15 | `MSG_PING` | `"PING"` | Announce presence |
| 16 | `MSG_PONG` | `"PONG"` | Response to ping |
| 17 | `MSG_PROFILE_REQ` | `"PREQ"` | Request profile |
| 18 | `MSG_PROFILE` | `"PROF"` | Profile data |
| 20 | `BROADCAST_INTERVAL` | `15` | Seconds between broadcasts |
| 21 | `PROFILE_CACHE_TIME` | `3600` | 1 hour profile cache |
| 22 | `PING_COOLDOWN` | `5` | Min seconds between pings to same player |
| 23 | `DISCOVERY_SOUND_COOLDOWN` | `120` | Murloc sound cooldown (2 minutes) |
| 56 | `MAX_PING_COOLDOWNS` | `100` | Max entries in ping cooldown table |
| 57 | `MAX_FELLOWS` | `200` | Max fellows before profile cache clear |
| 58 | `FELLOW_EXPIRY_DAYS` | `30` | Days before old fellows pruned |
| 59 | `PROFILE_REQUEST_COOLDOWN` | `60` | Seconds between profile requests per player |

**RP Status Options** (line 26-30):

| ID | Label | Color |
|----|-------|-------|
| `OOC` | Out of Character | `808080` |
| `IC` | In Character | `00FF00` |
| `LF_RP` | Looking for RP | `FFD700` |

**Personality Traits** (line 33-38): 20 options: Stoic, Curious, Battle-hardened, Cheerful, Mysterious, Reckless, Cautious, Loyal, Cunning, Compassionate, Gruff, Scholarly, Devout, Cynical, Optimistic, Noble, Roguish, Fierce, Gentle, Haunted

### Guild Constants (Guild.lua:16-40)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 16-24 | `ACTIVITY_TYPE` | table | 7 activity types: LOGIN, LOGOUT, LEVELUP, ZONE, RANK, JOIN, LEAVE |
| 27-35 | `ACTIVITY_MESSAGES` | table | RP-flavored format strings per activity type |
| 38 | `MAX_ACTIVITY_ENTRIES` | `100` | Max stored activity entries |
| 39 | `ACTIVITY_RETENTION_DAYS` | `7` | Days before activity entries pruned |
| 40 | `ROSTER_REFRESH_INTERVAL` | `30` | Seconds between auto-refresh |

### Directory Constants (Directory.lua:12-24)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 12-21 | `SORT_OPTIONS` | table | 8 sort options: name_asc, name_desc, class, level_desc, level_asc, last_seen, ilvl_desc, ilvl_asc |
| 23 | `currentSort` | `"last_seen"` | Default sort |
| 24 | `searchFilter` | `""` | Default search filter |
| 372-382 | `CLASS_ICONS` | table | 9 class icon paths (WARRIOR through DRUID) |

---

## 2. Message Routing Architecture

### Message Format

All addon messages use the format: `"MSGTYPE:VERSION:DATA"`

```lua
-- Parsing (FellowTravelers.lua:402):
local msgType, version, data = strsplit(":", message, 3)
```

### O(1) Handler Lookup (FellowTravelers.lua:280-285)

```lua
local MESSAGE_HANDLERS = {
    [MSG_PING]        = "HandlePing",        -- :441
    [MSG_PONG]        = "HandlePong",        -- :489
    [MSG_PROFILE_REQ] = "HandleProfileRequest", -- :541
    [MSG_PROFILE]     = "HandleProfileData",    -- :555
}
```

### Dispatch Flow (OnAddonMessage:388-436)

```
OnAddonMessage(prefix, message, channel, sender)
  -> Filter: prefix != ADDON_PREFIX -> return
  -> Filter: sender == self -> return
  -> Parse: strsplit(":", message, 3) -> msgType, version, data
  -> Check registered callbacks first (line 411-417):
       for each callback: if callback.match(msgType) -> callback.handler(msgType, sender, data); return
  -> Check MESSAGE_HANDLERS O(1) lookup (line 420):
       if handler found -> self[handler](self, sender, data); return
  -> Forward to Minigames module (line 431-435):
       if Minigames:IsMinigameMessage(msgType) -> Minigames:HandleMessage(...)
```

### Extensible Callback System (FellowTravelers.lua:157-174)

Other modules can register message handlers without modifying FellowTravelers:

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 157 | `RegisterMessageCallback` | `(callbackId, matchFunc, handler)` | Register handler. `matchFunc(msgType)` returns true to claim message |
| 169 | `UnregisterMessageCallback` | `(callbackId)` | Remove registered handler |

**Priority:** Registered callbacks are checked FIRST (line 411-417). If a callback claims the message, built-in handlers are skipped.

---

## 3. Channel Priority & Broadcasting

### BroadcastPresence (FellowTravelers.lua:290-335)

Sends presence PING to all available channels. Called every `BROADCAST_INTERVAL` seconds by periodic ticker.

**Channel priority:**

| Priority | Channel | Condition | Line |
|----------|---------|-----------|------|
| 1 | `INSTANCE_CHAT` | In BG, arena, or dungeon (`IsInInstanceGroup()`) | 312 |
| 2 | `RAID` | In real raid (not BG raid) (`IsInRealRaid()`) | 315 |
| 3 | `PARTY` | In real party (not BG party) (`IsInRealParty()`) | 317 |
| 4 | `GUILD` | In guild (`IsInGuild()`) | 321 |
| 5 | `YELL` | Not in instance and not in real raid, **every other broadcast** | 327-331 |

**YELL throttling** (line 327-331): `yellCounter` increments each broadcast; YELL only fires on even counts (every 30s instead of 15s).

### BroadcastMessage (FellowTravelers.lua:352-383)

Raw message broadcast for other modules (e.g., ActivityFeed). Same channel priority as BroadcastPresence but YELL fires every time (no throttle).

### SendDirectMessage (FellowTravelers.lua:343-346)

Sends via `WHISPER` channel to a specific player.

### Compatibility Helpers (FellowTravelers.lua:62-144)

| Line | Function | Purpose |
|------|----------|---------|
| 67 | `CachedSendAddonMessage` | Cached reference to `C_ChatInfo.SendAddonMessage` or `SendAddonMessage` |
| 71 | `SafeSendAddonMessage` | pcall wrapper, silently handles edge cases (BG leave, raid disband) |
| 83 | `IsInInstanceGroup` | Returns true for BG/arena/dungeon (use INSTANCE_CHAT) |
| 96 | `IsInRealRaid` | Excludes BG raids where RAID channel fails |
| 110 | `IsInRealParty` | Excludes BG parties |
| 124 | `EscapePattern` | Escape Lua pattern chars for safe gsub |
| 130 | `ScheduleBroadcast` | Timer deduplication for broadcasts |

---

## 4. Protocol Extension (iLevel Leaderboard)

Protocol v2 adds `avgILvl` and `gearScore` fields to both PING and PONG messages. Old v1 clients without these fields are handled gracefully (defaults to 0).

> **See Section 13.3** for full PING/PONG wire format, build/parse details, and backward compatibility rules.

---

## 5. FellowTravelers Complete Function Reference

### Module State (FellowTravelers.lua:43-53)

```lua
FellowTravelers.lastBroadcast = 0                  -- GetTime() of last broadcast
FellowTravelers.pingCooldowns = {}                  -- [playerName] = lastPingTime (GetTime)
FellowTravelers.eventFrame = nil                    -- WoW event frame
FellowTravelers.pendingBroadcast = nil              -- Timer handle for deduplication
FellowTravelers.profileRequestCooldowns = {}        -- [playerName] = lastRequestTime (GetTime)
FellowTravelers.lastDiscoverySoundTime = 0          -- GetTime() of last Murloc sound
FellowTravelers.soundPlayedForPlayer = {}           -- [name] = true (per-session, never cleared)
FellowTravelers.cleanupTicker = nil                 -- 5-minute cleanup timer
FellowTravelers.broadcastTicker = nil               -- 15-second broadcast timer
FellowTravelers.messageCallbacks = {}               -- Registered extensible handlers
FellowTravelers.yellCounter = 0                     -- YELL throttle counter
FellowTravelers.lastKnownParty = {}                 -- (line 1133) Party member tracking for change detection
```

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 180 | `OnInitialize()` | Register `ADDON_PREFIX` with WoW API |
| 190 | `OnEnable()` | Calls `Initialize()` |
| 194 | `OnDisable()` | Unregister events, unhook chat, cancel all tickers/timers |
| 218 | `Initialize()` | Create event frame, register 4 events, hook tooltip/chat, schedule initial broadcast, start cleanup + broadcast tickers |

**Registered events** (line 222-225): `GROUP_ROSTER_UPDATE`, `CHAT_MSG_ADDON`, `ZONE_CHANGED_NEW_AREA`, `PLAYER_TARGET_CHANGED`

### Messaging Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 290 | `BroadcastPresence` | `()` | Send PING to all channels (throttled by BROADCAST_INTERVAL) |
| 343 | `SendDirectMessage` | `(target, msgType, data)` | WHISPER to specific player |
| 352 | `BroadcastMessage` | `(msg)` | Raw message to all channels (for other modules) |
| 388 | `OnAddonMessage` | `(prefix, message, channel, sender)` | Dispatch incoming messages |

### Message Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 441 | `HandlePing` | `(sender, zoneData, channel)` | Register fellow, respond with PONG if not on cooldown |
| 489 | `HandlePong` | `(sender, data)` | Register/update fellow, request profile if not cached |
| 521 | `RequestProfile` | `(playerName)` | Send PREQ with cooldown check |
| 541 | `HandleProfileRequest` | `(sender)` | Serialize and send own profile if sharing enabled |
| 555 | `HandleProfileData` | `(sender, data)` | Deserialize and cache received profile |

### Profile Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 579 | `SerializeProfile` | `(profile)` -> `string` | Encode profile for transmission |
| 619 | `DeserializeProfile` | `(data)` -> `table\|nil` | Decode received profile |
| 776 | `GetFellowProfile` | `(name)` -> `table\|nil` | Get cached profile (checks 1-hour expiry) |
| 1465 | `GetMyProfile` | `()` -> `table\|nil` | Get player's own profile from charDb |
| 1474 | `UpdateMyProfile` | `(updates)` | Merge updates into own profile |
| 1489 | `GetStatusInfo` | `(statusId)` -> `table\|nil` | Lookup STATUS_OPTIONS by id |

### Fellow Management Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 682 | `RegisterFellow` | `(name, info)` | Create/update fellow. New discovery: play sound, print message, check companion online |
| 752 | `GetFellow` | `(name)` -> `table\|nil` | Get fellow data from charDb |
| 764 | `IsFellow` | `(name)` -> `boolean` | Check if player is a fellow |
| 1328 | `GetFellowCount` | `()` -> `number` | Count fellows in charDb |

### Cleanup Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 794 | `CleanupTables` | `()` | Prune pingCooldowns (expired + overflow), profileRequestCooldowns, old fellows (30d). Clear profile caches if >200 fellows |
| 854 | `AddPingCooldown` | `(name)` | Add entry with proactive oldest-eviction if at limit |
| 882 | `AddProfileRequestCooldown` | `(name)` | Add entry with proactive eviction if >=100 entries |

### Tooltip Integration

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 906 | `OnTooltipSetUnit` | `(tooltip)` (local) | Module-scope tooltip handler. Shows Fellow Traveler badge, title, profile excerpt, personality, appearance, RP hooks, pronouns, first seen date |
| 997 | `HookTooltip` | `()` | Guard against double-hook, warn about tooltip addon conflicts, hook `GameTooltip:OnTooltipSetUnit` |

### Chat Coloring

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1022 | `HookChat` | `()` | Hook all `NUM_CHAT_WINDOWS` chat frames (if colorChat enabled). Warns about chat addon conflicts |
| 1048 | `HookChatFrame` | `(chatFrame)` | Replace `AddMessage` with fellow name coloring wrapper. Stores original in `chatFrame._hopeOriginalAddMessage` |
| 1067 | `UnhookChat` | `()` | Restore original `AddMessage` on all hooked frames (prevents closure layering) |
| 1085 | `ColorFellowNames` | `(msg)` -> `string` | Extract bracketed names `[Name]`, color matching fellows. Handles both simple brackets and player links |

### Event Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1135 | `OnPartyChanged` | `()` | Detect new party members, update known travelers, re-register existing fellows |
| 1188 | `OnZoneChanged` | `()` | Schedule broadcast after 2s delay |
| 1193 | `OnTargetChanged` | `()` | Request profile if targeting a fellow without cached profile |

### Legacy/Compatibility Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1214 | `GetPartyMembers` | `()` -> `table` | Get current party/raid members as array |
| 1256 | `UpdateKnownTraveler` | `(name, class, level, isNewGroup)` | Update `charDb.travelers.known` entry, increment groupCount |
| 1292 | `GetTraveler` | `(name)` -> `table\|nil` | Get from `charDb.travelers.known` |
| 1303 | `GetAllTravelers` | `()` -> `table` | Get all from `charDb.travelers.known` |
| 1312 | `GetTravelerCount` | `()` -> `number` | Count known travelers |
| 1344 | `FormatPartyForDisplay` | `()` -> `string` | Class-colored comma-separated party names (or "Solo") |
| 1367 | `GetPartySnapshot` | `()` -> `table` | Party composition snapshot for milestone recording |
| 1386 | `GetRecentTravelers` | `(days)` -> `table` | Known travelers seen within N days, sorted newest first |
| 1429 | `IsGuildGroup` | `()` -> `boolean` | True if >50% of party are guild members |

---

## 6. Profile Serialization Format

**Serialize** (FellowTravelers.lua:579-612), **Deserialize** (line 619-671)

### Wire Format

```
b=backstory;a=appearance;h=rpHooks;p=pronouns;s=status;t=trait1,trait2;c=color;n=title;rs=romanceStatus;rp=romancePartner
```

### Field Map

| Key | Field | Max Length | Notes |
|-----|-------|-----------|-------|
| `b` | `backstory` | 200 chars | Truncated before serialize |
| `a` | `appearance` | 150 chars | Truncated before serialize |
| `h` | `rpHooks` | 150 chars | Truncated before serialize |
| `p` | `pronouns` | 30 chars | Truncated before serialize |
| `s` | `status` | - | Status ID: "OOC", "IC", "LF_RP" |
| `t` | `personality` | - | Comma-separated trait list |
| `c` | `selectedColor` | - | Badge color hex |
| `n` | `selectedTitle` | - | Title string |
| `rs` | `romanceStatus` | - | From `Romance:GetStatus()` |
| `rp` | `romancePartner` | - | Partner name from Romance module |

### Escaping

Characters `;`, `=`, `|` escaped with backslash. Newlines escaped as `\n`.

---

## 7. Directory Complete Function Reference

### Module State (Directory.lua:6-24)

```lua
Directory = {}                          -- Module table
HopeAddon.Directory = Directory         -- Global reference (line 7)
Directory.SORT_OPTIONS = { ... }        -- 8 sort options (line 12-21)
Directory.currentSort = "last_seen"     -- Active sort (line 23)
Directory.searchFilter = ""             -- Active filter (line 24)
```

### Data Access Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 34 | `GetAllEntries` | `()` -> `table` | Build entries from `charDb.travelers.fellows` + self-entry (Fellow Travelers only) |
| 60 | `BuildSelfEntry` | `()` -> `table\|nil` | Build live self-entry using WoW API (isSelf=true, no fellows table write) |
| 108 | `BuildEntry` | `(name, data, isFellow)` -> `table` | Standardize raw data into display entry. Includes Relationships note lookup |
| 139 | `GetFilteredEntries` | `(filter, sortOption)` -> `table` | Filter by name/class/zone text, then sort |
| 173 | `SortEntries` | `(entries, sortOption)` | In-place sort by 8 options. All use alphabetical name as tiebreaker |
| 235 | `GetILvlColor` | `(ilvl)` -> `string` | Hex color by gear tier (grey/white/green/blue/purple) |
| 248 | `GetEntryCount` | `()` -> `number` | Optimized count (no full entry build) |
| 267 | `GetEntry` | `(name)` -> `table\|nil` | Find specific entry by name (builds all entries, O(n)) |
| 283 | `IsPlayerNearby` | `(name)` -> `boolean` | Check party/raid for player (best-effort) |

### Statistics & Display Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 313 | `GetStats` | `()` -> `table` | Returns `{ fellows, byClass, recentCount }` (seen in last 7 days) |
| 345 | `FormatEntryForDisplay` | `(entry)` -> `table` | Returns `{ name, coloredName, classColor, colorHex, levelText, locationText, statusText, lastSeenText, hasNote }` |
| 389 | `GetClassIcon` | `(class)` -> `string` | Class icon path from cached lookup table |

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 397 | `OnInitialize()` | No-op |
| 401 | `OnEnable()` | Debug log |
| 405 | `OnDisable()` | No-op |

### BuildEntry Output Schema

```lua
{
    name = "PlayerName",
    class = "WARRIOR",
    level = 70,
    lastSeen = "Mar 01, 2026",
    lastSeenZone = "Shattrath City",
    lastSeenTime = 1740000000,      -- Unix timestamp
    firstSeen = "Feb 15, 2026",
    isFellow = true,
    isSelf = false,                  -- true only for BuildSelfEntry (local player)
    selectedColor = "FF0000",        -- Badge color hex or nil
    selectedTitle = "Champion",      -- Title or nil
    profile = { ... },               -- Cached RP profile or nil
    hasNote = true,                  -- Has Relationships note
    note = "Good tank",              -- Relationships note text or nil
    stats = { groupCount = 5, ... }, -- Grouped stats
    avgILvl = 115,                   -- Average item level or nil
    gearScore = 2450,                -- Gear score or nil
    avgILvlTime = 1740000000,        -- When iLvl was last updated
}
```

---

## 8. Guild Complete Function Reference

### Module State (Guild.lua:59-63)

```lua
Guild.eventFrame = nil          -- WoW event frame
Guild.listeners = {}            -- { [id] = callback } registered UI listeners
Guild.listenerCount = 0         -- Listener count (maintained manually)
Guild.refreshTicker = nil       -- 30-second periodic roster refresh timer
Guild.isInitialized = false     -- Initialize guard
```

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 69 | `OnInitialize()` | No-op (charDb not available yet) |
| 73 | `OnEnable()` | Calls `Initialize()` |
| 77 | `OnDisable()` | Unregister events, cancel refreshTicker, clear listeners |
| 98 | `Initialize()` | Guard, EnsureGuildData, create event frame, register 3 events, initial roster request, store guild info, start 30s refresh ticker |

**Registered events** (line 106-108): `GUILD_ROSTER_UPDATE`, `PLAYER_GUILD_UPDATE`, `GUILD_MOTD`

### Data Structure Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 150 | `EnsureGuildData` | `()` -> `table\|nil` | Create/migrate `charDb.guild` schema with defaults |
| 187 | `GetGuildData` | `()` -> `table\|nil` | Alias for EnsureGuildData |

### Event Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 199 | `OnGuildRosterUpdate` | `()` | Cache all guild members, detect activity changes (login/logout/zone/level/rank/join/leave), update guild info, notify listeners |
| 298 | `OnPlayerGuildUpdate` | `()` | Join -> request roster; Leave -> clear roster. Notify listeners "membership" |
| 314 | `OnGuildMOTD` | `(motd)` | Store MOTD, notify listeners "motd" |
| 325 | `ClearRoster` | `()` | Wipe roster, clear guild info, notify listeners "membership" |

### Activity Tracking Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 347 | `RecordActivity` | `(activityType, playerName, data)` | Insert at beginning, trim to MAX_ACTIVITY_ENTRIES, clean old |
| 375 | `CleanOldActivity` | `()` | Remove entries older than ACTIVITY_RETENTION_DAYS from end |
| 393 | `FormatActivity` | `(entry)` -> `string` | Format using ACTIVITY_MESSAGES template strings |
| 413 | `GetRecentActivity` | `(limit)` -> `table` | Return up to `limit` entries (default 20) |

**Activity entry schema:**

```lua
{
    type = "LOGIN",          -- ACTIVITY_TYPE value
    player = "PlayerName",   -- Short name
    data = nil,              -- Extra: level (LEVELUP), zone (ZONE), rank (RANK)
    timestamp = 1740000000,  -- time()
}
```

**Activity detection** (OnGuildRosterUpdate:240-266):

| Change | Activity Type | Detection |
|--------|--------------|-----------|
| Offline -> Online | `LOGIN` | `not oldEntry.isOnline and isOnline` |
| Online -> Offline | `LOGOUT` | `oldEntry.isOnline and not isOnline` |
| Zone changed | `ZONE` | `oldEntry.zone ~= zone` (online only) |
| Level increased | `LEVELUP` | `level > oldEntry.level` |
| Rank changed | `RANK` | `rankIndex ~= oldEntry.rankIndex` |
| New member | `JOIN` | Not in previous roster (skip first load) |
| Missing member | `LEAVE` | In old roster but not new roster |

### Roster Query Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 435 | `GetRoster` | `()` -> `table` | Array of all member entries from guildData.roster |
| 466 | `GetSortedRoster` | `(sortBy)` -> `table` | Sort by: "online" (default), "name", "rank", "level", "class", "ilvl" |
| 531 | `GetFilteredRoster` | `(filter, sortBy)` -> `table` | Filter by showOffline, rankFilter, classFilter, searchText |
| 583 | `GetMember` | `(name)` -> `table\|nil` | Direct lookup from guildData.roster |
| 593 | `GetOnlineCount` | `()` -> `number` | Count online members |
| 610 | `GetMemberCount` | `()` -> `number` | Count total members |

### Guild Info Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 625 | `GetGuildName` | `()` -> `string` | Guild name or "" |
| 634 | `GetMOTD` | `()` -> `string` | Message of the day or "" |
| 644 | `IsGuildMember` | `(name)` -> `boolean` | Check roster for name |
| 653 | `IsFellowTraveler` | `(name)` -> `boolean` | Delegates to `FellowTravelers:IsFellow(name)` |
| 662 | `GetRanks` | `()` -> `table` | Unique ranks from roster, sorted by rankIndex |

### Listener System

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 696 | `RegisterListener` | `(id, callback)` | Register callback for guild updates |
| 709 | `UnregisterListener` | `(id)` | Remove listener by id |
| 721 | `NotifyListeners` | `(eventType)` | Call all listeners with pcall safety. Events: "roster", "activity", "membership", "motd" |

### Settings Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 738 | `GetSortSetting` | `()` -> `string` | Get saved sort (default "online") |
| 747 | `SetSortSetting` | `(sortBy)` | Save sort preference |
| 758 | `GetShowOffline` | `()` -> `boolean` | Get offline visibility (default true) |
| 767 | `SetShowOffline` | `(show)` | Save offline visibility |
| 778 | `GetTrackActivity` | `()` -> `boolean` | Get activity tracking (default true) |
| 787 | `SetTrackActivity` | `(track)` | Save activity tracking |

### Utility Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 803 | `FormatRelativeTime` | `(timestamp)` -> `string` | "Just now", "2m ago", "1h ago", "3d ago" |
| 827 | `GetClassColor` | `(classToken)` -> `table` | `{ r, g, b }` from `RAID_CLASS_COLORS` |
| 841 | `RefreshRoster` | `()` | Force roster request via `RequestGuildRoster()` |

### API Compatibility (Guild.lua:47-53)

```lua
local function RequestGuildRoster()  -- GuildRoster() or C_GuildInfo.GuildRoster()
```

---

## 9. Sort System

### Directory Sort Options (Directory.lua:12-21)

| ID | Label | Sort Logic | Tiebreaker |
|----|-------|-----------|------------|
| `name_asc` | Name (A-Z) | Alphabetical ascending | - |
| `name_desc` | Name (Z-A) | Alphabetical descending | - |
| `class` | Class | Class name ascending | Name A-Z |
| `level_desc` | Level (High-Low) | Level descending | Name A-Z |
| `level_asc` | Level (Low-High) | Level ascending | Name A-Z |
| `last_seen` | Last Seen | lastSeenTime descending, fallback lastSeen string | - |
| `ilvl_desc` | iLevel (High-Low) | avgILvl descending | Name A-Z |
| `ilvl_asc` | iLevel (Low-High) | avgILvl ascending | Name A-Z |

### Guild Sort Options (Guild.lua:466-523)

| Sort | Logic | Tiebreaker |
|------|-------|------------|
| `online` (default) | Online first | Name A-Z |
| `name` | Name A-Z | - |
| `rank` | rankIndex ascending | Name A-Z |
| `level` | Level descending | Name A-Z |
| `class` | Class name ascending | Name A-Z |
| `ilvl` | avgILvl descending (via FellowTravelers lookup) — see **Section 13.7.3** | Name A-Z |

### iLevel Color Tiers (Directory.lua:235-241)

See **Section 13.6.1** for the full tier coloring table (`Directory:GetILvlColor()`).

---

## 10. UI Components (Journal.lua)

> **iLvl display details** are fully documented in **Section 13.6** (traveler rows) and **Section 13.7** (guild member rows).

### CreateTravelerRow iLevel Display

**File:** `Journal/Journal.lua:12578-12587` — See **Section 13.6.1** for full details.

- Position: RIGHT side of row, -120px offset
- Format: `"115 iLvl"` with tier color, or `"--"` in gray
- Rank badges when sorted by iLvl — see **Section 13.6.2**
- Self-entry handling — see **Section 13.6.4**
- Row tooltip with iLvl + age — see **Section 13.6.5**

### CreateGuildMemberRow iLevel Display

**File:** `Journal/Journal.lua:11837-11849` — See **Section 13.7.1** for full details.

- Looks up `FellowTravelers:GetFellow(member.name)` for gear data
- Same format as traveler row; members without addon show `"--"` in gray
- Tooltip shows iLvl + gear score for Fellows — see **Section 13.7.2**

---

## 11. Saved Variables Schema

### charDb.travelers

```lua
charDb.travelers = {
    fellows = {
        -- [playerName] = fellowData
        ["Tankbro"] = {
            firstSeen = "Feb 15, 2026",      -- HopeAddon:GetDate()
            lastSeen = "Mar 01, 2026",        -- HopeAddon:GetDate()
            lastSeenTime = 1740000000,         -- time() unix timestamp
            lastSeenZone = "Shattrath City",
            level = 70,
            class = "WARRIOR",
            selectedColor = "FF0000",           -- Badge color hex or nil
            selectedTitle = "Champion",         -- Title or nil
            profile = {                         -- Cached RP profile or nil
                backstory = "...",
                appearance = "...",
                rpHooks = "...",
                pronouns = "he/him",
                status = "IC",
                personality = { "Stoic", "Loyal" },
                selectedColor = "FF0000",
                selectedTitle = "Champion",
                romanceStatus = "SINGLE",
                romancePartner = nil,
            },
            profileCachedAt = 1740000000,      -- time() of profile cache
            avgILvl = 115,                      -- Average item level
            avgILvlTime = 1740000000,           -- time() of last iLvl update
            gearScore = 2450,                   -- Quality-weighted gear score
        },
    },
    known = {
        -- [playerName] = knownTravelerData (legacy - non-addon party members)
        ["Healbot"] = {
            class = "PRIEST",
            level = 70,
            lastSeen = "Mar 01, 2026",
            lastSeenZone = "Karazhan",
            firstSeen = "Feb 10, 2026",
            icons = {},                         -- Legacy icon data
            stats = {
                groupCount = 5,                 -- Times grouped together
                bossKillsTogether = 0,          -- Placeholder
                zonesVisitedTogether = {},       -- Placeholder
            },
        },
    },
    myProfile = {
        backstory = "A wandering warrior...",
        appearance = "Battle-scarred and tall...",
        rpHooks = "Mentions a lost sword...",
        pronouns = "he/him",
        status = "IC",
        personality = { "Battle-hardened", "Loyal" },
        selectedColor = nil,
        selectedTitle = nil,
    },
    fellowSettings = {
        enabled = true,                         -- Enable addon communication
        shareProfile = true,                    -- Allow profile sharing
        showTooltips = true,                    -- Show fellow info in tooltips
        colorChat = true,                       -- Color fellow names in chat
    },
}
```

### charDb.guild

```lua
charDb.guild = {
    name = "Hope",                              -- Guild name
    rank = "Officer",                           -- Player's rank name
    rankIndex = 2,                              -- Player's rank index
    roster = {
        -- [shortName] = memberData
        ["Tankbro"] = {
            fullName = "Tankbro-Realm",
            level = 70,
            class = "Warrior",                  -- Display name
            classToken = "WARRIOR",             -- Uppercase token
            zone = "Shattrath City",
            isOnline = true,
            note = "Main tank",                 -- Public note
            officerNote = "",                   -- Officer note
            rank = "Officer",
            rankIndex = 2,
            lastOnline = 1740000000,            -- time() when last seen online
            status = 0,                         -- 0=online, 1=AFK, 2=DND
        },
    },
    activity = {
        -- Array, newest first (max 100 entries, 7-day retention)
        { type = "LOGIN", player = "Tankbro", data = nil, timestamp = 1740000000 },
        { type = "ZONE", player = "Healbot", data = "Karazhan", timestamp = 1739999000 },
        { type = "LEVELUP", player = "Newbie", data = 68, timestamp = 1739998000 },
    },
    motd = "Kara tonight at 8pm!",
    lastRosterUpdate = 1740000000,              -- time() of last update
    settings = {
        trackActivity = true,                   -- Track guild activity
        showOffline = true,                     -- Show offline members
        sortBy = "online",                      -- Default sort: "online", "name", "rank", "level", "class", "ilvl"
    },
}
```

---

## 12. Cross-Module Integrations

### FellowTravelers -> External Modules

| Line | Integration | Target Module | Purpose |
|------|------------|---------------|---------|
| 466-467 | `Badges:GetSelectedColor()` / `GetSelectedTitle()` | Badges | Include in PONG response |
| 592-596 | `Romance:GetStatus()` | Romance | Include in profile serialization |
| 716-719 | `Companions:IsCompanion(name)` | Companions | Check companion status on fellow re-registration |
| 719 | `SocialToasts:Show("companion_online", name)` | SocialToasts | Show companion online notification |
| 431-435 | `Minigames:IsMinigameMessage()` / `HandleMessage()` | Minigames | Forward unhandled messages |
| 302 | `HopeAddon:GetGearScore()` | Core | Include gear data in PING broadcasts |
| 470 | `HopeAddon:GetGearScore()` | Core | Include gear data in PONG responses |
| 251 | `HopeAddon:InvalidateGearScoreCache()` | Core | Force recalculate before 15s warmup broadcast |
| 698 | `HopeAddon:PlaySound("FELLOW_DISCOVERY")` | Core/Sounds | Murloc discovery sound |

### Guild -> External Modules

| Line | Integration | Target Module | Purpose |
|------|------------|---------------|---------|
| 504-519 | `FellowTravelers:GetFellow(name)` | FellowTravelers | iLvl sort lookup for guild members |
| 653-656 | `FellowTravelers:IsFellow(name)` | FellowTravelers | Check if guild member has addon |
| 132-136 | `HopeAddon.Timer:NewTicker()` | Core/Timer | Periodic roster refresh |

### Directory -> External Modules

| Line | Integration | Target Module | Purpose |
|------|------------|---------------|---------|
| 66 | `HopeAddon:GetGearScore()` | Core | Live iLvl/gearScore for self-entry |
| 69-71 | `Badges:GetSelectedColor/Title()` | Badges | Badge data for self-entry |
| 76-77 | `Relationships:GetNote(name)` | Relationships | Attach player notes to entries |
| 346 | `HopeAddon:GetClassColor(class)` | Core | Class color for display formatting |

---

## 13. iLvl Leaderboard System (End-to-End)

The Travelers tab functions as an **iLvl leaderboard** for fellow addon users. This section documents the complete data flow from gear calculation through broadcasting, storage, and display — including the guild roster integration.

### 13.1 Gear Score Calculation (Core.lua)

**Functions:**

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 981 | `GetGearScore` | `()` -> `number, number` | Returns `gearScore, avgILvl` (cached) |
| 1016 | `InvalidateGearScoreCache` | `()` | Sets `gearScoreDirty = true` |
| 1024 | `GetGearScoreText` | `()` -> `string` | Formatted display: `"GS 2450"` or `"GS --"` |

**Algorithm** (Core.lua:981-1014):

```
gearScore = sum( itemLevel * qualityMultiplier ) for each equipped slot
avgILvl   = sum( itemLevel ) / equippedSlotCount
```

Scans via `GetInventoryItemLink("player", slotId)` then `GetItemInfo(itemLink)` for each slot.

**Equipment Slots** (`GEAR_SLOTS`, Core.lua:955-973) — 17 slots (shirt slot 4 excluded):

| Slot IDs | Slots |
|----------|-------|
| 1, 2, 3 | Head, Neck, Shoulder |
| 5, 6, 7, 8 | Chest, Waist, Legs, Feet |
| 9, 10 | Wrist, Hands |
| 11, 12 | Finger1, Finger2 |
| 13, 14 | Trinket1, Trinket2 |
| 15 | Back (cloak) |
| 16, 17, 18 | MainHand, OffHand, Ranged |

**Quality Multipliers** (`QUALITY_MULTIPLIERS`, Core.lua:937-948):

| Quality ID | Quality | Multiplier |
|------------|---------|------------|
| 0 | Poor (grey) | 0.0 |
| 1 | Common (white) | 0.5 |
| 2 | Uncommon (green) | 1.0 |
| 3 | Rare (blue) | 1.5 |
| 4 | Epic (purple) | 2.0 |
| 5 | Legendary (orange) | 2.5 |
| 6 | Artifact | 3.0 |
| 7 | Heirloom | 2.0 |

**Caching** (Core.lua:950-952): Results stored in `cachedGearScore` / `cachedAvgILvl` locals. Invalidated (`gearScoreDirty = true`) by:
- `PLAYER_EQUIPMENT_CHANGED` event handler (Core.lua:1076, 1094) — gear swap
- `HopeAddon:InvalidateGearScoreCache()` — called explicitly (login warmup)

**Zero-guard** (Core.lua:1007): Cache is only written when `itemCount > 0`, preventing a stale 0 from being cached when `GetItemInfo` hasn't loaded items yet (common at login).

### 13.2 Login Warmup (FellowTravelers.lua:246-253)

On login, `GetItemInfo()` may return nil for equipped items because the client item cache isn't populated yet. The addon handles this with two broadcasts:

1. **t=5s** (line 246): `ScheduleBroadcast(5)` — first presence broadcast (may have iLvl=0 if items aren't cached yet)
2. **t=15s** (line 250-253): Explicit `InvalidateGearScoreCache()` + `BroadcastPresence()` — by 15s the WoW client item cache is reliably populated, so this broadcast sends correct iLvl data

**Note:** The 15s timer calls `BroadcastPresence()` directly (bypasses `ScheduleBroadcast` deduplication) to guarantee a corrected broadcast is sent. The periodic 15s broadcast ticker (line 265-270) then continues with correct cached values.

### 13.3 Broadcasting (FellowTravelers.lua)

**PING** (line 303): `"PING:2:ZoneName|avgILvl|gearScore"`
- Built: `string.format("%s:%d:%s|%d|%d", MSG_PING, PROTOCOL_VERSION, zone, avgILvl or 0, gearScore or 0)`
- Parsed in HandlePing (line 444): `strsplit("|", zoneData, 3)` -> `zone, avgILvlStr, gearScoreStr`
- Sent to all available channels (INSTANCE > RAID > PARTY > GUILD > YELL)
- iLvl/gearScore obtained from `HopeAddon:GetGearScore()` (cached)

**PONG** (line 472): `"level|class|color|title|zone|avgILvl|gearScore"`
- Built: `string.format("%d|%s|%s|%s|%s|%d|%d", level, class, color, title, zone, avgILvl, gearScore)`
- Parsed in HandlePong (line 494): `strsplit("|", data, 7)` -> 7 fields, `tonumber()` for avgILvl/gearScore
- Both handlers call `RegisterFellow` with gear data

**Backward compatibility**: Old v1 clients send PING/PONG without gear fields. Parser gets `nil` for avgILvlStr/gearScoreStr (defaults to 0 via `tonumber(nil) or nil`). `RegisterFellow` only stores values when > 0, so missing data is never overwritten.

### 13.4 Storage (FellowTravelers.lua:734-741)

`RegisterFellow` stores iLvl data only when values are > 0 (guards against overwriting real data with 0):

```lua
-- Line 735-738: avgILvl guard
if info.avgILvl and info.avgILvl > 0 then
    fellow.avgILvl = info.avgILvl
    fellow.avgILvlTime = time()     -- timestamp tied to avgILvl update
end
-- Line 739-741: gearScore guard (separate, no timestamp)
if info.gearScore and info.gearScore > 0 then
    fellow.gearScore = info.gearScore
end
```

**Note:** `avgILvlTime` is only set alongside `avgILvl`, not `gearScore`. This means the "Updated: Xm ago" tooltip reflects when iLvl was last received, not gear score specifically.

### 13.5 Self-Entry (Directory.lua:60-99)

`Directory:BuildSelfEntry()` creates a live entry for the local player without touching the `fellows` table:

| Line | Data Source | Field(s) Set |
|------|------------|--------------|
| 61 | `UnitName("player")` | `name` |
| 64 | `UnitClass("player")` | `class` (classToken) |
| 65 | `UnitLevel("player")` | `level` |
| 66 | `HopeAddon:GetGearScore()` | `gearScore`, `avgILvl` |
| 67 | `GetZoneText()` | `lastSeenZone` |
| 69-71 | `Badges:GetSelectedColor/Title()` | `selectedColor`, `selectedTitle` |
| 73-74 | `charDb.travelers.myProfile` | `profile` |
| 76-77 | `Relationships:GetNote(name)` | `hasNote`, `note` |
| 83-85 | `HopeAddon:GetDate()`, `time()` | `lastSeen`, `lastSeenTime`, `avgILvlTime` |
| 88 | hardcoded | `isSelf = true` |

**Fields always nil for self:** `firstSeen`, `stats` (no historical data for self-entry).

Injected at the start of `GetAllEntries()` (line 42-45), then sorted alongside all fellow entries.

### 13.6 Display — Traveler Rows (Journal.lua)

#### 13.6.1 iLevel Text (Journal.lua:12578-12587)

- Position: RIGHT side of row, -120px offset
- Font: HEADER font, size 10, right-justified
- Format: `"|cFFXXXXXX115 iLvl|r"` using `Directory:GetILvlColor()` tier hex
- Fallback: `"|cFF555555--|r"` when no data or avgILvl <= 0

**Tier coloring** (`Directory:GetILvlColor()`, Directory.lua:235-241):

| Range | Color | Hex | Meaning |
|-------|-------|-----|---------|
| <= 0 / nil | Gray | `555555` | No data |
| 1-99 | White | `FFFFFF` | Leveling gear |
| 100-114 | Green | `1eff00` | Pre-raid (dungeons/heroics) |
| 115-129 | Blue | `0070dd` | T4+ raid gear |
| >= 130 | Purple | `a335ee` | T5+ raid gear |

#### 13.6.2 Rank Badges (Journal.lua:12319-12333)

Shown only when `sortOption == "ilvl_desc"` and entry has `avgILvl > 0`. Placed outside the row frame (anchored RIGHT of row:LEFT, -4px offset).

| Position | Color | Hex | Text |
|----------|-------|-----|------|
| #1 | Gold | `FFD700` | `#1` |
| #2 | Silver | `C0C0C0` | `#2` |
| #3 | Bronze | `CD7F32` | `#3` |
| #4+ | Grey | `808080` | `#N` |

Uses pooled `row.rankText` (HEADER font, size 11, OUTLINE).

#### 13.6.3 Online Status (Journal.lua:12540)

Self-entry is always `"online"`. For others, determined by `GetOnlineStatus(lastSeenTime)` (Journal.lua:11137-11148):

| Status | Condition | Dot Color (RGB) |
|--------|-----------|-----------------|
| `online` | `elapsed < ONLINE_THRESHOLD` (300s / 5min) | 0.2, 1.0, 0.2 (green) |
| `away` | `elapsed < AWAY_THRESHOLD` (900s / 15min) | 1.0, 0.8, 0.2 (yellow) |
| `offline` | `elapsed >= AWAY_THRESHOLD` or nil | 0.5, 0.5, 0.5 (grey) |

Thresholds from `Constants.SOCIAL_TAB.ONLINE_THRESHOLD` / `AWAY_THRESHOLD`.

#### 13.6.4 Self-Entry UI (Journal.lua:12568-12570, 12629-12631)

- Name display: Appends ` |cFF888888(You)|r` in grey after name (and optional title)
- Action buttons: All 5 hidden (companion, romance, game, invite, whisper) — the `if entry.isSelf` block at line 12630 skips all button configuration
- Tooltip: Shows "This is you!" line in green (0.5, 0.8, 0.5) at line 12815

#### 13.6.5 Row Tooltip — iLvl Section (Journal.lua:12818-12836)

When hovering a traveler row, the tooltip shows gear data if `avgILvl > 0`:

```
Avg iLevel: 115          -- tier-colored via GetILvlColor() RGB conversion
Gear Score: 2450          -- grey (0.7, 0.7, 0.7), only if gearScore > 0
Updated: 2h ago           -- grey (0.5, 0.5, 0.5), relative time from avgILvlTime
```

**Age formatting** (inline, lines 12828-12834):

| Elapsed | Display |
|---------|---------|
| < 60s | "Just now" |
| < 3600s | "Xm ago" |
| < 86400s | "Xh ago" |
| >= 86400s | "Xd ago" |

#### 13.6.6 Relationship Tag (Journal.lua:12589-12601)

If the entry has a relationship type in `charDb.social.relationshipTypes[name]` (not `"NONE"`), a colored `[Label]` tag is shown next to the name using `Constants.RELATIONSHIP_TYPES[type]`.

### 13.7 Display — Guild Member Rows (Journal.lua)

Guild members also display iLvl data when they are Fellow Travelers (have addon installed).

#### 13.7.1 Guild Row iLevel (Journal.lua:11837-11849)

- Looks up `FellowTravelers:GetFellow(member.name)` for gear data
- Same format as traveler row: `"115 iLvl"` with tier coloring, or `"--"` in grey
- Position: RIGHT side, -120px offset
- Members without addon always show `"--"`

#### 13.7.2 Guild Row Tooltip iLevel (Journal.lua:11886-11897)

When hovering a guild member who is a Fellow Traveler:

```
Fellow Traveler - Has HopeAddon   -- purple (0.61, 0.19, 1.0)
Avg iLevel: 115                    -- tier-colored RGB
Gear Score: 2450                   -- grey (0.7, 0.7, 0.7), only if > 0
```

Note: Guild member tooltip does NOT show data age (unlike traveler row tooltip).

#### 13.7.3 Guild iLvl Sort (Guild.lua:504-519)

`GetSortedRoster("ilvl")` sorts guild members by iLvl descending:
- For each member, calls `FellowTravelers:GetFellow(name)` to get `avgILvl`
- Non-fellow members default to iLvl 0 (sorted to bottom)
- Tiebreaker: name ascending (A-Z)

### 13.8 Frame Pooling — TravelerRows (Journal.lua)

Traveler rows use `HopeAddon.FramePool:NewNamed("TravelerRows", ...)` to avoid creating/destroying frames on every tab refresh.

#### Lifecycle

| Phase | Location | Line | Action |
|-------|----------|------|--------|
| Declaration | Journal.lua top | 62 | `Journal.travelerRowPool = nil` |
| Creation | `OnEnable()` | 219 | `self:CreateTravelerRowPool()` |
| Acquire | `CreateTravelerRow()` | 12523 | `self.travelerRowPool:Acquire()` |
| Release (refresh) | `PopulateSocialTravelers()` | 12281 | `self.travelerRowPool:ReleaseAll()` |
| Release (tab switch) | `ClearSocialContent()` | 11035 | `self.travelerRowPool:ReleaseAll()` |
| Destroy | `OnDisable()` | 328-329 | `self.travelerRowPool:Destroy()` / `= nil` |

#### createFunc (Journal.lua:1081-1144)

Creates a `Button` frame (BackdropTemplate) with pre-built sub-elements:

| Element | Type | Purpose |
|---------|------|---------|
| `row.statusDot` | Texture (OVERLAY) | 10x10 green indicator dot |
| `row.classIcon` | Texture (ARTWORK) | 28x28 class icon atlas |
| `row.nameText` | FontString (OVERLAY) | HEADER/12 — name + title + "(You)" |
| `row.zoneText` | FontString (OVERLAY) | BODY/10, grey — zone text |
| `row.ilvlText` | FontString (OVERLAY) | HEADER/10, right-justified — iLvl display |
| `row.relTag` | FontString (OVERLAY) | HEADER/9, hidden — relationship tag |
| `row.rankText` | FontString (OVERLAY) | HEADER/11 OUTLINE, hidden — rank medal |
| `row.companionBtn` | Button | 22x22 — add/remove buddy |
| `row.romanceBtn` | Button | 22x22 — oath/romance interaction |
| `row.gameBtn` | Button | 22x22 — challenge to minigame |
| `row.inviteBtn` | Button | 22x22 — invite to party |
| `row.whisperBtn` | Button | 22x22 — open whisper |

Action buttons created via local `CreatePooledActionIcon(parent)` (line 1127-1136): each gets a child `btn.icon` Texture.

#### resetFunc (Journal.lua:1147-1198)

Resets all state to ensure no stale data or closure leaks:

1. **Frame**: Hide, ClearAllPoints, SetParent(nil), reset backdrop colors
2. **Scripts**: Clear `OnEnter`, `OnLeave`, `OnClick` (releases closure references)
3. **Sub-elements**: ClearAllPoints + reset text/texture for statusDot, classIcon (+ texcoord reset), nameText, zoneText, ilvlText
4. **Hidden elements**: ClearAllPoints + reset text + Hide for relTag and rankText
5. **Action buttons**: For each of 5 buttons: Hide, ClearAllPoints, clear icon texture/vertex color, clear `OnEnter`/`OnLeave`/`OnClick` scripts

---

## 14. Dead Code & Unused Features

*All previously documented dead code has been removed:*
- FellowTravelers.lua: `MSG_LOCATION` constant and `originalAddMessage` field removed
- Guild.lua: `ONLINE_CHECK_INTERVAL`, `previousRoster`, `lastRosterUpdate`, `pendingRefresh`, and `OnGuildChat` removed

*No known dead code remains in the Social system.*

---

## Appendix: Function Count Summary

| Module | Category | Count | Functions |
|--------|----------|-------|-----------|
| **FellowTravelers.lua** | | | |
| Lifecycle | 4 | OnInitialize, OnEnable, OnDisable, Initialize |
| Messaging | 4 | BroadcastPresence, SendDirectMessage, BroadcastMessage, OnAddonMessage |
| Message Handlers | 5 | HandlePing, HandlePong, RequestProfile, HandleProfileRequest, HandleProfileData |
| Profile | 6 | SerializeProfile, DeserializeProfile, GetFellowProfile, GetMyProfile, UpdateMyProfile, GetStatusInfo |
| Fellow Management | 4 | RegisterFellow, GetFellow, IsFellow, GetFellowCount |
| Cleanup | 3 | CleanupTables, AddPingCooldown, AddProfileRequestCooldown |
| Tooltip | 2 | OnTooltipSetUnit (local), HookTooltip |
| Chat | 4 | HookChat, HookChatFrame, UnhookChat, ColorFellowNames |
| Events | 3 | OnPartyChanged, OnZoneChanged, OnTargetChanged |
| Legacy | 9 | GetPartyMembers, UpdateKnownTraveler, GetTraveler, GetAllTravelers, GetTravelerCount, FormatPartyForDisplay, GetPartySnapshot, GetRecentTravelers, IsGuildGroup |
| Callbacks | 2 | RegisterMessageCallback, UnregisterMessageCallback |
| **FellowTravelers subtotal** | **46** | |
| **Directory.lua** | | | |
| Data Access | 6 | GetAllEntries, BuildSelfEntry, BuildEntry, GetFilteredEntries, SortEntries, GetILvlColor |
| Queries | 3 | GetEntryCount, GetEntry, IsPlayerNearby |
| Stats/Display | 3 | GetStats, FormatEntryForDisplay, GetClassIcon |
| Lifecycle | 3 | OnInitialize, OnEnable, OnDisable |
| **Directory subtotal** | **15** | |
| **Guild.lua** | | | |
| Lifecycle | 4 | OnInitialize, OnEnable, OnDisable, Initialize |
| Data | 2 | EnsureGuildData, GetGuildData |
| Events | 4 | OnGuildRosterUpdate, OnPlayerGuildUpdate, OnGuildMOTD, ClearRoster |
| Activity | 4 | RecordActivity, CleanOldActivity, FormatActivity, GetRecentActivity |
| Roster | 6 | GetRoster, GetSortedRoster, GetFilteredRoster, GetMember, GetOnlineCount, GetMemberCount |
| Info | 5 | GetGuildName, GetMOTD, IsGuildMember, IsFellowTraveler, GetRanks |
| Listeners | 3 | RegisterListener, UnregisterListener, NotifyListeners |
| Settings | 6 | GetSortSetting, SetSortSetting, GetShowOffline, SetShowOffline, GetTrackActivity, SetTrackActivity |
| Utility | 3 | FormatRelativeTime, GetClassColor, RefreshRoster |
| API Compat | 1 | RequestGuildRoster (local) |
| **Guild subtotal** | **38** | |
| | | | |
| **Grand total** | **99 functions** | (+ 5 local helpers in FellowTravelers, 1 local in Guild) |
