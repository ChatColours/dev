local baseUrl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/TheChosenOne"
local function Execute(link : string, Window, WindUI, TabName)
    local success, result = pcall(function()
        loadstring(game:HttpGet(link))()
    end)

    if success and type(result) == "function" then
        local modulesuccess, moduleerr = pcall(function()
            result(Window, WindUI)
        end)

        if modulesuccess then
            print(`Loaded {TabName} Module`)
        else
            warn(`Failed to load {TabName} -> {moduleerr}`)
        end
    end
end

return function(Window, WindUI, TabName)
    Execute(baseUrl.. "/Home.luau", Window, WindUI, TabName)
end