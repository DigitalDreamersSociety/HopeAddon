# Armory Tab Restructure - Executable Payloads

## Pre-Implementation Verification Summary

**Verified Code Locations:**
- `ARMORY_TIERS` at Constants.lua:5657-5676 (uses `[4]`, `[5]`, `[6]` keys)
- `ARMORY_GEAR_DATABASE` at Constants.lua:5738-6298 (uses `[4]` key for T4 data, `[5]`/`[6]` empty)
- `GetArmoryGear()` helper at Constants.lua:6301-6305
- `GetArmorySlots()` helper at Constants.lua:6307-6312
- `GetArmoryGearData()` at Journal.lua:10278-10299 (has `tier = phase + 3` hack)
- `ARMORY_PHASE_BUTTON.PHASES` at Constants.lua:5220-5226 (already has phases 1-5)

**Already Working (No Changes Needed):**
- Slot button tooltips: `OnArmorySlotEnter()` at Journal.lua:10343-10358
- Popup item tooltips: `CreateArmoryGearPopupItemRow()` at Journal.lua:10756-10795
- Phase bar UI: `CreateArmoryPhaseBar()` at Journal.lua:9261-9293
- Phase buttons 1-5: `CreateArmoryPhaseButtons()` at Journal.lua:9298-9339

---

## PAYLOAD 1: Constants.lua Database Key Rename

**Goal:** Change database keys from Tier-based (`[4]`, `[5]`, `[6]`) to Phase-based (`[1]`, `[2]`, `[3]`, `[5]`)

**File:** `Core/Constants.lua`

### Change 1.1: Rename ARMORY_TIERS to ARMORY_PHASES (Lines 5657-5676)

**BEFORE:**
```lua
C.ARMORY_TIERS = {
    [4] = {
        name = "Phase 1 (T4)",
        content = "Karazhan, Gruul, Magtheridon, Heroics",
        color = "FEL_GREEN",
        raids = { "karazhan", "gruul", "magtheridon" },
    },
    [5] = {
        name = "Phase 2 (T5)",
        content = "SSC, Tempest Keep",
        color = "SKY_BLUE",
        raids = { "ssc", "tk" },
    },
    [6] = {
        name = "Phase 3 (T6)",
        content = "Hyjal, Black Temple, Sunwell",
        color = "HELLFIRE_RED",
        raids = { "hyjal", "bt", "sunwell" },
    },
}
```

**AFTER:**
```lua
C.ARMORY_PHASES = {
    [1] = {
        name = "Phase 1",
        content = "Karazhan, Gruul, Magtheridon, Heroics, Badge Gear, Reputation",
        color = "FEL_GREEN",
        raids = { "karazhan", "gruul", "magtheridon" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    [2] = {
        name = "Phase 2",
        content = "Serpentshrine Cavern, Tempest Keep",
        color = "SKY_BLUE",
        raids = { "ssc", "tk" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    [3] = {
        name = "Phase 3",
        content = "Hyjal Summit, Black Temple",
        color = "HELLFIRE_RED",
        raids = { "hyjal", "bt" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
    -- Phase 4 (ZA) skipped - catch-up raid
    [5] = {
        name = "Phase 5",
        content = "Sunwell Plateau",
        color = "LEGENDARY_ORANGE",
        raids = { "sunwell" },
        sources = { "raid", "heroic", "badge", "rep", "crafted" },
    },
}

-- Legacy alias for backwards compatibility
C.ARMORY_TIERS = C.ARMORY_PHASES
```

### Change 1.2: Rename ARMORY_GEAR_DATABASE Keys (Lines 5738-6298)

**BEFORE:**
```lua
C.ARMORY_GEAR_DATABASE = {
    [4] = {
        ["tank"] = { ... },
        ["healer"] = { ... },
        -- ... all the T4 data
    },
    [5] = {},
    [6] = {},
}
```

**AFTER:**
```lua
C.ARMORY_GEAR_DATABASE = {
    -------------------------------------------------
    -- PHASE 1: Karazhan, Gruul, Magtheridon, Heroics
    -------------------------------------------------
    [1] = {
        ["tank"] = { ... },  -- existing T4 data unchanged
        ["healer"] = { ... },
        -- ... all existing data, just under key [1] instead of [4]
    },

    -- Phase 2, 3, 5 placeholders for future expansion
    [2] = {},
    [3] = {},
    [5] = {},
}
```

### Change 1.3: Update Helper Functions (Lines 6301-6312)

**BEFORE:**
```lua
-- Helper function to get gear for a slot/role/tier
function C:GetArmoryGear(tier, role, slot)
    if not C.ARMORY_GEAR_DATABASE[tier] then return nil end
    if not C.ARMORY_GEAR_DATABASE[tier][role] then return nil end
    return C.ARMORY_GEAR_DATABASE[tier][role][slot]
end

-- Helper function to get all slots for a role/tier
function C:GetArmorySlots(tier, role)
    if not C.ARMORY_GEAR_DATABASE[tier] then return {} end
    if not C.ARMORY_GEAR_DATABASE[tier][role] then return {} end
    return C.ARMORY_GEAR_DATABASE[tier][role]
end
```

**AFTER:**
```lua
-- Helper function to get gear for a slot/role/phase
function C:GetArmoryGear(phase, role, slot)
    if not C.ARMORY_GEAR_DATABASE[phase] then return nil end
    if not C.ARMORY_GEAR_DATABASE[phase][role] then return nil end
    return C.ARMORY_GEAR_DATABASE[phase][role][slot]
end

-- Helper function to get all slots for a role/phase
function C:GetArmorySlots(phase, role)
    if not C.ARMORY_GEAR_DATABASE[phase] then return {} end
    if not C.ARMORY_GEAR_DATABASE[phase][role] then return {} end
    return C.ARMORY_GEAR_DATABASE[phase][role]
end

-- Get phase metadata
function C:GetArmoryPhase(phase)
    return C.ARMORY_PHASES[phase]
end

-- Check if phase has gear data
function C:HasArmoryPhaseData(phase)
    local data = C.ARMORY_GEAR_DATABASE[phase]
    if not data then return false end
    -- Check if any role has data
    for role, slots in pairs(data) do
        if next(slots) then return true end
    end
    return false
end
```

---

## PAYLOAD 2: Journal.lua Tier Conversion Removal

**Goal:** Remove the `tier = phase + 3` hack and use phase numbers directly

**File:** `Journal/Journal.lua`

### Change 2.1: Update GetArmoryGearData() (Lines 10278-10299)

**BEFORE:**
```lua
function Journal:GetArmoryGearData(slotName)
    local C = HopeAddon.Constants
    local guideKey = self:GetCurrentArmoryGuideKey()
    local phase = self.armoryState.selectedPhase or 1

    -- Try new spec-based database first
    if guideKey and C.GetSpecBisGearLegacy then
        local gearData = C:GetSpecBisGearLegacy(phase, guideKey, slotName)
        if gearData then return gearData end
    end

    -- Fallback to old role-based database (map phase to tier for compatibility)
    local tier = phase + 3  -- Phase 1=T4, Phase 2=T5, Phase 3=T6
    local role = self:GetCurrentArmoryRole()
    if C.GetArmoryGear then
        return C:GetArmoryGear(tier, role, slotName)
    end
    return nil
end
```

**AFTER:**
```lua
function Journal:GetArmoryGearData(slotName)
    local C = HopeAddon.Constants
    local phase = self.armoryState.selectedPhase or 1
    local role = self:GetCurrentArmoryRole()

    -- Use phase number directly (no tier conversion)
    if C.GetArmoryGear then
        local gearData = C:GetArmoryGear(phase, role, slotName)
        if gearData then return gearData end
    end

    return nil
end
```

### Change 2.2: Add "No Data" Handling in PopulateArmoryGearPopup()

Find `PopulateArmoryGearPopup` function and add handling for empty phases.

**Location:** Around line 10567 in `Journal.lua`

**ADD** inside `PopulateArmoryGearPopup()` after getting gearData:

```lua
-- Check if phase has any data
local C = HopeAddon.Constants
local phase = self.armoryState.selectedPhase or 1
if not C:HasArmoryPhaseData(phase) then
    -- Show "No data for this phase" message
    local noDataText = popup.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    noDataText:SetPoint("TOP", popup.content, "TOP", 0, -40)
    noDataText:SetText("No gear data for Phase " .. phase .. " yet.")
    noDataText:SetTextColor(0.7, 0.7, 0.7)

    local hintText = popup.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hintText:SetPoint("TOP", noDataText, "BOTTOM", 0, -10)
    hintText:SetText("Phase 1 data is available.")
    hintText:SetTextColor(0.5, 0.5, 0.5)
    return
end
```

---

## PAYLOAD 3: Phase 4 Button Handling

**Goal:** Hide or disable Phase 4 button since ZA (catch-up raid) is skipped

**File:** `Journal/Journal.lua`

### Change 3.1: Update CreateArmoryPhaseButtons() (Around line 9302)

**BEFORE:**
```lua
for phase = 1, 5 do
    local phaseConfig = C.PHASES[phase]
    -- ... button creation
```

**AFTER:**
```lua
for phase = 1, 5 do
    -- Skip Phase 4 (ZA catch-up raid)
    if phase == 4 then
        -- Don't create button for Phase 4
    else
        local phaseConfig = C.PHASES[phase]
        -- ... button creation (existing code)
    end
end
```

**Alternative (Simpler):** Just change the loop:
```lua
local phasesToShow = { 1, 2, 3, 5 }  -- Skip Phase 4
for _, phase in ipairs(phasesToShow) do
    local phaseConfig = C.PHASES[phase]
    -- ... existing button creation code
```

---

## PAYLOAD 4: Documentation Cleanup

**Goal:** Update documentation and remove outdated plan files

### Files to Update:
1. `CLAUDE.md` - Update Armory tab status from "IN PROGRESS" to reflect current state
2. Remove or archive these planning files:
   - `ARMORY_SIMPLIFICATION_PLAN.md`
   - `ARMORY_CURRENT_STATE.md`
   - `ARMORY_REDESIGN_PLAN.md`
   - `ARMORY_PHASE_RESTRUCTURE_PLAN.md`
   - `ARMORY_FIX_PAYLOADS.md`
   - `ARMORY_BIS_DATA_PLAN.md`
   - `ARMORY_UI_COMPACT_PLAN.md`

### Post-Implementation Checklist:
- [ ] Phase 1 gear shows correctly when selected
- [ ] Phase 2, 3, 5 show "No data" message
- [ ] Phase 4 button is hidden
- [ ] Slot tooltips work (hover over equipped item)
- [ ] Popup item tooltips work (hover over BiS items)
- [ ] Model frame rotates with mouse drag
- [ ] Spec dropdown detects current spec

---

## Execution Order

1. **PAYLOAD 1** (Constants.lua) - Must be first, changes data structure
2. **PAYLOAD 2** (Journal.lua GetArmoryGearData) - Depends on Payload 1
3. **PAYLOAD 3** (Journal.lua Phase 4 button) - Independent but logical after 1&2
4. **PAYLOAD 4** (Documentation) - After code changes verified working

---

## Risk Assessment

| Payload | Risk | Mitigation |
|---------|------|------------|
| 1 | Medium - data structure change | Legacy alias `ARMORY_TIERS = ARMORY_PHASES` maintains compatibility |
| 2 | Low - single function change | Simple removal of arithmetic |
| 3 | Low - UI only | Just skips button creation |
| 4 | None - documentation only | N/A |

---

## Verification Tests

After implementation:
1. `/hope` → Armory tab → Phase 1 should show gear recommendations
2. Switch to Phase 2 → Should show "No data for Phase 2 yet"
3. Hover over equipped item slot → Should show item tooltip
4. Click slot → Popup shows BiS + alternatives with tooltips
5. Only buttons for Phase 1, 2, 3, 5 visible (no Phase 4)
