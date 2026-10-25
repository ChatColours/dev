local Globals = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character

Player.CharacterAdded:Connect(function(char: Model)
    Character = char
end)

function Globals.GetTool(name : string)
    local gear = Character:FindFirstChild(name)
    if gear then
        return gear
    else
        return nil
    end
end

return Globals