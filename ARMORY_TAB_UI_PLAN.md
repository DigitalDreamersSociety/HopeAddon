# Armory Tab UI Plan

**Status:** 📋 UI PLANNING PHASE
**Created:** 2026-01-24
**Purpose:** Replace or enhance the existing Transmog tab with a comprehensive Armory system

---

## Table of Contents

1. [Concept Overview](#1-concept-overview)
2. [UI Layout & Hierarchy](#2-ui-layout--hierarchy)
3. [Container Architecture](#3-container-architecture)
4. [Slot Button System](#4-slot-button-system)
5. [Slot Detail Panel](#5-slot-detail-panel)
6. [Tier Selection System](#6-tier-selection-system)
7. [State Management](#7-state-management)
8. [Frame Pooling Strategy](#8-frame-pooling-strategy)
9. [Animation & Effects](#9-animation--effects)
10. [SavedVariables Structure](#10-savedvariables-structure)
11. [Implementation Phases](#11-implementation-phases)
12. [Design Mockups](#12-design-mockups)

---

## 1. Concept Overview

### 1.1 Purpose

The **Armory Tab** is an "all-in-one" gear management and upgrade planning system that combines:

1. **Character Equipment View** - Visual paperdoll showing all 17 equipment slots
2. **Per-Slot Detail Panels** - Click any slot to see:
   - Currently equipped item
   - Recommended upgrades organized by source tier
   - Wishlist functionality
3. **Tier Selector** - T4 / T5 / T6 content filtering
4. **Spec Awareness** - Role-based recommendations

### 1.2 Design Philosophy

> "Like WoW's character screen, but with a built-in gear advisor for each slot"

- **Familiar Layout:** Mirrors WoW's character screen with slots around a central model
- **Progressive Disclosure:** Overview shows upgrade indicators; click for full details
- **One-Stop Shop:** Everything about gear planning in one tab

### 1.3 Relationship to Transmog Tab

**Two Options:**

| Option | Description | Recommendation |
|--------|-------------|----------------|
| **Option A: Replace** | Armory replaces Transmog as single tab | Less maintenance, cleaner navigation |
| **Option B: Separate** | Keep both Transmog and Armory tabs | More tabs but separation of concerns |

**Recommended: Option A (Replace with Combined Tab)**
- Armory subsumes Transmog's tier preview functionality
- Visual preview mode toggle: "Gear Advisor" vs "Appearance Preview"
- Single model instance, shared lighting presets

---

## 2. UI Layout & Hierarchy

### 2.1 Overall Layout Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TIER SELECTOR BAR                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                    ┌───────────────┐ │
│  │   T4    │  │   T5    │  │   T6    │                    │ Spec Dropdown │ │
│  └─────────┘  └─────────┘  └─────────┘                    └───────────────┘ │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         MAIN CONTENT AREA                            │   │
│  │                                                                      │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │                    PAPERDOLL CONTAINER                        │   │   │
│  │  │                                                               │   │   │
│  │  │   [HEAD]                                        [NECK]        │   │   │
│  │  │                                                               │   │   │
│  │  │   [SHLD]      ┌─────────────────────┐          [BACK]        │   │   │
│  │  │               │                     │                         │   │   │
│  │  │   [CHST]      │   CHARACTER MODEL   │          [WRIST]       │   │   │
│  │  │               │                     │                         │   │   │
│  │  │   [WAIST]     │                     │          [HANDS]       │   │   │
│  │  │               │                     │                         │   │   │
│  │  │   [LEGS]      └─────────────────────┘          [FEET]        │   │   │
│  │  │                                                               │   │   │
│  │  │   [RING1] [RING2] [TRNK1] [TRNK2]  [MH] [OH] [RANGED]       │   │   │
│  │  │                                                               │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │                 SLOT DETAIL PANEL (Expandable)                │   │   │
│  │  │  (Appears when slot is clicked, shows upgrade recommendations)│   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                              STATUS FOOTER                                   │
│  "Gear Score: 125 avg | Upgrades Available: 8 | Wishlisted: 5"              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Responsive Behavior

The layout adjusts based on whether a slot is selected:

**State A: No Slot Selected (Overview Mode)**
```
┌───────────────────────────────────────┐
│          PAPERDOLL CONTAINER          │
│  (Large model, all slots visible)     │
│  Height: 450px                        │
└───────────────────────────────────────┘
```

**State B: Slot Selected (Detail Mode)**
```
┌───────────────────────────────────────┐
│          PAPERDOLL CONTAINER          │
│  (Compact, selected slot highlighted) │
│  Height: 280px                        │
├───────────────────────────────────────┤
│         SLOT DETAIL PANEL             │
│  (Expands to show upgrade options)    │
│  Height: 300px (scrollable)           │
└───────────────────────────────────────┘
```

---

## 3. Container Architecture

### 3.1 Frame Hierarchy

```lua
Journal.armoryUI = {
    -- Top-level container
    container = nil,              -- Frame: Main armory container

    -- Tier selection bar
    tierBar = nil,                -- Frame: Horizontal tier selection
    tierButtons = {},             -- [tier] = Button (T4, T5, T6)
    specDropdown = nil,           -- UIDropDownMenu

    -- Paperdoll section
    paperdoll = {
        container = nil,          -- Frame: Paperdoll wrapper
        model = nil,              -- DressUpModel: Character preview
        modelBg = nil,            -- Texture: Model background
        slotsContainer = nil,     -- Frame: Container for slot buttons
        slots = {},               -- [slotName] = SlotButton
    },

    -- Detail panel section
    detailPanel = {
        container = nil,          -- Frame: Detail panel wrapper
        header = nil,             -- Frame: Panel header with slot info
        scrollFrame = nil,        -- ScrollFrame: Scrollable content
        content = nil,            -- Frame: Scroll content
        upgradeCards = {},        -- Pooled upgrade cards
    },

    -- Footer
    footer = nil,                 -- Frame: Status bar
    gearScoreText = nil,          -- FontString: Average iLvl display
    upgradeCountText = nil,       -- FontString: Upgrades available
    wishlistCountText = nil,      -- FontString: Wishlist count
}
```

### 3.2 Container Creation Pattern

```lua
function Journal:CreateArmoryContainers()
    local content = self.mainFrame.scrollContainer.content

    -- Main container (full width of scroll content)
    local container = CreateFrame("Frame", nil, content)
    container:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    container:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    container:SetHeight(800)  -- Will adjust based on state
    self.armoryUI.container = container

    -- Tier selection bar (horizontal, top)
    local tierBar = CreateFrame("Frame", nil, container)
    tierBar:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    tierBar:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
    tierBar:SetHeight(50)
    self.armoryUI.tierBar = tierBar

    -- Paperdoll container (center section)
    local paperdoll = CreateFrame("Frame", nil, container)
    paperdoll:SetPoint("TOPLEFT", tierBar, "BOTTOMLEFT", 0, -10)
    paperdoll:SetPoint("TOPRIGHT", tierBar, "BOTTOMRIGHT", 0, -10)
    paperdoll:SetHeight(450)  -- Adjustable
    self.armoryUI.paperdoll.container = paperdoll

    -- Detail panel (bottom section, initially hidden)
    local detailPanel = CreateFrame("Frame", nil, container)
    detailPanel:SetPoint("TOPLEFT", paperdoll, "BOTTOMLEFT", 0, -10)
    detailPanel:SetPoint("TOPRIGHT", paperdoll, "BOTTOMRIGHT", 0, -10)
    detailPanel:SetHeight(300)
    detailPanel:Hide()  -- Shown when slot selected
    self.armoryUI.detailPanel.container = detailPanel

    -- Build child elements
    self:CreateArmoryTierBar()
    self:CreateArmoryPaperdoll()
    self:CreateArmoryDetailPanel()
    self:CreateArmoryFooter()
end
```

### 3.3 Container Dimensions

```lua
local ARMORY_UI = {
    -- Overall
    CONTAINER_MIN_HEIGHT = 550,
    CONTAINER_EXPANDED_HEIGHT = 850,

    -- Tier bar
    TIER_BAR_HEIGHT = 50,
    TIER_BUTTON_WIDTH = 100,
    TIER_BUTTON_HEIGHT = 36,
    TIER_BUTTON_SPACING = 10,

    -- Paperdoll
    PAPERDOLL_COMPACT_HEIGHT = 280,
    PAPERDOLL_FULL_HEIGHT = 450,
    MODEL_WIDTH = 200,
    MODEL_HEIGHT = 280,

    -- Slot buttons
    SLOT_BUTTON_SIZE = 44,
    SLOT_BUTTON_ICON_SIZE = 36,
    SLOT_INDICATOR_SIZE = 14,

    -- Detail panel
    DETAIL_PANEL_HEIGHT = 300,
    DETAIL_PANEL_PADDING = 15,
    UPGRADE_CARD_HEIGHT = 80,
    UPGRADE_CARD_SPACING = 8,

    -- Footer
    FOOTER_HEIGHT = 30,
}
```

---

## 4. Slot Button System

### 4.1 Slot Button Visual States

Each equipment slot button has multiple visual states:

| State | Border Color | Indicator | Background |
|-------|--------------|-----------|------------|
| **Empty** | Grey (#808080) | None | Dark grey |
| **Equipped (BiS)** | Gold (#FFD700) | ★ Gold star | Dark grey |
| **Equipped (OK)** | Green (#00FF00) | ✓ Checkmark | Dark grey |
| **Upgrade Available** | Orange (#FFA500) | ↑ Arrow | Subtle pulse |
| **Major Upgrade** | Red (#FF4444) | !! Exclaim | Glow pulse |
| **Selected** | Bright Gold | Ring glow | Highlight |
| **Wishlisted** | Purple outline | ♥ Heart | Subtle purple |

### 4.2 Slot Button Structure

```lua
SlotButton = {
    frame = Button,           -- Main button frame
    icon = Texture,           -- Item icon (or slot placeholder)
    iconBorder = Texture,     -- Quality/state colored border
    slotLabel = FontString,   -- "HEAD", "CHEST", etc.
    indicator = {
        frame = Frame,        -- Indicator container
        icon = Texture,       -- State icon (arrow, star, etc.)
        text = FontString,    -- Optional "+15" upgrade text
    },
    glow = Texture,           -- Selection/upgrade glow
    cooldown = Cooldown,      -- For animation effects

    -- Data
    slotId = number,          -- WoW inventory slot ID
    slotName = string,        -- "head", "chest", etc.
    equippedItem = table,     -- Current item data
    upgradeStatus = string,   -- "bis", "ok", "upgrade", "major"
    isSelected = boolean,
    isWishlisted = boolean,
}
```

### 4.3 Slot Positions (Character Creator Layout)

```lua
local ARMORY_SLOT_POSITIONS = {
    -- Left column (armor)
    head      = { anchor = "TOPLEFT",  x = 20,  y = -20 },
    shoulders = { anchor = "TOPLEFT",  x = 20,  y = -75 },
    chest     = { anchor = "TOPLEFT",  x = 20,  y = -130 },
    waist     = { anchor = "TOPLEFT",  x = 20,  y = -185 },
    legs      = { anchor = "TOPLEFT",  x = 20,  y = -240 },

    -- Right column (accessories)
    neck      = { anchor = "TOPRIGHT", x = -20, y = -20 },
    back      = { anchor = "TOPRIGHT", x = -20, y = -75 },
    wrist     = { anchor = "TOPRIGHT", x = -20, y = -130 },
    hands     = { anchor = "TOPRIGHT", x = -20, y = -185 },
    feet      = { anchor = "TOPRIGHT", x = -20, y = -240 },

    -- Bottom row (jewelry, weapons)
    ring1     = { anchor = "BOTTOM", x = -150, y = 20 },
    ring2     = { anchor = "BOTTOM", x = -100, y = 20 },
    trinket1  = { anchor = "BOTTOM", x = -50,  y = 20 },
    trinket2  = { anchor = "BOTTOM", x = 0,    y = 20 },
    mainhand  = { anchor = "BOTTOM", x = 50,   y = 20 },
    offhand   = { anchor = "BOTTOM", x = 100,  y = 20 },
    ranged    = { anchor = "BOTTOM", x = 150,  y = 20 },
}

-- Slot display order for iteration
local ARMORY_SLOT_ORDER = {
    "head", "neck", "shoulders", "back", "chest", "wrist",
    "waist", "hands", "legs", "feet",
    "ring1", "ring2", "trinket1", "trinket2",
    "mainhand", "offhand", "ranged"
}
```

### 4.4 Slot Button Click Behavior

```lua
function Journal:OnArmorySlotClick(slotName)
    local wasSelected = self.armoryState.selectedSlot == slotName

    -- Deselect current
    if self.armoryState.selectedSlot then
        self:DeselectArmorySlot(self.armoryState.selectedSlot)
    end

    if wasSelected then
        -- Toggle off - collapse detail panel
        self.armoryState.selectedSlot = nil
        self:CollapseArmoryDetailPanel()
    else
        -- Select new slot - expand detail panel
        self.armoryState.selectedSlot = slotName
        self:SelectArmorySlot(slotName)
        self:ExpandArmoryDetailPanel(slotName)
    end

    -- Play sound
    HopeAddon.Sounds:PlayClick()
end
```

---

## 5. Slot Detail Panel

### 5.1 Detail Panel Layout

When a slot is selected, the detail panel expands below the paperdoll:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SLOT DETAIL PANEL: HEAD                                           [X Close]│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CURRENTLY EQUIPPED                                                  │   │
│  │  [Icon] Helm of the Warp                                            │   │
│  │         iLvl 105 | Quest Reward | +28 Str, +24 Sta                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  TIER 4 UPGRADES                                   [▼ Collapse]     │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  ┌───────────────────────────────────────────────────────────────┐  │   │
│  │  │ [★ BEST]  Warbringer Greathelm                         [♥]   │  │   │
│  │  │ [Icon]    iLvl 120 | T4 Token | Prince Malchezaar            │  │   │
│  │  │           +43 Str, +45 Sta, +32 Defense Rating               │  │   │
│  │  │           >>> +15 iLvl upgrade                               │  │   │
│  │  └───────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌───────────────────────────────────────────────────────────────┐  │   │
│  │  │ [ALT]     Eternium Greathelm                           [♥]   │  │   │
│  │  │ [Icon]    iLvl 115 | Heroic Mechanar                         │  │   │
│  │  │           +38 Str, +40 Sta, +28 Defense Rating               │  │   │
│  │  │           >>> +10 iLvl upgrade                               │  │   │
│  │  └───────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌───────────────────────────────────────────────────────────────┐  │   │
│  │  │ [ALT]     Felsteel Helm                                [♥]   │  │   │
│  │  │ [Icon]    iLvl 115 | Blacksmithing (BoE)                     │  │   │
│  │  │           +35 Str, +38 Sta, +25 Defense Rating               │  │   │
│  │  │           >>> +10 iLvl upgrade                               │  │   │
│  │  └───────────────────────────────────────────────────────────────┘  │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  BADGE OF JUSTICE REWARDS                          [▼ Collapse]     │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │  (Similar upgrade cards for badge gear...)                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Detail Panel Sections

The detail panel organizes upgrades into collapsible sections:

```lua
local DETAIL_PANEL_SECTIONS = {
    { id = "equipped",  title = "CURRENTLY EQUIPPED",    collapsible = false },
    { id = "tier",      title = "TIER %d UPGRADES",      collapsible = true },
    { id = "heroic",    title = "HEROIC DUNGEONS",       collapsible = true },
    { id = "badge",     title = "BADGE OF JUSTICE",      collapsible = true },
    { id = "rep",       title = "REPUTATION REWARDS",    collapsible = true },
    { id = "crafted",   title = "CRAFTED GEAR",          collapsible = true },
}
```

### 5.3 Upgrade Card Structure

```lua
UpgradeCard = {
    frame = Frame,            -- Card container
    rankBadge = {
        frame = Frame,        -- "BEST" / "ALT" badge
        text = FontString,
    },
    itemIcon = Texture,       -- Item icon
    itemBorder = Texture,     -- Quality border
    nameText = FontString,    -- Item name (quality colored)
    statsText = FontString,   -- "+43 Str, +45 Sta..."
    sourceText = FontString,  -- "Prince Malchezaar - Karazhan"
    upgradeText = FontString, -- "+15 iLvl upgrade" (green)
    wishlistButton = Button,  -- Heart toggle

    -- Data
    itemData = table,
    isWishlisted = boolean,
}
```

### 5.4 Upgrade Card Colors

```lua
local UPGRADE_CARD_COLORS = {
    -- Rank badge backgrounds
    BEST = { bg = {0.8, 0.6, 0, 0.3}, text = "GOLD_BRIGHT" },
    ALT  = { bg = {0.3, 0.3, 0.3, 0.3}, text = "GREY" },

    -- Source type colors
    tier     = "EPIC_PURPLE",
    heroic   = "RARE_BLUE",
    badge    = "GOLD_BRIGHT",
    rep      = "FEL_GREEN",
    crafted  = "BRONZE",

    -- Upgrade indicator
    major    = "HELLFIRE_RED",    -- +20 iLvl or more
    moderate = "GOLD_BRIGHT",     -- +10-19 iLvl
    minor    = "FEL_GREEN",       -- +1-9 iLvl
    equal    = "GREY",            -- Same iLvl
}
```

---

## 6. Tier Selection System

### 6.1 Tier Tab Bar Design

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐        ┌────────┐ │
│  │     T4        │  │     T5        │  │     T6        │        │ Prot   │ │
│  │  Phase 1      │  │  Phase 2      │  │  Phase 3      │        │ Warrior│ │
│  │ ═══════════   │  │               │  │               │        │   v    │ │
│  └───────────────┘  └───────────────┘  └───────────────┘        └────────┘ │
│     ^ Active                                                     Spec DD   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Tier Button States

| State | Border | Background | Text | Underline |
|-------|--------|------------|------|-----------|
| **Active** | Tier color | Lightened | White | Thick colored bar |
| **Inactive** | Grey | Dark | Grey | None |
| **Hover** | Tier color (dim) | Slight brighten | Light grey | Thin line |
| **Disabled** | Dark grey | Darkest | Dark grey | None |

### 6.3 Tier Colors

```lua
local TIER_COLORS = {
    [4] = { r = 0.2, g = 0.8, b = 0.2 },  -- FEL_GREEN
    [5] = { r = 0.3, g = 0.7, b = 1.0 },  -- SKY_BLUE
    [6] = { r = 0.9, g = 0.2, b = 0.1 },  -- HELLFIRE_RED
}

local TIER_INFO = {
    [4] = { name = "T4", subtitle = "Phase 1", raids = "Kara, Gruul, Mag" },
    [5] = { name = "T5", subtitle = "Phase 2", raids = "SSC, TK" },
    [6] = { name = "T6", subtitle = "Phase 3", raids = "Hyjal, BT, SWP" },
}
```

### 6.4 Tier Change Behavior

```lua
function Journal:SelectArmoryTier(tier)
    -- Update state
    local oldTier = self.armoryState.selectedTier
    self.armoryState.selectedTier = tier

    -- Update tier button visuals
    for t, btn in pairs(self.armoryUI.tierButtons) do
        self:UpdateTierButtonVisual(btn, t, t == tier)
    end

    -- Refresh slot buttons with new tier's upgrade data
    self:RefreshArmorySlotIndicators()

    -- If detail panel is open, refresh it
    if self.armoryState.selectedSlot then
        self:RefreshArmoryDetailPanel()
    end

    -- Save state
    HopeAddon.charDb.armory.selectedTier = tier

    -- Animation: Color flash on tier change
    if oldTier ~= tier and HopeAddon.Effects then
        HopeAddon.Effects:ColorFlash(self.armoryUI.tierButtons[tier], TIER_COLORS[tier])
    end
end
```

---

## 7. State Management

### 7.1 Runtime State

```lua
Journal.armoryState = {
    -- Selection state
    selectedTier = 4,           -- Current tier filter (4, 5, 6)
    selectedSlot = nil,         -- Currently open slot (nil = none)

    -- UI state
    isDetailPanelExpanded = false,
    expandedSections = {},      -- [sectionId] = true/false for collapsible

    -- Data state
    currentRole = nil,          -- Detected from spec: "tank", "healer", etc.
    currentSpec = nil,          -- Spec tab index (1, 2, 3)

    -- Cache
    equippedItems = {},         -- [slotName] = itemData
    upgradeData = {},           -- [tier][slotName] = { best, alternatives }
    slotStatuses = {},          -- [slotName] = "bis" | "ok" | "upgrade" | "major"
}
```

### 7.2 State Initialization

```lua
function Journal:InitializeArmoryState()
    -- Load saved preferences
    local saved = HopeAddon.charDb.armory
    self.armoryState.selectedTier = saved.selectedTier or 4

    -- Detect current spec and role
    local specName, specTab = HopeAddon:GetPlayerSpec()
    local _, _, classToken = UnitClass("player")
    self.armoryState.currentSpec = specTab
    self.armoryState.currentRole = HopeAddon:GetSpecRole(classToken, specTab)

    -- Scan equipped items
    self:ScanEquippedItems()

    -- Calculate upgrade statuses for all slots
    self:CalculateUpgradeStatuses()
end
```

### 7.3 Equipped Item Scanning

```lua
function Journal:ScanEquippedItems()
    self.armoryState.equippedItems = {}

    for slotName, slotId in pairs(C.INVENTORY_SLOT_IDS) do
        local itemLink = GetInventoryItemLink("player", slotId)
        if itemLink then
            local itemName, _, itemQuality, itemLevel = GetItemInfo(itemLink)
            local itemId = GetItemInfoInstant(itemLink)
            local itemIcon = GetInventoryItemTexture("player", slotId)

            self.armoryState.equippedItems[slotName] = {
                itemId = itemId,
                itemLink = itemLink,
                name = itemName,
                quality = itemQuality,
                iLvl = itemLevel,
                icon = itemIcon,
                slotId = slotId,
            }
        end
    end
end
```

### 7.4 Upgrade Status Calculation

```lua
function Journal:CalculateUpgradeStatuses()
    local tier = self.armoryState.selectedTier
    local role = self.armoryState.currentRole
    local equipped = self.armoryState.equippedItems

    for _, slotName in ipairs(ARMORY_SLOT_ORDER) do
        local bestUpgrade = self:GetBestUpgrade(tier, role, slotName)
        local equippedItem = equipped[slotName]

        local status = "empty"
        local iLvlDiff = 0

        if equippedItem and bestUpgrade then
            iLvlDiff = bestUpgrade.iLvl - equippedItem.iLvl

            if equippedItem.itemId == bestUpgrade.itemId then
                status = "bis"
            elseif iLvlDiff >= 20 then
                status = "major"
            elseif iLvlDiff >= 10 then
                status = "upgrade"
            elseif iLvlDiff > 0 then
                status = "minor"
            else
                status = "ok"
            end
        elseif equippedItem then
            status = "ok"  -- No upgrade data for this tier
        end

        self.armoryState.slotStatuses[slotName] = {
            status = status,
            iLvlDiff = iLvlDiff,
            bestUpgrade = bestUpgrade,
        }
    end
end
```

---

## 8. Frame Pooling Strategy

### 8.1 Pool Analysis

| Frame Type | Count | Dynamic? | Pool? | Reasoning |
|------------|-------|----------|-------|-----------|
| container | 1 | No | ❌ | Single instance |
| tierButtons | 3 | No | ❌ | Fixed count |
| slotButtons | 17 | No | ❌ | Fixed count |
| model | 1 | No | ❌ | Single DressUpModel |
| detailPanel | 1 | No | ❌ | Single instance |
| **upgradeCards** | **0-10** | **Yes** | **✅** | Variable per slot |
| **sectionHeaders** | **0-6** | **Yes** | **✅** | Variable sections |

### 8.2 Upgrade Card Pool

```lua
-- Pool for upgrade recommendation cards
function Journal:CreateArmoryPools()
    -- Upgrade card pool
    self.armoryUpgradeCardPool = HopeAddon.FramePool:Create(
        "Button",
        self.armoryUI.detailPanel.content,
        "BackdropTemplate",
        function(card) self:InitializeUpgradeCard(card) end,
        function(card) self:ResetUpgradeCard(card) end
    )

    -- Section header pool
    self.armorySectionPool = HopeAddon.FramePool:Create(
        "Frame",
        self.armoryUI.detailPanel.content,
        nil,
        function(section) self:InitializeSectionHeader(section) end,
        function(section) self:ResetSectionHeader(section) end
    )
end

function Journal:DestroyArmoryPools()
    if self.armoryUpgradeCardPool then
        self.armoryUpgradeCardPool:Destroy()
        self.armoryUpgradeCardPool = nil
    end
    if self.armorySectionPool then
        self.armorySectionPool:Destroy()
        self.armorySectionPool = nil
    end
end
```

### 8.3 Pool Lifecycle

```lua
-- When opening detail panel for a slot:
function Journal:PopulateDetailPanel(slotName)
    -- Release all pooled frames first
    self.armoryUpgradeCardPool:ReleaseAll()
    self.armorySectionPool:ReleaseAll()

    -- Get upgrade data
    local tier = self.armoryState.selectedTier
    local role = self.armoryState.currentRole
    local upgrades = self:GetSlotUpgrades(tier, role, slotName)

    local yOffset = 0

    -- Equipped section (always shown)
    local equippedSection = self.armorySectionPool:Acquire()
    self:SetupSectionHeader(equippedSection, "CURRENTLY EQUIPPED", false)
    equippedSection:SetPoint("TOPLEFT", 0, -yOffset)
    yOffset = yOffset + 40

    -- ... create upgrade cards for each category
end

-- When closing detail panel or switching slots:
function Journal:ClearDetailPanel()
    self.armoryUpgradeCardPool:ReleaseAll()
    self.armorySectionPool:ReleaseAll()
end
```

---

## 9. Animation & Effects

### 9.1 Slot Button Animations

```lua
-- Upgrade available pulse
function Journal:StartUpgradePulse(slotButton)
    if not slotButton.pulseAnim then
        slotButton.pulseAnim = HopeAddon.Animations:CreatePulse(slotButton.glow, {
            minAlpha = 0.2,
            maxAlpha = 0.7,
            duration = 1.5,
            loop = true,
        })
    end
    slotButton.pulseAnim:Play()
end

-- Selection highlight
function Journal:HighlightSlot(slotButton, highlight)
    if highlight then
        slotButton.glow:Show()
        HopeAddon.Effects:CreatePulsingGlow(slotButton, "GOLD_BRIGHT", 0.7)
    else
        HopeAddon.Effects:StopGlowsOnParent(slotButton)
        slotButton.glow:Hide()
    end
end
```

### 9.2 Detail Panel Expand/Collapse

```lua
function Journal:ExpandArmoryDetailPanel(slotName)
    local detailPanel = self.armoryUI.detailPanel.container
    local paperdoll = self.armoryUI.paperdoll.container

    -- Shrink paperdoll
    paperdoll:SetHeight(ARMORY_UI.PAPERDOLL_COMPACT_HEIGHT)

    -- Show and populate detail panel
    detailPanel:Show()
    self:PopulateDetailPanel(slotName)

    -- Animate slide-in (optional)
    if HopeAddon.Animations then
        HopeAddon.Animations:SlideIn(detailPanel, "TOP", 0.2)
    end

    -- Update container height
    self.armoryUI.container:SetHeight(ARMORY_UI.CONTAINER_EXPANDED_HEIGHT)
end

function Journal:CollapseArmoryDetailPanel()
    local detailPanel = self.armoryUI.detailPanel.container
    local paperdoll = self.armoryUI.paperdoll.container

    -- Hide detail panel
    detailPanel:Hide()
    self:ClearDetailPanel()

    -- Expand paperdoll
    paperdoll:SetHeight(ARMORY_UI.PAPERDOLL_FULL_HEIGHT)

    -- Update container height
    self.armoryUI.container:SetHeight(ARMORY_UI.CONTAINER_MIN_HEIGHT)
end
```

### 9.3 Tier Change Animation

```lua
function Journal:AnimateTierChange(oldTier, newTier)
    -- Flash new tier button with tier color
    local btn = self.armoryUI.tierButtons[newTier]
    local color = TIER_COLORS[newTier]

    HopeAddon.Effects:ColorFlash(btn, color, 0.3)

    -- Refresh slot indicators with staggered animation
    local delay = 0
    for _, slotName in ipairs(ARMORY_SLOT_ORDER) do
        HopeAddon.Timer:After(delay, function()
            self:RefreshSlotIndicator(slotName)
        end)
        delay = delay + 0.02  -- 20ms stagger
    end
end
```

---

## 10. SavedVariables Structure

### 10.1 charDb.armory (Per-Character)

```lua
-- Add to CHAR_DATA_DEFAULTS in Core.lua
armory = {
    -- Selection preferences
    selectedTier = 4,                -- Last selected tier

    -- Wishlist - items player wants to acquire
    wishlist = {
        -- Format: [itemId] = { slot, addedDate, notes }
        [29011] = { slot = "head", addedDate = "2026-01-24", notes = "" },
        [28762] = { slot = "shoulders", addedDate = "2026-01-24", notes = "" },
    },

    -- UI preferences
    collapsedSections = {},          -- [sectionId] = true for collapsed
    showMinorUpgrades = true,        -- Show upgrades < 10 iLvl
    showCraftedGear = true,          -- Show BoE crafted options

    -- Model state (shared with Transmog if combined)
    lastRotation = 0,
},
```

### 10.2 Migration from Transmog

If combining Armory with Transmog:

```lua
function HopeAddon:MigrateToArmory()
    local charDb = self.charDb

    -- Create armory if doesn't exist
    if not charDb.armory then
        charDb.armory = CopyTable(CHAR_DATA_DEFAULTS.armory)
    end

    -- Migrate transmog rotation to shared
    if charDb.transmog and charDb.transmog.lastRotation then
        charDb.armory.lastRotation = charDb.transmog.lastRotation
    end

    -- Migrate dreamSet to wishlist format
    if charDb.transmog and charDb.transmog.dreamSet then
        for itemId, _ in pairs(charDb.transmog.dreamSet) do
            if not charDb.armory.wishlist[itemId] then
                local slotName = self:GetSlotForItem(itemId)
                charDb.armory.wishlist[itemId] = {
                    slot = slotName,
                    addedDate = date("%Y-%m-%d"),
                    notes = "Migrated from Dream Set",
                }
            end
        end
    end
end
```

---

## 11. Implementation Phases

### Phase 1: Container Structure (4 hours)

**Goal:** Basic armory tab with container hierarchy and slot button positions.

**Deliverables:**
- [ ] Add "armory" to tabData (or replace "transmog")
- [ ] Create `armoryUI` and `armoryState` tables
- [ ] Implement `CreateArmoryContainers()`
- [ ] Implement `CreateArmoryTierBar()` with 3 tier buttons
- [ ] Implement `CreateArmoryPaperdoll()` with model frame
- [ ] Position 17 slot button placeholders

**Validation:**
- Open Armory tab, see layout with model and 17 grey slot buttons
- Click tier buttons, see selection change

### Phase 2: Slot Button System (4 hours)

**Goal:** Functional slot buttons showing equipped items and upgrade indicators.

**Deliverables:**
- [ ] Implement `CreateArmorySlotButton()` with icon, border, indicator
- [ ] Implement `ScanEquippedItems()` to get player's current gear
- [ ] Implement `UpdateSlotButtonVisual()` for different states
- [ ] Add slot button click handlers
- [ ] Add hover tooltips showing equipped item

**Validation:**
- Slot buttons show equipped item icons
- Hover shows item tooltip
- Click selects slot (visual highlight)

### Phase 3: Detail Panel (6 hours)

**Goal:** Expandable detail panel with upgrade recommendations.

**Deliverables:**
- [ ] Create frame pools for upgrade cards and sections
- [ ] Implement `ExpandArmoryDetailPanel()` / `CollapseArmoryDetailPanel()`
- [ ] Implement `PopulateDetailPanel()` with sections
- [ ] Create upgrade card UI with rank, icon, stats, source
- [ ] Add wishlist toggle button functionality

**Validation:**
- Click slot to expand detail panel
- See "Currently Equipped" and upgrade recommendations
- Click heart to toggle wishlist
- Click X or slot again to collapse

### Phase 4: Data Integration (6 hours)

**Goal:** Populate with actual T4 gear data.

**Deliverables:**
- [ ] Add `C.ARMORY_GEAR_DATABASE` structure to Constants.lua
- [ ] Research and add T4 tank gear (17 slots × 3 items = 51 items)
- [ ] Research and add T4 healer gear (51 items)
- [ ] Research and add T4 DPS gear (51 items × 3 roles = 153 items)
- [ ] Implement spec detection integration

**Validation:**
- Select Protection Warrior, see tank recommendations
- Select Holy Priest, see healer recommendations
- Recommendations match actual TBC Classic BiS lists

### Phase 5: Polish & Animation (4 hours)

**Goal:** Visual polish and animations.

**Deliverables:**
- [ ] Add slot upgrade pulse animations
- [ ] Add tier change color flash
- [ ] Add detail panel slide animation
- [ ] Add sound effects (click, hover, wishlist)
- [ ] Add footer with gear score and upgrade count

**Validation:**
- Smooth animations on all interactions
- Audio feedback on clicks
- Footer shows accurate summary

### Phase 6: T5/T6 Data (4 hours)

**Goal:** Extend to T5 and T6 content.

**Deliverables:**
- [ ] Research and add T5 gear data (~255 items)
- [ ] Research and add T6 gear data (~255 items)
- [ ] Ensure tier switching updates recommendations

**Validation:**
- T5 tier shows SSC/TK items
- T6 tier shows Hyjal/BT/SWP items

---

## 12. Design Mockups

### 12.1 Overview Mode (No Slot Selected)

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  YOUR ARMORY                                                                   ║
╠═════════════════════════════════════════════════════════════════════════════  ║
║                                                                                ║
║  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          ┌──────────────┐  ║
║  │  ▓▓ T4 ▓▓  │  │     T5      │  │     T6      │          │  Protection  │  ║
║  │  Phase 1   │  │             │  │             │          │   Warrior ▼  │  ║
║  └─────────────┘  └─────────────┘  └─────────────┘          └──────────────┘  ║
║                                                                                ║
║  ┌────────────────────────────────────────────────────────────────────────┐   ║
║  │                                                                        │   ║
║  │  ┌──────┐                                               ┌──────┐      │   ║
║  │  │ HEAD │                                               │ NECK │      │   ║
║  │  │[icon]│                                               │[icon]│      │   ║
║  │  │ +15↑ │                                               │  OK  │      │   ║
║  │  └──────┘                                               └──────┘      │   ║
║  │                                                                        │   ║
║  │  ┌──────┐     ╔══════════════════════════════╗         ┌──────┐      │   ║
║  │  │ SHLD │     ║                              ║         │ BACK │      │   ║
║  │  │[icon]│     ║                              ║         │[icon]│      │   ║
║  │  │ +10↑ │     ║      [ CHARACTER MODEL ]     ║         │ +8↑  │      │   ║
║  │  └──────┘     ║                              ║         └──────┘      │   ║
║  │               ║                              ║                        │   ║
║  │  ┌──────┐     ║                              ║         ┌──────┐      │   ║
║  │  │ CHST │     ║                              ║         │WRIST │      │   ║
║  │  │[T4!★]│     ║                              ║         │[icon]│      │   ║
║  │  │ BiS  │     ╚══════════════════════════════╝         │  OK  │      │   ║
║  │  └──────┘                                               └──────┘      │   ║
║  │                                                                        │   ║
║  │  ┌──────┐                                               ┌──────┐      │   ║
║  │  │WAIST │                                               │HANDS │      │   ║
║  │  │[icon]│                                               │[icon]│      │   ║
║  │  │ +12↑ │                                               │ +5↑  │      │   ║
║  │  └──────┘                                               └──────┘      │   ║
║  │                                                                        │   ║
║  │  ┌──────┐                                               ┌──────┐      │   ║
║  │  │ LEGS │                                               │ FEET │      │   ║
║  │  │[icon]│                                               │[icon]│      │   ║
║  │  │ +20↑ │                                               │ BiS★ │      │   ║
║  │  └──────┘                                               └──────┘      │   ║
║  │                                                                        │   ║
║  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐  ┌────┐ ┌────┐ ┌────┐                    │   ║
║  │  │RNG1│ │RNG2│ │TRN1│ │TRN2│  │ MH │ │ OH │ │RNGD│                    │   ║
║  │  └────┘ └────┘ └────┘ └────┘  └────┘ └────┘ └────┘                    │   ║
║  │                                                                        │   ║
║  └────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
╠════════════════════════════════════════════════════════════════════════════   ║
║  Avg iLvl: 112 | Upgrades Available: 8 slots | Wishlisted: 3 items            ║
╚═══════════════════════════════════════════════════════════════════════════════╝

Legend:
  +N↑  = Upgrade available (+N iLvl improvement)
  BiS★ = Best in Slot equipped (gold star)
  T4!  = Tier token upgrade available (purple)
  OK   = Current item acceptable (green check)
```

### 12.2 Detail Mode (Slot Selected)

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  YOUR ARMORY                                                                   ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          ┌──────────────┐  ║
║  │  ▓▓ T4 ▓▓  │  │     T5      │  │     T6      │          │  Protection  │  ║
║  └─────────────┘  └─────────────┘  └─────────────┘          │   Warrior ▼  │  ║
║                                                              └──────────────┘  ║
║  ┌────────────────────────────────────────────────────────────────────────┐   ║
║  │  [HEAD]                      MODEL (compact)               [NECK]      │   ║
║  │  ┌────┐                      ┌──────────┐                 ┌────┐      │   ║
║  │  │****│◄─ SELECTED           │          │                 │    │      │   ║
║  │  └────┘                      │ [Player] │                 └────┘      │   ║
║  │  [SHLD][CHST][WAIST][LEGS]   └──────────┘    [BACK][WRIST][HANDS][FEET]│   ║
║  │  ┌──┐ ┌──┐ ┌──┐ ┌──┐                        ┌──┐ ┌──┐ ┌──┐ ┌──┐      │   ║
║  │  │  │ │  │ │  │ │  │                        │  │ │  │ │  │ │  │      │   ║
║  │  └──┘ └──┘ └──┘ └──┘                        └──┘ └──┘ └──┘ └──┘      │   ║
║  │  [RNG1][RNG2][TRN1][TRN2]    [MH][OH][RNGD]                           │   ║
║  └────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                ║
║  ╔══════════════════════════════════════════════════════════════════════════╗ ║
║  ║  HEAD SLOT UPGRADES                                               [✕]   ║ ║
║  ╠══════════════════════════════════════════════════════════════════════════╣ ║
║  ║                                                                          ║ ║
║  ║  CURRENTLY EQUIPPED                                                      ║ ║
║  ║  ┌───────────────────────────────────────────────────────────────────┐  ║ ║
║  ║  │  [Icon]  Helm of the Warp                                         │  ║ ║
║  ║  │          iLvl 105 | Quest Reward                                  │  ║ ║
║  ║  │          +28 Strength, +24 Stamina, +18 Defense Rating            │  ║ ║
║  ║  └───────────────────────────────────────────────────────────────────┘  ║ ║
║  ║                                                                          ║ ║
║  ║  ▼ T4 UPGRADES                                                           ║ ║
║  ║  ┌───────────────────────────────────────────────────────────────────┐  ║ ║
║  ║  │  ★ BEST                                                     [♡]  │  ║ ║
║  ║  │  [Icon]  Warbringer Greathelm                                     │  ║ ║
║  ║  │          iLvl 120 | Prince Malchezaar - Karazhan                  │  ║ ║
║  ║  │          +43 Str, +45 Sta, +32 Defense                            │  ║ ║
║  ║  │          ▲ +15 iLvl upgrade                                       │  ║ ║
║  ║  └───────────────────────────────────────────────────────────────────┘  ║ ║
║  ║  ┌───────────────────────────────────────────────────────────────────┐  ║ ║
║  ║  │  ALT                                                        [♡]  │  ║ ║
║  ║  │  [Icon]  Eternium Greathelm                                       │  ║ ║
║  ║  │          iLvl 115 | Heroic Mechanar                               │  ║ ║
║  ║  │          +38 Str, +40 Sta, +28 Defense                            │  ║ ║
║  ║  │          ▲ +10 iLvl upgrade                                       │  ║ ║
║  ║  └───────────────────────────────────────────────────────────────────┘  ║ ║
║  ║                                                                          ║ ║
║  ║  ► BADGE OF JUSTICE (collapsed)                                          ║ ║
║  ║  ► CRAFTED GEAR (collapsed)                                              ║ ║
║  ║                                                                          ║ ║
║  ╚══════════════════════════════════════════════════════════════════════════╝ ║
║                                                                                ║
╠════════════════════════════════════════════════════════════════════════════   ║
║  Avg iLvl: 112 | Upgrades Available: 8 slots | Wishlisted: 3 items            ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 13. Questions for Design Approval

Before implementation, please confirm:

1. **Tab Strategy:** Replace Transmog or add as separate tab?
   - Recommended: Replace (combined Armory with appearance preview mode)

2. **Initial Scope:** T4 only for MVP, or all tiers?
   - Recommended: T4 first, T5/T6 in Phase 6

3. **Data Source:** Should I research actual TBC BiS items, or use placeholder data?
   - Recommended: Actual item IDs from Wowhead TBC Classic

4. **Wishlist Integration:** Merge with existing Transmog dreamSet, or separate wishlist?
   - Recommended: Migrate dreamSet to new unified wishlist format

5. **Model Sharing:** Reuse existing Transmog DressUpModel code?
   - Recommended: Yes, extract to shared utility

---

## 14. File Changes Summary

| File | Changes | Lines Est. |
|------|---------|------------|
| `Journal/Journal.lua` | Add armory tab functions, replace/modify transmog | ~800 |
| `Core/Constants.lua` | Add `C.ARMORY_GEAR_DATABASE`, slot positions | ~600 |
| `Core/Core.lua` | Add `charDb.armory` defaults, migration | ~50 |
| `HopeAddon.toc` | No changes (or minor ordering) | ~2 |

**Total Estimated:** ~1,450 lines

---

## 15. Success Criteria

- [ ] All 17 equipment slots visible in paperdoll layout
- [ ] Click any slot to see upgrade recommendations
- [ ] Tier selector filters recommendations by T4/T5/T6
- [ ] Spec dropdown changes role-based recommendations
- [ ] Wishlist items persist across sessions
- [ ] Smooth animations on all interactions
- [ ] Footer shows accurate upgrade summary
- [ ] Works on all 9 TBC classes with all specs

---

# PART 2: DETAILED UI SPECIFICATIONS

---

## 16. Equipment Slot UI Deep Dive

### 16.1 Slot Button Anatomy (Detailed)

Each slot button is a complex composite of multiple visual layers:

```
┌─────────────────────────────────────────────────────────────────┐
│  SLOT BUTTON FRAME (44x44 pixels)                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Layer 1: BACKGROUND (dark charcoal base)                 │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Layer 2: SLOT ICON PLACEHOLDER                     │  │  │
│  │  │  (when empty: ghost outline of slot type)           │  │  │
│  │  │  ┌─────────────────────────────────────────────┐    │  │  │
│  │  │  │  Layer 3: ITEM ICON (36x36)                 │    │  │  │
│  │  │  │  (equipped item texture)                    │    │  │  │
│  │  │  │  ┌─────────────────────────────────────┐    │    │  │  │
│  │  │  │  │  Layer 4: QUALITY BORDER             │    │    │  │  │
│  │  │  │  │  (colored by item quality)           │    │    │  │  │
│  │  │  │  │  ┌─────────────────────────────┐     │    │    │  │  │
│  │  │  │  │  │ Layer 5: UPGRADE INDICATOR  │     │    │    │  │  │
│  │  │  │  │  │ (corner badge with symbol)  │     │    │    │  │  │
│  │  │  │  │  └─────────────────────────────┘     │    │    │  │  │
│  │  │  │  └─────────────────────────────────────┘    │    │  │  │
│  │  │  └─────────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                                                           │  │
│  │  Layer 6: SLOT LABEL (FontString below icon)              │  │
│  │  "HEAD" / "CHEST" / etc.                                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Layer 7: GLOW OVERLAY (for selection/upgrade pulse)            │
│  Layer 8: HIGHLIGHT (mouseover)                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 16.2 Slot Button Constants

```lua
-- Add to Constants.lua
C.ARMORY_SLOT_UI = {
    -- Dimensions
    BUTTON_SIZE = 44,               -- Overall slot button size
    ICON_SIZE = 36,                 -- Item icon size
    ICON_INSET = 4,                 -- (44-36)/2 = 4px border
    INDICATOR_SIZE = 16,            -- Upgrade indicator badge size
    INDICATOR_OFFSET = { x = 2, y = -2 },  -- Corner offset from top-right
    LABEL_HEIGHT = 12,              -- Slot label font height
    LABEL_OFFSET = -4,              -- Gap between icon and label

    -- Colors for slot states (TBC palette)
    STATE_COLORS = {
        empty     = { border = "GREY",          indicator = nil },
        equipped  = { border = "ITEM_QUALITY",  indicator = nil },  -- Use item quality
        bis       = { border = "GOLD_BRIGHT",   indicator = "GOLD_BRIGHT" },
        ok        = { border = "FEL_GREEN",     indicator = "FEL_GREEN" },
        minor     = { border = "FEL_GREEN",     indicator = "FEL_GREEN" },
        upgrade   = { border = "GOLD_BRIGHT",   indicator = "GOLD_BRIGHT" },
        major     = { border = "HELLFIRE_RED",  indicator = "HELLFIRE_RED" },
        selected  = { border = "ARCANE_PURPLE", indicator = nil },
        wishlisted = { border = "EPIC_PURPLE",  indicator = "EPIC_PURPLE" },
    },

    -- Indicator symbols (WoW icon textures or custom)
    INDICATOR_ICONS = {
        bis       = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "★" },
        ok        = { icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready", symbol = "✓" },
        minor     = { icon = "Interface\\BUTTONS\\UI-MicroStream-Green", symbol = "↑" },
        upgrade   = { icon = "Interface\\BUTTONS\\UI-MicroStream-Yellow", symbol = "↑↑" },
        major     = { icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew", symbol = "!!" },
        wishlisted = { icon = "Interface\\BUTTONS\\UI-GroupLoot-Coin-Up", symbol = "♥" },
        tier      = { icon = "Interface\\ICONS\\INV_Misc_Token_SoulTrader", symbol = "T" },
    },
}

-- WoW Inventory Slot IDs (TBC)
C.INVENTORY_SLOT_IDS = {
    head      = 1,   -- INVSLOT_HEAD
    neck      = 2,   -- INVSLOT_NECK
    shoulders = 3,   -- INVSLOT_SHOULDER
    back      = 15,  -- INVSLOT_BACK
    chest     = 5,   -- INVSLOT_CHEST
    shirt     = 4,   -- INVSLOT_BODY (not used in armory)
    tabard    = 19,  -- INVSLOT_TABARD (not used in armory)
    wrist     = 9,   -- INVSLOT_WRIST
    hands     = 10,  -- INVSLOT_HAND
    waist     = 6,   -- INVSLOT_WAIST
    legs      = 7,   -- INVSLOT_LEGS
    feet      = 8,   -- INVSLOT_FEET
    ring1     = 11,  -- INVSLOT_FINGER1
    ring2     = 12,  -- INVSLOT_FINGER2
    trinket1  = 13,  -- INVSLOT_TRINKET1
    trinket2  = 14,  -- INVSLOT_TRINKET2
    mainhand  = 16,  -- INVSLOT_MAINHAND
    offhand   = 17,  -- INVSLOT_OFFHAND
    ranged    = 18,  -- INVSLOT_RANGED
}

-- Slot placeholder icons (when empty)
C.ARMORY_SLOT_PLACEHOLDER_ICONS = {
    head      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head",
    neck      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck",
    shoulders = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder",
    back      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",  -- No specific back
    chest     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
    wrist     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists",
    hands     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands",
    waist     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist",
    legs      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs",
    feet      = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet",
    ring1     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
    ring2     = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
    trinket1  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
    trinket2  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
    mainhand  = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand",
    offhand   = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand",
    ranged    = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged",
}
```

### 16.3 Slot Button Creation (Detailed)

```lua
function Journal:CreateArmorySlotButton(slotName, parent)
    local C = HopeAddon.Constants
    local UI = C.ARMORY_SLOT_UI
    local pos = C.ARMORY_SLOT_POSITIONS[slotName]

    -- Main button frame
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(UI.BUTTON_SIZE, UI.BUTTON_SIZE + UI.LABEL_HEIGHT + math.abs(UI.LABEL_OFFSET))

    -- Position based on anchor type
    if pos.anchor == "TOPLEFT" then
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", pos.x, pos.y)
    elseif pos.anchor == "TOPRIGHT" then
        btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", pos.x, pos.y)
    elseif pos.anchor == "BOTTOM" then
        btn:SetPoint("BOTTOM", parent, "BOTTOM", pos.x, pos.y)
    end

    -- Background (dark charcoal)
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)  -- Grey default

    -- Icon frame (contains icon + quality border)
    local iconFrame = CreateFrame("Frame", nil, btn)
    iconFrame:SetSize(UI.ICON_SIZE, UI.ICON_SIZE)
    iconFrame:SetPoint("TOP", btn, "TOP", 0, -UI.ICON_INSET)
    btn.iconFrame = iconFrame

    -- Slot placeholder texture (shown when empty)
    local placeholder = iconFrame:CreateTexture(nil, "BACKGROUND")
    placeholder:SetAllPoints()
    placeholder:SetTexture(C.ARMORY_SLOT_PLACEHOLDER_ICONS[slotName])
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(0.3)
    btn.placeholder = placeholder

    -- Item icon texture
    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:Hide()  -- Hidden until item equipped
    btn.icon = icon

    -- Quality border (colored by item quality)
    local qualityBorder = iconFrame:CreateTexture(nil, "OVERLAY")
    qualityBorder:SetPoint("TOPLEFT", -2, 2)
    qualityBorder:SetPoint("BOTTOMRIGHT", 2, -2)
    qualityBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    qualityBorder:Hide()
    btn.qualityBorder = qualityBorder

    -- Upgrade indicator (corner badge)
    local indicator = CreateFrame("Frame", nil, btn)
    indicator:SetSize(UI.INDICATOR_SIZE, UI.INDICATOR_SIZE)
    indicator:SetPoint("TOPRIGHT", iconFrame, "TOPRIGHT",
        UI.INDICATOR_OFFSET.x, UI.INDICATOR_OFFSET.y)
    indicator:SetFrameLevel(btn:GetFrameLevel() + 5)
    indicator:Hide()
    btn.indicator = indicator

    -- Indicator background
    local indBg = indicator:CreateTexture(nil, "BACKGROUND")
    indBg:SetAllPoints()
    indBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    indBg:SetVertexColor(0, 0, 0, 0.8)
    indicator.bg = indBg

    -- Indicator icon
    local indIcon = indicator:CreateTexture(nil, "ARTWORK")
    indIcon:SetSize(UI.INDICATOR_SIZE - 4, UI.INDICATOR_SIZE - 4)
    indIcon:SetPoint("CENTER")
    indicator.icon = indIcon

    -- Indicator text (alternative to icon)
    local indText = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    indText:SetPoint("CENTER")
    indText:SetTextColor(1, 1, 1, 1)
    indicator.text = indText

    -- Slot label below icon
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", iconFrame, "BOTTOM", 0, UI.LABEL_OFFSET)
    label:SetText(slotName:upper():sub(1, 4))  -- "HEAD", "CHST", etc.
    label:SetTextColor(0.8, 0.8, 0.8, 1)
    btn.label = label

    -- Glow overlay (for selection/upgrade animation)
    local glow = btn:CreateTexture(nil, "OVERLAY", nil, 7)
    glow:SetPoint("TOPLEFT", -8, 8)
    glow:SetPoint("BOTTOMRIGHT", 8, -8)
    glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
    glow:SetBlendMode("ADD")
    glow:SetAlpha(0)
    btn.glow = glow

    -- Highlight overlay (mouseover)
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(iconFrame)
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")
    btn.highlight = highlight

    -- Data storage
    btn.slotName = slotName
    btn.slotId = C.INVENTORY_SLOT_IDS[slotName]
    btn.equippedItem = nil
    btn.upgradeStatus = "empty"
    btn.isSelected = false
    btn.isWishlisted = false

    -- Event handlers
    btn:SetScript("OnClick", function()
        self:OnArmorySlotClick(slotName)
    end)

    btn:SetScript("OnEnter", function()
        self:OnArmorySlotEnter(btn)
    end)

    btn:SetScript("OnLeave", function()
        self:OnArmorySlotLeave(btn)
    end)

    return btn
end
```

### 16.4 Slot Button Visual Update

```lua
function Journal:UpdateArmorySlotVisual(slotButton)
    local C = HopeAddon.Constants
    local UI = C.ARMORY_SLOT_UI
    local status = slotButton.upgradeStatus
    local stateConfig = UI.STATE_COLORS[status] or UI.STATE_COLORS.empty
    local indicatorConfig = UI.INDICATOR_ICONS[status]

    -- Update icon
    if slotButton.equippedItem then
        slotButton.icon:SetTexture(slotButton.equippedItem.icon)
        slotButton.icon:Show()
        slotButton.placeholder:Hide()

        -- Quality border color
        local quality = slotButton.equippedItem.quality
        local r, g, b = GetItemQualityColor(quality)
        slotButton.qualityBorder:SetVertexColor(r, g, b, 1)
        slotButton.qualityBorder:Show()
    else
        slotButton.icon:Hide()
        slotButton.placeholder:Show()
        slotButton.qualityBorder:Hide()
    end

    -- Update border color based on state
    local borderColor
    if stateConfig.border == "ITEM_QUALITY" and slotButton.equippedItem then
        local r, g, b = GetItemQualityColor(slotButton.equippedItem.quality)
        borderColor = { r = r, g = g, b = b }
    else
        borderColor = HopeAddon.colors[stateConfig.border] or HopeAddon.colors.GREY
    end
    slotButton:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

    -- Update indicator
    if indicatorConfig then
        slotButton.indicator:Show()

        -- Set indicator icon and color
        local indicatorColor = HopeAddon.colors[stateConfig.indicator]
        if indicatorColor then
            slotButton.indicator.bg:SetVertexColor(
                indicatorColor.r * 0.3,
                indicatorColor.g * 0.3,
                indicatorColor.b * 0.3,
                0.9
            )
            slotButton.indicator.icon:SetTexture(indicatorConfig.icon)
            slotButton.indicator.icon:SetVertexColor(
                indicatorColor.r,
                indicatorColor.g,
                indicatorColor.b,
                1
            )
        end

        -- Show upgrade amount for upgrade states
        if status == "minor" or status == "upgrade" or status == "major" then
            local iLvlDiff = self.armoryState.slotStatuses[slotButton.slotName].iLvlDiff
            slotButton.indicator.text:SetText("+" .. iLvlDiff)
            slotButton.indicator.icon:Hide()
        else
            slotButton.indicator.text:SetText("")
            slotButton.indicator.icon:Show()
        end
    else
        slotButton.indicator:Hide()
    end

    -- Update selection state
    if slotButton.isSelected then
        slotButton.glow:SetAlpha(0.7)
        slotButton.glow:SetVertexColor(0.8, 0.6, 0, 1)  -- Gold glow
    else
        slotButton.glow:SetAlpha(0)
    end

    -- Start/stop upgrade pulse animation
    if status == "upgrade" or status == "major" then
        self:StartUpgradePulse(slotButton)
    else
        self:StopUpgradePulse(slotButton)
    end
end
```

---

## 17. Tab Organization & Margins System

### 17.1 Global Margin Constants

```lua
-- Add to Constants.lua
C.ARMORY_MARGINS = {
    -- Container margins
    CONTAINER_PADDING = 15,          -- Padding inside main container
    SECTION_SPACING = 20,            -- Space between major sections
    SUBSECTION_SPACING = 12,         -- Space between sub-sections

    -- Component margins
    COMPONENT_GAP_SM = 4,            -- Small gap between related items
    COMPONENT_GAP_MD = 8,            -- Medium gap
    COMPONENT_GAP_LG = 16,           -- Large gap

    -- Card margins
    CARD_PADDING = 12,               -- Padding inside cards
    CARD_MARGIN = 8,                 -- Space between cards
    CARD_BORDER = 2,                 -- Border thickness

    -- Header margins
    HEADER_MARGIN_TOP = 16,          -- Space above headers
    HEADER_MARGIN_BOTTOM = 8,        -- Space below headers

    -- Button margins
    BUTTON_PADDING_H = 12,           -- Horizontal padding in buttons
    BUTTON_PADDING_V = 6,            -- Vertical padding in buttons
    BUTTON_SPACING = 8,              -- Space between buttons

    -- Tier bar margins
    TIER_BAR_PADDING = 10,           -- Padding in tier bar
    TIER_BUTTON_GAP = 12,            -- Gap between tier buttons

    -- Detail panel margins
    DETAIL_HEADER_HEIGHT = 40,       -- Height of detail panel header
    DETAIL_CONTENT_PADDING = 15,     -- Padding inside detail content area
    DETAIL_SCROLL_WIDTH = 16,        -- Scroll bar width

    -- Footer margins
    FOOTER_PADDING = 10,             -- Padding in footer bar
}
```

### 17.2 Tab Bar Design System

The Armory uses a horizontal tab bar with tier selection and spec dropdown:

```lua
-- Tab bar structure
C.ARMORY_TAB_BAR = {
    HEIGHT = 50,
    BACKGROUND_COLOR = { r = 0.08, g = 0.08, b = 0.08, a = 0.95 },
    BORDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },

    -- Tier tabs
    TIER_SECTION = {
        WIDTH = 340,  -- Total width for 3 tier buttons + gaps
        ALIGN = "LEFT",
    },

    -- Spec dropdown
    SPEC_SECTION = {
        WIDTH = 150,
        ALIGN = "RIGHT",
    },
}

-- Tier button design
C.ARMORY_TIER_BUTTON = {
    WIDTH = 100,
    HEIGHT = 36,
    FONT = "GameFontNormal",
    FONT_SIZE = 12,

    -- Visual states
    STATES = {
        active = {
            bgAlpha = 0.4,
            borderSize = 2,
            textColor = { r = 1, g = 1, b = 1, a = 1 },
            underline = true,
            underlineHeight = 3,
        },
        inactive = {
            bgAlpha = 0.1,
            borderSize = 1,
            textColor = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
            underline = false,
        },
        hover = {
            bgAlpha = 0.25,
            borderSize = 1,
            textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 },
            underline = true,
            underlineHeight = 1,
        },
    },
}
```

### 17.3 Tab Bar Creation

```lua
function Journal:CreateArmoryTierBar()
    local C = HopeAddon.Constants
    local M = C.ARMORY_MARGINS
    local TB = C.ARMORY_TAB_BAR
    local BTN = C.ARMORY_TIER_BUTTON

    local tierBar = self.armoryUI.tierBar

    -- Background
    tierBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    tierBar:SetBackdropColor(
        TB.BACKGROUND_COLOR.r,
        TB.BACKGROUND_COLOR.g,
        TB.BACKGROUND_COLOR.b,
        TB.BACKGROUND_COLOR.a
    )

    -- Tier buttons container (left side)
    local tierContainer = CreateFrame("Frame", nil, tierBar)
    tierContainer:SetSize(TB.TIER_SECTION.WIDTH, TB.HEIGHT - M.TIER_BAR_PADDING * 2)
    tierContainer:SetPoint("LEFT", tierBar, "LEFT", M.TIER_BAR_PADDING, 0)

    -- Create 3 tier buttons
    local tierData = {
        { tier = 4, label = "T4", sublabel = "Phase 1", color = "FEL_GREEN" },
        { tier = 5, label = "T5", sublabel = "Phase 2", color = "SKY_BLUE" },
        { tier = 6, label = "T6", sublabel = "Phase 3", color = "HELLFIRE_RED" },
    }

    for i, data in ipairs(tierData) do
        local btn = self:CreateArmoryTierButton(tierContainer, data)
        btn:SetPoint("LEFT", tierContainer, "LEFT", (i - 1) * (BTN.WIDTH + M.TIER_BUTTON_GAP), 0)
        self.armoryUI.tierButtons[data.tier] = btn
    end

    -- Spec dropdown (right side)
    local specDropdown = CreateFrame("Frame", "HopeArmorySpecDropdown", tierBar, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("RIGHT", tierBar, "RIGHT", -M.TIER_BAR_PADDING, 0)
    UIDropDownMenu_SetWidth(specDropdown, TB.SPEC_SECTION.WIDTH - 40)
    UIDropDownMenu_Initialize(specDropdown, function(frame, level)
        self:InitializeArmorySpecDropdown(frame, level)
    end)
    self.armoryUI.specDropdown = specDropdown

    -- Set initial spec text
    local specName = HopeAddon:GetPlayerSpec()
    UIDropDownMenu_SetText(specDropdown, specName or "Select Spec")
end

function Journal:CreateArmoryTierButton(parent, data)
    local C = HopeAddon.Constants
    local BTN = C.ARMORY_TIER_BUTTON
    local tierColor = HopeAddon.colors[data.color]

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(BTN.WIDTH, BTN.HEIGHT)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    -- Main label (T4, T5, T6)
    local mainLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainLabel:SetPoint("TOP", btn, "TOP", 0, -5)
    mainLabel:SetText(data.label)
    btn.mainLabel = mainLabel

    -- Sub label (Phase 1, Phase 2, Phase 3)
    local subLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subLabel:SetPoint("TOP", mainLabel, "BOTTOM", 0, -2)
    subLabel:SetText(data.sublabel)
    subLabel:SetTextColor(0.7, 0.7, 0.7, 1)
    btn.subLabel = subLabel

    -- Underline (active indicator)
    local underline = btn:CreateTexture(nil, "OVERLAY")
    underline:SetHeight(BTN.STATES.active.underlineHeight)
    underline:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2, 2)
    underline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
    underline:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    underline:SetVertexColor(tierColor.r, tierColor.g, tierColor.b, 1)
    underline:Hide()
    btn.underline = underline

    -- Store tier data
    btn.tier = data.tier
    btn.tierColor = tierColor

    -- Click handler
    btn:SetScript("OnClick", function()
        self:SelectArmoryTier(data.tier)
        HopeAddon.Sounds:PlayClick()
    end)

    -- Hover handlers
    btn:SetScript("OnEnter", function()
        if self.armoryState.selectedTier ~= data.tier then
            self:SetTierButtonState(btn, "hover")
        end
        HopeAddon.Sounds:PlayHover()
    end)

    btn:SetScript("OnLeave", function()
        if self.armoryState.selectedTier ~= data.tier then
            self:SetTierButtonState(btn, "inactive")
        end
    end)

    -- Set initial state
    self:SetTierButtonState(btn, "inactive")

    return btn
end

function Journal:SetTierButtonState(btn, state)
    local C = HopeAddon.Constants
    local BTN = C.ARMORY_TIER_BUTTON
    local config = BTN.STATES[state]
    local tierColor = btn.tierColor

    -- Background
    btn:SetBackdropColor(
        tierColor.r * 0.3,
        tierColor.g * 0.3,
        tierColor.b * 0.3,
        config.bgAlpha
    )

    -- Border
    btn:SetBackdropBorderColor(
        tierColor.r,
        tierColor.g,
        tierColor.b,
        state == "inactive" and 0.3 or 0.8
    )

    -- Text color
    btn.mainLabel:SetTextColor(
        config.textColor.r,
        config.textColor.g,
        config.textColor.b,
        config.textColor.a
    )

    -- Underline
    if config.underline then
        btn.underline:SetHeight(config.underlineHeight)
        btn.underline:Show()
    else
        btn.underline:Hide()
    end
end
```

---

## 18. Colorful Upgrade Symbols System

### 18.1 Upgrade Symbol Constants

```lua
-- Add to Constants.lua
C.ARMORY_UPGRADE_SYMBOLS = {
    -- Symbol definitions with colors and animations
    SYMBOLS = {
        -- Best in Slot (achieved)
        BIS = {
            symbol = "★",
            icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready",
            color = "GOLD_BRIGHT",
            glow = true,
            glowColor = "GOLD_BRIGHT",
            glowIntensity = 0.5,
            tooltip = "Best in Slot!",
        },

        -- Good enough (no upgrade needed)
        OK = {
            symbol = "✓",
            icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready",
            color = "FEL_GREEN",
            glow = false,
            tooltip = "Good item, minor upgrades only",
        },

        -- Minor upgrade available (+1-9 iLvl)
        MINOR_UPGRADE = {
            symbol = "↑",
            icon = "Interface\\BUTTONS\\UI-MicroStream-Green",
            color = "FEL_GREEN",
            glow = false,
            tooltip = "Minor upgrade available",
            showDiff = true,
        },

        -- Standard upgrade available (+10-19 iLvl)
        UPGRADE = {
            symbol = "▲",
            icon = "Interface\\BUTTONS\\UI-MicroStream-Yellow",
            color = "GOLD_BRIGHT",
            glow = true,
            glowColor = "GOLD_BRIGHT",
            glowIntensity = 0.3,
            pulse = true,
            tooltip = "Upgrade available!",
            showDiff = true,
        },

        -- Major upgrade available (+20+ iLvl)
        MAJOR_UPGRADE = {
            symbol = "⬆⬆",
            icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
            color = "HELLFIRE_RED",
            glow = true,
            glowColor = "HELLFIRE_RED",
            glowIntensity = 0.6,
            pulse = true,
            pulseSpeed = 1.0,
            tooltip = "MAJOR upgrade needed!",
            showDiff = true,
        },

        -- Tier token available
        TIER_TOKEN = {
            symbol = "T",
            icon = "Interface\\ICONS\\INV_Misc_Token_SoulTrader",
            color = "EPIC_PURPLE",
            glow = true,
            glowColor = "ARCANE_PURPLE",
            glowIntensity = 0.4,
            tooltip = "Tier token upgrade",
        },

        -- Wishlisted item
        WISHLIST = {
            symbol = "♥",
            icon = "Interface\\ICONS\\INV_ValentinesCard02",
            color = "EPIC_PURPLE",
            glow = false,
            tooltip = "On your wishlist",
        },

        -- Badge of Justice item
        BADGE = {
            symbol = "●",
            icon = "Interface\\ICONS\\Spell_Holy_ChampionsBond",
            color = "GOLD_BRIGHT",
            glow = false,
            tooltip = "Badge of Justice reward",
        },

        -- Heroic dungeon item
        HEROIC = {
            symbol = "H",
            icon = "Interface\\ICONS\\Spell_Holy_SealOfBlood",
            color = "RARE_BLUE",
            glow = false,
            tooltip = "Heroic dungeon drop",
        },

        -- Reputation reward
        REP = {
            symbol = "☆",
            icon = "Interface\\ICONS\\INV_Misc_Token_argentdawn",
            color = "FEL_GREEN",
            glow = false,
            tooltip = "Reputation reward",
        },

        -- Crafted item
        CRAFTED = {
            symbol = "⚒",
            icon = "Interface\\ICONS\\Trade_BlackSmithing",
            color = "BRONZE",
            glow = false,
            tooltip = "Crafted item",
        },
    },

    -- Priority order for showing symbols (first match wins in slot indicator)
    PRIORITY = {
        "MAJOR_UPGRADE",
        "TIER_TOKEN",
        "UPGRADE",
        "MINOR_UPGRADE",
        "WISHLIST",
        "BIS",
        "OK",
    },
}
```

### 18.2 Symbol Rendering

```lua
function Journal:CreateUpgradeSymbol(parent, symbolType, size)
    local C = HopeAddon.Constants
    local symbolDef = C.ARMORY_UPGRADE_SYMBOLS.SYMBOLS[symbolType]
    if not symbolDef then return nil end

    size = size or 16
    local color = HopeAddon.colors[symbolDef.color]

    -- Container frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)

    -- Background (slightly darker than symbol color)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    bg:SetVertexColor(color.r * 0.2, color.g * 0.2, color.b * 0.2, 0.9)
    frame.bg = bg

    -- Symbol icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(size - 4, size - 4)
    icon:SetPoint("CENTER")
    icon:SetTexture(symbolDef.icon)
    icon:SetVertexColor(color.r, color.g, color.b, 1)
    frame.icon = icon

    -- Text overlay (for symbols like "+15")
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER")
    text:SetTextColor(color.r, color.g, color.b, 1)
    text:Hide()
    frame.text = text

    -- Glow effect (if enabled)
    if symbolDef.glow then
        local glowColor = HopeAddon.colors[symbolDef.glowColor] or color
        local glow = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
        glow:SetPoint("TOPLEFT", -4, 4)
        glow:SetPoint("BOTTOMRIGHT", 4, -4)
        glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
        glow:SetBlendMode("ADD")
        glow:SetVertexColor(glowColor.r, glowColor.g, glowColor.b, symbolDef.glowIntensity)
        frame.glow = glow

        -- Pulse animation
        if symbolDef.pulse then
            local pulseSpeed = symbolDef.pulseSpeed or 1.5
            frame.pulseAnim = HopeAddon.Animations:CreatePulse(glow, {
                minAlpha = symbolDef.glowIntensity * 0.5,
                maxAlpha = symbolDef.glowIntensity,
                duration = pulseSpeed,
                loop = true,
            })
            frame.pulseAnim:Play()
        end
    end

    -- Tooltip
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(symbolDef.tooltip, color.r, color.g, color.b)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Store metadata
    frame.symbolType = symbolType
    frame.symbolDef = symbolDef

    return frame
end

function Journal:UpdateUpgradeSymbol(symbolFrame, iLvlDiff)
    local symbolDef = symbolFrame.symbolDef
    if not symbolDef then return end

    -- Show iLvl difference if applicable
    if symbolDef.showDiff and iLvlDiff and iLvlDiff > 0 then
        symbolFrame.icon:Hide()
        symbolFrame.text:SetText("+" .. iLvlDiff)
        symbolFrame.text:Show()
    else
        symbolFrame.icon:Show()
        symbolFrame.text:Hide()
    end
end
```

---

## 19. WoW Asset Utilization Guide

### 19.1 Approved WoW Textures

```lua
-- Add to Constants.lua
C.ARMORY_ASSETS = {
    -- Backgrounds (scalable/tileable)
    BACKGROUNDS = {
        DARK_PANEL = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        LIGHT_PANEL = "Interface\\DialogFrame\\UI-DialogBox-Background",
        TOOLTIP = "Interface\\Tooltips\\UI-Tooltip-Background",
        PARCHMENT = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment-Horizontal",
    },

    -- Borders
    BORDERS = {
        TOOLTIP = "Interface\\Tooltips\\UI-Tooltip-Border",
        DIALOG = "Interface\\DialogFrame\\UI-DialogBox-Border",
        GOLD = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        ACHIEVEMENT = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-WoodBorder",
    },

    -- Icons for upgrade indicators
    UPGRADE_ICONS = {
        ARROW_UP_GREEN = "Interface\\BUTTONS\\UI-MicroStream-Green",
        ARROW_UP_YELLOW = "Interface\\BUTTONS\\UI-MicroStream-Yellow",
        ARROW_UP_RED = "Interface\\BUTTONS\\UI-MicroStream-Red",
        CHECKMARK = "Interface\\RAIDFRAME\\ReadyCheck-Ready",
        ALERT = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
        STAR = "Interface\\COMMON\\ReputationStar03",
        STAR_FULL = "Interface\\COMMON\\ReputationStar04",
    },

    -- Glow effects
    GLOWS = {
        ACTION_BUTTON = "Interface\\BUTTONS\\UI-ActionButton-Border",
        CHECKBOX = "Interface\\BUTTONS\\CheckButtonGlow",
        SOFT = "Interface\\BUTTONS\\WHITE8X8",
    },

    -- Slot placeholder icons (standard WoW paperdoll)
    SLOT_PLACEHOLDERS = {
        head = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head",
        neck = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck",
        shoulder = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder",
        chest = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
        waist = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist",
        legs = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs",
        feet = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet",
        wrist = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists",
        hands = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands",
        finger = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
        trinket = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
        mainhand = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand",
        offhand = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand",
        ranged = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged",
    },

    -- Quality border frames
    QUALITY_BORDERS = {
        COMMON = "Interface\\Common\\WhiteIconFrame",
        UNCOMMON = "Interface\\Common\\WhiteIconFrame",
        RARE = "Interface\\Common\\WhiteIconFrame",
        EPIC = "Interface\\Common\\WhiteIconFrame",
        LEGENDARY = "Interface\\Common\\WhiteIconFrame",
    },

    -- Rank badges
    RANK_BADGES = {
        BEST = "Interface\\ICONS\\Ability_Creature_Disease_03",  -- Gold star-like
        ALT = "Interface\\ICONS\\Ability_ThunderBolt",  -- Lightning bolt
    },

    -- Source type icons
    SOURCE_ICONS = {
        raid = "Interface\\ICONS\\INV_Misc_Head_Dragon_01",
        heroic = "Interface\\ICONS\\Spell_Holy_SealOfBlood",
        badge = "Interface\\ICONS\\Spell_Holy_ChampionsBond",
        rep = "Interface\\ICONS\\INV_Misc_Token_argentdawn",
        crafted = "Interface\\ICONS\\Trade_BlackSmithing",
    },
}
```

### 19.2 Asset Usage Guidelines

```lua
--[[
    ARMORY ASSET USAGE GUIDELINES

    1. BACKGROUNDS
       - Use DARK_PANEL for main containers and popups
       - Use TOOLTIP for inner panels and cards
       - Use PARCHMENT sparingly for special sections

    2. BORDERS
       - Use TOOLTIP for most borders (12px edge size)
       - Use GOLD for highlighted/selected items
       - Border color set via SetBackdropBorderColor()

    3. ICONS
       - Always use WoW assets when available
       - Cache icon textures, don't create duplicate textures
       - Use SetVertexColor for TBC-themed coloring

    4. GLOWS
       - ACTION_BUTTON for selection/highlight glows
       - Set blend mode to "ADD" for proper glow effect
       - Keep intensity subtle (0.3-0.7 alpha)

    5. SCALING
       - All textures should use SetAllPoints() or explicit sizes
       - Avoid stretching non-tileable textures
       - Test at different UI scales (0.64, 1.0, 1.4)

    6. PERFORMANCE
       - Reuse textures via frame pooling
       - Hide unused textures, don't destroy
       - Limit animated glows to visible elements only
]]
```

---

## 20. Comprehensive Frame Pool System

### 20.1 Pool Definitions

```lua
-- Add to Journal.lua armory section
Journal.armoryPools = {
    -- Pool for upgrade cards in detail panel
    upgradeCard = nil,

    -- Pool for section headers
    sectionHeader = nil,

    -- Pool for stat comparison rows
    statRow = nil,

    -- Pool for source tag badges
    sourceTag = nil,

    -- Pool for wishlist buttons
    wishlistBtn = nil,
}
```

### 20.2 Pool Creation

```lua
function Journal:CreateArmoryPools()
    local detailContent = self.armoryUI.detailPanel.content

    -- Upgrade Card Pool
    self.armoryPools.upgradeCard = HopeAddon.FramePool:Create(
        "Button",
        detailContent,
        "BackdropTemplate",
        function(card)
            self:InitializeUpgradeCard(card)
        end,
        function(card)
            self:ResetUpgradeCard(card)
        end
    )

    -- Section Header Pool
    self.armoryPools.sectionHeader = HopeAddon.FramePool:Create(
        "Frame",
        detailContent,
        "BackdropTemplate",
        function(header)
            self:InitializeSectionHeader(header)
        end,
        function(header)
            self:ResetSectionHeader(header)
        end
    )

    -- Stat Row Pool
    self.armoryPools.statRow = HopeAddon.FramePool:Create(
        "Frame",
        nil,  -- Parent set on acquire
        nil,
        function(row)
            self:InitializeStatRow(row)
        end,
        function(row)
            self:ResetStatRow(row)
        end
    )

    -- Source Tag Pool
    self.armoryPools.sourceTag = HopeAddon.FramePool:Create(
        "Frame",
        nil,
        nil,
        function(tag)
            self:InitializeSourceTag(tag)
        end,
        function(tag)
            self:ResetSourceTag(tag)
        end
    )

    -- Wishlist Button Pool
    self.armoryPools.wishlistBtn = HopeAddon.FramePool:Create(
        "Button",
        nil,
        nil,
        function(btn)
            self:InitializeWishlistButton(btn)
        end,
        function(btn)
            self:ResetWishlistButton(btn)
        end
    )
end

function Journal:DestroyArmoryPools()
    for name, pool in pairs(self.armoryPools) do
        if pool then
            pool:Destroy()
            self.armoryPools[name] = nil
        end
    end
end
```

### 20.3 Pool Item Initialization

```lua
-- Upgrade Card Initialization
function Journal:InitializeUpgradeCard(card)
    local C = HopeAddon.Constants
    local M = C.ARMORY_MARGINS
    local CARD = C.ARMORY_UPGRADE_CARD

    card:SetHeight(CARD.HEIGHT)
    card:SetBackdrop({
        bgFile = C.ARMORY_ASSETS.BACKGROUNDS.TOOLTIP,
        edgeFile = C.ARMORY_ASSETS.BORDERS.TOOLTIP,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    card:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

    -- Rank badge (BEST / ALT)
    local rankBadge = CreateFrame("Frame", nil, card)
    rankBadge:SetSize(50, 20)
    rankBadge:SetPoint("TOPLEFT", M.CARD_PADDING, -M.CARD_PADDING)
    card.rankBadge = rankBadge

    local rankBg = rankBadge:CreateTexture(nil, "BACKGROUND")
    rankBg:SetAllPoints()
    rankBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    rankBadge.bg = rankBg

    local rankText = rankBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankText:SetPoint("CENTER")
    rankBadge.text = rankText

    -- Item icon
    local iconFrame = CreateFrame("Frame", nil, card)
    iconFrame:SetSize(40, 40)
    iconFrame:SetPoint("LEFT", rankBadge, "RIGHT", M.COMPONENT_GAP_MD, 0)
    iconFrame:SetPoint("TOP", card, "TOP", 0, -M.CARD_PADDING)
    card.iconFrame = iconFrame

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    card.icon = icon

    local iconBorder = iconFrame:CreateTexture(nil, "OVERLAY")
    iconBorder:SetPoint("TOPLEFT", -2, 2)
    iconBorder:SetPoint("BOTTOMRIGHT", 2, -2)
    iconBorder:SetTexture(C.ARMORY_ASSETS.QUALITY_BORDERS.COMMON)
    card.iconBorder = iconBorder

    -- Item name
    local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", M.COMPONENT_GAP_MD, 0)
    nameText:SetPoint("RIGHT", card, "RIGHT", -50, 0)
    nameText:SetJustifyH("LEFT")
    card.nameText = nameText

    -- Item stats
    local statsText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -M.COMPONENT_GAP_SM)
    statsText:SetPoint("RIGHT", card, "RIGHT", -50, 0)
    statsText:SetJustifyH("LEFT")
    statsText:SetTextColor(0.7, 0.7, 0.7, 1)
    card.statsText = statsText

    -- Source info
    local sourceText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceText:SetPoint("TOPLEFT", statsText, "BOTTOMLEFT", 0, -M.COMPONENT_GAP_SM)
    sourceText:SetPoint("RIGHT", card, "RIGHT", -50, 0)
    sourceText:SetJustifyH("LEFT")
    card.sourceText = sourceText

    -- Upgrade indicator
    local upgradeText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    upgradeText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", M.CARD_PADDING, M.CARD_PADDING)
    card.upgradeText = upgradeText

    -- Wishlist button (heart icon)
    local wishlistBtn = CreateFrame("Button", nil, card)
    wishlistBtn:SetSize(24, 24)
    wishlistBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -M.CARD_PADDING, -M.CARD_PADDING)
    card.wishlistBtn = wishlistBtn

    local wishlistIcon = wishlistBtn:CreateTexture(nil, "ARTWORK")
    wishlistIcon:SetAllPoints()
    wishlistIcon:SetTexture("Interface\\ICONS\\INV_ValentinesCard02")
    wishlistIcon:SetDesaturated(true)
    wishlistBtn.icon = wishlistIcon

    wishlistBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(wishlistBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Add to Wishlist", 1, 1, 1)
        GameTooltip:Show()
    end)
    wishlistBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function Journal:ResetUpgradeCard(card)
    card:Hide()
    card:ClearAllPoints()
    card:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Reset all texts
    card.rankBadge.text:SetText("")
    card.nameText:SetText("")
    card.statsText:SetText("")
    card.sourceText:SetText("")
    card.upgradeText:SetText("")

    -- Reset icon
    card.icon:SetTexture(nil)
    card.iconBorder:SetVertexColor(1, 1, 1, 1)

    -- Reset wishlist state
    card.wishlistBtn.icon:SetDesaturated(true)
    card.wishlistBtn:SetScript("OnClick", nil)

    -- Stop any animations
    if card.glowAnim then
        card.glowAnim:Stop()
    end

    -- Clear data
    card.itemData = nil
    card.isWishlisted = false
end
```

### 20.4 Pool Usage Pattern

```lua
function Journal:PopulateDetailPanel(slotName)
    -- Release all pooled frames
    for _, pool in pairs(self.armoryPools) do
        if pool then pool:ReleaseAll() end
    end

    local content = self.armoryUI.detailPanel.content
    local C = HopeAddon.Constants
    local M = C.ARMORY_MARGINS

    local yOffset = 0

    -- Equipped Section
    local equippedHeader = self.armoryPools.sectionHeader:Acquire()
    self:SetupSectionHeader(equippedHeader, "CURRENTLY EQUIPPED", false, "GREY")
    equippedHeader:SetParent(content)
    equippedHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
    equippedHeader:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
    equippedHeader:Show()
    yOffset = yOffset + equippedHeader:GetHeight() + M.SUBSECTION_SPACING

    -- Equipped item card
    local equippedCard = self.armoryPools.upgradeCard:Acquire()
    self:SetupEquippedCard(equippedCard, slotName)
    equippedCard:SetParent(content)
    equippedCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
    equippedCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
    equippedCard:Show()
    yOffset = yOffset + equippedCard:GetHeight() + M.SECTION_SPACING

    -- Tier Upgrades Section
    local tier = self.armoryState.selectedTier
    local upgrades = self:GetSlotUpgrades(tier, slotName)

    if upgrades and #upgrades > 0 then
        local tierHeader = self.armoryPools.sectionHeader:Acquire()
        self:SetupSectionHeader(tierHeader, string.format("T%d UPGRADES", tier), true, C.TIER_COLORS[tier])
        tierHeader:SetParent(content)
        tierHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        tierHeader:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
        tierHeader:Show()
        yOffset = yOffset + tierHeader:GetHeight() + M.SUBSECTION_SPACING

        -- Upgrade cards
        for i, upgradeData in ipairs(upgrades) do
            local card = self.armoryPools.upgradeCard:Acquire()
            self:SetupUpgradeCard(card, upgradeData, i == 1)  -- First is "BEST"
            card:SetParent(content)
            card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
            card:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
            card:Show()
            yOffset = yOffset + card:GetHeight() + M.CARD_MARGIN
        end
        yOffset = yOffset + M.SECTION_SPACING
    end

    -- Update scroll content height
    content:SetHeight(yOffset)
end
```

---

## 21. Additional Constants Namespace

### 21.1 Complete Armory Constants Block

```lua
-- Add to Constants.lua as C.ARMORY namespace

C.ARMORY = {
    -- UI Dimensions
    UI = {
        CONTAINER_MIN_HEIGHT = 550,
        CONTAINER_EXPANDED_HEIGHT = 850,
        TIER_BAR_HEIGHT = 50,
        PAPERDOLL_FULL_HEIGHT = 450,
        PAPERDOLL_COMPACT_HEIGHT = 280,
        DETAIL_PANEL_HEIGHT = 350,
        FOOTER_HEIGHT = 30,
        MODEL_WIDTH = 200,
        MODEL_HEIGHT = 280,
    },

    -- Slot Button Config
    SLOT = {
        BUTTON_SIZE = 44,
        ICON_SIZE = 36,
        INDICATOR_SIZE = 16,
        LABEL_HEIGHT = 12,
    },

    -- Upgrade Card Config
    CARD = {
        HEIGHT = 80,
        PADDING = 12,
        MARGIN = 8,
        ICON_SIZE = 40,
        RANK_BADGE_WIDTH = 50,
        RANK_BADGE_HEIGHT = 20,
    },

    -- Margins (import from section 17.1)
    MARGINS = C.ARMORY_MARGINS,

    -- Slot positions (import from section 4.3)
    SLOT_POSITIONS = ARMORY_SLOT_POSITIONS,

    -- Upgrade symbols (import from section 18.1)
    SYMBOLS = C.ARMORY_UPGRADE_SYMBOLS,

    -- Assets (import from section 19.1)
    ASSETS = C.ARMORY_ASSETS,

    -- Tier info
    TIERS = {
        [4] = {
            name = "T4",
            fullName = "Tier 4",
            phase = "Phase 1",
            color = "FEL_GREEN",
            raids = { "karazhan", "gruul", "magtheridon" },
            content = "Karazhan, Gruul's Lair, Magtheridon's Lair",
        },
        [5] = {
            name = "T5",
            fullName = "Tier 5",
            phase = "Phase 2",
            color = "SKY_BLUE",
            raids = { "ssc", "tk" },
            content = "Serpentshrine Cavern, Tempest Keep",
        },
        [6] = {
            name = "T6",
            fullName = "Tier 6",
            phase = "Phase 3",
            color = "HELLFIRE_RED",
            raids = { "hyjal", "bt", "sunwell" },
            content = "Hyjal Summit, Black Temple, Sunwell Plateau",
        },
    },

    -- Source types
    SOURCE_TYPES = {
        tier = { label = "Tier Token", color = "EPIC_PURPLE" },
        raid = { label = "Raid Drop", color = "EPIC_PURPLE" },
        heroic = { label = "Heroic Dungeon", color = "RARE_BLUE" },
        badge = { label = "Badge of Justice", color = "GOLD_BRIGHT" },
        rep = { label = "Reputation", color = "FEL_GREEN" },
        crafted = { label = "Crafted", color = "BRONZE" },
        quest = { label = "Quest", color = "GOLD_BRIGHT" },
        world = { label = "World Drop", color = "RARE_BLUE" },
    },

    -- iLvl thresholds for upgrade severity
    UPGRADE_THRESHOLDS = {
        MINOR = 1,    -- 1-9 iLvl
        STANDARD = 10, -- 10-19 iLvl
        MAJOR = 20,   -- 20+ iLvl
    },

    -- Slot categories for layout grouping
    SLOT_CATEGORIES = {
        armor = { "head", "shoulders", "chest", "waist", "legs" },
        accessories = { "neck", "back", "wrist", "hands", "feet" },
        jewelry = { "ring1", "ring2", "trinket1", "trinket2" },
        weapons = { "mainhand", "offhand", "ranged" },
    },

    -- Display order
    SLOT_ORDER = {
        "head", "neck", "shoulders", "back", "chest", "wrist",
        "waist", "hands", "legs", "feet",
        "ring1", "ring2", "trinket1", "trinket2",
        "mainhand", "offhand", "ranged"
    },
}
```

---

## 22. Summary: Files and Estimated Lines

| File | Section | New Lines | Purpose |
|------|---------|-----------|---------|
| `Constants.lua` | `C.ARMORY` | ~400 | All armory constants |
| `Constants.lua` | `C.ARMORY_GEAR_DATABASE` | ~600 | T4/T5/T6 item data |
| `Journal.lua` | `armoryUI` tables | ~50 | UI state management |
| `Journal.lua` | Containers | ~150 | Container creation |
| `Journal.lua` | Tier bar | ~150 | Tier selection UI |
| `Journal.lua` | Slot buttons | ~200 | 17 slot buttons |
| `Journal.lua` | Detail panel | ~300 | Upgrade detail UI |
| `Journal.lua` | Pooling | ~150 | Frame pools |
| `Journal.lua` | Helpers | ~100 | Utility functions |
| `Core.lua` | Defaults | ~30 | SavedVariables |

**Total New Code:** ~2,130 lines

---

---

# PART 3: COMPLETE CONTAINER SPECIFICATIONS

---

## 23. Master Container Registry

All containers in the Armory tab are documented below with exact specifications for implementation.

### 23.1 Container Hierarchy Overview

```
Journal.armoryUI (root namespace)
├── container                    -- Main armory container (23.2)
│   ├── tierBar                  -- Tier selection bar (23.3)
│   │   ├── tierButtons[4,5,6]   -- Individual tier buttons (23.4)
│   │   └── specDropdown         -- Spec/role dropdown (23.5)
│   │
│   ├── paperdoll               -- Character preview section (23.6)
│   │   ├── modelFrame          -- DressUpModel container (23.7)
│   │   └── slotsContainer      -- Equipment slot buttons (23.8)
│   │       └── slotButtons[17] -- Individual slot buttons (23.9)
│   │
│   ├── detailPanel             -- Right-side upgrade details (23.10)
│   │   ├── header              -- Panel header with slot name (23.11)
│   │   ├── scrollFrame         -- Scrollable content area (23.12)
│   │   │   └── content         -- Scroll content frame (23.13)
│   │   │       ├── equippedCard -- Currently equipped item (23.14)
│   │   │       └── sections[]  -- Collapsible upgrade sections (23.15)
│   │   └── footer              -- Action buttons row (23.16)
│   │
│   └── footer                  -- Bottom summary bar (23.17)
│
├── armoryPools (pool namespace)
│   ├── upgradeCard             -- Pool for upgrade item cards (23.18)
│   ├── sectionHeader           -- Pool for collapsible headers (23.19)
│   ├── statRow                 -- Pool for stat comparison rows (23.20)
│   ├── sourceTag               -- Pool for source type badges (23.21)
│   └── wishlistBtn             -- Pool for wishlist heart buttons (23.22)
│
└── armoryState (state namespace)
    ├── selectedTier            -- Current tier (4, 5, or 6)
    ├── selectedSpec            -- Current spec tab index
    ├── selectedSlot            -- Currently selected slot name
    ├── expandedSections        -- Which sections are expanded
    ├── slotStatuses            -- Upgrade status per slot
    └── wishlist                -- Wishlisted item IDs
```

---

## 23.2 Main Container Specification

```lua
--[[
    CONTAINER: armoryUI.container
    PURPOSE: Root container for entire Armory tab content
    PARENT: Journal.mainFrame.scrollContainer.content
    POOLED: No (created once, reused)
]]

C.ARMORY_CONTAINER = {
    -- Dimensions (relative to parent)
    WIDTH = "MATCH_PARENT",        -- Fills scroll content width
    HEIGHT = "DYNAMIC",            -- Expands based on content
    MIN_HEIGHT = 600,              -- Minimum height

    -- Margins
    PADDING = 15,                  -- Inner padding all sides
    MARGIN_TOP = 0,                -- From scroll content top
    MARGIN_BOTTOM = 20,            -- Extra space at bottom

    -- Appearance
    BACKDROP = {
        bgFile = nil,              -- Transparent (parent has bg)
        edgeFile = nil,            -- No border
    },
}

-- PAYLOAD: Container Creation
function Journal:CreateArmoryContainer()
    local parent = self.mainFrame.scrollContainer.content
    local C = HopeAddon.Constants.ARMORY_CONTAINER

    -- Create or reuse container
    if not self.armoryUI.container then
        local container = CreateFrame("Frame", "HopeArmoryContainer", parent)
        container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
        self.armoryUI.container = container
    end

    local container = self.armoryUI.container

    -- Reset state
    container:Show()

    -- Child creation (order matters)
    self:CreateArmoryTierBar()      -- 23.3
    self:CreateArmoryPaperdoll()    -- 23.6
    self:CreateArmoryDetailPanel()  -- 23.10
    self:CreateArmoryFooter()       -- 23.17

    -- Calculate total height
    self:RecalculateArmoryHeight()

    return container
end
```

---

## 23.3 Tier Bar Container Specification

```lua
--[[
    CONTAINER: armoryUI.tierBar
    PURPOSE: Horizontal bar with T4/T5/T6 buttons and spec dropdown
    PARENT: armoryUI.container
    POOLED: No
]]

C.ARMORY_TIER_BAR = {
    -- Dimensions
    HEIGHT = 50,
    WIDTH = "MATCH_PARENT",

    -- Anchoring
    ANCHOR = "TOPLEFT",
    OFFSET_X = 0,
    OFFSET_Y = 0,

    -- Internal layout
    PADDING_H = 15,                -- Horizontal padding
    PADDING_V = 7,                 -- Vertical padding

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.08, g = 0.08, b = 0.08, a = 0.95 },
    BORDER_COLOR = { r = 0.4, g = 0.35, b = 0.25, a = 1 },  -- Warm gold-brown

    -- Child layout
    TIER_BUTTONS_LEFT = 15,        -- Left edge of tier buttons
    SPEC_DROPDOWN_RIGHT = -15,     -- Right edge of spec dropdown
}

-- PAYLOAD: Tier Bar Creation
function Journal:CreateArmoryTierBar()
    local container = self.armoryUI.container
    local C = HopeAddon.Constants.ARMORY_TIER_BAR

    -- Create tier bar frame
    if not self.armoryUI.tierBar then
        local tierBar = CreateFrame("Frame", "HopeArmoryTierBar", container, "BackdropTemplate")
        tierBar:SetHeight(C.HEIGHT)
        tierBar:SetPoint("TOPLEFT", container, "TOPLEFT", C.OFFSET_X, C.OFFSET_Y)
        tierBar:SetPoint("TOPRIGHT", container, "TOPRIGHT", -C.OFFSET_X, C.OFFSET_Y)
        tierBar:SetBackdrop(C.BACKDROP)
        tierBar:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        tierBar:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        self.armoryUI.tierBar = tierBar
        self.armoryUI.tierButtons = {}
    end

    local tierBar = self.armoryUI.tierBar
    tierBar:Show()

    -- Create tier buttons
    self:CreateArmoryTierButtons()   -- 23.4
    self:CreateArmorySpecDropdown()  -- 23.5

    return tierBar
end
```

---

## 23.4 Tier Button Specifications

```lua
--[[
    CONTAINER: armoryUI.tierButtons[tier]
    PURPOSE: Individual tier selection buttons (T4, T5, T6)
    PARENT: armoryUI.tierBar
    POOLED: No (exactly 3 buttons)
]]

C.ARMORY_TIER_BUTTON = {
    -- Dimensions
    WIDTH = 100,
    HEIGHT = 36,

    -- Spacing
    GAP = 12,                      -- Gap between buttons
    FIRST_OFFSET = 15,             -- Offset from left edge

    -- Text
    FONT = "GameFontNormal",
    FONT_SIZE = 12,

    -- Per-tier configuration
    TIERS = {
        [4] = {
            label = "T4",
            sublabel = "Phase 1",
            color = "FEL_GREEN",
            raids = "Kara, Gruul, Mag",
        },
        [5] = {
            label = "T5",
            sublabel = "Phase 2",
            color = "SKY_BLUE",
            raids = "SSC, TK",
        },
        [6] = {
            label = "T6",
            sublabel = "Phase 3",
            color = "HELLFIRE_RED",
            raids = "Hyjal, BT, SWP",
        },
    },

    -- Visual states
    STATES = {
        active = {
            bgAlpha = 0.4,
            borderAlpha = 1.0,
            textAlpha = 1.0,
            showUnderline = true,
            underlineHeight = 3,
        },
        inactive = {
            bgAlpha = 0.1,
            borderAlpha = 0.5,
            textAlpha = 0.6,
            showUnderline = false,
        },
        hover = {
            bgAlpha = 0.25,
            borderAlpha = 0.8,
            textAlpha = 0.9,
            showUnderline = true,
            underlineHeight = 2,
        },
    },
}

-- PAYLOAD: Tier Buttons Creation
function Journal:CreateArmoryTierButtons()
    local tierBar = self.armoryUI.tierBar
    local C = HopeAddon.Constants.ARMORY_TIER_BUTTON

    for tier = 4, 6 do
        local btnConfig = C.TIERS[tier]

        if not self.armoryUI.tierButtons[tier] then
            local btn = CreateFrame("Button", "HopeArmoryTier" .. tier .. "Button", tierBar, "BackdropTemplate")
            btn:SetSize(C.WIDTH, C.HEIGHT)

            -- Position: left to right with gaps
            local xOffset = C.FIRST_OFFSET + (tier - 4) * (C.WIDTH + C.GAP)
            btn:SetPoint("LEFT", tierBar, "LEFT", xOffset, 0)

            -- Backdrop
            btn:SetBackdrop({
                bgFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })

            -- Text: Main label (T4, T5, T6)
            local label = btn:CreateFontString(nil, "OVERLAY", C.FONT)
            label:SetPoint("CENTER", btn, "CENTER", 0, 4)
            label:SetText(btnConfig.label)
            btn.label = label

            -- Text: Sublabel (Phase 1, Phase 2, Phase 3)
            local sublabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            sublabel:SetPoint("TOP", label, "BOTTOM", 0, -1)
            sublabel:SetText(btnConfig.sublabel)
            sublabel:SetTextColor(0.7, 0.7, 0.7, 1)
            btn.sublabel = sublabel

            -- Underline (for active state)
            local underline = btn:CreateTexture(nil, "OVERLAY")
            underline:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 4, 2)
            underline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 2)
            underline:SetHeight(C.STATES.active.underlineHeight)
            underline:SetTexture("Interface\\BUTTONS\\WHITE8X8")
            underline:Hide()
            btn.underline = underline

            -- Store tier reference
            btn.tier = tier
            btn.tierColor = HopeAddon.colors[btnConfig.color]

            -- Click handler
            btn:SetScript("OnClick", function()
                HopeAddon.Sounds:PlayClick()
                self:SelectArmoryTier(tier)
            end)

            -- Hover handlers
            btn:SetScript("OnEnter", function()
                HopeAddon.Sounds:PlayHover()
                self:SetTierButtonState(btn, "hover")
                GameTooltip:SetOwner(btn, "ANCHOR_BOTTOM")
                GameTooltip:SetText(btnConfig.label .. ": " .. btnConfig.raids)
                GameTooltip:Show()
            end)

            btn:SetScript("OnLeave", function()
                local state = (self.armoryState.selectedTier == tier) and "active" or "inactive"
                self:SetTierButtonState(btn, state)
                GameTooltip:Hide()
            end)

            self.armoryUI.tierButtons[tier] = btn
        end

        -- Set initial state
        local state = (self.armoryState.selectedTier == tier) and "active" or "inactive"
        self:SetTierButtonState(self.armoryUI.tierButtons[tier], state)
    end
end

-- PAYLOAD: Tier Button State Management
function Journal:SetTierButtonState(btn, stateName)
    local C = HopeAddon.Constants.ARMORY_TIER_BUTTON
    local state = C.STATES[stateName]
    local tierColor = btn.tierColor

    -- Background color (tier color at configured alpha)
    btn:SetBackdropColor(
        tierColor.r * 0.3,
        tierColor.g * 0.3,
        tierColor.b * 0.3,
        state.bgAlpha
    )

    -- Border color
    btn:SetBackdropBorderColor(
        tierColor.r,
        tierColor.g,
        tierColor.b,
        state.borderAlpha
    )

    -- Text color
    btn.label:SetTextColor(tierColor.r, tierColor.g, tierColor.b, state.textAlpha)

    -- Underline
    if state.showUnderline then
        btn.underline:SetHeight(state.underlineHeight)
        btn.underline:SetVertexColor(tierColor.r, tierColor.g, tierColor.b, 1)
        btn.underline:Show()
    else
        btn.underline:Hide()
    end
end
```

---

## 23.5 Spec Dropdown Specification

```lua
--[[
    CONTAINER: armoryUI.specDropdown
    PURPOSE: Dropdown to select character spec for role-based recommendations
    PARENT: armoryUI.tierBar
    POOLED: No
]]

C.ARMORY_SPEC_DROPDOWN = {
    -- Dimensions
    WIDTH = 150,
    HEIGHT = 30,

    -- Anchoring (right side of tier bar)
    ANCHOR = "RIGHT",
    OFFSET_X = -15,
    OFFSET_Y = 0,

    -- Dropdown menu width
    MENU_WIDTH = 140,
}

-- PAYLOAD: Spec Dropdown Creation
function Journal:CreateArmorySpecDropdown()
    local tierBar = self.armoryUI.tierBar
    local C = HopeAddon.Constants.ARMORY_SPEC_DROPDOWN

    if not self.armoryUI.specDropdown then
        local dropdown = CreateFrame("Frame", "HopeArmorySpecDropdown", tierBar, "UIDropDownMenuTemplate")
        dropdown:SetPoint(C.ANCHOR, tierBar, C.ANCHOR, C.OFFSET_X, C.OFFSET_Y)

        UIDropDownMenu_SetWidth(dropdown, C.MENU_WIDTH)

        UIDropDownMenu_Initialize(dropdown, function(frame, level)
            self:InitArmorySpecDropdownMenu(frame, level)
        end)

        self.armoryUI.specDropdown = dropdown
    end

    -- Set current spec text
    local specName = HopeAddon:GetPlayerSpec()
    UIDropDownMenu_SetText(self.armoryUI.specDropdown, specName or "Select Spec")
end

-- PAYLOAD: Spec Dropdown Menu Initialization
function Journal:InitArmorySpecDropdownMenu(frame, level)
    local classFile = select(2, UnitClass("player"))

    -- Get specs for this class (1, 2, 3)
    for specTab = 1, 3 do
        local specName = select(1, GetTalentTabInfo(specTab))
        if specName and specName ~= "" then
            local info = UIDropDownMenu_CreateInfo()
            info.text = specName
            info.value = specTab
            info.func = function()
                self.armoryState.selectedSpec = specTab
                UIDropDownMenu_SetText(self.armoryUI.specDropdown, specName)
                self:RefreshArmoryRecommendations()
            end
            info.checked = (self.armoryState.selectedSpec == specTab)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
```

---

## 23.6 Paperdoll Container Specification

```lua
--[[
    CONTAINER: armoryUI.paperdoll
    PURPOSE: Left side with character model and equipment slots
    PARENT: armoryUI.container
    POOLED: No
]]

C.ARMORY_PAPERDOLL = {
    -- Dimensions
    WIDTH = 300,
    HEIGHT = "FILL_HEIGHT",        -- Fills from tier bar to footer

    -- Anchoring
    ANCHOR = "TOPLEFT",
    OFFSET_X = 0,
    OFFSET_Y = -50,                -- Below tier bar (50px height)

    -- Internal sections
    MODEL_HEIGHT = 280,            -- Character model area
    SLOTS_HEIGHT = 280,            -- Equipment slots area (stacked)

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    BG_COLOR = { r = 0.05, g = 0.05, b = 0.05, a = 0.9 },
    BORDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
}

-- PAYLOAD: Paperdoll Creation
function Journal:CreateArmoryPaperdoll()
    local container = self.armoryUI.container
    local C = HopeAddon.Constants.ARMORY_PAPERDOLL
    local tierBarHeight = HopeAddon.Constants.ARMORY_TIER_BAR.HEIGHT

    if not self.armoryUI.paperdoll then
        local paperdoll = CreateFrame("Frame", "HopeArmoryPaperdoll", container, "BackdropTemplate")
        paperdoll:SetWidth(C.WIDTH)
        paperdoll:SetPoint("TOPLEFT", container, "TOPLEFT", C.OFFSET_X, -tierBarHeight)
        paperdoll:SetBackdrop(C.BACKDROP)
        paperdoll:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        paperdoll:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        self.armoryUI.paperdoll = paperdoll
    end

    local paperdoll = self.armoryUI.paperdoll
    paperdoll:Show()

    -- Create child components
    self:CreateArmoryModelFrame()     -- 23.7
    self:CreateArmorySlotsContainer() -- 23.8

    -- Set height based on children
    paperdoll:SetHeight(C.MODEL_HEIGHT + C.SLOTS_HEIGHT + 20)

    return paperdoll
end
```

---

## 23.7 Model Frame Specification

```lua
--[[
    CONTAINER: armoryUI.modelFrame
    PURPOSE: DressUpModel showing character with equipped gear
    PARENT: armoryUI.paperdoll
    POOLED: No
]]

C.ARMORY_MODEL_FRAME = {
    -- Dimensions
    WIDTH = 280,
    HEIGHT = 260,

    -- Anchoring (centered in paperdoll)
    ANCHOR = "TOP",
    OFFSET_X = 0,
    OFFSET_Y = -10,

    -- Model settings
    DEFAULT_ROTATION = 0,          -- Facing forward
    ROTATION_SPEED = 0.01,         -- Radians per pixel dragged
    DEFAULT_CAMERA = 0,            -- Camera zoom level
    BACKGROUND_COLOR = { r = 0.02, g = 0.02, b = 0.02, a = 1 },

    -- Lighting (TBC ambient)
    LIGHTING = {
        ambient = { r = 0.4, g = 0.4, b = 0.4 },
        diffuse = { r = 1.0, g = 0.95, b = 0.9 },
    },
}

-- PAYLOAD: Model Frame Creation
function Journal:CreateArmoryModelFrame()
    local paperdoll = self.armoryUI.paperdoll
    local C = HopeAddon.Constants.ARMORY_MODEL_FRAME

    if not self.armoryUI.modelFrame then
        local modelFrame = CreateFrame("DressUpModel", "HopeArmoryModel", paperdoll)
        modelFrame:SetSize(C.WIDTH, C.HEIGHT)
        modelFrame:SetPoint(C.ANCHOR, paperdoll, C.ANCHOR, C.OFFSET_X, C.OFFSET_Y)

        -- Background
        local bg = modelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(C.BACKGROUND_COLOR.r, C.BACKGROUND_COLOR.g, C.BACKGROUND_COLOR.b, C.BACKGROUND_COLOR.a)

        -- Initialize model
        modelFrame:SetUnit("player")
        modelFrame:SetRotation(C.DEFAULT_ROTATION)
        modelFrame:SetPortraitZoom(0.8)

        -- Drag rotation
        modelFrame:EnableMouse(true)
        modelFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self.isDragging = true
                self.lastX = GetCursorPosition()
            end
        end)

        modelFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                self.isDragging = false
            end
        end)

        modelFrame:SetScript("OnUpdate", function(self)
            if self.isDragging then
                local currentX = GetCursorPosition()
                local delta = (currentX - (self.lastX or currentX)) * C.ROTATION_SPEED
                self:SetRotation(self:GetFacing() + delta)
                self.lastX = currentX
            end
        end)

        self.armoryUI.modelFrame = modelFrame
    end

    self.armoryUI.modelFrame:Show()
    self.armoryUI.modelFrame:SetUnit("player")

    return self.armoryUI.modelFrame
end
```

---

## 23.8 Slots Container Specification

```lua
--[[
    CONTAINER: armoryUI.slotsContainer
    PURPOSE: Container for all 17 equipment slot buttons
    PARENT: armoryUI.paperdoll
    POOLED: No
]]

C.ARMORY_SLOTS_CONTAINER = {
    -- Dimensions
    WIDTH = 280,
    HEIGHT = 260,

    -- Anchoring (below model frame)
    ANCHOR = "TOP",
    OFFSET_X = 0,
    OFFSET_Y = -280,               -- MODEL_HEIGHT + 20 padding

    -- Slot button layout
    SLOT_SIZE = 44,
    SLOT_GAP = 6,
    COLUMN_GAP = 8,

    -- Layout regions (slots grouped by position)
    REGIONS = {
        -- Left column (from top to bottom)
        LEFT = {
            slots = { "head", "shoulders", "chest", "waist", "legs" },
            anchor = "TOPLEFT",
            offset = { x = 10, y = -10 },
            direction = "DOWN",
        },
        -- Right column (from top to bottom)
        RIGHT = {
            slots = { "neck", "back", "wrist", "hands", "feet" },
            anchor = "TOPRIGHT",
            offset = { x = -10, y = -10 },
            direction = "DOWN",
        },
        -- Bottom row (rings, trinkets, weapons)
        BOTTOM = {
            slots = { "ring1", "ring2", "trinket1", "trinket2", "mainhand", "offhand", "ranged" },
            anchor = "BOTTOM",
            offset = { x = 0, y = 10 },
            direction = "RIGHT",
        },
    },
}

-- PAYLOAD: Slots Container Creation
function Journal:CreateArmorySlotsContainer()
    local paperdoll = self.armoryUI.paperdoll
    local C = HopeAddon.Constants.ARMORY_SLOTS_CONTAINER
    local modelHeight = HopeAddon.Constants.ARMORY_MODEL_FRAME.HEIGHT

    if not self.armoryUI.slotsContainer then
        local slotsContainer = CreateFrame("Frame", "HopeArmorySlotsContainer", paperdoll)
        slotsContainer:SetSize(C.WIDTH, C.HEIGHT)
        slotsContainer:SetPoint("TOP", paperdoll, "TOP", C.OFFSET_X, -(modelHeight + 20))

        self.armoryUI.slotsContainer = slotsContainer
        self.armoryUI.slotButtons = {}
    end

    local slotsContainer = self.armoryUI.slotsContainer
    slotsContainer:Show()

    -- Create all slot buttons
    self:CreateArmorySlotButtons()  -- 23.9

    return slotsContainer
end
```

---

## 23.9 Slot Button Specification (Template)

```lua
--[[
    CONTAINER: armoryUI.slotButtons[slotName]
    PURPOSE: Individual equipment slot button
    PARENT: armoryUI.slotsContainer
    POOLED: No (exactly 17 buttons, reused)
]]

C.ARMORY_SLOT_BUTTON = {
    -- Dimensions
    SIZE = 44,
    ICON_SIZE = 36,
    ICON_INSET = 4,

    -- Indicator badge
    INDICATOR_SIZE = 16,
    INDICATOR_OFFSET = { x = 2, y = -2 },

    -- Label
    LABEL_HEIGHT = 12,
    LABEL_FONT = "GameFontNormalSmall",

    -- All 17 slots with display names
    SLOTS = {
        head      = { displayName = "HEAD",     slotId = 1 },
        neck      = { displayName = "NECK",     slotId = 2 },
        shoulders = { displayName = "SHLD",     slotId = 3 },
        back      = { displayName = "BACK",     slotId = 15 },
        chest     = { displayName = "CHEST",    slotId = 5 },
        wrist     = { displayName = "WRIST",    slotId = 9 },
        hands     = { displayName = "HANDS",    slotId = 10 },
        waist     = { displayName = "WAIST",    slotId = 6 },
        legs      = { displayName = "LEGS",     slotId = 7 },
        feet      = { displayName = "FEET",     slotId = 8 },
        ring1     = { displayName = "RING",     slotId = 11 },
        ring2     = { displayName = "RING",     slotId = 12 },
        trinket1  = { displayName = "TRNK",     slotId = 13 },
        trinket2  = { displayName = "TRNK",     slotId = 14 },
        mainhand  = { displayName = "MH",       slotId = 16 },
        offhand   = { displayName = "OH",       slotId = 17 },
        ranged    = { displayName = "RNG",      slotId = 18 },
    },

    -- Position offsets for each slot (relative to slotsContainer)
    POSITIONS = {
        -- Left column (x=10, spaced vertically)
        head      = { anchor = "TOPLEFT",  x = 10,  y = -10 },
        shoulders = { anchor = "TOPLEFT",  x = 10,  y = -60 },
        chest     = { anchor = "TOPLEFT",  x = 10,  y = -110 },
        waist     = { anchor = "TOPLEFT",  x = 10,  y = -160 },
        legs      = { anchor = "TOPLEFT",  x = 10,  y = -210 },

        -- Right column (x from right edge, spaced vertically)
        neck      = { anchor = "TOPRIGHT", x = -10, y = -10 },
        back      = { anchor = "TOPRIGHT", x = -10, y = -60 },
        wrist     = { anchor = "TOPRIGHT", x = -10, y = -110 },
        hands     = { anchor = "TOPRIGHT", x = -10, y = -160 },
        feet      = { anchor = "TOPRIGHT", x = -10, y = -210 },

        -- Bottom row (centered, spaced horizontally)
        ring1     = { anchor = "BOTTOMLEFT", x = 10,  y = 10 },
        ring2     = { anchor = "BOTTOMLEFT", x = 60,  y = 10 },
        trinket1  = { anchor = "BOTTOMLEFT", x = 110, y = 10 },
        trinket2  = { anchor = "BOTTOMLEFT", x = 160, y = 10 },
        mainhand  = { anchor = "BOTTOMRIGHT", x = -110, y = 10 },
        offhand   = { anchor = "BOTTOMRIGHT", x = -60, y = 10 },
        ranged    = { anchor = "BOTTOMRIGHT", x = -10, y = 10 },
    },
}

-- PAYLOAD: Create All Slot Buttons
function Journal:CreateArmorySlotButtons()
    local slotsContainer = self.armoryUI.slotsContainer
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON

    for slotName, slotData in pairs(C.SLOTS) do
        if not self.armoryUI.slotButtons[slotName] then
            local btn = self:CreateSingleArmorySlotButton(slotsContainer, slotName, slotData)
            self.armoryUI.slotButtons[slotName] = btn
        end

        -- Position the button
        local pos = C.POSITIONS[slotName]
        local btn = self.armoryUI.slotButtons[slotName]
        btn:ClearAllPoints()
        btn:SetPoint(pos.anchor, slotsContainer, pos.anchor, pos.x, pos.y)
        btn:Show()
    end
end

-- PAYLOAD: Create Single Slot Button
function Journal:CreateSingleArmorySlotButton(parent, slotName, slotData)
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON
    local colors = HopeAddon.colors

    local btn = CreateFrame("Button", "HopeArmorySlot_" .. slotName, parent, "BackdropTemplate")
    btn:SetSize(C.SIZE, C.SIZE)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- Icon container
    local iconFrame = CreateFrame("Frame", nil, btn)
    iconFrame:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    iconFrame:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconFrame = iconFrame

    -- Placeholder texture (when no item equipped)
    local placeholder = iconFrame:CreateTexture(nil, "ARTWORK", nil, 0)
    placeholder:SetAllPoints()
    placeholder:SetTexture(HopeAddon.Constants.ARMORY_SLOT_PLACEHOLDER_ICONS[slotName] or "Interface\\PaperDoll\\UI-Backpack-EmptySlot")
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(0.5)
    btn.placeholder = placeholder

    -- Item icon texture
    local icon = iconFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- Trim default border
    icon:Hide()
    btn.icon = icon

    -- Quality border overlay
    local qualityBorder = iconFrame:CreateTexture(nil, "OVERLAY", nil, 0)
    qualityBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -2, 2)
    qualityBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 2, -2)
    qualityBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    qualityBorder:Hide()
    btn.qualityBorder = qualityBorder

    -- Upgrade indicator badge (top-right corner)
    local indicator = CreateFrame("Frame", nil, btn)
    indicator:SetSize(C.INDICATOR_SIZE, C.INDICATOR_SIZE)
    indicator:SetPoint("TOPRIGHT", btn, "TOPRIGHT", C.INDICATOR_OFFSET.x, C.INDICATOR_OFFSET.y)
    indicator:Hide()
    btn.indicator = indicator

    local indicatorBg = indicator:CreateTexture(nil, "BACKGROUND")
    indicatorBg:SetAllPoints()
    indicatorBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    indicatorBg:SetVertexColor(0, 0, 0, 0.8)
    indicator.bg = indicatorBg

    local indicatorIcon = indicator:CreateTexture(nil, "ARTWORK")
    indicatorIcon:SetSize(C.INDICATOR_SIZE - 2, C.INDICATOR_SIZE - 2)
    indicatorIcon:SetPoint("CENTER")
    indicator.iconTex = indicatorIcon

    local indicatorText = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    indicatorText:SetPoint("CENTER")
    indicatorText:SetFont(indicatorText:GetFont(), 10, "OUTLINE")
    indicator.text = indicatorText

    -- Slot label (below icon)
    local label = btn:CreateFontString(nil, "OVERLAY", C.LABEL_FONT)
    label:SetPoint("TOP", btn, "BOTTOM", 0, -2)
    label:SetText(slotData.displayName)
    label:SetTextColor(0.7, 0.7, 0.7, 1)
    btn.label = label

    -- Glow overlay (for selection/pulse animation)
    local glow = btn:CreateTexture(nil, "OVERLAY", nil, 7)
    glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -8, 8)
    glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 8, -8)
    glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
    glow:SetBlendMode("ADD")
    glow:SetAlpha(0)
    btn.glow = glow

    -- Highlight overlay (mouseover)
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(iconFrame)
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")

    -- Data storage
    btn.slotName = slotName
    btn.slotId = slotData.slotId
    btn.equippedItem = nil
    btn.upgradeStatus = "empty"
    btn.isSelected = false

    -- Click handler
    btn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        self:OnArmorySlotClick(slotName)
    end)

    -- Hover handlers
    btn:SetScript("OnEnter", function()
        HopeAddon.Sounds:PlayHover()
        self:OnArmorySlotEnter(btn)
    end)

    btn:SetScript("OnLeave", function()
        self:OnArmorySlotLeave(btn)
    end)

    return btn
end
```

---

## 23.10 Detail Panel Specification

```lua
--[[
    CONTAINER: armoryUI.detailPanel
    PURPOSE: Right-side panel showing upgrade recommendations for selected slot
    PARENT: armoryUI.container
    POOLED: No
]]

C.ARMORY_DETAIL_PANEL = {
    -- Dimensions
    WIDTH = "FILL_REMAINING",      -- Fills space right of paperdoll
    MIN_WIDTH = 350,
    HEIGHT = "MATCH_PAPERDOLL",    -- Same height as paperdoll

    -- Anchoring
    ANCHOR = "TOPRIGHT",
    OFFSET_X = 0,
    OFFSET_Y = -50,                -- Below tier bar

    -- Internal spacing
    HEADER_HEIGHT = 45,
    FOOTER_HEIGHT = 40,
    CONTENT_PADDING = 12,

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
    BG_COLOR = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 },
    BORDER_COLOR = { r = 0.4, g = 0.35, b = 0.25, a = 1 },
}

-- PAYLOAD: Detail Panel Creation
function Journal:CreateArmoryDetailPanel()
    local container = self.armoryUI.container
    local paperdoll = self.armoryUI.paperdoll
    local C = HopeAddon.Constants.ARMORY_DETAIL_PANEL
    local tierBarHeight = HopeAddon.Constants.ARMORY_TIER_BAR.HEIGHT
    local paperdollWidth = HopeAddon.Constants.ARMORY_PAPERDOLL.WIDTH

    if not self.armoryUI.detailPanel then
        local detailPanel = CreateFrame("Frame", "HopeArmoryDetailPanel", container, "BackdropTemplate")

        -- Position: right of paperdoll, same height
        detailPanel:SetPoint("TOPLEFT", container, "TOPLEFT", paperdollWidth + 10, -tierBarHeight)
        detailPanel:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -tierBarHeight)
        detailPanel:SetPoint("BOTTOM", paperdoll, "BOTTOM", 0, 0)

        detailPanel:SetBackdrop(C.BACKDROP)
        detailPanel:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        detailPanel:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        self.armoryUI.detailPanel = detailPanel
    end

    local detailPanel = self.armoryUI.detailPanel
    detailPanel:Show()

    -- Create child components
    self:CreateArmoryDetailHeader()    -- 23.11
    self:CreateArmoryDetailScroll()    -- 23.12
    self:CreateArmoryDetailFooter()    -- 23.16

    return detailPanel
end
```

---

## 23.11 Detail Panel Header Specification

```lua
--[[
    CONTAINER: armoryUI.detailPanel.header
    PURPOSE: Header showing selected slot name and equipped item summary
    PARENT: armoryUI.detailPanel
    POOLED: No
]]

C.ARMORY_DETAIL_HEADER = {
    HEIGHT = 45,

    -- Title text
    TITLE_FONT = "GameFontNormalLarge",
    TITLE_OFFSET = { x = 15, y = -12 },

    -- Subtitle (equipped item name)
    SUBTITLE_FONT = "GameFontNormalSmall",
    SUBTITLE_OFFSET = { x = 15, y = -28 },

    -- Close/collapse button (right side)
    CLOSE_BUTTON_SIZE = 24,
    CLOSE_BUTTON_OFFSET = { x = -10, y = 0 },

    -- Divider line
    DIVIDER_HEIGHT = 2,
    DIVIDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
}

-- PAYLOAD: Detail Header Creation
function Journal:CreateArmoryDetailHeader()
    local detailPanel = self.armoryUI.detailPanel
    local C = HopeAddon.Constants.ARMORY_DETAIL_HEADER

    if not detailPanel.header then
        local header = CreateFrame("Frame", nil, detailPanel)
        header:SetHeight(C.HEIGHT)
        header:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 0, 0)
        header:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", 0, 0)

        -- Title text (slot name)
        local title = header:CreateFontString(nil, "OVERLAY", C.TITLE_FONT)
        title:SetPoint("TOPLEFT", header, "TOPLEFT", C.TITLE_OFFSET.x, C.TITLE_OFFSET.y)
        title:SetText("Select a Slot")
        title:SetTextColor(1, 0.84, 0, 1)  -- Gold
        header.title = title

        -- Subtitle (equipped item)
        local subtitle = header:CreateFontString(nil, "OVERLAY", C.SUBTITLE_FONT)
        subtitle:SetPoint("TOPLEFT", header, "TOPLEFT", C.SUBTITLE_OFFSET.x, C.SUBTITLE_OFFSET.y)
        subtitle:SetText("")
        subtitle:SetTextColor(0.7, 0.7, 0.7, 1)
        header.subtitle = subtitle

        -- Divider line at bottom
        local divider = header:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(C.DIVIDER_HEIGHT)
        divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 10, 0)
        divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -10, 0)
        divider:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        divider:SetVertexColor(C.DIVIDER_COLOR.r, C.DIVIDER_COLOR.g, C.DIVIDER_COLOR.b, C.DIVIDER_COLOR.a)
        header.divider = divider

        detailPanel.header = header
    end

    detailPanel.header:Show()
    return detailPanel.header
end
```

---

## 23.12 Detail Scroll Frame Specification

```lua
--[[
    CONTAINER: armoryUI.detailPanel.scrollFrame
    PURPOSE: Scrollable area for upgrade recommendations
    PARENT: armoryUI.detailPanel
    POOLED: No
]]

C.ARMORY_DETAIL_SCROLL = {
    -- Padding from parent edges
    PADDING_LEFT = 5,
    PADDING_RIGHT = 5,
    PADDING_TOP = 50,              -- Below header
    PADDING_BOTTOM = 45,           -- Above footer

    -- Scroll bar
    SCROLLBAR_WIDTH = 16,
    SCROLLBAR_OFFSET = -2,

    -- Content area
    CONTENT_PADDING = 10,
}

-- PAYLOAD: Detail Scroll Frame Creation
function Journal:CreateArmoryDetailScroll()
    local detailPanel = self.armoryUI.detailPanel
    local C = HopeAddon.Constants.ARMORY_DETAIL_SCROLL
    local headerHeight = HopeAddon.Constants.ARMORY_DETAIL_HEADER.HEIGHT
    local footerHeight = HopeAddon.Constants.ARMORY_DETAIL_FOOTER.HEIGHT

    if not detailPanel.scrollFrame then
        -- Create scroll frame using shared utility
        local scrollContainer = HopeAddon.Components:CreateScrollFrame(
            detailPanel,
            nil,  -- width set by anchors
            nil   -- height set by anchors
        )

        scrollContainer.frame:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", C.PADDING_LEFT, -headerHeight)
        scrollContainer.frame:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -C.PADDING_RIGHT, footerHeight)

        detailPanel.scrollFrame = scrollContainer.frame
        detailPanel.scrollContent = scrollContainer.content
    end

    detailPanel.scrollFrame:Show()
    return detailPanel.scrollFrame
end
```

---

## 23.13 Scroll Content Specification

```lua
--[[
    CONTAINER: armoryUI.detailPanel.scrollContent
    PURPOSE: Content frame inside scroll frame, holds all upgrade cards
    PARENT: armoryUI.detailPanel.scrollFrame
    POOLED: No (content managed by frame pools)
]]

C.ARMORY_SCROLL_CONTENT = {
    -- Vertical layout
    CARD_SPACING = 8,              -- Space between cards
    SECTION_SPACING = 15,          -- Space between sections

    -- Empty state
    EMPTY_TEXT = "Click on an equipment slot to see upgrade recommendations.",
    EMPTY_TEXT_COLOR = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
}

-- Note: scrollContent is created automatically by CreateScrollFrame
-- Content management is handled by PopulateArmorySlotDetail()
```

---

## 23.14 Equipped Item Card Specification

```lua
--[[
    CONTAINER: (created in scrollContent)
    PURPOSE: Shows currently equipped item in selected slot
    PARENT: armoryUI.detailPanel.scrollContent
    POOLED: No (single instance, reused)
]]

C.ARMORY_EQUIPPED_CARD = {
    -- Dimensions
    HEIGHT = 80,
    WIDTH = "MATCH_PARENT",

    -- Margins
    PADDING = 12,
    ICON_SIZE = 44,

    -- Text layout
    TITLE_OFFSET = { x = 60, y = -12 },
    ILEVEL_OFFSET = { x = 60, y = -28 },
    STATS_OFFSET = { x = 60, y = -44 },

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 },

    -- Header label
    HEADER_TEXT = "CURRENTLY EQUIPPED",
    HEADER_COLOR = { r = 0.7, g = 0.7, b = 0.7, a = 1 },
}

-- PAYLOAD: Equipped Card Creation
function Journal:CreateArmoryEquippedCard()
    local scrollContent = self.armoryUI.detailPanel.scrollContent
    local C = HopeAddon.Constants.ARMORY_EQUIPPED_CARD

    if not self.armoryUI.equippedCard then
        local card = CreateFrame("Frame", "HopeArmoryEquippedCard", scrollContent, "BackdropTemplate")
        card:SetHeight(C.HEIGHT)
        card:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
        card:SetPoint("TOPRIGHT", scrollContent, "TOPRIGHT", 0, 0)

        card:SetBackdrop(C.BACKDROP)
        card:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)

        -- Header label
        local headerLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerLabel:SetPoint("TOPLEFT", card, "TOPLEFT", C.PADDING, -8)
        headerLabel:SetText(C.HEADER_TEXT)
        headerLabel:SetTextColor(C.HEADER_COLOR.r, C.HEADER_COLOR.g, C.HEADER_COLOR.b, C.HEADER_COLOR.a)
        card.headerLabel = headerLabel

        -- Item icon
        local icon = card:CreateTexture(nil, "ARTWORK")
        icon:SetSize(C.ICON_SIZE, C.ICON_SIZE)
        icon:SetPoint("TOPLEFT", card, "TOPLEFT", C.PADDING, -24)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        card.icon = icon

        -- Quality border
        local qualityBorder = card:CreateTexture(nil, "OVERLAY")
        qualityBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        qualityBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        qualityBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
        card.qualityBorder = qualityBorder

        -- Item name
        local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("TOPLEFT", card, "TOPLEFT", C.TITLE_OFFSET.x, C.TITLE_OFFSET.y - 16)
        nameText:SetJustifyH("LEFT")
        card.nameText = nameText

        -- Item level and source
        local iLevelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        iLevelText:SetPoint("TOPLEFT", card, "TOPLEFT", C.ILEVEL_OFFSET.x, C.ILEVEL_OFFSET.y - 16)
        iLevelText:SetTextColor(0.7, 0.7, 0.7, 1)
        card.iLevelText = iLevelText

        -- Stats preview
        local statsText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statsText:SetPoint("TOPLEFT", card, "TOPLEFT", C.STATS_OFFSET.x, C.STATS_OFFSET.y - 16)
        statsText:SetPoint("RIGHT", card, "RIGHT", -C.PADDING, 0)
        statsText:SetJustifyH("LEFT")
        statsText:SetTextColor(0.6, 0.6, 0.6, 1)
        card.statsText = statsText

        self.armoryUI.equippedCard = card
    end

    return self.armoryUI.equippedCard
end
```

---

## 23.15 Upgrade Section Specification (Collapsible)

```lua
--[[
    CONTAINER: (pooled section headers + upgrade cards)
    PURPOSE: Collapsible sections for different upgrade sources
    PARENT: armoryUI.detailPanel.scrollContent
    POOLED: Yes (sectionHeader pool, upgradeCard pool)
]]

C.ARMORY_UPGRADE_SECTION = {
    -- Section types
    SECTIONS = {
        { id = "t4_upgrades", label = "T4 UPGRADES", color = "FEL_GREEN", defaultExpanded = true },
        { id = "badge",       label = "BADGE OF JUSTICE", color = "GOLD_BRIGHT", defaultExpanded = false },
        { id = "heroic",      label = "HEROIC DUNGEONS", color = "SKY_BLUE", defaultExpanded = false },
        { id = "rep",         label = "REPUTATION", color = "ARCANE_PURPLE", defaultExpanded = false },
        { id = "crafted",     label = "CRAFTED GEAR", color = "BRONZE", defaultExpanded = false },
    },

    -- Section header
    HEADER_HEIGHT = 28,
    HEADER_PADDING = 8,
    HEADER_FONT = "GameFontNormal",

    -- Collapse arrow
    ARROW_SIZE = 16,
    ARROW_EXPANDED = "Interface\\Buttons\\UI-MinusButton-Up",
    ARROW_COLLAPSED = "Interface\\Buttons\\UI-PlusButton-Up",

    -- Content area (when expanded)
    CONTENT_PADDING = 8,
    CARD_SPACING = 6,
}
```

---

## 23.16 Detail Panel Footer Specification

```lua
--[[
    CONTAINER: armoryUI.detailPanel.footer
    PURPOSE: Action buttons row at bottom of detail panel
    PARENT: armoryUI.detailPanel
    POOLED: No
]]

C.ARMORY_DETAIL_FOOTER = {
    HEIGHT = 40,

    -- Padding
    PADDING_H = 10,
    PADDING_V = 5,

    -- Buttons
    BUTTON_WIDTH = 100,
    BUTTON_HEIGHT = 28,
    BUTTON_GAP = 10,

    -- Divider line
    DIVIDER_HEIGHT = 2,
    DIVIDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },

    -- Button definitions
    BUTTONS = {
        { id = "addWishlist", label = "Add to Wishlist", color = "EPIC_PURPLE", position = "LEFT" },
        { id = "close", label = "Close", color = "GREY", position = "RIGHT" },
    },
}

-- PAYLOAD: Detail Footer Creation
function Journal:CreateArmoryDetailFooter()
    local detailPanel = self.armoryUI.detailPanel
    local C = HopeAddon.Constants.ARMORY_DETAIL_FOOTER

    if not detailPanel.footer then
        local footer = CreateFrame("Frame", nil, detailPanel)
        footer:SetHeight(C.HEIGHT)
        footer:SetPoint("BOTTOMLEFT", detailPanel, "BOTTOMLEFT", 0, 0)
        footer:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", 0, 0)

        -- Divider line at top
        local divider = footer:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(C.DIVIDER_HEIGHT)
        divider:SetPoint("TOPLEFT", footer, "TOPLEFT", 10, -1)
        divider:SetPoint("TOPRIGHT", footer, "TOPRIGHT", -10, -1)
        divider:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        divider:SetVertexColor(C.DIVIDER_COLOR.r, C.DIVIDER_COLOR.g, C.DIVIDER_COLOR.b, C.DIVIDER_COLOR.a)
        footer.divider = divider

        -- Create action buttons
        footer.buttons = {}
        for _, btnConfig in ipairs(C.BUTTONS) do
            local btn = HopeAddon.Components:CreateStyledButton(
                footer,
                btnConfig.label,
                C.BUTTON_WIDTH,
                C.BUTTON_HEIGHT
            )

            if btnConfig.position == "LEFT" then
                btn:SetPoint("LEFT", footer, "LEFT", C.PADDING_H, 0)
            else
                btn:SetPoint("RIGHT", footer, "RIGHT", -C.PADDING_H, 0)
            end

            local color = HopeAddon.colors[btnConfig.color]
            if color then
                btn:SetBackdropBorderColor(color.r, color.g, color.b, 1)
            end

            btn:SetScript("OnClick", function()
                self:OnArmoryFooterButtonClick(btnConfig.id)
            end)

            footer.buttons[btnConfig.id] = btn
        end

        detailPanel.footer = footer
    end

    detailPanel.footer:Show()
    return detailPanel.footer
end
```

---

## 23.17 Main Footer Specification

```lua
--[[
    CONTAINER: armoryUI.footer
    PURPOSE: Bottom bar showing upgrade summary statistics
    PARENT: armoryUI.container
    POOLED: No
]]

C.ARMORY_FOOTER = {
    -- Dimensions
    HEIGHT = 35,

    -- Anchoring
    ANCHOR = "BOTTOMLEFT",
    OFFSET_Y = 0,

    -- Internal layout
    PADDING_H = 15,
    STAT_GAP = 30,

    -- Statistics to display
    STATS = {
        { id = "avgIlvl", label = "Avg iLvl:", format = "%d" },
        { id = "upgradesAvail", label = "Upgrades:", format = "%d slots" },
        { id = "wishlisted", label = "Wishlisted:", format = "%d items" },
    },

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.06, g = 0.06, b = 0.06, a = 0.95 },
    BORDER_COLOR = { r = 0.3, g = 0.3, b = 0.3, a = 1 },

    -- Text colors
    LABEL_COLOR = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
    VALUE_COLOR = { r = 1, g = 0.84, b = 0, a = 1 },  -- Gold
}

-- PAYLOAD: Main Footer Creation
function Journal:CreateArmoryFooter()
    local container = self.armoryUI.container
    local paperdoll = self.armoryUI.paperdoll
    local C = HopeAddon.Constants.ARMORY_FOOTER

    if not self.armoryUI.footer then
        local footer = CreateFrame("Frame", "HopeArmoryFooter", container, "BackdropTemplate")
        footer:SetHeight(C.HEIGHT)
        footer:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
        footer:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)

        footer:SetBackdrop(C.BACKDROP)
        footer:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        footer:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        -- Create stat displays
        footer.stats = {}
        local xOffset = C.PADDING_H

        for _, statConfig in ipairs(C.STATS) do
            -- Label
            local label = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("LEFT", footer, "LEFT", xOffset, 0)
            label:SetText(statConfig.label)
            label:SetTextColor(C.LABEL_COLOR.r, C.LABEL_COLOR.g, C.LABEL_COLOR.b, C.LABEL_COLOR.a)

            -- Value (positioned after label)
            local value = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            value:SetPoint("LEFT", label, "RIGHT", 4, 0)
            value:SetText("--")
            value:SetTextColor(C.VALUE_COLOR.r, C.VALUE_COLOR.g, C.VALUE_COLOR.b, C.VALUE_COLOR.a)

            footer.stats[statConfig.id] = {
                label = label,
                value = value,
                format = statConfig.format,
            }

            xOffset = xOffset + label:GetStringWidth() + 50 + C.STAT_GAP
        end

        self.armoryUI.footer = footer
    end

    self.armoryUI.footer:Show()
    return self.armoryUI.footer
end

-- PAYLOAD: Footer Update
function Journal:UpdateArmoryFooter()
    local footer = self.armoryUI.footer
    if not footer then return end

    local stats = self:CalculateArmoryStats()

    for statId, statDisplay in pairs(footer.stats) do
        local value = stats[statId] or 0
        statDisplay.value:SetText(string.format(statDisplay.format, value))
    end
end
```

---

## 23.18 Upgrade Card Pool Specification

```lua
--[[
    POOL: armoryPools.upgradeCard
    PURPOSE: Pooled frames for individual upgrade recommendations
    PARENT: armoryUI.detailPanel.scrollContent (on acquire)
    POOL_TYPE: HopeAddon.FramePool
]]

C.ARMORY_UPGRADE_CARD = {
    -- Dimensions
    HEIGHT = 75,
    WIDTH = "MATCH_PARENT",

    -- Margins
    PADDING = 10,
    ICON_SIZE = 44,

    -- Layout offsets
    ICON_OFFSET = { x = 10, y = -15 },
    RANK_OFFSET = { x = 10, y = -8 },
    NAME_OFFSET = { x = 64, y = -12 },
    ILEVEL_OFFSET = { x = 64, y = -28 },
    STATS_OFFSET = { x = 64, y = -44 },
    SOURCE_OFFSET = { x = 64, y = -60 },
    UPGRADE_BADGE_OFFSET = { x = -10, y = -12 },
    WISHLIST_OFFSET = { x = -10, y = -45 },

    -- Rank badge (BEST, ALT)
    RANK_BADGE_WIDTH = 45,
    RANK_BADGE_HEIGHT = 18,
    RANK_COLORS = {
        BEST = { bg = { r = 1, g = 0.84, b = 0 }, text = { r = 0.1, g = 0.1, b = 0.1 } },
        ALT = { bg = { r = 0.5, g = 0.5, b = 0.5 }, text = { r = 1, g = 1, b = 1 } },
    },

    -- Upgrade amount badge
    UPGRADE_BADGE_WIDTH = 50,
    UPGRADE_BADGE_HEIGHT = 20,

    -- Wishlist heart
    WISHLIST_SIZE = 24,
    WISHLIST_ICON_ON = "Interface\\ICONS\\INV_ValentinesCard02",
    WISHLIST_ICON_OFF = "Interface\\ICONS\\INV_ValentinesCard01",

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    BG_COLOR = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
    BG_COLOR_BEST = { r = 0.15, g = 0.12, b = 0.05, a = 0.9 },
    BORDER_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 1 },
    BORDER_COLOR_BEST = { r = 1, g = 0.84, b = 0, a = 1 },
}

-- PAYLOAD: Upgrade Card Initialization (called by pool on first acquire)
function Journal:InitializeUpgradeCard(card)
    local C = HopeAddon.Constants.ARMORY_UPGRADE_CARD

    card:SetHeight(C.HEIGHT)
    card:SetBackdrop(C.BACKDROP)
    card:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
    card:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

    -- Rank badge (BEST / ALT)
    local rankBadge = CreateFrame("Frame", nil, card)
    rankBadge:SetSize(C.RANK_BADGE_WIDTH, C.RANK_BADGE_HEIGHT)
    rankBadge:SetPoint("TOPLEFT", card, "TOPLEFT", C.RANK_OFFSET.x, C.RANK_OFFSET.y)
    card.rankBadge = rankBadge

    local rankBg = rankBadge:CreateTexture(nil, "BACKGROUND")
    rankBg:SetAllPoints()
    rankBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    rankBadge.bg = rankBg

    local rankText = rankBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankText:SetPoint("CENTER")
    rankText:SetFont(rankText:GetFont(), 10, "OUTLINE")
    rankBadge.text = rankText

    -- Item icon
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    icon:SetPoint("TOPLEFT", card, "TOPLEFT", C.ICON_OFFSET.x, C.ICON_OFFSET.y)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    card.icon = icon

    -- Quality border
    local qualityBorder = card:CreateTexture(nil, "OVERLAY")
    qualityBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
    qualityBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
    qualityBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    card.qualityBorder = qualityBorder

    -- Item name
    local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", card, "TOPLEFT", C.NAME_OFFSET.x, C.NAME_OFFSET.y)
    nameText:SetPoint("RIGHT", card, "RIGHT", -70, 0)
    nameText:SetJustifyH("LEFT")
    card.nameText = nameText

    -- Item level
    local iLevelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iLevelText:SetPoint("TOPLEFT", card, "TOPLEFT", C.ILEVEL_OFFSET.x, C.ILEVEL_OFFSET.y)
    iLevelText:SetTextColor(0.7, 0.7, 0.7, 1)
    card.iLevelText = iLevelText

    -- Stats
    local statsText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsText:SetPoint("TOPLEFT", card, "TOPLEFT", C.STATS_OFFSET.x, C.STATS_OFFSET.y)
    statsText:SetPoint("RIGHT", card, "RIGHT", -70, 0)
    statsText:SetJustifyH("LEFT")
    statsText:SetTextColor(0.6, 0.6, 0.6, 1)
    card.statsText = statsText

    -- Source info
    local sourceText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceText:SetPoint("TOPLEFT", card, "TOPLEFT", C.SOURCE_OFFSET.x, C.SOURCE_OFFSET.y)
    sourceText:SetTextColor(0.5, 0.5, 0.5, 1)
    card.sourceText = sourceText

    -- Upgrade amount badge (right side)
    local upgradeBadge = CreateFrame("Frame", nil, card)
    upgradeBadge:SetSize(C.UPGRADE_BADGE_WIDTH, C.UPGRADE_BADGE_HEIGHT)
    upgradeBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", C.UPGRADE_BADGE_OFFSET.x, C.UPGRADE_BADGE_OFFSET.y)
    card.upgradeBadge = upgradeBadge

    local upgradeBg = upgradeBadge:CreateTexture(nil, "BACKGROUND")
    upgradeBg:SetAllPoints()
    upgradeBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    upgradeBadge.bg = upgradeBg

    local upgradeArrow = upgradeBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    upgradeArrow:SetPoint("LEFT", upgradeBadge, "LEFT", 3, 0)
    upgradeArrow:SetText("▲")
    upgradeBadge.arrow = upgradeArrow

    local upgradeValue = upgradeBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    upgradeValue:SetPoint("LEFT", upgradeArrow, "RIGHT", 2, 0)
    upgradeBadge.value = upgradeValue

    -- Wishlist button (heart)
    local wishlistBtn = CreateFrame("Button", nil, card)
    wishlistBtn:SetSize(C.WISHLIST_SIZE, C.WISHLIST_SIZE)
    wishlistBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", C.WISHLIST_OFFSET.x, C.WISHLIST_OFFSET.y)
    card.wishlistBtn = wishlistBtn

    local wishlistIcon = wishlistBtn:CreateTexture(nil, "ARTWORK")
    wishlistIcon:SetAllPoints()
    wishlistIcon:SetTexture(C.WISHLIST_ICON_OFF)
    wishlistBtn.iconTex = wishlistIcon

    wishlistBtn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        self:ToggleArmoryWishlist(card.itemData)
    end)

    wishlistBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(wishlistBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText(card.isWishlisted and "Remove from Wishlist" or "Add to Wishlist")
        GameTooltip:Show()
    end)

    wishlistBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Click handler for entire card (show item tooltip)
    card:SetScript("OnEnter", function()
        if card.itemData and card.itemData.itemId then
            GameTooltip:SetOwner(card, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. card.itemData.itemId)
            GameTooltip:Show()
        end
    end)

    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Data storage
    card.itemData = nil
    card.isWishlisted = false
    card.isBest = false
end

-- PAYLOAD: Upgrade Card Reset (called by pool on release)
function Journal:ResetUpgradeCard(card)
    card:Hide()
    card:ClearAllPoints()
    card.itemData = nil
    card.isWishlisted = false
    card.isBest = false

    -- Reset visuals to default
    local C = HopeAddon.Constants.ARMORY_UPGRADE_CARD
    card:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
    card:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)
    card.wishlistBtn.iconTex:SetTexture(C.WISHLIST_ICON_OFF)
end

-- PAYLOAD: Populate Upgrade Card with Data
function Journal:PopulateUpgradeCard(card, itemData, rank, iLvlDiff)
    local C = HopeAddon.Constants.ARMORY_UPGRADE_CARD

    card.itemData = itemData
    card.isBest = (rank == "BEST")

    -- Rank badge
    local rankColors = C.RANK_COLORS[rank] or C.RANK_COLORS.ALT
    card.rankBadge.bg:SetVertexColor(rankColors.bg.r, rankColors.bg.g, rankColors.bg.b, 1)
    card.rankBadge.text:SetText(rank)
    card.rankBadge.text:SetTextColor(rankColors.text.r, rankColors.text.g, rankColors.text.b, 1)

    -- Item icon
    card.icon:SetTexture(itemData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

    -- Quality border
    local r, g, b = GetItemQualityColor(itemData.quality or 3)
    card.qualityBorder:SetVertexColor(r, g, b, 1)

    -- Item name (colored by quality)
    card.nameText:SetText(itemData.name or "Unknown Item")
    card.nameText:SetTextColor(r, g, b, 1)

    -- Item level and source
    card.iLevelText:SetText("iLvl " .. (itemData.iLvl or "?") .. " | " .. (itemData.source or "Unknown"))

    -- Stats
    card.statsText:SetText(itemData.stats or "")

    -- Source type
    card.sourceText:SetText(itemData.sourceType or "")

    -- Upgrade badge
    if iLvlDiff and iLvlDiff > 0 then
        local upgradeColor = self:GetUpgradeColor(iLvlDiff)
        card.upgradeBadge.bg:SetVertexColor(upgradeColor.r * 0.3, upgradeColor.g * 0.3, upgradeColor.b * 0.3, 0.9)
        card.upgradeBadge.arrow:SetTextColor(upgradeColor.r, upgradeColor.g, upgradeColor.b, 1)
        card.upgradeBadge.value:SetText("+" .. iLvlDiff)
        card.upgradeBadge.value:SetTextColor(upgradeColor.r, upgradeColor.g, upgradeColor.b, 1)
        card.upgradeBadge:Show()
    else
        card.upgradeBadge:Hide()
    end

    -- Wishlist state
    card.isWishlisted = self:IsItemWishlisted(itemData.itemId)
    card.wishlistBtn.iconTex:SetTexture(card.isWishlisted and C.WISHLIST_ICON_ON or C.WISHLIST_ICON_OFF)

    -- Background color (gold tint for BEST)
    if card.isBest then
        card:SetBackdropColor(C.BG_COLOR_BEST.r, C.BG_COLOR_BEST.g, C.BG_COLOR_BEST.b, C.BG_COLOR_BEST.a)
        card:SetBackdropBorderColor(C.BORDER_COLOR_BEST.r, C.BORDER_COLOR_BEST.g, C.BORDER_COLOR_BEST.b, C.BORDER_COLOR_BEST.a)
    else
        card:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        card:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)
    end

    card:Show()
end
```

---

## 23.19 Section Header Pool Specification

```lua
--[[
    POOL: armoryPools.sectionHeader
    PURPOSE: Pooled collapsible section headers
    PARENT: armoryUI.detailPanel.scrollContent (on acquire)
    POOL_TYPE: HopeAddon.FramePool
]]

C.ARMORY_SECTION_HEADER = {
    -- Dimensions
    HEIGHT = 28,
    WIDTH = "MATCH_PARENT",

    -- Layout
    PADDING_H = 10,
    ARROW_SIZE = 16,
    ICON_SIZE = 20,
    GAP = 8,

    -- Arrow textures
    ARROW_EXPANDED = "Interface\\Buttons\\UI-MinusButton-Up",
    ARROW_COLLAPSED = "Interface\\Buttons\\UI-PlusButton-Up",

    -- Text
    FONT = "GameFontNormal",
    COUNT_FONT = "GameFontNormalSmall",
    COUNT_COLOR = { r = 0.6, g = 0.6, b = 0.6, a = 1 },

    -- Appearance
    BACKDROP = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = nil,
    },
    BG_ALPHA = 0.2,
}

-- PAYLOAD: Section Header Initialization
function Journal:InitializeSectionHeader(header)
    local C = HopeAddon.Constants.ARMORY_SECTION_HEADER

    header:SetHeight(C.HEIGHT)
    header:SetBackdrop(C.BACKDROP)
    header:EnableMouse(true)

    -- Collapse arrow
    local arrow = header:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(C.ARROW_SIZE, C.ARROW_SIZE)
    arrow:SetPoint("LEFT", header, "LEFT", C.PADDING_H, 0)
    arrow:SetTexture(C.ARROW_EXPANDED)
    header.arrow = arrow

    -- Section icon (optional)
    local sectionIcon = header:CreateTexture(nil, "ARTWORK")
    sectionIcon:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    sectionIcon:SetPoint("LEFT", arrow, "RIGHT", C.GAP, 0)
    header.sectionIcon = sectionIcon

    -- Title text
    local title = header:CreateFontString(nil, "OVERLAY", C.FONT)
    title:SetPoint("LEFT", sectionIcon, "RIGHT", C.GAP, 0)
    header.title = title

    -- Item count
    local count = header:CreateFontString(nil, "OVERLAY", C.COUNT_FONT)
    count:SetPoint("LEFT", title, "RIGHT", 6, 0)
    count:SetTextColor(C.COUNT_COLOR.r, C.COUNT_COLOR.g, C.COUNT_COLOR.b, C.COUNT_COLOR.a)
    header.count = count

    -- Data storage
    header.sectionId = nil
    header.isExpanded = true
    header.sectionColor = nil

    -- Click handler
    header:SetScript("OnMouseDown", function()
        HopeAddon.Sounds:PlayClick()
        self:ToggleArmorySection(header.sectionId)
    end)

    -- Hover effect
    header:SetScript("OnEnter", function()
        local color = header.sectionColor or HopeAddon.colors.GOLD_BRIGHT
        header:SetBackdropColor(color.r, color.g, color.b, C.BG_ALPHA + 0.1)
    end)

    header:SetScript("OnLeave", function()
        local color = header.sectionColor or HopeAddon.colors.GOLD_BRIGHT
        header:SetBackdropColor(color.r, color.g, color.b, C.BG_ALPHA)
    end)
end

-- PAYLOAD: Section Header Reset
function Journal:ResetSectionHeader(header)
    header:Hide()
    header:ClearAllPoints()
    header.sectionId = nil
    header.isExpanded = true
    header.sectionColor = nil
end

-- PAYLOAD: Populate Section Header
function Journal:PopulateSectionHeader(header, sectionConfig, itemCount)
    local C = HopeAddon.Constants.ARMORY_SECTION_HEADER

    header.sectionId = sectionConfig.id
    header.sectionColor = HopeAddon.colors[sectionConfig.color]
    header.isExpanded = self.armoryState.expandedSections[sectionConfig.id] ~= false

    -- Set background color
    local color = header.sectionColor or HopeAddon.colors.GOLD_BRIGHT
    header:SetBackdropColor(color.r, color.g, color.b, C.BG_ALPHA)

    -- Arrow state
    header.arrow:SetTexture(header.isExpanded and C.ARROW_EXPANDED or C.ARROW_COLLAPSED)

    -- Title (colored by section)
    header.title:SetText(sectionConfig.label)
    header.title:SetTextColor(color.r, color.g, color.b, 1)

    -- Item count
    header.count:SetText("(" .. (itemCount or 0) .. ")")

    header:Show()
end
```

---

## 23.20 Stat Row Pool Specification

```lua
--[[
    POOL: armoryPools.statRow
    PURPOSE: Pooled rows for stat comparison (in upgrade cards)
    PARENT: Set on acquire (usually upgrade card)
    POOL_TYPE: HopeAddon.FramePool
]]

C.ARMORY_STAT_ROW = {
    HEIGHT = 16,
    WIDTH = "MATCH_PARENT",

    -- Layout
    STAT_NAME_WIDTH = 80,
    CURRENT_WIDTH = 50,
    NEW_WIDTH = 50,
    DIFF_WIDTH = 50,
    GAP = 4,

    -- Colors
    POSITIVE_COLOR = { r = 0.2, g = 0.8, b = 0.2 },  -- Green
    NEGATIVE_COLOR = { r = 0.8, g = 0.2, b = 0.2 },  -- Red
    NEUTRAL_COLOR = { r = 0.7, g = 0.7, b = 0.7 },   -- Grey
}

-- Initialization and reset follow same pattern as other pools
```

---

## 23.21 Source Tag Pool Specification

```lua
--[[
    POOL: armoryPools.sourceTag
    PURPOSE: Pooled source type badges (Raid, Heroic, Badge, Rep, Crafted)
    PARENT: Set on acquire
    POOL_TYPE: HopeAddon.FramePool
]]

C.ARMORY_SOURCE_TAG = {
    HEIGHT = 18,
    WIDTH = 70,

    PADDING_H = 6,
    ICON_SIZE = 14,
    GAP = 4,

    -- Source type configurations
    TYPES = {
        raid    = { label = "Raid",    color = "EPIC_PURPLE",   icon = "Interface\\ICONS\\INV_Misc_Head_Dragon_01" },
        heroic  = { label = "Heroic",  color = "SKY_BLUE",      icon = "Interface\\ICONS\\Spell_Holy_SealOfBlood" },
        badge   = { label = "Badge",   color = "GOLD_BRIGHT",   icon = "Interface\\ICONS\\Spell_Holy_ChampionsBond" },
        rep     = { label = "Rep",     color = "FEL_GREEN",     icon = "Interface\\ICONS\\INV_Misc_Token_argentdawn" },
        crafted = { label = "Crafted", color = "BRONZE",        icon = "Interface\\ICONS\\Trade_BlackSmithing" },
    },
}
```

---

## 23.22 Wishlist Button Pool Specification

```lua
--[[
    POOL: armoryPools.wishlistBtn
    PURPOSE: Pooled wishlist heart toggle buttons
    PARENT: Set on acquire (usually upgrade card)
    POOL_TYPE: HopeAddon.FramePool
]]

C.ARMORY_WISHLIST_BUTTON = {
    SIZE = 24,

    ICON_ON = "Interface\\ICONS\\INV_ValentinesCard02",   -- Red heart
    ICON_OFF = "Interface\\ICONS\\INV_ValentinesCard01",  -- Grey heart

    -- Tooltip text
    TOOLTIP_ADD = "Add to Wishlist",
    TOOLTIP_REMOVE = "Remove from Wishlist",
}
```

---

# PART 4: PAYLOAD-STYLE IMPLEMENTATION GUIDE

---

## 24. Implementation Payloads (Copy-Paste Ready)

### 24.1 PAYLOAD 1: Constants Setup

**Target File:** `Core/Constants.lua`
**Insert After:** Last constants definition

```lua
--------------------------------------------------------------------------------
-- ARMORY TAB CONSTANTS
--------------------------------------------------------------------------------

-- Main container
C.ARMORY_CONTAINER = {
    WIDTH = "MATCH_PARENT",
    HEIGHT = "DYNAMIC",
    MIN_HEIGHT = 600,
    PADDING = 15,
    MARGIN_TOP = 0,
    MARGIN_BOTTOM = 20,
}

-- Tier bar (paste C.ARMORY_TIER_BAR from section 23.3)
-- Tier buttons (paste C.ARMORY_TIER_BUTTON from section 23.4)
-- Spec dropdown (paste C.ARMORY_SPEC_DROPDOWN from section 23.5)
-- Paperdoll (paste C.ARMORY_PAPERDOLL from section 23.6)
-- Model frame (paste C.ARMORY_MODEL_FRAME from section 23.7)
-- Slots container (paste C.ARMORY_SLOTS_CONTAINER from section 23.8)
-- Slot button (paste C.ARMORY_SLOT_BUTTON from section 23.9)
-- Detail panel (paste C.ARMORY_DETAIL_PANEL from section 23.10)
-- All remaining constants from sections 23.11-23.22
```

### 24.2 PAYLOAD 2: Journal.lua State Initialization

**Target File:** `Journal/Journal.lua`
**Insert After:** `Journal.transmogUI = {}` or similar UI namespace declarations

```lua
--------------------------------------------------------------------------------
-- ARMORY TAB STATE
--------------------------------------------------------------------------------

Journal.armoryUI = {
    container = nil,
    tierBar = nil,
    tierButtons = {},
    specDropdown = nil,
    paperdoll = nil,
    modelFrame = nil,
    slotsContainer = nil,
    slotButtons = {},
    detailPanel = nil,
    equippedCard = nil,
    footer = nil,
}

Journal.armoryState = {
    selectedTier = 4,
    selectedSpec = nil,
    selectedSlot = nil,
    expandedSections = {},
    slotStatuses = {},
    wishlist = {},
}

Journal.armoryPools = {
    upgradeCard = nil,
    sectionHeader = nil,
    statRow = nil,
    sourceTag = nil,
    wishlistBtn = nil,
}
```

### 24.3 PAYLOAD 3: Tab Registration

**Target File:** `Journal/Journal.lua`
**Location:** Tab registration section (look for `RegisterTab` calls)

```lua
-- Register Armory tab (replace or add alongside Transmog)
self:RegisterTab("armory", "INV_Chest_Chain_09", function()
    self:PopulateArmory()
end)
```

### 24.4 PAYLOAD 4: Main Entry Point

**Target File:** `Journal/Journal.lua`
**Insert After:** Other `Populate*` functions

```lua
--------------------------------------------------------------------------------
-- ARMORY TAB POPULATION
--------------------------------------------------------------------------------

function Journal:PopulateArmory()
    local scrollContainer = self.mainFrame.scrollContainer

    -- Clear existing content
    scrollContainer:ClearEntries(self.containerPool)

    -- Create pools if needed
    if not self.armoryPools.upgradeCard then
        self:CreateArmoryPools()
    end

    -- Create container structure
    self:CreateArmoryContainer()

    -- Load current equipment and calculate upgrade status
    self:RefreshArmorySlotData()

    -- Update footer stats
    self:UpdateArmoryFooter()
end
```

### 24.5 PAYLOAD 5: Container Creation Functions

Paste all `Create*` functions from sections 23.2-23.17 into `Journal/Journal.lua`.

### 24.6 PAYLOAD 6: Pool Initialization

Paste pool creation and initialization functions from sections 23.18-23.22 into `Journal/Journal.lua`.

### 24.7 PAYLOAD 7: Event Handlers

```lua
--------------------------------------------------------------------------------
-- ARMORY EVENT HANDLERS
--------------------------------------------------------------------------------

function Journal:OnArmorySlotClick(slotName)
    -- Deselect previous slot
    if self.armoryState.selectedSlot then
        local prevBtn = self.armoryUI.slotButtons[self.armoryState.selectedSlot]
        if prevBtn then
            prevBtn.isSelected = false
            self:UpdateArmorySlotVisual(prevBtn)
        end
    end

    -- Select new slot
    self.armoryState.selectedSlot = slotName
    local newBtn = self.armoryUI.slotButtons[slotName]
    if newBtn then
        newBtn.isSelected = true
        self:UpdateArmorySlotVisual(newBtn)
    end

    -- Populate detail panel
    self:PopulateArmorySlotDetail(slotName)
end

function Journal:OnArmorySlotEnter(btn)
    -- Show tooltip with equipped item
    if btn.equippedItem and btn.equippedItem.itemId then
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. btn.equippedItem.itemId)
        GameTooltip:Show()
    end
end

function Journal:OnArmorySlotLeave(btn)
    GameTooltip:Hide()
end

function Journal:SelectArmoryTier(tier)
    local prevTier = self.armoryState.selectedTier
    self.armoryState.selectedTier = tier

    -- Update tier button visuals
    for t, btn in pairs(self.armoryUI.tierButtons) do
        local state = (t == tier) and "active" or "inactive"
        self:SetTierButtonState(btn, state)
    end

    -- Refresh recommendations if slot selected
    if self.armoryState.selectedSlot then
        self:PopulateArmorySlotDetail(self.armoryState.selectedSlot)
    end

    -- Save preference
    HopeAddon.charDb.armory.selectedTier = tier
end

function Journal:ToggleArmorySection(sectionId)
    local isExpanded = self.armoryState.expandedSections[sectionId]
    self.armoryState.expandedSections[sectionId] = not isExpanded

    -- Refresh detail panel to reflect change
    if self.armoryState.selectedSlot then
        self:PopulateArmorySlotDetail(self.armoryState.selectedSlot)
    end
end

function Journal:ToggleArmoryWishlist(itemData)
    if not itemData or not itemData.itemId then return end

    local itemId = itemData.itemId
    if self.armoryState.wishlist[itemId] then
        self.armoryState.wishlist[itemId] = nil
    else
        self.armoryState.wishlist[itemId] = true
    end

    -- Save to character data
    HopeAddon.charDb.armory.wishlist = self.armoryState.wishlist

    -- Update visuals
    self:RefreshArmorySlotData()
    self:UpdateArmoryFooter()
end

function Journal:IsItemWishlisted(itemId)
    return self.armoryState.wishlist[itemId] == true
end

function Journal:OnArmoryFooterButtonClick(buttonId)
    if buttonId == "addWishlist" then
        -- Add all "BEST" items to wishlist
        -- Implementation depends on current selection
    elseif buttonId == "close" then
        self.armoryState.selectedSlot = nil
        self:ClearArmoryDetailPanel()
    end
end
```

### 24.8 PAYLOAD 8: Core.lua Defaults

**Target File:** `Core/Core.lua`
**Location:** `CHAR_DATA_DEFAULTS` section

```lua
-- Add to character data defaults
armory = {
    selectedTier = 4,
    selectedSpec = nil,
    wishlist = {},
    expandedSections = {},
},
```

---

## 25. Implementation Order

1. **Constants First** - Add all `C.ARMORY_*` constants to `Constants.lua`
2. **State Variables** - Add `armoryUI`, `armoryState`, `armoryPools` to `Journal.lua`
3. **Defaults** - Add `armory` defaults to `Core.lua`
4. **Tab Registration** - Register armory tab
5. **Container Hierarchy** - Implement containers top-down (23.2 → 23.17)
6. **Frame Pools** - Implement pool init/reset functions (23.18 → 23.22)
7. **Event Handlers** - Add click/hover/toggle handlers
8. **Data Population** - Implement slot data refresh and detail population
9. **Polish** - Add animations, sounds, final adjustments

---

## 26. Testing Checklist

- [ ] Tab appears in journal navigation
- [ ] Tier buttons switch correctly (T4/T5/T6)
- [ ] Spec dropdown shows all 3 specs for current class
- [ ] All 17 slot buttons are visible and positioned
- [ ] Clicking slot shows detail panel with upgrade recommendations
- [ ] Wishlist toggle works and persists
- [ ] Footer stats update accurately
- [ ] Scroll works in detail panel
- [ ] Collapsible sections expand/collapse
- [ ] Model frame shows current character
- [ ] Slot buttons show correct upgrade indicators

---

## 27. Next Steps

1. **Review this plan** - Confirm all UI patterns are acceptable
2. **Create Constants** - Add `C.ARMORY` namespace first
3. **Build containers** - Start with empty frame hierarchy
4. **Add slot buttons** - Position all 17 slots
5. **Implement tier bar** - Tier selection + spec dropdown
6. **Add detail panel** - Expandable upgrade recommendations
7. **Populate data** - Research actual TBC Classic BiS items
8. **Polish** - Animations, sounds, final visual tweaks
