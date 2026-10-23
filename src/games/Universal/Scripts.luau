
return function(Window, WindUI)

    local Tab = Window:Tab({
    Title = "Scripts",
    Icon = "terminal", -- optional
    Locked = false,
    })

Tab:Button({
    Title = "Infinite Yield",
    Desc = "A powerful universal admin command script",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})
Tab:Code({
    Title = "Infinite Yield",
    Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()]]
})
end
