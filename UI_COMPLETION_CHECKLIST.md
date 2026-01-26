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
| `charDb.journal.bossKills` | ❌ Empty | COMBAT_LOG boss deaths |
| `charDb.stats.*` | ❌ Empty | Various events |
| `charDb.travelers.*` | ❌ Empty | Addon detection |
| `Constants.LEVEL_MILESTONES` | ✅ Populated | 18 milestones defined |
| `Constants.GAME_DEFINITIONS` | ✅ Populated | 6 games defined |
| `Constants.RAIDS_BY_TIER` | ✅ Populated | T4/T5/T6 raids defined |
| `Constants.ARMORY_PHASES` | ✅ Populated | Phase 1 data complete |

### Visual Asset Status
| Asset Type | Status | Notes |
|------------|--------|-------|
| Icon paths | ✅ All defined | 100+ icons in assets.icons |
| Textures | ✅ All defined | Parchment, borders, bars |
| Fonts | ✅ All defined | 4 fonts |
| Sounds | ✅ All defined | 12 sounds |
| Glow effects | ✅ All defined | 4 glow textures |
| Quality borders | ⚠️ Inline | Colors applied but no centralized function |
| Badge shine effects | ❌ Missing | No quality-tier overlays |

---

## Phase 1: Tab Structure - ALL COMPLETE ✅

### 1.1 Journey Tab ✅ COMPLETE
- [x] "YOU ARE PREPARED" summary header
- [x] Tier progress section (T4/T5/T6 bars)
- [x] Focus panel (current objectives)
- [x] Attunement summary
- [x] Reputation summary
- [x] "Your journey awaits..." placeholder if no entries
- [x] 3 variants: pre-60, leveling (60-67), endgame (68+)
- [x] Milestones merged into Journey timeline (Phase 23)

### 1.2 Reputation Tab ✅ COMPLETE
- [x] "FACTION STANDING" header
- [x] Aldor/Scryers choice card (if choice made)
- [x] Faction categories with Heroic Dungeon Keys (4 factions)
- [x] Each shows: faction icon, name, current standing, progress bar
- [x] Milestone tracking for faction standings

### 1.3 Raids Tab ✅ COMPLETE
- [x] Quick jump buttons: [T4] [T5] [T6]
- [x] T4 Section (collapsible): Karazhan, Gruul's Lair, Magtheridon's Lair
- [x] T5 Section (collapsible): Serpentshrine Cavern, Tempest Keep
- [x] T6 Section (collapsible): Mount Hyjal, Black Temple
- [x] Boss cards with progress bars and kill counts

### 1.4 Attunements Tab ✅ COMPLETE
- [x] "RAID ATTUNEMENTS" header
- [x] 6 attunement chains with chapter progress:
  - Karazhan [T4] - The Master's Key
  - SSC [T5] - The Serpent's Coil
  - TK [T5] - The Arcane Key
  - Hyjal [T5] - The Sands of Time
  - Black Temple [T6] - The Dark Portal
  - Cipher Vaults [T6] - The Cipher
- [x] Quest chain progress with prerequisites

### 1.5 Games Tab ✅ COMPLETE
- [x] "GAMES HALL" header
- [x] Game cards grid layout
- [x] 6 games: Tetris Battle, Pong, Death Roll, Words with WoW, Battleship, Dice/RPS
- [x] Each card: icon, title, description, [Practice] [Challenge] buttons
- [x] Game statistics and win/loss tracking

### 1.6 Social Tab ✅ COMPLETE
- [x] 3 sub-tabs: Feed, Travelers, Companions
- [x] **Feed sub-tab:**
  - Activity feed ("Tavern Notice Board")
  - Rumors (manual status posts)
  - Mug reactions
- [x] **Travelers sub-tab:**
  - Fellow Traveler directory with filters (all, online, party, lfrp)
  - Search and sort functionality
  - Stats summary: travelers known, addon users count
- [x] **Companions sub-tab:**
  - Favorites list with request/accept/decline flow
  - Online status tracking

### 1.7 Armory Tab ✅ COMPLETE
- [x] Phase-based gear upgrade advisor
- [x] Phase buttons: [P1] [P2] [P3] [P5] (Phase 4 hidden - catch-up raid)
- [x] Slot grid with gear recommendations by spec/role
- [x] BiS source indicators (raids, heroics, crafted, badge, reputation)
- [x] Phase 1 data fully populated (Karazhan, Gruul, Mag, Heroics, Badge, Rep)
- [x] Placeholder messages for Phase 2/3/5 data

### 1.8 Heroic Keys Tab ✅ COMPLETE
- [x] 5 reputation-gated dungeon keys
- [x] Progress bars showing current standing vs Revered requirement
- [x] Faction icons and dungeon names
- [x] Tips for reputation grinding

### 1.9 Stats Tab ✅ COMPLETE
- [x] "JOURNEY STATISTICS" header
- [x] Journey Began date, Total Playtime, Quests Completed
- [x] Dungeon Runs, Raid Bosses Slain, Deaths
- [x] Badges display by category
- [x] Boss kill tracker

---

## Phase 2: Visual Polish - Replace Text Indicators

### 2.1 Dropdown Arrow
**File:** `UI/Components.lua:1178`
**Current:** `arrow:SetText("▼")`

- [ ] Replace FontString with Texture
- [ ] Add rotation animation on expand/collapse

**Implementation:**
```lua
-- Replace FontString with Texture
local arrow = dropdown:CreateTexture(nil, "OVERLAY")
arrow:SetSize(16, 16)
arrow:SetPoint("RIGHT", dropdown, "RIGHT", -8, 0)
arrow:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
-- Alternative: Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up

-- Add rotation on toggle (requires tracking state)
dropdown.expanded = false
dropdown:SetScript("OnClick", function(self)
    self.expanded = not self.expanded
    if self.expanded then
        arrow:SetRotation(math.pi) -- 180 degrees
    else
        arrow:SetRotation(0)
    end
end)
```

**Dependencies:** None - standalone change

### 2.2 Collapsible Section Toggles
**File:** `UI/Components.lua:1426`
**Current:** `indicator:SetText(startExpanded and "[-]" or "[+]")`

- [ ] Replace "[+]"/"[-]" text with texture-based +/- buttons
- [ ] Update Toggle() function to swap textures

**Implementation:**
```lua
-- Replace FontString with Texture in CreateCollapsibleSection()
local indicator = header:CreateTexture(nil, "OVERLAY")
indicator:SetSize(16, 16)
indicator:SetPoint("LEFT", header, "LEFT", 8, 0)

-- Helper function for toggle state
local function UpdateIndicator(expanded)
    if expanded then
        indicator:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
    else
        indicator:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
    end
end

-- Initial state
UpdateIndicator(startExpanded)

-- In Toggle() function (~line 1535):
-- Add after: self.expanded = not self.expanded
UpdateIndicator(self.expanded)
```

**Alternative Textures:**
- `Interface\\Buttons\\UI-PlusButton-Disabled` (grayed out)
- `Interface\\Buttons\\UI-MinusButton-Disabled` (grayed out)

### 2.3 Checkbox/Radio Indicators
**File:** `UI/Components.lua` - CreateCheckboxWithLabel()

- [ ] Use texture-based check marks instead of FontString "✓"

**Implementation:**
```lua
-- In CreateCheckboxWithLabel() or wherever checkboxes are created
local checkmark = checkbox:CreateTexture(nil, "OVERLAY")
checkmark:SetSize(20, 20)
checkmark:SetPoint("CENTER", checkbox, "CENTER", 0, 0)
checkmark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
checkmark:Hide() -- Initially hidden

-- On check state change:
if checked then
    checkmark:Show()
else
    checkmark:Hide()
end

-- For disabled/locked state:
checkmark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
```

### 2.4 Progress Bar Completion ✅ COMPLETE
- [x] Add checkmark overlay when 100%
- [x] Apply gold border on completion
- [x] Trigger sparkle effect
- [x] Sound effect on completion

### 2.5 Locked/Unlocked State Indicators
**Files:** Any card creation (Journal.lua, Components.lua)

- [ ] Locked: Padlock icon + desaturated card
- [ ] Unlocked: Glowing border + full color

**Implementation:**
```lua
-- Add to card creation functions or as standalone helper
local function ApplyLockedState(card, isLocked)
    -- Create lock icon if doesn't exist
    if not card.lockIcon then
        card.lockIcon = card:CreateTexture(nil, "OVERLAY")
        card.lockIcon:SetSize(24, 24)
        card.lockIcon:SetPoint("TOPRIGHT", card, "TOPRIGHT", -4, -4)
        card.lockIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-LOCK")
    end

    if isLocked then
        card.lockIcon:Show()
        -- Desaturate the main icon
        if card.icon then
            card.icon:SetDesaturated(true)
            card.icon:SetAlpha(0.5)
        end
        -- Dim the entire card
        if card.SetAlpha then
            card:SetAlpha(0.7)
        end
    else
        card.lockIcon:Hide()
        -- Restore icon
        if card.icon then
            card.icon:SetDesaturated(false)
            card.icon:SetAlpha(1.0)
        end
        card:SetAlpha(1.0)
        -- Optional: Add glow on unlock
        HopeAddon.Effects:CreateBorderGlow(card, "GOLD_BRIGHT")
    end
end
```

**Usage in Journal.lua:**
```lua
-- When creating milestone/badge cards:
local isUnlocked = charDb.journal.levelMilestones[level] ~= nil
ApplyLockedState(card, not isUnlocked)
```

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
- [ ] Apply to: milestone cards, badge icons, traveler icons

### 3.3 ApplyQualityBorder Helper Function
**File:** `UI/Components.lua` (new function, add near other utility functions)

**Implementation:**
```lua
-- Quality color definitions (matches WoW item quality)
local QUALITY_COLORS = {
    COMMON = { r = 0.62, g = 0.62, b = 0.62 },
    UNCOMMON = { r = 0.12, g = 1.00, b = 0.00 },
    RARE = { r = 0.00, g = 0.44, b = 0.87 },
    EPIC = { r = 0.64, g = 0.21, b = 0.93 },
    LEGENDARY = { r = 1.00, g = 0.50, b = 0.00 },
}

-- Mapping to existing Glow.lua color names
local QUALITY_GLOW_COLORS = {
    EPIC = "ARCANE_PURPLE",
    LEGENDARY = "GOLD_BRIGHT",
}

function HopeAddon:ApplyQualityBorder(frame, quality)
    local color = QUALITY_COLORS[quality] or QUALITY_COLORS.COMMON

    -- Apply border color (if frame has backdrop)
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    end

    -- Stop any existing quality glows first
    HopeAddon.Effects:StopGlowsOnParent(frame)

    -- Add special effects for high quality
    if quality == "EPIC" then
        -- Subtle purple pulse using existing Effects system
        HopeAddon.Effects:CreateBorderGlow(frame, "ARCANE_PURPLE")
    elseif quality == "LEGENDARY" then
        -- Bright orange glow
        HopeAddon.Effects:CreatePulsingGlow(frame, "GOLD_BRIGHT", 0.8)

        -- Optional: Add shine overlay (if texture exists)
        if not frame.shineOverlay then
            frame.shineOverlay = frame:CreateTexture(nil, "OVERLAY", nil, 7)
            frame.shineOverlay:SetSize(frame:GetWidth() + 8, frame:GetHeight() + 8)
            frame.shineOverlay:SetPoint("CENTER")
            frame.shineOverlay:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            frame.shineOverlay:SetBlendMode("ADD")
            frame.shineOverlay:SetAlpha(0.3)
        end
        frame.shineOverlay:Show()
    else
        -- Hide shine overlay for lower qualities
        if frame.shineOverlay then
            frame.shineOverlay:Hide()
        end
    end

    return color
end

-- Convenience function to get quality color without applying
function HopeAddon:GetQualityColor(quality)
    return QUALITY_COLORS[quality] or QUALITY_COLORS.COMMON
end
```

### 3.4 Integration Points

**Badge Cards (Social/Badges.lua):**
```lua
-- In badge card creation or display
local badge = C.BADGES[badgeId]
local quality = badge.quality or "COMMON"
HopeAddon:ApplyQualityBorder(card, quality)
```

**Milestone Cards (Journal/Journal.lua):**
```lua
-- In milestone card creation
local milestone = C.LEVEL_MILESTONES[level]
local quality = milestone.quality or "UNCOMMON"
HopeAddon:ApplyQualityBorder(card, quality)
```

**Traveler Icons (Social/TravelerIcons.lua):**
```lua
-- When displaying earned icons
local iconDef = C.TRAVELER_ICONS[iconId]
local quality = iconDef.quality or "COMMON"
HopeAddon:ApplyQualityBorder(iconFrame, quality)
```

### 3.5 Dependencies
- **Effects.lua** - `CreateBorderGlow()` for EPIC effects, `CreatePulsingGlow()`, `StopGlowsOnParent()` for LEGENDARY effects
- **Glow.lua** - `CreateEpicGlow()` for animated EPIC effects (alternative)
- **Constants.lua** - Quality definitions in badge/milestone/icon data

---

## Phase 4: Missing Visual Components

### 4.1 Game Card Improvements
**File:** `UI/Components.lua` - CreateGameCard() or `Journal/Journal.lua`

- [ ] Add game-specific background texture/tint
- [ ] Add difficulty indicator (stars or text)
- [ ] Add "vs Player" / "vs AI" mode badges

**Implementation:**
```lua
-- Game theme definitions
local GAME_THEMES = {
    tetris = {
        bg = "Interface\\Icons\\INV_Misc_Dice_01",
        tint = {0.2, 0.6, 0.8, 0.15},  -- Light blue
        difficulty = 2  -- 1-3 stars
    },
    pong = {
        bg = "Interface\\Icons\\Ability_Rogue_Sprint",
        tint = {0.8, 0.8, 0.2, 0.15},  -- Yellow
        difficulty = 1
    },
    deathroll = {
        bg = "Interface\\Icons\\INV_Misc_Coin_17",
        tint = {0.9, 0.7, 0.2, 0.15},  -- Gold
        difficulty = 1
    },
    words = {
        bg = "Interface\\Icons\\INV_Misc_Book_09",
        tint = {0.6, 0.4, 0.2, 0.15},  -- Brown
        difficulty = 3
    },
    battleship = {
        bg = "Interface\\Icons\\Ability_Hunter_Snipershot",
        tint = {0.3, 0.5, 0.7, 0.15},  -- Navy blue
        difficulty = 2
    },
    dicerps = {
        bg = "Interface\\Icons\\INV_Misc_Dice_02",
        tint = {0.5, 0.5, 0.5, 0.15},  -- Gray
        difficulty = 1
    },
}

-- In game card creation:
local function EnhanceGameCard(card, gameId, gameDef)
    local theme = GAME_THEMES[gameId]
    if not theme then return end

    -- Background tint
    if not card.bgTint then
        card.bgTint = card:CreateTexture(nil, "BACKGROUND", nil, 1)
        card.bgTint:SetAllPoints()
    end
    card.bgTint:SetColorTexture(unpack(theme.tint))

    -- Mode badges (top-right corner)
    if not card.modeBadge then
        card.modeBadge = card:CreateFontString(nil, "OVERLAY")
        card.modeBadge:SetFont(HopeAddon.assets.fonts.BODY, 9, "OUTLINE")
        card.modeBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -4, -4)
    end

    local hasAI = gameDef.hasLocal
    local hasPvP = gameDef.hasRemote
    if hasAI and hasPvP then
        card.modeBadge:SetText("AI + PvP")
        card.modeBadge:SetTextColor(0.5, 1.0, 0.5)
    elseif hasAI then
        card.modeBadge:SetText("vs AI")
        card.modeBadge:SetTextColor(0.7, 0.7, 0.7)
    elseif hasPvP then
        card.modeBadge:SetText("PvP")
        card.modeBadge:SetTextColor(1.0, 0.5, 0.5)
    end

    -- Difficulty stars (bottom-left)
    if not card.difficultyText then
        card.difficultyText = card:CreateFontString(nil, "OVERLAY")
        card.difficultyText:SetFont(HopeAddon.assets.fonts.BODY, 10)
        card.difficultyText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 4, 4)
        card.difficultyText:SetTextColor(1, 0.82, 0)
    end
    local stars = string.rep("★", theme.difficulty) .. string.rep("☆", 3 - theme.difficulty)
    card.difficultyText:SetText(stars)
end
```

### 4.2 Traveler Portrait Frame
**File:** `UI/Components.lua` (new component)

- [ ] Create `CreateTravelerPortrait(parent, size)` component
- [ ] Show class icon as default
- [ ] Add Fellow Traveler badge overlay
- [ ] Add online/offline indicator

**Implementation:**
```lua
function HopeAddon:CreateTravelerPortrait(parent, size)
    size = size or 40

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)

    -- Portrait background (dark circle)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)

    -- Class icon (main portrait)
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(size - 4, size - 4)
    frame.icon:SetPoint("CENTER")
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim edges

    -- Portrait ring/border
    frame.ring = frame:CreateTexture(nil, "OVERLAY")
    frame.ring:SetSize(size + 4, size + 4)
    frame.ring:SetPoint("CENTER")
    frame.ring:SetTexture("Interface\\CHARACTERFRAME\\TempPortrait")

    -- Fellow Traveler badge (small addon icon overlay)
    frame.fellowBadge = frame:CreateTexture(nil, "OVERLAY", nil, 2)
    frame.fellowBadge:SetSize(14, 14)
    frame.fellowBadge:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
    frame.fellowBadge:SetTexture(HopeAddon.assets.icons.BOOK_OPEN)
    frame.fellowBadge:Hide()

    -- Online indicator (green/gray dot)
    frame.onlineIndicator = frame:CreateTexture(nil, "OVERLAY", nil, 3)
    frame.onlineIndicator:SetSize(10, 10)
    frame.onlineIndicator:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    frame.onlineIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
    frame.onlineIndicator:Hide()

    -- API methods
    function frame:SetClass(classToken)
        local iconPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
        local coords = CLASS_ICON_TCOORDS[classToken]
        if coords then
            self.icon:SetTexture(iconPath)
            self.icon:SetTexCoord(unpack(coords))
        else
            self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            self.icon:SetTexCoord(0, 1, 0, 1)
        end
    end

    function frame:SetFellow(isFellow)
        self.fellowBadge:SetShown(isFellow)
    end

    function frame:SetOnline(isOnline)
        self.onlineIndicator:Show()
        if isOnline then
            self.onlineIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
        else
            self.onlineIndicator:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        end
    end

    function frame:SetBorderColor(r, g, b)
        self.ring:SetVertexColor(r, g, b)
    end

    return frame
end
```

**Usage in Directory/Social tab:**
```lua
local portrait = HopeAddon:CreateTravelerPortrait(row, 36)
portrait:SetPoint("LEFT", row, "LEFT", 8, 0)
portrait:SetClass(traveler.class)
portrait:SetFellow(traveler.isFellow)
portrait:SetOnline(traveler.isOnline)
```

### 4.3 Boss Card Enhancements
**File:** `Journal/Journal.lua` - Boss card creation

- [ ] Add "SLAIN" stamp overlay for killed bosses
- [ ] Add kill count badge
- [ ] Add tier/phase badge

**Implementation:**
```lua
-- Add SLAIN stamp overlay
local function AddSlainStamp(card, killCount)
    if killCount and killCount > 0 then
        -- Create stamp if doesn't exist
        if not card.slainStamp then
            card.slainStamp = card:CreateTexture(nil, "OVERLAY", nil, 7)
            card.slainStamp:SetSize(64, 32)
            card.slainStamp:SetPoint("CENTER", card, "CENTER", 0, 0)
            -- Use WoW's checkmark with red tint and rotation for "SLAIN" effect
            card.slainStamp:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            card.slainStamp:SetVertexColor(0.8, 0.2, 0.2, 0.7) -- Red tint
            card.slainStamp:SetRotation(math.rad(-15)) -- Slight diagonal angle
        end
        card.slainStamp:Show()

        -- Kill count badge (bottom-right)
        if not card.killBadge then
            card.killBadge = card:CreateFontString(nil, "OVERLAY")
            card.killBadge:SetFont(HopeAddon.assets.fonts.HEADER, 14, "OUTLINE")
            card.killBadge:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -4, 4)
            card.killBadge:SetTextColor(1, 0.82, 0) -- Gold
        end
        card.killBadge:SetText("x" .. killCount)
        card.killBadge:Show()
    else
        -- Hide stamps for unkilled bosses
        if card.slainStamp then card.slainStamp:Hide() end
        if card.killBadge then card.killBadge:Hide() end
    end
end

-- Add tier badge (top-left corner)
local function AddTierBadge(card, tier)
    if not card.tierBadge then
        card.tierBadge = card:CreateFontString(nil, "OVERLAY")
        card.tierBadge:SetFont(HopeAddon.assets.fonts.BODY, 10, "OUTLINE")
        card.tierBadge:SetPoint("TOPLEFT", card, "TOPLEFT", 4, -4)
    end

    local tierColors = {
        T4 = {0.4, 0.8, 0.4},  -- Green
        T5 = {0.4, 0.6, 1.0},  -- Blue
        T6 = {0.8, 0.4, 1.0},  -- Purple
    }
    local color = tierColors[tier] or {0.7, 0.7, 0.7}
    card.tierBadge:SetText("[" .. tier .. "]")
    card.tierBadge:SetTextColor(unpack(color))
end

-- Usage in boss card creation:
local killCount = charDb.journal.bossKills[bossName] or 0
AddSlainStamp(bossCard, killCount)
AddTierBadge(bossCard, "T4")
```

### 4.4 Attunement Chain Visualization
**File:** `Journal/Journal.lua` - Attunements tab

- [ ] Add connecting lines between chapters
- [ ] Show chapter icons in horizontal row
- [ ] Highlight current/completed chapters

**Implementation:**
```lua
-- Create horizontal chapter chain visualization
local function CreateAttunementChainVisual(parent, attunementData, progressData)
    local chain = CreateFrame("Frame", nil, parent)
    chain:SetSize(parent:GetWidth() - 20, 40)

    local chapters = attunementData.chapters
    local numChapters = #chapters
    local spacing = (chain:GetWidth() - 30) / (numChapters - 1)

    -- Track chapter frames for connecting lines
    local chapterFrames = {}

    for i, chapter in ipairs(chapters) do
        local chapterFrame = CreateFrame("Frame", nil, chain)
        chapterFrame:SetSize(24, 24)

        -- Position horizontally
        local xOffset = (i - 1) * spacing
        chapterFrame:SetPoint("LEFT", chain, "LEFT", 15 + xOffset, 0)

        -- Chapter icon (checkmark for completed, current icon for active, gray for locked)
        local icon = chapterFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()

        local isCompleted = progressData.chapters[chapter.questId]
        local isCurrent = false -- Determine based on prerequisites

        if isCompleted then
            icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            icon:SetVertexColor(0.2, 1.0, 0.2) -- Green
        elseif isCurrent then
            icon:SetTexture(chapter.icon or "Interface\\Icons\\INV_Misc_Note_01")
            icon:SetVertexColor(1, 1, 1) -- Full color
            -- Add glow effect for current chapter
            HopeAddon.Effects:CreateBorderGlow(chapterFrame, "GOLD_BRIGHT")
        else
            icon:SetTexture(chapter.icon or "Interface\\Icons\\INV_Misc_Note_01")
            icon:SetDesaturated(true)
            icon:SetAlpha(0.5)
        end

        -- Chapter number label
        local numLabel = chapterFrame:CreateFontString(nil, "OVERLAY")
        numLabel:SetFont(HopeAddon.assets.fonts.BODY, 9, "OUTLINE")
        numLabel:SetPoint("BOTTOM", chapterFrame, "TOP", 0, 2)
        numLabel:SetText(i)

        -- Tooltip on hover
        chapterFrame:EnableMouse(true)
        chapterFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(chapter.name, 1, 1, 1)
            if chapter.description then
                GameTooltip:AddLine(chapter.description, 0.8, 0.8, 0.8, true)
            end
            GameTooltip:Show()
        end)
        chapterFrame:SetScript("OnLeave", GameTooltip_Hide)

        chapterFrames[i] = chapterFrame

        -- Draw connecting line to previous chapter
        if i > 1 then
            local line = chain:CreateTexture(nil, "BACKGROUND")
            line:SetHeight(2)
            line:SetPoint("LEFT", chapterFrames[i-1], "RIGHT", 2, 0)
            line:SetPoint("RIGHT", chapterFrame, "LEFT", -2, 0)

            -- Color based on completion
            local prevCompleted = progressData.chapters[chapters[i-1].questId]
            if prevCompleted and isCompleted then
                line:SetColorTexture(0.2, 1.0, 0.2, 1.0) -- Green
            elseif prevCompleted then
                line:SetColorTexture(1.0, 0.82, 0, 1.0) -- Gold (in progress)
            else
                line:SetColorTexture(0.3, 0.3, 0.3, 1.0) -- Gray (locked)
            end
        end
    end

    return chain
end
```

### 4.5 Dependencies for Phase 4
- **Effects.lua** - `CreateBorderGlow()` for current chapter highlight, various glow effects
- **Glow.lua** - `CreateEpicGlow()` for animated effects (alternative)
- **Constants.lua** - `CLASS_ICON_TCOORDS`, attunement data, game definitions
- **Frame Pools** - Should integrate with existing pools for memory efficiency

---

## Phase 5: Asset Additions Needed

### 5.1 Asset Priority Tiers

**Tier 1: Use WoW Built-in (No Custom Art Needed)**

These assets can be achieved using existing WoW textures:

| Need | WoW Asset | Path | Notes |
|------|-----------|------|-------|
| Padlock | LFG Lock | `Interface\\LFGFrame\\UI-LFG-ICON-LOCK` | Perfect fit |
| Checkmark | Ready Check | `Interface\\RAIDFRAME\\ReadyCheck-Ready` | Green checkmark |
| Plus/Minus toggle | UI Buttons | `Interface\\Buttons\\UI-PlusButton-UP` | Collapsible sections |
| Dropdown arrow | Scroll Button | `Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up` | Dropdown menus |
| Difficulty stars | Pet Battle | `Interface\\PetBattles\\PetBattle-Quality-*` | 1-5 quality stars |
| Portrait ring | Character Frame | `Interface\\CHARACTERFRAME\\TempPortrait` | Traveler portraits |
| Glow overlay | Spell Activation | `Interface\\SpellActivationOverlay\\IconAlert` | Quality shine |
| X mark | Ready Check | `Interface\\RAIDFRAME\\ReadyCheck-NotReady` | Failed/declined states |

**Tier 2: Can Substitute with WoW Assets (Lower Priority for Custom)**

| Original Need | WoW Substitute | Implementation |
|---------------|----------------|----------------|
| "SLAIN" stamp | ReadyCheck-Ready | Apply red tint (`SetVertexColor(0.8, 0.2, 0.2)`) + rotation (`SetRotation(math.rad(-15))`) |
| "COMPLETE" stamp | ReadyCheck-Ready | Apply green tint + rotation, or use as-is |
| Badge shine | IconAlert | Use with `SetBlendMode("ADD")` and low alpha |
| Game backgrounds | ColorTexture | Use `SetColorTexture(r, g, b, 0.15)` with theme colors |
| Boss portrait frame | TempPortrait | Combine with class icon texcoords |
| Chain connector lines | ColorTexture | Simple `CreateTexture()` with `SetColorTexture()` |

**Tier 3: Truly Custom (Lowest Priority)**

Only create custom assets if the substitutes prove inadequate:

| Asset | Why Custom Might Be Needed |
|-------|---------------------------|
| Attunement chain fancy connectors | If simple lines look too plain |
| Themed game card backgrounds | If color tints don't convey theme well enough |
| Branded stamps (SLAIN/COMPLETE text) | If checkmark rotation isn't clear enough |

### 5.2 Comprehensive WoW Built-in Asset Reference

**Buttons & Controls:**
```lua
-- Plus/Minus buttons
"Interface\\Buttons\\UI-PlusButton-UP"
"Interface\\Buttons\\UI-PlusButton-DOWN"
"Interface\\Buttons\\UI-PlusButton-Disabled"
"Interface\\Buttons\\UI-MinusButton-UP"
"Interface\\Buttons\\UI-MinusButton-DOWN"

-- Scroll buttons (good for dropdowns)
"Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up"
"Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down"
"Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up"

-- Checkboxes
"Interface\\Buttons\\UI-CheckBox-Check"
"Interface\\Buttons\\UI-CheckBox-Check-Disabled"
```

**Status Indicators:**
```lua
-- Ready check marks
"Interface\\RAIDFRAME\\ReadyCheck-Ready"      -- Green checkmark
"Interface\\RAIDFRAME\\ReadyCheck-NotReady"   -- Red X
"Interface\\RAIDFRAME\\ReadyCheck-Waiting"    -- Yellow question mark

-- Lock icon
"Interface\\LFGFrame\\UI-LFG-ICON-LOCK"
```

**Portrait & Frames:**
```lua
-- Portrait masks and rings
"Interface\\CHARACTERFRAME\\TempPortrait"
"Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
"Interface\\MINIMAP\\UI-Minimap-Background"

-- Class icons (spritesheet)
"Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
-- Use CLASS_ICON_TCOORDS[classToken] for texcoords
```

**Quality & Glow Effects:**
```lua
-- Spell activation glow (excellent for legendary shine)
"Interface\\SpellActivationOverlay\\IconAlert"

-- Pet battle quality stars
"Interface\\PetBattles\\PetBattle-Quality-Common"
"Interface\\PetBattles\\PetBattle-Quality-Uncommon"
"Interface\\PetBattles\\PetBattle-Quality-Rare"
"Interface\\PetBattles\\PetBattle-Quality-Epic"
"Interface\\PetBattles\\PetBattle-Quality-Legendary"
```

**Backgrounds & Borders:**
```lua
-- Tiling backgrounds (scale properly)
"Interface\\DialogFrame\\UI-DialogBox-Background"       -- Light tan
"Interface\\DialogFrame\\UI-DialogBox-Background-Dark"  -- Dark tan
"Interface\\Tooltips\\UI-Tooltip-Background"            -- Charcoal

-- Borders (use with backdrop system)
"Interface\\DialogFrame\\UI-DialogBox-Border"
"Interface\\DialogFrame\\UI-DialogBox-Gold-Border"
```

### 5.3 Creating Substitute Textures Programmatically

**Color Texture Creation:**
```lua
-- Instead of loading an image, create a colored texture
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.2, 0.4, 0.6, 0.3)  -- RGBA
```

**Tinting Existing Textures:**
```lua
-- Take any texture and tint it
local stamp = frame:CreateTexture(nil, "OVERLAY")
stamp:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
stamp:SetVertexColor(0.8, 0.2, 0.2, 0.8)  -- Red tint
stamp:SetRotation(math.rad(-15))           -- Diagonal angle
```

**Additive Blending for Glows:**
```lua
local shine = frame:CreateTexture(nil, "OVERLAY", nil, 7)
shine:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
shine:SetBlendMode("ADD")  -- Additive blending for glow effect
shine:SetAlpha(0.3)        -- Subtle effect
```

### 5.4 Implementation Priority Order

1. **Tier 1 (Use Immediately):** Replace text indicators with built-in textures
2. **Tier 2 (Evaluate):** Test WoW substitutes; only create custom if inadequate
3. **Tier 3 (Defer):** Custom art is nice-to-have, not blocking

**Recommended Order:**
1. Plus/Minus buttons for collapsibles (Phase 2.2)
2. Dropdown arrows (Phase 2.1)
3. Lock icons for locked content (Phase 2.5)
4. Quality border colors and glows (Phase 3)
5. SLAIN stamp substitute (Phase 4.3)
6. Portrait frames (Phase 4.2)
7. Chain connectors (Phase 4.4)
8. Custom assets (if needed)

---

## Phase 6: Demo Data Mode ✅ COMPLETE

### 6.1 Sample Data Commands
```lua
/hope demo  -- Populate with sample data
/hope reset demo  -- Clear sample data
```

Sample data includes:
- [x] 6 level milestones (5, 10, 15, 20, 25, 30)
- [x] Stats (deaths, playtime, quests, creatures, largest hit)
- [x] 3 sample travelers (Thrall, Jaina, Sylvanas)
- [x] 1 Fellow Traveler with profile (Arthas)
- [x] 1 relationship note (Thrall)

### 6.2 Event Handlers Verified
- [x] PLAYER_LEVEL_UP → levelMilestones + entries
- [x] PLAYER_DEAD → stats.deaths + entries
- [x] QUEST_TURNED_IN → stats.questsCompleted + entries
- [x] TIME_PLAYED_MSG → stats.playtime
- [x] UPDATE_FACTION → reputation + entries
- [x] COMBAT_LOG (UNIT_DIED) → bossKills + entries

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
/run HopeAddon.Journal:SelectTab(2)  -- Reputation
/run HopeAddon.Journal:SelectTab(3)  -- Raids
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
| P0 | Fix empty tabs - ensure structure renders | Medium | Critical | ✅ Complete |
| P1 | Add sample data mode for testing | Low | High | ✅ Complete |
| Phase 1 | All tab implementations | High | Critical | ✅ Complete |
| P2 | Replace text arrows with textures | Low | Medium | 📋 Documented |
| P3 | Add quality tier visual treatment | Medium | High | 📋 Documented |
| P4 | Add locked/unlocked state visuals | Medium | High | 📋 Documented |
| P5 | Custom asset creation | High | Medium | 📋 Documented |

**Note:** Phases 2-5 now have detailed implementation guidance including code examples, file paths, and WoW asset references. See each phase section for copy-paste ready implementations.

---

## Recent Fixes

### Scroll Content Frame Width Fix (2026-01-19)
**File:** `UI/Components.lua:CreateScrollFrame`
**Issue:** Content frame width was calculated before SetAllPoints was applied, resulting in 0 width
**Fix:** Added OnSizeChanged handler to update content width when scroll frame is resized.

### Demo Data Mode (2026-01-19)
**File:** `Core/Core.lua`
**Commands:** `/hope demo` and `/hope reset demo`

### Tab Restructure (Phase 23-24)
- Milestones Tab merged into Journey timeline
- Zones Tab removed (exploration tracking simplified)
- Games and Social split into separate tabs
- Social tab now has 3 sub-tabs: Feed, Travelers, Companions

### Armory Tab Addition (Phase 58)
- Phase-based gear upgrade advisor
- Phase 1 data fully populated
- Spec/role detection for recommendations

---

## Notes

- All icon paths exist in WoW's default assets
- No custom textures need to be created initially
- Focus on using existing WoW textures creatively
- Quality tier effects can use existing glow system
- Test on TBC Classic 2.4.3 client specifically
- **Phase 2-5 Implementation:** Each section now includes:
  - Exact file paths and line numbers
  - Copy-paste ready Lua code examples
  - WoW texture paths verified for TBC Classic
  - Dependencies on existing utilities (Glow.lua, Effects.lua, etc.)
  - Integration points showing where to call new functions

---

**Document Created:** 2026-01-19
**Last Updated:** 2026-01-26
**Status:** Phase 1 Complete, Phase 2-5 Documented with Implementation Details
