local Globals = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character
local bricksFolder = workspace:WaitForChild("Bricks")

Player.CharacterAdded:Connect(function(char: Model)
    Character = char
end)

local validParts = {}

for _, v in ipairs(bricksFolder:GetDescendants()) do
	if v:IsA("BasePart") then
		validParts[v] = true
	end
end
bricksFolder.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		validParts[obj] = true
	end
end)
bricksFolder.DescendantRemoving:Connect(function(obj)
	if validParts[obj] then
		validParts[obj] = nil
	end
end)

function Globals.GetTool(name : string): Tool?
    local gear = Character:FindFirstChild(name)
    if not gear then
        gear = Player.Backpack:FindFirstChild(name)
    end

    if gear then
        return gear
    else
        return nil
    end
end

function Globals.getNearestPart(maxRange : number): BasePart?
	local candidates = {}
	local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
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

function Globals.GetEvent(tool : Tool): RemoteEvent?
    if tool then
        local Script = tool:FindFirstChild("Script")
        local Event = Script and Script:FindFirstChild("Event")
        if Event then
            return Event
        else
            return nil
        end
    end
end

return Globals