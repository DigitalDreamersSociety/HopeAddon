# Transmog Tab Removal Plan

**Status:** READY FOR IMPLEMENTATION
**Goal:** Remove the Transmog tab entirely, keep Armory as the single gear-focused tab
**Estimated Changes:** ~1,200 lines removed, ~50 lines modified

---

## Summary

The Transmog tab was implemented as a tier set preview feature but overlaps significantly with the Armory tab's gear advisor functionality. This plan removes Transmog completely to simplify the addon and reduce maintenance burden.

**What gets removed:**
- Transmog tab registration and routing
- All Transmog UI code (~1,100 lines)
- Transmog state/UI tables
- Transmog SavedVariables
- TIER_SETS data (~500 lines in Constants.lua)
- LIGHTING_PRESETS data (~200 lines in Constants.lua)
- TRANSMOG_UI constants (~40 lines)

**What stays:**
- Armory tab with full gear advisor functionality
- ARMORY_GEAR_DATABASE (upgrade recommendations)
- All Armory UI and state code

---

## Detailed Steps

### Step 1: Remove Transmog Tab Registration

**File:** `HopeAddon/Journal/Journal.lua`
**Line:** 926

**Current:**
```lua
{ id = "transmog", label = "Transmog", tooltip = "Preview legendary tier sets", color = "LEGENDARY" },
{ id = "armory", label = "Armory", tooltip = "Gear upgrade advisor by role", color = "HELLFIRE_RED" },
```

**Change to:**
```lua
{ id = "armory", label = "Armory", tooltip = "Gear upgrade advisor by role", color = "HELLFIRE_RED" },
```

---

### Step 2: Add Migration for Transmog Tab Users

**File:** `HopeAddon/Journal/Journal.lua`
**Location:** Around line 1047-1051 (in SelectTab function, after stats migration)

**Add:**
```lua
-- Migration: "transmog" tab removed, redirect to armory
if tabId == "transmog" then
    tabId = "armory"
    self.currentTab = tabId
end
```

---

### Step 3: Remove Transmog Tab Routing

**File:** `HopeAddon/Journal/Journal.lua`
**Lines:** 1065-1066

**Remove:**
```lua
elseif tabId == "transmog" then
    self:PopulateTransmog()
```

---

### Step 4: Remove Transmog State and UI Tables

**File:** `HopeAddon/Journal/Journal.lua`
**Lines:** 9037-9067

**Remove entire block:**
```lua
Journal.transmogState = {
    selectedTier = 4,
    selectedRaid = "karazhan",
    selectedSpec = nil,
    selectedCategory = "warm",
    selectedPreset = "default",
    modelRotation = 0,
    currentSetData = nil,
}

Journal.transmogUI = {
    container = nil,
    sidebar = nil,
    preview = nil,
    tierButtons = {},
    raidButtons = {},
    raidHeader = nil,
    raidContainer = nil,
    specDropdown = nil,
    dreamProgress = nil,
    modelFrame = nil,
    model = nil,
    modelBg = nil,
    setNameLabel = nil,
    setInfoLabel = nil,
    slotsContainer = nil,
    slotButtons = {},
    rotateHint = nil,
    lightingLabel = nil,
    categoryContainer = nil,
    categoryButtons = {},
    presetDropdown = nil,
    instructions = nil,
}
```

---

### Step 5: Remove All Transmog Functions

**File:** `HopeAddon/Journal/Journal.lua`
**Lines to remove:** 9137-10238 (approximately 1,100 lines)

**Functions to remove:**
| Function | Line | Lines |
|----------|------|-------|
| `CreateTransmogContainers()` | 9137 | ~45 |
| `CreateTransmogSidebar()` | 9180 | ~130 |
| `CreateTransmogPreview()` | 9308 | ~185 |
| `InitLightingPresetDropdown()` | 9495 | ~50 |
| `SelectLightingCategory()` | 9527 | ~45 |
| `SelectLightingPreset()` | 9566 | ~25 |
| `ApplyLightingPreset()` | 9589 | ~40 |
| `CreateTransmogSlotButton()` | 9626 | ~80 |
| `SelectTransmogTier()` | 9704 | ~35 |
| `UpdateTransmogRaidButtons()` | 9738 | ~70 |
| `SelectTransmogRaid()` | 9806 | ~35 |
| `UpdateTransmogSpec()` | 9839 | ~65 |
| `UpdateTransmogSlots()` | 9903 | ~110 |
| `PreviewTierSet()` | 10011 | ~55 |
| `WarmItemCache()` | 10064 | ~70 |
| `RefreshTransmogPreview()` | 10132 | ~10 |
| `PopulateTransmog()` | 10143 | ~75 |
| `HideTransmogTab()` | 10219 | ~20 |

**Total:** ~1,100 lines

---

### Step 6: Remove Transmog SavedVariables Default

**File:** `HopeAddon/Core/Core.lua`
**Lines:** 1415-1425 (in GetDefaultCharDB)

**Remove:**
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

---

### Step 7: Remove Transmog Migration Code

**File:** `HopeAddon/Core/Core.lua`
**Lines:** 1040-1048 (in MigrateCharDb)

**Remove:**
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

### Step 8: Remove Transmog Constants

**File:** `HopeAddon/Core/Constants.lua`

**Remove these sections:**

| Section | Approximate Lines | Content |
|---------|-------------------|---------|
| `C.TRANSMOG_UI` | 3309-3346 | UI dimension constants |
| `C.TIER_SETS` | 3350-3826 | All tier set item data (~475 lines) |
| `C:GetTierSet()` | 3828-3833 | Helper function |
| `C:GetAvailableSpecs()` | 3835-3857 | Helper function |
| `C.LIGHTING_PRESETS` | 3860-4045 | All lighting preset data (~185 lines) |
| `C.LIGHTING_PRESETS_BY_CATEGORY` | 4047-4054 | Category index |
| `C.LIGHTING_PRESET_CATEGORIES` | ~4056-4080 | Category definitions |

**Total:** ~750 lines from Constants.lua

---

### Step 9: Update CLAUDE.md Documentation

**File:** `CLAUDE.md`

**Changes:**
1. Remove "Transmog Tab" from Feature Status Summary table
2. Remove Phase 56 documentation about Transmog
3. Update tab count from 8 to 7
4. Remove transmog-related API functions from documentation
5. Update "Recent Changes" section

---

## File Change Summary

| File | Action | Lines Changed |
|------|--------|---------------|
| `Journal/Journal.lua` | Remove tab, routing, state, UI, functions | -1,130 lines |
| `Core/Core.lua` | Remove SavedVars default and migration | -20 lines |
| `Core/Constants.lua` | Remove TIER_SETS, LIGHTING_PRESETS, TRANSMOG_UI | -750 lines |
| `CLAUDE.md` | Update documentation | ~50 lines modified |

**Net reduction:** ~1,900 lines of code

---

## Testing Checklist

After implementation, verify:

- [ ] Journal opens without errors
- [ ] 7 tabs visible (Journey, Attunements, Reputation, Raids, Games, Social, Armory)
- [ ] Armory tab works correctly
- [ ] No Lua errors when clicking where Transmog tab used to be
- [ ] Users with `lastTab = "transmog"` correctly redirect to Armory
- [ ] No orphaned references to transmog functions
- [ ] `/hope` command works
- [ ] SavedVariables load without errors (existing transmog data becomes orphaned but harmless)

---

## Rollback Plan

If issues arise, the changes can be reverted by:
1. Restoring the removed code blocks from git history
2. Re-adding the tab registration
3. Re-adding the SelectTab routing

Since this is pure removal (no refactoring of shared code), rollback is straightforward.

---

## Implementation Order

Execute steps in this exact order to minimize errors:

1. **Step 2** - Add migration FIRST (prevents crashes if tab selected)
2. **Step 1** - Remove tab registration
3. **Step 3** - Remove tab routing
4. **Step 4** - Remove state/UI tables
5. **Step 5** - Remove all functions (largest change)
6. **Step 6** - Remove SavedVariables default
7. **Step 7** - Remove migration code
8. **Step 8** - Remove Constants
9. **Step 9** - Update documentation

---

## Notes

- Existing `charDb.transmog` data in users' SavedVariables becomes orphaned but causes no harm
- No data migration needed - transmog data was purely cosmetic/preview, not gameplay-affecting
- The Armory tab already has its own model/preview functionality for showing equipped items
- TIER_SETS data could theoretically be kept if we want to add tier preview to Armory later, but removing it now reduces complexity
