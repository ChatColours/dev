local baseUrl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/TheChosenOne"
local function Execute(link : string, Window, WindUI, TabName)
<<<<<<< HEAD
    local success, result = pcall(function()
        local module, loadError = loadstring(game:HttpGet(link))

        if not module then
            error(loadError)
        end

        return module()
=======
    local success, result = pcall(function() 
        loadstring(game:HttpGet(link))()
>>>>>>> 170a2bec5d1aaf0ed727246c4054c71f5f7950f8
    end)

    if not success then
        warn(`Failed to fetch {TabName} Module -> {result}`)
        return
    end

    if type(result) ~= "function" then
        warn(`Failed to load {TabName} Module -> expected a function, got {type(result)}`)
        return
    end

    local modulesuccess, moduleerr = pcall(function()
        result(Window, WindUI)
    end)

    if modulesuccess then
        print(`Loaded {TabName} Module`)
    else
        warn(`Failed to load {TabName} -> {moduleerr}`)
    end
end

return function(Window, WindUI, TabName)
    Execute(baseUrl.. "/Home.luau", Window, WindUI, TabName)
end
