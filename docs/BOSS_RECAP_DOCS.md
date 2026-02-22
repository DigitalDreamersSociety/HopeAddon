# Boss Kill Recap System

## Overview

The boss kill recap system provides visual feedback when a raid boss is defeated. It consists of two sequential phases:

1. **Celebratory Flash** (2-3 seconds) - A snappy popup showing boss name, kill time, personal best, and kill count with animated bars
2. **Breakdown Panel** (30 seconds or click to dismiss) - A Power BI-style dashboard showing DPS, HPS, damage taken, and deaths with class-colored bars

**Trigger:** Boss dies (detected via COMBAT_LOG_EVENT_UNFILTERED UNIT_DIED or ENCOUNTER_END) in a raid instance.

## Architecture

```
Combat Event Flow:
COMBAT_LOG_EVENT_UNFILTERED
    |
    +---> RaidData:OnCombatLogEvent()    -- Boss kill detection (UNIT_DIED)
    |         |
    |         +---> EncounterTracker:FinishEncounter()
    |         +---> RaidData:RecordBossKill()
    |         +---> RaidData:ShowRaidBossStats()    -- Phase 1: Flash
    |                    |
    |                    +---> [2-3s auto-hide]
    |                    +---> RaidData:HideRaidBossStats(callback)
    |                              |
    |                              +---> BossBreakdown:ShowBreakdown()  -- Phase 2: Breakdown
    |
    +---> EncounterTracker:ProcessCombatEvent()  -- Accumulate DPS/HPS/deaths

PLAYER_REGEN_DISABLED  --> EncounterTracker:StartTracking()
PLAYER_REGEN_ENABLED   --> 5s abort timer (if no boss kill detected)
```

### File Map

| File | Purpose |
|------|---------|
| `Raids/RaidData.lua` | Boss kill detection, celebratory flash popup, event wiring |
| `Raids/EncounterTracker.lua` | Combat log parser collecting per-player stats during encounters |
| `Raids/BossBreakdown.lua` | Power BI-style breakdown panel UI |

## Phase 1: Celebratory Flash

**Window:** `HopeRaidBossStats` (340x240 normal, 400x300 final boss)

### Content
- Boss icon + name
- "DEFEATED" subtitle (phase-colored)
- Raid name + kill count
- Kill time bar (animated fill) with best time marker
- Personal best badge (on new PB)
- Boss quote + raid progress (final boss only)

### Animation Timings
| Animation | Normal Boss | Final Boss |
|-----------|------------|------------|
| Slide-in duration | 0.3s | 0.35s |
| Bar animation delay | 0.3s | 0.3s |
| Count-up delay | 0.25s | 0.4s |
| Shake (final only) | - | 0.5s delay, 0.2s duration |
| Display duration | 2.0s | 3.0s |
| Fade-out | 0.5s | 0.5s |

### Final Boss Extras
- Shake effect on window
- EpicGlow on boss icon (phase-colored)
- CelebrateAchievement bounce on title
- Boss quote display
- Raid progress text

### Celebratory Flash - UI Blueprint

Every UI element in `CreateRaidStatsWindow()` (`RaidData.lua:535-716`):

| Element | Type | Size | Anchor | Font/Texture | Color |
|---------|------|------|--------|--------------|-------|
| Main window | Frame "HopeRaidBossStats" | 340x240 (400x300 final) | CENTER, 0, 100 | Backdrop: DARK_FEL | bg(0.1,0.1,0.1,0.95) border=phase color |
| Boss icon | Texture (ARTWORK) | 44x44 | TOPLEFT, 15, -15 | TexCoord 0.08-0.92 | - |
| Boss name | FontString (OVERLAY) | auto, R clamped -40 | LEFT of icon +12 | HEADER 15pt | white (1,1,1) |
| "DEFEATED" | FontString (OVERLAY) | auto | TOPLEFT of name, BL, 0, -2 | SMALL 10pt | phase color |
| Raid name | FontString (OVERLAY) | auto | TOPLEFT of defeated, BL, 0, -1 | SMALL 10pt | (0.7,0.7,0.7) |
| Separator | Texture (ARTWORK) | (W-30)x1 | TOP, 0, -68 | SOLID / WHITE8X8 | phase color @ 0.6a |
| Stats container | Frame | 300x40 | TOP, 0, -78 | - | - |
| "Kill Time:" label | FontString (OVERLAY) | auto | TOPLEFT of stats | BODY 12pt | (0.7,0.7,0.7) |
| Kill time value | FontString (OVERLAY) | auto | LEFT of label +5 | BODY 12pt | white (1,1,1) |
| "Best:" label | FontString (OVERLAY) | auto | TOPLEFT of stats, X=160 | BODY 12pt | (0.7,0.7,0.7) |
| Best time value | FontString (OVERLAY) | auto | LEFT of best label +5 | BODY 12pt | green(0.2,0.8,0.2) or gold(1,0.84,0) on PB |
| Kill count text | FontString (OVERLAY) | auto | TOPRIGHT of stats | HEADER 13pt | white (1,1,1) |
| Bar container | Frame | 300x18 (360 final) | TOP of stats, BOTTOM, 0, -10 | - | - |
| Bar background | Texture (BACKGROUND) | fills container | AllPoints | WHITE8X8 | (0.15,0.15,0.15,0.8) |
| Kill time bar | Texture (ARTWORK) | Hx18 | LEFT of container | STATUS_BAR | phase color |
| Best marker | Texture (OVERLAY) | 2x22 | LEFT + calculated X | WHITE8X8 | (0.2,0.8,0.2,1) |
| PB badge | FontString (OVERLAY) | auto | TOP of bar, BOTTOM, 0, -5 | HEADER 11pt | gold (1,0.84,0) |
| Quote container | Frame+BackdropTemplate | 300x50 | TOP of PB, BOTTOM, 0, -8 | Backdrop: TOOLTIP_SMALL | bg(0.12,0.12,0.12,0.9) border=phase*0.7 @ 0.6a |
| Quote text | FontString (OVERLAY) | inset TL(8,-6) BR(-8,16) | fills quote container | BODY 10pt, wrap, CENTER/TOP | (0.85,0.85,0.85) |
| Quote attribution | FontString (OVERLAY) | auto | BOTTOMRIGHT of quote, -8, 4 | SMALL 9pt | (0.5,0.5,0.5) |
| Progress text | FontString (OVERLAY) | auto | BOTTOM, 0, 15 | BODY 11pt | gold(1,0.84,0) or grey(0.7,0.7,0.7) |
| Close button | UIPanelCloseButton | standard | TOPRIGHT, -2, -2 | - | - |

**Window strata:** HIGH. Clamped to screen. Hidden by default.

**Bar fill animation pattern** (`RaidData.lua:805-839`):
```lua
-- Bar width varies: 300 for normal boss, 360 for final boss
local barWidth = isFinal and 360 or 300

-- Target width calculation
local maxTime = max(killTime, bestTime)
maxTime = maxTime * 1.1  -- 10% padding

local targetBarWidth = (killTime / maxTime) * barWidth

-- Best marker position
local markerX = (bestTime / maxTime) * barWidth - 1

-- Animate from 0.001 to targetBarWidth over 0.3s after 0.3s delay
HopeAddon.Timer:After(0.3, function()
    HopeAddon.Animations:AnimateValue(0.001, targetBarWidth, 0.3, function(current)
        window.thisBar:SetWidth(math.max(0.001, current))
    end)
end)
```

**Entrance animation** (`RaidData.lua:879-897`):
- Window starts at alpha=0, Y=130
- FadeIn + MoveTo Y=100 over `slideDuration` (0.3s normal, 0.35s final)
- Effectively slides 30px downward while fading in

## Phase 2: Breakdown Panel

**Window:** `HopeBossBreakdown` (480px wide, dynamic height)

### Layout
```
+--[ ENCOUNTER BREAKDOWN ]-------------------+
| [Icon]  BOSS NAME                          |
|          Raid Name  |  Kill #X  |  3:45    |
| -------- separator --------                |
|                                            |
| TOP DAMAGE (DPS)      TOP HEALING (HPS)    |
| [class] Name  1.2K   [class] Name  980    |
| [class] Name  1.1K   [class] Name  850    |
| [class] Name   980   [class] Name  720    |
| [class] Name   890   [class] Name  650    |
| [class] Name   750   [class] Name  590    |
|                                            |
| -------- separator --------                |
|                                            |
| DAMAGE TAKEN           DEATHS (3)          |
| [class] Tank1  1.5M   Unlucky   (0:45)    |
| [class] Tank2  980K   Oops      (1:23)    |
| [class] Dps1   450K   StoodFire (2:10)    |
|                                            |
|        [Click anywhere to dismiss]         |
+--------------------------------------------+
```

### Visual Design
- **Background:** Very dark (0.08, 0.08, 0.08, 0.95)
- **Border:** Phase-colored (KARA_PURPLE through SUNWELL_GOLD)
- **Bar fills:** WoW class colors via `HopeAddon:GetClassColor(class)`
- **Section headers:** GOLD_BRIGHT
- **Bar backgrounds:** (0.12, 0.12, 0.12, 0.9)
- **Death timestamps:** Red-tinted (0.8, 0.3, 0.3)

### Animation Sequence
1. Panel fades in (0.4s)
2. DPS bars animate left-to-right, staggered 0.1s apart (0.3s each), starting at 0.3s
3. HPS bars animate same pattern after DPS completes
4. Damage taken bars animate after HPS
5. Death entries fade in as a group after damage taken
6. Auto-dismiss after 30 seconds, or click anywhere to dismiss immediately

### Number Formatting
- >= 1,000,000 -> "1.5M"
- >= 1,000 -> "1.2K"
- < 1,000 -> "980"

### Breakdown Panel - UI Blueprint

Layout constants (`BossBreakdown.lua:24-32`):
```
PANEL_WIDTH  = 480    BAR_HEIGHT   = 16    BAR_SPACING  = 2
BAR_WIDTH    = 180    COLUMN_LEFT_X = 15   COLUMN_RIGHT_X = 250
SECTION_SPACING = 8   AUTO_HIDE_DURATION = 30
```

Every UI element in `CreateBreakdownPanel()` (`BossBreakdown.lua:117-275`):

| Element | Type | Size | Anchor | Font/Texture | Color |
|---------|------|------|--------|--------------|-------|
| Main panel | Frame "HopeBossBreakdown" | 480x420 (dynamic H) | CENTER, 0, 0 | Backdrop: DARK_FEL | bg(0.08,0.08,0.08,0.95) border=phase color |
| Boss icon | Texture (ARTWORK) | 36x36 | TOPLEFT, 15, -12 | TexCoord 0.08-0.92 | - |
| Boss name | FontString (OVERLAY) | auto, R clamped -15 | TOPLEFT of icon TR +10, -2 | HEADER 14pt | white (1,1,1) |
| Subtitle | FontString (OVERLAY) | auto | TOPLEFT of name, BL, 0, -2 | SMALL 10pt | (0.7,0.7,0.7) |
| Title label | FontString (OVERLAY) | auto | TOPRIGHT, -15, -12 | SMALL 9pt | (0.5,0.5,0.5) |
| Header separator | Texture (ARTWORK) | (W-30)x1 | TOP, 0, -56 | WHITE8X8 | phase color @ 0.6a |
| DPS header | FontString (OVERLAY) | auto | TOPLEFT, X=15, Y=-66 | HEADER 11pt | GOLD_BRIGHT |
| HPS header | FontString (OVERLAY) | auto | TOPLEFT, X=250, Y=-66 | HEADER 11pt | GOLD_BRIGHT |
| DPS bars (5) | CreateBarRow | 180x16 each | TOPLEFT, X=15, Y=-(82 + i*18) | see CreateBarRow | class-colored fill |
| HPS bars (5) | CreateBarRow | 180x16 each | TOPLEFT, X=250, Y=-(82 + i*18) | see CreateBarRow | class-colored fill |
| Mid separator | Texture (ARTWORK) | (W-30)x1 | TOP, 0, -178 | WHITE8X8 | (0.3,0.3,0.3,0.5) |
| DT header | FontString (OVERLAY) | auto | TOPLEFT, X=15, Y=-188 | HEADER 11pt | GOLD_BRIGHT |
| Deaths header | FontString (OVERLAY) | auto | TOPLEFT, X=250, Y=-188 | HEADER 11pt | GOLD_BRIGHT |
| DT bars (3) | CreateBarRow | 180x16 each | TOPLEFT, X=15, Y=-(204 + i*18) | see CreateBarRow | class-colored fill |
| Death entries (5) | 2x FontString | auto | TOPLEFT, X=250, Y=-(204 + i*15) | SMALL 10pt | name=class-colored, time=(0.8,0.3,0.3) |
| Dismiss hint | FontString (OVERLAY) | auto | BOTTOM, 0, 8 | SMALL 9pt | (0.4,0.4,0.4) |
| "No data" text | FontString (OVERLAY) | auto | CENTER, 0, -20 | BODY 12pt | (0.5,0.5,0.5) |

**Window strata:** HIGH. Clamped to screen. Click-to-dismiss via OnMouseDown. Hidden by default.

**Bar row Y offsets** (18px apart = BAR_HEIGHT 16 + BAR_SPACING 2):
```
DPS/HPS rows: Y = -(82 + (i-1) * 18)  for i=1..5
  Row 1: Y=-82   Row 2: Y=-100   Row 3: Y=-118   Row 4: Y=-136   Row 5: Y=-154

DT rows:      Y = -(204 + (i-1) * 18)  for i=1..3
  Row 1: Y=-204  Row 2: Y=-222   Row 3: Y=-240

Death rows:   Y = -(204 + (i-1) * 15)  for i=1..5
  Row 1: Y=-204  Row 2: Y=-219   Row 3: Y=-234   Row 4: Y=-249   Row 5: Y=-264
```

**CreateBarRow() internals** (`BossBreakdown.lua:81-112`):
```
bg:        Texture WHITE8X8  180x16  TOPLEFT at (xOffset, -yOffset)  layer=BACKGROUND
           color(0.12, 0.12, 0.12, 0.9)

fill:      Texture STATUS_BAR  Hx16  LEFT of bg  layer=ARTWORK
           width starts at 0.001  color = class-colored @ 0.85a

nameText:  FontString SMALL 10pt  LEFT of bg +4  layer=OVERLAY
           justifyH=LEFT  color=white (1,1,1)

valueText: FontString SMALL 10pt  RIGHT of bg -4  layer=OVERLAY
           justifyH=RIGHT  color=white (1,1,1)
```

**Bar width calculation** (`BossBreakdown.lua:309-310`):
```lua
local proportion = maxVal > 0 and (entry.total / maxVal) or 0  -- maxVal = topDPS[1].total
local targetWidth = math_max(1, proportion * BAR_WIDTH)         -- BAR_WIDTH = 180
```

**Dynamic height formula** (`BossBreakdown.lua:450-453`):
```lua
local hasDeaths = encounterSummary and #(encounterSummary.deaths or {}) > 0
local deathCount = encounterSummary and math_min(#(encounterSummary.deaths or {}), 5) or 0
local bottomY = hasDeaths and (204 + deathCount * 15 + 30) or 270
panel:SetHeight(math_max(bottomY, 280))
```

**PopulateBars stagger timing** (`BossBreakdown.lua:286-343`):
```lua
-- Each bar animates 0.1s after the previous one, each fill takes 0.3s
local barDelay = baseDelay + (i - 1) * 0.1  -- i = bar index (1-based)
-- Section returns: baseDelay + usedCount * 0.1 + 0.3 (last bar's completion time)
-- Next section's baseDelay = previous section's return value
```

## Backdrop & Texture Reference

### Backdrop Definitions

**DARK_FEL** (`Constants.lua:4385-4392`) - Main window backdrop for both flash and breakdown:
```lua
{
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- Grayscale, tintable
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
}
```

**TOOLTIP_SMALL** (`Constants.lua:4290-4297`) - Quote container backdrop:
```lua
{
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 8,
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
}
```

### Textures

| Key | Path | Used For |
|-----|------|----------|
| TEX_WHITE8X8 | `Interface\BUTTONS\WHITE8X8` | Solid fill: separators, bar backgrounds, best marker |
| TEX_STATUS_BAR | `Interface\TARGETINGFRAME\UI-StatusBar` | Gradient bar fills (kill time bar, breakdown bars) |

### Fonts

All recap UI fonts use the same typeface at different sizes:

| Key | Path | Sizes used |
|-----|------|-----------|
| HEADER | `Fonts\FRIZQT__.TTF` | 15pt (boss name), 14pt (breakdown name), 13pt (kill count), 11pt (section headers, PB badge) |
| BODY | `Fonts\FRIZQT__.TTF` | 12pt (kill time/best labels), 11pt (progress text), 10pt (quote text, no-data) |
| SMALL | `Fonts\FRIZQT__.TTF` | 10pt (defeated, raid name, subtitle, bar text, death entries), 9pt (attribution, title label, dismiss hint) |

## Color Reference

### Phase Colors

Used for window borders, separator lines, "DEFEATED" text, and kill time bar fills.

| Name | Phase | R | G | B | A | Hex | Raid(s) |
|------|-------|---|---|---|---|-----|---------|
| KARA_PURPLE | 1 | 0.50 | 0.30 | 0.70 | 1.0 | #804DB3 | Karazhan, Gruul's Lair, Magtheridon's Lair |
| SSC_BLUE | 2 | 0.20 | 0.60 | 0.90 | 1.0 | #3399E6 | Serpentshrine Cavern, Tempest Keep |
| BT_FEL | 3 | 0.30 | 0.80 | 0.30 | 1.0 | #4DCC4D | Mount Hyjal, Black Temple |
| ZA_TRIBAL | 4 | 0.80 | 0.55 | 0.25 | 1.0 | #CC8C40 | Zul'Aman |
| SUNWELL_GOLD | 5 | 1.00 | 0.90 | 0.40 | 1.0 | #FFE666 | Sunwell Plateau |

Mapping in `RaidData.lua:216-222` via `PHASE_COLOR_NAMES[phaseNumber]`.

### Class Colors

Applied to breakdown bar fills at 0.85 alpha. Source: `Core.lua:683-693`.

| Class | R | G | B | Hex |
|-------|---|---|---|-----|
| WARRIOR | 0.78 | 0.61 | 0.43 | #C79C6E |
| PALADIN | 0.96 | 0.55 | 0.73 | #F58CBA |
| HUNTER | 0.67 | 0.83 | 0.45 | #ABD473 |
| ROGUE | 1.00 | 0.96 | 0.41 | #FFF569 |
| PRIEST | 1.00 | 1.00 | 1.00 | #FFFFFF |
| SHAMAN | 0.00 | 0.44 | 0.87 | #0070DE |
| MAGE | 0.41 | 0.80 | 0.94 | #69CCF0 |
| WARLOCK | 0.58 | 0.51 | 0.79 | #9482C9 |
| DRUID | 1.00 | 0.49 | 0.04 | #FF7D0A |

### UI Colors Used in Recap

| Usage | R | G | B | A | Notes |
|-------|---|---|---|---|-------|
| GOLD_BRIGHT | 1.00 | 0.84 | 0.00 | 1.0 | Section headers (DPS, HPS, DT, Deaths) |
| PB badge / "RAID COMPLETE!" | 1.00 | 0.84 | 0.00 | 1.0 | Same gold |
| Best time (normal) | 0.20 | 0.80 | 0.20 | 1.0 | Green, non-PB best time |
| Best marker line | 0.20 | 0.80 | 0.20 | 1.0 | Green vertical line on bar |
| Flash bg | 0.10 | 0.10 | 0.10 | 0.95 | Celebratory flash backdrop |
| Breakdown bg | 0.08 | 0.08 | 0.08 | 0.95 | Breakdown panel backdrop |
| Bar background | 0.15 | 0.15 | 0.15 | 0.80 | Flash kill time bar bg |
| Bar background (breakdown) | 0.12 | 0.12 | 0.12 | 0.90 | Breakdown bar row bg |
| Quote container bg | 0.12 | 0.12 | 0.12 | 0.90 | Quote frame backdrop |
| Quote text | 0.85 | 0.85 | 0.85 | 1.0 | - |
| Quote attribution | 0.50 | 0.50 | 0.50 | 1.0 | - |
| Label grey | 0.70 | 0.70 | 0.70 | 1.0 | "Kill Time:", "Best:", raid name, subtitle |
| Mid separator | 0.30 | 0.30 | 0.30 | 0.50 | Breakdown mid separator |
| Dismiss hint | 0.40 | 0.40 | 0.40 | 1.0 | "Click anywhere to dismiss" |
| Title label | 0.50 | 0.50 | 0.50 | 1.0 | "ENCOUNTER BREAKDOWN" |
| No data text | 0.50 | 0.50 | 0.50 | 1.0 | "No encounter data available" |
| Death timestamps | 0.80 | 0.30 | 0.30 | 1.0 | Red-tinted time display |

## EncounterTracker Data Schema

### `encounterState` (ephemeral, per-fight)

```lua
encounterState = {
    active       = false,       -- boolean: currently tracking?
    startTime    = nil,         -- number: GetTime() at combat start
    endTime      = nil,         -- number: GetTime() at boss death (nil if active)
    raidMembers  = {},          -- { [guid:string] = { name:string, class:string } }
    players      = {},          -- { [guid:string] = PlayerStats }
    deathLog     = {},          -- { DeathEntry, ... } (chronological order)
    totalDamage  = 0,           -- number: sum of all player damage
    totalHealing = 0,           -- number: sum of all net healing
}

-- PlayerStats shape:
{
    name        = "Playername",  -- string
    class       = "WARRIOR",     -- string: uppercase English class token
    damage      = 0,             -- number: total damage dealt
    healing     = 0,             -- number: total net healing (minus overhealing)
    damageTaken = 0,             -- number: total damage received
    deaths      = 0,             -- number: death count
}

-- DeathEntry shape:
{
    name       = "Playername",   -- string
    class      = "WARRIOR",      -- string
    timestamp  = 45.3,           -- number: seconds elapsed since encounter start
    killerName = nil,            -- string|nil (currently unused, reserved)
    spellName  = nil,            -- string|nil (currently unused, reserved)
}
```

### `GetEncounterSummary()` return shape

```lua
{
    duration       = 185.4,        -- number: fight length in seconds
    totalDamage    = 4523000,      -- number: total raid damage dealt
    totalHealing   = 2100000,      -- number: total raid net healing
    totalDeaths    = 3,            -- number: total death count across all players

    topDPS = {                     -- table[]: sorted desc by total, max 5 entries
        {
            name      = "Dps1",    -- string
            class     = "ROGUE",   -- string
            total     = 850000,    -- number: total damage dealt
            perSecond = 4587.5,    -- number: total / duration
        },
        -- ... up to 5 entries
    },

    topHPS = {                     -- table[]: sorted desc by total, max 5 entries
        {
            name      = "Healer1", -- string
            class     = "PRIEST",  -- string
            total     = 620000,    -- number: total net healing
            perSecond = 3344.1,    -- number: total / duration
        },
        -- ... up to 5 entries
    },

    topDamageTaken = {             -- table[]: sorted desc by total, max 3 entries
        {
            name  = "Tank1",       -- string
            class = "WARRIOR",     -- string
            total = 1500000,       -- number: total damage received
        },
        -- ... up to 3 entries
    },

    deaths = {                     -- table[]: chronological order, all deaths (unbounded)
        {
            name       = "Unlucky",   -- string
            class      = "MAGE",      -- string
            timestamp  = 45.3,        -- number: seconds into fight
            killerName = nil,         -- string|nil (reserved)
            spellName  = nil,         -- string|nil (reserved)
        },
        -- ... all deaths during encounter
    },
}
```

### Tracked Combat Events (TBC 2.4.3)

| Sub-Event | What it tracks | Amount position |
|-----------|---------------|-----------------|
| SWING_DAMAGE | Player damage dealt | arg9 |
| SPELL_DAMAGE | Player damage dealt | arg12 |
| RANGE_DAMAGE | Player damage dealt | arg12 |
| SPELL_PERIODIC_DAMAGE | Player damage dealt (DoTs) | arg12 |
| SPELL_HEAL | Player healing done | arg12 (minus arg13 overhealing) |
| SPELL_PERIODIC_HEAL | Player healing done (HoTs) | arg12 (minus arg13 overhealing) |
| UNIT_DIED | Player deaths | - |
| *_DAMAGE (non-raid source) | Damage taken by raid members | same as above |

### Combat Log Arg Format (TBC 2.4.3, NO hideCaster)
```
arg1=timestamp, arg2=subEvent, arg3=srcGUID, arg4=srcName, arg5=srcFlags,
arg6=destGUID, arg7=destName, arg8=destFlags, arg9+...=payload
```

### Performance Notes
- Sub-event lookup via hash table (O(1) instead of string comparison chain)
- Raid members stored in GUID-keyed table (O(1) lookup per event)
- Early return on irrelevant events before any processing
- Healing accounts for overhealing (net effective healing only)

### State Management
- `StartTracking()` - Called on PLAYER_REGEN_DISABLED in raid instances. Snapshots raid composition.
- `ProcessCombatEvent(...)` - Called per combat log event while active. Fast-path filtering.
- `FinishEncounter()` - Called when boss death detected. Marks inactive, preserves data.
- `AbortTracking()` - Called 5s after combat ends with no boss kill. Clears all state.
- `GetEncounterSummary()` - Returns sorted top-N lists for display.

## Animation Chain Timeline

Complete animation sequence from boss death to breakdown dismiss. Times shown for a **normal boss** (final boss timings in parentheses where different).

```
T+0.0s   Boss dies -> UNIT_DIED detected
         EncounterTracker:FinishEncounter()
         RaidData:RecordBossKill()
         Flash window created: alpha=0, Y=130, Show()

T+0.0s   FadeIn starts (0.3s) (0.35s final)
         MoveTo Y=100 starts (0.3s) (0.35s final)

T+0.25s  CountUp "Kill #X" animation starts, 0.5s duration (0.4s delay for final)

T+0.3s   Bar fill animates: 0.001 -> targetBarWidth over 0.3s
         (0.35s: Flash fully visible for final boss)

T+0.3s   [Flash fully visible, at final position Y=100]

T+0.5s   [Final only] Shake effect: 4px amplitude, 0.2s duration
         [Final only] EpicGlow on boss icon (phase-colored)

T+0.6s   Bar fill animation complete

T+0.75s  CountUp animation complete

T+0.8s   [Final only] CelebrateAchievement bounce on boss name

T+2.0s   Auto-hide timer fires (3.0s for final)
         FadeOut starts (0.5s)

T+2.5s   Flash hidden (3.5s for final)
         Callback fires -> chain to breakdown

T+2.5s   Breakdown panel: alpha=0, Show()
         FadeIn starts (0.4s)

T+2.8s   DPS bars animate (staggered 0.1s apart, 0.3s fill each)
         5 bars: 0.3s, 0.4s, 0.5s, 0.6s, 0.7s start times (relative to panel show)
         Section complete at baseDelay + 5*0.1 + 0.3 = 1.1s relative

T+2.9s   Breakdown fully visible (fade complete)

T+3.6s   HPS bars animate (same stagger pattern, baseDelay = DPS completion)

T+4.4s   DT bars animate (3 bars, baseDelay = HPS completion)

T+4.9s   Death entries fade in (as a group, after DT completion)

T+32.5s  Breakdown auto-hide timer fires (30s from show)
         FadeOut (0.4s), then Hide()
```

**With animations disabled** (`animationsEnabled = false`):
- Flash: instant show at full alpha, bars at final width immediately
- Breakdown: instant show, all bars at final width, no stagger
- Timers still apply for auto-hide

## Boss Detection

### Primary: COMBAT_LOG_EVENT_UNFILTERED
Watches for `UNIT_DIED` events where the dying unit's NPC ID matches `BOSS_NPC_IDS` in Constants.lua. Works reliably in TBC Classic 2.4.3.

### Fallback: ENCOUNTER_END
Registered but may not fire in TBC Classic. Provides encounterID -> boss mapping via `ENCOUNTER_TO_BOSS`.

### Duplicate Prevention
Both detection paths write to `recentKills[killKey]` with a 10-second dedup window. Expired entries cleaned after 15 seconds.

## Kill Time Sources

1. **DBM/BigWigs** (preferred) - Parses chat messages matching patterns like "Boss down after 3:45!"
2. **Manual timer** (fallback) - Tracks PLAYER_REGEN_DISABLED to boss death time

## Configuration

The recap system respects `HopeAddon.db.settings.animationsEnabled`:
- **Enabled (default):** Full animated bars, fade transitions, staggered reveals
- **Disabled:** Instant show/hide, bars at final width immediately

## Extending

### Adding New Raids/Bosses
1. Add boss data to Constants.lua (BOSS_NPC_IDS, raid boss definitions)
2. Add phase color mapping in RaidData.lua PHASE_COLOR_NAMES if new phase
3. No changes needed in EncounterTracker or BossBreakdown - they work generically

### Adding New Breakdown Sections
1. Add new data collection in EncounterTracker:ProcessCombatEvent()
2. Include in GetEncounterSummary() return value
3. Add UI rows in BossBreakdown:CreateBreakdownPanel()
4. Populate in BossBreakdown:ShowBreakdown()

### Future: External Data Sources
EncounterTracker is designed to be replaceable. To accept data from damage meters:
- Implement an adapter that populates the same summary format as GetEncounterSummary()
- BossBreakdown:ShowBreakdown() accepts any summary matching the expected shape
