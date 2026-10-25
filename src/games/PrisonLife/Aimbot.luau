local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SilentAimEnabled = false

local Event = game:GetService("ReplicatedStorage"):WaitForChild("GunRemotes"):WaitForChild("ShootEvent")
local triggerBot = _G.triggerBot
local Settings = {
    FOV = 150,
    MaxDistance = 500,
    WallCheck = true,
    TeamCheck = true,
    DistanceWeight = 0.4,
    Prediction = 0,
}

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Radius = Settings.FOV
circle.Thickness = 1.5
circle.NumSides = 64
circle.Filled = false
circle.Color = Color3.fromRGB(217, 183, 140)

local LockedTarget = nil

local function GetMuzzle()
    local gear = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local muzzle = gear:FindFirstChild("Muzzle")
    if muzzle then
        return muzzle
    end
end

local function IsExcluded(player)
    if player == LocalPlayer then
        return true
    end

    if Settings.TeamCheck then
        if not player.Neutral
            and not LocalPlayer.Neutral
            and player.Team ~= nil
            and player.Team == LocalPlayer.Team then
            return true
        end
    end

    return false
end

local function IsVisible(character, part)
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    params.FilterDescendantsInstances = LocalPlayer.Character
        and {LocalPlayer.Character}
        or {}

    local result = workspace:Raycast(origin, direction, params)

    return not result
        or result.Instance:IsDescendantOf(character)
end

local function GetTargetPosition(part)
    return part.Position
        + part.AssemblyLinearVelocity * Settings.Prediction
end

local function GetTargetScore(part)
    local screen, onScreen = Camera:WorldToViewportPoint(part.Position)

    if not onScreen then
        return nil
    end

    local center = Camera.ViewportSize / 2
    local screenDistance = (
        Vector2.new(screen.X, screen.Y) - center
    ).Magnitude

    if screenDistance > Settings.FOV then
        return nil
    end

    local worldDistance = (
        part.Position - Camera.CFrame.Position
    ).Magnitude

    if worldDistance > Settings.MaxDistance then
        return nil
    end

    local screenScore = screenDistance / Settings.FOV
    local distanceScore = worldDistance / Settings.MaxDistance
    local weight = Settings.DistanceWeight

    return screenScore * (1 - weight)
        + distanceScore * weight
end

local function IsValidTarget(player)
    if IsExcluded(player) then
        return nil
    end

    local character = player.Character
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")

    if not humanoid or humanoid.Health <= 0 or not head then
        return nil
    end

    if Settings.WallCheck and not IsVisible(character, head) then
        return nil
    end

    return head
end

local function GetClosestTarget()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    -- Keep existing target when valid
    if LockedTarget then
        local head = IsValidTarget(LockedTarget)

        if head and GetTargetScore(head) then
            return LockedTarget, head, GetTargetPosition(head)
        end

        LockedTarget = nil
    end

    local bestPlayer = nil
    local bestPart = nil
    local bestScore = math.huge

    for _, player in Players:GetPlayers() do
        local head = IsValidTarget(player)
        if not head then
            continue
        end

        local score = GetTargetScore(head)

        if score and score < bestScore then
            bestScore = score
            bestPlayer = player
            bestPart = head
        end
    end

    LockedTarget = bestPlayer

    if bestPlayer and bestPart then
        return bestPlayer, bestPart, GetTargetPosition(bestPart)
    end

    return nil
end

return function(Window, WindUI, Tab)
    Tab:Divider()

    Tab:Toggle({
        Title = "Silent Aim",
        Desc = "Select targets without moving the camera",
        Icon = "crosshair",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            SilentAimEnabled = state
            circle.Visible = state

            if not state then
                LockedTarget = nil
            end
        end
    })

    Tab:Slider({
        Title = "Silent Aim FOV",
        Desc = "Maximum targeting radius in pixels",
        Step = 5,

        Value = {
            Min = 25,
            Max = 500,
            Default = 150,
        },

        Callback = function(value)
            Settings.FOV = value
            circle.Radius = value
        end
    })

    Tab:Toggle({
        Title = "Silent Aim Wall Check",
        Desc = "Ignore players behind obstacles",
        Type = "Checkbox",
        Value = true,

        Callback = function(state)
            Settings.WallCheck = state
        end
    })

    Tab:Toggle({
        Title = "Silent Aim Team Check",
        Desc = "Ignore players on your team",
        Type = "Checkbox",
        Value = true,

        Callback = function(state)
            Settings.TeamCheck = state
        end
    })

    Tab:Slider({
        Title = "Silent Aim Prediction",
        Desc = "Predict target movement in seconds",
        Step = 0.01,

        Value = {
            Min = 0,
            Max = 0.5,
            Default = 0,
        },

        Callback = function(value)
            Settings.Prediction = value
        end
    })

    Tab:Colorpicker({
        Title = "Silent Aim FOV Color",
        Desc = "Change the Silent Aim circle colour",
        Default = Color3.fromRGB(217, 183, 140),
        Transparency = 0,

        Callback = function(color)
            circle.Color = color
        end
    })

    RunService:BindToRenderStep(
        "SteveHubSilentAimPrisonLife",
        Enum.RenderPriority.Camera.Value + 1,
        function()
        local camera = workspace.CurrentCamera
        if not camera then
            circle.Visible = false
            return
        end

        Camera = camera

        -- Keep the circle centred
        local viewport = camera.ViewportSize

        circle.Position = Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )

        circle.Radius = Settings.FOV
        circle.Visible = SilentAimEnabled

        if not SilentAimEnabled then
            return
        end

        local player, part, position = GetClosestTarget()

        if not player then
            return
        end
            local muzzle = GetMuzzle()
            if not muzzle then return end

            if triggerBot then
                Event:FireServer(
                    {
                        {
                            muzzle.Position,
                            position,
                            part
                        }
                    }
                )
            elseif not triggerBot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                Event:FireServer(
                    {
                        {
                            muzzle.Position,
                            position,
                            part
                        }
                    }
                )
            end
        end
    )
end
