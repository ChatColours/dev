local NecessaryFiles = {
    "fold.Steve",
    "fold.Steve/assets",
    "fold.Steve/Configurations",
}

for _, v in NecessaryFiles do
    if v:sub(1, 6) == "file." then
        if not isfile(v:sub(6)) then
            writefile(v:sub(6), "")
        end
    elseif v:sub(1, 6) == "fold." then
        if not isfolder(v:sub(6)) then
            makefolder(v:sub(6))
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