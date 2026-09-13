local MAIN_URL = "https://raw.githubusercontent.com/ZenLunarDev/D204wpi-AWEaPa-IAVWB9982kldoi-HW4398-2Aw586/refs/heads/main/main.lua"
local ACCESS_KEY = "xEzShop :3"
local DISCORD_URL = "https://discord.gg/7MA4RK5aUU"
local CREATOR_NAME = "ZenLunarDev"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(0.2)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, gui = pcall(gethui)
        if ok and gui then
            return gui
        end
    end

    local ok = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
    end)

    if ok then
        return CoreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local parent = getGuiParent()

local old = parent:FindFirstChild("xEzShop_KeyGui")
if old then
    old:Destroy()
end


-- สี / ค่าพื้นฐาน


local COLORS = {
    Card = Color3.fromRGB(18, 18, 22),
    Card2 = Color3.fromRGB(24, 24, 29),
    Input = Color3.fromRGB(28, 28, 34),
    Stroke = Color3.fromRGB(58, 58, 68),
    Text = Color3.fromRGB(245, 245, 248),
    Muted = Color3.fromRGB(160, 160, 172),
    Subtle = Color3.fromRGB(108, 108, 120),
    Accent = Color3.fromRGB(125, 190, 255),
    AccentHover = Color3.fromRGB(150, 205, 255),
    Danger = Color3.fromRGB(240, 100, 105),
    Success = Color3.fromRGB(110, 220, 150),
}

local function tween(object, duration, properties, style, direction)
    local t = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    t:Play()
    return t
end

local function addCorner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = object
    return c
end

local function addStroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.Stroke
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function addPadding(object, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = object
    return p
end


-- สร้าง GUI


local Gui = Instance.new("ScreenGui")
Gui.Name = "xEzShop_KeyGui"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = parent

-- ไม่มีพื้นหลังครอบจอ ตามที่ขอ

local Shadow = Instance.new("Frame")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, 10)
Shadow.Size = UDim2.fromOffset(560, 390)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.75
Shadow.BorderSizePixel = 0
Shadow.Parent = Gui
addCorner(Shadow, 16)

local Card = Instance.new("Frame")
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.Position = UDim2.fromScale(0.5, 0.5)
Card.Size = UDim2.fromOffset(560, 390)
Card.BackgroundColor3 = COLORS.Card
Card.BorderSizePixel = 0
Card.Parent = Gui
addCorner(Card, 16)
addStroke(Card, COLORS.Stroke, 0.15, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = 0.92
Scale.Parent = Card

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.Parent = Card

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(45, 8)
Title.Size = UDim2.new(1, -160, 0, 22)
Title.BackgroundTransparency = 1
Title.Text = "xEz Shop | Key System"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextColor3 = COLORS.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.fromOffset(66, 29)
Subtitle.Size = UDim2.new(1, -160, 0, 18)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ระบบยืนยันคีย์ฟรี"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = COLORS.Subtle
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local MinButton = Instance.new("TextButton")
MinButton.AnchorPoint = Vector2.new(1, 0)
MinButton.Position = UDim2.new(1, -48, 0, 10)
MinButton.Size = UDim2.fromOffset(32, 32)
MinButton.BackgroundColor3 = COLORS.Card2
MinButton.BorderSizePixel = 0
MinButton.Text = "—"
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 16
MinButton.TextColor3 = COLORS.Muted
MinButton.AutoButtonColor = false
MinButton.Parent = Header
addCorner(MinButton, 9)

local CloseButton = Instance.new("TextButton")
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Position = UDim2.new(1, -10, 0, 10)
CloseButton.Size = UDim2.fromOffset(32, 32)
CloseButton.BackgroundColor3 = COLORS.Card2
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = COLORS.Muted
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header
addCorner(CloseButton, 9)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(20, 64)
Content.Size = UDim2.new(1, -40, 1, -84)
Content.BackgroundTransparency = 1
Content.Parent = Card


-- โปรไฟล์ผู้เล่น


local Profile = Instance.new("Frame")
Profile.Size = UDim2.new(1, 0, 0, 68)
Profile.BackgroundColor3 = COLORS.Card2
Profile.BorderSizePixel = 0
Profile.Parent = Content
addCorner(Profile, 12)

local Avatar = Instance.new("ImageLabel")
Avatar.Position = UDim2.fromOffset(10, 10)
Avatar.Size = UDim2.fromOffset(48, 48)
Avatar.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
Avatar.BorderSizePixel = 0
Avatar.Parent = Profile
addCorner(Avatar, 12)

local AvatarStroke = addStroke(Avatar, COLORS.Stroke, 0.15, 1)

local AvatarText = Instance.new("TextLabel")
AvatarText.Size = UDim2.fromScale(1, 1)
AvatarText.BackgroundTransparency = 1
AvatarText.Text = "..."
AvatarText.Font = Enum.Font.GothamBold
AvatarText.TextSize = 14
AvatarText.TextColor3 = COLORS.Muted
AvatarText.Parent = Avatar

local PlayerTitle = Instance.new("TextLabel")
PlayerTitle.Position = UDim2.fromOffset(70, 11)
PlayerTitle.Size = UDim2.new(1, -160, 0, 22)
PlayerTitle.BackgroundTransparency = 1
PlayerTitle.Text = LocalPlayer.DisplayName
PlayerTitle.Font = Enum.Font.GothamBold
PlayerTitle.TextSize = 15
PlayerTitle.TextColor3 = COLORS.Text
PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayerTitle.TextTruncate = Enum.TextTruncate.AtEnd
PlayerTitle.Parent = Profile

local PlayerName = Instance.new("TextLabel")
PlayerName.Position = UDim2.fromOffset(70, 34)
PlayerName.Size = UDim2.new(1, -160, 0, 18)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = "@" .. LocalPlayer.Name
PlayerName.Font = Enum.Font.Gotham
PlayerName.TextSize = 12
PlayerName.TextColor3 = COLORS.Subtle
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
PlayerName.Parent = Profile

-- โหลดรูปโปรไฟล์จริงของ Roblox

task.spawn(function()
    local ok, image = pcall(function()
        local content, ready = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size180x180
        )
        return content
    end)

    if ok and image and image ~= "" then
        Avatar.Image = image
        AvatarText.Visible = false
    else
        AvatarText.Text = string.upper(string.sub(LocalPlayer.DisplayName, 1, 1))
    end
end)


-- คีย์


local Label = Instance.new("TextLabel")
Label.Position = UDim2.fromOffset(0, 80)
Label.Size = UDim2.new(1, 0, 0, 20)
Label.BackgroundTransparency = 1
Label.Text = "กรอกคีย์เพื่อใช้งาน"
Label.Font = Enum.Font.GothamMedium
Label.TextSize = 13
Label.TextColor3 = COLORS.Muted
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Content

local Input = Instance.new("TextBox")
Input.Position = UDim2.fromOffset(0, 104)
Input.Size = UDim2.new(1, 0, 0, 44)
Input.BackgroundColor3 = COLORS.Input
Input.BorderSizePixel = 0
Input.ClearTextOnFocus = false
Input.PlaceholderText = "ใส่คีย์ที่นี่!!"
Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 112)
Input.Text = ""
Input.Font = Enum.Font.Gotham
Input.TextSize = 13
Input.TextColor3 = COLORS.Text
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.Parent = Content
addCorner(Input, 10)
addStroke(Input, COLORS.Stroke, 0.25, 1)
addPadding(Input, 13, 13, 0, 0)

local Button = Instance.new("TextButton")
Button.Position = UDim2.fromOffset(0, 156)
Button.Size = UDim2.new(1, 0, 0, 44)
Button.BackgroundColor3 = COLORS.Accent
Button.BorderSizePixel = 0
Button.Text = "ยืนยันคีย์"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 13
Button.TextColor3 = Color3.fromRGB(15, 18, 24)
Button.AutoButtonColor = false
Button.Parent = Content
addCorner(Button, 10)

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(0, 207)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.BackgroundTransparency = 1
Status.Text = "คีย์ฟรีพร้อมใช้งาน"
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextColor3 = COLORS.Subtle
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Content

local CopyButton = Instance.new("TextButton")
CopyButton.Position = UDim2.new(1, -126, 1, -30)
CopyButton.Size = UDim2.fromOffset(126, 28)
CopyButton.BackgroundColor3 = COLORS.Card2
CopyButton.BorderSizePixel = 0
CopyButton.Text = "คัดลอกคีย์"
CopyButton.Font = Enum.Font.GothamMedium
CopyButton.TextSize = 11
CopyButton.TextColor3 = COLORS.Muted
CopyButton.AutoButtonColor = false
CopyButton.Parent = Content
addCorner(CopyButton, 8)

local CreditButton = Instance.new("TextButton")
CreditButton.Position = UDim2.fromOffset(0, 242)
CreditButton.Size = UDim2.fromOffset(118, 28)
CreditButton.BackgroundTransparency = 1
CreditButton.Text = "เครดิต: ZenLunarDev"
CreditButton.TextTruncate = Enum.TextTruncate.AtEnd
CreditButton.Font = Enum.Font.Gotham
CreditButton.TextSize = 10
CreditButton.TextColor3 = COLORS.Subtle
CreditButton.TextXAlignment = Enum.TextXAlignment.Left
CreditButton.AutoButtonColor = false
CreditButton.Parent = Content


-- หน้าคำขอบคุณ / เครดิต


local CreditPanel = Instance.new("Frame")
CreditPanel.Visible = false
CreditPanel.AnchorPoint = Vector2.new(0.5, 0.5)
CreditPanel.Position = UDim2.fromScale(0.5, 0.5)
CreditPanel.Size = UDim2.fromOffset(430, 250)
CreditPanel.BackgroundColor3 = COLORS.Card
CreditPanel.BorderSizePixel = 0
CreditPanel.Parent = Gui
addCorner(CreditPanel, 14)
addStroke(CreditPanel, COLORS.Stroke, 0.1, 1)

local CreditTitle = Instance.new("TextLabel")
CreditTitle.Position = UDim2.fromOffset(20, 18)
CreditTitle.Size = UDim2.new(1, -60, 0, 28)
CreditTitle.BackgroundTransparency = 1
CreditTitle.Text = "เครดิต"
CreditTitle.Font = Enum.Font.GothamBold
CreditTitle.TextSize = 18
CreditTitle.TextColor3 = COLORS.Text
CreditTitle.TextXAlignment = Enum.TextXAlignment.Left
CreditTitle.Parent = CreditPanel

local CreditClose = Instance.new("TextButton")
CreditClose.AnchorPoint = Vector2.new(1, 0)
CreditClose.Position = UDim2.new(1, -12, 0, 12)
CreditClose.Size = UDim2.fromOffset(30, 30)
CreditClose.BackgroundColor3 = COLORS.Card2
CreditClose.BorderSizePixel = 0
CreditClose.Text = "×"
CreditClose.Font = Enum.Font.GothamBold
CreditClose.TextSize = 18
CreditClose.TextColor3 = COLORS.Muted
CreditClose.AutoButtonColor = false
CreditClose.Parent = CreditPanel
addCorner(CreditClose, 8)

local CreditInfo = Instance.new("TextLabel")
CreditInfo.Position = UDim2.fromOffset(20, 60)
CreditInfo.Size = UDim2.new(1, -40, 0, 72)
CreditInfo.BackgroundTransparency = 1
CreditInfo.Text = "ผู้ัฒนา: ZenLunarDev\nขอบคุณที่ใช้งานครับ!"
CreditInfo.Font = Enum.Font.Gotham
CreditInfo.TextSize = 13
CreditInfo.LineHeight = 1.15
CreditInfo.TextColor3 = COLORS.Muted
CreditInfo.TextWrapped = true
CreditInfo.TextXAlignment = Enum.TextXAlignment.Left
CreditInfo.TextYAlignment = Enum.TextYAlignment.Top
CreditInfo.Parent = CreditPanel

local DiscordButton = Instance.new("TextButton")
DiscordButton.Position = UDim2.fromOffset(20, 146)
DiscordButton.Size = UDim2.new(1, -40, 0, 42)
DiscordButton.BackgroundColor3 = COLORS.Card2
DiscordButton.BorderSizePixel = 0
DiscordButton.Text = "คัดลอก Discord"
DiscordButton.Font = Enum.Font.GothamMedium
DiscordButton.TextSize = 12
DiscordButton.TextColor3 = COLORS.Text
DiscordButton.AutoButtonColor = false
DiscordButton.Parent = CreditPanel
addCorner(DiscordButton, 9)
addStroke(DiscordButton, COLORS.Stroke, 0.2, 1)

local DiscordText = Instance.new("TextLabel")
DiscordText.Position = UDim2.fromOffset(20, 199)
DiscordText.Size = UDim2.new(1, -40, 0, 28)
DiscordText.BackgroundTransparency = 1
DiscordText.Text = "discord.gg/7MA4RK5aUU"
DiscordText.Font = Enum.Font.Gotham
DiscordText.TextSize = 10
DiscordText.TextColor3 = COLORS.Subtle
DiscordText.TextXAlignment = Enum.TextXAlignment.Center
DiscordText.Parent = CreditPanel


-- การแจ้งเตือน / แอนิเมชัน


local busy = false
local minimized = false

local function setStatus(text, color)
    Status.Text = text
    Status.TextColor3 = color or COLORS.Subtle
end

local function shake(object)
    local base = object.Position
    task.spawn(function()
        local sequence = {7, -7, 5, -5, 3, -3, 0}
        for _, x in ipairs(sequence) do
            tween(object, 0.045, {Position = base + UDim2.fromOffset(x, 0)}, Enum.EasingStyle.Linear)
            task.wait(0.045)
        end
        object.Position = base
    end)
end

local function openCredit()
    CreditPanel.Visible = true
    CreditPanel.Size = UDim2.fromOffset(410, 235)
    CreditPanel.BackgroundTransparency = 1
    tween(CreditPanel, 0.25, {
        Size = UDim2.fromOffset(430, 250),
        BackgroundTransparency = 0,
    })
end

local function closeCredit()
    local t = tween(CreditPanel, 0.18, {
        Size = UDim2.fromOffset(410, 235),
        BackgroundTransparency = 1,
    })
    t.Completed:Connect(function()
        CreditPanel.Visible = false
    end)
end

-- เปิดด้วยแอนิเมชัน
Card.BackgroundTransparency = 1
Shadow.BackgroundTransparency = 1

tween(Shadow, 0.28, {BackgroundTransparency = 0.75})
tween(Card, 0.28, {BackgroundTransparency = 0})
tween(Scale, 0.32, {Scale = 1}, Enum.EasingStyle.Back)

local function loadMain()
    if busy then return end
    busy = true

    Button.Text = "กำลังตรวจสอบ..."
    setStatus("คีย์ถูกต้อง • กำลังเปิด xEz Hub", COLORS.Success)
    tween(Button, 0.15, {BackgroundColor3 = Color3.fromRGB(100, 205, 140)})

    task.wait(0.3)

    local ok, code = pcall(function()
        return game:HttpGet(MAIN_URL)
    end)

    if not ok or type(code) ~= "string" or code == "" then
        busy = false
        Button.Text = "ยืนยันคีย์"
        tween(Button, 0.15, {BackgroundColor3 = COLORS.Accent})
        setStatus("โหลด main.lua ไม่สำเร็จ", COLORS.Danger)
        return
    end

    local fn, err = loadstring(code)
    if not fn then
        busy = false
        Button.Text = "ยืนยันคีย์"
        tween(Button, 0.15, {BackgroundColor3 = COLORS.Accent})
        setStatus("main.lua มีข้อผิดพลาด: " .. tostring(err), COLORS.Danger)
        return
    end

    tween(Scale, 0.18, {Scale = 0.94})
    tween(Card, 0.22, {BackgroundTransparency = 1})
    tween(Shadow, 0.22, {BackgroundTransparency = 1})

    task.wait(0.23)
    Gui:Destroy()

    task.spawn(function()
        local runOk, runErr = pcall(fn)
        if not runOk then
            warn("[xEzShop] main.lua error:", runErr)
        end
    end)
end


-- ปุ่มต่าง ๆ


Button.MouseEnter:Connect(function()
    if not busy then
        tween(Button, 0.15, {BackgroundColor3 = COLORS.AccentHover})
    end
end)

Button.MouseLeave:Connect(function()
    if not busy then
        tween(Button, 0.15, {BackgroundColor3 = COLORS.Accent})
    end
end)

Button.MouseButton1Click:Connect(function()
    if busy then return end

    if Input.Text == ACCESS_KEY then
        loadMain()
    else
        setStatus("คีย์ไม่ถูกต้อง", COLORS.Danger)
        shake(Card)
    end
end)

CopyButton.MouseEnter:Connect(function()
    tween(CopyButton, 0.15, {BackgroundColor3 = Color3.fromRGB(33, 33, 40)})
end)

CopyButton.MouseLeave:Connect(function()
    tween(CopyButton, 0.15, {BackgroundColor3 = COLORS.Card2})
end)

CopyButton.MouseButton1Click:Connect(function()
    local copied = false
    pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(ACCESS_KEY)
            copied = true
        end
    end)

    if copied then
        setStatus("คัดลอกคีย์เรียบร้อยแล้ว", COLORS.Success)
    else
        setStatus("คัดลอกอัตโนมัติไม่สำเร็จ", COLORS.Danger)
    end
end)

CreditButton.MouseButton1Click:Connect(openCredit)
CreditClose.MouseButton1Click:Connect(closeCredit)

DiscordButton.MouseEnter:Connect(function()
    tween(DiscordButton, 0.15, {BackgroundColor3 = Color3.fromRGB(31, 31, 38)})
end)

DiscordButton.MouseLeave:Connect(function()
    tween(DiscordButton, 0.15, {BackgroundColor3 = COLORS.Card2})
end)

DiscordButton.MouseButton1Click:Connect(function()
    local copied = false
    pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(DISCORD_URL)
            copied = true
        end
    end)

    if copied then
        DiscordButton.Text = "คัดลอก Discord แล้ว"
        task.delay(1.6, function()
            if DiscordButton.Parent then
                DiscordButton.Text = "คัดลอก Discord"
            end
        end)
    else
        DiscordButton.Text = "คัดลอกไม่สำเร็จ"
        task.delay(1.6, function()
            if DiscordButton.Parent then
                DiscordButton.Text = "คัดลอก Discord"
            end
        end)
    end
end)

MinButton.MouseEnter:Connect(function()
    tween(MinButton, 0.15, {BackgroundColor3 = Color3.fromRGB(34, 34, 41), TextColor3 = COLORS.Text})
end)

MinButton.MouseLeave:Connect(function()
    tween(MinButton, 0.15, {BackgroundColor3 = COLORS.Card2, TextColor3 = COLORS.Muted})
end)

CloseButton.MouseEnter:Connect(function()
    tween(CloseButton, 0.15, {BackgroundColor3 = Color3.fromRGB(65, 32, 35), TextColor3 = Color3.fromRGB(255, 130, 135)})
end)

CloseButton.MouseLeave:Connect(function()
    tween(CloseButton, 0.15, {BackgroundColor3 = COLORS.Card2, TextColor3 = COLORS.Muted})
end)

local function setMinimized(value)
    minimized = value

    if value then
        Content.Visible = false
        tween(Card, 0.22, {Size = UDim2.fromOffset(560, 56)})
        tween(Shadow, 0.22, {Size = UDim2.fromOffset(560, 56)})
        MinButton.Text = "+"
    else
        tween(Card, 0.22, {Size = UDim2.fromOffset(560, 390)})
        tween(Shadow, 0.22, {Size = UDim2.fromOffset(560, 390)})
        task.delay(0.13, function()
            if not minimized and Content.Parent then
                Content.Visible = true
            end
        end)
        MinButton.Text = "—"
    end
end

MinButton.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

CloseButton.MouseButton1Click:Connect(function()
    local t1 = tween(Scale, 0.2, {Scale = 0.92})
    tween(Card, 0.18, {BackgroundTransparency = 1})
    tween(Shadow, 0.18, {BackgroundTransparency = 1})
    t1.Completed:Connect(function()
        if Gui.Parent then
            Gui:Destroy()
        end
    end)
end)

Input.Focused:Connect(function()
    tween(Input, 0.15, {BackgroundColor3 = Color3.fromRGB(31, 31, 38)})
end)

Input.FocusLost:Connect(function(enterPressed)
    tween(Input, 0.15, {BackgroundColor3 = COLORS.Input})
    if enterPressed then
        Button:Activate()
    end
end)

do
    local dragging = false
    local dragStart
    local startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Card.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        Card.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        Shadow.Position = Card.Position + UDim2.fromOffset(0, 10)
    end)
end

Input:CaptureFocus()
