# Armory Gear Popup Tooltip Enhancement Plan

**Date:** 2026-01-25
**Status:** PLANNING
**Scope:** Enhance hover tooltips for items in the Armory gear popup (BiS/Alternatives list)

---

## Current State Analysis

### Existing Tooltip Functions

| Function | Location | Purpose |
|----------|----------|---------|
| `BuildArmoryGearTooltip()` | Journal.lua:10727-10813 | Main tooltip builder, shows WoW tooltip + enhanced sections |
| `BuildBasicHoverData()` | Journal.lua:10818-10858 | Fallback generator from item fields |
| `CreateArmoryGearPopupItemRow()` | Journal.lua:11104-11335 | Row creation, OnEnter calls BuildArmoryGearTooltip at line 11314 |

### Tooltip is Already Called

The hover tooltip IS being triggered. In `CreateArmoryGearPopupItemRow()`:

```lua
-- Line 11299-11315
row:SetScript("OnEnter", function(self)
    -- Brighten on hover
    self:SetBackdropColor(...)

    -- Sound effect
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayHover()
    end

    -- Show enhanced tooltip with drop info, tips, etc.
    journalSelf:BuildArmoryGearTooltip(self.itemData, self)  -- <-- LINE 11314
end)
```

---

## Field Inventory

### Fields Available in ARMORY_GEAR_DATABASE

Every item in the database has these fields:

| Field | Type | Always Present | Example |
|-------|------|----------------|---------|
| `itemId` | number | ✅ Yes | `29011` |
| `name` | string | ✅ Yes | `"Warbringer Greathelm"` |
| `icon` | string | ✅ Yes | `"INV_Helmet_70"` |
| `quality` | string | ✅ Yes | `"epic"`, `"rare"`, `"uncommon"` |
| `iLvl` | number | ✅ Yes | `120` |
| `stats` | string | ✅ Yes | `"+43 Str, +45 Sta, +32 Def Rating"` |
| `source` | string | ✅ Yes | `"Prince Malchezaar"`, `"G'eras"`, `"Blacksmithing"` |
| `sourceType` | string | ✅ Yes | See sourceType table below |
| `sourceDetail` | string | ❌ Sometimes | `"Karazhan"`, `"Heroic Botanica"` |
| `badgeCost` | number | ❌ Only badge | `50`, `25`, `41` |
| `repFaction` | string | ❌ Only rep | `"The Sha'tar"`, `"Lower City"` |
| `repStanding` | string | ❌ Only rep | `"Exalted"`, `"Revered"` |

### sourceType Values

| sourceType | Example source | Example sourceDetail | Optional Fields |
|------------|----------------|---------------------|-----------------|
| `raid` | `"Prince Malchezaar"` | `"Karazhan"` | - |
| `heroic` | `"Warp Splinter"` | `"Heroic Botanica"` | - |
| `dungeon` | `"Aeonus"` | `"Black Morass"` | - |
| `badge` | `"G'eras"` | - | `badgeCost` |
| `crafted` | `"Blacksmithing"` | - | - |
| `rep` | `"Sha'tar Exalted"` | - | `repFaction`, `repStanding` |
| `world` | `"Doom Lord Kazzak"` | - | - |
| `quest` | `"Quest: Deathblow..."` | - | - |
| `pvp` | (defined in SOURCE_TYPES) | - | - |

### Supporting Constants Already Defined

```lua
-- Constants.lua:6584-6594
C.ARMORY_SOURCE_TYPES = {
    raid = { color = "EPIC_PURPLE", icon = "Achievement_Dungeon_Karazhan", label = "Raid Drop" },
    heroic = { color = "RARE_BLUE", icon = "INV_Misc_Key_10", label = "Heroic Dungeon" },
    badge = { color = "GOLD_BRIGHT", icon = "Spell_Holy_ChampionsBond", label = "Badge of Justice" },
    rep = { color = "FEL_GREEN", icon = "INV_Misc_Token_Argentdawn", label = "Reputation" },
    crafted = { color = "BRONZE", icon = "Trade_BlackSmithing", label = "Crafted" },
    pvp = { color = "HELLFIRE_RED", icon = "INV_Jewelry_TrinketPVP_01", label = "PvP" },
    world = { color = "LEGENDARY_ORANGE", icon = "INV_Misc_Head_Dragon_01", label = "World Boss" },
    quest = { color = "UNCOMMON_GREEN", icon = "INV_Misc_Book_07", label = "Quest Reward" },
    dungeon = { color = "RARE_BLUE", icon = "INV_Misc_Key_03", label = "Dungeon" },
}

-- Constants.lua:6622-6629
C.ARMORY_ROLES = {
    tank = { name = "Tank", icon = "...", stats = "Stamina, Defense, Dodge, Parry" },
    healer = { name = "Healer", icon = "...", stats = "+Healing, MP5, Intellect" },
    melee_dps = { name = "Melee DPS", icon = "...", stats = "AP, Hit, Crit, Expertise" },
    ranged_dps = { name = "Ranged DPS", icon = "...", stats = "Agility, AP, Hit, Crit" },
    caster_dps = { name = "Caster DPS", icon = "...", stats = "Spell Power, Hit, Crit" },
}
```

---

## Current BuildBasicHoverData Analysis

### What It Does Now (Journal.lua:10818-10858)

```lua
function Journal:BuildBasicHoverData(itemData)
    local hoverData = {}

    if itemData.source or itemData.sourceDetail or itemData.sourceType then
        hoverData.dropInfo = {}

        if itemData.sourceType == "raid" then
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
        elseif itemData.sourceType == "badge" then
            hoverData.dropInfo.instance = "Badge of Justice Vendor"
            if itemData.badgeCost then
                hoverData.dropInfo.difficulty = itemData.badgeCost .. " Badges"
            end
        elseif itemData.sourceType == "crafted" then
            hoverData.dropInfo.instance = itemData.source or "Crafted"
            hoverData.dropInfo.difficulty = "Requires profession"
        elseif itemData.sourceType == "reputation" or itemData.sourceType == "rep" then
            hoverData.dropInfo.instance = itemData.source or "Reputation Vendor"
            if itemData.standing then
                hoverData.prerequisites = { "Requires " .. itemData.standing .. " with " .. (itemData.faction or itemData.source) }
            end
        elseif itemData.sourceType == "heroic" then
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
            hoverData.dropInfo.difficulty = "Heroic"
        elseif itemData.sourceType == "quest" then
            hoverData.dropInfo.instance = "Quest Reward"
            hoverData.dropInfo.difficulty = itemData.sourceDetail
        else
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
        end
    end

    if not next(hoverData) then
        return nil
    end

    return hoverData
end
```

### Issues Found

| Issue | Field Used | Problem |
|-------|------------|---------|
| Rep field mismatch | `itemData.standing` | Database uses `repStanding` |
| Rep field mismatch | `itemData.faction` | Database uses `repFaction` |
| No stat priority | - | `stats` field not parsed |
| No tips generated | - | No generic tips by sourceType |
| World boss not handled | `sourceType == "world"` | Falls to else, loses context |
| Dungeon not handled | `sourceType == "dungeon"` | Falls to else, loses context |

---

## Detailed Fix Plan

### PAYLOAD 1: Fix Field Name Mismatches (5 min)

**File:** `Journal/Journal.lua` lines 10835-10839

**Current (BROKEN):**
```lua
elseif itemData.sourceType == "reputation" or itemData.sourceType == "rep" then
    hoverData.dropInfo.instance = itemData.source or "Reputation Vendor"
    if itemData.standing then  -- WRONG: field is repStanding
        hoverData.prerequisites = { "Requires " .. itemData.standing .. " with " .. (itemData.faction or itemData.source) }
    end
```

**Fixed:**
```lua
elseif itemData.sourceType == "reputation" or itemData.sourceType == "rep" then
    hoverData.dropInfo.instance = itemData.source or "Reputation Vendor"
    if itemData.repStanding then
        local faction = itemData.repFaction or itemData.source or "Unknown Faction"
        hoverData.prerequisites = { "Requires " .. itemData.repStanding .. " with " .. faction }
    end
```

---

### PAYLOAD 2: Add Missing sourceType Handlers (10 min)

**File:** `Journal/Journal.lua` inside `BuildBasicHoverData`

**Add before the final `else`:**

```lua
elseif itemData.sourceType == "world" then
    hoverData.dropInfo.bossName = itemData.source
    hoverData.dropInfo.instance = "World Boss"
    hoverData.dropInfo.difficulty = "Outdoor Raid Boss"
    hoverData.tips = { "Spawns in the open world on a timer", "Coordinate with other raid groups" }

elseif itemData.sourceType == "dungeon" then
    hoverData.dropInfo.bossName = itemData.source
    hoverData.dropInfo.instance = itemData.sourceDetail
    hoverData.dropInfo.difficulty = "Normal"
```

---

### PAYLOAD 3: Add Stat Priority Parser (15 min)

**File:** `Journal/Journal.lua` - Add new function before `BuildBasicHoverData`

```lua
--[[
    Parse stats string into ordered priority list
    Example: "+43 Str, +45 Sta, +32 Def Rating" → {"Strength", "Stamina", "Defense Rating"}
]]
function Journal:ParseStatPriority(statsString, role)
    if not statsString then return nil end

    local priority = {}
    local statPatterns = {
        { pattern = "Sta",      name = "Stamina" },
        { pattern = "Str",      name = "Strength" },
        { pattern = "Agi",      name = "Agility" },
        { pattern = "Int",      name = "Intellect" },
        { pattern = "Spi",      name = "Spirit" },
        { pattern = "Def",      name = "Defense Rating" },
        { pattern = "Dodge",    name = "Dodge Rating" },
        { pattern = "Parry",    name = "Parry Rating" },
        { pattern = "Block",    name = "Block Rating" },
        { pattern = "Hit",      name = "Hit Rating" },
        { pattern = "Crit",     name = "Critical Strike" },
        { pattern = "Haste",    name = "Haste Rating" },
        { pattern = "Healing",  name = "+Healing" },
        { pattern = "Spell",    name = "Spell Power" },
        { pattern = "MP5",      name = "MP5" },
        { pattern = "mp5",      name = "MP5" },
        { pattern = "AP",       name = "Attack Power" },
        { pattern = "Armor",    name = "Armor" },
    }

    for _, stat in ipairs(statPatterns) do
        if statsString:find(stat.pattern) then
            table.insert(priority, stat.name)
        end
    end

    return #priority > 0 and priority or nil
end
```

**Then in `BuildBasicHoverData`, add after dropInfo block:**

```lua
-- Parse stat priority from stats string
if itemData.stats then
    hoverData.statPriority = self:ParseStatPriority(itemData.stats)
end
```

---

### PAYLOAD 4: Add Generic Tips by Source Type (15 min)

**File:** `Journal/Journal.lua` - Add new function

```lua
--[[
    Generate generic tips based on source type
]]
function Journal:GetGenericTipsForSourceType(sourceType, itemData)
    local tips = {}

    if sourceType == "raid" then
        table.insert(tips, "Coordinate with your raid for loot priority")
        if itemData.sourceDetail == "Karazhan" then
            table.insert(tips, "10-man raid, runs weekly")
        elseif itemData.sourceDetail == "Gruul's Lair" or itemData.sourceDetail == "Magtheridon's Lair" then
            table.insert(tips, "25-man raid, shorter than Karazhan")
        end

    elseif sourceType == "badge" then
        table.insert(tips, "Farm Heroics and Karazhan for Badges")
        if itemData.badgeCost and itemData.badgeCost >= 50 then
            table.insert(tips, "High badge cost - prioritize carefully")
        end

    elseif sourceType == "crafted" then
        table.insert(tips, "Check AH for mats or find a guild crafter")
        if itemData.source == "Blacksmithing" then
            table.insert(tips, "May require Primal Nether from Heroics")
        elseif itemData.source:find("Tailoring") then
            table.insert(tips, "Tailoring specialization may be required")
        elseif itemData.source:find("Leatherworking") then
            table.insert(tips, "LW specialization may be required")
        end

    elseif sourceType == "rep" then
        table.insert(tips, "Complete daily quests to build reputation")
        if itemData.repStanding == "Exalted" then
            table.insert(tips, "Long grind - plan for 2-3 weeks of dailies")
        elseif itemData.repStanding == "Revered" then
            table.insert(tips, "Revered is faster - focus dungeon runs")
        end

    elseif sourceType == "heroic" then
        table.insert(tips, "Requires Heroic key (Revered with faction)")
        table.insert(tips, "Daily lockout per heroic dungeon")

    elseif sourceType == "world" then
        table.insert(tips, "Spawns on 2-3 day timer in outdoor zone")
        table.insert(tips, "Coordinate with other raid groups")

    elseif sourceType == "quest" then
        table.insert(tips, "One-time reward - choose carefully if options exist")

    elseif sourceType == "dungeon" then
        table.insert(tips, "Normal mode - farmable without lockout")
    end

    return #tips > 0 and tips or nil
end
```

**Then in `BuildBasicHoverData`, add after statPriority:**

```lua
-- Generate tips based on source type
if not hoverData.tips then
    hoverData.tips = self:GetGenericTipsForSourceType(itemData.sourceType, itemData)
end
```

---

### PAYLOAD 5: Add Badge Cost to Drop Info (5 min)

**File:** `Journal/Journal.lua` in `BuildBasicHoverData` badge handler

**Current:**
```lua
elseif itemData.sourceType == "badge" then
    hoverData.dropInfo.instance = "Badge of Justice Vendor"
    if itemData.badgeCost then
        hoverData.dropInfo.difficulty = itemData.badgeCost .. " Badges"
    end
```

**Enhanced:**
```lua
elseif itemData.sourceType == "badge" then
    hoverData.dropInfo.instance = "Badge of Justice Vendor"
    hoverData.dropInfo.bossName = "G'eras (Shattrath)"
    if itemData.badgeCost then
        hoverData.dropInfo.dropRate = itemData.badgeCost .. " Badges of Justice"
        -- Add helpful context
        local badgesPerWeek = 22 + 13  -- Kara (22) + Heroic daily (13)
        local weeksNeeded = math.ceil(itemData.badgeCost / badgesPerWeek)
        if weeksNeeded > 1 then
            hoverData.dropInfo.tokenInfo = "~" .. weeksNeeded .. " weeks to farm"
        end
    end
```

---

## Implementation Order

| # | Payload | Time | Priority | Description |
|---|---------|------|----------|-------------|
| 1 | Field Fixes | 5 min | HIGH | Fix `repStanding`/`repFaction` field names |
| 2 | sourceType Handlers | 10 min | HIGH | Add world/dungeon handlers |
| 3 | Stat Priority | 15 min | MEDIUM | Parse stats string → priority list |
| 4 | Generic Tips | 15 min | MEDIUM | Tips by sourceType |
| 5 | Badge Enhancement | 5 min | LOW | Weeks-to-farm calculation |

**Total Estimated Time:** 50 minutes

---

## Testing Matrix

After implementation, verify each sourceType displays correctly:

| sourceType | Test Item | Expected Sections |
|------------|-----------|-------------------|
| `raid` | Warbringer Greathelm | Boss, Instance, Stats, Tips |
| `heroic` | Barbed Choker of Discipline | Boss, Instance, "Heroic", Key tip |
| `badge` | Faceguard of Determination | Vendor, Badge cost, Weeks to farm |
| `crafted` | Felsteel Helm | Profession, Mats tip |
| `rep` | Sha'tari Wrought Armguards | Faction, Standing requirement |
| `world` | Topaz-Studded Battlegrips | World Boss, Timer tip |
| `dungeon` | Latro's Shifting Sword | Boss, Instance, "Normal" |
| `quest` | Elementium Band of the Sentry | Quest Reward, One-time tip |

---

## Files Modified

| File | Changes |
|------|---------|
| `Journal/Journal.lua` | Fix field names, add ParseStatPriority(), add GetGenericTipsForSourceType(), enhance BuildBasicHoverData() |

No changes needed to `Constants.lua` - all data fields already present.
