# Words with WoW - Test Suite

Comprehensive testing for the HopeAddon Words with WoW game system.

## Quick Start

### Loading Tests

**Option 1: Load on Demand (Recommended)**
```lua
/run LoadAddOn("HopeAddon_Tests")
/wordtest all
```

**Option 2: Always Load**
Add this line to `HopeAddon.toc`:
```
Tests\WordGameTests.lua
```

### Running Tests

```
/wordtest all       - Run all tests (comprehensive)
/wordtest dict      - Test dictionary validation
/wordtest board     - Test board placement rules
/wordtest score     - Test scoring mechanics
/wordtest cross     - Test cross-word detection
/wordtest flow      - Test game state management
/wordtest help      - Show command help
```

---

## Test Coverage

### 1. Dictionary Tests (`/wordtest dict`)

Tests `WordDictionary.lua` functionality:

| Test | Description |
|------|-------------|
| Valid words | DRAGON, WARRIOR, ILLIDAN, PALADIN, HORDE |
| Invalid words | ZZZQQQ, NOTAWORD, ASDFGH |
| Case insensitivity | dragon = DRAGON = DrAgOn |
| Letter values | Q=10, E=1, Z=10, A=1, K=5 |
| Word scoring | DRAGON = 8 points (D2+R1+A1+G2+O1+N1) |
| Tile bag size | 98 tiles total |
| Tile distribution | 12 E's, 9 A's (Scrabble standard) |
| Edge cases | Empty string, nil, single letter |
| Word count | 400+ WoW-themed words |

**Expected:** All tests pass, ~400+ valid words in dictionary

---

### 2. Board Placement Tests (`/wordtest board`)

Tests `WordBoard.lua` placement validation:

| Test | Description |
|------|-------------|
| Empty board | Board starts with no tiles |
| Center rule | First word must cover (8,8) |
| Off-center rejection | First word at (1,1) rejected |
| Out of bounds H | Long word extending past column 15 |
| Out of bounds V | Long word extending past row 15 |
| First word placement | DRAGON at center creates 6 tiles |
| Tile verification | Letters at expected positions |
| Disconnected rejection | FIRE at (1,1) after DRAGON at (8,8) |
| Connected acceptance | DRUID vertical through D of DRAGON |
| Conflicting letter | Cannot place SWORD over DRAGON |
| No new tiles | Cannot place word using only existing letters |

**Expected:** All placement rules enforced correctly

---

### 3. Scoring Tests (`/wordtest score`)

Tests `WordBoard.lua` scoring calculations:

| Test | Description | Expected Score |
|------|-------------|----------------|
| Center square bonus | DRAGON at (8,8) | 16 (8 × 2) |
| Triple word bonus | FIRE at (1,1) | 21 (7 × 3) |
| Subsequent placement | ARC after FIRE | > 0 points |
| Base word value | WARRIOR (no bonuses) | 10 points |

**Key Rules:**
- Center square (8,8) is Double Word (DW)
- Corner squares (1,1), (1,15), (15,1), (15,15) are Triple Word (TW)
- Letter bonuses (DL, TL) apply before word bonuses (DW, TW)
- Only new tiles trigger bonus squares

**Expected:** All bonus multipliers calculate correctly

---

### 4. Cross-Word Tests (`/wordtest cross`)

Tests `WordBoard.lua` cross-word detection:

| Test | Description |
|------|-------------|
| Simple cross-word | ARC vertical through R in FIRE horizontal |
| Word validation | All formed words checked against dictionary |
| Invalid cross-word | Placement rejected if forms invalid word |
| Multiple intersections | RAGE through DRAGON |
| GetHorizontalWord | Retrieves correct horizontal word at position |
| GetVerticalWord | Retrieves correct vertical word at position |

**Expected:** All formed words detected and validated

---

### 5. Game Flow Tests (`/wordtest flow`)

Tests `WordGame.lua` state management:

| Test | Description |
|------|-------------|
| Game creation | StartGame() returns valid game ID |
| Initial state | Game starts with PLAYER1_TURN |
| First word placement | DRAGON placed successfully |
| Turn switching | State changes to PLAYER2_TURN |
| Score tracking | Player 1 score increases |
| Turn validation | Player 1 cannot move on Player 2's turn |
| Pass turn | Player 2 passes, consecutivePasses = 1 |
| Double pass | Player 1 passes, game state = FINISHED |

**Expected:** Complete game lifecycle works correctly

---

### 6. Network Sync Tests (Manual Only)

**Cannot be automated** - requires 2 WoW clients with addon installed.

#### Manual Test Procedure

**Setup:**
1. Load addon on 2 clients (same server, same zone)
2. Both players: `/hope debug`

**Test Steps:**

| Step | Player A | Player B | Verify |
|------|----------|----------|--------|
| 1 | `/hope words PlayerB` | - | B receives invite |
| 2 | - | `/hope accept` | Both see game start |
| 3 | `/word DRAGON H 8 8` | - | B sees DRAGON on board |
| 4 | - | Verify board | DRAGON appears |
| 5 | - | `/word DRUID V 8 8` | A sees DRUID on board |
| 6 | Verify board | - | DRUID appears |
| 7 | Check score | Check score | Scores match |
| 8 | `/pass` | - | Both see pass notification |
| 9 | - | `/pass` | Game ends for both |
| 10 | View results | View results | Winner shown correctly |

**Expected:**
- Invites deliver instantly
- Word placements sync in real-time
- Scores match on both clients
- Turn indicators update correctly
- Game over screen shows consistent winner

---

## Test Results Interpretation

### Success Criteria

✅ **Pass:** All automated tests show 100% pass rate
- Dictionary: All valid/invalid word tests pass
- Board: All placement rules enforced
- Scoring: All bonus calculations correct
- Cross-words: All formed words validated
- Game Flow: Complete game cycle works

### Common Issues

❌ **Failures:**

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| Dictionary word not found | Word missing from WordDictionary.lua | Add word to WORDS table |
| Board placement allowed when invalid | CanPlaceWord logic bug | Check connectivity/bounds validation |
| Incorrect score | Bonus square calculation error | Verify CalculateWordScore logic |
| Cross-word not detected | FindFormedWords missing words | Check horizontal/vertical word detection |
| Game state stuck | Turn switching bug | Verify SwitchTurn logic |

---

## Development Workflow

### Adding New Tests

1. **Add test function to appropriate suite:**
```lua
function Tests:Dictionary()
    -- Add new test here
    Assert(dict:IsValidWord("NEWWORD"), "Test description")
end
```

2. **Run specific suite:**
```
/wordtest dict
```

3. **Verify pass/fail output**

4. **Run full suite:**
```
/wordtest all
```

### Debugging Failed Tests

1. **Enable debug mode:**
```
/hope debug
```

2. **Run failing test:**
```
/wordtest board
```

3. **Check debug output for details**

4. **Fix implementation**

5. **Re-run test**

---

## Test File Structure

```
HopeAddon/Tests/
└── WordGameTests.lua (500+ lines)
    ├── Utility Functions
    │   ├── Assert(condition, testName)
    │   ├── AssertEquals(actual, expected, testName)
    │   ├── ResetCounters()
    │   └── PrintSummary(suiteName)
    ├── Test Suites
    │   ├── Tests:Dictionary()
    │   ├── Tests:BoardPlacement()
    │   ├── Tests:Scoring()
    │   ├── Tests:CrossWords()
    │   ├── Tests:GameFlow()
    │   └── Tests:All()
    └── Slash Command Handler
        └── /wordtest [suite]
```

---

## Integration with CI/CD

### Future: Automated Testing

Currently manual testing only. Future improvements:

1. **Headless WoW Testing:**
   - Use wow.export or similar tools
   - Run tests on commit

2. **Test Coverage:**
   - Track lines executed
   - Report untested code paths

3. **Performance Tests:**
   - Memory leak detection
   - Frame time profiling
   - Large game simulation

4. **Regression Tests:**
   - Save test results
   - Compare against previous runs
   - Alert on failures

---

## Maintenance

### When to Update Tests

| Event | Action |
|-------|--------|
| New word added to dictionary | Add to Valid Words test |
| Board rule changed | Update Board Placement tests |
| Scoring formula changed | Update Scoring tests |
| New game state | Add to Game Flow tests |
| Bug discovered | Add regression test |

### Test Philosophy

- **Comprehensive:** Cover all code paths
- **Maintainable:** Clear test names and assertions
- **Fast:** All automated tests run in < 5 seconds
- **Deterministic:** Same input always produces same output
- **Isolated:** Each test independent of others

---

## Known Limitations

1. **No Remote Testing:** Network sync requires 2 clients
2. **No UI Testing:** Text board rendering not validated
3. **No Performance Testing:** No profiling or benchmarks
4. **No Memory Testing:** Cannot detect memory leaks
5. **No Visual Testing:** Cannot verify board appearance

---

## Contributing

When adding new features to Words with WoW:

1. ✅ Write tests first (TDD approach)
2. ✅ Ensure all existing tests still pass
3. ✅ Add tests for new functionality
4. ✅ Update this README with new test descriptions
5. ✅ Run `/wordtest all` before committing

---

## Troubleshooting

### Tests Won't Load

**Problem:** `/wordtest` command not found

**Solutions:**
1. Load test addon: `/run LoadAddOn("HopeAddon_Tests")`
2. Verify `HopeAddon_Tests.toc` exists in AddOns folder
3. Check Dependencies: HopeAddon must load first
4. Reload UI: `/reload`

### Tests Fail Immediately

**Problem:** All tests show FAIL

**Solutions:**
1. Ensure HopeAddon main addon is loaded
2. Check WordGame module loaded: `/dump HopeAddon:GetModule("WordGame")`
3. Verify WordDictionary exists: `/dump HopeAddon.WordDictionary`
4. Enable debug: `/hope debug`
5. Run individual suite to isolate issue

### Game Flow Tests Fail

**Problem:** GameCore or WordGame nil

**Solutions:**
1. Verify modules registered in Core.lua
2. Check OnInitialize called for all modules
3. Ensure SavedVariables loaded before tests run
4. Try running tests after entering world (not at login screen)

---

## Support

For issues or questions:

1. Check CLAUDE.md for feature status
2. Enable debug mode: `/hope debug`
3. Run specific test suite to isolate problem
4. Review implementation files:
   - WordGame.lua (game logic)
   - WordBoard.lua (board mechanics)
   - WordDictionary.lua (word validation)

---

## Version History

**v1.0.0** (2026-01-19)
- Initial test suite release
- 5 automated test suites
- 50+ individual test cases
- Manual network sync test procedure
- Comprehensive documentation

---

## License

Part of HopeAddon - TBC (2.4.3) addon for World of Warcraft.
