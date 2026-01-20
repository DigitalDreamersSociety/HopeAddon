--[[
    HopeAddon Battleship AI
    Hunt/Target AI algorithm for local practice mode
]]

local BattleshipAI = {}

--============================================================
-- CONSTANTS
--============================================================

-- AI states
BattleshipAI.STATE = {
    HUNT = "HUNT",       -- Random shots looking for ships
    TARGET = "TARGET",   -- Following up on a hit
}

-- Error rate for imperfection (makes AI beatable)
BattleshipAI.ERROR_RATE = 0.20  -- 20% chance to make suboptimal move

--============================================================
-- AI CREATION
--============================================================

--[[
    Create a new AI instance
    @return table - AI state
]]
function BattleshipAI:Create()
    local ai = {
        state = self.STATE.HUNT,
        hitStack = {},          -- Cells to investigate after a hit
        lastHit = nil,          -- Last successful hit
        targetDirection = nil,  -- Direction we're pursuing (after 2+ hits in line)
        shotsFired = {},        -- Track where we've shot (for efficiency)
    }
    return ai
end

--============================================================
-- SHIP PLACEMENT
--============================================================

--[[
    Randomly place all ships on a board
    @param board table - Board data (from BattleshipBoard:Create())
    @return boolean - True if all ships placed successfully
]]
function BattleshipAI:PlaceShips(board)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return false end

    for _, shipDef in ipairs(Board.SHIPS) do
        local placed = false
        local attempts = 0
        local maxAttempts = 100

        while not placed and attempts < maxAttempts do
            attempts = attempts + 1

            local row = math.random(1, Board.GRID_SIZE)
            local col = math.random(1, Board.GRID_SIZE)
            local orientation = math.random() < 0.5 and Board.ORIENTATION.HORIZONTAL or Board.ORIENTATION.VERTICAL

            if Board:PlaceShip(board, shipDef.id, row, col, orientation) then
                placed = true
            end
        end

        if not placed then
            HopeAddon:Debug("AI failed to place ship:", shipDef.name)
            return false
        end
    end

    return true
end

--============================================================
-- SHOT SELECTION
--============================================================

--[[
    Get the next shot for the AI
    @param ai table - AI state
    @param enemyBoard table - Enemy board (we don't see ships, just our shots)
    @return number, number - row, col to shoot
]]
function BattleshipAI:GetNextShot(ai, enemyBoard)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return 1, 1 end

    -- Imperfection: sometimes make a random shot instead of optimal
    if math.random() < self.ERROR_RATE and ai.state == self.STATE.TARGET then
        local shot = self:GetRandomUnfiredCell(ai, enemyBoard)
        if shot then
            return shot.row, shot.col
        end
    end

    -- If we're targeting, try to follow up on hits
    if ai.state == self.STATE.TARGET and #ai.hitStack > 0 then
        local targetCell = table.remove(ai.hitStack)

        -- Make sure we haven't already shot here
        while targetCell and self:HasFired(ai, targetCell.row, targetCell.col) do
            targetCell = table.remove(ai.hitStack)
        end

        if targetCell then
            return targetCell.row, targetCell.col
        end

        -- No more targets, go back to hunting
        ai.state = self.STATE.HUNT
    end

    -- Hunt mode: semi-random shots with checkerboard pattern for efficiency
    return self:GetHuntShot(ai, enemyBoard)
end

--[[
    Get a hunt mode shot (checkerboard pattern for efficiency)
    @param ai table - AI state
    @param enemyBoard table - Enemy board
    @return number, number - row, col
]]
function BattleshipAI:GetHuntShot(ai, enemyBoard)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return 1, 1 end

    -- Try checkerboard pattern first (more efficient hunting)
    local candidates = {}
    for row = 1, Board.GRID_SIZE do
        for col = 1, Board.GRID_SIZE do
            -- Checkerboard: (row + col) is even
            if (row + col) % 2 == 0 and not self:HasFired(ai, row, col) then
                table.insert(candidates, { row = row, col = col })
            end
        end
    end

    -- If checkerboard exhausted, try remaining cells
    if #candidates == 0 then
        for row = 1, Board.GRID_SIZE do
            for col = 1, Board.GRID_SIZE do
                if not self:HasFired(ai, row, col) then
                    table.insert(candidates, { row = row, col = col })
                end
            end
        end
    end

    -- Pick random from candidates
    if #candidates > 0 then
        local choice = candidates[math.random(#candidates)]
        return choice.row, choice.col
    end

    -- Fallback (shouldn't happen)
    return 1, 1
end

--[[
    Get a random unfired cell
    @param ai table - AI state
    @param enemyBoard table - Enemy board
    @return table|nil - { row, col }
]]
function BattleshipAI:GetRandomUnfiredCell(ai, enemyBoard)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return nil end

    local candidates = {}
    for row = 1, Board.GRID_SIZE do
        for col = 1, Board.GRID_SIZE do
            if not self:HasFired(ai, row, col) then
                table.insert(candidates, { row = row, col = col })
            end
        end
    end

    if #candidates > 0 then
        return candidates[math.random(#candidates)]
    end
    return nil
end

--============================================================
-- HIT HANDLING
--============================================================

--[[
    Process the result of a shot
    @param ai table - AI state
    @param row number - Shot row
    @param col number - Shot col
    @param result table - Result from BattleshipBoard:FireShot()
]]
function BattleshipAI:ProcessResult(ai, row, col, result)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return end

    -- Record that we fired here
    self:RecordShot(ai, row, col)

    if not result.hit then
        -- Miss - nothing special
        return
    end

    -- Hit!
    if result.sunk then
        -- Ship sunk - clear targeting state
        ai.hitStack = {}
        ai.lastHit = nil
        ai.targetDirection = nil
        ai.state = self.STATE.HUNT
        return
    end

    -- Hit but not sunk - switch to target mode
    ai.state = self.STATE.TARGET

    -- Add adjacent cells to hit stack
    local adjacent = {
        { row = row - 1, col = col },  -- Up
        { row = row + 1, col = col },  -- Down
        { row = row, col = col - 1 },  -- Left
        { row = row, col = col + 1 },  -- Right
    }

    -- If we have a previous hit, prioritize the direction
    if ai.lastHit then
        local dRow = row - ai.lastHit.row
        local dCol = col - ai.lastHit.col

        -- If we have direction (2+ hits in a line), prioritize that direction
        if dRow ~= 0 or dCol ~= 0 then
            ai.targetDirection = { dRow = dRow > 0 and 1 or (dRow < 0 and -1 or 0),
                                   dCol = dCol > 0 and 1 or (dCol < 0 and -1 or 0) }

            -- Clear stack and add only cells in this direction
            ai.hitStack = {}

            -- Continue in the same direction
            local nextRow = row + ai.targetDirection.dRow
            local nextCol = col + ai.targetDirection.dCol
            if self:IsValidTarget(ai, nextRow, nextCol) then
                table.insert(ai.hitStack, { row = nextRow, col = nextCol })
            end

            -- Also try opposite direction from the first hit
            local oppRow = ai.lastHit.row - ai.targetDirection.dRow
            local oppCol = ai.lastHit.col - ai.targetDirection.dCol
            if self:IsValidTarget(ai, oppRow, oppCol) then
                table.insert(ai.hitStack, { row = oppRow, col = oppCol })
            end
        end
    else
        -- First hit - add all adjacent cells
        for _, adj in ipairs(adjacent) do
            if self:IsValidTarget(ai, adj.row, adj.col) then
                table.insert(ai.hitStack, adj)
            end
        end
    end

    ai.lastHit = { row = row, col = col }
end

--============================================================
-- UTILITY
--============================================================

--[[
    Check if we've already fired at a cell
    @param ai table - AI state
    @param row number
    @param col number
    @return boolean
]]
function BattleshipAI:HasFired(ai, row, col)
    local key = row .. "," .. col
    return ai.shotsFired[key] == true
end

--[[
    Record a shot
    @param ai table - AI state
    @param row number
    @param col number
]]
function BattleshipAI:RecordShot(ai, row, col)
    local key = row .. "," .. col
    ai.shotsFired[key] = true
end

--[[
    Check if a cell is a valid target (in bounds and not shot)
    @param ai table - AI state
    @param row number
    @param col number
    @return boolean
]]
function BattleshipAI:IsValidTarget(ai, row, col)
    local Board = HopeAddon.BattleshipBoard
    if not Board then return false end

    if row < 1 or row > Board.GRID_SIZE or col < 1 or col > Board.GRID_SIZE then
        return false
    end

    return not self:HasFired(ai, row, col)
end

-- Register as a utility (not a module - no lifecycle needed)
HopeAddon.BattleshipAI = BattleshipAI
HopeAddon:Debug("BattleshipAI loaded")
