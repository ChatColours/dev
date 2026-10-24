local uptime = 0
local init = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/init.luau"))()
local function FormatTime(Seconds)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor(Seconds % 3600 / 60)
    local SecondsLeft = math.floor(Seconds % 60)

    return string.format("%02d hours %02d minutes %02d seconds", Hours, Minutes, SecondsLeft)
end

return function(Window, WindUI)

    local Tab = Window:Tab({
    Title = "Home",
    Icon = "house", -- optional
    Locked = false,
    })

    local upTime = Tab:Paragraph({
    Title = "Uptime",
    Desc = FormatTime(uptime),
    Color = Color3.fromHex("#3B3027"),
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
    }
})

Tab:Button({
    Title = "Load Anticheat Bypass Tab",
    Desc = "Tab designed to bypass anticheat methods",
    Locked = false,
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
                }
            }
        })
    end
})
task.spawn(function()
    while task.wait(1) do
        uptime += 1
        upTime:SetDesc(FormatTime(uptime))
    end
end)
end