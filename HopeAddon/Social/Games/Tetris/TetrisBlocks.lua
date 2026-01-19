--[[
    HopeAddon Tetris Blocks
    Tetromino definitions and rotation states

    Standard 7 pieces: I, O, T, S, Z, J, L
    Each piece has 4 rotation states (0, 90, 180, 270 degrees)
]]

local TetrisBlocks = {}

--============================================================
-- BLOCK COLORS
--============================================================

TetrisBlocks.COLORS = {
    I = { r = 0.00, g = 0.90, b = 0.90 },  -- Cyan
    O = { r = 1.00, g = 0.90, b = 0.00 },  -- Yellow
    T = { r = 0.60, g = 0.00, b = 0.80 },  -- Purple
    S = { r = 0.00, g = 0.80, b = 0.00 },  -- Green
    Z = { r = 0.90, g = 0.00, b = 0.00 },  -- Red
    J = { r = 0.00, g = 0.00, b = 0.90 },  -- Blue
    L = { r = 1.00, g = 0.50, b = 0.00 },  -- Orange
    GARBAGE = { r = 0.5, g = 0.5, b = 0.5 }, -- Gray (for garbage rows)
    GHOST = { r = 0.3, g = 0.3, b = 0.3 },   -- Ghost piece preview
}

--============================================================
-- TETROMINO DEFINITIONS
--============================================================

-- Each piece defined as array of {row, col} offsets from pivot point
-- 4 rotation states per piece

TetrisBlocks.PIECES = {
    -- I-piece (cyan)
    I = {
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { 0, 2 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 2, 0 },
        },
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { 0, 2 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 2, 0 },
        },
    },

    -- O-piece (yellow) - same in all rotations
    O = {
        {
            { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 },
        },
        {
            { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 },
        },
        {
            { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 },
        },
        {
            { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 },
        },
    },

    -- T-piece (purple)
    T = {
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { 1, 0 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, -1 },
        },
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { -1, 0 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 },
        },
    },

    -- S-piece (green)
    S = {
        {
            { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 0 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 0, 1 }, { 1, 1 },
        },
        {
            { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 0 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 0, 1 }, { 1, 1 },
        },
    },

    -- Z-piece (red)
    Z = {
        {
            { 0, -1 }, { 0, 0 }, { 1, 0 }, { 1, 1 },
        },
        {
            { -1, 1 }, { 0, 0 }, { 0, 1 }, { 1, 0 },
        },
        {
            { 0, -1 }, { 0, 0 }, { 1, 0 }, { 1, 1 },
        },
        {
            { -1, 1 }, { 0, 0 }, { 0, 1 }, { 1, 0 },
        },
    },

    -- J-piece (blue)
    J = {
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { 1, -1 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { -1, -1 },
        },
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { -1, 1 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 1, 1 },
        },
    },

    -- L-piece (orange)
    L = {
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { 1, 1 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { -1, 1 },
        },
        {
            { 0, -1 }, { 0, 0 }, { 0, 1 }, { -1, -1 },
        },
        {
            { -1, 0 }, { 0, 0 }, { 1, 0 }, { 1, -1 },
        },
    },
}

-- Piece type list for random selection
TetrisBlocks.PIECE_TYPES = { "I", "O", "T", "S", "Z", "J", "L" }

--============================================================
-- WALL KICK DATA (SRS - Super Rotation System)
--============================================================

-- Wall kick offsets for J, L, S, T, Z pieces
TetrisBlocks.WALL_KICKS_JLSTZ = {
    -- 0->1 (spawn to clockwise)
    [1] = {
        { 0, 0 }, { -1, 0 }, { -1, 1 }, { 0, -2 }, { -1, -2 },
    },
    -- 1->2
    [2] = {
        { 0, 0 }, { 1, 0 }, { 1, -1 }, { 0, 2 }, { 1, 2 },
    },
    -- 2->3
    [3] = {
        { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, -2 }, { 1, -2 },
    },
    -- 3->0
    [4] = {
        { 0, 0 }, { -1, 0 }, { -1, -1 }, { 0, 2 }, { -1, 2 },
    },
}

-- Wall kick offsets for I piece
TetrisBlocks.WALL_KICKS_I = {
    -- 0->1
    [1] = {
        { 0, 0 }, { -2, 0 }, { 1, 0 }, { -2, -1 }, { 1, 2 },
    },
    -- 1->2
    [2] = {
        { 0, 0 }, { -1, 0 }, { 2, 0 }, { -1, 2 }, { 2, -1 },
    },
    -- 2->3
    [3] = {
        { 0, 0 }, { 2, 0 }, { -1, 0 }, { 2, 1 }, { -1, -2 },
    },
    -- 3->0
    [4] = {
        { 0, 0 }, { 1, 0 }, { -2, 0 }, { 1, -2 }, { -2, 1 },
    },
}

--============================================================
-- API FUNCTIONS
--============================================================

--[[
    Get a random piece type
    @return string - Piece type (I, O, T, S, Z, J, L)
]]
function TetrisBlocks:GetRandomPieceType()
    return self.PIECE_TYPES[math.random(#self.PIECE_TYPES)]
end

--[[
    Generate a bag of pieces (7-bag randomizer)
    @return table - Array of piece types
]]
function TetrisBlocks:GenerateBag()
    local bag = {}
    for i, pieceType in ipairs(self.PIECE_TYPES) do
        bag[i] = pieceType
    end

    -- Fisher-Yates shuffle
    for i = #bag, 2, -1 do
        local j = math.random(i)
        bag[i], bag[j] = bag[j], bag[i]
    end

    return bag
end

--[[
    Get piece blocks for a given type and rotation
    @param pieceType string
    @param rotation number (1-4)
    @return table - Array of {row, col} offsets
]]
function TetrisBlocks:GetBlocks(pieceType, rotation)
    local piece = self.PIECES[pieceType]
    if not piece then return {} end

    -- Validate rotation is a number
    rotation = tonumber(rotation) or 1
    rotation = ((rotation - 1) % 4) + 1
    return piece[rotation]
end

--[[
    Get piece color
    @param pieceType string
    @return table - {r, g, b}
]]
function TetrisBlocks:GetColor(pieceType)
    return self.COLORS[pieceType] or self.COLORS.GARBAGE
end

--[[
    Get wall kick offsets for rotation
    @param pieceType string
    @param fromRotation number (1-4)
    @param direction number (1 for clockwise, -1 for counter-clockwise)
    @return table - Array of {row, col} kick offsets
]]
function TetrisBlocks:GetWallKicks(pieceType, fromRotation, direction)
    if pieceType == "O" then
        -- O piece doesn't need wall kicks
        return { { 0, 0 } }
    end

    local kickData
    if pieceType == "I" then
        kickData = self.WALL_KICKS_I
    else
        kickData = self.WALL_KICKS_JLSTZ
    end

    -- Determine kick index based on rotation transition
    local kickIndex
    if direction == 1 then -- Clockwise
        kickIndex = fromRotation
    else -- Counter-clockwise (use reverse of next state's clockwise kicks)
        kickIndex = (fromRotation % 4) + 1
    end

    local kicks = kickData[kickIndex]
    if not kicks then
        return { { 0, 0 } }
    end

    -- For counter-clockwise, negate the offsets
    if direction == -1 then
        local negatedKicks = {}
        for i, kick in ipairs(kicks) do
            negatedKicks[i] = { -kick[1], -kick[2] }
        end
        return negatedKicks
    end

    return kicks
end

--[[
    Get spawn position for a piece type
    @param pieceType string
    @param gridWidth number
    @return number, number - row, col
]]
function TetrisBlocks:GetSpawnPosition(pieceType, gridWidth)
    -- Spawn at top center
    local col = math.floor(gridWidth / 2)
    local row = 1

    -- I piece spawns one row higher
    if pieceType == "I" then
        row = 0
    end

    return row, col
end

-- Export
HopeAddon.TetrisBlocks = TetrisBlocks

HopeAddon:Debug("TetrisBlocks module loaded")
