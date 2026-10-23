local uptime = 0
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

task.spawn(function()
    while task.wait(1) do
        uptime += 1
        upTime:SetDesc(FormatTime(uptime))
    end
end)
end
