local loader = {}
local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local cache = {}

function loader.Require(path)
    if cache[path] then
        return cache[path]
    end

    local url = baseurl.. path
    local source = game:HttpGet(url)
    local module = loadstring(source)()

    cache[path] = module

    return module
end

return loader