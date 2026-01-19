--[[
    HopeAddon Pages Module
    Journal page templates and rendering
]]

local Pages = {}
HopeAddon.Pages = Pages

--[[
    Module lifecycle: OnInitialize
]]
function Pages:OnInitialize()
end

--[[
    Module lifecycle: OnEnable
]]
function Pages:OnEnable()
end

--[[
    Module lifecycle: OnDisable
]]
function Pages:OnDisable()
    -- Clear page cache
    for _, page in pairs(self.cachedPages) do
        if page and page.Hide then
            page:Hide()
            page:SetParent(nil)
        end
    end
    self.cachedPages = {}
end

--[[
    Get or create a cached page of the specified type
    Reuses existing pages instead of creating new ones each time
    @param parent Frame - Parent frame
    @param pageType string - One of TEMPLATES keys
    @param data table - Data to populate the page with
    @return Frame - The page frame
]]
function Pages:GetOrCreatePage(parent, pageType, data)
    local cacheKey = pageType

    -- Check if we have a cached page
    if self.cachedPages[cacheKey] then
        local page = self.cachedPages[cacheKey]
        page:SetParent(parent)
        page:Show()
        -- Note: Full content update would require template-specific update methods
        -- For now, caching helps with the frame creation overhead
        return page
    end

    -- Create new page using the appropriate template
    local templateFunc = self:GetTemplate(pageType)
    local page = templateFunc(self, parent, data)

    -- Cache for reuse
    self.cachedPages[cacheKey] = page

    return page
end

--[[
    Release a cached page (hides it but keeps in cache)
    @param pageType string - The page type to release
]]
function Pages:ReleasePage(pageType)
    local page = self.cachedPages[pageType]
    if page then
        page:Hide()
    end
end

--[[
    Clear all cached pages
]]
function Pages:ClearCache()
    for pageType, page in pairs(self.cachedPages) do
        if page and page.Hide then
            page:Hide()
        end
    end
    self.cachedPages = {}
end

-- Page template types
Pages.TEMPLATES = {
    MILESTONE = "milestone",
    ZONE = "zone",
    BOSS = "boss",
    ATTUNEMENT = "attunement",
    CUSTOM = "custom",
}

-- Page cache for reusing page frames (keyed by template type)
Pages.cachedPages = {}

--[[
    Create a milestone page layout
    @param parent Frame - Parent frame to attach to
    @param data table - Milestone data
    @return Frame - The page frame
]]
function Pages:CreateMilestonePage(parent, data)
    local Components = HopeAddon.Components

    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 400)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(1, 1, 1, 0.95)
    page:SetBackdropBorderColor(1, 0.84, 0, 1)

    -- Chapter header
    local chapterText = page:CreateFontString(nil, "OVERLAY")
    chapterText:SetFont(HopeAddon.assets.fonts.TITLE, 20)
    chapterText:SetPoint("TOP", page, "TOP", 0, -20)
    chapterText:SetText(HopeAddon:ColorText("CHAPTER " .. (data.chapter or "?") .. ": " .. (data.title or "Unknown"), "GOLD_BRIGHT"))
    chapterText:SetShadowOffset(2, -2)
    chapterText:SetShadowColor(0, 0, 0, 0.5)

    -- Divider
    local divider = page:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", chapterText, "BOTTOMLEFT", -30, -10)
    divider:SetPoint("TOPRIGHT", chapterText, "BOTTOMRIGHT", 30, -10)
    divider:SetVertexColor(HopeAddon:GetColor("GOLD_BRIGHT"))

    -- Icon
    if data.icon then
        local icon = page:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(data.icon)
        icon:SetSize(64, 64)
        icon:SetPoint("TOP", divider, "BOTTOM", 0, -20)

        -- Icon border
        local iconBorder = page:CreateTexture(nil, "OVERLAY")
        iconBorder:SetTexture(HopeAddon.assets.textures.TOOLTIP_BORDER)
        iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -4, 4)
        iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 4, -4)

        page.icon = icon
    end

    -- Level achieved
    local levelText = page:CreateFontString(nil, "OVERLAY")
    levelText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    levelText:SetPoint("TOP", page.icon or divider, "BOTTOM", 0, -20)
    levelText:SetText("Level " .. (data.level or "?") .. " Achieved")
    levelText:SetTextColor(1, 1, 1, 1)

    -- Date and zone
    local dateText = page:CreateFontString(nil, "OVERLAY")
    dateText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    dateText:SetPoint("TOP", levelText, "BOTTOM", 0, -5)
    dateText:SetText((data.date or "Unknown Date") .. " - " .. (data.zone or "Unknown Zone"))
    dateText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    -- Story/flavor text
    local storyText = page:CreateFontString(nil, "OVERLAY")
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 13)
    storyText:SetPoint("TOP", dateText, "BOTTOM", 0, -25)
    storyText:SetWidth(page:GetWidth() - 60)
    storyText:SetText('"' .. (data.story or "Your journey continues...") .. '"')
    storyText:SetTextColor(HopeAddon:GetTextColor("BRIGHT"))
    storyText:SetJustifyH("CENTER")

    -- Stats section
    local statsHeader = page:CreateFontString(nil, "OVERLAY")
    statsHeader:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    statsHeader:SetPoint("TOPLEFT", page, "TOPLEFT", 30, -280)
    statsHeader:SetText(HopeAddon:ColorText("STATS AT THIS MOMENT:", "BRONZE"))

    local statsText = page:CreateFontString(nil, "OVERLAY")
    statsText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    statsText:SetPoint("TOPLEFT", statsHeader, "BOTTOMLEFT", 0, -8)
    statsText:SetJustifyH("LEFT")

    local deaths = HopeAddon.charDb.stats.deaths.total
    local quests = HopeAddon.charDb.stats.questsCompleted
    local zones = 0
    for _ in pairs(HopeAddon.charDb.journal.zoneDiscoveries) do
        zones = zones + 1
    end

    statsText:SetText(string.format(
        "Deaths: %d (Battle Scars)\nQuests Completed: %d\nZones Discovered: %d",
        deaths, quests, zones
    ))
    statsText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))

    -- User note section
    local noteHeader = page:CreateFontString(nil, "OVERLAY")
    noteHeader:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    noteHeader:SetPoint("TOPLEFT", page, "TOPLEFT", 30, -360)
    noteHeader:SetText(HopeAddon:ColorText("My Thoughts:", "BRONZE"))

    local noteBox = CreateFrame("Frame", nil, page)
    noteBox:SetPoint("TOPLEFT", noteHeader, "BOTTOMLEFT", 0, -5)
    noteBox:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -30, 30)
    noteBox:SetBackdrop({
        bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
        edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    noteBox:SetBackdropColor(0, 0, 0, 0.3)
    noteBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5)

    local noteText = noteBox:CreateFontString(nil, "OVERLAY")
    noteText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    noteText:SetPoint("TOPLEFT", noteBox, "TOPLEFT", 8, -8)
    noteText:SetPoint("BOTTOMRIGHT", noteBox, "BOTTOMRIGHT", -8, 8)
    noteText:SetJustifyH("LEFT")
    noteText:SetJustifyV("TOP")
    noteText:SetText(data.userNote or "Click to add your thoughts...")
    noteText:SetTextColor(HopeAddon:GetTextColor("DISABLED"))

    page.noteText = noteText
    page.noteBox = noteBox

    return page
end

--[[
    Create a zone discovery page layout
    @param parent Frame - Parent frame
    @param data table - Zone data
    @return Frame - The page frame
]]
function Pages:CreateZonePage(parent, data)
    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 350)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT,
        edgeFile = HopeAddon.assets.textures.DIALOG_BORDER,
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(1, 1, 1, 0.95)

    -- Apply zone-themed border color
    local theme = HopeAddon.Glow.zoneThemes[data.zoneName]
    if theme then
        local color = HopeAddon.colors[theme.primary]
        if color then
            page:SetBackdropBorderColor(color.r, color.g, color.b, 1)
        end
    end

    -- Header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    header:SetPoint("TOP", page, "TOP", 0, -20)
    header:SetText(HopeAddon:ColorText("NEW LAND DISCOVERED", theme and theme.primary or "SKY_BLUE"))

    -- Zone icon
    if data.icon then
        local icon = page:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(data.icon)
        icon:SetSize(56, 56)
        icon:SetPoint("TOP", header, "BOTTOM", 0, -15)
        page.icon = icon
    end

    -- Zone title
    local titleText = page:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    titleText:SetPoint("TOP", page.icon or header, "BOTTOM", 0, -15)
    titleText:SetText(data.title or data.zoneName or "Unknown Zone")
    titleText:SetTextColor(1, 1, 1, 1)

    -- Flavor text
    local flavorText = page:CreateFontString(nil, "OVERLAY")
    flavorText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    flavorText:SetPoint("TOP", titleText, "BOTTOM", 0, -10)
    flavorText:SetWidth(page:GetWidth() - 60)
    flavorText:SetText('"' .. (data.flavor or "") .. '"')
    flavorText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    flavorText:SetJustifyH("CENTER")

    -- Discovery info
    local infoText = page:CreateFontString(nil, "OVERLAY")
    infoText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    infoText:SetPoint("TOP", flavorText, "BOTTOM", 0, -20)
    infoText:SetText(string.format(
        "First Visited: %s\nLevel When Discovered: %d",
        data.firstVisit or "Unknown",
        data.level or 0
    ))
    infoText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    return page
end

--[[
    Create a boss kill page layout
    @param parent Frame - Parent frame
    @param data table - Boss kill data
    @return Frame - The page frame
]]
function Pages:CreateBossPage(parent, data)
    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 400)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT_DARK,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true,
        tileSize = 32,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(HopeAddon:GetBgColor("DARK_OPAQUE"))
    page:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)

    -- Victory header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 22)
    header:SetPoint("TOP", page, "TOP", 0, -20)
    header:SetText(HopeAddon:ColorText("VICTORY", "HELLFIRE_RED"))

    -- Boss name
    local bossName = page:CreateFontString(nil, "OVERLAY")
    bossName:SetFont(HopeAddon.assets.fonts.HEADER, 18)
    bossName:SetPoint("TOP", header, "BOTTOM", 0, -15)
    bossName:SetText(data.bossName or "Unknown Boss")
    bossName:SetTextColor(1, 1, 1, 1)

    -- Dungeon/Raid name
    local dungeonName = page:CreateFontString(nil, "OVERLAY")
    dungeonName:SetFont(HopeAddon.assets.fonts.BODY, 12)
    dungeonName:SetPoint("TOP", bossName, "BOTTOM", 0, -5)
    dungeonName:SetText(data.dungeonName or "Unknown Location")
    dungeonName:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    -- Boss lore
    if data.lore then
        local loreText = page:CreateFontString(nil, "OVERLAY")
        loreText:SetFont(HopeAddon.assets.fonts.BODY, 11)
        loreText:SetPoint("TOP", dungeonName, "BOTTOM", 0, -15)
        loreText:SetWidth(page:GetWidth() - 60)
        loreText:SetText('"' .. data.lore .. '"')
        loreText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))
        loreText:SetJustifyH("CENTER")
    end

    -- Battle record
    local recordHeader = page:CreateFontString(nil, "OVERLAY")
    recordHeader:SetFont(HopeAddon.assets.fonts.HEADER, 12)
    recordHeader:SetPoint("TOPLEFT", page, "TOPLEFT", 30, -200)
    recordHeader:SetText(HopeAddon:ColorText("BATTLE RECORD:", "BRONZE"))

    local recordText = page:CreateFontString(nil, "OVERLAY")
    recordText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    recordText:SetPoint("TOPLEFT", recordHeader, "BOTTOMLEFT", 0, -8)
    recordText:SetText(string.format(
        "First Kill: %s\nTotal Kills: %d\nDeaths During Fight: %d",
        data.firstKill or "Unknown",
        data.totalKills or 1,
        data.deaths or 0
    ))
    recordText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))

    return page
end

--[[
    Create an attunement progress page
    @param parent Frame - Parent frame
    @param data table - Attunement data
    @return Frame - The page frame
]]
function Pages:CreateAttunementPage(parent, data)
    local Components = HopeAddon.Components

    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 450)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(1, 1, 1, 0.95)
    page:SetBackdropBorderColor(HopeAddon:GetColor("ARCANE_PURPLE"))

    -- Large raid icon at top (64x64)
    local raidIconPath = data.headerIcon and ("Interface\\Icons\\" .. data.headerIcon) or
                         (data.icon and ("Interface\\Icons\\" .. data.icon) or nil)
    local iconAnchor = page
    local iconAnchorPoint = "TOP"

    if raidIconPath then
        local raidIcon = page:CreateTexture(nil, "ARTWORK")
        raidIcon:SetTexture(raidIconPath)
        raidIcon:SetSize(64, 64)
        raidIcon:SetPoint("TOP", page, "TOP", 0, -20)

        -- Add glow for in-progress attunements
        if data.progress and data.progress > 0 and data.progress < 100 then
            HopeAddon.Effects:CreatePulsingGlow(raidIcon, "ARCANE_PURPLE", 0.8)
        elseif data.progress and data.progress >= 100 then
            HopeAddon.Effects:CreatePulsingGlow(raidIcon, "GOLD_BRIGHT", 0.5)
        end

        page.raidIcon = raidIcon
        iconAnchor = raidIcon
        iconAnchorPoint = "BOTTOM"
    end

    -- Header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    header:SetPoint("TOP", iconAnchor, iconAnchorPoint, 0, raidIconPath and -10 or -20)
    header:SetText(HopeAddon:ColorText("THE PATH TO " .. (data.raidName or "UNKNOWN"), "ARCANE_PURPLE"))

    -- Divider line under header
    local divider = page:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -40, -8)
    divider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 40, -8)
    divider:SetVertexColor(HopeAddon:GetColor("ARCANE_PURPLE"))

    -- Progress bar
    local progressBar = Components:CreateProgressBar(page, page:GetWidth() - 60, 25, "ARCANE_PURPLE")
    progressBar:SetPoint("TOP", divider, "BOTTOM", 0, -15)
    progressBar:SetProgress(data.progress or 0)

    if data.progress and data.progress >= 100 then
        HopeAddon.Effects:CreatePulsingGlow(progressBar, "GOLD_BRIGHT", 0.5)
    end

    -- Chapter list header
    local chaptersHeader = page:CreateFontString(nil, "OVERLAY")
    chaptersHeader:SetFont(HopeAddon.assets.fonts.HEADER, 14)
    chaptersHeader:SetPoint("TOP", progressBar, "BOTTOM", 0, -20)
    chaptersHeader:SetText(HopeAddon:ColorText("CHAPTERS", "BRONZE"))

    local chapters = HopeAddon.Attunements:GetAllChapters(data.raidKey or "karazhan")
    local yOffset = -45

    for i, chapter in ipairs(chapters) do
        local chapterFrame = CreateFrame("Frame", nil, page)
        chapterFrame:SetSize(page:GetWidth() - 40, 55)
        chapterFrame:SetPoint("TOP", progressBar, "BOTTOM", 0, yOffset)
        chapterFrame:SetBackdrop({
            bgFile = HopeAddon.assets.textures.TOOLTIP_BG,
            edgeFile = HopeAddon.assets.textures.TOOLTIP_BORDER,
            tile = true, tileSize = 8, edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })

        if chapter.complete then
            chapterFrame:SetBackdropColor(HopeAddon:GetBgColor("GREEN_TINT"))
            chapterFrame:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
        else
            chapterFrame:SetBackdropColor(HopeAddon:GetBgColor("DARK_FAINT"))
            chapterFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        end

        -- Location/dungeon icon (24x24) on the left
        local iconOffset = 10
        if chapter.locationIcon then
            local locationIcon = chapterFrame:CreateTexture(nil, "ARTWORK")
            locationIcon:SetTexture("Interface\\Icons\\" .. chapter.locationIcon)
            locationIcon:SetSize(24, 24)
            locationIcon:SetPoint("LEFT", chapterFrame, "LEFT", 10, 0)

            -- Desaturate if not complete
            if not chapter.complete then
                locationIcon:SetDesaturated(true)
                locationIcon:SetAlpha(0.6)
            end

            iconOffset = 40
            chapterFrame.locationIcon = locationIcon
        end

        -- Chapter number
        local numText = chapterFrame:CreateFontString(nil, "OVERLAY")
        numText:SetFont(HopeAddon.assets.fonts.HEADER, 12)
        numText:SetPoint("LEFT", chapterFrame, "LEFT", iconOffset, 0)
        numText:SetText(HopeAddon:ColorText(tostring(i), chapter.complete and "FEL_GREEN" or "GREY"))

        -- Chapter name
        local nameText = chapterFrame:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(HopeAddon.assets.fonts.HEADER, 12)
        nameText:SetPoint("LEFT", numText, "RIGHT", 10, 8)
        nameText:SetText(chapter.name)
        nameText:SetTextColor(chapter.complete and 1 or 0.6, chapter.complete and 1 or 0.6, chapter.complete and 1 or 0.6)

        -- Story text
        local storyText = chapterFrame:CreateFontString(nil, "OVERLAY")
        storyText:SetFont(HopeAddon.assets.fonts.BODY, 10)
        storyText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
        storyText:SetWidth(chapterFrame:GetWidth() - 100)
        storyText:SetText(chapter.story)
        storyText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))

        -- Status icon (check or X) instead of text
        local statusIcon = chapterFrame:CreateTexture(nil, "ARTWORK")
        if chapter.complete then
            statusIcon:SetTexture(HopeAddon.assets.statusIcons.CHECK_READY)
        else
            statusIcon:SetTexture(HopeAddon.assets.statusIcons.CHECK_NOT_READY)
        end
        statusIcon:SetSize(20, 20)
        statusIcon:SetPoint("RIGHT", chapterFrame, "RIGHT", -10, 0)
        chapterFrame.statusIcon = statusIcon

        yOffset = yOffset - 60
    end

    -- Calculate final page height
    local baseHeight = raidIconPath and 500 or 400
    page:SetHeight(baseHeight + (#chapters * 60))

    return page
end

--[[
    Create an attunement milestone page layout
    @param parent Frame - Parent frame
    @param data table - Attunement milestone data
    @return Frame - The page frame
]]
function Pages:CreateAttunementMilestonePage(parent, data)
    local Components = HopeAddon.Components

    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 400)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(1, 1, 1, 0.95)
    page:SetBackdropBorderColor(1, 0.84, 0, 1) -- Gold border for completion

    -- Header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 20)
    header:SetPoint("TOP", page, "TOP", 0, -20)
    header:SetText(HopeAddon:ColorText("ATTUNEMENT COMPLETE", "GOLD_BRIGHT"))
    header:SetShadowOffset(2, -2)
    header:SetShadowColor(0, 0, 0, 0.5)

    -- Divider under header
    local divider = page:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -50, -10)
    divider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 50, -10)
    divider:SetVertexColor(HopeAddon:GetColor("GOLD_BRIGHT"))

    -- Large Icon (64x64) with glow
    local iconPath = data.icon
    if iconPath and not string.find(iconPath, "Interface") then
        iconPath = "Interface\\Icons\\" .. iconPath
    end

    if iconPath then
        local icon = page:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(iconPath)
        icon:SetSize(72, 72)
        icon:SetPoint("TOP", divider, "BOTTOM", 0, -20)

        -- Gold glow effect for completion
        HopeAddon.Effects:CreatePulsingGlow(icon, "GOLD_BRIGHT", 0.5)

        -- Add sparkles for extra celebration
        if HopeAddon.Effects.CreateSparkles then
            HopeAddon.Effects:CreateSparkles(icon, 4, "GOLD_BRIGHT")
        end

        page.icon = icon
    end

    -- Ready check icon as visual confirmation
    local checkIcon = page:CreateTexture(nil, "OVERLAY")
    checkIcon:SetTexture(HopeAddon.assets.statusIcons.CHECK_READY)
    checkIcon:SetSize(24, 24)
    if page.icon then
        checkIcon:SetPoint("BOTTOMRIGHT", page.icon, "BOTTOMRIGHT", 8, -8)
    else
        checkIcon:SetPoint("TOP", divider, "BOTTOM", 0, -30)
    end

    -- Title
    local titleText = page:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.HEADER, 18)
    titleText:SetPoint("TOP", page.icon or divider, "BOTTOM", 0, -20)
    titleText:SetText(data.title or "Unknown Attunement")
    titleText:SetTextColor(1, 1, 1, 1)
    titleText:SetShadowOffset(1, -1)
    titleText:SetShadowColor(0, 0, 0, 0.3)

    -- Raid name subtitle
    if data.raidName then
        local raidText = page:CreateFontString(nil, "OVERLAY")
        raidText:SetFont(HopeAddon.assets.fonts.BODY, 14)
        raidText:SetPoint("TOP", titleText, "BOTTOM", 0, -5)
        raidText:SetText(HopeAddon:ColorText(data.raidName, "ARCANE_PURPLE"))
    end

    -- Story
    local storyText = page:CreateFontString(nil, "OVERLAY")
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 13)
    storyText:SetPoint("TOP", titleText, "BOTTOM", 0, data.raidName and -30 or -20)
    storyText:SetWidth(page:GetWidth() - 60)
    storyText:SetText('"' .. (data.story or "") .. '"')
    storyText:SetTextColor(HopeAddon:GetTextColor("BRIGHT"))
    storyText:SetJustifyH("CENTER")

    -- Bottom divider
    local bottomDivider = page:CreateTexture(nil, "ARTWORK")
    bottomDivider:SetTexture(HopeAddon.assets.textures.DIVIDER)
    bottomDivider:SetHeight(2)
    bottomDivider:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 30, 60)
    bottomDivider:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -30, 60)
    bottomDivider:SetVertexColor(HopeAddon:GetColor("BRONZE"))

    -- Date
    local dateText = page:CreateFontString(nil, "OVERLAY")
    dateText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    dateText:SetPoint("TOP", bottomDivider, "BOTTOM", 0, -10)
    dateText:SetText("Completed: " .. (data.date or "Unknown"))
    dateText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    return page
end

--[[
    Create a final boss milestone page layout
    @param parent Frame - Parent frame
    @param data table - Final boss milestone data
    @return Frame - The page frame
]]
function Pages:CreateFinalBossMilestonePage(parent, data)
    local Components = HopeAddon.Components

    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 400)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT_DARK,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = true,
        tileSize = 32,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(HopeAddon:GetBgColor("RED_TINT"))
    page:SetBackdropBorderColor(1, 0.84, 0, 1)

    -- Header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 22)
    header:SetPoint("TOP", page, "TOP", 0, -20)
    header:SetText(HopeAddon:ColorText("RAID CONQUERED", "GOLD_BRIGHT"))

    -- Icon with glow
    if data.icon then
        local icon = page:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(data.icon)
        icon:SetSize(72, 72)
        icon:SetPoint("TOP", header, "BOTTOM", 0, -20)

        HopeAddon.Effects:CreatePulsingGlow(icon, "HELLFIRE_RED", 0.5)
        HopeAddon.Effects:CreateSparkles(icon, 6, "GOLD_BRIGHT")

        page.icon = icon
    end

    -- Title
    local titleText = page:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.HEADER, 18)
    titleText:SetPoint("TOP", page.icon or header, "BOTTOM", 0, -20)
    titleText:SetText(data.title or "Unknown Victory")
    titleText:SetTextColor(1, 1, 1, 1)

    -- Boss name
    if data.bossName then
        local bossText = page:CreateFontString(nil, "OVERLAY")
        bossText:SetFont(HopeAddon.assets.fonts.BODY, 14)
        bossText:SetPoint("TOP", titleText, "BOTTOM", 0, -5)
        bossText:SetText(data.bossName .. " Defeated")
        bossText:SetTextColor(0.8, 0.2, 0.2, 1)
    end

    -- Story
    local storyText = page:CreateFontString(nil, "OVERLAY")
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    storyText:SetPoint("TOP", titleText, "BOTTOM", 0, -30)
    storyText:SetWidth(page:GetWidth() - 60)
    storyText:SetText('"' .. (data.story or "") .. '"')
    storyText:SetTextColor(HopeAddon:GetTextColor("BRIGHT"))
    storyText:SetJustifyH("CENTER")

    -- Date
    local dateText = page:CreateFontString(nil, "OVERLAY")
    dateText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    dateText:SetPoint("BOTTOM", page, "BOTTOM", 0, 30)
    dateText:SetText("Victory: " .. (data.date or "Unknown"))
    dateText:SetTextColor(HopeAddon:GetTextColor("TERTIARY"))

    return page
end

--[[
    Create a tier milestone page layout
    @param parent Frame - Parent frame
    @param data table - Tier milestone data
    @return Frame - The page frame
]]
function Pages:CreateTierMilestonePage(parent, data)
    local page = CreateFrame("Frame", nil, parent)
    page:SetSize(parent:GetWidth() - 40, 300)
    page:SetBackdrop({
        bgFile = HopeAddon.assets.textures.PARCHMENT,
        edgeFile = HopeAddon.assets.textures.GOLD_BORDER,
        tile = false,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    page:SetBackdropColor(1, 1, 1, 0.95)

    -- Color based on tier
    local tierColors = {
        T4 = "GOLD_BRIGHT",
        T5 = "SKY_BLUE",
        T6 = "HELLFIRE_RED",
    }
    local tierColor = tierColors[data.tier] or "ARCANE_PURPLE"
    local color = HopeAddon.colors[tierColor]
    if color then
        page:SetBackdropBorderColor(color.r, color.g, color.b, 1)
    end

    -- Header
    local header = page:CreateFontString(nil, "OVERLAY")
    header:SetFont(HopeAddon.assets.fonts.TITLE, 18)
    header:SetPoint("TOP", page, "TOP", 0, -20)
    header:SetText(HopeAddon:ColorText(data.tier .. " RAIDING BEGINS", tierColor))

    -- Icon
    if data.icon then
        local icon = page:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(data.icon)
        icon:SetSize(56, 56)
        icon:SetPoint("TOP", header, "BOTTOM", 0, -15)
        page.icon = icon
    end

    -- Title
    local titleText = page:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(HopeAddon.assets.fonts.HEADER, 16)
    titleText:SetPoint("TOP", page.icon or header, "BOTTOM", 0, -15)
    titleText:SetText(data.title or "New Tier")
    titleText:SetTextColor(1, 1, 1, 1)

    -- Story
    local storyText = page:CreateFontString(nil, "OVERLAY")
    storyText:SetFont(HopeAddon.assets.fonts.BODY, 12)
    storyText:SetPoint("TOP", titleText, "BOTTOM", 0, -10)
    storyText:SetWidth(page:GetWidth() - 60)
    storyText:SetText('"' .. (data.story or "") .. '"')
    storyText:SetTextColor(HopeAddon:GetTextColor("SECONDARY"))
    storyText:SetJustifyH("CENTER")

    -- Date
    local dateText = page:CreateFontString(nil, "OVERLAY")
    dateText:SetFont(HopeAddon.assets.fonts.BODY, 11)
    dateText:SetPoint("BOTTOM", page, "BOTTOM", 0, 25)
    dateText:SetText(data.date or "Unknown")
    dateText:SetTextColor(HopeAddon:GetTextColor("SUBTLE"))

    return page
end

--[[
    Get page template based on entry type
    @param entryType string - Type of entry
    @return function - Template creation function
]]
function Pages:GetTemplate(entryType)
    local templates = {
        level_milestone = self.CreateMilestonePage,
        zone_discovery = self.CreateZonePage,
        boss_kill = self.CreateBossPage,
        attunement = self.CreateAttunementPage,
        attunement_complete = self.CreateAttunementPage,
        attunement_milestone = self.CreateAttunementMilestonePage,
        final_boss_milestone = self.CreateFinalBossMilestonePage,
        boss_milestone = self.CreateBossPage,
        tier_milestone = self.CreateTierMilestonePage,
        raid_leader_milestone = self.CreateFinalBossMilestonePage,
    }

    return templates[entryType] or self.CreateMilestonePage
end

-- Register with addon
HopeAddon:RegisterModule("Pages", Pages)
if HopeAddon.Debug then
    HopeAddon:Debug("Pages module loaded")
end
