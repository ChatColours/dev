local repFirst = game:GetService("ReplicatedFirst")

repFirst.ChildAdded:Connect(function(child)
    if child:IsA("Script") then
        local opt = s
        saveinstance(child)
    end
end)