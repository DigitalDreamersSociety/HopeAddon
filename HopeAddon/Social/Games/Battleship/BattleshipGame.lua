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

-- Per-ship colors for visual distinction
local SHIP_COLORS = {
    carrier = { r = 0.6, g = 0.3, b = 0.6 },     -- Purple
    battleship = { r = 0.3, g = 0.5, b = 0.7 },  -- Steel blue
    cruiser = { r = 0.2, g = 0.6, b = 0.5 },     -- Teal
    submarine = { r = 0.5, g = 0.5, b = 0.3 },   -- Olive/khaki
    destroyer = { r = 0.6, g = 0.4, b = 0.3 },   -- Brown/rust
}

-- Error messages for placement failures
local PLACEMENT_ERRORS = {
    OUT_OF_BOUNDS = "Ship doesn't fit! Press R to rotate or click closer to center.",
    OVERLAP = "Ships can't overlap! Choose empty cells.",
    INVALID_SHIP = "Invalid ship selection.",
}

-- Side Panel Constants
local SIDE_PANEL_WIDTH = 100
local SIDE_PANEL_GAP = 14      -- Gap between panel and grids
local SHIP_ROW_HEIGHT = 40
local HEALTH_BAR_WIDTH = 85
local HEALTH_BAR_HEIGHT = 8
local STATS_SECTION_HEIGHT = 60

-- Health bar colors based on damage
local HEALTH_COLORS = {
    FULL = { r = 0.2, g = 0.7, b = 0.3 },      -- Green (100%)
    DAMAGED = { r = 0.9, g = 0.7, b = 0.2 },   -- Yellow (50-99%)
    CRITICAL = { r = 0.9, g = 0.3, b = 0.2 },  -- Red (1-49%)
    SUNK = { r = 0.4, g = 0.1, b = 0.1 },      -- Dark red (0%)
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
                -- Side panels for ship status tracking
                leftPanel = {
                    frame = nil,
                    ships = {},            -- Ship row frames by shipId
                    statsFrame = nil,
                    shipsRemainingText = nil,
                    hitsTakenText = nil,
                },
                rightPanel = {
                    frame = nil,
                    ships = {},
                    statsFrame = nil,
                    hitsText = nil,
                    missesText = nil,
                    accuracyText = nil,
                    sunkCountText = nil,
                },
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

        -- Delay victory overlay to let final shot animation complete
        local delay = BattleshipUI:GetAnimationDuration() + 0.2
        HopeAddon.Timer:After(delay, function()
            -- Verify game still exists before showing overlay
            if self.games[gameId] then
                BattleshipUI:ShowVictoryOverlay(gameId, didWin, stats)
            end
        end)
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

        -- Update side panels: reveal enemy ship if sunk, update stats
        if result.sunk and result.shipId then
            state.sunkEnemyShips = (state.sunkEnemyShips or 0) + 1
            self:RevealEnemyShip(gameId, result.shipId, result.shipName)
        end
        self:UpdatePanelStats(gameId)

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

    -- Update side panels: update player ship status if hit
    if result.hit and result.shipId then
        self:UpdatePlayerShipStatus(gameId, result.shipId)
    end
    self:UpdatePanelStats(gameId)

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

    -- Apply naval-themed styling to window (unique to Battleship)
    window:SetBackdropColor(0.06, 0.10, 0.14, 0.98)  -- Deep ocean (based on WATER color)
    window:SetBackdropBorderColor(0.25, 0.45, 0.65, 1)  -- Steel blue border

    -- Style title bar with naval theme
    if window.titleBar then
        window.titleBar:SetBackdropColor(0.10, 0.18, 0.28, 1)  -- Navy blue
    end

    -- Set title
    if window.title then
        window.title:SetText(HopeAddon:ColorText("BATTLESHIP", "SKY_BLUE"))
    end

    -- Create content area
    local content = CreateFrame("Frame", nil, window)
    content:SetPoint("TOPLEFT", window, "TOPLEFT", 15, -45)
    content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -15, 15)

    -- Create decorative inner border (naval styling)
    local innerBorder = CreateBackdropFrame("Frame", nil, window)
    innerBorder:SetPoint("TOPLEFT", window, "TOPLEFT", 5, -5)
    innerBorder:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -5, 5)
    innerBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    innerBorder:SetBackdropBorderColor(0.20, 0.35, 0.55, 0.5)  -- Subtle steel blue accent
    innerBorder:SetFrameLevel(window:GetFrameLevel() + 1)

    -- Initialize shot counter for stats
    gameData.data.state.shotsFired = 0

    -- Create TOP ANNOUNCEMENT AREA for shot results (HIT!/MISS!/SUNK!)
    local topAnnouncement = CreateFrame("Frame", nil, content)
    topAnnouncement:SetHeight(TOP_ANNOUNCEMENT_HEIGHT)
    topAnnouncement:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    topAnnouncement:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    topAnnouncement:SetFrameLevel(content:GetFrameLevel() + 10)  -- Above grids for text visibility
    -- Subtle background
    local topBg = topAnnouncement:CreateTexture(nil, "BACKGROUND")
    topBg:SetAllPoints()
    topBg:SetColorTexture(0.05, 0.09, 0.13, 0.6)  -- Slightly more visible, matches theme
    gameData.data.ui.topAnnouncement = topAnnouncement

    -- Create BOTTOM STATUS BAR for turn info and instructions
    local bottomStatus = CreateBackdropFrame("Frame", nil, content)
    bottomStatus:SetHeight(BOTTOM_STATUS_HEIGHT)
    bottomStatus:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
    bottomStatus:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    bottomStatus:SetFrameLevel(content:GetFrameLevel() + 10)  -- Above grids for text visibility
    bottomStatus:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    bottomStatus:SetBackdropColor(0.06, 0.10, 0.14, 0.98)  -- Match window background
    bottomStatus:SetBackdropBorderColor(0.25, 0.45, 0.65, 1)  -- Match window border
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
    -- Use explicit sizing instead of flexible anchoring to prevent layout issues
    local Board = HopeAddon.BattleshipBoard
    local singleGridWidth = (Board.GRID_SIZE + 1) * CELL_SIZE  -- 286px
    local singleGridHeight = (Board.GRID_SIZE + 1) * CELL_SIZE + HEADER_HEIGHT  -- 316px
    local totalGridsWidth = singleGridWidth * 2 + CENTER_GAP  -- 592px

    local gridsContainer = CreateFrame("Frame", nil, content)
    gridsContainer:SetSize(totalGridsWidth, singleGridHeight)
    gridsContainer:SetPoint("TOP", topAnnouncement, "BOTTOM", 0, -SECTION_GAP)
    gridsContainer:SetFrameLevel(content:GetFrameLevel() + 1)  -- Below text elements
    gameData.data.ui.gridsContainer = gridsContainer

    -- Create grids side by side
    self:CreatePlayerGrid(gameId, gridsContainer)
    self:CreateEnemyGrid(gameId, gridsContainer)

    -- Create side panels for ship status tracking
    self:CreateSidePanels(gameId, content, gridsContainer)

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
    -- Use TOPLEFT anchor for predictable positioning
    gridFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    gameData.data.ui.playerGrid = gridFrame

    -- Header
    local header = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOP", gridFrame, "TOP", 0, 0)
    header:SetText("YOUR FLEET")
    header:SetTextColor(0.5, 0.75, 0.9)  -- Light ocean blue (friendly)

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
    -- Position to the right of player grid + gap using TOPLEFT anchor
    local singleGridWidth = (Board.GRID_SIZE + 1) * CELL_SIZE
    gridFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", singleGridWidth + CENTER_GAP, 0)
    gameData.data.ui.enemyGrid = gridFrame

    -- Header
    local header = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOP", gridFrame, "TOP", 0, 0)
    header:SetText("ENEMY WATERS")
    header:SetTextColor(0.9, 0.5, 0.5)  -- Target red (hostile)

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
-- SIDE PANELS (Ship Status Tracking)
--============================================================

--[[
    Create both left and right side panels for ship status tracking
    @param gameId string
    @param content Frame - Main content area
    @param gridsContainer Frame - The grids container to position relative to
]]
function BattleshipGame:CreateSidePanels(gameId, content, gridsContainer)
    local gameData = self.games[gameId]
    if not gameData then return end

    local Board = HopeAddon.BattleshipBoard
    local panelHeight = #Board.SHIPS * SHIP_ROW_HEIGHT + STATS_SECTION_HEIGHT + 30  -- Ships + stats + header

    -- Left Panel: YOUR FLEET STATUS
    local leftPanel = CreateBackdropFrame("Frame", nil, content)
    leftPanel:SetSize(SIDE_PANEL_WIDTH, panelHeight)
    leftPanel:SetPoint("RIGHT", gridsContainer, "LEFT", -SIDE_PANEL_GAP, 0)
    leftPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    leftPanel:SetBackdropColor(0.05, 0.08, 0.12, 0.95)
    leftPanel:SetBackdropBorderColor(0.2, 0.4, 0.6, 0.8)
    gameData.data.ui.leftPanel.frame = leftPanel

    -- Left panel header
    local leftHeader = leftPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftHeader:SetPoint("TOP", leftPanel, "TOP", 0, -6)
    leftHeader:SetText("YOUR FLEET")
    leftHeader:SetTextColor(0.5, 0.75, 0.9)

    -- Create ship rows for left panel (player's ships)
    local yOffset = -22
    for _, shipDef in ipairs(Board.SHIPS) do
        local shipRow = self:CreateShipRow(leftPanel, shipDef, true, gameId)
        shipRow:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 5, yOffset)
        gameData.data.ui.leftPanel.ships[shipDef.id] = shipRow
        yOffset = yOffset - SHIP_ROW_HEIGHT
    end

    -- Left panel stats section
    local leftStats = CreateFrame("Frame", nil, leftPanel)
    leftStats:SetSize(SIDE_PANEL_WIDTH - 10, STATS_SECTION_HEIGHT)
    leftStats:SetPoint("BOTTOM", leftPanel, "BOTTOM", 0, 5)
    gameData.data.ui.leftPanel.statsFrame = leftStats

    -- Divider line
    local leftDivider = leftStats:CreateTexture(nil, "ARTWORK")
    leftDivider:SetSize(SIDE_PANEL_WIDTH - 20, 1)
    leftDivider:SetPoint("TOP", leftStats, "TOP", 0, 0)
    leftDivider:SetColorTexture(0.3, 0.5, 0.7, 0.5)

    -- Stats label
    local leftStatsLabel = leftStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftStatsLabel:SetPoint("TOP", leftDivider, "BOTTOM", 0, -4)
    leftStatsLabel:SetText("STATS")
    leftStatsLabel:SetTextColor(0.6, 0.6, 0.6)

    -- Ships remaining
    local shipsRemaining = leftStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    shipsRemaining:SetPoint("TOP", leftStatsLabel, "BOTTOM", 0, -4)
    shipsRemaining:SetText("Ships: 5/5")
    shipsRemaining:SetTextColor(0.7, 0.9, 0.7)
    gameData.data.ui.leftPanel.shipsRemainingText = shipsRemaining

    -- Hits taken
    local hitsTaken = leftStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hitsTaken:SetPoint("TOP", shipsRemaining, "BOTTOM", 0, -2)
    hitsTaken:SetText("Hits: 0")
    hitsTaken:SetTextColor(0.9, 0.7, 0.7)
    gameData.data.ui.leftPanel.hitsTakenText = hitsTaken

    -- Right Panel: ENEMY FLEET STATUS
    local rightPanel = CreateBackdropFrame("Frame", nil, content)
    rightPanel:SetSize(SIDE_PANEL_WIDTH, panelHeight)
    rightPanel:SetPoint("LEFT", gridsContainer, "RIGHT", SIDE_PANEL_GAP, 0)
    rightPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    rightPanel:SetBackdropColor(0.05, 0.08, 0.12, 0.95)
    rightPanel:SetBackdropBorderColor(0.6, 0.3, 0.3, 0.8)
    gameData.data.ui.rightPanel.frame = rightPanel

    -- Right panel header
    local rightHeader = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightHeader:SetPoint("TOP", rightPanel, "TOP", 0, -6)
    rightHeader:SetText("ENEMY FLEET")
    rightHeader:SetTextColor(0.9, 0.5, 0.5)

    -- Create ship rows for right panel (enemy's ships - initially hidden)
    yOffset = -22
    for _, shipDef in ipairs(Board.SHIPS) do
        local shipRow = self:CreateShipRow(rightPanel, shipDef, false, gameId)
        shipRow:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 5, yOffset)
        gameData.data.ui.rightPanel.ships[shipDef.id] = shipRow
        yOffset = yOffset - SHIP_ROW_HEIGHT
    end

    -- Right panel stats section
    local rightStats = CreateFrame("Frame", nil, rightPanel)
    rightStats:SetSize(SIDE_PANEL_WIDTH - 10, STATS_SECTION_HEIGHT)
    rightStats:SetPoint("BOTTOM", rightPanel, "BOTTOM", 0, 5)
    gameData.data.ui.rightPanel.statsFrame = rightStats

    -- Divider line
    local rightDivider = rightStats:CreateTexture(nil, "ARTWORK")
    rightDivider:SetSize(SIDE_PANEL_WIDTH - 20, 1)
    rightDivider:SetPoint("TOP", rightStats, "TOP", 0, 0)
    rightDivider:SetColorTexture(0.7, 0.4, 0.4, 0.5)

    -- Stats label
    local rightStatsLabel = rightStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightStatsLabel:SetPoint("TOP", rightDivider, "BOTTOM", 0, -4)
    rightStatsLabel:SetText("YOUR ATTACKS")
    rightStatsLabel:SetTextColor(0.6, 0.6, 0.6)

    -- Hits
    local hitsText = rightStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hitsText:SetPoint("TOPLEFT", rightStatsLabel, "BOTTOMLEFT", -10, -4)
    hitsText:SetText("Hits: 0")
    hitsText:SetTextColor(0.7, 0.9, 0.7)
    gameData.data.ui.rightPanel.hitsText = hitsText

    -- Misses
    local missesText = rightStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    missesText:SetPoint("TOPLEFT", hitsText, "BOTTOMLEFT", 0, -2)
    missesText:SetText("Misses: 0")
    missesText:SetTextColor(0.9, 0.7, 0.7)
    gameData.data.ui.rightPanel.missesText = missesText

    -- Accuracy
    local accuracyText = rightStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    accuracyText:SetPoint("TOPLEFT", missesText, "BOTTOMLEFT", 0, -2)
    accuracyText:SetText("Accuracy: --%")
    accuracyText:SetTextColor(0.8, 0.8, 0.8)
    gameData.data.ui.rightPanel.accuracyText = accuracyText

    -- Ships sunk counter
    local sunkCountText = rightStats:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sunkCountText:SetPoint("TOPRIGHT", rightStatsLabel, "BOTTOMRIGHT", 10, -4)
    sunkCountText:SetText("Sunk: 0/5")
    sunkCountText:SetTextColor(1, 0.4, 0.4)
    gameData.data.ui.rightPanel.sunkCountText = sunkCountText
end

--[[
    Create a single ship row with name and health/status bar
    @param parent Frame - Panel to attach to
    @param shipData table - Ship definition {id, name, size}
    @param isPlayerShip boolean - True for player's ships, false for enemy
    @param gameId string
    @return Frame - The ship row frame
]]
function BattleshipGame:CreateShipRow(parent, shipData, isPlayerShip, gameId)
    local shipRow = CreateFrame("Frame", nil, parent)
    shipRow:SetSize(SIDE_PANEL_WIDTH - 10, SHIP_ROW_HEIGHT)

    local shipColor = SHIP_COLORS[shipData.id] or COLORS.SHIP

    -- Ship name text
    local nameText = shipRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", shipRow, "TOPLEFT", 2, -2)

    if isPlayerShip then
        -- Player ship: show colored name
        nameText:SetText("■ " .. shipData.name)
        nameText:SetTextColor(shipColor.r, shipColor.g, shipColor.b)
    else
        -- Enemy ship: show mystery state
        nameText:SetText("? " .. shipData.name)
        nameText:SetTextColor(0.5, 0.5, 0.5)
    end
    shipRow.nameText = nameText

    -- Health/status bar or text
    if isPlayerShip then
        -- Create health bar background
        local barBg = shipRow:CreateTexture(nil, "BACKGROUND")
        barBg:SetSize(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)
        barBg:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
        barBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        shipRow.barBg = barBg

        -- Create health bar fill
        local healthBar = shipRow:CreateTexture(nil, "ARTWORK")
        healthBar:SetSize(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)
        healthBar:SetPoint("TOPLEFT", barBg, "TOPLEFT", 0, 0)
        healthBar:SetColorTexture(shipColor.r, shipColor.g, shipColor.b, 1)
        shipRow.healthBar = healthBar

        -- Store ship size for damage calculation
        shipRow.maxHealth = shipData.size
        shipRow.currentHealth = shipData.size
    else
        -- Enemy ship: show mystery bar or status text
        local statusText = shipRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statusText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
        statusText:SetText(string.rep("?", math.min(shipData.size, 8)))
        statusText:SetTextColor(0.4, 0.4, 0.4)
        shipRow.statusText = statusText
    end

    -- Store ship ID for reference
    shipRow.shipId = shipData.id
    shipRow.shipName = shipData.name
    shipRow.isPlayerShip = isPlayerShip

    return shipRow
end

--[[
    Update a player ship's health bar after taking damage
    @param gameId string
    @param shipId string
]]
function BattleshipGame:UpdatePlayerShipStatus(gameId, shipId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local shipRow = gameData.data.ui.leftPanel.ships[shipId]
    if not shipRow or not shipRow.healthBar then return end

    local Board = HopeAddon.BattleshipBoard
    local shipStatus = Board:GetShipStatus(gameData.data.state.playerBoard, shipId)
    if not shipStatus then return end

    local healthPercent = (shipStatus.size - shipStatus.hits) / shipStatus.size
    local newWidth = HEALTH_BAR_WIDTH * healthPercent

    if shipStatus.sunk then
        -- Ship is sunk
        shipRow.healthBar:SetSize(0.1, HEALTH_BAR_HEIGHT)
        shipRow.healthBar:SetColorTexture(HEALTH_COLORS.SUNK.r, HEALTH_COLORS.SUNK.g, HEALTH_COLORS.SUNK.b, 1)
        shipRow.nameText:SetText("☒ " .. shipRow.shipName)
        shipRow.nameText:SetTextColor(0.6, 0.2, 0.2)

        -- Add SUNK! text
        if not shipRow.sunkText then
            local sunkText = shipRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            sunkText:SetPoint("LEFT", shipRow.barBg, "RIGHT", 2, 0)
            sunkText:SetText("SUNK!")
            sunkText:SetTextColor(1, 0.3, 0.3)
            shipRow.sunkText = sunkText
        end
    else
        -- Update health bar width and color
        shipRow.healthBar:SetSize(math.max(newWidth, 0.1), HEALTH_BAR_HEIGHT)

        -- Color based on health
        local color
        if healthPercent >= 1 then
            color = HEALTH_COLORS.FULL
        elseif healthPercent >= 0.5 then
            color = HEALTH_COLORS.DAMAGED
        else
            color = HEALTH_COLORS.CRITICAL
        end
        shipRow.healthBar:SetColorTexture(color.r, color.g, color.b, 1)
    end
end

--[[
    Reveal an enemy ship when sunk (with animation)
    @param gameId string
    @param shipId string
    @param shipName string
]]
function BattleshipGame:RevealEnemyShip(gameId, shipId, shipName)
    local gameData = self.games[gameId]
    if not gameData then return end

    local shipRow = gameData.data.ui.rightPanel.ships[shipId]
    if not shipRow then return end

    -- Flash effect
    if HopeAddon.Effects then
        HopeAddon.Effects:Flash(shipRow, 0.3, { r = 1, g = 0.3, b = 0.3 })
    end

    -- Update ship name to revealed state
    shipRow.nameText:SetText("☒ " .. shipName)
    shipRow.nameText:SetTextColor(0.9, 0.3, 0.3)

    -- Update status text
    if shipRow.statusText then
        shipRow.statusText:SetText("DESTROYED!")
        shipRow.statusText:SetTextColor(1, 0.4, 0.4)
    end

    -- Sparkle effect
    if HopeAddon.Effects then
        HopeAddon.Effects:CreateSparkles(shipRow, 5, "FEL_GREEN")
    end
end

--[[
    Update stats sections on both panels
    @param gameId string
]]
function BattleshipGame:UpdatePanelStats(gameId)
    local gameData = self.games[gameId]
    if not gameData then return end

    local state = gameData.data.state
    local Board = HopeAddon.BattleshipBoard
    local leftUI = gameData.data.ui.leftPanel
    local rightUI = gameData.data.ui.rightPanel

    -- Left panel stats (player fleet)
    local shipsRemaining = Board:GetShipsRemaining(state.playerBoard)
    local totalHitsOnPlayer = #state.playerBoard.hits

    if leftUI.shipsRemainingText then
        leftUI.shipsRemainingText:SetText("Ships: " .. shipsRemaining .. "/5")
        if shipsRemaining <= 2 then
            leftUI.shipsRemainingText:SetTextColor(1, 0.4, 0.4)
        elseif shipsRemaining <= 3 then
            leftUI.shipsRemainingText:SetTextColor(0.9, 0.9, 0.4)
        else
            leftUI.shipsRemainingText:SetTextColor(0.7, 0.9, 0.7)
        end
    end

    if leftUI.hitsTakenText then
        leftUI.hitsTakenText:SetText("Hits: " .. totalHitsOnPlayer)
    end

    -- Right panel stats (player's attacks on enemy)
    local playerHits = #state.enemyBoard.hits
    local playerMisses = #state.enemyBoard.misses
    local totalShots = playerHits + playerMisses
    local accuracy = totalShots > 0 and math.floor((playerHits / totalShots) * 100) or 0
    local sunkCount = state.sunkEnemyShips or 0

    if rightUI.hitsText then
        rightUI.hitsText:SetText("Hits: " .. playerHits)
    end

    if rightUI.missesText then
        rightUI.missesText:SetText("Misses: " .. playerMisses)
    end

    if rightUI.accuracyText then
        rightUI.accuracyText:SetText("Accuracy: " .. accuracy .. "%")
        if accuracy >= 60 then
            rightUI.accuracyText:SetTextColor(0.4, 1, 0.4)
        elseif accuracy >= 40 then
            rightUI.accuracyText:SetTextColor(0.9, 0.9, 0.4)
        else
            rightUI.accuracyText:SetTextColor(0.9, 0.6, 0.6)
        end
    end

    if rightUI.sunkCountText then
        rightUI.sunkCountText:SetText("Sunk: " .. sunkCount .. "/5")
        if sunkCount >= 4 then
            rightUI.sunkCountText:SetTextColor(0.4, 1, 0.4)
        elseif sunkCount >= 2 then
            rightUI.sunkCountText:SetTextColor(1, 0.7, 0.3)
        else
            rightUI.sunkCountText:SetTextColor(1, 0.4, 0.4)
        end
    end
end

--============================================================
-- UI UPDATES
--============================================================

function BattleshipGame:UpdateUI(gameId)
    self:UpdatePlayerGrid(gameId)
    self:UpdateEnemyGrid(gameId)
    self:UpdatePanelStats(gameId)
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
            local shipId = board.shipGrid and board.shipGrid[cell.row][cell.col]
            local shipColor = shipId and SHIP_COLORS[shipId] or COLORS.SHIP
            cell.bg:SetColorTexture(shipColor.r, shipColor.g, shipColor.b, 1)
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
            ui.hintText:SetText("Click YOUR FLEET grid  |  " .. orientArrow .. "  |  |cFFFFD700Press R|r to rotate")
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

    -- Update side panels: update player ship status if hit
    if result.hit and result.shipId then
        self:UpdatePlayerShipStatus(gameId, result.shipId)
    end
    self:UpdatePanelStats(gameId)

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

    -- Update side panels: reveal enemy ship if sunk, update stats
    if sunk and shipName then
        -- Find ship ID from name for network mode
        local shipId = nil
        for _, shipDef in ipairs(Board.SHIPS) do
            if shipDef.name == shipName then
                shipId = shipDef.id
                break
            end
        end
        if shipId then
            self:RevealEnemyShip(gameId, shipId, shipName)
        end
    end
    self:UpdatePanelStats(gameId)

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
