# HopeAddon Module API Reference

Complete module APIs, data schemas, and architectural details. For quick reference, see [CLAUDE.md](CLAUDE.md).

---

## Module API Documentation

### Guild Module (Guild Hall)

- **Purpose**: Track ALL guild members without requiring addon - uses WoW's built-in guild API
- **Theme**: "Guild Hall" - RP-flavored member roster and activity chronicles
- **Data Source**: `GetGuildRosterInfo()`, `GuildRoster()` WoW API calls
- **Events**: `GUILD_ROSTER_UPDATE`, `PLAYER_GUILD_UPDATE`, `GUILD_MOTD`

**Activity Types:**
- LOGIN: "[Name] has entered the hall"
- LOGOUT: "[Name] has departed for distant lands"
- LEVELUP: "[Name] has grown stronger (Level X)"
- ZONE: "[Name] ventures into [Zone]"
- RANK: "[Name] has been promoted to [Rank]"
- JOIN/LEAVE: Member joined/left guild

**Key Public API:**
- `GetGuildData()` - Get full guild data table
- `GetRoster()` / `GetSortedRoster(sortBy)` - Get member list
- `GetFilteredRoster(filter, sortBy)` - Get filtered roster
- `GetMember(name)` - Get specific member data
- `GetOnlineCount()` / `GetMemberCount()` - Statistics
- `GetGuildName()` / `GetMOTD()` - Guild info
- `GetRecentActivity(limit)` - Get activity chronicle entries
- `IsFellowTraveler(name)` - Check if guild member also has addon
- `RegisterListener(id, callback)` / `UnregisterListener(id)` - UI updates

**Integration with Fellow Travelers:**
- Guild members WITH addon get [GF] badge and enhanced features
- Guild members WITHOUT addon get [G] badge and basic roster info
- `IsFellowTraveler()` checks both systems for combined features

**Stores:** `charDb.guild.roster`, `charDb.guild.activity`, `charDb.guild.settings`

---

### FellowTravelers Module (Communication Hub)

- Addon prefix: `HOPEADDON`, protocol version 1
- Message types: PING, PONG, PREQ (profile request), PROF (profile data), LOC (location)
- Key public API:
  - `IsFellow(name)` - Check if player uses the addon
  - `GetFellow(name)` / `GetFellowProfile(name)` - Get fellow data
  - `GetTraveler(name)` / `GetAllTravelers()` - Get any known player
  - `GetPartyMembers()` - Get current party/raid members
  - `GetPartySnapshot()` - Snapshot with timestamps for shared achievements
  - `GetMyProfile()` / `UpdateMyProfile(updates)` - Manage own RP profile
  - `RegisterMessageCallback(id, matchFunc, handler)` - For other modules to receive messages
- Stores: `charDb.travelers.known`, `charDb.travelers.fellows`, `charDb.travelers.myProfile`

---

### Directory Module

- Combines `travelers.known` + `travelers.fellows` into unified list
- Sort options: name (A-Z/Z-A), class, level (high/low), last seen
- Search filters by name, class, or zone
- Integrates with Relationships for note display (`hasNote` field)
- Read-only module - does not write to SavedVariables
- Key functions:
  - `GetAllEntries()` - Get all directory entries
  - `GetFilteredEntries(filter, sort)` - Get filtered/sorted entries
  - `GetEntry(name)` - Get specific player entry
  - `GetEntryCount()` - Optimized count without building entries
  - `GetFellowCount()` - Count addon users only
  - `GetStats()` - Statistics: total, fellows, byClass, recentCount
  - `FormatEntryForDisplay(entry)` - Format for UI display
  - `IsPlayerNearby(name)` - Check if player in party/raid

---

### Relationships Module

- Simple key-value note storage: `charDb.relationships[playerName] = { note, addedDate }`
- 256 character note limit (NOTE_MAX_LENGTH)
- Key functions:
  - `GetNote(name)` / `SetNote(name, note)` / `RemoveNote(name)` / `HasNote(name)` - CRUD
  - `GetRelationship(name)` - Get full data { note, addedDate }
  - `GetAllNotes()` - Get all notes dictionary
  - `GetNoteCount()` - Count of players with notes
  - `GetPlayersWithNotes()` - Sorted array of player names
  - `SearchNotes(text)` - Search notes by name or content
  - `AddNoteFromTarget(note)` - Add note for current target
  - `AddNoteFromChat(name, note)` - Add note from chat link
  - `ExportNotes()` / `ImportNotes(data)` - Backup/restore
- Integrates with Directory for UI display

---

### ActivityFeed Module

- "Tavern Notice Board" - Activity feed for social events
- Activity types: STATUS, BOSS, LEVEL, GAME, BADGE, RUMOR, MUG, LOOT, ROMANCE, IC_POST, ANON
- Wire protocol: `ACT:version:type:player:class:data:time` (~20-50 bytes)
- Limits: 50 max entries, 48-hour retention
- Broadcast interval: 30 seconds via `broadcastTicker`

**Network Architecture:**
```
Outgoing: QueueForBroadcast() -> BroadcastActivities() -> FellowTravelers:BroadcastMessage()
                                       |
                              SerializeActivity() -> "ACT:1:BOSS:Player:CLASS:data:time"
                                       |
                              AddToFeed() (own copy) + NotifyListeners()

Incoming: CHAT_MSG_ADDON -> FellowTravelers:OnAddonMessage()
                                       |
                              strsplit(":", message, 3) -> msgType, version, data
                                       |
                              Callback match(msgType=="ACT") -> handler(msgType, sender, data)
                                       |
                              ActivityFeed:HandleNetworkActivity(sender, data)
                                       |
                              Parse data directly -> AddToFeed() -> NotifyListeners()
```

**Listener System** (for real-time UI updates):
  - `RegisterListener(id, callback)` - Register to receive activity notifications
  - `UnregisterListener(id)` - Remove listener
  - `NotifyListeners(count)` - Internal: calls all registered listeners
- Key functions:
  - `PostRumor(text)` - Post manual status (5-min cooldown, 100 char max)
  - `CanPostRumor()` - Check cooldown status
  - `GiveMug(activityId)` - React to an activity
  - `HasMugged(activityId)` - Check if already mugged
  - `GetFeed()` / `GetRecentFeed(max)` - Get activities
  - `FormatActivity(activity)` - Get display string
  - `GetRelativeTime(timestamp)` - "2m", "1h", "3d" format
  - `OnRomanceEvent(eventType, partnerName, reason)` - Called by Romance module
- Stores: `charDb.social.feed`, `charDb.social.mugsGiven`, `charDb.social.myRumors`

---

### Companions Module

- Favorites list with request/accept/decline flow
- 50 max companions, 24h request expiry
- Online status based on FellowTravelers lastSeenTime (5-min threshold)
- Key functions:
  - `SendRequest(playerName)` - Send companion request
  - `AcceptRequest(playerName)` - Accept incoming request
  - `DeclineRequest(playerName)` - Decline request
  - `RemoveCompanion(playerName)` - Remove from list
  - `IsCompanion(playerName)` - Check status
  - `GetAllCompanions()` - Get all with online status
  - `GetIncomingRequests()` - Get pending requests
  - `GetOnlineCount()` / `GetCount()` - Statistics
- Network: COMP_REQ, COMP_ACC, COMP_DEC message types via FellowTravelers
- Stores: `charDb.social.companions.list`, `.outgoing`, `.incoming`

---

### SocialToasts Module

- Non-intrusive slide-in notifications from top right
- 5 second auto-dismiss, max 3 toasts stacked
- Toast types: companion_online, companion_nearby, companion_request, mug_received, companion_lfrp, fellow_discovered
- Key functions:
  - `Show(toastType, playerName, customMessage)` - Display toast
  - `DismissToast(frame)` - Manually dismiss
  - `DismissAll()` - Clear all toasts
- Uses frame pool for performance
- Settings: `charDb.social.toasts` (per-type toggles)

---

### Romance Module

- "Azeroth Relationship Status" - Facebook-style dating for WoW RP
- One exclusive partner at a time (monogamous)
- States: SINGLE -> PROPOSED (pending) -> DATING (accepted)
- 24-hour rejection cooldown, 7-day proposal expiry
- Key functions:
  - `ProposeToPlayer(playerName)` - Send proposal
  - `AcceptProposal(senderName)` - Accept incoming proposal
  - `DeclineProposal(senderName)` - Decline incoming proposal
  - `BreakUp(reason)` - End relationship
  - `CancelProposal()` - Cancel outgoing proposal
  - `GetStatus()` - Get current relationship status
  - `IsPartner(playerName)` - Check if player is current partner
  - `HasPendingProposal()` - Check for outgoing proposal
  - `GetPendingIncoming()` - Get array of incoming proposals
- Network: ROM_REQ, ROM_ACC, ROM_DEC, ROM_BRK message types via FellowTravelers WHISPER
- Stores: `charDb.social.romance` (status, partner, since, pendingOutgoing, pendingIncoming, cooldowns, history)
- Broadcasts breakups to ActivityFeed for timeline drama

---

### Calendar Module

- **Purpose**: Event scheduling for raids/dungeons/RP events with role-based signups
- **Files**: `Social/Calendar.lua` (logic), `Social/CalendarUI.lua` (UI)
- **Network**: CAL_CREATE, CAL_UPDATE, CAL_DELETE, CAL_SIGNUP via FellowTravelers

**Event Types & Color Coding:**
- RAID: Orange dots/stripes
- DUNGEON: Blue dots/stripes
- RP_EVENT: Purple dots/stripes
- OTHER: Grey dots/stripes

**Key Features:**
- Month grid with colored event indicators
- Event cards with type color stripes
- Event templates (save/load raid configurations)
- Signup Matrix UI (LOIHCal-inspired):
  - Needs Bar: Shows unfilled slots with role colors
  - Role Columns: Tank | Healer | DPS with status icons
  - Standby Section: Overflow signups when roles full

**Template API:**
- `SaveTemplate(eventId, name)` - Save event as template
- `LoadTemplate(templateId)` - Get template data
- `DeleteTemplate(templateId)` - Remove template
- `GetTemplatesList()` - Get sorted array of templates

**Signup API:**
- `GetSignupsByRole(event)` - Returns { role: { confirmed, tentative, standby } }
- `GetStandbySignups(event)` - Returns array of overflow signups
- `GetSignupCounts(event)` - Returns { role: { current, max } }
- `IsRoleFull(event, role)` - Check if role has slots

**Stores:** `charDb.social.calendar` (myEvents, fellowEvents, mySignups, templates, settings)

---

### CalendarValidation Module

- **Purpose**: Enforces rules for calendar event creation and signup attempts
- **File**: `Social/CalendarValidation.lua`
- **Integration**: Called by Calendar.lua CreateEvent() and SignUp()

**Validation Rules (configurable via `C.CALENDAR_VALIDATION`):**
- `MIN_NOTICE_MINUTES = 30` - Events must be 30+ minutes in future
- `MAX_FUTURE_DAYS = 60` - Events cannot be more than 60 days ahead
- `MAX_SIGNUPS_PER_PLAYER = 5` - Limits concurrent signups
- `ALLOW_PAST_EVENTS = false` - Prevents past date events
- `ENFORCE_ROLE_LIMITS = true` - Auto-assigns standby when role full
- `ENFORCE_RAID_SIZE = true` - Enforces total raid size cap

**Key Functions:**
- `ValidateEventCreate(eventData)` - Returns isValid, errors
- `ValidateSignup(eventId, playerName, role)` - Returns isValid, errors, shouldStandby
- `FindTimeConflicts(playerName, newEvent)` - Returns array of conflicting events
- `CountPlayerSignups(playerName)` - Returns count of active signups
- `GetEventTimestamp(eventData)` - Converts date/time to Unix timestamp

---

### Treasures (Soft Reserve) Module

- **Purpose**: Soft Reserve (SR) loot system for guild raids
- **File**: `Social/Treasures.lua`
- **Network**: SRLIST, SRUPD, SRQRY message types via FellowTravelers

**SR Rules:**
- SR 1 system: One reserve per raid per weekly lockout
- Resets with WoW raid lockouts (Tuesday 11 AM server time)
- Phase 1 raids: karazhan, gruul, magtheridon

**Key API:**
- `SetReserve(raidKey, itemName, itemIcon, bossId, bossName)` - Set soft reserve
- `ClearReserve(raidKey)` - Clear a reserve
- `GetReserve(raidKey)` - Get player's reserve for a raid
- `GetAllReserves()` - Get all active reserves
- `HasReserve(raidKey)` - Check if player has a reserve
- `GetGuildReserves(raidKey)` - Get guild members' reserves
- `GetContenders(raidKey, itemName)` - Get list of players who reserved an item
- `IsItemContested(raidKey, itemName)` - Check if item has multiple reserves
- `GetReservableItems(raidKey)` - Get loot table for a raid
- `GetTimeUntilReset()` - Human-readable time until weekly reset

**Listener System:**
- `RegisterListener(id, callback)` - Register for SR updates
- `UnregisterListener(id)` - Remove listener
- Callback receives (action, data) where action is "SET", "CLEAR", or "GUILD_UPDATE"

**Network Protocol:**
- SR_UPDATE: `raidKey|itemName` - Single item update
- SR_LIST: `raid1:item1,raid2:item2,...` - Full SR list
- SR_QUERY: `REQUEST` - Request guild data

**Stores:** `charDb.social.treasures` (reserves, history, guildReserves, settings)

---

## Data Structures

### Character Data (`HopeAddonCharDB`)

```lua
{
    journal = {
        entries = {},              -- All journal entries chronologically
        levelMilestones = {},      -- [level] = entry
        bossKills = {},            -- [bossName] = count
        attunementMilestones = {}, -- [raidKey] = entry
        bossMilestones = {},       -- [tierKey] = entry
        tierMilestones = {},       -- [tierKey] = entry
        lastTab = "timeline",
    },
    attunements = {
        karazhan = { started = bool, completed = bool, chapters = { [questId] = true } },
        ssc = { ... }, tk = { ... }, hyjal = { ... }, bt = { ... }, cipher = { ... }
    },
    stats = {
        deaths = { total = 0, byZone = {}, byBoss = {} },
        playtime = 0,
        questsCompleted = 0,
        creaturesSlain = 0,
        largestHit = 0,
        dungeonRuns = { [dungeonKey] = { normal = 0, heroic = 0 } }
    },
    guild = {
        name = "",                 -- Guild name
        rank = "",                 -- Player's rank name
        rankIndex = 0,             -- Player's rank index
        roster = {
            [playerName] = {
                level = 70,
                class = "Warrior",
                classToken = "WARRIOR",
                zone = "Shattrath",
                isOnline = true,
                lastOnline = 1705334400,
                note = "",
                officerNote = "",
                rank = "Member",
                rankIndex = 3,
            }
        },
        activity = {
            -- Array of { type, player, data, timestamp }
            { type = "LOGIN", player = "Name", timestamp = time() },
        },
        motd = "",
        lastRosterUpdate = 0,
        settings = {
            trackActivity = true,
            showOffline = true,
            sortBy = "online",
        },
    },
    travelers = {
        known = {
            [playerName] = {
                class = "WARRIOR",
                level = 70,
                lastSeen = "2024-01-15",
                lastSeenZone = "Shattrath",
                lastSeenTime = 1705334400,
                firstSeen = "2024-01-10",
                selectedColor = "FF8000",
                selectedTitle = "Hero",
                profile = { backstory, personality, ... },
                icons = { [iconId] = { earnedDate, earnedTimestamp, context } },
                stats = { minigames = { dice = {...}, rps = {...} } },
            },
        },
        fellows = {},              -- Same structure
        myProfile = {
            backstory = "",
            personality = {},
            appearance = "",
            rpHooks = "",
            pronouns = "",
            status = "OOC",
            selectedTitle = nil,
            selectedColor = nil,
        },
        badges = {},
        fellowSettings = { enabled = true, colorChat = true, shareProfile = true, showTooltips = true },
    },
    reputation = {
        milestones = {},           -- [faction][standing] = entry
        currentStandings = {},     -- [faction] = standing
        aldorScryerChoice = nil    -- "aldor" | "scryer" | nil
    },
    relationships = {
        [playerName] = {
            note = "Friendly healer, met in Karazhan",
            addedDate = "2024-01-15",
            updatedDate = "2024-01-20",
        },
    },
    savedGames = {
        words = {
            games = {},             -- [opponentName] = serialized game state
            pendingInvites = {},    -- [senderName] = { state, timestamp }
            sentInvites = {},       -- [recipientName] = { state, timestamp }
        },
    },
    social = {
        feed = {},                 -- Activity feed entries
        mugsGiven = {},            -- [activityId] = true
        myRumors = {},             -- Posted rumors
        companions = {
            list = {},             -- [playerName] = { addedDate }
            outgoing = {},         -- Pending outgoing requests
            incoming = {},         -- Pending incoming requests
        },
        romance = {
            status = "SINGLE",     -- SINGLE | PROPOSED | DATING
            partner = nil,
            since = nil,
            pendingOutgoing = nil,
            pendingIncoming = {},
            cooldowns = {},
            history = {},
        },
        calendar = {
            myEvents = {},
            fellowEvents = {},
            mySignups = {},
            templates = {},
            settings = {},
        },
        treasures = {
            reserves = {},
            history = {},
            guildReserves = {},
            settings = {},
        },
    },
}
```

### Account Data (`HopeAddonDB`)

```lua
{
    version = "1.0.0",
    debug = false,
    settings = {
        soundEnabled = true,
        glowEnabled = true,
        animationsEnabled = true,
        notificationsEnabled = true,
        hideUIDuringCombat = true,
    },
    minimapButton = {
        position = 225,  -- Angle in degrees
        enabled = true,
    }
}
```

---

## Social Tab Architecture

The Social tab uses a sub-tabbed interface with five tabs: Guild, Travelers, Companions, Calendar, and Feed.

**Two-Tier System:**
- **Guild Tier** (No addon required): All guild members via WoW API
- **Fellow Travelers Tier** (Addon required): Addon users across all guilds with RP features

### Container Structure

```lua
Journal.socialContainers = {
    statusBar = nil,      -- Top status bar with profile info
    tabBar = nil,         -- Sub-tab buttons (Guild, Travelers, Companions, Calendar, Feed)
    content = nil,        -- Main content area (cleared on tab/filter switch)
    scrollFrame = nil,    -- Scroll frame wrapper
}

Journal.socialSubTabs = {
    guild = nil,          -- Guild Hall tab button
    travelers = nil,      -- Fellow Travelers directory tab button
    companions = nil,     -- Companions list tab button
    calendar = nil,       -- Calendar tab button
    feed = nil,           -- Activity feed tab button
}

Journal.quickFilterButtons = {}      -- Filter buttons for Travelers/Guild tabs
Journal.socialContentRegions = {}    -- FontStrings/Textures for manual cleanup
```

### Content Clearing (CRITICAL)

**Before repopulating any social content, you MUST call `ClearSocialContent()`**

```lua
function Journal:ClearSocialContent(preserveFilterBar)
    -- Clears all child frames from content container
    -- Clears all tracked regions (FontStrings, Textures)
    -- Prevents frame stacking when switching filters/tabs
    -- If preserveFilterBar=true, keeps the filter bar
end
```

**When to preserve filter bar:**
- `ClearSocialContent(true)` - When refreshing list (filter change only)
- `ClearSocialContent()` - When switching sub-tabs (clears everything)

### Populate Functions

| Function | Purpose | Triggers |
|----------|---------|----------|
| `PopulateSocialGuild()` | Guild Hall roster and activity chronicles | Guild tab select, filter change |
| `PopulateSocialTravelers()` | Fellow Traveler directory with filters | Travelers tab select, filter change |
| `PopulateSocialCompanions()` | Companions list with requests | Companions tab select, accept/decline |
| `PopulateSocialFeed()` | Activity feed with rumors, mugs | Feed tab select, refresh |

### Filter System (Travelers Tab)

State stored in `HopeAddon:GetSocialUI().travelers`:
```lua
{
    quickFilter = "all",     -- "all", "online", "party", "lfrp"
    searchText = "",         -- Search box text
    sortOption = "last_seen" -- Sort order
}
```

### Refresh Flow

```
User clicks filter -> SetQuickFilter(filterId)
                          |
                          +- Update socialUI.travelers.quickFilter
                          +- Update button visuals (on preserved buttons)
                          +- RefreshTravelersList()
                                    |
                                    +- ClearSocialContent(true)  <- preserves filter bar
                                    +- PopulateSocialTravelers()
                                              |
                                              +- GetFilteredTravelerEntries(filter)
                                              +- Reuse existing filterBar OR create new
                                              +- UpdateQuickFilterCounts() (if reusing)
                                              +- CreateTravelerRow() for each entry
```

### Region Tracking

FontStrings and Textures are NOT returned by `frame:GetChildren()`, so they must be tracked manually:

```lua
-- When creating a FontString/Texture on social content:
local text = content:CreateFontString(nil, "OVERLAY")
self:TrackSocialRegion(text)  -- Adds to socialContentRegions for cleanup
```

---

## Reputation Tab Infrastructure

The Reputation tab has dedicated state containers and pooling for efficient UI management.

### State Containers

```lua
Journal.reputationUI = {
    categoryBar = nil,      -- Category filter bar frame
    categoryButtons = {},   -- References to category filter buttons
}

Journal.reputationState = {
    selectedCategory = nil,  -- Last viewed category (e.g., "hellfire")
    expandedFactions = {},   -- { [factionName] = true } for collapsible sections
}
```

### Pool

| Pool | Frame Type | Purpose |
|------|------------|---------|
| `reputationBarPool` | SegmentedReputationBar | Neutral->Exalted progress bars |

### Key Functions

```lua
Journal:CreateReputationBarPool()   -- Pool initialization (OnEnable)
Journal:AcquireReputationBar(parent, width)  -- Get bar from pool
Journal:HideReputationTab()         -- Save state, release bars (SelectTab)
```

### Lifecycle

```
OnEnable -> CreateReputationBarPool()
SelectTab(reputation) -> PopulateReputation() -> AcquireReputationBar() per faction
SelectTab(other) -> HideReputationTab() -> ReleaseAll() + save state
```

---

## Event Flow Examples

**Player reaches level 30:**
```
PLAYER_LEVEL_UP -> Journal:OnLevelUp(30)
                  +- Adds entry to charDb.journal.entries
                  +- Calls Badges:OnPlayerLevelUp(30)
```

**Player kills raid boss:**
```
COMBAT_LOG_EVENT_UNFILTERED -> RaidData:OnCombatLogEvent()
                               +- Matches NPC ID in C.BOSS_NPC_IDS
                               +- Adds journal entry
                               +- Calls Badges:OnBossKilled(bossName)
```

---

## WoW Event Handlers by Module

| Module | Events | Purpose |
|--------|--------|---------|
| **Core.lua** | ADDON_LOADED, PLAYER_LOGIN, PLAYER_LOGOUT | Init, enable/disable modules |
| **Journal.lua** | PLAYER_LEVEL_UP, QUEST_TURNED_IN, PLAYER_DEAD, TIME_PLAYED_MSG, COMBAT_LOG_EVENT_UNFILTERED, SKILL_LINES_CHANGED | Track all player activities |
| **RaidData.lua** | ENCOUNTER_END, COMBAT_LOG_EVENT_UNFILTERED | Boss kill detection |
| **Reputation.lua** | UPDATE_FACTION, PLAYER_LOGIN | Reputation changes |
| **FellowTravelers.lua** | GROUP_ROSTER_UPDATE, GUILD_ROSTER_UPDATE, CHAT_MSG_ADDON, ZONE_CHANGED_NEW_AREA, PLAYER_TARGET_CHANGED | Player detection & communication |
| **Minigames.lua** | CHAT_MSG_SYSTEM | Detect /roll results |
| **DeathRollGame.lua** | CHAT_MSG_SYSTEM | Detect /roll results |
| **DeathRollEscrow.lua** | TRADE_SHOW, TRADE_MONEY_CHANGED, TRADE_ACCEPT_UPDATE, TRADE_CLOSED | Escrow trading |
| **MapPins.lua** | ZONE_CHANGED_NEW_AREA, ZONE_CHANGED | Update minimap pins |

---

## Words with WoW Scoring System

### PlaceWord() Function Flow (WordGame.lua:490-644)

```
PlaceWord(gameId, word, horizontal, startRow, startCol, playerName)
+- VALIDATION (498-521)
|  +- Game exists and not finished
|  +- Player's turn check
|  +- Word in dictionary (WordDictionary:IsValidWord)
|  +- Valid placement (CanPlaceWord)
|
+- PLACEMENT (524-530)
|  +- board:PlaceWord() -> returns placedTiles array
|  +- Invalidate cached rows
|
+- CROSS-WORD DETECTION & VALIDATION (530-541)
|  +- board:FindFormedWords(placedTiles, horizontal)
|  +- Validate ALL formed words in dictionary (undo if any invalid)
|
+- SCORING (545-563)
|  +- Loop: CalculateWordScore() for each formed word
|  +- Store wordData.score for each word
|  +- Sum into totalScore
|  +- Add BINGO bonus (+35) if 7 tiles placed
|
+- NOTIFICATIONS (597-628)
|  +- Print main: "[Player] played '[word]' for [score] points!"
|  +- Print cross-words with scores: "Cross-words: WORD (+X), ..."
|  +- Sound effects (4 tiers based on score)
|  +- ShowScoreToast (floating visual)
|
+- TURN ADVANCE & NETWORK (631-644)
```

### Base Tile Values (WordDictionary.lua)

| Points | Letters |
|--------|---------|
| 1 | A, E, I, L, N, O, R, S, T, U |
| 2 | D, G |
| 3 | B, C, M, P |
| 4 | F, H, V, W, Y |
| 5 | K |
| 8 | J, X |
| 10 | Q, Z |

### Bonus Squares (WordBoard.lua:28-45)

| Type | Effect | Locations |
|------|--------|-----------|
| DOUBLE_LETTER (DL) | Letter x 2 | Scattered across board |
| TRIPLE_LETTER (TL) | Letter x 3 | Diagonal lines |
| DOUBLE_WORD (DW) | Word x 2 | Diagonals from corners |
| TRIPLE_WORD (TW) | Word x 3 | 8 corners/edges |
| CENTER | Word x 2 | Position (8,8) |

**Critical Rule:** Bonuses ONLY apply to newly placed tiles (not existing)

### CalculateWordScore Algorithm (WordBoard.lua:258-296)

```lua
wordScore = 0
wordMultiplier = 1

for each letter in word:
    letterValue = GetLetterValue(letter)
    if isNewTile[position]:
        -- Letter bonuses applied immediately
        if DL: letterValue *= 2
        if TL: letterValue *= 3
        -- Word bonuses collected
        if DW or CENTER: wordMultiplier *= 2
        if TW: wordMultiplier *= 3
    wordScore += letterValue

return wordScore * wordMultiplier
```

### Special Bonuses & Thresholds

- **BINGO Bonus:** +35 points for placing 7 tiles in one turn (C.WORDS_BINGO_BONUS)
- **Score Thresholds (C.WORDS_SCORE_THRESHOLDS):**
  - GOOD (>=20): PlayNewEntry sound
  - GREAT (>=30): PlayBell sound
  - AMAZING (>=50): PlayAchievement sound

### Cross-Word Detection (WordBoard.lua:304-436)

- **Main word:** Extends from placed tiles in placement direction
- **Cross-words:** For each newly placed tile, check perpendicular direction
- **Filter:** Only words >= 2 letters included
- **Output:** `{ word, startRow, startCol, horizontal, score }`

### Notification Types

| Event | Format | Color |
|-------|--------|-------|
| Word played | `[Player] played '[WORD]' for [score] points!` | Default |
| Cross-words | `Cross-words: WORD (+X), WORD (+Y)` | Default |
| BINGO | `BINGO! +35 bonus for using all 7 tiles!` | Gold |
| Pass | `[Player] passed.` | Default |
| Remote move | `[Words] [Sender] played '[WORD]' for [score] points!` | Purple/Gold |

### Score Toast (WordGame.lua:3932-4008)

| Score Range | Text Format | Color |
|-------------|-------------|-------|
| >= 50 | `+[Score] [WORD]!` | Orange |
| >= 30 | `+[Score]!` | Gold |
| < 30 | `+[Score]` | Yellow |

- **Duration:** 1.5 seconds with rise + fade animation

### Known Gaps

| Feature | Status |
|---------|--------|
| Blank/Wildcard tiles | NOT IMPLEMENTED |
| Tile swapping UI | PARTIAL (RefillHand exists) |
| Score toast pooling | NOT POOLED (memory leak risk) |
| Turn timer | NOT IMPLEMENTED |
| Challenge/dispute | NOT IMPLEMENTED |
