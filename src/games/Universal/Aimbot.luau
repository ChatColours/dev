local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")



local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local toggleKey = Enum.KeyCode.G
local enabled = false
local holdKey = Enum.UserInputType.MouseButton2
local mouseKeys = {
    ["LMB"] = Enum.UserInputType.MouseButton1,
    ["RMB"] = Enum.UserInputType.MouseButton2,
    ["MMB"] = Enum.UserInputType.MouseButton3
}
local AimbotEnabled = false
local teamExclusions = {}


_G.triggerBot = false
local radius = 120
local wallCheck = true
local teamCheck = true
local lead = 0

local mouseaimKey = Enum.KeyCode.F
local mouseaim = false
local smoothing = .1
local lockedTarget

local Settings = {
    MaxDistance = 500,
    TargetStickiness = 1.3,
    DistanceWeight = 0.5,
}

local usemouseaim = false

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

local function IsExcluded(player)
    if not teamCheck then return false end

    local team = player.Team

    if teamExclusions[team] then
        return true
    end

    if team
        and not player.Neutral
        and not Player.Neutral
        and team == Player.Team then
        return true
    end

    return false
end

local function GetTriggerTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local ray = camera:ViewportPointToRay(center.X, center.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = Player.Character
        and {Player.Character}
        or {}

    local result = workspace:Raycast(
        ray.Origin,
        ray.Direction * 1000,
        params
    )

    if not result then return nil end

    local character = result.Instance:FindFirstAncestorOfClass("Model")
    if not character then return nil end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    local targetPlayer = Players:GetPlayerFromCharacter(character)
    if not targetPlayer or targetPlayer == Player then
        return nil
    end

    if IsExcluded(targetPlayer) then
        return nil
    end

    return targetPlayer
end

local function GetAimCenter()
    if mouseaim then
        return UserInputService:GetMouseLocation()
    end

    return GetCenter()
end

local function GetPredictedPosition(target)
    return target.Position + target.AssemblyLinearVelocity * lead
end

local function IsVisible(character, targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        Player.Character
    }
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    return result == nil or result.Instance:IsDescendantOf(character)
end

local function IsValidTarget(player, character, head)
    if player == Player then
        return false
    end

    if IsExcluded(player) then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local myRoot = Player.Character
        and Player.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot then
        return false
    end

    local distance3D = (head.Position - myRoot.Position).Magnitude

    if distance3D > Settings.MaxDistance then
        return false
    end

    if wallCheck and not IsVisible(character, head) then
        return false
    end

    return true
end

local function GetTargetScore(head, center)
    local screenPosition, onScreen =
        Camera:WorldToViewportPoint(head.Position)

    if not onScreen then
        return nil
    end

    local screenDistance = (
        Vector2.new(screenPosition.X, screenPosition.Y) - center
    ).Magnitude

    if screenDistance > radius then
        return nil
    end

    local worldDistance = (
        head.Position - Camera.CFrame.Position
    ).Magnitude

    -- Lower scores are better
    local screenScore = screenDistance / math.max(radius, 1)
    local worldScore = worldDistance / Settings.MaxDistance

    local weight = Settings.DistanceWeight

    return screenScore * (1 - weight) + worldScore * weight
end

local function GetClosest()
    local center = GetAimCenter()

    if lockedTarget then
        local character = lockedTarget.Character
        local head = character and character:FindFirstChild("Head")

        if head and IsValidTarget(lockedTarget, character, head) then
            local score = GetTargetScore(head, center)

            if score then
                return head
            end
        end

        lockedTarget = nil
    end

    local bestPlayer = nil
    local bestHead = nil
    local bestScore = math.huge

    for _, player in Players:GetPlayers() do
        local character = player.Character
        local head = character and character:FindFirstChild("Head")

        if not head then
            continue
        end

        if not IsValidTarget(player, character, head) then
            continue
        end

        local score = GetTargetScore(head, center)

        if score and score < bestScore then
            bestScore = score
            bestPlayer = player
            bestHead = head
        end
    end

    lockedTarget = bestPlayer

    return bestHead
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Universal Aimbot",
        Icon = "crosshair",
        Locked = false,
    })

    Tab:Toggle({
        Title = "Aimbot Enabled",
        Desc = "Whether the whole module should be enabled or not",
        Value = false,
        Callback = function(state) 
            AimbotEnabled = state
        end
    })

    Tab:Keybind({
        Title = "Aimbot Key",
        Desc = "Keybind to toggle aimbot",
        Value = "G",

        Callback = function(value)
            toggleKey = Enum.KeyCode[value]
        end
    })

        Tab:Keybind({
        Title = "Mouse Aimbot Key",
        Desc = "Keybind to toggle mouse aimbot",
        Value = "F",

        Callback = function(value)
            mouseaimKey = Enum.KeyCode[value]
        end
    })

    Tab:Dropdown({
        Title = "Hold Key",
        Desc = "What mouse key should be held down to use aimbot",
        Values = {"LMB", "RMB", "MMB"},
        Value = "RMB",
        Callback = function(option) 
            holdKey = mouseKeys[option]
        end
    })

    Tab:Toggle({
        Title = "Trigger Bot",
        Desc = "Players in the aimbot FOV will automatically be shot at",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            _G.triggerBot = state
        end
    })

    Tab:Toggle({
        Title = "Mouse Aimbot",
        Desc = "Moves the mouse onto players instead of the camera",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            mouseaim = state
        end
    })


    Tab:Slider({
        Title = "Mouse Aimbot Smoothing",
        Desc = "How smooth cursor movement should be",
        Step = 0.01,

        Value = {
            Min = 0.01,
            Max = 1,
            Default = 0,
        },

        Callback = function(value)
            smoothing = value
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

    Tab:Slider({
        Title = "Movement Prediction",
        Desc = "Compensate for target movement",
        Step = 0.01,

        Value = {
            Min = 0,
            Max = 1,
            Default = 0,
        },

        Callback = function(value)
            lead = value
        end
    })
    local teams = {}
    for i, v in ipairs(game.Teams:GetChildren()) do
        table.insert(teams, v.Name)
    end
    Tab:Dropdown({
        Title = "Team Exclusions",
        Desc = "What teams to ignore for aimbot",
        Values = teams,
        Value = {},
        Multi = true,
        AllowNone = true,
        Callback = function(option) 
            table.clear(teamExclusions)
            for key, value in option do
                if type(key) == "number" then
                    teamExclusions[value] = true
                elseif value == true then
                    teamExclusions[key] = true
                end
            end
        end
    })

    Tab:Toggle({
        Title = "Team Check",
        Desc = "Exclude players in teams that are excluded",
        Icon = "users",
        Type = "Checkbox",
        Value = teamCheck,

        Callback = function(state)
            teamCheck = state
        end
    })



    Tab:Toggle({
        Title = "Wall Check",
        Desc = "Don't aim at players behind walls",
        Icon = "shield",
        Type = "Checkbox",
        Value = wallCheck,

        Callback = function(state)
            wallCheck = state
        end
    })

    Tab:Slider({
        Title = "Maximum Target Distance",
        Desc = "Ignore targets beyond this distance",
        Step = 25,

        Value = {
            Min = 25,
            Max = 2000,
            Default = 500,
        },

        Callback = function(value)
            Settings.MaxDistance = value
        end
    })

    Tab:Slider({
        Title = "Distance Priority",
        Desc = "How strongly nearby targets are preferred",
        Step = 0.05,

        Value = {
            Min = 0,
            Max = 1,
            Default = 0.5,
        },

        Callback = function(value)
            Settings.DistanceWeight = value
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
        if gameProcessed or not AimbotEnabled then
            return
        end

        if input.KeyCode == toggleKey then
            enabled = not enabled
            circle.Visible = enabled

        elseif input.KeyCode == mouseaimKey then
            mouseaim = true
            usemouseaim = true
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("start")
            StartFastClick()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == mouseaimKey then
            usemouseaim = false
        end
    end)

RunService:BindToRenderStep(
    "SteveHubAimbot",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if not AimbotEnabled then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        Camera = camera
        circle.Position = mouseaim
            and UserInputService:GetMouseLocation()
            or GetCenter()
        circle.Radius = radius

        if not enabled then
            lockedTarget = nil
            return
        end

        local holding = UserInputService:IsMouseButtonPressed(
            holdKey
        )

        if not holding and not usemouseaim then
            lockedTarget = nil
            return
        end

        local target = GetClosest()
        if not target then return end

        if _G.triggerBot and type(mouse1click) == "function" then
            mouse1click()
        end

        local predictedPosition = GetPredictedPosition(target)

        if mouseaim then
            if not mousemoverel then return end

            local screenPosition, onScreen =
                camera:WorldToViewportPoint(predictedPosition)

            if not onScreen then return end

            local mousePosition = GetAimCenter()

            local difference = Vector2.new(
                screenPosition.X,
                screenPosition.Y
            ) - mousePosition

            mousemoverel(
                difference.X * smoothing,
                difference.Y * smoothing
            )
        else
            camera.CFrame = CFrame.lookAt(
                camera.CFrame.Position,
                predictedPosition
            )
        end
    end
)

return Tab
end