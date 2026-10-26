local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()

local ConfigManager = _G.ConfigManager

local ogCap = getfpscap and getfpscap() or 60
local UnlockFPS = false
local CurrentFPS = ogCap

local saveName = "main"
local currConfig = nil

local function ChangeFPS(value: number)
    CurrentFPS = value

    if UnlockFPS and setfpscap then
        local Success, Error = pcall(setfpscap, value)

        if not Success then
            warn("[Settings] Failed to change FPS:", Error)
        end
    end
end

local function SetFPSUnlocked(state: boolean)
    UnlockFPS = state

    if state then
        ChangeFPS(CurrentFPS)
    elseif setfpscap then
        local Success, Error = pcall(setfpscap, ogCap)

        if not Success then
            warn("[Settings] Failed to restore FPS:", Error)
        end
    end
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Settings",
        Icon = "settings",
        Locked = false,
    })

    Tab:Toggle({
        Title = "Unlock FPS",
        Desc = "Enable custom FPS limits. Frame-dependent features may update less frequently at lower FPS.",
        Value = false,

        Callback = function(state)
            SetFPSUnlocked(state)
        end
    })

    Tab:Slider({
        Title = "FPS Cap",
        Desc = "Change your FPS limit. Set to 0 for unlimited FPS.",
        Step = 1,

        Value = {
            Min = 0,
            Max = 1000,
            Default = ogCap,
        },

        Callback = function(value)
            ChangeFPS(value)
        end
    })

    Tab:Divider()

    Tab:Input({
        Title = "Configuration Name",
        Desc = "Enter the name of the configuration you want to save.",
        Value = saveName,
        Type = "Input",
        Placeholder = "main",

        Callback = function(input)
            saveName = input
        end
    })

    local saves

    local function RefreshConfigs()
        saves:Refresh(ConfigManager:AllConfigs())
    end

    local function Notify(title, content, duration)
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 4
        })
    end

    saves = Tab:Dropdown({
        Title = "Select Configuration",
        Desc = "Choose an existing configuration to load or delete.",
        Values = ConfigManager:AllConfigs(),
        Value = "",

        Callback = function(option)
            if type(option) == "table" then
                option = option[1]
            end

            if not option or option == "" then
                currConfig = nil
                return
            end

            local Success, Result = pcall(function()
                return ConfigManager:CreateConfig(option)
            end)

            if Success then
                currConfig = Result
            else
                currConfig = nil
                warn("[Settings] Failed to select configuration:", Result)
            end
        end
    })

    Tab:Button({
        Title = "Save Configuration",
        Desc = "Save the current feature settings to a configuration file.",
        Locked = false,

        Callback = function()
            local Success, Result, Error = pcall(function()
                local Config = ConfigManager:CreateConfig(saveName)
                local Saved, SaveError = Config:Save()

                return Saved, SaveError
            end)

            if Success and Result then
                Notify(
                    "Configuration Saved",
                    "Successfully saved " .. saveName
                )

                RefreshConfigs()
            else
                Notify(
                    "Save Failed",
                    tostring(Success and Error or Result)
                )
            end
        end
    })

    Tab:Button({
        Title = "Load Configuration",
        Desc = "Load the selected configuration.",
        Locked = false,

        Callback = function()
            if not currConfig then
                Notify(
                    "No Configuration Selected",
                    "Select a configuration from the dropdown first."
                )
                return
            end

            local Success, Result, Error = pcall(function()
                return currConfig:Load()
            end)

            if Success and Result then
                Notify(
                    "Configuration Loaded",
                    "Successfully loaded " .. currConfig.Name
                )
            else
                Notify(
                    "Load Failed",
                    tostring(Success and Error or Result)
                )
            end
        end
    })

    Tab:Button({
        Title = "Delete Configuration",
        Desc = "Permanently delete the selected configuration.",
        Locked = false,

        Callback = function()
            if not currConfig then
                Notify(
                    "No Configuration Selected",
                    "Select a configuration from the dropdown first."
                )
                return
            end

            local ConfigName = currConfig.Name

            local Success, Result, Error = pcall(function()
                return currConfig:Delete()
            end)

            if Success and Result then
                currConfig = nil

                RefreshConfigs()

                Notify(
                    "Configuration Deleted",
                    "Successfully deleted " .. ConfigName
                )
            else
                Notify(
                    "Delete Failed",
                    tostring(Success and Error or Result)
                )
            end
        end
    })

    return Tab
end