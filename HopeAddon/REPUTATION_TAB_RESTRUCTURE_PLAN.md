# Reputation Tab Restructure Plan - Detailed Payloads

## Current State Analysis

### Existing Code Structure

**PopulateReputation()** (Journal.lua:2971-3034)
- Creates header "FACTION STANDING"
- Shows Aldor/Scryers choice card (if applicable)
- Iterates `Data:GetOrderedCategories()` → `Data:GetFactionsByCategory(catId)`
- Creates category headers and faction cards via `CreateReputationCard()`

**CreateReputationCard()** (Journal.lua:3179-3297)
- Gets standing from `Reputation:GetFactionStanding(info.name)`
- Gets progress from `Reputation:GetProgressInStanding(info.name)` → returns `(current, max, standingId)`
- Card height: 140px (with bar) or 80px (special cards)
- Uses `Components:CreateSegmentedReputationBar(card, barWidth, 14)` at bottom
- Calls `repBar:SetItemIcon(standing, item, standingId)` for each standing 5-8
- Golden glow for Exalted via `Effects:CreatePulsingGlow()`

**CreateSegmentedReputationBar()** (Components.lua:2499-2770)
- Container: `width × (height + 20 + 4 + 14)` = ~54px total height
- 4 segments (Friendly/Honored/Revered/Exalted) with dividers
- 4 item icon containers (20x20) positioned above each segment
- Standing labels below each segment
- Badge on right showing current standing

**Helper Functions** (Journal.lua:3036-3177)
- `GetBestRepItemForFaction(factionName)` - Returns single best item
- `GetRepItemsByStanding(factionName)` - Returns `{[standingId] = item}`
- `CreateRepItemLink()` - Clickable item with tooltip (NOT USED currently)
- `CreateStandingLabel()` - Fallback label (NOT USED currently)

**Data Source** (Constants.lua:4026+)
- `C.CLASS_SPEC_LOOT_HOTLIST[classToken][specTab].rep` array
- Each item: `{ itemId, name, icon, quality, slot, stats, source, sourceType, faction, standing }`
- ~3 rep items per spec, ~27 specs = ~81 total rep items

---

## Proposed Design

### Visual Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  FACTION STANDING                                               │
│  Your reputation across Outland                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ★ UPGRADES FOR YOUR SPEC                                       │
│  Protection Warrior                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [32x32]  Bladespire Warbands              [BUY NOW] or [45%]   │
│           Wrist • Epic • +33 Sta, +21 Def                       │
│           Keepers of Time @ Exalted                             │
│           [████████████████░░░░░░░░] Revered → Exalted          │
│                                                                 │
│  [32x32]  Veteran's Plate Belt                      [LOCKED]    │
│           Waist • Epic • +40 Sta, +23 Def, +22 Block            │
│           Honor Hold @ Exalted                                  │
│           [████████░░░░░░░░░░░░░░░░] Honored → Exalted          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─ HELLFIRE CAMPAIGN ─────────────────────────────────────────────┐
│                                                                 │
│  [ICON]  Honor Hold                                             │
│          "You get to use the good outhouse now. Luxury!"        │
│          [████████████░░░░░░░░] Honored (67%)         [Honored] │
│                                                                 │
│  [ICON]  Thrallmar                                              │
│          "Lok'tar... who are you again?"                        │
│          [░░░░░░░░░░░░░░░░░░░░] Neutral (0%)          [Neutral] │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Changes

| Aspect | Before | After |
|--------|--------|-------|
| Item visibility | 20x20 icons above bar segments | 32x32 icons in dedicated section |
| Item info | Hover tooltip only | Inline stats + faction + standing |
| Faction card | 140px with segmented bar | ~80px with simple inline bar |
| Progress display | 4-segment bar per faction | Single progress bar with % |
| Sorting | By faction category | Items sorted by obtainability |

---

## PAYLOAD 1: New Upgrade Item Card Component

**Goal:** Create a reusable card component for displaying reputation upgrade items prominently.

### File: UI/Components.lua

**Add new function: `CreateUpgradeItemCard()`** (~120 lines)

**Location:** After `CreateSegmentedReputationBar` (around line 2770)

```lua
--[[
    CreateUpgradeItemCard - Card showing a recommended upgrade item with rep progress
    @param parent Frame - Parent frame
    @param itemData table - Item from CLASS_SPEC_LOOT_HOTLIST.rep
    @param factionProgress table - { standingId, current, max, standingName }
    @return Frame - The card frame
]]
function Components:CreateUpgradeItemCard(parent, itemData, factionProgress)
    local C = HopeAddon.Constants
    local CARD_HEIGHT = 85
    local ICON_SIZE = 32

    -- Create card frame with backdrop
    local card = CreateBackdropFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetSize(parent:GetWidth() - 20, CARD_HEIGHT)
    self:ApplyBackdrop(card, "TOOLTIP")

    -- Quality border color
    local qualityColor = C.ITEM_QUALITY_COLORS[itemData.quality] or C.ITEM_QUALITY_COLORS.common
    card:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)

    -- Icon (32x32)
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
    icon:SetTexture("Interface\\Icons\\" .. (itemData.icon or "INV_Misc_QuestionMark"))
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Icon border glow
    local iconBorder = card:CreateTexture(nil, "OVERLAY")
    iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    iconBorder:SetBlendMode("ADD")
    iconBorder:SetPoint("CENTER", icon, "CENTER")
    iconBorder:SetSize(ICON_SIZE + 12, ICON_SIZE + 12)
    iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b, 0.8)

    -- Item name (top line)
    local nameText = card:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(AssetFonts.HEADER, 12, "")
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
    nameText:SetText(itemData.name)
    nameText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Slot + Stats (second line)
    local statsText = card:CreateFontString(nil, "OVERLAY")
    statsText:SetFont(AssetFonts.BODY, 10, "")
    statsText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    statsText:SetText((itemData.slot or "Unknown") .. " • " .. (itemData.stats or ""))
    statsText:SetTextColor(0.8, 0.8, 0.8)

    -- Faction + Required Standing (third line)
    local factionText = card:CreateFontString(nil, "OVERLAY")
    factionText:SetFont(AssetFonts.SMALL, 10, "")
    factionText:SetPoint("TOPLEFT", statsText, "BOTTOMLEFT", 0, -2)
    local standingNames = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
    local reqStanding = itemData.standing or 8
    factionText:SetText((itemData.faction or "Unknown") .. " @ " .. standingNames[reqStanding])

    -- Color based on obtainability
    local isObtainable = factionProgress.standingId >= reqStanding
    if isObtainable then
        factionText:SetTextColor(0, 1, 0)  -- Green
    else
        factionText:SetTextColor(1, 0.6, 0)  -- Orange
    end

    -- Status badge (right side)
    local statusBadge = card:CreateFontString(nil, "OVERLAY")
    statusBadge:SetFont(AssetFonts.HEADER, 10, "OUTLINE")
    statusBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
    if isObtainable then
        statusBadge:SetText("|cFF00FF00BUY NOW|r")
    else
        -- Show progress percentage toward required standing
        local totalNeeded = self:CalculateRepToStanding(factionProgress.standingId, reqStanding)
        local progress = math.floor((1 - (totalNeeded / self:GetTotalRepForStanding(reqStanding))) * 100)
        statusBadge:SetText(progress .. "%")
        statusBadge:SetTextColor(1, 0.8, 0)
    end

    -- Progress bar at bottom
    local barWidth = card:GetWidth() - ICON_SIZE - 40
    local progressBar = self:CreateProgressBar(card, barWidth, 10)
    progressBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", ICON_SIZE + 20, 8)

    -- Calculate and set progress
    local progress = 0
    if factionProgress.max > 0 then
        progress = factionProgress.current / factionProgress.max
    end
    progressBar:SetProgress(progress)

    -- Progress label
    local progressLabel = card:CreateFontString(nil, "OVERLAY")
    progressLabel:SetFont(AssetFonts.SMALL, 9, "")
    progressLabel:SetPoint("LEFT", progressBar, "RIGHT", 6, 0)
    progressLabel:SetText(factionProgress.standingName)

    -- Grey out icon if not obtainable
    if not isObtainable then
        icon:SetDesaturated(true)
        icon:SetVertexColor(0.7, 0.7, 0.7)
    end

    -- Tooltip
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if itemData.itemId then
            GameTooltip:SetHyperlink("item:" .. itemData.itemId)
        else
            GameTooltip:AddLine(itemData.name, qualityColor.r, qualityColor.g, qualityColor.b)
            GameTooltip:AddLine(itemData.stats, 1, 1, 1)
        end
        GameTooltip:AddLine(" ")
        if isObtainable then
            GameTooltip:AddLine("Available for purchase!", 0, 1, 0)
        else
            GameTooltip:AddLine("Requires: " .. standingNames[reqStanding], 1, 0.5, 0)
        end
        GameTooltip:Show()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    card:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return card
end
```

**Helper functions needed:**

```lua
-- Calculate rep needed from current standing to target standing
function Components:CalculateRepToStanding(fromStanding, toStanding)
    local REP_PER_STANDING = {
        [5] = 3000,   -- Neutral → Friendly
        [6] = 6000,   -- Friendly → Honored
        [7] = 12000,  -- Honored → Revered
        [8] = 21000,  -- Revered → Exalted
    }
    local total = 0
    for i = fromStanding + 1, toStanding do
        total = total + (REP_PER_STANDING[i] or 0)
    end
    return total
end

-- Get total rep needed for a standing from neutral
function Components:GetTotalRepForStanding(standingId)
    local totals = { [5] = 3000, [6] = 9000, [7] = 21000, [8] = 42000 }
    return totals[standingId] or 0
end
```

**Estimated:** ~150 lines, 1 hour

---

## PAYLOAD 2: Recommended Upgrades Section

**Goal:** Create the "UPGRADES FOR YOUR SPEC" section that appears at the top of Reputation tab.

### File: Journal/Journal.lua

**Add new function: `CreateRecommendedUpgradesSection()`** (~100 lines)

**Location:** After `PopulateReputation()` definition (around line 3035)

```lua
--[[
    CreateRecommendedUpgradesSection - Shows spec-appropriate rep items sorted by obtainability
    Displays at top of Reputation tab, before faction categories
]]
function Journal:CreateRecommendedUpgradesSection()
    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local Reputation = HopeAddon:GetModule("Reputation")

    -- Get player spec info
    local _, classToken = UnitClass("player")
    local specName, specTab = HopeAddon:GetPlayerSpec()
    if not specTab or specTab < 1 then specTab = 1 end

    -- Get rep items for this spec
    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    if not classData then return end

    local specData = classData[specTab]
    if not specData or not specData.rep or #specData.rep == 0 then return end

    -- Build items with faction progress data
    local items = {}
    for _, item in ipairs(specData.rep) do
        local standingId = 4  -- Default neutral
        local standingName = "Neutral"
        local current, max = 0, 0

        if Reputation and item.faction then
            local cached = Reputation:GetFactionStanding(item.faction)
            if cached then
                standingId = cached.standingId
            end
            local curr, mx, _ = Reputation:GetProgressInStanding(item.faction)
            if curr then current = curr end
            if mx then max = mx end

            -- Get standing name
            local Data = HopeAddon.ReputationData
            local standingInfo = Data:GetStandingInfo(standingId)
            standingName = standingInfo and standingInfo.name or "Unknown"
        end

        local requiredStanding = item.standing or 8
        local isObtainable = standingId >= requiredStanding

        -- Calculate priority (lower = show first)
        -- Obtainable items first, then sort by how close to requirement
        local priority
        if isObtainable then
            priority = 0  -- Already obtainable - top priority
        else
            -- Closer to requirement = lower priority number
            priority = (requiredStanding - standingId) * 100 - current
        end

        table.insert(items, {
            item = item,
            factionProgress = {
                standingId = standingId,
                standingName = standingName,
                current = current,
                max = max,
            },
            isObtainable = isObtainable,
            priority = priority,
        })
    end

    -- Sort by priority (obtainable first, then closest to requirement)
    table.sort(items, function(a, b) return a.priority < b.priority end)

    -- Section header
    local header = self:CreateSectionHeader(
        "UPGRADES FOR YOUR SPEC",
        "GOLD_BRIGHT",
        specName or "Your current spec"
    )
    self.mainFrame.scrollContainer:AddEntry(header)

    -- Create item cards (show all, typically 3)
    for i, itemData in ipairs(items) do
        local card = Components:CreateUpgradeItemCard(
            self.mainFrame.scrollContainer.content,
            itemData.item,
            itemData.factionProgress
        )
        self.mainFrame.scrollContainer:AddEntry(card)
    end

    -- Spacer before faction categories
    local spacer = self:CreateSpacer(20)
    self.mainFrame.scrollContainer:AddEntry(spacer)
end
```

**Estimated:** ~100 lines, 45 minutes

---

## PAYLOAD 3: Simplify Faction Cards

**Goal:** Remove the complex segmented bar with item icons from faction cards. Replace with a simple inline progress bar.

### File: Journal/Journal.lua

**Modify: `CreateReputationCard()`** (lines 3179-3297)

**Changes:**
1. Reduce card height from 140 to 85
2. Remove `CreateSegmentedReputationBar` call
3. Add simple inline progress bar
4. Keep quips, icon, border colors, exalted glow

**Before (line 3239-3289):**
```lua
-- Create card (taller for progress bar + item icons)
local needsProgressBar = not info.isSpecial and info.data
local cardHeight = needsProgressBar and 140 or 80  -- Extra height for bar + icons + labels
...
-- Add segmented progress bar for regular factions
if needsProgressBar then
    local barWidth = card:GetWidth() - Components.ICON_SIZE_STANDARD - 3 * Components.MARGIN_NORMAL - 60
    local repBar = Components:CreateSegmentedReputationBar(card, barWidth, 14)
    ...
    local itemsByStanding = self:GetRepItemsByStanding(info.name)
    for standing = 5, 8 do
        local item = itemsByStanding[standing]
        if item then
            repBar:SetItemIcon(standing, item, standingId)
        end
    end
end
```

**After:**
```lua
-- Create card (simplified height)
local needsProgressBar = not info.isSpecial and info.data
local cardHeight = needsProgressBar and 85 or 80

local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
    icon = icon,
    title = info.name,
    description = description,
    timestamp = "",
})
card:SetHeight(cardHeight)

-- Set border color based on standing
card:SetBackdropBorderColor(r, g, b, 1)
card.defaultBorderColor = {r, g, b, 1}

-- Grey out border for "not started" factions
if not info.isSpecial and standingId <= 4 and current == 0 and (max == 0 or max == nil) then
    card:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    card.defaultBorderColor = {0.4, 0.4, 0.4, 0.8}
end

-- Add simple inline progress bar for regular factions
if needsProgressBar then
    local barWidth = card:GetWidth() - Components.ICON_SIZE_STANDARD - 3 * Components.MARGIN_NORMAL - 80

    -- Simple progress bar (not segmented)
    local progressBar = Components:CreateProgressBar(card, barWidth, 12)
    progressBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",
        Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL, 10)

    -- Calculate progress within current standing (0-1)
    local progress = 0
    if max and max > 0 then
        progress = current / max
    end
    progressBar:SetProgress(progress)

    -- Standing badge on right
    local standingBadge = card:CreateFontString(nil, "OVERLAY")
    standingBadge:SetFont(HopeAddon.assets.fonts.HEADER, 10, "OUTLINE")
    standingBadge:SetPoint("LEFT", progressBar, "RIGHT", 8, 0)
    standingBadge:SetText(standingName)
    standingBadge:SetTextColor(r, g, b)

    -- Progress percentage
    local pctText = card:CreateFontString(nil, "OVERLAY")
    pctText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    pctText:SetPoint("BOTTOMLEFT", progressBar, "TOPLEFT", 0, 2)
    local pct = max > 0 and math.floor((current / max) * 100) or 0
    pctText:SetText(pct .. "% to next")
    pctText:SetTextColor(0.7, 0.7, 0.7)
end

-- Add golden glow for Exalted
if standingId == 8 then
    Effects:CreatePulsingGlow(card, "GOLD_BRIGHT", 0.3)
end

return card
```

**Net change:** Remove ~30 lines, add ~25 lines = -5 lines

**Estimated:** 30 minutes

---

## PAYLOAD 4: Update PopulateReputation Flow

**Goal:** Call the new upgrades section at the top of the tab.

### File: Journal/Journal.lua

**Modify: `PopulateReputation()`** (lines 2971-3034)

**Add call after header, before Aldor/Scryers:**

```lua
function Journal:PopulateReputation()
    local Components = HopeAddon.Components
    local Data = HopeAddon.ReputationData
    local Reputation = HopeAddon:GetModule("Reputation")

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("FACTION STANDING", "ARCANE_PURPLE", "Your reputation across Outland")
    self.mainFrame.scrollContainer:AddEntry(header)

    -- NEW: Recommended upgrades section at top
    self:CreateRecommendedUpgradesSection()

    -- Check for Aldor/Scryers choice
    local choice = HopeAddon.charDb.reputation and HopeAddon.charDb.reputation.aldorScryerChoice
    -- ... rest unchanged
```

**Estimated:** 5 minutes

---

## PAYLOAD 5: Cleanup Dead Code

**Goal:** Remove unused functions and simplify Components.lua.

### File: Journal/Journal.lua

**Remove these functions (no longer used):**
- `CreateRepItemLink()` (lines 3101-3159) - Was unused, item display moved to upgrade cards
- `CreateStandingLabel()` (lines 3161-3177) - Was unused fallback
- `GetRepItemsByStanding()` (lines 3067-3099) - No longer needed (segmented bar removed)

**Keep:**
- `GetBestRepItemForFaction()` (lines 3036-3065) - May be useful for tooltips

### File: UI/Components.lua

**Option A: Keep `CreateSegmentedReputationBar`**
- It's a complete component that could be reused elsewhere
- Just won't be called by Reputation tab

**Option B: Remove it entirely**
- ~270 lines (2499-2770)
- Nothing else uses it currently

**Recommendation:** Option A - keep it but mark as available for future use

**Estimated:** 15 minutes

---

## Summary: Payload Breakdown

| Payload | Description | Lines Changed | Time Est. |
|---------|-------------|---------------|-----------|
| **P1** | CreateUpgradeItemCard component | +150 | 1 hour |
| **P2** | CreateRecommendedUpgradesSection | +100 | 45 min |
| **P3** | Simplify CreateReputationCard | -5 net | 30 min |
| **P4** | Update PopulateReputation flow | +3 | 5 min |
| **P5** | Cleanup dead code | -80 | 15 min |
| **Total** | | +168 net | ~2.5 hours |

---

## Execution Order

1. **P1 first** - New component with no dependencies
2. **P2 second** - Uses P1 component
3. **P3 third** - Modifies existing function
4. **P4 fourth** - Wires everything together
5. **P5 last** - Cleanup after verification

---

## Testing Checklist

### Payload 1 (CreateUpgradeItemCard)
- [ ] Card displays with correct icon, name, stats
- [ ] Quality border color matches item quality
- [ ] "BUY NOW" shows for obtainable items (green)
- [ ] Progress % shows for locked items (orange)
- [ ] Progress bar fills correctly
- [ ] Tooltip shows item info
- [ ] Greyed out icon for locked items

### Payload 2 (CreateRecommendedUpgradesSection)
- [ ] Section header shows spec name
- [ ] All 3 rep items for spec displayed
- [ ] Sorted by obtainability (obtainable first)
- [ ] Handles missing spec data gracefully
- [ ] Spacer after section

### Payload 3 (Simplified Faction Cards)
- [ ] Card height reduced to ~85px
- [ ] Simple progress bar shows correctly
- [ ] Standing badge shows on right
- [ ] Progress % displayed
- [ ] Quips still show
- [ ] Border colors correct by standing
- [ ] Exalted glow still works
- [ ] "Not started" grey border works

### Payload 4 (Flow Update)
- [ ] Upgrades section appears first
- [ ] Aldor/Scryers choice still works
- [ ] Categories still render correctly
- [ ] Scroll container layout correct

### Payload 5 (Cleanup)
- [ ] No Lua errors from removed functions
- [ ] No orphaned references

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Components:CreateProgressBar doesn't exist | P1, P3 fail | Check first, may need to use CreateReputationBar |
| Spec detection fails | P2 shows nothing | Fallback to spec 1 (already in code) |
| Faction names mismatch | No progress data | Verify faction names match ReputationData exactly |
| Pool memory issues | Memory leak | Cards should use existing cardPool |

---

## Dependencies Verified

- ✅ `HopeAddon:GetPlayerSpec()` exists (Core.lua:559-585)
- ✅ `C.CLASS_SPEC_LOOT_HOTLIST` exists (Constants.lua:4026+)
- ✅ `Reputation:GetFactionStanding()` exists (Reputation.lua)
- ✅ `Reputation:GetProgressInStanding()` exists (Reputation.lua:472-491)
- ✅ `HopeAddon.ReputationData:GetStandingInfo()` exists (ReputationData.lua)
- ⚠️ `Components:CreateProgressBar()` - need to verify exists

---

## API Reference

### Reputation Module
```lua
Reputation:GetFactionStanding(factionName)
-- Returns: { standingId, earnedValue, factionId } or nil

Reputation:GetProgressInStanding(factionName)
-- Returns: current, max, standingId (rep within current standing)
```

### ReputationData
```lua
Data:GetStandingInfo(standingId)
-- Returns: { name, color, hex, threshold }

Data:GetOrderedCategories()
-- Returns: array of { id, data } sorted by order

Data:GetFactionsByCategory(categoryId)
-- Returns: array of { name, data }
```

### Constants
```lua
C.CLASS_SPEC_LOOT_HOTLIST[classToken][specTab].rep
-- Array of: { itemId, name, icon, quality, slot, stats, source, sourceType, faction, standing }
```
