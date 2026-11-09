local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local logs = Loader.Require("src/Core/Utilities/logs.luau")

local LocalPlayer = Players.LocalPlayer

local WorkerURL = "wss://mochasocket.chatcolours-lua.workers.dev"

local WebSocket = WebSocket or (syn and syn.websocket)
if not WebSocket then
    logs:Log("WebSocket is not supported", "WARN")
    return
end

local Connection
local Running = true
local ReconnectDelay = 5
local HeartbeatInterval = 15

local function Connect()
    if Connection then
        return true
    end

    local URL = WorkerURL
        .. "/ws?userid=" .. LocalPlayer.UserId
        .. "&username=" .. HttpService:UrlEncode(LocalPlayer.Name)

    local Success, Result = pcall(function()
        return WebSocket.connect(URL)
    end)

    if not Success then
        logs:Log("WebSocket connection failed:".. Result, "ERROR")
        return false
    end

    local Socket = Result
    Connection = Socket
    logs:Log("Connected to Cloudflare Worker!", "SUCCESS")

    Socket.OnMessage:Connect(function(Message)
        if Message == "pong" then
            logs:Log("Heartbeat acknowledged", "INFO")
        else
            logs:Log("Received:".. Message, "INFO")
        end
    end)

    Socket.OnClose:Connect(function()
        logs:Log("Disconnected from WebSocket", "INFO")

        if Connection == Socket then
            Connection = nil
        end
    end)

    return true
end

local function Disconnect()
    Running = false

    if Connection then
        pcall(function()
            Connection:Close()
        end)

        Connection = nil
    end
end

task.spawn(function()
    while Running do
        if not Connection then
            if not Connect() then
                task.wait(ReconnectDelay)
                continue
            end
        end

        local Socket = Connection

        local Success, Error = pcall(function()
            Socket:Send("ping")
        end)

        if not Success then
            logs:Log("Heartbeat failed: ".. Error, "ERROR")

            pcall(function()
                Socket:Close()
            end)

            if Connection == Socket then
                Connection = nil
            end

            task.wait(ReconnectDelay)
        else
            task.wait(HeartbeatInterval)
        end
    end
end)