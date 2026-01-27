--[[
    HopeAddon Treasures Module
    Soft Reserve (SR) system for guild loot management
    Phase 1 = SR 1 (one soft reserve per raid per lockout)
]]

local Treasures = {}

-- Module references (populated on enable)
local C = nil
local Timer = nil
local FellowTravelers = nil
local ActivityFeed = nil
local SocialToasts = nil

-- Protocol version for network sync
local PROTOCOL_VERSION = 1

-- Listener system for UI updates
local listeners = {}

--============================================================
-- INITIALIZATION
--============================================================

function Treasures:OnInitialize()
    C = HopeAddon.Constants
    HopeAddon:Debug("Treasures: Initialized")
end

function Treasures:OnEnable()
    Timer = HopeAddon.Timer
    FellowTravelers = HopeAddon.FellowTravelers
    ActivityFeed = HopeAddon.ActivityFeed
    SocialToasts = HopeAddon.SocialToasts

    -- Ensure data structure exists
    self:EnsureDataStructure()

    -- Register network message handlers
    self:RegisterNetworkHandlers()

    -- Clean up expired reserves
    self:CleanupExpiredReserves()

    HopeAddon:Debug("Treasures: Enabled")
end

function Treasures:OnDisable()
    -- Unregister network message callbacks
    if FellowTravelers then
        FellowTravelers:UnregisterMessageCallback("sr_list")
        FellowTravelers:UnregisterMessageCallback("sr_update")
        FellowTravelers:UnregisterMessageCallback("sr_query")
    end

    -- Clear listener callbacks to prevent accumulation
    wipe(listeners)

    HopeAddon:Debug("Treasures: Disabled")
end

--============================================================
-- DATA ACCESS
--============================================================

--[[
    Ensure treasures data structure exists
    @return table - The treasures data table
]]
function Treasures:EnsureDataStructure()
    local social = HopeAddon:EnsureSocialData()
    if not social then return nil end

    if not social.treasures then
        social.treasures = {
            reserves = {},           -- [raidKey] = { itemName, itemIcon, bossId, bossName, timestamp, lockoutExpires }
            history = {},            -- Array of { itemName, raidKey, won, timestamp }
            guildReserves = {},      -- [playerName][raidKey] = { itemName, timestamp }
            settings = {
                showInTooltips = true,
                announceOnDrop = true,
            },
        }
    end

    return social.treasures
end

--[[
    Get treasures data
    @return table - Treasures data or nil
]]
function Treasures:GetTreasuresData()
    local social = HopeAddon.charDb and HopeAddon.charDb.social
    return social and social.treasures
end

--[[
    Get treasures settings
    @return table
]]
function Treasures:GetSettings()
    local treasures = self:GetTreasuresData()
    return treasures and treasures.settings or {}
end

--============================================================
-- LOCKOUT TIMING
--============================================================

--[[
    Get the Unix timestamp of the last weekly reset (Tuesday 11:00 AM)
    @return number - Unix timestamp of last reset
]]
function Treasures:GetLastResetTime()
    local now = time()
    local nowDate = date("*t", now)

    -- Calculate days since last Tuesday
    -- WoW uses: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
    local resetDay = C.SOFT_RESERVE.RESET_DAY  -- 3 = Tuesday
    local resetHour = C.SOFT_RESERVE.RESET_HOUR  -- 11 AM

    local daysSinceReset = (nowDate.wday - resetDay + 7) % 7

    -- Calculate timestamp for this week's reset day
    local resetDate = {
        year = nowDate.year,
        month = nowDate.month,
        day = nowDate.day - daysSinceReset,
        hour = resetHour,
        min = 0,
        sec = 0,
    }

    local resetTimestamp = time(resetDate)

    -- If we haven't reached reset time yet on reset day, go back a week
    if now < resetTimestamp then
        resetTimestamp = resetTimestamp - (7 * 86400)
    end

    return resetTimestamp
end

--[[
    Get the Unix timestamp of the next weekly reset
    @return number - Unix timestamp of next reset
]]
function Treasures:GetNextResetTime()
    return self:GetLastResetTime() + (7 * 86400)
end

--[[
    Check if a reserve is expired (past the weekly reset)
    @param reserve table - Reserve data with timestamp field
    @return boolean - True if expired
]]
function Treasures:IsLockoutExpired(reserve)
    if not reserve or not reserve.timestamp then return true end
    local lastReset = self:GetLastResetTime()
    return reserve.timestamp < lastReset
end

--[[
    Get time until next reset in human readable format
    @return string
]]
function Treasures:GetTimeUntilReset()
    local nextReset = self:GetNextResetTime()
    local seconds = nextReset - time()

    if seconds <= 0 then
        return "Resetting now"
    elseif seconds < 3600 then
        return math.floor(seconds / 60) .. " min"
    elseif seconds < 86400 then
        local hours = math.floor(seconds / 3600)
        return hours .. " hour" .. (hours > 1 and "s" or "")
    else
        local days = math.floor(seconds / 86400)
        local hours = math.floor((seconds % 86400) / 3600)
        return days .. "d " .. hours .. "h"
    end
end

--============================================================
-- PHASE MANAGEMENT
--============================================================

--[[
    Check if a raid is available in current content phase
    For Phase 1, only Karazhan, Gruul, Magtheridon are available
    @param raidKey string
    @return boolean
]]
function Treasures:IsRaidInCurrentPhase(raidKey)
    -- For now, assume Phase 1 content is available
    local phase = C.RAID_TO_PHASE[raidKey]
    -- Allow Phase 1 raids by default
    return phase == 1
end

--[[
    Get list of available raids for current phase
    @return table - Array of raid keys
]]
function Treasures:GetAvailableRaids()
    -- Phase 1 raids
    return C.SOFT_RESERVE.PHASES[1] or {}
end

--============================================================
-- CORE API
--============================================================

--[[
    Set a soft reserve for a raid
    @param raidKey string - Raid identifier (karazhan, gruul, magtheridon)
    @param itemName string - Name of the item to reserve
    @param itemIcon string - Icon path for the item (optional)
    @param bossId string - Boss ID the item drops from (optional)
    @param bossName string - Boss name (optional)
    @return boolean success, string|nil error
]]
function Treasures:SetReserve(raidKey, itemName, itemIcon, bossId, bossName)
    local treasures = self:EnsureDataStructure()
    if not treasures then
        return false, "Treasures data not available"
    end

    -- Validate raid is in current phase
    if not self:IsRaidInCurrentPhase(raidKey) then
        return false, "This raid is not available in current content phase"
    end

    -- Check if there's an existing unexpired reserve
    local currentReserve = treasures.reserves[raidKey]
    if currentReserve and not self:IsLockoutExpired(currentReserve) then
        return false, "You already have a reserve for " .. self:GetRaidDisplayName(raidKey) .. ": " .. currentReserve.itemName
    end

    -- Set the reserve
    treasures.reserves[raidKey] = {
        itemName = itemName,
        itemIcon = itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark",
        bossId = bossId,
        bossName = bossName,
        timestamp = time(),
        lockoutExpires = self:GetNextResetTime(),
    }

    -- Notify listeners
    self:NotifyListeners("SET", raidKey)

    -- Broadcast to guild/raid
    self:BroadcastSRUpdate(raidKey)

    -- Post to activity feed
    if ActivityFeed then
        ActivityFeed:OnSoftReserve(raidKey, itemName)
    end

    HopeAddon:Debug("Treasures: Set reserve for", raidKey, ":", itemName)
    return true
end

--[[
    Clear a soft reserve for a raid
    @param raidKey string
    @return boolean success
]]
function Treasures:ClearReserve(raidKey)
    local treasures = self:GetTreasuresData()
    if not treasures then return false end

    if not treasures.reserves[raidKey] then
        return false
    end

    treasures.reserves[raidKey] = nil

    -- Notify listeners
    self:NotifyListeners("CLEAR", raidKey)

    -- Broadcast to guild/raid
    self:BroadcastSRUpdate(raidKey)

    HopeAddon:Debug("Treasures: Cleared reserve for", raidKey)
    return true
end

--[[
    Get player's reserve for a specific raid
    @param raidKey string
    @return table|nil - Reserve data
]]
function Treasures:GetReserve(raidKey)
    local treasures = self:GetTreasuresData()
    if not treasures then return nil end

    local reserve = treasures.reserves[raidKey]

    -- Check if expired
    if reserve and self:IsLockoutExpired(reserve) then
        treasures.reserves[raidKey] = nil
        return nil
    end

    return reserve
end

--[[
    Get all active reserves for the player
    @return table - Map of raidKey to reserve data
]]
function Treasures:GetAllReserves()
    local treasures = self:GetTreasuresData()
    if not treasures then return {} end

    local active = {}
    for raidKey, reserve in pairs(treasures.reserves) do
        if not self:IsLockoutExpired(reserve) then
            active[raidKey] = reserve
        end
    end

    return active
end

--[[
    Check if player has a reserve for a raid
    @param raidKey string
    @return boolean
]]
function Treasures:HasReserve(raidKey)
    return self:GetReserve(raidKey) ~= nil
end

--============================================================
-- GUILD SR TRACKING
--============================================================

--[[
    Get guild reserves for a specific raid
    @param raidKey string
    @return table - Array of { player, reserve }
]]
function Treasures:GetGuildReserves(raidKey)
    local treasures = self:GetTreasuresData()
    if not treasures then return {} end

    local reserves = {}
    local lastReset = self:GetLastResetTime()

    for playerName, playerReserves in pairs(treasures.guildReserves or {}) do
        local reserve = playerReserves[raidKey]
        if reserve and reserve.timestamp and reserve.timestamp >= lastReset then
            table.insert(reserves, {
                player = playerName,
                reserve = reserve,
            })
        end
    end

    -- Sort by player name
    table.sort(reserves, function(a, b)
        return a.player < b.player
    end)

    return reserves
end

--[[
    Get all guild reserves grouped by item name for a raid
    @param raidKey string
    @return table - Map of itemName to array of player names
]]
function Treasures:GetGuildReservesByItem(raidKey)
    local guildReserves = self:GetGuildReserves(raidKey)
    local byItem = {}

    -- Include self
    local myReserve = self:GetReserve(raidKey)
    if myReserve then
        byItem[myReserve.itemName] = byItem[myReserve.itemName] or {}
        table.insert(byItem[myReserve.itemName], UnitName("player"))
    end

    -- Add guild members
    for _, entry in ipairs(guildReserves) do
        local itemName = entry.reserve.itemName
        byItem[itemName] = byItem[itemName] or {}
        table.insert(byItem[itemName], entry.player)
    end

    return byItem
end

--[[
    Get list of players who reserved a specific item
    @param raidKey string
    @param itemName string
    @return table - Array of player names
]]
function Treasures:GetContenders(raidKey, itemName)
    local byItem = self:GetGuildReservesByItem(raidKey)
    return byItem[itemName] or {}
end

--[[
    Check if an item has multiple reserves (contested)
    @param raidKey string
    @param itemName string
    @return boolean, number - isContested, numberOfContenders
]]
function Treasures:IsItemContested(raidKey, itemName)
    local contenders = self:GetContenders(raidKey, itemName)
    return #contenders > 1, #contenders
end

--============================================================
-- LOOT HELPER
--============================================================

--[[
    Get display name for a raid
    @param raidKey string
    @return string
]]
function Treasures:GetRaidDisplayName(raidKey)
    local raidNames = {
        karazhan = "Karazhan",
        gruul = "Gruul's Lair",
        magtheridon = "Magtheridon's Lair",
        ssc = "Serpentshrine Cavern",
        tk = "Tempest Keep",
        hyjal = "Hyjal Summit",
        bt = "Black Temple",
        za = "Zul'Aman",
        sunwell = "Sunwell Plateau",
    }
    return raidNames[raidKey] or raidKey
end

--[[
    Get loot table for a raid from Constants
    @param raidKey string
    @return table - Array of { bossName, bossId, items = { {name, type} } }
]]
function Treasures:GetRaidLootTable(raidKey)
    local lootTable = {}

    -- Get boss data from Constants
    local bossKey = string.upper(raidKey) .. "_BOSSES"
    local bosses = C[bossKey]

    if not bosses then return lootTable end

    for _, boss in ipairs(bosses) do
        if boss.notableLoot and #boss.notableLoot > 0 then
            table.insert(lootTable, {
                bossId = boss.id,
                bossName = boss.name,
                items = boss.notableLoot,
            })
        end
    end

    return lootTable
end

--[[
    Get all reservable items for a raid (flattened list)
    @param raidKey string
    @return table - Array of { itemName, bossName, bossId, type }
]]
function Treasures:GetReservableItems(raidKey)
    local items = {}
    local lootTable = self:GetRaidLootTable(raidKey)

    for _, boss in ipairs(lootTable) do
        for _, item in ipairs(boss.items) do
            table.insert(items, {
                itemName = item.name,
                itemType = item.type,
                bossName = boss.bossName,
                bossId = boss.bossId,
            })
        end
    end

    -- Sort by item name
    table.sort(items, function(a, b)
        return a.itemName < b.itemName
    end)

    return items
end

--============================================================
-- CLEANUP
--============================================================

--[[
    Clean up expired reserves
]]
function Treasures:CleanupExpiredReserves()
    local treasures = self:GetTreasuresData()
    if not treasures then return end

    local lastReset = self:GetLastResetTime()

    -- Clean own reserves
    for raidKey, reserve in pairs(treasures.reserves) do
        if self:IsLockoutExpired(reserve) then
            treasures.reserves[raidKey] = nil
            HopeAddon:Debug("Treasures: Cleaned expired reserve for", raidKey)
        end
    end

    -- Clean guild reserves
    for playerName, playerReserves in pairs(treasures.guildReserves or {}) do
        for raidKey, reserve in pairs(playerReserves) do
            if reserve.timestamp and reserve.timestamp < lastReset then
                playerReserves[raidKey] = nil
            end
        end
        -- Remove empty player entries
        local hasReserves = false
        for _ in pairs(playerReserves) do
            hasReserves = true
            break
        end
        if not hasReserves then
            treasures.guildReserves[playerName] = nil
        end
    end
end

--============================================================
-- NETWORK PROTOCOL
--============================================================

--[[
    Register network message handlers with FellowTravelers
]]
function Treasures:RegisterNetworkHandlers()
    if not FellowTravelers then
        HopeAddon:Debug("Treasures: FellowTravelers not available for network registration")
        return
    end

    -- SR list broadcast
    FellowTravelers:RegisterMessageCallback("sr_list", function(msgType)
        return msgType == C.SR_MESSAGE_TYPES.SR_LIST
    end, function(msgType, sender, data)
        self:HandleSRList(sender, data)
    end)

    -- SR update (single item)
    FellowTravelers:RegisterMessageCallback("sr_update", function(msgType)
        return msgType == C.SR_MESSAGE_TYPES.SR_UPDATE
    end, function(msgType, sender, data)
        self:HandleSRUpdate(sender, data)
    end)

    -- SR query (request for data)
    FellowTravelers:RegisterMessageCallback("sr_query", function(msgType)
        return msgType == C.SR_MESSAGE_TYPES.SR_QUERY
    end, function(msgType, sender, data)
        self:HandleSRQuery(sender, data)
    end)

    HopeAddon:Debug("Treasures: Network handlers registered")
end

--[[
    Broadcast a single SR update
    @param raidKey string
]]
function Treasures:BroadcastSRUpdate(raidKey)
    if not FellowTravelers then return end

    local reserve = self:GetReserve(raidKey)
    local itemName = reserve and reserve.itemName or "NONE"

    -- Format: raidKey|itemName
    local data = raidKey .. "|" .. itemName

    -- Broadcast message
    local msg = string.format("%s:%d:%s", C.SR_MESSAGE_TYPES.SR_UPDATE, PROTOCOL_VERSION, data)
    FellowTravelers:BroadcastMessage(msg)

    HopeAddon:Debug("Treasures: Broadcast SR update for", raidKey)
end

--[[
    Broadcast full SR list
]]
function Treasures:BroadcastFullSRList()
    if not FellowTravelers then return end

    local reserves = self:GetAllReserves()
    local parts = {}

    for raidKey, reserve in pairs(reserves) do
        table.insert(parts, raidKey .. ":" .. reserve.itemName)
    end

    if #parts == 0 then
        parts = { "EMPTY" }
    end

    local data = table.concat(parts, ",")
    local msg = string.format("%s:%d:%s", C.SR_MESSAGE_TYPES.SR_LIST, PROTOCOL_VERSION, data)
    FellowTravelers:BroadcastMessage(msg)

    HopeAddon:Debug("Treasures: Broadcast full SR list")
end

--[[
    Handle incoming SR list from another player
    @param sender string
    @param data string
]]
function Treasures:HandleSRList(sender, data)
    if sender == UnitName("player") then return end

    local treasures = self:EnsureDataStructure()
    if not treasures then return end

    treasures.guildReserves = treasures.guildReserves or {}
    treasures.guildReserves[sender] = {}

    if data == "EMPTY" then
        return
    end

    for pair in data:gmatch("[^,]+") do
        local raidKey, itemName = pair:match("([^:]+):(.+)")
        if raidKey and itemName then
            treasures.guildReserves[sender][raidKey] = {
                itemName = itemName,
                timestamp = time(),
            }
        end
    end

    -- Notify listeners
    self:NotifyListeners("GUILD_UPDATE", sender)

    HopeAddon:Debug("Treasures: Received SR list from", sender)
end

--[[
    Handle incoming SR update from another player
    @param sender string
    @param data string
]]
function Treasures:HandleSRUpdate(sender, data)
    if sender == UnitName("player") then return end

    local raidKey, itemName = data:match("([^|]+)|(.+)")
    if not raidKey then return end

    local treasures = self:EnsureDataStructure()
    if not treasures then return end

    treasures.guildReserves = treasures.guildReserves or {}
    treasures.guildReserves[sender] = treasures.guildReserves[sender] or {}

    if itemName == "NONE" then
        treasures.guildReserves[sender][raidKey] = nil
    else
        treasures.guildReserves[sender][raidKey] = {
            itemName = itemName,
            timestamp = time(),
        }

        -- Show toast if enabled
        if SocialToasts then
            SocialToasts:Show("soft_reserve", sender, "reserved " .. itemName)
        end
    end

    -- Notify listeners
    self:NotifyListeners("GUILD_UPDATE", sender)

    HopeAddon:Debug("Treasures: Received SR update from", sender, "for", raidKey)
end

--[[
    Handle SR query (request for data)
    @param sender string
    @param data string
]]
function Treasures:HandleSRQuery(sender, data)
    if sender == UnitName("player") then return end

    -- Respond with our full SR list
    self:BroadcastFullSRList()
end

--[[
    Request SR data from guild/raid
]]
function Treasures:RequestGuildSRData()
    if not FellowTravelers then return end

    local msg = string.format("%s:%d:REQUEST", C.SR_MESSAGE_TYPES.SR_QUERY, PROTOCOL_VERSION)
    FellowTravelers:BroadcastMessage(msg)

    HopeAddon:Debug("Treasures: Requested guild SR data")
end

--============================================================
-- LISTENER SYSTEM
--============================================================

--[[
    Register a listener for SR updates
    @param id string - Unique identifier
    @param callback function - Called with (action, data)
]]
function Treasures:RegisterListener(id, callback)
    if type(callback) == "function" then
        listeners[id] = callback
    end
end

--[[
    Unregister a listener
    @param id string
]]
function Treasures:UnregisterListener(id)
    listeners[id] = nil
end

--[[
    Notify all listeners of an update
    @param action string - "SET", "CLEAR", "GUILD_UPDATE"
    @param data any - Additional data
]]
function Treasures:NotifyListeners(action, data)
    for _, callback in pairs(listeners) do
        local ok, err = pcall(callback, action, data)
        if not ok then
            HopeAddon:Debug("Treasures: Listener error:", err)
        end
    end
end

--============================================================
-- SLASH COMMANDS
--============================================================

--[[
    Handle /hope sr commands
    @param args string - Command arguments
]]
function Treasures:HandleSlashCommand(args)
    local parts = {}
    for part in args:gmatch("%S+") do
        table.insert(parts, part)
    end

    local subCmd = parts[1] and parts[1]:lower() or "help"

    if subCmd == "list" then
        -- Show all reserves
        local reserves = self:GetAllReserves()
        local hasAny = false

        HopeAddon:Print("|cFFFFD700Your Soft Reserves:|r")
        for raidKey, reserve in pairs(reserves) do
            hasAny = true
            HopeAddon:Print("  " .. self:GetRaidDisplayName(raidKey) .. ": |cFF00FF00" .. reserve.itemName .. "|r")
        end

        if not hasAny then
            HopeAddon:Print("  (none)")
        end

        HopeAddon:Print("Reset in: " .. self:GetTimeUntilReset())

    elseif subCmd == "clear" then
        local raidKey = parts[2] and parts[2]:lower()
        if raidKey then
            if self:ClearReserve(raidKey) then
                HopeAddon:Print("Cleared reserve for " .. self:GetRaidDisplayName(raidKey))
            else
                HopeAddon:Print("No reserve to clear for " .. self:GetRaidDisplayName(raidKey))
            end
        else
            HopeAddon:Print("Usage: /hope sr clear <raid>")
        end

    elseif subCmd == "guild" then
        local raidKey = parts[2] and parts[2]:lower() or "karazhan"
        local guildReserves = self:GetGuildReserves(raidKey)

        HopeAddon:Print("|cFFFFD700Guild Reserves for " .. self:GetRaidDisplayName(raidKey) .. ":|r")
        if #guildReserves == 0 then
            HopeAddon:Print("  (none)")
        else
            for _, entry in ipairs(guildReserves) do
                HopeAddon:Print("  " .. entry.player .. ": |cFF00FF00" .. entry.reserve.itemName .. "|r")
            end
        end

    elseif subCmd == "sync" then
        self:RequestGuildSRData()
        HopeAddon:Print("Requesting SR data from guild...")

    else
        -- Set reserve: /hope sr <raid> <item>
        local raidKey = subCmd
        local itemName = table.concat(parts, " ", 2)

        if raidKey and itemName and itemName ~= "" then
            local success, err = self:SetReserve(raidKey, itemName)
            if success then
                HopeAddon:Print("|cFF00FF00Reserved:|r " .. itemName .. " for " .. self:GetRaidDisplayName(raidKey))
            else
                HopeAddon:Print("|cFFFF0000Error:|r " .. (err or "Unknown error"))
            end
        else
            HopeAddon:Print("|cFFFFD700Soft Reserve Commands:|r")
            HopeAddon:Print("  /hope sr <raid> <item> - Set reserve")
            HopeAddon:Print("  /hope sr list - Show your reserves")
            HopeAddon:Print("  /hope sr clear <raid> - Clear reserve")
            HopeAddon:Print("  /hope sr guild [raid] - Show guild reserves")
            HopeAddon:Print("  /hope sr sync - Request guild data")
            HopeAddon:Print("")
            HopeAddon:Print("Available raids: karazhan, gruul, magtheridon")
        end
    end
end

--============================================================
-- PUBLIC API
--============================================================

-- Make module accessible and register
HopeAddon.Treasures = Treasures
HopeAddon:RegisterModule("Treasures", Treasures)

return Treasures
