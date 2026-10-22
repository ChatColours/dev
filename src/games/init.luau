local Owner = "ChatColours"
local Repo = "dev"
local Branch = "main"
local Folder = "src/games"

local baseUrl = `https://raw.githubusercontent.com/{Owner}/{Repo}/{Branch}/{Folder}/`
local apiUrl = `https://api.github.com/repos/{Owner}/{Repo}/git/trees/{Branch}?recursive=1`

local http = game:GetService("HttpService")

print("v1")

local function ListScripts(target)
    local success, result = pcall(function()
        return http:JSONDecode(game:HttpGet(apiUrl))
    end)

    if not success then
        warn(`Failed to list scripts: {result}`)
        return {}
    end

    if result.truncated then
        warn("GitHub returned a truncated file tree")
    end

    local scripts = {}
    local prefix = Folder .. "/"

    for _, file in ipairs(result.tree or {}) do
        if file.type ~= "blob" then
            continue
        end

        if file.path:sub(1, #prefix) ~= prefix then
            continue
        end

        local relativePath = file.path:sub(#prefix + 1)

        if relativePath:match("%.luau?$") then
            local name = relativePath:match("([^/]+)%.luau?$")

            if not target or name == target then
                table.insert(scripts, {
                    Name = name,
                    Path = relativePath,
                    URL = baseUrl .. relativePath
                })
                 print("REACHED END -> GOT SCRIPTS")
            end
        end
    end

    table.sort(scripts, function(a, b)
        return a.Path < b.Path
    end)

    return scripts
end

local function Execute(link, Window, WindUI, TabName)
    local Start = os.clock()

    local success, result = pcall(function()
        return loadstring(game:HttpGet(link))()
    end)

    if not success then
        warn(`Error fetching {TabName} -> {result}`)
        return false
    end

    if type(result) ~= "function" then
        warn(`Invalid module {TabName}: expected function, got {type(result)}`)
        return false
    end

    local module_success, module_err = pcall(function()
        result(Window, WindUI)
    end)

    if not module_success then
        warn(`Error loading {TabName} -> {module_err}`)
        return false
    end

    print(`Loaded {TabName} module in {os.clock() - Start} seconds`)
    return true
end

return function(Window, WindUI, Tabs)
    local scripts = ListScripts()

    local selected = nil

    if Tabs then
        selected = {}

        for _, name in ipairs(Tabs) do
            selected[name] = true
        end
    end

    for _, scriptInfo in ipairs(scripts) do
        if not selected or selected[scriptInfo.Name] or selected[scriptInfo.Path] then
            Execute(scriptInfo.URL, Window, WindUI, scriptInfo.Name)
        end
    end
end