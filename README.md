# HopeAddon

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![TBC](https://img.shields.io/badge/TBC-2.4.3-green.svg)
![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

A comprehensive TBC adventure journal addon for World of Warcraft with attunement tracking, reputation milestones, social features, and multiplayer minigames.

## Features

### Journal System (7 Tabs)
- **Timeline**: Chronological view of all character milestones and discoveries
- **Milestones**: Automatic level-based achievements (levels 5-70)
- **Raids**: Complete boss lists for all TBC raids with Phase 1-5 grouping
- **Reputation**: Milestone tracking for 18 TBC factions
- **Statistics**: Deaths by zone/boss, playtime, dungeon runs, combat stats
- **Armory**: Phase-based BiS gear tracking for your class and spec
- **Social**: Fellow Travelers directory, RP profiles, and activity feed

### Attunement Tracking
- **Karazhan**: Master's Key quest chain
- **Serpentshrine Cavern**: Vashj attunement chain
- **Tempest Keep**: Kael'thas attunement chain
- **Mount Hyjal**: Battle for Mount Hyjal chain
- **Black Temple**: Cipher of Damnation + Medallion of Karabor
- **Cipher of Damnation**: Three fragment quest chain

Progress bars and chapter-by-chapter tracking for all attunement chains.

### Social Features
- **Fellow Travelers**: Automatic detection of other addon users with nameplate coloring
- **RP Profiles**: Create and share character backstories, personality traits, and appearance
- **Badges**: Unlock 20+ achievements based on milestones and accomplishments
- **Map Pins**: See Fellow Travelers on your minimap with RP status coloring
- **Profile Directory**: Browse and search profiles of all detected addon users
- **Activity Feed**: Notice board with guild activity and mug reactions
- **Companions**: Track relationships with NPCs encountered in your journey
- **Romance System**: Develop relationships with fellow travelers
- **Rumors**: Share and discover rumors about other players
- **Guild System**: Guild roster caching, activity tracking, and member insights

### Calendar System
- **Event Scheduling**: Create and manage guild events and raid signups
- **Raid Signups**: Track attendance with role selection
- **Event Validation**: Comprehensive validation for event creation and signups

### Soft Reserve (SR) System
- **Per-Raid Reserves**: Set soft reserves for specific raids
- **Guild Overview**: View all guild members' soft reserves
- **Conflict Detection**: See who else is reserving your desired items

### Multiplayer Minigames
- **Dice Roll**: Classic high-roll game using real `/roll` detection
- **Rock-Paper-Scissors**: Best of 3 with hash-based commit-reveal protocol
- **Death Roll**: Turn-based gambling with 3-player escrow system
- **Tetris Battle**: Two-player competitive Tetris with garbage mechanic
- **Pong**: Classic arcade game with physics and AI opponent
- **Words with WoW**: Scrabble-style word game with WoW vocabulary and async multiplayer
- **Battleship**: Classic naval battle game with AI or multiplayer
- **WoW Wordle**: Word guessing game with WoW-themed vocabulary

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
- `/hope` or `/journal` - Open the journal UI
- `/hope stats` - Display statistics in chat
- `/hope debug` - Toggle debug mode
- `/hope sound` - Toggle sound effects
- `/hope combathide` - Toggle auto-hide UI during combat
- `/hope minimap` - Toggle minimap button visibility
- `/hope nameplates` - Toggle Fellow nameplate coloring
- `/hope pins` - Toggle minimap pin RP status coloring
- `/hope demo` - Populate sample data for UI testing
- `/hope reset demo` - Clear demo data
- `/hope reset confirm` - Reset all character data

### Minigame Commands
- `/hope challenge <player>` - Challenge a Fellow Traveler (opens game selection popup)
- `/hope tetris [player]` - Start Tetris Battle (local mode if no player specified)
- `/hope pong [player]` - Start Pong (local mode if no player specified)
- `/hope deathroll <player>` - Start Death Roll gambling game
- `/hope words` - Start local practice Words game
- `/hope words <player>` - Resume or start Words vs player
- `/hope words list` - Show all active Words games
- `/hope words forfeit <player>` - Forfeit a Words game
- `/hope battleship [player]` - Start Battleship (local vs AI if no player)
- `/hope wordle` - Start WoW Wordle (practice mode)
- `/hope wordle <player>` - Challenge player to Wordle
- `/hope wordle stats` - Show Wordle statistics
- `/hope accept` - Accept a pending challenge
- `/hope decline` - Decline a pending challenge
- `/hope cancel` - Cancel current game

### In-Game Commands
- `/word <word> <H/V> <row> <col>` - Place word in Words game
- `/pass` - Pass turn in Words game
- `/fire <coord>` - Fire in Battleship (e.g., `/fire A5`)
- `/ready` - Signal ships placed in Battleship
- `/surrender` - Forfeit Battleship game
- `/gc <message>` - Send chat to opponent in any game

### Soft Reserve Commands
- `/hope sr <raid> <item>` - Set soft reserve for a raid
- `/hope sr list` - Show your soft reserves
- `/hope sr clear <raid>` - Clear soft reserve for a raid
- `/hope sr guild [raid]` - Show guild soft reserves

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
