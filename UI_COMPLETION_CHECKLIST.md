# HopeAddon UI Completion Checklist

## Overview

This document tracks what's needed to fully populate and render the Journal UI tabs with proper visual elements instead of blank/text-only content.

---

## Current State Assessment

### Data Layer Status
| Data Source | Populated | Source |
|------------|-----------|--------|
| `charDb.journal.entries` | ❌ Empty | Requires in-game events |
| `charDb.journal.levelMilestones` | ❌ Empty | PLAYER_LEVEL_UP events |
| `charDb.journal.zoneDiscoveries` | ❌ Empty | ZONE_CHANGED_NEW_AREA events |
| `charDb.journal.bossKills` | ❌ Empty | COMBAT_LOG boss deaths |
| `charDb.stats.*` | ❌ Empty | Various events |
| `charDb.travelers.*` | ❌ Empty | Addon detection |
| `Constants.LEVEL_MILESTONES` | ✅ Populated | 18 milestones defined |
| `Constants.ZONE_DISCOVERIES` | ✅ Populated | 8 zones defined |
| `Constants.GAME_DEFINITIONS` | ✅ Populated | 4 games defined |
| `Constants.RAIDS_BY_TIER` | ✅ Populated | T4/T5/T6 raids defined |

### Visual Asset Status
| Asset Type | Status | Notes |
|------------|--------|-------|
| Icon paths | ✅ All defined | 100+ icons in assets.icons |
| Textures | ✅ All defined | Parchment, borders, bars |
| Fonts | ✅ All defined | 4 fonts |
| Sounds | ✅ All defined | 12 sounds |
| Glow effects | ✅ All defined | 4 glow textures |
| Quality borders | ⚠️ Generic | Only TOOLTIP_BORDER used |
| Badge shine effects | ❌ Missing | No quality-tier overlays |

---

## Phase 1: Ensure Tabs Render Structure (Even Without Data)

### 1.1 Journey Tab - Must Show
- [ ] "YOU ARE PREPARED" summary header
- [ ] Tier progress section (T4/T5/T6 bars at 0%)
- [ ] Focus panel (current objectives)
- [ ] Attunement summary (all locked)
- [ ] Reputation summary (all at neutral)
- [ ] "Your journey awaits..." placeholder if no entries

### 1.2 Milestones Tab - Must Show
- [ ] "THE HERO'S JOURNEY" header with 0% progress bar
- [ ] Act I: The Awakening (levels 5,10,15,20) - all locked
- [ ] Act II: The Journey (levels 25-55) - all locked
- [ ] Act III: Through the Dark Portal (levels 58-70) - all locked
- [ ] Each milestone card shows: icon (desaturated), title, description, "LOCKED"

### 1.3 Zones Tab - Must Show
- [ ] "OUTLAND EXPLORATION" header
- [ ] All 8 zones in 2-column grid:
  - Hellfire Peninsula, Zangarmarsh, Terokkar Forest, Nagrand
  - Blade's Edge Mountains, Netherstorm, Shadowmoon Valley, Shattrath
- [ ] Undiscovered zones: 40% alpha, "???" text, level range shown
- [ ] Discovered zones: Full color, zone flavor text, discovery date

### 1.4 Reputation Tab - Must Show
- [ ] "FACTION STANDING" header
- [ ] Aldor/Scryers choice card (if choice made, otherwise hidden)
- [ ] Faction categories:
  - Heroic Dungeon Keys (4 factions)
  - Each shows: faction icon, name, current standing, progress bar

### 1.5 Raids Tab - Must Show
- [ ] Quick jump buttons: [T4] [T5] [T6]
- [ ] T4 Section (collapsible):
  - Karazhan (0/11 bosses) with progress bar
  - Gruul's Lair (0/2 bosses)
  - Magtheridon's Lair (0/1 bosses)
- [ ] T5 Section (collapsible):
  - Serpentshrine Cavern (0/6 bosses)
  - Tempest Keep (0/4 bosses)
- [ ] T6 Section (collapsible):
  - Mount Hyjal (0/5 bosses)
  - Black Temple (0/9 bosses)

### 1.6 Attunements Tab - Must Show
- [ ] "RAID ATTUNEMENTS" header
- [ ] For each attunement chain:
  - Karazhan [T4] - The Master's Key (0% progress)
  - SSC [T5] - The Serpent's Coil (0% progress)
  - TK [T5] - The Arcane Key (0% progress)
  - Hyjal [T5] - The Sands of Time (0% progress)
  - Black Temple [T6] - The Dark Portal (0% progress)
  - Cipher Vaults [T6] - The Cipher (0% progress)

### 1.7 Directory Tab - Must Show
- [ ] "GAMES HALL" collapsible section:
  - 3-column grid of game cards
  - Tetris Battle, Pong, Death Roll, Words with WoW
  - Each card: icon, title, description, [Practice] [Challenge] buttons
- [ ] "FELLOW TRAVELERS" section:
  - Stats summary: "0 travelers known, 0 use this addon"
  - Empty state: "No travelers encountered yet..."

### 1.8 Stats Tab - Must Show
- [ ] "JOURNEY STATISTICS" header
- [ ] Journey Began: [date or "Unknown"]
- [ ] Total Playtime: 0h 0m
- [ ] Quests Completed: 0
- [ ] Dungeon Runs: 0
- [ ] Raid Bosses Slain: 0
- [ ] Deaths: 0

---

## Phase 2: Visual Polish - Replace Text Indicators

### 2.1 Dropdown Arrow (Components.lua:1053)
- [ ] Replace "▼" text with `Interface\\Buttons\\UI-DropDown-Button` texture
- [ ] Add rotation animation on expand/collapse

### 2.2 Collapsible Section Toggles
- [ ] Replace "▼"/"▶" text with texture-based arrows
- [ ] Use `Interface\\Buttons\\UI-PlusButton-UP` (collapsed)
- [ ] Use `Interface\\Buttons\\UI-MinusButton-UP` (expanded)

### 2.3 Checkbox/Radio Indicators
- [ ] Use `Interface\\Buttons\\UI-CheckBox-Check` for checked state
- [ ] Use `Interface\\Buttons\\UI-CheckBox-Check-Disabled` for locked

### 2.4 Progress Bar Completion
- [ ] Add checkmark overlay when 100%
- [ ] Apply gold border on completion
- [ ] Trigger sparkle effect

### 2.5 Locked/Unlocked State Indicators
- [ ] Locked: Padlock icon + desaturated card
- [ ] Unlocked: Glowing border + full color

---

## Phase 3: Quality Tier Visual Treatment

### 3.1 Badge Quality Borders
| Quality | Border Color | Additional Effect |
|---------|--------------|-------------------|
| COMMON | Gray (0.62, 0.62, 0.62) | None |
| UNCOMMON | Green (0.12, 1.00, 0.00) | None |
| RARE | Blue (0.00, 0.44, 0.87) | None |
| EPIC | Purple (0.64, 0.21, 0.93) | Subtle glow pulse |
| LEGENDARY | Orange (1.00, 0.50, 0.00) | Shine effect + glow |

### 3.2 Implementation Tasks
- [ ] Create `ApplyQualityBorder(frame, quality)` helper
- [ ] Add glow pulse animation for EPIC items
- [ ] Add shine overlay texture for LEGENDARY items
- [ ] Apply to: milestone cards, zone cards, badge icons, traveler icons

---

## Phase 4: Missing Visual Components

### 4.1 Game Card Improvements
- [ ] Add game-specific background texture/tint
- [ ] Add difficulty indicator (stars or text)
- [ ] Add "vs Player" / "vs AI" badges

### 4.2 Traveler Portrait Frame
- [ ] Create `CreateTravelerPortrait(parent, size)` component
- [ ] Show class icon as default
- [ ] Add Fellow Traveler badge overlay

### 4.3 Boss Card Enhancements
- [ ] Add boss portrait background
- [ ] Add "SLAIN" stamp overlay for killed bosses
- [ ] Add kill count badge

### 4.4 Attunement Chain Visualization
- [ ] Add connecting lines between chapters
- [ ] Add chapter icons in horizontal row
- [ ] Highlight current chapter

---

## Phase 5: Asset Additions Needed

### 5.1 Custom Textures to Create/Source
| Asset | Size | Purpose |
|-------|------|---------|
| Badge shine overlay | 64x64 | Legendary item glow |
| Game card background | 200x110 | Games Hall cards |
| Boss portrait frame | 48x48 | Raid boss cards |
| Traveler portrait frame | 40x40 | Directory entries |
| Attunement chain connector | 16x32 | Chain visualization |
| Lock/padlock icon | 24x24 | Locked content |
| Stamp "SLAIN" | 64x32 | Boss kill overlay |
| Stamp "COMPLETE" | 64x32 | Attunement completion |

### 5.2 WoW Built-in Assets to Leverage
| WoW Asset | Path | Use For |
|-----------|------|---------|
| Padlock | `Interface\\LFGFrame\\UI-LFG-ICON-LOCK` | Locked content |
| Checkmark | `Interface\\RAIDFRAME\\ReadyCheck-Ready` | Completed items |
| Star rating | `Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Guild-Icon-*` | Difficulty |
| Portrait ring | `Interface\\CHARACTERFRAME\\TemporaryPortrait-*` | Traveler frames |
| Glow | `Interface\\SpellActivationOverlay\\IconAlert` | Quality effects |

---

## Phase 6: Default Data Population ✅ IMPLEMENTED

### 6.1 Add Sample/Demo Data Mode
For testing without playing the game:
```lua
/hope demo  -- Populate with sample data
/hope reset demo  -- Clear sample data
```

Sample data includes:
- [x] 6 level milestones (5, 10, 15, 20, 25, 30)
- [x] 3 zone discoveries (Hellfire, Zangarmarsh, Shattrath)
- [x] Stats (deaths, playtime, quests, creatures, largest hit)
- [x] 3 sample travelers (Thrall, Jaina, Sylvanas)
- [x] 1 Fellow Traveler with profile (Arthas)
- [x] 1 relationship note (Thrall)

### 6.2 Ensure Event Handlers Fire
Verify these events are registered and create entries:
- [ ] PLAYER_LEVEL_UP → levelMilestones + entries
- [ ] ZONE_CHANGED_NEW_AREA → zoneDiscoveries + entries
- [ ] PLAYER_DEAD → stats.deaths + entries
- [ ] QUEST_TURNED_IN → stats.questsCompleted + entries
- [ ] TIME_PLAYED_MSG → stats.playtime
- [ ] UPDATE_FACTION → reputation + entries
- [ ] COMBAT_LOG (UNIT_DIED) → bossKills + entries

---

## Verification Checklist

### Tab Rendering Test
Run these commands after `/hope`:
```lua
-- Check if tabs have content
/run local sc = HopeAddon.Journal.mainFrame.scrollContainer; print("Entries:", #sc.entries)

-- Check specific tab
/hope  -- Open journal
-- Click each tab and verify content appears

-- Force tab refresh
/run HopeAddon.Journal:SelectTab(1)  -- Journey
/run HopeAddon.Journal:SelectTab(2)  -- Milestones
/run HopeAddon.Journal:SelectTab(3)  -- Zones
-- etc.
```

### Visual Asset Test
```lua
-- Check if icons render
/run local icon = CreateFrame("Frame", nil, UIParent); icon:SetSize(40,40); icon:SetPoint("CENTER"); local t = icon:CreateTexture(); t:SetAllPoints(); t:SetTexture("Interface\\Icons\\INV_Misc_Book_09"); icon:Show()

-- Check if glow works
/run HopeAddon.Effects:Sparkles(UIParent, 2)
```

---

## Implementation Priority

| Priority | Task | Complexity | Impact | Status |
|----------|------|------------|--------|--------|
| P0 | Fix empty tabs - ensure structure renders | Medium | Critical | ✅ Fixed scroll content width |
| P1 | Add sample data mode for testing | Low | High | ✅ /hope demo implemented |
| P2 | Replace text arrows with textures | Low | Medium | Pending |
| P3 | Add quality tier visual treatment | Medium | High | Pending |
| P4 | Add locked/unlocked state visuals | Medium | High | Pending |
| P5 | Custom asset creation | High | Medium | Pending |

---

## Recent Fixes (2026-01-19)

### Scroll Content Frame Width Fix
**File:** `UI/Components.lua:CreateScrollFrame`
**Issue:** Content frame width was calculated before SetAllPoints was applied, resulting in 0 width
**Fix:** Added OnSizeChanged handler to update content width when scroll frame is resized:
```lua
scrollFrame:SetScript("OnSizeChanged", function(self, newWidth, newHeight)
    if newWidth and newWidth > 0 then
        content:SetWidth(newWidth)
    end
end)
```

### Demo Data Mode
**File:** `Core/Core.lua`
**Commands:**
- `/hope demo` - Populates sample data (milestones, zones, travelers, stats)
- `/hope reset demo` - Clears demo data

---

## Notes

- All icon paths exist in WoW's default assets
- No custom textures need to be created initially
- Focus on using existing WoW textures creatively
- Quality tier effects can use existing glow system
- Test on TBC Classic 2.4.3 client specifically

---

**Document Created:** 2026-01-19
**Last Updated:** 2026-01-19
**Status:** In Progress - P0/P1 Complete
