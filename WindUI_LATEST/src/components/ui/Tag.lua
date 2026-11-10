local Tag = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

function Tag:New(TagConfig, Parent)
	local TagModule = {
		Title = TagConfig.Title or "Tag",
		Icon = TagConfig.Icon,
		Color = TagConfig.Color or Color3.fromHex("#315dff"),
		Radius = TagConfig.Radius or 999,
		Border = TagConfig.Border or false,

		TagFrame = nil,
		Height = TagConfig.Height or 26,
		Padding = TagConfig.Padding or 10,
		TextSize = TagConfig.TextSize or 14,
		IconSize = TagConfig.IconSize or 16,
	}

	local TagIcon
	if TagModule.Icon then
		TagIcon = Creator.Image(TagModule.Icon, TagModule.Icon, 0, TagConfig.Window, "Tag", false)

		TagIcon.Size = UDim2.new(0, TagModule.IconSize, 0, TagModule.IconSize)
		TagIcon.ImageLabel.ImageColor3 = typeof(TagModule.Color) == "Color3"
				and Creator.GetTextColorForHSB(TagModule.Color)
			or typeof(TagModule.Color) == "string"
				and (Creator.GetTextColorForHSB(Creator.GetThemeProperty(TagModule.Color, Creator.Theme)))
	end

	local TagTitle = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
		TextSize = TagModule.TextSize,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		Text = TagModule.Title,
		TextColor3 = typeof(TagModule.Color) == "Color3" and Creator.GetTextColorForHSB(TagModule.Color) or typeof(
			TagModule.Color
		) == "string" and (Creator.GetTextColorForHSB(Creator.GetThemeProperty(TagModule.Color, Creator.Theme))),
		LayoutOrder = 9999,
	})

	local BackgroundGradient

	if typeof(TagModule.Color) == "table" then
		BackgroundGradient = New("UIGradient")
		for key, value in next, TagModule.Color do
			BackgroundGradient[key] = value
		end

		TagTitle.TextColor3 = Creator.GetTextColorForHSB(Creator.GetAverageColor(BackgroundGradient))
		if TagIcon then
			TagIcon.ImageLabel.ImageColor3 = Creator.GetTextColorForHSB(Creator.GetAverageColor(BackgroundGradient))
		end
	end

	local TagFrame = Creator.NewRoundFrame(TagModule.Radius, "Squircle", {
		AutomaticSize = "X",
		Size = UDim2.new(0, 0, 0, TagModule.Height),
		Parent = Parent,
		LayoutOrder = TagConfig.Order or 0,
		ImageTransparency = TagConfig.BackgroundTransparency or 0,
		ImageColor3 = typeof(TagModule.Color) == "Color3" and TagModule.Color
			or typeof(TagModule.Color) == "table" and Color3.new(1, 1, 1)
			or nil,
		ThemeTag = typeof(TagModule.Color) == "string" and {
			ImageColor3 = TagModule.Color,
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, TagModule.Radius) }),
		BackgroundGradient,
		Creator.NewRoundFrame(TagModule.Radius + 1, "SquircleGlass", {
			Size = UDim2.new(1, 1, 1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ThemeTag = {
				ImageColor3 = "White",
			},
			ImageTransparency = 0.75,
		}),
		New("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = "X",
			Name = "Content",
			BackgroundTransparency = 1,
		}, {
			TagIcon,
			TagTitle,
			New("UIPadding", {
				PaddingLeft = UDim.new(0, TagModule.Padding),
				PaddingRight = UDim.new(0, TagModule.Padding),
			}),
			New("UIListLayout", {
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
				Padding = UDim.new(0, TagModule.Padding / 1.5),
			}),
		}),
	})
	TagModule.TagFrame = TagFrame
	if TagModule.Border then
		New("UIStroke", {
			Parent = TagFrame,
			Thickness = TagConfig.BorderThickness or 1,
			Transparency = TagConfig.BorderTransparency or 0.55,
			Color = typeof(TagConfig.BorderColor) == "Color3" and TagConfig.BorderColor or nil,
			ThemeTag = typeof(TagConfig.BorderColor) == "Color3" and nil
				or { Color = TagConfig.BorderColor or "White" },
		})
	end
	if TagIcon then TagIcon.LayoutOrder = TagConfig.IconPosition == "Right" and 2 or 0 end
	TagTitle.LayoutOrder = 1
	if TagConfig.TextColor then TagTitle.TextColor3 = TagConfig.TextColor end
	if TagConfig.IconColor and TagIcon then TagIcon.ImageLabel.ImageColor3 = TagConfig.IconColor end

	function TagModule:SetTitle(text)
		TagModule.Title = text
		TagTitle.Text = text

		return TagModule
	end

	function TagModule:SetColor(color)
		TagModule.Color = color
		if typeof(color) == "table" then
			local gradient = TagFrame:FindFirstChildOfClass("UIGradient") or New("UIGradient", { Parent = TagFrame })
			for k, v in next, color do gradient[k] = v end
			local avgColor = Creator.GetAverageColor(gradient)
			Tween(TagTitle, 0.06, { TextColor3 = TagConfig.TextColor or Creator.GetTextColorForHSB(avgColor) }):Play()
			Tween(TagFrame, 0.06, { ImageColor3 = Color3.new(1, 1, 1) }):Play()
		else
			local gradient = TagFrame:FindFirstChildOfClass("UIGradient")
			if gradient then gradient:Destroy() end
			local resolved = typeof(color) == "string" and Creator.GetThemeProperty(color, Creator.Theme) or color
			Tween(TagTitle, 0.06, { TextColor3 = TagConfig.TextColor or Creator.GetTextColorForHSB(resolved) }):Play()
			if TagIcon then
				Tween(TagIcon.ImageLabel, 0.06, { ImageColor3 = TagConfig.IconColor or Creator.GetTextColorForHSB(resolved) }):Play()
			end
			Tween(TagFrame, 0.06, { ImageColor3 = resolved }):Play()
		end

		return TagModule
	end

	function TagModule:SetIcon(icon)
		TagModule.Icon = icon

		if TagIcon then
			TagIcon:Destroy()
			TagIcon = nil
		end

		if icon then
			TagIcon = Creator.Image(icon, icon, 0, TagConfig.Window, "Tag", false)

			TagIcon.Size = UDim2.new(0, TagModule.IconSize, 0, TagModule.IconSize)
			TagIcon.Parent = TagFrame:FindFirstChild("Content")
			TagIcon.LayoutOrder = TagConfig.IconPosition == "Right" and 2 or 0
			local resolved = typeof(TagModule.Color) == "string"
				and Creator.GetThemeProperty(TagModule.Color, Creator.Theme) or TagModule.Color
			if typeof(resolved) == "Color3" then
				TagIcon.ImageLabel.ImageColor3 = TagConfig.IconColor or Creator.GetTextColorForHSB(resolved)
			end

			if typeof(TagModule.Color) == "Color3" then
				TagIcon.ImageLabel.ImageColor3 = Creator.GetTextColorForHSB(TagModule.Color)
			elseif typeof(TagModule.Color) == "table" then
				TagIcon.ImageLabel.ImageColor3 = Creator.GetTextColorForHSB(
					Creator.GetAverageColor(TagFrame:FindFirstChildOfClass("UIGradient")))
			end
		end
		return TagModule
	end

	function TagModule:Destroy()
		TagFrame:Destroy()
		return TagModule
	end

	Creator:OnThemeChange(function(NewTheme, OldTheme)
		local color = typeof(TagModule.Color) == "table"
			and Creator.GetAverageColor(TagFrame:FindFirstChildOfClass("UIGradient"))
			or (typeof(TagModule.Color) == "string" and Creator.GetThemeProperty(TagModule.Color, Creator.Theme) or TagModule.Color)
		if color then
			local textColor = Creator.GetTextColorForHSB(color)
			TagTitle.TextColor3 = TagConfig.TextColor or textColor
			if TagIcon then TagIcon.ImageLabel.ImageColor3 = TagConfig.IconColor or textColor end
			if typeof(TagModule.Color) == "string" then TagFrame.ImageColor3 = color end
		end
	end)

	return TagModule
end

return Tag
