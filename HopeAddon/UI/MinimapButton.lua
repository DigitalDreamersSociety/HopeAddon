--[[
    HopeAddon Minimap Button
    Draggable minimap button to toggle the journal
]]

local MinimapButton = {}
HopeAddon:RegisterModule("MinimapButton", MinimapButton)

-- Constants
local BUTTON_SIZE = 31
local MINIMAP_RADIUS = 78  -- Tighter to minimap edge
local DEFAULT_POSITION = 225  -- Degrees, lower-left area

-- Local references
local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_deg = math.deg

-- Button frame reference
local button = nil

--[[
    Calculate button position from angle
]]
local function GetPositionFromAngle(angle)
    local rads = math_rad(angle)
    local x = math_cos(rads) * MINIMAP_RADIUS
    local y = math_sin(rads) * MINIMAP_RADIUS
    return x, y
end

--[[
    Calculate angle from cursor position relative to minimap center
]]
local function GetAngleFromCursor()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale

    local dx = cx - mx
    local dy = cy - my

    local angle = math_deg(math_atan2(dy, dx))
    if angle < 0 then
        angle = angle + 360
    end

    return angle
end

--[[
    Update button position on minimap edge
]]
function MinimapButton:UpdatePosition()
    if not button then return end

    local db = HopeAddon.db
    local angle = (db and db.minimapButton and db.minimapButton.position) or DEFAULT_POSITION

    local x, y = GetPositionFromAngle(angle)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

--[[
    Create the minimap button
]]
function MinimapButton:CreateButton()
    if button then return end

    -- Create the button frame
    button = CreateFrame("Button", "HopeAddonMinimapButton", Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    -- Enable mouse and dragging
    button:EnableMouse(true)
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Use the circular tracking icon (already properly sized/shaped)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Minimap\\Tracking\\Poisons")  -- Green vial - TBC fel vibes
    button.icon = icon

    -- Border ring
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border

    -- Highlight (circular glow)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetSize(24, 24)
    highlight:SetPoint("CENTER", 0, 0)
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    -- Mask to circle using tex coords that crop to center
    highlight:SetTexCoord(0.22, 0.78, 0.22, 0.78)
    button.highlight = highlight

    -- Click handler
    button:SetScript("OnClick", function(self, clickButton)
        if clickButton == "LeftButton" then
            HopeAddon:ToggleJournal()
        elseif clickButton == "RightButton" then
            -- Right-click could open options in the future
            HopeAddon:Print("Left-click to open journal. Drag to move.")
        end
    end)

    -- Drag handlers
    button:SetScript("OnDragStart", function(self)
        self.isDragging = true
        self:SetScript("OnUpdate", function(self)
            if self.isDragging then
                local angle = GetAngleFromCursor()
                local x, y = GetPositionFromAngle(angle)
                self:ClearAllPoints()
                self:SetPoint("CENTER", Minimap, "CENTER", x, y)
            end
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)

        -- Save the new position
        local angle = GetAngleFromCursor()
        if HopeAddon.db then
            HopeAddon.db.minimapButton = HopeAddon.db.minimapButton or {}
            HopeAddon.db.minimapButton.position = angle
        end
    end)

    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cff9B30FFHope Is Here|r", 1, 1, 1)
        GameTooltip:AddLine("Your TBC Journey Journal", 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFD700Left-click|r to open journal", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cFFFFD700Drag|r to move me around", 0.9, 0.9, 0.9)
        GameTooltip:Show()

        -- Play hover sound
        if HopeAddon.Sounds and HopeAddon.Sounds.PlayHover then
            HopeAddon.Sounds:PlayHover()
        end
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    self.button = button
end

--[[
    Show/hide the minimap button
]]
function MinimapButton:SetEnabled(enabled)
    if not button then return end

    if enabled then
        button:Show()
    else
        button:Hide()
    end

    if HopeAddon.db then
        HopeAddon.db.minimapButton = HopeAddon.db.minimapButton or {}
        HopeAddon.db.minimapButton.enabled = enabled
    end
end

--[[
    Toggle minimap button visibility
]]
function MinimapButton:Toggle()
    if not button then return end

    local isShown = button:IsShown()
    self:SetEnabled(not isShown)

    if isShown then
        HopeAddon:Print("Minimap button hidden. Use /hope minimap to show.")
    else
        HopeAddon:Print("Minimap button shown.")
    end
end

--[[
    Module lifecycle
]]
function MinimapButton:OnInitialize()
    -- Nothing needed here
end

function MinimapButton:OnEnable()
    self:CreateButton()
    self:UpdatePosition()

    -- Check if button should be hidden
    local db = HopeAddon.db
    if db and db.minimapButton and db.minimapButton.enabled == false then
        button:Hide()
    end
end

function MinimapButton:OnDisable()
    if button then
        button:Hide()
    end
end
