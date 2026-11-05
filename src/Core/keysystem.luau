local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local FetchAsset = Loader.Require("src/Core/Utilities/files.luau")
local KeySystem = Loader.Require("src/Core/utilities/key.luau")

local License = ""
local LicenseStatus = "Inactive"
local LicenseURL = ""
local SupportURL = ""

local Window = WindUI:CreateWindow({
    Title = "SteveHub",
    Icon = FetchAsset("icon.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/icon.jpg"), -- lucide icon
    Author = "By ChatColours",
    Folder = "MySuperHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.LeftShift,
    Background = FetchAsset("background.png", "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/background.png"),
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

local function Validate(license : string) : boolean
    local result = KeySystem.Validate(
        {
            ["Username"] = game.Players.LocalPlayer.Name,
            ["Userid"] = game.Players.LocalPlayer.UserId,
            ["Hwid"] = gethwid(),
            ["Tick"] = os.time(),
            ["Key license"] = license
        }
    )
    
    return result
end

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
    Icon = "bird", -- optional
    Locked = false,
})

local Paragraph = Tab:Paragraph({
    Title = "Paragraph with Image, Thumbnail, Buttons",
    Desc = "Test Paragraph",
    Color = "Red",
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
        {
            Icon = "bird",
            Title = "Button",
            Callback = function() print("1 Button") end,
        }
    }
})