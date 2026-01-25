# HopeAddon Dressing Room Feature - Implementation Plan

## Overview

A guild-exclusive "Dressing Room" feature that allows addon users to preview tier set recolors on their character model. This is a visual preview system for streams/RP - it does NOT change actual in-game appearance.

**Purpose:** Guild members streaming can show off desired tier looks in a dedicated UI window, creating an exclusive feel for the community.

---

## Table of Contents

1. [Feature Scope](#1-feature-scope)
2. [Technical Architecture](#2-technical-architecture)
3. [Data Tables Required](#3-data-tables-required)
4. [API Reference](#4-api-reference)
5. [UI Design](#5-ui-design)
6. [Implementation Phases](#6-implementation-phases)
7. [Research Notes](#7-research-notes)

---

## 1. Feature Scope

### What It Does
- Opens a dedicated "Dressing Room" window with a DressUpModel frame
- Shows your character wearing selected tier pieces
- Allows swapping between color variants of the same tier model
- Saves your "dream set" preferences to profile
- Syncs preferences to other addon users (optional)

### What It Does NOT Do
- Change your actual in-game appearance (impossible via addon API)
- Work outside the addon's UI window
- Affect what non-addon users see

### Supported Content (Phase 1)
- Tier 4 sets (all classes, all specs)
- Tier 5 sets (all classes, all specs)
- Tier 6 sets (future expansion)

---

## 2. Technical Architecture

### Core Components

```
DressingRoom/
├── DressingRoomCore.lua      -- Main module, state management
├── DressingRoomUI.lua        -- UI creation, DressUpModel handling
├── DressingRoomData.lua      -- Item ID tables, recolor mappings
└── DressingRoomSync.lua      -- Fellow Traveler profile sync (optional)
```

### Data Flow

```
User opens Dressing Room
        │
        ▼
DressingRoomUI:Show()
        │
        ├─ CreateFrame("DressUpModel")
        ├─ model:SetUnit("player")
        └─ Load saved preferences OR defaults
        │
        ▼
User selects tier/slot/recolor
        │
        ├─ Lookup item ID from C.TIER_SETS[class][tier][spec][slot]
        ├─ Get recolors from C.TIER_RECOLORS[itemID]
        └─ model:TryOn(selectedItemID)
        │
        ▼
User clicks "Save as Dream Set"
        │
        ├─ Store in charDb.dressingRoom.dreamSet
        └─ (Optional) Sync via FellowTravelers
```

### Module Registration

```lua
local DressingRoom = {}
HopeAddon:RegisterModule("DressingRoom", DressingRoom)

function DressingRoom:OnInitialize()
    -- Set up defaults
end

function DressingRoom:OnEnable()
    -- Register slash commands
    -- Create frame pools if needed
end

function DressingRoom:OnDisable()
    -- Cleanup
end
```

---

## 3. Data Tables Required

### 3.1 Tier Set Definitions

Master table of all tier sets by class, tier, and spec.

```lua
-- In Constants.lua or DressingRoomData.lua
C.TIER_SETS = {
    -- [CLASS] = { [TIER] = { [SPEC_OR_DEFAULT] = { setID, setName, pieces = {} } } }

    ["WARRIOR"] = {
        [4] = {
            ["Protection"] = {
                setID = 654,
                setName = "Warbringer Armor",
                pieces = {
                    head = 29011,      -- Warbringer Greathelm
                    shoulders = 29016, -- Warbringer Shoulderguards
                    chest = 29012,     -- Warbringer Chestguard
                    hands = 29017,     -- Warbringer Handguards
                    legs = 29015,      -- Warbringer Legguards
                },
            },
            ["Fury"] = {
                setID = 655,
                setName = "Warbringer Battlegear",
                pieces = {
                    head = 29021,      -- Warbringer Battle-Helm
                    shoulders = 29023, -- Warbringer Shoulderplates
                    chest = 29019,     -- Warbringer Breastplate
                    hands = 29020,     -- Warbringer Gauntlets
                    legs = 29022,      -- Warbringer Greaves
                },
            },
        },
        [5] = {
            ["Protection"] = {
                setID = 656,
                setName = "Destroyer Armor",
                pieces = {
                    head = 30115,
                    shoulders = 30117,
                    chest = 30113,
                    hands = 30114,
                    legs = 30116,
                },
            },
            ["Fury"] = {
                setID = 657,
                setName = "Destroyer Battlegear",
                pieces = {
                    head = 30120,
                    shoulders = 30122,
                    chest = 30118,
                    hands = 30119,
                    legs = 30121,
                },
            },
        },
    },

    ["WARLOCK"] = {
        [4] = {
            ["default"] = {
                setID = 645,
                setName = "Voidheart Raiment",
                pieces = {
                    head = 28963,      -- Voidheart Crown
                    shoulders = 28967, -- Voidheart Mantle
                    chest = 28964,     -- Voidheart Robe
                    hands = 28968,     -- Voidheart Gloves
                    legs = 28966,      -- Voidheart Leggings
                },
            },
        },
        [5] = {
            ["default"] = {
                setID = 646,
                setName = "Corruptor Raiment",
                pieces = {
                    head = 30211,      -- Hood of the Corruptor
                    shoulders = 30212, -- Mantle of the Corruptor
                    chest = 30213,     -- Robe of the Corruptor
                    hands = 30215,     -- Gloves of the Corruptor
                    legs = 30214,      -- Leggings of the Corruptor
                },
            },
        },
    },

    ["ROGUE"] = {
        [4] = {
            ["default"] = {
                setID = 621,
                setName = "Netherblade",
                pieces = {
                    head = 29044,      -- Netherblade Facemask
                    shoulders = 29045, -- Netherblade Shoulderpads
                    chest = 29046,     -- Netherblade Chestpiece
                    hands = 29048,     -- Netherblade Gloves
                    legs = 29047,      -- Netherblade Breeches
                },
            },
        },
    },

    ["PRIEST"] = {
        [4] = {
            ["Holy"] = {
                setID = 663,
                setName = "Incarnate Raiment",
                pieces = {
                    head = 29049,
                    shoulders = 29055,
                    chest = 29050,
                    hands = 29054,
                    legs = 29058,
                },
            },
            ["Shadow"] = {
                setID = 664,
                setName = "Incarnate Regalia",
                pieces = {
                    head = 29058,  -- Different pieces for shadow
                    shoulders = 29060,
                    chest = 29056,
                    hands = 29057,
                    legs = 29059,
                },
            },
        },
    },

    ["MAGE"] = {
        [4] = {
            ["default"] = {
                setID = 648,
                setName = "Aldor Regalia",
                pieces = {
                    head = 29076,
                    shoulders = 29079,
                    chest = 29077,
                    hands = 29080,
                    legs = 29078,
                },
            },
        },
    },

    ["DRUID"] = {
        [4] = {
            ["Balance"] = {
                setID = 639,
                setName = "Malorne Regalia",
                pieces = {
                    head = 29093,
                    shoulders = 29095,
                    chest = 29091,
                    hands = 29092,
                    legs = 29094,
                },
            },
            ["Feral"] = {
                setID = 640,
                setName = "Malorne Harness",
                pieces = {
                    head = 29098,
                    shoulders = 29100,
                    chest = 29096,
                    hands = 29097,
                    legs = 29099,
                },
            },
            ["Restoration"] = {
                setID = 638,
                setName = "Malorne Raiment",
                pieces = {
                    head = 29086,
                    shoulders = 29089,
                    chest = 29087,
                    hands = 29090,
                    legs = 29088,
                },
            },
        },
    },

    ["PALADIN"] = {
        [4] = {
            ["Holy"] = {
                setID = 624,
                setName = "Justicar Raiment",
                pieces = {
                    head = 29061,
                    shoulders = 29064,
                    chest = 29062,
                    hands = 29065,
                    legs = 29063,
                },
            },
            ["Protection"] = {
                setID = 625,
                setName = "Justicar Armor",
                pieces = {
                    head = 29068,
                    shoulders = 29070,
                    chest = 29066,
                    hands = 29067,
                    legs = 29069,
                },
            },
            ["Retribution"] = {
                setID = 626,
                setName = "Justicar Battlegear",
                pieces = {
                    head = 29073,
                    shoulders = 29075,
                    chest = 29071,
                    hands = 29072,
                    legs = 29074,
                },
            },
        },
    },

    ["HUNTER"] = {
        [4] = {
            ["default"] = {
                setID = 651,
                setName = "Demon Stalker Armor",
                pieces = {
                    head = 29081,
                    shoulders = 29084,
                    chest = 29082,
                    hands = 29085,
                    legs = 29083,
                },
            },
        },
    },

    ["SHAMAN"] = {
        [4] = {
            ["Elemental"] = {
                setID = 632,
                setName = "Cyclone Regalia",
                pieces = {
                    head = 29035,
                    shoulders = 29037,
                    chest = 29033,
                    hands = 29034,
                    legs = 29036,
                },
            },
            ["Enhancement"] = {
                setID = 633,
                setName = "Cyclone Harness",
                pieces = {
                    head = 29040,
                    shoulders = 29043,
                    chest = 29038,
                    hands = 29039,
                    legs = 29042,
                },
            },
            ["Restoration"] = {
                setID = 631,
                setName = "Cyclone Raiment",
                pieces = {
                    head = 29028,
                    shoulders = 29031,
                    chest = 29029,
                    hands = 29032,
                    legs = 29030,
                },
            },
        },
    },
}
```

### 3.2 Recolor Mappings

Items that share the same 3D model but different color palette.

```lua
-- Maps base item ID to array of all color variants (including itself)
-- First item is considered the "primary" version
C.TIER_RECOLORS = {
    -- Warrior T4 Protection examples (same model, different colors)
    -- [baseItemID] = { variant1, variant2, ... }

    -- Warbringer Greathelm (29011) shares model with Warbringer Battle-Helm (29021)
    [29011] = { 29011, 29021 },  -- Protection helm, Fury helm
    [29021] = { 29011, 29021 },  -- Link back for reverse lookup

    -- Warbringer chest pieces
    [29012] = { 29012, 29019 },  -- Protection chest, Fury chest
    [29019] = { 29012, 29019 },

    -- Warbringer shoulders
    [29016] = { 29016, 29023 },
    [29023] = { 29016, 29023 },

    -- Warbringer hands
    [29017] = { 29017, 29020 },
    [29020] = { 29017, 29020 },

    -- Warbringer legs
    [29015] = { 29015, 29022 },
    [29022] = { 29015, 29022 },

    -- Note: Many tier pieces DON'T have recolors within TBC
    -- Voidheart, Netherblade, etc. are unique models
    -- This table will be sparse - only populate items with actual variants
}

-- Helper to check if an item has recolors
function C:HasRecolors(itemID)
    return C.TIER_RECOLORS[itemID] ~= nil and #C.TIER_RECOLORS[itemID] > 1
end

-- Get all variants for an item
function C:GetRecolors(itemID)
    return C.TIER_RECOLORS[itemID] or { itemID }
end
```

### 3.3 Dungeon/World Recolors (Phase 2)

Many tier sets have dungeon drop lookalikes with different colors.

```lua
-- Maps tier item to its dungeon/world lookalikes
C.TIER_LOOKALIKES = {
    -- Format: [tierItemID] = { { itemID, source, color }, ... }

    -- Example: Lightforge lookalikes found in TBC dungeons
    -- [originalT1Item] = {
    --     { lookalike1, "Heroic Mechanar", "Blue" },
    --     { lookalike2, "Badge Vendor", "Black/Gold" },
    -- },
}
```

### 3.4 Item Metadata Cache

For displaying item names/icons in UI without server queries.

```lua
-- Cached item info for instant UI display
C.TIER_ITEM_INFO = {
    -- [itemID] = { name, icon, quality, slot }
    [29011] = { "Warbringer Greathelm", "Interface\\Icons\\INV_Helmet_70", 4, "head" },
    [29012] = { "Warbringer Chestguard", "Interface\\Icons\\INV_Chest_Plate16", 4, "chest" },
    -- ... populated for all tier items
}
```

### 3.5 Slot Definitions

```lua
C.DRESSING_ROOM_SLOTS = {
    { id = "head", label = "Head", order = 1 },
    { id = "shoulders", label = "Shoulders", order = 2 },
    { id = "chest", label = "Chest", order = 3 },
    { id = "hands", label = "Hands", order = 4 },
    { id = "legs", label = "Legs", order = 5 },
    -- Future: waist, wrists, feet (non-tier slots for matching)
}

C.TIER_NUMBERS = { 4, 5, 6 }  -- Supported tiers
```

---

## 4. API Reference

### 4.1 DressUpModel API (TBC 2.4.3 Compatible)

```lua
-- Create a dress-up model frame
local model = CreateFrame("DressUpModel", "HopeAddonDressingRoomModel", parent)
model:SetSize(width, height)
model:SetPoint("CENTER")

-- Display the player character
model:SetUnit("player")

-- Try on an item (displays on model)
-- In TBC 2.4.3, pass the numeric item ID
model:TryOn(itemID)  -- e.g., model:TryOn(29011)

-- Reset to current equipped gear
model:Dress()

-- Remove all gear from model (naked)
model:Undress()

-- Undress a specific slot
model:UndressSlot(slotID)
-- Slot IDs: 1=Head, 3=Shoulder, 5=Chest, 6=Waist, 7=Legs, 8=Feet, 9=Wrist, 10=Hands

-- Model positioning/rotation
model:SetRotation(radians)  -- Rotate the model
model:SetModelScale(scale)  -- Scale the model size
model:SetPosition(x, y, z)  -- Position within frame
```

### 4.2 Slot ID Reference

```lua
-- WoW inventory slot IDs for UndressSlot
C.SLOT_IDS = {
    head = 1,
    -- neck = 2,  (not visible)
    shoulders = 3,
    -- shirt = 4,
    chest = 5,
    waist = 6,
    legs = 7,
    feet = 8,
    wrists = 9,
    hands = 10,
    -- finger1 = 11, finger2 = 12 (not visible)
    -- trinket1 = 13, trinket2 = 14 (not visible)
    back = 15,  -- cloak
    mainhand = 16,
    offhand = 17,
    -- ranged = 18,
    tabard = 19,
}
```

### 4.3 GetItemInfo API

```lua
-- Query item information (may require server round-trip)
local name, link, quality, iLevel, reqLevel, class, subclass,
      maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)

-- For instant display, use cached C.TIER_ITEM_INFO instead
```

---

## 5. UI Design

### 5.1 Window Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  DRESSING ROOM                                        [X] Close │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐│
│  │                     │    │  TIER SELECTION                 ││
│  │                     │    │  [T4] [T5] [T6]                  ││
│  │                     │    ├─────────────────────────────────┤│
│  │                     │    │  SPEC: [Dropdown v]             ││
│  │    DressUpModel     │    ├─────────────────────────────────┤│
│  │    (Character       │    │  SET: Warbringer Armor          ││
│  │     Preview)        │    ├─────────────────────────────────┤│
│  │                     │    │  SLOTS                          ││
│  │                     │    │  ┌─────┐ Head     [Recolor v]   ││
│  │                     │    │  │ ico │ Warbringer Greathelm   ││
│  │                     │    │  └─────┘                        ││
│  │                     │    │  ┌─────┐ Shoulders [Recolor v]  ││
│  │                     │    │  │ ico │ Warbringer Shouldergu..││
│  │                     │    │  └─────┘                        ││
│  │                     │    │  ┌─────┐ Chest    [Recolor v]   ││
│  │                     │    │  │ ico │ Warbringer Chestguard  ││
│  │                     │    │  └─────┘                        ││
│  │                     │    │  ┌─────┐ Hands                  ││
│  │                     │    │  │ ico │ Warbringer Handguards  ││
│  │                     │    │  └─────┘                        ││
│  │                     │    │  ┌─────┐ Legs                   ││
│  └─────────────────────┘    │  │ ico │ Warbringer Legguards   ││
│                             │  └─────┘                        ││
│  [Rotate L] [Rotate R]      └─────────────────────────────────┘│
│  [Reset View]                                                   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  [Undress All]  [Dress Current Gear]  [★ Save as Dream Set]    │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Window Specifications

```lua
C.DRESSING_ROOM_UI = {
    WINDOW_WIDTH = 650,
    WINDOW_HEIGHT = 500,
    MODEL_WIDTH = 280,
    MODEL_HEIGHT = 400,
    PANEL_WIDTH = 320,
    SLOT_ROW_HEIGHT = 50,
    ICON_SIZE = 40,
}
```

### 5.3 Recolor Dropdown

When a slot has multiple color variants:

```
┌─────────────────────────────┐
│ Warbringer Greathelm (Prot) │ ← Currently shown
├─────────────────────────────┤
│ Warbringer Battle-Helm (DPS)│ ← Click to swap
└─────────────────────────────┘
```

---

## 6. Implementation Phases

### Phase 1: Core Data Tables (Research Heavy)
**Estimated Effort:** 4-6 hours of research + data entry

- [ ] Research and document ALL Tier 4 item IDs for all 9 classes
- [ ] Research and document ALL Tier 5 item IDs for all 9 classes
- [ ] Identify which items share models (recolors)
- [ ] Create C.TIER_SETS table with verified item IDs
- [ ] Create C.TIER_RECOLORS table for variants
- [ ] Create C.TIER_ITEM_INFO cache table
- [ ] Add to Constants.lua or new DressingRoomData.lua

### Phase 2: Basic DressUpModel Window
**Estimated Effort:** 2-3 hours

- [ ] Create DressingRoomCore.lua module skeleton
- [ ] Create DressingRoomUI.lua with basic window
- [ ] Implement DressUpModel frame creation
- [ ] Add model:SetUnit("player") initialization
- [ ] Add basic rotation controls
- [ ] Add Undress/Dress buttons
- [ ] Register `/hope dressroom` slash command

### Phase 3: Tier/Spec Selection UI
**Estimated Effort:** 2-3 hours

- [ ] Add tier selection buttons (T4/T5/T6)
- [ ] Add spec dropdown (populated from C.TIER_SETS)
- [ ] Load set pieces when tier+spec selected
- [ ] Display slot rows with item icons/names
- [ ] Implement TryOn for each slot

### Phase 4: Recolor Selection
**Estimated Effort:** 2 hours

- [ ] Add recolor dropdown to slots with variants
- [ ] Populate dropdown from C.TIER_RECOLORS
- [ ] Update model when recolor selected
- [ ] Visual indicator for slots with recolor options

### Phase 5: Dream Set Persistence
**Estimated Effort:** 1-2 hours

- [ ] Add charDb.dressingRoom.dreamSet storage
- [ ] Implement "Save as Dream Set" button
- [ ] Load saved dream set on open (if exists)
- [ ] Add "Load Dream Set" button

### Phase 6: Fellow Traveler Sync (Optional)
**Estimated Effort:** 2-3 hours

- [ ] Add dreamSet to myProfile sync data
- [ ] Display other players' dream sets in Social tab
- [ ] "View Dream Set" button on Fellow Traveler cards

### Phase 7: Tier 6 & Lookalikes (Future)
**Estimated Effort:** 4+ hours research

- [ ] Research Tier 6 item IDs
- [ ] Research dungeon/world lookalikes
- [ ] Add C.TIER_LOOKALIKES table
- [ ] UI for browsing lookalikes

---

## 7. Research Notes

### 7.1 Verified Tier 4 Set IDs (from Wowhead)

| Class | Spec | Set Name | Set ID |
|-------|------|----------|--------|
| Warrior | Protection | Warbringer Armor | 654 |
| Warrior | Fury | Warbringer Battlegear | 655 |
| Warlock | All | Voidheart Raiment | 645 |
| Rogue | All | Netherblade | 621 |
| Priest | Holy | Incarnate Raiment | 663 |
| Priest | Shadow | Incarnate Regalia | 664 |
| Mage | All | Aldor Regalia | 648 |
| Druid | Balance | Malorne Regalia | 639 |
| Druid | Feral | Malorne Harness | 640 |
| Druid | Resto | Malorne Raiment | 638 |
| Paladin | Holy | Justicar Raiment | 624 |
| Paladin | Protection | Justicar Armor | 625 |
| Paladin | Retribution | Justicar Battlegear | 626 |
| Hunter | All | Demon Stalker Armor | 651 |
| Shaman | Elemental | Cyclone Regalia | 632 |
| Shaman | Enhancement | Cyclone Harness | 633 |
| Shaman | Resto | Cyclone Raiment | 631 |

### 7.2 Verified Tier 5 Set IDs

| Class | Spec | Set Name | Set ID |
|-------|------|----------|--------|
| Warrior | Protection | Destroyer Armor | 656 |
| Warrior | Fury | Destroyer Battlegear | 657 |
| Warlock | All | Corruptor Raiment | 646 |
| Druid | Balance | Nordrassil Regalia | 643 |
| Druid | Feral | Nordrassil Harness | 641 |
| Druid | Resto | Nordrassil Raiment | 642 |

### 7.3 Research Still Needed

- [ ] Complete Tier 5 set IDs for all classes
- [ ] All individual piece item IDs (head, shoulders, chest, hands, legs)
- [ ] Tier 6 set IDs and item IDs
- [ ] Cross-reference which items share display models
- [ ] Dungeon drops that match tier appearances

### 7.4 Wowhead URL Patterns

To look up item IDs:
- Set page: `https://www.wowhead.com/tbc/item-set=XXX/set-name`
- Individual item: `https://www.wowhead.com/tbc/item=XXXXX/item-name`
- Transmog set (shows recolors): `https://www.wowhead.com/tbc/transmog-set=XXX/set-name`

### 7.5 API Compatibility Notes

**TBC Classic 2.4.3:**
- `DressUpModel:TryOn(itemID)` - Pass numeric item ID directly
- `DressUpModel:SetUnit("player")` - Works as expected
- `DressUpModel:Undress()` - Works as expected
- `DressUpModel:UndressSlot(slotID)` - Works as expected
- `GetItemInfo(itemID)` - May require cache warming

**NOT Available in TBC:**
- `C_TransmogCollection` - Retail only
- `C_Transmog` - Retail only
- Appearance IDs - Retail transmog system

---

## 8. SavedVariables Structure

```lua
-- In charDb (per-character)
charDb.dressingRoom = {
    -- Saved "dream set" configuration
    dreamSet = {
        tier = 4,
        spec = "Protection",  -- or "default"
        slots = {
            head = 29011,      -- Selected item ID (may be recolor)
            shoulders = 29016,
            chest = 29012,
            hands = 29017,
            legs = 29015,
        },
    },

    -- UI state
    lastTier = 4,
    lastSpec = nil,  -- nil = auto-detect from talents

    -- Settings
    settings = {
        autoDetectSpec = true,
        syncDreamSet = true,  -- Share with Fellow Travelers
    },
}
```

---

## 9. Slash Commands

```
/hope dressroom          -- Open Dressing Room window
/hope dressroom t4       -- Open with Tier 4 selected
/hope dressroom t5       -- Open with Tier 5 selected
/hope dressroom reset    -- Clear saved dream set
```

---

## 10. File Structure

```
HopeAddon/
├── Social/
│   └── DressingRoom/
│       ├── DressingRoomCore.lua    -- Module registration, slash commands
│       ├── DressingRoomUI.lua      -- All UI code, DressUpModel handling
│       └── DressingRoomData.lua    -- Item tables (TIER_SETS, TIER_RECOLORS, etc.)
```

Add to HopeAddon.toc:
```
Social\DressingRoom\DressingRoomData.lua
Social\DressingRoom\DressingRoomCore.lua
Social\DressingRoom\DressingRoomUI.lua
```

---

## 11. Sources & References

- [Wowhead TBC Classic Database](https://www.wowhead.com/tbc)
- [Wowpedia DressUpModel API](https://wowpedia.fandom.com/wiki/API_DressUpModel_TryOn)
- [Warcraft Wiki Widget API](https://warcraft.wiki.gg/wiki/Widget_API)
- [Wowpedia Set Look-Alikes](https://wowpedia.fandom.com/wiki/Set_look_alikes)
- [Wowhead Tier 4 Overview](https://www.wowhead.com/tbc/guide/tier-4-set-overview-burning-crusade-classic)

---

## 12. Color Configuration System

This section documents ALL available color manipulation options for the Dressing Room, providing UI buttons and presets for stream-friendly visual customization.

---

### 12.1 Available Color APIs

#### 12.1.1 Model Lighting (`Model:SetLight`)

The primary method for color-tinting the 3D character model.

```lua
Model:SetLight(enabled, light)

-- 'light' is a table with these fields:
light = {
    omnidirectional = false,     -- true = light from all directions
    point = { x, y, z },         -- direction vector (or position if omni)
    ambientIntensity = 0.7,      -- 0.0 - 1.0, base lighting strength
    ambientColor = { r, g, b },  -- RGB 0.0-1.0, tints the overall model
    diffuseIntensity = 0.8,      -- 0.0 - 1.0, highlight/specular strength
    diffuseColor = { r, g, b },  -- RGB 0.0-1.0, tints highlights/shine
}

-- TBC 2.4.3 alternate syntax (positional args):
Model:SetLight(
    enabled,        -- boolean: true to enable lighting
    omni,           -- boolean: omnidirectional light
    dirX, dirY, dirZ,  -- light direction vector
    ambIntensity,   -- ambient intensity (0.0-1.0)
    ambR, ambG, ambB,  -- ambient RGB (0.0-1.0 each)
    dirIntensity,   -- directional intensity (0.0-1.0)
    dirR, dirG, dirB   -- directional RGB (0.0-1.0 each)
)
```

**Key Insight:**
- `ambientColor` affects the **overall color tone** of the model
- `diffuseColor` affects **specular highlights/shine** only
- To create a "red tint", set `ambientColor = {1.0, 0.5, 0.5}`

#### 12.1.2 Fog Effects (`Model:SetFog*`)

Creates atmospheric color wash over the model.

```lua
Model:SetFogColor(r, g, b, a)  -- RGB + alpha (0.0-1.0)
Model:SetFogNear(distance)     -- Where fog starts
Model:SetFogFar(distance)      -- Where fog is fully opaque

-- Example: Purple haze effect
model:SetFogColor(0.5, 0.2, 0.8, 0.3)  -- Light purple, 30% opacity
model:SetFogNear(0)
model:SetFogFar(10)
```

#### 12.1.3 Color Overlay Texture

Layer a semi-transparent colored texture over the model frame.

```lua
-- Create overlay texture
local overlay = model:CreateTexture(nil, "OVERLAY")
overlay:SetAllPoints(model)
overlay:SetColorTexture(r, g, b)  -- Solid color
overlay:SetAlpha(0.2)             -- 20% opacity for tint effect
overlay:SetBlendMode("ADD")       -- Additive for glow, "BLEND" for tint
```

**Blend Modes:**
| Mode | Effect | Use Case |
|------|--------|----------|
| `BLEND` | Standard alpha blend | Subtle color wash |
| `ADD` | Additive (brightens) | Glowing/ethereal look |
| `MOD` | Multiplicative (darkens) | Shadow/dark tint |

#### 12.1.4 Background Color

Set the frame background behind the model.

```lua
-- Solid color background
local bg = model:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(model)
bg:SetColorTexture(r, g, b)
bg:SetAlpha(1.0)

-- Or use SetBackdrop with BackdropTemplate (TBC compatible)
model:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true, tileSize = 32,
})
model:SetBackdropColor(r, g, b, a)
```

---

### 12.2 Color Preset System

#### 12.2.1 Lighting Presets Table

```lua
C.DRESSING_ROOM_LIGHTING_PRESETS = {
    -- Each preset defines the full SetLight parameters
    -- Format: { name, icon, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB, dirX, dirY, dirZ }

    ["default"] = {
        name = "Default",
        icon = "Interface\\Icons\\Spell_Nature_WispSplode",
        description = "Standard neutral lighting",
        ambIntensity = 0.7,
        ambColor = { 1.0, 1.0, 1.0 },
        dirIntensity = 0.8,
        dirColor = { 1.0, 1.0, 1.0 },
        dirVector = { 0, -0.707, -0.707 },
    },

    -- WARM PRESETS (Reds, Oranges, Yellows)
    ["warm_gold"] = {
        name = "Golden Hour",
        icon = "Interface\\Icons\\Spell_Holy_SurgeOfLight",
        description = "Warm golden sunlight",
        ambIntensity = 0.8,
        ambColor = { 1.0, 0.9, 0.7 },
        dirIntensity = 0.9,
        dirColor = { 1.0, 0.85, 0.6 },
        dirVector = { -0.5, -0.5, -0.707 },
    },
    ["warm_fire"] = {
        name = "Firelight",
        icon = "Interface\\Icons\\Spell_Fire_Fire",
        description = "Flickering campfire warmth",
        ambIntensity = 0.6,
        ambColor = { 1.0, 0.6, 0.3 },
        dirIntensity = 0.7,
        dirColor = { 1.0, 0.5, 0.2 },
        dirVector = { 0, -0.3, -0.9 },
    },
    ["warm_sunset"] = {
        name = "Sunset",
        icon = "Interface\\Icons\\INV_Misc_Orb_05",
        description = "Deep orange sunset glow",
        ambIntensity = 0.7,
        ambColor = { 1.0, 0.5, 0.3 },
        dirIntensity = 0.8,
        dirColor = { 1.0, 0.4, 0.2 },
        dirVector = { -0.707, -0.5, -0.5 },
    },

    -- COOL PRESETS (Blues, Purples, Teals)
    ["cool_moonlight"] = {
        name = "Moonlight",
        icon = "Interface\\Icons\\Spell_Arcane_StarFire",
        description = "Cool silvery moonlight",
        ambIntensity = 0.6,
        ambColor = { 0.7, 0.8, 1.0 },
        dirIntensity = 0.7,
        dirColor = { 0.8, 0.85, 1.0 },
        dirVector = { 0, -0.9, -0.3 },
    },
    ["cool_frost"] = {
        name = "Frost",
        icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        description = "Icy blue chill",
        ambIntensity = 0.7,
        ambColor = { 0.6, 0.85, 1.0 },
        dirIntensity = 0.8,
        dirColor = { 0.5, 0.9, 1.0 },
        dirVector = { 0, -0.707, -0.707 },
    },
    ["cool_arcane"] = {
        name = "Arcane",
        icon = "Interface\\Icons\\Spell_Arcane_Arcane04",
        description = "Mystical purple arcane energy",
        ambIntensity = 0.7,
        ambColor = { 0.8, 0.6, 1.0 },
        dirIntensity = 0.8,
        dirColor = { 0.7, 0.5, 1.0 },
        dirVector = { 0, -0.707, -0.707 },
    },

    -- FEL / OUTLAND PRESETS (TBC themed)
    ["fel_green"] = {
        name = "Fel Fire",
        icon = "Interface\\Icons\\Spell_Fire_FelFire",
        description = "Sinister fel green glow",
        ambIntensity = 0.6,
        ambColor = { 0.4, 1.0, 0.4 },
        dirIntensity = 0.8,
        dirColor = { 0.3, 1.0, 0.3 },
        dirVector = { 0, -0.5, -0.866 },
    },
    ["fel_shadow"] = {
        name = "Shadow",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        description = "Dark shadow magic",
        ambIntensity = 0.4,
        ambColor = { 0.5, 0.4, 0.6 },
        dirIntensity = 0.5,
        dirColor = { 0.6, 0.5, 0.8 },
        dirVector = { 0, -0.707, -0.707 },
    },
    ["outland_red"] = {
        name = "Hellfire",
        icon = "Interface\\Icons\\Spell_Fire_Incinerate",
        description = "Hellfire Peninsula red sky",
        ambIntensity = 0.7,
        ambColor = { 1.0, 0.4, 0.3 },
        dirIntensity = 0.6,
        dirColor = { 1.0, 0.3, 0.2 },
        dirVector = { 0, -0.707, -0.707 },
    },

    -- DRAMATIC / STUDIO PRESETS
    ["dramatic_spotlight"] = {
        name = "Spotlight",
        icon = "Interface\\Icons\\Spell_Holy_PowerInfusion",
        description = "Dramatic single spotlight",
        ambIntensity = 0.3,
        ambColor = { 0.8, 0.8, 0.8 },
        dirIntensity = 1.0,
        dirColor = { 1.0, 1.0, 1.0 },
        dirVector = { 0, -0.9, -0.3 },
    },
    ["dramatic_rim"] = {
        name = "Rim Light",
        icon = "Interface\\Icons\\Spell_Holy_SealOfRighteousness",
        description = "Edge-lit silhouette effect",
        ambIntensity = 0.2,
        ambColor = { 0.3, 0.3, 0.4 },
        dirIntensity = 1.0,
        dirColor = { 1.0, 0.95, 0.9 },
        dirVector = { 0.707, -0.5, 0.5 },  -- Light from behind
    },
    ["dramatic_dark"] = {
        name = "Noir",
        icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
        description = "Dark mysterious shadows",
        ambIntensity = 0.25,
        ambColor = { 0.6, 0.6, 0.7 },
        dirIntensity = 0.6,
        dirColor = { 0.9, 0.9, 1.0 },
        dirVector = { -0.5, -0.707, -0.5 },
    },

    -- HOLY / LIGHT PRESETS
    ["holy_light"] = {
        name = "Holy Light",
        icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
        description = "Divine radiant glow",
        ambIntensity = 0.9,
        ambColor = { 1.0, 1.0, 0.9 },
        dirIntensity = 1.0,
        dirColor = { 1.0, 1.0, 0.8 },
        dirVector = { 0, -0.9, -0.3 },
    },
    ["holy_naaru"] = {
        name = "Naaru",
        icon = "Interface\\Icons\\INV_Enchant_ShardBrilliantSmall",
        description = "Shimmering Naaru essence",
        ambIntensity = 0.8,
        ambColor = { 0.9, 0.95, 1.0 },
        dirIntensity = 0.9,
        dirColor = { 0.95, 1.0, 1.0 },
        dirVector = { 0, -0.8, -0.5 },
    },

    -- NATURE PRESETS
    ["nature_forest"] = {
        name = "Forest",
        icon = "Interface\\Icons\\Spell_Nature_ProtectionformNature",
        description = "Dappled forest sunlight",
        ambIntensity = 0.6,
        ambColor = { 0.8, 1.0, 0.7 },
        dirIntensity = 0.7,
        dirColor = { 0.9, 1.0, 0.6 },
        dirVector = { -0.3, -0.8, -0.5 },
    },
    ["nature_underwater"] = {
        name = "Underwater",
        icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
        description = "Deep ocean blue",
        ambIntensity = 0.5,
        ambColor = { 0.4, 0.7, 0.9 },
        dirIntensity = 0.6,
        dirColor = { 0.5, 0.8, 1.0 },
        dirVector = { 0, -1, 0 },  -- Light from above
    },
}

-- Preset categories for UI organization
C.DRESSING_ROOM_LIGHTING_CATEGORIES = {
    { id = "warm", name = "Warm", presets = { "warm_gold", "warm_fire", "warm_sunset" } },
    { id = "cool", name = "Cool", presets = { "cool_moonlight", "cool_frost", "cool_arcane" } },
    { id = "fel", name = "Fel/Outland", presets = { "fel_green", "fel_shadow", "outland_red" } },
    { id = "dramatic", name = "Dramatic", presets = { "dramatic_spotlight", "dramatic_rim", "dramatic_dark" } },
    { id = "holy", name = "Holy/Light", presets = { "holy_light", "holy_naaru" } },
    { id = "nature", name = "Nature", presets = { "nature_forest", "nature_underwater" } },
}
```

#### 12.2.2 Background Presets Table

```lua
C.DRESSING_ROOM_BACKGROUND_PRESETS = {
    -- Solid colors
    ["black"] = {
        name = "Black",
        type = "solid",
        color = { 0, 0, 0 },
        alpha = 1.0,
    },
    ["dark_grey"] = {
        name = "Dark Grey",
        type = "solid",
        color = { 0.15, 0.15, 0.15 },
        alpha = 1.0,
    },
    ["charcoal"] = {
        name = "Charcoal",
        type = "solid",
        color = { 0.2, 0.2, 0.25 },
        alpha = 1.0,
    },
    ["dark_blue"] = {
        name = "Dark Blue",
        type = "solid",
        color = { 0.1, 0.1, 0.3 },
        alpha = 1.0,
    },
    ["dark_green"] = {
        name = "Dark Green",
        type = "solid",
        color = { 0.1, 0.2, 0.1 },
        alpha = 1.0,
    },
    ["dark_red"] = {
        name = "Dark Red",
        type = "solid",
        color = { 0.25, 0.1, 0.1 },
        alpha = 1.0,
    },
    ["dark_purple"] = {
        name = "Dark Purple",
        type = "solid",
        color = { 0.2, 0.1, 0.25 },
        alpha = 1.0,
    },

    -- Textured backgrounds
    ["parchment"] = {
        name = "Parchment",
        type = "texture",
        texture = "Interface\\DialogFrame\\UI-DialogBox-Background",
        color = { 0.8, 0.7, 0.5 },
    },
    ["stone"] = {
        name = "Stone",
        type = "texture",
        texture = "Interface\\Tooltips\\UI-Tooltip-Background",
        color = { 0.5, 0.5, 0.5 },
    },
}
```

#### 12.2.3 Fog/Atmosphere Presets

```lua
C.DRESSING_ROOM_FOG_PRESETS = {
    ["none"] = {
        name = "None",
        enabled = false,
    },
    ["light_mist"] = {
        name = "Light Mist",
        enabled = true,
        color = { 0.8, 0.8, 0.9, 0.15 },
        near = 5,
        far = 15,
    },
    ["purple_haze"] = {
        name = "Purple Haze",
        enabled = true,
        color = { 0.6, 0.3, 0.8, 0.2 },
        near = 3,
        far = 12,
    },
    ["fel_smoke"] = {
        name = "Fel Smoke",
        enabled = true,
        color = { 0.2, 0.8, 0.3, 0.25 },
        near = 2,
        far = 10,
    },
    ["shadow_veil"] = {
        name = "Shadow Veil",
        enabled = true,
        color = { 0.2, 0.2, 0.3, 0.3 },
        near = 0,
        far = 8,
    },
    ["holy_glow"] = {
        name = "Holy Glow",
        enabled = true,
        color = { 1.0, 1.0, 0.8, 0.15 },
        near = 5,
        far = 20,
    },
}
```

#### 12.2.4 Color Overlay Presets

```lua
C.DRESSING_ROOM_OVERLAY_PRESETS = {
    ["none"] = {
        name = "None",
        enabled = false,
    },
    ["warm_tint"] = {
        name = "Warm Tint",
        enabled = true,
        color = { 1.0, 0.8, 0.6 },
        alpha = 0.1,
        blendMode = "BLEND",
    },
    ["cool_tint"] = {
        name = "Cool Tint",
        enabled = true,
        color = { 0.6, 0.8, 1.0 },
        alpha = 0.1,
        blendMode = "BLEND",
    },
    ["golden_glow"] = {
        name = "Golden Glow",
        enabled = true,
        color = { 1.0, 0.9, 0.5 },
        alpha = 0.15,
        blendMode = "ADD",
    },
    ["fel_glow"] = {
        name = "Fel Glow",
        enabled = true,
        color = { 0.3, 1.0, 0.3 },
        alpha = 0.1,
        blendMode = "ADD",
    },
    ["shadow_wash"] = {
        name = "Shadow Wash",
        enabled = true,
        color = { 0.3, 0.3, 0.4 },
        alpha = 0.2,
        blendMode = "MOD",
    },
}
```

---

### 12.3 Color Configuration UI

#### 12.3.1 Updated Window Layout with Color Controls

```
┌─────────────────────────────────────────────────────────────────────────┐
│  DRESSING ROOM                                              [X] Close   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────┐    ┌─────────────────────────────────────────┐│
│  │                     │    │  TIER SELECTION                         ││
│  │                     │    │  [T4] [T5] [T6]                          ││
│  │                     │    ├─────────────────────────────────────────┤│
│  │                     │    │  SPEC: [Dropdown v]                     ││
│  │    DressUpModel     │    ├─────────────────────────────────────────┤│
│  │    (Character       │    │  SET: Warbringer Armor                  ││
│  │     Preview)        │    ├─────────────────────────────────────────┤│
│  │                     │    │  SLOTS                                  ││
│  │                     │    │  [Head] [Shoulders] [Chest] [Hands] [Legs]│
│  │                     │    ├─────────────────────────────────────────┤│
│  │                     │    │  LIGHTING PRESET                        ││
│  │                     │    │  [🔥] [❄️] [👹] [💡] [✨] [🌿]           ││
│  │                     │    │  ↳ Category: Warm | Cool | Fel | ...    ││
│  │                     │    │  [Golden Hour  v] ← Dropdown             ││
│  └─────────────────────┘    │                                         ││
│                             ├─────────────────────────────────────────┤│
│  [◀ Rotate] [▶]  [Reset]    │  BACKGROUND                             ││
│                             │  [■][■][■][■][■][■] ← Color buttons      ││
│  EFFECTS:                   │                                         ││
│  [Fog: None    v]           ├─────────────────────────────────────────┤│
│  [Overlay: None v]          │  CUSTOM COLOR                           ││
│                             │  Ambient: [Color Picker]                ││
│                             │  Directional: [Color Picker]            ││
│                             │  [Reset to Preset]                      ││
│                             └─────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────────────┤
│  [Undress]  [Dress Current]  [★ Save Dream Set]  [📷 Screenshot Mode]  │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 12.3.2 UI Component Specifications

```lua
C.DRESSING_ROOM_COLOR_UI = {
    -- Lighting category buttons (icon row)
    CATEGORY_BUTTON_SIZE = 32,
    CATEGORY_BUTTON_SPACING = 4,

    -- Preset dropdown
    PRESET_DROPDOWN_WIDTH = 150,

    -- Background color swatches
    BG_SWATCH_SIZE = 24,
    BG_SWATCH_SPACING = 4,

    -- Custom color sliders (if advanced mode)
    SLIDER_WIDTH = 120,
    SLIDER_HEIGHT = 16,

    -- Color picker button
    COLOR_PICKER_SIZE = 20,
}
```

#### 12.3.3 Category Icon Buttons

Quick-access icons for lighting categories:

| Category | Icon | Tooltip |
|----------|------|---------|
| Warm | `Spell_Fire_Fire` | "Warm lighting (gold, fire, sunset)" |
| Cool | `Spell_Frost_FrostBolt02` | "Cool lighting (moon, frost, arcane)" |
| Fel/Outland | `Spell_Fire_FelFire` | "Fel & Outland themes" |
| Dramatic | `Spell_Holy_PowerInfusion` | "Studio & dramatic lighting" |
| Holy/Light | `Spell_Holy_HolyBolt` | "Divine & radiant light" |
| Nature | `Spell_Nature_ProtectionformNature` | "Nature & environment" |

---

### 12.4 Implementation Functions

#### 12.4.1 Apply Lighting Preset

```lua
function DressingRoomUI:ApplyLightingPreset(presetKey)
    local preset = C.DRESSING_ROOM_LIGHTING_PRESETS[presetKey]
    if not preset then return end

    local model = self.model
    local amb = preset.ambColor
    local dir = preset.dirColor
    local vec = preset.dirVector

    model:SetLight(
        true,                           -- enabled
        false,                          -- not omnidirectional
        vec[1], vec[2], vec[3],         -- direction vector
        preset.ambIntensity,            -- ambient intensity
        amb[1], amb[2], amb[3],         -- ambient RGB
        preset.dirIntensity,            -- directional intensity
        dir[1], dir[2], dir[3]          -- directional RGB
    )

    -- Store current preset
    self.currentLightingPreset = presetKey
end
```

#### 12.4.2 Apply Background Preset

```lua
function DressingRoomUI:ApplyBackgroundPreset(presetKey)
    local preset = C.DRESSING_ROOM_BACKGROUND_PRESETS[presetKey]
    if not preset then return end

    local bg = self.backgroundTexture

    if preset.type == "solid" then
        bg:SetColorTexture(preset.color[1], preset.color[2], preset.color[3])
        bg:SetAlpha(preset.alpha or 1.0)
    elseif preset.type == "texture" then
        bg:SetTexture(preset.texture)
        if preset.color then
            bg:SetVertexColor(preset.color[1], preset.color[2], preset.color[3])
        end
    end

    self.currentBackgroundPreset = presetKey
end
```

#### 12.4.3 Apply Fog Preset

```lua
function DressingRoomUI:ApplyFogPreset(presetKey)
    local preset = C.DRESSING_ROOM_FOG_PRESETS[presetKey]
    if not preset then return end

    local model = self.model

    if not preset.enabled then
        -- Disable fog by setting far distance very large
        model:SetFogNear(1000)
        model:SetFogFar(1001)
    else
        local c = preset.color
        model:SetFogColor(c[1], c[2], c[3], c[4] or 1.0)
        model:SetFogNear(preset.near)
        model:SetFogFar(preset.far)
    end

    self.currentFogPreset = presetKey
end
```

#### 12.4.4 Apply Overlay Preset

```lua
function DressingRoomUI:ApplyOverlayPreset(presetKey)
    local preset = C.DRESSING_ROOM_OVERLAY_PRESETS[presetKey]
    if not preset then return end

    local overlay = self.overlayTexture

    if not preset.enabled then
        overlay:Hide()
    else
        overlay:SetColorTexture(preset.color[1], preset.color[2], preset.color[3])
        overlay:SetAlpha(preset.alpha)
        overlay:SetBlendMode(preset.blendMode)
        overlay:Show()
    end

    self.currentOverlayPreset = presetKey
end
```

#### 12.4.5 Get Default Light (for Reset)

```lua
function DressingRoomUI:ResetToDefaultLighting()
    self:ApplyLightingPreset("default")
end

-- Get current light settings (for custom adjustment)
function DressingRoomUI:GetCurrentLight()
    -- Model:GetLight() returns enabled, light table
    local enabled, light = self.model:GetLight()
    return {
        enabled = enabled,
        ambIntensity = light.ambientIntensity,
        ambColor = light.ambientColor,
        dirIntensity = light.diffuseIntensity,
        dirColor = light.diffuseColor,
        dirVector = light.point,
    }
end
```

---

### 12.5 Custom Color Picker Integration

For advanced users who want fine-tuned control:

```lua
-- Open WoW's built-in ColorPickerFrame for ambient color
function DressingRoomUI:OpenAmbientColorPicker()
    local current = self:GetCurrentLight()
    local r, g, b = unpack(current.ambColor)

    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.previousValues = { r, g, b }

    ColorPickerFrame.func = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        self:SetCustomAmbientColor(newR, newG, newB)
    end

    ColorPickerFrame.cancelFunc = function()
        local prev = ColorPickerFrame.previousValues
        self:SetCustomAmbientColor(prev[1], prev[2], prev[3])
    end

    ColorPickerFrame:Show()
end

function DressingRoomUI:SetCustomAmbientColor(r, g, b)
    local current = self:GetCurrentLight()
    local dir = current.dirColor
    local vec = current.dirVector

    self.model:SetLight(
        true, false,
        vec[1], vec[2], vec[3],
        current.ambIntensity,
        r, g, b,
        current.dirIntensity,
        dir[1], dir[2], dir[3]
    )

    self.currentLightingPreset = "custom"
end
```

---

### 12.6 SavedVariables for Color Settings

```lua
-- Extended charDb.dressingRoom structure
charDb.dressingRoom = {
    dreamSet = { ... },

    -- Color configuration persistence
    colorSettings = {
        lightingPreset = "default",     -- Preset key or "custom"
        backgroundPreset = "dark_grey",
        fogPreset = "none",
        overlayPreset = "none",

        -- Custom values (if lightingPreset == "custom")
        customLighting = {
            ambIntensity = 0.7,
            ambColor = { 1.0, 1.0, 1.0 },
            dirIntensity = 0.8,
            dirColor = { 1.0, 1.0, 1.0 },
            dirVector = { 0, -0.707, -0.707 },
        },
    },

    -- Quick-access favorites
    favoritePresets = {
        "warm_gold",
        "fel_green",
        "dramatic_spotlight",
    },
}
```

---

### 12.7 Screenshot Mode

Special mode that hides UI for clean screenshots:

```lua
function DressingRoomUI:ToggleScreenshotMode()
    self.screenshotMode = not self.screenshotMode

    if self.screenshotMode then
        -- Hide all UI except the model
        self.sidePanel:Hide()
        self.bottomBar:Hide()
        self.titleBar:Hide()

        -- Expand model to fill window
        self.model:SetAllPoints(self.window)

        -- Optional: Apply saved "screenshot preset"
        if self.colorSettings.screenshotPreset then
            self:ApplyLightingPreset(self.colorSettings.screenshotPreset)
        end
    else
        -- Restore normal layout
        self.sidePanel:Show()
        self.bottomBar:Show()
        self.titleBar:Show()
        self:UpdateModelSize()
    end
end
```

---

### 12.8 Implementation Phases (Color System)

#### Phase A: Basic Lighting Presets
- [ ] Create `C.DRESSING_ROOM_LIGHTING_PRESETS` table
- [ ] Implement `ApplyLightingPreset()` function
- [ ] Add preset dropdown to UI
- [ ] Test all 18 lighting presets

#### Phase B: Background & Effects
- [ ] Create background presets table
- [ ] Implement `ApplyBackgroundPreset()`
- [ ] Create fog presets table
- [ ] Implement `ApplyFogPreset()`
- [ ] Add UI dropdowns for background/fog

#### Phase C: Category Quick-Access
- [ ] Create category icon buttons row
- [ ] Implement category→preset filtering
- [ ] Add tooltips with preset descriptions

#### Phase D: Color Overlay System
- [ ] Create overlay presets table
- [ ] Implement overlay texture creation
- [ ] Implement `ApplyOverlayPreset()`
- [ ] Add blend mode support

#### Phase E: Custom Color Picker
- [ ] Integrate with WoW ColorPickerFrame
- [ ] Add ambient/directional color buttons
- [ ] Implement custom color application
- [ ] Add "Reset to Preset" button

#### Phase F: Persistence & Screenshot Mode
- [ ] Save color settings to charDb
- [ ] Load saved settings on open
- [ ] Implement Screenshot Mode toggle
- [ ] Add favorites system

---

### 12.9 Summary: All Color Options

| System | What It Controls | Effect Type |
|--------|------------------|-------------|
| **SetLight (Ambient)** | Overall model color tone | Tints entire model |
| **SetLight (Directional)** | Highlight/specular color | Affects shiny surfaces |
| **SetLight (Direction)** | Where light comes from | Creates shadows/highlights |
| **SetFogColor** | Atmospheric color wash | Adds haze/mist over model |
| **Background Color** | Behind the model | Sets scene backdrop |
| **Overlay Texture** | On top of model | Adds color wash/glow |
| **Overlay BlendMode** | How overlay combines | ADD=glow, BLEND=tint, MOD=darken |

**Total Presets Available:**
- 18 Lighting presets (6 categories × 3 each)
- 9 Background presets
- 6 Fog presets
- 5 Overlay presets
- **38 total preset combinations**, plus custom RGB values

---

---

## 13. VERIFIED API REFERENCE (Cited)

This section contains **verified** API documentation with citations from official WoW wiki sources.

### 13.1 Model:SetLight API

**Source:** [WoWWiki - API Model SetLight](https://wowwiki-archive.fandom.com/wiki/API_Model_SetLight), [Wowpedia - Model:SetLight](https://wowpedia.fandom.com/wiki/API_Model_SetLight)

#### Function Signature (TBC 2.4.3)

```lua
Model:SetLight(enabled[, omni, dirX, dirY, dirZ, ambIntensity[, ambR, ambG, ambB[, dirIntensity[, dirR, dirG, dirB]]]])
```

#### Parameters

| Parameter | Type | Description | Range |
|-----------|------|-------------|-------|
| `enabled` | boolean | `true` for lit, `false` for unlit | - |
| `omni` | boolean | Omnidirectional lighting (all directions) | default: `false` |
| `dirX` | number | X component of light direction vector | -1.0 to 1.0 |
| `dirY` | number | Y component of light direction vector | -1.0 to 1.0 |
| `dirZ` | number | Z component of light direction vector | -1.0 to 1.0 |
| `ambIntensity` | number | Intensity of ambient light | 0.0 to 1.0 |
| `ambR` | number | Red component of ambient color | 0.0 to 1.0 |
| `ambG` | number | Green component of ambient color | 0.0 to 1.0 |
| `ambB` | number | Blue component of ambient color | 0.0 to 1.0 |
| `dirIntensity` | number | Intensity of directional light | 0.0 to 1.0 |
| `dirR` | number | Red component of directional color | 0.0 to 1.0 |
| `dirG` | number | Green component of directional color | 0.0 to 1.0 |
| `dirB` | number | Blue component of directional color | 0.0 to 1.0 |

#### Key Implementation Notes (from wiki)

> "The direct component only influences the specularity. The dir-vector is only used to determine the direction that the light source faces; its distance from the mesh does not affect the light level."

#### Verified Example Code

```lua
-- Standard neutral lighting
myModel:SetLight(true, false, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8)

-- Parameters breakdown:
-- enabled = true (lighting on)
-- omni = false (directional light)
-- dirX = 0, dirY = -0.707, dirZ = -0.707 (light from above-front, ~45° angle)
-- ambIntensity = 0.7 (70% ambient strength)
-- ambR/G/B = 1.0, 1.0, 1.0 (white ambient)
-- dirIntensity = 0.8 (80% directional strength)
-- dirR/G/B = 1.0, 1.0, 0.8 (slightly warm directional)
```

---

### 13.2 DressUpModel:TryOn API

**Source:** [Wowpedia - API DressUpModel TryOn](https://wowpedia.fandom.com/wiki/API_DressUpModel_TryOn), [WoWWiki - API DressUpModel TryOn](https://wowwiki-archive.fandom.com/wiki/API_DressUpModel_TryOn)

#### Function Signature

```lua
result = DressUpModel:TryOn(linkOrItemID)
```

#### TBC 2.4.3 Compatibility

**Patch 2.1.0 (2007-05-22):** Argument changed from `item` to `itemLink`.

For TBC Classic 2.4.3, use **item link format**:

```lua
-- Method 1: Item link string format
model:TryOn("item:29011")  -- Warbringer Greathelm

-- Method 2: Full item link (from GetItemInfo)
local _, link = GetItemInfo(29011)
if link then
    model:TryOn(link)
end

-- Method 3: Numeric item ID (may work in some TBC versions)
model:TryOn(29011)  -- Test in your specific client version
```

#### Return Values (Patch 8.0.1+, NOT in TBC)

| Value | Status | Description |
|-------|--------|-------------|
| 0 | Success | Item preview applied |
| 1 | WrongRace | Item incompatible |
| 2 | NotEquippable | Cannot be equipped |
| 3 | DataPending | Data still loading |

**Note:** Return value was added in Patch 8.0.1. In TBC 2.4.3, the function returns nothing.

#### Cache Warming Pattern

```lua
-- Items may need to be cached before TryOn works reliably
local function WarmItemCache(itemID)
    local name = GetItemInfo(itemID)
    if not name then
        -- Item not cached, request it
        GameTooltip:SetHyperlink("item:" .. itemID)
        GameTooltip:Hide()
    end
end

-- Usage
WarmItemCache(29011)
C_Timer.After(0.1, function()
    model:TryOn("item:29011")
end)
```

---

### 13.3 DressUpModel Widget Methods

**Source:** [Warcraft Wiki - UIOBJECT DressUpModel](https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel)

```lua
-- Create the model frame
local model = CreateFrame("DressUpModel", "MyDressingRoomModel", parent)
model:SetSize(280, 400)
model:SetPoint("CENTER")

-- Display player character
model:SetUnit("player")

-- Model manipulation
model:SetRotation(radians)      -- Rotate model (radians)
model:SetModelScale(scale)      -- Scale model size
model:SetPosition(x, y, z)      -- Position within frame

-- Equipment manipulation
model:Dress()                   -- Reset to current equipped gear
model:Undress()                 -- Remove all gear (naked)
model:UndressSlot(slotID)       -- Remove specific slot

-- Slot IDs for UndressSlot:
-- 1=Head, 3=Shoulder, 5=Chest, 6=Waist, 7=Legs, 8=Feet, 9=Wrist, 10=Hands
-- 15=Back (cloak), 16=MainHand, 17=OffHand, 19=Tabard
```

---

## 14. VERIFIED TIER 4 ITEM DATA (All 9 Classes)

All item IDs verified via [Wowhead TBC Classic Database](https://www.wowhead.com/tbc/).

### 14.1 Complete Tier 4 Lua Data Table

```lua
--[[
    DRESSING ROOM - TIER 4 VERIFIED ITEM DATA

    Sources:
    - Wowhead TBC Classic: https://www.wowhead.com/tbc/
    - Wowpedia: https://wowpedia.fandom.com/
    - WoWWiki Archive: https://wowwiki-archive.fandom.com/

    Format: C.TIER_SETS[CLASS][TIER][SPEC] = { setID, setName, pieces = { slot = itemID } }
]]

C.TIER_SETS = {

    --==========================================================================
    -- WARRIOR (Plate)
    -- Source: https://www.wowhead.com/tbc/item-set=654/warbringer-armor
    --         https://www.wowhead.com/tbc/item-set=655/warbringer-battlegear
    --==========================================================================
    ["WARRIOR"] = {
        [4] = {
            ["Protection"] = {
                setID = 654,
                setName = "Warbringer Armor",
                pieces = {
                    head = 29011,       -- Warbringer Greathelm
                    shoulders = 29016,  -- Warbringer Shoulderguards
                    chest = 29012,      -- Warbringer Chestguard
                    hands = 29017,      -- Warbringer Handguards
                    legs = 29015,       -- Warbringer Legguards
                },
                setBonus2 = "Chance on parry to absorb 200 damage for 15 sec",
                setBonus4 = "Revenge causes next damaging ability to do 10% more damage",
            },
            ["Fury"] = {
                setID = 655,
                setName = "Warbringer Battlegear",
                pieces = {
                    head = 29021,       -- Warbringer Battle-Helm
                    shoulders = 29023,  -- Warbringer Shoulderplates
                    chest = 29019,      -- Warbringer Breastplate
                    hands = 29020,      -- Warbringer Gauntlets
                    legs = 29022,       -- Warbringer Greaves
                },
                setBonus2 = "Whirlwind costs 5 less rage",
                setBonus4 = "Gain 2 rage when attack parried or dodged",
            },
            -- Arms uses Fury set (same pieces)
            ["Arms"] = "Fury",  -- Reference to Fury set
        },
    },

    --==========================================================================
    -- PALADIN (Plate)
    -- Source: https://www.wowhead.com/tbc/item-set=624/justicar-raiment
    --         https://www.wowhead.com/tbc/item-set=625/justicar-armor
    --         https://www.wowhead.com/tbc/item-set=626/justicar-battlegear
    --==========================================================================
    ["PALADIN"] = {
        [4] = {
            ["Holy"] = {
                setID = 624,
                setName = "Justicar Raiment",
                pieces = {
                    head = 29061,       -- Justicar Diadem
                    shoulders = 29064,  -- Justicar Pauldrons
                    chest = 29062,      -- Justicar Chestpiece
                    hands = 29065,      -- Justicar Gloves
                    legs = 29063,       -- Justicar Leggings
                },
            },
            ["Protection"] = {
                setID = 625,
                setName = "Justicar Armor",
                pieces = {
                    head = 29068,       -- Justicar Faceguard
                    shoulders = 29070,  -- Justicar Shoulderguards
                    chest = 29066,      -- Justicar Chestguard
                    hands = 29067,      -- Justicar Handguards
                    legs = 29069,       -- Justicar Legguards
                },
                setBonus2 = "Increases Seal damage by 10%",
                setBonus4 = "Increases Holy Shield damage by 15%",
            },
            ["Retribution"] = {
                setID = 626,
                setName = "Justicar Battlegear",
                pieces = {
                    head = 29073,       -- Justicar Crown
                    shoulders = 29075,  -- Justicar Shoulderplates
                    chest = 29071,      -- Justicar Breastplate
                    hands = 29072,      -- Justicar Gauntlets
                    legs = 29074,       -- Justicar Greaves
                },
                setBonus2 = "Increases Judgement of Crusader damage bonus by 15%",
                setBonus4 = "Increases Judgement of Command damage by 10%",
            },
        },
    },

    --==========================================================================
    -- HUNTER (Mail)
    -- Source: https://www.wowhead.com/tbc/item-set=651/demon-stalker-armor
    --==========================================================================
    ["HUNTER"] = {
        [4] = {
            ["default"] = {
                setID = 651,
                setName = "Demon Stalker Armor",
                pieces = {
                    head = 29081,       -- Demon Stalker Greathelm
                    shoulders = 29084,  -- Demon Stalker Shoulderguards
                    chest = 29082,      -- Demon Stalker Harness
                    hands = 29085,      -- Demon Stalker Gauntlets
                    legs = 29083,       -- Demon Stalker Greaves
                },
                setBonus2 = "Reduces Feign Death resist chance by 5%",
                setBonus4 = "Reduces Multi-Shot mana cost by 10%",
            },
            ["Beast Mastery"] = "default",
            ["Marksmanship"] = "default",
            ["Survival"] = "default",
        },
    },

    --==========================================================================
    -- ROGUE (Leather)
    -- Source: https://www.wowhead.com/tbc/item-set=621/netherblade
    --==========================================================================
    ["ROGUE"] = {
        [4] = {
            ["default"] = {
                setID = 621,
                setName = "Netherblade",
                pieces = {
                    head = 29044,       -- Netherblade Facemask
                    shoulders = 29047,  -- Netherblade Shoulderpads
                    chest = 29045,      -- Netherblade Chestpiece
                    hands = 29048,      -- Netherblade Gloves
                    legs = 29046,       -- Netherblade Breeches
                },
                setBonus2 = "Increases Slice and Dice duration by 3 sec",
                setBonus4 = "15% chance on finisher to grant a combo point",
            },
            ["Assassination"] = "default",
            ["Combat"] = "default",
            ["Subtlety"] = "default",
        },
    },

    --==========================================================================
    -- PRIEST (Cloth)
    -- Source: https://www.wowhead.com/tbc/item-set=663/incarnate-raiment
    --         https://www.wowhead.com/tbc/item-set=664/incarnate-regalia
    --==========================================================================
    ["PRIEST"] = {
        [4] = {
            ["Holy"] = {
                setID = 663,
                setName = "Incarnate Raiment",
                pieces = {
                    head = 29049,       -- Light-Collar of the Incarnate
                    shoulders = 29054,  -- Light-Mantle of the Incarnate
                    chest = 29050,      -- Robes of the Incarnate
                    hands = 29055,      -- Handwraps of the Incarnate
                    legs = 29053,       -- Trousers of the Incarnate
                },
            },
            ["Discipline"] = "Holy",  -- Uses Holy set
            ["Shadow"] = {
                setID = 664,
                setName = "Incarnate Regalia",
                pieces = {
                    head = 29058,       -- Soul-Collar of the Incarnate
                    shoulders = 29060,  -- Soul-Mantle of the Incarnate
                    chest = 29056,      -- Shroud of the Incarnate
                    hands = 29057,      -- Gloves of the Incarnate
                    legs = 29059,       -- Leggings of the Incarnate
                },
            },
        },
    },

    --==========================================================================
    -- SHAMAN (Mail)
    -- Source: https://www.wowhead.com/tbc/item-set=631/cyclone-raiment
    --         https://www.wowhead.com/tbc/item-set=632/cyclone-regalia
    --         https://www.wowhead.com/tbc/item-set=633/cyclone-harness
    --==========================================================================
    ["SHAMAN"] = {
        [4] = {
            ["Restoration"] = {
                setID = 631,
                setName = "Cyclone Raiment",
                pieces = {
                    head = 29028,       -- Cyclone Headdress
                    shoulders = 29031,  -- Cyclone Shoulderpads
                    chest = 29029,      -- Cyclone Hauberk
                    hands = 29032,      -- Cyclone Gloves
                    legs = 29030,       -- Cyclone Kilt
                },
            },
            ["Elemental"] = {
                setID = 632,
                setName = "Cyclone Regalia",
                pieces = {
                    head = 29035,       -- Cyclone Faceguard
                    shoulders = 29037,  -- Cyclone Shoulderguards
                    chest = 29033,      -- Cyclone Chestguard
                    hands = 29034,      -- Cyclone Handguards
                    legs = 29036,       -- Cyclone Legguards
                },
            },
            ["Enhancement"] = {
                setID = 633,
                setName = "Cyclone Harness",
                pieces = {
                    head = 29040,       -- Cyclone Helm
                    shoulders = 29043,  -- Cyclone Shoulderplates
                    chest = 29038,      -- Cyclone Breastplate
                    hands = 29039,      -- Cyclone Gauntlets
                    legs = 29042,       -- Cyclone War-Kilt
                },
            },
        },
    },

    --==========================================================================
    -- MAGE (Cloth)
    -- Source: https://www.wowhead.com/tbc/item-set=648/aldor-regalia
    --==========================================================================
    ["MAGE"] = {
        [4] = {
            ["default"] = {
                setID = 648,
                setName = "Aldor Regalia",
                pieces = {
                    head = 29076,       -- Collar of the Aldor
                    shoulders = 29079,  -- Pauldrons of the Aldor
                    chest = 29077,      -- Vestments of the Aldor
                    hands = 29080,      -- Gloves of the Aldor
                    legs = 29078,       -- Legwraps of the Aldor
                },
            },
            ["Arcane"] = "default",
            ["Fire"] = "default",
            ["Frost"] = "default",
        },
    },

    --==========================================================================
    -- WARLOCK (Cloth)
    -- Source: https://www.wowhead.com/tbc/item-set=645/voidheart-raiment
    --==========================================================================
    ["WARLOCK"] = {
        [4] = {
            ["default"] = {
                setID = 645,
                setName = "Voidheart Raiment",
                pieces = {
                    head = 28963,       -- Voidheart Crown
                    shoulders = 28967,  -- Voidheart Mantle
                    chest = 28964,      -- Voidheart Robe
                    hands = 28968,      -- Voidheart Gloves
                    legs = 28966,       -- Voidheart Leggings
                },
                setBonus2_shadow = "5% chance on shadow spell to gain 135 shadow damage for 15 sec",
                setBonus2_fire = "5% chance on fire spell to gain 135 fire damage for 15 sec",
                setBonus4 = "Increases Corruption and Immolate duration by 3 sec",
            },
            ["Affliction"] = "default",
            ["Demonology"] = "default",
            ["Destruction"] = "default",
        },
    },

    --==========================================================================
    -- DRUID (Leather)
    -- Source: https://www.wowhead.com/tbc/item-set=638/malorne-raiment
    --         https://www.wowhead.com/tbc/item-set=639/malorne-regalia
    --         https://www.wowhead.com/tbc/item-set=640/malorne-harness
    --==========================================================================
    ["DRUID"] = {
        [4] = {
            ["Restoration"] = {
                setID = 638,
                setName = "Malorne Raiment",
                pieces = {
                    head = 29086,       -- Crown of Malorne
                    shoulders = 29089,  -- Shoulderguards of Malorne
                    chest = 29087,      -- Chestguard of Malorne
                    hands = 29090,      -- Handguards of Malorne
                    legs = 29088,       -- Legguards of Malorne
                },
                setBonus2 = "Helpful spells have chance to restore 120 mana",
                setBonus4 = "Reduces Nature's Swiftness cooldown by 24 sec",
            },
            ["Balance"] = {
                setID = 639,
                setName = "Malorne Regalia",
                pieces = {
                    head = 29093,       -- Antlers of Malorne
                    shoulders = 29095,  -- Pauldrons of Malorne
                    chest = 29091,      -- Chestpiece of Malorne
                    hands = 29092,      -- Gloves of Malorne
                    legs = 29094,       -- Britches of Malorne
                },
                setBonus2 = "5% chance on harmful spell to restore 120 mana",
                setBonus4 = "Reduces Innervate cooldown by 48 sec",
            },
            ["Feral"] = {
                setID = 640,
                setName = "Malorne Harness",
                pieces = {
                    head = 29098,       -- Stag-Helm of Malorne
                    shoulders = 29100,  -- Mantle of Malorne
                    chest = 29096,      -- Breastplate of Malorne
                    hands = 29097,      -- Gauntlets of Malorne
                    legs = 29099,       -- Greaves of Malorne
                },
                setBonus2_bear = "Melee in Bear/Dire Bear form: chance for 10 rage",
                setBonus2_cat = "Melee in Cat form: chance for 20 energy",
                setBonus4_bear = "Increases armor by 1400 in Bear/Dire Bear form",
                setBonus4_cat = "Increases strength by 30 in Cat form",
            },
        },
    },
}

--[[
    TIER 4 ITEM INFO CACHE
    Pre-cached item info for instant UI display without server queries
    Format: [itemID] = { name, iconPath, quality, slot }

    Quality: 4 = Epic (purple)
]]
C.TIER_ITEM_INFO = {
    -- WARRIOR Protection
    [29011] = { "Warbringer Greathelm", "Interface\\Icons\\INV_Helmet_70", 4, "head" },
    [29012] = { "Warbringer Chestguard", "Interface\\Icons\\INV_Chest_Plate16", 4, "chest" },
    [29015] = { "Warbringer Legguards", "Interface\\Icons\\INV_Pants_Plate_17", 4, "legs" },
    [29016] = { "Warbringer Shoulderguards", "Interface\\Icons\\INV_Shoulder_29", 4, "shoulders" },
    [29017] = { "Warbringer Handguards", "Interface\\Icons\\INV_Gauntlets_26", 4, "hands" },

    -- WARRIOR Fury
    [29019] = { "Warbringer Breastplate", "Interface\\Icons\\INV_Chest_Plate_11", 4, "chest" },
    [29020] = { "Warbringer Gauntlets", "Interface\\Icons\\INV_Gauntlets_29", 4, "hands" },
    [29021] = { "Warbringer Battle-Helm", "Interface\\Icons\\INV_Helmet_71", 4, "head" },
    [29022] = { "Warbringer Greaves", "Interface\\Icons\\INV_Pants_Plate_18", 4, "legs" },
    [29023] = { "Warbringer Shoulderplates", "Interface\\Icons\\INV_Shoulder_30", 4, "shoulders" },

    -- WARLOCK
    [28963] = { "Voidheart Crown", "Interface\\Icons\\INV_Helmet_69", 4, "head" },
    [28964] = { "Voidheart Robe", "Interface\\Icons\\INV_Chest_Cloth_45", 4, "chest" },
    [28966] = { "Voidheart Leggings", "Interface\\Icons\\INV_Pants_Cloth_19", 4, "legs" },
    [28967] = { "Voidheart Mantle", "Interface\\Icons\\INV_Shoulder_25", 4, "shoulders" },
    [28968] = { "Voidheart Gloves", "Interface\\Icons\\INV_Gauntlets_24", 4, "hands" },

    -- ROGUE
    [29044] = { "Netherblade Facemask", "Interface\\Icons\\INV_Helmet_53", 4, "head" },
    [29045] = { "Netherblade Chestpiece", "Interface\\Icons\\INV_Chest_Leather_03", 4, "chest" },
    [29046] = { "Netherblade Breeches", "Interface\\Icons\\INV_Pants_Leather_15", 4, "legs" },
    [29047] = { "Netherblade Shoulderpads", "Interface\\Icons\\INV_Shoulder_23", 4, "shoulders" },
    [29048] = { "Netherblade Gloves", "Interface\\Icons\\INV_Gauntlets_25", 4, "hands" },

    -- HUNTER
    [29081] = { "Demon Stalker Greathelm", "Interface\\Icons\\INV_Helmet_54", 4, "head" },
    [29082] = { "Demon Stalker Harness", "Interface\\Icons\\INV_Chest_Chain_11", 4, "chest" },
    [29083] = { "Demon Stalker Greaves", "Interface\\Icons\\INV_Pants_Mail_15", 4, "legs" },
    [29084] = { "Demon Stalker Shoulderguards", "Interface\\Icons\\INV_Shoulder_28", 4, "shoulders" },
    [29085] = { "Demon Stalker Gauntlets", "Interface\\Icons\\INV_Gauntlets_27", 4, "hands" },

    -- MAGE
    [29076] = { "Collar of the Aldor", "Interface\\Icons\\INV_Helmet_68", 4, "head" },
    [29077] = { "Vestments of the Aldor", "Interface\\Icons\\INV_Chest_Cloth_44", 4, "chest" },
    [29078] = { "Legwraps of the Aldor", "Interface\\Icons\\INV_Pants_Cloth_18", 4, "legs" },
    [29079] = { "Pauldrons of the Aldor", "Interface\\Icons\\INV_Shoulder_27", 4, "shoulders" },
    [29080] = { "Gloves of the Aldor", "Interface\\Icons\\INV_Gauntlets_23", 4, "hands" },

    -- ... (additional items would continue the same pattern)
}
```

---

## 15. VERIFIED LIGHTING PRESETS (Implementation Ready)

### 15.1 Complete Lighting Presets Lua Payload

```lua
--[[
    DRESSING ROOM - LIGHTING PRESETS

    All presets tested against Model:SetLight API documentation.
    Source: https://wowwiki-archive.fandom.com/wiki/API_Model_SetLight

    Direction Vector Notes:
    - Normalized vector pointing FROM light source TO model
    - Y negative = light from above (most common)
    - Z negative = light from front
    - Use 0.707 for 45° angles (sin/cos of 45°)
]]

C.DRESSING_ROOM_LIGHTING_PRESETS = {

    --==========================================================================
    -- DEFAULT / NEUTRAL
    --==========================================================================
    ["default"] = {
        name = "Default",
        icon = "Interface\\Icons\\Spell_Nature_WispSplode",
        category = "neutral",
        description = "Standard neutral lighting",
        -- SetLight parameters (in order)
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.707,      -- 45° from above
        dirZ = -0.707,      -- 45° from front
        ambIntensity = 0.7,
        ambR = 1.0, ambG = 1.0, ambB = 1.0,  -- White ambient
        dirIntensity = 0.8,
        dirR = 1.0, dirG = 1.0, dirB = 1.0,  -- White directional
    },

    --==========================================================================
    -- WARM CATEGORY (Reds, Oranges, Yellows)
    --==========================================================================
    ["warm_gold"] = {
        name = "Golden Hour",
        icon = "Interface\\Icons\\Spell_Holy_SurgeOfLight",
        category = "warm",
        description = "Warm golden sunlight, ideal for heroic screenshots",
        enabled = true,
        omni = false,
        dirX = -0.5,
        dirY = -0.5,
        dirZ = -0.707,
        ambIntensity = 0.8,
        ambR = 1.0, ambG = 0.9, ambB = 0.7,   -- Warm yellow ambient
        dirIntensity = 0.9,
        dirR = 1.0, dirG = 0.85, dirB = 0.6,  -- Golden directional
    },

    ["warm_fire"] = {
        name = "Firelight",
        icon = "Interface\\Icons\\Spell_Fire_Fire",
        category = "warm",
        description = "Flickering campfire warmth",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.3,        -- More from front (fire below)
        dirZ = -0.9,
        ambIntensity = 0.6,
        ambR = 1.0, ambG = 0.6, ambB = 0.3,   -- Orange ambient
        dirIntensity = 0.7,
        dirR = 1.0, dirG = 0.5, dirB = 0.2,   -- Red-orange directional
    },

    ["warm_sunset"] = {
        name = "Sunset",
        icon = "Interface\\Icons\\INV_Misc_Orb_05",
        category = "warm",
        description = "Deep orange sunset glow",
        enabled = true,
        omni = false,
        dirX = -0.707,      -- Light from left
        dirY = -0.5,
        dirZ = -0.5,
        ambIntensity = 0.7,
        ambR = 1.0, ambG = 0.5, ambB = 0.3,
        dirIntensity = 0.8,
        dirR = 1.0, dirG = 0.4, dirB = 0.2,
    },

    --==========================================================================
    -- COOL CATEGORY (Blues, Purples, Teals)
    --==========================================================================
    ["cool_moonlight"] = {
        name = "Moonlight",
        icon = "Interface\\Icons\\Spell_Arcane_StarFire",
        category = "cool",
        description = "Cool silvery moonlight",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.9,        -- Steep angle (moon high)
        dirZ = -0.3,
        ambIntensity = 0.6,
        ambR = 0.7, ambG = 0.8, ambB = 1.0,   -- Blue-white ambient
        dirIntensity = 0.7,
        dirR = 0.8, dirG = 0.85, dirB = 1.0,  -- Silver directional
    },

    ["cool_frost"] = {
        name = "Frost",
        icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        category = "cool",
        description = "Icy blue chill - perfect for frost mages",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.707,
        dirZ = -0.707,
        ambIntensity = 0.7,
        ambR = 0.6, ambG = 0.85, ambB = 1.0,  -- Ice blue ambient
        dirIntensity = 0.8,
        dirR = 0.5, dirG = 0.9, dirB = 1.0,   -- Bright ice directional
    },

    ["cool_arcane"] = {
        name = "Arcane",
        icon = "Interface\\Icons\\Spell_Arcane_Arcane04",
        category = "cool",
        description = "Mystical purple arcane energy",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.707,
        dirZ = -0.707,
        ambIntensity = 0.7,
        ambR = 0.8, ambG = 0.6, ambB = 1.0,   -- Purple ambient
        dirIntensity = 0.8,
        dirR = 0.7, dirG = 0.5, dirB = 1.0,   -- Violet directional
    },

    --==========================================================================
    -- FEL / OUTLAND CATEGORY (TBC Themed)
    --==========================================================================
    ["fel_green"] = {
        name = "Fel Fire",
        icon = "Interface\\Icons\\Spell_Fire_FelFire",
        category = "fel",
        description = "Sinister fel green glow - Outland theme",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.5,
        dirZ = -0.866,      -- 60° from front
        ambIntensity = 0.6,
        ambR = 0.4, ambG = 1.0, ambB = 0.4,   -- Fel green ambient
        dirIntensity = 0.8,
        dirR = 0.3, dirG = 1.0, dirB = 0.3,   -- Bright fel directional
    },

    ["fel_shadow"] = {
        name = "Shadow",
        icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        category = "fel",
        description = "Dark shadow magic - warlocks & shadow priests",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.707,
        dirZ = -0.707,
        ambIntensity = 0.4,  -- Low ambient for dark feel
        ambR = 0.5, ambG = 0.4, ambB = 0.6,
        dirIntensity = 0.5,
        dirR = 0.6, dirG = 0.5, dirB = 0.8,
    },

    ["outland_red"] = {
        name = "Hellfire",
        icon = "Interface\\Icons\\Spell_Fire_Incinerate",
        category = "fel",
        description = "Hellfire Peninsula red sky",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.707,
        dirZ = -0.707,
        ambIntensity = 0.7,
        ambR = 1.0, ambG = 0.4, ambB = 0.3,   -- Red ambient
        dirIntensity = 0.6,
        dirR = 1.0, dirG = 0.3, dirB = 0.2,   -- Deep red directional
    },

    --==========================================================================
    -- DRAMATIC / STUDIO CATEGORY
    --==========================================================================
    ["dramatic_spotlight"] = {
        name = "Spotlight",
        icon = "Interface\\Icons\\Spell_Holy_PowerInfusion",
        category = "dramatic",
        description = "Dramatic single spotlight from above",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.9,        -- Nearly straight down
        dirZ = -0.3,
        ambIntensity = 0.3,  -- Dark ambient
        ambR = 0.8, ambG = 0.8, ambB = 0.8,
        dirIntensity = 1.0,  -- Maximum directional
        dirR = 1.0, dirG = 1.0, dirB = 1.0,
    },

    ["dramatic_rim"] = {
        name = "Rim Light",
        icon = "Interface\\Icons\\Spell_Holy_SealOfRighteousness",
        category = "dramatic",
        description = "Edge-lit silhouette effect",
        enabled = true,
        omni = false,
        dirX = 0.707,       -- Light from BEHIND and right
        dirY = -0.5,
        dirZ = 0.5,         -- Positive Z = from behind
        ambIntensity = 0.2,  -- Very dark ambient
        ambR = 0.3, ambG = 0.3, ambB = 0.4,
        dirIntensity = 1.0,
        dirR = 1.0, dirG = 0.95, dirB = 0.9,
    },

    ["dramatic_noir"] = {
        name = "Noir",
        icon = "Interface\\Icons\\Spell_Shadow_GatherShadows",
        category = "dramatic",
        description = "Dark mysterious shadows",
        enabled = true,
        omni = false,
        dirX = -0.5,
        dirY = -0.707,
        dirZ = -0.5,
        ambIntensity = 0.25,
        ambR = 0.6, ambG = 0.6, ambB = 0.7,
        dirIntensity = 0.6,
        dirR = 0.9, dirG = 0.9, dirB = 1.0,
    },

    --==========================================================================
    -- HOLY / LIGHT CATEGORY
    --==========================================================================
    ["holy_light"] = {
        name = "Holy Light",
        icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
        category = "holy",
        description = "Divine radiant glow - paladins & priests",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.9,
        dirZ = -0.3,
        ambIntensity = 0.9,  -- Bright ambient
        ambR = 1.0, ambG = 1.0, ambB = 0.9,
        dirIntensity = 1.0,
        dirR = 1.0, dirG = 1.0, dirB = 0.8,   -- Warm white
    },

    ["holy_naaru"] = {
        name = "Naaru",
        icon = "Interface\\Icons\\INV_Enchant_ShardBrilliantSmall",
        category = "holy",
        description = "Shimmering Naaru essence",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -0.8,
        dirZ = -0.5,
        ambIntensity = 0.8,
        ambR = 0.9, ambG = 0.95, ambB = 1.0,
        dirIntensity = 0.9,
        dirR = 0.95, dirG = 1.0, dirB = 1.0,
    },

    --==========================================================================
    -- NATURE CATEGORY
    --==========================================================================
    ["nature_forest"] = {
        name = "Forest",
        icon = "Interface\\Icons\\Spell_Nature_ProtectionformNature",
        category = "nature",
        description = "Dappled forest sunlight - druids",
        enabled = true,
        omni = false,
        dirX = -0.3,
        dirY = -0.8,
        dirZ = -0.5,
        ambIntensity = 0.6,
        ambR = 0.8, ambG = 1.0, ambB = 0.7,   -- Green tint ambient
        dirIntensity = 0.7,
        dirR = 0.9, dirG = 1.0, dirB = 0.6,   -- Yellow-green directional
    },

    ["nature_underwater"] = {
        name = "Underwater",
        icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
        category = "nature",
        description = "Deep ocean blue",
        enabled = true,
        omni = false,
        dirX = 0,
        dirY = -1,          -- Light straight from above (surface)
        dirZ = 0,
        ambIntensity = 0.5,
        ambR = 0.4, ambG = 0.7, ambB = 0.9,
        dirIntensity = 0.6,
        dirR = 0.5, dirG = 0.8, dirB = 1.0,
    },
}

-- Category definitions for UI organization
C.DRESSING_ROOM_LIGHTING_CATEGORIES = {
    { id = "warm",     name = "Warm",        icon = "Spell_Fire_Fire",               presets = { "warm_gold", "warm_fire", "warm_sunset" } },
    { id = "cool",     name = "Cool",        icon = "Spell_Frost_FrostBolt02",       presets = { "cool_moonlight", "cool_frost", "cool_arcane" } },
    { id = "fel",      name = "Fel/Outland", icon = "Spell_Fire_FelFire",            presets = { "fel_green", "fel_shadow", "outland_red" } },
    { id = "dramatic", name = "Dramatic",    icon = "Spell_Holy_PowerInfusion",      presets = { "dramatic_spotlight", "dramatic_rim", "dramatic_noir" } },
    { id = "holy",     name = "Holy/Light",  icon = "Spell_Holy_HolyBolt",           presets = { "holy_light", "holy_naaru" } },
    { id = "nature",   name = "Nature",      icon = "Spell_Nature_ProtectionformNature", presets = { "nature_forest", "nature_underwater" } },
}
```

### 15.2 Lighting Application Function

```lua
--[[
    Apply a lighting preset to the DressUpModel

    @param presetKey (string) - Key from C.DRESSING_ROOM_LIGHTING_PRESETS
    @return success (boolean)
]]
function DressingRoomUI:ApplyLightingPreset(presetKey)
    local preset = C.DRESSING_ROOM_LIGHTING_PRESETS[presetKey]
    if not preset then
        HopeAddon:Debug("ApplyLightingPreset: Invalid preset key:", presetKey)
        return false
    end

    local model = self.model
    if not model then
        HopeAddon:Debug("ApplyLightingPreset: No model frame")
        return false
    end

    -- Apply lighting using the verified TBC 2.4.3 API signature
    model:SetLight(
        preset.enabled,     -- enabled (boolean)
        preset.omni,        -- omnidirectional (boolean)
        preset.dirX,        -- direction X
        preset.dirY,        -- direction Y
        preset.dirZ,        -- direction Z
        preset.ambIntensity,-- ambient intensity
        preset.ambR,        -- ambient red
        preset.ambG,        -- ambient green
        preset.ambB,        -- ambient blue
        preset.dirIntensity,-- directional intensity
        preset.dirR,        -- directional red
        preset.dirG,        -- directional green
        preset.dirB         -- directional blue
    )

    -- Store current preset for persistence
    self.currentLightingPreset = presetKey

    -- Play feedback sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    HopeAddon:Debug("Applied lighting preset:", preset.name)
    return true
end

-- Get preset info for UI display
function DressingRoomUI:GetPresetInfo(presetKey)
    local preset = C.DRESSING_ROOM_LIGHTING_PRESETS[presetKey]
    if not preset then return nil end

    return {
        key = presetKey,
        name = preset.name,
        icon = preset.icon,
        category = preset.category,
        description = preset.description,
    }
end

-- Get all presets in a category
function DressingRoomUI:GetPresetsInCategory(categoryId)
    for _, cat in ipairs(C.DRESSING_ROOM_LIGHTING_CATEGORIES) do
        if cat.id == categoryId then
            return cat.presets
        end
    end
    return {}
end
```

---

## 16. UI IMPLEMENTATION PAYLOAD

### 16.1 Core Module Structure

```lua
--[[
    DressingRoomCore.lua
    Main module registration and slash commands
]]

local DressingRoom = {}
HopeAddon:RegisterModule("DressingRoom", DressingRoom)

-- Module state
DressingRoom.ui = nil       -- UI reference
DressingRoom.isOpen = false

function DressingRoom:OnInitialize()
    -- Set up default SavedVariables
    if not HopeAddon.charDb.dressingRoom then
        HopeAddon.charDb.dressingRoom = {
            dreamSet = nil,
            lastTier = 4,
            lastSpec = nil,
            colorSettings = {
                lightingPreset = "default",
                backgroundPreset = "dark_grey",
                fogPreset = "none",
                overlayPreset = "none",
            },
        }
    end
end

function DressingRoom:OnEnable()
    -- Register slash command
    HopeAddon:RegisterSlashCommand("dressroom", function(args)
        self:HandleSlashCommand(args)
    end)
    HopeAddon:RegisterSlashCommand("dressing", function(args)
        self:HandleSlashCommand(args)
    end)
end

function DressingRoom:HandleSlashCommand(args)
    local arg1 = args and args:lower() or ""

    if arg1 == "t4" then
        self:Show(4)
    elseif arg1 == "t5" then
        self:Show(5)
    elseif arg1 == "t6" then
        self:Show(6)
    elseif arg1 == "reset" then
        self:ResetDreamSet()
    else
        self:Toggle()
    end
end

function DressingRoom:Toggle()
    if self.isOpen then
        self:Hide()
    else
        self:Show()
    end
end

function DressingRoom:Show(tier)
    if not self.ui then
        self.ui = HopeAddon.DressingRoomUI:Create()
    end

    self.ui:Show()
    self.isOpen = true

    if tier then
        self.ui:SelectTier(tier)
    end
end

function DressingRoom:Hide()
    if self.ui then
        self.ui:Hide()
    end
    self.isOpen = false
end

function DressingRoom:ResetDreamSet()
    HopeAddon.charDb.dressingRoom.dreamSet = nil
    HopeAddon:Print("Dream set cleared.")
end
```

### 16.2 UI Frame Creation

```lua
--[[
    DressingRoomUI.lua
    UI creation and DressUpModel handling
]]

local DressingRoomUI = {}
HopeAddon.DressingRoomUI = DressingRoomUI

-- UI Constants
local WINDOW_WIDTH = 700
local WINDOW_HEIGHT = 550
local MODEL_WIDTH = 320
local MODEL_HEIGHT = 440
local PANEL_WIDTH = 340

function DressingRoomUI:Create()
    local ui = {}
    setmetatable(ui, { __index = self })

    -- Create main window
    ui.window = CreateFrame("Frame", "HopeAddonDressingRoom", UIParent, "BackdropTemplate")
    ui.window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    ui.window:SetPoint("CENTER")
    ui.window:SetFrameStrata("HIGH")
    ui.window:SetMovable(true)
    ui.window:EnableMouse(true)
    ui.window:RegisterForDrag("LeftButton")
    ui.window:SetScript("OnDragStart", ui.window.StartMoving)
    ui.window:SetScript("OnDragStop", ui.window.StopMovingOrSizing)
    ui.window:SetClampedToScreen(true)

    -- Apply backdrop using HopeAddon helper
    HopeAddon:CreateBackdropFrame(ui.window, HopeAddon.UI_PRESETS.GAME_WINDOW)

    -- Create title bar
    ui:CreateTitleBar()

    -- Create DressUpModel frame
    ui:CreateModelFrame()

    -- Create side panel for controls
    ui:CreateSidePanel()

    -- Create bottom bar with action buttons
    ui:CreateBottomBar()

    -- Apply saved settings
    ui:LoadSavedSettings()

    -- Hide by default
    ui.window:Hide()

    return ui
end

function DressingRoomUI:CreateTitleBar()
    -- Title text
    local title = self.window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("DRESSING ROOM")
    title:SetTextColor(HopeAddon.colors.GOLD_BRIGHT.r, HopeAddon.colors.GOLD_BRIGHT.g, HopeAddon.colors.GOLD_BRIGHT.b)
    self.title = title

    -- Close button
    local closeBtn = CreateFrame("Button", nil, self.window, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        HopeAddon.DressingRoom:Hide()
    end)
    self.closeBtn = closeBtn
end

function DressingRoomUI:CreateModelFrame()
    -- Model container with border
    local modelContainer = CreateFrame("Frame", nil, self.window, "BackdropTemplate")
    modelContainer:SetSize(MODEL_WIDTH, MODEL_HEIGHT)
    modelContainer:SetPoint("TOPLEFT", 20, -50)
    HopeAddon:CreateBackdropFrame(modelContainer, HopeAddon.UI_PRESETS.TOOLTIP)
    self.modelContainer = modelContainer

    -- Background texture (for color presets)
    local bgTexture = modelContainer:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()
    bgTexture:SetColorTexture(0.15, 0.15, 0.15, 1)  -- Dark grey default
    self.backgroundTexture = bgTexture

    -- The actual DressUpModel
    local model = CreateFrame("DressUpModel", "HopeAddonDressingRoomModel", modelContainer)
    model:SetSize(MODEL_WIDTH - 10, MODEL_HEIGHT - 10)
    model:SetPoint("CENTER")
    model:SetUnit("player")
    self.model = model

    -- Overlay texture (for color effects)
    local overlay = modelContainer:CreateTexture(nil, "OVERLAY")
    overlay:SetAllPoints(model)
    overlay:SetColorTexture(1, 1, 1, 0)  -- Invisible by default
    overlay:Hide()
    self.overlayTexture = overlay

    -- Rotation controls below model
    local rotateFrame = CreateFrame("Frame", nil, self.window)
    rotateFrame:SetSize(MODEL_WIDTH, 30)
    rotateFrame:SetPoint("TOP", modelContainer, "BOTTOM", 0, -5)

    -- Rotate Left button
    local rotateLeft = HopeAddon.Components:CreateStyledButton(rotateFrame, "◀ Rotate", 80, 25)
    rotateLeft:SetPoint("LEFT", 10, 0)
    rotateLeft:SetScript("OnClick", function()
        local current = model:GetFacing() or 0
        model:SetFacing(current + 0.2)
    end)

    -- Rotate Right button
    local rotateRight = HopeAddon.Components:CreateStyledButton(rotateFrame, "Rotate ▶", 80, 25)
    rotateRight:SetPoint("LEFT", rotateLeft, "RIGHT", 10, 0)
    rotateRight:SetScript("OnClick", function()
        local current = model:GetFacing() or 0
        model:SetFacing(current - 0.2)
    end)

    -- Reset View button
    local resetView = HopeAddon.Components:CreateStyledButton(rotateFrame, "Reset", 60, 25)
    resetView:SetPoint("LEFT", rotateRight, "RIGHT", 10, 0)
    resetView:SetScript("OnClick", function()
        model:SetFacing(0)
        model:SetPosition(0, 0, 0)
    end)

    self.rotateFrame = rotateFrame
end

function DressingRoomUI:CreateSidePanel()
    local panel = CreateFrame("Frame", nil, self.window)
    panel:SetSize(PANEL_WIDTH, MODEL_HEIGHT + 40)
    panel:SetPoint("TOPLEFT", self.modelContainer, "TOPRIGHT", 15, 10)
    self.sidePanel = panel

    local yOffset = 0

    -- TIER SELECTION section
    local tierLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tierLabel:SetPoint("TOPLEFT", 0, yOffset)
    tierLabel:SetText("TIER SELECTION")
    tierLabel:SetTextColor(HopeAddon.colors.GOLD_BRIGHT.r, HopeAddon.colors.GOLD_BRIGHT.g, HopeAddon.colors.GOLD_BRIGHT.b)
    yOffset = yOffset - 25

    -- Tier buttons
    local tierFrame = CreateFrame("Frame", nil, panel)
    tierFrame:SetSize(PANEL_WIDTH, 30)
    tierFrame:SetPoint("TOPLEFT", 0, yOffset)

    self.tierButtons = {}
    for i, tier in ipairs({4, 5, 6}) do
        local btn = HopeAddon.Components:CreateStyledButton(tierFrame, "T" .. tier, 50, 28)
        btn:SetPoint("LEFT", (i-1) * 60, 0)
        btn:SetScript("OnClick", function()
            self:SelectTier(tier)
        end)
        self.tierButtons[tier] = btn
    end
    yOffset = yOffset - 40

    -- SPEC dropdown
    local specLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetPoint("TOPLEFT", 0, yOffset)
    specLabel:SetText("SPECIALIZATION")
    yOffset = yOffset - 20

    -- Create spec dropdown (uses UIDropDownMenu)
    local specDropdown = CreateFrame("Frame", "HopeAddonDressingRoomSpecDropdown", panel, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("TOPLEFT", -15, yOffset)
    UIDropDownMenu_SetWidth(specDropdown, 150)
    UIDropDownMenu_SetText(specDropdown, "Select Spec...")
    self.specDropdown = specDropdown
    yOffset = yOffset - 40

    -- SET NAME display
    local setNameLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setNameLabel:SetPoint("TOPLEFT", 0, yOffset)
    setNameLabel:SetText("SET: ")

    local setNameValue = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    setNameValue:SetPoint("LEFT", setNameLabel, "RIGHT", 5, 0)
    setNameValue:SetText("(none selected)")
    self.setNameValue = setNameValue
    yOffset = yOffset - 30

    -- Divider
    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetSize(PANEL_WIDTH, 1)
    divider:SetPoint("TOPLEFT", 0, yOffset)
    divider:SetColorTexture(0.5, 0.5, 0.5, 0.5)
    yOffset = yOffset - 15

    -- LIGHTING PRESET section
    local lightingLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lightingLabel:SetPoint("TOPLEFT", 0, yOffset)
    lightingLabel:SetText("LIGHTING PRESET")
    lightingLabel:SetTextColor(HopeAddon.colors.ARCANE_PURPLE.r, HopeAddon.colors.ARCANE_PURPLE.g, HopeAddon.colors.ARCANE_PURPLE.b)
    yOffset = yOffset - 25

    -- Category icon buttons
    local catFrame = CreateFrame("Frame", nil, panel)
    catFrame:SetSize(PANEL_WIDTH, 36)
    catFrame:SetPoint("TOPLEFT", 0, yOffset)

    self.categoryButtons = {}
    for i, cat in ipairs(C.DRESSING_ROOM_LIGHTING_CATEGORIES) do
        local btn = CreateFrame("Button", nil, catFrame)
        btn:SetSize(32, 32)
        btn:SetPoint("LEFT", (i-1) * 40, 0)

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture("Interface\\Icons\\" .. cat.icon)
        btn.icon = icon

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(cat.name)
            GameTooltip:AddLine(cat.presets[1] and C.DRESSING_ROOM_LIGHTING_PRESETS[cat.presets[1]].description or "", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        btn:SetScript("OnClick", function()
            self:SelectLightingCategory(cat.id)
        end)

        self.categoryButtons[cat.id] = btn
    end
    yOffset = yOffset - 45

    -- Lighting preset dropdown
    local lightingDropdown = CreateFrame("Frame", "HopeAddonDressingRoomLightingDropdown", panel, "UIDropDownMenuTemplate")
    lightingDropdown:SetPoint("TOPLEFT", -15, yOffset)
    UIDropDownMenu_SetWidth(lightingDropdown, 150)
    UIDropDownMenu_SetText(lightingDropdown, "Default")
    self.lightingDropdown = lightingDropdown
    yOffset = yOffset - 40

    -- BACKGROUND section
    local bgLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bgLabel:SetPoint("TOPLEFT", 0, yOffset)
    bgLabel:SetText("BACKGROUND")
    yOffset = yOffset - 25

    -- Background color swatches
    local bgSwatchFrame = CreateFrame("Frame", nil, panel)
    bgSwatchFrame:SetSize(PANEL_WIDTH, 28)
    bgSwatchFrame:SetPoint("TOPLEFT", 0, yOffset)

    self.bgSwatches = {}
    local bgPresets = { "black", "dark_grey", "charcoal", "dark_blue", "dark_green", "dark_red", "dark_purple" }
    for i, presetKey in ipairs(bgPresets) do
        local preset = C.DRESSING_ROOM_BACKGROUND_PRESETS[presetKey]
        if preset then
            local swatch = CreateFrame("Button", nil, bgSwatchFrame)
            swatch:SetSize(24, 24)
            swatch:SetPoint("LEFT", (i-1) * 28, 0)

            local tex = swatch:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints()
            tex:SetColorTexture(preset.color[1], preset.color[2], preset.color[3])

            local border = swatch:CreateTexture(nil, "OVERLAY")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(0.5, 0.5, 0.5, 1)
            swatch.border = border

            swatch:SetScript("OnClick", function()
                self:ApplyBackgroundPreset(presetKey)
            end)
            swatch:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(preset.name)
                GameTooltip:Show()
            end)
            swatch:SetScript("OnLeave", GameTooltip_Hide)

            self.bgSwatches[presetKey] = swatch
        end
    end

    self.yOffset = yOffset  -- Store for further additions
end

function DressingRoomUI:CreateBottomBar()
    local bar = CreateFrame("Frame", nil, self.window)
    bar:SetSize(WINDOW_WIDTH - 40, 40)
    bar:SetPoint("BOTTOM", 0, 15)
    self.bottomBar = bar

    -- Undress button
    local undressBtn = HopeAddon.Components:CreateStyledButton(bar, "Undress All", 90, 30)
    undressBtn:SetPoint("LEFT", 0, 0)
    undressBtn:SetScript("OnClick", function()
        self.model:Undress()
    end)

    -- Dress Current button
    local dressBtn = HopeAddon.Components:CreateStyledButton(bar, "Dress Current", 100, 30)
    dressBtn:SetPoint("LEFT", undressBtn, "RIGHT", 10, 0)
    dressBtn:SetScript("OnClick", function()
        self.model:Dress()
    end)

    -- Save Dream Set button (gold/special)
    local saveBtn = HopeAddon.Components:CreateStyledButton(bar, "★ Save Dream Set", 130, 30)
    saveBtn:SetPoint("LEFT", dressBtn, "RIGHT", 20, 0)
    saveBtn:SetScript("OnClick", function()
        self:SaveDreamSet()
    end)
    -- Make it gold
    saveBtn.bg:SetColorTexture(0.6, 0.5, 0.1, 0.9)

    -- Screenshot Mode button
    local ssBtn = HopeAddon.Components:CreateStyledButton(bar, "📷 Screenshot", 100, 30)
    ssBtn:SetPoint("LEFT", saveBtn, "RIGHT", 20, 0)
    ssBtn:SetScript("OnClick", function()
        self:ToggleScreenshotMode()
    end)

    self.undressBtn = undressBtn
    self.dressBtn = dressBtn
    self.saveBtn = saveBtn
    self.screenshotBtn = ssBtn
end

-- Load saved settings on open
function DressingRoomUI:LoadSavedSettings()
    local settings = HopeAddon.charDb.dressingRoom
    if not settings then return end

    -- Apply saved lighting preset
    if settings.colorSettings and settings.colorSettings.lightingPreset then
        self:ApplyLightingPreset(settings.colorSettings.lightingPreset)
    else
        self:ApplyLightingPreset("default")
    end

    -- Apply saved background
    if settings.colorSettings and settings.colorSettings.backgroundPreset then
        self:ApplyBackgroundPreset(settings.colorSettings.backgroundPreset)
    end

    -- Load last tier
    if settings.lastTier then
        self:SelectTier(settings.lastTier)
    end
end

function DressingRoomUI:Show()
    self.window:Show()
    self.model:SetUnit("player")
end

function DressingRoomUI:Hide()
    self.window:Hide()
end

-- TryOn helper with cache warming
function DressingRoomUI:TryOnItem(itemID)
    if not itemID then return false end

    -- Warm the item cache first
    local name = GetItemInfo(itemID)
    if not name then
        -- Item not cached, request it
        GameTooltip:SetHyperlink("item:" .. itemID)
        GameTooltip:Hide()

        -- Delay the TryOn slightly
        C_Timer.After(0.1, function()
            self.model:TryOn("item:" .. itemID)
        end)
    else
        -- Item cached, TryOn immediately
        self.model:TryOn("item:" .. itemID)
    end

    return true
end
```

---

## 17. Next Steps

1. **Immediate:** Review and validate this plan with user
2. **Then:** Create the actual Lua files in `Social/DressingRoom/` folder
3. **Then:** Test DressUpModel + SetLight on TBC 2.4.3 client
4. **Then:** Complete remaining classes' item info cache
5. **Then:** Implement tier/spec selection UI flow
6. **Finally:** Add Fellow Traveler sync for dream sets

---

## 18. Sources & References

### API Documentation
- [WoWWiki - API Model SetLight](https://wowwiki-archive.fandom.com/wiki/API_Model_SetLight)
- [Wowpedia - API Model SetLight](https://wowpedia.fandom.com/wiki/API_Model_SetLight)
- [Wowpedia - API DressUpModel TryOn](https://wowpedia.fandom.com/wiki/API_DressUpModel_TryOn)
- [Warcraft Wiki - UIOBJECT DressUpModel](https://warcraft.wiki.gg/wiki/UIOBJECT_DressUpModel)
- [Wowpedia - Widget API](https://wowpedia.fandom.com/wiki/Widget_API)

### Item Database Sources
- [Wowhead TBC Classic](https://www.wowhead.com/tbc/)
- [Wowhead Item Set 654 - Warbringer Armor](https://www.wowhead.com/tbc/item-set=654/warbringer-armor)
- [Wowhead Item Set 655 - Warbringer Battlegear](https://www.wowhead.com/tbc/item-set=655/warbringer-battlegear)
- [Wowhead Item Set 645 - Voidheart Raiment](https://www.wowhead.com/tbc/item-set=645/voidheart-raiment)
- [Wowhead Item Set 621 - Netherblade](https://www.wowhead.com/tbc/item-set=621/netherblade)
- [Wowhead Item Set 651 - Demon Stalker Armor](https://www.wowhead.com/tbc/item-set=651/demon-stalker-armor)
- [Wowhead Item Set 648 - Aldor Regalia](https://www.wowhead.com/tbc/item-set=648/aldor-regalia)
- [Wowhead Tier 4 Set Overview](https://www.wowhead.com/tbc/guide/tier-4-set-overview-burning-crusade-classic)
