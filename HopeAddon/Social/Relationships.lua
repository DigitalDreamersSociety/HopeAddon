--[[
    HopeAddon Relationships Module
    Simple notes system for tracking player relationships
]]

local Relationships = {}
HopeAddon.Relationships = Relationships

-- Note character limit
local NOTE_MAX_LENGTH = 256

--============================================================
-- DATA MANAGEMENT
--============================================================

--[[
    Initialize relationships data structure
]]
function Relationships:InitializeData()
    if not HopeAddon.charDb then return end

    if not HopeAddon.charDb.relationships then
        HopeAddon.charDb.relationships = {}
    end
end

--[[
    Get all relationship notes
    @return table - Dictionary of [playerName] = { note, addedDate }
]]
function Relationships:GetAllNotes()
    self:InitializeData()
    return HopeAddon.charDb.relationships or {}
end

--[[
    Get note for a specific player
    @param playerName string - Player name (without realm)
    @return string|nil - Note text or nil if no note
]]
function Relationships:GetNote(playerName)
    if not playerName then return nil end

    self:InitializeData()
    local data = HopeAddon.charDb.relationships[playerName]
    if data then
        return data.note
    end
    return nil
end

--[[
    Get full relationship data for a player
    @param playerName string - Player name
    @return table|nil - { note, addedDate } or nil
]]
function Relationships:GetRelationship(playerName)
    if not playerName then return nil end

    self:InitializeData()
    return HopeAddon.charDb.relationships[playerName]
end

--[[
    Set or update a note for a player
    @param playerName string - Player name
    @param note string - Note text (will be truncated if too long)
    @return boolean - True if successful
]]
function Relationships:SetNote(playerName, note)
    if not playerName then return false end

    self:InitializeData()

    -- Handle empty notes (remove)
    if not note or note == "" then
        return self:RemoveNote(playerName)
    end

    -- Truncate if too long
    if #note > NOTE_MAX_LENGTH then
        note = note:sub(1, NOTE_MAX_LENGTH)
    end

    -- Update or create
    local existing = HopeAddon.charDb.relationships[playerName]
    if existing then
        existing.note = note
        existing.updatedDate = HopeAddon:GetDate()
    else
        HopeAddon.charDb.relationships[playerName] = {
            note = note,
            addedDate = HopeAddon:GetDate(),
        }
    end

    HopeAddon:Debug("Note saved for", playerName)
    return true
end

--[[
    Remove a note for a player
    @param playerName string - Player name
    @return boolean - True if removed, false if didn't exist
]]
function Relationships:RemoveNote(playerName)
    if not playerName then return false end

    self:InitializeData()

    if HopeAddon.charDb.relationships[playerName] then
        HopeAddon.charDb.relationships[playerName] = nil
        HopeAddon:Debug("Note removed for", playerName)
        return true
    end

    return false
end

--[[
    Check if a player has a note
    @param playerName string - Player name
    @return boolean
]]
function Relationships:HasNote(playerName)
    return self:GetNote(playerName) ~= nil
end

--============================================================
-- QUICK ADD FROM CONTEXT
--============================================================

--[[
    Add note from current target
    @param note string - Note text
    @return boolean, string - Success and player name or error message
]]
function Relationships:AddNoteFromTarget(note)
    if not UnitExists("target") then
        return false, "No target selected"
    end

    if not UnitIsPlayer("target") then
        return false, "Target is not a player"
    end

    local name = UnitName("target")
    if not name then
        return false, "Could not get target name"
    end

    local success = self:SetNote(name, note)
    if success then
        return true, name
    else
        return false, "Failed to save note"
    end
end

--[[
    Add note from chat link (player name)
    @param playerName string - Player name from chat
    @param note string - Note text
    @return boolean - Success
]]
function Relationships:AddNoteFromChat(playerName, note)
    -- Remove realm if present
    playerName = strsplit("-", playerName)
    return self:SetNote(playerName, note)
end

--============================================================
-- SEARCH AND FILTERING
--============================================================

--[[
    Search notes for text
    @param searchText string - Text to search for
    @return table - Array of { playerName, note, addedDate }
]]
function Relationships:SearchNotes(searchText)
    local results = {}

    if not searchText or searchText == "" then
        return results
    end

    local searchLower = searchText:lower()
    local notes = self:GetAllNotes()

    for playerName, data in pairs(notes) do
        local nameLower = playerName:lower()
        local noteLower = (data.note or ""):lower()

        if nameLower:find(searchLower, 1, true) or noteLower:find(searchLower, 1, true) then
            table.insert(results, {
                playerName = playerName,
                note = data.note,
                addedDate = data.addedDate,
            })
        end
    end

    -- Sort by player name
    table.sort(results, function(a, b)
        return a.playerName < b.playerName
    end)

    return results
end

--[[
    Get all players with notes
    @return table - Array of player names
]]
function Relationships:GetPlayersWithNotes()
    local players = {}
    local notes = self:GetAllNotes()

    for playerName in pairs(notes) do
        table.insert(players, playerName)
    end

    table.sort(players)
    return players
end

--[[
    Get note count
    @return number
]]
function Relationships:GetNoteCount()
    local count = 0
    local notes = self:GetAllNotes()

    for _ in pairs(notes) do
        count = count + 1
    end

    return count
end

--============================================================
-- IMPORT/EXPORT (Future use)
--============================================================

--[[
    Export all notes as a string
    @return string - Serialized notes
]]
function Relationships:ExportNotes()
    local notes = self:GetAllNotes()
    local lines = {}

    for playerName, data in pairs(notes) do
        -- Simple format: "PlayerName|Note|Date"
        local note = (data.note or ""):gsub("|", "\\|"):gsub("\n", "\\n")
        local line = string.format("%s|%s|%s", playerName, note, data.addedDate or "")
        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end

--[[
    Import notes from a string (merges with existing)
    @param data string - Serialized notes
    @return number - Count of imported notes
]]
function Relationships:ImportNotes(data)
    if not data or data == "" then return 0 end

    local count = 0

    for line in data:gmatch("[^\n]+") do
        local playerName, note, addedDate = strsplit("|", line, 3)
        if playerName and note then
            note = note:gsub("\\|", "|"):gsub("\\n", "\n")
            self:SetNote(playerName, note)
            count = count + 1
        end
    end

    return count
end

--============================================================
-- MODULE LIFECYCLE
--============================================================

function Relationships:OnInitialize()
    self:InitializeData()
end

function Relationships:OnEnable()
    HopeAddon:Debug("Relationships module enabled")
end

function Relationships:OnDisable()
    -- Cleanup if needed
end

-- Register with addon
HopeAddon:RegisterModule("Relationships", Relationships)
HopeAddon:Debug("Relationships module loaded")
