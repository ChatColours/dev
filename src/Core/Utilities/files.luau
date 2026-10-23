local NecessaryFiles = {
    "fold.Steve",
    "fold.Steve/assets",
    "file.Steve/config.json",
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

return function FetchAsset(FileName, Link)
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
end