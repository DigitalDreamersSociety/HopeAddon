# Reputation Tab Enhanced Tooltips - Executable Payloads

## Overview
Add Attunements-style rich hover tooltips to Reputation tab's "Upgrades For Your Spec" section.

**Total Work:** 2 payloads, ~220 lines, ~1.25 hours

---

## PAYLOAD 1: Enhanced Tooltip Builder
**File:** `UI/Components.lua`
**Action:** Add helper function + modify OnEnter handler

### Step 1.1: Add Helper Function
**Location:** Insert BEFORE line 2798 (before the `--[[` comment block for UPGRADE ITEM CARD)

```lua
--[[
    BuildRepItemTooltip - Enhanced tooltip with Attunements-style sections
    Shows rep sources, stat priority, tips, and alternatives when hoverData exists
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

    -- Item link (shows full WoW item tooltip) or manual name
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
    local standingName = C.STANDING_NAMES and C.STANDING_NAMES[reqStanding] or "Unknown"
    if isObtainable then
        GameTooltip:AddLine("Available for purchase!", 0, 1, 0)
    else
        GameTooltip:AddLine("Requires: " .. (itemData.faction or "Unknown") .. " " .. standingName, 1, 0.5, 0)
        GameTooltip:AddLine("Current: " .. (factionProgress.standingName or "Neutral"), 0.7, 0.7, 0.7)
    end

    -- Enhanced sections (only if hoverData exists)
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

        -- Tips (Orange - matches Attunements pattern)
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

### Step 1.2: Replace OnEnter Handler
**Location:** Lines 2918-2936 in `CreateUpgradeItemCard` function

**DELETE these lines (2918-2936):**
```lua
    card:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if itemData.itemId then
            GameTooltip:SetHyperlink("item:" .. itemData.itemId)
        else
            GameTooltip:AddLine(itemData.name or "Unknown", qualityColor.r, qualityColor.g, qualityColor.b)
            if itemData.stats then
                GameTooltip:AddLine(itemData.stats, 1, 1, 1)
            end
        end
        GameTooltip:AddLine(" ")
        if isObtainable then
            GameTooltip:AddLine("Available for purchase!", 0, 1, 0)
        else
            GameTooltip:AddLine("Requires: " .. (standingNames[reqStanding] or "Unknown"), 1, 0.5, 0)
        end
        GameTooltip:Show()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
```

**REPLACE WITH:**
```lua
    card:SetScript("OnEnter", function(self)
        BuildRepItemTooltip(self, itemData, factionProgress, isObtainable, qualityColor, reqStanding)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
```

### Payload 1 Verification
After completing Payload 1:
- [ ] `BuildRepItemTooltip` function exists before line 2798
- [ ] OnEnter handler calls `BuildRepItemTooltip` with 6 parameters
- [ ] OnLeave handler unchanged (line 2937-2939)
- [ ] Items WITHOUT hoverData still show basic tooltip (fallback works)

---

## PAYLOAD 2: WARRIOR Class hoverData
**File:** `Core/Constants.lua`
**Action:** Add `hoverData` field to each WARRIOR rep item

### Step 2.1: Arms Warrior (Tab 1) - Line 4034
**REPLACE line 4034:**
```lua
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8 },
```

**WITH:**
```lua
                { itemId = 29119, name = "Haramad's Bargain", icon = "INV_Jewelry_Necklace_30naxxramas", quality = "epic", slot = "Neck", stats = "+20 Agi, +24 Sta, +22 Hit", source = "The Consortium @ Exalted", sourceType = "rep", faction = "The Consortium", standing = 8,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)",
                            "Turn in Oshu'gun Crystal Powder Samples (250 rep/10)",
                            "Consortium quests in Nagrand and Netherstorm",
                        },
                        statPriority = {
                            "Best pre-raid DPS neck for physical damage",
                            "+22 Hit Rating helps reach melee hit cap (9%)",
                            "Agility provides crit and dodge",
                        },
                        tips = {
                            "Farm Oshu'gun Powder from Nagrand ogres/ethereals",
                            "Mana-Tombs Heroic is fastest once keyed",
                            "Buy from Karaaz in Stormspire (Netherstorm)",
                        },
                        alternatives = {
                            "Natasha's Ember Necklace (Nagrand quest)",
                            "Necklace of the Deep (Fishing)",
                            "Worgen Claw Necklace (H Underbog)",
                        },
                    },
                },
```

### Step 2.2: Arms Warrior (Tab 1) - Line 4035
**REPLACE line 4035:**
```lua
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7 },
```

**WITH:**
```lua
                { itemId = 29152, name = "Marksman's Bow", icon = "INV_Weapon_Bow_18", quality = "epic", slot = "Ranged", stats = "+14 Agi, +8 Sta, +16 Hit", source = "Honor Hold @ Revered", sourceType = "rep", faction = "Honor Hold", standing = 7,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k rep total)",
                        },
                        statPriority = {
                            "Best ranged slot for melee - stat stick",
                            "+16 Hit is huge for reaching hit cap",
                            "Better than Nerubian Slavemaker until Kara",
                        },
                        tips = {
                            "Should reach Revered just from questing",
                            "If short, run Shattered Halls (fastest)",
                            "Buy from Logistics Officer Ulrike in Honor Hold",
                        },
                        alternatives = {
                            "Nerubian Slavemaker (Naxx - if you have it)",
                            "Emberhawk Crossbow (H OHB)",
                            "Melmorta's Twilight Longbow (H BM)",
                        },
                    },
                },
```

### Step 2.3: Arms Warrior (Tab 1) - Line 4036
**REPLACE line 4036:**
```lua
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8 },
```

**WITH:**
```lua
                { itemId = 29187, name = "Bloodlust Brooch", icon = "INV_Jewelry_Trinket_13", quality = "epic", slot = "Trinket", stats = "+72 AP, Use: +278 AP", source = "Thrallmar @ Exalted", sourceType = "rep", faction = "Thrallmar", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill, best rep/hour)",
                            "Hellfire Peninsula quests (Horde only)",
                        },
                        statPriority = {
                            "BiS trinket for physical DPS until T5",
                            "+72 AP passive + 278 AP on-use burst",
                            "20 sec duration, 2 min cooldown",
                        },
                        tips = {
                            "Shattered Halls spam is fastest to Exalted",
                            "Grind this early - used through T5",
                            "Buy from Quartermaster Urgronn in Thrallmar",
                        },
                        alternatives = {
                            "Abacus of Violent Odds (H Mech)",
                            "Hourglass of the Unraveller (H BM)",
                            "Core of Ar'kelos (Netherstorm quest)",
                        },
                    },
                },
```

### Step 2.4: Fury Warrior (Tab 2) - Lines 4052-4054
**Same items as Arms - copy the exact same hoverData blocks to lines 4052, 4053, 4054**

### Step 2.5: Protection Warrior (Tab 3) - Line 4070
**REPLACE line 4070:**
```lua
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8 },
```

**WITH:**
```lua
                { itemId = 29167, name = "Bladespire Warbands", icon = "INV_Bracer_16", quality = "epic", slot = "Wrist", stats = "+33 Sta, +21 Def Rating", source = "Keepers of Time @ Exalted", sourceType = "rep", faction = "Keepers of Time", standing = 8,
                    hoverData = {
                        repSources = {
                            "Old Hillsbrad Foothills (8 rep/kill)",
                            "Black Morass (8 Normal, 25 Heroic rep/kill)",
                            "Caverns of Time attunement questline",
                        },
                        statPriority = {
                            "Best pre-raid tank bracers",
                            "+21 Defense helps reach 490 cap",
                            "+33 Stamina for effective health",
                        },
                        tips = {
                            "Black Morass Heroic is fastest at 70",
                            "Complete attunement first (required for Heroic)",
                            "Buy from Alurmi in Caverns of Time",
                        },
                        alternatives = {
                            "Bracers of Dignity (H Mechanar)",
                            "Bracers of the Green Fortress (BS BoE)",
                            "Vambraces of Courage (H SH)",
                        },
                    },
                },
```

### Step 2.6: Protection Warrior (Tab 3) - Line 4071
**REPLACE line 4071:**
```lua
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8 },
```

**WITH:**
```lua
                { itemId = 29151, name = "Veteran's Plate Belt", icon = "INV_Belt_03", quality = "epic", slot = "Waist", stats = "+40 Sta, +23 Def, +22 Block", source = "Honor Hold @ Exalted", sourceType = "rep", faction = "Honor Hold", standing = 8,
                    hoverData = {
                        repSources = {
                            "Hellfire Ramparts/Blood Furnace (10 rep/kill)",
                            "Shattered Halls (15-25 rep/kill)",
                            "Hellfire Peninsula quests (~10k total)",
                        },
                        statPriority = {
                            "Best pre-raid tank belt",
                            "+23 Defense + 22 Block Rating",
                            "+40 Stamina for massive EH",
                        },
                        tips = {
                            "Long grind - start early while leveling",
                            "Shattered Halls is most efficient",
                            "Buy from Logistics Officer Ulrike",
                        },
                        alternatives = {
                            "Sha'tari Vindicator's Waistguard (H Mech)",
                            "Girdle of the Immovable (H SL)",
                            "Belt of the Guardian (BS craft)",
                        },
                    },
                },
```

### Step 2.7: Protection Warrior (Tab 3) - Line 4072
**REPLACE line 4072:**
```lua
                { itemId = 29177, name = "Consortium Plated Legguards", icon = "INV_Pants_Plate_05", quality = "epic", slot = "Legs", stats = "+48 Sta, +27 Def", source = "The Consortium @ Revered", sourceType = "rep", faction = "The Consortium", standing = 7 },
```

**WITH:**
```lua
                { itemId = 29177, name = "Consortium Plated Legguards", icon = "INV_Pants_Plate_05", quality = "epic", slot = "Legs", stats = "+48 Sta, +27 Def", source = "The Consortium @ Revered", sourceType = "rep", faction = "The Consortium", standing = 7,
                    hoverData = {
                        repSources = {
                            "Mana-Tombs (Normal: 5-10, Heroic: 15-25 rep/kill)",
                            "Oshu'gun Crystal Powder Samples (250 rep/10)",
                            "Consortium quests in Nagrand/Netherstorm",
                        },
                        statPriority = {
                            "Solid pre-raid tank legs at Revered",
                            "+27 Defense toward 490 cap",
                            "+48 Stamina is excellent",
                        },
                        tips = {
                            "Only need Revered (not Exalted)",
                            "Powder farming in Nagrand is relaxing",
                            "Buy from Karaaz in Stormspire",
                        },
                        alternatives = {
                            "Timewarden's Leggings (H BM)",
                            "Legguards of the Bold (H SH)",
                            "Felsteel Leggings (BS craft)",
                        },
                    },
                },
```

### Payload 2 Verification
After completing Payload 2:
- [ ] Arms [1] rep items (lines 4034-4036) have hoverData
- [ ] Fury [2] rep items (lines 4052-4054) have hoverData
- [ ] Prot [3] rep items (lines 4070-4072) have hoverData
- [ ] No syntax errors (commas, braces balanced)
- [ ] Hover over WARRIOR items shows enhanced tooltip

---

## Testing Procedure

1. **Login as any class** - Verify no Lua errors on load
2. **Open Journal → Reputation tab** - Should load without errors
3. **Check items WITHOUT hoverData** - Other classes should show basic tooltip
4. **Check WARRIOR items WITH hoverData** - Should show 4 colored sections:
   - "How to Earn Rep:" (Fel Green)
   - "Why This Item:" (Arcane Purple)
   - "Tips:" (Orange)
   - "Alternatives:" (Sky Blue)
5. **Verify word wrap** - Long lines should wrap properly
6. **Verify hover sound** - Should still play on hover

---

## Rollback Instructions

If issues occur:

**Payload 1 Rollback:**
1. Delete `BuildRepItemTooltip` function (lines before 2798)
2. Restore original OnEnter handler from git

**Payload 2 Rollback:**
1. Remove `hoverData = {...},` from each WARRIOR item
2. Items revert to single-line format

---

## Future Work (Payload 3+)

Add hoverData to remaining 8 classes in priority order:
1. PALADIN (Prot, Holy)
2. DRUID (Feral, Resto)
3. PRIEST (Disc/Holy)
4. SHAMAN, MAGE, WARLOCK
5. HUNTER, ROGUE

Each class: ~180 lines of hoverData for 9 rep items.
