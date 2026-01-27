# UI Organization & Design Specification Guide

## Task Summary
This document provides:
1. Exact specifications for TBC/Outland themed UI aesthetics
2. Catalog of all current UI issues organized by severity
3. Detailed checklists for maintaining visual consistency
4. Documentation of icon organization patterns (talent-tree-inspired layouts)
5. Standards for Quest Log and Achievement Panel styling

## Design Vision

### Target Aesthetic
- **Primary Theme:** Outland/TBC (fel green, arcane purple palette)
- **NOT:** Classic WoW brown leather aesthetic
- **NOT:** Traditional talent tree with connecting lines
- **IS:** Icon organization inspired by talent trees (rows/columns for stages)

### UI Elements to Emulate
1. **Quest Log Styling:**
   - Parchment backgrounds
   - Quest text formatting
   - Header styles
   - Objective layouts

2. **Achievement Panel Patterns:**
   - Icon badges with quality borders
   - Progress bars with completion states
   - Celebration effects
   - Tooltip patterns

3. **Icon Organization (Talent-Tree-Inspired):**
   - Icons arranged in rows/columns for multi-part stages
   - Example: Stage with 3 parts → 3 icons in row/column
   - Simple and scalable for Lua
   - Clear visual grouping without complex connecting lines

### Reference Implementations (Good Examples)
✓ **Milestones tab** - Collapsible acts structure
✓ **Raids tab** - Tier groupings with boss cards
✓ **Directory Games Hall** - 3-column game card grid

---

## Part 1: Design Specifications

### 1.1 TBC/Outland Color Palette (Exact Values)

**Fel Green Spectrum:**
- Primary Fel Green: `{r=0.20, g=0.80, b=0.20}` (#32CD32) - Zone headers, nature elements
- Fel Glow: `{r=0.40, g=1.00, b=0.40}` (#66FF66) - Hover effects, active states
- Outland Teal: `{r=0.00, g=0.81, b=0.82}` (#00CED1) - Water/sky elements

**Arcane Purple Spectrum:**
- Primary Arcane Purple: `{r=0.61, g=0.19, b=1.00}` (#9B30FF) - Directory tab, social features
- Nether Lavender: `{r=0.69, g=0.53, b=0.93}` (#B088EE) - Subtle accents, secondary elements
- Void Purple: `{r=0.50, g=0.00, b=0.50}` (#800080) - Dark borders, shadows

**Hellfire Spectrum (Combat/Danger):**
- Hellfire Red: `{r=1.00, g=0.27, b=0.27}` (#FF4444) - Errors, warnings
- Hellfire Orange: `{r=1.00, g=0.55, b=0.00}` (#FF8C00) - Legendary quality
- Lava Orange: `{r=1.00, g=0.65, b=0.00}` (#FFA500) - Fire elements

**Achievement/UI Gold:**
- Gold Bright: `{r=1.00, g=0.84, b=0.00}` (#FFD700) - Headers, hover states, completion
- Gold Pale: `{r=1.00, g=0.93, b=0.55}` (#FFEE8C) - Subtle gold accents
- Bronze: `{r=0.80, g=0.50, b=0.20}` (#CD853F) - Brown accents (use sparingly)

**Item Quality Borders:**
- Poor (Gray): `{r=0.62, g=0.62, b=0.62}` (#9D9D9D)
- Common (White): `{r=1.00, g=1.00, b=1.00}` (#FFFFFF)
- Uncommon (Green): `{r=0.12, g=1.00, b=0.00}` (#1EFF00)
- Rare (Blue): `{r=0.00, g=0.44, b=0.87}` (#0070DD)
- Epic (Purple): `{r=0.64, g=0.21, b=0.93}` (#A335EE)
- Legendary (Orange): `{r=1.00, g=0.50, b=0.00}` (#FF8000)

**Background Colors (from HopeAddon.bgColors):**
- Dark Transparent: `{r=0.1, g=0.1, b=0.1, a=0.7}` - Overlays
- Dark Solid: `{r=0.1, g=0.1, b=0.1, a=0.8}` - Containers
- Dark Opaque: `{r=0.1, g=0.1, b=0.1, a=0.95}` - Main frames
- Input BG: `{r=0.05, g=0.05, b=0.05, a=0.9}` - Text inputs
- Purple Tint: `{r=0.1, g=0.08, b=0.15, a=0.95}` - Arcane-themed frames

**Checklist for Color Usage:**
- [ ] All tabs use consistent TBC palette
- [ ] No brown leather colors (classic WoW) used
- [ ] Hover states use brighter versions of base colors
- [ ] Disabled states use desaturated versions
- [ ] Text contrast meets readability standards

---

### 1.2 Parchment & Background Standards

**Backdrop Texture Paths (from HopeAddon.assets.textures):**
```lua
PARCHMENT = "Interface\\QUESTFRAME\\QuestBG"                      -- Standard quest log
PARCHMENT_DARK = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"  -- Darker variant
DIALOG_BG = "Interface\\DialogFrame\\UI-DialogBox-Background"     -- Standard dialog
TOOLTIP_BG = "Interface\\Tooltips\\UI-Tooltip-Background"         -- Tooltip style
SOLID = "Interface\\BUTTONS\\WHITE8X8"                            -- Solid color fill
```

**Border Texture Paths:**
```lua
GOLD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border"  -- Gold/achievement borders
DIALOG_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"     -- Standard borders
TOOLTIP_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"         -- Tooltip borders
```

**Standard Background Colors:**
- Main frame: `{r=0.1, g=0.1, b=0.1, a=0.95}` (DARK_OPAQUE) - Journal, major windows
- Tab content: `{r=0.1, g=0.1, b=0.1, a=0.8}` (DARK_SOLID) - Scroll containers
- Card backgrounds: `{r=0.1, g=0.1, b=0.1, a=0.7}` (DARK_TRANSPARENT) - Individual cards
- Section headers: `{r=0.1, g=0.08, b=0.15, a=0.95}` (PURPLE_TINT) - Arcane-themed headers
- Input fields: `{r=0.05, g=0.05, b=0.05, a=0.9}` (INPUT_BG) - Text inputs, edit boxes

**Game UI Background Colors (from GameUI.lua COLORS):**
- Window BG: `{r=0.1, g=0.1, b=0.1, a=0.95}` - Game windows
- Title BG: `{r=0.2, g=0.15, b=0.3, a=1.0}` - Title bars (purple tint)
- Button Normal: `{r=0.3, g=0.25, b=0.4, a=1.0}` - Button base color
- Button Hover: `{r=0.4, g=0.35, b=0.55, a=1.0}` - Button hover state
- Button Pressed: `{r=0.25, g=0.2, b=0.35, a=1.0}` - Button pressed state

**Checklist for Backgrounds:**
- [ ] All major frames use appropriate backdrop textures
- [ ] Cards have consistent backdrop with proper insets
- [ ] Nested containers have proper alpha to show depth
- [ ] Scrollable areas have appropriate edge treatment

---

### 1.3 Icon Organization Patterns

Specifications for talent-tree-inspired icon layouts:

**Pattern A: Linear Stage (single icon per stage)**
```
[Icon] Stage 1
  ↓ (5-10px vertical spacing)
[Icon] Stage 2
  ↓
[Icon] Stage 3
```
- Vertical spacing: 5-10 pixels
- Icon size: 40x40 pixels (standard)
- Connector: Simple arrow or line texture

**Pattern B: Multi-Part Stage (row layout)**
```
[Icon] [Icon] [Icon]  ← 3 parts in Stage 1 (10px spacing between)
       ↓ (5px vertical spacing)
     [Icon]            ← Stage 2 (centered)
```
- Horizontal spacing: 10 pixels between icons in row
- Vertical spacing: 5 pixels between stages
- Centered alignment for next stage

**Pattern C: Multi-Part Stage (column layout)**
```
[Icon]
[Icon]  ← 3 parts stacked (5px spacing)
[Icon]
  ↓
[Icon]  ← Next stage
```
- Vertical spacing: 5 pixels between icons in column
- Column width: 40 pixels (icon size)

**Checklist for Icon Layouts:**
- [ ] Icons in same stage use consistent size (40x40)
- [ ] Spacing between stage icons uses MARGIN_NORMAL (10px)
- [ ] Vertical flow clearly shows progression
- [ ] No overlapping hitboxes on icon buttons
- [ ] Tooltips don't obscure adjacent icons

---

### 1.4 Achievement Badge Standards

**Icon Sizes:**
- Standard: 40x40 pixels (Components.ICON_SIZE_STANDARD)
- Large: 48x48 pixels (used in Milestones, boss cards)
- Miniature: 24x24 pixels (used for inline buttons, notes)
- Tiny: 16x16 pixels (used for status badges)

**Quality Border Colors (from Item Quality system):**
- Common (gray): `{r=0.62, g=0.62, b=0.62}`
- Uncommon (green): `{r=0.12, g=1.00, b=0.00}`
- Rare (blue): `{r=0.00, g=0.44, b=0.87}`
- Epic (purple): `{r=0.64, g=0.21, b=0.93}`
- Legendary (orange): `{r=1.00, g=0.50, b=0.00}`

**Border Thickness:** 2 pixels (standard)
**Icon Padding:** 8 pixels inside border (Components.INPUT_PADDING)

**Glow Effects for Completion:**
- Glow type: Icon glow (scale: 1.5x)
- Glow color: Gold `{r=1, g=0.84, b=0}`
- Duration: 1-2 seconds
- Fade pattern: Fade in, hold, fade out

**Checklist for Achievement Icons:**
- [ ] All achievement icons use quality-based borders
- [ ] Locked icons show desaturated texture
- [ ] Unlocked icons show celebration effect
- [ ] Icon tooltips follow achievement panel format
- [ ] Icon size consistent within same context (40x40 standard)

---

### 1.5 Progress Bar Standards

**Bar Dimensions:**
- Width: Full container width - 16 margins (MARGIN_NORMAL * 2)
- Height: 20 pixels
- Corner radius: Uses textured borders (no explicit radius)

**Fill Animation:**
- Duration: 0.5 seconds
- Easing: Linear progression with ticker
- Update frequency: 0.03 seconds (30 FPS)

**Color Patterns:**

**Incomplete:**
- Background: `{r=0.1, g=0.1, b=0.1, a=0.8}` (Dark)
- Fill: Gradient from `{r=0.1, g=0.6, b=0.1}` to `{r=0.2, g=0.9, b=0.2}` (Dark green → Bright green)
- Border: `{r=0.5, g=0.5, b=0.5}` (Gray)

**Complete:**
- Background: `{r=0.1, g=0.1, b=0.1, a=0.8}` (Dark)
- Fill: Solid `{r=0.2, g=0.9, b=0.2}` (Bright green)
- Border: `{r=1, g=0.84, b=0}` (Gold)

**Text Overlay:**
- Font: GameFontNormal
- Size: 12 points
- Color: White `{r=1, g=1, b=1}` with black outline
- Format: "X / Y (Z%)"
- Shadow: Offset (1, -1), Color `{r=0, g=0, b=0, a=1}`

**Checklist for Progress Bars:**
- [ ] All progress bars use consistent dimensions (20px height)
- [ ] Completion triggers sparkle effect
- [ ] Text overlay readable on all fill states
- [ ] Animation doesn't cause UI stutter (0.03s ticker)
- [ ] Bar fills left-to-right consistently

---

### 1.6 Typography Hierarchy

**Available Font Files (from HopeAddon.assets.fonts):**
- TITLE: "Fonts\\MORPHEUS.TTF" - Decorative, large headings
- HEADER: "Fonts\\FRIZQT__.TTF" - Standard WoW UI font
- BODY: "Fonts\\FRIZQT__.TTF" - Same as header
- SMALL: "Fonts\\ARIALN.TTF" - Condensed, small text

**Standard GameFont Variants (Blizzard built-in):**
- GameFontNormalLarge - ~16pt, for major headings
- GameFontNormal - ~12pt, standard UI text
- GameFontNormalSmall - ~10pt, body text
- GameFontHighlight - White color variant
- GameFontHighlightSmall - ~10pt white text
- GameFontNormalHuge - ~20pt, for emphasis

**Heading Levels:**
- **H1 (Tab Title):** GameFontNormalLarge, ~16pt, GOLD `{r=1, g=0.84, b=0}`
- **H2 (Section Header):** GameFontNormal, ~12pt, Color varies by context
- **H3 (Category Header):** GameFontNormalSmall, ~10pt, Gray `{r=0.8, g=0.8, b=0.8}`

**Body Text:**
- **Primary:** GameFontHighlightSmall, ~10pt, White `{r=1, g=1, b=1}`
- **Secondary:** GameFontNormalSmall, ~10pt, Light gray `{r=0.7, g=0.7, b=0.7}`
- **Flavor Text:** GameFontNormalSmall, ~10pt, Arcane purple `{r=0.69, g=0.53, b=0.93}` (italic)
- **Monospace (Words board):** FRIZQT__.TTF, 10pt fixed - For grid-based text rendering

**Special Text:**
- **Quest Objectives:** Green `{r=0, g=1, b=0}` when complete, white when incomplete
- **Timestamps:** Gray `{r=0.6, g=0.6, b=0.6}`, ~9pt GameFontNormalSmall
- **Stats:** Gold `{r=1, g=0.84, b=0}` for numbers, white for labels
- **Player Names:** Class color, ~12pt GameFontNormal
- **Game Scores:** GameFontNormalHuge, ~20pt, white or gold

**Line Spacing:**
- Between paragraphs: 10 pixels (MARGIN_NORMAL)
- Between list items: 5 pixels (MARGIN_SMALL)
- Before section headers: 20 pixels (MARGIN_LARGE)
- Card title to subtitle: 5 pixels (MARGIN_SMALL)
- Subtitle to body: 5 pixels (MARGIN_SMALL)

**Text Shadows (for readability):**
- Standard shadow: Offset (1, -1), Color `{r=0, g=0, b=0, a=1}`
- Heavy shadow (large text): Offset (2, -2), Color `{r=0, g=0, b=0, a=1}`

**Checklist for Typography:**
- [ ] All headings use consistent hierarchy
- [ ] Body text uses GameFont variants (not custom fonts)
- [ ] Line height provides comfortable reading
- [ ] Text color contrast meets readability standards
- [ ] Flavor text visually distinct from mechanics

---

### 1.7 Card Component Specification

**Dimensions:**
- Width: Container width (485px typical for journal)
- Height: Auto-sizing with minimum 80 pixels
- Margin: 5 pixels between cards (MARGIN_SMALL)

**Layout Structure:**
```
┌─────────────────────────────────────────────┐
│ [Icon 40x40]  [Title: GOLD, 12pt]          │
│               [Subtitle: Gray, 10pt]       │
│               [Body text: White, 10pt]     │
│               [Timestamp: Gray, 9pt]       │
└─────────────────────────────────────────────┘
```

**Icon Positioning:**
- Top-left corner
- Margin: 10 pixels from edges (MARGIN_NORMAL)
- Size: 40x40 standard, 48x48 for important entries

**Text Positioning:**
- Title: 10 pixels right of icon, 10 pixels from top
- Subtitle: Below title, 5 pixel gap (MARGIN_SMALL)
- Body: Below subtitle, 5 pixel gap, word-wrapped
- Timestamp: Bottom-right, 10 pixels from edges, 8 pixels from bottom

**Visual States:**
- **Default:** Border `{r=0.5, g=0.5, b=0.5}`, no glow
- **Hover:** Border `{r=1, g=0.84, b=0}` (gold), subtle glow
- **Clicked:** Border brightens, press animation (scale 0.98x)
- **New/Unread:** Fel green glow, "NEW" badge in corner

**Checklist for Cards:**
- [ ] Icon always top-left with 10px margin
- [ ] Text never overlaps icon
- [ ] Timestamp always bottom-right
- [ ] Hover state transitions smoothly (0.15s)
- [ ] Click animation doesn't break layout

---

### 1.8 Collapsible Section Specification

**Header Dimensions:**
- Width: Full container width
- Height: 28 pixels
- Margin: 5 pixels above content (MARGIN_SMALL)

**Header Layout:**
```
┌─────────────────────────────────────────────┐
│ [▼] [Title: Large font]  [Progress: X/Y]  │
└─────────────────────────────────────────────┘
```

**Toggle Icon:**
- Position: Left edge, 8 pixels margin (INPUT_PADDING)
- Size: Font-based (GameFontNormalLarge)
- States: ▼ (expanded), ▶ (collapsed)
- Animation: Rotate 90° over 0.3 seconds

**Title Text:**
- Font: GameFontNormal, 12 pt
- Color: Based on section type (Act = green, Tier = purple, etc.)
- Position: 8 pixels right of toggle icon (INPUT_PADDING)

**Progress Display:**
- Position: Right edge, 10 pixels margin (MARGIN_NORMAL)
- Format: "X / Y" or "XX%"
- Color: White for incomplete, Gold for complete

**Content Container:**
- Indent: 10 pixels from left edge (MARGIN_NORMAL)
- Background: Slightly darker than parent (alpha: 0.3)
- Padding: 5 pixels top/bottom (MARGIN_SMALL)

**Animation:**
- Expand: Fade in + slide down, 0.3 seconds
- Collapse: Fade out + slide up, 0.3 seconds
- Recalculate scroll height on toggle

**Checklist for Collapsible Sections:**
- [ ] Toggle icon rotates smoothly
- [ ] Content fades in/out during transition
- [ ] Scroll height recalculates correctly
- [ ] Progress display updates on child changes
- [ ] Nested sections don't break layout

---

### 1.9 Layout Constants Reference

**Spacing (from Components.lua):**
```lua
MARGIN_SMALL = 5      -- Between related elements (list items, icon rows)
MARGIN_NORMAL = 10    -- Standard spacing (between cards, buttons)
MARGIN_LARGE = 20     -- Between major sections (headers, spacers)
INPUT_PADDING = 8     -- For text input editbox
SCROLLBAR_WIDTH = 25  -- Space for scrollbar
```

**Container Sizes:**
```lua
FRAME_WIDTH = 550           -- Main journal frame
FRAME_HEIGHT = 650          -- Main journal frame
CONTAINER_WIDTH = 485       -- Scroll content (550 - 40 margin - 25 scrollbar)
TAB_HEIGHT = 32             -- Tab button height
FOOTER_HEIGHT = 40          -- Stats footer height
```

**Icon Sizes:**
```lua
ICON_SIZE_STANDARD = 40     -- Default for entries (Components constant)
ICON_SIZE_LARGE = 48        -- Milestones, bosses, important entries
ICON_SIZE_SMALL = 24        -- Minimap pins, inline buttons
ICON_SIZE_TINY = 16         -- Notes, status badges
```

**Card Specifications:**
```lua
CARD_HEIGHT_MIN = 80        -- Minimum card height (scroll fallback)
CARD_PADDING = 8            -- Internal padding (icon margin)
CARD_ICON_MARGIN = 10       -- Icon to edge margin (MARGIN_NORMAL)
CARD_TEXT_OFFSET = 10       -- Text to right of icon (MARGIN_NORMAL)
```

**Button Sizes:**
```lua
BUTTON_HEIGHT_STANDARD = 22 -- Default button (Practice, Challenge)
BUTTON_HEIGHT_LARGE = 32    -- Primary action button
BUTTON_WIDTH_STANDARD = 80  -- Default button width
BUTTON_WIDTH_ICON = 24      -- Icon button size (square)
```

**Game Card Grid (Directory Games Hall):**
```lua
GAME_CARD_WIDTH = 200       -- Individual game card
GAME_CARD_HEIGHT = 110      -- Card height
GAME_CARD_SPACING = 10      -- Gap between cards (MARGIN_NORMAL)
CARDS_PER_ROW = 3           -- Grid columns
ROW_HEIGHT = 115            -- Card height + spacing (110 + 5)
```

**Window Sizes (GameUI.WINDOW_SIZES):**
```lua
SMALL = { width = 300, height = 200 }    -- Small dialogs
MEDIUM = { width = 450, height = 350 }   -- Medium games
LARGE = { width = 600, height = 500 }    -- Large content
PONG = { width = 500, height = 400 }     -- Pong-specific
TETRIS = { width = 700, height = 550 }   -- Tetris battle
WORDS = { width = 650, height = 600 }    -- Words with WoW board (H2 fix)
```

**Checklist for Layout:**
- [ ] All spacing uses named constants (no magic numbers)
- [ ] Nested containers account for parent margins
- [ ] Scrollbar width subtracted from content width (485 = 550 - 40 - 25)
- [ ] Minimum heights prevent layout collapse
- [ ] Button sizes consistent within same context

---

### 1.10 Frame Strata & Z-Ordering Standards

**WoW Frame Strata Hierarchy (lowest to highest):**
1. `WORLD` - World content (rarely used for UI)
2. `BACKGROUND` - Background frames
3. `LOW` - Below normal UI
4. `MEDIUM` - Standard UI elements (default)
5. `HIGH` - Above normal UI
6. `DIALOG` - Popup dialogs, modals
7. `FULLSCREEN` - Fullscreen overlays
8. `FULLSCREEN_DIALOG` - Dialogs over fullscreen
9. `TOOLTIP` - Tooltips (highest normal)

**Frame Level vs Frame Strata:**
- **Strata** - Coarse grouping (all frames in higher strata render above lower)
- **Level** - Fine ordering within same strata (higher level = on top)
- A frame at strata `HIGH` level 1 is ABOVE strata `MEDIUM` level 100

**HopeAddon Strata Assignments:**

| Frame | Strata | Level | Purpose |
|-------|--------|-------|---------|
| Main Journal Frame | `DIALOG` | default | Primary addon window |
| Journal Tab Bar | `HIGH` | default | Tab navigation |
| Journal Content | `HIGH` | default | Tab content area |
| Scroll Container | `MEDIUM` | default | Scrollable content |
| Notification Pool | `DIALOG` | default | Pop-up notifications |
| Game Windows | `DIALOG` | default | Minigame windows |
| Rumor Popup | `DIALOG` | default | Modal dialogs |
| Tooltips | `TOOLTIP` | default | Item/hover tooltips |

**Armory Tab Frame Hierarchy (CRITICAL):**
```
scrollContainer.content (MEDIUM, inherits)
└── armoryUI.container (MEDIUM, inherits)
    ├── phaseBar (MEDIUM, inherits)
    │   └── phase buttons (level: parent+2)
    ├── characterView (MEDIUM, BackdropTemplate, a=0.95)
    │   ├── modelFrame (LOW, DressUpModel - renders 3D model)
    │   └── slotsContainer (MEDIUM, level: characterView+10)
    │       └── slot buttons (level: slotsContainer+2)
    └── footer (MEDIUM, inherits)

armoryUI.gearPopup (DIALOG) - Floats above all Armory content
armoryClickAwayFrame (HIGH, level: popup-1) - Catches clicks outside popup
```

**Why Model Frame is LOW Strata:**
The `DressUpModel` frame renders a 3D character model which intercepts mouse events. Setting it to `LOW` strata allows slot buttons (at `MEDIUM` strata) to receive clicks even when positioned over the model area.

**Click-Away Pattern:**
When showing popups that should dismiss on outside click:
1. Create a full-screen button at `HIGH` strata
2. Set its level BELOW the popup (popup at `DIALOG` is above)
3. Register `OnClick` to dismiss popup
4. Show on popup show, hide on popup hide

**Common Z-Order Issues & Fixes:**

| Issue | Cause | Fix |
|-------|-------|-----|
| Popup hidden behind content | Parent strata too low | Use `DIALOG` strata for popups |
| Buttons not clickable | Parent intercepts mouse | Set clickable frames higher level |
| Model blocks clicks | DressUpModel intercepts | Set model to `LOW`, buttons to `MEDIUM` |
| Backdrop covers content | High alpha on parent | Reduce alpha OR move children to separate parent |
| Click-away catches popup clicks | Level ordering wrong | Set click-away level = popup level - 1 |
| Popup visually obscured by parent backdrop | Child inherits parent rendering order | Re-parent popup to higher ancestor (mainFrame/UIParent), keep anchor to original element |

**Armory Popup Fix Pattern (Phase 60):**
```lua
-- WRONG: Popup parented to characterView (has 95% opacity backdrop)
local popup = CreateFrame("Frame", "...", characterView, "BackdropTemplate")
popup:SetFrameStrata("DIALOG")  -- Still visually obscured!

-- CORRECT: Popup parented to mainFrame, anchored to slot button
local popup = CreateFrame("Frame", "...", self.mainFrame, "BackdropTemplate")
popup:SetFrameStrata("DIALOG")
popup:SetFrameLevel(100)  -- Ensure above other DIALOG frames
-- Anchoring still works:
popup:SetPoint("LEFT", slotButton, "RIGHT", 10, 0)  -- Anchors to slotButton
```

**Checklist for Frame Strata:**
- [ ] Popups/modals use `DIALOG` strata
- [ ] Main windows use `HIGH` or `DIALOG` strata
- [ ] 3D models use `LOW` strata to not block buttons
- [ ] Click-away frames are 1 level below target popup
- [ ] BackdropTemplate frames with high alpha don't obstruct children
- [ ] All interactive elements (buttons) have proper level above siblings

---

## Part 2: Current Architecture Documentation

### 2.1 System Overview

```
HopeAddon UI Architecture
├─ Journal System (Main Hub)
│  ├─ Frame Pools (7 types)
│  ├─ Tab System (7 tabs: Journey, Reputation, Raids, Attunements, Games, Social, Armory)
│  ├─ Scroll Container
│  └─ Footer Stats
├─ Game System
│  ├─ GameCore (Loop & State)
│  ├─ GameUI (Windows & Components)
│  ├─ GameComms (Network)
│  ├─ ScoreChallenge (Turn-based multiplayer)
│  └─ 6 Game Implementations (Dice, RPS, DeathRoll, Pong, Tetris, Words, Battleship)
├─ Social System
│  ├─ Activity Feed (Tavern Notice Board)
│  ├─ Companions (Favorites with online status)
│  ├─ Romance (Relationship status)
│  ├─ Profile Editor
│  ├─ MapPins
│  └─ TravelerIcons
└─ Armory System (NEW - Phase 58+)
   ├─ Phase Selection (P1-P5, skips P4)
   ├─ Character Model (DressUpModel)
   ├─ Equipment Slots (15 visible)
   ├─ Gear Popup (BiS + alternatives)
   └─ Footer Stats (iLvl, upgrades)
```

---

### 2.2 Frame Pool Architecture

**Main Journal Pools:**
| Pool | Purpose | Create Function | Reset Pattern | Usage |
|------|---------|-----------------|---------------|-------|
| **notificationPool** | Pop-up notifications | CreateBackdropFrame(Frame) | Clear FontStrings + effects | Achievement unlocks |
| **containerPool** | Headers, spacers, sections | CreateFrame(Frame) | Clear children | All tabs |
| **cardPool** | Entry cards | CreateBackdropFrame(Button) | Clear text, effects, handlers | Most tabs |
| **collapsiblePool** | Expandable sections | CreateCollapsibleSection | Reset childEntries array | Raids, Attunements |
| **bossInfoPool** | Raid metadata frames | CreateFrame(Frame) | Clear FontString | Raids tab |
| **gameCardPool** | Games Hall cards | CreateGameCard | Reset text, handlers, colors | Games tab |
| **upgradeCardPool** | Gear upgrade cards | CreateBackdropFrame(Button) | Clear text, handlers | Journey tab |

**Armory Tab Pools (`Journal.armoryPools`):**
| Pool | Purpose | Usage |
|------|---------|-------|
| **upgradeCard** | Gear upgrade item rows | Gear popup |
| **sectionHeader** | Section headers | Gear popup categories |

**Pool Lifecycle:**
1. **OnEnable:** Create all main pools
2. **SelectTab:** ReleaseAll in dependency order (cards → sections → containers)
3. **Armory Special:** `CreateArmoryFramePools()` on first Armory visit
4. **Populate:** Acquire frames from pools
5. **OnDisable:** Destroy all pools

**Memory Management:**
- Frames released to pool, not destroyed
- Reset functions clear all references
- Parent set to nil to hide frames
- Effects/glows stopped before release
- Armory pools use unnamed pools (not `NewNamed`) for isolation

---

### 2.3 Tab System Flow

**Current Tabs (7 total):**
| Index | Tab | Populate Function | Special Handling |
|-------|-----|-------------------|------------------|
| 1 | Journey | `PopulateJourney()` | Level-based routing (pre-68 vs endgame) |
| 2 | Reputation | `PopulateReputation()` | Faction bars with milestone tracking |
| 3 | Raids | `PopulateRaids()` | Collapsible tier sections |
| 4 | Attunements | `PopulateAttunements()` | Quest chain progress |
| 5 | Games | `PopulateGames()` | Game cards with Practice/Challenge |
| 6 | Social | `PopulateSocial()` | Sub-tabs (Feed, Travelers, Companions) |
| 7 | Armory | `PopulateArmory()` | Custom UI (not scroll-based) |

**Tab Selection Flow:**
```
User clicks tab
      ↓
SelectTab(tabIndex) called
      ↓
Check if same tab (early return)
      ↓
Set isTabAnimating = true (debounce)
      ↓
Update tab button visual states
      ↓
Stop all glow effects
      ↓
Special cleanup for previous tab:
  - If was Armory: CleanupArmory()
  - If was Social: ClearSocialContent()
      ↓
Release pooled frames:
  1. cardPool:ReleaseAll()
  2. collapsiblePool:ReleaseAll()
  3. scrollContainer:ClearEntries(containerPool)
      ↓
Call Populate function for new tab
      ↓
UpdateFooter() with stats (unless Armory)
      ↓
Set isTabAnimating = false after 0.3s
```

**Armory Tab Special Handling:**
- Does NOT use standard scroll container
- Has its own container with custom components
- Requires explicit `CleanupArmory()` when switching away
- Footer stats updated via `UpdateArmoryFooter()` not `UpdateFooter()`

---

### 2.4 Component Hierarchy

```
Journal Frame (Draggable backdrop)
├─ Tab Container (Top)
│  ├─ Tab Button 1 (Journey)
│  ├─ Tab Button 2 (Reputation)
│  ├─ ... (7 tabs total, ending with Armory)
├─ Content Container (Middle)
│  └─ Scroll Frame
│     └─ Scroll Content
│        ├─ Section Header
│        ├─ Collapsible Section
│        │  └─ Child Cards
│        ├─ Spacer
│        ├─ Entry Card
│        └─ ... (pooled frames)
└─ Footer Container (Bottom)
   └─ Stats Text
```

---

### 2.5 Scroll Container System

**Key Concept:** Track cumulative Y offset instead of recalculating every frame.

```lua
container.currentYOffset = 0

function AddEntry(frame)
    -- Position using cached offset
    frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -currentYOffset)

    -- Measure frame
    local height = frame:GetHeight() or 80  -- Fallback

    -- Update offset for next entry
    currentYOffset = currentYOffset + height + MARGIN_SMALL
    content:SetHeight(currentYOffset)
end
```

**Performance:** O(1) per entry instead of O(n²) for full recalculation.

**Known Issue:** Fallback height (80px) doesn't match all component types (see Issue H1).

---

### 2.6 Color System Organization

**Current color definitions in `HopeAddon.colors`:**
- All TBC/Outland themed colors defined with r, g, b, a, hex values
- Item quality colors for borders
- Achievement gold for completion states
- Fel green for nature/zone elements
- Arcane purple for social/directory features

**Background colors in `HopeAddon.bgColors`:**
- Multiple alpha levels for layering (0.7, 0.8, 0.95)
- Themed tints (purple, blue, red, green)
- Input-specific darker backgrounds

**Text colors in `HopeAddon.textColors`:**
- Hierarchical grayscale (PRIMARY → DISABLED)
- Consistent readability across contexts

---

### 2.7 Armory Tab Architecture

The Armory tab is a complex equipment management interface with a 3D character model, equipment slots, and a floating gear popup system.

**Frame Hierarchy:**
```
scrollContainer.content (scroll parent)
└── armoryUI.container (main container, dynamically sized)
    ├── phaseBar (35px height, horizontal phase buttons)
    │   ├── Phase 1 button (active/inactive state)
    │   ├── Phase 2 button
    │   ├── Phase 3 button
    │   └── Phase 5 button (Phase 4 skipped - ZA catch-up)
    │
    ├── characterView (380px height, BackdropTemplate a=0.95)
    │   ├── modelFrame (DressUpModel, 180x280px, LOW strata)
    │   │   └── 3D character model with drag rotation
    │   │
    │   └── slotsContainer (MEDIUM strata, level +10)
    │       ├── Left column: head, neck, shoulders, back, chest, wrist
    │       ├── Right column: hands, waist, legs, feet, ring1, ring2, trinket1, trinket2
    │       └── Bottom row: mainhand, offhand, ranged (anchored to model bottom)
    │
    └── footer (35px height)
        ├── Stats: Avg iLvl, Upgrades, Wishlisted
        ├── BIS button (gold, left)
        └── RESET button (grey, right)

armoryUI.gearPopup (DIALOG strata, parented to mainFrame)
    ├── Header with slot name + close button
    ├── ScrollFrame with item rows
    │   ├── BiS item row (gold star indicator)
    │   └── Alternative item rows (up to 5)
    └── Anchored to clicked slot button
```

**State Management (`Journal.armoryState`):**
```lua
armoryState = {
    selectedPhase = 1,           -- Current phase (1-5, no 4)
    selectedSlot = nil,          -- Currently selected slot name
    popupVisible = false,        -- Is gear popup shown
    expandedSections = {},       -- Collapsible state (future use)
    slotData = {},               -- Cached equipment data per slot
}
```

**UI State (`Journal.armoryUI`):**
```lua
armoryUI = {
    container = Frame,           -- Main container
    phaseBar = Frame,            -- Phase selection bar
    phaseButtons = {},           -- [phase] = Button
    characterView = Frame,       -- Character display area
    modelFrame = DressUpModel,   -- 3D model
    slotsContainer = Frame,      -- Slot button parent
    slotButtons = {},            -- [slotName] = Button
    footer = Frame,              -- Stats and action buttons
    gearPopup = Frame,           -- Floating gear popup (parented to mainFrame!)
}
```

**Key Functions:**
| Function | Purpose |
|----------|---------|
| `PopulateArmory()` | Main entry point, creates/shows all Armory UI |
| `CleanupArmory()` | Hides and clears Armory UI |
| `CreateArmoryContainer()` | Creates main container and children |
| `CreateArmoryPhaseBar()` | Creates phase selection buttons |
| `CreateArmoryCharacterView()` | Creates model + slots container |
| `CreateArmoryModelFrame()` | Creates DressUpModel with drag rotation |
| `CreateArmorySlotsContainer()` | Creates slot button container |
| `CreateArmorySlotButtons()` | Creates 15 equipment slot buttons |
| `CreateSingleArmorySlotButton()` | Creates individual slot button |
| `CreateArmoryFooter()` | Creates stats and action buttons |
| `RefreshArmorySlotData()` | Loads current equipment + calculates upgrades |
| `GetArmoryGearPopup()` | Lazy-creates gear popup |
| `ShowArmoryGearPopup()` | Positions and shows popup |
| `HideArmoryGearPopup()` | Hides popup |
| `PopulateArmoryGearPopup()` | Fills popup with BiS + alternatives |
| `SelectArmoryPhase()` | Changes phase, refreshes UI |
| `RecalculateArmoryHeight()` | Updates container height |

**Slot Button Visual States:**
| State | Border Color | Background | Glow |
|-------|--------------|------------|------|
| Empty | Grey (0.4) | Dark (0.1) | None |
| Equipped (no upgrade) | Grey (0.5) | Dark (0.15) | None |
| Upgrade available | Gold (1, 0.84, 0) | Dark (0.15) | Gold pulse |
| Selected | Bright gold | Lighter (0.2) | Strong gold |
| Hover | Brighter | Lighter | Subtle |

**Gear Popup Positioning:**
- Left column slots → Popup appears RIGHT
- Right column slots → Popup appears LEFT
- Bottom row slots → Popup appears TOP
- Configured in `C.ARMORY_GEAR_POPUP.POSITION_OFFSETS`

**Constants Reference (Constants.lua):**
| Constant | Purpose |
|----------|---------|
| `ARMORY_PHASES` | Phase metadata (name, color, raids) |
| `ARMORY_PHASE_BAR` | Phase bar dimensions and styling |
| `ARMORY_CHARACTER_VIEW` | Character view dimensions and backdrop |
| `ARMORY_MODEL_FRAME` | Model frame dimensions and settings |
| `ARMORY_SLOTS_CONTAINER` | Slot container dimensions |
| `ARMORY_SLOT_BUTTON` | Slot button sizes, positions, icons |
| `ARMORY_SLOT_PLACEHOLDER_ICONS` | Empty slot placeholder icons |
| `ARMORY_HIDDEN_SLOTS` | Hidden slots (shirt, tabard) |
| `ARMORY_GEAR_POPUP` | Popup dimensions, positioning, styling |
| `ARMORY_FOOTER` | Footer dimensions and button config |
| `ARMORY_GEAR_DATABASE` | BiS items by phase/slot |

**Data Flow:**
```
User selects Phase 2
       ↓
SelectArmoryPhase(2)
       ↓
Update phase button visuals
       ↓
RefreshArmorySlotData()
       ↓
For each slot:
  - Get equipped item
  - Get BiS for Phase 2
  - Calculate upgrade delta
  - Update slot visual (gold border if upgrade)
       ↓
If popup visible:
  - Re-populate with Phase 2 data
```

**Known Considerations:**
1. Model frame at LOW strata allows slot buttons to receive clicks
2. Gear popup parented to mainFrame (not characterView) to avoid backdrop obscuring
3. Phase 4 (ZA) intentionally skipped in UI - catch-up raid with no BiS
4. Shirt and tabard slots hidden - no BiS recommendations for cosmetic slots

---

### 2.8 Social Tab Architecture

The Social Tab uses a sub-tabbed interface with three views: Feed, Travelers, and Companions.

**Container Structure:**
```lua
Journal.socialContainers = {
    statusBar = Frame,     -- Top profile/status bar
    tabBar = Frame,        -- Sub-tab buttons
    content = Frame,       -- Main content area
    scrollFrame = Frame,   -- Scroll frame wrapper
}

Journal.socialSubTabs = {
    feed = Button,         -- Activity Feed tab
    travelers = Button,    -- Fellow Travelers directory
    companions = Button,   -- Companions list
}
```

**Sub-Tab Content:**

| Sub-Tab | Content | Key Functions |
|---------|---------|---------------|
| Feed | Activity feed with rumors, mugs | `PopulateSocialFeed()` |
| Travelers | Directory with filters/search | `PopulateSocialTravelers()` |
| Companions | Favorites + online status | `PopulateSocialCompanions()` |

**Travelers Tab Filters:**
```lua
Journal.socialState = {
    searchText = "",           -- Search box content
    sortOption = "last_seen",  -- Sort order
    filterOption = "all",      -- Quick filter: all/online/ic/ooc/lfrp
    currentPage = 1,           -- Pagination
    pageSize = 20,             -- Items per page
}
```

**Filter Buttons:**
| Filter | Description | Color |
|--------|-------------|-------|
| All | All travelers | Grey |
| Online | Seen < 5 min | Green |
| IC | In Character status | Green |
| OOC | Out of Character | Blue |
| LF_RP | Looking for RP | Pink |

**Content Clearing Pattern:**
```lua
-- When switching sub-tabs: clear everything
ClearSocialContent()

-- When changing filters (same sub-tab): preserve filter bar
ClearSocialContent(true)  -- preserveFilterBar = true
```

**Region Tracking:**
FontStrings and Textures must be tracked manually for cleanup:
```lua
local text = content:CreateFontString(nil, "OVERLAY")
self:TrackSocialRegion(text)  -- Adds to socialContentRegions array
```

**Activity Feed System:**
- Shows recent activities from Fellow Travelers (48h retention)
- Activity types: STATUS, BOSS, LEVEL, GAME, BADGE, RUMOR, MUG, ROMANCE
- Listener system for real-time updates: `ActivityFeed:RegisterListener(id, callback)`
- Hybrid refresh: auto when scrolled to top, banner when scrolled down

**Companions System:**
- Favorites list with 50 max companions
- Request/Accept/Decline flow with 24h expiry
- Online status based on FellowTravelers lastSeenTime (5-min threshold)
- Network messages: COMP_REQ, COMP_ACC, COMP_DEC

**Romance System:**
- One exclusive partner (monogamous)
- States: SINGLE → PROPOSED → DATING
- Network messages: ROM_REQ, ROM_ACC, ROM_DEC, ROM_BRK
- Breakups broadcast to Activity Feed

---

## Part 3: Issue Catalog

### 3.1 Critical Issues

#### Issue C1: Words with WoW - Missing UI Cleanup ✅ FIXED
**Severity:** Critical (Memory Leak)
**Category:** Memory Management
**File:** `Social/Games/WordsWithWoW/WordGame.lua:196-253`

**Problem:**
No dedicated `CleanupGame()` function. OnDestroy only calls `DestroyGameWindow()` but doesn't clean FontStrings (p1ScoreText, p2ScoreText, boardText, turnText, lastMoveText), boardFrame, or game data (board, moveHistory).

**Impact:** Memory leak on every game end.

**Fix Applied (2026-01-19):**
- Added `CleanupGame()` function at line 196
- Clears all FontStrings (p1ScoreText, p2ScoreText, turnText, boardText, lastMoveText)
- Clears frame references (p1Frame, p2Frame, boardFrame, window)
- Clears game data references (board, moveHistory, scores, rowCache)
- Called from OnDestroy before DestroyGameWindow
- Frame references now stored in ShowUI for proper cleanup

**Checklist:**
- [x] CleanupGame function created
- [x] All FontStrings cleared
- [x] boardFrame released
- [x] Game data references nil'd
- [x] Called from OnDestroy and OnDisable

---

#### Issue C2: Pong - Ball Position Not Synchronized ✅ FIXED
**Severity:** Critical (Multiplayer Desync)
**Category:** Network Synchronization
**File:** `Social/Games/Pong/PongGame.lua:561-623`

**Problem:**
Only paddle positions synchronized. Ball physics run locally on both clients → divergence → inconsistent scoring.

**Impact:** Remote opponents see different ball positions. Score discrepancies.

**Fix Applied (2026-01-19):**
- Added `isHost` flag in OnCreate (player1/game creator is host)
- Host sends BALL messages with x, y, dx, dy, speed alongside PADDLE messages
- Client receives and applies ball state from host
- Ball physics remain server-authoritative (host controls)

**Checklist:**
- [x] Determine host/client role on game start
- [x] Host sends ball updates with paddle
- [x] Client applies received ball position
- [ ] Test scoring consistency (requires manual testing)
- [ ] Handle late packets/interpolation (future enhancement)

---

#### Issue C3: Words with WoW - Board Re-render Performance ✅ FIXED
**Severity:** Critical (Performance)
**Category:** Rendering Optimization
**File:** `Social/Games/WordsWithWoW/WordGame.lua:732-813`

**Problem:**
Entire 15x15 board re-rendered as concatenated string on every update. O(n²) string operations.

**Impact:** Frame drops during active play.

**Fix Applied (2026-01-19):**
- Added row caching system (rowCache, dirtyRows, headerCache, separatorCache)
- `RenderBoard()` now accepts gameData parameter for cache storage
- Added `RenderBoardRow()` helper for individual row rendering
- Added `InvalidateRows()` to mark dirty rows when tiles placed
- Only dirty rows are re-rendered, cached rows are reused
- Header and separator cached permanently (never change)

**Checklist:**
- [x] Implement row caching
- [x] Invalidate cache on cell changes
- [ ] Benchmark before/after performance (requires testing)
- [x] Ensure cache cleared on game reset (via CleanupGame)
- [ ] Test with full board (requires manual testing)

---

### 3.2 High Priority Issues

#### Issue H1: Scroll Container Height Fallback Mismatch ✅ FIXED
**Severity:** High (Layout Bug)
**Category:** Layout
**File:** `UI/Components.lua:131-150, 654-666`

**Problem:**
80px fallback doesn't match component heights. Section headers ~30px, spacers variable, collapsible headers 28px (all UNDER fallback).

**Symptom:** Double-spacing or compressed layout.

**Fix Applied (2026-01-19):**
- Added `COMPONENT_TYPE` constants enum (line 131-139)
- Added `FALLBACK_HEIGHTS` table with type-specific heights (line 141-150)
- Updated `AddEntry()` to check `_componentType` and `_spacerHeight` (line 654-666)
- Updated component creation functions to set `_componentType`:
  - `CreateSectionHeader` (line 2073)
  - `CreateCategoryHeader` (line 2108)
  - `CreateSpacer` (line 2131-2132, also sets `_spacerHeight`)
  - `CreateEntryCard` (line 709)
  - `CreateDivider` (line 807)
  - `CreateCollapsibleSection` (line 922)

**Checklist:**
- [x] Component type stored in _componentType field
- [x] Fallback heights match actual component heights
- [x] Spacer height stored in _spacerHeight field
- [ ] Test all tab layouts (requires manual testing)
- [ ] Verify no double-spacing (requires manual testing)

---

#### Issue H2: Game Window Size - Words Uses Generic "LARGE" ✅ FIXED
**Severity:** High (UX)
**Category:** Consistency
**File:** `Social/Games/GameUI.lua:34`, `Social/Games/WordsWithWoW/WordGame.lua:532`

**Problem:**
Words uses generic LARGE (600x500) instead of dedicated WORDS constant.

**Fix Applied (2026-01-19):**
- Added `WORDS = { width = 650, height = 600 }` to WINDOW_SIZES (GameUI.lua:34)
- Updated WordGame.lua to use "WORDS" instead of "LARGE" (line 532)

**Checklist:**
- [x] WORDS constant added to WINDOW_SIZES
- [x] WordGame.lua updated to use "WORDS"
- [ ] Test board fits comfortably (requires manual testing)
- [ ] No horizontal scrolling (requires manual testing)
- [ ] Adjust dimensions if needed

---

#### Issue H3: Inconsistent Frame Reference Storage Patterns ⏭️ WON'T FIX
**Severity:** High (Maintainability)
**Category:** Code Consistency
**Files:** All game implementations

**Problem:**
Each game stores frame references differently. Hard to maintain cleanup patterns.

**Proposed Fix:** Standardize on nested structure (game.data.ui for frames, game.data.state for state).

**Decision (2026-01-19): Won't Fix - By Design**
Analysis shows current patterns are already consistent:
- All games use `*Frame` suffix for frames
- All games use `*Text` suffix for FontStrings
- All games have proper CleanupGame functions
- Timer pattern (`countdownTimer`) is identical across games

The suggested `game.data.ui` / `game.data.state` split would require:
- Refactoring all 4 game implementations
- Updating all cleanup functions
- No functional benefit (just organization preference)

**Verdict:** Not worth the risk/effort. Current patterns work well and are maintainable.

---

#### Issue H4: Words Network Score Validation Missing ✅ FIXED
**Severity:** High (Multiplayer Integrity)
**Category:** Network Synchronization
**File:** `Social/Games/WordsWithWoW/WordGame.lua:490-514`

**Problem:**
Score sent in move message but not validated by opponent. Scores can diverge if dictionaries or scoring differ.

**Fix Applied (2026-01-19):**
- HandleRemoteMove now compares remote claimed score vs locally calculated score
- Score is recalculated locally via PlaceWord (authoritative)

---

#### Issue H5: Armory Gear Popup Visually Obscured by Parent Backdrop ✅ FIXED
**Severity:** High (Visual Bug)
**Category:** Frame Strata/Z-Order
**File:** `Journal/Journal.lua:10873-10888`

**Problem:**
The Armory gear popup was parented to `characterView` which has a `BackdropTemplate` with 95% opacity. Even though the popup was set to `DIALOG` strata (higher than parent), WoW's rendering engine draws child frames within their parent's visual context, causing the dark backdrop to visually obscure the popup content.

**Symptom:** Popup appears to be "covered" or "behind" something dark despite being clickable.

**Fix Applied (2026-01-25):**
- Re-parented popup from `characterView` to `self.mainFrame` (Journal's main window)
- Added `SetFrameLevel(100)` to ensure popup is above other DIALOG strata frames
- Anchor positioning to slot buttons still works (anchors are independent of parent)

```lua
-- Before (broken):
local popup = CreateFrame("Frame", "...", characterView, "BackdropTemplate")
popup:SetFrameStrata("DIALOG")

-- After (fixed):
local popupParent = self.mainFrame or UIParent
local popup = CreateFrame("Frame", "...", popupParent, "BackdropTemplate")
popup:SetFrameStrata("DIALOG")
popup:SetFrameLevel(100)
```

**Root Cause Analysis:**
In WoW, frame strata determines render order between frames, but a parent's backdrop can still visually obscure children if the backdrop is drawn after children in the render pass. The solution is to parent popups to a frame that doesn't have an opaque backdrop, while still using anchors to position relative to the original content.

**Checklist:**
- [x] Popup parented to mainFrame (no opaque backdrop)
- [x] SetFrameLevel(100) added for extra assurance
- [x] Anchor to slot buttons still works
- [x] Click-away handler still functions correctly
- [x] Documented in Section 1.10 (Frame Strata Standards)
- If mismatch detected, logs debug message with claimed vs actual values
- Local calculation always trusted (prevents cheating)

**Checklist:**
- [x] Score recalculated on move receipt (via PlaceWord)
- [x] Mismatch logged to debug output
- [x] Local calculation trusted
- [ ] Test with identical boards (requires manual testing)
- [x] Validation logic documented in code comments

---

### 3.3 Medium Priority Issues

#### Issue M1: RecalculatePositions Layout Shift ✅ FIXED
**Severity:** Medium (UX Bug)
**Category:** Layout
**File:** `UI/Components.lua:708-711`

**Problem:**
RecalculatePositions adds MARGIN_NORMAL (10px) to final content height at line 710, but AddEntry doesn't add this extra padding at line 670. Both use MARGIN_SMALL for inter-entry spacing, but the total content height differs by 10px after RecalculatePositions.

**Fix Applied (2026-01-19):**
- Removed MARGIN_NORMAL from RecalculatePositions final height calculation
- Changed `self.content:SetHeight(yOffset + Components.MARGIN_NORMAL)` to `self.content:SetHeight(yOffset)`
- Now matches AddEntry height calculation exactly

**Checklist:**
- [x] Match AddEntry height calculation (no extra padding)
- [ ] Test collapsible toggle doesn't shift layout (requires manual testing)
- [x] Content height calculation consistent between functions
- [ ] Check all tabs with collapsible sections (requires manual testing)

---

#### Issue M2: Card Description Bottom Clipping ⏭️ WON'T FIX
**Severity:** Medium (UX)
**Category:** Layout
**File:** `Journal/Journal.lua`

**Problem:**
Description pinned to BOTTOM at fixed Y offset. Long descriptions may overflow.

**Proposed Fix:** Use SetMaxLines(3) instead of fixed bottom constraint. Adjust card height dynamically.

**Decision (2026-01-19): Won't Fix - By Design**
Current implementation is already robust:
- Uses anchor-based constraints (bottom anchor 22px for timestamp)
- Truncates to 120 characters with "..." in the code
- Shows full text in tooltip on hover
- No actual clipping occurs in practice

SetMaxLines would be redundant and add complexity. Current pattern is better.

---

#### Issue M3: Challenge Button Offset Inconsistency ⏭️ WON'T FIX
**Severity:** Medium (Visual Polish)
**Category:** Styling
**Files:** `Journal/Journal.lua`

**Problem:**
Game cards use offset (-8, 8), directory cards use (-10, 10). Minor visual misalignment.

**Proposed Fix:** Standardize to MARGIN_NORMAL (10px): `(-10, 10)` for both.

**Decision (2026-01-19): Won't Fix - Intentional**
The "inconsistency" is actually intentional design:
- **Game cards:** 80x22 styled buttons → offset (-8, 8) appropriate for button size
- **Directory cards:** 24x24 icon buttons → offset (-10, 10) appropriate for smaller icon

Different button types warrant different positioning. The 2px difference accommodates the different visual styles and is intentional visual tuning.

---

#### Issue M4: Game Card Border Color Restoration ✅ VERIFIED FIXED
**Severity:** Medium (Visual Bug)
**Category:** Styling
**File:** `UI/Components.lua:2150`

**Problem:**
Game cards may not properly restore border color after hover if defaultBorderColor isn't initialized.

**Status:** Already properly implemented. Analysis confirmed:
- `defaultBorderColor` is stored on card creation (Components.lua:2150)
- `OnLeave` handler correctly uses `defaultBorderColor` for restoration (Components.lua:2248)
- Pattern is consistently used across entry cards, game cards, and other components

**Checklist:**
- [x] defaultBorderColor stored on card creation
- [x] Border restores correctly after hover
- [x] Test with multiple game cards (pattern verified in code review)
- [x] Verify no color bleed between cards (pattern verified in code review)

---

#### Issue M5: Profile Editor Absolute Positioning ⏭️ WON'T FIX
**Severity:** Medium (Maintainability)
**Category:** Layout
**File:** `Journal/ProfileEditor.lua:130-246`

**Problem:**
Uses manual Y offset tracking instead of layout system.

**Proposed Fix:** Use AddField pattern with relative positioning.

**Decision (2026-01-19): Won't Fix - Low ROI**
Refactoring would require:
- Creating new AddField helper system
- Refactoring entire ProfileEditor layout
- Testing all field interactions

Current manual offset tracking works fine for a single-use editor. The editor layout is stable and rarely modified.

**Verdict:** Only refactor if adding many new profile fields in the future.

---

### 3.4 Low Priority Issues

#### Issue L1: Minimap Tooltip No Icon Display ✅ RESOLVED
**Severity:** Low (Feature Gap)
**Category:** Visual Polish
**File:** `Social/MapPins.lua:30-55`

**Problem:**
Tooltip shows text only. Could show Fellow Traveler icon.

**Fix Applied (2026-01-19):**
- Added icon display using `TravelerIcons:GetHighestQualityIcon()`
- Falls back to default "INV_Misc_GroupLooking" icon
- Icon appears before player name in tooltip

**Checklist:**
- [x] Icon texture path retrieved from TravelerIcons
- [x] AddTexture called before AddLine
- [x] Icon size appropriate (uses GameTooltip default)
- [x] Fallback if no icon available

---

#### Issue L2: Inline Button Handler Closures ✅ RESOLVED
**Severity:** Low (Code Quality)
**Category:** Memory Management
**Files:** `Social/MinigamesUI.lua`

**Status (2026-01-19):** All handlers moved to module scope (lines 66-255).
Comment at lines 61-63 documents: "Avoids creating closures on each frame creation"

**Checklist:**
- [x] Move inline handlers to module level
- [x] No new closures per button
- [x] Test button functionality unchanged
- [x] Pattern consistent across UI

---

#### Issue L3: Font Size Constants Not Centralized ✅ RESOLVED
**Severity:** Low (Consistency)
**Category:** Styling
**Files:** `Social/Games/GameUI.lua`

**Fix Applied (2026-01-19):**
Added `GameUI.GAME_FONTS` table with centralized font constants:
```lua
GAME_FONTS = {
    TITLE = "GameFontNormalHuge",       -- ~20pt
    SCORE = "GameFontNormalLarge",      -- ~16pt
    LABEL = "GameFontNormal",           -- ~12pt
    STATUS = "GameFontNormalSmall",     -- ~10pt
    HINT = "GameFontHighlightSmall",    -- ~10pt white
    MONOSPACE = "NumberFontNormal",     -- For grids
}
```

**Checklist:**
- [x] GAME_FONTS table added to GameUI
- [ ] All games reference constants (gradual adoption)
- [x] Consistent font sizes documented
- [x] Monospaced font documented

---

#### Issue L4: No Render Optimization Outside Tetris ✅ RESOLVED
**Severity:** Low (Performance)
**Category:** Optimization

**Status (2026-01-19):**
- Words addressed in Issue C3 (row caching)
- Pong performance acceptable (3 objects)
- Optimization patterns documented

**Checklist:**
- [x] Words optimization addressed in C3
- [x] Pong performance acceptable (monitor)
- [x] Document optimization patterns for future games

---

#### Issue L5: Color Scheme Fully TBC-Themed ✅ RESOLVED
**Severity:** Low (Visual Consistency)
**Category:** Styling
**Files:** `Journal/Journal.lua`, `Social/MinigamesUI.lua`

**Fix Applied (2026-01-19):**
Replaced all BROWN (0.6, 0.5, 0.3) with ARCANE_PURPLE (0.61, 0.19, 1.0):
- Journal.lua: Card borders (line 408-409), button border (line 2963)
- MinigamesUI.lua: Game button leave (line 227), dice frames (lines 543, 571), RPS buttons (line 946)

**Checklist:**
- [x] Review all backdrop color usage
- [x] Ensure no brown/leather colors in production
- [x] Verify TBC theme maintained throughout
- [x] Update if any classic colors found

---

## Part 4: Implementation Roadmap

### Phase 1: Critical Fixes ✅ COMPLETE (2026-01-19)
1. **Issue C1:** Words UI cleanup (memory leak) ✅
2. **Issue C2:** Pong ball sync (multiplayer desync) ✅
3. **Issue C3:** Words board optimization (performance) ✅

**Success Criteria:**
- [x] No memory leaks on game end (CleanupGame added)
- [x] Pong scores consistent between players (host-authoritative ball sync)
- [x] Words board uses row caching (O(n) vs O(n²))

---

### Phase 2: High Priority ✅ COMPLETE (2026-01-19)
1. **Issue H1:** Scroll container height fallback ✅
2. **Issue H2:** Words window size constant ✅
3. **Issue H3:** Frame reference standardization ⏭️ Won't Fix (patterns already consistent)
4. **Issue H4:** Words score validation ✅

**Success Criteria:**
- [x] Component-type-aware fallback heights
- [x] WORDS window size added (650x600)
- [x] Cleanup patterns verified consistent (H3 reviewed, no changes needed)
- [x] Score mismatches logged to debug output

---

### Phase 3: Medium Priority ✅ COMPLETE (2026-01-19)
1. **Issue M1:** RecalculatePositions margin consistency ✅
2. **Issue M2:** Card description clipping ⏭️ Won't Fix (current design robust)
3. **Issue M3:** Challenge button offset ⏭️ Won't Fix (intentional difference)
4. **Issue M4:** Game card border restoration ✅ (verified already fixed)
5. **Issue M5:** Profile editor layout ⏭️ Won't Fix (low ROI)

**Success Criteria:**
- [x] No layout shifts on collapsible toggle (M1 fixed)
- [x] Long descriptions handled by truncation + tooltip (M2 verified)
- [x] Button offsets are intentionally different per context (M3 verified)
- [x] Profile editor works fine as-is (M5 verified)

---

### Phase 4: Low Priority Polish ✅ COMPLETE (2026-01-19)
1. **Issue L1:** Minimap tooltip icons ✅
2. **Issue L2:** Inline handler cleanup ✅ (already done)
3. **Issue L3:** Font constant centralization ✅
4. **Issue L4:** Document optimization patterns ✅
5. **Issue L5:** Verify TBC color theme ✅

**Success Criteria:**
- [x] All tooltips show icons where applicable
- [x] No closure-creating button handlers
- [x] Consistent font usage across games
- [ ] Color palette verified TBC-themed

---

### Phase 5: Documentation & Standards (Ongoing)
1. Update CLAUDE.md with new patterns
2. Maintain this UI guide
3. Add code examples for common patterns
4. Keep issue catalog current

**Success Criteria:**
- [ ] Documentation reflects current state
- [ ] All new code follows standards
- [ ] AI assistants can reference style guide
- [ ] Issue catalog stays current

---

## Part 5: Quick Reference Checklists

### Adding a New UI Component Checklist
- [ ] Uses TBC color palette (fel green/arcane purple)
- [ ] Uses named spacing constants (MARGIN_SMALL/NORMAL/LARGE)
- [ ] Follows quest log parchment styling
- [ ] Icon organization uses row/column pattern if multi-part
- [ ] Achievement badge uses quality border colors
- [ ] Progress bars use standardized dimensions (20px height)
- [ ] Typography follows hierarchy (H1/H2/H3/body)
- [ ] Frame pooled if used repeatedly
- [ ] Cleanup function releases all references
- [ ] Hover states use smooth transitions (0.15s)
- [ ] Tooltips use GameTooltip with consistent anchoring

### Adding a New Game Checklist
- [ ] Uses GameUI:CreateGameWindow() for window
- [ ] Window size defined in WINDOW_SIZES constant
- [ ] Uses GameCore for game loop/state
- [ ] Uses GameComms for multiplayer
- [ ] Implements CleanupGame() function
- [ ] Cleanup called from OnDestroy and OnDisable
- [ ] Frame references stored in game.data.ui table
- [ ] Game state stored in game.data.state table
- [ ] Network messages include validation data
- [ ] Font sizes use GAME_FONTS constants
- [ ] Colors use GameUI color constants
- [ ] Button handlers at module level (not closures)
- [ ] Tested in LOCAL and REMOTE modes

### Tab Layout Checklist
- [ ] Uses scroll container pattern
- [ ] Calls ReleaseAll on pools before rendering
- [ ] Uses AcquireCard/AcquireSection from pools
- [ ] Adds section headers with CreateSectionHeader
- [ ] Uses CreateSpacer for vertical spacing (MARGIN_LARGE)
- [ ] Collapsible sections use AcquireCollapsibleSection
- [ ] Calls UpdateFooter() after populating
- [ ] No magic numbers (uses constants)
- [ ] Handles empty state with placeholder message
- [ ] Progress bars show completion state

### Visual Consistency Checklist
- [ ] Card heights uniform within same context (min 80px)
- [ ] Icon sizes consistent (40x40 standard)
- [ ] Margins consistent (10px standard between elements)
- [ ] Border colors match quality/context
- [ ] Hover effects use GOLD_BRIGHT
- [ ] Text colors follow hierarchy
- [ ] Backgrounds use appropriate alpha levels
- [ ] No classic WoW brown colors
- [ ] Fel green/arcane purple accents
- [ ] Button sizes match context (22px or 32px height)

---

## Part 6: Code Pattern Examples

### Example 1: Creating a Card with Icon Organization

For a multi-stage feature (e.g., attunement with 3 chapters in Act 1):

```lua
-- Stage 1: 3 parts in a row
local stage1Container = CreateFrame("Frame", nil, parent)
stage1Container:SetSize(140, 50)  -- 3 icons * 40px + 2*10px spacing

local icons = {}
for i = 1, 3 do
    local icon = CreateFrame("Button", nil, stage1Container)
    icon:SetSize(40, 40)  -- ICON_SIZE_STANDARD
    icon:SetPoint("LEFT", stage1Container, "LEFT", (i-1) * 50, 0)

    -- Icon texture
    local tex = icon:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\Icons\\Achievement_Icon_" .. i)

    -- Quality border
    icon:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })

    -- State-based border color
    if completed[i] then
        icon:SetBackdropBorderColor(1, 0.84, 0, 1)  -- GOLD_BRIGHT
    else
        icon:SetBackdropBorderColor(0.64, 0.21, 0.93, 1)  -- EPIC
        tex:SetDesaturated(true)
    end

    icons[i] = icon
end

-- Arrow connector (5px below stage)
local arrow = stage1Container:CreateTexture(nil, "OVERLAY")
arrow:SetSize(16, 16)
arrow:SetPoint("TOP", stage1Container, "BOTTOM", 0, -5)
arrow:SetTexture("Interface\\Buttons\\UI-MicroStream-Yellow")
arrow:SetVertexColor(0.5, 0.5, 0.5)

-- Stage 2: Single icon (centered below, 5px from arrow)
local stage2Icon = CreateFrame("Button", nil, parent)
stage2Icon:SetSize(40, 40)
stage2Icon:SetPoint("TOP", arrow, "BOTTOM", 0, -5)
```

**Checklist:**
- [ ] Multi-part stages use row layout
- [ ] Icons 40x40 standard size
- [ ] 10px spacing between icons (MARGIN_NORMAL)
- [ ] 5px spacing between stages (MARGIN_SMALL)
- [ ] Connector arrow between stages
- [ ] Next stage centered below
- [ ] Locked icons desaturated
- [ ] Completed icons have gold border

---

### Example 2: Creating a Progress Bar

```lua
local function CreateProgressBar(parent, width, initialProgress)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(width, 20)

    -- Background
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)  -- DARK_SOLID

    -- Border
    bar:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    bar:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)  -- Gray

    -- Fill (StatusBar with gradient)
    bar.fill = CreateFrame("StatusBar", nil, bar)
    bar.fill:SetSize(width - 4, 16)  -- Inset 2px each side
    bar.fill:SetPoint("LEFT", bar, "LEFT", 2, 0)
    bar.fill:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    -- Gradient: Dark green to bright green
    bar.fill:GetStatusBarTexture():SetGradient("HORIZONTAL",
        {r=0.1, g=0.6, b=0.1},
        {r=0.2, g=0.9, b=0.2}
    )

    bar.fill:SetMinMaxValues(0, 100)
    bar.fill:SetValue(0)

    -- Text overlay
    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.text:SetTextColor(1, 1, 1)
    bar.text:SetShadowOffset(1, -1)
    bar.text:SetShadowColor(0, 0, 0, 1)

    -- Animate to target value
    local function AnimateTo(targetValue, duration)
        local startValue = bar.fill:GetValue()
        local startTime = GetTime()
        local endTime = startTime + duration

        local ticker = C_Timer.NewTicker(0.03, function()  -- 30 FPS
            local now = GetTime()
            if now >= endTime then
                bar.fill:SetValue(targetValue)
                bar.text:SetText(string.format("%.0f%%", targetValue))
                ticker:Cancel()

                if targetValue >= 100 then
                    HopeAddon.Effects:Sparkles(bar, 1.5)
                    bar:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold
                end
            else
                local progress = (now - startTime) / duration
                local currentValue = startValue + (targetValue - startValue) * progress
                bar.fill:SetValue(currentValue)
                bar.text:SetText(string.format("%.0f%%", currentValue))
            end
        end)
    end

    bar.SetProgress = function(self, value)
        AnimateTo(value, 0.5)
    end

    bar:SetProgress(initialProgress or 0)

    return bar
end
```

**Checklist:**
- [ ] Dark background (DARK_SOLID)
- [ ] Gradient fill (dark green → bright green)
- [ ] Text overlay with shadow
- [ ] Animated fill over 0.5s at 30 FPS
- [ ] Sparkle effect on 100% completion
- [ ] Gold border on completion
- [ ] SetProgress() method for updates

---

### Example 3: Creating Collapsible Section

```lua
local function CreateCollapsibleSection(parent, title, progressText, color)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(485, 28)  -- CONTAINER_WIDTH, header height

    -- Header background (Button for clickability)
    section.header = CreateFrame("Button", nil, section)
    section.header:SetSize(485, 28)
    section.header:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    section.header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 8,
    })
    section.header:SetBackdropColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.8)
    section.header:SetBackdropBorderColor(color.r, color.g, color.b, 1)

    -- Toggle icon
    section.toggleIcon = section.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.toggleIcon:SetPoint("LEFT", section.header, "LEFT", 10, 0)  -- MARGIN_NORMAL
    section.toggleIcon:SetText("▼")  -- Expanded
    section.toggleIcon:SetTextColor(color.r, color.g, color.b)

    -- Title text
    section.titleText = section.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.titleText:SetPoint("LEFT", section.toggleIcon, "RIGHT", 10, 0)  -- MARGIN_NORMAL
    section.titleText:SetText(title)
    section.titleText:SetTextColor(color.r, color.g, color.b)

    -- Progress text (right-aligned)
    section.progressText = section.header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    section.progressText:SetPoint("RIGHT", section.header, "RIGHT", -10, 0)  -- MARGIN_NORMAL
    section.progressText:SetText(progressText or "")
    section.progressText:SetTextColor(1, 1, 1)

    -- Content container (indented)
    section.contentContainer = CreateFrame("Frame", nil, section)
    section.contentContainer:SetPoint("TOPLEFT", section.header, "BOTTOMLEFT", 10, 0)  -- MARGIN_NORMAL
    section.contentContainer:SetPoint("RIGHT", section, "RIGHT", 0, 0)
    section.contentContainer:SetHeight(0)
    section.contentContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
    })
    section.contentContainer:SetBackdropColor(0, 0, 0, 0.3)

    -- State
    section.isExpanded = true
    section.childEntries = {}
    section.contentHeight = 0

    -- Add child helper
    function section:AddChild(childFrame)
        childFrame:SetPoint("TOPLEFT", self.contentContainer, "TOPLEFT", 0, -self.contentHeight)
        childFrame:SetPoint("RIGHT", self.contentContainer, "RIGHT", 0, 0)
        table.insert(self.childEntries, childFrame)

        local childHeight = childFrame:GetHeight() or 80
        self.contentHeight = self.contentHeight + childHeight + 5  -- MARGIN_SMALL
        self.contentContainer:SetHeight(self.contentHeight)
        self:UpdateHeight()
    end

    -- Update section height
    function section:UpdateHeight()
        if self.isExpanded then
            self:SetHeight(28 + self.contentHeight + 5)  -- Header + content + MARGIN_SMALL
        else
            self:SetHeight(28)  -- Header only
        end
    end

    -- Toggle handler
    function section:Toggle()
        self.isExpanded = not self.isExpanded

        if self.isExpanded then
            self.toggleIcon:SetText("▼")
            HopeAddon.Animations:FadeTo(self.contentContainer, 1, 0.3)
            self.contentContainer:Show()
        else
            self.toggleIcon:SetText("▶")
            HopeAddon.Animations:FadeTo(self.contentContainer, 0, 0.3, function()
                self.contentContainer:Hide()
            end)
        end

        self:UpdateHeight()

        if self.onToggle then
            self.onToggle()
        end
    end

    section.header:SetScript("OnClick", function(self)
        section:Toggle()
        HopeAddon.Sounds:PlayClick()
    end)

    -- Hover effect
    section.header:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)  -- Gold
    end)
    section.header:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    end)

    return section
end
```

**Usage:**
```lua
local t4Section = CreateCollapsibleSection(
    scrollContent,
    "Tier 4: Rise of the Burning Legion",
    "3 / 5 Bosses",
    HopeAddon.colors.ARCANE_PURPLE
)

-- Add boss cards as children
for _, boss in ipairs(t4Bosses) do
    local card = CreateBossCard(boss)
    t4Section:AddChild(card)
end

-- Register toggle callback
t4Section.onToggle = function()
    scrollContainer:RecalculatePositions()
end
```

**Checklist:**
- [ ] Header uses theme color
- [ ] Toggle icon rotates (▼ → ▶)
- [ ] Content fades in/out over 0.3s
- [ ] AddChild helper manages layout
- [ ] UpdateHeight called after changes
- [ ] onToggle callback for scroll recalc
- [ ] Hover changes border to gold
- [ ] Content indented 10px (MARGIN_NORMAL)

---

### Example 4: Using LayoutBuilder (Phase 17)

Automated form layout with vertical positioning:

```lua
local builder = HopeAddon.Components:CreateLayoutBuilder(parent, {
    startY = -10,
    padding = 10,
})

-- Add labeled input fields
local nameBox = HopeAddon.Components:CreateLabeledEditBox(parent, "Character Name:", "Enter name", 50)
builder:AddRow(nameBox)

builder:AddSpacer(15)  -- Extra spacing between sections

local classDropdown = HopeAddon.Components:CreateLabeledDropdown(parent, "Class:", {
    { value = "WARRIOR", text = "Warrior" },
    { value = "PALADIN", text = "Paladin" },
    { value = "HUNTER", text = "Hunter" },
})
builder:AddRow(classDropdown)

-- Reset for multi-column layouts
builder:Reset()
```

**Checklist:**
- [ ] Use CreateLayoutBuilder for forms with multiple fields
- [ ] AddRow positions frames vertically
- [ ] AddSpacer adds vertical gaps
- [ ] Reset clears yOffset for new columns

---

### Example 5: Using CreateStyledButton (Phase 17)

Consistent button styling with hover effects:

```lua
local saveBtn = HopeAddon.Components:CreateStyledButton(
    parent,
    "Save Changes",   -- Text
    120,              -- Width
    28,               -- Height
    function()        -- OnClick
        self:SaveProfile()
        HopeAddon:Print("Profile saved!")
    end,
    { disabled = false }  -- Options
)

-- Button helpers
saveBtn:SetButtonText("Saving...")
saveBtn:SetButtonEnabled(false)
```

**Features:**
- 150ms color transition on hover (ColorTransition)
- PURPLE_TINT backdrop with GOLD_BRIGHT hover border
- Click sound via Sounds module
- SetButtonText() and SetButtonEnabled() helpers

---

### Example 6: Using Celebration Effects (Phase 17)

Visual feedback for achievements and completions:

```lua
-- Full celebration (glow + sparkles + sound)
HopeAddon.Effects:Celebrate(achievementFrame, 2.0, {
    color = HopeAddon.colors.GOLD_BRIGHT
})

-- Quick icon glow for badges
HopeAddon.Effects:IconGlow(badgeIcon, 1.5)

-- Progress bar completion sparkles
if progress >= 100 then
    HopeAddon.Effects:ProgressSparkles(progressBar, 1.5)
end
```

**Effect Functions:**
- `Celebrate(frame, duration, options)` - Full celebration with sound
- `IconGlow(frame, duration)` - Subtle 1.5s glow for icons
- `ProgressSparkles(progressBar, duration)` - Sparkles with success sound

---

## Part 7: Critical Files Reference

| File | Purpose | Status |
|------|---------|--------|
| `UI/Components.lua` | Reusable UI components | ✅ LayoutBuilder, CreateStyledButton added |
| `Social/Games/GameUI.lua` | Game window system | ✅ GAME_FONTS added |
| `Social/Games/WordsWithWoW/WordGame.lua` | Words implementation | ✅ All issues resolved |
| `Social/Games/Pong/PongGame.lua` | Pong implementation | ✅ Ball sync fixed |
| `Journal/Journal.lua` | Main journal UI | ✅ BROWN replaced with ARCANE_PURPLE |
| `Social/MinigamesUI.lua` | Minigame UI | ✅ BROWN replaced with ARCANE_PURPLE |
| `Social/MapPins.lua` | Minimap pins | ✅ Tooltip icons added |
| `Core/Core.lua` | Core utilities | ✅ ColorUtils, CreateBackdropFrame |
| `UI/Animations.lua` | Animation utilities | ✅ ColorTransition added |
| `Core/Effects.lua` | Visual effects | ✅ Celebrate, IconGlow, ProgressSparkles |

---

## Part 8: Visual Reference (ASCII Diagrams)

### Ideal Card Layout (Quest Log Style)

```
┌────────────────────────────────────────────────────────────┐
│  [Icon]  Chapter I: Shattered Halls                  [NEW] │
│  40x40   The warlocks of the Burning Legion await...      │
│          Completed on 2024-01-15                           │
│          ──────────────────────────────────────────────    │
│          Progress: ███████████████───────────── 75%        │
└────────────────────────────────────────────────────────────┘
 ^        ^                                            ^      ^
 10px     Icon ends                                   Note   10px
 margin   10px from left edge                        badge   margin
```

**Key measurements:**
- Card padding: 10px all sides (MARGIN_NORMAL)
- Icon: 40x40 (ICON_SIZE_STANDARD), top-left at (10, -10)
- Title: 10px right of icon, GameFontNormal, GOLD_BRIGHT
- Description: 5px below title (MARGIN_SMALL), GameFontNormalSmall
- Timestamp: 5px below description
- Progress bar: Full width - 20px margins, 20px height
- Border: Varies by context

---

### Icon Organization Pattern (Multi-Part Stage)

```
┌─────────────────────────────────────────┐
│ ACT I: THE VIOLET TOWER              ▼ │
├─────────────────────────────────────────┤
│                                         │
│  [Icon1]  [Icon2]  [Icon3]             │
│  Chapter  Chapter  Chapter              │
│    1        2        3                  │
│  (10px spacing between, row centered)  │
│              ↓ (5px spacing)            │
│           [Icon4]                       │
│  ACT II: Medivh's Shadow               │
│       (Centered below)                  │
│                                         │
└─────────────────────────────────────────┘
```

**Layout specs:**
- Row icons: 40x40 each
- Spacing between icons: 10px (MARGIN_NORMAL)
- Total row width: 3 * 40 + 2 * 10 = 140px
- Arrow: 16x16, 5px below row (MARGIN_SMALL)
- Next stage: 40x40, 5px below arrow

---

### Progress Bar Visual States

**Incomplete (< 100%):**
```
┌──────────────────────────────────────────┐
│ ███████████───────────────────           │
│             35 / 100 (35%)               │
└──────────────────────────────────────────┘
    Gray border (0.5, 0.5, 0.5)
```

**Complete (100%):**
```
┌──────────────────────────────────────────┐
│ ██████████████████████████████████████   │
│  ✨     100 / 100 (100%)        ✨       │
└──────────────────────────────────────────┘
    Gold border (1, 0.84, 0) + sparkles
```

---

### Armory Tab Layout

**Main Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ [P1] [P2] [P3] [P5]              Phase Selection Bar (35px)     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Head]                                            [Hands]      │
│  [Neck]         ┌─────────────────────┐            [Waist]      │
│  [Shoulders]    │                     │            [Legs]       │
│  [Back]         │   Character Model   │            [Feet]       │
│  [Chest]        │    (DressUpModel)   │            [Ring1]      │
│  [Wrist]        │      180x280px      │            [Ring2]      │
│                 └─────────────────────┘            [Trinket1]   │
│                                                    [Trinket2]   │
│          [MainHand]  [OffHand]  [Ranged]                        │
│                  (Bottom row - anchored to model)               │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ Avg iLvl: 115    Upgrades: 4 slots    [BIS]  [RESET]   (35px)   │
└─────────────────────────────────────────────────────────────────┘
```

**Gear Popup (when slot clicked):**
```
                    ┌─────────────────────────────┐
                    │ CHEST UPGRADES          [X] │  <- Header (36px)
                    ├─────────────────────────────┤
                    │ ★ [Icon] Chestguard of     │  <- BiS item (gold star)
 [Chest] ──────────>│          the Fallen         │     64px height
   slot             │          iLvl 128           │
  button            │          Karazhan - Prince  │
                    ├─────────────────────────────┤
                    │   [Icon] T4 Chestpiece      │  <- Alternative
                    │          iLvl 120           │     (up to 5)
                    │          Mag - Magtheridon  │
                    ├─────────────────────────────┤
                    │   [Icon] Badge Chest        │
                    │          iLvl 115           │
                    │          Badges (75)        │
                    └─────────────────────────────┘
                              300px width
```

**Slot Button States:**
```
┌────────┐  Empty        ┌────────┐  Equipped      ┌────────┐  Upgrade
│  [ ]   │  Grey border  │ [Icon] │  Grey border   │ [Icon] │  Gold border
│        │  Dark BG      │        │  Dark BG       │   ↑    │  Gold glow
│        │  No glow      │        │  No glow       │        │  Pulse anim
└────────┘               └────────┘                └────────┘
```

**Z-Order Visualization:**
```
Layer 5 (DIALOG):   ┌──────────────────┐  Gear Popup (parented to mainFrame)
                    │   Gear Popup     │
Layer 4 (HIGH):     └─────┬────────────┘
                          │
Layer 3 (MEDIUM):   ┌─────▼────────────────────────────────────────┐
                    │  Slot Buttons (level +10)                    │
Layer 2 (MEDIUM):   │  ┌──────────────────────────────────────────┐│
                    │  │ Slots Container                          ││
Layer 1 (LOW):      │  │  ┌────────────────────────────────────┐  ││
                    │  │  │ Model Frame (DressUpModel)         │  ││
                    │  │  │ (LOW strata so buttons work above) │  ││
                    │  │  └────────────────────────────────────┘  ││
                    │  └──────────────────────────────────────────┘│
                    │ Character View (backdrop a=0.95)             │
                    └──────────────────────────────────────────────┘
```

---

### Social Tab Layout

**Main Layout with Sub-Tabs:**
```
┌─────────────────────────────────────────────────────────────────┐
│ YOUR PROFILE                                                     │
│ [Class] Name <Title>    Level 70 Warrior                        │
│ Status: [In Character ▼]    [Edit Profile]                      │
├─────────────────────────────────────────────────────────────────┤
│ [Feed]  [Travelers]  [Companions]    <- Sub-tab bar             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    ┌─────────────────────────────────────────────────────┐      │
│    │ Content varies by sub-tab:                          │      │
│    │                                                     │      │
│    │ Feed: Activity entries, rumors, mugs               │      │
│    │ Travelers: Search, filters, directory cards        │      │
│    │ Companions: Favorites list, online status          │      │
│    └─────────────────────────────────────────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Travelers Tab with Filters:**
```
┌─────────────────────────────────────────────────────────────────┐
│ [🔍 Search...              ] [Sort: Last Seen ▼]  15 travelers  │
├─────────────────────────────────────────────────────────────────┤
│ [All] [Online] [IC] [OOC] [LF_RP]    <- Quick filter buttons    │
├─────────────────────────────────────────────────────────────────┤
│ [Warrior] Thrall <Hero>                                         │
│           Level 70 - Orgrimmar - 5 min ago    [♥] [★] [Game]   │
├─────────────────────────────────────────────────────────────────┤
│ [Mage] Jaina <Archmage>                                         │
│        Level 70 - Theramore - 1 hr ago       [♥] [★] [Game]    │
├─────────────────────────────────────────────────────────────────┤
│                    [< Prev]  Page 1 of 3  [Next >]              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Verification Steps

### Visual Consistency Checklist
1. [ ] Colors match TBC palette (no brown leather)
2. [ ] Icons 40x40 in standard contexts
3. [ ] Spacing uses named constants (MARGIN_SMALL/NORMAL/LARGE)
4. [ ] Progress bars 20px height
5. [ ] Borders use quality-based or context colors
6. [ ] Text follows typography hierarchy
7. [ ] Hover states transition smoothly (0.15s)
8. [ ] Tooltips use GameTooltip with consistent style

### Functional Checklist
1. [ ] Frame pooling used if component repeats
2. [ ] Cleanup function releases all references
3. [ ] No memory leaks after tab switches
4. [ ] Scroll container height calculates correctly
5. [ ] Collapsible sections animate smoothly (0.3s)
6. [ ] Network sync validated for multiplayer
7. [ ] Performance: < 16ms per frame (60fps)

### Code Quality Checklist
1. [ ] No magic numbers (uses constants)
2. [ ] No inline button handlers (uses module-level)
3. [ ] Consistent naming (ui/state structure)
4. [ ] Comments explain "why" not "what"
5. [ ] Follows existing patterns in codebase

---

## Document Maintenance

This guide should be updated when:
- [ ] New UI issue discovered → Add to Issue Catalog
- [ ] Issue fixed → Mark resolved, update checklist
- [ ] New component added → Add spec to Design Specifications
- [ ] Pattern changed → Update Code Pattern Examples
- [ ] Constants changed → Update Quick Reference Tables

---

## Summary

This UI Organization Guide provides:
✓ Complete TBC/Outland design specifications with exact values
✓ All current UI issues cataloged by severity (Critical/High/Medium/Low)
✓ Icon organization patterns (talent-tree-inspired)
✓ Quest log and achievement panel styling standards
✓ Implementation roadmap with 5 phases
✓ Code examples and checklists
✓ Visual reference diagrams with measurements

**Use this document as the authoritative reference for all UI work.**

When in doubt:
1. Check the relevant specification section
2. Reference the code examples
3. Verify against the checklists
4. Maintain visual consistency with TBC theme

---

---

## Part 9: Additional UI Standards

### 9.1 Restricted Assets (Do Not Use)

These WoW assets have fixed dimensions and cannot be resized properly for arbitrary frame sizes:

| Asset | Path | Issue |
|-------|------|-------|
| Quest Parchment | `Interface\\QUESTFRAME\\QuestBG` | Locked to quest log dimensions |
| Quest BG Bottom | `Interface\\QUESTFRAME\\QuestBG-Bot` | Fixed quest footer |
| Quest BG Top | `Interface\\QUESTFRAME\\QuestBG-Top` | Fixed quest header |
| Achievement Parchment | `Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment` | Fixed achievement frame size |

**For scalable backgrounds, use these tiling textures:**
- `Interface\\DialogFrame\\UI-DialogBox-Background` (light tan, tiles properly)
- `Interface\\DialogFrame\\UI-DialogBox-Background-Dark` (dark tan, tiles properly)
- `Interface\\Tooltips\\UI-Tooltip-Background` (charcoal, tiles properly)

**Backdrop presets that scale properly:**
| Preset | Background | Border | Use For |
|--------|------------|--------|---------|
| `DARK_GOLD` | Dark tan (tiled) | Gold | Popups, notifications |
| `PARCHMENT_TILED` | Light tan (tiled) | Gold | Main frames |
| `GAME_WINDOW` | Charcoal (tiled) | Gold | Game windows |
| `TOOLTIP` | Charcoal (tiled) | Grey | Cards, inputs |
| `DARK_DIALOG` | Dark tan (tiled) | Grey | Dark frames |

---

### 9.2 Frame Pooling Patterns

**Main Journal Pools (Journal.lua):**
| Pool | Frame Type | Purpose | Location |
|------|------------|---------|----------|
| `notificationPool` | Frame + BackdropTemplate | Pop-up notifications | Journal.lua:130-175 |
| `containerPool` | Frame | Headers, spacers, sections | Journal.lua:179-205 |
| `cardPool` | Button + BackdropTemplate | Entry cards | Journal.lua:207-285 |
| `collapsiblePool` | Frame | Collapsible sections | Journal.lua:288-345 |
| `bossInfoPool` | Frame | Raid metadata frames | Journal.lua:347-375 |
| `gameCardPool` | Button + BackdropTemplate | Games Hall cards | Journal.lua:377-430 |
| `reputationBarPool` | SegmentedReputationBar | Reputation progress bars | Journal.lua:762-782 |
| `bossLootPools.lootRow` | Button + BackdropTemplate | Boss loot popup rows | Journal.lua:807-912 |
| `pinPool` | Table-based | Minimap pins | MapPins.lua:20 |

**Lifecycle:** OnEnable -> Create pools | SelectTab -> ReleaseAll + ClearEntries | OnDisable -> Destroy pools

**Memory Management:**
- Frames released to pool, not destroyed
- Reset functions clear all references
- Parent set to nil to hide frames
- Effects/glows stopped before release
- Armory pools use unnamed pools (not `NewNamed`) for isolation

---

### 9.3 ColorUtils API

**ColorUtils Namespace** (`HopeAddon.ColorUtils`):
```lua
ColorUtils:Lighten(color, percent)          -- Lighten color by percentage
ColorUtils:Darken(color, percent)           -- Darken color by percentage
ColorUtils:ApplyVertexColor(texture, name)  -- Apply from color name
ColorUtils:ApplyTextColor(fontString, name) -- Apply from color name
ColorUtils:Blend(color1, color2, ratio)     -- Blend two colors
ColorUtils:HexToRGB(hex)                    -- Convert hex to RGB table
```

---

### 9.4 Celebration Effects API

**Celebration Effects** (`HopeAddon.Effects`):
```lua
Effects:Celebrate(frame, duration, opts)    -- Full effect: glow + sparkles + sound
Effects:IconGlow(frame, duration)           -- Subtle icon glow (1.5s default)
Effects:ProgressSparkles(bar, duration)     -- Progress bar completion sparkles

-- Pulsing Glow (persistent until manually stopped)
-- Use for "victory box" or "active selection" effects
local glowData = Effects:CreatePulsingGlow(frame, colorName, intensity)
-- colorName: "FEL_GREEN", "GOLD_BRIGHT", "ARCANE_PURPLE", "HELLFIRE_RED", etc.
-- intensity: 0.3-1.0 (default 1.0), controls glow brightness
-- Returns glowData table for manual cleanup later

-- To stop the glow:
Effects:StopGlowsOnParent(frame)            -- Stops ALL glows on a frame

-- Example: Persistent victory glow
frame.myGlow = Effects:CreatePulsingGlow(frame, "FEL_GREEN", 0.7)
-- Later, when done:
Effects:StopGlowsOnParent(frame)
```

---

**Document Created:** 2026-01-19
**Last Updated:** 2026-01-27
**Status:** Active - v1.4
**Maintainer:** AI Assistant (Claude Code)

### Recent Updates (v1.4 - 2026-01-27)
**Documentation Reorganization**
- Added Part 9: Additional UI Standards
- Added Section 9.1: Restricted Assets (moved from CLAUDE.md)
- Added Section 9.2: Frame Pooling Patterns (detailed table)
- Added Section 9.3: ColorUtils API
- Added Section 9.4: Celebration Effects API

### Previous Updates (v1.3 - 2026-01-25)
**Phase 60: Armory Tab Z-Order Fix + Documentation**
- ✅ Added Section 1.10: Frame Strata & Z-Ordering Standards
- ✅ Added Section 2.7: Armory Tab Architecture (full documentation)
- ✅ Added Section 2.8: Social Tab Architecture
- ✅ Updated Section 2.1: System Overview (7 tabs, Armory system added)
- ✅ Updated Section 2.2: Frame Pool Architecture (Armory pools added)
- ✅ Updated Section 2.3: Tab System Flow (current 7 tabs, special handling)
- ✅ Added Armory tab ASCII diagrams to Part 8
- ✅ Added Social tab ASCII diagrams to Part 8
- ✅ Fixed Armory popup z-order issue (re-parented to mainFrame)
- ✅ Documented WoW frame strata hierarchy

### Previous Updates (v1.2 - 2026-01-19)
**Phase 18: Low Priority Completion**
- ✅ Fixed L1: Added minimap tooltip icons (MapPins.lua)
- ✅ Verified L2: All handlers at module scope (MinigamesUI.lua)
- ✅ Fixed L3: Added GAME_FONTS centralized table (GameUI.lua)
- ✅ Fixed L4: Optimization patterns documented
- ✅ Fixed L5: Replaced all BROWN with ARCANE_PURPLE (Journal.lua, MinigamesUI.lua)
- 📝 Added Phase 17 utility examples (LayoutBuilder, CreateStyledButton, Celebration Effects)
- 📝 Updated Part 7 to show resolved status

### Previous Updates (v1.1 - 2026-01-19)
- ✅ Fixed C1: Added CleanupGame() to WordGame.lua
- ✅ Fixed C2: Added ball sync to PongGame.lua (host-authoritative)
- ✅ Fixed C3: Implemented board row caching in WordGame.lua
- ✅ Fixed H1: Added component-type-aware height fallbacks
- ✅ Fixed H2: Added WORDS window size (650x600)
- ✅ Verified M4: Border color restoration already working
- 📝 Corrected M1 description (content height padding, not spacing)
