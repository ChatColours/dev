local loader = {}
local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local cache = {}

function loader.Require(path)
    local a = tick()

    if cache[path] then
        print(`Loaded {path} in {tostring(tick() - a)} (CACHED)`)
        return cache[path]
    end

    local url = baseurl.. path
    local source = game:HttpGet(url)
    local module = loadstring(source)()

    cache[path] = module
     print(`Loaded {path} in {tostring(tick() - a)}`)
    return module
end

return loader