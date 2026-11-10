local TweenService = game:GetService("TweenService")

local Creator = {}

function Creator.New(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end

    for _, Child in ipairs(Children or {}) do
        Child.Parent = Object
    end

    return Object
end

function Creator.Tween(Object, Properties, Duration, Style, Direction)
    local Info = TweenInfo.new(
        Duration or 0.25,
        Style or Enum.EasingStyle.Quint,
        Direction or Enum.EasingDirection.Out
    )

    local Tween = TweenService:Create(Object, Info, Properties)
    Tween:Play()

    return Tween
end

function Creator.Corner(Object, Radius)
    return Creator.New("UICorner", {
        CornerRadius = typeof(Radius) == "UDim"
            and Radius
            or UDim.new(0, Radius or 8),

        Parent = Object
    })
end

function Creator.Stroke(Object, Color, Thickness, Transparency)
    return Creator.New("UIStroke", {
        Color = Color or Color3.new(1, 1, 1),
        Thickness = Thickness or 1,
        Transparency = Transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = Object
    })
end

function Creator.Gradient(Object, Colors, Rotation, Transparencies)
    local ColorSequenceValue

    if typeof(Colors) == "ColorSequence" then
        ColorSequenceValue = Colors
    elseif typeof(Colors) == "Color3" then
        ColorSequenceValue = ColorSequence.new(Colors)
    elseif type(Colors) == "table" then
        local Keypoints = {}

        for Index, Color in ipairs(Colors) do
            table.insert(Keypoints, ColorSequenceKeypoint.new(
                (Index - 1) / math.max(#Colors - 1, 1),
                Color
            ))
        end

        ColorSequenceValue = ColorSequence.new(Keypoints)
    else
        ColorSequenceValue = ColorSequence.new(
            Color3.new(1, 1, 1)
        )
    end

    return Creator.New("UIGradient", {
        Color = ColorSequenceValue,
        Rotation = Rotation or 0,
        Transparency = Transparencies or NumberSequence.new(0),
        Parent = Object
    })
end

function Creator.Padding(Object, Top, Right, Bottom, Left)
    return Creator.New("UIPadding", {
        PaddingTop = UDim.new(0, Top or 0),
        PaddingRight = UDim.new(0, Right or 0),
        PaddingBottom = UDim.new(0, Bottom or 0),
        PaddingLeft = UDim.new(0, Left or 0),
        Parent = Object
    })
end

function Creator.List(Object, Padding, HorizontalAlignment, VerticalAlignment)
    return Creator.New("UIListLayout", {
        Padding = UDim.new(0, Padding or 0),
        HorizontalAlignment = HorizontalAlignment or Enum.HorizontalAlignment.Left,
        VerticalAlignment = VerticalAlignment or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Object
    })
end

return Creator