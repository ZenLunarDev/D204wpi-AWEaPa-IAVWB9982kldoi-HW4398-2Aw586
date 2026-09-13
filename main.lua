--[[
    xEz Hub v1.3.1
    Build a Boat
    Key System: "xEzShop :3"

    - By ZenLunarDev

    Changelog v1.3.1:
    - FIXED: Gold detection (fallback attribute names + retry loop)
    - FIXED: buyChest() no longer reads Gold before leaderstats loads
    - ADDED: Number formatting with comma separator
    - ADDED: Gold debug button in Stats tab
    - FIXED: Crystal Cave solver improvements
]]


-- CONFIG


local SCRIPT_URL = "https://raw.githubusercontent.com/ZenLunarDev/D204wpi-AWEaPa-IAVWB9982kldoi-HW4398-2Aw586/refs/heads/main/main.lua"
local VERSION_URL = "https://raw.githubusercontent.com/ZenLunarDev/D204wpi-AWEaPa-IAVWB9982kldoi-HW4398-2Aw586/refs/heads/main/version.json"
local SCRIPT_VERSION = "1.3.1"
local DISCORD_URL = "https://discord.gg/7MA4RK5aUU"
local CREATOR_NAME = "ZenLunarDev"
local CONFIG_FILE = "xEzHub_config.json"


-- SAFE INIT


if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(0.5)


-- SERVICES


local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local GRAVITY_NORMAL = Workspace.Gravity


-- LOAD FLUENT


local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

if not Fluent then
    error("[xEz Hub] Cannot load Fluent UI")
end


-- GAME CONSTANTS


local CHEST_PRICES = {
    ["Common Chest"] = 5,
    ["Uncommon Chest"] = 15,
    ["Rare Chest"] = 45,
    ["Epic Chest"] = 135,
    ["Legendary Chest"] = 405,
}

local CRYSTAL_PORTAL_PATHS = {
    orange = { "green", "gray" },
    white = { "yellow", "cyan", "black" },
    yellow = { "green", "white", "purple" },
}

local STAGE_HAZARDS = {
    ["BedroomStage"] = { biplane = true },
    ["CrystalCaveStage"] = { stalactite = true, laser = true },
    ["TrenchStage"] = { stalagmite = true, mushroom = true },
}

local TOOL_PRICES = {
    ["Paint Tool"] = 1500,
    ["Binding Tool"] = 2000,
    ["Property Tool"] = 2500,
    ["Scaling Tool"] = 5000,
    ["Trowel Tool"] = 7500,
}


-- STATE


local State = {
    AutoFarm = false,
    Farm24_7 = false,
    GodMode = false,
    AutoCollectCoin = false,
    AutoSkipWave = false,
    FarmSpeed = 900,
    MaxSpeedMode = false,
    StepDelay = 0.02,
    ChestDelay = 0.5,
    ResetDelay = 0.5,
    PostResetDelay = 1.0,
    GravityZero = true,
    FlightHeight = 72,
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 100,
    AntiFling = false,
    AntiKick = false,
    AutoBuyChest = false,
    SelectedChest = "Common Chest",
    AutoBuyCount = 1,
    AntiAFK = true,
    AntiAFKKey = true,
    AutoRejoin = true,
    StaffDetector = true,
    AntiDisconnect = true,
    RejoinDelay = 3,
    BlackScreen = false,
    MemoryCleanup = true,
    FpsBoost = false,
    RenderDistance = 1000,
    LowGraphics = false,
    ShowNotifications = true,
    WebhookURL = "",
    WebhookNotify = false,
    WebhookRichEmbed = true,
    PanicKey = "RightShift",

    AutoCrystalCave = false,
    AutoWildWestSecret = false,
    AutoToxicWasteSecret = false,
    TrackGoldGain = true,
    CurrentStage = "",
    LastGoldValue = 0,
    TotalGoldGained = 0,
    StageRewards = {},

    WinsCount = 0,
    FailsCount = 0,
    SessionStart = tick(),
    LastCleanup = tick(),
    RunTimes = {},
    BestRunTime = 0,
    CurrentRunStart = 0,
    LastRespawn = 0,
    RespawnCount = 0,
    SessionLog = {},
    IsFarming = false
}


-- CONFIG SAVE / LOAD


local SAVEABLE_KEYS = {
    "FarmSpeed", "MaxSpeedMode", "StepDelay", "ChestDelay", "ResetDelay", "PostResetDelay",
    "GravityZero", "FlightHeight", "WalkSpeed", "JumpPower", "InfJump", "NoClip", "Fly",
    "FlySpeed", "AntiFling", "AntiKick", "SelectedChest", "AutoBuyCount", "AntiAFK", "AntiAFKKey",
    "AutoRejoin", "StaffDetector", "AntiDisconnect", "RejoinDelay", "BlackScreen",
    "MemoryCleanup", "FpsBoost", "RenderDistance", "LowGraphics", "ShowNotifications",
    "WebhookURL", "WebhookNotify", "WebhookRichEmbed", "PanicKey",
    "AutoCrystalCave", "AutoWildWestSecret", "AutoToxicWasteSecret", "TrackGoldGain"
}

local function saveConfig()
    if not writefile then return false end
    local data = {}
    for _, key in ipairs(SAVEABLE_KEYS) do
        data[key] = State[key]
    end
    data._version = SCRIPT_VERSION
    data._savedAt = os.time()
    local ok = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
    return ok
end

local function loadConfig()
    if not isfile or not readfile then return false end
    if not isfile(CONFIG_FILE) then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not ok or type(data) ~= "table" then return false end
    for _, key in ipairs(SAVEABLE_KEYS) do
        if data[key] ~= nil then
            State[key] = data[key]
        end
    end
    return true
end

local savePending = false
local function requestSave()
    if savePending then return end
    savePending = true
    task.delay(2, function()
        savePending = false
        saveConfig()
    end)
end

loadConfig()


-- WAYPOINTS


local Waypoints = {
    CFrame.new(-43.6134491, 62.1137619, 672.744934,
        -0.999842644, -0.00183729955, 0.017645346,
        0, 0.994622767, 0.103564225,
        -0.0177407414, 0.103547923, -0.994466245),
    CFrame.new(-60.1504707, 97.4659729, 8767.91406,
        -0.99889338, 0.000705028593, 0.0470264405,
        0, 0.999887645, -0.0149902813,
        -0.047031723, -0.0149736926, -0.998781145),
    CFrame.new(-54.331871, -345.398346, 9488.60645,
        -0.98221302, 0, 0.187770084,
        0, 1, 0,
        -0.187770084, 0, -0.98221302),
}


-- CONNECTIONS + TOKENS


local Connections = {
    AntiAFK = nil, NoClip = nil, GodMode = nil, CharacterAdded = nil,
    TeleportFailed = nil, ErrorMessage = nil, PlayerAdded = nil,
    JumpRequest = nil, AntiAFKKeyLoop = nil, FlyLoop = nil,
    AntiFlingLoop = nil, AntiKickLoop = nil
}

local FarmToken = 0
local BuyToken = 0
local isHopping = false
local isBuyWarned = false
local isFlying = false
local currentTween = nil


-- SESSION LOG


local function addLog(message)
    table.insert(State.SessionLog, {
        time = os.date("%H:%M:%S"),
        message = message
    })
    if #State.SessionLog > 100 then
        table.remove(State.SessionLog, 1)
    end
end


-- GUI PARENT


local cachedGuiParent = nil

local function getGuiParent()
    if cachedGuiParent and cachedGuiParent.Parent then
        return cachedGuiParent
    end
    if gethui and type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            cachedGuiParent = hui
            return hui
        end
    end
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then
        local testOk = pcall(function()
            local test = Instance.new("ScreenGui")
            test.Parent = cg
            test:Destroy()
        end)
        if testOk then
            cachedGuiParent = cg
            return cg
        end
    end
    cachedGuiParent = LocalPlayer:WaitForChild("PlayerGui")
    return cachedGuiParent
end


-- UTILITY


local function notify(title, content, duration)
    if not State.ShowNotifications then return end
    pcall(function()
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    end)
    addLog(title .. ": " .. content)
end

-- v1.3.1: Format number with comma separator
local function formatNumber(n)
    n = tonumber(n) or 0
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    if not character then return nil end
    local h = character:FindFirstChildOfClass("Humanoid")
    if h and h.Parent then return h end
    return nil
end

local function getRoot()
    local character = getCharacter()
    if not character then return nil end
    local r = character:FindFirstChild("HumanoidRootPart")
    if r and r.Parent then return r end
    return nil
end

local function isCharacterReady()
    local character = getCharacter()
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return true
end

local function getRequestFunction()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if http and type(http.request) == "function" then return http.request end
    if syn and type(syn.request) == "function" then return syn.request end
    return nil
end

local function safeWait(seconds, myToken, checkFn)
    local elapsed = 0
    local step = 0.02
    while elapsed < seconds do
        if checkFn and not checkFn() then return false end
        task.wait(step)
        elapsed = elapsed + step
    end
    return true
end

local function formatUptime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function getAverageRunTime()
    if #State.RunTimes == 0 then return 0 end
    local total = 0
    for _, time in ipairs(State.RunTimes) do
        total = total + time
    end
    return total / #State.RunTimes
end

local function getPing()
    local ok, ping = pcall(function()
        local network = Stats:FindFirstChild("Network")
        local serverStats = network and network:FindFirstChild("ServerStatsItem")
        local pingItem = serverStats and serverStats:FindFirstChild("Data Ping")
        return pingItem and pingItem:GetValue() or 0
    end)
    if ok and type(ping) == "number" then
        return math.floor(ping)
    end
    return 0
end


-- v1.3.1: FIXED Gold detection with fallback names


local cachedGoldStat = nil
local cachedGoldStatTime = 0

local function findGoldStat()
    -- Cache for 5 seconds to avoid spamming
    if cachedGoldStat and cachedGoldStat.Parent and (tick() - cachedGoldStatTime) < 5 then
        return cachedGoldStat
    end

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if not leaderstats then
        cachedGoldStat = nil
        return nil
    end

    -- Try common names first
    local possibleNames = {
        "Gold", "gold", "GOLD",
        "Cash", "cash", "CASH",
        "Coins", "coins", "COINS",
        "Money", "money", "MONEY",
        "Currency", "currency"
    }
    for _, name in ipairs(possibleNames) do
        local stat = leaderstats:FindFirstChild(name)
        if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
            cachedGoldStat = stat
            cachedGoldStatTime = tick()
            return stat
        end
    end

    -- Fallback: find any IntValue/NumberValue that looks like currency
    for _, child in ipairs(leaderstats:GetChildren()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            -- Prefer values > 0
            if type(child.Value) == "number" and child.Value > 0 then
                cachedGoldStat = child
                cachedGoldStatTime = tick()
                return child
            end
        end
    end

    -- Last resort: first IntValue/NumberValue found
    for _, child in ipairs(leaderstats:GetChildren()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            cachedGoldStat = child
            cachedGoldStatTime = tick()
            return child
        end
    end

    cachedGoldStat = nil
    return nil
end

local function getCurrentGold()
    local stat = findGoldStat()
    if stat and type(stat.Value) == "number" then
        return stat.Value
    end
    return 0
end

-- v1.3.1: Get gold with retry (waits for leaderstats to load)
local function getCurrentGoldWithRetry(maxAttempts, delayPerAttempt)
    maxAttempts = maxAttempts or 10
    delayPerAttempt = delayPerAttempt or 0.2
    local gold = 0
    for attempt = 1, maxAttempts do
        gold = getCurrentGold()
        if gold > 0 then return gold end
        -- Also wait for leaderstats if not present
        if not LocalPlayer:FindFirstChild("leaderstats") then
            task.wait(delayPerAttempt)
        else
            task.wait(delayPerAttempt)
        end
    end
    return gold
end


-- v1.3.1: Get current stage name


local function getCurrentStageName()
    local stages = Workspace:FindFirstChild("BoatStages")
    if not stages then return nil end
    local normal = stages:FindFirstChild("NormalStages")
    if not normal then return nil end
    local hrp = getRoot()
    if not hrp then return nil end

    local closestStage = nil
    local closestDist = math.huge

    for _, stage in ipairs(normal:GetChildren()) do
        if stage:IsA("Model") and stage.Name ~= "TheEnd" then
            local part = stage:FindFirstChildOfClass("BasePart")
            if part then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < closestDist and dist < 800 then
                    closestDist = dist
                    closestStage = stage.Name
                end
            end
        end
    end

    return closestStage
end


-- v1.3.1: Track Gold gain


local function trackGoldGain()
    if not State.TrackGoldGain then return end
    local currentGold = getCurrentGold()
    if currentGold > State.LastGoldValue then
        local gained = currentGold - State.LastGoldValue
        State.TotalGoldGained = State.TotalGoldGained + gained

        local stageName = State.CurrentStage ~= "" and State.CurrentStage or "Unknown"
        if not State.StageRewards[stageName] then
            State.StageRewards[stageName] = 0
        end
        State.StageRewards[stageName] = State.StageRewards[stageName] + gained

        addLog(string.format("Gold +%d (stage: %s)", gained, stageName))
    end
    State.LastGoldValue = currentGold
end


-- FIXED waitForNewCharacter


local function waitForNewCharacter(timeout, opts)
    timeout = timeout or 15
    opts = opts or {}
    local requireRespawn = opts.requireRespawn ~= false

    local oldCharacter = LocalPlayer.Character
    local oldHumanoid  = oldCharacter and oldCharacter:FindFirstChildOfClass("Humanoid")
    local oldRoot      = oldCharacter and oldCharacter:FindFirstChild("HumanoidRootPart")
    local oldPos       = oldRoot and oldRoot.Position
    local startTick    = tick()

    if requireRespawn then
        local dieWait = 0
        while oldHumanoid
            and oldHumanoid.Parent
            and oldHumanoid.Health > 0
            and dieWait < 5 do
            task.wait(0.1)
            dieWait = dieWait + 0.1
        end
    end

    while tick() - startTick < timeout do
        local character = LocalPlayer.Character

        if character and character ~= oldCharacter then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrp then
                return true
            end
        end

        if character and character == oldCharacter then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrp then
                if not oldPos or (hrp.Position - oldPos).Magnitude > 3 then
                    return true
                end
            end
        end

        task.wait(0.1)
    end

    return false
end


-- QUEUE ON TELEPORT


local queueonteleport =
    (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport)

if type(queueonteleport) == "function" then
    pcall(function()
        queueonteleport(string.format([[
            repeat task.wait() until game:IsLoaded()
            task.wait(1)
            loadstring(game:HttpGet("%s"))()
        ]], SCRIPT_URL))
    end)
end


-- CREATE FLUENT WINDOW


local FluentWindow = Fluent:CreateWindow({
    Title = "xEz Hub",
    SubTitle = "Build a Boat • v" .. SCRIPT_VERSION,
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local ElementCounter = 0
local function nextElementId(prefix)
    ElementCounter += 1
    return string.format("xEz_%s_%d", prefix, ElementCounter)
end


-- FLUENT TAB ADAPTER


local function wrapTab(tab)
    local adapter = {}

    function adapter:Paragraph(config)
        local para = tab:AddParagraph({
            Title = config.Title or "xEz Hub",
            Content = config.Desc or config.Content or ""
        })
        return para
    end

    function adapter:Section(config)
        local title = type(config) == "table" and config.Title or tostring(config)
        return tab:AddSection(title)
    end

    function adapter:Button(config)
        return tab:AddButton({
            Title = config.Title or "Button",
            Description = config.Desc or config.Description or "",
            Callback = config.Callback
        })
    end

    function adapter:Toggle(config)
        local title = config.Title or "Toggle"
        return tab:AddToggle(nextElementId("Toggle"), {
            Title = title,
            Description = config.Desc or config.Description or "",
            Default = config.Default == true,
            Callback = function(value)
                if config.Callback then config.Callback(value) end
                requestSave()
            end
        })
    end

    function adapter:Slider(config)
        local title = config.Title or "Slider"
        local value = config.Value or {}
        local min = tonumber(value.Min) or 0
        local max = tonumber(value.Max) or 100
        local default = tonumber(value.Default) or min
        return tab:AddSlider(nextElementId("Slider"), {
            Title = title,
            Description = config.Desc or config.Description or "",
            Default = default,
            Min = min,
            Max = max,
            Rounding = 0,
            Callback = function(v)
                if config.Callback then config.Callback(v) end
                requestSave()
            end
        })
    end

    function adapter:Dropdown(config)
        local values = config.Values or {}
        local selected = config.Value
        if type(selected) == "number" then
            selected = values[selected]
        end
        if selected == nil then
            selected = values[1]
        end
        return tab:AddDropdown(nextElementId("Dropdown"), {
            Title = config.Title or "Dropdown",
            Description = config.Desc or config.Description or "",
            Values = values,
            Multi = false,
            Default = selected,
            Callback = function(v)
                if config.Callback then config.Callback(v) end
                requestSave()
            end
        })
    end

    function adapter:Input(config)
        return tab:AddInput(nextElementId("Input"), {
            Title = config.Title or "Input",
            Description = config.Desc or config.Description or "",
            Default = config.Value or "",
            Placeholder = config.Placeholder or "",
            Numeric = false,
            Finished = false,
            Callback = function(text)
                if config.Callback then config.Callback(text) end
                requestSave()
            end
        })
    end

    return adapter
end

local TabMain = wrapTab(FluentWindow:AddTab({ Title = "หลัก", Icon = "house" }))
local TabSecrets = wrapTab(FluentWindow:AddTab({ Title = "Secret", Icon = "gem" }))
local TabSettings = wrapTab(FluentWindow:AddTab({ Title = "ตั้งค่า", Icon = "settings-2" }))
local TabStats = wrapTab(FluentWindow:AddTab({ Title = "สถิติ", Icon = "chart-no-axes-combined" }))
local TabProfile = wrapTab(FluentWindow:AddTab({ Title = "โปรไฟล์", Icon = "user-round" }))
local TabCredits = wrapTab(FluentWindow:AddTab({ Title = "เครดิต", Icon = "badge-check" }))


-- PROFILE CARD


local ProfileGui
local ProfileCard

local function createProfileCard()
    local parent = getGuiParent()
    ProfileGui = Instance.new("ScreenGui")
    ProfileGui.Name = "xEz_PlayerProfile"
    ProfileGui.ResetOnSpawn = false
    ProfileGui.IgnoreGuiInset = true
    ProfileGui.DisplayOrder = 20
    ProfileGui.Parent = parent

    ProfileCard = Instance.new("Frame")
    ProfileCard.Name = "ProfileCard"
    ProfileCard.AnchorPoint = Vector2.new(1, 0)
    ProfileCard.Position = UDim2.new(1, -18, 0, 18)
    ProfileCard.Size = UDim2.fromOffset(292, 92)
    ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    ProfileCard.BackgroundTransparency = 0.05
    ProfileCard.BorderSizePixel = 0
    ProfileCard.Parent = ProfileGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = ProfileCard

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 78)
    stroke.Transparency = 0.25
    stroke.Thickness = 1
    stroke.Parent = ProfileCard

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.fromOffset(64, 64)
    avatar.Position = UDim2.fromOffset(14, 14)
    avatar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    avatar.BorderSizePixel = 0
    avatar.Parent = ProfileCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    local ok, imageUrl = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if ok and imageUrl then
        avatar.Image = imageUrl
    end

    local displayName = Instance.new("TextLabel")
    displayName.Size = UDim2.new(1, -94, 0, 24)
    displayName.Position = UDim2.fromOffset(90, 14)
    displayName.BackgroundTransparency = 1
    displayName.Text = tostring(LocalPlayer.DisplayName)
    displayName.TextColor3 = Color3.fromRGB(245, 245, 248)
    displayName.TextSize = 17
    displayName.Font = Enum.Font.GothamBold
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.Parent = ProfileCard

    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(1, -94, 0, 20)
    username.Position = UDim2.fromOffset(90, 38)
    username.BackgroundTransparency = 1
    username.Text = "@" .. tostring(LocalPlayer.Name)
    username.TextColor3 = Color3.fromRGB(175, 175, 184)
    username.TextSize = 13
    username.Font = Enum.Font.Gotham
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = ProfileCard

    local userId = Instance.new("TextLabel")
    userId.Size = UDim2.new(1, -94, 0, 18)
    userId.Position = UDim2.fromOffset(90, 60)
    userId.BackgroundTransparency = 1
    userId.Text = "UserId: " .. tostring(LocalPlayer.UserId)
    userId.TextColor3 = Color3.fromRGB(130, 130, 138)
    userId.TextSize = 11
    userId.Font = Enum.Font.Gotham
    userId.TextXAlignment = Enum.TextXAlignment.Left
    userId.Parent = ProfileCard

    return ProfileGui
end

createProfileCard()


-- BLACK SCREEN


local BlackScreenUI = Instance.new("ScreenGui")
BlackScreenUI.Name = "xEz_BlackScreen"
BlackScreenUI.ResetOnSpawn = false
BlackScreenUI.IgnoreGuiInset = true
BlackScreenUI.DisplayOrder = 4
BlackScreenUI.Parent = getGuiParent()

local BlackFrame = Instance.new("Frame")
BlackFrame.Size = UDim2.fromScale(1, 1)
BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackFrame.BackgroundTransparency = 1
BlackFrame.BorderSizePixel = 0
BlackFrame.Visible = false
BlackFrame.Parent = BlackScreenUI

local BlackText = Instance.new("TextLabel")
BlackText.Size = UDim2.fromScale(1, 0.1)
BlackText.Position = UDim2.fromScale(0, 0.45)
BlackText.Text = " "
BlackText.TextColor3 = Color3.fromRGB(0, 255, 150)
BlackText.TextSize = 24
BlackText.BackgroundTransparency = 1
BlackText.TextTransparency = 1
BlackText.Font = Enum.Font.GothamBold
BlackText.Parent = BlackFrame

task.spawn(function()
    local dots = {".", "..", "..."}
    local i = 1
    while BlackFrame.Parent do
        task.wait(0.5)
        if BlackFrame.Visible then
            pcall(function()
                BlackText.Text = " " .. dots[i]
            end)
            i = i % #dots + 1
        end
    end
end)


-- ANTI-AFK


local function toggleAntiAFK(enabled)
    if Connections.AntiAFK then
        Connections.AntiAFK:Disconnect()
        Connections.AntiAFK = nil
    end
    if not enabled then return end
    Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

local function toggleAntiAFKKey(enabled)
    State.AntiAFKKey = enabled
    if not enabled then
        if Connections.AntiAFKKeyLoop then
            pcall(task.cancel, Connections.AntiAFKKeyLoop)
            Connections.AntiAFKKeyLoop = nil
        end
        return
    end
    if Connections.AntiAFKKeyLoop then
        pcall(task.cancel, Connections.AntiAFKKeyLoop)
        Connections.AntiAFKKeyLoop = nil
    end
    Connections.AntiAFKKeyLoop = task.spawn(function()
        while State.AntiAFKKey do
            task.wait(10)
            if State.AntiAFKKey then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.K, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.K, false, game)
                end)
            end
        end
    end)
end


-- NOCLIP


local OriginalCollision = {}

local function saveCollision(part)
    if OriginalCollision[part] == nil then
        OriginalCollision[part] = part.CanCollide
    end
end

local function restoreCollision()
    for part, collision in pairs(OriginalCollision) do
        if part and part.Parent then
            pcall(function() part.CanCollide = collision end)
        end
    end
    table.clear(OriginalCollision)
end

local function toggleNoClip(enabled)
    if Connections.NoClip then
        Connections.NoClip:Disconnect()
        Connections.NoClip = nil
    end
    if not enabled then
        restoreCollision()
        return
    end
    Connections.NoClip = RunService.Heartbeat:Connect(function()
        if not isCharacterReady() then return end
        local character = getCharacter()
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                saveCollision(part)
                pcall(function() part.CanCollide = false end)
            end
        end
    end)
end


-- GOD MODE


local function toggleGodMode(enabled)
    if Connections.GodMode then
        Connections.GodMode:Disconnect()
        Connections.GodMode = nil
    end
    if not enabled then return end
    Connections.GodMode = RunService.Heartbeat:Connect(function()
        if not isCharacterReady() then return end
        local humanoid = getHumanoid()
        if not humanoid then return end
        pcall(function()
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end)
    end)
end


-- ANTI FLING / KICK


local function toggleAntiFling(enabled)
    if Connections.AntiFlingLoop then
        Connections.AntiFlingLoop:Disconnect()
        Connections.AntiFlingLoop = nil
    end
    if not enabled then return end
    Connections.AntiFlingLoop = RunService.Heartbeat:Connect(function()
        if not isCharacterReady() then return end
        local hrp = getRoot()
        if not hrp then return end
        if hrp.Velocity.Magnitude > 200 then
            pcall(function()
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        end
    end)
end

local function toggleAntiKick(enabled)
    State.AntiKick = enabled
    if not enabled then
        if Connections.AntiKickLoop then
            pcall(task.cancel, Connections.AntiKickLoop)
            Connections.AntiKickLoop = nil
        end
        return
    end
    if Connections.AntiKickLoop then
        pcall(task.cancel, Connections.AntiKickLoop)
        Connections.AntiKickLoop = nil
    end
    Connections.AntiKickLoop = task.spawn(function()
        while State.AntiKick do
            task.wait(5)
            if State.AntiKick then
                pcall(function()
                    VirtualUser:CaptureController()
                end)
            end
        end
    end)
end


-- FLY


local function toggleFly(enabled)
    if Connections.FlyLoop then
        Connections.FlyLoop:Disconnect()
        Connections.FlyLoop = nil
    end
    isFlying = enabled
    if not enabled then
        local hrp = getRoot()
        if hrp then
            local bv = hrp:FindFirstChild("xEzFlyVelocity")
            if bv then bv:Destroy() end
        end
        return
    end
    local hrp = getRoot()
    if not hrp then return end    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "xEzFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = hrp
    Connections.FlyLoop = RunService.RenderStepped:Connect(function()
        if not isFlying then return end
        local hrp = getRoot()
        if not hrp or not bodyVelocity.Parent then return end
        local camera = Workspace.CurrentCamera
        local moveVector = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * State.FlySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end


-- CHARACTER RESPAWN


local function cleanupOldCharacter()
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
end

local function onCharacterRespawn(character)
    if not character then return end
    State.LastRespawn = tick()
    State.RespawnCount = State.RespawnCount + 1
    addLog("Respawn #" .. State.RespawnCount)
    cleanupOldCharacter()
    task.wait(0.3)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    character:WaitForChild("HumanoidRootPart", 10)
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end)
    pcall(function()
        humanoid.WalkSpeed = State.WalkSpeed
        humanoid.JumpPower = State.JumpPower
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
    end)
    if State.GravityZero then
        Workspace.Gravity = 0
    else
        Workspace.Gravity = GRAVITY_NORMAL
    end
    if State.GodMode then
        task.defer(function()
            pcall(function()
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end)
            toggleGodMode(true)
        end)
    end
    if State.NoClip then task.defer(function() toggleNoClip(true) end) end
    if State.Fly then task.defer(function() toggleFly(true) end) end
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterRespawn)

if LocalPlayer.Character then
    task.spawn(function()
        task.wait(1)
        onCharacterRespawn(LocalPlayer.Character)
    end)
end

LocalPlayer.CharacterRemoving:Connect(function()
    cleanupOldCharacter()
end)


-- INFINITE JUMP


Connections.JumpRequest = UserInputService.JumpRequest:Connect(function()
    if not State.InfJump then return end
    local humanoid = getHumanoid()
    if humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)


-- PANIC KEYBIND


local PanicKeyMap = {
    ["RightShift"] = Enum.KeyCode.RightShift,
    ["LeftShift"]  = Enum.KeyCode.LeftShift,
    ["F1"] = Enum.KeyCode.F1,
    ["F2"] = Enum.KeyCode.F2,
    ["F3"] = Enum.KeyCode.F3,
    ["F4"] = Enum.KeyCode.F4,
    ["F5"] = Enum.KeyCode.F5,
    ["F6"] = Enum.KeyCode.F6,
    ["F7"] = Enum.KeyCode.F7,
    ["F8"] = Enum.KeyCode.F8,
    ["Delete"] = Enum.KeyCode.Delete,
    ["End"]    = Enum.KeyCode.End,
}

local function panicStop()
    State.AutoFarm = false
    State.Farm24_7 = false
    State.AutoBuyChest = false
    State.Fly = false
    State.NoClip = false
    State.GodMode = false
    State.AutoCollectCoin = false
    State.AutoSkipWave = false
    State.AutoCrystalCave = false
    State.AutoWildWestSecret = false
    State.AutoToxicWasteSecret = false

    FarmToken = FarmToken + 1
    State.IsFarming = false
    BuyToken = BuyToken + 1

    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end

    if Connections.FlyLoop then
        Connections.FlyLoop:Disconnect()
        Connections.FlyLoop = nil
    end
    if Connections.NoClip then
        Connections.NoClip:Disconnect()
        Connections.NoClip = nil
        restoreCollision()
    end
    if Connections.GodMode then
        Connections.GodMode:Disconnect()
        Connections.GodMode = nil
    end
    if Connections.AntiFlingLoop then
        Connections.AntiFlingLoop:Disconnect()
        Connections.AntiFlingLoop = nil
    end

    local hrp = getRoot()
    if hrp then
        local bv = hrp:FindFirstChild("xEzFlyVelocity")
        if bv then bv:Destroy() end
    end

    Workspace.Gravity = GRAVITY_NORMAL
    isFlying = false
    notify("PANIC", "หยุดทุกอย่างแล้ว — toggle ใหม่เพื่อใช้งานต่อ", 5)
    addLog("PANIC triggered")
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = PanicKeyMap[State.PanicKey]
    if key and input.KeyCode == key then
        panicStop()
    end
end)


-- SERVER HOP


local function serverHop()
    if isHopping then return end
    isHopping = true
    notify("เปลี่ยนห้อง", "กำลังหาห้อง...", 3)
    local req = getRequestFunction()
    if not req then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        task.delay(15, function() isHopping = false end)
        return
    end
    local success, response = pcall(function()
        return req({
            Url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100",
                game.PlaceId
            ),
            Method = "GET"
        })
    end)
    if not success or not response then
        isHopping = false
        return
    end
    local decodeSuccess, body = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)
    if not decodeSuccess or not body then
        isHopping = false
        return
    end
    local servers = {}
    if type(body.data) == "table" then
        for _, server in ipairs(body.data) do
            if type(server) == "table"
                and server.id
                and server.maxPlayers
                and server.playing
                and server.maxPlayers > server.playing + 5
                and server.id ~= game.JobId
            then
                table.insert(servers, server.id)
            end
        end
    end
    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
        end)
    else
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
    task.delay(15, function() isHopping = false end)
end


-- WEBHOOK


local function sendWebhook(title, description, color)
    if State.WebhookURL == "" then return false end
    if not State.WebhookURL:match("^https?://") then return false end
    local req = getRequestFunction()
    if not req then return false end
    local payloadTable
    if State.WebhookRichEmbed then
        payloadTable = {
            embeds = {
                {
                    title = title,
                    description = description,
                    color = color or 65280,
                    fields = {
                        { name = "User", value = tostring(LocalPlayer.Name), inline = true },
                        { name = "Wins", value = tostring(State.WinsCount), inline = true },
                        { name = "Gold Gained", value = tostring(State.TotalGoldGained), inline = true }
                    },
                    footer = { text = "xEz Hub v" .. SCRIPT_VERSION },
                    timestamp = DateTime.now():ToIsoDate()
                }
            }
        }
    else
        payloadTable = { content = "**" .. title .. "**\n" .. description }
    end
    local encodeSuccess, payload = pcall(function()
        return HttpService:JSONEncode(payloadTable)
    end)
    if not encodeSuccess then return false end
    local sent = false
    local okRequest = pcall(function()
        local response = req({
            Url = State.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
        if response then
            local status = response.StatusCode or response.Status or 0
            sent = (status == 0) or (status >= 200 and status < 300)
        end
    end)
    return okRequest and sent
end


-- STAFF DETECTOR


local STAFF_GROUPS = {
    { GroupId = 2890259, MinimumRank = 200 },
    { GroupId = 3059674, MinimumRank = 100 }
}

local detectedStaff = {}

local function isStaff(player)
    if not player then return false end
    for _, group in ipairs(STAFF_GROUPS) do
        local success, rank = pcall(function()
            return player:GetRankInGroup(group.GroupId)
        end)
        if success and type(rank) == "number" and rank >= group.MinimumRank then
            return true
        end
    end
    return false
end

local function checkPlayerForStaff(player)
    if not State.StaffDetector then return end
    if player == LocalPlayer then return end
    if detectedStaff[player.UserId] then return end
    if not isStaff(player) then return end
    detectedStaff[player.UserId] = true
    notify("แอดมิน", "เจอแอดมิน: " .. player.Name, 5)
    task.delay(1, function()
        if State.StaffDetector then
            serverHop()
        end
    end)
end

Connections.PlayerAdded = Players.PlayerAdded:Connect(checkPlayerForStaff)

task.spawn(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            checkPlayerForStaff(player)
        end
    end
end)


-- MOVE / FLIGHT TO


local function moveTo(targetCFrame, timeout)
    local hrp = getRoot()
    if not hrp then return false end
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
    if State.GravityZero then
        Workspace.Gravity = 0
    end
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if State.MaxSpeedMode then
        pcall(function() hrp.CFrame = targetCFrame end)
        task.wait(State.StepDelay)
        return true
    end
    local speedValue = math.max(50, tonumber(State.FarmSpeed) or 900)
    local duration = distance / speedValue
    if State.FarmSpeed >= 5000 then
        local steps = math.max(1, math.floor(distance / 100))
        for i = 1, steps do
            if not State.AutoFarm then return false end
            if not hrp or not hrp.Parent then return false end
            local alpha = i / steps
            local nextCFrame = hrp.CFrame:Lerp(targetCFrame, alpha)
            pcall(function() hrp.CFrame = nextCFrame end)
            task.wait(State.StepDelay)
        end
        return true
    end
    local reached = false
    local cancelled = false
    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = targetCFrame }
    )
    local completedConn
    completedConn = currentTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            reached = true
        else
            cancelled = true
        end
        if completedConn then completedConn:Disconnect() end
    end)
    currentTween:Play()
    local start = tick()
    local maxWait = timeout or (duration + 5)
    while not reached and not cancelled do
        if tick() - start > maxWait then break end
        if not State.AutoFarm then break end
        if not hrp or not hrp.Parent then break end
        task.wait(0.02)
    end
    if completedConn then completedConn:Disconnect() end
    return reached
end


-- CHEST


local function findGoldenChestTrigger()
    local boatStages = Workspace:FindFirstChild("BoatStages")
    if not boatStages then return nil end
    local normalStages = boatStages:FindFirstChild("NormalStages")
    if not normalStages then return nil end
    local theEnd = normalStages:FindFirstChild("TheEnd")
    if not theEnd then return nil end
    local goldenChest = theEnd:FindFirstChild("GoldenChest")
    if not goldenChest then return nil end
    return goldenChest:FindFirstChild("Trigger")
        or goldenChest:FindFirstChildOfClass("BasePart")
end

local function triggerChest()
    local hrp = getRoot()
    if not hrp then return false end
    local chestPart = findGoldenChestTrigger()
    if not chestPart then return false end
    if type(firetouchinterest) ~= "function" then return false end
    local success = pcall(function()
        firetouchinterest(hrp, chestPart, 0)
        task.wait(0.05)
        firetouchinterest(hrp, chestPart, 1)
    end)
    return success
end


-- SECRET: CRYSTAL CAVE


local function findCrystalCaveCrystals()
    local stages = Workspace:FindFirstChild("BoatStages")
    if not stages then return {} end
    local normal = stages:FindFirstChild("NormalStages")
    if not normal then return {} end
    local crystalStage = normal:FindFirstChild("CrystalCaveStage")
    if not crystalStage then return {} end

    local crystals = {}
    for _, obj in ipairs(crystalStage:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("crystal") then
            table.insert(crystals, obj)
        end
    end
    return crystals
end

local function shootCrystalAt(crystalPart)
    if not crystalPart or not crystalPart.Parent then return false end
    local hrp = getRoot()
    if not hrp then return false end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    local shootTool = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("cannon") or tool.Name:lower():find("gun")) then
            shootTool = tool
            break
        end
    end

    if not shootTool then
        notify("Crystal Cave", "ไม่พบ Cannon ในกระเป๋า", 3)
        return false
    end

    local humanoid = getHumanoid()
    if humanoid then
        pcall(function()
            humanoid:EquipTool(shootTool)
        end)
        task.wait(0.2)
    end

    local toolHandle = shootTool:FindFirstChild("Handle")
    if toolHandle then
        pcall(function()
            local direction = (crystalPart.Position - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        end)
    end

    pcall(function()
        shootTool:Activate()
    end)

    task.wait(0.3)
    return true
end

local function isInCrystalSecretArea()
    local hrp = getRoot()
    if not hrp then return false end
    local crystalStage = Workspace:FindFirstChild("BoatStages")
    if not crystalStage then return false end
    local normal = crystalStage:FindFirstChild("NormalStages")
    if not normal then return false end
    local cave = normal:FindFirstChild("CrystalCaveStage")
    if not cave then return false end
    local part = cave:FindFirstChildOfClass("BasePart")
    if not part then return false end

    local dist = (hrp.Position - part.Position).Magnitude
    return dist > 500
end

local function findPortalsInSecretArea()
    local portals = {}
    local hrp = getRoot()
    if not hrp then return portals end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("portal") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < 1000 then
                table.insert(portals, obj)
            end
        end
    end
    return portals
end

local function findPortalByColor(colorName)
    local portals = findPortalsInSecretArea()
    for _, portal in ipairs(portals) do
        local name = portal.Name:lower()
        if name:find(colorName:lower()) then
            return portal
        end
    end
    return nil
end

local function traversePortalPath(portalColors)
    for _, colorName in ipairs(portalColors) do
        local portal = findPortalByColor(colorName)
        if portal then
            local hrp = getRoot()
            if hrp then
                pcall(function()
                    hrp.CFrame = portal.CFrame + Vector3.new(0, 3, 0)
                end)
                task.wait(0.5)
            end
        end
    end
end

local function findSecretCrystals()
    local crystals = {}
    local hrp = getRoot()
    if not hrp then return crystals end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart")
            and obj.Name:lower():find("crystal")
            and (hrp.Position - obj.Position).Magnitude < 1000 then
            local size = obj.Size
            if size.X < 10 and size.Y < 10 and size.Z < 10 then
                table.insert(crystals, obj)
            end
        end
    end
    return crystals
end

local function autoSolveCrystalCave()
    if not State.AutoCrystalCave then return end
    if not isInCrystalSecretArea() then
        notify("Crystal Cave", "ยังไม่เข้าโซนลับ — ยิงคริสตัลก่อน", 3)
        return
    end

    notify("Crystal Cave", "เริ่มแก้ปริศนา Portal", 3)
    addLog("Crystal Cave solver started")

    local paths = {
        { name = "orange", portals = { "green", "gray" } },
        { name = "white", portals = { "yellow", "cyan", "black" } },
        { name = "yellow", portals = { "green", "white", "purple" } },
    }

    for _, path in ipairs(paths) do
        if not State.AutoCrystalCave then break end
        notify("Crystal Cave", "ไปเก็บ " .. path.name, 2)
        traversePortalPath(path.portals)

        local crystals = findSecretCrystals()
        for _, crystal in ipairs(crystals) do
            local hrp = getRoot()
            if hrp then
                pcall(function()
                    firetouchinterest(hrp, crystal, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, crystal, 1)
                end)
            end
        end
        task.wait(1)
    end

    notify("Crystal Cave", "เสร็จสิ้น — นำคริสตัลไปใส่", 3)
    addLog("Crystal Cave solver finished")
end

local function autoShootCrystalCave()
    local stageName = getCurrentStageName()
    if stageName ~= "CrystalCaveStage" then return end

    local crystals = findCrystalCaveCrystals()
    if #crystals == 0 then return end

    notify("Crystal Cave", "ยิงคริสตัล " .. #crystals .. " อัน", 3)

    local shotCount = 0
    for _, crystal in ipairs(crystals) do
        if shotCount >= 10 then break end
        if shootCrystalAt(crystal) then
            shotCount = shotCount + 1
        end
        task.wait(0.2)
    end

    addLog("Shot " .. shotCount .. " crystals in Crystal Cave")
end


-- SECRET: WILD WEST


local function autoCollectWildWestSecret()
    if not State.AutoWildWestSecret then return end
    local stageName = getCurrentStageName()
    if stageName ~= "WildWestStage" then return end

    local stages = Workspace:FindFirstChild("BoatStages")
    if not stages then return end
    local normal = stages:FindFirstChild("NormalStages")
    if not normal then return end
    local wildWest = normal:FindFirstChild("WildWestStage")
    if not wildWest then return end

    local hrp = getRoot()
    if not hrp then return end

    local stagePart = wildWest:FindFirstChildOfClass("BasePart")
    if stagePart then
        local cavePos = stagePart.Position + Vector3.new(100, 0, 0)
        pcall(function()
            hrp.CFrame = CFrame.new(cavePos)
        end)
        task.wait(0.5)
    end

    for _, obj in ipairs(wildWest:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("treasure") then
            pcall(function()
                firetouchinterest(hrp, obj, 0)
                task.wait(0.05)
                firetouchinterest(hrp, obj, 1)
            end)
            addLog("Wild West secret collected")
            notify("Wild West", "เก็บ Secret แล้ว", 2)
            break
        end
    end
end


-- SECRET: TOXIC WASTE


local function autoCollectToxicWasteSecret()
    if not State.AutoToxicWasteSecret then return end
    local stageName = getCurrentStageName()
    if stageName ~= "ToxicWasteStage" then return end

    local stages = Workspace:FindFirstChild("BoatStages")
    if not stages then return end
    local normal = stages:FindFirstChild("NormalStages")
    if not normal then return end
    local toxic = normal:FindFirstChild("ToxicWasteStage")
    if not toxic then return end

    for _, obj in ipairs(toxic:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("rock") then
            local hrp = getRoot()
            if hrp and (hrp.Position - obj.Position).Magnitude < 200 then
                shootCrystalAt(obj)
                task.wait(0.3)
            end
        end
    end

    addLog("Toxic Waste secret attempt")
end


-- AUTO FARM


local function startAutoFarm()
    if State.IsFarming then return end
    FarmToken += 1
    local myToken = FarmToken
    local function stillActive()
        return State.AutoFarm and myToken == FarmToken
    end
    if State.GravityZero then
        Workspace.Gravity = 0
    end
    State.IsFarming = true
    while stillActive() do
        if not isCharacterReady() then
            waitForNewCharacter(15, { requireRespawn = false })
        end
        if not stillActive() then break end
        if not isCharacterReady() then
            task.wait(0.5)
        else
            State.CurrentRunStart = tick()
            State.CurrentStage = getCurrentStageName() or "Unknown"
            trackGoldGain()

            if State.AutoCrystalCave then
                autoShootCrystalCave()
            end
            if State.AutoWildWestSecret then
                autoCollectWildWestSecret()
            end
            if State.AutoToxicWasteSecret then
                autoCollectToxicWasteSecret()
            end

            moveTo(Waypoints[1])
            if not stillActive() then break end
            if not safeWait(State.StepDelay, myToken, stillActive) then break end
            moveTo(Waypoints[2])
            if not stillActive() then break end
            if not safeWait(State.StepDelay, myToken, stillActive) then break end
            moveTo(Waypoints[3])
            if not stillActive() then break end
            if not safeWait(0.1, myToken, stillActive) then break end
            if isCharacterReady() then
                local chestOpened = triggerChest()
                if not safeWait(State.ChestDelay, myToken, stillActive) then break end
                if isCharacterReady() then
                    pcall(function()
                        local hrp = getRoot()
                        if hrp then
                            hrp.CFrame = CFrame.new(-54.331871, -345.398346, 9495.13)
                        end
                    end)
                end
                if not safeWait(0.2, myToken, stillActive) then break end
                trackGoldGain()
                local runTime = tick() - State.CurrentRunStart
                table.insert(State.RunTimes, runTime)
                if #State.RunTimes > 50 then table.remove(State.RunTimes, 1) end
                if State.BestRunTime == 0 or runTime < State.BestRunTime then
                    State.BestRunTime = runTime
                end
                if chestOpened then
                    State.WinsCount += 1
                    notify("ฟาร์ม", "รอบที่ " .. State.WinsCount .. " (" .. string.format("%.1f", runTime) .. "s)", 2)
                    if State.WebhookNotify then
                        task.spawn(function()
                            sendWebhook("Farm Complete", "Round " .. State.WinsCount, 65280)
                        end)
                    end
                else
                    State.FailsCount += 1
                end
            end
            if not stillActive() then break end
            if not safeWait(State.ResetDelay, myToken, stillActive) then break end
            if not stillActive() then break end

            Workspace.Gravity = GRAVITY_NORMAL

            if State.GodMode and Connections.GodMode then
                Connections.GodMode:Disconnect()
                Connections.GodMode = nil
            end

            local h = getHumanoid()
            if h and h.Parent then
                pcall(function()
                    h.MaxHealth = 100
                    h.Health = 0
                end)
            end

            waitForNewCharacter(15, { requireRespawn = true })

            if not safeWait(State.PostResetDelay, myToken, stillActive) then break end
            if State.GravityZero and stillActive() then
                Workspace.Gravity = 0
            end

            if State.GodMode and stillActive() then
                task.defer(function()
                    if State.GodMode then toggleGodMode(true) end
                end)
            end

            if State.MemoryCleanup and tick() - State.LastCleanup > 300 then
                State.LastCleanup = tick()
                pcall(function() collectgarbage("collect") end)
            end
        end
    end
    State.IsFarming = false
    Workspace.Gravity = GRAVITY_NORMAL
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
end

local function stopAutoFarm()
    FarmToken += 1
    State.IsFarming = false
    Workspace.Gravity = GRAVITY_NORMAL
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
end


-- v1.3.1: FIXED AUTO BUY (with proper Gold retry)


local function buyChest(chestName, count)
    local itemBought = Workspace:FindFirstChild("ItemBoughtFromShop")
    if not itemBought then
        if not isBuyWarned then
            isBuyWarned = true
            notify("ร้านค้า", "ไม่พบระบบซื้อไอเทม", 3)
        end
        return false
    end
    isBuyWarned = false

    -- ✅ FIX: รอ leaderstats โหลดก่อน (สูงสุด 2 วิ)
    local currentGold = getCurrentGoldWithRetry(10, 0.2)

    local pricePerChest = CHEST_PRICES[chestName] or 5
    local totalNeeded = pricePerChest * count

    if currentGold < totalNeeded then
        notify("ร้านค้า",
            string.format("Gold ไม่พอ: มี %s / ต้องใช้ %s",
                formatNumber(currentGold),
                formatNumber(totalNeeded)),
            5)
        return false
    end

    local amount = math.max(1, tonumber(count) or 1)
    local successCount = 0
    for _ = 1, amount do
        local success = pcall(function()
            itemBought:InvokeServer(chestName, 1)
        end)
        if success then successCount += 1 end
        task.wait(0.05)
    end
    return successCount > 0
end

local function startAutoBuy()
    BuyToken += 1
    local myToken = BuyToken
    local failCount = 0
    while State.AutoBuyChest and myToken == BuyToken do
        local ok = buyChest(State.SelectedChest, State.AutoBuyCount)
        if not ok then
            failCount = failCount + 1
            if failCount >= 5 then
                State.AutoBuyChest = false
                break
            end
        else
            failCount = 0
        end
        task.wait(0.2)
    end
end

local function stopAutoBuy()
    BuyToken += 1
end


-- AUTO REJOIN


Connections.TeleportFailed = TeleportService.TeleportInitFailed:Connect(
    function(player, teleportResult, errorMessage)
        if player ~= LocalPlayer then return end
        if not State.AutoRejoin then return end
        task.delay(State.RejoinDelay, function()
            if State.AutoRejoin then
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        end)
    end
)

Connections.ErrorMessage = GuiService.ErrorMessageChanged:Connect(function()
    if not State.AutoRejoin then return end
    task.delay(State.RejoinDelay, function()
        if State.AutoRejoin then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end)
end)


-- AUTO COLLECT COIN / SKIP WAVE


task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoCollectCoin and isCharacterReady() then
            local hrp = getRoot()
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                        pcall(function()
                            firetouchinterest(hrp, obj, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, obj, 1)
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoSkipWave then
            local skipRemote = Workspace:FindFirstChild("SkipWave")
                or ReplicatedStorage:FindFirstChild("SkipWave")
            if skipRemote and skipRemote:IsA("RemoteEvent") then
                pcall(function()
                    skipRemote:FireServer()
                end)
            end
        end
    end
end)


-- 24/7 LOOP


task.spawn(function()
    while true do
        task.wait(3)
        if State.Farm24_7 then
            State.AutoFarm = true
            if not State.IsFarming then
                task.spawn(startAutoFarm)
            end
            if not isCharacterReady() and tick() - State.LastRespawn > 10 then
                pcall(function()
                    LocalPlayer:LoadCharacter()
                end)
            end
            if State.AntiDisconnect then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end)
            end
        end
    end
end)


-- GOLD TRACKING LOOP


task.spawn(function()
    while true do
        task.wait(2)
        if State.TrackGoldGain then
            trackGoldGain()
            local stageName = getCurrentStageName()
            if stageName and stageName ~= State.CurrentStage then
                State.CurrentStage = stageName
                addLog("Entered stage: " .. stageName)
            end
        end
    end
end)


-- STATS UPDATER


local StatsLabels = {}

task.spawn(function()
    while true do
        local ok, err = pcall(function()
            task.wait(1)
            if StatsLabels.Uptime then
                StatsLabels.Uptime:SetTitle("เวลาเปิด: " .. formatUptime(tick() - State.SessionStart))
            end
            if StatsLabels.Wins then
                StatsLabels.Wins:SetTitle("ชนะ: " .. tostring(State.WinsCount))
            end
            if StatsLabels.Fails then
                StatsLabels.Fails:SetTitle("พลาด: " .. tostring(State.FailsCount))
            end
            if StatsLabels.Rate then
                local total = State.WinsCount + State.FailsCount
                local rate = total > 0 and math.floor((State.WinsCount / total) * 100) or 0
                StatsLabels.Rate:SetTitle("อัตราสำเร็จ: " .. rate .. "%")
            end
            if StatsLabels.BestTime then
                StatsLabels.BestTime:SetTitle("เร็วสุด: " .. string.format("%.1f", State.BestRunTime) .. "s")
            end
            if StatsLabels.AvgTime then
                StatsLabels.AvgTime:SetTitle("เฉลี่ย: " .. string.format("%.1f", getAverageRunTime()) .. "s")
            end
            if StatsLabels.Ping then
                StatsLabels.Ping:SetTitle("ปิง: " .. getPing() .. "ms")
            end
            if StatsLabels.Speed then
                local speedText = State.MaxSpeedMode and "MAX" or tostring(State.FarmSpeed)
                StatsLabels.Speed:SetTitle("ความเร็ว: " .. speedText)
            end
            if StatsLabels.Respawns then
                StatsLabels.Respawns:SetTitle("เกิดใหม่: " .. tostring(State.RespawnCount))
            end
            if StatsLabels.Gold then
                local currentGold = getCurrentGold()
                StatsLabels.Gold:SetTitle(
                    "Gold: " .. formatNumber(currentGold) ..
                    " (รวม +" .. formatNumber(State.TotalGoldGained) .. ")"
                )
            end
            if StatsLabels.CurrentStage then
                StatsLabels.CurrentStage:SetTitle("Stage: " .. (State.CurrentStage ~= "" and State.CurrentStage or "-"))
            end
            if StatsLabels.Log then
                local logText = ""
                local start = math.max(1, #State.SessionLog - 9)
                for i = start, #State.SessionLog do
                    logText = logText .. State.SessionLog[i].time .. " | " .. State.SessionLog[i].message .. "\n"
                end
                pcall(function()
                    StatsLabels.Log:SetDesc(logText)
                end)
            end
        end)
        if not ok then
            warn("[xEz Hub] Stats updater error:", err)
        end
    end
end)


-- PROFILE TAB


TabProfile:Paragraph({
    Title = "โปรไฟล์ผู้เล่น",
    Desc = string.format(
        "%s (@%s)\nUserId: %d",
        tostring(LocalPlayer.DisplayName),
        tostring(LocalPlayer.Name),
        LocalPlayer.UserId
    )
})

TabProfile:Button({
    Title = "คัดลอก UserId",
    Desc = tostring(LocalPlayer.UserId),
    Callback = function()
        pcall(function()
            if setclipboard then
                setclipboard(tostring(LocalPlayer.UserId))
            end
        end)
        notify("โปรไฟล์", "คัดลอก UserId แล้ว", 2)
    end
})


-- MAIN TAB


TabMain:Paragraph({
    Title = "xEz Hub v" .. SCRIPT_VERSION,
    Desc = "ฟาร์ม Build a Boat อัตโนมัติ",
})

TabMain:Toggle({
    Title = "ฟาร์มอัตโนมัติ",
    Desc = "เปิดเพื่อเริ่มฟาร์ม",
    Default = false,
    Callback = function(value)
        State.AutoFarm = value
        if value then
            notify("xEz Hub", "เริ่มฟาร์มแล้ว", 2)
            task.spawn(startAutoFarm)
        else
            stopAutoFarm()
            notify("xEz Hub", "หยุดฟาร์มแล้ว", 2)
        end
    end
})

TabMain:Toggle({
    Title = "ฟาร์ม 24 ชม.",
    Desc = "ฟาร์มต่อเนื่อง 24 ชม.",
    Default = false,
    Callback = function(value)
        State.Farm24_7 = value
        if value then
            notify("24/7", "เปิด 24 ชม. แล้ว", 2)
            State.AutoFarm = true
            task.spawn(startAutoFarm)
        else
            notify("24/7", "ปิด 24 ชม. แล้ว", 2)
        end
    end
})

TabMain:Toggle({
    Title = "กันตาย",
    Desc = "ไม่ตาย",
    Default = false,
    Callback = function(value)
        State.GodMode = value
        toggleGodMode(value)
    end
})

TabMain:Toggle({
    Title = "เก็บเหรียญอัตโนมัติ",
    Desc = "เก็บเหรียญอัตโนมัติ",
    Default = false,
    Callback = function(value) State.AutoCollectCoin = value end
})

TabMain:Toggle({
    Title = "ข้ามด่านอัตโนมัติ",
    Desc = "ข้ามด่านอัตโนมัติ",
    Default = false,
    Callback = function(value) State.AutoSkipWave = value end
})

TabMain:Section({ Title = "การเคลื่อนที่" })

TabMain:Slider({
    Title = "ความเร็วเดิน",
    Value = { Min = 16, Max = 250, Default = State.WalkSpeed },
    Callback = function(value)
        State.WalkSpeed = value
        local h = getHumanoid()
        if h then pcall(function() h.WalkSpeed = value end) end
    end
})

TabMain:Slider({
    Title = "แรงกระโดด",
    Value = { Min = 50, Max = 300, Default = State.JumpPower },
    Callback = function(value)
        State.JumpPower = value
        local h = getHumanoid()
        if h then pcall(function() h.JumpPower = value end) end
    end
})

TabMain:Toggle({
    Title = "กระโดดไม่จำกัด",
    Default = State.InfJump,
    Callback = function(value) State.InfJump = value end
})

TabMain:Toggle({
    Title = "ทะลุของ",
    Default = State.NoClip,
    Callback = function(value)
        State.NoClip = value
        toggleNoClip(value)
    end
})

TabMain:Toggle({
    Title = "บิน (WASD + Space/Ctrl)",
    Default = State.Fly,
    Callback = function(value)
        State.Fly = value
        toggleFly(value)
    end
})

TabMain:Slider({
    Title = "ความเร็วบิน",
    Value = { Min = 30, Max = 500, Default = State.FlySpeed },
    Callback = function(value) State.FlySpeed = value end
})

TabMain:Button({
    Title = "รีเซ็ตตัวละคร",
    Callback = function()
        local h = getHumanoid()
        if h and h.Parent then
            pcall(function() h.Health = 0 end)
        end
    end
})

TabMain:Section({ Title = "ซื้อกล่อง" })

TabMain:Dropdown({
    Title = "ชนิดกล่อง",
    Values = { "Common Chest", "Uncommon Chest", "Rare Chest", "Epic Chest", "Legendary Chest" },
    Value = State.SelectedChest,
    Callback = function(value) State.SelectedChest = value end
})

TabMain:Slider({
    Title = "จำนวนที่ซื้อต่อครั้ง",
    Value = { Min = 1, Max = 999, Default = State.AutoBuyCount },
    Callback = function(value) State.AutoBuyCount = value end
})

TabMain:Button({
    Title = "ซื้อ 1",
    Callback = function() buyChest(State.SelectedChest, 1) end
})

TabMain:Button({
    Title = "ซื้อ 100",
    Callback = function() buyChest(State.SelectedChest, 100) end
})

TabMain:Button({
    Title = "ซื้อ 999",
    Callback = function() buyChest(State.SelectedChest, 999) end
})

TabMain:Toggle({
    Title = "ซื้อวน",
    Default = false,
    Callback = function(value)
        State.AutoBuyChest = value
        if value then task.spawn(startAutoBuy) else stopAutoBuy() end
    end
})

TabMain:Section({ Title = "ระบบกัน" })

TabMain:Toggle({
    Title = "กันหลุด",
    Default = State.AntiAFK,
    Callback = function(value)
        State.AntiAFK = value
        toggleAntiAFK(value)
    end
})

toggleAntiAFK(State.AntiAFK)

TabMain:Toggle({
    Title = "กันหลุด (กด K)",
    Default = State.AntiAFKKey,
    Callback = function(value)
        State.AntiAFKKey = value
        toggleAntiAFKKey(value)
    end
})

toggleAntiAFKKey(State.AntiAFKKey)

TabMain:Toggle({
    Title = "กันเตะ",
    Default = State.AntiKick,
    Callback = function(value)
        State.AntiKick = value
        toggleAntiKick(value)
    end
})

TabMain:Toggle({
    Title = "กันกระเด็น",
    Default = State.AntiFling,
    Callback = function(value)
        State.AntiFling = value
        toggleAntiFling(value)
    end
})

TabMain:Toggle({
    Title = "จับแอดมิน",
    Default = State.StaffDetector,
    Callback = function(value) State.StaffDetector = value end
})

TabMain:Toggle({
    Title = "เข้าห้องเดิม",
    Default = State.AutoRejoin,
    Callback = function(value) State.AutoRejoin = value end
})

TabMain:Button({
    Title = "เปลี่ยนห้อง",
    Callback = function() task.spawn(serverHop) end
})


-- SECRET TAB


TabSecrets:Paragraph({
    Title = "Secret Treasure",
    Desc = "เก็บสมบัติลับใน Build a Boat\n(Crystal Cave, Wild West, Toxic Waste)",
})

TabSecrets:Section({ Title = "Crystal Cave" })

TabSecrets:Toggle({
    Title = "Crystal Cave Auto-Solver",
    Desc = "ยิงคริสตัล + แก้ Portal Maze อัตโนมัติ",
    Default = State.AutoCrystalCave,
    Callback = function(value)
        State.AutoCrystalCave = value
        if value then
            notify("Crystal Cave", "เปิด Auto-Solver — จะทำงานเมื่อเจอ Stage", 3)
        end
    end
})

TabSecrets:Button({
    Title = "แก้ปริศนาทันที (ถ้าอยู่ในโซนลับ)",
    Callback = function()
        task.spawn(autoSolveCrystalCave)
    end
})

TabSecrets:Paragraph({
    Title = "Portal Paths",
    Desc = "Orange: green → gray\nWhite: yellow → cyan → black\nYellow: green → white → purple",
})

TabSecrets:Section({ Title = "Wild West" })

TabSecrets:Toggle({
    Title = "Wild West Secret Auto-Collect",
    Desc = "เดินเข้าไปในถ้ำด้านขวาเพื่อเก็บ Small Treasure",
    Default = State.AutoWildWestSecret,
    Callback = function(value) State.AutoWildWestSecret = value end
})

TabSecrets:Section({ Title = "Toxic Waste" })

TabSecrets:Toggle({
    Title = "Toxic Waste Secret Auto-Collect",
    Desc = "ยิงกำแพงหินเพื่อได้ Ultra Thrusters",
    Default = State.AutoToxicWasteSecret,
    Callback = function(value) State.AutoToxicWasteSecret = value end
})

TabSecrets:Section({ Title = "ข้อมูล" })

TabSecrets:Paragraph({
    Title = "รางวัล Secret",
    Desc = "Crystal Cave: 4 Portals + 200 Gold + Medium Treasure\nWild West: 30 Neon Blocks + Small Treasure\nToxic Waste: 2 Ultra Thrusters + 175 Gold",
})


-- SETTINGS TAB


TabSettings:Paragraph({
    Title = "ตั้งค่า",
    Desc = "ปรับความเร็ว หน่วง และอื่นๆ",
})

TabSettings:Section({ Title = "Config" })

TabSettings:Button({
    Title = "บันทึก Config ตอนนี้",
    Callback = function()
        if saveConfig() then
            notify("Config", "บันทึกแล้ว", 2)
        else
            notify("Config", "บันทึกไม่สำเร็จ (executor ไม่รองรับ writefile)", 3)
        end
    end
})

TabSettings:Button({
    Title = "โหลด Config",
    Callback = function()
        if loadConfig() then
            notify("Config", "โหลดแล้ว (บางค่าต้องรีสตาร์ทสคริปต์)", 3)
        else
            notify("Config", "ไม่พบไฟล์ config", 2)
        end
    end
})

TabSettings:Button({
    Title = "ลบ Config",
    Callback = function()
        pcall(function()
            if delfile and isfile and isfile(CONFIG_FILE) then
                delfile(CONFIG_FILE)
            end
        end)
        notify("Config", "ลบแล้ว", 2)
    end
})

TabSettings:Section({ Title = "ความปลอดภัย" })

TabSettings:Dropdown({
    Title = "ปุ่มหยุดฉุกเฉิน",
    Values = { "RightShift", "LeftShift", "F1", "F2", "F3", "F4", "F5",
               "F6", "F7", "F8", "Delete", "End" },
    Value = State.PanicKey,
    Callback = function(value)
        State.PanicKey = value
        notify("Panic", "ตั้งปุ่มเป็น " .. value, 2)
    end
})

TabSettings:Section({ Title = "ปรับความเร็ว" })

TabSettings:Toggle({
    Title = "โหมดเร็วสุด",
    Default = State.MaxSpeedMode,
    Callback = function(value)
        State.MaxSpeedMode = value
        if value then notify("Speed", "เปิดโหมดเร็วสุด", 2)
        else notify("Speed", "ปิดโหมดเร็วสุด", 2) end
    end
})

TabSettings:Slider({
    Title = "ความเร็วฟาร์ม (studs/sec)",
    Value = { Min = 50, Max = 10000, Default = State.FarmSpeed },
    Callback = function(value) State.FarmSpeed = value end
})

TabSettings:Section({ Title = "ปรับหน่วง" })

TabSettings:Slider({
    Title = "หน่วงตอนบิน",
    Value = { Min = 1, Max = 50, Default = math.floor(State.StepDelay * 100) },
    Callback = function(value) State.StepDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงหลังเปิดกล่อง",
    Value = { Min = 10, Max = 200, Default = math.floor(State.ChestDelay * 100) },
    Callback = function(value) State.ChestDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงก่อนตาย",
    Value = { Min = 10, Max = 300, Default = math.floor(State.ResetDelay * 100) },
    Callback = function(value) State.ResetDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงหลังเกิด",
    Value = { Min = 10, Max = 500, Default = math.floor(State.PostResetDelay * 100) },
    Callback = function(value) State.PostResetDelay = value / 100 end
})

TabSettings:Section({ Title = "โหมดพร้อมใช้" })

TabSettings:Button({
    Title = "ช้า (300)",
    Callback = function()
        State.FarmSpeed = 300
        State.StepDelay = 0.05
        State.ChestDelay = 0.8
        State.ResetDelay = 1.0
        State.PostResetDelay = 2.0
        State.MaxSpeedMode = false
        requestSave()
        notify("Preset", "ตั้งค่าเรียบร้อย", 2)
    end
})

TabSettings:Button({
    Title = "ปกติ (900)",
    Callback = function()
        State.FarmSpeed = 900
        State.StepDelay = 0.02
        State.ChestDelay = 0.5
        State.ResetDelay = 0.5
        State.PostResetDelay = 1.0
        State.MaxSpeedMode = false
        requestSave()
        notify("Preset", "ตั้งค่าเรียบร้อย", 2)
    end
})

TabSettings:Button({
    Title = "เร็ว (5000)",
    Callback = function()
        State.FarmSpeed = 5000
        State.StepDelay = 0.01
        State.ChestDelay = 0.3
        State.ResetDelay = 0.3
        State.PostResetDelay = 0.5
        State.MaxSpeedMode = false
        requestSave()
        notify("Preset", "ตั้งค่าเรียบร้อย", 2)
    end
})

TabSettings:Button({
    Title = "เร็วสุด",
    Callback = function()
        State.MaxSpeedMode = true
        State.StepDelay = 0.01
        State.ChestDelay = 0.2
        State.ResetDelay = 0.2
        State.PostResetDelay = 0.3
        requestSave()
        notify("Preset", "ตั้งค่าเรียบร้อย", 2)
    end
})

TabSettings:Section({ Title = "การบิน" })

TabSettings:Toggle({
    Title = "ปิดแรงโน้มถ่วง",
    Default = State.GravityZero,
    Callback = function(value)
        State.GravityZero = value
        if not value then
            Workspace.Gravity = GRAVITY_NORMAL
        end
    end
})

TabSettings:Slider({
    Title = "ความสูงบิน",
    Value = { Min = 20, Max = 200, Default = State.FlightHeight },
    Callback = function(value) State.FlightHeight = value end
})

TabSettings:Section({ Title = "ประสิทธิภาพ" })

TabSettings:Toggle({
    Title = "จอดำ",
    Default = State.BlackScreen,
    Callback = function(value)
        State.BlackScreen = value
        if value then
            BlackFrame.Visible = true
            pcall(function()
                TweenService:Create(BlackFrame, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()
                TweenService:Create(BlackText, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
            end)
        else
            pcall(function()
                TweenService:Create(BlackFrame, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(BlackText, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            end)
            task.delay(0.4, function()
                BlackFrame.Visible = false
            end)
        end
    end
})

TabSettings:Toggle({
    Title = "ล้างแรม",
    Default = State.MemoryCleanup,
    Callback = function(value) State.MemoryCleanup = value end
})

TabSettings:Toggle({
    Title = "เพิ่ม FPS",
    Default = State.FpsBoost,
    Callback = function(value)
        State.FpsBoost = value
        if value then
            pcall(function()
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("PostEffect") then obj.Enabled = false end
                end
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                        obj.Enabled = false
                    end
                end
            end)
        end
    end
})

TabSettings:Toggle({
    Title = "กราฟิกต่ำ",
    Default = State.LowGraphics,
    Callback = function(value)
        State.LowGraphics = value
        if value then
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 100
                Lighting.Brightness = 0
            end)
        end
    end
})

TabSettings:Button({
    Title = "ล้างแรมตอนนี้",
    Callback = function()
        pcall(function() collectgarbage("collect") end)
        notify("Performance", "ล้างแรมแล้ว", 2)
    end
})


-- STATS TAB


TabStats:Paragraph({
    Title = "สถิติ",
    Desc = "สถิติและประวัติการใช้งาน",
})

TabStats:Section({ Title = "สถิติ" })

StatsLabels.Uptime = TabStats:Paragraph({ Title = "เวลาเปิด: 00:00:00", Desc = "" })
StatsLabels.Wins = TabStats:Paragraph({ Title = "ชนะ: 0", Desc = "" })
StatsLabels.Fails = TabStats:Paragraph({ Title = "พลาด: 0", Desc = "" })
StatsLabels.Rate = TabStats:Paragraph({ Title = "อัตราสำเร็จ: 0%", Desc = "" })
StatsLabels.BestTime = TabStats:Paragraph({ Title = "เร็วสุด: 0.0s", Desc = "" })
StatsLabels.AvgTime = TabStats:Paragraph({ Title = "เฉลี่ย: 0.0s", Desc = "" })
StatsLabels.Ping = TabStats:Paragraph({ Title = "ปิง: 0ms", Desc = "" })
StatsLabels.Speed = TabStats:Paragraph({ Title = "ความเร็ว: 900", Desc = "" })
StatsLabels.Respawns = TabStats:Paragraph({ Title = "เกิดใหม่: 0", Desc = "" })
StatsLabels.Gold = TabStats:Paragraph({ Title = "Gold: 0 (รวม +0)", Desc = "" })
StatsLabels.CurrentStage = TabStats:Paragraph({ Title = "Stage: -", Desc = "" })

TabStats:Button({
    Title = "ล้างสถิติ",
    Callback = function()
        State.WinsCount = 0
        State.FailsCount = 0
        State.SessionStart = tick()
        State.RunTimes = {}
        State.BestRunTime = 0
        State.RespawnCount = 0
        State.TotalGoldGained = 0
        State.StageRewards = {}
        notify("สถิติ", "ล้างสถิติแล้ว", 2)
    end
})

TabStats:Section({ Title = "Gold Tracking" })

TabStats:Toggle({
    Title = "ติดตาม Gold ที่ได้",
    Default = State.TrackGoldGain,
    Callback = function(value) State.TrackGoldGain = value end
})

TabStats:Button({
    Title = "🛠 Debug: ตรวจสอบ Gold Stat",  -- v1.3.1
    Callback = function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then
            notify("Debug", "ไม่พบ leaderstats", 5)
            return
        end
        local lines = {}
        for _, child in ipairs(leaderstats:GetChildren()) do
            table.insert(lines, string.format("%s = %s (%s)",
                child.Name,
                tostring(child.Value),
                child.ClassName))
        end
        local msg = #lines > 0 and table.concat(lines, "\n") or "(empty)"
        notify("Gold Debug", msg, 10)
        print("[xEz Debug] leaderstats:")
        for _, line in ipairs(lines) do
            print("  " .. line)
        end
    end
})

TabStats:Button({
    Title = "แสดงสรุป Gold ตาม Stage",
    Callback = function()
        local summary = "Gold ที่ได้แต่ละ Stage:\n"
        for stage, gold in pairs(State.StageRewards) do
            summary = summary .. string.format("- %s: +%s\n", stage, formatNumber(gold))
        end
        if next(State.StageRewards) == nil then
            summary = "ยังไม่มีข้อมูล"
        end
        notify("Gold Summary", summary, 10)
    end
})

TabStats:Section({ Title = "บันทึกกิจกรรม" })

StatsLabels.Log = TabStats:Paragraph({
    Title = "บันทึกกิจกรรม",
    Desc = "(ยังไม่มีบันทึก)",
})

TabStats:Button({
    Title = "ล้างบันทึก",
    Callback = function()
        State.SessionLog = {}
        notify("บันทึก", "ล้างบันทึกแล้ว", 2)
    end
})

TabStats:Section({ Title = "เว็บฮุค" })

TabStats:Input({
    Title = "ลิงก์ Discord Webhook",
    Value = State.WebhookURL,
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text) State.WebhookURL = tostring(text or "") end
})

TabStats:Toggle({
    Title = "เปิดเว็บฮุค",
    Default = State.WebhookNotify,
    Callback = function(value) State.WebhookNotify = value end
})

TabStats:Toggle({
    Title = "ส่งแบบละเอียด",
    Default = State.WebhookRichEmbed,
    Callback = function(value) State.WebhookRichEmbed = value end
})

TabStats:Button({
    Title = "ทดสอบเว็บฮุค",
    Callback = function()
        if State.WebhookURL == "" then
            notify("เว็บฮุค", "ใส่ลิงก์ก่อน", 2)
            return
        end
        local ok = sendWebhook("Test", "xEz Hub v" .. SCRIPT_VERSION, 65280)
        if ok then notify("Webhook", "ส่งเว็บฮุคแล้ว", 2)
        else notify("Webhook", "ส่งเว็บฮุคไม่ผ่าน", 2) end
    end
})


-- CREDITS TAB


TabCredits:Paragraph({
    Title = "เครดิต",
    Desc = "ข้อมูลผู้สร้าง",
})

TabCredits:Section({ Title = "เครดิต" })

TabCredits:Paragraph({
    Title = "ผู้สร้าง",
    Desc = CREATOR_NAME,
})

TabCredits:Paragraph({
    Title = "ข้อมูลเวอร์ชัน",
    Desc = "xEz Hub v" .. SCRIPT_VERSION .. "\nBuild a Boat",
})

TabCredits:Paragraph({
    Title = "เซิร์ฟเวอร์ Discord",
    Desc = DISCORD_URL,
})

TabCredits:Paragraph({
    Title = "ขอบคุณพิเศษ",
    Desc = "dawid-scripts (Fluent UI)\nRoblox Community\nAll testers\nYou!",
})

TabCredits:Button({
    Title = "เข้าร่วม Discord",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(DISCORD_URL) end
        end)
        notify("ดิสคอร์ด", "คัดลอกลิงก์ Discord แล้ว\n" .. DISCORD_URL, 5)
    end
})

TabCredits:Button({
    Title = "คัดลอกลิงก์ Discord",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(DISCORD_URL) end
        end)
        notify("ดิสคอร์ด", "คัดลอกลิงก์ Discord แล้ว", 2)
    end
})

TabCredits:Button({
    Title = "อัปเดตเป็นเวอร์ชันล่าสุด",
    Callback = function()
        notify("อัปเดต", "กำลังโหลดเวอร์ชันใหม่...", 3)
        task.wait(0.5)
        pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
    end
})


-- VERSION CHECK


task.spawn(function()
    local req = getRequestFunction()
    if not req then
        print("[xEz Hub] Version check skipped (no request function)")
        return
    end
    local ok, res = pcall(function()
        return req({ Url = VERSION_URL, Method = "GET" })
    end)
    if not ok or not res or not res.Body then
        print("[xEz Hub] Version check failed")
        return
    end
    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(res.Body)
    end)
    if not decodeOk or type(data) ~= "table" then return end
    local latest = tostring(data.version or "")
    if latest == "" or latest == SCRIPT_VERSION then
        print("[xEz Hub] Up to date: v" .. SCRIPT_VERSION)
        return
    end
    notify(
        "มีเวอร์ชันใหม่",
        "v" .. latest .. " พร้อมใช้งาน (คุณใช้ v" .. SCRIPT_VERSION .. ")",
        10
    )
    addLog("New version available: " .. latest)
end)


-- START


notify("xEz Hub", "v" .. SCRIPT_VERSION .. " | โหลดเสร็จ", 4)
addLog("Session started")

print("[xEz Hub] v" .. SCRIPT_VERSION .. " loaded.")
print("[xEz Hub] Discord: " .. DISCORD_URL)
print("[xEz Hub] Panic key: " .. State.PanicKey)

-- Debug: log what Gold stat we found
task.spawn(function()
    task.wait(2)
    local stat = findGoldStat()
    if stat then
        print("[xEz Hub] Gold stat detected: " .. stat:GetFullName() .. " = " .. tostring(stat.Value))
    else
        print("[xEz Hub] WARNING: Could not find Gold stat in leaderstats!")
        print("[xEz Hub] Run debug button in Stats tab to see what's available.")
    end
end)


-- CLEANUP ON CLOSE


game:BindToClose(function()
    saveConfig()
    local summary = string.format(
        "Session: %s | Wins: %d | Fails: %d | Rate: %.1f%% | Best: %.1fs | Gold: +%s",
        formatUptime(tick() - State.SessionStart),
        State.WinsCount,
        State.FailsCount,
        State.WinsCount / math.max(1, State.WinsCount + State.FailsCount) * 100,
        State.BestRunTime,
        formatNumber(State.TotalGoldGained)
    )
    print("[xEz Hub] " .. summary)
    if State.WebhookNotify then
        sendWebhook("Session End", summary, 15158332)
    end
end)


-- Cleanup profile card if the Fluent window is destroyed externally.
task.spawn(function()
    while FluentWindow and FluentWindow.Root and FluentWindow.Root.Parent do
        task.wait(2)
    end
    pcall(function()
        if ProfileGui then ProfileGui:Destroy() end
    end)
end)