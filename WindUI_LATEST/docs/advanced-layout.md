# Layout and card elements

The new options are optional. Existing windows and elements keep their current layout.

## Window branding

```luau
local Window = WindUI:CreateWindow({
    Title = "Ender Hub",
    Author = "By Qilex",
    Icon = "sparkles",
    IconClipsDescendants = false, -- true clips artwork to the window icon frame
    Theme = "Dark",
    Position = UDim2.fromScale(0.5, 0.5),
    Padding = 14,
    Gap = 6,
    ElementPadding = 12,
    TabGap = 6,
    ContentPadding = 16,
    Topbar = {
        Height = 48,
        ButtonsType = "Mac",
        TagDirection = "RightToLeft", -- or "LeftToRight"
        TagsGap = 6,
        Tags = {
            { Title = "Live", Icon = "activity", Color = "Primary" },
            { Title = "Beta", Color = Color3.fromRGB(100, 80, 180) },
        },
    },
    Branding = {
        Placement = "Sidebar", -- or omit for the top bar
        IconClipsDescendants = false, -- optional override for sidebar branding
        IconPosition = "Left", -- Left, Right, Top, Bottom
        TextAlign = "Left",    -- Left, Center, Right
        Align = "Left",
        Height = 64,
        Gap = 8,
        Padding = 14,
    },
})
```

Individual tabs also accept `IconClipsDescendants = true` when a tab icon should be clipped. `Window:SelectTab(tab)` accepts either the tab object or its numeric index; only the active tab receives the selected background.


`Window:Tag({ Title = "New", Color = "Primary" })` adds another topbar tag later. `Window:SetTagDirection("LeftToRight")` changes the direction of all existing topbar tags. Use `TagsPosition = "Topbar"` on an element to place its tags in the window topbar. Set `ConnectedElements = true` on the window only when you want adjacent elements to share square edges; separate rounded cards are the default.

## Element text, images, and tags

Elements that use the standard element card accept these options:

```luau
Tab:Paragraph({
    Title = "Status",
    Desc = "Everything is running",
    Image = "circle-check",
    ImagePosition = "Right", -- Left, Right, Top, Bottom
    TitleAlign = "Left",
    DescAlign = "Left",
    TagsPosition = "Topbar", -- Topbar, AboveTitle, BelowTitle, BelowDescription, Left, Right
    TagsAlign = "Left",          -- Left, Center, Right
    TagsGap = 6,
    TagsWidth = 100,            -- width when tags are on the left or right
    Tags = {
        {
            Title = "Live",
            Icon = "activity",
            Color = "Primary", -- theme key, Color3, or UIGradient property table
            IconPosition = "Left",
            Order = 1,
            Height = 22,
            Padding = 8,
            TextSize = 12,
            Border = true,
        },
    },
})
```

You can also set tag `IconSize`, `Radius`, `BackgroundTransparency`, `TextColor`, `IconColor`, `BorderColor`, `BorderThickness`, and `BorderTransparency`.

## Themed group cards

```luau
local Server = Tab:Group({
    Title = "Server",
    Desc = "Information about this session",
    Icon = "server",
    Padding = 12,
    Gap = 8,
    Radius = 16,
    Border = true,
    Layout = "Vertical", -- Horizontal for a row
})
Server:Stat({ Title = "Players", Value = "8", Desc = "Playing now" })
Server:Stat({ Title = "Latency", Value = "174 ms" })
Server:Callout({
    Title = "Wave",
    Desc = "Your executor supports this script.",
    Icon = "sparkles",
})
```

To place two complete group cards on the same row, create them inside an `HStack`. Each card takes half the available width and keeps its own natural height:

```luau
local Row = Tab:HStack()
local Left = Row:Group({ Title = "Server", Icon = "server", Padding = 10 })
local Right = Row:Group({ Title = "Friends", Icon = "users", Padding = 10 })
Left:Stat({ Title = "Players", Value = "8" })
Right:Stat({ Title = "Online", Value = "2" })
```

Groups accept `Header = false`, `TextAlign`, `TitleSize`, `DescSize`, `IconSize`, `IconThemed`, `BackgroundColor`, `BackgroundTransparency`, `BorderColor`, `BorderThickness`, and `BorderTransparency`. The background, border, text, and icon use the current theme by default. `Stat` accepts `ValueSize`, `ValueColor`, `TextAlign`, `Padding`, and `Radius`. `Callout` accepts `Color`, `IconSize`, `TitleSize`, `DescSize`, `TextAlign`, `Padding`, and `Radius`.

## Viewport

```luau
local Preview = Tab:Viewport({
    Object = workspace.PreviewModel,
    Height = 240,
    Interactive = true,
    Clone = true, -- default: leave the original in Workspace
    Focused = true,
    MinZoom = 2,
    MaxZoom = 40,
    ZoomSpeed = 2,
    RotationSpeed = 0.01,
    FieldOfView = 60,
    FocusPadding = 1.25,
})
Preview:SetObject(workspace.AnotherModel)
Preview:Focus()
Preview:SetZoom(8)
Preview:SetAngles(0, 0)
```

The viewport accepts a `Model` or `BasePart`. Drag to orbit, use the mouse wheel or pinch to zoom. It keeps zoom within the configured bounds and restores tab scrolling after interaction. The scene has configurable `Ambient`, `LightColor`, and `LightDirection`; these can also be changed with `SetLighting`.
