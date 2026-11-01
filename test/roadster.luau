local ContextActionService_upv_1 = game:GetService("ContextActionService")
local MarketplaceService_upv_1 = game:GetService("MarketplaceService")
local GuiService_upv_1 = game:GetService("GuiService")
local Players_1 = game:GetService("Players")
local ReplicatedStorage_upv_1 = game:GetService("ReplicatedStorage")
local RunService_upv_1 = game:GetService("RunService")
local UserInputService_upv_1 = game:GetService("UserInputService")
local Workspace_upv_1 = game:GetService("Workspace")
local Lighting_upv_1 = game:GetService("Lighting")
local Parent_1 = script.Parent.Parent
local Theme_upv_1 = require(Parent_1.Client.Theme)
local Layout_upv_1 = require(Parent_1.Client.Layout)
local Menu_upv_1 = require(Parent_1.Client.Menu)
local Signals_upv_1 = require(Parent_1.Achievements.Signals)
local Index_upv_1 = require(script.Parent.Index)
local Track_upv_1 = require(script.Parent.Track)
local Course_upv_1 = require(script.Parent.Course)
local Portal_upv_1 = require(script.Parent.Portal)
local Obby_upv_1 = require(Parent_1.Obby)
local Portal_upv_2 = require(Parent_1.Obby.Portal)
local Config_upv_1 = require(Parent_1.Config)
local tbl_upv_1 = {}
local tbl_upv_2 = {}
tbl_upv_2.turbo = {Time = 1, Accel = 70}
local C_upv_1 = Theme_upv_1.C
local F_upv_1 = Theme_upv_1.F
local LocalPlayer_upv_1 = Players_1.LocalPlayer
local u1 = nil
local u2 = nil
local u3 = nil
local u4 = "idle"
local tbl_upv_3 = nil
local u5 = nil
local u6 = nil
local u7 = nil
local u8 = true
local u9 = {Bests = 0, Unlocked = 1, Next = 1}
u9.Bests = {}
local u10 = nil
local u11 = nil
local u12 = nil
local u13 = nil
local u14 = 0
local u15 = nil
local u16 = nil
local u17 = false
local u18 = 0
local u19 = true
local u20 = false
local u21 = 0
local function tracker()
    --[[
      name: tracker
      line: 82
      upvalues:
        u1 (ref, index: 1)
    ]]
    local v1 = u1 and (u1.Ui)
    return v1
end
local function banner(a1)
    --[[
      name: banner
      line: 86
      upvalues:
        u1 (ref, index: 1)
    ]]
    local v2 = u1 and (u1.Ui)
    if not v2 then
        return
    end
    v2:Banner(a1)
end
local function isObby()
    --[[
      name: isObby
      line: 105
      upvalues:
        tbl_upv_3 (ref, index: 1)
    ]]
    local v3 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    return v3
end
local function stageOf(a1)
    --[[
      name: stageOf
      line: 110
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Obby_upv_1 (copy, index: 2)
    ]]
    local v4 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[a1]))
    if not v4 then
        return Obby_upv_1.Stage(a1)
    end
    local tbl_4 = {}
    tbl_4.Name = v4.Name
    tbl_4.Hint = v4.Hint
    return tbl_4
end
local function stageLine(a1)
    --[[
      name: stageLine
      line: 118
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Obby_upv_1 (copy, index: 2)
    ]]
    local format_1 = string.format
    local v5 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[a1]))
    local v6
    if v5 then
        v6 = {}
        v6.Name = v5.Name
        v6.Hint = v5.Hint
    else
        v6 = Obby_upv_1.Stage(a1)
    end
    return format_1("CHECKPOINT %d  \194\183  %s", a1, v6.Name)
end
local function obbyWindow(a1)
    --[[
      name: obbyWindow
      line: 126
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Course_upv_1 (copy, index: 2)
    ]]
    local v7 = tbl_upv_3 and (tbl_upv_3.Tower)
    if not v7 then
        return
    end
    if not (v7.Busy) then
        v7:Ensure((a1 + 3) + 1)
    end
    local v8 = tbl_upv_3:Final()
    for n_1 = tbl_upv_3.GatesAdded + 1, v8 do
        local v9 = tbl_upv_3.Sections[n_1]
        table.insert(tbl_upv_3.StageGates, v9.Gate)
        table.insert(tbl_upv_3.Waypoints, v9.Gate)
        tbl_upv_3.StageFloor[n_1] = v9.Floor
        for _, value_1 in v9.Zones do
            table.insert(tbl_upv_3.Zones, value_1)
        end
        tbl_upv_3.GatesAdded = n_1
    end
    if v8 > 0 then
        tbl_upv_3.StageFloor[v8 + 1] = tbl_upv_3.Sections[v8].Y - 300
    end
    local v10 = math.max(1, a1 - 1)
    local v11 = math.min(a1 + 3, v8)
    for n_2 = v10, v11 do
        if not (tbl_upv_3.Built[n_2]) then
            local v12 = Instance.new("Folder")
            v12.Name = "Section" .. n_2
            Course_upv_1.Build(tbl_upv_3.Sections[n_2].Parts, v12)
            v12.Parent = tbl_upv_3.Folder
            tbl_upv_3.Built[n_2] = v12
        end
    end
    for key_1, value_2 in tbl_upv_3.Built do
        if key_1 < v10 - 1 or v11 + 1 < key_1 then
            value_2:Destroy()
            tbl_upv_3.Built[key_1] = nil
        end
    end
    local v13 = ((not (a1 > 0)) and 0) or (tbl_upv_3.Sections[a1].Y)
    local v14 = v13 - tbl_upv_3.Origin.Y
    local v15 = math.max(0, math.floor((v14 - 700) / tbl_upv_3.CHUNK))
    local v16 = math.floor((v14 + 1500) / tbl_upv_3.CHUNK)
    for n_3 = v15, v16 do
        if not (tbl_upv_3.Walls[n_3]) then
            v14 = Instance.new("Folder")
            v14.Name = "Walls" .. n_3
            Course_upv_1.Build(tbl_upv_3:Walls(n_3), v14)
            v14.Parent = tbl_upv_3.Folder
            tbl_upv_3.Walls[n_3] = v14
        end
    end
    for key_2, value_3 in tbl_upv_3.Walls do
        if key_2 < v15 or v16 < key_2 then
            value_3:Destroy()
            tbl_upv_3.Walls[key_2] = nil
        end
    end
end
local function place(a1, a2)
    --[[
      name: place
      line: 200
    ]]
    a1:PivotTo(a2)
    a1.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    a1.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end
local function teleport(a1, a2)
    --[[
      name: teleport
      line: 206
      upvalues:
        Signals_upv_1 (copy, index: 1)
    ]]
    Signals_upv_1.Fire("Reset", "teleport")
    a1:PivotTo(a2)
    a1.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    a1.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end
local function notRoadster(a1)
    --[[
      name: notRoadster
      line: 213
      upvalues:
        u2 (ref, index: 1)
    ]]
    if a1 and (a1:GetAttribute("Model") or "Roadster") ~= "Roadster" then
        if u2 then
            u2:Flash("TRACKS is ROADSTER ONLY  -  swap back to the Roadster in the garage", 4)
        end
        return true
    end
    return false
end
local function fetchProgress()
    --[[
      name: fetchProgress
      line: 223
      upvalues:
        u3 (ref, index: 1)
        u9 (ref, index: 2)
    ]]
    local success_1, v17 = pcall(u3.InvokeServer, u3, "Progress")
    if success_1 and type(v17) == "table" then
        u9 = v17
    end
    return u9
end
local startRun = nil
local backToHub = nil
local hidePanel = nil
local syncCity = nil
local u22 = nil
local u23 = false
function tbl_upv_1.FilterInput(a1, a2)
    --[[
      name: FilterInput
      line: 239
      upvalues:
        u22 (ref, index: 1)
        u23 (ref, index: 2)
        u4 (ref, index: 3)
    ]]
    u22 = a2
    u23 = (a1 ~= nil) and (a1.Lift == true)
    if a2 then
        a2.Racing = u4 ~= "idle"
    end
    if a1 then
        if u4 ~= "idle" then
            a1.Ability = false
        end
        if u4 ~= "idle" and u4 ~= "racing" then
            a1.Lift = false
            a1.Boost = false
            a1.Roll = 0
            a1.Ability = false
            a1.Throttle = 0
            a1.Steer = 0
            a1.Pitch = 0
        end
    end
    return a1
end
function tbl_upv_1.Active()
    --[[
      name: Active
      line: 265
      upvalues:
        u4 (ref, index: 1)
    ]]
    local v18 = u4 ~= "idle"
    return v18
end
local function drivenCar()
    --[[
      name: drivenCar
      line: 186
      upvalues:
        LocalPlayer_upv_1 (copy, index: 1)
        Workspace_upv_1 (copy, index: 2)
    ]]
    local Character_1 = LocalPlayer_upv_1.Character
    local v19 = Character_1 and (Character_1:FindFirstChildOfClass("Humanoid"))
    Character_1 = v19
    local _ = Character_1 and (v19.SeatPart)
    local Roadsters_1 = Workspace_upv_1:FindFirstChild("Roadsters")
    while Character_1 and (Character_1.Parent) and Character_1.Parent ~= Roadsters_1 do
        Character_1 = Character_1.Parent
    end
    if Character_1 and Character_1.Parent == Roadsters_1 and Character_1:IsA("Model") and Character_1.PrimaryPart then
        return Character_1
    end
    return nil
end
function tbl_upv_1.Checkpoint()
    --[[
      name: Checkpoint
      line: 271
      upvalues:
        u4 (ref,  index: 1)
        u5 (ref,  index: 2)
        tbl_upv_3 (ref,  index: 3)
        hidePanel (ref,  index: 4)
        startRun (ref,  index: 5)
        drivenCar (copy, index: 6)
        LocalPlayer_upv_1 (copy, index: 7)
        Signals_upv_1 (copy, index: 8)
        u22 (ref,  index: 9)
    ]]
    if u4 ~= "racing" and u4 ~= "countdown" then
        local v20 = u4 ~= "idle"
        return v20
    end
    if not (u5) or u5.CpCount == 0 then
        local v21 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        if not (v21) then
            hidePanel(true)
            startRun()
            return true
        end
    end
    local v22 = drivenCar()
    local v23 = LocalPlayer_upv_1:GetAttribute("RoadsterCheckpoint")
    if v22 and v23 then
        Signals_upv_1.Fire("Reset", "teleport")
        v22:PivotTo(v23)
        v22.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        v22.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        u5.LastPos = nil
        if u22 then
            u22.Pull = nil
            u22.GravityUp = nil
            u22.Gas = 1
        end
    end
    return true
end
local tbl_upv_5 = nil
local passedHere = nil
local skipLevel = nil
local afterSkip = nil
local u24 = nil
local syncNav = nil
local function nextEntry()
    --[[
      name: nextEntry
      line: 303
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Index_upv_1 (copy, index: 2)
        u9 (ref,  index: 3)
    ]]
    local v24 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
    if v24 and v24.Level <= u9.Unlocked then
        return v24
    end
    return nil
end
local function refreshPage()
    --[[
      name: refreshPage
      line: 311
      upvalues:
        tbl_upv_5 (ref,  index: 1)
        u9 (ref,  index: 2)
        C_upv_1 (copy, index: 3)
        tbl_upv_3 (ref,  index: 4)
        Index_upv_1 (copy, index: 5)
        passedHere (ref,  index: 6)
    ]]
    if not tbl_upv_5 then
        return
    end
    local v25 = 0
    local v26 = nil
    local v35 = nil
    for v36, value_4 in tbl_upv_5.Rows do
        local Entry_1 = value_4.Entry
        local v27 = u9.Bests[Entry_1.Id]
        local v28 = Entry_1.Level <= u9.Unlocked
        v25 = (v27 and (v25 + 1)) or v25
        local Best_1 = value_4.Best
        if v27 then
            if v27 ~= nil then
                local v29 = math.floor(v27 / 60)
                local v30 = v27 - v29 * 60
                if v29 > 0 then
                    v26 = string.format("%d:%05.2f", v29, v30)
                else
                    v26 = string.format("%.2f", v30)
                end
            else
                v26 = "--"
            end
        else
            v26 = (v28 and "NEXT") or "\240\159\148\146"
        end
        Best_1.Text = v26
        local Name_1 = value_4.Name
        if v28 then
            v26 = C_upv_1.Text
        else
            v26 = C_upv_1.Faint
        end
        Name_1.TextColor3 = v26
        local Num_1 = value_4.Num
        if Entry_1.Level ~= u9.Unlocked then
            v26 = C_upv_1.Sub
        else
            v26 = C_upv_1.Good
        end
        Num_1.TextColor3 = v26
        local Row_1 = value_4.Row
        if (tbl_upv_3) and tbl_upv_3.Entry == Entry_1 then
            v26 = 0.8
        else
            v26 = 1
        end
        Row_1.BackgroundTransparency = v26
    end
    local Title_1 = tbl_upv_5.Title
    local Skip_1 = ((not tbl_upv_3) and "TRACKS") or (string.format("LEVEL %d \194\183 %s", tbl_upv_3.Entry.Level, string.upper(tbl_upv_3.Entry.Name)))
    Title_1.Text = Skip_1
    local Sub_1 = tbl_upv_5.Sub
    Sub_1.Text = string.format("LEVEL %d OF %d UNLOCKED  \194\183  %d FINISHED", u9.Unlocked, #Index_upv_1, v25)
    local Restart_1 = tbl_upv_5.Restart
    Skip_1 = tbl_upv_3 ~= nil
    Restart_1.Visible = Skip_1
    local Next_1 = tbl_upv_5.Next
    local v31 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
    local v32 = not (v31) or not (v31.Level <= u9.Unlocked) or v31
    if v32 ~= nil then
        Skip_1 = true
    else
        Skip_1 = false
    end
    Next_1.Visible = Skip_1
    local v33 = tbl_upv_3 and (tbl_upv_3.Entry)
    Skip_1 = tbl_upv_5.Skip
    local v34 = false
    if v33 ~= nil then
        v34 = (Index_upv_1[v33.Level + 1] ~= nil) and (not passedHere(v33))
    end
    Skip_1.Visible = v34
end
local function loadLevel(a1)
    --[[
      name: buildPage
      line: 337
      upvalues:
        Theme_upv_1 (copy, index: 1)
        F_upv_1 (copy, index: 2)
        C_upv_1 (copy, index: 3)
        Menu_upv_1 (copy, index: 4)
        hidePanel (ref,  index: 5)
        startRun (ref,  index: 6)
        tbl_upv_3 (ref,  index: 7)
        Index_upv_1 (copy, index: 8)
        u9 (ref,  index: 9)
        loadLevel (ref,  index: 10)
        backToHub (ref,  index: 11)
        Config_upv_1 (copy, index: 12)
        skipLevel (ref,  index: 13)
        refreshPage (copy, index: 14)
        u1 (ref,  index: 15)
        tbl_upv_5 (ref,  index: 16)
    ]]
    local v35 = Theme_upv_1.new("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 16), Size = UDim2.new(1, -48, 0, 56)}, a1)
    local v36 = Theme_upv_1.Text({Text = "TRACKS", TextSize = 24, Size = UDim2.new(0.5, 0, 0, 30), FontFace = F_upv_1.Display, TextColor3 = C_upv_1.Good, TextTruncate = Enum.TextTruncate.AtEnd}, v35)
    local v37 = Theme_upv_1.Kicker({Text = "", Position = UDim2.fromOffset(0, 34), Size = UDim2.new(0.5, 0, 0, 18)}, v35)
    local u25 = Theme_upv_1.new("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.5, 0, 0, 40)}, v35)
    Theme_upv_1.new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, u25)
    local function button_1(a2, a3, a4, a5)
        --[[
          name: button
          line: 343
          upvalues:
            Theme_upv_1 (copy, index: 1)
            u25 (copy, index: 2)
        ]]
        local v38 = Theme_upv_1.Button({TextSize = 13, LayoutOrder = a2, Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X, Text = a3}, u25, a4)
        Theme_upv_1.new("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, v38)
        v38.Activated:Connect(a5)
        return v38
    end
    local v39 = button_1(
        1,
        "RESTART  \194\183  BACKSPACE",
        "ghost",
        function()
            --[[
              line: 349
              upvalues:
                Menu_upv_1 (copy, index: 1)
                hidePanel (ref,  index: 2)
                startRun (ref,  index: 3)
            ]]
            Menu_upv_1.Close()
            hidePanel(true)
            startRun()
        end
    )
    local v40 = button_1(
        2,
        "NEXT LEVEL  \194\183  ENTER",
        "primary",
        function()
            --[[
              line: 354
              upvalues:
                tbl_upv_3 (ref,  index: 1)
                Index_upv_1 (copy, index: 2)
                u9 (ref,  index: 3)
                Menu_upv_1 (copy, index: 4)
                hidePanel (ref,  index: 5)
                loadLevel (ref,  index: 6)
            ]]
            local v41 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
            local v42 = not (v41) or not (v41.Level <= u9.Unlocked) or v41
            if not v42 then
                return
            end
            Menu_upv_1.Close()
            hidePanel(true)
            loadLevel(v42)
        end
    )
    button_1(
        3,
        "BACK TO HUB",
        "ghost",
        function()
            --[[
              line: 362
              upvalues:
                Menu_upv_1 (copy, index: 1)
                backToHub (ref,  index: 2)
            ]]
            Menu_upv_1.Close()
            backToHub()
        end
    )
    local v43 = button_1(
        0,
        string.format("SKIP LEVEL  \194\183  R$ %d", ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipRobux)) or 20),
        "gold",
        function()
            --[[
              line: 366
              upvalues:
                skipLevel (ref, index: 1)
            ]]
            skipLevel()
        end
    )
    v35 = Theme_upv_1.new("ScrollingFrame", {BackgroundTransparency = 1, ScrollBarThickness = 6, BorderSizePixel = 0, Position = UDim2.fromOffset(24, 84), Size = UDim2.new(1, -48, 1, -96), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, a1)
    Theme_upv_1.new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, v35)
    local tbl_6 = {}
    local Region_1 = nil
    local v45 = nil
    for key_3, value_upv_5 in Index_upv_1 do
        if value_upv_5.Region ~= Region_1 then
            Region_1 = value_upv_5.Region
            Theme_upv_1.Kicker({LayoutOrder = (key_3 * 2) - 1, Size = UDim2.new(1, -10, 0, 24), Text = string.format("   REGION %d \194\183 %s", value_upv_5.Region, value_upv_5.RegionName), TextColor3 = C_upv_1.Gold}, v35)
        end
        local u26 = Theme_upv_1.new("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Name = value_upv_5.Id, LayoutOrder = key_3 * 2, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = C_upv_1.Energy, SelectionImageObject = Theme_upv_1.Selection}, v35)
        Theme_upv_1.Corners(u26, 4)
        local v46 = Theme_upv_1.Text({TextSize = 15, Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(44, 30), Text = tostring(value_upv_5.Level), FontFace = F_upv_1.Number, TextColor3 = C_upv_1.Sub}, u26)
        local v47 = Theme_upv_1.Text({TextSize = 15, Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -380, 1, 0), Text = value_upv_5.Name, FontFace = F_upv_1.Bold, TextTruncate = Enum.TextTruncate.AtEnd}, u26)
        Theme_upv_1.Text({TextSize = 13, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -170, 0, 0), Size = UDim2.fromOffset(160, 30), Text = value_upv_5.RegionName, TextColor3 = C_upv_1.Sub, TextTruncate = Enum.TextTruncate.AtEnd}, u26)
        local Text_1 = Theme_upv_1.Text
        local tbl_7 = {FontFace = 0, TextXAlignment = 0, TextColor3 = 0, Text = 0, TextSize = 15}
        tbl_7.AnchorPoint = Vector2.new(1, 0)
        tbl_7.Position = UDim2.new(1, -86, 0, 0)
        tbl_7.Size = UDim2.fromOffset(76, 30)
        local Gold_1 = value_upv_5.Gold
        if Gold_1 == nil then
            v45 = "--"
            tbl_7.Text = v45
            tbl_7.TextColor3 = C_upv_1.Gold
            tbl_7.FontFace = F_upv_1.Number
            tbl_7.TextXAlignment = Enum.TextXAlignment.Right
            Text_1(tbl_7, u26)
            tbl_6[key_3] = {Entry = value_upv_5, Row = u26, Best = Theme_upv_1.Text({Text = "", TextSize = 15, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(72, 30), TextColor3 = C_upv_1.Good, FontFace = F_upv_1.Number, TextXAlignment = Enum.TextXAlignment.Right}, u26), Name = v47, Num = v46}
            u26.MouseEnter:Connect(
                function()
                    --[[
                      line: 394
                      upvalues:
                        u26 (copy, index: 1)
                    ]]
                    u26.BackgroundTransparency = 0.75
                end
            )
            u26.MouseLeave:Connect(refreshPage)
            u26.Activated:Connect(
                function()
                    --[[
                      line: 398
                      upvalues:
                        value_upv_5 (copy, index: 1)
                        u9 (ref,  index: 2)
                        Menu_upv_1 (copy, index: 3)
                        hidePanel (ref,  index: 4)
                        loadLevel (ref,  index: 5)
                        u1 (ref,  index: 6)
                    ]]
                    if value_upv_5.Level <= u9.Unlocked then
                        Menu_upv_1.Close()
                        hidePanel(true)
                        loadLevel(value_upv_5)
                    else
                        local v48 = string.format("LOCKED \194\183 FINISH LEVEL %d FIRST", u9.Unlocked)
                        local v49 = u1 and (u1.Ui)
                        if v49 then
                            v49:Banner(v48)
                        end
                    end
                end
            )
            continue
        end
        local v50 = math.floor(Gold_1 / 60)
        local v51 = Gold_1 - v50 * 60
        if v50 > 0 then
            v45 = string.format("%d:%05.2f", v50, v51)
        else
            v45 = string.format("%.2f", v51)
        end
        tbl_7.Text = v45
        tbl_7.TextColor3 = C_upv_1.Gold
        tbl_7.FontFace = F_upv_1.Number
        tbl_7.TextXAlignment = Enum.TextXAlignment.Right
        Text_1(tbl_7, u26)
        tbl_6[key_3] = {Entry = value_upv_5, Row = u26, Best = Theme_upv_1.Text({Text = "", TextSize = 15, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(72, 30), TextColor3 = C_upv_1.Good, FontFace = F_upv_1.Number, TextXAlignment = Enum.TextXAlignment.Right}, u26), Name = v47, Num = v46}
        u26.MouseEnter:Connect(
            function()
                --[[
                  line: 394
                  upvalues:
                    u26 (copy, index: 1)
                ]]
                u26.BackgroundTransparency = 0.75
            end
        )
        u26.MouseLeave:Connect(refreshPage)
        u26.Activated:Connect(
            function()
                --[[
                  line: 398
                  upvalues:
                    value_upv_5 (copy, index: 1)
                    u9 (ref,  index: 2)
                    Menu_upv_1 (copy, index: 3)
                    hidePanel (ref,  index: 4)
                    loadLevel (ref,  index: 5)
                    u1 (ref,  index: 6)
                ]]
                if value_upv_5.Level <= u9.Unlocked then
                    Menu_upv_1.Close()
                    hidePanel(true)
                    loadLevel(value_upv_5)
                else
                    local v48 = string.format("LOCKED \194\183 FINISH LEVEL %d FIRST", u9.Unlocked)
                    local v49 = u1 and (u1.Ui)
                    if v49 then
                        v49:Banner(v48)
                    end
                end
            end
        )
    end
    tbl_upv_5 = {Rows = tbl_6, Sub = v37, Title = v36, Restart = v39, Next = v40, Skip = v43}
end
passedHere = function(a1)
    --[[
      name: passedHere
      line: 412
      upvalues:
        u9 (ref, index: 1)
    ]]
    local Bests_1 = u9.Bests
    local v52 = true
    if Bests_1[a1.Id] == nil then
        if Bests_1.__done == nil then
            v52 = (Bests_1.__skip ~= nil) and (Bests_1.__skip[a1.Id] == true)
        else
            v52 = true
            if Bests_1.__done[a1.Id] ~= true then
                v52 = (Bests_1.__skip ~= nil) and (Bests_1.__skip[a1.Id] == true)
            end
        end
    end
    return v52
end
local u27 = nil
local tbl_upv_8 = {}
local function canSkip()
    --[[
      name: canSkip
      line: 422
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Index_upv_1 (copy, index: 2)
        passedHere (ref,  index: 3)
    ]]
    local v53 = tbl_upv_3 and (tbl_upv_3.Entry)
    local v54 = false
    if v53 ~= nil then
        v54 = not v53.Obby and ((Index_upv_1[v53.Level + 1] ~= nil) and (not passedHere(v53)))
    end
    return v54
end
local u28 = nil
local u29 = nil
local function syncSkip()
    --[[
      name: syncSkip
      line: 429
      upvalues:
        u27 (ref,  index: 1)
        tbl_upv_3 (ref,  index: 2)
        Index_upv_1 (copy, index: 3)
        passedHere (ref,  index: 4)
        u4 (ref,  index: 5)
        u28 (ref,  index: 6)
        tbl_upv_8 (copy, index: 7)
        u29 (ref,  index: 8)
        Config_upv_1 (copy, index: 9)
        Layout_upv_1 (copy, index: 10)
    ]]
    if not u27 then
        return
    end
    local v55 = tbl_upv_3 and (tbl_upv_3.Entry)
    local v56 = false
    if v55 ~= nil then
        v56 = not v55.Obby and ((Index_upv_1[v55.Level + 1] ~= nil) and (not passedHere(v55)))
    end
    if v56 then
        local v57 = true
        if u4 == "racing" then
            v56 = v57
        else
            v56 = u4 == "countdown"
        end
    end
    if v56 ~= u28 then
        u28 = v56
        u27.Skip.Visible = v56
    end
    local v58 = v56 and ((tbl_upv_8[tbl_upv_3.Entry.Id] or 0) >= 3)
    if v58 ~= u29 then
        u29 = v58
        local SkipButton_1 = u27.SkipButton
        local v59
        if v58 then
            v59 = "STUCK?  " .. string.format("SKIP LEVEL  \194\183  R$ %d", ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipRobux)) or 20)
        else
            v59 = string.format("SKIP LEVEL  \194\183  R$ %d", ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipRobux)) or 20)
        end
        SkipButton_1.Text = v59
    end
    v56 = (v58 and (math.max(0, math.sin(os.clock() * 4)) * 0.06 + 1)) or 1
    local SkipScale_1 = u27.SkipScale
    SkipScale_1.Scale = Layout_upv_1.Scale() * v56
end
local u30 = 0
skipLevel = function()
    --[[
      name: skipLevel
      line: 451
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Index_upv_1 (copy, index: 2)
        passedHere (ref,  index: 3)
        u30 (ref,  index: 4)
        Config_upv_1 (copy, index: 5)
        u3 (ref,  index: 6)
        MarketplaceService_upv_1 (copy, index: 7)
        LocalPlayer_upv_1 (copy, index: 8)
        afterSkip (ref,  index: 9)
        u1 (ref,  index: 10)
    ]]
    local v60 = tbl_upv_3 and (tbl_upv_3.Entry)
    if v60 then
        local v61 = tbl_upv_3 and (tbl_upv_3.Entry)
        local v62 = false
        if v61 ~= nil then
            v62 = not v61.Obby and ((Index_upv_1[v61.Level + 1] ~= nil) and (not passedHere(v61)))
        end
        if not v62 or (os.clock() < u30) then
            return
        end
        v62 = ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipProductId)) or 0
        pcall(u3.InvokeServer, u3, "SkipTarget", tbl_upv_3.Id)
        if v62 == 0 then
            local success_2, v63 = pcall(u3.InvokeServer, u3, "Skip", tbl_upv_3.Id)
            if not success_2 or not v63 then
                v62 = u1 and (u1.Ui)
                if v62 then
                    v62:Banner("SKIP LEVEL ISN'T SET UP YET")
                end
                return
            end
            afterSkip()
        else
            u30 = os.clock() + 30
            MarketplaceService_upv_1:PromptProductPurchase(LocalPlayer_upv_1, v62)
        end
    end
end
afterSkip = function()
    --[[
      name: afterSkip
      line: 471
      upvalues:
        u3 (ref,  index: 1)
        u9 (ref,  index: 2)
        refreshPage (copy, index: 3)
        u6 (ref,  index: 4)
        tbl_upv_3 (ref,  index: 5)
        Index_upv_1 (copy, index: 6)
        passedHere (ref,  index: 7)
        u1 (ref,  index: 8)
    ]]
    local success_3, v64 = pcall(u3.InvokeServer, u3, "Progress")
    if success_3 and type(v64) == "table" then
        u9 = v64
    end
    refreshPage()
    if u6 and u6.Shade.Visible then
        local Skip_2 = u6.Buttons.Skip
        local v65 = tbl_upv_3 and (tbl_upv_3.Entry)
        v64 = false
        if v65 ~= nil then
            v64 = not v65.Obby and ((Index_upv_1[v65.Level + 1] ~= nil) and (not passedHere(v65)))
        end
        Skip_2.Visible = v64
    end
    local v66 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
    if not v66 then
        return
    end
    if v66.Level <= u9.Unlocked then
        local v67 = string.format("LEVEL %d UNLOCKED", v66.Level)
        local v68 = u1 and (u1.Ui)
        if not v68 then
            return
        end
        v68:Banner(v67)
    end
end
local function openLevels()
    --[[
      name: openLevels
      line: 484
      upvalues:
        tbl_upv_1 (copy, index: 1)
        u6 (ref,  index: 2)
        hidePanel (ref,  index: 3)
        Menu_upv_1 (copy, index: 4)
        u3 (ref,  index: 5)
        u9 (ref,  index: 6)
        refreshPage (copy, index: 7)
    ]]
    if not tbl_upv_1.Active() then
        return
    end
    if u6 and u6.Shade.Visible then
        hidePanel(true)
    end
    Menu_upv_1.Toggle("TRACKS")
    if Menu_upv_1.IsOpen("TRACKS") then
        task.spawn(
            function()
                --[[
                  line: 493
                  upvalues:
                    u3 (ref,  index: 1)
                    u9 (ref,  index: 2)
                    refreshPage (copy, index: 3)
                ]]
                local success_4, v69 = pcall(u3.InvokeServer, u3, "Progress")
                if success_4 and type(v69) == "table" then
                    u9 = v69
                end
                refreshPage()
            end
        )
    end
end
local function buildBoard()
    --[[
      name: buildBoard
      line: 504
      upvalues:
        Theme_upv_1 (copy, index: 1)
        LocalPlayer_upv_1 (copy, index: 2)
        Layout_upv_1 (copy, index: 3)
        C_upv_1 (copy, index: 4)
        F_upv_1 (copy, index: 5)
        Config_upv_1 (copy, index: 6)
        skipLevel (ref,  index: 7)
    ]]
    local v70 = Theme_upv_1.new("ScreenGui", {Enabled = false, Name = "TmnfBoard", DisplayOrder = 5, ResetOnSpawn = false, IgnoreGuiInset = true}, LocalPlayer_upv_1:WaitForChild("PlayerGui"))
    v70:SetAttribute("Toon", true)
    local v71 = Theme_upv_1.Panel({BackgroundTransparency = 0.18, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -Theme_upv_1.Edge, 0.5, 0), Size = UDim2.fromOffset(260, 300)}, v70)
    local u31 = Theme_upv_1.new("UIScale", {Scale = Layout_upv_1.Scale()}, v71)
    local v72 = Theme_upv_1.Kicker({Text = "TOP 10", Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 16), TextColor3 = C_upv_1.Gold}, v71)
    local v73 = Theme_upv_1.Text({Text = "", TextSize = 14, Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -32, 0, 20), FontFace = F_upv_1.Bold, TextTruncate = Enum.TextTruncate.AtEnd}, v71)
    local tbl_9 = {}
    for n_4 = 1, 10 do
        local v74 = (n_4 - 1) * 23 + 58
        tbl_9[n_4] = {
            Rank = Theme_upv_1.Text({TextSize = 14, Position = UDim2.fromOffset(16, v74), Size = UDim2.fromOffset(24, 22), Text = tostring(n_4) .. ".", FontFace = F_upv_1.Number, TextColor3 = C_upv_1.Sub}, v71),
            Name = Theme_upv_1.Text({Text = "", TextSize = 14, Position = UDim2.fromOffset(42, v74), Size = UDim2.new(1, -132, 0, 22), FontFace = F_upv_1.Bold, TextTruncate = Enum.TextTruncate.AtEnd}, v71),
            Time = Theme_upv_1.Text({Text = "", TextSize = 14, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, v74), Size = UDim2.fromOffset(84, 22), FontFace = F_upv_1.Number, TextXAlignment = Enum.TextXAlignment.Right}, v71)
        }
    end
    local v75 = Theme_upv_1.Text({TextWrapped = true, Text = "No times yet: set the first one", TextSize = 13, Position = UDim2.fromOffset(16, 60), Size = UDim2.new(1, -32, 0, 40), TextColor3 = C_upv_1.Sub}, v71)
    local v76 = Theme_upv_1.Panel({BackgroundTransparency = 0.18, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -Theme_upv_1.Edge, 1, -Theme_upv_1.Edge), Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X}, v70)
    Theme_upv_1.new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, v76)
    Theme_upv_1.new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, v76)
    local u32 = Theme_upv_1.new("UIScale", {Scale = Layout_upv_1.Scale()}, v76)
    local tbl_10 = {}
    for key_4, value_6 in {{"C", "LAST CHECKPOINT"}, {"BACKSPACE", "RESTART LEVEL"}, {"L", "LEVELS"}} do
        local v77 = Theme_upv_1.KeyCap(value_6[1], v76, {LayoutOrder = key_4 * 2})
        local v78 = Theme_upv_1.Text({FreeText = true, TextSize = 13, LayoutOrder = (key_4 * 2) + 1, Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X, Text = value_6[2], FontFace = F_upv_1.Heavy}, v76)
        Theme_upv_1.new("UIPadding", {PaddingRight = UDim.new(0, 12)}, v78)
        tbl_10[key_4] = {Cap = v77, Label = v78, Text = value_6[2]}
    end
    local u33 = Theme_upv_1.new("Frame", {BackgroundTransparency = 1, Visible = false, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -Theme_upv_1.Edge, 1, -Theme_upv_1.Edge - (50 * Layout_upv_1.Scale())), Size = UDim2.fromOffset(250, 46)}, v70)
    local v79 = Theme_upv_1.new("UIScale", {Scale = Layout_upv_1.Scale()}, u33)
    local Button_1 = Theme_upv_1.Button
    local tbl_11 = {Text = 0, TextSize = 16}
    tbl_11.AnchorPoint = Vector2.new(0.5, 0.5)
    tbl_11.Position = UDim2.fromScale(0.5, 0.5)
    tbl_11.Size = UDim2.fromScale(1, 1)
    tbl_11.Text = string.format("SKIP LEVEL  \194\183  R$ %d", ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipRobux)) or 20)
    local v80 = Button_1(tbl_11, u33, "gold")
    v80.Activated:Connect(
        function()
            --[[
              line: 537
              upvalues:
                skipLevel (ref, index: 1)
            ]]
            skipLevel()
        end
    )
    Layout_upv_1.Changed:Connect(
        function()
            --[[
              line: 540
              upvalues:
                u31 (copy, index: 1)
                Layout_upv_1 (copy, index: 2)
                u32 (copy, index: 3)
                u33 (copy, index: 4)
                Theme_upv_1 (copy, index: 5)
            ]]
            u31.Scale = Layout_upv_1.Scale()
            u32.Scale = Layout_upv_1.Scale()
            u33.Position = UDim2.new(1, -Theme_upv_1.Edge, 1, -Theme_upv_1.Edge - (50 * Layout_upv_1.Scale()))
        end
    )
    local tbl_12 = {}
    tbl_12.Gui = v70
    tbl_12.Head = v72
    tbl_12.Title = v73
    tbl_12.Rows = tbl_9
    tbl_12.Empty = v75
    tbl_12.Skip = u33
    tbl_12.SkipButton = v80
    tbl_12.SkipScale = v79
    tbl_12.Keys = tbl_10
    return tbl_12
end
local u34 = nil
local function buildPlate()
    --[[
      name: buildPlate
      line: 551
      upvalues:
        u34 (ref,  index: 1)
        tbl_upv_3 (ref,  index: 2)
        Course_upv_1 (copy, index: 3)
        Theme_upv_1 (copy, index: 4)
        F_upv_1 (copy, index: 5)
        C_upv_1 (copy, index: 6)
        Workspace_upv_1 (copy, index: 7)
    ]]
    if u34 then
        u34.Part:Destroy()
        u34 = nil
    end
    if not tbl_upv_3 then
        return
    end
    local v81 = tbl_upv_3.SpawnCF * CFrame.new((Course_upv_1.WIDTH / 2) + 20, 14, -36) * CFrame.Angles(0, 2.6179938779914944, 0)
    local v82 = Instance.new("Part")
    v82.Name = "TmnfTopPlate"
    v82.Anchored = true
    v82.CanCollide = false
    v82.CanQuery = false
    v82.CanTouch = false
    v82.Size = Vector3.new(26, 30, 1)
    v82.CFrame = v81
    v82.Color = Color3.fromRGB(16, 18, 24)
    v82.Material = Enum.Material.SmoothPlastic
    local v83 = Instance.new("Part")
    v83.Anchored = true
    v83.CanCollide = false
    v83.CanQuery = false
    v83.CanTouch = false
    v83.Size = Vector3.new(1.5, 14, 1.5)
    v83.CFrame = v81 * CFrame.new(0, -22, 0)
    v83.Color = Color3.fromRGB(60, 64, 72)
    v83.Material = Enum.Material.Metal
    v83.Parent = v82
    local v84 = Instance.new("SurfaceGui")
    v84.Face = Enum.NormalId.Front
    v84.CanvasSize = Vector2.new(520, 600)
    v84.LightInfluence = 0
    v84.Parent = v82
    local v85 = Theme_upv_1.Text({Text = "TOP 10", TextSize = 34, Position = UDim2.fromOffset(24, 18), Size = UDim2.new(1, -48, 0, 36), FontFace = F_upv_1.Display, TextColor3 = C_upv_1.Gold}, v84)
    local v86 = Theme_upv_1.Text({Text = "", TextSize = 22, Position = UDim2.fromOffset(24, 58), Size = UDim2.new(1, -48, 0, 28), FontFace = F_upv_1.Bold, TextTruncate = Enum.TextTruncate.AtEnd}, v84)
    local tbl_13 = {}
    for n_5 = 1, 10 do
        local v87 = (n_5 - 1) * 48 + 100
        tbl_13[n_5] = {
            Rank = Theme_upv_1.Text({TextSize = 26, Position = UDim2.fromOffset(24, v87), Size = UDim2.fromOffset(44, 40), Text = n_5 .. ".", FontFace = F_upv_1.Number, TextColor3 = C_upv_1.Sub}, v84),
            Name = Theme_upv_1.Text({Text = "", TextSize = 26, Position = UDim2.fromOffset(72, v87), Size = UDim2.new(1, -250, 0, 40), FontFace = F_upv_1.Bold, TextTruncate = Enum.TextTruncate.AtEnd}, v84),
            Time = Theme_upv_1.Text({Text = "", TextSize = 26, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, v87), Size = UDim2.fromOffset(160, 40), FontFace = F_upv_1.Number, TextXAlignment = Enum.TextXAlignment.Right}, v84)
        }
    end
    v82.Parent = Workspace_upv_1
    u34 = {Part = v82, Head = v85, Title = v86, Rows = tbl_13}
end
local tbl_upv_14 = {}
local u35 = false
local function drawBoard()
    --[[
      name: drawBoard
      line: 603
      upvalues:
        u27 (ref,  index: 1)
        buildBoard (copy, index: 2)
        u35 (ref,  index: 3)
        tbl_upv_14 (ref,  index: 4)
        tbl_upv_3 (ref,  index: 5)
        LocalPlayer_upv_1 (copy, index: 6)
        C_upv_1 (copy, index: 7)
        u34 (ref,  index: 8)
    ]]
    local v88 = u27 or (buildBoard())
    u27 = v88
    local v89 = u35 and (tbl_upv_14.Today ~= nil)
    local v90
    if v89 then
        v90 = tbl_upv_14.Today
    else
        v90 = tbl_upv_14.All
    end
    if not (v90) then
        v90 = {}
    end
    local u36 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    local Head_1 = u27.Head
    Head_1.Text = (v89 and "TODAY'S TOP 10") or "TOP 10"
    local Title_2 = u27.Title
    Title_2.Text = not tbl_upv_3 and "" or u36 and "HIGHEST CLIMBERS" or string.format("LEVEL %d \194\183 %s", tbl_upv_3.Entry.Level, string.upper(tbl_upv_3.Entry.Name))
    local function score_1(a1)
        --[[
          name: score
          line: 611
          upvalues:
            u36 (copy, index: 1)
        ]]
        if u36 then
            return (string.format("CP %d", a1.Stage or 0))
        end
        local Time_1 = a1.Time
        if Time_1 == nil then
            return "--"
        end
        local v92 = math.floor(Time_1 / 60)
        local v93 = Time_1 - v92 * 60
        if v92 > 0 then
            return (string.format("%d:%05.2f", v92, v93))
        end
        return (string.format("%.2f", v93))
    end
    local v94 = (u36 and "Nobody's climbed yet: be the first") or ((v89 and "No times today yet: set the first one") or "No times yet: set the first one")
    local v95 = nil
    local v96 = nil
    local _ = nil
    local v105 = nil
    for key_5, value_7 in u27.Rows do
        local v97 = v90[key_5]
        local v98 = (v97 ~= nil) and (v97.Name == LocalPlayer_upv_1.Name)
        value_7.Rank.Visible = v97 ~= nil
        value_7.Name.Text = ((not v97) and "") or (v97.Name)
        local Time_2 = value_7.Time
        if v97 then
            if u36 then
                v95 = string.format("CP %d", v97.Stage or 0)
            else
                v96 = v97.Time
                if v96 ~= nil then
                    local v99 = math.floor(v96 / 60)
                    local v100 = v96 - v99 * 60
                    if v99 > 0 then
                        v95 = string.format("%d:%05.2f", v99, v100)
                    else
                        v95 = string.format("%.2f", v100)
                    end
                else
                    v95 = "--"
                end
            end
        else
            v95 = ""
        end
        Time_2.Text = v95
        local Name_2 = value_7.Name
        if v98 then
            v95 = C_upv_1.Good
        else
            v95 = C_upv_1.Text
        end
        Name_2.TextColor3 = v95
        local Time_3 = value_7.Time
        if v98 then
            v95 = C_upv_1.Good
            Time_3.TextColor3 = v95
            continue
        end
        if key_5 ~= 1 then
            v95 = C_upv_1.Text
        else
            v95 = C_upv_1.Gold
        end
        Time_3.TextColor3 = v95
    end
    u27.Empty.Text = v94
    local Empty_1 = u27.Empty
    Empty_1.Visible = #v90 == 0
    if u34 then
        u34.Head.Text = u27.Head.Text
        u34.Title.Text = u27.Title.Text
        local v106
        v96 = nil
        for key_6, value_8 in u34.Rows do
            local v101 = v90[key_6]
            local v102 = (v101 ~= nil) and (v101.Name == LocalPlayer_upv_1.Name)
            value_8.Rank.Visible = v101 ~= nil
            local Name_3 = value_8.Name
            if v101 then
                v96 = v101.Name
            elseif key_6 == 1 then
                v96 = v94
            else
                v96 = ""
            end
            Name_3.Text = v96
            local Name_4 = value_8.Name
            if v102 then
                v96 = C_upv_1.Good
            elseif v101 then
                v96 = C_upv_1.Text
            else
                v96 = C_upv_1.Sub
            end
            Name_4.TextColor3 = v96
            local Time_4 = value_8.Time
            if v101 then
                if u36 then
                    v96 = string.format("CP %d", v101.Stage or 0)
                else
                    local Time_5 = v101.Time
                    if Time_5 ~= nil then
                        local v103 = math.floor(Time_5 / 60)
                        local v104 = Time_5 - v103 * 60
                        if v103 > 0 then
                            v96 = string.format("%d:%05.2f", v103, v104)
                        else
                            v96 = string.format("%.2f", v104)
                        end
                    else
                        v96 = "--"
                    end
                end
            else
                v96 = ""
            end
            Time_4.Text = v96
            local Time_6 = value_8.Time
            if v102 then
                v96 = C_upv_1.Good
                Time_6.TextColor3 = v96
                continue
            end
            if key_6 ~= 1 then
                v96 = C_upv_1.Text
            else
                v96 = C_upv_1.Gold
            end
            Time_6.TextColor3 = v96
        end
    end
end
local function setBoard(a1, a2)
    --[[
      name: setBoard
      line: 642
      upvalues:
        tbl_upv_14 (ref,  index: 1)
        drawBoard (copy, index: 2)
    ]]
    tbl_upv_14 = {All = a1, Today = a2}
    drawBoard()
end
task.spawn(
    function()
        --[[
          line: 647
          upvalues:
            u27 (ref,  index: 1)
            tbl_upv_14 (ref,  index: 2)
            u35 (ref,  index: 3)
            drawBoard (copy, index: 4)
        ]]
        repeat
            task.wait(8)
        until u27
        if tbl_upv_14.Today == nil then
            return
        end
        u35 = not u35
        drawBoard()
    end
)
local function showBoard(a1)
    --[[
      name: showBoard
      line: 657
      upvalues:
        u27 (ref,  index: 1)
        buildBoard (copy, index: 2)
        tbl_upv_3 (ref,  index: 3)
        Layout_upv_1 (copy, index: 4)
    ]]
    local v105 = u27 or (buildBoard())
    u27 = v105
    local v106 = nil
    for key_7, value_9 in u27.Keys do
        local v107 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        local v108 = not v107 or (key_7 == 1)
        if value_9.Cap then
            value_9.Cap.Visible = v108
        end
        value_9.Label.Visible = v108
        local Label_1 = value_9.Label
        local v109 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        if (v109) and key_7 == 1 then
            v106 = "STAGE START"
        else
            v106 = value_9.Text
        end
        Label_1.Text = v106
    end
    local Gui_1 = u27.Gui
    Gui_1.Enabled = a1 and not Layout_upv_1.IsTouch()
end
local function fetchBoard(a1)
    --[[
      name: fetchBoard
      line: 673
    ]]
    task.spawn(function() end)
end
local leave = nil
local showPanel = nil
local u37 = nil
local u38 = nil
local tbl_upv_16 = {"ClockTime", "Brightness", "Ambient", "OutdoorAmbient", "FogColor", "FogStart", "FogEnd"}
local tbl_upv_17 = {"Density", "Offset", "Color", "Decay", "Glare", "Haze"}
local u39 = function(a1)
    --[[
      line: 699
      upvalues:
        Lighting_upv_1 (copy, index: 1)
        u37 (ref,  index: 2)
        tbl_upv_16 (copy, index: 3)
        tbl_upv_17 (copy, index: 4)
        u38 (ref,  index: 5)
        tbl_upv_3 (ref,  index: 6)
        Workspace_upv_1 (copy, index: 7)
    ]]
    local v111 = Lighting_upv_1:FindFirstChildOfClass("Atmosphere")
    if a1 then
        if not (u37) then
            u37 = {Atmosphere = {}}
            for _, value_10 in tbl_upv_16 do
                u37[value_10] = Lighting_upv_1[value_10]
            end
            if v111 then
                for _, value_11 in tbl_upv_17 do
                    u37.Atmosphere[value_11] = v111[value_11]
                end
            end
        end
        for _, value_12 in tbl_upv_16 do
            if a1[value_12] ~= nil then
                Lighting_upv_1[value_12] = a1[value_12]
            end
        end
        if v111 and a1.Atmosphere then
            for _, value_13 in tbl_upv_17 do
                if a1.Atmosphere[value_13] ~= nil then
                    v111[value_13] = a1.Atmosphere[value_13]
                end
            end
        end
        if u38 then
            u38:Destroy()
            u38 = nil
        end
        if not a1.Planet or not tbl_upv_3 then
            return
        end
        u38 = Instance.new("Part")
        u38.Shape = Enum.PartType.Ball
        u38.Size = Vector3.new(2048, 2048, 2048)
        local v112 = u38
        local v113 = u38
        local v114 = u38
        u38.Anchored = true
        v112.CanCollide = false
        v113.CanQuery = false
        v114.CanTouch = false
        local v115 = u38
        v115.Color = Color3.fromRGB(40, 110, 200)
        u38.Material = Enum.Material.SmoothPlastic
        local v116 = u38
        v116.CFrame = CFrame.new(((tbl_upv_3.Min + tbl_upv_3.Max) / 2) - Vector3.new(0, 2600, 0))
        u38.Parent = Workspace_upv_1
    elseif u37 then
        for _, value_14 in tbl_upv_16 do
            Lighting_upv_1[value_14] = u37[value_14]
        end
        if v111 then
            for key_8, value_15 in u37.Atmosphere do
                v111[key_8] = value_15
            end
        end
        u37 = nil
        if u38 then
            u38:Destroy()
            u38 = nil
        end
    end
end
local u40 = nil
local u41 = function(a1)
    --[[
      line: 758
      upvalues:
        u40 (ref,  index: 1)
        Workspace_upv_1 (copy, index: 2)
        Course_upv_1 (copy, index: 3)
    ]]
    if a1 and not (u40) then
        u40 = Workspace_upv_1.Gravity
        Workspace_upv_1.Gravity = u40 * Course_upv_1.LOW_GRAVITY
        return
    end
    if (a1) then
        return
    end
    if u40 then
        Workspace_upv_1.Gravity = u40
        u40 = nil
    end
end
local function tiers()
    --[[
      name: tiers
      line: 768
      upvalues:
        tbl_upv_3 (ref, index: 1)
    ]]
    local Entry_2 = tbl_upv_3.Entry
    local tbl_18 = {}
    tbl_18.gold = Entry_2.Gold
    tbl_18.silver = Entry_2.Silver
    tbl_18.bronze = Entry_2.Bronze
    return tbl_18
end
local function title()
    --[[
      name: title
      line: 773
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        u5 (ref,  index: 2)
        Obby_upv_1 (copy, index: 3)
    ]]
    local v117 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    if not v117 then
        return string.format("LEVEL %d \194\183 %s", tbl_upv_3.Entry.Level, tbl_upv_3.Entry.Name)
    end
    if not u5 then
        return "OBBY"
    end
    local v118 = u5.Stage + 1
    local v119 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v118]))
    local v120
    if v119 then
        v120 = {}
        v120.Name = v119.Name
        v120.Hint = v119.Hint
    else
        v120 = Obby_upv_1.Stage(v118)
    end
    return (string.format("CHECKPOINT %d  \194\183  %s", v118, v120.Name))
end
local function showRun()
    --[[
      name: showRun
      line: 780
      upvalues:
        u1 (ref,  index: 1)
        tbl_upv_3 (ref,  index: 2)
        u5 (ref,  index: 3)
        Obby_upv_1 (copy, index: 4)
        drivenCar (copy, index: 5)
        Config_upv_1 (copy, index: 6)
        u21 (ref,  index: 7)
        u9 (ref,  index: 8)
    ]]
    local v121 = u1 and (u1.Ui)
    if not v121 then
        return
    end
    local tbl_19 = {}
    local v122 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    if v122 then
        local v123 = u5.Stage + 1
        local v124 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v123]))
        local v125
        if v124 then
            v125 = {}
            v125.Name = v124.Name
            v125.Hint = v124.Hint
        else
            v125 = Obby_upv_1.Stage(v123)
        end
        table.insert(tbl_19, v125.Hint)
    elseif tbl_upv_3.Checkpoints > 0 then
        table.insert(tbl_19, string.format("checkpoints  %d / %d", u5.CpCount, tbl_upv_3.Checkpoints))
    end
    if tbl_upv_3.Laps > 1 then
        table.insert(tbl_19, string.format("lap  %d / %d", u5.Lap, tbl_upv_3.Laps))
    end
    local v126 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    if v126 then
        local v127 = drivenCar()
        local v128 = (v127 and (v127:GetPivot().Position.Y - tbl_upv_3.Origin.Y)) or 0
        local tbl_20 = {Sub = 0, Lines = 0, Title = 0, Owner = "Tmnf", Big = 0}
        local v129 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        local v130
        if v129 then
            if u5 then
                local v131 = u5.Stage + 1
                local v132 = tbl_upv_3 and tbl_upv_3.Tower and tbl_upv_3.Tower.Sections[u5.Stage + 1]
                local v133
                if v132 then
                    v133 = {}
                    v133.Name = v132.Name
                    v133.Hint = v132.Hint
                else
                    v133 = Obby_upv_1.Stage(v131)
                end
                v130 = string.format("CHECKPOINT %d  \194\183  %s", v131, v133.Name)
            else
                v130 = "OBBY"
            end
        else
            v130 = string.format("LEVEL %d \194\183 %s", tbl_upv_3.Entry.Level, tbl_upv_3.Entry.Name)
        end
        tbl_20.Title = v130
        tbl_20.Big = string.format("%d m", math.max(0, math.floor(v128 / Config_upv_1.STUDS_PER_METER)))
        tbl_20.Sub = string.format("HIGHEST  CHECKPOINT %d", math.max(u5.Stage, u21))
        tbl_20.Lines = tbl_19
        u1:ShowRun(tbl_20)
    else
        local tbl_21 = {Lines = 0, Title = 0, Owner = "Tmnf", Tiers = 0, Best = 0, Time = 0}
        local v134
        if false then
            if u5 then
                local v135 = u5.Stage + 1
                local v136 = tbl_upv_3 and tbl_upv_3.Tower and tbl_upv_3.Tower.Sections[u5.Stage + 1]
                local v137
                if v136 then
                    v137 = {}
                    v137.Name = v136.Name
                    v137.Hint = v136.Hint
                else
                    v137 = Obby_upv_1.Stage(v135)
                end
                v134 = string.format("CHECKPOINT %d  \194\183  %s", v135, v137.Name)
            else
                v134 = "OBBY"
            end
        else
            v134 = string.format("LEVEL %d \194\183 %s", tbl_upv_3.Entry.Level, tbl_upv_3.Entry.Name)
        end
        tbl_21.Title = v134
        tbl_21.Time = u5.T
        local Entry_3 = tbl_upv_3.Entry
        tbl_21.Tiers = {gold = Entry_3.Gold, silver = Entry_3.Silver, bronze = Entry_3.Bronze}
        tbl_21.Best = u9.Bests[tbl_upv_3.Entry.Id]
        tbl_21.Lines = tbl_19
        u1:ShowRun(tbl_21)
    end
end
startRun = function()
    --[[
      name: startRun
      line: 804
      upvalues:
        drivenCar (copy, index: 1)
        tbl_upv_3 (ref,  index: 2)
        leave (ref,  index: 3)
        obbyWindow (copy, index: 4)
        u18 (ref,  index: 5)
        u20 (ref,  index: 6)
        Signals_upv_1 (copy, index: 7)
        LocalPlayer_upv_1 (copy, index: 8)
        u1 (ref,  index: 9)
        u5 (ref,  index: 10)
        u3 (ref,  index: 11)
        u2 (ref,  index: 12)
        Obby_upv_1 (copy, index: 13)
        u22 (ref,  index: 14)
        u4 (ref,  index: 15)
        hidePanel (ref,  index: 16)
    ]]
    local v138 = drivenCar()
    if v138 and tbl_upv_3 then
        local v139 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        if v139 then
            obbyWindow((math.max(0, u18)))
        end
        local v140 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        local v141
        if v140 then
            v141 = math.clamp(u18, 0, #tbl_upv_3.StageGates)
        else
            v141 = 0
        end
        local v142 = tbl_upv_3.SpawnCF
        if v141 > 0 then
            local v143 = tbl_upv_3.StageGates[v141]
            local v144 = tbl_upv_3.StageGates[v141].CFrame * CFrame.new(0, -30, 0)
            v142 = v143.Spawn or v144 + v144.UpVector * 5.5
        end
        local v146 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        if not (v146) or v141 ~= 0 or not (u20) then
            Signals_upv_1.Fire("Reset", "teleport")
            v138:PivotTo(v142)
            v138.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            v138.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        u20 = false
        LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", v142)
        LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", ((v141 > 0) and "STAGE START") or "START")
        local v147 = u1 and (u1.Ui)
        if v147 then
            v147:Claim("Tmnf")
        end
        u5 = {CpCount = 0, Lap = 1, T = 0, TurboUntil = 0, Countdown = 3, TurboAccel = 0, Shown = 4, Cps = {}, Stage = v141, From = v141, SpawnCF = v142}
        local v148 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        local v156 = nil
        if v148 then
            for n_6 = 1, v141 do
                u5.Cps[tbl_upv_3.StageGates[n_6]] = true
            end
            u5.CpCount = v141
            task.spawn(pcall, u3.InvokeServer, u3, "ObbyRun", v141)
            if u2 then
                v156 = u2
                local v150 = v141 + 1
                local format_2 = string.format
                v140 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v150]))
                local v151
                if v140 then
                    v151 = {}
                    v151.Name = v140.Name
                    v151.Hint = v140.Hint
                else
                    v151 = Obby_upv_1.Stage(v150)
                end
                local v152 = format_2("CHECKPOINT %d  \194\183  %s", v150, v151.Name)
                local v153 = v141 + 1
                local v154 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v153]))
                if v154 then
                    v150 = {}
                    v150.Name = v154.Name
                    v150.Hint = v154.Hint
                else
                    v150 = Obby_upv_1.Stage(v153)
                end
                v156:Flash(string.format("%s  \194\183  %s", v152, v150.Hint), 5)
            end
        end
        if u22 then
            u22.Gas = 1
        end
        local v155 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
        if v155 then
            v156 = "racing"
        else
            v156 = "countdown"
        end
        u4 = v156
        hidePanel(true)
    else
        leave()
    end
end
local function obbyFinish()
    --[[
      name: obbyFinish
      line: 851
      upvalues:
        u4 (ref,  index: 1)
        u5 (ref,  index: 2)
        tbl_upv_3 (ref,  index: 3)
        drivenCar (copy, index: 4)
        u10 (ref,  index: 5)
        u1 (ref,  index: 6)
        u9 (ref,  index: 7)
        u18 (ref,  index: 8)
        showPanel (ref,  index: 9)
        u3 (ref,  index: 10)
        tbl_upv_14 (ref,  index: 11)
        drawBoard (copy, index: 12)
    ]]
    u4 = "finished"
    local T_upv_1 = u5.T
    local Entry_upv_4 = tbl_upv_3.Entry
    local v157 = u5.From == 0
    local v158 = drivenCar()
    local v159 = v158 and (v158:GetPivot())
    u10 = v159
    local v160 = u1 and (u1.Ui)
    if v160 then
        v160:HideRun("Tmnf")
    end
    local v161 = u9.Bests[Entry_upv_4.Id]
    local tbl_upv_22 = {NewBest = 0}
    tbl_upv_22.Time = T_upv_1
    tbl_upv_22.Full = v157
    tbl_upv_22.Before = v161
    local v162
    if v157 then
        v162 = true
        if v161 ~= nil then
            v162 = T_upv_1 < v161
        end
    else
        v162 = v157
    end
    tbl_upv_22.NewBest = v162
    if tbl_upv_22.NewBest then
        u9.Bests[Entry_upv_4.Id] = T_upv_1
    end
    u18 = 0
    showPanel("finished", tbl_upv_22)
    task.spawn(
        function()
            --[[
              line: 869
              upvalues:
                u3 (ref,  index: 1)
                Entry_upv_4 (copy, index: 2)
                T_upv_1 (copy, index: 3)
                tbl_upv_3 (ref,  index: 4)
                tbl_upv_14 (ref,  index: 5)
                drawBoard (copy, index: 6)
                u1 (ref,  index: 7)
                u4 (ref,  index: 8)
                tbl_upv_22 (copy, index: 9)
                showPanel (ref,  index: 10)
            ]]
            local success_5, v163 = pcall(u3.InvokeServer, u3, "Finish", Entry_upv_4.Id, T_upv_1)
            if not success_5 or type(v163) ~= "table" or not tbl_upv_3 or tbl_upv_3.Entry ~= Entry_upv_4 then
                return
            end
            if v163.Top then
                tbl_upv_14 = {All = v163.Top, Today = v163.TopToday or {}}
                drawBoard()
            end
            if v163.Earned and v163.Earned > 0 then
                local v164 = string.format("+%d TESLA COINS", v163.Earned)
                local v165 = u1 and (u1.Ui)
                if v165 then
                    v165:Banner(v164)
                end
            end
            if u4 ~= "finished" then
                return
            end
            tbl_upv_22.Top = v163.Top
            showPanel("finished", tbl_upv_22)
        end
    )
end
local function finish()
    --[[
      name: finish
      line: 886
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        obbyFinish (copy, index: 2)
        u4 (ref,  index: 3)
        u5 (ref,  index: 4)
        u9 (ref,  index: 5)
        Index_upv_1 (copy, index: 6)
        drivenCar (copy, index: 7)
        u10 (ref,  index: 8)
        LocalPlayer_upv_1 (copy, index: 9)
        u1 (ref,  index: 10)
        u16 (ref,  index: 11)
        showPanel (ref,  index: 12)
        u3 (ref,  index: 13)
        tbl_upv_14 (ref,  index: 14)
        drawBoard (copy, index: 15)
    ]]
    local v166 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    if v166 then
        obbyFinish()
    else
        u4 = "finished"
        local T_upv_2 = u5.T
        local Entry_upv_5 = tbl_upv_3.Entry
        local v167 = tbl_upv_3.Entry
        local tbl_23 = {}
        tbl_23.gold = v167.Gold
        tbl_23.silver = v167.Silver
        tbl_23.bronze = v167.Bronze
        local _ = nil
        for v175, value_16 in {"gold", "silver", "bronze"} do
            if tbl_23[value_16] and T_upv_2 <= tbl_23[value_16] then
                v167 = value_16
            else
                continue
            end
        end
        local v168 = u9.Bests[Entry_upv_5.Id]
        local v169 = true
        if v168 ~= nil then
            v169 = T_upv_2 < v168
        end
        if v169 then
            u9.Bests[Entry_upv_5.Id] = T_upv_2
        end
        if T_upv_2 <= (Entry_upv_5.NeedTime or math.huge) then
            local v170 = true
        else
            local v170 = false
        end
        if v170 and (v168 == nil or not (v168 <= (Entry_upv_5.NeedTime or math.huge))) and u9.Unlocked <= Entry_upv_5.Level then
            local v171 = u9
            v171.Unlocked = math.min(Entry_upv_5.Level + 1, #Index_upv_1)
        end
        local v172 = Index_upv_1[Entry_upv_5.Level + 1]
        local v170 = drivenCar()
        local v173 = v170 and (v170:GetPivot())
        u10 = v173
        LocalPlayer_upv_1:SetAttribute("TmnfResult", string.format("%s:%.3f", Entry_upv_5.Id, T_upv_2))
        v170 = u1 and (u1.Ui)
        if v170 then
            v170:HideRun("Tmnf")
        end
        local tbl_upv_24 = {}
        tbl_upv_24.Time = T_upv_2
        tbl_upv_24.Medal = v167
        tbl_upv_24.NewBest = v169
        tbl_upv_24.Before = v168
        v169 = u16 and (u16())
        if v169 and v169.Key == "g_tmnf1" then
            tbl_upv_24.Mission = v169
        end
        showPanel("finished", tbl_upv_24)
        if v170 and v172 then
            local v174 = string.format("LEVEL %d UNLOCKED", v172.Level)
            v169 = u1 and (u1.Ui)
            if v169 then
                v169:Banner(v174)
            end
        end
        task.spawn(
            function()
                --[[
                  line: 933
                  upvalues:
                    u3 (ref,  index: 1)
                    Entry_upv_5 (copy, index: 2)
                    T_upv_2 (copy, index: 3)
                    u9 (ref,  index: 4)
                    tbl_upv_3 (ref,  index: 5)
                    tbl_upv_14 (ref,  index: 6)
                    drawBoard (copy, index: 7)
                    u1 (ref,  index: 8)
                    u4 (ref,  index: 9)
                    tbl_upv_24 (copy, index: 10)
                    showPanel (ref,  index: 11)
                ]]
                local success_6, v175 = pcall(u3.InvokeServer, u3, "Finish", Entry_upv_5.Id, T_upv_2)
                if not success_6 or type(v175) ~= "table" then
                    return
                end
                if v175.Unlocked then
                    u9.Unlocked = math.max(u9.Unlocked, v175.Unlocked)
                end
                if tbl_upv_3 and tbl_upv_3.Entry == Entry_upv_5 and v175.Top then
                    tbl_upv_14 = {All = v175.Top, Today = v175.TopToday or {}}
                    drawBoard()
                end
                if v175.NoRecords then
                    local v176 = u1 and (u1.Ui)
                    if v176 then
                        v176:Banner("ROADSTER ONLY \194\183 NO TIMES OR MEDALS ON THE BOARDS")
                    end
                end
                if u4 ~= "finished" or not tbl_upv_3 or tbl_upv_3.Entry ~= Entry_upv_5 then
                    return
                end
                tbl_upv_24.Top = v175.Top
                showPanel("finished", tbl_upv_24)
            end
        )
    end
end
local function bindKeys(a1)
    --[[
      name: bindKeys
      line: 953
      upvalues:
        ContextActionService_upv_1 (copy, index: 1)
    ]]
    if a1 then
        ContextActionService_upv_1:BindActionAtPriority("TmnfKeys", function() end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Backspace, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter, Enum.KeyCode.L)
    else
        ContextActionService_upv_1:UnbindAction("TmnfKeys")
    end
end
leave = function()
    --[[
      name: leave
      line: 985
      upvalues:
        u14 (ref,  index: 1)
        tbl_upv_3 (ref,  index: 2)
        u4 (ref,  index: 3)
        u3 (ref,  index: 4)
        u5 (ref,  index: 5)
        u13 (ref,  index: 6)
        u15 (ref,  index: 7)
        u12 (ref,  index: 8)
        LocalPlayer_upv_1 (copy, index: 9)
        u22 (ref,  index: 10)
        u1 (ref,  index: 11)
        ContextActionService_upv_1 (copy, index: 12)
        hidePanel (ref,  index: 13)
        showBoard (copy, index: 14)
        u34 (ref,  index: 15)
        u39 (ref,  index: 16)
        u41 (ref,  index: 17)
    ]]
    u14 = u14 + 1
    if tbl_upv_3 or u4 ~= "idle" then
        task.spawn(pcall, u3.InvokeServer, u3, "Unload")
    end
    if tbl_upv_3 and tbl_upv_3.Folder then
        tbl_upv_3.Folder:Destroy()
    end
    tbl_upv_3 = nil
    u5 = nil
    u13 = nil
    u15 = nil
    if u12 then
        LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", u12.CF)
        LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", u12.Name)
        u12 = nil
    end
    if u22 then
        u22.Pull = nil
        u22.GravityUp = nil
    end
    if u4 ~= "idle" then
        local v177 = u1 and (u1.Ui)
        if v177 then
            v177:HideRun("Tmnf")
            v177:Claim(nil)
        end
    end
    u4 = "idle"
    ContextActionService_upv_1:UnbindAction("TmnfKeys")
    hidePanel()
    showBoard(false)
    if u34 then
        u34.Part:Destroy()
        u34 = nil
    end
    u39(nil)
    u41(false)
end
backToHub = function()
    --[[
      name: backToHub
      line: 1028
      upvalues:
        drivenCar (copy, index: 1)
        tbl_upv_3 (ref,  index: 2)
        leave (ref,  index: 3)
        u8 (ref,  index: 4)
        u19 (ref,  index: 5)
        Portal_upv_2 (copy, index: 6)
        Portal_upv_1 (copy, index: 7)
        Signals_upv_1 (copy, index: 8)
    ]]
    local v178 = drivenCar()
    local v179 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    leave()
    u8 = false
    u19 = false
    if v178 then
        local v180
        if v179 then
            v180 = Portal_upv_2.ExitCFrame()
        else
            v180 = Portal_upv_1.ExitCFrame(Portal_upv_1.CFRAME.Position + Portal_upv_1.CFRAME.LookVector)
        end
        Signals_upv_1.Fire("Reset", "teleport")
        v178:PivotTo(v180)
        v178.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        v178.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end
local function nextUnlocked()
    --[[
      name: nextUnlocked
      line: 1039
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        Index_upv_1 (copy, index: 2)
        u9 (ref,  index: 3)
    ]]
    local v181 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
    if v181 and v181.Level <= u9.Unlocked then
        return v181
    end
    return nil
end
local function buildPanel()
    --[[
      name: buildPanel
      line: 1047
      upvalues:
        Theme_upv_1 (copy, index: 1)
        LocalPlayer_upv_1 (copy, index: 2)
        C_upv_1 (copy, index: 3)
        Layout_upv_1 (copy, index: 4)
        F_upv_1 (copy, index: 5)
        Config_upv_1 (copy, index: 6)
        skipLevel (ref,  index: 7)
        tbl_upv_3 (ref,  index: 8)
        Index_upv_1 (copy, index: 9)
        u9 (ref,  index: 10)
        hidePanel (ref,  index: 11)
        loadLevel (ref,  index: 12)
        u13 (ref,  index: 13)
        showPanel (ref,  index: 14)
        backToHub (ref,  index: 15)
        u18 (ref,  index: 16)
        startRun (ref,  index: 17)
        openLevels (copy, index: 18)
    ]]
    local v182 = Theme_upv_1.new("ScreenGui", {ResetOnSpawn = false, IgnoreGuiInset = true, Name = "TmnfPanel", DisplayOrder = 39}, LocalPlayer_upv_1:WaitForChild("PlayerGui"))
    v182:SetAttribute("Toon", true)
    local v183 = Theme_upv_1.new("TextButton", {Visible = false, Modal = true, Selectable = false, Text = "", AutoButtonColor = false, BackgroundTransparency = 0.45, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundColor3 = C_upv_1.Bg}, v182)
    local tbl_25 = Theme_upv_1.Panel({BackgroundTransparency = 0.06, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(460, 514)}, v183)
    local v184 = Theme_upv_1.new("UIScale", {Scale = Layout_upv_1.Scale()}, tbl_25)
    local v185 = Theme_upv_1.Kicker({Text = "", Position = UDim2.fromOffset(24, 18), Size = UDim2.new(1, -48, 0, 20)}, tbl_25)
    local v186 = Theme_upv_1.Text({Text = "", TextSize = 34, Position = UDim2.fromOffset(24, 40), Size = UDim2.new(1, -48, 0, 44), FontFace = F_upv_1.Display, TextColor3 = C_upv_1.Good}, tbl_25)
    local v187 = Theme_upv_1.Text({TextWrapped = true, Text = "", TextSize = 15, Position = UDim2.fromOffset(24, 92), Size = UDim2.new(1, -48, 0, 150), TextColor3 = C_upv_1.Sub, TextYAlignment = Enum.TextYAlignment.Top}, tbl_25)
    local v188 = Theme_upv_1.new("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 24, 1, -20), Size = UDim2.new(1, -48, 0, 260)}, tbl_25)
    Theme_upv_1.new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom}, v188)
    tbl_25 = {}
    tbl_25.Shade = v183
    tbl_25.Scale = v184
    tbl_25.Head = v185
    tbl_25.Big = v186
    tbl_25.Info = v187
    tbl_25.Buttons = {}
    local tbl_26 = {}
    local tbl_27 = {"City", "BACK TO THE CITY  \194\183  ENTER", "primary"}
    local tbl_28 = {}
    tbl_28[1], tbl_28[2], tbl_28[3] = "Skip", string.format("SKIP LEVEL  \194\183  R$ %d", ((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipRobux)) or 20), "gold"
    tbl_26[1], tbl_26[2], tbl_26[3], tbl_26[4], tbl_26[5], tbl_26[6], tbl_26[7] = tbl_27, tbl_28, {"Next", "PLAY NEXT MAP  \194\183  ENTER", "primary"}, {"Stay", "KEEP PLAYING TRACKS", "ghost"}, {"Restart", "RESTART MAP  \194\183  BACKSPACE", "ghost"}, {"Levels", "LEVEL SELECT  \194\183  L", "ghost"}, {"Hub", "BACK TO HUB", "ghost"}
    for key_9, value_17 in tbl_26 do
        tbl_25.Buttons[value_17[1]] = Theme_upv_1.Button({TextSize = 14, Name = value_17[1], LayoutOrder = key_9, Size = UDim2.new(1, 0, 0, 36), Text = value_17[2]}, v188, value_17[3])
    end
    tbl_25.Buttons.Skip.Activated:Connect(
        function()
            --[[
              line: 1063
              upvalues:
                skipLevel (ref, index: 1)
            ]]
            skipLevel()
        end
    )
    local function playNext_1()
        --[[
          name: playNext
          line: 1066
          upvalues:
            tbl_upv_3 (ref,  index: 1)
            Index_upv_1 (copy, index: 2)
            u9 (ref,  index: 3)
            hidePanel (ref,  index: 4)
            loadLevel (ref,  index: 5)
        ]]
        local v189 = tbl_upv_3 and (Index_upv_1[tbl_upv_3.Entry.Level + 1])
        local v190 = not (v189) or not (v189.Level <= u9.Unlocked) or v189
        if not v190 then
            return
        end
        hidePanel(true)
        loadLevel(v190)
    end
    tbl_25.Buttons.Next.Activated:Connect(playNext_1)
    tbl_25.Buttons.Stay.Activated:Connect(
        function()
            --[[
              line: 1075
              upvalues:
                u13 (ref, index: 1)
                showPanel (ref, index: 2)
            ]]
            if not u13 then
                return
            end
            u13.Mission = nil
            showPanel("finished", u13)
        end
    )
    tbl_25.Buttons.City.Activated:Connect(backToHub)
    tbl_25.Buttons.Restart.Activated:Connect(
        function()
            --[[
              line: 1082
              upvalues:
                hidePanel (ref, index: 1)
                tbl_upv_3 (ref, index: 2)
                u18 (ref, index: 3)
                startRun (ref, index: 4)
            ]]
            hidePanel(true)
            local v191 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
            if v191 then
                u18 = 0
            end
            startRun()
        end
    )
    tbl_25.Buttons.Levels.Activated:Connect(
        function()
            --[[
              line: 1089
              upvalues:
                hidePanel (ref,  index: 1)
                openLevels (copy, index: 2)
            ]]
            hidePanel(true)
            openLevels()
        end
    )
    tbl_25.Buttons.Hub.Activated:Connect(backToHub)
    return tbl_25
end
local function fmt(a1)
    --[[
      name: fmt
      line: 93
    ]]
    if a1 == nil then
        return "--"
    end
    local v192 = math.floor(a1 / 60)
    local v193 = a1 - v192 * 60
    if v192 > 0 then
        return string.format("%d:%05.2f", v192, v193)
    end
    return string.format("%.2f", v193)
end
showPanel = function(a1, a2)
    --[[
      name: showPanel
      line: 1098
      upvalues:
        tbl_upv_3 (ref,  index: 1)
        u13 (ref,  index: 2)
        u6 (ref,  index: 3)
        buildPanel (copy, index: 4)
        u4 (ref,  index: 5)
        u11 (ref,  index: 6)
        drivenCar (copy, index: 7)
        u10 (ref,  index: 8)
        C_upv_1 (copy, index: 9)
        u5 (ref,  index: 10)
        stageLine (copy, index: 11)
        Obby_upv_1 (copy, index: 12)
        fmt (copy, index: 13)
        Layout_upv_1 (copy, index: 14)
        LocalPlayer_upv_1 (copy, index: 15)
        UserInputService_upv_1 (copy, index: 16)
        GuiService_upv_1 (copy, index: 17)
        Index_upv_1 (copy, index: 18)
        u9 (ref,  index: 19)
        title (copy, index: 20)
        Theme_upv_1 (copy, index: 21)
        passedHere (ref,  index: 22)
    ]]
    if not tbl_upv_3 then
        return
    end
    if a1 == "finished" then
        u13 = a2
    end
    local v194 = u6 or (buildPanel())
    u6 = v194
    local Entry_6 = tbl_upv_3.Entry
    local v195 = {}
    local v196 = (a1 == "finished") and (a2.Mission)
    local v197 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
    if v197 then
        if a1 ~= "paused" then
            u6.Head.Text = "OBBY COMPLETE"
            local Big_1 = u6.Big
            local v198, v199 = nil, nil
            if a2.Full then
                v198 = a2.Time
                local v200 = nil
                if v198 ~= nil then
                    v200 = math.floor(v198 / 60)
                    local v201 = v198 - v200 * 60
                    if v200 > 0 then
                        v199 = string.format("%d:%05.2f", v200, v201)
                    else
                        v199 = string.format("%.2f", v201)
                    end
                else
                    v199 = "--"
                end
            else
                v199 = "ALL STAGES"
            end
            Big_1.Text = v199
            u6.Big.TextColor3 = C_upv_1.Good
            if a2.Full then
                if (a2.NewBest) and (a2.Before) then
                    table.insert(v195, string.format("New best  (was %s)", fmt(a2.Before)))
                else
                    local v202 = nil
                    if a2.Before then
                        v202 = a2.Before
                        local v203, v201 = nil, nil
                        if v202 ~= nil then
                            v203 = math.floor(v202 / 60)
                            local v204 = v202 - v203 * 60
                            if v203 > 0 then
                                v201 = string.format("%d:%05.2f", v203, v204)
                            else
                                v201 = string.format("%.2f", v204)
                            end
                        else
                            v201 = "--"
                        end
                        table.insert(v195, "Best  " .. v201)
                    end
                end
            else
                table.insert(v195, "Run it from stage 1 to the finish for a time on the TOP 10.")
            end
            for key_10, value_18 in a2.Top or {} do
                if key_10 > 5 then
                    break
                else
                    table.insert(v195, string.format("%d.  %s   %s", key_10, value_18.Name, fmt(value_18.Time)))
                end
            end
        else
            local v205 = nil
            if u4 ~= "paused" then
                u11 = u4
                v205 = drivenCar()
                local v206
                if v205 then
                    v206 = v205:GetPivot()
                else
                    v206 = v205
                end
                u10 = v206
                u4 = "paused"
            end
            u6.Head.Text = "PAUSED"
            u6.Big.Text = "OBBY"
            u6.Big.TextColor3 = C_upv_1.Text
            local v207 = (u5 and (u5.Stage + 1)) or 1
            table.insert(v195, stageLine(v207))
            local v208 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v207]))
            local v209
            if v208 then
                v209 = {}
                v209.Name = v208.Name
                v209.Hint = v208.Hint
            else
                v209 = Obby_upv_1.Stage(v207)
            end
            table.insert(v195, v209.Hint)
        end
        local Info_1 = u6.Info
        Info_1.Text = table.concat(v195, "\n")
        u6.Buttons.Restart.Text = "RESTART FROM STAGE 1"
        local v210 = nil
        for key_11, _ in u6.Buttons do
            v210 = true
            if key_11 ~= "Restart" then
                v210 = key_11 == "Hub"
            end
            local v211
            v211.Visible = v210
        end
        local Scale_1 = u6.Scale
        Scale_1.Scale = Layout_upv_1.Scale()
        u6.Shade.Visible = true
        LocalPlayer_upv_1:SetAttribute("RoadsterUiOpen", true)
        if not UserInputService_upv_1.GamepadEnabled then
            return
        end
        GuiService_upv_1.SelectedObject = u6.Buttons.Restart
    else
        u6.Buttons.Restart.Text = "RESTART MAP  \194\183  BACKSPACE"
        u6.Buttons.Restart.Visible = true
        u6.Buttons.Levels.Visible = true
        local v212, v213, v214, v215, v216, v217 = nil, nil, nil, nil, nil, nil
        local v218 = nil
        if a1 ~= "paused" then
            local Head_2 = u6.Head
            local v219
            if v196 then
                v218 = string.format("MISSION COMPLETE  \194\183  +%d TESLA COINS", v196.Gold or 0)
            else
                v218 = string.format("%s  \194\183  FINISHED", title())
            end
            Head_2.Text = v218
            if v196 then
                if v196.Next then
                    table.insert(v195, string.format("NEXT MISSION: %s", v196.Next))
                end
                table.insert(v195, "TRACKS is always here: drive into its portal to come back.")
            end
            local Big_2 = u6.Big
            v212 = a2.Time
            local v220 = nil
            if v212 ~= nil then
                v220 = math.floor(v212 / 60)
                local v221 = v212 - v220 * 60
                if v220 > 0 then
                    v219 = string.format("%d:%05.2f", v220, v221)
                else
                    v219 = string.format("%.2f", v221)
                end
            else
                v219 = "--"
            end
            Big_2.Text = v219
            local Big_3 = u6.Big
            if a2.Medal then
                v219 = Theme_upv_1.Tier[a2.Medal]
            else
                v219 = C_upv_1.Good
            end
            Big_3.TextColor3 = v219
            if a2.Medal then
                table.insert(v195, string.format("%s MEDAL", string.upper(a2.Medal)))
            end
            local v224, v225 = nil, nil
            if (a2.NewBest) and (a2.Before) then
                table.insert(v195, string.format("New best  (was %s)", fmt(a2.Before)))
            elseif a2.Before then
                v213 = a2.Before
                if v213 ~= nil then
                    v224 = math.floor(v213 / 60)
                    local v223 = v213 - v224 * 60
                    if v224 > 0 then
                        v225 = string.format("%d:%05.2f", v224, v223)
                    else
                        v225 = string.format("%.2f", v223)
                    end
                else
                    v225 = "--"
                end
                table.insert(v195, "Best  " .. v225)
            end
            v213 = Entry_6.Gold
            if v213 ~= nil then
                v224 = math.floor(v213 / 60)
                v214 = v213 - v224 * 60
                if v224 > 0 then
                    v225 = string.format("%d:%05.2f", v224, v214)
                else
                    v225 = string.format("%.2f", v214)
                end
            else
                v225 = "--"
            end
            v213 = "    Silver  "
            v214 = Entry_6.Silver
            local v226, v227 = nil, nil
            if v214 ~= nil then
                v226 = math.floor(v214 / 60)
                v215 = v214 - v226 * 60
                if v226 > 0 then
                    v227 = string.format("%d:%05.2f", v226, v215)
                else
                    v227 = string.format("%.2f", v215)
                end
            else
                v227 = "--"
            end
            v215 = Entry_6.Bronze
            local v228, v229 = nil, nil
            if v215 ~= nil then
                v228 = math.floor(v215 / 60)
                local v230 = v215 - v228 * 60
                if v228 > 0 then
                    v229 = string.format("%d:%05.2f", v228, v230)
                else
                    v229 = string.format("%.2f", v230)
                end
            else
                v229 = "--"
            end
            table.insert(v195, "Gold  " .. v225 .. v213 .. v227 .. "    Bronze  " .. v229)
            local v231 = Index_upv_1[Entry_6.Level + 1]
            if Entry_6.Need and v231 and u9.Unlocked < v231.Level then
                v213 = string.upper(Entry_6.Need)
                v214 = Entry_6.NeedTime
                local v232 = nil
                if v214 ~= nil then
                    v232 = math.floor(v214 / 60)
                    v215 = v214 - v232 * 60
                    if v232 > 0 then
                        v227 = string.format("%d:%05.2f", v232, v215)
                    else
                        v227 = string.format("%.2f", v215)
                    end
                else
                    v227 = "--"
                end
                table.insert(v195, string.format("%s (%s) UNLOCKS LEVEL %d", v213, v227, v231.Level))
            end
            for key_12, value_19 in a2.Top or {} do
                if key_12 > 5 then
                    break
                else
                    table.insert(v195, string.format("%d.  %s   %s", key_12, value_19.Name, fmt(value_19.Time)))
                end
            end
        else
            if u4 ~= "paused" then
                u11 = u4
                local v233 = drivenCar()
                local v234 = v233 and (v233:GetPivot())
                u10 = v234
                u4 = "paused"
            end
            u6.Head.Text = "PAUSED"
            local Big_4 = u6.Big
            Big_4.Text = string.upper(Entry_6.Name)
            u6.Big.TextColor3 = C_upv_1.Text
            table.insert(v195, string.format("Level %d of %d", Entry_6.Level, #Index_upv_1))
            local v235 = "Time  "
            local v236 = (u5 and (u5.T)) or 0
            local v237, v201 = nil, nil
            if v236 ~= nil then
                v237 = math.floor(v236 / 60)
                local v238 = v236 - v237 * 60
                if v237 > 0 then
                    v201 = string.format("%d:%05.2f", v237, v238)
                else
                    v201 = string.format("%.2f", v238)
                end
            else
                v201 = "--"
            end
            table.insert(v195, v235 .. v201)
            if tbl_upv_3.Checkpoints > 0 and u5 then
                table.insert(v195, string.format("Checkpoints  %d / %d", u5.CpCount, tbl_upv_3.Checkpoints))
            end
            local v239 = "Gold  "
            v216 = Entry_6.Gold
            local v240 = nil
            if v216 ~= nil then
                v240 = math.floor(v216 / 60)
                v217 = v216 - v240 * 60
                if v240 > 0 then
                    v201 = string.format("%d:%05.2f", v240, v217)
                else
                    v201 = string.format("%.2f", v217)
                end
            else
                v201 = "--"
            end
            v217 = u9.Bests[Entry_6.Id]
            local v241, v242 = nil, nil
            if v217 ~= nil then
                v241 = math.floor(v217 / 60)
                local v243 = v217 - v241 * 60
                if v241 > 0 then
                    v242 = string.format("%d:%05.2f", v241, v243)
                else
                    v242 = string.format("%.2f", v243)
                end
            else
                v242 = "--"
            end
            table.insert(v195, v239 .. v201 .. "    Best  " .. v242)
        end
        local Info_2 = u6.Info
        Info_2.Text = table.concat(v195, "\n")
        local Next_2 = u6.Buttons.Next
        v218 = not v196
        if v218 then
            v195 = tbl_upv_3 and Index_upv_1[tbl_upv_3.Entry.Level + 1]
            local v244 = nil
            if not (v195) or not (v195.Level <= u9.Unlocked) then
                v244 = nil
            end
            v218 = v244 ~= nil
        end
        Next_2.Visible = v218
        local Skip_3 = u6.Buttons.Skip
        v218 = false
        if a1 == "paused" then
            local v245 = tbl_upv_3 and (tbl_upv_3.Entry)
            v218 = false
            if v245 ~= nil then
                v218 = not v245.Obby and ((Index_upv_1[v245.Level + 1] ~= nil) and (not passedHere(v245)))
            end
        end
        Skip_3.Visible = v218
        local City_1 = u6.Buttons.City
        City_1.Visible = v196
        local Stay_1 = u6.Buttons.Stay
        Stay_1.Visible = v196
        u6.Buttons.Hub.Visible = not v196
        local Scale_2 = u6.Scale
        Scale_2.Scale = Layout_upv_1.Scale()
        u6.Shade.Visible = true
        LocalPlayer_upv_1:SetAttribute("RoadsterUiOpen", true)
        if not UserInputService_upv_1.GamepadEnabled then
            return
        end
        if v196 then
            v218 = u6.Buttons.City
        elseif u6.Buttons.Next.Visible then
            v218 = u6.Buttons.Next
        else
            v218 = u6.Buttons.Restart
        end
        GuiService_upv_1.SelectedObject = v218
    end
end
hidePanel = function(a1)
    --[[
      name: hidePanel
      line: 1220
      upvalues:
        u6 (ref,  index: 1)
        buildPanel (copy, index: 2)
        LocalPlayer_upv_1 (copy, index: 3)
        GuiService_upv_1 (copy, index: 4)
        u4 (ref,  index: 5)
        u11 (ref,  index: 6)
    ]]
    local v246 = u6 or (buildPanel())
    u6 = v246
    if u6.Shade.Visible then
        LocalPlayer_upv_1:SetAttribute("RoadsterUiOpen", false)
        GuiService_upv_1.SelectedObject = nil
    end
    u6.Shade.Visible = false
    if u4 ~= "paused" or (a1) then
        return
    end
    u4 = u11 or "racing"
end
local function restorePanel()
    --[[
      name: restorePanel
      line: 1234
      upvalues:
        tbl_upv_3 (ref, index: 1)
        u6 (ref, index: 2)
        u4 (ref, index: 3)
        u13 (ref, index: 4)
        showPanel (ref, index: 5)
    ]]
    if not tbl_upv_3 then
        return
    end
    if not u6 or not u6.Shade.Visible then
        if u4 == "finished" and u13 then
            showPanel("finished", u13)
            return
        end
        if u4 == "paused" then
            showPanel("paused")
        end
        return
    end
end
local u42 = OverlapParams.new()
u42.FilterType = Enum.RaycastFilterType.Include
u42.RespectCanCollide = true
loadLevel = function(a1)
    --[[
      name: loadLevel
      line: 1250
      upvalues:
        u4 (ref,  index: 1)
        drivenCar (copy, index: 2)
        u2 (ref,  index: 3)
        Portal_upv_2 (copy, index: 4)
        Portal_upv_1 (copy, index: 5)
        tbl_upv_3 (ref,  index: 6)
        Signals_upv_1 (copy, index: 7)
        u7 (ref,  index: 8)
        u12 (ref,  index: 9)
        LocalPlayer_upv_1 (copy, index: 10)
        Menu_upv_1 (copy, index: 11)
        u14 (ref,  index: 12)
        u1 (ref,  index: 13)
        u3 (ref,  index: 14)
        restorePanel (ref,  index: 15)
        Workspace_upv_1 (copy, index: 16)
        u18 (ref,  index: 17)
        Course_upv_1 (copy, index: 18)
        obbyWindow (copy, index: 19)
        u42 (copy, index: 20)
        tbl_upv_1 (copy, index: 21)
        buildPlate (copy, index: 22)
        tbl_upv_14 (ref,  index: 23)
        drawBoard (copy, index: 24)
        showBoard (copy, index: 25)
        u39 (ref,  index: 26)
        ContextActionService_upv_1 (copy, index: 27)
        startRun (ref,  index: 28)
        u13 (ref,  index: 30)
        backToHub (ref,  index: 31)
        u9 (ref,  index: 32)
        hidePanel (ref,  index: 33)
        loadLevel (ref,  index: 34)
        openLevels (copy, index: 35)
        u17 (ref,  index: 36)
    ]]
    if u4 == "loading" then
        return
    end
    local v247 = drivenCar()
    local v248
    if (v247) and (v247:GetAttribute("Model") or "Roadster") ~= "Roadster" then
        if u2 then
            u2:Flash("TRACKS is ROADSTER ONLY  -  swap back to the Roadster in the garage", 4)
        end
        v248 = true
    else
        v248 = false
    end
    local v249 = nil
    if v248 then
        local v250
        if a1.Obby then
            v250 = Portal_upv_2
        else
            v250 = Portal_upv_1
        end
        if (tbl_upv_3) then
            return
        end
        if v250.Inside(v247.PrimaryPart.Position) then
            local v251 = v250.ExitCFrame(v247:GetPivot().Position)
            Signals_upv_1.Fire("Reset", "teleport")
            v247:PivotTo(v251)
            v247.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            v247.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    else
        if v247 then
            u7 = v247:GetPivot()
        end
        v249 = u4
        if v249 == "idle" and not (u12) then
            local tbl_29 = {}
            tbl_29.CF = LocalPlayer_upv_1:GetAttribute("RoadsterCheckpoint")
            tbl_29.Name = LocalPlayer_upv_1:GetAttribute("RoadsterCheckpointName")
            u12 = tbl_29
        end
        u4 = "loading"
        Menu_upv_1.Close()
        u14 = u14 + 1
        local v252 = ((a1.Obby) and "OBBY") or (string.format("LEVEL %d \194\183 %s", a1.Level, string.upper(a1.Name)))
        local v253 = u1 and (u1.Ui)
        if v253 then
            v253:Banner(v252)
        end
        local v254, v255
        v254, v253, v255 = pcall(u3.InvokeServer, u3, "Load", a1.Id)
        if u14 == u14 then
            if v254 and type(v253) == "table" then
                local v256
                if v253.Name then
                    v256 = Workspace_upv_1:WaitForChild(v253.Name, 30)
                else
                    v256 = nil
                end
                local v257 = os.clock()
                while v256 and (#v256:GetChildren() < v253.Parts) and (os.clock() - v257 < 30) and u14 == u14 do
                    task.wait(0.1)
                end
                if u14 == u14 then
                    local v258 = drivenCar()
                    if a1.Infinite then
                        v254 = a1.Tower.new(v253.Origin)
                    else
                        v254 = nil
                    end
                    local u43
                    if v254 then
                        local v259 = u1 and u1.Ui
                        if v259 then
                            v259:Banner("BUILDING THE TOWER")
                        end
                        v254:Ensure((math.max(0, u18) + 3) + 2, true)
                        local _, v260 = v254:Base()
                        local v261 = a1.Tower.HALF
                        local tbl_30 = {}
                        tbl_30.Parts = {}
                        tbl_30.Waypoints = {v254.Start}
                        tbl_30.Zones = v260
                        tbl_30.Path = {}
                        tbl_30.StageFloors = {}
                        tbl_30.Min = v253.Origin - Vector3.new(v261, 50, v261)
                        tbl_30.Max = v253.Origin + Vector3.new(v261, 1e+07, v261)
                        u43 = tbl_30
                    elseif a1.Layout then
                        u43 = a1.Layout(v253.Origin)
                    else
                        u43 = Course_upv_1.Layout(a1.Pieces, v253.Origin, a1.Theme, a1.Hard)
                    end
                    local v262 = nil
                    local v263 = 0
                    local v260, v261 = v263, v262
                    for _, value_20 in u43.Waypoints do
                        if value_20.Type == "Checkpoint" then
                            v260 = v260 + 1
                            continue
                        end
                        if value_20.Type == "Start" then
                            v261 = ((value_20.Spawn) and (value_20.Spawn + value_20.Spawn.UpVector * 2.5)) or v261
                        end
                    end
                    local pathIndex = v261 or (CFrame.new(v253.Origin + Vector3.new(0, 10, 0)))
                    local tbl_31 = {}
                    local tbl_32 = {}
                    local tbl_33 = {}
                    local v264 = (v256 and (v256:GetChildren())) or {}
                    for _, value_21 in v264 do
                        if value_21:GetAttribute("TmnfHazard") then
                            table.insert(tbl_33, value_21)
                        end
                        if value_21.Name == "Barrier" then
                            table.insert(tbl_31, value_21)
                            continue
                        end
                        if value_21.Name == "Moving" then
                            table.insert(tbl_32, {Part = value_21, Motion = {Kind = value_21:GetAttribute("Kind"), Pivot = value_21:GetAttribute("Pivot"), Period = value_21:GetAttribute("Period"), Phase = value_21:GetAttribute("Phase"), Amp = value_21:GetAttribute("Amp")}, Offset = value_21:GetAttribute("Offset")})
                        end
                    end
                    tbl_upv_3 = {Entry = a1, Origin = v253.Origin, Waypoints = u43.Waypoints, Zones = u43.Zones, Path = u43.Path, Min = u43.Min, Max = u43.Max, Barriers = tbl_31, Moving = tbl_32, Hazards = tbl_33, InZone = {}, OnPad = {}, Checkpoints = v260, Laps = a1.Laps or 0, SpawnCF = pathIndex}
                    if v254 then
                        tbl_32 = Instance.new("Folder")
                        tbl_32.Name = "ObbyTower"
                        Course_upv_1.Build(u43.Parts, tbl_32)
                        tbl_32.Parent = Workspace_upv_1
                        local v265 = tbl_upv_3
                        local v266 = tbl_upv_3
                        local v267 = tbl_upv_3
                        local v268 = tbl_upv_3
                        local tbl_34 = {}
                        local tbl_35 = {}
                        tbl_upv_3.Tower = v254
                        v265.Folder = tbl_32
                        v266.Built = tbl_34
                        v267.Walls = tbl_35
                        v268.GatesAdded = 0
                    end
                    if a1.Obby then
                        tbl_upv_3.StageGates = {}
                        for _, value_22 in u43.Waypoints do
                            if value_22.Type == "Checkpoint" then
                                table.insert(tbl_upv_3.StageGates, value_22)
                            end
                        end
                        tbl_upv_3.StageFloor = u43.StageFloors
                        if v254 then
                            obbyWindow(0)
                        end
                        if not (tbl_upv_3.StageFloor) then
                            pathIndex = function(a2)
                                --[[
                                  name: pathIndex
                                  line: 1371
                                  upvalues:
                                    u43 (ref, index: 1)
                                ]]
                                local v269 = math.huge
                                local v270 = 1
                                for key_13, value_23 in u43.Path do
                                    local Magnitude_1 = (value_23.CFrame.Position - a2).Magnitude
                                    if Magnitude_1 < v269 then
                                        v269, v270 = Magnitude_1, key_13
                                    end
                                end
                                return v270
                            end
                            local tbl_36 = {1}
                            for _, value_24 in tbl_upv_3.StageGates do
                                table.insert(tbl_36, (pathIndex((value_24.CFrame * CFrame.new(0, -30, 0)).Position)))
                            end
                            table.insert(tbl_36, #u43.Path)
                            tbl_upv_3.StageFloor = {}
                            for n_7 = 1, #tbl_36 - 1 do
                                pathIndex = math.huge
                                for n_8 = tbl_36[n_7], math.max(tbl_36[n_7], tbl_36[n_7 + 1]) do
                                    pathIndex = math.min(pathIndex, u43.Path[n_8].CFrame.Position.Y)
                                end
                                tbl_upv_3.StageFloor[n_7] = pathIndex - 90
                            end
                        end
                    end
                    if v258 and v258.PrimaryPart then
                        local CFrame_1 = v258.PrimaryPart.CFrame
                        v264 = Vector3.new(1, 1, 1) * math.huge
                        local v271 = Vector3.new(-1, -1, -1) * math.huge
                        local v272 = -math.huge
                        local v273
                        v273, v256 = v271, v272
                        for _, value_25 in v258:GetDescendants() do
                            local v274 = value_25:IsA("BasePart")
                            if not (v274) then
                                continue
                            end
                            if value_25.CanCollide or value_25.Transparency < 0.5 then
                                v253 = CFrame_1:ToObjectSpace(value_25.CFrame)
                                v254 = value_25.Size / 2
                                local v275 = Vector3.new(((math.abs(v253.XVector.X) * v254.X) + (math.abs(v253.YVector.X) * v254.Y)) + (math.abs(v253.ZVector.X) * v254.Z), ((math.abs(v253.XVector.Y) * v254.X) + (math.abs(v253.YVector.Y) * v254.Y)) + (math.abs(v253.ZVector.Y) * v254.Z), ((math.abs(v253.XVector.Z) * v254.X) + (math.abs(v253.YVector.Z) * v254.Y)) + (math.abs(v253.ZVector.Z) * v254.Z))
                                if value_25.CanCollide then
                                    v264, v273 = v264:Min(v253.Position - v275), v273:Max(v253.Position + v275)
                                    continue
                                end
                                if not (math.abs(v253.Position.X) < 4) then
                                    continue
                                end
                                if math.abs(v253.Position.Z) < 7 then
                                    v256 = math.max(v256, v253.Position.Y + v275.Y)
                                end
                            end
                        end
                        if v264.X < v273.X then
                            local v276 = Vector3.new(v273.X, math.max(v273.Y, math.min(v256, v273.Y + 2)), v273.Z)
                            local v277 = tbl_upv_3
                            local v278 = tbl_upv_3
                            v277.CarBox = CFrame.new((v264 + v276) / 2)
                            v278.CarSize = v276 - v264
                        end
                    end
                    u42.FilterDescendantsInstances = tbl_33
                    tbl_upv_1.Layout = u43
                    buildPlate()
                    tbl_upv_14 = {}
                    drawBoard()
                    showBoard(true)
                    task.spawn(
                        function()
                            --[[
                              line: 674
                              upvalues:
                                u3 (ref,  index: 1)
                                a1 (copy, index: 2)
                                tbl_upv_3 (ref,  index: 3)
                                tbl_upv_14 (ref,  index: 4)
                                drawBoard (copy, index: 5)
                            ]]
                            local success_7, v279 = pcall(u3.InvokeServer, u3, "Top", a1.Id)
                            local v280 = false
                            local v281 = nil
                            if not a1.Obby then
                                local success_8, v282 = pcall(u3.InvokeServer, u3, "Top", a1.Id, "today")
                                v280, v281 = success_8, v282
                            end
                            if not tbl_upv_3 then
                                return
                            end
                            if tbl_upv_3.Entry == a1 then
                                local v282
                                if (success_7) and type(v279) == "table" then
                                    v282 = v279
                                else
                                    v282 = {}
                                    v282 = v282
                                end
                                if a1.Obby then
                                    v282 = nil
                                elseif (v280) and type(v281) == "table" then
                                    v282 = v281
                                else
                                    v282 = {}
                                end
                                local v283 = nil
                                tbl_upv_14 = {All = v283, Today = v282}
                                drawBoard()
                            end
                        end
                    )
                    u39(a1.Lighting)
                    ContextActionService_upv_1:BindActionAtPriority(
                        "TmnfKeys",
                        function(a3, a4, a5)
                            --[[
                              line: 955
                              upvalues:
                                u4 (ref,  index: 1)
                                tbl_upv_3 (ref,  index: 2)
                                tbl_upv_1 (copy, index: 3)
                                startRun (ref,  index: 4)
                                u13 (ref,  index: 6)
                                backToHub (ref,  index: 7)
                                u9 (ref,  index: 8)
                                hidePanel (ref,  index: 9)
                                loadLevel (ref,  index: 10)
                                openLevels (copy, index: 11)
                            ]]
                            if a4 == Enum.UserInputState.Begin and u4 ~= "menu" and u4 ~= "loading" then
                                if a5.KeyCode ~= Enum.KeyCode.Backspace then
                                    if a5.KeyCode == Enum.KeyCode.Return or a5.KeyCode == Enum.KeyCode.KeypadEnter then
                                        local v284 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
                                        if not (v284) then
                                            if u4 == "finished" and u13 and u13.Mission then
                                                backToHub()
                                            else
                                                if u4 ~= "finished" and u4 ~= "paused" or not (tbl_upv_3) or not (tbl_upv_3.Level <= u9.Unlocked) then
                                                    return Enum.ContextActionResult.Pass
                                                end
                                                hidePanel(true)
                                                loadLevel(tbl_upv_3)
                                            end
                                            return Enum.ContextActionResult.Sink
                                        end
                                    end
                                    if a5.KeyCode == Enum.KeyCode.L then
                                        local v285 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
                                        if not (v285) then
                                            openLevels()
                                        end
                                    end
                                else
                                    local v286 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
                                    if (v286) and u4 ~= "finished" then
                                        tbl_upv_1.Checkpoint()
                                    else
                                        startRun()
                                    end
                                end
                                return Enum.ContextActionResult.Sink
                            end
                            return Enum.ContextActionResult.Pass
                        end,
                        false,
                        Enum.ContextActionPriority.High.Value,
                        Enum.KeyCode.Backspace,
                        Enum.KeyCode.Return,
                        Enum.KeyCode.KeypadEnter,
                        Enum.KeyCode.L
                    )
                    startRun()
                    if (u17) or not u2 then
                        return
                    end
                    u17 = true
                    task.delay(
                        2,
                        function()
                            --[[
                              line: 1435
                              upvalues:
                                u4 (ref,  index: 1)
                                u2 (ref,  index: 2)
                                a1 (copy, index: 3)
                            ]]
                            if u4 == "idle" then
                                return
                            end
                            u2:Flash(((a1.Obby) and "Leave the tower anytime: drive out of the opening, or BACK TO CITY at the top") or "Leave TRACKS anytime: BACK TO CITY at the top of the screen", 6)
                        end
                    )
                else
                    task.spawn(pcall, u3.InvokeServer, u3, "Unload")
                end
            else
                local v287 = string.upper(v255 or "couldn't load that level")
                local v288 = u1 and (u1.Ui)
                if v288 then
                    v288:Banner(v287)
                end
                if tbl_upv_3 then
                    local v289
                    if v249 ~= "menu" then
                        v289 = v249
                    else
                        v289 = "finished"
                    end
                    u4 = v289
                    restorePanel()
                else
                    u12 = nil
                    u4 = "idle"
                    if not v247 then
                        return
                    end
                    if u7 then
                        local v290
                        if a1.Obby then
                            v290 = Portal_upv_2
                        else
                            v290 = Portal_upv_1
                        end
                        local v291 = v290.ExitCFrame(u7.Position)
                        Signals_upv_1.Fire("Reset", "teleport")
                        v247:PivotTo(v291)
                        v247.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        v247.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        elseif v254 and type(v253) == "table" then
            task.spawn(pcall, u3.InvokeServer, u3, "Unload")
        end
    end
end
local u44 = nil
local u45 = nil
local u46 = 0
local u47 = function(a1, a2)
    --[[
      line: 1448
      upvalues:
        u46 (ref,  index: 1)
        u44 (ref,  index: 2)
        Workspace_upv_1 (copy, index: 3)
        u45 (ref,  index: 4)
    ]]
    if (os.clock() - u46 < 0.06) then
        return
    end
    u46 = os.clock()
    if not (u44) or not (u44.Parent) then
        u44 = Instance.new("Part")
        u44.Name = "ObbyGas"
        u44.Anchored = true
        u44.CanCollide = false
        u44.CanQuery = false
        u44.CanTouch = false
        u44.Transparency = 1
        u44.Size = Vector3.new(1, 1, 1)
        u44.Parent = Workspace_upv_1
        u45 = Instance.new("ParticleEmitter")
        u45.Texture = "rbxasset://textures/particles/smoke_main.dds"
        u45.Color = ColorSequence.new(Color3.fromRGB(235, 245, 255))
        u45.LightEmission = 0.4
        u45.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
        u45.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 18)})
        u45.Lifetime = NumberRange.new(0.5, 0.9)
        u45.Speed = NumberRange.new(60, 110)
        u45.SpreadAngle = Vector2.new(25, 25)
        u45.Drag = 4
        u45.Rate = 0
        u45.EmissionDirection = Enum.NormalId.Front
        u45.Parent = u44
    end
    u44.CFrame = CFrame.lookAt(a1, a1 + a2)
    u45:Emit(10)
end
local u48 = RaycastParams.new()
u48.FilterType = Enum.RaycastFilterType.Exclude
u48.RespectCanCollide = true
local function step(a1)
    --[[
      name: step
      line: 1482
      upvalues:
        syncNav (ref,  index: 1)
        syncCity (ref,  index: 2)
        syncSkip (copy, index: 3)
        drivenCar (copy, index: 4)
        u15 (ref,  index: 5)
        u4 (ref,  index: 6)
        leave (ref,  index: 7)
        Portal_upv_2 (copy, index: 8)
        u19 (ref,  index: 9)
        u7 (ref,  index: 10)
        u3 (ref,  index: 11)
        u9 (ref,  index: 12)
        u18 (ref,  index: 13)
        u21 (ref,  index: 14)
        u20 (ref,  index: 15)
        loadLevel (ref,  index: 16)
        Obby_upv_1 (copy, index: 17)
        Portal_upv_1 (copy, index: 18)
        u8 (ref,  index: 19)
        Index_upv_1 (copy, index: 20)
        u2 (ref,  index: 21)
        backToHub (ref,  index: 22)
        tbl_upv_3 (ref,  index: 23)
        Workspace_upv_1 (copy, index: 24)
        Course_upv_1 (copy, index: 25)
        u10 (ref,  index: 26)
        u42 (copy, index: 27)
        u5 (ref,  index: 28)
        u1 (ref,  index: 29)
        tbl_upv_8 (copy, index: 30)
        u41 (ref,  index: 31)
        u22 (ref,  index: 32)
        LocalPlayer_upv_1 (copy, index: 33)
        Signals_upv_1 (copy, index: 34)
        showRun (copy, index: 35)
        Track_upv_1 (copy, index: 36)
        u23 (ref,  index: 37)
        u47 (ref,  index: 38)
        u48 (copy, index: 39)
        tbl_upv_2 (copy, index: 40)
        obbyWindow (copy, index: 41)
        finish (copy, index: 42)
    ]]
    syncNav()
    syncCity()
    syncSkip()
    local v292 = drivenCar()
    if v292 and v292.PrimaryPart then
        u15 = nil
        local PrimaryPart_1 = v292.PrimaryPart
        local Position_upv_1 = PrimaryPart_1.Position
        if u4 ~= "idle" then
            if u4 ~= "loading" then
                local v293
                if (v292) and (v292:GetAttribute("Model") or "Roadster") ~= "Roadster" then
                    if u2 then
                        u2:Flash("TRACKS is ROADSTER ONLY  -  swap back to the Roadster in the garage", 4)
                    end
                    v293 = true
                else
                    v293 = false
                end
                if v293 then
                    backToHub()
                    return
                end
            end
            if u4 ~= "menu" and u4 ~= "loading" then
                local v294 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
                if not v294 or not Portal_upv_2.Outside(Position_upv_1) then
                    if Position_upv_1.X < tbl_upv_3.Min.X - 3000 or tbl_upv_3.Max.X + 3000 < Position_upv_1.X or Position_upv_1.Z < tbl_upv_3.Min.Z - 3000 or tbl_upv_3.Max.Z + 3000 < Position_upv_1.Z then
                        leave()
                    else
                        local v295 = Workspace_upv_1:GetServerTimeNow()
                        for _, value_26 in tbl_upv_3.Barriers do
                            local v296 = Course_upv_1.BarrierOpen(value_26:GetAttribute("Period"), value_26:GetAttribute("Open"), value_26:GetAttribute("Phase"), v295)
                            if value_26.CanCollide == v296 then
                                value_26.CanCollide = not v296
                                value_26.CanQuery = not v296
                                value_26.Transparency = (v296 and 0.85) or 0
                            end
                        end
                        for _, value_27 in tbl_upv_3.Moving do
                            value_27.Part.CFrame = Course_upv_1.Pose(value_27.Motion, v295) * value_27.Offset
                        end
                        if u4 ~= "finished" and u4 ~= "paused" then
                            local v297 = (u4 == "racing") and (tbl_upv_3.CarBox and ((#tbl_upv_3.Hazards > 0) and (#Workspace_upv_1:GetPartBoundsInBox(PrimaryPart_1.CFrame * tbl_upv_3.CarBox, tbl_upv_3.CarSize + Vector3.new(0.4000000059604645, 0.4000000059604645, 0.4000000059604645), u42) > 0)))
                            local v298 = (tbl_upv_3 ~= nil) and (tbl_upv_3.Entry.Obby == true)
                            local v299
                            if (v298) and (u5) then
                                v299 = tbl_upv_3.StageFloor[u5.Stage + 1] or (tbl_upv_3.Min.Y - 40)
                            else
                                v299 = tbl_upv_3.Min.Y - tbl_upv_3.Entry.Fall
                            end
                            if v297 or Position_upv_1.Y < v299 then
                                if v297 then
                                    local v300 = u1 and (u1.Ui)
                                    if v300 then
                                        v300:Banner("WRECKED")
                                    end
                                end
                                tbl_upv_8[tbl_upv_3.Entry.Id] = (tbl_upv_8[tbl_upv_3.Entry.Id] or 0) + 1
                                u41(false)
                                if u22 then
                                    u22.Pull = nil
                                    u22.GravityUp = nil
                                    u22.Gas = 1
                                end
                                local v301 = LocalPlayer_upv_1:GetAttribute("RoadsterCheckpoint") or (tbl_upv_3.SpawnCF)
                                Signals_upv_1.Fire("Reset", "teleport")
                                v292:PivotTo(v301)
                                v292.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                v292.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                u5.LastPos = nil
                            else
                                local u49, v302 = nil, nil
                                if u4 ~= "countdown" then
                                    local v303 = false
                                    for _, value_28 in tbl_upv_3.Zones do
                                        local v304 = Track_upv_1.Inside(value_28, Position_upv_1)
                                        if value_28.Type == "LowGravity" then
                                            v303 = v303 or v304
                                        elseif v304 and not tbl_upv_3.InZone[value_28] and value_28.Type == "Refuel" and u22 then
                                            u22.Gas = 1
                                            local v305 = u1 and (u1.Ui)
                                            if v305 then
                                                v305:Banner("REFUELLED")
                                            end
                                        end
                                        if value_28.Type == "Gravity" and v304 and u22 then
                                            if u22.GroundedCount >= 2 then
                                                tbl_upv_3.OnPad[value_28] = u22.Clock
                                            end
                                            if u23 and not (u22.GravityUp) and u22.Clock - (tbl_upv_3.OnPad[value_28] or -1e+09) < 0.3 then
                                                u22.GravityUp = {Until = u22.Clock + (value_28.Seconds or 3)}
                                            end
                                        end
                                        if value_28.Type == "Boost" and v304 then
                                            local AssemblyLinearVelocity_1 = PrimaryPart_1.AssemblyLinearVelocity
                                            local v306 = AssemblyLinearVelocity_1:Dot(value_28.Look)
                                            if v306 < value_28.Speed then
                                                PrimaryPart_1.AssemblyLinearVelocity = AssemblyLinearVelocity_1 + (value_28.Look * math.min(value_28.Speed - v306, 420 * a1))
                                            end
                                        end
                                        if value_28.Type == "Push" and v304 then
                                            local AssemblyLinearVelocity_2 = PrimaryPart_1.AssemblyLinearVelocity
                                            if AssemblyLinearVelocity_2:Dot(value_28.Normal) < (value_28.Speed or 60) then
                                                PrimaryPart_1.AssemblyLinearVelocity = AssemblyLinearVelocity_2 + ((value_28.Normal * (value_28.Accel or 320)) * a1)
                                                if value_28.Face then
                                                    u47(Position_upv_1 - (value_28.Normal * (Position_upv_1 - value_28.Face):Dot(value_28.Normal)), value_28.Normal)
                                                end
                                            end
                                        end
                                        if value_28.Type == "Jump" and v304 and u23 and u22 and not (u22.Pull) then
                                            u22:Vent(0.4)
                                            u22.GravityUp = nil
                                            u22.Pull = {Point = value_28.Point, Normal = value_28.Normal, Look = value_28.Look, Speed = math.max(130, PrimaryPart_1.AssemblyLinearVelocity.Magnitude), Start = u22.Clock, Until = u22.Clock + 1.6}
                                        end
                                        if value_28.Type ~= "LowGravity" then
                                            tbl_upv_3.InZone[value_28] = v304
                                        end
                                    end
                                    u41(v303)
                                    u48.FilterDescendantsInstances = {v292, LocalPlayer_upv_1.Character}
                                    local v307 = Workspace_upv_1:Raycast(Position_upv_1, PrimaryPart_1.CFrame.UpVector * -6, u48)
                                    local v308 = v307 and (v307.Instance:GetAttribute("TmnfSurface"))
                                    if v308 and tbl_upv_2[v308] then
                                        u5.TurboUntil = u5.T + tbl_upv_2[v308].Time
                                        u5.TurboAccel = tbl_upv_2[v308].Accel
                                    end
                                    if u5.T < u5.TurboUntil then
                                        PrimaryPart_1.AssemblyLinearVelocity = PrimaryPart_1.AssemblyLinearVelocity + ((PrimaryPart_1.CFrame.LookVector * u5.TurboAccel) * a1)
                                    end
                                    u5.T = u5.T + a1
                                    u49 = u5.LastPos or Position_upv_1
                                    u5.LastPos = Position_upv_1
                                    if (Position_upv_1 - u49).Magnitude > 60 then
                                        u49 = Position_upv_1
                                    end
                                    local u50 = math.clamp(math.ceil((Position_upv_1 - u49).Magnitude / 4), 1, 40)
                                    local function crossed_1(a2)
                                        --[[
                                          name: crossed
                                          line: 1694
                                          upvalues:
                                            u50 (copy, index: 1)
                                            Track_upv_1 (copy, index: 2)
                                            u49 (ref,  index: 3)
                                            Position_upv_1 (copy, index: 4)
                                        ]]
                                        for n_9 = 1, u50 do
                                            local v309 = Track_upv_1.Inside(a2, u49:Lerp(Position_upv_1, n_9 / u50))
                                            if not (v309) then
                                                continue
                                            end
                                            return true
                                        end
                                        return false
                                    end
                                    local v310 = nil
                                    local v311 = nil
                                    local v312 = nil
                                    for _, value_29 in tbl_upv_3.Waypoints do
                                        if value_29.Type ~= "Finish" then
                                            local v313 = crossed_1(value_29)
                                            if not (v313) then
                                                continue
                                            end
                                            if value_29.Type == "Checkpoint" and not u5.Cps[value_29] and false then
                                                local u51 = table.find(tbl_upv_3.StageGates, value_29)
                                                if u51 ~= u5.Stage + 1 then
                                                    continue
                                                end
                                                u5.Cps[value_29] = true
                                                u5.CpCount = u5.CpCount + 1
                                                u5.Stage = u51
                                                u21 = math.max(u21, u51)
                                                local v314 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", value_29.Spawn or (v314 + v314.UpVector * 5.5))
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "STAGE START")
                                                if u22 then
                                                    u22.Gas = 1
                                                end
                                                local v315 = string.format("STAGE %d CLEARED", u51)
                                                local v316 = u1 and (u1.Ui)
                                                if v316 then
                                                    v316:Banner(v315)
                                                end
                                                obbyWindow(u51)
                                                local Tower_upv_1 = tbl_upv_3.Tower
                                                task.spawn(
                                                    function()
                                                        --[[
                                                          line: 1727
                                                          upvalues:
                                                            Tower_upv_1 (copy, index: 1)
                                                            u51 (copy, index: 2)
                                                        ]]
                                                        Tower_upv_1:Ensure((u51 + 3) + 4, true)
                                                    end
                                                )
                                                if not (u2) then
                                                    task.spawn(
                                                        function()
                                                            --[[
                                                              line: 1733
                                                              upvalues:
                                                                u3 (ref,  index: 1)
                                                                u51 (copy, index: 2)
                                                                u1 (ref,  index: 3)
                                                            ]]
                                                            local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                            if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                                return
                                                            end
                                                            if v317.Earned > 0 then
                                                                local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                                local v319 = u1 and (u1.Ui)
                                                                if not v319 then
                                                                    return
                                                                end
                                                                v319:Banner(v318)
                                                            end
                                                        end
                                                    )
                                                    continue
                                                end
                                                local v320 = u2
                                                local format_3 = string.format
                                                local v321 = "%s  \194\183  %s"
                                                v310 = u51 + 1
                                                local format_4 = string.format
                                                local v322 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v310]))
                                                if v322 then
                                                    v312 = {}
                                                    v312.Name = v322.Name
                                                    v312.Hint = v322.Hint
                                                else
                                                    v312 = Obby_upv_1.Stage(v310)
                                                end
                                                local v323 = format_4("CHECKPOINT %d  \194\183  %s", v310, v312.Name)
                                                local v324 = u51 + 1
                                                local v325 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v324]))
                                                if v325 then
                                                    v310 = {}
                                                    v310.Name = v325.Name
                                                    v310.Hint = v325.Hint
                                                else
                                                    v310 = Obby_upv_1.Stage(v324)
                                                end
                                                v320:Flash(format_3(v321, v323, v310.Hint), 5)
                                                task.spawn(
                                                    function()
                                                        --[[
                                                          line: 1733
                                                          upvalues:
                                                            u3 (ref,  index: 1)
                                                            u51 (copy, index: 2)
                                                            u1 (ref,  index: 3)
                                                        ]]
                                                        local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                        if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                            return
                                                        end
                                                        if v317.Earned > 0 then
                                                            local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                            local v319 = u1 and (u1.Ui)
                                                            if not v319 then
                                                                return
                                                            end
                                                            v319:Banner(v318)
                                                        end
                                                    end
                                                )
                                            else
                                                if value_29.Type ~= "Checkpoint" or u5.Cps[value_29] then
                                                    if value_29.Type == "Finish" or value_29.Type == "StartFinish" and u5.T > 2 then
                                                        if not (tbl_upv_3.Checkpoints <= u5.CpCount) then
                                                            continue
                                                        end
                                                        if value_29.Type == "StartFinish" and tbl_upv_3.Laps > 1 and u5.Lap < tbl_upv_3.Laps then
                                                            u5.Lap = u5.Lap + 1
                                                            u5.Cps = {}
                                                            u5.CpCount = 0
                                                            local v326 = string.format("LAP %d / %d", u5.Lap, tbl_upv_3.Laps)
                                                            local v327 = u1 and (u1.Ui)
                                                            if v327 then
                                                                v327:Banner(v326)
                                                                continue
                                                            end
                                                        end
                                                        finish()
                                                        return
                                                    end
                                                    continue
                                                end
                                                u5.Cps[value_29] = true
                                                u5.CpCount = u5.CpCount + 1
                                                local v328 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", v328 + (v328.UpVector * 5.5))
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "CHECKPOINT")
                                                local T_3 = u5.T
                                                if T_3 ~= nil then
                                                    local v329 = math.floor(T_3 / 60)
                                                    local v330 = T_3 - v329 * 60
                                                    if v329 > 0 then
                                                        v311 = string.format("%d:%05.2f", v329, v330)
                                                    else
                                                        v311 = string.format("%.2f", v330)
                                                    end
                                                else
                                                    v311 = "--"
                                                end
                                                local v331 = string.format("%s   %d / %d", v311, u5.CpCount, tbl_upv_3.Checkpoints)
                                                local v332 = u1 and (u1.Ui)
                                                if v332 then
                                                    v332:Banner(v331)
                                                    continue
                                                end
                                            end
                                        elseif u5.CpCount < tbl_upv_3.Checkpoints then
                                            local v333 = crossed_1(value_29)
                                            if v333 then
                                                if not ((u5.MissedShown or 0) + 3 < u5.T) then
                                                    continue
                                                end
                                                u5.MissedShown = u5.T
                                                local v334 = string.format("CHECKPOINT MISSED  %d / %d  \194\183  C BACK TO THE LAST ONE", u5.CpCount, tbl_upv_3.Checkpoints)
                                                local v335 = u1 and (u1.Ui)
                                                if v335 then
                                                    v335:Banner(v334)
                                                    continue
                                                end
                                            else
                                                local v313 = crossed_1(value_29)
                                                if not (v313) then
                                                    continue
                                                end
                                                if value_29.Type == "Checkpoint" and not u5.Cps[value_29] and false then
                                                    local u51 = table.find(tbl_upv_3.StageGates, value_29)
                                                    if u51 ~= u5.Stage + 1 then
                                                        continue
                                                    end
                                                    u5.Cps[value_29] = true
                                                    u5.CpCount = u5.CpCount + 1
                                                    u5.Stage = u51
                                                    u21 = math.max(u21, u51)
                                                    local v314 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                    LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", value_29.Spawn or (v314 + v314.UpVector * 5.5))
                                                    LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "STAGE START")
                                                    if u22 then
                                                        u22.Gas = 1
                                                    end
                                                    local v315 = string.format("STAGE %d CLEARED", u51)
                                                    local v316 = u1 and (u1.Ui)
                                                    if v316 then
                                                        v316:Banner(v315)
                                                    end
                                                    obbyWindow(u51)
                                                    local Tower_upv_1 = tbl_upv_3.Tower
                                                    task.spawn(
                                                        function()
                                                            --[[
                                                              line: 1727
                                                              upvalues:
                                                                Tower_upv_1 (copy, index: 1)
                                                                u51 (copy, index: 2)
                                                            ]]
                                                            Tower_upv_1:Ensure((u51 + 3) + 4, true)
                                                        end
                                                    )
                                                    if not (u2) then
                                                        task.spawn(
                                                            function()
                                                                --[[
                                                                  line: 1733
                                                                  upvalues:
                                                                    u3 (ref,  index: 1)
                                                                    u51 (copy, index: 2)
                                                                    u1 (ref,  index: 3)
                                                                ]]
                                                                local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                                if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                                    return
                                                                end
                                                                if v317.Earned > 0 then
                                                                    local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                                    local v319 = u1 and (u1.Ui)
                                                                    if not v319 then
                                                                        return
                                                                    end
                                                                    v319:Banner(v318)
                                                                end
                                                            end
                                                        )
                                                        continue
                                                    end
                                                    local v320 = u2
                                                    local format_3 = string.format
                                                    local v321 = "%s  \194\183  %s"
                                                    v310 = u51 + 1
                                                    local format_4 = string.format
                                                    local v322 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v310]))
                                                    if v322 then
                                                        v312 = {}
                                                        v312.Name = v322.Name
                                                        v312.Hint = v322.Hint
                                                    else
                                                        v312 = Obby_upv_1.Stage(v310)
                                                    end
                                                    local v323 = format_4("CHECKPOINT %d  \194\183  %s", v310, v312.Name)
                                                    local v324 = u51 + 1
                                                    local v325 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v324]))
                                                    if v325 then
                                                        v310 = {}
                                                        v310.Name = v325.Name
                                                        v310.Hint = v325.Hint
                                                    else
                                                        v310 = Obby_upv_1.Stage(v324)
                                                    end
                                                    v320:Flash(format_3(v321, v323, v310.Hint), 5)
                                                    task.spawn(
                                                        function()
                                                            --[[
                                                              line: 1733
                                                              upvalues:
                                                                u3 (ref,  index: 1)
                                                                u51 (copy, index: 2)
                                                                u1 (ref,  index: 3)
                                                            ]]
                                                            local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                            if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                                return
                                                            end
                                                            if v317.Earned > 0 then
                                                                local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                                local v319 = u1 and (u1.Ui)
                                                                if not v319 then
                                                                    return
                                                                end
                                                                v319:Banner(v318)
                                                            end
                                                        end
                                                    )
                                                else
                                                    if value_29.Type ~= "Checkpoint" or u5.Cps[value_29] then
                                                        if value_29.Type == "Finish" or value_29.Type == "StartFinish" and u5.T > 2 then
                                                            if not (tbl_upv_3.Checkpoints <= u5.CpCount) then
                                                                continue
                                                            end
                                                            if value_29.Type == "StartFinish" and tbl_upv_3.Laps > 1 and u5.Lap < tbl_upv_3.Laps then
                                                                u5.Lap = u5.Lap + 1
                                                                u5.Cps = {}
                                                                u5.CpCount = 0
                                                                local v326 = string.format("LAP %d / %d", u5.Lap, tbl_upv_3.Laps)
                                                                local v327 = u1 and (u1.Ui)
                                                                if v327 then
                                                                    v327:Banner(v326)
                                                                    continue
                                                                end
                                                            end
                                                            finish()
                                                            return
                                                        end
                                                        continue
                                                    end
                                                    u5.Cps[value_29] = true
                                                    u5.CpCount = u5.CpCount + 1
                                                    local v328 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                    LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", v328 + (v328.UpVector * 5.5))
                                                    LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "CHECKPOINT")
                                                    local T_3 = u5.T
                                                    if T_3 ~= nil then
                                                        local v329 = math.floor(T_3 / 60)
                                                        local v330 = T_3 - v329 * 60
                                                        if v329 > 0 then
                                                            v311 = string.format("%d:%05.2f", v329, v330)
                                                        else
                                                            v311 = string.format("%.2f", v330)
                                                        end
                                                    else
                                                        v311 = "--"
                                                    end
                                                    local v331 = string.format("%s   %d / %d", v311, u5.CpCount, tbl_upv_3.Checkpoints)
                                                    local v332 = u1 and (u1.Ui)
                                                    if v332 then
                                                        v332:Banner(v331)
                                                        continue
                                                    end
                                                end
                                            end
                                        else
                                            local v313 = crossed_1(value_29)
                                            if not (v313) then
                                                continue
                                            end
                                            if value_29.Type == "Checkpoint" and not u5.Cps[value_29] and false then
                                                local u51 = table.find(tbl_upv_3.StageGates, value_29)
                                                if u51 ~= u5.Stage + 1 then
                                                    continue
                                                end
                                                u5.Cps[value_29] = true
                                                u5.CpCount = u5.CpCount + 1
                                                u5.Stage = u51
                                                u21 = math.max(u21, u51)
                                                local v314 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", value_29.Spawn or (v314 + v314.UpVector * 5.5))
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "STAGE START")
                                                if u22 then
                                                    u22.Gas = 1
                                                end
                                                local v315 = string.format("STAGE %d CLEARED", u51)
                                                local v316 = u1 and (u1.Ui)
                                                if v316 then
                                                    v316:Banner(v315)
                                                end
                                                obbyWindow(u51)
                                                local Tower_upv_1 = tbl_upv_3.Tower
                                                task.spawn(
                                                    function()
                                                        --[[
                                                          line: 1727
                                                          upvalues:
                                                            Tower_upv_1 (copy, index: 1)
                                                            u51 (copy, index: 2)
                                                        ]]
                                                        Tower_upv_1:Ensure((u51 + 3) + 4, true)
                                                    end
                                                )
                                                if not (u2) then
                                                    task.spawn(
                                                        function()
                                                            --[[
                                                              line: 1733
                                                              upvalues:
                                                                u3 (ref,  index: 1)
                                                                u51 (copy, index: 2)
                                                                u1 (ref,  index: 3)
                                                            ]]
                                                            local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                            if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                                return
                                                            end
                                                            if v317.Earned > 0 then
                                                                local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                                local v319 = u1 and (u1.Ui)
                                                                if not v319 then
                                                                    return
                                                                end
                                                                v319:Banner(v318)
                                                            end
                                                        end
                                                    )
                                                    continue
                                                end
                                                local v320 = u2
                                                local format_3 = string.format
                                                local v321 = "%s  \194\183  %s"
                                                v310 = u51 + 1
                                                local format_4 = string.format
                                                local v322 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v310]))
                                                if v322 then
                                                    v312 = {}
                                                    v312.Name = v322.Name
                                                    v312.Hint = v322.Hint
                                                else
                                                    v312 = Obby_upv_1.Stage(v310)
                                                end
                                                local v323 = format_4("CHECKPOINT %d  \194\183  %s", v310, v312.Name)
                                                local v324 = u51 + 1
                                                local v325 = tbl_upv_3 and (tbl_upv_3.Tower and (tbl_upv_3.Tower.Sections[v324]))
                                                if v325 then
                                                    v310 = {}
                                                    v310.Name = v325.Name
                                                    v310.Hint = v325.Hint
                                                else
                                                    v310 = Obby_upv_1.Stage(v324)
                                                end
                                                v320:Flash(format_3(v321, v323, v310.Hint), 5)
                                                task.spawn(
                                                    function()
                                                        --[[
                                                          line: 1733
                                                          upvalues:
                                                            u3 (ref,  index: 1)
                                                            u51 (copy, index: 2)
                                                            u1 (ref,  index: 3)
                                                        ]]
                                                        local success_9, v317 = pcall(u3.InvokeServer, u3, "ObbyStage", u51)
                                                        if not success_9 or type(v317) ~= "table" or not v317.Earned then
                                                            return
                                                        end
                                                        if v317.Earned > 0 then
                                                            local v318 = string.format("STAGE %d CLEARED  \194\183  +%d TESLA COINS", u51, v317.Earned)
                                                            local v319 = u1 and (u1.Ui)
                                                            if not v319 then
                                                                return
                                                            end
                                                            v319:Banner(v318)
                                                        end
                                                    end
                                                )
                                            else
                                                if value_29.Type ~= "Checkpoint" or u5.Cps[value_29] then
                                                    if value_29.Type == "Finish" or value_29.Type == "StartFinish" and u5.T > 2 then
                                                        if not (tbl_upv_3.Checkpoints <= u5.CpCount) then
                                                            continue
                                                        end
                                                        if value_29.Type == "StartFinish" and tbl_upv_3.Laps > 1 and u5.Lap < tbl_upv_3.Laps then
                                                            u5.Lap = u5.Lap + 1
                                                            u5.Cps = {}
                                                            u5.CpCount = 0
                                                            local v326 = string.format("LAP %d / %d", u5.Lap, tbl_upv_3.Laps)
                                                            local v327 = u1 and (u1.Ui)
                                                            if v327 then
                                                                v327:Banner(v326)
                                                                continue
                                                            end
                                                        end
                                                        finish()
                                                        return
                                                    end
                                                    continue
                                                end
                                                u5.Cps[value_29] = true
                                                u5.CpCount = u5.CpCount + 1
                                                local v328 = value_29.CFrame * CFrame.new(0, -30, 0)
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpoint", v328 + (v328.UpVector * 5.5))
                                                LocalPlayer_upv_1:SetAttribute("RoadsterCheckpointName", "CHECKPOINT")
                                                local T_3 = u5.T
                                                if T_3 ~= nil then
                                                    local v329 = math.floor(T_3 / 60)
                                                    local v330 = T_3 - v329 * 60
                                                    if v329 > 0 then
                                                        v311 = string.format("%d:%05.2f", v329, v330)
                                                    else
                                                        v311 = string.format("%.2f", v330)
                                                    end
                                                else
                                                    v311 = "--"
                                                end
                                                local v331 = string.format("%s   %d / %d", v311, u5.CpCount, tbl_upv_3.Checkpoints)
                                                local v332 = u1 and (u1.Ui)
                                                if v332 then
                                                    v332:Banner(v331)
                                                    continue
                                                end
                                            end
                                        end
                                        finish()
                                        return
                                    end
                                else
                                    v292:PivotTo(u5.SpawnCF or (tbl_upv_3.SpawnCF))
                                    v292.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    v292.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    u5.Countdown = u5.Countdown - a1
                                    v302 = math.ceil(u5.Countdown)
                                    if v302 ~= u5.Shown then
                                        u5.Shown = v302
                                        local v336 = ((not (v302 > 0)) and "GO!") or (tostring(v302))
                                        local v337 = u1 and (u1.Ui)
                                        if v337 then
                                            v337:Banner(v336)
                                        end
                                    end
                                    if u5.Countdown <= 0 then
                                        u4 = "racing"
                                    end
                                end
                                showRun()
                            end
                        elseif u10 then
                            v292:PivotTo(u10)
                            v292.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            v292.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
                leave()
            elseif u7 then
                v292:PivotTo(u7)
                v292.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                v292.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        elseif Portal_upv_2.Inside(Position_upv_1) then
            if u19 then
                u19 = false
                u7 = v292:GetPivot()
                u4 = "loading"
                task.spawn(
                    function()
                        --[[
                          line: 1504
                          upvalues:
                            u3 (ref,  index: 1)
                            u9 (ref,  index: 2)
                            u18 (ref,  index: 3)
                            u21 (ref,  index: 4)
                            u20 (ref,  index: 5)
                            u4 (ref,  index: 6)
                            loadLevel (ref,  index: 7)
                            Obby_upv_1 (copy, index: 8)
                        ]]
                        local success_10, v338 = pcall(u3.InvokeServer, u3, "Progress")
                        if success_10 and type(v338) == "table" then
                            u9 = v338
                        end
                        local success_11, v339 = pcall(u3.InvokeServer, u3, "ObbyProgress")
                        local v340
                        if (success_11) and type(v339) == "table" then
                            v340 = v339.Stage or 0
                        else
                            v340 = 0
                        end
                        u18 = v340
                        u21 = u18
                        u20 = true
                        u4 = "idle"
                        loadLevel(Obby_upv_1.Entry)
                    end
                )
            end
        else
            u19 = true
            if Portal_upv_1.Inside(Position_upv_1) then
                if u8 then
                    u8 = false
                    u7 = v292:GetPivot()
                    u4 = "loading"
                    task.spawn(
                        function()
                            --[[
                              line: 1525
                              upvalues:
                                u3 (ref,  index: 1)
                                u9 (ref,  index: 2)
                                u4 (ref,  index: 3)
                                Index_upv_1 (copy, index: 4)
                                loadLevel (ref,  index: 5)
                            ]]
                            local success_12, v341 = pcall(u3.InvokeServer, u3, "Progress")
                            if success_12 and type(v341) == "table" then
                                u9 = v341
                            end
                            u4 = "idle"
                            local v342 = u9.Next or (u9.Unlocked)
                            local v343 = Index_upv_1[math.clamp(v342, 1, #Index_upv_1)]
                            if not v343 then
                                return
                            end
                            loadLevel(v343)
                        end
                    )
                    return
                end
            else
                u8 = true
            end
        end
    else
        local v344 = u15 or (os.clock())
        u15 = v344
        if u4 ~= "idle" and u4 ~= "menu" and u4 ~= "loading" and os.clock() - u15 > 3 then
            leave()
        end
    end
end
local u52 = nil
syncCity = function()
    --[[
      name: syncCity
      line: 1767
      upvalues:
        u52 (ref,  index: 1)
        Theme_upv_1 (copy, index: 2)
        LocalPlayer_upv_1 (copy, index: 3)
        tbl_upv_1 (copy, index: 4)
        Layout_upv_1 (copy, index: 5)
        u4 (ref,  index: 6)
        u6 (ref,  index: 7)
    ]]
    if not (u52) then
        local v345 = Theme_upv_1.new("ScreenGui", {ResetOnSpawn = false, IgnoreGuiInset = true, Name = "TmnfCity", DisplayOrder = 2}, LocalPlayer_upv_1:WaitForChild("PlayerGui"))
        local v346 = Theme_upv_1.Button({Name = "City", Visible = false, Text = "BACK TO CITY", TextSize = 14, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(136, 30)}, v345, "primary")
        u52 = v346
        u52.Activated:Connect(tbl_upv_1.BackToHub)
        Layout_upv_1.Fit(v345)
        local function place_2()
            --[[
              name: place
              line: 1774
              upvalues:
                Layout_upv_1 (copy, index: 1)
                u52 (ref,  index: 2)
            ]]
            local v347 = Layout_upv_1.IsTouch()
            local v348
            if v347 then
                v348 = UDim2.fromOffset(112, 26)
            else
                v348 = UDim2.fromOffset(136, 30)
            end
            u52.Size = v348
            u52.TextSize = (v347 and 12) or 14
            local v349 = (v347 and (6 + (68 * Layout_upv_1.Scale()) + 6)) or 10
            u52.Position = UDim2.new(0.5, 0, 0, v349)
        end
        place_2()
        Layout_upv_1.Changed:Connect(place_2)
    end
    local v350 = u52
    local v351 = false
    if u4 ~= "idle" then
        v351 = false
        if u4 ~= "loading" then
            local _ = u6 and u6.Shade.Visible
            v351 = not u6 or not u6.Shade.Visible
        end
    end
    v350.Visible = v351
end
local u53 = nil
syncNav = function()
    --[[
      name: syncNav
      line: 1790
      upvalues:
        tbl_upv_1 (copy, index: 1)
        tbl_upv_3 (ref,  index: 2)
        u53 (ref,  index: 3)
        Menu_upv_1 (copy, index: 4)
        u24 (ref,  index: 5)
    ]]
    local v352 = tbl_upv_1.Active()
    local v353
    if v352 then
        local _ = tbl_upv_3 ~= nil and tbl_upv_3.Entry.Obby == true
        v353 = tbl_upv_3 == nil or tbl_upv_3.Entry.Obby ~= true
    else
        v353 = v352
    end
    local v354 = tostring(v352) .. tostring(v353)
    if v354 == u53 then
        return
    end
    u53 = v354
    Menu_upv_1.SetTabVisible("TRACKS", v353)
    Menu_upv_1.SetModeHidden({"MISSIONS", "AWARDS", "ACHIEVEMENTS"}, v352)
    if u24 then
        u24.SetVisible(v353)
    end
    if not (v352) and Menu_upv_1.IsOpen("TRACKS") then
        Menu_upv_1.Close()
    end
end
function tbl_upv_1.BackToHub()
    --[[
      name: BackToHub
      line: 1810
      upvalues:
        u4 (ref,  index: 1)
        Menu_upv_1 (copy, index: 2)
        backToHub (ref,  index: 3)
    ]]
    if u4 == "idle" then
        return
    end
    Menu_upv_1.Close()
    backToHub()
end
function tbl_upv_1.Start(a1)
    --[[
      name: Start
      line: 1817
      upvalues:
        u1 (ref,  index: 1)
        u2 (ref,  index: 2)
        u16 (ref,  index: 3)
        Menu_upv_1 (copy, index: 4)
        loadLevel (copy, index: 5)
        refreshPage (copy, index: 6)
        tbl_upv_5 (ref,  index: 7)
        u9 (ref,  index: 8)
        u24 (ref,  index: 9)
        C_upv_1 (copy, index: 10)
        openLevels (copy, index: 11)
        MarketplaceService_upv_1 (copy, index: 12)
        LocalPlayer_upv_1 (copy, index: 13)
        Config_upv_1 (copy, index: 14)
        u30 (ref,  index: 15)
        afterSkip (ref,  index: 16)
        syncNav (ref,  index: 17)
        u4 (ref,  index: 18)
        u11 (ref,  index: 19)
        drivenCar (copy, index: 20)
        u10 (ref,  index: 21)
        restorePanel (ref,  index: 22)
        u3 (ref,  index: 23)
        ReplicatedStorage_upv_1 (copy, index: 24)
        RunService_upv_1 (copy, index: 25)
        step (copy, index: 26)
        Index_upv_1 (copy, index: 27)
        loadLevel (ref,  index: 28)
    ]]
    u1 = a1 and (a1.Achievements)
    u2 = a1 and (a1.Hud)
    u16 = a1 and (a1.Mission)
    local function First()
        --[[
          name: First
          line: 1827
          upvalues:
            tbl_upv_5 (ref, index: 1)
            u9 (ref, index: 2)
        ]]
        local v355 = tbl_upv_5 and (tbl_upv_5.Rows[math.max(1, u9.Unlocked)] and (tbl_upv_5.Rows[math.max(1, u9.Unlocked)].Row))
        return v355
    end
    Menu_upv_1.Register({Name = "TRACKS", Order = 0, Key = "L", Build = buildPage, Refresh = refreshPage, First = First})
    local v356 = Menu_upv_1.Dock({Title = "LEVELS", Order = 0, Key = "L", Glyph = "boost", Color = C_upv_1.Good, OnClick = openLevels})
    u24 = v356
    MarketplaceService_upv_1.PromptProductPurchaseFinished:Connect(
        function(a2, a3, a4)
            --[[
              line: 1832
              upvalues:
                LocalPlayer_upv_1 (copy, index: 1)
                Config_upv_1 (copy, index: 2)
                u30 (ref,  index: 3)
                afterSkip (ref,  index: 4)
            ]]
            if a2 ~= LocalPlayer_upv_1.UserId then
                return
            end
            if a3 == (((Config_upv_1.Tmnf) and (Config_upv_1.Tmnf.SkipProductId)) or 0) then
                local v357 = (a4 and (os.clock() + 5)) or 0
                u30 = v357
                if not a4 then
                    return
                end
                task.wait(1)
                afterSkip()
            end
        end
    )
    syncNav()
    Menu_upv_1.Changed:Connect(
        function(a5)
            --[[
              line: 1843
              upvalues:
                u4 (ref,  index: 1)
                u11 (ref,  index: 2)
                drivenCar (copy, index: 3)
                u10 (ref,  index: 4)
                restorePanel (ref,  index: 5)
            ]]
            if a5 then
                if u4 ~= "racing" and u4 ~= "countdown" then
                    if not (a5) and u4 == "paused" then
                        u4 = u11 or "racing"
                        return
                    end
                    if not (a5) and u4 == "finished" then
                        restorePanel()
                    end
                    return
                end
                u11 = u4
                local v358 = drivenCar()
                local v359 = v358 and (v358:GetPivot())
                u10 = v359
                u4 = "paused"
                return
            end
            if not (a5) and u4 == "paused" then
                u4 = u11 or "racing"
                return
            end
            if (a5) then
                return
            end
            if u4 == "finished" then
                restorePanel()
            end
        end
    )
    u3 = ReplicatedStorage_upv_1:WaitForChild("Roadster"):WaitForChild("TmnfRemote", 60)
    if u3 then
        RunService_upv_1.Heartbeat:Connect(step)
        if RunService_upv_1:IsStudio() then
            LocalPlayer_upv_1:GetAttributeChangedSignal("TmnfLoad"):Connect(
                function()
                    --[[
                      line: 1863
                      upvalues:
                        LocalPlayer_upv_1 (copy, index: 1)
                        Index_upv_1 (copy, index: 2)
                        loadLevel (ref,  index: 3)
                    ]]
                    local v360 = LocalPlayer_upv_1:GetAttribute("TmnfLoad")
                    for _, value_30 in Index_upv_1 do
                        if value_30.Id == v360 then
                            LocalPlayer_upv_1:SetAttribute("TmnfResult", nil)
                            task.spawn(loadLevel, value_30)
                        end
                    end
                end
            )
        end
    else
        warn("[Tmnf] no TmnfRemote: Tmnf.Server isn't running")
    end
end
return tbl_upv_1