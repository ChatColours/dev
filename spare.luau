local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
---------------------------------------------------------------------------------------------------------------------
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
--local game.Workspace = game.Workspace

---------------------------------------------------------------------------------------------------------------------
local ka = false
local DeleteClickAura = false
local spraypaint = false
local currentText = ""
local currentBlockPathType = "detailed"
local currentRepStorageBrickText = "Hello, world!"
local connections = {}
local highlights = {}
local invis = {}
local TextChatService = game:GetService("TextChatService")
local RBXGeneral = TextChatService.TextChannels.RBXGeneral
local function chatMessage(msg)
	RBXGeneral:SendAsync(tostring(msg))
	task.wait(0.1)
end
local bricksFolder = game.Workspace.Bricks

local validParts = {}


for _, v in ipairs(bricksFolder:GetDescendants()) do
	if v:IsA("BasePart") then
		validParts[v] = true
	end
end
bricksFolder.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		validParts[obj] = true
	end
end)
bricksFolder.DescendantRemoving:Connect(function(obj)
	if validParts[obj] then
		validParts[obj] = nil
	end
end)

---------------------------------------------------------------------------------------------------------------------

local PermDel = false
local LocalPlayer = Players.LocalPlayer
local plr = Players.LocalPlayer
local character = plr.Character

plr.CharacterAdded:Connect(function(char)
	character = char -- reset when char added
end)

local mouse = plr:GetMouse()
local cam = game.Workspace.CurrentCamera
local detailedPath = false
local shovel = false
local delete = false
local rainbow = false
local rainbowSky = false
local boxMode = false
local selectedBlock = false
local velocities = true -- for save delete

local backpack = plr:WaitForChild("Backpack")
local function getTool(tool)
	local t = plr.Backpack:FindFirstChild(tool)
	if not t then
		t = plr.Character:FindFirstChild(tool)

	end

	if t then
		return t
	end
end
local function getEvent(tool)
	return tool
		and tool:FindFirstChild("Script")
		and tool.Script:FindFirstChild("Event")
end

local buildTool = getTool("Build")
local buildEvent = getEvent(buildTool)

local paintTool = getTool("Paint")
local paintEvent = getEvent(paintTool)

local deleteTool = getTool("Delete")
local deleteEvent = getEvent(deleteTool)

local shovelTool = getTool("Shovel")
local shovelEvent = getEvent(shovelTool)
print(buildTool, buildEvent, paintTool, paintEvent, deleteTool, deleteEvent, shovelTool, shovelEvent)
local material = "plastic"
local currentMaterial = "smooth"
local h = 0

local block = nil
local waitingForClick = false



local function normalToFace(n)
	local a = math.abs
	if a(n.X) > a(n.Y) and a(n.X) > a(n.Z) then
		return n.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left
	elseif a(n.Y) > a(n.Z) then
		return n.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom
	else
		return n.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
	end
end
local function getPaintEvent()
	local char = plr.Character
	if char then
		local tool = char:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint")
		if tool then
			paintTool = tool
			local scr = tool:FindFirstChild("Script")
			if scr then
				return scr:FindFirstChild("Event")
			end
		end
	end
end

local function RepStorageText(txt, side)
	local len = #txt
	local third = math.floor(len/3)

	local part1 = string.sub(txt, 1, third)
	local part2 = string.sub(txt, third+1, third*2)
	local part3 = string.sub(txt, third*2+1)

	txt =
		'<font color="#ff5555">'..part1..'</font>'..
		'<font color="#55ff55">'..part2..'</font>'..
		'<font color="#5599ff">'..part3..'</font>'

	local args = {
		game.ReplicatedStorage:WaitForChild("Brick"),
		side,
		game.ReplicatedStorage:WaitForChild("Brick").Position,
		"both \240\159\164\157",
		Color3.new(0.8784313797950745, 0.8784313797950745, 0.43921568989753723),
		"spray",
		tostring(txt)
	}
	game.Players.LocalPlayer.Character:WaitForChild("Paint"):WaitForChild("Script"):WaitForChild("Event"):FireServer(unpack(args))

end

local event = getPaintEvent()

local function refreshTools()
	local char = plr.Character
	if not char then return end

	local backpack = plr.Backpack

	local function findTool(toolName)
		return char:FindFirstChild(toolName) or backpack:FindFirstChild(toolName)
	end

	paintTool = findTool("Paint")
	if paintTool then
		paintEvent = paintTool.Script.Event
	end

	buildTool = findTool("Build")
	if buildTool then
		buildEvent = buildTool.Script.Event
	end

	deleteTool = findTool("Delete")
	if deleteTool then
		deleteTool = deleteTool.Script.Event
	end


	shovelTool = findTool("Shovel")
	if shovelTool then
		shovelEvent = shovelTool.Script.Event
	end

	--local paintTool = findTool("Paint")
	--	event = paintTool and paintTool:FindFirstChild("Script") and paintTool.Script:FindFirstChild("Event") or nil
	--[[
	local paintTool = findTool("Paint")
	event = paintTool and paintTool:FindFirstChild("Script") and paintTool.Script:FindFirstChild("Event") or nil
	
	local shovelTool = findTool("Shovel")
	shovelEvent = shovelTool and shovelTool:FindFirstChild("Script") and shovelTool.Script:FindFirstChild("Event") or nil
	if not PermDel then
		local deleteTool = findTool("Delete")
		deleteEvent = deleteTool and deleteTool:FindFirstChild("Script") and deleteTool.Script:FindFirstChild("Event") or nil
	end
	]]
end

local function resetPaint()
	local char = plr.Character
	if not char then return end

	local backpack = plr.Backpack

	local function findTool(toolName)
		return char:FindFirstChild(toolName) or backpack:FindFirstChild(toolName)
	end
	local PaintTool = findTool("Paint")
	if PaintTool then
		local r = PaintTool:FindFirstChild("Script")
		if r then
			event = r:FindFirstChild("Event")
		end
	end
end

local function build(pos :Vector3)
	local char = plr.Character
	if not char then return end

	local buildTool = plr.Backpack:FindFirstChild("Build")
		or
		char:FindFirstChild("Build")

	if buildTool then
		buildTool.Script.Event:FireServer(
			workspace.Beach,
			Enum.NormalId.Top,
			vector.create(pos.X, pos.Y, pos.Z),
			"normal"
		)
	else
		warn("Not build tool!")
	end
end
local function dropDelete()
	local ogPos
	local char = plr.Character
	local deleteTool = plr.Backpack:FindFirstChild("Delete")
		or
		char:FindFirstChild("Delete")
	local buildTool = plr.Backpack:FindFirstChild("Build")
		or
		char:FindFirstChild("Build")
	local Positions = {
		CFrame.new(9150, 28270, -39794),
		CFrame.new(9146, 28270, -39794),
		CFrame.new(9146, 28270, -39790),
		CFrame.new(9142, 28270, -39794),
		CFrame.new(9150, 28270, -39790),
		CFrame.new(9142, 28270, -39786),
		CFrame.new(9142, 28270, -39790),
		CFrame.new(9146, 28270, -39786),
		CFrame.new(9150, 28270, -39786),
		CFrame.new(9154, 28274, -39794)
	}
	if deleteTool and buildTool then
		local root :Part = char:FindFirstChild("HumanoidRootPart")

		if root then
			ogPos = root.CFrame
			for i, pos in ipairs(Positions) do
				velocities = false
				char:PivotTo(pos)
				buildTool.Parent = char
				task.wait(0.2)

				build(pos.Position)

				task.wait(0.5)
			end

			char:PivotTo(CFrame.new(9144.86426, 28278.9961, -39784.5469, 0.684553802, 2.25997745e-08, -0.728962302, -1.23514603e-08, 1, 1.94036573e-08, 0.728962302, -4.27909885e-09, 0.684553802))
			task.wait(0.4)
			deleteTool.Parent = char
			task.wait(0.1)
			deleteTool.Parent = workspace
			task.wait()
			char:PivotTo(ogPos)
			velocities = true
			workspace.Gravity = 196.2
		end
	end
end



local function sneakyforceEquip(gear)
	local t = plr.Backpack:FindFirstChild(gear)
	if t then
		t.Parent = plr.Character
		t.Parent = plr.Backpack
		--	print("SET GEAR: ".. gear)
	end
	return t
end
local function forceEquip(gear)
	local t = plr.Backpack:FindFirstChild(gear)
	if t then
		t.Parent = plr.Character
		--	print("SET GEAR: ".. gear)
	end
	return t
end

local mode = "both \240\159\164\157"
---------------------------------------------------------------------------------------------------------------------
local Window = WindUI:CreateWindow({
	Title = "Hunter's GUI",
	Icon = "zap", -- lucide icon
	Author = "discord.gg/kHJmDy3SUY",
	Folder = "g",
	Transparent = true,
	Theme = "Dark",
	Resizable = true,
	SideBarWidth = 200,
	BackgroundImageTransparency = 0.42,
	HideSearchBar = true,
	ScrollBarEnabled = true,

	-- ↓ Optional. You can remove it.
    --[[ You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]]

	-- ↓ Optional. You can remove it.
	User = {
		Enabled = true,
		Anonymous = false,
		Callback = function()
		end,
	},
})

Window:Tag({
	Title = "v0.1.2",
	Icon = "lucide:badge-info",
	Color = Color3.fromHex("#3653d6"),
	Radius = 13, -- from 0 to 13
})

local Tab = Window:Tab({
	Title = "Home",
	Icon = "lucide:terminal", -- optional
	Locked = false,
})

local Button = Tab:Button({
	Title = "Load Infinite Yield",
	Desc = "Universal command script to help your exploiting experience",
	Locked = false,
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end
})
local Button = Tab:Button({
	Title = "Joinxl",
	Desc = "In case you cannot chat, or Roblox flagged you as a spammer",
	Locked = false,
	Callback = function()
		game.ReplicatedStorage.System:FireServer("xl")
	end
})

local Button = Tab:Button({
	Title = "Remove Bkit Text",
	Desc = "here u go bonerboa",
	Locked = false,
	Callback = function()
		forceEquip("Paint")

		local plr = game.Players.LocalPlayer
		local char = plr.Character
		local paintTool = plr.Backpack:FindFirstChild("Paint")
			or char:FindFirstChild("Paint")

		local brick = game.ReplicatedStorage:WaitForChild("Brick")
		local sides = {
			"Front",
			"Back",
			"Left",
			"Right",
			"Top",
			"Bottom"
		}
		WindUI:Notify({
			Title = "BKIT NOTICE",
			Content = "This will take 1.9 seconds! (depends on ping)",
			Duration = 1.8, -- 3 seconds
			Icon = "lucide:bell-ring",
		})

		if not brick then
			WindUI:Notify({
				Title = "BKIT NOTICE",
				Content = "Could not find Brick under RepStorage! Bkit broken?",
				Duration = 3, -- 3 seconds
				Icon = "lucide:ban",
			})

			return
		end

		brick.Parent = workspace

		local event = paintTool.Script.Event

		for i, v in ipairs(sides) do
			forceEquip("Paint")
			local args = {
				brick,
				Enum.NormalId[v], -- this is the side (value of table sides)
				char.HumanoidRootPart.Position,
				"both \240\159\164\157",
				Color3.new(0.753, 0.753, 0.753),
				"spray",
				""
			}
			event:FireServer(unpack(args))
			task.wait(0.2)
		end
		task.wait(0.5)
		local args = {
			brick,
			Enum.NormalId.Top,
			char.HumanoidRootPart.Position,
			"both \240\159\164\157",
			Color3.new(0.753, 0.753, 0.753),
			"plastic",
			""
		}
		event:FireServer(unpack(args))
		task.wait(0.2)
		if brick.Anchored == false then
			local args = {
				brick,
				Enum.NormalId.Top,
				char.HumanoidRootPart.Position,
				"both \240\159\164\157",
				Color3.new(0.753, 0.753, 0.753),
				"anchor",
				""
			}
			event:FireServer(unpack(args))
		end
		brick.Parent = game.ReplicatedStorage
		brick.CFrame = CFrame.new(brick.Position, brick.Position + Vector3.new(0,0,-1))

		WindUI:Notify({
			Title = "BKIT NOTICE",
			Content = "Bkit should be fixed now",
			Duration = 3, -- 3 seconds
			Icon = "lucide:badge-check",
		})

	end
})


local Dropdown = Tab:Dropdown({
	Title = "Material",
	Desc = "What to paint the target's material for stuff like rainbow paint?",
	Values = {"smooth", "plastic", "tiles", "bricks", "planks", "ice", "neon", "toxic", "anchor"},
	Value = "smooth",
	Callback = function(option) 

		currentMaterial = option

	end
})

local Toggle = Tab:Toggle({
	Title = "Rainbow paint",
	Desc = "Aim at a brick or the ground, and it'll paint that rainbow as long as you aim at it",
	Icon = "lucide:paintbrush",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		rainbow = state
	end
})

local Toggle = Tab:Toggle({
	Title = "Shovel",
	Desc = "Dig fast where you aim",
	Icon = "lucide:shovel",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		connections["Shovel"] = function()
			RunService.Heartbeat:Connect(function()
				local hitPos = mouse.Hit.Position
				direction = hitPos - origin

				if direction.Magnitude <= 0 then return end
				direction = direction.Unit * 1000

				local result = game.Workspace:Raycast(origin, direction, rayParams)

					if result then
						local args = {
							game.Workspace:WaitForChild("Beach"),
							Enum.NormalId.Top,
							result.Position,
							"dig"
						}
						shovelEvent:FireServer(unpack(args))
					end
			end)
		end
		shovel = state
	end
})

local Toggle = Tab:Toggle({
	Title = "Delete",
	Desc = "Delete at what you aim, from anywhere",
	Icon = "lucide:hammer",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		delete = state
	end
})

local Dropdown = Tab:Dropdown({
	Title = "Block trail type",
	Desc = "Small, or normal, or rainbow? (Use material to set block material at the very top)",
	Values = {"detailed", "normal", "rainbow detailed", "rainbow normal"},
	Value = "detailed",
	Multi = false,
	AllowNone = false,
	Callback = function(option) 
		currentBlockPathType = option[1]
	end
})

local Toggle = Tab:Toggle({
	Title = "Block trail",
	Desc = "Spawn a trail of blocks on you",
	Icon = "lucide:line-squiggle",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		detailedPath = state
	end
})

local Toggle = Tab:Toggle({
	Title = "Kill aura",
	Desc = "Automatically places detail toxic blocks inside people",
	Icon = "lucide:sword",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		ka = state
	end
})

local Tab = Window:Tab({
	Title = "OP",
	Icon = "lucide:gem", -- optional
	Locked = false,
})

local Input = Tab:Input({
	Title = "Brick Text",
	Desc = "After using this, every new brick will be created with the text",
	Value = "Default value",
	InputIcon = "lucide:italic",
	Type = "Input", -- or "Textarea"
	Placeholder = "Hello, world!",
	Callback = function(input) 
		currentRepStorageBrickText = input
	end
})

local Button = Tab:Button({
	Title = "Set brick text",
	Desc = "Read it",
	Locked = false,
	Callback = function()
		resetPaint()

		local player = game.Players.LocalPlayer
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local brick = game.ReplicatedStorage:FindFirstChild("Brick")
		if not brick then return end

		--hrp.Anchored = true

		forceEquip("Paint")

		local sides = {
			"Left",
			"Right",
			"Back",
			"Front",
			"Top",
			"Bottom"
		}

		for _, side in ipairs(sides) do
			brick.Position = hrp.Position
			RepStorageText(currentRepStorageBrickText, side)
			task.wait(0.15)
		end

	end
})

local Button = Tab:Button({
	Title = "Toxic brick",
	Desc = "Every new brick, becomes toxic",
	Locked = false,
	Callback = function()
		local repStorage = game.ReplicatedStorage:WaitForChild("Brick")
		forceEquip("Paint")
		resetPaint()
		event:FireServer(
			repStorage,
			"Front",
			vector.create(repStorage.Position.X, repStorage.Position.Y, repStorage.Position.Z),
			"both \240\159\164\157",
			Color3.new(1,1,1),
			"toxic",
			""
		)
	end
})

local Button = Tab:Button({
	Title = "Anchor brick",
	Desc = "Anchors or unanchors every new brick",
	Locked = false,
	Callback = function()
		local repStorage = game.ReplicatedStorage:WaitForChild("Brick")
		forceEquip("Paint")
		resetPaint()
		event:FireServer(
			repStorage,
			"Front",
			vector.create(repStorage.Position.X, repStorage.Position.Y, repStorage.Position.Z),
			"both \240\159\164\157",
			Color3.new(1,1,1),
			"anchor",
			""
		)
	end
})


local Button = Tab:Button({
	Title = "Break bkit",
	Desc = "Destroy bkit (THIS IS PERMANENT AND CANNOT BE REVERTED, USE AT RISK!)",
	Locked = false,
	Callback = function()
		local args = {
			game.ReplicatedStorage.Brick,
			game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
		}

		game.Players.LocalPlayer:WaitForChild("Backpack"):WaitForChild("Delete"):WaitForChild("Script"):WaitForChild("Event"):FireServer(unpack(args))

	end
})

local Toggle = Tab:Toggle({
	Title = "Perma delete enabled",
	Desc = "ggg",
	Icon = "lucide:shield-alert",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		PermDel = state
	end
})

local Button = Tab:Button({
	Title = "Perma save delete",
	Desc = "THIS REQUIRES BUILD & DELETE! ",
	Locked = false,
	Callback = function()
		dropDelete()
	end
})

local Button = Tab:Button({
	Title = "Delcubes all",
	Desc = "Delete, except with no limtied range and you just need the delete tool. Note: This wont stop until its finishde or you lose delete",
	Locked = false,
	Callback = function()
		local plr = game.Players.LocalPlayer

		for i, v in pairs(game.Workspace.Bricks:GetDescendants()) do
			if plr.Backpack:FindFirstChild("Delete") then plr.Backpack.Delete.Parent = plr.Character end
			if v:IsA("BasePart") then
				plr.Character.Delete.Script.Event:FireServer(v, plr.Character.HumanoidRootPart.Position)
				task.wait(0.05)
			end
		end
	end
})

local Tab = Window:Tab({
	Title = "Players",
	Icon = "lucide:users-round", -- optional
	Locked = false,
})
local showEnlightens = false
local showInvis = false
local Toggle = Tab:Toggle({
	Title = "Enlightened users ESP",
	Desc = "Anyone who has enlighten, will be highlighted blue",
	Icon = "lucide:flag",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		showEnlightens = state
	end
})
local Toggle = Tab:Toggle({
	Title = "Invisible users ESP",
	Desc = "This is best paired with enlightened users, because it cannot highlight invisible users but this can.",
	Icon = "lucide:flag",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		showInvis = state
	end
})

local function highlight(target, colour)
	local c :Player = target
	local character = c.Character
	if character then
		local highlight = character:FindFirstChild("enlightenHighlight")
		if not highlight then
			local newHighlight = Instance.new("Highlight", character)
			newHighlight.Name = "enlightenHighlight"
			newHighlight.FillColor = Color3.new(0, 0.733333, 1)
			newHighlight.FillTransparency = 0.5
		end
	end
end

local function invisibleAlert(target)
	local c :Player = target
	local character = c.Character
	if character then
		local function gui()
			local billboardui = Instance.new("BillboardGui", character)
			billboardui.Size = UDim2.new(0,200,0,50)
			billboardui.AlwaysOnTop = true
			billboardui.Name = "invis"
			local textLabel = Instance.new("TextLabel", billboardui)
			textLabel.Text = "(INVIS USER: ".. target.Name.. ")"
			textLabel.TextScaled = true

			textLabel.RichText = true -- extra bigger text
			textLabel.TextColor3 = Color3.fromRGB(255, 50, 0)
			textLabel.FontFace.Bold = true
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1,0,1,0)
		end
		local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
		if torso and torso.Transparency == 1 then

			gui()
		else
			local ui = character:FindFirstChild("invis")
			if ui then
				ui:Destroy()
			end
		end

	end
end
local function hasEnlighten(plr)
	if plr.Backpack and plr.Backpack:FindFirstChild("The Arkenstone") then
		return true
	end
	if plr.Character and plr.Character:FindFirstChild("The Arkenstone") then
		return true
	end
	return false
end
task.spawn(function()
	while task.wait(.5) do
		if showEnlightens or showInvis then
			for _, Player in ipairs(game.Players:GetPlayers()) do
				if Player ~= game.Players.LocalPlayer then
					if showEnlightens then
						local hasenli = hasEnlighten(Player)
						if hasenli then
							highlight(Player)
						end
					else
						for i, v in ipairs(highlights) do
							v:Destroy()
							table.remove(highlights, table.find(highlights, v))
						end

					end
					if showInvis then
						invisibleAlert(Player)
					end
				end
			end
		end
	end
end)

Tab:Divider()
local blacklistEnabled = false
local Toggle = Tab:Toggle({
	Title = "Blacklist enabled",
	Desc = "Punish blacklisted users when they join or if theyre in the server currently",
	Icon = "lucide:shield-alert",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		blacklistEnabled = state
	end
})

local blacklisted = {}



local convertedJson
local success, err = pcall(function()
	convertedJson = game:GetService("HttpService"):JSONDecode(readfile("blacklisted.json"))
end)

if success and convertedJson then
	for i, v in ipairs(convertedJson) do
		table.insert(blacklisted, v)
	end
	WindUI:Notify({
		Title = "Loaded blacklist save!",
		Content = "Save loaded without issue",
		Duration = 3, -- 3 seconds
		Icon = "lucide:file-check",
	})
else
	warn("No blacklisted.json, creating one")
	writefile("blacklisted.json", "[]")
end

local Dropdown = Tab:Dropdown({
	Title = "Blacklisted users",
	Desc = "Dropdown Description",
	Values = blacklisted,
	Value = blacklisted[1],
	Callback = function(option) 
	end
})

local Input = Tab:Input({
	Title = "Add user to blacklist",
	Desc = "Type the player's FULL user, NOT DISPLAY",
	Value = "Default value",
	InputIcon = "lucide:users-round",
	Type = "Input", -- or "Textarea"
	Placeholder = "Player123",
	Callback = function(input) 
		if game.Players:FindFirstChild(input) then
			table.insert(blacklisted, input)
			Dropdown:Refresh(blacklisted)
		end
	end
})
local toggledPunishes = {}

local Dropdown = Tab:Dropdown({
	Title = "Punishments",
	Desc = "Dropdown Description",
	Values = {"mute", "freeze", "glitch", "blind", "jail", "dumb", "speed 0"},
	Value = "mute",
	Multi = true,
	AllowNone = true,
	Callback = function(option)
		table.clear(toggledPunishes)
		for i, v in ipairs(option) do
			table.insert(toggledPunishes, v)
			--print(i, v)
		end
	end
})

local function punish(plr)
	for i, v in ipairs(toggledPunishes) do
		if v == "mute" then
			chatMessage("mute ".. plr.Name)
		elseif v == "freeze" then
			chatMessage("freeze ".. plr.Name)
		elseif v == "blind" then
			chatMessage("blind ".. plr.Name)
		elseif v == "glitch" then
			chatMessage("glitch ".. plr.Name)
		elseif v == "jail" then
			chatMessage("jail ".. plr.Name)
		elseif v == "dumb" then
			chatMessage("iq ".. plr.Name.. " 0")
		elseif v == "speed 0" then
			chatMessage("speed ".. plr.Name.. " 0")
		end
		task.wait(0.5)
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	if blacklistEnabled == true then
		for i, v in ipairs(blacklisted) do
			if plr.Name == v then
				plr.CharacterAdded:Wait()
				punish(plr)

			end
		end
	end
end)

local function convertToJson()
	local json = game:GetService('HttpService'):JSONEncode(blacklisted)
	if json then
		return json
	end
end
local Button = Tab:Button({
	Title = "Save blacklist",
	Desc = "Save the blacklisted players",
	Locked = false,
	Callback = function()
		for _, v in ipairs(blacklisted) do
			writefile("blacklisted.json", convertToJson())
		end
	end
})
local Buildaura = false
local SignAura = false
local PaintAura = false
local DeleteAura = false

local DeleteAuraRange = 20
local PaintAuraRange = 20
local Tab = Window:Tab({
	Title = "Auras (WIP)",
	Icon = "lucide:box", -- optional
	Locked = false,
})

local Toggle = Tab:Toggle({
	Title = "Build aura",
	Desc = "Place blocks around yourself",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		Buildaura = state
	end
})

local Toggle = Tab:Toggle({
	Title = "Delete aura",
	Desc = "Delete blocks around yourself",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		DeleteAura = state
	end
})

local Slider = Tab:Slider({
	Title = "Delete aura range",
	Desc = "How far blocks can be deleted",

	-- To make float number supported, 
	-- make the Step a float number.
	-- example: Step = 0.1
	Step = 1,
	Value = {
		Min = 5,
		Max = 500,
		Default = 20,
	},
	Callback = function(value)
		DeleteAuraRange = value
	end
})

local Toggle = Tab:Toggle({
	Title = "Sign aura",
	Desc = "Spam signs around you (best with unanchored in OP tab)",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		SignAura = state
	end
})

local Toggle = Tab:Toggle({
	Title = "Paint aura",
	Desc = "Spams rainbow paint around you",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state)
		PaintAura = state
	end
})

local Slider = Tab:Slider({
	Title = "Paint aura range",
	Desc = "How far blocks can be painted",

	-- To make float number supported, 
	-- make the Step a float number.
	-- example: Step = 0.1
	Step = 1,
	Value = {
		Min = 5,
		Max = 500,
		Default = 20,
	},
	Callback = function(value)
		PaintAuraRange = value
	end
})
local Tab = Window:Tab({
	Title = "Antis",
	Icon = "lucide:shield-x", -- optional
	Locked = false,
})
local AntiBlind = false
local AntiFog = false
local Antimyopic = false
local AntiJail = false
local Antifreeze = false
local FogDefault = 0.4

local blur = game.Lighting:WaitForChild("Blur")
local blind = plr.PlayerGui:WaitForChild("Blind")
local fog = game.Lighting:WaitForChild("Fog")
local function canCollideObj(obj)
	for _, part in ipairs(obj:GetDescendants()) do
		if part:IsA("Part") then
			part.CanCollide = not part.CanCollide
		end
	end
end
local Toggle = Tab:Toggle({
	Title = "Anti-blind",
	Desc = "Disables the blind overlay on your screen",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		AntiBlind = state
		blind.Enabled = state
	end
})
local Toggle = Tab:Toggle({
	Title = "Anti-Freeze",
	Desc = "Resets your character everytime you get frozen",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		Antifreeze = state
		if character:FindFirstChild("Hielo") and state == true then
			character:FindFirstChildOfClass("Humanoid").Health = 0
		end
	end
})
local Toggle = Tab:Toggle({
	Title = "Anti-jail",
	Desc = "Makes it so you can just walk out side of the jail",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		AntiJail = state
		if state == true then
			if character:FindFirstChild("Jail") and state == true then
				canCollideObj(character:FindFirstChild("Jail"))
			end
		end
	end
})
local Toggle = Tab:Toggle({
	Title = "Anti-myopic",
	Desc = "Disables the blur overlay on your screen",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		Antimyopic = state
		blur.Enabled = state
	end
})
local Toggle = Tab:Toggle({
	Title = "Anti-fog",
	Desc = "Removes the fog on your screen",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		AntiFog = state
		if state == true then
			fog.Density = FogDefault
		end
	end
})

local Tab = Window:Tab({
	Title = "Target",
	Icon = "lucide:users-round", -- optional
	Locked = false,
})

---------------------------- anti ---------------------------------------------------------------------------------------

blur:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Antimyopic then
		blur.Enabled = false
	end
end)
blind:GetPropertyChangedSignal("Enabled"):Connect(function()
	if AntiBlind then
		blind.Enabled = false
	end
end)
fog:GetPropertyChangedSignal("Density"):Connect(function()
	if AntiFog then
		fog.Density = FogDefault
	end
end)

character.ChildAdded:Connect(function(inst)

	if inst.Name == "Hielo" and Antifreeze then
		character:FindFirstChildOfClass("Humanoid").Health = 0
	elseif inst.Name == "Jail" and AntiJail then
		canCollideObj(inst)
	end
end)

---------------------------- anti ---------------------------------------------------------------------------------------

local existingUsers = {}
local target = ""
local targetDelcubes = false
for _, player in ipairs(game.Players:GetPlayers()) do
	--if player ~= plr then
	table.insert(existingUsers, player.Name)
	--end
end

local Dropdownf = Tab:Dropdown({
	Title = "Target User",
	Desc = "Which user to target",
	Values = existingUsers,
	Value = existingUsers[1],
	Callback = function(option) 
		target = game.Players:FindFirstChild(option) or ""
	end
})

game.Players.PlayerAdded:Connect(function(player)
	table.insert(existingUsers, player.Name)
	Dropdownf:Refresh(existingUsers)
end)
game.Players.PlayerRemoving:Connect(function(player)
	table.remove(existingUsers, table.find(existingUsers, player.Name))
	Dropdownf:Refresh(existingUsers)
end)

local Toggle = Tab:Toggle({
	Title = "Delcubes target (Tool)",
	Desc = "Using delete tool, delete the target's build",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		targetDelcubes = state
	end
})

task.spawn(function()
	while task.wait() do
		if targetDelcubes then
			local targ = target
			if targ then
				local cubes = workspace.Bricks:FindFirstChild(targ.Name)
				if cubes then
					for _, cube in cubes:GetChildren() do
						if not targetDelcubes then break end
						forceEquip("Delete")
						deleteEvent:FireServer(cube, plr.Character:FindFirstChild("HumanoidRootPart").Position)
					end
				end
			end
		end
	end
end)


local Tab = Window:Tab({
	Title = "Misc",
	Icon = "lucide:banana", -- optional
	Locked = false,
})
local antiGriefing = false

local Toggle = Tab:Toggle({
	Title = "Griefer detection",
	Desc = "This may be wrong! Fuck femboys.",
	Icon = "lucide:box",
	Type = "Checkbox",
	Value = false, -- default value
	Callback = function(state) 
		antiGriefing = state
	end
})

local tracked = {}

for _, part in ipairs(game.Workspace.Bricks:GetDescendants()) do
	if part:IsA("Part") then
		tracked[part] = {
			owner = part.Parent.Name
		}
	end
end

game.Workspace.Bricks.DescendantAdded:Connect(function(inst)
	if inst:IsA("Part") then
		local parent = inst.Parent
		if not parent then return end

		tracked[inst] = {
			owner = parent.Name
		}
	end

end)

game.Workspace.Bricks.DescendantRemoving:Connect(function(inst)

	if not antiGriefing then return end

	local info = tracked[inst]
	tracked[inst] = nil

	if not info then return end

	local ownerName = info.owner

	for _, plr in ipairs(game.Players:GetPlayers()) do
		if plr.Name == ownerName then continue end

		local char = plr.Character
		if not char then continue end

		local del = char:FindFirstChild("Delete")
		if not del then continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local brick = hrp:FindFirstChild("Brick")
		if not brick then continue end

		if brick.Playing then
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Possible griefer!",
				Text = plr.Name.." may be a griefer (DEL DETECTED)",
				Duration = 5
			})
		end
	end

end)


local Tab = Window:Tab({
	Title = "Configuration",
	Icon = "lucide:cog", -- optional
	Locked = false,
})

local Button = Tab:Button({
	Title = "DEBUG: Print event variables",
	Desc = "Check if all 4 events (paint, delete, build, shovel) exists",
	Locked = false,
	Callback = function()
		print("DELETE: "..deleteTool)
		print("PAINT: "..paintTool)
		print("BUILD: "..buildTool)
		print("SHOVEL: "..shovelTool)
	end
})



local Tab = Window:Tab({
	Title = "Credits",
	Icon = "lucide:form", -- optional
	Locked = false,
})

local Paragraph = Tab:Paragraph({
	Title = "Credits",
	Desc = [[
	XxHunterStormBytexX4 - Creator & Scripter
	ScullyLittleRaskul (Romeo) - Helper
	]],
	Color = "Grey",
	Image = "",
	ImageSize = 30,
	Thumbnail = "",
	ThumbnailSize = 80,
	Locked = false,
	Buttons = {
	}
})

local function getPositionAround(part, minRange, maxRange)
	local distance = math.random() * (maxRange - minRange) + minRange

	local theta = math.random() * math.pi * 2
	local phi = math.acos(2 * math.random() - 1) 

	local x = distance * math.sin(phi) * math.cos(theta)
	local y = distance * math.cos(phi)
	local z = distance * math.sin(phi) * math.sin(theta)

	return part.Position + Vector3.new(x, y, z)
end

local function getNearestPart(maxRange)
	local candidates = {}
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	for part in pairs(validParts) do
		if part:IsA("Part") then
			local d = (hrp.Position - part.Position).Magnitude
			if d <= maxRange then
				table.insert(candidates, part)
			end
		end
	end

	if #candidates == 0 then return end

	return candidates[math.random(1, #candidates)]
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { plr.Character }
local char = plr.Character or plr.characterAdded:Wait()

local function getNearestBlock(pos)
	local folder = game.Workspace:FindFirstChild("Bricks")
	if not folder then return end

	local playerFolder = folder:FindFirstChild(plr.Name)
	if not playerFolder then return end

	local nearest, nearestDist

	for _, p in ipairs(playerFolder:GetDescendants()) do
		if p:IsA("BasePart") then
			local d = (p.Position - pos).Magnitude
			if not nearestDist or d < nearestDist then
				nearest = p
				nearestDist = d
			end
		end
	end

	return nearest
end



task.spawn(function() -- velocities
	while true do

		task.wait()
		if velocities then continue end
		local root = plr.Character:WaitForChild('HumanoidRootPart')
		workspace.Gravity = 0
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		for _, v in ipairs(root:GetDescendants()) do
			if v:IsA("BodyVelocity")
				or v:IsA("AngularVelocity")
				or v:IsA("LinearVelocity")
				or v:IsA("VectorForce")
				or v:IsA("BodyAngularVelocity")
				or v:IsA("BodyForce")
				or v:IsA("BodyGyro")
				or v:IsA("BodyPosition")
				or v:IsA("BodyThrust")
			then
				v:Destroy()
			end
		end
	end
end)


local function normalToNormalId(n)
	local ax = math.abs(n.X)
	local ay = math.abs(n.Y)
	local az = math.abs(n.Z)

	if ay > ax and ay > az then
		return n.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom
	elseif ax > ay and ax > az then
		return n.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left
	else
		return n.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
	end
end


local function sprayNearbyBricks(hitPos, hitNormal, col, currentText)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { game.Workspace.Terrain }

	local parts = game.Workspace:GetPartBoundsInBox(
		CFrame.new(hitPos),
		Vector3.new(1, 1, 1),
		params
	)

	local normalId = normalToNormalId(hitNormal)
	if not normalId then return end

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			event:FireServer(
				part,
				normalId,
				vector.create(hitPos.X, hitPos.Y, hitPos.Z),
				"both \240\159\164\157",
				col,
				"spray",
				currentText
			)
		end
	end
end



local function getNearestHRP(position)
	--print("GetnearestHRP is running")
	local nearestHRP = nil
	local maxDistance = 20

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local humanoid = char:FindFirstChild("Humanoid")
			if humanoid.Health <= 0 then return end
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (hrp.Position - position).Magnitude
				if dist < maxDistance then
					maxDistance = dist
					nearestHRP = hrp

				end
			end
		end
	end
	--print(nearestHRP.Parent.Name, "is the nearestHRP")
	--	print(maxDistance)
	return nearestHRP
end

local deleteAuraBox
local function runDeleteClickAura(hitPos)
	if not DeleteClickAura or not hitPos then
		if deleteAuraBox then
			deleteAuraBox:Destroy()
			deleteAuraBox = nil
		end
		return
	end

	if not deleteAuraBox then
		deleteAuraBox = Instance.new("Part")
		deleteAuraBox.Size = Vector3.new(20, 20, 20)
		deleteAuraBox.Anchored = true
		deleteAuraBox.CanCollide = false
		deleteAuraBox.Transparency = 0.65
		deleteAuraBox.Color = Color3.fromRGB(255, 0, 0)
		deleteAuraBox.Material = Enum.Material.Neon
		deleteAuraBox.Name = "DeleteAura"
		deleteAuraBox.Parent = game.Workspace
	end

	deleteAuraBox.CFrame = CFrame.new(hitPos)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {deleteAuraBox}

	local parts = game.Workspace:GetPartBoundsInBox(deleteAuraBox.CFrame, deleteAuraBox.Size, overlapParams)

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") and part:IsDescendantOf(game.Workspace.Bricks) then
			deleteEvent:FireServer(part, part.Position)
		end
	end
end

-- SPRAYPAINT CLICK
mouse.Button1Down:Connect(function()
	if spraypaint then
		local origin = cam.CFrame.Position
		local hitPos = mouse.Hit.Position
		local direction = (hitPos - origin) * 500

		local result = game.Workspace:Raycast(origin, direction, rayParams)
		if not result then return end

		sprayNearbyBricks(
			result.Position,
			result.Normal,
			Color3.fromHSV(h, 1, 1),
			currentText
		)
	end
end)

local DCAPos
mouse.Button1Down:Connect(function()
	if not DeleteClickAura then return end

	local origin = cam.CFrame.Position
	local hitPos = mouse.Hit.Position
	local direction = (hitPos - origin) * 1000

	local result = game.Workspace:Raycast(origin, direction, rayParams)
	if not result then return end

	DCAPos = result.Position
end)


local function checkForTools()
	shovel = LocalPlayer.Character:FindFirstChild("Shovel")
	if not shovel then
		shovel = LocalPlayer.Backpack:FindFirstChild("Shovel")
	end
	delete = LocalPlayer.Character:FindFirstChild("Delete")
	if not delete then
		delete = LocalPlayer.Backpack:FindFirstChild("Delete")
	end
	paintTool = LocalPlayer.Character:FindFirstChild("Paint")
	if not paintTool then
		paintTool = LocalPlayer.Backpack:FindFirstChild("Paint")
	end
end

local function createToxicBlock(position)
	local nearest = getNearestHRP(position)
	if not nearest then return end

	local buildTool = sneakyforceEquip("Build")
	local paint = sneakyforceEquip("Paint")

	local scr = buildTool and buildTool:FindFirstChild("Script")
	if scr then
		local event = scr:FindFirstChild("Event")
		if event then
			local args = {game.Workspace.Beach, Enum.NormalId.Top, nearest.Position, "detailed"}
			event:FireServer(unpack(args))
		end
	end

	local bricksFolder = game.Workspace:WaitForChild("Bricks"):WaitForChild(plr.Name)
	local newBlock
	local conn
	conn = bricksFolder.ChildAdded:Connect(function(child)
		newBlock = child
		conn:Disconnect()
	end)
	repeat task.wait() until newBlock

	return newBlock
end
local function randomColor()
	return Color3.new(
		math.random(),
		math.random(),
		math.random()
	)
end
local paintDebounce = false
local unacnhorDebounce = false
-- TO PREVENT ROMEO GETTING ALL THE GOD DAMN ATTENTION!!
local function billboard(inst)
	local head = inst:FindFirstChild("Head")
	if not head then return end

	local bill = Instance.new("BillboardGui", head)
	bill.Size = UDim2.new(0, 300, 0, 50)
	bill.AlwaysOnTop = true
	bill.Adornee = inst
	bill.ExtentsOffsetWorldSpace = 
		Vector3.new(
			0, 1.5, 0
		)

	local label = Instance.new("TextLabel", bill)
	label.Size = UDim2.new(1,0,1,0)
	label.Text = "HunterStorm - Script Creator"
	label.TextScaled = true
	label.Font = Enum.Font.Arcade
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)

	local stroke = Instance.new("UIStroke", label)
end
game.Players.PlayerAdded:Connect(function(plrs)
	if plrs.Name == "XxHunterStormBytexX4" then
		plrs.CharacterAdded:Connect(function(char)
			billboard(char)
		end)
	end
end)
for _, plrs in ipairs(game.Players:GetPlayers()) do
	if plrs == plr then continue end
	if plrs.Name == "XxHunterStormBytexX4" then
		if plrs.Character then
			billboard(plrs.Character)
		end
		plrs.CharacterAdded:Connect(function(char)
			billboard(char)
		end)
	end
end

RunService.RenderStepped:Connect(function()
	refreshTools()

	h = h + 0.005
	if h > 1 then h = 0 end
	local col = Color3.fromHSV(h, 1, 1)
	local origin = cam.CFrame.Position
	local direction = Vector3.new()
	runDeleteClickAura(DCAPos)
	if detailedPath then
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local pathType = currentBlockPathType
		local isRainbowPath = pathType == "rainbow detailed" or pathType == "rainbow normal"

		if isRainbowPath or currentMaterial == "anchor" then
			forceEquip("Paint")
			forceEquip("Build")
			pathType = pathType:gsub("rainbow ","")
		end
		local args = {game.Workspace.Beach, Enum.NormalId.Top, hrp.Position, pathType}
		local buildTool = plr.Character:FindFirstChild("Build")
		if buildTool then
			local scr = buildTool:FindFirstChild("Script")
			if scr and scr:FindFirstChild("Event") then
				scr.Event:FireServer(unpack(args))
			end
		end

		if isRainbowPath and event or currentMaterial == "anchor" then
			local nearest = getNearestBlock(hrp.Position)
			if nearest then
				if currentMaterial == "anchor" then
					if nearest.Anchored == true then
						event:FireServer(
							nearest,
							normalToFace(nearest.Position),
							vector.create(nearest.Position.X, nearest.Position.Y, nearest.Position.Z),
							"both \240\159\164\157",
							col,
							"anchor",
							""
						)
					end
				else
					event:FireServer(
						nearest,
						normalToFace(nearest.Position),
						vector.create(nearest.Position.X, nearest.Position.Y, nearest.Position.Z),
						"both \240\159\164\157",
						col,
						currentMaterial,
						""
					)
				end

			end
		end
	end

	--if Buildaura or DeleteAura then
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if Buildaura or DeleteAura or PaintAura or SignAura then

		if Buildaura then

			forceEquip("Build")

			local buildTool = plr.Character:FindFirstChild("Build")
			if buildTool then
				local pos = getPositionAround(hrp, 5, 20)

				local args = {
					workspace.Terrain,
					Enum.NormalId.Top,
					pos,
					"normal"
				}

				buildTool.Script.Event:FireServer(unpack(args))
			end
		end

		if SignAura then

			forceEquip("Sign")

			local buildTool = plr.Character:FindFirstChild("Sign")
			if buildTool then
				local pos = getPositionAround(hrp, 3, 20)

				local args = {
					game.Workspace.Beach,
					Enum.NormalId.Top,
					pos,
					"normal"
				}

				buildTool.Script.Event:FireServer(unpack(args))
			end
		end

		if DeleteAura then

			--forceEquip("Delete")

			local block = getNearestPart(DeleteAuraRange)
			if block then
				local delArgs = {block, hrp.Position}
				deleteEvent:FireServer(unpack(delArgs))
			end
		end

		if PaintAura then
			if paintDebounce then return end

			forceEquip("Paint")

			local block = getNearestPart(PaintAuraRange)
			if block then
					--[[
					
					local args = {
	game.Workspace:WaitForChild("Bricks"):WaitForChild("XxHunterStormBytexX4"):WaitForChild("Brick"),
	Enum.NormalId.Top,
	vector.create(-11.131067276000977, 4.000000953674316, 34.25965118408203),
	"both \240\159\164\157",
	Color3.new(0.7686274647712708, 0.1568627506494522, 0.10980392247438431),
	"plastic",
	""
}
game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):WaitForChild("Paint"):WaitForChild("Script"):WaitForChild("Event"):FireServer(unpack(args))

					
					]]
				local col = randomColor()
				local paintArgs = {
					block,
					Enum.NormalId.Top,
					block.Position,
					"both \240\159\164\157",
					col,
					"plastic",
					""
				}

				plr.Character:FindFirstChild("Paint").Script.Event:FireServer(unpack(paintArgs))

			end
		end
	end
	--end

	if rainbow or rainbowSky or boxMode or selectedBlock or shovel or delete or spraypaint or ka then
		local hitPos = mouse.Hit.Position
		direction = hitPos - origin

		if direction.Magnitude <= 0 then return end
		direction = direction.Unit * 1000

		local result = game.Workspace:Raycast(origin, direction, rayParams)

		if shovel then
			if result then
				local args = {
					game.Workspace:WaitForChild("Beach"),
					Enum.NormalId.Top,
					result.Position,
					"dig"
				}
				shovelEvent:FireServer(unpack(args))
			end

		elseif ka == true then
			local character = plr.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local block = createToxicBlock(character.HumanoidRootPart.Position)
				event:FireServer(
					block,
					Enum.NormalId.Top,
					Vector3.new(block.Position.X, block.Position.Y, block.Position.Z),
					"both \240\159\164\157",
					Color3.new(0, 0, 0),
					"toxic",
					""
				)
			end
		elseif delete then
			if result then
				deleteEvent:FireServer(result.Instance, plr.Character:FindFirstChild("HumanoidRootPart").Position)
			end

		elseif rainbow and mouse.Target then
			event:FireServer(
				mouse.Target,
				normalToFace(mouse.Target.Position or Vector3.new(0,1,0)),
				hrp.Position,
				mode,
				col,
				currentMaterial,
				""
			)

		elseif rainbowSky then
			event:FireServer(
				Enum.NormalId.Right,
				vector.create(9468.4033203125, 3084.64111328125, 707.554443359375),
				mode,
				col,
				"neon",
				""
			)

		elseif selectedBlock then
			event:FireServer(
				block or (result and result.Instance) or game.Workspace.Beach,
				normalToFace(
					block and block.Position
						or result and result.Position
						or Vector3.new(0,1,0)
				),
				vector.create(hitPos.X, hitPos.Y, hitPos.Z),
				mode,
				col,
				currentMaterial,
				""
			)
		end
	end
end)

