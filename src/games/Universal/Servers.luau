local Loader = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/src/Core/loader.luau"
))()

local ServerModule = Loader.Require("src/Modules/ServerSearch.luau")

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

local MAX_SERVERS = 50

local Browser = {
    Servers = {},
    Paragraphs = {},
    Refreshing = false,
    FriendsAvailable = false,
    FriendsByServer = {},
}

-- Utilities

local function Notify(WindUI, title, message)
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = title,
            Content = tostring(message),
            Duration = 4,
        })
    else
        print("[SteveHub]", title, message)
    end
end

local function GetPingColor(ping)
    if type(ping) ~= "number" then
        return "#A99B8A"
    end

    if ping < 80 then
        return "#A6C48A"
    elseif ping < 150 then
        return "#E8C47C"
    else
        return "#E28B82"
    end
end

local function FormatPing(ping)
    if type(ping) ~= "number" then
        return "Unknown"
    end

    return string.format("%.0f ms", ping)
end

local function FormatJobId(jobId)
    return tostring(jobId or "Unknown")
end

local function GetFriendsByServer()
    local friendsByServer = {}

    local success, result = pcall(function()
        return Player:GetFriendsOnlineAsync(200)
    end)

    if not success or type(result) ~= "table" then
        warn("[SteveHub] Failed to fetch online friends:", result)
        return friendsByServer, false
    end

    for _, friend in ipairs(result) do
        local jobId = friend.GameId

        if friend.PlaceId == PlaceId
            and type(jobId) == "string"
            and jobId ~= "" then

            friendsByServer[jobId] = friendsByServer[jobId] or {}

            table.insert(
                friendsByServer[jobId],
                friend.DisplayName or friend.UserName or "Unknown"
            )
        end
    end

    return friendsByServer, true
end

local function DecodeServers(result)
    if type(result) == "string" then
        result = HttpService:JSONDecode(result)
    end

    if type(result) ~= "table" then
        error("Invalid server response")
    end

    local data = result.data or result.Data or result

    if type(data) ~= "table" then
        error("Server response contains no valid data")
    end

    return data
end

local function FetchServers()
    local result = ServerModule.FetchServers(MAX_SERVERS)
    local data = DecodeServers(result)

    local servers = {}
    local seen = {}

    for _, server in pairs(data) do
        if type(server) ~= "table" then
            continue
        end

        local jobId = server.id or server.Id

        if type(jobId) ~= "string"
            or jobId == ""
            or seen[jobId] then
            continue
        end

        seen[jobId] = true

        table.insert(servers, {
            Id = jobId,
            Playing = tonumber(server.playing or server.Playing) or 0,
            MaxPlayers = tonumber(server.maxPlayers or server.MaxPlayers) or 0,
            Ping = tonumber(server.ping or server.Ping),
            FPS = tonumber(server.fps or server.FPS),
        })
    end

    return servers
end

local function JoinServer(jobId, WindUI)
    if type(jobId) ~= "string" or jobId == "" then
        return
    end

    if jobId == game.JobId then
        Notify(WindUI, "Already Here", "You're already in this server.")
        return
    end

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(
            PlaceId,
            jobId,
            Player
        )
    end)

    if not success then
        Notify(WindUI, "Teleport Failed", err)
    end
end

local function RejoinServer(WindUI)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(
            PlaceId,
            game.JobId,
            Player
        )
    end)

    if not success then
        Notify(WindUI, "Rejoin Failed", err)
    end
end

local function ClearParagraphs()
    for _, paragraph in ipairs(Browser.Paragraphs) do
        pcall(function()
            paragraph:Destroy()
        end)
    end

    table.clear(Browser.Paragraphs)
end

local function GetFriendCount(jobId)
    if not Browser.FriendsAvailable then
        return nil
    end

    return #(Browser.FriendsByServer[jobId] or {})
end

local function SortServers(servers)
    table.sort(servers, function(a, b)
        local friendsA = GetFriendCount(a.Id) or 0
        local friendsB = GetFriendCount(b.Id) or 0

        if friendsA ~= friendsB then
            return friendsA > friendsB
        end

        local availableA = a.MaxPlayers == 0 or a.Playing < a.MaxPlayers
        local availableB = b.MaxPlayers == 0 or b.Playing < b.MaxPlayers

        if availableA ~= availableB then
            return availableA
        end

        local pingA = a.Ping or math.huge
        local pingB = b.Ping or math.huge

        if pingA ~= pingB then
            return pingA < pingB
        end

        return a.Id < b.Id
    end)
end

local function BuildDescription(server)
    local friends = Browser.FriendsByServer[server.Id] or {}
    local friendCount = GetFriendCount(server.Id)

    local friendText

    if friendCount == nil then
        friendText = "Unavailable"
    else
        friendText = tostring(friendCount)
    end

    local playersText = string.format(
        "%d / %d",
        server.Playing,
        server.MaxPlayers
    )

    local pingText = FormatPing(server.Ping)
    local pingColor = GetPingColor(server.Ping)

    local status

    if server.Id == game.JobId then
        status = '<font color="#A6C48A">Current Server</font>'
    elseif server.MaxPlayers > 0
        and server.Playing >= server.MaxPlayers then
        status = '<font color="#E28B82">Full</font>'
    else
        status = '<font color="#A6C48A">Joinable</font>'
    end

    local description = string.format([[
<font color="#CFC5B8"><b>Players:</b></font> %s
<font color="#CFC5B8"><b>Ping:</b></font> <font color="%s">%s</font>
<font color="#CFC5B8"><b>Friends Playing:</b></font> %s
<font color="#CFC5B8"><b>Status:</b></font> %s

<font color="#A99B8A"><b>Job ID</b></font>
<font color="#A99B8A">%s</font>
]],
        playersText,
        pingColor,
        pingText,
        friendText,
        status,
        FormatJobId(server.Id)
    )

    if #friends > 0 then
        local names = table.concat(friends, ", ")

        names = names:gsub("&", "&amp;")
        names = names:gsub("<", "&lt;")
        names = names:gsub(">", "&gt;")

        description ..= string.format(
            '\n<font color="#A6C48A"><b>Friends:</b> %s</font>',
            names
        )
    end

    return description
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Servers",
        Icon = "server",
        Locked = false,
    })

    Tab:Paragraph({
        Title = "Server Browser",
        Desc = [[
<font color="#D9B78C"><b>SteveHub Server Browser</b></font>

<font color="#CFC5B8">Browse available public servers, compare player counts and latency, find servers containing friends, and quickly join another server.</font>

<font color="#A99B8A"><i>Server data is provided by Roblox and may change between refreshes.</i></font>
]],
        Locked = false,
    })

    local StatusParagraph = Tab:Paragraph({
        Title = "Server Status",
        Desc = "Loading server browser...",
        Locked = false,
    })

    local function UpdateStatus()
        local totalPlayers = 0
        local available = 0
        local friendsFound = 0

        for _, server in ipairs(Browser.Servers) do
            totalPlayers += server.Playing

            if server.MaxPlayers == 0
                or server.Playing < server.MaxPlayers then
                available += 1
            end

            friendsFound += GetFriendCount(server.Id) or 0
        end

        local friendText = Browser.FriendsAvailable
            and tostring(friendsFound)
            or "Unavailable"

        StatusParagraph:SetDesc(string.format([[
<font color="#D9B78C"><b>Servers Found:</b></font> %d
<font color="#CFC5B8"><b>Available Servers:</b></font> %d
<font color="#CFC5B8"><b>Players in Listed Servers:</b></font> %d
<font color="#CFC5B8"><b>Friends in Listed Servers:</b></font> %s

<font color="#A99B8A"><i>Sorted by friends playing, availability, then lowest ping.</i></font>
]],
            #Browser.Servers,
            available,
            totalPlayers,
            friendText
        ))
    end

    Tab:Section({
        Title = "Server Actions",
    })

    local RefreshServers

    Tab:Button({
        Title = "Refresh Server List",
        Desc = "Fetch the latest available public servers",
        Icon = "refresh-cw",

        Callback = function()
            RefreshServers()
        end,
    })

    Tab:Button({
        Title = "Rejoin Server",
        Desc = "Attempt to reconnect to your current server",
        Icon = "rotate-ccw",

        Callback = function()
            RejoinServer(WindUI)
        end,
    })

    Tab:Section({
        Title = "Available Servers",
    })

    local function CreateServerParagraph(server, index)
        local isCurrent = server.Id == game.JobId
        local isFull = server.MaxPlayers > 0
            and server.Playing >= server.MaxPlayers

        local title = string.format(
            "Server #%d | %d/%d Players",
            index,
            server.Playing,
            server.MaxPlayers
        )

        if isCurrent then
            title ..= " (You)"
        end

        local paragraph = Tab:Paragraph({
            Title = title,
            Desc = BuildDescription(server),
            Locked = false,

            Buttons = {
                {
                    Title = "Join Server",
                    Icon = "log-in",

                    Callback = function()
                        if isCurrent then
                            Notify(
                                WindUI,
                                "Current Server",
                                "You're already in this server."
                            )
                            return
                        end

                        if isFull then
                            Notify(
                                WindUI,
                                "Server Full",
                                "This server currently has no free slots."
                            )
                            return
                        end

                        JoinServer(server.Id, WindUI)
                    end,
                },

                {
                    Title = "Copy Job ID",
                    Icon = "copy",

                    Callback = function()
                        if type(setclipboard) == "function" then
                            setclipboard(server.Id)

                            Notify(
                                WindUI,
                                "Copied",
                                "Server Job ID copied."
                            )
                        else
                            Notify(
                                WindUI,
                                "Unavailable",
                                "Clipboard function isn't supported."
                            )
                        end
                    end,
                }
            }
        })

        table.insert(Browser.Paragraphs, paragraph)
    end

    RefreshServers = function()
        if Browser.Refreshing then
            return
        end

        Browser.Refreshing = true

        StatusParagraph:SetDesc(
            '<font color="#D9B78C">Refreshing servers and friends...</font>'
        )

        task.spawn(function()
            local success, serversOrError = pcall(FetchServers)

            if not success then
                Browser.Refreshing = false

                StatusParagraph:SetDesc(
                    '<font color="#E28B82"><b>Failed to fetch servers.</b></font>'
                )

                Notify(
                    WindUI,
                    "Server Browser",
                    serversOrError
                )

                return
            end

            local friendsByServer, friendsAvailable = GetFriendsByServer()

            Browser.Servers = serversOrError
            Browser.FriendsByServer = friendsByServer
            Browser.FriendsAvailable = friendsAvailable

            SortServers(Browser.Servers)
            ClearParagraphs()
            UpdateStatus()

            if #Browser.Servers == 0 then
                local emptyParagraph = Tab:Paragraph({
                    Title = "No Servers Found",
                    Desc = "No public servers were returned. Try refreshing.",
                })

                table.insert(Browser.Paragraphs, emptyParagraph)
            else
                for index, server in ipairs(Browser.Servers) do
                    CreateServerParagraph(server, index)

                    if index % 10 == 0 then
                        task.wait()
                    end
                end
            end

            Browser.Refreshing = false

            Notify(
                WindUI,
                "Server Browser",
                string.format(
                    "Loaded %d public servers.",
                    #Browser.Servers
                )
            )
        end)
    end

    RefreshServers()
end