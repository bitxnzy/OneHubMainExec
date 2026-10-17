if not game:IsLoaded() then
    game.Loaded:Wait()
end
warn("[One HUB] Loading Ui")
task.wait()

local MacLib =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrilhaX/maclibTempestHubUI/main/maclib.lua"))()

local isMobile = game:GetService("UserInputService").TouchEnabled
local pcSize = UDim2.fromOffset(850, 650)
local mobileSize = UDim2.fromOffset(650, 400)
local currentSize = isMobile and mobileSize or pcSize

local Window = MacLib:Window({
    Title = "One Hub",
    Subtitle = "Alliance TD",
    Size = currentSize,
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = false,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true
})

function findGui(parent, name)
    return parent:FindFirstChild(name, true)
end

function normalize(str)
    return str:gsub("%s+", ""):lower()
end

function aeuatFunction()
    local teleportQueued = false
    game.Players.LocalPlayer.OnTeleport:Connect(function(State)
        if (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) and not teleportQueued then
            teleportQueued = true

            queue_on_teleport([[         
                        repeat task.wait() until game:IsLoaded()
                        if getgenv().executedEnabled then return end    
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/bitxnzy/OneHubMainExec/main/mainexec.lua"))()
                    ]])

            getgenv().executedEnabled = true
            wait(1)
            teleportQueued = false
        end
    end)
end

local globalSettings = {
    UIBlurToggle = Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool)
            Window:SetAcrylicBlurState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
                Lifetime = 5
            })
        end
    }),
    NotificationToggler = Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool)
            Window:SetNotificationsState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " Notifications",
                Lifetime = 5
            })
        end
    }),
    ShowUserInfo = Window:GlobalSetting({
        Name = "Show User Info",
        Default = Window:GetUserInfoState(),
        Callback = function(bool)
            bool = bool or false
            Window:SetUserInfoState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Showing" or "Redacted") .. " User Info",
                Lifetime = 5
            })
        end
    })
}
warn("[One Hub] Loading Function")
wait()
warn("[One Hub] Loading Toggles")
wait()
warn("[One Hub] Last Checking")
wait()

local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local originalSizes = {}
local pcSize2 = Vector2.new(850, 650)
local mobileSize2 = Vector2.new(750, 500)

function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function getBaseSize()
    return isMobile() and mobileSize2 or pcSize2
end

function storeOriginalFrameSizes(guiObject)
    for _, obj in ipairs(guiObject:GetDescendants()) do
        if obj:IsA("Frame") then
            if not originalSizes[obj] then
                originalSizes[obj] = obj.Size
            end
        end
    end
end

function resizeFrames(scale)
    local gui = CoreGui:FindFirstChild("MaclibGui")
    if not gui then
        return
    end

    storeOriginalFrameSizes(gui)

    local baseSize = getBaseSize()
    local widthScale = (baseSize.X * scale) / baseSize.X
    local heightScale = (baseSize.Y * scale) / baseSize.Y

    for frame, originalSize in pairs(originalSizes) do
        if frame and frame.Parent then
            frame.Size = UDim2.new(originalSize.X.Scale, math.floor(originalSize.X.Offset * widthScale),
                originalSize.Y.Scale, math.floor(originalSize.Y.Offset * heightScale))
        end
    end
end

local tabGroups = {
    TabGroup1 = Window:TabGroup()
}

local tabs = {
    Main = tabGroups.TabGroup1:Tab({
        Name = "Main",
        Image = "rbxassetid://18821914323"
    }),
    Macro = tabGroups.TabGroup1:Tab({
        Name = "Macro",
        Image = "rbxassetid://10735024209"
    }),
    Settings = tabGroups.TabGroup1:Tab({
        Name = "Settings",
        Image = "rbxassetid://10734950309"
    })
}

local sections = {
    MainSection1 = tabs.Main:Section({
        Side = "Left"
    }),
    MainSection2 = tabs.Main:Section({
        Side = "Right"
    }),
    MainSection80 = tabs.Macro:Section({
        Side = "Left"
    }),
    MainSection100 = tabs.Settings:Section({
        Side = "Left"
    }),
    MainSection101 = tabs.Settings:Section({
        Side = "Right"
    })
}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local macrosFolder = "OneHub/_ATD_/Macros"
if not isfolder(macrosFolder) then
    makefolder(macrosFolder)
end
local isRecording = false
local isPlaying = false
local recordingData = {
    steps = {},
    currentStepIndex = 0
}
local startTime = 0
local selectedMacro = (MacLib.Options.selectedUIMacro and MacLib.Options.selectedUIMacro.Value) or "None"
local macroName = ""
local selectedTypeOfRecord = "Time"
local selectedDelayMacro = 0.2
local macros = {}

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local tentandoReconectar = false

function tentarReconectar(mensagem)
    if tentandoReconectar then
        return
    end

    tentandoReconectar = true
    task.wait(10)
    TeleportService:Teleport(placeId, player)
end

GuiService.ErrorMessageChanged:Connect(function(mensagem)
    if type(mensagem) ~= "string" or mensagem == "" then
        return
    end

    local texto = string.lower(mensagem)

    if string.find(texto, "lost connection", 1, true) or string.find(texto, "277", 1, true) or
        string.find(texto, "769", 1, true) or string.find(texto, "1025", 1, true) then

        tentarReconectar(mensagem)
    end
end)

local function getPlayerCash()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash")
        if cash then
            return cash.Value
        end
    end
    return 0
end

local function getTowerPrice(towerInstance, priceType)
    if not towerInstance then
        return 0
    end

    local attrPrice = towerInstance:GetAttribute(priceType)
    if attrPrice then
        return tonumber(attrPrice) or 0
    end

    local valueObj = towerInstance:FindFirstChild(priceType)
    if valueObj and (valueObj:IsA("NumberValue") or valueObj:IsA("IntValue")) then
        return valueObj.Value
    end

    return 0
end

local function updateDropdownFunction()
    local newMacros = {}
    if isfolder(macrosFolder) then
        for _, file in ipairs(listfiles(macrosFolder)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(newMacros, name)
            end
        end
    end
    macros = newMacros
    if selectedUIMacro then
        selectedUIMacro:ClearOptions()
        selectedUIMacro:InsertOptions(macros)
    end
end

local function createJsonFileFunction(fileName)
    if not fileName or fileName == "" or fileName == "None" then
        return
    end
    local filePath = macrosFolder .. "/" .. fileName .. ".json"
    if not isfile(filePath) then
        writefile(filePath, "{}")
    end
    updateDropdownFunction()
    selectedMacro = fileName
    SelectedMacroLabel:UpdateName("Selected Macro: " .. selectedMacro)
    if selectedUIMacro then
        selectedUIMacro:SetOption(fileName)
    end
end

updateDropdownFunction()

local function getTowerCFrame(towerInstance)
    if not towerInstance then
        return nil
    end
    if towerInstance:IsA("Model") and towerInstance.PrimaryPart then
        return towerInstance.PrimaryPart.CFrame
    elseif towerInstance:IsA("BasePart") then
        return towerInstance.CFrame
    elseif towerInstance:IsA("Model") then
        local part = towerInstance:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.CFrame
        end
    end
    return nil
end

local function serializeArguments(args, remoteName)
    local serialized = {}
    for i = 1, #args do
        local arg = args[i]
        if typeof(arg) == "CFrame" then
            serialized[i] = {
                __Type = "CFrame",
                Components = {arg:GetComponents()}
            }
        elseif typeof(arg) == "Vector3" then
            serialized[i] = {
                __Type = "Vector3",
                Components = {arg.X, arg.Y, arg.Z}
            }
        elseif typeof(arg) == "Instance" then
            local cf = getTowerCFrame(arg)
            if cf then
                serialized[i] = {
                    __Type = "TowerReference",
                    CFrame = {cf:GetComponents()},
                    Name = arg.Name
                }
            else
                serialized[i] = arg.Name
            end
        else
            serialized[i] = arg
        end
    end
    return serialized
end

local function findTowerByCFrame(targetCFrame, tolerance)
    local towersFolder = workspace:FindFirstChild("Towers")
    if not towersFolder then
        return nil
    end

    tolerance = tolerance or 2.5
    for _, tower in ipairs(towersFolder:GetChildren()) do
        local cf = getTowerCFrame(tower)
        if cf then
            local distance = (cf.Position - targetCFrame.Position).Magnitude
            if distance <= tolerance then
                return tower
            end
        end
    end
    return nil
end

local function deserializeArguments(args)
    local deserialized = {}
    for i = 1, #args do
        local arg = args[i]
        if type(arg) == "table" and arg.__Type then
            if arg.__Type == "CFrame" then
                deserialized[i] = CFrame.new(unpack(arg.Components))
            elseif arg.__Type == "Vector3" then
                deserialized[i] = Vector3.new(unpack(arg.Components))
            elseif arg.__Type == "TowerReference" then
                local targetCF = CFrame.new(unpack(arg.CFrame))
                local foundTower = findTowerByCFrame(targetCF)
                deserialized[i] = foundTower
            else
                deserialized[i] = arg
            end
        else
            deserialized[i] = arg
        end
    end
    return deserialized
end

local function collectRemoteInfoFunction(remoteName, args)
    if not recordingData then
        recordingData = {
            steps = {},
            currentStepIndex = 0
        }
    end

    local remoteData = {
        action = remoteName,
        arguments = serializeArguments(args, remoteName),
        index = (recordingData.currentStepIndex or 0) + 1
    }

    recordingData.currentStepIndex = remoteData.index

    if selectedTypeOfRecord == "Time" or selectedTypeOfRecord == "Hybrid" then
        remoteData.time = tick() - startTime
    end

    if selectedTypeOfRecord == "Cash" or selectedTypeOfRecord == "Hybrid" then
        remoteData.cash = getPlayerCash()
    end

    table.insert(recordingData.steps, remoteData)
end

local originalNamecall
originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    local remoteName = self.Name
    if remoteName == "GetData" or remoteName == "GetGameSpeedState" then
        return originalNamecall(self, ...)
    end

    local results = {originalNamecall(self, ...)}

    if isRecording and not checkcaller() then
        if method == "InvokeServer" or method == "FireServer" then
            local rfFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions", true) or
                                 ReplicatedStorage:FindFirstChild("Remotes", true)
            if rfFolder and (self.Parent == rfFolder or self:IsDescendantOf(rfFolder)) then
                pcall(function()
                    task.spawn(function()
                        collectRemoteInfoFunction(remoteName, args)
                    end)
                end)
            end
        end
    end

    return unpack(results)
end)

local function playMacro(macroName)
    if not macroName or macroName == "None" then
        return
    end
    local filePath = macrosFolder .. "/" .. macroName .. ".json"
    if not isfile(filePath) then
        return
    end

    local fileContent = readfile(filePath)
    local success, macroData = pcall(function()
        return HttpService:JSONDecode(fileContent)
    end)

    if not success or not macroData or not macroData.steps then
        return
    end

    isPlaying = true

    local playerGui = player:WaitForChild("PlayerGui")
    while isPlaying do
        local waveReady = false
        pcall(function()
            local mainGameUI = playerGui:FindFirstChild("MainGameUI")
            local upSide = mainGameUI and mainGameUI:FindFirstChild("UpSide")
            local infoDop = upSide and upSide:FindFirstChild("InfoDop")
            local waveLabel = infoDop and infoDop:FindFirstChild("Wave")

            if waveLabel and waveLabel.Text then
                local currentWave = tonumber(waveLabel.Text:match("Wave%s+(%d+)"))
                if currentWave == 1 then
                    waveReady = true
                end
            end
        end)

        if waveReady then
            break
        end
        task.wait(0.5)
    end

    if not isPlaying then
        return
    end

    local playbackStartTime = tick()
    task.wait(1)

    for i = 1, #macroData.steps do
        if not isPlaying then
            break
        end
        local step = macroData.steps[i]

        if selectedTypeOfRecord == "Time" and step.time then
            local targetTime = step.time
            while isPlaying and (targetTime - (tick() - playbackStartTime)) > 0 do
                task.wait(0.05)
            end
        elseif selectedTypeOfRecord == "Cash" and step.cash then
            while isPlaying and getPlayerCash() < step.cash do
                task.wait(0.2)
            end
        elseif selectedTypeOfRecord == "Hybrid" then
            if step.time then
                local targetTime = step.time
                while isPlaying and (targetTime - (tick() - playbackStartTime)) > 0 do
                    task.wait(0.05)
                end
            end
            if step.cash then
                while isPlaying and getPlayerCash() < step.cash do
                    task.wait(0.2)
                end
            end
        end

        local remoteContainer = ReplicatedStorage:FindFirstChild("RemoteFunctions", true) or ReplicatedStorage
        local targetRemote = remoteContainer:FindFirstChild(step.action, true)

        if targetRemote then
            pcall(function()
                local realArgs = deserializeArguments(step.arguments)

                if step.action == "PlaceTower" then
                    local expectedCFrame = nil
                    for _, v in ipairs(step.arguments) do
                        if type(v) == "table" and v.__Type == "CFrame" then
                            expectedCFrame = CFrame.new(unpack(v.Components))
                        end
                    end

                    targetRemote:InvokeServer(unpack(realArgs))

                    if expectedCFrame then
                        local checkStart = tick()
                        while tick() - checkStart < 1.5 do
                            if findTowerByCFrame(expectedCFrame, 1.5) then
                                break
                            end
                            task.wait(0.05)
                        end
                    end

                elseif step.action == "UpgradeTower" then
                    local targetTower = realArgs[1]
                    if targetTower and typeof(targetTower) == "Instance" then
                        local requiredCash = getTowerPrice(targetTower, "UpgradePrice")

                        if requiredCash > 0 then
                            while isPlaying and getPlayerCash() < requiredCash do
                                task.wait(0.2)
                            end
                        end

                        targetRemote:InvokeServer(unpack(realArgs))
                    else
                        warn("[MACRO] Tower not found for Upgrade!")
                    end

                elseif step.action == "SellTower" then
                    if realArgs[1] and typeof(realArgs[1]) == "Instance" then
                        targetRemote:InvokeServer(unpack(realArgs))
                    end
                else
                    if targetRemote:IsA("RemoteFunction") then
                        targetRemote:InvokeServer(unpack(realArgs))
                    elseif targetRemote:IsA("RemoteEvent") then
                        targetRemote:FireServer(unpack(realArgs))
                    end
                end
            end)
        end

        task.wait(selectedDelayMacro)
    end

    isPlaying = false
end

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFunc = ReplicatedStorage:FindFirstChild("RemoteFunctions"):FindFirstChild("GetData")
local data = remoteFunc:InvokeServer()

function autoCollectGiftsFunction()
    local claimRemote = ReplicatedStorage:FindFirstChild("RemoteFunctions"):FindFirstChild("ClaimPlaytimeGift")
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectGiftsEnabled do
            local currentData = remoteFunc:InvokeServer()
            if currentData and currentData.PlaytimeGifts then
                local playtimeGifts = currentData.PlaytimeGifts
                local currentDay = playtimeGifts.Day
                local claimedTable = playtimeGifts.Claimed or {}

                for i = 1, 9 do
                    local giftKey = "Gift" .. i
                    local isClaimed = claimedTable[giftKey]

                    if isClaimed == false or isClaimed == nil then
                        local args = {
                            [1] = i,
                            [2] = currentDay
                        }

                        claimRemote:InvokeServer(unpack(args))
                        task.wait(0.5)
                    end
                end
            end
            task.wait(1)
        end
    end)
end

function autoCollectHourlyQuestsFunction()
    local claimQuestRemote = ReplicatedStorage:FindFirstChild("RemoteFunctions"):FindFirstChild("ClaimQuest")
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectHourlyQuestsEnabled do
            if data and data.SeasonQuestsHourly then
                local hourlyData = data.SeasonQuestsHourly
                local cycleId = hourlyData.CycleId
                local slots = hourlyData.Slots or {}

                for i, slot in ipairs(slots) do
                    if slot and not slot.Claimed and slot.Progress >= slot.Target then
                        local args = {
                            [1] = i,
                            [2] = cycleId
                        }

                        claimQuestRemote:InvokeServer(unpack(args))
                        task.wait(.5)
                    end
                end
            end
            task.wait(1)
        end
    end)
end

function autoCollectHalloweenPassFunction()
    local claimQuestRemote = ReplicatedStorage:FindFirstChild("RemoteFunctions"):FindFirstChild("ClaimQuest")
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectHalloweenPassEnabled do
            for i = 1, 50 do
                local args = {
                    [1] = tonumber(i),
                    [2] = "Free"
                }

                game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions"):FindFirstChild(
                    "ClaimSeasonReward"):InvokeServer(unpack(args))
                wait(1)
                local args = {
                    [1] = tonumber(i),
                    [2] = "Paid"
                }

                game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunctions"):FindFirstChild(
                    "ClaimSeasonReward"):InvokeServer(unpack(args))
            end
            task.wait(1)
        end
    end)
end

local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
local upgradeConfigModule = modulesFolder and modulesFolder:FindFirstChild("UpgradeTreeConfig")
local upgradeConfig = upgradeConfigModule and require(upgradeConfigModule) or "None"
local selectedNode = "Start"
local autoBuyEnabled = false
local upgradeOptions = {}
if type(upgradeConfig) == "table" and upgradeConfig.Order then
    for _, nodeName in ipairs(upgradeConfig.Order) do
        table.insert(upgradeOptions, nodeName)
    end
end

function autoBuyUpgradeTowerFunction()
    local remoteFuncs = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    local upgradeRemote = remoteFuncs and remoteFuncs:FindFirstChild("UpgradeTreeRemote")

    if not upgradeRemote then
        warn("UpgradeTreeRemote could not be found!")
        return
    end

    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoBuyEnabled do
            if selectedNode then
                local args = {
                    [1] = "Purchase",
                    [2] = selectedNode
                }
                upgradeRemote:InvokeServer(unpack(args))
            end
            task.wait(1)
        end
    end)
end

local Workspace = game:GetService("Workspace")

function checarMapaWorkspace()
    local mapId = Workspace:GetAttribute("MapId")
    local mapDisplayName = Workspace:GetAttribute("MapDisplayName")
    local mapReady = Workspace:GetAttribute("MapReady")

    if mapReady then
        return true
    else
        return false
    end
end

function autoVoteFunction()
    task.spawn(function()
        local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        local gameUIFolder = playerGui and playerGui:FindFirstChild("Folder: GameUI")
        local alrVoted = false
        if not gameUIFolder then
            return
        end

        local voteGameMode = gameUIFolder:FindFirstChild("VoteGameMode")
        if not voteGameMode then
            return
        end

        while voteGameMode.Enabled == true and voteGameMode.Frame.Visible == true and autoVoteEnabled and not alrVoted do
            local args = {
                [1] = selectedVote
            }

            local modeVoteRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ModeVote")
            local voteRemote = modeVoteRemote and modeVoteRemote:FindFirstChild("Vote")

            if voteRemote then
                voteRemote:FireServer(unpack(args))
                alrVoted = true
            end

            task.wait(1)
        end
    end)
end

local jaDeuReplay = false
function autoRestartFunction()
    task.spawn(function()
        while autoRestartEnabled do
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ReplayVote")
                :FireServer(true)
            task.wait(1)
        end
    end)
end

local matchesPlayed = 0
local targetMatches = 1
local autoLeaveEnabled = false
local autoLeaveAfterEnabled = false

function autoLeaveFunction()
    task.spawn(function()
        while autoLeaveEnabled or autoLeaveAfterEnabled do
            game:GetService("ReplicatedStorage"):WaitForChild("ReturnToLobby"):FireServer(true)
            
            if autoLeaveAfterEnabled then
                matchesPlayed = matchesPlayed + 1
                if matchesPlayed >= targetMatches then
                    autoLeaveAfterEnabled = false
                    autoLeaveEnabled = false
                    break
                end
            end
            
            task.wait(1)
        end
    end)
end

local targetAutoSkipWave = 10
local stopAutoSkipEnabled = false

function autoSkipWaveFunction()
    task.spawn(function()
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")

        local upSide = playerGui:WaitForChild("MainGameUI"):WaitForChild("UpSide")

        local waveLabel = upSide:WaitForChild("InfoDop"):WaitForChild("Wave")
        local skipGui = upSide:WaitForChild("Skip")

        local skipRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SkipWaveVote")

        local lastWave = nil

        while autoSkipWaveEnabled do
            local currentWave = tonumber(waveLabel.Text:match("Wave%s+(%d+)"))

            if stopAutoSkipEnabled and currentWave and currentWave >= targetAutoSkipWave then
                autoSkipWaveEnabled = false
                break
            end

            if skipGui.Visible and currentWave and currentWave ~= lastWave then
                lastWave = currentWave
                skipRemote:FireServer(currentWave)
            end

            task.wait(1)
        end
    end)
end

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local mapConfigModule = sharedFolder and sharedFolder:FindFirstChild("MapConfig")
local mapConfig = mapConfigModule and require(mapConfigModule) or nil
local mapOptions = {}
local mapsData = {}

if mapConfig and typeof(mapConfig.GetAll) == "function" then
    mapsData = mapConfig.GetAll()
    for _, mapInfo in ipairs(mapsData) do
        if mapInfo.DisplayName then
            table.insert(mapOptions, mapInfo.DisplayName)
        end
    end
end

function autoJoinFunction()
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end

        while autoJoinEnabled do
            local mapId = selectedStory
            if mapConfig and typeof(mapConfig.GetAll) == "function" then
                for _, mapInfo in ipairs(mapsData) do
                    if mapInfo.DisplayName == selectedStory then
                        mapId = mapInfo.Id
                        break
                    end
                end
            end

            local args = {
                [1] = mapId,
                [2] = 1
            }

            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0")
                :WaitForChild("knit"):WaitForChild("Services"):WaitForChild("MatchmakingService"):WaitForChild("RF")
                :WaitForChild("JoinQueue"):InvokeServer(unpack(args))
            task.wait(1)
        end
    end)
end

function autoSpeedFunction()
    task.spawn(function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(
            "GetGameSpeedState")
        local data = remote:InvokeServer()
        data.MaxSpeed = 1.5
        data.Speed = 1.5
    end)
end

sections.MainSection1:Toggle({
    Name = "Hide Player Info",
    Default = false,
    Callback = function(value)
        while value do
            MacLib:HidePlayer(value)
            task.wait(0.1)
        end
    end
}, "HidePlayerInfoToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Gifts",
    Default = false,
    Callback = function(value)
        if value then
            autoCollectGiftsEnabled = value
            autoCollectGiftsFunction()
        end
    end
}, "AutoCollectGiftsToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Quests",
    Default = false,
    Callback = function(value)
        if value then
            autoCollectHourlyQuestsEnabled = value
            autoCollectHourlyQuestsFunction()
        end
    end
}, "AutoCollectQuestsToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Halloween Pass",
    Default = false,
    Callback = function(value)
        if value then
            autoCollectHalloweenPassEnabled = value
            autoCollectHalloweenPassFunction()
        end
    end
}, "AutoCollectHalloweenPassToggle")

local selectedUpgradeBuy = sections.MainSection1:Dropdown({
    Name = "Upgrade to Focus",
    Multi = false,
    Required = true,
    Options = upgradeOptions,
    Default = "Start",
    Callback = function(Value)
        selectedNode = Value
    end
}, "selectedUpgradeBuy")

sections.MainSection1:Toggle({
    Name = "Auto Buy Upgrade Tower",
    Default = false,
    Callback = function(value)
        autoBuyUpgradeTowerEnabled = value

        if value then
            autoBuyUpgradeTowerFunction()
        end
    end
}, "AutoBuyUpgradeTowerToggle")

local selectedStoryDropdown = sections.MainSection1:Dropdown({
    Name = "Select Story",
    Multi = false,
    Required = true,
    Options = mapOptions,
    Default = selectedStory,
    Callback = function(Value)
        selectedStory = Value
    end
}, "selectedStoryDropdown")

sections.MainSection1:Toggle({
    Name = "Auto Join",
    Default = false,
    Callback = function(value)
        autoJoinEnabled = value

        if value then
            autoJoinFunction()
        end
    end
}, "autoJoinToggle")

sections.MainSection2:Toggle({
    Name = "Auto Skip Wave",
    Default = false,
    Callback = function(value)
        autoSkipWaveEnabled = value

        if value then
            autoSkipWaveFunction()
        end
    end
}, "autoSkipWaveToggle")

sections.MainSection2:Input({
    Name = "Stop Auto Skip at Wave X",
    Default = "10",
    Placeholder = "Wave limite",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            targetAutoSkipWave = num
        end
    end
}, "AutoSkipLimitInput")

sections.MainSection2:Toggle({
    Name = "Stop Auto Skip",
    Default = false,
    Callback = function(value)
        stopAutoSkipEnabled = value
    end
}, "StopAutoSkipToggle")

sections.MainSection2:Toggle({
    Name = "Auto Speed",
    Default = false,
    Callback = function(value)
        if value then
            autoSpeedFunction()
        end
    end
}, "autoSpeedToggle")

sections.MainSection2:Toggle({
    Name = "Auto Restart",
    Default = false,
    Callback = function(value)
        autoRestartEnabled = value

        if value then
            autoRestartFunction()
        end
    end
}, "autoRestartToggle")

sections.MainSection2:Toggle({
    Name = "Auto Leave",
    Default = false,
    Callback = function(value)
        autoLeaveEnabled = value

        if value then
            autoLeaveFunction()
        end
    end
}, "autoLeaveToggle")

sections.MainSection2:Input({
    Name = "Auto Leave after X matches",
    Default = "1",
    Placeholder = "Número de partidas",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            targetMatches = num
        end
    end
}, "AutoLeaveInput")

sections.MainSection2:Toggle({
    Name = "Auto Leave After X",
    Default = false,
    Callback = function(value)
        autoLeaveAfterEnabled = value

        if value then
            matchesPlayed = 0
            autoLeaveFunction()
        end
    end
}, "AutoLeaveAfterToggle")

local selectedVoteToStart = sections.MainSection2:Dropdown({
    Name = "Choose the Vote",
    Multi = false,
    Required = true,
    Options = {"Easy", "Medium", "Hard", "Insane", "Crazy"},
    Default = "Start",
    Callback = function(Value)
        selectedVote = Value
    end
}, "selectedVoteToStart")

sections.MainSection2:Toggle({
    Name = "Auto Vote",
    Default = false,
    Callback = function(value)
        autoVoteEnabled = value

        if value then
            autoVoteFunction()
        end
    end
}, "autoVoteToggle")

sections.MainSection80:Header({
    Name = "Macro"
})

local RecordingMethodLabel = sections.MainSection80:Label({
    Text = "Recording Method: Time"
})

local SelectedMacroLabel = sections.MainSection80:Label({
    Text = "Selected Macro: None"
})

sections.MainSection80:Divider()

updateDropdownFunction()

local selectedUIMacro = sections.MainSection80:Dropdown({
    Name = "Select Macro",
    Multi = false,
    Required = true,
    Options = macros,
    Default = "None",
    Callback = function(Value)
        if Value and Value ~= "" then
            selectedMacro = Value:gsub(".json$", "")
            SelectedMacroLabel:UpdateName("Selected Macro: " .. selectedMacro)
        end
    end
}, "selectedUIMacro")

sections.MainSection80:Input({
    Name = "Macro Name",
    Placeholder = "Type name...",
    AcceptedCharacters = "All",
    Callback = function(value)
        macroName = value
    end,
    onChanged = function(value)
        macroName = value
    end
}, "MacroNameInput")

sections.MainSection80:Button({
    Name = "Refresh List",
    Callback = function()
        updateDropdownFunction()
    end
})

sections.MainSection80:Button({
    Name = "Create Macro",
    Callback = function()
        if macroName and macroName ~= "" then
            createJsonFileFunction(macroName)
        end
    end
})

sections.MainSection80:Button({
    Name = "Delete Macro",
    Callback = function()
        if selectedMacro and selectedMacro ~= "None" then
            local filePath = macrosFolder .. "/" .. selectedMacro .. ".json"
            if isfile(filePath) then
                delfile(filePath)
                selectedMacro = "None"
                SelectedMacroLabel:UpdateName("Selected Macro: None")
                updateDropdownFunction()
            end
        end
    end
})

local RecordMacroToggle
RecordMacroToggle = sections.MainSection80:Toggle({
    Name = "Record Macro",
    Default = false,
    Callback = function(value)
        if value then
            if not selectedMacro or selectedMacro == "None" then
                warn("[MACRO] Selecione uma macro primeiro!")
                isRecording = false
                return
            end
            isRecording = true
            recordingData = {
                steps = {},
                currentStepIndex = 0
            }
            startTime = tick()
            print("[MACRO] Recording started...")

            task.spawn(function()
                local Players = game:GetService("Players")
                while isRecording do
                    task.wait(1)
                    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    local endGui = playerGui and playerGui:FindFirstChild("GameEndUI")

                    if endGui and endGui.Enabled and endGui.NewFrame and endGui.NewFrame.Visible then
                        print("[MACRO] Partida finalizada. Parando e salvando a gravação...")
                        isRecording = false

                        if RecordMacroToggle and typeof(RecordMacroToggle.SetState) == "function" then
                            RecordMacroToggle:SetState(false)
                        end
                        break
                    end
                end
            end)
        else
            isRecording = false
            if recordingData and recordingData.steps and #recordingData.steps > 0 then
                local filePath = macrosFolder .. "/" .. selectedMacro .. ".json"
                table.sort(recordingData.steps, function(a, b)
                    return a.index < b.index
                end)
                local success, jsonData = pcall(function()
                    return HttpService:JSONEncode(recordingData)
                end)
                if success then
                    writefile(filePath, jsonData)
                    print("[MACRO] Successfully saved to:", filePath)
                end
            end
        end
    end
}, "RecordMacroToggle")

local PlayMacroToggle
PlayMacroToggle = sections.MainSection80:Toggle({
    Name = "Play Macro",
    Default = false,
    Callback = function(value)
        if value then
            if not selectedMacro or selectedMacro == "None" then
                warn("[MACRO] Selecione uma macro primeiro!")
                isPlaying = false
                return
            end

            isPlaying = true
            task.spawn(function()
                playMacro(selectedMacro)
            end)
        else
            isPlaying = false
        end
    end
}, "PlayMacroToggle")

sections.MainSection80:Slider({
    Name = "Macro Delay",
    Default = 0.2,
    Minimum = 0,
    Maximum = 1,
    DisplayMethod = "Number",
    Precision = 1,
    Callback = function(Value)
        selectedDelayMacro = Value
    end
}, "selectedDelayMacroSlider")

sections.MainSection80:Dropdown({
    Name = "Recording Type",
    Multi = false,
    Required = true,
    Options = {"Time", "Cash", "Hybrid"},
    Default = "Time",
    Callback = function(Value)
        selectedTypeOfRecord = Value
        RecordingMethodLabel:UpdateName("Recording Method: " .. selectedTypeOfRecord)
    end
}, "SelectedRecordingMethod")

sections.MainSection100:Toggle({
    Name = "Auto Execute",
    Default = false,
    Callback = function(value)
        aeuatFunction()
    end
}, "AutoExecuteToggle")

sections.MainSection100:Toggle({
    Name = "Hide UI when Execute",
    Default = false,
    Callback = function(value)
        MacLib:HideUI(value)
    end
}, "HideUiWhenExecuteToggle")

sections.MainSection100:Toggle({
    Name = "Low cpu usage",
    Default = false,
    Callback = function(value)
        MacLib:lowCpuUsage(value)
    end
}, "LowCpuUsageToggle")

sections.MainSection100:Toggle({
    Name = "FPS Boost",
    Default = false,
    Callback = function(value)
        MacLib:FPSBoost(value)
    end
}, "FPSBoostToggle")

sections.MainSection100:Slider({
    Name = "Change UI Size",
    Default = 0.75,
    Minimum = 0.5,
    Maximum = 1.5,
    DisplayMethod = "Value",
    Precision = 1,
    Callback = function(Value)
        scale = MacLib.Options.ChangeUISizeSlider.Value
        MacLib:changeUISize(scale)
    end
}, "ChangeUISizeSlider")

Window.onUnloaded(function()
end)
tabs.Main:Select()

MacLib:SetFolder("One Hub")
MacLib:SetFolder("One Hub/_ATD_")
local GameConfigName = "_ATD_"
local player = game.Players.LocalPlayer
MacLib:LoadConfig(player.Name .. GameConfigName)
spawn(function()
    while task.wait(1) do
        MacLib:SaveConfig(player.Name .. GameConfigName)
    end
end)

local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = game:GetService("Players").LocalPlayer
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
