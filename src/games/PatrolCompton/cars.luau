local CarConfig = require(game:GetService("ReplicatedStorage").Shared.Config.VehicleConfig)
local function SetData(expected, val)
    for team, _ in pairs(CarConfig.Handling) do
        for i, v in pairs(team) do
             if i == expected then i = val end
        end
    end
end

return function(Window, WindUI)
    local Handling = CarConfig.Handling
    local ResetVals = CarConfig
    local Tab = Window:Tab({
    Title = "Car Mods",
    Icon = "bird", -- optional
    Locked = false,
})

local Button = Tab:Button({
    Title = "Reset",
    Desc = "Test Button",
    Locked = false,
    Callback = function()
        -- ...
    end
})
    Tab:Slider({
    Title = "Mass",
    Desc = "How heavy the car is",
    Step = 1,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 380,
    },
    Callback = function(value)
        SetData("Mass", value)
    end
})
    Tab:Slider({
    Title = "Acceleration",
    Desc = "How fast the car accelerates",
    Step = 1,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 20,
    },
    Callback = function(value)
        SetData("Acceleration", value)
    end
})

    Tab:Slider({
    Title = "Grip",
    Desc = "How grippy the wheels should be",
    Step = 1,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 0.38,
    },
    Callback = function(value)
        SetData("Grip", value)
    end
})
    Tab:Slider({
    Title = "Max Speed",
    Desc = "The top speed for the vehicle",
    Step = 1,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 150,
    },
    Callback = function(value)
        SetData("MaxSpeed", value)
    end
})

    Tab:Slider({
    Title = "Steer Speed",
    Desc = "How fast steering is",
    Step = 1,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 3,
    },
    Callback = function(value)
        SetData("SteerSpeed", value)
    end
})
end