--[[
    xEz UI Library v1.0.0
    Combined from:
      - Xenon Library (by dawid-scripts / WindUI-inspired)
      - MacLib (by Maclib)
    Unified by ZenLunarDev

    Usage:
        local UI = loadstring(game:HttpGet(".../xez-ui.lua"))()
        local Window = UI:Window({ Title = "My Hub", Subtitle = "v1.0" })
        local Tab = Window:TabGroup():Tab({ Name = "Main", Image = "rbxassetid://..." })
        local Section = Tab:Section({ Side = "Left" })
        Section:Button({ Name = "Click", Callback = function() print("hi") end })
]]

local xEzUI = {
    Options = {},
    Folder = "xEzUI",
    Version = "1.0.0",
    GetService = function(service)
        return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
    end
}

--// Services
local TweenService    = xEzUI.GetService("TweenService")
local RunService      = xEzUI.GetService("RunService")
local HttpService     = xEzUI.GetService("HttpService")
local ContentProvider = xEzUI.GetService("ContentProvider")
local UserInputService= xEzUI.GetService("UserInputService")
local Lighting        = xEzUI.GetService("Lighting")
local Players         = xEzUI.GetService("Players")

local isStudio    = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local windowState, acrylicBlur, hasGlobalSetting
local tabs, currentTabInstance, tabIndex = {}, nil, 0
local unloaded = false

--// Assets
local assets = {
    interFont        = "rbxassetid://12187365364",
    userInfoBlurred  = "rbxassetid://18824089198",
    toggleBackground = "rbxassetid://18772190202",
    togglerHead      = "rbxassetid://18772309008",
    buttonImage      = "rbxassetid://10709791437",
    searchIcon       = "rbxassetid://86737463322606",
    colorWheel       = "rbxassetid://2849458409",
    colorTarget      = "rbxassetid://73265255323268",
    grid             = "rbxassetid://121484455191370",
    globe            = "rbxassetid://108952102602834",
    transform        = "rbxassetid://90336395745819",
    dropdown         = "rbxassetid://18865373378",
    sliderbar        = "rbxassetid://18772615246",
    sliderhead       = "rbxassetid://18772834246",
}

--// Helpers
local function GetGui()
    local newGui = Instance.new("ScreenGui")
    newGui.ScreenInsets   = Enum.ScreenInsets.None
    newGui.ResetOnSpawn   = false
    newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    newGui.DisplayOrder   = 2147483647

    local parent = RunService:IsStudio()
        and LocalPlayer:FindFirstChild("PlayerGui")
        or (gethui and gethui())
        or (cloneref and cloneref(xEzUI.GetService("CoreGui")) or xEzUI.GetService("CoreGui"))

    newGui.Parent = parent
    return newGui
end

local function Tween(instance, tweeninfo, propertytable)
    return TweenService:Create(instance, tweeninfo, propertytable)
end

--==========================================================================
-- WINDOW
--==========================================================================
function xEzUI:Window(Settings)
    local WindowFunctions = { Settings = Settings }

    acrylicBlur = Settings.AcrylicBlur ~= nil and Settings.AcrylicBlur or true

    local macLib = GetGui()

    --// Notifications container
    local notifications = Instance.new("Frame")
    notifications.Name                   = "Notifications"
    notifications.BackgroundTransparency = 1
    notifications.BorderSizePixel        = 0
    notifications.Size                   = UDim2.fromScale(1, 1)
    notifications.Parent                 = macLib
    notifications.ZIndex                 = 2

    local nUIList = Instance.new("UIListLayout")
    nUIList.Padding             = UDim.new(0, 10)
    nUIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    nUIList.SortOrder           = Enum.SortOrder.LayoutOrder
    nUIList.VerticalAlignment   = Enum.VerticalAlignment.Bottom
    nUIList.Parent              = notifications

    local nUIPad = Instance.new("UIPadding")
    nUIPad.PaddingBottom = UDim.new(0, 10)
    nUIPad.PaddingLeft   = UDim.new(0, 10)
    nUIPad.PaddingRight  = UDim.new(0, 10)
    nUIPad.PaddingTop    = UDim.new(0, 10)
    nUIPad.Parent        = notifications

    --// Base window
    local base = Instance.new("Frame")
    base.Name                   = "Base"
    base.AnchorPoint            = Vector2.new(0.5, 0.5)
    base.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
    base.BackgroundTransparency = acrylicBlur and 0.05 or 0
    base.BorderSizePixel        = 0
    base.Position               = UDim2.fromScale(0.5, 0.5)
    base.Size                   = Settings.Size or UDim2.fromOffset(868, 650)

    local baseUIScale = Instance.new("UIScale")
    baseUIScale.Parent = base

    local baseUICorner = Instance.new("UICorner")
    baseUICorner.CornerRadius = UDim.new(0, 10)
    baseUICorner.Parent = base

    local baseUIStroke = Instance.new("UIStroke")
    baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    baseUIStroke.Color           = Color3.fromRGB(255, 255, 255)
    baseUIStroke.Transparency    = 0.9
    baseUIStroke.Parent          = base

    --// Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name                   = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel        = 0
    sidebar.Size                   = UDim2.fromScale(0.325, 1)
    sidebar.Parent                 = base

    local divider = Instance.new("Frame")
    divider.Name                   = "Divider"
    divider.AnchorPoint            = Vector2.new(1, 0)
    divider.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.9
    divider.BorderSizePixel        = 0
    divider.Position               = UDim2.fromScale(1, 0)
    divider.Size                   = UDim2.new(0, 1, 1, 0)
    divider.Parent                 = sidebar

    local dividerInteract = Instance.new("TextButton")
    dividerInteract.Name                   = "DividerInteract"
    dividerInteract.AnchorPoint            = Vector2.new(0.5, 0)
    dividerInteract.BackgroundTransparency = 1
    dividerInteract.Text                   = ""
    dividerInteract.Position               = UDim2.fromScale(0.5, 0)
    dividerInteract.Size                   = UDim2.new(1, 6, 1, 0)
    dividerInteract.Parent                 = divider

    --// Window controls
    local windowControls = Instance.new("Frame")
    windowControls.Name                   = "WindowControls"
    windowControls.BackgroundTransparency = 1
    windowControls.BorderSizePixel        = 0
    windowControls.Size                   = UDim2.new(1, 0, 0, 31)

    local controls = Instance.new("Frame")
    controls.Name                   = "Controls"
    controls.BackgroundTransparency = 1
    controls.BorderSizePixel        = 0
    controls.Size                   = UDim2.fromScale(1, 1)

    local controlsList = Instance.new("UIListLayout")
    controlsList.Padding            = UDim.new(0, 5)
    controlsList.FillDirection      = Enum.FillDirection.Horizontal
    controlsList.SortOrder          = Enum.SortOrder.LayoutOrder
    controlsList.VerticalAlignment  = Enum.VerticalAlignment.Center
    controlsList.Parent             = controls

    local controlsPad = Instance.new("UIPadding")
    controlsPad.PaddingLeft = UDim.new(0, 11)
    controlsPad.Parent      = controls

    local windowControlSettings = {
        sizes            = { enabled = UDim2.fromOffset(8, 8), disabled = UDim2.fromOffset(7, 7) },
        transparencies   = { enabled = 0, disabled = 1 },
        strokeTransparency = 0.9,
    }

    local stroke = Instance.new("UIStroke")
    stroke.Name              = "BaseUIStroke"
    stroke.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    stroke.Color             = Color3.fromRGB(255, 255, 255)
    stroke.Transparency      = windowControlSettings.strokeTransparency

    local exit = Instance.new("TextButton")
    exit.Name              = "Exit"
    exit.Text              = ""
    exit.AutoButtonColor   = false
    exit.BackgroundColor3  = Color3.fromRGB(250, 93, 86)
    exit.BorderSizePixel   = 0

    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(1, 0)
    exitCorner.Parent = exit

    exit.Parent = controls

    local minimize = Instance.new("TextButton")
    minimize.Name             = "Minimize"
    minimize.Text             = ""
    minimize.AutoButtonColor  = false
    minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
    minimize.BorderSizePixel  = 0
    minimize.LayoutOrder      = 1

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minimize

    minimize.Parent = controls

    local maximize = Instance.new("TextButton")
    maximize.Name             = "Maximize"
    maximize.Text             = ""
    maximize.AutoButtonColor  = false
    maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
    maximize.BorderSizePixel  = 0
    maximize.LayoutOrder      = 1

    local maxCorner = Instance.new("UICorner")
    maxCorner.CornerRadius = UDim.new(1, 0)
    maxCorner.Parent = maximize

    maximize.Parent = controls

    local function applyState(button, enabled)
        local size         = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
        local transparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled

        button.Size                  = size
        button.BackgroundTransparency= transparency
        button.Active                = enabled
        button.Interactable          = enabled

        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Transparency = transparency
            end
        end
        if not enabled then
            stroke:Clone().Parent = button
        end
    end

    applyState(maximize, false)

    for _, button in pairs({ exit, minimize }) do
        local buttonName = button.Name
        local isEnabled = true
        if Settings.DisabledWindowControls and table.find(Settings.DisabledWindowControls, buttonName) then
            isEnabled = false
        end
        applyState(button, isEnabled)
    end

    controls.Parent = windowControls

    local divider1 = Instance.new("Frame")
    divider1.Name                   = "Divider"
    divider1.AnchorPoint            = Vector2.new(0, 1)
    divider1.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    divider1.BackgroundTransparency = 0.9
    divider1.BorderSizePixel        = 0
    divider1.Position               = UDim2.fromScale(0, 1)
    divider1.Size                   = UDim2.new(1, 0, 0, 1)
    divider1.Parent                 = windowControls

    windowControls.Parent = sidebar

    --// Information (Title / Subtitle)
    local information = Instance.new("Frame")
    information.Name                   = "Information"
    information.BackgroundTransparency = 1
    information.BorderSizePixel        = 0
    information.Position               = UDim2.fromOffset(0, 31)
    information.Size                   = UDim2.new(1, 0, 0, 60)

    local divider2 = Instance.new("Frame")
    divider2.Name                   = "Divider"
    divider2.AnchorPoint            = Vector2.new(0, 1)
    divider2.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    divider2.BackgroundTransparency = 0.9
    divider2.BorderSizePixel        = 0
    divider2.Position               = UDim2.fromScale(0, 1)
    divider2.Size                   = UDim2.new(1, 0, 0, 1)
    divider2.Parent                 = information

    local informationHolder = Instance.new("Frame")
    informationHolder.Name                   = "InformationHolder"
    informationHolder.BackgroundTransparency = 1
    informationHolder.BorderSizePixel        = 0
    informationHolder.Size                   = UDim2.fromScale(1, 1)

    local infoHolderPad = Instance.new("UIPadding")
    infoHolderPad.PaddingBottom = UDim.new(0, 10)
    infoHolderPad.PaddingLeft   = UDim.new(0, 23)
    infoHolderPad.PaddingRight  = UDim.new(0, 22)
    infoHolderPad.PaddingTop    = UDim.new(0, 10)
    infoHolderPad.Parent        = informationHolder

    local globalSettingsButton = Instance.new("ImageButton")
    globalSettingsButton.Name                   = "GlobalSettingsButton"
    globalSettingsButton.Image                  = assets.globe
    globalSettingsButton.ImageTransparency      = 0.5
    globalSettingsButton.AnchorPoint            = Vector2.new(1, 0.5)
    globalSettingsButton.BackgroundTransparency = 1
    globalSettingsButton.BorderSizePixel        = 0
    globalSettingsButton.Position               = UDim2.fromScale(1, 0.5)
    globalSettingsButton.Size                   = UDim2.fromOffset(16, 16)
    globalSettingsButton.Parent                 = informationHolder

    globalSettingsButton.MouseEnter:Connect(function()
        Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.3 }):Play()
    end)
    globalSettingsButton.MouseLeave:Connect(function()
        Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.5 }):Play()
    end)

    local titleFrame = Instance.new("Frame")
    titleFrame.Name                   = "TitleFrame"
    titleFrame.BackgroundTransparency = 1
    titleFrame.BorderSizePixel        = 0
    titleFrame.Size                   = UDim2.fromScale(1, 1)

    local title = Instance.new("TextLabel")
    title.Name                   = "Title"
    title.FontFace               = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    title.Text                   = Settings.Title
    title.TextColor3             = Color3.fromRGB(255, 255, 255)
    title.RichText               = true
    title.TextSize               = 18
    title.TextTransparency       = 0.1
    title.TextTruncate           = Enum.TextTruncate.SplitWord
    title.TextXAlignment         = Enum.TextXAlignment.Left
    title.TextYAlignment         = Enum.TextYAlignment.Top
    title.AutomaticSize          = Enum.AutomaticSize.Y
    title.BackgroundTransparency = 1
    title.BorderSizePixel        = 0
    title.Size                   = UDim2.new(1, -20, 0, 0)
    title.Parent                 = titleFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Name                   = "Subtitle"
    subtitle.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    subtitle.RichText               = true
    subtitle.Text                   = Settings.Subtitle
    subtitle.TextColor3             = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize               = 12
    subtitle.TextTransparency       = 0.7
    subtitle.TextTruncate           = Enum.TextTruncate.SplitWord
    subtitle.TextXAlignment         = Enum.TextXAlignment.Left
    subtitle.TextYAlignment         = Enum.TextYAlignment.Top
    subtitle.AutomaticSize          = Enum.AutomaticSize.Y
    subtitle.BackgroundTransparency = 1
    subtitle.BorderSizePixel        = 0
    subtitle.LayoutOrder            = 1
    subtitle.Size                   = UDim2.new(1, -20, 0, 0)
    subtitle.Parent                 = titleFrame

    local titleFrameList = Instance.new("UIListLayout")
    titleFrameList.Padding           = UDim.new(0, 3)
    titleFrameList.SortOrder         = Enum.SortOrder.LayoutOrder
    titleFrameList.VerticalAlignment = Enum.VerticalAlignment.Center
    titleFrameList.Parent            = titleFrame

    titleFrame.Parent = informationHolder

    informationHolder.Parent = information
    information.Parent       = sidebar

    --// Sidebar group
    local sidebarGroup = Instance.new("Frame")
    sidebarGroup.Name                   = "SidebarGroup"
    sidebarGroup.BackgroundTransparency = 1
    sidebarGroup.BorderSizePixel        = 0
    sidebarGroup.Position               = UDim2.fromOffset(0, 91)
    sidebarGroup.Size                   = UDim2.new(1, 0, 1, -91)

    local userInfo = Instance.new("Frame")
    userInfo.Name                   = "UserInfo"
    userInfo.AnchorPoint            = Vector2.new(0, 1)
    userInfo.BackgroundTransparency = 1
    userInfo.BorderSizePixel        = 0
    userInfo.Position               = UDim2.fromScale(0, 1)
    userInfo.Size                   = UDim2.new(1, 0, 0, 107)

    local informationGroup = Instance.new("Frame")
    informationGroup.Name                   = "InformationGroup"
    informationGroup.BackgroundTransparency = 1
    informationGroup.BorderSizePixel        = 0
    informationGroup.Size                   = UDim2.fromScale(1, 1)

    local infoGroupPad = Instance.new("UIPadding")
    infoGroupPad.PaddingBottom = UDim.new(0, 17)
    infoGroupPad.PaddingLeft   = UDim.new(0, 25)
    infoGroupPad.Parent        = informationGroup

    local infoGroupList = Instance.new("UIListLayout")
    infoGroupList.FillDirection     = Enum.FillDirection.Horizontal
    infoGroupList.SortOrder         = Enum.SortOrder.LayoutOrder
    infoGroupList.VerticalAlignment = Enum.VerticalAlignment.Center
    infoGroupList.Parent            = informationGroup

    local userId       = LocalPlayer.UserId
    local thumbType    = Enum.ThumbnailType.AvatarBust
    local thumbSize    = Enum.ThumbnailSize.Size48x48
    local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local headshot = Instance.new("ImageLabel")
    headshot.Name                   = "Headshot"
    headshot.BackgroundTransparency = 1
    headshot.BorderSizePixel        = 0
    headshot.Size                   = UDim2.fromOffset(32, 32)
    headshot.Image                  = (isReady and headshotImage) or "rbxassetid://0"

    local headshotCorner = Instance.new("UICorner")
    headshotCorner.CornerRadius = UDim.new(1, 0)
    headshotCorner.Parent = headshot

    local headshotStroke = Instance.new("UIStroke")
    headshotStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    headshotStroke.Color           = Color3.fromRGB(255, 255, 255)
    headshotStroke.Transparency    = 0.9
    headshotStroke.Parent          = headshot

    headshot.Parent = informationGroup

    local userAndDisplayFrame = Instance.new("Frame")
    userAndDisplayFrame.Name                   = "UserAndDisplayFrame"
    userAndDisplayFrame.BackgroundTransparency = 1
    userAndDisplayFrame.BorderSizePixel        = 0
    userAndDisplayFrame.LayoutOrder            = 1
    userAndDisplayFrame.Size                   = UDim2.new(1, -42, 0, 32)

    local displayName = Instance.new("TextLabel")
    displayName.Name                   = "DisplayName"
    displayName.FontFace               = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    displayName.Text                   = LocalPlayer.DisplayName
    displayName.TextColor3             = Color3.fromRGB(255, 255, 255)
    displayName.TextSize               = 13
    displayName.TextTransparency       = 0.1
    displayName.TextTruncate           = Enum.TextTruncate.SplitWord
    displayName.TextXAlignment         = Enum.TextXAlignment.Left
    displayName.AutomaticSize          = Enum.AutomaticSize.XY
    displayName.BackgroundTransparency = 1
    displayName.BorderSizePixel        = 0
    displayName.Parent                 = userAndDisplayFrame
    displayName.Size                   = UDim2.fromScale(1, 0)

    local udList = Instance.new("UIListLayout")
    udList.Padding     = UDim.new(0, 1)
    udList.SortOrder   = Enum.SortOrder.LayoutOrder
    udList.Parent      = userAndDisplayFrame

    local username = Instance.new("TextLabel")
    username.Name                   = "Username"
    username.FontFace               = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    username.Text                   = "@" .. LocalPlayer.Name
    username.TextColor3             = Color3.fromRGB(255, 255, 255)
    username.TextSize               = 12
    username.TextTransparency       = 0.7
    username.TextTruncate           = Enum.TextTruncate.SplitWord
    username.TextXAlignment         = Enum.TextXAlignment.Left
    username.AutomaticSize          = Enum.AutomaticSize.XY
    username.BackgroundTransparency = 1
    username.BorderSizePixel        = 0
    username.LayoutOrder            = 1
    username.Parent                 = userAndDisplayFrame
    username.Size                   = UDim2.fromScale(1, 0)

    userAndDisplayFrame.Parent = informationGroup
    informationGroup.Parent    = userInfo

    local userInfoPad = Instance.new("UIPadding")
    userInfoPad.PaddingLeft  = UDim.new(0, 10)
    userInfoPad.PaddingRight = UDim.new(0, 10)
    userInfoPad.Parent       = userInfo

    userInfo.Parent = sidebarGroup

    local sidebarGroupPad = Instance.new("UIPadding")
    sidebarGroupPad.PaddingLeft = UDim.new(0, 10)
    sidebarGroupPad.PaddingRight= UDim.new(0, 10)
    sidebarGroupPad.PaddingTop  = UDim.new(0, 31)
    sidebarGroupPad.Parent      = sidebarGroup

    --// Tab switchers
    local tabSwitchers = Instance.new("Frame")
    tabSwitchers.Name                   = "TabSwitchers"
    tabSwitchers.BackgroundTransparency = 1
    tabSwitchers.BorderSizePixel        = 0
    tabSwitchers.Size                   = UDim2.new(1, 0, 1, -107)

    local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
    tabSwitchersScrollingFrame.Name                     = "TabSwitchersScrollingFrame"
    tabSwitchersScrollingFrame.AutomaticCanvasSize       = Enum.AutomaticSize.Y
    tabSwitchersScrollingFrame.BottomImage               = ""
    tabSwitchersScrollingFrame.CanvasSize                = UDim2.new()
    tabSwitchersScrollingFrame.ScrollBarImageTransparency= 0.8
    tabSwitchersScrollingFrame.ScrollBarThickness        = 1
    tabSwitchersScrollingFrame.TopImage                  = ""
    tabSwitchersScrollingFrame.BackgroundTransparency    = 1
    tabSwitchersScrollingFrame.BorderSizePixel           = 0
    tabSwitchersScrollingFrame.Size                      = UDim2.fromScale(1, 1)

    local tabList = Instance.new("UIListLayout")
    tabList.Padding     = UDim.new(0, 17)
    tabList.SortOrder   = Enum.SortOrder.LayoutOrder
    tabList.Parent      = tabSwitchersScrollingFrame

    local tabSwitchersPad = Instance.new("UIPadding")
    tabSwitchersPad.PaddingTop = UDim.new(0, 2)
    tabSwitchersPad.Parent     = tabSwitchersScrollingFrame

    tabSwitchersScrollingFrame.Parent = tabSwitchers
    tabSwitchers.Parent               = sidebarGroup
    sidebarGroup.Parent               = sidebar
    sidebar.Parent                    = base

    --// Content
    local content = Instance.new("Frame")
    content.Name                   = "Content"
    content.AnchorPoint            = Vector2.new(1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel        = 0
    content.Position               = UDim2.fromScale(1, 0)
    content.Size                   = UDim2.new(0, (base.AbsoluteSize.X - sidebar.AbsoluteSize.X), 1, 0)

    --// Divider resizing
    local resizingContent = false
    local defaultSidebarWidth = sidebar.AbsoluteSize.X
    local initialMouseX, initialSidebarWidth
    local snapRange = 20
    local minSidebarWidth = 107
    local maxSidebarWidth = base.AbsoluteSize.X - minSidebarWidth

    local TweenSettings = {
        DefaultTransparency = 0.9,
        HoverTransparency   = 0.85,
        EasingStyle         = Enum.EasingStyle.Sine
    }

    local function ChangeState(State)
        Tween(divider, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
            BackgroundTransparency = State == "Idle" and TweenSettings.DefaultTransparency or TweenSettings.HoverTransparency
        }):Play()
    end

    dividerInteract.MouseEnter:Connect(function() ChangeState("Hover") end)
    dividerInteract.MouseLeave:Connect(function() ChangeState("Idle") end)

    dividerInteract.MouseButton1Down:Connect(function()
        resizingContent     = true
        initialMouseX       = UserInputService:GetMouseLocation().X
        initialSidebarWidth = sidebar.AbsoluteSize.X
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizingContent = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
            local deltaX = UserInputService:GetMouseLocation().X - initialMouseX
            local newSidebarWidth = initialSidebarWidth + deltaX

            if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then
                newSidebarWidth = defaultSidebarWidth
            else
                newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, maxSidebarWidth)
            end

            sidebar.Size = UDim2.new(0, newSidebarWidth, 1, 0)
            content.Size = UDim2.new(0, base.AbsoluteSize.X - newSidebarWidth, 1, 0)
        end
    end)

    --// Topbar
    local topbar = Instance.new("Frame")
    topbar.Name                   = "Topbar"
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel        = 0
    topbar.Size                   = UDim2.new(1, 0, 0, 63)

    local divider4 = Instance.new("Frame")
    divider4.Name                   = "Divider"
    divider4.AnchorPoint            = Vector2.new(0, 1)
    divider4.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    divider4.BackgroundTransparency = 0.9
    divider4.BorderSizePixel        = 0
    divider4.Position               = UDim2.fromScale(0, 1)
    divider4.Size                   = UDim2.new(1, 0, 0, 1)
    divider4.Parent                 = topbar

    local elements = Instance.new("Frame")
    elements.Name                   = "Elements"
    elements.BackgroundTransparency = 1
    elements.BorderSizePixel        = 0
    elements.Size                   = UDim2.fromScale(1, 1)

    local elementsPad = Instance.new("UIPadding")
    elementsPad.PaddingLeft  = UDim.new(0, 20)
    elementsPad.PaddingRight = UDim.new(0, 20)
    elementsPad.Parent       = elements

    local moveIcon = Instance.new("ImageButton")
    moveIcon.Name                   = "MoveIcon"
    moveIcon.Image                  = assets.transform
    moveIcon.ImageTransparency      = 0.7
    moveIcon.AnchorPoint            = Vector2.new(1, 0.5)
    moveIcon.BackgroundTransparency = 1
    moveIcon.BorderSizePixel        = 0
    moveIcon.Position               = UDim2.fromScale(1, 0.5)
    moveIcon.Size                   = UDim2.fromOffset(15, 15)
    moveIcon.Parent                 = elements
    moveIcon.Visible                = not Settings.DragStyle or Settings.DragStyle == 1

    local interact = Instance.new("TextButton")
    interact.Name                   = "Interact"
    interact.Text                   = ""
    interact.AnchorPoint            = Vector2.new(0.5, 0.5)
    interact.BackgroundTransparency = 1
    interact.BorderSizePixel        = 0
    interact.Position               = UDim2.fromScale(0.5, 0.5)
    interact.Size                   = UDim2.fromOffset(40, 40)
    interact.Parent                 = moveIcon

    interact.MouseEnter:Connect(function()
        Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.4 }):Play()
    end)
    interact.MouseLeave:Connect(function()
        Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.7 }):Play()
    end)

    --// Dragging
    local dragging_ = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging_ = true
            dragStart = input.Position
            startPos  = base.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging_ = false
                end
            end)
        end
    end

    local function onDragUpdate(input)
        if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end

    if not Settings.DragStyle or Settings.DragStyle == 1 then
        interact.InputBegan:Connect(onDragStart)
        interact.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging_ then update(input) end
        end)
        interact.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_ = false
            end
        end)
    elseif Settings.DragStyle == 2 then
        base.InputBegan:Connect(onDragStart)
        base.InputChanged:Connect(onDragUpdate)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging_ then update(input) end
        end)
        base.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_ = false
            end
        end)
    end

    local currentTab = Instance.new("TextLabel")
    currentTab.Name                   = "CurrentTab"
    currentTab.FontFace               = Font.new(assets.interFont)
    currentTab.RichText               = true
    currentTab.Text                   = ""
    currentTab.TextColor3             = Color3.fromRGB(255, 255, 255)
    currentTab.TextSize               = 15
    currentTab.TextTransparency       = 0.5
    currentTab.TextTruncate           = Enum.TextTruncate.SplitWord
    currentTab.TextXAlignment         = Enum.TextXAlignment.Left
    currentTab.AnchorPoint            = Vector2.new(0, 0.5)
    currentTab.AutomaticSize          = Enum.AutomaticSize.Y
    currentTab.BackgroundTransparency = 1
    currentTab.BorderSizePixel        = 0
    currentTab.Position               = UDim2.fromScale(0, 0.5)
    currentTab.Size                   = UDim2.fromScale(0.9, 0)
    currentTab.Parent                 = elements

    elements.Parent = topbar
    topbar.Parent   = content
    content.Parent  = base

    --// Global settings panel
    local globalSettings = Instance.new("Frame")
    globalSettings.Name              = "GlobalSettings"
    globalSettings.AutomaticSize     = Enum.AutomaticSize.XY
    globalSettings.BackgroundColor3  = Color3.fromRGB(15, 15, 15)
    globalSettings.BorderSizePixel   = 0
    globalSettings.Position          = UDim2.fromScale(0.298, 0.104)

    local globalSettingsUIStroke = Instance.new("UIStroke")
    globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    globalSettingsUIStroke.Color           = Color3.fromRGB(255, 255, 255)
    globalSettingsUIStroke.Transparency    = 0.9
    globalSettingsUIStroke.Parent          = globalSettings

    local globalSettingsUICorner = Instance.new("UICorner")
    globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
    globalSettingsUICorner.Parent       = globalSettings

    local globalSettingsUIPadding = Instance.new("UIPadding")
    globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
    globalSettingsUIPadding.PaddingTop    = UDim.new(0, 10)
    globalSettingsUIPadding.Parent        = globalSettings

    local globalSettingsUIListLayout = Instance.new("UIListLayout")
    globalSettingsUIListLayout.Padding   = UDim.new(0, 5)
    globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    globalSettingsUIListLayout.Parent    = globalSettings

    local globalSettingsUIScale = Instance.new("UIScale")
    globalSettingsUIScale.Scale  = 1e-07
    globalSettingsUIScale.Parent = globalSettings

    globalSettings.Parent = base
    base.Parent           = macLib

    --// Acrylic blur (simplified - uses DepthOfField)
    local acrylicBlurParts = {}
    local DepthOfField = Instance.new("DepthOfFieldEffect")
    DepthOfField.FarIntensity   = 0
    DepthOfField.FocusDistance  = 51.6
    DepthOfField.InFocusRadius  = 50
    DepthOfField.NearIntensity  = 1
    DepthOfField.Name           = HttpService:GenerateGUID(true)
    DepthOfField:AddTag(".")
    DepthOfField.Parent         = Lighting

    local blurFrame = Instance.new("Frame")
    blurFrame.Name                   = HttpService:GenerateGUID(true)
    blurFrame.Size                   = UDim2.new(0.97, 0, 0.97, 0)
    blurFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    blurFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    blurFrame.BackgroundTransparency = 1
    blurFrame.Parent                 = base

    --// Window API
    function WindowFunctions:UpdateTitle(NewTitle)
        title.Text = NewTitle
    end

    function WindowFunctions:UpdateSubtitle(NewSubtitle)
        subtitle.Text = NewSubtitle
    end

    --// Toggle global settings
    local hovering
    local toggled = globalSettingsUIScale.Scale == 1
    local function toggle()
        if not toggled then
            local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 1 })
            intween:Play(); intween.Completed:Wait()
            toggled = true
        else
            local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 0 })
            outtween:Play(); outtween.Completed:Wait()
            toggled = false
        end
    end

    globalSettingsButton.MouseButton1Click:Connect(function()
        if not hasGlobalSetting then return end
        toggle()
    end)

    globalSettings.MouseEnter:Connect(function() hovering = true end)
    globalSettings.MouseLeave:Connect(function() hovering = false end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and toggled and not hovering then
            toggle()
        end
    end)

    --// GlobalSetting API
    function WindowFunctions:GlobalSetting(Settings)
        hasGlobalSetting = true
        local GlobalSettingFunctions = {}

        local globalSetting = Instance.new("TextButton")
        globalSetting.Name                   = "GlobalSetting"
        globalSetting.Text                   = ""
        globalSetting.BackgroundTransparency = 1
        globalSetting.BorderSizePixel        = 0
        globalSetting.Size                   = UDim2.fromOffset(200, 30)

        local globalSettingUIPadding = Instance.new("UIPadding")
        globalSettingUIPadding.PaddingLeft = UDim.new(0, 15)
        globalSettingUIPadding.Parent      = globalSetting

        local settingName = Instance.new("TextLabel")
        settingName.Name                   = "SettingName"
        settingName.FontFace               = Font.new(assets.interFont)
        settingName.Text                   = Settings.Name
        settingName.RichText               = true
        settingName.TextColor3             = Color3.fromRGB(255, 255, 255)
        settingName.TextSize               = 13
        settingName.TextTransparency       = 0.5
        settingName.TextTruncate           = Enum.TextTruncate.SplitWord
        settingName.TextXAlignment         = Enum.TextXAlignment.Left
        settingName.AnchorPoint            = Vector2.new(0, 0.5)
        settingName.AutomaticSize          = Enum.AutomaticSize.Y
        settingName.BackgroundTransparency = 1
        settingName.BorderSizePixel        = 0
        settingName.Position               = UDim2.fromScale(0, 0.5)
        settingName.Size                   = UDim2.new(1, -40, 0, 0)
        settingName.Parent                 = globalSetting

        local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
        globalSettingToggleUIListLayout.Padding           = UDim.new(0, 10)
        globalSettingToggleUIListLayout.FillDirection     = Enum.FillDirection.Horizontal
        globalSettingToggleUIListLayout.SortOrder         = Enum.SortOrder.LayoutOrder
        globalSettingToggleUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        globalSettingToggleUIListLayout.Parent            = globalSetting

        local checkmark = Instance.new("TextLabel")
        checkmark.Name                   = "Checkmark"
        checkmark.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        checkmark.Text                   = "✓"
        checkmark.TextColor3             = Color3.fromRGB(255, 255, 255)
        checkmark.TextSize               = 13
        checkmark.TextTransparency       = 1
        checkmark.AnchorPoint            = Vector2.new(0, 0.5)
        checkmark.AutomaticSize          = Enum.AutomaticSize.Y
        checkmark.BackgroundTransparency = 1
        checkmark.BorderSizePixel        = 0
        checkmark.LayoutOrder            = -1
        checkmark.Position               = UDim2.fromScale(0, 0.5)
        checkmark.Size                   = UDim2.fromOffset(-10, 0)
        checkmark.Parent                 = globalSetting

        globalSetting.Parent = globalSettings

        local tweens = {
            checkIn  = Tween(checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(checkmark.Size.X.Scale, 12, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset) }),
            checkOut = Tween(checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(checkmark.Size.X.Scale, -globalSettingToggleUIListLayout.Padding.Offset, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset) }),
            nameIn   = Tween(settingName, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { TextTransparency = 0.2 }),
            nameOut  = Tween(settingName, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { TextTransparency = 0.5 }),
        }

        local function Toggle(State)
            if not State then
                tweens.checkOut:Play()
                tweens.nameOut:Play()
                checkmark.TextTransparency = 1
            else
                tweens.checkIn:Play()
                tweens.nameIn:Play()
                checkmark.TextTransparency = 0
            end
        end

        local toggled = Settings.Default
        Toggle(toggled)

        globalSetting.MouseButton1Click:Connect(function()
            toggled = not toggled
            Toggle(toggled)
            task.spawn(function()
                if Settings.Callback then
                    Settings.Callback(toggled)
                end
            end)
        end)

        function GlobalSettingFunctions:UpdateName(NewName)
            settingName.Text = NewName
        end
        function GlobalSettingFunctions:UpdateState(NewState)
            Toggle(NewState)
            toggled = NewState
        end

        return GlobalSettingFunctions
    end

    --// TabGroup API
    function WindowFunctions:TabGroup()
        local SectionFunctions = {}

        local tabGroup = Instance.new("Frame")
        tabGroup.Name                   = "Section"
        tabGroup.AutomaticSize          = Enum.AutomaticSize.Y
        tabGroup.BackgroundTransparency = 1
        tabGroup.BorderSizePixel        = 0
        tabGroup.Size                   = UDim2.fromScale(1, 0)

        local divider3 = Instance.new("Frame")
        divider3.Name                   = "Divider"
        divider3.AnchorPoint            = Vector2.new(0.5, 1)
        divider3.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        divider3.BackgroundTransparency = 0.9
        divider3.BorderSizePixel        = 0
        divider3.Position               = UDim2.fromScale(0.5, 1)
        divider3.Size                   = UDim2.new(1, -21, 0, 1)
        divider3.Parent                 = tabGroup

        local sectionTabSwitchers = Instance.new("Frame")
        sectionTabSwitchers.Name                   = "SectionTabSwitchers"
        sectionTabSwitchers.BackgroundTransparency = 1
        sectionTabSwitchers.BorderSizePixel        = 0
        sectionTabSwitchers.Size                   = UDim2.fromScale(1, 1)

        local sectionTabSwitchersList = Instance.new("UIListLayout")
        sectionTabSwitchersList.Padding           = UDim.new(0, 15)
        sectionTabSwitchersList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sectionTabSwitchersList.SortOrder         = Enum.SortOrder.LayoutOrder
        sectionTabSwitchersList.Parent            = sectionTabSwitchers

        local sectionTabSwitchersPad = Instance.new("UIPadding")
        sectionTabSwitchersPad.PaddingBottom = UDim.new(0, 15)
        sectionTabSwitchersPad.Parent        = sectionTabSwitchers

        sectionTabSwitchers.Parent = tabGroup
        tabGroup.Parent            = tabSwitchersScrollingFrame

        function SectionFunctions:Tab(Settings)
            local TabFunctions = { Settings = Settings }

            local tabSwitcher = Instance.new("TextButton")
            tabSwitcher.Name                   = "TabSwitcher"
            tabSwitcher.Text                   = ""
            tabSwitcher.AutoButtonColor        = false
            tabSwitcher.AnchorPoint            = Vector2.new(0.5, 0)
            tabSwitcher.BackgroundTransparency = 1
            tabSwitcher.BorderSizePixel        = 0
            tabSwitcher.Position               = UDim2.fromScale(0.5, 0)
            tabSwitcher.Size                   = UDim2.new(1, -21, 0, 40)

            tabIndex += 1
            tabSwitcher.LayoutOrder = tabIndex

            local tabSwitcherUICorner = Instance.new("UICorner")
            tabSwitcherUICorner.Parent = tabSwitcher

            local tabSwitcherUIStroke = Instance.new("UIStroke")
            tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            tabSwitcherUIStroke.Color           = Color3.fromRGB(255, 255, 255)
            tabSwitcherUIStroke.Transparency    = 1
            tabSwitcherUIStroke.Parent          = tabSwitcher

            local tabSwitcherUIListLayout = Instance.new("UIListLayout")
            tabSwitcherUIListLayout.Padding           = UDim.new(0, 9)
            tabSwitcherUIListLayout.FillDirection     = Enum.FillDirection.Horizontal
            tabSwitcherUIListLayout.SortOrder         = Enum.SortOrder.LayoutOrder
            tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            tabSwitcherUIListLayout.Parent            = tabSwitcher

            local tabImage
            if Settings.Image then
                tabImage = Instance.new("ImageLabel")
                tabImage.Name                   = "TabImage"
                tabImage.Image                  = Settings.Image
                tabImage.ImageTransparency      = 0.5
                tabImage.BackgroundTransparency = 1
                tabImage.BorderSizePixel        = 0
                tabImage.Size                   = UDim2.fromOffset(18, 18)
                tabImage.Parent                 = tabSwitcher
            end

            local tabSwitcherName = Instance.new("TextLabel")
            tabSwitcherName.Name                   = "TabSwitcherName"
            tabSwitcherName.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            tabSwitcherName.Text                   = Settings.Name
            tabSwitcherName.RichText               = true
            tabSwitcherName.TextColor3             = Color3.fromRGB(255, 255, 255)
            tabSwitcherName.TextSize               = 16
            tabSwitcherName.TextTransparency       = 0.5
            tabSwitcherName.TextTruncate           = Enum.TextTruncate.SplitWord
            tabSwitcherName.TextXAlignment         = Enum.TextXAlignment.Left
            tabSwitcherName.AutomaticSize          = Enum.AutomaticSize.Y
            tabSwitcherName.BackgroundTransparency = 1
            tabSwitcherName.BorderSizePixel        = 0
            tabSwitcherName.Size                   = UDim2.fromScale(1, 0)
            tabSwitcherName.Parent                 = tabSwitcher
            tabSwitcherName.LayoutOrder            = 1

            local tabSwitcherUIPadding = Instance.new("UIPadding")
            tabSwitcherUIPadding.PaddingLeft  = UDim.new(0, 24)
            tabSwitcherUIPadding.PaddingRight = UDim.new(0, 35)
            tabSwitcherUIPadding.PaddingTop   = UDim.new(0, 1)
            tabSwitcherUIPadding.Parent       = tabSwitcher

            tabSwitcher.Parent = sectionTabSwitchers

            local elements1 = Instance.new("Frame")
            elements1.Name                   = "Elements"
            elements1.BackgroundTransparency = 1
            elements1.BorderSizePixel        = 0
            elements1.Position               = UDim2.fromOffset(0, 63)
            elements1.Size                   = UDim2.new(1, 0, 1, -63)
            elements1.ClipsDescendants       = true

            local elementsUIPadding = Instance.new("UIPadding")
            elementsUIPadding.PaddingRight  = UDim.new(0, 5)
            elementsUIPadding.PaddingTop    = UDim.new(0, 10)
            elementsUIPadding.PaddingBottom = UDim.new(0, 10)
            elementsUIPadding.Parent        = elements1

            local elementsScrolling = Instance.new("ScrollingFrame")
            elementsScrolling.Name                     = "ElementsScrolling"
            elementsScrolling.AutomaticCanvasSize       = Enum.AutomaticSize.Y
            elementsScrolling.BottomImage               = ""
            elementsScrolling.CanvasSize                = UDim2.new()
            elementsScrolling.ScrollBarImageTransparency= 0.5
            elementsScrolling.ScrollBarThickness        = 1
            elementsScrolling.TopImage                  = ""
            elementsScrolling.BackgroundTransparency    = 1
            elementsScrolling.BorderSizePixel           = 0
            elementsScrolling.Size                      = UDim2.fromScale(1, 1)
            elementsScrolling.ClipsDescendants          = false

            local elementsScrollingUIPadding = Instance.new("UIPadding")
            elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 5)
            elementsScrollingUIPadding.PaddingLeft   = UDim.new(0, 11)
            elementsScrollingUIPadding.PaddingRight  = UDim.new(0, 3)
            elementsScrollingUIPadding.PaddingTop    = UDim.new(0, 5)
            elementsScrollingUIPadding.Parent        = elementsScrolling

            local elementsScrollingUIListLayout = Instance.new("UIListLayout")
            elementsScrollingUIListLayout.Padding       = UDim.new(0, 15)
            elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
            elementsScrollingUIListLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            elementsScrollingUIListLayout.Parent        = elementsScrolling

            local left = Instance.new("Frame")
            left.Name                   = "Left"
            left.AutomaticSize          = Enum.AutomaticSize.Y
            left.BackgroundTransparency = 1
            left.BorderSizePixel        = 0
            left.Position               = UDim2.fromScale(0.512, 0)
            left.Size                   = UDim2.new(0.5, -10, 0, 0)

            local leftUIListLayout = Instance.new("UIListLayout")
            leftUIListLayout.Padding   = UDim.new(0, 15)
            leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            leftUIListLayout.Parent    = left

            left.Parent = elementsScrolling

            local right = Instance.new("Frame")
            right.Name                   = "Right"
            right.AutomaticSize          = Enum.AutomaticSize.Y
            right.BackgroundTransparency = 1
            right.BorderSizePixel        = 0
            right.LayoutOrder            = 1
            right.Position               = UDim2.fromScale(0.512, 0)
            right.Size                   = UDim2.new(0.5, -10, 0, 0)

            local rightUIListLayout = Instance.new("UIListLayout")
            rightUIListLayout.Padding   = UDim.new(0, 15)
            rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            rightUIListLayout.Parent    = right

            right.Parent = elementsScrolling
            elementsScrolling.Parent = elements1

            --// Section API
            function TabFunctions:Section(Settings)
                local SectionFunctions = {}

                local section = Instance.new("Frame")
                section.Name                   = "Section"
                section.AutomaticSize          = Enum.AutomaticSize.Y
                section.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                section.BackgroundTransparency = 0.98
                section.BorderSizePixel        = 0
                section.Position               = UDim2.fromScale(0, 0)
                section.Size                   = UDim2.fromScale(1, 0)
                section.ClipsDescendants       = true
                section.Parent                 = Settings.Side == "Left" and left or right

                local sectionUICorner = Instance.new("UICorner")
                sectionUICorner.Parent = section

                local sectionUIStroke = Instance.new("UIStroke")
                sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sectionUIStroke.Color           = Color3.fromRGB(255, 255, 255)
                sectionUIStroke.Transparency    = 0.95
                sectionUIStroke.Parent          = section

                local sectionUIListLayout = Instance.new("UIListLayout")
                sectionUIListLayout.Padding   = UDim.new(0, 10)
                sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sectionUIListLayout.Parent    = section

                local sectionUIPadding = Instance.new("UIPadding")
                sectionUIPadding.PaddingBottom = UDim.new(0, 20)
                sectionUIPadding.PaddingLeft   = UDim.new(0, 20)
                sectionUIPadding.PaddingRight  = UDim.new(0, 18)
                sectionUIPadding.PaddingTop    = UDim.new(0, 22)
                sectionUIPadding.Parent        = section

                --==========================================================
                -- BUTTON
                --==========================================================
                function SectionFunctions:Button(Settings, Flag)
                    local ButtonFunctions = { Settings = Settings }

                    local button = Instance.new("Frame")
                    button.Name                   = "Button"
                    button.AutomaticSize          = Enum.AutomaticSize.Y
                    button.BackgroundTransparency = 1
                    button.BorderSizePixel        = 0
                    button.Size                   = UDim2.new(1, 0, 0, 38)
                    button.Parent                 = section

                    local buttonInteract = Instance.new("TextButton")
                    buttonInteract.Name                   = "ButtonInteract"
                    buttonInteract.FontFace               = Font.new(assets.interFont)
                    buttonInteract.RichText               = true
                    buttonInteract.TextColor3             = Color3.fromRGB(255, 255, 255)
                    buttonInteract.TextSize               = 13
                    buttonInteract.TextTransparency       = 0.5
                    buttonInteract.TextTruncate           = Enum.TextTruncate.AtEnd
                    buttonInteract.TextXAlignment         = Enum.TextXAlignment.Left
                    buttonInteract.BackgroundTransparency = 1
                    buttonInteract.BorderSizePixel        = 0
                    buttonInteract.Size                   = UDim2.fromScale(1, 1)
                    buttonInteract.Parent                 = button
                    buttonInteract.Text                   = ButtonFunctions.Settings.Name

                    local buttonImage = Instance.new("ImageLabel")
                    buttonImage.Name                   = "ButtonImage"
                    buttonImage.Image                  = assets.buttonImage
                    buttonImage.ImageTransparency      = 0.5
                    buttonImage.AnchorPoint            = Vector2.new(1, 0.5)
                    buttonImage.BackgroundTransparency = 1
                    buttonImage.BorderSizePixel        = 0
                    buttonImage.Position               = UDim2.fromScale(1, 0.5)
                    buttonImage.Size                   = UDim2.fromOffset(15, 15)
                    buttonImage.Parent                 = button

                    buttonInteract.MouseEnter:Connect(function()
                        Tween(buttonInteract, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { TextTransparency = 0.3 }):Play()
                        Tween(buttonImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.3 }):Play()
                    end)
                    buttonInteract.MouseLeave:Connect(function()
                        Tween(buttonInteract, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { TextTransparency = 0.5 }):Play()
                        Tween(buttonImage, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.5 }):Play()
                    end)

                    buttonInteract.MouseButton1Click:Connect(function()
                        if ButtonFunctions.Settings.Callback then
                            task.spawn(ButtonFunctions.Settings.Callback)
                        end
                    end)

                    function ButtonFunctions:UpdateName(Name)
                        buttonInteract.Text = Name
                    end
                    function ButtonFunctions:SetVisibility(State)
                        button.Visible = State
                    end

                    if Flag then
                        xEzUI.Options[Flag] = ButtonFunctions
                    end
                    return ButtonFunctions
                end

                --==========================================================
                -- TOGGLE
                --==========================================================
                function SectionFunctions:Toggle(Settings, Flag)
                    local ToggleFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Toggle" }

                    local toggle = Instance.new("Frame")
                    toggle.Name                   = "Toggle"
                    toggle.AutomaticSize          = Enum.AutomaticSize.Y
                    toggle.BackgroundTransparency = 1
                    toggle.BorderSizePixel        = 0
                    toggle.Size                   = UDim2.new(1, 0, 0, 38)
                    toggle.Parent                 = section

                    local toggleName = Instance.new("TextLabel")
                    toggleName.Name                   = "ToggleName"
                    toggleName.FontFace               = Font.new(assets.interFont)
                    toggleName.Text                   = ToggleFunctions.Settings.Name
                    toggleName.RichText               = true
                    toggleName.TextColor3             = Color3.fromRGB(255, 255, 255)
                    toggleName.TextSize               = 13
                    toggleName.TextTransparency       = 0.5
                    toggleName.TextTruncate           = Enum.TextTruncate.AtEnd
                    toggleName.TextXAlignment         = Enum.TextXAlignment.Left
                    toggleName.AnchorPoint            = Vector2.new(0, 0.5)
                    toggleName.AutomaticSize          = Enum.AutomaticSize.Y
                    toggleName.BackgroundTransparency = 1
                    toggleName.BorderSizePixel        = 0
                    toggleName.Position               = UDim2.fromScale(0, 0.5)
                    toggleName.Size                   = UDim2.new(1, -50, 0, 0)
                    toggleName.Parent                 = toggle

                    local toggle1 = Instance.new("ImageButton")
                    toggle1.Name                   = "Toggle"
                    toggle1.Image                  = assets.toggleBackground
                    toggle1.ImageColor3             = Color3.fromRGB(87, 86, 86)
                    toggle1.AutoButtonColor        = false
                    toggle1.AnchorPoint            = Vector2.new(1, 0.5)
                    toggle1.BackgroundTransparency = 1
                    toggle1.BorderSizePixel        = 0
                    toggle1.Position               = UDim2.fromScale(1, 0.5)
                    toggle1.Size                   = UDim2.fromOffset(41, 21)
                    toggle1.ImageTransparency      = 0.5

                    local toggleUIPadding = Instance.new("UIPadding")
                    toggleUIPadding.PaddingBottom = UDim.new(0, 1)
                    toggleUIPadding.PaddingLeft   = UDim.new(0, -2)
                    toggleUIPadding.PaddingRight  = UDim.new(0, 3)
                    toggleUIPadding.PaddingTop    = UDim.new(0, 1)
                    toggleUIPadding.Parent        = toggle1

                    local togglerHead = Instance.new("ImageLabel")
                    togglerHead.Name                   = "TogglerHead"
                    togglerHead.Image                  = assets.togglerHead
                    togglerHead.ImageColor3             = Color3.fromRGB(255, 255, 255)
                    togglerHead.AnchorPoint            = Vector2.new(1, 0.5)
                    togglerHead.BackgroundTransparency = 1
                    togglerHead.BorderSizePixel        = 0
                    togglerHead.Position               = UDim2.fromScale(0.5, 0.5)
                    togglerHead.Size                   = UDim2.fromOffset(15, 15)
                    togglerHead.ZIndex                 = 2
                    togglerHead.Parent                 = toggle1
                    togglerHead.ImageTransparency      = 0.8

                    toggle1.Parent = toggle

                    local toggle1Transparency = { Enabled = 0, Disabled = 0.5 }
                    local togglerHeadTransparency = { Enabled = 0, Disabled = 0.85 }
                    local TweenSettings = {
                        Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                        EnabledPosition  = UDim2.new(1, 0, 0.5, 0),
                        DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
                    }

                    local togglebool = ToggleFunctions.Settings.Default

                    local function NewState(State, callback)
                        local transparencyValues = State and { toggle1Transparency.Enabled, togglerHeadTransparency.Enabled }
                            or { toggle1Transparency.Disabled, togglerHeadTransparency.Disabled }
                        local position = State and TweenSettings.EnabledPosition or TweenSettings.DisabledPosition

                        Tween(toggle1, TweenSettings.Info, { ImageTransparency = transparencyValues[1] }):Play()
                        Tween(togglerHead, TweenSettings.Info, { ImageTransparency = transparencyValues[2] }):Play()
                        Tween(togglerHead, TweenSettings.Info, { Position = position }):Play()

                        ToggleFunctions.State = State
                        if callback then callback(togglebool) end
                    end

                    NewState(togglebool)

                    local function Toggle()
                        togglebool = not togglebool
                        NewState(togglebool, ToggleFunctions.Settings.Callback)
                    end

                    toggle1.MouseButton1Click:Connect(Toggle)

                    function ToggleFunctions:Toggle() Toggle() end
                    function ToggleFunctions:UpdateState(State)
                        togglebool = State
                        NewState(togglebool, ToggleFunctions.Settings.Callback)
                    end
                    function ToggleFunctions:GetState() return togglebool end
                    function ToggleFunctions:UpdateName(Name) toggleName.Text = Name end
                    function ToggleFunctions:SetVisibility(State) toggle.Visible = State end

                    if Flag then
                        xEzUI.Options[Flag] = ToggleFunctions
                    end
                    return ToggleFunctions
                end

                --==========================================================
                -- SLIDER
                --==========================================================
                function SectionFunctions:Slider(Settings, Flag)
                    local SliderFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Slider" }

                    local slider = Instance.new("Frame")
                    slider.Name                   = "Slider"
                    slider.AutomaticSize          = Enum.AutomaticSize.Y
                    slider.BackgroundTransparency = 1
                    slider.BorderSizePixel        = 0
                    slider.Size                   = UDim2.new(1, 0, 0, 38)
                    slider.Parent                 = section

                    local sliderName = Instance.new("TextLabel")
                    sliderName.Name                   = "SliderName"
                    sliderName.FontFace               = Font.new(assets.interFont)
                    sliderName.Text                   = SliderFunctions.Settings.Name
                    sliderName.RichText               = true
                    sliderName.TextColor3             = Color3.fromRGB(255, 255, 255)
                    sliderName.TextSize               = 13
                    sliderName.TextTransparency       = 0.5
                    sliderName.TextTruncate           = Enum.TextTruncate.AtEnd
                    sliderName.TextXAlignment         = Enum.TextXAlignment.Left
                    sliderName.AnchorPoint            = Vector2.new(0, 0.5)
                    sliderName.AutomaticSize          = Enum.AutomaticSize.XY
                    sliderName.BackgroundTransparency = 1
                    sliderName.BorderSizePixel        = 0
                    sliderName.Position               = UDim2.fromScale(0, 0.5)
                    sliderName.Parent                 = slider

                    local sliderElements = Instance.new("Frame")
                    sliderElements.Name                   = "SliderElements"
                    sliderElements.AnchorPoint            = Vector2.new(1, 0)
                    sliderElements.BackgroundTransparency = 1
                    sliderElements.BorderSizePixel        = 0
                    sliderElements.Position               = UDim2.fromScale(1, 0)
                    sliderElements.Size                   = UDim2.fromScale(1, 1)

                    local sliderValue = Instance.new("TextBox")
                    sliderValue.Name                   = "SliderValue"
                    sliderValue.FontFace               = Font.new(assets.interFont)
                    sliderValue.TextColor3             = Color3.fromRGB(255, 255, 255)
                    sliderValue.TextSize               = 12
                    sliderValue.TextTransparency       = 0.1
                    sliderValue.BackgroundTransparency = 0.95
                    sliderValue.BorderSizePixel        = 0
                    sliderValue.LayoutOrder            = 1
                    sliderValue.Position               = UDim2.fromScale(-0.0789, 0.171)
                    sliderValue.Size                   = UDim2.fromOffset(41, 21)
                    sliderValue.ClipsDescendants       = true

                    local sliderValueUICorner = Instance.new("UICorner")
                    sliderValueUICorner.CornerRadius = UDim.new(0, 4)
                    sliderValueUICorner.Parent = sliderValue

                    local sliderValueUIStroke = Instance.new("UIStroke")
                    sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    sliderValueUIStroke.Color           = Color3.fromRGB(255, 255, 255)
                    sliderValueUIStroke.Transparency    = 0.9
                    sliderValueUIStroke.Parent          = sliderValue

                    local sliderValueUIPadding = Instance.new("UIPadding")
                    sliderValueUIPadding.PaddingLeft  = UDim.new(0, 2)
                    sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
                    sliderValueUIPadding.Parent       = sliderValue

                    sliderValue.Parent = sliderElements

                    local sliderElementsUIListLayout = Instance.new("UIListLayout")
                    sliderElementsUIListLayout.Padding           = UDim.new(0, 20)
                    sliderElementsUIListLayout.FillDirection     = Enum.FillDirection.Horizontal
                    sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    sliderElementsUIListLayout.SortOrder         = Enum.SortOrder.LayoutOrder
                    sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    sliderElementsUIListLayout.Parent            = sliderElements

                    local sliderBar = Instance.new("ImageLabel")
                    sliderBar.Name                   = "SliderBar"
                    sliderBar.Image                  = assets.sliderbar
                    sliderBar.ImageColor3             = Color3.fromRGB(87, 86, 86)
                    sliderBar.BackgroundTransparency = 1
                    sliderBar.BorderSizePixel        = 0
                    sliderBar.Position               = UDim2.fromScale(0.219, 0.457)
                    sliderBar.Size                   = UDim2.fromOffset(123, 3)

                    local sliderHead = Instance.new("ImageButton")
                    sliderHead.Name                   = "SliderHead"
                    sliderHead.Image                  = assets.sliderhead
                    sliderHead.AnchorPoint            = Vector2.new(0.5, 0.5)
                    sliderHead.BackgroundTransparency = 1
                    sliderHead.BorderSizePixel        = 0
                    sliderHead.Position               = UDim2.fromScale(1, 0.5)
                    sliderHead.Size                   = UDim2.fromOffset(12, 12)
                    sliderHead.Parent                 = sliderBar

                    sliderBar.Parent = sliderElements

                    local sliderElementsUIPadding = Instance.new("UIPadding")
                    sliderElementsUIPadding.PaddingTop = UDim.new(0, 3)
                    sliderElementsUIPadding.Parent     = sliderElements

                    sliderElements.Parent = slider

                    local dragging = false

                    local DisplayMethods = {
                        Round   = function(v, p) return p and string.format("%." .. p .. "f", v) or tostring(math.round(v)) end,
                        Degrees = function(v, p) return (p and string.format("%." .. p .. "f", v) or tostring(v)) .. "°" end,
                        Percent = function(v, p)
                            local pct = (v - SliderFunctions.Settings.Minimum) / (SliderFunctions.Settings.Maximum - SliderFunctions.Settings.Minimum) * 100
                            return p and string.format("%." .. p .. "f", pct) .. "%" or tostring(math.round(pct)) .. "%"
                        end,
                        Value   = function(v, p) return p and string.format("%." .. p .. "f", v) or tostring(v) end,
                    }

                    local ValueDisplayMethod = DisplayMethods[SliderFunctions.Settings.DisplayMethod] or DisplayMethods.Value
                    local finalValue

                    local function SetValue(val, ignorecallback)
                        local posXScale
                        if typeof(val) == "Instance" then
                            local input = val
                            posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        else
                            posXScale = (val - SliderFunctions.Settings.Minimum) / (SliderFunctions.Settings.Maximum - SliderFunctions.Settings.Minimum)
                        end

                        sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                        finalValue = posXScale * (SliderFunctions.Settings.Maximum - SliderFunctions.Settings.Minimum) + SliderFunctions.Settings.Minimum
                        sliderValue.Text = (SliderFunctions.Settings.Prefix or "") .. ValueDisplayMethod(finalValue, SliderFunctions.Settings.Precision) .. (SliderFunctions.Settings.Suffix or "")

                        if not ignorecallback then
                            task.spawn(function()
                                if SliderFunctions.Settings.Callback then
                                    SliderFunctions.Settings.Callback(finalValue)
                                end
                            end)
                        end

                        SliderFunctions.Value = finalValue
                    end

                    SetValue(SliderFunctions.Settings.Default or SliderFunctions.Settings.Minimum, true)

                    sliderHead.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            SetValue(input)
                        end
                    end)

                    sliderHead.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            if SliderFunctions.Settings.onInputComplete then
                                SliderFunctions.Settings.onInputComplete(finalValue)
                            end
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            SetValue(input)
                        end
                    end)

                    function SliderFunctions:UpdateName(Name) sliderName.Text = Name end
                    function SliderFunctions:SetVisibility(State) slider.Visible = State end
                    function SliderFunctions:UpdateValue(Value) SetValue(tonumber(Value), true) end
                    function SliderFunctions:GetValue() return finalValue end

                    if Flag then
                        xEzUI.Options[Flag] = SliderFunctions
                    end
                    return SliderFunctions
                end

                --==========================================================
                -- INPUT
                --==========================================================
                function SectionFunctions:Input(Settings, Flag)
                    local InputFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Input" }

                    local input = Instance.new("Frame")
                    input.Name                   = "Input"
                    input.AutomaticSize          = Enum.AutomaticSize.Y
                    input.BackgroundTransparency = 1
                    input.BorderSizePixel        = 0
                    input.Size                   = UDim2.new(1, 0, 0, 38)
                    input.Parent                 = section

                    local inputName = Instance.new("TextLabel")
                    inputName.Name                   = "InputName"
                    inputName.FontFace               = Font.new(assets.interFont)
                    inputName.Text                   = InputFunctions.Settings.Name
                    inputName.RichText               = true
                    inputName.TextColor3             = Color3.fromRGB(255, 255, 255)
                    inputName.TextSize               = 13
                    inputName.TextTransparency       = 0.5
                    inputName.TextTruncate           = Enum.TextTruncate.AtEnd
                    inputName.TextXAlignment         = Enum.TextXAlignment.Left
                    inputName.AnchorPoint            = Vector2.new(0, 0.5)
                    inputName.AutomaticSize          = Enum.AutomaticSize.XY
                    inputName.BackgroundTransparency = 1
                    inputName.BorderSizePixel        = 0
                    inputName.Position               = UDim2.fromScale(0, 0.5)
                    inputName.Parent                 = input

                    local inputBox = Instance.new("TextBox")
                    inputBox.Name                   = "InputBox"
                    inputBox.FontFace               = Font.new(assets.interFont)
                    inputBox.Text                   = "Hello world!"
                    inputBox.TextColor3             = Color3.fromRGB(255, 255, 255)
                    inputBox.TextSize               = 12
                    inputBox.TextTransparency       = 0.1
                    inputBox.AnchorPoint            = Vector2.new(1, 0.5)
                    inputBox.AutomaticSize          = Enum.AutomaticSize.X
                    inputBox.BackgroundTransparency = 0.95
                    inputBox.BorderSizePixel        = 0
                    inputBox.ClipsDescendants       = true
                    inputBox.LayoutOrder            = 1
                    inputBox.Position               = UDim2.fromScale(1, 0.5)
                    inputBox.Size                   = UDim2.fromOffset(21, 21)
                    inputBox.TextXAlignment         = Enum.TextXAlignment.Right

                    local inputBoxUICorner = Instance.new("UICorner")
                    inputBoxUICorner.CornerRadius = UDim.new(0, 4)
                    inputBoxUICorner.Parent = inputBox

                    local inputBoxUIStroke = Instance.new("UIStroke")
                    inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    inputBoxUIStroke.Color           = Color3.fromRGB(255, 255, 255)
                    inputBoxUIStroke.Transparency    = 0.9
                    inputBoxUIStroke.Parent          = inputBox

                    local inputBoxUIPadding = Instance.new("UIPadding")
                    inputBoxUIPadding.PaddingLeft  = UDim.new(0, 5)
                    inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    inputBoxUIPadding.Parent       = inputBox

                    inputBox.Parent = input

                    local CharacterSubs = {
                        All          = function(v) return v end,
                        Numeric      = function(v) return v:match("^%-?%d*$") and v or v:gsub("[^%d-]", "") end,
                        Alphabetic   = function(v) return v:gsub("[^a-zA-Z ]", "") end,
                        AlphaNumeric = function(v) return v:gsub("[^a-zA-Z0-9]", "") end,
                    }

                    local AcceptedCharacters = type(InputFunctions.Settings.AcceptedCharacters) == "function"
                        and InputFunctions.Settings.AcceptedCharacters
                        or CharacterSubs[InputFunctions.Settings.AcceptedCharacters] or CharacterSubs.All

                    InputBox.FocusLost:Connect(function()
                        local filteredText = AcceptedCharacters(InputBox.Text)
                        InputBox.Text = filteredText
                        task.spawn(function()
                            if InputFunctions.Settings.Callback then
                                InputFunctions.Settings.Callback(filteredText)
                            end
                        end)
                    end)

                    InputBox.Text = InputFunctions.Settings.Default or ""
                    InputBox.PlaceholderText = InputFunctions.Settings.Placeholder or ""

                    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        InputBox.Text = AcceptedCharacters(InputBox.Text)
                        if InputFunctions.Settings.onChanged then
                            InputFunctions.Settings.onChanged(InputBox.Text)
                        end
                        InputFunctions.Text = InputBox.Text
                    end)

                    function InputFunctions:UpdateName(Name) inputName.Text = Name end
                    function InputFunctions:SetVisibility(State) input.Visible = State end
                    function InputFunctions:GetInput() return InputBox.Text end
                    function InputFunctions:UpdatePlaceholder(Placeholder) inputBox.PlaceholderText = Placeholder end
                    function InputFunctions:UpdateText(Text)
                        local filteredText = AcceptedCharacters(Text)
                        InputBox.Text = filteredText
                        InputFunctions.Text = filteredText
                        task.spawn(function()
                            if InputFunctions.Settings.Callback then
                                InputFunctions.Settings.Callback(filteredText)
                            end
                        end)
                    end

                    if Flag then
                        xEzUI.Options[Flag] = InputFunctions
                    end
                    return InputFunctions
                end

                --==========================================================
                -- KEYBIND
                --==========================================================
                function SectionFunctions:Keybind(Settings, Flag)
                    local KeybindFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Keybind" }

                    local keybind = Instance.new("Frame")
                    keybind.Name                   = "Keybind"
                    keybind.AutomaticSize          = Enum.AutomaticSize.Y
                    keybind.BackgroundTransparency = 1
                    keybind.BorderSizePixel        = 0
                    keybind.Size                   = UDim2.new(1, 0, 0, 38)
                    keybind.Parent                 = section

                    local keybindName = Instance.new("TextLabel")
                    keybindName.Name                   = "KeybindName"
                    keybindName.FontFace               = Font.new(assets.interFont)
                    keybindName.Text                   = KeybindFunctions.Settings.Name
                    keybindName.RichText               = true
                    keybindName.TextColor3             = Color3.fromRGB(255, 255, 255)
                    keybindName.TextSize               = 13
                    keybindName.TextTransparency       = 0.5
                    keybindName.TextTruncate           = Enum.TextTruncate.AtEnd
                    keybindName.TextXAlignment         = Enum.TextXAlignment.Left
                    keybindName.AnchorPoint            = Vector2.new(0, 0.5)
                    keybindName.AutomaticSize          = Enum.AutomaticSize.XY
                    keybindName.BackgroundTransparency = 1
                    keybindName.BorderSizePixel        = 0
                    keybindName.Position               = UDim2.fromScale(0, 0.5)
                    keybindName.Parent                 = keybind

                    local binderBox = Instance.new("TextBox")
                    binderBox.Name                   = "BinderBox"
                    binderBox.CursorPosition         = -1
                    binderBox.FontFace               = Font.new(assets.interFont)
                    binderBox.PlaceholderText        = "..."
                    binderBox.Text                   = ""
                    binderBox.TextColor3             = Color3.fromRGB(255, 255, 255)
                    binderBox.TextSize               = 12
                    binderBox.TextTransparency       = 0.1
                    binderBox.AnchorPoint            = Vector2.new(1, 0.5)
                    binderBox.AutomaticSize          = Enum.AutomaticSize.X
                    binderBox.BackgroundTransparency = 0.95
                    binderBox.BorderSizePixel        = 0
                    binderBox.ClipsDescendants       = true
                    binderBox.LayoutOrder            = 1
                    binderBox.Position               = UDim2.fromScale(1, 0.5)
                    binderBox.Size                   = UDim2.fromOffset(21, 21)

                    local binderBoxUICorner = Instance.new("UICorner")
                    binderBoxUICorner.CornerRadius = UDim.new(0, 4)
                    binderBoxUICorner.Parent = binderBox

                    local binderBoxUIStroke = Instance.new("UIStroke")
                    binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    binderBoxUIStroke.Color           = Color3.fromRGB(255, 255, 255)
                    binderBoxUIStroke.Transparency    = 0.9
                    binderBoxUIStroke.Parent          = binderBox

                    local binderBoxUIPadding = Instance.new("UIPadding")
                    binderBoxUIPadding.PaddingLeft  = UDim.new(0, 5)
                    binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
                    binderBoxUIPadding.Parent       = binderBox

                    binderBox.Parent = keybind

                    local focused, isBinding, reset = false, false, false
                    local binded = KeybindFunctions.Settings.Default

                    if binded then binderBox.Text = binded.Name end

                    binderBox.Focused:Connect(function() focused = true end)
                    binderBox.FocusLost:Connect(function() focused = false end)

                    local function resetFocusState()
                        focused, isBinding = false, false
                        binderBox:ReleaseFocus()
                    end

                    UserInputService.InputBegan:Connect(function(inp)
                        if focused and not isBinding then
                            isBinding = true
                            local Event
                            Event = UserInputService.InputBegan:Connect(function(input)
                                if KeybindFunctions.Settings.Blacklist and
                                   (table.find(KeybindFunctions.Settings.Blacklist, input.KeyCode) or
                                    table.find(KeybindFunctions.Settings.Blacklist, input.UserInputType)) then
                                    binderBox:ReleaseFocus()
                                    resetFocusState()
                                    Event:Disconnect()
                                    return
                                end

                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    binded = input.KeyCode
                                    binderBox.Text = input.KeyCode.Name
                                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                                    binded = input.UserInputType
                                    binderBox.Text = input.UserInputType.Name
                                end

                                if KeybindFunctions.Settings.onBinded then
                                    KeybindFunctions.Settings.onBinded(binded)
                                end
                                reset = true
                                resetFocusState()
                                Event:Disconnect()
                            end)
                        else
                            if not reset and (inp.KeyCode == binded or inp.UserInputType == binded) then
                                if KeybindFunctions.Settings.Callback then
                                    KeybindFunctions.Settings.Callback(binded)
                                end
                                if KeybindFunctions.Settings.onBindHeld then
                                    KeybindFunctions.Settings.onBindHeld(true, binded)
                                end
                            else
                                reset = false
                            end
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(inp)
                        if not focused and not isBinding then
                            if inp.KeyCode == binded or inp.UserInputType == binded then
                                if Settings.onBindHeld then
                                    Settings.onBindHeld(false, binded)
                                end
                            end
                        end
                    end)

                    function KeybindFunctions:Bind(Key)
                        binded = Key
                        binderBox.Text = Key.Name
                    end
                    function KeybindFunctions:Unbind()
                        binded = nil
                        binderBox.Text = ""
                    end
                    function KeybindFunctions:GetBind() return binded end
                    function KeybindFunctions:UpdateName(Name) keybindName.Text = Name end
                    function KeybindFunctions:SetVisibility(State) keybind.Visible = State end

                    if Flag then
                        xEzUI.Options[Flag] = KeybindFunctions
                    end
                    return KeybindFunctions
                end

                --==========================================================
                -- DROPDOWN
                --==========================================================
                function SectionFunctions:Dropdown(Settings, Flag)
                    local DropdownFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Dropdown" }
                    local Selected = {}
                    local OptionObjs = {}

                    local dropdown = Instance.new("Frame")
                    dropdown.Name                   = "Dropdown"
                    dropdown.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                    dropdown.BackgroundTransparency = 0.985
                    dropdown.BorderSizePixel        = 0
                    dropdown.Size                   = UDim2.new(1, 0, 0, 38)
                    dropdown.Parent                 = section
                    dropdown.ClipsDescendants       = true

                    local dropdownUIPadding = Instance.new("UIPadding")
                    dropdownUIPadding.PaddingLeft  = UDim.new(0, 15)
                    dropdownUIPadding.PaddingRight = UDim.new(0, 15)
                    dropdownUIPadding.Parent       = dropdown

                    local interact = Instance.new("TextButton")
                    interact.Name                   = "Interact"
                    interact.Text                   = ""
                    interact.BackgroundTransparency = 1
                    interact.BorderSizePixel        = 0
                    interact.Size                   = UDim2.new(1, 0, 0, 38)
                    interact.Parent                 = dropdown

                    local dropdownName = Instance.new("TextLabel")
                    dropdownName.Name                   = "DropdownName"
                    dropdownName.FontFace               = Font.new(assets.interFont)
                    dropdownName.Text                   = Settings.Name .. "..."
                    dropdownName.RichText               = true
                    dropdownName.TextColor3             = Color3.fromRGB(255, 255, 255)
                    dropdownName.TextSize               = 13
                    dropdownName.TextTransparency       = 0.5
                    dropdownName.TextTruncate           = Enum.TextTruncate.SplitWord
                    dropdownName.TextXAlignment         = Enum.TextXAlignment.Left
                    dropdownName.AutomaticSize          = Enum.AutomaticSize.Y
                    dropdownName.BackgroundTransparency = 1
                    dropdownName.BorderSizePixel        = 0
                    dropdownName.Size                   = UDim2.new(1, -20, 0, 38)
                    dropdownName.Parent                 = dropdown

                    local dropdownUIStroke = Instance.new("UIStroke")
                    dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    dropdownUIStroke.Color           = Color3.fromRGB(255, 255, 255)
                    dropdownUIStroke.Transparency    = 0.95
                    dropdownUIStroke.Parent          = dropdown

                    local dropdownUICorner = Instance.new("UICorner")
                    dropdownUICorner.CornerRadius = UDim.new(0, 6)
                    dropdownUICorner.Parent = dropdown

                    local dropdownImage = Instance.new("ImageLabel")
                    dropdownImage.Name                   = "DropdownImage"
                    dropdownImage.Image                  = assets.dropdown
                    dropdownImage.ImageTransparency      = 0.5
                    dropdownImage.AnchorPoint            = Vector2.new(1, 0)
                    dropdownImage.BackgroundTransparency = 1
                    dropdownImage.BorderSizePixel        = 0
                    dropdownImage.Position               = UDim2.new(1, 0, 0, 12)
                    dropdownImage.Size                   = UDim2.fromOffset(14, 14)
                    dropdownImage.Parent                 = dropdown

                    local dropdownFrame = Instance.new("Frame")
                    dropdownFrame.Name                   = "DropdownFrame"
                    dropdownFrame.BackgroundTransparency = 1
                    dropdownFrame.BorderSizePixel        = 0
                    dropdownFrame.ClipsDescendants       = true
                    dropdownFrame.Size                   = UDim2.fromScale(1, 1)
                    dropdownFrame.Visible                = false
                    dropdownFrame.AutomaticSize          = Enum.AutomaticSize.Y

                    local dropdownFrameUIPadding = Instance.new("UIPadding")
                    dropdownFrameUIPadding.PaddingTop    = UDim.new(0, 38)
                    dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
                    dropdownFrameUIPadding.Parent        = dropdownFrame

                    local dropdownFrameUIListLayout = Instance.new("UIListLayout")
                    dropdownFrameUIListLayout.Padding   = UDim.new(0, 5)
                    dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dropdownFrameUIListLayout.Parent    = dropdownFrame

                    local tweensettings = {
                        duration       = 0.2,
                        easingStyle    = Enum.EasingStyle.Quint,
                        transparencyIn = 0.2,
                        transparencyOut= 0.5,
                        checkSizeIncrease = 12,
                        checkSizeDecrease = -13,
                    }

                    local function Toggle(optionName, State)
                        local option = OptionObjs[optionName]
                        if not option then return end

                        local checkmark = option.Checkmark
                        local optionNameLabel = option.NameLabel

                        if State then
                            if DropdownFunctions.Settings.Multi then
                                if not table.find(Selected, optionName) then
                                    table.insert(Selected, optionName)
                                    DropdownFunctions.Value = Selected
                                end
                            else
                                for name, opt in pairs(OptionObjs) do
                                    if name ~= optionName then
                                        Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                            Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)
                                        }):Play()
                                        Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                            TextTransparency = tweensettings.transparencyOut
                                        }):Play()
                                        opt.Checkmark.TextTransparency = 1
                                    end
                                end
                                Selected = { optionName }
                                DropdownFunctions.Value = Selected[1]
                            end
                            Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }):Play()
                            Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                TextTransparency = tweensettings.transparencyIn
                            }):Play()
                            checkmark.TextTransparency = 0
                        else
                            if DropdownFunctions.Settings.Multi then
                                local idx = table.find(Selected, optionName)
                                if idx then table.remove(Selected, idx) end
                            else
                                Selected = {}
                            end
                            Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                            }):Play()
                            Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                TextTransparency = tweensettings.transparencyOut
                            }):Play()
                            checkmark.TextTransparency = 1
                        end

                        if DropdownFunctions.Settings.Required and #Selected == 0 and not State then return end

                        if #Selected > 0 then
                            dropdownName.Text = DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")
                        else
                            dropdownName.Text = DropdownFunctions.Settings.Name .. "..."
                        end
                    end

                    local function CalculateDropdownSize()
                        local totalHeight = 0
                        local visibleChildrenCount = 0
                        local padding = dropdownFrameUIPadding.PaddingTop.Offset + dropdownFrameUIPadding.PaddingBottom.Offset

                        for _, v in pairs(dropdownFrame:GetChildren()) do
                            if not v:IsA("UIComponent") and v.Visible then
                                totalHeight += v.AbsoluteSize.Y
                                visibleChildrenCount += 1
                            end
                        end

                        local spacing = dropdownFrameUIListLayout.Padding.Offset * math.max(0, visibleChildrenCount - 1)
                        return totalHeight + spacing + padding
                    end

                    local dropped, db = false, false

                    local function ToggleDropdown()
                        if db then return end
                        db = true
                        local defaultDropdownSize = 38
                        local isDropdownOpen = not dropped
                        local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)

                        local dropTween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = targetSize })
                        local iconTween = Tween(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = isDropdownOpen and -90 or 0 })

                        dropTween:Play()
                        iconTween:Play()

                        if isDropdownOpen then
                            dropdownFrame.Visible = true
                            dropTween.Completed:Connect(function() db = false end)
                        else
                            dropTween.Completed:Connect(function()
                                dropdownFrame.Visible = false
                                db = false
                            end)
                        end

                        dropped = isDropdownOpen
                    end

                    interact.MouseButton1Click:Connect(ToggleDropdown)

                    local function addOption(i, v)
                        local option = Instance.new("TextButton")
                        option.Name                   = "Option"
                        option.Text                   = ""
                        option.BackgroundTransparency = 1
                        option.BorderSizePixel        = 0
                        option.Size                   = UDim2.new(1, 0, 0, 30)

                        local optionUIPadding = Instance.new("UIPadding")
                        optionUIPadding.PaddingLeft = UDim.new(0, 15)
                        optionUIPadding.Parent      = option

                        local optionName = Instance.new("TextLabel")
                        optionName.Name                   = "OptionName"
                        optionName.FontFace               = Font.new(assets.interFont)
                        optionName.Text                   = v
                        optionName.RichText               = true
                        optionName.TextColor3             = Color3.fromRGB(255, 255, 255)
                        optionName.TextSize               = 13
                        optionName.TextTransparency       = 0.5
                        optionName.TextTruncate           = Enum.TextTruncate.AtEnd
                        optionName.TextXAlignment         = Enum.TextXAlignment.Left
                        optionName.AnchorPoint            = Vector2.new(0, 0.5)
                        optionName.AutomaticSize          = Enum.AutomaticSize.XY
                        optionName.BackgroundTransparency = 1
                        optionName.BorderSizePixel        = 0
                        optionName.Position               = UDim2.fromScale(0, 0.5)
                        optionName.Parent                 = option

                        local optionUIListLayout = Instance.new("UIListLayout")
                        optionUIListLayout.Padding           = UDim.new(0, 10)
                        optionUIListLayout.FillDirection     = Enum.FillDirection.Horizontal
                        optionUIListLayout.SortOrder         = Enum.SortOrder.LayoutOrder
                        optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        optionUIListLayout.Parent            = option

                        local checkmark = Instance.new("TextLabel")
                        checkmark.Name                   = "Checkmark"
                        checkmark.FontFace               = Font.new(assets.interFont)
                        checkmark.Text                   = "✓"
                        checkmark.TextColor3             = Color3.fromRGB(255, 255, 255)
                        checkmark.TextSize               = 13
                        checkmark.TextTransparency       = 1
                        checkmark.AnchorPoint            = Vector2.new(0, 0.5)
                        checkmark.AutomaticSize          = Enum.AutomaticSize.Y
                        checkmark.BackgroundTransparency = 1
                        checkmark.BorderSizePixel        = 0
                        checkmark.LayoutOrder            = -1
                        checkmark.Position               = UDim2.fromScale(0, 0.5)
                        checkmark.Size                   = UDim2.fromOffset(-10, 0)
                        checkmark.Parent                 = option

                        option.Parent = dropdownFrame
                        dropdownFrame.Parent = dropdown

                        OptionObjs[v] = {
                            Index = i,
                            Button = option,
                            NameLabel = optionName,
                            Checkmark = checkmark
                        }

                        local isSelected = false
                        if DropdownFunctions.Settings.Default then
                            if DropdownFunctions.Settings.Multi then
                                isSelected = table.find(DropdownFunctions.Settings.Default, v) and true or false
                            else
                                isSelected = (DropdownFunctions.Settings.Default == i) and true or false
                            end
                        end
                        Toggle(v, isSelected)

                        option.MouseButton1Click:Connect(function()
                            local sel = table.find(Selected, v) and true or false
                            local newSelected = not sel

                            if DropdownFunctions.Settings.Required and not newSelected and #Selected <= 1 then return end

                            Toggle(v, newSelected)

                            task.spawn(function()
                                if DropdownFunctions.Settings.Multi then
                                    local Return = {}
                                    for _, opt in ipairs(Selected) do Return[opt] = true end
                                    if DropdownFunctions.Settings.Callback then
                                        DropdownFunctions.Settings.Callback(Return)
                                    end
                                else
                                    if newSelected and DropdownFunctions.Settings.Callback then
                                        DropdownFunctions.Settings.Callback(Selected[1] or nil)
                                    end
                                end
                            end)
                        end)

                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end

                    if DropdownFunctions.Settings.Options then
                        for i, v in pairs(DropdownFunctions.Settings.Options) do
                            addOption(i, v)
                        end
                    end

                    function DropdownFunctions:UpdateName(New) dropdownName.Text = New end
                    function DropdownFunctions:SetVisibility(State) dropdown.Visible = State end

                    function DropdownFunctions:UpdateSelection(newSelection)
                        if not newSelection then return end
                        for option, _ in pairs(OptionObjs) do
                            Toggle(option, false)
                        end
                        local selectedOptions = {}
                        if type(newSelection) == "number" then
                            for option, data in pairs(OptionObjs) do
                                local isSel = data.Index == newSelection
                                Toggle(option, isSel)
                                if isSel then table.insert(selectedOptions, option) end
                            end
                        elseif type(newSelection) == "string" then
                            for option, _ in pairs(OptionObjs) do
                                local isSel = option == newSelection
                                Toggle(option, isSel)
                                if isSel then table.insert(selectedOptions, option) end
                            end
                        elseif type(newSelection) == "table" then
                            for option, _ in pairs(OptionObjs) do
                                local isSel = table.find(newSelection, option) ~= nil
                                Toggle(option, isSel)
                                if isSel then table.insert(selectedOptions, option) end
                            end
                        end
                        if DropdownFunctions.Settings.Callback then
                            if DropdownFunctions.Settings.Multi then
                                local Return = {}
                                for _, opt in ipairs(selectedOptions) do Return[opt] = true end
                                DropdownFunctions.Settings.Callback(Return)
                            else
                                DropdownFunctions.Settings.Callback(selectedOptions[1] or nil)
                            end
                        end
                    end

                    function DropdownFunctions:InsertOptions(newOptions)
                        if not newOptions then return end
                        DropdownFunctions.Settings.Options = newOptions
                        for i, v in pairs(newOptions) do addOption(i, v) end
                    end

                    function DropdownFunctions:ClearOptions()
                        for _, optionData in pairs(OptionObjs) do
                            optionData.Button:Destroy()
                        end
                        OptionObjs = {}
                        Selected = {}
                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end

                    function DropdownFunctions:GetOptions()
                        local optionsStatus = {}
                        for option, _ in pairs(OptionObjs) do
                            optionsStatus[option] = table.find(Selected, option) and true or false
                        end
                        return optionsStatus
                    end

                    function DropdownFunctions:RemoveOptions(remove)
                        if not remove then return end
                        for _, optionName in ipairs(remove) do
                            local optionData = OptionObjs[optionName]
                            if optionData then
                                for i = #Selected, 1, -1 do
                                    if Selected[i] == optionName then
                                        table.remove(Selected, i)
                                    end
                                end
                                optionData.Button:Destroy()
                                OptionObjs[optionName] = nil
                            end
                        end
                        if dropped then
                            dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                        end
                    end

                    function DropdownFunctions:IsOption(optionName)
                        if not optionName then return end
                        return OptionObjs[optionName] ~= nil
                    end

                    if Flag then
                        xEzUI.Options[Flag] = DropdownFunctions
                    end
                    return DropdownFunctions
                end

                --==========================================================
                -- DIVIDER / SPACER / LABEL / PARAGRAPH
                --==========================================================
                function SectionFunctions:Divider()
                    local DividerFunctions = {}
                    local divider = Instance.new("Frame")
                    divider.Name                   = "Divider"
                    divider.AnchorPoint            = Vector2.new(0, 1)
                    divider.AutomaticSize          = Enum.AutomaticSize.Y
                    divider.BackgroundTransparency = 1
                    divider.BorderSizePixel        = 0
                    divider.Position               = UDim2.fromScale(0, 1)
                    divider.Size                   = UDim2.new(1, 0, 0, 1)
                    divider.Parent                 = section

                    local uIPadding = Instance.new("UIPadding")
                    uIPadding.PaddingBottom = UDim.new(0, 8)
                    uIPadding.PaddingTop    = UDim.new(0, 8)
                    uIPadding.Parent        = divider

                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Parent    = divider

                    local line = Instance.new("Frame")
                    line.Name                   = "Line"
                    line.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                    line.BackgroundTransparency = 0.9
                    line.BorderSizePixel        = 0
                    line.Size                   = UDim2.new(1, 0, 0, 1)
                    line.Parent                 = divider

                    function DividerFunctions:Remove() divider:Destroy() end
                    function DividerFunctions:SetVisibility(State) divider.Visible = State end
                    return DividerFunctions
                end

                function SectionFunctions:Spacer()
                    local SpacerFunctions = {}
                    local spacer = Instance.new("Frame")
                    spacer.Name                   = "Spacer"
                    spacer.BackgroundTransparency = 1
                    spacer.BorderSizePixel        = 0
                    spacer.Parent                 = section

                    function SpacerFunctions:Remove() spacer:Destroy() end
                    function SpacerFunctions:SetVisibility(State) spacer.Visible = State end
                    return SpacerFunctions
                end

                function SectionFunctions:Label(Settings, Flag)
                    local LabelFunctions = { Settings = Settings }
                    local label = Instance.new("Frame")
                    label.Name                   = "Label"
                    label.AutomaticSize          = Enum.AutomaticSize.Y
                    label.BackgroundTransparency = 1
                    label.BorderSizePixel        = 0
                    label.Size                   = UDim2.new(1, 0, 0, 38)
                    label.Parent                 = section

                    local labelText = Instance.new("TextLabel")
                    labelText.Name                   = "LabelText"
                    labelText.FontFace               = Font.new(assets.interFont)
                    labelText.RichText               = true
                    labelText.Text                   = LabelFunctions.Settings.Text or LabelFunctions.Settings.Name
                    labelText.TextColor3             = Color3.fromRGB(255, 255, 255)
                    labelText.TextSize               = 13
                    labelText.TextTransparency       = 0.5
                    labelText.TextWrapped            = true
                    labelText.TextXAlignment         = Enum.TextXAlignment.Left
                    labelText.AutomaticSize          = Enum.AutomaticSize.Y
                    labelText.BackgroundTransparency = 1
                    labelText.BorderSizePixel        = 0
                    labelText.Size                   = UDim2.fromScale(1, 1)
                    labelText.Parent                 = label

                    function LabelFunctions:UpdateName(New) labelText.Text = New end
                    function LabelFunctions:SetVisibility(State) label.Visible = State end

                    if Flag then xEzUI.Options[Flag] = LabelFunctions end
                    return LabelFunctions
                end

                function SectionFunctions:Paragraph(Settings, Flag)
                    local ParagraphFunctions = { Settings = Settings }
                    local paragraph = Instance.new("Frame")
                    paragraph.Name                   = "Paragraph"
                    paragraph.AutomaticSize          = Enum.AutomaticSize.Y
                    paragraph.BackgroundTransparency = 1
                    paragraph.BorderSizePixel        = 0
                    paragraph.Size                   = UDim2.new(1, 0, 0, 38)
                    paragraph.Parent                 = section

                    local paragraphHeader = Instance.new("TextLabel")
                    paragraphHeader.Name                   = "ParagraphHeader"
                    paragraphHeader.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    paragraphHeader.RichText               = true
                    paragraphHeader.Text                   = ParagraphFunctions.Settings.Header
                    paragraphHeader.TextColor3             = Color3.fromRGB(255, 255, 255)
                    paragraphHeader.TextSize               = 15
                    paragraphHeader.TextTransparency       = 0.4
                    paragraphHeader.TextWrapped            = true
                    paragraphHeader.TextXAlignment         = Enum.TextXAlignment.Left
                    paragraphHeader.AutomaticSize          = Enum.AutomaticSize.Y
                    paragraphHeader.BackgroundTransparency = 1
                    paragraphHeader.BorderSizePixel        = 0
                    paragraphHeader.Size                   = UDim2.fromScale(1, 0)
                    paragraphHeader.Parent                 = paragraph

                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.Padding   = UDim.new(0, 5)
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Parent    = paragraph

                    local paragraphBody = Instance.new("TextLabel")
                    paragraphBody.Name                   = "ParagraphBody"
                    paragraphBody.FontFace               = Font.new(assets.interFont)
                    paragraphBody.RichText               = true
                    paragraphBody.Text                   = ParagraphFunctions.Settings.Body
                    paragraphBody.TextColor3             = Color3.fromRGB(255, 255, 255)
                    paragraphBody.TextSize               = 13
                    paragraphBody.TextTransparency       = 0.5
                    paragraphBody.TextWrapped            = true
                    paragraphBody.TextXAlignment         = Enum.TextXAlignment.Left
                    paragraphBody.AutomaticSize          = Enum.AutomaticSize.Y
                    paragraphBody.BackgroundTransparency = 1
                    paragraphBody.BorderSizePixel        = 0
                    paragraphBody.LayoutOrder            = 1
                    paragraphBody.Size                   = UDim2.fromScale(1, 0)
                    paragraphBody.Parent                 = paragraph

                    function ParagraphFunctions:UpdateHeader(New) paragraphHeader.Text = New end
                    function ParagraphFunctions:UpdateBody(New) paragraphBody.Text = New end
                    function ParagraphFunctions:SetVisibility(State) paragraph.Visible = State end

                    if Flag then xEzUI.Options[Flag] = ParagraphFunctions end
                    return ParagraphFunctions
                end

                function SectionFunctions:Header(Settings, Flag)
                    local HeaderFunctions = { Settings = Settings }
                    local header = Instance.new("Frame")
                    header.Name                   = "Header"
                    header.AutomaticSize          = Enum.AutomaticSize.Y
                    header.BackgroundTransparency = 1
                    header.BorderSizePixel        = 0
                    header.LayoutOrder            = 0
                    header.Size                   = UDim2.fromScale(1, 0)
                    header.Parent                 = section

                    local uIPadding = Instance.new("UIPadding")
                    uIPadding.PaddingBottom = UDim.new(0, 5)
                    uIPadding.Parent        = header

                    local headerText = Instance.new("TextLabel")
                    headerText.Name                   = "HeaderText"
                    headerText.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                    headerText.RichText               = true
                    headerText.Text                   = HeaderFunctions.Settings.Text or HeaderFunctions.Settings.Name
                    headerText.TextColor3             = Color3.fromRGB(255, 255, 255)
                    headerText.TextSize               = 16
                    headerText.TextTransparency       = 0.3
                    headerText.TextWrapped            = true
                    headerText.TextXAlignment         = Enum.TextXAlignment.Left
                    headerText.AutomaticSize          = Enum.AutomaticSize.Y
                    headerText.BackgroundTransparency = 1
                    headerText.BorderSizePixel        = 0
                    headerText.Size                   = UDim2.fromScale(1, 0)
                    headerText.Parent                 = header

                    function HeaderFunctions:UpdateName(New) headerText.Text = New end
                    function HeaderFunctions:SetVisibility(State) header.Visible = State end

                    if Flag then xEzUI.Options[Flag] = HeaderFunctions end
                    return HeaderFunctions
                end

                return SectionFunctions
            end

            --// Tab select
            local function SelectCurrentTab()
                local easetime = 0.15
                if currentTabInstance then currentTabInstance.Parent = nil end
                for i, tabInfo in pairs(tabs) do
                    Tween(i, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
                        BackgroundTransparency = (i == tabSwitcher and 0.98 or 1)
                    }):Play()
                    if tabInfo.tabStroke then
                        Tween(tabInfo.tabStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
                            Transparency = (i == tabSwitcher and 0.95 or 1)
                        }):Play()
                    end
                    if tabInfo.switcherImage then
                        Tween(tabInfo.switcherImage, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
                            ImageTransparency = (i == tabSwitcher and 0.1 or 0.5)
                        }):Play()
                    end
                    if tabInfo.switcherName then
                        Tween(tabInfo.switcherName, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
                            TextTransparency = (i == tabSwitcher and 0.1 or 0.5)
                        }):Play()
                    end
                end
                tabs[tabSwitcher].tabContent.Parent = content
                currentTabInstance = tabs[tabSwitcher].tabContent
                currentTab.Text = Settings.Name
            end

            tabSwitcher.MouseButton1Click:Connect(SelectCurrentTab)
            function TabFunctions:Select() SelectCurrentTab() end

            tabs[tabSwitcher] = {
                tabContent = elements1,
                tabStroke = tabSwitcherUIStroke,
                switcherImage = tabImage,
                switcherName = tabSwitcherName,
            }

            return TabFunctions
        end

        return SectionFunctions
    end

    --// Notify API
    function WindowFunctions:Notify(Settings)
        local NotificationFunctions = {}

        local notification = Instance.new("Frame")
        notification.Name                   = "Notification"
        notification.AnchorPoint            = Vector2.new(0.5, 0.5)
        notification.AutomaticSize          = Enum.AutomaticSize.Y
        notification.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
        notification.BorderSizePixel        = 0
        notification.Position               = UDim2.fromScale(0.5, 0.5)
        notification.Size                   = UDim2.fromOffset(Settings.SizeX or 250, 0)
        notification.Parent                 = notifications

        local notificationUIStroke = Instance.new("UIStroke")
        notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        notificationUIStroke.Color           = Color3.fromRGB(255, 255, 255)
        notificationUIStroke.Transparency    = 0.9
        notificationUIStroke.Parent          = notification

        local notificationUICorner = Instance.new("UICorner")
        notificationUICorner.CornerRadius = UDim.new(0, 10)
        notificationUICorner.Parent = notification

        local notificationUIScale = Instance.new("UIScale")
        notificationUIScale.Parent = notification
        notificationUIScale.Scale = 0

        local notificationInformation = Instance.new("Frame")
        notificationInformation.Name                   = "NotificationInformation"
        notificationInformation.AutomaticSize          = Enum.AutomaticSize.Y
        notificationInformation.BackgroundTransparency = 1
        notificationInformation.BorderSizePixel        = 0
        notificationInformation.Size                   = UDim2.fromScale(1, 1)

        local notificationTitle = Instance.new("TextLabel")
        notificationTitle.Name                   = "NotificationTitle"
        notificationTitle.FontFace               = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        notificationTitle.RichText               = true
        notificationTitle.Text                   = Settings.Title
        notificationTitle.TextColor3             = Color3.fromRGB(255, 255, 255)
        notificationTitle.TextSize               = 13
        notificationTitle.TextTransparency       = 0.2
        notificationTitle.TextTruncate           = Enum.TextTruncate.SplitWord
        notificationTitle.TextXAlignment         = Enum.TextXAlignment.Left
        notificationTitle.AutomaticSize          = Enum.AutomaticSize.XY
        notificationTitle.BackgroundTransparency = 1
        notificationTitle.BorderSizePixel        = 0
        notificationTitle.Size                   = UDim2.new(1, -12, 0, 0)
        notificationTitle.Parent                 = notificationInformation

        local notificationDescription = Instance.new("TextLabel")
        notificationDescription.Name                   = "NotificationDescription"
        notificationDescription.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        notificationDescription.Text                   = Settings.Description
        notificationDescription.TextColor3             = Color3.fromRGB(255, 255, 255)
        notificationDescription.TextSize               = 11
        notificationDescription.TextTransparency       = 0.5
        notificationDescription.TextWrapped            = true
        notificationDescription.RichText               = true
        notificationDescription.TextXAlignment         = Enum.TextXAlignment.Left
        notificationDescription.AutomaticSize          = Enum.AutomaticSize.XY
        notificationDescription.BackgroundTransparency = 1
        notificationDescription.BorderSizePixel        = 0
        notificationDescription.Size                   = UDim2.new(1, -12, 0, 0)
        notificationDescription.Parent                 = notificationInformation

        local notificationUIPadding = Instance.new("UIPadding")
        notificationUIPadding.PaddingBottom = UDim.new(0, 12)
        notificationUIPadding.PaddingLeft   = UDim.new(0, 10)
        notificationUIPadding.PaddingRight  = UDim.new(0, 10)
        notificationUIPadding.PaddingTop    = UDim.new(0, 10)
        notificationUIPadding.Parent        = notificationInformation

        notificationInformation.Parent = notification

        local notificationControls = Instance.new("Frame")
        notificationControls.Name                   = "NotificationControls"
        notificationControls.AutomaticSize          = Enum.AutomaticSize.Y
        notificationControls.BackgroundTransparency = 1
        notificationControls.BorderSizePixel        = 0
        notificationControls.Size                   = UDim2.fromScale(1, 1)

        local interactable = Instance.new("TextButton")
        interactable.Name                   = "Interactable"
        interactable.FontFace               = Font.new(assets.interFont)
        interactable.Text                   = "✓"
        interactable.TextColor3             = Color3.fromRGB(255, 255, 255)
        interactable.TextSize               = 17
        interactable.TextTransparency       = 0.2
        interactable.AnchorPoint            = Vector2.new(1, 0.5)
        interactable.AutomaticSize          = Enum.AutomaticSize.XY
        interactable.BackgroundTransparency = 1
        interactable.BorderSizePixel        = 0
        interactable.LayoutOrder            = 1
        interactable.Position               = UDim2.fromScale(1, 0.5)
        interactable.Parent                 = notificationControls

        local uIPadding = Instance.new("UIPadding")
        uIPadding.PaddingBottom = UDim.new(0, 6)
        uIPadding.PaddingRight  = UDim.new(0, 13)
        uIPadding.PaddingTop    = UDim.new(0, 6)
        uIPadding.Parent        = notificationControls

        notificationControls.Parent = notification

        local tweens = {
            In  = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = Settings.Scale or 1 }),
            Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 0 }),
        }

        local styles = {
            None    = function() interactable:Destroy() end,
            Confirm = function() interactable.Text = "✓" end,
            Cancel  = function() interactable.Text = "✗" end
        }

        local style = styles[Settings.Style] or function() interactable:Destroy() end
        style()

        if interactable then
            interactable.MouseButton1Click:Connect(function()
                NotificationFunctions:Cancel()
                if Settings.Callback then task.spawn(Settings.Callback) end
            end)
        end

        local AnimateNotification = task.spawn(function()
            tweens.In:Play()
            Settings.Lifetime = Settings.Lifetime or 3
            if Settings.Lifetime ~= 0 then
                task.wait(Settings.Lifetime)
                local out = tweens.Out
                out:Play()
                out.Completed:Wait()
                notification:Destroy()
            end
        end)

        function NotificationFunctions:UpdateTitle(New) notificationTitle.Text = New end
        function NotificationFunctions:UpdateDescription(New) notificationDescription.Text = New end
        function NotificationFunctions:Resize(X) notification.Size = UDim2.fromOffset(X or 250, 0) end
        function NotificationFunctions:Cancel()
            task.cancel(AnimateNotification)
            local out = tweens.Out
            out:Play()
            out.Completed:Wait()
            notification:Destroy()
        end

        return NotificationFunctions
    end

    --// Dialog API
    function WindowFunctions:Dialog(Settings)
        local DialogFunctions = {}

        local dialogCanvas = Instance.new("CanvasGroup")
        dialogCanvas.Name                   = "DialogCanvas"
        dialogCanvas.BackgroundTransparency = 1
        dialogCanvas.BorderSizePixel        = 0
        dialogCanvas.Size                   = UDim2.fromScale(1, 1)
        dialogCanvas.GroupTransparency      = 1
        dialogCanvas.Parent                 = base

        local dialog = Instance.new("Frame")
        dialog.Name                   = "Dialog"
        dialog.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        dialog.BackgroundTransparency = 0.5
        dialog.BorderSizePixel        = 0
        dialog.Size                   = UDim2.fromScale(1, 1)

        local dialogUICorner = Instance.new("UICorner")
        dialogUICorner.CornerRadius = UDim.new(0, 10)
        dialogUICorner.Parent = dialog

        local prompt = Instance.new("Frame")
        prompt.Name                   = "Prompt"
        prompt.AnchorPoint            = Vector2.new(0.5, 0.5)
        prompt.AutomaticSize          = Enum.AutomaticSize.Y
        prompt.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
        prompt.BorderSizePixel        = 0
        prompt.Position               = UDim2.fromScale(0.5, 0.5)
        prompt.Size                   = UDim2.fromOffset(280, 0)

        local promptUIScale = Instance.new("UIScale")
        promptUIScale.Parent = prompt
        promptUIScale.Scale = 0.95

        local promptStroke = Instance.new("UIStroke")
        promptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        promptStroke.Color           = Color3.fromRGB(255, 255, 255)
        promptStroke.Transparency    = 0.9
        promptStroke.Parent          = prompt

        local promptCorner = Instance.new("UICorner")
        promptCorner.CornerRadius = UDim.new(0, 10)
        promptCorner.Parent = prompt

        local promptPadding = Instance.new("UIPadding")
        promptPadding.PaddingBottom = UDim.new(0, 20)
        promptPadding.PaddingLeft   = UDim.new(0, 20)
        promptPadding.PaddingRight  = UDim.new(0, 20)
        promptPadding.PaddingTop    = UDim.new(0, 20)
        promptPadding.Parent        = prompt

        local paragraph = Instance.new("Frame")
        paragraph.Name                   = "Paragraph"
        paragraph.AutomaticSize          = Enum.AutomaticSize.Y
        paragraph.BackgroundTransparency = 1
        paragraph.BorderSizePixel        = 0
        paragraph.Size                   = UDim2.new(1, 0, 0, 38)

        local paragraphHeader = Instance.new("TextLabel")
        paragraphHeader.Name                   = "ParagraphHeader"
        paragraphHeader.FontFace               = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        paragraphHeader.RichText               = true
        paragraphHeader.Text                   = Settings.Title
        paragraphHeader.TextColor3             = Color3.fromRGB(255, 255, 255)
        paragraphHeader.TextSize               = 18
        paragraphHeader.TextTransparency       = 0.4
        paragraphHeader.TextWrapped            = true
        paragraphHeader.AutomaticSize          = Enum.AutomaticSize.Y
        paragraphHeader.BackgroundTransparency = 1
        paragraphHeader.BorderSizePixel        = 0
        paragraphHeader.Size                   = UDim2.fromScale(1, 0)
        paragraphHeader.Parent                 = paragraph

        local uIListLayout = Instance.new("UIListLayout")
        uIListLayout.Padding   = UDim.new(0, 15)
        uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout.Parent    = paragraph

        local paragraphBody = Instance.new("TextLabel")
        paragraphBody.Name                   = "ParagraphBody"
        paragraphBody.FontFace               = Font.new(assets.interFont)
        paragraphBody.RichText               = true
        paragraphBody.Text                   = Settings.Description
        paragraphBody.TextColor3             = Color3.fromRGB(255, 255, 255)
        paragraphBody.TextSize               = 14
        paragraphBody.TextTransparency       = 0.5
        paragraphBody.TextWrapped            = true
        paragraphBody.AutomaticSize          = Enum.AutomaticSize.Y
        paragraphBody.BackgroundTransparency = 1
        paragraphBody.BorderSizePixel        = 0
        paragraphBody.LayoutOrder            = 1
        paragraphBody.Size                   = UDim2.fromScale(1, 0)
        paragraphBody.Parent                 = paragraph

        paragraph.Parent = prompt

        local interactions = Instance.new("Frame")
        interactions.Name                   = "Interactions"
        interactions.AutomaticSize          = Enum.AutomaticSize.Y
        interactions.BackgroundTransparency = 1
        interactions.BorderSizePixel        = 0
        interactions.LayoutOrder            = 1
        interactions.Size                   = UDim2.fromScale(1, 0)

        local uIListLayout1 = Instance.new("UIListLayout")
        uIListLayout1.Padding   = UDim.new(0, 10)
        uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout1.Parent    = interactions

        local uIPadding = Instance.new("UIPadding")
        uIPadding.PaddingTop = UDim.new(0, 20)
        uIPadding.Parent     = interactions

        interactions.Parent = prompt

        local uIListLayout2 = Instance.new("UIListLayout")
        uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout2.Parent    = prompt

        prompt.Parent = dialog
        dialog.Parent = dialogCanvas

        local canvasIn  = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
        local canvasOut = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
        local scaleIn   = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
        local scaleOut  = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })

        local function dialogIn()
            canvasIn:Play()
            scaleIn:Play()
            canvasIn.Completed:Wait()
            dialog.Parent = base
        end

        local function dialogOut()
            if not dialog.Parent then return end
            dialog.Parent = dialogCanvas
            canvasOut:Play()
            scaleOut:Play()
            canvasOut.Completed:Wait()
            dialogCanvas:Destroy()
        end

        for _, v in pairs(Settings.Buttons) do
            local button = Instance.new("TextButton")
            button.Name                   = "Button"
            button.FontFace               = Font.new(assets.interFont)
            button.Text                   = v.Name
            button.TextColor3             = Color3.fromRGB(255, 255, 255)
            button.TextSize               = 15
            button.TextTransparency       = 0.5
            button.TextTruncate           = Enum.TextTruncate.AtEnd
            button.AutoButtonColor        = false
            button.AutomaticSize          = Enum.AutomaticSize.Y
            button.BackgroundColor3       = Color3.fromRGB(25, 25, 25)
            button.BorderSizePixel        = 0
            button.Size                   = UDim2.fromScale(1, 0)

            local uIPadding1 = Instance.new("UIPadding")
            uIPadding1.PaddingBottom = UDim.new(0, 9)
            uIPadding1.PaddingLeft   = UDim.new(0, 10)
            uIPadding1.PaddingRight  = UDim.new(0, 10)
            uIPadding1.PaddingTop    = UDim.new(0, 9)
            uIPadding1.Parent        = button

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 10)
            buttonCorner.Parent = button

            button.Parent = interactions

            button.MouseButton1Click:Connect(function()
                if dialogCanvas.GroupTransparency ~= 0 then return end
                if v.Callback then task.spawn(v.Callback) end
                dialogOut()
            end)

            button.MouseEnter:Connect(function()
                Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.3, TextTransparency = 0.6 }):Play()
            end)
            button.MouseLeave:Connect(function()
                Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0, TextTransparency = 0.5 }):Play()
            end)
        end

        dialogIn()

        function DialogFunctions:UpdateTitle(New) paragraphHeader.Text = New end
        function DialogFunctions:UpdateDescription(New) paragraphBody.Text = New end
        function DialogFunctions:Cancel() dialogOut() end

        return DialogFunctions
    end

    --// Misc window methods
    function WindowFunctions:SetNotificationsState(State) notifications.Visible = State end
    function WindowFunctions:GetNotificationsState() return notifications.Visible end
    function WindowFunctions:SetState(State) windowState = State; base.Visible = State end
    function WindowFunctions:GetState() return windowState end

    local onUnloadCallback
    function WindowFunctions:Unload()
        if onUnloadCallback then onUnloadCallback() end
        macLib:Destroy()
        unloaded = true
    end
    function WindowFunctions.onUnloaded(callback) onUnloadCallback = callback end

    local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl

    local function ToggleMenu()
        local state = not WindowFunctions:GetState()
        WindowFunctions:SetState(state)
        WindowFunctions:Notify({
            Title = Settings.Title,
            Description = (state and "Maximized " or "Minimized ") .. "the menu. Use " .. tostring(MenuKeybind.Name) .. " to toggle it.",
            Lifetime = 5
        })
    end

    UserInputService.InputEnded:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == MenuKeybind then ToggleMenu() end
    end)

    minimize.MouseButton1Click:Connect(ToggleMenu)
    exit.MouseButton1Click:Connect(function()
        WindowFunctions:Dialog({
            Title = Settings.Title,
            Description = "Are you sure you want to exit the menu? You will lose any unsaved configurations.",
            Buttons = {
                { Name = "Confirm", Callback = function() WindowFunctions:Unload() end },
                { Name = "Cancel" }
            }
        })
    end)

    function WindowFunctions:SetKeybind(Keycode) MenuKeybind = Keycode end
    function WindowFunctions:SetAcrylicBlurState(State)
        acrylicBlur = State
        base.BackgroundTransparency = State and 0.05 or 0
    end
    function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end

    local showUserInfo = Settings.ShowUserInfo ~= nil and Settings.ShowUserInfo or true
    local function _SetUserInfoState(State)
        if State then
            headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
            username.Text  = "@" .. LocalPlayer.Name
            displayName.Text = LocalPlayer.DisplayName
        else
            headshot.Image = assets.userInfoBlurred
            username.Text  = "@" .. string.rep(".", #LocalPlayer.Name)
            displayName.Text = string.rep(".", #LocalPlayer.DisplayName)
        end
    end
    _SetUserInfoState(showUserInfo)

    function WindowFunctions:SetUserInfoState(State) _SetUserInfoState(State) end
    function WindowFunctions:GetUserInfoState() return showUserInfo end

    function WindowFunctions:SetSize(Size) base.Size = Size end
    function WindowFunctions:GetSize() return base.Size end
    function WindowFunctions:SetScale(Scale) baseUIScale.Scale = Scale end
    function WindowFunctions:GetScale() return baseUIScale.Scale end

    --// Config system
    local ClassParser = {
        ["Toggle"] = {
            Save = function(Flag, data) return { type = "Toggle", flag = Flag, state = data.State or false } end,
            Load = function(Flag, data)
                if xEzUI.Options[Flag] and data.state then xEzUI.Options[Flag]:UpdateState(data.state) end
            end
        },
        ["Slider"] = {
            Save = function(Flag, data) return { type = "Slider", flag = Flag, value = (data.Value and tostring(data.Value)) or false } end,
            Load = function(Flag, data)
                if xEzUI.Options[Flag] and data.value then xEzUI.Options[Flag]:UpdateValue(data.value) end
            end
        },
        ["Input"] = {
            Save = function(Flag, data) return { type = "Input", flag = Flag, text = data.Text } end,
            Load = function(Flag, data)
                if xEzUI.Options[Flag] and data.text and type(data.text) == "string" then
                    xEzUI.Options[Flag]:UpdateText(data.text)
                end
            end
        },
        ["Keybind"] = {
            Save = function(Flag, data)
                return { type = "Keybind", flag = Flag, bind = (typeof(data.Bind) == "EnumItem" and data.Bind.Name) or nil }
            end,
            Load = function(Flag, data)
                if xEzUI.Options[Flag] and data.bind then xEzUI.Options[Flag]:Bind(Enum.KeyCode[data.bind]) end
            end
        },
        ["Dropdown"] = {
            Save = function(Flag, data) return { type = "Dropdown", flag = Flag, value = data.Value } end,
            Load = function(Flag, data)
                if xEzUI.Options[Flag] and data.value then xEzUI.Options[Flag]:UpdateSelection(data.value) end
            end
        },
    }

    local function BuildFolderTree()
        if isStudio or not (isfolder and makefolder) then return "Config system unavailable." end
        local paths = { xEzUI.Folder, xEzUI.Folder .. "/settings" }
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then makefolder(str) end
        end
    end

    function xEzUI:LoadAutoLoadConfig()
        if isStudio or not (isfile and readfile) then return "Config system unavailable." end
        if isfile(xEzUI.Folder .. "/settings/autoload.txt") then
            local name = readfile(xEzUI.Folder .. "/settings/autoload.txt")
            local suc, err = xEzUI:LoadConfig(name)
            if not suc then
                WindowFunctions:Notify({ Title = "Interface", Description = "Error loading autoload config: " .. tostring(err) })
            end
        end
    end

    function xEzUI:SetFolder(Folder)
        if isStudio then return "Config system unavailable." end
        xEzUI.Folder = Folder
        BuildFolderTree()
    end

    function xEzUI:SaveConfig(Path)
        if isStudio or not writefile then return "Config system unavailable." end
        if not Path then return false, "Please select a config file." end
        local fullPath = xEzUI.Folder .. "/settings/" .. Path .. ".json"
        local data = { objects = {} }
        for flag, option in next, xEzUI.Options do
            if not ClassParser[option.Class] then continue end
            if option.IgnoreConfig then continue end
            table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
        end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then return false, "Unable to encode into JSON data" end
        writefile(fullPath, encoded)
        return true
    end

    function xEzUI:LoadConfig(Path)
        if isStudio or not (isfile and readfile) then return "Config system unavailable." end
        if not Path then return false, "Please select a config file." end
        local file = xEzUI.Folder .. "/settings/" .. Path .. ".json"
        if not isfile(file) then return false, "Invalid file" end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, "Unable to decode JSON data." end
        for _, option in next, decoded.objects do
            if ClassParser[option.type] then
                task.spawn(function() ClassParser[option.type].Load(option.flag, option) end)
            end
        end
        return true
    end

    function xEzUI:RefreshConfigList()
        if isStudio or not (isfolder and listfiles) then return "Config system unavailable." end
        local list = (isfolder(xEzUI.Folder) and isfolder(xEzUI.Folder .. "/settings")) and listfiles(xEzUI.Folder .. "/settings") or {}
        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == ".json" then
                local pos = file:find(".json", 1, true)
                local start = pos
                local char = file:sub(pos, pos)
                while char ~= "/" and char ~= "\\" and char ~= "" do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end
                if char == "/" or char == "\\" then
                    local name = file:sub(pos + 1, start - 1)
                    if name ~= "options" then table.insert(out, name) end
                end
            end
        end
        return out
    end

    macLib.Enabled = false
    local assetList = {}
    for _, assetId in pairs(assets) do table.insert(assetList, assetId) end
    ContentProvider:PreloadAsync(assetList)
    macLib.Enabled = true
    windowState = true

    --// Insert Config Section helper (Xenon-style)
    function WindowFunctions:InsertConfigSection(Tab, Side)
        local configSection = Tab:Section({ Side = Side or "Left" })

        if isStudio then
            configSection:Label({ Text = "Config system unavailable. (Environment isStudio)" })
            return
        end

        local inputPath, selectedConfig

        configSection:Input({
            Name = "Config Name",
            Placeholder = "Name",
            AcceptedCharacters = "All",
            Callback = function(input) inputPath = input end,
        })

        local configSelection = configSection:Dropdown({
            Name = "Select Config",
            Multi = false,
            Required = false,
            Options = xEzUI:RefreshConfigList(),
            Callback = function(Value) selectedConfig = Value end,
        })

        configSection:Button({
            Name = "Create Config",
            Callback = function()
                if not inputPath or string.gsub(inputPath, " ", "") == "" then
                    WindowFunctions:Notify({ Title = "Interface", Description = "Config name cannot be empty." })
                    return
                end
                local success, returned = xEzUI:SaveConfig(inputPath)
                if not success then
                    WindowFunctions:Notify({ Title = "Interface", Description = "Unable to save config, return error: " .. tostring(returned) })
                end
                WindowFunctions:Notify({ Title = "Interface", Description = string.format("Created config %q", inputPath) })
                configSelection:ClearOptions()
                configSelection:InsertOptions(xEzUI:RefreshConfigList())
            end,
        })

        configSection:Button({
            Name = "Load Config",
            Callback = function()
                local success, returned = xEzUI:LoadConfig(configSelection.Value)
                if not success then
                    WindowFunctions:Notify({ Title = "Interface", Description = "Unable to load config, return error: " .. tostring(returned) })
                    return
                end
                WindowFunctions:Notify({ Title = "Interface", Description = string.format("Loaded config %q", configSelection.Value) })
            end,
        })

        configSection:Button({
            Name = "Overwrite Config",
            Callback = function()
                local success, returned = xEzUI:SaveConfig(configSelection.Value)
                if not success then
                    WindowFunctions:Notify({ Title = "Interface", Description = "Unable to overwrite config, return error: " .. tostring(returned) })
                    return
                end
                WindowFunctions:Notify({ Title = "Interface", Description = string.format("Overwrote config %q", configSelection.Value) })
            end,
        })

        configSection:Button({
            Name = "Refresh Config List",
            Callback = function()
                configSelection:ClearOptions()
                configSelection:InsertOptions(xEzUI:RefreshConfigList())
            end,
        })

        local autoloadLabel

        configSection:Button({
            Name = "Set as autoload",
            Callback = function()
                local name = configSelection.Value
                writefile(xEzUI.Folder .. "/settings/autoload.txt", name)
                autoloadLabel:UpdateName("Autoload config: " .. name)
                WindowFunctions:Notify({ Title = "Interface", Description = string.format("Set %q as autoload", name) })
            end,
        })

        autoloadLabel = configSection:Label({ Text = "Autoload config: None" })

        if isfile(xEzUI.Folder .. "/settings/autoload.txt") then
            local name = readfile(xEzUI.Folder .. "/settings/autoload.txt")
            autoloadLabel:UpdateName("Autoload config: " .. name)
        end

        return configSection
    end

    --// Convenience Notify wrapper (Xenon-style)
    function WindowFunctions:Toast(Title, Description, Lifetime)
        return WindowFunctions:Notify({
            Title = Title,
            Description = Description,
            Lifetime = Lifetime or 3
        })
    end

    return WindowFunctions
end

--==========================================================================
-- DEMO
--==========================================================================
function xEzUI:Demo()
    local Window = xEzUI:Window({
        Title    = "xEz UI Demo",
        Subtitle = "v" .. xEzUI.Version .. " | Combined Library",
        Size     = UDim2.fromOffset(868, 650),
        DragStyle = 1,
        ShowUserInfo = true,
        Keybind  = Enum.KeyCode.RightControl,
        AcrylicBlur = true,
    })

    local globalSettings = {
        UIBlurToggle = Window:GlobalSetting({
            Name = "UI Blur",
            Default = Window:GetAcrylicBlurState(),
            Callback = function(bool)
                Window:SetAcrylicBlurState(bool)
                Window:Toast(Window.Settings.Title, (bool and "Enabled" or "Disabled") .. " UI Blur", 5)
            end,
        }),
        NotificationToggler = Window:GlobalSetting({
            Name = "Notifications",
            Default = Window:GetNotificationsState(),
            Callback = function(bool)
                Window:SetNotificationsState(bool)
                Window:Toast(Window.Settings.Title, (bool and "Enabled" or "Disabled") .. " Notifications", 5)
            end,
        }),
        ShowUserInfo = Window:GlobalSetting({
            Name = "Show User Info",
            Default = Window:GetUserInfoState(),
            Callback = function(bool)
                Window:SetUserInfoState(bool)
                Window:Toast(Window.Settings.Title, (bool and "Showing" or "Redacted") .. " User Info", 5)
            end,
        })
    }

    local TabGroup = Window:TabGroup()

    local MainTab = TabGroup:Tab({ Name = "Demo", Image = "rbxassetid://18821914323" })
    local SettingsTab = TabGroup:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })

    local MainSection = MainTab:Section({ Side = "Left" })

    MainSection:Header({ Name = "Header #1" })

    MainSection:Button({
        Name = "Button",
        Callback = function()
            Window:Dialog({
                Title = Window.Settings.Title,
                Description = "This is a demo dialog. Click confirm to proceed.",
                Buttons = {
                    { Name = "Confirm", Callback = function() print("Confirmed!") end },
                    { Name = "Cancel" }
                }
            })
        end,
    })

    MainSection:Input({
        Name = "Input",
        Placeholder = "Type here...",
        AcceptedCharacters = "All",
        Callback = function(input)
            Window:Toast(Window.Settings.Title, "Input set to: " .. input)
        end,
    }, "Input")

    MainSection:Slider({
        Name = "Slider",
        Default = 50,
        Minimum = 0,
        Maximum = 100,
        DisplayMethod = "Percent",
        Precision = 0,
        Callback = function(Value) print("Slider:", Value) end,
    }, "Slider")

    MainSection:Toggle({
        Name = "Toggle",
        Default = false,
        Callback = function(value)
            Window:Toast(Window.Settings.Title, (value and "Enabled " or "Disabled ") .. "Toggle")
        end,
    }, "Toggle")

    MainSection:Keybind({
        Name = "Keybind",
        Blacklist = false,
        Callback = function(binded)
            Window:Toast("Demo", "Pressed: " .. tostring(binded.Name), 3)
        end,
    }, "Keybind")

    MainSection:Dropdown({
        Name = "Dropdown",
        Multi = false,
        Required = true,
        Options = { "Apple", "Banana", "Orange", "Grapes", "Pineapple" },
        Default = 1,
        Callback = function(Value) print("Dropdown:", Value) end,
    }, "Dropdown")

    MainSection:Dropdown({
        Name = "Multi Dropdown",
        Search = true,
        Multi = true,
        Required = false,
        Options = { "Apple", "Banana", "Orange", "Grapes", "Pineapple" },
        Default = { "Apple", "Orange" },
        Callback = function(Value)
            local out = {}
            for k in next, Value do table.insert(out, k) end
            print("Multi:", table.concat(out, ", "))
        end,
    }, "MultiDropdown")

    MainSection:Divider()

    MainSection:Paragraph({
        Header = "Paragraph",
        Body = "Paragraph body text. Lorem ipsum odor amet, consectetuer adipiscing elit."
    })

    MainSection:Label({ Text = "Label text goes here." })

    xEzUI:SetFolder("xEzUI")
    Window:InsertConfigSection(SettingsTab, "Left")

    Window.onUnloaded(function() print("xEz UI Unloaded!") end)

    MainTab:Select()
    xEzUI:LoadAutoLoadConfig()

    return Window
end

return xEzUI