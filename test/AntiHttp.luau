local ogRest
ogRest = hookfunction(restorefunction, function(...)
    local args = {...}
    if args[1] == hookfunction or args[1] == restorefunction then
        return nil
    end

    return ogRest(...)
end)
local ogHook
ogHook = hookfunction(hookfunction, function(...)
    local args = {...}

    if args[1] == hookfunction or args[1] == restorefunction then
        return nil
    end

    return ogHook(...)
end)

local req
req = hookfunction(request, function(...)
    local args = {...}
    if args[1] ~= "key" then
        return nil
    end

    table.remove(args, 1)
    req(args)
end)