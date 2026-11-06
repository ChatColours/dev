local function C(hex)
    return Color3.fromHex(hex)
end

local flavors = {
    Latte = {
        base="#EFF1F5", mantle="#E6E9EF", crust="#DCE0E8",
        text="#4C4F69", subtext="#6C6F85", overlay="#8C8FA1", surface="#CCD0DA", surface2="#BCC0CC",
        accent="#8839EF", accentAlt="#1E66F5", pink="#EA76CB", green="#40A02B",
        red="#D20F39", yellow="#DF8E1D", white="#FFFFFF", black="#000000",
    },
    Frappe = {
        base="#303446", mantle="#292C3C", crust="#232634",
        text="#C6D0F5", subtext="#A5ADCE", overlay="#737994", surface="#414559", surface2="#51576D",
        accent="#CA9EE6", accentAlt="#8CAAEE", pink="#F4B8E4", green="#A6D189",
        red="#E78284", yellow="#E5C890", white="#FFFFFF", black="#000000",
    },
    Macchiato = {
        base="#24273A", mantle="#1E2030", crust="#181926",
        text="#CAD3F5", subtext="#A5ADCB", overlay="#6E738D", surface="#363A4F", surface2="#494D64",
        accent="#C6A0F6", accentAlt="#8AADF4", pink="#F5BDE6", green="#A6DA95",
        red="#ED8796", yellow="#EED49F", white="#FFFFFF", black="#000000",
    },
    Mocha = {
        base="#1E1E2E", mantle="#181825", crust="#11111B",
        text="#CDD6F4", subtext="#A6ADC8", overlay="#6C7086", surface="#313244", surface2="#45475A",
        accent="#CBA6F7", accentAlt="#89B4FA", pink="#F5C2E7", green="#A6E3A1",
        red="#F38BA8", yellow="#F9E2AF", white="#FFFFFF", black="#000000",
    },
}

local function buildTheme(name, p)
    local theme = {
        Name = "Catppuccin " .. name,

        -- Window, popup, and dialog surfaces
        Background = C(p.base),
        Dialog = C(p.mantle),
        WindowBackground = C(p.base),
        WindowShadow = C(p.black),
        PopupBackground = C(p.mantle),
        DialogBackground = C(p.mantle),
        PanelBackground = C(p.crust),
        PanelBackgroundTransparency = 0.12,

        -- Brand and window chrome
        Accent = C(p.accent),
        Primary = C(p.accent),
        WindowTopbarTitle = C(p.text),
        WindowTopbarAuthor = C(p.subtext),
        WindowTopbarIcon = C(p.accent),
        WindowTopbarButtonIcon = C(p.subtext),
        WindowSearchBarBackground = C(p.mantle),

        -- Text, icons, and borders
        Outline = C(p.surface2),
        Text = C(p.text),
        Placeholder = C(p.subtext),
        Icon = C(p.subtext),
        White = C(p.text),
        Black = C(p.black),
        Tooltip = C(p.crust),
        TooltipText = C(p.text),
        TooltipSecondary = C(p.accent),
        TooltipSecondaryText = C(p.base),

        -- Sidebar tabs and section headers
        TabBackground = C(p.mantle),
        TabBackgroundHover = C(p.surface),
        TabBackgroundHoverTransparency = 0.25,
        TabBackgroundActive = C(p.surface),
        TabBackgroundActiveTransparency = 0.05,
        TabText = C(p.subtext),
        TabTextTransparency = 0,
        TabTextTransparencyActive = 0,
        TabTitle = C(p.text),
        TabIcon = C(p.accentAlt),
        TabIconTransparency = 0.12,
        TabIconTransparencyActive = 0,
        TabBorder = C(p.accent),
        TabBorderTransparency = 0.82,
        TabBorderTransparencyActive = 0.35,
        TabSectionIcon = C(p.accent),

        -- Buttons, inputs, dropdowns, sliders, toggles, and checkboxes
        Button = C(p.surface),
        Hover = C(p.surface2),
        ElementBackground = C(p.mantle),
        ElementBackgroundTransparency = 0,
        ElementBackgroundHover = C(p.surface),
        ElementTitle = C(p.text),
        ElementDesc = C(p.subtext),
        ElementIcon = C(p.accentAlt),
        Toggle = C(p.accent),
        ToggleBar = C(p.surface2),
        Checkbox = C(p.accent),
        CheckboxIcon = C(p.base),
        CheckboxBorder = C(p.overlay),
        CheckboxBorderTransparency = 0.35,
        Slider = C(p.accentAlt),
        SliderIcon = C(p.accentAlt),
        SliderThumb = C(p.text),
        SliderIconFrom = C(p.accentAlt),
        SliderIconTo = C(p.accent),
        ProgressBar = C(p.accent),
        ProgressBarTrack = C(p.surface2),
        ProgressBarTrackTransparency = 0.35,
        ProgressBarText = C(p.text),
        DropdownTabBorder = C(p.surface2),
        DropdownTabBackground = C(p.mantle),
        DropdownBackground = C(p.mantle),

        -- Sections and viewport cards
        SectionIcon = C(p.accent),
        SectionExpandIcon = C(p.subtext),
        SectionExpandIconTransparency = 0.15,
        SectionBox = C(p.surface2),
        SectionBoxTransparency = 0.55,
        SectionBoxBorder = C(p.overlay),
        SectionBoxBorderTransparency = 0.5,
        SectionBoxBackground = C(p.mantle),
        SectionBoxBackgroundTransparency = 0.15,
        ViewportBackground = C(p.crust),
        ViewportBackgroundTransparency = 0,

        -- Search, labels, and notifications
        SearchBarBorder = C(p.surface2),
        SearchBarBorderTransparency = 0.45,
        LabelBackground = C(p.surface),
        LabelBackgroundTransparency = 0.12,
        Notification = C(p.mantle),
        Notification2 = C(p.surface),
        Notification2Transparency = 0.15,
        NotificationTitle = C(p.text),
        NotificationTitleTransparency = 0,
        NotificationContent = C(p.subtext),
        NotificationContentTransparency = 0,
        NotificationDuration = C(p.accent),
        NotificationDurationTransparency = 0,
        NotificationBorder = C(p.surface2),
        NotificationBorderTransparency = 0.35,
    }

    return theme
end

local function Register(WindUI)
    for name, palette in pairs(flavors) do
        WindUI:AddTheme(buildTheme(name, palette))
    end
end

return {
    Flavors = flavors,
    Register = Register,
    Theme = buildTheme,
}