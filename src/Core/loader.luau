if type(_G.Loader) == "table"
    and type(_G.Loader.Require) == "function" then
    return _G.Loader
end

local loader = {}
loader.loadedimages = false

local baseurl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/"
local function get(FileName, Link)
    if isfile("MochaHub/assets/".. FileName) then
        return getcustomasset("MochaHub/assets/".. FileName)
    else
        local success, result = pcall(function()
            return game:HttpGet(Link)
        end)
        if success then
            writefile("MochaHub/assets/".. FileName, result)
            return getcustomasset("MochaHub/assets/".. FileName)
        end
    end
    return nil
end 

local assetUrl = baseurl.. "assets/"
local images = {
    "icon.png",
    "banner.png"
}

if not loader.loadedimages then
    for _, path in ipairs(images) do
        get(path, assetUrl.. path)
    end
    loader.loadedimages = true
end

local logs = loadstring(game:HttpGet(baseurl.. "src/Core/Utilities/logs.luau"))()
loader.cache = {}


function loader.Require(path)
    local a = tick()
    print(`Loader is loading {path}`)
    if loader.cache[path] then
        logs:Log(`Loaded {path} in {tick() - a} (CACHED)`, "SUCCESS")

        local cached = loader.cache[path]
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

    loader.cache[path] = results
    logs:Log(`Loaded {path} in {tostring(tick() - a)}`, "SUCCESS")
    return table.unpack(results, 2, results.n)
end

_G.Loader = loader
return loader