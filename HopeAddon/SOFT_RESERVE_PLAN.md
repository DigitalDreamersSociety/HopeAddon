# Soft Reserve System Integration Plan

## Overview

Integrate a Soft Reserve (SR) loot system into HopeAddon for guild raids (Karazhan, Gruul's Lair, Magtheridon's Lair) using **SR 1** rules (each player can reserve 1 item per raid).

This plan is based on research of existing SR addons ([LootReserve](https://www.curseforge.com/wow/addons/lootreserve), [SoftRes](https://www.curseforge.com/wow/addons/softres), [softres.it](https://softres.it/)) and leverages HopeAddon's proven communication infrastructure.

---

## Part 1: System Design

### 1.1 Core Concept

| Aspect | Design Decision |
|--------|-----------------|
| **SR Limit** | SR 1 for Kara/Gruul/Mag (configurable per raid) |
| **Who Can Reserve** | Guild members with addon + Fellow Travelers |
| **Reserve Window** | Host opens session → Raiders reserve → Host locks → Raid starts |
| **Conflict Resolution** | Multiple reservers /roll, highest wins |
| **Distribution** | Manual with addon-assisted tracking |

### 1.2 User Roles

| Role | Permissions | UI Access |
|------|-------------|-----------|
| **Host** (Raid Lead/ML) | Create session, lock reserves, manage rolls, distribute loot | Full SR tab + Host panel |
| **Raider** (Guild Member) | Reserve items, view reserves, participate in rolls | SR tab (reserve mode) |
| **Guest** (Non-addon) | Reserve via chat commands (!reserve) | Chat only |

### 1.3 Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         HOST WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Open SR Tab → Click "Start Session"                              │
│     └─ Select Raid: [Karazhan ▼]                                     │
│     └─ Set SR Limit: [1 ▼]                                           │
│     └─ Set Timer: [30 min ▼] (optional)                              │
│                                                                      │
│  2. Session Active → Raiders can reserve                             │
│     └─ View real-time reserves list                                  │
│     └─ See who reserved what                                         │
│                                                                      │
│  3. Click "Lock Reserves" → No more changes                          │
│                                                                      │
│  4. During Raid:                                                     │
│     └─ Item drops → Check reserves                                   │
│     └─ Single reserver → Give item                                   │
│     └─ Multiple reservers → Start Roll                               │
│     └─ Mark item as distributed                                      │
│                                                                      │
│  5. Click "End Session" → Archive results                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        RAIDER WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Open SR Tab → See available items for [Karazhan]                 │
│     └─ Browse by boss or search by name                              │
│     └─ See who else reserved each item                               │
│                                                                      │
│  2. Click "Reserve" on desired item                                  │
│     └─ Confirmation: "Reserve [Fiery Warhorse's Reins]?"             │
│     └─ Reserve count updates: "1/1 reserves used"                    │
│                                                                      │
│  3. Optional: Cancel reserve before lock                             │
│     └─ Click "Cancel" on reserved item                               │
│                                                                      │
│  4. During Raid:                                                     │
│     └─ See toast when reserved item drops                            │
│     └─ Roll popup if contested                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 2: Data Structures

### 2.1 Loot Database (New Constants)

Need comprehensive loot tables with item IDs for all T4 bosses. The existing `notableLoot` tables have names but no IDs.

```lua
-- Core/Constants.lua (new section)
C.SR_LOOT_TABLES = {
    karazhan = {
        attumen = {
            { id = 28477, name = "Fiery Warhorse's Reins", slot = "mount", classes = "ALL" },
            { id = 28454, name = "Stalker's War Bands", slot = "wrist", classes = "HUNTER,SHAMAN" },
            { id = 28453, name = "Bracers of the White Stag", slot = "wrist", classes = "DRUID,ROGUE" },
            { id = 28502, name = "Vambraces of Courage", slot = "wrist", classes = "PALADIN,WARRIOR" },
            { id = 28503, name = "Whirlwind Bracers", slot = "wrist", classes = "HUNTER,SHAMAN" },
            { id = 28505, name = "Gloves of Dexterous Manipulation", slot = "hands", classes = "ROGUE" },
            { id = 28506, name = "Gloves of Saintly Blessings", slot = "hands", classes = "PALADIN,PRIEST" },
            { id = 28507, name = "Handwraps of Flowing Thought", slot = "hands", classes = "MAGE,WARLOCK,PRIEST" },
            { id = 28508, name = "Gauntlets of Renewed Hope", slot = "hands", classes = "PALADIN,WARRIOR" },
            { id = 28509, name = "Worgen Claw Necklace", slot = "neck", classes = "ALL" },
        },
        moroes = {
            -- ~10 items
        },
        maiden = {
            -- ~10 items
        },
        -- ... all 10 Karazhan bosses
    },
    gruul = {
        maulgar = {
            -- ~8 items including tier tokens
        },
        gruul = {
            -- ~10 items including Dragonspine Trophy
        },
    },
    magtheridon = {
        magtheridon = {
            -- ~10 items including tier chest tokens
        },
    },
}

-- Lookup: itemId → boss/raid
C.SR_ITEM_LOOKUP = {}  -- Built on load from SR_LOOT_TABLES
```

**Item Data Requirements:**
- ~150 items for Karazhan (10 bosses × ~15 items)
- ~20 items for Gruul's Lair (2 bosses)
- ~12 items for Magtheridon's Lair (1 boss)
- **Total: ~180 items with IDs, names, slots, class restrictions**

### 2.2 SavedVariables (Character Data)

```lua
-- Added to HopeAddonCharDB
charDb.softReserve = {
    -- My reserves (persists across sessions for quick re-reserve)
    myReserves = {
        -- [raidKey] = { itemId, timestamp, sessionId }
        karazhan = { itemId = 28477, timestamp = 1705334400, sessionId = "kara-2024-01-15" },
    },

    -- Reserve history (for statistics)
    history = {
        -- [sessionId] = { raid, date, reserved, won, participants }
        ["kara-2024-01-15"] = {
            raid = "karazhan",
            date = "2024-01-15",
            reserved = 28477,  -- itemId
            won = true,
            participants = 10,
        },
    },

    -- Settings
    settings = {
        showClassFiltered = true,  -- Only show items for my class
        autoAcceptRoll = false,    -- Auto-click roll button
        soundOnDrop = true,        -- Play sound when reserved item drops
    },
}
```

### 2.3 SavedVariables (Account Data - Host Only)

```lua
-- Added to HopeAddonDB (account-wide for raid leaders)
db.softReserve = {
    -- Active session (only one at a time)
    activeSession = nil,  -- or session object below

    -- Session template
    --[[
    activeSession = {
        id = "kara-2024-01-15-19:30",
        raid = "karazhan",
        srLimit = 1,
        status = "open",  -- "open", "locked", "active", "ended"
        createdAt = timestamp,
        lockedAt = nil,
        endedAt = nil,
        timer = 1800,  -- 30 min timer (nil = no timer)

        -- All reserves
        reserves = {
            -- [playerName] = { itemId, class, timestamp }
            ["Thrall"] = { itemId = 28477, class = "SHAMAN", timestamp = 1705334400 },
        },

        -- Roll tracking
        rolls = {
            -- [itemId] = { contestants, winner, winningRoll }
            [28477] = {
                contestants = { "Thrall", "Jaina" },
                rolls = { Thrall = 87, Jaina = 42 },
                winner = "Thrall",
                winningRoll = 87,
                distributed = true,
            },
        },

        -- Dropped items (tracked during raid)
        dropped = {
            -- [itemId] = { bossName, timestamp, distributed, winner }
        },
    },
    ]]

    -- Session history (last 20 sessions)
    sessionHistory = {},

    -- Default settings
    defaults = {
        karazhan = { srLimit = 1, timer = 1800 },
        gruul = { srLimit = 1, timer = 900 },
        magtheridon = { srLimit = 1, timer = 900 },
    },
}
```

---

## Part 3: Network Protocol

### 3.1 Message Types

Leverages existing FellowTravelers communication infrastructure.

```lua
-- Register with FellowTravelers callback system
local SR_PREFIX = "SR"  -- All SR messages start with "SR:"

-- Message Types
SR_MSG = {
    -- Session Management (Host → All)
    SESSION_START = "SSTA",   -- New session created
    SESSION_LOCK = "SLCK",    -- Reserves locked
    SESSION_END = "SEND",     -- Session ended
    SESSION_SYNC = "SSYN",    -- Full state sync (on request)

    -- Reserve Management (Raider ↔ Host)
    RESERVE = "SRES",         -- Player reserved item
    CANCEL = "SCAN",          -- Player cancelled reserve
    RESERVE_ACK = "SACK",     -- Host confirms reserve
    RESERVE_DENY = "SDNY",    -- Host denies reserve (limit reached, locked, etc.)

    -- Loot Events (Host → All)
    ITEM_DROP = "SDRP",       -- Reserved item dropped
    ROLL_START = "SROL",      -- Roll started for contested item
    ROLL_END = "SRND",        -- Roll ended, winner announced
    ITEM_DIST = "SDST",       -- Item distributed

    -- Queries (Raider → Host)
    QUERY_SESSION = "SQRY",   -- Request session state
    QUERY_RESERVES = "SQRS",  -- Request reserves list
}
```

### 3.2 Message Formats

```lua
-- Session Start (Host broadcast)
-- Format: "SR:SSTA:version:raidKey:srLimit:timer:sessionId"
-- Example: "SR:SSTA:1:karazhan:1:1800:kara-2024-01-15"

-- Reserve (Raider → Host whisper)
-- Format: "SR:SRES:version:sessionId:itemId"
-- Example: "SR:SRES:1:kara-2024-01-15:28477"

-- Reserve Acknowledge (Host → Raider whisper)
-- Format: "SR:SACK:version:sessionId:itemId:currentCount:maxCount"
-- Example: "SR:SACK:1:kara-2024-01-15:28477:1:1"

-- Session Sync (on request)
-- Format: "SR:SSYN:version:sessionId:status:compressedReserves"
-- Uses strsplit with | for reserves: "player1:itemId,player2:itemId,..."

-- Item Drop (Host broadcast)
-- Format: "SR:SDRP:version:sessionId:itemId:bossName:reserverCount"
-- Example: "SR:SDRP:1:kara-2024-01-15:28477:Attumen:2"

-- Roll Start (Host broadcast)
-- Format: "SR:SROL:version:sessionId:itemId:contestants"
-- Example: "SR:SROL:1:kara-2024-01-15:28477:Thrall,Jaina"
```

### 3.3 Chat Commands (For Non-Addon Users)

```lua
-- Raiders without addon can use chat commands
-- Monitored channels: WHISPER, RAID, PARTY

CHAT_COMMANDS = {
    "!reserve ITEM",      -- Reserve item (link or name)
    "!reserve cancel",    -- Cancel last reserve
    "!myreserves",        -- Show my reserves
    "!reserves",          -- Show all reserves
    "!reserves ITEM",     -- Show who reserved specific item
}

-- Example: Player whispers "!reserve [Fiery Warhorse's Reins]"
-- Host addon parses, validates, adds reserve, responds
```

---

## Part 4: Module Architecture

### 4.1 New Files

```
HopeAddon/
├── Social/
│   └── SoftReserve/
│       ├── SoftReserve.lua      -- Main module (~400 lines)
│       ├── SoftReserveHost.lua  -- Host-only logic (~300 lines)
│       ├── SoftReserveUI.lua    -- UI components (~500 lines)
│       └── SoftReserveData.lua  -- Loot tables (~800 lines)
```

### 4.2 Module Responsibilities

**SoftReserve.lua (Core Module)**
```lua
local SoftReserve = {}
HopeAddon:RegisterModule("SoftReserve", SoftReserve)

-- Lifecycle
function SoftReserve:OnInitialize()
function SoftReserve:OnEnable()
function SoftReserve:OnDisable()

-- Public API
function SoftReserve:GetActiveSession()
function SoftReserve:GetMyReserves()
function SoftReserve:ReserveItem(itemId)
function SoftReserve:CancelReserve(itemId)
function SoftReserve:IsReserved(itemId)
function SoftReserve:GetReservers(itemId)

-- Network Handlers (registered with FellowTravelers)
function SoftReserve:HandleSessionStart(sender, data)
function SoftReserve:HandleReserveAck(sender, data)
function SoftReserve:HandleItemDrop(sender, data)
function SoftReserve:HandleRollStart(sender, data)

-- Event Handlers
function SoftReserve:OnLootOpened()  -- LOOT_OPENED event
function SoftReserve:OnChatMessage(msg, sender, channel)  -- Chat commands
```

**SoftReserveHost.lua (Host-Only)**
```lua
local SoftReserveHost = {}

-- Session Management
function SoftReserveHost:StartSession(raidKey, srLimit, timer)
function SoftReserveHost:LockSession()
function SoftReserveHost:EndSession()

-- Reserve Management
function SoftReserveHost:ProcessReserve(playerName, itemId, class)
function SoftReserveHost:ProcessCancel(playerName, itemId)
function SoftReserveHost:BroadcastReserves()

-- Loot Distribution
function SoftReserveHost:OnItemDropped(itemId, bossName)
function SoftReserveHost:StartRoll(itemId, contestants)
function SoftReserveHost:ProcessRoll(playerName, roll)
function SoftReserveHost:EndRoll(itemId)
function SoftReserveHost:MarkDistributed(itemId, winner)

-- Chat Command Parsing
function SoftReserveHost:ParseChatCommand(msg, sender)
```

**SoftReserveUI.lua (UI Components)**
```lua
local SoftReserveUI = {}

-- Tab Integration
function SoftReserveUI:CreateSRTab()  -- New journal tab or section in Social

-- Raider View
function SoftReserveUI:ShowRaiderView()
function SoftReserveUI:CreateItemList(raidKey)
function SoftReserveUI:CreateItemCard(itemData)
function SoftReserveUI:UpdateReserveStatus()

-- Host View
function SoftReserveUI:ShowHostPanel()
function SoftReserveUI:CreateSessionControls()
function SoftReserveUI:CreateReservesList()
function SoftReserveUI:CreateRollTracker()

-- Popups
function SoftReserveUI:ShowReserveConfirm(itemId)
function SoftReserveUI:ShowRollPopup(itemId, contestants)
function SoftReserveUI:ShowItemDropToast(itemId, bossName)

-- Frame Pools
function SoftReserveUI:CreateFramePools()
function SoftReserveUI:DestroyFramePools()
```

### 4.3 Integration Points

| System | Integration |
|--------|-------------|
| **Journal** | New "Loot" tab or section in existing tab |
| **FellowTravelers** | Register SR message callbacks |
| **ActivityFeed** | Post activities (session started, item won) |
| **Sounds** | New sound category for reserves, drops, wins |
| **Toasts** | Drop notifications, roll popups |
| **Companions** | Priority UI for companions in reserve list |

---

## Part 5: UI Design

### 5.1 Journal Tab Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  LOOT RESERVES                                           [?] Help   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  KARAZHAN - SR 1                          Session: OPEN     │    │
│  │  Host: Thrall           Reserves: 8/10         ⏱ 24:35      │    │
│  │  Your Reserve: [Fiery Warhorse's Reins]   ✓ Reserved        │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─ Filter ─────────────────────────────────────────────────────┐   │
│  │ [All Items] [My Class Only ✓] [Available Only]               │   │
│  │ 🔍 Search items...                                           │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  [▼] ATTUMEN THE HUNTSMAN (3 reserves)                              │
│  ├─────────────────────────────────────────────────────────────┐    │
│  │ [Mount Icon] Fiery Warhorse's Reins                         │    │
│  │              Mount - All Classes                            │    │
│  │              Reserved by: Thrall, Jaina          [Cancel]   │    │
│  ├─────────────────────────────────────────────────────────────┤    │
│  │ [Wrist Icon] Stalker's War Bands                            │    │
│  │              Mail Wrist - Hunter, Shaman                    │    │
│  │              Reserved by: Rexxar               [Reserve]    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  [▼] MOROES (2 reserves)                                            │
│  ...                                                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Host Panel (Overlay or Side Panel)

```
┌─────────────────────────────────────────────────────────────────────┐
│  HOST CONTROLS                                           [X] Close  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Session: OPEN                                                       │
│  Raid: Karazhan    SR Limit: 1    Timer: 24:35                      │
│                                                                      │
│  [Lock Reserves]  [Broadcast]  [End Session]                        │
│                                                                      │
├─ RESERVES (8 players) ──────────────────────────────────────────────┤
│                                                                      │
│  Thrall (Shaman)      → Fiery Warhorse's Reins                      │
│  Jaina (Mage)         → Fiery Warhorse's Reins          ⚔ Contest   │
│  Arthas (Paladin)     → Justicar Chestguard                         │
│  Sylvanas (Hunter)    → Sunfury Bow of the Phoenix                  │
│  ...                                                                 │
│                                                                      │
├─ ROLL TRACKER ──────────────────────────────────────────────────────┤
│                                                                      │
│  [Fiery Warhorse's Reins]                            STATUS: ROLLED │
│  ├─ Thrall:  87  ← WINNER                                           │
│  └─ Jaina:   42                                                      │
│                                                                      │
│  [Start Roll]  [Re-Roll]  [Assign Winner ▼]                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.3 Roll Popup (For Contested Items)

```
┌───────────────────────────────────────────┐
│        ROLL FOR LOOT                      │
├───────────────────────────────────────────┤
│                                           │
│   [Icon] Fiery Warhorse's Reins           │
│          Mount                            │
│                                           │
│   Contestants:                            │
│   • Thrall (Shaman)     [ 87 ]            │
│   • Jaina (Mage)        [    ]            │
│                                           │
│       [ ROLL ]     [ PASS ]               │
│                                           │
│   You have 30 seconds to roll             │
│                                           │
└───────────────────────────────────────────┘
```

---

## Part 6: Implementation Phases

### Phase 1: Data Foundation (2-3 hours)
**Goal:** Create loot database and data structures

**Tasks:**
- [ ] Create `SoftReserveData.lua` with full T4 loot tables (~180 items)
- [ ] Add `charDb.softReserve` defaults to Core.lua
- [ ] Add `db.softReserve` defaults to Core.lua
- [ ] Create item lookup table builder
- [ ] Add to HopeAddon.toc

**Deliverables:**
- Complete loot tables for Karazhan (150 items), Gruul (20 items), Mag (12 items)
- Item ID → boss/raid lookup
- SavedVariables structure

### Phase 2: Core Module (3-4 hours)
**Goal:** Implement raider-side functionality

**Tasks:**
- [ ] Create `SoftReserve.lua` with module lifecycle
- [ ] Register message callbacks with FellowTravelers
- [ ] Implement `ReserveItem()` and `CancelReserve()`
- [ ] Implement `GetMyReserves()` and `IsReserved()`
- [ ] Handle incoming session/reserve messages
- [ ] Add LOOT_OPENED event handler for drop detection

**Deliverables:**
- Working reserve/cancel flow
- Network message handling
- Drop detection with toast

### Phase 3: Host Module (4-5 hours)
**Goal:** Implement host-side functionality

**Tasks:**
- [ ] Create `SoftReserveHost.lua`
- [ ] Implement session lifecycle (start/lock/end)
- [ ] Implement reserve processing and validation
- [ ] Implement roll tracking with /roll detection
- [ ] Add chat command parsing (!reserve, !myreserves)
- [ ] Add session broadcast on join

**Deliverables:**
- Full session management
- Reserve processing with limits
- Roll tracking and winner detection
- Chat command support for non-addon users

### Phase 4: Basic UI (4-5 hours)
**Goal:** Create functional UI

**Tasks:**
- [ ] Create `SoftReserveUI.lua`
- [ ] Add "Loot" tab to Journal (or section in existing tab)
- [ ] Create item list with boss collapsibles
- [ ] Create reserve button with confirmation
- [ ] Create host panel overlay
- [ ] Add frame pools for efficiency

**Deliverables:**
- Browseable item list
- Working reserve buttons
- Host control panel
- Reserve status display

### Phase 5: Polish & Integration (3-4 hours)
**Goal:** Complete integration and polish

**Tasks:**
- [ ] Add roll popup for contested items
- [ ] Add drop notification toast
- [ ] Add sounds (reserve, drop, win)
- [ ] Add ActivityFeed integration
- [ ] Add settings (class filter, sounds)
- [ ] Add session history view

**Deliverables:**
- Complete user experience
- Sound feedback
- Activity tracking
- User settings

### Phase 6: Testing & Documentation (2-3 hours)
**Goal:** Test and document

**Tasks:**
- [ ] Test solo (mock session)
- [ ] Test with 2+ addon users
- [ ] Test with chat commands (non-addon user)
- [ ] Test edge cases (disconnect, rejoin, etc.)
- [ ] Update CLAUDE.md documentation
- [ ] Add slash commands help

**Deliverables:**
- Tested functionality
- Documentation
- `/hope sr` command help

---

## Part 7: Slash Commands

```lua
-- Core commands
/hope sr                    -- Open SR tab
/hope sr help              -- Show help
/hope sr status            -- Show current session status

-- Raider commands
/hope sr reserve [item]    -- Reserve item (link or ID)
/hope sr cancel            -- Cancel my reserve
/hope sr list              -- List my reserves

-- Host commands
/hope sr host              -- Open host panel
/hope sr start [raid]      -- Start session (karazhan, gruul, magtheridon)
/hope sr lock              -- Lock reserves
/hope sr end               -- End session
/hope sr broadcast         -- Re-broadcast session info
/hope sr roll [item]       -- Start roll for item
```

---

## Part 8: Estimated Effort

| Phase | Hours | Dependencies |
|-------|-------|--------------|
| Phase 1: Data Foundation | 2-3h | None |
| Phase 2: Core Module | 3-4h | Phase 1 |
| Phase 3: Host Module | 4-5h | Phase 2 |
| Phase 4: Basic UI | 4-5h | Phase 3 |
| Phase 5: Polish | 3-4h | Phase 4 |
| Phase 6: Testing | 2-3h | Phase 5 |
| **Total** | **18-24h** | |

---

## Part 9: Future Enhancements (Post-MVP)

### 9.1 Advanced Features
- **+1 System:** Track won items, penalize re-wins
- **Priority System:** MS > OS rolls with spec detection
- **Wishlist:** Long-term item wishlist across sessions
- **softres.it Import:** Import reserves from softres.it CSV

### 9.2 T5/T6 Expansion
- Add SSC, TK, Hyjal, BT, Sunwell loot tables
- Per-raid SR limits (SR 2 for larger raids?)

### 9.3 Integration Improvements
- **Armory Integration:** Show SR status on BiS items
- **Calendar Integration:** Link SR sessions to raid events
- **Export:** CSV export of session results

---

## Part 10: Research Sources

- [LootReserve on CurseForge](https://www.curseforge.com/wow/addons/lootreserve) - Feature reference
- [SoftRes Addon](https://www.curseforge.com/wow/addons/softres) - Simple implementation reference
- [softres.it](https://softres.it/) - Web-based SR utility
- [LootReserve GitHub](https://github.com/Anonomit/LootReserve) - Code reference
- [Wowhead Soft Reserve Article](https://classic.wowhead.com/news/soft-reserve-raid-loot-distribution-utility-317492) - Concept explanation

---

## Appendix A: T4 Boss List for Loot Tables

### Karazhan (10 bosses)
1. Attumen the Huntsman
2. Moroes
3. Maiden of Virtue
4. Opera Event (Oz/R&J/BBW)
5. The Curator
6. Terestian Illhoof
7. Shade of Aran
8. Netherspite
9. Chess Event
10. Prince Malchezaar
11. Nightbane (optional)

### Gruul's Lair (2 bosses)
1. High King Maulgar
2. Gruul the Dragonkiller

### Magtheridon's Lair (1 boss)
1. Magtheridon

**Note:** Need ~15-20 items per boss including tier tokens for Karazhan bosses, fewer for Gruul/Mag.

---

## Appendix B: Existing Infrastructure Leverage

| Component | Existing Code | Reuse For |
|-----------|---------------|-----------|
| FellowTravelers | Message callbacks | SR message routing |
| GameComms | Protocol versioning | Message format consistency |
| ActivityFeed | Activity broadcasting | SR event notifications |
| Frame Pools | FramePool module | UI efficiency |
| Timer | Ticker system | Session timer, roll timer |
| Components | UI factories | Consistent styling |
| Sounds | Sound system | Reserve/drop/win sounds |
| Toasts | SocialToasts | Drop notifications |

All infrastructure is battle-tested through 57+ development phases.
