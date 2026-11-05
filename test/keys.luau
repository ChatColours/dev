
local License = ""
local LicenseStatus = "Inactive"
local LicenseProvider = "Steve Hub"

-- Configuration
local LicenseURL = "" -- Your license acquisition URL
local SupportURL = "" -- Your Discord support URL

local function Notify(Title, Content, Icon)
    WindUI:Notify({
        Title = Title,
        Content = Content,
        Icon = Icon or "info",
        Duration = 4,
    })
end

local function CopyLink(URL, Name)
    if URL == "" then
        Notify("Unavailable", Name .. " URL is not configured.", "triangle-alert")
        return
    end

    if not setclipboard then
        Notify("Unavailable", "Clipboard access is not supported.", "triangle-alert")
        return
    end

    setclipboard(URL)
    Notify("Copied", Name .. " link copied to clipboard.", "check")
end

-- ==========================================
-- OVERVIEW
-- ==========================================

local OverviewTab = KeyWindow:Tab({
    Title = "Overview",
    Icon = "house",
    Locked = false,
})

OverviewTab:Paragraph({
    Title = "Welcome to Steve Hub",
    Desc = "Your personal license management dashboard.\n\nManage your license, access your account information, and get assistance from one place.",
    Icon = "shield-check",
})

local OverviewStatus = OverviewTab:Paragraph({
    Title = "License Overview",
    Desc = "Status: Inactive\nProvider: Steve Hub\n\nYour license has not been activated.",
    Icon = "circle-alert",
})

OverviewTab:Space()

OverviewTab:Paragraph({
    Title = "Getting Started",
    Desc = "1. Obtain a license from an authorized provider.\n2. Navigate to the Activation tab.\n3. Enter your license code.\n4. Activate your license to continue.",
    Icon = "list-checks",
})

OverviewTab:Paragraph({
    Title = "Secure Licensing",
    Desc = "Steve Hub uses license verification to manage access and help protect your account.",
    Icon = "lock-keyhole",
})

-- ==========================================
-- ACTIVATION
-- ==========================================

local Tab = KeyWindow:Tab({
    Title = "Activation",
    Icon = "key-round",
    Locked = false,
})

Tab:Paragraph({
    Title = "Activate Your License",
    Desc = "Enter your Steve Hub license below to verify your access.",
    Icon = "shield-check",
})

local ActivationStatus = Tab:Paragraph({
    Title = "Activation Status",
    Desc = "Status: Waiting for license\n\nEnter your license to begin.",
    Icon = "circle-dot",
})

Tab:Space()

local Input = Tab:Input({
    Title = "License Code",
    Desc = "Enter the license associated with your account.",
    Value = "",
    InputIcon = "key-round",
    Type = "Input",
    Placeholder = "Enter your license...",
    Callback = function(input)
        License = input
    end,
})

local function UpdateLicenseStatus(Status, Description)
    LicenseStatus = Status

    ActivationStatus:SetDesc(
        "Status: " .. Status .. "\n\n" .. Description
    )

    OverviewStatus:SetDesc(
        "Status: " .. Status ..
        "\nProvider: " .. LicenseProvider ..
        "\n\n" .. Description
    )
end

Tab:Button({
    Title = "Activate License",
    Desc = "Verify your license and unlock access.",
    Icon = "shield-check",
    Callback = function()
        if License == "" or not License:match("%S") then
            Notify(
                "License Required",
                "Please enter a license code.",
                "triangle-alert"
            )
            return
        end

        UpdateLicenseStatus(
            "Verifying",
            "Your license is being verified."
        )

        -- Connect your license verification API here.
        -- Only set Active after the API confirms success.

        Notify(
            "Verification Pending",
            "Connect your license API to complete activation.",
            "info"
        )
    end,
})

Tab:Button({
    Title = "Clear License",
    Desc = "Clear the currently entered license.",
    Icon = "eraser",
    Callback = function()
        License = ""
        Input:Set("")
        UpdateLicenseStatus(
            "Inactive",
            "No license is currently activated."
        )
    end,
})

-- ==========================================
-- GET LICENSE
-- ==========================================

local GetLicenseTab = KeyWindow:Tab({
    Title = "Get License",
    Icon = "shopping-bag",
    Locked = false,
})

GetLicenseTab:Paragraph({
    Title = "Obtain a License",
    Desc = "Don't have a Steve Hub license yet?\n\nChoose an available provider below to obtain your license.",
    Icon = "key-round",
})

GetLicenseTab:Space()

GetLicenseTab:Button({
    Title = "Get License",
    Desc = "Copy the official license acquisition link.",
    Icon = "external-link",
    Callback = function()
        CopyLink(LicenseURL, "License")
    end,
})

GetLicenseTab:Space()

GetLicenseTab:Paragraph({
    Title = "Already Have a License?",
    Desc = "Head over to the Activation tab and enter your existing license code. You do not need to obtain another license if yours is still valid.",
    Icon = "badge-check",
})

-- ==========================================
-- ACCOUNT
-- ==========================================

local AccountTab = KeyWindow:Tab({
    Title = "Account",
    Icon = "user-round",
    Locked = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

AccountTab:Paragraph({
    Title = "Roblox Account",
    Desc = "Username: @" .. LocalPlayer.Name ..
        "\nDisplay Name: " .. LocalPlayer.DisplayName ..
        "\nUser ID: " .. tostring(LocalPlayer.UserId),
    Icon = "user-round",
})

AccountTab:Button({
    Title = "Copy User ID",
    Desc = "Copy your Roblox account's User ID.",
    Icon = "copy",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(LocalPlayer.UserId))
            Notify("Copied", "Roblox User ID copied.", "check")
        end
    end,
})

AccountTab:Space()

AccountTab:Paragraph({
    Title = "Device Information",
    Desc = "Your hardware identifier may be used to associate a license with your device.",
    Icon = "monitor",
})

AccountTab:Button({
    Title = "Copy HWID",
    Desc = "Copy your device's hardware identifier.",
    Icon = "copy",
    Callback = function()
        if type(gethwid) ~= "function" then
            Notify(
                "Unavailable",
                "Your environment does not support HWID retrieval.",
                "triangle-alert"
            )
            return
        end

        local Success, HWID = pcall(gethwid)

        if Success and HWID and setclipboard then
            setclipboard(tostring(HWID))
            Notify("Copied", "HWID copied to clipboard.", "check")
        else
            Notify("Error", "Could not retrieve your HWID.", "triangle-alert")
        end
    end,
})

AccountTab:Space()

local AccountLicense = AccountTab:Paragraph({
    Title = "License Information",
    Desc = "License Status: Inactive\nProvider: Steve Hub",
    Icon = "id-card",
})

-- ==========================================
-- SUPPORT
-- ==========================================

local SupportTab = KeyWindow:Tab({
    Title = "Support",
    Icon = "life-buoy",
    Locked = false,
})

SupportTab:Paragraph({
    Title = "Need Assistance?",
    Desc = "Having trouble activating your license? Our support team can help with invalid licenses, account linking, and device-related issues.",
    Icon = "message-circle-question",
})

SupportTab:Button({
    Title = "Contact Support",
    Desc = "Copy the official Steve Hub support link.",
    Icon = "external-link",
    Callback = function()
        CopyLink(SupportURL, "Support")
    end,
})

SupportTab:Space()

SupportTab:Paragraph({
    Title = "Common Activation Issues",
    Desc = "Invalid License\nDouble-check your license for typing mistakes.\n\nExpired License\nYour license may have reached its expiration date.\n\nDevice Mismatch\nYour license may already be linked to another device.\n\nRevoked License\nYour license may have been disabled by staff.",
    Icon = "triangle-alert",
})

SupportTab:Paragraph({
    Title = "License Guidelines",
    Desc = "• Keep your license private.\n• Do not share licenses with other users.\n• Contact support before changing devices if your license is HWID-bound.\n• Only obtain licenses from authorized providers.",
    Icon = "shield",
})
