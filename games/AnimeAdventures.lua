if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
while not player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RS = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = player:WaitForChild("PlayerGui")

local LOBBY_PLACE_ID = 8304191830
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request or
                        (fluxus and fluxus.request)

local function findPath(root, ...)
    for i = 1, select("#", ...) do
        if not root then
            return nil
        end
        root = root:FindFirstChild((select(i, ...)))
    end
    return root
end

local function selList(v)
    local out = {}
    if type(v) == "table" then
        for k, val in pairs(v) do
            if type(k) == "number" then
                out[#out + 1] = tostring(val)
            elseif val then
                out[#out + 1] = tostring(k)
            end
        end
    elseif v ~= nil and v ~= "None" and v ~= "" then
        out[1] = tostring(v)
    end
    return out
end

local function selHas(list, value)
    value = tostring(value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end
    return false
end

local function baseName(n)
    return n:match("^(.-)_evolved$") or n:match("^(.-)_christmas$") or n:match("^(.-)_halloween$") or n
end

local statsClient
local function getStats()
    if statsClient then
        return statsClient
    end
    local loaderModule = findPath(RS, "src", "Loader")
    if not loaderModule then
        return nil
    end
    local loader = require(loaderModule)
    if type(loader) ~= "table" or type(loader.init) ~= "function" then
        return nil
    end
    for _, v in ipairs(debug.getupvalues(loader.init)) do
        if type(v) == "table" and v.StatsServiceClient then
            statsClient = v.StatsServiceClient
            return statsClient
        end
    end
    return nil
end

local function getSession()
    local stats = getStats()
    return stats and stats.module and stats.module.session
end

local function getCollection()
    local session = getSession()
    return session and session.collection and session.collection.collection_profile_data
end

local function getProfile()
    local session = getSession()
    return session and session.profile_data
end

local function getInventory()
    local session = getSession()
    return session and session.inventory and session.inventory.inventory_profile_data
end

local clientToServer
local remoteCache = {}
local function invoke(name, ...)
    local remote = remoteCache[name]
    if not remote then
        clientToServer = clientToServer or RS:WaitForChild("endpoints"):WaitForChild("client_to_server")
        remote = clientToServer:FindFirstChild(name) or clientToServer:WaitForChild(name, 5)
        if not remote then
            return nil
        end
        remoteCache[name] = remote
    end
    return remote:InvokeServer(...)
end

local function waitForGameReady()
    warn("[One HUB] Waiting for the game to load...")

    RS:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local src = RS:WaitForChild("src")
    src:WaitForChild("Loader")
    local data = src:WaitForChild("Data")
    for _, name in ipairs({"Worlds", "Maps", "Levels", "ChallengeAndRewards"}) do
        data:WaitForChild(name, 30)
    end
    RS:WaitForChild("packages"):WaitForChild("assets")
    RS:WaitForChild("LOBBY_ASSETS", 30)

    player:WaitForChild("_stats", 15)

    local t0 = os.clock()
    while not player.Character and os.clock() - t0 < 20 do
        task.wait(0.25)
    end

    t0 = os.clock()
    while os.clock() - t0 < 45 do
        local col = getCollection()
        if col and col.owned_units and col.equipped_units then
            break
        end
        task.wait(0.25)
    end

    if game.PlaceId == LOBBY_PLACE_ID then
        workspace:WaitForChild("_LOBBIES", 20)
    else
        workspace:WaitForChild("_MAP_CONFIG", 20)
    end
    task.wait(1)
    warn("[One HUB] Game ready")
end

waitForGameReady()

warn("[One HUB] Loading Ui")

local MacLib =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TrilhaX/maclibTempestHubUI/main/maclib.lua"))()

local isMobile = game:GetService("UserInputService").TouchEnabled
local pcSize = UDim2.fromOffset(868, 650)
local mobileSize = UDim2.fromOffset(800, 550)
local currentSize = isMobile and mobileSize or pcSize
hideInfoPlayerEnabled = false
autoWalkEnabled = false
securityModeEnabled = false
deletemapEnabled = false
autoleaveEnabled = false
autoreplayEnabled = false
autonextEnabled = false
autoNextPortalEnabled = false
autoNextContratoEnabled = false
autostartEnabled = false
autoskipwaveEnabled = false
autoGetBattlepassEnabled = false
autoGetQuestEnabled = false
disableNotificationsEnabled = false
placeInRedZonesEnabled = false
showInfoUnitsEnabled = false
autoGivePresentsEnabled = false
autoRollPassiveEnabled = false
autoFeedEnabled = false
pingUser = false
autoEnterPortalEnabled = false
AutoMatchmakingEnabled = false
autoContractMatchmakingEnabled = false
autoContractEnabled = false
selectedHardInfCastleEnabled = false
autoEnterInfiniteCastleEnabled = false
autoJoinCursedWombEnabled = false
autoEnterEnabled = false
autoJoinLastStoryEnabled = false
worldSkipEnabled = false
autoEquipTeamEnabled = false
dupeGriffithEnabled = false
dupeVegetoEnabled = false
autoChooseCardEnabled = false
focusBuffEnabled = false
focusDebuffEnabled = false
autoPlaceEnabled = false
OnlyautoPlaceEnabled = false
autoUpgradeEnabled = false
onlyupgradeinXwaveEnabled = false
autoSellEnabled = false
autoSellFarmWaveXEnabled = false
autoLeaveInXWaveEnabled = false
universalSkillEnabled = false
universalSkillinXWaveEnabled = false
autoSacrificeGriffithEnabled = false
autoOpenCapsuleEnabled = false
autoCraftShardEnabled = false
autoBuyEnabled = false
autoRollSakamotoBannerEnabled = false
PriorityJoinActive = false
loadedallscript = false
autoJoinPlayerEnabled = false
autoEnterChallengeEnabled = false
autoEnterDailyChallengeEnabled = false
autoMatchmakingDailyChallengeEnabled = false
autoEnterRaidEnabled = false
autoEnterLegendStageEnabled = false

local distancePercentage
local GroundPercentage
local HillPercentage

local Window = MacLib:Window({
    Title = "One Hub",
    Subtitle = "Anime Adventures",
    Size = currentSize,
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true
})

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
local selectedMapChallenges = {}
local selectedChallengesDiff = {}
local selectedTierContract = {}
local selectedIgnoreContractChallenge = {}
local selectedIgnoreDmgBonus = {}
local selectedTierPortal = {}
local selectedPortalDiff = {}
local selectedPassiveToRoll = {}
local dmgBonus = {"None", "air", "physical", "light", "fire", "storm", "dark", "magic", "aqua"}
local passivesValues = {"superior 1", "range 1", "nimble 1", "superior 2", "range 2", "nimble 2", "superior 3",
                        "range 3", "nimble 3", "adept 1", "culling 1", "sniper 1", "godspeed 1", "reaper 1",
                        "celestial 1", "divine 1", "golden 1", "unique 1"}
local shardsValues = {"nagumo_shard", "madoka_portal_shard", "dazai_shard", "relic_shard"}
local selectedPriorities = {
    Buff = {},
    Debuff = {}
}
local Cards = {
    Buff = {"+ Attack I", "+ Attack II", "+ Attack III", "+ Boss Damage I", "+ Boss Damage II", "+ Boss Damage III",
            "+ Gain 2 Random Effects Tier 1", "+ Gain 2 Random Effects Tier 2", "+ Gain 2 Random Effects Tier 3",
            "+ Range I", "+ Range II", "+ Range III", "+ Random Blessings I", "+ Random Blessings II",
            "+ Random Blessings III", "+ Yen I", "+ Yen II", "+ Yen III", "- Cooldown I", "- Cooldown II",
            "- Cooldown III", "- Active Cooldown I", "- Active Cooldown II", "- Active Cooldown III",
            "+ Double Attack, Half Range", "+ Double Attack, Double Cooldown", "+ Double Attack", "+ Double Range"},
    Debuff = {"+ Enemy Health I", "+ Enemy Health II", "+ Enemy Health III", "+ Enemy Shield I", "+ Enemy Shield II",
              "+ Enemy Shield III", "+ Enemy Speed I", "+ Enemy Speed II", "+ Enemy Speed III", "+ Enemy Regen I",
              "+ Enemy Regen II", "+ Enemy Regen III", "+ Explosive Deaths I", "+ Explosive Deaths II",
              "+ Explosive Deaths III", "+ New Path", "+ Random Curses I", "+ Random Curses II", "+ Random Curses III"}
}

local loopsRunning = {}
local joinStarters = {}

local function makeLoop(name, isEnabled, body, interval, isJoin)
    local function start()
        if loopsRunning[name] then
            return
        end
        loopsRunning[name] = true
        task.spawn(function()
            while isEnabled() and not (isJoin and PriorityJoinActive) do
                if loadedallscript == true then
                    local ok, err = pcall(body)
                    if not ok then
                        warn("[One HUB] " .. name .. ": " .. tostring(err))
                    end
                end
                task.wait(interval or 1)
            end
            loopsRunning[name] = nil
        end)
    end
    if isJoin then
        joinStarters[#joinStarters + 1] = start
    end
    return start
end

function resumeJoinLoops()
    for _, start in ipairs(joinStarters) do
        start()
    end
end

local function resultsOpen()
    local ui = PlayerGui:FindFirstChild("ResultsUI")
    return ui ~= nil and ui.Enabled == true
end

local function currentWave()
    local w = workspace:FindFirstChild("_wave_num")
    return w and tonumber(w.Value) or 0
end

local function ownedByPlayer(unit)
    local owner = findPath(unit, "_stats", "player")
    return owner ~= nil and owner.Value == player
end

local function equippedUnitsByName()
    local set = {}
    local col = getCollection()
    local owned, equipped = col and col.owned_units, col and col.equipped_units
    if owned and equipped then
        for _, uuid in pairs(equipped) do
            local u = owned[uuid] or owned[tostring(uuid)]
            if u and u.unit_id then
                set[baseName(u.unit_id)] = u
            end
        end
    end
    return set
end

local aeuatConnection
function aeuatFunction(enabled)
    if not enabled then
        if aeuatConnection then
            aeuatConnection:Disconnect()
            aeuatConnection = nil
        end
        return
    end
    if aeuatConnection or not queue_on_teleport then
        return
    end

    local queued = false
    aeuatConnection = player.OnTeleport:Connect(function(state)
        if queued or (state ~= Enum.TeleportState.Started and state ~= Enum.TeleportState.InProgress) then
            return
        end
        queued = true
        queue_on_teleport([[
            if not game:IsLoaded() then game.Loaded:Wait() end
            loadstring(game:HttpGet("https://raw.githubusercontent.com/bitxnzy/OneHubMainExec/main/mainexec.lua"))()
        ]])
        task.delay(1, function()
            queued = false
        end)
    end)
end

local reconnectConnection
local reconnecting = false
function autoReconnect(enabled)
    if not enabled then
        if reconnectConnection then
            reconnectConnection:Disconnect()
            reconnectConnection = nil
        end
        return
    end
    if reconnectConnection then
        return
    end

    reconnectConnection = GuiService.ErrorMessageChanged:Connect(function(message)
        if reconnecting or type(message) ~= "string" or message == "" then
            return
        end

        local text = string.lower(message)
        if string.find(text, "lost connection", 1, true) or string.find(text, "%f[%d]277%f[%D]") or
            string.find(text, "%f[%d]769%f[%D]") or string.find(text, "%f[%d]1025%f[%D]") then
            reconnecting = true
            warn("[One HUB] Connection lost, reconnecting in 10s...")
            task.wait(10)
            TeleportService:Teleport(LOBBY_PLACE_ID, player)
            task.delay(30, function()
                reconnecting = false
            end)
        end
    end)
end

autoWalk = makeLoop("autoWalk", function()
    return autoWalkEnabled
end, function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
    task.wait(1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
    task.wait(1)
end, 1)

securityMode = makeLoop("securityMode", function()
    return securityModeEnabled
end, function()
    if not selecteQuantityPlayer or game.PlaceId == LOBBY_PLACE_ID then
        return
    end
    if #Players:GetPlayers() >= (tonumber(selecteQuantityPlayer) or math.huge) then
        TeleportService:Teleport(LOBBY_PLACE_ID, player)
        task.wait(10)
    end
end, 1)

deletemap = makeLoop("deletemap", function()
    return deletemapEnabled
end, function()
    local map = workspace:FindFirstChild("_map")
    if map then
        for _, v in ipairs(map:GetChildren()) do
            if v.Name ~= "bottom" then
                v:Destroy()
            end
        end
    end
end, 2)

hideInfoPlayer = makeLoop("hideInfoPlayer", function()
    return hideInfoPlayerEnabled
end, function()
    local character = player.Character
    if character then
        local overhead = findPath(character, "Head", "_overhead", "Frame")
        if overhead then
            overhead.Visible = false
        end
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") then
                obj:Destroy()
            end
        end
    end

    local lives = findPath(PlayerGui, "spawn_units", "Lives")
    local frame = lives and lives:FindFirstChild("Frame")
    local units = frame and frame:FindFirstChild("Units")
    local resources = frame and frame:FindFirstChild("Resource")
    local limitBreak = frame and frame:FindFirstChild("LimitBreaks")
    local main = lives and lives:FindFirstChild("Main")

    if units then
        for _, v in ipairs(units:GetChildren()) do
            if v.Name ~= "UIListLayout" then
                local m = v:FindFirstChild("Main")
                if m then
                    for _, n in ipairs({"View", "Level", "EvolvedShine", "TraitIcons"}) do
                        local o = m:FindFirstChild(n)
                        if o then
                            o.Visible = false
                        end
                    end
                end
                local cost = findPath(v, "Cost", "text")
                if cost then
                    cost.Text = "99999"
                end
                local glow = v:FindFirstChild("EvolvedGlow")
                if glow then
                    glow.Visible = false
                end
                local border = v:FindFirstChild("Border")
                if border then
                    border.Enabled = false
                end
            end
        end
    end
    local boost = limitBreak and limitBreak:FindFirstChild("Boost")
    if boost then
        boost.Text = "99999"
    end
    if resources then
        for _, n in ipairs({"Gem", "Gold", "HolidayStars"}) do
            local level = findPath(resources, n, "Level")
            if level then
                level.Text = "99999"
            end
        end
    end
    if main then
        local desc, health = main:FindFirstChild("Desc"), main:FindFirstChild("Health")
        if desc then
            desc.Visible = false
        end
        if health then
            health.Visible = false
        end
    end
end, 1)

placeInRedZones = makeLoop("placeInRedZones", function()
    return placeInRedZonesEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    local set = equippedUnitsByName()
    if next(set) == nil then
        return
    end
    for _, unit in ipairs(units:GetChildren()) do
        if set[baseName(unit.Name)] then
            local hitbox = unit:FindFirstChild("_hitbox")
            if hitbox and hitbox.Size ~= Vector3.zero then
                hitbox.Size = Vector3.zero
            end
        end
    end
end, 1)

local function setInfoBillboards(visible)
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    for _, unit in ipairs(units:GetChildren()) do
        local gui = unit:FindFirstChild("OneHubInfo")
        if gui then
            gui.Enabled = visible
        end
    end
end

local startInfoUnits = makeLoop("showInfoUnits", function()
    return showInfoUnitsEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    local set = equippedUnitsByName()
    for _, unit in ipairs(units:GetChildren()) do
        local data = set[baseName(unit.Name)]
        if data then
            local gui = unit:FindFirstChild("OneHubInfo")
            if not gui then
                gui = Instance.new("BillboardGui")
                gui.Name = "OneHubInfo"
                gui.Adornee = unit
                gui.Size = UDim2.new(0, 250, 0, 75)
                gui.StudsOffset = Vector3.new(0, 2, 0)
                gui.AlwaysOnTop = false
                local label = Instance.new("TextLabel")
                label.Name = "Info"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.6
                label.TextSize = 18
                label.Text = "Total Kills: " .. (data.total_kills or 0) .. "\nWorthness: " .. (data.stat_luck or 0) .. "%"
                label.Parent = gui
                gui.Parent = unit
            end
            gui.Enabled = true
        end
    end
end, 2)

function showInfoUnits()
    if showInfoUnitsEnabled then
        startInfoUnits()
    else
        setInfoBillboards(false)
    end
end

local startNotifications = makeLoop("disableNotifications", function()
    return disableNotificationsEnabled
end, function()
    local a = PlayerGui:FindFirstChild("NotificationWindows")
    local b = PlayerGui:FindFirstChild("MessageGui")
    if a then
        a.Enabled = false
    end
    if b then
        b.Enabled = false
    end
end, 3)

function disableNotifications()
    if disableNotificationsEnabled then
        startNotifications()
    else
        local a = PlayerGui:FindFirstChild("NotificationWindows")
        local b = PlayerGui:FindFirstChild("MessageGui")
        if a then
            a.Enabled = true
        end
        if b then
            b.Enabled = true
        end
    end
end

function UpdatePriorityList(category, selectedList)
    selectedPriorities[category] = selList(selectedList)
end

local function firstCardIn(found, list)
    if #list == 0 then
        return nil
    end
    for pos = 1, #found do
        if selHas(list, found[pos]) then
            return pos
        end
    end
    return nil
end

autoChooseCard = makeLoop("autoChooseCard", function()
    return autoChooseCardEnabled
end, function()
    local items = findPath(PlayerGui, "RoguelikeSelect", "Main", "Main", "Items")
    if not items then
        return
    end
    local found = {}
    for _, frame in ipairs(items:GetChildren()) do
        if frame:IsA("Frame") then
            local label = findPath(frame, "bg", "Main", "Title", "TextLabel")
            if label then
                found[#found + 1] = label.Text
            end
        end
    end
    if #found == 0 then
        return
    end

    local buff, debuff = selectedPriorities.Buff, selectedPriorities.Debuff
    local pos
    if focusBuffEnabled then
        pos = firstCardIn(found, buff)
    end
    if not pos and focusDebuffEnabled then
        pos = firstCardIn(found, debuff)
    end
    pos = pos or firstCardIn(found, buff) or firstCardIn(found, debuff)
    if pos then
        invoke("select_roguelike_option", tostring(pos))
    end
end, 1)

autoGetQuest = makeLoop("autoGetQuest", function()
    return autoGetQuestEnabled
end, function()
    local content = findPath(PlayerGui, "QuestsUI", "Main", "Main", "Main", "Content")
    if not content then
        return
    end
    for _, cat in ipairs({"daily", "event", "infinite", "story"}) do
        local scroll = findPath(content, cat, "Scroll")
        if scroll then
            for _, child in ipairs(scroll:GetChildren()) do
                local n = child.Name
                if n ~= "UIListLayout" and n ~= "RefreshFrame" and n ~= "Empty" then
                    invoke("redeem_quest", n)
                end
            end
        end
    end
end, 3)

function autoGetBattlepass()
    if not autoGetBattlepassEnabled then
        return
    end
    task.spawn(function()
        while loadedallscript ~= true do
            task.wait(0.5)
        end
        invoke("claim_battlepass_rewards")
    end)
end

autoGivePresents = makeLoop("autoGivePresents", function()
    return autoGivePresentsEnabled
end, function()
    invoke("feed_easter_meter")
end, 1)

autostart = makeLoop("autostart", function()
    return autostartEnabled
end, function()
    local gui = PlayerGui:FindFirstChild("VoteStart")
    if gui and gui.Enabled == true then
        invoke("vote_start")
    end
end, 1)

autoskipwave = makeLoop("autoskipwave", function()
    return autoskipwaveEnabled
end, function()
    local gui = PlayerGui:FindFirstChild("VoteSkip")
    if gui and gui.Enabled == true then
        invoke("vote_wave_skip")
    end
end, 1)

autoreplay = makeLoop("autoreplay", function()
    return autoreplayEnabled
end, function()
    if resultsOpen() then
        invoke("set_game_finished_vote", "replay")
    end
end, 1)

autoleave = makeLoop("autoleave", function()
    return autoleaveEnabled
end, function()
    if resultsOpen() then
        invoke("teleport_back_to_lobby", "leave")
    end
end, 1)

autonext = makeLoop("autonext", function()
    return autonextEnabled
end, function()
    if resultsOpen() then
        invoke("set_game_finished_vote", "next_story")
    end
end, 1)

autoLeaveInXWave = makeLoop("autoLeaveInXWave", function()
    return autoLeaveInXWaveEnabled
end, function()
    local need = tonumber(selectedWaveToLeave)
    if need and currentWave() == need then
        invoke("teleport_back_to_lobby", "leave")
    end
end, 1)

local function joinLobbyAndStart(lobby, levelName, friendsOnly, difficulty)
    invoke("request_join_lobby", lobby)
    task.wait(1)
    invoke("request_lock_level", lobby, levelName, friendsOnly, difficulty)
    task.wait(1)
    invoke("request_start_game", lobby)
    return true
end

function joinPlayerLobby()
    local names = selList(selectedPlayerToJoin)
    if #names == 0 then
        return false
    end
    local roots = {findPath(workspace, "_LOBBIES", "Story"), findPath(workspace, "_RAID", "Raid"),
                   findPath(workspace, "_DUNGEONS", "Lobbies"), findPath(workspace, "_CHALLENGES", "Challenges"),
                   findPath(workspace, "_CHALLENGES", "DailyChallenge"),
                   findPath(workspace, "_EVENT_CHALLENGES", "Lobbies")}
    for i = 1, 6 do
        local root = roots[i]
        if root then
            for _, lobby in ipairs(root:GetChildren()) do
                local owner = lobby:FindFirstChild("Owner")
                if owner and owner.Value and selHas(names, owner.Value.Name) then
                    invoke("request_join_lobby", lobby)
                    return true
                end
            end
        end
    end
    return false
end

autoJoinPlayer = makeLoop("autoJoinPlayer", function()
    return autoJoinPlayerEnabled
end, joinPlayerLobby, 1, true)

local function invokeWorldSkipForMap(worldName, force)
    if not force and not worldSkipEnabled then
        return false
    end
    if type(worldName) ~= "string" or worldName == "" or worldName == "None" then
        warn("[One HUB] World Skip: mapa de destino inválido.")
        return false
    end
    local ok, result = pcall(invoke, "lobby_world_skip", worldName)
    return ok and result ~= false
end

local function invokeWorldSkipForSelectedStory()
    return invokeWorldSkipForMap(selectedMap, false)
end

local levelOrderModule
function getNextStoryActAuto()
    if levelOrderModule == nil then
        local m = findPath(RS, "src", "Data", "WorldLevelOrder")
        levelOrderModule = m and require(m) or false
    end
    if not levelOrderModule or not levelOrderModule.LEVEL_ORDER then
        return "namek", "1"
    end

    local profile = getProfile()
    local completed = profile and profile.level_data and profile.level_data.completed_story_levels or {}
    for _, levelId in ipairs(levelOrderModule.LEVEL_ORDER) do
        if not completed[levelId] then
            local map, act = levelId:match("^(.-)_level_(%d+)$")
            if map and act then
                return map, act
            end
            break
        end
    end
    return "namek", "6"
end

local function invokeWorldSkipForSelectedStoryAuto()
    local targetMap = getNextStoryActAuto()
    return invokeWorldSkipForMap(targetMap, false)
end

autoJoinLastStoryFunction = makeLoop("autoJoinLastStory", function()
    return autoJoinLastStoryEnabled
end, function()
    local targetMap, targetAct = getNextStoryActAuto()
    local lobby = "_lobbytemplategreen1"
    invoke("request_join_lobby", lobby)
    task.wait(1)
    if worldSkipEnabled then
        invokeWorldSkipForMap(targetMap, true)
    end
    task.wait(0.5)
    local diff = (selectedDifficulty ~= nil and selectedDifficulty ~= "None") and selectedDifficulty or "Normal"
    invoke("request_lock_level", lobby, targetMap .. "_level_" .. tostring(targetAct), false, diff)
    task.wait(1)
    invoke("request_start_game", lobby)
end, 3, true)

function tryJoinStory()
    if type(selectedMap) ~= "string" or selectedMap == "" or selectedMap == "None" or not selectedDifficulty or
        selectedDifficulty == "None" or not selectedAct or selectedAct == "None" then
        return false
    end
    local lobby = "_lobbytemplategreen1"
    invoke("request_join_lobby", lobby)
    task.wait(1)
    invokeWorldSkipForSelectedStory()
    task.wait(0.5)
    local level, friends
    if selectedAct == "Infinite" then
        level, friends = selectedMap .. "_infinite", selectedFriendsOnly
    else
        level, friends = selectedMap .. "_level_" .. selectedAct, false
    end
    invoke("request_lock_level", lobby, level, friends, selectedDifficulty)
    task.wait(1)
    invoke("request_start_game", lobby)
    return true
end

autoEnter = makeLoop("autoEnter", function()
    return autoEnterEnabled
end, tryJoinStory, 1, true)

autoEnterChallenge = makeLoop("autoEnterChallenge", function()
    return autoEnterChallengeEnabled
end, function()
    local lobby = findPath(workspace, "_CHALLENGES", "Challenges", "_lobbytemplate315")
    local level = lobby and lobby:FindFirstChild("Level")
    local challenge = lobby and lobby:FindFirstChild("Challenge")
    if level and challenge and selHas(selList(selectedMapChallenges), level.Value) and
        selHas(selList(selectedChallengesDiff), challenge.Value) then
        invoke("request_join_lobby", "_lobbytemplate315")
    end
end, 1, true)

autoEnterDailyChallenge = makeLoop("autoEnterDailyChallenge", function()
    return autoEnterDailyChallengeEnabled
end, function()
    invoke("request_join_lobby", "_lobbytemplate320")
end, 1, true)

autoMatchmakingDailyChallenge = makeLoop("autoMatchmakingDailyChallenge", function()
    return autoMatchmakingDailyChallengeEnabled
end, function()
    invoke("request_matchmaking", "__DAILY_CHALLENGE")
end, 1, true)

autoEnterInfiniteCastle = makeLoop("autoEnterInfiniteCastle", function()
    return autoEnterInfiniteCastleEnabled
end, function()
    local profile = getProfile()
    local tower = profile and profile.level_data and profile.level_data.infinite_tower
    local floor = (tower and tower.floor_reached) or 1
    invoke("request_start_infinite_tower", floor, selectedHardInfCastleEnabled and "Hard" or "Normal")
end, 1, true)

autoEnterRaid = makeLoop("autoEnterRaid", function()
    return autoEnterRaidEnabled
end, function()
    if selectedRaidMap and selectedRaidMap ~= "None" then
        joinLobbyAndStart("_lobbytemplate210", selectedRaidMap, selectedFriendsOnly == true, "Hard")
    end
end, 1, true)

autoEnterLegendStage = makeLoop("autoEnterLegendStage", function()
    return autoEnterLegendStageEnabled
end, function()
    if selectedLegendStageMap and selectedLegendStageMap ~= "None" then
        joinLobbyAndStart("_lobbytemplategreen1", selectedLegendStageMap, selectedFriendsOnly == true, "Hard")
    end
end, 1, true)

AutoMatchmaking = makeLoop("AutoMatchmaking", function()
    return AutoMatchmakingEnabled
end, function()
    if selectedMatchmakingMap and selectedMatchmakingMap ~= "None" then
        invoke("request_matchmaking", selectedMatchmakingMap)
    end
end, 1, true)

function autoJoinCursedWomb()
    if not autoJoinCursedWombEnabled or PriorityJoinActive then
        return
    end
    task.spawn(function()
        while loadedallscript ~= true do
            task.wait(0.5)
        end
        invoke("save_notifications_state", "Items", 0)
        task.wait(1)
        invoke("request_join_lobby", "_lobbytemplate_event222", {
            selected_key = "key_jjk_finger"
        })
    end)
end

local function findPortalUuid()
    if not selectedPortalMap or selectedPortalMap == "None" then
        return nil
    end
    local inv = getInventory()
    local items = inv and inv.unique_items
    if type(items) ~= "table" then
        return nil
    end
    local tiers = selList(selectedTierPortal)
    local ignoreDmg = selList(selectedIgnoreDmgBonus)
    local ignoreChallenge = selList(selectedPortalDiff)
    for _, item in pairs(items) do
        local data = item.uuid and item._unique_item_data
        local portal = data and data._unique_portal_data
        if portal and portal.level_id and portal.portal_depth and tostring(portal.level_id) == tostring(selectedPortalMap) then
            local tierOk = #tiers == 0 or selHas(tiers, portal.portal_depth)
            local weak = portal._weak_against and portal._weak_against[1]
            local dmgType = weak and weak.damage_type
            local dmgOk = not (dmgType and selHas(ignoreDmg, dmgType))
            local chalOk = not (portal.challenge and selHas(ignoreChallenge, portal.challenge))
            if tierOk and dmgOk and chalOk then
                return tostring(item.uuid)
            end
        end
    end
    return nil
end

autoEnterPortal = makeLoop("autoEnterPortal", function()
    return autoEnterPortalEnabled
end, function()
    local uuid = findPortalUuid()
    if uuid then
        invoke("save_notifications_state", "Items", 0)
        invoke("use_portal", uuid, selectedFriendsOnly and {
            friends_only = true
        } or nil)
    end
end, 1, true)

autoNextPortal = makeLoop("autoNextPortal", function()
    return autoNextPortalEnabled
end, function()
    if not resultsOpen() then
        return
    end
    local uuid = findPortalUuid()
    if uuid then
        invoke("save_notifications_state", "Items", 0)
        invoke("set_game_finished_vote", "replay", {
            item_uuid = uuid
        })
    end
end, 1)

local function findContractSlot()
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage")
            .endpoints.client_to_server.get_current_event_contracts:InvokeServer()
    end)

    if not success or not result or type(result) ~= "table" then
        return nil
    end

    local tiers = selList(selectedTierContract)
    local ignored = selList(selectedIgnoreContractChallenge)
    if #tiers == 0 then
        return nil
    end

    local function hasItem(tbl, val)
        if type(tbl) ~= "table" then return false end
        for _, v in ipairs(tbl) do
            if v == val then return true end
        end
        return false
    end

    local slots = {}
    for slot, data in pairs(result) do
        if type(data) == "table" then
            table.insert(slots, slot)
        end
    end
    
    if #slots == 0 then
        return nil
    end

    table.sort(slots, function(a, b) return tonumber(a) < tonumber(b) end)

    for _, slotKey in ipairs(slots) do
        local data = result[slotKey]
        if type(data) == "table" then
            local difficulty = data._portal_depth or ""
            local diffText = tostring(difficulty):match("%d+") or tostring(difficulty):lower()
            
            local chalText = ""
            if data._challengename then
                chalText = data._challengename:lower():gsub(" ", "_")
            elseif data._challenge then
                chalText = tostring(data._challenge):lower():gsub(" ", "_")
            end

            local matchTier = hasItem(tiers, diffText) or hasItem(tiers, tostring(difficulty):lower())
            local matchIgnore = hasItem(ignored, chalText)

            if matchTier and not matchIgnore then
                return data._event_contract and data._event_contract.slot or tonumber(slotKey)
            end
        end
    end

    return nil
end

autoContractMatchmaking = makeLoop("autoContractMatchmaking", function()
    return autoContractMatchmakingEnabled
end, function()
    local idx = findContractSlot()
    if idx then
        invoke("request_matchmaking", "__EVENT_CONTRACT_Sakamoto:" .. tostring(idx))
    end
end, 1, true)

autoContract = makeLoop("autoContract", function()
    return autoContractEnabled
end, function()
    local idx = findContractSlot()
    if idx then
        if selectedFriendsOnly == true then
            invoke("open_event_contract_portal", tostring(idx), {
                friends_only = true
            })
        else
            invoke("open_event_contract_portal", tostring(idx))
        end
    end
end, 1, true)

autoNextContrato = makeLoop("autoNextContrato", function()
    return autoNextContratoEnabled
end, function()
    if not resultsOpen() then
        return
    end
    local idx = findContractSlot()
    if idx then
        invoke("set_game_finished_vote", "eventcontract", {
            _eventcontractslot = tostring(idx)
        })
    end
end, 1)

local function pickTeam(levelData)
    local kinds = {}
    for _, v in pairs(levelData) do
        if type(v) == "string" then
            kinds[v] = true
            if v:match("^__EVENT_CONTRACT_Sakamoto:%d$") then
                kinds.contract = true
            end
        end
    end

    local weak = levelData._daily_challenge_weak_against
    local function weakHas(t)
        if type(weak) == "table" then
            for _, v in pairs(weak) do
                if v == t then
                    return true
                end
            end
        end
        return false
    end

    if kinds.contract then
        return weakHas("physical") and selectedTeamPhysicContract or selectedTeamMagicContract
    elseif kinds.challenge then
        if weakHas("physical") then
            return selectedTeamPhysicChallengeDailyChallenge
        elseif weakHas("magic") then
            return selectedTeamMagicChallengeDailyChallenge
        end
        return selectedTeamChallengeDailyChallenge
    elseif kinds.infinite_tower then
        return selectedTeamInfTower
    elseif kinds.portal then
        return selectedTeamPortal
    elseif kinds.dungeon then
        return selectedTeamDungeon
    elseif kinds.legendstage then
        return selectedTeamlegend
    elseif kinds.raid then
        return selectedTeamRaid
    elseif kinds.infinite or kinds.story then
        return selectedTeamStoryInf
    end
    return nil
end

local lastTeam, lastTeamAt = nil, 0
autoEquipTeam = makeLoop("autoEquipTeam", function()
    return autoEquipTeamEnabled
end, function()
    local remote = findPath(workspace, "_MAP_CONFIG", "GetLevelData")
    local levelData = remote and remote:InvokeServer()
    if type(levelData) ~= "table" then
        return
    end
    local team = pickTeam(levelData)
    if team and (team ~= lastTeam or os.clock() - lastTeamAt > 30) then
        invoke("load_team_loadout", team)
        lastTeam, lastTeamAt = team, os.clock()
    end
end, 1)

local function checkRRS()
    local Loader = require(RS.src.Loader)
    local up = debug.getupvalues(Loader.init)
    local stats = up[11]["StatsServiceClient"]
    return stats.module.session.profile_data.total_trait_rerolls
end

autoRollPassive = makeLoop("autoRollPassive", function()
    return autoRollPassiveEnabled
end, function()
    if not selectedUnitToRoll then
        return
    end
    if checkRRS() < 1 then
        return
    end
    local col = getCollection()
    local unit = col and col.owned_units and col.owned_units[selectedUnitToRoll]
    local trait = unit and type(unit.traits) == "table" and unit.traits[1]
    if type(trait) == "table" and trait.trait and trait.tier then
        if selHas(selList(selectedPassiveToRoll), trait.trait .. " " .. trait.tier) then
            return
        end
        invoke("request_token_trait_reroll", tostring(selectedUnitToRoll))
    end
end, 1)

autoFeed = makeLoop("autoFeed", function()
    return autoFeedEnabled
end, function()
    if not selectedUnitToFeed then
        return
    end
    local items = {}
    for _, name in ipairs(selList(selectedFeed)) do
        items[name] = 1
    end
    if next(items) == nil then
        return
    end
    invoke("level_up_feed", selectedUnitToFeed, items)
    invoke("save_notifications_state", "Inventory", 0)
end, 1)

autoBuy = makeLoop("autoBuy", function()
    return autoBuyEnabled
end, function()
    if selectedItemToBuy then
        invoke("buy_travelling_merchant_item", selectedItemToBuy, "1")
        invoke("save_notifications_state", "Items", 1)
    end
end, 1)

autoOpenCapsule = makeLoop("autoOpenCapsule", function()
    return autoOpenCapsuleEnabled
end, function()
    if selectedCapsule then
        invoke("use_item", selectedCapsule, {
            use10 = false
        })
    end
end, 1)

autoCraftShard = makeLoop("autoCraftShard", function()
    return autoCraftShardEnabled
end, function()
    if selectedShardtoCraft then
        invoke("use_item", selectedShardtoCraft, {
            use10 = false
        })
    end
end, 1)

autoRollSakamotoBanner = makeLoop("autoRollSakamotoBanner", function()
    return autoRollSakamotoBannerEnabled
end, function()
    invoke("buy_from_banner", "SakamotoEvent", "gems10")
end, 1)

autoSell = makeLoop("autoSell", function()
    return autoSellEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    local need = tonumber(selectedWaveToSell)
    if need and currentWave() < need then
        return
    end
    for _, unit in ipairs(units:GetChildren()) do
        local uuid = findPath(unit, "_stats", "uuid")
        if uuid and uuid.Value ~= "neutral" then
            invoke("sell_unit_ingame", unit)
        end
    end
end, 1)

autoSellFarmWaveX = makeLoop("autoSellFarmWaveX", function()
    return autoSellFarmWaveXEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    local need = tonumber(onlysellFarminXwave)
    if not units or not need or currentWave() ~= need then
        return
    end
    for _, unit in ipairs(units:GetChildren()) do
        if (unit.Name == "speedwagon" or unit.Name == "bulma") and ownedByPlayer(unit) then
            invoke("sell_unit_ingame", unit)
        end
    end
end, 1)

local abilitySet
local function getAbilitySet()
    if abilitySet then
        return abilitySet
    end
    local ok, data = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/main/AA/UnitsAbility.luau", true))()
    end)
    if not ok or type(data) ~= "table" then
        warn("[One HUB] Universal Skill: não foi possível carregar a lista de unidades.")
        return nil
    end
    abilitySet = {}
    for _, name in pairs(data) do
        abilitySet[baseName(tostring(name))] = true
    end
    return abilitySet
end

universalSkill = makeLoop("universalSkill", function()
    return universalSkillEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    if universalSkillinXWaveEnabled then
        local need = tonumber(selectedWaveToUniversalSkill)
        if need and currentWave() < need then
            return
        end
    end
    local set = getAbilitySet()
    if not set then
        task.wait(10)
        return
    end
    for _, unit in ipairs(units:GetChildren()) do
        if set[baseName(unit.Name)] and ownedByPlayer(unit) then
            invoke("use_active_attack", unit)
        end
    end
end, 1)

local function activeAttackByName(names)
    local alive = workspace:FindFirstChild("_UNITS")
    local dead = RS:FindFirstChild("_DEAD_UNITS")
    for _, name in ipairs(names) do
        local a = alive and alive:FindFirstChild(name)
        if a then
            invoke("use_active_attack", a)
        end
        local d = dead and dead:FindFirstChild(name)
        if d then
            invoke("use_active_attack", d)
        end
    end
end

dupeVegeto = makeLoop("dupeVegeto", function()
    return dupeVegetoEnabled
end, function()
    activeAttackByName({"goku_ssj3", "vegeta_majin"})
end, 1)

dupeGriffith = makeLoop("dupeGriffith", function()
    return dupeGriffithEnabled
end, function()
    activeAttackByName({"femto_egg"})
end, 1)

local function squadActive(names, isOn)
    local units = workspace:FindFirstChild("_UNITS")
    if not units then
        return
    end
    local squad = {}
    for _, u in ipairs(units:GetChildren()) do
        if names[u.Name] and ownedByPlayer(u) then
            squad[#squad + 1] = u
        end
    end
    if #squad == 4 then
        for _, u in ipairs(squad) do
            if not isOn() then
                break
            end
            invoke("use_active_attack", u)
            task.wait(1)
        end
    end
end

UseActiveAttackE = makeLoop("buffErwin", function()
    return toggle
end, function()
    squadActive({erwin = true}, function()
        return toggle
    end)
end, 1)

UseActiveAttackW = makeLoop("buffWendy", function()
    return toggle2
end, function()
    squadActive({wendy = true, wendy_halloween = true}, function()
        return toggle2
    end)
end, 1)

UseActiveAttackL = makeLoop("buffLeafy", function()
    return toggle3
end, function()
    squadActive({leafy = true}, function()
        return toggle3
    end)
end, 1)

local sacrificeUnits = {orwin = true, wendy = true, elf = true}
autoSacrificeGriffith = makeLoop("autoSacrificeGriffith", function()
    return autoSacrificeGriffithEnabled
end, function()
    local units = workspace:FindFirstChild("_UNITS")
    local egg = units and units:FindFirstChild("femto_egg")
    local root = egg and egg:FindFirstChild("HumanoidRootPart")
    if not root or workspace:FindFirstChild("griffith_reincarnation") then
        return
    end

    local col = getCollection()
    local owned, equipped = col and col.owned_units, col and col.equipped_units
    if not owned or not equipped then
        return
    end

    local wendyCount, allUpgraded = 0, true
    for _, u in ipairs(units:GetChildren()) do
        if u.Name == "wendy" or u.Name == "wendy_halloween" then
            wendyCount = wendyCount + 1
            local upgrade = findPath(u, "_stats", "upgrade")
            if upgrade and upgrade.Value < 6 then
                allUpgraded = false
            end
        end
    end
    if wendyCount == 6 then
        if allUpgraded then
            invoke("use_active_attack", egg)
        end
        return
    end

    for _, uuid in pairs(equipped) do
        local data = owned[uuid] or owned[tostring(uuid)]
        if data and sacrificeUnits[data.unit_id] then
            local angle, dist = math.random() * 2 * math.pi, math.random() * 10
            local pos = root.Position + Vector3.new(math.cos(angle) * dist, -1, math.sin(angle) * dist + 1)
            invoke("spawn_unit", uuid, CFrame.new(pos))
        end
    end
end, 1)

local function formatNumber(num)
    num = tonumber(num) or 0
    if num >= 1000 then
        local formatted = num / 1000
        if formatted % 1 == 0 then
            return formatted .. "k"
        end
        return string.format("%.1fk", formatted)
    end
    return tostring(num)
end

local function pingText()
    if pingUser and pingUserId then
        return "<@" .. pingUserId .. ">"
    elseif pingUser then
        return "@"
    end
    return ""
end

local function postWebhook(payload)
    if not httpRequest then
        warn("[WEBHOOK] No supported HTTP request function found")
        return false
    end
    local ok, response = pcall(httpRequest, {
        Url = urlwebhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(payload)
    })
    if not ok then
        warn("[WEBHOOK] request failed: " .. tostring(response))
        return false
    end
    return response.Success == true or response.StatusCode == 204
end

local function buildReport()
    local resultsGui = PlayerGui:FindFirstChild("ResultsUI")
    local holder = resultsGui and resultsGui:FindFirstChild("Holder")
    if not holder then
        return nil
    end

    local levelLabel = findPath(PlayerGui, "spawn_units", "Lives", "Main", "Desc", "Level")
    local levelText = (levelLabel and levelLabel.Text or "Level: unknown"):sub(7)

    local profile = getProfile()
    local inventory = getInventory()
    local normalItems = inventory and inventory.normal_items or {}
    local gems = profile and profile.gem_amount or 0
    local gold = profile and profile.gold_amount or 0
    local holiday = findPath(player, "_stats", "_resourceHolidayStars")
    holiday = holiday and holiday.Value or 0
    local sakamotoCoin = normalItems.sakamoto_coin or 0

    local rewards = {}
    local scrolling = findPath(holder, "LevelRewards", "ScrollingFrame")
    if scrolling then
        for _, frame in ipairs(scrolling:GetChildren()) do
            local n = frame.Name
            if (n == "GemReward" or n == "GoldReward" or n == "TrophyReward" or n == "XPReward") and frame.Visible then
                local amount = findPath(frame, "Main", "Amount")
                if amount then
                    local total = normalItems[n:gsub("Reward", ""):lower()]
                    rewards[#rewards + 1] = total and (amount.Text .. "[" .. total .. "]\n") or (amount.Text .. " " .. n .. "\n")
                end
            end
        end
    end

    local unitInfo = {}
    local col = getCollection()
    if col and col.owned_units and col.unit_ingame_levels then
        for _, unit in pairs(col.owned_units) do
            if type(unit) == "table" and col.unit_ingame_levels[unit.unit_id] then
                local kills, luck = unit.total_kills, unit.stat_luck
                if luck == nil then
                    kills, luck = 0, 0
                end
                unitInfo[#unitInfo + 1] = unit.unit_id .. " = " .. formatNumber(kills) .. ":crossed_swords: [" ..
                                              formatNumber(luck) .. "% W]\n"
            end
        end
    end

    local result = holder.Title.Text
    local timeParts = string.split(holder.Middle.Timer.Text, ":")
    local totalSeconds = 0
    if #timeParts == 3 then
        totalSeconds = (tonumber(timeParts[1]) or 0) * 3600 + (tonumber(timeParts[2]) or 0) * 60 + (tonumber(timeParts[3]) or 0)
    elseif #timeParts == 2 then
        totalSeconds = (tonumber(timeParts[1]) or 0) * 60 + (tonumber(timeParts[2]) or 0)
    elseif #timeParts == 1 then
        totalSeconds = tonumber(timeParts[1]) or 0
    end
    local formattedTime = string.format("%02d:%02d:%02d", math.floor(totalSeconds / 3600),
        math.floor((totalSeconds % 3600) / 60), math.floor(totalSeconds % 60))

    local mapConfig = ""
    local levelRemote = findPath(workspace, "_MAP_CONFIG", "GetLevelData")
    local levelData = levelRemote and levelRemote:InvokeServer()
    if type(levelData) == "table" and levelData._difficulty and levelData.name and levelData._location_name then
        mapConfig = formattedTime .. " - " .. result .. "\n" .. levelData._location_name .. " - " .. levelData.name ..
                        " [" .. levelData._difficulty .. "] "
    end

    local cardsEffect = {}
    local info = PlayerGui:FindFirstChild("GameLevelInfo")
    local list = info and info.Enabled and info:FindFirstChild("List_rg")
    local buffs = list and list.Visible and list:FindFirstChild("Buffs")
    if buffs then
        for _, v in ipairs(buffs:GetChildren()) do
            if v:IsA("TextLabel") then
                cardsEffect[#cardsEffect + 1] = v.Text
            end
        end
    end
    if #cardsEffect == 0 then
        cardsEffect = {"No card"}
    end

    local color = 7995647
    if result == "DEFEAT" then
        color = 16711680
    elseif result == "VICTORY" then
        color = 65280
    end

    return {
        content = pingText(),
        embeds = {{
            description = "User: ||" .. player.Name .. "||\nLevel: " .. levelText .. " || [1111/1123] ||",
            color = color,
            fields = {{
                name = "Player Stats",
                value = string.format(
                    "<:gemsAA:1322365177320177705> %s\n <:goldAA:1322369598015668315> %s\n<:holidayEventAA:1322369599517491241> %s\n<:sakamotoCoin:1335489173057962075> %s\n",
                    gems, gold, holiday, sakamotoCoin),
                inline = true
            }, {
                name = "Rewards",
                value = table.concat(rewards, "\n"),
                inline = true
            }, {
                name = "Units",
                value = table.concat(unitInfo)
            }, {
                name = "Card Effects",
                value = table.concat(cardsEffect, "\n")
            }, {
                name = "Match Result",
                value = mapConfig
            }},
            author = {
                name = "Anime Adventures"
            },
            footer = {
                text = "https://discord.gg/DX5afFApmC - One Hub"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            thumbnail = {
                url = "https://cdn.discordapp.com/attachments/1332473174352330755/1563400864927060038/100199291949935_1.png?ex=6add7e04&is=6adc2c84&hm=ff2b7d46466332efb06c5462d0586b5217e18a151626fd66f08832cf9ea75b6d&"
            }
        }},
        attachments = {}
    }
end

local webhookSent = false
local webhookWarned = false
webhook = makeLoop("webhook", function()
    return webhookEnabled
end, function()
    local a, b = PlayerGui:FindFirstChild("ResultsUI"), PlayerGui:FindFirstChild("Results")
    local function active(gui)
        if not gui then
            return false
        elseif gui:IsA("ScreenGui") then
            return gui.Enabled
        elseif gui:IsA("GuiObject") then
            return gui.Visible
        end
        return false
    end
    if not (active(a) or active(b)) then
        webhookSent, webhookWarned = false, false
        return
    end
    if webhookSent then
        return
    end
    if not urlwebhook or urlwebhook == "" then
        if not webhookWarned then
            webhookWarned = true
            warn("[WEBHOOK] URL is empty; set the Discord webhook URL in settings")
        end
        return
    end
    local report = buildReport()
    if report and postWebhook(report) then
        webhookSent = true
    end
end, 1)

function testWebhook()
    if not urlwebhook or urlwebhook == "" then
        warn("[WEBHOOK] URL is empty")
        return
    end
    postWebhook({
        content = pingText(),
        embeds = {{
            description = "Test Webhook LMAO\n\n```REWARDS:\n+AIZEN (999)\n```",
            color = 8716543,
            author = {
                name = "Anime Adventures"
            }
        }},
        attachments = {}
    })
end

function safeGetChildren(parent, name)
    local object = parent:FindFirstChild(name)
    return object and object:GetChildren() or {}
end


function printChallenges(module)
    local challengesKeys = {}
    if module.challenges then
        for key, value in pairs(module.challenges) do
            table.insert(challengesKeys, key)
        end
    end
    return challengesKeys
end

local module = require(game:GetService("ReplicatedStorage").src.Data.ChallengeAndRewards)
local challengeValues = printChallenges(module)

local Module2 = require(game:GetService("ReplicatedStorage").src.Data.Maps)
function getStoryMapValues(module)
    local seen = {}
    local values = {}

    for key, value in pairs(module) do
        local firstPart = key:match("([^_]+)")
        if not seen[firstPart] then
            seen[firstPart] = true
            table.insert(values, firstPart)
        end
    end

    return values
end

local storyMapValues = getStoryMapValues(Module2)

local portals = game:GetService("ReplicatedStorage").LOBBY_ASSETS:FindFirstChild("_portal_templates")
local ValuesPortalsMaps = {}
if portals then
    for i, v in pairs(portals:GetChildren()) do
        local nameWithoutUnderscore = string.sub(v.Name, 2)
        table.insert(ValuesPortalsMaps, nameWithoutUnderscore)
    end
end

levelsModule = require(game:GetService("ReplicatedStorage").src.Data.Levels)
local ChallengeMapValues = {}
if type(levelsModule) == "table" then
    for levelName, levelData in pairs(levelsModule) do
        if levelData.id then
            table.insert(ChallengeMapValues, tostring(levelData.id))
        end
    end
end

local PortalMapValues = {}
if type(levelsModule) == "table" then
    for levelName, levelData in pairs(levelsModule) do
        if levelData.id and string.find(levelName:lower(), "portal") then
            table.insert(PortalMapValues, tostring(levelData.id))
        end
    end
end

local capsules = game:GetService("ReplicatedStorage").packages.assets:FindFirstChild("ItemModels")
local ValuesCapsules = {}
if capsules then
    for i, v in pairs(capsules:GetChildren()) do
        if string.find(v.Name:lower(), "capsule") then
            table.insert(ValuesCapsules, v.Name)
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopItemsModule = ReplicatedStorage.src.Data:FindFirstChild("ShopItems")
local ValuesItemShop = {}
if ShopItemsModule then
    local ShopItems = require(ShopItemsModule)
    for key, value in pairs(ShopItems) do
        if not string.find(key, "bundle") and not string.find(key, "gift") then
            table.insert(ValuesItemShop, key)
        end
    end
else
    warn("ShopItems module not found.")
end

local itemModels = safeGetChildren(game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("assets"),
    "ItemModels")
local ValuesItemsToFeed = {}
for i, v in pairs(itemModels) do
    table.insert(ValuesItemsToFeed, v.Name)
end

local fxCache = game:GetService("ReplicatedStorage"):FindFirstChild("_FX_CACHE")
local ValuesUnitId = {}
if fxCache then
    for _, v in pairs(fxCache:GetChildren()) do
        if v.Name == "CollectionUnitFrame" then
            local collectionUnitFrame = v
            table.insert(ValuesUnitId,
                collectionUnitFrame.name.Text .. " | Level: " .. collectionUnitFrame.Main.Level.Text .. " | " ..
                    collectionUnitFrame._uuid.Value)
        end
    end
end

local namePortal = safeGetChildren(game:GetService("ReplicatedStorage").packages.assets, "ItemModels")
local ValuesPortalName = {}
for i, v in pairs(namePortal) do
    if string.find(v.Name:lower(), "portal") then
        table.insert(ValuesPortalName, v.Name)
    end
end

local ValuesPlayersName = {}
for _, v in ipairs(Players:GetPlayers()) do
    if v ~= player then
        table.insert(ValuesPlayersName, v.Name)
    end
end

do
    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    local player = Players.LocalPlayer
    local ROOT = "One Hub"
    local GAME_DIR = ROOT .. "/_AA_"
    local MACRO_DIR = GAME_DIR .. "/Macros"
    local MAP_FILE = GAME_DIR .. "/MacroMap.json"

    for _, dir in ipairs({ROOT, GAME_DIR, MACRO_DIR}) do
        if not isfolder(dir) then
            makefolder(dir)
        end
    end

    local RECORDED = {
        spawn_unit = true,
        upgrade_unit_ingame = true,
        sell_unit_ingame = true,
        use_active_attack = true,
        vote_wave_skip = true,
        vote_start = true
    }

    local MODES = {
        story = true,
        infinite = true,
        raid = true,
        infinite_tower = true,
        challenge = true
    }
    local MODE_LIST = {"Story", "Infinite", "Legend Stage", "Raid", "Challenge", "Infinite Tower", "Contract"}

    local endpoints = RS:WaitForChild("endpoints"):WaitForChild("client_to_server")
    local alive = true
    local isRecording, isPlaying = false, false
    local recSteps, recIndex, recStart = {}, 0, 0
    local instSlot = setmetatable({}, {
        __mode = "k"
    })

    local recordTarget = "None"
    local assignMode = "Story"
    local macroName = ""
    local macroMode = "Hybrid"
    local recMode = "Hybrid"
    local stepDelay = 0.2
    local autoRun = false

    local panel = {
        status = "Idle",
        current = "-",
        need = "-",
        nextStep = "-",
        detected = "Not in a match"
    }
    local ui = {}
    local function baseName(n)
        return n:match("^(.-)_evolved$") or n:match("^(.-)_christmas$") or n:match("^(.-)_halloween$") or n
    end

    local function fmtTime(s)
        return string.format("%.1fs", math.max(s, 0))
    end

    local function curWave()
        local w = workspace:FindFirstChild("_wave_num")
        return w and tonumber(w.Value) or 0
    end

    local function readJson(path)
        if not isfile(path) then
            return nil
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        return ok and data or nil
    end

    local function parseAmount(txt)
        if type(txt) ~= "string" then
            return nil
        end
        local clean = (txt:gsub(",", ""))
        local num, suf = clean:match("([%d%.]+)%s*([KkMmBb]?)")
        num = tonumber(num)
        if not num then
            return nil
        end
        return num * (({
            k = 1e3,
            m = 1e6,
            b = 1e9
        })[(suf or ""):lower()] or 1)
    end

    local function getMoney()
        local localPlayer = Players.LocalPlayer
        local gui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
        local spawnUnits = gui and gui:FindFirstChild("spawn_units")
        local lives = spawnUnits and spawnUnits:FindFirstChild("Lives")
        local frame = lives and lives:FindFirstChild("Frame")
        local resource = frame and frame:FindFirstChild("Resource")
        local money = resource and resource:FindFirstChild("Money")

        if money then
            local candidates = {money}
            for _, descendant in ipairs(money:GetDescendants()) do
                candidates[#candidates + 1] = descendant
            end
            for _, obj in ipairs(candidates) do
                if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                    local amount = parseAmount(obj.Text)
                    if amount ~= nil then
                        return amount
                    end
                end
            end
        end

        local stats = localPlayer and localPlayer:FindFirstChild("_stats")
        local gold = stats and (stats:FindFirstChild("gold_amount") or stats:FindFirstChild("money") or stats:FindFirstChild("Money"))
        if gold and (gold:IsA("IntValue") or gold:IsA("NumberValue") or gold:IsA("StringValue")) then
            return tonumber(gold.Value) or parseAmount(tostring(gold.Value))
        end
        return nil
    end

    local function unitIdOf(uuid)
        local col = getCollection()
        local u = col and col.owned_units and col.owned_units[uuid]
        return u and u.unit_id or nil
    end

    local function resolveUuid(recUuid, unitId)
        local col = getCollection()
        if not col then
            return recUuid
        end
        local equipped = col.equipped_units or {}
        for _, id in pairs(equipped) do
            if tostring(id) == tostring(recUuid) then
                return recUuid
            end
        end
        if unitId then
            for _, id in pairs(equipped) do
                local u = col.owned_units[id]
                if u and u.unit_id == unitId then
                    return id
                end
            end
        end
        return recUuid
    end

    local function slotOfUuid(uuid)
        local col = getCollection()
        local equipped = col and col.equipped_units
        if not equipped then
            return nil
        end
        local counter = 0
        for k, id in pairs(equipped) do
            counter = counter + 1
            if tostring(id) == tostring(uuid) then
                return tonumber(k) or counter
            end
        end
    end

    local function getSlotCost(slot)
        local cost = findPath(PlayerGui, "spawn_units", "Lives", "Frame", "Units", tostring(slot), "Cost")
        return cost and parseAmount(cost.Text) or nil
    end

    local function stepCost(step)
        if step.action == "spawn_unit" then
            local slot = slotOfUuid(resolveUuid(step.args[1], step.unitId))
            local c = slot and getSlotCost(slot)
            if c then
                return c, true
            end
        end
        return step.cost, false
    end

    local function unitsFolder()
        return workspace:FindFirstChild("_UNITS")
    end

    local function ownedBy(inst)
        local st = inst:FindFirstChild("_stats")
        local p = st and st:FindFirstChild("player")
        return p ~= nil and p.Value == player
    end

    local function snapshotOwned()
        local s, f = {}, unitsFolder()
        if f then
            for _, u in ipairs(f:GetChildren()) do
                if ownedBy(u) then
                    s[u] = true
                end
            end
        end
        return s
    end

    local function waitNewUnit(snap, unitId, timeout)
        local t = tick()
        repeat
            local f = unitsFolder()
            if f then
                for _, u in ipairs(f:GetChildren()) do
                    if not snap[u] and ownedBy(u) and (not unitId or baseName(u.Name) == baseName(unitId)) then
                        return u
                    end
                end
            end
            task.wait(0.05)
        until tick() - t > timeout or not alive
    end

    local function findOwnedByName(name)
        local f = unitsFolder()
        if not f then
            return nil
        end
        for _, u in ipairs(f:GetChildren()) do
            if baseName(u.Name) == baseName(name) and ownedBy(u) then
                return u
            end
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function groundY(pos)
        local ignore = {}
        if unitsFolder() then
            ignore[#ignore + 1] = unitsFolder()
        end
        if player.Character then
            ignore[#ignore + 1] = player.Character
        end
        rayParams.FilterDescendantsInstances = ignore
        local hit = workspace:Raycast(pos + Vector3.new(0, 60, 0), Vector3.new(0, -200, 0), rayParams)
        return hit and hit.Position.Y or nil
    end

    local function buildPlacement(recCF, groundOffset, attempt)
        local pos = recCF.Position
        if attempt > 2 then
            local r, a = 0.4 * (attempt - 2), math.random() * math.pi * 2
            pos = pos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
        end
        local gy = groundY(pos)
        if gy then
            pos = Vector3.new(pos.X, gy + (groundOffset or 0), pos.Z)
        end
        return CFrame.new(pos) * (recCF - recCF.Position)
    end

    local levelEntries = {}
    local idCategory = {}
    pcall(function()
        for wkey, w in pairs(require(RS.src.Data.Worlds)) do
            if type(w) == "table" then
                local cat = w.legend_stage and "legend_stage" or (w.raid_world and "raid" or "story")
                local name = tostring(w.name or wkey)
                if type(w.infinite) == "table" and w.infinite.id then
                    idCategory[w.infinite.id] = "infinite"
                    levelEntries[#levelEntries + 1] = {
                        id = w.infinite.id,
                        label = name .. " - Infinite",
                        cat = "infinite",
                        wkey = wkey,
                        world = name,
                        act = "Infinite"
                    }
                end
                if type(w.levels) == "table" then
                    local keys = {}
                    for k in pairs(w.levels) do
                        keys[#keys + 1] = k
                    end
                    table.sort(keys, function(a, b)
                        return (tonumber(a) or 0) < (tonumber(b) or 0)
                    end)
                    for _, k in ipairs(keys) do
                        local lv = w.levels[k]
                        if type(lv) == "table" and lv.id then
                            idCategory[lv.id] = cat
                            levelEntries[#levelEntries + 1] = {
                                id = lv.id,
                                cat = cat,
                                wkey = wkey,
                                world = name,
                                act = #keys > 1 and ("Act " .. tostring(k)) or "Level",
                                label = #keys > 1 and (name .. " - Act " .. tostring(k)) or name
                            }
                        end
                    end
                end
            end
        end
        table.sort(levelEntries, function(a, b)
            if a.label ~= b.label then
                return a.label < b.label
            end
            return a.id < b.id
        end)
    end)

    local levelInfoCache
    local function getLevelInfo()
        if levelInfoCache then
            return levelInfoCache
        end
        local cfg = workspace:FindFirstChild("_MAP_CONFIG")
        local remote = cfg and cfg:FindFirstChild("GetLevelData")
        if not remote then
            return nil
        end
        local ok, data = pcall(function()
            return remote:InvokeServer()
        end)
        if not ok or type(data) ~= "table" then
            return nil
        end

        local seen, id = {}, nil
        for _, v in pairs(data) do
            if type(v) == "string" then
                if MODES[v] then
                    seen[v] = true
                end
                if v:match("^__EVENT_CONTRACT") then
                    seen.contract = true
                end
                if not id and idCategory[v] then
                    id = v
                end
            end
        end
        if not id and type(data.id) == "string" then
            id = data.id
        end

        local mode
        for _, m in ipairs({"contract", "challenge", "infinite_tower"}) do
            if seen[m] then
                mode = m
                break
            end
        end
        if not mode and id and idCategory[id] then
            mode = idCategory[id]
        end
        if not mode then
            for _, m in ipairs({"raid", "infinite", "story"}) do
                if seen[m] then
                    mode = m
                    break
                end
            end
        end
        local info = {
            mode = mode or "unknown",
            id = id or "unknown",
            raw = data
        }
        if info.mode ~= "unknown" and info.id ~= "unknown" then
            levelInfoCache = info
        end
        return info
    end

    local macroFiles = {}
    local assignments = readJson(MAP_FILE) or {}

    local function saveAssignments()
        writefile(MAP_FILE, HttpService:JSONEncode(assignments))
    end

    local function refreshLists()
        local list = {}
        for _, f in ipairs(listfiles(MACRO_DIR)) do
            local name = f:match("([^/\\]+)%.json$")
            if name then
                list[#list + 1] = name
            end
        end
        table.sort(list)
        macroFiles = list
        if ui.recordDropdown then
            ui.recordDropdown:ClearOptions()
            ui.recordDropdown:InsertOptions(list)
            if recordTarget ~= "None" and ui.recordDropdown:IsOption(recordTarget) then
                ui.recordDropdown:UpdateSelection(recordTarget)
            end
        end
        if ui.refreshAssignUI then
            ui.refreshAssignUI(true)
        end
    end

    local function modeKey(display)
        return (display:lower():gsub(" ", "_"))
    end

    local function lookupAssignment(mode, id)
        local m = assignments[mode]
        local f = m and (m[id] or m["*"])
        if f then
            return f
        end
        for _, mm in pairs(assignments) do
            if mm[id] then
                return mm[id]
            end
        end
    end

    local function getActiveMacroFile()
        local function macroExists(name)
            return type(name) == "string" and name ~= "" and name ~= "None" and
                       isfile(MACRO_DIR .. "/" .. name .. ".json")
        end
        local info = getLevelInfo()
        if info and info.mode and info.id then
            local assigned = lookupAssignment(info.mode, info.id)
            if macroExists(assigned) then
                return assigned, ("%s | %s (Macro maps)"):format(info.mode, info.id)
            end
        end
        if macroExists(recordTarget) then
            return recordTarget, "Record file (no macro mapped for this map)"
        end
        return nil, "No macro available"
    end

    local function serializeArgs(args)
        local out = {}
        for i = 1, args.n do
            local a = args[i]
            local t = typeof(a)
            if t == "CFrame" then
                out[i] = {
                    __Type = "CFrame",
                    c = {a:GetComponents()}
                }
            elseif t == "Vector3" then
                out[i] = {
                    __Type = "Vector3",
                    c = {a.X, a.Y, a.Z}
                }
            elseif t == "Instance" then
                local stats = a:FindFirstChild("_stats")
                local uuidValue = stats and stats:FindFirstChild("uuid")
                local unitCF = a:IsA("PVInstance") and a:GetPivot() or nil
                out[i] = {
                    __Type = "Unit",
                    slot = instSlot[a],
                    name = a.Name,
                    path = a:GetFullName(),
                    uuid = uuidValue and tostring(uuidValue.Value) or nil,
                    cframe = unitCF and {unitCF:GetComponents()} or nil
                }
            elseif a == nil then
                out[i] = false
            else
                out[i] = a
            end
        end
        return out
    end

    local function onRemote(action, args, t, wave, idx, snap, cashBefore)
        if action ~= "spawn_unit" and action ~= "upgrade_unit_ingame" and action ~= "sell_unit_ingame" and action ~=
            "use_active_attack" then
            return
        end

        local step = {
            i = idx,
            action = action,
            n = args.n,
            args = serializeArgs(args)
        }
        if recMode == "Time" or recMode == "Hybrid" then
            step.time = t
        end
        if recMode == "Wave" or recMode == "Hybrid" then
            step.wave = wave
        end
        if recMode == "Yen" or recMode == "Hybrid" then
            step.yen = cashBefore
        end

        if cashBefore and (action == "spawn_unit" or action == "upgrade_unit_ingame") then
            task.delay(0.35, function()
                local after = getMoney()
                if after then
                    step.cost = math.max(0, math.floor(cashBefore - after))
                end
            end)
        end

        if action == "spawn_unit" then
            step.unitId = unitIdOf(args[1])
            step.slot = "s" .. idx

            local cf
            for i = 1, args.n do
                if typeof(args[i]) == "CFrame" then
                    cf = args[i]
                    break
                end
            end
            if cf then
                local gy = groundY(cf.Position)
                step.groundOffset = gy and (cf.Y - gy) or 0
            end

            task.spawn(function()
                local inst = waitNewUnit(snap, step.unitId, 3)
                if inst then
                    instSlot[inst] = step.slot
                end
            end)
        end

        recSteps[#recSteps + 1] = step
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if isRecording and (method == "InvokeServer" or method == "FireServer") and not checkcaller() then
            local rname = self.Name
            if RECORDED[rname] then
                recIndex = recIndex + 1
                local idx, t, wave = recIndex, tick() - recStart, curWave()
                local args = table.pack(...)
                local snap = rname == "spawn_unit" and snapshotOwned() or nil
                local cash = getMoney()
                if setnamecallmethod then
                    setnamecallmethod(method)
                end
                local res = table.pack(oldNamecall(self, ...))
                task.defer(onRemote, rname, args, t, wave, idx, snap, cash)
                return table.unpack(res, 1, res.n)
            end
        end
        return oldNamecall(self, ...)
    end))

    local function startRecording()
        if recordTarget == "None" then
            panel.status = "Select a record file first"
            return false
        end
        recMode = macroMode
        recSteps, recIndex, recStart = {}, 0, tick()
        instSlot = setmetatable({}, {
            __mode = "k"
        })
        isRecording = true
        return true
    end

    local function stopRecording()
        isRecording = false
        if #recSteps == 0 then
            return
        end
        table.sort(recSteps, function(a, b)
            return a.i < b.i
        end)
        local info = getLevelInfo()
        local data = {
            version = 3,
            mode = recMode,
            steps = recSteps,
            meta = info and {
                mode = info.mode,
                id = info.id
            } or nil
        }
        local ok, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if ok then
            writefile(MACRO_DIR .. "/" .. recordTarget .. ".json", json)
            panel.status = ("Saved %d steps to %s"):format(#recSteps, recordTarget)
        end
    end

    local function deserializeArg(a, ctx)
        if type(a) ~= "table" then
            return a
        end
        if a.__Type == "CFrame" then
            return CFrame.new(unpack(a.c))
        end
        if a.__Type == "Vector3" then
            return Vector3.new(unpack(a.c))
        end
        if a.__Type == "Unit" then
            local folder = unitsFolder()
            if folder and a.uuid and a.uuid ~= "" and a.uuid ~= "neutral" then
                for _, candidate in ipairs(folder:GetChildren()) do
                    local stats = candidate:FindFirstChild("_stats")
                    local uuidValue = stats and stats:FindFirstChild("uuid")
                    if uuidValue and tostring(uuidValue.Value) == tostring(a.uuid) then
                        return candidate
                    end
                end
            end
            local inst = a.slot and ctx.slots[a.slot]
            if inst and inst.Parent then
                return inst
            end
            if folder and a.cframe then
                local okCF, savedCF = pcall(function() return CFrame.new(unpack(a.cframe)) end)
                if okCF then
                    local best, bestDistance
                    for _, candidate in ipairs(folder:GetChildren()) do
                        if ownedBy(candidate) and (not a.name or baseName(candidate.Name) == baseName(a.name)) then
                            local okPivot = candidate:IsA("PVInstance")
                            local pivot = okPivot and candidate:GetPivot()
                            if okPivot then
                                local distance = (pivot.Position - savedCF.Position).Magnitude
                                if distance < 5 and (not bestDistance or distance < bestDistance) then
                                    best, bestDistance = candidate, distance
                                end
                            end
                        end
                    end
                    if best then return best end
                end
            end
            local node = game
            for part in tostring(a.path or ""):gmatch("[^%.]+") do
                node = node and node:FindFirstChild(part)
            end
            if node and node ~= game then return node end
            return findOwnedByName(a.name)
        end
        return a
    end

    local function describe(step)
        if not step then
            return "-"
        end
        local who = step.unitId
        if not who then
            local a = step.args and step.args[1]
            who = type(a) == "table" and a.name or nil
        end
        return who and (step.action .. " (" .. who .. ")") or step.action
    end

    local function reqText(step)
        local p = {}
        if step.wave then
            p[#p + 1] = "wave " .. step.wave
        end
        if step.time then
            p[#p + 1] = fmtTime(step.time)
        end
        local c, exact = stepCost(step)
        if c and c > 0 then
            p[#p + 1] = (exact and "" or "~") .. math.floor(c) .. " cash"
        end
        return #p > 0 and table.concat(p, ", ") or "no requirement"
    end

    local function needText(step, t0, useTime, useWave, useYen)
        local parts = {}
        if useWave and step.wave and curWave() < step.wave then
            parts[#parts + 1] = ("wave %d (now %d)"):format(step.wave, curWave())
        end
        if useYen and step.yen then
            local cash = getMoney() or 0
            if cash < step.yen then
                parts[#parts + 1] = ("Yen %d (now %d)"):format(step.yen, math.floor(cash))
            end
        end
        if useTime and step.time and step.time - (tick() - t0) > 0 then
            parts[#parts + 1] = ("time in %s"):format(fmtTime(step.time - (tick() - t0)))
        end
        return #parts > 0 and table.concat(parts, " + ") or nil
    end

    local function execSpawn(step, ctx)
        if not isPlaying then
            return false
        end

        local recCF = deserializeArg(step.args[2], ctx)
        if typeof(recCF) ~= "CFrame" then
            warn("[MACRO] Spawn failed: recorded placement is not a CFrame")
            return false
        end

        local uuid = resolveUuid(step.args[1], step.unitId)
        if not uuid then
            warn("[MACRO] Spawn failed: could not resolve unit UUID for", tostring(step.unitId))
            return false
        end

        local snap = snapshotOwned()
        local cf = buildPlacement(recCF, step.groundOffset or 0, 1)
        local folder = unitsFolder()
        if folder then
            for _, existing in ipairs(folder:GetChildren()) do
                if ownedBy(existing) and baseName(existing.Name) == baseName(step.unitId or "") then
                    local existingPivot = existing:IsA("PVInstance") and existing:GetPivot()
                    if existingPivot and (existingPivot.Position - cf.Position).Magnitude < 3 then
                        if step.slot then ctx.slots[step.slot] = existing end
                        return true
                    end
                end
            end
        end
        local invoked, invokeError = pcall(function()
            endpoints.spawn_unit:InvokeServer(uuid, cf)
        end)
        if not invoked then
            warn("[MACRO] spawn_unit error:", tostring(invokeError))
            return false
        end

        local inst = waitNewUnit(snap, step.unitId, 1.2)
        if inst then
            if step.slot then
                ctx.slots[step.slot] = inst
            end
            return true
        end

        panel.need = "Placement not confirmed; will retry"
        warn("[MACRO] Spawn was invoked but no new unit appeared:", tostring(step.unitId))
        return false
    end

    local function execUpgrade(step, ctx)
        local inst = deserializeArg(step.args[1], ctx)
        if not inst then
            warn("[MACRO] Upgrade failed: unit reference could not be resolved")
            return false
        end
        if not isPlaying or not inst.Parent then
            return false
        end

        local stat = inst:FindFirstChild("_stats") and inst._stats:FindFirstChild("upgrade")
        local before = stat and stat.Value
        local invoked, invokeError = pcall(function()
            endpoints.upgrade_unit_ingame:InvokeServer(inst)
        end)
        if not invoked then
            warn("[MACRO] upgrade_unit_ingame error:", tostring(invokeError))
            return false
        end

        if not stat then
            return true
        end

        local started = tick()
        repeat
            task.wait(0.05)
        until stat.Value ~= before or tick() - started > 1 or not alive

        if stat.Value ~= before then
            return true
        end

        panel.need = "Upgrade not confirmed; will retry"
        warn("[MACRO] Upgrade invoked but upgrade value did not change:", inst.Name)
        return false
    end

    local function execGeneric(step, ctx)
        local remote = endpoints:FindFirstChild(step.action)
        if not remote then
            warn("[MACRO] Remote not found:", step.action)
            return false
        end
        local args = {}
        for i = 1, step.n or #step.args do
            local v = step.args[i]
            args[i] = (v ~= false) and deserializeArg(v, ctx) or nil
        end
        local n = step.n or #step.args
        return pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer(unpack(args, 1, n))
            else
                remote:FireServer(unpack(args, 1, n))
            end
        end)
    end

    local function playMacro(fileName)
        if isPlaying or not fileName or fileName == "None" then
            return
        end
        local data = readJson(MACRO_DIR .. "/" .. fileName .. ".json")
        if not data or not data.steps or #data.steps == 0 then
            panel.status = "Macro is empty or invalid: " .. tostring(fileName)
            return
        end

        local steps, total = data.steps, #data.steps
        local mode = (data.mode == "Time" or data.mode == "Wave" or data.mode == "Yen" or data.mode == "Hybrid") and
                         data.mode or "Hybrid"
        local useTime = mode == "Time" or mode == "Hybrid"
        local useWave = mode == "Wave" or mode == "Hybrid"
        local useYen = mode == "Yen" or mode == "Hybrid"
        local ctx, t0 = {
            slots = {}
        }, tick()
        isPlaying = true
        panel.status = ("Playing: %s [%s mode]"):format(fileName, mode)

        for i = 1, total do
            if not isPlaying or not alive then
                break
            end
            local step = steps[i]
            panel.current = ("%d/%d  %s"):format(i, total, describe(step))
            panel.nextStep = steps[i + 1] and
                                 ("%d/%d  %s  (needs: %s)"):format(i + 1, total, describe(steps[i + 1]),
                    reqText(steps[i + 1])) or "Last step"

            while isPlaying and alive do
                local need = needText(step, t0, useTime, useWave, useYen)
                if not need then
                    local cost, exact = stepCost(step)
                    local cash = getMoney()
                    if cost and cost > 0 and cash and cash < cost then
                        need = ("cash %d (now %d)"):format(math.floor(cost), math.floor(cash))
                    end
                end
                if not need then
                    break
                end
                panel.need = "Waiting for " .. need
                task.wait(0.1)
            end
            if not isPlaying then
                break
            end

            local attempt = 0
            local ok = false
            while isPlaying and alive and not ok do
                attempt += 1
                panel.need = ("Executing %s (attempt %d; waiting for success)"):format(step.action, attempt)
                if step.action == "spawn_unit" then
                    ok = execSpawn(step, ctx)
                elseif step.action == "upgrade_unit_ingame" then
                    ok = execUpgrade(step, ctx)
                else
                    local callOk, result = pcall(execGeneric, step, ctx)
                    ok = callOk and result == true
                    if not callOk then
                        warn("[MACRO] Step error:", i, step.action, tostring(result))
                    end
                end
                if not ok and isPlaying and alive then
                    warn("[MACRO] Step still not confirmed; retrying:", i, step.action, "attempt", attempt)
                    task.wait(math.max(0.25, stepDelay))
                end
            end
            if ok then task.wait(stepDelay) end
        end

        panel.need = "-"
        panel.status = isPlaying and ("Finished: " .. fileName) or "Stopped"
        panel.nextStep = "-"
        isPlaying = false
    end

    do
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request or
                            (fluxus and fluxus.request)
    local importLink = ""

    local function notify(msg)
        panel.status = msg
        Window:Notify({
            Title = "Macro",
            Description = msg,
            Lifetime = 5
        })
    end

    local function cleanName(n)
        n = tostring(n or "")
        n = n:gsub("%.json$", "")
        n = n:gsub("[^%w%-%_ ]", "")
        n = n:gsub("^%s+", "")
        n = n:gsub("%s+$", "")
        return n
    end

    local function exportMacro()
        if recordTarget == "None" or recordTarget == "" then
            notify("Export: select a macro in 'Record file' first")
            return
        end
        local path = MACRO_DIR .. "/" .. recordTarget .. ".json"
        if not isfile(path) then
            notify("Export: macro file not found")
            return
        end
        local hook = urlwebhook
        if type(hook) ~= "string" or not hook:match("^https://") then
            notify("Export: set the Webhook URL first")
            return
        end
        if not httpRequest then
            notify("Export: your executor has no http request function")
            return
        end

        local name = recordTarget
        task.spawn(function()
            panel.status = "Exporting " .. name .. "..."
            local content = readfile(path)
            local boundary = "----OneHub" .. (HttpService:GenerateGUID(false):gsub("-", ""))
            local payload = HttpService:JSONEncode({
                content = "Macro exported: **" .. name .. "**"
            })
            local body = table.concat({"--" .. boundary, 'Content-Disposition: form-data; name="payload_json"',
                                       "Content-Type: application/json", "", payload, "--" .. boundary,
                                       'Content-Disposition: form-data; name="files[0]"; filename="' .. name ..
                ".json" .. '"', "Content-Type: application/json", "", content, "--" .. boundary .. "--", ""}, "\r\n")

            local url = hook .. (hook:find("?", 1, true) and "&" or "?") .. "wait=true"
            local ok, res = pcall(httpRequest, {
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
                },
                Body = body
            })
            if not ok or type(res) ~= "table" or (res.StatusCode or 0) < 200 or (res.StatusCode or 0) >= 300 then
                notify("Export failed: " .. tostring(ok and res and res.StatusCode or res))
                return
            end

            local okj, msg = pcall(function()
                return HttpService:JSONDecode(res.Body)
            end)
            local att = okj and type(msg) == "table" and msg.attachments and msg.attachments[1]
            local link = att and att.url
            if not link then
                notify("Export: uploaded, but Discord returned no CDN link")
                return
            end

            pcall(httpRequest, {
                Url = hook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    content = "CDN link for `" .. name .. "`:\n```\n" .. link .. "\n```"
                })
            })
            if setclipboard then
                pcall(setclipboard, link)
            end
            notify("Exported '" .. name .. "' - CDN link sent to the webhook" .. (setclipboard and " and copied" or ""))
        end)
    end

    local function importMacro()
        local link = (tostring(importLink or ""):gsub("%s+", ""))
        if not link:match("^https?://") then
            notify("Import: paste a valid link first")
            return
        end
        task.spawn(function()
            panel.status = "Importing..."
            local ok, body = pcall(function()
                if httpRequest then
                    local r = httpRequest({
                        Url = link,
                        Method = "GET"
                    })
                    local code = r.StatusCode or 0
                    if code < 200 or code >= 300 then
                        error("HTTP " .. tostring(code) .. " (expired link?)")
                    end
                    return r.Body
                end
                return game:HttpGet(link)
            end)
            if not ok or type(body) ~= "string" or #body == 0 then
                notify("Import failed: " .. tostring(body))
                return
            end
            if #body > 4000000 then
                notify("Import failed: file too large")
                return
            end

            local okj, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if not okj or type(data) ~= "table" or type(data.steps) ~= "table" then
                notify("Import failed: not a valid macro file")
                return
            end

            local clean = {}
            for _, s in ipairs(data.steps) do
                if type(s) == "table" and RECORDED[s.action] then
                    clean[#clean + 1] = s
                end
            end
            if #clean == 0 then
                notify("Import failed: macro has no valid steps")
                return
            end
            data.steps = clean

            local name = cleanName(macroName)
            if name == "" then
                local fromUrl = link:match("([^/?#]+)%.json") or ""
                fromUrl = fromUrl:gsub("%%20", " ")
                name = cleanName(fromUrl)
            end
            if name == "" then
                name = "imported_" .. tostring(os.time() % 100000)
            end
            if isfile(MACRO_DIR .. "/" .. name .. ".json") then
                name = name .. "_" .. tostring(os.time() % 100000)
            end

            writefile(MACRO_DIR .. "/" .. name .. ".json", HttpService:JSONEncode(data))
            recordTarget = name
            if ui.recInfo then
                ui.recInfo:UpdateName("Recording file: " .. name)
            end
            refreshLists()
            notify(("Imported '%s' (%d steps)"):format(name, #clean))
        end)
    end


    ui.exportMacro = exportMacro
    ui.importMacro = importMacro
    ui.setImportLink = function(v)
        importLink = v
    end
    end

    ;(function()
    local PlaceCfg = {
        show = false,
        priority = {},
        hill = {},
        maxUpgrade = {},
        maxPlace = {}
    }
    local SQ, STEP, HILL_MIN = 1.1, 3, 2
    local COL_GROUND = Color3.fromRGB(0, 255, 90)
    local COL_HILL = Color3.fromRGB(40, 140, 255)
    local COL_TAKEN = Color3.fromRGB(255, 60, 60)

    local placeSet, placeSetKey, visual
    local placeFail, placeBad, placeCooldown, placeWait = {}, {}, {}, {}

    local function getWaypoints()
        local lane = findPath(workspace, "_BASES", "pve", "LANES", "1")
        local out = {}
        if lane then
            for _, w in ipairs(lane:GetChildren()) do
                if w:IsA("BasePart") then
                    out[#out + 1] = w
                end
            end
        end
        table.sort(out, function(a, b)
            local na, nb = tonumber(a.Name), tonumber(b.Name)
            if na and nb then
                return na < nb
            end
            return a.Name < b.Name
        end)
        return out
    end

    local function totalMaxPlace()
        local total = 0
        for slot = 1, 6 do
            total = total + math.max(0, math.floor(tonumber(PlaceCfg.maxPlace[slot]) or 0))
        end
        return total
    end

    local function spreadCandidates(list, target, centerX, centerZ)
        if target <= 0 then return {} end
        if #list <= target then return list end
        local byAngle = {}
        for _, c in ipairs(list) do
            c.angle = math.atan2(c.pos.Z - centerZ, c.pos.X - centerX)
            byAngle[#byAngle + 1] = c
        end
        table.sort(byAngle, function(a, b) return a.angle < b.angle end)
        local out, used = {}, {}
        for i = 1, target do
            local index = math.floor(((i - 0.5) * #byAngle / target) + 1)
            index = math.clamp(index, 1, #byAngle)
            while used[index] and index < #byAngle do index = index + 1 end
            if not used[index] then
                used[index] = true
                out[#out + 1] = byAngle[index]
            end
        end
        return out
    end

    local function getTerrainSurfaceRoot(kind)
        local terrain = workspace:FindFirstChild("_terrain")
        if not terrain then return nil end
        local wanted = kind:lower()
        for _, inst in ipairs(terrain:GetDescendants()) do
            if (inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("Folder"))
                and inst.Name:lower():find(wanted, 1, true) then
                return inst
            end
        end
        return terrain:FindFirstChild(kind, true)
    end

    local function surfaceContains(root, pos)
        if not root then return false end
        local gy = groundY(pos)
        if not gy then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = {root}
        local hit = workspace:Raycast(Vector3.new(pos.X, gy + 60, pos.Z), Vector3.new(0, -200, 0), params)
        return hit ~= nil
    end

    local function nearestHillCenter(center)
        local hillRoot = getTerrainSurfaceRoot("hill")
        if not hillRoot then return nil, nil end
        local bestPos, bestDist
        local function consider(part)
            if not part:IsA("BasePart") then return end
            local p = part.Position
            local d = (Vector3.new(p.X, center.Y, p.Z) - Vector3.new(center.X, center.Y, center.Z)).Magnitude
            if not bestDist or d < bestDist then bestPos, bestDist = p, d end
        end
        if hillRoot:IsA("BasePart") then consider(hillRoot) end
        for _, inst in ipairs(hillRoot:GetDescendants()) do consider(inst) end
        if not bestPos then return nil, nil end
        return bestPos, hillRoot
    end

    local function getSet()
        local wps = getWaypoints()
        if #wps == 0 then
            placeSet, placeSetKey = nil, nil
            return nil
        end
        local idx = math.clamp(math.floor((distancePercentage or 50) * (#wps / 100)), 1, #wps)
        local center = wps[idx].Position
        local gR = math.clamp((GroundPercentage or 50) * 0.20, 1, 20)
        local hR = math.clamp((HillPercentage or 50) * 0.20, 1, 20)
        local hillCenter, hillRoot = nearestHillCenter(center)
        local budget = totalMaxPlace()
        local hillBudget = 0
        for slot = 1, 6 do
            if PlaceCfg.hill[slot] then
                hillBudget = hillBudget + math.max(0, math.floor(tonumber(PlaceCfg.maxPlace[slot]) or 0))
            end
        end
        local hc = hillCenter or Vector3.new(0, -100000, 0)
        local key = table.concat({idx, #wps, gR, hR, math.floor(center.X), math.floor(center.Z),
            math.floor(hc.X), math.floor(hc.Z), budget, hillBudget}, "|")
        if placeSet and placeSetKey == key then return placeSet end

        local baseY = groundY(center) or center.Y
        local set = {center=center, baseY=baseY, gR=gR, hR=hR, ground={}, hill={}}
        local function buildGrid(origin, radius, kind)
            if kind == "hill" and not hillRoot then return {} end
            local list = {}
            local minX, maxX = math.floor((origin.X-radius)/STEP), math.ceil((origin.X+radius)/STEP)
            local minZ, maxZ = math.floor((origin.Z-radius)/STEP), math.ceil((origin.Z+radius)/STEP)
            for ix=minX,maxX do
                for iz=minZ,maxZ do
                    local x,z=ix*STEP,iz*STEP
                    local d=math.sqrt((x-origin.X)^2+(z-origin.Z)^2)
                    if d <= radius then
                        local probe=Vector3.new(x, origin.Y, z)
                        local gy=groundY(probe)
                        if gy then
                            local pos=Vector3.new(x,gy,z)
                            local valid=false
                            if kind == "hill" then
                                valid = surfaceContains(hillRoot, pos)
                            else
                                valid = not surfaceContains(hillRoot, pos)
                                    and (gy - baseY) <= HILL_MIN
                                    and (gy - baseY) >= -HILL_MIN
                            end
                            if valid then
                                list[#list+1]={pos=pos,d=d,key=kind..":"..ix..":"..iz,kind=kind}
                            end
                        end
                    end
                end
            end
            table.sort(list,function(a,b) return a.d < b.d end)
            return list
        end

        set.ground = buildGrid(center, gR, "ground")
        if hillCenter then set.hill = buildGrid(hillCenter, hR, "hill") end

        local totalBudget = budget
        local hillTarget = math.min(hillBudget, totalBudget, #set.hill)
        local groundTarget = math.min(math.max(0, totalBudget-hillBudget), #set.ground)
        set.ground = spreadCandidates(set.ground, groundTarget, center.X, center.Z)
        if hillCenter then
            set.hill = spreadCandidates(set.hill, hillTarget, hillCenter.X, hillCenter.Z)
        else
            set.hill = {}
        end
        placeSet, placeSetKey = set, key
        return set
    end

    local function unitPositions()
        local t, f = {}, unitsFolder()
        if f then
            for _, u in ipairs(f:GetChildren()) do
                if u:IsA("PVInstance") then
                    t[#t + 1] = u:GetPivot().Position
                end
            end
        end
        return t
    end

    local function isTaken(c, positions)
        local lim = (STEP * 0.7) ^ 2
        for _, p in ipairs(positions) do
            if (p.X - c.pos.X) ^ 2 + (p.Z - c.pos.Z) ^ 2 < lim then
                return true
            end
        end
        return false
    end

    local function clearVisual()
        if visual then
            visual.folder:Destroy()
            visual = nil
        end
    end

    local function newPart(parent, size, cf, color, transp, shape)
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Transparency = transp
        if shape then
            p.Shape = shape
        end
        p.Parent = parent
        return p
    end

    local function drawVisual(set)
        clearVisual()
        local folder = Instance.new("Folder")
        folder.Name = "OneHubPlacements"
        folder.Parent = workspace

        local function disc(cx, cz, r, y, color)
            newPart(folder, Vector3.new(0.1, r * 2, r * 2),
                CFrame.new(cx, y + 0.08, cz) * CFrame.Angles(0, 0, math.pi / 2), color, 0.8, Enum.PartType.Cylinder)
        end
        disc(set.center.X, set.center.Z, set.gR, set.baseY, COL_GROUND)
        if #set.hill > 0 then
            local n, sx, sy, sz = #set.hill, 0, 0, 0
            for _, c in ipairs(set.hill) do
                sx, sy, sz = sx + c.pos.X, sy + c.pos.Y, sz + c.pos.Z
            end
            local cx, cz = sx / n, sz / n
            local r = 0
            for _, c in ipairs(set.hill) do
                r = math.max(r, math.sqrt((c.pos.X - cx) ^ 2 + (c.pos.Z - cz) ^ 2))
            end
            disc(cx, cz, r + SQ, sy / n, COL_HILL)
        end

        local cells = {}
        local function squares(list, color)
            for _, c in ipairs(list) do
                local part = newPart(folder, Vector3.new(SQ, 0.08, SQ), CFrame.new(c.pos.X, c.pos.Y + 0.1, c.pos.Z),
                    color, 0.25)
                cells[#cells + 1] = {
                    part = part,
                    cand = c,
                    color = color
                }
            end
        end
        squares(set.ground, COL_GROUND)
        squares(set.hill, COL_HILL)
        visual = {
            folder = folder,
            cells = cells,
            set = set
        }
    end

    local function refreshVisualColors()
        if not visual then
            return
        end
        local positions = unitPositions()
        for _, cell in ipairs(visual.cells) do
            local want = isTaken(cell.cand, positions) and COL_TAKEN or cell.color
            if cell.part.Color ~= want then
                cell.part.Color = want
            end
        end
    end

    task.spawn(function()
        while alive do
            if PlaceCfg.show then
                local set = getSet()
                if not set then
                    clearVisual()
                else
                    if not visual or visual.set ~= set then
                        drawVisual(set)
                    end
                    refreshVisualColors()
                end
            else
                clearVisual()
            end
            task.wait(0.5)
        end
        clearVisual()
    end)

    local function equippedList()
        local col = getCollection()
        local eq = col and col.equipped_units
        local owned = col and col.owned_units
        local list = {}
        if not eq or not owned then
            return list
        end
        local counter = 0
        for k, id in pairs(eq) do
            counter = counter + 1
            local o = owned[id] or owned[tostring(id)]
            list[#list + 1] = {
                slot = tonumber(k) or counter,
                uuid = id,
                unitId = o and o.unit_id or nil
            }
        end
        table.sort(list, function(a, b)
            return a.slot < b.slot
        end)
        return list
    end

    local unitsData
    local hillCache = {}
    local unitsPVEGenericData
    local unitUpgradeCostCache = {}

    local function normalizeUnitKey(value)
        if type(value) ~= "string" then
            return nil
        end
        value = value:lower():gsub("[^%w]", "")
        value = value:gsub("evolved$", ""):gsub("christmas$", ""):gsub("halloween$", "")
        return value
    end

    local function loadUnitsPVEGeneric()
        if unitsPVEGenericData ~= nil then
            return unitsPVEGenericData or nil
        end
        unitsPVEGenericData = false
        local dataModule = findPath(RS, "src", "Data", "Units_PVE_Generic")
        if dataModule and dataModule:IsA("ModuleScript") then
            unitsPVEGenericData = require(dataModule)
        end
        return unitsPVEGenericData or nil
    end

    local function requireDataValue(value)
        if typeof(value) == "Instance" and value:IsA("ModuleScript") then
            local ok, result = pcall(require, value)
            return ok and result or nil
        end
        return value
    end

    local function findUnitData(node, wanted, depth, seen)
        if depth > 12 or node == nil then
            return nil
        end
        node = requireDataValue(node)
        if type(node) ~= "table" or seen[node] then
            return nil
        end
        seen[node] = true

        local wantedKey = normalizeUnitKey(wanted)
        for key, value in pairs(node) do
            if type(key) == "string" and normalizeUnitKey(key) == wantedKey then
                local resolved = requireDataValue(value)
                if type(resolved) == "table" then
                    return resolved
                end
            end
        end
        for _, value in pairs(node) do
            local resolved = requireDataValue(value)
            if type(resolved) == "table" then
                local found = findUnitData(resolved, wanted, depth + 1, seen)
                if found then
                    return found
                end
            end
        end
        return nil
    end

    local function findNumericCost(node, depth, seen)
        if depth > 8 or type(node) ~= "table" or seen[node] then
            return nil
        end
        seen[node] = true
        for key, value in pairs(node) do
            if type(value) == "number" and type(key) == "string" then
                local k = key:lower():gsub("[%s_%-]", "")
                if k == "cost" or k == "price" or k == "upgradecost" or k == "upgradeprice" or k == "upgrade_cost" then
                    return value
                end
            end
        end
        for key, value in pairs(node) do
            if type(value) == "table" then
                local result = findNumericCost(value, depth + 1, seen)
                if result then
                    return result
                end
            end
        end
        return nil
    end

    local unitsModuleData
    local unitsModuleLoaded = false

    local function getUnitsRoot()
        local data = RS:FindFirstChild("src")
        data = data and data:FindFirstChild("Data")
        return data and data:FindFirstChild("Units")
    end

    local function resolveUnitRecord(wanted)
        local wantedKey = normalizeUnitKey(tostring(wanted or ""))
        if wantedKey == "" then
            return nil
        end

        local root = getUnitsRoot()
        if not root then
            return nil
        end

        local candidates = {}
        if root:IsA("ModuleScript") then
            candidates[#candidates + 1] = root
        end
        for _, inst in ipairs(root:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                candidates[#candidates + 1] = inst
            end
        end

        local function findRecord(node, depth, seen)
            if depth > 12 or type(node) ~= "table" or seen[node] then return nil end
            seen[node] = true
            for key, value in pairs(node) do
                if type(value) == "table" then
                    local id = normalizeUnitKey(tostring(value.id or value.unit_id or value.name or ""))
                    if id == wantedKey or (type(key) == "string" and normalizeUnitKey(key) == wantedKey) then
                        return value
                    end
                    local found = findRecord(value, depth + 1, seen)
                    if found then return found end
                end
            end
            return nil
        end

        for _, moduleScript in ipairs(candidates) do
            if normalizeUnitKey(moduleScript.Name) == wantedKey then
                local ok, record = pcall(require, moduleScript)
                if ok and type(record) == "table" then
                    local nested = findRecord(record, 0, {})
                    return nested or record
                end
            end
            local ok, data = pcall(require, moduleScript)
            if ok and type(data) == "table" then
                local found = findRecord(data, 0, {})
                if found then return found end
            end
        end

        if not unitsModuleLoaded then
            unitsModuleLoaded = true
            local ok, data = pcall(function()
                if root:IsA("ModuleScript") then return require(root) end
                return nil
            end)
            unitsModuleData = ok and data or false
        end

        local function scanTable(node, depth, seen)
            if depth > 12 or type(node) ~= "table" or seen[node] then return nil end
            seen[node] = true
            for key, value in pairs(node) do
                if type(key) == "string" and normalizeUnitKey(key) == wantedKey and type(value) == "table" then
                    return value
                end
                if type(value) == "table" then
                    local valueKey = normalizeUnitKey(tostring(value.id or value.unit_id or value.name or ""))
                    if valueKey == wantedKey then return value end
                    local found = scanTable(value, depth + 1, seen)
                    if found then return found end
                elseif typeof(value) == "Instance" and value:IsA("ModuleScript") then
                    local ok, result = pcall(require, value)
                    if ok and type(result) == "table" then
                        local valueKey = normalizeUnitKey(tostring(result.id or result.unit_id or result.name or value.Name))
                        if valueKey == wantedKey then return result end
                        local found = scanTable(result, depth + 1, seen)
                        if found then return found end
                    end
                end
            end
            return nil
        end

        if type(unitsModuleData) == "table" then
            return scanTable(unitsModuleData, 0, {})
        end
        return nil
    end

    local function getNextUpgradeCost(unitId, currentLevel)
        if not unitId then return nil end
        currentLevel = tonumber(currentLevel) or 0
        local cacheKey = tostring(unitId) .. ":" .. tostring(currentLevel)
        if unitUpgradeCostCache[cacheKey] ~= nil then
            return unitUpgradeCostCache[cacheKey] or nil
        end

        local record = resolveUnitRecord(unitId)
        local result
        if type(record) == "table" and type(record.upgrade) == "table" then
            local nextEntry = record.upgrade[currentLevel + 1]
                or record.upgrade[tostring(currentLevel + 1)]
            if type(nextEntry) == "table" then
                result = tonumber(nextEntry.cost or nextEntry.price or nextEntry.upgrade_cost)
            end
        end

        unitUpgradeCostCache[cacheKey] = result or false
        return result
    end
    local function getUnitData(unitId)
        return resolveUnitRecord(unitId)
    end

    local function isHillUnit(unitId)
        if not unitId then
            return false
        end
        if hillCache[unitId] ~= nil then
            return hillCache[unitId]
        end

        local record = getUnitData(unitId)
        local result = type(record) == "table" and record.hill_unit == true
        hillCache[unitId] = result
        return result
    end

    local function getUnitPlaceCost(unitId)
        local record = getUnitData(unitId)
        if type(record) == "table" then
            local cost = tonumber(record.cost or record.place_cost or record.spawn_cost)
            if cost and cost >= 0 then
                return cost
            end
        end
        return nil
    end

    local function countPlaced(unitId)
        local n, f = 0, unitsFolder()
        if f and unitId then
            for _, u in ipairs(f:GetChildren()) do
                if ownedBy(u) and baseName(u.Name) == baseName(unitId) then
                    n = n + 1
                end
            end
        end
        return n
    end

    local function femtoInMap()
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and (m.Name == "griffith_reincarnation" or m.Name == "femto_egg") then
                return true
            end
        end
        return false
    end

    local RESTRICTED = {
        erwin = true,
        wendy = true,
        Leafy = true
    }

    local function pickCandidate(set, kind)
        local now, positions = tick(), unitPositions()
        for _, c in ipairs(set[kind]) do
            if not (placeBad[c.key] and placeBad[c.key] > now) and not isTaken(c, positions) then
                return c
            end
        end
    end

    local function spawnAt(u, pos)
        local snap = snapshotOwned()
        pcall(function()
            endpoints.spawn_unit:InvokeServer(u.uuid, CFrame.new(pos))
        end)
        return waitNewUnit(snap, u.unitId, 1) ~= nil
    end

    local function placeStep()
        if loadedallscript ~= true or not workspace:FindFirstChild("_wave_num") then
            return
        end
        if OnlyautoPlaceEnabled == true then
            local need = tonumber(selectedWaveToPlace)
            if need and curWave() < need then
                return
            end
        end
        local set = getSet()
        if not set then
            return
        end
        local units = equippedList()
        if #units == 0 then
            return
        end

        local function rank(u)
            if u.unitId == "femto_egg" then
                return 0
            elseif PlaceCfg.priority[u.slot] then
                return 1 + PlaceCfg.priority[u.slot]
            end
            return 100
        end
        table.sort(units, function(a, b)
            local ra, rb = rank(a), rank(b)
            if ra ~= rb then
                return ra < rb
            end
            return a.slot < b.slot
        end)

        for _, u in ipairs(units) do
            if autoPlaceEnabled ~= true or not alive then
                return
            end
            local cd = placeCooldown[u.slot]
            local name = u.unitId or "Unknown"
            local maxPlace = math.max(0, math.floor(tonumber(PlaceCfg.maxPlace[u.slot]) or 0))
            local skip = maxPlace == 0 or (cd ~= nil and cd > tick())
            if not skip and countPlaced(name) >= maxPlace then
                skip = true
            end

            if not skip and autoSacrificeGriffithEnabled == true and unitsFolder() and
                unitsFolder():FindFirstChild("femto_egg") and RESTRICTED[name] and not femtoInMap() then
                skip = true
            end
            if not skip and name == "femto_egg" and (femtoInMap() or findOwnedByName("femto_egg")) then
                skip = true
            end

            if not skip then
                local cost = getUnitPlaceCost(name) or getSlotCost(u.slot)
                local cash = getMoney()
                local affordable = cost ~= nil and cash ~= nil and cash >= cost

                if affordable then
                    local cand, pos
                    if name == "femto_egg" then
                        local p = set.center + Vector3.new(25, 0, 25)
                        pos = Vector3.new(p.X, groundY(p) or p.Y, p.Z)
                    else
                        local kind = (PlaceCfg.hill[u.slot] or isHillUnit(name)) and "hill" or "ground"
                        cand = pickCandidate(set, kind)
                        if cand then
                            pos = cand.pos
                        else
                            placeCooldown[u.slot] = tick() + 3
                        end
                    end

                    if pos then
                        local ok = spawnAt(u, pos)
                        if ok then
                            placeWait[u.slot] = nil
                            if cand then placeFail[cand.key] = nil end
                            return
                        else
                            placeCooldown[u.slot] = tick() + 4
                            if cand then
                                local n = (placeFail[cand.key] or 0) + 1
                                placeFail[cand.key] = n
                                if n >= (countPlaced(name) > 0 and 4 or 2) then
                                    placeBad[cand.key] = tick() + 45
                                    placeFail[cand.key] = nil
                                end
                            end
                        end
                    end
                elseif cost == nil or cash == nil then
                    placeWait[u.slot] = tick()
                elseif PlaceCfg.priority[u.slot] or name == "femto_egg" then
                    return
                end
            end
        end
    end

    local placeRunning = false
    function autoPlace()
        if placeRunning then
            return
        end
        placeRunning = true
        task.spawn(function()
            while autoPlaceEnabled == true and alive do
                local ok, err = pcall(placeStep)
                if not ok then
                    warn("[AutoPlace]", err)
                end
                task.wait(1)
            end
            placeRunning = false
        end)
    end

    local function upgradeStep()
        if loadedallscript ~= true or not workspace:FindFirstChild("_wave_num") then
            return
        end
        if onlyupgradeinXwaveEnabled == true then
            local need = tonumber(selectedWaveToUpgrade)
            if need and curWave() < need then
                return
            end
        end
        local f = unitsFolder()
        if not f then
            return
        end
        local equipped = equippedList()
        local cash = getMoney()
        for _, u in ipairs(f:GetChildren()) do
            if autoUpgradeEnabled ~= true or not alive then
                return
            end
            if ownedBy(u) then
                local slotInfo
                local unitName = baseName(u.Name)
                local st = u:FindFirstChild("_stats")
                local uuidValue = st and (st:FindFirstChild("uuid") or st:FindFirstChild("unit_uuid"))
                local uuid = uuidValue and tostring(uuidValue.Value) or nil
                for _, e in ipairs(equipped) do
                    if (uuid and tostring(e.uuid) == uuid) or
                        (not uuid and e.unitId and baseName(e.unitId) == unitName) or
                        (e.unitId and baseName(e.unitId) == unitName) then
                        slotInfo = e
                        break
                    end
                end
                if slotInfo then
                    local max = PlaceCfg.maxUpgrade[slotInfo.slot] or 0
                    local stat = st and st:FindFirstChild("upgrade")
                    local lvl = stat and tonumber(stat.Value) or 0
                    if max == 0 or lvl < max then
                        local upgradeCost = getNextUpgradeCost(slotInfo.unitId or u.Name, lvl)
                        if cash ~= nil and upgradeCost ~= nil and cash >= upgradeCost then
                            local ok, err = pcall(function()
                                endpoints.upgrade_unit_ingame:InvokeServer(u)
                            end)
                            if not ok then
                                warn("[AutoUpgrade] upgrade_unit_ingame error:", tostring(err))
                            else
                                cash = math.max(0, cash - upgradeCost)
                            end
                            return
                        end
                    end
                end
            end
        end
    end

    local upgradeRunning = false
    function autoUpgrade()
        if upgradeRunning then
            return
        end
        upgradeRunning = true
        task.spawn(function()
            while autoUpgradeEnabled == true and alive do
                local ok, err = pcall(upgradeStep)
                if not ok then
                    warn("[AutoUpgrade]", err)
                end
                task.wait(1.5)
            end
            upgradeRunning = false
        end)
    end

    OneHubPlacements = {
        cfg = PlaceCfg,
        getSet = getSet
    }

    end)()

    local function buildUI(secRecord, secPanel, secMap, secInfo)
        local autoHandled = false
        secPanel:Header({
            Name = "Macro Panel"
        })
        local lblStatus = secPanel:Label({
            Text = "Status: Idle"
        })
        local lblCurrent = secPanel:Label({
            Text = "Current step: -"
        })
        local lblNeed = secPanel:Label({
            Text = "Requirement: -"
        })
        local lblNext = secPanel:Label({
            Text = "Next step: -"
        })
        local lblCash = secPanel:Label({
            Text = "Cash: -"
        })
        secPanel:Divider()
        local lblDetected = secPanel:Label({
            Text = "Detected: Not in a match"
        })
        local lblRecInfo = secPanel:Label({
            Text = "Recording file: None"
        })
        ui.recInfo = lblRecInfo

        secRecord:Header({
            Name = "Record"
        })

        ui.recordDropdown = secRecord:Dropdown({
            Name = "Record file",
            Multi = false,
            Required = false,
            Options = macroFiles,
            Default = "None",
            Callback = function(v)
                recordTarget = (tostring(v):gsub("%.json$", ""))
                lblRecInfo:UpdateName("Recording file: " .. recordTarget)
            end
        }, "MacroRecordFile")

        secRecord:Input({
            Name = "Macro name",
            Placeholder = "Type a name...",
            AcceptedCharacters = "All",
            Callback = function(v)
                macroName = v
            end,
            onChanged = function(v)
                macroName = v
            end
        }, "MacroFileNameInput")

        secRecord:Button({
            Name = "Refresh list",
            Callback = refreshLists
        })

        secRecord:Button({
            Name = "Create macro",
            Callback = function()
                if macroName == "" then
                    return
                end
                local path = MACRO_DIR .. "/" .. macroName .. ".json"
                if not isfile(path) then
                    writefile(path, "{}")
                end
                refreshLists()
            end
        })

        secRecord:Button({
            Name = "Delete selected macro",
            Callback = function()
                if recordTarget == "None" then
                    return
                end
                local path = MACRO_DIR .. "/" .. recordTarget .. ".json"
                if isfile(path) then
                    delfile(path)
                end
                recordTarget = "None"
                lblRecInfo:UpdateName("Recording file: None")
                refreshLists()
            end
        })

        secRecord:Divider()
        secRecord:Header({
            Name = "Import / Export"
        })
        secRecord:Label({
            Text = "Export uploads the selected macro through the Webhook URL and sends the CDN link. Import downloads a macro from a link."
        })
        secRecord:Button({
            Name = "Export selected macro (webhook)",
            Callback = function()
                ui.exportMacro()
            end
        })
        secRecord:Input({
            Name = "Import link (CDN)",
            Placeholder = "Paste the macro link...",
            AcceptedCharacters = "All",
            Callback = function(v)
                ui.setImportLink(v)
            end,
            onChanged = function(v)
                ui.setImportLink(v)
            end
        }, "MacroImportLink")
        secRecord:Button({
            Name = "Import macro from link",
            Callback = function()
                ui.importMacro()
            end
        })
        secRecord:Divider()

        secRecord:Dropdown({
            Name = "Macro mode",
            Multi = false,
            Required = false,
            Options = {"Time", "Wave", "Yen", "Hybrid"},
            Default = "Hybrid",
            Callback = function(v)
                macroMode = v
            end
        }, "MacroMode")

        ui.recToggle = secRecord:Toggle({
            Name = "Record macro",
            Default = false,
            Callback = function(v)
                if v then
                    if not startRecording() then
                        ui.recToggle:UpdateState(false)
                    end
                elseif isRecording then
                    stopRecording()
                end
            end
        })

        secRecord:Divider()
        secRecord:Header({
            Name = "Play Macro"
        })

        secRecord:Label({
            Text = "Play Macro: runs the macro assigned in 'Macro maps' for the current map; if none is assigned it runs the 'Record file' selection."
        })

        OneHubSliderSync = OneHubSliderSync or {}
        local function applyStepDelay(v)
            local o = MacLib.Options.StepDelay
            stepDelay = tonumber(o and o.Value or v) or 0.2
        end
        OneHubSliderSync.StepDelay = applyStepDelay
        secRecord:Slider({
            Name = "Delay between steps",
            Default = 0.2,
            Minimum = 0,
            Maximum = 1,
            DisplayMethod = "Number",
            Precision = 1,
            Callback = applyStepDelay
        }, "StepDelay")

        ui.playToggle = secRecord:Toggle({
            Name = "Play Macro",
            Default = false,
            Callback = function(v)
                autoRun = v
                if v then
                    autoHandled = false
                else
                    isPlaying = false
                end
            end
        }, "AutoPlayMacro")

        secMap:Header({
            Name = "Macro maps"
        })
        secMap:Label({
            Text = "Pick a mode and a map, then choose the macro for each act. Changes save instantly."
        })

        local maxRows = 1
        do
            local count = {}
            for _, e in ipairs(levelEntries) do
                local k = e.wkey .. "|" .. e.cat
                count[k] = (count[k] or 0) + 1
                maxRows = math.max(maxRows, count[k])
            end
            maxRows = math.min(maxRows, 8)
        end

        local suppress = false
        local worldRows = {}
        local curRows = {}
        local rowDD, allDD = {}, {}
        local worldDD, fallbackDD

        local function fileOptions()
            local o = {"None"}
            for _, f in ipairs(macroFiles) do
                o[#o + 1] = f
            end
            return o
        end

        local function assignedFor(id)
            local m = assignments[modeKey(assignMode)]
            return m and m[id]
        end

        local function setAssignment(id, file)
            local mk = modeKey(assignMode)
            assignments[mk] = assignments[mk] or {}
            assignments[mk][id] = (file ~= "None") and file or nil
            saveAssignments()
        end

        local function showSelection(dd, file)
            suppress = true
            pcall(function()
                dd:UpdateSelection((file and dd:IsOption(file)) and file or "None")
            end)
            suppress = false
        end

        function ui.refreshAssignUI(reloadOptions)
            if reloadOptions then
                for _, dd in ipairs(allDD) do
                    dd:ClearOptions()
                    dd:InsertOptions(fileOptions())
                end
            end
            for i, dd in ipairs(rowDD) do
                local e = curRows[i]
                if e then
                    dd:SetVisibility(true)
                    dd:UpdateName(e.act)
                    showSelection(dd, assignedFor(e.id))
                else
                    dd:SetVisibility(false)
                end
            end
            if fallbackDD then
                showSelection(fallbackDD, assignedFor("*"))
            end
        end

        local function selectWorld(name)
            curRows = worldRows[name] or {}
            ui.refreshAssignUI(false)
        end

        local function selectMode(display)
            assignMode = display
            local want = modeKey(display)
            if want == "challenge" or want == "contract" then
                want = "story"
            end
            worldRows = {}
            local names, nameOf = {}, {}
            if want ~= "infinite_tower" then
                for _, e in ipairs(levelEntries) do
                    if e.cat == want then
                        local dn = nameOf[e.wkey]
                        if not dn then
                            dn = e.world
                            if worldRows[dn] then
                                dn = dn .. " [" .. e.wkey .. "]"
                            end
                            nameOf[e.wkey] = dn
                            worldRows[dn] = {}
                            names[#names + 1] = dn
                        end
                        table.insert(worldRows[dn], e)
                    end
                end
            end
            table.sort(names)
            if worldDD then
                worldDD:ClearOptions()
                worldDD:InsertOptions(names)
                worldDD:SetVisibility(#names > 0)
            end
            if #names > 0 and worldDD then
                worldDD:UpdateSelection(names[1])
            else
                selectWorld(nil)
            end
        end

        local modeDD = secMap:Dropdown({
            Name = "Mode",
            Multi = false,
            Required = false,
            Options = MODE_LIST,
            Callback = function(v)
                if v then
                    selectMode(v)
                end
            end
        })

        worldDD = secMap:Dropdown({
            Name = "Map",
            Multi = false,
            Required = false,
            Options = {},
            Callback = function(v)
                if v then
                    selectWorld(v)
                end
            end
        })

        for i = 1, maxRows do
            local dd = secMap:Dropdown({
                Name = "Act " .. i,
                Multi = false,
                Required = false,
                Options = {"None"},
                Callback = function(v)
                    if suppress or not v then
                        return
                    end
                    local e = curRows[i]
                    if e then
                        setAssignment(e.id, v)
                    end
                end
            })
            rowDD[i] = dd
            allDD[#allDD + 1] = dd
        end

        local last = {}
        local function setLabel(key, label, text)
            if last[key] ~= text then
                last[key] = text
                label:UpdateName(text)
            end
        end

        task.spawn(function()
            while alive do
                if isRecording then
                    panel.status = ("Recording... %d steps | wave %d"):format(#recSteps, curWave())
                end
                setLabel("s", lblStatus, "Status: " .. panel.status)
                setLabel("c", lblCurrent, "Current step: " .. panel.current)
                setLabel("n", lblNeed, "Requirement: " .. panel.need)
                setLabel("x", lblNext, "Next step: " .. panel.nextStep)
                local cash = getMoney()
                setLabel("m", lblCash, "Cash: " .. (cash and tostring(math.floor(cash)) or "-"))
                setLabel("d", lblDetected, "Detected: " .. panel.detected)
                task.wait(0.5)
            end
        end)

        task.spawn(function()
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer
            while alive do
                task.wait(0.25)
                local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
                local resultsUI = playerGui and playerGui:FindFirstChild("ResultsUI")
                local resultsOpen = resultsUI and resultsUI.Enabled == true
                local waveInstance = workspace:FindFirstChild("_wave_num")
                local wave = waveInstance and tonumber(waveInstance.Value) or 0

                if resultsOpen then
                    levelInfoCache = nil
                    autoHandled = true
                    if isPlaying then
                        isPlaying = false
                        panel.status = "Stopped: results screen detected"
                        panel.need = "-"
                        panel.nextStep = "-"
                    end
                    if isRecording then
                        stopRecording()
                        panel.status = "Recording stopped: results screen detected"
                        if ui.recToggle then
                            ui.recToggle:UpdateState(false)
                        end
                    end
                    if ui.playToggle and autoRun then
                        autoRun = false
                        ui.playToggle:UpdateState(false)
                    end
                    panel.detected = "Results screen — macro stopped"
                elseif not waveInstance then
                    levelInfoCache = nil
                    autoHandled = false
                    panel.detected = "Not in a match"
                    if isPlaying then
                        isPlaying = false
                        panel.status = "Stopped: match ended"
                    end
                else
                    local info = getLevelInfo()
                    if info then
                        panel.detected = ("%s | %s | Wave %d"):format(info.mode, info.id, wave)
                    end
                    if wave == 1 and not autoHandled and not isPlaying and not isRecording and autoRun and
                        loadedallscript == true and not resultsOpen then
                        local currentInfo = info or getLevelInfo()
                        if currentInfo then
                            autoHandled = true
                            local file, sourceDesc = getActiveMacroFile()
                            if file then
                                panel.detected = sourceDesc .. " | Wave 1"
                                task.spawn(playMacro, file)
                            else
                                panel.status = ("No macro for %s | %s (map it or select a Record file)"):format(
                                    currentInfo.mode, currentInfo.id)
                            end
                        end
                    end
                end
            end
        end)

        refreshLists()
        modeDD:UpdateSelection("Story")
    end

    OneHubMacro = {
        buildUI = buildUI,
        unload = function()
            alive, isPlaying, isRecording = false, false, false
            if OneHubPlacements then
                OneHubPlacements.cfg.show = false
            end
        end
    }
end

local tabGroups = {
    TabGroup1 = Window:TabGroup()
}

local tabs = {
    Main = tabGroups.TabGroup1:Tab({
        Name = "Main",
        Image = "rbxassetid://10723407389"
    }),
    Farm = tabGroups.TabGroup1:Tab({
        Name = "Farm",
        Image = "rbxassetid://10734923549"
    }),
    Priority = tabGroups.TabGroup1:Tab({
        Name = "Priority",
        Image = "rbxassetid://10734923549"
    }),
    Teams = tabGroups.TabGroup1:Tab({
        Name = "Teams",
        Image = "rbxassetid://10734920149"
    }),
    Cards = tabGroups.TabGroup1:Tab({
        Name = "Cards",
        Image = "rbxassetid://10734907168"
    }),
    AutoPlay = tabGroups.TabGroup1:Tab({
        Name = "Auto Play",
        Image = "rbxassetid://10734923549"
    }),
    Macro = tabGroups.TabGroup1:Tab({
        Name = "Macro",
        Image = "rbxassetid://10735024209"
    }),
    Shop = tabGroups.TabGroup1:Tab({
        Name = "Shop",
        Image = "rbxassetid://10723345518"
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
    MainSection3 = tabs.Main:Section({
        Side = "Left"
    }),
    MainSection4 = tabs.Main:Section({
        Side = "Right"
    }),
    MainSection5 = tabs.Main:Section({
        Side = "Right"
    }),
    MainSection6 = tabs.Farm:Section({
        Side = "Left"
    }),
    MainSection7 = tabs.Farm:Section({
        Side = "Left"
    }),
    MainSection8 = tabs.Farm:Section({
        Side = "Left"
    }),
    MainSection9 = tabs.Farm:Section({
        Side = "Left"
    }),
    MainSection10 = tabs.Farm:Section({
        Side = "Right"
    }),
    MainSection11 = tabs.Farm:Section({
        Side = "Right"
    }),
    MainSection12 = tabs.Farm:Section({
        Side = "Right"
    }),
    MainSection13 = tabs.Farm:Section({
        Side = "Right"
    }),
    PrioritySection1 = tabs.Priority:Section({
        Side = "Left"
    }),
    PrioritySection2 = tabs.Priority:Section({
        Side = "Right"
    }),
    MainSection14 = tabs.Teams:Section({
        Side = "Left"
    }),
    MainSection15 = tabs.Teams:Section({
        Side = "Left"
    }),
    MainSection16 = tabs.Teams:Section({
        Side = "Left"
    }),
    MainSection17 = tabs.Teams:Section({
        Side = "Right"
    }),
    MainSection18 = tabs.Teams:Section({
        Side = "Right"
    }),
    MainSection20 = tabs.Cards:Section({
        Side = "Left"
    }),
    MainSection21 = tabs.AutoPlay:Section({
        Side = "Left"
    }),
    MainSection101 = tabs.AutoPlay:Section({
        Side = "Right"
    }),
    MainSection22 = tabs.AutoPlay:Section({
        Side = "Right"
    }),
    MacroSection1 = tabs.Macro:Section({
        Side = "Left"
    }),
    MacroSection2 = tabs.Macro:Section({
        Side = "Right"
    }),
    MacroSection3 = tabs.Macro:Section({
        Side = "Right"
    }),
    MainSection24 = tabs.Shop:Section({
        Side = "Left"
    }),
    MainSection100 = tabs.Settings:Section({
        Side = "Left"
    })
}

sections.MainSection1:Header({
    Name = "Player"
})

sections.MainSection1:Toggle({
    Name = "Hide Player Info",
    Default = false,
    Callback = function(value)
        hideInfoPlayerEnabled = value
        hideInfoPlayer()
    end
}, "HidePlayerInfo")

sections.MainSection1:Toggle({
    Name = "Auto Walk",
    Default = false,
    Callback = function(value)
        autoWalkEnabled = value
        autoWalk()
    end
}, "AutoWalk")

local Dropdown = sections.MainSection1:Dropdown({
    Name = "Select Quantity of Player",
    Search = true,
    Multi = false,
    Required = false,
    Options = {2, 3, 4, 5, 6},
    Default = None,
    Callback = function(value)
        selecteQuantityPlayer = value
    end
}, "dropdownSelectPlayerQ")

sections.MainSection1:Toggle({
    Name = "Security Mode",
    Default = false,
    Callback = function(value)
        securityModeEnabled = value
        securityMode()
    end
}, "SecurityMode")

sections.MainSection1:Toggle({
    Name = "Delete Map",
    Default = false,
    Callback = function(value)
        deletemapEnabled = value
        deletemap()
    end
}, "DeleteMap")

sections.MainSection1:Toggle({
    Name = "Auto Leave",
    Default = false,
    Callback = function(value)
        autoleaveEnabled = value
        autoleave()
    end
}, "AutoLeave")

sections.MainSection1:Toggle({
    Name = "Auto Replay",
    Default = false,
    Callback = function(value)
        autoreplayEnabled = value
        autoreplay()
    end
}, "AutoReplay")

sections.MainSection1:Toggle({
    Name = "Auto Next",
    Default = false,
    Callback = function(value)
        autonextEnabled = value
        autonext()
    end
}, "AutoNext")

sections.MainSection1:Toggle({
    Name = "Auto Next Portal",
    Default = false,
    Callback = function(value)
        autoNextPortalEnabled = value
        autoNextPortal()
    end
}, "AutoNextPortal")

sections.MainSection1:Toggle({
    Name = "Auto Next Contract",
    Default = false,
    Callback = function(value)
        autoNextContratoEnabled = value
        autoNextContrato()
    end
}, "AutoNextContract")

sections.MainSection1:Toggle({
    Name = "Auto Start",
    Default = false,
    Callback = function(value)
        autostartEnabled = value
        autostart()
    end
}, "AutoStart")

sections.MainSection1:Toggle({
    Name = "Auto Skip Wave",
    Default = false,
    Callback = function(value)
        autoskipwaveEnabled = value
        autoskipwave()
    end
}, "AutoSkipWave")

sections.MainSection2:Header({
    Name = "Extra"
})

sections.MainSection2:Toggle({
    Name = "Auto Get Battlepass",
    Default = false,
    Callback = function(value)
        autoGetBattlepassEnabled = value
        autoGetBattlepass()
    end
}, "autoGetBattlepass")

sections.MainSection2:Toggle({
    Name = "Auto Get Quest",
    Default = false,
    Callback = function(value)
        autoGetQuestEnabled = value
        autoGetQuest()
    end
}, "autoGetQuest")

sections.MainSection2:Toggle({
    Name = "Disable Notifications",
    Default = false,
    Callback = function(value)
        disableNotificationsEnabled = value
        disableNotifications()
    end
}, "DisableNotifications")

sections.MainSection2:Toggle({
    Name = "Place In Red Zones",
    Default = false,
    Callback = function(value)
        placeInRedZonesEnabled = value
        placeInRedZones()
    end
}, "PlaceInRedZones")

sections.MainSection2:Toggle({
    Name = "Show Info Units",
    Default = false,
    Callback = function(value)
        showInfoUnitsEnabled = value
        showInfoUnits()
    end
}, "ShowInfoUnits")

sections.MainSection2:Toggle({
    Name = "Friends Only",
    Default = false,
    Callback = function(value)
        selectedFriendsOnly = value
    end
}, "FriendsOnly")

sections.MainSection2:Toggle({
    Name = "Auto Give Presents",
    Default = false,
    Callback = function(value)
        autoGivePresentsEnabled = value
        autoGivePresents()
    end
}, "AutoGivePresents")

sections.MainSection2:Toggle({
    Name = "Dupe Griffith",
    Default = false,
    Callback = function(value)
        dupeGriffithEnabled = value
        dupeGriffith()
    end
}, "DupeGriffith")

sections.MainSection2:Toggle({
    Name = "Dupe Vegeto",
    Default = false,
    Callback = function(value)
        dupeVegetoEnabled = value
        dupeVegeto()
    end
}, "DupeVegeto")

sections.MainSection2:Button({
    Name = "Reedem Codes",
    Callback = function()
        task.spawn(function()
            local codes = {"ASSASSIN", "APRILFOOLS", "UPDATESOON5189", "DUNGEONS"}
            local claim = RS:WaitForChild("Remotes"):WaitForChild("ClaimCode")
            for _, code in ipairs(codes) do
                claim:InvokeServer(code)
                task.wait(0.5)
            end
        end)
    end
})

sections.MainSection4:Header({
    Name = "Passiva"
})

local Dropdown = sections.MainSection4:Dropdown({
    Name = "Select Unit",
    Multi = false,
    Search = true,
    Required = false,
    Options = ValuesUnitId,
    Default = None,
    Callback = function(value)
        selectedUnitToRoll = value and value:match(".* | .* | (.+)")
    end
}, "RollUnit")

local Dropdown = sections.MainSection4:Dropdown({
    Name = "Select Passive",
    Search = true,
    Multi = true,
    Required = false,
    Options = passivesValues,
    Default = None,
    Callback = function(value)
        selectedPassiveToRoll = value
    end
}, "dropdownSelectPassiveToRoll")

sections.MainSection4:Toggle({
    Name = "Auto Roll",
    Default = false,
    Callback = function(value)
        autoRollPassiveEnabled = value
        autoRollPassive()
    end
}, "autoRoll")

sections.MainSection5:Header({
    Name = "Feed"
})

local Dropdown = sections.MainSection5:Dropdown({
    Name = "Select Unit",
    Search = true,
    Multi = false,
    Required = false,
    Options = ValuesUnitId,
    Default = None,
    Callback = function(value)
        selectedUnitToFeed = value and value:match(".* | .* | (.+)")
    end
}, "FeedUnit")

local Dropdown = sections.MainSection5:Dropdown({
    Name = "Select Unit to Feed",
    Search = true,
    Multi = true,
    Required = false,
    Options = ValuesItemsToFeed,
    Default = None,
    Callback = function(value)
        selectedFeed = value
    end
}, "dropdownSelectItemsToFeed")

sections.MainSection5:Toggle({
    Name = "Auto Feed",
    Default = false,
    Callback = function(value)
        autoFeedEnabled = value
        autoFeed()
    end
}, "AutoFeed")

sections.MainSection3:Header({
    Name = "Webhook"
})

sections.MainSection3:Input({
    Name = "Webhook URL",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "All",
    Callback = function(value)
        urlwebhook = value
    end,
    onChanged = function(value)
        urlwebhook = value
    end
}, "WebhookURL")

sections.MainSection3:Input({
    Name = "User ID",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        pingUserId = value
    end,
    onChanged = function(value)
        pingUserId = value
    end
}, "pingUser@")

sections.MainSection3:Toggle({
    Name = "Send Webhook when finish game",
    Default = false,
    Callback = function(value)
        webhookEnabled = value
        if value then
            webhook()
        end
    end
}, "WebhookFinishGame")

sections.MainSection3:Toggle({
    Name = "Ping user",
    Default = false,
    Callback = function(value)
        pingUser = value
    end
}, "pingUser")

sections.MainSection3:Button({
    Name = "Test Webhook",
    Callback = function()
        testWebhook()
    end
})

sections.MainSection6:Header({
    Name = "Portal"
})

local Dropdown = sections.MainSection6:Dropdown({
    Name = "Select Portal",
    Search = true,
    Multi = false,
    Required = false,
    Options = PortalMapValues,
    Default = None,
    Callback = function(value)
        selectedPortalMap = value
    end
}, "dropdownPortalMap")

local Dropdown = sections.MainSection6:Dropdown({
    Name = "Select Tier",
    Multi = true,
    Required = false,
    Options = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18",
               "19", "20"},
    Default = None,
    Callback = function(value)
        selectedTierPortal = value
    end
}, "dropdownTierPortal")

local Dropdown = sections.MainSection6:Dropdown({
    Name = "Select Ignore Difficulty",
    Search = true,
    Multi = true,
    Required = false,
    Options = challengeValues,
    Default = None,
    Callback = function(value)
        selectedPortalDiff = value
    end
}, "dropdownSelectChallengePortal")

local Dropdown = sections.MainSection6:Dropdown({
    Name = "Select Ignore Dmg bonus",
    Search = true,
    Multi = true,
    Required = false,
    Options = dmgBonus,
    Default = None,
    Callback = function(value)
        selectedIgnoreDmgBonus = value
    end
}, "dropdownIgnoreDmgBonusPortal")

sections.MainSection6:Toggle({
    Name = "Auto Open Portal",
    Default = false,
    Callback = function(value)
        autoEnterPortalEnabled = value
        autoEnterPortal()
    end
}, "AutoEnterPortal")

sections.MainSection7:Header({
    Name = "Matchmaking"
})

local Dropdown = sections.MainSection7:Dropdown({
    Name = "Select Map",
    Search = true,
    Multi = false,
    Required = false,
    Options = ChallengeMapValues,
    Default = None,
    Callback = function(value)
        selectedMatchmakingMap = value
    end
}, "dropdownMatchmakingMap")

sections.MainSection7:Toggle({
    Name = "Auto Matchmaking",
    Default = false,
    Callback = function(value)
        AutoMatchmakingEnabled = value
        AutoMatchmaking()
    end
}, "AutoMatchmaking")

sections.MainSection8:Header({
    Name = "Contract"
})

local Dropdown = sections.MainSection8:Dropdown({
    Name = "Select Tier",
    Multi = true,
    Required = false,
    Options = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
               "20"},
    Default = None,
    Callback = function(value)
        selectedTierContract = value
    end
}, "dropdownSelectTierContract")

local Dropdown = sections.MainSection8:Dropdown({
    Name = "Select Ignore Challenge",
    Search = true,
    Multi = true,
    Required = false,
    Options = challengeValues,
    Default = None,
    Callback = function(value)
        selectedIgnoreContractChallenge = value
    end
}, "dropdownSelectIgnoreChallengeContract")

sections.MainSection8:Toggle({
    Name = "Auto Matchmaking Contract",
    Default = false,
    Callback = function(value)
        autoContractMatchmakingEnabled = value
        autoContractMatchmaking()
    end
}, "AutoMatchmakingContract")

sections.MainSection8:Toggle({
    Name = "Auto Contract",
    Default = false,
    Callback = function(value)
        autoContractEnabled = value
        autoContract()
    end
}, "autoContract")

local Dropdown = sections.MainSection8:Dropdown({
    Name = "Select Player",
    Search = true,
    Multi = true,
    Required = false,
    Options = ValuesPlayersName,
    Default = None,
    Callback = function(value)
        selectedPlayerToJoin = value
    end
}, "drodpownPlayerToJoin")

sections.MainSection9:Header({
    Name = "Others"
})

sections.MainSection9:Toggle({
    Name = "Hard Inf Castle",
    Default = false,
    Callback = function(value)
        selectedHardInfCastleEnabled = value
    end
}, "HardInfCastle")

sections.MainSection9:Toggle({
    Name = "Auto Enter Inf Castle",
    Default = false,
    Callback = function(value)
        autoEnterInfiniteCastleEnabled = value
        autoEnterInfiniteCastle()
    end
}, "AutoEnterInfCastle")

sections.MainSection9:Toggle({
    Name = "Auto Join Cursed Womb",
    Default = false,
    Callback = function(value)
        autoJoinCursedWombEnabled = value
        autoJoinCursedWomb()
    end
}, "AutoJoinCursedWomb")

sections.MainSection9:Toggle({
    Name = "Auto Join Player",
    Default = false,
    Callback = function(value)
        autoJoinPlayerEnabled = value
        autoJoinPlayer()
    end
}, "AutoJoinPlayer")

sections.MainSection10:Header({
    Name = "Story"
})

local Dropdown = sections.MainSection10:Dropdown({
    Name = "Select Story Map",
    Search = true,
    Multi = false,
    Required = false,
    Options = storyMapValues,
    Default = None,
    Callback = function(value)
        selectedMap = value
    end
}, "dropdownStoryMap")

local Dropdown = sections.MainSection10:Dropdown({
    Name = "Select Difficulty",
    Multi = false,
    Required = false,
    Options = {"Normal", "Hard"},
    Default = None,
    Callback = function(value)
        selectedDifficulty = value
    end
}, "dropdownSelectDifficultyStory")

local Dropdown = sections.MainSection10:Dropdown({
    Name = "Select Act",
    Multi = false,
    Required = false,
    Options = {"1", "2", "3", "4", "5", "6", "Infinite"},
    Default = None,
    Callback = function(value)
        selectedAct = value
    end
}, "dropdownSelectActStory")

sections.MainSection10:Toggle({
    Name = "Auto Enter",
    Default = false,
    Callback = function(value)
        autoEnterEnabled = value
        autoEnter()
    end
}, "AutoEnter")

sections.MainSection10:Toggle({
    Name = "Auto Join Last Story",
    Default = false,
    Callback = function(value)
        autoJoinLastStoryEnabled = value
        if value then
            task.spawn(autoJoinLastStoryFunction)
        end
    end
}, "AutoJoinLastStory")

sections.MainSection10:Toggle({
    Name = "World Skip",
    Default = false,
    Callback = function(value)
        worldSkipEnabled = value
        if value then
            invokeWorldSkipForSelectedStoryAuto()
        end
    end
}, "WorldSkip")

sections.MainSection11:Header({
    Name = "Challenge"
})

local Dropdown = sections.MainSection11:Dropdown({
    Name = "Select Map",
    Search = true,
    Multi = true,
    Required = false,
    Options = ChallengeMapValues,
    Default = None,
    Callback = function(value)
        selectedMapChallenges = value
    end
}, "dropdownChallengeMap")

local Dropdown = sections.MainSection11:Dropdown({
    Name = "Select Difficulty",
    Search = true,
    Multi = true,
    Required = false,
    Options = challengeValues,
    Default = None,
    Callback = function(value)
        selectedChallengesDiff = value
    end
}, "dropdownSelectChallenge")

sections.MainSection11:Toggle({
    Name = "Auto Enter Challenge",
    Default = false,
    Callback = function(value)
        autoEnterChallengeEnabled = value
        autoEnterChallenge()
    end
}, "AutoEnterChallenge")

sections.MainSection11:Toggle({
    Name = "Auto Enter Daily Challenge",
    Default = false,
    Callback = function(value)
        autoEnterDailyChallengeEnabled = value
        autoEnterDailyChallenge()
    end
}, "AutoEnterDailyChallenge")

sections.MainSection11:Toggle({
    Name = "Auto Matchmaking Daily Challenge",
    Default = false,
    Callback = function(value)
        autoMatchmakingDailyChallengeEnabled = value
        autoMatchmakingDailyChallenge()
    end
}, "AutoMatchmakingDailyChallenge")

sections.MainSection12:Header({
    Name = "Raid"
})

local Dropdown = sections.MainSection12:Dropdown({
    Name = "Select Map",
    Search = true,
    Multi = false,
    Required = false,
    Options = ChallengeMapValues,
    Default = None,
    Callback = function(value)
        selectedRaidMap = value
    end
}, "dropdownSelectRaid")

sections.MainSection12:Toggle({
    Name = "Auto Enter Raid",
    Default = false,
    Callback = function(value)
        autoEnterRaidEnabled = value
        autoEnterRaid()
    end
}, "AutoEnterRaid")

sections.MainSection13:Header({
    Name = "Legend Stage"
})

local Dropdown = sections.MainSection13:Dropdown({
    Name = "Select Map",
    Search = true,
    Multi = false,
    Required = false,
    Options = ChallengeMapValues,
    Default = None,
    Callback = function(value)
        selectedLegendStageMap = value
    end
}, "dropdownSelectLegendStage")

sections.MainSection13:Toggle({
    Name = "Auto Enter Legend Stage",
    Default = false,
    Callback = function(value)
        autoEnterLegendStageEnabled = value
        autoEnterLegendStage()
    end
}, "AutoEnterLegendStage")

sections.MainSection14:Header({
    Name = "Story & Infinite"
})

local Dropdown = sections.MainSection14:Dropdown({
    Name = "Select Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamStoryInf = value
        if selectedTeamStoryInf then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectStoryInfiniteMagic")

sections.MainSection15:Header({
    Name = "Infinite Tower"
})

local Dropdown = sections.MainSection15:Dropdown({
    Name = "Select Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamInfTower = value
        if selectedTeamInfTower then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectInfTowerMagic")

sections.MainSection16:Header({
    Name = "Contract"
})

local Dropdown = sections.MainSection16:Dropdown({
    Name = "Select Physic Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamPhysicContract = value
        if selectedTeamPhysicContract then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectContractPhysic")

local Dropdown = sections.MainSection16:Dropdown({
    Name = "Select Magic Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamMagicContract = value
        if selectedTeamMagicContract then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectContractMagic")

sections.MainSection17:Header({
    Name = "Challenge & Daily Challenge"
})

local Dropdown = sections.MainSection17:Dropdown({
    Name = "Select Physic Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamPhysicChallengeDailyChallenge = value
        if selectedTeamPhysicChallengeDailyChallenge then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectDailyChallengeChallengePhysic")

local Dropdown = sections.MainSection17:Dropdown({
    Name = "Select Magic Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamMagicChallengeDailyChallenge = value
        if selectedTeamMagicChallengeDailyChallenge then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectDailyChallengeChallengeMagic")

local Dropdown = sections.MainSection17:Dropdown({
    Name = "Select Team For Normal Challenge",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamChallengeDailyChallenge = value
        if selectedTeamChallengeDailyChallenge then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectDailyChallengeChallenge")

sections.MainSection18:Header({
    Name = "Raid"
})

local Dropdown = sections.MainSection18:Dropdown({
    Name = "Select Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamRaid = value
        if selectedTeamRaid then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectRaidMagic")

sections.MainSection18:Header({
    Name = "Portal"
})

local Dropdown = sections.MainSection18:Dropdown({
    Name = "Select Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamPortal = value
        if selectedTeamPortal then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectPortal")

sections.MainSection18:Header({
    Name = "Legend Stage"
})

local Dropdown = sections.MainSection18:Dropdown({
    Name = "Select Team",
    Multi = false,
    Required = false,
    Options = {'1', '2', '3', '4', '5', '6'},
    Default = None,
    Callback = function(value)
        selectedTeamlegend = value
        if selectedTeamlegend then
            autoEquipTeamEnabled = true
            autoEquipTeam()
        end
    end
}, "dropdownSelectPortal")

sections.MainSection20:Header({
    Name = "Card Picker"
})

local Dropdown = sections.MainSection20:Dropdown({
    Name = "Select Buff Priority",
    Search = true,
    Multi = true,
    Required = false,
    Options = Cards.Buff,
    Default = None,
    Callback = function(value)
        UpdatePriorityList("Buff", value)
    end
}, "dropdownBuffPriority")

local Dropdown = sections.MainSection20:Dropdown({
    Name = "Select Debuff Priority",
    Search = true,
    Multi = true,
    Required = false,
    Options = Cards.Debuff,
    Default = None,
    Callback = function(value)
        UpdatePriorityList("Debuff", value)
    end
}, "dropdownDebuffPriority")

sections.MainSection20:Toggle({
    Name = "Auto Card",
    Default = false,
    Callback = function(value)
        autoChooseCardEnabled = value
        if value then
            autoChooseCard()
        end
    end
}, "AutoCard")

sections.MainSection20:Toggle({
    Name = "Focus Buff",
    Default = false,
    Callback = function(value)
        focusBuffEnabled = value
    end
}, "FocusBuff")

sections.MainSection20:Toggle({
    Name = "Focus Debuff",
    Default = false,
    Callback = function(value)
        focusDebuffEnabled = value
    end
}, "FocusDebuff")

sections.MainSection21:Header({
    Name = "Unit"
})

sections.MainSection21:Input({
    Name = "Start Place at x Wave",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        selectedWaveToPlace = value
    end,
    onChanged = function(value)
        selectedWaveToPlace = value
    end
}, "inputAutoPlaceWaveX")

sections.MainSection21:Slider({
    Name = "Distance Percentage",
    Default = distancePercentage or 50,
    Minimum = 0,
    Maximum = 100,
    DisplayMethod = "Percent",
    Precision = 1,
    Callback = function(Value)
        local o = MacLib.Options.distancePercentage
        distancePercentage = math.round(tonumber(o and o.Value or Value) or 50)
    end
}, "distancePercentage")
OneHubSliderSync = OneHubSliderSync or {}
OneHubSliderSync.distancePercentage = function()
    local o = MacLib.Options.distancePercentage
    if o then
        distancePercentage = math.round(o.Value)
    end
end

sections.MainSection21:Slider({
    Name = "Ground Percentage",
    Default = GroundPercentage or 50,
    Minimum = 0,
    Maximum = 100,
    DisplayMethod = "Percent",
    Precision = 1,
    Callback = function(Value)
        local o = MacLib.Options.GroundPercentage
        GroundPercentage = math.round(tonumber(o and o.Value or Value) or 50)
    end
}, "GroundPercentage")
OneHubSliderSync = OneHubSliderSync or {}
OneHubSliderSync.GroundPercentage = function()
    local o = MacLib.Options.GroundPercentage
    if o then
        GroundPercentage = math.round(o.Value)
    end
end

sections.MainSection21:Slider({
    Name = "Hill Percentage",
    Default = HillPercentage or 50,
    Minimum = 0,
    Maximum = 100,
    DisplayMethod = "Percent",
    Precision = 1,
    Callback = function(Value)
        local o = MacLib.Options.HillPercentage
        HillPercentage = math.round(tonumber(o and o.Value or Value) or 50)
    end
}, "HillPercentage")
OneHubSliderSync = OneHubSliderSync or {}
OneHubSliderSync.HillPercentage = function()
    local o = MacLib.Options.HillPercentage
    if o then
        HillPercentage = math.round(o.Value)
    end
end

sections.MainSection21:Toggle({
    Name = "Show Placements",
    Default = false,
    Callback = function(value)
        local api = OneHubPlacements
        if not api then
            return
        end
        api.cfg.show = value
        if value and not api.getSet() then
            Window:Notify({
                Title = Window.Settings.Title,
                Description = "No lane found yet - placements will appear when a match starts",
                Lifetime = 5
            })
        end
    end
}, "ShowPlacements")

local slotOptions = {"Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6"}
local function fillSlotSet(v, target)
    for k in pairs(target) do
        target[k] = nil
    end
    if type(v) == "table" then
        for name, on in pairs(v) do
            local label = (on == true) and name or on
            local n = tonumber(tostring(label):match("%d+"))
            if n then
                target[n] = true
            end
        end
    end
end

        sections.MainSection101:Header({
            Name = "Priority Place per slot"
        })


for slot = 1, 6 do
    sections.MainSection101:Slider({
        Name = "Priority Place - Slot " .. slot .. "",
        Default = 0,
        Minimum = 0,
        Maximum = 6,
        DisplayMethod = "Number",
        Precision = 0,
        Callback = function(v)
            local o = MacLib.Options["PriorityPlaceSlot" .. slot]
            v = math.floor(tonumber(o and o.Value or v) or 0)
            OneHubPlacements.cfg.priority[slot] = v > 0 and v or nil
        end
    }, "PriorityPlaceSlot" .. slot)
    OneHubSliderSync = OneHubSliderSync or {}
    OneHubSliderSync["PriorityPlaceSlot" .. slot] = function()
        local o = MacLib.Options["PriorityPlaceSlot" .. slot]
        local v = math.floor(tonumber(o and o.Value) or 0)
        OneHubPlacements.cfg.priority[slot] = v > 0 and v or nil
    end
end

        sections.MainSection101:Header({
            Name = "Max Place per slot (0 = disabled)"
        })

for slot = 1, 6 do
    sections.MainSection101:Slider({
        Name = "Max Place - Slot " .. slot,
        Default = 0,
        Minimum = 0,
        Maximum = 20,
        DisplayMethod = "Number",
        Precision = 0,
        Callback = function(v)
            local o = MacLib.Options["MaxPlaceSlot" .. slot]
            OneHubPlacements.cfg.maxPlace[slot] = math.floor(tonumber(o and o.Value or v) or 0)
        end
    }, "MaxPlaceSlot" .. slot)
    OneHubSliderSync = OneHubSliderSync or {}
    OneHubSliderSync["MaxPlaceSlot" .. slot] = function()
        local o = MacLib.Options["MaxPlaceSlot" .. slot]
        OneHubPlacements.cfg.maxPlace[slot] = math.floor(tonumber(o and o.Value) or 0)
    end
end

        sections.MainSection101:Header({
            Name = "Max Upgrade per slot"
        })

for slot = 1, 6 do
    sections.MainSection101:Slider({
        Name = "Max Upgrade - Slot " .. slot .. "",
        Default = 0,
        Minimum = 0,
        Maximum = 20,
        DisplayMethod = "Number",
        Precision = 0,
        Callback = function(v)
            local o = MacLib.Options["MaxUpgradeSlot" .. slot]
            OneHubPlacements.cfg.maxUpgrade[slot] = math.floor(tonumber(o and o.Value or v) or 0)
        end
    }, "MaxUpgradeSlot" .. slot)
    OneHubSliderSync = OneHubSliderSync or {}
    OneHubSliderSync["MaxUpgradeSlot" .. slot] = function()
        local o = MacLib.Options["MaxUpgradeSlot" .. slot]
        OneHubPlacements.cfg.maxUpgrade[slot] = math.floor(tonumber(o and o.Value) or 0)
    end
end

sections.MainSection21:Toggle({
    Name = "Auto Place",
    Default = false,
    Callback = function(value)
        autoPlaceEnabled = value
        if value then
            distancePercentage = MacLib.Options.distancePercentage.Value
            GroundPercentage = MacLib.Options.GroundPercentage.Value
            HillPercentage = MacLib.Options.HillPercentage.Value
            autoPlace()
        end
    end
}, "AutoPlace")

sections.MainSection21:Toggle({
    Name = "Only Start Place in X Wave",
    Default = false,
    Callback = function(value)
        OnlyautoPlaceEnabled = value
    end
}, "OnlyStartPlaceInXWave")

sections.MainSection21:Input({
    Name = "Start Upgrade at x Wave",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        selectedWaveToUpgrade = value
    end,
    onChanged = function(value)
        selectedWaveToUpgrade = value
    end
}, "inputAutoUpgradeWaveX")

sections.MainSection21:Toggle({
    Name = "Focus Farm",
    Default = false,
    Callback = function(value)
        focusFarm = value
    end
}, "FocusInFarm")

sections.MainSection21:Toggle({
    Name = "Focus Griffith",
    Default = false,
    Callback = function(value)
        focusGriffith = value
    end
}, "FocusInGriffith")

sections.MainSection21:Toggle({
    Name = "Auto Upgrade",
    Default = false,
    Callback = function(value)
        autoUpgradeEnabled = value
        autoUpgrade()
    end
}, "AutoUpgrade")

sections.MainSection21:Toggle({
    Name = "Only Upgrade in X Wave",
    Default = false,
    Callback = function(value)
        onlyupgradeinXwaveEnabled = value
    end
}, "OnlyUpgradeInXWave")

sections.MainSection21:Input({
    Name = "Start Sell at x Wave",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        selectedWaveToSell = value
    end,
    onChanged = function(value)
        selectedWaveToSell = value
    end
}, "inputAutoSellWaveX")

sections.MainSection21:Toggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(value)
        autoSellEnabled = value
        autoSell()
    end
}, "AutoSell")

sections.MainSection21:Input({
    Name = "Only Sell Farm in X Wavee",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        onlysellFarminXwave = value
    end,
    onChanged = function(value)
        onlysellFarminXwave = value
    end
}, "OnlySellFarmInXWave")

sections.MainSection21:Toggle({
    Name = "Auto Sell Farm",
    Default = false,
    Callback = function(value)
        autoSellFarmWaveXEnabled = value
        autoSellFarmWaveX()
    end
}, "autoSellFarmWaveX")

sections.MainSection21:Input({
    Name = "Auto Leave at x Wave",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        selectedWaveToLeave = value
    end,
    onChanged = function(value)
        selectedWaveToLeave = value
    end
}, "inputAutoSellWaveX")

sections.MainSection21:Toggle({
    Name = "Auto Leave",
    Default = false,
    Callback = function(value)
        autoLeaveInXWaveEnabled = value
        autoLeaveInXWave()
    end
}, "AutoLeaveInXWave")

sections.MainSection22:Header({
    Name = "Skill"
})

sections.MainSection22:Input({
    Name = "Start Skill at x Wave",
    Placeholder = "Press enter after paste",
    AcceptedCharacters = "Number",
    Callback = function(value)
        selectedWaveToUniversalSkill = value
    end,
    onChanged = function(value)
        selectedWaveToUniversalSkill = value
    end
}, "inputAutoSkillWaveX")

sections.MainSection22:Toggle({
    Name = "Auto Universal Skill",
    Default = false,
    Callback = function(value)
        universalSkillEnabled = value
        universalSkill()
    end
}, "AutoUniversalSkill")

sections.MainSection22:Toggle({
    Name = "Only Universal Skill in X Wave",
    Default = false,
    Callback = function(value)
        universalSkillinXWaveEnabled = value
    end
}, "OnlyUniversalSkillinXWave")

sections.MainSection22:Toggle({
    Name = "Auto Sacrifice Griffith",
    Default = false,
    Callback = function(value)
        autoSacrificeGriffithEnabled = value
        autoSacrificeGriffith()
    end
}, "AutoSacrificeGriffith")

sections.MainSection22:Toggle({
    Name = "Auto Buff Erwin",
    Default = false,
    Callback = function(value)
        toggle = value
        if toggle then
            UseActiveAttackE()
        end
    end
}, "AutoBuffErwin")

sections.MainSection22:Toggle({
    Name = "Auto Buff Wenda",
    Default = false,
    Callback = function(value)
        toggle2 = value
        if toggle2 then
            UseActiveAttackW()
        end
    end
}, "AutoBuffWenda")

sections.MainSection22:Toggle({
    Name = "Auto Buff Leafy",
    Default = false,
    Callback = function(value)
        toggle3 = value
        if toggle3 then
            UseActiveAttackL()
        end
    end
}, "AutoBuffLeafy")

OneHubMacro.buildUI(sections.MacroSection1, sections.MacroSection2, sections.MacroSection3)

sections.MainSection24:Header({
    Name = "Shop"
})

local Dropdown = sections.MainSection24:Dropdown({
    Name = "Select Capsule to Open",
    Search = true,
    Multi = false,
    Required = false,
    Options = ValuesCapsules,
    Default = None,
    Callback = function(value)
        selectedCapsule = value
    end
}, "dropdownSelectCapsule")

sections.MainSection24:Toggle({
    Name = "Auto Open Capsule",
    Default = false,
    Callback = function(value)
        autoOpenCapsuleEnabled = value
        autoOpenCapsule()
    end
}, "AutoOpenCapsule")

local Dropdown = sections.MainSection24:Dropdown({
    Name = "Select Shard to Craft",
    Search = true,
    Multi = false,
    Required = false,
    Options = shardsValues,
    Default = None,
    Callback = function(value)
        selectedShardtoCraft = value
    end
}, "dropdownSelectShardToCraft")

sections.MainSection24:Toggle({
    Name = "Auto Craft Shards",
    Default = false,
    Callback = function(value)
        autoCraftShardEnabled = value
        autoCraftShard()
    end
}, "autoCraftShards")

local Dropdown = sections.MainSection24:Dropdown({
    Name = "Select Item",
    Search = true,
    Multi = false,
    Required = false,
    Options = ValuesItemsToFeed,
    Default = None,
    Callback = function(value)
        selectedItemToBuy = value
    end
}, "dropdownSelectItemToBuy")

sections.MainSection24:Toggle({
    Name = "Auto Buy",
    Default = false,
    Callback = function(value)
        autoBuyEnabled = value
        autoBuy()
    end
}, "AutoBuy")

sections.MainSection24:Toggle({
    Name = "Auto Roll Sakamoto Event",
    Default = false,
    Callback = function(value)
        autoRollSakamotoBannerEnabled = value
        autoRollSakamotoBanner()
    end
}, "autoRollSakamotoBanner")

MacLib:SetFolder("Maclib")

sections.MainSection100:Toggle({
    Name = "Auto Execute",
    Default = false,
    Callback = function(value)
        aeuatFunction(value)
    end
}, "AutoExecuteToggle")

sections.MainSection100:Toggle({
    Name = "Auto Reconnect",
    Default = false,
    Callback = function(value)
        autoReconnect(value)
    end
}, "AutoReconnectToggle")

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
        local o = MacLib.Options.ChangeUISizeSlider
        MacLib:changeUISize(o and o.Value or Value)
    end
}, "ChangeUISizeSlider")
OneHubSliderSync = OneHubSliderSync or {}
OneHubSliderSync.ChangeUISizeSlider = function()
    local o = MacLib.Options.ChangeUISizeSlider
    if o then
        MacLib:changeUISize(o.Value)
    end
end

;(function()
    local LOBBY_PLACE_ID = 8304191830
    local RS = game:GetService("ReplicatedStorage")

    local priorityEnabled = false
    local priorityWait = 10
    local priorityLoopRunning = false
    local slotValues = {}

    local function c2s(name)
        return RS:WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild(name)
    end

    local function invoke(name, ...)
        local args = table.pack(...)
        return pcall(function()
            return c2s(name):InvokeServer(table.unpack(args, 1, args.n))
        end)
    end

    local attempts = {
        ["Portal"] = function()
            if not selectedPortalMap or selectedPortalMap == "None" then
                return false
            end
            local Loader = require(RS.src.Loader)
            local up = debug.getupvalues(Loader.init)
            local stats = up[11]["StatsServiceClient"]
            local items = stats.module.session.inventory.inventory_profile_data.unique_items
            local tiers = selList(selectedTierPortal)
            local ignoreDmg = selList(selectedIgnoreDmgBonus)
            if type(items) ~= "table" then
                return false
            end
            for _, item in pairs(items) do
                local data = item.uuid and item._unique_item_data
                local portal = data and data._unique_portal_data
                if portal and portal.level_id and portal.portal_depth then
                    local dmgType = portal._weak_against and portal._weak_against[1]
                        and tostring(portal._weak_against[1].damage_type)
                    local tierOk = (#tiers == 0) or selHas(tiers, portal.portal_depth)
                    local dmgOk = not (dmgType and selHas(ignoreDmg, dmgType) and dmgType ~= "None")
                    if tostring(portal.level_id) == tostring(selectedPortalMap) and tierOk and dmgOk then
                        invoke("save_notifications_state", "Items", 0)
                        local ok = invoke("use_portal", tostring(item.uuid),
                            (selectedFriendsOnly and {friends_only = true}) or nil)
                        return ok
                    end
                end
            end
            return false
        end,

        ["Matchmaking"] = function()
            if not selectedMatchmakingMap or selectedMatchmakingMap == "None" then
                return false
            end
            return (invoke("request_matchmaking", selectedMatchmakingMap))
        end,

        ["Contract Matchmaking"] = function()
            local idx = findContractSlot()
            if not idx then
                return false
            end
            return (invoke("request_matchmaking", "__EVENT_CONTRACT_Sakamoto:" .. tostring(idx)))
        end,

        ["Auto Contract"] = function()
            local idx = findContractSlot()
            if not idx then
                return false
            end
            if selectedFriendsOnly == true then
                return (invoke("open_event_contract_portal", tostring(idx), {friends_only = true}))
            end
            return (invoke("open_event_contract_portal", tostring(idx)))
        end,

        ["Infinite Castle"] = function()
            local Loader = require(RS.src.Loader)
            local up = debug.getupvalues(Loader.init)
            local stats = up[11]["StatsServiceClient"]
            local floor = (stats and stats.module and stats.module.session and stats.module.session.profile_data
                and stats.module.session.profile_data.level_data
                and stats.module.session.profile_data.level_data.infinite_tower
                and stats.module.session.profile_data.level_data.infinite_tower.floor_reached) or 1
            local mode = selectedHardInfCastleEnabled and "Hard" or "Normal"
            return (invoke("request_start_infinite_tower", floor, mode))
        end,

        ["Cursed Womb"] = function()
            invoke("save_notifications_state", "Items", 0)
            task.wait(0.5)
            return (invoke("request_join_lobby", "_lobbytemplate_event222", {selected_key = "key_jjk_finger"}))
        end,

        ["Join Player"] = function()
            return joinPlayerLobby()
        end,

        ["Story"] = function()
            return tryJoinStory()
        end,

        ["Last Story"] = function()
            if type(selectedMap) ~= "string" or selectedMap == "" or selectedMap == "None"
                or not selectedDifficulty or selectedDifficulty == "None"
                or not selectedAct or selectedAct == "None" then
                return false
            end
            local targetMap, targetAct = getNextStoryActAuto()
            local lobby = "_lobbytemplategreen1"
            local ok = invoke("request_join_lobby", lobby)
            if not ok then return false end
            task.wait(1)
            if worldSkipEnabled then
                invokeWorldSkipForMap(targetMap, true)
            end
            task.wait(0.5)
            ok = invoke("request_lock_level", lobby, targetMap .. "_level_" .. tostring(targetAct),
                false, selectedDifficulty)
            if not ok then return false end
            task.wait(1)
            return invoke("request_start_game", lobby)
        end,

        ["Challenge"] = function()
            local lobby = workspace._CHALLENGES.Challenges:FindFirstChild("_lobbytemplate315")
            local level = lobby and lobby:FindFirstChild("Level")
            local challenge = lobby and lobby:FindFirstChild("Challenge")
            if not (level and challenge) then
                return false
            end
            local maps = selList(selectedMapChallenges)
            local diffs = selList(selectedChallengesDiff)
            if selHas(maps, level.Value) and selHas(diffs, challenge.Value) then
                return (invoke("request_join_lobby", "_lobbytemplate315"))
            end
            return false
        end,

        ["Daily Challenge"] = function()
            return (invoke("request_join_lobby", "_lobbytemplate320"))
        end,

        ["Matchmaking Daily Challenge"] = function()
            return (invoke("request_matchmaking", "__DAILY_CHALLENGE"))
        end,

        ["Raid"] = function()
            if not selectedRaidMap or selectedRaidMap == "None" then
                return false
            end
            return joinLobbyAndStart("_lobbytemplate210", selectedRaidMap, selectedFriendsOnly == true, "Hard")
        end,

        ["Legend Stage"] = function()
            if not selectedLegendStageMap or selectedLegendStageMap == "None" then
                return false
            end
            return joinLobbyAndStart("_lobbytemplategreen1", selectedLegendStageMap,
                selectedFriendsOnly == true, "Hard")
        end,
    }

    local farmEnabled = {
        ["Portal"] = function() return autoEnterPortalEnabled == true end,
        ["Matchmaking"] = function() return AutoMatchmakingEnabled == true end,
        ["Contract Matchmaking"] = function() return autoContractMatchmakingEnabled == true end,
        ["Auto Contract"] = function() return autoContractEnabled == true end,
        ["Infinite Castle"] = function() return autoEnterInfiniteCastleEnabled == true end,
        ["Cursed Womb"] = function() return autoJoinCursedWombEnabled == true end,
        ["Join Player"] = function() return autoJoinPlayerEnabled == true end,
        ["Story"] = function() return autoEnterEnabled == true end,
        ["Last Story"] = function() return autoJoinLastStoryEnabled == true end,
        ["Challenge"] = function() return autoEnterChallengeEnabled == true end,
        ["Daily Challenge"] = function() return autoEnterDailyChallengeEnabled == true end,
        ["Matchmaking Daily Challenge"] = function() return autoMatchmakingDailyChallengeEnabled == true end,
        ["Raid"] = function() return autoEnterRaidEnabled == true end,
        ["Legend Stage"] = function() return autoEnterLegendStageEnabled == true end,
    }

    local joinNames = {"Portal", "Matchmaking", "Contract Matchmaking", "Auto Contract", "Infinite Castle",
                       "Cursed Womb", "Join Player", "Story", "Last Story", "Challenge", "Daily Challenge",
                       "Matchmaking Daily Challenge", "Raid", "Legend Stage"}

    local function notify(text)
        warn("[One HUB] Priority Join: " .. text)
        Window:Notify({
            Title = "Priority Join",
            Description = text,
            Lifetime = 4
        })
    end

    local function buildOrder()
        local order, seen = {}, {}
        for i = 1, #joinNames do
            local v = slotValues[i]
            if type(v) == "string" and v ~= "None" and attempts[v] and not seen[v]
                and farmEnabled[v] and farmEnabled[v]() then
                seen[v] = true
                order[#order + 1] = v
            end
        end
        return order
    end

    local function priorityLoop()
        if priorityLoopRunning then
            return
        end
        priorityLoopRunning = true
        local warnedEmpty = false
        while priorityEnabled do
            if loadedallscript == true and game.PlaceId == LOBBY_PLACE_ID then
                local order = buildOrder()
                if #order == 0 then
                    if not warnedEmpty then
                        warnedEmpty = true
                        notify("Nenhum join ativo: escolha as prioridades e ligue o toggle do join na tab Farm.")
                    end
                    task.wait(2)
                else
                    warnedEmpty = false
                    for rank, name in ipairs(order) do
                        if not priorityEnabled or game.PlaceId ~= LOBBY_PLACE_ID then
                            break
                        end
                        local ok, sent = pcall(attempts[name])
                        if ok and sent then
                            notify("Priority " .. rank .. ": tentando " .. name)
                            local t0 = tick()
                            while priorityEnabled and tick() - t0 < priorityWait
                                and game.PlaceId == LOBBY_PLACE_ID do
                                task.wait(0.5)
                            end
                            if game.PlaceId == LOBBY_PLACE_ID and priorityEnabled then
                                notify(name .. " não entrou, indo para a próxima prioridade.")
                            end
                        elseif not ok then
                            warn("[One HUB] Priority Join (" .. name .. "): " .. tostring(sent))
                        end
                        task.wait(0.5)
                    end
                end
            else
                task.wait(1)
            end
        end
        priorityLoopRunning = false
    end

    sections.PrioritySection1:Header({
        Name = "Priority Join"
    })

    sections.PrioritySection1:Toggle({
        Name = "Enable Priority Join",
        Default = false,
        Callback = function(value)
            priorityEnabled = value
            PriorityJoinActive = value
            if value then
                task.spawn(priorityLoop)
            else
                resumeJoinLoops()
            end
        end
    }, "PriorityJoinEnabled")

    sections.PrioritySection1:Slider({
        Name = "Wait before next priority (s)",
        Default = 10,
        Minimum = 3,
        Maximum = 30,
        DisplayMethod = "Value",
        Precision = 0,
        Callback = function(value)
            local o = MacLib.Options.PriorityJoinWait
            priorityWait = tonumber(o and o.Value or value) or 10
        end
    }, "PriorityJoinWait")
    OneHubSliderSync = OneHubSliderSync or {}
    OneHubSliderSync.PriorityJoinWait = function()
        local o = MacLib.Options.PriorityJoinWait
        priorityWait = tonumber(o and o.Value) or 10
    end

    sections.PrioritySection1:Label({
        Text = "Priority 1 é tentado primeiro. Só entram na fila os joins com o toggle ligado na tab Farm; os desligados são pulados. Se não entrar, vai para a próxima prioridade. Com o Priority ligado, os loops individuais do Farm ficam pausados."
    })

    local options = {"None"}
    for _, n in ipairs(joinNames) do
        options[#options + 1] = n
    end

    for i = 1, #joinNames do
        local sec = (i <= 7) and sections.PrioritySection1 or sections.PrioritySection2
        if i == 8 then
            sections.PrioritySection2:Header({
                Name = "Priority Order"
            })
        end
        sec:Dropdown({
            Name = "Priority " .. i,
            Search = true,
            Multi = false,
            Required = false,
            Options = options,
            Default = "None",
            Callback = function(value)
                slotValues[i] = value
            end
        }, "PriorityJoinSlot" .. i)
    end
end)()

tabs.Main:Select()

MacLib:SetFolder("One Hub")
MacLib:SetFolder("One Hub/_AA_")
local GameConfigName = "_AA_"
local configName = player.Name .. GameConfigName
MacLib:LoadConfig(configName)

function syncAllSliders()
    for _, apply in pairs(OneHubSliderSync or {}) do
        apply()
    end
end
syncAllSliders()
task.delay(1, syncAllSliders)
task.delay(3, syncAllSliders)
task.delay(6, syncAllSliders)

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

player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        saveConfigSafe()
    end
end)

Window.onUnloaded(function()
    saveConfigSafe()
    OneHubMacro.unload()
end)

local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = game:GetService("Players").LocalPlayer
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
loadedallscript = true