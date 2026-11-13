
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local WindUI = loadstring(game:HttpGet("http://localhost:8642/dist/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Tabs = {}

local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")
local ServerSearch = Loader.Require("src/Modules/ServerSearch.luau")
local Version = Loader.Require("src/Core/Utilities/version.luau")
local Logs = Loader.Require("src/Core/Utilities/logs.luau")
local ThemesLoader = Loader.Require("src/misc/Themes.luau")
local KeyModule = Loader.Require("src/Core/Utilities/key.luau")
local KEY = ""

local Flavors = ThemesLoader.Flavors
local CurrentTheme = "Catppuccin Mocha"

local function JoinDiscord(inv)
    if not inv then inv = "mochahub" end
    local success, err = pcall(function()
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                nonce = HttpService:GenerateGUID(false),
                args = {
                    code = inv
                }
            })
        })
    end)

    if not success then
        Logs:Log(`Failed to open Discord (ignore this if u dont have Discord app): {err}`, "ERROR")
    end
end

-- key window
local KeyWindow = WindUI:CreateWindow({
    Title = "Mocha Hub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.png"), -- lucide icon
    Author = "By ChatColours",
    Folder = "Mocha",
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(640, 460),
    MinSize = Vector2.new(640, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Transparent = true,
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    IconSize = 32,
    Acrylic = true,
    NewElements = false,
    Topbar = {
        Height = 60,           -- Height of the topbar
        ButtonsType = "Default" -- "Default" or "Mac" style
    },
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})

local KeyTab = KeyWindow:Tab({
    Title = "Key",
    Icon = "key-round", -- optional
    Locked = false,
})

KeyTab:Input({
    Title = "Enter Key",
    Desc = "If you have a key, enter it here.",
    Value = "",
    InputIcon = "user-key",
    Type = "Input", -- or "Textarea"
    Placeholder = "MOCHA-XXXX-XXXX-XXXX",
    Callback = function(input) 
        KEY = input
    end
})

KeyTab:Button({
    Title = "Submit Key",
    Desc = "Authenticate your key",
    Locked = false,
    Callback = function()
        local result = KeyModule.Validate({
            ["Username"] = game.Players.LocalPlayer.Name,
            ["Userid"] = game.Players.LocalPlayer.UserId,
            ["Tick"] = os.time(),
            ["Hwid"] = gethwid(),
            ["Key license"] = KEY
        })

        if result then
            if not result.Approved then
                Logs:Log(`Key was rejected: {result.Reason}`, "INFO")
                WindUI:Notify({
                    Title = "Mocha Hub",
                    Content = "Key rejected: ".. result.Reason,
                    Duration = 5, -- 3 seconds
                    Icon = "x",
                })
            elseif result.Approved then
                Logs:Log(`Key Accepted!`, "SUCCESS")
            end
        end
    end
})
print(type(KeyTab))

local Group = KeyTab:Group({})
local HStack = Group:HStack()
HStack:Button({
    Title = "Join Discord",
    Desc = "",
    Locked = false,
    Callback = function()
        setclipboard("https://discord.gg/mochahub")
        JoinDiscord()
        WindUI:Notify({
            Title = "Mocha Hub",
            Content = "Copied Discord server invite! Paste this on a browser to join",
            Duration = 3, -- 3 seconds
            Icon = "mail",
        })
    end
})

HStack:Button({
    Title = "Join Support",
    Desc = "",
    Locked = false,
    Callback = function()
        setclipboard("https://discord.gg/4eDHh4G9tw")
        JoinDiscord("4eDHh4G9tw")
        WindUI:Notify({
            Title = "Mocha Hub",
            Content = "Copied support server invite! Paste this on a browser to join",
            Duration = 3, -- 3 seconds
            Icon = "mail",
        })
    end
})

KeyTab:Paragraph({
    Title = "How to get key",
    Desc = "To get a key, you must be in the Discord server. Upon joining, verify. Once you have verified, go to the bot commands channel and use /gen-key using Mocha Bot. Keys last for 48 hours, but may be extended by staff."
})