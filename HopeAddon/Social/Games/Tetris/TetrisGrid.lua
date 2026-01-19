--[[
    HopeAddon Tetris Grid
    10x20 grid data structure for Tetris

    Grid coordinates:
    - Row 1 is at the top (where pieces spawn)
    - Row 20 is at the bottom
    - Col 1 is left, Col 10 is right
]]

local TetrisGrid = {}
TetrisGrid.__index = TetrisGrid

--============================================================
-- CONSTANTS
--============================================================

TetrisGrid.WIDTH = 10
TetrisGrid.HEIGHT = 20
TetrisGrid.HIDDEN_ROWS = 2  -- Extra rows above visible area for spawning
TetrisGrid.FALLBACK_COLOR = { r = 0.5, g = 0.5, b = 0.5 }  -- Fallback color if TetrisBlocks not loaded

--============================================================
-- CONSTRUCTOR
--============================================================

--[[
    Create a new Tetris grid
    @return TetrisGrid
]]
function TetrisGrid:New()
    local grid = setmetatable({}, TetrisGrid)

    -- Grid data: [row][col] = nil (empty) or color table
    grid.cells = {}
    grid.width = self.WIDTH
    grid.height = self.HEIGHT
    grid.totalHeight = self.HEIGHT + self.HIDDEN_ROWS

    -- Dirty tracking: [row][col] = true for cells that need redrawing
    grid.dirtyCells = {}

    -- Initialize empty grid (including hidden rows at top)
    for row = 1 - self.HIDDEN_ROWS, self.HEIGHT do
        grid.cells[row] = {}
        for col = 1, self.WIDTH do
            grid.cells[row][col] = nil
        end
    end

    return grid
end

--============================================================
-- GRID OPERATIONS
--============================================================

--[[
    Get cell value
    @param row number
    @param col number
    @return table|nil - Color table or nil if empty
]]
function TetrisGrid:GetCell(row, col)
    if not self.cells[row] then return nil end
    return self.cells[row][col]
end

--[[
    Set cell value
    @param row number
    @param col number
    @param color table|nil - Color table or nil to clear
]]
function TetrisGrid:SetCell(row, col, color)
    if not self.cells[row] then
        self.cells[row] = {}
    end
    self.cells[row][col] = color
end

--[[
    Mark a cell as dirty (needs redrawing)
    @param row number
    @param col number
]]
function TetrisGrid:MarkDirty(row, col)
    if not self.dirtyCells[row] then
        self.dirtyCells[row] = {}
    end
    self.dirtyCells[row][col] = true
end

--[[
    Check if a cell is empty
    @param row number
    @param col number
    @return boolean
]]
function TetrisGrid:IsEmpty(row, col)
    return self:GetCell(row, col) == nil
end

--[[
    Check if a cell is within bounds
    @param row number
    @param col number
    @return boolean
]]
function TetrisGrid:IsInBounds(row, col)
    return col >= 1 and col <= self.width and
           row <= self.height
    -- Note: row can be negative for pieces spawning above visible area
end

--[[
    Check if a piece can be placed at position
    @param blocks table - Array of {row, col} offsets
    @param pivotRow number
    @param pivotCol number
    @return boolean
]]
function TetrisGrid:CanPlace(blocks, pivotRow, pivotCol)
    for _, block in ipairs(blocks) do
        local row = pivotRow + block[1]
        local col = pivotCol + block[2]

        -- Check bounds (allow rows above grid for spawning)
        if col < 1 or col > self.width or row > self.height then
            return false
        end

        -- Check collision with existing blocks (only if in visible area or below)
        if row >= 1 - TetrisGrid.HIDDEN_ROWS and not self:IsEmpty(row, col) then
            return false
        end
    end
    return true
end

--[[
    Place blocks on the grid
    @param blocks table - Array of {row, col} offsets
    @param pivotRow number
    @param pivotCol number
    @param color table - Color table
]]
function TetrisGrid:PlaceBlocks(blocks, pivotRow, pivotCol, color)
    for _, block in ipairs(blocks) do
        local row = pivotRow + block[1]
        local col = pivotCol + block[2]

        if row >= 1 - TetrisGrid.HIDDEN_ROWS and row <= self.height then
            self:SetCell(row, col, color)

            -- Mark cell as dirty for rendering
            if row >= 1 then
                self:MarkDirty(row, col)
            end
        end
    end
end

--============================================================
-- ROW OPERATIONS
--============================================================

--[[
    Check if a row is complete (full)
    @param row number
    @return boolean
]]
function TetrisGrid:IsRowComplete(row)
    if row < 1 or row > self.height then return false end

    for col = 1, self.width do
        if self:IsEmpty(row, col) then
            return false
        end
    end
    return true
end

--[[
    Find all complete rows
    @return table - Array of row numbers (bottom to top)
]]
function TetrisGrid:FindCompleteRows()
    local completeRows = {}

    for row = self.height, 1, -1 do
        if self:IsRowComplete(row) then
            table.insert(completeRows, row)
        end
    end

    return completeRows
end

--[[
    Clear a row and shift rows above down
    @param targetRow number
]]
function TetrisGrid:ClearRow(targetRow)
    -- Shift all rows above down by one
    for row = targetRow, 2 - TetrisGrid.HIDDEN_ROWS, -1 do
        for col = 1, self.width do
            self.cells[row][col] = self.cells[row - 1] and self.cells[row - 1][col] or nil
        end
    end

    -- Clear top row
    local topRow = 1 - TetrisGrid.HIDDEN_ROWS
    for col = 1, self.width do
        self:SetCell(topRow, col, nil)
    end
end

--[[
    Clear multiple rows (handles multiple simultaneous clears)
    @param rows table - Array of row numbers to clear (should be sorted bottom to top)
    @return number - Number of rows cleared
]]
function TetrisGrid:ClearRows(rows)
    local clearedCount = 0

    -- Sort rows from bottom to top to handle shifting correctly
    table.sort(rows, function(a, b) return a > b end)

    for _, row in ipairs(rows) do
        self:ClearRow(row)
        clearedCount = clearedCount + 1
    end

    -- Mark all visible cells as dirty after row clear (since rows shift down)
    for row = 1, self.height do
        for col = 1, self.width do
            self:MarkDirty(row, col)
        end
    end

    return clearedCount
end

--============================================================
-- GARBAGE OPERATIONS (for battle mode)
--============================================================

--[[
    Add garbage rows from the bottom
    @param count number - Number of garbage rows to add
    @param gapColumn number|nil - Column to leave empty (random if nil)
    @return boolean - True if game over (garbage pushed pieces out of top)
]]
function TetrisGrid:AddGarbageRows(count, gapColumn)
    local TetrisBlocks = HopeAddon.TetrisBlocks
    local garbageColor = TetrisBlocks and TetrisBlocks.COLORS.GARBAGE or self.FALLBACK_COLOR

    -- Check if any blocks exist in the top rows that would be pushed out
    local gameOver = false
    for row = 1, count do
        for col = 1, self.width do
            if not self:IsEmpty(row, col) then
                gameOver = true
                break
            end
        end
    end

    -- Shift all rows up
    for row = 1, self.height - count do
        for col = 1, self.width do
            self.cells[row][col] = self.cells[row + count] and self.cells[row + count][col] or nil
        end
    end

    -- Add garbage rows at bottom
    for i = 1, count do
        local row = self.height - count + i
        gapColumn = gapColumn or math.random(1, self.width)

        for col = 1, self.width do
            if col == gapColumn then
                self:SetCell(row, col, nil)
            else
                self:SetCell(row, col, garbageColor)
            end
        end

        -- Randomize gap position for next garbage row
        gapColumn = math.random(1, self.width)
    end

    -- Mark all visible cells as dirty after garbage added (since rows shifted up)
    for row = 1, self.height do
        for col = 1, self.width do
            self:MarkDirty(row, col)
        end
    end

    return gameOver
end

--============================================================
-- UTILITY
--============================================================

--[[
    Clear the entire grid
]]
function TetrisGrid:Clear()
    for row = 1 - TetrisGrid.HIDDEN_ROWS, self.height do
        for col = 1, self.width do
            self:SetCell(row, col, nil)
        end
    end
end

--[[
    Check if the grid is empty
    @return boolean
]]
function TetrisGrid:IsGridEmpty()
    for row = 1, self.height do
        for col = 1, self.width do
            if not self:IsEmpty(row, col) then
                return false
            end
        end
    end
    return true
end

--[[
    Count filled cells
    @return number
]]
function TetrisGrid:CountFilledCells()
    local count = 0
    for row = 1, self.height do
        for col = 1, self.width do
            if not self:IsEmpty(row, col) then
                count = count + 1
            end
        end
    end
    return count
end

--[[
    Get the highest filled row (lowest number = highest on screen)
    @return number - Row number (HEIGHT + 1 if grid is empty)
]]
function TetrisGrid:GetHighestFilledRow()
    for row = 1, self.height do
        for col = 1, self.width do
            if not self:IsEmpty(row, col) then
                return row
            end
        end
    end
    return self.height + 1
end

--[[
    Clone the grid
    @return TetrisGrid
]]
function TetrisGrid:Clone()
    local clone = TetrisGrid:New()

    for row = 1 - TetrisGrid.HIDDEN_ROWS, self.height do
        for col = 1, self.width do
            local cell = self:GetCell(row, col)
            if cell then
                clone:SetCell(row, col, { r = cell.r, g = cell.g, b = cell.b })
            end
        end
    end

    return clone
end

--============================================================
-- DIRTY TRACKING
--============================================================

--[[
    Get all dirty cells that need redrawing
    @return table - [row][col] = true for dirty cells
]]
function TetrisGrid:GetDirtyCells()
    return self.dirtyCells
end

--[[
    Clear all dirty cell flags
]]
function TetrisGrid:ClearDirtyCells()
    self.dirtyCells = {}
end

-- Export
HopeAddon.TetrisGrid = TetrisGrid

HopeAddon:Debug("TetrisGrid module loaded")
