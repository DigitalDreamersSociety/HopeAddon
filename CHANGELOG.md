# Changelog

All notable changes to HopeAddon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-19

### Added

#### Journal System
- Multi-tab journal UI with Timeline, Milestones, Zones, Raids, Reputation, Directory, Profile, and Stats tabs
- Frame pooling system for efficient UI management (notification, container, card, and pin pools)
- Chronological timeline view of all character milestones and discoveries
- Level milestone tracking for levels 5-70 with automatic triggers
- Zone discovery system tracking all 17 Outland zones with auto-detection
- Raid boss lists for all TBC raids (Karazhan, Gruul, Magtheridon, SSC, TK, Hyjal, BT)
- Statistics tracking: deaths by zone/boss, playtime, quests, creatures slain, largest hit, dungeon runs
- Parchment-themed UI with polished animations and sound effects

#### Attunement Tracking
- Complete attunement chain tracking for 6 raid attunements:
  - Karazhan (Master's Key)
  - Serpentshrine Cavern (Vashj attunement)
  - Tempest Keep (Kael'thas attunement)
  - Mount Hyjal (Battle for Mount Hyjal)
  - Black Temple (Cipher of Damnation + Medallion of Karabor)
  - Cipher of Damnation (Three fragment quest chain)
- Chapter-by-chapter progress tracking with quest validation
- Visual progress bars with completion percentages
- Automatic progress detection via quest log API

#### Reputation System
- Milestone tracking for 5 major TBC factions:
  - The Aldor
  - The Scryers
  - The Consortium
  - Netherwing
  - Ogri'la
- Automatic detection of Aldor vs Scryers choice
- Standing progression tracking (Neutral → Exalted)
- Reputation bars with current standing display

#### Social System
- Fellow Travelers: Automatic addon-to-addon detection via hidden chat channel
- RP Profile Editor: Create and share character backstories, personality traits, and appearance
- Profile Directory: Browse profiles of all detected addon users
- Badge System: 20+ unlockable achievements based on milestones and accomplishments
- Map Pins: Minimap pins showing Fellow Travelers' locations
- Traveler Icons: Visual indicators on player cards for shared experiences

#### Multiplayer Minigames
- Dice Roll: Classic high-roll game (1-100) with real `/roll` detection and verification
- Rock-Paper-Scissors: Best of 3 with hash-based commit-reveal protocol for fairness
- Death Roll: Turn-based gambling game with 3-player escrow system
- Tetris Battle: Two-player competitive Tetris with garbage mechanic, 7-bag randomizer, and SRS rotation
- Pong: Classic arcade game with ball physics and paddle collision detection
- Words with WoW: Scrabble-style word game with WoW-themed vocabulary
- Win/loss statistics tracking per opponent
- Challenge system with invite/accept/decline flow (60s timeout)
- Local and remote multiplayer modes

#### Game Framework
- GameCore: 30 FPS game loop with delta time and state management
- GameUI: Shared UI components (windows, buttons, score displays, timers)
- GameComms: Addon messaging protocol for multiplayer synchronization

#### Core Systems
- Modular architecture with Core, UI, Journal, Raids, Reputation, Social, and Games modules
- Data persistence with account-wide and per-character SavedVariables
- Automatic data migration on version updates
- TBC-compatible timer system using C_Timer or fallback implementation
- Sound effect system with UI feedback
- Visual effects utilities (glow, sparkles, animations)

#### Performance Optimizations
- Frame pooling for all UI elements to minimize allocations
- Combat log early filtering to reduce event processing overhead
- Timeline entry caching with invalidation on changes
- Riding skill caching with invalidation on skill updates
- Statistics batching with single-pass computation
- Glow parent index for O(1) lookup when stopping effects
- Comprehensive OnDisable cleanup for all pooled resources

### Technical Details

#### Architecture
```
HopeAddon/
├── Core/           # FramePool, Constants, Timer, Core, Sounds, Effects
├── UI/             # Components, Glow, Animations
├── Journal/        # Journal, Pages, Milestones, Zones, ProfileEditor
├── Raids/          # RaidData, Attunements, Karazhan, Gruul, Magtheridon
├── Reputation/     # ReputationData, Reputation
└── Social/         # Badges, FellowTravelers, TravelerIcons, Minigames, MapPins
    └── Games/      # GameCore, GameUI, GameComms, Tetris, DeathRoll, Pong, Words
```

#### SavedVariables
- **HopeAddonDB**: Account-wide settings
- **HopeAddonCharDB**: Per-character data (journal entries, attunements, statistics, traveler profiles)

#### Slash Commands
- `/hope` - Open journal
- `/hope stats` - Display statistics in chat
- `/hope debug` - Toggle debug mode
- `/hope sound` - Toggle sound effects
- `/hope reset` - Show reset options
- `/hope challenge <player> [game]` - Challenge Fellow Traveler
- `/hope tetris [player]` - Start Tetris Battle
- `/hope pong [player]` - Start Pong
- `/hope deathroll <player>` - Start Death Roll
- `/hope words <player>` - Start Words with WoW
- `/hope accept` - Accept challenge
- `/hope decline` - Decline challenge
- `/hope cancel` - Cancel game

### Known Issues
- Milestone detail modal not yet implemented (clicking shows placeholder)
- CheckAttunementIcons requires addon communication protocol extension
- Boss kill detection needs verification in live raid environment

---

## [Unreleased]

### Planned Features
- Milestone detail modal with expanded information
- Attunement completion icons for Fellow Travelers
- Dedicated settings panel UI
- Additional multiplayer minigames

---

**Legend:**
- `Added` - New features
- `Changed` - Changes to existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security vulnerability fixes
