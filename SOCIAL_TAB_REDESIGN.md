# Social Tab Redesign - Tabbed Social Media Experience

## Current Problems

### Redundancy Analysis
The same Fellow Traveler can appear in **up to 5 places**:
1. Activity Feed (if they did something recently)
2. Companions (if favorited)
3. Looking for RP (if LF_RP status)
4. In Your Party (if grouped)
5. Fellow Travelers Directory (always)

**Example:** Thrall is in your party, is a companion, has LF_RP status, and just killed a boss.
He appears 5 times on one screen!

### Current Section Order (Confusing)
```
1. Your Profile          <- About YOU
2. Activity Feed         <- About OTHERS
3. Companions            <- OTHERS (subset)
4. Looking for RP        <- OTHERS (subset)
5. In Your Party         <- OTHERS (subset)
6. Fellow Travelers      <- OTHERS (all)
```

This mixes "me" and "them" content, with repetitive Fellow Traveler subsets.

---

## Proposed Solution: Tabbed Interface

### Core Principle
**Fellow Travelers list is the PRIMARY view. Everything else is a FILTER or OVERLAY on that list.**

### Layout Structure
```
+-------------------------------------------------------------+
|  [Your Status Bar - Always Visible]                         |
|  [Class] Playername <Title>     [IC v]  [Post Rumor]        |
+-------------------------------------------------------------+
|  [Feed] [Travelers] [Companions]              [Search...]   |
+-------------------------------------------------------------+
|                                                             |
|  Tab Content Area (scrollable)                              |
|                                                             |
+-------------------------------------------------------------+
```

---

## Tab 1: FEED (Activity-Centric)

**Purpose:** What's happening right now in the community

```
+-------------------------------------------------------------+
| [Feed] [Travelers] [Companions]              [Filter v]     |
+-------------------------------------------------------------+
|                                                             |
|  [!] Thrall is Looking for RP                    2m  [Mug]  |
|      Orgrimmar - "Seeking war council RP"                   |
|                                                             |
|  [Loot] Jaina received [Sunfire Robe]            5m  [Mug]  |
|      Karazhan - "Finally! After 12 kills!"                  |
|                                                             |
|  [Boss] Arthas slew Gruul the Dragonkiller      15m  [Mug]  |
|      Gruul's Lair - First kill!                             |
|                                                             |
|  [Up] Sylvanas reached level 70                   1h  [Mug]  |
|      Shadowmoon Valley                                      |
|                                                             |
|  --------------- Earlier Today ---------------              |
|                                                             |
|  [Game] Thrall won at Tetris vs Jaina            3h  [Mug]  |
|                                                             |
|                    [Load More...]                           |
|                                                             |
+-------------------------------------------------------------+
```

**Features:**
- Two-line format: Action + Context (zone, hook, details)
- Time-grouped sections (Now, Earlier Today, Yesterday)
- Filter dropdown: All / Status / Boss / Level / Game / Badge / Loot
- Click player name -> Jump to their profile in Travelers tab
- Mug reactions with count

---

## Tab 2: TRAVELERS (People-Centric)

**Purpose:** Browse and find Fellow Travelers with smart filtering

```
+-------------------------------------------------------------+
| [Feed] [Travelers] [Companions]    [Search...] [Sort v]     |
+-------------------------------------------------------------+
| Quick Filters: [All 47] [Online 12] [Party 3] [LF_RP 4]     |
+-------------------------------------------------------------+
|                                                             |
| * Thrall           70 Warrior   Orgrimmar        2m         |
|   IC - "For the Horde!"                    [Ally] [*] [...] |
|                                                             |
| * Jaina            70 Mage      Shattrath        5m         |
|   LF_RP - "Seeking arcane studies RP"      [--]  [*] [...] |
|                                                             |
| o Anduin           68 Priest    Stormwind       15m         |
|   OOC                                      [--]  [-] [...] |
|                                                             |
| - Sylvanas         70 Hunter    Offline          3d         |
|   OOC                                      [--]  [*] [...] |
|                                                             |
|                    [Page 1 of 5]  [< >]                     |
|                                                             |
+-------------------------------------------------------------+
```

**Smart Features:**
- **Quick Filter Buttons** with counts - replaces separate sections
- **Unified Row Format** - no redundant cards
- **Relationship Tag** - [Ally], [Rival], [Friend], [--] (none set)
- **Companion Star** - [*] filled = companion, [-] empty = not companion
- **[...] Quick Actions** - Whisper, Challenge, View Profile, Add Note, Set Relationship

---

## Tab 3: COMPANIONS (Favorites)

**Purpose:** Quick access to your inner circle

```
+-------------------------------------------------------------+
| [Feed] [Travelers] [Companions]                  [+ Add]    |
+-------------------------------------------------------------+
| Online Now (3)                                              |
| +----------+ +----------+ +----------+                      |
| |[W]Thrall | |[M] Jaina | |[P]Anduin |                      |
| |* Orgrim. | |* Shatt.  | |* Storm.  |                      |
| | IC       | | LF_RP    | | OOC      |                      |
| |  [Ally]  | |  [--]    | | [Friend] |                      |
| +----------+ +----------+ +----------+                      |
|                                                             |
| Offline (3)                                                 |
| +----------+ +----------+ +----------+                      |
| |[H]Sylvan.| |[D]Malfur.| |[W]Garrosh|                      |
| |- 3 days  | |- 1 week  | |- 2 weeks |                      |
| +----------+ +----------+ +----------+                      |
|                                                             |
| Pending Requests (1)                                        |
| [P] Tyrande wants to be companions    [Accept] [Decline]    |
+-------------------------------------------------------------+
```

---

## NEW FEATURE: Loot Sharing System ("Brag About It!")

### Overview
When you receive epic+ loot from a raid/dungeon boss, you get the option to share it with Fellow Travelers. This is **opt-in only** - no auto-posting.

### User Flow

```
1. Player kills boss in raid/dungeon
2. Player receives epic item (quality >= 4)
3. System queues share prompt (waits for out of combat)
4. Combat ends (PLAYER_REGEN_ENABLED)
5. After 3 second delay, prompt appears
6. Player chooses: Share (with optional comment) or Skip
7. If shared, post appears in Feed for all Fellow Travelers
```

### Loot Detection

```lua
-- Events to monitor
CHAT_MSG_LOOT           -- "You receive loot: [Item]"
LOOT_SLOT_CLEARED       -- Item actually taken from corpse

-- Parse loot message
local LOOT_PATTERN = "You receive loot: (.+)"
local function OnLootReceived(message)
    local itemLink = message:match(LOOT_PATTERN)
    if not itemLink then return end

    local _, _, quality, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)

    -- Only epic+ items that are BoP (soulbound)
    if quality >= 4 and bindType == 1 then
        ActivityFeed:QueueLootSharePrompt(itemLink)
    end
end
```

### Context Detection (Where did this drop?)

```lua
-- Track current encounter for loot context
ActivityFeed.currentEncounter = {
    bossName = nil,
    raidName = nil,
    dungeonName = nil,
    startTime = nil,
}

-- Set on boss pull (ENCOUNTER_START in retail, COMBAT_LOG in TBC)
-- Clear on wipe or 60 seconds after kill

function ActivityFeed:GetLootContext()
    if self.currentEncounter.bossName then
        return {
            source = self.currentEncounter.bossName,
            location = self.currentEncounter.raidName or self.currentEncounter.dungeonName,
            isFirstKill = not charDb.journal.bossKills[self.currentEncounter.bossName],
        }
    end

    -- Fallback: use zone name
    return {
        source = "Unknown",
        location = GetZoneText(),
        isFirstKill = false,
    }
end
```

### Share Prompt UI

```
+---------------------------------------------------------------+
|                                              [X] Dismiss       |
+---------------------------------------------------------------+
|                                                               |
|  +-----------------------------------------------------------+
|  |  [Item Icon]  [Sunfire Robe]                              |
|  |               Epic Cloth Chest                             |
|  |               +42 Stamina, +35 Intellect                   |
|  |               Dropped from: Prince Malchezaar              |
|  |               Location: Karazhan                           |
|  +-----------------------------------------------------------+
|                                                               |
|  Add a comment (optional):                                    |
|  +-----------------------------------------------------------+
|  | Finally got it after 12 kills!                            |
|  +-----------------------------------------------------------+
|  (0/100 characters)                                           |
|                                                               |
|  +-------------------------+  +------------------+            |
|  |   [Brag About It!]      |  |     [Skip]       |            |
|  +-------------------------+  +------------------+            |
|                                                               |
|  [ ] Don't ask me about loot drops                            |
|                                                               |
+---------------------------------------------------------------+
```

### Prompt Queue System

```lua
-- Queue structure for pending prompts
ActivityFeed.pendingPrompts = {}

-- Example prompt entry
{
    id = "loot_12345",
    type = "LOOT",                    -- LOOT, FIRST_KILL, ATTUNEMENT, GAME_WIN
    timestamp = time(),
    expireAt = time() + 300,          -- 5 minutes to decide
    data = {
        itemLink = "|cff9d4dbb[Sunfire Robe]|r",
        itemIcon = 12345,
        itemQuality = 4,
        source = "Prince Malchezaar",
        location = "Karazhan",
        isFirstKill = false,
    },
}

-- Queue management
function ActivityFeed:QueueLootSharePrompt(itemLink)
    local context = self:GetLootContext()
    local _, _, quality, _, _, itemType, itemSubType, _, equipLoc, icon = GetItemInfo(itemLink)

    local prompt = {
        id = "loot_" .. time() .. "_" .. math.random(1000),
        type = "LOOT",
        timestamp = time(),
        expireAt = time() + C.SOCIAL_TAB.SHARE_PROMPT_EXPIRE,
        data = {
            itemLink = itemLink,
            itemIcon = icon,
            itemQuality = quality,
            itemType = itemType,
            itemSubType = itemSubType,
            equipLoc = equipLoc,
            source = context.source,
            location = context.location,
            isFirstKill = context.isFirstKill,
        },
    }

    table.insert(self.pendingPrompts, prompt)

    -- If not in combat, show immediately (after delay)
    if not InCombatLockdown() then
        HopeAddon.Timer:After(C.SOCIAL_TAB.SHARE_PROMPT_DELAY, function()
            self:ShowNextPrompt()
        end)
    end
end

-- Combat end handler
function ActivityFeed:OnCombatEnd()
    -- Clean up expired prompts
    self:CleanupExpiredPrompts()

    -- Show next prompt if any
    if #self.pendingPrompts > 0 then
        HopeAddon.Timer:After(C.SOCIAL_TAB.SHARE_PROMPT_DELAY, function()
            self:ShowNextPrompt()
        end)
    end
end
```

### Activity Creation (When User Shares)

```lua
function ActivityFeed:ShareLoot(promptData, comment)
    local _, class = UnitClass("player")

    -- Create activity with item data
    local activity = self:CreateActivity(
        ACTIVITY.LOOT,
        UnitName("player"),
        class,
        {
            itemLink = promptData.itemLink,
            source = promptData.source,
            location = promptData.location,
            comment = comment or "",
            isFirstKill = promptData.isFirstKill,
        }
    )

    -- Add to local feed
    self:AddActivity(activity)

    -- Broadcast to Fellow Travelers
    self:BroadcastActivity(activity)

    -- Play celebration sound
    HopeAddon.Sounds:PlayAchievement()

    -- Show confirmation toast
    HopeAddon.SocialToasts:Show("loot_shared", nil, "Shared to your Fellow Travelers!")
end
```

### Wire Protocol for Loot Activity

```lua
-- Format: ACT:version:type:player:class:data:timestamp
-- LOOT data format: itemLink|source|location|comment|isFirstKill

-- Encoding
function ActivityFeed:EncodeLootActivity(activity)
    local data = activity.data
    local encoded = string.format("%s|%s|%s|%s|%s",
        data.itemLink:gsub("|", "~"),  -- Escape pipe characters
        data.source or "",
        data.location or "",
        data.comment or "",
        data.isFirstKill and "1" or "0"
    )
    return encoded
end

-- Decoding
function ActivityFeed:DecodeLootActivity(encoded)
    local itemLink, source, location, comment, isFirstKill = strsplit("|", encoded)
    return {
        itemLink = itemLink:gsub("~", "|"),  -- Unescape
        source = source,
        location = location,
        comment = comment,
        isFirstKill = isFirstKill == "1",
    }
end
```

### Feed Display for Loot Posts

```
+-------------------------------------------------------------+
|  [Loot Icon] Jaina received [Sunfire Robe]          5m [Mug]|
|              Prince Malchezaar - Karazhan                   |
|              "Finally! After 12 kills!"                     |
+-------------------------------------------------------------+
```

### Settings Integration

```lua
charDb.social.shareSettings = {
    -- Loot specific
    promptForLoot = true,           -- Show prompts for epic+ loot
    lootMinQuality = 4,             -- 4 = Epic, 5 = Legendary
    lootOnlyBossDrops = true,       -- Only prompt for boss drops, not trash

    -- Other prompts
    promptForFirstKills = true,
    promptForAttunements = true,
    promptForGameWins = true,

    -- Auto-post (no prompt)
    autoPostBadges = true,
    autoPostMilestoneLevels = true,
    autoPostStatusChanges = true,
}
```

---

## Relationship System

### Relationship Types
```lua
C.RELATIONSHIP_TYPES = {
    NONE = { id = "NONE", label = "--", color = "808080", icon = nil, priority = 99 },
    ALLY = { id = "ALLY", label = "Ally", color = "00FF00", icon = "Achievement_Reputation_01", priority = 1 },
    FRIEND = { id = "FRIEND", label = "Friend", color = "00BFFF", icon = "INV_ValentinesCandy", priority = 2 },
    RIVAL = { id = "RIVAL", label = "Rival", color = "FF6600", icon = "Ability_DualWield", priority = 3 },
    MENTOR = { id = "MENTOR", label = "Mentor", color = "FFD700", icon = "Spell_Holy_AuraOfLight", priority = 4 },
    STUDENT = { id = "STUDENT", label = "Student", color = "9370DB", icon = "INV_Misc_Book_09", priority = 5 },
    FAMILY = { id = "FAMILY", label = "Family", color = "FF69B4", icon = "Spell_Holy_PrayerOfHealing", priority = 6 },
    ENEMY = { id = "ENEMY", label = "Enemy", color = "FF0000", icon = "Ability_Warrior_Rampage", priority = 7 },
}
```

### Data Storage
```lua
charDb.relationships = {
    ["Thrall"] = {
        note = "Great RP partner, met at Orgrimmar",
        addedDate = "2024-01-15",
        relationship = "ALLY",
        relationshipDate = "2024-01-20",
    },
}
```

---

## Status Bar (Always Visible)

```
+-------------------------------------------------------------+
| [Warrior] Playername <Hero>    [IC v]  [Edit] [Post]        |
+-------------------------------------------------------------+
```

**Elements:**
- Class icon (24x24)
- Name with title (click opens ProfileEditor)
- RP Status dropdown (IC/OOC/LF_RP) - instant change
- [Edit] - opens ProfileEditor for backstory/hooks
- [Post] - inline rumor input (expands below status bar)

---

## Constants

```lua
C.SOCIAL_TAB = {
    -- Tab bar
    TAB_WIDTH = 90,
    TAB_HEIGHT = 24,
    TAB_SPACING = 2,

    -- Status bar
    STATUS_BAR_HEIGHT = 36,
    RUMOR_INPUT_HEIGHT = 50,

    -- Feed
    FEED_ROW_HEIGHT = 48,
    FEED_VISIBLE_ROWS = 8,
    FEED_TIME_GROUPS = { "Now", "Earlier Today", "Yesterday", "This Week" },
    FEED_FILTERS = { "all", "status", "boss", "level", "game", "badge", "loot" },

    -- Travelers
    TRAVELER_ROW_HEIGHT = 44,
    TRAVELER_VISIBLE_ROWS = 8,
    QUICK_FILTERS = { "all", "online", "party", "lfrp" },

    -- Companions
    COMPANION_CARD_SIZE = 80,
    COMPANION_CARDS_PER_ROW = 4,
    COMPANION_SECTIONS = { "Online Now", "Away", "Offline" },

    -- Thresholds
    ONLINE_THRESHOLD = 300,
    AWAY_THRESHOLD = 900,

    -- Share prompts
    SHARE_PROMPT_EXPIRE = 300,
    SHARE_PROMPT_DELAY = 3,
    SHARE_PROMPT_WIDTH = 350,
    SHARE_PROMPT_HEIGHT = 280,

    -- Loot
    LOOT_MIN_QUALITY = 4,           -- Epic
    LOOT_COMMENT_MAX = 100,
}

C.SHARE_PROMPT_TYPES = {
    LOOT = { id = "LOOT", icon = "INV_Misc_Bag_10", label = "Loot Received", settingKey = "promptForLoot" },
    FIRST_KILL = { id = "FIRST_KILL", icon = "Achievement_Boss_Gruul", label = "First Boss Kill", settingKey = "promptForFirstKills" },
    ATTUNEMENT = { id = "ATTUNEMENT", icon = "INV_Misc_Key_03", label = "Attunement Complete", settingKey = "promptForAttunements" },
    GAME_WIN = { id = "GAME_WIN", icon = "INV_Misc_Dice_02", label = "Game Victory", settingKey = "promptForGameWins" },
}

C.RP_STATUS = {
    IC = { id = "IC", label = "In Character", color = "00FF00", icon = "Spell_Holy_MindVision" },
    OOC = { id = "OOC", label = "Out of Character", color = "808080", icon = "Spell_Nature_Sleep" },
    LF_RP = { id = "LF_RP", label = "Looking for RP", color = "FF33CC", icon = "INV_ValentinesCandy" },
}
```

---

## Activity Types (Extended)

```lua
ACTIVITY = {
    -- Existing
    STATUS = "STATUS",
    BOSS = "BOSS",
    LEVEL = "LEVEL",
    GAME = "GAME",
    BADGE = "BADGE",
    RUMOR = "RUMOR",
    MUG = "MUG",

    -- NEW
    LOOT = "LOOT",
    FIRST_KILL = "FIRST_KILL",
    ATTUNEMENT = "ATTUNEMENT",
    COMPANION = "COMPANION",
}
```

---

# IMPLEMENTATION PAYLOADS

## PAYLOAD 1: Core Tab Infrastructure
**Files:** Components.lua, Journal.lua, Core.lua
**Estimated Lines:** ~500
**Dependencies:** None

### 1.0 Add Constants (Constants.lua)

**Add to Core/Constants.lua after existing constants (~line 4000+):**

```lua
--============================================================
-- SOCIAL TAB CONSTANTS
--============================================================

C.SOCIAL_TAB = {
    -- Tab bar
    TAB_WIDTH = 90,
    TAB_HEIGHT = 24,
    TAB_SPACING = 2,

    -- Status bar
    STATUS_BAR_HEIGHT = 36,
    RUMOR_INPUT_HEIGHT = 50,

    -- Feed
    FEED_ROW_HEIGHT = 48,
    FEED_VISIBLE_ROWS = 8,
    FEED_TIME_GROUPS = { "Now", "Earlier Today", "Yesterday", "This Week" },
    FEED_FILTERS = { "all", "status", "boss", "level", "game", "badge", "loot" },

    -- Travelers
    TRAVELER_ROW_HEIGHT = 44,
    TRAVELER_VISIBLE_ROWS = 8,
    QUICK_FILTERS = { "all", "online", "party", "lfrp" },

    -- Companions
    COMPANION_CARD_SIZE = 80,
    COMPANION_CARDS_PER_ROW = 4,
    COMPANION_SECTIONS = { "Online Now", "Away", "Offline" },

    -- Thresholds
    ONLINE_THRESHOLD = 300,   -- 5 minutes
    AWAY_THRESHOLD = 900,     -- 15 minutes

    -- Share prompts
    SHARE_PROMPT_EXPIRE = 300,
    SHARE_PROMPT_DELAY = 3,
    SHARE_PROMPT_WIDTH = 350,
    SHARE_PROMPT_HEIGHT = 280,

    -- Loot
    LOOT_MIN_QUALITY = 4,           -- Epic
    LOOT_COMMENT_MAX = 100,
}

C.RELATIONSHIP_TYPES = {
    NONE = { id = "NONE", label = "--", color = "808080", icon = nil, priority = 99 },
    ALLY = { id = "ALLY", label = "Ally", color = "00FF00", icon = "Achievement_Reputation_01", priority = 1 },
    FRIEND = { id = "FRIEND", label = "Friend", color = "00BFFF", icon = "INV_ValentinesCandy", priority = 2 },
    RIVAL = { id = "RIVAL", label = "Rival", color = "FF6600", icon = "Ability_DualWield", priority = 3 },
    MENTOR = { id = "MENTOR", label = "Mentor", color = "FFD700", icon = "Spell_Holy_AuraOfLight", priority = 4 },
    STUDENT = { id = "STUDENT", label = "Student", color = "9370DB", icon = "INV_Misc_Book_09", priority = 5 },
    FAMILY = { id = "FAMILY", label = "Family", color = "FF69B4", icon = "Spell_Holy_PrayerOfHealing", priority = 6 },
    ENEMY = { id = "ENEMY", label = "Enemy", color = "FF0000", icon = "Ability_Warrior_Rampage", priority = 7 },
}

C.SHARE_PROMPT_TYPES = {
    LOOT = { id = "LOOT", icon = "INV_Misc_Bag_10", label = "Loot Received", settingKey = "promptForLoot" },
    FIRST_KILL = { id = "FIRST_KILL", icon = "Achievement_Boss_Gruul", label = "First Boss Kill", settingKey = "promptForFirstKills" },
    ATTUNEMENT = { id = "ATTUNEMENT", icon = "INV_Misc_Key_03", label = "Attunement Complete", settingKey = "promptForAttunements" },
    GAME_WIN = { id = "GAME_WIN", icon = "INV_Misc_Dice_02", label = "Game Victory", settingKey = "promptForGameWins" },
}

C.RP_STATUS = {
    IC = { id = "IC", label = "In Character", color = "00FF00", icon = "Spell_Holy_MindVision" },
    OOC = { id = "OOC", label = "Out of Character", color = "808080", icon = "Spell_Nature_Sleep" },
    LF_RP = { id = "LF_RP", label = "Looking for RP", color = "FF33CC", icon = "INV_ValentinesCandy" },
}
```

### 1.1 Add Social Sub-Tab Component (Components.lua)

```lua
-- Add after CreateTabButton (~line 850)

--[[
    Create a sub-tab button for Social tab's internal navigation
    @param parent Frame - Parent container
    @param text string - Tab label
    @param index number - Tab index (1-3)
    @param isActive boolean - Is this tab currently active
    @param onClick function - Click handler
    @return Button - The sub-tab button
]]
function HopeAddon.Components:CreateSocialSubTab(parent, text, index, isActive, onClick)
    local TAB_WIDTH = C.SOCIAL_TAB.TAB_WIDTH
    local TAB_HEIGHT = C.SOCIAL_TAB.TAB_HEIGHT

    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(TAB_WIDTH, TAB_HEIGHT)

    -- Background
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    tab.bg = bg

    -- Border
    HopeAddon:CreateBackdropFrame(tab, {
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })

    -- Label
    local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text)
    tab.label = label

    -- Badge (for count/new indicator)
    local badge = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    badge:SetPoint("TOP", label, "BOTTOM", 0, -2)
    badge:SetTextColor(0.7, 0.7, 0.7)
    tab.badge = badge

    -- State management
    function tab:SetActive(active)
        if active then
            bg:SetColorTexture(0.2, 0.15, 0.05, 0.9)
            tab:SetBackdropBorderColor(1.0, 0.82, 0.0, 1)  -- Gold
            label:SetTextColor(1.0, 0.82, 0.0)
        else
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            tab:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)  -- Grey
            label:SetTextColor(0.7, 0.7, 0.7)
        end
    end

    function tab:SetBadge(text)
        if text and text ~= "" then
            badge:SetText("(" .. text .. ")")
            badge:Show()
        else
            badge:Hide()
        end
    end

    -- Click handler
    tab:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        if onClick then onClick(index) end
    end)

    -- Hover effects
    tab:SetScript("OnEnter", function()
        if not tab.isActive then
            bg:SetColorTexture(0.15, 0.12, 0.05, 0.9)
        end
    end)

    tab:SetScript("OnLeave", function()
        if not tab.isActive then
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        end
    end)

    tab:SetActive(isActive)
    return tab
end
```

### 1.2 Add Tab State to charDb (Core.lua)

```lua
-- Add to defaultCharDb.social (~line 320)
social = {
    feed = {},
    mugsGiven = {},
    myRumors = {},
    companions = {
        list = {},
        outgoing = {},
        incoming = {},
    },

    -- NEW: UI state
    ui = {
        activeTab = "travelers",  -- "feed" | "travelers" | "companions"
        feed = {
            filter = "all",
            scrollPosition = 0,
            lastSeenTimestamp = 0,
        },
        travelers = {
            quickFilter = "all",
            sort = "online_first",
            searchText = "",
            scrollPosition = 0,
        },
        companions = {
            scrollPosition = 0,
        },
    },

    -- NEW: Share settings
    shareSettings = {
        promptForLoot = true,
        promptForFirstKills = true,
        promptForAttunements = true,
        promptForGameWins = true,
        autoPostBadges = true,
        autoPostMilestoneLevels = true,
        autoPostStatusChanges = true,
        lootMinQuality = 4,
        lootOnlyBossDrops = true,
    },
},
```

### 1.3 Refactor PopulateSocial() for Tabs (Journal.lua)

```lua
-- Replace existing PopulateSocial() (~line 3883)

function Journal:PopulateSocial()
    local scrollContainer = self.mainFrame.scrollContainer
    scrollContainer:ClearEntries(self.containerPool)

    -- Create status bar (always visible at top)
    local statusBar = self:CreateSocialStatusBar()
    scrollContainer:AddEntry(statusBar)
    self.socialContainers.statusBar = statusBar

    -- Create tab bar
    local tabBar = self:CreateSocialTabBar()
    scrollContainer:AddEntry(tabBar)
    self.socialContainers.tabBar = tabBar

    -- Create content container for active tab
    local content = self:CreateSocialContent()
    scrollContainer:AddEntry(content)
    self.socialContainers.content = content

    -- Populate active tab
    local activeTab = HopeAddon.charDb.social.ui.activeTab or "travelers"
    self:PopulateSocialTab(activeTab)

    self:UpdateFooter()
end

function Journal:CreateSocialTabBar()
    local container = self.containerPool:Acquire()
    container:SetHeight(32)
    container._componentType = "header"

    local tabs = { "Feed", "Travelers", "Companions" }
    local tabIds = { "feed", "travelers", "companions" }
    local activeTab = HopeAddon.charDb.social.ui.activeTab or "travelers"

    self.socialSubTabs = {}

    for i, label in ipairs(tabs) do
        local isActive = (tabIds[i] == activeTab)
        local tab = HopeAddon.Components:CreateSocialSubTab(
            container,
            label,
            i,
            isActive,
            function(index)
                self:SwitchSocialTab(tabIds[index])
            end
        )
        tab:SetPoint("LEFT", container, "LEFT", (i-1) * (C.SOCIAL_TAB.TAB_WIDTH + C.SOCIAL_TAB.TAB_SPACING), 0)
        self.socialSubTabs[tabIds[i]] = tab
    end

    -- Update badges
    self:UpdateSocialTabBadges()

    return container
end

function Journal:SwitchSocialTab(tabId)
    -- Save state
    HopeAddon.charDb.social.ui.activeTab = tabId

    -- Update tab visuals
    for id, tab in pairs(self.socialSubTabs) do
        tab:SetActive(id == tabId)
    end

    -- Repopulate content
    self:PopulateSocialTab(tabId)
end

function Journal:PopulateSocialTab(tabId)
    -- Clear existing content
    if self.socialContainers.content then
        -- Release pooled children
    end

    if tabId == "feed" then
        self:PopulateSocialFeed()
    elseif tabId == "travelers" then
        self:PopulateSocialTravelers()
    elseif tabId == "companions" then
        self:PopulateSocialCompanions()
    end
end

-- Content container for tab content
function Journal:CreateSocialContent()
    local container = self.containerPool:Acquire()
    container:SetHeight(400)  -- Will be resized dynamically by content
    container._componentType = "content"
    return container
end

-- Helper: Get online status from lastSeenTime
function Journal:GetOnlineStatus(lastSeenTime)
    if not lastSeenTime then return "offline" end
    local elapsed = time() - lastSeenTime
    if elapsed < C.SOCIAL_TAB.ONLINE_THRESHOLD then
        return "online"
    elseif elapsed < C.SOCIAL_TAB.AWAY_THRESHOLD then
        return "away"
    else
        return "offline"
    end
end

-- Helper: Get count for quick filter buttons
function Journal:GetFilterCount(filterId)
    local fellows = HopeAddon.Directory:GetAllEntries()
    if filterId == "all" then
        return #fellows
    end
    if filterId == "online" then
        local count = 0
        for _, f in ipairs(fellows) do
            if self:GetOnlineStatus(f.lastSeenTime) == "online" then
                count = count + 1
            end
        end
        return count
    end
    if filterId == "party" then
        local partyMembers = HopeAddon.FellowTravelers:GetPartyMembers()
        return partyMembers and #partyMembers or 0
    end
    if filterId == "lfrp" then
        local count = 0
        for _, f in ipairs(fellows) do
            if f.profile and f.profile.status == "LF_RP" then
                count = count + 1
            end
        end
        return count
    end
    return 0
end

-- Helper: Refresh travelers list when filters change
function Journal:RefreshTravelersList()
    if HopeAddon.charDb.social.ui.activeTab == "travelers" then
        self:PopulateSocialTravelers()
    end
end

-- Helper: Update tab badge counts
function Journal:UpdateSocialTabBadges()
    if not self.socialSubTabs then return end

    -- Feed: Show unread count
    local feed = HopeAddon.ActivityFeed:GetRecentFeed(50)
    local lastSeen = HopeAddon.charDb.social.ui.feed.lastSeenTimestamp or 0
    local unread = 0
    for _, activity in ipairs(feed) do
        if activity.time > lastSeen then
            unread = unread + 1
        end
    end
    if self.socialSubTabs.feed then
        self.socialSubTabs.feed:SetBadge(unread > 0 and tostring(unread) or "")
    end

    -- Travelers: Show online count
    local onlineCount = self:GetFilterCount("online")
    if self.socialSubTabs.travelers then
        self.socialSubTabs.travelers:SetBadge(onlineCount > 0 and tostring(onlineCount) or "")
    end

    -- Companions: Show online companions
    local companions = HopeAddon.Companions:GetAllCompanions()
    local onlineCompanions = 0
    for _, comp in ipairs(companions) do
        if self:GetOnlineStatus(comp.lastSeenTime) == "online" then
            onlineCompanions = onlineCompanions + 1
        end
    end
    if self.socialSubTabs.companions then
        self.socialSubTabs.companions:SetBadge(onlineCompanions > 0 and tostring(onlineCompanions) or "")
    end
end
```

### 1.5 Add Companion Card Pool (Journal.lua OnEnable)

```lua
-- Add to Journal:OnEnable() pool creation section (~line 130)
-- After existing pools like containerPool, cardPool, etc.

self.companionCardPool = HopeAddon.FramePool:Create("Button", UIParent, "BackdropTemplate")
```

```lua
-- Add to Journal:OnDisable() pool cleanup section (~line 155)

if self.companionCardPool then
    self.companionCardPool:Destroy()
    self.companionCardPool = nil
end
```

---

## PAYLOAD 2: Travelers Tab (Unified List)
**Files:** Journal.lua, Directory.lua
**Estimated Lines:** ~350
**Dependencies:** Payload 1

### 2.1 Quick Filter Component

```lua
function Journal:CreateQuickFilters(parent)
    local filters = {
        { id = "all", label = "All" },
        { id = "online", label = "Online" },
        { id = "party", label = "Party" },
        { id = "lfrp", label = "LF_RP" },
    }

    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(28)

    self.quickFilterButtons = {}
    local activeFilter = HopeAddon.charDb.social.ui.travelers.quickFilter or "all"

    local xOffset = 0
    for _, filter in ipairs(filters) do
        local count = self:GetFilterCount(filter.id)
        local btn = self:CreateQuickFilterButton(container, filter, count, filter.id == activeFilter)
        btn:SetPoint("LEFT", container, "LEFT", xOffset, 0)
        xOffset = xOffset + btn:GetWidth() + 4
        self.quickFilterButtons[filter.id] = btn
    end

    return container
end

function Journal:CreateQuickFilterButton(parent, filter, count, isActive)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(70, 24)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    btn.bg = bg

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetText(string.format("%s %d", filter.label, count))
    btn.label = label

    function btn:SetActive(active)
        self.isActive = active
        if active then
            bg:SetColorTexture(0.2, 0.6, 0.2, 0.8)  -- Green
            label:SetTextColor(1, 1, 1)
        else
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            label:SetTextColor(0.7, 0.7, 0.7)
        end
    end

    btn:SetScript("OnClick", function()
        self:SetQuickFilter(filter.id)
    end)

    btn:SetActive(isActive)
    return btn
end

function Journal:SetQuickFilter(filterId)
    HopeAddon.charDb.social.ui.travelers.quickFilter = filterId

    for id, btn in pairs(self.quickFilterButtons) do
        btn:SetActive(id == filterId)
    end

    self:RefreshTravelersList()
end
```

### 2.1.1 PopulateSocialTravelers (Main Function)

```lua
function Journal:PopulateSocialTravelers()
    local content = self.socialContainers.content
    if not content then return end

    -- Clear existing children (would need proper cleanup)
    -- For now, assume content is fresh from CreateSocialContent()

    -- Get filtered entries based on quick filter
    local quickFilter = HopeAddon.charDb.social.ui.travelers.quickFilter or "all"
    local entries = self:GetFilteredTravelerEntries(quickFilter)

    -- Create quick filter bar
    local filterBar = self:CreateQuickFilters(content)
    filterBar:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)

    -- Create rows for each traveler
    local yOffset = -32  -- Below filter bar
    for _, entry in ipairs(entries) do
        local row = self:CreateTravelerRow(content, entry)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        yOffset = yOffset - C.SOCIAL_TAB.TRAVELER_ROW_HEIGHT - 2
    end

    -- Adjust content height
    content:SetHeight(math.abs(yOffset) + 20)
end

function Journal:GetFilteredTravelerEntries(filterId)
    local allEntries = HopeAddon.Directory:GetAllEntries()

    if filterId == "all" then
        return allEntries
    end

    local filtered = {}
    for _, entry in ipairs(allEntries) do
        local include = false

        if filterId == "online" then
            include = self:GetOnlineStatus(entry.lastSeenTime) == "online"
        elseif filterId == "party" then
            local partyMembers = HopeAddon.FellowTravelers:GetPartyMembers() or {}
            for _, pm in ipairs(partyMembers) do
                if pm.name == entry.name then
                    include = true
                    break
                end
            end
        elseif filterId == "lfrp" then
            include = entry.profile and entry.profile.status == "LF_RP"
        end

        if include then
            table.insert(filtered, entry)
        end
    end

    return filtered
end
```

### 2.2 Unified Traveler Row

```lua
function Journal:CreateTravelerRow(parent, entry)
    local row = self.containerPool:Acquire()
    row:SetHeight(C.SOCIAL_TAB.TRAVELER_ROW_HEIGHT)
    row._componentType = "card"

    -- Online indicator (*, o, -)
    local statusDot = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusDot:SetPoint("LEFT", 8, 0)
    local onlineStatus = self:GetOnlineStatus(entry.lastSeenTime)
    if onlineStatus == "online" then
        statusDot:SetText("*")
        statusDot:SetTextColor(0.2, 1.0, 0.2)
    elseif onlineStatus == "away" then
        statusDot:SetText("o")
        statusDot:SetTextColor(1.0, 0.8, 0.2)
    else
        statusDot:SetText("-")
        statusDot:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(20, 20)
    classIcon:SetPoint("LEFT", statusDot, "RIGHT", 8, 0)
    local coords = CLASS_ICON_TCOORDS[entry.class]
    if coords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name + Level
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 8, 6)
    nameText:SetText(string.format("%s  %d %s", entry.name, entry.level, entry.class))

    -- Zone + Time
    local zoneText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -80, -8)
    zoneText:SetText(entry.lastSeenZone or "Unknown")
    zoneText:SetTextColor(0.7, 0.7, 0.7)

    local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -8)
    timeText:SetText(self:FormatTimeAgo(entry.lastSeenTime))
    timeText:SetTextColor(0.5, 0.5, 0.5)

    -- Second line: RP Status + Hook + Relationship
    local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("LEFT", classIcon, "RIGHT", 8, -8)
    local rpStatus = entry.profile and entry.profile.status or "OOC"
    local statusColor = C.RP_STATUS[rpStatus] and C.RP_STATUS[rpStatus].color or "808080"
    statusText:SetText("|cFF" .. statusColor .. rpStatus .. "|r")

    -- RP Hook preview (truncated)
    if entry.profile and entry.profile.rpHooks and entry.profile.rpHooks ~= "" then
        local hookPreview = entry.profile.rpHooks:sub(1, 40)
        if #entry.profile.rpHooks > 40 then hookPreview = hookPreview .. "..." end
        local hookText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hookText:SetPoint("LEFT", statusText, "RIGHT", 8, 0)
        hookText:SetText("- \"" .. hookPreview .. "\"")
        hookText:SetTextColor(0.6, 0.6, 0.6)
    end

    -- Relationship badge
    local relationship = HopeAddon.Relationships:GetRelationship(entry.name)
    local relType = relationship and relationship.relationship or "NONE"
    local relDef = C.RELATIONSHIP_TYPES[relType]
    if relDef and relType ~= "NONE" then
        local relBadge = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        relBadge:SetPoint("RIGHT", row, "RIGHT", -60, -8)
        relBadge:SetText("[" .. relDef.label .. "]")
        relBadge:SetTextColor(HopeAddon.ColorUtils:HexToRGB(relDef.color))
    end

    -- Companion star
    local isCompanion = HopeAddon.Companions:IsCompanion(entry.name)
    local starBtn = CreateFrame("Button", nil, row)
    starBtn:SetSize(20, 20)
    starBtn:SetPoint("RIGHT", row, "RIGHT", -35, 0)
    local starTex = starBtn:CreateTexture(nil, "ARTWORK")
    starTex:SetAllPoints()
    starTex:SetTexture(isCompanion and "Interface\\COMMON\\FavoritesIcon" or "Interface\\COMMON\\FavoritesIcon")
    starTex:SetDesaturated(not isCompanion)
    starTex:SetAlpha(isCompanion and 1 or 0.3)

    -- Actions menu button
    local actionsBtn = CreateFrame("Button", nil, row)
    actionsBtn:SetSize(20, 20)
    actionsBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    actionsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    actionsBtn:SetScript("OnClick", function()
        self:ShowTravelerActionsMenu(entry)
    end)

    return row
end
```

---

## PAYLOAD 3: Loot Share System
**Files:** ActivityFeed.lua, Journal.lua, Components.lua
**Estimated Lines:** ~600
**Dependencies:** Payload 1

### 3.0 Add LOOT to ACTIVITY Enum and FormatActivity (ActivityFeed.lua)

```lua
-- Add LOOT to the ACTIVITY enum at top of file (~line 20)
local ACTIVITY = {
    STATUS = "STATUS",
    BOSS = "BOSS",
    LEVEL = "LEVEL",
    GAME = "GAME",
    BADGE = "BADGE",
    RUMOR = "RUMOR",
    MUG = "MUG",
    LOOT = "LOOT",           -- NEW
    FIRST_KILL = "FIRST_KILL", -- NEW
    ATTUNEMENT = "ATTUNEMENT", -- NEW
}

-- Add to FormatActivity() function (~line 250) - add case for LOOT
elseif activity.type == ACTIVITY.LOOT then
    local itemLink = activity.data and activity.data.itemLink or "an item"
    return string.format("%s received %s", activity.player, itemLink)
```

### 3.1 Loot Detection Hook (ActivityFeed.lua)

```lua
-- Add to module state (~line 96)
ActivityFeed.pendingPrompts = {}
ActivityFeed.currentEncounter = nil
ActivityFeed.sharePromptFrame = nil

-- Add to SetupEventHooks() (~line 490)
-- Register loot event
self.eventFrame:RegisterEvent("CHAT_MSG_LOOT")

-- Add to event handler OnEvent (~line 486)
elseif event == "CHAT_MSG_LOOT" then
    local message = ...
    self:OnLootMessage(message)
end

-- New function
function ActivityFeed:OnLootMessage(message)
    -- Check if this is our loot
    local LOOT_PATTERN = "You receive loot: (.+)"
    local itemLink = message:match(LOOT_PATTERN)
    if not itemLink then return end

    -- Check settings
    local settings = HopeAddon.charDb.social.shareSettings
    if not settings.promptForLoot then return end

    -- Get item info
    local _, _, quality, _, _, itemType, itemSubType, _, equipLoc, icon, _, _, _, bindType = GetItemInfo(itemLink)

    -- Quality check (default: epic+)
    local minQuality = settings.lootMinQuality or 4
    if quality < minQuality then return end

    -- BoP check (only soulbound items worth sharing)
    if bindType ~= 1 then return end

    -- Queue the prompt
    self:QueueSharePrompt("LOOT", {
        itemLink = itemLink,
        itemIcon = icon,
        itemQuality = quality,
        itemType = itemType,
        itemSubType = itemSubType,
        equipLoc = equipLoc,
        source = self.currentEncounter and self.currentEncounter.bossName or "Unknown",
        location = GetZoneText(),
        isFirstKill = false,
    })
end
```

### 3.1.1 Encounter Context Hook (ActivityFeed.lua)

**Add to SetupEventHooks() to track boss kills for loot context:**

```lua
-- Add after existing hooks in SetupEventHooks() (~line 495)
-- Hook into boss kills to set encounter context for loot sharing

-- Store original if not already stored
if not self.originalHooks.OnBossKilled then
    -- Note: We're storing a DIFFERENT hook than the one used for activity posting
    -- This one sets the currentEncounter context BEFORE the boss kill is processed
end

-- Create a RaidData hook to set encounter context
if HopeAddon.RaidData and HopeAddon.RaidData.OnBossKilled then
    local existingHook = HopeAddon.RaidData.OnBossKilled
    HopeAddon.RaidData.OnBossKilled = function(rdModule, bossName, raidKey)
        -- Set encounter context BEFORE processing
        ActivityFeed.currentEncounter = {
            bossName = bossName,
            raidName = raidKey,
            dungeonName = nil,  -- Would need dungeon detection
            startTime = time(),
        }

        -- Call original
        existingHook(rdModule, bossName, raidKey)

        -- Clear after 60 seconds (give time for loot)
        HopeAddon.Timer:After(60, function()
            if ActivityFeed.currentEncounter and ActivityFeed.currentEncounter.bossName == bossName then
                ActivityFeed.currentEncounter = nil
            end
        end)
    end
end
```

```lua
-- Add GetLootContext helper function (~line 300)
function ActivityFeed:GetLootContext()
    if self.currentEncounter and self.currentEncounter.bossName then
        local charDb = HopeAddon.charDb
        local bossKills = charDb.journal and charDb.journal.bossKills
        local killCount = bossKills and bossKills[self.currentEncounter.bossName]
        return {
            source = self.currentEncounter.bossName,
            location = self.currentEncounter.raidName or self.currentEncounter.dungeonName or GetZoneText(),
            isFirstKill = not killCount or killCount.totalKills == 1,
        }
    end

    -- Fallback: use zone name
    return {
        source = "Unknown",
        location = GetZoneText(),
        isFirstKill = false,
    }
end
```

### 3.2 Share Prompt Queue Manager

```lua
function ActivityFeed:QueueSharePrompt(promptType, data)
    local prompt = {
        id = promptType .. "_" .. time() .. "_" .. math.random(1000),
        type = promptType,
        timestamp = time(),
        expireAt = time() + C.SOCIAL_TAB.SHARE_PROMPT_EXPIRE,
        data = data,
    }

    table.insert(self.pendingPrompts, prompt)
    HopeAddon:Debug("ActivityFeed: Queued share prompt:", promptType)

    -- If not in combat, show after delay
    if not InCombatLockdown() then
        HopeAddon.Timer:After(C.SOCIAL_TAB.SHARE_PROMPT_DELAY, function()
            self:ShowNextPrompt()
        end)
    end
end

function ActivityFeed:ShowNextPrompt()
    -- Clean expired
    self:CleanupExpiredPrompts()

    -- Already showing one?
    if self.sharePromptFrame and self.sharePromptFrame:IsShown() then
        return
    end

    -- Get next prompt
    local prompt = table.remove(self.pendingPrompts, 1)
    if not prompt then return end

    -- Show it
    self:ShowSharePrompt(prompt)
end

function ActivityFeed:CleanupExpiredPrompts()
    local now = time()
    for i = #self.pendingPrompts, 1, -1 do
        if self.pendingPrompts[i].expireAt < now then
            table.remove(self.pendingPrompts, i)
        end
    end
end

-- Combat end hook
function ActivityFeed:SetupCombatHook()
    if not self.combatFrame then
        self.combatFrame = CreateFrame("Frame")
    end

    self.combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.combatFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_ENABLED" then
            -- Delay to let combat truly end
            HopeAddon.Timer:After(C.SOCIAL_TAB.SHARE_PROMPT_DELAY, function()
                self:ShowNextPrompt()
            end)
        end
    end)
end
```

### 3.3 Share Prompt UI (Components.lua)

```lua
function HopeAddon.Components:CreateSharePrompt()
    local frame = CreateFrame("Frame", "HopeAddonSharePrompt", UIParent, "BackdropTemplate")
    frame:SetSize(C.SOCIAL_TAB.SHARE_PROMPT_WIDTH, C.SOCIAL_TAB.SHARE_PROMPT_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Share This Moment?")
    frame.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        HopeAddon.ActivityFeed:DismissPrompt()
    end)

    -- Item display area
    local itemFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    itemFrame:SetSize(C.SOCIAL_TAB.SHARE_PROMPT_WIDTH - 40, 70)
    itemFrame:SetPoint("TOP", 0, -50)
    itemFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    itemFrame:SetBackdropColor(0, 0, 0, 0.8)
    frame.itemFrame = itemFrame

    -- Item icon
    local itemIcon = itemFrame:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(40, 40)
    itemIcon:SetPoint("LEFT", 10, 0)
    frame.itemIcon = itemIcon

    -- Item name (colored by quality)
    local itemName = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemName:SetPoint("TOPLEFT", itemIcon, "TOPRIGHT", 10, -2)
    itemName:SetWidth(200)
    itemName:SetJustifyH("LEFT")
    frame.itemName = itemName

    -- Item details (type, source)
    local itemDetails = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemDetails:SetPoint("TOPLEFT", itemName, "BOTTOMLEFT", 0, -4)
    itemDetails:SetWidth(200)
    itemDetails:SetJustifyH("LEFT")
    itemDetails:SetTextColor(0.7, 0.7, 0.7)
    frame.itemDetails = itemDetails

    -- Source/Location
    local sourceText = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceText:SetPoint("TOPLEFT", itemDetails, "BOTTOMLEFT", 0, -2)
    sourceText:SetWidth(200)
    sourceText:SetJustifyH("LEFT")
    sourceText:SetTextColor(0.6, 0.6, 0.6)
    frame.sourceText = sourceText

    -- Comment input label
    local commentLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    commentLabel:SetPoint("TOPLEFT", itemFrame, "BOTTOMLEFT", 0, -12)
    commentLabel:SetText("Add a comment (optional):")
    commentLabel:SetTextColor(0.8, 0.8, 0.8)

    -- Comment input
    local commentBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    commentBox:SetSize(C.SOCIAL_TAB.SHARE_PROMPT_WIDTH - 40, 24)
    commentBox:SetPoint("TOP", commentLabel, "BOTTOM", 0, -4)
    commentBox:SetMaxLetters(C.SOCIAL_TAB.LOOT_COMMENT_MAX)
    commentBox:SetAutoFocus(false)
    frame.commentBox = commentBox

    -- Character count
    local charCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    charCount:SetPoint("TOPRIGHT", commentBox, "BOTTOMRIGHT", 0, -2)
    charCount:SetText("0/" .. C.SOCIAL_TAB.LOOT_COMMENT_MAX)
    charCount:SetTextColor(0.5, 0.5, 0.5)
    frame.charCount = charCount

    commentBox:SetScript("OnTextChanged", function(self)
        local len = #self:GetText()
        charCount:SetText(len .. "/" .. C.SOCIAL_TAB.LOOT_COMMENT_MAX)
        if len >= C.SOCIAL_TAB.LOOT_COMMENT_MAX then
            charCount:SetTextColor(1, 0.3, 0.3)
        else
            charCount:SetTextColor(0.5, 0.5, 0.5)
        end
    end)

    -- Share button
    local shareBtn = HopeAddon.Components:CreateStyledButton(frame, "Brag About It!", 140, 30)
    shareBtn:SetPoint("BOTTOMLEFT", 20, 50)
    shareBtn.bg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
    shareBtn:SetScript("OnClick", function()
        local comment = commentBox:GetText()
        HopeAddon.ActivityFeed:ShareCurrentPrompt(comment)
    end)
    frame.shareBtn = shareBtn

    -- Skip button
    local skipBtn = HopeAddon.Components:CreateStyledButton(frame, "Skip", 100, 30)
    skipBtn:SetPoint("BOTTOMRIGHT", -20, 50)
    skipBtn:SetScript("OnClick", function()
        HopeAddon.ActivityFeed:DismissPrompt()
    end)
    frame.skipBtn = skipBtn

    -- "Don't ask again" checkbox
    local dontAsk = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    dontAsk:SetSize(24, 24)
    dontAsk:SetPoint("BOTTOMLEFT", 16, 16)
    frame.dontAskCheckbox = dontAsk

    local dontAskLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dontAskLabel:SetPoint("LEFT", dontAsk, "RIGHT", 4, 0)
    dontAskLabel:SetText("Don't ask me about loot drops")
    dontAskLabel:SetTextColor(0.6, 0.6, 0.6)
    frame.dontAskLabel = dontAskLabel

    frame:Hide()
    return frame
end
```

### 3.4 Show/Dismiss Prompt Functions (ActivityFeed.lua)

```lua
function ActivityFeed:ShowSharePrompt(prompt)
    if not self.sharePromptFrame then
        self.sharePromptFrame = HopeAddon.Components:CreateSharePrompt()
    end

    local frame = self.sharePromptFrame
    self.currentPrompt = prompt

    -- Update UI based on prompt type
    if prompt.type == "LOOT" then
        self:PopulateLootPrompt(frame, prompt.data)
    elseif prompt.type == "FIRST_KILL" then
        self:PopulateFirstKillPrompt(frame, prompt.data)
    end

    -- Clear comment
    frame.commentBox:SetText("")
    frame.dontAskCheckbox:SetChecked(false)

    -- Show
    frame:Show()

    -- Play sound
    HopeAddon.Sounds:PlayNotification()
end

function ActivityFeed:PopulateLootPrompt(frame, data)
    frame.title:SetText("Share This Loot?")

    -- Item icon
    frame.itemIcon:SetTexture(data.itemIcon)

    -- Item name with quality color
    local qualityColor = ITEM_QUALITY_COLORS[data.itemQuality]
    frame.itemName:SetText(data.itemLink)

    -- Item type
    local typeText = data.itemSubType or data.itemType or "Item"
    if data.equipLoc and _G[data.equipLoc] then
        typeText = typeText .. " - " .. _G[data.equipLoc]
    end
    frame.itemDetails:SetText(typeText)

    -- Source
    local sourceStr = "Dropped from: " .. (data.source or "Unknown")
    if data.location then
        sourceStr = sourceStr .. " - " .. data.location
    end
    frame.sourceText:SetText(sourceStr)

    -- Update "don't ask" label
    frame.dontAskLabel:SetText("Don't ask me about loot drops")
end

function ActivityFeed:ShareCurrentPrompt(comment)
    if not self.currentPrompt then return end

    local prompt = self.currentPrompt

    -- Handle "don't ask again"
    if self.sharePromptFrame.dontAskCheckbox:GetChecked() then
        local settingKey = C.SHARE_PROMPT_TYPES[prompt.type].settingKey
        if settingKey then
            HopeAddon.charDb.social.shareSettings[settingKey] = false
        end
    end

    -- Share based on type
    if prompt.type == "LOOT" then
        self:ShareLoot(prompt.data, comment)
    elseif prompt.type == "FIRST_KILL" then
        self:ShareFirstKill(prompt.data, comment)
    end

    self:DismissPrompt()
end

function ActivityFeed:DismissPrompt()
    if self.sharePromptFrame then
        self.sharePromptFrame:Hide()
    end
    self.currentPrompt = nil

    -- Show next if any
    HopeAddon.Timer:After(0.5, function()
        self:ShowNextPrompt()
    end)
end

function ActivityFeed:ShareLoot(data, comment)
    local _, class = UnitClass("player")

    local activity = self:CreateActivity(
        ACTIVITY.LOOT,
        UnitName("player"),
        class,
        {
            itemLink = data.itemLink,
            source = data.source,
            location = data.location,
            comment = comment or "",
            isFirstKill = data.isFirstKill,
        }
    )

    self:AddActivity(activity)
    self:BroadcastActivity(activity)

    HopeAddon.Sounds:PlayAchievement()
    HopeAddon:Print("|cFF00FF00Shared with your Fellow Travelers!|r")
end
```

---

## PAYLOAD 4: Relationship System
**Files:** Relationships.lua, Components.lua, Journal.lua
**Estimated Lines:** ~250
**Dependencies:** Payload 2

### 4.1 Extend Relationships Module

```lua
-- Add to Relationships.lua

function Relationships:GetRelationshipType(playerName)
    local rel = self:GetRelationship(playerName)
    return rel and rel.relationship or "NONE"
end

function Relationships:SetRelationshipType(playerName, relType)
    if not C.RELATIONSHIP_TYPES[relType] then
        HopeAddon:Debug("Invalid relationship type:", relType)
        return false
    end

    local charDb = HopeAddon.charDb
    if not charDb.relationships[playerName] then
        charDb.relationships[playerName] = {
            addedDate = date("%Y-%m-%d"),
        }
    end

    charDb.relationships[playerName].relationship = relType
    charDb.relationships[playerName].relationshipDate = date("%Y-%m-%d")

    HopeAddon:Debug("Set relationship for", playerName, "to", relType)
    return true
end

function Relationships:ClearRelationship(playerName)
    return self:SetRelationshipType(playerName, "NONE")
end

function Relationships:GetPlayersByRelationship(relType)
    local result = {}
    for name, data in pairs(HopeAddon.charDb.relationships) do
        if data.relationship == relType then
            table.insert(result, name)
        end
    end
    return result
end
```

### 4.2 Relationship Dropdown Menu

```lua
-- Journal.lua - Add to ShowTravelerActionsMenu

function Journal:ShowTravelerActionsMenu(entry)
    local menu = {
        { text = entry.name, isTitle = true, notCheckable = true },
        { text = "Whisper", func = function() ChatFrame_SendTell(entry.name) end, notCheckable = true },
        { text = "Challenge to Game", func = function() self:ShowGameChallenge(entry.name) end, notCheckable = true },
        { text = "View Profile", func = function() self:ShowTravelerProfile(entry.name) end, notCheckable = true },
        { text = "", disabled = true, notCheckable = true },  -- Separator
        { text = "Set Relationship", hasArrow = true, notCheckable = true,
            menuList = self:CreateRelationshipSubmenu(entry.name)
        },
        { text = "Add/Edit Note", func = function() self:ShowNoteEditor(entry.name) end, notCheckable = true },
    }

    -- Add/Remove companion
    if HopeAddon.Companions:IsCompanion(entry.name) then
        table.insert(menu, { text = "Remove Companion", func = function()
            HopeAddon.Companions:RemoveCompanion(entry.name)
            self:RefreshTravelersList()
        end, notCheckable = true })
    else
        table.insert(menu, { text = "Add as Companion", func = function()
            HopeAddon.Companions:SendRequest(entry.name)
        end, notCheckable = true })
    end

    EasyMenu(menu, self.dropdownFrame, "cursor", 0, 0, "MENU")
end

function Journal:CreateRelationshipSubmenu(playerName)
    local currentRel = HopeAddon.Relationships:GetRelationshipType(playerName)
    local submenu = {}

    for id, def in pairs(C.RELATIONSHIP_TYPES) do
        table.insert(submenu, {
            text = def.label,
            checked = (currentRel == id),
            func = function()
                HopeAddon.Relationships:SetRelationshipType(playerName, id)
                self:RefreshTravelersList()
            end,
        })
    end

    -- Sort by priority
    table.sort(submenu, function(a, b)
        local aPri = C.RELATIONSHIP_TYPES[a.text] and C.RELATIONSHIP_TYPES[a.text].priority or 99
        local bPri = C.RELATIONSHIP_TYPES[b.text] and C.RELATIONSHIP_TYPES[b.text].priority or 99
        return aPri < bPri
    end)

    return submenu
end
```

---

## PAYLOAD 5: Feed Tab
**Files:** Journal.lua, ActivityFeed.lua
**Estimated Lines:** ~400
**Dependencies:** Payload 1, 3

### 5.0 PopulateSocialFeed (Main Function)

```lua
function Journal:PopulateSocialFeed()
    local content = self.socialContainers.content
    if not content then return end

    -- Get feed with optional filter
    local filterType = HopeAddon.charDb.social.ui.feed.filter or "all"
    local allActivities = HopeAddon.ActivityFeed:GetFeed()
    local activities = {}

    -- Filter activities
    for _, activity in ipairs(allActivities) do
        if filterType == "all" or activity.type:lower() == filterType then
            table.insert(activities, activity)
        end
    end

    -- Create filter dropdown (optional - could add later)
    -- local filterDropdown = self:CreateFeedFilterDropdown(content)
    -- filterDropdown:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)

    -- Group by time (Now, Earlier Today, Yesterday, This Week)
    local now = time()
    local todayStart = now - (now % 86400)  -- Start of today (midnight)
    local grouped = {
        now = {},           -- Last hour
        earlier = {},       -- Earlier today
        yesterday = {},     -- Yesterday
        thisWeek = {},      -- This week
        older = {},         -- Older
    }

    for _, activity in ipairs(activities) do
        local age = now - activity.time
        if age < 3600 then
            table.insert(grouped.now, activity)
        elseif activity.time >= todayStart then
            table.insert(grouped.earlier, activity)
        elseif activity.time >= todayStart - 86400 then
            table.insert(grouped.yesterday, activity)
        elseif age < 604800 then  -- 7 days
            table.insert(grouped.thisWeek, activity)
        else
            table.insert(grouped.older, activity)
        end
    end

    -- Create rows with time group headers
    local yOffset = 0
    local groups = {
        { key = "now", label = "Now" },
        { key = "earlier", label = "Earlier Today" },
        { key = "yesterday", label = "Yesterday" },
        { key = "thisWeek", label = "This Week" },
        { key = "older", label = "Older" },
    }

    for _, group in ipairs(groups) do
        local items = grouped[group.key]
        if #items > 0 then
            -- Group header
            local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            header:SetPoint("TOPLEFT", content, "TOPLEFT", 8, yOffset - 8)
            header:SetText("─── " .. group.label .. " ───")
            header:SetTextColor(0.5, 0.5, 0.5)
            yOffset = yOffset - 24

            -- Activity rows
            for _, activity in ipairs(items) do
                local row = self:CreateFeedRow(content, activity)
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
                row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
                yOffset = yOffset - C.SOCIAL_TAB.FEED_ROW_HEIGHT - 2
            end
        end
    end

    -- Mark feed as seen
    HopeAddon.charDb.social.ui.feed.lastSeenTimestamp = time()

    -- Empty state
    if #activities == 0 then
        local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("CENTER", content, "CENTER", 0, 0)
        emptyText:SetText("No recent activity.\nYour Fellow Travelers' adventures will appear here!")
        emptyText:SetTextColor(0.6, 0.6, 0.6)
        emptyText:SetJustifyH("CENTER")
    end

    -- Adjust content height
    content:SetHeight(math.abs(yOffset) + 20)
end
```

### 5.1 Feed Row Component

```lua
function Journal:CreateFeedRow(parent, activity)
    local row = self.containerPool:Acquire()
    row:SetHeight(C.SOCIAL_TAB.FEED_ROW_HEIGHT)
    row._componentType = "card"

    -- Activity icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 8, 0)
    local iconPath = self:GetActivityIcon(activity.type)
    icon:SetTexture(iconPath)

    -- Line 1: Player + Action
    local actionText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    actionText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 0)
    actionText:SetWidth(280)
    actionText:SetJustifyH("LEFT")

    local actionStr = HopeAddon.ActivityFeed:FormatActivity(activity)

    -- Personalize with relationship
    local rel = HopeAddon.Relationships:GetRelationshipType(activity.player)
    if rel and rel ~= "NONE" then
        local relDef = C.RELATIONSHIP_TYPES[rel]
        actionStr = actionStr:gsub(activity.player, "Your " .. relDef.label:lower() .. " " .. activity.player)
    end

    actionText:SetText(actionStr)

    -- Time
    local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -40, -8)
    timeText:SetText(HopeAddon.ActivityFeed:GetRelativeTime(activity.time))
    timeText:SetTextColor(0.5, 0.5, 0.5)

    -- Line 2: Context (zone, comment, etc.)
    local contextText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    contextText:SetPoint("TOPLEFT", actionText, "BOTTOMLEFT", 0, -4)
    contextText:SetWidth(280)
    contextText:SetJustifyH("LEFT")
    contextText:SetTextColor(0.6, 0.6, 0.6)

    local context = self:GetActivityContext(activity)
    contextText:SetText(context)

    -- Mug button
    local mugBtn = CreateFrame("Button", nil, row)
    mugBtn:SetSize(24, 24)
    mugBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    local mugTex = mugBtn:CreateTexture(nil, "ARTWORK")
    mugTex:SetAllPoints()
    mugTex:SetTexture("Interface\\Icons\\INV_Drink_04")

    local hasMugged = HopeAddon.ActivityFeed:HasMugged(activity.id)
    mugTex:SetDesaturated(hasMugged)

    local mugCount = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mugCount:SetPoint("RIGHT", mugBtn, "LEFT", -4, 0)
    mugCount:SetText(tostring(activity.mugs or 0))

    mugBtn:SetScript("OnClick", function()
        if not hasMugged then
            HopeAddon.ActivityFeed:GiveMug(activity.id)
            mugTex:SetDesaturated(true)
            mugCount:SetText(tostring((activity.mugs or 0) + 1))
        end
    end)

    return row
end

function Journal:GetActivityIcon(activityType)
    local icons = {
        STATUS = "Interface\\Icons\\Spell_Holy_MindVision",
        BOSS = "Interface\\Icons\\Achievement_Boss_Gruul",
        LEVEL = "Interface\\Icons\\Spell_Holy_GreaterHeal",
        GAME = "Interface\\Icons\\INV_Misc_Dice_02",
        BADGE = "Interface\\Icons\\Achievement_General",
        RUMOR = "Interface\\Icons\\INV_Letter_15",
        LOOT = "Interface\\Icons\\INV_Misc_Bag_10",
        FIRST_KILL = "Interface\\Icons\\Spell_Holy_SealOfMight",
        ATTUNEMENT = "Interface\\Icons\\INV_Misc_Key_03",
    }
    return icons[activityType] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function Journal:GetActivityContext(activity)
    if activity.type == "LOOT" and activity.data then
        local parts = {}
        if activity.data.source then table.insert(parts, activity.data.source) end
        if activity.data.location then table.insert(parts, activity.data.location) end
        if activity.data.comment and activity.data.comment ~= "" then
            table.insert(parts, "\"" .. activity.data.comment .. "\"")
        end
        return table.concat(parts, " - ")
    end

    -- Default: zone
    return activity.zone or ""
end
```

---

## PAYLOAD 6: Companions Tab
**Files:** Journal.lua
**Estimated Lines:** ~300
**Dependencies:** Payload 1, 4

### 6.0 CreateCompanionSection Helper

```lua
-- Track yOffset for section layout (module-level during populate)
Journal.companionYOffset = 0

function Journal:CreateCompanionSection(parent, title, companions, status)
    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)
    header:SetText(title .. " (" .. #companions .. ")")
    if status == "online" then
        header:SetTextColor(0.2, 1.0, 0.2)
    elseif status == "away" then
        header:SetTextColor(1.0, 0.8, 0.2)
    else
        header:SetTextColor(0.5, 0.5, 0.5)
    end
    self.companionYOffset = self.companionYOffset - 24

    -- Create card grid (4 per row)
    local cardSize = C.SOCIAL_TAB.COMPANION_CARD_SIZE
    local cardsPerRow = C.SOCIAL_TAB.COMPANION_CARDS_PER_ROW
    local spacing = 8

    for i, companion in ipairs(companions) do
        local col = (i - 1) % cardsPerRow
        local row = math.floor((i - 1) / cardsPerRow)

        local card = self:CreateCompanionCard(parent, companion, status)
        card:SetPoint("TOPLEFT", parent, "TOPLEFT",
            8 + col * (cardSize + spacing),
            self.companionYOffset - row * (cardSize + spacing))
    end

    -- Adjust yOffset for next section
    local rows = math.ceil(#companions / cardsPerRow)
    self.companionYOffset = self.companionYOffset - rows * (cardSize + spacing) - 16
end

function Journal:CreateCompanionRequests(parent, requests)
    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)
    header:SetText("Pending Requests (" .. #requests .. ")")
    header:SetTextColor(1.0, 0.82, 0.0)  -- Gold
    self.companionYOffset = self.companionYOffset - 24

    -- Request rows
    for _, request in ipairs(requests) do
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(parent:GetWidth() - 16, 30)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 8, 0)
        text:SetText(request.name .. " wants to be companions")

        local acceptBtn = HopeAddon.Components:CreateStyledButton(row, "Accept", 60, 24)
        acceptBtn:SetPoint("RIGHT", row, "RIGHT", -70, 0)
        acceptBtn.bg:SetColorTexture(0.2, 0.6, 0.2, 0.9)
        acceptBtn:SetScript("OnClick", function()
            HopeAddon.Companions:AcceptRequest(request.name)
            self:PopulateSocialCompanions()  -- Refresh
        end)

        local declineBtn = HopeAddon.Components:CreateStyledButton(row, "Decline", 60, 24)
        declineBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        declineBtn:SetScript("OnClick", function()
            HopeAddon.Companions:DeclineRequest(request.name)
            self:PopulateSocialCompanions()  -- Refresh
        end)

        self.companionYOffset = self.companionYOffset - 34
    end
end
```

### 6.1 Companion Card Grid

```lua
function Journal:PopulateSocialCompanions()
    local content = self.socialContainers.content
    if not content then return end

    -- Reset yOffset tracker
    self.companionYOffset = 0

    -- Get companions grouped by status
    local companions = HopeAddon.Companions:GetAllCompanions()
    local online, away, offline = {}, {}, {}

    for _, comp in ipairs(companions) do
        local status = self:GetOnlineStatus(comp.lastSeenTime)
        if status == "online" then
            table.insert(online, comp)
        elseif status == "away" then
            table.insert(away, comp)
        else
            table.insert(offline, comp)
        end
    end

    -- Online section
    if #online > 0 then
        self:CreateCompanionSection(content, "Online Now", online, "online")
    end

    -- Away section
    if #away > 0 then
        self:CreateCompanionSection(content, "Away", away, "away")
    end

    -- Offline section
    if #offline > 0 then
        self:CreateCompanionSection(content, "Offline", offline, "offline")
    end

    -- Pending requests
    local requests = HopeAddon.Companions:GetIncomingRequests()
    if #requests > 0 then
        self:CreateCompanionRequests(content, requests)
    end
end

function Journal:CreateCompanionCard(parent, companion, status)
    local card = self.companionCardPool:Acquire()
    card:SetSize(C.SOCIAL_TAB.COMPANION_CARD_SIZE, C.SOCIAL_TAB.COMPANION_CARD_SIZE)
    card._componentType = "card"

    -- Class icon
    local classIcon = card:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(24, 24)
    classIcon:SetPoint("TOP", 0, -8)
    local coords = CLASS_ICON_TCOORDS[companion.class]
    if coords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name
    local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("TOP", classIcon, "BOTTOM", 0, -4)
    name:SetText(companion.name:sub(1, 10))

    -- Status indicator
    local statusDot = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusDot:SetPoint("TOP", name, "BOTTOM", 0, -2)
    if status == "online" then
        statusDot:SetText("* " .. (companion.zone or ""):sub(1, 8))
        statusDot:SetTextColor(0.2, 1.0, 0.2)
    elseif status == "away" then
        local mins = math.floor((time() - (companion.lastSeenTime or 0)) / 60)
        statusDot:SetText("o " .. mins .. "m ago")
        statusDot:SetTextColor(1.0, 0.8, 0.2)
    else
        local days = math.floor((time() - (companion.lastSeenTime or 0)) / 86400)
        statusDot:SetText("- " .. days .. " days")
        statusDot:SetTextColor(0.5, 0.5, 0.5)
    end

    -- RP Status
    local rpStatus = companion.profile and companion.profile.status or "OOC"
    local rpText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rpText:SetPoint("TOP", statusDot, "BOTTOM", 0, -2)
    rpText:SetText(rpStatus)
    local statusColor = C.RP_STATUS[rpStatus] and C.RP_STATUS[rpStatus].color or "808080"
    rpText:SetTextColor(HopeAddon.ColorUtils:HexToRGB(statusColor))

    -- Relationship badge
    local rel = HopeAddon.Relationships:GetRelationshipType(companion.name)
    if rel and rel ~= "NONE" then
        local relDef = C.RELATIONSHIP_TYPES[rel]
        local relBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        relBadge:SetPoint("BOTTOM", card, "BOTTOM", 0, 8)
        relBadge:SetText("[" .. relDef.label .. "]")
        relBadge:SetTextColor(HopeAddon.ColorUtils:HexToRGB(relDef.color))
    end

    -- Click handler
    card:SetScript("OnClick", function()
        self:ShowTravelerActionsMenu(companion)
    end)

    return card
end
```

---

## File Change Summary

| File | Payload | Changes |
|------|---------|---------|
| `UI/Components.lua` | 1, 3 | CreateSocialSubTab(), CreateSharePrompt() |
| `Core/Core.lua` | 1 | Extend charDb.social defaults |
| `Core/Constants.lua` | All | C.SOCIAL_TAB, C.RELATIONSHIP_TYPES, C.SHARE_PROMPT_TYPES |
| `Journal/Journal.lua` | 1, 2, 5, 6 | Tab system, travelers list, feed, companions |
| `Social/ActivityFeed.lua` | 3, 5 | Loot detection, share prompts, LOOT activity type |
| `Social/Relationships.lua` | 4 | Relationship type functions |

---

## Testing Checklist

### Loot Sharing
- [ ] Receive epic item in dungeon -> prompt appears (out of combat)
- [ ] Receive epic item in raid -> prompt appears with boss name
- [ ] Click "Brag About It!" -> post appears in own feed
- [ ] Post broadcasts to Fellow Travelers
- [ ] Comment is included in post
- [ ] "Don't ask again" disables future prompts
- [ ] Skip dismisses without posting
- [ ] Prompt expires after 5 minutes

### Tab Navigation
- [ ] Clicking tabs switches content
- [ ] Tab state persists across /reload
- [ ] Badge counts update correctly

### Travelers Tab
- [ ] Quick filters work (All/Online/Party/LF_RP)
- [ ] Relationship tags display
- [ ] Actions menu works
- [ ] Companion star toggles

### Feed Tab
- [ ] Loot posts display with item link
- [ ] Relationship personalizes text ("Your ally...")
- [ ] Mug reactions work
- [ ] Filter dropdown works

### Companions Tab
- [ ] Grid layout displays
- [ ] Status grouping works
- [ ] Relationship badges show
- [ ] Request accept/decline works

### Relationship System
- [ ] Can set relationship from menu
- [ ] Relationship persists across /reload
- [ ] Displays on traveler row
- [ ] Displays on companion card
