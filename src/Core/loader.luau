local loader = {}
local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local cache = {}

function loader.Require(path)
    local a = tick()

    if cache[path] then
        print(`[STEVEHUB] Loaded {path} in {tostring(tick() - a)} (CACHED)`)
        return cache[path]
    end
    print("[STEVEHUB] Loading: ".. baseurl.. path)
    local url = baseurl.. path

    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn(`[STEVEHUB.REQUIRE] Failed to load {url} -> {result}: {debug.traceback()}`)
        return nil
    end

    cache[path] = result
     print(`[STEVEHUB] Loaded {path} in {tostring(tick() - a)}`)
    return result
end

return loader