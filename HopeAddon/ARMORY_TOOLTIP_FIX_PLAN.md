# Armory Tooltip Fix Plan

## Date: 2026-01-25

---

## Summary

5 potential issues identified that may prevent slot buttons from receiving mouse events and displaying tooltips correctly.

---

## PAYLOAD 0: Mouse Event Fixes (HIGH PRIORITY)

### Task 0.1: Add Explicit EnableMouse to Slot Buttons
**File:** `Journal/Journal.lua`
**Location:** `CreateSingleArmorySlotButton()` at line 9917
**Risk:** LOW
**Reason:** While Button frames should have mouse enabled by default, other interactive elements in the codebase explicitly call `EnableMouse(true)`. Being explicit ensures consistency.

**Current Code (line 9916-9917):**
```lua
    -- CRITICAL: Set frame level above parent to ensure button is clickable
    btn:SetFrameLevel(parent:GetFrameLevel() + 2)
```

**New Code:**
```lua
    -- CRITICAL: Set frame level above parent to ensure button is clickable
    btn:SetFrameLevel(parent:GetFrameLevel() + 2)
    btn:EnableMouse(true)
```

---

### Task 0.2: Set Frame Strata on Slots Container
**File:** `Journal/Journal.lua`
**Location:** `CreateArmorySlotsContainer()` at line 9811
**Risk:** MEDIUM
**Reason:** Frame level alone may not be sufficient. The DressUpModel and slots could be at the same strata, causing unpredictable z-ordering. Setting slots to MEDIUM strata ensures they render above the model.

**Current Code (lines 9807-9812):**
```lua
    -- CRITICAL: Set frame level ABOVE the model frame so slots are clickable
    -- Model frame renders at characterView level, slots need to be higher
    local characterView = self.armoryUI.characterView
    if characterView then
        slotsContainer:SetFrameLevel(characterView:GetFrameLevel() + 10)
        HopeAddon:Debug("CreateArmorySlotsContainer: Set frameLevel to", slotsContainer:GetFrameLevel())
    end
```

**New Code:**
```lua
    -- CRITICAL: Set frame level and strata ABOVE the model frame so slots are clickable
    -- Model frame renders at characterView level, slots need to be higher
    local characterView = self.armoryUI.characterView
    if characterView then
        slotsContainer:SetFrameLevel(characterView:GetFrameLevel() + 10)
        slotsContainer:SetFrameStrata("MEDIUM")
        HopeAddon:Debug("CreateArmorySlotsContainer: Set frameLevel to", slotsContainer:GetFrameLevel(), "strata=MEDIUM")
    end
```

---

### Task 0.3: Set Model Frame to Lower Strata
**File:** `Journal/Journal.lua`
**Location:** `CreateArmoryModelFrame()` at line 9755
**Risk:** LOW
**Reason:** Explicitly set the model to LOW strata so it doesn't compete with slot buttons for mouse events.

**Current Code (lines 9754-9755):**
```lua
        -- Drag rotation
        modelFrame:EnableMouse(true)
```

**New Code:**
```lua
        -- Drag rotation - but set LOW strata so slots can receive clicks
        modelFrame:SetFrameStrata("LOW")
        modelFrame:EnableMouse(true)
```

---

## PAYLOAD 1: GetItemInfo Nil Handling (MEDIUM PRIORITY)

### Task 1.1: Add Nil Check for Uncached Items
**File:** `Journal/Journal.lua`
**Location:** `RefreshSingleSlotData()` at lines 10368-10380
**Risk:** MEDIUM
**Reason:** `GetItemInfo(itemLink)` can return nil values on first call if the item isn't cached by the client. This causes `btn.icon:SetTexture(nil)` which results in no icon displayed.

**Current Code (lines 10368-10382):**
```lua
    if itemLink then
        local itemName, _, itemQuality, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
        local itemIdMatch = itemLink:match("item:(%d+)")
        local itemId = itemIdMatch and tonumber(itemIdMatch) or nil

        btn.equippedItem = {
            itemId = itemId,
            name = itemName,
            quality = itemQuality,
            iLvl = itemLevel or 0,
            icon = itemTexture,
        }
        btn.icon:SetTexture(itemTexture)
        btn.icon:Show()
        btn.placeholder:Hide()
```

**New Code:**
```lua
    if itemLink then
        local itemName, _, itemQuality, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
        local itemIdMatch = itemLink:match("item:(%d+)")
        local itemId = itemIdMatch and tonumber(itemIdMatch) or nil

        -- Handle uncached items (GetItemInfo returns nil on first call)
        if not itemName or not itemTexture then
            HopeAddon:Debug("RefreshSingleSlotData:", slotName, "- item not cached yet, showing placeholder")
            btn.equippedItem = { itemId = itemId, name = "Loading...", quality = 1, iLvl = 0, icon = nil }
            btn.icon:Hide()
            btn.placeholder:Show()
            btn.qualityBorder:Hide()
            btn.upgradeStatus = "empty"
            self:UpdateArmorySlotVisual(btn)
            return
        end

        btn.equippedItem = {
            itemId = itemId,
            name = itemName,
            quality = itemQuality,
            iLvl = itemLevel or 0,
            icon = itemTexture,
        }
        btn.icon:SetTexture(itemTexture)
        btn.icon:Show()
        btn.placeholder:Hide()
```

---

## PAYLOAD 2: Debug Enhancement (LOW PRIORITY)

### Task 2.1: Add Frame Hierarchy Debug to Slot Creation
**File:** `Journal/Journal.lua`
**Location:** `CreateSingleArmorySlotButton()` at end of function (before `return btn`)
**Risk:** NONE (debug only)
**Reason:** Helps diagnose any remaining frame stacking issues.

**Add before line 10027 (`return btn`):**
```lua
    HopeAddon:Debug("CreateSingleArmorySlotButton:", slotName,
        "frameLevel=", btn:GetFrameLevel(),
        "strata=", btn:GetFrameStrata(),
        "parentLevel=", parent:GetFrameLevel())
```

---

## Implementation Order

| Order | Task | Risk | Lines Affected |
|-------|------|------|----------------|
| 1 | Task 0.2: slotsContainer strata | MEDIUM | 9811-9812 |
| 2 | Task 0.3: modelFrame strata | LOW | 9754-9755 |
| 3 | Task 0.1: btn EnableMouse | LOW | 9917 |
| 4 | Task 1.1: GetItemInfo nil check | MEDIUM | 10368-10382 |
| 5 | Task 2.1: Debug output | NONE | 10026 |

---

## Verification Checklist

After implementation, test with:

1. `/hope debug` - Enable debug mode
2. Open Journal → Armory tab
3. Check debug output for:
   - `CreateArmorySlotsContainer: Set frameLevel to X strata=MEDIUM`
   - `CreateSingleArmorySlotButton: <slot> frameLevel=X strata=MEDIUM parentLevel=Y`
4. `/hope armoryslots` - Verify all 15 slots show `Shown=YES, Visible=YES`
5. Hover over each slot - verify hover sound plays and tooltip appears
6. Verify tooltip shows:
   - Equipped item stats (from `SetInventoryItem`)
   - BiS recommendation section
   - "Click for upgrade options" hint
7. Click a slot - verify gear popup opens

---

## Rollback Plan

If issues persist after these fixes, the problem is likely in:
1. Position constants placing slots outside visible bounds
2. characterView dimensions not matching expected layout
3. Slot buttons being created but never shown due to HIDDEN config

Debug with `/hope armoryslots` to check actual visibility state of each slot.
