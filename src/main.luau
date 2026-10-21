local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

const Services = {
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}

local NecessaryFiles = {
    "fold.Herobrine",
    "file.Herobrine/test.txt"
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

-- main window --

local Window = WindUI:CreateWindow({
    Title = "My Super Hub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/Herobrine_avatar.png"), -- lucide icon
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