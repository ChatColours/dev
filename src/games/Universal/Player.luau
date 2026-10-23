local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local humanoid, root = character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid, root = character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
end)
local Speed, JumpPower = 16, 50
local OgSpeed = 16
local OgJump = 50
local SpeedEnabled, JumpEnabled = false, false
return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "LocalPlayer",
        Icon = "user", -- optional
        Locked = false,
    })

    Tab:Toggle({
        Title = "Enable Speed",
        Desc = "Toggle for walkspeed",
        Icon = "bird",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            SpeedEnabled = state
            if state then
                OgSpeed = humanoid.WalkSpeed
            else
                humanoid.WalkSpeed = OgSpeed
            end
        end
    })

    Tab:Slider({
        Title = "WalkSpeed",
        Desc = "How fast you should walk",
        
        -- To make float number supported, 
        -- make the Step a float number.
        -- example: Step = 0.1
        Step = 1,
        Value = {
            Min = 20,
            Max = 500,
            Default = 16,
        },
        Callback = function(value)
            Speed = value
        end
    })

        Tab:Toggle({
        Title = "Enable Jump",
        Desc = "Toggle for jump",
        Icon = "bird",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            SpeedEnabled = state
            if state then
                OgJump = humanoid.JumpPower
            else
                humanoid.JumpPower = OgJump
            end
        end
    })

    Tab:Slider({
        Title = "Jumppower",
        Desc = "How fast you should walk",
        
        -- To make float number supported, 
        -- make the Step a float number.
        -- example: Step = 0.1
        Step = 1,
        Value = {
            Min = 20,
            Max = 1000,
            Default = 50,
        },
        Callback = function(value)
            JumpPower = value
        end
    })

    RunService.RenderStepped:Connect(function()
        if humanoid and SpeedEnabled then
            humanoid.WalkSpeed = Speed
        end

        if humanoid and JumpEnabled then
            humanoid.JumpPower = JumpPower
        end
    end)
end