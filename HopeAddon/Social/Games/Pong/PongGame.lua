--[[
    HopeAddon Pong Game
    Classic Pong with ball physics and paddle movement

    Controls:
    - Player 1: W/S keys
    - Player 2: Up/Down arrow keys

    In-person 2-player on same keyboard
]]

local PongGame = {}

--============================================================
-- CONSTANTS
--============================================================

-- Game settings
PongGame.SETTINGS = {
    -- Play area
    PLAY_WIDTH = 400,
    PLAY_HEIGHT = 300,

    -- Paddles
    PADDLE_WIDTH = 10,
    PADDLE_HEIGHT = 60,
    PADDLE_SPEED = 300,       -- Pixels per second
    PADDLE_MARGIN = 20,       -- Distance from edge

    -- Ball
    BALL_SIZE = 10,
    BALL_INITIAL_SPEED = 200,
    BALL_MAX_SPEED = 400,
    BALL_SPEED_INCREMENT = 10, -- Speed increase per hit

    -- Scoring
    WINNING_SCORE = 5,

    -- Network sync (REMOTE mode only)
    NETWORK_UPDATE_HZ = 10,       -- Network update rate (reduced from 30 to 10 for bandwidth optimization)
}

--============================================================
-- MODULE STATE
--============================================================

-- Active pong games
PongGame.games = {}

--============================================================
-- LIFECYCLE
--============================================================

function PongGame:OnInitialize()
    HopeAddon:Debug("PongGame initializing...")
end

function PongGame:OnEnable()
    -- Register with GameCore
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:RegisterGame(GameCore.GAME_TYPE.PONG, self)
    end

    -- Register network handlers
    self:RegisterNetworkHandlers()

    HopeAddon:Debug("PongGame enabled")
end

function PongGame:RegisterNetworkHandlers()
    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms then return end

    -- Register MOVE handler (paddle position)
    GameComms:RegisterHandler("PONG", "MOVE", function(sender, gameId, data)
        self:OnOpponentMove(sender, gameId, data)
    end)

    -- Register END handler (game over)
    GameComms:RegisterHandler("PONG", "END", function(sender, gameId, data)
        self:OnOpponentGameOver(sender, gameId, data)
    end)
end

function PongGame:OnDisable()
    -- Clean up any active games
    for gameId, game in pairs(self.games) do
        self:CleanupGame(gameId)
    end
end

--============================================================
-- GAME LIFECYCLE (Called by GameCore)
--============================================================

function PongGame:OnCreate(gameId, game)
    local S = self.SETTINGS
    local isRemote = game.mode == HopeAddon:GetModule("GameCore").GAME_MODE.REMOTE

    -- Initialize pong-specific data
    game.data = {
        -- Play area bounds
        playWidth = S.PLAY_WIDTH,
        playHeight = S.PLAY_HEIGHT,

        -- Mode tracking
        isRemote = isRemote,
        opponent = game.opponent,  -- Store opponent for network sync

        -- Paddle sync timer (REMOTE only)
        paddleSyncTimer = 0,
        lastOpponentMessage = GetTime(),  -- Track for disconnect detection

        -- Paddle 1 (left - always controlled by local player)
        paddle1 = {
            x = S.PADDLE_MARGIN,
            y = S.PLAY_HEIGHT / 2 - S.PADDLE_HEIGHT / 2,
            width = S.PADDLE_WIDTH,
            height = S.PADDLE_HEIGHT,
            dy = 0,
        },

        -- Paddle 2 (right - P2 in LOCAL, opponent in REMOTE)
        paddle2 = {
            x = S.PLAY_WIDTH - S.PADDLE_MARGIN - S.PADDLE_WIDTH,
            y = S.PLAY_HEIGHT / 2 - S.PADDLE_HEIGHT / 2,
            width = S.PADDLE_WIDTH,
            height = S.PADDLE_HEIGHT,
            dy = 0,
        },

        -- Ball
        ball = {
            x = S.PLAY_WIDTH / 2 - S.BALL_SIZE / 2,
            y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2,
            size = S.BALL_SIZE,
            dx = 0,
            dy = 0,
            speed = S.BALL_INITIAL_SPEED,
        },

        -- Game state
        serving = 1,  -- 1 or 2 - who serves next
        paused = false,
        countdown = 3,  -- Countdown before ball starts
    }

    self.games[gameId] = game
    HopeAddon:Debug("Pong game created:", gameId, "mode:", game.mode)
end

function PongGame:OnStart(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Show UI
    self:CreateUI(gameId)

    -- Start countdown
    game.data.countdown = 3
    self:StartCountdown(gameId)
end

function PongGame:OnUpdate(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    -- Check for opponent disconnect in REMOTE mode
    if game.data.isRemote and game.data.opponent then
        local timeSinceLastMessage = GetTime() - (game.data.lastOpponentMessage or GetTime())
        if timeSinceLastMessage > 10 then  -- 10 second timeout
            HopeAddon:Print("Opponent disconnected from Pong game")
            local GameCore = HopeAddon:GetModule("GameCore")
            if GameCore then
                GameCore:EndGame(gameId, "DISCONNECT")
            end
            return
        end
    end

    if game.data.paused or game.data.countdown > 0 then
        return
    end

    -- Update paddles
    self:UpdatePaddles(gameId, dt)

    -- Update ball
    self:UpdateBall(gameId, dt)

    -- Update UI
    self:UpdateUI(gameId)
end

function PongGame:OnPause(gameId)
    local game = self.games[gameId]
    if game then
        game.data.paused = true
    end
end

function PongGame:OnResume(gameId)
    local game = self.games[gameId]
    if game then
        game.data.paused = false
    end
end

function PongGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    -- Record stats for REMOTE games
    if game.data.isRemote and game.data.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            local isWinner = game.winner == game.player1
            local result = isWinner and "win" or "lose"
            local myScore = game.score[1]
            local oppScore = game.score[2]

            Minigames:RecordGameResult(
                game.data.opponent,
                "pong",
                result,
                myScore,
                oppScore
            )
        end
    end

    -- Show game over
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        local stats = {
            ["Final Score"] = game.score[1] .. " - " .. game.score[2],
        }
        GameUI:ShowGameOver(gameId, game.winner, stats)
    end
end

function PongGame:OnDestroy(gameId)
    self:CleanupGame(gameId)
end

--============================================================
-- GAME LOGIC
--============================================================

--[[
    Start countdown before serving
]]
function PongGame:StartCountdown(gameId)
    local game = self.games[gameId]
    if not game then return end

    game.data.countdown = 3

    -- Cancel existing countdown timer
    if game.data.countdownTimer then
        game.data.countdownTimer:Cancel()
    end

    -- Update countdown UI
    if game.data.countdownText then
        game.data.countdownText:SetText(tostring(game.data.countdown))
        game.data.countdownText:Show()
    end

    -- Countdown timer
    local function tick()
        local currentGame = self.games[gameId]  -- Re-fetch each time
        if not currentGame then return end

        currentGame.data.countdown = currentGame.data.countdown - 1

        if currentGame.data.countdown > 0 then
            if currentGame.data.countdownText then
                currentGame.data.countdownText:SetText(tostring(currentGame.data.countdown))
            end
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            currentGame.data.countdownTimer = HopeAddon.Timer:After(1, tick)
        else
            currentGame.data.countdownTimer = nil
            if currentGame.data.countdownText then
                currentGame.data.countdownText:Hide()
            end
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayAchievement()
            end
            self:ServeBall(gameId)
        end
    end

    game.data.countdownTimer = HopeAddon.Timer:After(1, tick)
end

--[[
    Serve the ball
]]
function PongGame:ServeBall(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ball = game.data.ball
    local S = self.SETTINGS

    -- Reset ball position
    ball.x = S.PLAY_WIDTH / 2 - S.BALL_SIZE / 2
    ball.y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2
    ball.speed = S.BALL_INITIAL_SPEED

    -- Random angle between -45 and 45 degrees
    local angle = (math.random() - 0.5) * math.pi / 2

    -- Direction based on who serves
    local direction = game.data.serving == 1 and 1 or -1

    ball.dx = math.cos(angle) * ball.speed * direction
    ball.dy = math.sin(angle) * ball.speed
end

--[[
    Update paddle positions based on input
]]
function PongGame:UpdatePaddles(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    local isRemote = game.data.isRemote

    if isRemote then
        -- REMOTE mode: Only control paddle1 (local player)
        self:UpdateLocalPaddle(gameId, dt)
        -- Paddle2 updated by network messages (OnOpponentMove)

        -- Send paddle position to opponent
        self:SendPaddlePosition(gameId, dt)
    else
        -- LOCAL mode: Control both paddles
        self:UpdateLocalPaddles(gameId, dt)
    end
end

function PongGame:UpdateLocalPaddle(gameId, dt)
    local game = self.games[gameId]
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local paddle1 = game.data.paddle1

    -- Player controls paddle1 with W/S
    paddle1.dy = 0
    if GameCore:IsKeyDown("W") then
        paddle1.dy = -S.PADDLE_SPEED
    elseif GameCore:IsKeyDown("S") then
        paddle1.dy = S.PADDLE_SPEED
    end

    -- Apply movement
    paddle1.y = paddle1.y + paddle1.dy * dt
    paddle1.y = GameCore:Clamp(paddle1.y, 0, S.PLAY_HEIGHT - paddle1.height)
end

function PongGame:UpdateLocalPaddles(gameId, dt)
    -- Existing LOCAL mode logic (Player 1: W/S, Player 2: Up/Down)
    local game = self.games[gameId]
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local paddle1 = game.data.paddle1
    local paddle2 = game.data.paddle2

    -- Player 1 (W/S)
    paddle1.dy = 0
    if GameCore:IsKeyDown("W") then
        paddle1.dy = -S.PADDLE_SPEED
    elseif GameCore:IsKeyDown("S") then
        paddle1.dy = S.PADDLE_SPEED
    end

    -- Player 2 (Up/Down arrows)
    paddle2.dy = 0
    if GameCore:IsKeyDown("UP") then
        paddle2.dy = -S.PADDLE_SPEED
    elseif GameCore:IsKeyDown("DOWN") then
        paddle2.dy = S.PADDLE_SPEED
    end

    -- Apply movement
    paddle1.y = paddle1.y + paddle1.dy * dt
    paddle2.y = paddle2.y + paddle2.dy * dt

    -- Clamp to play area
    paddle1.y = GameCore:Clamp(paddle1.y, 0, S.PLAY_HEIGHT - paddle1.height)
    paddle2.y = GameCore:Clamp(paddle2.y, 0, S.PLAY_HEIGHT - paddle2.height)
end

--[[
    Update ball position and handle collisions
]]
function PongGame:UpdateBall(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    local ball = game.data.ball
    local paddle1 = game.data.paddle1
    local paddle2 = game.data.paddle2

    -- Move ball
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Top/bottom wall collision
    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy
        self:PlayBounceSound()
    elseif ball.y + ball.size >= S.PLAY_HEIGHT then
        ball.y = S.PLAY_HEIGHT - ball.size
        ball.dy = -ball.dy
        self:PlayBounceSound()
    end

    -- Paddle 1 collision (left)
    if ball.dx < 0 and GameCore:CheckCollision(
        ball.x, ball.y, ball.size, ball.size,
        paddle1.x, paddle1.y, paddle1.width, paddle1.height
    ) then
        ball.x = paddle1.x + paddle1.width
        ball.dx = -ball.dx

        -- Add spin based on where ball hits paddle
        local hitPos = (ball.y + ball.size / 2) - (paddle1.y + paddle1.height / 2)
        local normalizedHit = hitPos / (paddle1.height / 2)
        ball.dy = ball.dy + normalizedHit * 100

        -- Increase speed
        ball.speed = math.min(ball.speed + S.BALL_SPEED_INCREMENT, S.BALL_MAX_SPEED)
        self:NormalizeBallSpeed(ball)

        self:PlayHitSound()
    end

    -- Paddle 2 collision (right)
    if ball.dx > 0 and GameCore:CheckCollision(
        ball.x, ball.y, ball.size, ball.size,
        paddle2.x, paddle2.y, paddle2.width, paddle2.height
    ) then
        ball.x = paddle2.x - ball.size
        ball.dx = -ball.dx

        -- Add spin
        local hitPos = (ball.y + ball.size / 2) - (paddle2.y + paddle2.height / 2)
        local normalizedHit = hitPos / (paddle2.height / 2)
        ball.dy = ball.dy + normalizedHit * 100

        -- Increase speed
        ball.speed = math.min(ball.speed + S.BALL_SPEED_INCREMENT, S.BALL_MAX_SPEED)
        self:NormalizeBallSpeed(ball)

        self:PlayHitSound()
    end

    -- Score detection (ball passed paddle)
    if ball.x + ball.size < 0 then
        -- Player 2 scores
        self:Score(gameId, 2)
    elseif ball.x > S.PLAY_WIDTH then
        -- Player 1 scores
        self:Score(gameId, 1)
    end
end

--[[
    Normalize ball velocity to match speed
]]
function PongGame:NormalizeBallSpeed(ball)
    local currentSpeed = math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
    if currentSpeed > 0 then
        ball.dx = (ball.dx / currentSpeed) * ball.speed
        ball.dy = (ball.dy / currentSpeed) * ball.speed
    end
end

--[[
    Handle scoring
]]
function PongGame:Score(gameId, player)
    local game = self.games[gameId]
    if not game then return end

    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")

    -- Update score
    GameCore:AddScore(gameId, player)

    -- Play score sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    -- Check for win
    if game.score[player] >= S.WINNING_SCORE then
        -- In REMOTE mode, send game over message
        if game.data.isRemote then
            -- Loser sends game over (player is the winner)
            local loser = player == 1 and 2 or 1
            self:SendGameOver(gameId, loser)
        end

        local winner = player == 1 and game.player1 or game.player2
        GameCore:SetWinner(gameId, winner)
        return
    end

    -- Set next server (loser serves)
    game.data.serving = player == 1 and 2 or 1

    -- Reset and start countdown
    self:ResetBall(gameId)
    self:StartCountdown(gameId)
end

--[[
    Reset ball to center without starting
]]
function PongGame:ResetBall(gameId)
    local game = self.games[gameId]
    if not game then return end

    local S = self.SETTINGS
    local ball = game.data.ball

    ball.x = S.PLAY_WIDTH / 2 - S.BALL_SIZE / 2
    ball.y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2
    ball.dx = 0
    ball.dy = 0
    ball.speed = S.BALL_INITIAL_SPEED
end

--============================================================
-- NETWORK SYNC (REMOTE mode)
--============================================================

function PongGame:SendPaddlePosition(gameId, dt)
    local game = self.games[gameId]
    if not game or not game.data.isRemote then return end

    local S = self.SETTINGS
    local syncInterval = 1 / S.NETWORK_UPDATE_HZ  -- Calculate interval from Hz

    -- Throttle network updates (10 Hz = 67% bandwidth reduction vs 30 Hz)
    -- Client-side physics still runs at 30 FPS for smooth local rendering
    game.data.paddleSyncTimer = (game.data.paddleSyncTimer or 0) + dt
    if game.data.paddleSyncTimer >= syncInterval then
        game.data.paddleSyncTimer = 0

        local paddle1 = game.data.paddle1
        local data = string.format("PADDLE|%.2f|%.2f", paddle1.y, paddle1.dy)

        local GameComms = HopeAddon:GetModule("GameComms")
        if GameComms and game.data.opponent then
            GameComms:SendMove(game.data.opponent, "PONG", gameId, data)
        end
    end
end

function PongGame:OnOpponentMove(sender, gameId, data)
    local game = self.games[gameId]
    if not game or not game.data.isRemote then return end

    -- Validate sender is the opponent
    if sender ~= game.data.opponent then
        HopeAddon:Debug("Ignoring PONG move from non-opponent:", sender)
        return
    end

    -- Update last message timestamp for disconnect detection
    game.data.lastOpponentMessage = GetTime()

    -- Parse paddle position
    local msgType, yPos, dyVel = strsplit("|", data)
    if msgType == "PADDLE" then
        local paddle2 = game.data.paddle2
        paddle2.y = tonumber(yPos) or paddle2.y
        paddle2.dy = tonumber(dyVel) or paddle2.dy
    end
end

function PongGame:SendGameOver(gameId, loser)
    local game = self.games[gameId]
    if not game or not game.data.isRemote then return end

    local data = "GAMEOVER|" .. tostring(loser)

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms and game.data.opponent then
        GameComms:SendEnd(game.data.opponent, "PONG", gameId, data)
    end
end

function PongGame:OnOpponentGameOver(sender, gameId, data)
    local game = self.games[gameId]
    if not game then return end

    -- Validate sender is the opponent
    if game.data.isRemote and sender ~= game.data.opponent then
        HopeAddon:Debug("Ignoring PONG game over from non-opponent:", sender)
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    -- Parse game over data
    local msgType, loser = strsplit("|", data)
    if msgType == "GAMEOVER" then
        local loserNum = tonumber(loser)
        local winner = loserNum == 1 and game.player2 or game.player1
        GameCore:SetWinner(gameId, winner)
    end
end

--============================================================
-- SOUND EFFECTS
--============================================================

function PongGame:PlayBounceSound()
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

function PongGame:PlayHitSound()
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--============================================================
-- UI
--============================================================

function PongGame:CreateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    local S = self.SETTINGS

    -- Create game window
    local window = GameUI:CreateGameWindow(gameId, "Pong", "PONG")
    if not window then return end

    game.data.window = window  -- Store for cleanup

    local content = window.content

    -- Score display at top
    local scoreContainer = CreateFrame("Frame", nil, content)
    scoreContainer:SetSize(200, 40)
    scoreContainer:SetPoint("TOP", 0, -5)

    local p1Score = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    p1Score:SetPoint("LEFT", 20, 0)
    p1Score:SetText("0")
    p1Score:SetTextColor(0.2, 0.8, 0.2)
    game.data.p1ScoreText = p1Score

    local vsText = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    vsText:SetPoint("CENTER", 0, 0)
    vsText:SetText("-")
    vsText:SetTextColor(0.6, 0.6, 0.6)

    local p2Score = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    p2Score:SetPoint("RIGHT", -20, 0)
    p2Score:SetText("0")
    p2Score:SetTextColor(0.8, 0.2, 0.2)
    game.data.p2ScoreText = p2Score

    -- Play area
    local playArea = GameUI:CreatePlayArea(content, S.PLAY_WIDTH, S.PLAY_HEIGHT)
    playArea:SetPoint("CENTER", 0, -10)
    game.data.playArea = playArea

    -- Center line (dashed)
    for i = 0, 14 do
        local dash = playArea:CreateTexture(nil, "ARTWORK")
        dash:SetSize(2, 12)
        dash:SetPoint("TOP", 0, -i * 20 - 5)
        dash:SetColorTexture(0.3, 0.3, 0.3, 1)
    end

    -- Paddle 1 (left)
    local paddle1Frame = CreateFrame("Frame", nil, playArea)
    paddle1Frame:SetSize(S.PADDLE_WIDTH, S.PADDLE_HEIGHT)
    local paddle1Tex = paddle1Frame:CreateTexture(nil, "ARTWORK")
    paddle1Tex:SetAllPoints()
    paddle1Tex:SetColorTexture(0.2, 0.8, 0.2, 1)
    game.data.paddle1Frame = paddle1Frame

    -- Paddle 2 (right)
    local paddle2Frame = CreateFrame("Frame", nil, playArea)
    paddle2Frame:SetSize(S.PADDLE_WIDTH, S.PADDLE_HEIGHT)
    local paddle2Tex = paddle2Frame:CreateTexture(nil, "ARTWORK")
    paddle2Tex:SetAllPoints()
    paddle2Tex:SetColorTexture(0.8, 0.2, 0.2, 1)
    game.data.paddle2Frame = paddle2Frame

    -- Ball
    local ballFrame = CreateFrame("Frame", nil, playArea)
    ballFrame:SetSize(S.BALL_SIZE, S.BALL_SIZE)
    local ballTex = ballFrame:CreateTexture(nil, "ARTWORK")
    ballTex:SetAllPoints()
    ballTex:SetColorTexture(1, 1, 1, 1)
    game.data.ballFrame = ballFrame

    -- Countdown text
    local countdownText = playArea:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    countdownText:SetPoint("CENTER")
    countdownText:SetText("3")
    countdownText:SetTextColor(1, 0.84, 0)
    countdownText:Hide()
    game.data.countdownText = countdownText

    -- Controls hint
    local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    controlsText:SetPoint("BOTTOM", 0, 5)

    local GameCore = HopeAddon:GetModule("GameCore")
    if game.mode == GameCore.GAME_MODE.REMOTE then
        controlsText:SetText("W/S to move | vs " .. (game.data.opponent or "Opponent"))
    else
        controlsText:SetText("P1: W/S | P2: Up/Down")
    end

    controlsText:SetTextColor(0.5, 0.5, 0.5)

    -- Enable keyboard input
    window:SetScript("OnKeyDown", function(_, key)
        self:OnKeyDown(gameId, key)
    end)
    window:SetScript("OnKeyUp", function(_, key)
        self:OnKeyUp(gameId, key)
    end)
    window:EnableKeyboard(true)
    window:SetPropagateKeyboardInput(false)

    -- Initial position update
    self:UpdateUI(gameId)

    window:Show()
end

function PongGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    -- Update scores
    if game.data.p1ScoreText then
        game.data.p1ScoreText:SetText(tostring(game.score[1]))
    end
    if game.data.p2ScoreText then
        game.data.p2ScoreText:SetText(tostring(game.score[2]))
    end

    -- Update paddle positions (relative to play area bottom-left)
    if game.data.paddle1Frame and game.data.playArea then
        game.data.paddle1Frame:SetPoint("BOTTOMLEFT", game.data.playArea, "BOTTOMLEFT",
            game.data.paddle1.x,
            game.data.paddle1.y)
    end

    if game.data.paddle2Frame and game.data.playArea then
        game.data.paddle2Frame:SetPoint("BOTTOMLEFT", game.data.playArea, "BOTTOMLEFT",
            game.data.paddle2.x,
            game.data.paddle2.y)
    end

    -- Update ball position
    if game.data.ballFrame and game.data.playArea then
        game.data.ballFrame:SetPoint("BOTTOMLEFT", game.data.playArea, "BOTTOMLEFT",
            game.data.ball.x,
            game.data.ball.y)
    end
end

--============================================================
-- INPUT HANDLING
--============================================================

function PongGame:OnKeyDown(gameId, key)
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    -- Map keys
    local keyMap = {
        ["W"] = "W",
        ["S"] = "S",
        ["UP"] = "UP",
        ["DOWN"] = "DOWN",
    }

    local mappedKey = keyMap[key]
    if mappedKey then
        GameCore:SetKeyState(mappedKey, true)
    end

    -- Escape to pause
    if key == "ESCAPE" then
        local game = self.games[gameId]
        if game then
            game.data.paused = not game.data.paused
        end
    end
end

function PongGame:OnKeyUp(gameId, key)
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local keyMap = {
        ["W"] = "W",
        ["S"] = "S",
        ["UP"] = "UP",
        ["DOWN"] = "DOWN",
    }

    local mappedKey = keyMap[key]
    if mappedKey then
        GameCore:SetKeyState(mappedKey, false)
    end
end

--============================================================
-- CLEANUP
--============================================================

function PongGame:CleanupGame(gameId)
    local game = self.games[gameId]
    if not game then
        self.games[gameId] = nil
        return
    end

    -- Cancel countdown timer
    if game.data and game.data.countdownTimer then
        game.data.countdownTimer:Cancel()
        game.data.countdownTimer = nil
    end

    -- Release UI frame references
    if game.data then
        if game.data.paddle1Frame then
            game.data.paddle1Frame:Hide()
            game.data.paddle1Frame:SetParent(nil)
            game.data.paddle1Frame = nil
        end
        if game.data.paddle2Frame then
            game.data.paddle2Frame:Hide()
            game.data.paddle2Frame:SetParent(nil)
            game.data.paddle2Frame = nil
        end
        if game.data.ballFrame then
            game.data.ballFrame:Hide()
            game.data.ballFrame:SetParent(nil)
            game.data.ballFrame = nil
        end
        if game.data.playArea then
            game.data.playArea:Hide()
            game.data.playArea:SetParent(nil)
            game.data.playArea = nil
        end
        if game.data.window then
            game.data.window:Hide()
            game.data.window = nil
        end

        -- Clear text references
        game.data.p1ScoreText = nil
        game.data.p2ScoreText = nil
        game.data.countdownText = nil
    end

    -- Clear key states
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore then
        GameCore:ClearKeyStates()
    end

    -- GameUI handles window destruction
    local GameUI = HopeAddon:GetModule("GameUI")
    if GameUI then
        GameUI:DestroyGameWindow(gameId)
    end

    self.games[gameId] = nil
end

--============================================================
-- PUBLIC API
--============================================================

--[[
    Start a new Pong game
    @return string - Game ID
]]
function PongGame:StartGame()
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return nil end

    local gameId = GameCore:CreateGame(GameCore.GAME_TYPE.PONG, GameCore.GAME_MODE.LOCAL, nil)

    local game = GameCore:GetGame(gameId)
    if game then
        game.player1 = "Player 1"
        game.player2 = "Player 2"
    end

    GameCore:StartGame(gameId)

    return gameId
end

-- Register with addon
HopeAddon:RegisterModule("PongGame", PongGame)
HopeAddon.PongGame = PongGame

HopeAddon:Debug("PongGame module loaded")
