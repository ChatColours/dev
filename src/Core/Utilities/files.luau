local NecessaryFiles = {
    "fold.MochaHub",
    "fold.MochaHub/assets",
    "fold.MochaHub/Configurations",
    "fold.MochaHub/Plugins",
    "fold.MochaHub/Logs",
    "file.MochaHub/version.json"
}

for _, v in ipairs(NecessaryFiles) do
    local Prefix = v:sub(1, 5)
    local Path = v:sub(6)

    if Prefix == "file." then
        if not isfile(Path) then
            writefile(Path, "")
            print("wrote: ".. Path)
        end
    elseif Prefix == "fold." then
        if not isfolder(Path) then
            makefolder(Path)
        end
    end
end

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