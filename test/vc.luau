local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local MinecraftLoader = {}
MinecraftLoader.__index = MinecraftLoader

local ASSETS = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/"

local DEFAULTS = {
    Position = UDim2.new(0.5, 0, 0, 22),
    Width = 364,
    Height = 154,
    AutoClose = true,
    AutoCloseDelay = 0.65,
    SwingBack = -40,
    SwingHit = 28,
    SwingTime = 0.14,
    Status = "Preparing SteveHub...",
    Title = "STEVEHUB",
    TextFont = Enum.Font.GothamMedium,
    TitleFont = Enum.Font.Arcade,
    DiamondImage = nil,
    Parent = nil,
}

local function getAsset(filename, remoteName)
    local path = "Steve/assets/" .. filename
    if isfile and getcustomasset and isfile(path) then
        local ok, id = pcall(getcustomasset, path)
        if ok then return id end
    end
    if not (writefile and getcustomasset and game.HttpGet) then return "" end
    local ok, result = pcall(function()
        if makefolder and isfolder then
            if not isfolder("Steve") then makefolder("Steve") end
            if not isfolder("Steve/assets") then makefolder("Steve/assets") end
        end
        writefile(path, game:HttpGet(ASSETS .. remoteName))
        return getcustomasset(path)
    end)
    if not ok then warn("SteveHub asset error:", result) end
    return ok and result or ""
end

local function create(class, parent, properties)
    local object = Instance.new(class)
    for name, value in pairs(properties or {}) do object[name] = value end
    object.Parent = parent
    return object
end

local function tween(object, duration, properties, style, direction)
    local t = TweenService:Create(object, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end

local function play(object, duration, properties, style, direction)
    local t = tween(object, duration, properties, style, direction)
    local state = t.Completed:Wait()
    return state == Enum.PlaybackState.Completed
end

function MinecraftLoader.new(settings)
    local self = setmetatable({}, MinecraftLoader)
    self.Config = table.clone(DEFAULTS)
    for k, v in pairs(settings or {}) do self.Config[k] = v end
    self.Progress = 0
    self.TargetProgress = 0
    self.Animating = false
    self.Broken = false
    self.Closing = false
    self.Session = 0
    self.Destroyed = false
    self:_Build()
    return self
end

function MinecraftLoader:_Build()
    local c = self.Config
    local gui = create("ScreenGui", c.Parent or Players.LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "SteveHubMiningLoader",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    self.Gui = gui

    local panel = create("CanvasGroup", gui, {
        Name = "Notification",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = c.Position,
        Size = UDim2.fromOffset(c.Width, c.Height),
        BackgroundColor3 = Color3.fromRGB(52, 45, 36),
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Visible = false,
    })
    self.Panel = panel

    create("UICorner", panel, {
        CornerRadius = UDim.new(0, 8)
    })

    create("UIStroke", panel, {
        Thickness = 2,
        Color = Color3.fromRGB(120, 110, 90),
        Transparency = 0.15
    })

    create("UIGradient", panel, {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 38, 31)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 22, 18)),
        })
    })

    local bottomStrip = create("ImageLabel", panel, {
        Name = "BottomDirtStrip",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -34),
        Size = UDim2.new(1, 0, 0, 34),
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(48, 48),
        Image = getAsset("background.png", "dirttexture.png"),
        ImageTransparency = 0.76,
        ZIndex = 1,
    })
    create("UICorner", bottomStrip, {
        CornerRadius = UDim.new(0, 8)
    })

    local slot = create("Frame", panel, {
        Name = "MiningBackdrop",
        Position = UDim2.fromOffset(16, 19),
        Size = UDim2.fromOffset(92, 82),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(22, 22, 19),
        BackgroundTransparency = 0.16,
        ZIndex = 2,
    })
    create("UICorner", slot, {
        CornerRadius = UDim.new(0, 4)
    })
    create("UIStroke", slot, {
        Thickness = 1,
        Color = Color3.fromRGB(124, 114, 92),
        Transparency = 0.38
    })

    local ore = create("ImageLabel", panel, {
        Name = "DiamondOre",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(85, 73),
        Size = UDim2.fromOffset(34, 34),
        Image = getAsset("diamond_ore.jpg", "diamondblock.jpg"),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
    })
    self.Ore = ore
    self.OrePosition = ore.Position

    local pickaxe = create("ImageLabel", panel, {
        Name = "Pickaxe",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.22, 0.80),
        Position = UDim2.fromOffset(54, 70),
        Size = UDim2.fromOffset(48, 48),
        Image = getAsset("pickaxe.png", "diamondpickaxe.png"),
        ScaleType = Enum.ScaleType.Fit,
        Rotation = -8,
        ZIndex = 7,
    })
    self.Pickaxe = pickaxe

    create("TextLabel", panel, {
        Name = "Title",
        Position = UDim2.fromOffset(124, 22),
        Size = UDim2.new(1, -140, 0, 28),
        BackgroundTransparency = 1,
        Text = c.Title,
        Font = c.TitleFont,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(247, 241, 224),
        TextStrokeColor3 = Color3.fromRGB(26, 23, 18),
        TextStrokeTransparency = 0.58,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    self.Status = create("TextLabel", panel, {
        Name = "Status",
        Position = UDim2.fromOffset(124, 52),
        Size = UDim2.new(1, -146, 0, 22),
        BackgroundTransparency = 1,
        Text = c.Status,
        Font = c.TextFont,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(210, 205, 189),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
    })

    create("TextLabel", panel, {
        Name = "ProgressCaption",
        Position = UDim2.fromOffset(124, 82),
        Size = UDim2.fromOffset(160, 16),
        BackgroundTransparency = 1,
        Text = "MINING PROGRESS",
        Font = c.TextFont,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(176, 170, 150),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    self.Percent = create("TextLabel", panel, {
        Name = "Percent",
        Position = UDim2.new(1, -56, 0, 82),
        Size = UDim2.fromOffset(40, 16),
        BackgroundTransparency = 1,
        Text = "0%",
        Font = c.TextFont,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(199, 226, 132),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4,
    })

    local bar = create("ImageLabel", panel, {
        Name = "XPBarBackground",
        Position = UDim2.fromOffset(16, 112),
        Size = UDim2.new(1, -32, 0, 12),
        BackgroundTransparency = 1,
        Image = getAsset("xpbar.png", "experience_bar_background.png"),
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = 3,
    })
    self.Bar = bar

    local mask = create("Frame", bar, {
        Name = "FillContainer",
        Size = UDim2.fromScale(0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4,
    })
    self.Mask = mask

    create("ImageLabel", mask, {
        Name = "XPBarFill",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Stretch,
        Image = getAsset("xpbar_fill.png", "experience_bar_progress.png"),
        ZIndex = 4,
    })
end

function MinecraftLoader:_Shake(session)
    local ore = self.Ore
    local origin = self.OrePosition
    for _, offset in ipairs({-4, 3, -2, 1, 0}) do
        if session ~= self.Session then return end
        play(ore, 0.043, {
            Position = origin + UDim2.fromOffset(offset, math.abs(offset) % 2),
            Rotation = offset * 1.25,
        }, Enum.EasingStyle.Linear)
    end
    ore.Position = origin
    ore.Rotation = 0
end

function MinecraftLoader:_Particles()
    local panel = self.Panel
    for i = 1, 5 do
        local particle = create("Frame", panel, {
            Name = "OreChip", Position = UDim2.fromOffset(82, 77),
            Size = UDim2.fromOffset(math.random(3, 6), math.random(3, 6)),
            BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(63, 204, 203) or Color3.fromRGB(125, 132, 126),
            BorderSizePixel = 0, ZIndex = 8,
        })
        local dx = math.random(-23, 25)
        local dy = math.random(-19, 20)
        local t = tween(particle, 0.24, {
            Position = particle.Position + UDim2.fromOffset(dx, dy),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quad)
        t.Completed:Once(function() particle:Destroy() end)
    end
end

function MinecraftLoader:_Swing(session)
    if not play(self.Pickaxe, self.Config.SwingTime, {Rotation = self.Config.SwingBack}, Enum.EasingStyle.Quad) then return end
    if session ~= self.Session then return end
    play(self.Pickaxe, 0.095, {Rotation = self.Config.SwingHit}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    if session ~= self.Session then return end
    self:_Particles()
    task.spawn(function() self:_Shake(session) end)
    play(self.Pickaxe, 0.19, {Rotation = -5}, Enum.EasingStyle.Back)
end

function MinecraftLoader:_DropDiamond(session)
    self.Ore.Visible = false
    self:_Particles()
    local c = self.Config
    local diamond = create("ImageLabel", self.Panel, {
        Name = "DroppedDiamond", BackgroundTransparency = 1,
        Image = c.DiamondImage or getAsset("diamond.png", "diamond.png"),
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(82, 77), ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Fit, Rotation = -18, ZIndex = 10,
    })
    self.Diamond = diamond
    play(diamond, 0.2, {Position = UDim2.fromOffset(82, 44), Rotation = 12}, Enum.EasingStyle.Back)
    if session ~= self.Session then return end
    play(diamond, 0.52, {Position = UDim2.fromOffset(93, 116), Rotation = 85}, Enum.EasingStyle.Bounce)
    if session ~= self.Session then return end
    play(diamond, 0.16, {ImageTransparency = 1, Size = UDim2.fromOffset(16, 16)})
    diamond:Destroy()
    self.Diamond = nil
end

function MinecraftLoader:_Process(session)
    while self.Progress < self.TargetProgress and session == self.Session do
        self:_Swing(session)
        if session ~= self.Session then return end
        -- Catch up to the latest loading stage without overlapping animations.
        self.Progress = self.TargetProgress
        self.Percent.Text = string.format("%d%%", math.floor(self.Progress * 100 + 0.5))
        play(self.Mask, 0.23, {Size = UDim2.fromScale(self.Progress, 1)}, Enum.EasingStyle.Quad)
    end
    if session ~= self.Session then return end
    if self.Progress >= 1 and not self.Broken then
        self.Broken = true
        self.Status.Text = "Ready to play!"
        self:_DropDiamond(session)
        if session ~= self.Session then return end
        if self.Config.AutoClose then
            task.wait(self.Config.AutoCloseDelay)
            if session == self.Session then self:Close() end
        end
    end
    if session == self.Session then self.Animating = false end
end

function MinecraftLoader:SetProgress(value)
    if self.Destroyed or self.Broken or self.Closing then return end
    value = math.clamp(value, 0, 1)
    if value <= self.TargetProgress then return end
    self.TargetProgress = value
    if not self.Animating then
        self.Animating = true
        local session = self.Session
        task.spawn(function() self:_Process(session) end)
    end
end

function MinecraftLoader:AddProgress(value)
    self:SetProgress(self.TargetProgress + value)
end

function MinecraftLoader:SetStatus(value)
    if not self.Destroyed then self.Status.Text = tostring(value) end
end

function MinecraftLoader:Reset()
    if self.Destroyed then return end
    self.Session += 1
    self.Progress, self.TargetProgress = 0, 0
    self.Animating, self.Broken, self.Closing = false, false, false
    self.Mask.Size = UDim2.fromScale(0, 1)
    self.Percent.Text = "0%"
    self.Status.Text = self.Config.Status
    self.Ore.Visible = true
    self.Ore.Position = self.OrePosition
    self.Ore.Rotation = 0
    self.Pickaxe.Rotation = -5
    if self.Diamond then self.Diamond:Destroy() self.Diamond = nil end
end

function MinecraftLoader:Open()
    if self.Destroyed then return end
    self:Reset()
    local panel = self.Panel
    local target = self.Config.Position
    panel.Visible = true
    panel.GroupTransparency = 1
    panel.Position = target - UDim2.fromOffset(0, 18)
    tween(panel, 0.32, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
    play(panel, 0.44, {Position = target}, Enum.EasingStyle.Back)
end

function MinecraftLoader:Close()
    if self.Destroyed or self.Closing then return end
    self.Closing = true
    self.Session += 1
    local panel = self.Panel
    local t = tween(panel, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(panel, 0.3, {Position = self.Config.Position - UDim2.fromOffset(0, 14)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    t.Completed:Wait()
    if not self.Destroyed then panel.Visible = false end
end

function MinecraftLoader:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Session += 1
    self.Gui:Destroy()
end


local Loader = MinecraftLoader.new({
    AutoClose = true,
    AutoCloseDelay = 0.65,

    SwingBack = -40,
    SwingHit = 28,
    SwingTime = 0.14,
})

Loader:Open()

Loader:SetStatus("Initializing SteveHub...")
Loader:SetProgress(0.2)

task.wait(1)

Loader:SetStatus("Loading modules...")
Loader:SetProgress(0.5)

task.wait(1)

Loader:SetStatus("Loading plugins...")
Loader:SetProgress(0.8)

task.wait(1)

Loader:SetStatus("Finishing...")
Loader:SetProgress(1)