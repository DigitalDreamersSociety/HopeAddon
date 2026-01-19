--[[
    HopeAddon Reputation Module
    Tracks TBC faction progress and creates narrative journal entries
]]

local Reputation = {}
HopeAddon:RegisterModule("Reputation", Reputation)

-- TBC 2.4.3 compatibility helper
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    local Components = HopeAddon.Components
    if Components and Components.CreateBackdropFrame then
        return Components.CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    end
    local template = additionalTemplate and (additionalTemplate .. ", BackdropTemplate") or "BackdropTemplate"
    local frame = CreateFrame(frameType or "Frame", name, parent, template)
    if not frame.SetBackdrop then
        frame:Hide()
        frame = CreateFrame(frameType or "Frame", name, parent, additionalTemplate)
    end
    return frame
end

-- Module state
Reputation.initialized = false
Reputation.cachedStandings = {}
Reputation.notificationPool = nil  -- Frame pool for notifications

--[[
    INITIALIZATION
]]
function Reputation:OnInitialize()
    -- Nothing yet - wait for OnEnable
end

function Reputation:OnEnable()
    self:CreateNotificationPool()
    self:RegisterEvents()
    self:CacheCurrentStandings()
    self.initialized = true
    HopeAddon:Debug("Reputation module enabled")
end

function Reputation:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
    if self.notificationPool then
        self.notificationPool:Destroy()
        self.notificationPool = nil
    end
end

--[[
    Create notification frame pool to avoid creating new frames each time
]]
function Reputation:CreateNotificationPool()
    local createFunc = function()
        local frame = CreateBackdropFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("DIALOG")
        frame:Hide()

        -- Pre-create font strings that will be reused
        frame.titleText = frame:CreateFontString(nil, "OVERLAY")
        frame.line1 = frame:CreateFontString(nil, "OVERLAY")
        frame.line2 = frame:CreateFontString(nil, "OVERLAY")
        frame.line3 = frame:CreateFontString(nil, "OVERLAY")

        return frame
    end

    local resetFunc = function(frame)
        frame:Hide()
        frame:ClearAllPoints()
        frame:SetParent(nil)
        frame:SetAlpha(1)
        -- Clear font string text
        frame.titleText:SetText("")
        frame.line1:SetText("")
        frame.line2:SetText("")
        frame.line3:SetText("")
        -- Clear any stored effects references
        frame._glowEffect = nil
        frame._sparkles = nil
    end

    self.notificationPool = HopeAddon.FramePool:NewNamed("ReputationNotifications", createFunc, resetFunc)
end

--[[
    Release a notification frame back to the pool
]]
function Reputation:ReleaseNotification(notif)
    -- Stop any glow/sparkle effects first
    if notif._glowEffect then
        HopeAddon.Effects:StopGlow(notif._glowEffect)
    end
    if notif._sparkles then
        HopeAddon.Effects:StopSparkles(notif._sparkles)
    end
    self.notificationPool:Release(notif)
end

--[[
    EVENT REGISTRATION
]]
function Reputation:RegisterEvents()
    local eventFrame = CreateFrame("Frame")

    eventFrame:RegisterEvent("UPDATE_FACTION")
    eventFrame:RegisterEvent("PLAYER_LOGIN")

    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "UPDATE_FACTION" then
            self:OnFactionUpdate()
        elseif event == "PLAYER_LOGIN" then
            -- Delay initial check to ensure data is loaded
            HopeAddon.Timer:After(2, function()
                self:CacheCurrentStandings()
            end)
        end
    end)

    self.eventFrame = eventFrame
end

--[[
    CACHE MANAGEMENT
]]
function Reputation:CacheCurrentStandings()
    local Data = HopeAddon.ReputationData

    -- Ensure saved variables exist
    if not HopeAddon.charDb.reputation then
        HopeAddon.charDb.reputation = {
            milestones = {},
            aldorScryerChoice = nil,
            currentStandings = {},
        }
    end

    -- Cache current standings for all TBC factions
    local numFactions = GetNumFactions()
    for i = 1, numFactions do
        local name, _, standingId, _, _, earnedValue, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(i)

        if not isHeader and factionID then
            local factionData, factionName = Data:GetFactionById(factionID)
            if factionData then
                self.cachedStandings[factionName] = {
                    standingId = standingId,
                    earnedValue = earnedValue,
                    factionId = factionID,
                }
                -- Also save to character DB for persistence
                HopeAddon.charDb.reputation.currentStandings[factionName] = standingId
            end
        end
    end

    HopeAddon:Debug("Cached standings for TBC factions")
end

--[[
    FACTION UPDATE HANDLER
]]
function Reputation:OnFactionUpdate()
    if not self.initialized then return end

    local Data = HopeAddon.ReputationData

    -- Check all TBC factions for changes
    local numFactions = GetNumFactions()
    for i = 1, numFactions do
        local name, _, standingId, _, _, earnedValue, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(i)

        if not isHeader and factionID then
            local factionData, factionName = Data:GetFactionById(factionID)
            if factionData then
                local cached = self.cachedStandings[factionName]

                -- Check for standing increase
                if cached and standingId > cached.standingId then
                    self:OnStandingIncreased(factionName, factionData, cached.standingId, standingId)
                end

                -- Check for Aldor/Scryer choice
                if factionData.isChoice and standingId >= 5 and (not cached or cached.standingId < 5) then
                    self:OnAldorScryerChoice(factionName, factionData)
                end

                -- Update cache
                self.cachedStandings[factionName] = {
                    standingId = standingId,
                    earnedValue = earnedValue,
                    factionId = factionID,
                }
                HopeAddon.charDb.reputation.currentStandings[factionName] = standingId
            end
        end
    end
end

--[[
    STANDING INCREASED HANDLER
]]
function Reputation:OnStandingIncreased(factionName, factionData, oldStanding, newStanding)
    local Data = HopeAddon.ReputationData

    -- Check each milestone standing reached
    for checkStanding = oldStanding + 1, newStanding do
        if Data:IsMilestoneStanding(checkStanding) then
            self:CreateMilestoneEntry(factionName, factionData, checkStanding)
        end
    end
end

--[[
    CREATE MILESTONE JOURNAL ENTRY
]]
function Reputation:CreateMilestoneEntry(factionName, factionData, standingId)
    local Data = HopeAddon.ReputationData
    local standingInfo = Data:GetStandingInfo(standingId)

    -- Get lore text for this standing (with nil check for lore table)
    local loreText = (factionData.lore and factionData.lore[standingId]) or "Your reputation has grown."

    -- Create journal entry
    local entry = {
        type = "reputation_milestone",
        faction = factionName,
        factionId = factionData.id,
        standing = standingId,
        standingName = standingInfo.name,
        title = factionName .. " - " .. standingInfo.name,
        description = loreText,
        story = loreText,
        icon = "Interface\\Icons\\" .. factionData.icon,
        zone = GetZoneText(),
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),
        category = factionData.category,
    }

    -- Add reward info if applicable
    if factionData.rewards and factionData.rewards[standingId] then
        entry.reward = factionData.rewards[standingId]
        entry.description = entry.description .. "\n\n" .. HopeAddon:ColorText(factionData.rewards[standingId], "GOLD_BRIGHT")
    end

    -- Save to character DB
    if not HopeAddon.charDb.reputation.milestones[factionName] then
        HopeAddon.charDb.reputation.milestones[factionName] = {}
    end
    HopeAddon.charDb.reputation.milestones[factionName][standingId] = entry

    -- Add to main journal entries
    table.insert(HopeAddon.charDb.journal.entries, entry)

    -- Show notification
    self:ShowReputationNotification(factionName, standingInfo, loreText, factionData)

    -- Play appropriate sound
    self:PlayMilestoneSound(standingId)

    -- Print to chat
    local coloredStanding = "|cFF" .. standingInfo.hex .. standingInfo.name .. "|r"
    HopeAddon:Print("Reputation milestone: " .. HopeAddon:ColorText(factionName, "ARCANE_PURPLE") .. " - " .. coloredStanding)

    -- Notify Badges module of reputation change
    if HopeAddon.Badges then
        HopeAddon.Badges:OnReputationChanged(factionName, standingId)
    end
end

--[[
    ALDOR/SCRYER CHOICE HANDLER
]]
function Reputation:OnAldorScryerChoice(factionName, factionData)
    -- Only record once
    if HopeAddon.charDb.reputation.aldorScryerChoice then
        return
    end

    local opposingFaction = factionData.opposingFaction
    local choiceLore = factionData.choiceLore or "You have made your choice."

    -- Record the choice
    HopeAddon.charDb.reputation.aldorScryerChoice = {
        chosen = factionName,
        opposing = opposingFaction,
        date = HopeAddon:GetDate(),
        timestamp = HopeAddon:GetTimestamp(),
    }

    -- Create special journal entry
    local entry = {
        type = "faction_choice",
        faction = factionName,
        opposingFaction = opposingFaction,
        title = "The Choice: " .. factionName,
        description = choiceLore,
        story = choiceLore,
        icon = "Interface\\Icons\\" .. factionData.icon,
        zone = "Shattrath City",
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),
        category = "shattrath",
    }

    table.insert(HopeAddon.charDb.journal.entries, entry)

    -- Show dramatic notification
    self:ShowChoiceNotification(factionName, opposingFaction, choiceLore, factionData)

    -- Play epic sound
    HopeAddon.Sounds:PlayEpicFanfare()

    -- Print to chat
    HopeAddon:Print(HopeAddon:ColorText("A FATEFUL CHOICE", "GOLD_BRIGHT") .. " - You have allied with " .. HopeAddon:ColorText(factionName, "ARCANE_PURPLE"))
end

--[[
    PLAY MILESTONE SOUND
]]
function Reputation:PlayMilestoneSound(standingId)
    local Sounds = HopeAddon.Sounds

    if standingId == 5 then -- Friendly
        Sounds:Play("reputation", "friendly")
    elseif standingId == 6 then -- Honored
        Sounds:Play("reputation", "honored")
    elseif standingId == 7 then -- Revered
        Sounds:Play("reputation", "revered")
    elseif standingId == 8 then -- Exalted
        Sounds:PlayEpicFanfare()
    end
end

--[[
    NOTIFICATIONS
    Uses frame pool to avoid creating new frames for each notification
]]
function Reputation:ShowReputationNotification(factionName, standingInfo, loreText, factionData)
    if HopeAddon.db and not HopeAddon.db.settings.notificationsEnabled then
        return
    end
    if not self.notificationPool then return end

    local isExalted = standingInfo.name == "Exalted"
    local Effects = HopeAddon.Effects

    -- Acquire from pool instead of creating new frame
    local notif = self.notificationPool:Acquire()
    notif:SetSize(380, 110)
    notif:SetPoint("TOP", UIParent, "TOP", 0, -100)
    notif:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT_DARK,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    notif:SetBackdropColor(HopeAddon:GetBgColor("PURPLE_TINT"))

    -- Use standing color for border
    local r, g, b = standingInfo.color.r, standingInfo.color.g, standingInfo.color.b
    notif:SetBackdropBorderColor(r, g, b, 1)

    -- Configure pre-created font strings
    notif.titleText:ClearAllPoints()
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 16)
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -12)
    notif.titleText:SetText("|cFF" .. standingInfo.hex .. "REPUTATION: " .. string.upper(standingInfo.name) .. "|r")

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -5)
    notif.line1:SetText(factionName)
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11)
    notif.line2:SetPoint("TOP", notif.line1, "BOTTOM", 0, -8)
    notif.line2:SetWidth(350)
    notif.line2:SetText('"' .. loreText .. '"')
    notif.line2:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))

    -- Add effects for Exalted (store references for cleanup)
    if isExalted then
        notif._glowEffect = Effects:CreateBorderGlow(notif, "ARCANE_PURPLE")
        notif._sparkles = Effects:CreateSparkles(notif, 10, "GOLD_BRIGHT")
        Effects:CreateBurstEffect(notif, "ARCANE_PURPLE")
    end

    -- Animate in, then release back to pool
    local self_ref = self
    HopeAddon.Animations:NotificationSlideIn(notif, function()
        local displayTime = isExalted and 6 or 4
        HopeAddon.Timer:After(displayTime, function()
            HopeAddon.Animations:NotificationSlideOut(notif, function()
                self_ref:ReleaseNotification(notif)
            end)
        end)
    end)
end

function Reputation:ShowChoiceNotification(chosenFaction, opposingFaction, loreText, factionData)
    if HopeAddon.db and not HopeAddon.db.settings.notificationsEnabled then
        return
    end
    if not self.notificationPool then return end

    local Effects = HopeAddon.Effects

    -- Acquire from pool instead of creating new frame
    local notif = self.notificationPool:Acquire()
    notif:SetSize(420, 140)
    notif:SetPoint("TOP", UIParent, "TOP", 0, -100)
    notif:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT_DARK,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true,
        tileSize = 16,
        edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    notif:SetBackdropColor(HopeAddon:GetBgColor("PURPLE_DARK"))
    notif:SetBackdropBorderColor(1, 0.84, 0, 1)

    -- Configure pre-created font strings
    notif.titleText:ClearAllPoints()
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 20)
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -15)
    notif.titleText:SetText(HopeAddon:ColorText("A FATEFUL CHOICE", "GOLD_BRIGHT"))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -8)
    notif.line1:SetText("You have aligned with " .. HopeAddon:ColorText(chosenFaction, "ARCANE_PURPLE"))
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11)
    notif.line2:SetPoint("TOP", notif.line1, "BOTTOM", 0, -10)
    notif.line2:SetWidth(380)
    notif.line2:SetText('"' .. loreText .. '"')
    notif.line2:SetTextColor(0.9, 0.85, 0.7, 1)

    notif.line3:ClearAllPoints()
    notif.line3:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    notif.line3:SetPoint("BOTTOM", notif, "BOTTOM", 0, 12)
    notif.line3:SetText(HopeAddon:ColorText(opposingFaction, "HELLFIRE_RED") .. " will never trust you again.")
    notif.line3:SetTextColor(1, 1, 1, 1)

    -- Epic effects (store references for cleanup)
    notif._glowEffect = Effects:CreateBorderGlow(notif, "GOLD_BRIGHT")
    notif._sparkles = Effects:CreateSparkles(notif, 12, "ARCANE_PURPLE")
    Effects:CreateBurstEffect(notif, "GOLD_BRIGHT")

    -- Animate in, then release back to pool
    local self_ref = self
    HopeAddon.Animations:NotificationSlideIn(notif, function()
        HopeAddon.Timer:After(7, function()
            HopeAddon.Animations:NotificationSlideOut(notif, function()
                self_ref:ReleaseNotification(notif)
            end)
        end)
    end)
end

--[[
    HELPER FUNCTIONS
]]
function Reputation:GetFactionStanding(factionName)
    return self.cachedStandings[factionName]
end

function Reputation:GetProgressInStanding(factionName)
    local Data = HopeAddon.ReputationData

    -- Find faction in reputation panel
    local numFactions = GetNumFactions()
    for i = 1, numFactions do
        local name, _, standingId, barMin, barMax, barValue, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(i)

        if not isHeader then
            local factionData, fname = Data:GetFactionById(factionID)
            if fname == factionName then
                local current = barValue - barMin
                local max = barMax - barMin
                return current, max, standingId
            end
        end
    end

    return 0, 0, 0
end

function Reputation:IsTBCFaction(factionId)
    local Data = HopeAddon.ReputationData
    return Data.FACTION_ID_MAP[factionId] ~= nil
end

function Reputation:HasReachedMilestone(factionName, standingId)
    local milestones = HopeAddon.charDb.reputation.milestones
    return milestones[factionName] and milestones[factionName][standingId] ~= nil
end

function Reputation:GetAldorScryerChoice()
    return HopeAddon.charDb.reputation.aldorScryerChoice
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Reputation module loaded")
end
