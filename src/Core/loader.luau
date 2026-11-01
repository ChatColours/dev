local loader = {}
local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local logs = loadstring(game:HttpGet(baseurl.. "src/Core/Utilities/logs.luau"))()
local cache = {}

function loader.Require(path)
    local a = tick()

    if cache[path] then
        logs:Log(`Loaded {path} in {tostring(tick() - a)} (CACHED)`, "SUCCESS")
        return cache[path]
    end
    
    logs:Log("Loading: " .. path, "INFO")
    local url = baseurl.. path

    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        logs:Log(`Failed to load {path} -> {result}: {debug.traceback()}`, "ERROR")
        return nil
    end

    cache[path] = result
    logs:Log(`Loaded {path} in {tostring(tick() - a)}`, "SUCCESS")
    return result
end

return loader