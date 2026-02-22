--[[
    HopeAddon Pac-Man Maps
    Maze definitions and map utilities
]]

local PacManMaps = {}
HopeAddon.PacManMaps = PacManMaps

--============================================================
-- CONSTANTS
--============================================================

PacManMaps.CELL = {
    WALL = 0,
    PATH = 1,
    PELLET = 2,
    POWER = 3,
    GHOST_HOUSE = 4,
    GHOST_DOOR = 5,
    TUNNEL = 6,
}

PacManMaps.GRID_WIDTH = 21
PacManMaps.GRID_HEIGHT = 23

--============================================================
-- CLASSIC MAZE
--============================================================

-- 0=wall, 1=path, 2=pellet, 3=power, 4=ghost house, 5=ghost door, 6=tunnel
PacManMaps.CLASSIC = {
    "000000000000000000000",
    "022222222202222222220",
    "020000020202000002020",
    "032000020202000002030",
    "020000020202000002020",
    "022222222222222222220",
    "020002000002000020020",
    "022202222222222202220",
    "000202000040000202000",
    "000202044544440202000",
    "000202044444440202000",
    "611212044444440212116",
    "000202044444440202000",
    "000202044444440202000",
    "000202000010000202000",
    "022202222212222202220",
    "020002000202000200020",
    "032222202222202222230",
    "000020202000202020000",
    "022220202222202022220",
    "020000000202000000020",
    "022222222222222222220",
    "000000000000000000000",
}

PacManMaps.PACMAN_SPAWN = { row = 15, col = 11 }

PacManMaps.GHOST_SPAWNS = {
    BLINKY = { row = 9, col = 11 },
    PINKY  = { row = 11, col = 10 },
    INKY   = { row = 11, col = 11 },
    CLYDE  = { row = 11, col = 12 },
}

PacManMaps.SCATTER_TARGETS = {
    BLINKY = { row = 1, col = 21 },
    PINKY  = { row = 1, col = 1 },
    INKY   = { row = 23, col = 21 },
    CLYDE  = { row = 23, col = 1 },
}

--============================================================
-- UTILITIES
--============================================================

function PacManMaps:ParseMap(mapString)
    local map = {}
    for row, line in ipairs(mapString) do
        map[row] = {}
        for col = 1, #line do
            map[row][col] = tonumber(line:sub(col, col))
        end
    end
    return map
end

function PacManMaps:CountPellets(map)
    local count = 0
    for row = 1, #map do
        for col = 1, #map[row] do
            local cell = map[row][col]
            if cell == self.CELL.PELLET or cell == self.CELL.POWER then
                count = count + 1
            end
        end
    end
    return count
end

function PacManMaps:IsWalkable(map, row, col)
    if row < 1 or row > #map or col < 1 or col > #map[1] then
        return false
    end
    local cell = map[row][col]
    return cell ~= self.CELL.WALL and cell ~= self.CELL.GHOST_HOUSE
end

function PacManMaps:IsGhostWalkable(map, row, col, canEnterHouse)
    if row < 1 or row > #map or col < 1 or col > #map[1] then
        return false
    end
    local cell = map[row][col]
    if cell == self.CELL.WALL then return false end
    if cell == self.CELL.GHOST_HOUSE and not canEnterHouse then return false end
    return true
end

function PacManMaps:WrapPosition(row, col)
    if col < 1 then
        col = self.GRID_WIDTH
    elseif col > self.GRID_WIDTH then
        col = 1
    end
    return row, col
end

HopeAddon:Debug("PacManMaps loaded")
