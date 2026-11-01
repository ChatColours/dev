local module = {}
local logsession = {}
logsession.__index = logsession
module.__index = module
_G.logHistory = _G.logHistory or {}
_G.UpdateConnection = nil
local LastRestoredView = nil
local maxLogs = 300

local CoreGui = game:GetService("CoreGui")
local DevConsole = CoreGui:WaitForChild("DevConsoleMaster")
local DevWindow = DevConsole:WaitForChild("DevConsoleWindow")
local DevUI = DevWindow:WaitForChild("DevConsoleUI")
local MainView = DevUI:WaitForChild("MainView")
local ClientLogView = MainView:WaitForChild("ClientLog")
local icon = getcustomasset("Steve/assets/icon.png")

_G.LogSession = nil
local HTMLTemplate = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SteveHub - Session Logs</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #0B0B0E;
            color: #E4E4E7;
            font-family: Consolas, monospace;
            font-size: 14px;
        }

        header {
            background: #141417;
            border-bottom: 1px solid #27272A;
            padding: 28px 36px;
        }

        .header-top {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .logo {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            object-fit: contain;
        }

        h1 {
            margin: 0;
            font-size: 26px;
        }

        h1 span {
            color: #A78BFA;
        }

        .header-top p {
            margin: 8px 0 0;
            color: #71717A;
            font-size: 12px;
        }

        .stats {
            display: flex;
            gap: 16px;
            margin-top: 28px;
        }

        .stat-card {
            flex: 1;
            background: #1C1C20;
            border: 1px solid #303036;
            border-radius: 10px;
            padding: 18px;
        }

        .stat-card p {
            color: #A1A1AA;
            font-size: 12px;
            margin: 0;
        }

        .stat-card h2 {
            font-size: 28px;
            margin: 12px 0 0;
        }

        #total-warnings {
            color: #FBBF24;
        }

        #total-errors {
            color: #F87171;
        }

        .session-info {
            display: flex;
            justify-content: space-between;
            color: #71717A;
            font-size: 12px;
            margin-top: 20px;
        }

        main {
            padding: 28px 36px;
        }

        main h2 {
            font-size: 16px;
            margin: 0 0 20px;
        }

        #logs {
            background: #111113;
            border: 1px solid #27272A;
            border-radius: 10px;
            min-height: 300px;
            padding: 12px;
        }

        .log-entry {
            display: flex;
            align-items: baseline;
            gap: 12px;
            padding: 8px 12px;
            border-bottom: 1px solid #27272A;
            transition: background 0.15s ease;
        }

        .log-entry:last-child {
            border-bottom: none;
        }

        .log-entry:hover {
            background: #1C1C20;
        }

        .timestamp {
            color: #71717A;
            flex-shrink: 0;
        }

        .log-type {
            font-weight: bold;
            min-width: 80px;
            flex-shrink: 0;
        }

        .message {
            color: #E4E4E7;
            overflow-wrap: anywhere;
            white-space: pre-wrap;
            flex: 1;
        }

        @media (max-width: 600px) {
            header {
                padding: 20px;
            }

            main {
                padding: 20px;
            }

            .stats {
                gap: 8px;
            }

            .stat-card {
                padding: 12px;
            }

            .stat-card h2 {
                font-size: 22px;
            }

            .log-entry {
                gap: 8px;
                flex-wrap: wrap;
            }

            .log-type {
                min-width: auto;
            }

            .message {
                flex-basis: 100%%;
            }
        }
    </style>
</head>

<body>
    <header>
        <div class="header-top">
            <img
                src="https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.jpg"
                class="logo"
                alt="SteveHub Icon"
            >

            <div>
                <h1>SteveHub <span>Logs</span></h1>
                <p>Session diagnostics & activity</p>
            </div>
        </div>

        <div class="stats">
            <div class="stat-card">
                <p>Total Logs</p>
                <h2 id="total-logs">0</h2>
            </div>

            <div class="stat-card">
                <p>Warnings</p>
                <h2 id="total-warnings">0</h2>
            </div>

            <div class="stat-card">
                <p>Errors</p>
                <h2 id="total-errors">0</h2>
            </div>
        </div>

        <div class="session-info">
            <span>Started: %s</span>
            <span>SteveHub v2.0</span>
        </div>
    </header>

    <main>
        <h2>Console Output</h2>

        <div id="logs">
]]

local EntryTemplate = [[
<div class="log-entry">
    <span class="timestamp">[%s]</span>
    <span class="log-type" style="color: #%s;">[%s]</span>
    <span class="message">%s</span>
</div>
]]

local LogTypes = {
    INFO = Color3.fromRGB(96, 165, 250),
    SUCCESS = Color3.fromRGB(74, 222, 128),
    WARN = Color3.fromRGB(251, 191, 36),
    ERROR = Color3.fromRGB(248, 113, 113),
    DEBUG = Color3.fromRGB(168, 162, 158)
}

local function MakeLog()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 29)
    Frame.BackgroundTransparency = 1

    local Image = Instance.new("ImageLabel", Frame)
    Image.Name = "image"
    Image.Size = UDim2.new(0, 14, 0, 14)
    Image.Position = UDim2.new(0, 3, 0, 0)
    Image.BackgroundTransparency = 1
    Image.Image = icon

    local TextLabel = Instance.new("TextLabel", Frame)
    TextLabel.Name = "msg"
    TextLabel.Size = UDim2.new(1, 0, 0, 29)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Position = UDim2.new(0, 20, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextSize = 15
    TextLabel.RichText = true
    TextLabel.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

    local Index = ClientLogView:GetChildren()
    Index = #Index + 1
    Frame.Name = tostring(Index)
    Frame.LayoutOrder = Index

    return Frame, TextLabel, Image
end

local Colors = {
    red = "#F87171",
    green = "#4ADE80",
    blue = "#60A5FA",
    yellow = "#FBBF24",
    purple = "#A78BFA",
    orange = "#FB923C",
    pink = "#F472B6",
    gray = "#A1A1AA",
    white = "#FFFFFF"
}
local function EscapeRichText(message: string): string
    return message
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
        :gsub('"', "&quot;")
        :gsub("'", "&apos;")
end

local function FormatTags(message: string): string
    message = EscapeRichText(message)

    for name, hex in pairs(Colors) do
        message = message:gsub(
            "&lt;" .. name .. "&gt;",
            '<font color="' .. hex .. '">'
        )

        message = message:gsub(
            "&lt;/" .. name .. "&gt;",
            "</font>"
        )
    end

    for _, tag in ipairs({"b", "i", "u", "s"}) do
        message = message:gsub("&lt;" .. tag .. "&gt;", "<" .. tag .. ">")
        message = message:gsub("&lt;/" .. tag .. "&gt;", "</" .. tag .. ">")
    end
    return message
end

function logsession.new()
    if _G.LogSession then
        return _G.LogSession
    end
    local self = setmetatable({}, logsession)
    self.SessionStarted = os.date("%d %b %Y, %H:%M:%S")
    self.SessionName = os.date("Session_%Y-%m-%d_%H-%M-%S")
    self.LogFile = "Steve/logs/" .. self.SessionName .. ".html"
    _G.LogSession = self
    return self
end

function logsession:InitializeLogs()
    if not isfolder("Steve") then
        makefolder("Steve")
    end

    if not isfolder("Steve/logs") then
        makefolder("Steve/logs")
    end

    writefile(
        self.LogFile,
        string.format(HTMLTemplate, self.SessionStarted)
    )
end

function module:Log(message: string, logType: string?, customColor: Color3?)
    logType = string.upper(logType or "INFO")
    local color = customColor or LogTypes[logType] or Color3.new(1, 1, 1)
    local hex = color:ToHex()
    local timestamp = os.date("%H:%M:%S")
    local formattedMessage = FormatTags(tostring(message))

    local formatted = string.format(
        '<font color="#71717A">[%s]</font> <font color="#A78BFA"><b>[STEVEHUB]</b></font> <font color="#%s"><b>[%s]</b></font> %s',
        timestamp,
        hex,
        logType,
        formattedMessage
    )

    local frame, txtlbl, img = MakeLog()
    txtlbl.Text = formatted
    img.Image = icon
    frame.Parent = ClientLogView

    table.insert(_G.logHistory, formatted)
    if #_G.logHistory > maxLogs then
        table.remove(_G.logHistory, 1)
    end

    if _G.LogSession then
        local Entry = string.format(
            EntryTemplate,
            timestamp,
            hex,
            logType,
            message
        )

        appendfile(_G.LogSession.LogFile, Entry)
    end
end

local function RestoreLogs()
    if LastRestoredView == ClientLogView then
        return
    end

    LastRestoredView = ClientLogView

    for _, log in ipairs(_G.logHistory) do
        local frame, txtlbl, img = MakeLog()

        txtlbl.Text = log
        img.Image = icon
        frame.Parent = ClientLogView
    end
end

if not _G.UpdateConnection then
    _G.UpdateConnection = DevUI.ChildAdded:Connect(function(child)
        if child.Name == "MainView" then
            MainView = child
            ClientLogView = MainView:WaitForChild("ClientLog")

            task.defer(function()
                RestoreLogs()
            end)
        end
    end)
end

return module, logsession