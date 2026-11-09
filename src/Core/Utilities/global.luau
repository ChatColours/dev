local globals = {}
local Services = {
    Players = game:GetService("Players")
}

globals.PlayerData = {
    LocalPlayer = Services.Players.LocalPlayer,
    UserId = Services.Players.LocalPlayer.UserId,
    Username = Services.Players.LocalPlayer.Name
}
globals.GameData = {
    JobId = game.JobId
}

return globals