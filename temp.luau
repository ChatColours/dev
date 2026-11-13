local Cooldown = 0.2 -- cooldown for loop if no hookmetamethod
local Time = 0
local DonoTime = 0
local TargetName = ""

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("System")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local rbxgen = TextChatService.TextChannels:WaitForChild("RBXGeneral")

local function getTime()
    return game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats").Time.Value
end

RunService.Heartbeat:Connect(function(dt)
    Time += dt
    DonoTime += dt
    if Time < Cooldown then return end
    Remote:FireServer("Focused")
    if Time > 10 then
        rbxgen:SendAsync(";donate ".. TargetName.. " ".. tostring(getTime() or 10))
        DonoTime = 0
    end
    Time = 0
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "thiing",
    Text = "auto dono and anti time afk loaded",
    Duration = 5
})