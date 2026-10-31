return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Plugin test tab",
        Icon = "bird", -- optional
        Locked = false,
    })

    Tab:Button({
        Title = "Button",
        Desc = "Test Button",
        Locked = false,
        Callback = function()
           WindUI:Notify({
                Title = "Plugin test",
                Content = "This is a plugin test tab!",
                Duration = 3, -- 3 seconds
                Icon = "bird",
            })
        end
    })
end