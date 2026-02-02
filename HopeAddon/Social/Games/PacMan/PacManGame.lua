--[[
    HopeAddon Pac WoW Game
    Classic Pac-Man vs AI ghosts with WoW theming
    Controls: Arrow keys or WASD
]]

local PacManGame = {}

local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

--============================================================
-- CONSTANTS
--============================================================

PacManGame.SETTINGS = {
    CELL_SIZE = 16,

    PACMAN_MOVE_INTERVAL = 0.12,
    GHOST_MOVE_INTERVAL = 0.15,
    FRIGHTENED_MOVE_INTERVAL = 0.20,
    EATEN_MOVE_INTERVAL = 0.05,

    POWER_DURATION = 8.0,
    POWER_WARNING = 2.0,

    POINTS_PELLET = 10,
    POINTS_POWER = 50,
    POINTS_GHOST = { 200, 400, 800, 1600 },

    STARTING_LIVES = 3,
    EXTRA_LIFE_SCORE = 10000,

    MODE_SEQUENCE = {
        { mode = "SCATTER", duration = 7 },
        { mode = "CHASE", duration = 20 },
        { mode = "SCATTER", duration = 7 },
        { mode = "CHASE", duration = 20 },
        { mode = "SCATTER", duration = 5 },
        { mode = "CHASE", duration = 20 },
        { mode = "SCATTER", duration = 5 },
        { mode = "CHASE", duration = 9999 },
    },

    GHOST_RELEASE = {
        BLINKY = 0,
        PINKY = 2,
        INKY = 5,
        CLYDE = 8,
    },
}

local COLORS = {
    WALL = { r = 0.1, g = 0.1, b = 0.5 },
    PATH = { r = 0.0, g = 0.0, b = 0.0 },
    PACMAN = { r = 1.0, g = 1.0, b = 0.0 },      -- Neon yellow (already bright)
    BLINKY = { r = 1.0, g = 0.1, b = 0.2 },      -- Neon red (hot red with slight pink)
    PINKY = { r = 1.0, g = 0.0, b = 0.8 },       -- Neon hot pink/magenta
    INKY = { r = 0.0, g = 1.0, b = 1.0 },        -- Neon cyan (already bright)
    CLYDE = { r = 1.0, g = 0.5, b = 0.0 },       -- Neon orange (more saturated)
    FRIGHTENED = { r = 0.3, g = 0.3, b = 1.0 },  -- Brighter blue
    FRIGHTENED_FLASH = { r = 1.0, g = 1.0, b = 1.0 },
    EATEN = { r = 0.4, g = 0.4, b = 0.4 },
    PELLET = { r = 1.0, g = 0.9, b = 0.5 },      -- Brighter pellets
    POWER = { r = 1.0, g = 1.0, b = 1.0 },
}

local PACMAN_ANIM = {
    CHOMP_SPEED = 12,       -- Radians per second (smooth sine wave)
    MAX_MOUTH_ANGLE = 55,   -- Maximum mouth opening in degrees
    DIR_ROTATION = {
        RIGHT = 0,
        DOWN = 270,
        LEFT = 180,
        UP = 90,
    },
}

-- Pupil offset based on ghost direction (for eye tracking)
local PUPIL_OFFSET = {
    UP = { x = 0, y = 1 },
    DOWN = { x = 0, y = -1 },
    LEFT = { x = -1, y = 0 },
    RIGHT = { x = 1, y = 0 },
}

--============================================================
-- MODULE STATE
--============================================================

PacManGame.games = {}

--============================================================
-- DIFFICULTY SCALING
--============================================================

--[[
    Get level-specific settings for difficulty scaling
    @param level number - Current level (1-based)
    @return table - Settings adjusted for the level
]]
function PacManGame:GetLevelSettings(level)
    local S = self.SETTINGS
    local baseGhostSpeed = S.GHOST_MOVE_INTERVAL
    local baseFrightSpeed = S.FRIGHTENED_MOVE_INTERVAL
    local baseFrightDuration = S.POWER_DURATION

    -- Ghosts get 5% faster each level, cap at 50% faster (multiplier 0.5)
    local speedMultiplier = math.max(0.5, 1 - (level - 1) * 0.05)

    -- Frightened duration decreases by 0.5s per level, min 2s
    local frightDuration = math.max(2, baseFrightDuration - (level - 1) * 0.5)

    return {
        ghostMoveInterval = baseGhostSpeed * speedMultiplier,
        frightenedMoveInterval = baseFrightSpeed * speedMultiplier,
        powerDuration = frightDuration,
    }
end

--============================================================
-- GHOST VISUAL CREATION
--============================================================

--[[
    Create a ghost frame with rounded body, wavy bottom, and expressive eyes
    @param parent Frame - Parent frame (gridFrame)
    @param ghostName string - Name of the ghost (BLINKY, PINKY, INKY, CLYDE)
    @param cellSize number - Size of a grid cell
    @return Frame - The ghost frame with all visual elements
]]
function PacManGame:CreateGhostFrame(parent, ghostName, cellSize)
    local color = COLORS[ghostName]
    local size = cellSize - 2

    local ghostFrame = CreateFrame("Frame", nil, parent)
    ghostFrame:SetSize(size, size)
    ghostFrame:SetFrameLevel(parent:GetFrameLevel() + 5)

    -- Main body - use SetColorTexture for exact color without multiplication
    -- (SetVertexColor multiplies texture pixels, which distorts colors)
    local body = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    body:SetSize(size, size)
    body:SetPoint("CENTER", 0, 1)
    body:SetColorTexture(color.r, color.g, color.b, 1)
    ghostFrame.body = body

    -- Bottom "skirt" - 3 small bumps for wavy edge
    local bumps = {}
    for i = 1, 3 do
        local bump = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 0)
        bump:SetSize(5, 5)
        bump:SetColorTexture(color.r, color.g, color.b, 1)
        bump:SetPoint("BOTTOM", ghostFrame, "BOTTOM", (i - 2) * 5, -2)
        bumps[i] = bump
    end
    ghostFrame.bumps = bumps

    -- Eye whites (2 circles)
    local eyeL = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    eyeL:SetSize(5, 5)
    eyeL:SetTexture("Interface\\COMMON\\Indicator-Gray")
    eyeL:SetVertexColor(1, 1, 1, 1)
    eyeL:SetPoint("CENTER", ghostFrame, "CENTER", -3, 2)
    ghostFrame.eyeL = eyeL

    local eyeR = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    eyeR:SetSize(5, 5)
    eyeR:SetTexture("Interface\\COMMON\\Indicator-Gray")
    eyeR:SetVertexColor(1, 1, 1, 1)
    eyeR:SetPoint("CENTER", ghostFrame, "CENTER", 3, 2)
    ghostFrame.eyeR = eyeR

    -- Pupils (2 smaller dark circles)
    local pupilL = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 3)
    pupilL:SetSize(2, 2)
    pupilL:SetColorTexture(0.1, 0.1, 0.3, 1)
    pupilL:SetPoint("CENTER", eyeL, "CENTER", 0, 0)
    ghostFrame.pupilL = pupilL

    local pupilR = ghostFrame:CreateTexture(nil, "ARTWORK", nil, 3)
    pupilR:SetSize(2, 2)
    pupilR:SetColorTexture(0.1, 0.1, 0.3, 1)
    pupilR:SetPoint("CENTER", eyeR, "CENTER", 0, 0)
    ghostFrame.pupilR = pupilR

    -- Store original color for restoration
    ghostFrame.originalColor = color
    ghostFrame.ghostName = ghostName

    -- Create frightened animation (pulsing scale)
    self:CreateFrightenedAnimation(ghostFrame)

    return ghostFrame
end

--[[
    Create pulsing animation for frightened state
    @param ghostFrame Frame - The ghost frame to add animation to
]]
function PacManGame:CreateFrightenedAnimation(ghostFrame)
    local ag = ghostFrame:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")

    local pulse = ag:CreateAnimation("Scale")
    pulse:SetScale(1.15, 1.15)
    pulse:SetDuration(0.3)
    pulse:SetSmoothing("IN_OUT")

    ghostFrame.frightenedAnim = ag
end

--[[
    Update ghost visual state (normal, frightened, eaten)
    @param ghostFrame Frame - The ghost frame
    @param ghost table - Ghost state data
    @param powerTimer number - Remaining power-up time
    @param powerWarning number - Warning threshold for flashing
]]
function PacManGame:UpdateGhostVisual(ghostFrame, ghost, powerTimer, powerWarning)
    if ghost.mode == "EATEN" then
        -- Eaten: hide body, show only eyes
        ghostFrame.body:Hide()
        for _, bump in ipairs(ghostFrame.bumps) do
            bump:Hide()
        end
        ghostFrame.eyeL:Show()
        ghostFrame.eyeR:Show()
        ghostFrame.pupilL:Show()
        ghostFrame.pupilR:Show()
        -- Center pupils when eaten (looking forward)
        ghostFrame.pupilL:ClearAllPoints()
        ghostFrame.pupilL:SetPoint("CENTER", ghostFrame.eyeL, "CENTER", 0, 0)
        ghostFrame.pupilR:ClearAllPoints()
        ghostFrame.pupilR:SetPoint("CENTER", ghostFrame.eyeR, "CENTER", 0, 0)
        -- Stop frightened animation if playing
        if ghostFrame.frightenedAnim:IsPlaying() then
            ghostFrame.frightenedAnim:Stop()
        end

    elseif ghost.mode == "FRIGHTENED" then
        -- Frightened: blue body, hide pupils (scared expression), pulse animation
        ghostFrame.body:Show()
        for _, bump in ipairs(ghostFrame.bumps) do
            bump:Show()
        end
        ghostFrame.eyeL:Show()
        ghostFrame.eyeR:Show()
        -- Hide pupils for scared look
        ghostFrame.pupilL:Hide()
        ghostFrame.pupilR:Hide()

        -- Flash white when power is about to end
        local flashWhite = powerTimer < powerWarning and math.floor(powerTimer * 4) % 2 == 0
        if flashWhite then
            ghostFrame.body:SetColorTexture(COLORS.FRIGHTENED_FLASH.r, COLORS.FRIGHTENED_FLASH.g, COLORS.FRIGHTENED_FLASH.b, 1)
            for _, bump in ipairs(ghostFrame.bumps) do
                bump:SetColorTexture(COLORS.FRIGHTENED_FLASH.r, COLORS.FRIGHTENED_FLASH.g, COLORS.FRIGHTENED_FLASH.b, 1)
            end
        else
            ghostFrame.body:SetColorTexture(COLORS.FRIGHTENED.r, COLORS.FRIGHTENED.g, COLORS.FRIGHTENED.b, 1)
            for _, bump in ipairs(ghostFrame.bumps) do
                bump:SetColorTexture(COLORS.FRIGHTENED.r, COLORS.FRIGHTENED.g, COLORS.FRIGHTENED.b, 1)
            end
        end

        -- Start pulsing if not already
        if not ghostFrame.frightenedAnim:IsPlaying() then
            ghostFrame.frightenedAnim:Play()
        end

    else
        -- Normal state: show full ghost with original color
        ghostFrame.body:Show()
        for _, bump in ipairs(ghostFrame.bumps) do
            bump:Show()
        end
        ghostFrame.eyeL:Show()
        ghostFrame.eyeR:Show()
        ghostFrame.pupilL:Show()
        ghostFrame.pupilR:Show()

        -- Restore original color
        local color = ghostFrame.originalColor
        ghostFrame.body:SetColorTexture(color.r, color.g, color.b, 1)
        for _, bump in ipairs(ghostFrame.bumps) do
            bump:SetColorTexture(color.r, color.g, color.b, 1)
        end

        -- Update pupil position based on direction
        local offset = PUPIL_OFFSET[ghost.direction] or { x = 0, y = 0 }
        ghostFrame.pupilL:ClearAllPoints()
        ghostFrame.pupilL:SetPoint("CENTER", ghostFrame.eyeL, "CENTER", offset.x, offset.y)
        ghostFrame.pupilR:ClearAllPoints()
        ghostFrame.pupilR:SetPoint("CENTER", ghostFrame.eyeR, "CENTER", offset.x, offset.y)

        -- Stop frightened animation if playing
        if ghostFrame.frightenedAnim:IsPlaying() then
            ghostFrame.frightenedAnim:Stop()
        end
    end
end

--[[
    Properly destroy a ghost frame and all child textures to prevent memory leaks
    @param ghostFrame Frame - The ghost frame to destroy
]]
function PacManGame:DestroyGhostFrame(ghostFrame)
    if not ghostFrame then return end

    -- Stop animation
    if ghostFrame.frightenedAnim then
        if ghostFrame.frightenedAnim:IsPlaying() then
            ghostFrame.frightenedAnim:Stop()
        end
        ghostFrame.frightenedAnim = nil
    end

    -- Clear texture references (textures auto-destroyed with parent)
    ghostFrame.body = nil
    ghostFrame.bumps = nil
    ghostFrame.eyeL = nil
    ghostFrame.eyeR = nil
    ghostFrame.pupilL = nil
    ghostFrame.pupilR = nil
    ghostFrame.originalColor = nil

    -- Hide and destroy frame
    ghostFrame:Hide()
    ghostFrame:SetParent(nil)
end

--============================================================
-- LIFECYCLE
--============================================================

function PacManGame:OnInitialize()
    HopeAddon:Debug("PacManGame initializing...")
end

function PacManGame:OnEnable()
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:RegisterGame(GameCore.GAME_TYPE.PACMAN, self)
    end
    self:RegisterNetworkHandlers()
    HopeAddon:Debug("PacManGame enabled")
end

function PacManGame:OnDisable()
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:UnregisterHandler("PACMAN", "STATE")
        GameComms:UnregisterHandler("PACMAN", "END")
    end
    for gameId in pairs(self.games) do
        self:CleanupGame(gameId)
    end
    self.games = {}
end

function PacManGame:RegisterNetworkHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end
    GameComms:RegisterHandler("PACMAN", "STATE", function(sender, gameId, data)
        self:OnOpponentState(sender, gameId, data)
    end)
    GameComms:RegisterHandler("PACMAN", "END", function(sender, gameId, data)
        self:OnOpponentEnd(sender, gameId, data)
    end)
end

function PacManGame:OnOpponentState(sender, gameId, data)
    local game = self.games[gameId]
    if not game or not game.data.state.isScoreChallenge then return end

    local score, level = strsplit("|", data)
    self:UpdateOpponentPanel(gameId, tonumber(score) or 0, tonumber(level) or 1, "PLAYING")
end

function PacManGame:OnOpponentEnd(sender, gameId, data)
    local game = self.games[gameId]
    if not game or not game.data.state.isScoreChallenge then return end

    local part1, part2 = strsplit("|", data)
    if part1 == "CANCEL" then return end

    self:UpdateOpponentPanel(gameId, tonumber(part1) or 0, tonumber(part2) or 1, "FINISHED")
end

--============================================================
-- GAMECORE CALLBACKS
--============================================================

function PacManGame:OnCreate(gameId, game)
    HopeAddon:Debug("PacManGame:OnCreate", gameId)

    local Maps = HopeAddon.PacManMaps
    local map = Maps:ParseMap(Maps.CLASSIC)
    local pelletCount = Maps:CountPellets(map)

    -- Detect if this is a score challenge mode
    local GameCore = HopeAddon:GetModule("GameCore")
    local isScoreChallenge = game.mode == GameCore.GAME_MODE.SCORE_CHALLENGE

    self.games[gameId] = {
        data = {
            ui = {
                window = nil,
                gridFrame = nil,
                cells = {},
                pacmanFrame = nil,
                ghostFrames = {},
                scoreText = nil,
                livesContainer = nil,
                lifeIcons = {},
                levelText = nil,
                countdownText = nil,
                opponentPanel = nil,
            },
            state = {
                phase = "READY",
                isScoreChallenge = isScoreChallenge,
                pacman = {
                    row = Maps.PACMAN_SPAWN.row,
                    col = Maps.PACMAN_SPAWN.col,
                    direction = "LEFT",
                    nextDirection = nil,
                    moveTimer = 0,
                    animTimer = 0,
                    mouthOpen = true,
                },
                ghosts = {
                    { name = "BLINKY", row = Maps.GHOST_SPAWNS.BLINKY.row, col = Maps.GHOST_SPAWNS.BLINKY.col,
                      direction = "LEFT", mode = "SCATTER", released = true, moveTimer = 0 },
                    { name = "PINKY", row = Maps.GHOST_SPAWNS.PINKY.row, col = Maps.GHOST_SPAWNS.PINKY.col,
                      direction = "UP", mode = "HOUSE", released = false, moveTimer = 0 },
                    { name = "INKY", row = Maps.GHOST_SPAWNS.INKY.row, col = Maps.GHOST_SPAWNS.INKY.col,
                      direction = "UP", mode = "HOUSE", released = false, moveTimer = 0 },
                    { name = "CLYDE", row = Maps.GHOST_SPAWNS.CLYDE.row, col = Maps.GHOST_SPAWNS.CLYDE.col,
                      direction = "UP", mode = "HOUSE", released = false, moveTimer = 0 },
                },
                map = map,
                pelletsRemaining = pelletCount,
                score = 0,
                lives = self.SETTINGS.STARTING_LIVES,
                level = 1,
                ghostsEatenThisPower = 0,
                extraLifeAwarded = false,
                powerTimer = 0,
                modeTimer = 0,
                modePhase = 1,
                currentMode = "SCATTER",
                gameTime = 0,
                countdown = 3,
                countdownTimer = nil,
                ghostReplay = nil,  -- Will be initialized for score challenge
            },
        },
    }

    -- Initialize ghost replay for score challenge mode
    if isScoreChallenge and game.opponent then
        local GhostReplay = HopeAddon.GhostReplay
        if GhostReplay then
            GhostReplay:Initialize(gameId, self.games[gameId], game.opponent)
        end
    end
end

function PacManGame:OnStart(gameId)
    HopeAddon:Debug("PacManGame:OnStart", gameId)
    self:ShowUI(gameId)
    self:StartCountdown(gameId)
end

function PacManGame:OnUpdate(gameId, dt)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    if state.phase ~= "PLAYING" then return end

    state.gameTime = state.gameTime + dt
    self:UpdateModeTimer(gameId, dt)
    self:UpdatePowerTimer(gameId, dt)
    self:UpdateGhostRelease(gameId)
    self:UpdatePacMan(gameId, dt)
    self:UpdatePacManAnimation(gameId, dt)
    self:UpdateGhosts(gameId, dt)
    self:CheckCollisions(gameId)

    if state.pelletsRemaining == 0 then
        self:LevelComplete(gameId)
    end

    self:UpdateEntityPositions(gameId)

    -- Update ghost replay for score challenge mode
    if state.ghostReplay and state.ghostReplay.enabled then
        local GhostReplay = HopeAddon.GhostReplay
        if GhostReplay then
            GhostReplay:UpdateOutbound(gameId, dt)
            GhostReplay:UpdateReplay(gameId, dt)
        end
    end
end

function PacManGame:OnEnd(gameId, reason)
    HopeAddon:Debug("PacManGame:OnEnd", gameId, reason)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state

    if state.countdownTimer then
        state.countdownTimer:Cancel()
        state.countdownTimer = nil
    end

    -- Score challenge mode: let ScoreChallenge handle the result display
    if state.isScoreChallenge then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:OnLocalGameEnded(state.score, state.level, 0)
        end
        return  -- ScoreChallenge handles the result display
    end

    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        GameUI:ShowGameOver(gameId, nil, {
            ["Final Score"] = tostring(state.score),
            ["Level Reached"] = tostring(state.level),
        })
    end
end

function PacManGame:OnDestroy(gameId)
    self:CleanupGame(gameId)
end

--============================================================
-- CLEANUP
--============================================================

function PacManGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game then return end
    local ui = game.data.ui
    local state = game.data.state

    if state.countdownTimer then
        state.countdownTimer:Cancel()
        state.countdownTimer = nil
    end

    if state.levelCompleteTimer then
        state.levelCompleteTimer:Cancel()
        state.levelCompleteTimer = nil
    end

    -- Clean up ghost replay
    if state.ghostReplay then
        local GhostReplay = HopeAddon.GhostReplay
        if GhostReplay then
            GhostReplay:Cleanup(gameId)
        end
    end

    if ui.window then
        ui.window:SetScript("OnKeyDown", nil)
    end

    if ui.pacmanFrame then
        -- Clear texture references before orphaning
        ui.pacmanFrame.body = nil
        ui.pacmanFrame.mouthTop = nil
        ui.pacmanFrame.mouthBot = nil
        ui.pacmanFrame:Hide()
        ui.pacmanFrame:SetParent(nil)
        ui.pacmanFrame = nil
    end

    for _, ghostFrame in pairs(ui.ghostFrames) do
        self:DestroyGhostFrame(ghostFrame)
    end
    ui.ghostFrames = {}

    for row, rowCells in pairs(ui.cells) do
        for col, cell in pairs(rowCells) do
            if cell.bg then
                cell.bg:Hide()
                cell.bg = nil
            end
            if cell.pellet then
                cell.pellet:Hide()
                cell.pellet = nil
            end
        end
    end
    ui.cells = {}

    -- Release opponent panel (SCORE_CHALLENGE mode)
    if ui.opponentPanel then
        ui.opponentPanel:Hide()
        ui.opponentPanel:SetParent(nil)
        ui.opponentPanel = nil
    end

    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        GameUI:DestroyGameWindow(gameId)
    end

    self.games[gameId] = nil
end

--============================================================
-- UI
--============================================================

function PacManGame:ShowUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state
    local Maps = HopeAddon.PacManMaps
    local S = self.SETTINGS
    local GameUI = HopeAddon:GetModule("GameUI")

    -- Window - use larger size for score challenge mode
    local windowSize = state.isScoreChallenge and "PACMAN_CHALLENGE" or "PACMAN"
    local window = GameUI:CreateGameWindow(gameId, "PAC WOW", windowSize)
    ui.window = window
    local content = window.content

    -- Status bar (30px)
    local statusBar = CreateFrame("Frame", nil, content)
    statusBar:SetHeight(30)
    statusBar:SetPoint("TOPLEFT", 0, 0)
    statusBar:SetPoint("TOPRIGHT", 0, 0)

    -- Score
    local scoreLabel = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scoreLabel:SetPoint("LEFT", 10, 0)
    scoreLabel:SetText("SCORE")
    scoreLabel:SetTextColor(0.6, 0.6, 0.6)

    local scoreText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scoreText:SetPoint("LEFT", scoreLabel, "RIGHT", 5, 0)
    scoreText:SetText("0")
    scoreText:SetTextColor(1, 1, 1)
    ui.scoreText = scoreText

    -- Level
    local levelText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelText:SetPoint("CENTER", 0, 0)
    levelText:SetText("LEVEL 1")
    levelText:SetTextColor(1, 0.84, 0)
    ui.levelText = levelText

    -- Lives
    local livesContainer = CreateFrame("Frame", nil, statusBar)
    livesContainer:SetSize(60, 20)
    livesContainer:SetPoint("RIGHT", -10, 0)
    ui.livesContainer = livesContainer

    ui.lifeIcons = {}
    for i = 1, 3 do
        local lifeIcon = livesContainer:CreateTexture(nil, "ARTWORK")
        lifeIcon:SetSize(12, 12)
        lifeIcon:SetPoint("LEFT", (i - 1) * 18, 0)
        lifeIcon:SetColorTexture(COLORS.PACMAN.r, COLORS.PACMAN.g, COLORS.PACMAN.b, 1)
        ui.lifeIcons[i] = lifeIcon
    end

    -- Grid
    local gridWidth = Maps.GRID_WIDTH * S.CELL_SIZE
    local gridHeight = Maps.GRID_HEIGHT * S.CELL_SIZE
    local gridFrame = GameUI:CreatePlayArea(content, gridWidth, gridHeight)
    gridFrame:SetPoint("TOP", statusBar, "BOTTOM", 0, -10)
    ui.gridFrame = gridFrame

    -- Cells
    ui.cells = {}
    for row = 1, Maps.GRID_HEIGHT do
        ui.cells[row] = {}
        for col = 1, Maps.GRID_WIDTH do
            local cellData = {}

            local bg = gridFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetSize(S.CELL_SIZE - 1, S.CELL_SIZE - 1)
            bg:SetPoint("TOPLEFT", gridFrame, "TOPLEFT",
                (col - 1) * S.CELL_SIZE + 1,
                -((row - 1) * S.CELL_SIZE + 1))
            cellData.bg = bg

            local pellet = gridFrame:CreateTexture(nil, "ARTWORK", nil, 1)
            pellet:SetSize(4, 4)
            pellet:SetPoint("CENTER", bg, "CENTER", 0, 0)
            pellet:Hide()
            cellData.pellet = pellet

            ui.cells[row][col] = cellData
        end
    end

    self:RenderMaze(gameId)

    -- Pac-Man entity (circular with chomping mouth)
    local pacmanFrame = CreateFrame("Frame", nil, gridFrame)
    local size = S.CELL_SIZE - 2
    pacmanFrame:SetSize(size, size)
    pacmanFrame:SetFrameLevel(gridFrame:GetFrameLevel() + 10)

    -- Yellow circular body
    local body = pacmanFrame:CreateTexture(nil, "ARTWORK", nil, 1)
    body:SetAllPoints()
    body:SetColorTexture(COLORS.PACMAN.r, COLORS.PACMAN.g, COLORS.PACMAN.b, 1)

    -- Mouth (two black rectangles forming a wedge)
    local mouthTop = pacmanFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    mouthTop:SetSize(size * 0.55, size * 0.22)
    mouthTop:SetPoint("LEFT", pacmanFrame, "CENTER", 0, 1)
    mouthTop:SetColorTexture(0, 0, 0, 1)
    mouthTop:SetRotation(math.rad(-20))

    local mouthBot = pacmanFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    mouthBot:SetSize(size * 0.55, size * 0.22)
    mouthBot:SetPoint("LEFT", pacmanFrame, "CENTER", 0, -1)
    mouthBot:SetColorTexture(0, 0, 0, 1)
    mouthBot:SetRotation(math.rad(20))

    pacmanFrame.body = body
    pacmanFrame.mouthTop = mouthTop
    pacmanFrame.mouthBot = mouthBot
    ui.pacmanFrame = pacmanFrame

    -- Ghost entities (with rounded bodies, wavy bottoms, and expressive eyes)
    ui.ghostFrames = {}
    for _, ghost in ipairs(state.ghosts) do
        local ghostFrame = self:CreateGhostFrame(gridFrame, ghost.name, S.CELL_SIZE)
        ui.ghostFrames[ghost.name] = ghostFrame
    end

    self:UpdateEntityPositions(gameId)

    -- Opponent panel for SCORE_CHALLENGE mode
    local GameCore = HopeAddon:GetModule("GameCore")
    local coreGame = GameCore and GameCore:GetGame(gameId)
    if state.isScoreChallenge and coreGame then
        ui.opponentPanel = self:CreateOpponentPanel(content, coreGame.opponent)
        ui.opponentPanel:SetPoint("LEFT", gridFrame, "RIGHT", 15, 0)

        -- Create ghost replay visuals now that UI is ready
        local GhostReplay = HopeAddon.GhostReplay
        if GhostReplay and state.ghostReplay then
            GhostReplay:CreateVisuals(gameId)
        end
    end

    -- Countdown text
    local countdownText = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    countdownText:SetPoint("CENTER")
    countdownText:SetText("3")
    countdownText:SetTextColor(1, 0.84, 0)
    countdownText:Hide()
    ui.countdownText = countdownText

    -- Input
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", function(self, key)
        PacManGame:OnKeyDown(gameId, key)
    end)

    window:Show()
end

--[[
    Create opponent panel for Score Challenge mode
    @param parent Frame - Parent frame
    @param opponentName string - Opponent's name
    @return Frame - The opponent panel
]]
function PacManGame:CreateOpponentPanel(parent, opponentName)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(100, 130)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -8)
    title:SetText("VS: " .. (opponentName or "Opponent"))
    title:SetTextColor(1, 0.84, 0)

    local scoreLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scoreLabel:SetPoint("TOP", title, "BOTTOM", 0, -12)
    scoreLabel:SetText("Score")
    scoreLabel:SetTextColor(0.6, 0.6, 0.6)

    local scoreValue = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scoreValue:SetPoint("TOP", scoreLabel, "BOTTOM", 0, -2)
    scoreValue:SetText("0")
    panel.scoreValue = scoreValue

    local levelLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("TOP", scoreValue, "BOTTOM", 0, -10)
    levelLabel:SetText("Level")
    levelLabel:SetTextColor(0.6, 0.6, 0.6)

    local levelValue = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelValue:SetPoint("TOP", levelLabel, "BOTTOM", 0, -2)
    levelValue:SetText("1")
    panel.levelValue = levelValue

    local statusLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusLabel:SetPoint("TOP", levelValue, "BOTTOM", 0, -10)
    statusLabel:SetText("[PLAYING]")
    statusLabel:SetTextColor(0.2, 0.8, 0.2)
    panel.statusLabel = statusLabel

    return panel
end

--[[
    Update opponent panel with current stats
    @param gameId string - Game ID
    @param score number - Opponent's score
    @param level number - Opponent's level
    @param status string - "PLAYING" or "FINISHED"
]]
function PacManGame:UpdateOpponentPanel(gameId, score, level, status)
    local game = self.games[gameId]
    if not game or not game.data.ui.opponentPanel then return end

    local panel = game.data.ui.opponentPanel
    if panel.scoreValue then panel.scoreValue:SetText(tostring(score)) end
    if panel.levelValue then panel.levelValue:SetText(tostring(level)) end
    if panel.statusLabel then
        if status == "FINISHED" then
            panel.statusLabel:SetText("[FINISHED]")
            panel.statusLabel:SetTextColor(1, 0.5, 0)
        else
            panel.statusLabel:SetText("[PLAYING]")
            panel.statusLabel:SetTextColor(0.2, 0.8, 0.2)
        end
    end
end

function PacManGame:RenderMaze(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state
    local Maps = HopeAddon.PacManMaps

    for row = 1, Maps.GRID_HEIGHT do
        for col = 1, Maps.GRID_WIDTH do
            local cellType = state.map[row][col]
            local cell = ui.cells[row][col]

            if cellType == Maps.CELL.WALL then
                cell.bg:SetColorTexture(COLORS.WALL.r, COLORS.WALL.g, COLORS.WALL.b, 1)
                cell.pellet:Hide()
            elseif cellType == Maps.CELL.GHOST_HOUSE or cellType == Maps.CELL.GHOST_DOOR then
                cell.bg:SetColorTexture(0.05, 0.05, 0.1, 1)
                cell.pellet:Hide()
            else
                cell.bg:SetColorTexture(COLORS.PATH.r, COLORS.PATH.g, COLORS.PATH.b, 1)
                if cellType == Maps.CELL.PELLET then
                    cell.pellet:SetSize(4, 4)
                    cell.pellet:SetColorTexture(COLORS.PELLET.r, COLORS.PELLET.g, COLORS.PELLET.b, 1)
                    cell.pellet:Show()
                elseif cellType == Maps.CELL.POWER then
                    cell.pellet:SetSize(10, 10)
                    cell.pellet:SetColorTexture(COLORS.POWER.r, COLORS.POWER.g, COLORS.POWER.b, 1)
                    cell.pellet:Show()
                else
                    cell.pellet:Hide()
                end
            end
        end
    end
end

function PacManGame:UpdateEntityPositions(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state
    local S = self.SETTINGS

    if ui.pacmanFrame and ui.gridFrame then
        local pacman = state.pacman
        ui.pacmanFrame:ClearAllPoints()
        ui.pacmanFrame:SetPoint("TOPLEFT", ui.gridFrame, "TOPLEFT",
            (pacman.col - 1) * S.CELL_SIZE + 1,
            -((pacman.row - 1) * S.CELL_SIZE + 1))
    end

    for _, ghost in ipairs(state.ghosts) do
        local ghostFrame = ui.ghostFrames[ghost.name]
        if ghostFrame then
            ghostFrame:ClearAllPoints()
            ghostFrame:SetPoint("TOPLEFT", ui.gridFrame, "TOPLEFT",
                (ghost.col - 1) * S.CELL_SIZE + 1,
                -((ghost.row - 1) * S.CELL_SIZE + 1))

            -- Update ghost visual state (body, eyes, animation)
            self:UpdateGhostVisual(ghostFrame, ghost, state.powerTimer, self.SETTINGS.POWER_WARNING)
        end
    end
end

function PacManGame:UpdatePacManAnimation(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local pacman = state.pacman
    local pacmanFrame = game.data.ui.pacmanFrame
    if not pacmanFrame or not pacmanFrame.body then return end

    -- Accumulate time for smooth sine wave
    pacman.animTimer = pacman.animTimer + dt * PACMAN_ANIM.CHOMP_SPEED

    -- Calculate mouth angle using sine wave (0 to MAX_MOUTH_ANGLE)
    local mouthAngle = math.abs(math.sin(pacman.animTimer)) * PACMAN_ANIM.MAX_MOUTH_ANGLE
    local mouthRad = math.rad(mouthAngle)

    -- Get base rotation for current direction
    local dirRotation = math.rad(PACMAN_ANIM.DIR_ROTATION[pacman.direction] or 0)

    -- Apply rotation to mouth pieces
    pacmanFrame.mouthTop:SetRotation(dirRotation - mouthRad)
    pacmanFrame.mouthBot:SetRotation(dirRotation + mouthRad)

    -- Always show mouth pieces (animation handles opening)
    pacmanFrame.mouthTop:Show()
    pacmanFrame.mouthBot:Show()

    -- Reposition mouth anchors based on direction
    pacmanFrame.mouthTop:ClearAllPoints()
    pacmanFrame.mouthBot:ClearAllPoints()
    if pacman.direction == "RIGHT" then
        pacmanFrame.mouthTop:SetPoint("LEFT", pacmanFrame, "CENTER", 0, 1)
        pacmanFrame.mouthBot:SetPoint("LEFT", pacmanFrame, "CENTER", 0, -1)
    elseif pacman.direction == "LEFT" then
        pacmanFrame.mouthTop:SetPoint("RIGHT", pacmanFrame, "CENTER", 0, -1)
        pacmanFrame.mouthBot:SetPoint("RIGHT", pacmanFrame, "CENTER", 0, 1)
    elseif pacman.direction == "UP" then
        pacmanFrame.mouthTop:SetPoint("BOTTOM", pacmanFrame, "CENTER", -1, 0)
        pacmanFrame.mouthBot:SetPoint("BOTTOM", pacmanFrame, "CENTER", 1, 0)
    elseif pacman.direction == "DOWN" then
        pacmanFrame.mouthTop:SetPoint("TOP", pacmanFrame, "CENTER", 1, 0)
        pacmanFrame.mouthBot:SetPoint("TOP", pacmanFrame, "CENTER", -1, 0)
    end
end

--============================================================
-- INPUT & MOVEMENT
--============================================================

function PacManGame:OnKeyDown(gameId, key)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state

    local keyToDir = {
        ["UP"] = "UP", ["DOWN"] = "DOWN", ["LEFT"] = "LEFT", ["RIGHT"] = "RIGHT",
        ["W"] = "UP", ["S"] = "DOWN", ["A"] = "LEFT", ["D"] = "RIGHT",
    }

    local dir = keyToDir[key]
    if dir then
        state.pacman.nextDirection = dir
    end

    if key == "ESCAPE" then
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "CLOSED")
        end
    end
end

function PacManGame:GetNextCell(row, col, direction)
    if direction == "UP" then return row - 1, col
    elseif direction == "DOWN" then return row + 1, col
    elseif direction == "LEFT" then return row, col - 1
    elseif direction == "RIGHT" then return row, col + 1
    end
    return row, col
end

function PacManGame:UpdatePacMan(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local pacman = state.pacman
    local Maps = HopeAddon.PacManMaps
    local S = self.SETTINGS

    pacman.moveTimer = pacman.moveTimer + dt

    if pacman.moveTimer >= S.PACMAN_MOVE_INTERVAL then
        pacman.moveTimer = 0

        if pacman.nextDirection then
            local testRow, testCol = self:GetNextCell(pacman.row, pacman.col, pacman.nextDirection)
            testRow, testCol = Maps:WrapPosition(testRow, testCol)
            if Maps:IsWalkable(state.map, testRow, testCol) then
                pacman.direction = pacman.nextDirection
                pacman.nextDirection = nil
            end
        end

        local newRow, newCol = self:GetNextCell(pacman.row, pacman.col, pacman.direction)
        newRow, newCol = Maps:WrapPosition(newRow, newCol)

        if Maps:IsWalkable(state.map, newRow, newCol) then
            pacman.row = newRow
            pacman.col = newCol
            self:CollectPellet(gameId, newRow, newCol)
        end
    end
end

function PacManGame:CollectPellet(gameId, row, col)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local ui = game.data.ui
    local Maps = HopeAddon.PacManMaps
    local S = self.SETTINGS
    local cellType = state.map[row][col]

    if cellType == Maps.CELL.PELLET then
        state.score = state.score + S.POINTS_PELLET
        state.pelletsRemaining = state.pelletsRemaining - 1
        state.map[row][col] = Maps.CELL.PATH
        if ui.cells[row] and ui.cells[row][col] then
            ui.cells[row][col].pellet:Hide()
        end
        self:UpdateScoreDisplay(gameId)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end

        -- Record pellet for ghost replay
        if state.ghostReplay and state.ghostReplay.enabled then
            local GhostReplay = HopeAddon.GhostReplay
            if GhostReplay then
                GhostReplay:RecordPellet(gameId, row, col, false)
            end
        end

    elseif cellType == Maps.CELL.POWER then
        state.score = state.score + S.POINTS_POWER
        state.pelletsRemaining = state.pelletsRemaining - 1
        state.map[row][col] = Maps.CELL.PATH
        if ui.cells[row] and ui.cells[row][col] then
            ui.cells[row][col].pellet:Hide()
        end
        self:FrightenGhosts(gameId)
        self:UpdateScoreDisplay(gameId)
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayAchievement() end

        -- Record power pellet for ghost replay (sends immediately)
        if state.ghostReplay and state.ghostReplay.enabled then
            local GhostReplay = HopeAddon.GhostReplay
            if GhostReplay then
                GhostReplay:RecordPellet(gameId, row, col, true)
            end
        end
    end

    if not state.extraLifeAwarded and state.score >= S.EXTRA_LIFE_SCORE then
        state.extraLifeAwarded = true
        state.lives = state.lives + 1
        self:UpdateLivesDisplay(gameId)
    end
end

function PacManGame:UpdateScoreDisplay(gameId)
    local game = self.games[gameId]
    if not game then return end
    local ui = game.data.ui
    local state = game.data.state
    if ui.scoreText then ui.scoreText:SetText(tostring(state.score)) end
    if ui.levelText then ui.levelText:SetText("LEVEL " .. state.level) end

    -- Score challenge: send score update to ScoreChallenge system
    if state.isScoreChallenge then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            ScoreChallenge:UpdateMyScore(state.score, state.level, 0)
        end
    end
end

function PacManGame:UpdateLivesDisplay(gameId)
    local game = self.games[gameId]
    if not game then return end
    local ui = game.data.ui
    local state = game.data.state
    for i = 1, 3 do
        if ui.lifeIcons[i] then
            if i <= state.lives then ui.lifeIcons[i]:Show() else ui.lifeIcons[i]:Hide() end
        end
    end
end

function PacManGame:StartCountdown(gameId)
    local game = self.games[gameId]
    if not game then return end
    local ui = game.data.ui
    local state = game.data.state

    state.countdown = 3
    state.phase = "READY"
    if ui.countdownText then
        ui.countdownText:SetText("3")
        ui.countdownText:Show()
    end

    local function tick()
        local g = self.games[gameId]
        if not g then return end
        local s = g.data.state
        local u = g.data.ui

        s.countdown = s.countdown - 1
        if s.countdown > 0 then
            if u.countdownText then u.countdownText:SetText(tostring(s.countdown)) end
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayClick() end
            s.countdownTimer = HopeAddon.Timer:After(1, tick)
        else
            s.countdownTimer = nil
            if u.countdownText then u.countdownText:Hide() end
            if HopeAddon.Sounds then HopeAddon.Sounds:PlayAchievement() end
            s.phase = "PLAYING"
        end
    end

    state.countdownTimer = HopeAddon.Timer:After(1, tick)
end

--============================================================
-- GHOST AI & POWER-UPS
--============================================================

function PacManGame:UpdateGhosts(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local Maps = HopeAddon.PacManMaps
    local GhostAI = HopeAddon.PacManGhostAI
    local S = self.SETTINGS
    local blinky = state.ghosts[1]

    -- Get level-adjusted settings for difficulty scaling
    local levelSettings = self:GetLevelSettings(state.level)

    for _, ghost in ipairs(state.ghosts) do
        if ghost.released then
            local moveInterval = levelSettings.ghostMoveInterval
            if ghost.mode == "FRIGHTENED" then moveInterval = levelSettings.frightenedMoveInterval
            elseif ghost.mode == "EATEN" then moveInterval = S.EATEN_MOVE_INTERVAL end

            ghost.moveTimer = ghost.moveTimer + dt

            if ghost.moveTimer >= moveInterval then
                ghost.moveTimer = 0
                local targetRow, targetCol

                if ghost.mode == "FRIGHTENED" then
                    ghost.direction = GhostAI:ChooseFrightenedDirection(ghost, state.map)
                elseif ghost.mode == "EATEN" then
                    local spawn = Maps.GHOST_SPAWNS[ghost.name]
                    targetRow, targetCol = spawn.row, spawn.col
                    ghost.direction = GhostAI:ChooseDirection(ghost, targetRow, targetCol, state.map, true)
                    if ghost.row == targetRow and ghost.col == targetCol then
                        ghost.mode = state.currentMode
                    end
                elseif ghost.mode == "SCATTER" then
                    local scatter = Maps.SCATTER_TARGETS[ghost.name]
                    targetRow, targetCol = scatter.row, scatter.col
                    ghost.direction = GhostAI:ChooseDirection(ghost, targetRow, targetCol, state.map, false)
                else
                    if ghost.name == "BLINKY" then
                        targetRow, targetCol = GhostAI:GetBlinkyTarget(state.pacman)
                    elseif ghost.name == "PINKY" then
                        targetRow, targetCol = GhostAI:GetPinkyTarget(state.pacman)
                    elseif ghost.name == "INKY" then
                        targetRow, targetCol = GhostAI:GetInkyTarget(state.pacman, blinky)
                    elseif ghost.name == "CLYDE" then
                        targetRow, targetCol = GhostAI:GetClydeTarget(state.pacman, ghost, Maps.SCATTER_TARGETS.CLYDE)
                    end
                    ghost.direction = GhostAI:ChooseDirection(ghost, targetRow, targetCol, state.map, false)
                end

                local newRow, newCol = self:GetNextCell(ghost.row, ghost.col, ghost.direction)
                newRow, newCol = Maps:WrapPosition(newRow, newCol)
                local canEnterHouse = ghost.mode == "EATEN"
                if Maps:IsGhostWalkable(state.map, newRow, newCol, canEnterHouse) then
                    ghost.row = newRow
                    ghost.col = newCol
                end
            end
        end
    end
end

function PacManGame:FrightenGhosts(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state

    -- Get level-adjusted power duration
    local levelSettings = self:GetLevelSettings(state.level)
    state.powerTimer = levelSettings.powerDuration
    state.ghostsEatenThisPower = 0

    local opposite = { UP = "DOWN", DOWN = "UP", LEFT = "RIGHT", RIGHT = "LEFT" }
    for _, ghost in ipairs(state.ghosts) do
        if ghost.released and ghost.mode ~= "EATEN" then
            ghost.direction = opposite[ghost.direction] or ghost.direction
            ghost.mode = "FRIGHTENED"
        end
    end
end

function PacManGame:UpdatePowerTimer(gameId, dt)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state

    if state.powerTimer > 0 then
        state.powerTimer = state.powerTimer - dt
        if state.powerTimer <= 0 then
            for _, ghost in ipairs(state.ghosts) do
                if ghost.mode == "FRIGHTENED" then
                    ghost.mode = state.currentMode
                end
            end
            state.ghostsEatenThisPower = 0
        end
    end
end

function PacManGame:UpdateModeTimer(gameId, dt)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    local S = self.SETTINGS

    state.modeTimer = state.modeTimer + dt
    local currentPhase = S.MODE_SEQUENCE[state.modePhase]

    if currentPhase and state.modeTimer >= currentPhase.duration then
        state.modeTimer = 0
        state.modePhase = state.modePhase + 1
        local nextPhase = S.MODE_SEQUENCE[state.modePhase]
        if nextPhase then
            state.currentMode = nextPhase.mode
            local opposite = { UP = "DOWN", DOWN = "UP", LEFT = "RIGHT", RIGHT = "LEFT" }
            for _, ghost in ipairs(state.ghosts) do
                if ghost.mode ~= "FRIGHTENED" and ghost.mode ~= "EATEN" and ghost.mode ~= "HOUSE" then
                    ghost.direction = opposite[ghost.direction] or ghost.direction
                    ghost.mode = state.currentMode
                end
            end
        end
    end
end

function PacManGame:UpdateGhostRelease(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    local S = self.SETTINGS

    for _, ghost in ipairs(state.ghosts) do
        if not ghost.released then
            local releaseTime = S.GHOST_RELEASE[ghost.name]
            if state.gameTime >= releaseTime then
                ghost.released = true
                ghost.mode = state.currentMode
            end
        end
    end
end

--============================================================
-- COLLISION & GAME FLOW
--============================================================

function PacManGame:CheckCollisions(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    local pacman = state.pacman
    local S = self.SETTINGS

    for _, ghost in ipairs(state.ghosts) do
        if ghost.released and ghost.row == pacman.row and ghost.col == pacman.col then
            if ghost.mode == "FRIGHTENED" then
                ghost.mode = "EATEN"
                state.ghostsEatenThisPower = state.ghostsEatenThisPower + 1
                local points = S.POINTS_GHOST[state.ghostsEatenThisPower] or 1600
                state.score = state.score + points
                self:UpdateScoreDisplay(gameId)
                if HopeAddon.Sounds then HopeAddon.Sounds:PlayAchievement() end
            elseif ghost.mode ~= "EATEN" then
                self:PacManDeath(gameId)
                return
            end
        end
    end
end

function PacManGame:PacManDeath(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state

    state.lives = state.lives - 1
    self:UpdateLivesDisplay(gameId)

    if state.lives <= 0 then
        state.phase = "GAME_OVER"
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then GameCore:EndGame(gameId, "GAME_OVER") end
    else
        self:Respawn(gameId)
    end
end

function PacManGame:Respawn(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    local Maps = HopeAddon.PacManMaps

    state.pacman.row = Maps.PACMAN_SPAWN.row
    state.pacman.col = Maps.PACMAN_SPAWN.col
    state.pacman.direction = "LEFT"
    state.pacman.nextDirection = nil
    state.pacman.moveTimer = 0

    for i, ghost in ipairs(state.ghosts) do
        local spawn = Maps.GHOST_SPAWNS[ghost.name]
        ghost.row = spawn.row
        ghost.col = spawn.col
        ghost.mode = (i == 1) and "SCATTER" or "HOUSE"
        ghost.released = (i == 1)
        ghost.moveTimer = 0
    end

    state.powerTimer = 0
    state.ghostsEatenThisPower = 0
    self:StartCountdown(gameId)
end

function PacManGame:LevelComplete(gameId)
    local game = self.games[gameId]
    if not game then return end
    local state = game.data.state
    local ui = game.data.ui
    local Maps = HopeAddon.PacManMaps

    state.phase = "LEVEL_COMPLETE"
    state.level = state.level + 1
    if HopeAddon.Sounds then HopeAddon.Sounds:PlayAchievement() end

    state.levelCompleteTimer = HopeAddon.Timer:After(2, function()
        local g = self.games[gameId]
        if not g then return end
        local s = g.data.state
        local u = g.data.ui

        s.map = Maps:ParseMap(Maps.CLASSIC)
        s.pelletsRemaining = Maps:CountPellets(s.map)
        s.modeTimer = 0
        s.modePhase = 1
        s.currentMode = "SCATTER"
        s.gameTime = 0

        -- Reset ghost replay state for new level
        if s.ghostReplay then
            local GhostReplay = HopeAddon.GhostReplay
            if GhostReplay then
                GhostReplay:ResetPelletOverlays(s.ghostReplay, u)
            end
        end

        self:Respawn(gameId)
        self:RenderMaze(gameId)
    end)
end

--============================================================
-- MODULE REGISTRATION
--============================================================

HopeAddon:RegisterModule("PacManGame", PacManGame)
HopeAddon:Debug("PacManGame module loaded")
