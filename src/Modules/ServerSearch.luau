local API = "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"
local HttpService = game:GetService("HttpService")
local Servers = {}
function Servers.FetchServers(MaxServers)
    local Servers = {}
    local Cursor = nil
    local SeenCursors = {}

    repeat
        local URL = API:format(game.PlaceId)

        if Cursor then
            URL ..= "&cursor=" .. HttpService:UrlEncode(Cursor)
        end

        local Success, Result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(URL))
        end)

        if not Success then
            warn("Failed to fetch servers:", Result)
            break
        end

        for _, Server in ipairs(Result.data or {}) do
            table.insert(Servers, Server)

            if MaxServers and #Servers >= MaxServers then
                return Servers
            end
        end

        Cursor = Result.nextPageCursor

        if Cursor then
            if SeenCursors[Cursor] then
                break
            end

            SeenCursors[Cursor] = true
        end

        if Cursor then
            task.wait(0.25)
        end
    until not Cursor

    return Servers
end

return Servers