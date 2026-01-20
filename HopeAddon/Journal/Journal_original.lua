--[[
    HopeAddon Journal Module
    Main journal UI and entry management
]]

local Journal = {}
HopeAddon:RegisterModule("Journal", Journal)

-- Use centralized backdrop frame creation from Core.lua
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

-- Journal state
Journal.isOpen = false
Journal.currentTab = "journey"
Journal.mainFrame = nil
Journal.notificationPool = nil  -- Frame pool for notifications
Journal.pendingNotifications = {}  -- Track pending notifications to prevent stacking
Journal.notificationQueue = {}  -- Queue for sequential notification display
Journal.isShowingNotification = false  -- Flag to prevent overlapping notifications

-- Cached counts (invalidated when entries change)
Journal.cachedCounts = nil

-- Cached timeline entries (invalidated when new entries added)
Journal.cachedSortedTimeline = nil
Journal.timelineCacheValid = false

-- Cached riding skill (invalidated on SKILL_LINES_CHANGED)
Journal.cachedRidingSkill = nil

-- Cached stats data (invalidated on relevant events)
Journal.cachedStatsData = nil

-- Notification size constants
local NOTIF_WIDTH_LARGE = 350
local NOTIF_WIDTH_SMALL = 300
local NOTIF_HEIGHT_LARGE = 100
local NOTIF_HEIGHT_SMALL = 80
local NOTIF_TOP_OFFSET = -100

-- Lookup table for tracked combat events (faster than string comparison in loop)
local TRACKED_DAMAGE_EVENTS = {
    ["PARTY_KILL"] = true,
    ["SPELL_DAMAGE"] = true,
    ["SWING_DAMAGE"] = true,
    ["RANGE_DAMAGE"] = true,
}

-- Heroic dungeon key icons by faction ID
local HEROIC_KEY_ICONS = {
    [942] = "INV_Misc_Key_13",    -- Cenarion Expedition - Reservoir Key
    [935] = "INV_Misc_Key_12",    -- The Sha'tar - Warpforged Key
    [989] = "INV_Misc_Key_11",    -- Keepers of Time - Key of Time
    [1011] = "INV_Misc_Key_14",   -- Lower City - Auchenai Key
    [946] = "INV_Misc_Key_15",    -- Honor Hold - Flamewrought Key (Alliance)
    [947] = "INV_Misc_Key_15",    -- Thrallmar - Flamewrought Key (Horde)
}

-- Heroic key names by faction ID
local HEROIC_KEY_NAMES = {
    [942] = "Reservoir Key",      -- Cenarion - Heroic Coilfang
    [935] = "Warpforged Key",     -- Sha'tar - Heroic Tempest Keep
    [989] = "Key of Time",        -- KoT - Heroic Caverns of Time
    [1011] = "Auchenai Key",      -- Lower City - Heroic Auchindoun
    [946] = "Flamewrought Key",   -- Honor Hold - Heroic Hellfire
    [947] = "Flamewrought Key",   -- Thrallmar - Heroic Hellfire
}

-- Icons for requirement types in Next Step box
local REQUIREMENT_TYPE_ICONS = {
    dungeon = "INV_Misc_Key_04",
    raid = "Ability_Creature_Cursed_04",
    boss = "Ability_DualWield",
    quest = "INV_Letter_15",
    item = "INV_Misc_Bag_10",
    level = "Achievement_Level_60",
}

-- Phase colors for Next Step box border
local PHASE_COLORS = {
    PRE_OUTLAND = "GOLD_BRIGHT",
    T4_ATTUNEMENT = "FEL_GREEN",
    T5_ATTUNEMENT = "ARCANE_PURPLE",
    T6_ATTUNEMENT = "HELLFIRE_RED",
    RAID_PROGRESSION = "SKY_BLUE",
    ENDGAME = "GOLD_BRIGHT",
}

-- Phase display names
local PHASE_NAMES = {
    PRE_OUTLAND = "The Journey Begins",
    T4_ATTUNEMENT = "Tier 4 Attunement",
    T5_ATTUNEMENT = "Tier 5 Attunement",
    T6_ATTUNEMENT = "Tier 6 Attunement",
    RAID_PROGRESSION = "Raid Progression",
    ENDGAME = "Legend of Outland",
}

--[[
    INITIALIZATION
]]
function Journal:OnInitialize()
    -- Nothing yet - wait for OnEnable
end

function Journal:OnEnable()
    -- Create pools FIRST - CreateMainFrame calls SelectTab which needs them
    self:CreateNotificationPool()
    self:CreateContainerPool()
    self:CreateCardPool()
    self:CreateCollapsibleSectionPool()
    self:CreateBossInfoPool()
    self:CreateGameCardPool()
    self:CreateMainFrame()
    self:RegisterEvents()
    HopeAddon:Debug("Journal module enabled")
end

function Journal:OnDisable()
    -- Stop all active effects to prevent memory leaks
    if HopeAddon.Effects then
        -- Stop all glows tracked by Effects module
        HopeAddon.Effects:StopAllGlows()

        -- Stop all sparkles tracked per parent frame
        for parent, sparkles in pairs(HopeAddon.Effects.frameSparkles or {}) do
            HopeAddon.Effects:StopSparkles(sparkles)
        end
        HopeAddon.Effects.frameSparkles = {}
        HopeAddon.Effects.activeGlows = {}
        HopeAddon.Effects.activeAnimations = {}
    end

    -- Stop all glows tracked by Glow module
    if HopeAddon.Glow then
        HopeAddon.Glow:StopAll()
        HopeAddon.Glow.registry = {}
        HopeAddon.Glow.glowsByParent = {}
    end

    -- Clear cached data
    self.cachedCounts = nil
    self.cachedSortedTimeline = nil
    self.timelineCacheValid = false
    self.cachedRidingSkill = nil
    self.cachedStatsData = nil

    -- Hide main frame
    if self.mainFrame then
        self.mainFrame:Hide()
    end

    -- Unregister events
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    -- Destroy frame pools
    if self.notificationPool then
        self.notificationPool:Destroy()
        self.notificationPool = nil
    end
    if self.cardPool then
        self.cardPool:Destroy()
        self.cardPool = nil
    end
    if self.collapsiblePool then
        self.collapsiblePool:Destroy()
        self.collapsiblePool = nil
    end
    if self.containerPool then
        self.containerPool:Destroy()
        self.containerPool = nil
    end
    if self.bossInfoPool then
        self.bossInfoPool:Destroy()
        self.bossInfoPool = nil
    end
    if self.gameCardPool then
        self.gameCardPool:Destroy()
        self.gameCardPool = nil
    end
end

--[[
    Create notification frame pool to avoid creating new frames each time
]]
function Journal:CreateNotificationPool()
    local createFunc = function()
        local frame = CreateBackdropFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("DIALOG")
        frame:Hide()

        -- Pre-create font strings that will be reused
        frame.titleText = frame:CreateFontString(nil, "OVERLAY")
        frame.line1 = frame:CreateFontString(nil, "OVERLAY")
        frame.line2 = frame:CreateFontString(nil, "OVERLAY")

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
        -- Clear any stored effects references
        frame._glowEffect = nil
        frame._sparkles = nil
    end

    self.notificationPool = HopeAddon.FramePool:NewNamed("JournalNotifications", createFunc, resetFunc)
end

--[[
    Release a notification frame back to the pool
]]
function Journal:ReleaseNotification(notif)
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
    Create container frame pool for headers, spacers, and simple containers
    Reuses frames instead of creating new ones each tab switch
]]
function Journal:CreateContainerPool()
    local createFunc = function()
        local frame = CreateFrame("Frame")
        frame:Hide()
        return frame
    end

    local resetFunc = function(frame)
        frame:Hide()
        frame:ClearAllPoints()
        frame:SetParent(nil)
        frame:SetSize(1, 1)
        frame._pooled = true
        -- Clear all regions (font strings, textures)
        for _, region in pairs({frame:GetRegions()}) do
            if region:GetObjectType() == "FontString" then
                region:SetText("")
            elseif region:GetObjectType() == "Texture" then
                region:Hide()
            end
        end
        -- Hide child frames (tier cards, etc.) but don't destroy them
        for _, child in pairs({frame:GetChildren()}) do
            child:Hide()
        end
    end

    self.containerPool = HopeAddon.FramePool:NewNamed("JournalContainers", createFunc, resetFunc)
end

--[[
    Create entry card frame pool for boss cards, timeline entries, etc.
    Reuses card frames instead of creating new ones each tab switch
]]
function Journal:CreateCardPool()
    local createFunc = function()
        -- Create a minimal card frame (icon, title, desc, timestamp)
        local card = CreateBackdropFrame("Button", nil, UIParent)
        card:SetHeight(80)
        card:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)

        -- Pre-create all elements
        card.icon = card:CreateTexture(nil, "ARTWORK")
        card.title = card:CreateFontString(nil, "OVERLAY")
        card.desc = card:CreateFontString(nil, "OVERLAY")
        card.timestamp = card:CreateFontString(nil, "OVERLAY")

        -- Setup fonts (unchanging)
        card.title:SetFont(HopeAddon.assets.fonts.HEADER, 14)
        card.desc:SetFont(HopeAddon.assets.fonts.BODY, 11)
        card.timestamp:SetFont(HopeAddon.assets.fonts.SMALL, 10)

        card:Hide()
        return card
    end

    local resetFunc = function(card)
        card:Hide()
        card:ClearAllPoints()
        card:SetParent(nil)
        card:SetAlpha(1.0)
        card:SetBackdropColor(HopeAddon:GetBgColor("DARK_TRANSPARENT"))
        card:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        card.icon:SetTexture(nil)
        card.icon:Hide()
        card.title:SetText("")
        card.desc:SetText("")
        card.timestamp:SetText("")
        card:SetScript("OnClick", nil)
        card:SetScript("OnEnter", nil)
        card:SetScript("OnLeave", nil)
        -- Clean up any glow effects to prevent memory leaks
        if card._glowEffect then
            HopeAddon.Effects:StopGlow(card._glowEffect)
            card._glowEffect = nil
        end
        -- Clean up any sparkle effects
        if card._sparkles then
            HopeAddon.Effects:StopSparkles(card._sparkles)
            card._sparkles = nil
        end
        -- Clean up challengeBtn to prevent closure memory leaks
        if card.challengeBtn then
            card.challengeBtn:Hide()
            card.challengeBtn:SetScript("OnClick", nil)
            card.challengeBtn:SetScript("OnEnter", nil)
            card.challengeBtn:SetScript("OnLeave", nil)
            card.challengeBtn:SetScript("OnMouseDown", nil)
            card.challengeBtn:SetScript("OnMouseUp", nil)
            card.challengeBtn.targetName = nil
        end
        -- Clean up noteIcon
        if card.noteIcon then
            card.noteIcon:Hide()
        end
        -- Clear default border color cache
        card.defaultBorderColor = nil
        -- Clear OnCardClick callback to prevent stale closure references
        card.OnCardClick = nil
        card._pooled = true
    end

    self.cardPool = HopeAddon.FramePool:NewNamed("EntryCards", createFunc, resetFunc)
end

--[[
    Create collapsible section frame pool for Milestones and Raids tabs.
    These complex frames are expensive to create (header, content container, methods).
    Pooling them avoids recreating 12+ sections on every tab switch.
]]
function Journal:CreateCollapsibleSectionPool()
    local Components = HopeAddon.Components

    local createFunc = function()
        -- Create the full collapsible section structure via Components
        local section = Components:CreateCollapsibleSection(UIParent, "", "GOLD_BRIGHT", true)
        section:Hide()
        return section
    end

    local resetFunc = function(section)
        section:Hide()
        section:ClearAllPoints()
        section:SetParent(nil)
        section:SetAlpha(1)

        -- Reset state
        section.childEntries = {}
        section.contentHeight = 0
        section.isExpanded = true
        section.onToggle = nil

        -- Reset indicator and title
        section.indicator:SetText("[-]")
        section.titleText:SetText("")

        -- Reset subtitle if present
        if section.subtitleText then
            section.subtitleText:SetText("")
            section.subtitleText:Hide()
        end

        -- Reset content container
        section.contentContainer:SetHeight(1)
        section.contentContainer:Show()

        -- Hide all children in content container without destroying them
        -- (they will be released by the cardPool separately)
        local children = {section.contentContainer:GetChildren()}
        for _, child in ipairs(children) do
            child:Hide()
            child:ClearAllPoints()
            child:SetParent(nil)
        end

        -- Reset section height to header-only
        section:SetHeight(28)

        -- Mark as pooled for ClearEntries detection
        section._pooled = true
    end

    self.collapsiblePool = HopeAddon.FramePool:NewNamed("CollapsibleSections", createFunc, resetFunc)
end

--[[
    Create boss info card pool for raid metadata frames (location, size, etc.)
    These simple frames are reused across Raids tab switches
]]
function Journal:CreateBossInfoPool()
    local createFunc = function()
        local card = CreateFrame("Frame", nil, UIParent)
        card:SetHeight(22)

        -- Pre-create text element
        card.infoText = card:CreateFontString(nil, "OVERLAY")
        card.infoText:SetFont(HopeAddon.assets.fonts.SMALL, 10)

        card:Hide()
        return card
    end

    local resetFunc = function(card)
        card:Hide()
        card:ClearAllPoints()
        card:SetParent(nil)
        card:SetAlpha(1.0)
        card.infoText:SetText("")
        card._pooled = true
    end

    self.bossInfoPool = HopeAddon.FramePool:NewNamed("BossInfoCards", createFunc, resetFunc)
end

--[[
    Create game card pool for Games Hall UI in Directory tab.
    These cards are expensive to create (icon, title, desc, stats, 2 buttons).
    Pooling avoids recreating 6 cards on every tab switch.
]]
function Journal:CreateGameCardPool()
    local Components = HopeAddon.Components

    local createFunc = function()
        -- Create the full game card structure via Components
        local card = Components:CreateGameCard(UIParent, nil, nil, nil)
        card:Hide()
        return card
    end

    local resetFunc = function(card)
        card:Hide()
        card:ClearAllPoints()
        card:SetParent(nil)
        card:SetAlpha(1.0)

        -- Reset backdrop colors (TBC theme: arcane purple)
        local c = HopeAddon.colors.ARCANE_PURPLE
        card:SetBackdropColor(1, 1, 1, 0.9)
        card:SetBackdropBorderColor(c.r, c.g, c.b, 1)
        card.defaultBorderColor = { c.r, c.g, c.b, 1 }

        -- Clear data reference
        card.gameData = nil

        -- Reset text fields
        card.icon:SetTexture(nil)
        card.title:SetText("")
        card.desc:SetText("")
        card.stats:SetText("")

        -- Reset button states
        card.practiceBtn:Enable()
        card.practiceBtn.disabledOverlay:Hide()
        card.practiceBtn.text:SetTextColor(0.8, 1.0, 0.8, 1)
        card.practiceBtn:SetScript("OnClick", nil)

        card.challengeBtn:SetScript("OnClick", nil)

        -- Mark as pooled
        card._pooled = true
    end

    self.gameCardPool = HopeAddon.FramePool:NewNamed("GameCards", createFunc, resetFunc)
end

--[[
    Acquire and configure a game card from the pool
    @param parent Frame - Parent to attach to
    @param gameData table - Game definition from Constants.GAME_DEFINITIONS
    @param onPractice function - Callback for Practice button
    @param onChallenge function - Callback for Challenge button
    @return Frame - Configured pooled game card
]]
function Journal:AcquireGameCard(parent, gameData, onPractice, onChallenge)
    if not self.gameCardPool then return nil end

    local card = self.gameCardPool:Acquire()
    card:SetParent(parent)
    card._pooled = true

    -- Configure with game data
    card:SetGameData(gameData, onPractice, onChallenge)

    return card
end

--[[
    Acquire and configure a boss info card from the pool
    @param parent Frame - Parent to attach to
    @param text string - Info text to display
    @return Frame - Configured pooled info card
]]
function Journal:AcquireBossInfoCard(parent, text)
    if not self.bossInfoPool then return nil end

    local card = self.bossInfoPool:Acquire()
    card:SetParent(parent)
    card._pooled = true

    -- Configure text
    card.infoText:ClearAllPoints()
    card.infoText:SetPoint("LEFT", card, "LEFT", HopeAddon.Components.MARGIN_SMALL, 0)
    card.infoText:SetText(text)
    card.infoText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))

    return card
end

--[[
    Acquire and configure a collapsible section from the pool
    @param parent Frame - Parent to attach to
    @param title string - Section title text
    @param colorName string - Color name for the title
    @param startExpanded boolean - Whether to start expanded (default true)
    @return Frame - Configured pooled collapsible section
]]
function Journal:AcquireCollapsibleSection(parent, title, colorName, startExpanded)
    if not self.collapsiblePool then return nil end

    local section = self.collapsiblePool:Acquire()
    section:SetParent(parent)
    section._pooled = true

    -- Configure title with color
    colorName = colorName or "GOLD_BRIGHT"
    section.titleText:SetText(HopeAddon:ColorText(title, colorName))

    -- Set initial expansion state
    startExpanded = startExpanded ~= false
    section.isExpanded = startExpanded
    section.indicator:SetText(startExpanded and "[-]" or "[+]")
    section:UpdateHeight()

    return section
end

--[[
    Acquire and configure an entry card from the pool
    @param parent Frame - Parent to attach to
    @param data table - Card data { icon, title, description, timestamp }
    @return Frame - Configured pooled card
]]
function Journal:AcquireCard(parent, data)
    if not self.cardPool then return nil end
    local card = self.cardPool:Acquire()
    local Components = HopeAddon.Components

    card:SetParent(parent)
    card:SetHeight(80)
    card._pooled = true

    -- Configure icon
    local iconOffset = Components.MARGIN_NORMAL
    if data.icon then
        card.icon:SetTexture(data.icon)
        card.icon:SetSize(Components.ICON_SIZE_STANDARD, Components.ICON_SIZE_STANDARD)
        card.icon:ClearAllPoints()
        card.icon:SetPoint("LEFT", card, "LEFT", Components.MARGIN_NORMAL, 0)
        card.icon:Show()
        iconOffset = Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL
    else
        card.icon:Hide()
    end

    -- Configure title
    card.title:ClearAllPoints()
    card.title:SetPoint("TOPLEFT", card, "TOPLEFT", iconOffset, -Components.MARGIN_NORMAL)
    card.title:SetPoint("RIGHT", card, "RIGHT", -Components.MARGIN_NORMAL, 0)
    card.title:SetText(HopeAddon:ColorText(data.title or "Entry", "GOLD_BRIGHT"))

    -- Configure description
    card.desc:ClearAllPoints()
    card.desc:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -Components.MARGIN_SMALL)
    card.desc:SetPoint("RIGHT", card, "RIGHT", -Components.MARGIN_NORMAL, 0)
    card.desc:SetMaxLines(3)  -- Limit to 3 lines instead of fixed bottom anchor
    card.desc:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    card.desc:SetJustifyH("LEFT")
    card.desc:SetJustifyV("TOP")
    card.desc:SetWordWrap(true)
    card.desc:SetText(data.description or "")

    -- Configure timestamp
    card.timestamp:ClearAllPoints()
    card.timestamp:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -Components.MARGIN_NORMAL, 5)
    card.timestamp:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
    card.timestamp:SetText(data.timestamp or "")

    -- Hover effects
    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(HopeAddon:GetColor("GOLD_BRIGHT"))
    end)
    card:SetScript("OnLeave", function(self)
        local bc = self.defaultBorderColor or {0.5, 0.5, 0.5, 1}
        self:SetBackdropBorderColor(unpack(bc))
    end)

    card.defaultBorderColor = {0.5, 0.5, 0.5, 1}

    return card
end

--[[
    Acquire a container frame from the pool
    @param parent Frame - Parent to attach to
    @param height number - Desired height
    @return Frame - Pooled container frame
]]
-- Content width for Journey tab containers (frame 550 - margins 40 - scrollbar 25 = 485)
local CONTAINER_WIDTH = 485

function Journal:AcquireContainer(parent, height)
    if not self.containerPool then return nil end
    local container = self.containerPool:Acquire()
    container:SetParent(parent)
    container:SetSize(CONTAINER_WIDTH, height or 20)
    container._pooled = true
    return container
end

--[[
    Create a spacer frame from the pool
    @param height number - Spacer height
    @return Frame - Pooled spacer frame
]]
function Journal:CreateSpacer(height)
    return self:AcquireContainer(self.mainFrame.scrollContainer.content, height or 15)
end

--[[
    Get cached counts for milestones
    Avoids O(n) iteration on every footer update
    @return table - { milestones = n }
]]
function Journal:GetCachedCounts()
    if not self.cachedCounts then
        local milestoneCount = 0
        for _ in pairs(HopeAddon.charDb.journal.levelMilestones) do
            milestoneCount = milestoneCount + 1
        end

        self.cachedCounts = {
            milestones = milestoneCount,
        }
    end
    return self.cachedCounts
end

--[[
    Invalidate cached counts (call when entries are added)
]]
function Journal:InvalidateCounts()
    self.cachedCounts = nil
    -- Also invalidate timeline cache when entries change
    self.timelineCacheValid = false
    self.cachedSortedTimeline = nil
    -- Invalidate stats cache since counts may have changed
    self.cachedStatsData = nil
end

--[[
    EVENT REGISTRATION
]]
function Journal:RegisterEvents()
    -- Parent to mainFrame for proper cleanup and frame hierarchy
    local eventFrame = CreateFrame("Frame", nil, self.mainFrame)

    -- Level up tracking
    eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventFrame:RegisterEvent("QUEST_TURNED_IN")
    eventFrame:RegisterEvent("PLAYER_DEAD")
    -- Playtime tracking
    eventFrame:RegisterEvent("TIME_PLAYED_MSG")
    -- Combat log for stats (creatures slain, largest hit, dungeon bosses)
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    -- Skill changes (for riding skill cache invalidation)
    eventFrame:RegisterEvent("SKILL_LINES_CHANGED")

    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            self:OnLevelUp(...)
        elseif event == "QUEST_TURNED_IN" then
            self:OnQuestComplete(...)
        elseif event == "PLAYER_DEAD" then
            self:OnPlayerDeath()
        elseif event == "TIME_PLAYED_MSG" then
            self:OnTimePlayed(...)
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local success, err = pcall(self.OnCombatLogEvent, self)
            if not success then
                HopeAddon:Debug("Combat log handler error:", err)
            end
        elseif event == "SKILL_LINES_CHANGED" then
            -- Invalidate riding skill cache
            self.cachedRidingSkill = nil
            self.cachedStatsData = nil
        end
    end)

    self.eventFrame = eventFrame

    -- Request playtime on login (with slight delay to avoid spam)
    HopeAddon.Timer:After(2, function()
        RequestTimePlayed()
    end)
end

--[[
    CREATE MAIN FRAME
]]
function Journal:CreateMainFrame()
    local Components = HopeAddon.Components
    local Effects = HopeAddon.Effects

    -- Main parchment frame
    local frame = Components:CreateParchmentFrame("HopeJournalFrame", UIParent, 550, 650)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")
    frame:Hide()

    -- Make it close with Escape
    tinsert(UISpecialFrames, "HopeJournalFrame")

    -- Title
    local titleBar = Components:CreateTitleBar(frame, "MY JOURNEY", "ARCANE_PURPLE")

    -- Character info display
    local charInfo = frame:CreateFontString(nil, "OVERLAY")
    charInfo:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    charInfo:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -50, -20)
    local _, class = UnitClass("player")
    local classColor = HopeAddon:GetClassColor(class)
    charInfo:SetText(string.format("|cFF%02x%02x%02x%s|r - Level %d",
        classColor.r * 255, classColor.g * 255, classColor.b * 255,
        UnitName("player"), UnitLevel("player")))
    frame.charInfo = charInfo

    -- Close button
    Components:CreateCloseButton(frame)

    -- Tab bar (inherits HIGH strata from parent, but set explicitly for clarity)
    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetFrameStrata("HIGH")
    tabBar:SetPoint("TOPLEFT", frame, "TOPLEFT", Components.MARGIN_LARGE, -65)
    tabBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -Components.MARGIN_LARGE, -65)
    tabBar:SetHeight(35)

    -- Create tabs
    local tabs = {}
    local tabData = {
        { id = "journey", label = "Journey", tooltip = "Your TBC progression and timeline" },
        { id = "zones", label = "Zones", tooltip = "Outland zone discoveries" },
        { id = "reputation", label = "Reputation", tooltip = "Faction standings by category" },
        { id = "raids", label = "Raids", tooltip = "Boss kill tracking by tier (T4/T5/T6)" },
        { id = "attunements", label = "Attunements", tooltip = "Raid attunement quest chains" },
        { id = "games", label = "Games", tooltip = "Practice minigames or challenge friends", color = "ARCANE_PURPLE" },
        { id = "social", label = "Social", tooltip = "Fellow travelers directory", color = "FEL_GREEN" },
        { id = "stats", label = "Stats", tooltip = "Journey statistics summary" },
    }

    local tabWidth = (frame:GetWidth() - 2 * Components.MARGIN_LARGE) / #tabData
    for i, data in ipairs(tabData) do
        local tab = Components:CreateTabButton(tabBar, data.label, tabWidth - 5, 30, data.tooltip, data.color)
        tab:SetPoint("LEFT", tabBar, "LEFT", (i-1) * tabWidth, 0)
        tab.id = data.id

        tab:HookScript("OnClick", function()
            self:SelectTab(data.id)
        end)

        tabs[data.id] = tab
    end
    frame.tabs = tabs

    -- Content area (inherits HIGH strata from parent, but set explicitly for clarity)
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetFrameStrata("HIGH")
    contentArea:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -Components.MARGIN_NORMAL)
    contentArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -Components.MARGIN_LARGE, 30)
    frame.contentArea = contentArea

    -- Scroll frame for entries - use SetAllPoints instead of passing size params that get ignored
    local scrollContainer = Components:CreateScrollFrame(contentArea)
    scrollContainer:SetAllPoints(contentArea)
    frame.scrollContainer = scrollContainer

    -- Footer with stats summary
    local footer = frame:CreateFontString(nil, "OVERLAY")
    footer:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 25)
    footer:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
    frame.footer = footer

    -- Store reference
    self.mainFrame = frame

    -- Select default tab
    self:SelectTab("journey")

    return frame
end

--[[
    TAB SELECTION
]]
function Journal:SelectTab(tabId)
    -- Prevent rapid tab switching during animation
    if self.isTabAnimating then return end
    if tabId == self.currentTab then return end

    self.isTabAnimating = true
    self.currentTab = tabId

    -- Update tab visuals
    for id, tab in pairs(self.mainFrame.tabs) do
        tab:SetSelected(id == tabId)
    end

    -- Stop any active glow effects before clearing content to prevent memory leaks
    local Glow = HopeAddon.Glow
    if Glow and Glow.StopAll then
        Glow:StopAll()
    end

    -- Release pooled frames in correct order:
    -- 1. Cards first (they're children of collapsible sections)
    if self.cardPool then
        self.cardPool:ReleaseAll()
    end

    -- 2. Collapsible sections second (after their card children are released)
    if self.collapsiblePool then
        self.collapsiblePool:ReleaseAll()
    end

    -- 3. Clear and repopulate content (pass containerPool for pooled frame release)
    self.mainFrame.scrollContainer:ClearEntries(self.containerPool)

    -- Migration: old "directory" tab now split into "games" and "social"
    if tabId == "directory" then
        tabId = "social"
        self.currentTab = tabId
    end

    if tabId == "journey" then
        self:PopulateJourney()
    elseif tabId == "zones" then
        self:PopulateZones()
    elseif tabId == "reputation" then
        self:PopulateReputation()
    elseif tabId == "raids" then
        self:PopulateRaids()
    elseif tabId == "attunements" then
        self:PopulateAttunements()
    elseif tabId == "games" then
        self:PopulateGames()
    elseif tabId == "social" then
        self:PopulateSocial()
    elseif tabId == "stats" then
        self:PopulateStats()
    end

    -- Update footer
    self:UpdateFooter()

    -- Reset animation throttle after tab transition completes
    HopeAddon.Timer:After(0.3, function()
        self.isTabAnimating = false
    end)
end

--[[
    UPDATE FOOTER
]]
function Journal:UpdateFooter()
    local stats = HopeAddon.charDb.stats
    local entryCount = #HopeAddon.charDb.journal.entries
    local counts = self:GetCachedCounts()

    self.mainFrame.footer:SetText(string.format(
        "Journal Entries: %d | Milestones: %d | Deaths: %d",
        entryCount, counts.milestones, stats.deaths.total
    ))
end

--[[
    HELPER: Create Section Header
    Creates a header that is properly added to the scroll container
    Delegates to Components:CreateSectionHeader for consistent styling
]]
function Journal:CreateSectionHeader(title, colorName, subtext)
    local parent = self.mainFrame.scrollContainer.content
    return HopeAddon.Components:CreateSectionHeader(parent, title, colorName, subtext)
end

--[[
    HELPER: Create Category Header (smaller)
    Delegates to Components:CreateCategoryHeader for consistent styling
]]
function Journal:CreateCategoryHeader(title, colorName)
    local parent = self.mainFrame.scrollContainer.content
    return HopeAddon.Components:CreateCategoryHeader(parent, title, colorName)
end

--[[
    POPULATE FUNCTIONS
]]

--[[
    YOU ARE PREPARED - Summary Section Data Helpers
]]

-- Tier display names and colors
local TIER_INFO = {
    T4 = { name = "Tier 4", color = "UNCOMMON", raids = { "karazhan", "gruul", "magtheridon" } },
    T5 = { name = "Tier 5", color = "RARE", raids = { "ssc", "tk" } },
    T6 = { name = "Tier 6", color = "EPIC", raids = { "hyjal", "bt" } },
}

-- Raid display names
local RAID_NAMES = {
    karazhan = "Karazhan",
    gruul = "Gruul's Lair",
    magtheridon = "Magtheridon's Lair",
    ssc = "Serpentshrine Cavern",
    tk = "Tempest Keep",
    hyjal = "Hyjal Summit",
    bt = "Black Temple",
}

-- Boss counts per raid
local RAID_BOSS_COUNTS = {
    karazhan = 11,  -- Including optional bosses
    gruul = 2,
    magtheridon = 1,
    ssc = 6,
    tk = 4,
    hyjal = 5,
    bt = 9,
}

-- Key reputations for progression (faction IDs)
local KEY_REPUTATIONS = {
    { id = 942, name = "Cenarion Expedition", requirement = "Heroic Keys" },
    { id = 935, name = "The Sha'tar", requirement = "Heroic Keys" },
    { id = 989, name = "Keepers of Time", requirement = "Heroic Keys" },
    { id = 1011, name = "Lower City", requirement = "Heroic Keys" },
    { id = 932, name = "The Aldor", requirement = "Attunements", isChoice = true },
    { id = 934, name = "The Scryers", requirement = "Attunements", isChoice = true },
}

--[[
    Get raid tier status for summary display
    @param tierKey string - "T4", "T5", or "T6"
    @return table - { status, bossesKilled, totalBosses, raids }
]]
function Journal:GetTierStatus(tierKey)
    local tierInfo = TIER_INFO[tierKey]
    if not tierInfo then return nil end

    local C = HopeAddon.Constants
    local Attunements = HopeAddon.Attunements
    local bossKills = HopeAddon.charDb.journal.bossKills or {}

    local totalKilled = 0
    local totalBosses = 0
    local raids = {}

    for _, raidKey in ipairs(tierInfo.raids) do
        local raidBosses = C[string.upper(raidKey) .. "_BOSSES"] or {}
        local bossCount = #raidBosses
        local killedCount = 0

        -- Count killed bosses for this raid
        for _, boss in ipairs(raidBosses) do
            if bossKills[boss.id] then
                killedCount = killedCount + 1
            end
        end

        -- Check attunement status (only karazhan, ssc, tk, hyjal, bt have attunements)
        local attuned = false
        local attuneProgress = 0
        local attuneTotal = 0

        if Attunements and Attunements.GetState then
            local state = Attunements:GetState(raidKey)
            attuned = (state == Attunements.STATE.COMPLETED)

            -- Get progress for attunement
            local attunementData = Attunements:GetAttunementData(raidKey)
            if attunementData and attunementData.chapters then
                attuneTotal = #attunementData.chapters
                local progress = Attunements:GetProgress(raidKey)
                if progress and progress.chapters then
                    for _ in pairs(progress.chapters) do
                        attuneProgress = attuneProgress + 1
                    end
                end
            end
        end

        -- Gruul and Magtheridon don't require attunement
        if raidKey == "gruul" or raidKey == "magtheridon" then
            attuned = true  -- Always accessible if you can enter T4 raids
        end

        table.insert(raids, {
            key = raidKey,
            name = RAID_NAMES[raidKey],
            bossesKilled = killedCount,
            totalBosses = bossCount,
            attuned = attuned,
            attuneProgress = attuneProgress,
            attuneTotal = attuneTotal,
            cleared = killedCount >= bossCount,
        })

        totalKilled = totalKilled + killedCount
        totalBosses = totalBosses + bossCount
    end

    -- Determine tier status
    local status = "LOCKED"
    if totalKilled >= totalBosses then
        status = "CLEARED"
    elseif totalKilled > 0 then
        status = "IN_PROGRESS"
    else
        -- Check if any raid is attuned
        for _, raid in ipairs(raids) do
            if raid.attuned then
                status = "READY"
                break
            end
        end
    end

    return {
        status = status,
        bossesKilled = totalKilled,
        totalBosses = totalBosses,
        raids = raids,
        color = tierInfo.color,
        name = tierInfo.name,
    }
end

--[[
    Get current attunement progress summary
    @return table - Array of attunement status objects
]]
function Journal:GetAttunementSummary()
    local Attunements = HopeAddon.Attunements
    if not Attunements then return {} end

    local attunementOrder = { "karazhan", "ssc", "tk", "hyjal", "bt" }
    local attunementNames = {
        karazhan = "Karazhan",
        ssc = "Serpentshrine Cavern",
        tk = "Tempest Keep",
        hyjal = "Hyjal Summit",
        bt = "Black Temple",
    }

    local summary = {}

    for _, raidKey in ipairs(attunementOrder) do
        local state = Attunements:GetState(raidKey)
        local attunementData = Attunements:GetAttunementData(raidKey)
        local progress = Attunements:GetProgress(raidKey)

        local completed = 0
        local total = 0

        if attunementData and attunementData.chapters then
            total = #attunementData.chapters
            if progress and progress.chapters then
                for _ in pairs(progress.chapters) do
                    completed = completed + 1
                end
            end
        end

        table.insert(summary, {
            key = raidKey,
            name = attunementNames[raidKey],
            state = state,
            completed = completed,
            total = total,
            isComplete = (state == Attunements.STATE.COMPLETED),
        })
    end

    return summary
end

--[[
    Get key reputation standings
    @return table - Array of reputation status objects
]]
function Journal:GetKeyReputationSummary()
    local ReputationData = HopeAddon.ReputationData
    local summary = {}

    for _, repInfo in ipairs(KEY_REPUTATIONS) do
        -- Get current standing using TBC-compatible method
        local standingId = nil
        local standingName = "Unknown"
        local repValue = 0
        local repMax = 0

        -- Iterate through factions to find the one we want
        local numFactions = GetNumFactions()
        for i = 1, numFactions do
            local name, _, standId, barMin, barMax, barValue, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(i)
            if factionId == repInfo.id then
                standingId = standId
                if ReputationData and ReputationData.STANDINGS[standId] then
                    standingName = ReputationData.STANDINGS[standId].name
                end
                repValue = barValue - barMin
                repMax = barMax - barMin
                break
            end
        end

        -- Only include if we found the faction
        if standingId then
            table.insert(summary, {
                name = repInfo.name,
                standing = standingName,
                standingId = standingId or 4,
                value = repValue,
                max = repMax,
                requirement = repInfo.requirement,
                isChoice = repInfo.isChoice,
                -- Honored (6) is needed for heroic keys
                hasHeroicKey = (standingId or 0) >= 6,
            })
        end
    end

    return summary
end

--[[
    Determine what the player should focus on next
    @return table - { title, items } where items are checklist entries
]]
function Journal:GetNextFocus()
    local playerLevel = UnitLevel("player")
    local Attunements = HopeAddon.Attunements

    -- Pre-58: Focus on leveling
    if playerLevel < 58 then
        return {
            title = "REACH THE DARK PORTAL",
            subtitle = "Level " .. playerLevel .. " / 58",
            items = {
                { text = "Reach level 58", done = false, current = true },
                { text = "Journey to Blasted Lands", done = false },
                { text = "Enter the Dark Portal", done = false },
            }
        }
    end

    -- Check Karazhan attunement first
    if Attunements then
        local karaState = Attunements:GetState("karazhan")
        if karaState ~= Attunements.STATE.COMPLETED then
            local progress = Attunements:GetProgress("karazhan")
            local attunementData = Attunements:GetAttunementData("karazhan")
            local items = {}

            if attunementData and attunementData.chapters then
                for i, chapter in ipairs(attunementData.chapters) do
                    local done = progress and progress.chapters and progress.chapters[chapter.questId]
                    table.insert(items, {
                        text = chapter.title or ("Step " .. i),
                        done = done or false,
                        current = not done and #items == 0,
                    })
                    -- Only show first few uncompleted
                    if not done and #items >= 4 then break end
                end
            end

            -- Fallback if no items were added
            if #items == 0 then
                table.insert(items, { text = "Begin the attunement chain", done = false, current = true })
            end

            return {
                title = "KARAZHAN ATTUNEMENT",
                subtitle = "The Master's Key",
                items = items,
            }
        end

        -- Check SSC/TK attunements
        local sscState = Attunements:GetState("ssc")
        local tkState = Attunements:GetState("tk")

        if sscState ~= Attunements.STATE.COMPLETED or tkState ~= Attunements.STATE.COMPLETED then
            local items = {}

            -- SSC items
            if sscState ~= Attunements.STATE.COMPLETED then
                local sscProgress = Attunements:GetProgress("ssc")
                local sscData = Attunements:GetAttunementData("ssc")
                if sscData and sscData.chapters then
                    for _, chapter in ipairs(sscData.chapters) do
                        local done = sscProgress and sscProgress.chapters and sscProgress.chapters[chapter.questId]
                        if not done and #items < 3 then
                            table.insert(items, {
                                text = "[SSC] " .. (chapter.title or "Quest"),
                                done = false,
                            })
                        end
                    end
                end
            else
                table.insert(items, { text = "SSC Attuned", done = true })
            end

            -- TK items
            if tkState ~= Attunements.STATE.COMPLETED then
                local tkProgress = Attunements:GetProgress("tk")
                local tkData = Attunements:GetAttunementData("tk")
                if tkData and tkData.chapters then
                    for _, chapter in ipairs(tkData.chapters) do
                        local done = tkProgress and tkProgress.chapters and tkProgress.chapters[chapter.questId]
                        if not done and #items < 5 then
                            table.insert(items, {
                                text = "[TK] " .. (chapter.title or "Quest"),
                                done = false,
                            })
                        end
                    end
                end
            else
                table.insert(items, { text = "TK Attuned", done = true })
            end

            return {
                title = "TIER 5 ATTUNEMENTS",
                subtitle = "Champion of the Naaru",
                items = items,
            }
        end

        -- Check Hyjal/BT attunements
        local hyjalState = Attunements:GetState("hyjal")
        local btState = Attunements:GetState("bt")

        if hyjalState ~= Attunements.STATE.COMPLETED or btState ~= Attunements.STATE.COMPLETED then
            local items = {}

            if hyjalState ~= Attunements.STATE.COMPLETED then
                table.insert(items, { text = "Defeat Lady Vashj (SSC)", done = false })
                table.insert(items, { text = "Defeat Kael'thas (TK)", done = false })
            else
                table.insert(items, { text = "Hyjal Summit Access", done = true })
            end

            if btState ~= Attunements.STATE.COMPLETED then
                table.insert(items, { text = "Complete Tablets of Baa'ri", done = false })
                table.insert(items, { text = "Obtain Medallion of Karabor", done = false })
            else
                table.insert(items, { text = "Black Temple Access", done = true })
            end

            return {
                title = "TIER 6 ATTUNEMENTS",
                subtitle = "Hand of A'dal",
                items = items,
            }
        end
    end

    -- All attuned - focus on clearing content
    local t6Status = self:GetTierStatus("T6")
    if t6Status and t6Status.status ~= "CLEARED" then
        local items = {}
        for _, raid in ipairs(t6Status.raids) do
            if not raid.cleared then
                table.insert(items, {
                    text = "Clear " .. raid.name .. " (" .. raid.bossesKilled .. "/" .. raid.totalBosses .. ")",
                    done = false,
                })
            else
                table.insert(items, {
                    text = raid.name .. " Cleared",
                    done = true,
                })
            end
        end
        return {
            title = "CONQUER TIER 6",
            subtitle = "The Final Challenge",
            items = items,
        }
    end

    -- Everything done!
    return {
        title = "LEGEND OF OUTLAND",
        subtitle = "All content conquered",
        items = {
            { text = "All attunements complete", done = true },
            { text = "All raids cleared", done = true },
            { text = "You are truly prepared!", done = true },
        }
    }
end

--[[
    Create the "YOU ARE PREPARED" summary header
]]
function Journal:CreateJourneySummaryHeader()
    local Components = HopeAddon.Components
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 70)

    -- Title: YOU ARE PREPARED
    local title = container.summaryTitle
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.summaryTitle = title
    end
    title:SetFont(HopeAddon.assets.fonts.TITLE, 24)
    title:ClearAllPoints()
    title:SetPoint("TOP", container, "TOP", 0, -10)
    title:SetText(HopeAddon:ColorText("YOU ARE PREPARED", "FEL_GREEN"))
    title:Show()  -- Explicit show for pooled container children

    -- Subtitle with player name
    local subtitle = container.summarySubtitle
    if not subtitle then
        subtitle = container:CreateFontString(nil, "OVERLAY")
        container.summarySubtitle = subtitle
    end
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 12)
    subtitle:ClearAllPoints()
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    local playerName = UnitName("player")
    local _, class = UnitClass("player")
    local classColor = HopeAddon:GetClassColor(class)
    subtitle:SetText(string.format("The journey of |cFF%02x%02x%02x%s|r through Outland",
        classColor.r * 255, classColor.g * 255, classColor.b * 255, playerName))
    subtitle:Show()  -- Explicit show for pooled container children

    return container
end

--[[
    Create tier progress cards (T4, T5, T6)
]]
function Journal:CreateTierProgressSection()
    local Components = HopeAddon.Components
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 140)

    -- Section title
    local sectionTitle = container.tierSectionTitle
    if not sectionTitle then
        sectionTitle = container:CreateFontString(nil, "OVERLAY")
        container.tierSectionTitle = sectionTitle
    end
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    sectionTitle:SetText(HopeAddon:ColorText("RAID PROGRESSION", "GOLD_BRIGHT"))
    sectionTitle:Show()  -- Explicit show for pooled container children

    -- Create 3 tier cards side by side
    local tiers = { "T4", "T5", "T6" }
    local cardWidth = 150
    local cardHeight = 100
    local spacing = 10
    local totalWidth = (cardWidth * 3) + (spacing * 2)
    -- Use constant width since container hasn't been added to scroll yet
    local startX = (CONTAINER_WIDTH - totalWidth) / 2

    for i, tierKey in ipairs(tiers) do
        local tierStatus = self:GetTierStatus(tierKey)
        if tierStatus then
            local cardKey = "tierCard" .. tierKey
            local card = container[cardKey]

            if not card then
                card = CreateFrame("Frame", nil, container, "BackdropTemplate")
                card:SetSize(cardWidth, cardHeight)
                card:SetBackdrop(HopeAddon.Constants.BACKDROPS.SOLID_TOOLTIP)
                container[cardKey] = card

                -- Tier name
                card.tierName = card:CreateFontString(nil, "OVERLAY")
                card.tierName:SetFont(HopeAddon.assets.fonts.HEADER, 13)
                card.tierName:SetPoint("TOP", card, "TOP", 0, -8)

                -- Status text
                card.statusText = card:CreateFontString(nil, "OVERLAY")
                card.statusText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
                card.statusText:SetPoint("TOP", card.tierName, "BOTTOM", 0, -2)

                -- Progress text
                card.progressText = card:CreateFontString(nil, "OVERLAY")
                card.progressText:SetFont(HopeAddon.assets.fonts.BODY, 11)
                card.progressText:SetPoint("TOP", card.statusText, "BOTTOM", 0, -8)

                -- Raid list
                card.raidList = card:CreateFontString(nil, "OVERLAY")
                card.raidList:SetFont(HopeAddon.assets.fonts.SMALL, 9)
                card.raidList:SetPoint("BOTTOM", card, "BOTTOM", 0, 8)
                card.raidList:SetWidth(140)  -- cardWidth - 10
                card.raidList:SetJustifyH("CENTER")
            end

            -- Position card
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", container, "TOPLEFT", startX + (i-1) * (cardWidth + spacing), -25)

            -- Set background color based on status
            local bgColor = { 0.1, 0.1, 0.1, 0.8 }
            local borderColor = { 0.3, 0.3, 0.3, 1 }

            if tierStatus.status == "CLEARED" then
                bgColor = { 0.1, 0.2, 0.1, 0.9 }
                borderColor = { 0.0, 0.8, 0.0, 1 }
            elseif tierStatus.status == "IN_PROGRESS" then
                bgColor = { 0.15, 0.15, 0.1, 0.9 }
                borderColor = { 0.8, 0.7, 0.0, 1 }
            elseif tierStatus.status == "READY" then
                bgColor = { 0.1, 0.1, 0.15, 0.9 }
                borderColor = { 0.4, 0.4, 0.8, 1 }
            end

            card:SetBackdropColor(unpack(bgColor))
            card:SetBackdropBorderColor(unpack(borderColor))

            -- Set text
            card.tierName:SetText(HopeAddon:ColorText(tierStatus.name, tierStatus.color))
            card.tierName:Show()  -- Explicit show for pooled children

            local statusColors = {
                LOCKED = "CC4444",
                READY = "4488CC",
                IN_PROGRESS = "CCAA44",
                CLEARED = "44CC44",
            }
            card.statusText:SetText("|cFF" .. (statusColors[tierStatus.status] or "FFFFFF") .. tierStatus.status .. "|r")
            card.statusText:Show()  -- Explicit show for pooled children

            card.progressText:SetText(tierStatus.bossesKilled .. " / " .. tierStatus.totalBosses .. " bosses")
            card.progressText:Show()  -- Explicit show for pooled children

            -- Build raid list
            local raidLines = {}
            for _, raid in ipairs(tierStatus.raids) do
                local checkmark = raid.cleared and "|cFF44CC44[X]|r" or (raid.bossesKilled > 0 and "|cFFCCAA44[-]|r" or "|cFF666666[ ]|r")
                table.insert(raidLines, checkmark .. " " .. raid.name)
            end
            card.raidList:SetText(table.concat(raidLines, "\n"))
            card.raidList:Show()  -- Explicit show for pooled children

            card:Show()
        end
    end

    return container
end

--[[
    Create the "What to Focus On" panel
]]
function Journal:CreateFocusPanel()
    local Components = HopeAddon.Components
    local focus = self:GetNextFocus()

    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 95 + (#focus.items * 16))

    -- Section title
    local sectionTitle = container.focusSectionTitle
    if not sectionTitle then
        sectionTitle = container:CreateFontString(nil, "OVERLAY")
        container.focusSectionTitle = sectionTitle
    end
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    sectionTitle:SetText(HopeAddon:ColorText("CURRENT FOCUS", "GOLD_BRIGHT"))
    sectionTitle:Show()  -- Explicit show for pooled container children

    -- Focus title
    local focusTitle = container.focusTitle
    if not focusTitle then
        focusTitle = container:CreateFontString(nil, "OVERLAY")
        container.focusTitle = focusTitle
    end
    focusTitle:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    focusTitle:ClearAllPoints()
    focusTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -25)
    focusTitle:SetText(HopeAddon:ColorText(focus.title, "FEL_GREEN"))

    -- Focus subtitle
    local focusSubtitle = container.focusSubtitle
    if not focusSubtitle then
        focusSubtitle = container:CreateFontString(nil, "OVERLAY")
        container.focusSubtitle = focusSubtitle
    end
    focusSubtitle:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    focusSubtitle:ClearAllPoints()
    focusSubtitle:SetPoint("TOPLEFT", focusTitle, "BOTTOMLEFT", 0, -2)
    focusSubtitle:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
    focusSubtitle:SetText(focus.subtitle)

    -- Checklist items
    local yOffset = -55
    for i, item in ipairs(focus.items) do
        local itemKey = "focusItem" .. i
        local itemText = container[itemKey]
        if not itemText then
            itemText = container:CreateFontString(nil, "OVERLAY")
            container[itemKey] = itemText
        end
        itemText:SetFont(HopeAddon.assets.fonts.BODY, 11)
        itemText:ClearAllPoints()
        itemText:SetPoint("TOPLEFT", container, "TOPLEFT", 30, yOffset)

        local checkmark = item.done and "|cFF44CC44[X]|r" or "|cFF666666[ ]|r"
        local textColor = item.done and "44CC44" or (item.current and "FFFFFF" or "AAAAAA")
        itemText:SetText(checkmark .. " |cFF" .. textColor .. item.text .. "|r")
        itemText:Show()

        yOffset = yOffset - 16
    end

    -- Hide any extra item texts
    for i = #focus.items + 1, 10 do
        local itemKey = "focusItem" .. i
        if container[itemKey] then
            container[itemKey]:Hide()
        end
    end

    return container
end

--[[
    Create attunement summary row
]]
function Journal:CreateAttunementSummary()
    local Components = HopeAddon.Components
    local attunements = self:GetAttunementSummary()

    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 90)

    -- Section title
    local sectionTitle = container.attuneSectionTitle
    if not sectionTitle then
        sectionTitle = container:CreateFontString(nil, "OVERLAY")
        container.attuneSectionTitle = sectionTitle
    end
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    sectionTitle:SetText(HopeAddon:ColorText("ATTUNEMENTS", "GOLD_BRIGHT"))

    -- Attunement items
    local yOffset = -25
    for i, attune in ipairs(attunements) do
        local itemKey = "attuneItem" .. i
        local itemText = container[itemKey]
        if not itemText then
            itemText = container:CreateFontString(nil, "OVERLAY")
            container[itemKey] = itemText
        end
        itemText:SetFont(HopeAddon.assets.fonts.BODY, 10)
        itemText:ClearAllPoints()
        itemText:SetPoint("TOPLEFT", container, "TOPLEFT", 20, yOffset)

        local status
        if attune.isComplete then
            status = "|cFF44CC44[X]|r"
        elseif attune.completed > 0 then
            status = "|cFFCCAA44[" .. attune.completed .. "/" .. attune.total .. "]|r"
        else
            status = "|cFF666666[ ]|r"
        end

        local textColor = attune.isComplete and "44CC44" or (attune.completed > 0 and "CCAA44" or "888888")
        itemText:SetText(status .. " |cFF" .. textColor .. attune.name .. "|r")
        itemText:Show()

        yOffset = yOffset - 13
    end

    return container
end

--[[
    Create key reputation summary
]]
function Journal:CreateReputationSummary()
    local Components = HopeAddon.Components
    local reps = self:GetKeyReputationSummary()

    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 100)

    -- Section title
    local sectionTitle = container.repSectionTitle
    if not sectionTitle then
        sectionTitle = container:CreateFontString(nil, "OVERLAY")
        container.repSectionTitle = sectionTitle
    end
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    sectionTitle:SetText(HopeAddon:ColorText("KEY REPUTATIONS", "GOLD_BRIGHT"))

    -- Reputation items (2 columns)
    local leftY = -25
    local rightY = -25
    local leftCount = 0
    local rightCount = 0

    for i, rep in ipairs(reps) do
        -- Skip choice factions if player hasn't chosen
        if not rep.isChoice or (rep.standingId and rep.standingId >= 5) then
            local itemKey = "repItem" .. i
            local itemText = container[itemKey]
            if not itemText then
                itemText = container:CreateFontString(nil, "OVERLAY")
                container[itemKey] = itemText
            end
            itemText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
            itemText:ClearAllPoints()

            -- Alternate columns
            if leftCount <= rightCount then
                itemText:SetPoint("TOPLEFT", container, "TOPLEFT", 20, leftY)
                leftY = leftY - 14
                leftCount = leftCount + 1
            else
                itemText:SetPoint("TOPLEFT", container, "TOP", 10, rightY)
                rightY = rightY - 14
                rightCount = rightCount + 1
            end

            -- Color based on standing
            local standingColors = {
                [1] = "CC0000", [2] = "FF3333", [3] = "FF8000", [4] = "FFFF00",
                [5] = "00CC00", [6] = "0099CC", [7] = "0066CC", [8] = "9933FF",
            }
            local standingColor = standingColors[rep.standingId] or "FFFFFF"
            local keyIcon = rep.hasHeroicKey and "|cFF44CC44*|r" or ""

            itemText:SetText(rep.name .. ": |cFF" .. standingColor .. rep.standing .. "|r" .. keyIcon)
            itemText:Show()
        end
    end

    return container
end

--[[
    Create timeline section header (separator before entries)
]]
function Journal:CreateTimelineSeparator()
    local Components = HopeAddon.Components
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 30)

    local header = container.timelineHeader
    if not header then
        header = container:CreateFontString(nil, "OVERLAY")
        container.timelineHeader = header
    end
    header:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    header:ClearAllPoints()
    header:SetPoint("LEFT", container, "LEFT", 10, 0)
    header:SetText(HopeAddon:ColorText("TIMELINE", "GOLD_BRIGHT"))

    -- Divider line
    local divider = container.timelineDivider
    if not divider then
        divider = container:CreateTexture(nil, "ARTWORK")
        container.timelineDivider = divider
    end
    divider:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    divider:SetHeight(1)
    divider:ClearAllPoints()
    divider:SetPoint("LEFT", header, "RIGHT", 10, 0)
    divider:SetPoint("RIGHT", container, "RIGHT", -10, 0)
    divider:Show()

    return container
end

--[[
    Main Journey tab populate function
    Includes "YOU ARE PREPARED" summary section followed by timeline entries
]]
function Journal:PopulateJourney()
    local entries = HopeAddon.charDb.journal.entries
    local Components = HopeAddon.Components
    local scrollContainer = self.mainFrame.scrollContainer

    -- === YOU ARE PREPARED SUMMARY SECTION ===

    -- 1. Header with title
    local header = self:CreateJourneySummaryHeader()
    scrollContainer:AddEntry(header)

    -- 2. Tier Progress Cards (T4/T5/T6)
    local tierSection = self:CreateTierProgressSection()
    scrollContainer:AddEntry(tierSection)

    -- 3. Current Focus Panel
    local focusPanel = self:CreateFocusPanel()
    scrollContainer:AddEntry(focusPanel)

    -- 4. Attunement Summary (compact)
    local attuneSection = self:CreateAttunementSummary()
    scrollContainer:AddEntry(attuneSection)

    -- 5. Key Reputations (compact)
    local repSection = self:CreateReputationSummary()
    scrollContainer:AddEntry(repSection)

    -- === TIMELINE SECTION ===

    -- Separator
    local separator = self:CreateTimelineSeparator()
    scrollContainer:AddEntry(separator)

    -- Use cached sorted entries if available (performance optimization)
    -- Cache is invalidated when new entries are added via InvalidateCounts()
    if not self.timelineCacheValid or not self.cachedSortedTimeline then
        self.cachedSortedTimeline = {}
        for _, entry in ipairs(entries) do
            table.insert(self.cachedSortedTimeline, entry)
        end
        table.sort(self.cachedSortedTimeline, function(a, b)
            return (a.timestamp or "") > (b.timestamp or "")
        end)
        self.timelineCacheValid = true
    end

    for _, entry in ipairs(self.cachedSortedTimeline) do
        local card = self:AcquireCard(scrollContainer.content, {
            icon = entry.icon,
            title = entry.title,
            description = entry.description or entry.story,
            timestamp = entry.timestamp,
        })
        scrollContainer:AddEntry(card)
    end

    -- If no entries, show placeholder
    if #entries == 0 then
        local placeholderFrame = self:AcquireContainer(scrollContainer.content, 100)

        local placeholder = placeholderFrame.headerText
        if not placeholder then
            placeholder = placeholderFrame:CreateFontString(nil, "OVERLAY")
            placeholderFrame.headerText = placeholder
        end
        placeholder:SetFont(HopeAddon.assets.fonts.BODY, 12)
        placeholder:ClearAllPoints()
        placeholder:SetPoint("CENTER", placeholderFrame, "CENTER", 0, 0)
        placeholder:SetText("Your journey awaits...\n\nLevel up to record your first milestone!")
        placeholder:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
        placeholder:SetJustifyH("CENTER")

        scrollContainer:AddEntry(placeholderFrame)
    end
end

--[[
    Create the chronicle header with title, subtitle, and progress bar
    Used by Journey tab to show milestone progress
    @return Frame - Header container
]]
function Journal:CreateChronicleHeader()
    local Components = HopeAddon.Components
    local milestones = HopeAddon.charDb.journal.levelMilestones
    local playerName = UnitName("player")

    -- Calculate completed milestone count
    local totalMilestones = 15  -- Total milestone levels
    local completedCount = 0
    for _ in pairs(milestones) do
        completedCount = completedCount + 1
    end

    -- Container for the header
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 110)

    -- Main title in Morpheus font
    local title = container.titleText
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.titleText = title
    end
    title:SetFont(HopeAddon.assets.fonts.TITLE, 22)
    title:ClearAllPoints()
    title:SetPoint("TOP", container, "TOP", 0, -10)
    title:SetText(HopeAddon:ColorText("THE HERO'S JOURNEY", "GOLD_BRIGHT"))
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 0.8)

    -- Subtitle with character name
    local subtitle = container.subtitleText
    if not subtitle then
        subtitle = container:CreateFontString(nil, "OVERLAY")
        container.subtitleText = subtitle
    end
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 13)
    subtitle:ClearAllPoints()
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetText("The Chronicle of " .. playerName)
    subtitle:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))

    -- Decorative divider line
    local divider = container.dividerLine
    if not divider then
        divider = container:CreateTexture(nil, "ARTWORK")
        container.dividerLine = divider
    end
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:ClearAllPoints()
    divider:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -60, -8)
    divider:SetPoint("TOPRIGHT", subtitle, "BOTTOMRIGHT", 60, -8)
    divider:SetVertexColor(HopeAddon:GetColor("GOLD_BRIGHT"))

    -- Progress bar showing overall completion
    local progressBar = container.progressBar
    if not progressBar then
        progressBar = Components:CreateProgressBar(container, 300, 20, "GOLD_BRIGHT")
        container.progressBar = progressBar
    end
    progressBar:ClearAllPoints()
    progressBar:SetPoint("TOP", divider, "BOTTOM", 0, -12)
    progressBar:SetProgress((completedCount / totalMilestones) * 100)

    -- Progress text below bar
    local progressText = container.progressLabel
    if not progressText then
        progressText = container:CreateFontString(nil, "OVERLAY")
        container.progressLabel = progressText
    end
    progressText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    progressText:ClearAllPoints()
    progressText:SetPoint("TOP", progressBar, "BOTTOM", 0, -5)
    progressText:SetText(string.format("%d of %d milestones completed", completedCount, totalMilestones))
    progressText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))

    return container
end

function Journal:PopulateReputation()
    local Components = HopeAddon.Components
    local Data = HopeAddon.ReputationData
    local Reputation = HopeAddon:GetModule("Reputation")

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("FACTION STANDING", "ARCANE_PURPLE", "Your reputation across Outland")
    self.mainFrame.scrollContainer:AddEntry(header)

    -- Check for Aldor/Scryers choice
    local choice = HopeAddon.charDb.reputation and HopeAddon.charDb.reputation.aldorScryerChoice
    if choice then
        local choiceCard = self:CreateReputationCard({
            name = "The Choice",
            icon = "INV_Jewelry_Ring_54",
            description = "You allied with " .. choice.chosen .. " on " .. choice.date,
            standingId = 8, -- Use exalted color for importance
            standingName = choice.chosen,
            isSpecial = true,
        })
        self.mainFrame.scrollContainer:AddEntry(choiceCard)

        local choiceSpacer = self:CreateSpacer(15)
        self.mainFrame.scrollContainer:AddEntry(choiceSpacer)
    end

    -- Iterate through categories in order
    local categories = Data:GetOrderedCategories()

    for _, catInfo in ipairs(categories) do
        local catId = catInfo.id
        local catData = catInfo.data

        -- Get factions for this category
        local factions = Data:GetFactionsByCategory(catId)

        if #factions > 0 then
            -- Category header - properly added to scroll
            local catHeader = self:CreateCategoryHeader(string.upper(catData.name), "GOLD_BRIGHT")
            self.mainFrame.scrollContainer:AddEntry(catHeader)

            -- Show factions
            for _, factionInfo in ipairs(factions) do
                local factionName = factionInfo.name
                local factionData = factionInfo.data

                -- Skip opposing faction if choice was made
                if choice and factionData.isChoice and factionName == choice.opposing then
                    -- Skip this faction - we chose the other
                else
                    local card = self:CreateReputationCard({
                        name = factionName,
                        data = factionData,
                    })
                    self.mainFrame.scrollContainer:AddEntry(card)
                end
            end

            -- Spacer between categories
            local categorySpacer = self:CreateSpacer(15)
            self.mainFrame.scrollContainer:AddEntry(categorySpacer)
        end
    end
end

function Journal:CreateReputationCard(info)
    local Components = HopeAddon.Components
    local Data = HopeAddon.ReputationData
    local Effects = HopeAddon.Effects
    local Reputation = HopeAddon:GetModule("Reputation")

    -- Get current standing
    local standingId = 4 -- Default neutral
    local standingName = "Neutral"
    local current, max = 0, 0

    if info.isSpecial then
        -- Special card (like "The Choice")
        standingId = info.standingId or 8
        standingName = info.standingName or ""
    elseif info.data then
        -- Get live standing data
        local cached = Reputation and Reputation:GetFactionStanding(info.name)
        if cached then
            standingId = cached.standingId
            local standingInfo = Data:GetStandingInfo(standingId)
            standingName = standingInfo and standingInfo.name or "Unknown"
        end

        -- Get progress
        if Reputation then
            local curr, mx, _ = Reputation:GetProgressInStanding(info.name)
            if curr then current = curr end
            if mx then max = mx end
        end
    end

    local standingInfo = Data:GetStandingInfo(standingId)
    local r, g, b = Data:GetStandingColor(standingId)

    -- Determine icon
    local icon = "Interface\\Icons\\"
    if info.isSpecial then
        icon = icon .. (info.icon or "INV_Misc_QuestionMark")
    elseif info.data then
        icon = icon .. (info.data.icon or "INV_Misc_QuestionMark")
    end

    -- Build description
    local description = ""
    if info.isSpecial then
        description = info.description or ""
    elseif info.data then
        description = info.data.description or ""

        -- Add lore if we have milestones
        local milestones = HopeAddon.charDb.reputation and HopeAddon.charDb.reputation.milestones
        if milestones and milestones[info.name] and milestones[info.name][standingId] then
            local milestone = milestones[info.name][standingId]
            description = milestone.story or description
        end

        -- Add progress info
        if max > 0 then
            description = description .. string.format("\n\nProgress: %d / %d", current, max)
        end
    end

    -- Determine if we need progress bar (affects card height)
    local needsProgressBar = not info.isSpecial and info.data and standingId < 8 and max > 0

    -- Create card
    local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
        icon = icon,
        title = info.name,
        description = description,
        timestamp = standingName,
    })

    -- Increase card height if progress bar needed to prevent overlap
    if needsProgressBar then
        card:SetHeight(95)
    end

    -- Set border color based on standing
    card:SetBackdropBorderColor(r, g, b, 1)
    card.defaultBorderColor = {r, g, b, 1}  -- Store for hover restore

    -- Add RPG-themed progress bar for non-exalted factions
    if needsProgressBar then
        -- Calculate bar width: card width - icon - margins
        local barWidth = card:GetWidth() - Components.ICON_SIZE_STANDARD - 3 * Components.MARGIN_NORMAL - 60 -- 60 for badge
        local reputationBar = Components:CreateReputationBar(card, barWidth, 12, {
            compact = true,
            showStandingBadge = true,
            showTickMarks = true,
            showAnimations = true,
        })
        reputationBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",
            Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL, 10)
        reputationBar:SetReputation(info.name, current, max, standingId)
        card.reputationBar = reputationBar
    end

    -- Add golden glow for Exalted (the reputation bar handles its own effects,
    -- but we keep the card glow for consistency with other completed cards)
    if standingId == 8 then
        Effects:CreatePulsingGlow(card, "GOLD_BRIGHT", 0.3)
    end

    return card
end

function Journal:PopulateAttunements()
    local Components = HopeAddon.Components
    local Attunements = HopeAddon.Attunements
    local C = HopeAddon.Constants

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("RAID ATTUNEMENTS", "ARCANE_PURPLE", "Your path through TBC raid content")
    self.mainFrame.scrollContainer:AddEntry(header)

    -- Tier colors
    local tierColors = {
        T4 = "GOLD_BRIGHT",
        T5 = "SKY_BLUE",
        T6 = "HELLFIRE_RED",
    }

    -- Display all attunements
    local allAttunements = Attunements:GetAllAttunements()

    for _, attunementInfo in ipairs(allAttunements) do
        local raidKey = attunementInfo.key
        local tier = attunementInfo.tier
        local tierColor = tierColors[tier] or "ARCANE_PURPLE"

        local summary = Attunements:GetSummary(raidKey)
        local attunementData = Attunements:GetAttunementData(raidKey)
        if not attunementData then
            -- Skip if no data
        else
            -- Attunement section header - FontString properly parented to container
            local headerContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 25)
            local raidHeader = headerContainer.headerText
            if not raidHeader then
                raidHeader = headerContainer:CreateFontString(nil, "OVERLAY")
                headerContainer.headerText = raidHeader
            end
            raidHeader:ClearAllPoints()
            raidHeader:SetFont(HopeAddon.assets.fonts.HEADER, 13)
            raidHeader:SetPoint("TOPLEFT", headerContainer, "TOPLEFT", Components.MARGIN_NORMAL, -3)
            raidHeader:SetText(HopeAddon:ColorText(
                string.format("[%s] %s", tier, summary.raidName),
                tierColor
            ))
            self.mainFrame.scrollContainer:AddEntry(headerContainer)

            -- Sub-title with attunement chain name - FontString parented to container
            local chainContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 18)
            local chainName = chainContainer.headerText
            if not chainName then
                chainName = chainContainer:CreateFontString(nil, "OVERLAY")
                chainContainer.headerText = chainName
            end
            chainName:ClearAllPoints()
            chainName:SetFont(HopeAddon.assets.fonts.BODY, 11)
            chainName:SetPoint("TOPLEFT", chainContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
            chainName:SetText(summary.name)
            chainName:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
            self.mainFrame.scrollContainer:AddEntry(chainContainer)

            -- Show prerequisite if any
            if summary.prerequisite then
                local prereqContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 15)
                local prereqText = prereqContainer.headerText
                if not prereqText then
                    prereqText = prereqContainer:CreateFontString(nil, "OVERLAY")
                    prereqContainer.headerText = prereqText
                end
                prereqText:ClearAllPoints()
                prereqText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
                prereqText:SetPoint("TOPLEFT", prereqContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
                prereqText:SetText("Requires: " .. summary.prerequisite)
                prereqText:SetTextColor(1, 0.5, 0.3, 1)
                self.mainFrame.scrollContainer:AddEntry(prereqContainer)
            end

            -- Progress bar
            local progressBar = Components:CreateProgressBar(
                self.mainFrame.scrollContainer.content,
                self.mainFrame.scrollContainer.content:GetWidth() - 30,
                20,
                summary.isAttuned and "FEL_GREEN" or tierColor
            )
            progressBar:SetProgress(summary.percentage)

            -- Progress text overlay
            local progressText = progressBar:CreateFontString(nil, "OVERLAY")
            progressText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
            progressText:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
            progressText:SetText(string.format("%d/%d Chapters (%d%%)",
                summary.completedChapters, summary.totalChapters, summary.percentage))
            progressText:SetTextColor(1, 1, 1, 1)

            local progressContainer = self:CreateSpacer(Components.MARGIN_LARGE)
            self.mainFrame.scrollContainer:AddEntry(progressContainer)

            -- Add glow if complete
            if summary.isAttuned then
                HopeAddon.Effects:CreatePulsingGlow(progressBar, "GOLD_BRIGHT", 0.4)

                -- Show title if applicable - FontString parented to container
                if summary.title then
                    local titleContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 18)
                    local titleText = titleContainer.headerText
                    if not titleText then
                        titleText = titleContainer:CreateFontString(nil, "OVERLAY")
                        titleContainer.headerText = titleText
                    end
                    titleText:ClearAllPoints()
                    titleText:SetFont(HopeAddon.assets.fonts.BODY, 10)
                    titleText:SetPoint("TOPLEFT", titleContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
                    titleText:SetText("Title: " .. HopeAddon:ColorText(summary.title, "GOLD_BRIGHT"))
                    self.mainFrame.scrollContainer:AddEntry(titleContainer)
                end
            end

            -- Show chapters (collapsed by default, expandable)
            local chapters = Attunements:GetChaptersForRaid(raidKey)

            for i, chapter in ipairs(chapters) do
                local chapterDetails = Attunements:GetChapterDetails(raidKey, i)
                local isComplete = chapterDetails and chapterDetails.complete

                local statusIcon = isComplete and "|cFF00FF00[+]|r " or "|cFF666666[ ]|r "

                -- Build description using table.concat for efficiency
                local descParts = { chapter.story or "" }

                -- NEW: Add quest giver and location
                if chapter.questGiver then
                    local locText = chapter.questGiver
                    if chapter.location then
                        locText = locText .. " - " .. chapter.location
                    end
                    descParts[#descParts + 1] = HopeAddon:ColorText("Quest Giver: " .. locText, "GOLD_BRIGHT")
                end

                -- NEW: Add difficulty badge
                if chapter.difficulty then
                    local diffData = C.ATTUNEMENT_DIFFICULTY[chapter.difficulty]
                    if diffData then
                        descParts[#descParts + 1] = HopeAddon:ColorText("Difficulty: " .. diffData.label, diffData.color)
                    end
                end

                -- Add dungeon/raid requirements
                if chapter.dungeon then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Dungeon: " .. chapter.dungeon, "SKY_BLUE")
                end
                if chapter.dungeons then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Dungeons: " .. table.concat(chapter.dungeons, ", "), "SKY_BLUE")
                end
                if chapter.raid then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Raid: " .. chapter.raid, "HELLFIRE_RED")
                end
                if chapter.boss then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Boss: " .. chapter.boss, "HELLFIRE_ORANGE")
                end
                if chapter.requires and type(chapter.requires) == "string" then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Requires: " .. chapter.requires, "BRONZE")
                elseif chapter.requires and type(chapter.requires) == "table" then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Requires: " .. table.concat(chapter.requires, ", "), "BRONZE")
                end
                local descText = table.concat(descParts, "\n")

                local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
                    icon = "Interface\\Icons\\" .. attunementData.icon,
                    title = statusIcon .. "Ch. " .. i .. ": " .. chapter.name,
                    description = descText,
                    timestamp = isComplete and (chapterDetails.completedDate or "Complete") or "",
                })

                -- Store tips for tooltip
                if chapter.tips and #chapter.tips > 0 then
                    card.tips = chapter.tips
                    card.chapterName = chapter.name
                end

                if isComplete then
                    card:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                elseif chapter.noFactionChosen then
                    card:SetBackdropBorderColor(1, 0.5, 0.3, 1) -- Orange for no faction chosen
                else
                    card:SetAlpha(0.7)
                end

                -- Enhanced tooltip with tips on hover
                local oldOnEnter = card:GetScript("OnEnter")
                card:SetScript("OnEnter", function(self)
                    if oldOnEnter then oldOnEnter(self) end
                    if self.tips and #self.tips > 0 then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(self.chapterName .. " - Tips", 1, 0.84, 0)
                        for _, tip in ipairs(self.tips) do
                            GameTooltip:AddLine("- " .. tip, 0.8, 0.8, 0.8, true)
                        end
                        GameTooltip:Show()
                    end
                end)
                local oldOnLeave = card:GetScript("OnLeave")
                card:SetScript("OnLeave", function(self)
                    if oldOnLeave then oldOnLeave(self) end
                    GameTooltip:Hide()
                end)

                self.mainFrame.scrollContainer:AddEntry(card)
            end

            -- Spacer between attunements
            local attuneSpacer = self:CreateSpacer(Components.SECTION_SPACER)
            self.mainFrame.scrollContainer:AddEntry(attuneSpacer)
        end
    end

    -- Cipher of Damnation section (TK prerequisite)
    local cipherSpacer = self:CreateSpacer(Components.SECTION_SPACER)
    self.mainFrame.scrollContainer:AddEntry(cipherSpacer)

    -- Cipher header - FontStrings properly parented to container
    local cipherHeaderContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 40)
    local cipherHeader = cipherHeaderContainer.headerText
    if not cipherHeader then
        cipherHeader = cipherHeaderContainer:CreateFontString(nil, "OVERLAY")
        cipherHeaderContainer.headerText = cipherHeader
    end
    cipherHeader:ClearAllPoints()
    cipherHeader:SetFont(HopeAddon.assets.fonts.HEADER, 13)
    cipherHeader:SetPoint("TOPLEFT", cipherHeaderContainer, "TOPLEFT", Components.MARGIN_NORMAL, -3)
    cipherHeader:SetText(HopeAddon:ColorText("[PREREQUISITE] Cipher of Damnation", "HELLFIRE_ORANGE"))

    local cipherSubHeader = cipherHeaderContainer.subText
    if not cipherSubHeader then
        cipherSubHeader = cipherHeaderContainer:CreateFontString(nil, "OVERLAY")
        cipherHeaderContainer.subText = cipherSubHeader
    end
    cipherSubHeader:SetFont(HopeAddon.assets.fonts.BODY, 10)
    cipherSubHeader:ClearAllPoints()
    cipherSubHeader:SetPoint("TOPLEFT", cipherHeader, "BOTTOMLEFT", 0, -3)
    cipherSubHeader:SetText("Required before starting Tempest Key attunement")
    cipherSubHeader:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
    self.mainFrame.scrollContainer:AddEntry(cipherHeaderContainer)

    local cipherSummary = Attunements:GetSummary("cipher")
    local cipherProgressBar = Components:CreateProgressBar(
        self.mainFrame.scrollContainer.content,
        self.mainFrame.scrollContainer.content:GetWidth() - 30,
        18,
        cipherSummary.isAttuned and "FEL_GREEN" or "HELLFIRE_ORANGE"
    )
    cipherProgressBar:SetProgress(cipherSummary.percentage)

    local cipherProgressText = cipherProgressBar:CreateFontString(nil, "OVERLAY")
    cipherProgressText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
    cipherProgressText:SetPoint("CENTER", cipherProgressBar, "CENTER", 0, 0)
    cipherProgressText:SetText(string.format("%d/%d (%d%%)",
        cipherSummary.completedChapters, cipherSummary.totalChapters, cipherSummary.percentage))
    cipherProgressText:SetTextColor(1, 1, 1, 1)

    local cipherProgressContainer = self:CreateSpacer(Components.MARGIN_LARGE)
    self.mainFrame.scrollContainer:AddEntry(cipherProgressContainer)

    -- Add Heroic Keys section
    self:PopulateHeroicKeys()
end

--[[
    Helper to get faction standing by ID
    @param factionId number - WoW faction ID
    @return number - Standing ID (1=Hated to 8=Exalted)
]]
function Journal:GetFactionStanding(factionId)
    local numFactions = GetNumFactions()
    for i = 1, numFactions do
        local _, _, standingId, _, _, _, _, _, _, _, _, _, _, fId = GetFactionInfo(i)
        if fId == factionId then
            return standingId or 4  -- Default to Neutral if not found
        end
    end
    return 4  -- Neutral
end

--[[
    Populate Heroic Dungeon Keys section
    Shows reputation-gated heroic access keys with tracking
]]
function Journal:PopulateHeroicKeys()
    local Components = HopeAddon.Components
    local C = HopeAddon.Constants

    -- Section divider
    local divider = Components:CreateDivider(self.mainFrame.scrollContainer.content)
    self.mainFrame.scrollContainer:AddEntry(divider)

    -- Header
    local header = self:CreateSectionHeader("HEROIC DUNGEON KEYS", "ARCANE_PURPLE", "Reputation-gated heroic access")
    self.mainFrame.scrollContainer:AddEntry(header)

    -- Get player faction for dual-faction keys
    local playerFaction = UnitFactionGroup("player")
    local isAlliance = playerFaction == "Alliance"

    -- Standing names lookup
    local standingNames = {
        [1] = "Hated",
        [2] = "Hostile",
        [3] = "Unfriendly",
        [4] = "Neutral",
        [5] = "Friendly",
        [6] = "Honored",
        [7] = "Revered",
        [8] = "Exalted",
    }

    for _, keyId in ipairs(C.HEROIC_KEY_ORDER) do
        local keyData = C.HEROIC_KEYS[keyId]
        if keyData then
            -- Determine which faction to check
            local factionName, factionId
            if keyData.faction then
                factionName = keyData.faction
                factionId = keyData.factionId
            else
                -- Dual-faction key (Honor Hold / Thrallmar)
                if isAlliance then
                    factionName = keyData.factionAlliance
                    factionId = keyData.factionId.alliance
                else
                    factionName = keyData.factionHorde
                    factionId = keyData.factionId.horde
                end
            end

            -- Get current standing
            local standingId = self:GetFactionStanding(factionId)
            local hasKey = standingId >= keyData.requiredStanding
            local standingName = standingNames[standingId] or "Unknown"
            local requiredName = standingNames[keyData.requiredStanding] or "Revered"

            -- Status icon
            local statusIcon = hasKey and "|cFF00FF00[+]|r " or "|cFF666666[ ]|r "

            -- Build description
            local descParts = {
                keyData.description,
                HopeAddon:ColorText("Faction: " .. factionName, "GOLD_BRIGHT"),
                HopeAddon:ColorText("Current: " .. standingName .. " | Required: " .. requiredName,
                    hasKey and "FEL_GREEN" or "HELLFIRE_ORANGE"),
                HopeAddon:ColorText("Dungeons: " .. table.concat(keyData.dungeons, ", "), "SKY_BLUE"),
            }
            local descText = table.concat(descParts, "\n")

            local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
                icon = "Interface\\Icons\\" .. keyData.icon,
                title = statusIcon .. keyData.name,
                description = descText,
                timestamp = hasKey and "Obtained" or "",
            })

            -- Store tips for tooltip
            if keyData.tips and #keyData.tips > 0 then
                card.tips = keyData.tips
                card.keyName = keyData.name
            end

            if hasKey then
                card:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
            else
                card:SetAlpha(0.7)
            end

            -- Tooltip with tips on hover
            local oldOnEnter = card:GetScript("OnEnter")
            card:SetScript("OnEnter", function(self)
                if oldOnEnter then oldOnEnter(self) end
                if self.tips and #self.tips > 0 then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(self.keyName .. " - Reputation Tips", 1, 0.84, 0)
                    for _, tip in ipairs(self.tips) do
                        GameTooltip:AddLine("- " .. tip, 0.8, 0.8, 0.8, true)
                    end
                    GameTooltip:Show()
                end
            end)
            local oldOnLeave = card:GetScript("OnLeave")
            card:SetScript("OnLeave", function(self)
                if oldOnLeave then oldOnLeave(self) end
                GameTooltip:Hide()
            end)

            self.mainFrame.scrollContainer:AddEntry(card)
        end
    end

    -- Spacer
    local spacer = self:CreateSpacer(15)
    self.mainFrame.scrollContainer:AddEntry(spacer)
end

function Journal:PopulateRaids()
    local Components = HopeAddon.Components
    local RaidData = HopeAddon.RaidData
    local colors = HopeAddon.colors
    local scrollContainer = self.mainFrame.scrollContainer

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("RAID PROGRESS", "HELLFIRE_RED", "Your conquest of TBC raid content")
    scrollContainer:AddEntry(header)

    -- Organized by tier
    local tierColors = {
        T4 = "GOLD_BRIGHT",
        T5 = "SKY_BLUE",
        T6 = "HELLFIRE_RED",
    }

    local raidsByTier = HopeAddon.Constants.RAIDS_BY_TIER

    local tierOrder = { "T4", "T5", "T6" }

    -- Quick jump tier buttons
    local jumpBar = self:AcquireContainer(scrollContainer.content, 30)
    self.tierSections = {}

    local buttonWidth = 60
    local buttonSpacing = 10

    for i, tier in ipairs(tierOrder) do
        local tierColorName = tierColors[tier]
        local tierColor = colors[tierColorName]

        -- Create nav button using component (includes click sound)
        local jumpBtn = Components:CreateNavButton(jumpBar, tier, buttonWidth, tierColorName, function()
            if self.tierSections[tier] then
                local section = self.tierSections[tier]
                local yOffset = 0
                for _, entry in ipairs(scrollContainer.entries) do
                    if entry == section then
                        scrollContainer.scrollFrame:SetVerticalScroll(yOffset)
                        break
                    end
                    yOffset = yOffset + entry:GetHeight() + Components.MARGIN_SMALL
                end
            end
        end)
        jumpBtn:SetPoint("LEFT", jumpBar, "LEFT", (i-1) * (buttonWidth + buttonSpacing), 0)

        -- Add tooltip
        jumpBtn:SetScript("OnEnter", function(btn)
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:SetText("Jump to " .. tier .. " Raids", tierColor.r, tierColor.g, tierColor.b)
            GameTooltip:Show()
        end)
        jumpBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    scrollContainer:AddEntry(jumpBar)

    for _, tier in ipairs(tierOrder) do
        local tierColor = tierColors[tier]
        local raids = raidsByTier[tier]

        -- Tier header - FontString properly parented to container
        local tierHeaderContainer = self:AcquireContainer(scrollContainer.content, 30)
        local tierHeader = tierHeaderContainer.headerText
        if not tierHeader then
            tierHeader = tierHeaderContainer:CreateFontString(nil, "OVERLAY")
            tierHeaderContainer.headerText = tierHeader
        end
        tierHeader:ClearAllPoints()
        tierHeader:SetFont(HopeAddon.assets.fonts.HEADER, 14)
        tierHeader:SetPoint("LEFT", tierHeaderContainer, "LEFT", Components.MARGIN_SMALL, 0)
        tierHeader:SetText(HopeAddon:ColorText("--- " .. tier .. " RAIDS ---", tierColor))
        scrollContainer:AddEntry(tierHeaderContainer)
        self.tierSections[tier] = tierHeaderContainer

        for _, raidKey in ipairs(raids) do
            local raid = RaidData:GetRaid(raidKey)
            if raid then
                local killed, total = RaidData:GetRaidProgress(raidKey)
                local raidIsCleared = killed >= total

                -- Create collapsible section for this raid
                local raidTitle = string.format("%s (%d/%d)", raid.name, killed, total)
                if raidIsCleared then
                    raidTitle = raidTitle .. " - CLEARED!"
                end

                local raidSection = self:AcquireCollapsibleSection(
                    scrollContainer.content,
                    raidTitle,
                    raidIsCleared and "FEL_GREEN" or tierColor,
                    false -- Start collapsed
                )

                raidSection.onToggle = function()
                    scrollContainer:RecalculatePositions()
                end

                -- Location and size info card (using pool for efficiency)
                local infoCard = self:AcquireBossInfoCard(
                    raidSection.contentContainer,
                    string.format("%s | %d-player", raid.location, raid.size)
                )
                raidSection:AddChild(infoCard)

                -- Boss cards
                local bosses = RaidData:GetBosses(raidKey)
                local kills = HopeAddon.charDb.journal.bossKills

                for _, boss in ipairs(bosses) do
                    local key = raidKey .. "_" .. boss.id
                    local killData = kills[key]
                    local isKilled = killData ~= nil

                    local statusIcon = isKilled and "|cFF00FF00[X]|r " or "|cFF666666[ ]|r "
                    local description
                    if isKilled then
                        -- Build description with kill count, date, and times
                        local lines = {}
                        table.insert(lines, string.format("Kills: %d | First: %s", killData.totalKills, killData.firstKill))

                        -- Show best time if available
                        if killData.bestTime then
                            local bestTimeStr = HopeAddon:FormatTime(killData.bestTime)
                            table.insert(lines, HopeAddon:ColorText("Best: " .. bestTimeStr, "GOLD_BRIGHT"))

                            -- Show last time with delta if different from best
                            if killData.lastTime and math.abs(killData.lastTime - killData.bestTime) > 0.5 then
                                local lastTimeStr = HopeAddon:FormatTime(killData.lastTime)
                                local delta = killData.lastTime - killData.bestTime
                                local deltaStr = string.format("+%.0fs", delta)
                                table.insert(lines, string.format("Last: %s (%s)",
                                    lastTimeStr, HopeAddon:ColorText(deltaStr, "HELLFIRE_RED")))
                            end
                        end

                        -- Add boss quote if available
                        if boss.quote then
                            table.insert(lines, "")
                            table.insert(lines, HopeAddon:ColorText('"' .. boss.quote .. '"', "GOLD_BRIGHT"))
                        end

                        description = table.concat(lines, "\n")
                    else
                        description = boss.lore or boss.location
                    end

                    local card = self:AcquireCard(raidSection.contentContainer, {
                        icon = "Interface\\Icons\\" .. (boss.icon or raid.icon),
                        title = statusIcon .. boss.name .. (boss.finalBoss and " (Final)" or ""),
                        description = description,
                        timestamp = boss.optional and "(Optional)" or "",
                    })

                    if isKilled then
                        card:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                        card.defaultBorderColor = { 0.2, 0.8, 0.2, 1 }
                        if boss.finalBoss then
                            card._glowEffect = HopeAddon.Effects:CreatePulsingGlow(card, "GOLD_BRIGHT", 0.3)
                        end
                    else
                        card:SetAlpha(0.6)
                    end

                    raidSection:AddChild(card)
                end

                scrollContainer:AddEntry(raidSection)

                -- Small spacer between raids
                local raidSpacer = self:CreateSpacer(8)
                scrollContainer:AddEntry(raidSpacer)
            end
        end

        -- Spacer between tiers
        local tierSpacer = self:CreateSpacer(15)
        scrollContainer:AddEntry(tierSpacer)
    end
end

--============================================================
-- DIRECTORY TAB - Games Hall + Fellow Travelers List
--============================================================
function Journal:PopulateDirectory()
    local Components = HopeAddon.Components
    local Constants = HopeAddon.Constants
    local Directory = HopeAddon.Directory
    local Relationships = HopeAddon.Relationships
    local scrollContainer = self.mainFrame.scrollContainer

    --============================================================
    -- SECTION 1: GAMES HALL (Collapsible)
    --============================================================
    local gamesSection = self:AcquireCollapsibleSection(
        scrollContainer.content,
        "GAMES HALL",
        "ARCANE_PURPLE",
        true  -- Start expanded
    )
    scrollContainer:AddEntry(gamesSection)

    -- Create game cards in a 3-column grid
    local CARD_WIDTH = 200
    local CARD_SPACING = 10
    local CARDS_PER_ROW = 3
    local ROW_HEIGHT = 115  -- Card height + spacing

    -- Get game definitions from Constants
    local games = Constants.GAME_DEFINITIONS or {}
    local row, col = 0, 0

    -- Callbacks for game card buttons
    local function onPracticeClick(gameId)
        self:StartLocalGame(gameId)
    end

    local function onChallengeClick(gameId)
        if HopeAddon.MinigamesUI then
            HopeAddon.MinigamesUI:ShowTravelerPickerForGame(gameId)
        end
    end

    -- Create cards for each game
    for i, gameData in ipairs(games) do
        local card = self:AcquireGameCard(
            gamesSection.contentContainer,
            gameData,
            onPracticeClick,
            onChallengeClick
        )

        -- Position in grid (3 columns)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", gamesSection.contentContainer, "TOPLEFT",
            col * (CARD_WIDTH + CARD_SPACING),
            -row * ROW_HEIGHT)
        card:Show()

        -- Update grid position
        col = col + 1
        if col >= CARDS_PER_ROW then
            col = 0
            row = row + 1
        end

        -- Load stats for this game
        local gameStats = self:GetGameStats(gameData.id)
        card:SetStats(gameStats.wins, gameStats.losses, gameStats.ties)

        -- Track card as child of section (for collapse/expand)
        table.insert(gamesSection.childEntries, card)
    end

    -- Update section content height based on grid
    local totalRows = math.ceil(#games / CARDS_PER_ROW)
    gamesSection.contentHeight = totalRows * ROW_HEIGHT
    gamesSection.contentContainer:SetHeight(gamesSection.contentHeight)
    gamesSection:UpdateHeight()

    -- Set toggle callback to recalculate scroll positions
    gamesSection.onToggle = function(section, isExpanded)
        scrollContainer:RecalculatePositions()
    end

    --============================================================
    -- SPACER between sections
    --============================================================
    local spacer = Components:CreateSpacer(scrollContainer.content, 15)
    spacer._pooled = false  -- Not from pool, simple frame
    scrollContainer:AddEntry(spacer)

    --============================================================
    -- SECTION 2: FELLOW TRAVELERS
    --============================================================
    local header = self:CreateSectionHeader("FELLOW TRAVELERS", "FEL_GREEN", "Addon users you have encountered")
    scrollContainer:AddEntry(header)

    -- Stats summary
    local stats = Directory and Directory:GetStats() or { fellows = 0 }
    local statsContainer = self:AcquireContainer(scrollContainer.content, 30)
    local statsText = statsContainer.headerText
    if not statsText then
        statsText = statsContainer:CreateFontString(nil, "OVERLAY")
        statsContainer.headerText = statsText
    end
    statsText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    statsText:ClearAllPoints()
    statsText:SetPoint("TOPLEFT", statsContainer, "TOPLEFT", Components.MARGIN_NORMAL, -8)
    statsText:SetText(string.format(
        "Fellow Addon Users: |cFF00FF00%d|r | Recent (7d): |cFF00FF00%d|r",
        stats.fellows, stats.recentCount or 0
    ))
    statsText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    scrollContainer:AddEntry(statsContainer)

    -- Get filtered/sorted entries
    local entries = Directory and Directory:GetFilteredEntries() or {}

    if #entries == 0 then
        -- No entries placeholder
        local placeholderFrame = self:AcquireContainer(scrollContainer.content, 150)
        local placeholder = placeholderFrame.headerText
        if not placeholder then
            placeholder = placeholderFrame:CreateFontString(nil, "OVERLAY")
            placeholderFrame.headerText = placeholder
        end
        placeholder:SetFont(HopeAddon.assets.fonts.BODY, 14)
        placeholder:ClearAllPoints()
        placeholder:SetPoint("CENTER", placeholderFrame, "CENTER", 0, 0)
        placeholder:SetText("No fellow travelers found yet...\n\nGroup up with other HopeAddon users\nto discover them automatically!")
        placeholder:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
        placeholder:SetJustifyH("CENTER")
        scrollContainer:AddEntry(placeholderFrame)
    else
        -- Create cards for each entry
        for _, entry in ipairs(entries) do
            local card = self:CreateDirectoryCard(entry)
            scrollContainer:AddEntry(card)
        end
    end
end

--[[
    Get game statistics for a specific game ID
    @param gameId string - Game identifier (dice, rps, pong, etc.)
    @return table - { wins, losses, ties }
]]
function Journal:GetGameStats(gameId)
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.travelers or not charDb.travelers.known then
        return { wins = 0, losses = 0, ties = 0 }
    end

    -- Aggregate stats across all known travelers for this game
    local totalWins, totalLosses, totalTies = 0, 0, 0

    for _, traveler in pairs(charDb.travelers.known) do
        if traveler.stats and traveler.stats.minigames then
            local gameStats = traveler.stats.minigames[gameId]
            if gameStats then
                totalWins = totalWins + (gameStats.wins or 0)
                totalLosses = totalLosses + (gameStats.losses or 0)
                totalTies = totalTies + (gameStats.ties or 0)
            end
        end
    end

    return { wins = totalWins, losses = totalLosses, ties = totalTies }
end

--[[
    Start a local (practice) game
    @param gameId string - Game identifier
]]
function Journal:StartLocalGame(gameId)
    HopeAddon:Debug("Starting local game:", gameId)

    if gameId == "dice" then
        -- Dice has local mode via Minigames
        if HopeAddon.Minigames then
            HopeAddon.Minigames:StartLocalDiceGame()
        end
    elseif gameId == "deathroll" then
        -- Death roll local practice
        if HopeAddon.Minigames then
            HopeAddon.Minigames:StartLocalDeathRoll()
        end
    elseif gameId == "pong" then
        -- Pong via GameCore
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:CreateGame("PONG", "LOCAL", nil)
        end
    elseif gameId == "tetris" then
        -- Tetris via GameCore
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:CreateGame("TETRIS", "LOCAL", nil)
        end
    else
        HopeAddon:Print("Local mode not available for " .. (gameId or "unknown"))
    end
end

--[[
    Create a directory entry card for a fellow traveler
    @param entry table - Directory entry data
    @return Frame - Card frame
]]
function Journal:CreateDirectoryCard(entry)
    local Components = HopeAddon.Components
    local Directory = HopeAddon.Directory
    local Relationships = HopeAddon.Relationships

    -- Get formatted display data
    local display = Directory and Directory:FormatEntryForDisplay(entry) or {}

    -- Get class color once for reuse (description + border)
    local classColor = entry.class and HopeAddon:GetClassColor(entry.class) or nil

    -- Build description
    local descParts = {}
    if classColor then
        local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
        table.insert(descParts, "|cFF" .. colorHex .. entry.class .. "|r")
    end
    if entry.level then
        table.insert(descParts, "Level " .. entry.level)
    end
    if entry.lastSeenZone then
        table.insert(descParts, "Last seen: " .. entry.lastSeenZone)
    end
    if entry.isFellow then
        table.insert(descParts, "|cFF00FF00[Fellow Addon User]|r")
    end

    -- Add note preview if exists
    local note = Relationships and Relationships:GetNote(entry.name) or nil
    if note then
        local notePreview = note:sub(1, 50)
        if #note > 50 then
            notePreview = notePreview .. "..."
        end
        table.insert(descParts, "|cFFFFD700Note:|r " .. notePreview)
    end

    local description = table.concat(descParts, "\n")

    -- Get class icon
    local icon = Directory and Directory:GetClassIcon(entry.class) or "Interface\\Icons\\INV_Misc_QuestionMark"

    -- Create card
    local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
        icon = icon,
        title = display.coloredName or entry.name,
        description = description,
        timestamp = entry.lastSeen or "",
    })

    -- Set border color based on class (reuse cached classColor)
    if classColor then
        card:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.8)
        card.defaultBorderColor = { classColor.r, classColor.g, classColor.b, 0.8 }
    end

    -- Add note indicator icon if has note
    if note then
        local noteIcon = card.noteIcon
        if not noteIcon then
            noteIcon = card:CreateTexture(nil, "OVERLAY")
            card.noteIcon = noteIcon
        end
        noteIcon:SetSize(16, 16)
        noteIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
        noteIcon:ClearAllPoints()
        noteIcon:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -8)
        noteIcon:Show()
    elseif card.noteIcon then
        card.noteIcon:Hide()
    end

    -- Add Challenge button for Fellow Addon Users
    if entry.isFellow then
        local challengeBtn = card.challengeBtn
        if not challengeBtn then
            challengeBtn = CreateFrame("Button", nil, card)
            card.challengeBtn = challengeBtn

            -- Icon texture (crossed swords)
            local btnIcon = challengeBtn:CreateTexture(nil, "ARTWORK")
            btnIcon:SetAllPoints()
            btnIcon:SetTexture("Interface\\Icons\\Ability_DualWield")
            challengeBtn.icon = btnIcon

            -- Highlight on hover
            local btnHighlight = challengeBtn:CreateTexture(nil, "HIGHLIGHT")
            btnHighlight:SetAllPoints()
            btnHighlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
            btnHighlight:SetBlendMode("ADD")
            btnHighlight:SetVertexColor(1, 1, 1, 0.3)

            -- Border (TBC theme: arcane purple)
            local borderColor = HopeAddon.colors.ARCANE_PURPLE
            local btnBorder = challengeBtn:CreateTexture(nil, "OVERLAY")
            btnBorder:SetPoint("TOPLEFT", challengeBtn, "TOPLEFT", -2, 2)
            btnBorder:SetPoint("BOTTOMRIGHT", challengeBtn, "BOTTOMRIGHT", 2, -2)
            btnBorder:SetTexture(HopeAddon.assets.textures.TOOLTIP_BORDER)
            btnBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, 1)
            challengeBtn.border = btnBorder

            -- Tooltip
            challengeBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Challenge to Minigame", 1, 0.84, 0)
                GameTooltip:AddLine("Dice Roll or Rock-Paper-Scissors", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            challengeBtn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- Mouse down/up feedback
            challengeBtn:SetScript("OnMouseDown", function(self)
                self.icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            end)
            challengeBtn:SetScript("OnMouseUp", function(self)
                self.icon:SetVertexColor(1, 1, 1, 1)
            end)

            -- OnClick handler - set once, uses self.targetName for dynamic player name
            challengeBtn:SetScript("OnClick", function(self)
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayClick()
                end
                if HopeAddon.MinigamesUI then
                    HopeAddon.MinigamesUI:ShowGameSelectionPopup(self.targetName)
                end
            end)
        end

        -- Position and configure (runs every render, but no new closures)
        challengeBtn:SetSize(24, 24)
        challengeBtn:ClearAllPoints()
        challengeBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 10)
        challengeBtn.targetName = entry.name
        challengeBtn:Show()
    elseif card.challengeBtn then
        card.challengeBtn:Hide()
    end

    -- Click handler to show details or add note
    card.OnCardClick = function(cardFrame, entryData)
        HopeAddon.Sounds:PlayClick()
        -- For now, just print info - future: open detail modal
        HopeAddon:Print("Viewing: " .. entry.name)
        if note then
            HopeAddon:Print("Note: " .. note)
        end
    end

    return card
end

function Journal:PopulateStats()
    local Components = HopeAddon.Components
    local stats = HopeAddon.charDb.stats
    local scrollContainer = self.mainFrame.scrollContainer

    --============================================================
    -- SECTION 1: JOURNEY STATISTICS
    --============================================================
    local header1 = self:CreateSectionHeader("JOURNEY STATISTICS", "GOLD_BRIGHT")
    scrollContainer:AddEntry(header1)

    -- Journey Began
    if HopeAddon.charDb.characterCreated then
        local card = self:AcquireCard(scrollContainer.content, {
            icon = "Interface\\Icons\\INV_Misc_Book_09",
            title = "Journey Began",
            description = "Your journey started on " .. HopeAddon.charDb.characterCreated,
            timestamp = "",
        })
        scrollContainer:AddEntry(card)
    end

    -- Total Playtime
    local playtime = stats.playtime or 0
    local playtimeStr = self:FormatPlaytime(playtime)
    local playtimeCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
        title = "Total Playtime",
        description = playtimeStr,
        timestamp = "",
    })
    scrollContainer:AddEntry(playtimeCard)

    -- Quests Completed
    local questCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        title = "Quests Completed",
        description = "Total quests turned in: " .. (stats.questsCompleted or 0),
        timestamp = "",
    })
    scrollContainer:AddEntry(questCard)

    local spacer1 = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer1)

    --============================================================
    -- SECTION 2: DUNGEON & RAID PROGRESS
    --============================================================
    local header2 = self:CreateSectionHeader("DUNGEON & RAID PROGRESS", "SKY_BLUE")
    scrollContainer:AddEntry(header2)

    -- Count dungeon runs
    local normalRuns, heroicRuns = self:CountDungeonRuns()

    -- Dungeon Runs (Normal)
    local dungeonCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_Key_10",
        title = "Dungeon Runs",
        description = normalRuns .. " normal dungeons completed",
        timestamp = "",
    })
    scrollContainer:AddEntry(dungeonCard)

    -- Heroic Dungeons Cleared
    local heroicCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_Key_13",
        title = "Heroic Dungeons Cleared",
        description = heroicRuns .. " heroic dungeons completed",
        timestamp = "",
    })
    if heroicRuns > 0 then
        heroicCard:SetBackdropBorderColor(0, 0.75, 1, 1) -- Sky blue for heroic
    end
    scrollContainer:AddEntry(heroicCard)

    -- Raid Bosses Slain
    local raidBossKills = self:CountRaidBossKills()
    local bossCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Spell_Shadow_SummonInfernal",
        title = "Raid Bosses Slain",
        description = raidBossKills .. " raid bosses defeated",
        timestamp = "",
    })
    if raidBossKills > 0 then
        bossCard:SetBackdropBorderColor(1, 0.27, 0.27, 1) -- Hellfire red
    end
    scrollContainer:AddEntry(bossCard)

    -- Raids Cleared (full clears)
    local raidsCleared = self:CountRaidsCleared()
    local raidClearCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Helmet_06",
        title = "Raids Cleared",
        description = raidsCleared .. " full raid clears",
        timestamp = "",
    })
    if raidsCleared > 0 then
        raidClearCard._glowEffect = HopeAddon.Effects:CreatePulsingGlow(raidClearCard, "GOLD_BRIGHT", 0.3)
    end
    scrollContainer:AddEntry(raidClearCard)

    local spacer2 = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer2)

    --============================================================
    -- SECTION 3: COMBAT RECORD
    --============================================================
    local header3 = self:CreateSectionHeader("COMBAT RECORD", "HELLFIRE_RED")
    scrollContainer:AddEntry(header3)

    -- Battle Scars (Deaths)
    local deathTitle, deathColor = HopeAddon.Constants:GetDeathTitle(stats.deaths.total)
    local deathCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Ability_Creature_Cursed_02",
        title = "Battle Scars: " .. deathTitle,
        description = "Total Deaths: " .. stats.deaths.total .. "\n\nEach death is a lesson learned.",
        timestamp = "",
    })
    local deathColorData = HopeAddon.colors[deathColor]
    if deathColorData then
        deathCard:SetBackdropBorderColor(deathColorData.r, deathColorData.g, deathColorData.b, 1)
    end
    scrollContainer:AddEntry(deathCard)

    -- Creatures Slain
    local creaturesSlain = stats.creaturesSlain or 0
    local creatureCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Ability_DualWield",
        title = "Creatures Slain",
        description = self:FormatLargeNumber(creaturesSlain) .. " foes vanquished",
        timestamp = "",
    })
    scrollContainer:AddEntry(creatureCard)

    -- Largest Hit Dealt
    local largestHit = stats.largestHit or 0
    local hitCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Ability_Warrior_Rampage",
        title = "Largest Hit Dealt",
        description = self:FormatLargeNumber(largestHit) .. " damage in a single strike",
        timestamp = "",
    })
    if largestHit >= 10000 then
        hitCard:SetBackdropBorderColor(1, 0.84, 0, 1) -- Gold for big hits
    end
    scrollContainer:AddEntry(hitCard)

    local spacer3 = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer3)

    --============================================================
    -- SECTION 4: EXPLORATION & DISCOVERY
    --============================================================
    local header4 = self:CreateSectionHeader("EXPLORATION & DISCOVERY", "FEL_GREEN")
    scrollContainer:AddEntry(header4)

    -- Milestones Reached
    local counts = self:GetCachedCounts()
    local milestoneCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_QirajiCrystal_01",
        title = "Milestones Reached",
        description = counts.milestones .. " major achievements recorded",
        timestamp = "",
    })
    scrollContainer:AddEntry(milestoneCard)

    local spacer4 = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer4)

    --============================================================
    -- SECTION 5: TBC PROGRESSION
    --============================================================
    local header5 = self:CreateSectionHeader("TBC PROGRESSION", "ARCANE_PURPLE")
    scrollContainer:AddEntry(header5)

    -- Attunements Completed
    local attunementCount = self:CountAttunementsCompleted()
    local attunementCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_Key_14",
        title = "Attunements Completed",
        description = attunementCount .. " of 5 raid attunements completed",
        timestamp = "",
    })
    if attunementCount > 0 then
        attunementCard:SetBackdropBorderColor(0.61, 0.19, 1, 1) -- Arcane purple
    end
    scrollContainer:AddEntry(attunementCard)

    -- Reputations at Exalted
    local exaltedCount = self:CountExaltedReputations()
    local repCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\INV_Misc_Token_ArgentDawn",
        title = "Reputations at Exalted",
        description = exaltedCount .. " factions at Exalted standing",
        timestamp = "",
    })
    if exaltedCount > 0 then
        repCard:SetBackdropBorderColor(1, 0.84, 0, 1) -- Gold
    end
    scrollContainer:AddEntry(repCard)

    -- Flying Unlocked
    local flyingStatus, flyingDate = self:GetFlyingStatus()
    local flyingCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Ability_Mount_GryphonRiding",
        title = "Flying Unlocked",
        description = flyingStatus,
        timestamp = flyingDate or "",
    })
    if flyingDate then
        flyingCard:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
    else
        flyingCard:SetAlpha(0.6)
    end
    scrollContainer:AddEntry(flyingCard)

    -- Epic Flying Unlocked
    local epicFlyingStatus, epicFlyingDate = self:GetEpicFlyingStatus()
    local epicFlyingCard = self:AcquireCard(scrollContainer.content, {
        icon = "Interface\\Icons\\Ability_Mount_NetherDrakeElite",
        title = "Epic Flying Unlocked",
        description = epicFlyingStatus,
        timestamp = epicFlyingDate or "",
    })
    if epicFlyingDate then
        epicFlyingCard:SetBackdropBorderColor(0.61, 0.19, 1, 1)
        HopeAddon.Effects:CreatePulsingGlow(epicFlyingCard, "ARCANE_PURPLE", 0.3)
    else
        epicFlyingCard:SetAlpha(0.6)
    end
    scrollContainer:AddEntry(epicFlyingCard)
end

--[[
    STATS HELPER FUNCTIONS
]]

-- Format playtime into days, hours, minutes
function Journal:FormatPlaytime(seconds)
    if not seconds or seconds == 0 then
        return "Not yet recorded\n\nType /played to update"
    end

    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    local parts = {}
    if days > 0 then
        table.insert(parts, days .. " day" .. (days ~= 1 and "s" or ""))
    end
    if hours > 0 then
        table.insert(parts, hours .. " hour" .. (hours ~= 1 and "s" or ""))
    end
    if minutes > 0 or #parts == 0 then
        table.insert(parts, minutes .. " minute" .. (minutes ~= 1 and "s" or ""))
    end

    return table.concat(parts, ", ")
end

-- Format large numbers with commas
function Journal:FormatLargeNumber(num)
    if not num then return "0" end
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

-- Get cached stats data (all counts computed together and cached)
-- Invalidated via InvalidateCounts() when entries change
-- This avoids multiple iterations over the same data when opening Stats tab
function Journal:GetCachedStatsData()
    if self.cachedStatsData then
        return self.cachedStatsData
    end

    -- Compute all counts in a batch
    local normalRuns, heroicRuns = 0, 0
    local dungeonRuns = HopeAddon.charDb.stats.dungeonRuns or {}
    for _, runs in pairs(dungeonRuns) do
        normalRuns = normalRuns + (runs.normal or 0)
        heroicRuns = heroicRuns + (runs.heroic or 0)
    end

    local bossKills = 0
    local bossKillsData = HopeAddon.charDb.journal.bossKills or {}
    for _ in pairs(bossKillsData) do
        bossKills = bossKills + 1
    end

    local raidsCleared = 0
    local RaidData = HopeAddon.RaidData
    if RaidData then
        for _, raidKey in ipairs(HopeAddon.Constants.ALL_RAID_KEYS) do
            local killed, total = RaidData:GetRaidProgress(raidKey)
            if killed >= total and total > 0 then
                raidsCleared = raidsCleared + 1
            end
        end
    end

    local attunementsComplete = 0
    local Attunements = HopeAddon.Attunements
    if Attunements then
        for _, raidKey in ipairs(HopeAddon.Constants.ATTUNEMENT_RAID_KEYS) do
            local summary = Attunements:GetSummary(raidKey)
            if summary and summary.isAttuned then
                attunementsComplete = attunementsComplete + 1
            end
        end
    end

    local exaltedReps = 0
    local Reputation = HopeAddon:GetModule("Reputation")
    if Reputation and Reputation.cachedStandings then
        for _, standing in pairs(Reputation.cachedStandings) do
            if standing.standingId == 8 then
                exaltedReps = exaltedReps + 1
            end
        end
    end

    self.cachedStatsData = {
        normalDungeonRuns = normalRuns,
        heroicDungeonRuns = heroicRuns,
        raidBossKills = bossKills,
        raidsCleared = raidsCleared,
        attunementsCompleted = attunementsComplete,
        exaltedReputations = exaltedReps,
        ridingSkill = self:GetRidingSkill(),
    }

    return self.cachedStatsData
end

-- Count normal and heroic dungeon runs
function Journal:CountDungeonRuns()
    -- Use cached data if available
    local cached = self.cachedStatsData
    if cached then
        return cached.normalDungeonRuns, cached.heroicDungeonRuns
    end

    local normal, heroic = 0, 0
    local dungeonRuns = HopeAddon.charDb.stats.dungeonRuns or {}

    for _, runs in pairs(dungeonRuns) do
        normal = normal + (runs.normal or 0)
        heroic = heroic + (runs.heroic or 0)
    end

    return normal, heroic
end

-- Count raid boss kills from bossKills data
function Journal:CountRaidBossKills()
    -- Use cached data if available
    local cached = self.cachedStatsData
    if cached then
        return cached.raidBossKills
    end

    local count = 0
    local bossKills = HopeAddon.charDb.journal.bossKills or {}

    for _ in pairs(bossKills) do
        count = count + 1
    end

    return count
end

-- Count fully cleared raids
function Journal:CountRaidsCleared()
    -- Use cached data if available
    local cached = self.cachedStatsData
    if cached then
        return cached.raidsCleared
    end

    local cleared = 0
    local RaidData = HopeAddon.RaidData

    if RaidData then
        for _, raidKey in ipairs(HopeAddon.Constants.ALL_RAID_KEYS) do
            local killed, total = RaidData:GetRaidProgress(raidKey)
            if killed >= total and total > 0 then
                cleared = cleared + 1
            end
        end
    end

    return cleared
end

-- Count completed attunements
function Journal:CountAttunementsCompleted()
    -- Use cached data if available
    local cached = self.cachedStatsData
    if cached then
        return cached.attunementsCompleted
    end

    local count = 0
    local Attunements = HopeAddon.Attunements

    if Attunements then
        for _, raidKey in ipairs(HopeAddon.Constants.ATTUNEMENT_RAID_KEYS) do
            local summary = Attunements:GetSummary(raidKey)
            if summary and summary.isAttuned then
                count = count + 1
            end
        end
    end

    return count
end

-- Count exalted reputations
function Journal:CountExaltedReputations()
    -- Use cached data if available
    local cached = self.cachedStatsData
    if cached then
        return cached.exaltedReputations
    end

    local count = 0
    local Reputation = HopeAddon:GetModule("Reputation")

    if Reputation and Reputation.cachedStandings then
        for _, standing in pairs(Reputation.cachedStandings) do
            if standing.standingId == 8 then -- 8 = Exalted
                count = count + 1
            end
        end
    end

    return count
end

-- Get riding skill with caching (invalidated on SKILL_LINES_CHANGED)
-- Avoids O(n) linear search through 30-50 skills on every stats view
function Journal:GetRidingSkill()
    if self.cachedRidingSkill then
        return self.cachedRidingSkill
    end

    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local skillName, _, _, skillRank = GetSkillLineInfo(i)
        if skillName == "Riding" then
            self.cachedRidingSkill = skillRank
            return skillRank
        end
    end

    self.cachedRidingSkill = 0
    return 0
end

-- Get flying status
function Journal:GetFlyingStatus()
    local stats = HopeAddon.charDb.stats

    -- Check if we've recorded flying unlocked
    if stats.flyingUnlocked then
        return "Soaring through Outland!", stats.flyingUnlocked
    end

    -- Use cached riding skill lookup
    local ridingSkill = self:GetRidingSkill()

    if ridingSkill >= 225 then
        -- Record the date if not already recorded
        stats.flyingUnlocked = HopeAddon:GetDate()
        return "Soaring through Outland!", stats.flyingUnlocked
    end

    return "Requires Expert Riding (225)\nCost: 800g training + mount", nil
end

-- Get epic flying status
function Journal:GetEpicFlyingStatus()
    local stats = HopeAddon.charDb.stats

    -- Check if we've recorded epic flying unlocked
    if stats.epicFlyingUnlocked then
        return "Swift as the wind!", stats.epicFlyingUnlocked
    end

    -- Use cached riding skill lookup
    local ridingSkill = self:GetRidingSkill()

    if ridingSkill >= 300 then
        -- Record the date if not already recorded
        stats.epicFlyingUnlocked = HopeAddon:GetDate()
        return "Swift as the wind!", stats.epicFlyingUnlocked
    end

    return "Requires Artisan Riding (300)\nCost: 5000g training + mount", nil
end

--[[
    EVENT HANDLERS
]]
function Journal:OnLevelUp(newLevel)
    local MILESTONES = HopeAddon.Constants.LEVEL_MILESTONES

    -- Update character info display if journal is open
    if self.mainFrame and self.mainFrame:IsShown() then
        local _, class = UnitClass("player")
        local classColor = HopeAddon:GetClassColor(class)
        self.mainFrame.charInfo:SetText(string.format("|cFF%02x%02x%02x%s|r - Level %d",
            classColor.r * 255, classColor.g * 255, classColor.b * 255,
            UnitName("player"), newLevel))
    end

    -- Check if this is a milestone level
    if MILESTONES[newLevel] then
        local milestone = MILESTONES[newLevel]

        -- Create journal entry
        local entry = {
            type = "level_milestone",
            level = newLevel,
            title = milestone.title,
            description = milestone.story,
            story = milestone.story,
            icon = "Interface\\Icons\\" .. milestone.icon,
            zone = GetZoneText(),
            timestamp = HopeAddon:GetTimestamp(),
            date = HopeAddon:GetDate(),
        }

        -- Save to character DB
        HopeAddon.charDb.journal.levelMilestones[newLevel] = entry
        table.insert(HopeAddon.charDb.journal.entries, entry)

        -- Invalidate cached counts
        self:InvalidateCounts()

        -- Show notification
        self:ShowMilestoneNotification(milestone.title, newLevel, milestone.story)

        -- Play sound
        HopeAddon.Sounds:PlayAchievementFanfare()

        HopeAddon:Print("Milestone reached: " .. HopeAddon:ColorText(milestone.title, "GOLD_BRIGHT"))
    end
end

function Journal:OnQuestComplete(questID)
    -- Increment quest counter (always track total, even without questID)
    HopeAddon.charDb.stats.questsCompleted = HopeAddon.charDb.stats.questsCompleted + 1

    -- TBC Classic compatibility: QUEST_TURNED_IN may not provide questID
    -- If questID is nil or 0, we can still count the completion but can't track attunements
    if questID and questID > 0 then
        -- Check if this is an attunement quest using the Attunements module
        HopeAddon.Attunements:OnQuestComplete(questID)
    else
        HopeAddon:Debug("Quest completed without valid questID (TBC Classic compatibility)")
    end
end

function Journal:OnPlayerDeath()
    -- Track death
    HopeAddon.charDb.stats.deaths.total = HopeAddon.charDb.stats.deaths.total + 1

    local zone = GetZoneText()
    HopeAddon.charDb.stats.deaths.byZone[zone] = (HopeAddon.charDb.stats.deaths.byZone[zone] or 0) + 1
end

function Journal:OnTimePlayed(totalTime, levelTime)
    -- Store total playtime in seconds
    HopeAddon.charDb.stats.playtime = totalTime
    HopeAddon:Debug("Playtime updated:", totalTime, "seconds")
end

function Journal:OnCombatLogEvent()
    -- Check subEvent FIRST before unpacking all values (performance optimization)
    -- COMBAT_LOG fires 50,000+ times per raid session - avoid unnecessary work
    local subEvent = select(2, CombatLogGetCurrentEventInfo())
    if not TRACKED_DAMAGE_EVENTS[subEvent] then return end

    -- Only unpack remaining values after confirming relevant event
    local _, _, _, sourceGUID, _, _, _, destGUID, _, _, _, arg12, _, _, arg15 = CombatLogGetCurrentEventInfo()

    local playerGUID = UnitGUID("player")
    if sourceGUID ~= playerGUID then return end

    local stats = HopeAddon.charDb.stats

    -- Track creature kills
    if subEvent == "PARTY_KILL" then
        local destType, _, _, _, _, npcId = strsplit("-", destGUID)
        if destType == "Creature" then
            stats.creaturesSlain = (stats.creaturesSlain or 0) + 1

            npcId = tonumber(npcId)
            if npcId then
                local dungeonBoss = HopeAddon.Constants.DUNGEON_BOSS_NPC_IDS[npcId]
                if dungeonBoss then
                    self:OnDungeonBossKill(dungeonBoss.dungeon, dungeonBoss.name)
                end
            end
        end
        return
    end

    -- Track largest hit (damage events)
    local amount = (subEvent == "SWING_DAMAGE") and arg12 or arg15
    if amount and amount > (stats.largestHit or 0) then
        stats.largestHit = amount
    end
end

function Journal:OnDungeonBossKill(dungeonKey, dungeonName)
    local stats = HopeAddon.charDb.stats

    -- Initialize dungeon tracking if needed
    if not stats.dungeonRuns then
        stats.dungeonRuns = {}
    end
    if not stats.dungeonRuns[dungeonKey] then
        stats.dungeonRuns[dungeonKey] = { normal = 0, heroic = 0 }
    end

    -- Check difficulty (TBC Classic uses GetInstanceDifficulty)
    local difficulty = GetInstanceDifficulty and GetInstanceDifficulty() or 1
    local isHeroic = difficulty == 2

    if isHeroic then
        stats.dungeonRuns[dungeonKey].heroic = stats.dungeonRuns[dungeonKey].heroic + 1
        HopeAddon:Debug("Heroic dungeon clear:", dungeonName)
    else
        stats.dungeonRuns[dungeonKey].normal = stats.dungeonRuns[dungeonKey].normal + 1
        HopeAddon:Debug("Normal dungeon clear:", dungeonName)
    end
end

--[[
    NOTIFICATIONS
    Uses frame pool to avoid creating new frames for each notification
    Queue system ensures notifications don't overlap visually
]]

-- Queue a notification for display
function Journal:QueueNotification(notifType, data)
    -- Check for duplicate in queue
    for _, queued in ipairs(self.notificationQueue) do
        if queued.type == notifType then
            return -- Already queued
        end
    end

    table.insert(self.notificationQueue, { type = notifType, data = data })
    self:ProcessNotificationQueue()
end

-- Process the notification queue
function Journal:ProcessNotificationQueue()
    if self.isShowingNotification or #self.notificationQueue == 0 then
        return
    end

    self.isShowingNotification = true
    local next = table.remove(self.notificationQueue, 1)

    if next.type == "milestone" then
        self:ShowMilestoneNotificationInternal(next.data.title, next.data.level, next.data.story)
    elseif next.type == "discovery" then
        self:ShowDiscoveryNotificationInternal(next.data.zoneName, next.data.title, next.data.flavor)
    elseif next.type == "bossKill" then
        self:ShowBossKillNotificationInternal(next.data)
    else
        -- Unknown type, skip and continue
        self.isShowingNotification = false
        self:ProcessNotificationQueue()
    end
end

-- Called when a notification finishes displaying
function Journal:OnNotificationComplete()
    self.isShowingNotification = false
    -- Small delay before next notification
    HopeAddon.Timer:After(0.3, function()
        self:ProcessNotificationQueue()
    end)
end

function Journal:ShowMilestoneNotification(title, level, story)
    if HopeAddon.db and not HopeAddon.db.settings.notificationsEnabled then
        return
    end
    if not self.notificationPool then return end

    -- Queue instead of showing directly
    self:QueueNotification("milestone", { title = title, level = level, story = story })
end

function Journal:ShowMilestoneNotificationInternal(title, level, story)

    -- Acquire from pool instead of creating new frame
    local notif = self.notificationPool:Acquire()
    notif:SetSize(NOTIF_WIDTH_LARGE, NOTIF_HEIGHT_LARGE)
    notif:SetPoint("TOP", UIParent, "TOP", 0, NOTIF_TOP_OFFSET)
    HopeAddon.Components:ApplyBackdrop(notif, "DARK_GOLD", "PURPLE_TINT", "GOLD")

    -- Configure pre-created font strings
    notif.titleText:ClearAllPoints()
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -15)
    notif.titleText:SetText(HopeAddon:ColorText("MILESTONE REACHED", "GOLD_BRIGHT"))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -8)
    notif.line1:SetText("Level " .. level .. ": " .. title)
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11)
    notif.line2:SetPoint("TOP", notif.line1, "BOTTOM", 0, -5)
    notif.line2:SetText('"' .. story .. '"')
    notif.line2:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))

    -- Effects (store references for cleanup)
    notif._glowEffect = HopeAddon.Effects:CreateBorderGlow(notif, "GOLD_BRIGHT")
    notif._sparkles = HopeAddon.Effects:CreateSparkles(notif, 8, "GOLD_BRIGHT")
    HopeAddon.Effects:CreateBurstEffect(notif, "GOLD_BRIGHT")

    -- Animate in, then release back to pool
    local self_ref = self
    HopeAddon.Animations:NotificationSlideIn(notif, function()
        HopeAddon.Timer:After(4, function()
            HopeAddon.Animations:NotificationSlideOut(notif, function()
                self_ref:ReleaseNotification(notif)
                self_ref:OnNotificationComplete()
            end)
        end)
    end)
end

function Journal:ShowDiscoveryNotification(zoneName, title, flavor)
    if HopeAddon.db and not HopeAddon.db.settings.notificationsEnabled then
        return
    end
    if not self.notificationPool then return end

    -- Queue instead of showing directly
    self:QueueNotification("discovery", { zoneName = zoneName, title = title, flavor = flavor })
end

function Journal:ShowDiscoveryNotificationInternal(zoneName, title, flavor)
    -- Acquire from pool instead of creating new frame
    local notif = self.notificationPool:Acquire()
    notif:SetSize(NOTIF_WIDTH_SMALL, NOTIF_HEIGHT_SMALL)
    notif:SetPoint("TOP", UIParent, "TOP", 0, NOTIF_TOP_OFFSET)
    HopeAddon.Components:ApplyBackdrop(notif, "TOOLTIP", "BLUE_TINT", nil)

    -- Get zone color (with safe fallback)
    local zoneColor = "SKY_BLUE"
    local theme = HopeAddon.Glow and HopeAddon.Glow.zoneThemes and HopeAddon.Glow.zoneThemes[zoneName]
    if theme then
        zoneColor = theme.primary
    end
    local color = HopeAddon:GetSafeColor(zoneColor, "SKY_BLUE")
    notif:SetBackdropBorderColor(color.r, color.g, color.b, 1)

    -- Configure pre-created font strings
    notif.titleText:ClearAllPoints()
    notif.titleText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -12)
    notif.titleText:SetText(HopeAddon:ColorText("NEW LAND DISCOVERED", zoneColor))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.BODY, 12)
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -5)
    notif.line1:SetText(title)
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    notif.line2:SetPoint("TOP", notif.line1, "BOTTOM", 0, -3)
    notif.line2:SetWidth(280)
    notif.line2:SetText('"' .. flavor .. '"')
    notif.line2:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    -- Animate and release back to pool
    local self_ref = self
    HopeAddon.Animations:NotificationSlideIn(notif, function()
        HopeAddon.Timer:After(3, function()
            HopeAddon.Animations:NotificationSlideOut(notif, function()
                self_ref:ReleaseNotification(notif)
                self_ref:OnNotificationComplete()
            end)
        end)
    end)
end

function Journal:ShowBossKillNotification(killData)
    if HopeAddon.db and not HopeAddon.db.settings.notificationsEnabled then return end
    if not self.notificationPool then return end

    -- Queue instead of showing directly
    self:QueueNotification("bossKill", killData)
end

function Journal:ShowBossKillNotificationInternal(killData)
    -- Acquire from pool instead of creating new frame
    local notif = self.notificationPool:Acquire()
    notif:SetSize(NOTIF_WIDTH_LARGE, NOTIF_HEIGHT_LARGE)
    notif:SetPoint("TOP", UIParent, "TOP", 0, NOTIF_TOP_OFFSET)
    HopeAddon.Components:ApplyBackdrop(notif, "DARK_GOLD", "RED_TINT", "RED")

    -- Configure pre-created font strings
    notif.titleText:ClearAllPoints()
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -15)
    notif.titleText:SetText(HopeAddon:ColorText("VICTORY!", "HELLFIRE_RED"))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -8)
    notif.line1:SetText(killData.bossName .. " defeated!")
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11)
    notif.line2:SetPoint("TOP", notif.line1, "BOTTOM", 0, -5)
    notif.line2:SetText(killData.raidName)
    notif.line2:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    -- Animate and release back to pool
    local self_ref = self
    HopeAddon.Animations:NotificationSlideIn(notif, function()
        HopeAddon.Timer:After(3, function()
            HopeAddon.Animations:NotificationSlideOut(notif, function()
                self_ref:ReleaseNotification(notif)
                self_ref:OnNotificationComplete()
            end)
        end)
    end)
end

--[[
    PUBLIC API
]]
function Journal:Toggle()
    if not self.mainFrame then
        HopeAddon:Print("Journal not ready. Try /reload")
        return
    end
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
        HopeAddon.Sounds:PlayJournalClose()
        self.isOpen = false
        -- Save last selected tab
        HopeAddon.charDb.journal.lastTab = self.currentTab
    else
        -- Update character level display
        local _, class = UnitClass("player")
        local classColor = HopeAddon:GetClassColor(class)
        self.mainFrame.charInfo:SetText(string.format("|cFF%02x%02x%02x%s|r - Level %d",
            classColor.r * 255, classColor.g * 255, classColor.b * 255,
            UnitName("player"), UnitLevel("player")))

        self.mainFrame:Show()
        HopeAddon.Sounds:PlayJournalOpen()
        self.isOpen = true

        -- Restore last selected tab or default to timeline
        local lastTab = HopeAddon.charDb.journal.lastTab or "journey"
        self:SelectTab(lastTab)
    end
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Journal module loaded")
end
