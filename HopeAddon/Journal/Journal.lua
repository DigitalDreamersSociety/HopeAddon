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

-- Social tab cached containers (destroyed on tab switch to prevent memory leaks)
-- These are complex containers that aren't suitable for pooling
Journal.socialContainers = {
    profileSection = nil,
    activitySection = nil,
    companionsSection = nil,
    lfRPBoard = nil,
    toolbar = nil,
    paginationControls = nil,
    -- New tabbed interface elements
    statusBar = nil,
    tabBar = nil,
    content = nil,
    filterBar = nil,  -- Travelers quick filter bar (preserved across filter changes)
}

-- Social sub-tab references
Journal.socialSubTabs = {
    feed = nil,
    travelers = nil,
    companions = nil,
}

-- Quick filter button references (for Travelers tab)
Journal.quickFilterButtons = {}

-- Track regions (FontStrings, Textures) created in social content for cleanup
Journal.socialContentRegions = {}

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
    self:CreateUpgradeCardPool()
    self:CreateMainFrame()
    self:RegisterEvents()

    -- Register as ActivityFeed listener for real-time updates
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:RegisterListener("Journal", function(count)
            Journal:OnNewActivity(count)
        end)
    end

    HopeAddon:Debug("Journal module enabled")
end

function Journal:OnDisable()
    -- Unregister from ActivityFeed listener
    if HopeAddon.ActivityFeed then
        HopeAddon.ActivityFeed:UnregisterListener("Journal")
    end

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

    -- Stop all glows tracked by Effects module
    if HopeAddon.Effects then
        HopeAddon.Effects:StopAllGlows()
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
    if self.upgradeCardPool then
        self.upgradeCardPool:Destroy()
        self.upgradeCardPool = nil
    end

    -- Cleanup new activities banner
    if self.newActivitiesBanner then
        self.newActivitiesBanner:Hide()
        self.newActivitiesBanner:SetParent(nil)
        self.newActivitiesBanner = nil
    end
    self.pendingActivityCount = 0

    -- Destroy social tab containers
    self:CleanupSocialContainers(true)
end

--[[
    Cleanup Social tab containers
    Called on tab switch to destroy containers, and in OnDisable for full cleanup
    @param destroy boolean - If true, destroy frames and clear references
]]
function Journal:CleanupSocialContainers(destroy)
    if not self.socialContainers then return end

    -- Close any open dropdown menus first
    CloseDropDownMenus()

    for key, container in pairs(self.socialContainers) do
        if container then
            -- Stop any glow effects on the container
            if container._glowEffect and HopeAddon.Effects then
                HopeAddon.Effects:StopGlow(container._glowEffect)
            end

            container:Hide()

            if destroy then
                container:SetParent(nil)
                self.socialContainers[key] = nil
            end
        end
    end

    -- Also cleanup rumorInputFrame
    if self.rumorInputFrame then
        self.rumorInputFrame:Hide()
        if destroy then
            self.rumorInputFrame:SetParent(nil)
            self.rumorInputFrame = nil
        end
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
        card.title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
        card.desc:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        card.timestamp:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")

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
        -- Clean up standing progress text (created in CreateReputationCard)
        if card.standingProgress then
            card.standingProgress:SetText("")
            card.standingProgress:Hide()
        end
        -- Clean up loot icons (created in PopulateRaids boss cards)
        if card.lootIcons then
            for _, lootIcon in ipairs(card.lootIcons) do
                lootIcon:Hide()
                lootIcon:SetScript("OnEnter", nil)
                lootIcon:SetScript("OnLeave", nil)
                lootIcon.itemData = nil
                lootIcon.qualityColor = nil
            end
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
        card.infoText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")

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
    Create upgrade card frame pool for reputation tab upgrade items
    Reuses frames instead of creating new ones each tab switch
]]
function Journal:CreateUpgradeCardPool()
    local C = HopeAddon.Constants
    local CARD_HEIGHT = 85
    local ICON_SIZE = 32

    local createFunc = function()
        local card = CreateBackdropFrame("Frame", nil, UIParent, "BackdropTemplate")
        card:SetHeight(CARD_HEIGHT)
        HopeAddon.Components:ApplyBackdrop(card, "TOOLTIP")
        card:EnableMouse(true)
        card:Hide()

        -- Pre-create all elements
        card.icon = card:CreateTexture(nil, "ARTWORK")
        card.icon:SetSize(ICON_SIZE, ICON_SIZE)
        card.icon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
        card.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        card.iconBorder = card:CreateTexture(nil, "OVERLAY")
        card.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        card.iconBorder:SetBlendMode("ADD")
        card.iconBorder:SetPoint("CENTER", card.icon, "CENTER")
        card.iconBorder:SetSize(ICON_SIZE + 12, ICON_SIZE + 12)

        card.nameText = card:CreateFontString(nil, "OVERLAY")
        card.nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
        card.nameText:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 10, -2)

        card.statsText = card:CreateFontString(nil, "OVERLAY")
        card.statsText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        card.statsText:SetPoint("TOPLEFT", card.nameText, "BOTTOMLEFT", 0, -2)

        card.factionText = card:CreateFontString(nil, "OVERLAY")
        card.factionText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        card.factionText:SetPoint("TOPLEFT", card.statsText, "BOTTOMLEFT", 0, -2)

        card.statusBadge = card:CreateFontString(nil, "OVERLAY")
        card.statusBadge:SetFont(HopeAddon.assets.fonts.HEADER, 10, "OUTLINE")
        card.statusBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)

        card.standingLabel = card:CreateFontString(nil, "OVERLAY")
        card.standingLabel:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")

        return card
    end

    local resetFunc = function(card)
        card:Hide()
        card:ClearAllPoints()
        card:SetParent(nil)
        card:SetAlpha(1.0)
        card:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        -- Reset icon
        card.icon:SetTexture(nil)
        card.icon:SetDesaturated(false)
        card.icon:SetVertexColor(1, 1, 1)
        card.iconBorder:SetVertexColor(1, 1, 1, 0.8)

        -- Reset text
        card.nameText:SetText("")
        card.statsText:SetText("")
        card.factionText:SetText("")
        card.statusBadge:SetText("")
        card.standingLabel:SetText("")

        -- Clear scripts
        card:SetScript("OnEnter", nil)
        card:SetScript("OnLeave", nil)

        -- Clean up progress bar if exists
        if card.progressBar then
            card.progressBar:Hide()
            card.progressBar:SetParent(nil)
            card.progressBar = nil
        end

        -- Clear stored data
        card.itemData = nil
        card.factionProgress = nil

        card._pooled = true
        card._componentType = "upgradeCard"
    end

    self.upgradeCardPool = HopeAddon.FramePool:NewNamed("UpgradeCards", createFunc, resetFunc)
end

--[[
    Acquire and configure an upgrade card from the pool
    @param parent Frame - Parent to attach to
    @param itemData table - Item data from CLASS_SPEC_LOOT_HOTLIST
    @param factionProgress table - Faction progress data {standingId, standingName, current, max}
    @return Frame - Configured pooled upgrade card
]]
function Journal:AcquireUpgradeCard(parent, itemData, factionProgress)
    if not self.upgradeCardPool then
        HopeAddon:Debug("WARN: AcquireUpgradeCard called but upgradeCardPool is nil")
        return nil
    end

    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local card = self.upgradeCardPool:Acquire()

    card:SetParent(parent)
    card:SetWidth(parent:GetWidth() > 0 and parent:GetWidth() - 20 or 400)
    card._pooled = true
    card._componentType = "upgradeCard"

    -- Store data for tooltip
    card.itemData = itemData
    card.factionProgress = factionProgress

    -- Quality color
    local qualityColor = C.ITEM_QUALITY_COLORS and C.ITEM_QUALITY_COLORS[itemData.quality]
    if not qualityColor then
        qualityColor = { r = 1, g = 1, b = 1 }
    end
    card:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)

    -- Icon
    card.icon:SetTexture("Interface\\Icons\\" .. (itemData.icon or "INV_Misc_QuestionMark"))
    card.iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b, 0.8)

    -- Item name
    card.nameText:SetText(itemData.name or "Unknown Item")
    card.nameText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Stats
    card.statsText:SetText((itemData.slot or "Unknown") .. " - " .. (itemData.stats or ""))
    card.statsText:SetTextColor(0.8, 0.8, 0.8)

    -- Determine if this is a non-rep item
    local isNonRepItem = factionProgress.isNonRepItem or not itemData.faction
    local standingNames = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
    local reqStanding = itemData.standing or 8
    local currentStanding = factionProgress.standingId or 4
    local isObtainable = isNonRepItem or currentStanding >= reqStanding

    -- Faction/Source text
    if isNonRepItem then
        -- Non-rep item - show source instead of faction
        card.factionText:SetText(itemData.source or "Available")
        card.factionText:SetTextColor(0.6, 0.8, 1)  -- Light blue for non-rep sources
    else
        -- Rep-based item
        card.factionText:SetText((itemData.faction or "Unknown") .. " @ " .. (standingNames[reqStanding] or "Unknown"))
        if isObtainable then
            card.factionText:SetTextColor(0, 1, 0)
        else
            card.factionText:SetTextColor(1, 0.6, 0)
        end
    end

    -- Status badge
    if isNonRepItem then
        card.statusBadge:SetText("|cFF88CCFFAVAILABLE|r")
    elseif isObtainable then
        card.statusBadge:SetText("|cFF00FF00BUY NOW|r")
    else
        local totalNeeded = Components:GetTotalRepForStanding(reqStanding)
        local totalEarned = Components:GetTotalRepForStanding(currentStanding)
        if factionProgress.max and factionProgress.max > 0 then
            totalEarned = totalEarned + factionProgress.current
        end
        local progress = totalNeeded > 0 and math.floor((totalEarned / totalNeeded) * 100) or 0
        card.statusBadge:SetText(progress .. "%")
        card.statusBadge:SetTextColor(1, 0.8, 0)
    end

    -- Progress bar (only for rep items)
    local ICON_SIZE = 32
    local barWidth = card:GetWidth() - ICON_SIZE - 60

    if isNonRepItem then
        -- No progress bar for non-rep items - use standing label for source type
        if card.progressBar then
            card.progressBar:Hide()
        end
        card.standingLabel:ClearAllPoints()
        card.standingLabel:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", ICON_SIZE + 20, 10)
        -- Show source type (dungeon/badge/crafted)
        local sourceType = itemData.sourceType or "item"
        local sourceTypeLabels = {
            dungeon = "Dungeon Drop",
            badge = "Badge Vendor",
            crafted = "Crafted",
            quest = "Quest Reward",
        }
        card.standingLabel:SetText(sourceTypeLabels[sourceType] or sourceType)
        card.standingLabel:SetTextColor(0.6, 0.8, 1)
    else
        -- Rep item - show progress bar
        local progressBar = Components:CreateProgressBar(card, barWidth, 10)
        progressBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", ICON_SIZE + 20, 8)
        card.progressBar = progressBar

        -- Set progress
        local progress = 0
        if factionProgress.max and factionProgress.max > 0 then
            progress = factionProgress.current / factionProgress.max
        end
        progressBar:SetProgress(progress)

        -- Standing label
        card.standingLabel:ClearAllPoints()
        card.standingLabel:SetPoint("LEFT", progressBar, "RIGHT", 6, 0)
        card.standingLabel:SetText(factionProgress.standingName or "Neutral")
        card.standingLabel:SetTextColor(0.7, 0.7, 0.7)
    end

    -- Grey out icon if not obtainable
    if not isObtainable then
        card.icon:SetDesaturated(true)
        card.icon:SetVertexColor(0.7, 0.7, 0.7)
    end

    -- Tooltip - use the Armory tooltip system for proper item display and hoverData
    card:SetScript("OnEnter", function(self)
        -- Use BuildArmoryGearTooltip for consistent tooltip display with proper item link format
        Journal:BuildArmoryGearTooltip(self.itemData, self)

        -- Add rep-specific status after the hoverData sections
        GameTooltip:AddLine(" ")
        if isNonRepItem then
            GameTooltip:AddLine("Source: " .. (itemData.source or "Unknown"), 0.6, 0.8, 1)
            GameTooltip:AddLine("Status: Available", 0, 1, 0)
        elseif isObtainable then
            GameTooltip:AddLine("Status: Available for purchase!", 0, 1, 0)
        else
            GameTooltip:AddLine("Status: Requires " .. (standingNames[reqStanding] or "Unknown"), 1, 0.5, 0)
        end
        GameTooltip:Show()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return card
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
        local milestones = HopeAddon.charDb and HopeAddon.charDb.journal
            and HopeAddon.charDb.journal.levelMilestones
        if milestones then
            for _ in pairs(milestones) do
                milestoneCount = milestoneCount + 1
            end
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

    -- Cleanup when hidden (close dropdowns, clear search focus)
    frame:SetScript("OnHide", function()
        CloseDropDownMenus()
        if Journal.socialToolbar and Journal.socialToolbar.searchBox then
            Journal.socialToolbar.searchBox:ClearFocus()
        end
        if Journal.rumorInputFrame then
            Journal.rumorInputFrame:Hide()
        end
    end)

    -- Title
    local titleBar = Components:CreateTitleBar(frame, "HOPE IS HERE", "ARCANE_PURPLE")

    -- Character info display
    local charInfo = frame:CreateFontString(nil, "OVERLAY")
    charInfo:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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
        { id = "attunements", label = "Attunements", tooltip = "Raid attunement quest chains" },
        { id = "reputation", label = "Reputation", tooltip = "Faction standings by category" },
        { id = "raids", label = "Raids", tooltip = "Boss kill tracking by tier (T4/T5/T6)" },
        { id = "games", label = "Games", tooltip = "Minigames and challenges", color = "ARCANE_PURPLE" },
        { id = "social", label = "Social", tooltip = "Fellow travelers directory", color = "FEL_GREEN" },
        { id = "armory", label = "Armory", tooltip = "Gear upgrade advisor by role", color = "HELLFIRE_RED" },
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
    footer:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 25)
    footer:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
    frame.footer = footer

    -- Author credit box (bottom-right)
    local authorBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    authorBox:SetSize(155, 24)
    authorBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 18)
    authorBox:SetBackdrop(HopeAddon.Constants.BACKDROPS.TOOLTIP_SMALL)
    authorBox:SetBackdropColor(0.05, 0.05, 0.08, 0.85)
    authorBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)

    local authorCredit = authorBox:CreateFontString(nil, "OVERLAY")
    authorCredit:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")  -- FRIZQT - WoW's most readable font
    authorCredit:SetPoint("CENTER", authorBox, "CENTER", 0, 0)
    -- Rainbow gradient for "PhilFestive": P-h-i-l-F-e-s-t-i-v-e
    local rainbowName = "|cFFFF0000P|r|cFFFF5500h|r|cFFFFAA00i|r|cFFFFFF00l|r|cFFAAFF00F|r|cFF00FF00e|r|cFF00FFAAs|r|cFF00AAFFt|r|cFF0055FFi|r|cFF5500FFv|r|cFFAA00FFe|r"
    authorCredit:SetText("Inscribed by " .. rainbowName)
    frame.authorBox = authorBox
    frame.authorCredit = authorCredit

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

    -- CRITICAL: Close any open dropdown menus to prevent input capture lockup
    -- WoW's UIDropDownMenu creates an invisible frame that captures ALL mouse input
    CloseDropDownMenus()

    -- Clear any focused edit boxes (search box, rumor input, etc.)
    if self.socialToolbar and self.socialToolbar.searchBox then
        self.socialToolbar.searchBox:ClearFocus()
    end

    -- Hide/cleanup Social tab dropdowns when leaving
    if self.currentTab == "social" and self.socialDropdowns then
        for _, dropdown in pairs(self.socialDropdowns) do
            if dropdown and dropdown.Hide then
                dropdown:Hide()
            end
        end
        -- Clear the tracking table
        wipe(self.socialDropdowns)
    end

    self.isTabAnimating = true
    self.currentTab = tabId

    -- Update tab visuals
    for id, tab in pairs(self.mainFrame.tabs) do
        tab:SetSelected(id == tabId)
    end

    -- Stop any active glow effects before clearing content to prevent memory leaks
    if HopeAddon.Effects then
        HopeAddon.Effects:StopAllGlows()
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

    -- 3. Destroy Social tab containers (these are not pooled due to complexity)
    self:CleanupSocialContainers(true)

    -- 4. Hide Armory tab containers (reused, not destroyed)
    self:HideArmoryTab()

    -- 5. Clear and repopulate content (pass containerPool for pooled frame release)
    -- Skip for armory tab - it uses fixed layout in contentArea, not scrollContainer
    if tabId ~= "armory" then
        self.mainFrame.scrollContainer:ClearEntries(self.containerPool)
    end

    -- Migration: old "directory" tab now split into "games" and "social"
    if tabId == "directory" then
        tabId = "games"
        self.currentTab = tabId
    end

    -- Migration: old "stats" tab removed, redirect to raids for boss tracking
    if tabId == "stats" then
        tabId = "raids"
        self.currentTab = tabId
    end

    -- Migration: "transmog" tab removed, redirect to armory
    if tabId == "transmog" then
        tabId = "armory"
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
    elseif tabId == "armory" then
        local success, err = pcall(function()
            self:PopulateArmory()
        end)
        if not success then
            HopeAddon:Print("|cFFFF0000Armory Tab Error:|r " .. tostring(err))
            -- Show error in UI for debugging (use contentArea since armory uses fixed layout)
            local contentArea = self.mainFrame.contentArea
            if contentArea then
                local errorFrame = CreateFrame("Frame", nil, contentArea)
                errorFrame:SetSize(contentArea:GetWidth() - 20, 100)
                errorFrame:SetPoint("TOP", contentArea, "TOP", 0, -20)
                local errorText = errorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                errorText:SetPoint("CENTER")
                errorText:SetText("|cFFFF0000Error loading Armory:|r\n\n" .. tostring(err))
                errorText:SetJustifyH("CENTER")
                errorFrame:Show()
            end
        end
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
    local stats = HopeAddon.charDb and HopeAddon.charDb.stats
    local entries = HopeAddon.charDb and HopeAddon.charDb.journal
        and HopeAddon.charDb.journal.entries
    local entryCount = entries and #entries or 0
    local counts = self:GetCachedCounts()
    local deathTotal = stats and stats.deaths and stats.deaths.total or 0

    self.mainFrame.footer:SetText(string.format(
        "Journal Entries: %d | Milestones: %d | Deaths: %d",
        entryCount, counts.milestones, deathTotal
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
    title:SetFont(HopeAddon.assets.fonts.TITLE, 24, "")
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
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
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
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
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
                card.tierName:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
                card.tierName:SetPoint("TOP", card, "TOP", 0, -8)

                -- Status text
                card.statusText = card:CreateFontString(nil, "OVERLAY")
                card.statusText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
                card.statusText:SetPoint("TOP", card.tierName, "BOTTOM", 0, -2)

                -- Progress text
                card.progressText = card:CreateFontString(nil, "OVERLAY")
                card.progressText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
                card.progressText:SetPoint("TOP", card.statusText, "BOTTOM", 0, -8)

                -- Raid list
                card.raidList = card:CreateFontString(nil, "OVERLAY")
                card.raidList:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
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
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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
    focusTitle:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    focusTitle:ClearAllPoints()
    focusTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -25)
    focusTitle:SetText(HopeAddon:ColorText(focus.title, "FEL_GREEN"))

    -- Focus subtitle
    local focusSubtitle = container.focusSubtitle
    if not focusSubtitle then
        focusSubtitle = container:CreateFontString(nil, "OVERLAY")
        container.focusSubtitle = focusSubtitle
    end
    focusSubtitle:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
        itemText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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
        itemText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
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
    sectionTitle:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    sectionTitle:ClearAllPoints()
    sectionTitle:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -8)
    local gearScoreText = HopeAddon:GetGearScoreText()
    sectionTitle:SetText("|cFF" .. hexColor .. string.upper(className) .. " - " .. specName .. "|r |cFFAAAAAA(" .. gearScoreText .. ")|r")
    sectionTitle:Show()

    local yOffset = -38

    -- Category definitions with colors
    local categories = {
        { key = "rep", title = "Reputation Rewards", color = "ARCANE_PURPLE", icon = "INV_Misc_Token_ArgentDawn" },  -- TBC compatible
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
        section.indicator:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
        section.indicator:SetPoint("LEFT", section.header, "LEFT", 8, 0)

        -- Title
        section.titleText = section.header:CreateFontString(nil, "OVERLAY")
        section.titleText:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
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
        card.sourceText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
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
        card.itemName:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        card.itemName:SetPoint("TOPLEFT", card.itemIcon, "TOPRIGHT", 8, 0)

        -- Slot text
        card.slotText = card:CreateFontString(nil, "OVERLAY")
        card.slotText:SetFont(HopeAddon.assets.fonts.SMALL, 8, "")
        card.slotText:SetPoint("TOPLEFT", card.itemName, "BOTTOMLEFT", 0, -1)
        card.slotText:SetTextColor(0.7, 0.7, 0.7)

        -- Stats text
        card.statsText = card:CreateFontString(nil, "OVERLAY")
        card.statsText:SetFont(HopeAddon.assets.fonts.SMALL, 8, "")
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
        card.progressText:SetFont(HopeAddon.assets.fonts.SMALL, 8, "")
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
    local result = { phase = "ENDGAME", title = "Legend of Outland", subtitle = "All attunements complete!", story = "You have conquered all of Outland's challenges.", icon = "Interface\\Icons\\INV_Weapon_Glaive_01", progress = { current = 100, total = 100, percentage = 100, label = "Complete" } }
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
    local phaseBadge = container.phaseBadge or container:CreateFontString(nil, "OVERLAY") container.phaseBadge = phaseBadge phaseBadge:SetFont(HopeAddon.assets.fonts.SMALL, 9, "") phaseBadge:ClearAllPoints() phaseBadge:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -8) phaseBadge:SetText(HopeAddon:ColorText(PHASE_NAMES[stepData.phase] or stepData.phase, phaseColor)) phaseBadge:Show()
    local header = container.stepHeader or container:CreateFontString(nil, "OVERLAY") container.stepHeader = header header:SetFont(HopeAddon.assets.fonts.HEADER, 11, "") header:ClearAllPoints() header:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -5) header:SetText(HopeAddon:ColorText("YOUR NEXT STEP", phaseColor)) header:Show()
    local icon = container.stepIcon or container:CreateTexture(nil, "ARTWORK") container.stepIcon = icon icon:SetSize(48, 48) icon:ClearAllPoints() icon:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -25) icon:SetTexture(stepData.icon or "Interface\\Icons\\INV_Misc_QuestionMark") icon:Show()
    local title = container.stepTitle or container:CreateFontString(nil, "OVERLAY") container.stepTitle = title title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "") title:ClearAllPoints() title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2) title:SetText(HopeAddon:ColorText(stepData.title, "BRIGHT_WHITE")) title:Show()
    local subtitle = container.stepSubtitle or container:CreateFontString(nil, "OVERLAY") container.stepSubtitle = subtitle subtitle:SetFont(HopeAddon.assets.fonts.BODY, 11, "") subtitle:ClearAllPoints() subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2) subtitle:SetText(HopeAddon:ColorText(stepData.subtitle, "SUBTLE")) subtitle:Show()
    local story = container.stepStory or container:CreateFontString(nil, "OVERLAY") container.stepStory = story story:SetFont(HopeAddon.assets.fonts.BODY, 10, "") story:ClearAllPoints() story:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -80) story:SetPoint("RIGHT", container, "RIGHT", -15, 0) story:SetJustifyH("LEFT") story:SetText("|cFFCCCCCC\"" .. (stepData.story or "") .. "\"|r") story:Show()
    local progressBar = container.stepProgressBar if not progressBar then progressBar = CreateFrame("Frame", nil, container, "BackdropTemplate") progressBar:SetSize(CONTAINER_WIDTH - 40, 16) progressBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 }) progressBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8) progressBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) progressBar.fill = progressBar:CreateTexture(nil, "ARTWORK") progressBar.fill:SetPoint("TOPLEFT", 2, -2) progressBar.fill:SetPoint("BOTTOMLEFT", 2, 2) progressBar.label = progressBar:CreateFontString(nil, "OVERLAY") progressBar.label:SetFont(HopeAddon.assets.fonts.SMALL, 9, "") progressBar.label:SetPoint("CENTER", progressBar, "CENTER", 0, 0) container.stepProgressBar = progressBar end
    progressBar:ClearAllPoints() progressBar:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 20, 35) local pct = stepData.progress.percentage or 0 progressBar.fill:SetWidth(math.max(1, (CONTAINER_WIDTH - 44) * (pct / 100))) progressBar.fill:SetColorTexture(c.r, c.g, c.b, 0.8) progressBar.label:SetText(stepData.progress.label or (pct .. "%")) progressBar:Show()
    local nextPreview = container.stepNextPreview or container:CreateFontString(nil, "OVERLAY") container.stepNextPreview = nextPreview nextPreview:SetFont(HopeAddon.assets.fonts.SMALL, 9, "") nextPreview:ClearAllPoints() nextPreview:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 20, 12) nextPreview:SetText("") nextPreview:Show()
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
    header:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 16, "")
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -12)
    title:SetText(HopeAddon:ColorText("JOURNEY TO OUTLAND", "GOLD_BRIGHT"))

    -- Level display
    local levelText = container.pre60Level
    if not levelText then
        levelText = container:CreateFontString(nil, "OVERLAY")
        container.pre60Level = levelText
    end
    levelText:SetFont(HopeAddon.assets.fonts.TITLE, 24, "")
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
    progressLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    progressLabel:ClearAllPoints()
    progressLabel:SetPoint("LEFT", progressBar, "RIGHT", 10, 0)
    progressLabel:SetText(HopeAddon:ColorText(string.format("%d / 60", playerLevel), "GREY"))

    -- Story text
    local storyText = container.pre60Story
    if not storyText then
        storyText = container:CreateFontString(nil, "OVERLAY")
        container.pre60Story = storyText
    end
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    awaitsTitle:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    awaitsTitle:ClearAllPoints()
    awaitsTitle:SetPoint("TOPLEFT", awaitsContainer, "TOPLEFT", 15, -12)
    awaitsTitle:SetText(HopeAddon:ColorText("WHAT AWAITS IN OUTLAND", "ARCANE_PURPLE"))

    -- Bullet points
    local bulletText = awaitsContainer.bulletText
    if not bulletText then
        bulletText = awaitsContainer:CreateFontString(nil, "OVERLAY")
        awaitsContainer.bulletText = bulletText
    end
    bulletText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -12)
    title:SetText(HopeAddon:ColorText("YOUR JOURNEY", "GOLD_BRIGHT"))

    -- Level display
    local levelText = container.levelText
    if not levelText then
        levelText = container:CreateFontString(nil, "OVERLAY")
        container.levelText = levelText
    end
    levelText:SetFont(HopeAddon.assets.fonts.TITLE, 24, "")
    levelText:ClearAllPoints()
    levelText:SetPoint("LEFT", title, "RIGHT", 15, 0)
    levelText:SetText(HopeAddon:ColorText("Level " .. playerLevel, "FEL_GREEN"))

    -- Range label
    local rangeLabel = container.rangeLabel
    if not rangeLabel then
        rangeLabel = container:CreateFontString(nil, "OVERLAY")
        container.rangeLabel = rangeLabel
    end
    rangeLabel:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -10)
    title:SetText(HopeAddon:ColorText("GEAR FOR YOUR JOURNEY", "GOLD_BRIGHT"))

    -- Spec/role info
    local specInfo = container.specInfo
    if not specInfo then
        specInfo = container:CreateFontString(nil, "OVERLAY")
        container.specInfo = specInfo
    end
    specInfo:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    specInfo:ClearAllPoints()
    specInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    local roleName = roleInfo and roleInfo.name or "DPS"
    local gearScoreText = HopeAddon:GetGearScoreText()
    specInfo:SetText("|cFF" .. hexColor .. specName .. "|r |cFFAAAAAA(" .. gearScoreText .. ")|r - |cFF" .. roleHex .. roleName .. "|r")

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
    headerTitle:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
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
        card.itemName:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        card.itemName:SetPoint("TOPLEFT", card.itemIcon, "TOPRIGHT", 10, -2)

        -- Slot text
        card.slotText = card:CreateFontString(nil, "OVERLAY")
        card.slotText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
        card.slotText:SetPoint("TOPLEFT", card.itemName, "BOTTOMLEFT", 0, -2)

        -- Stats text
        card.statsText = card:CreateFontString(nil, "OVERLAY")
        card.statsText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
        card.statsText:SetPoint("TOPLEFT", card.slotText, "BOTTOMLEFT", 0, -2)

        -- Source text
        card.sourceText = card:CreateFontString(nil, "OVERLAY")
        card.sourceText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
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
    title:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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
        entry:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
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
    title:SetFont(HopeAddon.assets.fonts.TITLE, 22, "")
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
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 13, "")
    subtitle:ClearAllPoints()
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetText("The Journey of " .. playerName)
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
    progressText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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

    -- Add recommended upgrades section at top (spec-specific rep items)
    self:CreateRecommendedUpgradesSection()

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

--[[
    CreateRecommendedUpgradesSection - Shows spec-appropriate rep items sorted by obtainability
    Displays at top of Reputation tab, before faction categories
]]
function Journal:CreateRecommendedUpgradesSection()
    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local Reputation = HopeAddon:GetModule("Reputation")
    local Data = HopeAddon.ReputationData

    -- Get player spec info
    local _, classToken = UnitClass("player")
    local specName, specTab = HopeAddon:GetPlayerSpec()
    if not specTab or specTab < 1 then specTab = 1 end

    -- Get rep items for this spec
    local classData = C.CLASS_SPEC_LOOT_HOTLIST and C.CLASS_SPEC_LOOT_HOTLIST[classToken]
    if not classData then return end

    local specData = classData[specTab]
    if not specData or not specData.rep or #specData.rep == 0 then return end

    -- Build items with faction progress data
    local items = {}
    for _, item in ipairs(specData.rep) do
        local standingId = 4  -- Default neutral
        local standingName = "Neutral"
        local current, max = 0, 0
        local isObtainable = false
        local priority = 0
        local isNonRepItem = not item.faction  -- Track if this is a non-rep item

        if item.faction then
            -- Rep-based item - calculate faction progress
            if Reputation then
                local cached = Reputation:GetFactionStanding(item.faction)
                if cached then
                    standingId = cached.standingId or 4
                end
                local curr, mx, _ = Reputation:GetProgressInStanding(item.faction)
                if curr then current = curr end
                if mx then max = mx end

                -- Get standing name
                if Data then
                    local standingInfo = Data:GetStandingInfo(standingId)
                    standingName = standingInfo and standingInfo.name or "Unknown"
                end
            end

            local requiredStanding = item.standing or 8
            isObtainable = standingId >= requiredStanding

            -- Calculate priority (lower = show first)
            -- Obtainable items first, then sort by how close to requirement
            if isObtainable then
                priority = 0  -- Already obtainable - top priority
            else
                -- Closer to requirement = lower priority number
                priority = (requiredStanding - standingId) * 1000 - current
            end
        else
            -- Non-rep item (dungeon/badge/crafted) - always available
            standingId = 8  -- Treat as max standing for display
            standingName = item.source or "Available"
            isObtainable = true
            priority = 1  -- Show after obtainable rep items
        end

        table.insert(items, {
            item = item,
            factionProgress = {
                standingId = standingId,
                standingName = standingName,
                current = current,
                max = max,
                isNonRepItem = isNonRepItem,
            },
            isObtainable = isObtainable,
            priority = priority,
        })
    end

    -- Sort by priority (obtainable first, then closest to requirement)
    table.sort(items, function(a, b) return a.priority < b.priority end)

    -- Category header (smaller, under main FACTION STANDING header)
    local headerText = string.format("RECOMMENDED UPGRADES (%s)", specName or "Your Spec")
    local header = self:CreateCategoryHeader(headerText, "GOLD_BRIGHT")
    self.mainFrame.scrollContainer:AddEntry(header)

    -- Create item cards using pool (show all, typically 3)
    for _, itemData in ipairs(items) do
        local card = self:AcquireUpgradeCard(
            self.mainFrame.scrollContainer.content,
            itemData.item,
            itemData.factionProgress
        )
        self.mainFrame.scrollContainer:AddEntry(card)
    end

    -- Spacer before faction categories
    local spacer = self:CreateSpacer(20)
    self.mainFrame.scrollContainer:AddEntry(spacer)
end

-- NOTE: GetBestRepItemForFaction, GetRepItemsByStanding, CreateRepItemLink, and CreateStandingLabel
-- were removed in Reputation tab restructure. Items now displayed via CreateRecommendedUpgradesSection.

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

    -- Create card - simplified height (no segmented bar with icons)
    local cardHeight = 85

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
    local notStarted = not info.isSpecial and standingId <= 4 and current == 0 and (max == 0 or max == nil)
    if notStarted then
        card:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        card.defaultBorderColor = {0.4, 0.4, 0.4, 0.8}
    end

    -- Add simple inline progress bar and standing badge for regular factions
    if not info.isSpecial and info.data then
        -- Reuse timestamp slot for standing badge (top right)
        card.timestamp:ClearAllPoints()
        card.timestamp:SetFont(HopeAddon.assets.fonts.BODY, 10, "OUTLINE")
        card.timestamp:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
        card.timestamp:SetText(standingName)
        card.timestamp:SetTextColor(r, g, b)

        -- Progress percentage (below badge) - reuse or create once
        local progressPct = 0
        if max and max > 0 then
            progressPct = math.floor((current / max) * 100)
        end

        if not card.standingProgress then
            card.standingProgress = card:CreateFontString(nil, "OVERLAY")
        end
        card.standingProgress:ClearAllPoints()
        card.standingProgress:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
        card.standingProgress:SetPoint("TOP", card.timestamp, "BOTTOM", 0, -2)
        card.standingProgress:SetText(progressPct .. "%")
        card.standingProgress:SetTextColor(0.7, 0.7, 0.7)
        card.standingProgress:Show()

        -- Simple progress bar at bottom
        local barWidth = card:GetWidth() - Components.ICON_SIZE_STANDARD - 60
        local progressBar = Components:CreateProgressBar(card, barWidth, 8)
        progressBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",
            Components.ICON_SIZE_STANDARD + 2 * Components.MARGIN_NORMAL, 8)

        -- Set progress bar color based on standing
        if progressBar.fill then
            progressBar.fill:SetVertexColor(r, g, b)
        end

        -- Calculate progress (0-1)
        local progress = 0
        if max and max > 0 then
            progress = current / max
        end
        progressBar:SetProgress(progress)

        card.reputationBar = progressBar
    end

    -- Add golden glow for Exalted
    if standingId == 8 then
        Effects:CreatePulsingGlow(card, "GOLD_BRIGHT", 0.3)
    end

    return card
end

function Journal:PopulateAttunements()
    local Components = HopeAddon.Components
    local scrollContainer = self.mainFrame.scrollContainer

    -- Header - properly added to scroll
    local header = self:CreateSectionHeader("RAID ATTUNEMENTS", "GOLD_BRIGHT", "Your path through TBC raid content")
    scrollContainer:AddEntry(header)

    -- Phase filter bar
    self:CreateAttunementsPhaseBar()

    -- Content based on selected phase
    self:PopulateAttunementsContent()

    self:UpdateFooter()
end

--[[
    Create the phase selection bar for Attunements tab
    Shows [All] [1] [2] [3] buttons for filtering by phase
]]
function Journal:CreateAttunementsPhaseBar()
    local scrollContainer = self.mainFrame.scrollContainer
    local C = HopeAddon.Constants.ATTUNEMENT_PHASE_BAR

    -- Create phase bar container
    local phaseBarContainer = self:AcquireContainer(scrollContainer.content, C.HEIGHT + 5)

    if not self.attunementsUI.phaseBar then
        local phaseBar = CreateFrame("Frame", "HopeAttunementsPhaseBar", phaseBarContainer, "BackdropTemplate")
        phaseBar:SetHeight(C.HEIGHT)
        phaseBar:SetPoint("TOPLEFT", phaseBarContainer, "TOPLEFT", 0, 0)
        phaseBar:SetPoint("TOPRIGHT", phaseBarContainer, "TOPRIGHT", 0, 0)
        phaseBar:SetBackdrop(C.BACKDROP)
        phaseBar:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        phaseBar:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        -- "PHASE" label
        local label = phaseBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", phaseBar, "LEFT", C.PADDING_H, 0)
        label:SetText(C.LABEL_TEXT)
        label:SetTextColor(0.7, 0.7, 0.7, 1)
        phaseBar.label = label

        self.attunementsUI.phaseBar = phaseBar
        self.attunementsUI.phaseButtons = {}
    end

    local phaseBar = self.attunementsUI.phaseBar
    phaseBar:SetParent(phaseBarContainer)
    phaseBar:ClearAllPoints()
    phaseBar:SetPoint("TOPLEFT", phaseBarContainer, "TOPLEFT", 0, 0)
    phaseBar:SetPoint("TOPRIGHT", phaseBarContainer, "TOPRIGHT", 0, 0)
    phaseBar:Show()

    -- Create phase buttons
    self:CreateAttunementsPhaseButtons()

    scrollContainer:AddEntry(phaseBarContainer)
end

--[[
    Create the phase selection buttons for Attunements tab
    Buttons: [All] [1] [2] [3]
]]
function Journal:CreateAttunementsPhaseButtons()
    local phaseBar = self.attunementsUI.phaseBar
    local C = HopeAddon.Constants.ATTUNEMENT_PHASE_BUTTON

    -- Phases to show: 0 (All), 1, 2, 3
    local phasesToShow = { 0, 1, 2, 3 }

    for buttonIndex, phase in ipairs(phasesToShow) do
        local phaseConfig = C.PHASES[phase]

        if not self.attunementsUI.phaseButtons[phase] then
            local btn = CreateFrame("Button", "HopeAttunementsPhase" .. phase .. "Button", phaseBar, "BackdropTemplate")
            local btnWidth = (phase == 0) and (C.WIDTH + 8) or C.WIDTH  -- "All" button slightly wider
            btn:SetSize(btnWidth, C.HEIGHT)

            -- Position: left to right after "PHASE" label with gaps
            local xOffset = C.FIRST_OFFSET + (buttonIndex - 1) * (C.WIDTH + C.GAP + 2)
            btn:SetPoint("LEFT", phaseBar, "LEFT", xOffset, 0)

            -- Backdrop
            btn:SetBackdrop({
                bgFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })

            -- Text: Phase label ("All", "1", "2", "3")
            local label = btn:CreateFontString(nil, "OVERLAY", C.FONT)
            label:SetPoint("CENTER", btn, "CENTER", 0, 0)
            label:SetText(phaseConfig.label)
            btn.label = label

            -- Glow texture (for active state)
            local glow = btn:CreateTexture(nil, "OVERLAY")
            glow:SetPoint("CENTER", btn, "CENTER", 0, 0)
            glow:SetSize(btnWidth + 8, C.HEIGHT + 8)
            glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
            glow:SetBlendMode("ADD")
            glow:SetAlpha(0.5)
            glow:Hide()
            btn.glow = glow

            -- Store phase reference
            btn.phase = phase
            btn.phaseColor = HopeAddon.colors[phaseConfig.color]

            -- Click handler
            btn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                self:SelectAttunementsPhase(phase)
            end)

            -- Hover handlers with tooltip
            btn:SetScript("OnEnter", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
                self:SetAttunementsPhaseButtonState(btn, "hover")
                GameTooltip:SetOwner(btn, "ANCHOR_BOTTOM")
                GameTooltip:SetText(phaseConfig.tooltip, 1, 0.84, 0)

                -- Show attunements in this phase
                if phaseConfig.attunements and #phaseConfig.attunements > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Attunements:", 0.2, 0.8, 0.2)
                    for _, attKey in ipairs(phaseConfig.attunements) do
                        local attName = attKey
                        if attKey == "cipher" then
                            attName = "Cipher of Damnation (TK Prereq)"
                        elseif attKey == "karazhan" then
                            attName = "The Master's Key (Karazhan)"
                        elseif attKey == "ssc" then
                            attName = "Hand of A'dal (SSC)"
                        elseif attKey == "tk" then
                            attName = "The Tempest Key (TK)"
                        elseif attKey == "hyjal" then
                            attName = "Battle for Mount Hyjal"
                        elseif attKey == "bt" then
                            attName = "Black Temple Attunement"
                        end
                        GameTooltip:AddLine("  - " .. attName, 0.9, 0.9, 0.9)
                    end
                end

                GameTooltip:Show()
            end)

            btn:SetScript("OnLeave", function()
                local state = (self.attunementsState.selectedPhase == phase) and "active" or "inactive"
                self:SetAttunementsPhaseButtonState(btn, state)
                GameTooltip:Hide()
            end)

            self.attunementsUI.phaseButtons[phase] = btn
        end

        -- Set initial state
        local state = (self.attunementsState.selectedPhase == phase) and "active" or "inactive"
        self:SetAttunementsPhaseButtonState(self.attunementsUI.phaseButtons[phase], state)
    end
end

--[[
    Set visual state for attunements phase button
]]
function Journal:SetAttunementsPhaseButtonState(btn, stateName)
    local C = HopeAddon.Constants.ATTUNEMENT_PHASE_BUTTON
    local state = C.STATES[stateName]
    local phaseColor = btn.phaseColor or HopeAddon.colors.ARCANE_PURPLE

    -- Background color (phase color at configured alpha)
    btn:SetBackdropColor(
        phaseColor.r * 0.3,
        phaseColor.g * 0.3,
        phaseColor.b * 0.3,
        state.bgAlpha
    )

    -- Border color
    btn:SetBackdropBorderColor(
        phaseColor.r,
        phaseColor.g,
        phaseColor.b,
        state.borderAlpha
    )

    -- Text color
    btn.label:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b, state.textAlpha)

    -- Glow (for active state)
    if state.showGlow and btn.glow then
        btn.glow:SetVertexColor(phaseColor.r, phaseColor.g, phaseColor.b, 0.5)
        btn.glow:Show()
    elseif btn.glow then
        btn.glow:Hide()
    end
end

--[[
    Select a phase filter for the Attunements tab
    @param phase number - 0 = All, 1-3 = specific phase
]]
function Journal:SelectAttunementsPhase(phase)
    self.attunementsState.selectedPhase = phase

    -- Update all button states
    for p, btn in pairs(self.attunementsUI.phaseButtons) do
        local state = (p == phase) and "active" or "inactive"
        self:SetAttunementsPhaseButtonState(btn, state)
    end

    -- Refresh the attunements list
    self:RefreshAttunementsList()
end

--[[
    Refresh the attunements list (called after phase filter change)
]]
function Journal:RefreshAttunementsList()
    local scrollContainer = self.mainFrame.scrollContainer

    -- Release all pooled frames
    scrollContainer:ClearEntries(self.containerPool)

    -- Repopulate the entire tab
    self:PopulateAttunements()
end

--[[
    Populate attunements content based on selected phase
]]
function Journal:PopulateAttunementsContent()
    local selectedPhase = self.attunementsState.selectedPhase

    if selectedPhase == 0 then
        -- Show all phases grouped with headers
        for phase = 1, 3 do
            self:CreatePhaseGroupHeader(phase)
            self:PopulateAttunementsForPhase(phase)
        end
    else
        -- Show only selected phase
        self:PopulateAttunementsForPhase(selectedPhase)
    end

    -- Always show Heroic Keys at the bottom
    self:PopulateHeroicKeys()
end

--[[
    Create a phase group header divider
    @param phase number - Phase number (1, 2, or 3)
]]
function Journal:CreatePhaseGroupHeader(phase)
    local Components = HopeAddon.Components
    local C = HopeAddon.Constants.ATTUNEMENT_PHASE_BUTTON
    local scrollContainer = self.mainFrame.scrollContainer

    local phaseConfig = C.PHASES[phase]
    local phaseColor = phaseConfig.color

    -- Spacer before header
    local spacer = self:CreateSpacer(10)
    scrollContainer:AddEntry(spacer)

    -- Divider line with phase color
    local divider = Components:CreateDivider(scrollContainer.content, phaseColor)
    scrollContainer:AddEntry(divider)

    -- Phase header
    local headerContainer = self:AcquireContainer(scrollContainer.content, 25)
    local headerText = headerContainer.headerText
    if not headerText then
        headerText = headerContainer:CreateFontString(nil, "OVERLAY")
        headerContainer.headerText = headerText
    end
    headerText:ClearAllPoints()
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    headerText:SetPoint("TOPLEFT", headerContainer, "TOPLEFT", Components.MARGIN_NORMAL, -3)
    headerText:SetText(HopeAddon:ColorText("=== PHASE " .. phase .. " ===", phaseColor))
    scrollContainer:AddEntry(headerContainer)

    -- Spacer after header
    local spacer2 = self:CreateSpacer(5)
    scrollContainer:AddEntry(spacer2)
end

--[[
    Populate attunements for a specific phase
    @param phase number - Phase number (1, 2, or 3)
]]
function Journal:PopulateAttunementsForPhase(phase)
    local Components = HopeAddon.Components
    local Attunements = HopeAddon.Attunements
    local C = HopeAddon.Constants
    local scrollContainer = self.mainFrame.scrollContainer

    -- Phase colors
    local phaseColors = {
        [1] = "KARA_PURPLE",
        [2] = "SSC_BLUE",
        [3] = "BT_FEL",
    }
    local phaseColor = phaseColors[phase] or "ARCANE_PURPLE"

    -- In Phase 2, show Cipher of Damnation first (TK prerequisite)
    if phase == 2 then
        self:PopulateCipherSection(phaseColor)
    end

    -- Get attunements for this phase
    local allAttunements = Attunements:GetAllAttunements()

    for _, attunementInfo in ipairs(allAttunements) do
        if attunementInfo.phase == phase then
            local raidKey = attunementInfo.key
            self:PopulateSingleAttunement(raidKey, phaseColor)
        end
    end
end

--[[
    Populate the Cipher of Damnation section (Phase 2 prerequisite for TK)
    @param phaseColor string - Color name to use for the section
]]
function Journal:PopulateCipherSection(phaseColor)
    local Components = HopeAddon.Components
    local Attunements = HopeAddon.Attunements
    local scrollContainer = self.mainFrame.scrollContainer

    -- Cipher header
    local cipherHeaderContainer = self:AcquireContainer(scrollContainer.content, 40)
    local cipherHeader = cipherHeaderContainer.headerText
    if not cipherHeader then
        cipherHeader = cipherHeaderContainer:CreateFontString(nil, "OVERLAY")
        cipherHeaderContainer.headerText = cipherHeader
    end
    cipherHeader:ClearAllPoints()
    cipherHeader:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    cipherHeader:SetPoint("TOPLEFT", cipherHeaderContainer, "TOPLEFT", Components.MARGIN_NORMAL, -3)
    cipherHeader:SetText(HopeAddon:ColorText("[PREREQ] Cipher of Damnation", phaseColor))

    local cipherSubHeader = cipherHeaderContainer.subText
    if not cipherSubHeader then
        cipherSubHeader = cipherHeaderContainer:CreateFontString(nil, "OVERLAY")
        cipherHeaderContainer.subText = cipherSubHeader
    end
    cipherSubHeader:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    cipherSubHeader:ClearAllPoints()
    cipherSubHeader:SetPoint("TOPLEFT", cipherHeader, "BOTTOMLEFT", 0, -3)
    cipherSubHeader:SetText("Required before starting Tempest Key attunement")
    cipherSubHeader:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))
    scrollContainer:AddEntry(cipherHeaderContainer)

    -- Progress bar container
    local progressContainer = self:AcquireContainer(scrollContainer.content, 25)
    local cipherSummary = Attunements:GetSummary("cipher")
    local cipherProgressBar = Components:CreateProgressBar(
        progressContainer,
        scrollContainer.content:GetWidth() - 30,
        18,
        cipherSummary.isAttuned and "FEL_GREEN" or phaseColor
    )
    cipherProgressBar:SetPoint("TOP", progressContainer, "TOP", 0, -2)
    cipherProgressBar:SetProgress(cipherSummary.percentage)
    cipherProgressBar.text:Hide()

    local cipherProgressText = cipherProgressBar:CreateFontString(nil, "OVERLAY")
    cipherProgressText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    cipherProgressText:SetPoint("CENTER", cipherProgressBar, "CENTER", 0, 0)
    cipherProgressText:SetText(string.format("%d/%d (%d%%)",
        cipherSummary.completedChapters, cipherSummary.totalChapters, cipherSummary.percentage))
    cipherProgressText:SetTextColor(1, 1, 1, 1)

    if cipherSummary.isAttuned then
        HopeAddon.Effects:CreatePulsingGlow(cipherProgressBar, "GOLD_BRIGHT", 0.4)
    end

    scrollContainer:AddEntry(progressContainer)

    -- Spacer after cipher
    local spacer = self:CreateSpacer(15)
    scrollContainer:AddEntry(spacer)
end

--[[
    Populate a single attunement chain
    @param raidKey string - Raid key (e.g., "karazhan", "ssc")
    @param phaseColor string - Color name to use for the section
]]
function Journal:PopulateSingleAttunement(raidKey, phaseColor)
    local Components = HopeAddon.Components
    local Attunements = HopeAddon.Attunements
    local C = HopeAddon.Constants
    local scrollContainer = self.mainFrame.scrollContainer

    local summary = Attunements:GetSummary(raidKey)
    local attunementData = Attunements:GetAttunementData(raidKey)
    if not attunementData then return end

    local attunementInfo = nil
    for _, info in ipairs(C.ALL_ATTUNEMENTS) do
        if info.key == raidKey then
            attunementInfo = info
            break
        end
    end
    local attunementPhase = attunementInfo and attunementInfo.phase or 1

    -- Attunement section header
    local headerContainer = self:AcquireContainer(scrollContainer.content, 25)
    local raidHeader = headerContainer.headerText
    if not raidHeader then
        raidHeader = headerContainer:CreateFontString(nil, "OVERLAY")
        headerContainer.headerText = raidHeader
    end
    raidHeader:ClearAllPoints()
    raidHeader:SetFont(HopeAddon.assets.fonts.HEADER, 13, "")
    raidHeader:SetPoint("TOPLEFT", headerContainer, "TOPLEFT", Components.MARGIN_NORMAL, -3)
    raidHeader:SetText(HopeAddon:ColorText(
        string.format("[P%d] %s", attunementPhase, summary.raidName),
        phaseColor
    ))
    scrollContainer:AddEntry(headerContainer)

    -- Sub-title with attunement chain name
    local chainContainer = self:AcquireContainer(scrollContainer.content, 18)
    local chainName = chainContainer.headerText
    if not chainName then
        chainName = chainContainer:CreateFontString(nil, "OVERLAY")
        chainContainer.headerText = chainName
    end
    chainName:ClearAllPoints()
    chainName:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    chainName:SetPoint("TOPLEFT", chainContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
    chainName:SetText(summary.name)
    chainName:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    scrollContainer:AddEntry(chainContainer)

    -- Show level requirements
    if attunementData.minLevel or attunementData.recommendedLevel then
        local levelContainer = self:AcquireContainer(scrollContainer.content, 15)
        local levelText = levelContainer.headerText
        if not levelText then
            levelText = levelContainer:CreateFontString(nil, "OVERLAY")
            levelContainer.headerText = levelText
        end
        levelText:ClearAllPoints()
        levelText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        levelText:SetPoint("TOPLEFT", levelContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)

        local levelStr = ""
        if attunementData.minLevel then
            levelStr = "Minimum Level: " .. attunementData.minLevel
        end
        if attunementData.recommendedLevel then
            if levelStr ~= "" then levelStr = levelStr .. " | " end
            levelStr = levelStr .. "Recommended: " .. attunementData.recommendedLevel
        end
        levelText:SetText(HopeAddon:ColorText(levelStr, "GOLD_BRIGHT"))
        scrollContainer:AddEntry(levelContainer)
    end

    -- Show detailed prerequisites (keys, reputation, etc.)
    if attunementData.prerequisites and #attunementData.prerequisites > 0 then
        local prereqHeader = self:AcquireContainer(scrollContainer.content, 16)
        local prereqHeaderText = prereqHeader.headerText
        if not prereqHeaderText then
            prereqHeaderText = prereqHeader:CreateFontString(nil, "OVERLAY")
            prereqHeader.headerText = prereqHeaderText
        end
        prereqHeaderText:ClearAllPoints()
        prereqHeaderText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        prereqHeaderText:SetPoint("TOPLEFT", prereqHeader, "TOPLEFT", Components.MARGIN_NORMAL, -2)
        prereqHeaderText:SetText(HopeAddon:ColorText("Prerequisites:", phaseColor))
        scrollContainer:AddEntry(prereqHeader)

        for _, prereq in ipairs(attunementData.prerequisites) do
            local prereqItem = self:AcquireContainer(scrollContainer.content, 14)
            local prereqItemText = prereqItem.headerText
            if not prereqItemText then
                prereqItemText = prereqItem:CreateFontString(nil, "OVERLAY")
                prereqItem.headerText = prereqItemText
            end
            prereqItemText:ClearAllPoints()
            prereqItemText:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
            prereqItemText:SetPoint("TOPLEFT", prereqItem, "TOPLEFT", Components.MARGIN_NORMAL + 10, -1)

            local prereqStr = "  - " .. prereq.name
            if prereq.source then
                prereqStr = prereqStr .. " - " .. prereq.source
            end
            prereqItemText:SetText(prereqStr)
            local bronzeColor = HopeAddon.colors.BRONZE or { r = 0.9, g = 0.7, b = 0.5 }
            prereqItemText:SetTextColor(bronzeColor.r, bronzeColor.g, bronzeColor.b, 1)
            prereqItemText:SetWidth(scrollContainer.content:GetWidth() - 50)
            prereqItemText:SetWordWrap(true)
            scrollContainer:AddEntry(prereqItem)
        end
    end

    -- Show prerequisite if any (legacy single prerequisite)
    if summary.prerequisite and not (attunementData.prerequisites and #attunementData.prerequisites > 0) then
        local prereqContainer = self:AcquireContainer(scrollContainer.content, 15)
        local prereqText = prereqContainer.headerText
        if not prereqText then
            prereqText = prereqContainer:CreateFontString(nil, "OVERLAY")
            prereqContainer.headerText = prereqText
        end
        prereqText:ClearAllPoints()
        prereqText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
        prereqText:SetPoint("TOPLEFT", prereqContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
        prereqText:SetText("Requires: " .. summary.prerequisite)
        local orangeColor = HopeAddon.colors.HELLFIRE_ORANGE or { r = 1, g = 0.5, b = 0.3 }
        prereqText:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b, 1)
        scrollContainer:AddEntry(prereqContainer)
    end

    -- Progress bar container
    local progressContainer = self:AcquireContainer(scrollContainer.content, 25)
    local progressBar = Components:CreateProgressBar(
        progressContainer,
        scrollContainer.content:GetWidth() - 30,
        20,
        summary.isAttuned and "FEL_GREEN" or phaseColor
    )
    progressBar:SetPoint("TOP", progressContainer, "TOP", 0, -2)
    progressBar:SetProgress(summary.percentage)
    progressBar.text:Hide()

    local progressText = progressBar:CreateFontString(nil, "OVERLAY")
    progressText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    progressText:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
    progressText:SetText(string.format("%d/%d Chapters (%d%%)",
        summary.completedChapters, summary.totalChapters, summary.percentage))
    progressText:SetTextColor(1, 1, 1, 1)

    scrollContainer:AddEntry(progressContainer)

    -- Add glow if complete
    if summary.isAttuned then
        HopeAddon.Effects:CreatePulsingGlow(progressBar, "GOLD_BRIGHT", 0.4)

        -- Show title if applicable
        if summary.title then
            local titleContainer = self:AcquireContainer(scrollContainer.content, 18)
            local titleText = titleContainer.headerText
            if not titleText then
                titleText = titleContainer:CreateFontString(nil, "OVERLAY")
                titleContainer.headerText = titleText
            end
            titleText:ClearAllPoints()
            titleText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
            titleText:SetPoint("TOPLEFT", titleContainer, "TOPLEFT", Components.MARGIN_NORMAL, -2)
            titleText:SetText("Title: " .. HopeAddon:ColorText(summary.title, "GOLD_BRIGHT"))
            scrollContainer:AddEntry(titleContainer)
        end
    end

    -- Show chapters
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
            descParts[#descParts + 1] = HopeAddon:ColorText("Raid: " .. chapter.raid, phaseColor)
        end
        if chapter.boss then
            descParts[#descParts + 1] = HopeAddon:ColorText("Boss: " .. chapter.boss, phaseColor)
        end

        -- Add prerequisite (key/rep requirements)
        if chapter.prerequisite then
            descParts[#descParts + 1] = HopeAddon:ColorText("Prerequisite: " .. chapter.prerequisite, phaseColor)
        end

        if chapter.requires and type(chapter.requires) == "string" then
            descParts[#descParts + 1] = HopeAddon:ColorText("Requires: " .. chapter.requires, "BRONZE")
        elseif chapter.requires and type(chapter.requires) == "table" then
            descParts[#descParts + 1] = HopeAddon:ColorText("Requires: " .. table.concat(chapter.requires, ", "), "BRONZE")
        end
        local descText = table.concat(descParts, "\n")

        local card = self:AcquireCard(scrollContainer.content, {
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
                        GameTooltip:AddLine("  - " .. obj, 0.9, 0.9, 0.9, true)
                    end
                end

                -- Show quests
                if self.quests and #self.quests > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Quests:", 1, 0.84, 0)
                    for _, quest in ipairs(self.quests) do
                        GameTooltip:AddLine("  - " .. quest.name, 0.9, 0.9, 0.7, true)
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
                        GameTooltip:AddLine("  - " .. tip, 0.8, 0.8, 0.8, true)
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

        scrollContainer:AddEntry(card)
    end

    -- Spacer between attunements
    local attuneSpacer = self:CreateSpacer(20)
    scrollContainer:AddEntry(attuneSpacer)
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

    -- Header (uses KARA_PURPLE since heroic keys are Phase 1 content)
    local header = self:CreateSectionHeader("HEROIC DUNGEON KEYS", "KARA_PURPLE", "Reputation-gated heroic access")
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
    if not HopeAddon.Constants or not HopeAddon.Constants.RAIDS_BY_PHASE then
        HopeAddon:Debug("ERROR: PopulateRaids - RAIDS_BY_PHASE not loaded")
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
    -- Color name mapping for phases (these are color NAMES, not color tables)
    local phaseColorNames = {
        [1] = "KARA_PURPLE",   -- Phase 1: Karazhan purple
        [2] = "SSC_BLUE",      -- Phase 2: SSC blue
        [3] = "BT_FEL",        -- Phase 3: BT fel green
        [4] = "ZA_TRIBAL",     -- Phase 4: ZA tribal gold
        [5] = "SUNWELL_GOLD",  -- Phase 5: Sunwell gold
    }

    -- Calculate overall raid progress across all phases
    local raidsByPhase = HopeAddon.Constants.RAIDS_BY_PHASE
    local phaseOrder = { 1, 2, 3, 4, 5 }
    local phaseProgress = {}
    local totalKilled, totalBosses = 0, 0

    for _, phase in ipairs(phaseOrder) do
        local raids = raidsByPhase[phase]
        local phaseKilled, phaseTotal = 0, 0
        if raids then
            for _, raidKey in ipairs(raids) do
                local killed, total = RaidData:GetRaidProgress(raidKey)
                phaseKilled = phaseKilled + (killed or 0)
                phaseTotal = phaseTotal + (total or 0)
            end
        end
        phaseProgress[phase] = { killed = phaseKilled, total = phaseTotal }
        totalKilled = totalKilled + phaseKilled
        totalBosses = totalBosses + phaseTotal
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
        overallLabel:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
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

        -- Mini phase progress bars (horizontal layout - 5 narrower bars)
        local miniBarWidth = (containerWidth - 60) / 5
        local miniBarHeight = 12

        for i, phase in ipairs(phaseOrder) do
            local prog = phaseProgress[phase]
            local phasePercent = prog.total > 0 and math.floor((prog.killed / prog.total) * 100) or 0
            local phaseColorName = phaseColorNames[phase]
            local phaseColor = HopeAddon:GetSafeColor(phaseColorName)

            -- Phase label
            local phaseLabel = progressContainer:CreateFontString(nil, "OVERLAY")
            phaseLabel:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
            phaseLabel:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10 + (i-1) * (miniBarWidth + 8), -48)
            phaseLabel:SetText(HopeAddon:ColorText(string.format("P%d: %d/%d", phase, prog.killed, prog.total), phaseColorName))

            -- Mini progress bar
            local miniBar = CreateFrame("StatusBar", nil, progressContainer)
            miniBar:SetSize(miniBarWidth - 8, miniBarHeight)
            miniBar:SetPoint("TOPLEFT", progressContainer, "TOPLEFT", 10 + (i-1) * (miniBarWidth + 8), -62)
            miniBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            miniBar:SetMinMaxValues(0, 100)
            miniBar:SetValue(phasePercent)
            if phaseColor then
                miniBar:SetStatusBarColor(phaseColor.r, phaseColor.g, phaseColor.b)
            end

            -- Mini bar background
            local miniBg = miniBar:CreateTexture(nil, "BACKGROUND")
            miniBg:SetAllPoints()
            miniBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        end

        scrollContainer:AddEntry(progressContainer)
    end
    -- ===== END PROGRESS SUMMARY BAR =====

    -- Quick jump phase buttons
    local jumpBar = self:AcquireContainer(scrollContainer.content, 30)
    self.phaseSections = {}

    local buttonWidth = 45
    local buttonSpacing = 8

    for i, phase in ipairs(phaseOrder) do
        local phaseColorName = phaseColorNames[phase]
        local phaseColor = HopeAddon:GetSafeColor(phaseColorName)
        local buttonLabel = "P" .. phase

        -- Create nav button using component (includes click sound)
        local jumpBtn = Components:CreateNavButton(jumpBar, buttonLabel, buttonWidth, phaseColorName, function()
            if self.phaseSections[phase] then
                local section = self.phaseSections[phase]
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
            if phaseColor then
                GameTooltip:SetText("Jump to Phase " .. phase .. " Raids", phaseColor.r, phaseColor.g, phaseColor.b)
            else
                GameTooltip:SetText("Jump to Phase " .. phase .. " Raids")
            end
            GameTooltip:Show()
        end)
        jumpBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    scrollContainer:AddEntry(jumpBar)

    for _, phase in ipairs(phaseOrder) do
        local phaseColorName = phaseColorNames[phase]
        local raids = raidsByPhase[phase]

        -- Phase header - FontString properly parented to container
        local phaseHeaderContainer = self:AcquireContainer(scrollContainer.content, 30)
        if not phaseHeaderContainer then
            HopeAddon:Debug("ERROR: Failed to acquire container for phase header:", phase)
        else
            local phaseHeader = phaseHeaderContainer.headerText
            if not phaseHeader then
                phaseHeader = phaseHeaderContainer:CreateFontString(nil, "OVERLAY")
                phaseHeaderContainer.headerText = phaseHeader
            end
            phaseHeader:ClearAllPoints()
            phaseHeader:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
            phaseHeader:SetPoint("LEFT", phaseHeaderContainer, "LEFT", Components.MARGIN_SMALL, 0)
            phaseHeader:SetText(HopeAddon:ColorText("--- PHASE " .. phase .. " ---", phaseColorName))
            scrollContainer:AddEntry(phaseHeaderContainer)
            self.phaseSections[phase] = phaseHeaderContainer
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
                    raidIsCleared and "FEL_GREEN" or phaseColorName,
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
                                badge:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
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
                            -- ===== LOOT ICON STRIP =====
                            -- Show up to 4 notable loot icons on the right side of the card
                            local lootItems = boss.notableLoot or {}
                            local maxLootIcons = math.min(4, #lootItems)
                            local LOOT_ICON_SIZE = 20
                            local LOOT_ICON_SPACING = 2
                            local LOOT_STRIP_RIGHT_MARGIN = 8
                            local LOOT_STRIP_TOP_MARGIN = 8

                            -- Create or reuse loot icon container
                            if not card.lootIcons then
                                card.lootIcons = {}
                            end

                            -- Hide all existing loot icons first
                            for _, lootIcon in ipairs(card.lootIcons) do
                                lootIcon:Hide()
                            end

                            -- Create/show loot icons
                            for i = 1, maxLootIcons do
                                local item = lootItems[i]
                                local lootIcon = card.lootIcons[i]

                                if not lootIcon then
                                    -- Create new loot icon frame
                                    lootIcon = CreateFrame("Frame", nil, card)
                                    lootIcon:SetSize(LOOT_ICON_SIZE, LOOT_ICON_SIZE)

                                    -- Icon texture
                                    lootIcon.texture = lootIcon:CreateTexture(nil, "ARTWORK")
                                    lootIcon.texture:SetAllPoints()

                                    -- Quality border
                                    lootIcon.border = lootIcon:CreateTexture(nil, "OVERLAY")
                                    lootIcon.border:SetPoint("TOPLEFT", -1, 1)
                                    lootIcon.border:SetPoint("BOTTOMRIGHT", 1, -1)
                                    lootIcon.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                                    lootIcon.border:SetBlendMode("ADD")

                                    card.lootIcons[i] = lootIcon
                                end

                                -- Position the icon (vertical strip on the right)
                                lootIcon:ClearAllPoints()
                                lootIcon:SetPoint("TOPRIGHT", card, "TOPRIGHT",
                                    -LOOT_STRIP_RIGHT_MARGIN,
                                    -LOOT_STRIP_TOP_MARGIN - (i - 1) * (LOOT_ICON_SIZE + LOOT_ICON_SPACING))

                                -- Get item icon - use generic icon based on type
                                local iconPath = "Interface\\Icons\\INV_Misc_QuestionMark"
                                local itemType = item.type and item.type:lower() or ""

                                -- Map item types to appropriate icons
                                if itemType:find("mount") then
                                    iconPath = "Interface\\Icons\\Ability_Mount_Ridinghorse"
                                elseif itemType:find("legendary") or (itemType:find("bow") and not itemType:find("elbow")) then
                                    iconPath = "Interface\\Icons\\INV_Weapon_Bow_39"
                                elseif itemType:find("trinket") then
                                    iconPath = "Interface\\Icons\\INV_Jewelry_Talisman_07"
                                elseif itemType:find("tier") or itemType:find("token") then
                                    iconPath = "Interface\\Icons\\INV_Chest_Plate16"
                                elseif itemType:find("sword") and itemType:find("2h") then
                                    iconPath = "Interface\\Icons\\INV_Sword_39"
                                elseif itemType:find("axe") and itemType:find("2h") then
                                    iconPath = "Interface\\Icons\\INV_Axe_22"
                                elseif itemType:find("sword") or itemType:find("weapon") then
                                    iconPath = "Interface\\Icons\\INV_Sword_04"
                                elseif itemType:find("axe") then
                                    iconPath = "Interface\\Icons\\INV_Axe_01"
                                elseif itemType:find("mace") then
                                    iconPath = "Interface\\Icons\\INV_Mace_01"
                                elseif itemType:find("dagger") then
                                    iconPath = "Interface\\Icons\\INV_Weapon_ShortBlade_05"
                                elseif itemType:find("staff") then
                                    iconPath = "Interface\\Icons\\INV_Staff_08"
                                elseif itemType:find("shield") then
                                    iconPath = "Interface\\Icons\\INV_Shield_04"
                                elseif itemType:find("helm") or itemType:find("head") then
                                    iconPath = "Interface\\Icons\\INV_Helmet_08"
                                elseif itemType:find("shoulder") then
                                    iconPath = "Interface\\Icons\\INV_Shoulder_02"
                                elseif itemType:find("chest") or itemType:find("robe") then
                                    iconPath = "Interface\\Icons\\INV_Chest_Cloth_17"
                                elseif itemType:find("leg") then
                                    iconPath = "Interface\\Icons\\INV_Pants_06"
                                elseif itemType:find("ring") then
                                    iconPath = "Interface\\Icons\\INV_Jewelry_Ring_36"
                                elseif itemType:find("neck") or itemType:find("amulet") then
                                    iconPath = "Interface\\Icons\\INV_Jewelry_Necklace_07"
                                elseif itemType:find("back") or itemType:find("cloak") then
                                    iconPath = "Interface\\Icons\\INV_Misc_Cape_20"
                                elseif itemType:find("wand") then
                                    iconPath = "Interface\\Icons\\INV_Wand_06"
                                elseif itemType:find("off-hand") then
                                    iconPath = "Interface\\Icons\\INV_Offhand_Tome_02"
                                elseif itemType:find("fist") then
                                    iconPath = "Interface\\Icons\\INV_Gauntlets_04"
                                elseif itemType:find("polearm") then
                                    iconPath = "Interface\\Icons\\INV_Spear_02"
                                elseif itemType:find("glove") or itemType:find("hands") then
                                    iconPath = "Interface\\Icons\\INV_Gauntlets_23"
                                elseif itemType:find("belt") or itemType:find("waist") then
                                    iconPath = "Interface\\Icons\\INV_Belt_03"
                                elseif itemType:find("bracer") or itemType:find("wrist") then
                                    iconPath = "Interface\\Icons\\INV_Bracer_07"
                                elseif itemType:find("boot") or itemType:find("feet") then
                                    iconPath = "Interface\\Icons\\INV_Boots_Chain_01"
                                elseif itemType:find("relic") then
                                    iconPath = "Interface\\Icons\\INV_Relics_LibramOfGrace"
                                end

                                lootIcon.texture:SetTexture(iconPath)

                                -- Set quality border color (default to epic purple)
                                local qualityR, qualityG, qualityB = 0.64, 0.21, 0.93  -- Epic purple
                                if item.type and item.type:lower():find("legendary") then
                                    qualityR, qualityG, qualityB = 1.0, 0.5, 0.0  -- Legendary orange
                                elseif item.type and item.type:lower():find("rare") then
                                    qualityR, qualityG, qualityB = 0.0, 0.44, 0.87  -- Rare blue
                                end
                                lootIcon.border:SetVertexColor(qualityR, qualityG, qualityB, 0.8)

                                -- Store item data for tooltip
                                lootIcon.itemData = item
                                lootIcon.qualityColor = { qualityR, qualityG, qualityB }

                                -- Tooltip on hover
                                lootIcon:EnableMouse(true)
                                lootIcon:SetScript("OnEnter", function(self)
                                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                                    local qr, qg, qb = unpack(self.qualityColor)
                                    GameTooltip:AddLine(self.itemData.name, qr, qg, qb)
                                    if self.itemData.type then
                                        GameTooltip:AddLine(self.itemData.type, 0.8, 0.8, 0.8)
                                    end
                                    if self.itemData.dropRate then
                                        GameTooltip:AddLine("Drop Rate: " .. self.itemData.dropRate, 0.6, 0.6, 0.6)
                                    end
                                    GameTooltip:Show()
                                end)
                                lootIcon:SetScript("OnLeave", function()
                                    GameTooltip:Hide()
                                end)

                                lootIcon:Show()
                            end
                            -- ===== END LOOT ICON STRIP =====

                            -- Add boss tooltip with mechanics and loot
                            card:SetScript("OnEnter", function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

                                -- Boss name header
                                local bossColor = HopeAddon:GetSafeColor(phaseColorName)
                                if bossColor then
                                    GameTooltip:AddLine(boss.name, bossColor.r, bossColor.g, bossColor.b)
                                else
                                    GameTooltip:AddLine(boss.name, 1, 0.84, 0)
                                end
                                GameTooltip:AddLine(boss.location or raid.location, 0.8, 0.8, 0.8)

                                -- Boss lore/description
                                if boss.lore then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine(boss.lore, 1, 1, 1, true)
                                end

                                -- Boss quote if available
                                if boss.quote then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine('"' .. boss.quote .. '"', 1, 0.84, 0, true)
                                end

                                -- Mechanics section
                                if boss.mechanics and #boss.mechanics > 0 then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine("Mechanics:", 1, 0.84, 0)
                                    for _, mechanic in ipairs(boss.mechanics) do
                                        GameTooltip:AddLine("  • " .. mechanic, 0.9, 0.9, 0.9, true)
                                    end
                                end

                                -- Notable loot section (fixed: use notableLoot not loot)
                                if boss.notableLoot and #boss.notableLoot > 0 then
                                    GameTooltip:AddLine(" ")
                                    GameTooltip:AddLine("Notable Loot:", 0.6, 0.3, 0.9)
                                    for _, item in ipairs(boss.notableLoot) do
                                        if type(item) == "table" then
                                            -- Determine quality color
                                            local qualityR, qualityG, qualityB = 0.64, 0.21, 0.93  -- Epic
                                            if item.type and item.type:lower():find("legendary") then
                                                qualityR, qualityG, qualityB = 1.0, 0.5, 0.0
                                            elseif item.type and item.type:lower():find("rare") then
                                                qualityR, qualityG, qualityB = 0.0, 0.44, 0.87
                                            end
                                            local lootText = "  • " .. item.name
                                            if item.type then
                                                lootText = lootText .. " (" .. item.type .. ")"
                                            end
                                            GameTooltip:AddLine(lootText, qualityR, qualityG, qualityB)
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
                                card:SetAlpha(0.7)
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
    instructionsText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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

    -- Add subtle purple glow (closest to pink in existing colors)
    if HopeAddon.Effects and HopeAddon.Effects.CreateBorderGlow then
        container._glowEffect = HopeAddon.Effects:CreateBorderGlow(container, "ARCANE_PURPLE")
    end

    -- Get theme from constants
    local C = HopeAddon.Constants
    local theme = C.SOCIAL_SECTION_THEMES and C.SOCIAL_SECTION_THEMES.lf_rp or {}

    -- Header with radiant light icon (Sunwell theme)
    local headerIcon = container:CreateTexture(nil, "ARTWORK")
    headerIcon:SetSize(20, 20)
    headerIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    headerIcon:SetTexture(theme.icon or "Interface\\Icons\\Spell_Holy_SurgeOfLight")  -- Sunwell light

    local headerText = container:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    headerText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
    headerText:SetText("|cFFFF33CC" .. (theme.title or "LOOKING FOR RP") .. "|r")

    -- Count badge
    local countBadge = container:CreateFontString(nil, "OVERLAY")
    countBadge:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
        moreText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    nameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 8, -2)
    nameText:SetText(displayName)

    -- Zone and time
    local zoneText = row:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    btnText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    descText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    descText:SetPoint("TOPLEFT", typeIcon, "TOPRIGHT", 8, -2)
    descText:SetWidth(parent:GetWidth() - 120)  -- Leave room for time
    descText:SetWordWrap(true)

    local formattedText = ActivityFeed and ActivityFeed:FormatActivity(activity) or (activity.player .. ": " .. (activity.data or ""))
    descText:SetText(formattedText)

    -- Time ago (top right)
    local timeText = row:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    mugCountText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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

    local travelers = HopeAddon.charDb and HopeAddon.charDb.travelers
    local profile = travelers and travelers.myProfile or {}
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
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
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
    editBtnText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    nameText:SetFont(HopeAddon.assets.fonts.TITLE, 16, "")
    nameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 10, -2)
    nameText:SetText(displayName)
    container.nameText = nameText  -- Store reference for updates

    -- Class/Level info
    local levelText = container:CreateFontString(nil, "OVERLAY")
    levelText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    levelText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    local colorHex = classColor and string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) or "FFFFFF"
    levelText:SetText(string.format("Level %d |cFF%s%s|r", UnitLevel("player"), colorHex, playerClass or "Unknown"))
    levelText:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Title dropdown label
    local titleLabel = container:CreateFontString(nil, "OVERLAY")
    titleLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    titleLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -95)
    titleLabel:SetText("Title:")
    titleLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Title dropdown (static name - frame is hidden/wiped on tab switch via socialDropdowns tracking)
    local titleDropdown = _G["HopeAddonSocialTitleDropdown"] or CreateFrame("Frame", "HopeAddonSocialTitleDropdown", container, "UIDropDownMenuTemplate")
    titleDropdown:SetParent(container)
    titleDropdown:ClearAllPoints()
    titleDropdown:SetPoint("LEFT", titleLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(titleDropdown, 140)
    -- Track for cleanup on tab switch
    table.insert(Journal.socialDropdowns, titleDropdown)

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
    statusLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    statusLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 15, -125)
    statusLabel:SetText("RP Status:")
    statusLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- RP Status dropdown (static name - frame is hidden/wiped on tab switch via socialDropdowns tracking)
    local statusDropdown = _G["HopeAddonSocialStatusDropdown"] or CreateFrame("Frame", "HopeAddonSocialStatusDropdown", container, "UIDropDownMenuTemplate")
    statusDropdown:SetParent(container)
    statusDropdown:ClearAllPoints()
    statusDropdown:SetPoint("LEFT", statusLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(statusDropdown, 140)
    -- Track for cleanup on tab switch
    table.insert(Journal.socialDropdowns, statusDropdown)

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
Journal.socialDropdowns = {}  -- Track dropdown frames for cleanup on tab switch

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
    searchBox:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    searchBox:SetTextColor(1, 1, 1, 1)
    searchBox:SetAutoFocus(false)
    searchBox:SetText(self.socialState.searchText)
    searchBox:SetTextInsets(8, 8, 0, 0)
    toolbar.searchBox = searchBox

    local placeholder = searchBox:CreateFontString(nil, "OVERLAY")
    placeholder:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        -- Also close the journal (escape should dismiss the whole UI)
        if Journal.mainFrame then
            Journal.mainFrame:Hide()
        end
    end)
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    -- Allow movement keys to pass through to game while typing
    searchBox:SetScript("OnKeyDown", function(self, key)
        self:SetPropagateKeyboardInput(true)
    end)

    local sortLabel = toolbar:CreateFontString(nil, "OVERLAY")
    sortLabel:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    sortLabel:SetPoint("LEFT", searchBox, "RIGHT", 15, 0)
    sortLabel:SetText("Sort:")
    sortLabel:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Sort dropdown (static name - frame is hidden/wiped on tab switch via socialDropdowns tracking)
    local sortDropdown = _G["HopeAddonSocialSortDropdown"] or CreateFrame("Frame", "HopeAddonSocialSortDropdown", toolbar, "UIDropDownMenuTemplate")
    sortDropdown:SetParent(toolbar)
    sortDropdown:ClearAllPoints()
    sortDropdown:SetPoint("LEFT", sortLabel, "RIGHT", -10, -2)
    UIDropDownMenu_SetWidth(sortDropdown, 100)
    toolbar.sortDropdown = sortDropdown
    -- Track for cleanup on tab switch
    table.insert(Journal.socialDropdowns, sortDropdown)

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
        btnText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    resultsText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    pageText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
        prevText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
        nextText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    nameText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    acceptText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    declineText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
        editBox:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
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
        sendText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
            -- Also close the journal (escape should dismiss the whole UI)
            if Journal.mainFrame then
                Journal.mainFrame:Hide()
            end
        end)

        -- Placeholder text
        local placeholder = editBox:CreateFontString(nil, "ARTWORK")
        placeholder:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
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

--============================================================
-- POST POPUP - IC Post vs Anonymous Rumor selection
--============================================================

local POST_POPUP_WIDTH = 360
local POST_POPUP_HEIGHT = 380

-- Post type options (Phase 50)
local POST_TYPE_OPTIONS = {
    {
        id = "IC",
        label = "In Character",
        description = "Your name and title will be shown",
        color = { 0.2, 0.8, 0.2 },       -- Fel green
        icon = "Interface\\Icons\\Spell_Holy_MindVision",
        previewFormat = function(playerName, title)
            if title and title ~= "" then
                return string.format("|cFFFFD700%s|r |cFF808080<%s>|r:", playerName, title)
            end
            return string.format("|cFFFFD700%s|r:", playerName)
        end,
    },
    {
        id = "ANON",
        label = "Tavern Rumor",
        description = "Anonymous - 'A patron whispers...'",
        color = { 0.61, 0.19, 1.0 },     -- Arcane purple
        icon = "Interface\\Icons\\INV_Scroll_01",
        previewFormat = function()
            return "|cFF808080A patron whispers|r:"
        end,
    },
}

-- Status options for status mode (kept for backward compatibility)
local STATUS_OPTIONS = {
    { id = "IC", label = "In Character", color = {0.0, 1.0, 0.0}, hex = "00FF00" },
    { id = "OOC", label = "Out of Character", color = {0.5, 0.5, 0.5}, hex = "808080" },
    { id = "LF_RP", label = "Looking for RP", color = {1.0, 0.41, 0.71}, hex = "FF69B4" },
}

--[[
    Get or create the post popup frame (IC Post vs Anonymous Rumor)
    @return Frame - The popup frame
]]
function Journal:GetRumorPopup()
    if self.rumorPopup then
        return self.rumorPopup
    end

    -- Create popup frame
    local popup = CreateFrame("Frame", "HopePostPopup", UIParent, "BackdropTemplate")
    popup:SetSize(POST_POPUP_WIDTH, POST_POPUP_HEIGHT)
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    popup:SetFrameStrata("DIALOG")
    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(1.0, 0.84, 0.0, 1)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    title:SetPoint("TOP", popup, "TOP", 0, -15)
    title:SetText(HopeAddon:ColorText("TAVERN NOTICE BOARD", "GOLD_BRIGHT"))
    popup.title = title

    -- Subtitle
    local subtitle = popup:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("|cFF808080Share with Fellow Travelers|r")

    -- Close (X) button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    -- Content container
    local content = CreateFrame("Frame", nil, popup)
    content:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, -50)
    content:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -20, 50)
    popup.content = content

    -- Edit box with background
    local editBoxFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    editBoxFrame:SetSize(POST_POPUP_WIDTH - 40, 60)
    editBoxFrame:SetPoint("TOP", content, "TOP", 0, 0)
    editBoxFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    editBoxFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    editBoxFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local editBox = CreateFrame("EditBox", nil, editBoxFrame)
    editBox:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    editBox:SetPoint("TOPLEFT", editBoxFrame, "TOPLEFT", 8, -8)
    editBox:SetPoint("BOTTOMRIGHT", editBoxFrame, "BOTTOMRIGHT", -8, 8)
    editBox:SetMaxLetters(100)
    editBox:SetAutoFocus(false)
    editBox:SetMultiLine(true)
    editBox:SetTextInsets(2, 2, 2, 2)
    editBox:SetTextColor(1, 1, 1)
    popup.editBox = editBox

    -- Character counter
    local charCounter = content:CreateFontString(nil, "OVERLAY")
    charCounter:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    charCounter:SetPoint("TOPRIGHT", editBoxFrame, "BOTTOMRIGHT", 0, -3)
    charCounter:SetText("0 / 100")
    charCounter:SetTextColor(0.6, 0.6, 0.6)
    popup.charCounter = charCounter

    -- Cooldown indicator
    local cooldownText = content:CreateFontString(nil, "OVERLAY")
    cooldownText:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
    cooldownText:SetPoint("TOPLEFT", editBoxFrame, "BOTTOMLEFT", 0, -3)
    cooldownText:SetTextColor(1, 0.5, 0.5)
    cooldownText:Hide()
    popup.cooldownText = cooldownText

    editBox:SetScript("OnTextChanged", function(self)
        local len = #self:GetText()
        charCounter:SetText(len .. " / 100")
        if len >= 100 then
            charCounter:SetTextColor(1, 0.3, 0.3)
        elseif len >= 80 then
            charCounter:SetTextColor(1, 0.8, 0)
        else
            charCounter:SetTextColor(0.6, 0.6, 0.6)
        end
        -- Update preview
        Journal:UpdatePostPreview()
    end)

    editBox:SetScript("OnEscapePressed", function()
        popup:Hide()
    end)

    -- "HOW TO POST" label
    local howToLabel = content:CreateFontString(nil, "OVERLAY")
    howToLabel:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    howToLabel:SetPoint("TOPLEFT", editBoxFrame, "BOTTOMLEFT", 0, -22)
    howToLabel:SetText("|cFF808080Choose how to post:|r")

    -- POST TYPE RADIO BUTTONS
    popup.postTypeButtons = {}
    popup.selectedPostType = "IC"  -- Default to IC

    local yOffset = -40
    for i, option in ipairs(POST_TYPE_OPTIONS) do
        local btn = CreateFrame("Button", nil, content, "BackdropTemplate")
        btn:SetSize(POST_POPUP_WIDTH - 40, 50)
        btn:SetPoint("TOP", editBoxFrame, "BOTTOM", 0, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        btn:SetBackdropBorderColor(option.color[1], option.color[2], option.color[3], 0.4)

        -- Radio button indicator (circle)
        local radio = btn:CreateTexture(nil, "OVERLAY")
        radio:SetSize(16, 16)
        radio:SetPoint("LEFT", btn, "LEFT", 12, 0)
        radio:SetTexture("Interface\\Buttons\\UI-RadioButton")
        radio:SetTexCoord(0, 0.25, 0, 1)  -- Unchecked state
        btn.radio = radio

        -- Type icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", radio, "RIGHT", 10, 0)
        icon:SetTexture(option.icon)
        btn.icon = icon

        -- Type label
        local label = btn:CreateFontString(nil, "OVERLAY")
        label:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
        label:SetPoint("LEFT", icon, "RIGHT", 8, 6)
        label:SetText(option.label)
        label:SetTextColor(option.color[1], option.color[2], option.color[3])
        btn.label = label

        -- Description
        local desc = btn:CreateFontString(nil, "OVERLAY")
        desc:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
        desc:SetPoint("LEFT", icon, "RIGHT", 8, -8)
        desc:SetText("|cFF808080" .. option.description .. "|r")
        btn.desc = desc

        btn.typeId = option.id
        btn.option = option

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        end)
        btn:SetScript("OnLeave", function(self)
            if popup.selectedPostType == self.typeId then
                self:SetBackdropBorderColor(self.option.color[1], self.option.color[2], self.option.color[3], 1)
            else
                self:SetBackdropBorderColor(self.option.color[1], self.option.color[2], self.option.color[3], 0.4)
            end
        end)
        btn:SetScript("OnClick", function(self)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            popup.selectedPostType = self.typeId
            Journal:UpdatePostTypeSelection()
            Journal:UpdatePostPreview()
        end)

        popup.postTypeButtons[i] = btn
        yOffset = yOffset - 55
    end

    -- Preview section
    local previewLabel = content:CreateFontString(nil, "OVERLAY")
    previewLabel:SetFont(HopeAddon.assets.fonts.SMALL, 9, "")
    previewLabel:SetPoint("TOPLEFT", popup.postTypeButtons[2], "BOTTOMLEFT", 0, -10)
    previewLabel:SetText("|cFF808080Preview:|r")
    popup.previewLabel = previewLabel

    local previewFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    previewFrame:SetSize(POST_POPUP_WIDTH - 40, 36)
    previewFrame:SetPoint("TOP", previewLabel, "BOTTOM", 0, -4)
    previewFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    previewFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    previewFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
    popup.previewFrame = previewFrame

    local previewText = previewFrame:CreateFontString(nil, "OVERLAY")
    previewText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    previewText:SetPoint("LEFT", previewFrame, "LEFT", 8, 0)
    previewText:SetPoint("RIGHT", previewFrame, "RIGHT", -8, 0)
    previewText:SetJustifyH("LEFT")
    previewText:SetWordWrap(true)
    previewText:SetText("|cFF808080Your message will appear here...|r")
    popup.previewText = previewText

    -- BOTTOM BUTTONS --

    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(90, 24)
    cancelBtn:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 20, 15)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        popup:Hide()
    end)
    popup.cancelBtn = cancelBtn

    -- Post button
    local postBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    postBtn:SetSize(90, 24)
    postBtn:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -20, 15)
    postBtn:SetText("Post")
    popup.postBtn = postBtn

    postBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        local text = editBox:GetText()
        if text and text ~= "" and HopeAddon.ActivityFeed then
            local isAnonymous = (popup.selectedPostType == "ANON")
            if HopeAddon.ActivityFeed:PostMessage(text, isAnonymous) then
                editBox:SetText("")
                popup:Hide()
                -- Switch to Feed sub-tab and refresh so user sees their post
                if Journal.mainFrame and Journal.mainFrame:IsVisible() then
                    Journal:SelectSocialSubTab("feed")
                end
            end
        else
            HopeAddon:Print("Please enter a message to post.")
        end
    end)

    -- Escape to close
    popup:EnableKeyboard(true)
    popup:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    popup:Hide()
    self.rumorPopup = popup
    return popup
end

--[[
    Update post type radio button selection visuals
]]
function Journal:UpdatePostTypeSelection()
    local popup = self.rumorPopup
    if not popup then return end

    for _, btn in ipairs(popup.postTypeButtons) do
        if popup.selectedPostType == btn.typeId then
            -- Selected state
            btn.radio:SetTexCoord(0.25, 0.5, 0, 1)  -- Checked
            btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            btn:SetBackdropBorderColor(btn.option.color[1], btn.option.color[2], btn.option.color[3], 1)
        else
            -- Unselected state
            btn.radio:SetTexCoord(0, 0.25, 0, 1)  -- Unchecked
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            btn:SetBackdropBorderColor(btn.option.color[1], btn.option.color[2], btn.option.color[3], 0.4)
        end
    end

    -- Update preview frame border to match selected type
    local selectedOption = nil
    for _, opt in ipairs(POST_TYPE_OPTIONS) do
        if opt.id == popup.selectedPostType then
            selectedOption = opt
            break
        end
    end
    if selectedOption then
        popup.previewFrame:SetBackdropBorderColor(selectedOption.color[1], selectedOption.color[2], selectedOption.color[3], 0.6)
    end
end

--[[
    Update the preview text based on current selection and text
]]
function Journal:UpdatePostPreview()
    local popup = self.rumorPopup
    if not popup then return end

    local text = popup.editBox:GetText()
    if not text or text == "" then
        popup.previewText:SetText("|cFF808080Your message will appear here...|r")
        return
    end

    -- Truncate for preview
    if #text > 50 then
        text = text:sub(1, 47) .. "..."
    end

    -- Get the format function for the selected type
    local selectedOption = nil
    for _, opt in ipairs(POST_TYPE_OPTIONS) do
        if opt.id == popup.selectedPostType then
            selectedOption = opt
            break
        end
    end

    if selectedOption and selectedOption.previewFormat then
        local playerName = UnitName("player")
        local title = nil
        if HopeAddon.FellowTravelers then
            local profile = HopeAddon.FellowTravelers:GetMyProfile()
            if profile and profile.selectedTitle then
                title = profile.selectedTitle
            end
        end
        local attribution = selectedOption.previewFormat(playerName, title)
        popup.previewText:SetText(attribution .. " \"" .. text .. "\"")
    else
        popup.previewText:SetText("\"" .. text .. "\"")
    end
end

--[[
    Show the post popup
]]
function Journal:ShowRumorPopup()
    local popup = self:GetRumorPopup()
    popup:Show()
    popup.editBox:SetText("")
    popup.charCounter:SetText("0 / 100")
    popup.selectedPostType = "IC"  -- Default to IC Post

    -- Check cooldown
    if HopeAddon.ActivityFeed then
        local canPost, remaining = HopeAddon.ActivityFeed:CanPost()
        if not canPost then
            local mins = math.floor(remaining / 60)
            local secs = remaining % 60
            popup.cooldownText:SetText(string.format("Cooldown: %d:%02d", mins, secs))
            popup.cooldownText:Show()
            popup.postBtn:Disable()
        else
            popup.cooldownText:Hide()
            popup.postBtn:Enable()
        end
    end

    self:UpdatePostTypeSelection()
    self:UpdatePostPreview()
    popup.editBox:SetFocus()
end

--[[
    Hide the post popup
]]
function Journal:HideRumorPopup()
    if self.rumorPopup then
        self.rumorPopup:Hide()
    end
end

function Journal:PopulateSocial()
    local Components = HopeAddon.Components
    local C = HopeAddon.Constants
    local scrollContainer = self.mainFrame.scrollContainer

    -- Ensure social data structure exists using centralized helper
    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    -- SECTION 1: Status Bar (Your profile summary - always visible)
    local statusBar = self:CreateSocialStatusBar(scrollContainer.content)
    scrollContainer:AddEntry(statusBar)
    self.socialContainers.statusBar = statusBar

    -- Spacer
    local spacer1 = Components:CreateSpacer(scrollContainer.content, 8)
    scrollContainer:AddEntry(spacer1)

    -- SECTION 2: Sub-Tab Bar
    local tabBar = self:CreateSocialTabBar(scrollContainer.content)
    scrollContainer:AddEntry(tabBar)
    self.socialContainers.tabBar = tabBar

    -- Spacer
    local spacer2 = Components:CreateSpacer(scrollContainer.content, 8)
    scrollContainer:AddEntry(spacer2)

    -- SECTION 3: Tab Content (dynamic based on active sub-tab)
    local content = self:CreateSocialContent()
    content:SetParent(scrollContainer.content)
    scrollContainer:AddEntry(content)
    self.socialContainers.content = content

    -- Populate based on active sub-tab
    local activeTab = socialUI.activeTab or "travelers"
    self:SelectSocialSubTab(activeTab)
end

--[[
    Create the Social Status Bar (your profile summary)
    Shows: Class icon, Name <Title>, RP Status dropdown, Post Rumor button
    @param parent Frame - Parent frame
    @return Frame - Status bar frame
]]
function Journal:CreateSocialStatusBar(parent)
    local C = HopeAddon.Constants
    local height = C.SOCIAL_TAB.STATUS_BAR_HEIGHT

    local bar = self.containerPool:Acquire()
    bar:SetParent(parent)
    bar:SetHeight(height)
    bar._componentType = "header"

    -- Get player info
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    local myProfile = HopeAddon.charDb.travelers and HopeAddon.charDb.travelers.myProfile or {}
    local classColor = playerClass and HopeAddon:GetClassColor(playerClass) or { r = 0.7, g = 0.7, b = 0.7 }

    -- Class icon
    local classIcon = bar:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(28, 28)
    classIcon:SetPoint("LEFT", bar, "LEFT", 12, 0)
    local coords = CLASS_ICON_TCOORDS[playerClass]
    if coords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name with title
    local nameText = bar:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 8, 0)

    local displayName = "|cFF" .. string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. playerName .. "|r"
    if myProfile.selectedTitle and myProfile.selectedTitle ~= "" then
        local Badges = HopeAddon.Badges
        local titleColor = Badges and Badges:GetTitleColor(myProfile.selectedTitle) or "FFD700"
        displayName = displayName .. " |cFF" .. titleColor .. "<" .. myProfile.selectedTitle .. ">|r"
    end
    nameText:SetText(displayName)

    -- RP Status dropdown (compact)
    local statusDropdown = CreateFrame("Frame", "HopeAddonSocialStatusDropdownBar", bar, "UIDropDownMenuTemplate")
    statusDropdown:SetPoint("LEFT", nameText, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(statusDropdown, 80)

    local currentStatus = myProfile.status or "OOC"
    UIDropDownMenu_SetText(statusDropdown, currentStatus)

    UIDropDownMenu_Initialize(statusDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, statusId in ipairs({ "IC", "OOC", "LF_RP" }) do
            local statusDef = C.RP_STATUS[statusId]
            info.text = statusDef.label
            info.value = statusId
            info.checked = (currentStatus == statusId)
            info.func = function()
                UIDropDownMenu_SetText(statusDropdown, statusId)
                if HopeAddon.FellowTravelers then
                    HopeAddon.FellowTravelers:UpdateMyProfile({ status = statusId })
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Post Rumor button
    local rumorBtn = CreateFrame("Button", nil, bar, "BackdropTemplate")
    rumorBtn:SetSize(90, 24)
    rumorBtn:SetPoint("RIGHT", bar, "RIGHT", -12, 0)
    rumorBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    rumorBtn:SetBackdropColor(0.2, 0.4, 0.2, 0.9)
    rumorBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)

    local rumorText = rumorBtn:CreateFontString(nil, "OVERLAY")
    rumorText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    rumorText:SetPoint("CENTER")
    rumorText:SetText("+ Share")
    rumorText:SetTextColor(0.4, 1.0, 0.4)

    rumorBtn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        Journal:ShowRumorPopup()
    end)
    rumorBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
    end)
    rumorBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
    end)

    return bar
end

--[[
    Create the Social Sub-Tab Bar
    Shows: [Guild] [Travelers] [Companions] [Feed] tabs
    @param parent Frame - Parent frame
    @return Frame - Tab bar frame
]]
function Journal:CreateSocialTabBar(parent)
    local C = HopeAddon.Constants
    local Components = HopeAddon.Components

    local bar = self.containerPool:Acquire()
    bar:SetParent(parent)
    bar:SetHeight(C.SOCIAL_TAB.TAB_HEIGHT + 4)
    bar._componentType = "header"

    -- Use centralized helper for social UI access
    local socialUI = HopeAddon:GetSocialUI()
    local activeTab = socialUI and socialUI.activeTab or "guild"

    -- Create sub-tabs - Guild first, then Travelers, Companions, Feed
    local tabs = {
        { id = "guild", label = "Guild" },
        { id = "travelers", label = "Travelers" },
        { id = "companions", label = "Companions" },
        { id = "feed", label = "Feed" },
    }

    local xOffset = 8
    for _, tabInfo in ipairs(tabs) do
        local isActive = (tabInfo.id == activeTab)
        local tab = Components:CreateSocialSubTab(bar, tabInfo.id, tabInfo.label, isActive, function(tabId)
            self:SelectSocialSubTab(tabId)
        end)
        tab:SetPoint("LEFT", bar, "LEFT", xOffset, 0)
        xOffset = xOffset + C.SOCIAL_TAB.TAB_WIDTH + C.SOCIAL_TAB.TAB_SPACING

        self.socialSubTabs[tabInfo.id] = tab
    end

    -- Update badge counts
    self:UpdateSocialTabBadges()

    return bar
end

--[[
    Clear social tab content container
    Removes all child frames and tracked regions (FontStrings, Textures)
    Must be called before repopulating content to prevent stacking
    @param preserveFilterBar boolean - If true, keeps the filter bar (for Travelers tab refresh)
]]
function Journal:ClearSocialContent(preserveFilterBar)
    -- Safety check for nil socialContainers
    if not self.socialContainers or not self.socialContainers.content then return end

    local filterBar = preserveFilterBar and self.socialContainers.filterBar or nil

    -- Hide all children (frame cleanup), except filter bar if preserving
    local children = { self.socialContainers.content:GetChildren() }
    for _, child in ipairs(children) do
        if child ~= filterBar then
            child:Hide()
            child:SetParent(nil)
        end
    end

    -- If not preserving filter bar, clear reference and button table
    if not preserveFilterBar then
        self.socialContainers.filterBar = nil
        if self.quickFilterButtons then
            wipe(self.quickFilterButtons)
        end
    end

    -- Hide all tracked regions (FontStrings, Textures not returned by GetChildren)
    -- Note: SetParent(nil) releases references to allow garbage collection
    if self.socialContentRegions then
        for _, region in ipairs(self.socialContentRegions) do
            if region and region.Hide then
                region:Hide()
                region:SetParent(nil)
            end
        end
        wipe(self.socialContentRegions)
    end
end

--[[
    Select a social sub-tab and refresh content
    @param tabId string - Tab identifier (guild, travelers, companions, feed)
]]
function Journal:SelectSocialSubTab(tabId)
    -- Use centralized helper for social UI access
    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    -- Update stored state
    socialUI.activeTab = tabId

    -- Update tab visuals
    for id, tab in pairs(self.socialSubTabs) do
        if tab and tab.SetActive then
            tab:SetActive(id == tabId)
        end
    end

    -- Clear existing content before populating
    self:ClearSocialContent()

    -- Populate based on selected tab
    if tabId == "guild" then
        self:PopulateSocialGuild()
    elseif tabId == "feed" then
        self:PopulateSocialFeed()
    elseif tabId == "travelers" then
        self:PopulateSocialTravelers()
    elseif tabId == "companions" then
        self:PopulateSocialCompanions()
    end
end

--[[
    Create content container for tab content
    @return Frame - Content container
]]
function Journal:CreateSocialContent()
    local container = self.containerPool:Acquire()
    container:SetHeight(400)  -- Will be resized dynamically by content
    container._componentType = "content"
    return container
end

--[[
    Track a region (FontString, Texture) for cleanup when switching sub-tabs
    FontStrings and Textures are not returned by GetChildren(), so we track them manually
    @param region Region - The region to track
    @return Region - Same region for chaining
]]
function Journal:TrackSocialRegion(region)
    if region then
        table.insert(self.socialContentRegions, region)
    end
    return region
end

--[[
    Get online status from lastSeenTime
    @param lastSeenTime number - Timestamp of last seen
    @return string - "online", "away", or "offline"
]]
function Journal:GetOnlineStatus(lastSeenTime)
    if not lastSeenTime then return "offline" end
    local C = HopeAddon.Constants
    local elapsed = time() - lastSeenTime
    if elapsed < C.SOCIAL_TAB.ONLINE_THRESHOLD then
        return "online"
    elseif elapsed < C.SOCIAL_TAB.AWAY_THRESHOLD then
        return "away"
    else
        return "offline"
    end
end

--[[
    Get count for quick filter buttons
    @param filterId string - Filter identifier
    @return number - Count of matching entries
]]
function Journal:GetFilterCount(filterId)
    if not HopeAddon.Directory then return 0 end
    local fellows = HopeAddon.Directory:GetAllEntries()
    if filterId == "all" then
        return #fellows
    end
    if filterId == "online" then
        local count = 0
        for _, f in ipairs(fellows) do
            if self:GetOnlineStatus(f.lastSeenTime) == "online" then
                count = count + 1
            end
        end
        return count
    end
    if filterId == "party" then
        if not HopeAddon.FellowTravelers then return 0 end
        local partyMembers = HopeAddon.FellowTravelers:GetPartyMembers()
        return partyMembers and #partyMembers or 0
    end
    if filterId == "lfrp" then
        local count = 0
        for _, f in ipairs(fellows) do
            if f.profile and f.profile.status == "LF_RP" then
                count = count + 1
            end
        end
        return count
    end
    return 0
end

--[[
    Refresh travelers list when filters change
    Clears content first to prevent stacking of old entries
]]
function Journal:RefreshTravelersList()
    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    if socialUI.activeTab == "travelers" then
        -- Preserve filter bar when just changing filters
        self:ClearSocialContent(true)
        self:PopulateSocialTravelers()
    end
end

--[[
    Called when new activities arrive from ActivityFeed
    @param count number - Number of new activities
]]
function Journal:OnNewActivity(count)
    -- Always update the unread badge
    self:UpdateSocialTabBadges()

    -- If viewing Social tab's Feed sub-tab, handle refresh
    if self.currentTab == "social" then
        local socialUI = HopeAddon:GetSocialUI()
        if socialUI and socialUI.activeTab == "feed" then
            self:HandleFeedActivityArrival(count)
        end
    end
end

--[[
    Handle new activity arrival while viewing feed
    Uses hybrid approach: auto-refresh if at top, show banner if scrolled
    @param count number - Number of new activities
]]
function Journal:HandleFeedActivityArrival(count)
    -- Check if scrolled to top (within 20px tolerance)
    local scrollFrame = self.socialContainers and self.socialContainers.scrollFrame
    if scrollFrame then
        local scrollPos = scrollFrame:GetVerticalScroll()
        if scrollPos < 20 then
            -- Auto-refresh silently
            self:ClearSocialContent()
            self:PopulateSocialFeed()
            return
        end
    end

    -- Not at top - show "new activities" banner
    self:ShowNewActivitiesBanner(count)
end

--[[
    Show banner indicating new activities are available
    @param count number - Number of new activities to add
]]
function Journal:ShowNewActivitiesBanner(count)
    local content = self.socialContainers and self.socialContainers.content
    if not content then return end

    -- Create banner if it doesn't exist
    if not self.newActivitiesBanner then
        local banner = CreateFrame("Button", nil, content, "BackdropTemplate")
        banner:SetHeight(28)
        banner:SetFrameStrata("HIGH")
        banner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        banner:SetBackdropColor(0.15, 0.5, 0.15, 0.95)
        banner:SetBackdropBorderColor(0.3, 0.8, 0.3, 1)

        local text = banner:CreateFontString(nil, "OVERLAY")
        text:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        text:SetPoint("CENTER")
        text:SetTextColor(1, 1, 1)
        banner.text = text

        -- Hover effect
        banner:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.6, 0.2, 1)
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        end)
        banner:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.15, 0.5, 0.15, 0.95)
        end)

        -- Click to refresh
        banner:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            banner:Hide()
            Journal.pendingActivityCount = 0
            Journal:ClearSocialContent()
            Journal:PopulateSocialFeed()
        end)

        self.newActivitiesBanner = banner
    end

    -- Update count and position
    self.pendingActivityCount = (self.pendingActivityCount or 0) + count
    local label = self.pendingActivityCount == 1 and "activity" or "activities"
    self.newActivitiesBanner.text:SetText(string.format(
        "|cFFFFFFFF\226\134\145 %d new %s|r - Click to refresh",
        self.pendingActivityCount,
        label
    ))

    -- Position at top of content area
    self.newActivitiesBanner:ClearAllPoints()
    self.newActivitiesBanner:SetPoint("TOPLEFT", content, "TOPLEFT", 4, 4)
    self.newActivitiesBanner:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, 4)
    self.newActivitiesBanner:Show()
    self.newActivitiesBanner:Raise()
end

--[[
    Hide the new activities banner (called when switching tabs or refreshing)
]]
function Journal:HideNewActivitiesBanner()
    if self.newActivitiesBanner then
        self.newActivitiesBanner:Hide()
    end
    self.pendingActivityCount = 0
end

--[[
    Update tab badge counts
]]
function Journal:UpdateSocialTabBadges()
    if not self.socialSubTabs then return end

    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    -- Guild: Show online member count
    if HopeAddon.Guild then
        local onlineGuildMembers = HopeAddon.Guild:GetOnlineCount()
        if self.socialSubTabs.guild then
            self.socialSubTabs.guild:SetBadge(onlineGuildMembers > 0 and tostring(onlineGuildMembers) or "")
        end
    end

    -- Feed: Show unread count
    if HopeAddon.ActivityFeed then
        local feed = HopeAddon.ActivityFeed:GetRecentFeed(50)
        local lastSeen = socialUI.feed and socialUI.feed.lastSeenTimestamp or 0
        local unread = 0
        for _, activity in ipairs(feed) do
            if activity.time > lastSeen then
                unread = unread + 1
            end
        end
        if self.socialSubTabs.feed then
            self.socialSubTabs.feed:SetBadge(unread > 0 and tostring(unread) or "")
        end
    end

    -- Travelers: Show online count
    local onlineCount = self:GetFilterCount("online")
    if self.socialSubTabs.travelers then
        self.socialSubTabs.travelers:SetBadge(onlineCount > 0 and tostring(onlineCount) or "")
    end

    -- Companions: Show online companions
    if HopeAddon.Companions then
        local companions = HopeAddon.Companions:GetAllCompanions()
        local onlineCompanions = 0
        for _, comp in ipairs(companions) do
            if self:GetOnlineStatus(comp.lastSeenTime) == "online" then
                onlineCompanions = onlineCompanions + 1
            end
        end
        if self.socialSubTabs.companions then
            self.socialSubTabs.companions:SetBadge(onlineCompanions > 0 and tostring(onlineCompanions) or "")
        end
    end
end

--============================================================
-- SOCIAL SUB-TAB CONTENT FUNCTIONS
--============================================================

--[[
    Populate the Guild sub-tab with "Guild Hall" themed roster and activity
]]
function Journal:PopulateSocialGuild()
    local content = self.socialContainers.content
    if not content then return end

    local C = HopeAddon.Constants
    local Components = HopeAddon.Components
    local Guild = HopeAddon.Guild

    -- Check if player is in a guild
    if not IsInGuild() then
        -- Show "not in guild" message
        local noGuildFrame = CreateFrame("Frame", nil, content)
        noGuildFrame:SetHeight(120)
        noGuildFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        noGuildFrame:SetPoint("RIGHT", content, "RIGHT", 0, 0)

        local icon = noGuildFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(48, 48)
        icon:SetPoint("TOP", noGuildFrame, "TOP", 0, -10)
        icon:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")
        self:TrackSocialRegion(icon)

        local text = noGuildFrame:CreateFontString(nil, "OVERLAY")
        text:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
        text:SetPoint("TOP", icon, "BOTTOM", 0, -10)
        text:SetText("|cFFFFD700You are not in a guild|r")
        self:TrackSocialRegion(text)

        local subtext = noGuildFrame:CreateFontString(nil, "OVERLAY")
        subtext:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        subtext:SetPoint("TOP", text, "BOTTOM", 0, -6)
        subtext:SetText("|cFF808080Join a guild to see your Guild Hall|r")
        self:TrackSocialRegion(subtext)

        content:SetHeight(120)
        return
    end

    -- Get guild data
    local guildName = Guild and Guild:GetGuildName() or GetGuildInfo("player") or "Unknown Guild"
    local motd = Guild and Guild:GetMOTD() or ""

    local socialUI = HopeAddon:GetSocialUI()
    local guildUI = socialUI and socialUI.guild or {}
    local quickFilter = guildUI.quickFilter or "all"
    local sortBy = guildUI.sortBy or "online"

    local yOffset = 0

    -- HEADER: "Guild Hall of [Guild Name]"
    local header = CreateFrame("Frame", nil, content, "BackdropTemplate")
    header:SetHeight(C.SOCIAL_TAB.GUILD_HEADER_HEIGHT or 50)
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    header:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    header:SetBackdropColor(0.12, 0.1, 0.08, 0.95)
    header:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)

    -- Guild crest icon
    local crest = header:CreateTexture(nil, "ARTWORK")
    crest:SetSize(36, 36)
    crest:SetPoint("LEFT", header, "LEFT", 10, 0)
    crest:SetTexture("Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend")
    self:TrackSocialRegion(crest)

    -- Guild name title
    local title = header:CreateFontString(nil, "OVERLAY")
    title:SetFont(HopeAddon.assets.fonts.HEADER, 16, "")
    title:SetPoint("LEFT", crest, "RIGHT", 12, 6)
    title:SetText("|cFFFFD700Guild Hall of|r |cFF4FC3F7" .. guildName .. "|r")
    self:TrackSocialRegion(title)

    -- Subtitle with member counts
    local onlineCount = Guild and Guild:GetOnlineCount() or 0
    local totalCount = Guild and Guild:GetMemberCount() or 0
    local subtitle = header:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    subtitle:SetText(string.format("|cFF808080%d online of %d members|r", onlineCount, totalCount))
    self:TrackSocialRegion(subtitle)

    yOffset = yOffset - (C.SOCIAL_TAB.GUILD_HEADER_HEIGHT or 50) - 4

    -- MOTD Section (if exists)
    if motd and motd ~= "" then
        local motdFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
        motdFrame:SetHeight(C.SOCIAL_TAB.GUILD_MOTD_HEIGHT or 40)
        motdFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        motdFrame:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        motdFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        motdFrame:SetBackdropColor(0.15, 0.12, 0.1, 0.9)
        motdFrame:SetBackdropBorderColor(0.4, 0.35, 0.3, 0.8)

        local motdLabel = motdFrame:CreateFontString(nil, "OVERLAY")
        motdLabel:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
        motdLabel:SetPoint("TOPLEFT", motdFrame, "TOPLEFT", 8, -4)
        motdLabel:SetText("|cFFFFD700MOTD:|r")
        self:TrackSocialRegion(motdLabel)

        local motdText = motdFrame:CreateFontString(nil, "OVERLAY")
        motdText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        motdText:SetPoint("TOPLEFT", motdLabel, "BOTTOMLEFT", 0, -2)
        motdText:SetPoint("RIGHT", motdFrame, "RIGHT", -8, 0)
        motdText:SetText("|cFFCCCCCC" .. motd .. "|r")
        motdText:SetWordWrap(true)
        motdText:SetJustifyH("LEFT")
        self:TrackSocialRegion(motdText)

        yOffset = yOffset - (C.SOCIAL_TAB.GUILD_MOTD_HEIGHT or 40) - 4
    end

    -- FILTER BAR: Online / All
    local filterBar = self:CreateGuildQuickFilters(content, quickFilter)
    filterBar:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    filterBar:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    yOffset = yOffset - 32

    -- MEMBER ROSTER
    local filter = {
        showOffline = (quickFilter == "all"),
    }
    local roster = Guild and Guild:GetFilteredRoster(filter, sortBy) or {}

    for _, member in ipairs(roster) do
        local row = self:CreateGuildMemberRow(content, member)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        yOffset = yOffset - (C.SOCIAL_TAB.GUILD_ROW_HEIGHT or 44) - 2
    end

    -- Show "no members" message if roster is empty
    if #roster == 0 then
        local emptyText = content:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
        emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        emptyText:SetText("|cFF808080No guild members " .. (quickFilter == "online" and "online" or "found") .. "|r")
        self:TrackSocialRegion(emptyText)
        yOffset = yOffset - 30
    end

    -- ACTIVITY CHRONICLES Section
    yOffset = yOffset - 10
    local activityHeader = content:CreateFontString(nil, "OVERLAY")
    activityHeader:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    activityHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 8, yOffset)
    activityHeader:SetText("|cFFFFD700Guild Chronicles|r")
    self:TrackSocialRegion(activityHeader)
    yOffset = yOffset - 20

    local activities = Guild and Guild:GetRecentActivity(10) or {}
    if #activities > 0 then
        for _, activity in ipairs(activities) do
            local activityRow = self:CreateGuildActivityRow(content, activity)
            activityRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
            activityRow:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            yOffset = yOffset - (C.SOCIAL_TAB.GUILD_ACTIVITY_HEIGHT or 36) - 2
        end
    else
        local noActivity = content:CreateFontString(nil, "OVERLAY")
        noActivity:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        noActivity:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        noActivity:SetText("|cFF808080No recent guild activity|r")
        self:TrackSocialRegion(noActivity)
        yOffset = yOffset - 24
    end

    -- Adjust content height
    content:SetHeight(math.abs(yOffset) + 20)
end

--[[
    Create quick filter buttons for Guild tab
    @param parent Frame - Parent frame
    @param activeFilter string - Currently active filter
    @return Frame - Filter bar frame
]]
function Journal:CreateGuildQuickFilters(parent, activeFilter)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetHeight(28)

    local filters = {
        { id = "all", label = "All Members" },
        { id = "online", label = "Online Only" },
    }

    local xOffset = 0
    for _, filterInfo in ipairs(filters) do
        local isActive = (filterInfo.id == activeFilter)

        local btn = CreateFrame("Button", nil, bar, "BackdropTemplate")
        btn:SetSize(90, 24)
        btn:SetPoint("LEFT", bar, "LEFT", xOffset, 0)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        btnText:SetPoint("CENTER")
        btnText:SetText(filterInfo.label)
        btn.text = btnText

        btn.isActive = isActive
        btn.filterId = filterInfo.id

        local function SetActive(active)
            active = (active == true)
            btn.isActive = active
            if active then
                btn:SetBackdropColor(0.2, 0.5, 0.2, 0.9)
                btn:SetBackdropBorderColor(0.4, 1.0, 0.4, 1)
                btnText:SetTextColor(0.4, 1.0, 0.4)
            else
                btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                btnText:SetTextColor(0.7, 0.7, 0.7)
            end
        end
        btn.SetActive = SetActive
        SetActive(isActive)

        btn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            self:SetGuildQuickFilter(filterInfo.id)
        end)

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isActive then
                self:SetBackdropBorderColor(0.4, 1.0, 0.4, 1)
            else
                self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
        end)

        xOffset = xOffset + 94
    end

    return bar
end

--[[
    Set guild quick filter and refresh
    @param filterId string - Filter ID (all, online)
]]
function Journal:SetGuildQuickFilter(filterId)
    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    if not socialUI.guild then
        socialUI.guild = { quickFilter = "all", sortBy = "online", showActivity = true }
    end
    socialUI.guild.quickFilter = filterId

    -- Refresh guild content
    self:ClearSocialContent()
    self:PopulateSocialGuild()
end

--[[
    Create a guild member row
    @param parent Frame - Parent frame
    @param member table - Guild member data
    @return Frame - Row frame
]]
function Journal:CreateGuildMemberRow(parent, member)
    local C = HopeAddon.Constants
    local Guild = HopeAddon.Guild

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(C.SOCIAL_TAB.GUILD_ROW_HEIGHT or 44)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    -- Get class color
    local classColor = member.classToken and RAID_CLASS_COLORS[member.classToken]
    if not classColor then classColor = { r = 0.5, g = 0.5, b = 0.5 } end

    -- Background and border based on online status
    if member.isOnline then
        row:SetBackdropColor(0.1, 0.15, 0.1, 0.9)
        row:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.8)
    else
        row:SetBackdropColor(0.08, 0.08, 0.08, 0.7)
        row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
    end

    -- Online status indicator
    local statusDot = row:CreateTexture(nil, "OVERLAY")
    statusDot:SetSize(10, 10)
    statusDot:SetPoint("LEFT", row, "LEFT", 8, 0)
    statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
    if member.isOnline then
        if member.status == 1 then  -- AFK
            statusDot:SetVertexColor(1.0, 0.8, 0.2)
        elseif member.status == 2 then  -- DND
            statusDot:SetVertexColor(1.0, 0.3, 0.3)
        else
            statusDot:SetVertexColor(0.2, 1.0, 0.2)
        end
    else
        statusDot:SetVertexColor(0.5, 0.5, 0.5)
    end

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(24, 24)
    classIcon:SetPoint("LEFT", statusDot, "RIGHT", 6, 0)
    local classCoords = CLASS_ICON_TCOORDS[member.classToken]
    if classCoords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(classCoords))
    else
        classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end

    -- Check if member is also a Fellow Traveler
    local isFellow = Guild and Guild:IsFellowTraveler(member.name) or false

    -- Name with class color
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 8, 4)
    local nameColor = string.format("|cFF%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
    local displayName = nameColor .. member.name .. "|r"

    -- Add badge indicator if Fellow Traveler
    if isFellow then
        displayName = displayName .. " |cFF9B30FF[F]|r"
    end
    nameText:SetText(displayName)

    -- Level and Rank
    local infoText = row:CreateFontString(nil, "OVERLAY")
    infoText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    infoText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    infoText:SetText(string.format("|cFFAAAAAAlvl %d|r  |cFF888888<%s>|r", member.level or 0, member.rank or "Member"))

    -- Zone or last seen
    local zoneText = row:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    zoneText:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    zoneText:SetJustifyH("RIGHT")

    if member.isOnline then
        zoneText:SetText("|cFF4FC3F7" .. (member.zone or "Unknown") .. "|r")
    else
        local lastOnline = member.lastOnline
        if lastOnline then
            local timeAgo = Guild and Guild:FormatRelativeTime(lastOnline) or "Unknown"
            zoneText:SetText("|cFF666666Last seen " .. timeAgo .. "|r")
        else
            zoneText:SetText("|cFF666666Offline|r")
        end
    end

    -- Hover effects
    row:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0, 1)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end

        -- Show tooltip with more info
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(member.name, classColor.r, classColor.g, classColor.b)
        GameTooltip:AddLine(string.format("Level %d %s", member.level or 0, member.class or "Unknown"), 1, 1, 1)
        GameTooltip:AddLine(member.rank or "Member", 0.6, 0.6, 0.6)
        if member.isOnline then
            GameTooltip:AddLine("Currently in: " .. (member.zone or "Unknown"), 0.3, 0.76, 0.97)
        end
        if member.note and member.note ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Note: " .. member.note, 0.7, 0.7, 0.7, true)
        end
        if isFellow then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Fellow Traveler - Has HopeAddon", 0.61, 0.19, 1.0)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to whisper", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)

    row:SetScript("OnLeave", function(self)
        if member.isOnline then
            self:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.8)
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        end
        GameTooltip:Hide()
    end)

    -- Click to whisper
    row:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        if member.isOnline then
            ChatFrame_OpenChat("/w " .. member.name .. " ")
        else
            HopeAddon:Print(member.name .. " is offline")
        end
    end)

    return row
end

--[[
    Create a guild activity row
    @param parent Frame - Parent frame
    @param activity table - Activity entry { type, player, data, timestamp }
    @return Frame - Row frame
]]
function Journal:CreateGuildActivityRow(parent, activity)
    local C = HopeAddon.Constants
    local Guild = HopeAddon.Guild

    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetHeight(C.SOCIAL_TAB.GUILD_ACTIVITY_HEIGHT or 36)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    row:SetBackdropColor(0.1, 0.1, 0.1, 0.7)

    -- Get activity border color
    local borderColor = C.GUILD_ACTIVITY_BORDERS and C.GUILD_ACTIVITY_BORDERS[activity.type] or { 0.4, 0.4, 0.4 }
    row:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 0.8)

    -- Activity icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    local iconPath = C.GUILD_ACTIVITY_ICONS and C.GUILD_ACTIVITY_ICONS[activity.type] or "Interface\\Icons\\INV_Misc_QuestionMark"
    icon:SetTexture(iconPath)
    self:TrackSocialRegion(icon)

    -- Activity message
    local message = Guild and Guild:FormatActivity(activity) or ""
    local msgText = row:CreateFontString(nil, "OVERLAY")
    msgText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    msgText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    msgText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
    msgText:SetText("|cFFCCCCCC" .. message .. "|r")
    msgText:SetJustifyH("LEFT")
    msgText:SetWordWrap(false)
    self:TrackSocialRegion(msgText)

    -- Timestamp
    local timeText = row:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    timeText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    local timeAgo = Guild and Guild:FormatRelativeTime(activity.timestamp) or ""
    timeText:SetText("|cFF888888" .. timeAgo .. "|r")
    self:TrackSocialRegion(timeText)

    return row
end

--[[
    Populate the Travelers sub-tab with quick filters and traveler list
]]
function Journal:PopulateSocialTravelers()
    local content = self.socialContainers.content
    if not content then return end

    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    local C = HopeAddon.Constants
    local Components = HopeAddon.Components

    -- Get filtered entries based on quick filter
    local quickFilter = socialUI.travelers and socialUI.travelers.quickFilter or "all"
    local entries = self:GetFilteredTravelerEntries(quickFilter)

    -- Create or reuse quick filter bar (persists across filter changes)
    local filterBar = self.socialContainers.filterBar
    if not filterBar or not filterBar:IsShown() then
        -- Clear old button references
        wipe(self.quickFilterButtons)
        filterBar = self:CreateQuickFilters(content)
        filterBar:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        filterBar:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        self.socialContainers.filterBar = filterBar
    else
        -- Update counts on existing buttons
        self:UpdateQuickFilterCounts()
    end

    -- Create rows for each traveler
    local yOffset = -36  -- Below filter bar
    for _, entry in ipairs(entries) do
        local row = self:CreateTravelerRow(content, entry)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        yOffset = yOffset - C.SOCIAL_TAB.TRAVELER_ROW_HEIGHT - 2
    end

    -- Adjust content height
    content:SetHeight(math.abs(yOffset) + 20)
end

--[[
    Update counts on existing quick filter buttons without recreating them
]]
function Journal:UpdateQuickFilterCounts()
    for filterId, btn in pairs(self.quickFilterButtons) do
        if btn and btn.text then
            local count = self:GetFilterCount(filterId)
            local label = filterId == "all" and "All" or
                          filterId == "online" and "Online" or
                          filterId == "party" and "Party" or
                          filterId == "lfrp" and "LF_RP" or filterId
            btn.text:SetText(label .. " " .. count)
        end
    end
end

--[[
    Get filtered traveler entries based on quick filter
    @param filterId string - Filter identifier (all, online, party, lfrp)
    @return table - Array of filtered entries
]]
function Journal:GetFilteredTravelerEntries(filterId)
    if not HopeAddon.Directory then return {} end
    local allEntries = HopeAddon.Directory:GetAllEntries()

    if filterId == "all" then
        return allEntries
    end

    local filtered = {}
    for _, entry in ipairs(allEntries) do
        local include = false

        if filterId == "online" then
            include = self:GetOnlineStatus(entry.lastSeenTime) == "online"
        elseif filterId == "party" then
            local partyMembers = HopeAddon.FellowTravelers and HopeAddon.FellowTravelers:GetPartyMembers() or {}
            for _, pm in ipairs(partyMembers) do
                if pm.name == entry.name then
                    include = true
                    break
                end
            end
        elseif filterId == "lfrp" then
            include = entry.profile and entry.profile.status == "LF_RP"
        end

        if include then
            table.insert(filtered, entry)
        end
    end

    return filtered
end

--[[
    Create quick filter buttons bar
    @param parent Frame - Parent frame
    @return Frame - Filter bar frame
]]
function Journal:CreateQuickFilters(parent)
    local C = HopeAddon.Constants

    local bar = CreateFrame("Frame", nil, parent)
    bar:SetHeight(28)

    -- Use centralized helper for social UI access
    local socialUI = HopeAddon:GetSocialUI()
    local quickFilter = socialUI and socialUI.travelers and socialUI.travelers.quickFilter or "all"

    local filters = {
        { id = "all", label = "All" },
        { id = "online", label = "Online" },
        { id = "party", label = "Party" },
        { id = "lfrp", label = "LF_RP" },
    }

    local xOffset = 0
    for _, filterInfo in ipairs(filters) do
        local count = self:GetFilterCount(filterInfo.id)
        local isActive = (filterInfo.id == quickFilter)

        local btn = CreateFrame("Button", nil, bar, "BackdropTemplate")
        btn:SetSize(70, 24)
        btn:SetPoint("LEFT", bar, "LEFT", xOffset, 0)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        btnText:SetPoint("CENTER")
        btnText:SetText(filterInfo.label .. " " .. count)
        btn.text = btnText

        -- Track active state on the button itself
        btn.isActive = isActive
        btn.filterId = filterInfo.id

        -- Set active/inactive visual with explicit boolean check
        local function SetActive(active)
            active = (active == true)  -- Ensure boolean
            btn.isActive = active
            if active then
                btn:SetBackdropColor(0.2, 0.5, 0.2, 0.9)
                btn:SetBackdropBorderColor(0.4, 1.0, 0.4, 1)
                btnText:SetTextColor(0.4, 1.0, 0.4)
            else
                btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                btnText:SetTextColor(0.7, 0.7, 0.7)
            end
        end
        btn.SetActive = SetActive
        SetActive(isActive)

        btn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            self:SetQuickFilter(filterInfo.id)
        end)

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 0.84, 0, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            -- Restore border color based on tracked active state
            if self.isActive then
                self:SetBackdropBorderColor(0.4, 1.0, 0.4, 1)
            else
                self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
        end)

        self.quickFilterButtons[filterInfo.id] = btn
        xOffset = xOffset + 74
    end

    return bar
end

--[[
    Set quick filter and refresh travelers list
    @param filterId string - Filter identifier
]]
function Journal:SetQuickFilter(filterId)
    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    -- Ensure travelers sub-table exists
    if not socialUI.travelers then
        socialUI.travelers = { quickFilter = "all", searchText = "", sortOption = "last_seen" }
    end
    socialUI.travelers.quickFilter = filterId

    -- Update button visuals (buttons persist across refreshes)
    -- Use explicit loop to ensure each button gets correct state
    for id, btn in pairs(self.quickFilterButtons) do
        if btn and btn.SetActive then
            local shouldBeActive = (id == filterId)
            btn:SetActive(shouldBeActive)
            HopeAddon:Debug("QuickFilter: Button", id, "active=", shouldBeActive)
        end
    end

    self:RefreshTravelersList()
end

--[[
    Create a unified traveler row
    @param parent Frame - Parent frame
    @param entry table - Traveler entry data
    @return Frame - Row frame
]]
function Journal:CreateTravelerRow(parent, entry)
    local C = HopeAddon.Constants
    local Relationships = HopeAddon.Relationships
    local Badges = HopeAddon.Badges

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(C.SOCIAL_TAB.TRAVELER_ROW_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    local classColor = entry.class and HopeAddon:GetClassColor(entry.class) or { r = 0.5, g = 0.5, b = 0.5 }
    row:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.6)

    -- Online status indicator
    local statusDot = row:CreateTexture(nil, "OVERLAY")
    statusDot:SetSize(10, 10)
    statusDot:SetPoint("LEFT", row, "LEFT", 8, 0)
    statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
    local status = self:GetOnlineStatus(entry.lastSeenTime)
    if status == "online" then
        statusDot:SetVertexColor(0.2, 1.0, 0.2)
    elseif status == "away" then
        statusDot:SetVertexColor(1.0, 0.8, 0.2)
    else
        statusDot:SetVertexColor(0.5, 0.5, 0.5)
    end

    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(28, 28)
    classIcon:SetPoint("LEFT", statusDot, "RIGHT", 6, 0)
    local coords = CLASS_ICON_TCOORDS[entry.class]
    if coords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name with title
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12, "")
    nameText:SetPoint("LEFT", classIcon, "RIGHT", 8, 4)

    local colorHex = string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
    local displayName = "|cFF" .. colorHex .. entry.name .. "|r"
    if entry.selectedTitle and entry.selectedTitle ~= "" then
        local titleColor = Badges and Badges:GetTitleColor(entry.selectedTitle) or "FFD700"
        displayName = displayName .. " |cFF" .. titleColor .. "<" .. entry.selectedTitle .. ">|r"
    end
    nameText:SetText(displayName)

    -- Zone/status text
    local zoneText = row:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    zoneText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    zoneText:SetText(entry.lastSeenZone or "Unknown")
    zoneText:SetTextColor(0.6, 0.6, 0.6)

    -- Relationship tag (if set)
    local relType = HopeAddon.charDb.social.relationshipTypes and HopeAddon.charDb.social.relationshipTypes[entry.name]
    if relType and relType ~= "NONE" then
        local relDef = C.RELATIONSHIP_TYPES[relType]
        if relDef then
            local relTag = row:CreateFontString(nil, "OVERLAY")
            relTag:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
            relTag:SetPoint("LEFT", nameText, "RIGHT", 8, 0)
            relTag:SetText("[" .. relDef.label .. "]")
            local r, g, b = HopeAddon.ColorUtils:HexToRGB(relDef.color)
            relTag:SetTextColor(r, g, b)
        end
    end

    -- Action icon buttons (right side)
    -- Layout: [Whisper] [Invite] [Game] [Companion] - right to left
    local ICON_SIZE = 22
    local ICON_SPACING = 4
    local ICON_PADDING = 8

    -- Helper to create icon button with tooltip
    local function CreateActionIcon(parent, texture, tooltipText, onClick)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(ICON_SIZE, ICON_SIZE)
        btn:RegisterForClicks("LeftButtonUp")  -- Required for button to receive click events

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(texture)
        icon:SetVertexColor(0.7, 0.7, 0.7)  -- Normal: dimmed
        btn.icon = icon

        btn:SetScript("OnEnter", function(self)
            self.icon:SetVertexColor(1, 0.84, 0)  -- Hover: gold
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltipText, 1, 1, 1)
            GameTooltip:Show()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        end)

        btn:SetScript("OnLeave", function(self)
            self.icon:SetVertexColor(0.7, 0.7, 0.7)  -- Reset
            GameTooltip:Hide()
        end)

        btn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            onClick()
        end)

        return btn
    end

    -- Companion button (rightmost)
    local isCompanion = HopeAddon.Companions and HopeAddon.Companions:IsCompanion(entry.name)
    local companionBtn = CreateActionIcon(row,
        "Interface\\COMMON\\ReputationStar",
        isCompanion and "Remove from companions" or "Add to companions",
        function()
            if HopeAddon.Companions then
                if HopeAddon.Companions:IsCompanion(entry.name) then
                    HopeAddon.Companions:RemoveCompanion(entry.name)
                else
                    HopeAddon.Companions:SendRequest(entry.name)
                end
                self:RefreshTravelersList()
            end
        end
    )
    companionBtn:SetPoint("RIGHT", row, "RIGHT", -ICON_PADDING, 0)
    companionBtn.icon:SetTexCoord(0, 0.5, 0, 0.5)
    if isCompanion then
        companionBtn.icon:SetVertexColor(1, 0.84, 0)  -- Gold for companions
    end

    -- Romance heart button (between companion and game)
    local romanceBtn = nil
    local romance = HopeAddon:GetSocialRomance()
    if romance and HopeAddon.Romance then
        local isPartner = romance.partner and romance.partner == entry.name
        local isPendingOutgoing = romance.pendingOutgoing and romance.pendingOutgoing.to == entry.name
        local isPendingIncoming = romance.pendingIncoming and romance.pendingIncoming[entry.name] ~= nil

        romanceBtn = CreateFrame("Button", nil, row)
        romanceBtn:SetSize(ICON_SIZE, ICON_SIZE)
        romanceBtn:RegisterForClicks("LeftButtonUp")  -- Required for button to receive click events
        romanceBtn:SetPoint("RIGHT", companionBtn, "LEFT", -ICON_SPACING, 0)

        local heartIcon = romanceBtn:CreateTexture(nil, "ARTWORK")
        heartIcon:SetAllPoints()
        heartIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        romanceBtn.icon = heartIcon

        if isPartner then
            -- Already dating - bright pink
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard02")
            heartIcon:SetVertexColor(1, 0.2, 0.6, 1)
            romanceBtn:SetScript("OnEnter", function(self)
                self.icon:SetVertexColor(1, 0.4, 0.8, 1)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("In a relationship", 1.0, 0.08, 0.58)
                GameTooltip:Show()
            end)
            romanceBtn:SetScript("OnLeave", function(self)
                self.icon:SetVertexColor(1, 0.2, 0.6, 1)
                GameTooltip:Hide()
            end)

        elseif isPendingOutgoing then
            -- Proposal pending - candy icon
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCandy")
            heartIcon:SetVertexColor(1, 0.5, 0.8, 1)
            romanceBtn:SetScript("OnEnter", function(self)
                self.icon:SetVertexColor(1, 0.7, 0.9, 1)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("Proposal pending...", 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Waiting for response", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end)
            romanceBtn:SetScript("OnLeave", function(self)
                self.icon:SetVertexColor(1, 0.5, 0.8, 1)
                GameTooltip:Hide()
            end)

        elseif isPendingIncoming then
            -- They proposed - gold heart
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard02")
            heartIcon:SetVertexColor(1, 0.8, 0.2, 1)
            romanceBtn:SetScript("OnEnter", function(self)
                self.icon:SetVertexColor(1, 0.9, 0.4, 1)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(entry.name .. " proposed!", 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Go to Companions tab to respond", 0.7, 0.7, 0.7)
                GameTooltip:Show()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            romanceBtn:SetScript("OnLeave", function(self)
                self.icon:SetVertexColor(1, 0.8, 0.2, 1)
                GameTooltip:Hide()
            end)
            romanceBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                Journal:SelectSocialSubTab("companions")
            end)

        elseif romance.status == "SINGLE" then
            -- Single - grey heart, pink on hover
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard01")
            heartIcon:SetVertexColor(0.5, 0.5, 0.5, 0.7)
            romanceBtn:SetScript("OnEnter", function(self)
                self.icon:SetVertexColor(1, 0.4, 0.7, 1)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("Propose to " .. entry.name, 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Click to send a proposal", 0.7, 0.7, 0.7)
                GameTooltip:Show()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            romanceBtn:SetScript("OnLeave", function(self)
                self.icon:SetVertexColor(0.5, 0.5, 0.5, 0.7)
                GameTooltip:Hide()
            end)
            romanceBtn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                HopeAddon.Romance:ProposeToPlayer(entry.name)
                Journal:RefreshTravelersList()
            end)

        else
            -- Dating someone else - very dim
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard01")
            heartIcon:SetVertexColor(0.3, 0.3, 0.3, 0.5)
            romanceBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("Already in a relationship", 0.5, 0.5, 0.5)
                GameTooltip:Show()
            end)
            romanceBtn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    -- Game button
    local gameBtn = CreateActionIcon(row,
        "Interface\\ICONS\\INV_Misc_Dice_02",
        "Challenge to game",
        function()
            if HopeAddon.MinigamesUI then
                HopeAddon.MinigamesUI:ShowGameSelectionPopup(entry.name)
            end
        end
    )
    local gameAnchor = romanceBtn or companionBtn
    gameBtn:SetPoint("RIGHT", gameAnchor, "LEFT", -ICON_SPACING, 0)

    -- Invite button
    local inviteBtn = CreateActionIcon(row,
        "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up",
        "Invite to party",
        function()
            InviteUnit(entry.name)
        end
    )
    inviteBtn:SetPoint("RIGHT", gameBtn, "LEFT", -ICON_SPACING, 0)

    -- Whisper button
    local whisperBtn = CreateActionIcon(row,
        "Interface\\CHATFRAME\\UI-ChatIcon-Chat-Up",
        "Whisper " .. entry.name,
        function()
            ChatFrame_OpenChat("/w " .. entry.name .. " ")
        end
    )
    whisperBtn:SetPoint("RIGHT", inviteBtn, "LEFT", -ICON_SPACING, 0)

    -- Row hover effect (no click action)
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    end)

    return row
end

--[[
    Populate the Feed sub-tab with activity feed
]]
function Journal:PopulateSocialFeed()
    local content = self.socialContainers.content
    if not content then return end

    local socialUI = HopeAddon:GetSocialUI()
    if not socialUI then return end

    -- Hide the new activities banner when refreshing
    self:HideNewActivitiesBanner()

    local C = HopeAddon.Constants

    -- Get feed with optional filter
    local filterType = socialUI.feed and socialUI.feed.filter or "all"
    local allActivities = {}
    if HopeAddon.ActivityFeed then
        allActivities = HopeAddon.ActivityFeed:GetFeed() or {}
    end

    local activities = {}
    for _, activity in ipairs(allActivities) do
        if filterType == "all" or (activity.type and activity.type:lower() == filterType) then
            table.insert(activities, activity)
        end
    end

    -- Group by time (Now, Earlier Today, Yesterday, This Week)
    local now = time()
    local todayStart = now - (now % 86400)
    local grouped = {
        now = {},
        earlier = {},
        yesterday = {},
        thisWeek = {},
        older = {},
    }

    for _, activity in ipairs(activities) do
        local age = now - (activity.time or 0)
        if age < 3600 then
            table.insert(grouped.now, activity)
        elseif (activity.time or 0) >= todayStart then
            table.insert(grouped.earlier, activity)
        elseif (activity.time or 0) >= todayStart - 86400 then
            table.insert(grouped.yesterday, activity)
        elseif age < 604800 then
            table.insert(grouped.thisWeek, activity)
        else
            table.insert(grouped.older, activity)
        end
    end

    -- Create rows with time group headers
    local yOffset = 0
    local groups = {
        { key = "now", label = "Now" },
        { key = "earlier", label = "Earlier Today" },
        { key = "yesterday", label = "Yesterday" },
        { key = "thisWeek", label = "This Week" },
        { key = "older", label = "Older" },
    }

    for _, group in ipairs(groups) do
        local items = grouped[group.key]
        if #items > 0 then
            -- Group header
            local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            header:SetPoint("TOPLEFT", content, "TOPLEFT", 8, yOffset - 8)
            header:SetText("--- " .. group.label .. " ---")
            header:SetTextColor(0.5, 0.5, 0.5)
            self:TrackSocialRegion(header)
            yOffset = yOffset - 24

            -- Activity rows
            for _, activity in ipairs(items) do
                local row = self:CreateFeedRow(content, activity)
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
                row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
                yOffset = yOffset - C.SOCIAL_TAB.FEED_ROW_HEIGHT - 2
            end
        end
    end

    -- Mark feed as seen (socialUI already validated at function start)
    if socialUI.feed then
        socialUI.feed.lastSeenTimestamp = time()
    end

    -- Empty state
    if #activities == 0 then
        local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("CENTER", content, "CENTER", 0, 0)
        emptyText:SetText("No recent activity.\nYour Fellow Travelers' adventures will appear here!")
        emptyText:SetTextColor(0.6, 0.6, 0.6)
        emptyText:SetJustifyH("CENTER")
        self:TrackSocialRegion(emptyText)
        yOffset = -100
    end

    -- Adjust content height
    content:SetHeight(math.abs(yOffset) + 20)
end

--[[
    Create a feed activity row
    @param parent Frame - Parent frame
    @param activity table - Activity data
    @return Frame - Row frame
]]
function Journal:CreateFeedRow(parent, activity)
    local C = HopeAddon.Constants

    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetHeight(C.SOCIAL_TAB.FEED_ROW_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(0.1, 0.1, 0.1, 0.7)

    -- Get border color based on activity type
    local borderR, borderG, borderB = 0.3, 0.3, 0.3
    if HopeAddon.ActivityFeed and HopeAddon.ActivityFeed.GetActivityBorderColor then
        borderR, borderG, borderB = HopeAddon.ActivityFeed:GetActivityBorderColor(activity.type)
    elseif activity.type == "IC" or activity.type == "IC_POST" then
        -- IC Post: Fel green
        borderR, borderG, borderB = 0.2, 0.8, 0.2
    elseif activity.type == "ANON" then
        -- Anonymous: Arcane purple
        borderR, borderG, borderB = 0.61, 0.19, 1.0
    elseif activity.type == "LOOT" then
        -- Loot: Gold
        borderR, borderG, borderB = 1.0, 0.84, 0
    elseif activity.type == "BOSS" then
        -- Boss kills: Hellfire red
        borderR, borderG, borderB = 0.9, 0.2, 0.1
    elseif activity.type == "BADGE" then
        -- Badges: Gold
        borderR, borderG, borderB = 1.0, 0.84, 0
    end
    row:SetBackdropBorderColor(borderR, borderG, borderB, 0.8)

    -- Activity type icon
    local typeIcon = row:CreateTexture(nil, "ARTWORK")
    typeIcon:SetSize(24, 24)
    typeIcon:SetPoint("LEFT", row, "LEFT", 8, 0)

    -- Get icon based on activity type - use new constants if available
    local iconPath = "Interface\\Icons\\INV_Misc_QuestionMark"
    if C.FEED_ACTIVITY_ICONS and C.FEED_ACTIVITY_ICONS[activity.type] then
        iconPath = C.FEED_ACTIVITY_ICONS[activity.type]
    elseif activity.type == "IC" or activity.type == "IC_POST" then
        -- IC Post: Speech bubble / RP mask
        iconPath = "Interface\\Icons\\Spell_Holy_MindVision"
    elseif activity.type == "ANON" then
        -- Anonymous: Scroll
        iconPath = "Interface\\Icons\\INV_Scroll_01"
    elseif activity.type == "BOSS" then
        iconPath = "Interface\\Icons\\Achievement_Boss_Gruul"
    elseif activity.type == "LVL" or activity.type == "LEVEL" then
        iconPath = "Interface\\Icons\\Spell_Holy_SurgeOfLight"
    elseif activity.type == "GAME" then
        iconPath = "Interface\\Icons\\INV_Misc_Dice_02"
    elseif activity.type == "BADGE" then
        iconPath = "Interface\\Icons\\Achievement_General"
    elseif activity.type == "STA" or activity.type == "STATUS" then
        iconPath = "Interface\\Icons\\Spell_Holy_MindVision"
    elseif activity.type == "RUM" or activity.type == "RUMOR" then
        iconPath = "Interface\\Icons\\INV_Letter_15"
    elseif activity.type == "LOOT" then
        iconPath = "Interface\\Icons\\INV_Misc_Bag_10"
    elseif activity.type == "ROM" or activity.type == "ROMANCE" then
        iconPath = "Interface\\Icons\\INV_ValentinesCard02"
    end
    typeIcon:SetTexture(iconPath)

    -- Activity text
    local activityText = row:CreateFontString(nil, "OVERLAY")
    activityText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
    activityText:SetPoint("LEFT", typeIcon, "RIGHT", 8, 4)
    activityText:SetPoint("RIGHT", row, "RIGHT", -80, 4)
    activityText:SetJustifyH("LEFT")

    local text = ""
    if HopeAddon.ActivityFeed and HopeAddon.ActivityFeed.FormatActivity then
        text = HopeAddon.ActivityFeed:FormatActivity(activity)
    else
        text = (activity.player or "Someone") .. " did something"
    end
    activityText:SetText(text)

    -- Set text color based on activity type
    if activity.type == "IC" or activity.type == "IC_POST" then
        -- IC posts: Gold/warm
        activityText:SetTextColor(1.0, 0.9, 0.7)
    elseif activity.type == "ANON" then
        -- Anonymous: Slightly purple/mysterious
        activityText:SetTextColor(0.85, 0.8, 0.95)
    else
        activityText:SetTextColor(0.9, 0.9, 0.9)
    end

    -- Context/zone text (hidden for anonymous posts to preserve anonymity)
    local contextText = row:CreateFontString(nil, "OVERLAY")
    contextText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    contextText:SetPoint("TOPLEFT", activityText, "BOTTOMLEFT", 0, -2)

    -- For anonymous posts, don't show zone/context info
    local isAnonymous = (activity.type == "ANON")
    local context = ""
    if not isAnonymous then
        context = activity.zone or ""
        -- For IC/user posts, show the text content is already in main text, no need for context
        if activity.type == "IC" or activity.type == "RUM" then
            context = ""
        elseif activity.data and type(activity.data) == "string" then
            context = activity.data
        end
    end
    contextText:SetText(context)
    contextText:SetTextColor(0.5, 0.5, 0.5)

    -- Time ago
    local timeText = row:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    timeText:SetPoint("RIGHT", row, "RIGHT", -40, 0)
    local timeAgo = ""
    if HopeAddon.ActivityFeed and HopeAddon.ActivityFeed.GetRelativeTime then
        timeAgo = HopeAddon.ActivityFeed:GetRelativeTime(activity.time)
    else
        local age = time() - (activity.time or time())
        if age < 60 then
            timeAgo = "now"
        elseif age < 3600 then
            timeAgo = math.floor(age / 60) .. "m"
        elseif age < 86400 then
            timeAgo = math.floor(age / 3600) .. "h"
        else
            timeAgo = math.floor(age / 86400) .. "d"
        end
    end
    timeText:SetText(timeAgo)
    timeText:SetTextColor(0.5, 0.5, 0.5)

    -- Mug button
    local mugBtn = CreateFrame("Button", nil, row)
    mugBtn:SetSize(20, 20)
    mugBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    local mugTex = mugBtn:CreateTexture(nil, "ARTWORK")
    mugTex:SetAllPoints()
    mugTex:SetTexture("Interface\\Icons\\INV_Drink_04")

    local hasMugged = HopeAddon.ActivityFeed and HopeAddon.ActivityFeed:HasMugged(activity.id)
    if hasMugged then
        mugTex:SetVertexColor(1, 0.84, 0)
    else
        mugTex:SetVertexColor(0.5, 0.5, 0.5)
    end

    mugBtn:SetScript("OnClick", function()
        HopeAddon.Sounds:PlayClick()
        if HopeAddon.ActivityFeed then
            HopeAddon.ActivityFeed:GiveMug(activity.id)
            mugTex:SetVertexColor(1, 0.84, 0)
        end
    end)

    mugBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(mugBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Raise a Mug!", 1, 0.84, 0)
        GameTooltip:AddLine("Show appreciation for this activity", 0.8, 0.8, 0.8)
        if activity.mugs and activity.mugs > 0 then
            GameTooltip:AddLine(activity.mugs .. " mugs raised", 0.4, 1.0, 0.4)
        end
        GameTooltip:Show()
    end)
    mugBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return row
end

--[[
    Populate the Companions sub-tab with companion grid
]]
function Journal:PopulateSocialCompanions()
    local content = self.socialContainers.content
    if not content then return end

    local C = HopeAddon.Constants

    -- Reset yOffset tracker
    self.companionYOffset = 0

    -- Add Romance Status section at the top
    self:CreateRomanceStatusSection(content)

    -- Get companions grouped by status
    local companions = {}
    if HopeAddon.Companions then
        companions = HopeAddon.Companions:GetAllCompanions() or {}
    end

    local online, away, offline = {}, {}, {}

    for _, comp in ipairs(companions) do
        local status = self:GetOnlineStatus(comp.lastSeenTime)
        if status == "online" then
            table.insert(online, comp)
        elseif status == "away" then
            table.insert(away, comp)
        else
            table.insert(offline, comp)
        end
    end

    -- Get pending requests
    local requests = {}
    if HopeAddon.Companions then
        requests = HopeAddon.Companions:GetIncomingRequests() or {}
    end

    -- Pending requests section (if any)
    if #requests > 0 then
        self:CreateCompanionRequests(content, requests)
    end

    -- Create sections
    if #online > 0 then
        self:CreateCompanionSection(content, "Online Now", online, "online")
    end
    if #away > 0 then
        self:CreateCompanionSection(content, "Away", away, "away")
    end
    if #offline > 0 then
        self:CreateCompanionSection(content, "Offline", offline, "offline")
    end

    -- Empty state
    if #companions == 0 and #requests == 0 then
        local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("CENTER", content, "CENTER", 0, 0)
        emptyText:SetText("No companions yet.\n\nClick the star on any traveler\nto add them as a companion!")
        emptyText:SetTextColor(0.6, 0.6, 0.6)
        emptyText:SetJustifyH("CENTER")
        self:TrackSocialRegion(emptyText)
        self.companionYOffset = -100
    end

    -- Adjust content height
    content:SetHeight(math.abs(self.companionYOffset) + 20)
end

--[[
    Create the Romance Status section at top of Companions tab
    Shows current relationship status, partner info, pending proposals
    @param parent Frame - Parent frame
]]
function Journal:CreateRomanceStatusSection(parent)
    local C = HopeAddon.Constants
    local Romance = HopeAddon.Romance
    if not Romance then return end

    local romanceData = Romance:GetStatus()
    local status = romanceData.status or "SINGLE"
    local statusDef = C.ROMANCE_STATUS[status]

    -- Section container with pink/grey border based on status
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(parent:GetWidth() - 16, 80)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)

    local borderColor = status == "DATING" and {1, 0.08, 0.58, 1} or {0.5, 0.5, 0.5, 0.8}
    container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    container:SetBackdropColor(0.1, 0.05, 0.1, 0.9)
    container:SetBackdropBorderColor(unpack(borderColor))
    self:TrackSocialRegion(container)

    -- Heart icon
    local heartIcon = container:CreateTexture(nil, "ARTWORK")
    heartIcon:SetSize(28, 28)
    heartIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 12, -10)
    if statusDef and statusDef.icon then
        heartIcon:SetTexture("Interface\\Icons\\" .. statusDef.icon)
    else
        heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard01")
    end
    self:TrackSocialRegion(heartIcon)

    -- Title: "RELATIONSHIP STATUS"
    local titleText = container:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
    titleText:SetPoint("LEFT", heartIcon, "RIGHT", 8, 4)
    titleText:SetText("RELATIONSHIP STATUS")
    titleText:SetTextColor(1, 0.41, 0.71)  -- Hot pink
    self:TrackSocialRegion(titleText)

    -- Status text
    local statusText = container:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
    statusText:SetPoint("TOPLEFT", heartIcon, "BOTTOMLEFT", 0, -4)

    if status == "DATING" and romanceData.partner then
        -- Get partner info
        local partnerInfo = Romance:GetPartnerInfo()
        local partnerClass = partnerInfo and partnerInfo.class or "UNKNOWN"
        local classColor = HopeAddon:GetClassColor(partnerClass)

        statusText:SetText("|cFFFF1493<3 Dating:|r " ..
            string.format("|cFF%02X%02X%02X%s|r",
                classColor.r * 255, classColor.g * 255, classColor.b * 255,
                romanceData.partner))

        -- "Since" date
        if romanceData.since then
            local sinceText = container:CreateFontString(nil, "OVERLAY")
            sinceText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
            sinceText:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -2)
            sinceText:SetText("Since: " .. date("%b %d, %Y", romanceData.since))
            sinceText:SetTextColor(0.6, 0.6, 0.6)
            self:TrackSocialRegion(sinceText)
        end

        -- Break Up button
        local breakupBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
        breakupBtn:SetSize(80, 22)
        breakupBtn:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
        breakupBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        breakupBtn:SetBackdropColor(0.4, 0.1, 0.1, 0.9)
        breakupBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)

        local breakupText = breakupBtn:CreateFontString(nil, "OVERLAY")
        breakupText:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
        breakupText:SetPoint("CENTER")
        breakupText:SetText("</3 Break Up")
        breakupText:SetTextColor(0.9, 0.5, 0.5)

        breakupBtn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            -- Show confirmation
            StaticPopupDialogs["HOPEADDON_BREAKUP_CONFIRM"] = {
                text = "Are you sure you want to break up with " .. romanceData.partner .. "?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    Romance:BreakUp("mutual")
                    Journal:ClearSocialContent()
                    Journal:PopulateSocialCompanions()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("HOPEADDON_BREAKUP_CONFIRM")
        end)

        breakupBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
        end)
        breakupBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
        end)

    elseif status == "PROPOSED" and romanceData.pendingOutgoing then
        -- Waiting for response
        statusText:SetText("|cFFFF69B4<3 Proposed to:|r " .. romanceData.pendingOutgoing.to)
        statusText:SetTextColor(1, 0.41, 0.71)

        local waitText = container:CreateFontString(nil, "OVERLAY")
        waitText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        waitText:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -2)
        waitText:SetText("Waiting for their response...")
        waitText:SetTextColor(0.6, 0.6, 0.6)
        self:TrackSocialRegion(waitText)

        -- Cancel button
        local cancelBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
        cancelBtn:SetSize(70, 22)
        cancelBtn:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
        cancelBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        cancelBtn:SetBackdropColor(0.3, 0.3, 0.3, 0.9)
        cancelBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY")
        cancelText:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
        cancelText:SetPoint("CENTER")
        cancelText:SetText("Cancel")
        cancelText:SetTextColor(0.8, 0.8, 0.8)

        cancelBtn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            Romance:CancelProposal()
            Journal:ClearSocialContent()
            Journal:PopulateSocialCompanions()
        end)

    else
        -- Single
        statusText:SetText("|cFF808080Status:|r Single")

        local hintText = container:CreateFontString(nil, "OVERLAY")
        hintText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        hintText:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -2)
        hintText:SetText("Click |cFFFF69B4\226\153\165|r on any Fellow Traveler to propose!")
        hintText:SetTextColor(0.6, 0.6, 0.6)
        self:TrackSocialRegion(hintText)
    end
    self:TrackSocialRegion(statusText)

    -- Check for incoming proposals
    local incomingRequests = Romance:GetIncomingRequests()
    if #incomingRequests > 0 then
        -- Expand container for proposals
        container:SetHeight(container:GetHeight() + 30 * #incomingRequests)

        local proposalY = -55
        for _, request in ipairs(incomingRequests) do
            local propRow = CreateFrame("Frame", nil, container)
            propRow:SetSize(container:GetWidth() - 20, 26)
            propRow:SetPoint("TOPLEFT", container, "TOPLEFT", 10, proposalY)

            local propText = propRow:CreateFontString(nil, "OVERLAY")
            propText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
            propText:SetPoint("LEFT", propRow, "LEFT", 0, 0)
            propText:SetText("|cFFFF69B4<3|r " .. request.name .. " wants to date you!")
            self:TrackSocialRegion(propText)

            -- Accept button
            local acceptBtn = CreateFrame("Button", nil, propRow, "BackdropTemplate")
            acceptBtn:SetSize(55, 20)
            acceptBtn:SetPoint("RIGHT", propRow, "RIGHT", -65, 0)
            acceptBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
                edgeSize = 6,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            acceptBtn:SetBackdropColor(0.2, 0.5, 0.2, 0.9)
            acceptBtn:SetBackdropBorderColor(0.3, 0.7, 0.3, 1)

            local accText = acceptBtn:CreateFontString(nil, "OVERLAY")
            accText:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
            accText:SetPoint("CENTER")
            accText:SetText("<3 Yes!")
            accText:SetTextColor(0.4, 1, 0.4)

            acceptBtn:SetScript("OnClick", function()
                HopeAddon.Sounds:PlayClick()
                Romance:AcceptProposal(request.name)
                Journal:ClearSocialContent()
                Journal:PopulateSocialCompanions()
            end)

            -- Decline button
            local declineBtn = CreateFrame("Button", nil, propRow, "BackdropTemplate")
            declineBtn:SetSize(55, 20)
            declineBtn:SetPoint("RIGHT", propRow, "RIGHT", 0, 0)
            declineBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
                edgeSize = 6,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            declineBtn:SetBackdropColor(0.4, 0.2, 0.2, 0.9)
            declineBtn:SetBackdropBorderColor(0.6, 0.3, 0.3, 1)

            local decText = declineBtn:CreateFontString(nil, "OVERLAY")
            decText:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
            decText:SetPoint("CENTER")
            decText:SetText("No")
            decText:SetTextColor(0.8, 0.5, 0.5)

            declineBtn:SetScript("OnClick", function()
                HopeAddon.Sounds:PlayClick()
                Romance:DeclineProposal(request.name)
                Journal:ClearSocialContent()
                Journal:PopulateSocialCompanions()
            end)

            proposalY = proposalY - 30
        end
    end

    self.companionYOffset = self.companionYOffset - container:GetHeight() - 16

    -- Add relationship history section if there are past relationships
    self:CreateRelationshipHistorySection(parent)
end

--[[
    Create relationship history display (past relationships)
    @param parent Frame - Parent frame
]]
function Journal:CreateRelationshipHistorySection(parent)
    local Romance = HopeAddon.Romance
    if not Romance then return end

    local history = Romance:GetRelationshipHistory()
    if #history == 0 then return end

    -- Collapsible container
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(parent:GetWidth() - 16, 30 + math.min(#history, 3) * 26)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)
    container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    container:SetBackdropColor(0.08, 0.05, 0.08, 0.9)
    container:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    self:TrackSocialRegion(container)

    -- Header with collapse toggle
    local headerBtn = CreateFrame("Button", nil, container)
    headerBtn:SetSize(container:GetWidth() - 10, 24)
    headerBtn:SetPoint("TOPLEFT", container, "TOPLEFT", 5, -3)

    -- Broken heart icon
    local historyIcon = headerBtn:CreateTexture(nil, "ARTWORK")
    historyIcon:SetSize(18, 18)
    historyIcon:SetPoint("LEFT", headerBtn, "LEFT", 2, 0)
    historyIcon:SetTexture("Interface\\Icons\\Spell_Shadow_SoulLeech_3")
    historyIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    historyIcon:SetVertexColor(0.5, 0.5, 0.5)
    self:TrackSocialRegion(historyIcon)

    local headerText = headerBtn:CreateFontString(nil, "OVERLAY")
    headerText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    headerText:SetPoint("LEFT", historyIcon, "RIGHT", 6, 0)
    headerText:SetText("Past Relationships (" .. #history .. ")")
    headerText:SetTextColor(0.6, 0.6, 0.6)
    self:TrackSocialRegion(headerText)

    -- Collapse arrow
    local arrow = headerBtn:CreateFontString(nil, "OVERLAY")
    arrow:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    arrow:SetPoint("RIGHT", headerBtn, "RIGHT", -5, 0)
    arrow:SetText("v")
    arrow:SetTextColor(0.5, 0.5, 0.5)
    self:TrackSocialRegion(arrow)

    -- Content frame (for collapsing)
    local contentFrame = CreateFrame("Frame", nil, container)
    contentFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 5, -28)
    contentFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -5, 5)
    self:TrackSocialRegion(contentFrame)

    -- History rows (show up to 3, most recent first)
    local rowY = 0
    for i = 1, math.min(#history, 3) do
        local rel = history[i]

        local row = CreateFrame("Frame", nil, contentFrame)
        row:SetSize(contentFrame:GetWidth(), 22)
        row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, rowY)
        self:TrackSocialRegion(row)

        -- Partner name
        local nameText = row:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(HopeAddon.assets.fonts.BODY, 10, "")
        nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
        nameText:SetText("|cFF808080</3|r " .. rel.partner)
        nameText:SetTextColor(0.7, 0.7, 0.7)
        self:TrackSocialRegion(nameText)

        -- Duration
        local durationText = row:CreateFontString(nil, "OVERLAY")
        durationText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        durationText:SetPoint("RIGHT", row, "RIGHT", -5, 0)
        durationText:SetText(Romance:FormatDuration(rel.duration))
        durationText:SetTextColor(0.5, 0.5, 0.5)
        self:TrackSocialRegion(durationText)

        -- End date
        local dateText = row:CreateFontString(nil, "OVERLAY")
        dateText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        dateText:SetPoint("RIGHT", durationText, "LEFT", -10, 0)
        dateText:SetText(date("%b %d", rel.ended))
        dateText:SetTextColor(0.5, 0.5, 0.5)
        self:TrackSocialRegion(dateText)

        rowY = rowY - 26
    end

    -- Show "and X more" if there are more than 3
    if #history > 3 then
        local moreText = contentFrame:CreateFontString(nil, "OVERLAY")
        moreText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
        moreText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, rowY)
        moreText:SetText("...and " .. (#history - 3) .. " more")
        moreText:SetTextColor(0.4, 0.4, 0.4)
        self:TrackSocialRegion(moreText)
    end

    -- Collapse/expand toggle
    container.isCollapsed = false
    container.fullHeight = container:GetHeight()
    container.collapsedHeight = 30

    headerBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayClick()
        end

        container.isCollapsed = not container.isCollapsed
        if container.isCollapsed then
            container:SetHeight(container.collapsedHeight)
            contentFrame:Hide()
            arrow:SetText(">")
        else
            container:SetHeight(container.fullHeight)
            contentFrame:Show()
            arrow:SetText("v")
        end
    end)

    headerBtn:SetScript("OnEnter", function()
        headerText:SetTextColor(0.8, 0.8, 0.8)
        arrow:SetTextColor(0.8, 0.8, 0.8)
    end)

    headerBtn:SetScript("OnLeave", function()
        headerText:SetTextColor(0.6, 0.6, 0.6)
        arrow:SetTextColor(0.5, 0.5, 0.5)
    end)

    self.companionYOffset = self.companionYOffset - container:GetHeight() - 12
end

--[[
    Create a section of companion cards
    @param parent Frame - Parent frame
    @param title string - Section title
    @param companions table - Array of companions
    @param status string - Status type (online, away, offline)
]]
function Journal:CreateCompanionSection(parent, title, companions, status)
    local C = HopeAddon.Constants

    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)
    header:SetText(title .. " (" .. #companions .. ")")
    if status == "online" then
        header:SetTextColor(0.2, 1.0, 0.2)
    elseif status == "away" then
        header:SetTextColor(1.0, 0.8, 0.2)
    else
        header:SetTextColor(0.5, 0.5, 0.5)
    end
    self:TrackSocialRegion(header)
    self.companionYOffset = self.companionYOffset - 24

    -- Create card grid (4 per row)
    local cardSize = C.SOCIAL_TAB.COMPANION_CARD_SIZE
    local cardsPerRow = C.SOCIAL_TAB.COMPANION_CARDS_PER_ROW
    local spacing = 8

    for i, companion in ipairs(companions) do
        local col = (i - 1) % cardsPerRow
        local cardRow = math.floor((i - 1) / cardsPerRow)

        local card = self:CreateCompanionCard(parent, companion, status)
        card:SetPoint("TOPLEFT", parent, "TOPLEFT",
            8 + col * (cardSize + spacing),
            self.companionYOffset - cardRow * (cardSize + spacing))
    end

    -- Adjust yOffset for next section
    local rows = math.ceil(#companions / cardsPerRow)
    self.companionYOffset = self.companionYOffset - rows * (cardSize + spacing) - 16
end

--[[
    Create pending companion requests section
    @param parent Frame - Parent frame
    @param requests table - Array of pending requests
]]
function Journal:CreateCompanionRequests(parent, requests)
    -- Section header
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)
    header:SetText("Pending Requests (" .. #requests .. ")")
    header:SetTextColor(1.0, 0.82, 0.0)
    self:TrackSocialRegion(header)
    self.companionYOffset = self.companionYOffset - 24

    -- Request rows
    for _, request in ipairs(requests) do
        local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        row:SetSize(parent:GetWidth() - 16, 30)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, self.companionYOffset)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 8, 0)
        text:SetText((request.name or "Unknown") .. " wants to be companions")

        local acceptBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
        acceptBtn:SetSize(60, 24)
        acceptBtn:SetPoint("RIGHT", row, "RIGHT", -70, 0)
        acceptBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        acceptBtn:SetBackdropColor(0.2, 0.6, 0.2, 0.9)
        acceptBtn:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
        local acceptText = acceptBtn:CreateFontString(nil, "OVERLAY")
        acceptText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        acceptText:SetPoint("CENTER")
        acceptText:SetText("Accept")
        acceptText:SetTextColor(0.4, 1.0, 0.4)

        acceptBtn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            if HopeAddon.Companions then
                HopeAddon.Companions:AcceptRequest(request.name)
            end
            self:ClearSocialContent()
            self:PopulateSocialCompanions()
        end)

        local declineBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
        declineBtn:SetSize(60, 24)
        declineBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        declineBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        declineBtn:SetBackdropColor(0.4, 0.2, 0.2, 0.9)
        declineBtn:SetBackdropBorderColor(0.6, 0.3, 0.3, 1)
        local declineText = declineBtn:CreateFontString(nil, "OVERLAY")
        declineText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
        declineText:SetPoint("CENTER")
        declineText:SetText("Decline")
        declineText:SetTextColor(0.8, 0.4, 0.4)

        declineBtn:SetScript("OnClick", function()
            HopeAddon.Sounds:PlayClick()
            if HopeAddon.Companions then
                HopeAddon.Companions:DeclineRequest(request.name)
            end
            self:ClearSocialContent()
            self:PopulateSocialCompanions()
        end)

        self.companionYOffset = self.companionYOffset - 34
    end

    self.companionYOffset = self.companionYOffset - 10
end

--[[
    Create a companion card
    @param parent Frame - Parent frame
    @param companion table - Companion data
    @param status string - Online status
    @return Frame - Card frame
]]
function Journal:CreateCompanionCard(parent, companion, status)
    local C = HopeAddon.Constants

    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(C.SOCIAL_TAB.COMPANION_CARD_SIZE, C.SOCIAL_TAB.COMPANION_CARD_SIZE)
    card:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    card:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    local classColor = companion.class and HopeAddon:GetClassColor(companion.class) or { r = 0.5, g = 0.5, b = 0.5 }
    card:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.7)

    -- Class icon
    local classIcon = card:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(24, 24)
    classIcon:SetPoint("TOP", card, "TOP", 0, -8)
    local coords = CLASS_ICON_TCOORDS[companion.class]
    if coords then
        classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        classIcon:SetTexCoord(unpack(coords))
    end

    -- Name
    local nameText = card:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 10, "")
    nameText:SetPoint("TOP", classIcon, "BOTTOM", 0, -4)
    nameText:SetText((companion.name or "?"):sub(1, 10))
    nameText:SetTextColor(classColor.r, classColor.g, classColor.b)

    -- Status indicator
    local statusText = card:CreateFontString(nil, "OVERLAY")
    statusText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    statusText:SetPoint("TOP", nameText, "BOTTOM", 0, -2)
    if status == "online" then
        statusText:SetText("● " .. ((companion.zone or ""):sub(1, 8)))
        statusText:SetTextColor(0.2, 1.0, 0.2)
    elseif status == "away" then
        local mins = math.floor((time() - (companion.lastSeenTime or 0)) / 60)
        statusText:SetText("○ " .. mins .. "m ago")
        statusText:SetTextColor(1.0, 0.8, 0.2)
    else
        local days = math.floor((time() - (companion.lastSeenTime or 0)) / 86400)
        statusText:SetText("- " .. days .. " days")
        statusText:SetTextColor(0.5, 0.5, 0.5)
    end

    -- RP Status
    local rpStatus = companion.profile and companion.profile.status or "OOC"
    local rpText = card:CreateFontString(nil, "OVERLAY")
    rpText:SetFont(HopeAddon.assets.fonts.BODY, 9, "")
    rpText:SetPoint("TOP", statusText, "BOTTOM", 0, -2)
    rpText:SetText(rpStatus)
    local rpDef = C.RP_STATUS[rpStatus]
    if rpDef then
        local r, g, b = HopeAddon.ColorUtils:HexToRGB(rpDef.color)
        rpText:SetTextColor(r, g, b)
    end

    -- Relationship badge
    local relType = HopeAddon.charDb.social.relationshipTypes and HopeAddon.charDb.social.relationshipTypes[companion.name]
    if relType and relType ~= "NONE" then
        local relDef = C.RELATIONSHIP_TYPES[relType]
        if relDef then
            local relBadge = card:CreateFontString(nil, "OVERLAY")
            relBadge:SetFont(HopeAddon.assets.fonts.HEADER, 9, "")
            relBadge:SetPoint("BOTTOM", card, "BOTTOM", 0, 8)
            relBadge:SetText("[" .. relDef.label .. "]")
            local r, g, b = HopeAddon.ColorUtils:HexToRGB(relDef.color)
            relBadge:SetTextColor(r, g, b)
        end
    end

    -- Romance heart button (top-right corner) - using actual icon textures
    local romance = HopeAddon:GetSocialRomance()
    if romance and HopeAddon.Romance then
        local heartBtn = CreateFrame("Button", nil, card)
        heartBtn:SetSize(18, 18)
        heartBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -3, -3)

        -- Icon texture (heart card icon from Valentine's set)
        local heartIcon = heartBtn:CreateTexture(nil, "ARTWORK")
        heartIcon:SetSize(16, 16)
        heartIcon:SetPoint("CENTER")
        heartIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- Trim icon borders

        -- Highlight on hover
        local highlight = heartBtn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(heartIcon)
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        highlight:SetBlendMode("ADD")
        highlight:SetAlpha(0.3)

        local isPartner = romance.partner and romance.partner == companion.name
        local isPendingOutgoing = romance.pendingOutgoing and romance.pendingOutgoing.to == companion.name
        -- pendingIncoming is a table keyed by name, not an array
        local isPendingIncoming = romance.pendingIncoming and romance.pendingIncoming[companion.name] ~= nil

        if isPartner then
            -- Already dating - bright pink heart card
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard02")
            heartIcon:SetVertexColor(1, 0.2, 0.6, 1)  -- Pink tint
            heartBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("In a relationship with " .. companion.name, 1.0, 0.08, 0.58)
                GameTooltip:Show()
            end)
            heartBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            heartBtn:SetScript("OnClick", nil) -- Can't propose to partner
        elseif isPendingOutgoing then
            -- Already proposed - candy (pending) icon
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCandy")
            heartIcon:SetVertexColor(1, 0.5, 0.8, 1)  -- Light pink
            heartBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Proposal pending...", 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Waiting for their response", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end)
            heartBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            heartBtn:SetScript("OnClick", nil) -- Already pending
        elseif isPendingIncoming then
            -- They proposed to us - glowing heart with exclamation
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard02")
            heartIcon:SetVertexColor(1, 0.8, 0.2, 1)  -- Gold/excited
            heartBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(companion.name .. " proposed to you!", 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Check relationship status section above", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end)
            heartBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            heartBtn:SetScript("OnClick", function()
                HopeAddon:Print("|cFFFF69B4" .. companion.name .. " proposed to you! Check the relationship status section above.|r")
            end)
        elseif romance.status == "SINGLE" then
            -- Single and available to propose - grey heart that turns pink on hover
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard01")
            heartIcon:SetVertexColor(0.5, 0.5, 0.5, 0.7)  -- Grey/desaturated
            heartBtn:SetScript("OnEnter", function(self)
                heartIcon:SetVertexColor(1, 0.4, 0.7, 1)  -- Pink on hover
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Propose to " .. companion.name .. "?", 1.0, 0.41, 0.71)
                GameTooltip:AddLine("Click to send a proposal", 0.7, 0.7, 0.7)
                GameTooltip:Show()
            end)
            heartBtn:SetScript("OnLeave", function()
                heartIcon:SetVertexColor(0.5, 0.5, 0.5, 0.7)  -- Back to grey
                GameTooltip:Hide()
            end)
            heartBtn:SetScript("OnClick", function()
                HopeAddon.Romance:ProposeToPlayer(companion.name)
                HopeAddon.Sounds:PlayClick()
                -- Refresh the social tab
                if Journal.currentTab == "social" then
                    Journal:PopulateSocial()
                end
            end)
        else
            -- Already in a relationship with someone else - very dim heart
            heartIcon:SetTexture("Interface\\Icons\\INV_ValentinesCard01")
            heartIcon:SetVertexColor(0.3, 0.3, 0.3, 0.5)  -- Very grey
            heartBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Already in a relationship", 0.5, 0.5, 0.5)
                GameTooltip:Show()
            end)
            heartBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            heartBtn:SetScript("OnClick", nil) -- Can't propose while dating
        end
    end

    -- Action icons at bottom (Whisper, Invite, Game)
    local ICON_SIZE = 18
    local ICON_SPACING = 6

    -- Helper to create icon button
    local function CreateCardIcon(parent, texture, tooltipText, onClick)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(ICON_SIZE, ICON_SIZE)

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(texture)
        icon:SetVertexColor(0.6, 0.6, 0.6)
        btn.icon = icon

        btn:SetScript("OnEnter", function(self)
            self.icon:SetVertexColor(1, 0.84, 0)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function(self)
            self.icon:SetVertexColor(0.6, 0.6, 0.6)
            GameTooltip:Hide()
        end)

        btn:SetScript("OnClick", function()
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            onClick()
        end)

        return btn
    end

    -- Icon row at bottom center
    local iconWidth = (ICON_SIZE * 3) + (ICON_SPACING * 2)
    local startX = -iconWidth / 2

    local whisperBtn = CreateCardIcon(card,
        "Interface\\CHATFRAME\\UI-ChatIcon-Chat-Up",
        "Whisper " .. companion.name,
        function() ChatFrame_OpenChat("/w " .. companion.name .. " ") end
    )
    whisperBtn:SetPoint("BOTTOM", card, "BOTTOM", startX + ICON_SIZE/2, 6)

    local inviteBtn = CreateCardIcon(card,
        "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up",
        "Invite to party",
        function() InviteUnit(companion.name) end
    )
    inviteBtn:SetPoint("LEFT", whisperBtn, "RIGHT", ICON_SPACING, 0)

    local gameBtn = CreateCardIcon(card,
        "Interface\\ICONS\\INV_Misc_Dice_02",
        "Challenge to game",
        function()
            if HopeAddon.MinigamesUI then
                HopeAddon.MinigamesUI:ShowGameSelectionPopup(companion.name)
            end
        end
    )
    gameBtn:SetPoint("LEFT", inviteBtn, "RIGHT", ICON_SPACING, 0)

    -- Card hover effect (no click action)
    card:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    end)
    card:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    end)

    return card
end

--[[
    Populate the Calendar sub-tab with event calendar
]]
function Journal:PopulateSocialCalendar()
    local content = self.socialContainers.content
    if not content then return end

    local CalendarUI = HopeAddon.CalendarUI
    if not CalendarUI then
        -- Fallback if CalendarUI not loaded
        local noCalendar = content:CreateFontString(nil, "OVERLAY")
        noCalendar:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
        noCalendar:SetPoint("TOP", content, "TOP", 0, -40)
        noCalendar:SetText("Calendar module not available")
        noCalendar:SetTextColor(0.7, 0.7, 0.7)
        self:TrackSocialRegion(noCalendar)
        return
    end

    local C = HopeAddon.Constants
    local UI = C.CALENDAR_UI

    -- Create calendar header
    local header = CalendarUI:CreateCalendarHeader(content)
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)

    -- Create month navigation bar
    local navBar = CalendarUI:CreateMonthNavigation(content)
    navBar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    navBar:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -8)
    content.navBar = navBar

    -- Create month grid
    local monthGrid = CalendarUI:CreateMonthGrid(content)
    monthGrid:SetPoint("TOP", navBar, "BOTTOM", 0, -8)

    -- Populate the grid
    CalendarUI:PopulateMonthGrid(monthGrid)

    -- Create selected day panel
    local dayPanel = CalendarUI:CreateSelectedDayPanel(content)
    dayPanel:SetPoint("TOPLEFT", monthGrid, "BOTTOMLEFT", 0, -15)
    dayPanel:SetPoint("RIGHT", content, "RIGHT", 0, 0)

    -- Restore selected date if any
    local socialUI = HopeAddon:GetSocialUI()
    if socialUI and socialUI.calendar and socialUI.calendar.selectedDate then
        CalendarUI:SelectDate(socialUI.calendar.selectedDate)
    end

    -- Update content height
    local totalHeight = header:GetHeight() + navBar:GetHeight() + monthGrid:GetHeight() + dayPanel:GetHeight() + 40
    content:SetHeight(totalHeight)
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
    nameText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
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
    levelText:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
            btnText:SetFont(HopeAddon.assets.fonts.HEADER, 11, "")
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

--------------------------------------------------------------------------------
-- ARMORY TAB STATE
--------------------------------------------------------------------------------

Journal.armoryUI = {
    container = nil,
    phaseBar = nil,        -- Slim phase selector bar (was tierBar)
    phaseButtons = {},     -- Phase 1-5 buttons (was tierButtons)
    specDropdown = nil,
    characterView = nil,   -- Centered character view (replaces paperdoll + detailPanel)
    modelFrame = nil,
    slotsContainer = nil,
    slotButtons = {},
    infoCards = {},        -- Slot info cards (iLvl + upgrade arrow)
    gearPopup = nil,       -- Floating gear popup (replaces detailPanel)
    footer = nil,
}

Journal.armoryState = {
    selectedPhase = 1,  -- Phase 1-5 (replaces selectedTier 4-6)
    selectedSpec = nil,
    selectedSlot = nil,
    popupVisible = false,  -- Track if gear popup is open
    expandedSections = {},
    slotStatuses = {},
    wishlist = {},
    -- Gear popup state (Phase 60 redesign)
    popup = {
        activeFilter = "all",       -- Current filter: "all" or source key from SOURCE_GROUPS
        expandedGroups = {},        -- { [sourceKey] = true/false } - which groups are expanded
        sortOrder = "bis",          -- "bis" (default), "ilvl", "source"
        lastSlot = nil,             -- Last slot clicked for popup
        acquiredItems = {},         -- Cache of { [itemId] = true } for owned items
    },
}

-- Attunements tab state (Phase 61 - phase-based theming)
Journal.attunementsState = {
    selectedPhase = 0,  -- 0 = All, 1-3 = specific phase
}

Journal.attunementsUI = {
    phaseBar = nil,
    phaseButtons = {},
}

Journal.armoryPools = {
    upgradeCard = nil,
    sectionHeader = nil,
    statRow = nil,
    sourceTag = nil,
    wishlistBtn = nil,
    infoCard = nil,         -- Slot info cards (iLvl + upgrade arrow)
    -- Gear popup pools (Phase 60 redesign)
    bisCard = nil,          -- Featured BiS item card
    popupItemRow = nil,     -- Alternative item rows in popup
    groupHeader = nil,      -- Collapsible group headers
    filterBtn = nil,        -- Source filter buttons
}


--------------------------------------------------------------------------------
-- ARMORY TAB FUNCTIONS
--------------------------------------------------------------------------------

--[[
    Populate the Armory tab
    Main entry point - creates containers and populates slot data
]]
function Journal:PopulateArmory()
    HopeAddon:Debug("PopulateArmory: Starting")
    local scrollContainer = self.mainFrame.scrollContainer
    if not scrollContainer then
        error("PopulateArmory: scrollContainer is nil")
    end
    HopeAddon:Debug("PopulateArmory: scrollContainer OK")

    -- Hide entire scroll container - Armory uses fixed layout, no scrolling needed
    -- Must hide the whole container (not just scroll bar) to prevent it blocking mouse input
    scrollContainer:Hide()

    -- Ensure charDb.armory exists early (defensive)
    if HopeAddon.charDb then
        HopeAddon.charDb.armory = HopeAddon.charDb.armory or {}
    end

    -- Don't clear scrollContainer entries - Armory uses fixed layout parented to contentArea
    HopeAddon:Debug("PopulateArmory: Using fixed layout (no scroll)")

    -- Create pools if needed
    if not self.armoryPools.upgradeCard then
        HopeAddon:Debug("PopulateArmory: Creating pools")
        self:CreateArmoryPools()
    end
    HopeAddon:Debug("PopulateArmory: Pools ready")

    -- Load saved state
    local savedState = HopeAddon.charDb.armory or {}
    -- Migration: convert old selectedTier (4-6) to selectedPhase (1-3), or use new selectedPhase
    if savedState.selectedPhase then
        self.armoryState.selectedPhase = savedState.selectedPhase
    elseif savedState.selectedTier then
        -- Migrate: T4=Phase1, T5=Phase2, T6=Phase3
        self.armoryState.selectedPhase = savedState.selectedTier - 3
    else
        self.armoryState.selectedPhase = 1
    end
    self.armoryState.selectedSpec = savedState.selectedSpec
    self.armoryState.wishlist = savedState.wishlist or {}
    self.armoryState.expandedSections = savedState.expandedSections or {}
    HopeAddon:Debug("PopulateArmory: State loaded, phase=" .. self.armoryState.selectedPhase)

    -- Create container structure
    HopeAddon:Debug("PopulateArmory: Creating container")
    self:CreateArmoryContainer()
    HopeAddon:Debug("PopulateArmory: Container created")

    -- Load current equipment and calculate upgrade status
    HopeAddon:Debug("PopulateArmory: Refreshing slot data")
    self:RefreshArmorySlotData()
    HopeAddon:Debug("PopulateArmory: Slot data refreshed")

    -- Create info cards for equipped slots (iLvl + upgrade arrows)
    HopeAddon:Debug("PopulateArmory: Updating info cards")
    self:UpdateArmoryInfoCards()
    HopeAddon:Debug("PopulateArmory: Info cards updated")

    -- Update footer stats
    HopeAddon:Debug("PopulateArmory: Updating footer")
    self:UpdateArmoryFooter()
    HopeAddon:Debug("PopulateArmory: Complete")
end

--[[
    Hide Armory tab when switching away
    Saves state and hides containers (does not destroy)
]]
function Journal:HideArmoryTab()
    -- Save current state
    if self.armoryState and HopeAddon.charDb and HopeAddon.charDb.armory then
        HopeAddon.charDb.armory.selectedPhase = self.armoryState.selectedPhase
        HopeAddon.charDb.armory.selectedSpec = self.armoryState.selectedSpec
        HopeAddon.charDb.armory.wishlist = self.armoryState.wishlist
        HopeAddon.charDb.armory.expandedSections = self.armoryState.expandedSections
    end

    -- Hide gear popup if visible
    if self.armoryState and self.armoryState.popupVisible then
        self:HideArmoryGearPopup()
    end

    -- Ensure click-away handler is unregistered
    self:UnregisterArmoryClickAwayHandler()

    -- Restore scroll container visibility for other tabs
    local scrollContainer = self.mainFrame and self.mainFrame.scrollContainer
    if scrollContainer then
        scrollContainer:Show()
    end

    -- Release info cards to pool
    if self.armoryPools.infoCard then
        self.armoryPools.infoCard:ReleaseAll()
    end
    if self.armoryUI then
        self.armoryUI.infoCards = nil
    end

    -- Hide container (but don't destroy - we reuse it)
    if self.armoryUI and self.armoryUI.container then
        self.armoryUI.container:Hide()
        self.armoryUI.container:ClearAllPoints()
    end

    -- Clear model if it exists
    if self.armoryUI and self.armoryUI.modelFrame and self.armoryUI.modelFrame.ClearModel then
        self.armoryUI.modelFrame:ClearModel()
    end
end

--[[
    Create Armory frame pools for dynamic content
]]
function Journal:CreateArmoryPools()
    local FramePool = HopeAddon.FramePool
    local C = HopeAddon.Constants

    -- Upgrade card pool
    self.armoryPools.upgradeCard = FramePool:New(
        function()
            local card = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            self:InitializeUpgradeCard(card)
            return card
        end,
        function(card) self:ResetUpgradeCard(card) end
    )

    -- Section header pool
    self.armoryPools.sectionHeader = FramePool:New(
        function()
            local header = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            self:InitializeSectionHeader(header)
            return header
        end,
        function(header) self:ResetSectionHeader(header) end
    )

    -- Slot info card pool (shows iLvl + upgrade arrow next to each slot)
    local infoCardCfg = C.ARMORY_INFO_CARD
    self.armoryPools.infoCard = FramePool:New(
        function()
            local card = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            card:SetFrameStrata("HIGH")  -- Must match slot buttons strata to render above them
            card:SetSize(infoCardCfg.SIZE, infoCardCfg.SIZE)
            card:SetBackdrop(infoCardCfg.BACKDROP)
            card:SetBackdropColor(
                infoCardCfg.BG_COLOR.r,
                infoCardCfg.BG_COLOR.g,
                infoCardCfg.BG_COLOR.b,
                infoCardCfg.BG_COLOR.a
            )
            card:SetBackdropBorderColor(
                infoCardCfg.BORDER_COLOR.r,
                infoCardCfg.BORDER_COLOR.g,
                infoCardCfg.BORDER_COLOR.b,
                infoCardCfg.BORDER_COLOR.a
            )

            -- iLvl text (top half)
            card.iLvlText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            card.iLvlText:SetPoint("TOP", 0, -6)
            card.iLvlText:SetTextColor(1, 1, 1)

            -- Arrow indicator texture (bottom half)
            card.arrowTexture = card:CreateTexture(nil, "OVERLAY")
            card.arrowTexture:SetSize(20, 20)
            card.arrowTexture:SetPoint("BOTTOM", 0, 4)

            -- Enable mouse for click passthrough
            card:EnableMouse(true)

            -- Highlight on hover
            card:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(
                    infoCardCfg.HIGHLIGHT_COLOR.r,
                    infoCardCfg.HIGHLIGHT_COLOR.g,
                    infoCardCfg.HIGHLIGHT_COLOR.b,
                    infoCardCfg.HIGHLIGHT_COLOR.a
                )
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            card:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(
                    infoCardCfg.BORDER_COLOR.r,
                    infoCardCfg.BORDER_COLOR.g,
                    infoCardCfg.BORDER_COLOR.b,
                    infoCardCfg.BORDER_COLOR.a
                )
            end)

            return card
        end,
        function(card)
            -- Reset function
            card:Hide()
            card:ClearAllPoints()
            card:SetParent(UIParent)
            card.iLvlText:SetText("")
            card.arrowTexture:SetTexture(nil)
            card.slotName = nil
            card:SetScript("OnMouseDown", nil)
        end
    )

    --======================================================================
    -- GEAR POPUP POOLS (Phase 60 redesign)
    --======================================================================

    -- BiS Card pool - Featured item showcase at top of popup
    self.armoryPools.bisCard = FramePool:New(
        function()
            local card = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            card:SetSize(C.ARMORY_GEAR_POPUP.WIDTH - (C.ARMORY_GEAR_POPUP.PADDING * 2), C.ARMORY_GEAR_POPUP.BIS_CARD.HEIGHT)

            -- Gold border backdrop
            card:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })

            -- Icon frame (larger for BiS)
            card.icon = card:CreateTexture(nil, "ARTWORK")
            card.icon:SetSize(C.ARMORY_GEAR_POPUP.BIS_CARD.ICON_SIZE, C.ARMORY_GEAR_POPUP.BIS_CARD.ICON_SIZE)
            card.icon:SetPoint("LEFT", 12, 0)

            -- Icon border (quality colored)
            card.iconBorder = card:CreateTexture(nil, "OVERLAY")
            card.iconBorder:SetSize(C.ARMORY_GEAR_POPUP.BIS_CARD.ICON_SIZE + 4, C.ARMORY_GEAR_POPUP.BIS_CARD.ICON_SIZE + 4)
            card.iconBorder:SetPoint("CENTER", card.icon, "CENTER")
            card.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            card.iconBorder:SetBlendMode("ADD")

            -- BiS indicator star
            card.bisIndicator = card:CreateTexture(nil, "OVERLAY")
            card.bisIndicator:SetSize(20, 20)
            card.bisIndicator:SetPoint("TOPLEFT", card.icon, "TOPLEFT", -6, 6)
            card.bisIndicator:SetTexture("Interface\\COMMON\\ReputationStar")
            card.bisIndicator:SetVertexColor(1, 0.84, 0)

            -- Item name (larger font)
            card.nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            card.nameText:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 12, -4)
            card.nameText:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            card.nameText:SetJustifyH("LEFT")

            -- Item level
            card.iLevelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            card.iLevelText:SetPoint("TOPLEFT", card.nameText, "BOTTOMLEFT", 0, -2)
            card.iLevelText:SetTextColor(0.7, 0.7, 0.7)

            -- Source text
            card.sourceText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            card.sourceText:SetPoint("TOPLEFT", card.iLevelText, "BOTTOMLEFT", 0, -2)
            card.sourceText:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            card.sourceText:SetJustifyH("LEFT")
            card.sourceText:SetTextColor(0.6, 0.6, 0.6)

            -- Try On button
            card.tryOnBtn = CreateFrame("Button", nil, card, "BackdropTemplate")
            card.tryOnBtn:SetSize(70, 22)
            card.tryOnBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 10)
            card.tryOnBtn:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            card.tryOnBtn.text = card.tryOnBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            card.tryOnBtn.text:SetPoint("CENTER")
            card.tryOnBtn.text:SetText("Try On")
            card.tryOnBtn:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(1, 0.84, 0)
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            card.tryOnBtn:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(0.5, 0.5, 0.5)
            end)

            card:Hide()
            return card
        end,
        function(card)
            card:Hide()
            card:ClearAllPoints()
            card:SetParent(UIParent)
            card.icon:SetTexture(nil)
            card.iconBorder:SetVertexColor(1, 1, 1)
            card.nameText:SetText("")
            card.iLevelText:SetText("")
            card.sourceText:SetText("")
            card.tryOnBtn:SetScript("OnClick", nil)
        end
    )

    -- Popup Item Row pool - Compact alternative item rows
    self.armoryPools.popupItemRow = FramePool:New(
        function()
            local row = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
            row:SetSize(C.ARMORY_GEAR_POPUP.WIDTH - (C.ARMORY_GEAR_POPUP.PADDING * 2) - 20, C.ARMORY_GEAR_POPUP.ITEM_HEIGHT)

            -- Hover highlight
            row.highlight = row:CreateTexture(nil, "BACKGROUND")
            row.highlight:SetAllPoints()
            row.highlight:SetColorTexture(0.3, 0.3, 0.3, 0)

            -- Icon
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(C.ARMORY_GEAR_POPUP.ITEM.ICON_SIZE, C.ARMORY_GEAR_POPUP.ITEM.ICON_SIZE)
            row.icon:SetPoint("LEFT", 4, 0)

            -- Icon border (quality colored)
            row.iconBorder = row:CreateTexture(nil, "OVERLAY")
            row.iconBorder:SetSize(C.ARMORY_GEAR_POPUP.ITEM.ICON_SIZE + 2, C.ARMORY_GEAR_POPUP.ITEM.ICON_SIZE + 2)
            row.iconBorder:SetPoint("CENTER", row.icon, "CENTER")
            row.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            row.iconBorder:SetBlendMode("ADD")

            -- Item name
            row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.nameText:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -2)
            row.nameText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
            row.nameText:SetJustifyH("LEFT")

            -- Source text (below name)
            row.sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.sourceText:SetPoint("TOPLEFT", row.nameText, "BOTTOMLEFT", 0, -1)
            row.sourceText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
            row.sourceText:SetJustifyH("LEFT")
            row.sourceText:SetTextColor(0.6, 0.6, 0.6)

            -- iLevel on right
            row.iLevelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.iLevelText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            row.iLevelText:SetTextColor(0.7, 0.7, 0.7)

            -- Hover handlers
            row:SetScript("OnEnter", function(self)
                self.highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            row:SetScript("OnLeave", function(self)
                self.highlight:SetColorTexture(0.3, 0.3, 0.3, 0)
            end)

            row:Hide()
            return row
        end,
        function(row)
            row:Hide()
            row:ClearAllPoints()
            row:SetParent(UIParent)
            row.highlight:SetColorTexture(0.3, 0.3, 0.3, 0)
            row.icon:SetTexture(nil)
            row.iconBorder:SetVertexColor(1, 1, 1)
            row.nameText:SetText("")
            row.sourceText:SetText("")
            row.iLevelText:SetText("")
            row:SetScript("OnClick", nil)
        end
    )

    -- Group Header pool - Collapsible source group headers
    self.armoryPools.groupHeader = FramePool:New(
        function()
            local header = CreateFrame("Button", nil, UIParent)
            header:SetSize(C.ARMORY_GEAR_POPUP.WIDTH - (C.ARMORY_GEAR_POPUP.PADDING * 2) - 20, C.ARMORY_GEAR_POPUP.GROUP_HEADER.HEIGHT)

            -- Background
            header.bg = header:CreateTexture(nil, "BACKGROUND")
            header.bg:SetAllPoints()
            header.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

            -- Expand/collapse icon
            header.expandIcon = header:CreateTexture(nil, "ARTWORK")
            header.expandIcon:SetSize(C.ARMORY_GEAR_POPUP.GROUP_HEADER.ICON_SIZE, C.ARMORY_GEAR_POPUP.GROUP_HEADER.ICON_SIZE)
            header.expandIcon:SetPoint("LEFT", 6, 0)

            -- Source type icon
            header.sourceIcon = header:CreateTexture(nil, "ARTWORK")
            header.sourceIcon:SetSize(18, 18)
            header.sourceIcon:SetPoint("LEFT", header.expandIcon, "RIGHT", 6, 0)

            -- Group label text
            header.labelText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header.labelText:SetPoint("LEFT", header.sourceIcon, "RIGHT", 6, 0)
            header.labelText:SetJustifyH("LEFT")

            -- Count text (right side)
            header.countText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            header.countText:SetPoint("RIGHT", header, "RIGHT", -8, 0)
            header.countText:SetTextColor(0.6, 0.6, 0.6)

            -- Hover effect
            header:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            header:SetScript("OnLeave", function(self)
                self.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
            end)

            header:Hide()
            return header
        end,
        function(header)
            header:Hide()
            header:ClearAllPoints()
            header:SetParent(UIParent)
            header.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
            header.expandIcon:SetTexture(nil)
            header.sourceIcon:SetTexture(nil)
            header.labelText:SetText("")
            header.countText:SetText("")
            header:SetScript("OnClick", nil)
            header.groupKey = nil
            header.isExpanded = nil
        end
    )

    -- Filter Button pool - Source type filter toggles
    self.armoryPools.filterBtn = FramePool:New(
        function()
            local btn = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
            btn:SetSize(80, C.ARMORY_GEAR_POPUP.FILTER.BUTTON_HEIGHT)

            btn:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })

            -- Label text
            btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btn.text:SetPoint("CENTER")

            -- Active state indicator
            btn.activeIndicator = btn:CreateTexture(nil, "OVERLAY")
            btn.activeIndicator:SetSize(6, 6)
            btn.activeIndicator:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
            btn.activeIndicator:SetTexture("Interface\\COMMON\\Indicator-Green")
            btn.activeIndicator:Hide()

            -- Hover handlers
            btn:SetScript("OnEnter", function(self)
                if not self.isActive then
                    self:SetBackdropBorderColor(0.8, 0.7, 0.2)
                end
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
            end)
            btn:SetScript("OnLeave", function(self)
                if not self.isActive then
                    self:SetBackdropBorderColor(0.5, 0.5, 0.5)
                end
            end)

            btn:Hide()
            return btn
        end,
        function(btn)
            btn:Hide()
            btn:ClearAllPoints()
            btn:SetParent(UIParent)
            btn.text:SetText("")
            btn.activeIndicator:Hide()
            btn.isActive = false
            btn.filterKey = nil
            btn:SetScript("OnClick", nil)
            btn:SetBackdropBorderColor(0.5, 0.5, 0.5)
        end
    )
end

--[[
    Create the main Armory container and all child containers
]]
function Journal:CreateArmoryContainer()
    HopeAddon:Debug("CreateArmoryContainer: Starting")
    -- Use contentArea directly for fixed layout (not scroll content)
    local parent = self.mainFrame.contentArea
    local C = HopeAddon.Constants

    if not parent then
        error("CreateArmoryContainer: contentArea is nil")
    end
    HopeAddon:Debug("CreateArmoryContainer: parent OK (using contentArea for fixed layout)")

    -- Create or reuse container
    if not self.armoryUI.container then
        HopeAddon:Debug("CreateArmoryContainer: Creating new container frame")
        local container = CreateFrame("Frame", "HopeArmoryContainer", parent)
        self.armoryUI.container = container
    end

    local container = self.armoryUI.container
    container:SetParent(parent)
    container:ClearAllPoints()
    -- Fixed layout: anchor to all four corners of contentArea with margins
    -- Use same MARGIN_SMALL (5px) as scrollFrame for visual consistency
    local margin = 5  -- Components.MARGIN_SMALL
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", margin, -margin)
    container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -margin, -margin)
    container:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", margin, margin)
    container:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -margin, margin)
    container:Show()
    HopeAddon:Debug("CreateArmoryContainer: Container setup complete (fixed anchors with margins)")

    -- No scroll container entry - fixed layout directly in contentArea

    -- Child creation (order matters)
    HopeAddon:Debug("CreateArmoryContainer: Creating PhaseBar")
    self:CreateArmoryPhaseBar()
    HopeAddon:Debug("CreateArmoryContainer: Creating CharacterView")
    self:CreateArmoryCharacterView()
    HopeAddon:Debug("CreateArmoryContainer: Creating Footer")
    self:CreateArmoryFooter()

    -- No height calculation needed - container fills contentArea via anchors

    HopeAddon:Debug("CreateArmoryContainer: Complete")
    return container
end

--[[
    Create the tier selection bar with T4/T5/T6 buttons and spec dropdown
]]
function Journal:CreateArmoryPhaseBar()
    local container = self.armoryUI.container
    local C = HopeAddon.Constants.ARMORY_PHASE_BAR

    if not self.armoryUI.phaseBar then
        local phaseBar = CreateFrame("Frame", "HopeArmoryPhaseBar", container, "BackdropTemplate")
        phaseBar:SetHeight(C.HEIGHT)
        phaseBar:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        phaseBar:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
        phaseBar:SetBackdrop(C.BACKDROP)
        phaseBar:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        phaseBar:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        -- "PHASE" label
        local label = phaseBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", phaseBar, "LEFT", C.PADDING_H, 0)
        label:SetText(C.LABEL_TEXT)
        label:SetTextColor(0.7, 0.7, 0.7, 1)
        phaseBar.label = label

        self.armoryUI.phaseBar = phaseBar
        self.armoryUI.phaseButtons = {}
    end

    local phaseBar = self.armoryUI.phaseBar
    phaseBar:Show()

    -- Create phase buttons and spec dropdown
    self:CreateArmoryPhaseButtons()
    self:CreateArmorySpecDropdown()

    return phaseBar
end

--[[
    Create the Phase selection buttons (compact numbered buttons)
    Note: Phase 4 (ZA catch-up raid) is skipped
]]
function Journal:CreateArmoryPhaseButtons()
    local phaseBar = self.armoryUI.phaseBar
    local C = HopeAddon.Constants.ARMORY_PHASE_BUTTON

    -- Phases to show (all 5 phases)
    local phasesToShow = { 1, 2, 3, 4, 5 }

    for buttonIndex, phase in ipairs(phasesToShow) do
        local phaseConfig = C.PHASES[phase]

        if not self.armoryUI.phaseButtons[phase] then
            local btn = CreateFrame("Button", "HopeArmoryPhase" .. phase .. "Button", phaseBar, "BackdropTemplate")
            btn:SetSize(C.WIDTH, C.HEIGHT)

            -- Position: left to right after "PHASE" label with gaps (use buttonIndex for positioning)
            local xOffset = C.FIRST_OFFSET + (buttonIndex - 1) * (C.WIDTH + C.GAP)
            btn:SetPoint("LEFT", phaseBar, "LEFT", xOffset, 0)

            -- Backdrop
            btn:SetBackdrop({
                bgFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })

            -- Text: Phase number (1, 2, 3, 4, 5)
            local label = btn:CreateFontString(nil, "OVERLAY", C.FONT)
            label:SetPoint("CENTER", btn, "CENTER", 0, 0)
            label:SetText(phaseConfig.label)
            btn.label = label

            -- Glow texture (for active state)
            local glow = btn:CreateTexture(nil, "OVERLAY")
            glow:SetPoint("CENTER", btn, "CENTER", 0, 0)
            glow:SetSize(C.WIDTH + 8, C.HEIGHT + 8)
            glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
            glow:SetBlendMode("ADD")
            glow:SetAlpha(0.5)
            glow:Hide()
            btn.glow = glow

            -- Store phase reference
            btn.phase = phase
            btn.phaseColor = HopeAddon.colors[phaseConfig.color]

            -- Click handler
            btn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                self:SelectArmoryPhase(phase)
            end)

            -- Hover handlers with enhanced tooltip
            btn:SetScript("OnEnter", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
                self:SetPhaseButtonState(btn, "hover")
                GameTooltip:SetOwner(btn, "ANCHOR_BOTTOM")

                -- Title (gold)
                GameTooltip:SetText(phaseConfig.tooltip, 1, 0.84, 0)

                -- Raids in this phase (fel green header)
                if phaseConfig.raids and #phaseConfig.raids > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Raid Content:", 0.2, 0.8, 0.2)
                    for _, raid in ipairs(phaseConfig.raids) do
                        GameTooltip:AddLine("  • " .. raid, 0.9, 0.9, 0.9)
                    end
                end

                -- Gear sources (sky blue header)
                if phaseConfig.gearSources and #phaseConfig.gearSources > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Gear Sources:", 0.3, 0.7, 1.0)
                    for _, source in ipairs(phaseConfig.gearSources) do
                        GameTooltip:AddLine("  • " .. source, 0.8, 0.8, 0.8)
                    end
                end

                -- Recommended iLvl (grey)
                if phaseConfig.recommendedILvl then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Recommended iLvl: " .. phaseConfig.recommendedILvl, 0.6, 0.6, 0.6)
                end

                GameTooltip:Show()
            end)

            btn:SetScript("OnLeave", function()
                local state = (self.armoryState.selectedPhase == phase) and "active" or "inactive"
                self:SetPhaseButtonState(btn, state)
                GameTooltip:Hide()
            end)

            self.armoryUI.phaseButtons[phase] = btn
        end

        -- Set initial state
        local state = (self.armoryState.selectedPhase == phase) and "active" or "inactive"
        self:SetPhaseButtonState(self.armoryUI.phaseButtons[phase], state)
    end
end

--[[
    Set visual state for phase button
]]
function Journal:SetPhaseButtonState(btn, stateName)
    local C = HopeAddon.Constants.ARMORY_PHASE_BUTTON
    local state = C.STATES[stateName]
    local phaseColor = btn.phaseColor or HopeAddon.colors.GOLD_BRIGHT

    -- Background color (phase color at configured alpha)
    btn:SetBackdropColor(
        phaseColor.r * 0.3,
        phaseColor.g * 0.3,
        phaseColor.b * 0.3,
        state.bgAlpha
    )

    -- Border color
    btn:SetBackdropBorderColor(
        phaseColor.r,
        phaseColor.g,
        phaseColor.b,
        state.borderAlpha
    )

    -- Text color
    btn.label:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b, state.textAlpha)

    -- Glow (for active state)
    if state.showGlow and btn.glow then
        btn.glow:SetVertexColor(phaseColor.r, phaseColor.g, phaseColor.b, 0.5)
        btn.glow:Show()
    elseif btn.glow then
        btn.glow:Hide()
    end
end

--[[
    Create the spec selection dropdown
]]
function Journal:CreateArmorySpecDropdown()
    local phaseBar = self.armoryUI.phaseBar
    local C = HopeAddon.Constants.ARMORY_SPEC_DROPDOWN

    if not self.armoryUI.specDropdown then
        local dropdown = CreateFrame("Frame", "HopeArmorySpecDropdown", phaseBar, "UIDropDownMenuTemplate")
        dropdown:SetPoint(C.ANCHOR, phaseBar, C.ANCHOR, C.OFFSET_X, C.OFFSET_Y)

        UIDropDownMenu_SetWidth(dropdown, C.MENU_WIDTH)

        UIDropDownMenu_Initialize(dropdown, function(frame, level)
            self:InitArmorySpecDropdownMenu(frame, level)
        end)

        self.armoryUI.specDropdown = dropdown
    end

    -- Set current spec text
    local specName = HopeAddon:GetPlayerSpec()
    UIDropDownMenu_SetText(self.armoryUI.specDropdown, specName or "Select Spec")
end

--[[
    Initialize spec dropdown menu items
]]
function Journal:InitArmorySpecDropdownMenu(frame, level)
    -- Get specs for this class (1, 2, 3)
    -- GetTalentTabInfo returns: id, name, description, iconTexture, pointsSpent, background
    -- We need the name (2nd return value), not the id (1st)
    for specTab = 1, 3 do
        local _, specName = GetTalentTabInfo(specTab)
        if specName and specName ~= "" then
            local info = UIDropDownMenu_CreateInfo()
            info.text = specName
            info.value = specTab
            info.func = function()
                self.armoryState.selectedSpec = specTab
                UIDropDownMenu_SetText(self.armoryUI.specDropdown, specName)
                self:RefreshArmoryRecommendations()
            end
            info.checked = (self.armoryState.selectedSpec == specTab)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

--[[
    Create the centered character view container
    This is a full-width container with model centered and slots symmetrically positioned
]]
function Journal:CreateArmoryCharacterView()
    local container = self.armoryUI.container
    local C = HopeAddon.Constants.ARMORY_CHARACTER_VIEW
    local phaseBarHeight = HopeAddon.Constants.ARMORY_PHASE_BAR.HEIGHT

    if not self.armoryUI.characterView then
        local characterView = CreateFrame("Frame", "HopeArmoryCharacterView", container, "BackdropTemplate")
        -- Full width, positioned below phase bar
        characterView:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -phaseBarHeight)
        characterView:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -phaseBarHeight)
        characterView:SetBackdrop(C.BACKDROP)
        characterView:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        characterView:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        self.armoryUI.characterView = characterView
    end

    local characterView = self.armoryUI.characterView
    characterView:Show()

    -- CRITICAL: Set height BEFORE creating children so they have valid parent dimensions
    -- Compact height: 8 slots × 44px + weapons (54) + padding (10) = 380px
    local compactHeight = HopeAddon.Constants.ARMORY_CHARACTER_VIEW.COMPACT_HEIGHT or 380
    characterView:SetHeight(compactHeight)

    -- Create child components - MODEL FIRST so weapons can anchor to it
    self:CreateArmoryModelFrame()
    self:CreateArmorySlotsContainer()

    return characterView
end

--[[
    Create the DressUpModel for character preview
    Model is centered in the characterView between left and right slot columns
]]
function Journal:CreateArmoryModelFrame()
    local characterView = self.armoryUI.characterView
    local C = HopeAddon.Constants.ARMORY_MODEL_FRAME

    if not self.armoryUI.modelFrame then
        local modelFrame = CreateFrame("DressUpModel", "HopeArmoryModel", characterView)
        modelFrame:SetSize(C.WIDTH, C.HEIGHT)
        -- Center the model in the characterView
        -- Model is positioned at TOP center of characterView
        modelFrame:SetPoint("TOP", characterView, "TOP", 0, C.OFFSET_Y)

        -- Background
        local bg = modelFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(C.BACKGROUND_COLOR.r, C.BACKGROUND_COLOR.g, C.BACKGROUND_COLOR.b, C.BACKGROUND_COLOR.a)

        -- Initialize model - show full character, not portrait zoom
        modelFrame:SetUnit("player")
        modelFrame:SetRotation(C.DEFAULT_ROTATION)
        modelFrame:SetPortraitZoom(0)  -- 0 = full body view, 1 = close-up face

        -- Drag rotation - use LOW strata so slot buttons (HIGH) receive clicks first
        modelFrame:EnableMouse(true)
        modelFrame:SetFrameStrata("LOW")
        modelFrame:SetFrameLevel(1)  -- Explicitly lowest level
        modelFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self.isDragging = true
                self.lastX = GetCursorPosition()
            end
        end)

        modelFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                self.isDragging = false
            end
        end)

        modelFrame:SetScript("OnUpdate", function(self)
            if self.isDragging then
                local currentX = GetCursorPosition()
                local delta = (currentX - (self.lastX or currentX)) * C.ROTATION_SPEED
                self:SetRotation(self:GetFacing() + delta)
                self.lastX = currentX
            end
        end)

        self.armoryUI.modelFrame = modelFrame
    end

    self.armoryUI.modelFrame:Show()
    self.armoryUI.modelFrame:SetUnit("player")

    return self.armoryUI.modelFrame
end

--[[
    Create the container for all 17 equipment slot buttons
    Spans the full characterView - slots positioned symmetrically around center
]]
function Journal:CreateArmorySlotsContainer()
    local characterView = self.armoryUI.characterView
    local C = HopeAddon.Constants.ARMORY_SLOTS_CONTAINER

    if not self.armoryUI.slotsContainer then
        local slotsContainer = CreateFrame("Frame", "HopeArmorySlotsContainer", characterView)
        -- Span the full characterView area so slots can be positioned symmetrically
        slotsContainer:SetPoint("TOPLEFT", characterView, "TOPLEFT", 0, 0)
        slotsContainer:SetPoint("BOTTOMRIGHT", characterView, "BOTTOMRIGHT", 0, 0)

        self.armoryUI.slotsContainer = slotsContainer
        self.armoryUI.slotButtons = {}
    end

    local slotsContainer = self.armoryUI.slotsContainer

    -- CRITICAL: Set frame level ABOVE the model frame so slots are clickable
    -- CRITICAL: Set frame level and strata ABOVE the model frame so slots are clickable
    -- Model frame renders at characterView level, slots need to be higher
    local characterView = self.armoryUI.characterView
    if characterView then
        slotsContainer:SetFrameLevel(characterView:GetFrameLevel() + 10)
        slotsContainer:SetFrameStrata("MEDIUM")
        HopeAddon:Debug("CreateArmorySlotsContainer: Set frameLevel to", slotsContainer:GetFrameLevel(), "strata=MEDIUM")
    end

    slotsContainer:Show()

    -- Create all slot buttons
    self:CreateArmorySlotButtons()

    return slotsContainer
end

--[[
    Create all equipment slot buttons (15 visible - shirt/tabard hidden)
    Layout: Left column (armor), Right column (accessories), Bottom row (weapons below model)
    Compact layout: 44px spacing, weapons anchor to model bottom not container
]]
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
        -- Skip cosmetic slots (shirt, tabard) - they have no BiS recommendations
        if HIDDEN[slotName] then
            hiddenByConfig = hiddenByConfig + 1
            -- Hide if previously created
            if self.armoryUI.slotButtons[slotName] then
                self.armoryUI.slotButtons[slotName]:Hide()
            end
        else
            if not self.armoryUI.slotButtons[slotName] then
                local btn = self:CreateSingleArmorySlotButton(slotsContainer, slotName, slotData)
                self.armoryUI.slotButtons[slotName] = btn
            end

            -- Position the button using constants
            local pos = C.POSITIONS and C.POSITIONS[slotName]
            local btn = self.armoryUI.slotButtons[slotName]
            btn:ClearAllPoints()

            if pos then
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
                            HopeAddon:Debug("CreateArmorySlotButtons: Using characterView fallback for " .. slotName)
                            btn:SetPoint("BOTTOM", characterView, "BOTTOM", pos.x, 10)
                        else
                            -- Ultimate fallback to slotsContainer
                            HopeAddon:Debug("CreateArmorySlotButtons: Using slotsContainer fallback for " .. slotName)
                            btn:SetPoint("TOP", slotsContainer, "TOP", pos.x, -290)
                        end
                    end
                else
                    -- Normal anchoring to slotsContainer
                    btn:SetPoint(pos.anchor, slotsContainer, pos.anchor, pos.x, pos.y)
                end
                btn:Show()
                shownCount = shownCount + 1
            else
                -- Fallback: hide unpositioned slots
                hiddenNoPos = hiddenNoPos + 1
                HopeAddon:Debug("CreateArmorySlotButtons: No position for slot " .. slotName)
                btn:Hide()
            end
        end
    end

    HopeAddon:Debug("CreateArmorySlotButtons: SUMMARY - created:", createdCount,
        "shown:", shownCount, "hiddenConfig:", hiddenByConfig, "hiddenNoPos:", hiddenNoPos)
end

--[[
    Create a single equipment slot button
]]
function Journal:CreateSingleArmorySlotButton(parent, slotName, slotData)
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON

    local btn = CreateFrame("Button", "HopeArmorySlot_" .. slotName, parent, "BackdropTemplate")
    btn:SetSize(C.SIZE, C.SIZE)

    -- CRITICAL: Set frame strata HIGH and level above parent to ensure button is clickable
    -- This ensures slots are above the click-away frame (MEDIUM strata)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(parent:GetFrameLevel() + 2)
    btn:EnableMouse(true)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- Icon container
    local iconFrame = CreateFrame("Frame", nil, btn)
    iconFrame:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    iconFrame:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.iconFrame = iconFrame

    -- Placeholder texture (when no item equipped)
    local placeholder = iconFrame:CreateTexture(nil, "ARTWORK", nil, 0)
    placeholder:SetAllPoints()
    local placeholderIcon = HopeAddon.Constants.ARMORY_SLOT_PLACEHOLDER_ICONS and HopeAddon.Constants.ARMORY_SLOT_PLACEHOLDER_ICONS[slotName]
    placeholder:SetTexture(placeholderIcon or "Interface\\PaperDoll\\UI-Backpack-EmptySlot")
    placeholder:SetDesaturated(true)
    placeholder:SetAlpha(0.5)
    btn.placeholder = placeholder

    -- Item icon texture
    local icon = iconFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:Hide()
    btn.icon = icon

    -- Quality border overlay
    local qualityBorder = iconFrame:CreateTexture(nil, "OVERLAY", nil, 0)
    qualityBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -2, 2)
    qualityBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 2, -2)
    qualityBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    qualityBorder:Hide()
    btn.qualityBorder = qualityBorder

    -- Upgrade indicator badge (top-right corner)
    local indicator = CreateFrame("Frame", nil, btn)
    indicator:SetSize(C.INDICATOR_SIZE, C.INDICATOR_SIZE)
    indicator:SetPoint("TOPRIGHT", btn, "TOPRIGHT", C.INDICATOR_OFFSET.x, C.INDICATOR_OFFSET.y)
    indicator:Hide()
    btn.indicator = indicator

    local indicatorBg = indicator:CreateTexture(nil, "BACKGROUND")
    indicatorBg:SetAllPoints()
    indicatorBg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    indicatorBg:SetVertexColor(0, 0, 0, 0.8)
    indicator.bg = indicatorBg

    local indicatorIcon = indicator:CreateTexture(nil, "ARTWORK")
    indicatorIcon:SetSize(C.INDICATOR_SIZE - 2, C.INDICATOR_SIZE - 2)
    indicatorIcon:SetPoint("CENTER")
    indicator.iconTex = indicatorIcon

    local indicatorText = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    indicatorText:SetPoint("CENTER")
    indicatorText:SetFont(indicatorText:GetFont(), 10, "OUTLINE")
    indicator.text = indicatorText

    -- Slot label (below icon)
    local label = btn:CreateFontString(nil, "OVERLAY", C.LABEL_FONT)
    label:SetPoint("TOP", btn, "BOTTOM", 0, -2)
    label:SetText(slotData.displayName)
    label:SetTextColor(0.7, 0.7, 0.7, 1)
    btn.label = label

    -- Glow overlay (for selection/pulse animation)
    local glow = btn:CreateTexture(nil, "OVERLAY", nil, 7)
    glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -8, 8)
    glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 8, -8)
    glow:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
    glow:SetBlendMode("ADD")
    glow:SetAlpha(0)
    btn.glow = glow

    -- Highlight overlay (mouseover)
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(iconFrame)
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")

    -- Data storage
    btn.slotName = slotName
    btn.slotId = slotData.slotId
    btn.equippedItem = nil
    btn.upgradeStatus = "empty"
    btn.isSelected = false

    -- Click handler
    btn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:OnArmorySlotClick(slotName)
    end)

    -- Hover handlers
    btn:SetScript("OnEnter", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        self:OnArmorySlotEnter(btn)
    end)

    btn:SetScript("OnLeave", function()
        self:OnArmorySlotLeave(btn)
    end)

    HopeAddon:Debug("CreateSingleArmorySlotButton:", slotName,
        "frameLevel=", btn:GetFrameLevel(),
        "strata=", btn:GetFrameStrata(),
        "parentLevel=", parent:GetFrameLevel())

    return btn
end

--============================================================================
-- SLOT INFO CARDS (iLvl + upgrade arrow indicators)
--============================================================================

--[[
    Calculate average equipped item level across all equipped slots
    Skips shirt (4) and tabard (19) slots
    Returns 0 if no items equipped
]]
function Journal:GetAverageEquippedILvl()
    local totalILvl = 0
    local slotCount = 0

    for slotId = 1, 18 do
        -- Skip shirt (4) - tabard (19) is outside this range anyway
        if slotId ~= 4 then
            local itemLink = GetInventoryItemLink("player", slotId)
            if itemLink then
                local _, _, _, iLvl = GetItemInfo(itemLink)
                if iLvl and iLvl > 0 then
                    totalILvl = totalILvl + iLvl
                    slotCount = slotCount + 1
                end
            end
        end
    end

    return slotCount > 0 and math.floor(totalILvl / slotCount) or 0
end

--[[
    Determine upgrade status indicator for a slot based on iLvl vs average
    Returns indicator config: { texture, color }
]]
function Journal:GetSlotUpgradeStatus(slotILvl, avgILvl)
    local cfg = HopeAddon.Constants.ARMORY_INFO_CARD
    local diff = slotILvl - avgILvl

    if diff >= cfg.THRESHOLD_GOOD then
        return cfg.INDICATORS.GOOD       -- Green down arrow (above average)
    elseif diff <= cfg.THRESHOLD_BAD then
        return cfg.INDICATORS.UPGRADE    -- Red up arrow (needs upgrade)
    else
        return cfg.INDICATORS.OKAY       -- Gold neutral (at average)
    end
end

--[[
    Create or update an info card for a specific equipment slot
    Returns nil if slot is empty (card should be hidden)
]]
function Journal:CreateSlotInfoCard(slotButton, slotName)
    if not slotButton or not slotButton.slotId then
        return nil
    end

    local itemLink = GetInventoryItemLink("player", slotButton.slotId)
    if not itemLink then
        return nil  -- Hide card for empty slots
    end

    local _, _, _, iLvl = GetItemInfo(itemLink)
    if not iLvl or iLvl <= 0 then
        return nil
    end

    local avgILvl = self:GetAverageEquippedILvl()
    local status = self:GetSlotUpgradeStatus(iLvl, avgILvl)
    local posData = HopeAddon.Constants.ARMORY_INFO_CARD.POSITIONS[slotName]

    if not posData then
        HopeAddon:Debug("CreateSlotInfoCard: No position data for", slotName)
        return nil
    end

    -- Acquire card from pool
    local card = self.armoryPools.infoCard:Acquire()
    card:SetParent(slotButton:GetParent())
    card:ClearAllPoints()
    card:SetPoint(posData.anchor, slotButton, posData.relAnchor, posData.x, posData.y)

    -- Set frame strata and level above slot button
    card:SetFrameStrata("HIGH")  -- Match slot buttons strata
    card:SetFrameLevel(slotButton:GetFrameLevel() + 5)  -- Clearly above slot buttons

    -- Set content
    card.iLvlText:SetText(tostring(iLvl))
    card.arrowTexture:SetTexture(status.texture)
    card.arrowTexture:SetVertexColor(status.color.r, status.color.g, status.color.b)

    -- Store slot reference for click handling
    card.slotName = slotName

    -- Click handler - opens gear popup (same as clicking slot)
    card:SetScript("OnMouseDown", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:OnArmorySlotClick(slotName)
    end)

    card:Show()
    return card
end

--[[
    Update all slot info cards
    Releases existing cards and creates new ones for equipped slots
]]
function Journal:UpdateArmoryInfoCards()
    -- Release all existing info cards
    if self.armoryPools.infoCard then
        self.armoryPools.infoCard:ReleaseAll()
    end

    -- Initialize storage for card references
    self.armoryUI.infoCards = self.armoryUI.infoCards or {}
    wipe(self.armoryUI.infoCards)

    -- Create info card for each equipped slot
    local HIDDEN = HopeAddon.Constants.ARMORY_HIDDEN_SLOTS or {}
    for slotName, slotButton in pairs(self.armoryUI.slotButtons or {}) do
        -- Skip hidden slots (shirt, tabard)
        if not HIDDEN[slotName] then
            local card = self:CreateSlotInfoCard(slotButton, slotName)
            if card then
                self.armoryUI.infoCards[slotName] = card
            end
        end
    end

    local cardCount = 0
    for _ in pairs(self.armoryUI.infoCards or {}) do cardCount = cardCount + 1 end
    HopeAddon:Debug("UpdateArmoryInfoCards: Created", cardCount, "info cards")
end

-- NOTE: Old detail panel functions (CreateArmoryDetailPanel, CreateArmoryDetailHeader,
-- CreateArmoryDetailScroll, CreateArmoryDetailFooter) have been removed.
-- The new UI uses a floating gear popup instead - see GetArmoryGearPopup()

--[[
    Create the main footer showing gear statistics
]]
function Journal:CreateArmoryFooter()
    local container = self.armoryUI.container
    local characterView = self.armoryUI.characterView
    local C = HopeAddon.Constants.ARMORY_FOOTER

    if not self.armoryUI.footer then
        local footer = CreateFrame("Frame", "HopeArmoryFooter", container, "BackdropTemplate")
        footer:SetHeight(C.HEIGHT)
        -- Position below characterView, not overlapping
        -- Footer spans full width of container, positioned 5px below characterView
        footer:SetPoint("TOPLEFT", characterView, "BOTTOMLEFT", 0, -5)
        footer:SetPoint("RIGHT", container, "RIGHT", 0, 0)  -- Match container right edge

        footer:SetBackdrop(C.BACKDROP)
        footer:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
        footer:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

        -- Create stat displays on the RIGHT side (built right-to-left)
        -- Layout: [BIS] [RESET]    Phase 1 | Avg iLvl: 115 | Upgrades: 4 | Wishlisted: 2 | GS: 1850
        local L = C.LAYOUT or {}
        footer.stats = {}
        footer.dividers = {}
        local rightOffset = L.STATS_RIGHT_MARGIN or 15
        local statGap = L.STAT_GAP or 16

        for i, statConfig in ipairs(C.STATS) do
            -- Value first (right-most for each stat pair)
            local value = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            value:SetPoint("RIGHT", footer, "RIGHT", -rightOffset, 0)
            value:SetText("--")

            -- Use phase color for phase stat, gold for others
            if statConfig.id == "phase" then
                value:SetTextColor(C.PHASE_COLOR.r, C.PHASE_COLOR.g, C.PHASE_COLOR.b, C.PHASE_COLOR.a)
            else
                value:SetTextColor(C.VALUE_COLOR.r, C.VALUE_COLOR.g, C.VALUE_COLOR.b, C.VALUE_COLOR.a)
            end

            -- Label (left of value)
            local label = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("RIGHT", value, "LEFT", -4, 0)
            label:SetText(statConfig.label)

            -- Use phase color for phase label too
            if statConfig.id == "phase" then
                label:SetTextColor(C.PHASE_COLOR.r, C.PHASE_COLOR.g, C.PHASE_COLOR.b, C.PHASE_COLOR.a)
            else
                label:SetTextColor(C.LABEL_COLOR.r, C.LABEL_COLOR.g, C.LABEL_COLOR.b, C.LABEL_COLOR.a)
            end

            footer.stats[statConfig.id] = {
                label = label,
                value = value,
                format = statConfig.format,
            }

            -- Calculate width: estimate label width + value width + padding
            local estimatedWidth = 80  -- Reasonable estimate for label+value
            rightOffset = rightOffset + estimatedWidth + statGap

            -- Add divider between stats (except after last one)
            if i < #C.STATS then
                local divider = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                divider:SetPoint("RIGHT", label, "LEFT", -8, 0)
                divider:SetText("|")
                divider:SetTextColor(C.DIVIDER_COLOR.r, C.DIVIDER_COLOR.g, C.DIVIDER_COLOR.b, C.DIVIDER_COLOR.a)
                table.insert(footer.dividers, divider)
            end
        end

        -- Create BIS and RESET buttons on the LEFT side
        self:CreateArmoryFooterButtons(footer)

        self.armoryUI.footer = footer
    end

    self.armoryUI.footer:Show()
    return self.armoryUI.footer
end

--[[
    Create BIS and RESET buttons for the footer
    Layout: Both buttons on LEFT side - [BIS] [RESET]
]]
function Journal:CreateArmoryFooterButtons(footer)
    local C = HopeAddon.Constants.ARMORY_FOOTER.BUTTONS
    if not C then return end

    -- BIS button (LEFT side, prominent gold)
    local bisBtn = self:CreateArmoryFooterButton(
        footer,
        C.BIS.label,
        C.BIS.width,
        C.BIS.height,
        C.BIS.borderColor,
        C.BIS.bgColor,
        C.BIS.tooltip,
        function() self:OnBISButtonClick() end
    )
    bisBtn:ClearAllPoints()
    bisBtn:SetPoint("LEFT", footer, "LEFT", C.LEFT_MARGIN or 12, 0)
    footer.bisBtn = bisBtn

    -- RESET button (LEFT side, after BIS button)
    local resetBtn = self:CreateArmoryFooterButton(
        footer,
        C.RESET.label,
        C.RESET.width,
        C.RESET.height,
        C.RESET.borderColor,
        C.RESET.bgColor,
        C.RESET.tooltip,
        function() self:OnRESETButtonClick() end
    )
    resetBtn:ClearAllPoints()
    resetBtn:SetPoint("LEFT", bisBtn, "RIGHT", C.GAP or 8, 0)
    footer.resetBtn = resetBtn
end

--[[
    Create a single footer button
]]
function Journal:CreateArmoryFooterButton(parent, label, width, height, borderColor, bgColor, tooltip, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    btn:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    btn:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)

    -- Store colors for hover effects
    btn.normalBorder = borderColor
    btn.normalBg = bgColor

    -- Label
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    text:SetText(label)
    text:SetTextColor(borderColor.r, borderColor.g, borderColor.b, 1)
    btn.label = text

    -- Click handler
    btn:SetScript("OnClick", onClick)

    -- Hover effects
    btn:SetScript("OnEnter", function(self)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        -- Brighten
        self:SetBackdropColor(
            bgColor.r * 1.5,
            bgColor.g * 1.5,
            bgColor.b * 1.5,
            bgColor.a
        )
        self:SetBackdropBorderColor(1, 1, 1, 1)
        self.label:SetTextColor(1, 1, 1, 1)

        -- Tooltip
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltip)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        -- Restore normal colors
        self:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        self.label:SetTextColor(borderColor.r, borderColor.g, borderColor.b, 1)
        GameTooltip:Hide()
    end)

    return btn
end

--[[
    Recalculate the total height of the armory container
    Layout: PhaseBar (35px) + CharacterView (480px) + Gap (5px) + Footer (35px) = 555px

    DEPRECATED: No longer used - Armory tab now uses fixed layout anchored to contentArea
    corners (TOPLEFT/TOPRIGHT/BOTTOMLEFT/BOTTOMRIGHT), so height is automatic.
    Kept for reference in case dynamic sizing is needed in the future.
]]
function Journal:RecalculateArmoryHeight()
    local phaseBarHeight = HopeAddon.Constants.ARMORY_PHASE_BAR.HEIGHT  -- 35
    local characterViewHeight = self.armoryUI.characterView and self.armoryUI.characterView:GetHeight() or 480
    local footerHeight = HopeAddon.Constants.ARMORY_FOOTER.HEIGHT  -- 35
    local contentGap = 5  -- Gap between characterView and footer

    local totalHeight = phaseBarHeight + characterViewHeight + contentGap + footerHeight
    self.armoryUI.container:SetHeight(math.max(totalHeight, HopeAddon.Constants.ARMORY_CONTAINER.MIN_HEIGHT))
end

--[[
    Update the footer statistics
]]
function Journal:UpdateArmoryFooter()
    local footer = self.armoryUI and self.armoryUI.footer
    if not footer or not footer.stats then return end

    local stats = self:CalculateArmoryStats()

    for statId, statDisplay in pairs(footer.stats) do
        local value = stats[statId] or 0
        statDisplay.value:SetText(string.format(statDisplay.format, value))
    end
end

--[[
    Calculate armory statistics
]]
function Journal:CalculateArmoryStats()
    local stats = {
        phase = self.armoryState.selectedPhase or 1,
        avgIlvl = 0,
        upgradesAvail = 0,
        wishlisted = 0,
        gearScore = 0,
    }

    -- Get gear score and avg iLvl from core function
    local gearScore, avgILvl = HopeAddon:GetGearScore()
    stats.gearScore = gearScore or 0
    stats.avgIlvl = avgILvl or 0

    -- Count wishlisted items
    for _ in pairs(self.armoryState.wishlist) do
        stats.wishlisted = stats.wishlisted + 1
    end

    -- Count upgrade opportunities
    for slotName, btn in pairs(self.armoryUI.slotButtons or {}) do
        if btn.upgradeStatus == "upgrade" or btn.upgradeStatus == "major" then
            stats.upgradesAvail = stats.upgradesAvail + 1
        end
    end

    return stats
end

--[[
    BIS Button: Preview all Best in Slot items for current phase
    Undresses model first, then tries on each BiS item
]]
function Journal:OnBISButtonClick()
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end

    local modelFrame = self.armoryUI.modelFrame
    if not modelFrame then
        HopeAddon:Debug("OnBISButtonClick: No model frame")
        return
    end

    -- Undress model first
    modelFrame:Undress()

    -- Get current phase and spec guide key
    local phase = self.armoryState.selectedPhase or 1
    local guideKey = self:GetCurrentArmoryGuideKey()

    if not guideKey then
        HopeAddon:Print("Cannot determine your spec. Please select a spec from the dropdown.")
        return
    end

    -- Get BiS database for this phase/spec
    local C = HopeAddon.Constants
    local HIDDEN = C.ARMORY_HIDDEN_SLOTS or {}
    local phaseData = C.ARMORY_SPEC_BIS_DATABASE and C.ARMORY_SPEC_BIS_DATABASE[phase]
    local specData = phaseData and phaseData[guideKey]

    if not specData then
        HopeAddon:Print("No BiS data for Phase " .. phase .. " / " .. guideKey)
        return
    end

    -- Try on each BiS item
    local itemCount = 0

    for slotName, slotData in pairs(specData) do
        if not HIDDEN[slotName] and slotData.bis and slotData.bis.id then
            local itemId = slotData.bis.id
            local itemLink = select(2, GetItemInfo(itemId))

            if itemLink then
                modelFrame:TryOn(itemLink)
                itemCount = itemCount + 1
            else
                -- Request item info for cache (will work next time)
                GetItemInfo(itemId)
            end
        end
    end

    -- Visual feedback
    if HopeAddon.Effects and HopeAddon.Effects.IconGlow then
        HopeAddon.Effects:IconGlow(modelFrame, 0.5)
    end

    -- Feedback message
    local phaseLabel = C.ARMORY_PHASES and C.ARMORY_PHASES[phase] and C.ARMORY_PHASES[phase].label or ("Phase " .. phase)
    HopeAddon:Print("Previewing " .. itemCount .. " BiS items for " .. phaseLabel)
end

-- Legacy alias for backwards compatibility
function Journal:PreviewAllBis()
    self:OnBISButtonClick()
end

--[[
    RESET Button: Reset model to current equipped gear
    Undresses model and re-sets unit to player
]]
function Journal:OnRESETButtonClick()
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end

    local modelFrame = self.armoryUI.modelFrame
    if not modelFrame then
        HopeAddon:Debug("OnRESETButtonClick: No model frame")
        return
    end

    -- Reset to current gear
    modelFrame:Undress()
    modelFrame:SetUnit("player")

    HopeAddon:Print("Reset to current gear")
end

-- Legacy alias for backwards compatibility
function Journal:ResetArmoryPreview()
    self:OnRESETButtonClick()
end

--[[
    Refresh all slot data from current equipment
]]
function Journal:RefreshArmorySlotData()
    for slotName, btn in pairs(self.armoryUI.slotButtons or {}) do
        self:RefreshSingleSlotData(btn)
    end
end

--[[
    Refresh data for a single slot button
]]
function Journal:RefreshSingleSlotData(btn)
    local slotId = btn.slotId
    local slotName = btn.slotName
    local itemLink = GetInventoryItemLink("player", slotId)
    local C = HopeAddon.Constants

    HopeAddon:Debug("RefreshSingleSlotData:", slotName, "slotId=", slotId, "hasItem=", itemLink and "YES" or "NO")

    if itemLink then
        local itemName, _, itemQuality, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
        local itemIdMatch = itemLink:match("item:(%d+)")
        local itemId = itemIdMatch and tonumber(itemIdMatch) or nil

        -- Handle uncached items (GetItemInfo returns nil on first call)
        if not itemName or not itemTexture then
            HopeAddon:Debug("RefreshSingleSlotData:", slotName, "- item not cached yet, showing placeholder")
            btn.equippedItem = { itemId = itemId, name = "Loading...", quality = 1, iLvl = 0, icon = nil }
            btn.icon:Hide()
            btn.placeholder:Show()
            btn.qualityBorder:Hide()
            btn.upgradeStatus = "empty"
            self:UpdateArmorySlotVisual(btn)
            return
        end

        btn.equippedItem = {
            itemId = itemId,
            name = itemName,
            quality = itemQuality,
            iLvl = itemLevel or 0,
            icon = itemTexture,
        }
        btn.icon:SetTexture(itemTexture)
        btn.icon:Show()
        btn.placeholder:Hide()

        -- Quality border
        if itemQuality then
            local r, g, b = GetItemQualityColor(itemQuality)
            btn.qualityBorder:SetVertexColor(r, g, b, 1)
            btn.qualityBorder:Show()
        end

        -- Determine upgrade status using gear database
        btn.upgradeStatus = self:CalculateSlotUpgradeStatus(slotName, itemId, itemLevel or 0)
    else
        btn.equippedItem = nil
        btn.icon:Hide()
        btn.placeholder:Show()
        btn.qualityBorder:Hide()
        btn.upgradeStatus = "empty"
    end

    self:UpdateArmorySlotVisual(btn)
end

--[[
    Calculate upgrade status for a slot based on equipped item vs BiS
    Returns: "bis" (have BiS), "ok" (have alternative), "upgrade" (better available), "empty" (no item)
]]
function Journal:CalculateSlotUpgradeStatus(slotName, equippedItemId, equippedILvl)
    -- Get gear recommendations from new spec-based database
    local gearData = self:GetArmoryGearData(slotName)
    if not gearData then
        return "ok" -- No data, assume OK
    end

    -- Check if equipped is BiS
    if gearData.best and gearData.best.itemId == equippedItemId then
        return "bis"
    end

    -- Check if equipped is an alternative
    if gearData.alternatives then
        for _, alt in ipairs(gearData.alternatives) do
            if alt.itemId == equippedItemId then
                return "ok" -- Have an alternative, show upgrade available
            end
        end
    end

    -- Check if there's a significant iLvl upgrade available
    local bisILvl = gearData.best and gearData.best.iLvl or 0
    if bisILvl > 0 and equippedILvl < bisILvl then
        return "upgrade"
    end

    return "ok"
end

--[[
    Update the visual state of a slot button
]]
function Journal:UpdateArmorySlotVisual(btn)
    local C = HopeAddon.Constants.ARMORY_SLOT_BUTTON
    local stateColors = C.STATE_COLORS or {}
    local colors = HopeAddon.colors

    -- Get color config based on upgrade status
    local stateConfig = stateColors[btn.upgradeStatus]
    local borderColorName = stateConfig and stateConfig.border or "GREY"

    -- Resolve color name to actual color
    local borderColor = colors[borderColorName] or colors.GREY or { r = 0.4, g = 0.4, b = 0.4 }

    -- Selection overrides status color
    if btn.isSelected then
        borderColor = colors.ARCANE_PURPLE or { r = 0.61, g = 0.19, b = 1.0 }
    end

    btn:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

    -- Show/hide upgrade indicator
    if btn.upgradeStatus == "major" or btn.upgradeStatus == "upgrade" then
        btn.indicator:Show()
        -- Use phase color instead of hardcoded FEL_GREEN
        local phase = self.armoryState.selectedPhase or 1
        local phaseConfig = HopeAddon.Constants.ARMORY_PHASE_BUTTON.PHASES[phase]
        local indicatorColorName = phaseConfig and phaseConfig.color or "FEL_GREEN"
        local indColor = colors[indicatorColorName] or { r = 0.2, g = 0.8, b = 0.2 }
        btn.indicator.bg:SetVertexColor(indColor.r * 0.3, indColor.g * 0.3, indColor.b * 0.3, 0.9)
        btn.indicator.text:SetText("↑")
        btn.indicator.text:SetTextColor(indColor.r, indColor.g, indColor.b, 1)
    elseif btn.upgradeStatus == "bis" then
        btn.indicator:Show()
        -- Use phase color instead of hardcoded GOLD_BRIGHT
        local phase = self.armoryState.selectedPhase or 1
        local phaseConfig = HopeAddon.Constants.ARMORY_PHASE_BUTTON.PHASES[phase]
        local indicatorColorName = phaseConfig and phaseConfig.color or "GOLD_BRIGHT"
        local indColor = colors[indicatorColorName] or { r = 1, g = 0.84, b = 0 }
        btn.indicator.bg:SetVertexColor(indColor.r * 0.3, indColor.g * 0.3, indColor.b * 0.3, 0.9)
        btn.indicator.text:SetText("★")
        btn.indicator.text:SetTextColor(indColor.r, indColor.g, indColor.b, 1)
    else
        btn.indicator:Hide()
    end

    -- Selection glow
    if btn.isSelected then
        btn.glow:SetAlpha(0.5)
    else
        btn.glow:SetAlpha(0)
    end
end

--[[
    Refresh recommendations based on current phase/spec selection
]]
function Journal:RefreshArmoryRecommendations()
    -- Save spec preference
    if HopeAddon.charDb then
        HopeAddon.charDb.armory = HopeAddon.charDb.armory or {}
        HopeAddon.charDb.armory.selectedSpec = self.armoryState.selectedSpec
    end

    -- Refresh slot data to update upgrade status
    self:RefreshArmorySlotData()

    -- Refresh gear popup if a slot is selected and visible
    if self.armoryState.selectedSlot and self.armoryState.popupVisible then
        self:PopulateArmoryGearPopup(self.armoryState.selectedSlot)
    end

    self:UpdateArmoryFooter()
end

-- NOTE: Old detail panel functions (PopulateArmorySlotDetail, CreateArmoryUpgradeCard) have been removed.
-- Item display is now handled by CreateArmoryGearPopupItemRow() in the gear popup system.

--[[
    Get the current role for armory based on spec or saved preference
]]
function Journal:GetCurrentArmoryRole()
    -- Check saved preference first
    if self.armoryState.selectedSpec then
        local _, classToken = UnitClass("player")
        return HopeAddon:GetSpecRole(classToken, self.armoryState.selectedSpec)
    end

    -- Auto-detect from talents
    local _, classToken = UnitClass("player")
    local _, specTab = HopeAddon:GetPlayerSpec()
    return HopeAddon:GetSpecRole(classToken, specTab)
end

--[[
    Get the current guideKey for armory BiS lookup
    Returns: guideKey string (e.g., "warrior-dps", "protection-warrior-tank")
]]
function Journal:GetCurrentArmoryGuideKey()
    local _, classToken = UnitClass("player")
    local C = HopeAddon.Constants
    local specs = C:GetClassSpecs(classToken)
    if not specs or #specs == 0 then return nil end

    -- Get the current spec tab (1, 2, or 3)
    local specTab = self.armoryState.selectedSpec
    if not specTab then
        _, specTab = HopeAddon:GetPlayerSpec()
    end
    specTab = specTab or 1

    -- Find the matching spec entry
    -- Note: specTab is 1-3, and specs array is indexed by order in C.ARMORY_SPECS
    -- We need to match by checking the role or use the index directly
    local role = HopeAddon:GetSpecRole(classToken, specTab)

    for _, spec in ipairs(specs) do
        if spec.role == role then
            return spec.guideKey
        end
    end

    -- Fallback to first spec
    return specs[1] and specs[1].guideKey
end

--[[
    Filter gear items based on class weapon restrictions
    Removes items the current class cannot equip and promotes alternatives
]]
function Journal:FilterGearByClass(gearData, classToken)
    local C = HopeAddon.Constants
    if not gearData then return nil end
    if not C.CLASS_WEAPON_ALLOWED then return gearData end

    local allowed = C.CLASS_WEAPON_ALLOWED[classToken]
    if not allowed then return gearData end -- Unknown class, no filtering

    -- Helper to check if an item is allowed for this class
    local function isAllowed(item)
        if not item then return false end
        if not item.weaponType then return true end -- No weapon type = allow
        for _, wtype in ipairs(allowed) do
            if item.weaponType == wtype then
                return true
            end
        end
        return false
    end

    -- Make a copy to avoid modifying the original data
    local filtered = {
        best = gearData.best,
        alternatives = {},
    }

    -- Copy alternatives
    if gearData.alternatives then
        for _, alt in ipairs(gearData.alternatives) do
            table.insert(filtered.alternatives, alt)
        end
    end

    -- If best item is not allowed, find first allowed alternative to promote
    if filtered.best and not isAllowed(filtered.best) then
        local promoted = nil
        local newAlternatives = {}

        for _, alt in ipairs(filtered.alternatives) do
            if not promoted and isAllowed(alt) then
                promoted = alt -- First allowed alternative becomes best
            else
                table.insert(newAlternatives, alt)
            end
        end

        filtered.best = promoted
        filtered.alternatives = newAlternatives
    end

    -- Filter alternatives to only include allowed items
    if filtered.alternatives then
        local allowedAlts = {}
        for _, alt in ipairs(filtered.alternatives) do
            if isAllowed(alt) then
                table.insert(allowedAlts, alt)
            end
        end
        filtered.alternatives = allowedAlts
    end

    return filtered
end

--[[
    Get gear data using the new spec-based BiS database
    Returns data in legacy format for compatibility
    Filters weapon slots based on class restrictions
]]
function Journal:GetArmoryGearData(slotName)
    local C = HopeAddon.Constants
    local phase = self.armoryState.selectedPhase or 1
    local role = self:GetCurrentArmoryRole()

    -- Use phase number directly (no tier conversion needed)
    if C.GetArmoryGear then
        local gearData = C:GetArmoryGear(phase, role, slotName)
        if gearData then
            -- Filter weapon slots by class restrictions
            if slotName == "ranged" or slotName == "mainhand" or slotName == "offhand" then
                local _, classToken = UnitClass("player")
                gearData = self:FilterGearByClass(gearData, classToken)
            end
            return gearData
        end
    end

    return nil
end

-- NOTE: Old detail panel helper functions (ClearArmoryDetailContent, GetArmoryDetailFontString,
-- ClearArmoryDetailPanel) have been removed. The gear popup manages its own content lifecycle.

--------------------------------------------------------------------------------
-- ARMORY EVENT HANDLERS
--------------------------------------------------------------------------------

function Journal:OnArmorySlotClick(slotName)
    local slotBtn = self.armoryUI.slotButtons[slotName]

    -- If clicking the same slot that's already selected, toggle popup off
    if self.armoryState.selectedSlot == slotName and self.armoryState.popupVisible then
        self:HideArmoryGearPopup()
        -- Deselect the slot
        if slotBtn then
            slotBtn.isSelected = false
            self:UpdateArmorySlotVisual(slotBtn)
        end
        self.armoryState.selectedSlot = nil
        return
    end

    -- Deselect previous slot
    if self.armoryState.selectedSlot then
        local prevBtn = self.armoryUI.slotButtons[self.armoryState.selectedSlot]
        if prevBtn then
            prevBtn.isSelected = false
            self:UpdateArmorySlotVisual(prevBtn)
        end
    end

    -- Select new slot
    self.armoryState.selectedSlot = slotName
    if slotBtn then
        slotBtn.isSelected = true
        self:UpdateArmorySlotVisual(slotBtn)
    end

    -- Show gear popup near the slot
    self:ShowArmoryGearPopup(slotName, slotBtn)
end

function Journal:OnArmorySlotEnter(btn)
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")

    -- Show equipped item first (if any)
    if btn.equippedItem and btn.equippedItem.itemId then
        GameTooltip:SetInventoryItem("player", btn.slotId)
    else
        GameTooltip:SetText(btn.slotName:upper(), 1, 0.84, 0)
        GameTooltip:AddLine("No item equipped", 0.5, 0.5, 0.5)
    end

    -- Divider
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("---------------------", 0.3, 0.3, 0.3)

    -- Get BiS recommendation for current phase/role
    local gearData = self:GetArmoryGearData(btn.slotName)

    if gearData and gearData.best then
        local best = gearData.best
        local phase = self.armoryState.selectedPhase or 1

        -- BiS header (green)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Phase " .. phase .. " Best in Slot:", 0.2, 0.8, 0.2)

        -- BiS item name (quality colored)
        local qualityColors = HopeAddon.Constants.ARMORY_QUALITY_COLORS
        local qc = qualityColors[best.quality or "epic"] or qualityColors.epic
        GameTooltip:AddLine("  " .. (best.name or "Unknown"), qc.r, qc.g, qc.b)

        -- iLvl
        if best.iLvl then
            GameTooltip:AddLine("  iLvl " .. best.iLvl, 0.7, 0.7, 0.7)
        end

        -- Source (orange)
        if best.source then
            local sourceText = best.source
            if best.sourceDetail then
                sourceText = sourceText .. " - " .. best.sourceDetail
            end
            GameTooltip:AddLine("  " .. sourceText, 1, 0.5, 0)
        end

        -- Upgrade indicator
        if btn.equippedItem and btn.equippedItem.iLvl then
            local equippedILvl = btn.equippedItem.iLvl or 0
            local bisILvl = best.iLvl or 0
            local diff = bisILvl - equippedILvl
            if diff > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("  +" .. diff .. " item levels upgrade!", 0.2, 1, 0.2)
            elseif diff == 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("  Already at BiS!", 1, 0.84, 0)
            end
        end

        -- Alternatives count
        if gearData.alternatives and #gearData.alternatives > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("  " .. #gearData.alternatives .. " alternative(s) available", 0.5, 0.5, 0.5)
        end
    else
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("No BiS data for Phase " .. (self.armoryState.selectedPhase or 1), 0.5, 0.5, 0.5)
    end

    -- Click hint
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click for upgrade options", 0.4, 0.4, 0.4)

    GameTooltip:Show()
end

function Journal:OnArmorySlotLeave(btn)
    if not btn then return end
    if GameTooltip then
        GameTooltip:Hide()
    end
end

--------------------------------------------------------------------------------
-- ARMORY ENHANCED TOOLTIP SYSTEM
--------------------------------------------------------------------------------

--[[
    Build an enhanced gear tooltip with drop info, tips, stat priority, alternatives
    Follows the Attunements tab pattern with color-coded sections
]]
function Journal:BuildArmoryGearTooltip(itemData, anchorFrame)
    if not itemData then return end

    GameTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT", 8, 0)

    -- Show standard item tooltip first (use proper item link format)
    local itemId = itemData.id or itemData.itemId
    if itemId and itemId > 0 then
        -- Full item link format: item:itemId:enchant:gem1:gem2:gem3:gem4:suffix:uniqueId
        GameTooltip:SetHyperlink("item:" .. itemId .. ":0:0:0:0:0:0:0")
    else
        GameTooltip:SetText(itemData.name or "Unknown Item", 1, 1, 1)
    end

    -- Try to get enhanced hover data
    local hoverData = itemData.hoverData
    if not hoverData then
        -- Build basic hover data from existing fields
        hoverData = self:BuildBasicHoverData(itemData)
    end

    if hoverData then
        -- Divider
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("=======================", 0.4, 0.4, 0.4)

        -- Drop Information (gold header)
        if hoverData.dropInfo then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Drop Information:", 1, 0.84, 0)
            local di = hoverData.dropInfo
            if di.bossName then
                GameTooltip:AddLine("  Boss: " .. di.bossName, 0.9, 0.9, 0.9)
            end
            if di.instance then
                GameTooltip:AddLine("  Instance: " .. di.instance, 0.9, 0.9, 0.9)
            end
            if di.difficulty then
                GameTooltip:AddLine("  Difficulty: " .. di.difficulty, 0.7, 0.7, 0.7)
            end
            if di.dropRate then
                GameTooltip:AddLine("  Drop Rate: " .. di.dropRate, 0.7, 0.9, 0.7)
            end
            if di.tokenInfo then
                GameTooltip:AddLine("  Token: " .. di.tokenInfo, 0.9, 0.7, 1)
            end
        end

        -- Rep Sources (fel green header) - used by Reputation tab upgrade items
        if hoverData.repSources and #hoverData.repSources > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("How to Get Rep:", 0.4, 1, 0.4)
            for _, source in ipairs(hoverData.repSources) do
                GameTooltip:AddLine("  • " .. source, 0.8, 0.8, 0.8, true)
            end
        end

        -- Stat Priority (arcane purple header)
        if hoverData.statPriority and #hoverData.statPriority > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Stat Priority:", 0.61, 0.19, 1.0)
            for i, stat in ipairs(hoverData.statPriority) do
                GameTooltip:AddLine("  " .. i .. ". " .. stat, 0.8, 0.8, 0.8)
            end
        end

        -- Tips (orange header)
        if hoverData.tips and #hoverData.tips > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Tips:", 1, 0.5, 0)
            for _, tip in ipairs(hoverData.tips) do
                GameTooltip:AddLine("  • " .. tip, 0.8, 0.8, 0.8, true)
            end
        end

        -- Alternatives (sky blue header)
        if hoverData.alternatives and #hoverData.alternatives > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Alternatives:", 0.3, 0.7, 1.0)
            for _, alt in ipairs(hoverData.alternatives) do
                GameTooltip:AddLine("  • " .. alt, 0.7, 0.7, 0.7, true)
            end
        end

        -- Prerequisites (hellfire red header)
        if hoverData.prerequisites and #hoverData.prerequisites > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Requirements:", 0.9, 0.2, 0.1)
            for _, prereq in ipairs(hoverData.prerequisites) do
                GameTooltip:AddLine("  • " .. prereq, 0.8, 0.6, 0.6, true)
            end
        end
    end

    GameTooltip:Show()
end

--[[
    Build basic hover data from existing item fields (fallback)
]]
function Journal:BuildBasicHoverData(itemData)
    local hoverData = {}

    if itemData.source or itemData.sourceDetail or itemData.sourceType then
        hoverData.dropInfo = {}

        if itemData.sourceType == "raid" then
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
        elseif itemData.sourceType == "badge" then
            hoverData.dropInfo.instance = "Badge of Justice Vendor"
            if itemData.badgeCost then
                hoverData.dropInfo.difficulty = itemData.badgeCost .. " Badges"
            end
        elseif itemData.sourceType == "crafted" then
            hoverData.dropInfo.instance = itemData.source or "Crafted"
            hoverData.dropInfo.difficulty = "Requires profession"
        elseif itemData.sourceType == "reputation" or itemData.sourceType == "rep" then
            hoverData.dropInfo.instance = itemData.source or "Reputation Vendor"
            if itemData.standing then
                hoverData.prerequisites = { "Requires " .. itemData.standing .. " with " .. (itemData.faction or itemData.source) }
            end
        elseif itemData.sourceType == "heroic" then
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
            hoverData.dropInfo.difficulty = "Heroic"
        elseif itemData.sourceType == "quest" then
            hoverData.dropInfo.instance = "Quest Reward"
            hoverData.dropInfo.difficulty = itemData.sourceDetail
        else
            hoverData.dropInfo.bossName = itemData.source
            hoverData.dropInfo.instance = itemData.sourceDetail
        end
    end

    if not next(hoverData) then
        return nil
    end

    return hoverData
end

--------------------------------------------------------------------------------
-- ARMORY GEAR POPUP (Floating popup for BiS and alternatives)
--------------------------------------------------------------------------------

--[[
    Get or create the gear popup frame
    Phase 60 Redesign: Larger popup with BiS showcase, filter bar, grouped alternatives
    Uses the Get/Show/Hide pattern from MinigamesUI
]]
function Journal:GetArmoryGearPopup()
    if self.armoryUI.gearPopup then
        return self.armoryUI.gearPopup
    end

    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP

    -- IMPORTANT: Parent popup to mainFrame (not characterView) so it renders above all Armory content
    local popupParent = self.mainFrame or UIParent

    -- Create popup frame at DIALOG strata so it floats above everything
    local popup = CreateFrame("Frame", "HopeArmoryGearPopup", popupParent, "BackdropTemplate")
    popup:SetSize(C.WIDTH, C.MAX_HEIGHT)
    popup:SetBackdrop(C.BACKDROP)
    popup:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
    popup:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(100)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:SetClampedToScreen(true)
    popup:Hide()

    --======================================================================
    -- HEADER SECTION
    --======================================================================
    local header = CreateFrame("Frame", nil, popup)
    header:SetHeight(C.HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 0, 0)

    -- Make header draggable
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")

    header:SetScript("OnDragStart", function()
        popup:StartMoving()
        popup.isBeingDragged = true
    end)

    header:SetScript("OnDragStop", function()
        popup:StopMovingOrSizing()
        popup.isBeingDragged = false
        popup.hasBeenMoved = true  -- Flag that user repositioned
    end)

    -- Visual feedback: cursor changes when hovering over draggable header
    header:SetScript("OnEnter", function(self)
        SetCursor("Interface\\CURSOR\\UI-Cursor-Move")
    end)

    header:SetScript("OnLeave", function(self)
        SetCursor(nil)  -- Reset to default
    end)

    -- Slot icon (left of title)
    local slotIcon = header:CreateTexture(nil, "ARTWORK")
    slotIcon:SetSize(24, 24)
    slotIcon:SetPoint("LEFT", header, "LEFT", C.PADDING, 0)
    slotIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
    popup.slotIcon = slotIcon

    -- Header title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", slotIcon, "RIGHT", 8, 0)
    title:SetText("UPGRADES")
    popup.title = title

    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -C.PADDING, 0)
    closeBtn:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Down")
    closeBtn:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:HideArmoryGearPopup()
    end)
    popup.closeBtn = closeBtn

    -- Divider below header
    local headerDivider = popup:CreateTexture(nil, "OVERLAY")
    headerDivider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", C.PADDING, 0)
    headerDivider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -C.PADDING, 0)
    headerDivider:SetHeight(1)
    headerDivider:SetColorTexture(0.4, 0.35, 0.25, 1)

    --======================================================================
    -- BIS SHOWCASE SECTION (Featured item card)
    --======================================================================
    local bisSection = CreateFrame("Frame", nil, popup)
    bisSection:SetHeight(C.BIS_SECTION_HEIGHT)
    bisSection:SetPoint("TOPLEFT", popup, "TOPLEFT", C.PADDING, -C.HEADER_HEIGHT - 4)
    bisSection:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -C.PADDING, -C.HEADER_HEIGHT - 4)
    popup.bisSection = bisSection

    -- BiS section label
    local bisLabel = bisSection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bisLabel:SetPoint("TOPLEFT", bisSection, "TOPLEFT", 0, 0)
    bisLabel:SetText("BEST IN SLOT")
    bisLabel:SetTextColor(1, 0.84, 0)  -- Gold
    popup.bisLabel = bisLabel

    -- Placeholder for BiS card (populated dynamically)
    popup.bisCardFrame = nil

    --======================================================================
    -- FILTER BAR SECTION
    --======================================================================
    local filterBar = CreateFrame("Frame", nil, popup)
    filterBar:SetHeight(C.FILTER_BAR_HEIGHT)
    filterBar:SetPoint("TOPLEFT", bisSection, "BOTTOMLEFT", 0, -8)
    filterBar:SetPoint("TOPRIGHT", bisSection, "BOTTOMRIGHT", 0, -8)
    popup.filterBar = filterBar

    -- "Alternatives" label
    local altLabel = filterBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    altLabel:SetPoint("LEFT", filterBar, "LEFT", 0, 0)
    altLabel:SetText("Alternatives:")
    altLabel:SetTextColor(0.8, 0.8, 0.8)
    popup.altLabel = altLabel

    -- Filter buttons container (populated dynamically)
    popup.filterButtons = {}

    -- Divider below filter bar
    local filterDivider = popup:CreateTexture(nil, "OVERLAY")
    filterDivider:SetPoint("TOPLEFT", filterBar, "BOTTOMLEFT", 0, -4)
    filterDivider:SetPoint("TOPRIGHT", filterBar, "BOTTOMRIGHT", 0, -4)
    filterDivider:SetHeight(1)
    filterDivider:SetColorTexture(0.3, 0.3, 0.3, 0.6)
    popup.filterDivider = filterDivider

    --======================================================================
    -- ALTERNATIVES SCROLL SECTION
    --======================================================================
    local scrollYStart = C.HEADER_HEIGHT + C.BIS_SECTION_HEIGHT + C.FILTER_BAR_HEIGHT + 20

    local scrollFrame = CreateFrame("ScrollFrame", "HopeArmoryGearPopupScroll", popup, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", C.PADDING, -scrollYStart)
    scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -C.PADDING - 20, C.FOOTER_HEIGHT)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetWidth(C.WIDTH - C.PADDING * 2 - 20)
    scrollFrame:SetScrollChild(scrollContent)
    popup.scrollFrame = scrollFrame
    popup.scrollContent = scrollContent

    --======================================================================
    -- FOOTER SECTION (Try On Full Set button)
    --======================================================================
    local footer = CreateFrame("Frame", nil, popup)
    footer:SetHeight(C.FOOTER_HEIGHT)
    footer:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", C.PADDING, 0)
    footer:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -C.PADDING, 0)
    popup.footer = footer

    -- "Try On Full BiS Set" button
    local tryOnSetBtn = CreateFrame("Button", nil, footer, "BackdropTemplate")
    tryOnSetBtn:SetSize(140, 24)
    tryOnSetBtn:SetPoint("LEFT", footer, "LEFT", 0, 0)
    tryOnSetBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    local tryOnText = tryOnSetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tryOnText:SetPoint("CENTER")
    tryOnText:SetText("Try On BiS Set")
    tryOnSetBtn.text = tryOnText

    tryOnSetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.84, 0)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    tryOnSetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end)
    tryOnSetBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:TryOnBisSet()
    end)
    popup.tryOnSetBtn = tryOnSetBtn

    -- "Reset Model" button
    local resetBtn = CreateFrame("Button", nil, footer, "BackdropTemplate")
    resetBtn:SetSize(100, 24)
    resetBtn:SetPoint("LEFT", tryOnSetBtn, "RIGHT", 8, 0)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resetText:SetPoint("CENTER")
    resetText:SetText("Reset")
    resetBtn.text = resetText

    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.8, 0.7, 0.2)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end)
    resetBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        self:ResetModelToEquipped()
    end)
    popup.resetBtn = resetBtn

    -- Item count indicator (right side)
    local itemCount = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    itemCount:SetPoint("RIGHT", footer, "RIGHT", 0, 0)
    itemCount:SetTextColor(0.6, 0.6, 0.6)
    popup.itemCount = itemCount

    --======================================================================
    -- POOLED ELEMENTS TRACKING
    --======================================================================
    popup.itemRows = {}           -- Currently displayed item rows (pooled)
    popup.groupHeaders = {}       -- Currently displayed group headers (pooled)
    popup.activeFilterBtns = {}   -- Currently displayed filter buttons (pooled)
    popup.emptyFontStrings = {}   -- Orphan text cleanup tracking

    --======================================================================
    -- EVENT HANDLERS
    --======================================================================
    popup:SetScript("OnShow", function()
        self:RegisterArmoryClickAwayHandler()
    end)

    popup:SetScript("OnHide", function()
        self:UnregisterArmoryClickAwayHandler()
        -- Release pooled frames when hiding
        self:ReleaseArmoryPopupFrames()
    end)

    -- ESC key to close
    popup:SetScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" then
            self:HideArmoryGearPopup()
        end
    end)
    popup:SetPropagateKeyboardInput(true)

    self.armoryUI.gearPopup = popup
    return popup
end

--[[
    Release all pooled frames from the gear popup
]]
function Journal:ReleaseArmoryPopupFrames()
    local popup = self.armoryUI.gearPopup
    if not popup then return end

    -- Release BiS card
    if popup.bisCardFrame and self.armoryPools.bisCard then
        self.armoryPools.bisCard:Release(popup.bisCardFrame)
        popup.bisCardFrame = nil
    end

    -- Release item rows
    if popup.itemRows and self.armoryPools.popupItemRow then
        for _, row in ipairs(popup.itemRows) do
            self.armoryPools.popupItemRow:Release(row)
        end
        wipe(popup.itemRows)
    end

    -- Release group headers
    if popup.groupHeaders and self.armoryPools.groupHeader then
        for _, header in ipairs(popup.groupHeaders) do
            self.armoryPools.groupHeader:Release(header)
        end
        wipe(popup.groupHeaders)
    end

    -- Release filter buttons
    if popup.activeFilterBtns and self.armoryPools.filterBtn then
        for _, btn in ipairs(popup.activeFilterBtns) do
            self.armoryPools.filterBtn:Release(btn)
        end
        wipe(popup.activeFilterBtns)
    end

    -- Clear orphan FontStrings
    if popup.emptyFontStrings then
        for _, fs in ipairs(popup.emptyFontStrings) do
            fs:Hide()
            fs:SetText("")
        end
        wipe(popup.emptyFontStrings)
    end
end

--[[
    Show the gear popup near the clicked slot
    Phase 60: Added screen bounds checking to prevent popup from going off-screen
]]
function Journal:ShowArmoryGearPopup(slotName, anchorBtn)
    local popup = self:GetArmoryGearPopup()
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP

    -- Reset manual position flag when showing - each slot click repositions to that slot
    popup.hasBeenMoved = false

    -- Get positioning info for this slot
    local posInfo = C.POSITION_OFFSETS[slotName]
    if not posInfo then
        posInfo = { side = "RIGHT", x = 10, y = 0 }
    end

    -- Update title with slot name
    local slotData = HopeAddon.Constants.ARMORY_SLOT_BUTTON.SLOTS[slotName]
    popup.title:SetText((slotData and slotData.displayName) or slotName:upper())

    -- Populate with gear data FIRST (sets popup height)
    self:PopulateArmoryGearPopup(slotName)

    -- Clear previous anchoring
    popup:ClearAllPoints()

    -- Get screen dimensions
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local popupWidth = popup:GetWidth()
    local popupHeight = popup:GetHeight()

    -- Get anchor button position
    local btnLeft = anchorBtn:GetLeft() or 0
    local btnRight = anchorBtn:GetRight() or 0
    local btnTop = anchorBtn:GetTop() or 0
    local btnBottom = anchorBtn:GetBottom() or 0
    local btnCenterY = (btnTop + btnBottom) / 2

    -- Calculate preferred position based on slot
    local preferredSide = posInfo.side
    local finalX, finalY
    local usedSide = preferredSide

    -- Check if preferred side fits, otherwise flip
    if preferredSide == "RIGHT" then
        -- Check if popup fits on right
        if btnRight + posInfo.x + popupWidth <= screenWidth then
            popup:SetPoint("LEFT", anchorBtn, "RIGHT", posInfo.x, posInfo.y)
        else
            -- Flip to left
            popup:SetPoint("RIGHT", anchorBtn, "LEFT", -posInfo.x, posInfo.y)
            usedSide = "LEFT"
        end
    elseif preferredSide == "LEFT" then
        -- Check if popup fits on left
        if btnLeft + posInfo.x - popupWidth >= 0 then
            popup:SetPoint("RIGHT", anchorBtn, "LEFT", posInfo.x, posInfo.y)
        else
            -- Flip to right
            popup:SetPoint("LEFT", anchorBtn, "RIGHT", -posInfo.x, posInfo.y)
            usedSide = "RIGHT"
        end
    elseif preferredSide == "TOP" then
        -- Check if popup fits above
        if btnTop + posInfo.y + popupHeight <= screenHeight then
            popup:SetPoint("BOTTOM", anchorBtn, "TOP", posInfo.x, posInfo.y)
        else
            -- Flip to below
            popup:SetPoint("TOP", anchorBtn, "BOTTOM", posInfo.x, -posInfo.y)
            usedSide = "BOTTOM"
        end
    else
        -- Default: right side
        popup:SetPoint("LEFT", anchorBtn, "RIGHT", 10, 0)
    end

    -- After positioning, check for vertical overflow and adjust
    popup:Show()

    -- Use C_Timer or direct check after Show
    local popupTop = popup:GetTop() or 0
    local popupBottom = popup:GetBottom() or 0

    -- Clamp to screen bounds vertically
    local verticalOffset = 0
    if popupTop > screenHeight then
        verticalOffset = screenHeight - popupTop - 10
    elseif popupBottom < 0 then
        verticalOffset = -popupBottom + 10
    end

    if verticalOffset ~= 0 and (usedSide == "LEFT" or usedSide == "RIGHT") then
        -- Re-anchor with vertical offset
        popup:ClearAllPoints()
        if usedSide == "RIGHT" then
            popup:SetPoint("LEFT", anchorBtn, "RIGHT", posInfo.x, posInfo.y + verticalOffset)
        else
            popup:SetPoint("RIGHT", anchorBtn, "LEFT", posInfo.x, posInfo.y + verticalOffset)
        end
    end

    self.armoryState.popupVisible = true
    self.armoryState.selectedSlot = slotName
end

--[[
    Hide the gear popup
]]
function Journal:HideArmoryGearPopup()
    if self.armoryUI.gearPopup then
        self.armoryUI.gearPopup:Hide()
    end
    self.armoryState.popupVisible = false
end

--[[
    Populate the gear popup with BiS and alternatives for the selected slot
    Phase 60 Redesign: BiS showcase card, filter bar, grouped alternatives
]]
function Journal:PopulateArmoryGearPopup(slotName)
    local popup = self.armoryUI.gearPopup
    if not popup then return end

    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local scrollContent = popup.scrollContent
    local journalSelf = self

    -- Release all pooled frames from previous population
    self:ReleaseArmoryPopupFrames()

    -- Store current slot for refresh operations
    self.armoryState.popup.lastSlot = slotName

    -- Get gear recommendations for this slot
    local gearData = self:GetArmoryGearData(slotName)

    -- Update slot icon in header
    local slotData = HopeAddon.Constants.ARMORY_SLOT_BUTTON.SLOTS[slotName]
    if slotData and slotData.slotId then
        local invSlot = GetInventoryItemTexture("player", slotData.slotId)
        if invSlot then
            popup.slotIcon:SetTexture(invSlot)
        else
            popup.slotIcon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
        end
    end

    --======================================================================
    -- EMPTY STATE (No gear data)
    --======================================================================
    if not gearData or (not gearData.best and (not gearData.alternatives or #gearData.alternatives == 0)) then
        local phase = self.armoryState.selectedPhase or 1
        local CC = HopeAddon.Constants

        -- Hide BiS section
        popup.bisSection:Hide()
        popup.filterBar:Hide()
        popup.filterDivider:Hide()
        popup.tryOnSetBtn:Hide()
        popup.resetBtn:Hide()
        popup.itemCount:SetText("")

        -- Show empty message
        local emptyText = scrollContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOP", scrollContent, "TOP", 0, -40)
        emptyText:SetText("No gear data for\nPhase " .. phase .. " yet")
        emptyText:SetTextColor(0.6, 0.6, 0.6, 1)
        table.insert(popup.emptyFontStrings, emptyText)

        -- Hint about available phases
        local hintText = scrollContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hintText:SetPoint("TOP", emptyText, "BOTTOM", 0, -10)
        if CC:HasArmoryPhaseData(1) then
            hintText:SetText("Phase 1 data is available.")
            hintText:SetTextColor(0.5, 0.8, 0.5, 1)
        else
            hintText:SetText("No phase data available.")
            hintText:SetTextColor(0.5, 0.5, 0.5, 1)
        end
        table.insert(popup.emptyFontStrings, hintText)

        scrollContent:SetHeight(100)
        popup:SetHeight(C.MIN_HEIGHT)
        return
    end

    -- Show sections
    popup.bisSection:Show()
    popup.filterBar:Show()
    popup.filterDivider:Show()
    popup.tryOnSetBtn:Show()
    popup.resetBtn:Show()

    --======================================================================
    -- BIS SHOWCASE CARD
    --======================================================================
    if gearData.best then
        self:PopulateBisCard(popup, gearData.best)
    else
        -- No BiS, hide the section
        if popup.bisCardFrame then
            self.armoryPools.bisCard:Release(popup.bisCardFrame)
            popup.bisCardFrame = nil
        end
        popup.bisLabel:Hide()
    end

    --======================================================================
    -- FILTER BAR
    --======================================================================
    self:PopulateArmoryFilterBar(popup, gearData)

    --======================================================================
    -- ALTERNATIVES LIST (Grouped by source type)
    --======================================================================
    local yOffset = 0
    local totalHeight = 0
    local itemCount = 0

    if gearData.alternatives and #gearData.alternatives > 0 then
        -- Group alternatives by source type
        local grouped = self:GroupItemsBySource(gearData.alternatives)

        -- Get sort order for groups
        local sortedGroups = self:GetSortedSourceGroups(grouped)

        -- Get current filter
        local activeFilter = self.armoryState.popup.activeFilter or "all"

        -- Render each group
        for _, groupKey in ipairs(sortedGroups) do
            local items = grouped[groupKey]
            if items and #items > 0 then
                -- Skip this group if filtered out
                if activeFilter ~= "all" and activeFilter ~= groupKey then
                    -- Skip
                else
                    -- Create group header (collapsible)
                    local groupHeader = self:CreateArmoryGroupHeader(scrollContent, groupKey, #items, yOffset)
                    table.insert(popup.groupHeaders, groupHeader)
                    yOffset = yOffset - C.GROUP_HEADER.HEIGHT - 4
                    totalHeight = totalHeight + C.GROUP_HEADER.HEIGHT + 4

                    -- Check if group is expanded
                    local isExpanded = self.armoryState.popup.expandedGroups[groupKey]
                    if isExpanded == nil then isExpanded = true end  -- Default expanded

                    if isExpanded then
                        -- Render items in this group
                        for _, itemData in ipairs(items) do
                            local row = self:CreateArmoryPopupItemRow(scrollContent, itemData, yOffset)
                            table.insert(popup.itemRows, row)
                            yOffset = yOffset - C.ITEM_HEIGHT - C.ITEM_GAP
                            totalHeight = totalHeight + C.ITEM_HEIGHT + C.ITEM_GAP
                            itemCount = itemCount + 1
                        end
                    end
                end
            end
        end
    end

    -- Update item count in footer
    popup.itemCount:SetText(itemCount .. " alternatives")

    -- Set scroll content height
    scrollContent:SetHeight(math.max(totalHeight, 60))

    -- Calculate popup height
    local fixedHeight = C.HEADER_HEIGHT + C.BIS_SECTION_HEIGHT + C.FILTER_BAR_HEIGHT + C.FOOTER_HEIGHT + 30
    local contentHeight = totalHeight + 20
    local popupHeight = fixedHeight + math.min(contentHeight, C.MAX_HEIGHT - fixedHeight)
    popup:SetHeight(math.max(math.min(popupHeight, C.MAX_HEIGHT), C.MIN_HEIGHT))
end

--[[
    Group items by their source type
]]
function Journal:GroupItemsBySource(items)
    local groups = {}
    for _, item in ipairs(items) do
        local sourceType = item.sourceType or "world"
        if not groups[sourceType] then
            groups[sourceType] = {}
        end
        table.insert(groups[sourceType], item)
    end
    return groups
end

--[[
    Get sorted array of source group keys based on SOURCE_GROUPS order
]]
function Journal:GetSortedSourceGroups(grouped)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local sorted = {}

    -- Collect all group keys
    for key in pairs(grouped) do
        table.insert(sorted, key)
    end

    -- Sort by order defined in SOURCE_GROUPS
    table.sort(sorted, function(a, b)
        local orderA = C.SOURCE_GROUPS[a] and C.SOURCE_GROUPS[a].order or 99
        local orderB = C.SOURCE_GROUPS[b] and C.SOURCE_GROUPS[b].order or 99
        return orderA < orderB
    end)

    return sorted
end

--======================================================================
-- GEAR POPUP HELPER FUNCTIONS (Phase 60)
--======================================================================

--[[
    Populate the BiS showcase card at top of popup
]]
function Journal:PopulateBisCard(popup, bisItem)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local journalSelf = self

    -- Acquire BiS card from pool
    local card = self.armoryPools.bisCard:Acquire()
    card:SetParent(popup.bisSection)
    card:ClearAllPoints()
    card:SetPoint("TOPLEFT", popup.bisLabel, "BOTTOMLEFT", 0, -4)
    card:SetPoint("TOPRIGHT", popup.bisSection, "TOPRIGHT", 0, -20)

    -- Set icon
    local itemId = bisItem.id or bisItem.itemId
    if itemId and itemId > 0 then
        GetItemInfo(itemId)  -- Queue for cache
        local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)
        if itemTexture then
            card.icon:SetTexture(itemTexture)
        elseif bisItem.icon then
            local iconPath = bisItem.icon
            if not iconPath:find("Interface") then
                iconPath = "Interface\\ICONS\\" .. iconPath
            end
            card.icon:SetTexture(iconPath)
        else
            card.icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        end
    end

    -- Set icon border color based on quality
    local qualityColors = HopeAddon.Constants.ARMORY_QUALITY_COLORS
    local qualityColor = qualityColors[bisItem.quality or "epic"] or qualityColors.epic
    card.iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Set name with quality color
    card.nameText:SetText(bisItem.name or "Unknown Item")
    card.nameText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Set item level
    card.iLevelText:SetText(bisItem.iLvl and ("iLvl " .. bisItem.iLvl) or "")
    -- Apply phase color to item level
    local phaseColorName = C:GetPhaseColorForItemLevel(bisItem.iLvl)
    if phaseColorName then
        local phaseColor = HopeAddon.colors[phaseColorName]
        card.iLevelText:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b)
    else
        card.iLevelText:SetTextColor(0.7, 0.7, 0.7)  -- Default gray
    end

    -- Set source
    local sourceText = bisItem.source or "Unknown Source"
    if bisItem.sourceDetail then
        sourceText = sourceText .. " - " .. bisItem.sourceDetail
    end
    card.sourceText:SetText(sourceText)

    -- Try On button handler
    card.tryOnBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        journalSelf:PreviewItemOnModel(bisItem)
    end)

    -- Store item data for tooltip
    card.itemData = bisItem
    card.itemId = itemId

    -- Tooltip on hover
    card:SetScript("OnEnter", function(self)
        journalSelf:BuildArmoryGearTooltip(self.itemData, self)
    end)
    card:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    card:Show()
    popup.bisCardFrame = card
    popup.bisLabel:Show()
end

--[[
    Populate the filter bar with source type buttons
]]
function Journal:PopulateArmoryFilterBar(popup, gearData)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local journalSelf = self

    -- Clear existing filter buttons
    if popup.activeFilterBtns then
        for _, btn in ipairs(popup.activeFilterBtns) do
            self.armoryPools.filterBtn:Release(btn)
        end
        wipe(popup.activeFilterBtns)
    end

    -- Collect unique source types from alternatives
    local sourceTypes = {}
    if gearData.alternatives then
        for _, item in ipairs(gearData.alternatives) do
            local st = item.sourceType or "world"
            sourceTypes[st] = (sourceTypes[st] or 0) + 1
        end
    end

    -- Create "All" button first
    local xOffset = 80  -- After "Alternatives:" label
    local activeFilter = self.armoryState.popup.activeFilter or "all"

    local allBtn = self.armoryPools.filterBtn:Acquire()
    allBtn:SetParent(popup.filterBar)
    allBtn:ClearAllPoints()
    allBtn:SetPoint("LEFT", popup.filterBar, "LEFT", xOffset, 0)
    allBtn:SetWidth(50)
    allBtn.text:SetText("All")
    allBtn.filterKey = "all"
    allBtn.isActive = (activeFilter == "all")

    if allBtn.isActive then
        allBtn:SetBackdropBorderColor(0.3, 0.8, 0.3)
        allBtn.activeIndicator:Show()
    else
        allBtn:SetBackdropBorderColor(0.5, 0.5, 0.5)
        allBtn.activeIndicator:Hide()
    end

    allBtn:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        journalSelf:SetArmoryPopupFilter("all")
    end)

    allBtn:Show()
    table.insert(popup.activeFilterBtns, allBtn)
    xOffset = xOffset + 58

    -- Create buttons for each source type
    local sortedTypes = {}
    for st in pairs(sourceTypes) do
        table.insert(sortedTypes, st)
    end
    table.sort(sortedTypes, function(a, b)
        local orderA = C.SOURCE_GROUPS[a] and C.SOURCE_GROUPS[a].order or 99
        local orderB = C.SOURCE_GROUPS[b] and C.SOURCE_GROUPS[b].order or 99
        return orderA < orderB
    end)

    for _, sourceType in ipairs(sortedTypes) do
        local groupInfo = C.SOURCE_GROUPS[sourceType]
        if groupInfo then
            local btn = self.armoryPools.filterBtn:Acquire()
            btn:SetParent(popup.filterBar)
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", popup.filterBar, "LEFT", xOffset, 0)

            -- Shorter label for space
            local label = groupInfo.label:gsub(" Dungeon", ""):gsub(" Drops", ""):gsub(" Rewards", "")
            btn:SetWidth(math.max(btn.text:GetStringWidth() + 16, 60))
            btn.text:SetText(label)
            btn.filterKey = sourceType
            btn.isActive = (activeFilter == sourceType)

            if btn.isActive then
                btn:SetBackdropBorderColor(0.3, 0.8, 0.3)
                btn.activeIndicator:Show()
            else
                btn:SetBackdropBorderColor(0.5, 0.5, 0.5)
                btn.activeIndicator:Hide()
            end

            btn:SetScript("OnClick", function()
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
                journalSelf:SetArmoryPopupFilter(sourceType)
            end)

            btn:Show()
            table.insert(popup.activeFilterBtns, btn)
            xOffset = xOffset + btn:GetWidth() + 4
        end
    end
end

--[[
    Set the active filter and refresh the popup
]]
function Journal:SetArmoryPopupFilter(filterKey)
    self.armoryState.popup.activeFilter = filterKey

    -- Refresh the popup content
    local lastSlot = self.armoryState.popup.lastSlot
    if lastSlot then
        self:PopulateArmoryGearPopup(lastSlot)
    end
end

--[[
    Create a collapsible group header for a source type
]]
function Journal:CreateArmoryGroupHeader(parent, groupKey, itemCount, yOffset)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local journalSelf = self

    local header = self.armoryPools.groupHeader:Acquire()
    header:SetParent(parent)
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)

    -- Get group info
    local groupInfo = C.SOURCE_GROUPS[groupKey] or { label = groupKey, color = "GOLD_BRIGHT", icon = "Interface\\ICONS\\INV_Misc_QuestionMark" }

    -- Check expanded state
    local isExpanded = self.armoryState.popup.expandedGroups[groupKey]
    if isExpanded == nil then isExpanded = true end  -- Default expanded
    header.isExpanded = isExpanded
    header.groupKey = groupKey

    -- Set expand/collapse icon
    if isExpanded then
        header.expandIcon:SetTexture(C.GROUP_HEADER.COLLAPSE_ICON)
    else
        header.expandIcon:SetTexture(C.GROUP_HEADER.EXPAND_ICON)
    end

    -- Set source icon
    header.sourceIcon:SetTexture(groupInfo.icon)

    -- Set label with color
    local color = HopeAddon.colors[groupInfo.color] or HopeAddon.colors.GOLD_BRIGHT
    header.labelText:SetText(groupInfo.label)
    header.labelText:SetTextColor(color.r, color.g, color.b)

    -- Set count
    header.countText:SetText("(" .. itemCount .. ")")

    -- Click to toggle expand/collapse
    header:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        journalSelf.armoryState.popup.expandedGroups[groupKey] = not isExpanded
        -- Refresh popup
        local lastSlot = journalSelf.armoryState.popup.lastSlot
        if lastSlot then
            journalSelf:PopulateArmoryGearPopup(lastSlot)
        end
    end)

    header:Show()
    return header
end

--[[
    Create a compact item row for the alternatives list (uses pool)
]]
function Journal:CreateArmoryPopupItemRow(parent, itemData, yOffset)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local journalSelf = self

    local row = self.armoryPools.popupItemRow:Acquire()
    row:SetParent(parent)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)

    -- Store item data
    row.itemData = itemData
    row.itemId = itemData.id or itemData.itemId or 0

    -- Set icon
    local itemId = row.itemId
    if itemId and itemId > 0 then
        GetItemInfo(itemId)  -- Queue for cache
        local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)
        if itemTexture then
            row.icon:SetTexture(itemTexture)
        elseif itemData.icon then
            local iconPath = itemData.icon
            if not iconPath:find("Interface") then
                iconPath = "Interface\\ICONS\\" .. iconPath
            end
            row.icon:SetTexture(iconPath)
        else
            row.icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        end
    end

    -- Set icon border color based on quality
    local qualityColors = HopeAddon.Constants.ARMORY_QUALITY_COLORS
    local qualityColor = qualityColors[itemData.quality or "rare"] or qualityColors.rare
    row.iconBorder:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Set name with quality color
    row.nameText:SetText(itemData.name or "Unknown Item")
    row.nameText:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)

    -- Set source
    local sourceText = itemData.source or "Unknown"
    if itemData.sourceDetail then
        sourceText = sourceText .. " - " .. itemData.sourceDetail
    end
    row.sourceText:SetText(sourceText)

    -- Set iLevel
    row.iLevelText:SetText(itemData.iLvl and ("iLvl " .. itemData.iLvl) or "")
    -- Apply phase color to item level
    local phaseColorName = C:GetPhaseColorForItemLevel(itemData.iLvl)
    if phaseColorName then
        local phaseColor = HopeAddon.colors[phaseColorName]
        row.iLevelText:SetTextColor(phaseColor.r, phaseColor.g, phaseColor.b)
    else
        row.iLevelText:SetTextColor(0.7, 0.7, 0.7)  -- Default gray
    end

    -- Click to preview
    row:SetScript("OnClick", function()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        journalSelf:PreviewItemOnModel(itemData)
    end)

    -- Tooltip on hover
    row:SetScript("OnEnter", function(self)
        self.highlight:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
        journalSelf:BuildArmoryGearTooltip(self.itemData, self)
    end)
    row:SetScript("OnLeave", function(self)
        self.highlight:SetColorTexture(0.3, 0.3, 0.3, 0)
        GameTooltip:Hide()
    end)

    row:Show()
    return row
end

--[[
    Create a single item row in the gear popup
    Enhanced with hover highlight, full item tooltip, and Preview button
]]
function Journal:CreateArmoryGearPopupItemRow(parent, itemData, isBis, yOffset)
    local C = HopeAddon.Constants.ARMORY_GEAR_POPUP
    local journalSelf = self  -- Capture for closures

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(C.ITEM_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)

    -- Store full item data for enhanced tooltip
    row.itemData = itemData
    row.itemId = itemData.id or itemData.itemId or 0
    row.itemName = itemData.name or "Unknown"
    row.itemSource = itemData.source or ""
    row.itemSourceType = itemData.sourceType or "unknown"

    -- Background
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    local normalBg, normalBorder
    if isBis then
        normalBg = { r = 0.15, g = 0.12, b = 0.05, a = 0.95 }
        normalBorder = { r = 1, g = 0.84, b = 0, a = 1 }  -- Gold border for BiS
    else
        normalBg = { r = 0.1, g = 0.1, b = 0.1, a = 0.95 }
        normalBorder = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    end
    row:SetBackdropColor(normalBg.r, normalBg.g, normalBg.b, normalBg.a)
    row:SetBackdropBorderColor(normalBorder.r, normalBorder.g, normalBorder.b, normalBorder.a)
    row.normalBg = normalBg
    row.normalBorder = normalBorder

    -- Highlight overlay (shown on hover)
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.3)
    row.highlight = highlight

    -- Icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(C.ITEM.ICON_SIZE, C.ITEM.ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Try to get icon from item ID first, fall back to provided icon
    local itemId = itemData.id or itemData.itemId
    if itemId and itemId > 0 then
        -- Request item info FIRST to queue for cache
        GetItemInfo(itemId)
        -- Now try to get the texture (may be cached now or from previous request)
        local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)
        if itemTexture then
            icon:SetTexture(itemTexture)
        elseif itemData.icon then
            local iconPath = itemData.icon
            if not iconPath:find("Interface") then
                iconPath = "Interface\\ICONS\\" .. iconPath
            end
            icon:SetTexture(iconPath)
        else
            icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        end
    elseif itemData.icon then
        local iconPath = itemData.icon
        if not iconPath:find("Interface") then
            iconPath = "Interface\\ICONS\\" .. iconPath
        end
        icon:SetTexture(iconPath)
    else
        icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
    end
    row.icon = icon

    -- BiS star indicator
    if isBis then
        local star = row:CreateTexture(nil, "OVERLAY")
        star:SetSize(C.ITEM.BIS_INDICATOR_SIZE, C.ITEM.BIS_INDICATOR_SIZE)
        star:SetPoint("TOPLEFT", icon, "TOPLEFT", -4, 4)
        star:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
        star:SetVertexColor(C.ITEM.BIS_COLOR.r, C.ITEM.BIS_COLOR.g, C.ITEM.BIS_COLOR.b)
        row.star = star
    end

    -- Item name (quality colored) - adjust width to leave room for preview button
    local name = row:CreateFontString(nil, "OVERLAY", C.ITEM.NAME_FONT)
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    name:SetPoint("RIGHT", row, "RIGHT", -70, 0)  -- Leave room for preview button
    name:SetJustifyH("LEFT")
    name:SetText(itemData.name or "Unknown Item")

    -- Apply quality color
    local qualityColors = HopeAddon.Constants.ARMORY_QUALITY_COLORS
    local qualityColor = qualityColors[itemData.quality or "rare"] or qualityColors.rare
    name:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
    row.name = name

    -- Item level and stats
    local stats = row:CreateFontString(nil, "OVERLAY", C.ITEM.ILEVEL_FONT)
    stats:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
    stats:SetPoint("RIGHT", row, "RIGHT", -70, 0)
    stats:SetJustifyH("LEFT")
    local iLvlText = itemData.iLvl and ("iLvl " .. itemData.iLvl) or ""
    local statsText = itemData.stats or ""
    stats:SetText(iLvlText .. (iLvlText ~= "" and " - " or "") .. statsText)
    stats:SetTextColor(0.7, 0.7, 0.7, 1)
    row.stats = stats

    -- Source info
    local source = row:CreateFontString(nil, "OVERLAY", C.ITEM.SOURCE_FONT)
    source:SetPoint("TOPLEFT", stats, "BOTTOMLEFT", 0, -2)
    source:SetPoint("RIGHT", row, "RIGHT", -70, 0)
    source:SetJustifyH("LEFT")
    local sourceText = itemData.source or "Unknown Source"
    if itemData.sourceDetail then
        sourceText = sourceText .. " - " .. itemData.sourceDetail
    end
    source:SetText(sourceText)

    -- Source color based on type - use new ARMORY_SOURCE_COLORS
    local sourceColors = HopeAddon.Constants.ARMORY_SOURCE_COLORS
    local sourceColor = sourceColors[itemData.sourceType or "raid"]
    if sourceColor then
        source:SetTextColor(sourceColor.r, sourceColor.g, sourceColor.b, 1)
    else
        source:SetTextColor(0.6, 0.6, 0.6, 1)
    end
    row.source = source

    -- Preview button (right side of item row)
    local previewBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
    previewBtn:SetSize(55, 20)
    previewBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)

    -- Button backdrop
    previewBtn:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    previewBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    previewBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- Button text
    local btnText = previewBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER")
    btnText:SetText("Preview")
    btnText:SetTextColor(0.9, 0.9, 0.9, 1)
    previewBtn.text = btnText

    -- Preview button hover effects
    previewBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 1)
        self:SetBackdropBorderColor(0.8, 0.7, 0.2, 1)
        self.text:SetTextColor(1, 1, 1, 1)
    end)

    previewBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end)

    -- Preview button click handler: preview item on model
    -- Note: Use self (Journal) from closure, not global Journal reference
    previewBtn:SetScript("OnClick", function()
        local modelFrame = self.armoryUI and self.armoryUI.modelFrame
        local itemIdToPreview = row.itemId

        if modelFrame and itemIdToPreview and itemIdToPreview > 0 then
            local itemLink = select(2, GetItemInfo(itemIdToPreview))
            if itemLink then
                modelFrame:TryOn(itemLink)
                if HopeAddon.Sounds and HopeAddon.Sounds.PlayClick then
                    HopeAddon.Sounds:PlayClick()
                end
            else
                -- Item not cached yet, request it
                GetItemInfo(itemIdToPreview)
                HopeAddon:Print("Item not cached. Click again to preview.")
            end
        end
    end)

    row.previewBtn = previewBtn

    -- Row hover tooltip (enhanced item tooltip via BuildArmoryGearTooltip)
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        -- Brighten on hover
        self:SetBackdropColor(
            self.normalBg.r * 1.3,
            self.normalBg.g * 1.3,
            self.normalBg.b * 1.3,
            self.normalBg.a
        )

        -- Sound effect
        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayHover()
        end

        -- Show enhanced tooltip with drop info, tips, etc.
        journalSelf:BuildArmoryGearTooltip(self.itemData, self)
    end)

    row:SetScript("OnLeave", function(self)
        -- Restore normal colors (with nil safety)
        if self and self.normalBg then
            self:SetBackdropColor(self.normalBg.r, self.normalBg.g, self.normalBg.b, self.normalBg.a)
        end

        -- Hide tooltip
        GameTooltip:Hide()
    end)

    -- Row click (entire row) also previews item
    row:SetScript("OnClick", function(self)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
        Journal:PreviewItemOnModel(itemData)
    end)

    row:Show()
    return row
end

--[[
    Preview an item on the character model
]]
function Journal:PreviewItemOnModel(itemData)
    local modelFrame = self.armoryUI.modelFrame
    if not modelFrame then return end

    -- Handle both itemId and id fields
    local itemId = itemData and (itemData.itemId or itemData.id)
    if not itemId then return end

    -- Try to dress the model with this item
    -- Note: DressUpModel:TryOn() may not work in TBC Classic for all items
    local itemLink = "item:" .. itemId
    if modelFrame.TryOn then
        modelFrame:TryOn(itemLink)
    end
end

--[[
    Try on the full BiS set for all slots (Phase 60)
    Iterates through all equipment slots and tries on each BiS item
]]
function Journal:TryOnBisSet()
    local modelFrame = self.armoryUI.modelFrame
    if not modelFrame or not modelFrame.TryOn then
        HopeAddon:Print("Model frame not available for try-on.")
        return
    end

    local phase = self.armoryState.selectedPhase or 1
    local CC = HopeAddon.Constants

    -- Get all slot names
    local slots = { "head", "neck", "shoulders", "back", "chest", "wrist", "hands", "waist", "legs", "feet", "ring1", "ring2", "trinket1", "trinket2", "mainhand", "offhand", "ranged" }

    local triedOnCount = 0

    for _, slotName in ipairs(slots) do
        -- Skip hidden slots
        if not CC.ARMORY_HIDDEN_SLOTS[slotName] then
            local gearData = self:GetArmoryGearData(slotName)
            if gearData and gearData.best then
                local itemId = gearData.best.itemId or gearData.best.id
                if itemId then
                    local itemLink = "item:" .. itemId
                    modelFrame:TryOn(itemLink)
                    triedOnCount = triedOnCount + 1
                end
            end
        end
    end

    if triedOnCount > 0 then
        HopeAddon:Print("Trying on " .. triedOnCount .. " BiS items for Phase " .. phase .. ".")
    else
        HopeAddon:Print("No BiS items available for Phase " .. phase .. ".")
    end
end

--[[
    Reset the model to show currently equipped gear (Phase 60)
]]
function Journal:ResetModelToEquipped()
    local modelFrame = self.armoryUI.modelFrame
    if not modelFrame then
        HopeAddon:Print("Model frame not available.")
        return
    end

    -- DressUpModel has Undress() method to remove all previewed items
    if modelFrame.Undress then
        modelFrame:Undress()
        HopeAddon:Print("Model reset to current equipment.")
    elseif modelFrame.RefreshUnit then
        -- Alternative: refresh from player unit
        modelFrame:RefreshUnit()
        HopeAddon:Print("Model refreshed.")
    else
        -- Fallback: SetUnit to re-dress from player
        if modelFrame.SetUnit then
            modelFrame:SetUnit("player")
        end
        HopeAddon:Print("Model reset.")
    end
end

--[[
    Register click-away handler to dismiss popup
]]
function Journal:RegisterArmoryClickAwayHandler()
    -- Create a frame that catches clicks outside the popup
    -- Parent to characterView so it only covers the armory area (not fullscreen)
    local characterView = self.armoryUI.characterView
    if not characterView then return end

    if not self.armoryClickAwayFrame then
        local frame = CreateFrame("Button", "HopeArmoryClickAway", characterView)
        frame:SetAllPoints(characterView)
        frame:SetFrameStrata("MEDIUM")
        frame:EnableMouse(true)
        frame:RegisterForClicks("AnyUp")
        frame:SetScript("OnClick", function()
            -- Check if mouse is over any slot button - if so, click that slot instead
            for slotName, slotBtn in pairs(self.armoryUI.slotButtons or {}) do
                if slotBtn:IsVisible() and slotBtn:IsMouseOver() then
                    -- Forward click to the slot button
                    slotBtn:Click()
                    return
                end
            end

            -- Also check if mouse is over the popup itself - don't close if clicking popup
            if self.armoryUI.gearPopup and self.armoryUI.gearPopup:IsMouseOver() then
                return
            end

            -- Mouse not over any slot or popup - close the popup
            self:HideArmoryGearPopup()
            -- Also deselect the slot
            if self.armoryState.selectedSlot then
                local btn = self.armoryUI.slotButtons[self.armoryState.selectedSlot]
                if btn then
                    btn.isSelected = false
                    self:UpdateArmorySlotVisual(btn)
                end
                self.armoryState.selectedSlot = nil
            end
        end)
        self.armoryClickAwayFrame = frame
    else
        -- Re-parent if characterView changed
        self.armoryClickAwayFrame:SetParent(characterView)
        self.armoryClickAwayFrame:SetAllPoints(characterView)
    end

    -- Frame level: above model frame but below slots container
    -- characterView level + 5 (model is at characterView level, slots are at +10)
    self.armoryClickAwayFrame:SetFrameLevel(characterView:GetFrameLevel() + 5)
    self.armoryClickAwayFrame:Show()
end

--[[
    Unregister click-away handler
]]
function Journal:UnregisterArmoryClickAwayHandler()
    if self.armoryClickAwayFrame then
        self.armoryClickAwayFrame:Hide()
    end
end

function Journal:SelectArmoryPhase(phase)
    self.armoryState.selectedPhase = phase

    -- Update phase button visuals
    for p, btn in pairs(self.armoryUI.phaseButtons) do
        local state = (p == phase) and "active" or "inactive"
        self:SetPhaseButtonState(btn, state)
    end

    -- Refresh slot indicators to reflect new phase
    self:RefreshArmorySlotData()

    -- Refresh popup if visible
    if self.armoryState.popupVisible and self.armoryState.selectedSlot then
        self:ShowArmoryGearPopup(self.armoryState.selectedSlot, self.armoryUI.slotButtons[self.armoryState.selectedSlot])
    end

    -- Save preference
    if HopeAddon.charDb then
        HopeAddon.charDb.armory = HopeAddon.charDb.armory or {}
        HopeAddon.charDb.armory.selectedPhase = phase
    end
end

function Journal:ToggleArmorySection(sectionId)
    local isExpanded = self.armoryState.expandedSections[sectionId]
    self.armoryState.expandedSections[sectionId] = not isExpanded

    -- Refresh detail panel to reflect change
    if self.armoryState.selectedSlot then
        self:PopulateArmorySlotDetail(self.armoryState.selectedSlot)
    end
end

function Journal:ToggleArmoryWishlist(itemData)
    if not itemData or not itemData.itemId then return end

    local itemId = itemData.itemId
    if self.armoryState.wishlist[itemId] then
        self.armoryState.wishlist[itemId] = nil
    else
        self.armoryState.wishlist[itemId] = true
    end

    -- Save to character data
    if HopeAddon.charDb then
        HopeAddon.charDb.armory = HopeAddon.charDb.armory or {}
        HopeAddon.charDb.armory.wishlist = self.armoryState.wishlist
    end

    -- Update visuals
    self:RefreshArmorySlotData()
    self:UpdateArmoryFooter()
end

function Journal:IsItemWishlisted(itemId)
    return self.armoryState.wishlist[itemId] == true
end

function Journal:OnArmoryFooterButtonClick(buttonId)
    if buttonId == "addWishlist" then
        -- Add all "BEST" items to wishlist (placeholder)
        HopeAddon:Print("Wishlist feature coming soon!")
    elseif buttonId == "close" then
        self.armoryState.selectedSlot = nil
        self:ClearArmoryDetailPanel()
        -- Deselect all slots
        for _, btn in pairs(self.armoryUI.slotButtons) do
            btn.isSelected = false
            self:UpdateArmorySlotVisual(btn)
        end
    end
end

--------------------------------------------------------------------------------
-- ARMORY POOL INITIALIZATION FUNCTIONS
--------------------------------------------------------------------------------

function Journal:InitializeUpgradeCard(card)
    local C = HopeAddon.Constants.ARMORY_UPGRADE_CARD

    card:SetHeight(C.HEIGHT)
    card:SetBackdrop(C.BACKDROP)
    card:SetBackdropColor(C.BG_COLOR.r, C.BG_COLOR.g, C.BG_COLOR.b, C.BG_COLOR.a)
    card:SetBackdropBorderColor(C.BORDER_COLOR.r, C.BORDER_COLOR.g, C.BORDER_COLOR.b, C.BORDER_COLOR.a)

    -- Item icon
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    icon:SetPoint("TOPLEFT", card, "TOPLEFT", C.ICON_OFFSET.x, C.ICON_OFFSET.y)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    card.icon = icon

    -- Item name
    local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", card, "TOPLEFT", C.NAME_OFFSET.x, C.NAME_OFFSET.y)
    nameText:SetJustifyH("LEFT")
    card.nameText = nameText

    -- Item level
    local iLevelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iLevelText:SetPoint("TOPLEFT", card, "TOPLEFT", C.ILEVEL_OFFSET.x, C.ILEVEL_OFFSET.y)
    iLevelText:SetTextColor(0.7, 0.7, 0.7, 1)
    card.iLevelText = iLevelText

    -- Data storage
    card.itemData = nil
    card.isWishlisted = false
    card.isBest = false
end

function Journal:ResetUpgradeCard(card)
    card:Hide()
    card:ClearAllPoints()
    card.itemData = nil
    card.isWishlisted = false
    card.isBest = false
end

function Journal:InitializeSectionHeader(header)
    local C = HopeAddon.Constants.ARMORY_SECTION_HEADER

    header:SetHeight(C.HEIGHT)
    header:SetBackdrop(C.BACKDROP)
    header:EnableMouse(true)

    -- Collapse arrow
    local arrow = header:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(C.ARROW_SIZE, C.ARROW_SIZE)
    arrow:SetPoint("LEFT", header, "LEFT", C.PADDING_H, 0)
    arrow:SetTexture(C.ARROW_EXPANDED)
    header.arrow = arrow

    -- Title text
    local title = header:CreateFontString(nil, "OVERLAY", C.FONT)
    title:SetPoint("LEFT", arrow, "RIGHT", C.GAP, 0)
    header.title = title

    -- Item count
    local count = header:CreateFontString(nil, "OVERLAY", C.COUNT_FONT)
    count:SetPoint("LEFT", title, "RIGHT", 6, 0)
    count:SetTextColor(C.COUNT_COLOR.r, C.COUNT_COLOR.g, C.COUNT_COLOR.b, C.COUNT_COLOR.a)
    header.count = count

    -- Data storage
    header.sectionId = nil
    header.isExpanded = true
    header.sectionColor = nil
end

function Journal:ResetSectionHeader(header)
    header:Hide()
    header:ClearAllPoints()
    header.sectionId = nil
    header.isExpanded = true
    header.sectionColor = nil
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
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -15)
    notif.titleText:SetText(HopeAddon:ColorText("MILESTONE REACHED", "GOLD_BRIGHT"))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -8)
    notif.line1:SetText("Level " .. level .. ": " .. title)
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
    notif.titleText:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -12)
    notif.titleText:SetText(HopeAddon:ColorText("NEW LAND DISCOVERED", zoneColor))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.BODY, 12, "")
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -5)
    notif.line1:SetText(title)
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.SMALL, 10, "")
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
    notif.titleText:SetFont(HopeAddon.assets.fonts.TITLE, 18, "")
    notif.titleText:SetPoint("TOP", notif, "TOP", 0, -15)
    notif.titleText:SetText(HopeAddon:ColorText("VICTORY!", "HELLFIRE_RED"))

    notif.line1:ClearAllPoints()
    notif.line1:SetFont(HopeAddon.assets.fonts.HEADER, 14, "")
    notif.line1:SetPoint("TOP", notif.titleText, "BOTTOM", 0, -8)
    notif.line1:SetText(killData.bossName .. " defeated!")
    notif.line1:SetTextColor(1, 1, 1, 1)

    notif.line2:ClearAllPoints()
    notif.line2:SetFont(HopeAddon.assets.fonts.BODY, 11, "")
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
        -- Migrate removed tab selections to journey (stats now goes to raids for boss tracking)
        if lastTab == "zones" or lastTab == "milestones" or lastTab == "directory" then
            lastTab = "journey"
        elseif lastTab == "stats" then
            lastTab = "raids"
        end
        self:SelectTab(lastTab)
    end
end

-- Register with addon
if HopeAddon.Debug then
    HopeAddon:Debug("Journal module loaded")
end
