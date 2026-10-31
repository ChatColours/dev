local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Tabs = {}

local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")
local ServerSearch = Loader.Require("src/Modules/ServerSearch.luau")
local Version = Loader.Require("src/Core/Utilities/version.luau")
local Plugins = Loader.Require("src/Core/Utilities/plugins.luau")

const Services = {
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}
local Hooks = {}

local SupportedGames = {
    [11137575513] = {
        Folder = "TheChosenOne",
        Tabs = {
            ["Grief.luau"] = "",
            ["Overpowered.luau"] = ""
        }
    },

    [86799185313399] = {
        Folder = "PatrolCompton",
        Tabs = {
            ["cars.luau"] = ""
        }
    },

    [155615604] = {
        Folder = "PrisonLife",
        Tabs = {
            ["Aimbot.luau"] = "UniversalAimbot"
        }
    }
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
    ["isnetworkowner"] = type(isnetworkowner) == "function",
    ["newcclosure"] = type(newcclosure) == "function",
    ["getnamecallmethod"] = type(getnamecallmethod) == "function",
    ["getgc"] = type(getgc) == "function"
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
_G.ConfigManager = Window.ConfigManager

Window:Tag({
    Title = Version:sub(1, 7),
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 13, -- from 0 to 13
})
Window:Tag({
    Title = (SupportedGames[game.PlaceId] and "Supported Game") or "Unsupported Game",
    Icon = "gamepad-2",
    Color = (SupportedGames[game.PlaceId] and Color3.fromHex("#30ff6a")) or Color3.fromHex("#ff3030"),
    Radius = 13, -- from 0 to 13
})

WindUI:Popup({
    Title = "Join Discord?",
    Icon = FetchAsset("discord.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/discord.png"),
    Content = "Join the Discord to chat and receive updates",
    Buttons = {
        {
            Title = "Don't Join",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "Join Discord",
            Icon = "arrow-right",
            Callback = function() setclipboard("discord.gg/abcdef") end,
            Variant = "Primary",
        }
    }
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
    supportedFunctionstxt ..= i .. ": " .. (v == true and `<font color="rgb(0,255,0)">✓</font>` or "❌") .. "\n"
end

ReadMe:Paragraph({
    Title = "Information",
    Desc = 
[[
<font size="22" color="#D9B78C"><b>Welcome to SteveHub!</b></font>

<font color="#E0D5C5">SteveHub</font> is a free, open-source Roblox script hub designed to provide both <b>universal utilities</b> and <b>game-specific features</b> in one convenient interface.

Our goal is to create a powerful, lightweight, and modular experience that is easy to use, regularly improved, and accessible to everyone.

<font size="17" color="#C6A47D"><b>What We Offer</b></font>
<font color="#CFC5B8">• Universal features across supported experiences
• Dedicated scripts for individual games
• Anti-cheat bypasses
• A clean and customisable interface
• Modular systems for improved maintainability
• Regular improvements and new functionality
• Free and open-source development</font>

<font size="17" color="#C6A47D"><b>Supported Games</b></font>
<font color="#A6C48A">✓</font> The Chosen One
<font color="#A6C48A">✓</font> Patrol Compton

<font color="#A99B8A"><i>More experiences and features are planned for future updates.</i></font>

<font size="17" color="#C6A47D"><b>Executor Compatibility</b></font>
SteveHub supports various executors, although certain advanced functions and bypasses require higher-level executors such as <font color="#D9B78C"><b>Volt</b></font>.

Some features may be unavailable depending on your executor's supported functions.

<font size="17" color="#C6A47D"><b>Plugin Support</b></font>
<font color="#CFC5B8">SteveHub supports <font color="#D9B78C"><b>community-created plugins</b></font>, allowing users to extend the hub with custom features, utilities, and additional functionality.

Plugins can be developed by anyone and shared with the community, making SteveHub even more flexible and customisable.</font>

<font size="15" color="#C6A47D"><b>Installing Plugins</b></font>
<font color="#CFC5B8">To install a plugin, place its <font color="#D9B78C"><b>.luau</b></font> file inside the following directory:</font>

<font color="#D9B78C"><b>Steve/Plugins/</b></font>

<font color="#A99B8A"><i>This folder is located inside your executor's workspace.</i></font>

<font color="#CFC5B8">SteveHub will automatically detect and load plugins found in this directory.</font>

<font color="#A99B8A"><i>Only install plugins from developers you trust, as plugins can execute their own code.</i></font>

<font size="17" color="#C6A47D"><b>Important Information</b></font>
<font color="#CFC5B8">• Features may change or become unavailable after game updates.
• Some functions are experimental and may contain bugs.
• Use SteveHub responsibly and at your own discretion.</font>

<font color="#A99B8A"><i>Built for versatility. Designed for simplicity.</i></font>

<font color="#D9B78C"><b>SteveHub</b></font>
<font color="#A99B8A"><i>Created and maintained by ChatColours.</i></font>
]]
,
    Color = Color3.fromHex("#3B3027"),
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

ReadMe:Paragraph({
    Title = "Supported Functions",
    Desc = supportedFunctionstxt,
    Color = Color3.fromHex("#3B3027"),
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

Window:Divider()

local init = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"
))()

init(Window, WindUI, "Universal/Home.luau")
init(Window, WindUI, "Universal/Player.luau")
init(Window, WindUI, "Universal/Visuals.luau")
init(Window, WindUI, "Universal/Servers.luau")
init(Window, WindUI, "Universal/Scripts.luau")
init(Window, WindUI, "Universal/Safety.luau")
local supported = SupportedGames[game.PlaceId]

if supported then
    for filename, requiredTab in pairs(supported.Tabs) do
        local path = supported.Folder .. "/" .. filename

        local tab = nil

        if requiredTab ~= "" then
            tab = Tabs[requiredTab]

            if not tab then
                warn(`Missing required tab: {requiredTab} for {path}`)
                continue
            end
        end

        init(Window, WindUI, path, tab)
    end
end

local pluginList = Plugins.ListPlugins()
local loaded = 0
for _, pluginPath in ipairs(pluginList) do
    if not pluginPath:match("%.luau$") and not pluginPath:match("%.lua$") then
        warn(`[STEVEHUB] Failed to load plugin: {pluginPath} (not a .luau or .lua file)`)
        continue
    end

    local plugin, res = Plugins.LoadPlugin(pluginPath, Window, WindUI)
    if not plugin and res then
        warn(`[STEVEHUB] Failed to load plugin: {pluginPath}: {res}`)
    elseif plugin then
        loaded += 1
    end
end

WindUI:Notify({
    Title = "Plugins Loaded",
    Content = `Successfully loaded {loaded} plugins.`,
    Duration = 3, -- 3 seconds
    Icon = "unplug",
})

init(Window, WindUI, "Universal/Settings.luau")
queueonteleport(game:HttpGet(
    "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/main.luau"
))