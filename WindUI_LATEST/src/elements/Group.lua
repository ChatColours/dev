local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}

function Element:New(Config)
	local Window = Config.Window
	local Gap = Config.Gap or (Config.Tab and Config.Tab.Gap) or 6
	local Padding = Config.Padding or 12
	local Group = {
		__type = "Group",
		Title = Config.Title,
		Desc = Config.Desc,
		Icon = Config.Icon,
		Elements = {},
		Layout = Config.Layout or "Vertical",
	}
	local Card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		Parent = Config.Parent,
		BackgroundColor3 = typeof(Config.BackgroundColor) == "Color3" and Config.BackgroundColor or nil,
		BackgroundTransparency = Config.BackgroundTransparency,
		ThemeTag = typeof(Config.BackgroundColor) == "Color3" and nil or {
			BackgroundColor3 = Config.BackgroundColor or "GroupBackground",
			BackgroundTransparency = Config.BackgroundTransparency and nil or "GroupBackgroundTransparency",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, Config.Radius or Window.ElementConfig.UICorner) }),
		New("UIPadding", {
			PaddingTop = UDim.new(0, Padding),
			PaddingBottom = UDim.new(0, Padding),
			PaddingLeft = UDim.new(0, Padding),
			PaddingRight = UDim.new(0, Padding),
		}),
		New("UIListLayout", {
			SortOrder = "LayoutOrder",
			FillDirection = "Vertical",
			Padding = UDim.new(0, Gap),
		}),
	})
	local Border = New("UIStroke", {
		Parent = Card,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = Config.BorderThickness or 1,
		Transparency = Config.Border == false and 1 or (Config.BorderTransparency or 0.8),
		Color = typeof(Config.BorderColor) == "Color3" and Config.BorderColor or nil,
		ThemeTag = typeof(Config.BorderColor) == "Color3" and nil or { Color = Config.BorderColor or "GroupBorder" },
	})
	local Header = New("Frame", {
		Parent = Card,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Visible = Config.Header ~= false and (Group.Title ~= nil or Group.Desc ~= nil or Group.Icon ~= nil),
	}, {
		New("UIListLayout", { FillDirection = "Horizontal", VerticalAlignment = "Center", Padding = UDim.new(0, 8) }),
	})
	local Icon
	if Group.Icon then
		Icon = Creator.Image(Group.Icon, Group.Icon .. ":" .. (Group.Title or "Group"), 0, Window.Folder, "Group", true, Config.IconThemed, "GroupIcon")
		Icon.Size = UDim2.new(0, Config.IconSize or 18, 0, Config.IconSize or 18)
		Icon.LayoutOrder = 0
		Icon.Parent = Header
	end
	local Text = New("Frame", {
		Parent = Header,
		Size = UDim2.new(1, Icon and -(Config.IconSize or 18) - 8 or 0, 0, 0),
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, { New("UIListLayout", { Padding = UDim.new(0, 2) }) })
	local Title = New("TextLabel", {
		Parent = Text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Group.Title or "", TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = Config.TitleSize or 16,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "GroupTitle" }, Visible = Group.Title ~= nil,
	})
	local Desc = New("TextLabel", {
		Parent = Text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Group.Desc or "", TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = Config.DescSize or 13,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "GroupDesc" }, TextTransparency = 0.35, Visible = Group.Desc ~= nil,
	})
	local Content = New("Frame", {
		Parent = Card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, LayoutOrder = 1,
	}, {
		New("UIListLayout", {
			FillDirection = Group.Layout == "Horizontal" and "Horizontal" or "Vertical",
			VerticalAlignment = "Top", Padding = UDim.new(0, Gap),
		}),
	})
	Group.ElementFrame = Card
	Group.UIElements = { Card = Card, Header = Header, Content = Content, Border = Border }
	Config.ElementsModule.Load(Group, Content, Config.ElementsModule.Elements, Window, Config.WindUI,
		Group.Layout == "Horizontal" and function(_, AllElements)
			local Count = #AllElements
			if Count == 0 then return end
			for _, Child in ipairs(AllElements) do
				if Child.ElementFrame then
					Child.ElementFrame.Size = UDim2.new(1 / Count, -(Gap * (Count - 1)) / Count, 0, Child.ElementFrame.Size.Y.Offset)
				end
			end
		end or nil, Config.ElementsModule, Config.UIScale, Config.Tab)
	function Group:SetTitle(Value)
		Group.Title = Value
		Title.Text = Value or ""
		Title.Visible = Value ~= nil
		Header.Visible = Config.Header ~= false and (Group.Title ~= nil or Group.Desc ~= nil or Group.Icon ~= nil)
	end
	function Group:SetDesc(Value)
		Group.Desc = Value
		Desc.Text = Value or ""
		Desc.Visible = Value ~= nil
		Header.Visible = Config.Header ~= false and (Group.Title ~= nil or Group.Desc ~= nil or Group.Icon ~= nil)
	end
	function Group:SetBackground(Color, Transparency)
		if Color then Card.BackgroundColor3 = Color end
		if Transparency then Card.BackgroundTransparency = Transparency end
	end
	return Group.__type, Group
end

return Element
