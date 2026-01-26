# Armory Popup Redesign Plan

## TBC 2.4.3 Compatibility Verification

### ✅ Confirmed Compatible APIs & Patterns

| API/Pattern | Status | Notes |
|-------------|--------|-------|
| `CreateFrame("Frame", name, parent, "BackdropTemplate")` | ✅ | Use `HopeAddon:CreateBackdropFrame()` wrapper for safety |
| `UIPanelScrollFrameTemplate` | ✅ | Used throughout codebase (Components.lua:718) |
| `HopeAddon.FramePool` | ✅ | Custom pooling system (FramePool.lua) |
| `SetBackdrop()` / `SetBackdropColor()` | ✅ | Via BackdropTemplateMixin or native |
| `GetItemInfo(itemId)` | ✅ | Returns nil if not cached, call twice |
| `DressUpModel:TryOn(itemLink)` | ✅ | Works in TBC Classic |
| `GameTooltip:SetOwner()` / `SetText()` | ✅ | Standard tooltip API |
| `UIDropDownMenu_*` | ✅ | Native TBC dropdown system |

### ✅ Confirmed Compatible Assets (TBC 2.4.3)

| Asset Type | Path | Used For |
|------------|------|----------|
| Background | `Interface\\DialogFrame\\UI-DialogBox-Background-Dark` | Popup backdrop |
| Border | `Interface\\DialogFrame\\UI-DialogBox-Gold-Border` | Gold borders |
| Border | `Interface\\Tooltips\\UI-Tooltip-Border` | Item row borders |
| Highlight | `Interface\\Buttons\\ButtonHilight-Square` | Hover effects |
| Star | `Interface\\RAIDFRAME\\ReadyCheck-Ready` | BiS indicator |
| Arrow | `Interface\\BUTTONS\\UI-MicroStream-Green` | Upgrade indicators |
| Solid | `Interface\\BUTTONS\\WHITE8X8` | Button backgrounds |

### ⚠️ API Caveats

1. **GetItemInfo caching** - May return nil on first call. Always call twice or use `ItemCacheFrame:OnEvent("GET_ITEM_INFO_RECEIVED")`
2. **Model:TryOn** - Requires valid item link format `"item:itemId"` or `"item:itemId:0:0:0:0:0:0:0"`
3. **Frame pooling** - Must call `:Release()` before `:Hide()` to return to pool properly

---

## Frame Pooling Requirements

### New Pools to Create

| Pool Name | Frame Type | Purpose | Reset Function |
|-----------|------------|---------|----------------|
| `armoryBisCardPool` | Frame + BackdropTemplate | BiS showcase cards | Hide, ClearAllPoints, clear data |
| `armoryItemRowPool` | Button + BackdropTemplate | Alternative item rows | Hide, ClearAllPoints, wipe data |
| `armoryGroupHeaderPool` | Frame | Collapsible group headers | Hide, ClearAllPoints, reset state |
| `armoryFilterBtnPool` | Button + BackdropTemplate | Filter bar buttons | Hide, ClearAllPoints, reset selection |

### Pool Implementation Pattern (from Journal.lua)

```lua
-- Create pool in OnEnable
function Journal:CreateArmoryItemRowPool()
    local createFunc = function()
        local row = HopeAddon:CreateBackdropFrame("Button", nil, UIParent, nil)
        row:SetHeight(C.ARMORY_GEAR_POPUP.COMPACT_ITEM_HEIGHT)
        -- Setup static elements (icon, name, stats, source, preview button)
        return row
    end

    local resetFunc = function(row)
        row:Hide()
        row:ClearAllPoints()
        row:SetParent(nil)
        row.itemData = nil
        row.itemId = nil
        if row.icon then row.icon:SetTexture(nil) end
        if row.name then row.name:SetText("") end
        if row.stats then row.stats:SetText("") end
        if row.source then row.source:SetText("") end
    end

    self.armoryItemRowPool = HopeAddon.FramePool:NewNamed("ArmoryItemRows", createFunc, resetFunc)
end

-- Destroy in OnDisable
if self.armoryItemRowPool then
    self.armoryItemRowPool:Destroy()
    self.armoryItemRowPool = nil
end
```

### Pool Lifecycle

```
OnEnable
    └─ CreateArmoryItemRowPool()
    └─ CreateArmoryGroupHeaderPool()
    └─ CreateArmoryFilterBtnPool()
    └─ CreateArmoryBisCardPool()

ShowArmoryGearPopup(slotName)
    └─ PopulateArmoryGearPopup(slotName)
        └─ ReleaseAll existing rows
        └─ Acquire new rows from pool
        └─ Configure with item data

HideArmoryGearPopup()
    └─ ReleaseAll rows back to pool

OnDisable
    └─ Destroy all pools
```

---

## Current State Analysis

### Problems Identified

1. **Congested Layout** - All items crammed into a single column, 300px width is restrictive
2. **No Category Organization** - BiS and alternatives mixed without clear visual hierarchy
3. **Limited Space** - Current 300x420px popup feels cramped with 5+ items
4. **No Filtering/Sorting** - Can't filter by source type (dungeon, raid, crafted, etc.)
5. **Preview Feature Hidden** - Small "Preview" button easily missed, buried in row
6. **No Visual Grouping** - Items from same source (e.g., Karazhan drops) not grouped
7. **Poor Scanability** - Dense text, hard to quickly compare items

### Current Dimensions
- **Width:** 300px (too narrow)
- **Max Height:** 420px
- **Item Row:** 64px height
- **Max Alternatives:** 5 items

---

## Proposed Redesign: "Gear Advisor Panel"

### Design Goals

1. **Larger Canvas** - Expand to 480x520px for better organization
2. **Visual Hierarchy** - Clear sections for BiS vs Alternatives
3. **Source Grouping** - Group alternatives by source type (Raid, Heroic, Crafted, Rep)
4. **Prominent Try-On** - Large preview button, one-click dressing room
5. **Scroll Container** - Proper scroll frame for long lists
6. **Filter Bar** - Quick filters by source type

---

## New Layout Structure

```
┌──────────────────────────────────────────────────────────────────┐
│ [X]  HEAD UPGRADES                              Phase 1          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────── BEST IN SLOT ────────────────────────┐ │
│  │  ☆                                                          │ │
│  │  [ICON]  Warbringer Greathelm                 [TRY ON]      │ │
│  │          Epic | iLvl 120 | Karazhan                         │ │
│  │          +43 Str, +45 Sta, +32 Def Rating                   │ │
│  │          Prince Malchezaar - 18% Drop Rate                  │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ─────────────────── ALTERNATIVES (5) ──────────────────────     │
│  [All] [Raid] [Heroic] [Crafted] [Rep]           Sort: iLvl ▼   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  ▼ RAID DROPS (2)                                          │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │ [ICON] Faceguard of Determination    iLvl 115        │  │  │
│  │  │        Gruul's Lair - Gruul        [TRY ON]          │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │ [ICON] Helm of the Fallen Champion   iLvl 115        │  │  │
│  │  │        Karazhan - Chess Event      [TRY ON]          │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  │  ▼ HEROIC DROPS (2)                                        │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │ [ICON] Mok'Nathal Beast-Mask         iLvl 110        │  │  │
│  │  │        Heroic Blood Furnace        [TRY ON]          │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  │  ...                                                       │  │
│  │                                                            │  │
│  │  ▼ CRAFTED (1)                                             │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │ [ICON] Felsteel Helm                 iLvl 105        │  │  │
│  │  │        Blacksmithing (365)         [TRY ON]          │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Expand Popup Dimensions & Structure (2 hours)

**Goal:** Create larger, better organized container

**Constants Changes (Constants.lua):**
```lua
C.ARMORY_GEAR_POPUP = {
    WIDTH = 480,              -- Was 300 (+60%)
    MAX_HEIGHT = 520,         -- Was 420 (+24%)
    MIN_HEIGHT = 280,         -- New: minimum height

    -- Section heights
    HEADER_HEIGHT = 40,       -- Was 36
    BIS_SECTION_HEIGHT = 120, -- New: dedicated BiS section
    FILTER_BAR_HEIGHT = 32,   -- New: filter buttons row

    -- Item dimensions
    ITEM_HEIGHT = 54,         -- Was 64 (more compact)
    ITEM_GAP = 4,             -- Was 6 (tighter)
    COMPACT_ITEM_HEIGHT = 44, -- New: for grouped items

    -- Layout
    PADDING = 16,             -- Was 12
    SECTION_GAP = 12,         -- New: gap between sections

    MAX_ALTERNATIVES = 10,    -- Was 5 (more items visible)

    -- New: Source type grouping
    SOURCE_GROUPS = {
        raid = { order = 1, label = "Raid Drops", color = "HELLFIRE_RED" },
        heroic = { order = 2, label = "Heroic Drops", color = "ARCANE_PURPLE" },
        dungeon = { order = 3, label = "Normal Dungeons", color = "SKY_BLUE" },
        crafted = { order = 4, label = "Crafted", color = "FEL_GREEN" },
        badge = { order = 5, label = "Badge Rewards", color = "GOLD_BRIGHT" },
        reputation = { order = 6, label = "Reputation", color = "CENARION_GREEN" },
        quest = { order = 7, label = "Quest Rewards", color = "GOLD_BRIGHT" },
        world = { order = 8, label = "World Drops", color = "GREY" },
    },
}
```

**Journal.lua Changes:**
- Resize popup frame in `GetArmoryGearPopup()`
- Add proper scroll frame with `UIPanelScrollFrameTemplate`
- Create dedicated BiS section container
- Create alternatives section container

---

### Phase 2: BiS Item Showcase (1.5 hours)

**Goal:** Give the Best in Slot item prominent, featured display

**New Function: `CreateBisSectionContainer()`**
```
┌─────────────────────────────────────────────────────────┐
│  ☆ BEST IN SLOT                                        │
│  ┌───────────────────────────────────────────────────┐ │
│  │                                                   │ │
│  │  [64x64    ]  Warbringer Greathelm              │ │
│  │  [  ICON  ]   Epic Plate Helmet                 │ │
│  │  [        ]   Item Level 120                    │ │
│  │               +43 Str, +45 Sta, +32 Def         │ │
│  │                                                   │ │
│  │  Source: Prince Malchezaar (Karazhan)           │ │
│  │  Drop Rate: ~18%                                │ │
│  │                                          [TRY ON] │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Larger icon (64x64 vs 44x44)
- Gold border with subtle glow
- Full stat breakdown visible without hover
- Large, prominent "TRY ON" button (100x28px)
- Drop rate info if available
- BiS star indicator with pulsing glow

**Implementation:**
- `CreateBisItemCard(parent, itemData)` - New function
- Use `Effects:CreatePulsingGlow()` for star indicator
- Store BiS card reference for easy refresh

---

### Phase 3: Filter Bar Component (1.5 hours)

**Goal:** Quick-filter alternatives by source type

**Layout:**
```
─────────────────── ALTERNATIVES (8) ───────────────────
[All] [Raid] [Heroic] [Crafted] [Rep] [Badge]    Sort: ▼
```

**New Function: `CreateFilterBar(parent)`**
- Filter buttons with active state (gold border when selected)
- Count badges showing items per category
- "All" button shows all alternatives (default)
- Sort dropdown: "iLvl (High-Low)", "iLvl (Low-High)", "Source"

**State Tracking:**
```lua
self.armoryPopupState = {
    activeFilter = "all",  -- "all", "raid", "heroic", etc.
    sortOrder = "ilvl_desc",
}
```

**Filter Logic:**
```lua
function Journal:GetFilteredAlternatives(alternatives, filter, sort)
    local filtered = {}
    for _, item in ipairs(alternatives) do
        if filter == "all" or item.sourceType == filter then
            table.insert(filtered, item)
        end
    end
    -- Sort by ilvl descending by default
    table.sort(filtered, function(a, b)
        return (a.iLvl or 0) > (b.iLvl or 0)
    end)
    return filtered
end
```

---

### Phase 4: Grouped Alternatives with Collapsible Sections (2 hours)

**Goal:** Group items by source type with collapsible headers

**Layout Per Group:**
```
▼ RAID DROPS (2)
  ┌────────────────────────────────────────────┐
  │ [Icon] Item Name          iLvl 115 [TRY ON]│
  │        Source - Boss Name                  │
  └────────────────────────────────────────────┘
  ┌────────────────────────────────────────────┐
  │ [Icon] Item Name          iLvl 115 [TRY ON]│
  │        Source - Boss Name                  │
  └────────────────────────────────────────────┘
```

**New Functions:**
- `CreateSourceGroupHeader(parent, sourceType, itemCount)` - Collapsible header
- `CreateCompactItemRow(parent, itemData, yOffset)` - Smaller item card (44px height)
- `ToggleSourceGroup(sourceType)` - Expand/collapse group

**Collapsible State:**
```lua
self.armoryPopupState.expandedGroups = {
    raid = true,    -- Expanded by default
    heroic = true,
    crafted = false, -- Collapsed by default
    -- etc.
}
```

**Implementation Notes:**
- Use frame pooling for item rows (`itemRowPool`)
- Track group headers separately (`groupHeaderPool`)
- Recalculate scroll height on toggle

---

### Phase 5: Enhanced Try-On System (1.5 hours)

**Goal:** Make try-on prominent and add multi-item preview

**Features:**
1. **Large TRY ON Button** - 80x28px, bright green background
2. **Try All BiS Button** - In header, previews full BiS set for slot
3. **Preview Checkboxes** - Toggle items on/off model
4. **Reset Button** - Restore model to current equipped gear

**New UI Elements:**
```
Header: [X] HEAD UPGRADES                [Try All BiS] [Reset]
```

**Try-On Button Styling:**
```lua
local tryOnBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
tryOnBtn:SetSize(80, 28)
tryOnBtn:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
})
-- Green background for try-on
tryOnBtn:SetBackdropColor(0.2, 0.6, 0.2, 1)
tryOnBtn:SetBackdropBorderColor(0.8, 0.7, 0.2, 1)
```

**New Functions:**
- `Journal:TryOnItem(itemData)` - Preview single item
- `Journal:TryOnBisSet(slotName)` - Preview full BiS for this slot type
- `Journal:ResetModelToEquipped()` - Reset to current gear

---

### Phase 6: Polish & Animation (1 hour)

**Goal:** Add visual polish and smooth animations

**Animations:**
1. **Popup Slide-In** - Slide from anchor direction (150ms)
2. **Filter Transition** - Fade items when filter changes (100ms)
3. **Group Expand/Collapse** - Smooth height animation (200ms)
4. **Try-On Confirmation** - Brief flash on model when item applied

**Sound Effects:**
- Filter click: `PlayClick()`
- Group expand: `PlayClick()`
- Try-on success: `PlayClick()` + item equip sound
- Hover over item: `PlayHover()`

**Visual Polish:**
- Gradient dividers between sections
- Subtle inner shadow on BiS card
- Quality-colored left border on item rows
- Hover: brighten by 20% + gold border

---

## File Changes Summary

### Constants.lua (~100 lines added/modified)
- `ARMORY_GEAR_POPUP` - New dimensions and configuration
- `ARMORY_SOURCE_GROUPS` - Source type definitions
- `ARMORY_POPUP_FILTERS` - Filter definitions

### Journal.lua (~400 lines added/modified)
- `GetArmoryGearPopup()` - Complete rewrite
- `ShowArmoryGearPopup()` - Update positioning for larger popup
- `PopulateArmoryGearPopup()` - New section-based population
- `CreateBisItemCard()` - NEW: Featured BiS display
- `CreateFilterBar()` - NEW: Filter/sort controls
- `CreateSourceGroupHeader()` - NEW: Collapsible headers
- `CreateCompactItemRow()` - NEW: Smaller alternative rows
- `GetFilteredAlternatives()` - NEW: Filter/sort logic
- `ToggleSourceGroup()` - NEW: Expand/collapse handler
- `TryOnItem()` - ENHANCED: Better feedback
- `TryOnBisSet()` - NEW: Preview full set
- `ResetModelToEquipped()` - NEW: Reset preview

### Components.lua (~50 lines added)
- `CreateFilterButton()` - NEW: Reusable filter button component
- `CreateSortDropdown()` - NEW: Sort option dropdown

---

## Positioning Logic Update

Since the popup is now larger (480px wide), positioning needs adjustment:

```lua
POSITION_OFFSETS = {
    -- Left column: popup to RIGHT, but check screen bounds
    head      = { side = "RIGHT", x = 8, y = 0, fallback = "BOTTOM" },
    -- Right column: popup to LEFT
    hands     = { side = "LEFT", x = -8, y = 0, fallback = "BOTTOM" },
    -- Bottom row: popup ABOVE, centered
    mainhand  = { side = "TOP", x = 0, y = 8, fallback = "RIGHT" },
}

-- Screen bounds check in ShowArmoryGearPopup():
local screenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
local popupRight = anchorBtn:GetRight() + C.WIDTH
if popupRight > screenWidth and posInfo.fallback then
    -- Use fallback position
end
```

---

## Data Structure Enhancement

To support the new features, item data needs optional fields:

```lua
{
    -- Existing fields
    id = 29011,
    name = "Warbringer Greathelm",
    icon = "INV_Helmet_70",
    quality = "epic",
    iLvl = 120,
    stats = "+43 Str, +45 Sta, +32 Def",
    source = "Karazhan",
    sourceType = "raid",

    -- New optional fields for enhanced display
    sourceDetail = "Prince Malchezaar",  -- Boss name
    dropRate = 18,                       -- Percentage (if known)
    slot = "head",                       -- Equipment slot
    armorType = "Plate",                 -- Armor class
    statPriority = "tank",               -- Stat weighting hint
    prerequisites = nil,                 -- Attunement/rep requirements
}
```

---

## Testing Checklist

- [ ] Popup opens at correct size (480x520)
- [ ] BiS section shows featured card with large icon
- [ ] Filter buttons filter alternatives correctly
- [ ] Sort dropdown sorts by iLvl
- [ ] Source groups collapse/expand
- [ ] Try-On button previews item on model
- [ ] "Try All BiS" previews full set
- [ ] Reset button restores equipped gear
- [ ] Scroll works when many alternatives
- [ ] Popup positions correctly for all slot positions
- [ ] ESC closes popup
- [ ] Click-away closes popup
- [ ] Memory cleanup on hide (no leaks)
- [ ] Sounds play on interactions

---

## Estimated Time: 9.5 hours total

| Phase | Time | Description |
|-------|------|-------------|
| 1 | 2h | Expand dimensions & structure |
| 2 | 1.5h | BiS item showcase |
| 3 | 1.5h | Filter bar component |
| 4 | 2h | Grouped alternatives |
| 5 | 1.5h | Enhanced try-on system |
| 6 | 1h | Polish & animation |

---

## Future Enhancements (Not in Scope)

- Wishlist system (save items for later)
- Price/cost display for crafted items
- Attunement status indicator
- "Compare to Equipped" overlay
- Export gear list to chat/clipboard

---

## Implementation Checklist

### Pre-Implementation Verification

- [ ] **TBC 2.4.3 API Check**
  - [ ] Verify `UIPanelScrollFrameTemplate` exists
  - [ ] Verify `BackdropTemplateMixin` fallback works
  - [ ] Test `DressUpModel:TryOn()` with item links
  - [ ] Confirm `UIDropDownMenu_*` functions available

- [ ] **Existing Code Audit**
  - [ ] Review current `GetArmoryGearPopup()` implementation
  - [ ] Review current `PopulateArmoryGearPopup()` flow
  - [ ] Review current `CreateArmoryGearPopupItemRow()` structure
  - [ ] Identify all references to `self.armoryUI.gearPopup`

### Phase 1: Constants & Structure (Constants.lua)

- [ ] **Update ARMORY_GEAR_POPUP dimensions**
  - [ ] WIDTH: 300 → 480
  - [ ] MAX_HEIGHT: 420 → 520
  - [ ] MIN_HEIGHT: add 280
  - [ ] ITEM_HEIGHT: 64 → 54 (compact)
  - [ ] COMPACT_ITEM_HEIGHT: add 44 (for grouped items)
  - [ ] MAX_ALTERNATIVES: 5 → 10

- [ ] **Add new constants**
  - [ ] BIS_SECTION_HEIGHT: 120
  - [ ] FILTER_BAR_HEIGHT: 32
  - [ ] SECTION_GAP: 12
  - [ ] SOURCE_GROUPS table with order, label, color

- [ ] **Update POSITION_OFFSETS for wider popup**
  - [ ] Reduce x offsets (10 → 8)
  - [ ] Add fallback positions for screen edge cases

### Phase 2: Frame Pool Setup (Journal.lua)

- [ ] **Create new pools in OnEnable**
  - [ ] `CreateArmoryBisCardPool()` - BiS showcase
  - [ ] `CreateArmoryItemRowPool()` - Compact item rows
  - [ ] `CreateArmoryGroupHeaderPool()` - Collapsible headers
  - [ ] `CreateArmoryFilterBtnPool()` - Filter buttons

- [ ] **Add pool cleanup in OnDisable**
  - [ ] Destroy `armoryBisCardPool`
  - [ ] Destroy `armoryItemRowPool`
  - [ ] Destroy `armoryGroupHeaderPool`
  - [ ] Destroy `armoryFilterBtnPool`

- [ ] **Create reset functions**
  - [ ] BiS card reset (hide, clear points, nil data)
  - [ ] Item row reset (hide, clear points, nil textures)
  - [ ] Group header reset (hide, clear points, reset expanded)
  - [ ] Filter button reset (hide, clear points, reset selected)

### Phase 3: Popup Frame Restructure (Journal.lua)

- [ ] **Rewrite GetArmoryGearPopup()**
  - [ ] Use new dimensions from constants
  - [ ] Create header section (40px)
  - [ ] Create BiS section container (120px)
  - [ ] Create filter bar container (32px)
  - [ ] Create scroll frame for alternatives
  - [ ] Add "Try All BiS" button to header
  - [ ] Add "Reset" button to header

- [ ] **Update ShowArmoryGearPopup()**
  - [ ] Use new positioning logic
  - [ ] Add screen bounds checking
  - [ ] Implement fallback positions

- [ ] **Rewrite PopulateArmoryGearPopup()**
  - [ ] Release all pooled frames first
  - [ ] Create BiS showcase card
  - [ ] Create filter bar with buttons
  - [ ] Group alternatives by sourceType
  - [ ] Create collapsible group headers
  - [ ] Create compact item rows within groups
  - [ ] Calculate total scroll height

### Phase 4: BiS Showcase Card

- [ ] **Create CreateBisItemCard(parent, itemData)**
  - [ ] Large icon (64x64) with quality border
  - [ ] Gold pulsing glow effect
  - [ ] Full stat breakdown visible
  - [ ] Source and drop rate info
  - [ ] Large "TRY ON" button (100x28)
  - [ ] BiS star indicator with glow

- [ ] **Acquire from armoryBisCardPool**
  - [ ] Single card per popup
  - [ ] Release on popup hide

### Phase 5: Filter Bar Component

- [ ] **Create CreateArmoryFilterBar(parent)**
  - [ ] "All" button (default selected)
  - [ ] Source type buttons from SOURCE_GROUPS
  - [ ] Count badges showing items per category
  - [ ] Active state styling (gold border)

- [ ] **Create sort dropdown**
  - [ ] Options: "iLvl (High-Low)", "iLvl (Low-High)", "Source"
  - [ ] Use UIDropDownMenu_* API
  - [ ] Store selection in armoryPopupState

- [ ] **Implement filter logic**
  - [ ] `GetFilteredAlternatives(alternatives, filter, sort)`
  - [ ] Update on filter button click
  - [ ] Refresh alternatives section only

### Phase 6: Grouped Alternatives

- [ ] **Create CreateSourceGroupHeader(parent, sourceType, count)**
  - [ ] Collapse/expand arrow icon
  - [ ] Source type label with color
  - [ ] Item count badge
  - [ ] Click to toggle expanded state

- [ ] **Create CreateCompactItemRow(parent, itemData)**
  - [ ] Smaller height (44px vs 54px)
  - [ ] Icon (36x36)
  - [ ] Name with quality color
  - [ ] iLvl badge
  - [ ] Compact "TRY ON" button (60x22)
  - [ ] Source text (smaller font)

- [ ] **Track expanded state**
  - [ ] `armoryPopupState.expandedGroups[sourceType]`
  - [ ] Default: raid=true, heroic=true, others=false
  - [ ] Recalculate scroll height on toggle

### Phase 7: Try-On System Enhancement

- [ ] **Enhance TryOnItem(itemData)**
  - [ ] Visual feedback (flash on model)
  - [ ] Sound effect on success
  - [ ] Error handling for uncached items

- [ ] **Create TryOnBisSet(slotName)**
  - [ ] Get all BiS items for slot type
  - [ ] Preview each on model
  - [ ] Button in header section

- [ ] **Create ResetModelToEquipped()**
  - [ ] Call `Undress()` then re-dress current gear
  - [ ] Button in header section

### Phase 8: Polish & Animation

- [ ] **Add hover effects**
  - [ ] Item row: brighten 20%, gold border
  - [ ] Filter button: highlight
  - [ ] Try-on button: brighten

- [ ] **Add sound effects**
  - [ ] Filter click: PlayClick()
  - [ ] Group expand/collapse: PlayClick()
  - [ ] Try-on success: PlayClick()
  - [ ] Hover: PlayHover()

- [ ] **Add animations (optional)**
  - [ ] Group expand/collapse: smooth height (200ms)
  - [ ] Filter transition: fade items (100ms)

### Phase 9: Memory & Cleanup

- [ ] **Verify pool cleanup**
  - [ ] All frames released on hide
  - [ ] No orphaned FontStrings
  - [ ] No dangling references

- [ ] **Test memory usage**
  - [ ] Open/close popup 50 times
  - [ ] Check frame count doesn't grow
  - [ ] Verify no Lua errors

- [ ] **Test edge cases**
  - [ ] Empty slot (no BiS data)
  - [ ] Slot with only BiS (no alternatives)
  - [ ] Slot with 10+ alternatives
  - [ ] Phase with no data

### Phase 10: Testing Verification

- [ ] **Functional tests**
  - [ ] Popup opens at correct size
  - [ ] Popup positions correctly for all 14 visible slots
  - [ ] BiS card displays correctly
  - [ ] Filter buttons filter alternatives
  - [ ] Sort dropdown sorts correctly
  - [ ] Source groups collapse/expand
  - [ ] Try-on previews item on model
  - [ ] "Try All BiS" works
  - [ ] "Reset" restores equipped gear
  - [ ] Scroll works with many items
  - [ ] ESC closes popup
  - [ ] Click-away closes popup

- [ ] **Visual tests**
  - [ ] Quality colors display correctly
  - [ ] Source colors display correctly
  - [ ] Icons load from cache or show placeholder
  - [ ] Hover effects work
  - [ ] Sounds play

- [ ] **Memory tests**
  - [ ] No leaks after repeated open/close
  - [ ] Pool stats show reuse

---

## File Changes Checklist (Verified Line Numbers)

### Constants.lua
- [ ] **Line 5982-6033:** Update `ARMORY_GEAR_POPUP` dimensions
  - [ ] WIDTH: 300 → 480
  - [ ] MAX_HEIGHT: 420 → 520
  - [ ] Add MIN_HEIGHT: 280
  - [ ] ITEM_HEIGHT: 64 → 54
  - [ ] Add COMPACT_ITEM_HEIGHT: 44
  - [ ] Add BIS_SECTION_HEIGHT: 120
  - [ ] Add FILTER_BAR_HEIGHT: 32
  - [ ] Add SECTION_GAP: 12
  - [ ] MAX_ALTERNATIVES: 5 → 10
- [ ] **Line 6000-6023:** Update `POSITION_OFFSETS` for wider popup
  - [ ] Reduce x offsets (10 → 8)
  - [ ] Add fallback property for screen edge handling
- [ ] **After line 6033:** Add `SOURCE_GROUPS` table (~30 lines)
- [ ] **After SOURCE_GROUPS:** Add `FILTER_BAR` configuration (~15 lines)

### Journal.lua

**Pool Setup (add after existing pools around line 146):**
- [ ] **Line ~147:** Add `self:CreateArmoryBisCardPool()` call
- [ ] **Line ~147:** Add `self:CreateArmoryItemRowPool()` call
- [ ] **Line ~147:** Add `self:CreateArmoryGroupHeaderPool()` call
- [ ] **Line ~147:** Add `self:CreateArmoryFilterBtnPool()` call

**Pool Cleanup (add in OnDisable around line 231):**
- [ ] **Line ~234:** Add `armoryBisCardPool` destruction
- [ ] **Line ~235:** Add `armoryItemRowPool` destruction
- [ ] **Line ~236:** Add `armoryGroupHeaderPool` destruction
- [ ] **Line ~237:** Add `armoryFilterBtnPool` destruction

**New Pool Functions (add after line 707, after CreateUpgradeCardPool):**
- [ ] Add `CreateArmoryBisCardPool()` (~45 lines)
- [ ] Add `CreateArmoryItemRowPool()` (~55 lines)
- [ ] Add `CreateArmoryGroupHeaderPool()` (~45 lines)
- [ ] Add `CreateArmoryFilterBtnPool()` (~35 lines)

**State Additions (update armoryState at line 9267-9275):**
- [ ] Add `activeFilter = "all"` to armoryState
- [ ] Add `sortOrder = "ilvl_desc"` to armoryState
- [ ] Add `expandedGroups = {}` to armoryState

**Popup Functions (lines 10868-11349):**
- [ ] **Line 10868-10956:** Rewrite `GetArmoryGearPopup()`
  - New structure with BiS section, filter bar, scroll frame
  - Add "Try All BiS" and "Reset" buttons to header
- [ ] **Line 10958-10993:** Update `ShowArmoryGearPopup()`
  - Add screen bounds checking
  - Add fallback position logic
- [ ] **Line 11005-11098:** Rewrite `PopulateArmoryGearPopup()`
  - Release all pools first
  - Create BiS card
  - Create filter bar
  - Group and create alternatives
- [ ] **Line 11100-11335:** DEPRECATE `CreateArmoryGearPopupItemRow()` (keep for reference, mark deprecated)
- [ ] **Line 11337-11349:** Update `PreviewItemOnModel()` - add visual feedback

**New Functions (add after PreviewItemOnModel):**
- [ ] Add `CreateBisItemCard(parent, itemData)` (~85 lines)
- [ ] Add `CreateArmoryFilterBar(parent, alternatives)` (~65 lines)
- [ ] Add `CreateSourceGroupHeader(parent, sourceType, count, yOffset)` (~55 lines)
- [ ] Add `CreateCompactItemRow(parent, itemData, yOffset)` (~75 lines)
- [ ] Add `GetFilteredAlternatives(alternatives, filter, sort)` (~25 lines)
- [ ] Add `ToggleSourceGroup(sourceType)` (~35 lines)
- [ ] Add `RefreshAlternativesSection()` (~40 lines)
- [ ] Add `TryOnBisSet(slotName)` (~35 lines)
- [ ] Add `ResetModelToEquipped()` (~25 lines)
- [ ] Add `UpdateFilterCounts(alternatives)` (~20 lines)

### Estimated Total Changes
- **Constants.lua:** ~120 lines added/modified
- **Journal.lua:** ~780 lines added/modified
  - Pool functions: ~180 lines (4 pools)
  - Popup rewrite: ~350 lines
  - New helper functions: ~250 lines
  - Deprecations/removals: ~235 lines removed (CreateArmoryGearPopupItemRow)
  - **Net change:** ~545 new lines

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Frame pool memory leak | Low | High | Thorough reset functions, test with /reload |
| GetItemInfo cache miss | Medium | Low | Double-call pattern, placeholder icon |
| Popup positioning off-screen | Medium | Medium | Screen bounds check, fallback positions |
| Performance with 10+ items | Low | Medium | Pool reuse, lazy group expansion |
| TBC API incompatibility | Low | High | Use verified patterns from existing code |

---

## Success Criteria

1. **Usability:** Users can quickly find upgrades by source type
2. **Performance:** No frame count growth after repeated use
3. **Reliability:** No Lua errors during normal use
4. **Visual Quality:** Matches existing addon TBC aesthetic
5. **Discoverability:** Try-on feature is obvious and easy to use

---

## Validation Steps (Pre-Implementation)

### Step 1: Verify Current Codebase State

Run these checks before starting implementation:

```lua
-- In-game verification commands (/run in chat)

-- 1. Verify FramePool exists and works
/run print("FramePool:", HopeAddon.FramePool and "OK" or "MISSING")

-- 2. Verify BackdropTemplate support
/run print("BackdropTemplateMixin:", BackdropTemplateMixin and "OK" or "NATIVE")

-- 3. Verify CreateBackdropFrame helper exists
/run print("CreateBackdropFrame:", HopeAddon.CreateBackdropFrame and "OK" or "MISSING")

-- 4. Verify scroll template exists
/run local f = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate"); print("ScrollTemplate:", f and "OK" or "MISSING"); f:Hide()

-- 5. Verify model TryOn works
/run local m = CreateFrame("DressUpModel", nil, UIParent); m:SetUnit("player"); print("TryOn:", m.TryOn and "OK" or "MISSING"); m:Hide()

-- 6. Verify dropdown API exists
/run print("UIDropDownMenu:", UIDropDownMenu_Initialize and "OK" or "MISSING")

-- 7. Verify Effects module
/run print("Effects:", HopeAddon.Effects and HopeAddon.Effects.CreatePulsingGlow and "OK" or "MISSING")

-- 8. Verify Sounds module
/run print("Sounds:", HopeAddon.Sounds and HopeAddon.Sounds.PlayClick and "OK" or "MISSING")
```

**Expected Results:** All should print "OK" (BackdropTemplateMixin may print "NATIVE" on original TBC 2.4.3)

### Step 2: Verify Current Armory Structure

```lua
-- Check armoryUI table structure
/run local j = HopeAddon.Journal; print("armoryUI:", j.armoryUI and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; print("gearPopup ref:", j.armoryUI and j.armoryUI.gearPopup or "NIL")
/run local j = HopeAddon.Journal; print("armoryState:", j.armoryState and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; print("armoryPools:", j.armoryPools and "EXISTS" or "NIL")
```

### Step 3: Verify Constants Exist

```lua
-- Check required constants
/run local C = HopeAddon.Constants; print("ARMORY_GEAR_POPUP:", C.ARMORY_GEAR_POPUP and "EXISTS" or "MISSING")
/run local C = HopeAddon.Constants; print("WIDTH:", C.ARMORY_GEAR_POPUP and C.ARMORY_GEAR_POPUP.WIDTH or "N/A")
/run local C = HopeAddon.Constants; print("POSITION_OFFSETS:", C.ARMORY_GEAR_POPUP and C.ARMORY_GEAR_POPUP.POSITION_OFFSETS and "EXISTS" or "MISSING")
/run local C = HopeAddon.Constants; print("ARMORY_SOURCE_COLORS:", C.ARMORY_SOURCE_COLORS and "EXISTS" or "MISSING")
/run local C = HopeAddon.Constants; print("ARMORY_QUALITY_COLORS:", C.ARMORY_QUALITY_COLORS and "EXISTS" or "MISSING")
```

---

## Validation Steps (During Implementation)

### After Phase 1 (Constants & Structure)

```lua
-- Verify new constants
/run local C = HopeAddon.Constants.ARMORY_GEAR_POPUP; print("WIDTH:", C.WIDTH, "expected 480")
/run local C = HopeAddon.Constants.ARMORY_GEAR_POPUP; print("MAX_HEIGHT:", C.MAX_HEIGHT, "expected 520")
/run local C = HopeAddon.Constants.ARMORY_GEAR_POPUP; print("SOURCE_GROUPS:", C.SOURCE_GROUPS and "EXISTS" or "MISSING")
/run local C = HopeAddon.Constants.ARMORY_GEAR_POPUP; print("COMPACT_ITEM_HEIGHT:", C.COMPACT_ITEM_HEIGHT or "MISSING")
```

### After Phase 2 (Frame Pools)

```lua
-- Verify pools were created
/run local j = HopeAddon.Journal; print("armoryBisCardPool:", j.armoryBisCardPool and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; print("armoryItemRowPool:", j.armoryItemRowPool and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; print("armoryGroupHeaderPool:", j.armoryGroupHeaderPool and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; print("armoryFilterBtnPool:", j.armoryFilterBtnPool and "EXISTS" or "NIL")

-- Verify pool stats (should all be 0 created initially)
/run local j = HopeAddon.Journal; if j.armoryItemRowPool then local s = j.armoryItemRowPool:GetStats(); print("ItemRowPool - created:", s.created, "active:", s.active) end
```

### After Phase 3 (Popup Restructure)

```lua
-- Open Armory tab and click a slot, then verify:
/run local j = HopeAddon.Journal; local p = j.armoryUI and j.armoryUI.gearPopup; print("Popup:", p and "EXISTS" or "NIL")
/run local j = HopeAddon.Journal; local p = j.armoryUI.gearPopup; print("Popup size:", p and (p:GetWidth().."x"..p:GetHeight()) or "N/A")
/run local j = HopeAddon.Journal; local p = j.armoryUI.gearPopup; print("Popup visible:", p and p:IsShown() or false)
/run local j = HopeAddon.Journal; local p = j.armoryUI.gearPopup; print("ScrollFrame:", p and p.scrollFrame and "EXISTS" or "MISSING")
```

### After Each Phase - Memory Check

```lua
-- Check for frame leaks (run before and after opening/closing popup 10 times)
/run local count = 0; for k,v in pairs(_G) do if type(v) == "table" and v.GetObjectType then count = count + 1 end end; print("Total frames:", count)

-- Check pool stats after use
/run local j = HopeAddon.Journal; for name, pool in pairs({bis=j.armoryBisCardPool, row=j.armoryItemRowPool, hdr=j.armoryGroupHeaderPool, btn=j.armoryFilterBtnPool}) do if pool then local s = pool:GetStats(); print(name, "- created:", s.created, "active:", s.active, "available:", s.available) end end
```

---

## Validation Steps (Post-Implementation)

### Functional Validation Script

```lua
-- Run full validation suite
/run local function validate()
    local errors = {}
    local j = HopeAddon.Journal
    local C = HopeAddon.Constants

    -- Check constants
    if not C.ARMORY_GEAR_POPUP then table.insert(errors, "Missing ARMORY_GEAR_POPUP") end
    if C.ARMORY_GEAR_POPUP and C.ARMORY_GEAR_POPUP.WIDTH ~= 480 then table.insert(errors, "WIDTH not 480") end
    if C.ARMORY_GEAR_POPUP and not C.ARMORY_GEAR_POPUP.SOURCE_GROUPS then table.insert(errors, "Missing SOURCE_GROUPS") end

    -- Check pools
    if not j.armoryBisCardPool then table.insert(errors, "Missing armoryBisCardPool") end
    if not j.armoryItemRowPool then table.insert(errors, "Missing armoryItemRowPool") end
    if not j.armoryGroupHeaderPool then table.insert(errors, "Missing armoryGroupHeaderPool") end
    if not j.armoryFilterBtnPool then table.insert(errors, "Missing armoryFilterBtnPool") end

    -- Check functions exist
    if not j.CreateBisItemCard then table.insert(errors, "Missing CreateBisItemCard") end
    if not j.CreateArmoryFilterBar then table.insert(errors, "Missing CreateArmoryFilterBar") end
    if not j.CreateSourceGroupHeader then table.insert(errors, "Missing CreateSourceGroupHeader") end
    if not j.CreateCompactItemRow then table.insert(errors, "Missing CreateCompactItemRow") end
    if not j.GetFilteredAlternatives then table.insert(errors, "Missing GetFilteredAlternatives") end
    if not j.ToggleSourceGroup then table.insert(errors, "Missing ToggleSourceGroup") end
    if not j.TryOnBisSet then table.insert(errors, "Missing TryOnBisSet") end
    if not j.ResetModelToEquipped then table.insert(errors, "Missing ResetModelToEquipped") end

    -- Report
    if #errors > 0 then
        print("|cFFFF0000VALIDATION FAILED:|r")
        for _, e in ipairs(errors) do print("  - " .. e) end
    else
        print("|cFF00FF00VALIDATION PASSED|r - All checks OK")
    end
end
validate()
```

### Memory Leak Test Procedure

1. **Baseline:** Note frame count before test
2. **Stress Test:** Open Armory → Click each slot 3 times → Close popup → Repeat 5 times
3. **Check:** Frame count should be within ±5 of baseline
4. **Pool Check:** All pools should show `active: 0` when popup is closed

```lua
-- Memory leak test
/run local function memTest()
    local j = HopeAddon.Journal
    -- Get baseline
    local baseFrames = 0
    for k,v in pairs(_G) do if type(v) == "table" and rawget(v, "GetObjectType") then baseFrames = baseFrames + 1 end end

    print("Starting memory test - baseline frames:", baseFrames)
    print("Please: Open Armory > Click each slot 3x > Close > Repeat 5x")
    print("Then run: /run HopeAddon._memTestEnd()")

    HopeAddon._memTestEnd = function()
        local endFrames = 0
        for k,v in pairs(_G) do if type(v) == "table" and rawget(v, "GetObjectType") then endFrames = endFrames + 1 end end
        local diff = endFrames - baseFrames
        if math.abs(diff) <= 5 then
            print("|cFF00FF00MEMORY TEST PASSED|r - Frame diff:", diff)
        else
            print("|cFFFF0000MEMORY TEST FAILED|r - Frame diff:", diff, "(expected ±5)")
        end

        -- Check pool states
        for name, pool in pairs({bis=j.armoryBisCardPool, row=j.armoryItemRowPool}) do
            if pool then
                local s = pool:GetStats()
                if s.active > 0 then
                    print("|cFFFF0000LEAK:|r", name, "has", s.active, "active frames")
                end
            end
        end
        HopeAddon._memTestEnd = nil
    end
end
memTest()
```

### Visual Validation Checklist

| Test | Expected Result | Pass/Fail |
|------|-----------------|-----------|
| Open popup for HEAD slot | Popup appears to RIGHT of slot | [ ] |
| Open popup for HANDS slot | Popup appears to LEFT of slot | [ ] |
| Open popup for MAINHAND slot | Popup appears ABOVE slot | [ ] |
| Popup width | 480px | [ ] |
| Popup max height | 520px (scrolls if more) | [ ] |
| BiS card icon size | 64x64 | [ ] |
| BiS card has gold glow | Pulsing glow visible | [ ] |
| Filter buttons visible | [All] [Raid] [Heroic] [Crafted] etc. | [ ] |
| Click "Raid" filter | Only raid items shown | [ ] |
| Click "All" filter | All items shown | [ ] |
| Group headers visible | "▼ RAID DROPS (2)" format | [ ] |
| Click group header | Items collapse/expand | [ ] |
| Hover item row | Brightens, tooltip shows | [ ] |
| Click "TRY ON" button | Item appears on model | [ ] |
| Click "Reset" button | Model shows equipped gear | [ ] |
| Press ESC | Popup closes | [ ] |
| Click outside popup | Popup closes | [ ] |
| Click same slot again | Popup toggles off | [ ] |

---

## Accuracy Verification - Current Line Numbers

| Item | File | Verified Line | Notes |
|------|------|---------------|-------|
| `Journal.armoryUI` | Journal.lua | 9254-9265 | Table with gearPopup ref at 9263 |
| `Journal.armoryState` | Journal.lua | 9267-9275 | Includes popupVisible at 9271 |
| `Journal.armoryPools` | Journal.lua | 9277-9283 | Existing pool structure |
| `GetArmoryGearPopup()` | Journal.lua | 10868-10956 | Creates popup frame |
| `ShowArmoryGearPopup()` | Journal.lua | 10958-10993 | Positions and shows popup |
| `HideArmoryGearPopup()` | Journal.lua | 10995-11003 | Hides popup |
| `PopulateArmoryGearPopup()` | Journal.lua | 11005-11098 | Populates content |
| `CreateArmoryGearPopupItemRow()` | Journal.lua | 11100-11335 | Creates item rows |
| `PreviewItemOnModel()` | Journal.lua | 11337-11349 | Model preview |
| `ARMORY_GEAR_POPUP` | Constants.lua | 5982-6033 | Current dimensions (300x420) |
| `POSITION_OFFSETS` | Constants.lua | 6000-6023 | Slot positioning |
| `ARMORY_SOURCE_COLORS` | Constants.lua | 6162-6177 | Source type colors |
| `ARMORY_QUALITY_COLORS` | Constants.lua | 6379-6386 | Item quality colors |
| `OnEnable pool creation` | Journal.lua | 138-147 | Where pools are created |
| `OnDisable pool cleanup` | Journal.lua | 206-233 | Where pools are destroyed |
| `CreateUpgradeCardPool()` | Journal.lua | 622-707 | Example pool pattern |

---

## Rollback Plan

If implementation fails, revert these files:
1. `Constants.lua` - Restore original `ARMORY_GEAR_POPUP` dimensions
2. `Journal.lua` - Restore original popup functions

**Git commands:**
```bash
# Before starting, create backup branch
git checkout -b armory-popup-backup
git checkout main

# If rollback needed
git checkout armory-popup-backup -- HopeAddon/Core/Constants.lua
git checkout armory-popup-backup -- HopeAddon/Journal/Journal.lua
```

**Manual rollback points:**
- Constants.lua line 5982: `ARMORY_GEAR_POPUP` block
- Journal.lua line 10868: `GetArmoryGearPopup()` function
- Journal.lua line 11005: `PopulateArmoryGearPopup()` function
- Journal.lua line 11100: `CreateArmoryGearPopupItemRow()` function
