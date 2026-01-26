# Armory Slot Tooltip Issues Checklist

## Analysis Date: 2026-01-25

---

## VERIFIED WORKING ✅

### A. Slot Button Creation (CreateSingleArmorySlotButton - Line 9709)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| A1 | Button created as "Button" frame type | ✅ OK | Line 9712: `CreateFrame("Button", ...)` |
| A2 | `btn.slotName` assigned | ✅ OK | Line 9804: `btn.slotName = slotName` |
| A3 | `btn.slotId` assigned from slotData | ✅ OK | Line 9805: `btn.slotId = slotData.slotId` |
| A4 | OnEnter handler attached | ✅ OK | Lines 9817-9820: `btn:SetScript("OnEnter", ...)` |
| A5 | OnLeave handler attached | ✅ OK | Lines 9822-9824: `btn:SetScript("OnLeave", ...)` |
| A6 | OnClick handler attached | ✅ OK | Lines 9811-9814: `btn:SetScript("OnClick", ...)` |
| A7 | Frame level set (+2 above parent) | ✅ OK | Line 9716: `btn:SetFrameLevel(parent:GetFrameLevel() + 2)` |
| A8 | Icon texture created | ✅ OK | Lines 9744-9748 |
| A9 | Placeholder texture created | ✅ OK | Lines 9735-9741 |
| A10 | Quality border created | ✅ OK | Lines 9751-9756 |

### B. Container Setup (CreateArmorySlotsContainer - Line 9590)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| B1 | Container frame level set (+10 above characterView) | ✅ OK | Lines 9606-9612 |
| B2 | Container spans full characterView | ✅ OK | Lines 9597-9598 |
| B3 | Parent height set BEFORE children created | ✅ OK | Lines 9516-9523 in CreateArmoryCharacterView |

### C. Constants (Constants.lua)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| C1 | All 17 slots defined with correct slotId (1-19) | ✅ OK | Lines 5405-5428 |
| C2 | All 17 slots have positions defined | ✅ OK | Lines 5434-5464 |
| C3 | Hidden slots (shirt/tabard) defined | ✅ OK | Lines 5391-5394 |
| C4 | Placeholder icons for all slots | ✅ OK | Lines 5488-5508 |

### D. Data Refresh (RefreshSingleSlotData - Line 10162)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| D1 | Uses `GetInventoryItemLink("player", slotId)` | ✅ OK | Line 10165 |
| D2 | Stores equippedItem with itemId, name, quality, iLvl, icon | ✅ OK | Lines 10175-10181 |
| D3 | Sets icon texture from item | ✅ OK | Line 10182 |
| D4 | Shows/hides placeholder correctly | ✅ OK | Lines 10183-10184, 10197-10198 |
| D5 | Sets quality border color | ✅ OK | Lines 10187-10190 |
| D6 | Called from PopulateArmory | ✅ OK | Line 9146 |

### E. Tooltip Display (OnArmorySlotEnter - Line 10417)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| E1 | `GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")` | ✅ OK | Line 10418 |
| E2 | `GameTooltip:SetInventoryItem("player", btn.slotId)` when item exists | ✅ OK | Line 10422 |
| E3 | Fallback text when no item | ✅ OK | Lines 10424-10425 |
| E4 | BiS section added | ✅ OK | Lines 10435-10480 |
| E5 | `GameTooltip:Show()` called | ✅ OK | Line 10490 |

### F. Tooltip Hide (OnArmorySlotLeave - Line 10493)
| # | Item | Status | Evidence |
|---|------|--------|----------|
| F1 | `GameTooltip:Hide()` called | ✅ OK | Line 10496 |

---

## POTENTIAL ISSUES ⚠️

### Issue 1: Button EnableMouse Not Explicitly Set
**Location:** CreateSingleArmorySlotButton (Line 9709)
**Problem:** Unlike other interactive frames in the codebase, the armory slot buttons don't explicitly call `EnableMouse(true)`.
**Risk:** LOW - Button frames should have mouse enabled by default, but explicit is safer.
**Evidence:** Other interactive elements (lines 2169, 2816, 5478, 11077) explicitly call `EnableMouse(true)`.

### Issue 2: Model Frame Consumes Mouse Events
**Location:** CreateArmoryModelFrame (Line 9535)
**Problem:** The DressUpModel has `EnableMouse(true)` (line 9557) for drag rotation, which could intercept mouse events meant for slot buttons if frame levels aren't working correctly.
**Risk:** MEDIUM - Could explain why slots aren't responding if frame stacking is wrong.
**Evidence:** Model has mouse enabled at line 9557.

### Issue 3: No Frame Strata Set on Slot Buttons
**Location:** CreateSingleArmorySlotButton (Line 9709)
**Problem:** Slot buttons don't set a `SetFrameStrata()`. They inherit from parent. If parent strata is lower than model strata, buttons won't receive input.
**Risk:** MEDIUM - Frame level alone may not be sufficient; strata matters too.
**Evidence:** The gear popup sets `SetFrameStrata("DIALOG")` at line 10666, but slot buttons have no strata setting.

### Issue 4: Model Frame No Strata Set Either
**Location:** CreateArmoryModelFrame (Line 9540)
**Problem:** DressUpModel doesn't have explicit strata set.
**Risk:** LOW - But combined with Issue 3, could cause unpredictable layering.

### Issue 5: GetItemInfo May Return nil on First Call
**Location:** RefreshSingleSlotData (Line 10171)
**Problem:** `GetItemInfo(itemLink)` can return nil values on first call if item isn't cached. The code doesn't handle this - `itemTexture` could be nil.
**Risk:** MEDIUM - Could cause missing icons for newly equipped items.
**Evidence:** Line 10182 `btn.icon:SetTexture(itemTexture)` - if nil, texture won't display.

### Issue 6: Weapon Slots May Overlap Model
**Location:** CreateArmorySlotButtons (Lines 9669-9684)
**Problem:** Weapon slots anchor to MODEL_BOTTOM. If model is large or positions are off, weapons may visually overlap model but be behind it in frame hierarchy.
**Risk:** LOW - Frame level fix should handle this, but visual overlap could confuse users.

---

## ISSUES REQUIRING VERIFICATION 🔍

### V1: Slot Buttons Actually Visible?
**Test:** `/hope debug` then `/hope armoryslots`
**Expected:** All 15 slots (excluding shirt/tabard) should report `Shown=YES, Visible=YES`
**If Failing:** Frame level or strata issue

### V2: Slot Buttons Receiving Mouse Events?
**Test:** Hover over each slot, check for hover sound and tooltip
**Expected:** Hover sound plays, tooltip appears
**If Failing:** Mouse events being intercepted (likely by model)

### V3: Equipment Data Loading?
**Test:** `/hope debug` and open Armory tab, check debug output
**Expected:** `RefreshSingleSlotData: <slotName> slotId=<N> hasItem=YES/NO` for all slots
**If Failing:** Slot buttons don't have valid slotId or RefreshArmorySlotData not being called

### V4: Tooltip Showing Correct Item?
**Test:** Hover slot with equipped item
**Expected:** Standard WoW item tooltip with stats + BiS section below
**If Failing:** `btn.slotId` is wrong or `btn.equippedItem` not populated

---

## RECOMMENDED FIXES (Priority Order)

### FIX 1: Add Explicit EnableMouse to Slot Buttons [LOW PRIORITY]
```lua
-- In CreateSingleArmorySlotButton, after SetFrameLevel:
btn:EnableMouse(true)
```

### FIX 2: Ensure Slots Are Above Model in Strata [MEDIUM PRIORITY]
```lua
-- Option A: Lower model strata
modelFrame:SetFrameStrata("LOW")

-- Option B: Raise slot container strata
slotsContainer:SetFrameStrata("MEDIUM")
```

### FIX 3: Handle GetItemInfo nil Returns [MEDIUM PRIORITY]
```lua
-- In RefreshSingleSlotData, add nil check:
if itemLink then
    local itemName, _, itemQuality, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)

    -- Handle uncached item
    if not itemName then
        -- Item not cached yet, schedule retry
        HopeAddon:Debug("RefreshSingleSlotData: Item not cached for", slotName)
        btn.equippedItem = { itemId = itemId, name = "Loading...", quality = 1, iLvl = 0, icon = nil }
        btn.icon:Hide()
        btn.placeholder:Show()
        return
    end
    -- ... rest of code
end
```

### FIX 4: Add Debug Output for Frame Hierarchy [DEBUG]
```lua
-- In CreateSingleArmorySlotButton, at end:
HopeAddon:Debug("Slot", slotName, "created: level=", btn:GetFrameLevel(),
                "strata=", btn:GetFrameStrata(), "parent=", parent:GetName())
```

---

## SUMMARY

| Category | Status |
|----------|--------|
| Button Creation | ✅ Complete |
| Handler Attachment | ✅ Complete |
| Constants/Data | ✅ Complete |
| Data Refresh | ✅ Complete |
| Tooltip Functions | ✅ Complete |
| Frame Hierarchy | ⚠️ May need strata adjustment |
| Mouse Event Handling | ⚠️ May need explicit EnableMouse |
| Item Caching | ⚠️ No nil handling |

**Most Likely Root Cause:** If only necklace slot is visible/working, the issue is likely:
1. Frame strata conflict with DressUpModel
2. Position constants placing slots outside visible area
3. Container size/bounds issue

**Next Step:** Run `/hope armoryslots` in-game to see actual slot states, then apply fixes based on results.
