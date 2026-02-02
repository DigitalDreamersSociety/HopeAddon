# Memory Leak Check Guide - HopeAddon

A comprehensive reference for running memory leak checks on the addon.

**Related:** [MEMORY_LEAK_ANALYSIS.md](MEMORY_LEAK_ANALYSIS.md) - Pattern analysis (no issues found)

---

## 1. WoW Memory Profiling Tools

### Ready-to-Use Macros

**Basic memory check:**
```lua
/run UpdateAddOnMemoryUsage(); print("HopeAddon:", format("%.2f KB", GetAddOnMemoryUsage("HopeAddon")))
```

**Force garbage collection then check:**
```lua
/run collectgarbage("collect"); UpdateAddOnMemoryUsage(); print("After GC:", format("%.2f KB", GetAddOnMemoryUsage("HopeAddon")))
```

**Continuous monitoring (call multiple times to track delta):**
```lua
/run if not _mem then _mem=0 end; collectgarbage("collect"); UpdateAddOnMemoryUsage(); local m=GetAddOnMemoryUsage("HopeAddon"); print(format("Δ: %+.2f KB (Total: %.2f KB)", m-_mem, m)); _mem=m
```

---

## 2. Addon Debug Infrastructure

### Slash Commands

| Command | Purpose |
|---------|---------|
| `/hope debug` | Toggle debug output (stored in `HopeAddon.db.debug`) |
| `/hope stats` | Show character statistics |

### FramePool Statistics

Check pool usage across the addon:
```lua
/run for name, pool in pairs(HopeAddon) do if type(pool)=="table" and pool.GetStats then local s=pool:GetStats(); print(s.name..": "..s.active.." active, "..s.available.." pooled, "..s.created.." created") end end
```

### Timer Queue Check

Check active timer count:
```lua
/run print("Active timers:", HopeAddon.Timer:GetActiveCount())
```

---

## 3. Pattern Verification Checklists

### A. Event Registration Audit

- **Search:** `RegisterEvent` → verify matching `UnregisterEvent` or `UnregisterAllEvents` in OnDisable
- **Key files:** Core.lua, Journal.lua, FellowTravelers.lua, RaidData.lua

### B. Timer/Ticker Lifecycle

- **Search:** `Timer:After`, `Timer:NewTicker` → verify `Cancel()` called in OnDisable
- **Check:** Stored references exist (e.g., `self.broadcastTicker`)

### C. Frame Pool Balance

- **Search:** `Acquire()` → verify `Release()` or `ReleaseAll()` in OnDisable
- **Check:** Active count returns to 0 after window close

### D. Callback/Listener Cleanup

- **Search:** `RegisterListener`, `RegisterMessageCallback` → verify unregistration
- **Key modules:** ActivityFeed, Treasures, Guild, FellowTravelers

### E. OnUpdate Scripts

- **Search:** `SetScript("OnUpdate"` → verify `SetScript("OnUpdate", nil)` in OnDisable
- **Key files:** Timer.lua (single shared frame), GameCore.lua, Journal.lua

### F. Table Cleanup

- **Search:** `wipe(` → verify tables cleared in OnDisable
- **Check:** Bounded queue constants (`MAX_*` limits)

### G. HookScript Guards

- **Search:** `HookScript` → verify guarded by flag (e.g., `hooksInstalled`)
- **Key file:** FellowTravelers.lua

---

## 4. Testing Procedures

### A. UI Stress Test

1. Record baseline memory
2. Open/close Journal 20 times rapidly
3. Switch between all tabs 10 times each
4. Force GC and compare to baseline
5. **Expected:** Memory returns to within 10% of baseline

### B. Game Lifecycle Test

1. Record baseline memory
2. Start and finish 5 games of each type (Tetris, Pong, Battleship, Wordle)
3. Force GC and compare to baseline
4. **Expected:** No significant growth

### C. Reload Test

1. Record baseline memory
2. `/reload`
3. Open Journal, perform typical actions
4. Force GC and compare
5. **Expected:** Memory similar to pre-reload

### D. Long Session Test

1. Record memory at session start
2. Play normally for 1+ hours
3. Record memory every 15 minutes
4. Plot growth rate - should plateau, not climb linearly

---

## 5. Interpreting Results

| Growth Pattern | Interpretation |
|----------------|----------------|
| Stable after GC | No leak |
| Climbs then plateaus | Normal - pools filling up |
| Linear growth over time | Possible leak - investigate |
| Spikes on specific action | Leak in that action's code |

### Warning Signs

- Memory doesn't return after closing UI
- Pool active count never reaches 0
- Event frame still processing after disable
- Timer still firing after cancel

---

## 6. Quick Reference

```
=== MEMORY CHECK MACROS ===
/run UpdateAddOnMemoryUsage(); print(format("%.2f KB", GetAddOnMemoryUsage("HopeAddon")))
/run collectgarbage("collect")

=== DEBUG TOGGLE ===
/hope debug

=== POOL STATS ===
/run for name, pool in pairs(HopeAddon) do if type(pool)=="table" and pool.GetStats then local s=pool:GetStats(); print(s.name..": "..s.active.." active") end end

=== TIMER COUNT ===
/run print("Active timers:", HopeAddon.Timer:GetActiveCount())

=== SEARCH PATTERNS (for code audit) ===
RegisterEvent / UnregisterEvent
Timer:NewTicker / Cancel()
:Acquire() / :Release()
SetScript("OnUpdate" / SetScript("OnUpdate", nil)
RegisterListener / UnregisterListener
HookScript / hooksInstalled
```

---

## Related Files

| File | Purpose |
|------|---------|
| `HopeAddon/Core/FramePool.lua` | Pool system with `GetStats()` |
| `HopeAddon/Core/Timer.lua` | Centralized timer management with `GetActiveCount()` |
| `HopeAddon/Core/Core.lua` | `HopeAddon:Debug()` function |
