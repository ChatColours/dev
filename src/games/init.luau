local baseUrl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/"

local function Execute(path, Window, WindUI, RequiredTab)
    local start = os.clock()
    local url = baseUrl .. path

    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not success then
        warn(`Error fetching {path} -> {result}`)
        return nil
    end

    if type(result) ~= "function" then
        warn(`Invalid module {path} -> Expected function, got {type(result)}`)
        return nil
    end

    local moduleSuccess, tab = pcall(function()
        return result(Window, WindUI, RequiredTab)
    end)

    if not moduleSuccess then
        warn(`Error loading {path} -> {tab}`)
        return nil
    end

    print(`Loaded {path} in {os.clock() - start} seconds`)

    return tab
end

return function(Window, WindUI, Filename, RequiredTab)
    return Execute(Filename, Window, WindUI, RequiredTab)
end