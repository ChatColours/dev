local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local range = 10
local paintColour = 0
local blocksInRange = {}
local Bricks = workspace:WaitForChild("Bricks")
local function GetBlocksInRange()
    for i, v in ipairs(Bricks) do
        if (v.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= range then
            table.insert(blocksInRange, v)
        else
            if table.find(blocksInRange, v) then
                table.remove(blocksInRange, table.find(blocksInRange, v))
            end
        end
    end
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
    Icon = "bird",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        if state then
            Connections["DelAura"] = RunService.RenderStepped:Connect(function()
                local delTool = Player.Backpack:FindFirstChild("Delete") or Player.Character:FindFirstChild("Delete")
                if delTool then
                    for i, v in ipairs(blocksInRange) do
                        delTool.Script.Event:FireServer(v, Player.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            Connections["DelAura"]:Disconnect()
        end
    end
})

    Tab:Toggle({
    Title = "Paint Aura",
    Desc = "rainbow paint cubes in range",
    Icon = "bird",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        if state then
            Connections["PaintAura"] = RunService.RenderStepped:Connect(function()
                local Paint = Player.Backpack:FindFirstChild("Paint") or Player.Character:FindFirstChild("Paint")
                if Paint then
                    for i, v in ipairs(blocksInRange) do
                        Paint.Script.Event:FireServer(
                            v,
                            Enum.NormalId.Front,
                            Player.Character.HumanoidRootPart.Position,
                            "both \xF0\x9F\xA4\x9D",
                            Color3.fromHSV(math.random(0, 1), 1, 1),
                            Materials[math.random(1, #Materials)],
                            ""
                        )
                    end
                end
            end)
        else
            Connections["PaintAura"]:Disconnect()
        end
    end
})
end