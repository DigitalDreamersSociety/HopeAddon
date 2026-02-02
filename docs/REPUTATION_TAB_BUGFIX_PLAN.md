# Reputation Tab Bug Fix Plan - Detailed Analysis

**Document Version:** 1.1
**Created:** 2026-01-27
**Status:** ✓ FULLY IMPLEMENTED

---

## Executive Summary

Testing on a level 60 Draenei Shaman revealed multiple issues with the Reputation tab implementation:

1. **BiS icons showing as question marks** - Item cache not warmed up
2. **Wrong icons displayed** - Generic reward icons shown instead of actual BiS item icons
3. **UI organization issues** - Bar centering calculation overly complex
4. **Multi-icon container errors** - Legacy pooled bars incompatible with new structure

---

## Issue 1: BiS Icons Not Resolving

### Problem Description

BiS items from `GetSpecReputationBisItems()` don't have pre-stored `icon` fields in the database. The system relies on `GetItemInfo(itemId)` to fetch icons from the WoW client cache.

**For a level 60 character:**
- Many TBC reputation items have never been seen in-game
- WoW client cache doesn't have these items
- `GetItemInfo()` returns `nil` for the icon field
- Icons display as question marks or fall back to wrong icons

### Root Cause Analysis

**Data Flow:**
```
ARMORY_SPEC_BIS_DATABASE[phase][guideKey][slot].bis = {
    id = 30834,           -- ✓ Has itemId
    name = "...",         -- ✓ Has name
    source = "...",       -- ✓ Has source
    sourceType = "reputation"  -- ✓ Has type
    -- ❌ NO icon field!
}
```

**Code Path:**
```lua
-- Journal.lua: PopulateReputationItemIcons()
local function resolveIcon(item, standingId)
    if item.icon then return item.icon end  -- FAILS: no icon field

    -- Try GetItemInfo
    local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(item.itemId)
    if itemIcon then return itemIcon end  -- FAILS: not in cache

    -- Falls through to wrong fallback...
end
```

### Solution

**Option A: Pre-cache icons during addon load** (Recommended)
- Queue all BiS itemIds to `GetItemInfo()` on PLAYER_LOGIN
- WoW will async fetch item data from server
- Icons available by the time user opens Reputation tab

**Option B: Add icon fields to ARMORY_SPEC_BIS_DATABASE**
- Requires manual data entry for 100+ items
- Maintenance burden when data changes
- Not recommended

**Option C: Show loading state, retry on next view**
- Current approach with question marks
- Poor UX but functional

### Implementation (Option A)

**File:** `Core/ArmoryBisData.lua` (add at end)

```lua
-- Pre-cache reputation BiS items for icon resolution
function C:WarmupReputationItemCache()
    if not C.ARMORY_SPEC_BIS_DATABASE or not C.ARMORY_SPEC_BIS_DATABASE[1] then
        return
    end

    local itemIds = {}

    -- Collect all reputation item IDs from all specs
    for _, specData in pairs(C.ARMORY_SPEC_BIS_DATABASE[1]) do
        for _, slotData in pairs(specData) do
            -- Check BiS
            if slotData.bis and slotData.bis.sourceType == "reputation" then
                itemIds[slotData.bis.id] = true
            end
            -- Check alts
            if slotData.alts then
                for _, alt in ipairs(slotData.alts) do
                    if alt.sourceType == "reputation" then
                        itemIds[alt.id] = true
                    end
                end
            end
        end
    end

    -- Queue all items to GetItemInfo (async cache warmup)
    local count = 0
    for itemId in pairs(itemIds) do
        GetItemInfo(itemId)
        count = count + 1
    end

    if HopeAddon.Debug then
        HopeAddon:Debug("Warmed up " .. count .. " reputation BiS items for icon cache")
    end
end
```

**File:** `Core/Core.lua` (in PLAYER_LOGIN handler)

```lua
-- Add after existing PLAYER_LOGIN logic:
if HopeAddon.Constants and HopeAddon.Constants.WarmupReputationItemCache then
    HopeAddon.Constants:WarmupReputationItemCache()
end
```

---

## Issue 2: Wrong Icons from Generic Rewards

### Problem Description

When `GetItemInfo()` fails, the old code searched generic rewards at the same standing and returned ANY icon found - even if the itemId didn't match.

**Example:**
- BiS item: Shapeshifter's Signet (itemId 30834) at Lower City Exalted
- Generic reward at Exalted: Lower City Tabard (itemId 31778)
- Result: Signet shows with Tabard icon ❌

### Root Cause

```lua
-- OLD CODE (problematic):
local genericRewards = Data:GetAllRewards(factionName)
if genericRewards and genericRewards[standingId] then
    for _, genericItem in ipairs(genericRewards[standingId]) do
        if genericItem.itemId == item.itemId then
            return genericItem.icon  -- Only matches if SAME itemId
        end
    end
    -- BUG: Falls through and might use wrong icon elsewhere
end
```

The issue was the fallback logic outside this function that grabbed ANY icon.

### Solution

**Already Fixed in Current Code:**

```lua
-- NEW CODE (fixed):
local function resolveIcon(item, standingId)
    -- 1. Pre-stored icon from BiS data
    if item.icon then return item.icon end

    -- 2. Try GetItemInfo (works if item is in client cache)
    if item.itemId and item.itemId > 0 then
        GetItemInfo(item.itemId)  -- Queue for cache warmup
        local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(item.itemId)
        if itemIcon then return itemIcon end
    end

    -- 3. Try matching in generic rewards by itemId (same item in both sources)
    local genericRewards = Data:GetAllRewards(factionName)
    if genericRewards and genericRewards[standingId] then
        for _, genericItem in ipairs(genericRewards[standingId]) do
            if genericItem.itemId == item.itemId then
                return genericItem.icon
            end
        end
    end

    -- 4. Fallback - DO NOT use random generic reward icon
    -- Return question mark; icon will resolve on subsequent views after cache warmup
    return "INV_Misc_QuestionMark"
end
```

**Key Change:** Return question mark instead of grabbing wrong icon.

---

## Issue 3: UI Organization / Bar Centering

### Problem Description

The bar centering calculation was overly complex and included margin adjustments that didn't align with actual layout:

```lua
-- OLD CODE:
local cardInnerWidth = contentWidth - (Components.MARGIN_NORMAL * 2)
local remainingSpace = cardInnerWidth - barWidth
local leftOffset = math.floor(remainingSpace / 2) + Components.MARGIN_NORMAL
```

### Root Cause

Cards are anchored LEFT and RIGHT to scroll content with no internal padding. The `MARGIN_NORMAL` adjustments were incorrect.

### Solution

**Already Fixed:**

```lua
-- NEW CODE (simplified):
local BAR_WIDTH_PERCENT = 0.80
local barWidth = math.floor(contentWidth * BAR_WIDTH_PERCENT)
local leftOffset = math.floor((contentWidth - barWidth) / 2)

local segmentedBar = journalSelf:AcquireReputationBar(card, barWidth)
segmentedBar:ClearAllPoints()
segmentedBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", leftOffset, 8)
```

**Math Verification:**
- contentWidth = 480px
- barWidth = 480 * 0.80 = 384px
- leftOffset = (480 - 384) / 2 = 48px
- Bar positioned 48px from left edge, centered

---

## Issue 4: Multi-Icon Container Compatibility

### Problem Description

Error when switching tabs:
```
attempt to index field 'icon' (a nil value)
```

Pooled reputation bars created before the Phase 2 code update have the OLD structure:
- `itemContainers[i]` = Button with `.icon` texture directly

NEW structure:
- `itemContainers[i]` = Frame with `.icons[]` array of buttons

### Root Cause

`SetItemIcons()` assumed all containers had `.icons` array:

```lua
-- OLD CODE:
local iconContainer = self.itemContainers[segmentIndex]
if not iconContainer or not iconContainer.icons then return end  -- Fails silently

-- But backward compat wrapper called old structure methods:
function container:SetItemIcon(...)
    self:SetItemIcons(...)  -- Calls new method on old structure
end
```

### Solution

**Already Fixed - Added Legacy Detection:**

```lua
function container:SetItemIcons(standingId, items)
    local segmentIndex = standingId - 3
    if segmentIndex < 1 or segmentIndex > 5 then return end

    local iconContainer = self.itemContainers[segmentIndex]
    if not iconContainer then return end

    -- Handle legacy single-icon containers (pre-Phase 2 pooled bars)
    if not iconContainer.icons then
        -- Fallback: use old single-icon behavior for first item only
        if items and #items > 0 then
            local item = items[1]
            -- ... (legacy handling code)
        end
        return
    end

    -- New multi-icon logic continues...
end
```

---

## Issue 5: Shaman Spec Detection

### Analysis Performed

Verified the spec detection chain for Draenei Shaman:

```
GetCurrentPlayerGuideKey()
    → GetPlayerSpec() → specTab (1, 2, or 3)
    → GetSpecRole(SHAMAN, specTab) → role
    → GetGuideKeyForRole(SHAMAN, role) → guideKey
```

**ARMORY_SPECS.SHAMAN:**
| Spec Tab | Spec Name | Role | Guide Key |
|----------|-----------|------|-----------|
| 1 | Elemental | caster_dps | elemental-shaman-dps |
| 2 | Enhancement | melee_dps | enhancement-shaman-dps |
| 3 | Restoration | healer | shaman-healer |

**Reputation BiS Items for Shaman Specs:**

| Spec | Faction | Standing | ItemId | Name |
|------|---------|----------|--------|------|
| Elemental | The Violet Eye | Exalted | 29287 | Violet Signet of the Archmage |
| Elemental | Lower City | Exalted | 29126 | Seer's Signet |
| Elemental | The Scryers | Revered | 29132 | Scryer's Bloodgem |
| Enhancement | Lower City | Exalted | 30834 | Shapeshifter's Signet |
| Enhancement | The Violet Eye | Exalted | 29283 | Violet Signet of the Master Assassin |
| Resto | Keepers of Time | Exalted | 29183 | Bindings of the Timewalker |
| Resto | The Violet Eye | Exalted | 29290 | Violet Signet of the Grand Restorer |
| Resto | Honor Hold/Thrallmar | Exalted | 29169 | Ring of Convalescence |
| Resto | Lower City | Honored | 30841 | Lower City Prayerbook |
| Resto | The Aldor | Exalted | 29175 | Gavel of Pure Light |
| Resto | Cenarion Expedition | Exalted | 29170 | Windcaller's Orb |

**Verification:** Spec detection is working correctly. The issue was icon resolution, not spec detection.

---

## Implementation Checklist

### Already Implemented ✓

- [x] Phase 1: Bar centering (simplified math)
- [x] Phase 2: Multi-icon container structure
- [x] Phase 2: Legacy container compatibility
- [x] Phase 3: Validation script created
- [x] Phase 4: Enhanced tooltips
- [x] resolveIcon() fix (no wrong fallback icons)

### All Implemented ✓

- [x] **Item cache warmup function** - Added `WarmupReputationItemCache()` to ArmoryBisData.lua:2905-2960
- [x] **Call warmup on login** - Added call in Core.lua:1199-1203 (OnPlayerLogin)
- [ ] **Test with fresh character** - Verify icons resolve after cache warmup

---

## New Payload: Cache Warmup

### Payload 6A: ArmoryBisData.lua Addition

**Location:** End of `Core/ArmoryBisData.lua` (before final `end` if in function, or at module level)

```lua
--[[
    Pre-cache reputation BiS items for icon resolution
    Called on PLAYER_LOGIN to warm up client item cache
    This allows GetItemInfo() to return icons immediately
]]
function C:WarmupReputationItemCache()
    -- Only process Phase 1 data (most characters are here)
    if not C.ARMORY_SPEC_BIS_DATABASE or not C.ARMORY_SPEC_BIS_DATABASE[1] then
        return 0
    end

    local itemIds = {}

    -- Collect all reputation item IDs from all specs in Phase 1
    for guideKey, specData in pairs(C.ARMORY_SPEC_BIS_DATABASE[1]) do
        for slot, slotData in pairs(specData) do
            -- Check BiS item
            if slotData.bis and slotData.bis.sourceType == "reputation" and slotData.bis.id then
                itemIds[slotData.bis.id] = true
            end
            -- Check alt items
            if slotData.alts then
                for _, altItem in ipairs(slotData.alts) do
                    if altItem.sourceType == "reputation" and altItem.id then
                        itemIds[altItem.id] = true
                    end
                end
            end
        end
    end

    -- Queue all items to GetItemInfo (triggers async cache fetch)
    local count = 0
    for itemId in pairs(itemIds) do
        GetItemInfo(itemId)
        count = count + 1
    end

    return count
end
```

### Payload 6B: Core.lua PLAYER_LOGIN Addition

**Location:** Inside the PLAYER_LOGIN event handler in `Core/Core.lua`

**Find this section:**
```lua
elseif event == "PLAYER_LOGIN" then
```

**Add after existing PLAYER_LOGIN logic:**
```lua
    -- Warmup reputation BiS item cache for icon resolution
    if HopeAddon.Constants and HopeAddon.Constants.WarmupReputationItemCache then
        local count = HopeAddon.Constants:WarmupReputationItemCache()
        HopeAddon:Debug("Warmed up " .. count .. " reputation BiS items for icon cache")
    end
```

---

## Testing Protocol

### Test 1: Fresh Cache Test
1. `/reload` to apply changes
2. Open Journal → Reputation tab
3. Check each faction card for icons
4. BiS items should show correct icons (not question marks)

### Test 2: Spec-Specific Verification
1. Note your current spec (Enhancement, Elemental, or Restoration)
2. Check if BiS items match the spec table above
3. Verify icons match item names in tooltips

### Test 3: Multi-Icon Display
1. Find a faction with multiple items at same standing
2. Verify icons display side-by-side (up to 4)
3. BiS items should appear first with brighter gold border

### Test 4: Bar Centering
1. Visually verify bars are centered in cards
2. Should have equal margins on left and right (~48px each)
3. Bar width should be ~80% of card width

---

## Summary

| Issue | Status | Fix Location |
|-------|--------|--------------|
| BiS icons question marks | ✓ Fixed | ArmoryBisData.lua:2905-2960 + Core.lua:1199-1203 |
| Wrong generic icons | ✓ Fixed | Journal.lua resolveIcon() |
| Bar centering | ✓ Fixed | Journal.lua bar positioning |
| Legacy container errors | ✓ Fixed | Components.lua SetItemIcons() |
| Spec detection | ✓ Working | No changes needed |

**All fixes implemented.** Test with `/reload` to verify.
