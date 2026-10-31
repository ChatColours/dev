local module = {}

function module.ListPlugins()
    return listfiles("Steve/Plugins")
end

function module.LoadPlugin(Path, Window, WindUI)
    local Success, Result, Error = pcall(function()
        return loadfile(Path)
    end)

    if Success and Result then
        Result(Window, WindUI)
        return Result
    else
        return nil, tostring(Success and Error or Result)
    end
end

return module