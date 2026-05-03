# CrusadeCritter Dungeon Kill Popup System

Documentation for the dungeon boss kill popup system: event handling, deduplication, UI lifecycle.

---

## Event Flow

```
COMBAT_LOG_EVENT_UNFILTERED
    │
    ├── PARTY_KILL (fires first)  ──┐
    │                                ├──► Dedup check (recentBossKills table, 5s cooldown)
    └── UNIT_DIED (fires second)  ──┘       │
                                            ▼
                                   CrusadeCritter:OnBossKill(npcID, bossData)
                                            │
                                   ┌────────┴────────┐
                                   │                  │
                              Mid-boss           Final boss
                                   │                  │
                                   ▼                  ▼
                     ShowBossKillPopup()    OnDungeonComplete()
                              │                  │
                              ▼                  ▼
                CritterUI:ShowCombinedStats()  CritterUI:ShowStatsWindow()
                   (7s auto-hide)              (15s auto-hide)
```

## Combat Log Deduplication

### Why dedup is needed

WoW fires both `PARTY_KILL` and `UNIT_DIED` for the same creature death:
- **PARTY_KILL** fires early in the death sequence (source: [Warcraft Wiki](https://warcraft.wiki.gg/wiki/COMBAT_LOG_EVENT))
- **UNIT_DIED** fires later after other death-related events
- Both events contain the same `destGUID` pointing to the boss NPC

Without dedup, `OnBossKill` runs twice per kill, causing double popups and corrupted run data.

### Implementation (CrusadeCritter.lua)

```lua
local recentBossKills = {}
local BOSS_KILL_COOLDOWN = 5  -- seconds

-- In OnCombatLogEvent, before OnBossKill:
local now = GetTime()
-- Cleanup expired entries
for key, ts in pairs(recentBossKills) do
    if now - ts > BOSS_KILL_COOLDOWN * 2 then
        recentBossKills[key] = nil
    end
end
-- Check cooldown
if recentBossKills[npcID] and (now - recentBossKills[npcID]) < BOSS_KILL_COOLDOWN then
    return  -- Already processed this kill
end
recentBossKills[npcID] = now
```

**Key design decisions:**
- Uses `npcID` as dedup key (unique per boss NPC in TBC)
- 5-second cooldown window (generous; events fire within same frame or ~16ms apart)
- Cleanup at 2x cooldown (10s) prevents memory leak
- `GetTime()` is frame-cached but sufficient for multi-second windows
- Pattern matches `RaidData.lua` which uses identical approach for raid boss dedup

### Reference: How RaidData does it (raids)

```lua
-- RaidData.lua uses raidKey_bossId composite key with 10-second cooldown
local killKey = mapping.raid .. "_" .. mapping.boss
if recentKills[killKey] and (now - recentKills[killKey]) < 10 then
    return
end
```

---

## UI Components

### CombinedStats Window (mid-boss kills)

| Property | Value |
|----------|-------|
| Duration | 7 seconds (`COMBINED_STATS_DURATION`) |
| Auto-hide timer | `combinedStatsTimer` (cancelled on re-show, manual close, OnDisable) |
| Learn button timer | `learnBtnTimer` — shows after 3s (tracked, cancelled alongside main timer) |
| Fade | FadeIn 0.3s on show, FadeOut 0.3s on hide via Effects module |
| Frame | Singleton `combinedStatsWindow`, reused for all mid-boss kills |

### StatsWindow (dungeon complete / final boss)

| Property | Value |
|----------|-------|
| Duration | 15 seconds (`STATS_WINDOW_DURATION`) |
| Auto-hide timer | `statsWindowTimer` (cancelled on manual close or OnDisable) |
| Manual close | Close button calls `HideStatsWindow()` which cancels timer |
| Fade | PopIn 0.4s on show, FadeOut 0.3s on hide |
| Frame | Singleton `statsWindow`, reused for all dungeon completions |

### Timer Management

All timers are tracked and cancelled in these locations:

| Timer | Set in | Cancelled in |
|-------|--------|-------------|
| `combinedStatsTimer` | ShowCombinedStats | ShowCombinedStats (re-show), HideCombinedStats, OnDisable |
| `learnBtnTimer` | ShowCombinedStats | ShowCombinedStats (re-show), HideCombinedStats, OnDisable |
| `statsWindowTimer` | ShowStatsWindow | HideStatsWindow, OnDisable |
| `bossPopupTimer` | ShowBossPopup | ShowBossPopup (re-show), OnDisable |
| `unlockTimer` | OnLevelUp | OnLevelUp (re-trigger), inner callback, OnDisable |

---

## Unlock Celebration Timers (CrusadeCritter.lua)

Level-up unlock celebration uses nested timers with proper tracking:
- Outer timer (3s): waits for level-up animation to finish
- Inner timer (5s): combat retry delay if player is in combat
- Both stored in `self.unlockTimer` (only one active at a time)
- Guarded with `if not HopeAddon.Timer then return end`
- Cancelled in OnDisable

---

## Validated: 2026-03-18
