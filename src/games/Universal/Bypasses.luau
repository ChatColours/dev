local method = "hookfunction"
local hooks = {
    ["antikick1"] = nil,
    ["antikick2"] = nil
}
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char and char:WaitForChild("Humanoid")
player.CharacterAdded:Connect(function(c)
    char = c
    humanoid = char:WaitForChild("Humanoid")

    hookmetamethod(humanoid, "__index", newcclosure(function(self, key)
        if typeof(self) == "Instance" and self:IsA("Humanoid") and hooks["HumanoidClient"] and hooks["HumanoidClient"] == true then
            if key == "WalkSpeed" then
                return 16
            elseif key == "JumpPower" then
                return 50
            elseif key == "JumpHeight" then
                return 7.2
            end
        end
    end))
end)

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Bypasses",
        Icon = "bird", -- optional
        Locked = false,
    })

    Tab:Paragraph({
        Title = "Information",
        Desc = "Test Paragraph",
        Color = "Red",
        Image = "",
        ImageSize = 30,
        Thumbnail = "",
        ThumbnailSize = 80,
        Locked = false,
        Buttons = {
            {
                Icon = "bird",
                Title = "Button",
                Callback = function() print("1 Button") end,
            }
        }
    })

    Tab:Dropdown({
        Title = "Hook Method",
        Desc = "How functions should be hooked",
        Values = {"oth.hook", "hookfunction"},
        Value = "hookfunction",
        Callback = function(option) 
            method = option
        end
    })

    Tab:Toggle({
        Title = "Prevent Clientside Humanoid Checks",
        Desc = "This will return normal looking humanoid values to prevent being flagged if the client was to check.",
        Icon = "bird",
        Type = "Checkbox",
        Locked = hookmetamethod == nil,
        Value = false, -- default value
        Callback = function(state) 
            hooks["HumanoidClient"] = state
        end
    })

    Tab:Toggle({
        Title = "Hook Getfenv",
        Desc = "Prevent executor leaks",
        Icon = "bird",
        Type = "Checkbox",
        Locked = oth == nil and hookfunction == nil,
        Value = false, -- default value
        Callback = function(state) 
            if state then
                if method == "oth.hook" then
                    oth.hook(getfenv, function()
                        return {}
                    end)
                elseif method == "hookfunction" then
                    hookfunction(getfenv, function()
                        return {}
                    end)
                end
            else
                restorefunction(getfenv)
                if oth then
                    oth.unhook(getfenv)
                end
            end
        end
    })

    local Toggle = Tab:Toggle({
        Title = "Anti-Kick",
        Desc = "Only works if a localscript tries to kick you",
        Icon = "bird",
        Type = "Checkbox",
        Value = false, -- default value
        Callback = function(state) 
            if state then
                hooks["antikick1"] = hookfunction(game.Players.LocalPlayer.Kick, function()
                    return nil
                end)

                hooks["antikick2"] = hookfunction(
                    getrawmetatable(game).__namecall,
                    newcclosure(function(self, ...)
                        local method = getnamecallmethod()

                        if method == "Kick" then
                            return -- Block kick
                        end

                        return hooks["antikick2"](self, ...)
                    end)
                )
            end
        end
    })
end