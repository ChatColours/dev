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
    Icon = "bomb", -- optional
    Locked = false,
    })
    
    Tab:Toggle({
        Title = "Delete Aura",
        Desc = "delete cubes that are in range",
        Value = false, -- default value
        Callback = function(state) 
            if state then
                Connections["DelAura"] = RunService.RenderStepped:Connect(function()
                    local Event = Globals.GetEvent(Globals.GetTool("Delete"))
                    if Event then
                        local block = getNearestPart(Range.Delete)
                        Event:FireServer(block, Globals.GetLocalPosition())
                    end
                end)
            else
                Connections["DelAura"]:Disconnect()
            end
        end
    })

    Tab:Slider({
        Title = "Delete Aura Range",
        Desc = "The range for delete aura",
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

    Tab:Toggle({
        Title = "Paint Aura",
        Desc = "rainbow paint cubes in range",
        Value = false, -- default value
        Callback = function(state) 
            if state then
                Connections["PaintAura"] = RunService.RenderStepped:Connect(function()
                    
                    local Event = Globals.GetEvent(Globals.GetTool("Paint"))
                    if Event then
                        local block = getNearestPart(Range.Paint)
                        if not block then return end
                        local colour = PaintColours and Color3.fromHSV(math.random(), 1, 1) or block.Color
                        local material = PaintMaterials and Materials[math.random(1, #Materials)] or block.Material.Name:lower()
                        Event:FireServer(
                            block,
                            Enum.NormalId.Front,
                            Globals.GetLocalPosition(),
                            "both \xF0\x9F\xA4\x9D",
                            colour,
                            material,
                            ""
                        )
                    end
                end)
            else
                Connections["PaintAura"]:Disconnect()
            end
        end
    })

    Tab:Toggle({
        Title = "Paint Materials",
        Desc = "If paint aura should also change materials",
        Value = false, -- default value
        Callback = function(state) 
            PaintMaterials = state
        end
    })
    Tab:Toggle({
        Title = "Paint Colours",
        Desc = "If paint aura should also change colours",
        Value = false, -- default value
        Callback = function(state) 
            PaintColours = state
        end
    })

    Tab:Slider({
        Title = "Paint Aura Range",
        Desc = "The range for paint aura",
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

    Tab:Toggle({
        Title = "Build Aura",
        Desc = "build cubes in range",
        Value = false, -- default value
        Callback = function(state) 
            if state then
                Connections["BuildAura"] = RunService.RenderStepped:Connect(function()
                    local Event = Globals.GetEvent(Globals.GetTool("Build"))
                    if Event then
                        Event:FireServer(workspace.Terrain, Enum.NormalId.Top, getPositionAround(Player.Character.HumanoidRootPart, 5, Range.Build), "normal")
                    end
                end)
            else
                Connections["BuildAura"]:Disconnect()
            end
        end
    })
    Tab:Slider({
        Title = "Build Aura Range",
        Desc = "The range for build aura",
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
end
