local Globals = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character

Player.CharacterAdded:Connect(function(char: Model)
    Character = char
end)

function Globals.GetTool(name : string): Tool?
    local gear = Character:FindFirstChild(name)
    if not gear then
        gear = Player.Backpack:FindFirstChild(name)
    end

    if gear then
        return gear
    else
        return nil
    end
end

function Globals.GetEvent(tool : Tool): RemoteEvent?
    if tool then
        local Script = tool:FindFirstChild("Script")
        local Event = Script and Script:FindFirstChild("Event")
        if Event then
            return Event
        else
            return nil
        end
    end
end

return Globals