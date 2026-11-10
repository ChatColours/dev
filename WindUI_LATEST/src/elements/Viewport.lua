local UserInputService = game:GetService("UserInputService")
local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}

function Element:New(Config)
	local Viewport = {
		__type = "Viewport",
		Interactive = Config.Interactive == true,
		Height = Config.Height or 200,
		Focused = Config.Focused ~= false,
		Clone = Config.Clone ~= false,
		MinZoom = Config.MinZoom or 1,
		MaxZoom = Config.MaxZoom or 100,
		ZoomSpeed = Config.ZoomSpeed or 2,
		RotationSpeed = Config.RotationSpeed or 0.01,
		Yaw = Config.Yaw or 0,
		Pitch = Config.Pitch or 0,
	}
	local Frame = New("ViewportFrame", {
		Name = "Viewport",
		Parent = Config.Parent,
		Size = UDim2.new(1, 0, 0, Viewport.Height),
		BorderSizePixel = 0,
		ThemeTag = {
			BackgroundColor3 = "ViewportBackground",
			BackgroundTransparency = "ViewportBackgroundTransparency",
		},
		Active = Viewport.Interactive,
		ClipsDescendants = true,
		Ambient = Config.Ambient or Color3.fromRGB(180, 180, 180),
		LightColor = Config.LightColor or Color3.new(1, 1, 1),
		LightDirection = Config.LightDirection or Vector3.new(-1, -1, -1),
	})
	local Main = Frame
	local World = New("WorldModel", { Parent = Frame })
	local Camera = Config.Camera and Config.Camera:Clone() or New("Camera", { FieldOfView = Config.FieldOfView or 70 })
	Camera.Parent = Frame
	Frame.CurrentCamera = Camera
	Viewport.Camera = Camera
	Viewport.WorldModel = World
	Viewport.Frame = Frame
	Viewport.Main = Main
	Viewport.ElementFrame = Main
	local Target = Vector3.zero
	local Distance = 8
	local Dragging = false
	local LastPosition
	local ActiveInput
	local PreviousScrolling
	local Connections = {}
	local function Connect(Signal, Callback)
		table.insert(Connections, Creator.AddSignal(Signal, Callback))
	end

	local function UpdateCamera()
		local Rotation = CFrame.fromOrientation(Viewport.Pitch, Viewport.Yaw, 0)
		Camera.CFrame = CFrame.lookAt(Target + Rotation.LookVector * Distance, Target)
		Camera.Focus = CFrame.new(Target)
	end
	local function SetScrolling(Enabled)
		local Container = Config.Tab and Config.Tab.UIElements and Config.Tab.UIElements.ContainerFrame
		if Container then
			if Enabled then
				if PreviousScrolling ~= nil then Container.ScrollingEnabled = PreviousScrolling end
				PreviousScrolling = nil
			elseif PreviousScrolling == nil then
				PreviousScrolling = Container.ScrollingEnabled
				Container.ScrollingEnabled = false
			end
		end
	end
	local function Inside(Position)
		local P, S = Frame.AbsolutePosition, Frame.AbsoluteSize
		return Position.X >= P.X and Position.X <= P.X + S.X
			and Position.Y >= P.Y and Position.Y <= P.Y + S.Y
	end
	local function Bounds(Object)
		if Object:IsA("BasePart") then
			return Object.CFrame, Object.Size
		elseif Object:IsA("Model") then
			return Object:GetBoundingBox()
		end
		return CFrame.new(), Vector3.one
	end
	function Viewport:Focus()
		if not Viewport.Object then return end
		local Box, Size = Bounds(Viewport.Object)
		Target = Box.Position
		local Radius = Size.Magnitude * 0.5
		local Field = math.rad(Camera.FieldOfView * 0.5)
		Distance = math.clamp(Radius / math.sin(Field) * (Config.FocusPadding or 1.25), Viewport.MinZoom, Viewport.MaxZoom)
		UpdateCamera()
	end
	function Viewport:SetObject(Object, ShouldClone)
		assert(Object == nil or Object:IsA("Model") or Object:IsA("BasePart"), "Viewport object must be a Model or BasePart")
		if Viewport.Object then
			if Viewport.OwnsObject then
				Viewport.Object:Destroy()
			else
				Viewport.Object.Parent = Viewport.OriginalParent
			end
		end
		Viewport.Object = nil
		if Object then
			local UseClone = ShouldClone
			if UseClone == nil then UseClone = Viewport.Clone end
			local DisplayObject = UseClone and Object:Clone() or Object
			assert(DisplayObject, "Viewport could not clone the object; check Archivable or use Clone = false")
			Viewport.OwnsObject = UseClone
			Viewport.OriginalParent = not UseClone and Object.Parent or nil
			DisplayObject.Parent = World
			Viewport.Object = DisplayObject
			if Viewport.Focused then Viewport:Focus() end
		end
		return Viewport
	end
	function Viewport:SetHeight(Height)
		Viewport.Height = Height
		Main.Size = UDim2.new(1, 0, 0, Height)
		return Viewport
	end
	function Viewport:SetCamera(NewCamera)
		assert(NewCamera and NewCamera:IsA("Camera"), "Viewport camera must be a Camera")
		if NewCamera == Camera then return Viewport end
		local DisplayCamera = NewCamera:Clone()
		assert(DisplayCamera, "Viewport could not clone the camera")
		if Camera then Camera:Destroy() end
		Camera = DisplayCamera
		Camera.Parent = Frame
		Frame.CurrentCamera = Camera
		Viewport.Camera = Camera
		UpdateCamera()
		return Viewport
	end
	function Viewport:SetInteractive(Value)
		Viewport.Interactive = Value == true
		Frame.Active = Viewport.Interactive
		if not Viewport.Interactive then
			Dragging = false
			SetScrolling(true)
		end
		return Viewport
	end
	function Viewport:SetZoom(Value)
		Distance = math.clamp(Value, Viewport.MinZoom, Viewport.MaxZoom)
		UpdateCamera()
		return Viewport
	end
	function Viewport:SetAngles(Yaw, Pitch)
		Viewport.Yaw = Yaw or Viewport.Yaw
		Viewport.Pitch = math.clamp(Pitch or Viewport.Pitch, -math.pi * 0.47, math.pi * 0.47)
		UpdateCamera()
		return Viewport
	end
	function Viewport:SetLighting(Ambient, LightColor, LightDirection)
		if Ambient then Frame.Ambient = Ambient end
		if LightColor then Frame.LightColor = LightColor end
		if LightDirection then Frame.LightDirection = LightDirection end
		return Viewport
	end
	Connect(Frame.InputBegan, function(Input)
		if not Viewport.Interactive then return end
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			ActiveInput = Input
			LastPosition = Input.Position
			SetScrolling(false)
		end
	end)
	Connect(UserInputService.InputChanged, function(Input)
		if not Viewport.Interactive or not Frame.Parent then return end
		if Dragging and LastPosition and
			(Input == ActiveInput or (ActiveInput and ActiveInput.UserInputType == Enum.UserInputType.MouseButton1
				and Input.UserInputType == Enum.UserInputType.MouseMovement)) then
			local Delta = Input.Position - LastPosition
			LastPosition = Input.Position
			Viewport:SetAngles(Viewport.Yaw - Delta.X * Viewport.RotationSpeed, Viewport.Pitch + Delta.Y * Viewport.RotationSpeed)
		end
	end)
	Connect(UserInputService.InputEnded, function(Input)
		if Input == ActiveInput or (ActiveInput and ActiveInput.UserInputType == Enum.UserInputType.MouseButton1
			and Input.UserInputType == Enum.UserInputType.MouseButton1) then
			Dragging = false
			ActiveInput = nil
			SetScrolling(true)
		end
	end)
	Connect(Frame.InputChanged, function(Input)
		if Viewport.Interactive and Input.UserInputType == Enum.UserInputType.MouseWheel then
			Viewport:SetZoom(Distance - Input.Position.Z * Viewport.ZoomSpeed)
		end
	end)
	Connect(UserInputService.TouchPinch, function(Positions, Scale, _, State)
		if not Viewport.Interactive or not Positions[1] or not Positions[2] then return end
		if State == Enum.UserInputState.Begin and Inside(Positions[1]) and Inside(Positions[2]) then
			Dragging = false
			Viewport.Pinching = true
			Viewport.PinchStartDistance = Distance
			SetScrolling(false)
		elseif Viewport.Pinching and State == Enum.UserInputState.Change then
			Viewport:SetZoom(Viewport.PinchStartDistance / math.max(Scale, 0.01))
		elseif State == Enum.UserInputState.End or State == Enum.UserInputState.Cancel then
			Viewport.Pinching = false
			SetScrolling(true)
		end
	end)
	function Viewport:Destroy()
		SetScrolling(true)
		for _, Connection in ipairs(Connections) do Connection:Disconnect() end
		if Viewport.Object and not Viewport.OwnsObject then
			Viewport.Object.Parent = Viewport.OriginalParent
		end
		Main:Destroy()
	end
	if Config.Object then Viewport:SetObject(Config.Object) else UpdateCamera() end
	return Viewport.__type, Viewport
end

return Element
