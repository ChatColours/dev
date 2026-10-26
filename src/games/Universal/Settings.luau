local init = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"))()
local ogCap = getfpscap and getfpscap()
local UnlockFPS = false
local saveName = "main"
local currConfig = _G.ConfigManager:CreateConfig(saveName)

local function NameJsonFile(name: string): string
    if name:sub(-5) == ".json" then
        return name
    else
        return name.. ".json"
    end
end

local function changeFPS(n : number)
    if setfpscap and UnlockFPS then
        pcall(function()
            setfpscap(n)
        end) 
    end 
end

return function(Window, WindUI)

    local Tab = Window:Tab({
    Title = "Settings",
    Icon = "house", -- optional
    Locked = false,
    })

    Tab:Toggle({
        Title = "Unlock FPS",
        Desc = "Allow custom FPS settings. FPS also affects how fast some features run. At one FPS a second, features that run on your FPS will execute once a second.",
        Value = false, -- default value
        Callback = function(state) 
            if not state then
                pcall(function()
                    setfpscap(ogCap) -- reset fps cap
                end)
            else
                UnlockFPS = true
            end
        end
    })

    Tab:Slider({
        Title = "FPS Cap",
        Desc = "Change your FPS cap. For no cap, set it to 0.",
        Step = 1,
        Value = {
            Min = 0,
            Max = 1000,
            Default = ogCap or 60,
        },
        Callback = function(value)
            changeFPS(value)
        end
    })

    Tab:Divider()

    Tab:Input({
        Title = "Configuration Name",
        Desc = "The name for the save file.",
        Value = "main",
        Type = "Input", -- or "Textarea"
        Placeholder = "main",
        Callback = function(input) 
            saveName = NameJsonFile(input)
        end
    })

    
    local saves = Tab:Dropdown({
        Title = "Load Configuration",
        Desc = "Select a saved configuration and load it",
        Values = _G.ConfigManager:AllConfigs(),
        Value = "",
        Callback = function(option) 
            currConfig = _G.ConfigManager:CreateConfig(option)
        end
    })

    Tab:Button({
        Title = "Save Configuration",
        Desc = "Saves the current values of features",
        Locked = false,
        Callback = function()
           currConfig = _G.ConfigManager:CreateConfig(saveName)
           currConfig:Save()
           saves:Refresh(_G.ConfigManager:AllConfigs())
        end
    })

    Tab:Button({
        Title = "Load Configuration",
        Desc = "Load a saved configuration to use",
        Locked = false,
        Callback = function()
           currConfig:Load()
        end
    })

    Tab:Button({
        Title = "Delete Configuration",
        Desc = "Delete a saved configuration",
        Locked = false,
        Callback = function()
           currConfig:Delete()
            saves:Refresh(_G.ConfigManager:AllConfigs())
        end
    })
end