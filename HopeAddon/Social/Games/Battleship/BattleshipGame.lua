--[[
    HopeAddon Battleship Game
    Main game controller with UI and network integration
]]

local BattleshipGame = {}

-- Use centralized backdrop frame creation
local function CreateBackdropFrame(frameType, name, parent, additionalTemplate)
    return HopeAddon:CreateBackdropFrame(frameType, name, parent, additionalTemplate)
end

--============================================================
-- CONSTANTS
--============================================================

local CELL_SIZE = 26
local GRID_PADDING = 10
local HEADER_HEIGHT = 30
local CENTER_GAP = 20  -- Space between the two grids
local TOP_ANNOUNCEMENT_HEIGHT = 80  -- Shot result area at top
local BOTTOM_STATUS_HEIGHT = 70     -- Turn status bar at bottom
local SECTION_GAP = 10              -- Vertical gap between UI sections

-- Colors
local COLORS = {
    WATER = { r = 0.1, g = 0.3, b = 0.5 },
    WATER_HOVER = { r = 0.15, g = 0.4, b = 0.6 },
    SHIP = { r = 0.4, g = 0.4, b = 0.4 },
    HIT = { r = 0.8, g = 0.2, b = 0.2 },
    MISS = { r = 0.3, g = 0.3, b = 0.5 },
    SUNK = { r = 0.5, g = 0.1, b = 0.1 },
    VALID_PLACEMENT = { r = 0.2, g = 0.6, b = 0.2 },
    INVALID_PLACEMENT = { r = 0.6, g = 0.2, b = 0.2 },
    GRID_LINES = { r = 0.3, g = 0.4, b = 0.5 },
    PREVIEW_VALID = { r = 0.2, g = 0.8, b = 0.2 },
    PREVIEW_INVALID = { r = 0.8, g = 0.2, b = 0.2 },
}

-- Error messages for placement failures
local PLACEMENT_ERRORS = {
    OUT_OF_BOUNDS = "Ship doesn't fit! Press R to rotate or click closer to center.",
    OVERLAP = "Ships can't overlap! Choose empty cells.",
    INVALID_SHIP = "Invalid ship selection.",
}

--============================================================
-- MODULE STATE
--============================================================

BattleshipGame.games = {}  -- Active games by gameId

--============================================================
-- LIFECYCLE
--============================================================

function BattleshipGame:OnInitialize()
    HopeAddon:Debug("BattleshipGame initializing...")
end

function BattleshipGame:OnEnable()
    -- Register with GameCore
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:RegisterGame(GameCore.GAME_TYPE.BATTLESHIP, self)
    end

    -- Register network handlers
    self:RegisterNetworkHandlers()

    HopeAddon:Debug("BattleshipGame enabled")
end

function BattleshipGame:OnDisable()
    -- Unregister network handlers to prevent handler accumulation on /reload
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:UnregisterHandler("BATTLESHIP", "MOVE")
        GameComms:UnregisterHandler("BATTLESHIP", "STATE")
        GameComms:UnregisterHandler("BATTLESHIP", "END")
    end

    -- Cleanup all games
    for gameId in pairs(self.games) do
        self:CleanupGame(gameId)
    end
    self.games = {}
end

--============================================================
-- GAMECORE CALLBACKS
--============================================================

function BattleshipGame:OnCreate(gameId, game)
    HopeAddon:Debug("BattleshipGame:OnCreate", gameId)

    local Board = HopeAddon.BattleshipBoard
    local AI = HopeAddon.BattleshipAI
    local GameCore = HopeAddon:GetModule("GameCore")

    local isLocalGame = game.mode == GameCore.GAME_MODE.LOCAL

    self.games[gameId] = {
        data = {
            ui = {
                window = nil,
                playerGrid = nil,
                enemyGrid = nil,
                statusText = nil,
                shipButtons = {},
                cells = { player = {}, enemy = {} },
            },
            state = {
                phase = "PLACEMENT",  -- PLACEMENT, WAITING_OPPONENT, PLAYING, ENDED
                playerBoard = Board:Create(),
                enemyBoard = Board:Create(),
                currentTurn = nil,  -- "player" or "enemy"
                placementOrientation = Board.ORIENTATION.HORIZONTAL,
                isLocalGame = isLocalGame,
                aiState = nil,
                winner = nil,
                -- Network-specific state
                playerReady = false,
                opponentReady = isLocalGame,  -- AI is always ready
                isChallenger = (game.player1 == UnitName("player")),
                sunkEnemyShips = 0,
            },
        },
    }

    local gameData = self.games[gameId]

    -- For local games, set up AI
    if isLocalGame then
        gameData.data.state.aiState = AI:Create()
        -- AI places ships immediately
        AI:PlaceShips(gameData.data.state.enemyBoard)
    end
end

function BattleshipGame:OnStart(gameId)
    HopeAddon:Debug("BattleshipGame:OnStart", gameId)

    local gameData = self.games[gameId]
    if not gameData then return end

    -- Show UI
    self:ShowUI(gameId)
end

function BattleshipGame:OnUpdate(gameId, dt)
    -- Battleship is turn-based, minimal update needed
    -- Could add animations here later
end

function BattleshipGame:OnEnd(gameId, reason)
    HopeAddon:Debug("BattleshipGame:OnEnd", gameId, reason)

    local gameData = self.games[gameId]
    if not gameData then return end

    gameData.data.state.phase = "ENDED"

    -- Hide old status text
    if gameData.data.ui.statusText then
        gameData.data.ui.statusText:SetText("")
    end

    -- Show gameshow victory/defeat overlay
    local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
    if BattleshipUI then
        local didWin = gameData.data.state.winner == "player"
        local stats = {
            shipsRemaining = HopeAddon.BattleshipBoard:GetShipsRemaining(gameData.data.state.playerBoard),
            shotsFired = gameData.data.state.shotsFired or 0,
        }
        BattleshipUI:ShowVictoryOverlay(gameId, didWin, stats)
    else
        -- Fallback to simple text
        if gameData.data.ui.statusText then
            local winner = gameData.data.state.winner
            if winner == "player" then
                gameData.data.ui.statusText:SetText("|cFF00FF00VICTORY!|r All enemy ships destroyed!")
            elseif winner == "enemy" then
                gameData.data.ui.statusText:SetText("|cFFFF0000DEFEAT!|r Your fleet was destroyed!")
            else
                gameData.data.ui.statusText:SetText("Game ended: " .. (reason or "unknown"))
            end
        end

        -- Play sound (fallback)
        if HopeAddon.Sounds then
            if gameData.data.state.winner == "player" then
                HopeAddon.Sounds:PlayAchievement()
            else
                HopeAddon.Sounds:PlayError()
            end
        end
    end
end

function BattleshipGame:OnDestroy(gameId)
    HopeAddon:Debug("BattleshipGame:OnDestroy", gameId)
    self:CleanupGame(gameId)
end

--============================================================
-- GAME LOGIC
--============================================================

function BattleshipGame:StartPlaying(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state

    -- Hide rotate button during combat
    if gameData.data.ui.rotateBtn then
        gameData.data.ui.rotateBtn:Hide()
    end

    if state.isLocalGame then
        -- Local: Random first turn
        state.currentTurn = math.random() < 0.5 and "player" or "enemy"
    else
        -- Network: Challenger goes first
        state.currentTurn = state.isChallenger and "player" or "enemy"
    end

    state.phase = "PLAYING"
    self:UpdateUI(gameId)
    self:UpdateStatus(gameId)

    -- Announce turn
    if state.currentTurn == "player" then
        HopeAddon:Print("|cFF00FF00Your turn!|r Click enemy grid or use /fire <coord> (e.g., /fire A5)")
    else
        if state.isLocalGame then
            -- AI turn with delay
            HopeAddon.Timer:After(0.8, function()
                if self.games[gameId] and self.games[gameId].data.state.phase == "PLAYING" then
                    self:AITurn(gameId)
                end
            end)
        else
            HopeAddon:Print("|cFFFFFF00Waiting for opponent's shot...|r")
        end
    end
end

function BattleshipGame:PlayerShoot(gameId, row, col)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    -- Validate it's player's turn
    if state.phase ~= "PLAYING" or state.currentTurn ~= "player" then
        HopeAddon:Print("It's not your turn!")
        return
    end

    -- Check if already shot here (tracking board)
    if Board:IsShot(state.enemyBoard, row, col) then
        HopeAddon:Print("Already shot at " .. Board:FormatCoord(row, col) .. "!")
        return
    end

    if state.isLocalGame then
        -- LOCAL MODE: Process immediately against AI board
        local result = Board:FireShot(state.enemyBoard, row, col)

        if result.error then
            HopeAddon:Print(result.error)
            return
        end

        -- Track shots for stats
        state.shotsFired = (state.shotsFired or 0) + 1

        -- Update UI
        self:UpdateEnemyCell(gameId, row, col, result)

        -- Show gameshow shot result animation
        local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
        local coord = Board:FormatCoord(row, col)
        if BattleshipUI then
            local resultType = result.sunk and "SUNK" or (result.hit and "HIT" or "MISS")
            BattleshipUI:ShowShotResult(gameId, resultType, coord, result.shipName, true)

            -- Show ship sunk celebration
            if result.sunk then
                BattleshipUI:ShowShipSunkCelebration(gameId, result.shipName, true)
            end
        else
            -- Fallback to simple sound
            if HopeAddon.Sounds then
                if result.hit then
                    HopeAddon.Sounds:PlayBell()
                    if result.sunk then
                        HopeAddon:Print("|cFFFF0000" .. result.shipName .. " SUNK!|r")
                    end
                else
                    HopeAddon.Sounds:PlayClick()
                end
            end
        end

        -- Check for win
        if Board:AllShipsSunk(state.enemyBoard) then
            state.winner = "player"
            local GameCore = HopeAddon:GetModule("GameCore")
            if GameCore then
                GameCore:EndGame(gameId, "WIN")
            end
            return
        end

        -- Switch turns after animation
        state.currentTurn = "enemy"

        -- Delay AI turn to let animation play
        local animDelay = BattleshipUI and BattleshipUI:GetAnimationDuration() or 0.8
        HopeAddon.Timer:After(animDelay + 0.3, function()
            if self.games[gameId] and self.games[gameId].data.state.phase == "PLAYING" then
                self:UpdateStatus(gameId)
                self:AITurn(gameId)
            end
        end)
    else
        -- NETWORK MODE: Send shot and wait for result
        self:SendShot(gameId, row, col)

        -- Visual feedback that shot is pending
        HopeAddon:Print("Firing at " .. Board:FormatCoord(row, col) .. "...")

        -- Switch to waiting state
        state.currentTurn = "waiting"
        self:UpdateStatus(gameId)
    end
end

function BattleshipGame:AITurn(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard
    local AI = HopeAddon.BattleshipAI

    if state.currentTurn ~= "enemy" or not state.aiState then
        return
    end

    -- Get AI's shot
    local row, col = AI:GetNextShot(state.aiState, state.playerBoard)

    -- Fire shot at player board
    local result = Board:FireShot(state.playerBoard, row, col)

    -- Process result for AI learning
    AI:ProcessResult(state.aiState, row, col, result)

    -- Update UI
    self:UpdatePlayerCell(gameId, row, col, result)

    -- Show gameshow shot result animation
    local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
    local coord = Board:FormatCoord(row, col)
    if BattleshipUI then
        local resultType = result.sunk and "SUNK" or (result.hit and "HIT" or "MISS")
        BattleshipUI:ShowShotResult(gameId, resultType, coord, result.shipName, false)

        -- Show ship sunk effect for player ship
        if result.sunk then
            BattleshipUI:ShowShipSunkCelebration(gameId, result.shipName, false)
            HopeAddon:Print("|cFFFF8800Your " .. result.shipName .. " was destroyed!|r")
        end
    else
        -- Fallback to simple sound
        if HopeAddon.Sounds then
            if result.hit then
                HopeAddon.Sounds:PlayError()
                if result.sunk then
                    HopeAddon:Print("|cFFFF8800Your " .. result.shipName .. " was sunk!|r")
                end
            else
                HopeAddon.Sounds:PlayClick()
            end
        end
    end

    -- Check for loss
    if Board:AllShipsSunk(state.playerBoard) then
        state.winner = "enemy"
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "LOSS")
        end
        return
    end

    -- Switch turns after animation delay
    state.currentTurn = "player"
    local animDelay = BattleshipUI and BattleshipUI:GetAnimationDuration() or 0.8
    HopeAddon.Timer:After(animDelay, function()
        if self.games[gameId] and self.games[gameId].data.state.phase == "PLAYING" then
            self:UpdateStatus(gameId)
        end
    end)
end

--============================================================
-- SHIP PLACEMENT
--============================================================

function BattleshipGame:PlaceShip(gameId, row, col)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    if state.phase ~= "PLACEMENT" then return end

    local nextShip = Board:GetNextShipToPlace(state.playerBoard)
    if not nextShip then return end

    local orientation = state.placementOrientation

    -- Check if placement is valid and get error reason
    local canPlace, errorReason = Board:CanPlaceShip(state.playerBoard, nextShip.id, row, col, orientation)

    if canPlace then
        -- Place the ship
        Board:PlaceShip(state.playerBoard, nextShip.id, row, col, orientation)

        -- Update UI
        self:UpdatePlayerGrid(gameId)

        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayClick()
        end

        -- Check if all ships placed
        if Board:AllShipsPlaced(state.playerBoard) then
            self:StartPlaying(gameId)
        else
            self:UpdateStatus(gameId)
        end
    else
        -- Show error message
        self:ShowError(gameId, errorReason)

        if HopeAddon.Sounds then
            HopeAddon.Sounds:PlayError()
        end
    end
end

function BattleshipGame:ToggleOrientation(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    if state.placementOrientation == Board.ORIENTATION.HORIZONTAL then
        state.placementOrientation = Board.ORIENTATION.VERTICAL
    else
        state.placementOrientation = Board.ORIENTATION.HORIZONTAL
    end

    self:UpdateStatus(gameId)
end

--============================================================
-- UI CREATION
--============================================================

function BattleshipGame:ShowError(gameId, errorType)
    local gameData = self.games[gameId]
    if not gameData or not gameData.data.ui.errorText then return end

    local message = PLACEMENT_ERRORS[errorType] or "Invalid placement!"
    gameData.data.ui.errorText:SetText(message)

    -- Clear error after 3 seconds
    HopeAddon.Timer:After(3, function()
        if gameData.data.ui.errorText then
            gameData.data.ui.errorText:SetText("")
        end
    end)
end

function BattleshipGame:ShowUI(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    -- Create game window
    local window = GameUI:CreateGameWindow(gameId, "BATTLESHIP")
    gameData.data.ui.window = window

    -- Set title
    if window.title then
        window.title:SetText(HopeAddon:ColorText("BATTLESHIP", "SKY_BLUE"))
    end

    -- Create content area
    local content = CreateFrame("Frame", nil, window)
    content:SetPoint("TOPLEFT", window, "TOPLEFT", 10, -50)
    content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, 40)

    -- Initialize shot counter for stats
    gameData.data.state.shotsFired = 0

    -- Create TOP ANNOUNCEMENT AREA for shot results (HIT!/MISS!/SUNK!)
    local topAnnouncement = CreateFrame("Frame", nil, content)
    topAnnouncement:SetHeight(TOP_ANNOUNCEMENT_HEIGHT)
    topAnnouncement:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    topAnnouncement:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    -- Subtle background
    local topBg = topAnnouncement:CreateTexture(nil, "BACKGROUND")
    topBg:SetAllPoints()
    topBg:SetColorTexture(0.05, 0.1, 0.15, 0.5)
    gameData.data.ui.topAnnouncement = topAnnouncement

    -- Create BOTTOM STATUS BAR for turn info and instructions
    local bottomStatus = CreateBackdropFrame("Frame", nil, content)
    bottomStatus:SetHeight(BOTTOM_STATUS_HEIGHT)
    bottomStatus:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
    bottomStatus:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    bottomStatus:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    bottomStatus:SetBackdropColor(0.1, 0.15, 0.2, 0.95)
    bottomStatus:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)
    gameData.data.ui.bottomStatus = bottomStatus

    -- Turn indicator text (large, centered)
    local turnText = bottomStatus:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    turnText:SetPoint("TOP", bottomStatus, "TOP", 0, -12)
    gameData.data.ui.turnText = turnText

    -- Context hint text (smaller, below turn text)
    local hintText = bottomStatus:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hintText:SetPoint("TOP", turnText, "BOTTOM", 0, -4)
    hintText:SetTextColor(0.7, 0.7, 0.7)
    gameData.data.ui.hintText = hintText

    -- Initialize gameshow UI frames for shot results
    local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
    if BattleshipUI then
        BattleshipUI:InitializeGameFrames(gameId, topAnnouncement, bottomStatus)
    end

    -- Create grids container (between top announcement and bottom status)
    local gridsContainer = CreateFrame("Frame", nil, content)
    gridsContainer:SetPoint("TOPLEFT", topAnnouncement, "BOTTOMLEFT", 0, -SECTION_GAP)
    gridsContainer:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    gridsContainer:SetPoint("BOTTOM", bottomStatus, "TOP", 0, SECTION_GAP)
    gameData.data.ui.gridsContainer = gridsContainer

    -- Create grids side by side
    self:CreatePlayerGrid(gameId, gridsContainer)
    self:CreateEnemyGrid(gameId, gridsContainer)

    -- Error message text (above bottom status bar)
    local errorText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    errorText:SetPoint("BOTTOM", bottomStatus, "TOP", 0, 5)
    errorText:SetTextColor(1, 0.3, 0.3)
    errorText:SetText("")
    gameData.data.ui.errorText = errorText

    -- Rotate button for placement (inside bottom status bar)
    local rotateBtn = CreateFrame("Button", nil, bottomStatus, "UIPanelButtonTemplate")
    rotateBtn:SetSize(80, 22)
    rotateBtn:SetPoint("BOTTOMRIGHT", bottomStatus, "BOTTOMRIGHT", -10, 8)
    rotateBtn:SetText("Rotate (R)")
    rotateBtn:SetScript("OnClick", function()
        self:ToggleOrientation(gameId)
    end)
    rotateBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Rotate Ship", 1, 0.82, 0)
        GameTooltip:AddLine("Toggle between horizontal and vertical", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Keyboard shortcut: R", 0.5, 0.8, 0.5)
        GameTooltip:Show()
        if HopeAddon.Sounds then HopeAddon.Sounds:PlayHover() end
    end)
    rotateBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    gameData.data.ui.rotateBtn = rotateBtn

    -- Keyboard handler for R key
    window:SetScript("OnKeyDown", function(self, key)
        if key == "R" then
            BattleshipGame:ToggleOrientation(gameId)
        elseif key == "ESCAPE" then
            local GameCore = HopeAddon:GetModule("GameCore")
            if GameCore then
                GameCore:EndGame(gameId, "CLOSED")
            end
        end
    end)
    window:EnableKeyboard(true)
    window:SetPropagateKeyboardInput(false)

    window:Show()

    self:UpdateUI(gameId)
    self:UpdateStatus(gameId)
end

function BattleshipGame:CreatePlayerGrid(gameId, parent)
    local gameData = self.games[gameId]
    if not gameData then return end

    local Board = HopeAddon.BattleshipBoard

    -- Grid container
    local gridFrame = CreateFrame("Frame", nil, parent)
    local gridWidth = (Board.GRID_SIZE + 1) * CELL_SIZE
    local gridHeight = (Board.GRID_SIZE + 1) * CELL_SIZE + HEADER_HEIGHT
    gridFrame:SetSize(gridWidth, gridHeight)
    -- Anchor to center-right so there's a gap between grids
    gridFrame:SetPoint("RIGHT", parent, "CENTER", -CENTER_GAP/2, 0)
    gameData.data.ui.playerGrid = gridFrame

    -- Header
    local header = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOP", gridFrame, "TOP", 0, 0)
    header:SetText("YOUR FLEET")
    header:SetTextColor(0.8, 0.8, 0.8)

    -- Column labels (A-J)
    for col = 1, Board.GRID_SIZE do
        local label = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * CELL_SIZE + CELL_SIZE/2 - 4, -HEADER_HEIGHT)
        label:SetText(Board:ColToLetter(col))
        label:SetTextColor(0.7, 0.7, 0.7)
    end

    -- Row labels (1-10) and cells
    gameData.data.ui.cells.player = {}
    for row = 1, Board.GRID_SIZE do
        local rowLabel = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", CELL_SIZE/2 - 4, -(HEADER_HEIGHT + row * CELL_SIZE - CELL_SIZE/2 + 4))
        rowLabel:SetText(tostring(row))
        rowLabel:SetTextColor(0.7, 0.7, 0.7)

        gameData.data.ui.cells.player[row] = {}
        for col = 1, Board.GRID_SIZE do
            local cell = self:CreateCell(gridFrame, row, col, true, gameId)
            cell:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * CELL_SIZE, -(HEADER_HEIGHT + row * CELL_SIZE))
            gameData.data.ui.cells.player[row][col] = cell
        end
    end
end

function BattleshipGame:CreateEnemyGrid(gameId, parent)
    local gameData = self.games[gameId]
    if not gameData then return end

    local Board = HopeAddon.BattleshipBoard

    -- Grid container
    local gridFrame = CreateFrame("Frame", nil, parent)
    local gridWidth = (Board.GRID_SIZE + 1) * CELL_SIZE
    local gridHeight = (Board.GRID_SIZE + 1) * CELL_SIZE + HEADER_HEIGHT
    gridFrame:SetSize(gridWidth, gridHeight)
    -- Anchor to center-left so there's a gap between grids
    gridFrame:SetPoint("LEFT", parent, "CENTER", CENTER_GAP/2, 0)
    gameData.data.ui.enemyGrid = gridFrame

    -- Header
    local header = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOP", gridFrame, "TOP", 0, 0)
    header:SetText("ENEMY WATERS")
    header:SetTextColor(0.8, 0.8, 0.8)

    -- Column labels (A-J)
    for col = 1, Board.GRID_SIZE do
        local label = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * CELL_SIZE + CELL_SIZE/2 - 4, -HEADER_HEIGHT)
        label:SetText(Board:ColToLetter(col))
        label:SetTextColor(0.7, 0.7, 0.7)
    end

    -- Row labels (1-10) and cells
    gameData.data.ui.cells.enemy = {}
    for row = 1, Board.GRID_SIZE do
        local rowLabel = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", CELL_SIZE/2 - 4, -(HEADER_HEIGHT + row * CELL_SIZE - CELL_SIZE/2 + 4))
        rowLabel:SetText(tostring(row))
        rowLabel:SetTextColor(0.7, 0.7, 0.7)

        gameData.data.ui.cells.enemy[row] = {}
        for col = 1, Board.GRID_SIZE do
            local cell = self:CreateCell(gridFrame, row, col, false, gameId)
            cell:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * CELL_SIZE, -(HEADER_HEIGHT + row * CELL_SIZE))
            gameData.data.ui.cells.enemy[row][col] = cell
        end
    end
end

function BattleshipGame:CreateCell(parent, row, col, isPlayerGrid, gameId)
    local cell = CreateFrame("Button", nil, parent)
    cell:SetSize(CELL_SIZE - 2, CELL_SIZE - 2)

    -- Background texture
    local bg = cell:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(COLORS.WATER.r, COLORS.WATER.g, COLORS.WATER.b, 1)
    cell.bg = bg

    -- Border
    local border = cell:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(COLORS.GRID_LINES.r, COLORS.GRID_LINES.g, COLORS.GRID_LINES.b, 0.5)
    cell.border = border

    -- Marker (for hit/miss icons)
    local marker = cell:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    marker:SetPoint("CENTER")
    marker:SetText("")
    cell.marker = marker

    -- Store references
    cell.row = row
    cell.col = col
    cell.isPlayerGrid = isPlayerGrid
    cell.gameId = gameId

    -- Click handler
    cell:SetScript("OnClick", function(self)
        BattleshipGame:OnCellClick(self.gameId, self.row, self.col, self.isPlayerGrid)
    end)

    -- Hover effect
    cell:SetScript("OnEnter", function(self)
        if self.isPlayerGrid then
            -- Show ship placement preview on player grid during placement
            BattleshipGame:ShowPlacementPreview(self.gameId, self.row, self.col)
        else
            -- Simple hover on enemy grid
            self.bg:SetColorTexture(COLORS.WATER_HOVER.r, COLORS.WATER_HOVER.g, COLORS.WATER_HOVER.b, 1)
        end
    end)

    cell:SetScript("OnLeave", function(self)
        if self.isPlayerGrid then
            -- Clear placement preview
            BattleshipGame:ClearPlacementPreview(self.gameId)
        else
            BattleshipGame:UpdateCellAppearance(self)
        end
    end)

    return cell
end

function BattleshipGame:ShowPlacementPreview(gameId, startRow, startCol)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    -- Only show preview during placement phase
    if state.phase ~= "PLACEMENT" then return end

    local nextShip = Board:GetNextShipToPlace(state.playerBoard)
    if not nextShip then return end

    local size = nextShip.size
    local isHorizontal = state.placementOrientation == Board.ORIENTATION.HORIZONTAL
    local dRow = isHorizontal and 0 or 1
    local dCol = isHorizontal and 1 or 0

    -- Check if placement would be valid
    local canPlace = Board:CanPlaceShip(state.playerBoard, nextShip.id, startRow, startCol, state.placementOrientation)

    -- Highlight cells where ship would go
    local previewColor = canPlace and COLORS.PREVIEW_VALID or COLORS.PREVIEW_INVALID

    -- Track previewed cells for clearing later
    gameData.data.state.previewCells = {}

    for i = 0, size - 1 do
        local row = startRow + (i * dRow)
        local col = startCol + (i * dCol)

        -- Stay within grid bounds for preview
        if row >= 1 and row <= Board.GRID_SIZE and col >= 1 and col <= Board.GRID_SIZE then
            local cell = gameData.data.ui.cells.player[row] and gameData.data.ui.cells.player[row][col]
            if cell then
                -- Only preview on empty cells
                local cellState = state.playerBoard.grid[row][col]
                if cellState == Board.CELL.EMPTY then
                    cell.bg:SetColorTexture(previewColor.r, previewColor.g, previewColor.b, 0.7)
                    table.insert(gameData.data.state.previewCells, cell)
                end
            end
        end
    end
end

function BattleshipGame:ClearPlacementPreview(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    -- Clear all previewed cells
    if gameData.data.state.previewCells then
        for _, cell in ipairs(gameData.data.state.previewCells) do
            self:UpdateCellAppearance(cell)
        end
        gameData.data.state.previewCells = nil
    end
end

--============================================================
-- UI UPDATES
--============================================================

function BattleshipGame:UpdateUI(gameId)
    self:UpdatePlayerGrid(gameId)
    self:UpdateEnemyGrid(gameId)
end

function BattleshipGame:UpdatePlayerGrid(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    for row = 1, Board.GRID_SIZE do
        for col = 1, Board.GRID_SIZE do
            local cell = gameData.data.ui.cells.player[row] and gameData.data.ui.cells.player[row][col]
            if cell then
                self:UpdateCellAppearance(cell)
            end
        end
    end
end

function BattleshipGame:UpdateEnemyGrid(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    for row = 1, Board.GRID_SIZE do
        for col = 1, Board.GRID_SIZE do
            local cell = gameData.data.ui.cells.enemy[row] and gameData.data.ui.cells.enemy[row][col]
            if cell then
                self:UpdateCellAppearance(cell)
            end
        end
    end
end

function BattleshipGame:UpdateCellAppearance(cell)
    local gameData = self.games[cell.gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard
    local board = cell.isPlayerGrid and state.playerBoard or state.enemyBoard
    local cellState = board.grid[cell.row][cell.col]

    -- Set color based on state
    if cellState == Board.CELL.EMPTY then
        cell.bg:SetColorTexture(COLORS.WATER.r, COLORS.WATER.g, COLORS.WATER.b, 1)
        cell.marker:SetText("")
    elseif cellState == Board.CELL.SHIP then
        if cell.isPlayerGrid then
            cell.bg:SetColorTexture(COLORS.SHIP.r, COLORS.SHIP.g, COLORS.SHIP.b, 1)
        else
            -- Don't show enemy ships
            cell.bg:SetColorTexture(COLORS.WATER.r, COLORS.WATER.g, COLORS.WATER.b, 1)
        end
        cell.marker:SetText("")
    elseif cellState == Board.CELL.HIT then
        cell.bg:SetColorTexture(COLORS.HIT.r, COLORS.HIT.g, COLORS.HIT.b, 1)
        cell.marker:SetText("X")
        cell.marker:SetTextColor(1, 1, 1)
    elseif cellState == Board.CELL.MISS then
        cell.bg:SetColorTexture(COLORS.MISS.r, COLORS.MISS.g, COLORS.MISS.b, 1)
        cell.marker:SetText("O")
        cell.marker:SetTextColor(0.6, 0.6, 0.8)
    elseif cellState == Board.CELL.SUNK then
        cell.bg:SetColorTexture(COLORS.SUNK.r, COLORS.SUNK.g, COLORS.SUNK.b, 1)
        cell.marker:SetText("X")
        cell.marker:SetTextColor(1, 0.5, 0.5)
    end
end

function BattleshipGame:UpdatePlayerCell(gameId, row, col, result)
    local gameData = self.games[gameId]
    if not gameData then return end

    local cell = gameData.data.ui.cells.player[row] and gameData.data.ui.cells.player[row][col]
    if cell then
        self:UpdateCellAppearance(cell)
    end
end

function BattleshipGame:UpdateEnemyCell(gameId, row, col, result)
    local gameData = self.games[gameId]
    if not gameData then return end

    local cell = gameData.data.ui.cells.enemy[row] and gameData.data.ui.cells.enemy[row][col]
    if cell then
        self:UpdateCellAppearance(cell)
    end
end

function BattleshipGame:UpdateStatus(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local ui = gameData.data.ui
    local Board = HopeAddon.BattleshipBoard

    -- Update bottom status bar (this is now the ONLY turn/instruction display)
    if not ui.turnText or not ui.hintText or not ui.bottomStatus then return end

    if state.phase == "PLACEMENT" then
        local nextShip = Board:GetNextShipToPlace(state.playerBoard)
        if nextShip then
            local step = Board:GetCurrentStep(state.playerBoard)
            local shipName = string.upper(nextShip.name)
            local shipSize = nextShip.size

            ui.turnText:SetText(string.format("|cFF66AAFFSTEP %d/5:|r Place your |cFFFFD700%s|r (%d)", step, shipName, shipSize))

            local isHorizontal = state.placementOrientation == Board.ORIENTATION.HORIZONTAL
            local orientArrow = isHorizontal and "→ HORIZONTAL" or "↓ VERTICAL"
            ui.hintText:SetText("Click YOUR FLEET grid  |  " .. orientArrow .. "  |  Press R to rotate")
        end
        if ui.rotateBtn then ui.rotateBtn:Show() end
        ui.bottomStatus:SetBackdropBorderColor(0.4, 0.7, 1.0, 1) -- Blue for placement

    elseif state.phase == "WAITING_OPPONENT" then
        ui.turnText:SetText("|cFFFFFF00WAITING FOR OPPONENT|r")
        ui.hintText:SetText("Your ships are placed! Waiting for opponent to finish...")
        if ui.rotateBtn then ui.rotateBtn:Hide() end
        ui.bottomStatus:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Grey

    elseif state.phase == "PLAYING" then
        if ui.rotateBtn then ui.rotateBtn:Hide() end

        if state.currentTurn == "player" then
            ui.turnText:SetText("|cFF00FF00>>> YOUR TURN! <<<|r")
            ui.hintText:SetText("Click ENEMY WATERS grid  or type  /fire A5")
            ui.bottomStatus:SetBackdropBorderColor(0.2, 1.0, 0.2, 1) -- Green

            -- Play turn notification sound
            if HopeAddon.Sounds then
                HopeAddon.Sounds:Play("battleship", "yourTurn")
            end

        elseif state.currentTurn == "enemy" then
            local who = state.isLocalGame and "AI" or "OPPONENT"
            ui.turnText:SetText("|cFFFFFF00" .. who .. "'S TURN|r")
            ui.hintText:SetText("Waiting for shot...")
            ui.bottomStatus:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Grey

        else -- "waiting" for network result
            ui.turnText:SetText("|cFFFFFF00WAITING FOR RESULT...|r")
            ui.hintText:SetText("Shot fired, awaiting confirmation...")
            ui.bottomStatus:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        end

    elseif state.phase == "ENDED" then
        if ui.rotateBtn then ui.rotateBtn:Hide() end
        ui.turnText:SetText("")
        ui.hintText:SetText("")
    end
end

--============================================================
-- INPUT HANDLERS
--============================================================

function BattleshipGame:OnCellClick(gameId, row, col, isPlayerGrid)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state

    if state.phase == "PLACEMENT" and isPlayerGrid then
        self:PlaceShip(gameId, row, col)
    elseif state.phase == "PLAYING" and not isPlayerGrid then
        self:PlayerShoot(gameId, row, col)
    end
end

--============================================================
-- NETWORK HANDLERS
--============================================================

function BattleshipGame:RegisterNetworkHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- MOVE: shots and results
    GameComms:RegisterHandler("BATTLESHIP", "MOVE", function(sender, gameId, data)
        self:HandleNetworkMove(sender, gameId, data)
    end)

    -- STATE: ready signals
    GameComms:RegisterHandler("BATTLESHIP", "STATE", function(sender, gameId, data)
        self:HandleNetworkState(sender, gameId, data)
    end)

    -- END: surrenders
    GameComms:RegisterHandler("BATTLESHIP", "END", function(sender, gameId, data)
        self:HandleNetworkEnd(sender, gameId, data)
    end)
end

-- Handle incoming network moves (shots and results)
function BattleshipGame:HandleNetworkMove(sender, gameId, data)
    local msgType, arg1, arg2, arg3, arg4, arg5 = strsplit("|", data)

    if msgType == "SHOT" then
        -- Opponent shot at us
        self:ProcessOpponentShot(gameId, tonumber(arg1), tonumber(arg2), sender)
    elseif msgType == "RESULT" then
        -- Result of our shot
        self:ProcessShotResult(gameId, tonumber(arg1), tonumber(arg2),
            arg3 == "1", arg4 == "1", arg5)
    end
end

-- Handle state updates (ready signal)
function BattleshipGame:HandleNetworkState(sender, gameId, data)
    if data == "READY" then
        self:OnOpponentReady(gameId)
    end
end

-- Handle game end (surrender)
function BattleshipGame:HandleNetworkEnd(sender, gameId, data)
    if data == "SURRENDER" then
        self:OnOpponentSurrender(gameId)
    end
end

--============================================================
-- NETWORK GAME FLOW
--============================================================

-- Signal ready when ships are placed
function BattleshipGame:SignalReady(gameId)
    local gameData = self.games[gameId]
    if not gameData then
        HopeAddon:Print("No active game found!")
        return
    end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    if state.phase ~= "PLACEMENT" then
        HopeAddon:Print("Not in placement phase!")
        return
    end

    if not Board:AllShipsPlaced(state.playerBoard) then
        local nextShip = Board:GetNextShipToPlace(state.playerBoard)
        HopeAddon:Print("Place all ships first! Next: " .. nextShip.name)
        return
    end

    if state.isLocalGame then
        -- Local: Start immediately
        self:StartPlaying(gameId)
    else
        -- Network: Signal ready and wait
        self:SendReady(gameId)
        state.playerReady = true

        if state.opponentReady then
            self:StartPlaying(gameId)
        else
            state.phase = "WAITING_OPPONENT"
            self:UpdateStatus(gameId)
            HopeAddon:Print("Ships placed! Waiting for opponent...")
        end
    end
end

-- Handle opponent ready
function BattleshipGame:OnOpponentReady(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    state.opponentReady = true

    HopeAddon:Print("Opponent has placed their ships!")

    if state.playerReady then
        self:StartPlaying(gameId)
    end
end

-- Send ready signal to opponent
function BattleshipGame:SendReady(gameId)
    local gameData = self.games[gameId]
    if not gameData or gameData.data.state.isLocalGame then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    local GameCore = HopeAddon:GetModule("GameCore")
    local game = GameCore:GetGame(gameId)

    if GameComms and game and game.opponent then
        GameComms:SendState(game.opponent, "BATTLESHIP", gameId, "READY")
    end
end

-- Send shot to opponent
function BattleshipGame:SendShot(gameId, row, col)
    local gameData = self.games[gameId]
    if not gameData or gameData.data.state.isLocalGame then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    local GameCore = HopeAddon:GetModule("GameCore")
    local game = GameCore:GetGame(gameId)

    if GameComms and game and game.opponent then
        local data = string.format("SHOT|%d|%d", row, col)
        GameComms:SendMove(game.opponent, "BATTLESHIP", gameId, data)
    end
end

-- Process opponent's shot at our board
function BattleshipGame:ProcessOpponentShot(gameId, row, col, sender)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    HopeAddon:Print("Opponent fired at " .. Board:FormatCoord(row, col) .. "!")

    -- Fire shot at player board
    local result = Board:FireShot(state.playerBoard, row, col)

    -- Update UI
    self:UpdatePlayerCell(gameId, row, col, result)

    -- Sound feedback
    if HopeAddon.Sounds then
        if result.hit then
            HopeAddon.Sounds:PlayError()
            if result.sunk then
                HopeAddon:Print("|cFFFF8800Your " .. result.shipName .. " was sunk!|r")
            else
                HopeAddon:Print("|cFFFF0000HIT!|r")
            end
        else
            HopeAddon.Sounds:PlayClick()
            HopeAddon:Print("Miss!")
        end
    end

    -- Send result back
    self:SendShotResult(gameId, row, col, result)

    -- Check for loss
    if Board:AllShipsSunk(state.playerBoard) then
        state.winner = "enemy"
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "LOSS")
        end
        return
    end

    -- Now it's our turn
    state.currentTurn = "player"
    self:UpdateStatus(gameId)
    HopeAddon:Print("|cFF00FF00Your turn!|r Use /fire <coord> (e.g., /fire A5)")
end

-- Send shot result to opponent
function BattleshipGame:SendShotResult(gameId, row, col, result)
    local gameData = self.games[gameId]
    if not gameData or gameData.data.state.isLocalGame then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    local GameCore = HopeAddon:GetModule("GameCore")
    local game = GameCore:GetGame(gameId)

    if GameComms and game and game.opponent then
        local data = string.format("RESULT|%d|%d|%s|%s|%s",
            row, col,
            result.hit and "1" or "0",
            result.sunk and "1" or "0",
            result.shipName or "")
        GameComms:SendMove(game.opponent, "BATTLESHIP", gameId, data)
    end
end

-- Process result of our shot (network mode)
function BattleshipGame:ProcessShotResult(gameId, row, col, hit, sunk, shipName)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard

    -- Track shots for stats
    state.shotsFired = (state.shotsFired or 0) + 1

    -- Update tracking board
    if hit then
        state.enemyBoard.grid[row][col] = sunk and Board.CELL.SUNK or Board.CELL.HIT
        if sunk then
            state.sunkEnemyShips = (state.sunkEnemyShips or 0) + 1
        end
    else
        state.enemyBoard.grid[row][col] = Board.CELL.MISS
    end

    -- Update UI
    self:UpdateEnemyCell(gameId, row, col, { hit = hit, sunk = sunk, shipName = shipName })

    -- Show gameshow animation
    local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
    local coord = Board:FormatCoord(row, col)
    if BattleshipUI then
        local resultType = sunk and "SUNK" or (hit and "HIT" or "MISS")
        BattleshipUI:ShowShotResult(gameId, resultType, coord, shipName, true)

        if sunk then
            BattleshipUI:ShowShipSunkCelebration(gameId, shipName, true)
        end
    else
        -- Fallback sound and message
        if HopeAddon.Sounds then
            if hit then
                HopeAddon.Sounds:PlayBell()
                if sunk then
                    HopeAddon:Print("|cFFFF0000" .. shipName .. " SUNK!|r")
                else
                    HopeAddon:Print("|cFF00FF00HIT!|r")
                end
            else
                HopeAddon.Sounds:PlayClick()
                HopeAddon:Print("Miss!")
            end
        end
    end

    -- Check win (5 ships total)
    if (state.sunkEnemyShips or 0) >= 5 then
        state.winner = "player"
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore then
            GameCore:EndGame(gameId, "WIN")
        end
        return
    end

    -- Switch turns after animation
    state.currentTurn = "enemy"
    local animDelay = BattleshipUI and BattleshipUI:GetAnimationDuration() or 0.8
    HopeAddon.Timer:After(animDelay, function()
        if self.games[gameId] and self.games[gameId].data.state.phase == "PLAYING" then
            self:UpdateStatus(gameId)
        end
    end)
end

-- Surrender game
function BattleshipGame:Surrender(gameId)
    local gameData = self.games[gameId]
    if not gameData then
        HopeAddon:Print("No active game found!")
        return
    end

    local state = gameData.data.state

    HopeAddon:Print("You surrendered!")

    -- Notify opponent if network game
    if not state.isLocalGame then
        local GameComms = HopeAddon:GetModule("GameComms")
        local GameCore = HopeAddon:GetModule("GameCore")
        local game = GameCore:GetGame(gameId)

        if GameComms and game and game.opponent then
            GameComms:SendEnd(game.opponent, "BATTLESHIP", gameId, "SURRENDER")
        end
    end

    state.winner = "enemy"
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:EndGame(gameId, "SURRENDER")
    end
end

-- Handle opponent surrender
function BattleshipGame:OnOpponentSurrender(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    gameData.data.state.winner = "player"
    HopeAddon:Print("|cFF00FF00Your opponent surrendered! You win!|r")

    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:EndGame(gameId, "OPPONENT_SURRENDER")
    end
end

--============================================================
-- CLEANUP
--============================================================

function BattleshipGame:CleanupGame(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local ui = gameData.data.ui

    -- Cleanup gameshow UI frames
    local BattleshipUI = HopeAddon:GetModule("BattleshipUI")
    if BattleshipUI then
        BattleshipUI:CleanupGameFrames(gameId)
    end

    -- Hide and cleanup window scripts
    if ui.window then
        ui.window:Hide()
        ui.window:SetScript("OnKeyDown", nil)
    end

    -- Clear cell references first (prevents dangling references)
    ui.cells = { player = {}, enemy = {} }

    -- Properly destroy the game window (orphans frame and children for GC)
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        GameUI:DestroyGameWindow(gameId)
    end

    self.games[gameId] = nil
end

-- Register module
HopeAddon:RegisterModule("BattleshipGame", BattleshipGame)
HopeAddon:Debug("BattleshipGame module loaded")
