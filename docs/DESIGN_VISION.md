# HopeAddon - Original Design Vision
## Version 3.0 - "Your Outland Adventure"

> **⚠️ HISTORICAL DOCUMENT**
>
> This document represents the **original aspirational vision** for HopeAddon created early in development.
> Many features were implemented differently than described here, and some planned features were never built.
>
> **For accurate current documentation, see:**
> - `CLAUDE.md` - Quick reference for AI development
> - `MODULE_API_REFERENCE.md` - Detailed module APIs
> - `README.md` - User-facing feature list
>
> **Implementation Status:**
> - ✅ Journal system (implemented differently - 7 tabs, not 5)
> - ✅ Attunement tracking (all 6 TBC attunement chains)
> - ✅ Fellow Travelers (addon-to-addon communication)
> - ✅ Minigames (expanded beyond original scope - Tetris, Pong, Words, Battleship, Wordle)
> - ⚠️ Storybook intro (not implemented as separate module)
> - ⚠️ Adventure Map (integrated into journal, not standalone)
> - ❌ File structure differs significantly (see CLAUDE.md for actual structure)

---

# THE VISION

**HopeAddon is not a guild management tool. It's YOUR personal adventure journal.**

You are the hero. You woke up in Outland with no memory of how you got there. Now you must forge your path through this shattered world, conquer its darkest towers, and write your own legend.

The addon tracks YOUR story. YOUR conquests. YOUR deaths (hey, everyone dies to Flame Wreath). YOUR treasures claimed.

Guild members aren't "members" - they're fellow adventurers you meet along the way. When you see that ✦ symbol next to someone's name in the world, you know: *"That one's been through the portal too. That one understands."*

---

# TABLE OF CONTENTS

1. [The Player's Journey](#1-the-players-journey)
2. [File Structure](#2-file-structure)
3. [Visual Theme](#3-visual-theme)
4. [Act I: The Awakening (Intro Storybook)](#4-act-i-the-awakening)
5. [Act II: The Road Ahead (Adventure Map)](#5-act-ii-the-road-ahead)
6. [The Adventure Journal (Main UI)](#6-the-adventure-journal)
7. [Conquest System (Raids as Story Chapters)](#7-conquest-system)
8. [Treasures & Bounties (Loot/SR)](#8-treasures--bounties)
9. [Tavern Games](#9-tavern-games)
10. [Tales of Glory & Shame (Stats)](#10-tales-of-glory--shame)
11. [Fellow Travelers (Player Detection)](#11-fellow-travelers)
12. [Technical Specifications](#12-technical-specifications)

---

# 1. THE PLAYER'S JOURNEY

## First Login Experience
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   1. Screen fades in                                        │
│   2. Storybook opens - YOU are the protagonist              │
│   3. Learn how you arrived in Outland                       │
│   4. The road ahead is revealed (adventure map)             │
│   5. Your journal opens - your adventure begins             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## The Player's Story Arc
```
PROLOGUE: The Sleepwalker
  └─► You fell asleep in Azeroth, woke up in Outland
  
ACT I: Survival
  └─► Find allies, get your bearings, discover Hope
  
ACT II: The Haunted Tower
  └─► Karazhan - Medivh's cursed tower awaits
  └─► 12 bosses, 12 chapters of your legend
  
ACT III: The Gronn Lords
  └─► Gruul's Lair - Face the Dragonkiller
  └─► Magtheridon - The Pit Lord in chains
  
ACT IV: The Serpent & The Sun
  └─► Serpentshrine Cavern - Lady Vashj's domain
  └─► Tempest Keep - Kael'thas awaits
  
ACT V: The Legion's End
  └─► Mount Hyjal - Defend the World Tree
  └─► Black Temple - Illidan must fall
  
EPILOGUE: The Sunwell
  └─► Kil'jaeden rises. The final battle.
```

---

# 2. FILE STRUCTURE (ASPIRATIONAL - NOT IMPLEMENTED)

> **Note:** The actual file structure differs significantly. See `CLAUDE.md` for the real architecture.
> The files below were planned but never created as separate modules.

```
HopeAddon/                    ← PLANNED (not actual)
├── HopeAddon.toc
├── Core.lua                 # Foundation
├── Components.lua           # UI building blocks
├── Storybook.lua           # The Awakening (intro) ❌ NOT BUILT
├── AdventureMap.lua        # The Road Ahead (progress) ❌ NOT BUILT
├── Journal.lua             # Main UI - your adventure journal ✅ (different location)
├── Conquests.lua           # Raid progress as story chapters ❌ → Raids/ folder instead
├── Treasures.lua           # Loot system (SR + browser) ✅ → Social/Treasures.lua
├── TavernGames.lua         # Mini-games ❌ → Social/Games/ folder instead
├── Chronicles.lua          # Stats, deaths, achievements ❌ → Journal.lua instead
├── FellowTravelers.lua     # Player detection & markers ✅ (different location)
├── Communication.lua       # Sync between adventurers ❌ → GameComms.lua instead
└── Sounds.lua              # Audio ✅ (different location)
```

---

# 3. VISUAL THEME

## Color Philosophy
The colors tell a story:
- **Purple** (#9B30FF) - The mysterious, the magical, the unknown
- **Fel Green** (#32CD32) - Outland's taint, but also hope growing
- **Gold** (#FFD700) - Treasure, glory, achievement
- **Sky Blue** (#00BFFF) - The heavens, clarity, truth
- **Sunset Orange** (#FF8C00) - Hellfire Peninsula, new beginnings
- **Blood Red** (#FF4444) - Danger, sacrifice, the Burning Legion
- **Pink** (#FF69B4) - Joy, friendship, celebration
- **Teal** (#00CED1) - Zangarmarsh, Coilfang, water
- **Lavender** (#B088EE) - Netherstorm, arcane energy

## UI Style: Adventurer's Journal
- Worn leather journal aesthetic
- Parchment-colored content areas
- Hand-drawn map elements
- Sparkles and stars for magic ✦ ★ ✧

---

# 4. ACT I: THE AWAKENING

## The Storybook Intro

This is NOT a tutorial. This is the opening cinematic of YOUR story.

### Page 1: "The Last Peaceful Day"
```lua
{
    chapter = "Prologue",
    title = "The Last Peaceful Day",
    location = "Westfall, Azeroth",
    mood = "nostalgic",
    color = "yellow",
    icon = "INV_Misc_Flower_02",
    
    text = [[
The wheat fields stretched endlessly under the afternoon sun.

You wiped the sweat from your brow and looked at the small farm 
you'd been tending. It wasn't much, but it was honest work.

The war with the Legion felt distant here. Someone else's problem.

You sat beneath an old oak tree to rest your eyes...

Just for a moment...
    ]],
}
```

### Page 2: "Dreams of Green Fire"
```lua
{
    chapter = "Prologue",
    title = "Dreams of Green Fire",
    location = "The Void Between Worlds",
    mood = "unsettling",
    color = "lime",
    icon = "Spell_Arcane_PortalStormwind",
    
    text = [[
In your dreams, the world twisted.

A gateway of impossible size, carved from black stone,
pulsing with sickly green light.

Whispers in languages never meant for mortal ears.

"The portal is open..."
"Walk through..."
"Your destiny awaits beyond..."

Your legs moved on their own. Step after step toward the light.

You couldn't stop. You didn't want to.
    ]],
}
```

### Page 3: "Wrong Sky"
```lua
{
    chapter = "Act I",
    title = "Wrong Sky",
    location = "???",
    mood = "panic",
    color = "orange",
    icon = "Spell_Shadow_Confusion",
    
    text = [[
You wake SCREAMING.

The ground is red. Cracked. Bleeding fel energy.

You scramble to your feet and look up—

The sky is WRONG.

Instead of blue, a swirling void of green and purple chaos.
Chunks of rock float in the distance, defying all reason.

The air burns your lungs. Tastes like sulfur and regret.

Where ARE you?!
    ]],
}
```

### Page 4: "Hellfire"
```lua
{
    chapter = "Act I",
    title = "Hellfire",
    location = "Hellfire Peninsula, Outland",
    mood = "dread",
    color = "red",
    icon = "Achievement_Zone_Hellfire_01",
    
    text = [[
The terrible truth crashes over you like a wave.

You've heard the soldiers' stories. The veterans' nightmares.

The Dark Portal. The shattered world beyond.

OUTLAND.

Somehow, impossibly, you SLEEPWALKED through the 
Dark Portal itself.

You're in OUTLAND.

And you have no idea how to get home.
    ]],
}
```

### Page 5: "The Banner"
```lua
{
    chapter = "Act I",
    title = "The Banner",
    location = "Hellfire Peninsula, Outland",
    mood = "hope",
    color = "pink",
    icon = "INV_BannerPVP_02",
    
    text = [[
Despair threatens to overwhelm you. 

Then—movement. A flutter of cloth in the fel wind.

A BANNER. Planted firmly in the scorched earth.

You stumble toward it, heart pounding.

The words sewn into the fabric:

    ════════════════════════════
         ✦ HOPE ✦
    "For Those Who Woke Up Here"
    ════════════════════════════

Below, in smaller script:
"You're not alone. Find us."

Someone else understands. Someone else has been through this.

You're not alone.
    ]],
}
```

### Page 6: "Your Story Begins"
```lua
{
    chapter = "Act I",
    title = "Your Story Begins",
    location = "Hellfire Peninsula, Outland",
    mood = "determined",
    color = "cyan",
    icon = "Achievement_Dungeon_Karazhan",
    
    text = [[
You fold the banner and tuck it into your pack.

You don't know how you got here.
You don't know if you'll ever get home.

But you know this:

You will SURVIVE.
You will find others like you.
You will carve your name into the history of this broken world.

This is not where your story ends.

This is where your LEGEND begins.

    ═══════════════════════════════════════
      Your adventure in Outland starts NOW.
    ═══════════════════════════════════════
    ]],
}
```

## Storybook Animation Specs
- **Fade in**: 0.5s on page open
- **Typewriter**: 0.025s per character
- **Page turn**: Fade out (0.2s) → content swap → Fade in (0.2s)
- **Final page**: Particle effects (sparkles rising)

---

# 5. ACT II: THE ROAD AHEAD

## The Adventure Map

After the storybook, show the player their JOURNEY - a MAP of their adventure through Outland.

### Visual: Hand-Drawn Map Style
```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    ✦ YOUR ROAD THROUGH OUTLAND ✦                │
│                                                                 │
│                         ☀ SUNWELL                               │
│                        (The End?)                               │
│                            │                                    │
│                 ┌──────────┴──────────┐                        │
│            BLACK TEMPLE          MT. HYJAL                      │
│            "The Betrayer"        "Last Stand"                   │
│                 │                     │                         │
│                 └──────────┬──────────┘                        │
│                            │                                    │
│                 ┌──────────┴──────────┐                        │
│            SERPENTSHRINE        TEMPEST KEEP                    │
│            "The Witch"          "Sun King"                      │
│                 │                     │                         │
│                 └──────────┬──────────┘                        │
│                            │                                    │
│                 ┌──────────┴──────────┐                        │
│            GRUUL'S LAIR         MAGTHERIDON                     │
│            "Dragonkiller"       "The Chained"                   │
│                 │                     │                         │
│                 └──────────┬──────────┘                        │
│                            │                                    │
│                      ★ KARAZHAN ★                               │
│                   "The Haunted Tower"                           │
│                       [ENTER]                                   │
│                            │                                    │
│                       ● YOU ARE HERE                            │
│                    Hellfire Peninsula                           │
│                                                                 │
│               "Every legend begins with a single step."         │
│                                                                 │
│                     ┌───────────────────┐                      │
│                     │  Open Your Journal │                      │
│                     └───────────────────┘                      │
└─────────────────────────────────────────────────────────────────┘
```

### Map Interactivity
- **Completed raids**: Glow gold, show completion date
- **Current raid**: Pulsing indicator, "ENTER" button
- **Future raids**: Grayed out, fog of war effect
- **Hover**: Shows raid summary and your progress

### Raid Story Summaries

```lua
RaidStories = {
    ["Karazhan"] = {
        name = "Karazhan",
        subtitle = "The Haunted Tower",
        storyIntro = [[
High in Deadwind Pass stands Karazhan, the tower of the 
last Guardian, Medivh.

Once a beacon of knowledge and power, now it festers with 
dark magic and tortured spirits.

Medivh's tower calls to you. Will you answer?
        ]],
        yourGoal = "Ascend the tower. Face Prince Malchezaar. Claim Gorehowl.",
        bossCount = 12,
        groupSize = 10,
    },
    
    ["Gruul's Lair"] = {
        name = "Gruul's Lair",
        subtitle = "The Dragonkiller",
        storyIntro = [[
They call him the Dragonkiller. Black dragons once ruled 
this land—until Gruul ripped them from the sky with his 
bare hands.

He has never been defeated. Until now.
        ]],
        yourGoal = "Slay the Dragonkiller. Prove your strength.",
        bossCount = 2,
        groupSize = 25,
    },
    
    ["Black Temple"] = {
        name = "Black Temple",
        subtitle = "The Betrayer's End",
        storyIntro = [[
This is it. The Black Temple. Illidan's seat of power.

You have fought across Outland. You have grown strong.

Illidan Stormrage waits at the summit. The Betrayer.

It's time to finish this.
        ]],
        yourGoal = "Ascend the Black Temple. Face Illidan Stormrage.",
        bossCount = 9,
        groupSize = 25,
    },
    
    ["Sunwell Plateau"] = {
        name = "Sunwell Plateau",
        subtitle = "The Final Dawn",
        storyIntro = [[
Kil'jaeden, lord of the Burning Legion, attempts to 
enter Azeroth through the Sunwell.

If he succeeds, the world ends. Simple as that.

This is the final battle.
        ]],
        yourGoal = "Stop Kil'jaeden. Save the world. No big deal.",
        bossCount = 6,
        groupSize = 25,
    },
}
```

---

# 6. THE ADVENTURE JOURNAL (Main UI)

## Philosophy
The main UI is your **Adventure Journal** - a personal record of your journey.

### Journal Tabs
```
┌────────────────────────────────────────────────────────────┐
│  📖 Adventure Journal              [PlayerName]      [X]   │
│  ════════════════════════════════════════════════════════  │
│                                                            │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐     │
│  │  📍     │   ⚔️    │   💎    │   🎲    │   📜    │     │
│  │ Journey │Conquests│Treasures│ Tavern  │Chronicles│     │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘     │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │               [Tab Content Here]                     │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### Tab 1: Journey (📍)
Your current position in the TBC story.
- Adventure map (zoomed out)
- Current objective
- Next milestone

### Tab 2: Conquests (⚔️)
Your raid progress as story chapters.
- Which bosses you've defeated
- When you first killed them
- "Boss journal" entries

### Tab 3: Treasures (💎)
Loot browser + Soft Reserve system.
- Browse loot by raid/boss
- Your wish list (SR)
- Treasures you've claimed

### Tab 4: Tavern (🎲)
Mini-games for downtime.
- Death Roll
- High-Low
- Jackpot Raffle
- Trivia

### Tab 5: Chronicles (📜)
Your statistics and achievements.
- Death count (worn as a badge of honor)
- Boss kill counts
- Fellow travelers met

---

# 7. CONQUEST SYSTEM

## Raids as Story Chapters

Each BOSS is presented as a CHAPTER in your personal legend.

### Karazhan Boss Stories

```lua
KarazhanChapters = {
    {
        boss = "Attumen the Huntsman",
        chapter = "The Eternal Hunt",
        story = [[
In the stables beneath the tower, a phantom rider 
waits eternally for prey that never comes.

Attumen was Medivh's stableman in life. In death, 
he hunts still—and you are his quarry.
        ]],
    },
    {
        boss = "Moroes",
        chapter = "The Dinner Party",
        story = [[
The guests arrived for a party that would never end.

Moroes, the faithful steward, still serves his master.
The wine is blood now. The guests are monsters.
But the party goes on.
        ]],
    },
    {
        boss = "Shade of Aran",
        chapter = "The Father's Shadow",
        story = [[
Nielas Aran was Medivh's father—a mage who gave 
everything for his son.

Now his shade haunts the tower's library, 
endlessly casting spells, endlessly burning.

DON'T. MOVE. DURING. FLAME. WREATH.
        ]],
        specialNote = "If you move during Flame Wreath, everyone dies.",
    },
    {
        boss = "Prince Malchezaar",
        chapter = "The Eredar Prince",
        story = [[
At the tower's peak, a prince of the Burning 
Legion has claimed Medivh's power as his own.

One of his weapons is Gorehowl—Grom Hellscream's 
axe. Take it back.
        ]],
        finalBoss = true,
    },
}
```

### Victory Tracking
When you defeat a boss, your journal updates:

```lua
{
    boss = "Prince Malchezaar",
    yourVictory = {
        firstKill = "2026-01-22",
        totalKills = 4,
        deaths = 2,
        treasureClaimed = "Gorehowl",
    },
}
```

---

# 8. TREASURES & BOUNTIES

## Your Wish List (Soft Reserve)

```
┌──────────────────────────────────────────────────────────┐
│  💎 Your Wish List                                       │
│  ══════════════════════════════════════════════════════  │
│                                                          │
│  "Every adventurer dreams of certain treasures..."       │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  ★ Gorehowl                                       │   │
│  │    Prince Malchezaar - Karazhan                   │   │
│  │    "Grom Hellscream's legendary axe"              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Remaining wishes: 1/2                                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Treasure Browser

- Browse by raid → boss
- Click item to add to wish list
- See who else seeks each treasure
- Contested items show "(Roll-off!)"

---

# 9. TAVERN GAMES

## The Tavern

Games are what adventurers do during downtime between bosses.

### Death Roll
```
Two adventurers. One thousand-sided die.
Roll. Your opponent rolls up to your number.
First to roll 1 loses everything.
```

### High-Low
```
A number appears. Guess: higher or lower?
Streak grows = winnings double.
Guess wrong = lose it all.
How long will you push your luck?
```

### Jackpot
```
Everyone throws gold in the pot.
One name is drawn.
They take EVERYTHING.
```

### Trivia
```
Questions about Azeroth and Outland.
First correct answer wins.
```

---

# 10. TALES OF GLORY & SHAME

## Death Tracking: "The Graveyard Shift"

```lua
-- Titles earned by death count
DeathTitles = {
    {min = 0, max = 0, title = "Immortal"},
    {min = 1, max = 5, title = "Lucky"},
    {min = 6, max = 15, title = "Blooded"},
    {min = 16, max = 30, title = "Veteran"},
    {min = 31, max = 50, title = "Floor Inspector"},
    {min = 51, max = 100, title = "Professional Corpse"},
    {min = 101, max = 999, title = "LEGEND"},
}
```

## The Book of Shame (Leaderboard)

```
┌──────────────────────────────────────────────────────────┐
│  ☠️ The Book of Shame                                     │
│  "Those who have fallen the most..."                      │
│                                                          │
│  👑 CHAMPION OF DEATH:                                   │
│      PlayerSeven - 67 deaths                             │
│                                                          │
│  🥈 PlayerThree    - 45 deaths                           │
│  🥉 PlayerOne      - 38 deaths                           │
│  4. PlayerFive     - 29 deaths                           │
│  5. PlayerTwo      - 22 deaths                           │
│                                                          │
│  Your rank: #3 with 38 deaths                            │
│  Title: "Floor Inspector"                                │
└──────────────────────────────────────────────────────────┘
```

---

# 11. FELLOW TRAVELERS

## The Mark of Hope ✦

When you see ✦ next to someone's name, they're a fellow traveler—someone else who found their way to Hope.

### The Lore
```
"Before the Sleepwalkers scattered across Outland, they made a pact:

We will find each other. We will know each other.

They enchanted a simple symbol—a star—to appear only to 
those who share the bond.

When you see ✦, you know: that one walked through the 
portal too. That one understands."
```

### Visual Implementation

**Nameplate**:
```
✦ PlayerName
<Hope>
```

**Chat**:
```
[Guild] ✦ PlayerName: Hey everyone!
```

**Target Frame**:
```
PlayerName
✦ Fellow Traveler
```

---

# 12. TECHNICAL SPECIFICATIONS

## Saved Variables

```lua
HopeAddonDB = {
    -- Your story progress
    story = {
        hasSeenIntro = false,
        hasSeenAdventureMap = false,
    },
    
    -- Your conquests
    conquests = {
        ["Karazhan"] = {
            firstClear = nil,
            totalClears = 0,
            bossKills = {},
        },
    },
    
    -- Your treasures
    treasures = {
        wishList = {},
        claimed = {},
    },
    
    -- Your chronicles
    chronicles = {
        deaths = {total = 0, byBoss = {}},
        triviaScore = 0,
    },
    
    -- Fellow travelers
    travelers = {
        knownAddonUsers = {},
    },
}
```

## Core Events

```lua
Events = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "CHAT_MSG_SYSTEM",        -- /roll detection
    "CHAT_MSG_ADDON",         -- Fellow traveler detection
    "COMBAT_LOG_EVENT_UNFILTERED",  -- Deaths
    "NAME_PLATE_UNIT_ADDED",  -- Markers
}
```

---

# BUILD CHECKLIST

## Phase 1: Foundation
- [ ] Core.lua
- [ ] Components.lua
- [ ] Sounds.lua

## Phase 2: The Awakening
- [ ] Storybook.lua (6 pages)
- [ ] AdventureMap.lua

## Phase 3: The Journal
- [ ] Journal.lua (main UI)
- [ ] Conquests.lua (raid progress)
- [ ] Treasures.lua (loot/SR)
- [ ] TavernGames.lua
- [ ] Chronicles.lua (stats)

## Phase 4: Fellowship
- [ ] Communication.lua
- [ ] FellowTravelers.lua (✦ markers)

---

*"This is where your LEGEND begins."*
