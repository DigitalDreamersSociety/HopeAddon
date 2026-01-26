# Reputation Tab Enhanced Tooltips Plan

## Goal
Add Attunements-style rich hover tooltips to the "Upgrades For Your Spec" section in the Reputation tab, showing detailed color-coded information about reputation items.

---

## Current State Analysis

### Existing Components Verified
| Component | Location | Status |
|-----------|----------|--------|
| `CreateUpgradeItemCard` | Components.lua:2808-2942 | ✅ EXISTS - tooltip at lines 2916-2939 |
| `CLASS_SPEC_LOOT_HOTLIST` | Constants.lua:4026+ | ✅ EXISTS - 9 classes x 3 specs |
| `C.ITEM_QUALITY_COLORS` | Constants.lua:4001-4006 | ✅ EXISTS |
| `C.STANDING_NAMES` | Constants.lua:4009-4018 | ✅ EXISTS |
| `HopeAddon.colors` | Core.lua:37-80 | ✅ EXISTS - TBC color palette |
| `CreateRecommendedUpgradesSection` | Journal.lua:3043-3134 | ✅ EXISTS - calls CreateUpgradeItemCard |

### Existing Color Palette (Core.lua:37-80)
```lua
HopeAddon.colors = {
    FEL_GREEN       = { r = 0.20, g = 0.80, b = 0.20 },  -- Rep sources
    ARCANE_PURPLE   = { r = 0.61, g = 0.19, b = 1.00 },  -- Stat priority
    HELLFIRE_ORANGE = { r = 1.00, g = 0.55, b = 0.00 },  -- Tips (orange)
    SKY_BLUE        = { r = 0.00, g = 0.75, b = 1.00 },  -- Alternatives
    GOLD_BRIGHT     = { r = 1.00, g = 0.84, b = 0.00 },  -- Title
}
```

### Variables In Scope for OnEnter (Components.lua:2918)
| Variable | Line | Available |
|----------|------|-----------|
| `itemData` | 2808 (param) | ✅ Closure capture |
| `factionProgress` | 2808 (param) | ✅ Closure capture |
| `isObtainable` | 2864 | ✅ Closure capture |
| `qualityColor` | 2819 | ✅ Closure capture |
| `standingNames` | 2858 | ✅ Closure capture |
| `reqStanding` | 2859 | ✅ Closure capture |

### Attunements Tooltip Pattern (Journal.lua:3578-3639)
- Uses `GameTooltip:SetText()` for title
- Uses `GameTooltip:AddLine(" ")` for spacing
- Uses `GameTooltip:AddLine(text, r, g, b, true)` where `true` = word wrap
- Bullet character: `\226\128\162` (UTF-8 bullet •)
- Colors: Objectives=Sky Blue, Tips=Orange, Rewards=Green

---

## Payload Organization

### PAYLOAD 1: Components - Enhanced Tooltip Builder (30 minutes)
**File:** `UI/Components.lua`
**Lines:** ~60 added, ~20 replaced
**Location:** Before `CreateUpgradeItemCard` function (line ~2798)

**New Local Helper Function:**
```lua
--[[
    BuildRepItemTooltip - Enhanced tooltip with Attunements-style sections
    Uses existing HopeAddon.colors palette for TBC theme consistency
    @param frame Frame - Anchor frame for tooltip
    @param itemData table - Item from CLASS_SPEC_LOOT_HOTLIST
    @param factionProgress table - { standingId, standingName, current, max }
    @param isObtainable boolean - Whether player can buy the item
    @param qualityColor table - { r, g, b } for item quality
    @param reqStanding number - Required standing ID (5-8)
]]
local function BuildRepItemTooltip(frame, itemData, factionProgress, isObtainable, qualityColor, reqStanding)
    local C = HopeAddon.Constants
    local colors = HopeAddon.colors

    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")

    -- Item link (shows full item tooltip) or manual name
    if itemData.itemId then
        GameTooltip:SetHyperlink("item:" .. itemData.itemId)
    else
        GameTooltip:AddLine(itemData.name or "Unknown", qualityColor.r, qualityColor.g, qualityColor.b)
        if itemData.stats then
            GameTooltip:AddLine(itemData.stats, 1, 1, 1)
        end
    end

    -- Faction & Standing requirement
    GameTooltip:AddLine(" ")
    local standingName = C.STANDING_NAMES[reqStanding] or "Unknown"
    if isObtainable then
        GameTooltip:AddLine("Available for purchase!", 0, 1, 0)
    else
        GameTooltip:AddLine("Requires: " .. (itemData.faction or "Unknown") .. " " .. standingName, 1, 0.5, 0)
        GameTooltip:AddLine("Current: " .. (factionProgress.standingName or "Neutral"), 0.7, 0.7, 0.7)
    end

    -- Enhanced sections (if hoverData exists)
    local hover = itemData.hoverData
    if hover then
        -- Rep Sources (Fel Green)
        if hover.repSources and #hover.repSources > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("How to Earn Rep:", colors.FEL_GREEN.r, colors.FEL_GREEN.g, colors.FEL_GREEN.b)
            for _, source in ipairs(hover.repSources) do
                GameTooltip:AddLine("  \226\128\162 " .. source, 0.6, 0.85, 0.6, true)
            end
        end

        -- Stat Priority (Arcane Purple)
        if hover.statPriority and #hover.statPriority > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Why This Item:", colors.ARCANE_PURPLE.r, colors.ARCANE_PURPLE.g, colors.ARCANE_PURPLE.b)
            for _, reason in ipairs(hover.statPriority) do
                GameTooltip:AddLine("  \226\128\162 " .. reason, 0.75, 0.6, 0.9, true)
            end
        end

        -- Tips (Orange - matches Attunements)
        if hover.tips and #hover.tips > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Tips:", colors.HELLFIRE_ORANGE.r, colors.HELLFIRE_ORANGE.g, colors.HELLFIRE_ORANGE.b)
            for _, tip in ipairs(hover.tips) do
                GameTooltip:AddLine("  \226\128\162 " .. tip, 0.9, 0.8, 0.7, true)
            end
        end

        -- Alternatives (Sky Blue)
        if hover.alternatives and #hover.alternatives > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Alternatives:", colors.SKY_BLUE.r, colors.SKY_BLUE.g, colors.SKY_BLUE.b)
            for _, alt in ipairs(hover.alternatives) do
                GameTooltip:AddLine("  \226\128\162 " .. alt, 0.6, 0.8, 0.9, true)
            end
        end
    end

    GameTooltip:Show()
end
```

**Update OnEnter Handler** (replace lines 2918-2936):
```lua
    card:SetScript("OnEnter", function(self)
        BuildRepItemTooltip(self, itemData, factionProgress, isObtainable, qualityColor, reqStanding)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
```

---

### PAYLOAD 2: Constants - Sample hoverData for WARRIOR (45 minutes)
**File:** `Core/Constants.lua`
**Lines:** ~180 (add hoverData to 9 WARRIOR rep items)
**Location:** Within `CLASS_SPEC_LOOT_HOTLIST["WARRIOR"]` entries (lines 4030-4084)

**Example - Arms Warrior Item 1 (line ~4034):**
```lua
{
    itemId = 29119,
    name = "Haramad's Bargain",
    icon = "INV_Jewelry_Necklace_30naxxramas",
    quality = "epic",
    slot = "Neck",
    stats = "+20 Agi, +24 Sta, +22 Hit",
    source = "The Consortium @ Exalted",
    sourceType = "rep",
    faction = "The Consortium",
    standing = 8,
    hoverData = {
        repSources = {
            "Mana-Tombs (Normal: 5-10 rep/kill, Heroic: 15-25 rep/kill)",
            "Turn in Oshu'gun Crystal Powder Samples (250 rep per 10)",
            "Complete Consortium quests in Nagrand and Netherstorm",
        },
        statPriority = {
            "Best pre-raid DPS neck for physical damage dealers",
            "+22 Hit Rating helps reach melee hit cap (9%)",
            "Agility provides crit and armor for survival",
        },
        tips = {
            "Farm Oshu'gun Powder in Nagrand (ogres, ethereals)",
            "Mana-Tombs Heroic is fastest rep once keyed",
            "Buy from Karaaz in Stormspire (Netherstorm)",
        },
        alternatives = {
            "Natasha's Ember Necklace (Quest: Nagrand)",
            "Necklace of the Deep (Fishing)",
            "Worgen Claw Necklace (H Underbog)",
        },
    },
},
```

**Items to populate for WARRIOR:**

| Spec | Line | Item | Faction | Standing |
|------|------|------|---------|----------|
| Arms [1] | 4034 | Haramad's Bargain | The Consortium | Exalted |
| Arms [1] | 4035 | Marksman's Bow | Honor Hold | Revered |
| Arms [1] | 4036 | Bloodlust Brooch | Thrallmar | Exalted |
| Fury [2] | 4052 | Haramad's Bargain | The Consortium | Exalted |
| Fury [2] | 4053 | Marksman's Bow | Honor Hold | Revered |
| Fury [2] | 4054 | Bloodlust Brooch | Thrallmar | Exalted |
| Prot [3] | 4070 | Bladespire Warbands | Keepers of Time | Exalted |
| Prot [3] | 4071 | Veteran's Plate Belt | Honor Hold | Exalted |
| Prot [3] | 4072 | Consortium Plated Legguards | The Consortium | Revered |

**Note:** Arms and Fury share identical items, so hoverData can be copy-pasted.

---

### PAYLOAD 3: Remaining Classes hoverData (Optional, Ongoing)
**File:** `Core/Constants.lua`
**Lines:** ~1440 total (8 remaining classes x ~180 lines each)

**Priority Order:**
1. **High Priority:** PALADIN (Prot, Holy), DRUID (Feral, Resto), PRIEST (Disc/Holy)
2. **Medium Priority:** SHAMAN (Resto, Ele), MAGE, WARLOCK
3. **Lower Priority:** HUNTER, ROGUE

**Scope per class:** 3 specs × 3 rep items × ~20 lines hoverData = ~180 lines

---

## File Changes Summary

| Payload | File | Lines | Time Est. |
|---------|------|-------|-----------|
| 1 | Components.lua | +60, -20 | 30 min |
| 2 | Constants.lua | +180 | 45 min |
| 3 | Constants.lua | +1440 | 3-4 hours |
| **Total (P1-P2)** | | **~220** | **~1.25 hours** |

---

## Validation Checklist

### Code Validation ✅
- [x] `CreateUpgradeItemCard` exists at Components.lua:2808-2942
- [x] Current tooltip handler at lines 2918-2939
- [x] `itemData`, `factionProgress`, `isObtainable`, `qualityColor`, `reqStanding` all in scope
- [x] `HopeAddon.colors` exists at Core.lua:37-80 with all needed colors
- [x] `C.STANDING_NAMES` exists at Constants.lua:4009-4018
- [x] Attunements pattern uses same tooltip approach (Journal.lua:3578-3639)

### Design Validation ✅
- [x] Uses existing `HopeAddon.colors` (no new color constants needed)
- [x] Fallback behavior: items without `hoverData` show basic tooltip
- [x] Matches Attunements bullet pattern (`\226\128\162`)
- [x] Word wrap enabled with `true` parameter on AddLine
- [x] Sound effect preserved (`HopeAddon.Sounds:PlayHover()`)

---

## Fallback Behavior

Items without `hoverData` field continue showing existing basic tooltip:
1. Item link via `SetHyperlink` (shows WoW item tooltip)
2. "Available for purchase!" (green) OR "Requires: Faction Standing" (orange)

This allows incremental data population without breaking existing functionality.

---

## Visual Mockup

```
+--------------------------------------------------+
| Haramad's Bargain                                |
| Binds when picked up                             |
| Neck                                             |
| +20 Agility                                      |
| +24 Stamina                                      |
| +22 Hit Rating                                   |
|                                                  |
| Requires: The Consortium Exalted                 |
| Current: Honored                                 |
|                                                  |
| How to Earn Rep:                     [FEL GREEN] |
|   • Mana-Tombs (Normal: 5-10, Heroic: 15-25/kill)|
|   • Turn in Crystal Powder Samples (250 rep/10) |
|   • Complete Consortium quests in Nagrand       |
|                                                  |
| Why This Item:                   [ARCANE PURPLE] |
|   • Best pre-raid DPS neck for physical damage  |
|   • +22 Hit Rating helps reach 9% hit cap       |
|   • Agility provides crit and armor             |
|                                                  |
| Tips:                            [HELLFIRE ORANGE]|
|   • Farm Oshu'gun Powder in Nagrand             |
|   • Mana-Tombs Heroic is fastest once keyed     |
|   • Buy from Karaaz in Stormspire               |
|                                                  |
| Alternatives:                        [SKY BLUE] |
|   • Natasha's Ember Necklace (Quest: Nagrand)   |
|   • Necklace of the Deep (Fishing)              |
|   • Worgen Claw Necklace (H Underbog)           |
+--------------------------------------------------+
```

---

## Testing Checklist

- [ ] Items WITHOUT hoverData show basic tooltip (unchanged behavior)
- [ ] Items WITH hoverData show all 4 enhanced sections
- [ ] Colors match TBC theme (FEL_GREEN, ARCANE_PURPLE, HELLFIRE_ORANGE, SKY_BLUE)
- [ ] Tooltip doesn't overflow screen (word wrap working)
- [ ] Hover sound plays correctly
- [ ] GameTooltip hides properly on mouse leave
- [ ] Item hyperlink still works (shows WoW item stats)

---

## Implementation Notes

1. **No new Constants needed** - Reuses `HopeAddon.colors` from Core.lua
2. **Local function** - `BuildRepItemTooltip` is local to Components.lua (not exported)
3. **Closure safety** - All needed variables captured from outer scope
4. **Incremental rollout** - Start with WARRIOR class, add others as needed
5. **Duplicate handling** - Arms/Fury share items; copy hoverData for both
