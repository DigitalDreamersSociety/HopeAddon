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
Journal.currentTab = nil
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

-- Heroic key icons by faction ID
local HEROIC_KEY_ICONS = {
    [942] = "INV_Misc_Key_13", [935] = "INV_Misc_Key_12", [989] = "INV_Misc_Key_11",
    [1011] = "INV_Misc_Key_14", [946] = "INV_Misc_Key_15", [947] = "INV_Misc_Key_15",
}

local HEROIC_KEY_NAMES = {
    [942] = "Reservoir Key", [935] = "Warpforged Key", [989] = "Key of Time",
    [1011] = "Auchenai Key", [946] = "Flamewrought Key", [947] = "Flamewrought Key",
}

-- Requirement type icons for Next Step box
local REQUIREMENT_TYPE_ICONS = {
    dungeon = "INV_Misc_Key_04", raid = "Ability_Creature_Cursed_04",
    boss = "Ability_DualWield", quest = "INV_Letter_15",
    item = "INV_Misc_Bag_10", level = "Interface\\Icons\\Spell_Holy_MagicalSentry",
}

-- Progression phase colors and names
local PHASE_COLORS = {
    PRE_OUTLAND = "GOLD_BRIGHT", T4_ATTUNEMENT = "FEL_GREEN", T5_ATTUNEMENT = "ARCANE_PURPLE",
    T6_ATTUNEMENT = "HELLFIRE_RED", RAID_PROGRESSION = "SKY_BLUE", ENDGAME = "GOLD_BRIGHT",
}

local PHASE_NAMES = {
    PRE_OUTLAND = "The Journey Begins", T4_ATTUNEMENT = "Tier 4 Attunement",
    T5_ATTUNEMENT = "Tier 5 Attunement", T6_ATTUNEMENT = "Tier 6 Attunement",
    RAID_PROGRESSION = "Raid Progression", ENDGAME = "Legend of Outland",
}

-- Standing thresholds for reputation progress
local STANDING_THRESHOLDS = {
    [1] = 36000, [2] = 3000, [3] = 3000, [4] = 3000, [5] = 6000, [6] = 12000, [7] = 21000, [8] = 999,
}

local STANDING_NAMES = {
    [1] = "Hated", [2] = "Hostile", [3] = "Unfriendly", [4] = "Neutral",
    [5] = "Friendly", [6] = "Honored", [7] = "Revered", [8] = "Exalted",
}

-- Game stats display order and info (used by PopulateStats)
local GAME_STATS_ORDER = { "rps", "deathroll", "pong", "tetris", "words", "battleship" }
local GAME_STATS_INFO = {
    rps = { name = "Rock Paper Scissors", icon = "Interface\\Icons\\Spell_Nature_EarthShock", color = "NATURE_GREEN", hasTies = true, specialStat = nil, specialLabel = nil },
    deathroll = { name = "Death Roll", icon = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01", color = "HELLFIRE_RED", hasTies = true, specialStat = "highestBet", specialLabel = "High Bet" },
    pong = { name = "Pong", icon = "Interface\\Icons\\INV_Misc_PunchCards_Yellow", color = "SKY_BLUE", hasTies = false, specialStat = "highestScore", specialLabel = "High Score" },
    tetris = { name = "Tetris Battle", icon = "Interface\\Icons\\INV_Misc_Gem_Variety_01", color = "ARCANE_PURPLE", hasTies = false, specialStat = "highestScore", specialLabel = "High Score" },
    words = { name = "Words with WoW", icon = "Interface\\Icons\\INV_Misc_Book_07", color = "BRONZE", hasTies = false, specialStat = "highestScore", specialLabel = "High Score" },
    battleship = { name = "Battleship", icon = "Interface\\Icons\\INV_Misc_Anchor", color = "SKY_BLUE", hasTies = false, specialStat = nil, specialLabel = nil },
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
        frame._poolType = nil  -- Clear pool type on reset
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
        -- Clean up reputation bar (created in CreateReputationCard)
        if card.reputationBar then
            -- Clean up item containers first (they have scripts and stored data)
            if card.reputationBar.itemContainers then
                for _, itemBtn in ipairs(card.reputationBar.itemContainers) do
                    itemBtn:Hide()
                    itemBtn:SetScript("OnEnter", nil)
                    itemBtn:SetScript("OnLeave", nil)
                    itemBtn:SetScript("OnClick", nil)
                    itemBtn.itemData = nil
                    itemBtn.qualityColor = nil
                end
            end
            -- Clean up the bar frame if it exists
            if card.reputationBar.barFrame then
                card.reputationBar.barFrame:Hide()
            end
            card.reputationBar:Hide()
            card.reputationBar:SetParent(nil)
            card.reputationBar = nil
        end
        -- Clean up milestone frame (created in old CreateReputationCard - may not exist anymore)
        if card.milestoneFrame then
            card.milestoneFrame:Hide()
            card.milestoneFrame:SetParent(nil)
            card.milestoneFrame = nil
        end
        card._pooled = true
        card._poolType = nil  -- Clear pool type on reset
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
        section._poolType = nil  -- Clear pool type on reset
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
        card._poolType = nil  -- Clear pool type on reset
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
        card._poolType = nil  -- Clear pool type on reset
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
    card._poolType = "gamecard"  -- Mark as game card pool item

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
    if not self.bossInfoPool then
        HopeAddon:Debug("WARN: AcquireBossInfoCard called but bossInfoPool is nil")
        return nil
    end

    local card = self.bossInfoPool:Acquire()
    card:SetParent(parent)
    card._pooled = true
    card._poolType = "bossinfo"  -- Mark as boss info pool item

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
    if not self.collapsiblePool then
        HopeAddon:Debug("WARN: AcquireCollapsibleSection called but collapsiblePool is nil")
        return nil
    end

    local section = self.collapsiblePool:Acquire()
    section:SetParent(parent)
    section._pooled = true
    section._poolType = "collapsible"  -- Mark as collapsible pool item

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
    if not self.cardPool then
        HopeAddon:Debug("WARN: AcquireCard called but cardPool is nil")
        return nil
    end
    local card = self.cardPool:Acquire()
    local Components = HopeAddon.Components

    card:SetParent(parent)
    card:SetHeight(80)
    card._pooled = true
    card._poolType = "card"  -- Mark as card pool item

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
    if not self.containerPool then
        HopeAddon:Debug("WARN: AcquireContainer called but containerPool is nil")
        return nil
    end
    local container = self.containerPool:Acquire()
    container:SetParent(parent)
    container:SetSize(CONTAINER_WIDTH, height or 20)
    container._pooled = true
    container._poolType = "container"  -- Mark as container pool item
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
    local titleBar = Components:CreateTitleBar(frame, "CHRONICLE OF OUTLAND", "ARCANE_PURPLE")

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
        { id = "reputation", label = "Reputation", tooltip = "Faction standings by category" },
        { id = "raids", label = "Raids", tooltip = "Boss kill tracking by tier (T4/T5/T6)" },
        { id = "attunements", label = "Attunements", tooltip = "Raid attunement quest chains" },
        { id = "games", label = "Games", tooltip = "Minigames and challenges", color = "ARCANE_PURPLE" },
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

    -- NOTE: Do NOT call SelectTab here - frame is hidden and content will have width=0
    -- Toggle() calls SelectTab after showing the frame, which is the correct time

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
    -- 1. Cards and nested items first (they're children of other frames)
    if self.cardPool then
        self.cardPool:ReleaseAll()
    end
    if self.gameCardPool then
        self.gameCardPool:ReleaseAll()
    end
    if self.bossInfoPool then
        self.bossInfoPool:ReleaseAll()
    end

    -- 2. Collapsible sections second (after their card children are released)
    if self.collapsiblePool then
        self.collapsiblePool:ReleaseAll()
    end

    -- 3. Clear and repopulate content (pass containerPool for pooled frame release)
    self.mainFrame.scrollContainer:ClearEntries(self.containerPool)

    -- Migration: old "directory" tab now split into "games" and "social"
    if tabId == "directory" then
        tabId = "games"
        self.currentTab = tabId
    end

    if tabId == "journey" then
        self:PopulateJourney()
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
    Create loot hotlist showing top 3 recommended items for the player's class
    Items come from reputation rewards and normal dungeon drops
]]
function Journal:CreateLootHotlist()
    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local _, classToken = UnitClass("player")

    -- Get player's spec using the new spec detection
    local specName, specTab, specPoints = HopeAddon:GetPlayerSpec()

    -- Get spec-specific items from new data structure
    local classData = C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    local specData = classData and classData[specTab]

    -- Fallback to old data structure if spec data not found
    if not specData then
        specData = {
            rep = C.CLASS_LOOT_HOTLIST[classToken] or {},
            drops = {},
            crafted = {},
        }
    end

    -- Get class color
    local classColor = RAID_CLASS_COLORS[classToken] or { r = 1, g = 0.84, b = 0 }
    local hexColor = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
    local className = UnitClass("player")

    -- Calculate total height for container
    -- Header (35) + 3 collapsible sections * (header 32 + 3 items * 75 + spacing)
    local repCount = specData.rep and #specData.rep or 0
    local dropCount = specData.drops and #specData.drops or 0
    local craftCount = specData.crafted and #specData.crafted or 0
    local sectionHeight = 32 + (3 * 78)  -- header + 3 items
    local totalHeight = 45 + (sectionHeight * 3) + 30  -- main header + 3 sections + bottom padding

    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, totalHeight)

    -- Main section title with class name and spec
    local sectionTitle = container.lootSectionTitle
    if not sectionTitle then
        sectionTitle = container:CreateFontString(nil, "OVERLAY")
        container.lootSectionTitle = sectionTitle
    end
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 13)
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -8)
    sectionTitle:SetText("|cFF" .. hexColor .. string.upper(className) .. " - " .. specName .. "|r |cFFAAAAAA(" .. specPoints .. " pts)|r")
    sectionTitle:Show()

    local yOffset = -38

    -- Category definitions with colors
    local categories = {
        { key = "rep", title = "Reputation Rewards", color = "ARCANE_PURPLE", icon = "Achievement_Reputation_01" },
        { key = "drops", title = "Dungeon Drops", color = "FEL_GREEN", icon = "INV_Misc_Bone_HumanSkull_01" },
        { key = "crafted", title = "Crafted Gear", color = "GOLD_BRIGHT", icon = "Trade_BlackSmithing" },
    }

    -- Create collapsible section for each category
    for catIdx, category in ipairs(categories) do
        local items = specData[category.key] or {}
        if #items > 0 then
            -- Create collapsible section header
            local sectionFrame = self:CreateLootCategorySection(container, category.title, category.color, catIdx, yOffset)

            -- Add item cards to section
            local itemYOffset = -30
            for i, item in ipairs(items) do
                local cardKey = "lootCard_" .. category.key .. "_" .. i
                local card = self:CreateLootCard(sectionFrame, item, cardKey)
                card:ClearAllPoints()
                card:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 5, itemYOffset)
                card:SetPoint("RIGHT", sectionFrame, "RIGHT", -5, 0)
                card:Show()
                itemYOffset = itemYOffset - 78
            end

            yOffset = yOffset - (32 + (#items * 78) + 8)  -- section header + items + padding
        end
    end

    return container
end

--[[
    Create a collapsible category section for loot items
]]
function Journal:CreateLootCategorySection(parent, title, colorName, index, yOffset)
    local sectionKey = "lootSection_" .. index
    local section = parent[sectionKey]

    if not section then
        section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        section:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        section:SetBackdropColor(0.05, 0.05, 0.08, 0.6)

        -- Header bar
        section.header = CreateFrame("Button", nil, section)
        section.header:SetHeight(26)
        section.header:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
        section.header:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)

        -- Header background
        section.headerBg = section.header:CreateTexture(nil, "BACKGROUND")
        section.headerBg:SetAllPoints(section.header)
        section.headerBg:SetColorTexture(0.12, 0.12, 0.15, 0.9)

        -- Expand/collapse indicator
        section.indicator = section.header:CreateFontString(nil, "OVERLAY")
        section.indicator:SetFont(HopeAddon.assets.fonts.HEADER, 12)
        section.indicator:SetPoint("LEFT", section.header, "LEFT", 8, 0)

        -- Title
        section.titleText = section.header:CreateFontString(nil, "OVERLAY")
        section.titleText:SetFont(HopeAddon.assets.fonts.HEADER, 11)
        section.titleText:SetPoint("LEFT", section.indicator, "RIGHT", 6, 0)

        -- Hover highlight
        section.highlight = section.header:CreateTexture(nil, "HIGHLIGHT")
        section.highlight:SetAllPoints(section.header)
        section.highlight:SetColorTexture(1, 0.84, 0, 0.15)

        section.isExpanded = true
        section.contentHeight = 0

        parent[sectionKey] = section
    end

    -- Get color from palette
    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT
    section:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)

    -- Set title and indicator
    section.indicator:SetText(section.isExpanded and "[-]" or "[+]")
    section.indicator:SetTextColor(0.7, 0.7, 0.7)
    section.titleText:SetText("|cFF" .. string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) .. title .. "|r")

    -- Position section
    section:ClearAllPoints()
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    section:SetPoint("RIGHT", parent, "RIGHT", -5, 0)
    section:SetHeight(32 + (3 * 78))  -- header + 3 items
    section:Show()

    return section
end

--[[
    Create a single loot item card showing:
    - Source (faction @ standing, dungeon, or profession)
    - Item icon with quality border
    - Item name in quality color
    - Stats summary
    - Progress bar (for rep items) or source tag (for drops/crafted)
]]
function Journal:CreateLootCard(parent, item, cardKey)
    local card = parent[cardKey]
    local cardWidth = parent:GetWidth() - 10

    if not card then
        card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetHeight(72)
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        card:SetBackdropColor(0.06, 0.06, 0.08, 0.95)

        -- Source text (faction/dungeon/profession)
        card.sourceText = card:CreateFontString(nil, "OVERLAY")
        card.sourceText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
        card.sourceText:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -6)

        -- Item icon
        card.itemIcon = card:CreateTexture(nil, "ARTWORK")
        card.itemIcon:SetSize(32, 32)
        card.itemIcon:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -20)

        -- Icon border (quality colored)
        card.iconBorder = card:CreateTexture(nil, "OVERLAY")
        card.iconBorder:SetSize(36, 36)
        card.iconBorder:SetPoint("CENTER", card.itemIcon, "CENTER", 0, 0)
        card.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        card.iconBorder:SetBlendMode("ADD")

        -- Item name
        card.itemName = card:CreateFontString(nil, "OVERLAY")
        card.itemName:SetFont(HopeAddon.assets.fonts.BODY, 10)
        card.itemName:SetPoint("TOPLEFT", card.itemIcon, "TOPRIGHT", 8, 0)

        -- Slot text
        card.slotText = card:CreateFontString(nil, "OVERLAY")
        card.slotText:SetFont(HopeAddon.assets.fonts.SMALL, 8)
        card.slotText:SetPoint("TOPLEFT", card.itemName, "BOTTOMLEFT", 0, -1)
        card.slotText:SetTextColor(0.7, 0.7, 0.7)

        -- Stats text
        card.statsText = card:CreateFontString(nil, "OVERLAY")
        card.statsText:SetFont(HopeAddon.assets.fonts.SMALL, 8)
        card.statsText:SetPoint("TOPLEFT", card.slotText, "BOTTOMLEFT", 0, -1)
        card.statsText:SetTextColor(0.5, 0.75, 0.5)
        card.statsText:SetWidth(cardWidth - 60)
        card.statsText:SetJustifyH("LEFT")

        -- Progress bar background (for rep items)
        card.progressBg = card:CreateTexture(nil, "BACKGROUND")
        card.progressBg:SetColorTexture(0.08, 0.08, 0.1, 0.9)
        card.progressBg:SetHeight(6)
        card.progressBg:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 8, 6)
        card.progressBg:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -8, 6)

        -- Progress bar fill
        card.progressFill = card:CreateTexture(nil, "ARTWORK")
        card.progressFill:SetPoint("TOPLEFT", card.progressBg, "TOPLEFT", 1, -1)

        -- Progress/source text
        card.progressText = card:CreateFontString(nil, "OVERLAY")
        card.progressText:SetFont(HopeAddon.assets.fonts.SMALL, 8)
        card.progressText:SetPoint("BOTTOM", card.progressBg, "TOP", 0, 2)
        card.progressText:SetTextColor(0.8, 0.8, 0.8)

        parent[cardKey] = card
    end

    -- Get quality color
    local qualityColors = HopeAddon.Constants.ITEM_QUALITY_COLORS
    local qc = qualityColors[item.quality] or qualityColors.common

    -- Set border color based on quality
    card:SetBackdropBorderColor(qc.r * 0.7, qc.g * 0.7, qc.b * 0.7, 0.8)
    card.iconBorder:SetVertexColor(qc.r, qc.g, qc.b, 0.7)

    -- Source text with color based on type
    local sourceColor = "AAAA88"
    if item.sourceType == "rep" then
        sourceColor = "9B59B6"  -- Purple for rep
    elseif item.sourceType == "drops" then
        sourceColor = "3498DB"  -- Blue for dungeons
    elseif item.sourceType == "crafted" then
        sourceColor = "E67E22"  -- Orange for crafted
    end
    card.sourceText:SetText("|cFF" .. sourceColor .. item.source .. "|r")
    card.sourceText:Show()

    -- Item icon
    local iconPath = "Interface\\Icons\\" .. (item.icon or "INV_Misc_QuestionMark")
    card.itemIcon:SetTexture(iconPath)
    card.itemIcon:Show()
    card.iconBorder:Show()

    -- Item name in quality color
    local hexColor = string.format("%02x%02x%02x", qc.r * 255, qc.g * 255, qc.b * 255)
    card.itemName:SetText("|cFF" .. hexColor .. item.name .. "|r")
    card.itemName:Show()

    -- Slot text
    card.slotText:SetText(item.slot or "")
    card.slotText:Show()

    -- Stats text
    card.statsText:SetText(item.stats or "")
    card.statsText:Show()

    -- Progress bar for reputation items
    if item.sourceType == "rep" and item.faction then
        -- Get current standing with faction
        local standingId, currentRep, maxRep = self:GetFactionProgress(item.faction)
        local standingNames = HopeAddon.Constants.STANDING_NAMES
        local currentStanding = standingNames[standingId] or "Unknown"
        local requiredStanding = standingNames[item.standing] or "Exalted"

        -- Calculate progress
        local isComplete = standingId >= item.standing
        local pct = 0
        if isComplete then
            pct = 100
        elseif maxRep > 0 then
            pct = (currentRep / maxRep) * 100
        end

        -- Standing colors
        local standingColors = {
            [1] = {0.8,0,0}, [2] = {1,0.2,0.2}, [3] = {1,0.5,0}, [4] = {1,1,0},
            [5] = {0,0.8,0}, [6] = {0,0.6,0.8}, [7] = {0,0.4,0.8}, [8] = {0.6,0.2,1}
        }
        local sc = standingColors[standingId] or {0.5, 0.5, 0.5}

        card.progressBg:Show()
        card.progressFill:SetColorTexture(sc[1], sc[2], sc[3], 0.8)
        local barWidth = card.progressBg:GetWidth() - 2
        if barWidth < 1 then barWidth = 200 end  -- Default if not yet measured
        card.progressFill:SetSize(math.max(1, barWidth * (pct / 100)), 4)
        card.progressFill:Show()

        card.progressText:ClearAllPoints()
        card.progressText:SetPoint("BOTTOM", card.progressBg, "TOP", 0, 2)
        if isComplete then
            card.progressText:SetText("|cFF44CC44" .. string.char(226, 156, 147) .. " " .. currentStanding .. "|r")
        else
            card.progressText:SetText("|cFFCCCCCC" .. currentStanding .. " - Need " .. requiredStanding .. "|r")
        end
        card.progressText:Show()
    elseif item.sourceType == "drops" then
        -- Dungeon drop - show dungeon name
        card.progressBg:Hide()
        card.progressFill:Hide()
        card.progressText:ClearAllPoints()
        card.progressText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 8, 8)
        card.progressText:SetText("|cFF3498DB" .. string.char(226, 154, 148) .. " Dungeon Drop|r")
        card.progressText:Show()
    elseif item.sourceType == "crafted" then
        -- Crafted item - show profession
        card.progressBg:Hide()
        card.progressFill:Hide()
        card.progressText:ClearAllPoints()
        card.progressText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 8, 8)
        local profession = item.profession or "Crafted"
        card.progressText:SetText("|cFFE67E22" .. string.char(226, 154, 153) .. " " .. profession .. "|r")
        card.progressText:Show()
    else
        -- Unknown type
        card.progressBg:Hide()
        card.progressFill:Hide()
        card.progressText:ClearAllPoints()
        card.progressText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 8, 8)
        card.progressText:SetText("|cFFAAAAAA[Obtainable]|r")
        card.progressText:Show()
    end

    -- Enable mouse for tooltip
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if item.itemId then
            GameTooltip:SetHyperlink("item:" .. item.itemId)
        else
            GameTooltip:SetText(item.name)
            GameTooltip:AddLine(item.stats, 0.6, 0.8, 0.6)
            GameTooltip:AddLine(item.source, 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return card
end

--[[
    Get faction progress for a given faction name
    Returns: standingId, currentRep, maxRep
]]
function Journal:GetFactionProgress(factionName)
    -- Map faction names to faction IDs
    local factionIds = {
        ["Cenarion Expedition"] = 942,
        ["Honor Hold"] = 946,
        ["Thrallmar"] = 947,
        ["Lower City"] = 1011,
        ["The Sha'tar"] = 935,
        ["Keepers of Time"] = 989,
        ["The Consortium"] = 933,
        ["Sporeggar"] = 970,
        ["The Aldor"] = 932,
        ["The Scryers"] = 934,
    }

    local factionId = factionIds[factionName]
    if not factionId then
        return 4, 0, 3000 -- Default to Neutral if unknown
    end

    local name, description, standingId, barMin, barMax, barValue = GetFactionInfoByID(factionId)
    if not name then
        return 4, 0, 3000
    end

    local currentRep = barValue - barMin
    local maxRep = barMax - barMin

    return standingId, currentRep, maxRep
end

function Journal:GetNextStep()
    local Attunements = HopeAddon.Attunements
    local playerLevel = UnitLevel("player")
    local result = { phase = "ENDGAME", title = "Legend of Outland", subtitle = "All attunements complete!", story = "You have conquered all of Outland's challenges.", icon = "Interface\\Icons\\Achievement_Boss_Illidan", progress = { current = 100, total = 100, percentage = 100, label = "Complete" } }
    if playerLevel < 58 then result.phase = "PRE_OUTLAND" result.title = "Reach the Dark Portal" result.subtitle = "Level " .. playerLevel .. " of 58" result.story = "Journey to Hellfire Peninsula awaits." result.icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar" result.progress = { current = playerLevel, total = 58, percentage = math.floor((playerLevel / 58) * 100), label = playerLevel .. " / 58" } return result end
    local karaProgress = Attunements and Attunements:GetProgress("karazhan")
    if karaProgress and not karaProgress.completed then local chapters = Attunements:GetTotalChapters("karazhan") or 7 local completed = 0 if karaProgress.chapters then for _ in pairs(karaProgress.chapters) do completed = completed + 1 end end result.phase = "T4_ATTUNEMENT" result.title = "Karazhan Attunement" result.subtitle = "Chapter " .. (completed + 1) .. " of " .. chapters result.story = "Complete the Karazhan attunement chain." result.icon = "Interface\\Icons\\INV_Misc_Key_07" result.progress = { current = completed, total = chapters, percentage = math.floor((completed / chapters) * 100), label = completed .. " / " .. chapters } return result end
    local sscProgress = Attunements and Attunements:GetProgress("ssc") local tkProgress = Attunements and Attunements:GetProgress("tk")
    if (sscProgress and not sscProgress.completed) or (tkProgress and not tkProgress.completed) then local targetRaid = (sscProgress and not sscProgress.completed) and "ssc" or "tk" local progress = targetRaid == "ssc" and sscProgress or tkProgress local chapters = Attunements:GetTotalChapters(targetRaid) or 5 local completed = 0 if progress and progress.chapters then for _ in pairs(progress.chapters) do completed = completed + 1 end end local raidName = targetRaid == "ssc" and "Serpentshrine Cavern" or "Tempest Keep" result.phase = "T5_ATTUNEMENT" result.title = raidName .. " Attunement" result.subtitle = "Chapter " .. (completed + 1) .. " of " .. chapters result.story = "Complete the attunement to access " .. raidName result.icon = targetRaid == "ssc" and "Interface\\Icons\\INV_Misc_MonsterScales_15" or "Interface\\Icons\\INV_Misc_Key_13" result.progress = { current = completed, total = chapters, percentage = math.floor((completed / chapters) * 100), label = completed .. " / " .. chapters } return result end
    local hyjalProgress = Attunements and Attunements:GetProgress("hyjal") local btProgress = Attunements and Attunements:GetProgress("bt")
    if (hyjalProgress and not hyjalProgress.completed) or (btProgress and not btProgress.completed) then local targetRaid = (hyjalProgress and not hyjalProgress.completed) and "hyjal" or "bt" local progress = targetRaid == "hyjal" and hyjalProgress or btProgress local chapters = Attunements:GetTotalChapters(targetRaid) or 4 local completed = 0 if progress and progress.chapters then for _ in pairs(progress.chapters) do completed = completed + 1 end end local raidName = targetRaid == "hyjal" and "Mount Hyjal" or "Black Temple" result.phase = "T6_ATTUNEMENT" result.title = raidName .. " Attunement" result.subtitle = "Chapter " .. (completed + 1) .. " of " .. chapters result.story = "Complete the attunement to access " .. raidName result.icon = targetRaid == "hyjal" and "Interface\\Icons\\INV_Misc_Gem_Variety_01" or "Interface\\Icons\\INV_Weapon_Glaive_01" result.progress = { current = completed, total = chapters, percentage = math.floor((completed / chapters) * 100), label = completed .. " / " .. chapters } return result end
    local tierStatus = self:GetTierStatus("T6")
    if tierStatus and tierStatus.status ~= "CLEARED" then result.phase = "RAID_PROGRESSION" result.title = "Clear " .. (tierStatus.currentRaid or "Black Temple") result.subtitle = "Raid Progression" result.story = "Defeat the final bosses of Outland." result.icon = "Interface\\Icons\\INV_Sword_01" local bossesKilled = tierStatus.bossesKilled or 0 local totalBosses = tierStatus.totalBosses or 9 result.progress = { current = bossesKilled, total = totalBosses, percentage = math.floor((bossesKilled / totalBosses) * 100), label = bossesKilled .. " / " .. totalBosses } return result end
    return result
end

function Journal:CreateNextStepBox()
    local stepData = self:GetNextStep()
    local phaseColor = PHASE_COLORS[stepData.phase] or "GOLD_BRIGHT"
    local c = HopeAddon.colors[phaseColor] or HopeAddon.colors.GOLD_BRIGHT
    local scrollContent = self.mainFrame.scrollContainer.content

    -- Use persistent frame with BackdropTemplate for border color support
    local container = self._nextStepFrame
    if not container then
        container = HopeAddon:CreateBackdropFrame("Frame", nil, scrollContent)
        container:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        container:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
        self._nextStepFrame = container
    end
    container:SetParent(scrollContent)
    container:SetSize(CONTAINER_WIDTH, 180)
    container:Show()
    local phaseBadge = container.phaseBadge or container:CreateFontString(nil, "OVERLAY") container.phaseBadge = phaseBadge phaseBadge:SetFont(HopeAddon.assets.fonts.SMALL, 9) phaseBadge:ClearAllPoints() phaseBadge:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -8) phaseBadge:SetText(HopeAddon:ColorText(PHASE_NAMES[stepData.phase] or stepData.phase, phaseColor)) phaseBadge:Show()
    local header = container.stepHeader or container:CreateFontString(nil, "OVERLAY") container.stepHeader = header header:SetFont(HopeAddon.assets.fonts.HEADER, 11) header:ClearAllPoints() header:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5) header:SetText(HopeAddon:ColorText("YOUR NEXT STEP", phaseColor)) header:Show()
    local icon = container.stepIcon or container:CreateTexture(nil, "ARTWORK") container.stepIcon = icon icon:SetSize(48, 48) icon:ClearAllPoints() icon:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -25) icon:SetTexture(stepData.icon or "Interface\\Icons\\INV_Misc_QuestionMark") icon:Show()
    local title = container.stepTitle or container:CreateFontString(nil, "OVERLAY") container.stepTitle = title title:SetFont(HopeAddon.assets.fonts.HEADER, 14) title:ClearAllPoints() title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2) title:SetText(HopeAddon:ColorText(stepData.title, "BRIGHT_WHITE")) title:Show()
    local subtitle = container.stepSubtitle or container:CreateFontString(nil, "OVERLAY") container.stepSubtitle = subtitle subtitle:SetFont(HopeAddon.assets.fonts.BODY, 11) subtitle:ClearAllPoints() subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2) subtitle:SetText(HopeAddon:ColorText(stepData.subtitle, "SUBTLE")) subtitle:Show()
    local story = container.stepStory or container:CreateFontString(nil, "OVERLAY") container.stepStory = story story:SetFont(HopeAddon.assets.fonts.BODY, 10) story:ClearAllPoints() story:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -80) story:SetPoint("RIGHT", container, "RIGHT", -15, 0) story:SetJustifyH("LEFT") story:SetText("|cFFCCCCCC\"" .. (stepData.story or "") .. "\"|r") story:Show()
    local progressBar = container.stepProgressBar if not progressBar then progressBar = CreateFrame("Frame", nil, container, "BackdropTemplate") progressBar:SetSize(CONTAINER_WIDTH - 40, 16) progressBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 }) progressBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8) progressBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) progressBar.fill = progressBar:CreateTexture(nil, "ARTWORK") progressBar.fill:SetPoint("TOPLEFT", 2, -2) progressBar.fill:SetPoint("BOTTOMLEFT", 2, 2) progressBar.label = progressBar:CreateFontString(nil, "OVERLAY") progressBar.label:SetFont(HopeAddon.assets.fonts.SMALL, 9) progressBar.label:SetPoint("CENTER", progressBar, "CENTER", 0, 0) container.stepProgressBar = progressBar end
    progressBar:ClearAllPoints() progressBar:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 20, 35) local pct = stepData.progress.percentage or 0 progressBar.fill:SetWidth(math.max(1, (CONTAINER_WIDTH - 44) * (pct / 100))) progressBar.fill:SetColorTexture(c.r, c.g, c.b, 0.8) progressBar.label:SetText(stepData.progress.label or (pct .. "%")) progressBar:Show()
    local nextPreview = container.stepNextPreview or container:CreateFontString(nil, "OVERLAY") container.stepNextPreview = nextPreview nextPreview:SetFont(HopeAddon.assets.fonts.SMALL, 9) nextPreview:ClearAllPoints() nextPreview:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 20, 12) nextPreview:SetText("") nextPreview:Show()
    container:SetBackdropBorderColor(c.r, c.g, c.b, 1) return container
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
    Dynamically switches between:
    - Pre-60: "Journey to Outland" encouragement
    - 60-67: Leveling gear recommendations by role
    - 68+: Endgame attunements and raid progression
]]
function Journal:PopulateJourney()
    local playerLevel = UnitLevel("player")

    if playerLevel < 60 then
        self:PopulateJourneyPre60(playerLevel)
    elseif playerLevel < 68 then
        self:PopulateJourneyLeveling(playerLevel)
    else
        self:PopulateJourneyEndgame()
    end
end

--[[
    Pre-60 Journey tab (Level 1-59)
    Shows "Journey to Outland" encouragement with progress to level 60
]]
function Journal:PopulateJourneyPre60(playerLevel)
    local Components = HopeAddon.Components
    local scrollContainer = self.mainFrame.scrollContainer

    -- === JOURNEY TO OUTLAND HEADER BOX ===
    local container = self:AcquireContainer(scrollContainer.content, 130)

    -- Title
    local title = container.pre60Title
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.pre60Title = title
    end
    title:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -12)
    title:SetText(HopeAddon:ColorText("JOURNEY TO OUTLAND", "GOLD_BRIGHT"))

    -- Level display
    local levelText = container.pre60Level
    if not levelText then
        levelText = container:CreateFontString(nil, "OVERLAY")
        container.pre60Level = levelText
    end
    levelText:SetFont(HopeAddon.assets.fonts.TITLE, 24)
    levelText:ClearAllPoints()
    levelText:SetPoint("TOPRIGHT", container, "TOPRIGHT", -15, -12)
    levelText:SetText(HopeAddon:ColorText("Level " .. playerLevel, "FEL_GREEN"))

    -- Progress bar (1-60)
    local progress = (playerLevel / 60) * 100
    local progressBar = container.pre60ProgressBar
    if not progressBar then
        progressBar = Components:CreateProgressBar(container, 350, 16, "FEL_GREEN")
        container.pre60ProgressBar = progressBar
    end
    progressBar:ClearAllPoints()
    progressBar:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    progressBar:SetProgress(progress)

    -- Progress label
    local progressLabel = container.pre60ProgressLabel
    if not progressLabel then
        progressLabel = container:CreateFontString(nil, "OVERLAY")
        container.pre60ProgressLabel = progressLabel
    end
    progressLabel:SetFont(HopeAddon.assets.fonts.BODY, 10)
    progressLabel:ClearAllPoints()
    progressLabel:SetPoint("LEFT", progressBar, "RIGHT", 10, 0)
    progressLabel:SetText(HopeAddon:ColorText(string.format("%d / 60", playerLevel), "GREY"))

    -- Story text
    local storyText = container.pre60Story
    if not storyText then
        storyText = container:CreateFontString(nil, "OVERLAY")
        container.pre60Story = storyText
    end
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    storyText:ClearAllPoints()
    storyText:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -10)
    storyText:SetWidth(400)
    storyText:SetWordWrap(true)
    storyText:SetTextColor(0.8, 0.8, 0.8)

    local levelsRemaining = 60 - playerLevel
    if levelsRemaining == 1 then
        storyText:SetText("The Dark Portal awaits! Just one more level until you can step through into Outland and begin your adventure in the shattered realm.")
    elseif levelsRemaining <= 5 then
        storyText:SetText("The Dark Portal grows closer! Only " .. levelsRemaining .. " levels remain before you can venture through into Outland and face the Burning Legion's forces.")
    else
        storyText:SetText("Continue your journey through Azeroth. When you reach level 60, the Dark Portal will open and a new adventure awaits in the shattered realm of Outland.")
    end

    scrollContainer:AddEntry(container)

    -- === WHAT AWAITS SECTION ===
    local awaitsContainer = self:AcquireContainer(scrollContainer.content, 120)

    -- Section header
    local awaitsTitle = awaitsContainer.awaitsTitle
    if not awaitsTitle then
        awaitsTitle = awaitsContainer:CreateFontString(nil, "OVERLAY")
        awaitsContainer.awaitsTitle = awaitsTitle
    end
    awaitsTitle:SetFont(HopeAddon.assets.fonts.HEADER, 13)
    awaitsTitle:ClearAllPoints()
    awaitsTitle:SetPoint("TOPLEFT", awaitsContainer, "TOPLEFT", 15, -12)
    awaitsTitle:SetText(HopeAddon:ColorText("WHAT AWAITS IN OUTLAND", "ARCANE_PURPLE"))

    -- Bullet points
    local bulletText = awaitsContainer.bulletText
    if not bulletText then
        bulletText = awaitsContainer:CreateFontString(nil, "OVERLAY")
        awaitsContainer.bulletText = bulletText
    end
    bulletText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    bulletText:ClearAllPoints()
    bulletText:SetPoint("TOPLEFT", awaitsTitle, "BOTTOMLEFT", 0, -10)
    bulletText:SetWidth(400)
    bulletText:SetWordWrap(true)
    bulletText:SetSpacing(4)
    bulletText:SetTextColor(0.9, 0.9, 0.9)
    bulletText:SetText(
        HopeAddon:ColorText("At Level 60:", "GOLD_BRIGHT") .. "\n" ..
        "  • Hellfire Ramparts (60-62) - Your first Outland dungeon\n" ..
        "  • Blood Furnace (61-63) - Face Magtheridon's minions\n" ..
        "  • Gear recommendations tailored to your spec\n" ..
        "  • Begin your journey through Outland's zones"
    )

    scrollContainer:AddEntry(awaitsContainer)
end

--[[
    Endgame Journey tab (Level 68+)
    Includes "YOU ARE PREPARED" summary section with attunements and tier progress
]]
function Journal:PopulateJourneyEndgame()
    local entries = HopeAddon.charDb.journal.entries
    local Components = HopeAddon.Components
    local scrollContainer = self.mainFrame.scrollContainer

    -- === YOUR NEXT STEP - PROMINENT GUIDANCE BOX ===
    local nextStepBox = self:CreateNextStepBox()
    scrollContainer:AddEntry(nextStepBox)

    -- === YOU ARE PREPARED SUMMARY SECTION ===

    -- Header with title
    local header = self:CreateJourneySummaryHeader()
    scrollContainer:AddEntry(header)

    -- 3. Tier Progress Cards (T4/T5/T6)
    local tierSection = self:CreateTierProgressSection()
    scrollContainer:AddEntry(tierSection)

    -- 4. Attunement Summary (compact)
    local attuneSection = self:CreateAttunementSummary()
    scrollContainer:AddEntry(attuneSection)

    -- === LOOT HOTLIST SECTION ===
    -- Shows top 3 recommended items for the player's class
    local lootSection = self:CreateLootHotlist()
    scrollContainer:AddEntry(lootSection)
end

--[[
    Leveling Journey tab (Level 60-67)
    Shows gear recommendations from dungeons and quests based on player level and role
]]
function Journal:PopulateJourneyLeveling(playerLevel)
    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local scrollContainer = self.mainFrame.scrollContainer

    -- Get player's role based on spec
    local _, classToken = UnitClass("player")
    local specName, specTab, specPoints = HopeAddon:GetPlayerSpec()
    local role = HopeAddon:GetSpecRole(classToken, specTab) or "melee_dps"

    -- Get level range info
    local rangeKey = C:GetLevelRangeKey(playerLevel)
    local rangeInfo = nil
    for _, range in ipairs(C.LEVELING_RANGES) do
        if range.key == rangeKey then
            rangeInfo = range
            break
        end
    end

    -- Get role info
    local roleInfo = C.LEVELING_ROLES[role]

    -- === LEVEL PROGRESS BOX ===
    local levelBox = self:CreateLevelingProgressBox(playerLevel, rangeInfo)
    scrollContainer:AddEntry(levelBox)

    -- === GEAR RECOMMENDATIONS HEADER ===
    local gearHeader = self:CreateLevelingGearHeader(role, roleInfo, rangeInfo, specName, specPoints)
    scrollContainer:AddEntry(gearHeader)

    -- === GEAR SECTIONS ===
    local gearData = C:GetLevelingGear(role, playerLevel)
    if gearData then
        -- Dungeon Drops Section
        if gearData.dungeons and #gearData.dungeons > 0 then
            local dungeonSection = self:CreateLevelingGearSection("Dungeon Drops", "FEL_GREEN", gearData.dungeons, "dungeon")
            scrollContainer:AddEntry(dungeonSection)
        end

        -- Quest Rewards Section
        if gearData.quests and #gearData.quests > 0 then
            local questSection = self:CreateLevelingGearSection("Quest Rewards", "GOLD_BRIGHT", gearData.quests, "quest")
            scrollContainer:AddEntry(questSection)
        end
    end

    -- === RECOMMENDED DUNGEONS ===
    local dungeons = C:GetRecommendedDungeons(playerLevel)
    if dungeons then
        local dungeonList = self:CreateRecommendedDungeonsList(dungeons, rangeInfo)
        scrollContainer:AddEntry(dungeonList)
    end
end

--[[
    Create leveling progress box showing current level and XP-style progress
]]
function Journal:CreateLevelingProgressBox(playerLevel, rangeInfo)
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 90)
    local Components = HopeAddon.Components

    -- Calculate progress within level range
    local minLevel = rangeInfo and rangeInfo.minLevel or 60
    local maxLevel = rangeInfo and rangeInfo.maxLevel or 62
    local progress = ((playerLevel - minLevel) / (maxLevel - minLevel + 1)) * 100

    -- Title
    local title = container.levelTitle
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.levelTitle = title
    end
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -12)
    title:SetText(HopeAddon:ColorText("YOUR JOURNEY", "GOLD_BRIGHT"))

    -- Level display
    local levelText = container.levelText
    if not levelText then
        levelText = container:CreateFontString(nil, "OVERLAY")
        container.levelText = levelText
    end
    levelText:SetFont(HopeAddon.assets.fonts.TITLE, 24)
    levelText:ClearAllPoints()
    levelText:SetPoint("LEFT", title, "RIGHT", 15, 0)
    levelText:SetText(HopeAddon:ColorText("Level " .. playerLevel, "FEL_GREEN"))

    -- Range label
    local rangeLabel = container.rangeLabel
    if not rangeLabel then
        rangeLabel = container:CreateFontString(nil, "OVERLAY")
        container.rangeLabel = rangeLabel
    end
    rangeLabel:SetFont(HopeAddon.assets.fonts.BODY, 11)
    rangeLabel:ClearAllPoints()
    rangeLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    local rangeLabelText = rangeInfo and rangeInfo.label or "Level 60-62"
    local dungeonGroup = rangeInfo and rangeInfo.dungeonGroup or "Hellfire Citadel"
    rangeLabel:SetText(rangeLabelText .. " - " .. HopeAddon:ColorText(dungeonGroup, "SKY_BLUE"))

    -- Progress bar
    local progressBar = container.levelProgressBar
    if not progressBar then
        progressBar = Components:CreateProgressBar(container, 350, 16, "FEL_GREEN")
        container.levelProgressBar = progressBar
    end
    progressBar:ClearAllPoints()
    progressBar:SetPoint("TOPLEFT", rangeLabel, "BOTTOMLEFT", 0, -10)
    progressBar:SetProgress(progress)

    -- Story text
    local storyText = container.storyText
    if not storyText then
        storyText = container:CreateFontString(nil, "OVERLAY")
        container.storyText = storyText
    end
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 10)
    storyText:ClearAllPoints()
    storyText:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -6)
    storyText:SetTextColor(0.7, 0.7, 0.7)
    local storyMessages = {
        ["60-62"] = "Begin your journey through Hellfire Peninsula...",
        ["63-65"] = "Venture into the depths of Coilfang and Auchindoun...",
        ["66-67"] = "Prepare for the challenges ahead in Auchindoun and the Caverns of Time...",
    }
    storyText:SetText(storyMessages[rangeInfo and rangeInfo.key or "60-62"] or "Continue your adventure...")

    return container
end

--[[
    Create header showing player's role and gear recommendations context
]]
function Journal:CreateLevelingGearHeader(role, roleInfo, rangeInfo, specName, specPoints)
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, 50)

    -- Get class color
    local _, classToken = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[classToken] or { r = 1, g = 0.84, b = 0 }
    local hexColor = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

    -- Role color
    local roleColor = roleInfo and HopeAddon.colors[roleInfo.color] or HopeAddon.colors.GOLD_BRIGHT
    local roleHex = string.format("%02x%02x%02x", roleColor.r * 255, roleColor.g * 255, roleColor.b * 255)

    -- Main title
    local title = container.gearTitle
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.gearTitle = title
    end
    title:SetFont(HopeAddon.assets.fonts.HEADER, 13)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -10)
    title:SetText(HopeAddon:ColorText("GEAR FOR YOUR JOURNEY", "GOLD_BRIGHT"))

    -- Spec/role info
    local specInfo = container.specInfo
    if not specInfo then
        specInfo = container:CreateFontString(nil, "OVERLAY")
        container.specInfo = specInfo
    end
    specInfo:SetFont(HopeAddon.assets.fonts.BODY, 11)
    specInfo:ClearAllPoints()
    specInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    local roleName = roleInfo and roleInfo.name or "DPS"
    specInfo:SetText("|cFF" .. hexColor .. specName .. "|r |cFFAAAAAA(" .. specPoints .. " pts)|r - |cFF" .. roleHex .. roleName .. "|r")

    return container
end

--[[
    Create a collapsible gear section for dungeon drops or quest rewards
]]
function Journal:CreateLevelingGearSection(sectionTitle, colorName, items, sourceType)
    local itemCount = #items
    local sectionHeight = 38 + (itemCount * 75)  -- header + items
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, sectionHeight)

    local color = HopeAddon.colors[colorName] or HopeAddon.colors.GOLD_BRIGHT
    local hexColor = string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    -- Section header
    local header = container.sectionHeader
    if not header then
        header = CreateFrame("Frame", nil, container, "BackdropTemplate")
        header:SetHeight(30)
        header:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        header:SetBackdropColor(0.1, 0.1, 0.12, 0.9)
        header:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)
        container.sectionHeader = header
    end
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5)
    header:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -5)
    header:SetBackdropBorderColor(color.r, color.g, color.b, 0.6)

    -- Header icon
    local headerIcon = header.icon
    if not headerIcon then
        headerIcon = header:CreateTexture(nil, "ARTWORK")
        headerIcon:SetSize(18, 18)
        header.icon = headerIcon
    end
    headerIcon:ClearAllPoints()
    headerIcon:SetPoint("LEFT", header, "LEFT", 10, 0)
    local iconPath = sourceType == "dungeon" and "INV_Misc_Bone_HumanSkull_01" or "INV_Misc_Book_07"
    headerIcon:SetTexture("Interface\\Icons\\" .. iconPath)

    -- Header title
    local headerTitle = header.titleText
    if not headerTitle then
        headerTitle = header:CreateFontString(nil, "OVERLAY")
        header.titleText = headerTitle
    end
    headerTitle:SetFont(HopeAddon.assets.fonts.HEADER, 11)
    headerTitle:ClearAllPoints()
    headerTitle:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerTitle:SetText("|cFF" .. hexColor .. sectionTitle .. "|r")

    -- Item cards
    local yOffset = -40
    for i, item in ipairs(items) do
        local cardKey = "levelGearCard_" .. sourceType .. "_" .. i
        local card = self:CreateLevelingGearCard(container, item, cardKey, sourceType)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", container, "TOPLEFT", 15, yOffset)
        card:SetPoint("RIGHT", container, "RIGHT", -15, 0)
        card:Show()
        yOffset = yOffset - 75
    end

    return container
end

--[[
    Create a single gear item card for leveling recommendations
]]
function Journal:CreateLevelingGearCard(parent, item, cardKey, sourceType)
    local card = parent[cardKey]

    if not card then
        card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetHeight(70)
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        card:SetBackdropColor(0.06, 0.06, 0.08, 0.95)
        card:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)

        -- Item icon
        card.itemIcon = card:CreateTexture(nil, "ARTWORK")
        card.itemIcon:SetSize(36, 36)
        card.itemIcon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)

        -- Icon border
        card.iconBorder = card:CreateTexture(nil, "OVERLAY")
        card.iconBorder:SetSize(40, 40)
        card.iconBorder:SetPoint("CENTER", card.itemIcon, "CENTER", 0, 0)
        card.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        card.iconBorder:SetBlendMode("ADD")

        -- Item name
        card.itemName = card:CreateFontString(nil, "OVERLAY")
        card.itemName:SetFont(HopeAddon.assets.fonts.BODY, 11)
        card.itemName:SetPoint("TOPLEFT", card.itemIcon, "TOPRIGHT", 10, -2)

        -- Slot text
        card.slotText = card:CreateFontString(nil, "OVERLAY")
        card.slotText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
        card.slotText:SetPoint("TOPLEFT", card.itemName, "BOTTOMLEFT", 0, -2)

        -- Stats text
        card.statsText = card:CreateFontString(nil, "OVERLAY")
        card.statsText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
        card.statsText:SetPoint("TOPLEFT", card.slotText, "BOTTOMLEFT", 0, -2)

        -- Source text
        card.sourceText = card:CreateFontString(nil, "OVERLAY")
        card.sourceText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
        card.sourceText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 56, 8)

        parent[cardKey] = card
    end

    -- Set item icon
    local iconPath = item.icon or "INV_Misc_QuestionMark"
    if not string.find(iconPath, "Interface") then
        iconPath = "Interface\\Icons\\" .. iconPath
    end
    card.itemIcon:SetTexture(iconPath)

    -- Quality color
    local qualityColors = {
        common = { r = 1, g = 1, b = 1 },
        uncommon = { r = 0.12, g = 1, b = 0 },
        rare = { r = 0, g = 0.44, b = 0.87 },
        epic = { r = 0.64, g = 0.21, b = 0.93 },
    }
    local qColor = qualityColors[item.quality or "uncommon"] or qualityColors.uncommon
    card.iconBorder:SetVertexColor(qColor.r, qColor.g, qColor.b, 0.8)

    -- Item name in quality color
    local qHex = string.format("%02x%02x%02x", qColor.r * 255, qColor.g * 255, qColor.b * 255)
    card.itemName:SetText("|cFF" .. qHex .. (item.name or "Unknown Item") .. "|r")

    -- Slot
    card.slotText:SetText("|cFFAAAAAA" .. (item.slot or "Gear") .. "|r")

    -- Stats
    card.statsText:SetText("|cFF88FF88" .. (item.stats or "") .. "|r")

    -- Source info
    local sourceColor = sourceType == "dungeon" and "FEL_GREEN" or "GOLD_BRIGHT"
    local sourceHex = HopeAddon.colors[sourceColor]
    sourceHex = string.format("%02x%02x%02x", sourceHex.r * 255, sourceHex.g * 255, sourceHex.b * 255)

    local sourceInfo = ""
    if sourceType == "dungeon" then
        sourceInfo = (item.boss or "") .. " - " .. (item.source or "")
    else
        sourceInfo = "Quest: " .. (item.source or "") .. " (" .. (item.zone or "") .. ")"
    end
    card.sourceText:SetText("|cFF" .. sourceHex .. sourceInfo .. "|r")

    -- Enable mouse for tooltip
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if item.itemId then
            GameTooltip:SetHyperlink("item:" .. item.itemId)
        else
            GameTooltip:SetText(item.name)
            GameTooltip:AddLine(item.stats, 0.6, 0.8, 0.6)
            GameTooltip:AddLine(item.source, 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return card
end

--[[
    Create recommended dungeons list for the current level range
]]
function Journal:CreateRecommendedDungeonsList(dungeons, rangeInfo)
    local dungeonCount = #dungeons
    local containerHeight = 45 + (dungeonCount * 28)
    local container = self:AcquireContainer(self.mainFrame.scrollContainer.content, containerHeight)

    -- Section title
    local title = container.dungeonTitle
    if not title then
        title = container:CreateFontString(nil, "OVERLAY")
        container.dungeonTitle = title
    end
    title:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -10)
    title:SetText(HopeAddon:ColorText("RECOMMENDED DUNGEONS", "SKY_BLUE"))

    -- Dungeon list
    local yOffset = -35
    for i, dungeon in ipairs(dungeons) do
        local dungeonKey = "dungeonEntry_" .. i
        local entry = container[dungeonKey]

        if not entry then
            entry = container:CreateFontString(nil, "OVERLAY")
            container[dungeonKey] = entry
        end
        entry:SetFont(HopeAddon.assets.fonts.BODY, 10)
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", container, "TOPLEFT", 25, yOffset)

        local levelColor = "AAAAAA"
        local nameColor = "FFFFFF"
        local zoneColor = "888888"

        entry:SetText("|cFF" .. nameColor .. dungeon.name .. "|r |cFF" .. levelColor .. "(" .. dungeon.level .. ")|r - |cFF" .. zoneColor .. dungeon.zone .. "|r")
        entry:Show()

        yOffset = yOffset - 28
    end

    return container
end

--[[
    CHRONICLE MILESTONES HELPERS
    Three-act structure for the Hero's Journey milestones page
]]

-- Major milestones that get enhanced visual treatment
local MAJOR_MILESTONES = { [40] = true, [58] = true, [60] = true, [70] = true }

--[[
    Create the chronicle header with title, subtitle, and progress bar
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

-- Get the best reputation item for a faction based on player's class/spec
function Journal:GetBestRepItemForFaction(factionName)
    local C = HopeAddon.Constants

    -- Get player's class and spec
    local _, classToken = UnitClass("player")
    local specName, specTab = HopeAddon:GetPlayerSpec()

    -- Default to spec 1 if detection fails
    if not specTab or specTab < 1 then specTab = 1 end

    -- Look up items in CLASS_SPEC_LOOT_HOTLIST
    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    if not classData then return nil end

    local specData = classData[specTab]
    if not specData or not specData.rep then return nil end

    -- Find best item from this faction (prefer higher standing requirement = better item)
    local bestItem = nil
    for _, item in ipairs(specData.rep) do
        if item.faction == factionName then
            if not bestItem or (item.standing or 0) > (bestItem.standing or 0) then
                bestItem = item
            end
        end
    end

    return bestItem
end

-- Get ALL reputation items for a faction grouped by standing
-- Returns: { [standingId] = item } table with one item per standing
function Journal:GetRepItemsByStanding(factionName)
    local C = HopeAddon.Constants

    -- Get player's class and spec
    local _, classToken = UnitClass("player")
    local _, specTab = HopeAddon:GetPlayerSpec()

    -- Default to spec 1 if detection fails
    if not specTab or specTab < 1 then specTab = 1 end

    -- Look up items in CLASS_SPEC_LOOT_HOTLIST
    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    if not classData then return {} end

    local specData = classData[specTab]
    if not specData or not specData.rep then return {} end

    -- Group items by standing for this faction
    local itemsByStanding = {}
    for _, item in ipairs(specData.rep) do
        if item.faction == factionName and item.standing then
            -- Keep the best quality item if multiple at same standing
            if not itemsByStanding[item.standing] or
               (item.quality or 0) > (itemsByStanding[item.standing].quality or 0) then
                itemsByStanding[item.standing] = item
            end
        end
    end

    return itemsByStanding
end

-- Create a clickable item icon link for reputation rewards
function Journal:CreateRepItemLink(card, reputationBar, item, currentStanding)
    local C = HopeAddon.Constants

    local itemFrame = CreateFrame("Button", nil, card)
    itemFrame:SetSize(24, 24)
    itemFrame:SetPoint("LEFT", reputationBar, "RIGHT", 8, 0)

    -- Item icon
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\Icons\\" .. item.icon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Quality border color
    local qualityColor = C.ITEM_QUALITY_COLORS[item.quality] or C.ITEM_QUALITY_COLORS.common

    local border = itemFrame:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetPoint("CENTER", itemFrame, "CENTER", 0, 0)
    border:SetSize(36, 36)
    border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Grey out if standing not met
    local requiredStanding = item.standing or 8
    if currentStanding < requiredStanding then
        icon:SetDesaturated(true)
        icon:SetVertexColor(0.5, 0.5, 0.5)
        border:SetVertexColor(0.4, 0.4, 0.4)
    end

    -- Tooltip on hover
    itemFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. item.itemId)
        GameTooltip:AddLine(" ")
        if currentStanding >= requiredStanding then
            GameTooltip:AddLine("You can purchase this!", 0, 1, 0)
        else
            local standingNames = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
            GameTooltip:AddLine("Requires: " .. (standingNames[requiredStanding] or "Unknown"), 1, 0.5, 0)
        end
        GameTooltip:Show()
        HopeAddon.Sounds:PlayHover()
    end)
    itemFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Click to print item info
    itemFrame:SetScript("OnClick", function(self)
        local colorHex = string.format("%02X%02X%02X", qualityColor.r * 255, qualityColor.g * 255, qualityColor.b * 255)
        HopeAddon:Print("|cFF" .. colorHex .. "[" .. item.name .. "]|r - " .. item.stats)
        HopeAddon.Sounds:PlayClick()
    end)

    return itemFrame
end

-- Fallback standing label for factions without items in the hotlist
function Journal:CreateStandingLabel(card, reputationBar, standingName, standingId)
    local label = card:CreateFontString(nil, "OVERLAY")
    label:SetFont(HopeAddon.assets.fonts.BODY, 10)
    label:SetPoint("LEFT", reputationBar, "RIGHT", 8, 0)
    label:SetText(standingName)

    -- Color by standing
    local standingColors = {
        [1] = {0.5, 0.5, 0.5}, [2] = {0.5, 0.5, 0.5}, [3] = {0.5, 0.5, 0.5}, [4] = {0.5, 0.5, 0.5},
        [5] = {0, 0.8, 0}, [6] = {0, 0.6, 0.8}, [7] = {0, 0.4, 0.8}, [8] = {0.6, 0.2, 1}
    }
    local c = standingColors[standingId] or {0.5, 0.5, 0.5}
    label:SetTextColor(c[1], c[2], c[3])

    return label
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

        -- Get progress within current standing
        if Reputation then
            local curr, mx, _ = Reputation:GetProgressInStanding(info.name)
            if curr then current = curr end
            if mx then max = mx end
        end
    end

    local r, g, b = Data:GetStandingColor(standingId)

    -- Determine icon
    local icon = "Interface\\Icons\\"
    if info.isSpecial then
        icon = icon .. (info.icon or "INV_Misc_QuestionMark")
    elseif info.data then
        icon = icon .. (info.data.icon or "INV_Misc_QuestionMark")
    end

    -- Build description using quips (humorous remarks)
    local description = ""
    if info.isSpecial then
        description = info.description or ""
    elseif info.data then
        local quipKey = standingId
        if standingId <= 4 and current == 0 and max == 0 then
            quipKey = 0 -- Not started yet
        end
        if info.data.quips and info.data.quips[quipKey] then
            description = "|cFFFFD700\"|r" .. info.data.quips[quipKey] .. "|cFFFFD700\"|r"
        elseif info.data.quips and info.data.quips[standingId] then
            description = "|cFFFFD700\"|r" .. info.data.quips[standingId] .. "|cFFFFD700\"|r"
        else
            description = info.data.description or ""
        end
    end

    -- Create card (taller for progress bar + item icons)
    local needsProgressBar = not info.isSpecial and info.data
    local cardHeight = needsProgressBar and 140 or 80  -- Extra height for bar + icons + labels

    local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
        icon = icon,
        title = info.name,
        description = description,
        timestamp = "",  -- We show standing in the badge instead
    })
    card:SetHeight(cardHeight)

    -- Set border color based on standing
    card:SetBackdropBorderColor(r, g, b, 1)
    card.defaultBorderColor = {r, g, b, 1}

    -- Grey out border for "not started" factions
    if not info.isSpecial and standingId <= 4 and current == 0 and (max == 0 or max == nil) then
        card:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        card.defaultBorderColor = {0.4, 0.4, 0.4, 0.8}
    end

    -- Add segmented progress bar for regular factions
    if needsProgressBar then
        -- Calculate bar width: card width - icon - margins - badge space
        local barWidth = card:GetWidth() - Components.ICON_SIZE_STANDARD - 3 * Components.MARGIN_NORMAL - 60

        -- Create the new segmented reputation bar (includes icons above and labels below)
        local repBar = Components:CreateSegmentedReputationBar(card, barWidth, 14)
        repBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",
            Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL, 4)

        -- Calculate progress within current standing (0-1)
        local progress = 0
        if max and max > 0 then
            progress = current / max
        end

        -- Set the standing
        repBar:SetStanding(standingId, progress)
        card.reputationBar = repBar

        -- Get items by standing and add icons above each segment
        local itemsByStanding = self:GetRepItemsByStanding(info.name)
        for standing = 5, 8 do
            local item = itemsByStanding[standing]
            if item then
                repBar:SetItemIcon(standing, item, standingId)
            end
        end
    end

    -- Add golden glow for Exalted
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

            -- Show level requirements
            if attunementData.minLevel or attunementData.recommendedLevel then
                local levelContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 15)
                local levelText = levelContainer.headerText
                if not levelText then
                    levelText = levelContainer:CreateFontString(nil, "OVERLAY")
                    levelContainer.headerText = levelText
                end
                levelText:ClearAllPoints()
                levelText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
                levelText:SetPoint("TOPLEFT", levelContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)

                local levelStr = ""
                if attunementData.minLevel then
                    levelStr = "Minimum Level: " .. attunementData.minLevel
                end
                if attunementData.recommendedLevel then
                    if levelStr ~= "" then
                        levelStr = levelStr .. " | "
                    end
                    levelStr = levelStr .. "Recommended: " .. attunementData.recommendedLevel
                end
                levelText:SetText(HopeAddon:ColorText(levelStr, "GOLD_BRIGHT"))
                self.mainFrame.scrollContainer:AddEntry(levelContainer)
            end

            -- Show detailed prerequisites (keys, reputation, etc.)
            if attunementData.prerequisites and #attunementData.prerequisites > 0 then
                local prereqHeader = self:AcquireContainer(self.mainFrame.scrollContainer.content, 16)
                local prereqHeaderText = prereqHeader.headerText
                if not prereqHeaderText then
                    prereqHeaderText = prereqHeader:CreateFontString(nil, "OVERLAY")
                    prereqHeader.headerText = prereqHeaderText
                end
                prereqHeaderText:ClearAllPoints()
                prereqHeaderText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
                prereqHeaderText:SetPoint("TOPLEFT", prereqHeader, "TOPLEFT", Components.MARGIN_NORMAL, -2)
                prereqHeaderText:SetText(HopeAddon:ColorText("Prerequisites:", "HELLFIRE_ORANGE"))
                self.mainFrame.scrollContainer:AddEntry(prereqHeader)

                for _, prereq in ipairs(attunementData.prerequisites) do
                    local prereqItem = self:AcquireContainer(self.mainFrame.scrollContainer.content, 14)
                    local prereqItemText = prereqItem.headerText
                    if not prereqItemText then
                        prereqItemText = prereqItem:CreateFontString(nil, "OVERLAY")
                        prereqItem.headerText = prereqItemText
                    end
                    prereqItemText:ClearAllPoints()
                    prereqItemText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
                    prereqItemText:SetPoint("TOPLEFT", prereqItem, "TOPLEFT", Components.MARGIN_NORMAL + 10, -1)

                    local prereqStr = "  \226\128\162 " .. prereq.name
                    if prereq.source then
                        prereqStr = prereqStr .. " - " .. prereq.source
                    end
                    prereqItemText:SetText(prereqStr)
                    prereqItemText:SetTextColor(0.9, 0.7, 0.5, 1)
                    prereqItemText:SetWidth(self.mainFrame.scrollContainer.content:GetWidth() - 50)
                    prereqItemText:SetWordWrap(true)
                    self.mainFrame.scrollContainer:AddEntry(prereqItem)
                end
            end

            -- Show prerequisite if any (legacy single prerequisite)
            if summary.prerequisite and not (attunementData.prerequisites and #attunementData.prerequisites > 0) then
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

            -- Progress bar container (fixes memory leak - progressBar now properly tracked)
            local progressContainer = self:AcquireContainer(self.mainFrame.scrollContainer.content, 25)

            -- Progress bar parented to container so it gets cleaned up on tab switch
            local progressBar = Components:CreateProgressBar(
                progressContainer,
                self.mainFrame.scrollContainer.content:GetWidth() - 30,
                20,
                summary.isAttuned and "FEL_GREEN" or tierColor
            )
            progressBar:SetPoint("TOP", progressContainer, "TOP", 0, -2)
            progressBar:SetProgress(summary.percentage)
            -- Hide the built-in percentage text to avoid overlap with our custom text
            progressBar.text:Hide()

            -- Progress text overlay
            local progressText = progressBar:CreateFontString(nil, "OVERLAY")
            progressText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
            progressText:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
            progressText:SetText(string.format("%d/%d Chapters (%d%%)",
                summary.completedChapters, summary.totalChapters, summary.percentage))
            progressText:SetTextColor(1, 1, 1, 1)

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

                local statusIcon = isComplete and "|cFF44CC44[X]|r " or "|cFF666666[ ]|r "

                -- Build description using table.concat for efficiency
                local descParts = { chapter.story or "" }

                -- Add level requirement
                if chapter.minLevel then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Requires Level " .. chapter.minLevel, "GOLD_BRIGHT")
                end

                -- Add quest giver and location
                if chapter.questGiver then
                    local locText = chapter.questGiver
                    if chapter.location then
                        locText = locText .. " - " .. chapter.location
                    end
                    descParts[#descParts + 1] = HopeAddon:ColorText("Quest Giver: " .. locText, "GOLD_BRIGHT")
                end

                -- Add turn-in location if different from quest giver
                if chapter.turnIn then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Turn In: " .. chapter.turnIn, "GOLD_BRIGHT")
                end

                -- Add difficulty badge
                if chapter.difficulty then
                    local diffData = C.ATTUNEMENT_DIFFICULTY[chapter.difficulty]
                    if diffData then
                        descParts[#descParts + 1] = HopeAddon:ColorText("Difficulty: " .. diffData.label, diffData.color)
                    end
                end

                -- Add dungeon/raid requirements with level
                if chapter.dungeon then
                    local dungeonText = chapter.dungeon
                    if chapter.dungeonLevel then
                        dungeonText = dungeonText .. " (Level " .. chapter.dungeonLevel .. ")"
                    end
                    descParts[#descParts + 1] = HopeAddon:ColorText("Dungeon: " .. dungeonText, "SKY_BLUE")
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

                -- Add prerequisite (key/rep requirements)
                if chapter.prerequisite then
                    descParts[#descParts + 1] = HopeAddon:ColorText("Prerequisite: " .. chapter.prerequisite, "HELLFIRE_ORANGE")
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

                -- Store detailed info for enhanced tooltip
                card.chapterName = chapter.name
                card.tips = chapter.tips
                card.objectives = chapter.objectives
                card.rewards = chapter.rewards
                card.quests = chapter.quests

                if isComplete then
                    card:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                elseif chapter.noFactionChosen then
                    card:SetBackdropBorderColor(1, 0.5, 0.3, 1) -- Orange for no faction chosen
                else
                    card:SetAlpha(0.7)
                end

                -- Enhanced tooltip with objectives, rewards, tips on hover
                local oldOnEnter = card:GetScript("OnEnter")
                card:SetScript("OnEnter", function(self)
                    if oldOnEnter then oldOnEnter(self) end

                    local hasContent = (self.objectives and #self.objectives > 0) or
                                      (self.rewards) or
                                      (self.quests and #self.quests > 0) or
                                      (self.tips and #self.tips > 0)

                    if hasContent then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(self.chapterName, 1, 0.84, 0)

                        -- Show objectives
                        if self.objectives and #self.objectives > 0 then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("Objectives:", 0.2, 0.8, 1)
                            for _, obj in ipairs(self.objectives) do
                                GameTooltip:AddLine("  \226\128\162 " .. obj, 0.9, 0.9, 0.9, true)
                            end
                        end

                        -- Show quests
                        if self.quests and #self.quests > 0 then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("Quests:", 1, 0.84, 0)
                            for _, quest in ipairs(self.quests) do
                                GameTooltip:AddLine("  \226\128\162 " .. quest.name, 0.9, 0.9, 0.7, true)
                            end
                        end

                        -- Show rewards
                        if self.rewards then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("Rewards:", 0.1, 0.9, 0.1)
                            if self.rewards.xp then
                                GameTooltip:AddLine("  XP: " .. self.rewards.xp, 0.8, 0.6, 1)
                            end
                            if self.rewards.reputation then
                                local rep = self.rewards.reputation
                                GameTooltip:AddLine("  " .. rep.name .. ": +" .. rep.amount, 0.4, 0.8, 0.4)
                            end
                        end

                        -- Show tips
                        if self.tips and #self.tips > 0 then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("Tips:", 1, 0.5, 0)
                            for _, tip in ipairs(self.tips) do
                                GameTooltip:AddLine("  \226\128\162 " .. tip, 0.8, 0.8, 0.8, true)
                            end
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
            local attuneSpacer = self:CreateSpacer(20)
            self.mainFrame.scrollContainer:AddEntry(attuneSpacer)
        end
    end

    -- Cipher of Damnation section (TK prerequisite)
    local cipherSpacer = self:CreateSpacer(10)
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
    -- Hide the built-in percentage text to avoid overlap with our custom text
    cipherProgressBar.text:Hide()

    local cipherProgressText = cipherProgressBar:CreateFontString(nil, "OVERLAY")
    cipherProgressText:SetFont(HopeAddon.assets.fonts.SMALL, 9)
    cipherProgressText:SetPoint("CENTER", cipherProgressBar, "CENTER", 0, 0)
    cipherProgressText:SetText(string.format("%d/%d (%d%%)",
        cipherSummary.completedChapters, cipherSummary.totalChapters, cipherSummary.percentage))
    cipherProgressText:SetTextColor(1, 1, 1, 1)

    local cipherProgressContainer = self:CreateSpacer(25)
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
            local statusIcon = hasKey and "|cFF44CC44[X]|r " or "|cFF666666[ ]|r "

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

    -- Early validation - ensure required data is available
    if not HopeAddon.Constants or not HopeAddon.Constants.RAIDS_BY_TIER then
        HopeAddon:Debug("ERROR: PopulateRaids - RAIDS_BY_TIER not loaded")
        local errorHeader = self:CreateSectionHeader("RAID PROGRESS", "HELLFIRE_RED", "Error: Raid data not loaded")
        scrollContainer:AddEntry(errorHeader)
        return
    end

    if not RaidData then
        HopeAddon:Debug("ERROR: PopulateRaids - RaidData module not loaded")
        local errorHeader = self:CreateSectionHeader("RAID PROGRESS", "HELLFIRE_RED", "Error: RaidData module not loaded")
        scrollContainer:AddEntry(errorHeader)
        return
    end

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("RAID PROGRESS", "HELLFIRE_RED", "Your conquest of TBC raid content")
    scrollContainer:AddEntry(header)

    -- ===== PROGRESS SUMMARY BAR =====
    -- Color name mapping for tiers (these are color NAMES, not color tables)
    local tierColorNames = {
        T4 = "GOLD_BRIGHT",
        T5 = "SKY_BLUE",
        T6 = "HELLFIRE_RED",
    }

    -- Calculate overall raid progress across all tiers
    local raidsByTier = HopeAddon.Constants.RAIDS_BY_TIER
    local tierOrder = { "T4", "T5", "T6" }
    local tierProgress = {}
    local totalKilled, totalBosses = 0, 0

    for _, tier in ipairs(tierOrder) do
        local raids = raidsByTier[tier]
        local tierKilled, tierTotal = 0, 0
        if raids then
            for _, raidKey in ipairs(raids) do
                local killed, total = RaidData:GetRaidProgress(raidKey)
                tierKilled = tierKilled + (killed or 0)
                tierTotal = tierTotal + (total or 0)
            end
        end
        tierProgress[tier] = { killed = tierKilled, total = tierTotal }
        totalKilled = totalKilled + tierKilled
        totalBosses = totalBosses + tierTotal
    end

    -- Create progress summary container
    local progressContainer = self:AcquireContainer(scrollContainer.content, 85)
    if progressContainer then
        -- Get container width (use scroll content width as fallback since container may not be laid out yet)
        local containerWidth = scrollContainer.content:GetWidth()
        if containerWidth <= 0 then containerWidth = 400 end  -- Fallback width

        -- Overall progress percentage
        local overallPercent = totalBosses > 0 and math.floor((totalKilled / totalBosses) * 100) or 0

        -- Overall progress label
        local overallLabel = progressContainer:CreateFontString(nil, "OVERLAY")
        overallLabel:SetFont(HopeAddon.assets.fonts.HEADER, 12)
        overallLabel:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10, -5)
        overallLabel:SetText(HopeAddon:ColorText(string.format("Overall: %d%% Complete (%d/%d bosses)", overallPercent, totalKilled, totalBosses), "GOLD_BRIGHT"))

        -- Overall progress bar
        local overallBar = CreateFrame("StatusBar", nil, progressContainer)
        overallBar:SetSize(containerWidth - 20, 16)
        overallBar:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10, -25)
        overallBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        overallBar:SetMinMaxValues(0, 100)
        overallBar:SetValue(overallPercent)
        local goldColor = HopeAddon:GetSafeColor("GOLD_BRIGHT")
        if goldColor then
            overallBar:SetStatusBarColor(goldColor.r, goldColor.g, goldColor.b)
        else
            overallBar:SetStatusBarColor(1, 0.84, 0)
        end

        -- Bar background
        local barBg = overallBar:CreateTexture(nil, "BACKGROUND")
        barBg:SetAllPoints()
        barBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

        -- Mini tier progress bars (horizontal layout)
        local miniBarWidth = (containerWidth - 40) / 3
        local miniBarHeight = 12

        for i, tier in ipairs(tierOrder) do
            local prog = tierProgress[tier]
            local tierPercent = prog.total > 0 and math.floor((prog.killed / prog.total) * 100) or 0
            local tierColorName = tierColorNames[tier]
            local tierColor = HopeAddon:GetSafeColor(tierColorName)

            -- Tier label
            local tierLabel = progressContainer:CreateFontString(nil, "OVERLAY")
            tierLabel:SetFont(HopeAddon.assets.fonts.NORMAL, 10)
            tierLabel:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10 + (i-1) * (miniBarWidth + 10), -48)
            tierLabel:SetText(HopeAddon:ColorText(string.format("%s: %d/%d", tier, prog.killed, prog.total), tierColorName))

            -- Mini progress bar
            local miniBar = CreateFrame("StatusBar", nil, progressContainer)
            miniBar:SetSize(miniBarWidth - 10, miniBarHeight)
            miniBar:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10 + (i-1) * (miniBarWidth + 10), -62)
            miniBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            miniBar:SetMinMaxValues(0, 100)
            miniBar:SetValue(tierPercent)
            if tierColor then
                miniBar:SetStatusBarColor(tierColor.r, tierColor.g, tierColor.b)
            end

            -- Mini bar background
            local miniBg = miniBar:CreateTexture(nil, "BACKGROUND")
            miniBg:SetAllPoints()
            miniBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        end

        scrollContainer:AddEntry(progressContainer)
    end
    -- ===== END PROGRESS SUMMARY BAR =====

    -- Quick jump tier buttons
    local jumpBar = self:AcquireContainer(scrollContainer.content, 30)
    self.tierSections = {}

    local buttonWidth = 60
    local buttonSpacing = 10

    for i, tier in ipairs(tierOrder) do
        local tierColorName = tierColorNames[tier]
        local tierColor = HopeAddon:GetSafeColor(tierColorName)

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

        -- Add tooltip with safe color access
        jumpBtn:SetScript("OnEnter", function(btn)
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            if tierColor then
                GameTooltip:SetText("Jump to " .. tier .. " Raids", tierColor.r, tierColor.g, tierColor.b)
            else
                GameTooltip:SetText("Jump to " .. tier .. " Raids")
            end
            GameTooltip:Show()
        end)
        jumpBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    scrollContainer:AddEntry(jumpBar)

    for _, tier in ipairs(tierOrder) do
        local tierColorName = tierColorNames[tier]
        local raids = raidsByTier[tier]

        -- Tier header - FontString properly parented to container
        local tierHeaderContainer = self:AcquireContainer(scrollContainer.content, 30)
        if not tierHeaderContainer then
            HopeAddon:Debug("ERROR: Failed to acquire container for tier header:", tier)
        else
            local tierHeader = tierHeaderContainer.headerText
            if not tierHeader then
                tierHeader = tierHeaderContainer:CreateFontString(nil, "OVERLAY")
                tierHeaderContainer.headerText = tierHeader
            end
            tierHeader:ClearAllPoints()
            tierHeader:SetFont(HopeAddon.assets.fonts.HEADER, 14)
            tierHeader:SetPoint("LEFT", tierHeaderContainer, "LEFT", Components.MARGIN_SMALL, 0)
            tierHeader:SetText(HopeAddon:ColorText("--- " .. tier .. " RAIDS ---", tierColorName))
            scrollContainer:AddEntry(tierHeaderContainer)
            self.tierSections[tier] = tierHeaderContainer
        end

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
                    raidIsCleared and "FEL_GREEN" or tierColorName,
                    false -- Start collapsed
                )

                -- Nil check for raidSection before using it
                if not raidSection then
                    HopeAddon:Debug("ERROR: Failed to acquire collapsible section for raid:", raidKey)
                else
                    raidSection.onToggle = function()
                        scrollContainer:RecalculatePositions()
                    end

                    -- Add celebration effects for cleared raids
                    if raidIsCleared then
                        -- Gold border glow effect on the header
                        if raidSection.header and HopeAddon.Effects then
                            -- Set gold border on the header
                            local goldColor = HopeAddon:GetSafeColor("GOLD_BRIGHT")
                            if goldColor and raidSection.header.SetBackdropBorderColor then
                                raidSection.header:SetBackdropBorderColor(goldColor.r, goldColor.g, goldColor.b, 1)
                            end

                            -- Create a subtle pulsing glow effect
                            if HopeAddon.Effects.CreatePulsingGlow then
                                raidSection._clearedGlow = HopeAddon.Effects:CreatePulsingGlow(raidSection.header, "GOLD_BRIGHT", 0.2)
                            end

                            -- Add "CLEARED!" badge with sparkle effect
                            if not raidSection._clearedBadge then
                                local badge = raidSection.header:CreateFontString(nil, "OVERLAY")
                                badge:SetFont(HopeAddon.assets.fonts.HEADER, 10)
                                badge:SetPoint("RIGHT", raidSection.header, "RIGHT", -35, 0)
                                badge:SetText(HopeAddon:ColorText("★ CLEARED ★", "GOLD_BRIGHT"))
                                raidSection._clearedBadge = badge
                            end
                        end
                    end

                    -- Location and size info card (using pool for efficiency)
                    local infoCard = self:AcquireBossInfoCard(
                        raidSection.contentContainer,
                        string.format("%s | %d-player", raid.location, raid.size)
                    )
                    if infoCard then
                        raidSection:AddChild(infoCard)
                    end

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
                            -- Build description with kill count, date, and speed times
                            local descLines = {}
                            table.insert(descLines, string.format("Kills: %d | First: %s", killData.totalKills, killData.firstKill))

                            -- Show best time if available (speed tracking)
                            if killData.bestTime then
                                local bestTimeStr = HopeAddon:FormatTime(killData.bestTime)
                                table.insert(descLines, HopeAddon:ColorText("Best: " .. bestTimeStr, "GOLD_BRIGHT"))

                                -- Show last time with delta if different from best
                                if killData.lastTime and math.abs(killData.lastTime - killData.bestTime) > 0.5 then
                                    local lastTimeStr = HopeAddon:FormatTime(killData.lastTime)
                                    local delta = killData.lastTime - killData.bestTime
                                    local deltaStr = string.format("+%.0fs", delta)
                                    table.insert(descLines, string.format("Last: %s (%s)",
                                        lastTimeStr, HopeAddon:ColorText(deltaStr, "HELLFIRE_RED")))
                                end
                            end

                            -- Add boss quote if available
                            if boss.quote then
                                table.insert(descLines, "")
                                table.insert(descLines, HopeAddon:ColorText('"' .. boss.quote .. '"', "GOLD_BRIGHT"))
                            end

                            description = table.concat(descLines, "\n")
                        else
                            description = boss.lore or boss.location
                        end

                        local card = self:AcquireCard(raidSection.contentContainer, {
                            icon = "Interface\\Icons\\" .. (boss.icon or raid.icon),
                            title = statusIcon .. boss.name .. (boss.finalBoss and " (Final)" or ""),
                            description = description,
                            timestamp = boss.optional and "(Optional)" or "",
                        })

                        if card then
                            -- Add boss tooltip with mechanics and loot
                            card:SetScript("OnEnter", function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

                                -- Boss name header
                                local tierColor = HopeAddon:GetSafeColor(tierColorName)
                                if tierColor then
                                    GameTooltip:AddLine(boss.name, tierColor.r, tierColor.g, tierColor.b)
                                else
                                    GameTooltip:AddLine(boss.name, 1, 0.84, 0)
                                end
                                GameTooltip:AddLine(boss.location or raid.location, 0.8, 0.8, 0.8)

                                -- Boss lore/description
                                if boss.lore then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine(boss.lore, 1, 1, 1, true)
                                end

                                -- Mechanics section
                                if boss.mechanics and #boss.mechanics > 0 then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine("Mechanics:", 1, 0.84, 0)
                                    for _, mechanic in ipairs(boss.mechanics) do
                                        GameTooltip:AddLine("  • " .. mechanic, 0.9, 0.9, 0.9)
                                    end
                                end

                                -- Notable loot section
                                if boss.loot and #boss.loot > 0 then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine("Notable Loot:", 0.6, 0.3, 0.9)
                                    for _, item in ipairs(boss.loot) do
                                        if type(item) == "table" then
                                            -- Item with quality color
                                            local qualityColor = HopeAddon.Constants.ITEM_QUALITY_COLORS and
                                                HopeAddon.Constants.ITEM_QUALITY_COLORS[item.quality or "epic"]
                                            if qualityColor then
                                                GameTooltip:AddLine("  • " .. item.name, qualityColor.r, qualityColor.g, qualityColor.b)
                                            else
                                                GameTooltip:AddLine("  • " .. item.name, 0.64, 0.21, 0.93)
                                            end
                                        else
                                            GameTooltip:AddLine("  • " .. item, 0.64, 0.21, 0.93)
                                        end
                                    end
                                end

                                -- Kill stats if killed
                                if isKilled and killData then
                                    GameTooltip:AddLine(" ")

                                    -- Show kill tier with color (renamed to avoid collision with raid tier)
                                    local Constants = HopeAddon.Constants
                                    local killTier = Constants and Constants.GetBossTier and Constants:GetBossTier(killData.totalKills)
                                    local nextKillTier = Constants and Constants.GetNextBossTier and Constants:GetNextBossTier(killData.totalKills)

                                    if killTier then
                                        local r = tonumber(killTier.colorHex:sub(1, 2), 16) / 255
                                        local g = tonumber(killTier.colorHex:sub(3, 4), 16) / 255
                                        local b = tonumber(killTier.colorHex:sub(5, 6), 16) / 255
                                        GameTooltip:AddLine(string.format("Defeated %d time%s [%s]", killData.totalKills, killData.totalKills > 1 and "s" or "", killTier.name), r, g, b)

                                        -- Show progress to next tier
                                        if nextKillTier then
                                            local needed = nextKillTier.kills - killData.totalKills
                                            GameTooltip:AddLine(string.format("%d more for %s", needed, nextKillTier.name), 0.6, 0.6, 0.6)
                                        end
                                    else
                                        GameTooltip:AddLine(string.format("Defeated %d time%s", killData.totalKills, killData.totalKills > 1 and "s" or ""), 0.2, 0.8, 0.2)
                                    end
                                end

                                GameTooltip:Show()

                                -- Hover border effect
                                local goldColor = HopeAddon:GetSafeColor("GOLD_BRIGHT")
                                if goldColor then
                                    self:SetBackdropBorderColor(goldColor.r, goldColor.g, goldColor.b, 1)
                                end
                            end)

                            card:SetScript("OnLeave", function(self)
                                GameTooltip:Hide()
                                -- Restore original border color
                                if self.defaultBorderColor then
                                    self:SetBackdropBorderColor(unpack(self.defaultBorderColor))
                                else
                                    self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                                end
                            end)

                            if isKilled then
                                -- Apply kill tier colors based on kill count
                                local Constants = HopeAddon.Constants
                                local killTierData = Constants and Constants.GetBossTier and Constants:GetBossTier(killData.totalKills)
                                local borderR, borderG, borderB = 0.2, 0.8, 0.2  -- Default green

                                if killTierData and killTierData.colorHex then
                                    -- Convert hex to RGB
                                    local hex = killTierData.colorHex
                                    borderR = tonumber(hex:sub(1, 2), 16) / 255
                                    borderG = tonumber(hex:sub(3, 4), 16) / 255
                                    borderB = tonumber(hex:sub(5, 6), 16) / 255
                                end

                                card:SetBackdropBorderColor(borderR, borderG, borderB, 1)
                                card.defaultBorderColor = { borderR, borderG, borderB, 1 }

                                if boss.finalBoss then
                                    card._glowEffect = HopeAddon.Effects:CreatePulsingGlow(card, "GOLD_BRIGHT", 0.3)
                                end
                            else
                                -- Unkilled boss: grey border, reduced alpha
                                card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                                card.defaultBorderColor = { 0.4, 0.4, 0.4, 1 }
                                card:SetAlpha(0.6)
                            end
                            raidSection:AddChild(card)
                        end
                    end

                    scrollContainer:AddEntry(raidSection)

                    -- Small spacer between raids
                    local raidSpacer = self:CreateSpacer(8)
                    scrollContainer:AddEntry(raidSpacer)
                end -- end if raidSection
            end -- end if raid
        end -- end for raidKey

        -- Spacer between tiers
        local tierSpacer = self:CreateSpacer(15)
        scrollContainer:AddEntry(tierSpacer)
    end
end

--============================================================
-- GAMES TAB - Minigames and Challenges
--============================================================
function Journal:PopulateGames()
    local Components = HopeAddon.Components
    local Constants = HopeAddon.Constants
    local scrollContainer = self.mainFrame.scrollContainer

    -- Header
    local header = self:CreateSectionHeader("GAMES HALL", "ARCANE_PURPLE", "Challenge fellow travelers to minigames")
    scrollContainer:AddEntry(header)

    -- Instructions text
    local instructionsContainer = self:AcquireContainer(scrollContainer.content, 40)
    local instructionsText = instructionsContainer.headerText
    if not instructionsText then
        instructionsText = instructionsContainer:CreateFontString(nil, "OVERLAY")
        instructionsContainer.headerText = instructionsText
    end
    instructionsText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    instructionsText:ClearAllPoints()
    instructionsText:SetPoint("TOPLEFT", instructionsContainer, "TOPLEFT", Components.MARGIN_NORMAL, -8)
    instructionsText:SetText("|cFF9B30FFPractice|r solo or |cFF00FF00Challenge|r a Fellow Traveler to compete!")
    instructionsText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    scrollContainer:AddEntry(instructionsContainer)

    -- Create game cards container (not collapsible - full tab content)
    local gamesContainer = self:AcquireContainer(scrollContainer.content, 250)
    scrollContainer:AddEntry(gamesContainer)

    -- Create game cards in a 2-column grid (vertical stack)
    local CARD_WIDTH = 230
    local CARD_SPACING = 12
    local CARDS_PER_ROW = 2
    local ROW_HEIGHT = 120  -- Card height + spacing
    local GRID_LEFT_MARGIN = 7  -- Center the grid in container

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

    -- Get active Words games count
    local wordsActiveCount = 0
    local WordsPersistence = HopeAddon:GetModule("WordGamePersistence")
    if WordsPersistence then
        wordsActiveCount = WordsPersistence:GetGameCount()
    end

    -- Create cards for each game
    for i, gameData in ipairs(games) do
        local card = self:AcquireGameCard(
            gamesContainer,
            gameData,
            onPracticeClick,
            onChallengeClick
        )

        -- Position in grid (2 columns)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", gamesContainer, "TOPLEFT",
            GRID_LEFT_MARGIN + col * (CARD_WIDTH + CARD_SPACING),
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

        -- Show active games badge for Words
        if gameData.id == "words" and card.SetActiveGames then
            card:SetActiveGames(wordsActiveCount)
        end
    end

    -- Update container height based on grid
    local totalRows = math.ceil(#games / CARDS_PER_ROW)
    gamesContainer:SetHeight(totalRows * ROW_HEIGHT + 10)
end

--============================================================
-- SOCIAL TAB - Fellow Travelers Directory
--============================================================

--[[
    Get Fellow Travelers who have "Looking for RP" status
    Filters by:
    - Has LF_RP status
    - Seen within last 24 hours (recent)
    @return table - Array of fellow data with name, zone, class, level
]]
function Journal:GetLookingForRPFellows()
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers then return {} end

    local fellows = HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.fellows or {}
    local result = {}
    local now = time()
    local DAY_SECONDS = 86400  -- 24 hours

    for name, data in pairs(fellows) do
        -- Check if they have LF_RP status
        local status = data.profile and data.profile.status
        if status == "LF_RP" then
            -- Check if seen recently (within 24 hours)
            local lastSeenTime = data.lastSeenTime or 0
            if (now - lastSeenTime) < DAY_SECONDS then
                table.insert(result, {
                    name = name,
                    class = data.class,
                    level = data.level,
                    zone = data.lastSeenZone or "Unknown",
                    lastSeenTime = lastSeenTime,
                    selectedTitle = data.selectedTitle,
                    selectedColor = data.selectedColor,
                })
            end
        end
    end

    -- Sort by most recently seen
    table.sort(result, function(a, b)
        return (a.lastSeenTime or 0) > (b.lastSeenTime or 0)
    end)

    return result
end

--[[
    Create the "Looking for RP" board - a pink-bordered section showing
    Fellows who are actively seeking roleplay
    @param parent Frame - Parent frame
    @param fellows table - Array of fellow data
    @return Frame - The LF_RP board container
]]
function Journal:CreateLookingForRPBoard(parent, fellows)
    local Components = HopeAddon.Components
    local Badges = HopeAddon.Badges
    local Directory = HopeAddon.Directory

    -- Main container with hot pink border (LF_RP color)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local contentHeight = 50 + (#fellows * 45)  -- Header + rows
    container:SetSize(parent:GetWidth() - 20, math.min(contentHeight, 250))  -- Max height cap
    container._componentType = "lfRPBoard"

    -- Apply backdrop with hot pink border
    container:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    container:SetBackdropBorderColor(1, 0.2, 0.8, 1)  -- Hot pink

    -- Add subtle pink glow
    local glowColor = { r = 1, g = 0.2, b = 0.8 }
    if HopeAddon.Effects and HopeAddon.Effects.CreateBorderGlow then
        container._glowEffect = HopeAddon.Effects:CreateBorderGlow(container, nil, glowColor)
    end

    -- Header with icon
    local headerIcon = container:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(20, 20)
    headerIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerIcon:SetTexture("Interface\\Icons\\INV_Valentineperfumebottle")  -- Heart/perfume icon

    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    headerText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerText:SetText("|cFFFF33CCLOOKING FOR RP|r")

    -- Count badge
    local countBadge = container:CreateFontString(nil, "OVERLAY")
    countBadge:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    countBadge:SetPoint("LEFT", headerText, "RIGHT", 8, 0)
    countBadge:SetText("|cFFFFFFFF(" .. #fellows .. " available)|r")

    -- Divider
    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetSize(container:GetWidth() - 24, 1)
    divider:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -38)
    divider:SetColorTexture(1, 0.2, 0.8, 0.4)

    -- Create rows for each LF_RP fellow
    local yOffset = -48
    for i, fellow in ipairs(fellows) do
        if yOffset > -230 then  -- Don't exceed container
            local row = self:CreateLFRPRow(container, fellow, yOffset)
            yOffset = yOffset - 45
        end
    end

    -- "More..." indicator if truncated
    if #fellows > 4 then
        local moreText = container:CreateFontString(nil, "OVERLAY")
        moreText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        moreText:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -12, 8)
        moreText:SetText("|cFF808080+" .. (#fellows - 4) .. " more...|r")
    end

    return container
end

--[[
    Create a single row in the LF_RP board
    @param parent Frame - Parent container
    @param fellow table - Fellow data
    @param yOffset number - Y offset from top
    @return Frame - Row frame
]]
function Journal:CreateLFRPRow(parent, fellow, yOffset)
    local Badges = HopeAddon.Badges
    local Directory = HopeAddon.Directory

    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 24, 40)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(28, 28)
    classIcon:SetPoint("LEFT", row, "LEFT", 0, 0)
    local iconPath = Directory and Directory:GetClassIcon(fellow.class) or "Interface\\Icons\\INV_Misc_QuestionMark"
    classIcon:SetTexture(iconPath)

    -- Name with title
    local classColor = fellow.class and HopeAddon:GetClassColor(fellow.class) or { r = 0.7, g = 0.7, b = 0.7 }
    local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
    local displayName = "|cFF" .. colorHex .. fellow.name .. "|r"
    if fellow.selectedTitle and fellow.selectedTitle ~= "" then
        local titleColor = Badges and Badges:GetTitleColor(fellow.selectedTitle) or "FFD700"
        displayName = displayName .. " |cFF" .. titleColor .. "<" .. fellow.selectedTitle .. ">|r"
    end

    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    nameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 8, -2)
    nameText:SetText(displayName)

    -- Zone and time
    local zoneText = row:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    zoneText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    local timeAgo = self:FormatTimeAgo(fellow.lastSeenTime)
    zoneText:SetText("|cFF808080" .. fellow.zone .. " - " .. timeAgo .. "|r")

    -- Whisper button
    local whisperBtn = CreateFrame("Button", nil, row)
    whisperBtn:SetSize(60, 22)
    whisperBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    local btnBg = whisperBtn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(0.3, 0.15, 0.4, 0.8)
    whisperBtn.bg = btnBg

    local btnText = whisperBtn:CreateFontString(nil, "OVERLAY")
    btnText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    btnText:SetPoint("CENTER")
    btnText:SetText("|cFFFF33CCWhisper|r")

    whisperBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.5, 0.2, 0.6, 0.9)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Whisper " .. fellow.name, 1, 0.2, 0.8)
        GameTooltip:AddLine("Start a conversation about RP!", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    whisperBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.3, 0.15, 0.4, 0.8)
        GameTooltip:Hide()
    end)
    whisperBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        -- Open whisper to this player
        ChatFrame_OpenChat("/w " .. fellow.name .. " ")
    end)

    return row
end

--[[
    Format time since last seen into human-readable string
    @param timestamp number - Unix timestamp
    @return string - Formatted time ago string
]]
function Journal:FormatTimeAgo(timestamp)
    if not timestamp or timestamp == 0 then return "unknown" end

    local now = time()
    local diff = now - timestamp

    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        return mins .. " min ago"
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return hours .. " hr ago"
    else
        local days = math.floor(diff / 86400)
        return days .. " day ago"
    end
end

--============================================================
-- ACTIVITY FEED (NOTICE BOARD) SECTION
--============================================================

--[[
    Create the "Recent Activity" section - a collapsible section showing
    recent activities from Fellow Travelers (Notice Board theme)
    @param parent Frame - Parent frame
    @return Frame - The activity feed container
]]
function Journal:CreateActivityFeedSection(parent)
    local Components = HopeAddon.Components
    local ActivityFeed = HopeAddon.ActivityFeed

    -- Get recent activities (max 10 for display)
    local activities = ActivityFeed and ActivityFeed:GetRecentFeed(10) or {}

    -- Main container with arcane purple border (social feature color)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local contentHeight = #activities > 0 and (50 + (#activities * 50)) or 100
    container:SetSize(parent:GetWidth() - 20, math.min(contentHeight, 350))
    container._componentType = "activityFeed"

    -- Apply backdrop with arcane purple border
    container:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    local purpleColor = HopeAddon.colors.ARCANE_PURPLE
    container:SetBackdropBorderColor(purpleColor.r, purpleColor.g, purpleColor.b, 1)

    -- Header with scroll icon
    local headerIcon = container:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(20, 20)
    headerIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerIcon:SetTexture("Interface\\Icons\\INV_Scroll_03")  -- Scroll icon

    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    headerText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerText:SetText(HopeAddon:ColorText("RECENT ACTIVITY", "ARCANE_PURPLE"))

    -- Count badge
    local countBadge = container:CreateFontString(nil, "OVERLAY")
    countBadge:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    countBadge:SetPoint("LEFT", headerText, "RIGHT", 8, 0)
    if #activities > 0 then
        countBadge:SetText("|cFFFFFFFF(" .. #activities .. " recent)|r")
    else
        countBadge:SetText("|cFF808080(none)|r")
    end

    -- Post Rumor button (top right of header)
    local postBtn = CreateFrame("Button", nil, container)
    postBtn:SetSize(60, 22)
    postBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -12, -8)

    local postBtnBg = postBtn:CreateTexture(nil, "BACKGROUND")
    postBtnBg:SetAllPoints()
    postBtnBg:SetColorTexture(0.4, 0.2, 0.6, 0.8)
    postBtn.bg = postBtnBg

    local postBtnText = postBtn:CreateFontString(nil, "OVERLAY")
    postBtnText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    postBtnText:SetPoint("CENTER")
    postBtnText:SetText("|cFFFFFFFF+ Post|r")

    postBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.5, 0.3, 0.7, 0.9)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Post a Rumor", 0.8, 0.4, 1)
        local canPost, remaining = ActivityFeed:CanPostRumor()
        if canPost then
            GameTooltip:AddLine("Share what's on your mind!", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine("Cooldown: " .. remaining .. "s", 1, 0.3, 0.3)
        end
        GameTooltip:Show()
    end)
    postBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.4, 0.2, 0.6, 0.8)
        GameTooltip:Hide()
    end)
    postBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        Journal:ShowRumorInput(container)
    end)

    -- Divider
    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetSize(container:GetWidth() - 24, 1)
    divider:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -38)
    divider:SetColorTexture(purpleColor.r, purpleColor.g, purpleColor.b, 0.4)

    if #activities == 0 then
        -- Empty state
        local emptyText = container:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(HopeAddon.assets.fonts.BODY, 12)
        emptyText:SetPoint("CENTER", container, "CENTER", 0, -10)
        emptyText:SetText("|cFF808080No recent activity from Fellow Travelers.\n\nEvents will appear here as Fellows level up,\ndefeat bosses, earn badges, and change status!|r")
        emptyText:SetJustifyH("CENTER")
    else
        -- Create activity rows
        local yOffset = -48
        for i, activity in ipairs(activities) do
            if yOffset > -330 then
                local row = self:CreateActivityRow(container, activity, yOffset)
                yOffset = yOffset - 50
            end
        end

        -- "More..." indicator if truncated
        if #activities > 6 then
            local moreText = container:CreateFontString(nil, "OVERLAY")
            moreText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
            moreText:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -12, 8)
            moreText:SetText("|cFF808080+" .. (#activities - 6) .. " more...|r")
        end
    end

    return container
end

--[[
    Create a single activity row in the feed
    @param parent Frame - Parent container
    @param activity table - Activity data { type, player, class, data, time }
    @param yOffset number - Y offset from top
    @return Frame - Row frame
]]
function Journal:CreateActivityRow(parent, activity, yOffset)
    local ActivityFeed = HopeAddon.ActivityFeed
    local Directory = HopeAddon.Directory
    local Badges = HopeAddon.Badges

    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 24, 45)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)

    -- Activity type icon
    local typeIcon = row:CreateTexture(nil, "ARTWORK")
    typeIcon:SetSize(28, 28)
    typeIcon:SetPoint("LEFT", row, "LEFT", 0, 0)
    local iconPath = ActivityFeed and ActivityFeed:GetActivityIcon(activity.type) or "Interface\\Icons\\INV_Misc_QuestionMark"
    typeIcon:SetTexture(iconPath)

    -- Class-colored player name
    local classColor = activity.class and HopeAddon:GetClassColor(activity.class) or { r = 0.7, g = 0.7, b = 0.7 }

    -- Activity description
    local descText = row:CreateFontString(nil, "OVERLAY")
    descText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    descText:SetPoint("TOPLEFT", typeIcon, "TOPRIGHT", 8, -2)
    descText:SetWidth(parent:GetWidth() - 120)  -- Leave room for time
    descText:SetWordWrap(true)

    local formattedText = ActivityFeed and ActivityFeed:FormatActivity(activity) or (activity.player .. ": " .. (activity.data or ""))
    descText:SetText(formattedText)

    -- Time ago (top right)
    local timeText = row:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    timeText:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -2)

    local timeAgo = ActivityFeed and ActivityFeed:GetRelativeTime(activity.time) or "?"
    timeText:SetText("|cFF808080" .. timeAgo .. "|r")

    -- Mug button (Phase 2 - interactive)
    local mugBtn = CreateFrame("Button", nil, row)
    mugBtn:SetSize(36, 20)
    mugBtn:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 5)

    local mugIcon = mugBtn:CreateTexture(nil, "ARTWORK")
    mugIcon:SetSize(16, 16)
    mugIcon:SetPoint("LEFT", mugBtn, "LEFT", 0, 0)
    mugIcon:SetTexture("Interface\\Icons\\INV_Drink_10")

    local mugCountText = mugBtn:CreateFontString(nil, "OVERLAY")
    mugCountText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    mugCountText:SetPoint("LEFT", mugIcon, "RIGHT", 2, 0)
    local count = activity.mugs or 0
    mugCountText:SetText(count > 0 and ("|cFFFFD700" .. count .. "|r") or "")

    local hasMugged = ActivityFeed and ActivityFeed:HasMugged(activity.id)
    if hasMugged then
        mugIcon:SetVertexColor(1, 0.84, 0)  -- Gold tint (already mugged)
    else
        mugIcon:SetVertexColor(0.6, 0.6, 0.6)  -- Grey (can mug)
    end

    mugBtn:SetScript("OnClick", function()
        if not hasMugged and ActivityFeed then
            if ActivityFeed:GiveMug(activity.id) then
                mugIcon:SetVertexColor(1, 0.84, 0)
                local newCount = activity.mugs or 0
                mugCountText:SetText("|cFFFFD700" .. newCount .. "|r")
                hasMugged = true  -- Update local state
            end
        end
    end)
    mugBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Raise a Mug!", 1, 0.84, 0)
        if hasMugged then
            GameTooltip:AddLine("You've already cheered this!", 0.5, 0.5, 0.5)
        else
            GameTooltip:AddLine("Click to show appreciation", 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)
    mugBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Subtle separator line
    local separator = row:CreateTexture(nil, "BACKGROUND")
    separator:SetSize(row:GetWidth(), 1)
    separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    separator:SetColorTexture(0.3, 0.3, 0.3, 0.3)

    return row
end

--[[
    Create "Your Profile" section with golden glow container
    Contains: player name/title, title dropdown, RP status dropdown, edit profile button
]]
function Journal:CreateMyProfileSection(parent)
    local Components = HopeAddon.Components
    local Badges = HopeAddon.Badges
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    local Effects = HopeAddon.Effects

    local profile = HopeAddon.charDb.travelers.myProfile or {}
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    local classColor = HopeAddon:GetClassColor(playerClass)

    -- Container frame with backdrop
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(parent:GetWidth() - 20, 160)
    container._componentType = "profile"

    -- Apply dark parchment backdrop with golden border
    container:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    local gold = HopeAddon.colors.GOLD_BRIGHT
    container:SetBackdropBorderColor(gold.r, gold.g, gold.b, 1)

    -- Add static golden glow effect around the container
    if Effects and Effects.CreateBorderGlow then
        container._glowEffect = Effects:CreateBorderGlow(container, "GOLD_BRIGHT")
    end

    -- Header row: "YOUR PROFILE" title + Edit Profile button
    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    headerText:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerText:SetText("|cFFFFD700YOUR PROFILE|r")

    -- Edit Profile button (top right)
    local editBtn = CreateFrame("Button", nil, container)
    editBtn:SetSize(90, 22)
    editBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -8)

    local editBtnBg = editBtn:CreateTexture(nil, "BACKGROUND")
    editBtnBg:SetAllPoints()
    editBtnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    local editBtnText = editBtn:CreateFontString(nil, "OVERLAY")
    editBtnText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    editBtnText:SetPoint("CENTER")
    editBtnText:SetText("Edit Profile")
    editBtnText:SetTextColor(1, 0.82, 0, 1)

    editBtn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        local ProfileEditor = HopeAddon:GetModule("ProfileEditor")
        if ProfileEditor then
            ProfileEditor:Show()
        end
    end)
    editBtn:SetScript("OnEnter", function(self)
        editBtnBg:SetColorTexture(0.3, 0.3, 0.3, 0.9)
    end)
    editBtn:SetScript("OnLeave", function(self)
        editBtnBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    end)

    -- Divider line
    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetSize(container:GetWidth() - 24, 1)
    divider:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -30)
    divider:SetColorTexture(0.6, 0.5, 0.3, 0.5)

    -- Class icon
    local classIcon = container:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(40, 40)
    classIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -40)
    local iconPath = HopeAddon.Directory and HopeAddon.Directory:GetClassIcon(playerClass) or "Interface\\Icons\\INV_Misc_QuestionMark"
    classIcon:SetTexture(iconPath)

    -- Player name + title
    local selectedTitle = Badges and Badges:GetSelectedTitle() or nil
    local displayName = playerName
    if selectedTitle and selectedTitle ~= "" then
        local titleColor = Badges:GetTitleColor(selectedTitle)
        displayName = string.format("%s |cFF%s<%s>|r", playerName, titleColor, selectedTitle)
    end

    local nameText = container:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.TITLE, 16)
    nameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 10, -2)
    nameText:SetText(displayName)
    container.nameText = nameText  -- Store reference for updates

    -- Class/Level info
    local levelText = container:CreateFontString(nil, "OVERLAY")
    levelText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    levelText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    local colorHex = classColor and string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or "FFFFFF"
    levelText:SetText(string.format("Level %d |cFF%s%s|r", UnitLevel("player"), colorHex, playerClass or "Unknown"))
    levelText:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Title dropdown label
    local titleLabel = container:CreateFontString(nil, "OVERLAY")
    titleLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    titleLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -95)
    titleLabel:SetText("Title:")
    titleLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Title dropdown
    local titleDropdown = CreateFrame("Frame", "HopeAddonSocialTitleDropdown" .. GetTime(), container, "UIDropDownMenuTemplate")
    titleDropdown:SetPoint("LEFT", titleLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(titleDropdown, 140)

    local function InitializeTitleDropdown()
        local titles = Badges and Badges:GetUnlockedTitles() or {}
        local currentTitle = profile.selectedTitle

        UIDropDownMenu_Initialize(titleDropdown, function(self, level)
            -- "None" option
            local noneInfo = UIDropDownMenu_CreateInfo()
            noneInfo.text = "|cFF808080(None)|r"
            noneInfo.value = ""
            noneInfo.func = function()
                profile.selectedTitle = nil
                UIDropDownMenu_SetText(titleDropdown, "|cFF808080(None)|r")
                -- Update name display
                nameText:SetText(playerName)
            end
            UIDropDownMenu_AddButton(noneInfo, level)

            -- Unlocked titles
            for _, titleData in ipairs(titles) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = "|cFF" .. titleData.colorHex .. titleData.title .. "|r"
                info.value = titleData.title
                info.func = function()
                    profile.selectedTitle = titleData.title
                    UIDropDownMenu_SetText(titleDropdown, "|cFF" .. titleData.colorHex .. titleData.title .. "|r")
                    -- Update name display
                    nameText:SetText(string.format("%s |cFF%s<%s>|r", playerName, titleData.colorHex, titleData.title))
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Set current value
        if currentTitle and currentTitle ~= "" then
            local titleColor = Badges and Badges:GetTitleColor(currentTitle) or "FFFFFF"
            UIDropDownMenu_SetText(titleDropdown, "|cFF" .. titleColor .. currentTitle .. "|r")
        else
            UIDropDownMenu_SetText(titleDropdown, "|cFF808080(None)|r")
        end
    end
    InitializeTitleDropdown()

    -- RP Status dropdown label
    local statusLabel = container:CreateFontString(nil, "OVERLAY")
    statusLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    statusLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -125)
    statusLabel:SetText("RP Status:")
    statusLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- RP Status dropdown
    local statusDropdown = CreateFrame("Frame", "HopeAddonSocialStatusDropdown" .. GetTime(), container, "UIDropDownMenuTemplate")
    statusDropdown:SetPoint("LEFT", statusLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(statusDropdown, 140)

    local function InitializeStatusDropdown()
        local options = FellowTravelers and FellowTravelers.STATUS_OPTIONS or {}
        local currentStatus = profile.status or "OOC"

        UIDropDownMenu_Initialize(statusDropdown, function(self, level)
            for _, opt in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = "|cFF" .. opt.color .. opt.label .. "|r"
                info.value = opt.id
                info.func = function()
                    profile.status = opt.id
                    UIDropDownMenu_SetText(statusDropdown, "|cFF" .. opt.color .. opt.label .. "|r")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)

        -- Set current value
        for _, opt in ipairs(options) do
            if opt.id == currentStatus then
                UIDropDownMenu_SetText(statusDropdown, "|cFF" .. opt.color .. opt.label .. "|r")
                break
            end
        end
    end
    InitializeStatusDropdown()

    return container
end

-- Social tab state (persists between refreshes)
Journal.socialState = {
    searchText = "",
    sortOption = "last_seen",
    filterOption = "all",  -- "all", "online", "ic", "ooc", "lfrp"
    currentPage = 1,
    pageSize = 20,  -- Show 20 at a time for performance
}
Journal.searchDebounceTimer = nil  -- Timer handle for search debouncing

--[[
    Create search/filter toolbar for Fellow Travelers list
    @param parent Frame - Parent frame
    @return Frame - Toolbar frame
]]
function Journal:CreateSocialToolbar(parent)
    local Components = HopeAddon.Components
    local Directory = HopeAddon.Directory

    local toolbar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    toolbar:SetSize(parent:GetWidth() - 20, 70)
    toolbar._componentType = "toolbar"

    -- Apply subtle backdrop
    toolbar:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    toolbar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    toolbar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

    -- Row 1: Search box + Sort dropdown
    local searchIcon = toolbar:CreateTexture(nil, "ARTWORK")
    searchIcon:SetSize(16, 16)
    searchIcon:SetPoint("TOPLEFT", toolbar, "TOPLEFT", 12, -10)
    searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")

    local searchBox = CreateFrame("EditBox", nil, toolbar, "BackdropTemplate")
    searchBox:SetSize(180, 22)
    searchBox:SetPoint("LEFT", searchIcon, "RIGHT", 4, 0)
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    searchBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    searchBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)
    searchBox:SetFont(HopeAddon.assets.fonts.BODY, 11)
    searchBox:SetTextColor(1, 1, 1, 1)
    searchBox:SetAutoFocus(false)
    searchBox:SetText(self.socialState.searchText)
    searchBox:SetTextInsets(8, 8, 0, 0)
    toolbar.searchBox = searchBox

    local placeholder = searchBox:CreateFontString(nil, "OVERLAY")
    placeholder:SetFont(HopeAddon.assets.fonts.BODY, 11)
    placeholder:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
    placeholder:SetText("|cFF808080Search name, class, zone...|r")
    placeholder:SetJustifyH("LEFT")
    placeholder:SetShown(self.socialState.searchText == "")
    searchBox.placeholder = placeholder

    searchBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            local text = self:GetText()
            Journal.socialState.searchText = text
            Journal.socialState.currentPage = 1
            self.placeholder:SetShown(text == "")
            if Directory then Directory.searchFilter = text end
            -- Cancel previous timer to prevent stacking
            if Journal.searchDebounceTimer then
                Journal.searchDebounceTimer:Cancel()
            end
            Journal.searchDebounceTimer = HopeAddon.Timer:After(0.3, function()
                Journal:RefreshSocialList()
                Journal.searchDebounceTimer = nil
            end)
        end
    end)
    searchBox:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(1, 0.84, 0, 0.8) end)
    searchBox:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6) end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    -- Allow movement keys to pass through to game while typing
    searchBox:SetScript("OnKeyDown", function(self, key)
        self:SetPropagateKeyboardInput(true)
    end)

    local sortLabel = toolbar:CreateFontString(nil, "OVERLAY")
    sortLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    sortLabel:SetPoint("LEFT", searchBox, "RIGHT", 15, 0)
    sortLabel:SetText("Sort:")
    sortLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    local sortDropdown = CreateFrame("Frame", "HopeAddonSocialSortDropdown" .. GetTime(), toolbar, "UIDropDownMenuTemplate")
    sortDropdown:SetPoint("LEFT", sortLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(sortDropdown, 100)
    toolbar.sortDropdown = sortDropdown

    UIDropDownMenu_Initialize(sortDropdown, function(self, level)
        local sortOptions = Directory and Directory.SORT_OPTIONS or {}
        for _, opt in ipairs(sortOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.label
            info.value = opt.id
            info.func = function()
                Journal.socialState.sortOption = opt.id
                Journal.socialState.currentPage = 1
                if Directory then Directory.currentSort = opt.id end
                UIDropDownMenu_SetText(sortDropdown, opt.label)
                Journal:RefreshSocialList()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local currentSortLabel = "Last Seen"
    if Directory then
        for _, opt in ipairs(Directory.SORT_OPTIONS) do
            if opt.id == self.socialState.sortOption then
                currentSortLabel = opt.label
                break
            end
        end
    end
    UIDropDownMenu_SetText(sortDropdown, currentSortLabel)

    -- Row 2: Filter buttons
    local filterY = -42
    local filterX = 12
    local filters = {
        { id = "all", label = "All", color = { 0.5, 0.5, 0.5 } },
        { id = "online", label = "Online", color = { 0.2, 1, 0.2 } },
        { id = "ic", label = "IC", color = { 0.2, 1, 0.2 } },
        { id = "ooc", label = "OOC", color = { 0, 0.75, 1 } },
        { id = "lfrp", label = "LF_RP", color = { 1, 0.2, 0.8 } },
    }

    toolbar.filterButtons = {}
    for i, filter in ipairs(filters) do
        local btn = CreateFrame("Button", nil, toolbar)
        btn:SetSize(50, 20)
        btn:SetPoint("TOPLEFT", toolbar, "TOPLEFT", filterX, filterY)
        filterX = filterX + 55

        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btn.bg = btnBg

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        btnText:SetPoint("CENTER")
        btnText:SetText(filter.label)
        btn.text = btnText

        local isActive = self.socialState.filterOption == filter.id
        if isActive then
            btnBg:SetColorTexture(filter.color[1], filter.color[2], filter.color[3], 0.6)
            btnText:SetTextColor(1, 1, 1, 1)
        else
            btnBg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            btnText:SetTextColor(0.6, 0.6, 0.6, 1)
        end

        btn.filterId = filter.id
        btn.filterColor = filter.color

        btn:SetScript("OnClick", function(self)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            Journal.socialState.filterOption = self.filterId
            Journal.socialState.currentPage = 1
            for _, b in ipairs(toolbar.filterButtons) do
                local active = Journal.socialState.filterOption == b.filterId
                if active then
                    b.bg:SetColorTexture(b.filterColor[1], b.filterColor[2], b.filterColor[3], 0.6)
                    b.text:SetTextColor(1, 1, 1, 1)
                else
                    b.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                    b.text:SetTextColor(0.6, 0.6, 0.6, 1)
                end
            end
            Journal:RefreshSocialList()
        end)

        btn:SetScript("OnEnter", function(self) self.bg:SetColorTexture(self.filterColor[1], self.filterColor[2], self.filterColor[3], 0.4) end)
        btn:SetScript("OnLeave", function(self)
            local active = Journal.socialState.filterOption == self.filterId
            if active then
                self.bg:SetColorTexture(self.filterColor[1], self.filterColor[2], self.filterColor[3], 0.6)
            else
                self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            end
        end)

        table.insert(toolbar.filterButtons, btn)
    end

    local resultsText = toolbar:CreateFontString(nil, "OVERLAY")
    resultsText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    resultsText:SetPoint("TOPRIGHT", toolbar, "TOPRIGHT", -12, filterY - 4)
    resultsText:SetText("")
    resultsText:SetTextColor(0.6, 0.6, 0.6, 1)
    toolbar.resultsText = resultsText

    return toolbar
end

--[[
    Get filtered entries based on current social state
    @return table - Filtered entries
]]
function Journal:GetFilteredSocialEntries()
    local Directory = HopeAddon.Directory
    if not Directory then return {} end

    local entries = Directory:GetFilteredEntries(self.socialState.searchText, self.socialState.sortOption)

    local filterOption = self.socialState.filterOption
    if filterOption ~= "all" then
        local filtered = {}
        local now = time()
        local ONLINE_THRESHOLD = 300

        for _, entry in ipairs(entries) do
            local status = entry.profile and entry.profile.status or "OOC"
            local lastSeenTime = entry.lastSeenTime or 0
            local isOnline = (now - lastSeenTime) < ONLINE_THRESHOLD

            if filterOption == "online" and isOnline then
                table.insert(filtered, entry)
            elseif filterOption == "ic" and status == "IC" then
                table.insert(filtered, entry)
            elseif filterOption == "ooc" and status == "OOC" then
                table.insert(filtered, entry)
            elseif filterOption == "lfrp" and status == "LF_RP" then
                table.insert(filtered, entry)
            end
        end
        entries = filtered
    end

    return entries
end

function Journal:RefreshSocialList()
    if self.currentTab == "social" then
        self:PopulateSocial()
    end
end

function Journal:CreatePaginationControls(parent, totalEntries, currentPage, pageSize)
    local totalPages = math.ceil(totalEntries / pageSize)
    if totalPages <= 1 then return nil end

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(parent:GetWidth() - 20, 35)
    container._componentType = "pagination"

    local pageText = container:CreateFontString(nil, "OVERLAY")
    pageText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    pageText:SetPoint("CENTER", container, "CENTER", 0, 0)
    pageText:SetText(string.format("Page %d of %d", currentPage, totalPages))
    pageText:SetTextColor(0.8, 0.8, 0.8, 1)

    if currentPage > 1 then
        local prevBtn = CreateFrame("Button", nil, container)
        prevBtn:SetSize(60, 24)
        prevBtn:SetPoint("RIGHT", pageText, "LEFT", -20, 0)
        local prevBg = prevBtn:CreateTexture(nil, "BACKGROUND")
        prevBg:SetAllPoints()
        prevBg:SetColorTexture(0.3, 0.3, 0.3, 0.6)
        prevBtn.bg = prevBg
        local prevText = prevBtn:CreateFontString(nil, "OVERLAY")
        prevText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        prevText:SetPoint("CENTER")
        prevText:SetText("< Prev")
        prevText:SetTextColor(1, 0.84, 0, 1)
        prevBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self.socialState.currentPage = self.socialState.currentPage - 1
            self:RefreshSocialList()
        end)
        prevBtn:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.4, 0.4, 0.4, 0.8) end)
        prevBtn:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.6) end)
    end

    if currentPage < totalPages then
        local nextBtn = CreateFrame("Button", nil, container)
        nextBtn:SetSize(60, 24)
        nextBtn:SetPoint("LEFT", pageText, "RIGHT", 20, 0)
        local nextBg = nextBtn:CreateTexture(nil, "BACKGROUND")
        nextBg:SetAllPoints()
        nextBg:SetColorTexture(0.3, 0.3, 0.3, 0.6)
        nextBtn.bg = nextBg
        local nextText = nextBtn:CreateFontString(nil, "OVERLAY")
        nextText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        nextText:SetPoint("CENTER")
        nextText:SetText("Next >")
        nextText:SetTextColor(1, 0.84, 0, 1)
        nextBtn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            self.socialState.currentPage = self.socialState.currentPage + 1
            self:RefreshSocialList()
        end)
        nextBtn:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.4, 0.4, 0.4, 0.8) end)
        nextBtn:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.6) end)
    end

    return container
end

--[[
    Create the Companions section (favorites list)
    @param parent Frame
    @return Frame
]]
function Journal:CreateCompanionsSection(parent)
    local Companions = HopeAddon.Companions
    local companions = Companions and Companions:GetAllCompanions() or {}
    local requests = Companions and Companions:GetIncomingRequests() or {}
    local onlineCount = Companions and Companions:GetOnlineCount() or 0
    local totalCount = Companions and Companions:GetCount() or 0

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local hasRequests = #requests > 0
    local contentHeight = 55 + (#companions * 35) + (hasRequests and (#requests * 40 + 10) or 0)
    container:SetSize(parent:GetWidth() - 20, math.max(math.min(contentHeight, 250), 80))
    container._componentType = "companionsSection"

    container:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
    local goldColor = HopeAddon.colors.GOLD_BRIGHT
    container:SetBackdropBorderColor(goldColor.r, goldColor.g, goldColor.b, 1)

    -- Header with friends icon
    local headerIcon = container:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(20, 20)
    headerIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerIcon:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")

    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    headerText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerText:SetText(HopeAddon:ColorText("COMPANIONS", "GOLD_BRIGHT"))

    local countText = container:CreateFontString(nil, "OVERLAY")
    countText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    countText:SetPoint("LEFT", headerText, "RIGHT", 8, 0)
    if totalCount > 0 then
        countText:SetText("|cFF00FF00(" .. onlineCount .. "/" .. totalCount .. " online)|r")
    else
        countText:SetText("|cFF808080(0)|r")
    end

    -- Pending requests badge
    if hasRequests then
        local requestBadge = container:CreateFontString(nil, "OVERLAY")
        requestBadge:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        requestBadge:SetPoint("TOPRIGHT", container, "TOPRIGHT", -12, -12)
        requestBadge:SetText("|cFFFF3333" .. #requests .. " pending|r")
    end

    -- Divider
    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetSize(container:GetWidth() - 24, 1)
    divider:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -38)
    divider:SetColorTexture(goldColor.r, goldColor.g, goldColor.b, 0.4)

    local yOffset = -48

    -- Pending requests section first
    if hasRequests then
        local reqLabel = container:CreateFontString(nil, "OVERLAY")
        reqLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        reqLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 12, yOffset)
        reqLabel:SetText("|cFFFFD700Incoming Requests:|r")
        yOffset = yOffset - 18

        for _, req in ipairs(requests) do
            local reqRow = self:CreateCompanionRequestRow(container, req, yOffset)
            yOffset = yOffset - 38
        end

        yOffset = yOffset - 8
    end

    -- Companion rows
    if #companions == 0 and not hasRequests then
        local emptyText = container:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(HopeAddon.assets.fonts.BODY, 11)
        emptyText:SetPoint("CENTER", container, "CENTER", 0, -10)
        emptyText:SetText("|cFF808080No companions yet.\nAdd Fellows from the directory below!|r")
        emptyText:SetJustifyH("CENTER")
    else
        for _, comp in ipairs(companions) do
            if yOffset > -240 then
                local row = self:CreateCompanionRow(container, comp, yOffset)
                yOffset = yOffset - 32
            end
        end
    end

    return container
end

--[[
    Create a single companion row
    @param parent Frame
    @param comp table - Companion data { name, class, level, isOnline, zone, selectedTitle }
    @param yOffset number
    @return Frame
]]
function Journal:CreateCompanionRow(parent, comp, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 24, 28)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)

    -- Online status dot
    local statusDot = row:CreateTexture(nil, "ARTWORK")
    statusDot:SetSize(10, 10)
    statusDot:SetPoint("LEFT", row, "LEFT", 0, 0)
    statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
    if comp.isOnline then
        statusDot:SetVertexColor(0, 1, 0)  -- Green = online
    else
        statusDot:SetVertexColor(0.5, 0.5, 0.5)  -- Grey = offline
    end

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(18, 18)
    classIcon:SetPoint("LEFT", statusDot, "RIGHT", 6, 0)
    local classPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
    classIcon:SetTexture(classPath)
    local coords = CLASS_ICON_TCOORDS[comp.class]
    if coords then
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name with title
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 6, 0)

    local classColor = HopeAddon:GetClassColor(comp.class) or { r = 0.7, g = 0.7, b = 0.7 }
    local nameStr = string.format("|cFF%02x%02x%02x%s|r",
        classColor.r * 255, classColor.g * 255, classColor.b * 255, comp.name)
    if comp.selectedTitle then
        nameStr = nameStr .. " |cFFFFD700<" .. comp.selectedTitle .. ">|r"
    end
    nameText:SetText(nameStr)

    -- Zone (right side) or "Offline"
    local zoneText = row:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    zoneText:SetPoint("RIGHT", row, "RIGHT", -30, 0)
    if comp.isOnline then
        zoneText:SetText("|cFF00BFFF" .. (comp.zone or "Unknown") .. "|r")
    else
        zoneText:SetText("|cFF606060Offline|r")
    end

    -- Remove button (X)
    local removeBtn = CreateFrame("Button", nil, row)
    removeBtn:SetSize(16, 16)
    removeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    local removeText = removeBtn:CreateFontString(nil, "OVERLAY")
    removeText:SetFont(HopeAddon.assets.fonts.SMALL, 12)
    removeText:SetPoint("CENTER")
    removeText:SetText("|cFF606060×|r")

    removeBtn:SetScript("OnEnter", function()
        removeText:SetText("|cFFFF3333×|r")
        GameTooltip:SetOwner(removeBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Remove Companion", 1, 0.3, 0.3)
        GameTooltip:Show()
    end)
    removeBtn:SetScript("OnLeave", function()
        removeText:SetText("|cFF606060×|r")
        GameTooltip:Hide()
    end)
    removeBtn:SetScript("OnClick", function()
        if HopeAddon.Companions then
            HopeAddon.Companions:RemoveCompanion(comp.name)
            Journal:RefreshSocialList()
        end
    end)

    return row
end

--[[
    Create a companion request row (pending incoming)
    @param parent Frame
    @param req table - Request data { name, class, level, timestamp }
    @param yOffset number
    @return Frame
]]
function Journal:CreateCompanionRequestRow(parent, req, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 24, 32)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(18, 18)
    classIcon:SetPoint("LEFT", row, "LEFT", 0, 0)
    local classPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
    classIcon:SetTexture(classPath)
    local coords = CLASS_ICON_TCOORDS[req.class]
    if coords then
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 6, 0)

    local classColor = HopeAddon:GetClassColor(req.class) or { r = 0.7, g = 0.7, b = 0.7 }
    nameText:SetText(string.format("|cFF%02x%02x%02x%s|r",
        classColor.r * 255, classColor.g * 255, classColor.b * 255, req.name))

    -- Accept button
    local acceptBtn = CreateFrame("Button", nil, row)
    acceptBtn:SetSize(50, 20)
    acceptBtn:SetPoint("RIGHT", row, "RIGHT", -55, 0)

    local acceptBg = acceptBtn:CreateTexture(nil, "BACKGROUND")
    acceptBg:SetAllPoints()
    acceptBg:SetColorTexture(0.2, 0.6, 0.2, 0.8)

    local acceptText = acceptBtn:CreateFontString(nil, "OVERLAY")
    acceptText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    acceptText:SetPoint("CENTER")
    acceptText:SetText("|cFFFFFFFFAccept|r")

    acceptBtn:SetScript("OnEnter", function()
        acceptBg:SetColorTexture(0.3, 0.7, 0.3, 0.9)
    end)
    acceptBtn:SetScript("OnLeave", function()
        acceptBg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
    end)
    acceptBtn:SetScript("OnClick", function()
        if HopeAddon.Companions then
            HopeAddon.Companions:AcceptRequest(req.name)
            Journal:RefreshSocialList()
        end
    end)

    -- Decline button
    local declineBtn = CreateFrame("Button", nil, row)
    declineBtn:SetSize(50, 20)
    declineBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)

    local declineBg = declineBtn:CreateTexture(nil, "BACKGROUND")
    declineBg:SetAllPoints()
    declineBg:SetColorTexture(0.5, 0.2, 0.2, 0.8)

    local declineText = declineBtn:CreateFontString(nil, "OVERLAY")
    declineText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
    declineText:SetPoint("CENTER")
    declineText:SetText("|cFFFFFFFFDecline|r")

    declineBtn:SetScript("OnEnter", function()
        declineBg:SetColorTexture(0.6, 0.3, 0.3, 0.9)
    end)
    declineBtn:SetScript("OnLeave", function()
        declineBg:SetColorTexture(0.5, 0.2, 0.2, 0.8)
    end)
    declineBtn:SetScript("OnClick", function()
        if HopeAddon.Companions then
            HopeAddon.Companions:DeclineRequest(req.name)
            Journal:RefreshSocialList()
        end
    end)

    return row
end

--[[
    Refresh the Social tab (used after posting a rumor)
]]
function Journal:RefreshSocialList()
    -- Re-render the Social tab if it's currently visible
    if self.currentTab == "social" then
        self:PopulateSocial()
    end
end

--[[
    Show inline rumor input box
    @param parent Frame - Parent container (the activity feed section)
]]
function Journal:ShowRumorInput(parent)
    -- Create or show existing input frame
    if not self.rumorInputFrame then
        local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        frame:SetSize(parent:GetWidth() - 24, 60)
        frame:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP)
        frame:SetBackdropBorderColor(0.5, 0.3, 0.7, 1)
        self.rumorInputFrame = frame

        local editBox = CreateFrame("EditBox", nil, frame)
        editBox:SetFont(HopeAddon.assets.fonts.BODY, 12)
        editBox:SetSize(frame:GetWidth() - 90, 20)
        editBox:SetPoint("LEFT", frame, "LEFT", 10, 0)
        editBox:SetMaxLetters(100)
        editBox:SetAutoFocus(true)
        editBox:SetTextInsets(5, 5, 0, 0)
        frame.editBox = editBox

        local bg = editBox:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

        local sendBtn = CreateFrame("Button", nil, frame)
        sendBtn:SetSize(50, 24)
        sendBtn:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        local sendBg = sendBtn:CreateTexture(nil, "BACKGROUND")
        sendBg:SetAllPoints()
        sendBg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
        local sendText = sendBtn:CreateFontString(nil, "OVERLAY")
        sendText:SetFont(HopeAddon.assets.fonts.SMALL, 10)
        sendText:SetPoint("CENTER")
        sendText:SetText("|cFFFFFFFFSend|r")
        frame.sendBtn = sendBtn

        sendBtn:SetScript("OnEnter", function(self)
            sendBg:SetColorTexture(0.3, 0.7, 0.3, 0.9)
        end)
        sendBtn:SetScript("OnLeave", function(self)
            sendBg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
        end)
        sendBtn:SetScript("OnClick", function()
            local text = editBox:GetText()
            if text and text ~= "" and HopeAddon.ActivityFeed then
                if HopeAddon.ActivityFeed:PostRumor(text) then
                    editBox:SetText("")
                    frame:Hide()
                    Journal:RefreshSocialList()
                end
            end
        end)

        editBox:SetScript("OnEnterPressed", function()
            sendBtn:Click()
        end)
        editBox:SetScript("OnEscapePressed", function()
            frame:Hide()
        end)

        -- Placeholder text
        local placeholder = editBox:CreateFontString(nil, "ARTWORK")
        placeholder:SetFont(HopeAddon.assets.fonts.BODY, 12)
        placeholder:SetPoint("LEFT", editBox, "LEFT", 5, 0)
        placeholder:SetText("|cFF808080What's on your mind?|r")
        frame.placeholder = placeholder

        editBox:SetScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                placeholder:Show()
            else
                placeholder:Hide()
            end
        end)
    end

    self.rumorInputFrame:SetParent(parent)
    self.rumorInputFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -45)
    self.rumorInputFrame:Show()
    self.rumorInputFrame.editBox:SetText("")
    self.rumorInputFrame.placeholder:Show()
    self.rumorInputFrame.editBox:SetFocus()
end

function Journal:PopulateSocial()
    local Components = HopeAddon.Components
    local Directory = HopeAddon.Directory
    local scrollContainer = self.mainFrame.scrollContainer

    -- Your Profile section (lit-up container at top)
    local profileSection = self:CreateMyProfileSection(scrollContainer.content)
    scrollContainer:AddEntry(profileSection)

    -- Spacer
    local spacer = Components:CreateSpacer(scrollContainer.content, 15)
    scrollContainer:AddEntry(spacer)

    -- RECENT ACTIVITY section (Notice Board)
    local activitySection = self:CreateActivityFeedSection(scrollContainer.content)
    scrollContainer:AddEntry(activitySection)

    -- Spacer after Activity Feed
    local activitySpacer = Components:CreateSpacer(scrollContainer.content, 15)
    scrollContainer:AddEntry(activitySpacer)

    -- COMPANIONS section (favorites list)
    local companionsSection = self:CreateCompanionsSection(scrollContainer.content)
    scrollContainer:AddEntry(companionsSection)

    -- Spacer after Companions
    local companionsSpacer = Components:CreateSpacer(scrollContainer.content, 15)
    scrollContainer:AddEntry(companionsSpacer)

    -- LOOKING FOR RP board section
    local lfRPFellows = self:GetLookingForRPFellows()
    if #lfRPFellows > 0 then
        local lfRPBoard = self:CreateLookingForRPBoard(scrollContainer.content, lfRPFellows)
        scrollContainer:AddEntry(lfRPBoard)

        -- Spacer after LF_RP board
        local lfRPSpacer = Components:CreateSpacer(scrollContainer.content, 15)
        scrollContainer:AddEntry(lfRPSpacer)
    end

    -- IN YOUR PARTY section (only if party has Fellow Travelers)
    local partyFellows = self:GetPartyFellowTravelers()
    if #partyFellows > 0 then
        -- Party header
        local partyHeader = self:CreateSectionHeader("IN YOUR PARTY", "FEL_GREEN", "Fellow Travelers in your group")
        scrollContainer:AddEntry(partyHeader)

        -- Party member cards with challenge buttons
        for _, fellow in ipairs(partyFellows) do
            local card = self:CreatePartyFellowCard(scrollContainer.content, fellow)
            scrollContainer:AddEntry(card)
        end

        -- Spacer before Fellow Travelers section
        local partySpacer = Components:CreateSpacer(scrollContainer.content, 20)
        scrollContainer:AddEntry(partySpacer)
    end

    -- Fellow Travelers Header
    local header = self:CreateSectionHeader("FELLOW TRAVELERS", "FEL_GREEN", "Addon users you have encountered")
    scrollContainer:AddEntry(header)

    -- Search/Filter/Sort Toolbar
    local toolbar = self:CreateSocialToolbar(scrollContainer.content)
    scrollContainer:AddEntry(toolbar)
    self.socialToolbar = toolbar  -- Store reference for updates

    -- Get filtered entries using social state (search, sort, filter)
    local allEntries = self:GetFilteredSocialEntries()
    local totalEntries = #allEntries

    -- Apply pagination
    local pageSize = self.socialState.pageSize
    local currentPage = self.socialState.currentPage
    local startIdx = (currentPage - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, totalEntries)

    -- Slice entries for current page
    local entries = {}
    for i = startIdx, endIdx do
        if allEntries[i] then
            table.insert(entries, allEntries[i])
        end
    end

    -- Update results count in toolbar
    if toolbar.resultsText then
        local filterText = self.socialState.filterOption ~= "all" and (" (" .. self.socialState.filterOption:upper() .. ")") or ""
        toolbar.resultsText:SetText(string.format("%d travelers%s", totalEntries, filterText))
    end

    if totalEntries == 0 then
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

        -- Different message based on whether filters are active
        local hasFilter = self.socialState.searchText ~= "" or self.socialState.filterOption ~= "all"
        if hasFilter then
            placeholder:SetText("No fellow travelers match your filters.\n\nTry adjusting your search or filters.")
        else
            placeholder:SetText("No fellow travelers found yet...\n\nGroup up with other HopeAddon users\nto discover them automatically!")
        end
        placeholder:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
        placeholder:SetJustifyH("CENTER")
        scrollContainer:AddEntry(placeholderFrame)
    else
        -- Create cards for each entry on this page
        for _, entry in ipairs(entries) do
            local card = self:CreateDirectoryCard(entry)
            scrollContainer:AddEntry(card)
        end

        -- Pagination controls (if more than one page)
        local paginationControls = self:CreatePaginationControls(scrollContainer.content, totalEntries, currentPage, pageSize)
        if paginationControls then
            local paginationSpacer = Components:CreateSpacer(scrollContainer.content, 10)
            scrollContainer:AddEntry(paginationSpacer)
            scrollContainer:AddEntry(paginationControls)
        end
    end
end

--[[
    Get party members who are Fellow Travelers (addon users)
    @return table - Array of party fellow data
]]
function Journal:GetPartyFellowTravelers()
    local FellowTravelers = HopeAddon:GetModule("FellowTravelers")
    if not FellowTravelers then return {} end

    local partyMembers = FellowTravelers:GetPartyMembers()
    local partyFellows = {}

    for _, member in ipairs(partyMembers) do
        if FellowTravelers:IsFellow(member.name) then
            local fellowData = FellowTravelers:GetFellow(member.name)
            table.insert(partyFellows, {
                name = member.name,
                class = member.class,
                level = member.level,
                unit = member.unit,
                profile = fellowData and fellowData.profile,
                selectedTitle = fellowData and fellowData.selectedTitle,
                selectedColor = fellowData and fellowData.selectedColor,
            })
        end
    end

    return partyFellows
end

--[[
    Create a party fellow card with prominent challenge button
    @param parent Frame - Parent frame
    @param fellow table - Fellow traveler data
    @return Frame - Card frame
]]
function Journal:CreatePartyFellowCard(parent, fellow)
    local Components = HopeAddon.Components
    local Badges = HopeAddon.Badges
    local Directory = HopeAddon.Directory

    local card = self.cardPool:Acquire()
    card:SetParent(parent)
    card:SetSize(parent:GetWidth() - 20, 55)

    -- Get class color
    local classColor = fellow.class and HopeAddon:GetClassColor(fellow.class) or { r = 0.7, g = 0.7, b = 0.7 }

    -- Class icon (left side)
    local classIcon = card.classIcon
    if not classIcon then
        classIcon = card:CreateTexture(nil, "ARTWORK")
        card.classIcon = classIcon
    end
    classIcon:SetSize(32, 32)
    classIcon:ClearAllPoints()
    classIcon:SetPoint("LEFT", card, "LEFT", 12, 0)
    local iconPath = Directory and Directory:GetClassIcon(fellow.class) or "Interface\\Icons\\INV_Misc_QuestionMark"
    classIcon:SetTexture(iconPath)
    classIcon:Show()

    -- Name with title (if set)
    local nameText = card.nameText
    if not nameText then
        nameText = card:CreateFontString(nil, "OVERLAY")
        card.nameText = nameText
    end
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    nameText:ClearAllPoints()
    nameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 10, -2)

    -- Build display name with class color and title
    local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
    local displayName = "|cFF" .. colorHex .. fellow.name .. "|r"
    if fellow.selectedTitle and fellow.selectedTitle ~= "" then
        local titleColor = Badges and Badges:GetTitleColor(fellow.selectedTitle) or "FFD700"
        displayName = displayName .. " |cFF" .. titleColor .. "<" .. fellow.selectedTitle .. ">|r"
    end
    nameText:SetText(displayName)
    nameText:Show()

    -- Level and class text
    local levelText = card.levelText
    if not levelText then
        levelText = card:CreateFontString(nil, "OVERLAY")
        card.levelText = levelText
    end
    levelText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    levelText:ClearAllPoints()
    levelText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    levelText:SetText("Level " .. (fellow.level or "?") .. " " .. (fellow.class or "Unknown"))
    levelText:SetTextColor(0.7, 0.7, 0.7, 1)
    levelText:Show()

    -- Set class-colored border
    card:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.8)
    card.defaultBorderColor = { classColor.r, classColor.g, classColor.b, 0.8 }

    -- CHALLENGE button (prominent, right side) - use Components factory if available
    local challengeBtn = card.partyChallengBtn
    if not challengeBtn then
        -- Use Components:CreateChallengeButton if available, otherwise create manually
        if Components and Components.CreateChallengeButton then
            challengeBtn = Components:CreateChallengeButton(card, nil, function(targetName)
                if HopeAddon.MinigamesUI then
                    HopeAddon.MinigamesUI:ShowGameSelectionPopup(targetName)
                end
            end)
        else
            -- Fallback: manual creation with BackdropTemplate
            challengeBtn = CreateFrame("Button", nil, card, "BackdropTemplate")

            -- Text
            local btnText = challengeBtn:CreateFontString(nil, "OVERLAY")
            btnText:SetFont(HopeAddon.assets.fonts.HEADER, 11)
            btnText:SetPoint("CENTER", challengeBtn, "CENTER", 0, 0)
            btnText:SetText("CHALLENGE")
            btnText:SetTextColor(1, 0.84, 0, 1)
            challengeBtn.text = btnText

            -- Backdrop
            local borderColor = HopeAddon.colors.ARCANE_PURPLE
            challengeBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
                edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            challengeBtn:SetBackdropColor(0.4, 0.2, 0.6, 0.9)
            challengeBtn:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

            -- Hover effect
            challengeBtn:SetScript("OnEnter", function(self)
                self:SetBackdropColor(0.5, 0.3, 0.7, 1)
                self:SetBackdropBorderColor(1, 0.84, 0, 1)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Challenge " .. (self.targetName or "player"), 1, 0.84, 0)
                GameTooltip:AddLine("Select a game to play!", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            challengeBtn:SetScript("OnLeave", function(self)
                self:SetBackdropColor(0.4, 0.2, 0.6, 0.9)
                local bc = HopeAddon.colors.ARCANE_PURPLE
                self:SetBackdropBorderColor(bc.r, bc.g, bc.b, 1)
                GameTooltip:Hide()
            end)

            -- Click handler
            challengeBtn:SetScript("OnClick", function(self)
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayClick()
                end
                if HopeAddon.MinigamesUI then
                    HopeAddon.MinigamesUI:ShowGameSelectionPopup(self.targetName)
                end
            end)
        end
        card.partyChallengBtn = challengeBtn
    end

    -- Position and configure button
    challengeBtn:SetSize(80, 28)
    challengeBtn:ClearAllPoints()
    challengeBtn:SetPoint("RIGHT", card, "RIGHT", -12, 0)
    challengeBtn.targetName = fellow.name
    challengeBtn:Show()

    return card
end

--[[
    Get game statistics for a specific game ID
    @param gameId string - Game identifier (rps, pong, battleship, etc.)
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

    if gameId == "deathroll" then
        -- Death roll local practice via DeathRollUI
        local DeathRollUI = HopeAddon:GetModule("DeathRollUI")
        if DeathRollUI then
            DeathRollUI:QuickStartLocal()
        else
            HopeAddon:Print("DeathRollUI module not loaded")
        end
    elseif gameId == "pong" or gameId == "tetris" then
        -- Pong and Tetris: Show practice mode selection (AI vs 2-Player Local)
        local MinigamesUI = HopeAddon.MinigamesUI
        if MinigamesUI then
            MinigamesUI:ShowPracticeModePopup(gameId, function(mode)
                self:StartPracticeWithMode(gameId, mode)
            end)
        else
            HopeAddon:Print("MinigamesUI module not loaded")
        end
    elseif gameId == "words" then
        -- Words with WoW local practice (vs yourself)
        local WordGame = HopeAddon:GetModule("WordGame")
        if WordGame then
            WordGame:StartGame(nil)  -- nil opponent = local mode
        else
            HopeAddon:Print("WordGame module not loaded")
        end
    elseif gameId == "rps" then
        -- RPS vs AI with gameshow reveal
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            Minigames:StartLocalRPSGame()
        else
            HopeAddon:Print("Minigames module not loaded")
        end
    elseif gameId == "battleship" then
        -- Battleship via GameCore
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            local newGameId = GameCore:CreateGame("BATTLESHIP", GameCore.GAME_MODE.LOCAL, nil)
            if newGameId then
                GameCore:StartGame(newGameId)
            end
        else
            HopeAddon:Print("GameCore module not loaded")
        end
    else
        HopeAddon:Print("Local mode not available for " .. (gameId or "unknown"))
    end
end

--[[
    Start a practice game with the selected mode (AI or 2-Player Local)
    Called by the practice mode selection popup callback
    @param gameId string - Game identifier ("tetris" or "pong")
    @param mode string - Practice mode ("ai" or "local")
]]
function Journal:StartPracticeWithMode(gameId, mode)
    HopeAddon:Debug("Starting practice game:", gameId, "mode:", mode)

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then
        HopeAddon:Print("GameCore module not loaded")
        return
    end

    if gameId == "pong" then
        if mode == "ai" then
            -- Pong vs AI: Use SCORE_CHALLENGE mode (AI paddle enabled)
            local newGameId = GameCore:CreateGame("PONG", GameCore.GAME_MODE.SCORE_CHALLENGE, nil)
            if newGameId then
                GameCore:StartGame(newGameId)
            end
        else
            -- Pong 2-Player Local: Use LOCAL mode (both paddles human-controlled)
            local newGameId = GameCore:CreateGame("PONG", GameCore.GAME_MODE.LOCAL, nil)
            if newGameId then
                GameCore:StartGame(newGameId)
            end
        end
    elseif gameId == "tetris" then
        if mode == "ai" then
            -- Tetris vs AI: Use LOCAL mode with AI flag
            local newGameId = GameCore:CreateGame("TETRIS", GameCore.GAME_MODE.LOCAL, nil)
            if newGameId then
                -- Set AI opponent flag before starting
                local game = GameCore.games and GameCore.games[newGameId]
                if game and game.data and game.data.state then
                    game.data.state.isAIOpponent = true
                end
                GameCore:StartGame(newGameId)
            end
        else
            -- Tetris 2-Player Local: Use LOCAL mode without AI
            local newGameId = GameCore:CreateGame("TETRIS", GameCore.GAME_MODE.LOCAL, nil)
            if newGameId then
                -- Ensure AI is disabled
                local game = GameCore.games and GameCore.games[newGameId]
                if game and game.data and game.data.state then
                    game.data.state.isAIOpponent = false
                end
                GameCore:StartGame(newGameId)
            end
        end
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
    local Badges = HopeAddon.Badges

    -- Get formatted display data
    local display = Directory and Directory:FormatEntryForDisplay(entry) or {}

    -- Get class color once for reuse (description + border)
    local classColor = entry.class and HopeAddon:GetClassColor(entry.class) or nil

    -- Build the display name with title if available
    local displayTitle = entry.name
    if entry.selectedTitle and entry.selectedTitle ~= "" then
        -- Get the title's color from the badge system
        local titleColor = Badges and Badges:GetTitleColor(entry.selectedTitle) or "FFD700"
        displayTitle = string.format("%s |cFF%s<%s>|r", display.coloredName or entry.name, titleColor, entry.selectedTitle)
    else
        displayTitle = display.coloredName or entry.name
    end

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

    -- Add game stats if we have played games with this player
    local gameStats = self:GetOpponentGameStats(entry.name)
    if gameStats then
        local recordColor = self:GetRecordColor(gameStats.wins, gameStats.losses)
        local colorHex = "FFFFFF"
        if recordColor == "FEL_GREEN" then colorHex = "00FF00"
        elseif recordColor == "HELLFIRE_RED" then colorHex = "FF4444"
        elseif recordColor == "GOLD_BRIGHT" then colorHex = "FFD700"
        end
        local recordStr = self:FormatRecord(gameStats.wins, gameStats.losses, gameStats.ties, gameStats.ties > 0)
        table.insert(descParts, string.format("|cFF9B30FF[Games]|r |cFF%s%s|r (%d played)", colorHex, recordStr, gameStats.totalGames))
    end

    local description = table.concat(descParts, "\n")

    -- Get class icon
    local icon = Directory and Directory:GetClassIcon(entry.class) or "Interface\\Icons\\INV_Misc_QuestionMark"

    -- Create card with title-enhanced display name
    local card = self:AcquireCard(self.mainFrame.scrollContainer.content, {
        icon = icon,
        title = displayTitle,
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
                GameTooltip:AddLine("RPS, Death Roll, Pong, Tetris, etc.", 0.8, 0.8, 0.8)
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

        -- Add Companion button (heart icon, next to challenge button)
        local isCompanion = HopeAddon.Companions and HopeAddon.Companions:IsCompanion(entry.name)

        local addCompBtn = card.addCompBtn
        if not addCompBtn then
            addCompBtn = CreateFrame("Button", nil, card)
            card.addCompBtn = addCompBtn

            -- Heart icon texture
            local btnIcon = addCompBtn:CreateTexture(nil, "ARTWORK")
            btnIcon:SetAllPoints()
            btnIcon:SetTexture("Interface\\Icons\\INV_ValentinesCandy")
            addCompBtn.icon = btnIcon

            -- Highlight on hover
            local btnHighlight = addCompBtn:CreateTexture(nil, "HIGHLIGHT")
            btnHighlight:SetAllPoints()
            btnHighlight:SetTexture(HopeAddon.assets.textures.HIGHLIGHT)
            btnHighlight:SetBlendMode("ADD")
            btnHighlight:SetVertexColor(1, 1, 1, 0.3)

            -- Border (gold)
            local goldColor = HopeAddon.colors.GOLD_BRIGHT
            local btnBorder = addCompBtn:CreateTexture(nil, "OVERLAY")
            btnBorder:SetPoint("TOPLEFT", addCompBtn, "TOPLEFT", -2, 2)
            btnBorder:SetPoint("BOTTOMRIGHT", addCompBtn, "BOTTOMRIGHT", 2, -2)
            btnBorder:SetTexture(HopeAddon.assets.textures.TOOLTIP_BORDER)
            btnBorder:SetVertexColor(goldColor.r, goldColor.g, goldColor.b, 1)
            addCompBtn.border = btnBorder
        end

        -- Position
        addCompBtn:SetSize(22, 22)
        addCompBtn:ClearAllPoints()
        addCompBtn:SetPoint("RIGHT", challengeBtn, "LEFT", -6, 0)
        addCompBtn.targetName = entry.name

        -- Update visual based on companion status
        if isCompanion then
            addCompBtn.icon:SetVertexColor(1, 0.84, 0)  -- Gold = already companion
            addCompBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Already a Companion", 1, 0.84, 0)
                GameTooltip:AddLine("This Fellow is on your Companions list", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            addCompBtn:SetScript("OnClick", nil)  -- No action
        else
            addCompBtn.icon:SetVertexColor(0.7, 0.7, 0.7)  -- Grey = can add
            addCompBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Add as Companion", 1, 0.84, 0)
                GameTooltip:AddLine("Send a companion request", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            addCompBtn:SetScript("OnClick", function(self)
                if HopeAddon.Sounds then
                    HopeAddon.Sounds:PlayClick()
                end
                if HopeAddon.Companions then
                    HopeAddon.Companions:SendRequest(self.targetName)
                end
            end)
        end
        addCompBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        addCompBtn:Show()
    elseif card.challengeBtn then
        card.challengeBtn:Hide()
        if card.addCompBtn then
            card.addCompBtn:Hide()
        end
    end

    -- Click handler to show details including game stats
    card.OnCardClick = function(cardFrame, entryData)
        HopeAddon.Sounds:PlayClick()
        HopeAddon:Print("--- " .. entry.name .. " ---")
        if note then
            HopeAddon:Print("|cFFFFD700Note:|r " .. note)
        end
        -- Show detailed game stats if any
        if gameStats and gameStats.totalGames > 0 then
            HopeAddon:Print("|cFF9B30FFGame Record:|r")
            for gameId, stats in pairs(gameStats.games) do
                local gameInfo = GAME_STATS_INFO[gameId]
                local gameName = gameInfo and gameInfo.name or gameId
                local hasTies = gameInfo and gameInfo.hasTies
                local record = self:FormatRecord(stats.wins, stats.losses, stats.ties, hasTies)
                HopeAddon:Print(string.format("  %s: %s", gameName, record))
            end
        end
    end

    return card
end

-- Creates a compact horizontal row showing all game icons with W-L records
function Journal:CreateGameStatsRow(parent)
    local ICON_SIZE = 32
    local ICON_SPACING = 6
    local ROW_HEIGHT = 65

    -- Create container frame from pool
    local row = self.containerPool:Acquire()
    row:SetParent(parent)
    row:SetHeight(ROW_HEIGHT)
    row._componentType = "gameStatsRow"

    -- Store child frames for cleanup
    row._iconFrames = row._iconFrames or {}

    -- Create icon+stat pairs for each game
    for i, gameId in ipairs(GAME_STATS_ORDER) do
        local gameInfo = GAME_STATS_INFO[gameId]
        local gameStats = self:GetPerGameStats(gameId)

        -- Reuse or create icon frame
        local iconFrame = row._iconFrames[i]
        if not iconFrame then
            iconFrame = CreateFrame("Frame", nil, row)
            row._iconFrames[i] = iconFrame

            -- Icon texture
            local icon = iconFrame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(ICON_SIZE, ICON_SIZE)
            icon:SetPoint("TOP", 0, -5)
            iconFrame.icon = icon

            -- W-L text below icon
            local record = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            record:SetPoint("TOP", icon, "BOTTOM", 0, -2)
            iconFrame.record = record
        end

        iconFrame:SetParent(row)
        iconFrame:SetSize(ICON_SIZE + 12, ROW_HEIGHT - 8)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("LEFT", row, "LEFT", (i - 1) * (ICON_SIZE + ICON_SPACING + 6) + 10, 0)
        iconFrame:Show()

        -- Update icon
        iconFrame.icon:SetTexture(gameInfo.icon)

        -- Update W-L text
        if gameStats.total > 0 then
            local recordText = gameStats.wins .. "-" .. gameStats.losses
            if gameInfo.hasTies and gameStats.ties > 0 then
                recordText = recordText .. "-" .. gameStats.ties
            end
            iconFrame.record:SetText(recordText)

            -- Color based on record
            local color = HopeAddon.colors[self:GetRecordColor(gameStats.wins, gameStats.losses)]
            if color then
                iconFrame.record:SetTextColor(color.r, color.g, color.b)
            end
            iconFrame.icon:SetDesaturated(false)
        else
            iconFrame.record:SetText("--")
            iconFrame.record:SetTextColor(0.5, 0.5, 0.5)
            iconFrame.icon:SetDesaturated(true)
        end
    end

    -- Overall stats on right side
    local aggregate = self:GetAggregateGameStats()

    -- Reuse or create overall text elements
    if not row._overallText then
        row._overallText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row._winRateText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end

    row._overallText:ClearAllPoints()
    row._overallText:SetPoint("RIGHT", row, "RIGHT", -15, 5)
    row._overallText:SetText(string.format("%dW-%dL", aggregate.wins, aggregate.losses))
    row._overallText:Show()

    row._winRateText:ClearAllPoints()
    row._winRateText:SetPoint("TOP", row._overallText, "BOTTOM", 0, -2)
    row._winRateText:SetText(string.format("(%.0f%%)", aggregate.winRate))
    row._winRateText:Show()

    local color = HopeAddon.colors[self:GetRecordColor(aggregate.wins, aggregate.losses)]
    if color then
        row._overallText:SetTextColor(color.r, color.g, color.b)
        row._winRateText:SetTextColor(color.r, color.g, color.b)
    end

    row:Show()
    return row
end

function Journal:PopulateStats()
    local scrollContainer = self.mainFrame.scrollContainer

    --============================================================
    -- SECTION 1: BADGES
    --============================================================
    self:PopulateBadgesSection(scrollContainer)

    --============================================================
    -- SECTION 2: BOSS KILL TRACKER
    --============================================================
    local spacer1 = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer1)

    self:PopulateBossKillTracker(scrollContainer)
end

--[[
    Populate the Badges section in the Stats tab
    Shows badges organized by category in collapsible sections
]]
function Journal:PopulateBadgesSection(scrollContainer)
    local Badges = HopeAddon.Badges
    if not Badges then return end

    -- Get badges organized by category
    local categorizedBadges = Badges:GetBadgesByCategory()

    -- Calculate totals for header
    local earnedCount = 0
    local totalCount = 0
    for _, categoryData in ipairs(categorizedBadges) do
        earnedCount = earnedCount + categoryData.earnedCount
        totalCount = totalCount + categoryData.totalCount
    end

    -- Header with earned count
    local header = self:CreateSectionHeader(
        string.format("BADGES (%d / %d)", earnedCount, totalCount),
        "GOLD_BRIGHT",
        "Achievements unlocked through your journey"
    )
    scrollContainer:AddEntry(header)

    -- Create collapsible section for each category
    for _, categoryData in ipairs(categorizedBadges) do
        local category = categoryData.category
        local sectionTitle = string.format("%s (%d / %d)", category.name, categoryData.earnedCount, categoryData.totalCount)

        -- Create collapsible section (collapsed by default)
        local section = self:AcquireCollapsibleSection(
            scrollContainer.content,
            sectionTitle,
            category.color,
            false  -- Start collapsed
        )

        if section then
            -- Set up toggle callback to recalculate scroll positions
            section.onToggle = function(sec, expanded)
                scrollContainer:RecalculatePositions()
            end

            -- Add badge cards to section
            for _, badgeInfo in ipairs(categoryData.badges) do
                local card = self:CreateBadgeCard(section.contentContainer, badgeInfo)
                if card then
                    section:AddChild(card)
                end
            end

            scrollContainer:AddEntry(section)
        end
    end
end

--[[
    Create a badge card for display in badge sections
    @param parent Frame - Parent frame
    @param badgeInfo table - { id, definition, unlocked, unlockDate }
    @return Frame - Configured card
]]
function Journal:CreateBadgeCard(parent, badgeInfo)
    local def = badgeInfo.definition
    local isUnlocked = badgeInfo.unlocked

    -- Build description
    local descParts = {}
    table.insert(descParts, def.description)

    -- Add reward info
    if def.reward then
        if def.reward.title then
            local titleColorHex = def.reward.colorHex or "FFD700"
            table.insert(descParts, string.format("Title: |cFF%s%s|r", titleColorHex, def.reward.title))
        end
        if def.reward.colorName then
            local colorHex = def.reward.colorHex or "FFFFFF"
            table.insert(descParts, string.format("Color: |cFF%s%s|r", colorHex, def.reward.colorName))
        end
    end

    -- Add unlock date if earned
    if isUnlocked and badgeInfo.unlockDate then
        table.insert(descParts, "|cFF00FF00Earned: " .. badgeInfo.unlockDate .. "|r")
    elseif not isUnlocked then
        table.insert(descParts, "|cFF808080Not yet earned|r")
    end

    local description = table.concat(descParts, "\n")

    -- Create card from pool
    local card = self:AcquireCard(parent, {
        icon = "Interface\\Icons\\" .. def.icon,
        title = (isUnlocked and "|cFFFFFFFF" or "|cFF606060") .. def.name .. "|r",
        description = description,
        timestamp = "",
    })

    if not card then return nil end

    -- Style based on unlock status
    if isUnlocked then
        -- Earned: Use badge color for border
        local colorHex = def.reward and def.reward.colorHex or "FFD700"
        local r = tonumber(colorHex:sub(1, 2), 16) / 255
        local g = tonumber(colorHex:sub(3, 4), 16) / 255
        local b = tonumber(colorHex:sub(5, 6), 16) / 255
        card:SetBackdropBorderColor(r, g, b, 1)
        card.defaultBorderColor = { r, g, b, 1 }

        -- Make icon fully visible
        if card.iconTexture then
            card.iconTexture:SetDesaturated(false)
            card.iconTexture:SetVertexColor(1, 1, 1, 1)
        end
    else
        -- Not earned: Greyed out
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
        card.defaultBorderColor = { 0.3, 0.3, 0.3, 0.6 }

        -- Desaturate icon
        if card.iconTexture then
            card.iconTexture:SetDesaturated(true)
            card.iconTexture:SetVertexColor(0.5, 0.5, 0.5, 0.7)
        end
    end

    return card
end

--[[
    Populate the Boss Kill Tracker section in the Stats tab
    Shows all TBC raid bosses organized by tier with kill counts
]]
function Journal:PopulateBossKillTracker(scrollContainer)
    local Badges = HopeAddon.Badges
    local C = HopeAddon.Constants
    if not Badges or not C or not C.BOSS_BADGES then return end

    -- Get boss data organized by tier
    local bossByTier = Badges:GetBossBadgesByTier()
    local bossStats = Badges:GetBossStats()

    -- Tier display configuration
    local tierConfig = {
        {
            tier = "T4",
            name = "Tier 4",
            color = "GOLD_BRIGHT",
            raids = "Karazhan, Gruul's Lair, Magtheridon",
            totalBosses = 14,
        },
        {
            tier = "T5",
            name = "Tier 5",
            color = "SKY_BLUE",
            raids = "Serpentshrine Cavern, Tempest Keep",
            totalBosses = 10,
        },
        {
            tier = "T6",
            name = "Tier 6",
            color = "HELLFIRE_RED",
            raids = "Hyjal, Black Temple, Sunwell",
            totalBosses = 20,
        },
    }

    -- Header
    local header = self:CreateSectionHeader(
        string.format("BOSS KILL TRACKER (%d / %d bosses)", bossStats.totalBosses, 44),
        "HELLFIRE_RED",
        "Track your raid boss kills across Outland"
    )
    scrollContainer:AddEntry(header)

    -- Create collapsible section for each tier
    for _, config in ipairs(tierConfig) do
        local tierBosses = bossByTier[config.tier] or {}

        -- Count killed bosses in this tier
        local killedCount = 0
        for _, bossEntry in ipairs(tierBosses) do
            if bossEntry.kills > 0 then
                killedCount = killedCount + 1
            end
        end

        -- Section title with raid names
        local sectionTitle = string.format("%s (%d / %d) - %s",
            config.name, killedCount, config.totalBosses, config.raids)

        -- Create collapsible section (collapsed by default)
        local section = self:AcquireCollapsibleSection(
            scrollContainer.content,
            sectionTitle,
            config.color,
            false  -- Start collapsed
        )

        if section then
            -- Set up toggle callback to recalculate scroll positions
            section.onToggle = function(sec, expanded)
                scrollContainer:RecalculatePositions()
            end

            -- Sort bosses by raid, then by finalBoss (final bosses last within each raid)
            local sortedBosses = {}
            for _, entry in ipairs(tierBosses) do
                table.insert(sortedBosses, entry)
            end
            table.sort(sortedBosses, function(a, b)
                -- Sort by raid first
                if a.badge.raid ~= b.badge.raid then
                    return a.badge.raid < b.badge.raid
                end
                -- Within same raid, final bosses go last
                local aFinal = a.badge.finalBoss and 1 or 0
                local bFinal = b.badge.finalBoss and 1 or 0
                if aFinal ~= bFinal then
                    return aFinal < bFinal
                end
                -- Otherwise alphabetical by name
                return a.badge.name < b.badge.name
            end)

            -- Add boss cards to section
            for _, bossEntry in ipairs(sortedBosses) do
                local card = self:CreateBossKillCard(section.contentContainer, bossEntry)
                if card then
                    section:AddChild(card)
                end
            end

            scrollContainer:AddEntry(section)
        end
    end
end

--[[
    Create a boss kill card for display in boss tracker
    Uses RPG quality colors based on kill count:
    - 1 kill = Poor (grey)
    - 5 kills = Common (white)
    - 10 kills = Uncommon (green)
    - 25 kills = Rare (blue)
    - 50 kills = Epic (purple)
    - 69 kills = Legendary (orange)
    @param parent Frame - Parent frame
    @param bossEntry table - { badge, kills, firstKill, tier }
    @return Frame - Configured card
]]
function Journal:CreateBossKillCard(parent, bossEntry)
    local badge = bossEntry.badge
    local kills = bossEntry.kills or 0
    local isKilled = kills > 0
    local C = HopeAddon.Constants

    -- Get tier data for RPG quality coloring
    local tier = bossEntry.tier or (isKilled and C:GetBossTier(kills) or nil)
    local nextTier = isKilled and C:GetNextBossTier(kills) or nil

    -- Build description
    local descParts = {}

    if isKilled then
        -- Color the kill count based on tier quality
        local killsColor = tier and tier.colorHex or "FFFFFF"
        local tierName = tier and tier.name or "Poor"
        table.insert(descParts, string.format("|cFF%sKills: %d (%s)|r", killsColor, kills, tierName))

        -- Show progress to next tier
        if nextTier then
            local remaining = nextTier.kills - kills
            table.insert(descParts, string.format("|cFF808080%d more for %s|r", remaining, nextTier.name))
        elseif kills >= 69 then
            table.insert(descParts, "|cFFFF8000LEGENDARY!|r")
        end

        if bossEntry.firstKill then
            table.insert(descParts, string.format("First Kill: %s", bossEntry.firstKill))
        end
    else
        table.insert(descParts, "|cFF808080Not yet killed|r")
    end

    -- Add raid info
    local raidName = self:GetRaidDisplayName(badge.raid)
    if raidName then
        table.insert(descParts, "|cFF606060" .. raidName .. "|r")
    end

    local description = table.concat(descParts, "\n")

    -- Create card from pool - title color based on tier
    local titleColor = "606060"  -- Default grey for unkilled
    if isKilled and tier then
        titleColor = tier.colorHex
    end

    local card = self:AcquireCard(parent, {
        icon = "Interface\\Icons\\" .. badge.icon,
        title = string.format("|cFF%s%s|r", titleColor, badge.name),
        description = description,
        timestamp = "",
    })

    if not card then return nil end

    -- Style based on kill status and tier
    if isKilled then
        -- Parse tier color hex to RGB
        local colorHex = tier and tier.colorHex or "FFFFFF"
        local r = tonumber(colorHex:sub(1, 2), 16) / 255
        local g = tonumber(colorHex:sub(3, 4), 16) / 255
        local b = tonumber(colorHex:sub(5, 6), 16) / 255

        card:SetBackdropBorderColor(r, g, b, 1)
        card.defaultBorderColor = { r, g, b, 1 }

        if card.iconTexture then
            card.iconTexture:SetDesaturated(false)
            card.iconTexture:SetVertexColor(1, 1, 1, 1)
        end
    else
        -- Not killed: Grey border, desaturated icon
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
        card.defaultBorderColor = { 0.3, 0.3, 0.3, 0.6 }

        if card.iconTexture then
            card.iconTexture:SetDesaturated(true)
            card.iconTexture:SetVertexColor(0.5, 0.5, 0.5, 0.7)
        end
    end

    return card
end

--[[
    Get display name for a raid key
    @param raidKey string - Raid identifier
    @return string - Display name
]]
function Journal:GetRaidDisplayName(raidKey)
    local raidNames = {
        karazhan = "Karazhan",
        gruul = "Gruul's Lair",
        magtheridon = "Magtheridon's Lair",
        ssc = "Serpentshrine Cavern",
        tk = "Tempest Keep",
        hyjal = "Mount Hyjal",
        bt = "Black Temple",
        sunwell = "Sunwell Plateau",
    }
    return raidNames[raidKey]
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

    local outlandZones = 0
    local discoveries = HopeAddon.charDb.journal.zoneDiscoveries or {}
    local outlandZoneList = HopeAddon.Constants.OUTLAND_ZONES or {}
    for _, zoneName in ipairs(outlandZoneList) do
        if discoveries[zoneName] then
            outlandZones = outlandZones + 1
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
        outlandZonesExplored = outlandZones,
        attunementsCompleted = attunementsComplete,
        exaltedReputations = exaltedReps,
        ridingSkill = self:GetRidingSkill(),
    }

    return self.cachedStatsData
end

--[[
    GAME STATS HELPER FUNCTIONS
    These aggregate minigame statistics across all opponents for the Stats tab
    Note: GAME_STATS_ORDER and GAME_STATS_INFO are defined at top of file (line ~91)
]]

function Journal:GetAggregateGameStats()
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.travelers or not charDb.travelers.known then
        return { totalGames = 0, wins = 0, losses = 0, ties = 0, winRate = 0, totalRivals = 0 }
    end

    local totals = {
        totalGames = 0,
        wins = 0,
        losses = 0,
        ties = 0,
        gamesPerType = {},
        opponentGames = {},
        totalRivals = 0,
    }

    for opponentName, traveler in pairs(charDb.travelers.known) do
        if traveler.stats and traveler.stats.minigames then
            local hasGames = false
            for gameType, stats in pairs(traveler.stats.minigames) do
                local gameTotal = (stats.wins or 0) + (stats.losses or 0) + (stats.ties or 0)
                if gameTotal > 0 then
                    hasGames = true
                    totals.totalGames = totals.totalGames + gameTotal
                    totals.wins = totals.wins + (stats.wins or 0)
                    totals.losses = totals.losses + (stats.losses or 0)
                    totals.ties = totals.ties + (stats.ties or 0)

                    if not totals.gamesPerType[gameType] then
                        totals.gamesPerType[gameType] = { wins = 0, losses = 0, ties = 0, total = 0 }
                    end
                    local gt = totals.gamesPerType[gameType]
                    gt.wins = gt.wins + (stats.wins or 0)
                    gt.losses = gt.losses + (stats.losses or 0)
                    gt.ties = gt.ties + (stats.ties or 0)
                    gt.total = gt.total + gameTotal

                    totals.opponentGames[opponentName] = (totals.opponentGames[opponentName] or 0) + gameTotal
                end
            end
            if hasGames then
                totals.totalRivals = totals.totalRivals + 1
            end
        end
    end

    totals.winRate = totals.totalGames > 0 and (totals.wins / totals.totalGames * 100) or 0

    local bestGame, bestWinRate = nil, 0
    for gameType, stats in pairs(totals.gamesPerType) do
        if stats.total >= 3 then
            local winRate = stats.wins / stats.total
            if winRate > bestWinRate then
                bestWinRate = winRate
                bestGame = gameType
            end
        end
    end
    totals.bestGame = bestGame
    totals.bestGameWinRate = bestWinRate * 100

    local favoriteOpponent, maxGames = nil, 0
    for name, count in pairs(totals.opponentGames) do
        if count > maxGames then
            maxGames = count
            favoriteOpponent = name
        end
    end
    totals.favoriteOpponent = favoriteOpponent
    totals.favoriteOpponentGames = maxGames

    return totals
end

function Journal:GetPerGameStats(gameId)
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.travelers or not charDb.travelers.known then
        return { wins = 0, losses = 0, ties = 0, total = 0, winRate = 0, opponents = 0 }
    end

    local stats = {
        wins = 0, losses = 0, ties = 0, total = 0, opponents = 0,
        highestScore = 0, highestRoll = 0, highestBet = 0, lastPlayed = nil,
    }

    for _, traveler in pairs(charDb.travelers.known) do
        if traveler.stats and traveler.stats.minigames then
            local gameStats = traveler.stats.minigames[gameId]
            if gameStats then
                local gameTotal = (gameStats.wins or 0) + (gameStats.losses or 0) + (gameStats.ties or 0)
                if gameTotal > 0 then
                    stats.wins = stats.wins + (gameStats.wins or 0)
                    stats.losses = stats.losses + (gameStats.losses or 0)
                    stats.ties = stats.ties + (gameStats.ties or 0)
                    stats.total = stats.total + gameTotal
                    stats.opponents = stats.opponents + 1

                    if gameStats.highestScore and gameStats.highestScore > stats.highestScore then
                        stats.highestScore = gameStats.highestScore
                    end
                    if gameStats.highestRoll and gameStats.highestRoll > stats.highestRoll then
                        stats.highestRoll = gameStats.highestRoll
                    end
                    if gameStats.highestBet and gameStats.highestBet > stats.highestBet then
                        stats.highestBet = gameStats.highestBet
                    end
                    if gameStats.lastPlayed and (not stats.lastPlayed or gameStats.lastPlayed > stats.lastPlayed) then
                        stats.lastPlayed = gameStats.lastPlayed
                    end
                end
            end
        end
    end

    stats.winRate = stats.total > 0 and (stats.wins / stats.total * 100) or 0
    return stats
end

--[[
    Get game stats for a specific opponent
    @param opponentName string - Name of the opponent
    @return table - { totalGames, wins, losses, ties, winRate, games = { [gameId] = { wins, losses, ties } } }
]]
function Journal:GetOpponentGameStats(opponentName)
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.travelers or not charDb.travelers.known then
        return nil
    end

    local traveler = charDb.travelers.known[opponentName]
    if not traveler or not traveler.stats or not traveler.stats.minigames then
        return nil
    end

    local result = {
        totalGames = 0,
        wins = 0,
        losses = 0,
        ties = 0,
        games = {},
    }

    for gameId, stats in pairs(traveler.stats.minigames) do
        local gameTotal = (stats.wins or 0) + (stats.losses or 0) + (stats.ties or 0)
        if gameTotal > 0 then
            result.totalGames = result.totalGames + gameTotal
            result.wins = result.wins + (stats.wins or 0)
            result.losses = result.losses + (stats.losses or 0)
            result.ties = result.ties + (stats.ties or 0)

            result.games[gameId] = {
                wins = stats.wins or 0,
                losses = stats.losses or 0,
                ties = stats.ties or 0,
                total = gameTotal,
            }
        end
    end

    result.winRate = result.totalGames > 0 and (result.wins / result.totalGames * 100) or 0

    return result.totalGames > 0 and result or nil
end

function Journal:GetRivalData(limit)
    limit = limit or 10
    local charDb = HopeAddon.charDb
    if not charDb or not charDb.travelers or not charDb.travelers.known then
        return {}
    end

    local rivals = {}

    for name, traveler in pairs(charDb.travelers.known) do
        if traveler.stats and traveler.stats.minigames then
            local rival = {
                name = name, class = traveler.class, totalGames = 0,
                wins = 0, losses = 0, ties = 0, lastPlayed = nil,
                games = {}, dominantGame = nil, dominantGameWins = 0,
            }

            for gameType, stats in pairs(traveler.stats.minigames) do
                local gameTotal = (stats.wins or 0) + (stats.losses or 0) + (stats.ties or 0)
                if gameTotal > 0 then
                    rival.totalGames = rival.totalGames + gameTotal
                    rival.wins = rival.wins + (stats.wins or 0)
                    rival.losses = rival.losses + (stats.losses or 0)
                    rival.ties = rival.ties + (stats.ties or 0)

                    rival.games[gameType] = {
                        wins = stats.wins or 0, losses = stats.losses or 0, ties = stats.ties or 0,
                        highestScore = stats.highestScore, highestRoll = stats.highestRoll, highestBet = stats.highestBet,
                    }

                    if (stats.wins or 0) > rival.dominantGameWins then
                        rival.dominantGameWins = stats.wins or 0
                        rival.dominantGame = gameType
                    end

                    if stats.lastPlayed and (not rival.lastPlayed or stats.lastPlayed > rival.lastPlayed) then
                        rival.lastPlayed = stats.lastPlayed
                    end
                end
            end

            if rival.totalGames > 0 then
                table.insert(rivals, rival)
            end
        end
    end

    table.sort(rivals, function(a, b) return a.totalGames > b.totalGames end)

    if #rivals > limit then
        local limited = {}
        for i = 1, limit do
            limited[i] = rivals[i]
        end
        return limited
    end

    return rivals
end

function Journal:GetRecordColor(wins, losses)
    if wins > losses then
        return "FEL_GREEN"
    elseif losses > wins then
        return "HELLFIRE_RED"
    else
        return "GOLD_BRIGHT"
    end
end

function Journal:FormatRecord(wins, losses, ties, hasTies)
    if hasTies and ties and ties > 0 then
        return string.format("%dW-%dL-%dT", wins, losses, ties)
    else
        return string.format("%dW-%dL", wins, losses)
    end
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

    -- Play funny death sound sequence (Bumblebee style)
    HopeAddon.Sounds:PlayDeathComedy()
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

        -- Restore last selected tab or default to journey
        local lastTab = HopeAddon.charDb.journal.lastTab or "journey"
        -- Migrate removed tab selections to journey
        if lastTab == "zones" or lastTab == "milestones" or lastTab == "directory" then
            lastTab = "journey"
        end
        self:SelectTab(lastTab)
    end
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Journal module loaded")
end
