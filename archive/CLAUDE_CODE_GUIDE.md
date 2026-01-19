# HopeAddon - Claude Code Build Guide
## Quick Reference for Development

---

## 🎯 THE VISION

**This is NOT a guild management addon. It's the player's personal adventure journal.**

The player is the HERO of their own TBC story. They sleepwalked through the Dark Portal and woke up in Outland. Now they must forge their legend.

---

## 📁 FILE STRUCTURE

```
HopeAddon/
├── HopeAddon.toc
├── Core.lua              # Colors, data, utilities
├── Components.lua        # Reusable UI widgets
├── Sounds.lua            # Audio helpers
├── Storybook.lua         # 6-page animated intro
├── AdventureMap.lua      # "Road through Outland" progress map
├── Journal.lua           # Main UI with tabs
├── Conquests.lua         # Raids as story chapters
├── Treasures.lua         # Loot browser + wish list (SR)
├── TavernGames.lua       # Death Roll, High-Low, Jackpot, Trivia
├── Chronicles.lua        # Deaths, stats, achievements
├── FellowTravelers.lua   # ✦ markers on addon users
└── Communication.lua     # Addon-to-addon sync
```

---

## 🎨 COLOR PALETTE

Each color tells part of the Outland story:

| Color | Hex | Story Meaning |
|-------|-----|---------------|
| Purple | #9B30FF | Mystery, magic, the unknown |
| Fel Green | #32CD32 | Outland's corruption, but also hope |
| Gold | #FFD700 | Treasure, glory, achievement |
| Sky Blue | #00BFFF | Truth, clarity, the heavens |
| Orange | #FF8C00 | Hellfire Peninsula, new beginnings |
| Blood Red | #FF4444 | Danger, the Burning Legion |
| Pink | #FF69B4 | Joy, friendship, celebration |
| Teal | #00CED1 | Zangarmarsh, water, Coilfang |
| Lavender | #B088EE | Netherstorm, arcane energy |

---

## 📖 STORYBOOK INTRO (6 Pages)

The player IS the protagonist. This is their origin story.

| Page | Title | Mood | What Happens |
|------|-------|------|--------------|
| 1 | "The Last Peaceful Day" | 🌻 Nostalgic | Farming in Westfall, falling asleep |
| 2 | "Dreams of Green Fire" | 💚 Unsettling | Portal whispers, walking toward light |
| 3 | "Wrong Sky" | 🟠 Panic | Wake up, sky is WRONG |
| 4 | "Hellfire" | 🔴 Dread | Realize you're in OUTLAND |
| 5 | "The Banner" | 💗 Hope | Find the Hope Guild banner |
| 6 | "Your Story Begins" | 💎 Determined | Your legend starts NOW |

**Key Story Beat**: "You SLEEPWALKED through the Dark Portal."

---

## 🗺️ ADVENTURE MAP

After storybook → Show their journey through TBC as a visual MAP.

```
                    ☀ SUNWELL (Final)
                         │
              ┌──────────┴──────────┐
         BLACK TEMPLE          MT. HYJAL
                    │
              ┌─────┴─────┐
         SERPENTSHRINE   TEMPEST KEEP
                    │
              ┌─────┴─────┐
           GRUUL'S      MAGTHERIDON
                    │
              ★ KARAZHAN ★
               [YOU START HERE]
```

**Interactivity**:
- Completed = Glow gold
- Current = Pulsing "ENTER"
- Future = Fog of war / grayed

---

## 📓 JOURNAL TABS

Main UI is an "Adventure Journal" with 5 tabs:

| Tab | Icon | Purpose |
|-----|------|---------|
| Journey | 📍 | Adventure map, current objective |
| Conquests | ⚔️ | Raid progress as story chapters |
| Treasures | 💎 | Loot browser + wish list (SR) |
| Tavern | 🎲 | Mini-games |
| Chronicles | 📜 | Deaths, stats, achievements |

---

## ⚔️ RAIDS AS STORY CHAPTERS

Each BOSS has a story entry:

```lua
{
    boss = "Prince Malchezaar",
    chapter = "The Eredar Prince",
    story = [[
At the tower's peak, a prince of the Burning 
Legion has claimed Medivh's power.

One of his weapons is Gorehowl—Grom Hellscream's 
axe. Take it back.
    ]],
    finalBoss = true,
}
```

**When defeated**: Record first kill date, total kills, deaths, loot claimed.

---

## 💎 TREASURES (Loot System)

**Framing**: "Your Wish List" (not "Soft Reserve")

- Browse loot by raid → boss
- Click to add to wish list
- See who else seeks each item
- "(Roll-off!)" for contested items

---

## 🎲 TAVERN GAMES

| Game | Description |
|------|-------------|
| Death Roll | /roll 1000 → opponent /roll 1-X → first to roll 1 loses |
| High-Low | Guess if next number higher/lower, streak = 2x multiplier |
| Jackpot | Everyone antes, one winner takes all |
| Trivia | WoW lore questions, first correct wins |

---

## ☠️ DEATH TRACKING

Deaths are a **badge of honor**, not shame.

```lua
DeathTitles = {
    {min = 0, title = "Immortal"},
    {min = 1, title = "Lucky"},
    {min = 6, title = "Blooded"},
    {min = 16, title = "Veteran"},
    {min = 31, title = "Floor Inspector"},
    {min = 51, title = "Professional Corpse"},
    {min = 101, title = "LEGEND"},
}
```

**Leaderboard**: "The Book of Shame" - top deaths displayed proudly.

---

## ✦ FELLOW TRAVELERS

When you see ✦ next to someone's name, they have the addon.

**Lore**: "The Sleepwalkers enchanted a star to recognize each other."

**Shows on**:
- Nameplates: `✦ PlayerName`
- Chat: `[Guild] ✦ PlayerName: message`
- Target frame: `✦ Fellow Traveler`

**Detection**: Addon message HELLO → ACK response → add to known users.

---

## 💾 SAVED VARIABLES

```lua
HopeAddonDB = {
    story = {
        hasSeenIntro = false,
        hasSeenAdventureMap = false,
    },
    conquests = {
        ["Karazhan"] = {bossKills = {}, firstClear = nil},
    },
    treasures = {
        wishList = {},
        claimed = {},
    },
    chronicles = {
        deaths = {total = 0, byBoss = {}},
        triviaScore = 0,
    },
    travelers = {
        knownAddonUsers = {},
    },
}
```

---

## 🔧 KEY EVENTS

```lua
"ADDON_LOADED"              -- Init
"PLAYER_LOGIN"              -- Show intro or welcome
"CHAT_MSG_SYSTEM"           -- Detect /rolls
"CHAT_MSG_ADDON"            -- Fellow traveler detection
"COMBAT_LOG_EVENT_UNFILTERED" -- Death tracking
"NAME_PLATE_UNIT_ADDED"     -- Add ✦ markers
```

---

## 🔨 BUILD ORDER

### Phase 1: Foundation
1. Core.lua
2. Components.lua
3. Sounds.lua

### Phase 2: The Awakening
4. Storybook.lua (6-page intro)
5. AdventureMap.lua

### Phase 3: The Journal
6. Journal.lua (main UI)
7. Conquests.lua
8. Treasures.lua
9. TavernGames.lua
10. Chronicles.lua

### Phase 4: Fellowship
11. Communication.lua
12. FellowTravelers.lua

---

## 💡 KEY REMINDERS

1. **Player is the HERO** - Everything frames THEIR journey
2. **Story > Structure** - No guild rank lists, no rules pages
3. **Raids are Chapters** - Not "instances" but story arcs
4. **Deaths are Badges** - Celebrate them, don't hide them
5. **✦ = Connection** - Fellow travelers, not "guild members"
6. **Typewriter text** - 0.025s per character in storybook
7. **Toon colors** - Bright, cartoonish, magical feel

---

## 📝 STORY BEATS TO HIT

1. "You fell asleep in Azeroth"
2. "You sleepwalked through the Dark Portal"
3. "You woke up in Hellfire Peninsula"
4. "You found the Hope banner"
5. "This is where your legend begins"
6. "Karazhan awaits - the Haunted Tower"
7. "Every boss is a chapter in YOUR story"
8. "When you see ✦, you know they understand"

---

*"This is where your LEGEND begins."*
