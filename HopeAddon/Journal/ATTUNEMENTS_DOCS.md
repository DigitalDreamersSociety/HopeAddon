# Attunements Tab - Component Reference

> **Audience:** AI assistants modifying attunement code in `Journal.lua`.
> **Scope:** Raid attunement progression UI, heroic key tracking, phase filtering, and TomTom integration.

---

## 1. Architecture Overview

### What the Attunements Tab Does

The Attunements tab is a **quest-chain tracker** showing the player's progress through TBC Classic raid attunement chains. It displays each attunement as a sequence of chapter cards, grouped by raid tier phase.

| Phase | Tier | Raids | Attunements |
|-------|------|-------|-------------|
| 1 | T4 | Karazhan, Gruul's, Mag's | Karazhan (The Master's Key) |
| 2 | T5 | SSC, Tempest Keep | SSC (Cudgel of Kar'desh), TK (Tempest Key), Cipher of Damnation |
| 3 | T6 | Hyjal, Black Temple | Hyjal (Vials of Eternity), BT (Medallion of Karabor) |

Heroic dungeon keys (reputation-gated) are also displayed at the bottom.

### File Map

| File | Role |
|------|------|
| `Journal/Journal.lua` | All UI rendering: phase bar, header cards, progress bars, chapter cards |
| `Raids/Attunements.lua` | Data module: progress tracking, quest completion, state queries |
| `Core/Constants.lua` | Attunement chain definitions, phase colors, difficulty levels, UI constants |
| `Core/ArmoryAcquisitionData.lua` | `ZONE_MAP_IDS` (:200), `ACQUISITION_LOCATIONS` (:17), `ACQUISITION_INSTANCE_INDEX` (:90) |

### Key Functions (Journal.lua)

| Function | Line | Purpose |
|----------|------|---------|
| `PopulateAttunements()` | Journal.lua:5714 | Entry point: creates header, phase bar, calls `PopulateAttunementsContent()` |
| `CreateAttunementsPhaseBar()` | Journal.lua:5738 | Creates/reuses the [All][1][2][3] phase filter buttons |
| `CreateAttunementsPhaseButtons()` | Journal.lua:5782 | Creates individual phase button frames |
| `SetAttunementsPhaseButtonState()` | Journal.lua:5886 | Applies active/inactive styling to a phase button |
| `SelectAttunementsPhase()` | Journal.lua:5923 | Handler when user clicks a phase button; updates state + refreshes |
| `RefreshAttunementsList()` | Journal.lua:5939 | Clears scroll content and re-populates for current phase |
| `PopulateAttunementsContent()` | Journal.lua:5952 | Dispatches to `PopulateAttunementsForPhase()` based on selected phase |
| `PopulateAttunementsForPhase(phase)` | Journal.lua:5995 | Renders header card + progress bar + chapter cards for each raid in a phase |
| `PopulateSingleAttunement(raidKey, phaseColor)` | Journal.lua:6165 | Renders chapter cards for one attunement chain |
| `ParseChapterLocation(locationStr, dungeonName)` | Journal.lua:6617 | Parses location strings into TomTom coordinates |
| `HideAttunementsTab()` | Journal.lua:15838 | Saves state to `charDb`, clears UI references |

---

## 2. Layout Diagram

```
+=============================================+
| RAID ATTUNEMENTS              (header)      |
+=============================================+
| [All] [1] [2] [3]      (phase filter bar)  |
+=============================================+
|                                             |
| -- PHASE 1: Tier 4 Content --    (divider) |
|                                             |
| [icon] KARAZHAN              (header card)  |
|        The Master's Key                     |
|        6/6 Chapters Complete                |
| [====== progress bar ======] 100%           |
|                                             |
| [icon] Ch. 1: The Call          (ch. card)  |
|        Quest Giver: Archmage Alturus        |
|        Location: Deadwind Pass (47.0, 75.6) |
|                                     [pin]   |  <- TomTom btn (if installed)
|                                             |
| [icon] Ch. 2: Contact from Dalaran          |
|        ...                                  |
|                                             |
| -- PHASE 2: Tier 5 Content --    (divider) |
|        ...                                  |
|                                             |
| === HEROIC DUNGEON KEYS ===      (section) |
| [icon] Flamewrought Key  Revered/Revered   |
| [icon] Reservoir Key     Honored/Revered    |
|        ...                                  |
+=============================================+
```

---

## 3. State References

Declared near the bottom of `Journal.lua`:

```lua
-- Journal.lua:15627
Journal.attunementsState = {
    selectedPhase = 0,  -- 0 = All, 1-3 = specific phase
}

-- Journal.lua:15631
Journal.attunementsUI = {
    phaseBar = nil,       -- Persistent phase bar frame
    phaseButtons = {},    -- { [phase] = buttonFrame }
}
```

`selectedPhase` is saved to `HopeAddon.charDb.attunements.selectedPhase` on tab hide (Journal.lua:15842).

---

## 4. Frame Pool Usage

The Attunements tab shares the global `cardPool` and `containerPool` from `Journal:CreateCardPool()` (Journal.lua:589) / `Journal:CreateContainerPool()` (Journal.lua:539). It does **not** create its own pools.

| Pool | Used For |
|------|----------|
| `self.cardPool` | Chapter cards, header cards |
| `self.containerPool` | Phase bar container, spacers |

### resetFunc Cleanup

The shared card pool `resetFunc` (Journal.lua:740) cleans up attunement-specific child frames:

- `card._waypointBtn` — TomTom waypoint button (hides, clears scripts + data)
- `card._lootBtn` — Raids tab loot button (hides, clears scripts + data)
- `card._raidAccent` — Raids tab accent texture (hides)
- `card.lootIcons` — Raids tab loot icon strip (hides all, nils table)

---

## 5. Data Module Reference (Raids/Attunements.lua)

| Method | Line | Returns | Description |
|--------|------|---------|-------------|
| `GetAttunementData(raidKey)` | :62 | table/nil | Raw attunement chain from Constants |
| `GetAllAttunements()` | :82 | table | All attunement chains keyed by raidKey |
| `GetPlayerFaction()` | :90 | string | "Alliance" or "Horde" |
| `GetTotalChapters(raidKey)` | :115 | number | Total chapter count (handles BT faction branches) |
| `GetBTChapters()` | :131 | table | Merged faction-specific + shared chapters for BT |
| `GetChaptersForRaid(raidKey)` | :169 | table | Chapter list (faction-aware for BT) |
| `GetProgress(raidKey)` | :187 | number, number | completedCount, totalCount |
| `GetState(raidKey)` | :206 | number | STATE.NOT_STARTED / IN_PROGRESS / COMPLETED |
| `GetPercentage(raidKey)` | :223 | number | 0-100 progress percentage |
| `CompleteChapter(raidKey, idx)` | :246 | — | Marks chapter complete in charDb |
| `CheckQuestAttunement(questID)` | :358 | — | Auto-complete chapter if quest matches |
| `GetChapterDetails(raidKey, idx)` | :392 | table | { isComplete, completedDate } |
| `GetAllChapters(raidKey)` | :430 | table | Chapters with merged completion details |
| `GetNextChapter(raidKey)` | :448 | number/nil | Index of first incomplete chapter |
| `IsAttuned(raidKey)` | :470 | boolean | All chapters complete? |
| `GetSummary(raidKey)` | :480 | table | { state, completed, total, percentage, nextChapter } |

---

## 6. Constants Reference

### Attunement Chain Definitions (Constants.lua)

| Constant | Line | Raid | Chapters |
|----------|------|------|----------|
| `C.KARAZHAN_ATTUNEMENT` | :430 | Karazhan | 7 chapters (solo + dungeon chain) |
| `C.SSC_ATTUNEMENT` | :710 | SSC | 1 chapter (heroic drops) |
| `C.TK_ATTUNEMENT` | :737 | Tempest Keep | 5 chapters (trials + Magtheridon) |
| `C.CIPHER_OF_DAMNATION` | :800 | TK prereq | 6 chapters (Shadowmoon Valley chain) |
| `C.HYJAL_ATTUNEMENT` | :903 | Mount Hyjal | 1 chapter (T5 boss drops) |
| `C.BT_ATTUNEMENT` | :929 | Black Temple | Faction branches (4 Aldor/4 Scryer) + shared chapters |
| `C.HEROIC_KEYS` | :1251 | Heroic dungeons | 5 rep-gated keys |

### Phase & Styling Constants

| Constant | Line | Description |
|----------|------|-------------|
| `C.ATTUNEMENT_DIFFICULTY` | Constants.lua:347 | `{ SOLO, GROUP_5, HEROIC_5, RAID_10, RAID_25 }` with label + color |
| `C.PHASE_BORDER_COLORS` | Constants.lua:376 | `{ [1]=KARA_PURPLE, [2]=SSC_BLUE, [3]=BT_FEL }` RGBA arrays |
| `C.ATTUNEMENT_PHASE_HEADER` | Constants.lua:408 | Phase divider styling: icons, descriptions, color names |
| `C.ATTUNEMENT_HEADER_CARD` | Constants.lua:390 | Header card dimensions: height, icon size, raid icons |
| `C.ATTUNEMENT_PHASE_BAR` | Constants.lua:7454 | Phase bar backdrop, colors, dimensions |
| `C.ATTUNEMENT_PHASE_BUTTON` | Constants.lua:7470 | Phase button sizing + state colors (active/inactive/hover) |
| `C.HEROIC_KEY_ORDER` | Constants.lua:1330 | Display order for heroic keys |

---

## 7. TomTom Integration

### Overview

Chapter cards show a small green waypoint button (16x16, top-right corner) when:
1. TomTom addon is loaded (`TomTom` global exists with `AddWaypoint` method)
2. The chapter has a resolvable location (inline coordinates or dungeon lookup)

### Location Resolution (`ParseChapterLocation`, Journal.lua:6617)

Priority order:
1. **Inline coordinates** — `"Zone (x, y)"` or `"NPC - Zone (x, y)"` parsed via pattern matching
2. **Dungeon fallback** — `chapter.dungeon` looked up in `ACQUISITION_INSTANCE_INDEX` (ArmoryAcquisitionData.lua:90) → `ACQUISITION_LOCATIONS` (ArmoryAcquisitionData.lua:17)

Zone names are mapped to TBC Classic `uiMapId` values via `C.ZONE_MAP_IDS` (ArmoryAcquisitionData.lua:200).

### Waypoint Button Behavior

- **OnClick:** Calls `TomTom:AddWaypoint(mapId, x, y, { title = label })` and prints confirmation
- **OnEnter:** Tooltip showing "Set TomTom Waypoint" + location label
- **Cleanup:** `resetFunc` hides button and clears all scripts + stored data (`_mapId`, `_wpX`, `_wpY`, `_wpLabel`)

### Location String Examples

```
"Deadwind Pass (47.0, 75.6)"                -> mapId=42, x=0.47, y=0.756, label="Deadwind Pass"
"Archmage Cedric - Alterac Mountains (15.6, 54.4)" -> mapId=15, x=0.156, y=0.544, label="Archmage Cedric (Alterac Mountains)"
"Shattrath City (54.8, 44.6)"               -> mapId=481, x=0.548, y=0.446, label="Shattrath City"
"The Black Morass (after completion)"        -> no match (no numeric coords) -> nil
```
