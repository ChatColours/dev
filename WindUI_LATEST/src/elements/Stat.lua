local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}

function Element:New(Config)
	local Stat = {
		__type = "Stat",
		Title = Config.Title or "Metric",
		Value = Config.Value or "—",
		Desc = Config.Desc,
	}
	local Main = Creator.NewRoundFrame(Config.Radius or Config.Window.ElementConfig.UICorner, "Squircle", {
		Parent = Config.Parent,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		ThemeTag = { ImageColor3 = "StatBackground", ImageTransparency = "StatBackgroundTransparency" },
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, Config.Padding or 14),
			PaddingBottom = UDim.new(0, Config.Padding or 14),
			PaddingLeft = UDim.new(0, Config.Padding or 14),
			PaddingRight = UDim.new(0, Config.Padding or 14),
		}),
		New("UIListLayout", { Padding = UDim.new(0, 4) }),
	})
	local Title = New("TextLabel", {
		Parent = Main, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Stat.Title, TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = 13,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "StatLabel" }, TextTransparency = 0.25,
		LayoutOrder = 0,
	})
	local Value = New("TextLabel", {
		Parent = Main, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = tostring(Stat.Value), TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = Config.ValueSize or 24,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Bold),
		ThemeTag = typeof(Config.ValueColor) == "Color3" and nil or { TextColor3 = Config.ValueColor or "StatValue" },
		TextColor3 = typeof(Config.ValueColor) == "Color3" and Config.ValueColor or nil,
		LayoutOrder = 1,
	})
	local Desc = New("TextLabel", {
		Parent = Main, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = "Y",
		BackgroundTransparency = 1, Text = Stat.Desc or "", TextWrapped = true,
		TextXAlignment = Config.TextAlign or "Left", TextSize = 12,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		ThemeTag = { TextColor3 = "StatLabel" }, TextTransparency = 0.45,
		Visible = Stat.Desc ~= nil,
		LayoutOrder = 2,
	})
	Stat.ElementFrame = Main
	Stat.UIElements = { Main = Main, Title = Title, Value = Value, Desc = Desc }
	function Stat:SetValue(NewValue)
		Stat.Value = NewValue
		Value.Text = tostring(NewValue)
	end
	function Stat:SetDesc(NewDesc)
		Stat.Desc = NewDesc
		Desc.Text = NewDesc or ""
		Desc.Visible = NewDesc ~= nil
	end
	function Stat:SetTitle(NewTitle)
		Stat.Title = NewTitle
		Title.Text = NewTitle
	end
	return Stat.__type, Stat
end

return Element
