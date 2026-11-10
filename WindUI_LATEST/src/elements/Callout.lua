local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}

function Element:New(Config)
	local Callout = {
		__type = "Callout",
		Title = Config.Title or "Notice",
		Desc = Config.Desc or "",
		Icon = Config.Icon,
	}
	local Main = New("Frame", {
		Parent = Config.Parent,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		ThemeTag = typeof(Config.Color) == "Color3" and nil or {
			BackgroundColor3 = Config.Color or "CalloutBackground",
			BackgroundTransparency = "CalloutBackgroundTransparency",
		},
		BackgroundColor3 = typeof(Config.Color) == "Color3" and Config.Color or nil,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, Config.Radius or Config.Window.ElementConfig.UICorner) }),
		New("UIPadding", {
			PaddingTop = UDim.new(0, Config.Padding or 14),
			PaddingBottom = UDim.new(0, Config.Padding or 14),
			PaddingLeft = UDim.new(0, Config.Padding or 14),
			PaddingRight = UDim.new(0, Config.Padding or 14),
		}),
		New("UIListLayout", { FillDirection = "Horizontal", Padding = UDim.new(0, 10) }),
	})
	local Icon
	if Callout.Icon then
		Icon = Creator.Image(Callout.Icon, Callout.Icon .. ":" .. Callout.Title, 0,
			Config.Window.Folder, "Callout", true, Config.IconThemed, "CalloutIcon")
		Icon.Size = UDim2.new(0, Config.IconSize or 20, 0, Config.IconSize or 20)
		Icon.LayoutOrder = 0
		Icon.Parent = Main
	end
	local Text = New("Frame", {
		Parent = Main, Size = UDim2.new(1, Icon and -(Config.IconSize or 20) - 10 or 0, 0, 0),
		AutomaticSize = "Y", BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, { New("UIListLayout", { Padding = UDim.new(0, 3) }) })
	local Title = New("TextLabel", {
		Parent = Text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Callout.Title, TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = Config.TitleSize or 16,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		ThemeTag = { TextColor3 = "CalloutTitle" },
		LayoutOrder = 0,
	})
	local Desc = New("TextLabel", {
		Parent = Text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Callout.Desc, TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = Config.DescSize or 13,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "CalloutDesc" },
		Visible = Callout.Desc ~= "",
		LayoutOrder = 1,
	})
	Callout.ElementFrame = Main
	Callout.UIElements = { Main = Main, Title = Title, Desc = Desc, Icon = Icon }
	function Callout:SetTitle(Value)
		Callout.Title = Value
		Title.Text = Value or ""
	end
	function Callout:SetDesc(Value)
		Callout.Desc = Value
		Desc.Text = Value or ""
		Desc.Visible = Value ~= nil and Value ~= ""
	end
	return Callout.__type, Callout
end

return Element
