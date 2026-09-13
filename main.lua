--[[
    xEz Hub v1.1.0
    Build a Boat
    Key System: "xEzShop :3"

    - By ZenLunarDev
]]


-- CONFIG


local SCRIPT_URL = "https://raw.githubusercontent.com/ZenLunarDev/D204wpi-AWEaPa-IAVWB9982kldoi-HW4398-2Aw586/refs/heads/main/main.lua"
local SCRIPT_VERSION = "1.1.0"
local DISCORD_URL = "https://discord.gg/7MA4RK5aUU"
local CREATOR_NAME = "ZenLunarDev"


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


-- LOAD


local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

if not Fluent then
    error("[xEz Hub] Cannot load Fluent UI")
end

-- KEY UI IS HANDLED BY key.lua
-- main.lua intentionally creates only ONE Fluent window.

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


-- ข้อความภาษาไทย



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

local function waitForNewCharacter(timeout)
    timeout = timeout or 15
    local start = tick()
    while tick() - start < timeout do
        if isCharacterReady() then return true end
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
-- Important: main.lua creates exactly ONE Fluent window.
-- The key UI is a separate non-Fluent ScreenGui in key.lua.

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

local TitleIconMap = {
    ["ฟาร์มอัตโนมัติ"] = "bot",
    ["ฟาร์ม 24 ชม."] = "infinity",
    ["กันตาย"] = "shield-check",
    ["เก็บเหรียญอัตโนมัติ"] = "coins",
    ["ข้ามด่านอัตโนมัติ"] = "skip-forward",
    ["ความเร็วเดิน"] = "person-standing",
    ["แรงกระโดด"] = "arrow-up",
    ["กระโดดไม่จำกัด"] = "refresh-cw",
    ["ทะลุของ"] = "scan",
    ["บิน"] = "send",
    ["ความเร็วบิน"] = "gauge",
    ["รีเซ็ตตัวละคร"] = "rotate-ccw",
    ["ชนิดกล่อง"] = "package",
    ["ซื้อ 1"] = "shopping-cart",
    ["ซื้อ 100"] = "shopping-basket",
    ["ซื้อ 999"] = "boxes",
    ["ซื้อวน"] = "repeat-2",
    ["กันหลุด"] = "wifi-off",
    ["กันหลุด (กด K)"] = "keyboard",
    ["กันเตะ"] = "ban",
    ["กันกระเด็น"] = "shield",
    ["จับแอดมิน"] = "user-round-check",
    ["เข้าห้องเดิม"] = "log-in",
    ["เปลี่ยนห้อง"] = "shuffle",
    ["โหมดเร็วสุด"] = "zap",
    ["ความเร็วฟาร์ม"] = "gauge",
    ["หน่วงตอนบิน"] = "timer",
    ["หน่วงหลังเปิดกล่อง"] = "timer-reset",
    ["หน่วงก่อนตาย"] = "hourglass",
    ["หน่วงหลังเกิด"] = "history",
    ["ปิดแรงโน้มถ่วง"] = "orbit",
    ["ความสูงบิน"] = "move-vertical",
    ["จอดำ"] = "monitor-off",
    ["ล้างแรม"] = "memory-stick",
    ["เพิ่ม FPS"] = "activity",
    ["กราฟิกต่ำ"] = "image-down",
    ["ล้างแรมตอนนี้"] = "trash-2",
    ["ล้างสถิติ"] = "rotate-ccw",
    ["ล้างบันทึก"] = "notebook-pen",
    ["เปิดเว็บฮุค"] = "webhook",
    ["ส่งแบบละเอียด"] = "file-text",
    ["ทดสอบเว็บฮุค"] = "send",
    ["เข้าร่วม Discord"] = "message-circle",
    ["คัดลอกลิงก์ Discord"] = "copy",
}

local function resolveIcon(title, fallback)
    local t = tostring(title or "")
    for prefix, icon in pairs(TitleIconMap) do
        if t:find(prefix, 1, true) then
            return icon
        end
    end
    return fallback or "circle"
end

-- Compatibility adapter: keeps the original feature code readable while using Fluent's API.
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
            Callback = config.Callback
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
            Callback = config.Callback
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
            Callback = config.Callback
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
            Callback = config.Callback
        })
    end

    return adapter
end

local TabMain = wrapTab(FluentWindow:AddTab({ Title = "หลัก", Icon = "house" }))
local TabSettings = wrapTab(FluentWindow:AddTab({ Title = "ตั้งค่า", Icon = "settings-2" }))
local TabStats = wrapTab(FluentWindow:AddTab({ Title = "สถิติ", Icon = "chart-no-axes-combined" }))
local TabProfile = wrapTab(FluentWindow:AddTab({ Title = "โปรไฟล์", Icon = "user-round" }))
local TabCredits = wrapTab(FluentWindow:AddTab({ Title = "เครดิต", Icon = "badge-check" }))

-- Player profile: real Roblox thumbnail URL + actual player data.
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
        local url = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        return url
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
-- PROFILE TAB
TabProfile:Paragraph({
    Title = "โปรไฟล์ผู้เล่น",
    Desc = string.format(
        "%s (@%s)\nUserId: %d\nAvatar: Roblox HeadShot thumbnail",
        tostring(LocalPlayer.DisplayName),
        tostring(LocalPlayer.Name),
        LocalPlayer.UserId
    ),
    Image = "user-round"
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
    if not hrp then return end
    local bodyVelocity = Instance.new("BodyVelocity")
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
                        { name = "Speed", value = tostring(State.FarmSpeed), inline = true }
                    },
                    footer = { text = "xEz Hub v" .. SCRIPT_VERSION },
                    timestamp = DateTime.now():ToIsoDate()
                }
            }
        }
    else        payloadTable = { content = "**" .. title .. "**\n" .. description }
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
    notify("แอดมิน", "เจอแอดมิน" .. ": " .. player.Name, 5)
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


-- FLIGHT


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


-- AUTO FARM


local function startAutoFarm()
    if State.IsFarming then
        return
    end
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
            waitForNewCharacter(15)
        end
        if not stillActive() then break end
        if not isCharacterReady() then
            task.wait(0.5)
        else
            State.CurrentRunStart = tick()
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
                local runTime = tick() - State.CurrentRunStart
                table.insert(State.RunTimes, runTime)
                if #State.RunTimes > 50 then table.remove(State.RunTimes, 1) end
                if State.BestRunTime == 0 or runTime < State.BestRunTime then
                    State.BestRunTime = runTime
                end
                if chestOpened then
                    State.WinsCount += 1
                    notify("ฟาร์ม", "รอบที่" .. " " .. State.WinsCount .. " (" .. string.format("%.1f", runTime) .. "s)", 2)
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
            if isCharacterReady() then
                local h = getHumanoid()
                if h and h.Parent and h.Health > 0 then
                    pcall(function() h.Health = 0 end)
                end
            end
            waitForNewCharacter(15)
            if not safeWait(State.PostResetDelay, myToken, stillActive) then break end
            if State.GravityZero and stillActive() then
                Workspace.Gravity = 0
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


-- AUTO BUY


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
        local ok = buyChest(State.SelectedChest, 1)
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


-- STATS UPDATER


local StatsLabels = {}

task.spawn(function()
    while true do
        local ok, err = pcall(function()
            task.wait(1)
            if StatsLabels.Uptime then
                StatsLabels.Uptime:SetTitle("เวลาเปิด" .. ": " .. formatUptime(tick() - State.SessionStart))
            end
            if StatsLabels.Wins then
                StatsLabels.Wins:SetTitle("ชนะ" .. ": " .. tostring(State.WinsCount))
            end
            if StatsLabels.Fails then
                StatsLabels.Fails:SetTitle("พลาด" .. ": " .. tostring(State.FailsCount))
            end
            if StatsLabels.Rate then
                local total = State.WinsCount + State.FailsCount
                local rate = total > 0 and math.floor((State.WinsCount / total) * 100) or 0
                StatsLabels.Rate:SetTitle("อัตราสำเร็จ" .. ": " .. rate .. "%")
            end
            if StatsLabels.BestTime then
                StatsLabels.BestTime:SetTitle("เร็วสุด" .. ": " .. string.format("%.1f", State.BestRunTime) .. "s")
            end
            if StatsLabels.AvgTime then
                StatsLabels.AvgTime:SetTitle("เฉลี่ย" .. ": " .. string.format("%.1f", getAverageRunTime()) .. "s")
            end
            if StatsLabels.Ping then
                StatsLabels.Ping:SetTitle("ปิง" .. ": " .. getPing() .. "ms")
            end
            if StatsLabels.Speed then
                local speedText = State.MaxSpeedMode and "MAX" or tostring(State.FarmSpeed)
                StatsLabels.Speed:SetTitle("ความเร็ว" .. ": " .. speedText)
            end
            if StatsLabels.Respawns then
                StatsLabels.Respawns:SetTitle("เกิดใหม่" .. ": " .. tostring(State.RespawnCount))
            end
            if StatsLabels.Log then
                local logText = ""
                local start = math.max(1, #State.SessionLog - 9)
                for i = start, #State.SessionLog do
                    logText = logText .. State.SessionLog[i].time .. " | " .. State.SessionLog[i].message .. "\n"
                end
                StatsLabels.Log:SetDesc(logText)
            end
        end)
        if not ok then
            warn("[xEz Hub] Stats updater error:", err)
        end
    end
end)


-- MAIN TAB


TabMain:Paragraph({
    Title = "xEz Hub v" .. SCRIPT_VERSION,
    Desc = "ฟาร์ม Build a Boat อัตโนมัติ",
    Image = "circle"
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
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(value)
        State.WalkSpeed = value
        local h = getHumanoid()
        if h then pcall(function() h.WalkSpeed = value end) end
    end
})

TabMain:Slider({
    Title = "แรงกระโดด",
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(value)
        State.JumpPower = value
        local h = getHumanoid()
        if h then pcall(function() h.JumpPower = value end) end
    end
})

TabMain:Toggle({
    Title = "กระโดดไม่จำกัด",
    Default = false,
    Callback = function(value) State.InfJump = value end
})

TabMain:Toggle({
    Title = "ทะลุของ",
    Default = false,
    Callback = function(value)
        State.NoClip = value
        toggleNoClip(value)
    end
})

TabMain:Toggle({
    Title = "บิน" .. " (WASD + Space/Ctrl)",
    Default = false,
    Callback = function(value)
        State.Fly = value
        toggleFly(value)
    end
})

TabMain:Slider({
    Title = "ความเร็วบิน",
    Value = { Min = 30, Max = 500, Default = 100 },
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
    Value = 1,
    Callback = function(value) State.SelectedChest = value end
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
    Default = true,
    Callback = function(value)
        State.AntiAFK = value
        toggleAntiAFK(value)
    end
})

toggleAntiAFK(true)

TabMain:Toggle({
    Title = "กันหลุด (กด K)",
    Default = true,
    Callback = function(value)
        State.AntiAFKKey = value
        toggleAntiAFKKey(value)
    end
})

toggleAntiAFKKey(true)

TabMain:Toggle({
    Title = "กันเตะ",
    Default = false,
    Callback = function(value)
        State.AntiKick = value
        toggleAntiKick(value)
    end
})

TabMain:Toggle({
    Title = "กันกระเด็น",
    Default = false,
    Callback = function(value)
        State.AntiFling = value
        toggleAntiFling(value)
    end
})

TabMain:Toggle({
    Title = "จับแอดมิน",
    Default = true,
    Callback = function(value) State.StaffDetector = value end
})

TabMain:Toggle({
    Title = "เข้าห้องเดิม",
    Default = true,
    Callback = function(value) State.AutoRejoin = value end
})

TabMain:Button({
    Title = "เปลี่ยนห้อง",
    Callback = function() task.spawn(serverHop) end
})


-- SETTINGS TAB


TabSettings:Paragraph({
    Title = "ตั้งค่า",
    Desc = "ปรับความเร็ว หน่วง และอื่นๆ",
    Image = "circle"
})


TabSettings:Section({ Title = "ปรับความเร็ว" })

TabSettings:Toggle({
    Title = "โหมดเร็วสุด",
    Default = false,
    Callback = function(value)
        State.MaxSpeedMode = value
        if value then notify("Speed", "เปิดโหมดเร็วสุด", 2)
        else notify("Speed", "ปิดโหมดเร็วสุด", 2) end
    end
})

TabSettings:Slider({
    Title = "ความเร็วฟาร์ม" .. " (studs/sec)",
    Value = { Min = 50, Max = 10000, Default = 900 },
    Callback = function(value) State.FarmSpeed = value end
})

TabSettings:Section({ Title = "ปรับหน่วง" })

TabSettings:Slider({
    Title = "หน่วงตอนบิน",
    Value = { Min = 1, Max = 50, Default = 2 },
    Callback = function(value) State.StepDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงหลังเปิดกล่อง",
    Value = { Min = 10, Max = 200, Default = 50 },
    Callback = function(value) State.ChestDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงก่อนตาย",
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(value) State.ResetDelay = value / 100 end
})

TabSettings:Slider({
    Title = "หน่วงหลังเกิด",
    Value = { Min = 10, Max = 500, Default = 100 },
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
        notify("Preset", "ตั้งค่าเรียบร้อย", 2)
    end
})

TabSettings:Section({ Title = "การบิน" })

TabSettings:Toggle({
    Title = "ปิดแรงโน้มถ่วง",
    Default = true,
    Callback = function(value)
        State.GravityZero = value
        if not value then
            Workspace.Gravity = GRAVITY_NORMAL
        end
    end
})

TabSettings:Slider({
    Title = "ความสูงบิน",
    Value = { Min = 20, Max = 200, Default = 72 },
    Callback = function(value) State.FlightHeight = value end
})

TabSettings:Section({ Title = "ประสิทธิภาพ" })

TabSettings:Toggle({
    Title = "จอดำ",
    Default = false,
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
    Default = true,
    Callback = function(value) State.MemoryCleanup = value end
})

TabSettings:Toggle({
    Title = "เพิ่ม FPS",
    Default = false,
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
    Default = false,
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
    Image = "circle"
})

TabStats:Section({ Title = "สถิติ" })

StatsLabels.Uptime = TabStats:Paragraph({ Title = "เวลาเปิด" .. ": 00:00:00", Desc = "", Image = "circle" })
StatsLabels.Wins = TabStats:Paragraph({ Title = "ชนะ" .. ": 0", Desc = "", Image = "circle" })
StatsLabels.Fails = TabStats:Paragraph({ Title = "พลาด" .. ": 0", Desc = "", Image = "circle" })
StatsLabels.Rate = TabStats:Paragraph({ Title = "อัตราสำเร็จ" .. ": 0%", Desc = "", Image = "circle" })
StatsLabels.BestTime = TabStats:Paragraph({ Title = "เร็วสุด" .. ": 0.0s", Desc = "", Image = "circle" })
StatsLabels.AvgTime = TabStats:Paragraph({ Title = "เฉลี่ย" .. ": 0.0s", Desc = "", Image = "circle" })
StatsLabels.Ping = TabStats:Paragraph({ Title = "ปิง" .. ": 0ms", Desc = "", Image = "circle" })
StatsLabels.Speed = TabStats:Paragraph({ Title = "ความเร็ว" .. ": 900", Desc = "", Image = "circle" })
StatsLabels.Respawns = TabStats:Paragraph({ Title = "เกิดใหม่" .. ": 0", Desc = "", Image = "circle" })

TabStats:Button({
    Title = "ล้างสถิติ",
    Callback = function()
        State.WinsCount = 0
        State.FailsCount = 0
        State.SessionStart = tick()
        State.RunTimes = {}
        State.BestRunTime = 0
        State.RespawnCount = 0
        notify("สถิติ", "ล้างสถิติแล้ว", 2)
    end
})

TabStats:Section({ Title = "บันทึกกิจกรรม" })

StatsLabels.Log = TabStats:Paragraph({
    Title = "บันทึกกิจกรรม",
    Desc = "(ยังไม่มีบันทึก)",
    Image = "circle"
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
    Value = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text) State.WebhookURL = tostring(text or "") end
})

TabStats:Toggle({
    Title = "เปิดเว็บฮุค",
    Default = false,
    Callback = function(value) State.WebhookNotify = value end
})

TabStats:Toggle({
    Title = "ส่งแบบละเอียด",
    Default = true,
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
    Image = "circle"
})

TabCredits:Section({ Title = "เครดิต" })

TabCredits:Paragraph({
    Title = "ผู้สร้าง",
    Desc = CREATOR_NAME,
    Image = "circle"
})

TabCredits:Paragraph({
    Title = "ข้อมูลเวอร์ชัน",
    Desc = "xEz Hub v" .. SCRIPT_VERSION .. "\nBuild a Boat",
    Image = "circle"
})

TabCredits:Paragraph({
    Title = "เซิร์ฟเวอร์ Discord",
    Desc = DISCORD_URL,
    Image = "circle"
})

TabCredits:Paragraph({
    Title = "ขอบคุณพิเศษ",
    Desc = "dawid-scripts (Fluent UI)\nRoblox Community\nAll testers\nYou!",
    Image = "circle"
})

TabCredits:Button({
    Title = "เข้าร่วม Discord",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(DISCORD_URL) end
        end)
        notify("ดิสคอร์ด", "คัดลอกลิงก์ Discord แล้ว" .. "\n" .. DISCORD_URL, 5)
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


-- START


notify("xEz Hub", "v" .. SCRIPT_VERSION .. " | " .. "โหลดเสร็จ", 4)
addLog("Session started")

print("[xEz Hub] v" .. SCRIPT_VERSION .. " loaded. Fluent UI Dark Edition.")
print("[xEz Hub] Discord: " .. DISCORD_URL)

-- Cleanup profile card if the Fluent window is destroyed externally.
task.spawn(function()
    while FluentWindow and FluentWindow.Root and FluentWindow.Root.Parent do
        task.wait(2)
    end
    pcall(function()
        if ProfileGui then ProfileGui:Destroy() end
    end)
end)