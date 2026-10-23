local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local toggleKey = Enum.KeyCode.G
local enabled = false
local radius = 120

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Radius = radius
circle.Thickness = 1.5
circle.NumSides = 64
circle.Filled = false
circle.Color = Color3.new(1, 1, 1)

local function GetCenter()
    local viewport = Camera.ViewportSize
    return Vector2.new(viewport.X / 2, viewport.Y / 2)
end

local function GetClosest()
    local closest = nil
    local shortest = math.huge
    local center = GetCenter()

    for _, player in Players:GetPlayers() do
        if player == Player then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")

        if not humanoid or humanoid.Health <= 0 or not head then
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

        if not onScreen then
            continue
        end

        local position = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (position - center).Magnitude

        if distance <= radius and distance < shortest then
            shortest = distance
            closest = head
        end
    end

    return closest
end

return function(Window, WindUI)

    local Tab = Window:Tab({
        Title = "Aimbot",
        Icon = "crosshair",
        Locked = false,
    })

    Tab:Keybind({
        Title = "Aimbot Key",
        Desc = "Keybind to toggle aimbot",
        Value = "G",

        Callback = function(value)
            toggleKey = Enum.KeyCode[value]
        end
    })

    Tab:Slider({
        Title = "FOV Radius",
        Desc = "How big the circle is",
        Step = 1,

        Value = {
            Min = 20,
            Max = 100,
            Default = 40,
        },

        Callback = function(value)
            radius = value * 3
            circle.Radius = radius
        end
    })

    Tab:Colorpicker({
        Title = "FOV Color",
        Desc = "The color of the circle",
        Default = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        Locked = false,

        Callback = function(color)
            circle.Color = color
        end
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == toggleKey then
            enabled = not enabled
            circle.Visible = enabled
        end
    end)

    RunService.RenderStepped:Connect(function()
        Camera = workspace.CurrentCamera

        if not Camera then
            return
        end

        circle.Position = GetCenter()
        circle.Radius = radius

        if not enabled then
            return
        end

        local aiming = UserInputService:IsMouseButtonPressed(
            Enum.UserInputType.MouseButton2
        )

        if not aiming then
            return
        end

        local target = GetClosest()

        if target then
            Camera.CFrame = CFrame.lookAt(
                Camera.CFrame.Position,
                target.Position
            )
        end
    end)
end