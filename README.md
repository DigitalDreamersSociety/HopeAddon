# HopeAddon

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![TBC](https://img.shields.io/badge/TBC-2.4.3-green.svg)
![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

A comprehensive TBC adventure journal addon for World of Warcraft with attunement tracking, reputation milestones, social features, and multiplayer minigames.

## Features

### Journal System
- **Timeline**: Chronological view of all character milestones and discoveries
- **Milestones**: Automatic level-based achievements (levels 5-70)
- **Zone Discovery**: Track exploration of all 17 Outland zones
- **Raids**: Complete boss lists for Karazhan, Gruul's Lair, Magtheridon's Lair, SSC, TK, Hyjal, and Black Temple
- **Reputation**: Milestone tracking for 5 major TBC factions (Aldor, Scryers, Consortium, Netherwing, Ogri'la)
- **Statistics**: Deaths by zone/boss, playtime, dungeon runs, combat stats

### Attunement Tracking
- **Karazhan**: Master's Key quest chain
- **Serpentshrine Cavern**: Vashj attunement chain
- **Tempest Keep**: Kael'thas attunement chain
- **Mount Hyjal**: Battle for Mount Hyjal chain
- **Black Temple**: Cipher of Damnation + Medallion of Karabor
- **Cipher of Damnation**: Three fragment quest chain

Progress bars and chapter-by-chapter tracking for all attunement chains.

### Social Features
- **Fellow Travelers**: Automatic detection of other addon users
- **RP Profiles**: Create and share character backstories, personality traits, and appearance
- **Badges**: Unlock 20+ achievements based on milestones and accomplishments
- **Map Pins**: See Fellow Travelers on your minimap
- **Profile Directory**: Browse profiles of all detected addon users

### Multiplayer Minigames
- **Dice Roll**: Classic high-roll game using real `/roll` detection
- **Rock-Paper-Scissors**: Best of 3 with hash-based commit-reveal protocol
- **Death Roll**: Turn-based gambling with 3-player escrow system
- **Tetris Battle**: Two-player competitive Tetris with garbage mechanic
- **Pong**: Classic arcade game with physics
- **Words with WoW**: Scrabble-style word game with WoW vocabulary

Challenge other Fellow Travelers and track your win/loss records!

## Installation

### From GitHub
1. Download the latest release from [Releases](https://github.com/[username]/HopeAddon/releases)
2. Extract the `HopeAddon` folder to your `World of Warcraft\_classic_\Interface\AddOns\` directory
3. Restart WoW or type `/reload` in-game

### From Source
1. Clone this repository:
   ```bash
   git clone https://github.com/[username]/HopeAddon.git
   ```
2. Copy the `HopeAddon` folder to your `World of Warcraft\_classic_\Interface\AddOns\` directory
3. Restart WoW or type `/reload` in-game

## Usage

### Basic Commands
- `/hope` - Open the journal UI
- `/hope stats` - Display statistics in chat
- `/hope debug` - Toggle debug mode
- `/hope sound` - Toggle sound effects
- `/hope reset` - Show reset options

### Minigame Commands
- `/hope challenge <player> [game]` - Challenge a Fellow Traveler (opens selection popup if game not specified)
- `/hope tetris [player]` - Start Tetris Battle (local mode if no player specified)
- `/hope pong [player]` - Start Pong (local mode if no player specified)
- `/hope deathroll <player>` - Start Death Roll gambling game
- `/hope words <player>` - Start Words with WoW word game
- `/hope accept` - Accept a pending challenge
- `/hope decline` - Decline a pending challenge
- `/hope cancel` - Cancel current game

## Architecture

The addon is organized into modular components:

```
HopeAddon/
├── Core/           # Foundation (FramePool, Constants, Timer, Core, Sounds, Effects)
├── UI/             # Reusable components (Components, Glow, Animations)
├── Journal/        # Main journal system (Journal, Pages, Milestones, Zones, ProfileEditor)
├── Raids/          # Raid tracking (RaidData, Attunements, Karazhan, Gruul, Magtheridon)
├── Reputation/     # Faction tracking (ReputationData, Reputation)
└── Social/         # Multiplayer features (Badges, FellowTravelers, TravelerIcons, Minigames, MapPins)
    └── Games/      # Game system (GameCore, GameUI, GameComms, Tetris, DeathRoll, Pong, Words)
```

See [CLAUDE.md](CLAUDE.md) for detailed development documentation.

## Performance

HopeAddon is built with performance in mind:
- **Frame Pooling**: Reuses UI frames to minimize memory allocation
- **Event Filtering**: Early filtering of combat log events reduces CPU overhead
- **Caching**: Strategic caching of computed values (stats, timeline, riding skill)
- **Lazy Loading**: Modules initialize only when needed

## Development

See [CLAUDE.md](CLAUDE.md) for:
- Complete feature status tracking
- Architecture patterns and conventions
- Data structures and SavedVariables layout
- Frame pooling implementation details
- Known issues and future roadmap

## SavedVariables

The addon stores two types of data:
- **HopeAddonDB**: Account-wide settings (shared across all characters)
- **HopeAddonCharDB**: Per-character data (journal entries, attunements, statistics, profiles)

Data is automatically migrated on version updates.

## Credits

**Author**: Hope Guild
**License**: MIT License
**TBC Compatibility**: 2.4.3

Built with love for the Burning Crusade Classic community.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

If you encounter any issues or have suggestions:
1. Check the [Issues](https://github.com/[username]/HopeAddon/issues) page
2. Open a new issue with details about your problem or suggestion

---

**Enjoy your TBC adventure with HopeAddon!**
