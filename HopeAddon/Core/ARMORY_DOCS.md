# Armory Tab - Component Reference

> **Audience:** AI assistants modifying armory code.
> **Last updated:** 2026-03-01

---

## 1. Architecture Overview

The Armory tab is a BiS (Best in Slot) gear tracking system for TBC Classic, built into the HopeAddon guild journal. It displays a paperdoll-style character model flanked by equipment slot buttons across 6 content phases (Pre-Raid through Sunwell). Players select a phase and spec to see per-slot BiS recommendations, compare equipped gear against BiS targets, preview full BiS sets on their character model, and browse alternative items with source information. The entire UI is ~4000 lines of Lua spread across three files.

### File Map

| File | Lines | Content |
|------|-------|---------|
| `Journal/Journal.lua` lines 14720-18672 | ~3950 | All UI code: frames, events, tooltips, popups, footer |
| `Core/Constants.lua` lines 7353-8924 | ~1570 | All 24 `C.ARMORY_*` constant blocks (layout, colors, phases, slots, assets) |
| `Core/ArmoryBisData.lua` | 4897 | BiS item database (18 specs x 6 phases), spec mappings, lookup helpers |

### Visual Layout

```
+--------------------------------------------------------------+
|  PHASE  [P] [1] [2] [3] [4] [5]              [Spec Dropdown] |  <- Phase Bar (35px)
+--------------------------------------------------------------+
|                                                               |
|  [Head]       +------------------+        [Hands]             |
|  [Shoulders]  |                  |        [Waist]             |
|  [Chest]      |   3D Character   |        [Legs]             |
|  [Wrist]      |      Model       |        [Feet]             |
|  [Neck]       |                  |        [Ring1]             |  <- Character View (380px)
|  [Back]       +------------------+        [Ring2]             |
|               [Main] [Off] [Ranged]       [Trinket1]         |
|               [Trinket2]                                      |
|                                                               |
|  Each slot has an InfoCard beside it (iLvl + rank badge)      |
+--------------------------------------------------------------+
|  Avg iLvl: 115    Phase: 1         [BIS]  [RESET]            |  <- Footer (35px)
+--------------------------------------------------------------+

         +--- Gear Popup (340px wide, anchored to slot) ---+
         |  [Icon] Slot Name                          [X]  |
         |  +----- BiS Card (88px) --------------------+   |
         |  | [Icon] Item Name          iLvl 115       |   |
         |  |        Source: Prince Malchezaar  [Raid]  |   |
         |  +------------------------------------------+   |
         |  +--- Alt Item Row (72px) ------------------+   |
         |  | [Icon] Alt Item           iLvl 110       |   |
         |  |        Source: G'eras      [Badge]        |   |
         |  +------------------------------------------+   |
         |  ... more alternatives ...                       |
         |  Items: 5                    [Try BiS] [Reset]  |
         +-------------------------------------------------+
```

---

## 2. State & UI References

### `Journal.armoryState` (Journal.lua:14738)

```lua
{
    selectedPhase    = 1,           -- Phase 0-5 (0 = Pre-Raid)
    selectedSpec     = nil,         -- Spec tab index (1/2/3), nil = auto-detect
    selectedSlot     = nil,         -- Currently selected slot name string
    popupVisible     = false,       -- Whether gear popup is showing
    bisPreviewMode   = false,       -- When true, slot icons show BiS items
    expandedSections = {},          -- { [sectionId] = true/false }
    slotStatuses     = {},          -- Upgrade status per slot
    popup = {
        activeFilter   = "all",     -- "all" or source key
        expandedGroups = {},        -- { [sourceKey] = true/false }
        sortOrder      = "bis",     -- "bis", "ilvl", "source"
        lastSlot       = nil,       -- Last slot name for popup
        acquiredItems  = {},        -- { [itemId] = true }
    }
}
```

### `Journal.armoryUI` (Journal.lua:14724)

```lua
{
    container      = nil,   -- Main armory container frame
    phaseBar       = nil,   -- Slim phase selector bar
    phaseButtons   = {},    -- Phase 0-5 button frames keyed by phase number
    specDropdown   = nil,   -- UIDropDownMenu spec selector
    characterView  = nil,   -- Full-width character view container
    modelFrame     = nil,   -- DressUpModel for character preview
    slotsContainer = nil,   -- Container for all equipment slot buttons
    slotButtons    = {},    -- Keyed by slotName (e.g. "head", "chest")
    infoCards      = {},    -- Slot info cards (iLvl + rank display)
    gearPopup      = nil,   -- Floating gear popup frame (singleton)
    footer         = nil,   -- Footer bar with stats and buttons
    -- Runtime:
    cachedAvgILvl  = nil,   -- Set during UpdateArmoryInfoCards (line 16386)
}
```

### `Journal.armoryPools` (Journal.lua:14797)

| Pool | Line | Frame Type | Purpose |
|------|------|------------|---------|
| `upgradeCard` | 14999 | BackdropTemplate | Item recommendation cards |
| `sectionHeader` | 15009 | BackdropTemplate | Collapsible section headers |
| `infoCard` | 15020 | BackdropTemplate (HIGH) | Slot info banners (60x44px) |
| `bisCard` | 15223 | BackdropTemplate | Featured BiS item in popup |
| `popupItemRow` | 15332 | Button+BackdropTemplate | Alternative item rows in popup |

Declared but unused: `statRow`, `sourceTag`, `groupHeader`, `filterCard`.

---

## 3. Component Breakdown

### 3.1 Initialization

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 14819 | `PopulateArmory()` | Main entry: creates pools, loads saved state, builds container, refreshes all |
| 14886 | `HideArmoryTab()` | Saves state to charDb, hides popup, restores scroll container |
| 14994 | `CreateArmoryPools()` | Creates 5 FramePool instances |
| 15447 | `CreateArmoryContainer()` | Creates "HopeArmoryContainer", delegates to phaseBar/characterView/footer |

**Call flow:**
```
PopulateArmory()
  -> CreateArmoryPools()
  -> CreateArmoryContainer()
       -> CreateArmoryPhaseBar()
       -> CreateArmoryCharacterView()
       -> CreateArmoryFooter()
  -> RefreshArmorySlotData()
  -> UpdateArmoryInfoCards()
  -> UpdateArmoryFooter()
```

**Key frames:** `HopeArmoryContainer` (parented to contentArea)

**Constants:** `C.ARMORY_CONTAINER`

---

### 3.2 Phase Bar

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 15497 | `CreateArmoryPhaseBar()` | Creates "HopeArmoryPhaseBar" with backdrop and PHASE label |
| 15535 | `CreateArmoryPhaseButtons()` | Creates buttons for phases {0,1,2,3,4,5} with tooltips |
| 15641 | `SetPhaseButtonState(btn, stateName)` | Applies visual state (active/inactive/hover) |
| 18551 | `SelectArmoryPhase(phase)` | Sets phase, updates visuals, refreshes data |

**Call flow:**
```
CreateArmoryPhaseBar()
  -> CreateArmoryPhaseButtons()
  -> CreateArmorySpecDropdown()

User clicks phase button:
  -> SelectArmoryPhase(phase)
       -> SetPhaseButtonState() (for each button)
       -> RefreshArmorySlotData()
       -> ShowArmoryGearPopup() (if popup visible)
```

**Key frames:** `HopeArmoryPhaseBar`, phase buttons keyed 0-5

**Constants:** `C.ARMORY_PHASE_BAR`, `C.ARMORY_PHASE_BUTTON`

---

### 3.3 Spec Dropdown

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 15677 | `CreateArmorySpecDropdown()` | Creates "HopeArmorySpecDropdown" via UIDropDownMenuTemplate |
| 15702 | `InitArmorySpecDropdownMenu(frame, level)` | Populates with 3 spec tabs from GetTalentTabInfo |

**Call flow:**
```
CreateArmorySpecDropdown()
  -> UIDropDownMenu_Initialize(InitArmorySpecDropdownMenu)

User selects spec:
  -> Sets armoryState.selectedSpec
  -> RefreshArmoryRecommendations()
```

**Key frames:** `HopeArmorySpecDropdown`

**Constants:** `C.ARMORY_SPEC_DROPDOWN`

---

### 3.4 Character View

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 15727 | `CreateArmoryCharacterView()` | Creates "HopeArmoryCharacterView" with backdrop (380px) |
| 15763 | `CreateArmoryModelFrame()` | Creates "HopeArmoryModel" DressUpModel with drag rotation |

**Call flow:**
```
CreateArmoryCharacterView()
  -> CreateArmoryModelFrame()
  -> CreateArmorySlotsContainer()
```

**Key frames:** `HopeArmoryCharacterView`, `HopeArmoryModel`

**Constants:** `C.ARMORY_CHARACTER_VIEW`, `C.ARMORY_MODEL_FRAME`

---

### 3.5 Slot System

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 15834 | `CreateArmorySlotsContainer()` | Creates "HopeArmorySlotsContainer" at HIGH strata |
| 15879 | `CreateArmorySlotButtons()` | Iterates slots, skips hidden, positions via POSITIONS config |
| 15961 | `CreateSingleArmorySlotButton(parent, slotName, slotData)` | Creates Button with icon, border, indicator, label, glow |
| 16920 | `RefreshArmorySlotData()` | Iterates all slotButtons, calls RefreshSingleSlotData |
| 16929 | `RefreshSingleSlotData(btn)` | Reads equipped item, sets icon/quality, calculates upgrade status |
| 17022 | `UpdateArmorySlotVisual(btn)` | Applies STATE_COLORS, shows indicator badge (star/arrow) |
| 16989 | `CalculateSlotUpgradeStatus(slotName, equippedItemId, equippedILvl)` | Compares equipped to BiS, returns "bis"/"ok"/"upgrade" |

**Call flow:**
```
CreateArmorySlotsContainer()
  -> CreateArmorySlotButtons()
       -> CreateSingleArmorySlotButton() (x17, skipping shirt/tabard)

RefreshArmorySlotData()
  -> RefreshSingleSlotData(btn) (for each slot)
       -> CalculateSlotUpgradeStatus()
       -> UpdateArmorySlotVisual()
```

**Key frames:** `HopeArmorySlotsContainer`, slot buttons keyed by slot name

**Constants:** `C.ARMORY_SLOTS_CONTAINER`, `C.ARMORY_SLOT_BUTTON`, `C.ARMORY_HIDDEN_SLOTS`, `C.ARMORY_SLOT_PLACEHOLDER_ICONS`

---

### 3.6 Info Cards

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 16373 | `UpdateArmoryInfoCards()` | Releases pool, recreates cards for each non-hidden slot |
| 16217 | `CreateSlotInfoCard(slotButton, slotName)` | Acquires infoCard, sets iLvl/rank/grade/glow |
| 16098 | `GetAverageEquippedILvl()` | Iterates slots 1-18 (skip shirt), returns avg iLvl |
| 16130 | `GetSlotUpgradeStatus(slotILvl, avgILvl)` | 5-tier system: EXCELLENT/GOOD/OKAY/UPGRADE/URGENT |
| 16151 | `IsSlotBisEquipped(slotName, equippedItemId)` | True if equipped matches gearData.best.id |
| 16165 | `GetEquippedItemRank(slotName, equippedItemId)` | Returns rank 1 (best), 2+ (alt index), nil (not listed) |
| 16193 | `GetRankColor(rank)` | Returns color from RANK_COLORS config |

**Call flow:**
```
UpdateArmoryInfoCards()
  -> pool:ReleaseAll()
  -> GetAverageEquippedILvl() -> cachedAvgILvl
  -> CreateSlotInfoCard(btn, slotName) (for each slot)
       -> GetEquippedItemRank()
       -> GetRankColor()
       -> GetSlotUpgradeStatus()
```

**Key frames:** infoCards pool instances (60x44px banners beside each slot)

**Constants:** `C.ARMORY_INFO_CARD` (RANK_COLORS, GRADE_ICONS, POSITIONS, thresholds)

---

### 3.7 Gear Popup

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 17678 | `GetArmoryGearPopup()` | Creates singleton "HopeArmoryGearPopup" at DIALOG strata |
| 17900 | `ReleaseArmoryPopupFrames()` | Releases bisCard and popupItemRow pools |
| 17932 | `ShowArmoryGearPopup(slotName, anchorBtn)` | Positions popup (screen-bounds-aware), populates, shows |
| 18038 | `HideArmoryGearPopup()` | Hides popup, sets popupVisible = false |
| 18049 | `PopulateArmoryGearPopup(slotName)` | Builds BiS card + alt rows, sizes popup dynamically |
| 18163 | `PopulateBisCard(popup, bisItem)` | Configures featured BiS item card (icon, name, source) |
| 18281 | `CreateArmoryPopupItemRow(parent, itemData, yOffset)` | Creates alternative item row with highlight |
| 18496 | `RegisterArmoryClickAwayHandler()` | Creates click-away overlay to dismiss popup |
| 18545 | `UnregisterArmoryClickAwayHandler()` | Hides click-away frame |

**Call flow:**
```
ShowArmoryGearPopup(slotName, anchorBtn)
  -> GetArmoryGearPopup() (lazy singleton creation)
  -> PopulateArmoryGearPopup(slotName)
       -> ReleaseArmoryPopupFrames()
       -> GetArmoryGearData(slotName)
       -> PopulateBisCard(popup, bisItem)
       -> CreateArmoryPopupItemRow() (for each alt)
  -> RegisterArmoryClickAwayHandler()
```

**Key frames:** `HopeArmoryGearPopup`, `HopeArmoryClickAway`

**Constants:** `C.ARMORY_GEAR_POPUP` (dimensions, SOURCE_GROUPS, POSITION_OFFSETS, BIS_CARD, ITEM)

---

### 3.8 BiS Preview

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 16679 | `OnBISButtonClick()` | Toggles bisPreviewMode on/off |
| 16715 | `PreviewAllBis()` | Legacy alias for OnBISButtonClick |
| 16723 | `ApplyBisPreviewIcons()` | Swaps slot icons to BiS textures, tints borders green |
| 16766 | `RestoreEquippedIcons()` | Restores saved icon state on each slot button |
| 16796 | `UpdateBisButtonActiveState(isActive)` | Active: gold bg + green border + "BIS *"; Inactive: restore |
| 16828 | `OnRESETButtonClick()` | Full 9-step reset (exits preview, closes popup, resets phase) |
| 16913 | `ResetArmoryPreview()` | Legacy alias for OnRESETButtonClick |
| 18407 | `PreviewItemOnModel(itemData)` | Calls modelFrame:TryOn("item:" .. itemId) |
| 18427 | `TryOnBisSet()` | Iterates 17 slots, tries on each BiS item on model |
| 18469 | `ResetModelToEquipped()` | Undress/RefreshUnit/SetUnit("player") fallback chain |

**Call flow:**
```
OnBISButtonClick() [toggle ON]
  -> ApplyBisPreviewIcons()
  -> UpdateBisButtonActiveState(true)

OnBISButtonClick() [toggle OFF]
  -> RestoreEquippedIcons()
  -> UpdateBisButtonActiveState(false)

BIS button OnEnter:
  -> BuildBISTooltip(btn)              -- :17539 (shows full BiS list on hover)

OnRESETButtonClick()                   -- 9-step sequence:
  0. Exit BiS preview mode             -- :16832
  1. Close gear popup                  -- :16838
  2. Deselect any selected slot        -- :16845
  3. Unregister click-away handler     -- :16857
  4. Reset phase to Phase 1            -- :16862
  5. Reset spec to auto-detect         -- :16867
  6. Clear expanded sections           -- :16879
  7. Reset popup sub-state             -- :16887
  8. Reset character model             -- :16893
  9. Refresh all visuals               -- :16902
```

**Constants:** `C.ARMORY_FOOTER.BUTTONS.BIS`, `C.ARMORY_FOOTER.BUTTONS.RESET`

---

### 3.9 Footer

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 16416 | `CreateArmoryFooter()` | Creates "HopeArmoryFooter" with stat displays |
| 16500 | `CreateArmoryFooterButtons(footer)` | Creates BIS and RESET buttons |
| 16566 | `CreateArmoryFooterButton(parent, label, width, height, borderColor, bgColor, tooltip, onClick)` | Generic button factory |
| 16632 | `RecalculateArmoryHeight()` | DEPRECATED - no longer used with fixed layout |
| 16645 | `UpdateArmoryFooter()` | Calls CalculateArmoryStats, formats display |
| 16660 | `CalculateArmoryStats()` | Returns { phase, avgIlvl, gearScore } |

**Call flow:**
```
CreateArmoryFooter()
  -> CreateArmoryFooterButtons(footer)
       -> CreateArmoryFooterButton() (x2: BIS + RESET)

UpdateArmoryFooter()
  -> CalculateArmoryStats()
  -> format values into footer stat displays
```

**Key frames:** `HopeArmoryFooter`

**Constants:** `C.ARMORY_FOOTER`

---

### 3.10 Tooltips

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 17300 | `OnArmorySlotEnter(btn)` | Shows tooltip: BiS item (preview mode) or equipped + recommendation |
| 17423 | `OnArmorySlotLeave(btn)` | Hides GameTooltip |
| 17438 | `BuildArmoryGearTooltip(itemData, anchorFrame)` | Rich tooltip with drop info, rep, stats, tips, alts, prereqs |
| 17539 | `BuildBISTooltip(anchorFrame)` | Full BiS list grouped by Armor/Accessories/Weapons |
| 17628 | `BuildBasicHoverData(itemData)` | Builds dropInfo from sourceType (raid/badge/crafted/rep/heroic/quest) |

**Call flow:**
```
OnArmorySlotEnter(btn)
  -> [BiS preview mode]: SetHyperlink + source info
  -> [Normal mode]: SetInventoryItem + BiS recommendation section

BuildArmoryGearTooltip(itemData, anchor)
  -> SetHyperlink
  -> BuildBasicHoverData(itemData)
  -> Appends sections: Drop Info, Rep, Stats, Tips, Alts, Prerequisites
```

**Constants:** `C.ARMORY_SOURCE_COLORS`, `C.ARMORY_SOURCE_TYPES`

---

### 3.11 Event Handlers

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 17265 | `OnArmorySlotClick(slotName)` | Toggle popup: same slot closes, new slot opens |
| 18580 | `ToggleArmorySection(sectionId)` | Toggles expandedSections, refreshes detail panel |

**Call flow:**
```
OnArmorySlotClick(slotName)
  -> [same slot + popup visible]: HideArmoryGearPopup(), deselect
  -> [new slot]: deselect previous, select new, ShowArmoryGearPopup()
```

---

### 3.12 Data Layer

**Functions:**

| Line | Function | Purpose |
|------|----------|---------|
| 17077 | `RefreshArmoryRecommendations()` | Saves spec, refreshes slots/preview/popup/footer |
| 17106 | `GetCurrentArmoryRole()` | Returns role via HopeAddon:GetSpecRole |
| 17123 | `GetCurrentArmoryGuideKey()` | Maps class+role to guideKey string |
| 17155 | `FilterGearByClass(gearData, classToken)` | Filters weapons by CLASS_WEAPON_ALLOWED |
| 17224 | `GetArmoryGearData(slotName)` | Gets BiS data: spec-based first, role-based fallback |
| 18397 | `GetItemLinkFromId(itemId)` | Returns item link from GetItemInfo |

**Call flow:**
```
GetArmoryGearData(slotName)
  -> GetCurrentArmoryGuideKey()
  -> Constants:GetSpecBisGearLegacy(phase, guideKey, slot)
  -> [fallback]: Constants:GetArmoryGear(phase, role, slot)
  -> FilterGearByClass() (for weapon slots)
```

**Constants:** `C.ARMORY_SLOTS` (slot definitions)

---

### 3.13 Pool Initializers

| Line | Function | Purpose |
|------|----------|---------|
| 18594 | `InitializeUpgradeCard(card)` | Sets up upgrade card: backdrop, icon, text fields |
| 18627 | `ResetUpgradeCard(card)` | Hides card, clears points and data |
| 18635 | `InitializeSectionHeader(header)` | Sets up section header: arrow, title, count |
| 18666 | `ResetSectionHeader(header)` | Hides header, clears points and data |

---

## 4. Constants Reference

All blocks in `Core/Constants.lua`:

| # | Block | Line | Description | Key Fields |
|---|-------|------|-------------|------------|
| 1 | `C.ARMORY_CONTAINER` | 7353 | Main container dimensions | WIDTH, HEIGHT, MIN_HEIGHT, PADDING |
| 2 | `C.ARMORY_PHASE_BAR` | 7363 | Phase bar layout (35px) | HEIGHT, BACKDROP, BG_COLOR, LABEL_TEXT |
| 3 | `C.ARMORY_PHASE_BUTTON` | 7385 | Phase button config + per-phase metadata | WIDTH=32, HEIGHT=24, PHASES[0-5], STATES |
| 4 | `C.ARMORY_SPEC_DROPDOWN` | 7527 | Spec dropdown positioning | WIDTH=120, HEIGHT=28, MENU_WIDTH=110 |
| 5 | `C.ARMORY_CHARACTER_VIEW` | 7538 | Character view container | COMPACT_HEIGHT=380, LEFT/RIGHT_COLUMN_WIDTH=54 |
| 6 | `C.ARMORY_MODEL_FRAME` | 7561 | 3D model frame | WIDTH=180, HEIGHT=280, ROTATION_SPEED, LIGHTING |
| 7 | `C.ARMORY_SLOTS_CONTAINER` | 7578 | Slots parent container | SLOT_SIZE=44, SLOT_GAP=6 |
| 8 | `C.ARMORY_GEAR_POPUP` | 7590 | Gear popup (largest block) | WIDTH=340, SOURCE_GROUPS(9), POSITION_OFFSETS, BIS_CARD, ITEM |
| 9 | `C.ARMORY_HIDDEN_SLOTS` | 7744 | Hidden slots lookup | shirt=true, tabard=true |
| 10 | `C.ARMORY_SLOT_BUTTON` | 7750 | Slot button master config | SIZE=44, SLOTS(19), POSITIONS, STATE_COLORS(8), INDICATOR_ICONS(6) |
| 11 | `C.ARMORY_SLOT_PLACEHOLDER_ICONS` | 7839 | Empty-slot placeholder textures | 19 Interface\\PaperDoll paths |
| 12 | `C.ARMORY_INFO_CARD` | 7862 | Info card styling (60x44px) | RANK_COLORS, GRADE_ICONS(5), POSITIONS, thresholds |
| 13 | `C.ARMORY_FOOTER` | 7966 | Footer bar config | HEIGHT=35, STATS, BUTTONS.BIS, BUTTONS.RESET |
| 14 | `C.ARMORY_SOURCE_COLORS` | 8021 | Source type RGB colors | raid, heroic, dungeon, badge, crafted, rep, pvp, quest, world |
| 15 | `C.ARMORY_UPGRADE_CARD` | 8034 | Upgrade card template | HEIGHT=75, ICON_SIZE=44, RANK_COLORS, layout offsets |
| 16 | `C.ARMORY_SECTION_HEADER` | 8067 | Section header template | HEIGHT=28, ARROW_SIZE=16, expand/collapse textures |
| 17 | `C.ARMORY_MARGINS` | 8087 | Spacing system | CONTAINER_PADDING, SECTION_SPACING, COMPONENT_GAPs |
| 18 | `C.ARMORY_ASSETS` | 8111 | Texture asset paths | BACKGROUNDS, BORDERS, GLOWS, QUALITY_FRAMES, SOURCE_ICONS |
| 19 | `C.ARMORY_PHASES` | 8219 | Phase metadata (6 phases) | name, color, raids[], sources[] |
| 20 | `C.ARMORY_SOURCE_TYPES` | 8265 | Source type display metadata | color, icon, label per source type |
| 21 | `C.ARMORY_SLOTS` | 8278 | Ordered slot definitions (17) | id, slotId, label, position |
| 22 | `C.ARMORY_ROLES` | 8328 | Role definitions (5) | name, icon, color, stats |
| 23 | `C.ARMORY_QUALITY_COLORS` | 8337 | Item quality colors | poor, common, uncommon, rare, epic, legendary |
| 24 | `C.ARMORY_GEAR_DATABASE` | 8348 | Legacy BiS database (role-based) | [phase][role][slot] = { best, alternatives } |

### Related Constants (not `C.ARMORY_*` prefixed)

| Block/Function | Line | Description |
|----------------|------|-------------|
| `C:GetPhaseColorForItemLevel(iLvl)` | 7512 | Returns phase color name for an item level |
| `C:GetArmoryGear(phase, role, slot)` | 8927 | Gets gear from `ARMORY_GEAR_DATABASE` |
| `C:GetArmorySlots(phase, role)` | 8934 | Gets all slots for a role/phase |
| `C:GetArmoryPhase(phase)` | 8941 | Gets phase metadata from `ARMORY_PHASES` |
| `C:HasArmoryPhaseData(phase)` | 8946 | Checks if phase has any gear data |
| `C.CLASS_WEAPON_ALLOWED` | 8958 | Class->weapon type restrictions (9 classes) |
| `C:CanClassUseWeapon(classToken, weaponType)` | 8971 | Checks class weapon eligibility |
| `C.BIS_TOOLTIP_SLOT_ORDER` | 8304 | Ordered slot list for BiS tooltip display |

---

## 5. Data Layer (ArmoryBisData.lua)

### `C.ARMORY_SPECS` (line 16)

Maps class tokens to spec arrays:

```lua
C.ARMORY_SPECS = {
    WARRIOR = {
        { id="arms", name="Arms", role="melee_dps", guideKey="warrior-dps" },
        { id="fury", name="Fury", role="melee_dps", guideKey="warrior-dps" },
        { id="protection", name="Protection", role="tank", guideKey="protection-warrior-tank" },
    },
    -- ... 9 classes, 27 specs, 18 unique guideKeys
}
```

All 9 classes: WARRIOR, PALADIN, HUNTER, ROGUE, PRIEST, SHAMAN, MAGE, WARLOCK, DRUID.
Multiple specs can share a guideKey (e.g. Arms + Fury both use `"warrior-dps"`).

### `C.ARMORY_SPEC_BIS_DATABASE` (line 76)

```lua
C.ARMORY_SPEC_BIS_DATABASE = {
    [phase] = {
        [guideKey] = {
            [slot] = {
                bis  = { item_data },
                alts = { { item_data }, ... },
            },
        },
    },
}
```

**Item data shape:**
```lua
{
    id           = number,       -- WoW item ID (e.g. 29021)
    name         = string,       -- "Warbringer Battle-Helm"
    source       = string,       -- "Prince Malchezaar" or "G'eras (50 Badges)"
    sourceType   = string,       -- "raid"/"heroic"/"badge"/"rep"/"crafted"/"quest"/"pvp"/"dungeon"
    -- Optional fields (not always present):
    sourceDetail = string|nil,
    iLvl         = number|nil,
    quality      = string|nil,   -- "epic", "rare", etc.
    icon         = string|nil,
    stats        = table|nil,
}
```

**Populated phases:** 0 (Pre-Raid) and 1 (Karazhan era) - fully populated with all 18 guideKeys.
**Empty placeholders:** Phases 2, 3, 4, 5 (lines 4299-4302).

### `C.ARMORY_REP_SOURCE_MAP` (line 4468)

Maps reputation source strings to structured faction/standing data:
```lua
["Lower City Exalted"] = { faction = "Lower City", standing = 8 }
["Honor Hold/Thrallmar Exalted"] = { factionAlliance = "Honor Hold", factionHorde = "Thrallmar", standing = 8 }
```

Standing values: 5=Friendly, 6=Honored, 7=Revered, 8=Exalted.

### Helper Functions

| Line | Function | Purpose |
|------|----------|---------|
| 4310 | `C:GetSpecBisGear(phase, specKey, slot)` | Returns {bis, alts} for phase/spec/slot |
| 4317 | `C:GetSpecBisSlots(phase, specKey)` | Returns all slots for a spec/phase |
| 4324 | `C:GetClassSpecs(classToken)` | Returns spec array for a class |
| 4329 | `C:GetSpecByGuideKey(guideKey)` | Finds spec entry by guideKey, returns (spec, className) |
| 4343 | `ConvertToLegacyFormat(slotData)` | (local) Converts new->legacy format (id->itemId, bis->best) |
| 4387 | `C:GetSpecBisGearLegacy(phase, specKey, slot)` | GetSpecBisGear + ConvertToLegacyFormat |
| 4393 | `TIER_TO_PHASE` | (local table) Maps T4=1, T5=2, T6=3 |
| 4401 | `C:GetGuideKeyForRole(classToken, role)` | Finds guideKey by class+role |
| 4417 | `C:GetArmoryGearFromSpec(tier, role, slot, classToken)` | Bridge: tier->phase->guideKey->legacy BiS data |
| 4434 | `C:IsItemBisForSpec(itemName, bossName, guideKey, raidPhase)` | Checks if item is BiS across phases |
| 4452 | `C:GetCurrentPlayerGuideKey()` | Detects current player's guideKey |
| 4522 | `C:ParseReputationSource(source)` | Parses "Lower City Exalted" -> {faction, standing} |
| 4560 | `C:GetSpecReputationBisItems(guideKey, phase)` | All rep-sourced items for a spec |
| 4620 | `C:GetBossRaidKey(bossName)` | Resolves boss name -> raid key |
| 4661 | `C:IndexBisItem(item, slot, isBis, phase)` | Indexes item into bisLookupCache |
| 4708 | `C:BuildBisLookupTables(guideKey, phase)` | Builds inverted lookup indexes |
| 4770 | `C:EnsureBisLookupCurrent(guideKey, phase)` | Rebuilds lookup only if stale |
| 4788 | `C:GetBisItemsForFaction(factionName)` | Lookup: faction -> BiS items |
| 4798 | `C:GetBisItemsForBoss(bossName)` | Lookup: boss -> BiS items |
| 4808 | `C:GetBisInfoForItem(itemId)` | Lookup: itemId -> {slot, isBis, sourceType, source} |
| 4818 | `C:IsItemBisInLookup(itemId)` | Boolean: is item the BiS (not alt)? |
| 4825 | `C:GetBisLookupMeta()` | Returns {guideKey, phase, buildTime} |
| 4831 | `C:GetBisLookup()` | Getter for full bisLookupCache |
| 4847 | `C:WarmupReputationItemCache()` | Pre-fetches Phase 1 rep item data |

### BiS Lookup Cache Structure (module-level `bisLookupCache`)

```lua
{
    byFaction = { [factionName] = { { itemId, name, slot, standing, isBis }, ... } },
    byBoss    = { [bossName]    = { { itemId, name, slot, isBis, raidKey }, ... } },
    byItemId  = { [itemId]      = { slot, isBis, sourceType, source } },
    meta      = { guideKey = string, phase = number, buildTime = number },
}
```

---

## 6. Key Flows

### Flow 1: Tab Open

```
1. PopulateArmory()                          -- Journal.lua:14819
2.   CreateArmoryPools()                     -- :14994
3.   Load saved state from charDb.armory
4.   CreateArmoryContainer()                 -- :15447
5.     CreateArmoryPhaseBar()                -- :15497
6.       CreateArmoryPhaseButtons()          -- :15535
7.       CreateArmorySpecDropdown()          -- :15677
8.     CreateArmoryCharacterView()           -- :15727
9.       CreateArmoryModelFrame()            -- :15763
10.      CreateArmorySlotsContainer()        -- :15834
11.        CreateArmorySlotButtons()         -- :15879
12.          CreateSingleArmorySlotButton()  -- :15961 (x17)
13.    CreateArmoryFooter()                  -- :16416
14.      CreateArmoryFooterButtons()         -- :16500
15.  RefreshArmorySlotData()                 -- :16920
16.    RefreshSingleSlotData(btn)            -- :16929 (x17)
17.      CalculateSlotUpgradeStatus()        -- :16989
18.      UpdateArmorySlotVisual()            -- :17022
19.  UpdateArmoryInfoCards()                 -- :16373
20.    GetAverageEquippedILvl()              -- :16098
21.    CreateSlotInfoCard()                  -- :16217 (x17)
22.  UpdateArmoryFooter()                    -- :16645
23.    CalculateArmoryStats()                -- :16660
```

### Flow 2: Slot Click

```
1. OnArmorySlotClick(slotName)               -- Journal.lua:17265
2.   [if same slot + visible]: HideArmoryGearPopup()  -- :18038
3.   [if new slot]:
4.     Deselect previous slot
5.     Select new slot (ARCANE_PURPLE border)
6.     ShowArmoryGearPopup(slotName, btn)    -- :17932
7.       GetArmoryGearPopup()                -- :17678 (lazy create)
8.       PopulateArmoryGearPopup(slotName)   -- :18049
9.         ReleaseArmoryPopupFrames()        -- :17900
10.        GetArmoryGearData(slotName)       -- :17224
11.          GetCurrentArmoryGuideKey()      -- :17123
12.          C:GetSpecBisGearLegacy()        -- ArmoryBisData:4387
13.          FilterGearByClass()             -- :17155
14.        PopulateBisCard(popup, bisItem)   -- :18163
15.        CreateArmoryPopupItemRow()        -- :18281 (per alt)
16.      RegisterArmoryClickAwayHandler()    -- :18496
```

### Flow 3: Phase Change

```
1. SelectArmoryPhase(phase)                  -- Journal.lua:18551
2.   Set armoryState.selectedPhase
3.   SetPhaseButtonState() (for each button) -- :15641
4.   RefreshArmorySlotData()                 -- :16920
5.     RefreshSingleSlotData(btn)            -- :16929 (x17)
6.       CalculateSlotUpgradeStatus()        -- :16989
7.       UpdateArmorySlotVisual()            -- :17022
8.   UpdateArmoryInfoCards()                 -- :16373
9.   UpdateArmoryFooter()                    -- :16645
10.  [if popup visible]:
11.    ShowArmoryGearPopup(lastSlot)         -- :17932
12.      PopulateArmoryGearPopup()           -- :18049
13.        GetArmoryGearData()               -- :17224
14.        PopulateBisCard()                 -- :18163
15.        CreateArmoryPopupItemRow()        -- :18281
16.  Save to charDb
```

---

## 7. Modification Guide

### Add a new phase (e.g. Phase 6)
1. **Constants.lua** `C.ARMORY_PHASE_BUTTON.PHASES` (~line 7385): Add `[6]` entry with label, color, tooltip data
2. **Constants.lua** `C.ARMORY_PHASES` (~line 8219): Add `[6]` entry with name, color, raids, sources
3. **ArmoryBisData.lua** `C.ARMORY_SPEC_BIS_DATABASE` (~line 4302): Add `[6] = {}` then populate with guideKey->slot data
4. **Journal.lua** `CreateArmoryPhaseButtons()` (~line 15535): Add `6` to the phases iteration list

### Add a new equipment slot
1. **Constants.lua** `C.ARMORY_SLOT_BUTTON.SLOTS` (~line 7750): Add slot with displayName and slotId
2. **Constants.lua** `C.ARMORY_SLOT_BUTTON.POSITIONS`: Add position for the new slot
3. **Constants.lua** `C.ARMORY_SLOT_PLACEHOLDER_ICONS` (~line 7839): Add placeholder texture
4. **ArmoryBisData.lua**: Add slot key to all guideKey entries in `C.ARMORY_SPEC_BIS_DATABASE`

### Change popup layout
- **Dimensions:** `C.ARMORY_GEAR_POPUP` (Constants.lua:7590) - WIDTH, MAX_HEIGHT, CARD heights
- **Card styling:** `C.ARMORY_GEAR_POPUP.BIS_CARD` and `C.ARMORY_GEAR_POPUP.ITEM`
- **Position per slot:** `C.ARMORY_GEAR_POPUP.POSITION_OFFSETS`
- **Frame creation:** `GetArmoryGearPopup()` (Journal.lua:17678)
- **Content:** `PopulateBisCard()` (Journal.lua:18163), `CreateArmoryPopupItemRow()` (Journal.lua:18281)

### Modify BiS data
- **Spec-based (primary):** `C.ARMORY_SPEC_BIS_DATABASE` in ArmoryBisData.lua (line 76)
- **Role-based (legacy):** `C.ARMORY_GEAR_DATABASE` in Constants.lua (line 8348)
- **Item format:** `{ id=number, name=string, source=string, sourceType=string }`
- **Access path:** `C.ARMORY_SPEC_BIS_DATABASE[phase][guideKey][slot].bis` or `.alts[n]`

### Add a new source type
1. **Constants.lua** `C.ARMORY_SOURCE_COLORS` (line 8021): Add RGB color
2. **Constants.lua** `C.ARMORY_SOURCE_TYPES` (line 8265): Add color, icon, label
3. **Constants.lua** `C.ARMORY_GEAR_POPUP.SOURCE_GROUPS` (~line 7590): Add with order, label, shortLabel, color, icon
4. **Journal.lua** `BuildBasicHoverData()` (line 17628): Add sourceType case for tooltip
5. **ArmoryBisData.lua**: Use new sourceType string in item entries

---

## Appendix: Function Count Summary

| Subsystem | Functions |
|-----------|-----------|
| Initialization | 4 |
| Phase Bar | 4 |
| Spec Dropdown | 2 |
| Character View | 2 |
| Slot System | 7 |
| Info Cards | 7 |
| Gear Popup | 9 |
| BiS Preview | 10 |
| Footer | 6 |
| Tooltips | 5 |
| Event Handlers | 2 |
| Data Layer (Journal.lua) | 6 |
| Pool Initializers | 4 |
| **Journal.lua subtotal** | **68** |
| Data Layer (ArmoryBisData.lua) | 23 |
| **Grand total** | **91** |

---

## 8. Event Handlers Reference

Complete reference of all `SetScript` handlers in the armory UI, organized by component. All in `Journal/Journal.lua`.

### 8.1 Info Card Pool (line 15020)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnEnter` | 15122 | Brightens border to `HIGHLIGHT_COLOR`, shows pulsing `glowOverlay` via `glowAnim:Play()`, slides chevron 2px right, plays hover sound |
| `OnLeave` | 15142 | Restores border to `storedRankColor` (or default `BORDER_COLOR`), stops `glowAnim`, hides `glowOverlay`, resets chevron to `chevronBaseX` |
| `OnMouseDown` | 16358 | Plays click sound, calls `OnArmorySlotClick(slotName)` - same as clicking the slot button |

### 8.2 BiS Card Pool (line 15223)

| Handler | Line | Behavior |
|---------|------|----------|
| `tryOnBtn OnEnter` | 15305 | Sets border to gold `(1, 0.84, 0)`, plays hover sound |
| `tryOnBtn OnLeave` | 15309 | Resets border to grey `(0.5, 0.5, 0.5)` |
| `tryOnBtn OnClick` | 18236 | Set in `PopulateBisCard()` - plays click sound, calls `PreviewItemOnModel(bisItem)` |
| `card OnMouseUp` | 18246 | Set in `PopulateBisCard()` - Shift+click: `ChatEdit_InsertLink` or `DressUpItemLink`; Ctrl+click: `PreviewItemOnModel` |
| `card OnEnter` | 18263 | Set in `PopulateBisCard()` - calls `BuildArmoryGearTooltip(itemData, self)` |
| `card OnLeave` | 18266 | Set in `PopulateBisCard()` - hides GameTooltip |

### 8.3 Popup Item Row Pool (line 15332)

| Handler | Line | Behavior |
|---------|------|----------|
| `tryOnBtn OnEnter` | 15413 | Sets border to gold, plays hover sound |
| `tryOnBtn OnLeave` | 15417 | Resets border to grey |
| `tryOnBtn OnClick` | 18355 | Set in `CreateArmoryPopupItemRow()` - plays click sound, calls `PreviewItemOnModel(itemData)` |
| `row OnClick` | 18361 | Set in `CreateArmoryPopupItemRow()` - Shift+click: chat link or dressing room; Ctrl+click: model preview; plain click: click sound |
| `row OnEnter` | 18378 | Set in `CreateArmoryPopupItemRow()` - shows highlight `(0.5, 0.45, 0.35, 0.2)`, plays hover, shows gear tooltip |
| `row OnLeave` | 18383 | Set in `CreateArmoryPopupItemRow()` - clears highlight, hides tooltip |

### 8.4 Phase Buttons (line 15535)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnClick` | 15582 | Plays click sound, calls `SelectArmoryPhase(phase)` |
| `OnEnter` | 15588 | Plays hover sound, sets button to `"hover"` state, shows enhanced tooltip (raids, gear sources, recommended iLvl) |
| `OnLeave` | 15623 | Restores button to `"active"` or `"inactive"` state, hides tooltip |

### 8.5 Model Frame (line 15763)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnMouseDown` | 15789 | Sets `isDragging = true`, captures cursor X position to `lastX` |
| `OnMouseUp` | 15796 | Sets `isDragging = false` |
| `OnUpdate` | 15806 | Throttled at ~60fps (`MODEL_DRAG_THROTTLE = 0.016`). Early-exits if not dragging. Calculates cursor delta, applies `ROTATION_SPEED` multiplier, tracks rotation in local `currentRotation` closure |

### 8.6 Slot Buttons (line 15961)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnClick` | 16066 | Plays click sound, calls `OnArmorySlotClick(slotName)` |
| `OnEnter` | 16072 | Plays hover sound, calls `OnArmorySlotEnter(btn)` for tooltip |
| `OnLeave` | 16077 | Calls `OnArmorySlotLeave(btn)` to hide tooltip |

### 8.7 Footer Buttons (line 16500)

| Handler | Line | Behavior |
|---------|------|----------|
| BIS `OnEnter` | 16520 | Overrides generic - plays hover, applies `hoverColor` bg, white border/text, calls `BuildBISTooltip(btn)` |
| BIS `OnLeave` | 16530 | Overrides generic - checks `_activeModeColors` for preview mode restoration, otherwise restores from constants |
| BIS `OnClick` | 16513 | Calls `OnBISButtonClick()` |
| RESET `OnClick` | 16556 | Calls `OnRESETButtonClick()` |
| Generic `OnEnter` | 16595 | Brightens bg 1.5x, white border/text, shows tooltip |
| Generic `OnLeave` | 16613 | Restores `normalBg` and `normalBorder` colors, hides tooltip |

### 8.8 Gear Popup Header (line 17713)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnDragStart` | 17722 | Calls `popup:StartMoving()`, sets `isBeingDragged = true` |
| `OnDragStop` | 17727 | Calls `popup:StopMovingOrSizing()`, sets `isBeingDragged = false`, flags `hasBeenMoved = true` |
| `OnEnter` | 17734 | Sets cursor to Move icon |
| `OnLeave` | 17738 | Resets cursor to default |

### 8.9 Gear Popup Close Button (line 17756)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnClick` | 17762 | Plays click sound, calls `HideArmoryGearPopup()` |

### 8.10 Gear Popup Footer Buttons (line 17798)

| Handler | Line | Behavior |
|---------|------|----------|
| tryOnSetBtn `OnEnter` | 17819 | Gold border, hover sound |
| tryOnSetBtn `OnLeave` | 17823 | Tan border reset |
| tryOnSetBtn `OnClick` | 17826 | Click sound, calls `TryOnBisSet()` |
| resetBtn `OnEnter` | 17847 | Gold border, hover sound |
| resetBtn `OnLeave` | 17851 | Tan border reset |
| resetBtn `OnClick` | 17854 | Click sound, calls `ResetModelToEquipped()` |

### 8.11 Gear Popup Lifecycle (line 17875)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnShow` | 17875 | Calls `RegisterArmoryClickAwayHandler()` |
| `OnHide` | 17879 | Calls `UnregisterArmoryClickAwayHandler()` + `ReleaseArmoryPopupFrames()` |
| `OnKeyDown` | 17886 | ESC key calls `HideArmoryGearPopup()`. Has `SetPropagateKeyboardInput(true)` |

### 8.12 Click-Away Handler (line 18496)

| Handler | Line | Behavior |
|---------|------|----------|
| `OnClick` | 18508 | Checks `gearPopup:IsMouseOver()` - if over popup, returns (no-op). Otherwise calls `HideArmoryGearPopup()`, deselects slot, resets visual |

---

## 9. Internal State Reference

All per-frame state fields set at runtime on pooled or singleton frames. These are **not** part of `armoryState`/`armoryUI` but are stored directly on frame objects.

### 9.1 armoryUI Runtime Fields

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `armoryUI.cachedAvgILvl` | number | 16386 | Average iLvl cached during `UpdateArmoryInfoCards()`, used by `GetSlotUpgradeStatus()` |
| `armoryUI.infoCards` | table | 16389 | `{ [slotName] = cardFrame }` - references to all active info card pool frames |

### 9.2 Model Frame State

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `modelFrame.isDragging` | boolean | 15791 | True while left-button held for rotation |
| `modelFrame.lastX` | number | 15792 | Last cursor X position for delta calculation |
| Local `currentRotation` | number | 15805 | Closure variable tracking model rotation (no `GetFacing()` on DressUpModel) |
| Local `modelDragThrottle` | number | 15803 | Closure variable for 60fps throttle accumulator |

### 9.3 Gear Popup Per-Frame Fields

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `popup.bisCardFrame` | frame\|nil | 17785, 18271 | Currently displayed BiS card (pooled) |
| `popup.itemRows` | array | 17869 | Array of currently displayed alt item rows (pooled) |
| `popup.emptyFontStrings` | array | 17870 | Orphan FontStrings for cleanup on re-populate |
| `popup.isBeingDragged` | boolean | 17724 | True while header is being dragged |
| `popup.hasBeenMoved` | boolean | 17730 | True after user manually repositioned - prevents auto-reposition on slot change |

### 9.4 Info Card Per-Frame Fields

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `card.storedRankColor` | table\|nil | 15113, 16273 | `{r,g,b}` rank color for OnLeave border restoration |
| `card.slotName` | string | 16250 | Slot name for click-through to `OnArmorySlotClick` |
| `card.slotState` | string | 16277-16343 | `"RANKED"`, `"NOT_RANKED"`, `"EMPTY"`, or `"LOADING"` |
| `card.rankGlow` | texture | 15070 | Background glow texture for BiS #1 items (pulsing animation) |
| `card.chevronBaseX` | number | 15116 | Base X offset for chevron animation reset |

### 9.5 Slot Button Saved State (BiS Preview)

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `btn._savedIconTexture` | texture\|nil | 16742 | Original icon before BiS preview swap |
| `btn._savedIconShown` | boolean | 16743 | Whether icon was visible before swap |
| `btn._savedPlaceholderShown` | boolean | 16744 | Whether placeholder was visible before swap |

### 9.6 BiS Card & Item Row Data

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `card.itemData` / `row.itemData` | table | 18242, 18292 | Item data table for tooltip on hover |
| `card.itemId` / `row.itemId` | number | 18243, 18293 | Item ID for chat linking |

### 9.7 BIS Button State

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `bisBtn._activeModeColors` | table\|nil | 16812 | `{bg, border, text}` colors for active preview mode, checked in OnLeave |

### 9.8 Click-Away Singleton

| Field | Type | Set At | Purpose |
|-------|------|--------|---------|
| `self.armoryClickAwayFrame` | frame\|nil | 18503, 18529 | Singleton button frame, parented to characterView, shown/hidden per popup lifecycle |

### 9.9 armoryState.popup Fields

| Field | Type | Purpose | Status |
|-------|------|---------|--------|
| `popup.lastSlot` | string\|nil | Last slot populated in popup, used by `RefreshArmoryRecommendations()` | Active |
| `popup.acquiredItems` | table | `{ [itemId] = true }` cache of owned items | **Appears unused** - populated in state init but never read by armory UI code |

---

## 10. Pool Reset Mechanics

Each pool has an initializer (creates frame structure) and a reset closure (cleans frame for reuse). Reset closures are defined inline in `CreateArmoryPools()` (line 14994).

| Pool | Init Lines | Reset Lines | Key Reset Actions |
|------|-----------|-------------|-------------------|
| `infoCard` | 15020-15116 | 15171-15215 | Hide, clear text, reset chevron, stop glowAnim+rankGlowAnim, hide gradeIndicator, clear `storedRankColor`+`slotName`+`slotState`, remove OnMouseDown |
| `bisCard` | 15223-15313 | 15316-15328 | Hide, clear icon/text/sourceBadge, remove tryOnBtn OnClick |
| `popupItemRow` | 15332-15421 | 15424-15439 | Hide, reset border/highlight colors, clear icon/text/sourceBadge, remove tryOnBtn+row OnClick |
| `upgradeCard` | 18594-18625 | 18627-18633 | Hide, clear itemData/isWishlisted/isBest |
| `sectionHeader` | 18635-18664 | 18666-18672 | Hide, clear sectionId/isExpanded/sectionColor |

**`ReleaseArmoryPopupFrames()`** (line 17900): Releases `bisCardFrame` and all `itemRows` back to their pools, cleans up `emptyFontStrings`. Called on popup hide and before re-population.

---

## 11. Cross-System Integration

External module calls made from armory code in `Journal.lua`.

| External Call | Used At | Purpose |
|---------------|---------|---------|
| `HopeAddon:GetGearScore()` | 16668 | Returns `(gearScore, avgILvl)` for footer stats |
| `HopeAddon:GetSpecRole(classToken, specTab)` | 17110, 17116, 17139 | Returns role string (`"tank"`, `"melee_dps"`, etc.) for spec resolution |
| `HopeAddon:GetPlayerSpec()` | 15695, 16871, 17115, 17132 | Returns `(specName, specTab, specPoints)` for auto-detect |
| `C:GetClassSpecs(classToken)` | 17126 | Returns spec array from `ARMORY_SPECS` for guideKey lookup |
| `C:GetSpecBisGearLegacy(phase, guideKey, slot)` | 17232 | Primary BiS data access, returns legacy format `{best, alternatives}` |
| `C:GetPhaseColorForItemLevel(iLvl)` | 18204, 18324 | Maps iLvl to phase color name for BiS card and item row iLvl text coloring |
| `HopeAddon.Sounds:PlayClick()` | multiple | Sound feedback on button clicks |
| `HopeAddon.Sounds:PlayHover()` | multiple | Sound feedback on button hover |

### Tab Lifecycle Integration

| Call | Line | Context |
|------|------|---------|
| `MinigamesUI:OnTabHide()` | 14980-14981 | Called from `HideGamesTab()` to clean up game timers/popups |
| `Minigames:OnTabHide()` | 14986-14987 | Called from `HideGamesTab()` to clean up local RPS game state |

---

## 12. UI Mechanics Detail

### 12.1 Model Drag Rotation
- Throttled at 60fps via local `MODEL_DRAG_THROTTLE = 0.016` (line 15804)
- Rotation tracked in local closure variable `currentRotation` (line 15805) because `DressUpModel:GetFacing()` doesn't exist in TBC Classic
- Delta calculated as `(currentX - lastX) * ROTATION_SPEED` and applied via `SetRotation(currentRotation)` (line 15817)
- Only processes in `OnUpdate` when `isDragging == true` (early exit at line 15807)

### 12.2 Phase Button Enhanced Tooltip
- Title in gold: `phaseConfig.tooltip` (line 15594)
- Raids section (fel green header): iterates `phaseConfig.raids[]` (line 15597-15603)
- Gear sources section (sky blue header): iterates `phaseConfig.gearSources[]` (line 15606-15612)
- Recommended iLvl (grey): `phaseConfig.recommendedILvl` (line 15615-15618)
- All config in `C.ARMORY_PHASE_BUTTON.PHASES[phase]`

### 12.3 Popup Drag-to-Reposition
- Header is registered for drag via `RegisterForDrag("LeftButton")` (line 17720)
- `popup.hasBeenMoved` flag (line 17730) set on `OnDragStop`
- Flag is reset to `false` on each `ShowArmoryGearPopup()` call (line 17937), so each new slot click repositions to that slot
- Cursor changes to Move icon on header hover (lines 17734-17740)

### 12.4 Shift+Click / Ctrl+Click Item Interaction
- **Shift+click**: Attempts `ChatEdit_InsertLink(itemLink)` to paste in chat. Falls back to `DressUpItemLink(itemLink)` to open dressing room (lines 18248-18253, 18362-18368)
- **Ctrl+click**: Calls `PreviewItemOnModel(itemData)` to try on single item (lines 18255-18258, 18369-18371)
- Works on both BiS cards (`OnMouseUp` at 18246) and item rows (`OnClick` at 18361)

### 12.5 Dynamic Popup Height Calculation
- Height = `HEADER_HEIGHT + 8 + totalCardsHeight + FOOTER_HEIGHT + 8` (line 18149)
- `totalCardsHeight` = sum of `BIS_CARD_HEIGHT + CARD_GAP` for BiS card + `ALT_CARD_HEIGHT + CARD_GAP` per alternative
- Clamped between `MIN_HEIGHT` and `MAX_HEIGHT` via `math.max(math.min(...))` (line 18150)

### 12.6 Empty State Messages
- Shown when `GetArmoryGearData()` returns nil or no best/alternatives (line 18079)
- Primary: "No gear data for Phase X yet" (line 18092)
- Secondary hint: checks `HasArmoryPhaseData(1)` and shows "Phase 1 data is available." in green, or "No phase data available." in tan (lines 18099-18104)
- Empty FontStrings tracked in `popup.emptyFontStrings` for cleanup

---

## 13. Detailed Flows

### Flow 4: Click-Away Dismiss

```
1. RegisterArmoryClickAwayHandler()          -- :18496
2.   Create/reuse "HopeArmoryClickAway" Button
3.   Parent to characterView, SetAllPoints
4.   Frame level: characterView + 2 (above model, below slots)
5.   Show frame
6.
7. User clicks empty space in characterView:
8.   OnClick fires on click-away frame       -- :18508
9.   Check gearPopup:IsMouseOver()           -- :18513
10.  [if over popup]: return (no-op)
11.  [if not over popup]:
12.    HideArmoryGearPopup()                 -- :18518
13.    Deselect slot, reset visual           -- :18520-18527
```

### Flow 5: Model Drag Rotation

```
1. OnMouseDown("LeftButton")                 -- :15789
2.   isDragging = true, lastX = GetCursorPosition()
3.
4. OnUpdate(elapsed) [every frame]           -- :15806
5.   [if not isDragging]: return             -- early exit
6.   Accumulate modelDragThrottle += elapsed
7.   [if < 0.016]: return                   -- 60fps throttle
8.   Reset throttle = 0
9.   currentX = GetCursorPosition()
10.  [if currentX == lastX]: return          -- no movement
11.  delta = (currentX - lastX) * ROTATION_SPEED
12.  currentRotation += delta
13.  SetRotation(currentRotation)
14.  lastX = currentX
15.
16. OnMouseUp("LeftButton")                  -- :15796
17.  isDragging = false
```

### Flow 6: Info Card Hover Animation

```
1. OnEnter                                   -- :15122
2.   Set border to HIGHLIGHT_COLOR
3.   Show glowOverlay + start glowAnim (pulsing 0.1-0.25 alpha, 0.5s bounce)
4.   Slide chevron right by 2px
5.   Play hover sound
6.
7. OnLeave                                   -- :15142
8.   [if storedRankColor]: restore border to rank color
9.   [else]: restore to default BORDER_COLOR
10.  Stop glowAnim, hide glowOverlay
11.  Reset chevron to chevronBaseX
```

### Flow 7: Popup Drag-to-Reposition

```
1. Header OnDragStart                        -- :17722
2.   popup:StartMoving()
3.   isBeingDragged = true
4.
5. Header OnDragStop                         -- :17727
6.   popup:StopMovingOrSizing()
7.   isBeingDragged = false
8.   hasBeenMoved = true                     -- prevents auto-repos
9.
10. Next ShowArmoryGearPopup() call          -- :17937
11.  hasBeenMoved = false                    -- reset for new slot
12.  Position popup relative to new slot
```

---

## 14. Unused BiS Cache Functions (Dead Code)

8 functions in `ArmoryBisData.lua` (lines 4708-4831) that build inverted lookup indexes but are **never called** from the armory UI in `Journal.lua`. They were designed for cross-system lookups (e.g., "which BiS items drop from this boss?" or "which BiS items need this faction rep?") but no UI currently consumes them.

| Line | Function | Purpose | Callers |
|------|----------|---------|---------|
| 4708 | `C:BuildBisLookupTables(guideKey, phase)` | Builds `bisLookupCache` with byFaction/byBoss/byItemId indexes | None in Journal.lua |
| 4770 | `C:EnsureBisLookupCurrent(guideKey, phase)` | Rebuilds lookup if stale (checks meta.guideKey/phase match) | None in Journal.lua |
| 4788 | `C:GetBisItemsForFaction(factionName)` | Returns array of BiS items for a faction | None in Journal.lua |
| 4798 | `C:GetBisItemsForBoss(bossName)` | Returns array of BiS items from a boss | None in Journal.lua |
| 4808 | `C:GetBisInfoForItem(itemId)` | Returns {slot, isBis, sourceType, source} for an item | None in Journal.lua |
| 4818 | `C:IsItemBisInLookup(itemId)` | Boolean check if item is BiS (not alt) | None in Journal.lua |
| 4825 | `C:GetBisLookupMeta()` | Returns {guideKey, phase, buildTime} metadata | None in Journal.lua |
| 4831 | `C:GetBisLookup()` | Raw getter for full `bisLookupCache` table | None in Journal.lua |

**Note:** These functions may be used by the Reputation tab or Raids tab for BiS badge overlays. Check `Reputation.lua` and raid loot popup code before removing. The `WarmupReputationItemCache()` function (line 4847) in the same file **is** actively called on PLAYER_LOGIN.
