if _G.Loader then
    return _G.Loader
end
local loader = {}

local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local logs = loadstring(game:HttpGet(baseurl.. "src/Core/Utilities/logs.luau"))()
local cache = {}

function loader.Require(path)
    local a = tick()

    if cache[path] then
        logs:Log(`Loaded {path} in {tick() - a} (CACHED)`, "SUCCESS")

        local cached = cache[path]
        return table.unpack(cached, 2, cached.n)
    end
    
    logs:Log("Loading: " .. path, "INFO")
    local url = baseurl.. path

    local results = table.pack(pcall(function()
        return loadstring(game:HttpGet(url))()
    end))
    local success = results[1]
    local result = results[2]  
    if not success then
        logs:Log(`Failed to load {path} -> {result}: {debug.traceback()}`, "ERROR")
        return nil
    end

    cache[path] = results
    logs:Log(`Loaded {path} in {tostring(tick() - a)}`, "SUCCESS")
    return table.unpack(results, 2, results.n)
end

_G.Loader = loader
return loader