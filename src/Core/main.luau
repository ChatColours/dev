
local RunService = game:GetService("RunService")
local Version = "1.6.41"
local WindUI = loadstring(game:HttpGet("raw.githubusercontent.com/ChatColours/dev/refs/heads/main/WindUI/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Tabs = {}

local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")
local ServerSearch = Loader.Require("src/Modules/ServerSearch.luau")
local Version = Loader.Require("src/Core/Utilities/version.luau")
local Logs = Loader.Require("src/Core/Utilities/logs.luau")
local ThemesLoader = Loader.Require("src/misc/Themes.luau")

local Flavors = ThemesLoader.Flavors
local CurrentTheme = "Catppuccin Mocha"

local function LoadPlugin(Path, Window, WindUI)
    local Success, Result = pcall(function()
        local Chunk, LoadError = loadfile(Path)
        if not Chunk then
            Logs:Log(`Failed to load plugin: {Path} -> {LoadError}`, "ERROR")
        end
        local Plugin = Chunk()
        if type(Plugin) ~= "function" then
            Logs:Log(`Plugin must return a function: {Path}`, "WARN")
        end
        return Plugin(Window, WindUI)
    end)
    if Success then
        Logs:Log(`Successfully executed plugin: {Path}`, "SUCCESS")
        return true, Result
    else
        Logs:Log(`Failed to execute plugin: {Path} -> {tostring(Result)}`, "ERROR")
        return false, tostring(Result)
    end
end

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
    Title = "Mocha Hub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.png"), -- lucide icon
    Author = "By ChatColours",
    Folder = "Mocha",
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Transparent = true,
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

ThemesLoader.Register(WindUI)
WindUI:SetTheme("Catppuccin Mocha")

local ReadMe = Window:Tab({
    Title = "Read Me",
    Icon = "file-text", -- optional
    Locked = false,
})

ReadMe:Image({
    Image = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/banner.png",
    AspectRatio = "16:9",
    Radius = 12,
})

local passedFunctions, failedFunctions = GetFailedAndPassed()
local supportedFunctionstxt = `Your executor, {identifyexecutor()}, supports {tostring(passedFunctions)} out of {tostring(passedFunctions + failedFunctions)} \n \n`
for i, v in pairs(ExeFunctions) do
    supportedFunctionstxt ..= i .. ": " .. (v == true and `<font color="rgb(0,255,0)">✓</font>` or "❌") .. "\n"
end

local function RichText(Text, Color, Size, Bold, Italic)
    local Result = tostring(Text)
    if Bold then
        Result = "<b>" .. Result .. "</b>"
    end
    if Italic then
        Result = "<i>" .. Result .. "</i>"
    end
    if Size then
        Result = string.format(
            '<font size="%d">%s</font>',
            Size,
            Result
        )
    end
    if Color then
        Result = string.format(
            '<font color="%s">%s</font>',
            Color,
            Result
        )
    end
    return Result
end

local function GetPalette(ThemeName)
    local Name = ThemeName:gsub("^Catppuccin ", "")
    return Flavors[Name] or Flavors.Mocha
end

local function GenerateReadMe(ThemeName)
    local P = GetPalette(ThemeName)
    local function T(Text, Color, Size, Bold, Italic)
        return RichText(Text, P[Color], Size, Bold, Italic)
    end
    local Lines = {
        T("Welcome to SteveHub!", "accent", 22, true),
        "",
        T("SteveHub", "accent", nil, true)
            .. " is a free, open-source Roblox script hub designed to provide both "
            .. T("universal utilities", "text", nil, true)
            .. " and "
            .. T("game-specific features", "text", nil, true)
            .. " in one convenient interface.",
        "",
        "Our goal is to create a powerful, lightweight, and modular experience that is easy to use, regularly improved, and accessible to everyone.",
        "",
        T("What We Offer", "accent", 17, true),
        T(table.concat({
            "• Universal features across supported experiences",
            "• Dedicated scripts for individual games",
            "• Anti-cheat bypasses",
            "• A clean and customisable interface",
            "• Modular systems for improved maintainability",
            "• Regular improvements and new functionality",
            "• Free and open-source development",
        }, "\n"), "text"),
        "",
        T("Supported Games", "accent", 17, true),
        T("✓", "green") .. " The Chosen One",
        T("✓", "green") .. " Patrol Compton",
        "",
        T(
            "More experiences and features are planned for future updates.",
            "subtext",
            nil,
            false,
            true
        ),
        "",
        T("Executor Compatibility", "accent", 17, true),
        "SteveHub supports various executors, although certain advanced functions and bypasses require higher-level executors such as "
            .. T("Volt", "accent", nil, true)
            .. ".",
        "",
        "Some features may be unavailable depending on your executor's supported functions.",
        "",
        T("Plugin Support", "accent", 17, true),
        "SteveHub supports "
            .. T("community-created plugins", "accent", nil, true)
            .. ", allowing users to extend the hub with custom features, utilities, and additional functionality.",
        "",
        "Plugins can be developed by anyone and shared with the community, making SteveHub even more flexible and customisable.",
        "",
        T("Installing Plugins", "accent", 15, true),
        "To install a plugin, place its "
            .. T(".luau", "accent", nil, true)
            .. " file inside the following directory:",
        "",
        T("Steve/Plugins/", "accent", nil, true),
        "",
        T(
            "This folder is located inside your executor's workspace.",
            "subtext",
            nil,
            false,
            true
        ),
        "",
        "SteveHub will automatically detect and load plugins found in this directory.",
        "",
        T(
            "Only install plugins from developers you trust, as plugins can execute their own code.",
            "subtext",
            nil,
            false,
            true
        ),
        "",
        T("Important Information", "accent", 17, true),
        T(table.concat({
            "• Features may change or become unavailable after game updates.",
            "• Some functions are experimental and may contain bugs.",
            "• Use SteveHub responsibly and at your own discretion.",
        }, "\n"), "text"),
        "",
        T(
            "Built for versatility. Designed for simplicity.",
            "subtext",
            nil,
            false,
            true
        ),
        "",
        T("SteveHub", "accent", nil, true),
        T(
            "Created and maintained by ChatColours.",
            "subtext",
            nil,
            false,
            true
        ),
    }
    return table.concat(Lines, "\n")
end

local function GenerateSupportedFunctions(ThemeName)
    local P = GetPalette(ThemeName)
    local text = `Your executor, {identifyexecutor()}, supports {passedFunctions} out of {passedFunctions + failedFunctions}\n\n`
    for name, supported in pairs(ExeFunctions) do
        local mark = supported and RichText("✓", P.green) or RichText("✗", P.red)
        text ..= name .. ": " .. mark .. "\n"
    end
    return text
end

local Information = ReadMe:Paragraph({
    Title = "Information",
    Desc = GenerateReadMe(CurrentTheme),
    Color = Color3.fromHex(GetPalette(CurrentTheme).surface),
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

local SupportedFunctions = ReadMe:Paragraph({
    Title = "Supported Functions",
    Desc = GenerateSupportedFunctions(CurrentTheme),
    Color = Color3.fromHex(GetPalette(CurrentTheme).surface),
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

local function UpdateReadMe(themeName)
    CurrentTheme = themeName
    Information:SetDesc(GenerateReadMe(themeName))
    SupportedFunctions:SetDesc(GenerateSupportedFunctions(themeName))
end

ReadMe:Dropdown({
    Title = "Catppuccin Theme",
    Values = {"Catppuccin Latte", "Catppuccin Frappe", "Catppuccin Macchiato", "Catppuccin Mocha"},
    Value = CurrentTheme,
    Callback = function(value)
        WindUI:SetTheme(value)
        UpdateReadMe(value)
    end,
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
                Logs:Log(`Missing required tab: {requiredTab} for {path}`, "WARN")
                continue
            end
        end
        init(Window, WindUI, path, tab)
    end
end

local pluginList = listfiles("Steve/Plugins")
local loaded = 0

WindUI:Popup({
    Title = "Load plugins?",
    Content = "SteveHub is not responsible for any damage that may occur from using plugins. Only load plugins from developers you trust, or join our Discord for checked plugins.",
    Icon = "alert",
    Buttons = {
        {
            Title = "Load Plugins",
            Variant = "Tertiary",
            Icon = "check",
            Callback = function()
                for _, pluginPath in ipairs(pluginList) do
                    if not pluginPath:match("%.luau$") and not pluginPath:match("%.lua$") and not pluginPath:match("%.txt$") then
                        Logs:Log(`Failed to load plugin: {pluginPath} (not a .luau, .lua, or .txt file)`, "WARN")
                        WindUI:Notify({
                            Title = "Failed to load plugin",
                            Content = `{pluginPath} is not a .luau, .lua, or .txt file.`,
                            Duration = 3, -- 3 seconds
                            Icon = "unplug",
                        })
                        continue
                    end
                    local plugin, res = LoadPlugin(pluginPath, Window, WindUI)
                    if not plugin and res then
                        Logs:Log(`Failed to load plugin: {pluginPath}: {res}`, "ERROR")
                    elseif plugin then
                        loaded += 1
                    end
                end
            end
        },
        {
            Title = "Don't Load",
            Icon = "x",
            Callback = function() end,
            Variant = "Primary"
        }
    }
})

WindUI:Notify({
    Title = "Plugins Loaded",
    Content = `Successfully loaded {loaded} plugins.`,
    Duration = 3, -- 3 seconds
    Icon = "unplug",
})

init(Window, WindUI, "Universal/Settings.luau")