local Players = game:GetService("Players")
local uptime = 0

local init = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"
))()

local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    local secondsLeft = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secondsLeft)
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Home",
        Icon = "house",
        Locked = false,
    })

    local localPlayer = Players.LocalPlayer
    local displayName = localPlayer and localPlayer.DisplayName or "there"

    Tab:Callout({
        Title = "Welcome, " .. displayName,
        Desc = "Your Mocha Hub session at a glance.",
        Icon = "sparkles",
    })

    local TopRow = Tab:HStack()

    local Session = TopRow:Group({
        Title = "Session",
        Desc = "Time in the hub",
        Icon = "clock-3",
        Padding = 12,
        Gap = 8,
    })

    local uptimeStat = Session:Stat({
        Title = "Uptime",
        Value = FormatTime(uptime),
        Desc = "Hours : minutes : seconds",
        ValueSize = 21,
        Padding = 12,
    })

    local Server = TopRow:Group({
        Title = "Server",
        Desc = "Current session",
        Icon = "users",
        Padding = 12,
        Gap = 8,
    })

    local playerCount = Server:Stat({
        Title = "Players online",
        Value = tostring(#Players:GetPlayers()),
        Desc = "In this server",
        ValueSize = 21,
        Padding = 12,
    })

    local Advanced = Tab:Group({
        Title = "Advanced tools",
        Desc = "Optional utilities for experienced users",
        Icon = "shield-alert",
        Padding = 12,
        Gap = 8,
    })

    Advanced:Button({
        Title = "Load Anticheat Bypass Tab",
        Desc = "Review the warning before loading this tab.",
        Callback = function()
            WindUI:Popup({
                Title = "Load Anticheat Bypass tab?",
                Icon = "triangle-alert",
                Content = "This is a potentially dangerous tab to have loaded, which is why we ask first. We do not guarantee that this will bypass anticheats, but it may help bypass certain stuff. A newindex bypass is automatically run to ensure that anticheats do not detect the bypass tab. This requires a high level executor.",
                Buttons = {
                    {
                        Title = "Cancel",
                        Callback = function() end,
                        Variant = "Tertiary",
                    },
                    {
                        Title = "Continue",
                        Icon = "arrow-right",
                        Callback = function()
                            init(Window, WindUI, "Universal/Bypasses.luau")
                        end,
                        Variant = "Primary",
                    },
                },
            })
        end,
    })

    task.spawn(function()
        while task.wait(1) do
            uptime += 1
            uptimeStat:SetValue(FormatTime(uptime))
            playerCount:SetValue(tostring(#Players:GetPlayers()))
        end
    end)
end
