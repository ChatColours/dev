workspace.ChildAdded:Connect(function(object)
    if object:IsA("BasePart") and object:FindFirstChild("Mesh") then
        if object.Mesh.MeshId == "http://www.roblox.com/asset/?id=189741947" then
            
        end
    end
end)
local Enabled = {
    AbuseDetection = false
}
return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "CMD Logs",
        Icon = "bird", -- optional
        Locked = false,
    })
    local HStack = Tab:HStack()
    local Left = HStack:VStack()
    local Right = HStack:VStack()

    local AbuseLogs = Left:Group({
        Title = "Abuse Detection",
        Desc = "Detect when powerful commands are used",
        Icon = "server",
        Layout = "Vertical",
        Padding = 12,
        Gap = 8,
        Border = true,
    })

    AbuseLogs:Toggle({
        Title = "Abuse Detection Enabled",
        Callback = function(state)
            Enabled.AbuseDetection = state
        end
    })

    AbuseLogs:Toggle({
        Title = "All Cmds Only",
        Desc = "While enabled, only commands that target all players will be flagged.",
        Callback = function(state)
            print("Toggle state:", state)
        end
    })
end