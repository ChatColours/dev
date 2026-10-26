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
local tpWalkSpeed = 10
local SpeedEnabled, JumpEnabled = false, false
local tpwalk
return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "LocalPlayer",
        Icon = "user", -- optional
        Locked = false,
    })

    Tab:Toggle({
        Title = "Enable Speed",
        Desc = "Toggle for walkspeed",
        Type = "Checkbox",
        Flag = "WalkSpeedToggle",
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
        Flag = "WalkSpeedSlider",
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
        Title = "Teleport Walk",
        Desc = "Toggle for TP Walk, makes you go faster without changing the humanoid speed",
        Type = "Checkbox",
        Flag = "TpWalkToggle",
        Value = false, -- default value
        Callback = function(state) 
            if state then
                tpwalk = RunService.Heartbeat:Connect(function(dt: number)
                    local direction = humanoid.MoveDirection
                    if direction.Magnitude < 0.001 then
                        return
                    end

                    local displace = direction.Unit * tpWalkSpeed * dt
                    character:PivotTo(character:GetPivot() + displace)
                end)
            else
                tpwalk:Disconnect()
            end
        end
    })

        Tab:Slider({
        Title = "Teleport Walk Speed",
        Desc = "How fast you should tpwalk",
        Flag = "SpeedSlider",
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = 10,
        },
        Callback = function(value)
            tpWalkSpeed = value
        end
    })

        Tab:Toggle({
        Title = "Enable Jump",
        Desc = "Toggle for jump",
        Type = "Checkbox",
        Flag = "EnableJump",
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
        Flag = "JumpPowerSlide",
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