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
local fastClickThread = nil
local holdingLMB = false
local fastClick = false
local radius = 120
local wallCheck = true
local teamCheck = true
local lead = 0
local mouseaimKey = Enum.KeyCode.F
local mouseaim = false
local smoothing = .1
local playerLockedOn
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

local function StopFastClick()
    holdingLMB = false

    if fastClickThread then
        task.cancel(fastClickThread)
        fastClickThread = nil
    end
end

local function StartFastClick()
    if fastClickThread or not fastClick then
        return
    end

    fastClickThread = task.spawn(function()
        local releaseChecks = 0
        local maxReleaseChecks = 3

        while fastClick do
            local holding = UserInputService:IsMouseButtonPressed(
                Enum.UserInputType.MouseButton1
            )

            if not holding then
                releaseChecks += 1

                if releaseChecks >= maxReleaseChecks then
                    warn("Confirmed release!")
                    break
                end
            else
                releaseChecks = 0
            end

            if mouse1click then
                mouse1click()
            end

            task.wait(0.05)
        end

        fastClickThread = nil
    end)
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

local function GetClosest()
    local closest = nil
    local shortest = math.huge
    local center = GetAimCenter()

    for _, player in Players:GetPlayers() do
        if player == Player then
            continue
        end

        if teamCheck and player.Team ~= nil and player.Team == Player.Team then
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

        if distance > radius or distance >= shortest then
            continue
        end

        if wallCheck and not IsVisible(character, head) then
            continue
        end

        shortest = distance
        closest = head
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
        Title = "Fast Click",
        Desc = "Holding down will simulate multiple clicks, useful for semi weapons",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            fastClick = state
            print("fast click: ".. tostring(fastClick))

            if not state then
                StopFastClick()
            end
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

    Tab:Toggle({
        Title = "Team Check",
        Desc = "Exclude players on the same team as you",
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
        local camera = workspace.CurrentCamera
        if not camera then return end

        Camera = camera
        circle.Position = mouseaim
            and UserInputService:GetMouseLocation()
            or GetCenter()
        circle.Radius = radius

        if not enabled then return end

        local holding = UserInputService:IsMouseButtonPressed(
            holdKey
        )

        if not holding and not usemouseaim then return end

        local target = GetClosest()
        if not target then return end

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
end