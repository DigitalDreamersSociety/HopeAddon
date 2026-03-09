-- TooltipEnhancer.lua
-- Hooks into WoW item tooltips to show BiS status and Gear Score

local TooltipEnhancer = {}
HopeAddon.TooltipEnhancer = TooltipEnhancer

local C = HopeAddon.Constants
local tooltipBisLookup = {}        -- [itemId] = { {phase, slot, slotLabel, isBis}, ... }
local tooltipLookupGuideKey = nil  -- tracks cached guideKey
local tooltipHooked = false
local tooltipProcessed = {}        -- [tooltip] = itemId when already annotated this show-cycle

-- Build a slot id -> label lookup from C.ARMORY_SLOTS
local slotLabelMap = {}
for _, slotDef in ipairs(C.ARMORY_SLOTS) do
    slotLabelMap[slotDef.id] = slotDef.label
end

--[[
    Build reverse lookup: itemId -> list of {phase, slot, slotLabel, isBis}
    Only rebuilds when guideKey changes (talent switch / first call)
]]
local function BuildTooltipBisLookup(guideKey)
    if guideKey == tooltipLookupGuideKey then return end

    wipe(tooltipBisLookup)
    tooltipLookupGuideKey = guideKey

    local db = C.ARMORY_SPEC_BIS_DATABASE
    if not db then return end

    for phase = 0, 5 do
        local phaseData = db[phase]
        if phaseData then
            local specData = phaseData[guideKey]
            if specData then
                for slot, slotData in pairs(specData) do
                    local label = slotLabelMap[slot] or slot

                    -- Index BiS item
                    if slotData.bis and slotData.bis.id then
                        local id = slotData.bis.id
                        tooltipBisLookup[id] = tooltipBisLookup[id] or {}
                        table.insert(tooltipBisLookup[id], {
                            phase = phase,
                            slot = slot,
                            slotLabel = label,
                            isBis = true,
                        })
                    end

                    -- Index Alt items
                    if slotData.alts then
                        for _, alt in ipairs(slotData.alts) do
                            if alt.id then
                                local id = alt.id
                                tooltipBisLookup[id] = tooltipBisLookup[id] or {}
                                table.insert(tooltipBisLookup[id], {
                                    phase = phase,
                                    slot = slot,
                                    slotLabel = label,
                                    isBis = false,
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

--[[
    Add BiS annotation lines to tooltip
]]
local function AddBisLinesToTooltip(tooltip, entries)
    -- Shallow copy to avoid mutating cached lookup
    local sorted = {}
    for i, e in ipairs(entries) do sorted[i] = e end

    -- Sort: BiS first, then by phase ascending
    table.sort(sorted, function(a, b)
        if a.isBis ~= b.isBis then return a.isBis end
        return a.phase < b.phase
    end)

    tooltip:AddLine(" ")
    tooltip:AddLine("|cFF9B30FFHope Is Here|r")

    for _, entry in ipairs(sorted) do
        local phaseName = C.ARMORY_PHASES[entry.phase] and C.ARMORY_PHASES[entry.phase].name or ("Phase " .. entry.phase)
        if entry.isBis then
            -- Gold: BiS
            tooltip:AddLine("  \226\152\133 BiS " .. phaseName .. " (" .. entry.slotLabel .. ")", 1.0, 0.84, 0.0)
        else
            -- Green: Alt
            tooltip:AddLine("  \226\151\134 Alt " .. phaseName .. " (" .. entry.slotLabel .. ")", 0.12, 1.0, 0.0)
        end
    end
end

--[[
    Add gear score footer to tooltip
]]
local function AddGearScoreToTooltip(tooltip)
    local settings = HopeAddon.db and HopeAddon.db.settings
    if settings and settings.tooltipGearScoreEnabled == false then return end

    local gearScore, avgILvl = HopeAddon:GetGearScore()
    if not gearScore or gearScore <= 0 then return end

    local Directory = HopeAddon.Directory
    if not Directory then return end

    local colorHex = Directory:GetILvlColor(avgILvl)
    local r = tonumber(colorHex:sub(1, 2), 16) / 255
    local g = tonumber(colorHex:sub(3, 4), 16) / 255
    local b = tonumber(colorHex:sub(5, 6), 16) / 255

    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(
        "iLvl: " .. avgILvl, "GS: " .. gearScore,
        r, g, b,          -- left color (tier-based)
        1.0, 0.84, 0.0    -- right color (gold)
    )
    return true
end

local function OnTooltipCleared(tooltip)
    tooltipProcessed[tooltip] = nil
end

--[[
    Main tooltip hook handler
]]
local function OnTooltipSetItem(tooltip)
    -- Extract item ID early (needed for duplicate guard)
    local _, itemLink = tooltip:GetItem()
    if not itemLink then return end
    local itemId = tonumber(itemLink:match("item:(%d+)"))
    if not itemId then return end

    -- Prevent duplicate lines for same item (also handles profession recipe double-call)
    if tooltipProcessed[tooltip] == itemId then return end
    tooltipProcessed[tooltip] = itemId

    local settings = HopeAddon.db and HopeAddon.db.settings
    local bisEnabled = not settings or settings.tooltipBisEnabled ~= false
    local gsEnabled = not settings or settings.tooltipGearScoreEnabled ~= false
    if not bisEnabled and not gsEnabled then return end

    local modified = false

    -- BiS annotation
    if bisEnabled then
        local guideKey = C:GetCurrentPlayerGuideKey()
        if guideKey then
            BuildTooltipBisLookup(guideKey)
            local entries = tooltipBisLookup[itemId]
            if entries then
                AddBisLinesToTooltip(tooltip, entries)
                modified = true
            end
        end
    end

    -- Acquisition date annotation
    local acquisitions = HopeAddon.charDb and HopeAddon.charDb.gearAcquisitions
    if acquisitions then
        local acqData = acquisitions[itemId]
        if acqData and acqData.date then
            if not modified then
                tooltip:AddLine(" ")
                tooltip:AddLine("|cFF9B30FFHope Is Here|r")
            end
            local displayDate = C:FormatAppWideEventDate(acqData.date)
            tooltip:AddLine("  Acquired: " .. displayDate, 0.5, 0.8, 1.0)
            modified = true
        end
    end

    -- Gear score footer
    if gsEnabled then
        if AddGearScoreToTooltip(tooltip) then
            modified = true
        end
    end

    if modified then
        tooltip:Show()
    end
end

--[[
    Initialize tooltip hooks (called once on module enable)
]]
function TooltipEnhancer:Initialize()
    if tooltipHooked then return end
    tooltipHooked = true

    -- Hook item tooltips
    local tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2 }
    for _, tt in ipairs(tooltips) do
        tt:HookScript("OnTooltipSetItem", OnTooltipSetItem)
        tt:HookScript("OnTooltipCleared", OnTooltipCleared)
    end

    -- Warn about potential tooltip addon conflicts (matches FellowTravelers pattern)
    local tooltipAddons = { "TipTac", "TipTacTalents", "FreebTip", "Tukui", "ElvUI" }
    for _, addon in ipairs(tooltipAddons) do
        local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
        if loaded(addon) then
            HopeAddon:Debug("TooltipEnhancer: Tooltip display may conflict with " .. addon)
            break
        end
    end
end

--[[
    Module lifecycle
]]
function TooltipEnhancer:OnEnable()
    self:Initialize()
end

function TooltipEnhancer:InvalidateCache()
    tooltipLookupGuideKey = nil
end

HopeAddon:RegisterModule("TooltipEnhancer", TooltipEnhancer)
