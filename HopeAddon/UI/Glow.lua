--[[
    HopeAddon Glow Module
    Advanced glow effects for UI elements
]]

local Glow = {}
HopeAddon.Glow = Glow

-- Use centralized asset textures
local textures = HopeAddon.assets.textures

-- Active glow registry
Glow.registry = {}
-- Parent index for O(1) lookup when stopping glows by parent
-- Maps parent frame -> { glowId1, glowId2, ... }
Glow.glowsByParent = {}
local glowIdCounter = 0

--[[
    Create a unique glow ID
]]
local function GetNextGlowId()
    glowIdCounter = glowIdCounter + 1
    return "HopeGlow" .. glowIdCounter
end

--[[
    Add glow to parent index for O(1) lookup
]]
local function AddToParentIndex(parent, glowId)
    if not Glow.glowsByParent[parent] then
        Glow.glowsByParent[parent] = {}
    end
    table.insert(Glow.glowsByParent[parent], glowId)
end

--[[
    Remove glow from parent index
]]
local function RemoveFromParentIndex(parent, glowId)
    local parentGlows = Glow.glowsByParent[parent]
    if not parentGlows then return end

    for i, id in ipairs(parentGlows) do
        if id == glowId then
            table.remove(parentGlows, i)
            break
        end
    end

    -- Clean up empty tables
    if #parentGlows == 0 then
        Glow.glowsByParent[parent] = nil
    end
end

--[[
    ZONE-THEMED GLOWS
    Each Outland zone has a distinct color scheme
]]
Glow.zoneThemes = {
    ["Hellfire Peninsula"] = {
        primary = "HELLFIRE_ORANGE",
        secondary = "HELLFIRE_RED",
        accent = "FEL_GREEN",
    },
    ["Zangarmarsh"] = {
        primary = "OUTLAND_TEAL",
        secondary = "DEEP_BLUE",
        accent = "PINK_JOY",
    },
    ["Terokkar Forest"] = {
        primary = "NATURE_GREEN",
        secondary = "GOLD_PALE",
        accent = "VOID_PURPLE",
    },
    ["Nagrand"] = {
        primary = "SKY_BLUE",
        secondary = "NATURE_GREEN",
        accent = "GOLD_BRIGHT",
    },
    ["Blade's Edge Mountains"] = {
        primary = "BRONZE",
        secondary = "SHADOW_GREY",
        accent = "HELLFIRE_ORANGE",
    },
    ["Netherstorm"] = {
        primary = "NETHER_LAVENDER",
        secondary = "ARCANE_PURPLE",
        accent = "FROST_BLUE",
    },
    ["Shadowmoon Valley"] = {
        primary = "VOID_PURPLE",
        secondary = "FEL_GREEN",
        accent = "HELLFIRE_RED",
    },
    ["Shattrath City"] = {
        primary = "GOLD_BRIGHT",
        secondary = "ARCANE_PURPLE",
        accent = "SKY_BLUE",
    },
}

--[[
    Get zone-appropriate color
    @param zoneName string - Zone name
    @param colorType string - "primary", "secondary", or "accent"
]]
function Glow:GetZoneColor(zoneName, colorType)
    local theme = self.zoneThemes[zoneName]
    if theme then
        return theme[colorType] or "GOLD_BRIGHT"
    end
    return "GOLD_BRIGHT"
end

--[[
    Create an icon glow (for achievement/milestone icons)
    @param parent Frame - Parent frame
    @param colorName string - Color from HopeAddon.colors
    @param scale number - Size multiplier (default 1.5)
]]
function Glow:CreateIconGlow(parent, colorName, scale)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    -- Stop any existing glows on this parent to prevent accumulation
    self:StopAllFor(parent)

    scale = scale or 1.5
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    local glowId = GetNextGlowId()

    local glow = parent:CreateTexture(glowId, "OVERLAY", nil, 7)
    glow:SetTexture(textures.GLOW_ICON)
    glow:SetBlendMode("ADD")
    glow:SetSize(parent:GetWidth() * scale, parent:GetHeight() * scale)
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    glow:SetVertexColor(color.r, color.g, color.b, 0.7)

    -- Pulsing animation
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.4)
    pulse:SetToAlpha(0.9)
    pulse:SetDuration(0.7)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register
    self.registry[glowId] = {
        texture = glow,
        animGroup = ag,
        parent = parent,
        type = "icon",
    }
    AddToParentIndex(parent, glowId)

    return glowId
end

--[[
    Create a soft ambient glow (for backgrounds)
    @param parent Frame - Parent frame
    @param colorName string - Color name
    @param opacity number - Base opacity (0-1)
]]
function Glow:CreateAmbientGlow(parent, colorName, opacity)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    -- Stop any existing glows on this parent to prevent accumulation
    self:StopAllFor(parent)

    opacity = opacity or 0.4
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.ARCANE_PURPLE

    local glowId = GetNextGlowId()

    local glow = parent:CreateTexture(glowId, "BACKGROUND", nil, -8)
    glow:SetTexture(textures.GLOW_CIRCLE)
    glow:SetBlendMode("ADD")
    glow:SetSize(parent:GetWidth() * 2, parent:GetHeight() * 2)
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    glow:SetVertexColor(color.r, color.g, color.b, opacity)

    -- Very slow, subtle pulse
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(opacity * 0.6)
    pulse:SetToAlpha(opacity)
    pulse:SetDuration(3)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register
    self.registry[glowId] = {
        texture = glow,
        animGroup = ag,
        parent = parent,
        type = "ambient",
    }
    AddToParentIndex(parent, glowId)

    return glowId
end

--[[
    Create a ring glow (for circular icons/frames)
    @param parent Frame - Parent frame
    @param colorName string - Color name
    @param thickness number - Ring thickness
]]
function Glow:CreateRingGlow(parent, colorName, thickness)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    -- Stop any existing glows on this parent to prevent accumulation
    self:StopAllFor(parent)

    thickness = thickness or 4
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    local glowId = GetNextGlowId()

    -- Create a frame to hold the ring
    local ringFrame = CreateFrame("Frame", glowId, parent)
    ringFrame:SetAllPoints(parent)
    ringFrame:SetFrameLevel(parent:GetFrameLevel() + 1)

    -- Create four edge textures to form a ring
    local edges = {}
    local positions = {
        { point = "TOPLEFT", relPoint = "TOPLEFT", x = -thickness, y = thickness },
        { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = thickness, y = thickness },
        { point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = -thickness, y = -thickness },
        { point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = thickness, y = -thickness },
    }

    for i, pos in ipairs(positions) do
        local edge = ringFrame:CreateTexture(nil, "OVERLAY")
        edge:SetTexture(textures.GLOW_BUTTON)
        edge:SetBlendMode("ADD")
        edge:SetPoint(pos.point, parent, pos.relPoint, pos.x, pos.y)
        edge:SetSize(thickness * 2, thickness * 2)
        edge:SetVertexColor(color.r, color.g, color.b, 0.6)
        edges[i] = edge
    end

    -- Animation for all edges
    local ag = ringFrame:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.4)
    pulse:SetToAlpha(0.8)
    pulse:SetDuration(0.8)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register
    self.registry[glowId] = {
        frame = ringFrame,
        edges = edges,
        animGroup = ag,
        parent = parent,
        type = "ring",
    }
    AddToParentIndex(parent, glowId)

    return glowId
end

--[[
    Create a multi-layered epic glow (for major achievements)
    @param parent Frame - Parent frame
    @param colorName string - Primary color
]]
function Glow:CreateEpicGlow(parent, colorName)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    -- Stop any existing glows on this parent to prevent accumulation
    self:StopAllFor(parent)

    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    local glowId = GetNextGlowId()

    -- Layer 1: Outer ambient
    local outer = parent:CreateTexture(nil, "BACKGROUND", nil, -7)
    outer:SetTexture(textures.GLOW_CIRCLE)
    outer:SetBlendMode("ADD")
    outer:SetSize(parent:GetWidth() * 3, parent:GetHeight() * 3)
    outer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    outer:SetVertexColor(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.3)

    -- Layer 2: Middle glow
    local middle = parent:CreateTexture(nil, "BACKGROUND", nil, -6)
    middle:SetTexture(textures.GLOW_ICON)
    middle:SetBlendMode("ADD")
    middle:SetSize(parent:GetWidth() * 2, parent:GetHeight() * 2)
    middle:SetPoint("CENTER", parent, "CENTER", 0, 0)
    middle:SetVertexColor(color.r, color.g, color.b, 0.5)

    -- Layer 3: Inner bright
    local inner = parent:CreateTexture(nil, "OVERLAY", nil, 7)
    inner:SetTexture(textures.GLOW_STAR)
    inner:SetBlendMode("ADD")
    inner:SetSize(parent:GetWidth() * 0.5, parent:GetHeight() * 0.5)
    inner:SetPoint("CENTER", parent, "CENTER", 0, 0)
    inner:SetVertexColor(1, 1, 1, 0.8)

    -- Animations
    local agOuter = outer:CreateAnimationGroup()
    agOuter:SetLooping("BOUNCE")
    local pulseOuter = agOuter:CreateAnimation("Alpha")
    pulseOuter:SetFromAlpha(0.2)
    pulseOuter:SetToAlpha(0.4)
    pulseOuter:SetDuration(2)
    agOuter:Play()

    local agMiddle = middle:CreateAnimationGroup()
    agMiddle:SetLooping("BOUNCE")
    local pulseMiddle = agMiddle:CreateAnimation("Alpha")
    pulseMiddle:SetFromAlpha(0.3)
    pulseMiddle:SetToAlpha(0.6)
    pulseMiddle:SetDuration(1)
    agMiddle:Play()

    local agInner = inner:CreateAnimationGroup()
    agInner:SetLooping("REPEAT")
    local rotateInner = agInner:CreateAnimation("Rotation")
    rotateInner:SetDegrees(360)
    rotateInner:SetDuration(4)
    local pulseInner = agInner:CreateAnimation("Alpha")
    pulseInner:SetFromAlpha(0.5)
    pulseInner:SetToAlpha(1)
    pulseInner:SetDuration(0.5)
    agInner:Play()

    -- Register
    self.registry[glowId] = {
        layers = { outer, middle, inner },
        animGroups = { agOuter, agMiddle, agInner },
        parent = parent,
        type = "epic",
    }
    AddToParentIndex(parent, glowId)

    return glowId
end

--[[
    Stop and remove a glow
    @param glowId string - The glow ID returned from create functions
]]
function Glow:Stop(glowId)
    local glowData = self.registry[glowId]
    if not glowData then return end

    -- Remove from parent index
    if glowData.parent then
        RemoveFromParentIndex(glowData.parent, glowId)
    end

    -- Stop animations
    if glowData.animGroup then
        glowData.animGroup:Stop()
    end
    if glowData.animGroups then
        for _, ag in ipairs(glowData.animGroups) do
            ag:Stop()
        end
    end

    -- Hide textures
    if glowData.texture then
        glowData.texture:Hide()
    end
    if glowData.layers then
        for _, layer in ipairs(glowData.layers) do
            layer:Hide()
        end
    end
    if glowData.frame then
        glowData.frame:Hide()
    end
    if glowData.edges then
        for _, edge in ipairs(glowData.edges) do
            edge:Hide()
        end
    end

    -- Remove from registry
    self.registry[glowId] = nil
end

--[[
    Stop all glows for a parent frame (O(1) lookup via parent index)
    @param parent Frame - Parent frame
]]
function Glow:StopAllFor(parent)
    local glowIds = self.glowsByParent[parent]
    if not glowIds then return end

    -- Copy the list since Stop modifies glowsByParent
    local idsToStop = {}
    for _, glowId in ipairs(glowIds) do
        table.insert(idsToStop, glowId)
    end

    for _, glowId in ipairs(idsToStop) do
        self:Stop(glowId)
    end
end

--[[
    Stop all active glows
]]
function Glow:StopAll()
    for glowId in pairs(self.registry) do
        self:Stop(glowId)
    end
    -- Clear parent index (should already be empty, but ensure cleanup)
    self.glowsByParent = {}
end

--[[
    Update glow color
    @param glowId string - Glow ID
    @param colorName string - New color name
]]
function Glow:SetColor(glowId, colorName)
    local glowData = self.registry[glowId]
    if not glowData then return end

    local color = HopeAddon.colors[colorName]
    if not color then return end

    if glowData.texture then
        glowData.texture:SetVertexColor(color.r, color.g, color.b, glowData.texture:GetAlpha())
    end
    if glowData.layers then
        for _, layer in ipairs(glowData.layers) do
            layer:SetVertexColor(color.r, color.g, color.b, layer:GetAlpha())
        end
    end
end

--[[
    Module lifecycle
]]
function Glow:OnDisable()
    self:StopAll()
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Glow module loaded")
end
