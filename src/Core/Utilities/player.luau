local Player = {}
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function Player.SendFriendReq(player : string)
    local targetPlayer = Players:FindFirstChild("Hotdogmacko") 

    if not targetPlayer or targetPlayer == Players.LocalPlayer then return end

    task.spawn(function()
        while true do
            local success = pcall(function()
                StarterGui:SetCore("PromptSendFriendRequest", targetPlayer)
            end)
            
            if success then
                break
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
end

return Player