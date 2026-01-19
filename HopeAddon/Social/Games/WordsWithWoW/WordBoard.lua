--[[
    HopeAddon Words with WoW Board
    15x15 Scrabble-style board with bonus squares
]]

local WordBoard = {}
WordBoard.__index = WordBoard

--============================================================
-- CONSTANTS
--============================================================

WordBoard.SIZE = 15
WordBoard.CENTER = 8  -- 1-indexed center

-- Bonus types
WordBoard.BONUS = {
    NONE = 0,
    DOUBLE_LETTER = 1,  -- DL
    TRIPLE_LETTER = 2,  -- TL
    DOUBLE_WORD = 3,    -- DW
    TRIPLE_WORD = 4,    -- TW
    CENTER = 5,         -- Star (counts as DW)
}

-- Standard Scrabble board bonus layout (symmetric)
-- Only need to define one quadrant + center column/row
WordBoard.BONUS_LAYOUT = {
    -- Row 1
    [1] = { [1] = 4, [4] = 1, [8] = 4 },
    -- Row 2
    [2] = { [2] = 3, [6] = 2 },
    -- Row 3
    [3] = { [3] = 3, [7] = 1 },
    -- Row 4
    [4] = { [1] = 1, [4] = 3, [8] = 1 },
    -- Row 5
    [5] = { [5] = 3 },
    -- Row 6
    [6] = { [2] = 2, [6] = 2 },
    -- Row 7
    [7] = { [3] = 1, [7] = 1 },
    -- Row 8 (center row)
    [8] = { [1] = 4, [4] = 1, [8] = 5 },  -- Center is star/DW
}

--============================================================
-- CONSTRUCTOR
--============================================================

function WordBoard:New()
    local board = setmetatable({}, WordBoard)

    -- Board cells: [row][col] = { letter = nil, bonus = BONUS_TYPE }
    board.cells = {}
    board.size = self.SIZE

    -- Initialize board with bonuses (using symmetry)
    for row = 1, self.SIZE do
        board.cells[row] = {}
        for col = 1, self.SIZE do
            board.cells[row][col] = {
                letter = nil,
                bonus = board:GetBonusForCell(row, col),
            }
        end
    end

    return board
end

--============================================================
-- BONUS CALCULATION
--============================================================

function WordBoard:GetBonusForCell(row, col)
    -- Use symmetry to determine bonus
    -- Normalize to first quadrant + center
    local r = row <= 8 and row or (16 - row)
    local c = col <= 8 and col or (16 - col)

    -- Look up in layout
    if self.BONUS_LAYOUT[r] and self.BONUS_LAYOUT[r][c] then
        return self.BONUS_LAYOUT[r][c]
    end

    return self.BONUS.NONE
end

--============================================================
-- CELL OPERATIONS
--============================================================

function WordBoard:GetCell(row, col)
    if not self:IsInBounds(row, col) then return nil end
    return self.cells[row][col]
end

function WordBoard:SetLetter(row, col, letter)
    if not self:IsInBounds(row, col) then return false end
    self.cells[row][col].letter = letter and letter:upper() or nil
    return true
end

function WordBoard:GetLetter(row, col)
    local cell = self:GetCell(row, col)
    return cell and cell.letter or nil
end

function WordBoard:GetBonus(row, col)
    local cell = self:GetCell(row, col)
    return cell and cell.bonus or self.BONUS.NONE
end

function WordBoard:IsEmpty(row, col)
    return self:GetLetter(row, col) == nil
end

function WordBoard:IsInBounds(row, col)
    return row >= 1 and row <= self.size and col >= 1 and col <= self.size
end

--============================================================
-- WORD PLACEMENT
--============================================================

--[[
    Check if a word can be placed
    @param word string
    @param startRow number
    @param startCol number
    @param horizontal boolean
    @param isFirstWord boolean
    @return boolean, string (error message if false)
]]
function WordBoard:CanPlaceWord(word, startRow, startCol, horizontal, isFirstWord)
    word = word:upper()
    local len = #word

    -- Check bounds
    if horizontal then
        if startCol + len - 1 > self.size then
            return false, "Word extends beyond board"
        end
    else
        if startRow + len - 1 > self.size then
            return false, "Word extends beyond board"
        end
    end

    -- Track if word connects to existing tiles or uses existing tiles
    local connectsToExisting = false
    local usesExistingTile = false
    local newTilesCount = 0

    for i = 1, len do
        local row = horizontal and startRow or (startRow + i - 1)
        local col = horizontal and (startCol + i - 1) or startCol
        local existingLetter = self:GetLetter(row, col)
        local newLetter = word:sub(i, i)

        if existingLetter then
            -- Must match existing letter
            if existingLetter ~= newLetter then
                return false, "Conflicts with existing tile at " .. row .. "," .. col
            end
            usesExistingTile = true
        else
            newTilesCount = newTilesCount + 1

            -- Check for adjacent tiles (connections)
            if not connectsToExisting then
                -- Check adjacent cells
                local adjacents = {
                    { row - 1, col },
                    { row + 1, col },
                    { row, col - 1 },
                    { row, col + 1 },
                }
                for _, adj in ipairs(adjacents) do
                    if self:GetLetter(adj[1], adj[2]) then
                        connectsToExisting = true
                        break
                    end
                end
            end
        end
    end

    -- First word must cover center
    if isFirstWord then
        local coversCenter = false
        for i = 1, len do
            local row = horizontal and startRow or (startRow + i - 1)
            local col = horizontal and (startCol + i - 1) or startCol
            if row == self.CENTER and col == self.CENTER then
                coversCenter = true
                break
            end
        end
        if not coversCenter then
            return false, "First word must cover center square"
        end
    else
        -- Must connect to existing words or use existing tiles
        if not connectsToExisting and not usesExistingTile then
            return false, "Word must connect to existing tiles"
        end
    end

    -- Must place at least one new tile
    if newTilesCount == 0 then
        return false, "Must place at least one new tile"
    end

    return true
end

--[[
    Place a word on the board
    @param word string
    @param startRow number
    @param startCol number
    @param horizontal boolean
    @return table - Array of {row, col, letter} for new tiles placed
]]
function WordBoard:PlaceWord(word, startRow, startCol, horizontal)
    word = word:upper()
    local placedTiles = {}

    for i = 1, #word do
        local row = horizontal and startRow or (startRow + i - 1)
        local col = horizontal and (startCol + i - 1) or startCol
        local letter = word:sub(i, i)

        if self:IsEmpty(row, col) then
            self:SetLetter(row, col, letter)
            table.insert(placedTiles, { row = row, col = col, letter = letter })
        end
    end

    return placedTiles
end

--============================================================
-- SCORING
--============================================================

--[[
    Calculate score for placing a word
    @param word string
    @param startRow number
    @param startCol number
    @param horizontal boolean
    @param newTiles table - Array of {row, col} for newly placed tiles
    @return number
]]
function WordBoard:CalculateWordScore(word, startRow, startCol, horizontal, newTiles)
    local WordDictionary = HopeAddon.WordDictionary
    word = word:upper()

    local wordScore = 0
    local wordMultiplier = 1

    -- Build set of new tile positions for quick lookup
    local isNewTile = {}
    for _, tile in ipairs(newTiles) do
        isNewTile[tile.row .. "," .. tile.col] = true
    end

    for i = 1, #word do
        local row = horizontal and startRow or (startRow + i - 1)
        local col = horizontal and (startCol + i - 1) or startCol
        local letter = word:sub(i, i)
        local letterValue = WordDictionary:GetLetterValue(letter)
        local bonus = self:GetBonus(row, col)

        -- Bonuses only apply to newly placed tiles
        local key = row .. "," .. col
        if isNewTile[key] then
            if bonus == self.BONUS.DOUBLE_LETTER then
                letterValue = letterValue * 2
            elseif bonus == self.BONUS.TRIPLE_LETTER then
                letterValue = letterValue * 3
            elseif bonus == self.BONUS.DOUBLE_WORD or bonus == self.BONUS.CENTER then
                wordMultiplier = wordMultiplier * 2
            elseif bonus == self.BONUS.TRIPLE_WORD then
                wordMultiplier = wordMultiplier * 3
            end
        end

        wordScore = wordScore + letterValue
    end

    return wordScore * wordMultiplier
end

--[[
    Find all words formed by a play (main word + cross words)
    @param placedTiles table - Array of {row, col, letter}
    @param horizontal boolean - Direction of main word
    @return table - Array of {word, startRow, startCol, horizontal, score}
]]
function WordBoard:FindFormedWords(placedTiles, horizontal)
    local words = {}

    if #placedTiles == 0 then return words end

    -- Find main word extent
    local minRow, maxRow = placedTiles[1].row, placedTiles[1].row
    local minCol, maxCol = placedTiles[1].col, placedTiles[1].col

    for _, tile in ipairs(placedTiles) do
        minRow = math.min(minRow, tile.row)
        maxRow = math.max(maxRow, tile.row)
        minCol = math.min(minCol, tile.col)
        maxCol = math.max(maxCol, tile.col)
    end

    -- Extend main word to include adjacent existing tiles
    if horizontal then
        while minCol > 1 and self:GetLetter(minRow, minCol - 1) do
            minCol = minCol - 1
        end
        while maxCol < self.size and self:GetLetter(minRow, maxCol + 1) do
            maxCol = maxCol + 1
        end

        -- Build main word
        local mainWord = ""
        for col = minCol, maxCol do
            mainWord = mainWord .. self:GetLetter(minRow, col)
        end

        if #mainWord >= 2 then
            table.insert(words, {
                word = mainWord,
                startRow = minRow,
                startCol = minCol,
                horizontal = true,
            })
        end

        -- Check cross words for each placed tile
        for _, tile in ipairs(placedTiles) do
            local crossWord = self:GetVerticalWord(tile.row, tile.col)
            if crossWord and #crossWord.word >= 2 then
                table.insert(words, crossWord)
            end
        end
    else
        while minRow > 1 and self:GetLetter(minRow - 1, minCol) do
            minRow = minRow - 1
        end
        while maxRow < self.size and self:GetLetter(maxRow + 1, minCol) do
            maxRow = maxRow + 1
        end

        -- Build main word
        local mainWord = ""
        for row = minRow, maxRow do
            mainWord = mainWord .. self:GetLetter(row, minCol)
        end

        if #mainWord >= 2 then
            table.insert(words, {
                word = mainWord,
                startRow = minRow,
                startCol = minCol,
                horizontal = false,
            })
        end

        -- Check cross words for each placed tile
        for _, tile in ipairs(placedTiles) do
            local crossWord = self:GetHorizontalWord(tile.row, tile.col)
            if crossWord and #crossWord.word >= 2 then
                table.insert(words, crossWord)
            end
        end
    end

    return words
end

function WordBoard:GetVerticalWord(row, col)
    local startRow = row
    while startRow > 1 and self:GetLetter(startRow - 1, col) do
        startRow = startRow - 1
    end

    local endRow = row
    while endRow < self.size and self:GetLetter(endRow + 1, col) do
        endRow = endRow + 1
    end

    if startRow == endRow then return nil end

    local word = ""
    for r = startRow, endRow do
        word = word .. self:GetLetter(r, col)
    end

    return {
        word = word,
        startRow = startRow,
        startCol = col,
        horizontal = false,
    }
end

function WordBoard:GetHorizontalWord(row, col)
    local startCol = col
    while startCol > 1 and self:GetLetter(row, startCol - 1) do
        startCol = startCol - 1
    end

    local endCol = col
    while endCol < self.size and self:GetLetter(row, endCol + 1) do
        endCol = endCol + 1
    end

    if startCol == endCol then return nil end

    local word = ""
    for c = startCol, endCol do
        word = word .. self:GetLetter(row, c)
    end

    return {
        word = word,
        startRow = row,
        startCol = startCol,
        horizontal = true,
    }
end

--============================================================
-- UTILITY
--============================================================

function WordBoard:IsBoardEmpty()
    for row = 1, self.size do
        for col = 1, self.size do
            if not self:IsEmpty(row, col) then
                return false
            end
        end
    end
    return true
end

function WordBoard:Clear()
    for row = 1, self.size do
        for col = 1, self.size do
            self.cells[row][col].letter = nil
        end
    end
end

-- Export
HopeAddon.WordBoard = WordBoard

HopeAddon:Debug("WordBoard module loaded")
