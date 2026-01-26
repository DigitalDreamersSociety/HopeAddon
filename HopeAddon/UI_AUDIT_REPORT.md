# HopeAddon UI Audit Report

**Date:** 2026-01-25
**Scope:** Frame Pooling, Hover Handlers, Z-Order, Margins, Memory Leaks
**Status:** 16 issues identified (4 HIGH, 8 MEDIUM, 4 LOW)

---

## Executive Summary

The codebase demonstrates good frame pooling discipline overall, with proper `Destroy()` calls in `OnDisable()` and general cleanup awareness. The main issues are:

1. **Edge cases around state persistence in pooled frames**
2. **Uncleaned animation handlers on game close**
3. **Glow effects not stopped before pool release**
4. **Missing click-through prevention on modals**

All fixes are straightforward and localized, requiring no architectural changes.

---

## 1. FRAME POOLING AUDIT

### Issue P1: CardPool defaultBorderColor Set After OnLeave
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:971-979`
**Description:** In `AcquireCard()`, the `defaultBorderColor` is set AFTER the OnLeave script is defined. If OnLeave fires before defaultBorderColor is set (race condition on fast mouse movement), the border restoration will fail.

**Current Code:**
```lua
card:SetScript("OnLeave", function(self)
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    self:SetBackdropBorderColor(
        self.defaultBorderColor.r,  -- May be nil!
        self.defaultBorderColor.g,
        self.defaultBorderColor.b
    )
end)
-- ... later ...
card.defaultBorderColor = { r = 0.3, g = 0.3, b = 0.3 }  -- Set after scripts
```

**Fix:** Move `defaultBorderColor` assignment BEFORE script handlers, or add nil check in OnLeave.

---

### Issue P2: CardPool Reset Missing Callback/State Cleanup
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:473-531`
**Description:** The `cardPool` reset function hides the frame and resets some properties, but doesn't clear:
- `card.entryData` (old entry reference)
- `card.onClick` callback
- `card._glowEffect` reference

**Fix:** Add to reset function:
```lua
frame.entryData = nil
frame.onClick = nil
if frame._glowEffect and HopeAddon.Effects then
    HopeAddon.Effects:StopGlowsOnParent(frame)
end
frame._glowEffect = nil
```

---

### Issue P3: CollapsiblePool Children Not Cleared on Reset
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:534-562`
**Description:** Collapsible sections contain dynamically created child frames (content items). When released to pool, these children persist, causing:
- Memory bloat over time
- Visual artifacts if reused with different content count

**Fix:** Add child cleanup to reset function:
```lua
local children = {frame:GetChildren()}
for _, child in ipairs(children) do
    if child ~= frame.header and child ~= frame.content then
        child:Hide()
        child:SetParent(nil)
    end
end
```

---

### Issue P4: UpgradeCardPool Missing from SelectTab Cleanup
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:1246`
**Description:** The `SelectTab()` function releases cards from `cardPool`, `containerPool`, `collapsiblePool`, but doesn't release from `upgradeCardPool` if it exists.

**Fix:** Add to SelectTab cleanup:
```lua
if self.upgradeCardPool then
    self.upgradeCardPool:ReleaseAll()
end
```

---

### Issue P5: SocialContentRegions Not Cleared in OnDisable
**Severity:** LOW
**File:** `Journal/Journal.lua:62-263`
**Description:** The `socialContentRegions` array tracks FontStrings/Textures for manual cleanup. While it's wiped on tab switch, it's not explicitly cleared in `OnDisable()`, leaving dangling references.

**Fix:** Add to OnDisable:
```lua
if self.socialContentRegions then
    wipe(self.socialContentRegions)
end
```

---

## 2. HOVER HANDLERS AUDIT

### Issue H1: EntryCard OnEnter Missing Visual Feedback
**Severity:** MEDIUM
**File:** `UI/Components.lua:964-978`
**Description:** The `CreateEntryCard()` function creates cards with OnEnter/OnLeave handlers, but the OnEnter only plays a sound - no visual feedback (border highlight, backdrop change).

**Current Code:**
```lua
card:SetScript("OnEnter", function(self)
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    -- No visual change!
end)
```

**Fix:** Add visual feedback:
```lua
card:SetScript("OnEnter", function(self)
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    self:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold highlight
end)
```

---

## 3. OVERLAP & Z-ORDER AUDIT

### Issue Z1: Game Window Strata Inconsistent with Popups
**Severity:** LOW
**File:** `Social/Games/GameUI.lua:155`
**Description:** Game windows are set to `DIALOG` strata, but challenge popups and invite dialogs don't explicitly set strata (default `MEDIUM`). Popups may render behind game windows.

**Fix:** Set strata on all modal popups:
```lua
challengePopup:SetFrameStrata("DIALOG")
challengePopup:SetFrameLevel(10)
```

---

### Issue Z2: Modal Popups Missing Click-Through Prevention
**Severity:** MEDIUM
**File:** Multiple (MinigamesUI.lua, GameUI.lua)
**Description:** Modal popups don't prevent clicks from passing through to frames behind them. Clicks on transparent areas may trigger unintended actions.

**Fix:** Add to all modal frames:
```lua
popup:EnableMouse(true)
popup:SetPropagateMouseClicks(false)
```

---

## 4. MARGINS & SPACING AUDIT

### Issue M1: Inconsistent Padding in Content Frames
**Severity:** LOW
**File:** Multiple locations
**Description:** Different sections use different padding calculations:
- `Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL`
- `Components.MARGIN_NORMAL`
- Hardcoded `40`

**Fix:** Create unified constant:
```lua
Components.HEADER_LEFT_PADDING = Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL
```

---

### Issue M2: Hardcoded Spacer Heights Throughout Code
**Severity:** LOW
**File:** Multiple (WordGame.lua, DeathRollUI.lua, Components.lua)
**Description:** Y-offset values are hardcoded instead of using constants:
- `tile:SetPoint("TOPLEFT", 3, -3)`
- `label:SetPoint("TOP", myIcon, "BOTTOM", 0, -5)`

**Fix:** Define spacing constants at module level.

---

## 5. MEMORY LEAK AUDIT

### Issue MEM1: FontStrings in Containers Not Cleaned on Pool Release
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:3528-3596`
**Description:** FontStrings created inside pooled containers persist when container is released. `ClearEntries()` releases containers but doesn't clear their FontString children.

**Fix:** Add to containerPool reset function:
```lua
local function resetContainer(frame)
    -- Clear child FontStrings
    for _, region in ipairs({frame:GetRegions()}) do
        if region:GetObjectType() == "FontString" then
            region:Hide()
            region:SetText("")
        end
    end
end
```

---

### Issue MEM2: OnUpdate Scripts Not Cleared on Game Close
**Severity:** MEDIUM
**File:** `Social/Games/WordsWithWoW/WordGame.lua:2772`
**Description:** Tile frames have OnUpdate scripts for animation. If game closes before animation completes, OnUpdate persists on pooled frames.

**Fix:** Add to CleanupGame():
```lua
if game.data.ui.boardTiles then
    for row = 1, 15 do
        for col = 1, 15 do
            local tile = game.data.ui.boardTiles[row][col]
            if tile then
                tile:SetScript("OnUpdate", nil)
                tile.animating = nil
            end
        end
    end
end
```

---

### Issue MEM3: socialContentRegions Unbounded Growth Risk
**Severity:** LOW
**File:** `Journal/Journal.lua:62-63`
**Description:** The `socialContentRegions` array could theoretically grow unbounded if an error prevents the wipe during tab switch.

**Fix:** Add bounds checking:
```lua
function Journal:TrackSocialRegion(region)
    if region and #self.socialContentRegions < 1000 then
        table.insert(self.socialContentRegions, region)
    end
end
```

---

### Issue MEM4: Glow Effects Not Stopped Before Card Pool Release
**Severity:** MEDIUM
**File:** `Journal/Journal.lua:3493-3494, 262-263`
**Description:** Cards with active glow effects are released to pool without stopping the glow. Also, code references `StopGlow()` which doesn't exist - should be `StopGlowsOnParent()`.

**Fix:**
```lua
-- Before releasing card to pool:
if card._glowEffect and HopeAddon.Effects then
    HopeAddon.Effects:StopGlowsOnParent(card)
end
card._glowEffect = nil
```

---

### Issue MEM5: ProfileEditor EditBox Handlers Not Cleared
**Severity:** LOW
**File:** `Journal/ProfileEditor.lua`
**Description:** EditBoxes in ProfileEditor have event handlers that aren't cleared on hide, potentially leaving listeners active.

**Fix:** Add cleanup in OnDisable:
```lua
function ProfileEditor:OnDisable()
    if self.backstoryBox then
        self.backstoryBox.editBox:SetScript("OnTextChanged", nil)
    end
end
```

---

## Summary Table

| ID | Category | Severity | File | Description |
|----|----------|----------|------|-------------|
| P1 | Pooling | MEDIUM | Journal.lua:971-979 | CardPool defaultBorderColor set after OnLeave |
| P2 | Pooling | MEDIUM | Journal.lua:473-531 | CardPool reset missing callback/state cleanup |
| P3 | Pooling | MEDIUM | Journal.lua:534-562 | CollapsiblePool children not cleared on reset |
| P4 | Pooling | MEDIUM | Journal.lua:1246 | UpgradeCardPool missing from SelectTab cleanup |
| P5 | Pooling | LOW | Journal.lua:62-263 | SocialContentRegions not cleared in OnDisable |
| H1 | Hover | MEDIUM | Components.lua:964-978 | EntryCard OnEnter missing visual feedback |
| Z1 | Z-Order | LOW | GameUI.lua:155 | Game window strata inconsistent with popups |
| Z2 | Z-Order | MEDIUM | Multiple | Modal popups missing click-through prevention |
| M1 | Spacing | LOW | Multiple | Inconsistent content frame padding |
| M2 | Spacing | LOW | Multiple | Hardcoded Y-offsets instead of constants |
| MEM1 | Memory | MEDIUM | Journal.lua:3528-3596 | FontStrings in containers not cleaned |
| MEM2 | Memory | MEDIUM | WordGame.lua:2772 | OnUpdate scripts not cleared on game close |
| MEM3 | Memory | LOW | Journal.lua:62-63 | socialContentRegions unbounded growth risk |
| MEM4 | Memory | MEDIUM | Journal.lua:3493-3494 | Glow effects not stopped before pool release |
| MEM5 | Memory | LOW | ProfileEditor.lua | EditBox handlers not cleared on disable |

---

## Priority Fix Order

### HIGH PRIORITY (Address immediately)
1. **MEM4** - Fix glow cleanup with `StopGlowsOnParent()`
2. **P4** - Add `upgradeCardPool:ReleaseAll()` to SelectTab
3. **Z2** - Add `SetPropagateMouseClicks(false)` to modals
4. **MEM2** - Explicit OnUpdate cleanup in game close

### MEDIUM PRIORITY (Next iteration)
5. **P2** - Enhance cardPool reset to clear callbacks
6. **P3** - Add child frame cleanup to collapsiblePool reset
7. **MEM1** - Add FontString cleanup to containerPool reset
8. **P1** - Move defaultBorderColor before script handlers
9. **H1** - Add visual feedback to EntryCard OnEnter

### LOW PRIORITY (Nice to have)
10. **M1/M2** - Consolidate hardcoded spacing into constants
11. **MEM3** - Add bounds checking to socialContentRegions
12. **MEM5** - Add EditBox handler cleanup
13. **Z1** - Standardize frame strata for all popups
14. **P5** - Clear socialContentRegions in OnDisable

---

## Implementation Notes

All fixes are localized and don't require architectural changes. The codebase follows good patterns overall - these are edge cases and refinements rather than fundamental issues.

**Estimated effort:** 2-3 hours for HIGH priority, 2-3 hours for MEDIUM priority.
