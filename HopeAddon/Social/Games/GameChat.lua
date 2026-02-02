--[[
    HopeAddon Game Chat
    Reusable in-game chat system for multiplayer games

    Usage:
        /gc <message>       - Send chat to opponent
        /gamechat <message> - Same as /gc

    Features:
        - Works with any GameCore-based game
        - Messages display in chat with [Game] prefix
        - Can be embedded in game windows via CreateChatDisplay()
        - Stores recent message history
]]

local GameChat = {}

--============================================================
-- CONSTANTS
--============================================================

GameChat.MAX_MESSAGES = 20  -- Keep last 20 messages in history

--============================================================
-- MODULE STATE
--============================================================

GameChat.chatMessages = {}  -- Recent messages { sender, message, time }
GameChat.chatFrame = nil    -- Optional embedded UI frame
GameChat.fontStringPool = {}  -- Pool of reusable FontStrings

--============================================================
-- LIFECYCLE
--============================================================

function GameChat:OnInitialize()
    HopeAddon:Debug("GameChat initializing...")
end

function GameChat:OnEnable()
    -- Register with GameComms for CHAT messages
    local GameComms = HopeAddon:GetModule("GameComms")
    if GameComms then
        -- Register handler for all game types using wildcard
        -- GameComms routes GCHAT messages through HandleChat
        GameComms:RegisterHandler("*", "CHAT", function(sender, gameId, data)
            self:OnChatReceived(sender, gameId, data)
        end)
    end

    HopeAddon:Debug("GameChat enabled")
end

function GameChat:OnDisable()
    -- Clear message history
    self.chatMessages = {}

    -- Clear the FontString pool
    wipe(self.fontStringPool)

    -- Cleanup UI if exists
    if self.chatFrame then
        self.chatFrame:Hide()
        self.chatFrame = nil
    end
end

--============================================================
-- MESSAGING
--============================================================

--[[
    Send a chat message to opponent in the current active game
    @param message string - Message to send
]]
function GameChat:SendMessage(message)
    if not message or message == "" then
        HopeAddon:Print("Usage: /gc <message>")
        return
    end

    local GameCore = HopeAddon:GetModule("GameCore")
    local GameComms = HopeAddon:GetModule("GameComms")

    if not GameCore or not GameComms then
        HopeAddon:Print("Game modules not loaded!")
        return
    end

    -- Find any active game with an opponent
    local activeGame = nil
    local activeGameId = nil

    for gameId, game in pairs(GameCore.activeGames) do
        if game.opponent and game.state ~= GameCore.STATE.ENDED then
            activeGame = game
            activeGameId = gameId
            break
        end
    end

    if not activeGame or not activeGame.opponent then
        HopeAddon:Print("No active multiplayer game to chat in!")
        return
    end

    -- Send via GameComms GCHAT message type
    GameComms:SendGameMessage(activeGame.opponent, "GCHAT",
        activeGame.gameType, activeGameId, message)

    -- Display locally
    self:DisplayMessage(UnitName("player"), message)
end

--[[
    Handle incoming chat message from opponent
    @param sender string - Player who sent message
    @param gameId string - Game ID (may be nil)
    @param message string - Chat message content
]]
function GameChat:OnChatReceived(sender, gameId, message)
    if not sender or not message then return end

    -- Display the message
    self:DisplayMessage(sender, message)

    -- Play subtle notification sound
    if HopeAddon.Sounds then
        HopeAddon.Sounds:PlayClick()
    end
end

--[[
    Display a chat message (from self or opponent)
    @param sender string - Player name
    @param message string - Message content
]]
function GameChat:DisplayMessage(sender, message)
    -- Add to history
    table.insert(self.chatMessages, {
        sender = sender,
        message = message,
        time = GetTime()
    })

    -- Trim old messages
    while #self.chatMessages > self.MAX_MESSAGES do
        table.remove(self.chatMessages, 1)
    end

    -- Print to chat frame with colored formatting
    local isMe = sender == UnitName("player")
    local nameColor = isMe and "|cFF00FF00" or "|cFFFFD700"
    local prefix = "|cFF9B30FF[Game]|r "

    HopeAddon:Print(prefix .. nameColor .. sender .. ":|r " .. message)

    -- Update embedded UI if visible
    self:UpdateChatDisplay()
end

--============================================================
-- EMBEDDED UI (Optional)
--============================================================

--[[
    Create an embeddable chat display frame for game windows
    @param parent Frame - Parent frame to attach to
    @return Frame - The chat display frame
]]
function GameChat:CreateChatDisplay(parent)
    if self.chatFrame then
        self.chatFrame:SetParent(parent)
        self.chatFrame:Show()
        return self.chatFrame
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(200, 100)

    -- Semi-transparent background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.5)

    -- Border
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    frame.border:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.title:SetPoint("TOP", 0, -4)
    frame.title:SetText("|cFFFFD700Game Chat|r")

    -- Scroll frame for messages
    frame.scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 8, -20)
    frame.scroll:SetPoint("BOTTOMRIGHT", -28, 8)

    -- Content frame
    frame.content = CreateFrame("Frame", nil, frame.scroll)
    frame.content:SetSize(160, 300)
    frame.scroll:SetScrollChild(frame.content)

    -- Message text pool
    frame.messageTexts = {}

    self.chatFrame = frame
    self:UpdateChatDisplay()

    return frame
end

--[[
    Update the embedded chat display with recent messages
    Uses FontString pooling to prevent memory leaks
]]
function GameChat:UpdateChatDisplay()
    if not self.chatFrame or not self.chatFrame.content then return end

    local content = self.chatFrame.content

    -- Return all FontStrings to pool (don't create new ones)
    for _, text in ipairs(self.chatFrame.messageTexts or {}) do
        text:Hide()
        text:SetText("")
        table.insert(self.fontStringPool, text)
    end
    self.chatFrame.messageTexts = {}

    -- Add messages (most recent at bottom)
    local yOffset = 0
    local startIdx = math.max(1, #self.chatMessages - 10)

    for i = startIdx, #self.chatMessages do
        local msg = self.chatMessages[i]

        -- Reuse from pool or create new
        local text = table.remove(self.fontStringPool)
        if not text then
            text = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end

        text:ClearAllPoints()
        text:SetPoint("TOPLEFT", 2, -yOffset)
        text:SetWidth(156)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(true)
        text:Show()

        local isMe = msg.sender == UnitName("player")
        local nameColor = isMe and "|cFF00FF00" or "|cFFFFD700"
        text:SetText(nameColor .. msg.sender .. ":|r " .. msg.message)

        table.insert(self.chatFrame.messageTexts, text)

        -- Calculate height for next message
        yOffset = yOffset + (text:GetStringHeight() or 14) + 2
    end

    -- Update content height
    content:SetHeight(math.max(yOffset, 100))

    -- Scroll to bottom
    if self.chatFrame.scroll then
        self.chatFrame.scroll:SetVerticalScroll(
            self.chatFrame.scroll:GetVerticalScrollRange() or 0
        )
    end
end

--[[
    Get recent chat messages
    @return table - Array of { sender, message, time }
]]
function GameChat:GetMessages()
    return self.chatMessages
end

--[[
    Clear chat history
]]
function GameChat:ClearHistory()
    self.chatMessages = {}
    self:UpdateChatDisplay()
end

-- Register module
HopeAddon:RegisterModule("GameChat", GameChat)
HopeAddon:Debug("GameChat module loaded")
