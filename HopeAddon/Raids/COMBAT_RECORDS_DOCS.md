# Combat Records Module Reference

## Overview

The Combat Records module persists **personal** DPS/HPS/deaths after each boss kill. It reads ephemeral data from EncounterTracker before it's cleared and stores it permanently in `charDb.combatRecords`.

## Data Model

### `charDb.combatRecords`

```lua
{
    version = 1,
    records = {
        ["raidKey_bossId"] = {
            bossName = "Attumen the Huntsman",
            raidName = "Karazhan",
            raidKey = "karazhan",
            bossId = "attumen",
            icon = "Interface\\Icons\\...",

            -- Personal bests
            bestDPS  = { value = 1234.5, date = "2026-03-07", killTime = 145 },
            bestHPS  = { value = 987.6,  date = "2026-03-05", killTime = 150 },
            fastestKill = { time = 140, date = "2026-03-10", dps = 1100 },
            flawlessKills = 3,

            -- Last 10 kills (newest first)
            killHistory = {
                {
                    timestamp = 1709856000,
                    date = "2026-03-07",
                    killTime = 145,
                    dps = 1234.5,
                    hps = 0,
                    damage = 55800,
                    healing = 0,
                    damageTaken = 12345,
                    deaths = 0,
                    dpsRank = 3,
                    hpsRank = nil,
                    raidSize = 10,
                },
            },

            -- Aggregates
            totalKills = 15,
            totalDeaths = 2,
            avgDPS = 1150.2,
        },
    },
}
```

Storage estimate: ~500 bytes/boss x 45 bosses = ~22KB max.

## CombatRecords API

| Method | Returns | Description |
|--------|---------|-------------|
| `EnsureDB()` | table | Lazily creates `charDb.combatRecords` if missing |
| `RecordEncounter(raidKey, bossId, killData)` | void | Main entry point; reads EncounterTracker, persists stats |
| `GetBossRecord(raidKey, bossId)` | table/nil | Single boss record |
| `GetAllRecords()` | table | All records keyed by `raidKey_bossId` |
| `GetGlobalBests()` | table | Cross-boss `{ bestDPS, bestHPS, fastestKill }` |
| `GetAggregateStats()` | table | `{ totalKills, totalDeaths, flawlessKills, deathRate }` |
| `ClearAllRecords()` | void | Wipes all records |

## EncounterTracker Accessor Methods

Added to `Raids/EncounterTracker.lua`:

| Method | Returns | Description |
|--------|---------|-------------|
| `GetPlayerStats(guid)` | table/nil | Player's damage/healing/deaths/DPS/HPS |
| `GetPlayerDPSRank(guid)` | number | 1-based DPS rank in raid |
| `GetPlayerHPSRank(guid)` | number/nil | 1-based HPS rank, nil if 0 healing |
| `GetRaidSize()` | number | Count of tracked players |

Must be called **after** `FinishEncounter()` but **before** `AbortTracking()`.

## Integration Flow

```
Boss dies (UNIT_DIED or ENCOUNTER_END)
  -> EncounterTracker:FinishEncounter()     -- data finalized
  -> RaidData:RecordBossKill()              -- kill count + time stored
  -> CombatRecords:RecordEncounter()        -- NEW: personal stats persisted
  -> EncounterTracker:GetEncounterSummary() -- popup data
  -> KillFlash:ShowFlash()                  -- visual overlay
  -> (later) EncounterTracker:AbortTracking() -- data cleared
```

## UI Components (Journal.lua)

### Tab Definition
- Tab id: `"records"`, label: `"Records"`
- Replaces the former `"feed"` tab

### Functions

| Function | Purpose |
|----------|---------|
| `PopulateCombatRecords()` | Main tab renderer: header, best cards, stats bar, boss rows |
| `CreateRecordsBestCard(parent, label, value, bossName, date, color)` | Single personal best card |
| `CreateRecordsBossRow(parent, record, yOffset)` | Single boss history row with last/best lines |

### Layout
- **Header**: "COMBAT RECORDS" title + Clear button
- **Personal Bests**: Up to 3 cards (Best DPS, Best HPS, Fastest Kill)
- **Stats Bar**: Flawless / Deaths / Total / Rate
- **Boss History**: Sorted by most recent kill, filterable by raid
- **Empty State**: "Defeat a raid boss to start tracking!"

### Filter
- Cycles through `C.COMBAT_RECORDS.RAID_FILTERS` on click
- Stored in `socialUI.recordsFilter`

## Constants (`C.COMBAT_RECORDS`)

| Key | Value | Purpose |
|-----|-------|---------|
| `BEST_CARD_WIDTH` | 140 | Best card width |
| `BEST_CARD_HEIGHT` | 80 | Best card height |
| `BEST_CARD_SPACING` | 10 | Gap between best cards |
| `STATS_HEIGHT` | 24 | Aggregate stats bar height |
| `BOSS_ROW_HEIGHT` | 60 | Per-boss row height |
| `BOSS_ICON_SIZE` | 40 | Boss icon dimensions |
| `COLOR_DPS` | {0.8, 0.2, 0.2} | DPS accent color |
| `COLOR_HPS` | {0.2, 0.8, 0.2} | HPS accent color |
| `COLOR_FLAWLESS` | {1.0, 0.84, 0} | Gold accent |
| `COLOR_DEATH` | {0.5, 0.5, 0.5} | Death/gray accent |
| `COLOR_PB` | {1.0, 0.84, 0} | Personal best highlight |
| `MAX_KILL_HISTORY` | 10 | Max kills stored per boss |
| `RAID_FILTERS` | array | Filter dropdown options |

## Files Modified

| File | Change |
|------|--------|
| `Raids/CombatRecords.lua` | **New** - Data layer module |
| `Raids/EncounterTracker.lua` | Added 4 accessor methods |
| `Raids/RaidData.lua` | Added CombatRecords hook in both kill paths |
| `Core/Constants.lua` | Added `C.COMBAT_RECORDS` block |
| `Journal/Journal.lua` | Replaced Feed tab with Records tab |
| `HopeAddon.toc` | Added CombatRecords.lua |
