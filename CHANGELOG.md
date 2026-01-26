# HopeAddon Changelog

This file contains historical bug fixes and development phases for AI assistant reference.

---

## Phase 5: Pooling & Performance Optimizations

- ✅ **COMBAT_LOG Early Filter** (Journal.lua:2356) - Check subEvent with `select(2, ...)` BEFORE unpacking all values; reduces unnecessary work on 50,000+ events per raid session
- ✅ **Card Glow Tracking/Cleanup** (Journal.lua:198-209) - Added `_glowEffect` and `_sparkles` cleanup to card pool reset function; prevents memory leaks from orphaned glow effects
- ✅ **Timeline Entry Caching** (Journal.lua:674-685) - Cache sorted timeline entries; invalidated via `InvalidateCounts()` when entries change
- ✅ **Riding Skill Caching** (Journal.lua:2243-2259) - New `GetRidingSkill()` function with cache invalidation on `SKILL_LINES_CHANGED`; avoids O(n) linear search through 30-50 skills
- ✅ **Stats Batching** (Journal.lua:2149-2226) - New `GetCachedStatsData()` computes all counts in single pass; individual count functions now check cache first
- ✅ **Glow Parent Index** (Glow.lua:16, 30-55, 374-377, 415-428) - Added `glowsByParent` map for O(1) lookup when stopping glows by parent frame
- ✅ **Comprehensive OnDisable Cleanup** (Journal.lua:64-120) - Added cleanup for Effects, Glow registries, sparkles, and cached data
- ✅ **Boss Info Card Pool** (Journal.lua:341-386, 1676-1681) - New pool for raid metadata frames used in Raids tab

## Phase 6: Challenge Button Memory Leak Fixes

- ✅ **Card Pool challengeBtn/noteIcon Cleanup** (Journal.lua:255-268) - Added cleanup for challengeBtn (all 5 handlers + targetName) and noteIcon in card pool resetFunc; prevents closure memory leaks
- ✅ **OnClick Inside Creation Block** (Journal.lua:1920-1928) - Moved SetScript("OnClick") inside button creation block so handlers are set once, not on every render; eliminates N new closures per Directory tab render
- ✅ **OnCardClick Callback Cleanup** (Journal.lua:272) - Clear `card.OnCardClick` in resetFunc to prevent stale closure references from Milestones and Directory tabs

## Phase 7: Minigames Enhancements

- ✅ **GRES Result Validation** (Minigames.lua:962-1011) - Added `HandleResult()` function to validate incoming result messages match local calculation; warns on mismatch
- ✅ **Challenge Rate Limiting** (Minigames.lua:37, 70, 95, 234-246) - Added 30-second cooldown between challenges to same player; prevents spam
- ✅ **RPS Hash Enforcement** (Minigames.lua:40, 785-795) - Added `ENFORCE_HASH_INTEGRITY` option that cancels game if opponent's reveal doesn't match their commit hash; enabled by default

## Phase 5b: Remaining Performance Optimizations

- ✅ **SlideIn Animation Tracking** (Effects.lua:400-452) - Added `_slideAnimGroup` tracking to `SlideIn()` like `FadeIn()`/`FadeOut()` have; prevents animation stacking and memory leaks
- ✅ **PageFlip Timer Cleanup** (Animations.lua:206-270) - Clear `pageFlipTimers` array on animation completion; prevents timer handle references persisting after use
- ✅ **Centralized Raid Constants** (Constants.lua:2979-3011) - Added `C.RAID_TIERS`, `C.ALL_RAID_KEYS`, `C.ATTUNEMENT_RAID_KEYS`, `C.RAIDS_BY_TIER`, and `C:GetRaidTier()` helper function
- ✅ **Journal Raid List Deduplication** (Journal.lua:1593, 2277, 2297, 2378, 2422) - Replaced 5 duplicate raid list definitions with centralized Constants references
- ✅ **Milestones GetRaidTier** (Milestones.lua:375-377) - Replaced inline tier conditional with `Constants:GetRaidTier()` call

## Phase 8: Real /roll Detection for Dice Game

- ✅ **DICE_ROLL_PATTERN Constant** (Minigames.lua:42-44) - Added pattern to parse `CHAT_MSG_SYSTEM` roll messages: `"PlayerName rolls 42 (1-100)"`
- ✅ **Event Frame for Roll Detection** (Minigames.lua:78, 88-98, 111-114) - Created event frame in `OnEnable()`, registered `CHAT_MSG_SYSTEM`, cleanup in `OnDisable()`
- ✅ **OnSystemMessage Handler** (Minigames.lua:129-158) - Parses roll messages, validates 1-100 range, routes to local or opponent handlers
- ✅ **HandleLocalDiceRoll** (Minigames.lua:165-185) - Processes local player's roll from chat, sends to opponent via addon message, updates UI
- ✅ **HandleOpponentDiceRoll** (Minigames.lua:191-198) - Stores opponent's chat-detected roll for verification against addon message
- ✅ **MakeDiceMove Refactor** (Minigames.lua:622-640) - Replaced `math.random()` with `RandomRoll(1, 100)`, added `rollRequested` state tracking
- ✅ **Roll Verification** (Minigames.lua:670-675) - Verifies opponent's addon message roll against chat-detected roll; trusts chat if mismatch
- ✅ **OnRollRequested UI Function** (MinigamesUI.lua:847-853) - Updates button to show "Rolling..." state while waiting for chat result
- ✅ **Dice Label Centering** (MinigamesUI.lua:508, 543) - Changed player/opponent labels from TOP anchor to CENTER-based positioning
- ✅ **RPS Button Row Centering** (MinigamesUI.lua:605) - Removed arbitrary Y offset from button row positioning
- ✅ **Status Text Enhancement** (MinigamesUI.lua:791) - Added "Click to /roll" hint to dice game status text

## Phase 9: Pong Game Resource Management Fixes

- ✅ **Countdown Timer Leak** (PongGame.lua:234-278) - Store countdown timer in `game.data.countdownTimer` for cancellation; re-fetch game each tick to avoid stale closure references; cancel timer in CleanupGame
- ✅ **Nil Check Chaining** (PongGame.lua:160-174) - Split nil check in OnUpdate to prevent accessing `game.data` when game is nil
- ✅ **GameCore Validation** (PongGame.lua:326, 348) - Added nil checks for GameCore in UpdateLocalPaddle and UpdateLocalPaddles before calling GameCore methods
- ✅ **Window Reference Storage** (PongGame.lua:620) - Store window reference in `game.data.window` for proper cleanup
- ✅ **Comprehensive UI Cleanup** (PongGame.lua:800-860) - Release all frame references (paddle1Frame, paddle2Frame, ballFrame, playArea, window) with Hide + SetParent(nil); clear text references; cancel countdown timer

## Phase 10: Minigames UI & Slash Command Improvements

- ✅ **Directory Tab Custom Color** (Components.lua:237-314, Journal.lua:640) - Added `customColor` parameter to `CreateTabButton()` for per-tab color theming; Directory tab now uses `ARCANE_PURPLE` to visually distinguish social/games features
- ✅ **Tab Highlight Color** (Components.lua:254-263) - Hover highlight now uses custom color when provided instead of default gold
- ✅ **Selected Indicator Color** (Components.lua:298-307) - Selected state indicator bar now uses custom color when provided
- ✅ **Death Roll Slash Command** (Core.lua:710-731) - Added `/hope deathroll [player]` command supporting both local and remote play
- ✅ **Words Slash Command** (Core.lua:732-747) - Added `/hope words <player>` command for remote play with helpful usage message
- ✅ **Help Text Update** (Core.lua:786-787) - Updated help output to include new deathroll and words commands

## Phase 11: Death Roll Resource Management Fixes

- ✅ **CleanupGame Function Added** (DeathRollGame.lua:217-254) - Created comprehensive cleanup function with window, text references, and escrow cleanup following Tetris/Pong patterns
- ✅ **OnDestroy Refactor** (DeathRollGame.lua:209-211) - Updated OnDestroy to call CleanupGame for proper resource cleanup
- ✅ **FontString Cleanup** (DeathRollGame.lua:243-247) - Clear maxValueText, turnText, historyText, proximityText references to prevent memory leaks
- ✅ **Escrow Cleanup on Destroy** (DeathRollGame.lua:226-231) - Call Escrow:CancelEscrow when game destroyed with active bet
- ✅ **Nil Check Guards** (DeathRollGame.lua:169) - Added game.data nil check in OnEnd to prevent accessing nil data
- ✅ **GameUI Window Destruction** (DeathRollGame.lua:250-252) - Call GameUI:DestroyGameWindow to unregister window from GameUI registry
- ✅ **Escrow Timer Management** (DeathRollEscrow.lua:362) - Store cleanup timer handle in session.cleanupTimer for cancellation
- ✅ **CancelEscrow Function** (DeathRollEscrow.lua:436-451) - Added CancelEscrow function to cancel escrow sessions and cleanup timers
- ✅ **FindSessionByGameId Helper** (DeathRollEscrow.lua:453-461) - Added helper function to find session by game ID
- ✅ **Function Call Bug Fix** (DeathRollUI.lua:233-241) - Fixed InitiateEscrow → InitiateAsHouse with correct parameters (gameId, betAmount, player1, player2)

## Phase 12: Games Hall UI Enhancement

- ✅ **GAME_DEFINITIONS Constant** (Constants.lua:3018-3090) - Added centralized game definitions with id, name, description, icon, hasLocal, hasRemote, system, color properties
- ✅ **CreateGameCard Component** (Components.lua:2049-2274) - New storybook-style game card component with icon, title, description, stats row, Practice and Challenge buttons
- ✅ **gameCardPool** (Journal.lua:377-420) - New frame pool for game cards with proper reset function to prevent memory leaks
- ✅ **AcquireGameCard** (Journal.lua:430-441) - Pool acquisition function for game cards
- ✅ **PopulateDirectory Refactor** (Journal.lua:1817-1954) - Added collapsible "GAMES HALL" section at top of Directory tab with 3x2 game card grid
- ✅ **GetGameStats** (Journal.lua:1961-1982) - Aggregate win/loss/tie stats across all travelers for a game
- ✅ **StartLocalGame** (Journal.lua:1988-2016) - Handler for Practice button to start local games (dice, deathroll, pong, tetris)
- ✅ **ShowTravelerPickerForGame** (MinigamesUI.lua:1527-1609) - New popup for selecting Fellow Traveler to challenge from Games Hall
- ✅ **GetTravelerPickerPopup** (MinigamesUI.lua:1377-1463) - Creates traveler picker popup with scroll frame
- ✅ **GetTravelerButton** (MinigamesUI.lua:1471-1521) - Reusable traveler selection buttons for picker

## Phase 13: Words with WoW Test Suite

- ✅ **WordGameTests.lua** (Tests/WordGameTests.lua) - Comprehensive automated test suite for Words with WoW game system
- ✅ **Dictionary Tests** - Validate word validation, letter values, tile bag generation, case insensitivity
- ✅ **Board Placement Tests** - Test center rule, connectivity, bounds checking, conflict detection
- ✅ **Scoring Tests** - Verify bonus squares (DW, TW, DL, TL), multiplier calculations, cross-word scoring
- ✅ **Cross-Word Tests** - Test cross-word detection, validation, GetHorizontalWord/GetVerticalWord
- ✅ **Game Flow Tests** - Test state management, turn switching, pass system, game completion
- ✅ **Test Infrastructure** - Assert/AssertEquals utilities, test counters, summary reports
- ✅ **Slash Commands** - `/wordtest all`, `/wordtest dict`, `/wordtest board`, `/wordtest score`, `/wordtest cross`, `/wordtest flow`
- ✅ **Test Documentation** (Tests/README.md) - Complete test coverage documentation, manual test procedures, troubleshooting guide
- ✅ **Separate Test Addon** (HopeAddon_Tests.toc) - LoadOnDemand test addon that doesn't load by default in production
- ✅ **50+ Test Cases** - Comprehensive coverage of all Words with WoW functionality
- ✅ **Manual Network Test Procedure** - Step-by-step guide for testing remote multiplayer with 2 clients

---

## Phase 14: Production Readiness (Memory Leaks & Error Resilience)

- ✅ **Module Lifecycle Protection** (Core.lua:499-508, 536-543) - Wrapped OnEnable/OnDisable calls in pcall to prevent one failing module from cascading
- ✅ **Combat Log Handler Protection** (Journal.lua:649-653, RaidData.lua:346-358) - Wrapped COMBAT_LOG_EVENT_UNFILTERED handlers in pcall for stability during raids
- ✅ **eventFrame Cleanup** (6 modules) - Added `self.eventFrame = nil` after UnregisterAllEvents to prevent memory leaks:
  - FellowTravelers.lua:140-152
  - MapPins.lua:391-404
  - Reputation.lua:29-39
  - DeathRollGame.lua:94-106
  - Journal.lua:100-131
  - RaidData.lua:508-514
- ✅ **SafeCall Utility** (Core.lua:364-376) - Added `HopeAddon:SafeCall(func, ...)` for protected function execution
- ✅ **Slash Command Validation** (Core.lua:665-681) - Added ValidatePlayerName() function with length and format checks for `/hope words` and `/hope challenge`
- ✅ **ENCOUNTER_END Documentation** (RaidData.lua:339-341) - Documented that ENCOUNTER_END doesn't exist in TBC Classic 2.4.3; boss detection relies on COMBAT_LOG UNIT_DIED
- ✅ **Pool Cleanup Enhancement** (Journal.lua:107-131) - Added nil assignments after Destroy() calls for all 6 frame pools

## Phase 15: Documentation Organization

- ✅ **AI Quick Start Section** - Added guidance for common tasks and module patterns at document top
- ✅ **Module Dependencies Section** - Added load order, dependency graph, key relationships table
- ✅ **Event Handlers Table** - Added WoW event handlers by module reference
- ✅ **Missing Files Added** - Added Directory.lua and Relationships.lua to File Quick Reference
- ✅ **Missing Pools Added** - Added collapsiblePool and bossInfoPool to Frame Pooling table
- ✅ **Pool Line Numbers Fixed** - Updated all pool line references to match actual code
- ✅ **File Sizes Updated** - Fixed Effects.lua (~20KB), Sounds.lua (~8KB), Timer.lua (~8KB)
- ✅ **Directory Module Details** - Added comprehensive API documentation with all 8 public functions
- ✅ **Relationships Module Details** - Added comprehensive API documentation with all 12 public functions
- ✅ **FellowTravelers Module Details** - Added communication hub documentation with key API
- ✅ **Data Structures Enhanced** - Expanded HopeAddonCharDB with relationships and full structure
- ✅ **Account Data Added** - Added HopeAddonDB structure documentation
- ✅ **AI Session Handoff Checklist** - Added checklist for session continuity
- ✅ **Boss Detection Resolved** - Removed from Known Incomplete (documented in Phase 14)
- ✅ **Game System Paths Fixed** - Corrected `Games/` to `Social/Games/` throughout
- ✅ **Tests Folder Corrected** - Fixed "LoadOnDemand" to actual files (WordGameTests.lua, README.md)

## Phase 16: Implementation Guide Execution (2026-01-19)

**Critical Fixes:**
- ✅ **Pong Ball Desync (C2)** (PongGame.lua:418-422) - Added host-only ball physics check; client receives ball state from network instead of running local physics
- ✅ **PlayHover Sound (A3)** (Sounds.lua:148-150) - Added missing `PlayHover()` function to fix error in GameUI button hover handlers

**High Priority Fixes:**
- ✅ **RecalculatePositions Consistency (M1)** (Components.lua:695-711) - Added component-type-aware fallback logic matching AddEntry; removed extra MARGIN_NORMAL from final height calculation to prevent layout shifts on collapsible toggle
- ✅ **Words Score Validation (H4)** (WordGame.lua:490-514) - Added score validation in HandleRemoteMove comparing remote claimed score vs locally calculated; mismatches logged to debug

**Documentation Updates:**
- ✅ Updated UI_ORGANIZATION_GUIDE.md: H3, M2, M3, M5 marked as "Won't Fix - By Design" with justifications
- ✅ Phase 2 (High Priority) and Phase 3 (Medium Priority) marked complete

**Previously Implemented (Verified This Session):**
- ✅ **Words Memory Leak (C1)** (WordGame.lua:201-258) - CleanupGame function with comprehensive FontString and frame cleanup
- ✅ **Words Board Performance (C3)** (WordGame.lua:735-792) - Row caching with dirtyRows tracking for O(1) rendering
- ✅ **Scroll Height Fallback (H1)** (Components.lua:654-666) - Component-type-aware fallbacks using `_componentType` metadata
- ✅ **Words Window Size (H2)** (GameUI.lua:34, WordGame.lua:532) - Dedicated WORDS constant (650x600)

## Phase 17: PAYLOADS 1-4 Implementation (2026-01-19)

**PAYLOAD 1: Layout Consistency Fixes (4 hours)**
- ✅ **Words ui/state Refactoring** (WordGame.lua) - Completed refactoring of 12 functions to use `game.data.ui.*` and `game.data.state.*` structure
  - OnStart, OnEnd, CleanupGame, GetCurrentPlayer
  - PlaceWord, PassTurn, NextTurn, HandleRemoteMove, HandleRemotePass
  - ShowUI, UpdateUI, RenderBoard, InvalidateRows
  - CRITICAL: Preserved `state.board` as WordBoard instance with methods intact
- ✅ **All Games Refactored** - Pong (17 functions), DeathRoll (11 functions), Tetris (30+ functions), Words (12 functions)
- ✅ **Memory Leak Prevention** - All games now have O(1) CleanupGame with proper frame lifecycle

**PAYLOAD 2: Code Refactoring (12 hours)**
- ✅ **CreateBackdropFrame Centralized** (Core.lua:378-411) - Eliminated ~150 lines of duplication across 8 files
  - Handles TBC Classic vs original TBC with BackdropTemplateMixin check
  - Replaced local implementations in: Components.lua, Journal.lua, ProfileEditor.lua, Pages.lua, MinigamesUI.lua, GameUI.lua, DeathRollUI.lua, Reputation.lua
- ✅ **LayoutBuilder Component** (Components.lua:697-764) - Automated form layout with yOffset tracking
  - AddRow(frame, spacing) - Auto-positions frames vertically
  - AddSpacer(height) - Adds vertical spacing
  - Reset() - Resets for multi-column layouts
- ✅ **Labeled Control Factories** (Components.lua:975-1084)
  - CreateLabeledEditBox(parent, labelText, placeholder, maxLetters)
  - CreateLabeledDropdown(parent, labelText, options)
  - CreateCheckboxWithLabel(parent, labelText, defaultChecked)
- ✅ **ColorUtils Namespace** (Core.lua:447-556)
  - Lighten(color, percent) / Darken(color, percent)
  - ApplyVertexColor(texture, colorName) / ApplyTextColor(fontString, colorName)
  - Blend(color1, color2, ratio)
  - HexToRGB(hex)
- ✅ **CreateStyledButton Factory** (Components.lua:1098-1176) - Consistent button styling with hover effects

**PAYLOAD 3: Animation Integration (10 hours)**
- ✅ **ColorTransition Function** (Animations.lua:202-244) - Smooth 150ms border color transitions using custom tween system
  - Uses easeOutQuad for smooth transitions
  - Stores current color for next transition
  - Respects animationsEnabled setting
- ✅ **Hover Transitions Applied** - All styled buttons and labeled dropdowns use ColorTransition
  - OnEnter: Transition to GOLD_BRIGHT (150ms)
  - OnLeave: Transition back to default border color (150ms)
- ✅ **Celebration Effects** (Effects.lua:645-741)
  - Celebrate(frame, duration, options) - Composite effect: glow + sparkles + sound
  - IconGlow(frame, duration) - Shorter icon celebration
  - ProgressSparkles(progressBar, duration) - Progress bar completion sparkles
- ✅ **Integration Points**
  - Progress bars at 100%: Sparkles + gold border (Components.lua:286-309)
  - Game victories: Full celebration effect (GameUI.lua:517-520)
  - Collapsible sections: 200ms fade animations (Components.lua:1302-1340)
- ✅ **TBC Compatibility** - All animations use HopeAddon.Timer and custom tween system (no retail APIs)

**PAYLOAD 4: TBC Theme Audit (5 hours)**
- ✅ **Game Card Colors Updated** (Components.lua:2465-2469) - Replaced BROWN with ARCANE_PURPLE (0.61, 0.19, 1.0)
- ✅ **MinigamesUI Colors Updated** (MinigamesUI.lua:627, 1196) - Replaced BROWN with ARCANE_PURPLE for RPS buttons and game icon buttons
- ✅ **Tab Color Verification** - Audited all 7 journal tabs, confirmed TBC palette usage:
  - Journey: GOLD_BRIGHT (primary), FEL_GREEN (Outland content)
  - Reputation: ARCANE_PURPLE (main header), GOLD_BRIGHT (categories)
  - Raids: Tier colors (T4=GOLD_BRIGHT, T5=SKY_BLUE, T6=HELLFIRE_RED)
  - Attunements: ARCANE_PURPLE (magic theme), tier colors
  - Games: ARCANE_PURPLE (Games Hall)
  - Social: FEL_GREEN (Fellow Travelers)
  - Stats: GOLD_BRIGHT, FEL_GREEN, ARCANE_PURPLE
- ✅ **BROWN Eliminated** - All UI elements now use TBC palette (only color definition remains in Constants.lua)
- ✅ **Documentation Verified** - All color values already documented with actual RGB values (no 0.XX placeholders)
- ✅ **Icon Organization Examples** - UI_ORGANIZATION_GUIDE.md already has comprehensive examples (no additions needed)

**Files Modified (Total: 12 files)**
- Core.lua (CreateBackdropFrame, ColorUtils)
- Components.lua (LayoutBuilder, labeled controls, CreateStyledButton, progress bar sparkles, collapsible animations, game card colors)
- Animations.lua (ColorTransition)
- Effects.lua (Celebrate, IconGlow, ProgressSparkles)
- GameUI.lua (victory celebrations)
- MinigamesUI.lua (ARCANE_PURPLE for RPS/game buttons)
- WordGame.lua (ui/state refactoring, 12 functions)
- 5 other files (CreateBackdropFrame centralized): Journal.lua, ProfileEditor.lua, Pages.lua, DeathRollUI.lua, Reputation.lua

**Results:**
- ~150 lines of duplication eliminated
- Consistent ui/state structure across all 4 games
- Smooth animations on all buttons (150ms color transitions)
- Celebration effects on victories and achievements
- 100% TBC aesthetic (arcane purple, fel green, gold - no brown)
- All TBC 2.4.3 compatible (no retail APIs used)

## Phase 18: Score Challenge System (2026-01-19)

**Problem:** Real-time multiplayer Tetris/Pong over WoW addon communication has 100-500ms+ latency, making gameplay feel laggy and requiring complex sync logic.

**Solution:** Score-based challenge mode - both players play their own local game simultaneously, compare scores at end.

**New Files:**
- ✅ **ScoreChallenge.lua** (~400 lines) - Complete challenge orchestration module
  - Challenge invite/accept/decline flow with 60s timeout
  - Status pings every 10 seconds show opponent progress
  - Simple anti-cheat with hash tokens (prevents casual injection)
  - Game end handling with score comparison
  - 600s game timeout, 120s wait for opponent timeout

**Modified Files:**
- ✅ **GameCore.lua** - Added `SCORE_CHALLENGE` to `GAME_MODE` enum
- ✅ **TetrisGame.lua** - Score challenge integration:
  - `isScoreChallenge` state tracking
  - Skip garbage mechanics in SCORE_CHALLENGE mode
  - Opponent status panel (`CreateOpponentPanel`, `UpdateOpponentPanel`)
  - Notify ScoreChallenge on score updates and game over
- ✅ **PongGame.lua** - AI paddle and score challenge:
  - `UpdateAIPaddle()` - 85% tracking with ball prediction, beatable but challenging
  - Opponent status panel for challenge mode
  - Player vs AI, compare who beats AI faster/better
- ✅ **GameComms.lua** - Routes `SCORE_TETRIS` and `SCORE_PONG` game types to ScoreChallenge module
- ✅ **GameUI.lua** - Added `UpdateOpponentStatus()` function to route updates to games
- ✅ **Core.lua** - Updated slash commands:
  - `/hope tetris [player]` uses ScoreChallenge when player specified
  - `/hope pong [player]` uses ScoreChallenge when player specified
  - `/hope accept/decline/cancel` check ScoreChallenge first
- ✅ **HopeAddon.toc** - Added ScoreChallenge.lua to load order

**Key Design Decisions:**
- Pong AI Paddle approach (user confirmed) - both players compete vs AI, compare scores
- Simple hash anti-cheat (user confirmed) - concatenated player names + score + gameId hash
- Reuses existing GameComms infrastructure with SCORE_ prefix game types
- No changes to local 2-player modes (preserved)

**UI Integration Fixes (2026-01-19):**
- ✅ **ScoreChallenge popup notification** (ScoreChallenge.lua:486-520) - Added call to `MinigamesUI:ShowChallengePopup()` when challenge received, plays bell sound
- ✅ **Accept/Decline routing** (MinigamesUI.lua:65-124) - Added `scorechallenge` source handling to route Accept/Decline to `ScoreChallenge:AcceptChallenge/DeclineChallenge`
- ✅ **GAME_NAMES table** (MinigamesUI.lua:45-60) - Added `SCORE_TETRIS` and `SCORE_PONG` display names ("Tetris Score Battle", "Pong Score Battle")
- ✅ **Traveler picker routing** (MinigamesUI.lua:1318-1365) - Games Hall Challenge button now routes Tetris/Pong to `ScoreChallenge:StartChallenge()` instead of `GameComms:SendInvite()`

**User Flow:**
1. Games Hall → Click "Challenge" on Tetris/Pong card → Traveler Picker popup
2. Select Fellow Traveler → ScoreChallenge sends invite via GameComms
3. Opponent receives popup with Accept/Decline buttons + bell sound
4. Both players start local game simultaneously with opponent status panel

## Phase 19: UI Organization & Documentation (2026-01-19)

**Low Priority Fixes (L1-L5):**
- ✅ **L1: Minimap Tooltip Icons** (MapPins.lua:30-55) - Added icon display using `TravelerIcons:GetHighestQualityIcon()`; falls back to default "INV_Misc_GroupLooking" icon
- ✅ **L2: Inline Handler Closures** - Verified already resolved; all handlers at module scope in MinigamesUI.lua
- ✅ **L3: Font Constants** (GameUI.lua:27-35) - Added `GAME_FONTS` centralized table with TITLE, SCORE, LABEL, STATUS, HINT, MONOSPACE
- ✅ **L4/L5: BROWN Color Elimination** - Replaced all hardcoded BROWN (0.6, 0.5, 0.3) with ARCANE_PURPLE:
  - Journal.lua: Card borders (line 408-409), button border (line 2963)
  - MinigamesUI.lua: Game button leave (line 229), dice frames (lines 545, 573), RPS buttons (line 948)

**Documentation Updates:**
- ✅ Updated UI_ORGANIZATION_GUIDE.md to v1.2:
  - All Low Priority issues marked resolved
  - Phase 4 marked complete
  - Added Phase 17 utility examples (LayoutBuilder, CreateStyledButton, Celebration Effects)
  - Updated Part 7 Critical Files to show resolved status
- ✅ Updated CLAUDE.md:
  - Added Phase 17 utilities to Shared UI Components table
  - Added ColorUtils and Celebration Effects documentation
  - Added this Phase 19 entry

**Files Modified:**
- Journal.lua (2 color replacements)
- MinigamesUI.lua (4 color replacements)
- MapPins.lua (tooltip icon support)
- GameUI.lua (GAME_FONTS table)
- UI_ORGANIZATION_GUIDE.md (v1.2 update)
- CLAUDE.md (utilities documentation, Phase 19)

## Phase 20: UI Rendering Fixes & Demo Mode (2026-01-19)

**Critical Fix: Scroll Content Frame Width**
- ✅ **Problem:** `CreateScrollFrame` calculated content width before `SetAllPoints` was called, resulting in 0 width
- ✅ **Fix:** Added `OnSizeChanged` handler to update content width when scroll frame is resized (Components.lua:620-630)

**Demo Data Mode for UI Testing**
- ✅ **Commands:** `/hope demo` (populate) and `/hope reset demo` (clear)
- ✅ **Implementation:** `PopulateDemoData()` and `ClearDemoData()` functions in Core.lua
- ✅ **Sample Data Includes:**
  - 6 level milestones (5, 10, 15, 20, 25, 30)
  - 3 zone discoveries (Hellfire, Zangarmarsh, Shattrath)
  - Stats: deaths, playtime, quests completed, creatures slain, largest hit
  - 3 sample travelers (Thrall, Jaina, Sylvanas)
  - 1 Fellow Traveler with RP profile (Arthas)
  - 1 relationship note

**Documentation:**
- ✅ Updated UI_COMPLETION_CHECKLIST.md - Marked P0/P1 complete, added fix details
- ✅ Updated CLAUDE.md Testing Commands - Added /hope demo commands
- ✅ Created new document UI_COMPLETION_CHECKLIST.md - Tracks UI completion tasks

**Files Modified:**
- Components.lua (scroll content width fix)
- Core.lua (PopulateDemoData, ClearDemoData, slash command handlers)
- UI_COMPLETION_CHECKLIST.md (status updates)
- CLAUDE.md (Phase 20, demo commands)

## Phase 21: Fellow Traveler Detection Improvements (2026-01-19)

**Discovery Notification Enhancements:**
- ✅ **Comedy Sound:** Added Murloc aggro sound (`FELLOW_DISCOVERY`) plays when new Fellow Traveler detected
- ✅ **Sound Cooldown:** Added 30-second cooldown (`DISCOVERY_SOUND_COOLDOWN`) to prevent audio spam in crowded areas (Shattrath, raids)
- ✅ **Enhanced Message:** Changed from plain text to colorful: `|cFF9B30FF[Fellow Traveler]|r |cFF00FF00Name|r discovered nearby! Mrglglgl!`
- ✅ **Faster Detection:** Reduced `BROADCAST_INTERVAL` from 30s to 15s for quicker discovery

**How Fellow Traveler Detection Works:**
1. Addon broadcasts PING on YELL (300yd), PARTY, RAID, GUILD channels every 15 seconds
2. Other addon users respond with PONG containing their info
3. On first discovery of a new player: Murloc sound plays + chat notification
4. Fellow Travelers appear on minimap pins and in Directory tab
5. Hovering over Fellow Travelers in-world shows full RP profile tooltip

**Existing Tooltip Features (already implemented):**
- Fellow Traveler badge
- Selected title
- RP Status (IC/OOC/LF_RP)
- Backstory excerpt (100 chars)
- Personality traits
- Appearance description
- RP Hooks/Rumors
- Pronouns
- First seen date

**Files Modified:**
- Core.lua (added FELLOW_DISCOVERY sound path)
- FellowTravelers.lua (broadcast interval 30→15s, discovery notification with sound)

## Phase 22: Gaming-Style Reputation Bar (2026-01-19)

**Goal:** Transform reputation bars into satisfying "gaming XP bar" experience with chunky segments and audio feedback.

**Visual Enhancements:**
- ✅ **Texture Swap** (Components.lua:1668) - Changed from `SKILLS_BAR` (striated) to `STATUS_BAR` (smooth metallic gradient)
- ✅ **Segment Dividers** (Components.lua:1718-1729) - 9 vertical dividers at 10% intervals for chunky gaming feel
- ✅ **Diamond Milestones** (Components.lua:1735-1746) - Replaced thin tick marks with rotated GLOW_STAR diamonds at 25/50/75%
- ✅ **Leading Edge Glow** (Components.lua:1799-1808) - Pulsing GLOW_BUTTON at progress front
- ✅ **Inner Bevel** (Components.lua:1678-1694) - Top shadow + bottom highlight for 3D depth effect

**Animation & Sound Integration:**
- ✅ **Segment Tracking** (Components.lua:AnimateProgress) - Tracks crossing 10% boundaries during animation
- ✅ **OnSegmentCrossed** (Components.lua:2028-2040) - Gold flash on divider + tick sound every 10%
- ✅ **OnMilestoneCrossed** (Components.lua:2043-2059) - Bell chime + burst effect at 25/50/75%
- ✅ **OnProgressComplete** (Components.lua:2062-2075) - Achievement sound + sparkles at 100%
- ✅ **Progress Sounds** (Sounds.lua) - Added `progress` category with tick, milestone, complete sounds

**Files Modified:**
- Components.lua (CreateReputationBar complete overhaul - texture, segments, diamonds, glow, bevel, callbacks)
- Sounds.lua (Added progress sound category and PlayProgressTick/PlayProgressMilestone/PlayProgressComplete)

## Phase 23: Remove Milestones Tab (2026-01-19)

**Goal:** Simplify journal UI by removing dedicated Milestones tab. Milestone entries still appear in Journey timeline.

**Changes:**
- ✅ **Tab Registration** (Journal.lua:728-737) - Removed milestones from tabData array
- ✅ **SelectTab Case** (Journal.lua:823-825) - Removed milestones case from tab selection switch
- ✅ **UI Code Cleanup** (Journal.lua) - Removed ~100 lines of Milestones-only code:
  - `MAJOR_MILESTONES` table
  - `CHRONICLE_ACTS` table (3-act structure)
  - `CreateMilestoneEntry()` function
  - `CreateActSection()` function
  - `PopulateMilestones()` function
- ✅ **Tab Migration** (Journal.lua:3761-3766) - Users with lastTab="milestones" now default to "journey"

**Preserved:**
- `Journal/Milestones.lua` module - Still tracks level-up events
- `CreateChronicleHeader()` - Still used by Journey tab for progress bar
- Milestone entries in Journey timeline
- Stats tab milestone counts
- Badge triggers on milestone completion

**Files Modified:**
- Journal.lua (tab removal, UI cleanup, migration fallback)
- CLAUDE.md (documentation updates)

## Phase 23: Journey Tab Enhancements (2026-01-19)

**New Features:**
- ✅ **Next Step Box** (Journal.lua:1652-1664) - Prominent WoWhead-style progression guidance at top of Journey tab
  - `GetNextStep()` function at line 1636 returns progression data
  - Adapts to 5 phases: PRE_OUTLAND, T4_ATTUNEMENT, T5_ATTUNEMENT, T6_ATTUNEMENT, RAID_PROGRESSION, ENDGAME
  - Shows current chapter, story text, progress bar with phase-colored fill
  - Phase-colored borders (FEL_GREEN for T4, ARCANE_PURPLE for T5, HELLFIRE_RED for T6, etc.)
- ✅ **Enhanced Reputation Summary** (Journal.lua:1607-1634) - Progress bars and reward tracking
  - Per-faction rows with progress bars showing rep within current standing
  - Shows heroic key status with [Key] indicator when Honored+
  - Color-coded standings and progress fills
- ✅ **New Constants** (Journal.lua:51-89) - HEROIC_KEY_ICONS, HEROIC_KEY_NAMES, REQUIREMENT_TYPE_ICONS, PHASE_COLORS, PHASE_NAMES, STANDING_THRESHOLDS, STANDING_NAMES

**Key Functions Added:**
- `Journal:GetNextStep()` (line 1636) - Returns comprehensive progression data for the Next Step box
- `Journal:CreateNextStepBox()` (line 1652) - Creates the prominent Next Step guidance UI
- Enhanced `Journal:CreateReputationSummary()` (line 1607) - Now shows progress bars and reward info
- `Journal:PopulateJourney()` (line 1703) - Updated to call CreateNextStepBox at top of Journey tab

## Phase 24: Remove Zones Tab (2026-01-19)

**Goal:** Simplify journal UI by removing the Zones tab entirely.

**Files Removed:**
- `Journal/Zones.lua` - Entire module deleted

**Files Modified:**
- **HopeAddon.toc** - Removed Zones.lua from load order
- **Journal.lua** - Removed:
  - Tab registration for "zones"
  - SelectTab case for zones
  - `PopulateZones()` function
  - `PopulateZones_placeholder()` function (dead code)
  - `OnZoneChanged()` event handler
  - `CountOutlandZonesExplored()` function
  - Zone-related stats cards in Stats tab
  - Zone references in GetCachedCounts(), footer
  - ZONE_CHANGED_NEW_AREA event registration
- **Core/Constants.lua** - Removed:
  - `C.ZONE_DISCOVERIES` table (~50 lines)
  - `C.OUTLAND_ZONES` list
- **Core/Core.lua** - Removed:
  - `zoneDiscoveries` from default charDb
  - Zone population in PopulateDemoData()
  - Zone clear in ClearDemoData()
  - Zone stats in PrintStats()
- **Social/Badges.lua** - Removed:
  - `through_portal` badge (zone-based unlock)
  - Zone unlock type handling in CheckUnlockCondition()
  - `OnZoneDiscovered()` callback
- **Social/TravelerIcons.lua** - Removed:
  - `OnZoneDiscovery()` function
  - `CheckZoneIcons()` function
  - `CheckAllZonesIcon()` function
  - `RecordZoneVisitedTogether()` function
  - `zonesVisitedTogether` from stats structures

**Impact:**
- Journal now has 7 tabs: Journey, Reputation, Raids, Attunements, Games, Social, Stats
- Existing `charDb.journal.zoneDiscoveries` data becomes orphaned (harmless)
- ~500 lines of code removed

## Phase 25: Separate Games and Social Tabs (2026-01-19)

**Goal:** Split the combined Directory tab into two focused tabs for better organization.

**Changes:**
- ✅ **New Games Tab** - Dedicated tab for minigames with Practice and Challenge buttons
  - `PopulateGames()` function (Journal.lua:2638)
  - Header: "GAMES HALL" with instructions text
  - 6 game cards in 3x2 grid layout
  - Practice button (green) - solo/local play
  - Challenge button (purple) - opens traveler picker
- ✅ **New Social Tab** - Renamed from Directory, Fellow Travelers only
  - `PopulateSocial()` function (Journal.lua:2730)
  - Header: "FELLOW TRAVELERS"
  - Stats summary (addon users, recent count)
  - Searchable player directory

**Files Modified:**
- Journal.lua:
  - Added "games" and "social" tabs to tabData (lines 775-776)
  - SelectTab routing for both tabs (lines 874-877)
  - Migration: "directory" → "social" (lines 858-861)
  - Removed old `PopulateDirectory()` function
  - Added `PopulateGames()` and `PopulateSocial()` functions

**User Flow:**
- Games Tab: Click Practice to play solo, Click Challenge to invite Fellow Traveler
- Social Tab: Browse Fellow Travelers, view profiles, challenge directly

## Phase 26: Games Tab Practice Mode (2026-01-19)

**Goal:** Fix Practice buttons so all applicable games work in solo/local mode.

**Issues Found:**
- Dice Roll: `Minigames:StartLocalDiceGame()` was called but didn't exist
- Death Roll: `Minigames:StartLocalDeathRoll()` was called but didn't exist
- Words with WoW: `hasLocal = false` despite having full local mode support

**Fixes Implemented:**

1. **Death Roll** - Wire to existing `DeathRollUI:QuickStartLocal()`
   - Changed Journal.lua to call `DeathRollUI:QuickStartLocal()` instead of non-existent function

2. **Words with WoW** - Enable local mode
   - Changed `hasLocal = false` → `true` in Constants.lua:3302
   - Added handler in Journal.lua to call `WordGame:StartGame(nil)`

3. **Dice Roll** - Implement local practice mode
   - Added `Minigames.localDiceGame` state table
   - Added `Minigames:StartLocalDiceGame()` - generates computer roll, shows UI
   - Added `Minigames:HandleLocalDiceGameRoll()` - compares rolls, shows result
   - Updated `Minigames:OnSystemMessage()` - checks for local game before multiplayer
   - Added `MinigamesUI:ShowLocalDiceGame()` - shows dice UI for practice mode
   - Updated `OnDiceRollClick()` - handles local game via `RandomRoll(1, 100)`

**Files Modified:**
- `Journal/Journal.lua` - Fixed StartLocalGame() handlers for deathroll, words
- `Core/Constants.lua` - Set hasLocal=true for words
- `Social/Minigames.lua` - Added StartLocalDiceGame(), HandleLocalDiceGameRoll(), updated OnSystemMessage()
- `Social/MinigamesUI.lua` - Added ShowLocalDiceGame(), updated OnDiceRollClick()

**Practice Mode Status (Final):**
| Game | Practice Button | Mode |
|------|-----------------|------|
| Dice Roll | ✅ Works | vs Computer (random roll) |
| RPS | ❌ Disabled | By design - requires 2 players |
| Death Roll | ✅ Works | vs Self (alternating rolls) |
| Pong | ✅ Works | 2-player local (W/S + Up/Down) |
| Tetris | ✅ Works | 2-player local with garbage |
| Words | ✅ Works | vs Self (alternating turns) |

## Phase 26: Death Roll Gameshow Enhancement (2026-01-19)

**Goal:** Transform Death Roll into an exciting gameshow experience with dramatic announcements, big number displays, and clear turn instructions.

**New Features:**
- ✅ **Big Number Display** (DeathRollUI.lua:557-591) - Large animated number reveals with danger-colored text
- ✅ **Danger Level System** (DeathRollUI.lua:25-52, 535-549) - 5 levels: SAFE, CAUTION, DANGER, CRITICAL, DEATH
  - Color-coded: Gold → Yellow → Orange → Red → Dark Red
  - Unique messages: "SAFE!" → "Getting risky..." → "DANGER ZONE!" → "ONE WRONG MOVE..." → "ELIMINATED!"
- ✅ **Turn Prompt Banner** (DeathRollUI.lua:599-636, 779-816) - Pulsing gold "YOUR TURN!" with `/roll` command hint
  - Uses `Effects:CreatePulsingGlow()` for attention
  - Shows "Waiting for [opponent]..." when not your turn
- ✅ **Animation Sequence** (DeathRollUI.lua:719-771) - Suspense → Reveal → Message → Turn Prompt flow
  - Shake effect on CRITICAL/DANGER rolls
  - Burst effect on DEATH rolls
  - 1.2s animation lock prevents double-rolls
- ✅ **Sound Effects** (Sounds.lua:72-82, 196-211) - New `deathroll` category with 8 sounds
  - suspense (gong), reveal, safe (tick), caution (bell), danger (error), critical, death, yourTurn
- ✅ **Frame Pooling Optimization** (DeathRollUI.lua:94-96, 117-216) - Memory-efficient UI
  - `bigNumberPool` and `turnPromptPool` using `HopeAddon.FramePool`
  - Frames acquired on game start, released on cleanup (not destroyed)
  - Pools destroyed on OnDisable, fallback to direct creation if pools unavailable

**Files Modified:**
- `Social/Games/DeathRoll/DeathRollUI.lua` - Added gameshow UI with frame pooling (~450 lines)
- `Social/Games/DeathRoll/DeathRollGame.lua` - Modified ProcessRoll/ShowUI for animations
- `Core/Sounds.lua` - Added deathroll sound category

**Key Functions:**
- `DeathRollUI:CreateFramePools()` - Initialize frame pools on enable
- `DeathRollUI:AcquireBigNumberFrame(parent)` - Get frame from pool
- `DeathRollUI:AcquireTurnPromptFrame(parent)` - Get frame from pool
- `DeathRollUI:GetDangerLevel(roll, max)` - Returns danger level string
- `DeathRollUI:ShowRollResult(gameId, roll, max, playerName, isLocalPlayer)` - Animated reveal
- `DeathRollUI:ShowTurnPrompt(gameId, maxRoll, isYourTurn, opponentName)` - Pulsing turn banner
- `DeathRollUI:InitializeGameshowFrames(gameId, contentFrame)` - Acquires frames from pools
- `DeathRollUI:CleanupGameshowFrames(gameId)` - Releases frames back to pools
- `DeathRollGame:ProcessRoll()` - Now triggers gameshow animations with 1.2s delay

## Phase 27: Minimap Button (2026-01-19)

**Goal:** Add standard minimap button for easy journal access.

**New Features:**
- ✅ **Draggable Minimap Button** (UI/MinimapButton.lua) - Click to toggle journal
  - Left-click: Toggle journal open/closed
  - Right-click: Show help message
  - Drag: Reposition around minimap edge
  - Position saved account-wide in `HopeAddonDB.minimapButton.position`
- ✅ **Standard WoW Appearance** - Book icon with tracking border ring
- ✅ **Tooltip** - Shows addon name, version, click instructions
- ✅ **Toggle Command** - `/hope minimap` to show/hide button

**Files Created:**
- `UI/MinimapButton.lua` - Complete minimap button module (~200 lines)

**Files Modified:**
- `HopeAddon.toc` - Added MinimapButton.lua to load order
- `Core/Core.lua` - Added minimapButton defaults and `/hope minimap` command

## Phase 28: Social Tab RP Redesign (2026-01-19)

**Goal:** Transform Social tab into comprehensive RP-style experience with profile section and badge-based titles.

**New Features:**
- ✅ **Your Profile Section** (Journal.lua:2867-3057) - Lit-up container with golden glow at top of Social tab
  - Player name with selected title displayed in badge color
  - Class icon and level display
  - Title dropdown (shows only unlocked titles from badges)
  - RP Status dropdown (IC / OOC / Looking for RP)
  - Edit Profile button → Opens ProfileEditor for backstory/personality
- ✅ **Fellow Traveler Titles** (Journal.lua:3211-3270) - Cards now show player's selected title in badge color
  - Format: "PlayerName |cFFcolor<Title>|r"
  - Title color comes from the badge that granted it
- ✅ **Badges Section in Stats Tab** (Journal.lua:3568-3661) - Dedicated badge display
  - Shows all badges with earned/unearned status
  - Earned badges: Full color icon with badge-color border
  - Unearned badges: Greyed out, desaturated icon
  - Displays unlock date, title reward, color reward for each
- ✅ **Badge Helper Functions** (Badges.lua:420-445)
  - `GetTitleColor(title)` - Returns hex color for a title
  - `FormatNameWithTitle(name, title)` - Formats name with colored title
- ✅ **Demo Mode Badges** (Core.lua:1452-1474) - `/hope demo` now unlocks sample badges for testing

**Files Modified:**
- `Journal/Journal.lua` - Added CreateMyProfileSection, PopulateBadgesSection, modified PopulateSocial, CreateDirectoryCard
- `Social/Badges.lua` - Added GetTitleColor, FormatNameWithTitle, fixed DISPLAY_ORDER
- `Core/Core.lua` - Updated PopulateDemoData and ClearDemoData for badge testing

**Badges with Titles:**
| Badge | Title | Color |
|-------|-------|-------|
| hero_of_outland | "Hero" | Gold (#FFD700) |
| prince_slayer | "Prince Slayer" | Epic Purple (#A335EE) |
| gruul_slayer | "Dragonkiller" | Earth Brown (#8B4513) |
| magtheridon_slayer | "Pit Lord's Bane" | Crimson (#DC143C) |
| vashj_slayer | "Champion" | Sea Green (#20B2AA) |
| kael_slayer | "Champion" | Phoenix Orange (#FF4500) |
| aldor_exalted | "of the Aldor" | Holy White (#FFFFFF) |
| scryer_exalted | "of the Scryers" | Arcane Blue (#6A5ACD) |
| epic_flying | "Swiftwind" | Royal Blue (#4169E1) |

## Phase 29: Words with WoW Save/Resume & Async Multiplayer (2026-01-19)

**Goal:** Enable Words with WoW games to persist across sessions and support async multiplayer (play vs offline opponents).

**New Files Created:**
- ✅ **WordGamePersistence.lua** (~400 lines) - Save/load game state for async multiplayer
- ✅ **WordGameInvites.lua** (~500 lines) - Multiplayer invite system

**Files Modified:**
- ✅ **WordGame.lua** - Added persistence hooks
- ✅ **Core.lua** - SavedVariables and slash commands
- ✅ **HopeAddon.toc** - Added new files to load order
- ✅ **Components.lua** - Added active games badge to CreateGameCard
- ✅ **Journal.lua** - Games tab integration

**Design Decisions:**
- Invite timeout: 24 hours
- Multiple simultaneous games: Yes (up to 10)
- Inactivity auto-forfeit: 30 days
- Board hash validation on resume to detect desync

## Phase 30: Words with WoW TBC Cartoon UI Overhaul (2026-01-19)

**Goal:** Transform the minimal text-based Words UI into a visually rich, cartoon TBC-themed Scrabble experience.

**Major Changes:**

**Phase A: Board Visual Core**
- ✅ Frame-based 15x15 tile grid replacing ASCII text board
- ✅ Parchment background texture (`QUESTFRAME\QuestBG`)
- ✅ Color-coded bonus squares (TBC themed)
- ✅ MORPHEUS font letters with point values

**Phase B: Player Panels & Status**
- ✅ Tile hand tracking with 7-tile rack display
- ✅ Player panels with portrait icons and active glow
- ✅ Turn banner with "YOUR TURN!" pulsing glow

**Phase C: Animations & Feedback**
- ✅ Recently placed tiles show gold glow (3 seconds)
- ✅ Floating score popup toasts (rise + fade animation)
- ✅ Sound effects tied to score thresholds (GOOD/GREAT/AMAZING)

**Phase D: Game End & Polish**
- ✅ Parchment results overlay with winner announcement
- ✅ Hover tooltips for bonus squares showing multiplier info
- ✅ Hover tooltips for placed tiles showing who played them

**Window Size:** Changed from 650x600 to 700x720 to accommodate tile rack

**Files Modified:**
- `Social/Games/WordsWithWoW/WordGame.lua` - Complete UI overhaul (~500 lines added)
- `Social/Games/GameUI.lua` - Updated WORDS window size
- `Core/Constants.lua` - Added WORDS_* constants (~60 lines)

## Phase 30: Practice Mode Selection (AI vs 2-Player Local) (2026-01-19)

**Goal:** When clicking Practice on Tetris or Pong, show a popup to choose between "Play vs AI" and "2-Player Local" modes.

**Files Modified:**
- ✅ **MinigamesUI.lua** - Added practice mode selection popup
- ✅ **Journal.lua** - Modified practice button flow
- ✅ **TetrisGame.lua** - Added AI opponent

**AI Design (60-70% player win rate):**
- 0.3-0.8 second thinking delay (visible hesitation)
- 15% chance to make suboptimal move (random column offset)
- No lookahead (evaluates current piece only)
- Simple evaluation (penalize holes, height, bumpiness; reward line clears)

**Practice Mode Status:**
| Game | "Play vs AI" | "2-Player Local" |
|------|-------------|------------------|
| Tetris | ✅ New AI opponent | ✅ Dual keyboard (WASD / Arrows) |
| Pong | ✅ Existing AI paddle | ✅ Dual keyboard (W/S / Up/Down) |
| Death Roll | N/A (single option) | vs Self (alternating) |
| Words | N/A (single option) | vs Self (alternating) |
| RPS | N/A (single option) | vs AI |
| Dice | N/A (single option) | vs Computer |

## Phase 31: Battleship Multiplayer & Game Chat System (2026-01-19)

**Goal:** Implement true turn-based multiplayer for Battleship with text-based commands and create a reusable in-game chat system for all games.

**New Files Created:**
- ✅ **GameChat.lua** (~120 lines) - Reusable chat module for all multiplayer games

**Slash Commands Added (Core.lua):**
| Command | Usage | Description |
|---------|-------|-------------|
| `/fire` | `/fire A5` | Fire at coordinate (letter + number) |
| `/ready` | `/ready` | Signal ships placed, ready to play |
| `/surrender` | `/surrender` | Forfeit the current game |
| `/gc` | `/gc Good luck!` | Send chat to opponent (all games) |

**Game Flow (Multiplayer):**
1. `/hope battleship PlayerName` → Sends invite
2. Both players place ships, type `/ready`
3. "Waiting for opponent..." until both ready
4. Challenger shoots first with `/fire A5`
5. Turns alternate with shot/result sync
6. First to sink all 5 ships wins

## Phase 32: Journey Tab Loot Hotlist (2026-01-19)

**Goal:** Initial implementation of class-specific "Loot Hotlist" showing Top 3 recommended items from reputation rewards.

**Note:** This phase was superseded by Phase 34 which added spec detection and multiple item categories.

## Phase 33: Battleship Gameshow UI Enhancement (2026-01-19)

**Goal:** Add gameshow-style visual effects to Battleship matching Death Roll's flashy UI pattern.

**New File Created:**
- **BattleshipUI.lua** (~380 lines) - Gameshow visual effects module

**Files Modified:**
- **Sounds.lua** - Added `battleship` sound category
- **BattleshipGame.lua** - Integrated BattleshipUI calls
- **HopeAddon.toc** - Added BattleshipUI.lua to load order

**Animation Sequence (1.4s):**
1. Sound plays (hit/miss/sunk)
2. "HIT!" text pops in with color
3. Coordinate "[B5]" fades in
4. If SUNK: ship name + burst effect
5. Elements fade out, turn prompt appears

## Phase 34: Spec-Aware Loot Hotlist Expansion (2026-01-19)

**Goal:** Transform the Journey tab's Loot Hotlist from class-only reputation items to a comprehensive, spec-aware system with three collapsible item source categories.

**New Features:**
- ✅ **Spec Detection** - Determines player's primary spec by checking talent point distribution
- ✅ **Three Item Categories** - Reputation Rewards, Dungeon Drops, Crafted Gear (3 items each = 9 total)
- ✅ **Collapsible Sections** - Each category in its own collapsible section
- ✅ **27 Spec Configurations** - All 9 TBC classes × 3 specs with role-appropriate items

**Design Decisions:**
- Feral Druid (Tab 2): Recommends Tank (Bear) gear since tanks have stricter requirements
- Uses `GetTalentTabInfo()` API for TBC Classic 2.4.3 compatibility
- Items are pre-Karazhan BiS focused (normal/heroic 5-mans, rep rewards, BoE crafted)

**Files Modified:**
| File | Changes |
|------|---------|
| Core/Core.lua | Added SPEC_ROLE_MAP, GetPlayerSpec(), GetSpecRole() (~80 lines) |
| Core/Constants.lua | Added CLASS_SPEC_LOOT_HOTLIST (~900 lines of item data) |
| Journal/Journal.lua | Rewrote CreateLootHotlist, CreateLootCard, added CreateLootCategorySection (~200 lines) |

## Phase 35: Fellow Traveler Discovery & Challenge System Fix (2026-01-19)

**Goal:** Fix the Challenge button flow - players standing nearby were not appearing in the Traveler Picker because the PING broadcast was not running continuously.

**Root Cause:** The `BROADCAST_INTERVAL = 15` constant existed but was ONLY used as a rate limiter. There was NO periodic ticker calling `BroadcastPresence()`. Broadcasts only happened on login (once), zone change, or party change.

**Bugs Fixed:**
1. **No Periodic PING Broadcast (CRITICAL)** - Added `broadcastTicker` that calls `BroadcastPresence()` every 15 seconds
2. **Traveler Picker Shows Stale Data** - Now filters by `lastSeenTime` (5-minute threshold)
3. **No Visual Recency Indicators** - Added [Active], [Recent], [Idle] status tags
4. **Silent Challenge Failures** - Improved error messages explaining why challenges fail
5. **YELL Throttling Risk** - YELL now only broadcasts every other cycle (30s) to reduce throttle risk

**Testing:**
1. Two characters in same zone should discover each other within 30 seconds
2. Traveler Picker should only show fellows seen in last 5 minutes
3. Challenge to undiscovered player shows helpful error
4. Challenge to stale (>5 min) player shows warning but still sends

## Phase 36: Combat UI Auto-Hide (2026-01-19)

**Goal:** Add best practice auto-hide of addon UI when entering combat.

**New Feature:**
- UI automatically hides when combat starts (`PLAYER_REGEN_DISABLED`)
- UI automatically restores when combat ends (`PLAYER_REGEN_ENABLED`)
- Games are paused during combat and resumed after
- Setting toggle: `/hope combathide` (enabled by default)
- Notifications show when UI hides/restores (respects `notificationsEnabled` setting)

**Files Modified:**
- `Core/Core.lua` (~110 lines added)

## Phase 36: Badge Categories & Boss Kill Tracker (2026-01-19)

**Goal:** Enhance the Stats tab badge display with categorized sections and add a comprehensive boss kill tracker showing all 44 TBC raid bosses.

**New Features:**

1. **Categorized Badge Display**
   - Badges now grouped into 5 collapsible categories
   - Each category shows earned/total count
   - All categories collapsed by default

2. **Boss Kill Tracker Section**
   - Shows all 44 TBC raid bosses organized by tier
   - Three collapsible tier sections (T4, T5, T6)
   - Each boss shows: icon, name, kill count, first kill date
   - **RPG Quality Colors based on kill count**
   - Shows progress to next tier
   - Card border and boss name colored by current tier
   - Unkilled bosses: grey border, desaturated icon

## Phase 37: Journey Tab Level-Based Dynamic Content (2026-01-19)

**Goal:** Transform the Journey tab to be level-aware with two distinct experiences based on player level.

**New Features:**

1. **Pre-68 Leveling Mode (Levels 60-67)**
   - Shows gear recommendations from dungeons and quests instead of attunements
   - Role-based items using spec detection
   - Three level ranges: 60-62, 63-65, 66-67
   - Recommended dungeons list for current level range

2. **68+ Endgame Mode (Level 68-70)**
   - Current attunement-focused progression with tier cards
   - Existing loot hotlist for spec-specific endgame gear

**Files Modified:**
| File | Changes |
|------|---------|
| Core/Constants.lua | Added LEVELING_RANGES, LEVELING_ROLES, LEVELING_DUNGEONS, LEVELING_GEAR_MATRIX (~280 lines) |
| Journal/Journal.lua | Added PopulateJourneyLeveling and 7 helper functions (~400 lines) |

## Phase 37: Party Fellow Challenge Button (2026-01-19)

**Goal:** Add prominent "CHALLENGE" button next to party members who have the addon in the Social tab.

**New Features:**
- "IN YOUR PARTY" section appears at top of Social tab when party has Fellow Travelers
- Each party Fellow shows with class icon, name with title, level, and prominent CHALLENGE button
- Clicking CHALLENGE opens the game selection popup to choose which game to play
- Section automatically hides when solo or no Fellows in party

**Files Modified:**
- `Journal/Journal.lua` (~170 lines added)

## Phase 38: Words with WoW AI Opponent & Multiplayer Enhancements (2026-01-19)

**Goal:** Complete the Words with WoW core gameplay loop with AI opponent for practice mode, online status indicators for remote games, and turn notifications.

**New Features:**

1. **AI Opponent for Practice Mode**
   - AI automatically plays when it's their turn (1-3 second thinking delay)
   - Easy difficulty (~70% player win rate): 20% mistake chance, prefers shorter words
   - Word-finding algorithm checks all dictionary words against hand letters
   - Falls back to passing if no valid moves found

2. **Online Status Indicator for Remote Games**
   - Shows opponent status in player panel: Active (green), Online (yellow), Away (yellow), Offline (gray)
   - Uses FellowTravelers `lastSeenTime` with configurable thresholds
   - Updates every 15 seconds via ticker

3. **Turn Notifications for Async Games**
   - Bell sound plays when remote opponent makes a move
   - Chat notification: "[Words] PlayerName played 'WORD' for X points!"
   - Turn banner flashes when it becomes your turn
   - Similar notifications for pass actions

**Files Modified:**
| File | Changes |
|------|---------|
| Core/Constants.lua | Added WORDS_AI_SETTINGS, WORDS_ONLINE_STATUS (~25 lines) |
| Social/Games/WordsWithWoW/WordGame.lua | AI logic, status UI, notifications (~350 lines) |

## Phase 39: In-World Fellow Traveler Visual Identity (2026-01-20)

**Goal:** Make Fellow Travelers visually distinct in the world with colored nameplates and minimap pins based on RP status.

**New Features:**

1. **Nameplate Coloring by RP Status**
   - IC (In Character) = Bright Green (#33FF33)
   - OOC (Out of Character) = Sky Blue (#00BFFF)
   - LF_RP (Looking for RP) = Hot Pink (#FF33CC)
   - Toggle: `/hope nameplates`

2. **Enhanced Minimap Pins**
   - Star icons instead of generic dots
   - Glowing effect for visibility
   - Colors match RP status (same as nameplates)
   - Toggle: `/hope pins`

3. **New Settings**
   - `fellowSettings.colorNameplates` (default: true)
   - `fellowSettings.colorMinimapPins` (default: true)

**New File Created:**
- `Social/NameplateColors.lua` (~200 lines) - TBC-compatible nameplate coloring module

## Phase 40: Move Game Stats from Stats Tab to Social Tab (2026-01-20)

**Goal:** Remove global game statistics from the Stats tab and display game history per-player in the Social tab instead.

**Changes:**

1. **Stats Tab Simplified**
   - Removed "Game Champion Statistics" section
   - Removed "Rivals & Nemeses" section
   - Stats tab now shows only: Badges + Boss Kill Tracker
   - Cleaner, more focused on achievements and progression

2. **Social Tab Enhanced**
   - Fellow Traveler cards now show game record inline
   - Record color-coded: green for winning, red for losing, gold for tied
   - Clicking a player card shows detailed per-game breakdown in chat

## Phase 41: Looking for RP Board (2026-01-20)

**Goal:** Add a dedicated "Looking for RP" board to the Social tab showing Fellows who are actively seeking roleplay.

**New Features:**

1. **LF_RP Board Section**
   - Pink-bordered container at top of Social tab
   - Shows Fellows with `LF_RP` status who were seen in last 24 hours
   - Displays: class icon, name with title, current zone, time ago
   - "Whisper" button opens chat to that player

2. **Visual Design**
   - Hot pink border and glow (#FF33CC) matching LF_RP nameplate color
   - Heart/perfume icon for RP theming
   - Up to 4 Fellows shown, "more..." indicator if truncated
   - Sorted by most recently seen

## Phase 42: Social Tab Scalability (Search, Filter, Sort, Pagination) (2026-01-20)

**Goal:** Add UI controls to handle 50+ Fellow Travelers with search, filter by RP status, sort options, and pagination.

**New Features:**

1. **Search Bar** - Full-text search by name, class, or zone
2. **Sort Dropdown** - Name, Class, Level, Last Seen options
3. **Filter Buttons** - All, Online, IC, OOC, LF_RP
4. **Pagination Controls** - 20 entries per page

## Phase 43: Activity Feed (Tavern Notice Board) (2026-01-20)

**Goal:** Implement the Activity Feed system ("Tavern Notice Board") to show recent activities from Fellow Travelers, creating a mini-Facebook style social experience for RP players.

**New Features:**

1. **Activity Feed Module** (`Social/ActivityFeed.lua`)
   - Shows recent activities from nearby Fellow Travelers
   - Auto-populates from existing events
   - Manual "Rumors" posting with 5-min cooldown
   - "Raise a Mug" reactions on activities
   - 48-hour retention with automatic cleanup
   - Network protocol: `ACT:version:type:player:class:data:time`

2. **Activity Types Tracked:** STATUS, BOSS, LEVEL, GAME, BADGE, RUMOR, MUG

3. **Social Tab UI Enhancement:** "OUTLAND CHRONICLES" section with activity cards

4. **Event Hooks:** Integrates with Badges, FellowTravelers, GameCore modules

**New Files:**
| File | Lines | Purpose |
|------|-------|---------|
| `Social/ActivityFeed.lua` | ~850 | Activity feed module with network protocol |

## Phase 44: Social Tab TBC Visual Enhancement (2026-01-21)

**Goal:** Add TBC/Black Temple themed visual enhancements to the Social tab with fel/demon themed icons, glowing borders, and corner decorations.

**New Features:**

1. **Activity Feed "Outland Chronicles" Theme**
   - New `Spell_Fire_FelFire` header icon
   - Dual-border glow effect: inner arcane purple + outer fel green
   - Corner rune decorations
   - Renamed header to "OUTLAND CHRONICLES"

2. **Section Icon Updates** for all social sections

3. **New Helper Functions**
   - `Components:CreateCornerRunes()`
   - `Components:CreateSectionHeaderWithIcon()`
   - `Effects:CreateDualBorderGlow()`

## Phase 45: Romance System - "Azeroth Relationship Status" (2026-01-21)

**Goal:** Add a Facebook-style dating system with one exclusive partner, public relationship status visible to Fellow Travelers, and breakup events on the activity timeline.

**New Features:**

1. **Relationship Status System** - States: SINGLE, PROPOSED, DATING
2. **Proposal/Accept/Decline Flow** - 24-hour cooldown, 7-day expiry
3. **Breakup System** - Confirmation dialog, four humorous reasons
4. **UI Integration** - Heart buttons, status sections, colored indicators

**New Files:**
| File | Lines | Purpose |
|------|-------|---------|
| `Social/Romance.lua` | ~450 | Romance module with network handlers for proposal flow |

**Slash Commands:**
| Command | Description |
|---------|-------------|
| `/hope propose <player>` | Propose to a Fellow Traveler |
| `/hope breakup` | End your current relationship (with confirmation) |
| `/hope relationship` | Show your relationship status |

## Phase 46: Rumor Popup UI Fix (2026-01-21)

**Goal:** Fix the broken "Post Rumor" button in Social tab and enhance with a two-mode popup for posting rumors and updating RP status.

**New Features:**

1. **Two-Mode Rumor Popup** - Modal dialog with "Post Rumor" and "Update Status" tabs
2. **Rumor Mode Content** - Multi-line input, character counter, cooldown indicator
3. **Status Mode Content** - Three status buttons with colored dots

**Bug Fix:** Rumors not appearing in feed - added `broadcastTicker` and immediate broadcast call

**New Feature:** Companion Online Toast Notification - shows toast when companion comes online

## Phase 46: Words with WoW Hint System (2026-01-21)

**Goal:** Make Words with WoW easy to play by adding a progressive hint system that guides players through the core game loop (Place → Form → Play).

**New Features:**

1. **3-Step Progress Indicator** - Visual indicator showing current step
2. **Contextual Hint Messages** - Dynamic hints based on game state
3. **Center Square Pulse** - Gold pulsing glow for first word
4. **PLAY Button Pulse** - Green pulsing glow when word is valid

## Phase 47: Victory Overlay Pulsing Glow (2026-01-21)

**Goal:** Add persistent pulsing green glow to victory overlays in all games.

**Changes:**
- Added `Effects:CreatePulsingGlow()` to victory condition in 3 locations:
  1. `GameUI:ShowGameOver()` - Generic game over
  2. `WordGame:ShowGameOverScreen()` - Words with WoW custom overlay
  3. `BattleshipUI:ShowVictoryOverlay()` - Battleship victory screen
- Glow persists until Close button is clicked
- Added cleanup via `Effects:StopGlowsOnParent()`

## Phase 48: Death Roll Clickable Roll Button (2026-01-21)

**Goal:** Add clickable "ROLL" button to Death Roll turn prompt for better UX.

**Changes Made:**
- Turn prompt frame height increased from 50 to 70 pixels
- Added green "ROLL 1-X" button with gold border
- Button calls `RandomRoll(1, maxRoll)` on click
- Hover effects, button hidden when waiting for opponent's turn

**All turn-based games now have clickable UI** - no slash commands required!

## Phase 49: Activity Feed Real-Time Updates (2026-01-21)

**Goal:** Transform Activity Feed into a real-time, dynamic social experience with proper refresh mechanics.

**Architecture Implemented:**
1. **Listener System** - `ActivityFeed:RegisterListener(id, callback)` pattern
2. **Hybrid Refresh** - Auto-refresh when scrolled to top, banner when scrolled down
3. **Unread Badge** - Feed tab shows count of unseen activities

**Feed Refresh Behavior:**
- **At top of feed:** Auto-refresh silently when new activities arrive
- **Scrolled down:** Green banner appears: "↑ 2 new activities - Click to refresh"
- **Not viewing feed:** Unread count badge on Feed tab
- **Refresh interval:** 30 seconds

## Phase 51: ActivityFeed Network Fix + First Friends Icon Fix (2026-01-23)

**Goal:** Fix two social system bugs - Activity Feed network parsing and First Friends icon awarding to non-addon users.

**Bug 1: ActivityFeed Network Parsing (CRITICAL)**
- Fixed message parsing in `HandleNetworkActivity`

**Bug 2: First Friends Icon Awarded to Non-Addon Users**
- Added `IsFellow(name)` check before awarding the icon

## Phase 52: Social Tab Romance UX Improvements (2026-01-23)

**Goal:** Clean up confusing text in Companions tab and add heart icons directly to Traveler rows for proposing romance.

**Issues Fixed:**

1. **Confusing Hint Text** - Changed to clearer wording
2. **Heart Icons on Traveler Rows** - Five visual states for romance status
3. **Orphaned Code Removed** - Deleted unused functions (~184 lines)

## Phase 53: SafeSendAddonMessage pcall Protection (2026-01-23)

**Goal:** Fix "You are not in a raid group" error spam by wrapping SendAddonMessage calls in pcall.

**Fix Applied:** Wrapped all `SendAddonMessage` calls in `pcall` to silently handle edge cases

**Files Modified:**
| File | Changes |
|------|---------|
| `Social/FellowTravelers.lua` | Lines 71-79: Added pcall wrapper with debug logging |
| `Social/Games/GameComms.lua` | Lines 528-533: Added pcall wrapper with debug logging |

## Phase 54: Remove Immediate Party PING and Dead Code Cleanup (2026-01-24)

**Goal:** Fix "You are not in a raid group" error that occurred when joining battlegrounds/raids by removing the immediate PING on party roster change.

**Removed Features:**
1. Immediate party PING
2. `first_friends` icon
3. `OnGroupFormed()` function
4. `CheckGroupCountIcons()` function
5. `frequent_allies` icon
6. `trusted_companions` icon
7. Dead toast types
8. Added missing `loot_shared` toast

## Phase 55: INSTANCE_CHAT for Battlegrounds (2026-01-24)

**Goal:** Fix "You are not in a raid group" error spam in battlegrounds by using `INSTANCE_CHAT` channel instead of `RAID`/`PARTY` when inside instances.

**Solution:** Use `IsInInstance()` to detect battleground/arena/dungeon, then use `INSTANCE_CHAT` channel

**Channel Selection Logic:**
```
IsInInstanceGroup() = true  → INSTANCE_CHAT
IsInRealRaid() = true       → RAID
IsInRealParty() = true      → PARTY
IsInGuild() = true          → GUILD
Not in instance/raid        → YELL
```

## Phase 57: Transmog Tab Removal (2026-01-25)

**Goal:** Remove the redundant Transmog tab entirely to simplify the addon.

**Changes Made:**
| File | Lines Removed | Description |
|------|---------------|-------------|
| `Journal/Journal.lua` | ~1,105 | Removed tab registration, routing, state tables, 18 functions |
| `Core/Core.lua` | ~20 | Removed charDb.transmog defaults and migration code |
| `Core/Constants.lua` | ~750 | Removed TIER_SETS, LIGHTING_PRESETS, TRANSMOG_UI, helper functions |

**Migration:** Users with `lastTab = "transmog"` are automatically redirected to "armory" tab.

**Net Result:** ~2,000 lines of code removed, cleaner codebase focused on core functionality.

## Phase 58: Armory Tab Phase-Based Restructure (2026-01-25)

**Goal:** Convert Armory tab from Tier-based (T4/T5/T6) to Phase-based (Phase 1-5) system following Wowhead TBC Classic phase guides.

**Key Changes:**
| File | Change |
|------|--------|
| `Core/Constants.lua` | Renamed `ARMORY_TIERS` → `ARMORY_PHASES` with updated metadata |
| `Core/Constants.lua` | Changed `ARMORY_GEAR_DATABASE` keys from `[4]`, `[5]`, `[6]` to `[1]`, `[2]`, `[3]`, `[5]` |
| `Core/Constants.lua` | Added `C:GetArmoryPhase()` and `C:HasArmoryPhaseData()` helper functions |
| `Journal/Journal.lua` | Removed `tier = phase + 3` conversion hack in `GetArmoryGearData()` |
| `Journal/Journal.lua` | Modified `CreateArmoryPhaseButtons()` to skip Phase 4 (ZA catch-up raid) |
| `Journal/Journal.lua` | Enhanced "No Data" message to show which phases have data |

**Phase Mapping:**
- Phase 1: Karazhan, Gruul, Magtheridon, Heroics, Badge Gear, Rep (DATA POPULATED)
- Phase 2: SSC, TK (placeholder)
- Phase 3: Hyjal, BT (placeholder)
- Phase 4: ZA (skipped - catch-up raid, button hidden)
- Phase 5: Sunwell (placeholder)

**Documentation Cleanup:** Removed 8 outdated Armory planning files.

## Phase 59: Armory Enhanced Hover Tooltip System (2026-01-25)

**Goal:** Implement rich hover tooltips for the Armory tab, matching the Attunements tab pattern with color-coded sections for drop info, stat priority, tips, and alternatives.

**New Features:**

1. **Phase Button Tooltips** - Enhanced tooltips showing raids, gear sources, and recommended iLvl for each phase
2. **Equipment Slot Tooltips** - Show equipped item + BiS preview with upgrade indicator (+X iLvl)
3. **Popup Item Row Tooltips** - Full enhanced tooltips with drop information, tips, alternatives, and prerequisites

**New Functions (Journal.lua):**
| Function | Purpose |
|----------|---------|
| `BuildArmoryGearTooltip(itemData, anchorFrame)` | Build enhanced tooltip with color-coded sections |
| `BuildBasicHoverData(itemData)` | Generate hover data from existing item fields (fallback) |

**Tooltip Color Scheme (TBC Theme):**
| Section | Color | RGB |
|---------|-------|-----|
| Title/Name | Gold | (1, 0.84, 0) |
| Drop Info | Gold | (1, 0.84, 0) |
| Raids | Fel Green | (0.2, 0.8, 0.2) |
| Stat Priority | Arcane Purple | (0.61, 0.19, 1.0) |
| Tips | Orange | (1, 0.5, 0) |
| Gear Sources | Sky Blue | (0.3, 0.7, 1.0) |
| Alternatives | Sky Blue | (0.3, 0.7, 1.0) |
| Prerequisites | Hellfire Red | (0.9, 0.2, 0.1) |

## Phase 60: Armory Popup Z-Order Fix (2026-01-25)

**Goal:** Fix Armory gear popup being visually obscured by the characterView backdrop despite having higher frame strata.

**Root Cause:** The gear popup was parented to `characterView` which has a `BackdropTemplate` with 95% opacity. Even though the popup was set to `DIALOG` strata (higher than `MEDIUM`), the WoW rendering engine draws child frames within their parent's visual context, causing the dark backdrop to visually obscure the popup content.

**Fix Applied:**
1. Re-parented popup from `characterView` to `mainFrame` (Journal's main window)
2. Added explicit `SetFrameLevel(100)` to ensure popup is above other DIALOG frames
3. Anchor positioning to slot buttons still works since anchors are independent of parent hierarchy

**Files Modified:**
| File | Changes |
|------|---------|
| `Journal/Journal.lua` | Changed popup parent from characterView to mainFrame, added SetFrameLevel(100) |
| `UI_ORGANIZATION_GUIDE.md` | Added Section 1.10: Frame Strata & Z-Ordering Standards with full documentation |

**Key Insight:** In WoW, frame strata determines render order between frames, but a parent's backdrop can still visually obscure children if the backdrop is drawn after children. The solution is to parent popups to a frame that doesn't have an opaque backdrop, while still using anchors to position relative to the original content.

## Previous Session Fixes

- ✅ **Card Pool Frame Type** (Journal.lua:149) - Changed `"Frame"` to `"Button"` to support OnClick scripts
- ✅ **Reputation Card Border Hover** (Journal.lua:1119) - Store standing color in `defaultBorderColor` so border returns to correct color after hover instead of grey
- ✅ **Section Header Components** (Components.lua:1809, Journal.lua:619) - Moved CreateSectionHeader and CreateCategoryHeader to Components.lua for reusability; Journal now delegates to Components
- ✅ **Spacer Component** (Components.lua:1867) - Added CreateSpacer helper to Components.lua for consistent vertical spacing
- ✅ **RaidData OnInitialize** (RaidData.lua:486) - Added missing OnInitialize stub for module pattern consistency
