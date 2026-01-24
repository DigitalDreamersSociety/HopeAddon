--[[
    HopeAddon Effects Module
    Handles all visual effects: glows, animations, particles
]]

-- Lua function caches for hot paths
local math_random = math.random
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local string_sub = string.sub

local Effects = {}

-- Export to HopeAddon namespace for direct access
HopeAddon.Effects = Effects

-- Cache for active effects
Effects.activeGlows = {}
Effects.glowsByParent = {}  -- O(1) lookup for glows by parent frame
Effects.activeAnimations = {}
Effects.frameSparkles = {}  -- Track sparkles per parent frame to prevent stacking

--[[
    GLOW EFFECTS
]]

-- Stop all glows on a specific parent frame using O(1) index lookup
function Effects:StopGlowsOnParent(parent)
    local parentGlows = self.glowsByParent[parent]
    if not parentGlows then return end

    for glowData in pairs(parentGlows) do
        if glowData.animGroup then
            glowData.animGroup:Stop()
        end
        if glowData.texture then
            glowData.texture:Hide()
            glowData.texture:SetParent(nil)
        end
        -- Handle dual border glow inner elements
        if glowData.innerTexture then
            glowData.innerTexture:Hide()
            glowData.innerTexture:SetParent(nil)
        end
        if glowData.innerFrame then
            glowData.innerFrame:Hide()
        end
        if glowData.frame then
            glowData.frame:Hide()
        end
        -- Remove from activeGlows array
        for i, glow in ipairs(self.activeGlows) do
            if glow == glowData then
                table.remove(self.activeGlows, i)
                break
            end
        end
    end

    self.glowsByParent[parent] = nil
end

-- Creates pulsing glow around a frame
function Effects:CreatePulsingGlow(parent, colorName, intensity)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    -- Validate parent can create textures (Frames can, FontStrings cannot)
    if not parent or not parent.CreateTexture then
        HopeAddon:Debug("CreatePulsingGlow: parent cannot create textures")
        return nil
    end

    -- Stop any existing glows on this parent to prevent stacking (O(1) lookup)
    self:StopGlowsOnParent(parent)

    intensity = intensity or 1.0
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    local glow = parent:CreateTexture(nil, "OVERLAY")
    glow:SetTexture(HopeAddon.assets.textures.GLOW_ICON)
    glow:SetBlendMode("ADD")
    glow:SetSize(parent:GetWidth() * 1.4, parent:GetHeight() * 1.4)
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    glow:SetVertexColor(color.r, color.g, color.b, 0.7 * intensity)

    -- Animation
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.3 * intensity)
    pulse:SetToAlpha(0.8 * intensity)
    pulse:SetDuration(0.8)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Store reference for cleanup
    local glowData = { texture = glow, animGroup = ag, parent = parent }
    table.insert(self.activeGlows, glowData)

    -- Register in parent index for O(1) lookup
    if not self.glowsByParent[parent] then
        self.glowsByParent[parent] = {}
    end
    self.glowsByParent[parent][glowData] = true

    return glowData
end

-- Creates burst effect (one-time, for achievements)
function Effects:CreateBurstEffect(parent, colorName)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    -- Star burst
    local burst = parent:CreateTexture(nil, "OVERLAY")
    burst:SetTexture(HopeAddon.assets.textures.GLOW_STAR)
    burst:SetBlendMode("ADD")
    burst:SetPoint("CENTER", parent, "CENTER", 0, 0)
    burst:SetSize(16, 16)
    burst:SetVertexColor(color.r, color.g, color.b, 1)

    local ag = burst:CreateAnimationGroup()

    -- Scale up dramatically
    local scale = ag:CreateAnimation("Scale")
    scale:SetScale(6, 6)
    scale:SetDuration(0.4)
    scale:SetSmoothing("OUT")

    -- Spin
    local spin = ag:CreateAnimation("Rotation")
    spin:SetDegrees(180)
    spin:SetDuration(0.4)

    -- Fade out
    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    fade:SetDuration(0.4)
    fade:SetStartDelay(0.2)

    ag:SetScript("OnFinished", function()
        burst:Hide()
        burst:SetParent(nil)
    end)

    ag:Play()

    return burst
end

-- Creates fel green glow (Outland theme)
function Effects:CreateFelGlow(parent)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    local glow = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
    glow:SetTexture(HopeAddon.assets.textures.GLOW_CIRCLE)
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    glow:SetSize(parent:GetWidth() * 2, parent:GetHeight() * 2)
    glow:SetVertexColor(0.2, 0.8, 0.2, 0.5) -- Fel green

    -- Slow pulse
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.3)
    pulse:SetToAlpha(0.6)
    pulse:SetDuration(2)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register for cleanup
    local glowData = { texture = glow, animGroup = ag, parent = parent }
    table.insert(self.activeGlows, glowData)

    -- Register in parent index for O(1) lookup
    if not self.glowsByParent[parent] then
        self.glowsByParent[parent] = {}
    end
    self.glowsByParent[parent][glowData] = true

    return glowData
end

-- Creates border glow
function Effects:CreateBorderGlow(parent, colorName)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT

    local glowFrame = CreateFrame("Frame", nil, parent)
    glowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 3)
    glowFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 3, -3)
    glowFrame:SetFrameLevel(math_max(1, parent:GetFrameLevel() - 1))

    local glow = glowFrame:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    glow:SetBlendMode("ADD")
    glow:SetAllPoints(glowFrame)
    glow:SetVertexColor(color.r, color.g, color.b, 0.6)

    -- Pulse
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.4)
    pulse:SetToAlpha(0.8)
    pulse:SetDuration(1)

    ag:Play()

    -- Register for cleanup
    local glowData = { frame = glowFrame, texture = glow, animGroup = ag, parent = parent }
    table.insert(self.activeGlows, glowData)

    -- Register in parent index for O(1) lookup
    if not self.glowsByParent[parent] then
        self.glowsByParent[parent] = {}
    end
    self.glowsByParent[parent][glowData] = true

    return glowData
end

-- Creates dual-layer border glow (inner + outer colors)
-- Used for TBC-themed sections with contrasting glow effects
function Effects:CreateDualBorderGlow(parent, innerColorName, outerColorName, intensity)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    intensity = intensity or 1.0
    local innerColor = HopeAddon.colors[innerColorName] or HopeAddon.colors.ARCANE_PURPLE
    local outerColor = HopeAddon.colors[outerColorName] or HopeAddon.colors.FEL_GREEN

    -- Outer glow (larger, softer)
    local outerGlowFrame = CreateFrame("Frame", nil, parent)
    outerGlowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -6, 6)
    outerGlowFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 6, -6)
    outerGlowFrame:SetFrameLevel(math_max(1, parent:GetFrameLevel() - 2))

    local outerGlow = outerGlowFrame:CreateTexture(nil, "BACKGROUND")
    outerGlow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    outerGlow:SetBlendMode("ADD")
    outerGlow:SetAllPoints(outerGlowFrame)
    outerGlow:SetVertexColor(outerColor.r, outerColor.g, outerColor.b, 0.35 * intensity)

    -- Inner glow (tighter to border)
    local innerGlowFrame = CreateFrame("Frame", nil, parent)
    innerGlowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 3)
    innerGlowFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 3, -3)
    innerGlowFrame:SetFrameLevel(math_max(1, parent:GetFrameLevel() - 1))

    local innerGlow = innerGlowFrame:CreateTexture(nil, "BACKGROUND")
    innerGlow:SetTexture(HopeAddon.assets.textures.GLOW_BUTTON)
    innerGlow:SetBlendMode("ADD")
    innerGlow:SetAllPoints(innerGlowFrame)
    innerGlow:SetVertexColor(innerColor.r, innerColor.g, innerColor.b, 0.5 * intensity)

    -- Subtle pulse on outer glow only
    local ag = outerGlow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.25 * intensity)
    pulse:SetToAlpha(0.45 * intensity)
    pulse:SetDuration(1.5)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register for cleanup
    local glowData = {
        frame = outerGlowFrame,
        innerFrame = innerGlowFrame,
        texture = outerGlow,
        innerTexture = innerGlow,
        animGroup = ag,
        parent = parent
    }
    table.insert(self.activeGlows, glowData)

    -- Register in parent index for O(1) lookup
    if not self.glowsByParent[parent] then
        self.glowsByParent[parent] = {}
    end
    self.glowsByParent[parent][glowData] = true

    return glowData
end

-- Creates arcane/purple glow (for Karazhan content)
function Effects:CreateArcaneGlow(parent)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return nil
    end

    local color = HopeAddon.colors.ARCANE_PURPLE

    local glow = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
    glow:SetTexture(HopeAddon.assets.textures.GLOW_CIRCLE)
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER", parent, "CENTER", 0, 0)
    glow:SetSize(parent:GetWidth() * 1.8, parent:GetHeight() * 1.8)
    glow:SetVertexColor(color.r, color.g, color.b, 0.4)

    -- Slow pulse
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Alpha")
    pulse:SetFromAlpha(0.2)
    pulse:SetToAlpha(0.5)
    pulse:SetDuration(1.5)
    pulse:SetSmoothing("IN_OUT")

    ag:Play()

    -- Register for cleanup
    local glowData = { texture = glow, animGroup = ag, parent = parent }
    table.insert(self.activeGlows, glowData)

    -- Register in parent index for O(1) lookup
    if not self.glowsByParent[parent] then
        self.glowsByParent[parent] = {}
    end
    self.glowsByParent[parent][glowData] = true

    return glowData
end

--[[
    SPARKLE EFFECTS
]]

-- Creates floating sparkles
function Effects:CreateSparkles(parent, count, colorName)
    if HopeAddon.db and not HopeAddon.db.settings.glowEnabled then
        return {}
    end

    -- Stop any existing sparkles on this parent to prevent stacking
    if self.frameSparkles[parent] then
        self:StopSparkles(self.frameSparkles[parent])
        self.frameSparkles[parent] = nil
    end

    count = count or 5
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT
    local sparkles = {}

    for i = 1, count do
        local spark = parent:CreateTexture(nil, "OVERLAY")
        spark:SetTexture(HopeAddon.assets.textures.GLOW_STAR)
        spark:SetBlendMode("ADD")
        spark:SetSize(6 + math_random(4), 6 + math_random(4))
        spark:SetVertexColor(color.r, color.g, color.b, 0.8)

        -- Random starting position
        local xOff = math_random(-math_floor(parent:GetWidth()/2), math_floor(parent:GetWidth()/2))
        local yOff = math_random(-math_floor(parent:GetHeight()/2), math_floor(parent:GetHeight()/2))
        spark:SetPoint("CENTER", parent, "CENTER", xOff, yOff)

        -- Animation group
        local ag = spark:CreateAnimationGroup()
        ag:SetLooping("REPEAT")

        -- Float upward
        local move = ag:CreateAnimation("Translation")
        move:SetOffset(math_random(-10, 10), 20 + math_random(20))
        move:SetDuration(1.5 + math_random() * 1.5)
        move:SetSmoothing("OUT")

        -- Fade cycle
        local fadeIn = ag:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8)
        fadeIn:SetDuration(0.5)
        fadeIn:SetOrder(1)

        local fadeOut = ag:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.5)
        fadeOut:SetOrder(2)
        fadeOut:SetStartDelay(1 + math_random())

        -- Stagger start times (store timer handle for proper cancellation)
        local timerHandle = HopeAddon.Timer:After(math_random() * 2, function()
            if spark and spark:IsShown() then
                ag:Play()
            end
        end)

        table.insert(sparkles, { texture = spark, animGroup = ag, startupTimer = timerHandle })
    end

    -- Track sparkles for this parent to prevent stacking on subsequent calls
    self.frameSparkles[parent] = sparkles

    return sparkles
end

--[[
    TEXT ANIMATIONS
]]

-- Typewriter effect for text
function Effects:TypewriterText(fontString, text, speed, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        fontString:SetText(text)
        if callback then callback() end
        return nil
    end

    speed = speed or 0.03 -- seconds per character
    local currentIndex = 0
    local fullText = text

    fontString:SetText("")

    local ticker
    ticker = HopeAddon.Timer:NewTicker(speed, function()
        currentIndex = currentIndex + 1
        if currentIndex <= #fullText then
            fontString:SetText(string_sub(fullText, 1, currentIndex))
        else
            ticker:Cancel()
            if callback then
                callback()
            end
        end
    end)

    return ticker
end

-- Fade in frame
function Effects:FadeIn(frame, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:SetAlpha(1)
        frame:Show()
        if callback then callback() end
        return nil
    end

    -- Stop any existing fade animation on this frame to prevent overlap
    if frame._fadeAnimGroup then
        frame._fadeAnimGroup:Stop()
    end

    duration = duration or 0.3
    frame:SetAlpha(0)
    frame:Show()

    local ag = frame:CreateAnimationGroup()
    frame._fadeAnimGroup = ag
    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetDuration(duration)
    fade:SetSmoothing("OUT")

    ag:SetScript("OnFinished", function()
        frame:SetAlpha(1)
        frame._fadeAnimGroup = nil  -- Clear reference on completion
        if callback then callback() end
    end)

    ag:Play()
    return ag
end

-- Fade out frame
function Effects:FadeOut(frame, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:Hide()
        frame:SetAlpha(1)
        if callback then callback() end
        return nil
    end

    -- Stop any existing fade animation on this frame to prevent overlap
    if frame._fadeAnimGroup then
        frame._fadeAnimGroup:Stop()
    end

    duration = duration or 0.3

    local ag = frame:CreateAnimationGroup()
    frame._fadeAnimGroup = ag
    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(frame:GetAlpha())
    fade:SetToAlpha(0)
    fade:SetDuration(duration)
    fade:SetSmoothing("IN")

    ag:SetScript("OnFinished", function()
        frame:Hide()
        frame:SetAlpha(1)
        frame._fadeAnimGroup = nil  -- Clear reference on completion
        if callback then callback() end
    end)

    ag:Play()
    return ag
end

-- Slide in from side
function Effects:SlideIn(frame, direction, distance, duration)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:SetAlpha(1)
        frame:Show()
        return nil
    end

    -- Stop any existing slide animation on this frame to prevent overlap
    if frame._slideAnimGroup then
        frame._slideAnimGroup:Stop()
    end

    direction = direction or "LEFT"
    distance = distance or 100
    duration = duration or 0.3

    local xOff, yOff = 0, 0
    if direction == "LEFT" then xOff = -distance
    elseif direction == "RIGHT" then xOff = distance
    elseif direction == "TOP" then yOff = distance
    elseif direction == "BOTTOM" then yOff = -distance
    end

    frame:SetAlpha(0)
    frame:Show()

    local ag = frame:CreateAnimationGroup()
    frame._slideAnimGroup = ag  -- Store for cleanup

    local move = ag:CreateAnimation("Translation")
    move:SetOffset(-xOff, -yOff) -- Reverse to slide TO position
    move:SetDuration(duration)
    move:SetSmoothing("OUT")

    local fade = ag:CreateAnimation("Alpha")
    fade:SetFromAlpha(0)
    fade:SetToAlpha(1)
    fade:SetDuration(duration)

    -- Set starting offset
    local point, relativeTo, relativePoint, x, y = frame:GetPoint()
    if point then
        frame:SetPoint(point, relativeTo, relativePoint, (x or 0) + xOff, (y or 0) + yOff)

        ag:SetScript("OnFinished", function()
            frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
            frame:SetAlpha(1)
            frame._slideAnimGroup = nil  -- Clear reference on completion
        end)
    end

    ag:Play()
    return ag
end

-- Scale pop effect (for achievements/milestones)
-- TBC Compatible: Uses Timer instead of Scale animations (SetFromScale doesn't exist in 2.4.3)
function Effects:PopIn(frame, duration)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:SetAlpha(1)
        frame:Show()
        return nil
    end

    duration = duration or 0.3
    frame:SetAlpha(0)
    frame:Show()

    local elapsed = 0
    local phase1Duration = duration * 0.6  -- Scale up phase
    local phase2Duration = duration * 0.4  -- Scale down phase
    local totalDuration = duration

    -- Start small
    frame:SetScale(0.5)

    local ticker
    ticker = HopeAddon.Timer:NewTicker(0.016, function()  -- ~60fps
        elapsed = elapsed + 0.016

        if elapsed >= totalDuration then
            -- Finished - set final state
            frame:SetScale(1.0)
            frame:SetAlpha(1)
            ticker:Cancel()
            return
        end

        -- Calculate alpha (fade in during first 30% of duration)
        local fadeProgress = math_min(1, elapsed / (duration * 0.3))
        frame:SetAlpha(fadeProgress)

        -- Calculate scale
        if elapsed < phase1Duration then
            -- Phase 1: Scale from 0.5 to 1.1
            local progress = elapsed / phase1Duration
            local eased = 1 - (1 - progress) * (1 - progress)  -- easeOutQuad
            local scale = 0.5 + (1.1 - 0.5) * eased
            frame:SetScale(scale)
        else
            -- Phase 2: Scale from 1.1 to 1.0
            local progress = (elapsed - phase1Duration) / phase2Duration
            local eased = progress * (2 - progress)  -- easeInOutQuad approximation
            local scale = 1.1 - (1.1 - 1.0) * eased
            frame:SetScale(scale)
        end
    end)

    return ticker
end

-- Shake effect (for errors or dramatic moments)
-- Uses 0.05s interval (20fps) - sufficient for shake visual effect
function Effects:Shake(frame, intensity, duration)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        return nil
    end

    intensity = intensity or 5
    duration = duration or 0.5
    local elapsed = 0
    local originalX, originalY

    local point, relativeTo, relativePoint, x, y = frame:GetPoint()
    originalX, originalY = x or 0, y or 0

    local ticker
    ticker = HopeAddon.Timer:NewTicker(0.05, function()
        elapsed = elapsed + 0.05
        if elapsed >= duration then
            frame:SetPoint(point, relativeTo, relativePoint, originalX, originalY)
            ticker:Cancel()
            return
        end

        local progress = elapsed / duration
        local currentIntensity = intensity * (1 - progress)
        local offsetX = math_random(-currentIntensity, currentIntensity)
        local offsetY = math_random(-currentIntensity, currentIntensity)

        frame:SetPoint(point, relativeTo, relativePoint, originalX + offsetX, originalY + offsetY)
    end)

    return ticker
end

--[[
    CLEANUP
]]

function Effects:StopAllGlows()
    for _, glowData in ipairs(self.activeGlows) do
        if glowData.animGroup then
            glowData.animGroup:Stop()
        end
        if glowData.texture then
            glowData.texture:Hide()
        end
    end
    self.activeGlows = {}
    self.glowsByParent = {}  -- Clear parent index
end

function Effects:StopGlow(glowData)
    if not glowData then return end

    if glowData.animGroup then
        glowData.animGroup:Stop()
    end
    if glowData.texture then
        glowData.texture:Hide()
    end
    if glowData.frame then
        glowData.frame:Hide()
    end

    -- Remove from parent index (O(1))
    local parent = glowData.parent
    if parent and self.glowsByParent[parent] then
        self.glowsByParent[parent][glowData] = nil
        -- Clean up empty parent entry
        if not next(self.glowsByParent[parent]) then
            self.glowsByParent[parent] = nil
        end
    end

    -- Remove from active list
    for i, glow in ipairs(self.activeGlows) do
        if glow == glowData then
            table.remove(self.activeGlows, i)
            break
        end
    end
end

-- Clean up sparkles
function Effects:StopSparkles(sparkles)
    if not sparkles then return end

    for _, sparkData in ipairs(sparkles) do
        -- Cancel any pending startup timers
        if sparkData.startupTimer and sparkData.startupTimer.Cancel then
            sparkData.startupTimer:Cancel()
        end
        if sparkData.animGroup then
            sparkData.animGroup:Stop()
        end
        if sparkData.texture then
            sparkData.texture:Hide()
            sparkData.texture:SetParent(nil)
        end
    end
end

--[[
    COMPOSITE EFFECTS
    Combine multiple effects for common scenarios
]]

--[[
    Celebration effect: glow + sparkles + sound
    Perfect for achievements, level-ups, quest completions

    @param frame Frame - Frame to celebrate
    @param duration number - Duration in seconds (default 2.0)
    @param options table - Optional { colorName, soundOverride }
]]
function Effects:Celebrate(frame, duration, options)
    if not frame then return end

    -- If passed a FontString or Texture, use its parent frame instead
    -- (FontStrings/Textures don't have CreateTexture method needed for glow effects)
    if frame.GetObjectType and (frame:GetObjectType() == "FontString" or frame:GetObjectType() == "Texture") then
        frame = frame:GetParent()
        if not frame then return end
    end

    duration = duration or 2.0
    options = options or {}
    local colorName = options.colorName or "GOLD_BRIGHT"

    -- Stop any existing effects on this frame first
    self:StopGlowsOnParent(frame)
    if self.frameSparkles[frame] then
        self:StopSparkles(self.frameSparkles[frame])
        self.frameSparkles[frame] = nil
    end

    -- Create pulsing glow effect
    self:CreatePulsingGlow(frame, colorName, 0.8)

    -- Add sparkles
    local sparkles = self:CreateSparkles(frame, 8, colorName)

    -- Victory sound
    if HopeAddon.Sounds and not options.soundOverride then
        HopeAddon.Sounds:PlayVictory()
    elseif options.soundOverride and HopeAddon.Sounds then
        options.soundOverride()
    end

    -- Auto-cleanup after duration
    if duration and duration > 0 then
        HopeAddon.Timer:After(duration, function()
            self:StopGlowsOnParent(frame)
            if sparkles then
                self:StopSparkles(sparkles)
                self.frameSparkles[frame] = nil
            end
        end)
    end
end

--[[
    Icon glow effect (shorter celebration for icons/badges)
    @param frame Frame - Icon frame
    @param duration number - Duration in seconds (default 1.5)
]]
function Effects:IconGlow(frame, duration)
    if not frame then return end
    duration = duration or 1.5

    -- Create subtle glow
    self:CreateBorderGlow(frame, "GOLD_BRIGHT")

    -- Auto-cleanup
    HopeAddon.Timer:After(duration, function()
        self:StopGlowsOnParent(frame)
    end)
end

--[[
    Progress completion sparkles
    Specifically for progress bars reaching 100%

    @param progressBar Frame - Progress bar frame
    @param duration number - Duration in seconds (default 1.5)
]]
function Effects:ProgressSparkles(progressBar, duration)
    if not progressBar then return end
    duration = duration or 1.5

    -- Create sparkles at the progress bar
    local sparkles = self:CreateSparkles(progressBar, 6, "GOLD_BRIGHT")

    -- Small sound effect
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlaySuccess()
    end

    -- Auto-cleanup
    HopeAddon.Timer:After(duration, function()
        if sparkles then
            self:StopSparkles(sparkles)
            self.frameSparkles[progressBar] = nil
        end
    end)
end

-- Module lifecycle hooks
function Effects:OnInitialize()
    -- No initialization needed
end

function Effects:OnEnable()
    -- No enable logic needed
end

function Effects:OnDisable()
    self:StopAllGlows()

    -- Clean up all sparkles and their timers
    for parent, sparkles in pairs(self.frameSparkles or {}) do
        self:StopSparkles(sparkles)
    end
    self.frameSparkles = {}

    -- Clear active animations reference
    self.activeAnimations = {}
end

-- Register with addon
HopeAddon:RegisterModule("Effects", Effects)

if HopeAddon.Debug then
    HopeAddon:Debug("Effects module loaded")
end
