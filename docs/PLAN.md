# Wordle Hint System - Implementation Plan

## UI Constants Reference

### From Constants.lua (lines 3957-3987)
```lua
-- Window
WINDOW_WIDTH = 420
WINDOW_HEIGHT = 680

-- Letter Grid
BOX_SIZE = 56
BOX_GAP = 8
GRID_TOP = -60

-- Keyboard
KEY_WIDTH = 36
KEY_HEIGHT = 52
KEY_GAP = 6
KEYBOARD_TOP = -460

-- Misc
TOAST_TOP = -60
STATUS_BOTTOM = 15
TOAST_PADDING = 12
LETTER_FONT_SIZE = 28
KEY_FONT_SIZE = 14
TOAST_FONT_SIZE = 14
```

### From Components.lua (lines 100-108)
```lua
MARGIN_SMALL = 5
MARGIN_NORMAL = 10
MARGIN_LARGE = 20
SECTION_SPACER = 15
PADDING_INTERNAL = 4
INPUT_PADDING = 8
```

### Standard WoW UI Elements
| Element | Size | Notes |
|---------|------|-------|
| `UIPanelCloseButton` | 32×32 | Standard close button |
| `UIPanelButtonTemplate` | Variable | Standard button template |
| `GameFontNormalLarge` | ~16pt | Title font |
| `GameFontNormal` | ~12pt | Body font |
| `GameFontNormalSmall` | ~10pt | Small text |

---

## Current UI Element Inventory

### Header Section (lines 151-175)
| Element | Type | Anchor | Position | Size | Content |
|---------|------|--------|----------|------|---------|
| `title` | FontString | TOP of frame | (0, -12) | Auto | "WoW Wordle" (colored) |
| `closeBtn` | Button | TOPRIGHT of frame | (-2, -2) | 32×32 | UIPanelCloseButton |
| `subtitle` | FontString | BOTTOM of title | (0, -2) | Auto | "Guess the 5-letter WoW word!" |
| `headerLine` | Texture | BOTTOM of subtitle | (0, -8) | 380×1 | Gray separator line |

### Grid Section (lines 204-224)
| Element | Calculation | Result |
|---------|-------------|--------|
| Grid width | 5×56 + 4×8 | 312px |
| Grid startX | (420-312)/2 | 54px from left |
| Row 1 Y | GRID_TOP | -60 |
| Row spacing | BOX_SIZE + BOX_GAP | 64px |
| Grid height | 6×56 + 5×8 | 376px |
| Grid bottom Y | -60 - 376 | -436 |

### Keyboard Section (lines 328-389)
| Row | Keys | Y Position |
|-----|------|------------|
| Row 1 | Q W E R T Y U I O P (10) | -460 |
| Row 2 | A S D F G H J K L (9) | -518 |
| Row 3 | ENT Z X C V B N M < (9) | -576 |

| Element | Calculation | Result |
|---------|-------------|--------|
| Key height | KEY_HEIGHT | 52px |
| Key gap | KEY_GAP | 6px |
| Row spacing | 52 + 6 | 58px |
| Keyboard bottom | -576 - 52 | -628 |
| ENT/BACK width | KEY_WIDTH × 1.5 | 54px |
| Letter key width | KEY_WIDTH | 36px |

### Toast (lines 700-761)
| Property | Value | Notes |
|----------|-------|-------|
| Size | 200×44 (dynamic width) | Resizes to fit text |
| Position | TOP (0, -60) | Same Y as grid start |
| Frame level | parent + 50 | Floats above grid |
| Duration | 2.0 seconds | Then fades out |

### Status Text (lines 184-187)
| Property | Value |
|----------|-------|
| Position | BOTTOM (0, +15) |
| Font | GameFontNormal |
| Content | "Attempts: X/6" or win/loss message |

---

## Precise Y-Position Map

```
Y = 0     ┌─────────────────────────────────────────────────────────┐
          │                                                         │
Y = -2    │                                              [X]        │ ← closeBtn TOPRIGHT (-2, -2)
          │                                                         │
Y = -12   │                    WoW Wordle                           │ ← title TOP (0, -12)
          │                                                         │
Y = -28   │           Guess the 5-letter WoW word!                  │ ← subtitle (title.BOTTOM -2)
          │                                                         │
Y = -45   │ ───────────────────────────────────────────────────     │ ← headerLine (subtitle.BOTTOM -8)
          │                                                         │
          │           [TOAST OVERLAYS HERE WHEN SHOWN]              │ ← toast TOP (0, -60)
          │                                                         │
Y = -60   │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 1 boxes
          │         │  56  │  8   │  56  │  8   │  56  │           │
Y = -116  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
Y = -124  │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 2
Y = -180  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
Y = -188  │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 3
Y = -244  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
Y = -252  │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 4
Y = -308  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
Y = -316  │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 5
Y = -372  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
Y = -380  │         ┌──────┬──────┬──────┬──────┬──────┐           │ ← Row 6
Y = -436  │         └──────┴──────┴──────┴──────┴──────┘           │
          │                                                         │
          │                  24px gap                                │
          │                                                         │
Y = -460  │     [Q][W][E][R][T][Y][U][I][O][P]                     │ ← Keyboard Row 1
Y = -512  │                                                         │
          │                                                         │
Y = -518  │      [A][S][D][F][G][H][J][K][L]                       │ ← Keyboard Row 2
Y = -570  │                                                         │
          │                                                         │
Y = -576  │     [ENT][Z][X][C][V][B][N][M][<]                      │ ← Keyboard Row 3
Y = -628  │                                                         │
          │                                                         │
          │                  37px gap                                │
          │                                                         │
Y = -665  │                Attempts: 0/6                            │ ← statusText BOTTOM (0, +15)
          │                                                         │
Y = -680  └─────────────────────────────────────────────────────────┘
```

---

## Gap Analysis

| Gap | From | To | Pixels | Usable? |
|-----|------|----|--------|---------|
| Title → Subtitle | -12 (title) | -28 (subtitle) | 16px | No (text) |
| Subtitle → Line | -28 | -45 | 17px | No (text) |
| Line → Grid | -45 | -60 | **15px** | Too small for button |
| Grid → Keyboard | -436 | -460 | **24px** | Too small |
| Keyboard → Status | -628 | -665 | **37px** | Possible but crowded |

---

## Hint Button Placement Analysis

### Option 1: Next to Close Button (Recommended)
```
┌────────────────────────────────────────────────────────┐
│                                      [Hint]    [X]     │
│                                      ↑         ↑       │
│                                   (-40, -7)  (-2, -2)  │
```

**Calculation:**
- Close button: 32×32 at TOPRIGHT (-2, -2)
- Close button left edge: X = -34
- Hint button: 50×22
- Hint button right edge: -34 - 6 (gap) = -40
- Hint button position: TOPRIGHT (-40, -7) centers vertically with close

### Option 2: Below Subtitle (Not Recommended)
Only 15px between line and grid - not enough space.

### Option 3: In Status Area
Clutters the status text area.

---

## Hint Text Display Options

### Option A: Replace Subtitle (Recommended)
- Hide subtitle, show hint text in same position
- No layout changes required
- Gold color differentiates from default subtitle

### Option B: Persistent Toast
- Modify toast to not auto-hide when showing hint
- Requires toast system changes

### Option C: Dedicated Hint Line
- Would require shifting grid down ~20px
- Affects all spacing calculations
- Not recommended

---

## Final Implementation Plan

### File: WordleWords.lua

**Location:** After line 97 (after VALID_WORDS table)

```lua
--============================================================
-- WORD CATEGORIES FOR HINT SYSTEM
--============================================================

WordleWords.CATEGORIES = {
    -- CLASS (3)
    ROGUE = "CLASS", DRUID = "CLASS", MAGES = "CLASS",

    -- RACE (8)
    GNOME = "RACE", DWARF = "RACE", TROLL = "RACE", BLOOD = "RACE",
    NIGHT = "RACE", ELVES = "RACE", HUMAN = "RACE", TAURE = "RACE",

    -- CREATURE (35)
    DEMON = "CREATURE", GHOUL = "CREATURE", DRAKE = "CREATURE",
    WHELP = "CREATURE", BEAST = "CREATURE", GNOLL = "CREATURE",
    SPAWN = "CREATURE", WYRMS = "CREATURE", NAGA = "CREATURE",
    SATYR = "CREATURE", WORGS = "CREATURE", CROWS = "CREATURE",
    GIANT = "CREATURE", GOLEM = "CREATURE", HYDRA = "CREATURE",
    HOUND = "CREATURE", VIPER = "CREATURE", COBRA = "CREATURE",
    CRABS = "CREATURE", TIGER = "CREATURE", LIONS = "CREATURE",
    BEARS = "CREATURE", BOARS = "CREATURE", HAWKS = "CREATURE",
    RAVEN = "CREATURE", SHARK = "CREATURE", SQUID = "CREATURE",
    WHALE = "CREATURE", CROCS = "CREATURE", GATOR = "CREATURE",
    SPORE = "CREATURE", SLIME = "CREATURE", SHADE = "CREATURE",
    IMPS = "CREATURE", BATS = "CREATURE", OWLS = "CREATURE",

    -- EQUIPMENT (27)
    ARMOR = "EQUIPMENT", SWORD = "EQUIPMENT", STAFF = "EQUIPMENT",
    WANDS = "EQUIPMENT", CAPES = "EQUIPMENT", CLOAK = "EQUIPMENT",
    RINGS = "EQUIPMENT", CLOTH = "EQUIPMENT", PLATE = "EQUIPMENT",
    CHAIN = "EQUIPMENT", ROBES = "EQUIPMENT", HELMS = "EQUIPMENT",
    BOOTS = "EQUIPMENT", GLOVE = "EQUIPMENT", BELTS = "EQUIPMENT",
    CHEST = "EQUIPMENT", PANTS = "EQUIPMENT", HEADS = "EQUIPMENT",
    BACKS = "EQUIPMENT", NECKS = "EQUIPMENT", MACES = "EQUIPMENT",
    POUCH = "EQUIPMENT", FLASK = "EQUIPMENT", TORCH = "EQUIPMENT",
    TOOLS = "EQUIPMENT", PICKS = "EQUIPMENT", BOMBS = "EQUIPMENT",
    WAND = "EQUIPMENT",

    -- CONSUMABLE (3)
    FOODS = "CONSUMABLE", DRINK = "CONSUMABLE", ELIXS = "CONSUMABLE",

    -- SOCIAL (12)
    GUILD = "SOCIAL", PARTY = "SOCIAL", GROUP = "SOCIAL",
    RAIDS = "SOCIAL", REALM = "SOCIAL", SHARD = "SOCIAL",
    WORLD = "SOCIAL", HORDE = "SOCIAL", ALLIS = "SOCIAL",
    TEAMS = "SOCIAL", SQUAD = "SOCIAL", CLANS = "SOCIAL",

    -- GAMEPLAY (48)
    AGGRO = "GAMEPLAY", WIPES = "GAMEPLAY", PULLS = "GAMEPLAY",
    HEALS = "GAMEPLAY", TANKS = "GAMEPLAY", CASTS = "GAMEPLAY",
    BUFFS = "GAMEPLAY", PROCS = "GAMEPLAY", CRITS = "GAMEPLAY",
    DODGE = "GAMEPLAY", BLOCK = "GAMEPLAY", PARRY = "GAMEPLAY",
    STUNS = "GAMEPLAY", ROOTS = "GAMEPLAY", FEARS = "GAMEPLAY",
    LOOT = "GAMEPLAY", ROLLS = "GAMEPLAY", GREED = "GAMEPLAY",
    NEEDS = "GAMEPLAY", NINJA = "GAMEPLAY", TRADE = "GAMEPLAY",
    QUEST = "GAMEPLAY", SKILL = "GAMEPLAY", LEVEL = "GAMEPLAY",
    GRIND = "GAMEPLAY", FARMS = "GAMEPLAY", DUELS = "GAMEPLAY",
    ARENA = "GAMEPLAY", KILLS = "GAMEPLAY", DEATH = "GAMEPLAY",
    RESET = "GAMEPLAY", MELEE = "GAMEPLAY", RANGE = "GAMEPLAY",
    MAGIC = "GAMEPLAY", TRASH = "GAMEPLAY", PHASE = "GAMEPLAY",
    ADDON = "GAMEPLAY", MACRO = "GAMEPLAY", COMBO = "GAMEPLAY",
    BURST = "GAMEPLAY", PURGE = "GAMEPLAY", CURSE = "GAMEPLAY",
    STACK = "GAMEPLAY", PATCH = "GAMEPLAY", WIPED = "GAMEPLAY",
    OWNED = "GAMEPLAY", PWNED = "GAMEPLAY", SPEED = "GAMEPLAY",
    HEAL = "GAMEPLAY", HURT = "GAMEPLAY", PAIN = "GAMEPLAY",
    DOOM = "GAMEPLAY", TRAP = "GAMEPLAY", TOTEM = "GAMEPLAY",
    WARD = "GAMEPLAY", AURA = "GAMEPLAY", BUFF = "GAMEPLAY",
    NERF = "GAMEPLAY",

    -- MAGIC (16)
    FROST = "MAGIC", FIRES = "MAGIC", LIGHT = "MAGIC",
    ARCANE = "MAGIC", CHAOS = "MAGIC", HOLY = "MAGIC",
    STORM = "MAGIC", SHOCK = "MAGIC", BLAZE = "MAGIC",
    FLAME = "MAGIC", CHILL = "MAGIC", WINDS = "MAGIC",
    EARTH = "MAGIC", WATER = "MAGIC", NATRE = "MAGIC",
    RUNE = "MAGIC", SIGIL = "MAGIC",

    -- LOCATION (22)
    MARSH = "LOCATION", HILLS = "LOCATION", WOODS = "LOCATION",
    PEAKS = "LOCATION", WILDS = "LOCATION", FORGE = "LOCATION",
    TOWER = "LOCATION", KEEPS = "LOCATION", GATES = "LOCATION",
    WALLS = "LOCATION", RUINS = "LOCATION", CAVES = "LOCATION",
    MINES = "LOCATION", TOMBS = "LOCATION", ALTAR = "LOCATION",
    NEXUS = "LOCATION", DUNES = "LOCATION", OASIS = "LOCATION",
    COAST = "LOCATION", PORTS = "LOCATION", DOCKS = "LOCATION",
    SHIPS = "LOCATION",

    -- PROFESSION (7)
    MINER = "PROFESSION", SMITH = "PROFESSION", HERBS = "PROFESSION",
    SKINS = "PROFESSION", JEWEL = "PROFESSION", COOKS = "PROFESSION",
    CRAFT = "PROFESSION",

    -- QUALITY (7)
    EPICS = "QUALITY", BLUES = "QUALITY", GREEN = "QUALITY",
    GRAYS = "QUALITY", PURPS = "QUALITY", GOLDS = "QUALITY",
    RARES = "QUALITY",

    -- EMOTE (10)
    CHEER = "EMOTE", DANCE = "EMOTE", SALUT = "EMOTE",
    WAVES = "EMOTE", LAUGH = "EMOTE", CRIES = "EMOTE",
    POINT = "EMOTE", SHRUG = "EMOTE", FLEX = "EMOTE",
    SLEEP = "EMOTE",

    -- CURRENCY (6)
    HONOR = "CURRENCY", MARKS = "CURRENCY", BADGE = "CURRENCY",
    TOKEN = "CURRENCY", GOLD = "CURRENCY", COIN = "CURRENCY",
    GEMS = "CURRENCY",

    -- TBC (9)
    NAARU = "TBC", DRAEN = "TBC", ILLIS = "TBC",
    OUTLD = "TBC", SHATT = "TBC", AUCHD = "TBC",
    KAEL = "TBC", VASHJ = "TBC", ILLID = "TBC",

    -- MOUNT (2)
    MOUNT = "MOUNT", FLYER = "MOUNT",

    -- RESOURCE (3)
    MANA = "RESOURCE", RAGE = "RESOURCE", POWER = "RESOURCE",

    -- MISC (3)
    HEART = "MISC", SOULS = "MISC", BONES = "MISC",
}

WordleWords.CATEGORY_HINTS = {
    CLASS      = "This is a player class",
    RACE       = "This is a playable race",
    CREATURE   = "This is a creature or enemy",
    EQUIPMENT  = "This is equipment or gear",
    CONSUMABLE = "This is a consumable item",
    SOCIAL     = "This is a social/group term",
    GAMEPLAY   = "This is a gameplay mechanic",
    MAGIC      = "This is magic or elemental",
    LOCATION   = "This is a location or terrain",
    PROFESSION = "This is a profession term",
    QUALITY    = "This is an item quality",
    EMOTE      = "This is an emote or action",
    CURRENCY   = "This is a currency or reward",
    TBC        = "This is TBC/Outland specific",
    MOUNT      = "This is related to mounts",
    RESOURCE   = "This is a player resource",
    MISC       = "This is a WoW term",
}

--[[
    Get hint for a word
    @param word string
    @return string hint text
]]
function WordleWords:GetHint(word)
    if not word then return "This is a WoW term" end
    local category = self.CATEGORIES[word:upper()]
    if category then
        return self.CATEGORY_HINTS[category]
    end
    return "This is a WoW term"
end
```

---

### File: WordleGame.lua

**Change 1:** Add to game state (line 137, inside CreateGame)

```lua
local game = {
    id = gameId,
    mode = mode,
    state = self.STATE.PLAYING,
    secretWord = secretWord,
    guesses = {},
    currentInput = "",
    player = playerName,
    opponent = opponent,
    winner = nil,
    startTime = GetTime(),
    endTime = nil,
    letterStates = {},
    -- Hint system
    hintUsed = false,
}
```

**Change 2:** Add UseHint function (after SubmitCurrentInput, around line 518)

```lua
--[[
    Use the hint (reveals word category)
    @param gameId string
    @return boolean success
]]
function WordleGame:UseHint(gameId)
    local game = self.games[gameId]
    if not game then return false end
    if game.state ~= self.STATE.PLAYING then return false end
    if game.hintUsed then return false end

    -- Mark hint as used
    game.hintUsed = true

    -- Get hint text
    local WordleWords = HopeAddon.WordleWords
    local hintText = WordleWords:GetHint(game.secretWord)

    -- Update UI
    if self.ui.subtitle and self.ui.hintText then
        self.ui.subtitle:Hide()
        self.ui.hintText:SetText(hintText)
        self.ui.hintText:Show()
    end

    -- Disable hint button
    if self.ui.hintButton then
        self.ui.hintButton:Disable()
        self.ui.hintButton:SetText("Used")
    end

    -- Play subtle sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end

    return true
end
```

---

### File: WordleUI.lua

**Change 1:** Add to UI state table (line 67)

```lua
WordleGame.ui = {
    frame = nil,
    letterBoxes = {},
    keyboardKeys = {},
    statusText = nil,
    title = nil,
    subtitle = nil,          -- Already exists at line 168
    headerLine = nil,        -- Already exists at line 175
    hintButton = nil,        -- NEW
    hintText = nil,          -- NEW
    animationTimers = {},
}
```

**Change 2:** Add hint button after close button (after line 162)

```lua
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        WordleGame:CloseUI()
    end)

    -- NEW: Hint button (left of close button)
    local hintBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    hintBtn:SetSize(50, 22)
    hintBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -7)
    hintBtn:SetText("Hint")
    hintBtn:SetNormalFontObject("GameFontNormalSmall")
    hintBtn:SetScript("OnClick", function()
        if WordleGame.currentGameId then
            WordleGame:UseHint(WordleGame.currentGameId)
        end
    end)
    hintBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Reveal the word category (1 per game)", 1, 1, 1)
        GameTooltip:Show()
    end)
    hintBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.ui.hintButton = hintBtn
```

**Change 3:** Add hint text after subtitle (after line 168)

```lua
    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("|cFFAAAAAAGuess the 5-letter WoW word!|r")
    self.ui.subtitle = subtitle

    -- NEW: Hint text (same position, shown when hint is used)
    local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hintText:SetPoint("TOP", title, "BOTTOM", 0, -2)
    hintText:SetTextColor(1, 0.82, 0)  -- Gold: RGB(255, 209, 0)
    hintText:SetText("")
    hintText:Hide()
    self.ui.hintText = hintText
```

**Change 4:** Reset hint in ResetUIState (add to line 626)

```lua
function WordleGame:ResetUIState()
    local COLORS = GetColors()

    -- Clear all letter boxes
    for row = 1, self.MAX_GUESSES do
        for col = 1, self.WORD_LENGTH do
            self:UpdateLetterBox(row, col, nil, nil)
        end
    end

    -- Reset keyboard colors
    local kc = COLORS.KEY_DEFAULT
    local tc = COLORS.TEXT_WHITE
    for letter, key in pairs(self.ui.keyboardKeys) do
        if letter ~= "ENTER" and letter ~= "BACK" then
            key:SetBackdropColor(kc.r, kc.g, kc.b, 1)
            key.text:SetTextColor(tc.r, tc.g, tc.b, 1)
        end
    end

    -- NEW: Reset hint display
    if self.ui.subtitle then
        self.ui.subtitle:Show()
    end
    if self.ui.hintText then
        self.ui.hintText:SetText("")
        self.ui.hintText:Hide()
    end
    if self.ui.hintButton then
        self.ui.hintButton:Enable()
        self.ui.hintButton:SetText("Hint")
    end
end
```

**Change 5:** Restore hint state in UpdateUI (add to line 620, before statusText update)

```lua
    -- NEW: Update hint button state
    if self.ui.hintButton then
        if game.hintUsed then
            self.ui.hintButton:Disable()
            self.ui.hintButton:SetText("Used")
        else
            self.ui.hintButton:Enable()
            self.ui.hintButton:SetText("Hint")
        end
    end
```

---

## Visual Summary

### Before Hint Used
```
┌───────────────────────────────────────────────────────┐
│                                        [Hint]   [X]   │
│                                                       │
│                      WoW Wordle                       │
│             Guess the 5-letter WoW word!              │  ← Grey subtitle
│  ─────────────────────────────────────────────────    │
│                                                       │
│          ┌────┬────┬────┬────┬────┐                  │
│          │    │    │    │    │    │                  │
│          └────┴────┴────┴────┴────┘                  │
```

### After Hint Used
```
┌───────────────────────────────────────────────────────┐
│                                        [Used]   [X]   │  ← Button disabled
│                                                       │
│                      WoW Wordle                       │
│              This is a creature or enemy              │  ← Gold hint text
│  ─────────────────────────────────────────────────    │
│                                                       │
│          ┌────┬────┬────┬────┬────┐                  │
│          │ D  │ R  │ A  │ K  │ E  │                  │
│          └────┴────┴────┴────┴────┘                  │
```

---

## Summary

| Aspect | Detail |
|--------|--------|
| **Hint button** | 50×22 at TOPRIGHT (-40, -7), left of close button |
| **Hint text** | Replaces subtitle, gold color (1, 0.82, 0) |
| **Limit** | 1 hint per game (`hintUsed` flag) |
| **Categories** | 17 categories covering all ~156 words |
| **Layout changes** | None - uses existing subtitle space |
| **Files modified** | WordleWords.lua, WordleGame.lua, WordleUI.lua |
| **Lines added** | ~180 (mostly category data) |
