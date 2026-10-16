local TweenService = game:GetService("TweenService")
local AllowedPlaceIds = {
    [99703116573266] = true
}
local Games = {
    ["Alliance TD"] = { 99703116573266 }
}

local PlaceToGame = {}
for gameName, ids in pairs(Games) do
    for _, id in ipairs(ids) do
        PlaceToGame[id] = gameName
    end
end

local function LoadScript(gameName)
    local url = "https://raw.githubusercontent.com/TrilhaX/scriptexec/main/Games/" .. gameName
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    return success, result
end

local currentPlaceId = game.PlaceId
local targetGameName = PlaceToGame[currentPlaceId]

if not AllowedPlaceIds[currentPlaceId] then
    warn("Jogo não suportado. ID do lugar não permitido:", currentPlaceId)
    return
end

local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "LoaderGui"
LoaderGui.ResetOnSpawn = false

local successCore, _ = pcall(function()
    LoaderGui.Parent = game:GetService("CoreGui")
end)
if not successCore then
    LoaderGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local backgroundFrame = Instance.new("Frame", LoaderGui)
backgroundFrame.Name = "backgroundFrame"
backgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
backgroundFrame.BorderSizePixel = 0
backgroundFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
backgroundFrame.Size = UDim2.new(0, 300, 0, 300)

local imageLogo = Instance.new("ImageLabel", backgroundFrame)
imageLogo.Name = "imageLogo"
imageLogo.AnchorPoint = Vector2.new(0.5, 0.5)
imageLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
imageLogo.BorderSizePixel = 0
imageLogo.Position = UDim2.new(0.5, 0, 0.35, 0)
imageLogo.Size = UDim2.new(0, 300, 0, 250)
imageLogo.Image = "rbxassetid://100199291949935"

local textLoader = Instance.new("TextLabel", backgroundFrame)
textLoader.Name = "textLoader"
textLoader.AnchorPoint = Vector2.new(0.5, 0.5)
textLoader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textLoader.BorderSizePixel = 0
textLoader.Position = UDim2.new(0.5, 0, 0.9, 0)
textLoader.Size = UDim2.new(0, 250, 0, 30)
textLoader.Font = Enum.Font.PermanentMarker
textLoader.TextColor3 = Color3.fromRGB(0, 0, 0)
textLoader.TextScaled = true
textLoader.TextSize = 14
textLoader.TextWrapped = true

local backgroundBarFrame = Instance.new("Frame", backgroundFrame)
backgroundBarFrame.Name = "backgroundBarFrame"
backgroundBarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundBarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
backgroundBarFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
backgroundBarFrame.BorderSizePixel = 0
backgroundBarFrame.Position = UDim2.new(0.5, 0, 0.76, 0)
backgroundBarFrame.Size = UDim2.new(0, 250, 0, 20)

local barFrame = Instance.new("Frame", backgroundBarFrame)
barFrame.Name = "barFrame"
barFrame.AnchorPoint = Vector2.new(0, 0.5)
barFrame.BackgroundColor3 = Color3.fromRGB(85, 0, 127)
barFrame.BorderSizePixel = 0
barFrame.Position = UDim2.new(0, 0, 0.5, 0)
barFrame.Size = UDim2.new(0, 0, 1, 0)

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    if radius then corner.CornerRadius = radius end
    return corner
end

addCorner(backgroundBarFrame)
addCorner(barFrame)
addCorner(imageLogo, UDim.new(0, 4))
addCorner(backgroundFrame)

local uiStroke = Instance.new("UIStroke", backgroundBarFrame)
uiStroke.Thickness = 2.5

local function UpdateBar(Progress)
    local goal = { Size = UDim2.new(Progress, 0, 1, 0) }
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(barFrame, tweenInfo, goal):Play()
end

task.spawn(function()
    textLoader.Text = "Checking game..."
    task.wait(1)
    UpdateBar(0.33)

    if targetGameName then
        textLoader.Text = "Game: " .. targetGameName
        task.wait(1)
        
        textLoader.Text = "Checking components..."
        UpdateBar(0.66)
        task.wait(1)
        
        textLoader.Text = "Everything OK"
        UpdateBar(0.90)
        task.wait(0.5)
        
        textLoader.Text = "Loading script..."
        local success, result = LoadScript(targetGameName)

        if success then
            UpdateBar(1)
            textLoader.Text = "Loaded successfully!"
            task.wait(1)
            LoaderGui:Destroy()
        else
            warn("Failed to load script:", result)
            textLoader.Text = "Error loading script!"
            task.wait(2)
            LoaderGui:Destroy()
        end
    else
        warn("Game name not set for this PlaceId")
        textLoader.Text = "Game not supported"
        task.wait(2)
        LoaderGui:Destroy()
    end
end)