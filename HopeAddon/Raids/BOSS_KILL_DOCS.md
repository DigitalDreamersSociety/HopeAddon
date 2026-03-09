# Boss Kill Popup System

Documentation for the boss kill popup system: current implementation and redesign spec.

---

## Table of Contents

1. [Current System](#1-current-system)
   - [1a. Raid Boss Stats Window](#1a-raid-boss-stats-window)
   - [1b. Boss Breakdown Panel](#1b-boss-breakdown-panel)
   - [1c. First-Kill Notification](#1c-first-kill-notification)
   - [Data Flow](#data-flow)
   - [Data Structures](#data-structures)
   - [Known Issues](#known-issues)
2. [Redesign Spec — Kill Flash](#2-redesign-spec--kill-flash)
   - [Vision](#vision)
   - [Layout](#layout)
   - [Specifications](#specifications)
   - [Vignette — Raid-Themed Tinting](#vignette--raid-themed-tinting)
   - [Boss Icon — EpicGlow + BurstEffect](#boss-icon--epicglow--bursteffect)
   - [DEFEATED Text — Letter-Spaced, Phase-Colored](#defeated-text--letter-spaced-phase-colored)
   - [Animation Sequence](#animation-sequence)
   - [Sound](#sound)
   - [Top 3 DPS Bars](#top-3-dps-bars)
   - [What to Keep](#what-to-keep)
   - [What to Remove](#what-to-remove)
   - [Settings](#settings)
   - [Animation & Effect APIs](#animation--effect-apis)

---

## 1. Current System

Three auto-triggered components fire after a boss kill. They are chained: Stats Window shows first, then auto-hides and chains to Breakdown Panel. First-Kill Notification fires independently on kill #1.

### Trigger Path

```
UNIT_DIED (combat log)  ──┐
                          ├──► RecordBossKill() ──► ShowRaidBossStats()
ENCOUNTER_END (event)   ──┘       │
                                  ├── killData.totalKills == 1 → Journal:ShowBossKillNotification()
                                  ├── Milestones:CheckTierMilestone()
                                  └── TravelerIcons:OnBossKill()
```

Deduplication: Both `OnCombatLogEvent` and `OnEncounterEnd` use a shared `recentKills` table with 10-second cooldown per `raidKey_bossId` key (RaidData.lua:1120-1132, 1184-1197).

---

### 1a. Raid Boss Stats Window

**Source:** `RaidData.lua` — Creation: lines 540-716, Show logic: lines 724-955, Hide: lines 960-982

**Frame properties:**
- Name: `HopeRaidBossStats`
- Parent: `UIParent`
- Strata: `HIGH`
- Position: `CENTER, 0, 100` (starts at y=130, animates down to y=100)
- Size: 340x240 (normal), 400x300 (final boss)
- Backdrop: `DARK_FEL` — bg `rgba(0.1, 0.1, 0.1, 0.95)`, border phase-colored
- Has close button (`UIPanelCloseButton`)

**Content elements:**
| Element | Font/Size | Position | Details |
|---------|-----------|----------|---------|
| Boss icon | 44x44 texture | TOPLEFT 15,-15 | TexCoord cropped 0.08-0.92 |
| Boss name | HEADER 15pt | RIGHT of icon, 12px gap | White, left-justified |
| "DEFEATED" | SMALL 10pt | Below boss name, -2px | Phase-colored |
| Raid name + Kill # | SMALL 10pt | Below DEFEATED, -1px | Gray (0.7,0.7,0.7) |
| Separator line | 1px texture | TOP -68px | Phase-colored, 60% alpha |
| Kill Time label + value | BODY 12pt | TOP -78px, left side | Label gray, value white |
| Best Time label + value | BODY 12pt | TOP -78px, x=160 | Label gray, value green (or gold if PB) |
| Kill # (animated) | HEADER 13pt | TOP -78px, right-aligned | CountUp animation from 0 |
| Time bar | 18px tall, 300/360px wide | Below stats, -10px | Phase-colored fill, animated width over 0.3s |
| Best marker | 2x22 green line | On time bar | Shows best time position (hidden if new PB) |
| PB badge | HEADER 11pt | Below bar, -5px | Gold "NEW PERSONAL BEST!" — PopIn at 0.5s |
| Quote container | 300x50 frame | Below PB badge, -8px | Final boss only. Dark backdrop, phase-tinted border |
| Quote text | BODY 10pt | Inside container | Centered, word-wrapped, light gray |
| Quote attribution | SMALL 9pt | Bottom-right of container | Dim gray "- BossName" |
| Progress text | BODY 11pt | BOTTOM 15px | Final boss only. "RAID COMPLETE!" (gold) or "X/Y Bosses Cleared" (gray) |

**Duration and auto-hide:**
- Normal boss: 2.0s (`RAID_STATS_DURATION`) → FadeOut 0.5s → chain to breakdown
- Final boss: 3.0s (`RAID_STATS_FINAL_DURATION`) → FadeOut 0.5s → chain to breakdown

**Animation sequence:**
1. Window appears at alpha=0, y=130, slides down to y=100 via `MoveTo` (0.3s normal, 0.35s final)
2. `FadeIn` simultaneously (same duration)
3. Kill count `CountUp` starts at 0.25s (normal) or 0.4s (final)
4. Time bar animates width from 0 to target at 0.3s delay, over 0.3s
5. PB badge `PopIn` at 0.5s if new personal best

**Final boss extras (all gated on `isFinal`):**
- Window resized to 400x300 with wider bars (360px)
- `Shake(window, 4, 0.2)` at 0.5s
- `Glow:CreateEpicGlow(bossIcon, colorName)` at 0.5s
- `CelebrateAchievement(bossName)` at 0.8s
- Quote container shown with boss quote + attribution
- Progress text shown at bottom

**Sound:**
- Normal: `HopeAddon.Sounds:PlayBossKill()`
- Final: `HopeAddon.Sounds:PlayVictory()`

**Chaining mechanism (RaidData.lua:930-954):**
- On show, stores context in `self._lastRecapContext = { raidKey, bossId, killData, isFinal }`
- Auto-hide timer fires `HideRaidBossStats(callback)`
- Callback checks `HopeAddon.EncounterTracker:GetEncounterSummary()` for data
- If `#summary.topDPS > 0 or #summary.topHPS > 0`, calls `BossBreakdown:ShowBreakdown(...)`

---

### 1b. Boss Breakdown Panel

**Source:** `BossBreakdown.lua` — entire file, lines 1-523

**Frame properties:**
- Name: `HopeBossBreakdown`
- Parent: `UIParent`
- Strata: `HIGH`
- Position: `CENTER, 0, 0`
- Size: 480x420 (dynamically resized based on death count, minimum 280)
- Backdrop: `DARK_FEL` — bg `rgba(0.08, 0.08, 0.08, 0.95)`, border phase-colored

**Layout constants:**
```lua
PANEL_WIDTH = 480
PANEL_HEIGHT = 420
BAR_HEIGHT = 16
BAR_SPACING = 2
BAR_WIDTH = 180
SECTION_SPACING = 8
COLUMN_LEFT_X = 15
COLUMN_RIGHT_X = 250
AUTO_HIDE_DURATION = 30
```

**Content — 4 sections in 2-column layout:**

| Section | Position | Max entries | Data source |
|---------|----------|-------------|-------------|
| Top Damage (DPS) | Left column, y=-66 | 5 bars | `summary.topDPS` — shows `perSecond` |
| Top Healing (HPS) | Right column, y=-66 | 5 bars | `summary.topHPS` — shows `perSecond` |
| Damage Taken | Left column, y=-188 | 3 bars | `summary.topDamageTaken` — shows `total` |
| Deaths | Right column, y=-188 | 5 text entries | `summary.deaths` — name (class-colored) + timestamp |

**Bar row structure** (per `CreateBarRow`):
- Background: 180x16, dark gray (`rgba(0.12, 0.12, 0.12, 0.9)`)
- Fill bar: class-colored via `HopeAddon:GetClassColor()`, 85% alpha
- Name text: SMALL 10pt, left-aligned inside bar, white
- Value text: SMALL 10pt, right-aligned inside bar, white

**Death entry structure:**
- Name: SMALL 10pt, class-colored
- Timestamp: SMALL 10pt, red-tinted `(0.8, 0.3, 0.3)`, format "(M:SS)"

**Animation:**
- Panel fades in over 0.4s
- DPS bars animate with staggered reveal: each bar starts at width 0, animates to proportional width over 0.3s, with 0.1s stagger between bars
- HPS bars start after DPS bars finish
- Damage Taken bars start after HPS bars finish
- Death entries fade in after Damage Taken bars finish
- All animations respect `animationsEnabled` setting — instant fallback if disabled

**Duration:** Fixed 30 seconds (`AUTO_HIDE_DURATION`), then `FadeOut(0.4s)`

**Dismissal:** Click anywhere on panel calls `HideBreakdown()`

**No-data fallback:** If `#topDPS == 0 and #topHPS == 0`, hides all sections and shows "No encounter data available" text centered.

**Number formatting:** `FormatNumber()` — `>=1M` → "1.2M", `>=1K` → "1.2K", else integer

---

### 1c. First-Kill Notification

**Source:** `Journal.lua` — lines 19913-19952

**Trigger:** Only when `killData.totalKills == 1` (first kill of a specific boss)

**Flow:** `ShowBossKillNotification(killData)` → queues via `QueueNotification("bossKill", killData)` → `ShowBossKillNotificationInternal(killData)`

**Frame:** Acquired from `self.notificationPool` (shared notification frame pool)
- Size: `NOTIF_WIDTH_LARGE x NOTIF_HEIGHT_LARGE`
- Position: `TOP, UIParent, TOP, 0, NOTIF_TOP_OFFSET`
- Backdrop: `DARK_FEL` / `RED_TINT` / `FEL_GREEN`

**Content:**
| Element | Font/Size | Text |
|---------|-----------|------|
| Title | TITLE 18pt | "VICTORY!" (HELLFIRE_RED colored) |
| Line 1 | HEADER 14pt | "{BossName} defeated!" (white) |
| Line 2 | BODY 11pt | Raid name (tertiary color) |

**Animation:** `NotificationSlideIn` (slides from y=50 to y=-100 over 0.4s with fade) → 3 second hold → `NotificationSlideOut` (slides back up, fades out over 0.3s) → release back to pool

---

### Data Flow

```
COMBAT_LOG / ENCOUNTER_END
    │
    ▼
RaidData:OnCombatLogEvent() / OnEncounterEnd()    [RaidData.lua:1103-1231]
    │
    ├── EncounterTracker:FinishEncounter()          [captures final stats]
    │
    ├── RaidData:RecordBossKill(raidKey, bossId)    [RaidData.lua:320-424]
    │   └── Returns killData table (see Data Structures)
    │
    ├── RaidData:ShowRaidBossStats(raidKey, bossId, killData)  [RaidData.lua:724-955]
    │   └── After DURATION seconds:
    │       └── HideRaidBossStats(callback)          [RaidData.lua:960-982]
    │           └── callback → EncounterTracker:GetEncounterSummary()
    │               └── BossBreakdown:ShowBreakdown(raidKey, bossId, killData, summary, isFinal)
    │
    ├── Journal:ShowBossKillNotification(killData)   [only totalKills == 1]
    ├── Milestones:CheckTierMilestone()              [only totalKills == 1]
    └── TravelerIcons:OnBossKill()                   [always]
```

---

### Data Structures

**killData** (returned by `RecordBossKill`, stored in `charDb.journal.bossKills[key]`):
```lua
{
    type = "boss_kill",
    raidKey = "KARAZHAN",           -- raid identifier
    bossId = "ATTUMEN",             -- boss identifier
    bossName = "Attumen the Huntsman",
    raidName = "Karazhan",
    location = "...",
    lore = "...",
    firstKill = "2024-03-15",       -- date string
    firstKillTimestamp = 1710504000, -- epoch
    totalKills = 5,
    icon = "Interface\\Icons\\...",
    bestTime = 45.2,                -- seconds (nil if no timer data)
    bestTimeDate = "2024-03-20",
    lastTime = 52.1,                -- this kill's time
    killTimes = { ... },            -- array of recent times
    lastKill = "2024-03-22",        -- date of most recent kill
}
```

**encounterSummary** (from `EncounterTracker:GetEncounterSummary()`):
```lua
{
    duration = 45.2,                -- encounter duration in seconds
    totalDamage = 1500000,
    totalHealing = 800000,
    topDPS = {                      -- sorted desc, max 5
        { name = "Player", class = "WARRIOR", total = 500000, perSecond = 11062 },
        ...
    },
    topHPS = {                      -- sorted desc, max 5
        { name = "Healer", class = "PRIEST", total = 300000, perSecond = 6637 },
        ...
    },
    topDamageTaken = {              -- sorted desc, max 3
        { name = "Tank", class = "WARRIOR", total = 200000 },
        ...
    },
    deaths = {                      -- chronological
        { name = "Player", class = "MAGE", timestamp = 23.4, killerName = "Boss", spellName = "Fireball" },
        ...
    },
    totalDeaths = 2,
}
```

---

### Known Issues

1. **Stats window blocks screen center during combat** — The 340x240 window sits at `CENTER, 0, 100` during active combat (trash pulls between bosses). Players can close it manually but it's disruptive.

2. **Breakdown panel 30-second lock** — `AUTO_HIDE_DURATION = 30` with no skip/fast-forward. During fast raid clears, the panel is still showing from boss #1 when boss #2 dies. Click-to-dismiss exists but requires player attention.

3. **Two chained popups feel clunky** — Stats window (2-3s) → fade → breakdown (30s) is two separate interruptions. The chain uses `_lastRecapContext` state + callback, adding complexity.

4. **No user setting to disable** — Neither the stats window nor the breakdown panel has a settings toggle. The only escape is the close button / click-to-dismiss.

5. **First-kill notification overlaps** — The "VICTORY!" toast slides in from the top while the stats window is visible at center. Both compete for attention on the same kill event.

6. **Strata conflict** — Both windows use `HIGH` strata, which can be obscured by other addon frames using `DIALOG` or higher.

---

## 2. Redesign Spec — Kill Flash

### Vision

Replace both the Stats Window AND Breakdown Panel with a single dramatic Mortal Kombat-style kill flash. Fast, impactful, non-intrusive. ~2 seconds total, fullscreen overlay instead of a bordered popup window. Raid-themed vignette tinting, EpicGlow on all boss icons, and tight upper-middle positioning that stays out of the player's way.

### Layout

Fullscreen dark vignette overlay with content anchored to **upper-middle** screen:

```
┌──────────────────────────────────────────────────────┐
│  ░░░░░░░░░░░ raid-tinted dark vignette ░░░░░░░░░░░  │
│                                                      │
│          ✦ [Boss Icon 48x48 + EpicGlow] ✦            │  ← ~y = +200 from center
│            BOSS NAME  (TITLE 18pt, white)            │
│            D E F E A T E D  (phase-colored)          │
│            Kill #5  ·  2:34                          │
│                                                      │
│       #1 Playername  ████████████████  1.2K DPS      │
│       #2 Playername  ██████████████    980 DPS       │
│       #3 Playername  ████████████      820 DPS       │
│                                                      │
│                                                      │
│                                                      │
│                                                      │
└──────────────────────────────────────────────────────┘
```

All content anchored to `UIParent, "TOP", 0, -80` region — stays above center so it doesn't cover the player character or raid frames at screen bottom.

### Specifications

| Property | Value |
|----------|-------|
| Frame | Fullscreen overlay anchored to `UIParent`, all edges |
| Strata | `FULLSCREEN_DIALOG` |
| Background | Raid-tinted dark vignette (NOT a bordered popup box) |
| Content anchor | `UIParent, "TOP", 0, -80` — upper-middle positioning |
| Duration (normal) | ~2 seconds, then fade out (0.3s) |
| Duration (final) | ~3 seconds + shake + celebration effects |
| Dismissal | Fades automatically; no click-to-dismiss needed |

### Vignette — Raid-Themed Tinting

- Fullscreen dark overlay: base `rgba(0, 0, 0, 0.6)`
- **Tinted with raid accent color** from `C.RAID_THEMES[raidKey].accentColor`
  - Karazhan kills: purple-tinged darkness
  - SSC kills: teal-tinged
  - Black Temple: fel-green tinged
  - Sunwell: golden-tinged
- Implementation: blend accent color at ~15% into the overlay, e.g. Kara: `rgba(0.06, 0.04, 0.08, 0.6)`
- Lookup: `C:GetRaidTheme(raidKey)` → `.accentColor` → `HopeAddon.colors[accentColor]`

### Boss Icon — EpicGlow + BurstEffect

**All bosses** (not just final):
- `Glow:CreateEpicGlow(bossIcon, phaseColorName)` — 3-layer rotating glow (Glow.lua:290-364)
  - Outer ambient: 3x icon size, slow 2s pulse
  - Middle glow: 2x icon size, 1s pulse
  - Inner star: 0.5x size, rotating 360deg/4s + alpha pulse
- `Effects:CreateBurstEffect(bossIcon, phaseColorName)` — one-shot star burst at reveal (Effects.lua:116-159)
  - Star scales 0→6x, spins 180deg, fades over 0.4s
  - ADD blend mode for light overlay feel
- Cleanup: `Glow:StopAllFor(bossIcon)` during fadeout

**Final boss only** (additional):
- `Animations:Shake(flashFrame, 4, 0.2)` at 0.5s
- `Animations:CelebrateAchievement(bossNameText)` at 0.8s

### DEFEATED Text — Letter-Spaced, Phase-Colored

- Text: `"D E F E A T E D"` (manual spacing for wide letterform)
- Color: phase color via `RaidData:GetPhaseColorName(raidKey)` → `HopeAddon.colors[...]`
- Font: HEADER 14pt (bold feel)
- Subtle glow: `Effects:CreatePulsingGlow(defeatedContainer, phaseColorName, 0.4)` behind the text

### Animation Sequence

Timed to ~2 seconds total for normal bosses:

| Time | Element | Effect | API |
|------|---------|--------|-----|
| 0.0s | Vignette overlay | FadeIn 0.15s | `Effects:FadeIn(vignette, 0.15)` |
| 0.0s | Boss icon + EpicGlow | BounceIn 0.25s + glow starts | `Effects:BounceIn(iconContainer, 0.25)` + `Glow:CreateEpicGlow(icon, phase)` |
| 0.0s | Boss icon | BurstEffect (one-shot flash) | `Effects:CreateBurstEffect(icon, phase)` |
| 0.1s | Boss name | FadeIn 0.15s (TITLE 18pt, white) | `Effects:FadeIn(nameText, 0.15)` |
| 0.2s | "D E F E A T E D" | FadeIn 0.15s (phase-colored + pulsing glow) | `Effects:FadeIn(defeated, 0.15)` |
| 0.3s | Kill stats line | FadeIn 0.15s ("Kill #5 · 2:34") | `Effects:FadeIn(statsLine, 0.15)` |
| 0.4s | DPS bar #1 | SlideIn from RIGHT, 0.2s | `Effects:SlideIn(bar1, "RIGHT", 60, 0.2)` |
| 0.5s | DPS bar #2 | SlideIn from RIGHT, 0.2s | `Effects:SlideIn(bar2, "RIGHT", 60, 0.2)` |
| 0.6s | DPS bar #3 | SlideIn from RIGHT, 0.2s | `Effects:SlideIn(bar3, "RIGHT", 60, 0.2)` |
| 2.0s | Everything | FadeOut 0.3s + cleanup glows | `Effects:FadeOut(flashFrame, 0.3, cleanup)` |

**Final boss additions (extend to ~3s):**

| Time | Element | Effect | API |
|------|---------|--------|-----|
| 0.5s | Screen | Shake | `Animations:Shake(flashFrame, 4, 0.2)` |
| 0.8s | Boss name | CelebrateAchievement bounce | `Animations:CelebrateAchievement(nameText)` |
| 3.0s | Everything | FadeOut (extended duration) | Same cleanup |

### Sound

- Normal: `Sounds:PlayBossKill()`
- Final: `Sounds:PlayVictory()`

### Top 3 DPS Bars

- **Condition:** Only show if `EncounterTracker` has data (`#summary.topDPS > 0`)
- **Count:** Top 3 players max (trimmed from the 5 that `GetEncounterSummary` returns)
- **Colors:** Class-colored fill bars via `HopeAddon:GetClassColor(entry.class)`
- **Layout:** Player name left-aligned, DPS value right-aligned (formatted via `FormatNumber`)
- **Bar width:** Proportional to top player's total (same pattern as `BossBreakdown:PopulateBars`)
- **No data fallback:** If no encounter data available, skip the DPS section entirely — just show boss icon + name + "D E F E A T E D" + kill stats

### What to Keep

| Component | Source | Reason |
|-----------|--------|--------|
| Boss kill sound | `Sounds:PlayBossKill()` / `Sounds:PlayVictory()` | Audio feedback stays |
| First-kill journal notification | `Journal:ShowBossKillNotification()` | Fires independently, no visual conflict with flash (flash fades before notification slides in, or notification queue handles ordering) |
| Kill data recording | `RaidData:RecordBossKill()` | Data layer unchanged |
| TravelerIcons notification | `TravelerIcons:OnBossKill()` | Independent system |
| Milestone checks | `Milestones:CheckTierMilestone()` | Independent system |
| Deduplication | `recentKills` table in both event handlers | Prevents double-fire |

### What to Remove

| Component | Source | Replacement |
|-----------|--------|-------------|
| `RaidData:ShowRaidBossStats()` | RaidData.lua:724-955 | Kill flash |
| `RaidData:CreateRaidStatsWindow()` | RaidData.lua:540-716 | Kill flash frame |
| `RaidData:HideRaidBossStats()` | RaidData.lua:960-982 | Kill flash auto-fade |
| `BossBreakdown:ShowBreakdown()` | BossBreakdown.lua:353-468 | Removed entirely |
| `BossBreakdown:CreateBreakdownPanel()` | BossBreakdown.lua:117-275 | Removed entirely |
| `BossBreakdown:HideBreakdown()` | BossBreakdown.lua:514-523 | Removed entirely |
| `BossBreakdown.lua` | Entire file (523 lines) | Delete or gut |
| `_lastRecapContext` chaining | RaidData.lua:930-954 | No chain needed — single flash |
| `raidStatsTimer` auto-hide chain | RaidData.lua:938-954 | Simple timer, no callback chain |
| `raidStatsWindow` frame | RaidData.lua:714 | Replaced by kill flash frame |
| PB badge / personal best tracking | RaidData.lua:870-890 | Removed entirely — no PB in flash UI |

### Settings

| Setting | Key | Default | Description |
|---------|-----|---------|-------------|
| Kill flash enabled | `bossKillFlashEnabled` | `true` | Master toggle for the kill flash overlay |
| Animations enabled | `animationsEnabled` | `true` | Existing flag — if `false`, show instant flash (no animations) then hide after duration |

When `bossKillFlashEnabled = false`: skip the flash entirely, still record kill data and play sound.

When `animationsEnabled = false`: show the flash frame instantly (alpha=1, no transitions), hold for duration, then hide instantly (no fade out).

### Animation & Effect APIs

Available animation/effect functions for the kill flash implementation:

| API | Source | Signature | Notes |
|-----|--------|-----------|-------|
| `Effects:FadeIn` | Effects.lua:456-496 | `(frame, duration, callback)` | Alpha 0→1, OUT smoothing |
| `Effects:FadeOut` | Effects.lua:499-538 | `(frame, duration, callback)` | Alpha→0 then Hide, IN smoothing |
| `Effects:BounceIn` | Effects.lua:596-659 | `(frame, duration, callback)` | Scale 0.3→1.15→0.95→1.0, TBC-compatible ticker |
| `Effects:SlideIn` | Effects.lua:540-594 | `(frame, direction, distance, duration)` | Direction: LEFT/RIGHT/TOP/BOTTOM |
| `Effects:CreateBurstEffect` | Effects.lua:116-159 | `(frame, colorName)` | One-shot star burst, ADD blend, 0→6x scale |
| `Effects:CreatePulsingGlow` | Effects.lua:66-113 | `(frame, colorName, intensity)` | Subtle pulsing glow behind text |
| `Glow:CreateEpicGlow` | Glow.lua:290-364 | `(frame, colorName)` | 3-layer rotating glow (ambient + glow + star) |
| `Glow:StopAllFor` | Glow.lua:415-428 | `(frame)` | Cleanup all glow layers on a frame |
| `Animations:Shake` | Animations.lua:405-428 | `(frame, intensity, duration, callback)` | Random offset shake |
| `Animations:CelebrateAchievement` | Animations.lua:335-360 | `(frame, callback)` | Scale up 1→1.2 then elastic bounce back |
| `C:GetRaidTheme` | Constants.lua:4084-4086 | `(raidKey)` | Returns raid theme with `.accentColor` for vignette tint |
| `HopeAddon:GetClassColor` | Core | `(className)` | Returns `{ r, g, b }` for class coloring |

All animation APIs respect `animationsEnabled` setting — they execute instantly (no animation) when disabled.
