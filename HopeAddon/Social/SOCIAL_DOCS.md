# Social System - Component Reference

> **Audience:** AI assistants modifying social/directory/guild code.
> **Last updated:** 2026-03-01 (v2 protocol - fixed double-pipe parsing bug)

---

## 0. Architecture & File Map

The Social system handles addon-to-addon communication, RP profile sharing, player discovery, directory browsing, and guild roster management across 3 Lua modules.

| File | Lines | Module | Content |
|------|-------|--------|---------|
| `Social/FellowTravelers.lua` | 1-1512 | FellowTravelers | Addon communication, profile system, player discovery, chat coloring, tooltip integration |
| `Social/Directory.lua` | 1-375 | Directory | Searchable list of Fellow Travelers, sort/filter, stats, display formatting |
| `Social/Guild.lua` | 1-875 | Guild | Guild roster tracking, activity chronicles, listener system, settings |

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

### FellowTravelers Constants (FellowTravelers.lua:11-62)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 11 | `ADDON_PREFIX` | `"HOPEADDON"` | Addon message prefix registered with WoW API |
| 12 | `PROTOCOL_VERSION` | `2` | Message protocol version (v2: removed unused x/y fields from PING/PONG) |
| 15 | `MSG_PING` | `"PING"` | Announce presence |
| 16 | `MSG_PONG` | `"PONG"` | Response to ping |
| 17 | `MSG_PROFILE_REQ` | `"PREQ"` | Request profile |
| 18 | `MSG_PROFILE` | `"PROF"` | Profile data |
| 19 | `MSG_LOCATION` | `"LOC"` | Location update (**unused - dead code, x/y removed from PING/PONG in v2**) |
| 22 | `BROADCAST_INTERVAL` | `15` | Seconds between broadcasts |
| 23 | `PROFILE_CACHE_TIME` | `3600` | 1 hour profile cache |
| 24 | `PING_COOLDOWN` | `5` | Min seconds between pings to same player |
| 25 | `DISCOVERY_SOUND_COOLDOWN` | `120` | Murloc sound cooldown (2 minutes) |
| 59 | `MAX_PING_COOLDOWNS` | `100` | Max entries in ping cooldown table |
| 60 | `MAX_FELLOWS` | `200` | Max fellows before profile cache clear |
| 61 | `FELLOW_EXPIRY_DAYS` | `30` | Days before old fellows pruned |
| 62 | `PROFILE_REQUEST_COOLDOWN` | `60` | Seconds between profile requests per player |

**RP Status Options** (line 28-32):

| ID | Label | Color |
|----|-------|-------|
| `OOC` | Out of Character | `808080` |
| `IC` | In Character | `00FF00` |
| `LF_RP` | Looking for RP | `FFD700` |

**Personality Traits** (line 35-40): 20 options: Stoic, Curious, Battle-hardened, Cheerful, Mysterious, Reckless, Cautious, Loyal, Cunning, Compassionate, Gruff, Scholarly, Devout, Cynical, Optimistic, Noble, Roguish, Fierce, Gentle, Haunted

### Guild Constants (Guild.lua:16-41)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 16-24 | `ACTIVITY_TYPE` | table | 7 activity types: LOGIN, LOGOUT, LEVELUP, ZONE, RANK, JOIN, LEAVE |
| 27-35 | `ACTIVITY_MESSAGES` | table | RP-flavored format strings per activity type |
| 38 | `MAX_ACTIVITY_ENTRIES` | `100` | Max stored activity entries |
| 39 | `ACTIVITY_RETENTION_DAYS` | `7` | Days before activity entries pruned |
| 40 | `ROSTER_REFRESH_INTERVAL` | `30` | Seconds between auto-refresh |
| 41 | `ONLINE_CHECK_INTERVAL` | `60` | **Unused** - declared but never referenced |

### Directory Constants (Directory.lua:12-21)

| Line | Constant | Value | Purpose |
|------|----------|-------|---------|
| 12-21 | `SORT_OPTIONS` | table | 8 sort options: name_asc, name_desc, class, level_desc, level_asc, last_seen, ilvl_desc, ilvl_asc |
| 23 | `currentSort` | `"last_seen"` | Default sort |
| 24 | `searchFilter` | `""` | Default search filter |
| 335-345 | `CLASS_ICONS` | table | 9 class icon paths (WARRIOR through DRUID) |

---

## 2. Message Routing Architecture

### Message Format

All addon messages use the format: `"MSGTYPE:VERSION:DATA"`

```lua
-- Parsing (FellowTravelers.lua:398):
local msgType, version, data = strsplit(":", message, 3)
```

### O(1) Handler Lookup (FellowTravelers.lua:276-281)

```lua
local MESSAGE_HANDLERS = {
    [MSG_PING]        = "HandlePing",        -- :437
    [MSG_PONG]        = "HandlePong",        -- :489
    [MSG_PROFILE_REQ] = "HandleProfileRequest", -- :545
    [MSG_PROFILE]     = "HandleProfileData",    -- :559
}
```

### Dispatch Flow (OnAddonMessage:384-431)

```
OnAddonMessage(prefix, message, channel, sender)
  -> Filter: prefix != ADDON_PREFIX -> return
  -> Filter: sender == self -> return
  -> Parse: strsplit(":", message, 3) -> msgType, version, data
  -> Check registered callbacks first (line 407-413):
       for each callback: if callback.match(msgType) -> callback.handler(msgType, sender, data); return
  -> Check MESSAGE_HANDLERS O(1) lookup (line 416):
       if handler found -> self[handler](self, sender, data); return
  -> Forward to Minigames module (line 428):
       if Minigames:IsMinigameMessage(msgType) -> Minigames:HandleMessage(...)
```

### Extensible Callback System (FellowTravelers.lua:160-177)

Other modules can register message handlers without modifying FellowTravelers:

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 160 | `RegisterMessageCallback` | `(callbackId, matchFunc, handler)` | Register handler. `matchFunc(msgType)` returns true to claim message |
| 172 | `UnregisterMessageCallback` | `(callbackId)` | Remove registered handler |

**Priority:** Registered callbacks are checked FIRST (line 407-413). If a callback claims the message, built-in handlers are skipped.

---

## 3. Channel Priority & Broadcasting

### BroadcastPresence (FellowTravelers.lua:286-331)

Sends presence PING to all available channels. Called every `BROADCAST_INTERVAL` seconds by periodic ticker.

**Channel priority:**

| Priority | Channel | Condition | Line |
|----------|---------|-----------|------|
| 1 | `INSTANCE_CHAT` | In BG, arena, or dungeon (`IsInInstanceGroup()`) | 310 |
| 2 | `RAID` | In real raid (not BG raid) (`IsInRealRaid()`) | 312 |
| 3 | `PARTY` | In real party (not BG party) (`IsInRealParty()`) | 314 |
| 4 | `GUILD` | In guild (`IsInGuild()`) | 318 |
| 5 | `YELL` | Not in instance and not in real raid, **every other broadcast** | 323-328 |

**YELL throttling** (line 323-328): `yellCounter` increments each broadcast; YELL only fires on even counts (every 30s instead of 15s).

### BroadcastMessage (FellowTravelers.lua:348-379)

Raw message broadcast for other modules (e.g., ActivityFeed). Same channel priority as BroadcastPresence but YELL fires every time (no throttle).

### SendDirectMessage (FellowTravelers.lua:339-342)

Sends via `WHISPER` channel to a specific player.

### Compatibility Helpers (FellowTravelers.lua:64-131)

| Line | Function | Purpose |
|------|----------|---------|
| 70 | `CachedSendAddonMessage` | Cached reference to `C_ChatInfo.SendAddonMessage` or `SendAddonMessage` |
| 74 | `SafeSendAddonMessage` | pcall wrapper, silently handles edge cases (BG leave, raid disband) |
| 86 | `IsInInstanceGroup` | Returns true for BG/arena/dungeon (use INSTANCE_CHAT) |
| 99 | `IsInRealRaid` | Excludes BG raids where RAID channel fails |
| 113 | `IsInRealParty` | Excludes BG parties |
| 127 | `EscapePattern` | Escape Lua pattern chars for safe gsub |
| 133 | `ScheduleBroadcast` | Timer deduplication for broadcasts |

---

## 4. Protocol Extension (iLevel Leaderboard)

### PING Format (v2)

**File:** `Social/FellowTravelers.lua:299`

```
"PING:2:ZoneName|avgILvl|gearScore"
```

**Build:** `string.format("%s:%d:%s|%d|%d", MSG_PING, PROTOCOL_VERSION, zone, avgILvl or 0, gearScore or 0)`

**Parse:** `strsplit("|", zoneData, 3)` -> `zone, avgILvlStr, gearScoreStr`

### PONG Format (v2)

**File:** `Social/FellowTravelers.lua:468-476`

```
"level|class|color|title|zone|avgILvl|gearScore"
```

**Build:** `string.format("%d|%s|%s|%s|%s|%d|%d", level, class, color, title, zone, avgILvl, gearScore)`

**Parse:** `strsplit("|", data, 7)` -> `level, class, color, title, zone, avgILvlStr, gearScoreStr`

### Backward Compatibility

- Old v1 clients send PING without gear fields - parser gets `nil` for avgILvlStr/gearScoreStr (defaults to 0)
- `RegisterFellow` only stores `avgILvl`/`gearScore` when > 0
- v1->v2 migration: removed unused x/y coordinate fields from PING/PONG (location was never actually transmitted via these messages)

---

## 5. FellowTravelers Complete Function Reference

### Module State (FellowTravelers.lua:44-56)

```lua
FellowTravelers.lastBroadcast = 0                  -- GetTime() of last broadcast
FellowTravelers.pingCooldowns = {}                  -- [playerName] = lastPingTime (GetTime)
FellowTravelers.eventFrame = nil                    -- WoW event frame
FellowTravelers.originalAddMessage = nil            -- Leftover (unused - actual refs in chatFrame._hopeOriginalAddMessage)
FellowTravelers.pendingBroadcast = nil              -- Timer handle for deduplication
FellowTravelers.profileRequestCooldowns = {}        -- [playerName] = lastRequestTime (GetTime)
FellowTravelers.lastDiscoverySoundTime = 0          -- GetTime() of last Murloc sound
FellowTravelers.soundPlayedForPlayer = {}           -- [name] = true (per-session, never cleared)
FellowTravelers.cleanupTicker = nil                 -- 5-minute cleanup timer
FellowTravelers.broadcastTicker = nil               -- 15-second broadcast timer
FellowTravelers.messageCallbacks = {}               -- Registered extensible handlers
FellowTravelers.yellCounter = 0                     -- YELL throttle counter
FellowTravelers.lastKnownParty = {}                 -- (line 1144) Party member tracking for change detection
```

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 183 | `OnInitialize()` | Register `ADDON_PREFIX` with WoW API |
| 193 | `OnEnable()` | Calls `Initialize()` |
| 197 | `OnDisable()` | Unregister events, unhook chat, cancel all tickers/timers |
| 221 | `Initialize()` | Create event frame, register 4 events, hook tooltip/chat, schedule initial broadcast, start cleanup + broadcast tickers |

**Registered events** (line 225-228): `GROUP_ROSTER_UPDATE`, `CHAT_MSG_ADDON`, `ZONE_CHANGED_NEW_AREA`, `PLAYER_TARGET_CHANGED`

### Messaging Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 286 | `BroadcastPresence` | `()` | Send PING to all channels (throttled by BROADCAST_INTERVAL) |
| 339 | `SendDirectMessage` | `(target, msgType, data)` | WHISPER to specific player |
| 348 | `BroadcastMessage` | `(msg)` | Raw message to all channels (for other modules) |
| 384 | `OnAddonMessage` | `(prefix, message, channel, sender)` | Dispatch incoming messages |

### Message Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 437 | `HandlePing` | `(sender, zoneData, channel)` | Register fellow, respond with PONG if not on cooldown |
| 489 | `HandlePong` | `(sender, data)` | Register/update fellow, request profile if not cached |
| 525 | `RequestProfile` | `(playerName)` | Send PREQ with cooldown check |
| 545 | `HandleProfileRequest` | `(sender)` | Serialize and send own profile if sharing enabled |
| 559 | `HandleProfileData` | `(sender, data)` | Deserialize and cache received profile |

### Profile Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 583 | `SerializeProfile` | `(profile)` -> `string` | Encode profile for transmission |
| 623 | `DeserializeProfile` | `(data)` -> `table\|nil` | Decode received profile |
| 787 | `GetFellowProfile` | `(name)` -> `table\|nil` | Get cached profile (checks 1-hour expiry) |
| 1476 | `GetMyProfile` | `()` -> `table\|nil` | Get player's own profile from charDb |
| 1485 | `UpdateMyProfile` | `(updates)` | Merge updates into own profile |
| 1500 | `GetStatusInfo` | `(statusId)` -> `table\|nil` | Lookup STATUS_OPTIONS by id |

### Fellow Management Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 686 | `RegisterFellow` | `(name, info)` | Create/update fellow. New discovery: play sound, print message, check companion online |
| 763 | `GetFellow` | `(name)` -> `table\|nil` | Get fellow data from charDb |
| 775 | `IsFellow` | `(name)` -> `boolean` | Check if player is a fellow |
| 1339 | `GetFellowCount` | `()` -> `number` | Count fellows in charDb |

### Cleanup Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 805 | `CleanupTables` | `()` | Prune pingCooldowns (expired + overflow), profileRequestCooldowns, old fellows (30d). Clear profile caches if >200 fellows |
| 865 | `AddPingCooldown` | `(name)` | Add entry with proactive oldest-eviction if at limit |
| 893 | `AddProfileRequestCooldown` | `(name)` | Add entry with proactive eviction if >=100 entries |

### Tooltip Integration

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 917 | `OnTooltipSetUnit` | `(tooltip)` (local) | Module-scope tooltip handler. Shows Fellow Traveler badge, title, profile excerpt, personality, appearance, RP hooks, pronouns, first seen date |
| 1008 | `HookTooltip` | `()` | Guard against double-hook, warn about tooltip addon conflicts, hook `GameTooltip:OnTooltipSetUnit` |

### Chat Coloring

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1033 | `HookChat` | `()` | Hook all `NUM_CHAT_WINDOWS` chat frames (if colorChat enabled). Warns about chat addon conflicts |
| 1059 | `HookChatFrame` | `(chatFrame)` | Replace `AddMessage` with fellow name coloring wrapper. Stores original in `chatFrame._hopeOriginalAddMessage` |
| 1078 | `UnhookChat` | `()` | Restore original `AddMessage` on all hooked frames (prevents closure layering) |
| 1096 | `ColorFellowNames` | `(msg)` -> `string` | Extract bracketed names `[Name]`, color matching fellows. Handles both simple brackets and player links |

### Event Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1146 | `OnPartyChanged` | `()` | Detect new party members, update known travelers, re-register existing fellows |
| 1199 | `OnZoneChanged` | `()` | Schedule broadcast after 2s delay |
| 1204 | `OnTargetChanged` | `()` | Request profile if targeting a fellow without cached profile |

### Legacy/Compatibility Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 1225 | `GetPartyMembers` | `()` -> `table` | Get current party/raid members as array |
| 1267 | `UpdateKnownTraveler` | `(name, class, level, isNewGroup)` | Update `charDb.travelers.known` entry, increment groupCount |
| 1303 | `GetTraveler` | `(name)` -> `table\|nil` | Get from `charDb.travelers.known` |
| 1314 | `GetAllTravelers` | `()` -> `table` | Get all from `charDb.travelers.known` |
| 1323 | `GetTravelerCount` | `()` -> `number` | Count known travelers |
| 1355 | `FormatPartyForDisplay` | `()` -> `string` | Class-colored comma-separated party names (or "Solo") |
| 1378 | `GetPartySnapshot` | `()` -> `table` | Party composition snapshot for milestone recording |
| 1397 | `GetRecentTravelers` | `(days)` -> `table` | Known travelers seen within N days, sorted newest first |
| 1440 | `IsGuildGroup` | `()` -> `boolean` | True if >50% of party are guild members |

---

## 6. Profile Serialization Format

**Serialize** (FellowTravelers.lua:583-616), **Deserialize** (line 623-675)

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
| 34 | `GetAllEntries` | `()` -> `table` | Build entries from `charDb.travelers.fellows` (Fellow Travelers only) |
| 57 | `BuildEntry` | `(name, data, isFellow)` -> `table` | Standardize raw data into display entry. Includes Relationships note lookup |
| 88 | `GetFilteredEntries` | `(filter, sortOption)` -> `table` | Filter by name/class/zone text, then sort |
| 122 | `SortEntries` | `(entries, sortOption)` | In-place sort by 8 options. All use alphabetical name as tiebreaker |
| 184 | `GetILvlColor` | `(ilvl)` -> `string` | Hex color by gear tier (grey/white/green/blue/purple) |
| 197 | `GetEntryCount` | `()` -> `number` | Optimized count (no full entry build) |
| 215 | `GetFellowCount` | `()` -> `number` | Count fellows (same as GetEntryCount since only fellows shown) |
| 230 | `GetEntry` | `(name)` -> `table\|nil` | Find specific entry by name (builds all entries, O(n)) |
| 246 | `IsPlayerNearby` | `(name)` -> `boolean` | Check party/raid for player (best-effort) |

### Statistics & Display Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 276 | `GetStats` | `()` -> `table` | Returns `{ fellows, byClass, recentCount }` (seen in last 7 days) |
| 308 | `FormatEntryForDisplay` | `(entry)` -> `table` | Returns `{ name, coloredName, classColor, colorHex, levelText, locationText, statusText, lastSeenText, hasNote }` |
| 352 | `GetClassIcon` | `(class)` -> `string` | Class icon path from cached lookup table |

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 360 | `OnInitialize()` | No-op |
| 364 | `OnEnable()` | Debug log |
| 368 | `OnDisable()` | No-op |

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

### Module State (Guild.lua:60-67)

```lua
Guild.eventFrame = nil          -- WoW event frame
Guild.listeners = {}            -- { [id] = callback } registered UI listeners
Guild.listenerCount = 0         -- Listener count (maintained manually)
Guild.previousRoster = {}       -- For change detection (unused - declared but never read)
Guild.lastRosterUpdate = 0      -- Unused - declared but guildData.lastRosterUpdate used instead
Guild.refreshTicker = nil       -- 30-second periodic roster refresh timer
Guild.isInitialized = false     -- Initialize guard
Guild.pendingRefresh = nil      -- Timer deduplication (unused - declared, cancelled in OnDisable, never set)
```

### Lifecycle Functions

| Line | Function | Purpose |
|------|----------|---------|
| 73 | `OnInitialize()` | No-op (charDb not available yet) |
| 77 | `OnEnable()` | Calls `Initialize()` |
| 81 | `OnDisable()` | Unregister events, cancel refreshTicker + pendingRefresh, clear listeners |
| 107 | `Initialize()` | Guard, EnsureGuildData, create event frame, register 4 events, initial roster request, store guild info, start 30s refresh ticker |

**Registered events** (line 115-118): `GUILD_ROSTER_UPDATE`, `PLAYER_GUILD_UPDATE`, `GUILD_MOTD`, `CHAT_MSG_GUILD`

### Data Structure Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 163 | `EnsureGuildData` | `()` -> `table\|nil` | Create/migrate `charDb.guild` schema with defaults |
| 200 | `GetGuildData` | `()` -> `table\|nil` | Alias for EnsureGuildData |

### Event Handlers

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 212 | `OnGuildRosterUpdate` | `()` | Cache all guild members, detect activity changes (login/logout/zone/level/rank/join/leave), update guild info, notify listeners |
| 311 | `OnPlayerGuildUpdate` | `()` | Join -> request roster; Leave -> clear roster. Notify listeners "membership" |
| 327 | `OnGuildMOTD` | `(motd)` | Store MOTD, notify listeners "motd" |
| 340 | `OnGuildChat` | `(message, sender)` | Placeholder for future chat parsing |
| 348 | `ClearRoster` | `()` | Wipe roster, clear guild info, notify listeners "membership" |

### Activity Tracking Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 370 | `RecordActivity` | `(activityType, playerName, data)` | Insert at beginning, trim to MAX_ACTIVITY_ENTRIES, clean old |
| 398 | `CleanOldActivity` | `()` | Remove entries older than ACTIVITY_RETENTION_DAYS from end |
| 416 | `FormatActivity` | `(entry)` -> `string` | Format using ACTIVITY_MESSAGES template strings |
| 436 | `GetRecentActivity` | `(limit)` -> `table` | Return up to `limit` entries (default 20) |

**Activity entry schema:**

```lua
{
    type = "LOGIN",          -- ACTIVITY_TYPE value
    player = "PlayerName",   -- Short name
    data = nil,              -- Extra: level (LEVELUP), zone (ZONE), rank (RANK)
    timestamp = 1740000000,  -- time()
}
```

**Activity detection** (OnGuildRosterUpdate:253-277):

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
| 458 | `GetRoster` | `()` -> `table` | Array of all member entries from guildData.roster |
| 489 | `GetSortedRoster` | `(sortBy)` -> `table` | Sort by: "online" (default), "name", "rank", "level", "class", "ilvl" |
| 554 | `GetFilteredRoster` | `(filter, sortBy)` -> `table` | Filter by showOffline, rankFilter, classFilter, searchText |
| 606 | `GetMember` | `(name)` -> `table\|nil` | Direct lookup from guildData.roster |
| 616 | `GetOnlineCount` | `()` -> `number` | Count online members |
| 633 | `GetMemberCount` | `()` -> `number` | Count total members |

### Guild Info Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 648 | `GetGuildName` | `()` -> `string` | Guild name or "" |
| 657 | `GetMOTD` | `()` -> `string` | Message of the day or "" |
| 667 | `IsGuildMember` | `(name)` -> `boolean` | Check roster for name |
| 676 | `IsFellowTraveler` | `(name)` -> `boolean` | Delegates to `FellowTravelers:IsFellow(name)` |
| 685 | `GetRanks` | `()` -> `table` | Unique ranks from roster, sorted by rankIndex |

### Listener System

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 719 | `RegisterListener` | `(id, callback)` | Register callback for guild updates |
| 732 | `UnregisterListener` | `(id)` | Remove listener by id |
| 744 | `NotifyListeners` | `(eventType)` | Call all listeners with pcall safety. Events: "roster", "activity", "membership", "motd" |

### Settings Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 761 | `GetSortSetting` | `()` -> `string` | Get saved sort (default "online") |
| 770 | `SetSortSetting` | `(sortBy)` | Save sort preference |
| 781 | `GetShowOffline` | `()` -> `boolean` | Get offline visibility (default true) |
| 790 | `SetShowOffline` | `(show)` | Save offline visibility |
| 801 | `GetTrackActivity` | `()` -> `boolean` | Get activity tracking (default true) |
| 810 | `SetTrackActivity` | `(track)` | Save activity tracking |

### Utility Functions

| Line | Function | Signature | Purpose |
|------|----------|-----------|---------|
| 826 | `FormatRelativeTime` | `(timestamp)` -> `string` | "Just now", "2m ago", "1h ago", "3d ago" |
| 850 | `GetClassColor` | `(classToken)` -> `table` | `{ r, g, b }` from `RAID_CLASS_COLORS` |
| 864 | `RefreshRoster` | `()` | Force roster request via `RequestGuildRoster()` |

### API Compatibility (Guild.lua:48-54)

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

### Guild Sort Options (Guild.lua:489-543)

| Sort | Logic | Tiebreaker |
|------|-------|------------|
| `online` (default) | Online first | Name A-Z |
| `name` | Name A-Z | - |
| `rank` | rankIndex ascending | Name A-Z |
| `level` | Level descending | Name A-Z |
| `class` | Class name ascending | Name A-Z |
| `ilvl` | avgILvl descending (via FellowTravelers lookup) | Name A-Z |

### iLevel Color Tiers (Directory.lua:184-190)

| Tier | Range | Hex | Quality |
|------|-------|-----|---------|
| Gray | <= 0 / nil | `555555` | No data |
| White | 1-99 | `FFFFFF` | Leveling |
| Green | 100-114 | `1eff00` | Pre-raid |
| Blue | 115-129 | `0070dd` | T4+ |
| Purple | >= 130 | `a335ee` | T5+ |

---

## 10. UI Components (Journal.lua)

### CreateTravelerRow iLevel Display

**File:** `Journal/Journal.lua:11578-11590`

- Position: RIGHT side of row, -120px offset
- Font: HEADER font, size 10
- Format: `"XXX iLvl"` (e.g. `"115 iLvl"`)
- Color: `Directory:GetILvlColor(entry.avgILvl)`
- Fallback: `"--"` in gray (`555555`) when no data

### Rank Indicators (#1-#3 Medals)

When sorted by iLevel, top 3 travelers display medal indicators: #1 Gold, #2 Silver, #3 Bronze.

### CreateGuildMemberRow iLevel Display

**File:** `Journal/Journal.lua:10840-10852`

- Same format as traveler row
- Looks up `FellowTravelers:GetFellow(member.name)` for gear data
- Members without addon show `"--"` in gray

### Guild Member Row Tooltip

**File:** `Journal/Journal.lua:10892-10899`

- `Avg iLevel` line uses `GetILvlColor()` RGB values
- `Gear Score` line in gray (0.7, 0.7, 0.7) - only if > 0
- Only shown when Fellow Traveler data exists

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
| 596-600 | `Romance:GetStatus()` | Romance | Include in profile serialization |
| 720-724 | `Companions:IsCompanion(name)` | Companions | Check companion status on fellow re-registration |
| 723 | `SocialToasts:Show("companion_online", name)` | SocialToasts | Show companion online notification |
| 428-431 | `Minigames:IsMinigameMessage()` / `HandleMessage()` | Minigames | Forward unhandled messages |
| 298 | `HopeAddon:GetGearScore()` | Core | Include gear data in broadcasts |
| 702 | `HopeAddon:PlaySound("FELLOW_DISCOVERY")` | Core/Sounds | Murloc discovery sound |

### Guild -> External Modules

| Line | Integration | Target Module | Purpose |
|------|------------|---------------|---------|
| 527-542 | `FellowTravelers:GetFellow(name)` | FellowTravelers | iLvl sort lookup for guild members |
| 676-679 | `FellowTravelers:IsFellow(name)` | FellowTravelers | Check if guild member has addon |
| 145-149 | `HopeAddon.Timer:NewTicker()` | Core/Timer | Periodic roster refresh |

### Directory -> External Modules

| Line | Integration | Target Module | Purpose |
|------|------------|---------------|---------|
| 58-59 | `Relationships:GetNote(name)` | Relationships | Attach player notes to entries |
| 309 | `HopeAddon:GetClassColor(class)` | Core | Class color for display formatting |

---

## 13. Dead Code & Unused Features

| File | Line | Item | Status |
|------|------|------|--------|
| FellowTravelers.lua | 19 | `MSG_LOCATION = "LOC"` | Declared but never sent or handled |
| FellowTravelers.lua | 48 | `originalAddMessage` | Module state field, never read (actual refs stored per-frame as `chatFrame._hopeOriginalAddMessage`) |
| Guild.lua | 41 | `ONLINE_CHECK_INTERVAL = 60` | Declared but never used |
| Guild.lua | 63 | `previousRoster = {}` | Declared, never read (change detection done via `guildData.roster` instead) |
| Guild.lua | 64 | `lastRosterUpdate = 0` | Module-level field, unused (`guildData.lastRosterUpdate` used instead) |
| Guild.lua | 67 | `pendingRefresh = nil` | Declared and cancelled in OnDisable, but never assigned a value |
| Guild.lua | 340-343 | `OnGuildChat()` | Placeholder - parses nothing |

---

## Appendix: Function Count Summary

| Module | Category | Count | Functions |
|--------|----------|-------|-----------|
| **FellowTravelers.lua** | | | |
| Lifecycle | 4 | OnInitialize, OnEnable, OnDisable, Initialize |
| Messaging | 4 | BroadcastPresence, SendDirectMessage, BroadcastMessage, OnAddonMessage |
| Message Handlers | 5 | HandlePing, HandlePong, RequestProfile, HandleProfileRequest, HandleProfileData |
| Profile | 5 | SerializeProfile, DeserializeProfile, GetFellowProfile, GetMyProfile, UpdateMyProfile, GetStatusInfo |
| Fellow Management | 4 | RegisterFellow, GetFellow, IsFellow, GetFellowCount |
| Cleanup | 3 | CleanupTables, AddPingCooldown, AddProfileRequestCooldown |
| Tooltip | 2 | OnTooltipSetUnit (local), HookTooltip |
| Chat | 4 | HookChat, HookChatFrame, UnhookChat, ColorFellowNames |
| Events | 3 | OnPartyChanged, OnZoneChanged, OnTargetChanged |
| Legacy | 8 | GetPartyMembers, UpdateKnownTraveler, GetTraveler, GetAllTravelers, GetTravelerCount, FormatPartyForDisplay, GetPartySnapshot, GetRecentTravelers, IsGuildGroup |
| Callbacks | 2 | RegisterMessageCallback, UnregisterMessageCallback |
| **FellowTravelers subtotal** | **44** | |
| **Directory.lua** | | | |
| Data Access | 5 | GetAllEntries, BuildEntry, GetFilteredEntries, SortEntries, GetILvlColor |
| Queries | 4 | GetEntryCount, GetFellowCount, GetEntry, IsPlayerNearby |
| Stats/Display | 3 | GetStats, FormatEntryForDisplay, GetClassIcon |
| Lifecycle | 3 | OnInitialize, OnEnable, OnDisable |
| **Directory subtotal** | **15** | |
| **Guild.lua** | | | |
| Lifecycle | 4 | OnInitialize, OnEnable, OnDisable, Initialize |
| Data | 2 | EnsureGuildData, GetGuildData |
| Events | 5 | OnGuildRosterUpdate, OnPlayerGuildUpdate, OnGuildMOTD, OnGuildChat, ClearRoster |
| Activity | 4 | RecordActivity, CleanOldActivity, FormatActivity, GetRecentActivity |
| Roster | 6 | GetRoster, GetSortedRoster, GetFilteredRoster, GetMember, GetOnlineCount, GetMemberCount |
| Info | 5 | GetGuildName, GetMOTD, IsGuildMember, IsFellowTraveler, GetRanks |
| Listeners | 3 | RegisterListener, UnregisterListener, NotifyListeners |
| Settings | 6 | GetSortSetting, SetSortSetting, GetShowOffline, SetShowOffline, GetTrackActivity, SetTrackActivity |
| Utility | 3 | FormatRelativeTime, GetClassColor, RefreshRoster |
| API Compat | 1 | RequestGuildRoster (local) |
| **Guild subtotal** | **39** | |
| | | | |
| **Grand total** | **98 functions** | (+ 5 local helpers in FellowTravelers, 1 local in Guild) |
