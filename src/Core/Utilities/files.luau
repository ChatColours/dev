local NecessaryFiles = {
    "fold.Steve",
    "fold.Steve/assets",
    "fold.Steve/Configurations",
    "fold.Steve/Plugins"
}

for _, v in ipairs(NecessaryFiles) do
    local Prefix = v:sub(1, 5)
    local Path = v:sub(6)

    if Prefix == "file." then
        if not isfile(Path) then
            writefile(Path, "")
        end
    elseif Prefix == "fold." then
        if not isfolder(Path) then
            makefolder(Path)
        end
    end
end
--[[
local FileFuncts = {}

function FileFuncts.Write(path : string, data : string)
    if not data then
        data = "nil"
    end

    writefile(path, data)
end
function FileFuncts.Read(path : string): string?
    if isfile(path) then
        return readfile(path), true
    else
        return "", false
    end
end]]

return function(FileName, Link)
    if isfile("Steve/assets/".. FileName) then
        return getcustomasset("Steve/assets/".. FileName)
    else
        local success, result = pcall(function()
            return game:HttpGet(Link)
        end)
        if success then
            writefile("Steve/assets/".. FileName, result)
            return getcustomasset("Steve/assets/".. FileName)
        end
    end
    return nil
end --, FileFuncts