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
