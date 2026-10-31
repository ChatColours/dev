workspace.ChildAdded:Connect(function(object)
    if object:IsA("BasePart") and object:FindFirstChild("Mesh") then
        if object.Mesh.MeshId == "http://www.roblox.com/asset/?id=189741947" then
            
        end
    end
end)

return function(Window, WindUI)

end