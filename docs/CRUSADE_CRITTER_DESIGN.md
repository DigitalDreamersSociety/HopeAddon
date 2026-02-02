# Crusade Critter - Design Documentation

## Final Critter Roster

| Zone Hub | Name | Model | Color | Personality | Glow |
|----------|------|-------|-------|-------------|------|
| **Starter** | **Flux** | Nether Ray | Purple | Time traveler, 2007 panic | Purple |
| **Hellfire Citadel** | **Snookimp** | Imp | Orange | Jersey Shore, GTL | Orange |
| **Coilfang Reservoir** | **Shred** | Nether Ray | Blue | X Games, extreme sports | Teal |
| **Auchindoun** | **Emo** | Bat | Purple-Red | Fall Out Boy, MySpace | Dark Purple |
| **Tempest Keep** | **Cosmo** | Moth | Red | Space nerd, stargazer | Light Blue |
| **Caverns of Time** | **Boomer** | Owl | White | "Back in my day" | Bronze |

---

## Animated 3D Creature Models

Using `PlayerModel` frames we can show **animated 3D creature models** - but with caveats.

### TBC Compatibility Warning

Per [Wowpedia](https://wowpedia.fandom.com/wiki/Patch_3.0.2/API_changes), `SetCreature()` was **added in Patch 3.0.2** (WotLK).
In TBC Classic 2.5.x, we may need to use one of these alternatives:

| Method | TBC Compatible | Notes |
|--------|---------------|-------|
| `SetCreature(displayID)` | Maybe (test!) | Preferred if available |
| `SetDisplayInfo(displayID)` | Yes | Works with creature display IDs |
| `SetModel(modelPath)` | Yes | Requires knowing the .m2 file path |

### Technical Implementation
```lua
local model = CreateFrame("PlayerModel", nil, parent)
model:SetSize(64, 64)

-- TRY SetCreature first, fall back to SetDisplayInfo
if model.SetCreature then
    model:SetCreature(displayID)
else
    model:SetDisplayInfo(displayID)
end

model:SetCamera(0)            -- Close-up view
model:SetFacing(0)            -- Face forward
```

### Performance Considerations

**Memory Impact: LOW**
- 3D model frames use GPU memory, not Lua heap
- WoW's garbage collector handles Lua cleanup automatically
- Per [CurseForge AddOns CPU Usage](https://www.curseforge.com/wow/addons/addons-cpu-usage): CPU usage matters more than memory

**Recommendations:**
- Only render ONE critter at a time (the selected one)
- Hide the model when not visible (e.g., combat hide setting)
- Use `model:SetPaused(true)` when hidden to stop animation updates
- The 64x64 frame size is small enough to be negligible
- Simple creature models (imp, bat, owl) are lightweight

### Creature Animation Tiers

**Hunter Pets (BEST animations):** idle, walk, run, attack, special, eat, sleep, death
**Warlock Pets:** idle, cast, attack, fidget, death
**Wild Mobs:** idle, attack, death (minimal)

### FINAL Critter Choices (Rare Colors + Best Animations)

| Critter | Creature | Color Variant | Source | Why |
|---------|----------|---------------|--------|-----|
| **Flux** | Nether Ray | **Purple** | Netherstorm | Arcane/time magic, full animations |
| **Snookimp** | Imp | Orange/Red | Warlock pet | GTL tanning theme, good animations |
| **Shred** | Nether Ray | **Blue** | Zangarmarsh | Rad alien vibes, full animations |
| **Emo** | Bat | **Purple-Red** | Tirisfal/SFK | Gothic dark aesthetic, full animations |
| **Cosmo** | Moth | **Red** | Netherstorm | Space/cosmic rare color, full animations |
| **Boomer** | Owl | **White** | Olm the Wise (rare) | Wise elder, rare variant |

### Color Variant Sources (from [Petopia BC Classic](https://www.wow-petopia.com/classic_bc/))

**Nether Rays:**
- Purple - Netherstorm, Shadowmoon (arcane feel)
- Blue - Zangarmarsh (cool, extreme sports)
- Green - Underbog, Slave Pens
- Red - Shadowmoon Valley

**Bats:**
- Purple-Red - Tirisfal, Shadowfang Keep (emo/gothic)
- White - Ressan the Needler rare (ultra rare)

**Owls:**
- White - Olm the Wise rare spawn (wise elder)
- Red & Purple - Avian Warhawk (unique colors)

**Moths:**
- Red - Netherstorm (cosmic/space theme)
- White/Yellow/Blue - Exodar vendor

### Known TBC Creature Display IDs

| Creature | Display ID | Type | Animation Quality |
|----------|------------|------|-------------------|
| **Imp** | 4449 | Warlock pet | Good |
| **Wisp** | 10045 | Wild | Minimal (float only) |
| **Sprite Darter** | 2921 | Wild | Basic |
| **Faerie Dragon** | 10633 | Wild | Basic |
| **Owl** | 8571 | Hunter pet | **Full** |
| **Moth** | 17012 | Hunter pet (TBC) | **Full** |
| **Bat** | 2176 | Hunter pet (TBC) | **Full** |
| **Dragonhawk** | 17077 | Hunter pet (TBC) | **Full** |
| **Mana Wyrm** | 19400 | Wild | Basic |
| **Nether Ray** | 21184 | Hunter pet (TBC) | **Full** |
| **Ravager** | 17707 | Hunter pet (TBC) | **Full** |
| **Sporebat** | 17698 | Hunter pet (TBC) | **Full** |

### Final Creature Models (Display IDs TBD)

| Critter | Creature | Color | NPC Source | Display ID |
|---------|----------|-------|------------|------------|
| **Flux** | Nether Ray | Purple | Netherstorm wild | TBD* |
| **Snookimp** | Imp | Orange | Warlock pet | 4449 |
| **Shred** | Nether Ray | Blue | Zangarmarsh wild | TBD* |
| **Emo** | Bat | Purple-Red | Shadowfang Keep | TBD* |
| **Cosmo** | Moth | Red | Netherstorm | TBD* |
| **Boomer** | Owl | White | Olm the Wise rare | TBD* |

*\*Display IDs to be verified in-game using `/dump` or model viewer addon*

### How to Find Display IDs In-Game
```lua
-- Target the creature and run:
/script print(UnitDisplayInfo("target"))
-- Or use ModelViewer addon to browse display IDs
```

---

## Unlock Method

**Requirement:** Complete all dungeons in a zone hub (kill final boss of each dungeon, Normal OR Heroic counts)

### Hellfire Citadel (Unlocks: Snookimp)
- [ ] Hellfire Ramparts (Final Boss: Nazan)
- [ ] Blood Furnace (Final Boss: Keli'dan the Breaker)
- [ ] Shattered Halls (Final Boss: Warchief Kargath Bladefist)

### Coilfang Reservoir (Unlocks: Shred)
- [ ] Slave Pens (Final Boss: Quagmirran)
- [ ] Underbog (Final Boss: The Black Stalker)
- [ ] Steamvault (Final Boss: Warlord Kalithresh)

### Auchindoun (Unlocks: Emo)
- [ ] Mana-Tombs (Final Boss: Nexus-Prince Shaffar)
- [ ] Auchenai Crypts (Final Boss: Exarch Maladaar)
- [ ] Sethekk Halls (Final Boss: Talon King Ikiss)
- [ ] Shadow Labyrinth (Final Boss: Murmur)

### Tempest Keep (Unlocks: Cosmo)
- [ ] Mechanar (Final Boss: Pathaleon the Calculator)
- [ ] Botanica (Final Boss: Warp Splinter)
- [ ] Arcatraz (Final Boss: Harbinger Skyriss)

### Caverns of Time (Unlocks: Boomer)
- [ ] Old Hillsbrad Foothills (Final Boss: Epoch Hunter)
- [ ] The Black Morass (Final Boss: Aeonus)

---

## Mascot Container Design ("Your Pal")

The mascot should feel like a friendly companion on your screen - approachable, alive, not intrusive.

### Container Structure
```
         ┌─────────────────────────────┐
         │   "Boss down! That was     │  ← Speech Bubble (white, comic style)
         │    smoother than my iPod   │     280px wide, auto-height
         │    Nano's click wheel!"    │     Black 2px border, white fill
         └───────────┬─────────────────┘
                     │ ← Tail (triangle pointing down)
                     ▼
            ┌───────────────┐
            │  ╭─────────╮  │  ← Outer Glow (soft, pulsing)
            │  │  ~~~~   │  │     Color matches critter personality
            │  │  3D     │  │     Radius: 80px, blur
            │  │  Model  │  │
            │  │  ~~~~   │  │  ← Inner Container (64x64)
            │  ╰─────────╯  │     NO hard border - just the glow
            └───────────────┘
                   │
            [Drag Handle]  ← Invisible, whole frame is draggable
```

### Idle State (No Speech Bubble)
```
          ·  · ·  ·  ·  · ·  ·
        ·                      ·
       ·    ┌────────────┐      ·    ← Soft glow halo
       ·    │            │      ·       96px diameter
      ·     │   ~~~~~    │       ·      Personality color
      ·     │   3D       │       ·      Pulsing alpha
      ·     │   MODEL    │       ·
      ·     │   ~~~~~    │       ·   ← 64px model frame
       ·    │            │      ·       NO hard border
       ·    └────────────┘      ·
        ·                      ·
          ·  · ·  ·  ·  · ·  ·
                  ↕
            [gentle bob]
```

### Container Specifications

| Property | Value | Notes |
|----------|-------|-------|
| **Model Frame** | 64x64 px | PlayerModel with creature |
| **Outer Glow** | 96x96 px | Soft circular, personality color |
| **Border** | NONE | No hard edges - just soft glow |
| **Background** | Transparent | Model floats on glow only |
| **Total Hitbox** | 80x80 px | For dragging |
| **Feel** | Floating, alive | Gentle bob + glow pulse |

### Glow Effect
```lua
-- Soft pulsing glow behind the model
local glow = container:CreateTexture(nil, "BACKGROUND")
glow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
glow:SetSize(96, 96)
glow:SetPoint("CENTER", modelFrame, "CENTER", 0, 0)
glow:SetVertexColor(glowR, glowG, glowB, 0.6)
glow:SetBlendMode("ADD")
-- Pulse animation via Animations:Tween()
```

### Idle Animation (Bobbing)
```lua
-- Gentle float up/down to feel "alive"
local bobHeight = 3  -- pixels
local bobDuration = 2  -- seconds per cycle

Animations:Tween(bobDuration, function(progress)
    local offset = math.sin(progress * math.pi * 2) * bobHeight
    modelFrame:SetPoint("CENTER", container, "CENTER", 0, offset)
end, nil, Animations.easing.linear)
-- Loop continuously
```

### Speech Bubble Design

| Property | Value |
|----------|-------|
| **Background** | Pure white (`#FFFFFF`) |
| **Border** | Black, 2px, rounded corners |
| **Width** | 280px max |
| **Padding** | 12px all sides |
| **Font** | FRIZQT, 12pt, black text |
| **Tail** | Triangle, 12px, points down to critter |
| **Position** | Anchored ABOVE critter, centered |

### Speech Bubble Structure
```
┌─────────────────────────────────┐
│                                 │  ← 2px black border
│   "Quip text here with the     │  ← 12px padding
│    typewriter effect..."        │     Black text on white
│                                 │
└───────────────┬─────────────────┘
                │  ← Tail (black border, white fill)
                ▼
```

### Bubble Tail Implementation
```lua
-- Triangle tail pointing down
local tail = bubble:CreateTexture(nil, "ARTWORK")
tail:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
-- Or create via triangle vertices if available
-- Position below bubble, centered
tail:SetPoint("TOP", bubble, "BOTTOM", 0, 2)
tail:SetSize(16, 12)
```

### Screen Position & Dragging

| Property | Value |
|----------|-------|
| **Default Position** | RIGHT side, vertically centered |
| **Draggable** | Yes, entire container |
| **Clamp to Screen** | Yes |
| **Save Position** | Yes, to `db.crusadeCritter.position` |
| **Combat Hide** | Optional (follows addon `combatHide` setting) |

### Visibility Rules

| State | Mascot Visible | Speech Bubble |
|-------|----------------|---------------|
| **Normal gameplay** | Yes | Hidden (until event) |
| **Event triggers** | Yes | Shows for 5 seconds |
| **In combat** | Hidden* | Hidden |
| **Combat ends** | Fades back in | Hidden |
| **Disabled in settings** | Hidden | Hidden |

*Only if `combatHide` setting is enabled (reuses existing addon setting)

### "Pal" Personality Touches

1. **Entrance Animation**: Fade in + slight scale pop when appearing
2. **Attention Getter**: Brief glow pulse when new quip shows
3. **Idle Variety**: Occasional random facing change (model rotation)
4. **React to Events**: Brief bounce on boss kill celebrations

### Frame Layering (Bottom to Top)
```
1. BACKGROUND: Outer glow (soft, pulsing)
2. ARTWORK: 3D Model (PlayerModel)
3. OVERLAY: Speech bubble (when active)
4. HIGHLIGHT: Click/drag highlight (invisible normally)
```

---

## Stats Window Design

Two types of stats displays: **Boss Kill Popup** (mid-dungeon) and **Final Stats Window** (end of run).

### Boss Kill Popup (Mid-Dungeon)

Appears for 5 seconds after each boss dies (except final boss).

```
    ┌─────────────────────────────┐
    │  "That boss got Leroy'd!"   │  ← Speech bubble (same style)
    └─────────────┬───────────────┘
                  │
    ┌─────────────┴───────────────┐
    │      OMOR THE UNSCARRED     │  ← Boss name (gold, centered)
    │  ┌────────────────────────┐ │
    │  │ This  █████████░  2:15 │ │  ← Purple bar (current)
    │  │ Best  ███████░░░  1:42 │ │  ← Green bar (personal best)
    │  └────────────────────────┘ │
    └─────────────────────────────┘
              ∴∴∴∴∴∴∴
           ∴ [CRITTER] ∴
              ∴∴∴∴∴∴∴
```

| Property | Value |
|----------|-------|
| **Width** | 280px |
| **Background** | Dark (`DARK_GOLD` backdrop) |
| **Border** | Gold trim |
| **Duration** | 5 seconds, auto-dismiss |
| **Position** | Above mascot |

### Final Stats Window (End of Run)

Appears when final boss dies. Stays until manually closed.

```
┌────────────────────────────────────────────────────────────────┐
│                    DUNGEON COMPLETE!                           │  ← Gold title
├────────────────────────────────┬───────────────────────────────┤
│                                │  ┌─────────────────────────┐  │
│  RUN STATISTICS                │  │  "That run time was     │  │
│                                │  │   over 9000... seconds! │  │
│  Total Time:  18:42            │  │   Wait no, 18 minutes.  │  │
│  Last Run:    21:15            │  │   Still epic!"          │  │
│  Best Run:    16:30            │  └───────────┬─────────────┘  │
│  Bosses:      4/4              │              │                │
│                                │         ∴∴∴∴∴∴∴∴∴            │
│  ┌──────────────────────────┐  │      ∴ [CRITTER] ∴           │
│  │ This █████████░░  18:42  │  │         ∴∴∴∴∴∴∴∴∴            │
│  │ Last ███████████░  21:15 │  │                               │
│  │ Best ████████░░░░  16:30 │  │                               │
│  └──────────────────────────┘  │                               │
│                                │                               │
├────────────────────────────────┴───────────────────────────────┤
│                          [ Close ]                              │
└────────────────────────────────────────────────────────────────┘
```

### Stats Window Specifications

| Property | Value |
|----------|-------|
| **Width** | 450px |
| **Height** | ~300px (content-based) |
| **Background** | `DARK_GOLD` backdrop |
| **Border** | Gold trim |
| **Close** | X button OR click Close |
| **Position** | LEFT of mascot (mascot on right edge of window) |

### Position Layout
```
┌────────────────────────────────────────────┬─────────┐
│                                            │         │
│            STATS CONTENT                   │ CRITTER │  ← Mascot stays right
│            (left side)                     │  +QUIP  │
│                                            │         │
└────────────────────────────────────────────┴─────────┘
```

### Bar Chart Colors

| Bar | Color | Hex | Purpose |
|-----|-------|-----|---------|
| **This Run** | TBC Purple | `#9B30FF` | Current run time |
| **Last Run** | Grey | `#808080` | Previous run time |
| **Best Run** | TBC Green | `#32CD32` | Personal best |

### Chart Implementation
```lua
-- Use Charts:CreateTimeComparisonChart()
local chartData = {
    { label = "This", timeSeconds = currentTime, color = "ARCANE_PURPLE" },
    { label = "Last", timeSeconds = lastTime, color = "GREY" },
    { label = "Best", timeSeconds = bestTime, color = "FEL_GREEN" },
}
local chart = Charts:CreateTimeComparisonChart(parent, 220, chartData)
```

### Stats Tracked Per Dungeon

| Stat | Storage | Description |
|------|---------|-------------|
| `lastTime` | Seconds | Most recent run time |
| `bestTime` | Seconds | Personal best run time |
| `totalRuns` | Count | Total runs completed |
| `bossKills` | Table | Per-boss timestamps |

### Run Timer Logic

| Event | Action |
|-------|--------|
| `PLAYER_REGEN_DISABLED` (first in dungeon) | Start timer |
| `COMBAT_LOG_EVENT_UNFILTERED` (UNIT_DIED) | Check if boss, record timestamp |
| Final boss death | Stop timer, calculate stats, show window |

### Boss Detection (Combat Log)
```lua
-- Register for combat log
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- In handler:
local _, subEvent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
if subEvent == "UNIT_DIED" then
    -- Extract NPC ID from GUID
    local npcID = select(6, strsplit("-", destGUID))
    npcID = tonumber(npcID)

    -- Check against known TBC dungeon bosses (from Constants.lua)
    local bossInfo = C.DUNGEON_BOSS_NPC_IDS[npcID]
    if bossInfo then
        -- Boss died! Record kill and show popup
        CrusadeCritter:OnBossKill(bossInfo.name, bossInfo.dungeon)
    end
end
```

### TBC Dungeon Boss NPCs (Already in Constants.lua)
The addon already has `C.DUNGEON_BOSS_NPC_IDS` mapping NPC IDs to dungeon info.
We use `finalBossNPC` from `C.TBC_DUNGEONS` to detect final boss vs mid-bosses.

---

## Visual Style (FINALIZED)

Each critter uses:
- **64x64 PlayerModel frame** with animated 3D creature
- **Soft circular glow** matching personality color
- **Gentle bobbing animation** via `Animations:Tween()`

| Critter | Glow Color | Hex |
|---------|------------|-----|
| Flux | Purple/arcane | `#9B30FF` |
| Snookimp | Orange/fel | `#FF8C00` |
| Shred | Teal/water | `#00CED1` |
| Emo | Dark purple | `#800080` |
| Cosmo | Light blue | `#87CEEB` |
| Boomer | Bronze/gold | `#CD853F` |

---

## Implementation Files & Size Estimate

| File | Purpose | Est. Lines | Est. Size |
|------|---------|------------|-----------|
| `Social/CrusadeCritter.lua` | Core system, triggers | ~300 | ~12 KB |
| `Social/CrusadeCritterUI.lua` | UI (bubble, stats) | ~400 | ~16 KB |
| `Social/CrusadeCritterContent.lua` | Quip database | ~500 | ~20 KB |
| `Core/Charts.lua` | Bar chart component | ~200 | ~8 KB |
| **TOTAL** | | ~1400 | **~56 KB** |

### Size Comparison (Popular Addons)

| Addon | Size | Notes |
|-------|------|-------|
| BigWigs | ~4 MB | Smallest boss mod |
| DBM | ~7.5 MB | Most popular boss mod |
| WeakAuras | ~9.5 MB | Aura framework |
| **Crusade Critter** | **~56 KB** | 0.7% of BigWigs |

**Impact:** Negligible. This feature adds less than 60KB of code - smaller than a single texture file. The 3D models use existing game assets (creature models already in WoW), not addon-bundled files.

### What Makes Addons Large?

| Heavy | Light (Our Approach) |
|-------|---------------------|
| Bundled textures/sounds | Use WoW's built-in assets |
| Large libraries | Minimal dependencies |
| Many module files | Consolidated code |
| Extensive localization | English-only quips |
