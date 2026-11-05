local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")

local License = ""
local LicenseStatus = "Inactive"
local LicenseURL = ""
local SupportURL = ""

local Window = WindUI:CreateWindow({
    Title = "SteveHub",
    Icon = "door-open", -- lucide icon
    Author = "by .ftgs and .ftgs",
    Folder = "MySuperHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.LeftShift,
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})