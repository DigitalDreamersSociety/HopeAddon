# Reputation Tab Data Alignment Plan

**Document Version:** 2.0
**Created:** 2026-01-27
**Status:** Ready for Implementation

---

## Problem Statement

The Reputation tab icons are misaligned because:
1. Data is being pulled from wrong sources
2. Class/spec filtering is inconsistent
3. Multiple data sources may have conflicting/duplicate items

---

## Data Source Analysis

### Source 1: CLASS_SPEC_LOOT_HOTLIST (Journey Tab)
**Location:** `Core/Constants.lua:4620+`
**Structure:**
```lua
C.CLASS_SPEC_LOOT_HOTLIST = {
    ["WARRIOR"] = {
        [1] = {  -- Arms (specTab 1)
            rep = {
                {
                    itemId = 29119,
                    name = "Haramad's Bargain",
                    icon = "INV_Jewelry_Necklace_30naxxramas",
                    faction = "The Consortium",
                    standing = 8,  -- Exalted
                    slot = "Neck",
                    -- ... hoverData
                },
            },
            drops = { ... },
            crafted = { ... },
        },
        [2] = { ... },  -- Fury
        [3] = { ... },  -- Prot
    },
    ["SHAMAN"] = { ... },
    -- etc
}
```

**Characteristics:**
- ✓ Filtered by CLASS (classToken)
- ✓ Filtered by SPEC (specTab 1/2/3)
- ✓ Has `faction` field (maps to ReputationData faction name)
- ✓ Has `standing` field (required standing ID 5-8)
- ✓ Has `icon` field (pre-stored texture path)
- ✓ Has `itemId` field
- Used by: Journey tab's `CreateLootHotlist()`, `CreateRecommendedUpgradesSection()`

### Source 2: ARMORY_SPEC_BIS_DATABASE (Armory Tab)
**Location:** `Core/ArmoryBisData.lua:70+`
**Structure:**
```lua
C.ARMORY_SPEC_BIS_DATABASE = {
    [1] = {  -- Phase 1
        ["elemental-shaman-dps"] = {
            head = { bis = {...}, alts = {...} },
            ring1 = {
                bis = { id = 28793, name = "Band of Crimson Fury", source = "Magtheridon Quest", sourceType = "quest" },
                alts = {
                    { id = 29287, name = "Violet Signet of the Archmage", source = "Violet Eye Exalted", sourceType = "reputation" },
                },
            },
            -- etc per slot
        },
    },
}
```

**Characteristics:**
- ✓ Filtered by SPEC (guideKey like "elemental-shaman-dps")
- ✗ NOT directly filtered by CLASS (guideKey must be looked up)
- ✗ NO `faction` field - must parse from `source` string
- ✗ NO `standing` field - must parse from `source` string
- ✗ NO `icon` field - must use GetItemInfo()
- ✓ Has `id` field (itemId)
- ✓ Has `sourceType = "reputation"` flag
- Used by: Armory tab, `GetSpecReputationBisItems()`

### Source 3: ReputationData.TBC_FACTIONS (Generic Rewards)
**Location:** `Reputation/ReputationData.lua`
**Structure:**
```lua
Data.TBC_FACTIONS = {
    ["Honor Hold"] = {
        hoverData = {
            rewards = {
                [6] = {  -- Honored
                    { itemId = 28286, name = "Flamewrought Key", icon = "INV_Misc_Key_13" },
                },
                [8] = {  -- Exalted
                    { itemId = 23999, name = "Honor Hold Tabard", icon = "INV_Misc_Tabard_HonorHold" },
                },
            },
        },
    },
}
```

**Characteristics:**
- ✗ NOT filtered by class/spec (everyone sees same items)
- ✓ Has `faction` (is the key)
- ✓ Has standing (is the rewards key: 5/6/7/8)
- ✓ Has `icon` field
- ✓ Has `itemId` field
- Contains: Keys, Tabards, Mounts, Recipes - NOT spec BiS gear
- Used by: `Data:GetAllRewards(factionName)`

---

## Current Data Flow (BUGGY)

```
PopulateReputationItemIcons(segmentedBar, factionName, currentStandingId)
│
├── Step 1: Get BiS from ARMORY_SPEC_BIS_DATABASE
│   │
│   ├── guideKey = C:GetCurrentPlayerGuideKey()
│   │   └── Maps: SHAMAN + specTab → "elemental-shaman-dps"
│   │
│   ├── allSpecRepItems = C:GetSpecReputationBisItems(guideKey, 1)
│   │   └── Parses ALL items with sourceType="reputation"
│   │       └── Extracts faction/standing from source string
│   │
│   └── specBisItems = allSpecRepItems[factionName]
│       └── Filters to just this faction
│
├── Step 2: Add generic rewards from ReputationData
│   │
│   └── genericRewards = Data:GetAllRewards(factionName)
│       └── Returns keys, tabards, etc (NOT spec-specific)
│
└── Step 3: Merge and display
    └── De-duplicate by itemId
    └── Sort BiS first
```

**ISSUES:**
1. ❌ Does NOT use CLASS_SPEC_LOOT_HOTLIST (Journey's curated rep items)
2. ❌ Armory data lacks icons - relies on GetItemInfo cache
3. ❌ No validation that parsed faction matches actual faction
4. ❌ Generic rewards shown even when they're not useful for spec

---

## Corrected Data Flow (PROPOSED)

```
PopulateReputationItemIcons(segmentedBar, factionName, currentStandingId)
│
├── Step 1: Get BiS from CLASS_SPEC_LOOT_HOTLIST (PRIMARY SOURCE)
│   │
│   ├── classToken = UnitClass("player")
│   ├── specTab = GetPlayerSpec()
│   │
│   ├── classData = C.CLASS_SPEC_LOOT_HOTLIST[classToken]
│   ├── specData = classData[specTab]
│   │
│   └── FOR item IN specData.rep:
│       └── IF item.faction == factionName:
│           └── ADD to itemsByStanding[item.standing]
│               └── Has: itemId, icon, name, faction, standing
│
├── Step 2: Supplement with ARMORY_SPEC_BIS_DATABASE (SECONDARY)
│   │
│   ├── guideKey = C:GetCurrentPlayerGuideKey()
│   ├── allSpecRepItems = C:GetSpecReputationBisItems(guideKey, 1)
│   │
│   └── FOR item IN allSpecRepItems[factionName]:
│       └── IF NOT already in itemsByStanding (by itemId):
│           └── ADD to itemsByStanding[standingId]
│               └── Has: itemId, name, slot (icon from GetItemInfo)
│
├── Step 3: Add generic rewards ONLY if spec has none for that standing
│   │
│   └── FOR standing IN [5, 6, 7, 8]:
│       └── IF itemsByStanding[standing] is EMPTY:
│           └── ADD generic rewards (keys, tabards)
│
└── Step 4: Display
    └── Sort by: isBis DESC, name ASC
    └── Show up to MAX_ICONS_PER_STANDING (4)
```

---

## Key Formulas

### Formula 1: Item Source Priority
```
Priority = Journey (CLASS_SPEC_LOOT_HOTLIST) > Armory (ARMORY_SPEC_BIS_DATABASE) > Generic (ReputationData)
```

### Formula 2: Filter Criteria
```
Item is valid for display IF:
  1. item.faction == factionName (case-sensitive match)
  2. item.standing IN [5, 6, 7, 8] (Friendly through Exalted)
  3. (For Journey): classToken matches AND specTab matches
  4. (For Armory): guideKey matches current player's spec
  5. (For Generic): Only if no spec items at that standing
```

### Formula 3: Standing Position
```
standingId 5 (Friendly) → divider[1] (between Neutral and Friendly)
standingId 6 (Honored)  → divider[2] (between Friendly and Honored)
standingId 7 (Revered)  → divider[3] (between Honored and Revered)
standingId 8 (Exalted)  → divider[4] (between Revered and Exalted)
```

### Formula 4: Icon Resolution Priority
```
1. item.icon (from CLASS_SPEC_LOOT_HOTLIST - has pre-stored icons)
2. GetItemInfo(item.itemId) - from client cache
3. "INV_Misc_QuestionMark" (fallback - cache not warmed)
```

### Formula 5: Duplicate Detection
```
Two items are duplicates IF:
  item1.itemId == item2.itemId AND item1.standing == item2.standing

When duplicate found:
  KEEP the one from higher priority source (Journey > Armory > Generic)
```

---

## Implementation Checklist

### Changes Required

#### 1. Update PopulateReputationItemIcons() in Journal.lua

```lua
function Journal:PopulateReputationItemIcons(segmentedBar, factionName, currentStandingId)
    local Data = HopeAddon.ReputationData
    local C = HopeAddon.Constants

    segmentedBar:ClearItemIcons()

    local itemsByStanding = {}
    local seenItemIds = {}  -- Track seen items across all standings

    -- Helper: add item if not duplicate
    local function addItem(standingId, item, source)
        if not item.itemId or seenItemIds[item.itemId] then return false end

        itemsByStanding[standingId] = itemsByStanding[standingId] or {}
        table.insert(itemsByStanding[standingId], item)
        seenItemIds[item.itemId] = true
        return true
    end

    -- STEP 1: PRIMARY SOURCE - CLASS_SPEC_LOOT_HOTLIST (Journey data)
    local _, classToken = UnitClass("player")
    local _, specTab = HopeAddon:GetPlayerSpec()
    specTab = specTab or 1

    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    local specData = classData and classData[specTab]

    if specData and specData.rep then
        for _, item in ipairs(specData.rep) do
            if item.faction == factionName and item.standing then
                addItem(item.standing, {
                    itemId = item.itemId,
                    icon = item.icon,  -- Already has icon!
                    name = item.name,
                    isObtainable = currentStandingId >= item.standing,
                    isBis = true,
                    slot = item.slot,
                    source = "journey",
                })
            end
        end
    end

    -- STEP 2: SECONDARY SOURCE - ARMORY_SPEC_BIS_DATABASE
    local guideKey = C and C.GetCurrentPlayerGuideKey and C:GetCurrentPlayerGuideKey()
    if guideKey then
        local armoryItems = C:GetSpecReputationBisItems(guideKey, 1)
        local factionItems = armoryItems and armoryItems[factionName]

        if factionItems then
            for standingId, items in pairs(factionItems) do
                for _, item in ipairs(items) do
                    -- Resolve icon (armory items don't have pre-stored icons)
                    local icon = nil
                    if item.itemId and item.itemId > 0 then
                        GetItemInfo(item.itemId)
                        local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(item.itemId)
                        icon = itemIcon
                    end

                    addItem(standingId, {
                        itemId = item.itemId,
                        icon = icon or "INV_Misc_QuestionMark",
                        name = item.name,
                        isObtainable = currentStandingId >= standingId,
                        isBis = item.isBis or false,
                        slot = item.slot,
                        source = "armory",
                    })
                end
            end
        end
    end

    -- STEP 3: TERTIARY SOURCE - Generic rewards (only if no spec items at that standing)
    local genericRewards = Data:GetAllRewards(factionName)
    if genericRewards then
        for standingId, rewards in pairs(genericRewards) do
            -- Only add generic items if we have NO spec items at this standing
            if not itemsByStanding[standingId] or #itemsByStanding[standingId] == 0 then
                for _, reward in ipairs(rewards) do
                    addItem(standingId, {
                        itemId = reward.itemId or 0,
                        icon = reward.icon or "INV_Misc_QuestionMark",
                        name = reward.name,
                        isObtainable = currentStandingId >= standingId,
                        isBis = false,
                        source = "generic",
                    })
                end
            end
        end
    end

    -- STEP 4: Sort and display
    for standingId, items in pairs(itemsByStanding) do
        -- Sort: BiS first, then by name
        table.sort(items, function(a, b)
            if a.isBis and not b.isBis then return true end
            if not a.isBis and b.isBis then return false end
            return (a.name or "") < (b.name or "")
        end)

        if #items > 0 then
            segmentedBar:SetItemIcons(standingId, items)
        end
    end
end
```

---

## Validation Rules

### Rule 1: Faction Name Matching
```
Journey item.faction MUST match ReputationData faction key EXACTLY
Example: "The Consortium" (not "Consortium")
```

### Rule 2: Standing ID Range
```
Valid standing IDs for rewards: 5, 6, 7, 8
  5 = Friendly
  6 = Honored
  7 = Revered
  8 = Exalted

Standing 4 (Neutral) has no rewards to display
```

### Rule 3: Class/Spec Binding
```
Journey data: classToken + specTab
Armory data: guideKey (derived from classToken + specTab via GetCurrentPlayerGuideKey)

Both MUST resolve to same logical spec
```

---

## Test Cases

### Test 1: Enhancement Shaman at Lower City
**Expected items:**
- Exalted (8): Shapeshifter's Signet (itemId 30834) - BiS from Journey/Armory
- Honored (6): Auchenai Key (itemId 28395) - Generic only if no spec items

### Test 2: Elemental Shaman at The Violet Eye
**Expected items:**
- Exalted (8): Violet Signet of the Archmage (itemId 29287) - from Armory alts

### Test 3: Resto Shaman at Cenarion Expedition
**Expected items:**
- Exalted (8): Windcaller's Orb (itemId 29170) - BiS from Armory

### Test 4: Warrior at Honor Hold (no spec items)
**Expected items:**
- Honored (6): Flamewrought Key (itemId 28286) - Generic
- Revered (7): Nethercobra Leg Armor (itemId 29169) - Generic
- Exalted (8): Honor Hold Tabard (itemId 23999) - Generic

---

## Accuracy Verification (Completed)

### Faction Name Cross-Reference ✓
All faction names in CLASS_SPEC_LOOT_HOTLIST match TBC_FACTIONS keys exactly:

| CLASS_SPEC_LOOT_HOTLIST | TBC_FACTIONS Key | Match |
|-------------------------|------------------|-------|
| "Cenarion Expedition" | "Cenarion Expedition" | ✓ |
| "Lower City" | "Lower City" | ✓ |
| "The Sha'tar" | "The Sha'tar" | ✓ |
| "Keepers of Time" | "Keepers of Time" | ✓ |
| "Honor Hold" | "Honor Hold" | ✓ |
| "The Consortium" | "The Consortium" | ✓ |
| "The Scryers" | "The Scryers" | ✓ |

### Standing ID Verification ✓
Verified standing IDs in CLASS_SPEC_LOOT_HOTLIST use correct values:
- standing = 7 → Revered (e.g., Continuum Blade, Lower City Prayerbook)
- standing = 8 → Exalted (e.g., Shapeshifter's Signet, Gavel of Pure Light, Haramad's Bargain)

### Shaman Spec Data Verification ✓
**Elemental (Tab 1):**
- Continuum Blade: Keepers of Time @ Revered (7) - icon: INV_Sword_66 ✓
- Shapeshifter's Signet: Lower City @ Exalted (8) - icon: INV_Jewelry_Ring_51naxxramas ✓

**Enhancement (Tab 2):**
- Haramad's Bargain: The Consortium @ Exalted (8) - icon: INV_Jewelry_Necklace_30naxxramas ✓

**Restoration (Tab 3):**
- Gavel of Pure Light: The Sha'tar @ Exalted (8) - icon: INV_Mace_53 ✓
- Lower City Prayerbook: Lower City @ Revered (7) - icon: INV_Misc_Book_09 ✓

### Current Code Issue Confirmed ✓
Current `PopulateReputationItemIcons()` at Journal.lua:4439 uses:
1. `C:GetSpecReputationBisItems(guideKey, 1)` - pulls from ARMORY_SPEC_BIS_DATABASE (NO icons)
2. `Data:GetAllRewards(factionName)` - pulls generic rewards

**Missing:** CLASS_SPEC_LOOT_HOTLIST which HAS icons and is properly class/spec filtered.

---

## Implementation Payload 7

### File: Journal/Journal.lua
### Location: Replace function at line 4439-4544

**Replace the ENTIRE PopulateReputationItemIcons function with:**

```lua
--[[
    Populate item icons above segmented reputation bar segments
    Phase 3: Uses CLASS_SPEC_LOOT_HOTLIST as PRIMARY source (has pre-stored icons)
    Falls back to ARMORY_SPEC_BIS_DATABASE (secondary), then generic rewards (tertiary)
    Items properly filtered by class and spec
]]
function Journal:PopulateReputationItemIcons(segmentedBar, factionName, currentStandingId)
    local Data = HopeAddon.ReputationData
    local C = HopeAddon.Constants

    segmentedBar:ClearItemIcons()

    local itemsByStanding = {}
    local seenItemIds = {}  -- Track seen items across all standings for dedup

    -- Helper: add item if not a duplicate (by itemId)
    local function addItem(standingId, item)
        if not item.itemId or seenItemIds[item.itemId] then return false end

        itemsByStanding[standingId] = itemsByStanding[standingId] or {}
        table.insert(itemsByStanding[standingId], item)
        seenItemIds[item.itemId] = true
        return true
    end

    -- STEP 1: PRIMARY SOURCE - CLASS_SPEC_LOOT_HOTLIST (Journey data)
    -- Has: icon, itemId, name, faction, standing - all pre-stored
    local _, classToken = UnitClass("player")
    local _, specTab = HopeAddon:GetPlayerSpec()
    specTab = specTab or 1

    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    local specData = classData and classData[specTab]

    if specData and specData.rep then
        for _, item in ipairs(specData.rep) do
            -- STRICT faction match - case-sensitive
            if item.faction == factionName and item.standing and item.standing >= 5 and item.standing <= 8 then
                addItem(item.standing, {
                    itemId = item.itemId,
                    icon = item.icon,  -- Pre-stored icon from Journey data
                    name = item.name,
                    isObtainable = currentStandingId >= item.standing,
                    isBis = true,
                    slot = item.slot,
                    source = "journey",
                })
            end
        end
    end

    -- STEP 2: SECONDARY SOURCE - ARMORY_SPEC_BIS_DATABASE (supplementary)
    -- Only add items NOT already added from Journey
    local guideKey = C and C.GetCurrentPlayerGuideKey and C:GetCurrentPlayerGuideKey()
    if guideKey then
        local armoryItems = C:GetSpecReputationBisItems(guideKey, 1)
        local factionItems = armoryItems and armoryItems[factionName]

        if factionItems then
            for standingId, items in pairs(factionItems) do
                for _, item in ipairs(items) do
                    -- Only add if not already present (Journey takes priority)
                    if not seenItemIds[item.itemId] then
                        -- Resolve icon (armory items don't have pre-stored icons)
                        local icon = nil
                        if item.itemId and item.itemId > 0 then
                            GetItemInfo(item.itemId)  -- Queue for cache warmup
                            local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(item.itemId)
                            icon = itemIcon
                        end

                        addItem(standingId, {
                            itemId = item.itemId,
                            icon = icon or "INV_Misc_QuestionMark",
                            name = item.name,
                            isObtainable = currentStandingId >= standingId,
                            isBis = item.isBis or false,
                            slot = item.slot,
                            source = "armory",
                        })
                    end
                end
            end
        end
    end

    -- STEP 3: TERTIARY SOURCE - Generic rewards (keys, tabards, etc.)
    -- ONLY add if we have NO spec items at that standing level
    local genericRewards = Data:GetAllRewards(factionName)
    if genericRewards then
        for standingId, rewards in pairs(genericRewards) do
            -- Only add generic items if we have NO spec items at this standing
            if not itemsByStanding[standingId] or #itemsByStanding[standingId] == 0 then
                for _, reward in ipairs(rewards) do
                    addItem(standingId, {
                        itemId = reward.itemId or 0,
                        icon = reward.icon or "INV_Misc_QuestionMark",
                        name = reward.name,
                        isObtainable = currentStandingId >= standingId,
                        isBis = false,
                        source = "generic",
                    })
                end
            end
        end
    end

    -- STEP 4: Sort and display
    for standingId, items in pairs(itemsByStanding) do
        -- Sort: BiS items first, then alphabetically by name
        table.sort(items, function(a, b)
            if a.isBis and not b.isBis then return true end
            if not a.isBis and b.isBis then return false end
            return (a.name or "") < (b.name or "")
        end)

        if #items > 0 then
            segmentedBar:SetItemIcons(standingId, items)
        end
    end
end
```

---

## Summary

| Issue | Root Cause | Fix |
|-------|------------|-----|
| Wrong icons | Using Armory (no icons) instead of Journey (has icons) | Use Journey as PRIMARY source |
| Misaligned items | No faction validation | Strict faction == factionName check |
| Generic items everywhere | No conditional logic | Only show generic if NO spec items |
| Duplicate items | No dedup across sources | Track seenItemIds globally |
| Class/spec mismatch | Armory guideKey lookup | Use classToken + specTab directly for Journey |

---

## Post-Implementation Verification

After applying Payload 7, verify:

1. **Elemental Shaman at Lower City:**
   - Should see: Shapeshifter's Signet icon at Exalted divider
   - Icon: INV_Jewelry_Ring_51naxxramas (gold ring)

2. **Elemental Shaman at Keepers of Time:**
   - Should see: Continuum Blade icon at Revered divider
   - Icon: INV_Sword_66 (blue sword)

3. **Enhancement Shaman at The Consortium:**
   - Should see: Haramad's Bargain icon at Exalted divider
   - Icon: INV_Jewelry_Necklace_30naxxramas (gold necklace)

4. **Resto Shaman at The Sha'tar:**
   - Should see: Gavel of Pure Light icon at Exalted divider
   - Icon: INV_Mace_53 (golden mace)

5. **Resto Shaman at Lower City:**
   - Should see: Lower City Prayerbook icon at Revered divider
   - Icon: INV_Misc_Book_09 (book)

6. **Any class at Honor Hold (no spec items):**
   - Should see generic rewards: Key at Honored, Leg Armor at Revered, Tabard at Exalted
