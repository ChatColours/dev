local baseUrl = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/games/"
print("v1")
local function Execute(link, Window, WindUI, TabName)
    local Start = tick()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(link))()
    end)
    
    if success then
        local module_success, module_err = pcall(function()
            result(Window, WindUI)
        end)
        if not module_success then
            warn(`Error loading {TabName} -> {module_err}`)
        else
            local Finish = tick() - Start
            print(`Loaded {TabName} module in {Finish} seconds`)
        end
    else
        warn(`Error fetching {TabName} -> {result}`)
    end
end

return function(Window, WindUI, Filename)
    Execute(baseUrl.. Filename, Window, WindUI, Filename)
end
