local HttpService = game:GetService("HttpService")
local IpGrabbers = {
    "api.ipify.org", "api6.ipify.org", "api64.ipify.org", "ipwho.is",
    "ipinfo.io", "ipapi.co", "ip-api.com", "api.ipapi.is",
    "api.ipgeolocation.io", "api.iplocation.net", "ip.oxylabs.io",
    "icanhazip.com", "ifconfig.me", "ifconfig.co", "ifconfig.io",
    "ident.me", "checkip.amazonaws.com", "myexternalip.com",
    "wtfismyip.com", "ip.tyk.nu", "ipecho.net", "api.myip.com",
    "ip-address-api.com", "ipapi.com", "ipdata.co", "ipstack.com",
    "ipregistry.co", "ip2location.io", "ip.guide", "ip.sb",
    "ip4.me", "ip6.me", "ipv4.icanhazip.com", "ipv6.icanhazip.com",
}
local FakeIp = "127.0.0.1"
local ProtectionEnabled = false
local RequestHookInstalled = false
local NamecallHookInstalled = false
local OriginalRequest
local OriginalNamecall
local OriginalIndex
local IndexHookInstalled = false
local GetHwidHookInstalled = false
local OriginalGetHwid
local SpoofedRequests = 0
local RejectedRequests = 0
local LastInterceptedURL = "None"
local Spoofers = {
    HWID = {
        Enabled = false,
        Value = "",
        OgValue = (type(gethwid) == "function" and gethwid() or "Unavailable")
    },
    USERID = {
        Enabled = false,
        Value = 0,
        OgValue = game.Players.LocalPlayer.UserId
    },
    USERNAME = {
        Enabled = false,
        Value = "",
        OgValue = game.Players.LocalPlayer.Name
    }
}
local function IsIPv4(Value)
    if type(Value) ~= "string" then return false end
    local a, b, c, d = Value:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    if not a then return false end
    for _, Part in ipairs({a, b, c, d}) do
        if #Part > 3 or tonumber(Part) > 255 then return false end
    end
    return true
end
local function GetHost(URL)
    if type(URL) ~= "string" then return nil end
    local Host = URL:match("^https?://([^/%?#]+)")
    if not Host then return nil end
    return Host:lower():gsub(":%d+$", ""):gsub("%.$", "")
end
local function IsBlocked(URL)
    local Host = GetHost(URL)
    if not Host then return false end
    for _, BlockedHost in ipairs(IpGrabbers) do
        if Host == BlockedHost or Host:sub(-#BlockedHost - 1) == "." .. BlockedHost then
            return true
        end
    end
    return false
end
local function HostMatches(Host, Domain)
    return Host == Domain or Host:sub(-#Domain - 1) == "." .. Domain
end
local function ToJSON(Data)
    local OK, Result = pcall(HttpService.JSONEncode, HttpService, Data)
    return OK and Result or nil
end
local function SpoofBlockedRequest(URL)
    local Host = GetHost(URL)
    if not Host or not IsIPv4(FakeIp) then return nil end
    local LowerURL = URL:lower()
    if Host == "api6.ipify.org" or Host == "ipv6.icanhazip.com" or Host == "ip6.me" then
        return nil
    end
    if HostMatches(Host, "ipify.org") then
        if LowerURL:find("format=json", 1, true) then
            return ToJSON({ip = FakeIp})
        end
        return FakeIp
    end
    if Host == "ipwho.is" then
        return ToJSON({
            ip = FakeIp, success = true, type = "IPv4", continent = "North America",
            continent_code = "NA", country = "United States", country_code = "US",
            region = "Example Region", city = "Example City", latitude = 0,
            longitude = 0, connection = {isp = "Example ISP", org = "Example Network"},
        })
    end
    if Host == "ipinfo.io" then
        return ToJSON({
            ip = FakeIp, city = "Example City", region = "Example Region",
            country = "US", loc = "0,0", org = "AS64500 Example Network",
            timezone = "Etc/UTC",
        })
    end
    if Host == "ipapi.co" then
        if LowerURL:find("/json", 1, true) then
            return ToJSON({
                ip = FakeIp, city = "Example City", region = "Example Region",
                country = "US", country_name = "United States",
                latitude = 0, longitude = 0, org = "Example Network",
            })
        end
        if LowerURL:match("/ip/?%??") then return FakeIp end
        return nil
    end
    if Host == "ip-api.com" then
        return ToJSON({
            status = "success", query = FakeIp, country = "United States",
            countryCode = "US", regionName = "Example Region", city = "Example City",
            lat = 0, lon = 0, isp = "Example ISP", org = "Example Network",
        })
    end
    if Host == "api.myip.com" then
        return ToJSON({ip = FakeIp, country = "United States", cc = "US"})
    end
    if Host == "ifconfig.co" then
        if LowerURL:find("/json", 1, true) then
            return ToJSON({ip = FakeIp, country = "United States", country_iso = "US"})
        end
        return FakeIp
    end
    if Host == "ip.sb" then
        if LowerURL:find("/geoip", 1, true) then
            return ToJSON({ip = FakeIp, country = "United States", country_code = "US"})
        end
        return FakeIp
    end
    local PlainTextHosts = {
        ["icanhazip.com"] = true, ["ipv4.icanhazip.com"] = true,
        ["ipv6.icanhazip.com"] = true, ["ifconfig.me"] = true,
        ["ifconfig.io"] = true, ["ident.me"] = true,
        ["checkip.amazonaws.com"] = true, ["myexternalip.com"] = true,
        ["wtfismyip.com"] = true, ["ip.tyk.nu"] = true,
        ["ipecho.net"] = true, ["ip4.me"] = true,
    }
    if PlainTextHosts[Host] then
        return FakeIp .. ((Host == "icanhazip.com" or Host == "checkip.amazonaws.com") and "\n" or "")
    end
    return nil
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
    local function Intercept(URL, Spoofed)
        LastInterceptedURL = URL
        if Spoofed then
            SpoofedRequests += 1
        else
            RejectedRequests += 1
        end
        Notify(
            Spoofed and "IP Response Spoofed" or "IP Request Rejected",
            (Spoofed and "Returned fake data for: " or "Blocked unsupported API: ") .. URL,
            Spoofed and "shield-check" or "shield-alert"
        )
    end
    local function InstallRequestHook()
        if RequestHookInstalled then return true end
        if type(hookfunction) ~= "function" or type(request) ~= "function" then
            return false, "request() hooking is unavailable."
        end
        local Success, Result = pcall(function()
            return hookfunction(request, function(Data)
                if ProtectionEnabled and type(Data) == "table" then
                    local URL = Data.Url or Data.URL or Data.url
                    if type(URL) == "string" and IsBlocked(URL) then
                        local Body = SpoofBlockedRequest(URL)
                        Intercept(URL, Body ~= nil)
                        if not Body then return nil end
                        return {
                            Success = true,
                            StatusCode = 200,
                            StatusMessage = "OK",
                            Body = Body,
                            Headers = {
                                ["Content-Type"] = Body:sub(1, 1) == "{"
                                    and "application/json" or "text/plain",
                            },
                        }
                    end
                end
                return OriginalRequest(Data)
            end)
        end)
        if not Success then return false, tostring(Result) end
        if type(Result) ~= "function" then return false, "Invalid original request()." end
        OriginalRequest = Result
        RequestHookInstalled = true
        return true
    end
    local function InstallIndexHook()
        if IndexHookInstalled then return true end
        if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then
            return false, "__index hooking is unavailable."
        end
        local Success, Result = pcall(function()
            return hookmetamethod(game.Players.LocalPlayer, "__index", newcclosure(function(Self, Key)
                if Self == game.Players.LocalPlayer then
                    local Entry
                    if Key == "UserId" then
                        Entry = Spoofers.USERID
                    elseif Key == "Name" then
                        Entry = Spoofers.USERNAME
                    end
                    if Entry and Entry.Enabled then
                        if type(isexecutorthread) == "function" and isexecutorthread() then
                            return Entry.Value
                        end
                        return Entry.OgValue
                    end
                end
                return OriginalIndex(Self, Key)
            end))
        end)
        if not Success then return false, tostring(Result) end
        if type(Result) ~= "function" then return false, "Invalid original __index." end
        OriginalIndex = Result
        IndexHookInstalled = true
        return true
    end
    local function InstallGetHwidHook()
        if GetHwidHookInstalled then return true end
        if type(hookfunction) ~= "function" or type(gethwid) ~= "function"
            or type(newcclosure) ~= "function" then
            return false, "gethwid() hooking is unavailable."
        end
        local Success, Result = pcall(function()
            return hookfunction(gethwid, newcclosure(function(...)
                if Spoofers.HWID.Enabled then
                    return Spoofers.HWID.Value
                end
                return OriginalGetHwid(...)
            end))
        end)
        if not Success then return false, tostring(Result) end
        if type(Result) ~= "function" then return false, "Invalid original gethwid()." end
        OriginalGetHwid = Result
        GetHwidHookInstalled = true
        return true
    end
    local function InstallNamecallHook()
        if NamecallHookInstalled then return true end
        if type(hookmetamethod) ~= "function"
            or type(newcclosure) ~= "function"
            or type(getnamecallmethod) ~= "function" then
            return false, "Namecall hooking is unavailable."
        end
        local Success, Result = pcall(function()
            return hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
                if ProtectionEnabled then
                    local Method = getnamecallmethod()
                    if Method == "HttpGet" or Method == "HttpGetAsync" then
                        local URL = select(1, ...)
                        if type(URL) == "string" and IsBlocked(URL) then
                            local Body = SpoofBlockedRequest(URL)
                            Intercept(URL, Body ~= nil)
                            return Body
                        end
                    end
                end
                return OriginalNamecall(Self, ...)
            end))
        end)
        if not Success then return false, tostring(Result) end
        if type(Result) ~= "function" then return false, "Invalid original namecall." end
        OriginalNamecall = Result
        NamecallHookInstalled = true
        return true
    end
    local function InstallHTTPHooks()
        local RequestOK, RequestError = InstallRequestHook()
        local NamecallOK, NamecallError = InstallNamecallHook()
        if not RequestOK and not NamecallOK then
            return false, tostring(RequestError) .. " " .. tostring(NamecallError)
        end
        return true, RequestOK, NamecallOK
    end
    Tab:Paragraph({
        Title = "Your Privacy Matters",
        Desc = [[

<font size="22" color="#D9B78C"><b>SteveHub Privacy Protection</b></font>

<font color="#E0D5C5">Your privacy matters.</font> This feature attempts to intercept HTTP requests to known IP lookup and geolocation services before they are sent.

<font size="17" color="#C6A47D"><b>How Protection Works</b></font>

<font color="#A6C48A">✓</font> Recognised IP APIs receive a fabricated response.

<font color="#A6C48A">✓</font> Unsupported blocked API formats return nil.

<font color="#A6C48A">✓</font> Matching requests are not forwarded through the intercepted API.

<font color="#A99B8A"><i>Response spoofing does not alter the IP seen by a server if a request is actually sent.</i></font>

]],
        Color = Color3.fromHex("#3B3027"),
        Image = "", ImageSize = 30, Thumbnail = "", ThumbnailSize = 80,
        Locked = false, Buttons = {},
    })
    Tab:Space()
    Tab:Section({
        Title = "Network Protection",
        Desc = "Intercept known IP lookup endpoints.",
        Icon = "shield",
    })
    Tab:Toggle({
        Title = "Enable IP Protection",
        Desc = "Spoof supported IP APIs and reject unsupported matches.",
        Icon = "shield-check",
        Flag = "SteveHubIPProtection",
        Type = "Checkbox",
        Value = false,
        Callback = function(State)
            if State then
                local Success, RequestOK, NamecallOK = InstallHTTPHooks()
                if not Success then
                    ProtectionEnabled = false
                    Notify("Protection Unavailable", tostring(RequestOK), "triangle-alert")
                    return
                end
                ProtectionEnabled = true
                Notify(
                    RequestOK and NamecallOK and "Protection Enabled" or "Partial Protection",
                    RequestOK and NamecallOK
                        and "Filtering supported request() and HttpGet calls."
                        or "One of the supported HTTP interfaces could not be hooked.",
                    "shield-check"
                )
            else
                ProtectionEnabled = false
                Notify("Protection Disabled", "HTTP filtering is disabled.", "shield-off")
            end
        end,
    })
    Tab:Input({
        Title = "Fake IP Address",
        Desc = "IPv4 value returned to supported blocked API requests.",
        Value = FakeIp,
        Type = "Input",
        InputIcon = "pen",
        Placeholder = "127.0.0.1",
        Callback = function(Input)
            if IsIPv4(Input) then
                FakeIp = Input
            else
                Notify("Invalid IPv4", "Enter a valid IPv4 address (0-255 per octet).", "triangle-alert")
            end
        end,
    })
    Tab:Space()
    Tab:Section({
        Title = "Spoofers",
        Desc = "Change your HWID and such so other scripts see something else.",
        Icon = "shield",
    })
    Tab:Paragraph({
        Title = "Identity Spoofing",
        Desc = [[
<font size="20" color="#D9B78C"><b>Identity Controls</b></font>

<font color="#E0D5C5">Modify selected values observed through supported executor hooks.</font>

<font color="#CFC5B8">• Each feature can be enabled separately.
• Hooks are installed at most once per module execution.
• Disabled spoofers pass through the original values.</font>

<font color="#A99B8A"><i>These options do not change your real Roblox account information or hardware identifiers.</i></font>
]],
        Color = Color3.fromHex("#3B3027"),
        Image = "", ImageSize = 30, Thumbnail = "", ThumbnailSize = 80,
        Locked = false, Buttons = {},
    })
    Tab:Input({
        Title = "Fake HWID",
        Desc = "Value returned when gethwid() spoofing is enabled.",
        Type = "Input", InputIcon = "fingerprint",
        Value = Spoofers.HWID.Value,
        Placeholder = "Enter a fake HWID",
        Callback = function(Value)
            Spoofers.HWID.Value = tostring(Value)
        end,
    })
    Tab:Toggle({
        Title = "Spoof HWID",
        Desc = "Return your custom value through the supported gethwid() hook.",
        Icon = "fingerprint", Flag = "SteveHubSpoofHWID",
        Type = "Checkbox", Value = false,
        Callback = function(State)
            if State then
                local OK, Error = InstallGetHwidHook()
                if not OK then
                    Spoofers.HWID.Enabled = false
                    Notify("HWID Hook Unavailable", tostring(Error), "triangle-alert")
                    return
                end
            end
            Spoofers.HWID.Enabled = State
        end,
    })
    Tab:Space()
    Tab:Input({
        Title = "Fake UserId",
        Desc = "Numeric UserId shown to supported executor-thread property reads.",
        Type = "Input", InputIcon = "hash",
        Value = tostring(Spoofers.USERID.Value),
        Placeholder = "123456789",
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number and Number >= 0 and Number % 1 == 0 then
                Spoofers.USERID.Value = Number
            else
                Notify("Invalid UserId", "Use a non-negative whole number.", "triangle-alert")
            end
        end,
    })
    Tab:Toggle({
        Title = "Spoof UserId",
        Desc = "Spoof LocalPlayer.UserId through the shared __index hook.",
        Icon = "user-round", Flag = "SteveHubSpoofUserId",
        Type = "Checkbox", Value = false,
        Callback = function(State)
            if State then
                local OK, Error = InstallIndexHook()
                if not OK then
                    Spoofers.USERID.Enabled = false
                    Notify("UserId Hook Unavailable", tostring(Error), "triangle-alert")
                    return
                end
            end
            Spoofers.USERID.Enabled = State
        end,
    })
    Tab:Space()
    Tab:Input({
        Title = "Fake Username",
        Desc = "Name shown to supported executor-thread property reads.",
        Type = "Input", InputIcon = "pen",
        Value = Spoofers.USERNAME.Value,
        Placeholder = "ExampleUsername",
        Callback = function(Value)
            Spoofers.USERNAME.Value = tostring(Value)
        end,
    })
    Tab:Toggle({
        Title = "Spoof Username",
        Desc = "Spoof LocalPlayer.Name using the same __index hook as UserId.",
        Icon = "user-round", Flag = "SteveHubSpoofUsername",
        Type = "Checkbox", Value = false,
        Callback = function(State)
            if State then
                local OK, Error = InstallIndexHook()
                if not OK then
                    Spoofers.USERNAME.Enabled = false
                    Notify("Username Hook Unavailable", tostring(Error), "triangle-alert")
                    return
                end
            end
            Spoofers.USERNAME.Enabled = State
        end,
    })
    Tab:Space()
    Tab:Section({
        Title = "Protection Information",
        Desc = "About detection and response handling.",
        Icon = "list-check",
    })
    Tab:Paragraph({
        Title = "Known IP Services",
        Desc = string.format([[

<font size="20" color="#D9B78C"><b>Monitored Endpoints</b></font>

<font color="#E0D5C5">SteveHub currently checks against <b>%d known domains</b>.</font>

<font size="17" color="#C6A47D"><b>Examples</b></font>

<font color="#CFC5B8">• ipify.org and its API subdomains

• ipwho.is

• ipinfo.io

• ip-api.com

• ifconfig.me and icanhazip.com</font>

<font color="#A99B8A"><i>Not every monitored endpoint has a supported spoofed response format.</i></font>

]], #IpGrabbers),
        Color = Color3.fromHex("#3B3027"),
        Image = "", ImageSize = 30, Thumbnail = "", ThumbnailSize = 80,
        Locked = false, Buttons = {},
    })
    Tab:Paragraph({
        Title = "Request Handling",
        Desc = [[

<font size="20" color="#D9B78C"><b>Response Handling</b></font>

<font color="#CFC5B8">• <b>Recognised service:</b> return fake IP data without contacting it.

• <b>Unknown response format:</b> return nil without contacting it.

• <b>Unmatched domain:</b> allow the request normally.</font>

<font color="#A99B8A"><i>Only supported request() and game:HttpGet / HttpGetAsync paths are intercepted.</i></font>

]],
        Color = Color3.fromHex("#3B3027"),
        Image = "", ImageSize = 30, Thumbnail = "", ThumbnailSize = 80,
        Locked = false, Buttons = {},
    })
    Tab:Space()
    Tab:Button({
        Title = "View Protection Statistics",
        Desc = "View spoofed and rejected requests from this session.",
        Icon = "chart-no-axes-column",
        Callback = function()
            Notify("Protection Statistics", string.format(
                "Spoofed: %d | Rejected: %d\nLast intercepted URL: %s",
                SpoofedRequests, RejectedRequests, LastInterceptedURL
            ), "activity")
        end,
    })
    Tab:Button({
        Title = "Reset Protection Statistics",
        Desc = "Clear the intercepted request counters.",
        Icon = "refresh-cw",
        Callback = function()
            SpoofedRequests = 0
            RejectedRequests = 0
            LastInterceptedURL = "None"
            Notify("Statistics Reset", "Protection statistics have been cleared.", "check")
        end,
    })
    Tab:Space()
    Tab:Section({
        Title = "Privacy & Transparency",
        Desc = "Important limitations of this feature.",
        Icon = "lock-keyhole",
    })
    Tab:Paragraph({
        Title = "Privacy & Security Notice",
        Desc = [[

<font size="20" color="#D9B78C"><b>Know the Limitations</b></font>

<font color="#E0D5C5">SteveHub provides <b>best-effort filtering</b>, not guaranteed anonymity.</font>

<font size="17" color="#C6A47D"><b>Important Information</b></font>

<font color="#CFC5B8">• Any outside server you contact may log the source IP of that connection.

• Unknown domains can collect IP addresses without using a lookup API.

• Other HTTP functions, saved references, and native networking can bypass these hooks.

• Returning nil may cause some scripts expecting a response to error.</font>

<font color="#A99B8A"><i>Use trusted code, and treat this protection as an additional precaution rather than a guarantee.</i></font>

]],
        Color = Color3.fromHex("#3B3027"),
        Image = "", ImageSize = 30, Thumbnail = "", ThumbnailSize = 80,
        Locked = false, Buttons = {},
    })
    return Tab
end
