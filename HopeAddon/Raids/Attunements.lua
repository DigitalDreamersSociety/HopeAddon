--[[
    HopeAddon Attunements Module
    Raid attunement quest chain tracking
]]

local Attunements = {}
HopeAddon.Attunements = Attunements

--[[
    Module lifecycle: OnInitialize
]]
function Attunements:OnInitialize()
end

--[[
    Module lifecycle: OnEnable
]]
function Attunements:OnEnable()
end

--[[
    Module lifecycle: OnDisable
]]
function Attunements:OnDisable()
    -- Clear cached attunement map
    attunementMapCache = nil
end

-- Attunement states
Attunements.STATE = {
    NOT_STARTED = 0,
    IN_PROGRESS = 1,
    COMPLETED = 2,
}

-- Cached attunement map (lazy initialized on first use)
local attunementMapCache = nil

--[[
    TBC-Compatible faction lookup by ID
    GetFactionInfoByID() doesn't exist in TBC Classic, so we iterate through factions
    @param targetFactionId number - The faction ID to find
    @return number|nil - The standing ID (1-8) or nil if not found
]]
local function GetFactionStandingById(targetFactionId)
    -- Expand all faction headers to ensure we can find collapsed factions
    local numFactions = GetNumFactions()
    for i = 1, numFactions do
        local name, _, standingId, _, _, _, _, _, isHeader, _, hasRep, _, _, factionId = GetFactionInfo(i)
        if factionId == targetFactionId then
            return standingId
        end
    end
    return nil
end

--[[
    Get attunement data for a raid
    @param raidKey string - Raid identifier (karazhan, ssc, tk, hyjal, bt, cipher)
    @return table|nil - Attunement chain data
]]
function Attunements:GetAttunementData(raidKey)
    -- Lazy initialize the cache on first use (ensures Constants is loaded)
    if not attunementMapCache then
        local C = HopeAddon.Constants
        attunementMapCache = {
            karazhan = C.KARAZHAN_ATTUNEMENT,
            ssc = C.SSC_ATTUNEMENT,
            tk = C.TK_ATTUNEMENT,
            hyjal = C.HYJAL_ATTUNEMENT,
            bt = C.BT_ATTUNEMENT,
            cipher = C.CIPHER_OF_DAMNATION,
        }
    end
    return attunementMapCache[raidKey]
end

--[[
    Get all attunements in order
    @return table - Array of attunement info
]]
function Attunements:GetAllAttunements()
    return HopeAddon.Constants.ALL_ATTUNEMENTS
end

--[[
    Get player's faction for BT attunement
    @return string - "aldor" or "scryer" or nil if no choice made
]]
function Attunements:GetPlayerFaction()
    -- Check reputation to determine choice (using TBC-compatible helper)
    local aldorStanding = GetFactionStandingById(932)   -- Aldor faction ID
    local scryerStanding = GetFactionStandingById(934)  -- Scryer faction ID

    if aldorStanding and scryerStanding then
        -- One will be hostile (1), one will be neutral or better
        if aldorStanding >= 4 then return "aldor"
        elseif scryerStanding >= 4 then return "scryer"
        end
    end

    -- Check saved choice
    if HopeAddon.charDb.reputation and HopeAddon.charDb.reputation.aldorScryerChoice then
        return HopeAddon.charDb.reputation.aldorScryerChoice.chosen:lower()
    end

    return nil
end

--[[
    Get total chapter count for an attunement (including faction-specific for BT)
    @param raidKey string - Raid identifier
    @return number - Total chapters
]]
function Attunements:GetTotalChapters(raidKey)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then return 0 end

    if raidKey == "bt" then
        -- BT has 4 faction chapters + 11 shared chapters = 15 total
        return 15
    else
        return #attunement.chapters
    end
end

--[[
    Get chapters for BT attunement (faction-aware)
    @return table - Array of chapter data
]]
function Attunements:GetBTChapters()
    local C = HopeAddon.Constants
    local btData = C.BT_ATTUNEMENT
    local faction = self:GetPlayerFaction()
    local chapters = {}

    -- Get faction-specific chapters
    if faction == "aldor" then
        for _, chapter in ipairs(btData.aldorChapters) do
            table.insert(chapters, chapter)
        end
    elseif faction == "scryer" then
        for _, chapter in ipairs(btData.scryerChapters) do
            table.insert(chapters, chapter)
        end
    else
        -- No choice made - show Aldor by default with note
        for _, chapter in ipairs(btData.aldorChapters) do
            local chapterCopy = {}
            for k, v in pairs(chapter) do chapterCopy[k] = v end
            chapterCopy.noFactionChosen = true
            table.insert(chapters, chapterCopy)
        end
    end

    -- Add shared chapters
    for _, chapter in ipairs(btData.chapters) do
        table.insert(chapters, chapter)
    end

    return chapters
end

--[[
    Get chapters for any attunement (handles BT specially)
    @param raidKey string - Raid identifier
    @return table - Array of chapter data
]]
function Attunements:GetChaptersForRaid(raidKey)
    if raidKey == "bt" then
        return self:GetBTChapters()
    end

    local attunement = self:GetAttunementData(raidKey)
    if attunement and attunement.chapters then
        return attunement.chapters
    end

    return {}
end

--[[
    Get player's attunement progress for a raid
    @param raidKey string - Raid identifier
    @return table - Progress data
]]
function Attunements:GetProgress(raidKey)
    local progress = HopeAddon.charDb.attunements[raidKey]
    if not progress then
        progress = {
            started = false,
            completed = false,
            completedDate = nil,
            chapters = {},
        }
        HopeAddon.charDb.attunements[raidKey] = progress
    end
    return progress
end

--[[
    Get attunement state
    @param raidKey string - Raid identifier
    @return number - State constant
]]
function Attunements:GetState(raidKey)
    local progress = self:GetProgress(raidKey)

    if progress.completed then
        return self.STATE.COMPLETED
    elseif progress.started then
        return self.STATE.IN_PROGRESS
    else
        return self.STATE.NOT_STARTED
    end
end

--[[
    Get completion percentage
    @param raidKey string - Raid identifier
    @return number - Percentage (0-100)
]]
function Attunements:GetPercentage(raidKey)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then return 0 end

    local progress = self:GetProgress(raidKey)
    local totalChapters = self:GetTotalChapters(raidKey)
    local completedChapters = 0

    for i = 1, totalChapters do
        if progress.chapters[i] and progress.chapters[i].complete then
            completedChapters = completedChapters + 1
        end
    end

    if totalChapters == 0 then return 0 end
    return math.floor((completedChapters / totalChapters) * 100)
end

--[[
    Mark a chapter as complete
    @param raidKey string - Raid identifier
    @param chapterIndex number - Chapter number
]]
function Attunements:CompleteChapter(raidKey, chapterIndex)
    local progress = self:GetProgress(raidKey)
    local attunement = self:GetAttunementData(raidKey)

    if not attunement then return end

    -- Initialize chapters if needed
    if not progress.chapters then
        progress.chapters = {}
    end

    -- Mark as started
    progress.started = true

    -- Get chapters using the new method
    local chapters = self:GetChaptersForRaid(raidKey)
    local totalChapters = self:GetTotalChapters(raidKey)

    -- Mark chapter complete
    if not progress.chapters[chapterIndex] then
        progress.chapters[chapterIndex] = {
            complete = true,
            date = HopeAddon:GetDate(),
            timestamp = HopeAddon:GetTimestamp(),
        }

        local chapter = chapters[chapterIndex]
        local chapterName = chapter and chapter.name or ("Chapter " .. chapterIndex)
        HopeAddon:Print("Attunement progress: " ..
            HopeAddon:ColorText(chapterName, "ARCANE_PURPLE") .. " complete!")
        HopeAddon.Sounds:PlayMilestone()
    end

    -- Check if fully complete
    local allComplete = true
    for i = 1, totalChapters do
        if not progress.chapters[i] or not progress.chapters[i].complete then
            allComplete = false
            break
        end
    end

    if allComplete and not progress.completed then
        progress.completed = true
        progress.completedDate = HopeAddon:GetDate()

        -- Create journal entry for completion
        local entry = {
            type = "attunement_complete",
            title = attunement.name .. " Complete!",
            description = "You are now attuned to " .. attunement.raidName .. "!",
            icon = "Interface\\Icons\\" .. attunement.icon,
            raidKey = raidKey,
            timestamp = HopeAddon:GetTimestamp(),
        }
        table.insert(HopeAddon.charDb.journal.entries, entry)

        -- Record attunement milestone
        self:RecordAttunementMilestone(raidKey)

        HopeAddon:Print(HopeAddon:ColorText("ATTUNEMENT COMPLETE!", "GOLD_BRIGHT") ..
            " You are now attuned to " .. attunement.raidName .. "!")
        HopeAddon.Sounds:PlayEpicFanfare()

        -- Notify Badges module of attunement completion
        if HopeAddon.Badges then
            HopeAddon.Badges:OnAttunementCompleted(raidKey)
        end
    end
end

--[[
    Record attunement completion milestone
    @param raidKey string - Raid identifier
]]
function Attunements:RecordAttunementMilestone(raidKey)
    local C = HopeAddon.Constants
    local milestoneData = C.ATTUNEMENT_MILESTONES[raidKey]
    if not milestoneData then return end

    -- Check if already recorded
    if HopeAddon.charDb.journal.attunementMilestones and
       HopeAddon.charDb.journal.attunementMilestones[raidKey] then
        return
    end

    -- Initialize storage if needed
    HopeAddon.charDb.journal.attunementMilestones = HopeAddon.charDb.journal.attunementMilestones or {}

    -- Create milestone entry
    local entry = {
        type = "attunement_milestone",
        raidKey = raidKey,
        title = milestoneData.title,
        story = milestoneData.story,
        icon = "Interface\\Icons\\" .. milestoneData.icon,
        timestamp = HopeAddon:GetTimestamp(),
        date = HopeAddon:GetDate(),
    }

    -- Save
    HopeAddon.charDb.journal.attunementMilestones[raidKey] = entry
    table.insert(HopeAddon.charDb.journal.entries, entry)

    HopeAddon:Debug("Recorded attunement milestone:", milestoneData.title)
end

--[[
    Check if a quest ID is part of an attunement
    @param questID number - Quest ID
    @return string|nil, number|nil - Raid key and chapter index, or nil
]]
function Attunements:CheckQuestAttunement(questID)
    -- Use the optimized lookup from Constants
    local lookup = HopeAddon.Constants:GetAttunementForQuest(questID)
    if lookup then
        return lookup.raid, lookup.chapter
    end

    -- Fallback to old lookup for backwards compatibility
    local chapter = HopeAddon.Constants:GetChapterForQuest(questID)
    if chapter then
        return "karazhan", chapter
    end

    return nil, nil
end

--[[
    Handle quest completion - check for attunement progress
    @param questID number - Completed quest ID
]]
function Attunements:OnQuestComplete(questID)
    local raidKey, chapterIndex = self:CheckQuestAttunement(questID)

    if raidKey and chapterIndex then
        self:CompleteChapter(raidKey, chapterIndex)
    end
end

--[[
    Get chapter details
    @param raidKey string - Raid identifier
    @param chapterIndex number - Chapter number
    @return table|nil - Chapter data with completion status
]]
function Attunements:GetChapterDetails(raidKey, chapterIndex)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then return nil end

    -- Get chapters using the appropriate method
    local chapters = self:GetChaptersForRaid(raidKey)
    local chapter = chapters[chapterIndex]
    if not chapter then return nil end

    local progress = self:GetProgress(raidKey)
    local isComplete = progress.chapters[chapterIndex] and progress.chapters[chapterIndex].complete

    return {
        name = chapter.name,
        story = chapter.story,
        quests = chapter.quests,
        complete = isComplete,
        completedDate = isComplete and progress.chapters[chapterIndex].date or nil,
        dungeon = chapter.dungeon,
        dungeons = chapter.dungeons,
        raid = chapter.raid,
        boss = chapter.boss,
        requires = chapter.requires,
        noFactionChosen = chapter.noFactionChosen,
    }
end

--[[
    Get all chapters for an attunement
    @param raidKey string - Raid identifier
    @return table - Array of chapter details
]]
function Attunements:GetAllChapters(raidKey)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then return {} end

    local chapters = {}
    local totalChapters = self:GetTotalChapters(raidKey)
    for i = 1, totalChapters do
        table.insert(chapters, self:GetChapterDetails(raidKey, i))
    end

    return chapters
end

--[[
    Get the next incomplete chapter
    @param raidKey string - Raid identifier
    @return number|nil, table|nil - Chapter index and data, or nil if complete
]]
function Attunements:GetNextChapter(raidKey)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then return nil, nil end

    local progress = self:GetProgress(raidKey)
    local chapters = self:GetChaptersForRaid(raidKey)
    local totalChapters = self:GetTotalChapters(raidKey)

    for i = 1, totalChapters do
        if not progress.chapters[i] or not progress.chapters[i].complete then
            return i, chapters[i]
        end
    end

    return nil, nil -- All complete
end

--[[
    Check if player is attuned
    @param raidKey string - Raid identifier
    @return boolean
]]
function Attunements:IsAttuned(raidKey)
    local progress = self:GetProgress(raidKey)
    return progress.completed == true
end

--[[
    Get attunement summary for display
    @param raidKey string - Raid identifier
    @return table - Summary data
]]
function Attunements:GetSummary(raidKey)
    local attunement = self:GetAttunementData(raidKey)
    if not attunement then
        return {
            name = "Unknown",
            raidName = "Unknown",
            percentage = 0,
            state = self.STATE.NOT_STARTED,
            isAttuned = false,
        }
    end

    local totalChapters = self:GetTotalChapters(raidKey)
    local percentage = self:GetPercentage(raidKey)

    return {
        name = attunement.name,
        raidName = attunement.raidName or attunement.zone, -- zone for Cipher
        icon = attunement.icon,
        percentage = percentage,
        state = self:GetState(raidKey),
        isAttuned = self:IsAttuned(raidKey),
        totalChapters = totalChapters,
        completedChapters = math.floor(percentage / 100 * totalChapters),
        prerequisite = attunement.prerequisite,
        hasFactionStart = attunement.hasFactionStart,
        title = attunement.title,
    }
end

-- Register with addon
HopeAddon:RegisterModule("Attunements", Attunements)
HopeAddon:Debug("Attunements module loaded")
