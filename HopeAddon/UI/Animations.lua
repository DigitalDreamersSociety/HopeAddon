--[[
    HopeAddon Animations Module
    Animation utilities and preset animations
]]

local Animations = {}
HopeAddon.Animations = Animations

-- Animation registry for cleanup
Animations.active = {}
Animations.pageFlipTimers = {}  -- Store PageFlip timer handles

--[[
    EASING FUNCTIONS
    For custom animation curves
]]
Animations.easing = {
    -- Linear
    linear = function(t) return t end,

    -- Quadratic
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t)
        if t < 0.5 then return 2 * t * t end
        return -1 + (4 - 2 * t) * t
    end,

    -- Cubic
    easeInCubic = function(t) return t * t * t end,
    easeOutCubic = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end,
    easeInOutCubic = function(t)
        if t < 0.5 then return 4 * t * t * t end
        return (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
    end,

    -- Bounce
    easeOutBounce = function(t)
        if t < 1/2.75 then
            return 7.5625 * t * t
        elseif t < 2/2.75 then
            t = t - 1.5/2.75
            return 7.5625 * t * t + 0.75
        elseif t < 2.5/2.75 then
            t = t - 2.25/2.75
            return 7.5625 * t * t + 0.9375
        else
            t = t - 2.625/2.75
            return 7.5625 * t * t + 0.984375
        end
    end,

    -- Elastic
    easeOutElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        local p = 0.3
        local s = p / 4
        return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1
    end,
}

--[[
    Generic tween function
    @param duration number - Animation duration in seconds
    @param onUpdate function - Called each frame with (progress, value)
    @param onComplete function - Called when animation finishes
    @param easingFunc function - Easing function (optional)
]]
-- Animation tick interval: 30fps (0.033s) is sufficient for smooth animations
-- and reduces CPU usage compared to 60fps (0.016s)
local ANIM_TICK_INTERVAL = 0.033

function Animations:Tween(duration, onUpdate, onComplete, easingFunc)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        if onUpdate then onUpdate(1, 1) end
        if onComplete then onComplete() end
        return nil
    end

    easingFunc = easingFunc or self.easing.easeOutQuad
    local elapsed = 0

    local ticker
    ticker = HopeAddon.Timer:NewTicker(ANIM_TICK_INTERVAL, function() -- ~30fps
        elapsed = elapsed + ANIM_TICK_INTERVAL
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = easingFunc(progress)

        if onUpdate then
            onUpdate(progress, easedProgress)
        end

        if progress >= 1 then
            ticker:Cancel()
            -- Remove from active table to prevent memory leak
            for i, t in ipairs(Animations.active) do
                if t == ticker then
                    table.remove(Animations.active, i)
                    break
                end
            end
            if onComplete then
                onComplete()
            end
        end
    end)

    table.insert(self.active, ticker)
    return ticker
end

--[[
    Animate a value from start to end
    @param startVal number - Starting value
    @param endVal number - Ending value
    @param duration number - Duration in seconds
    @param onUpdate function - Called with current value
    @param onComplete function - Called when done
]]
function Animations:AnimateValue(startVal, endVal, duration, onUpdate, onComplete)
    return self:Tween(duration, function(progress, eased)
        local current = startVal + (endVal - startVal) * eased
        if onUpdate then onUpdate(current) end
    end, onComplete)
end

--[[
    Animate frame position
    @param frame Frame - Frame to animate
    @param targetX number - Target X offset
    @param targetY number - Target Y offset
    @param duration number - Duration
    @param callback function - Called when done
]]
function Animations:MoveTo(frame, targetX, targetY, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        local point, relativeTo, relativePoint = frame:GetPoint()
        frame:SetPoint(point, relativeTo, relativePoint, targetX, targetY)
        if callback then callback() end
        return nil
    end

    local point, relativeTo, relativePoint, startX, startY = frame:GetPoint()
    startX = startX or 0
    startY = startY or 0

    return self:Tween(duration, function(progress, eased)
        local currentX = startX + (targetX - startX) * eased
        local currentY = startY + (targetY - startY) * eased
        frame:SetPoint(point, relativeTo, relativePoint, currentX, currentY)
    end, callback)
end

--[[
    Animate frame size
    @param frame Frame - Frame to animate
    @param targetWidth number - Target width
    @param targetHeight number - Target height
    @param duration number - Duration
    @param callback function - Called when done
]]
function Animations:ResizeTo(frame, targetWidth, targetHeight, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:SetSize(targetWidth, targetHeight)
        if callback then callback() end
        return nil
    end

    local startWidth = frame:GetWidth()
    local startHeight = frame:GetHeight()

    return self:Tween(duration, function(progress, eased)
        local currentWidth = startWidth + (targetWidth - startWidth) * eased
        local currentHeight = startHeight + (targetHeight - startHeight) * eased
        frame:SetSize(currentWidth, currentHeight)
    end, callback)
end

--[[
    Animate frame alpha
    @param frame Frame - Frame to animate
    @param targetAlpha number - Target alpha (0-1)
    @param duration number - Duration
    @param callback function - Called when done
]]
function Animations:FadeTo(frame, targetAlpha, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        frame:SetAlpha(targetAlpha)
        if callback then callback() end
        return nil
    end

    local startAlpha = frame:GetAlpha()

    return self:Tween(duration, function(progress, eased)
        local currentAlpha = startAlpha + (targetAlpha - startAlpha) * eased
        frame:SetAlpha(currentAlpha)
    end, callback)
end

--[[
    PRESET ANIMATIONS
]]

-- Page flip animation (for journal)
function Animations:PageFlip(oldPage, newPage, direction, duration, callback)
    duration = duration or 0.4
    direction = direction or "left" -- "left" or "right"

    -- Cancel any previous page flip timers to prevent stacking
    for _, handle in ipairs(self.pageFlipTimers) do
        if handle and handle.Cancel then handle:Cancel() end
    end
    self.pageFlipTimers = {}

    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        if oldPage then oldPage:Hide() end
        if newPage then
            newPage:SetAlpha(1)
            newPage:Show()
        end
        if callback then callback() end
        return
    end

    local dirMult = direction == "left" and -1 or 1
    local distance = 50

    -- Hide old page
    if oldPage then
        self:Tween(duration * 0.5, function(progress, eased)
            oldPage:SetAlpha(1 - eased)
            local point, relativeTo, relativePoint, x, y = oldPage:GetPoint()
            if point then
                oldPage:SetPoint(point, relativeTo, relativePoint, (x or 0) + (distance * dirMult * eased), y or 0)
            end
        end, function()
            oldPage:Hide()
        end)
    end

    -- Show new page
    if newPage then
        local point, relativeTo, relativePoint, x, y = newPage:GetPoint()
        newPage:SetAlpha(0)
        newPage:Show()

        local handle1 = HopeAddon.Timer:After(duration * 0.3, function()
            self:Tween(duration * 0.5, function(progress, eased)
                newPage:SetAlpha(eased)
            end, function()
                -- Clear timer references on completion
                self.pageFlipTimers = {}
                if callback then callback() end
            end)
        end)
        table.insert(self.pageFlipTimers, handle1)
    else
        if callback then
            local handle2 = HopeAddon.Timer:After(duration, function()
                -- Clear timer references on completion
                self.pageFlipTimers = {}
                callback()
            end)
            table.insert(self.pageFlipTimers, handle2)
        end
    end

    HopeAddon.Sounds:PlayPageTurn()
end

-- Achievement celebration
function Animations:CelebrateAchievement(frame, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        if callback then callback() end
        return
    end

    -- Scale up then bounce back
    local originalWidth = frame:GetWidth()
    local originalHeight = frame:GetHeight()

    -- Phase 1: Scale up
    self:Tween(0.15, function(progress, eased)
        local scale = 1 + (0.2 * eased)
        frame:SetSize(originalWidth * scale, originalHeight * scale)
    end, function()
        -- Phase 2: Bounce back with overshoot
        self:Tween(0.25, function(progress, eased)
            local bounceEased = self.easing.easeOutElastic(progress)
            local scale = 1.2 - (0.2 * bounceEased)
            frame:SetSize(originalWidth * scale, originalHeight * scale)
        end, function()
            frame:SetSize(originalWidth, originalHeight)
            if callback then callback() end
        end)
    end)
end

-- Notification slide in from top
function Animations:NotificationSlideIn(frame, callback)
    local targetY = -100
    local startY = 50

    frame:SetAlpha(0)
    frame:Show()

    local point, relativeTo, relativePoint = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, startY)

    self:Tween(0.4, function(progress, eased)
        local currentY = startY + (targetY - startY) * eased
        frame:SetPoint("TOP", UIParent, "TOP", 0, currentY)
        frame:SetAlpha(eased)
    end, callback, self.easing.easeOutCubic)
end

-- Notification slide out
function Animations:NotificationSlideOut(frame, callback)
    local startY = -100
    local targetY = 50

    self:Tween(0.3, function(progress, eased)
        local currentY = startY + (targetY - startY) * eased
        frame:SetPoint("TOP", UIParent, "TOP", 0, currentY)
        frame:SetAlpha(1 - eased)
    end, function()
        frame:Hide()
        if callback then callback() end
    end, self.easing.easeInCubic)
end

-- Number counter animation (for stats)
function Animations:CountUp(fontString, startVal, endVal, duration, formatFunc)
    formatFunc = formatFunc or function(v) return tostring(math.floor(v)) end

    self:AnimateValue(startVal, endVal, duration, function(current)
        fontString:SetText(formatFunc(current))
    end)
end

-- Shake effect
function Animations:Shake(frame, intensity, duration, callback)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        if callback then callback() end
        return nil
    end

    intensity = intensity or 5
    duration = duration or 0.3

    local point, relativeTo, relativePoint, origX, origY = frame:GetPoint()
    origX = origX or 0
    origY = origY or 0

    return self:Tween(duration, function(progress)
        local currentIntensity = intensity * (1 - progress)
        local offsetX = (math.random() - 0.5) * 2 * currentIntensity
        local offsetY = (math.random() - 0.5) * 2 * currentIntensity
        frame:SetPoint(point, relativeTo, relativePoint, origX + offsetX, origY + offsetY)
    end, function()
        frame:SetPoint(point, relativeTo, relativePoint, origX, origY)
        if callback then callback() end
    end, self.easing.linear)
end

-- Pulse scale (breathe effect)
function Animations:PulseScale(frame, minScale, maxScale, duration)
    if HopeAddon.db and not HopeAddon.db.settings.animationsEnabled then
        return nil
    end

    minScale = minScale or 0.95
    maxScale = maxScale or 1.05
    duration = duration or 2

    local originalWidth = frame:GetWidth()
    local originalHeight = frame:GetHeight()
    local expanding = true
    local progress = 0

    local ticker
    ticker = HopeAddon.Timer:NewTicker(ANIM_TICK_INTERVAL, function()
        progress = progress + ANIM_TICK_INTERVAL

        local cycleProgress = (progress % duration) / duration
        local scale
        if cycleProgress < 0.5 then
            scale = minScale + (maxScale - minScale) * (cycleProgress * 2)
        else
            scale = maxScale - (maxScale - minScale) * ((cycleProgress - 0.5) * 2)
        end

        frame:SetSize(originalWidth * scale, originalHeight * scale)
    end)

    table.insert(self.active, ticker)
    return ticker
end

--[[
    CLEANUP
]]
function Animations:StopAll()
    for _, ticker in ipairs(self.active) do
        if ticker and ticker.Cancel then
            ticker:Cancel()
        end
    end
    self.active = {}
end

function Animations:Stop(ticker)
    if ticker and ticker.Cancel then
        ticker:Cancel()
    end

    for i, t in ipairs(self.active) do
        if t == ticker then
            table.remove(self.active, i)
            break
        end
    end
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Animations module loaded")
end
