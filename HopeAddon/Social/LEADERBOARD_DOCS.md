# Fellow Travelers Leaderboard - Design Reference

## Overview
The Travelers sub-tab displays addon users as a leaderboard-style view with a stats header, podium for top 3 players (ranked sorts only), persistent rank numbers, and a broadcast timing footer.

## Layout Structure (top to bottom)
1. **Quick Filter Bar** (28px) - Existing: All, Online, Party, LF_RP
2. **Stats Summary Header** (36px) - NEW: 4 stat cells with contextual data
3. **Podium Cards** (48px each, x3) - NEW: Top 3 entries for ranked sorts only
4. **Standard Rows** (44px each) - Modified: rank numbers, self-highlight, staleness
5. **Leaderboard Footer** (20px) - NEW: Broadcast timing display

## Stats Summary Header
A 36px bar showing 4 stat cells separated by 1px vertical dividers.

### Contextual Stats by Sort Category
- **Ranked sorts** (ilvl_desc, gearscore_desc, level_desc, veteran):
  `| Your Rank: #N | Avg [value] | Top [value] | Total: N |`
- **Non-ranked sorts** (name_asc, class, last_seen):
  `| Travelers: N | Online: N | Recent (7d): N | Total: N |`

### Styling
- Labels: SMALL font (9px), grey (0.5, 0.5, 0.5)
- Values: HEADER font (11px), white or colored
- Background: BACKDROPS.TOOLTIP with dark transparent bg (0.08, 0.08, 0.08, 0.85)

## Podium Section (Top 3)
Only shown when sorting by a ranked category. Top 3 entries render as enhanced 48px cards.

### Podium Card Layout
```
[3px accent] #1  [32x32 class icon]  Name <Title>     130 iLvl  GS 3200
[           ]     Level 70 Warrior | Zone              Updated: 2m
```

### Visual Details
- 3px left accent line: #1 gold (FFD700), #2 silver (C0C0C0), #3 bronze (CD7F32)
- Background: slightly brighter (0.12, 0.12, 0.12, 0.9)
- Rank number: HEADER font 14px, OUTLINE, medal color
- Class icon: 32x32 (vs 28x28 standard)
- No action buttons on podium cards
- Self on podium: green-tinted background (0.08, 0.15, 0.08, 0.9)

## Enhanced Standard Rows
Rows below the podium (or all rows if non-ranked sort).

### Rank Numbers
- Always displayed at left margin (30px wide)
- Status dot shifted right to accommodate
- Color coding: #1-3 gold/silver/bronze (if no podium), #4-10 white, #11+ grey

### Self-Row Highlight
- Green-tinted background: (0.08, 0.15, 0.08, 0.9)
- Green border: (0.2, 0.6, 0.2, 0.7)

### Staleness Dimming
- iLevel text at 0.6 alpha if `avgILvlTime` > 24 hours
- Asterisk suffix (*) if `avgILvlTime` > 7 days

## Sort Categories

| ID | Label | Ranked? | Notes |
|---|---|---|---|
| `ilvl_desc` | iLevel | Yes | Existing |
| `gearscore_desc` | Gear Score | Yes | New |
| `level_desc` | Level | Yes | Existing |
| `veteran` | Veteran | Yes | New - oldest firstSeen first |
| `last_seen` | Recently Active | No | Existing (default) |
| `name_asc` | Name (A-Z) | No | Existing |
| `class` | By Class | No | Existing |

Removed: `name_desc`, `level_asc`, `ilvl_asc`

## Leaderboard Footer
20px bar below all rows showing broadcast timing.

```
Last broadcast: 12s ago  |  Next in: 3s
```
- Grey SMALL font (9px)
- OnUpdate throttled to 1s
- Reads `FellowTravelers.lastBroadcast` and `BROADCAST_INTERVAL` (15s)

## Data Freshness (Tooltip Enhancement)
The existing tooltip "Updated: Xm ago" line gets color coding:
- < 1 hour (3600s): green (0.4, 1.0, 0.4)
- 1-24 hours: yellow (1.0, 0.8, 0.2)
- > 24 hours: orange (1.0, 0.5, 0.1)
- > 7 days (604800s): red (1.0, 0.3, 0.3) with "Stale" suffix

## Constants Reference (C.SOCIAL_TAB additions)
```lua
LEADERBOARD_HEADER_HEIGHT = 36
LEADERBOARD_PODIUM_HEIGHT = 48
LEADERBOARD_PODIUM_ACCENT_WIDTH = 3
LEADERBOARD_FOOTER_HEIGHT = 20
LEADERBOARD_RANK_WIDTH = 30
LEADERBOARD_COLORS = { GOLD, SILVER, BRONZE, SELF_BG, SELF_BORDER }
STALE_THRESHOLDS = { FRESH = 3600, AGING = 86400, STALE = 604800 }
RANKED_SORTS = { ilvl_desc, gearscore_desc, level_desc, veteran }
```

## Integration Points
- **Directory.lua**: Sort options, sort comparators, GetLeaderboardStats()
- **Journal.lua**: PopulateSocialTravelers(), CreateTravelerRow(), CreateTravelerRowPool createFunc
- **FellowTravelers.lua**: `lastBroadcast` timestamp (read-only for footer)
- **Constants.lua**: C.SOCIAL_TAB leaderboard constants

## Files Modified
| File | Scope |
|---|---|
| `Constants.lua` | Add ~25 lines of leaderboard constants |
| `Directory.lua` | Add 2 sorts, remove 3, add stats function (~70 lines) |
| `Journal.lua` | Modify populate/row functions, add header/footer (~300 lines) |
