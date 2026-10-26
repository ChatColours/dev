local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Config = {}
local _, files = Loader.Require("src/Core/Utilities/files.luau")
local path = "Steve/Configurations"
local HttpService = game:GetService("HttpService")

function Config.Save(name :string, data)
    files.Write(path.. name, data)
end

function Config.Load()

end

return Config