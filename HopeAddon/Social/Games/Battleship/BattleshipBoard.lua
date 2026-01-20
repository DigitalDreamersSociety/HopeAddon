--[[
    HopeAddon Battleship Board
    10x10 grid data structure with ship placement and hit detection
]]

local BattleshipBoard = {}

--============================================================
-- CONSTANTS
--============================================================

-- Board dimensions
BattleshipBoard.GRID_SIZE = 10

-- Cell states
BattleshipBoard.CELL = {
    EMPTY = 0,
    SHIP = 1,
    HIT = 2,
    MISS = 3,
    SUNK = 4,
}

-- Ship definitions
BattleshipBoard.SHIPS = {
    { id = "carrier", name = "Carrier", size = 5 },
    { id = "battleship", name = "Battleship", size = 4 },
    { id = "cruiser", name = "Cruiser", size = 3 },
    { id = "submarine", name = "Submarine", size = 3 },
    { id = "destroyer", name = "Destroyer", size = 2 },
}

-- Orientation
BattleshipBoard.ORIENTATION = {
    HORIZONTAL = "H",
    VERTICAL = "V",
}

--============================================================
-- BOARD CREATION
--============================================================

--[[
    Create a new empty board
    @return table - Board data structure
]]
function BattleshipBoard:Create()
    local board = {
        grid = {},          -- 10x10 cell states
        ships = {},         -- Placed ships with positions
        hits = {},          -- Coordinates that have been hit
        misses = {},        -- Coordinates that have been missed
    }

    -- Initialize empty grid
    for row = 1, self.GRID_SIZE do
        board.grid[row] = {}
        for col = 1, self.GRID_SIZE do
            board.grid[row][col] = self.CELL.EMPTY
        end
    end

    return board
end

--============================================================
-- SHIP PLACEMENT
--============================================================

--[[
    Check if a ship can be placed at the given position
    @param board table - Board data
    @param shipId string - Ship identifier
    @param row number - Starting row (1-10)
    @param col number - Starting column (1-10)
    @param orientation string - "H" or "V"
    @return boolean, string|nil - True if valid, or false with error reason
]]
function BattleshipBoard:CanPlaceShip(board, shipId, row, col, orientation)
    local ship = self:GetShipById(shipId)
    if not ship then return false, "INVALID_SHIP" end

    local size = ship.size
    local dRow = orientation == self.ORIENTATION.VERTICAL and 1 or 0
    local dCol = orientation == self.ORIENTATION.HORIZONTAL and 1 or 0

    -- Check bounds and overlaps
    for i = 0, size - 1 do
        local checkRow = row + (i * dRow)
        local checkCol = col + (i * dCol)

        -- Out of bounds?
        if checkRow < 1 or checkRow > self.GRID_SIZE or
           checkCol < 1 or checkCol > self.GRID_SIZE then
            return false, "OUT_OF_BOUNDS"
        end

        -- Cell already occupied?
        if board.grid[checkRow][checkCol] ~= self.CELL.EMPTY then
            return false, "OVERLAP"
        end
    end

    return true, nil
end

--[[
    Place a ship on the board
    @param board table - Board data
    @param shipId string - Ship identifier
    @param row number - Starting row (1-10)
    @param col number - Starting column (1-10)
    @param orientation string - "H" or "V"
    @return boolean - True if placed successfully
]]
function BattleshipBoard:PlaceShip(board, shipId, row, col, orientation)
    if not self:CanPlaceShip(board, shipId, row, col, orientation) then
        return false
    end

    local ship = self:GetShipById(shipId)
    local size = ship.size
    local dRow = orientation == self.ORIENTATION.VERTICAL and 1 or 0
    local dCol = orientation == self.ORIENTATION.HORIZONTAL and 1 or 0

    -- Record ship placement
    local cells = {}
    for i = 0, size - 1 do
        local cellRow = row + (i * dRow)
        local cellCol = col + (i * dCol)
        board.grid[cellRow][cellCol] = self.CELL.SHIP
        table.insert(cells, { row = cellRow, col = cellCol })
    end

    board.ships[shipId] = {
        id = shipId,
        name = ship.name,
        size = size,
        row = row,
        col = col,
        orientation = orientation,
        cells = cells,
        hits = 0,
        sunk = false,
    }

    return true
end

--[[
    Get ship definition by ID
    @param shipId string
    @return table|nil
]]
function BattleshipBoard:GetShipById(shipId)
    for _, ship in ipairs(self.SHIPS) do
        if ship.id == shipId then
            return ship
        end
    end
    return nil
end

--[[
    Check if all ships have been placed
    @param board table - Board data
    @return boolean
]]
function BattleshipBoard:AllShipsPlaced(board)
    for _, shipDef in ipairs(self.SHIPS) do
        if not board.ships[shipDef.id] then
            return false
        end
    end
    return true
end

--[[
    Get the next ship that needs to be placed
    @param board table - Board data
    @return table|nil - Ship definition or nil if all placed
]]
function BattleshipBoard:GetNextShipToPlace(board)
    for _, shipDef in ipairs(self.SHIPS) do
        if not board.ships[shipDef.id] then
            return shipDef
        end
    end
    return nil
end

--[[
    Get placement progress (ships placed / total ships)
    @param board table - Board data
    @return number, number - placed count, total count
]]
function BattleshipBoard:GetPlacementProgress(board)
    local placed = 0
    for _, shipDef in ipairs(self.SHIPS) do
        if board.ships[shipDef.id] then
            placed = placed + 1
        end
    end
    return placed, #self.SHIPS
end

--[[
    Get step number for current ship (1-5)
    @param board table - Board data
    @return number - Step number (1-5) or 6 if all placed
]]
function BattleshipBoard:GetCurrentStep(board)
    local placed, total = self:GetPlacementProgress(board)
    return placed + 1
end

--============================================================
-- SHOT HANDLING
--============================================================

--[[
    Fire a shot at the given coordinates
    @param board table - Board data
    @param row number - Target row (1-10)
    @param col number - Target column (1-10)
    @return table - Result { hit = bool, shipId = string|nil, sunk = bool, shipName = string|nil }
]]
function BattleshipBoard:FireShot(board, row, col)
    -- Validate coordinates
    if row < 1 or row > self.GRID_SIZE or col < 1 or col > self.GRID_SIZE then
        return { hit = false, error = "Invalid coordinates" }
    end

    local cell = board.grid[row][col]

    -- Already shot here?
    if cell == self.CELL.HIT or cell == self.CELL.MISS or cell == self.CELL.SUNK then
        return { hit = false, error = "Already shot here" }
    end

    -- Miss
    if cell == self.CELL.EMPTY then
        board.grid[row][col] = self.CELL.MISS
        table.insert(board.misses, { row = row, col = col })
        return { hit = false }
    end

    -- Hit!
    board.grid[row][col] = self.CELL.HIT
    table.insert(board.hits, { row = row, col = col })

    -- Find which ship was hit
    local hitShip = nil
    for shipId, ship in pairs(board.ships) do
        for _, shipCell in ipairs(ship.cells) do
            if shipCell.row == row and shipCell.col == col then
                ship.hits = ship.hits + 1
                hitShip = ship
                break
            end
        end
        if hitShip then break end
    end

    if not hitShip then
        return { hit = true }
    end

    -- Check if ship is sunk
    if hitShip.hits >= hitShip.size then
        hitShip.sunk = true
        -- Mark all cells as sunk
        for _, shipCell in ipairs(hitShip.cells) do
            board.grid[shipCell.row][shipCell.col] = self.CELL.SUNK
        end
        return { hit = true, shipId = hitShip.id, shipName = hitShip.name, sunk = true }
    end

    return { hit = true, shipId = hitShip.id, shipName = hitShip.name, sunk = false }
end

--[[
    Check if a cell has been shot at
    @param board table - Board data
    @param row number
    @param col number
    @return boolean
]]
function BattleshipBoard:IsShot(board, row, col)
    local cell = board.grid[row][col]
    return cell == self.CELL.HIT or cell == self.CELL.MISS or cell == self.CELL.SUNK
end

--============================================================
-- GAME STATE
--============================================================

--[[
    Check if all ships have been sunk
    @param board table - Board data
    @return boolean
]]
function BattleshipBoard:AllShipsSunk(board)
    for _, ship in pairs(board.ships) do
        if not ship.sunk then
            return false
        end
    end
    -- Make sure at least one ship exists
    local hasShips = false
    for _ in pairs(board.ships) do
        hasShips = true
        break
    end
    return hasShips
end

--[[
    Get number of ships remaining (not sunk)
    @param board table - Board data
    @return number
]]
function BattleshipBoard:GetShipsRemaining(board)
    local count = 0
    for _, ship in pairs(board.ships) do
        if not ship.sunk then
            count = count + 1
        end
    end
    return count
end

--[[
    Get a ship's status
    @param board table - Board data
    @param shipId string
    @return table|nil - { name, size, hits, sunk }
]]
function BattleshipBoard:GetShipStatus(board, shipId)
    local ship = board.ships[shipId]
    if not ship then return nil end
    return {
        name = ship.name,
        size = ship.size,
        hits = ship.hits,
        sunk = ship.sunk,
    }
end

--[[
    Get all ships with their status
    @param board table - Board data
    @return table - Array of ship statuses
]]
function BattleshipBoard:GetAllShipStatus(board)
    local statuses = {}
    for _, shipDef in ipairs(self.SHIPS) do
        local ship = board.ships[shipDef.id]
        if ship then
            table.insert(statuses, {
                id = shipDef.id,
                name = ship.name,
                size = ship.size,
                hits = ship.hits,
                sunk = ship.sunk,
            })
        end
    end
    return statuses
end

--============================================================
-- UTILITY
--============================================================

--[[
    Convert column number to letter (1 = A, 10 = J)
    @param col number
    @return string
]]
function BattleshipBoard:ColToLetter(col)
    return string.char(64 + col)  -- A=65, so col 1 -> A
end

--[[
    Convert letter to column number (A = 1, J = 10)
    @param letter string
    @return number
]]
function BattleshipBoard:LetterToCol(letter)
    return string.byte(string.upper(letter)) - 64
end

--[[
    Format coordinates for display (e.g., "B5")
    @param row number
    @param col number
    @return string
]]
function BattleshipBoard:FormatCoord(row, col)
    return self:ColToLetter(col) .. tostring(row)
end

--[[
    Parse coordinate string (e.g., "B5" -> row=5, col=2)
    @param coord string
    @return number, number - row, col
]]
function BattleshipBoard:ParseCoord(coord)
    local letter = coord:sub(1, 1)
    local num = tonumber(coord:sub(2))
    return num, self:LetterToCol(letter)
end

-- Register as a utility (not a module - no lifecycle needed)
HopeAddon.BattleshipBoard = BattleshipBoard
HopeAddon:Debug("BattleshipBoard loaded")
