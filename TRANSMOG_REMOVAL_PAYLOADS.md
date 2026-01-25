# Transmog Removal - Execution Payloads

**Status:** VERIFIED AND READY
**Last Accuracy Check:** 2026-01-25
**Total Estimated Lines Changed:** ~2,000 lines removed

---

## Pre-Flight Verification Summary

| Item | Expected | Verified |
|------|----------|----------|
| Transmog tab registration | Line 926 | ✅ Confirmed |
| Armory tab registration | Line 927 | ✅ Confirmed |
| Stats migration | Lines 1047-1051 | ✅ Confirmed |
| Tab routing - transmog | Lines 1065-1066 | ✅ Confirmed |
| Tab routing - armory | Lines 1067-1068 | ✅ Confirmed |
| transmogState table | Lines 9037-9048 | ✅ Confirmed |
| transmogUI table | Lines 9050-9063 | ✅ Confirmed |
| armoryUI table | Lines 9069-9081 | ✅ Confirmed |
| armoryState table | Lines 9083-9090 | ✅ Confirmed |
| armoryPools table | Lines 9092-9098 | ✅ Confirmed |
| TIER_COLORS local | Lines 9101-9105 | ✅ Confirmed |
| TRANSMOG_RAID_INFO local | Lines 9108-9123 | ✅ Confirmed |
| SLOT_INFO local | Lines 9126-9132 | ✅ Confirmed |
| First transmog function | Line 9137 CreateTransmogContainers | ✅ Confirmed |
| Last transmog function | Line 10238 HideTransmogTab end | ✅ Confirmed |
| First armory function | Line 10248 PopulateArmory | ✅ Confirmed |
| Constants TRANSMOG_UI | Lines 3309-3325 | ✅ Confirmed |
| Constants TRANSMOG_RAIDS | Lines 3328-3343 | ✅ Confirmed |
| Constants TIER_SETS | Lines 3350-3824 | ✅ Confirmed |
| Constants GetTierSet | Lines 3827-3831 | ✅ Confirmed |
| Constants GetAvailableSpecs | Lines 3834-3844 | ✅ Confirmed |
| Constants LIGHTING_* | Lines 3851-4054 | ✅ Confirmed |
| Core.lua transmog default | Lines 1415-1425 | ✅ Confirmed |
| Core.lua transmog migration | Lines 1040-1048 | ✅ Confirmed |

---

## PAYLOAD 1: Add Migration (Safety First)

**Purpose:** Prevent crashes if users have "transmog" saved as lastTab

### File: `HopeAddon/Journal/Journal.lua`

**Location:** After line 1051 (after stats migration block)

**ADD this code:**
```lua
    -- Migration: "transmog" tab removed, redirect to armory
    if tabId == "transmog" then
        tabId = "armory"
        self.currentTab = tabId
    end
```

**Verification:** This goes BEFORE the `if tabId == "journey"` block at line 1053

---

## PAYLOAD 2: Remove Transmog Tab Registration

**Purpose:** Remove tab from tab bar

### File: `HopeAddon/Journal/Journal.lua`

**Location:** Line 926

**REMOVE this line:**
```lua
        { id = "transmog", label = "Transmog", tooltip = "Preview legendary tier sets", color = "LEGENDARY" },
```

**Result:** Tab bar goes from 8 tabs to 7 tabs

---

## PAYLOAD 3: Remove Transmog Tab Routing

**Purpose:** Remove the elseif branch for transmog in SelectTab

### File: `HopeAddon/Journal/Journal.lua`

**Location:** Lines 1065-1066

**REMOVE these lines:**
```lua
    elseif tabId == "transmog" then
        self:PopulateTransmog()
```

---

## PAYLOAD 4: Remove Transmog State and Local Tables

**Purpose:** Remove state tables and local helper tables for transmog

### File: `HopeAddon/Journal/Journal.lua`

**Location:** Lines 9031-9132 (from comment `-- TRANSMOG TAB` to end of `SLOT_INFO`)

**REMOVE this entire block (102 lines):**
```lua
--[[
    TRANSMOG TAB
    Preview tier set gear and plan collections
]]

-- State tables for Transmog tab
Journal.transmogState = {
    selectedTier = 4,
    selectedRaid = "karazhan",
    selectedSpec = nil,
    selectedCategory = "warm",
    selectedPreset = "default",
    modelRotation = 0,
    isRotating = false,
    rotateStartX = 0,
    currentSetData = nil,
    currentItemIcons = {},
}

Journal.transmogUI = {
    container = nil,
    sidebar = nil,
    preview = nil,
    model = nil,
    tierButtons = {},
    raidButtons = {},
    specDropdown = nil,
    slotButtons = {},
    categoryButtons = {},
    presetDropdown = nil,
    setNameLabel = nil,
    setInfoLabel = nil,
}

-- ... (armory tables stay - lines 9065-9098)

-- Tier colors for visual consistency (must match C.ARMORY_TIER_BUTTON.TIERS)
local TIER_COLORS = {
    [4] = "FEL_GREEN",
    [5] = "SKY_BLUE",
    [6] = "HELLFIRE_RED",
}

-- Raid display names by tier
local TRANSMOG_RAID_INFO = {
    [4] = {
        { key = "karazhan", name = "Karazhan", short = "Kara" },
        { key = "gruul", name = "Gruul's Lair", short = "Gruul" },
        { key = "magtheridon", name = "Magtheridon's Lair", short = "Mag" },
    },
    [5] = {
        { key = "ssc", name = "Serpentshrine Cavern", short = "SSC" },
        { key = "tk", name = "Tempest Keep", short = "TK" },
    },
    [6] = {
        { key = "hyjal", name = "Hyjal Summit", short = "Hyjal" },
        { key = "bt", name = "Black Temple", short = "BT" },
        { key = "swp", name = "Sunwell Plateau", short = "SWP" },
    },
}

-- Slot display order and names
local SLOT_INFO = {
    { slot = "head", name = "Head", icon = "INV_Helmet_24" },
    { slot = "shoulders", name = "Shoulders", icon = "INV_Shoulder_01" },
    { slot = "chest", name = "Chest", icon = "INV_Chest_Chain" },
    { slot = "hands", name = "Hands", icon = "INV_Gauntlets_01" },
    { slot = "legs", name = "Legs", icon = "INV_Pants_01" },
}
```

**KEEP:** Lines 9065-9098 (armoryUI, armoryState, armoryPools tables)

**Exact range to delete:** Lines 9031-9063 (transmog comment + state + UI tables) AND lines 9100-9132 (TIER_COLORS + TRANSMOG_RAID_INFO + SLOT_INFO)

---

## PAYLOAD 5: Remove All Transmog Functions

**Purpose:** Remove all 18 transmog functions (~1,100 lines)

### File: `HopeAddon/Journal/Journal.lua`

**Location:** Lines 9134-10238

**REMOVE this entire block** (from `--[[ Create the Transmog tab containers` to end of `HideTransmogTab()`):

Functions being removed:
1. `CreateTransmogContainers()` - Line 9137
2. `CreateTransmogSidebar()` - Line 9180
3. `CreateTransmogPreview()` - Line 9308
4. `InitLightingPresetDropdown()` - Line 9495
5. `SelectLightingCategory()` - Line 9527
6. `SelectLightingPreset()` - Line 9566
7. `ApplyLightingPreset()` - Line 9589
8. `CreateTransmogSlotButton()` - Line 9626
9. `SelectTransmogTier()` - Line 9704
10. `UpdateTransmogRaidButtons()` - Line 9738
11. `SelectTransmogRaid()` - Line 9806
12. `UpdateTransmogSpec()` - Line 9839
13. `UpdateTransmogSlots()` - Line 9903
14. `PreviewTierSet()` - Line 10011
15. `WarmItemCache()` - Line 10064
16. `RefreshTransmogPreview()` - Line 10132
17. `PopulateTransmog()` - Line 10143
18. `HideTransmogTab()` - Line 10219

**Exact deletion range:** From line 9134 (comment before CreateTransmogContainers) through line 10238 (closing `end` of HideTransmogTab)

**KEEP:** Line 10240+ (ARMORY TAB FUNCTIONS comment and all armory functions)

---

## PAYLOAD 6: Remove Transmog SavedVariables Default

**Purpose:** Remove default charDb structure for transmog

### File: `HopeAddon/Core/Core.lua`

**Location:** Lines 1415-1425 (in GetDefaultCharDB function)

**REMOVE this block:**
```lua
        -- Transmog Preview System
        transmog = {
            selectedTier = 4,           -- Current tier (4, 5, or 6)
            selectedRaid = "karazhan",  -- Current raid within tier
            selectedSpec = nil,         -- Spec index (1-3) or nil for first available
            dreamSet = {},              -- [slot] = itemId for custom sets
            colorSettings = {
                lightingPreset = "default",  -- Current lighting preset key
            },
            lastRotation = 0,           -- Model rotation angle (radians)
        },
```

**KEEP:** Lines 1427-1433 (armory block)

---

## PAYLOAD 7: Remove Transmog Migration Code

**Purpose:** Remove migration code for existing characters

### File: `HopeAddon/Core/Core.lua`

**Location:** Lines 1040-1048 (in MigrateCharDb function)

**REMOVE this block:**
```lua
    -- Ensure transmog structure exists for existing characters
    db.transmog = db.transmog or {}
    db.transmog.selectedTier = db.transmog.selectedTier or 4
    db.transmog.selectedRaid = db.transmog.selectedRaid or "karazhan"
    db.transmog.selectedSpec = db.transmog.selectedSpec  -- nil is valid
    db.transmog.dreamSet = db.transmog.dreamSet or {}
    db.transmog.colorSettings = db.transmog.colorSettings or {}
    db.transmog.colorSettings.lightingPreset = db.transmog.colorSettings.lightingPreset or "default"
    db.transmog.lastRotation = db.transmog.lastRotation or 0
```

---

## PAYLOAD 8: Remove Transmog Constants

**Purpose:** Remove all transmog-related constants from Constants.lua

### File: `HopeAddon/Core/Constants.lua`

**Remove these sections in order (bottom to top to preserve line numbers):**

**8A: Remove LIGHTING_PRESETS_BY_CATEGORY loop (Lines 4047-4054)**
```lua
-- Build preset lookup by category
C.LIGHTING_PRESETS_BY_CATEGORY = {}
for presetKey, preset in pairs(C.LIGHTING_PRESETS) do
    local cat = preset.category
    if not C.LIGHTING_PRESETS_BY_CATEGORY[cat] then
        C.LIGHTING_PRESETS_BY_CATEGORY[cat] = {}
    end
    table.insert(C.LIGHTING_PRESETS_BY_CATEGORY[cat], presetKey)
end
```

**8B: Remove LIGHTING_PRESETS table (Lines 3860-4044)**
~185 lines of lighting preset definitions

**8C: Remove LIGHTING_PRESET_CATEGORIES (Lines 3851-3858)**
```lua
C.LIGHTING_PRESET_CATEGORIES = {
    { id = "warm", name = "Warm", icon = "Interface\\Icons\\Spell_Fire_Fire" },
    { id = "cool", name = "Cool", icon = "Interface\\Icons\\Spell_Frost_FrostBolt02" },
    { id = "fel", name = "Fel", icon = "Interface\\Icons\\Spell_Fire_FelFire" },
    { id = "dramatic", name = "Dramatic", icon = "Interface\\Icons\\Spell_Holy_PowerInfusion" },
    { id = "holy", name = "Holy", icon = "Interface\\Icons\\Spell_Holy_HolyBolt" },
    { id = "nature", name = "Nature", icon = "Interface\\Icons\\Spell_Nature_ProtectionformNature" },
}
```

**8D: Remove comment before LIGHTING (Lines 3846-3849)**
```lua
--[[
    LIGHTING PRESETS
    18 presets in 6 categories for the dressing room
    Uses Model:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB)
]]
```

**8E: Remove GetAvailableSpecs function (Lines 3833-3844)**
```lua
-- Get all available specs for class at tier
function C:GetAvailableSpecs(tier, classToken)
    local classSets = C.TIER_SETS[tier] and C.TIER_SETS[tier][classToken]
    if not classSets then return {} end
    local specs = {}
    for specIndex, setData in pairs(classSets) do
        if type(specIndex) == "number" then
            specs[specIndex] = setData.name
        end
    end
    return specs
end
```

**8F: Remove GetTierSet function (Lines 3826-3831)**
```lua
-- Get tier set for player class
function C:GetTierSet(tier, classToken, specIndex)
    local classSets = C.TIER_SETS[tier] and C.TIER_SETS[tier][classToken]
    if not classSets then return nil end
    return classSets[specIndex or 1]
end
```

**8G: Remove TIER_SETS table (Lines 3345-3824)**
~480 lines of tier set item data

**8H: Remove TRANSMOG_RAIDS (Lines 3327-3343)**
```lua
-- Raid keys that have tier sets
C.TRANSMOG_RAIDS = {
    [4] = {
        { key = "karazhan", name = "Karazhan", tier = 4 },
        -- ...
    },
    -- ...
}
```

**8I: Remove TRANSMOG_UI (Lines 3308-3325)**
```lua
-- Transmog UI dimensions
C.TRANSMOG_UI = {
    SIDEBAR_WIDTH = 180,
    -- ...
}
```

**8J: Remove C.TIER_SLOT_ORDER (Lines 3306-3307)**
```lua
C.TIER_SLOT_ORDER = { "head", "shoulders", "chest", "hands", "legs" }
```

**Total Constants removal:** Lines 3306-4054 (~750 lines)

---

## PAYLOAD 9: Update CLAUDE.md Documentation

**Purpose:** Update documentation to reflect transmog removal

### File: `CLAUDE.md`

**Changes:**

1. **Feature Status Summary table:** Remove Transmog row, update Armory row status

2. **Tab count:** Change "7 tabs" references to current count

3. **Phase 56 section:** Mark as SUPERSEDED or remove entirely

4. **Remove transmog API documentation** (PreviewTierSet, WarmItemCache, ApplyLightingPreset, etc.)

5. **Update Recent Changes:** Add new phase documenting transmog removal

---

## Execution Checklist

Execute payloads in this exact order:

- [ ] **PAYLOAD 1:** Add migration code (prevents crashes)
- [ ] **PAYLOAD 2:** Remove tab registration
- [ ] **PAYLOAD 3:** Remove tab routing
- [ ] **PAYLOAD 4:** Remove state/local tables
- [ ] **PAYLOAD 5:** Remove all transmog functions
- [ ] **PAYLOAD 6:** Remove SavedVars default
- [ ] **PAYLOAD 7:** Remove migration code in Core.lua
- [ ] **PAYLOAD 8:** Remove Constants (work bottom-to-top: 8A→8J)
- [ ] **PAYLOAD 9:** Update CLAUDE.md

---

## Post-Execution Testing

After all payloads complete:

1. [ ] `/reload` - No Lua errors
2. [ ] `/hope` - Journal opens
3. [ ] Count tabs - Should be 7: Journey, Attunements, Reputation, Raids, Games, Social, Armory
4. [ ] Click Armory tab - Opens without errors
5. [ ] Click through T4/T5/T6 buttons - Works
6. [ ] Click slot buttons - Detail panel appears
7. [ ] Close journal, reopen - State persists
8. [ ] Check for orphaned transmog references: `grep -r "transmog" HopeAddon/`

---

## Rollback Instructions

If issues occur:
1. `git checkout HopeAddon/Journal/Journal.lua`
2. `git checkout HopeAddon/Core/Core.lua`
3. `git checkout HopeAddon/Core/Constants.lua`
4. `git checkout CLAUDE.md`

---

## Line Count Summary

| Payload | File | Lines Removed | Lines Added |
|---------|------|---------------|-------------|
| 1 | Journal.lua | 0 | +5 |
| 2 | Journal.lua | -1 | 0 |
| 3 | Journal.lua | -2 | 0 |
| 4 | Journal.lua | -102 | 0 |
| 5 | Journal.lua | -1104 | 0 |
| 6 | Core.lua | -11 | 0 |
| 7 | Core.lua | -9 | 0 |
| 8 | Constants.lua | -750 | 0 |
| 9 | CLAUDE.md | ~-50 | ~+20 |

**Net change:** ~2,000 lines removed
