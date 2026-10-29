local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Globals = Loader.Require("src/games/TheChosenOne/Global.luau")

local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local PaintMaterials = false
local PaintColours = false
local paintColour = 0
local blocksInRange = {}
local BricksPath = workspace:WaitForChild("Bricks")
local Bricks = {}
local Range = {
    Paint = 70,
    Build = 24,
    Delete = 70
}

local Params = OverlapParams.new()
Params.FilterType = Enum.RaycastFilterType.Include
Params.FilterDescendantsInstances = {BricksPath}
Params.MaxParts = 100

local function getNearestPart(maxRange: number): Part?
    local Root = Player.Character
        and Player.Character:FindFirstChild("HumanoidRootPart")

    if not Root then return nil end

    local Parts = workspace:GetPartBoundsInRadius(
        Root.Position,
        maxRange,
        Params
    )

    local Selected = nil
    local Count = 0

    for _, Part in Parts do
        if Part:IsA("Part") then
            Count += 1

            if math.random(Count) == 1 then
                Selected = Part
            end
        end
    end

    return Selected
end

local function getPositionAround(part, minRange, maxRange)
	local distance = math.random() * (maxRange - minRange) + minRange

	local theta = math.random() * math.pi * 2
	local phi = math.acos(2 * math.random() - 1) 

	local x = distance * math.sin(phi) * math.cos(theta)
	local y = distance * math.cos(phi)
	local z = distance * math.sin(phi) * math.sin(theta)

	return part.Position + Vector3.new(x, y, z)
end

local Materials = {"smooth", "plastic", "tiles", "planks", "ice", "grass", "sand", "snow", "glass",
                   "wood", "stone", "pebble", "marble", "granite", "steel", "metal", "asphalt",
                   "concrete", "pavement", "anchor", "collide", "neon", "toxic"}

return function(Window, WindUI)
    local Connections = {}

    local Tab = Window:Tab({
        Title = "Grief",
        Icon = "bomb",
        Locked = false,
    })

    Tab:Paragraph({
        Title = "Griefing Utilities",
        Desc = "Automate block deletion, painting, and construction with configurable ranges and effects.",
        Icon = "triangle-alert",
    })

    Tab:Space()

    Tab:Section({
        Title = "Delete Aura",
        Desc = "Automatically delete nearby cubes.",
        Icon = "trash-2",
    })

    Tab:Toggle({
        Title = "Enable Delete Aura",
        Desc = "Continuously target and delete the nearest cube within your selected range.",
        Icon = "trash",
        Flag = "DelAuraToggle",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            if Connections["DelAura"] then
                Connections["DelAura"]:Disconnect()
                Connections["DelAura"] = nil
            end

            if state then
                Connections["DelAura"] = RunService.RenderStepped:Connect(function()
                    local Event = Globals.GetEvent(Globals.GetTool("Delete"))

                    if Event then
                        local block = getNearestPart(Range.Delete)

                        if block then
                            Event:FireServer(block, Globals.GetLocalPosition())
                        end
                    end
                end)
            end
        end
    })

    Tab:Slider({
        Title = "Deletion Range",
        Desc = "Maximum distance at which Delete Aura can target cubes.",
        Flag = "DelAuraRange",
        Step = 1,
        Value = {
            Min = 20,
            Max = 500,
            Default = 70,
        },

        Callback = function(value)
            Range.Delete = value
        end
    })

    Tab:Space()

    Tab:Section({
        Title = "Paint Aura",
        Desc = "Automatically recolour and modify nearby cubes.",
        Icon = "paintbrush",
    })

    Tab:Toggle({
        Title = "Enable Paint Aura",
        Desc = "Continuously paint the nearest cube with your selected effects.",
        Icon = "palette",
        Flag = "PaintAuraToggle",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            if Connections["PaintAura"] then
                Connections["PaintAura"]:Disconnect()
                Connections["PaintAura"] = nil
            end

            if state then
                Connections["PaintAura"] = RunService.RenderStepped:Connect(function()
                    local Event = Globals.GetEvent(Globals.GetTool("Paint"))

                    if not Event then
                        return
                    end

                    local block = getNearestPart(Range.Paint)

                    if not block then
                        return
                    end

                    local colour = PaintColours
                        and Color3.fromHSV(math.random(), 1, 1)
                        or block.Color

                    local material = PaintMaterials
                        and Materials[math.random(1, #Materials)]
                        or block.Material.Name:lower()

                    Event:FireServer(
                        block,
                        Enum.NormalId.Front,
                        Globals.GetLocalPosition(),
                        "both 🤝",
                        colour,
                        material,
                        ""
                    )
                end)
            end
        end
    })

    Tab:Space()

    Tab:Toggle({
        Title = "Randomize Materials",
        Desc = "Apply randomly selected materials to nearby cubes.",
        Icon = "layers",
        Flag = "PaintMaterialsToggle",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            PaintMaterials = state
        end
    })

    Tab:Toggle({
        Title = "Rainbow Colours",
        Desc = "Apply randomized rainbow colours to nearby cubes.",
        Icon = "rainbow",
        Flag = "PaintColoursToggle",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            PaintColours = state
        end
    })

    Tab:Slider({
        Title = "Painting Range",
        Desc = "Maximum distance at which Paint Aura can modify cubes.",
        Flag = "PaintAuraRange",
        Step = 1,
        Value = {
            Min = 20,
            Max = 500,
            Default = 70,
        },

        Callback = function(value)
            Range.Paint = value
        end
    })

    Tab:Space()

    Tab:Section({
        Title = "Build Aura",
        Desc = "Automatically construct blocks around your character.",
        Icon = "blocks",
    })

    Tab:Toggle({
        Title = "Enable Build Aura",
        Desc = "Continuously place cubes at random positions around your character.",
        Icon = "hammer",
        Flag = "BuildAuraToggle",
        Type = "Checkbox",
        Value = false,

        Callback = function(state)
            if Connections["BuildAura"] then
                Connections["BuildAura"]:Disconnect()
                Connections["BuildAura"] = nil
            end

            if state then
                Connections["BuildAura"] = RunService.RenderStepped:Connect(function()
                    local Event = Globals.GetEvent(Globals.GetTool("Build"))

                    if Event then
                        Event:FireServer(
                            workspace.Terrain,
                            Enum.NormalId.Top,
                            getPositionAround(
                                Player.Character.HumanoidRootPart,
                                5,
                                Range.Build
                            ),
                            "normal"
                        )
                    end
                end)
            end
        end
    })

    Tab:Slider({
        Title = "Building Range",
        Desc = "Maximum distance around your character for automatic block placement.",
        Flag = "BuildAuraRange",
        Step = 1,
        Value = {
            Min = 5,
            Max = 24,
            Default = 24,
        },

        Callback = function(value)
            Range.Build = value
        end
    })

    Tab:Space()

    Tab:Paragraph({
        Title = "Aura Information",
        Desc = "Aura features operate continuously while enabled. Higher ranges expand the area of effect. Disable unused features to reduce unnecessary processing.",
        Icon = "info",
    })

    return Tab
end