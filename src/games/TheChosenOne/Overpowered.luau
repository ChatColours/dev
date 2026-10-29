local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Globals = Loader.Require("src/games/TheChosenOne/Global.luau")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game.Players.LocalPlayer:GetMouse()
local MousePaint = false
local MousePaintKey, MousePaintUseKeybind = nil, false
local MousePaintToggle

local Materials = {"smooth", "plastic", "tiles", "planks", "ice", "grass", "sand", "snow", "glass",
                   "wood", "stone", "pebble", "marble", "granite", "steel", "metal", "asphalt",
                   "concrete", "pavement", "anchor", "collide", "neon", "toxic"}

UserInputService.InputBegan:Connect(function(key: InputObject, gp: boolean)
    if gp then return end

    if key.KeyCode == MousePaintKey and MousePaintUseKeybind and MousePaintToggle then
        MousePaintToggle:Set(not MousePaint)
    end
end)

RunService.RenderStepped:Connect(function(dt: number)
    if MousePaint and Mouse.Target then
        local event = Globals.GetEvent(Globals.GetTool("Paint"))
        if not event then return end
        local colour = Color3.fromHSV(math.random(), 1, 1)
        local material = Materials[math.random(1, #Materials)]
        event:FireServer(
            Mouse.Target,
            Enum.NormalId.Front,
            Globals.GetLocalPosition(),
            "both \xF0\x9F\xA4\x9D",
            colour,
            material,
            ""
        )
    end
end)

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Overpowered",
        Icon = "bird", -- optional
        Locked = false,
    })

    Tab:Keybind({
        Title = "Mouse Paint Keybind",
        Desc = "Keybind to toggle mouse paint",
        Value = "G",
        Callback = function(v)
            MousePaintKey = Enum.KeyCode[v]
        end
    })

    Tab:Toggle({
        Title = "Mouse Paint Keybind Toggle",
        Desc = "When enabled, the set keybind can be used to toggle paint",
        Icon = "bird",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            MousePaintUseKeybind = state
        end
    })

    MousePaintToggle = Tab:Toggle({
        Title = "Mouse Paint",
        Desc = "Paint parts which you aim at",
        Icon = "bird",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            MousePaint = state
        end
    })
end