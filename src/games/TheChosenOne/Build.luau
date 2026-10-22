local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local range = 10
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

return function(Window, WindUI)

    local Connections = {}

    local Tab = Window:Tab({
    Title = "Grief",
   -- Icon = "bomb", -- optional
    Locked = false,
    })
    
    local Toggle = Tab:Toggle({
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
                        delTool.Event:FireServer(v, Player.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            Connections["DelAura"]:Disconnect()
        end
    end
})
end