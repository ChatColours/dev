local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Globals = Loader.Require("src/games/TheChosenOne/Global.luau")

local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

local paintColour = 0
local blocksInRange = {}
local BricksPath = workspace:WaitForChild("Bricks")
local Bricks = {}
local Range = {
    Paint = 70,
    Build = 24,
    Delete = 70
}

local validParts = {}

for _, v in ipairs(BricksPath:GetDescendants()) do
	if v:IsA("BasePart") then
		validParts[v] = true
	end
end
BricksPath.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		validParts[obj] = true
	end
end)
BricksPath.DescendantRemoving:Connect(function(obj)
	if validParts[obj] then
		validParts[obj] = nil
	end
end)


local function getNearestPart(maxRange : number): BasePart?
	local candidates = {}
	local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	for part in pairs(validParts) do
		if part:IsA("Part") then
			local d = (hrp.Position - part.Position).Magnitude
			if d <= maxRange then
				table.insert(candidates, part)
			end
		end
	end

	if #candidates == 0 then return end

	return candidates[math.random(1, #candidates)]
end

local function GetBricks()
    table.clear(Bricks)
    for _, part in ipairs(BricksPath:GetDescendants()) do
        if part:IsA("Part") then
            table.insert(Bricks, part)
        end
    end
    return Bricks
end

local Params = OverlapParams.new()
Params.FilterType = Enum.RaycastFilterType.Include
Params.FilterDescendantsInstances = {BricksPath}

local function GetBlocksInRange(radius: number)
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return {}
    end

    return workspace:GetPartBoundsInRadius(
        Root.Position,
        radius,
        Params
    )
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
                        Event:FireServer(block, Player.Character.HumanoidRootPart.Position)
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
                        Event:FireServer(
                            block,
                            Enum.NormalId.Front,
                            Player.Character.HumanoidRootPart.Position,
                            "both \xF0\x9F\xA4\x9D",
                            Color3.fromHSV(math.random(), 1, 1),
                            Materials[math.random(1, #Materials)],
                            ""
                        )
                    end
                end)
            else
                Connections["PaintAura"]:Disconnect()
            end
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
