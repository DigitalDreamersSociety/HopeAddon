# Fix Plan: Travelers Tab Romance and Companion Buttons

## Problem Statement

The user reports that in the Social tab → Travelers sub-tab, the "Propose to" (heart) button and "Add to Companions" (star) button are broken.

## Analysis Summary

After thorough code review of `Journal.lua` lines 6545-6829 (`CreateTravelerRow` function), the button creation code appears correct. The buttons:
- Are created as `Button` frames
- Have `OnClick` handlers set via `SetScript`
- Call the correct module functions (`Romance:ProposeToPlayer`, `Companions:SendRequest`)

### Potential Root Causes

1. **Module not loaded** - `HopeAddon.Companions` or `HopeAddon.Romance` may be nil when buttons are clicked
2. **SendDirectMessage failure** - The network message may fail silently
3. **Data initialization** - `GetSocialRomance()` may return nil causing the romance button code to not set click handlers

### Code Locations

| Component | File | Lines | Function |
|-----------|------|-------|----------|
| Traveler Row Creation | Journal.lua | 6545-6829 | `CreateTravelerRow()` |
| Companion Button | Journal.lua | 6659-6679 | Inside CreateTravelerRow |
| Romance Button | Journal.lua | 6681-6785 | Inside CreateTravelerRow |
| Companion Module | Companions.lua | 65-100 | `SendRequest()` |
| Romance Module | Romance.lua | 309-370 | `ProposeToPlayer()` |
| Send Message | FellowTravelers.lua | 280-283 | `SendDirectMessage()` |

## Implementation Plan

### Step 1: Add Debug Logging to Button Click Handlers

**File:** `Journal/Journal.lua`

Add debug prints to verify buttons are being clicked and handlers are executing:

**Companion Button (line 6664-6672):**
```lua
function()
    HopeAddon:Print("[DEBUG] Companion button clicked for: " .. entry.name)
    if HopeAddon.Companions then
        HopeAddon:Print("[DEBUG] Companions module exists")
        if HopeAddon.Companions:IsCompanion(entry.name) then
            HopeAddon:Print("[DEBUG] Removing companion")
            HopeAddon.Companions:RemoveCompanion(entry.name)
        else
            HopeAddon:Print("[DEBUG] Sending companion request")
            HopeAddon.Companions:SendRequest(entry.name)
        end
        self:RefreshTravelersList()
    else
        HopeAddon:Print("[DEBUG] ERROR: Companions module is nil!")
    end
end
```

**Romance Button - SINGLE state (line 6766-6770):**
```lua
romanceBtn:SetScript("OnClick", function()
    HopeAddon:Print("[DEBUG] Romance button clicked for: " .. entry.name)
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    if HopeAddon.Romance then
        HopeAddon:Print("[DEBUG] Romance module exists, proposing...")
        local success, err = HopeAddon.Romance:ProposeToPlayer(entry.name)
        HopeAddon:Print("[DEBUG] Propose result: " .. tostring(success) .. " " .. tostring(err or ""))
    else
        HopeAddon:Print("[DEBUG] ERROR: Romance module is nil!")
    end
    Journal:RefreshTravelersList()
end)
```

### Step 2: Add Debug to SendDirectMessage

**File:** `Social/FellowTravelers.lua` (line 280-283)

```lua
function FellowTravelers:SendDirectMessage(target, msgType, data)
    HopeAddon:Debug("SendDirectMessage called - target:", target, "type:", msgType, "data:", data)
    local msg = string.format("%s:%d:%s", msgType, PROTOCOL_VERSION, data or "")
    local success = SafeSendAddonMessage(ADDON_PREFIX, msg, "WHISPER", target)
    HopeAddon:Debug("SendDirectMessage result:", success)
end
```

### Step 3: Check Romance Data Initialization

**File:** `Journal/Journal.lua` (line 6683-6684)

Current code:
```lua
local romance = HopeAddon:GetSocialRomance()
if romance and HopeAddon.Romance then
```

This is correct - if `romance` is nil, no heart button state handlers will be set. But the button IS still created. The issue is that if `GetSocialRomance()` returns nil OR if `romance.status` doesn't equal "SINGLE", then NO OnClick handler is set for the SINGLE state.

**Potential Fix:** Add defensive fallback to ensure click handler is always set for clickable states.

### Step 4: Verify Module Registration

Check that both modules are properly registered and enabled:

**Companions.lua line 14:**
```lua
HopeAddon:RegisterModule("Companions", Companions)
```

**Romance.lua line 21:**
```lua
HopeAddon:RegisterModule("Romance", Romance)
```

Both look correct. Need to verify modules are in HopeAddon.toc load order.

## Recommended Fixes

### Fix 1: Add Error Handling to Companion Button

**File:** `Journal/Journal.lua` (lines 6664-6672)

```lua
function()
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    if not HopeAddon.Companions then
        HopeAddon:Print("|cFFFF0000Error:|r Companions module not loaded")
        return
    end
    if HopeAddon.Companions:IsCompanion(entry.name) then
        HopeAddon.Companions:RemoveCompanion(entry.name)
    else
        local success = HopeAddon.Companions:SendRequest(entry.name)
        if not success then
            HopeAddon:Print("|cFFFF0000Failed to send companion request|r")
        end
    end
    self:RefreshTravelersList()
end
```

### Fix 2: Add Error Handling to Romance Button

**File:** `Journal/Journal.lua` (lines 6766-6770)

```lua
romanceBtn:SetScript("OnClick", function()
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
    if not HopeAddon.Romance then
        HopeAddon:Print("|cFFFF0000Error:|r Romance module not loaded")
        return
    end
    local success, err = HopeAddon.Romance:ProposeToPlayer(entry.name)
    if not success and err then
        HopeAddon:Print("|cFFFF0000" .. err .. "|r")
    end
    Journal:RefreshTravelersList()
end)
```

### Fix 3: Ensure Romance Button Always Has Fallback State

Add an explicit else clause to handle edge cases:

**After line 6784, add:**
```lua
    -- Ensure button is interactive even if state is unknown
    if not romanceBtn:GetScript("OnClick") then
        romanceBtn:SetScript("OnClick", function()
            HopeAddon:Print("|cFFFFFF00Unable to determine romance status|r")
        end)
    end
```

## Testing Plan

1. Enable debug mode: `/hope debug`
2. Open Journal → Social Tab → Travelers sub-tab
3. Click the star (companion) button on any traveler
4. Check chat for debug messages
5. Click the heart (romance) button on any traveler
6. Check chat for debug messages
7. Verify network messages are sent (check for "SendDirectMessage" debug output)

## Files to Modify

| File | Changes | Lines |
|------|---------|-------|
| `Journal/Journal.lua` | Add error handling to button handlers | ~20 lines |
| `Social/FellowTravelers.lua` | Add debug logging to SendDirectMessage | ~3 lines |

## Estimated Time

- Investigation complete
- Implementation: ~15 minutes
- Testing: ~10 minutes
