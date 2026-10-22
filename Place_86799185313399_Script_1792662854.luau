-- Script Path: game:GetService("Players").controllerBot10.PlayerScripts.Client.Controllers.VehicleController
-- Took 2.55s to decompile.
-- Executor: Wave (1.5.9)

local collectionService = game:GetService("CollectionService")
local contextActionService = game:GetService("ContextActionService")
local guiService = game:GetService("GuiService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local shared = replicatedStorage:WaitForChild("Shared")
local Constants = require(shared.Constants)
local GameConfig = require(shared.Config.GameConfig)
local VehicleConfig = require(shared.Config.VehicleConfig)
local Maid = require(shared.Utilities.Maid)
local Net = require(shared.Net)
local SoundUtil = require(shared.Utilities.SoundUtil)
local VehiclePhysics = require(shared.Utilities.VehiclePhysics)
local ui = script.Parent.Parent:WaitForChild("UI")
local Components = require(ui.Components)
local Keys = require(ui.Keys)
local Pad = require(ui.Pad)
local Theme = require(ui.Theme)
local PhoneLayout = require(ui.PhoneLayout)
local attributes = Constants.Attributes
local vehicle = Constants.Tags.Vehicle
local keys = VehicleConfig.Keys
local gamepad = VehicleConfig.Gamepad
local nativeELS = VehicleConfig.NativeELS
local color = Color3.fromRGB(205, 45, 45)
local color2 = Color3.fromRGB(45, 110, 220)
local speedToMph = VehicleConfig.SpeedToMph
local color3 = Color3.fromRGB(230, 60, 50)
local color4 = Color3.fromRGB(42, 150, 84)
local color5 = Color3.fromRGB(255, 176, 46)
local color3FromRGB6 = Color3.fromRGB
local data = {
    Width = 176,
    Height = 112,
    Diameter = 132,
    Thickness = 5,
    Top = 14,
    KeysWidth = 250,
    Sign = color3FromRGB6(242, 242, 238),
}
local hud = VehicleConfig.Hud
local vector2New = Vector2.new
local data2 = {
    Gap = 6,
    Pad = 14,
    Footer = 14,
    Cell = vector2New(56, 46),
}
data2.Housing = Color3.fromRGB(24, 24, 26)
data2.Key = Color3.fromRGB(21, 21, 23)
data2.Knob = Color3.fromRGB(196, 196, 202)
data2.Ink = Color3.fromRGB(244, 244, 240)
local vector2New2 = Vector2.new
local data3 = {
    Arrow = 92,
    Pill = 38,
    Phone = 500,
    Tablet = 1.3,
    Feed = 220,
    FeedGap = 16,
    Gap = 10,
    Edge = 16,
    Foot = 14,
    Clear = 150,
    ToolBar = 78,
    Slide = 6,
    KeyGap = 6,
    Text = 12,
    KeyText = 12,
    Panel = 1.35,
    PanelLeast = 0.85,
    CarShape = 1.3,
    CarLeast = 90,
    Gas = vector2New2(84, 96),
}
data3.Brake = Vector2.new(100, 78)
data3.Least = Vector2.new(62, 56)
data3.Key = Vector2.new(84, 52)
data3.KeyLeast = Vector2.new(56, 44)
data3.Plate = Color3.fromRGB(58, 60, 66)
data3.Rim = Color3.fromRGB(196, 198, 206)
data3.Rubber = Color3.fromRGB(16, 16, 18)
data3.Rib = Color3.fromRGB(92, 94, 102)
local color6 = Color3.fromRGB(18, 18, 21)
local color7 = Color3.fromRGB(214, 69, 69)
local color3FromRGB17 = Color3.fromRGB
local data4 = {Headlights = color3FromRGB17(5, 128, 248)}
data4.Hazard = Color3.fromRGB(240, 170, 40)
data4.IndicatorLeft = Color3.fromRGB(240, 170, 40)
data4.IndicatorRight = Color3.fromRGB(240, 170, 40)
local localPlayer = players.LocalPlayer
local function keyName(data)
    local data2 = data and data[1]
    if data2 then
        return data2.Name
    end
    return "?"
end

local config = {
    LeftBracket = "[",
    RightBracket = "]",
    Comma = ",",
    Period = ".",
    Minus = "-",
    Equals = "=",
}
local function shortKey(object)
    return config[object.Name] or object.Name
end

local function chassisOf(object)
    local chassis = object:FindFirstChild("Chassis") or object:FindFirstChild("DriveSeat")
    if chassis and chassis:IsA("BasePart") then
        return chassis
    end
    return nil
end

local function uprightAt(object, object2, vector)
    local cFrameLookVector2 = object2.CFrame.LookVector * vector.create(1, 0, 1)
    if cFrameLookVector2.Magnitude < 0.1 then
        cFrameLookVector2 = vector.create(0, 0, -1)
    end
    cFrameLookVector2 = CFrame.lookAt(vector, vector + cFrameLookVector2.Unit)
    return cFrameLookVector2 * object2.CFrame:ToObjectSpace(object:GetPivot())
end

local function isMap(object)
    if object:IsA("Terrain") then
        return true
    end
    if not object:IsA("BasePart") or not object.Anchored then
        return false
    end
    local ancestor = object:FindFirstAncestorOfClass("Model")
    while ancestor do
        if collectionService:HasTag(ancestor, vehicle) or ancestor:FindFirstChildOfClass("Humanoid") then
            return false
        end
        ancestor = ancestor:FindFirstAncestorOfClass("Model")
    end
    return true
end

local function speedLimitAt(vector)
    for key, value in VehicleConfig.Radar.SpeedZones do
        if (value.Centre - vector).Magnitude <= value.Radius then
            return value.Limit
        end
    end
    return VehicleConfig.Radar.DefaultSpeedLimit
end

local function init(data, arg2)
    data.Registry = arg2
    data._seatMaid = Maid.new()
    data._characterMaid = Maid.new()
    data._vehicle = nil
    data._role = nil
    data._physics = nil
    data._handbrake = false
    data._radarOn = hud.RadarShown
    data._reads = {}
    data:_buildHud()
end

local data5 = {Name = "VehicleController", Init = init}
function data5:Start()
    Net.Connect("Vehicles", "ALPR", function(arg1)
        if type(arg1) == "table" then
            self:_onALPR(arg1)
        end
    end)
    localPlayer.CharacterAdded:Connect(function(arg1)
        self:_watchCharacter(arg1)
    end)
    if localPlayer.Character then
        self:_watchCharacter(localPlayer.Character)
    end
    Pad.Changed:Connect(function()
        self:_padHints()
    end)
    self:_padHints()
end

function data5:GetVehicle()
    return self._vehicle
end

function data5:IsDriving()
    return self._role == "Driver"
end

function data5:GetControls()
    return self._controls
end

function data5:GetPad()
    return self._pad or {}
end

function data5:_watchCharacter(object)
    self._characterMaid:Cleanup()
    self:_leave()
    local humanoid = object:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end
    local function update()
        local seatPart = humanoid.SeatPart
        local seatPart2 = seatPart and seatPart:FindFirstAncestorOfClass("Model")
        while seatPart2 do
            if collectionService:HasTag(seatPart2, vehicle) then
                break
            end
            seatPart2 = seatPart2:FindFirstAncestorOfClass("Model")
        end
        if seatPart and seatPart2 then
            self:_enter(seatPart2, seatPart)
        else
            self:_leave()
        end
    end

    self._characterMaid:Give((humanoid:GetPropertyChangedSignal("SeatPart")):Connect(update))
    update()
end

function data5:_enter(object, object2)
    if self._vehicle == object and self._seat == object2 then
        return
    end
    self:_leave()
    local attribute = object2:GetAttribute(attributes.SeatRole) or "Passenger"
    local attribute2 = VehicleConfig.Vehicles[object:GetAttribute(attributes.VehicleType) or ""]
    self._vehicle = object
    self._seat = object2
    self._role = attribute
    self._definition = attribute2
    local _seatMaid = self._seatMaid
    local attribute22 = attribute2 and attribute2.Equipment or {}
    local condition = attribute2 ~= nil and attribute2.Kind == "Police"
    local result = condition
    if result then
        result = attribute22.Lights == true and attribute22.Siren == true
    end
    self._emergency = result
    if condition and (attribute == "Driver" or attribute == "Passenger") then
        self._mdtGui.Enabled = true
        _seatMaid:Give(function()
            self._mdtGui.Enabled = false
        end)
    end
    if object:GetAttribute("NativeChassis") then
        self:_enterNative(object, object2, attribute, condition)
    else
        local data2 = {}
        local data3 = {}
        if attribute == "Driver" then
            local vehiclePhysics = VehiclePhysics.new(object, attribute2 and attribute2.Handling)
            self._physics = vehiclePhysics
            _seatMaid:Give(function()
                if vehiclePhysics then
                    vehiclePhysics:Rest()
                end
            end)
            local tryGet = self.Registry:TryGet("VehicleEffectsController")
            if tryGet then
                tryGet:SetLocalVehicle(object, vehiclePhysics)
                _seatMaid:Give(function()
                    tryGet:SetLocalVehicle(nil)
                end)
            end
            self:_touchDrive(object2, _seatMaid, false)
            local chassis = object:FindFirstChild("Chassis")
            local preSimulation = runService.PreSimulation
            local config = {Throttle = 0, Steer = 0, Handbrake = false}
            local function callback(arg1)
                if not vehiclePhysics or (not chassis or not chassis.Parent) then
                    return
                end
                if chassis.ReceiveAge ~= 0 then
                    return
                end
                local object22 = object2
                config.Throttle = object22.ThrottleFloat
                config.Steer = object22.SteerFloat
                local _drive = self._drive
                if _drive then
                    local config2 = config
                    local throttle = config.Throttle + _drive.Throttle - _drive.Brake
                    config2.Throttle = math.clamp(throttle, -1, 1)
                    local config3 = config
                    local steer = config.Steer + _drive.Steer
                    config3.Steer = math.clamp(steer, -1, 1)
                end
                config.Handbrake = self._handbrake
                vehiclePhysics:SetFlatMask(object:GetAttribute(attributes.FlatTyres))
                vehiclePhysics:Step(arg1, config)
                self:_autoTick()
            end

            _seatMaid:Give(preSimulation:Connect(callback))
            if vehiclePhysics and chassis then
                preSimulation, callback = object, vehiclePhysics
                self:_watchVehicle(preSimulation, chassis, callback)
            end
            self:_bind("PatrolVehHandbrake", keys.Handbrake, function(arg1)
                self._handbrake = arg1 == Enum.UserInputState.Begin
            end, true)
            local function down()
                self._handbrake = true
            end

            local data4 = {Down = down}
            function data4.Up()
                self._handbrake = false
            end

            data3.Handbrake = data4
            local function headlights()
                Net.Fire("Vehicles", "SetState", "Headlights", not object:GetAttribute(attributes.Headlights))
            end

            local function horn(flag)
                Net.Fire("Vehicles", "SetState", "Horn", flag)
            end

            local function lock()
                local invoke2 = Net.Invoke("Vehicles", "ToggleLock")
                self:_toast(if invoke2.Success then "Info" else "Warning", invoke2.Message or "")
            end

            self:_bind("PatrolVehHeadlights", keys.Headlights, function(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    Net.Fire("Vehicles", "SetState", "Headlights", not object:GetAttribute(attributes.Headlights))
                end
            end)
            self:_bind("PatrolVehHorn", keys.Horn, function(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    Net.Fire("Vehicles", "SetState", "Horn", true)
                elseif arg1 == Enum.UserInputState.End or arg1 == Enum.UserInputState.Cancel then
                    Net.Fire("Vehicles", "SetState", "Horn", false)
                end
            end)
            self:_bind("PatrolVehReset", if result then VehicleConfig.EmergencyKeys.Reset else keys.Reset, function(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    self:_resetVehicle(object, chassis)
                end
            end)
            self:_bind("PatrolVehLock", keys.Lock, function(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    local invoke2 = Net.Invoke("Vehicles", "ToggleLock")
                    self:_toast(if invoke2.Success then "Info" else "Warning", invoke2.Message or "")
                end
            end)
            local data5 = {Key = keys.Headlights[1]}
            data5.Down = headlights
            data2.Headlights = data5
            local data6 = {Key = keys.Horn[1]}
            function data6.Down()
                Net.Fire("Vehicles", "SetState", "Horn", true)
            end

            function data6.Up()
                Net.Fire("Vehicles", "SetState", "Horn", false)
            end

            data2.Horn = data6
            local data7 = {Key = keys.Lock[1]}
            data7.Down = lock
            data2.Lock = data7
            data2.Airhorn = data2.Horn
            local function down3()
                self:_resetVehicle(object, chassis)
            end

            data2.Reset = {Down = down3}
            data3.Horn = data2.Horn
            if not result and not attribute22.Radar then
                for key, value in {"IndicatorLeft", "Hazard", "IndicatorRight"} do
                    local value2 = VehicleConfig.NativeLights.Keys[value]
                    local value3 = value
                    local function press()
                        Net.Fire("Vehicles", "SetState", value3, object:GetAttribute(value3) ~= true)
                    end

                    self:_bind("PatrolVeh" .. value3, value2, function(arg1)
                        if arg1 == Enum.UserInputState.Begin then
                            Net.Fire("Vehicles", "SetState", value3, object:GetAttribute(value3) ~= true)
                        end
                    end)
                    local data9 = {Key = if value2 then value2[1] else nil}
                    data9.Down = press
                    data2[value3] = data9
                end
            end
        end
        if condition and (attribute == "Driver" or attribute == "Passenger") then
            if result then
                self:_emergencyControls(object, data2, data3)
            end
            if attribute22.Lights and not result then
                local function nextStage()
                    local attribute = (object:GetAttribute(attributes.LightStage) or 0) + 1
                    if #VehicleConfig.LightStages < attribute then
                        attribute = 0
                    end
                    Net.Fire("Vehicles", "SetState", "LightStage", attribute)
                end

                self:_bind("PatrolVehLights", keys.Lights, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        local attribute = (object:GetAttribute(attributes.LightStage) or 0) + 1
                        if #VehicleConfig.LightStages < attribute then
                            attribute = 0
                        end
                        Net.Fire("Vehicles", "SetState", "LightStage", attribute)
                    end
                end, false, "Lights")
                local data10 = {Key = keys.Lights[1]}
                data10.Down = nextStage
                data10.Max = #VehicleConfig.LightStages
                data2.Stage = data10
                self:_padStage(object, data2, data3)
            end
            if attribute22.Siren and not result then
                local function siren()
                    Net.Fire("Vehicles", "SetState", "Siren", not object:GetAttribute(attributes.SirenOn))
                end

                local function nextTone()
                    local tones = VehicleConfig.Siren.Tones
                    local attribute = object:GetAttribute(attributes.SirenTone)
                    local tones2 = tones
                    local total = 1
                    for key, value in tones2 do
                        if value.Id ~= attribute then
                            continue
                        end
                        total = key % #tones + 1
                    end
                    Net.Fire("Vehicles", "SetState", "SirenTone", tones[total].Id)
                end

                self:_bind("PatrolVehSiren", keys.Siren, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        Net.Fire("Vehicles", "SetState", "Siren", not object:GetAttribute(attributes.SirenOn))
                    end
                end, false, "Siren")
                self:_bind("PatrolVehTone", keys.Tone, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        nextTone()
                    end
                end)
                local data11 = {Key = keys.Siren[1]}
                data11.Down = siren
                data2.Siren = data11
                local data12 = {Key = keys.Tone[1]}
                data12.Down = nextTone
                data2.Tone = data12
                local siren3 = data2.Siren
                local tone2 = data2.Tone
                data3.Siren = siren3
                data3.Tone = tone2
            end
            if attribute22.Spotlight then
                local function spotlight()
                    Net.Fire("Vehicles", "SetState", "Spotlight", not object:GetAttribute(attributes.Spotlight))
                end

                self:_bind("PatrolVehSpotlight", keys.Spotlight, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        Net.Fire("Vehicles", "SetState", "Spotlight", not object:GetAttribute(attributes.Spotlight))
                    end
                end)
                local data13 = {Key = keys.Spotlight[1]}
                data13.Down = spotlight
                data2.Spotlight = data13
            end
            if attribute22.Radar then
                local function radar()
                    self:_setRadarShown(not self._radarOn)
                end

                self:_bind("PatrolVehRadar", keys.Radar, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        self:_setRadarShown(not self._radarOn)
                    end
                end)
                local data14 = {Key = keys.Radar[1]}
                data14.Down = radar
                data2.Radar = data14
                data3.Radar = data2.Radar
            end
        end
        self:_bindPad(data3)
        self._controls = if next(data2) then data2 else nil
        if attribute == "Rear" then
            local contextActionService2 = contextActionService
            local value4 = Enum.ContextActionPriority.High.Value + 50
            local space = Enum.KeyCode.Space
            local buttonA = Enum.KeyCode.ButtonA
            contextActionService2:BindActionAtPriority("PatrolVehNoExit", function()
                if object2:GetAttribute(attributes.SeatLocked) then
                    return Enum.ContextActionResult.Sink
                end
                return Enum.ContextActionResult.Pass
            end, false, value4, space, buttonA)
            _seatMaid:Give(function()
                contextActionService:UnbindAction("PatrolVehNoExit")
            end)
        end
        if attribute == "Driver" or condition and attribute == "Passenger" then
            self._hud.Enabled = true
            self._speedo.Visible = true
            self:_setKeyHelp(self:_keyHelp(condition, attribute22, attribute))
            if condition then
                self:_showSirenBox(if result then hud.SirenBox.Emergency else hud.SirenBox.Standard, data2)
            end
            local renderStepped = runService.RenderStepped
            local function callback2()
                self:_updateHud()
            end

            _seatMaid:Give(renderStepped:Connect(callback2))
            _seatMaid:Give(function()
                self._hud.Enabled = false
                self._speedo.Visible = false
                self:_hideSirenBox()
            end)
        end
    end
end

function data5._padStage(data, object, arg3, data2)
    local function step(number)
        local attribute = object:GetAttribute(attributes.LightStage) or 0
        local attribute2 = attribute + number
        local count = #VehicleConfig.LightStages
        local number2 = math.clamp(attribute2, 0, count)
        if number2 ~= attribute then
            Net.Fire("Vehicles", "SetState", "LightStage", number2)
        end
    end

    data2.Stage = arg3.Stage
    local function down()
        local attribute = object:GetAttribute(attributes.LightStage) or 0
        local attribute2 = attribute + 1
        local count = #VehicleConfig.LightStages
        local number = math.clamp(attribute2, 0, count)
        if number ~= attribute then
            Net.Fire("Vehicles", "SetState", "LightStage", number)
        end
    end

    data2.StageUp = {Down = down}
    local function down2()
        local attribute = object:GetAttribute(attributes.LightStage) or 0
        local attribute2 = attribute + -1
        local count = #VehicleConfig.LightStages
        local number = math.clamp(attribute2, 0, count)
        if number ~= attribute then
            Net.Fire("Vehicles", "SetState", "LightStage", number)
        end
    end

    data2.StageDown = {Down = down2}
end

function data5:_emergencyControls(object, data2, data3)
    local emergencyKeys = VehicleConfig.EmergencyKeys
    local function nextStage()
        local attribute = (object:GetAttribute(attributes.LightStage) or 0) + 1
        if #VehicleConfig.LightStages < attribute then
            attribute = 0
        end
        Net.Fire("Vehicles", "SetState", "LightStage", attribute)
    end

    self:_bind("PatrolVehLights", emergencyKeys.Stage, function(arg1)
        if arg1 == Enum.UserInputState.Begin then
            local attribute = (object:GetAttribute(attributes.LightStage) or 0) + 1
            if #VehicleConfig.LightStages < attribute then
                attribute = 0
            end
            Net.Fire("Vehicles", "SetState", "LightStage", attribute)
        end
    end, false, "Lights")
    local data4 = {Key = emergencyKeys.Stage[1]}
    data4.Down = nextStage
    data4.Max = #VehicleConfig.LightStages
    data2.Stage = data4
    self:_padStage(object, data2, data3)
    local function down()
        Net.Fire("Vehicles", "SetState", "Siren", object:GetAttribute(attributes.SirenOn) ~= true)
    end

    data3.Siren = {Down = down}
    local function down2()
        local tones = VehicleConfig.Siren.Tones
        local object2 = object
        local sirenOn = attributes.SirenOn
        local value = 1
        if object2:GetAttribute(sirenOn) == true then
            for key, value2 in tones do
                if value2.Id ~= object:GetAttribute(attributes.SirenTone) then
                    continue
                end
                value = key % #tones + 1
            end
        end
        Net.Fire("Vehicles", "SetState", "SirenTone", tones[value].Id)
        Net.Fire("Vehicles", "SetState", "Siren", true)
    end

    data3.Tone = {Down = down2}
    for key, value in VehicleConfig.Siren.Tones do
        local value2 = value
        local function press()
            if object:GetAttribute(attributes.SirenOn) == true then
                if object:GetAttribute(attributes.SirenTone) == value2.Id then
                    Net.Fire("Vehicles", "SetState", "Siren", false)
                    return
                end
            end
            Net.Fire("Vehicles", "SetState", "SirenTone", value2.Id)
            Net.Fire("Vehicles", "SetState", "Siren", true)
        end

        local id = emergencyKeys[value2.Id]
        local text = "PatrolVehTone" .. value2.Id
        local id2 = id
        local siren = if value2.Id == "Wail" then "Siren" else nil
        self:_bind(text, id2, function(arg1)
            if arg1 == Enum.UserInputState.Begin then
                press()
            end
        end, false, siren)
        local id3 = value2.Id
        local data7 = {Key = if id then id[1] else nil}
        data7.Down = press
        data2[id3] = data7
    end
    local function manual(flag)
        Net.Fire("Vehicles", "SetState", "SirenManual", flag)
    end

    self:_bind("PatrolVehManual", emergencyKeys.Manual, function(arg1)
        if arg1 == Enum.UserInputState.Begin then
            Net.Fire("Vehicles", "SetState", "SirenManual", true)
        elseif arg1 == Enum.UserInputState.End or arg1 == Enum.UserInputState.Cancel then
            Net.Fire("Vehicles", "SetState", "SirenManual", false)
        end
    end)
    local data8 = {Key = emergencyKeys.Manual[1]}
    function data8.Down()
        Net.Fire("Vehicles", "SetState", "SirenManual", true)
    end

    function data8.Up()
        Net.Fire("Vehicles", "SetState", "SirenManual", false)
    end

    data2.Manual = data8
    for key2, value3 in {"IndicatorLeft", "Hazard", "IndicatorRight"} do
        local value32 = VehicleConfig.NativeLights.Keys[value3]
        local value33 = value3
        local function press2()
            Net.Fire("Vehicles", "SetState", value33, object:GetAttribute(value33) ~= true)
        end

        self:_bind("PatrolVeh" .. value33, value32, function(arg1)
            if arg1 == Enum.UserInputState.Begin then
                Net.Fire("Vehicles", "SetState", value33, object:GetAttribute(value33) ~= true)
            end
        end)
        local data9 = {Key = if value32 then value32[1] else nil}
        data9.Down = press2
        data2[value33] = data9
    end
end

function data5:_enterNative(object, object2, text, flag)
    local _seatMaid = self._seatMaid
    if text == "Rear" then
        local contextActionService2 = contextActionService
        local value = Enum.ContextActionPriority.High.Value + 50
        local space = Enum.KeyCode.Space
        local buttonA = Enum.KeyCode.ButtonA
        contextActionService2:BindActionAtPriority("PatrolVehNoExit", function()
            if object2:GetAttribute(attributes.SeatLocked) then
                return Enum.ContextActionResult.Sink
            end
            return Enum.ContextActionResult.Pass
        end, false, value, space, buttonA)
        _seatMaid:Give(function()
            contextActionService:UnbindAction("PatrolVehNoExit")
        end)
    else
        if text ~= "Driver" and not flag then
            return
        end
        local body = object:FindFirstChild("Body") and object.Body:FindFirstChild("Lightbar")
        local body2 = body and body:FindFirstChild("Events")
        local result = flag
        if result then
            result = text == "Driver" and body2 ~= nil
        end
        self._hud.Enabled = true
        local _speedo = self._speedo
        _speedo.Visible = true
        self:_setKeyHelp("")
        _seatMaid:Give(function()
            self._hud.Enabled = false
            self._speedo.Visible = false
            self:_hideSirenBox()
        end)
        if text == "Driver" then
            self:_touchDrive(object2, _seatMaid, true)
        end
        self:_moveCarGuis(_seatMaid)
        local renderStepped = runService.RenderStepped
        local function callback()
            self:_updateNative(object)
            self:_autoTick()
        end

        _seatMaid:Give(renderStepped:Connect(callback))
        if text == "Driver" then
            local chassis = object:FindFirstChild("Chassis") or object:FindFirstChild("DriveSeat")
            if chassis and chassis:IsA("BasePart") then
                _speedo = chassis
            else
                _speedo = nil
            end
        else
            _speedo = nil
        end
        if _speedo then
            local object3 = object
            local _speedo2 = _speedo
            self:_watchVehicle(object3, _speedo2, nil)
            self:_bind("PatrolVehReset", VehicleConfig.EmergencyKeys.Reset, function(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    local object2 = object
                    local _speedo2 = _speedo
                    self:_resetVehicle(object2, _speedo2)
                end
            end)
            self:_padChassis(_seatMaid)
        end
        if not flag then
            return
        end
        local function down()
            self:_setRadarShown(not self._radarOn)
        end

        local data2 = {Down = down}
        local data3 = {Radar = data2}
        local data4 = {Radar = data3.Radar}
        if _speedo then
            local function down2()
                local object2 = object
                local _speedo2 = _speedo
                self:_resetVehicle(object2, _speedo2)
            end

            data3.Reset = {Down = down2}
        end
        if result then
            local data6 = {Model = object}
            data6.Lightbar = body
            data6.Events = body2
            self._elsCar = data6
            _seatMaid:Give(function()
                self._elsCar = nil
                for key, value in nativeELS.Hold do
                    if self._holding and self._holding[value.Id] then
                        self:_elsHold(value.Id, false)
                    end
                end
            end)
            local values = body:FindFirstChild("Values")
            for key, value2 in nativeELS.Lights do
                if not values or values:FindFirstChild(value2.Id) then
                    local value22 = value2
                    local function press()
                        self:_elsLight(value22)
                    end

                    self:_bind("PatrolELS" .. value22.Id, {value22.Key}, function(arg1)
                        if arg1 == Enum.UserInputState.Begin then
                            self:_elsLight(value22)
                        end
                    end)
                    if value22.Id == nativeELS.Stage then
                        local data7 = {Key = value22.Key}
                        data7.Down = press
                        data7.Max = value22.Max
                        data3.Stage = data7
                        data4.Stage = data3.Stage
                        local function down3()
                            self:_elsStage(value22, 1)
                        end

                        data4.StageUp = {Down = down3}
                        local function down4()
                            self:_elsStage(value22, -1)
                        end

                        data4.StageDown = {Down = down4}
                    else
                        local id2 = value22.Id
                        local data10 = {Key = value22.Key}
                        data10.Down = press
                        data3[id2] = data10
                    end
                end
            end
            for key2, value3 in nativeELS.Sirens do
                local value32 = value3
                local function press2()
                    self:_elsSiren(value32.Id)
                end

                self:_bind("PatrolELS" .. value32.Id, {value32.Key}, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        self:_elsSiren(value32.Id)
                    end
                end)
                local id3 = value32.Id
                local data11 = {Key = value32.Key}
                data11.Down = press2
                data3[id3] = data11
            end
            local function down5()
                self:_elsSirenStep(false)
            end

            data4.Siren = {Down = down5}
            local function down6()
                self:_elsSirenStep(true)
            end

            data4.Tone = {Down = down6}
            for key3, value4 in nativeELS.Hold do
                local text4 = "PatrolELS" .. value4.Id
                local items3 = {value4.Key}
                local value42 = value4
                self:_bind(text4, items3, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        self:_elsHold(value42.Id, true)
                    elseif arg1 == Enum.UserInputState.End or arg1 == Enum.UserInputState.Cancel then
                        self:_elsHold(value42.Id, false)
                    end
                end)
                local id4 = value42.Id
                local data14 = {Key = value42.Key}
                function data14.Down()
                    self:_elsHold(value42.Id, true)
                end

                function data14.Up()
                    self:_elsHold(value42.Id, false)
                end

                data3[id4] = data14
            end
            local function rumbler()
                self:_elsSiren("Rumbler")
            end

            local items4 = {nativeELS.Rumbler.Key}
            local function callback2(arg1)
                if arg1 == Enum.UserInputState.Begin then
                    self:_elsSiren("Rumbler")
                end
            end

            self:_bind("PatrolELSRumbler", items4, callback2)
            local data15 = {Key = nativeELS.Rumbler.Key}
            data15.Down = rumbler
            data3.Rumbler = data15
            data4.Horn = data3.Airhorn
            for key4, value5 in VehicleConfig.NativeLights.Keys do
                local key42 = key4
                local function press3()
                    self:_roadLight(key42)
                end

                self:_bind("PatrolRoad" .. key42, value5, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        self:_roadLight(key42)
                    end
                end)
                local data16 = {Key = value5[1]}
                data16.Down = press3
                data3[key42] = data16
            end
            local _definition = self._definition
            if _definition and (_definition.Equipment and _definition.Equipment.ALPR) then
                local resetKey = VehicleConfig.ALPR.ResetKey
                local function reset2()
                    self:_resetALPR()
                end

                self:_bind("PatrolALPRReset", {resetKey}, function(arg1)
                    if arg1 == Enum.UserInputState.Begin then
                        self:_resetALPR()
                    end
                end)
                local data17 = {Key = resetKey}
                data17.Down = reset2
                data3.ALPRReset = data17
            end
        end
        local data42 = data4
        self:_bindPad(data42)
        if _speedo then
            self._pad.Handbrake = true
        end
        self._controls = data3
        if result then
            data42 = hud
            data42 = data42.SirenBox
            data42 = data42.Native
        else
            data42 = {}
            data42[1] = hud.SirenBox.Native[1]
        end
        self:_showSirenBox(data42, data3)
    end
end

function data5:_roadLight(text)
    local _elsCar = self._elsCar
    if not _elsCar then
        return
    end
    local headlights = if text == "Headlights" then attributes.Headlights else text
    self:_elsBeep()
    Net.Fire("Vehicles", "SetState", text, _elsCar.Model:GetAttribute(headlights) ~= true)
end

function data5:_elsBeep()
    local _elsCar = self._elsCar
    local result = _elsCar
    if result then
        result = _elsCar.Model
        result = result:FindFirstChild("DriveSeat")
        if result then
            result = _elsCar.Model
            result = result.DriveSeat
            result = result:FindFirstChild("ELS_Panel")
        end
    end
    local result2 = result and result:FindFirstChild("Beep")
    if result2 and result2:IsA("Sound") then
        (game:GetService("SoundService")):PlayLocalSound(result2)
    end
end

function data5:_elsLight(data2)
    local _elsCar = self._elsCar
    local _elsCar2 = _elsCar and _elsCar.Events:FindFirstChild("LightingEvent")
    if not _elsCar2 then
        return
    end
    self:_elsBeep()
    if data2.Kind == "Number" then
        _elsCar2:FireServer(data2.Id, "Number", data2.Max)
    else
        _elsCar2:FireServer(data2.Id, "Bool")
    end
end

function data5:_elsStage(data2, number)
    local _elsCar = self._elsCar
    local _elsCar2 = _elsCar and _elsCar.Lightbar:FindFirstChild("Values")
    local _elsCar22 = _elsCar2 and _elsCar2:FindFirstChild(data2.Id)
    if not _elsCar22 then
        return
    end
    local value = _elsCar22.Value
    local number2 = tonumber(value) or 0
    local number22 = number2 + number
    local max = data2.Max
    local number3 = math.clamp(number22, 0, max)
    if number3 ~= number2 then
        self:_elsBeep()
        Net.Fire("Vehicles", "SetState", "LightStage", number3)
    end
end

function data5:_elsSiren(text)
    local _elsCar = self._elsCar
    local _elsCar2 = _elsCar and _elsCar.Events:FindFirstChild("SirenEvent")
    if not _elsCar2 then
        return
    end
    if text ~= "Rumbler" then
        self:_elsBeep()
    end
    _elsCar2:FireServer(text, "N/A")
end

function data5:_elsHold(text, flag)
    local _elsCar = self._elsCar
    local _elsCar2 = _elsCar and _elsCar.Events:FindFirstChild("SirenEvent")
    self._holding = self._holding or {}
    if not _elsCar2 or self._holding[text] == flag then
        return
    end
    self._holding[text] = flag
    _elsCar2:FireServer(text, if flag then "HoldStart" else "HoldStop")
end

local function sirenPlaying(object, text, text2)
    local object2 = object and object:FindFirstChild(text2 or "Siren1")
    local object22 = object2 and object2:FindFirstChild(text)
    local flag = false
    if object22 ~= nil then
        flag = object22:IsA("Sound")
        if flag then
            flag = object22.Playing
        end
    end
    return flag
end

function data5:_elsSirenStep(flag)
    local _elsCar = self._elsCar
    if not _elsCar then
        return
    end
    for key, value in nativeELS.Sirens do
        if value.Holder then
            continue
        end
        local id = value.Id
        local data22 = {}
        table.insert(data22, id)
    end
    local data3 = {}
    for key2, value2 in data3 do
        local lightbar = _elsCar.Lightbar
        local lightbar2 = lightbar and lightbar:FindFirstChild("Siren1")
        local lightbar22 = lightbar2 and lightbar2:FindFirstChild(value2)
        local flag2 = false
        if lightbar22 ~= nil then
            flag2 = lightbar22:IsA("Sound")
            if flag2 then
                flag2 = lightbar22.Playing
            end
        end
        if flag2 then
            if flag then
                lightbar2 = data3[key2 % #data3 + 1]
            else
                lightbar2 = value2
            end
            self:_elsSiren(lightbar2)
            return
        end
    end
    if data3[1] then
        self:_elsSiren(data3[1])
    end
end

function data5:_nativeGear(number)
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    local playerGui2 = playerGui and playerGui:FindFirstChild("A-Chassis Interface")
    local playerGui22 = playerGui2 and playerGui2:FindFirstChild("Values")
    local playerGui222 = playerGui22 and playerGui22:FindFirstChild("Gear")
    if self._role == "Driver" and (playerGui22 and (playerGui222 and playerGui222:IsA("NumberValue"))) then
        local pBrake = playerGui22:FindFirstChild("PBrake")
        local flag = false
        if pBrake ~= nil then
            flag = pBrake:IsA("BoolValue")
            if flag then
                flag = pBrake.Value
            end
        end
        if flag then
            if math.abs(number) < 0.5 then
                return "P", true
            end
        end
        if playerGui222.Value < 0 then
            return "R", flag
        end
        if playerGui222.Value == 0 then
            return "N", flag
        end
        local transmissionMode = playerGui22:FindFirstChild("TransmissionMode")
        local transmissionMode2 = playerGui22:FindFirstChild("TransmissionMode")
        if transmissionMode and (transmissionMode:IsA("StringValue") and transmissionMode.Value == "Auto") then
            transmissionMode2 = "D"
        else
            local value = playerGui222.Value
            local number4 = math.floor(value)
            transmissionMode2 = tostring(number4)
        end
        return transmissionMode2, flag
    end
    local _role = self._role
    if number < -0.5 then
        _role = "R"
    else
        _role = if math.abs(number) < 0.5 then "P" else "D"
    end
    return _role, false
end

local data6 = {
    {Id = "Headlights", Label = "HEAD", Status = "HEADLIGHTS"},
    {Id = "IndicatorLeft", Label = "&lt; LEFT", Status = "&lt; LEFT"},
    {Id = "Hazard", Label = "HAZARD", Status = "HAZARDS"},
    {Id = "IndicatorRight", Label = "RIGHT &gt;", Status = "RIGHT &gt;"},
}
function data5:_updateNative(object)
    local chassis = object:FindFirstChild("Chassis") or object:FindFirstChild("DriveSeat")
    local value
    if chassis and chassis:IsA("BasePart") then
        value = chassis
    else
        value = nil
    end
    if not value then
        return
    end
    local dot = value.AssemblyLinearVelocity:Dot(value.CFrame.LookVector)
    local number2 = math.abs(dot) * speedToMph
    local speedLimitAt2 = speedLimitAt(value.Position)
    local _nativeGear, result2 = self:_nativeGear(dot)
    if object:GetAttribute(attributes.Headlights) then
        local data22 = {}
        table.insert(data22, {"HEADLIGHTS"})
    end
    if object:GetAttribute("IndicatorLeft") then
        local items = {"< LEFT", Theme.Colors.Good}
        local data32 = {}
        table.insert(data32, items)
    end
    if object:GetAttribute("IndicatorRight") then
        local items2 = {"RIGHT >", Theme.Colors.Good}
        local data42 = {}
        table.insert(data42, items2)
    end
    if object:GetAttribute("Hazard") then
        local items3 = {"HAZARDS", Theme.Colors.Warning}
        local data52 = {}
        table.insert(data52, items3)
    end
    local locked = attributes.Locked
    if object:GetAttribute(locked) then
        local data72 = {}
        table.insert(data72, {"LOCKED"})
    end
    local flatTyres = attributes.FlatTyres
    if (object:GetAttribute(flatTyres) or 0) ~= 0 then
        local items4 = {"FLAT TYRE", Theme.Colors.Bad}
        local data82 = {}
        table.insert(data82, items4)
    end
    if result2 then
        local items5 = {"HANDBRAKE", Theme.Colors.Warning}
        local data92 = {}
        table.insert(data92, items5)
    end
    locked, flatTyres = number2, _nativeGear
    self:_setSpeedo(locked, flatTyres, speedLimitAt2, {})
    if not self._box.Visible then
        return
    end
    local body = object:FindFirstChild("Body") and object.Body:FindFirstChild("Lightbar")
    local body2 = body and body:FindFirstChild("Values")
    for key, value2 in nativeELS.Lights do
        local body22 = body2 and body2:FindFirstChild(value2.Id)
        local body222 = body22 and body22.Value
        if value2.Kind == "Number" then
            body22 = (tonumber(body222) or 0) > 0
        else
            body22 = body222 == true
        end
        if value2.Id == nativeELS.Stage then
            self:_setStage(tonumber(body222) or 0)
        else
            self:_keyLit(value2.Id, body22, color)
            if value2.Kind == "Number" then
                local id3 = value2.Id
                local id4 = hud.Labels[value2.Id] or value2.Label
                local labels = hud.Labels
                if body22 then
                    labels = tostring(body222)
                else
                    labels = "OFF"
                end
                self:_keyText(id3, ("%s\n%s"):format(id4, labels))
            end
        end
        if body22 then
            local value3
            if value2.Kind == "Number" then
                value3 = "%s %s"
                value3 = value3:format(value2.Label, (tostring(body222)))
            else
                value3 = value2.Label
            end
            local data102 = {}
            table.insert(data102, value3)
        end
    end
    for key2, value4 in nativeELS.Sirens do
        local id5 = value4.Id
        local holder = value4.Holder
        local body3 = body and body:FindFirstChild(holder or "Siren1")
        local body32 = body3 and body3:FindFirstChild(id5)
        local flag = false
        if body32 ~= nil then
            flag = body32:IsA("Sound")
            if flag then
                flag = body32.Playing
            end
        end
        self:_keyLit(value4.Id, flag, color2)
        if flag then
            local data112 = {}
            local label2 = value4.Label
            table.insert(data112, ("<font color=\"#5fa0ff\">%s</font>"):format(label2))
        end
    end
    for key3, value5 in nativeELS.Hold do
        local id7 = value5.Id
        local id8 = value5.Id
        local body4 = body and body:FindFirstChild("Siren1")
        local body42 = body4 and body4:FindFirstChild(id8)
        local flag3 = false
        if body42 ~= nil then
            flag3 = body42:IsA("Sound")
            if flag3 then
                flag3 = body42.Playing
            end
        end
        self:_keyLit(id7, flag3, color2)
    end
    local body5 = body and body:FindFirstChild("Handler")
    local body52 = body5 and body5:FindFirstChild("SirenEvent")
    local body522 = body52 and body52:FindFirstChild("Rumbler")
    self:_keyLit("Rumbler", body522 ~= nil and body522.Value == true, color2)
    for key4, value6 in data6 do
        local condition2 = object:GetAttribute(if value6.Id == "Headlights" then attributes.Headlights else value6.Id) == true
        self:_keyLit(value6.Id, condition2, color)
        if condition2 then
            local status = value6.Status
            local data122 = {}
            table.insert(data122, status)
        end
    end
    local data13 = {}
    local count = #data13
    local value7
    if count > 0 then
        value7 = table.concat
        value7 = value7(data13, "  ")
    else
        value7 = "All off"
    end
    self:_setDisplay(value7, nil)
    local osClock = os.clock()
    if not self._lastRadar or osClock - self._lastRadar > 0.25 then
        self._lastRadar = osClock
        if self._radarOn then
            local value8 = value
            local value9
            local value10
            value9, value10 = self:_radar(value8)
            self:_setRadar(value9, value10, number2, speedLimitAt2)
        end
        self:_setDisplay(nil, self:_subLine())
    end
end

function data5:_leave()
    if self._vehicle and self._role == "Driver" then
        if not self._vehicle:GetAttribute("NativeChassis") then
            Net.Fire("Vehicles", "SetState", "Horn", false)
        end
    end
    self._seatMaid:Cleanup()
    self._vehicle = nil
    self._seat = nil
    self._role = nil
    self._controls = nil
    self._pad = nil
    self._physics = nil
    self._handbrake = false
end

function data5._noTouchJump(data, object, arg3)
    if not userInputService.TouchEnabled or userInputService.KeyboardEnabled then
        return
    end
    local function jumpButton()
        local child = localPlayer:FindFirstChildOfClass("PlayerGui")
        local child2 = child and child:FindFirstChild("TouchGui")
        local child22 = child2 and child2:FindFirstChild("TouchControlFrame")
        local child222 = child22 and child22:FindFirstChild("JumpButton")
        if child222 and child222:IsA("GuiObject") then
            return child222
        end
        return nil
    end

    local function apply(flag)
        local character = localPlayer.Character
        local character2 = character and character:FindFirstChildOfClass("Humanoid")
        if character2 then
            character2:SetStateEnabled(Enum.HumanoidStateType.Jumping, not flag)
        end
        local jumpButton2 = jumpButton()
        if jumpButton2 and flag then
            jumpButton2.Visible = false
        end
    end

    local taskSpawn = task.spawn
    local flag = true
    taskSpawn(function()
        while flag and object.Parent do
            local condition = object:GetAttribute(attributes.SeatLocked) == true
            local character = localPlayer.Character
            local character2 = character and character:FindFirstChildOfClass("Humanoid")
            if character2 then
                character2:SetStateEnabled(Enum.HumanoidStateType.Jumping, not condition)
            end
            local jumpButton2 = jumpButton()
            if jumpButton2 and condition then
                jumpButton2.Visible = false
            end
            task.wait(0.25)
        end
    end)
    arg3:Give(function()
        flag = false
        local character = localPlayer.Character
        local character2 = character and character:FindFirstChildOfClass("Humanoid")
        if character2 then
            character2:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
        local jumpButton2 = jumpButton()
        local jumpButton3 = jumpButton()
        if jumpButton3 then
            jumpButton3.Visible = true
        end
    end)
end

local function touchJumpButton()
    local child = localPlayer:FindFirstChildOfClass("PlayerGui")
    local child2 = child and child:FindFirstChild("TouchGui")
    local child22 = child2 and child2:FindFirstChild("TouchControlFrame")
    local child222 = child22 and child22:FindFirstChild("JumpButton")
    if child222 and child222:IsA("GuiObject") then
        return child222
    end
    return nil
end

function data5._touchBuild(data)
    if data._touchUi then
        return data._touchUi
    end
    local create = Components.Create
    local data4 = {
        Name = "TouchDriveUI",
        ResetOnSpawn = false,
        DisplayOrder = 10,
        ScreenInsets = Enum.ScreenInsets.None,
    }
    data4.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    data4.Parent = localPlayer:WaitForChild("PlayerGui")
    local create2 = create("ScreenGui", data4)
    local data5 = {Gui = create2}
    data5.Keys = {}
    data5.Held = {}
    data5.CarFrames = {}
    data._touchUi = data5
    data5.JumpBack = function()
        local jumpHome = data5.JumpHome
        data5.JumpHome = nil
        if jumpHome and jumpHome.Button.Parent then
            jumpHome.Button.Position = jumpHome.Position
        end
    end
    local function button(text, object)
        local create = Components.Create
        local data = {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = text,
        }
        data.Parent = object
        return create("TextButton", data)
    end

    local function face(object, uDim, color3)
        local create2 = Components.Create("UIStroke", {Thickness = 1.5, Transparency = 0.4, Color = data3.Rim})
        local create4 = Components.Create("UIScale", {})
        local create5 = Components.Create
        local vector2New = Vector2.new
        local data2 = {
            Name = "Face",
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            AnchorPoint = vector2New(0.5, 0.5),
        }
        data2.Position = UDim2.fromScale(0.5, 0.5)
        data2.Size = UDim2.fromScale(1, 1)
        data2.BackgroundColor3 = data3.Plate
        data2.Parent = object
        local corner2 = Components.Corner(uDim)
        local create22 = create2
        local create42 = create4
        local create6 = Components.Create
        local colorSequenceNew = ColorSequence.new
        local color = Color3.new(1, 1, 1)
        local color3FromRGB = Color3.fromRGB
        local data4 = {Rotation = 90, Color = colorSequenceNew(color, color3FromRGB(140, 140, 150))}
        return create5("Frame", data2, {
            corner2,
            create22,
            create42,
            create6("UIGradient", data4),
        }), function(flag)
            create4.Scale = if flag then 0.93 else 1
            create2.Color = if flag then color3 else data3.Rim
            create2.Transparency = if flag then 0 else 0.4
            create2.Thickness = if flag then 3 else 1.5
        end
    end

    local create3 = Components.Create
    local vector2New = Vector2.new
    local data6 = {
        Name = "Steer",
        BackgroundTransparency = 1,
        Visible = false,
        AnchorPoint = vector2New(0, 1),
    }
    data6.Parent = create2
    local create4 = create3("Frame", data6)
    local items = {}
    local items2 = {}
    for key, value in {-1, 1} do
        local left = if value < 0 then "Left" else "Right"
        local create5 = Components.Create
        local data7 = {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = left,
        }
        data7.Parent = create4
        local create6 = create5("TextButton", data7)
        create6.Position = UDim2.fromScale(if value < 0 then 0 else 0.53, 0)
        create6.Size = UDim2.fromScale(0.47, 1)
        local face3, result2 = face(create6, UDim.new(1, 0), data2.Ink)
        Components.Create("UIAspectRatioConstraint", {AspectRatio = 1, Parent = face3})
        for key2, value3 in {-1, 1} do
            local create8 = Components.Create
            local vector2New2 = Vector2.new
            local data9 = {Name = "Arrow", BorderSizePixel = 0, AnchorPoint = vector2New2(0.5, 0.5)}
            data9.Position = UDim2.fromScale(0.5, 0.5 + value3 * 0.115)
            data9.Size = UDim2.fromScale(0.09, 0.32)
            data9.Rotation = value * value3 * 40
            data9.BackgroundColor3 = data2.Ink
            data9.Parent = face3
            local corner = Components.Corner
            local uDimNew2 = UDim.new
            create8("Frame", data9, {corner(uDimNew2(1, 0))})
        end
        items[value] = create6
        items2[value] = result2
    end
    local function pedal(text, number, number2, color3)
        local create22 = create2
        local create = Components.Create
        local data = {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = text,
        }
        data.Parent = create22
        local create3 = create("TextButton", data)
        create3.AnchorPoint = Vector2.new(0, 1)
        create3.Visible = false
        local face3, result2 = face(create3, UDim.new(0.16, 0), color3)
        local create4 = Components.Create
        local vector2New2 = Vector2.new
        local data4 = {Name = "Rubber", BorderSizePixel = 0, AnchorPoint = vector2New2(0.5, 0)}
        data4.Position = UDim2.fromScale(0.5, 0.08)
        data4.Size = UDim2.fromScale(0.8, number2)
        data4.BackgroundColor3 = data3.Rubber
        data4.Parent = face3
        local corner = Components.Corner
        local uDimNew2 = UDim.new
        local create5 = create4("Frame", data4, {corner(uDimNew2(0.14, 0))})
        for index = 1, number do
            local create6 = Components.Create
            local vector2New3 = Vector2.new
            local data5 = {Name = "Rib", BorderSizePixel = 0, AnchorPoint = vector2New3(0.5, 0.5)}
            data5.Position = UDim2.fromScale(0.5, index / (number + 1))
            data5.Size = UDim2.fromScale(0.76, 0.42 / (number + 1))
            data5.BackgroundColor3 = data3.Rib
            data5.Parent = create5
            local corner2 = Components.Corner
            local uDimNew3 = UDim.new
            create6("Frame", data5, {corner2(uDimNew3(1, 0))})
        end
        local create7 = Components.Create
        local vector2New4 = Vector2.new
        local data6 = {
            Name = "Caption",
            BackgroundTransparency = 1,
            RichText = true,
            Text = "",
            AnchorPoint = vector2New4(0.5, 1),
        }
        data6.Position = UDim2.fromScale(0.5, 0.97)
        data6.Size = UDim2.fromScale(1, 0.89 - number2)
        data6.Font = Theme.Fonts.Bold
        data6.TextColor3 = data2.Ink
        data6.Parent = face3
        return create3, result2, (create7("TextLabel", data6))
    end

    local pedal3, result22, result3 = pedal("Gas", 5, 0.62, Theme.Colors.Good)
    local pedal4, result23, result32 = pedal("Brake", 3, 0.46, color)
    local create9 = Components.Create
    local data10 = {
        Name = "Exit",
        Text = "EXIT",
        AutoButtonColor = false,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        Font = Theme.Fonts.Bold,
    }
    data10.TextColor3 = data2.Ink
    data10.AnchorPoint = Vector2.new(0, 1)
    data10.BackgroundColor3 = data2.Housing
    data10.Parent = create2
    local corner3 = Components.Corner(UDim.new(0.5, 0))
    local create10 = Components.Create
    local data11 = {Thickness = 1.5, Transparency = 0.1, Color = color}
    data11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local create11 = create9("TextButton", data10, {corner3, create10("UIStroke", data11)})
    data5.Pad = create4
    data5.Brake = pedal4
    data5.Gas = pedal3
    data5.Exit = create11
    data5.BrakeCaption = result32
    data5.GasCaption = result3
    local function hold(object, callback, callback2)
        object.InputBegan:Connect(function(input)
            local userInputType = input.UserInputType
            if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 or (input.UserInputState ~= Enum.UserInputState.Begin or data5.Held[object]) then
                return
            end
            local held = data5.Held
            local object2 = object
            local data = {Input = input}
            data.Up = callback2
            held[object2] = data
            callback(input)
        end)
    end

    local function lifted(input)
        local condition = input.UserInputType == Enum.UserInputType.MouseButton1
        for key, value in data5.Held do
            if value.Input == input or condition and value.Input.UserInputType == Enum.UserInputType.MouseButton1 then
                data5.Held[key] = nil
                value.Up(value.Input)
            end
        end
    end

    userInputService.InputEnded:Connect(lifted)
    userInputService.TouchEnded:Connect(lifted)
    data5.Hold = hold
    function data5:Tap(callback)
        local inputBegan = self.InputBegan
        local value = 0
        inputBegan:Connect(function(input)
            local userInputType = input.UserInputType
            if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 or input.UserInputState ~= Enum.UserInputState.Begin then
                return
            end
            local osClock = os.clock()
            local osClock2 = osClock - value
            if osClock2 < 0.2 then
                return
            end
            value = osClock
            callback()
        end)
    end

    local inputBegan = create11.InputBegan
    local value4 = 0
    local function callback()
        create11.BackgroundColor3 = color
        task.delay(0.25, function()
            create11.BackgroundColor3 = data2.Housing
        end)
        data:_touchExit()
    end

    local function callback2(input)
        local userInputType = input.UserInputType
        if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 or input.UserInputState ~= Enum.UserInputState.Begin then
            return
        end
        local osClock = os.clock()
        local osClock2 = osClock - value4
        if osClock2 < 0.2 then
            return
        end
        value4 = osClock
        callback()
    end

    inputBegan:Connect(callback2)
    data5.Release = function()
        for key, value in data5.Held do
            data5.Held[key] = nil
            value.Up(value.Input)
        end
    end
    local data12 = {Piece = pedal3}
    data12.Pressed = result22
    local data13 = {Throttle = data12}
    local data14 = {Piece = pedal4}
    data14.Pressed = result23
    data13.Brake = data14
    for key3, value5 in data13 do
        local piece = value5.Piece
        local key32 = key3
        local value52 = value5
        local inputBegan2 = piece.InputBegan
        local function callback3()
            if data._drive then
                data._drive[key32] = 0
            end
            value52.Pressed(false)
        end

        local function callback4()
            if data._drive then
                data._drive[key32] = 1
            end
            value52.Pressed(true)
        end

        inputBegan2:Connect(function(input)
            local userInputType = input.UserInputType
            if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 or (input.UserInputState ~= Enum.UserInputState.Begin or data5.Held[piece]) then
                return
            end
            local held = data5.Held
            local piece2 = piece
            local data = {Input = input}
            data.Up = callback3
            held[piece2] = data
            callback4(input)
        end)
    end
    local function steer(number)
        if data._drive then
            data._drive.Steer = number
        end
        items2[-1](number < 0)
        items2[1](number > 0)
    end

    local function middle()
        return create4.AbsolutePosition.X + create4.AbsoluteSize.X / 2
    end

    for key4, value6 in items do
        local value7 = nil
        local key42 = key4
        local inputBegan3 = value6.InputBegan
        local value62 = value6
        local function callback5(arg1)
            if value7 and value7.Input == arg1 then
                value7 = nil
                if data._drive then
                    data._drive.Steer = 0
                end
                items2[-1](false)
                items2[1](false)
            end
        end

        local function callback6(arg1)
            local x3 = arg1.Position.X - (create4.AbsolutePosition.X + create4.AbsoluteSize.X / 2)
            local data2 = {Input = arg1}
            data2.Side = key42
            local x32 = x3 * key42
            local result = key42
            if x32 > 0 then
                result = 0
            else
                result = key42 * create4.AbsoluteSize.X / 4 - x3
            end
            data2.Bias = result
            value7 = data2
            local key423 = key42
            if data._drive then
                data._drive.Steer = key423
            end
            items2[-1](key423 < 0)
            items2[1](key423 > 0)
        end

        inputBegan3:Connect(function(input)
            local userInputType = input.UserInputType
            if userInputType ~= Enum.UserInputType.Touch and userInputType ~= Enum.UserInputType.MouseButton1 or (input.UserInputState ~= Enum.UserInputState.Begin or data5.Held[value62]) then
                return
            end
            local held = data5.Held
            local value622 = value62
            local data = {Input = input}
            data.Up = callback5
            held[value622] = data
            callback6(input)
        end)
    end
    local touchMoved = userInputService.TouchMoved
    local value8 = nil
    touchMoved:Connect(function(arg1)
        local value82 = value8
        if value82 and value82.Input == arg1 then
            if (arg1.Position.X + value82.Bias - (create4.AbsolutePosition.X + create4.AbsoluteSize.X / 2)) * value82.Side < -data3.Slide then
                value82.Side = -value82.Side
                local side = value82.Side
                if data._drive then
                    data._drive.Steer = side
                end
                items2[-1](side < 0)
                items2[1](side > 0)
            end
        end
    end)
    local renderStepped = runService.RenderStepped
    local value9 = 0
    renderStepped:Connect(function(value)
        if not data._vehicle then
            return
        end
        data:_touchMirror()
        value9 += value
        if value9 >= 0.25 then
            value9 = 0
            data:_touchPlace()
        end
    end)
    return data5
end

function data5:_touchExit()
    local character = localPlayer.Character
    local character2 = character and character:FindFirstChildOfClass("Humanoid")
    if not character2 or (not character2.SeatPart or self._exiting) then
        return
    end
    self._exiting = true
    Net.Fire("Vehicles", "Leave")
    local stepped = runService.Stepped
    local value = 0
    local value2 = nil
    value2 = stepped:Connect(function()
        value += 1
        if value > 30 or (not character2.Parent or not character2.SeatPart) then
            value2:Disconnect()
            self._exiting = nil
        else
            character2.Jump = true
        end
    end)
end

function data5:_touchPress(object, arg3)
    local _touchBuild = self:_touchBuild()
    if arg3.Up then
        _touchBuild.Hold(object, function()
            arg3.Down()
        end, function()
            arg3.Up()
        end)
    else
        _touchBuild.Tap(object, function()
            arg3.Down()
        end)
    end
end

function data5:_touchDrive(object, arg3, flag)
    if not self._touch then
        return
    end
    local _touchBuild = self:_touchBuild()
    local config = {Throttle = 0, Brake = 0, Steer = 0}
    self._drive = config
    if flag then
        local child = localPlayer:FindFirstChildOfClass("PlayerGui")
        local function tell(object, text, number)
            if object:GetAttribute(text) ~= number then
                object:SetAttribute(text, number)
            end
        end

        local heartbeat = runService.Heartbeat
        local function callback()
            local child2 = child and child:FindFirstChild("A-Chassis Interface")
            if not child2 then
                return
            end
            local throttleFloat = if object:IsA("VehicleSeat") then object.ThrottleFloat else 0
            local steerFloat = if object:IsA("VehicleSeat") then object.SteerFloat else 0
            local throttle = config.Throttle
            local number = math.clamp(throttleFloat, 0, 1)
            local number2 = math.max(throttle, number)
            if child2:GetAttribute("TouchThrottle") ~= number2 then
                child2:SetAttribute("TouchThrottle", number2)
            end
            local brake = config.Brake
            local throttleFloat3 = -throttleFloat
            local number3 = math.clamp(throttleFloat3, 0, 1)
            local number4 = math.max(brake, number3)
            if child2:GetAttribute("TouchBrake") ~= number4 then
                child2:SetAttribute("TouchBrake", number4)
            end
            local steer = config.Steer + steerFloat
            local number5 = math.clamp(steer, -1, 1)
            if child2:GetAttribute("TouchSteer") ~= number5 then
                child2:SetAttribute("TouchSteer", number5)
            end
        end

        arg3:Give(heartbeat:Connect(callback))
    end
    arg3:Give(function()
        self._drive = nil
        _touchBuild.Release()
        table.clear(_touchBuild.CarFrames)
        self:_touchShow()
    end)
    self:_touchShow()
end

function data5:_touchLights(data3)
    local _touchBuild = self:_touchBuild()
    _touchBuild.Release()
    for key, value in _touchBuild.Keys do
        value.Button:Destroy()
    end
    table.clear(_touchBuild.Keys)
    self._panelOpen = false
    if not data3 or not self:_touchPhone() and not self:_touchRoundTablet() then
        self:_touchShow()
    else
        for key2, value2 in self._keys do
            if value2.Hint then
                value2.HintText = ""
                value2.Hint.Text = ""
            end
        end
        if self._stage and self._stage.Hint then
            self._stage.HintText = "LIGHTS"
            self._stage.Hint.Text = "LIGHTS"
        end
        local enabled = PhoneLayout.Enabled()
        local function sign(text, object)
            local glyph2 = PhoneLayout.Glyph(text)
            glyph2.AnchorPoint = Vector2.new(0.5, 0.5)
            glyph2.Position = UDim2.fromScale(0.5, 0.5)
            glyph2.Size = UDim2.fromScale(0.58, 0.58)
            glyph2.Parent = object
            return glyph2
        end

        local config = {
            Stage = "Lightbar",
            Wail = "Siren",
            Siren = "Siren",
            Airhorn = "Horn",
            Horn = "Horn",
            Panel = "Panel",
            Headlights = "Headlights",
            Hazard = "Hazard",
            IndicatorLeft = "IndicatorLeft",
            IndicatorRight = "IndicatorRight",
        }
        local function add(text, text2, arg3)
            local create = Components.Create
            local data = {AutoButtonColor = false, BorderSizePixel = 0, Name = text}
            data.Text = if enabled then "" else text2
            data.Font = Theme.Fonts.Bold
            data.TextColor3 = data2.Ink
            data.AnchorPoint = Vector2.new(0, 1)
            data.BackgroundColor3 = data2.Key
            data.Parent = _touchBuild.Gui
            local corner = Components.Corner
            local value = 1
            if enabled then
                value = UDim.new
                value = value(0.5, 0)
            else
                value = UDim.new
                value = value(0, 6)
            end
            value = corner(value)
            local create2 = Components.Create
            local data3 = {Thickness = 1.5, Transparency = 0.05, Color = data2.Ink}
            data3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            value = create("TextButton", data, {value, create2("UIStroke", data3)})
            local data4 = {Id = text}
            data4.Button = value
            data4.Text = text2
            data4.Round = enabled
            if enabled then
                data4.Sign = sign(config[text] or "Panel", value)
                if text == "Panel" then
                    data4.Closed = sign("Close", value)
                    data4.Closed.Visible = false
                elseif text == "Stage" then
                    local create4 = Components.Create
                    local vector2New2 = Vector2.new
                    local data5 = {
                        Name = "Stage",
                        BorderSizePixel = 0,
                        Text = "",
                        TextScaled = true,
                        Visible = false,
                        AnchorPoint = vector2New2(0.75, 0.25),
                    }
                    data5.Position = UDim2.fromScale(1, 0)
                    data5.Size = UDim2.fromScale(0.42, 0.42)
                    data5.BackgroundColor3 = data2.Ink
                    data5.Font = Theme.Fonts.Bold
                    data5.TextColor3 = data2.Key
                    data5.Parent = value
                    local corner3 = Components.Corner
                    local uDimNew = UDim.new
                    data4.Badge = create4("TextLabel", data5, {corner3(uDimNew(0.5, 0))})
                end
            end
            if arg3.Up then
                _touchBuild.Hold(value, function()
                    arg3.Down()
                end, function()
                    arg3.Up()
                end)
            else
                _touchBuild.Tap(value, function()
                    arg3.Down()
                end)
            end
            local keys = _touchBuild.Keys
            table.insert(keys, data4)
        end

        if data3.Stage then
            add("Stage", "LIGHTS", data3.Stage)
        end
        local stage = data3.Stage
        if data3.Wail then
            stage = "Wail"
        else
            stage = if data3.Siren then "Siren" else nil
        end
        if stage then
            add(stage, "SIREN", data3[stage])
        end
        if data3.Airhorn then
            stage = "Airhorn"
        else
            stage = if data3.Horn then "Horn" else nil
        end
        if stage then
            add(stage, "HORN", data3[stage])
        end
        if enabled and PhoneLayout.DriveEnabled() then
            for key3, value3 in {
                "Headlights",
                "Hazard",
                "IndicatorLeft",
                "IndicatorRight",
            } do
                if data3[value3] then
                    add(value3, string.upper(value3), data3[value3])
                end
            end
        end
        local add3 = add
        local function down()
            self._panelOpen = not self._panelOpen
            self:_touchPlace()
        end

        add3("Panel", "PANEL", {Down = down})
        self:_touchShow()
    end
end

function data5:_touchShow()
    local _touchUi = self._touchUi
    if not _touchUi then
        return
    end
    local condition = self._drive ~= nil
    local pad = _touchUi.Pad
    local brake = _touchUi.Brake
    local gas = _touchUi.Gas
    pad.Visible = condition
    brake.Visible = condition
    gas.Visible = condition
    if not condition then
        _touchUi.Exit.Visible = false
    end
    self:_touchPlace()
end

function data5:_touchMirror()
    local _touchUi = self._touchUi
    if not _touchUi then
        return
    end
    for key, value in _touchUi.Keys do
        if value.Id == "Stage" then
            local _stage = self._stage
            local value2
            if _stage then
                local shown = _stage.Shown
                value2 = math.max(shown, 0)
            else
                value2 = 0
            end
            if value.Shown == value2 then
                continue
            end
            value.Shown = value2
            if value.Badge then
                value.Badge.Text = tostring(value2)
                value.Badge.Visible = value2 > 0
            else
                local button = value.Button
                local value3
                if value2 > 0 then
                    value3 = "%s %d"
                    value3 = value3:format(value.Text, value2)
                else
                    value3 = value.Text
                end
                button.Text = value3
            end
            value.Button.BackgroundColor3 = if value2 > 0 then color else data2.Key
        else
            if value.Id == "Panel" then
                continue
            end
            local id = self._keys[value.Id]
            local backgroundColor3 = if id then id.Button.BackgroundColor3 else data2.Key
            local id2 = data4[value.Id]
            if not id and (id2 and self._vehicle) then
                local headlights = if value.Id == "Headlights" then attributes.Headlights else value.Id
                if self._vehicle:GetAttribute(headlights) == true then
                    backgroundColor3 = id2
                else
                    backgroundColor3 = data2.Key
                end
            end
            if value.Button.BackgroundColor3 == backgroundColor3 then
                continue
            end
            value.Button.BackgroundColor3 = backgroundColor3
        end
    end
end

function data5:_touchSize()
    local _touchUi = self._touchUi
    local absoluteSize = if _touchUi then _touchUi.Gui.AbsoluteSize else Vector2.zero
    local condition = absoluteSize.X >= 1 and absoluteSize.Y >= 1
    if not condition then
        local currentCamera = workspace.CurrentCamera
        absoluteSize = if currentCamera then currentCamera.ViewportSize else Vector2.zero
    end
    local deviceInsets, result2, result3, result4 = Components.DeviceInsets()
    return absoluteSize - Vector2.new(deviceInsets + result3, result2 + result4), condition, deviceInsets, result3, result4
end

function data5:_touchPhone()
    local flag = runService:IsStudio() and workspace:GetAttribute("DebugTouch")
    if flag == "Phone" or flag == "Tablet" then
        return flag == "Phone"
    end
    local _touchSize = self:_touchSize()
    local x = _touchSize.X
    local y = _touchSize.Y
    return math.min(x, y) <= data3.Phone
end

function data5:_touchHud(number, number2, flag)
    self._speedo.AnchorPoint = Vector2.new(1, 1)
    self._speedo.Position = UDim2.new(1, -12, 1, -number)
    local openMDT = self._mdtGui:FindFirstChild("OpenMDT")
    if not openMDT or not openMDT:IsA("GuiObject") then
        return nil
    end
    local uDim2New2 = UDim2.new
    local width = data.Width
    openMDT.Position = uDim2New2(1, -12 - width * hud.Scale - 8, 1, -number)
    openMDT.Visible = flag ~= false
    local touchScale = openMDT:FindFirstChild("TouchScale")
    if not touchScale then
        touchScale = Components.Create("UIScale", {Name = "TouchScale", Parent = openMDT})
    end
    touchScale.Scale = number2 or 1
    if not self._mdtGui.Enabled then
        return nil
    end
    return Vector2.new(openMDT.Size.X.Offset, openMDT.Size.Y.Offset) * (number2 or 1) * Components.ScreenScale()
end

function data5:_touchLifted(number)
    if (self._touchLift or 0) ~= number then
        self._touchLift = number
        self:_liftRadio()
    end
end

local function touchPut(object, data, number, number2, number3, number4)
    object.Position = UDim2.new(0, (data.Left + number) / data.Scale, 1, -(data.Bottom + number4) / data.Scale)
    object.Size = UDim2.fromOffset(number2 / data.Scale, number3 / data.Scale)
end

function data5:_touchPlace()
    local _touchUi = self._touchUi
    if not _touchUi then
        return
    end
    local gui = _touchUi.Gui
    local _touchSize, result2, result3, result4, result5 = self:_touchSize()
    if _touchSize.X < 1 or _touchSize.Y < 1 then
        return
    end
    local x = _touchSize.X
    local y = _touchSize.Y
    local _touchPhone = self:_touchPhone()
    if self._phone ~= _touchPhone then
        self._phone = _touchPhone
        self:_padHints()
    end
    local data2 = {Jump = nil, Scale = Components.ScreenScale()}
    data2.Width = x
    data2.Height = y
    data2.Measured = result2
    data2.Left = result3
    data2.Right = result4
    data2.Bottom = result5
    data2.Wall = gui.AbsolutePosition.X + result3
    data2.Floor = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y - result5
    data2.JumpLeft = x - (if _touchPhone then 95 else 170)
    data2.JumpRight = x - (if _touchPhone then 25 else 50)
    data2.JumpFoot = if _touchPhone then 20 else 90
    local touchJumpButton2 = touchJumpButton()
    if self._drive then
        if touchJumpButton2 and touchJumpButton2.Visible then
            touchJumpButton2.Visible = false
        end
        _touchUi.JumpAway = true
    elseif _touchUi.JumpAway then
        _touchUi.JumpAway = nil
        if touchJumpButton2 then
            touchJumpButton2.Visible = true
        end
    end
    if result2 and (touchJumpButton2 and touchJumpButton2.AbsoluteSize.X > 1) then
        local x2 = touchJumpButton2.AbsolutePosition.X - data2.Wall
        if x * 0.5 < x2 and x2 < x then
            data2.Jump = touchJumpButton2
            local x22 = x2 + touchJumpButton2.AbsoluteSize.X
            local number = math.min(x22, x)
            data2.JumpLeft = x2
            data2.JumpRight = number
            data2.JumpFoot = data2.Floor - (touchJumpButton2.AbsolutePosition.Y + touchJumpButton2.AbsoluteSize.Y)
        end
    end
    local onTouchScreen = Pad.OnTouchScreen()
    _touchUi.Gui.Enabled = not onTouchScreen
    if onTouchScreen then
        self:_touchBeside(data2)
    elseif (_touchPhone or self:_touchRoundTablet()) and PhoneLayout.DriveEnabled() then
        self:_touchRound(data2)
    elseif _touchPhone then
        self:_touchRow(data2)
    else
        self:_touchBeside(data2)
    end
end

function data5._touchRoundTablet(arg1)
    return PhoneLayout.DriveEnabled() and PhoneLayout.TabletEnabled()
end

function data5:_touchHudMiddle(number, number2, flag)
    self._speedo.AnchorPoint = Vector2.new(0.5, 1)
    self._speedo.Position = UDim2.new(0.5, 0, 1, -number)
    local openMDT = self._mdtGui:FindFirstChild("OpenMDT")
    if not openMDT or not openMDT:IsA("GuiObject") then
        return nil
    end
    openMDT.Position = UDim2.new(0.5, -data.Width * hud.Scale / 2 - 8, 1, -number)
    openMDT.Visible = flag ~= false
    local touchScale = openMDT:FindFirstChild("TouchScale")
    if not touchScale then
        touchScale = Components.Create("UIScale", {Name = "TouchScale", Parent = openMDT})
    end
    touchScale.Scale = number2 or 1
    if not self._mdtGui.Enabled then
        return nil
    end
    return Vector2.new(openMDT.Size.X.Offset, openMDT.Size.Y.Offset) * (number2 or 1) * Components.ScreenScale()
end

function data5:_touchRoundLook(flag)
    local _touchUi = self._touchUi
    if not _touchUi or (if _touchUi.RoundLook == true then flag == true else flag == false) then
        return
    end
    _touchUi.RoundLook = flag
    local function sign(object, text, color3)
        local roundSign = object:FindFirstChild("RoundSign")
        if not roundSign and flag then
            roundSign = PhoneLayout.Glyph(text, nil, color3)
            roundSign.Name = "RoundSign"
            roundSign.AnchorPoint = Vector2.new(0.5, 0.5)
            roundSign.Position = UDim2.fromScale(0.5, 0.5)
            roundSign.Size = UDim2.fromScale(0.62, 0.62)
            Components.Create("UIAspectRatioConstraint", {AspectRatio = 1, Parent = roundSign})
            roundSign.Parent = object
        end
        return roundSign
    end

    local function face(object, text, uDim)
        local face = object:FindFirstChild("Face")
        if not face or not face:IsA("Frame") then
            return
        end
        local child = face:FindFirstChildOfClass("UICorner")
        if child then
            if face:GetAttribute("CornerWas") == nil then
                face:SetAttribute("CornerWas", child.CornerRadius.Scale)
                face:SetAttribute("CornerWasOffset", child.CornerRadius.Offset)
            end
            local attribute = face:GetAttribute("CornerWas")
            if flag and uDim then
                attribute = uDim
            else
                attribute = UDim.new
                attribute = attribute(face:GetAttribute("CornerWas"), face:GetAttribute("CornerWasOffset"))
            end
            child.CornerRadius = attribute
        end
        face.BackgroundColor3 = if flag then color6 else data3.Plate
        face.BackgroundTransparency = if flag then 0.28 else 0.1
        local child2 = face:FindFirstChildOfClass("UIGradient")
        if child2 then
            child2.Enabled = not flag
        end
        for key, value in {"Rubber", "Caption"} do
            local child3 = face:FindFirstChild(value)
            if child3 and child3:IsA("GuiObject") then
                child3.Visible = not flag
            end
        end
        if text then
            local sign2 = sign(face, text)
            if sign2 then
                sign2.Visible = flag
            end
        end
    end

    face(_touchUi.Gas, "Gas", UDim.new(0.5, 0))
    face(_touchUi.Brake, "Brake", UDim.new(0.5, 0))
    for key, value in _touchUi.Pad:GetChildren() do
        if value:IsA("GuiButton") then
            face(value, nil, nil)
        end
    end
    _touchUi.Exit.Text = if flag then "" else "EXIT"
    local sign3 = sign(_touchUi.Exit, "Exit", color7)
    if sign3 then
        sign3.Visible = flag
    end
end

function data5:_touchLetters(number, number2)
    local _touchUi = self._touchUi
    local text = data3.Text * number2 / number
    local number3 = math.floor(text)
    local gasCaption = _touchUi.GasCaption
    local brakeCaption = _touchUi.BrakeCaption
    local exit = _touchUi.Exit
    gasCaption.TextSize = number3
    brakeCaption.TextSize = number3
    exit.TextSize = number3
    _touchUi.GasCaption.Text = "GAS"
    local brakeCaption2 = _touchUi.BrakeCaption
    local number32 = number3 * 0.68
    local number4 = math.floor(number32)
    brakeCaption2.Text = ("BRAKE\n<font size=\"%d\" transparency=\"0.35\">REVERSE</font>"):format((math.max(number4, 1)))
end

function data5._touchRow(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5._touchRound(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5:_touchBeside(data4)
    local _touchUi = self._touchUi
    local scale = data4.Scale
    local width = data4.Width
    local gap = data3.Gap
    self:_touchRoundLook(false)
    local condition = self._drive ~= nil
    _touchUi.Gui.DisplayOrder = 10
    self:_touchHud(12)
    for key, value in _touchUi.Keys do
        value.Button.Visible = false
    end
    local _box = self._box
    local child = _box:FindFirstChildOfClass("UIScale")
    if child then
        child.Scale = hud.Scale
    end
    local value2 = 12 * scale
    local toolBar = data3.ToolBar
    local number = math.max(value2, toolBar)
    local number2 = number + _box.Size.Y.Offset * hud.Scale * scale
    _box.Position = UDim2.new(0, 12, 1, -number / scale)
    local value3 = 1
    local number3 = -number / scale
    if _box.Visible then
        number3 = data4.Left
        value3 = -number3
        local data5 = {Left = value3}
        number3 = 12 + _box.Size.X.Offset * hud.Scale
        value3 = number3 * scale
        data5.Right = value3
        data5.Top = number2
        local data62 = {}
        table.insert(data62, data5)
    end
    for key2, value4 in _touchUi.CarFrames do
        if not key2.Parent then
            _touchUi.CarFrames[key2] = nil
        else
            local anchorPoint = value4.AnchorPoint
            local size = value4.Size
            key2.AnchorPoint = anchorPoint
            key2.Size = size
            key2.Visible = true
            if value4.AnchorPoint.Y == 1 then
                anchorPoint = UDim2.new
                anchorPoint = anchorPoint(value4.Position.X.Scale, value4.Position.X.Offset, 1, -(data3.ToolBar + 4))
            else
                anchorPoint = value4.Position
            end
            key2.Position = anchorPoint
            if data4.Measured and key2.AbsoluteSize.X > 1 then
                local x = key2.AbsolutePosition.X - data4.Wall
                local data7 = {Left = x}
                data7.Right = x + key2.AbsoluteSize.X
                data7.Top = data4.Floor - key2.AbsolutePosition.Y
                local data82 = {}
                table.insert(data82, data7)
            end
        end
    end
    local data9 = {}
    local function clear(number, number2, number3)
        for key, value in data9 do
            if value.Left - gap < number2 and number < value.Right + gap then
                local top = value.Top + 8
                number3 = math.max(number3, top)
            end
        end
        return number3
    end

    local value5 = (12 + data.Height * hud.Scale) * scale
    local width3 = width - (12 + data.Width * hud.Scale) * scale
    local jump = data4.Jump
    if jump and (not condition and (self._speedo.Visible and width3 < data4.JumpRight)) then
        local jumpHome = _touchUi.JumpHome
        if not jumpHome or jumpHome.Button ~= jump then
            _touchUi.JumpBack()
            local data10 = {Button = jump}
            data10.Position = jump.Position
            jumpHome = data10
            _touchUi.JumpHome = jumpHome
        end
        if jumpHome.Position.Y.Scale == 1 and jump.Size.Y.Scale == 0 then
            local offset42 = -(jumpHome.Position.Y.Offset + jump.Size.Y.Offset)
            local position = jumpHome.Position
            local uDim2FromOffset = UDim2.fromOffset
            local value52 = value5 + 6
            jump.Position = position - uDim2FromOffset(0, math.max(offset42, value52) - offset42)
        end
    else
        _touchUi.JumpBack()
    end
    local tablet = data3.Tablet
    do
        local value53 = value5 + 8
        local vector2 = Vector2.new(data3.Gas.X * tablet, data3.Gas.Y * tablet)
        local vector22 = Vector2.new(data3.Brake.X * tablet, vector2.Y * data3.Brake.Y / data3.Gas.Y)
        local width422 = width + data4.Right - data3.Edge - vector2.X
        local width4222 = width422 - gap - vector22.X
        local clear3 = clear(width4222, width4222 + vector22.X, value53)
        local gas = _touchUi.Gas
        local x4 = vector2.X
        local y3 = vector2.Y
        gas.Position = UDim2.new(0, (data4.Left + width422) / data4.Scale, 1, -(data4.Bottom + value53) / data4.Scale)
        gas.Size = UDim2.fromOffset(x4 / data4.Scale, y3 / data4.Scale)
        local brake = _touchUi.Brake
        local x5 = vector22.X
        local y4 = vector22.Y
        brake.Position = UDim2.new(0, (data4.Left + width4222) / data4.Scale, 1, -(data4.Bottom + clear3) / data4.Scale)
        brake.Size = UDim2.fromOffset(x5 / data4.Scale, y4 / data4.Scale)
        local exit = _touchUi.Exit
        local x6 = vector22.X
        local pill = data3.Pill * tablet
        local clear32 = clear3 + vector22.Y + 8
        exit.Position = UDim2.new(0, (data4.Left + width4222) / data4.Scale, 1, -(data4.Bottom + clear32) / data4.Scale)
        exit.Size = UDim2.fromOffset(x6 / data4.Scale, pill / data4.Scale)
    end
    _touchUi.Exit.Visible = condition
    local arrow = data3.Arrow * tablet
    local arrow2 = arrow * 2 + gap
    local edge = data3.Edge - data4.Left
    local clear5 = clear(edge, edge + arrow2, data3.Foot)
    local pad = _touchUi.Pad
    pad.Position = UDim2.new(0, (data4.Left + edge) / data4.Scale, 1, -(data4.Bottom + clear5) / data4.Scale)
    pad.Size = UDim2.fromOffset(arrow2 / data4.Scale, arrow / data4.Scale)
    local scale3 = scale
    self:_touchLetters(scale3, tablet)
    if condition then
        arrow2 = clear5 + arrow
    else
        arrow2 = if _box.Visible then number2 else 0
    end
    if _box.Visible then
        local _radarUnit = self._radarUnit
        local uDim2New6 = UDim2.new
        scale3 = 0
        _radarUnit.Position = uDim2New6(scale3, 12, 1, -(arrow2 + 8 * scale) / scale)
    end
    local arrow2322 = arrow2 / scale + data3.FeedGap - data3.Feed
    self:_touchLifted((math.max(0, arrow2322)))
end

function data5:_bind(text, data2, callback, flag, text2)
    if not data2 or #data2 == 0 then
        return
    end
    local contextActionService2 = contextActionService
    local text3 = text
    local flag2 = false
    if text2 ~= nil then
        flag2 = not self._touch
    end
    contextActionService2:BindAction(text3, function(arg1, arg2)
        if userInputService:GetFocusedTextBox() then
            return Enum.ContextActionResult.Pass
        end
        callback(arg2)
        if flag then
            return Enum.ContextActionResult.Pass
        end
        return Enum.ContextActionResult.Sink
    end, flag2, table.unpack(data2))
    if text2 and not self._touch then
        contextActionService:SetTitle(text, text2)
    end
    self._seatMaid:Give(function()
        contextActionService:UnbindAction(text)
    end)
end

function data5:_bindPad(arg2)
    local data2 = {}
    self._pad = data2
    for key, value in arg2 do
        local key2 = gamepad[key]
        if type(key2) ~= "table" then
            continue
        end
        if #key2 == 0 then
            continue
        end
        local index = key2[1]
        if typeof(index) ~= "EnumItem" then
            continue
        end
        data2[key] = true
        local text = "PatrolPad" .. key
        local contextActionService2 = contextActionService
        local text2 = text
        local flag = false
        local value2 = value
        contextActionService2:BindAction(text2, function(arg1, arg2)
            if arg2 == Enum.UserInputState.Begin then
                if userInputService:GetFocusedTextBox() or guiService.SelectedObject ~= nil then
                    return Enum.ContextActionResult.Pass
                end
                flag = true
                value2.Down()
            elseif flag and (arg2 == Enum.UserInputState.End or arg2 == Enum.UserInputState.Cancel) then
                flag = false
                if value2.Up then
                    value2.Up()
                end
            else
                return Enum.ContextActionResult.Pass
            end
            return Enum.ContextActionResult.Sink
        end, false, table.unpack(key2))
        self._seatMaid:Give(function()
            contextActionService:UnbindAction(text)
        end)
    end
end

function data5._padChassis(arg1, arg2)
    local chassis = gamepad.Chassis
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not chassis or not playerGui then
        return
    end
    local function apply(object)
        local child = object:WaitForChild(chassis.Folder, 5)
        if not child then
            return
        end
        task.wait(0.2)
        for key, value in chassis.Map do
            local child2 = child:FindFirstChild(key)
            if child2 and child2:IsA("StringValue") then
                child2.Value = value.Name
            end
        end
    end

    for key, value in playerGui:GetChildren() do
        if value.Name ~= chassis.Gui then
            continue
        end
        task.spawn(apply, value)
    end
    local childAdded = playerGui.ChildAdded
    local function callback(object)
        if object.Name == chassis.Gui then
            task.spawn(apply, object)
        end
    end

    arg2:Give(childAdded:Connect(callback))
end

function data5._keyHelp(data, flag, data2, text)
    if flag then
        if data2.Lights then
            local lights = keys.Lights
            local lights2 = lights and lights[1]
            local text2 = (if lights2 then lights2.Name else "?") .. " lights"
            local data32 = {}
            table.insert(data32, text2)
        end
        if data2.Siren then
            local siren = keys.Siren
            local siren2 = siren and siren[1]
            local text3 = (if siren2 then siren2.Name else "?") .. " siren"
            local data4 = {}
            table.insert(data4, text3)
            local tone = keys.Tone
            local tone2 = tone and tone[1]
            local text4 = (if tone2 then tone2.Name else "?") .. " tone"
            table.insert(data4, text4)
        end
        if data2.Spotlight then
            local spotlight = keys.Spotlight
            local spotlight2 = spotlight and spotlight[1]
            local text5 = (if spotlight2 then spotlight2.Name else "?") .. " spotlight"
            local data52 = {}
            table.insert(data52, text5)
        end
        if data2.Radar then
            local radar = keys.Radar
            local radar2 = radar and radar[1]
            local text6 = (if radar2 then radar2.Name else "?") .. " radar"
            local data62 = {}
            table.insert(data62, text6)
        end
    end
    if text == "Driver" then
        local horn = keys.Horn
        local horn2 = horn and horn[1]
        local text7 = (if horn2 then horn2.Name else "?") .. " horn"
        local data7 = {}
        table.insert(data7, text7)
        local headlights = keys.Headlights
        local headlights2 = headlights and headlights[1]
        local text8 = (if headlights2 then headlights2.Name else "?") .. " headlights"
        table.insert(data7, text8)
        local lock = keys.Lock
        local lock2 = lock and lock[1]
        local text9 = (if lock2 then lock2.Name else "?") .. " lock"
        table.insert(data7, text9)
        local reset = keys.Reset
        local reset2 = reset and reset[1]
        local text10 = (if reset2 then reset2.Name else "?") .. " unstick"
        table.insert(data7, text10)
        table.insert(data7, "Shift handbrake")
        table.insert(data7, "Space exit")
    end
    return table.concat({}, "   ")
end

function data5:_resetVehicle(object, object2)
    local osClock = os.clock()
    if self._lastReset and osClock - self._lastReset < VehicleConfig.ResetCooldown then
        local resetCooldown2 = VehicleConfig.ResetCooldown - (osClock - self._lastReset)
        self:_toast("Warning", ("Wait %d s before resetting again."):format((math.ceil(resetCooldown2))))
    else
        local magnitude = object2.AssemblyLinearVelocity.Magnitude
        if VehicleConfig.ResetMaxSpeed < magnitude or object2.ReceiveAge ~= 0 then
            self:_toast("Warning", "Stop the vehicle first.")
        else
            self._lastReset = osClock
            local object3 = object
            local object22 = object2
            local position = object2.Position
            local lift = VehicleConfig.AutoReset.Lift
            local position2 = position + Vector3.new(0, lift, 0)
            local cFrameLookVector2 = object2.CFrame.LookVector * vector.create(1, 0, 1)
            if cFrameLookVector2.Magnitude < 0.1 then
                cFrameLookVector2 = vector.create(0, 0, -1)
            end
            cFrameLookVector2 = CFrame.lookAt(position2, position2 + cFrameLookVector2.Unit)
            self:_placeVehicle(object3, object22, cFrameLookVector2 * object2.CFrame:ToObjectSpace(object:GetPivot()))
        end
    end
end

function data5._placeVehicle(data, object, object2, cFrame)
    object:PivotTo(cFrame)
    object2.AssemblyLinearVelocity = vector.create(0, 0, 0)
    object2.AssemblyAngularVelocity = vector.create(0, 0, 0)
    local vector = vector.create(0, 0, 0)
    if object:GetAttribute("NativeChassis") then
        vector = object:FindFirstChild("Wheels")
    else
        vector = nil
    end
    if not vector then
        return
    end
    local cFrame3 = object2.CFrame
    for key, value in vector:GetDescendants() do
        if value:IsA("BasePart") and (not value.Anchored and value.AssemblyRootPart == value) then
            local attribute = value:GetAttribute(attributes.WheelRest)
            if typeof(attribute) == "CFrame" then
                value.CFrame = cFrame3 * attribute
            end
            value.AssemblyLinearVelocity = vector.create(0, 0, 0)
            value.AssemblyAngularVelocity = vector.create(0, 0, 0)
        end
    end
end

function data5:_watchVehicle(object, object2, arg4)
    if not VehicleConfig.AutoReset.Enabled then
        return
    end
    local value
    if arg4 then
        value = nil
    else
        value = object:FindFirstChild("Wheels")
    end
    if value then
        for key, value2 in value:GetChildren() do
            if value2:IsA("BasePart") then
                local data2 = {}
                table.insert(data2, value2)
            end
        end
    end
    if not arg4 and #{} == 0 then
        return
    end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {object}
    raycastParams.RespectCanCollide = true
    raycastParams.CollisionGroup = object2.CollisionGroup
    local data3 = {Next = 0, Resets = 0, Model = object}
    data3.Chassis = object2
    data3.Physics = arg4
    data3.Wheels = {}
    data3.Params = raycastParams
    data3.Size = object:GetExtentsSize()
    data3.Entered = os.clock()
    data3.Since = {}
    data3.Good = {}
    self._auto = data3
    self._seatMaid:Give(function()
        if self._auto == data3 then
            self._auto = nil
        end
    end)
end

function data5._mapRay(data, arg2, vector, vector2)
    for index = 1, 4 do
        local raycastResult = workspace:Raycast(vector, vector2, arg2.Params)
        if not raycastResult or isMap(raycastResult.Instance) then
            return raycastResult
        end
        arg2.Params:AddToFilter(raycastResult.Instance)
    end
    return nil
end

function data5:_wheelState(data2, cFrame)
    local autoReset = VehicleConfig.AutoReset
    local physics = data2.Physics
    local value = 0
    local value2 = 0
    if physics then
        local size = data2.Chassis.Size
        local x = size.X / 2 - 0.6
        local number = math.max(x, 0)
        local z = size.Z / 2 - 0.6
        local number2 = math.max(z, 0)
        local y2 = size.Y / 2 + autoReset.Sunk.Skin
        local vector3 = Vector3.new(0, y2, 0)
        local y3 = -size.Y
        local vector32 = Vector3.new(0, y3, 0)
        if self:_mapRay(data2, cFrame.Position + vector3, vector32) then
            value2 += 1
        end
        for key, value3 in physics.Wheels do
            if value3.Grounded then
                value += 1
            end
            local position2 = value3.Offset.Position
            local x2 = position2.X
            local number5 = math.clamp(x2, -number, number)
            local z2 = position2.Z
            local number6 = math.clamp(z2, -number2, number2)
            if self:_mapRay(data2, cFrame * Vector3.new(number5, 0, number6) + vector3, vector32) then
                value2 += 1
            end
        end
        return value, value2, 0
    end
    local height = autoReset.Sunk.Height
    local vector33 = Vector3.new(0, height, 0)
    local wheels2 = data2.Wheels
    local total = 0
    for key2, value4 in wheels2 do
        if value4.Parent then
            local position3 = value4.Position
            local workspace2 = workspace
            local position32 = position3
            local y42 = -(value4.Size.Y / 2 + autoReset.Stuck.Ground)
            if workspace2:Raycast(position32, Vector3.new(0, y42, 0), data2.Params) then
                value += 1
            end
            if self:_mapRay(data2, position3 + vector33, -vector33) then
                value2 += 1
            end
            local attribute = value4:GetAttribute(attributes.WheelRest)
            if typeof(attribute) ~= "CFrame" then
                continue
            end
            local pointToObjectSpace2 = cFrame:PointToObjectSpace(position3) - attribute.Position
            local y5 = pointToObjectSpace2.Y
            if not (autoReset.Wheels.Up < y5) then
                if not (pointToObjectSpace2.Y < -autoReset.Wheels.Down) then
                    local x32 = pointToObjectSpace2.X * pointToObjectSpace2.X + pointToObjectSpace2.Z * pointToObjectSpace2.Z
                    local number7 = math.sqrt(x32)
                    if not (autoReset.Wheels.Side < number7) then
                        continue
                    end
                end
            end
            total += 1
        end
    end
    return value, value2, total
end

function data5:_onFloorBelow(arg2, vector)
    local fell = VehicleConfig.AutoReset.Fell
    local arg22 = arg2
    local vector2 = vector
    local floor = -(fell.Floor or 8)
    local _mapRay = self:_mapRay(arg22, vector2, (Vector3.new(0, floor, 0)))
    local flag = false
    if _mapRay ~= nil then
        flag = table.find(fell.Plates or {}, _mapRay.Instance.Name) == nil
    end
    return flag
end

function data5._autoTick(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5._autoReset(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5._lastGood(data, data2, number, flag)
    local good = data2.Good
    if #good == 0 then
        return nil
    end
    local value = 1
    if not flag then
        for index = #good, 1, -1 do
            if good[index].Time <= number then
                value = index
                break
            end
        end
    end
    local items = {data2.Model}
    for key, value2 in data2.Model:GetDescendants() do
        if (value2:IsA("Seat") or value2:IsA("VehicleSeat")) and (value2.Occupant and value2.Occupant.Parent) then
            local parent = value2.Occupant.Parent
            table.insert(items, parent)
        end
    end
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = items
    overlapParams.RespectCanCollide = true
    local value3 = value
    local total = value
    for index2 = value3, 1, -1 do
        local workspace2 = workspace
        local pivot2 = good[index2].Pivot * CFrame.new(0, data2.Size.Y / 4, 0)
        local size = data2.Size
        local overlapParams2 = overlapParams
        local total2 = true
        for key2, value4 in workspace2:GetPartBoundsInBox(pivot2, size, overlapParams2) do
            if isMap(value4) then
                continue
            end
            total2 = false
            break
        end
        if total2 then
            total = index2
            break
        end
    end
    for index3 = total + 1, #good do
        table.remove(good)
    end
    return good[total].Pivot
end

function data5:_groundAbove(arg2)
    local search = VehicleConfig.AutoReset.Fell.Search
    local position = arg2.Chassis.Position
    local _mapRay = self:_mapRay(arg2, position, (Vector3.new(0, search, 0)))
    if not _mapRay then
        return nil
    end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    raycastParams.FilterDescendantsInstances = {_mapRay.Instance}
    local workspace2 = workspace
    local x = position.X
    local y = _mapRay.Position.Y + search
    local z = position.Z
    local vector32 = Vector3.new(x, y, z)
    local search3 = -search
    local raycastResult = workspace2:Raycast(vector32, Vector3.new(0, search3, 0), raycastParams)
    if raycastResult then
        return raycastResult.Position
    end
    return nil
end

function data5:_toast(text, text2)
    local tryGet = self.Registry:TryGet("NotificationController")
    if tryGet and text2 ~= "" then
        local data2 = {Title = "Vehicle", Duration = 3, Type = text}
        data2.Message = text2
        tryGet:Notify(data2)
    end
end

function data5:_buildSirenBox(object, flag)
    local create = Components.Create
    local vector2New = Vector2.new
    local data3 = {
        Name = "SirenBox",
        BorderSizePixel = 0,
        Visible = false,
        AnchorPoint = vector2New(0, 1),
    }
    data3.Position = UDim2.new(0, 12, 1, -12)
    data3.BackgroundColor3 = data2.Housing
    data3.Parent = object
    local corner2 = Components.Corner(UDim.new(0, 12))
    local stroke2 = Components.Stroke(0.78)
    local create3 = Components.Create("UIScale", {Scale = hud.Scale})
    local create4 = Components.Create
    local colorSequenceNew = ColorSequence.new
    local color = Color3.new(1, 1, 1)
    local color3FromRGB = Color3.fromRGB
    local data5 = {Rotation = 90, Color = colorSequenceNew(color, color3FromRGB(96, 96, 102))}
    local create5 = create("Frame", data3, {
        corner2,
        stroke2,
        create3,
        create4("UIGradient", data5),
    })
    self._box = create5
    local create6 = Components.Create
    local uDim2FromScale = UDim2.fromScale
    local data6 = {Name = "Keys", BackgroundTransparency = 1, Size = uDim2FromScale(1, 1)}
    data6.Parent = create5
    self._boxKeys = create6("Frame", data6)
    local label = Components.Label
    local data7 = {
        Name = "Model",
        Text = "LIGHT  /  SIREN  CONTROL",
        TextSize = 9,
        TextWrapped = false,
        Font = Theme.Fonts.Display,
    }
    data7.TextColor3 = Theme.Colors.Muted
    data7.AnchorPoint = Vector2.new(0, 1)
    data7.Position = UDim2.new(0, data2.Pad + 2, 1, -7)
    data7.Size = UDim2.fromOffset(220, 10)
    data7.Parent = create5
    label(data7)
    local label2 = Components.Label
    local stringUpper = string.upper
    local data8 = {
        Name = "Maker",
        TextSize = 9,
        TextWrapped = false,
        Text = stringUpper(GameConfig.GameName),
    }
    data8.Font = Theme.Fonts.Display
    data8.TextColor3 = Theme.Colors.SubText
    data8.TextXAlignment = Enum.TextXAlignment.Right
    data8.AnchorPoint = Vector2.new(1, 1)
    data8.Position = UDim2.new(1, -data2.Pad - 2, 1, -7)
    data8.Size = UDim2.fromOffset(220, 10)
    data8.Parent = create5
    label2(data8)
    self._keys = {}
    self:_buildRadarUnit(object)
end

function data5:_makeKey(text, uDim2, uDim22, data3)
    local create = Components.Create
    local data4 = {Text = "", BorderSizePixel = 0, Name = text}
    data4.AutoButtonColor = data3 ~= nil
    data4.Active = data3 ~= nil
    data4.BackgroundColor3 = data2.Key
    data4.Position = uDim2
    data4.Size = uDim22
    data4.Parent = self._boxKeys
    local corner2 = Components.Corner(UDim.new(0, 5))
    local create2 = Components.Create
    local uDim2FromOffset = UDim2.fromOffset
    local data5 = {Name = "Outline", BackgroundTransparency = 1, Position = uDim2FromOffset(4, 4)}
    data5.Size = UDim2.new(1, -8, 1, -8)
    local corner4 = Components.Corner(UDim.new(0, 4))
    local create3 = Components.Create
    local data6 = {Thickness = 1.5, Color = data2.Ink}
    data6.Transparency = if data3 then 0.05 else 0.84
    local items = {corner4, create3("UIStroke", data6)}
    local create4 = create("TextButton", data4, {corner2, create2("Frame", data5, items)})
    if not data3 then
        return
    end
    local create5 = Components.Create
    local uDim2FromOffset2 = UDim2.fromOffset
    local data7 = {
        Name = "Label",
        BackgroundTransparency = 1,
        TextSize = 9,
        TextWrapped = true,
        Position = uDim2FromOffset2(4, 7),
    }
    data7.Size = UDim2.new(1, -8, 1, -24)
    data7.Font = Theme.Fonts.Bold
    data7.Text = hud.Labels[text] or string.upper(text)
    data7.TextColor3 = data2.Ink
    data7.Parent = create4
    local create6 = create5("TextLabel", data7)
    local create7 = Components.Create
    local vector2New = Vector2.new
    local data8 = {
        Name = "Hint",
        BackgroundTransparency = 1,
        TextSize = 8,
        AnchorPoint = vector2New(0, 1),
    }
    data8.Position = UDim2.new(0, 0, 1, -7)
    data8.Size = UDim2.new(1, 0, 0, 9)
    data8.Font = Theme.Fonts.Medium
    local medium = Theme.Fonts.Medium
    if data3.Key then
        local key = data3.Key
        medium = config[key.Name]
        if not medium then
            medium = key.Name
        end
    else
        medium = ""
    end
    data8.Text = medium
    data8.TextColor3 = Theme.Colors.SubText
    data8.Parent = create4
    local create8 = create7("TextLabel", data8)
    if self._touch then
        self:_touchPress(create4, data3)
    elseif data3.Up then
        local flag = false
        local function release()
            if flag then
                flag = false
                data3.Up()
            end
        end

        create4.MouseButton1Down:Connect(function()
            flag = true
            data3.Down()
        end)
        create4.MouseButton1Up:Connect(release)
        create4.MouseLeave:Connect(release)
    else
        create4.Activated:Connect(function()
            data3.Down()
        end)
    end
    local _keys = self._keys
    local data9 = {On = false, Button = create4}
    data9.Label = create6
    data9.Hint = create8
    data9.HintText = create8.Text
    _keys[text] = data9
end

function data5._makeStage(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5:_makeDisplay(uDim2, uDim22)
    local create = Components.Create
    local data2 = {Name = "Display", BorderSizePixel = 0, BackgroundColor3 = Theme.Colors.Inset}
    data2.Position = uDim2
    data2.Size = uDim22
    data2.Parent = self._boxKeys
    local corner2 = Components.Corner(UDim.new(0, 4))
    local stroke = Components.Stroke
    local create2 = create("Frame", data2, {corner2, stroke(0.78)})
    local function line(text, number, arg3, number2, color3)
        local label = Components.Label
        local data = {
            RichText = true,
            Text = "",
            TextWrapped = false,
            Name = text,
        }
        data.Font = arg3
        data.TextSize = number2
        data.TextColor3 = color3
        data.TextTruncate = Enum.TextTruncate.AtEnd
        data.Position = UDim2.fromOffset(9, number)
        data.Size = UDim2.new(1, -18, 0, 15)
        data.Parent = create2
        return label(data)
    end

    local line2 = line
    local bold = Theme.Fonts.Bold
    local data3 = {Status = line2("Status", 6, bold, 11, Theme.Colors.Text)}
    data3.Sub = line("Sub", 24, Theme.Fonts.Regular, 10, Theme.Colors.SubText)
    self._display = data3
end

function data5:_showSirenBox(data3, data4)
    self._boxKeys:ClearAllChildren()
    self._keys = {}
    self._stage = nil
    self._display = nil
    local cell = data2.Cell
    local gap = data2.Gap
    local pad = data2.Pad
    local data32 = data3
    local total = 0
    for key, value in data32 do
        local count = #value
        total = math.max(total, count)
        local total3 = 1
        while total3 <= #value do
            local total32 = value[total3]
            local total4 = 1
            while (total32 == "Display" or total32 == "Stage") and value[total3 + total4] == total32 do
                total4 += 1
            end
            local uDim2FromOffset2 = UDim2.fromOffset(pad + (total3 - 1) * (cell.X + gap), pad + (key - 1) * (cell.Y + gap))
            local uDim2FromOffset4 = UDim2.fromOffset(total4 * cell.X + (total4 - 1) * gap, cell.Y)
            if total32 == "Display" then
                self:_makeDisplay(uDim2FromOffset2, uDim2FromOffset4)
            elseif total32 == "Stage" then
                self:_makeStage(uDim2FromOffset2, uDim2FromOffset4, data4.Stage)
            else
                self:_makeKey(total32, uDim2FromOffset2, uDim2FromOffset4, data4[total32])
            end
            total3 += total4
        end
    end
    local pad3222 = pad * 2 + #data3 * cell.Y + (#data3 - 1) * gap + data2.Footer
    local _box = self._box
    _box.Size = UDim2.fromOffset(pad * 2 + total * cell.X + (total - 1) * gap, pad3222)
    _box.Visible = true
    self._radarUnit.Position = UDim2.new(0, _box.Position.X.Offset, 1, _box.Position.Y.Offset - (pad3222 + 8) * hud.Scale)
    self:_setRadarShown(self._radarOn)
    if not data4.Radar then
        self._radarUnit.Visible = false
        self:_liftRadio()
    end
    self:_padHints()
    if self._touch then
        self:_touchLights(data4)
    end
end

function data5:_padHints()
    local active = Pad.Active()
    local _pad = self._pad or {}
    local function picture(object, text, arg3, uDim2, vector2)
        local child = object:FindFirstChild(text)
        local result = object
        if arg3 then
            result = Pad
            result = result.Image
            result = result(arg3)
        else
            result = ""
        end
        if result == "" then
            if child then
                child.Visible = false
            end
            return false
        end
        if not child then
            local create = Components.Create
            local data = {BackgroundTransparency = 1, Name = text}
            data.AnchorPoint = vector2
            data.Position = uDim2
            data.Size = UDim2.fromOffset(12, 12)
            data.ImageColor3 = Theme.Colors.SubText
            data.ScaleType = Enum.ScaleType.Fit
            data.Parent = object
            child = create("ImageLabel", data)
        end
        child.Image = result
        child.Visible = true
        return true
    end

    for key, value in self._keys or {} do
        local key2 = gamepad.Panel[key]
        local panel = gamepad.Panel
        if active and (key2 and _pad[key2]) then
            panel = gamepad[key2]
        else
            panel = nil
        end
        local index = if type(panel) == "table" then panel[1] else nil
        local picture3 = picture(value.Button, "PadHint", index, UDim2.new(0.5, 0, 1, -5), Vector2.new(0.5, 1))
        if value.Hint then
            local hint = value.Hint
            local value2
            if not active then
                value2 = value.HintText
            elseif index and not picture3 then
                value2 = Pad
                value2 = value2.Name
                value2 = value2(index)
            else
                value2 = ""
            end
            hint.Text = value2
        end
    end
    local _stage = self._stage
    if _stage and _stage.Hint then
        local result = active
        if result then
            result = _pad.StageUp
            if result then
                result = _pad.StageDown
            end
        end
        local picture4 = picture
        local button2 = _stage.Button
        local value3
        if result then
            value3 = gamepad.StageDown[1]
        else
            value3 = nil
        end
        local uDim22 = UDim2.new(1, -18, 1, 3)
        value3 = picture4(button2, "PadDown", value3, uDim22, Vector2.new(1, 1))
        local picture6 = picture
        local button3 = _stage.Button
        if result then
            uDim22 = gamepad.StageUp[1]
        else
            uDim22 = nil
        end
        uDim22 = picture6(button3, "PadUp", uDim22, UDim2.new(1, -3, 1, 3), Vector2.new(1, 1))
        local hint2 = _stage.Hint
        local value4
        if not active then
            value4 = _stage.HintText
        elseif result and (not value3 or not uDim22) then
            value4 = "LIGHTS   %s %s"
            value4 = value4:format(Pad.Name(gamepad.StageDown[1]), Pad.Name(gamepad.StageUp[1]))
        else
            value4 = "LIGHTS"
        end
        hint2.Text = value4
    end
    if self._mdtCap then
        self._mdtCap.Visible = not active and not self._phone
    end
end

function data5:_hideSirenBox()
    self._box.Visible = false
    self._radarUnit.Visible = false
    self:_liftRadio()
    if self._touch then
        self:_touchLights(nil)
    end
end

function data5:_liftRadio()
    local tryGet = self.Registry:TryGet("RadioController")
    if tryGet then
        local value
        if self._radarUnit.Visible then
            value = (self._radarUnit.Size.Y.Offset + 8) * hud.Scale
        else
            value = 0
        end
        tryGet:SetLift(value + (self._touchLift or 0))
    end
end

function data5:_keyLit(text, flag, color3)
    local text2 = self._keys[text]
    if text2 and text2.On ~= flag then
        text2.On = flag
        local button = text2.Button
        local value
        if flag then
            value = color3
            if not value then
                value = color
            end
        else
            value = data2
            value = value.Key
        end
        button.BackgroundColor3 = value
    end
end

function data5:_keyText(text, text2)
    local text3 = self._keys[text]
    if text3 and text3.Label.Text ~= text2 then
        text3.Label.Text = text2
    end
end

function data5:_setStage(number)
    local _stage = self._stage
    if not _stage or _stage.Shown == number then
        return
    end
    local condition = _stage.Shown < 0
    _stage.Shown = number
    local uDim2FromOffset = UDim2.fromOffset
    local left = _stage.Left
    local travel = _stage.Travel
    local max = _stage.Max
    local travel2 = travel * math.clamp(number, 0, max)
    local uDim2FromOffset2 = uDim2FromOffset(left + travel2 / _stage.Max, 3)
    local max2 = _stage.Max
    if condition then
        _stage.Knob.Position = uDim2FromOffset2
    else
        local tweenService2 = tweenService
        local knob = _stage.Knob
        travel2 = TweenInfo.new
        max2 = 0.12
        travel2 = travel2(max2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        max2 = {}
        max2.Position = uDim2FromOffset2
        ;(tweenService2:Create(knob, travel2, max2)):Play()
    end
    _stage.Knob.BackgroundColor3 = if number > 0 then color else data2.Knob
    for key, value in _stage.Marks do
        value.TextColor3 = if key == number then data2.Ink else Theme.Colors.Muted
    end
end

function data5:_setDisplay(text, text2)
    local _display = self._display
    if not _display then
        return
    end
    if text and _display.Status.Text ~= text then
        _display.Status.Text = text
    end
    if text2 and _display.Sub.Text ~= text2 then
        _display.Sub.Text = text2
    end
end

function data5:_buildRadarUnit(object)
    local create = Components.Create
    local vector2New = Vector2.new
    local data3 = {
        Name = "Radar",
        BorderSizePixel = 0,
        Visible = false,
        AnchorPoint = vector2New(0, 1),
    }
    data3.Size = UDim2.fromOffset(352, 76)
    data3.BackgroundColor3 = data2.Housing
    data3.Parent = object
    local corner2 = Components.Corner(UDim.new(0, 10))
    local stroke2 = Components.Stroke(0.78)
    local create3 = Components.Create("UIScale", {Scale = hud.Scale})
    local create4 = Components.Create
    local colorSequenceNew = ColorSequence.new
    local color = Color3.new(1, 1, 1)
    local color3FromRGB = Color3.fromRGB
    local data5 = {Rotation = 90, Color = colorSequenceNew(color, color3FromRGB(96, 96, 102))}
    local create5 = create("Frame", data3, {
        corner2,
        stroke2,
        create3,
        create4("UIGradient", data5),
    })
    self._radarUnit = create5
    local function window(text, text2, number, number2, color3)
        local label = Components.Label
        local data = {TextSize = 9, TextWrapped = false, Name = text .. "Caption"}
        data.Text = text2
        data.Font = Theme.Fonts.Display
        data.TextColor3 = Theme.Colors.SubText
        data.Position = UDim2.fromOffset(number + 2, 9)
        data.Size = UDim2.fromOffset(number2, 10)
        data.Parent = create5
        label(data)
        local create = Components.Create
        local data2 = {BorderSizePixel = 0, Name = text}
        data2.BackgroundColor3 = Theme.Colors.Inset
        data2.Position = UDim2.fromOffset(number, 23)
        data2.Size = UDim2.fromOffset(number2, 40)
        data2.Parent = create5
        local corner2 = Components.Corner(UDim.new(0, 4))
        local stroke = Components.Stroke
        local create2 = create("Frame", data2, {corner2, stroke(0.82)})
        local create3 = Components.Create
        local uDim2FromScale = UDim2.fromScale
        local data3 = {
            Name = "Value",
            BackgroundTransparency = 1,
            Text = "--",
            TextSize = 26,
            Size = uDim2FromScale(1, 1),
        }
        data3.Font = Theme.Fonts.Display
        data3.TextColor3 = color3
        data3.Parent = create2
        return create3("TextLabel", data3)
    end

    local data6 = {Target = window("Target", "TARGET", 14, 88, color5)}
    data6.Fast = window("Fast", "FAST", 108, 88, color5)
    data6.Patrol = window("Patrol", "PATROL", 202, 88, Theme.Colors.Good)
    data6.Limit = window("Limit", "LIMIT", 296, 42, Theme.Colors.Text)
    self._radarParts = data6
    for key, value in self._radarParts do
        value.FontFace = Theme.Faces.DisplayBold
    end
    self._radarParts.Limit.TextSize = 16
end

function data5:_setRadarShown(flag)
    self._radarOn = flag
    self._radarUnit.Visible = flag and self._box.Visible
    self._lastRadar = nil
    self:_keyLit("Radar", flag, color4)
    self:_liftRadio()
end

function data5:_setRadar(number, number2, number3, number4)
    local _radarParts = self._radarParts
    local function show(object, number)
        local value
        if number then
            local number2 = number + 0.5
            local number3 = math.floor(number2)
            value = tostring(number3)
        else
            value = "--"
        end
        object.Text = value
        if number and number4 + hud.OverLimit < number then
            value = Theme
            value = value.Colors
            value = value.Bad
        else
            value = color5
        end
        object.TextColor3 = value
    end

    local target = _radarParts.Target
    local value
    if number then
        local number5 = number + 0.5
        local number6 = math.floor(number5)
        value = tostring(number6)
    else
        value = "--"
    end
    target.Text = value
    if number and number4 + hud.OverLimit < number then
        value = Theme
        value = value.Colors
        value = value.Bad
    else
        value = color5
    end
    target.TextColor3 = value
    local fast = _radarParts.Fast
    if number2 then
        local number22 = number2 + 0.5
        local number7 = math.floor(number22)
        value = tostring(number7)
    else
        value = "--"
    end
    fast.Text = value
    if number2 and number4 + hud.OverLimit < number2 then
        value = Theme
        value = value.Colors
        value = value.Bad
    else
        value = color5
    end
    fast.TextColor3 = value
    local patrol = _radarParts.Patrol
    local number32 = number3 + 0.5
    local number8 = math.floor(number32)
    patrol.Text = tostring(number8)
    _radarParts.Limit.Text = tostring(number4)
end

function data5:_buildMdtButton(flag)
    local create2 = Components.Create("ScreenGui", {
        Name = "PatrolCarMDT",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 11,
        Enabled = false,
        Parent = localPlayer:WaitForChild("PlayerGui"),
    })
    local button = Components.Button
    local data4 = {
        Name = "OpenMDT",
        Text = "MDT",
        TextSize = 12,
        BackgroundTransparency = 0.14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }
    data4.AnchorPoint = Vector2.new(1, 1)
    local uDim2New = UDim2.new
    local width = data.Width
    data4.Position = uDim2New(1, -12 - width * hud.Scale - 8, 1, if flag then -150 else -12)
    data4.Size = UDim2.fromOffset(74, 28)
    data4.BackgroundColor3 = Theme.Colors.Panel
    data4.Parent = create2
    local button2 = button(data4)
    local create3 = Components.Create
    local uDimNew = UDim.new
    local data5 = {PaddingLeft = uDimNew(0, 11)}
    data5.Parent = button2
    create3("UIPadding", data5)
    local keyCap2 = Components.KeyCap(Keys.Label("MDT"))
    keyCap2.AnchorPoint = Vector2.new(1, 0.5)
    keyCap2.Position = UDim2.new(1, -7, 0.5, 0)
    keyCap2.Parent = button2
    Keys.Changed:Connect(function()
        keyCap2.Text = Keys.Label("MDT")
    end)
    self._mdtCap = keyCap2
    button2.Activated:Connect(function()
        local tryGet = self.Registry:TryGet("MDTController")
        if tryGet then
            tryGet:Toggle("Vehicle")
        end
    end)
    self._mdtGui = create2
end

function data5._buildSpeedo(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5:_setKeyHelp(text)
    local _keysPlate = self._keysPlate
    local _keysLabel = self._keysLabel
    _keysLabel.Text = text
    _keysPlate.Visible = hud.KeyGuide == true and text ~= ""
    if text ~= "" then
        local textSize2 = textService:GetTextSize(text, _keysLabel.TextSize, _keysLabel.Font, Vector2.new(data.KeysWidth - 22, 1000))
        _keysPlate.Size = UDim2.fromOffset(data.KeysWidth, textSize2.Y + 11)
    end
end

function data5:_moveCarGuis(arg2)
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end
    local function move(object)
        local name = hud.CarGuis[object.Name]
        local name2 = name and object:WaitForChild(name.Frame, 3)
        if name2 and name2:IsA("GuiObject") then
            name2.Position = name.Position
            local _touchUi = self._touchUi
            if _touchUi and self._touch then
                local carFrames = _touchUi.CarFrames
                local data = {AnchorPoint = name2.AnchorPoint}
                data.Position = name.Position
                data.Size = name2.Size
                carFrames[name2] = data
                self:_touchPlace()
            end
        end
    end

    for key, value in playerGui:GetDescendants() do
        if hud.CarGuis[value.Name] then
            task.spawn(move, value)
        end
    end
    local descendantAdded = playerGui.DescendantAdded
    local function callback(object)
        if hud.CarGuis[object.Name] then
            task.spawn(move, object)
        end
    end

    arg2:Give(descendantAdded:Connect(callback))
end

function data5:_buildHud()
    local create = Components.Create
    local data2 = {
        Name = "VehicleHUD",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 11,
        Enabled = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }
    data2.Parent = localPlayer:WaitForChild("PlayerGui")
    local create2 = create("ScreenGui", data2)
    self._hud = create2
    local touchEnabled = userInputService.TouchEnabled
    if touchEnabled then
        touchEnabled = not userInputService.KeyboardEnabled
    end
    if runService:IsStudio() then
        if workspace:GetAttribute("DebugTouch") ~= nil then
            touchEnabled = true
        end
    end
    self._touch = touchEnabled
    local create22 = create2
    local touchEnabled2 = touchEnabled
    self:_buildSpeedo(create22, touchEnabled2)
    create22, touchEnabled2 = create2, touchEnabled
    self:_buildSirenBox(create22, touchEnabled2)
    self:_buildMdtButton(touchEnabled)
    local panel = Components.Panel
    local vector2New = Vector2.new
    local data3 = {
        Name = "ALPRAlert",
        BackgroundTransparency = 0.1,
        Visible = false,
        AnchorPoint = vector2New(0.5, 0),
    }
    data3.Position = UDim2.new(0.5, 0, 0, 70)
    data3.Size = UDim2.fromOffset(420, 64)
    data3.BackgroundColor3 = color3
    data3.Parent = create2
    self._alert = panel(data3)
    ;(Components.Padding(8, 14)).Parent = self._alert
    Components.KeepUnderTopBar(create2, self._alert, 12)
    local label = Components.Label
    local data4 = {Name = "Text", RichText = true, Font = Theme.Fonts.Bold}
    data4.Size = UDim2.fromScale(1, 1)
    data4.Parent = self._alert
    self._alertLabel = label(data4)
end

function data5:_radar(object)
    local radar = VehicleConfig.Radar
    local coneAngle = radar.ConeAngle
    local number = math.rad(coneAngle)
    local number2 = math.cos(number)
    local cFrame = object.CFrame
    local vehicle2 = vehicle
    local total = nil
    local total2 = (1 / 0)
    local total3 = nil
    for key, value in collectionService:GetTagged(vehicle2) do
        if value == self._vehicle then
            continue
        end
        if value:IsA("Model") then
            local chassis = value:FindFirstChild("Chassis") or value:FindFirstChild("DriveSeat")
            local flag = value:IsA("Model")
            if chassis and chassis:IsA("BasePart") then
                flag = chassis
            else
                flag = nil
            end
            if flag then
                local position = flag.Position - cFrame.Position
                local magnitude = position.Magnitude
                if magnitude <= radar.Range and magnitude > 2 then
                    if number2 <= position.Unit:Dot(cFrame.LookVector) then
                        local magnitude22 = flag.AssemblyLinearVelocity.Magnitude * speedToMph
                        if magnitude < total2 then
                            total, total2 = magnitude22, magnitude
                        end
                        if not total3 or total3 < magnitude22 then
                            total3 = magnitude22
                        end
                    end
                end
            end
        end
    end
    return total, total3
end

function data5:_setSpeedo(number, text, number2, data3)
    local _speedoParts = self._speedoParts
    local speed = _speedoParts.Speed
    local number3 = number + 0.5
    local number4 = math.floor(number3)
    local number5 = math.min(number4, 999)
    speed.Text = tostring(number5)
    _speedoParts.Gear.Text = text
    local condition = number2 + hud.OverLimit < number
    local arc = _speedoParts.Arc
    local overLimit = hud.OverLimit
    if condition then
        overLimit = Theme
        overLimit = overLimit.Colors
        overLimit = overLimit.Bad
    else
        overLimit = if number2 + 0.5 < number then Theme.Colors.Warning else Theme.Colors.Text
    end
    arc.Color = overLimit
    local sweep = _speedoParts.Sweep
    local number6 = number / hud.DialMax
    sweep.Rotation = math.clamp(number6, 0, 1) * 180 + 270
    _speedoParts.Sign.BackgroundColor3 = if condition then Theme.Colors.Bad else data.Sign
    local text2 = tostring(number2)
    local number7 = math.clamp(number6, 0, 1)
    if _speedoParts.Limit.Text ~= text2 then
        _speedoParts.Limit.Text = text2
        number6 = number2 / hud.DialMax
        number7 = math.clamp(number6, 0, 1)
        local value = 3.141592653589793 * (1 - number7)
        number7 = data
        number7 = number7.Diameter
        number6 = data
        number6 = number6.Thickness
        local number72 = (number7 - number6) / 2
        local notch = _speedoParts.Notch
        number7 = UDim2.fromOffset
        number6 = data.Width / 2 + number72 * math.cos(value)
        number7 = number7(number6, data.Top + data.Diameter / 2 - number72 * math.sin(value))
        notch.Position = number7
        local notch2 = _speedoParts.Notch
        number6 = math.deg(value)
        number7 = 90 - number6
        notch2.Rotation = number7
    end
    for key, value5 in _speedoParts.Tags do
        local key2 = data3[key]
        value5.Visible = key2 ~= nil
        if key2 then
            value5.Text = key2[1]
            value5.TextColor3 = key2[2] or Theme.Colors.Text
        end
    end
end

function data5:_subLine()
    local _definition = self._definition
    if _definition and (_definition.Equipment and _definition.Equipment.ALPR) then
        return self:_alprLine()
    end
    local _vehicle = self._vehicle
    local _vehicle2 = _vehicle and _vehicle:GetAttribute(attributes.Plate)
    return ("%s  <b>%s</b>"):format(string.upper(if _definition then _definition.Name else ""), if type(_vehicle2) == "string" then _vehicle2 else "")
end

function data5:_alprLine()
    local index = self._reads[1]
    if not index then
        return "ALPR  scanning..."
    end
    local plate = index.Plate
    local count = #index.Flags
    local value
    if count > 0 then
        value = "<font color=\"#ff5050\">%s</font>"
        value = value:format(index.Flags[1])
    else
        value = "<font color=\"#46c46e\">clear</font>"
    end
    local colour = index.Colour or ""
    local text = tostring(colour)
    local model = index.Model or ""
    return ("ALPR  <b>%s</b>  %s  %s %s"):format(plate, value, text, (tostring(model)))
end

function data5._updateHud(...)
    error("irreducible bytecode cannot be decompiled safely")
end

function data5:_resetALPR()
    table.clear(self._reads)
    self._alertToken = (self._alertToken or 0) + 1
    if self._alert then
        self._alert.Visible = false
    end
    self:_elsBeep()
    Net.Fire("Vehicles", "ResetALPR")
    self:_setDisplay(nil, self:_subLine())
end

function data5:_onALPR(data2)
    local plate = data2.Plate
    if type(plate) ~= "string" or type(data2.Flags) ~= "table" then
        return
    end
    local _reads = self._reads
    table.insert(_reads, 1, data2)
    if #self._reads > 10 then
        table.remove(self._reads)
    end
    if #data2.Flags == 0 then
        return
    end
    local _vehicle = self._vehicle
    if _vehicle then
        local _vehicle2 = self._vehicle
        local chassis = _vehicle2:FindFirstChild("Chassis") or _vehicle2:FindFirstChild("DriveSeat")
        if chassis and chassis:IsA("BasePart") then
            _vehicle = chassis
        else
            _vehicle = nil
        end
    end
    SoundUtil.Play("ALPRAlert", _vehicle or workspace.CurrentCamera)
    local _alertLabel = self._alertLabel
    local plate2 = data2.Plate
    local colour = data2.Colour
    local text = tostring(colour)
    local model = data2.Model
    local text2 = tostring(model)
    local distance = data2.Distance
    _alertLabel.Text = ("ALPR HIT  %s\n<font size=\"13\">%s %s, %d studs ahead: %s</font>"):format(plate2, text, text2, tonumber(distance) or 0, table.concat(data2.Flags, ", "))
    self._alert.Visible = true
    self._alert.BackgroundTransparency = 0.1
    local _alertToken = (self._alertToken or 0) + 1
    self._alertToken = _alertToken
    task.delay(6, function()
        if self._alertToken == _alertToken then
            (tweenService:Create(self._alert, TweenInfo.new(0.4), {BackgroundTransparency = 1})):Play()
            task.wait(0.4)
            if self._alertToken == _alertToken then
                self._alert.Visible = false
            end
        end
    end)
end

return data5
