--[[
    HopeAddon Pong Game
    Classic Pong with ball physics and paddle movement

    Controls:
    - Player 1: W/S keys
    - Player 2: Up/Down arrow keys

    Network Model (REMOTE mode):
    Half-Court Authority - each player owns physics on their half of the court.
    Ball ownership transfers at the midline (X=200) via CROSS events.
    MISS events handle scoring when the ball passes a player's goal line.
    This eliminates rubber banding since there's no position syncing.
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
    MIDLINE_X = 200,  -- PLAY_WIDTH / 2 - handoff point for half-court authority

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
    NETWORK_UPDATE_HZ = 10,       -- Network update rate (only for paddle position)
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
    -- Unregister network handlers to prevent handler accumulation on /reload
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        GameComms:UnregisterHandler("PONG", "MOVE")
        GameComms:UnregisterHandler("PONG", "END")
    end

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
    local GameCore = HopeAddon:GetModule("GameCore")
    local isRemote = game.mode == GameCore.GAME_MODE.REMOTE
    local isScoreChallenge = game.mode == GameCore.GAME_MODE.SCORE_CHALLENGE

    -- Determine if this player is the host (game creator controls ball physics)
    -- Player1 is the host, player2 (opponent who accepted) is the client
    local isHost = game.player1 == UnitName("player")

    -- Initialize pong-specific data with ui/state structure
    game.data = {
        ui = {
            -- UI references (populated in CreateUI)
            window = nil,
            scoreText = { p1 = nil, p2 = nil },
            playArea = nil,
            paddles = { p1 = nil, p2 = nil },
            ball = nil,
            countdown = { text = nil, timer = nil },
            opponentPanel = nil,  -- For SCORE_CHALLENGE mode
        },
        state = {
            -- Play area bounds
            playWidth = S.PLAY_WIDTH,
            playHeight = S.PLAY_HEIGHT,

            -- Mode tracking
            isRemote = isRemote,
            isScoreChallenge = isScoreChallenge,
            isHost = isHost,  -- Host controls ball physics, client receives updates
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

            -- Paddle 2 (right - P2 in LOCAL, AI in SCORE_CHALLENGE, opponent in REMOTE)
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

            -- Network interpolation for opponent paddle (smooth rendering)
            paddle2Target = nil, -- Target paddle2 position from network

            -- Half-court authority: each player owns physics on their half
            -- "local" = we simulate ball, "remote" = opponent simulates, "none" = ball inactive
            ballOwner = "local",
        },
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
    game.data.state.countdown = 3
    self:StartCountdown(gameId)
end

function PongGame:OnUpdate(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Check for opponent disconnect in REMOTE mode
    if state.isRemote and state.opponent then
        -- Don't trigger disconnect if game already ended
        local GameCore = HopeAddon:GetModule("GameCore")
        if GameCore and game.state ~= GameCore.STATE.PLAYING then return end

        local timeSinceLastMessage = GetTime() - (state.lastOpponentMessage or GetTime())
        if timeSinceLastMessage > 5 then  -- 5 second timeout
            HopeAddon:Print("Opponent disconnected from Pong game")
            if GameCore then
                GameCore:EndGame(gameId, "DISCONNECT")
            end
            return
        end
    end

    if state.paused or state.countdown > 0 then
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
        game.data.state.paused = true
    end
end

function PongGame:OnResume(gameId)
    local game = self.games[gameId]
    if game then
        game.data.state.paused = false
    end
end

function PongGame:OnEnd(gameId, reason)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Record stats for REMOTE games
    if state.isRemote and state.opponent then
        local Minigames = HopeAddon:GetModule("Minigames")
        if Minigames then
            local isWinner = game.winner == game.player1
            local result = isWinner and "win" or "lose"
            local myScore = game.score[1]
            local oppScore = game.score[2]

            Minigames:RecordGameResult(
                state.opponent,
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

    local ui = game.data.ui
    local state = game.data.state

    state.countdown = 3

    -- Cancel existing countdown timer
    if ui.countdown.timer then
        ui.countdown.timer:Cancel()
    end

    -- Update countdown UI
    if ui.countdown.text then
        ui.countdown.text:SetText(tostring(state.countdown))
        ui.countdown.text:Show()
    end

    -- Countdown timer
    local function tick()
        local currentGame = self.games[gameId]  -- Re-fetch each time
        if not currentGame then return end

        local currentState = currentGame.data.state
        local currentUI = currentGame.data.ui

        currentState.countdown = currentState.countdown - 1

        if currentState.countdown > 0 then
            if currentUI.countdown.text then
                currentUI.countdown.text:SetText(tostring(currentState.countdown))
            end
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayClick()
            end
            currentUI.countdown.timer = HopeAddon.Timer:After(1, tick)
        else
            currentUI.countdown.timer = nil
            if currentUI.countdown.text then
                currentUI.countdown.text:Hide()
            end
            if HopeAddon.Sounds then
                HopeAddon.Sounds:PlayAchievement()
            end
            self:ServeBall(gameId)
        end
    end

    ui.countdown.timer = HopeAddon.Timer:After(1, tick)
end

--[[
    Serve the ball
    Half-court authority: Host always generates serve, determines ownership based on direction
]]
function PongGame:ServeBall(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local ball = state.ball
    local S = self.SETTINGS

    -- In REMOTE mode, only host generates the serve
    if state.isRemote and not state.isHost then
        -- Client waits for CROSS event from host after serve
        ball.x = S.PLAY_WIDTH / 2 - S.BALL_SIZE / 2
        ball.y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2
        ball.speed = S.BALL_INITIAL_SPEED
        ball.dx = 0
        ball.dy = 0
        state.ballOwner = "none"  -- Wait for CROSS from host
        return
    end

    -- Host or non-REMOTE mode: reset ball position
    ball.x = S.PLAY_WIDTH / 2 - S.BALL_SIZE / 2
    ball.y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2
    ball.speed = S.BALL_INITIAL_SPEED

    -- Generate random serve angle (-45 to 45 degrees)
    local angle = (math.random() - 0.5) * math.pi / 2

    -- Direction based on who serves
    local direction = state.serving == 1 and 1 or -1

    ball.dx = math.cos(angle) * ball.speed * direction
    ball.dy = math.sin(angle) * ball.speed

    -- Half-court authority: determine ball ownership based on direction
    if state.isRemote then
        if ball.dx > 0 then
            -- Ball going toward opponent (right side) - send CROSS, they own it
            self:SendCross(gameId)
            state.ballOwner = "none"
        else
            -- Ball coming toward us (left side) - we own it
            state.ballOwner = "local"
        end
    end
end

--[[
    Update paddle positions based on input
]]
function PongGame:UpdatePaddles(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    if state.isScoreChallenge then
        -- SCORE_CHALLENGE mode: Player controls paddle1, AI controls paddle2
        self:UpdateLocalPaddle(gameId, dt)
        self:UpdateAIPaddle(gameId, dt)
    elseif state.isRemote then
        -- REMOTE mode: Only control paddle1 (local player)
        self:UpdateLocalPaddle(gameId, dt)
        -- Paddle2 updated by network messages, with smooth interpolation
        self:InterpolatePaddle2(gameId, dt)

        -- Send paddle position to opponent
        self:SendPaddlePosition(gameId, dt)
    else
        -- LOCAL mode: Control both paddles
        self:UpdateLocalPaddles(gameId, dt)
    end
end

--[[
    Update AI paddle for SCORE_CHALLENGE mode
    AI follows ball with slight delay - beatable but challenging
]]
function PongGame:UpdateAIPaddle(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local paddle2 = state.paddle2
    local ball = state.ball

    -- AI only reacts when ball is moving toward it
    if ball.dx > 0 then
        -- Calculate where ball will intersect paddle2's x position
        local timeToReach = (paddle2.x - ball.x) / ball.dx
        local predictedY = ball.y + ball.dy * timeToReach

        -- Clamp prediction to play area
        predictedY = GameCore:Clamp(predictedY, 0, S.PLAY_HEIGHT - paddle2.height)

        -- Move toward predicted position with 85% tracking (slight lag)
        local targetY = predictedY
        local diff = targetY - paddle2.y

        -- AI speed scales with ball speed for fairness
        local aiSpeed = S.PADDLE_SPEED * 0.85
        local maxMove = aiSpeed * dt

        if math.abs(diff) > maxMove then
            paddle2.y = paddle2.y + (diff > 0 and maxMove or -maxMove)
        else
            paddle2.y = paddle2.y + diff * 0.85
        end
    else
        -- Ball moving away, slowly return to center
        local centerY = S.PLAY_HEIGHT / 2 - paddle2.height / 2
        local diff = centerY - paddle2.y
        paddle2.y = paddle2.y + diff * 0.3 * dt
    end

    -- Clamp to play area
    paddle2.y = GameCore:Clamp(paddle2.y, 0, S.PLAY_HEIGHT - paddle2.height)
end

function PongGame:UpdateLocalPaddle(gameId, dt)
    local game = self.games[gameId]
    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local paddle1 = state.paddle1

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
    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    local paddle1 = state.paddle1
    local paddle2 = state.paddle2

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
    Interpolate paddle2 position for smooth rendering in REMOTE mode
]]
function PongGame:InterpolatePaddle2(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    if not GameCore then return end

    -- Smooth toward target position if we have one
    if state.paddle2Target then
        local paddle2 = state.paddle2
        -- Lerp toward target (30% per frame for smooth movement)
        paddle2.y = paddle2.y + (state.paddle2Target.y - paddle2.y) * 0.3
        paddle2.dy = state.paddle2Target.dy
    end

    -- Clamp to play area
    local paddle2 = state.paddle2
    paddle2.y = GameCore:Clamp(paddle2.y, 0, S.PLAY_HEIGHT - paddle2.height)
end

--[[
    Update ball position and handle collisions
    HALF-COURT AUTHORITY: Each player only runs physics on their half.
    Ball ownership transfers at the midline via CROSS events.
]]
function PongGame:UpdateBall(gameId, dt)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")
    local ball = state.ball
    local paddle1 = state.paddle1
    local paddle2 = state.paddle2

    -- REMOTE mode: Half-court authority
    if state.isRemote then
        -- Only process physics if we own the ball
        if state.ballOwner ~= "local" then
            return  -- Ball is on opponent's half or inactive
        end

        -- Move ball
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Top/bottom wall collision (we handle on our half)
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            self:PlayBounceSound()
        elseif ball.y + ball.size >= S.PLAY_HEIGHT then
            ball.y = S.PLAY_HEIGHT - ball.size
            ball.dy = -ball.dy
            self:PlayBounceSound()
        end

        -- Paddle 1 collision (our paddle - we are authoritative)
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
            -- No network send here - we send CROSS when ball leaves our half
        end

        -- Check if ball crossed midline (leaving our half toward opponent)
        if ball.dx > 0 and ball.x > S.MIDLINE_X then
            self:SendCross(gameId)
            state.ballOwner = "none"
            return
        end

        -- Check if we missed (ball passed our goal line)
        if ball.x + ball.size < 0 then
            self:SendMiss(gameId)
            self:Score(gameId, 2)  -- Opponent scores
            state.ballOwner = "none"
            self:ResetBall(gameId)
            self:StartCountdown(gameId)
            return
        end

        return  -- Don't run non-REMOTE logic
    end

    -- Non-REMOTE modes (LOCAL, SCORE_CHALLENGE): full physics locally
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

    -- Paddle 1 collision (left paddle)
    if ball.dx < 0 and GameCore:CheckCollision(
        ball.x, ball.y, ball.size, ball.size,
        paddle1.x, paddle1.y, paddle1.width, paddle1.height
    ) then
        ball.x = paddle1.x + paddle1.width
        ball.dx = -ball.dx

        local hitPos = (ball.y + ball.size / 2) - (paddle1.y + paddle1.height / 2)
        local normalizedHit = hitPos / (paddle1.height / 2)
        ball.dy = ball.dy + normalizedHit * 100

        ball.speed = math.min(ball.speed + S.BALL_SPEED_INCREMENT, S.BALL_MAX_SPEED)
        self:NormalizeBallSpeed(ball)

        self:PlayHitSound()
    end

    -- Paddle 2 collision (right paddle)
    if ball.dx > 0 and GameCore:CheckCollision(
        ball.x, ball.y, ball.size, ball.size,
        paddle2.x, paddle2.y, paddle2.width, paddle2.height
    ) then
        ball.x = paddle2.x - ball.size
        ball.dx = -ball.dx

        local hitPos = (ball.y + ball.size / 2) - (paddle2.y + paddle2.height / 2)
        local normalizedHit = hitPos / (paddle2.height / 2)
        ball.dy = ball.dy + normalizedHit * 100

        ball.speed = math.min(ball.speed + S.BALL_SPEED_INCREMENT, S.BALL_MAX_SPEED)
        self:NormalizeBallSpeed(ball)

        self:PlayHitSound()
    end

    -- Score detection
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
    In REMOTE mode with half-court authority:
    - Player 1 scores when opponent sends MISS (handled in OnOpponentMove)
    - Player 2 scores when we send MISS (handled in UpdateBall)
    The caller is responsible for reset/countdown in REMOTE mode.
]]
function PongGame:Score(gameId, player)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local S = self.SETTINGS
    local GameCore = HopeAddon:GetModule("GameCore")

    -- Update score
    GameCore:AddScore(gameId, player)

    -- Notify ScoreChallenge of score update (if in that mode)
    if state.isScoreChallenge then
        local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
        if ScoreChallenge then
            -- In Pong, player 1 is human, player 2 is AI
            -- We only care about player 1's score for the challenge
            ScoreChallenge:UpdateMyScore(game.score[1], game.score[2], 1)
        end
    end

    -- Play score sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayAchievement()
    end

    -- Check for win
    if game.score[player] >= S.WINNING_SCORE then
        -- In SCORE_CHALLENGE mode, notify ScoreChallenge
        if state.isScoreChallenge then
            local ScoreChallenge = HopeAddon:GetModule("ScoreChallenge")
            if ScoreChallenge then
                -- Final score: player's score, AI score doesn't matter
                ScoreChallenge:OnLocalGameEnded(game.score[1], game.score[2], 1)
            end
            -- Don't set winner here - ScoreChallenge handles it
            return
        end

        -- In REMOTE mode, send game over message
        if state.isRemote then
            -- Loser sends game over (player is the winner)
            local loser = player == 1 and 2 or 1
            self:SendGameOver(gameId, loser)
        end

        local winner = player == 1 and game.player1 or game.player2
        GameCore:SetWinner(gameId, winner)
        return
    end

    -- Set next server (loser serves)
    state.serving = player == 1 and 2 or 1

    -- In REMOTE mode, reset/countdown is handled by the caller (UpdateBall or OnOpponentMove)
    -- to avoid duplicate resets
    if state.isRemote then
        return
    end

    -- Non-REMOTE modes: reset and start countdown
    self:ResetBall(gameId)
    self:StartCountdown(gameId)
end

--[[
    Reset ball to center without starting
]]
function PongGame:ResetBall(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    local S = self.SETTINGS
    local ball = state.ball

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
    if not game then return end

    local state = game.data.state
    if not state.isRemote then return end

    local S = self.SETTINGS
    local syncInterval = 1 / S.NETWORK_UPDATE_HZ  -- 10 Hz for paddle sync only

    -- Throttle network updates for paddle position only
    -- Ball is synced via CROSS/MISS events for half-court authority model
    state.paddleSyncTimer = (state.paddleSyncTimer or 0) + dt
    if state.paddleSyncTimer >= syncInterval then
        state.paddleSyncTimer = 0

        local paddle1 = state.paddle1
        local GameComms = HopeAddon:GetModule("GameComms")
        if not GameComms or not state.opponent then return end

        -- Delta detection: skip if paddle hasn't moved significantly
        local lastY = state.lastSentPaddleY or 0
        local lastDy = state.lastSentPaddleDy or 0
        local paddleMoved = math.abs(paddle1.y - lastY) > 2 or math.abs(paddle1.dy - lastDy) > 10

        if paddleMoved then
            -- Send paddle position only (no ball sync - that's event-based now)
            state.syncSeq = (state.syncSeq or 0) + 1
            local data = string.format("PADDLE|%d|%.1f|%.1f", state.syncSeq, paddle1.y, paddle1.dy)
            GameComms:SendMove(state.opponent, "PONG", gameId, data)
            state.lastSentPaddleY = paddle1.y
            state.lastSentPaddleDy = paddle1.dy
        end
    end
end

function PongGame:OnOpponentMove(sender, gameId, data)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    if not state.isRemote then return end

    -- Check game is still playing
    local GameCore = HopeAddon:GetModule("GameCore")
    if GameCore and game.state ~= GameCore.STATE.PLAYING then return end

    -- Validate sender is the opponent
    if sender ~= state.opponent then
        HopeAddon:Debug("Ignoring PONG move from non-opponent:", sender)
        return
    end

    -- Update last message timestamp for disconnect detection
    state.lastOpponentMessage = GetTime()

    local S = self.SETTINGS

    -- Parse message type
    local msgType, p1, p2, p3, p4, p5 = strsplit("|", data)

    if msgType == "PADDLE" then
        -- Opponent's paddle position update
        -- Format: PADDLE|seq|y|dy
        local seq = tonumber(p1)
        if seq and state.lastReceivedSeq and seq <= state.lastReceivedSeq then
            return  -- Old/duplicate message, ignore
        end
        state.lastReceivedSeq = seq

        -- Store target for interpolation
        state.paddle2Target = {
            y = tonumber(p2) or state.paddle2.y,
            dy = tonumber(p3) or state.paddle2.dy,
        }

    elseif msgType == "CROSS" then
        -- Ball crossing from opponent's half toward us
        -- Format: CROSS|dy|speed
        local receivedDy = tonumber(p1) or 0
        local receivedSpeed = tonumber(p2) or S.BALL_INITIAL_SPEED

        local ball = state.ball

        -- Spawn ball at midline, coming toward us (from the right edge of our view)
        ball.x = S.MIDLINE_X - ball.size
        ball.y = S.PLAY_HEIGHT / 2 - S.BALL_SIZE / 2
        ball.dy = receivedDy
        ball.speed = receivedSpeed

        -- Calculate dx (coming toward our paddle = negative direction)
        local dySq = receivedDy * receivedDy
        local speedSq = receivedSpeed * receivedSpeed
        ball.dx = -math.sqrt(math.max(0, speedSq - dySq))

        state.ballOwner = "local"  -- Take ownership
        self:PlayBounceSound()

    elseif msgType == "MISS" then
        -- Opponent missed - we score!
        self:Score(gameId, 1)
        state.ballOwner = "none"
        self:ResetBall(gameId)
        self:StartCountdown(gameId)
    end
end

--[[
    Send CROSS event when ball crosses midline toward opponent
    This transfers ball ownership to the opponent
    dy is mirrored (negated) for opponent's perspective
]]
function PongGame:SendCross(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    if not state.isRemote then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms or not state.opponent then return end

    local ball = state.ball
    -- Send dy (negated for mirrored perspective) and speed
    -- Opponent will spawn ball at their midline edge coming toward them
    local data = string.format("CROSS|%.1f|%.1f", -ball.dy, ball.speed)
    GameComms:SendMove(state.opponent, "PONG", gameId, data)
end

--[[
    Send MISS event when ball passes our goal line
    Opponent will increment their score
]]
function PongGame:SendMiss(gameId)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    if not state.isRemote then return end

    local GameComms = HopeAddon:GetModule("GameComms")
    if not GameComms or not state.opponent then return end

    GameComms:SendMove(state.opponent, "PONG", gameId, "MISS")
end

function PongGame:SendGameOver(gameId, loser)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state
    if not state.isRemote then return end

    local data = "GAMEOVER|" .. tostring(loser)

    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms and state.opponent then
        GameComms:SendEnd(state.opponent, "PONG", gameId, data)
    end
end

function PongGame:OnOpponentGameOver(sender, gameId, data)
    local game = self.games[gameId]
    if not game then return end

    local state = game.data.state

    -- Validate sender is the opponent
    if state.isRemote and sender ~= state.opponent then
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

    local ui = game.data.ui
    local state = game.data.state
    local GameUI = HopeAddon:GetModule("GameUI")
    if not GameUI then return end

    local S = self.SETTINGS

    -- Create game window (use larger window for Score Challenge to fit opponent panel)
    local windowType = state.isScoreChallenge and "PONG_CHALLENGE" or "PONG"
    local window = GameUI:CreateGameWindow(gameId, "Pong of War", windowType)
    if not window then return end

    ui.window = window  -- Store in ui table

    local content = window.content

    -- Score display at top (offset left when opponent panel is shown)
    local scoreContainer = CreateFrame("Frame", nil, content)
    scoreContainer:SetSize(200, 40)
    local scoreOffsetX = state.isScoreChallenge and -60 or 0
    scoreContainer:SetPoint("TOP", scoreOffsetX, -5)

    local p1Score = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    p1Score:SetPoint("LEFT", 20, 0)
    p1Score:SetText("0")
    p1Score:SetTextColor(0.2, 0.8, 0.2)
    ui.scoreText.p1 = p1Score

    local vsText = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    vsText:SetPoint("CENTER", 0, 0)
    vsText:SetText("-")
    vsText:SetTextColor(0.6, 0.6, 0.6)

    local p2Score = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    p2Score:SetPoint("RIGHT", -20, 0)
    p2Score:SetText("0")
    p2Score:SetTextColor(0.8, 0.2, 0.2)
    ui.scoreText.p2 = p2Score

    -- Play area (offset left when opponent panel is shown to avoid overlap)
    local playArea = GameUI:CreatePlayArea(content, S.PLAY_WIDTH, S.PLAY_HEIGHT)
    local playAreaOffsetX = state.isScoreChallenge and -60 or 0
    playArea:SetPoint("CENTER", playAreaOffsetX, -10)
    ui.playArea = playArea

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
    ui.paddles.p1 = paddle1Frame

    -- Paddle 2 (right)
    local paddle2Frame = CreateFrame("Frame", nil, playArea)
    paddle2Frame:SetSize(S.PADDLE_WIDTH, S.PADDLE_HEIGHT)
    local paddle2Tex = paddle2Frame:CreateTexture(nil, "ARTWORK")
    paddle2Tex:SetAllPoints()
    paddle2Tex:SetColorTexture(0.8, 0.2, 0.2, 1)
    ui.paddles.p2 = paddle2Frame

    -- Ball
    local ballFrame = CreateFrame("Frame", nil, playArea)
    ballFrame:SetSize(S.BALL_SIZE, S.BALL_SIZE)
    local ballTex = ballFrame:CreateTexture(nil, "ARTWORK")
    ballTex:SetAllPoints()
    ballTex:SetColorTexture(1, 1, 1, 1)
    ui.ball = ballFrame

    -- Countdown text
    local countdownText = playArea:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    countdownText:SetPoint("CENTER")
    countdownText:SetText("3")
    countdownText:SetTextColor(1, 0.84, 0)
    countdownText:Hide()
    ui.countdown.text = countdownText

    -- Opponent panel for SCORE_CHALLENGE mode
    local GameCore = HopeAddon:GetModule("GameCore")
    if state.isScoreChallenge then
        ui.opponentPanel = self:CreateOpponentPanel(content, state.opponent)
        ui.opponentPanel:SetPoint("TOPRIGHT", content, "TOPRIGHT", -10, -45)
    end

    -- Controls hint
    local controlsText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    controlsText:SetPoint("BOTTOM", 0, 5)

    if state.isScoreChallenge then
        controlsText:SetText("W/S to move | Race to 5 vs AI | Opponent: " .. (state.opponent or "Unknown"))
    elseif game.mode == GameCore.GAME_MODE.REMOTE then
        controlsText:SetText("W/S to move | vs " .. (state.opponent or "Opponent"))
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

--[[
    Create opponent status panel for SCORE_CHALLENGE mode
    @param parent Frame
    @param opponentName string
    @return Frame
]]
function PongGame:CreateOpponentPanel(parent, opponentName)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(100, 120)

    -- Background
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    -- Border
    local border = panel:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.4, 0.4, 0.4, 1)

    -- Inner bg
    local innerBg = panel:CreateTexture(nil, "ARTWORK")
    innerBg:SetPoint("TOPLEFT", 1, -1)
    innerBg:SetPoint("BOTTOMRIGHT", -1, 1)
    innerBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", 0, -8)
    title:SetText(opponentName or "Opponent")
    title:SetTextColor(1, 0.84, 0)  -- Gold

    -- Score
    local scoreLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scoreLabel:SetPoint("TOP", title, "BOTTOM", 0, -10)
    scoreLabel:SetText("Score")
    scoreLabel:SetTextColor(0.6, 0.6, 0.6)

    local scoreValue = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scoreValue:SetPoint("TOP", scoreLabel, "BOTTOM", 0, -2)
    scoreValue:SetText("0")
    scoreValue:SetTextColor(1, 1, 1)
    panel.scoreValue = scoreValue

    -- Status
    local statusLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusLabel:SetPoint("TOP", scoreValue, "BOTTOM", 0, -10)
    statusLabel:SetText("[PLAYING]")
    statusLabel:SetTextColor(0.2, 0.8, 0.2)  -- Green
    panel.statusLabel = statusLabel

    return panel
end

--[[
    Update opponent panel in SCORE_CHALLENGE mode
]]
function PongGame:UpdateOpponentPanel(gameId, score, lines, level, status)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    if not ui.opponentPanel then return end

    local panel = ui.opponentPanel
    if panel.scoreValue then
        panel.scoreValue:SetText(tostring(score))
    end
    if panel.statusLabel then
        if status == "FINISHED" then
            panel.statusLabel:SetText("[FINISHED]")
            panel.statusLabel:SetTextColor(1, 0.5, 0)  -- Orange
        elseif status == "WAITING" then
            panel.statusLabel:SetText("[WAITING]")
            panel.statusLabel:SetTextColor(0.8, 0.8, 0.2)  -- Yellow
        else
            panel.statusLabel:SetText("[PLAYING]")
            panel.statusLabel:SetTextColor(0.2, 0.8, 0.2)  -- Green
        end
    end
end

function PongGame:UpdateUI(gameId)
    local game = self.games[gameId]
    if not game then return end

    local ui = game.data.ui
    local state = game.data.state

    -- Update scores
    if ui.scoreText.p1 then
        ui.scoreText.p1:SetText(tostring(game.score[1]))
    end
    if ui.scoreText.p2 then
        ui.scoreText.p2:SetText(tostring(game.score[2]))
    end

    -- Update paddle positions (relative to play area bottom-left)
    if ui.paddles.p1 and ui.playArea then
        ui.paddles.p1:SetPoint("BOTTOMLEFT", ui.playArea, "BOTTOMLEFT",
            state.paddle1.x,
            state.paddle1.y)
    end

    if ui.paddles.p2 and ui.playArea then
        ui.paddles.p2:SetPoint("BOTTOMLEFT", ui.playArea, "BOTTOMLEFT",
            state.paddle2.x,
            state.paddle2.y)
    end

    -- Update ball position
    if ui.ball and ui.playArea then
        ui.ball:SetPoint("BOTTOMLEFT", ui.playArea, "BOTTOMLEFT",
            state.ball.x,
            state.ball.y)
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
        if game and game.data and game.data.state then
            game.data.state.paused = not game.data.state.paused
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

    if game.data and game.data.ui then
        local ui = game.data.ui

        -- Cancel countdown timer
        if ui.countdown.timer then
            ui.countdown.timer:Cancel()
            ui.countdown.timer = nil
        end

        -- Release paddle frame references
        if ui.paddles.p1 then
            ui.paddles.p1:Hide()
            ui.paddles.p1:SetParent(nil)
            ui.paddles.p1 = nil
        end
        if ui.paddles.p2 then
            ui.paddles.p2:Hide()
            ui.paddles.p2:SetParent(nil)
            ui.paddles.p2 = nil
        end

        -- Release ball frame
        if ui.ball then
            ui.ball:Hide()
            ui.ball:SetParent(nil)
            ui.ball = nil
        end

        -- Release play area
        if ui.playArea then
            ui.playArea:Hide()
            ui.playArea:SetParent(nil)
            ui.playArea = nil
        end

        -- Release opponent panel (SCORE_CHALLENGE mode)
        if ui.opponentPanel then
            ui.opponentPanel:Hide()
            ui.opponentPanel:SetParent(nil)
            ui.opponentPanel = nil
        end

        -- Hide window (GameUI handles destruction)
        if ui.window then
            -- Clear script handlers to prevent memory leaks from closures
            ui.window:SetScript("OnKeyDown", nil)
            ui.window:SetScript("OnKeyUp", nil)
            ui.window:Hide()
            ui.window = nil
        end

        -- Clear text references
        ui.scoreText.p1 = nil
        ui.scoreText.p2 = nil
        ui.countdown.text = nil
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
