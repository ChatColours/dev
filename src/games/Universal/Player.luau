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
        Icon = "user-round",
        Locked = false,
    })

    Tab:Paragraph({
        Title = "LocalPlayer Settings",
        Desc = "Customize your character's movement, walking speed, teleport movement, and jumping abilities.",
        Icon = "settings-2",
    })

    Tab:Space()

    Tab:Section({
        Title = "WalkSpeed",
        Desc = "Manage your character's movement speed.",
        Icon = "footprints",
    })

    Tab:Toggle({
        Title = "Enable WalkSpeed",
        Desc = "Override your character's default walking speed.",
        Type = "Checkbox",
        Flag = "WalkSpeedToggle",
        Value = false,
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
        Desc = "Adjust how fast your character walks.",
        Flag = "WalkSpeedSlider",
        Step = 1,
        Value = {
            Min = 1,
            Max = 500,
            Default = 16,
        },
        Callback = function(value)
            Speed = value
        end
    })

    Tab:Space()

    Tab:Section({
        Title = "Teleport Movement",
        Desc = "Move faster without modifying Humanoid.WalkSpeed.",
        Icon = "zap",
    })

    Tab:Toggle({
        Title = "Teleport Walk",
        Desc = "Move your character using small position adjustments.",
        Type = "Checkbox",
        Flag = "TpWalkToggle",
        Value = false,
        Callback = function(state)
            if tpwalk then
                tpwalk:Disconnect()
                tpwalk = nil
            end

            if state then
                tpwalk = RunService.Heartbeat:Connect(function(dt: number)
                    local direction = humanoid.MoveDirection

                    if direction.Magnitude < 0.001 then
                        return
                    end

                    local displace = direction.Unit * tpWalkSpeed * dt
                    character:PivotTo(character:GetPivot() + displace)
                end)
            end
        end
    })

    Tab:Slider({
        Title = "Teleport Walk Speed",
        Desc = "Control the additional movement speed in studs per second.",
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

    Tab:Space()

    Tab:Section({
        Title = "Jump Settings",
        Desc = "Customize your character's jumping power.",
        Icon = "arrow-up-from-line",
    })

    Tab:Toggle({
        Title = "Enable JumpPower",
        Desc = "Override your character's default jumping power.",
        Type = "Checkbox",
        Flag = "EnableJump",
        Value = false,
        Callback = function(state)
            JumpEnabled = state

            if state then
                OgJump = humanoid.JumpPower
            else
                humanoid.JumpPower = OgJump
            end
        end
    })

    Tab:Slider({
        Title = "JumpPower",
        Desc = "Adjust how high your character can jump.",
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

    Tab:Space()

    Tab:Paragraph({
        Title = "Movement Information",
        Desc = "WalkSpeed changes your Humanoid's movement speed. Teleport Walk moves your character directly, while JumpPower controls jumping strength.",
        Icon = "info",
    })

    RunService.RenderStepped:Connect(function()
        if humanoid and SpeedEnabled then
            humanoid.WalkSpeed = Speed
        end

        if humanoid and JumpEnabled then
            humanoid.JumpPower = JumpPower
        end
    end)

    return Tab
end