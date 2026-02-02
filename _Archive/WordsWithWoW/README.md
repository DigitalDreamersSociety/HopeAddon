# Words with WoW - Archived

This directory contains the archived Words with WoW game system, removed from active development on 2026-01-27.

## Reason for Archive

The tile placement drag-and-drop system had persistent bugs with coordinate detection and drop handling that proved difficult to resolve. The game is being shelved for potential future revisiting.

## Files

- `WordBoard.lua` - 15x15 Scrabble-style board with bonus squares
- `WordDictionary.lua` - WoW-themed word dictionary with letter values
- `WordGame.lua` - Main game logic, UI, drag/drop system (5000+ lines)
- `WordGameInvites.lua` - Multiplayer invite/accept/decline flow
- `WordGamePersistence.lua` - Save/load for async multiplayer
- `WordGameTests.lua` - Test suite
- `HopeAddon_Tests.toc` - Test addon TOC file

## To Restore

1. Move all `.lua` files back to `Social/Games/WordsWithWoW/`
2. Move `HopeAddon_Tests.toc` back to `HopeAddon/`
3. Move `WordGameTests.lua` back to `Tests/`
4. Add to `HopeAddon.toc`:
   ```
   Social\Games\WordsWithWoW\WordBoard.lua
   Social\Games\WordsWithWoW\WordDictionary.lua
   Social\Games\WordsWithWoW\WordGamePersistence.lua
   Social\Games\WordsWithWoW\WordGameInvites.lua
   Social\Games\WordsWithWoW\WordGame.lua
   ```
5. Restore Constants.lua entries (WORDS_* constants, GAME_DEFINITIONS entry)
6. Restore Core.lua slash commands and references
7. Restore Journal.lua game hall entries

## Known Issues When Archived

1. Tile drag coordinate detection used wrong coordinate space (scaled vs raw)
2. Drop detection via OnUpdate polling was unreliable
3. First word highlight showed entire row/column instead of valid positions only
