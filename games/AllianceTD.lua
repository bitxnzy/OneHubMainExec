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

local aeuatConnection
function aeuatFunction(enabled)
    if enabled == false then
        if aeuatConnection then
            aeuatConnection:Disconnect()
            aeuatConnection = nil
        end
        return
    end
    if aeuatConnection then
        return
    end

    local teleportQueued = false
    aeuatConnection = game.Players.LocalPlayer.OnTeleport:Connect(function(State)
        if (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) and not teleportQueued then
            teleportQueued = true

            queue_on_teleport([[
                        repeat task.wait() until game:IsLoaded()
<<<<<<< HEAD
                        if getgenv().executedEnabled then return end
=======
                        if getgenv().executedEnabled then return end    
>>>>>>> 4c87d72 (corrigido o errado da farmação de aura)
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/bitxnzy/OneHubMainExec/main/mainexec.lua"))()
                    ]])

            getgenv().executedEnabled = true
            task.wait(1)
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
    Webhook = tabGroups.TabGroup1:Tab({
        Name = "Webhook",
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

    MainSection99 = tabs.Webhook:Section({
        Side = "Left"
    }),
    MainSection100 = tabs.Settings:Section({
        Side = "Left"
    }),
    MainSection101 = tabs.Settings:Section({
        Side = "Right"
    })
}

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
local selectedMacro = "None"
local autoCollectGiftsEnabled = false
local autoCollectHourlyQuestsEnabled = false
local autoCollectHalloweenPassEnabled = false
local autoBuyUpgradeTowerEnabled = false
local autoJoinEnabled = false
local autoSkipWaveEnabled = false
local autoRestartEnabled = false
local autoVoteEnabled = false
local hidePlayerEnabled = false
local selectedStory = nil
local selectedVote = nil
local webhookUrl = ""
local autoSendEnabled = false
local sendWebhook -- forward declaration (definida mais abaixo)
local selectedUIMacro -- forward declaration (dropdown criado mais abaixo)
local SelectedMacroLabel -- forward declaration (label criado mais abaixo)
local StepLabel, ActionLabel, WaitingLabel -- forward declaration (status do macro)
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        if MacLib.Options and MacLib.Options.selectedUIMacro and MacLib.Options.selectedUIMacro.Value then
            local savedVal = MacLib.Options.selectedUIMacro.Value
            if savedVal and savedVal ~= "" and savedVal ~= "None" then
                selectedMacro = savedVal:gsub("%.json$", "")
                if SelectedMacroLabel and typeof(SelectedMacroLabel.UpdateName) == "function" then
                    SelectedMacroLabel:UpdateName("Selected Macro: " .. selectedMacro)
                end
            end
        end
    end)
end)
local macroName = ""
local selectedTypeOfRecord = "Time"
local selectedDelayMacro = 0.2
local macros = {}

local TeleportService = game:GetService("TeleportService")

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

    if string.find(texto, "lost connection", 1, true) or string.find(texto, "%f[%d]277%f[%D]") or
        string.find(texto, "%f[%d]769%f[%D]") or string.find(texto, "%f[%d]1025%f[%D]") then

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

local function sanitizeMacroName(name)
    name = tostring(name or "")
    name = name:gsub("%.json$", "")
    name = name:gsub("[\\/:*?\"<>|]", "")
    name = name:gsub("^%s+", "")
    name = name:gsub("%s+$", "")
    return name
end

local function setSelectedMacro(name)
    selectedMacro = (name and name ~= "") and name or "None"
    if SelectedMacroLabel and typeof(SelectedMacroLabel.UpdateName) == "function" then
        SelectedMacroLabel:UpdateName("Selected Macro: " .. selectedMacro)
    end
end

-- ===== STATUS DO MACRO (Step / Action / Waiting) =====
local macroStatusCache = {}
local lastWaitingUpdate = 0

local ACTION_NAMES = {
    PlaceTower = "Placing unit",
    UpgradeTower = "Upgrading unit",
    SellTower = "Selling unit"
}

local function setStatusLabel(label, key, text)
    if macroStatusCache[key] == text then
        return
    end
    macroStatusCache[key] = text
    if label and typeof(label.UpdateName) == "function" then
        label:UpdateName(text)
    end
end

-- 'force' ignora o limite de 0.2s (usado em mudancas de estado, nao em contagens)
local function setWaiting(text, force)
    local now = os.clock()
    if not force and (now - lastWaitingUpdate) < 0.2 then
        return
    end
    lastWaitingUpdate = now
    setStatusLabel(WaitingLabel, "waiting", text)
end

local function setMacroStatus(stepText, actionText, waitingText, force)
    if stepText then
        setStatusLabel(StepLabel, "step", stepText)
    end
    if actionText then
        setStatusLabel(ActionLabel, "action", actionText)
    end
    if waitingText then
        setWaiting(waitingText, force)
    end
end

local function resetMacroStatus()
    setMacroStatus("Step: -", "Action: Idle", "Waiting: -", true)
end

local function describeAction(actionName, arguments)
    local text = ACTION_NAMES[actionName] or tostring(actionName)
    local unitName
    for _, arg in ipairs(arguments or {}) do
        if type(arg) == "string" then
            unitName = arg
            break
        elseif type(arg) == "table" and arg.__Type == "TowerReference" and arg.Name then
            unitName = arg.Name
            break
        end
    end
    if unitName then
        text = text .. " (" .. unitName .. ")"
    end
    return text
end

local function formatSeconds(sec)
    if sec >= 60 then
        return string.format("%d:%02d", math.floor(sec / 60), math.floor(sec % 60))
    end
    return string.format("%.1fs", math.max(sec, 0.1))
end

local function formatCash(have, need)
    return string.format("Cash %d/%d", math.floor(have), math.floor(need))
end

local function updateDropdownFunction(selectName)
    local newMacros = {}
    if not isfolder(macrosFolder) then
        makefolder(macrosFolder)
    end
    for _, file in ipairs(listfiles(macrosFolder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(newMacros, name)
        end
    end
    table.sort(newMacros)
    macros = newMacros

    if selectedUIMacro then
        -- limpa as opcoes antigas e o estado interno do dropdown
        selectedUIMacro:ClearOptions()
        selectedUIMacro.Value = nil
        selectedUIMacro:UpdateName((selectedUIMacro.Settings.Name or "Select Macro") .. "...")

        -- recria as opcoes com os arquivos atuais
        selectedUIMacro:InsertOptions(macros)

        -- mantem/seleciona o macro desejado se ele ainda existir
        local target = selectName or selectedMacro
        if target and table.find(macros, target) then
            selectedUIMacro:UpdateSelection(target)
            setSelectedMacro(target)
        else
            setSelectedMacro("None")
        end
    end
end

local function createJsonFileFunction(fileName)
    fileName = sanitizeMacroName(fileName)
    if fileName == "" or fileName == "None" then
        return false
    end
    local filePath = macrosFolder .. "/" .. fileName .. ".json"
    if not isfile(filePath) then
        writefile(filePath, "{}")
    end
    updateDropdownFunction(fileName)
    return true
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

    setMacroStatus(string.format("Step: %d (recording)", remoteData.index),
        "Action: " .. describeAction(remoteName, remoteData.arguments), "Waiting: Your next action", true)
end

local originalNamecall
originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    -- caminho rapido: nao aloca nada quando nao esta gravando
    if not isRecording or checkcaller() then
        return originalNamecall(self, ...)
    end

    local method = getnamecallmethod()
    if method ~= "InvokeServer" and method ~= "FireServer" then
        return originalNamecall(self, ...)
    end

    local remoteName = self.Name
    if remoteName == "GetData" or remoteName == "GetGameSpeedState" then
        return originalNamecall(self, ...)
    end

    local args = {...}
    local results = table.pack(originalNamecall(self, ...))

    local rfFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions", true) or
                         ReplicatedStorage:FindFirstChild("Remotes", true)
    if rfFolder and (self.Parent == rfFolder or self:IsDescendantOf(rfFolder)) then
        task.spawn(function()
            pcall(collectRemoteInfoFunction, remoteName, args)
        end)
    end

    return table.unpack(results, 1, results.n)
end)

-- Espera o tempo e/ou dinheiro do passo (conforme o Recording Type) mostrando o que falta
local function waitForStepRequirements(step, startedAt)
    local useTime = (selectedTypeOfRecord == "Time" or selectedTypeOfRecord == "Hybrid") and step.time ~= nil
    local useCash = (selectedTypeOfRecord == "Cash" or selectedTypeOfRecord == "Hybrid") and step.cash ~= nil

    while isPlaying do
        local timeLeft = useTime and (step.time - (tick() - startedAt)) or 0
        local currentCash = getPlayerCash()
        local missingCash = useCash and currentCash < step.cash

        if timeLeft <= 0 and not missingCash then
            break
        end

        local parts = {}
        if timeLeft > 0 then
            table.insert(parts, "Time " .. formatSeconds(timeLeft))
        end
        if missingCash then
            table.insert(parts, formatCash(currentCash, step.cash))
        end
        setWaiting("Waiting: " .. table.concat(parts, " + "))

        task.wait(timeLeft > 0 and 0.05 or 0.2)
    end
end

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

    setMacroStatus(string.format("Step: 0/%d", #macroData.steps), "Action: Waiting for the match", "Waiting: Wave 1",
        true)

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
        resetMacroStatus()
        return
    end

    local remoteContainer = ReplicatedStorage:FindFirstChild("RemoteFunctions", true) or ReplicatedStorage
    local remoteCache = {}

    local playbackStartTime = tick()
    task.wait(1)

    local totalSteps = #macroData.steps
    local completed = true

    for i = 1, totalSteps do
        if not isPlaying then
            completed = false
            break
        end
        local step = macroData.steps[i]

        setMacroStatus(string.format("Step: %d/%d", i, totalSteps),
            "Action: " .. describeAction(step.action, step.arguments))

        waitForStepRequirements(step, playbackStartTime)

        if not isPlaying then
            completed = false
            break
        end
        setWaiting("Waiting: Executing action", true)

        local targetRemote = remoteCache[step.action]
        if not targetRemote or not targetRemote.Parent then
            targetRemote = remoteContainer:FindFirstChild(step.action, true)
            remoteCache[step.action] = targetRemote
        end

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
                        setWaiting("Waiting: Unit to appear", true)
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
                                setWaiting("Waiting: " .. formatCash(getPlayerCash(), requiredCash))
                                task.wait(0.2)
                            end
                        end

                        targetRemote:InvokeServer(unpack(realArgs))
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
    if completed then
        setMacroStatus(string.format("Step: %d/%d", totalSteps, totalSteps), "Action: Finished", "Waiting: -", true)
    else
        resetMacroStatus()
    end
end

local remoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions", 10)
local remoteFunc = remoteFunctions and remoteFunctions:FindFirstChild("GetData")

local function getPlayerData()
    if not remoteFunc then
        return nil
    end
    local ok, result = pcall(function()
        return remoteFunc:InvokeServer()
    end)
    return ok and result or nil
end

function autoCollectGiftsFunction()
    local claimRemote = remoteFunctions and remoteFunctions:FindFirstChild("ClaimPlaytimeGift")
    if not claimRemote then
        return
    end
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectGiftsEnabled do
            local currentData = getPlayerData()
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
    local claimQuestRemote = remoteFunctions and remoteFunctions:FindFirstChild("ClaimQuest")
    if not claimQuestRemote then
        return
    end
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectHourlyQuestsEnabled do
            local currentData = getPlayerData() -- antes usava um snapshot velho
            if currentData and currentData.SeasonQuestsHourly then
                local hourlyData = currentData.SeasonQuestsHourly
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
    local claimRemote = remoteFunctions and remoteFunctions:FindFirstChild("ClaimSeasonReward")
    if not claimRemote then
        return
    end
    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoCollectHalloweenPassEnabled do
            for i = 1, 50 do
                if not autoCollectHalloweenPassEnabled then
                    break
                end
                pcall(function()
                    claimRemote:InvokeServer(i, "Free")
                end)
                task.wait(0.5)
                if not autoCollectHalloweenPassEnabled then
                    break
                end
                pcall(function()
                    claimRemote:InvokeServer(i, "Paid")
                end)
                task.wait(0.5)
            end

            -- passada completa: espera antes de repetir (e para na hora se desligar)
            for _ = 1, 60 do
                if not autoCollectHalloweenPassEnabled then
                    break
                end
                task.wait(1)
            end
        end
    end)
end

local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
local upgradeConfigModule = modulesFolder and modulesFolder:FindFirstChild("UpgradeTreeConfig")
local upgradeConfig = upgradeConfigModule and require(upgradeConfigModule) or "None"
local selectedNode = "Start"
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
        return
    end

    task.spawn(function()
        local estaPronto = checarMapaWorkspace()
        if estaPronto then
            return
        end
        while autoBuyUpgradeTowerEnabled do
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
    return Workspace:GetAttribute("MapReady") == true
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
        local playerGui = player:WaitForChild("PlayerGui")
        local replayRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ReplayVote")

        local function endScreenVisible()
            local endGui = playerGui:FindFirstChild("GameEndUI")
            local frame = endGui and endGui:FindFirstChild("NewFrame")
            return endGui ~= nil and endGui.Enabled and frame ~= nil and frame.Visible
        end

        while autoRestartEnabled do
            if endScreenVisible() then
                task.wait(0.1) -- deixa a tela de fim assentar antes de votar

                -- vota assim que a tela aparece e repete a cada 2s enquanto ela
                -- continuar visivel (caso o primeiro voto seja ignorado)
                local lastVote = -math.huge
                while autoRestartEnabled and endScreenVisible() do
                    if os.clock() - lastVote >= 2 then
                        lastVote = os.clock()
                        pcall(function()
                            replayRemote:FireServer(true)
                        end)
                    end
                    task.wait(0.1)
                end
            else
                task.wait(0.1)
            end
        end
    end)
end

local matchesPlayed = 0
local targetMatches = 1
local autoLeaveEnabled = false
local autoLeaveAfterEnabled = false

function autoLeaveFunction()
    task.spawn(function()
        local returnRemote = ReplicatedStorage:WaitForChild("ReturnToLobby")
        while autoLeaveEnabled or autoLeaveAfterEnabled do
            returnRemote:FireServer(true)

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

        local joinQueue = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild(
            "sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("MatchmakingService")
            :WaitForChild("RF"):WaitForChild("JoinQueue")

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

            pcall(function()
                joinQueue:InvokeServer(mapId, 1)
            end)
            task.wait(1)
        end
    end)
end

function autoSpeedFunction()
    task.spawn(function()
        while autoSpeedEnabled do
                    local args = {
            [1] = 1.5
        }

        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("SetGameSpeed"):FireServer(
            unpack(args))
            task.wait(1)
        end
    end)
end

local function getText(root, ...)
    local node = root
    for _, childName in ipairs({...}) do
        node = node and node:FindFirstChild(childName)
    end
    return node and node.Text or "N/A"
end

function sendWebhook()
    if webhookUrl == "" then
        return
    end

    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end

    local gameEndUI = playerGui:FindFirstChild("GameEndUI")
    if not gameEndUI then
        return
    end

    local newFrame = gameEndUI:FindFirstChild("NewFrame")
    if not newFrame then
        return
    end
    local mapDisplayName = workspace:GetAttribute("mapdisplayname") or workspace:GetAttribute("MapDisplayName") or
                               "Unknown Map"
    local upside = newFrame:FindFirstChild("Upside")
    local runTime = getText(upside, "Timer", "TextLabel")
    local status = getText(upside, "StatusFrame", "Status")
    local mode = getText(upside, "Mode", "Mode")
    local winStreak = getText(upside, "WinStreak", "Title")
    local rewardsList = {}
    local listRewardsFolder = newFrame:FindFirstChild("ListRewards")

    if listRewardsFolder then
        for _, rewardFrame in ipairs(listRewardsFolder:GetChildren()) do
            if rewardFrame.Name:sub(1, 7) == "Reward_" then
                local rewardType = rewardFrame.Name:sub(8)
                local amountText = "0"

                if rewardFrame:FindFirstChild("Amount") then
                    amountText = rewardFrame.Amount.Text
                end

                table.insert(rewardsList, "**" .. rewardType .. "**: " .. amountText)
            end
        end
    end

    local rewardsFormatted = #rewardsList > 0 and table.concat(rewardsList, "\n") or "No Rewards"
    local embedColor = (status:lower():find("win") or status:lower():find("victory")) and 65280 or 16711680

    local payload = {
        ["embeds"] = {{
            ["title"] = "🎮 Match Results Summary",
            ["color"] = embedColor,
            ["fields"] = {{
                ["name"] = "🗺️ Map",
                ["value"] = tostring(mapDisplayName),
                ["inline"] = true
            }, {
                ["name"] = "⏱️ Time",
                ["value"] = tostring(runTime),
                ["inline"] = true
            }, {
                ["name"] = "📊 Status",
                ["value"] = tostring(status),
                ["inline"] = true
            }, {
                ["name"] = "⚔️ Mode",
                ["value"] = tostring(mode),
                ["inline"] = true
            }, {
                ["name"] = "🔥 Win Streak",
                ["value"] = tostring(winStreak),
                ["inline"] = true
            }, {
                ["name"] = "🎁 Rewards",
                ["value"] = rewardsFormatted,
                ["inline"] = false
            }},
            ["footer"] = {
                ["text"] = "Player: " .. player.Name
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
    if httpRequest then
        pcall(function()
            httpRequest({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

sections.MainSection1:Toggle({
    Name = "Hide Player Info",
    Default = false,
    Callback = function(value)
        hidePlayerEnabled = value
        if value then
            task.spawn(function()
                while hidePlayerEnabled do
                    pcall(function()
                        MacLib:HidePlayer(true)
                    end)
                    task.wait(1)
                end
            end)
        end
    end
}, "HidePlayerInfoToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Gifts",
    Default = false,
    Callback = function(value)
        autoCollectGiftsEnabled = value
        if value then
            autoCollectGiftsFunction()
        end
    end
}, "AutoCollectGiftsToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Quests",
    Default = false,
    Callback = function(value)
        autoCollectHourlyQuestsEnabled = value
        if value then
            autoCollectHourlyQuestsFunction()
        end
    end
}, "AutoCollectQuestsToggle")

sections.MainSection1:Toggle({
    Name = "Auto Collect Halloween Pass",
    Default = false,
    Callback = function(value)
        autoCollectHalloweenPassEnabled = value
        if value then
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
        autoSpeedEnabled = value
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

SelectedMacroLabel = sections.MainSection80:Label({
    Text = "Selected Macro: None"
})

StepLabel = sections.MainSection80:Label({
    Text = "Step: -"
})

ActionLabel = sections.MainSection80:Label({
    Text = "Action: Idle"
})

WaitingLabel = sections.MainSection80:Label({
    Text = "Waiting: -"
})

sections.MainSection80:Divider()

updateDropdownFunction()

selectedUIMacro = sections.MainSection80:Dropdown({
    Name = "Select Macro",
    Multi = false,
    Required = true,
    Options = macros,
    Default = "None",
    Callback = function(Value)
        if Value and Value ~= "" and Value ~= "None" then
            setSelectedMacro((Value:gsub("%.json$", "")))
        else
            setSelectedMacro("None")
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
        Window:Notify({
            Title = Window.Settings.Title,
            Description = "Macro list refreshed (" .. #macros .. ")",
            Lifetime = 3
        })
    end
})

sections.MainSection80:Button({
    Name = "Create Macro",
    Callback = function()
        local ok = createJsonFileFunction(macroName)
        Window:Notify({
            Title = Window.Settings.Title,
            Description = ok and ("Macro created: " .. sanitizeMacroName(macroName)) or "Type a valid macro name",
            Lifetime = 3
        })
    end
})

sections.MainSection80:Button({
    Name = "Delete Macro",
    Callback = function()
        if selectedMacro and selectedMacro ~= "None" then
            local filePath = macrosFolder .. "/" .. selectedMacro .. ".json"
            if isfile(filePath) then
                delfile(filePath)
                local deleted = selectedMacro
                setSelectedMacro("None")
                updateDropdownFunction()
                Window:Notify({
                    Title = Window.Settings.Title,
                    Description = "Macro deleted: " .. deleted,
                    Lifetime = 3
                })
                return
            end
        end
        Window:Notify({
            Title = Window.Settings.Title,
            Description = "No macro selected",
            Lifetime = 3
        })
    end
})

local recordingTarget = nil
local RecordMacroToggle
RecordMacroToggle = sections.MainSection80:Toggle({
    Name = "Record Macro",
    Default = false,
    Callback = function(value)
        if value then
            if not selectedMacro or selectedMacro == "None" then
                isRecording = false
                recordingTarget = nil
                Window:Notify({
                    Title = Window.Settings.Title,
                    Description = "Select or create a macro before recording",
                    Lifetime = 3
                })
                task.defer(function()
                    if RecordMacroToggle and typeof(RecordMacroToggle.SetState) == "function" then
                        RecordMacroToggle:SetState(false)
                    end
                end)
                return
            end

            recordingTarget = selectedMacro
            isRecording = true
            setMacroStatus("Step: 0 (recording)", "Action: Waiting for your first action", "Waiting: Your next action",
                true)
            recordingData = {
                steps = {},
                currentStepIndex = 0
            }
            startTime = tick()

            task.spawn(function()
                local Players = game:GetService("Players")
                while isRecording do
                    task.wait(1)
                    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    local endGui = playerGui and playerGui:FindFirstChild("GameEndUI")

                    if endGui and endGui.Enabled and endGui.NewFrame and endGui.NewFrame.Visible then
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
            if recordingTarget and recordingData and recordingData.steps and #recordingData.steps > 0 then
                local filePath = macrosFolder .. "/" .. recordingTarget .. ".json"
                table.sort(recordingData.steps, function(a, b)
                    return a.index < b.index
                end)
                local success, jsonData = pcall(function()
                    return HttpService:JSONEncode(recordingData)
                end)
                if success then
                    writefile(filePath, jsonData)
                end
            end
            recordingTarget = nil
            recordingData = {
                steps = {},
                currentStepIndex = 0
            }
            resetMacroStatus()
        end
    end
}, "RecordMacroToggle")

local PlayMacroToggle
PlayMacroToggle = sections.MainSection80:Toggle({
    Name = "Play Macro",
    Default = false,
    Callback = function(value)
        if value then
            if (not selectedMacro or selectedMacro == "None") and macros and #macros > 0 then
                selectedMacro = macros[1]
                SelectedMacroLabel:UpdateName("Selected Macro: " .. selectedMacro)
            end

            if not selectedMacro or selectedMacro == "None" then
                isPlaying = false
                return
            end

            isPlaying = true
            task.spawn(function()
                playMacro(selectedMacro)
            end)
        else
            isPlaying = false
            resetMacroStatus()
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

sections.MainSection99:Input({
    Name = "Discord Webhook URL",
    Placeholder = "Paste your webhook link here...",
    Callback = function(text)
        webhookUrl = text
    end
}, "DiscordWebhookURL")

sections.MainSection99:Toggle({
    Name = "Auto-Send Webhook on Game End",
    Default = false,
    Callback = function(state)
        autoSendEnabled = state
    end
}, "sendWebhookToggle")

sections.MainSection99:Button({
    Name = "Test / Send Webhook Now",
    Callback = function()
        task.spawn(sendWebhook)
    end
}, "testWebhookButton")

task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")
    local sending = false
    local lastFrame = nil

    while true do
        if not autoSendEnabled then
            lastFrame = nil
            task.wait(1)
        else
            task.wait(0.25)

            if not sending then
                local endGui = playerGui:FindFirstChild("GameEndUI")
                local frame = endGui and endGui:FindFirstChild("NewFrame")

                if not endGui or not frame or not endGui.Enabled or not frame.Visible then
                    lastFrame = nil
                elseif frame ~= lastFrame then
                    lastFrame = frame
                    sending = true

                    task.spawn(function()
                        task.wait(0.1)
                        pcall(sendWebhook)
                        sending = false
                    end)
                end
            end
        end
    end
end)

sections.MainSection100:Toggle({
    Name = "Auto Execute",
    Default = false,
    Callback = function(value)
        aeuatFunction(value)
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
        local scale = MacLib.Options.ChangeUISizeSlider.Value
        MacLib:changeUISize(scale)
    end
}, "ChangeUISizeSlider")

tabs.Main:Select()

MacLib:SetFolder("One Hub")
MacLib:SetFolder("One Hub/_ATD_")
local GameConfigName = "_ATD_"
local configName = player.Name .. GameConfigName
MacLib:LoadConfig(configName)

local function saveConfigSafe()
    pcall(function()
        MacLib:SaveConfig(configName)
    end)
end

task.spawn(function()
    while task.wait(5) do
        saveConfigSafe()
    end
end)

Window.onUnloaded(saveConfigSafe)

local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = game:GetService("Players").LocalPlayer
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
