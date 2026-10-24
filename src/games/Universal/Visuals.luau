local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Skeleton = false,
    Boxes = false,
    Tracers = false,
    Names = false,
    Distance = false,
    Healthbar = false,
    Rainbow = false,
}

local ESPColor = Color3.fromRGB(255, 255, 255)
local ESPObjects = {}
local Connections = {}

local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},

    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},

    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},

    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},

    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function NewDrawing(class, properties)
    local object = Drawing.new(class)
    for property, value in properties do
        object[property] = value
    end

    return object
end

local function CreateESP(player)
    if player == LocalPlayer or ESPObjects[player] then
        return
    end

    local objects = {
        Skeleton = {},
    }

    objects.Box = NewDrawing("Square", {
        Visible = false,
        Filled = false,
        Thickness = 1.5,
        Color = ESPColor,
    })

    objects.Tracer = NewDrawing("Line", {
        Visible = false,
        Thickness = 1.5,
        Color = ESPColor,
    })

    objects.Name = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Size = 14,
        Font = 2,
        Color = ESPColor,
    })

    objects.Distance = NewDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Size = 13,
        Font = 2,
        Color = ESPColor,
    })

    objects.HealthBackground = NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Color = Color3.fromRGB(20, 20, 20),
    })

    objects.Health = NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Color = Color3.fromRGB(0, 255, 0),
    })

    -- Maximum number of R15 skeleton connections
    for i = 1, #R15Bones do
        objects.Skeleton[i] = NewDrawing("Line", {
            Visible = false,
            Thickness = 1.5,
            Color = ESPColor,
        })
    end

    ESPObjects[player] = objects
end

local function RemoveESP(player)
    local objects = ESPObjects[player]
    if not objects then
        return
    end

    for key, object in objects do
        if key == "Skeleton" then
            for _, line in object do
                line:Remove()
            end
        else
            object:Remove()
        end
    end

    ESPObjects[player] = nil
end

local function HideESP(objects)
    for key, object in objects do
        if key == "Skeleton" then
            for _, line in object do
                line.Visible = false
            end
        else
            object.Visible = false
        end
    end
end

local function Project(position)
    local screen, visible = Camera:WorldToViewportPoint(position)

    return Vector2.new(screen.X, screen.Y), visible, screen.Z
end

local function GetBoundingBox(character)
    local cf, size = character:GetBoundingBox()

    local half = size / 2
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local offset = Vector3.new(
                    half.X * x,
                    half.Y * y,
                    half.Z * z
                )

                local world = cf:PointToWorldSpace(offset)
                local screen, _, depth = Project(world)

                if depth <= 0 then
                    return nil
                end

                minX = math.min(minX, screen.X)
                minY = math.min(minY, screen.Y)
                maxX = math.max(maxX, screen.X)
                maxY = math.max(maxY, screen.Y)
            end
        end
    end

    return Vector2.new(minX, minY),
        Vector2.new(maxX - minX, maxY - minY)
end

local function UpdateSkeleton(character, objects, color)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local bones = humanoid.RigType == Enum.HumanoidRigType.R6
        and R6Bones or R15Bones

    for i, line in objects.Skeleton do
        local connection = bones[i]

        if not Settings.Skeleton or not connection then
            line.Visible = false
            continue
        end

        local partA = character:FindFirstChild(connection[1])
        local partB = character:FindFirstChild(connection[2])

        if not partA or not partB then
            line.Visible = false
            continue
        end

        local a, _, depthA = Project(partA.Position)
        local b, _, depthB = Project(partB.Position)

        if depthA <= 0 or depthB <= 0 then
            line.Visible = false
            continue
        end

        line.From = a
        line.To = b
        line.Color = color
        line.Visible = true
    end
end

local function UpdateESP(player, objects, color)
    HideESP(objects)

    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    local screenPosition, onScreen, depth = Project(root.Position)

    if not onScreen or depth <= 0 then
        return
    end

    local boxPosition, boxSize = GetBoundingBox(character)

    if not boxPosition then
        return
    end

    local boxCenter = boxPosition.X + boxSize.X / 2
    local boxBottom = boxPosition.Y + boxSize.Y

    UpdateSkeleton(character, objects, color)

    if Settings.Boxes then
        local box = objects.Box

        box.Position = boxPosition
        box.Size = boxSize
        box.Color = color
        box.Visible = true
    end

    if Settings.Tracers then
        local tracer = objects.Tracer

        tracer.From = Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y
        )

        tracer.To = Vector2.new(boxCenter, boxBottom)
        tracer.Color = color
        tracer.Visible = true
    end

    if Settings.Names then
        local name = objects.Name

        name.Text = player.DisplayName
        name.Position = Vector2.new(
            boxCenter,
            boxPosition.Y - 20
        )

        name.Color = color
        name.Visible = true
    end

    if Settings.Distance then
        local distance = objects.Distance

        local myRoot = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if myRoot then
            local studs = (myRoot.Position - root.Position).Magnitude

            distance.Text = string.format("%.0f studs", studs)
            distance.Position = Vector2.new(
                boxCenter,
                boxBottom + 4
            )

            distance.Color = color
            distance.Visible = true
        end
    end

    -- Healthbar ESP
    if Settings.Healthbar then
        local ratio = math.clamp(
            humanoid.Health / math.max(humanoid.MaxHealth, 1),
            0,
            1
        )

        local barHeight = boxSize.Y
        local barWidth = 3
        local barX = boxPosition.X - 7

        local background = objects.HealthBackground
        background.Position = Vector2.new(barX, boxPosition.Y)
        background.Size = Vector2.new(barWidth, barHeight)
        background.Visible = true

        local health = objects.Health
        local filledHeight = barHeight * ratio

        health.Position = Vector2.new(
            barX,
            boxPosition.Y + barHeight - filledHeight
        )

        health.Size = Vector2.new(barWidth, filledHeight)

        health.Color = Color3.fromRGB(
            math.floor(255 * (1 - ratio)),
            math.floor(255 * ratio),
            0
        )

        health.Visible = true
    end
end

local function GetESPColor()
    if Settings.Rainbow then
        return Color3.fromHSV(
            (time() * 0.2) % 1,
            1,
            1
        )
    end

    return ESPColor
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Visuals",
        Icon = "eye",
        Locked = false,
    })
    local fov = workspace.CurrentCamera.FieldOfView
    local fovEnabled = false

    Tab:Toggle({
    Title = "Custom FOV",
    Desc = "Change your FOV",
    Icon = "bird",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        fovEnabled = state
    end
})

    local Slider = Tab:Slider({
    Title = "FOV Amount",
    Desc = "",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    Value = {
        Min = 1,
        Max = 170,
        Default = 70,
    },
    Callback = function(value)
        fov = value
    end
})

    Tab:Section({
        Title = "Player ESP",
    })

    local function AddToggle(title, description, setting)
        Tab:Toggle({
            Title = title,
            Desc = description,
            Value = Settings[setting],

            Callback = function(value)
                Settings[setting] = value
            end,
        })
    end

    AddToggle("Skeleton ESP", "Display player skeletons", "Skeleton")
    AddToggle("Box ESP", "Draw boxes around players", "Boxes")
    AddToggle("Tracer ESP", "Draw lines to players", "Tracers")
    AddToggle("Name ESP", "Display player names", "Names")
    AddToggle("Distance ESP", "Display distance in studs", "Distance")
    AddToggle("Healthbar ESP", "Display player health bars", "Healthbar")

    Tab:Section({
        Title = "ESP Appearance",
    })

    AddToggle("Rainbow ESP", "Cycle through rainbow colors", "Rainbow")

    Tab:Colorpicker({
        Title = "ESP Color",
        Desc = "Default ESP color when rainbow is disabled",
        Default = ESPColor,
        Transparency = 0,

        Callback = function(color)
            ESPColor = color
        end,
    })

    for _, player in Players:GetPlayers() do
        CreateESP(player)
    end

    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)

    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)

    Connections.Render = RunService.RenderStepped:Connect(function()
        Camera = workspace.CurrentCamera

        if not Camera then
            return
        end
        if fovEnabled then
            Camera.FieldOfView = fov
        end

        local color = GetESPColor()

        for player, objects in ESPObjects do
            UpdateESP(player, objects, color)
        end
    end)

end