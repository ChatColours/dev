local loader = {}
local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local cache = {}

function loader.Require(path)
    local a = tick()

    if cache[path] then
        print(`Loaded {path} in {tostring(tick() - a)} (CACHED)`)
        return cache[path]
    end
    print("Loading: ".. baseurl.. path)
    local url = baseurl.. path
    local source = game:HttpGet(url)

    local success, result = pcall(function()
        return loadstring(source)()
    end)
    
    if not success then
        warn(`Failed to load {url} -> {result}`)
        return nil
    end

    cache[path] = result
     print(`Loaded {path} in {tostring(tick() - a)}`)
    return result
end

return loader