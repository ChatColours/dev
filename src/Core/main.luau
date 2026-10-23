local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()

local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")
local ServerSearch = Loader.Require("src/Modules/ServerSearch.luau")
local Version = Loader.Require("src/Core/Utilities/version.luau")

const Services = {
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}
local Hooks = {}

local SupportedGames = {
    [11137575513] = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/TheChosenOne"
}

local function SafeRead(path : string)
    if isfile(path) then
        return readfile(path)
    else
        writefile(path, "")
        return ""
    end
end

-- function checking --

local ExeFunctions = {
    ["hookfunction"] = type(hookfunction) == "function",
    ["hookmetamethod"] = type(hookmetamethod) == "function",
    ["oth.hook"] = oth ~= nil and type(oth.hook) == "function",
    ["oth.unhook"] = oth ~= nil and type(oth.unhook) == "function",
    ["isnetworkowner"] = type(isnetworkowner) == "function"
}

local function GetFailedAndPassed()
    local pass, fail = 0, 0
    for i, v in pairs(ExeFunctions) do
        if v == true then
            pass += 1 
        else
            fail += 1
        end
    end

    return pass, fail
end

-- main window --

local Window = WindUI:CreateWindow({
    Title = "Steve Hub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.jpg"), -- lucide icon
    Author = "By ChatColours",
    Folder = "Steve",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Transparent = true,
    Background = FetchAsset("background.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/background.png"),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    IconSize = 32,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})
Window:Tag({
    Title = Version:sub(1, 7),
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0, -- from 0 to 13
})

WindUI:AddTheme({
    Name = "Minecraft",

    -- Stone / dirt background
    Accent = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromHex("#8B6B47"),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromHex("#59422F"),
            Transparency = 0
        }
    }, {
        Rotation = 45
    }),

    Background = Color3.fromHex("#292722"),
    BackgroundTransparency = 0,

    -- Text
    Text = Color3.fromHex("#F0E9DC"),
    Placeholder = Color3.fromHex("#A99F90"),
    Icon = Color3.fromHex("#B6A38A"),
    Outline = Color3.fromHex("#50483F"),

    -- Stone buttons
    Button = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromHex("#48443E"),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromHex("#302D29"),
            Transparency = 0
        }
    }, {
        Rotation = 90
    }),

    Hover = Color3.fromHex("#A88B62"),

    -- Window
    WindowBackground = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromHex("#302B25"),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromHex("#1A1917"),
            Transparency = 0
        }
    }, {
        Rotation = 90
    }),

    WindowShadow = Color3.fromHex("#0D0B09"),

    -- Topbar
    WindowTopbarButtonIcon = Color3.fromHex("#C9BAA5"),
    WindowTopbarTitle = Color3.fromHex("#F5EEE2"),
    WindowTopbarAuthor = Color3.fromHex("#C4A16D"),
    WindowTopbarIcon = Color3.fromHex("#D1BA8E"),

    -- Tabs
    TabBackground = Color3.fromHex("#40382F"),
    TabTitle = Color3.fromHex("#EDE3D3"),
    TabIcon = Color3.fromHex("#BBA88E"),

    -- Elements
    ElementBackground = Color3.fromHex("#332F29"),
    ElementBackgroundHover = Color3.fromHex("#463D32"),
})

WindUI:SetTheme("Minecraft")

local ReadMe = Window:Tab({
    Title = "Read Me",
    Icon = "file-text", -- optional
    Locked = false,
})
local passedFunctions, failedFunctions = GetFailedAndPassed()
local supportedFunctionstxt = `Your executor, {identifyexecutor()}, supports {tostring(passedFunctions)} out of {tostring(passedFunctions + failedFunctions)} \n \n`

for i, v in pairs(ExeFunctions) do
    supportedFunctionstxt ..= i .. ": " .. (v == true and "✅" or "❌") .. "\n"
end

ReadMe:Paragraph({
    Title = "Supported Functions",
    Desc = supportedFunctionstxt,
    Color = "Grey",
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})


ReadMe:Paragraph({
    Title = "Information",
    Desc = [[Welcome to SteveHub,
<i>SteveHub is a script, designed to be universal and support games at the same time.</i>
SteveHub is an open-source modular script, our assets may be used freely.

Bypasses require high level executors like Volt.

Supported games:
    • The Chosen One
    • Patrol Compton

- More to come

  <i>By ChatColours</i>
    ]],
    Color = "Brown",
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

Window:Divider()

local Home = Window:Tab({
    Title = "Home",
    Icon = "house", -- optional
    Locked = false,
})

local Server = Window:Tab({
    Title = "Servers",
    Icon = "server", -- optional
    Locked = false,
})


--[[ Load supported game tabs
local init = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"))()
init(Window, WindUI, "PatrolCompton/cars.luau")]]