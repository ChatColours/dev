local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

const Services = {
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}
local Hooks = {}
local NecessaryFiles = {
    "fold.Herobrine",
    "file.Herobrine/test.txt"
}

local SupportedGames = {
    [11137575513] = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/TheChosenOne"
}

for _, v in NecessaryFiles do
    if v:sub(1, 6) == "file." then
        if not isfile(v:sub(6)) then
            writefile(v:sub(6), "")
        end
    elseif v:sub(1, 6) == "fold." then
        if not isfolder(v:sub(6)) then
            makefolder(v:sub(6))
        end
    end
end

local function SafeRead(path : string)
    if isfile(path) then
        return readfile(path)
    else
        writefile(path, "")
        return ""
    end
end

local function FetchAsset(FileName, Link)
    if isfile("Herobrine/assets/".. FileName) then
        return getcustomasset("Herobrine/assets/".. FileName)
    else
        local success, result = pcall(function()
            return game:HttpGet(Link)
        end)
        if success then
            writefile("Herobrine/assets/".. FileName, result)
            return getcustomasset("Herobrine/assets/".. FileName)
        end
    end
    return nil
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
    Title = "My Super Hub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.jpg"), -- lucide icon
    Author = "by .ftgs and .ftgs",
    Folder = "Herobrine",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Transparent = true,
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

-- Load supported game tabs
local init = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"))()
init(Window, WindUI, {
    "TheChosenOne"
})

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

Window:Divider()