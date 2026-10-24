local method = "hookfunction"
local hooks = {
    ["antikick1"] = nil,
    ["antikick2"] = nil
}
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char and char:WaitForChild("Humanoid")
local HumanoidHook

local function hookHumanoid()
    HumanoidHook = hookmetamethod(humanoid, "__index", newcclosure(function(self, key)
        if typeof(self) == "Instance" and self:IsA("Humanoid") and hooks["HumanoidClient"] and hooks["HumanoidClient"] == true then
            if key == "WalkSpeed" then
                return 16
            elseif key == "JumpPower" then
                return 50
            elseif key == "JumpHeight" then
                return 7.2
            end
        end

        return HumanoidHook(self, key)
    end))
end

player.CharacterAdded:Connect(function(c)
    char = c
    humanoid = char:WaitForChild("Humanoid")

    hookHumanoid()
end)

hookHumanoid()

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Bypasses",
        Icon = "bird", -- optional
        Locked = false,
    })

    Tab:Paragraph({
        Title = "Information",
    Desc = [[
<font size="22" color="#D9B78C"><b>Executor Hooks &amp; Compatibility</b></font>

<font color="#E0D5C5">SteveHub</font> provides various hooking features designed to work with supported executor functions.

<font color="#A99B8A"><i>Features that are not supported by your current executor will automatically be locked or unavailable.</i></font>

<font size="17" color="#C6A47D"><b>Hooking Methods</b></font>

<font color="#D9B78C"><b>Hookfunction</b></font>
<font color="#CFC5B8">A traditional hooking method that replaces or redirects function calls. Depending on the implementation, hooked callbacks may expose information about their execution environment.</font>

<font color="#D9B78C"><b>OTH Hooks</b></font>
<font color="#CFC5B8">An alternative hooking method that may use separate execution threads or environments, depending on the executor's implementation.</font>

<font size="17" color="#C6A47D"><b>Key Differences</b></font>
<font color="#CFC5B8">• <b>Hookfunction:</b> Traditional function interception.
• <b>OTH:</b> Alternative thread-based hooking mechanisms.
• <b>Compatibility:</b> Availability varies between executors.
• <b>Detection:</b> Neither method guarantees undetectability.</font>

<font size="17" color="#C6A47D"><b>Important Information</b></font>
<font color="#A6C48A">✓</font> Unsupported features will be locked automatically.
<font color="#A6C48A">✓</font> Available methods depend on executor capabilities.
<font color="#D9B78C">!</font> Hooking behaviour may vary across executors.
<font color="#D9B78C">!</font> Some methods may introduce compatibility or stability issues.

<font color="#A99B8A"><i>Select the hooking method best suited to your executor and its supported functionality.</i></font>

<font color="#D9B78C"><b>SteveHub</b></font>
<font color="#A99B8A"><i>Developed by ChatColours.</i></font>
]],
        Color = Color3.fromHex("#3B3027"),
        Image = "",
        ImageSize = 30,
        Thumbnail = "",
        ThumbnailSize = 80,
        Locked = false,
        Buttons = {

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

    Tab:Toggle({
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
                            return
                        end

                        return hooks["antikick2"](self, ...)
                    end)
                )
            else
                hooks["antikick1"] = nil
                hooks["antikick2"] = nil
                restorefunction(game.Players.LocalPlayer.Kick)
                restorefunction(getrawmetatable(game).__namecall)
            end
        end
    })
end