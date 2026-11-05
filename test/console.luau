local s = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))


local TextLabel = Instance.new("TextLabel")
TextLabel.BorderSizePixel = 0
TextLabel.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
TextLabel.TextSize = 14
TextLabel.Size = UDim2.new(0.00, 200.00, 0.00, 50.00)
TextLabel.BorderColor3 = Color3.new(0.00, 0.00, 0.00)
TextLabel.TextColor3 = Color3.new(0.00, 0.00, 0.00)
TextLabel.Position = UDim2.new(0.38, 0.00, 0.76, 0.00)
TextLabel.Parent = game:GetService("StarterGui"):WaitForChild("ScreenGui")



local ASSETS = "https://raw.githubusercontent.com/ChatColours/dev/refs/heads/main/assets/"

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

TextLabel.Text = "Hello, world!"


local fontAsset = getAsset("font.ttf", "font.ttf")

local fontFamily = {
    name = "SteveHubFont",
    faces = {
        {
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = fontAsset
        }
    }
}

writefile(
    "Steve/assets/font.json",
    game.HttpService:JSONEncode(fontFamily)
)
local jsonAsset = getcustomasset("Steve/assets/font.json")
local success, result = pcall(function()
    return Font.new(jsonAsset)
end)

if success then
    TextLabel.FontFace = result
    print("Custom font applied!")
else
    warn("Failed to load font:", result)
end

