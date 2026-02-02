--[[
    HopeAddon Pac-Man Ghost AI
    Each ghost has unique targeting behavior
]]

local PacManGhostAI = {}
HopeAddon.PacManGhostAI = PacManGhostAI

local math_abs = math.abs

--============================================================
-- CONSTANTS
--============================================================

local OPPOSITE_DIR = {
    UP = "DOWN",
    DOWN = "UP",
    LEFT = "RIGHT",
    RIGHT = "LEFT",
}

local DIR_OFFSET = {
    UP = { row = -1, col = 0 },
    DOWN = { row = 1, col = 0 },
    LEFT = { row = 0, col = -1 },
    RIGHT = { row = 0, col = 1 },
}

local DIR_PRIORITY = { "UP", "LEFT", "DOWN", "RIGHT" }

--============================================================
-- TARGETING
--============================================================

-- Blinky: Direct chase
function PacManGhostAI:GetBlinkyTarget(pacman)
    return pacman.row, pacman.col
end

-- Pinky: 4 tiles ahead (with classic UP bug)
function PacManGhostAI:GetPinkyTarget(pacman)
    local offset = 4
    local targetRow, targetCol = pacman.row, pacman.col

    if pacman.direction == "UP" then
        targetRow = targetRow - offset
        targetCol = targetCol - offset
    elseif pacman.direction == "DOWN" then
        targetRow = targetRow + offset
    elseif pacman.direction == "LEFT" then
        targetCol = targetCol - offset
    elseif pacman.direction == "RIGHT" then
        targetCol = targetCol + offset
    end

    return targetRow, targetCol
end

-- Inky: Flanking based on Blinky
function PacManGhostAI:GetInkyTarget(pacman, blinky)
    local pivotRow, pivotCol = pacman.row, pacman.col

    if pacman.direction == "UP" then
        pivotRow = pivotRow - 2
        pivotCol = pivotCol - 2
    elseif pacman.direction == "DOWN" then
        pivotRow = pivotRow + 2
    elseif pacman.direction == "LEFT" then
        pivotCol = pivotCol - 2
    elseif pacman.direction == "RIGHT" then
        pivotCol = pivotCol + 2
    end

    return pivotRow + (pivotRow - blinky.row), pivotCol + (pivotCol - blinky.col)
end

-- Clyde: Chase when far, scatter when close
function PacManGhostAI:GetClydeTarget(pacman, clyde, scatterTarget)
    local distance = math_abs(pacman.row - clyde.row) + math_abs(pacman.col - clyde.col)

    if distance > 8 then
        return pacman.row, pacman.col
    else
        return scatterTarget.row, scatterTarget.col
    end
end

--============================================================
-- MOVEMENT DECISION
--============================================================

function PacManGhostAI:ChooseDirection(ghost, targetRow, targetCol, map, canEnterHouse)
    local Maps = HopeAddon.PacManMaps
    local validMoves = {}
    local opposite = OPPOSITE_DIR[ghost.direction]

    for _, dir in ipairs(DIR_PRIORITY) do
        if dir ~= opposite then
            local offset = DIR_OFFSET[dir]
            local newRow = ghost.row + offset.row
            local newCol = ghost.col + offset.col
            newRow, newCol = Maps:WrapPosition(newRow, newCol)

            if Maps:IsGhostWalkable(map, newRow, newCol, canEnterHouse) then
                local dist = math_abs(targetRow - newRow) + math_abs(targetCol - newCol)
                table.insert(validMoves, { dir = dir, distance = dist })
            end
        end
    end

    if #validMoves == 0 then
        return opposite
    end

    table.sort(validMoves, function(a, b) return a.distance < b.distance end)
    return validMoves[1].dir
end

function PacManGhostAI:ChooseFrightenedDirection(ghost, map)
    local Maps = HopeAddon.PacManMaps
    local validDirs = {}
    local opposite = OPPOSITE_DIR[ghost.direction]

    for _, dir in ipairs(DIR_PRIORITY) do
        if dir ~= opposite then
            local offset = DIR_OFFSET[dir]
            local newRow = ghost.row + offset.row
            local newCol = ghost.col + offset.col
            newRow, newCol = Maps:WrapPosition(newRow, newCol)

            if Maps:IsGhostWalkable(map, newRow, newCol, false) then
                table.insert(validDirs, dir)
            end
        end
    end

    if #validDirs == 0 then
        return opposite
    end

    return validDirs[math.random(#validDirs)]
end

HopeAddon:Debug("PacManGhostAI loaded")
