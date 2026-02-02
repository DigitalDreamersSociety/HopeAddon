# Crusade Critter

A mascot companion system for TBC dungeon grinding with personality-driven quips, run statistics, and unlockable critters.

## Overview

Crusade Critter adds a floating mascot companion that accompanies you through The Burning Crusade dungeons. Each critter has a unique personality and provides commentary on your adventures, tracks your dungeon run times, and celebrates your boss kills.

**Key Features:**
- 7 unlockable critters with distinct personalities
- Dungeon run timing and boss kill tracking
- Speech bubbles with typewriter animation
- Time comparison charts for runs and boss kills
- Progress-based unlock system tied to dungeon completion

## Quick Start

### Enable the Feature
```
/critter on
```

### Select Your Critter
```
/critter select flux
```

### View All Commands
```
/critter help
```

### Check Unlock Progress
```
/critter list
```

## Slash Commands

| Command | Description |
|---------|-------------|
| `/critter` | Show help and current status |
| `/critter on` | Enable the feature |
| `/critter off` | Disable the feature |
| `/critter select NAME` | Select a critter (must be unlocked) |
| `/critter reset` | Reset mascot position to default |
| `/critter list` | Show all critters with unlock status |
| `/critter status` | Show current status only |

---

## Features

### Mascot Companion

A 64x64 3D model with a soft pulsing glow floats on screen. The mascot:
- Bobs gently up and down (3px amplitude, 2-second cycle)
- Can be dragged to any position (position saved between sessions)
- Pauses animation during combat (optional setting)
- Shows a tooltip with the critter's name and description

### Speech Bubbles

When triggered by events, your critter speaks via comic-style speech bubbles:
- White background with black border
- Typewriter text animation (30ms per character)
- Auto-hides after 5 seconds
- Positioned above the mascot

**Trigger Events:**
- Zone entry (TBC zones)
- Dungeon entry
- Boss kills
- Player death
- Fast/slow run completion

### Dungeon Statistics

The system tracks:
- **Run Time**: Total time from first combat to final boss kill
- **Best Time**: Your fastest completion for each dungeon
- **Last Time**: Your previous run time for comparison
- **Boss Kill Times**: Duration of each boss fight

After completing a dungeon (final boss kill), a stats window displays:
- Time comparison chart (This Run vs Last vs Best)
- Boss count summary
- Performance-based quip from your critter

### Critter Unlocks

Complete all dungeons in a hub to unlock its associated critter:

| Complete... | Unlock |
|-------------|--------|
| Hellfire Citadel (3 dungeons) | Snookimp |
| Coilfang Reservoir (3 dungeons) | Shred |
| Auchindoun (4 dungeons) | Emo |
| Tempest Keep (3 dungeons) | Cosmo |
| Caverns of Time (2 dungeons) | Boomer |
| Isle of Quel'Danas (1 dungeon) | Diva |

---

## Critter Roster

| ID | Name | Model | Display ID | Personality | Unlock |
|----|------|-------|------------|-------------|--------|
| flux | Flux | Mana Wyrm | 5839 | Panicked time-traveler from 2007 | Starter (always unlocked) |
| snookimp | Snookimp | Imp | 4449 | Jersey Shore imp - GTL all day! | Hellfire Citadel |
| shred | Shred | Sporebat | 17752 | Extreme sports energy - X Games! | Coilfang Reservoir |
| emo | Emo | Bat | 10357 | Fall Out Boy scene kid | Auchindoun |
| cosmo | Cosmo | Moth | 19986 | Dreamy space nerd | Tempest Keep |
| boomer | Boomer | Owl | 4877 | OK Boomer energy - back in MY day... | Caverns of Time |
| diva | Diva | Phoenix-Hawk | 19298 | Fierce and glamorous! | Isle of Quel'Danas |

### Critter Details

**Flux** (Starter)
- *"A panicked Mana Wyrm who accidentally time-traveled to 2007"*
- Glow: TBC Purple (0.61, 0.19, 1.00)
- References MySpace, iPods, Britney, and other 2007 nostalgia

**Snookimp** (Hellfire Citadel)
- *"Jersey Shore imp - GTL all day!"*
- Glow: Orange (1.00, 0.50, 0.00)
- GTL = Gym, Tan, Loot-ry!

**Shred** (Coilfang Reservoir)
- *"Extreme sports Sporebat - X Games energy!"*
- Glow: Teal (0.00, 0.80, 0.80)
- Skater/extreme sports slang

**Emo** (Auchindoun)
- *"Fall Out Boy scene kid bat - dark but deep"*
- Glow: Dark Purple (0.40, 0.00, 0.40)
- References MCR, Panic!, emo culture

**Cosmo** (Tempest Keep)
- *"Dreamy space nerd moth - head in the stars"*
- Glow: Light Blue (0.50, 0.70, 1.00)
- Gets distracted by stars, nebulas, galaxies

**Boomer** (Caverns of Time)
- *"OK Boomer energy owl - back in MY day..."*
- Glow: Bronze (0.80, 0.60, 0.30)
- Complains about retail, talks about vanilla

**Diva** (Isle of Quel'Danas)
- *"Fabulous Phoenix-Hawk - fierce and glamorous!"*
- Glow: Gold (1.00, 0.84, 0.00)
- Fashion-forward, dramatic flair

---

## Dungeon Hub Mapping

| Hub Key | Display Name | Dungeons | Critter Reward |
|---------|--------------|----------|----------------|
| hellfire | Hellfire Citadel | ramparts, blood_furnace, shattered_halls | snookimp |
| coilfang | Coilfang Reservoir | slave_pens, underbog, steamvault | shred |
| auchindoun | Auchindoun | mana_tombs, auchenai_crypts, sethekk_halls, shadow_lab | emo |
| tempest_keep | Tempest Keep | mechanar, botanica, arcatraz | cosmo |
| caverns | Caverns of Time | old_hillsbrad, black_morass | boomer |
| queldanas | Isle of Quel'Danas | magisters_terrace | diva |

---

## Technical Reference

### Data Storage

All data is stored in `HopeAddon.db.crusadeCritter`:

```lua
HopeAddon.db.crusadeCritter = {
    -- Settings
    enabled = true,                    -- Feature on/off
    selectedCritter = "flux",          -- Currently selected critter ID
    position = { x = -200, y = 0 },    -- Mascot screen position (CENTER offset)
    hideInCombat = true,               -- Pause mascot during combat

    -- Unlock Progress
    unlockedCritters = { "flux" },     -- Array of unlocked critter IDs
    completedDungeons = {              -- Keyed by dungeon key
        ["ramparts"] = true,
        ["blood_furnace"] = true,
    },

    -- Visit Tracking
    visitedZones = {                   -- First-visit tracking for quips
        ["Hellfire Peninsula"] = true,
    },
    visitedDungeons = {                -- First-visit tracking for dungeons
        ["ramparts"] = true,
    },

    -- Run Statistics
    dungeonRuns = {
        ["ramparts"] = {
            lastTime = 1265,           -- Last run time in seconds
            bestTime = 990,            -- Best run time in seconds
            totalRuns = 47,            -- Total completions
        },
    },

    -- Boss Statistics
    bossStats = {
        ["Omor the Unscarred"] = {
            bestTime = 45,             -- Best fight duration in seconds
            totalKills = 23,           -- Total kills
        },
    },

    -- Runtime state (cleared on logout)
    currentRun = nil,
}
```

### Public API

#### CrusadeCritter (Core Module)

| Method | Purpose | Returns |
|--------|---------|---------|
| `CrusadeCritter:IsEnabled()` | Check if feature is enabled | `boolean` |
| `CrusadeCritter:SetEnabled(enabled)` | Enable or disable the feature | `void` |
| `CrusadeCritter:SetSelectedCritter(id)` | Change the active critter | `boolean` (success) |
| `CrusadeCritter:IsCritterUnlocked(id)` | Check if a critter is unlocked | `boolean` |
| `CrusadeCritter:GetUnlockedCritters()` | Get all unlocked critter data | `table` (array) |
| `CrusadeCritter:GetHubProgress(hubKey)` | Get dungeon hub completion | `completed, total` |
| `CrusadeCritter:GetBestBossTime(bossName)` | Get best kill time for a boss | `seconds` or `nil` |

#### CritterContent (Content Module)

| Method | Purpose | Returns |
|--------|---------|---------|
| `CritterContent:GetQuip(critterId, eventType, context)` | Get a random quip | `string` or `nil` |
| `CritterContent:GetCritter(critterId)` | Get critter definition | `table` or `nil` |
| `CritterContent:GetUnlockedCritters(unlockedList)` | Get detailed unlock list | `table` (array) |
| `CritterContent:IsHubComplete(hubKey, completedDungeons)` | Check hub completion | `boolean` |
| `CritterContent:GetHubCritter(hubKey)` | Get critter reward for hub | `string` or `nil` |
| `CritterContent:GetHubProgress(hubKey, completedDungeons)` | Get hub progress | `completed, total` |

#### CritterUI (UI Module)

| Method | Purpose | Returns |
|--------|---------|---------|
| `CritterUI:SetCritter(critterId)` | Set the mascot model and glow | `void` |
| `CritterUI:ShowMascot()` | Show mascot with fade-in | `void` |
| `CritterUI:HideMascot()` | Hide mascot with fade-out | `void` |
| `CritterUI:ShowSpeechBubble(msg, duration, callback)` | Show speech bubble | `void` |
| `CritterUI:HideSpeechBubble(callback)` | Hide speech bubble | `void` |
| `CritterUI:ShowBossPopup(bossName, thisTime, bestTime, quip)` | Show boss kill popup | `void` |
| `CritterUI:ShowStatsWindow(stats, quip)` | Show end-of-run stats | `void` |
| `CritterUI:ShowUnlockCelebration(critterId)` | Show unlock celebration | `void` |

### Event System

#### Event Flow

```
ZONE_CHANGED_NEW_AREA
    |
    +-> CheckZone()
        |
        +-> TBC dungeon detected?
        |   +-> OnDungeonEnter()
        |       +-> Start run tracking
        |       +-> TriggerDungeonQuip()
        |
        +-> TBC zone detected?
            +-> First visit? -> TriggerZoneQuip() (always)
            +-> Return visit? -> TriggerZoneQuip() (30% chance)

PLAYER_REGEN_DISABLED
    |
    +-> OnCombatStart()
        +-> Set currentRun.startTime (first combat only)
        +-> PauseBobbing() (if hideInCombat enabled)

PLAYER_REGEN_ENABLED
    |
    +-> OnCombatEnd()
        +-> ResumeBobbing()

COMBAT_LOG_EVENT_UNFILTERED (UNIT_DIED / PARTY_KILL)
    |
    +-> OnCombatLogEvent()
        |
        +-> Is boss NPC?
            +-> OnBossKill()
                |
                +-> Mid-boss?
                |   +-> ShowBossKillPopup() (5 sec popup + quip)
                |   +-> SaveBossTime()
                |
                +-> Final boss?
                    +-> OnDungeonComplete()
                        +-> Update dungeonRuns stats
                        +-> ShowStatsWindow()
                        +-> CheckUnlock()
                        +-> Clear currentRun

PLAYER_DEAD
    |
    +-> OnPlayerDeath()
        +-> ShowSpeechBubble() with encouraging quip
```

#### Registered Events

| Event | Handler | Purpose |
|-------|---------|---------|
| `ZONE_CHANGED_NEW_AREA` | `CheckZone()` | Detect dungeon/zone entry |
| `COMBAT_LOG_EVENT_UNFILTERED` | `OnCombatLogEvent()` | Detect boss kills |
| `PLAYER_REGEN_DISABLED` | `OnCombatStart()` | Start run timer, pause mascot |
| `PLAYER_REGEN_ENABLED` | `OnCombatEnd()` | Resume mascot |
| `PLAYER_DEAD` | `OnPlayerDeath()` | Show encouraging quip |

### Quip System

Quips are organized by critter and event type in `CritterContent.QUIPS`:

```lua
CritterContent.QUIPS = {
    flux = {
        boss_kill = { "Quip 1", "Quip 2", ... },
        fast_run = { ... },
        slow_run = { ... },
        player_death = { ... },
        zone_entry = {
            ["Hellfire Peninsula"] = "Zone-specific quip",
            ["Zangarmarsh"] = "Another zone quip",
            default = { "Fallback quip 1", "Fallback quip 2" },
        },
        dungeon_entry = { ... },
    },
    snookimp = { ... },
    -- etc.
}
```

**Event Types:**
- `boss_kill` - Any boss kill (random from array)
- `fast_run` - Beat your best time
- `slow_run` - Slower than last run by 20%+
- `player_death` - Player dies
- `zone_entry` - Enter a TBC zone (can be zone-specific or fallback)
- `dungeon_entry` - Enter a TBC dungeon

**Zone-Specific Quips:**
The `zone_entry` event type supports zone-specific quips. If the current zone matches a key in the table, that specific quip is used. Otherwise, a random quip from the `default` array is selected.

### Boss NPC Database

All TBC dungeon bosses are tracked with NPC IDs for combat log detection:

```lua
DUNGEON_BOSS_NPCS = {
    [17308] = { name = "Omor the Unscarred", dungeon = "ramparts" },
    [17536] = { name = "Nazan", dungeon = "ramparts", isFinal = true },
    -- ... all TBC dungeon bosses
}
```

The `isFinal = true` flag indicates the final boss of a dungeon, which triggers the completion stats window.

### UI Visual Specifications

| Element | Size | Notes |
|---------|------|-------|
| Mascot Container | 96x96 | Includes glow area |
| 3D Model | 64x64 | Centered in container |
| Speech Bubble | 280px wide | Height adjusts to text |
| Boss Popup | 300x140 | 5-second duration |
| Stats Window | 450x280 | Modal dialog |

**Animation Constants:**
- Bob Amplitude: 3px
- Bob Period: 2 seconds
- Bubble Duration: 5 seconds
- Typewriter Speed: 30ms per character
- Glow Pulse: 1.5 seconds (alpha 0.4 to 0.7)

---

## File Structure

| File | Purpose |
|------|---------|
| `Social/CrusadeCritter.lua` | Core logic, event handling, stats tracking |
| `Social/CrusadeCritterContent.lua` | Critter definitions, quip database, hub mappings |
| `Social/CrusadeCritterUI.lua` | Mascot frame, speech bubble, popups, stats window |

---

## Zone to Hub Mapping

Used for zone-entry quip selection:

| Zone Name | Hub Key |
|-----------|---------|
| Hellfire Peninsula | hellfire |
| Zangarmarsh | coilfang |
| Terokkar Forest | auchindoun |
| Netherstorm | tempest_keep |
| Tanaris | caverns |
| Isle of Quel'Danas | queldanas |

---

## Display ID Reference

Display IDs are used with `SetDisplayInfo()` for TBC Classic compatibility:

| Critter | Display ID | Source NPC |
|---------|------------|------------|
| Flux (Mana Wyrm) | 5839 | NPC #15274 |
| Snookimp (Imp) | 4449 | NPC #416 |
| Shred (Sporebat) | 17752 | NPC #18129 |
| Emo (Bat) | 10357 | Verify in-game |
| Cosmo (Moth) | 19986 | NPC #21009 |
| Boomer (Owl) | 4877 | NPC #7097 |
| Diva (Phoenix-Hawk) | 19298 | NPC #20038 |

**In-Game Verification:**
```
/script print(UnitDisplayInfo("target"))
```
