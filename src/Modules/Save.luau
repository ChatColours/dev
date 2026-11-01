local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"))()
local Logs = Loader.Require("src/Core/Utilities/logs.luau")

local Config = {}
Config.__index = Config

_G.Data = _G.Data or {}

local HttpService = game:GetService("HttpService")

local Path = "Steve/Configurations"

local function EnsureFolder()
    if not isfolder("Steve") then
        makefolder("Steve")
    end

    if not isfolder(Path) then
        makefolder(Path)
    end
end

local function NormalizeName(name: string): string
    assert(type(name) == "string", "Configuration name must be a string")

    name = name:match("^%s*(.-)%s*$")

    if name:sub(-5):lower() == ".json" then
        name = name:sub(1, -6)
    end

    assert(#name > 0, "Configuration name cannot be empty")
    assert(#name <= 64, "Configuration name is too long")
    assert(
        name:match("^[%w_%- ]+$"),
        "Configuration name contains invalid characters"
    )

    return name .. ".json"
end

local function GetPath(name: string): string
    return Path .. "/" .. NormalizeName(name)
end

function Config:CreateConfig(name: string)
    local FileName = NormalizeName(name)

    local self = setmetatable({
        Name = FileName,
        Path = Path .. "/" .. FileName
    }, Config)

    return self
end

function Config:Exists(): boolean
    return isfile(self.Path)
end

function Config:Save(data)
    EnsureFolder()

    local Data = data or _G.Data

    assert(type(Data) == "table", "Configuration data must be a table")

    local Success, Result = pcall(function()
        local Encoded = HttpService:JSONEncode(Data)
        writefile(self.Path, Encoded)
    end)

    if not Success then
        Logs:Log(
            "Failed to save configuration: " .. Result,
            "ERROR"
        )
        return false, Result
    end

    return true
end

function Config:Load()
    if not self:Exists() then
        return false, "Configuration does not exist"
    end

    local Success, Result = pcall(function()
        local Contents = readfile(self.Path)
        return HttpService:JSONDecode(Contents)
    end)

    if not Success then
        Logs:Log(
            "Failed to load configuration: " .. Result,
            "ERROR"
        )
        return false, Result
    end

    if type(Result) ~= "table" then
        return false, "Invalid configuration data"
    end

    table.clear(_G.Data)

    for Key, Value in pairs(Result) do
        _G.Data[Key] = Value
    end

    return true, _G.Data
end

function Config:Delete()
    if not self:Exists() then
        return false, "Configuration does not exist"
    end

    local Success, Result = pcall(function()
        delfile(self.Path)
    end)

    if not Success then
        Logs:Log(
            "Failed to delete configuration: " .. Result,
            "ERROR"
        )
        return false, Result
    end

    return true
end

function Config:AllConfigs()
    EnsureFolder()

    local Success, Files = pcall(function()
        return listfiles(Path)
    end)

    if not Success then
        Logs:Log(
            "Failed to list configurations: " .. Files,
            "ERROR"
        )
        return {}
    end

    local Configurations = {}

    for _, File in ipairs(Files) do
        local Name = File:gsub("\\", "/"):match("([^/]+)$")

        if Name and Name:sub(-5):lower() == ".json" then
            table.insert(Configurations, Name)
        end
    end

    table.sort(Configurations)

    return Configurations
end

return Config