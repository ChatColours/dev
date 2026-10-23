local UserInputService = game:GetService("UserInputService")
local runs = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local toggleKey = Enum.KeyCode.LeftAlt
local aiming = false
local enabled = false
local radius = 100
local Middle = workspace.CurrentCamera.ViewportSize
Middle = Vector2.new(Middle.X / 2, Middle.Y / 2)

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Radius = radius
circle.Position = Middle
circle.Color = Color3.new(1,1,1)

local function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - circle.Position).Magnitude
                    
                    -- Find our own head (compatible with R6 and R15)
                    local myHead = plr.Character and plr.Character:FindFirstChild("Head")
                    local dist3D = myHead and (head.Position - myHead.Position).Magnitude or math.huge
                    
                    if distFromCenter <= radius and dist3D < shortest then
                        shortest = dist3D
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

return function(Window, WindUI)

    UserInputService.InputBegan:Connect(function(input : InputObject, gp: boolean)
        if input.KeyCode == toggleKey then
            enabled = not enabled
            circle.Visible = enabled
        end
    end)

    local Tab = Window:Tab({
    Title = "Aimbot",
    Icon = "crosshair", -- optional
    Locked = false,
    })

    Tab:Keybind({
    Title = "Aimbot Key",
    Desc = "Keybind to toggle aimbot",
    Value = "G",
    Callback = function(v)
        toggleKey = Enum.KeyCode[v]
    end
})

Tab:Slider({
    Title = "FOV Radius",
    Desc = "How big the circle is",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    Value = {
        Min = 20,
        Max = 100,
        Default = 40,
    },
    Callback = function(value)
        circle.Radius = value * 3
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

runs.Heartbeat:Connect(function()
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and enabled then
        circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    
        if aiming then
            local target = getClosest()
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
            end
        end
    end
end)
end
