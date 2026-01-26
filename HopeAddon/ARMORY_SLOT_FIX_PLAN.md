# Armory Paperdoll Slot Fix Plan

## Problem Statement

The Armory tab's paperdoll shows **only the necklace slot** instead of all 15 equipped slots. All equipment slots should display their currently equipped items from the character sheet with proper tooltips on hover.

**Expected:** 15 visible slots (head, neck, shoulders, back, chest, wrist, hands, waist, legs, feet, ring1, ring2, trinket1, trinket2, mainhand, offhand, ranged)
**Actual:** Only necklace (neck) slot visible

---

## Root Cause Analysis

### Code Flow Trace

```
PopulateArmory() [Journal.lua:9094]
    └─► CreateArmoryContainer() [Journal.lua:9210]
            └─► CreateArmoryCharacterView() [Journal.lua:9464]
                    ├─► CreateArmoryModelFrame() [Journal.lua:9495]  ← Model created FIRST
                    ├─► CreateArmorySlotsContainer() [Journal.lua:9557]
                    │       └─► CreateArmorySlotButtons() [Journal.lua:9585]
                    │               └─► CreateSingleArmorySlotButton() [Journal.lua:9635] × 17 times
                    └─► characterView:SetHeight(380) ← Height set AFTER children created!
    └─► RefreshArmorySlotData() [Journal.lua:10073]
            └─► RefreshSingleSlotData() [Journal.lua:10082] × 17 times
                    └─► GetInventoryItemLink("player", slotId) ← Correct WoW API usage
```

### Verified Correct Components

| Component | Location | Status |
|-----------|----------|--------|
| Slot definitions (17 slots) | Constants.lua:5369-5392 | ✅ Correct slot IDs |
| Position definitions (17 positions) | Constants.lua:5398-5428 | ✅ All slots have positions |
| Equipment query | Journal.lua:10085 | ✅ Uses `GetInventoryItemLink("player", slotId)` |
| Tooltip display | Journal.lua:10343-10358 | ✅ Uses `GameTooltip:SetInventoryItem("player", btn.slotId)` |
| Placeholder icons | Constants.lua:5452-5472 | ✅ All slots have placeholders |

### Identified Bugs (Ranked by Likelihood)

| Bug | Severity | Description |
|-----|----------|-------------|
| **B1** | CRITICAL | **Frame Level Missing** - Slot buttons have no explicit frame level; DressUpModel may render OVER them |
| **B2** | HIGH | **Creation Order** - `characterView:SetHeight()` called AFTER children created; anchoring may fail |
| **B3** | HIGH | **Container Frame Level** - `slotsContainer` has no frame level; may be behind model |
| **B4** | MEDIUM | **Weapon Fallback** - If model doesn't exist, weapon slots use hardcoded y=-290 instead of proper anchor |
| **B5** | LOW | **No Debug Visibility** - No way to diagnose which slots are created vs hidden |

---

## Payload Structure

| Payload | Focus | Tasks | Est. Lines |
|---------|-------|-------|------------|
| **PAYLOAD 0** | Diagnostics | Add debug logging and `/hope armoryslots` command | ~50 lines |
| **PAYLOAD 1** | Frame Levels | Fix slot button and container frame levels | ~10 lines |
| **PAYLOAD 2** | Creation Order | Fix height setting order, weapon anchor fallback | ~15 lines |
| **PAYLOAD 3** | Verification | Test all 15 slots, document results | Testing only |

---

## PAYLOAD 0: Diagnostics (Do First)

**Goal:** Add visibility into slot creation to identify exactly what's failing.

### Task 0.1: Add Debug Logging to CreateArmorySlotButtons

**File:** `Journal/Journal.lua`
**Function:** `CreateArmorySlotButtons()` at line 9585
**Action:** Add debug output showing slot creation status

**Current Code (lines 9585-9590):**
```lua
function Journal:CreateArmorySlotButtons()
    local slotsContainer = self.armoryUI.slotsContainer
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON
    local HIDDEN = HopeAddon.Constants.ARMORY_HIDDEN_SLOTS or {}

    for slotName, slotData in pairs(C.SLOTS) do
```

**New Code (replace lines 9585-9590):**
```lua
function Journal:CreateArmorySlotButtons()
    local slotsContainer = self.armoryUI.slotsContainer
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON
    local HIDDEN = HopeAddon.Constants.ARMORY_HIDDEN_SLOTS or {}

    -- DEBUG: Validate constants loaded correctly
    local slotCount = 0
    if C.SLOTS then
        for _ in pairs(C.SLOTS) do slotCount = slotCount + 1 end
    end
    HopeAddon:Debug("CreateArmorySlotButtons: SLOTS count =", slotCount)
    HopeAddon:Debug("CreateArmorySlotButtons: POSITIONS exists =", C.POSITIONS ~= nil)
    HopeAddon:Debug("CreateArmorySlotButtons: slotsContainer =", slotsContainer and "OK" or "NIL")
    if slotsContainer then
        HopeAddon:Debug("CreateArmorySlotButtons: container size =",
            math.floor(slotsContainer:GetWidth() or 0), "x", math.floor(slotsContainer:GetHeight() or 0))
        HopeAddon:Debug("CreateArmorySlotButtons: container frameLevel =", slotsContainer:GetFrameLevel())
    end

    local createdCount, shownCount, hiddenByConfig, hiddenNoPos = 0, 0, 0, 0

    for slotName, slotData in pairs(C.SLOTS) do
        createdCount = createdCount + 1
```

**Also modify the loop body to track counts. Change line 9592-9596 from:**
```lua
        if HIDDEN[slotName] then
            -- Hide if previously created
            if self.armoryUI.slotButtons[slotName] then
                self.armoryUI.slotButtons[slotName]:Hide()
            end
```

**To:**
```lua
        if HIDDEN[slotName] then
            hiddenByConfig = hiddenByConfig + 1
            -- Hide if previously created
            if self.armoryUI.slotButtons[slotName] then
                self.armoryUI.slotButtons[slotName]:Hide()
            end
```

**Change line 9622 from:**
```lua
                btn:Show()
```

**To:**
```lua
                btn:Show()
                shownCount = shownCount + 1
```

**Change lines 9624-9626 from:**
```lua
                -- Fallback: hide unpositioned slots
                HopeAddon:Debug("CreateArmorySlotButtons: No position for slot " .. slotName)
                btn:Hide()
```

**To:**
```lua
                -- Fallback: hide unpositioned slots
                hiddenNoPos = hiddenNoPos + 1
                HopeAddon:Debug("CreateArmorySlotButtons: No position for slot " .. slotName)
                btn:Hide()
```

**Add before final `end` (line 9630), insert:**
```lua
    HopeAddon:Debug("CreateArmorySlotButtons: SUMMARY - created:", createdCount,
        "shown:", shownCount, "hiddenConfig:", hiddenByConfig, "hiddenNoPos:", hiddenNoPos)
```

---

### Task 0.2: Add `/hope armoryslots` Debug Command

**File:** `Core/Core.lua`
**Location:** After line 1458 (after the `elseif cmd == "debug"` block ends)
**Action:** Add new slash command

**Insert this new elseif block after line 1458:**
```lua
    elseif cmd == "armoryslots" then
        -- Debug: List all armory slot button states
        local Journal = HopeAddon.Journal
        if not Journal then
            HopeAddon:Print("Journal module not loaded")
            return
        end
        if not Journal.armoryUI or not Journal.armoryUI.slotButtons then
            HopeAddon:Print("Armory UI not initialized - open Armory tab first")
            return
        end

        HopeAddon:Print("=== Armory Slot Debug ===")
        local total, shown, hidden = 0, 0, 0
        for slotName, btn in pairs(Journal.armoryUI.slotButtons) do
            total = total + 1
            local isShown = btn:IsShown()
            local isVisible = btn:IsVisible()
            local w, h = btn:GetSize()
            local frameLevel = btn:GetFrameLevel()
            local itemName = btn.equippedItem and btn.equippedItem.name or "EMPTY"
            local status = btn.upgradeStatus or "?"

            if isShown and isVisible then
                shown = shown + 1
            else
                hidden = hidden + 1
            end

            HopeAddon:Print(string.format("  %s: shown=%s vis=%s lvl=%d size=%dx%d [%s] %s",
                slotName,
                isShown and "Y" or "N",
                isVisible and "Y" or "N",
                frameLevel,
                math.floor(w), math.floor(h),
                status,
                itemName))
        end
        HopeAddon:Print(string.format("Total: %d | Shown: %d | Hidden: %d", total, shown, hidden))

        -- Also show model frame level for comparison
        if Journal.armoryUI.modelFrame then
            HopeAddon:Print("Model frameLevel:", Journal.armoryUI.modelFrame:GetFrameLevel())
        end
```

---

### Task 0.3: Add Debug to RefreshSingleSlotData

**File:** `Journal/Journal.lua`
**Function:** `RefreshSingleSlotData()` at line 10082
**Action:** Add debug output for equipment loading

**Current Code (lines 10082-10086):**
```lua
function Journal:RefreshSingleSlotData(btn)
    local slotId = btn.slotId
    local slotName = btn.slotName
    local itemLink = GetInventoryItemLink("player", slotId)
    local C = HopeAddon.Constants
```

**New Code (replace lines 10082-10086):**
```lua
function Journal:RefreshSingleSlotData(btn)
    local slotId = btn.slotId
    local slotName = btn.slotName
    local itemLink = GetInventoryItemLink("player", slotId)
    local C = HopeAddon.Constants

    HopeAddon:Debug("RefreshSingleSlotData:", slotName, "slotId=", slotId, "hasItem=", itemLink and "YES" or "NO")
```

---

## PAYLOAD 1: Frame Level Fixes (Core Fix)

**Goal:** Ensure slot buttons render ABOVE the DressUpModel frame.

### Task 1.1: Set Frame Level on Slots Container

**File:** `Journal/Journal.lua`
**Function:** `CreateArmorySlotsContainer()` at line 9557
**Location:** Lines 9561-9568 (inside the `if not self.armoryUI.slotsContainer then` block)
**Action:** Add frame level after creating container

**Current Code (lines 9561-9568):**
```lua
    if not self.armoryUI.slotsContainer then
        local slotsContainer = CreateFrame("Frame", "HopeArmorySlotsContainer", characterView)
        -- Span the full characterView area so slots can be positioned symmetrically
        slotsContainer:SetPoint("TOPLEFT", characterView, "TOPLEFT", 0, 0)
        slotsContainer:SetPoint("BOTTOMRIGHT", characterView, "BOTTOMRIGHT", 0, 0)

        self.armoryUI.slotsContainer = slotsContainer
        self.armoryUI.slotButtons = {}
    end
```

**New Code (replace lines 9561-9568):**
```lua
    if not self.armoryUI.slotsContainer then
        local slotsContainer = CreateFrame("Frame", "HopeArmorySlotsContainer", characterView)
        -- Span the full characterView area so slots can be positioned symmetrically
        slotsContainer:SetPoint("TOPLEFT", characterView, "TOPLEFT", 0, 0)
        slotsContainer:SetPoint("BOTTOMRIGHT", characterView, "BOTTOMRIGHT", 0, 0)

        -- CRITICAL: Set frame level ABOVE model frame (model is typically level 1-5)
        -- This ensures slot buttons are clickable and visible over the 3D model
        slotsContainer:SetFrameLevel(characterView:GetFrameLevel() + 10)

        self.armoryUI.slotsContainer = slotsContainer
        self.armoryUI.slotButtons = {}
    end
```

---

### Task 1.2: Set Frame Level on Individual Slot Buttons

**File:** `Journal/Journal.lua`
**Function:** `CreateSingleArmorySlotButton()` at line 9635
**Location:** Lines 9638-9639
**Action:** Add frame level after creating button

**Current Code (lines 9635-9641):**
```lua
function Journal:CreateSingleArmorySlotButton(parent, slotName, slotData)
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON

    local btn = CreateFrame("Button", "HopeArmorySlot_" .. slotName, parent, "BackdropTemplate")
    btn:SetSize(C.SIZE, C.SIZE)

    -- Backdrop
```

**New Code (replace lines 9635-9641):**
```lua
function Journal:CreateSingleArmorySlotButton(parent, slotName, slotData)
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON

    local btn = CreateFrame("Button", "HopeArmorySlot_" .. slotName, parent, "BackdropTemplate")
    btn:SetSize(C.SIZE, C.SIZE)

    -- CRITICAL: Ensure button renders above model frame
    -- Parent (slotsContainer) is already elevated; add +2 for button layer
    btn:SetFrameLevel(parent:GetFrameLevel() + 2)

    -- Backdrop
```

---

## PAYLOAD 2: Creation Order & Anchor Fixes

**Goal:** Fix timing issues with container sizing and weapon slot anchoring.

### Task 2.1: Set Height BEFORE Creating Children

**File:** `Journal/Journal.lua`
**Function:** `CreateArmoryCharacterView()` at line 9464
**Location:** Lines 9481-9492
**Action:** Move `SetHeight` call before child creation

**Current Code (lines 9481-9492):**
```lua
    local characterView = self.armoryUI.characterView
    characterView:Show()

    -- Create child components - MODEL FIRST so weapons can anchor to it
    self:CreateArmoryModelFrame()
    self:CreateArmorySlotsContainer()

    -- Compact height: 8 slots × 44px + weapons (54) + padding (10) = 380px
    local compactHeight = HopeAddon.Constants.ARMORY_CHARACTER_VIEW.COMPACT_HEIGHT or 380
    characterView:SetHeight(compactHeight)

    return characterView
```

**New Code (replace lines 9481-9492):**
```lua
    local characterView = self.armoryUI.characterView
    characterView:Show()

    -- IMPORTANT: Set height BEFORE creating children so anchor-based positioning works
    -- Compact height: 8 slots × 44px + weapons (54) + padding (10) = 380px
    local compactHeight = HopeAddon.Constants.ARMORY_CHARACTER_VIEW.COMPACT_HEIGHT or 380
    characterView:SetHeight(compactHeight)

    -- Create child components - MODEL FIRST so weapons can anchor to it
    self:CreateArmoryModelFrame()
    self:CreateArmorySlotsContainer()

    return characterView
```

---

### Task 2.2: Fix Weapon Slot Anchor Fallback

**File:** `Journal/Journal.lua`
**Function:** `CreateArmorySlotButtons()` at line 9585
**Location:** Lines 9609-9617 (inside the `if pos.anchor == "MODEL_BOTTOM"` block)
**Action:** Improve fallback when model frame doesn't exist

**Current Code (lines 9609-9617):**
```lua
                if pos.anchor == "MODEL_BOTTOM" then
                    -- Special handling: anchor weapons to model frame bottom
                    local modelFrame = self.armoryUI.modelFrame
                    if modelFrame then
                        btn:SetPoint("TOP", modelFrame, "BOTTOM", pos.x, pos.y)
                    else
                        -- Fallback if model not created yet - will reposition later
                        btn:SetPoint("TOP", slotsContainer, "TOP", pos.x, -290)
                    end
```

**New Code (replace lines 9609-9617):**
```lua
                if pos.anchor == "MODEL_BOTTOM" then
                    -- Special handling: anchor weapons to model frame bottom
                    local modelFrame = self.armoryUI.modelFrame
                    if modelFrame then
                        btn:SetPoint("TOP", modelFrame, "BOTTOM", pos.x, pos.y)
                    else
                        -- Fallback: anchor to characterView bottom with offset
                        -- This handles edge case where model isn't created yet
                        local characterView = self.armoryUI.characterView
                        if characterView then
                            btn:SetPoint("BOTTOM", characterView, "BOTTOM", pos.x, 10)
                        else
                            -- Ultimate fallback to slotsContainer
                            btn:SetPoint("TOP", slotsContainer, "TOP", pos.x, -290)
                        end
                    end
```

---

## PAYLOAD 3: Verification & Testing

**Goal:** Confirm all fixes work correctly.

### Task 3.1: Test Procedure

1. **Enable Debug Mode:**
   ```
   /hope debug
   ```

2. **Open Armory Tab:**
   ```
   /hope
   ```
   Navigate to Armory tab. Watch chat for debug messages.

3. **Expected Debug Output:**
   ```
   CreateArmorySlotButtons: SLOTS count = 17
   CreateArmorySlotButtons: POSITIONS exists = true
   CreateArmorySlotButtons: slotsContainer = OK
   CreateArmorySlotButtons: container size = 300 x 380
   CreateArmorySlotButtons: container frameLevel = 15
   CreateArmorySlotButtons: SUMMARY - created: 17 shown: 15 hiddenConfig: 2 hiddenNoPos: 0
   ```

4. **Run Slot Debug Command:**
   ```
   /hope armoryslots
   ```

5. **Expected Output (all 15 visible slots):**
   ```
   === Armory Slot Debug ===
     head: shown=Y vis=Y lvl=17 size=44x44 [ok] Helmet of the Fallen Champion
     neck: shown=Y vis=Y lvl=17 size=44x44 [ok] Pendant of the Violet Eye
     shoulders: shown=Y vis=Y lvl=17 size=44x44 [empty] EMPTY
     ...etc for all 15 slots...
   Total: 15 | Shown: 15 | Hidden: 0
   Model frameLevel: 5
   ```

6. **Visual Verification:**
   - [ ] All 15 slots visible in paperdoll layout
   - [ ] Left column: HEAD, NECK, SHLD, BACK, CHEST, WRIST
   - [ ] Right column: HANDS, WAIST, LEGS, FEET, RING, RING, TRNK, TRNK
   - [ ] Bottom row: MH, OH, RNG (below model)
   - [ ] Equipped items show their icons
   - [ ] Empty slots show placeholder icons (greyed out)
   - [ ] Hover shows GameTooltip with item stats

---

### Task 3.2: Verification Checklist

| Check | Expected | Pass? |
|-------|----------|-------|
| Slot count in debug | 17 created, 15 shown, 2 hidden by config | [ ] |
| Frame level (slots) | Higher than model (e.g., 17 vs 5) | [ ] |
| Container size | Non-zero (e.g., 300x380) | [ ] |
| HEAD slot visible | Shows helm or placeholder | [ ] |
| NECK slot visible | Shows necklace or placeholder | [ ] |
| SHOULDERS slot visible | Shows shoulders or placeholder | [ ] |
| BACK slot visible | Shows cloak or placeholder | [ ] |
| CHEST slot visible | Shows chest or placeholder | [ ] |
| WRIST slot visible | Shows bracers or placeholder | [ ] |
| HANDS slot visible | Shows gloves or placeholder | [ ] |
| WAIST slot visible | Shows belt or placeholder | [ ] |
| LEGS slot visible | Shows pants or placeholder | [ ] |
| FEET slot visible | Shows boots or placeholder | [ ] |
| RING1 slot visible | Shows ring or placeholder | [ ] |
| RING2 slot visible | Shows ring or placeholder | [ ] |
| TRINKET1 slot visible | Shows trinket or placeholder | [ ] |
| TRINKET2 slot visible | Shows trinket or placeholder | [ ] |
| MAINHAND slot visible | Shows weapon or placeholder | [ ] |
| OFFHAND slot visible | Shows offhand or placeholder | [ ] |
| RANGED slot visible | Shows ranged or placeholder | [ ] |
| Tooltip on hover | Shows item stats from character | [ ] |
| Click opens gear popup | Shows BiS recommendations | [ ] |

---

## Summary: Files to Modify

| File | Payload | Task | Line(s) | Change |
|------|---------|------|---------|--------|
| `Journal/Journal.lua` | P0.1 | 0.1 | 9585-9590 | Add debug logging at function start |
| `Journal/Journal.lua` | P0.1 | 0.1 | 9592 | Add `hiddenByConfig` counter |
| `Journal/Journal.lua` | P0.1 | 0.1 | 9622 | Add `shownCount` counter |
| `Journal/Journal.lua` | P0.1 | 0.1 | 9624-9626 | Add `hiddenNoPos` counter |
| `Journal/Journal.lua` | P0.1 | 0.1 | 9629 | Add summary debug line |
| `Journal/Journal.lua` | P0.3 | 0.3 | 10086 | Add debug to RefreshSingleSlotData |
| `Core/Core.lua` | P0.2 | 0.2 | 1458+ | Add `/hope armoryslots` command |
| `Journal/Journal.lua` | P1.1 | 1.1 | 9565 | Set slotsContainer frame level |
| `Journal/Journal.lua` | P1.2 | 1.2 | 9639 | Set slot button frame level |
| `Journal/Journal.lua` | P2.1 | 2.1 | 9481-9492 | Move SetHeight before child creation |
| `Journal/Journal.lua` | P2.2 | 2.2 | 9609-9617 | Improve weapon slot anchor fallback |

---

## Expected Visual Result

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE: [1] [2] [3] [5]                  [Spec: Protection] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [HEAD]                                        [HANDS]      │
│  [NECK]         ┌─────────────────┐           [WAIST]      │
│  [SHLD]         │                 │           [LEGS]       │
│  [BACK]         │   PLAYER MODEL  │           [FEET]       │
│  [CHEST]        │   (rotatable)   │           [RING]       │
│  [WRIST]        │                 │           [RING]       │
│                 └─────────────────┘           [TRNK]       │
│                                               [TRNK]       │
│                                                             │
│              [MH]    [OH]    [RNG]                          │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Avg iLvl: 125    Upgrades: 4 slots    Wishlisted: 2 items │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Order

1. **PAYLOAD 0** - Run diagnostics first to confirm root cause
2. **PAYLOAD 1** - Apply frame level fixes (most likely solution)
3. **PAYLOAD 2** - Apply creation order fixes (secondary)
4. **PAYLOAD 3** - Verify all slots working

If PAYLOAD 1 alone fixes the issue, PAYLOAD 2 is still recommended for robustness.
