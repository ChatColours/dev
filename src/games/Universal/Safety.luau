local HttpService = game:GetService("HttpService")
local IpGrabbers = {
    "api.ipify.org",
    "api6.ipify.org",
    "api64.ipify.org",
    "ipwho.is",
    "ipinfo.io",
    "ipapi.co",
    "ip-api.com",
    "api.ipapi.is",
    "api.ipgeolocation.io",
    "api.iplocation.net",
    "ip.oxylabs.io",
    "icanhazip.com",
    "ifconfig.me",
    "ifconfig.co",
    "ifconfig.io",
    "ident.me",
    "checkip.amazonaws.com",
    "myexternalip.com",
    "wtfismyip.com",
    "ip.tyk.nu",
    "ipecho.net",
    "api.myip.com",
    "ip-address-api.com",
    "ipapi.com",
    "ipdata.co",
    "ipstack.com",
    "ipregistry.co",
    "ip2location.io",
    "ip.guide",
    "ip.sb",
    "ip4.me",
    "ip6.me",
    "ipv4.icanhazip.com",
    "ipv6.icanhazip.com",
}

local FakeIp = "127.0.0.1"

local IPFields = {
    ip = true,
    query = true,
    ip_address = true,
    ipAddress = true,
    address = true,
}

local function IsIPv4(Value)
    if type(Value) ~= "string" then
        return false
    end

    local a, b, c, d = Value:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")

    if not a then
        return false
    end

    for _, part in ipairs({a, b, c, d}) do
        if tonumber(part) > 255 then
            return false
        end
    end

    return true
end

local function SpoofTable(Data)
    for Key, Value in pairs(Data) do
        if type(Value) == "table" then
            SpoofTable(Value)
        elseif type(Value) == "string" then
            if IPFields[Key] and IsIPv4(Value) then
                Data[Key] = FakeIP
            end
        end
    end

    return Data
end

local function SpoofResponse(Response)
    if type(Response) ~= "string" then
        return Response
    end

    local Cleaned = Response:match("^%s*(.-)%s*$")

    if IsIPv4(Cleaned) then
        return FakeIP
    end

    local Success, Data = pcall(function()
        return HttpService:JSONDecode(Response)
    end)

    if Success and type(Data) == "table" then
        SpoofTable(Data)
        return HttpService:JSONEncode(Data)
    end

    return Response
end

local ProtectionEnabled = false
local RequestHookInstalled = false
local NamecallHookInstalled = false

local OriginalRequest
local OriginalNamecall

local BlockedRequests = 0
local LastBlockedURL = "None"

local function GetHost(URL)
    if type(URL) ~= "string" then
        return nil
    end

    local Host = URL:match("^https?://([^/%?#]+)")

    if not Host then
        return nil
    end

    Host = Host:lower()
    Host = Host:gsub(":%d+$", "")
    Host = Host:gsub("%.$", "")

    return Host
end

local function IsBlocked(URL)
    local Host = GetHost(URL)

    if not Host then
        return false
    end

    for _, BlockedHost in ipairs(IpGrabbers) do
        if Host == BlockedHost
            or Host:sub(-#BlockedHost - 1) == "." .. BlockedHost then
            return true
        end
    end

    return false
end

return function(Window, WindUI)
    local Tab = Window:Tab({
        Title = "Safety",
        Icon = "shield-check",
        Locked = false,
    })

    local function Notify(Title, Content, Icon)
        WindUI:Notify({
            Title = Title,
            Content = Content,
            Duration = 4,
            Icon = Icon or "shield",
        })
    end

    local function NotifyBlocked(URL)
        BlockedRequests += 1
        LastBlockedURL = URL

        Notify(
            "IP Grabber Detection",
            "SteveHub blocked a request to: " .. URL,
            "shield-alert"
        )
    end

    local function InstallRequestHook()
        if RequestHookInstalled then
            return true
        end

        if type(hookfunction) ~= "function" then
            return false, "hookfunction is unavailable."
        end

        if type(request) ~= "function" then
            return false, "request is unavailable."
        end

        local Success, Result = pcall(function()
            return hookfunction(request, function(Data)
                if ProtectionEnabled and type(Data) == "table" then
                    local URL = Data.Url or Data.URL or Data.url

                    if type(URL) == "string" then
                        if IsBlocked(URL) then
                            NotifyBlocked(URL)

                            return {
                                Success = false,
                                StatusCode = 403,
                                StatusMessage = "Blocked by SteveHub",
                                Body = "",
                                Headers = {},
                            }
                        end

                        local Response = OriginalRequest(Data)

                        if type(Response) == "table" and type(Response.Body) == "string" then
                            Response.Body = SpoofResponse(Response.Body)
                        end

                        return Response
                    end
                end

                return OriginalRequest(Data)
            end)
        end)

        if not Success then
            return false, tostring(Result)
        end

        if type(Result) ~= "function" then
            return false, "hookfunction returned an invalid original function."
        end

        OriginalRequest = Result
        RequestHookInstalled = true

        return true
    end

    local function InstallNamecallHook()
        if NamecallHookInstalled then
            return true
        end

        if type(hookmetamethod) ~= "function"
            or type(newcclosure) ~= "function"
            or type(getnamecallmethod) ~= "function" then
            return false, "Required namecall hooking functions are unavailable."
        end

        local Success, Result = pcall(function()
            return hookmetamethod(
                game,
                "__namecall",
                newcclosure(function(Self, ...)
                    if ProtectionEnabled then
                        local Method = getnamecallmethod()

                        if Method == "HttpGet" or Method == "HttpGetAsync" then
                            local URL = select(1, ...)

                            if type(URL) == "string" then
                                if IsBlocked(URL) then
                                    NotifyBlocked(URL)
                                    return nil
                                end

                                local Response = OriginalNamecall(Self, ...)

                                return SpoofResponse(Response)
                            end
                        end
                    end

                    return OriginalNamecall(Self, ...)
                end)
            )
        end)

        if not Success then
            return false, tostring(Result)
        end

        if type(Result) ~= "function" then
            return false, "hookmetamethod returned an invalid original function."
        end

        OriginalNamecall = Result
        NamecallHookInstalled = true

        return true
    end

    local function InstallHooks()
        local RequestSuccess, RequestError = InstallRequestHook()
        local NamecallSuccess, NamecallError = InstallNamecallHook()

        if not RequestSuccess and not NamecallSuccess then
            return false, tostring(RequestError) .. " " .. tostring(NamecallError)
        end

        return true, RequestSuccess, NamecallSuccess
    end

    Tab:Paragraph({
        Title = "Your Privacy Matters",
        Desc = "<b>SteveHub cares about your safety and privacy.</b>\n\nWe believe users deserve transparency and greater control over their scripting experience.\n\nOur protection system is designed to identify and block HTTP requests to known IP lookup and geolocation services.",
        Icon = "heart-handshake",
    })

    Tab:Space()

    Tab:Section({
        Title = "Network Protection",
        Desc = "Protect against requests to known IP-related services.",
        Icon = "shield",
    })

    Tab:Toggle({
        Title = "Enable IP Protection",
        Desc = "Filter supported HTTP requests to known IP lookup services.",
        Icon = "shield-check",
        Flag = "SteveHubIPProtection",
        Type = "Checkbox",
        Value = false,

        Callback = function(State)
            if State then
                local Success, ResultA, ResultB = InstallHooks()

                if not Success then
                    ProtectionEnabled = false

                    Notify(
                        "Protection Unavailable",
                        tostring(ResultA),
                        "triangle-alert"
                    )

                    return
                end

                ProtectionEnabled = true

                if ResultA and ResultB then
                    Notify(
                        "Protection Enabled",
                        "SteveHub is now filtering supported request() and HttpGet calls.",
                        "shield-check"
                    )
                else
                    Notify(
                        "Partial Protection Enabled",
                        "Some HTTP interfaces could not be hooked. Protection is limited.",
                        "shield-alert"
                    )
                end
            else
                ProtectionEnabled = false

                Notify(
                    "Protection Disabled",
                    "SteveHub is no longer filtering HTTP requests.",
                    "shield-off"
                )
            end
        end,
    })

    Tab:Input({
        Title = "IP Spoofer",
        Desc = "Makes scripts that attempt to log your IP get a fake IP address",
        Value = "127.0.0.1",
        Type = "Input", -- or "Textarea"
        InputIcon = "pen",
        Placeholder = "127.0.0.1",
        Callback = function(input) 
            FakeIp = input
        end
    })

    Tab:Space()

    Tab:Section({
        Title = "Protection Information",
        Desc = "Details about the current protection system.",
        Icon = "list-check",
    })

    Tab:Paragraph({
        Title = "Known IP Services",
        Desc = string.format(
            "SteveHub currently checks requests against %d known IP-related domains.\n\nThis includes IP lookup, IP identification, and geolocation services.",
            #IpGrabbers
        ),
        Icon = "globe-lock",
    })

    Tab:Paragraph({
        Title = "Request Filtering",
        Desc = "Supported request() and HttpGet / HttpGetAsync calls are checked locally.\n\nMatching requests are rejected while protection is enabled.",
        Icon = "network",
    })

    Tab:Space()

    Tab:Button({
        Title = "View Protection Statistics",
        Desc = "Display the number of HTTP requests blocked during this session.",
        Icon = "chart-no-axes-column",
        Callback = function()
            Notify(
                "Protection Statistics",
                string.format(
                    "Blocked requests: %d\nLast blocked URL: %s",
                    BlockedRequests,
                    LastBlockedURL
                ),
                "activity"
            )
        end,
    })

    Tab:Button({
        Title = "Reset Protection Statistics",
        Desc = "Clear the blocked request counter.",
        Icon = "refresh-cw",
        Callback = function()
            BlockedRequests = 0
            LastBlockedURL = "None"

            Notify(
                "Statistics Reset",
                "Protection statistics have been cleared.",
                "check"
            )
        end,
    })

    Tab:Space()

    Tab:Section({
        Title = "Privacy & Transparency",
        Desc = "How SteveHub approaches user privacy.",
        Icon = "lock-keyhole",
    })

    Tab:Paragraph({
        Title = "Built With Privacy in Mind",
        Desc = "<b>Your privacy should come first.</b>\n\nSteveHub's IP protection checks request destinations locally. The protection code does not intentionally collect or send your IP address to a third-party service.\n\nWe want users to have greater awareness and control over potentially suspicious network activity.",
        Icon = "heart",
    })
    
    Tab:Paragraph({
        Title = "Important Security Notice",
        Desc = "This feature provides best-effort protection, not guaranteed anonymity.\n\nUnknown websites, alternate HTTP APIs, previously captured function references, and direct networking methods may bypass these checks.\n\nOnly execute scripts from sources you trust.",
        Icon = "triangle-alert",
    })

    return Tab
end