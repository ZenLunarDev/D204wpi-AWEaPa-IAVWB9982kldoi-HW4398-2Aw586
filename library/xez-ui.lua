--[[
    ╔══════════════════════════════════════════╗
    ║         ROPHUB UI LIBRARY v1.0           ║
    ║      Modern UI Library for Roblox        ║
    ╚══════════════════════════════════════════╝
    
    วิธีใช้:
    local Library = loadstring(game:HttpGet("YOUR_URL_HERE"))()
    local Window = Library:CreateWindow("My Hub")
    local Tab = Window:CreateTab("Main")
    Tab:CreateButton("Click Me", function() print("Clicked!") end)
]]

-- ═══════════════════ SERVICES ═══════════════════
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════ CONFIG ═══════════════════
local Config = {
    Title = "Script Hub",
    Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(28, 28, 35),
        Tertiary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 165),
        Border = Color3.fromRGB(45, 45, 55),
        Toggle = Color3.fromRGB(45, 45, 55),
        ToggleOn = Color3.fromRGB(88, 101, 242),
        Danger = Color3.fromRGB(237, 66, 69),
        Success = Color3.fromRGB(59, 165, 93),
        Warning = Color3.fromRGB(250, 166, 26),
    },
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

-- ═══════════════════ UTILITIES ═══════════════════
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, time, properties, style, direction)
    local tweenInfo = TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function Round(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

local function Stroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

local function Pad(instance, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding)
    pad.PaddingBottom = UDim.new(0, padding)
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.Parent = instance
    return pad
end

local function GetGuiParent()
    if RunService:IsStudio() then
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    local success, result = pcall(function()
        return CoreGui
    end)
    return success and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════════════════ MAIN LIBRARY ═══════════════════
local Library = {}
Library.Flags = {}
Library.Connections = {}
Library.Notifications = {}

-- ═══════════════════ NOTIFICATION SYSTEM ═══════════════════
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local text = options.Text or ""
    local duration = options.Duration or 4
    local type_ = options.Type or "info"
    
    local typeColors = {
        info = Config.Theme.Accent,
        success = Config.Theme.Success,
        warning = Config.Theme.Warning,
        error = Config.Theme.Danger,
    }
    local typeIcons = {
        info = "ℹ",
        success = "✓",
        warning = "⚠",
        error = "✕",
    }
    
    if not Library.NotificationGui then return end
    
    local notif = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 0, #Library.Notifications * 90 + 20),
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Library.NotificationGui,
    })
    Round(notif, 8)
    Stroke(notif, Config.Theme.Border, 1)
    
    local accent = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = typeColors[type_],
        BorderSizePixel = 0,
        Parent = notif,
    })
    Round(accent, 2)
    
    Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 20, 0, 12),
        BackgroundTransparency = 1,
        Text = typeIcons[type_] .. "  " .. title,
        TextColor3 = Config.Theme.Text,
        Font = Config.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 36),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Theme.SubText,
        Font = Config.Font,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notif,
    })
    
    notif.Position = UDim2.new(1, 320, 0, #Library.Notifications * 90 + 20)
    Tween(notif, 0.3, {Position = UDim2.new(1, -320, 0, #Library.Notifications * 90 + 20)}, Enum.EasingStyle.Back)
    
    table.insert(Library.Notifications, notif)
    
    task.delay(duration, function()
        Tween(notif, 0.3, {Position = UDim2.new(1, 320, 0, notif.Position.Y.Offset)})
        task.wait(0.3)
        local index = table.find(Library.Notifications, notif)
        if index then
            table.remove(Library.Notifications, index)
        end
        notif:Destroy()
        -- Reposition remaining
        for i, n in ipairs(Library.Notifications) do
            Tween(n, 0.2, {Position = UDim2.new(1, -320, 0, (i - 1) * 90 + 20)})
        end
    end)
end

-- ═══════════════════ WINDOW ═══════════════════
function Library:CreateWindow(title)
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    
    local ScreenGui = Create("ScreenGui", {
        Name = "RophubUI_" .. tostring(math.random(1, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GetGuiParent(),
    })
    Library.ScreenGui = ScreenGui
    
    -- Notification container
    Library.NotificationGui = Create("Frame", {
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -320, 0, 0),
        BackgroundTransparency = 1,
        Parent = ScreenGui,
    })
    
    -- Main frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    Round(Main, 10)
    Stroke(Main, Config.Theme.Border, 1)
    
    -- Top bar (draggable)
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Round(TopBar, 10)
    
    local TopBarFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title or Config.Title,
        TextColor3 = Config.Theme.Text,
        Font = Config.FontBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })
    
    -- Minimize button
    local MinBtn = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = Config.Theme.Tertiary,
        BorderSizePixel = 0,
        Text = "—",
        TextColor3 = Config.Theme.Text,
        Font = Config.FontBold,
        TextSize = 14,
        Parent = TopBar,
    })
    Round(MinBtn, 6)
    
    -- Close button
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -36, 0, 5),
        BackgroundColor3 = Config.Theme.Danger,
        BorderSizePixel = 0,
        Text = "✕",
        TextColor3 = Config.Theme.Text,
        Font = Config.FontBold,
        TextSize = 14,
        Parent = TopBar,
    })
    Round(CloseBtn, 6)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
        task.wait(0.2)
        ScreenGui:Destroy()
    end)
    
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, 0.3, {Size = UDim2.new(0, 560, 0, 40)})
            MinBtn.Text = "□"
        else
            Tween(Main, 0.3, {Size = UDim2.new(0, 560, 0, 380)})
            MinBtn.Text = "—"
        end
    end)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, -48),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundColor3 = Config.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Round(Sidebar, 8)
    
    local TabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -16),
        Position = UDim2.new(0, 4, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar,
    })
    
    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList,
    })
    
    local Container = Create("Frame", {
        Name = "Container",
        Size = UDim2.new(1, -164, 1, -56),
        Position = UDim2.new(0, 156, 0, 48),
        BackgroundTransparency = 1,
        Parent = Main,
    })
    
    -- Resize handle
    local ResizeHandle = Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Main,
    })
    Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7149227702",
        ImageColor3 = Config.Theme.SubText,
        Parent = ResizeHandle,
    })
    
    local resizing, resizeStart, resizeStartSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = Main.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newX = math.max(400, resizeStartSize.X.Offset + delta.X)
            local newY = math.max(300, resizeStartSize.Y.Offset + delta.Y)
            Main.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- Keybind toggle
    local toggled = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggled = not toggled
            ScreenGui.Enabled = toggled
        end
    end)
    
    local Window = {}
    local Tabs = {}
    local activeTab = nil
    
    function Window:CreateTab(name)
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Config.Theme.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "  " .. name,
            TextColor3 = Config.Theme.SubText,
            Font = Config.Font,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabList,
        })
        Round(TabButton, 6)
        
        local indicator = Create("Frame", {
            Size = UDim2.new(0, 3, 0, 16),
            Position = UDim2.new(0, 4, 0.5, -8),
            BackgroundColor3 = Config.Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = TabButton,
        })
        Round(indicator, 2)
        
        local TabContent = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Config.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = Container,
        })
        
        local ContentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent,
        })
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local Tab = {Frame = TabContent, Button = TabButton}
        Tabs[name] = Tab
        
        -- Auto-select first tab
        if not activeTab then
            activeTab = name
            TabContent.Visible = true
            indicator.Visible = true
            TabButton.TextColor3 = Config.Theme.Text
            TabButton.BackgroundTransparency = 0
        end
        
        TabButton.MouseButton1Click:Connect(function()
            for tabName, tabData in pairs(Tabs) do
                tabData.Frame.Visible = false
                tabData.Button.TextColor3 = Config.Theme.SubText
                tabData.Button.BackgroundTransparency = 1
                if tabData.Button:FindFirstChildOfClass("Frame") then
                    tabData.Button:FindFirstChildOfClass("Frame").Visible = false
                end
            end
            TabContent.Visible = true
            indicator.Visible = true
            TabButton.TextColor3 = Config.Theme.Text
            TabButton.BackgroundTransparency = 0
            activeTab = name
        end)
        
        TabButton.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(TabButton, 0.15, {BackgroundTransparency = 0.7})
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(TabButton, 0.15, {BackgroundTransparency = 1})
            end
        end)
        
        -- ═══ SECTION ═══
        function Tab:CreateSection(sectionName)
            local Section = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 24),
                BackgroundTransparency = 1,
                Parent = TabContent,
            })
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.upper(sectionName),
                TextColor3 = Config.Theme.SubText,
                Font = Config.FontBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section,
            })
        end
        
        -- ═══ BUTTON ═══
        function Tab:CreateButton(text, callback)
            local Button = Create("TextButton", {
                Size = UDim2.new(1, -8, 0, 34),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = TabContent,
            })
            Round(Button, 6)
            Stroke(Button, Config.Theme.Border, 1)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Button,
            })
            
            Button.MouseEnter:Connect(function()
                Tween(Button, 0.15, {BackgroundColor3 = Config.Theme.Tertiary})
            end)
            Button.MouseLeave:Connect(function()
                Tween(Button, 0.15, {BackgroundColor3 = Config.Theme.Secondary})
            end)
            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            
            return Button
        end
        
        -- ═══ TOGGLE ═══
        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            
            local ToggleFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 34),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = TabContent,
            })
            Round(ToggleFrame, 6)
            Stroke(ToggleFrame, Config.Theme.Border, 1)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame,
            })
            
            local ToggleBtn = Create("TextButton", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = state and Config.Theme.ToggleOn or Config.Theme.Toggle,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = ToggleFrame,
            })
            Round(ToggleBtn, 10)
            
            local Circle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = ToggleBtn,
            })
            Round(Circle, 8)
            
            local function SetState(newState)
                state = newState
                Tween(ToggleBtn, 0.2, {BackgroundColor3 = state and Config.Theme.ToggleOn or Config.Theme.Toggle})
                Tween(Circle, 0.2, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                Library.Flags[text] = state
                if callback then pcall(callback, state) end
            end
            
            ToggleBtn.MouseButton1Click:Connect(function()
                SetState(not state)
            end)
            
            Library.Flags[text] = state
            
            local obj = {Set = SetState, Get = function() return state end}
            return obj
        end
        
        -- ═══ SLIDER ═══
        function Tab:CreateSlider(text, min, max, default, callback)
            min = min or 0
            max = max or 100
            local value = default or min
            
            local SliderFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 50),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = TabContent,
            })
            Round(SliderFrame, 6)
            Stroke(SliderFrame, Config.Theme.Border, 1)
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 10, 0, 6),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame,
            })
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 6),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = Config.Theme.Accent,
                Font = Config.FontBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame,
            })
            
            local SliderBar = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 34),
                BackgroundColor3 = Config.Theme.Tertiary,
                BorderSizePixel = 0,
                Parent = SliderFrame,
            })
            Round(SliderBar, 3)
            
            local Fill = Create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Config.Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderBar,
            })
            Round(Fill, 3)
            
            local Circle = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = SliderBar,
            })
            Round(Circle, 7)
            Stroke(Circle, Config.Theme.Accent, 2)
            
            local dragging = false
            local function UpdateFromInput(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos + 0.5)
                ValueLabel.Text = tostring(value)
                Tween(Fill, 0.05, {Size = UDim2.new(pos, 0, 1, 0)})
                Tween(Circle, 0.05, {Position = UDim2.new(pos, -7, 0.5, -7)})
                Library.Flags[text] = value
                if callback then pcall(callback, value) end
            end
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateFromInput(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateFromInput(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            Library.Flags[text] = value
            
            local obj = {
                Set = function(v)
                    v = math.clamp(v, min, max)
                    value = v
                    local pos = (v - min) / (max - min)
                    ValueLabel.Text = tostring(v)
                    Tween(Fill, 0.1, {Size = UDim2.new(pos, 0, 1, 0)})
                    Tween(Circle, 0.1, {Position = UDim2.new(pos, -7, 0.5, -7)})
                    Library.Flags[text] = v
                    if callback then pcall(callback, v) end
                end,
                Get = function() return value end,
            }
            return obj
        end
        
        -- ═══ TEXTBOX ═══
        function Tab:CreateTextbox(text, placeholder, callback)
            local BoxFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 54),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = TabContent,
            })
            Round(BoxFrame, 6)
            Stroke(BoxFrame, Config.Theme.Border, 1)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 4),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BoxFrame,
            })
            
            local Box = Create("TextBox", {
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.new(0, 10, 0, 24),
                BackgroundColor3 = Config.Theme.Tertiary,
                BorderSizePixel = 0,
                Text = "",
                PlaceholderText = placeholder or "Type here...",
                PlaceholderColor3 = Config.Theme.SubText,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = BoxFrame,
            })
            Round(Box, 4)
            Pad(Box, 6)
            
            Box.Focused:Connect(function()
                Tween(Box, 0.15, {BackgroundColor3 = Config.Theme.Background})
            end)
            Box.FocusLost:Connect(function(enter)
                Tween(Box, 0.15, {BackgroundColor3 = Config.Theme.Tertiary})
                if callback then pcall(callback, Box.Text, enter) end
            end)
            
            Library.Flags[text] = ""
            
            return {
                Set = function(v) Box.Text = v; Library.Flags[text] = v end,
                Get = function() return Box.Text end,
            }
        end
        
        -- ═══ DROPDOWN ═══
        function Tab:CreateDropdown(text, options, default, callback)
            options = options or {}
            local selected = default or options[1]
            local isOpen = false
            
            local DropFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 34),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                Parent = TabContent,
            })
            Round(DropFrame, 6)
            Stroke(DropFrame, Config.Theme.Border, 1)
            
            local DropBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropFrame,
            })
            
            Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropBtn,
            })
            
            local SelectedLabel = Create("TextLabel", {
                Size = UDim2.new(0, 100, 1, 0),
                Position = UDim2.new(1, -140, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(selected),
                TextColor3 = Config.Theme.Accent,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = DropBtn,
            })
            
            Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -25, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Config.Theme.SubText,
                Font = Config.Font,
                TextSize = 10,
                Parent = DropBtn,
            })
            
            local List = Create("Frame", {
                Size = UDim2.new(1, 0, 0, math.min(#options * 28, 150)),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 10,
                Parent = DropFrame,
            })
            Round(List, 6)
            Stroke(List, Config.Theme.Border, 1)
            
            local ListScroll = Create("ScrollingFrame", {
                Size = UDim2.new(1, -8, 1, -8),
                Position = UDim2.new(0, 4, 0, 4),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Config.Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ZIndex = 10,
                Parent = List,
            })
            
            local ListLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = ListScroll,
            })
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            for _, option in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Config.Theme.Tertiary,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = "  " .. tostring(option),
                    TextColor3 = Config.Theme.Text,
                    Font = Config.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                    Parent = ListScroll,
                })
                Round(OptBtn, 4)
                
                OptBtn.MouseEnter:Connect(function()
                    Tween(OptBtn, 0.1, {BackgroundTransparency = 0})
                end)
                OptBtn.MouseLeave:Connect(function()
                    Tween(OptBtn, 0.1, {BackgroundTransparency = 1})
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = option
                    SelectedLabel.Text = tostring(option)
                    Library.Flags[text] = option
                    if callback then pcall(callback, option) end
                    isOpen = false
                    List.Visible = false
                end)
            end
            
            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                List.Visible = isOpen
            end)
            
            Library.Flags[text] = selected
            
            return {
                Set = function(v)
                    selected = v
                    SelectedLabel.Text = tostring(v)
                    Library.Flags[text] = v
                    if callback then pcall(callback, v) end
                end,
                Get = function() return selected end,
            }
        end
        
        -- ═══ COLOR PICKER ═══
        function Tab:CreateColorPicker(text, default, callback)
            local color = default or Color3.fromRGB(255, 255, 255)
            
            local ColorFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 34),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = TabContent,
            })
            Round(ColorFrame, 6)
            Stroke(ColorFrame, Config.Theme.Border, 1)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorFrame,
            })
            
            local ColorBtn = Create("TextButton", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Text = "",
                Parent = ColorFrame,
            })
            Round(ColorBtn, 4)
            Stroke(ColorBtn, Config.Theme.Border, 1)
            
            -- Simple color picker (RGB sliders popup)
            local popupOpen = false
            local Popup = Create("Frame", {
                Size = UDim2.new(0, 200, 0, 110),
                Position = UDim2.new(1, 10, 0.5, -55),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 20,
                Parent = ColorFrame,
            })
            Round(Popup, 6)
            Stroke(Popup, Config.Theme.Border, 1)
            
            local r, g, b = color.R * 255, color.G * 255, color.B * 255
            
            local function createRGBSlider(name, yPos, val, onChange)
                Create("TextLabel", {
                    Size = UDim2.new(0, 15, 0, 20),
                    Position = UDim2.new(0, 10, 0, yPos),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Theme.Text,
                    Font = Config.FontBold,
                    TextSize = 11,
                    Parent = Popup,
                })
                
                local bar = Create("Frame", {
                    Size = UDim2.new(1, -60, 0, 8),
                    Position = UDim2.new(0, 30, 0, yPos + 6),
                    BackgroundColor3 = Config.Theme.Tertiary,
                    BorderSizePixel = 0,
                    Parent = Popup,
                })
                Round(bar, 4)
                
                local fill = Create("Frame", {
                    Size = UDim2.new(val / 255, 0, 1, 0),
                    BackgroundColor3 = Config.Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = bar,
                })
                Round(fill, 4)
                
                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local v = math.floor(pos * 255 + 0.5)
                    Tween(fill, 0.05, {Size = UDim2.new(pos, 0, 1, 0)})
                    onChange(v)
                end
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end
            
            createRGBSlider("R", 8, r, function(v)
                r = v
                color = Color3.fromRGB(r, g, b)
                ColorBtn.BackgroundColor3 = color
                Library.Flags[text] = color
                if callback then pcall(callback, color) end
            end)
            createRGBSlider("G", 38, g, function(v)
                g = v
                color = Color3.fromRGB(r, g, b)
                ColorBtn.BackgroundColor3 = color
                Library.Flags[text] = color
                if callback then pcall(callback, color) end
            end)
            createRGBSlider("B", 68, b, function(v)
                b = v
                color = Color3.fromRGB(r, g, b)
                ColorBtn.BackgroundColor3 = color
                Library.Flags[text] = color
                if callback then pcall(callback, color) end
            end)
            
            ColorBtn.MouseButton1Click:Connect(function()
                popupOpen = not popupOpen
                Popup.Visible = popupOpen
            end)
            
            Library.Flags[text] = color
            
            return {
                Set = function(c)
                    color = c
                    r, g, b = c.R * 255, c.G * 255, c.B * 255
                    ColorBtn.BackgroundColor3 = c
                    Library.Flags[text] = c
                    if callback then pcall(callback, c) end
                end,
                Get = function() return color end,
            }
        end
        
        -- ═══ KEYBIND ═══
        function Tab:CreateKeybind(text, default, callback)
            local key = default or Enum.KeyCode.F
            local binding = false
            
            local KeyFrame = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 34),
                BackgroundColor3 = Config.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = TabContent,
            })
            Round(KeyFrame, 6)
            Stroke(KeyFrame, Config.Theme.Border, 1)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeyFrame,
            })
            
            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 22),
                Position = UDim2.new(1, -90, 0.5, -11),
                BackgroundColor3 = Config.Theme.Tertiary,
                BorderSizePixel = 0,
                Text = key.Name,
                TextColor3 = Config.Theme.Text,
                Font = Config.Font,
                TextSize = 12,
                Parent = KeyFrame,
            })
            Round(KeyBtn, 4)
            
            KeyBtn.MouseButton1Click:Connect(function()
                binding = true
                KeyBtn.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    KeyBtn.Text = key.Name
                    binding = false
                    Library.Flags[text] = key
                    if callback then pcall(callback, key) end
                elseif not binding and input.KeyCode == key and not gpe then
                    if callback then pcall(callback, key) end
                end
            end)
            
            Library.Flags[text] = key
            
            return {
                Set = function(k)
                    key = k
                    KeyBtn.Text = k.Name
                    Library.Flags[text] = k
                end,
                Get = function() return key end,
            }
        end
        
        -- ═══ LABEL ═══
        function Tab:CreateLabel(text)
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 24),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Config.Theme.SubText,
                Font = Config.Font,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent,
            })
            return {
                Set = function(v) Label.Text = v end,
            }
        end
        
        return Tab
    end
    
    function Window:SelectTab(name)
        local tab = Tabs[name]
        if tab then
            tab.Button.MouseButton1Click:Fire()
        end
    end
    
    function Window:SetTitle(newTitle)
        TopBar:FindFirstChildOfClass("TextLabel").Text = newTitle
    end
    
    return Window
end

return Library