--[[
    xEz UI Library v2.5
    Author: ZenLunarDev

    API:
      local UI = loadstring(...)()
      local Win = UI:Make({ Title = "My Hub" })
      -- Aliases: UI:Window(...), UI:CreateWindow(...)
      local Tab = Win:AddTab({ Name = "Main" })
      -- Aliases: Win:Tab(...)
      local Sec = Tab:AddSection({ Name = "General", Side = "Left" })
      -- Aliases: Tab:Section(...)
      Sec:Button({ Name = "Click", Callback = function() end })

    Demo:
      UI:Demo()
]]

local xEz = {
    Version  = "2.5.0",
    Folder   = "xEzUI",
    Options  = {},
    Themes   = {},
    Theme    = "Dark",
}

--==========================================================================
-- SERVICES
--==========================================================================
local function getService(name)
    local ok, s = pcall(function()
        if cloneref then return cloneref(game:GetService(name)) end
        return game:GetService(name)
    end)
    if ok and s then return s end
    return game:GetService(name)
end

local TweenService = getService("TweenService")
local RunService   = getService("RunService")
local UserInput    = getService("UserInputService")
local HttpService  = getService("HttpService")
local Players      = getService("Players")

local LP = Players.LocalPlayer
local isStudio = RunService:IsStudio()

--==========================================================================
-- PARENT (PlayerGui only)
--==========================================================================
local function getGuiParent()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then return pg end
    local ok, pg2 = pcall(function()
        return LP:WaitForChild("PlayerGui", 10)
    end)
    if ok and pg2 then return pg2 end
    return nil
end

--==========================================================================
-- THEMES
--==========================================================================
xEz.Themes = {
    Dark = {
        Background = Color3.fromRGB(17, 17, 20), Surface = Color3.fromRGB(24, 24, 28),
        SurfaceHigh = Color3.fromRGB(32, 32, 38), Border = Color3.fromRGB(48, 48, 56),
        Text = Color3.fromRGB(240, 240, 245), TextDim = Color3.fromRGB(150, 150, 162),
        Accent = Color3.fromRGB(120, 160, 255), AccentDim = Color3.fromRGB(70, 95, 160),
        Success = Color3.fromRGB(90, 210, 140), Warning = Color3.fromRGB(250, 190, 70),
        Danger = Color3.fromRGB(245, 100, 100),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 248), Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHigh = Color3.fromRGB(240, 240, 245), Border = Color3.fromRGB(220, 220, 228),
        Text = Color3.fromRGB(25, 25, 35), TextDim = Color3.fromRGB(120, 120, 135),
        Accent = Color3.fromRGB(80, 110, 240), AccentDim = Color3.fromRGB(180, 195, 250),
        Success = Color3.fromRGB(50, 170, 100), Warning = Color3.fromRGB(230, 160, 40),
        Danger = Color3.fromRGB(220, 70, 70),
    },
    Midnight = {
        Background = Color3.fromRGB(10, 12, 22), Surface = Color3.fromRGB(16, 18, 32),
        SurfaceHigh = Color3.fromRGB(24, 28, 46), Border = Color3.fromRGB(40, 46, 70),
        Text = Color3.fromRGB(225, 230, 245), TextDim = Color3.fromRGB(130, 140, 170),
        Accent = Color3.fromRGB(140, 100, 255), AccentDim = Color3.fromRGB(80, 60, 150),
        Success = Color3.fromRGB(80, 200, 180), Warning = Color3.fromRGB(240, 180, 90),
        Danger = Color3.fromRGB(240, 90, 130),
    },
    Ocean = {
        Background = Color3.fromRGB(12, 22, 30), Surface = Color3.fromRGB(18, 32, 42),
        SurfaceHigh = Color3.fromRGB(26, 44, 58), Border = Color3.fromRGB(40, 70, 90),
        Text = Color3.fromRGB(220, 240, 245), TextDim = Color3.fromRGB(130, 170, 185),
        Accent = Color3.fromRGB(70, 200, 220), AccentDim = Color3.fromRGB(40, 110, 130),
        Success = Color3.fromRGB(90, 220, 170), Warning = Color3.fromRGB(250, 200, 90),
        Danger = Color3.fromRGB(240, 110, 120),
    },
    Sunset = {
        Background = Color3.fromRGB(28, 18, 22), Surface = Color3.fromRGB(38, 24, 28),
        SurfaceHigh = Color3.fromRGB(50, 32, 38), Border = Color3.fromRGB(80, 50, 60),
        Text = Color3.fromRGB(250, 235, 235), TextDim = Color3.fromRGB(190, 150, 160),
        Accent = Color3.fromRGB(255, 140, 90), AccentDim = Color3.fromRGB(160, 80, 50),
        Success = Color3.fromRGB(200, 220, 130), Warning = Color3.fromRGB(255, 200, 100),
        Danger = Color3.fromRGB(255, 110, 110),
    },
    Rose = {
        Background = Color3.fromRGB(24, 14, 20), Surface = Color3.fromRGB(34, 20, 28),
        SurfaceHigh = Color3.fromRGB(46, 28, 38), Border = Color3.fromRGB(74, 46, 60),
        Text = Color3.fromRGB(250, 230, 240), TextDim = Color3.fromRGB(180, 140, 160),
        Accent = Color3.fromRGB(255, 120, 180), AccentDim = Color3.fromRGB(160, 70, 120),
        Success = Color3.fromRGB(160, 220, 180), Warning = Color3.fromRGB(250, 200, 140),
        Danger = Color3.fromRGB(255, 100, 130),
    },
}

local function getTheme()
    return xEz.Themes[xEz.Theme] or xEz.Themes.Dark
end

--==========================================================================
-- HELPERS
--==========================================================================
local function mk(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end

local function corner(obj, r)
    return mk("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = obj })
end

local function stroke(obj, col, t, thick)
    return mk("UIStroke", {
        Color = col or Color3.new(1, 1, 1),
        Transparency = t or 0,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj,
    })
end

local function padding(obj, l, r, t, b)
    return mk("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        Parent = obj,
    })
end

local function tween(obj, info, goal)
    local ok, t = pcall(function()
        local tw = TweenService:Create(obj, info, goal)
        tw:Play()
        return tw
    end)
    return ok and t or nil
end

local function ripple(button, x, y, color)
    local r = mk("Frame", {
        Name = "Ripple",
        BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(x or button.AbsoluteSize.X / 2, y or button.AbsoluteSize.Y / 2),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 5,
        Parent = button,
    })
    corner(r, 999)
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    })
    task.delay(0.5, function()
        if r and r.Parent then r:Destroy() end
    end)
end

local function fmtNumber(n, precision)
    if precision then return string.format("%." .. precision .. "f", n) end
    if n == math.floor(n) then return tostring(math.floor(n)) end
    return string.format("%.2f", n)
end

--==========================================================================
-- UI OBJECT
--==========================================================================
local UI = {}

--==========================================================================
-- MAKE WINDOW
--==========================================================================
local function MakeWindow(cfg)
    cfg = cfg or {}
    local theme = getTheme()
    local win = { _tabs = {}, _settings = cfg }

    local parent = getGuiParent()
    if not parent then
        warn("[xEzUI] Cannot find GUI parent!")
        return nil
    end

    pcall(function()
        local old = parent:FindFirstChild("xEzUI")
        if old then old:Destroy() end
    end)

    local screen
    local ok, err = pcall(function()
        screen = mk("ScreenGui", {
            Name = "xEzUI",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            DisplayOrder = 999999,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = parent,
        })
    end)

    if not ok or not screen then
        warn("[xEzUI] Failed to create ScreenGui:", err)
        return nil
    end

    local notifyLayer = mk("Frame", {
        Name = "Notifications", BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = screen,
    })
    mk("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifyLayer,
    })
    padding(notifyLayer, 12, 12, 12, 12)

    local winSize = cfg.Size or UDim2.fromOffset(760, 520)
    local root = mk("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = winSize,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 1,
        Parent = screen,
    })
    corner(root, 14)
    stroke(root, theme.Border, 0.4)

    mk("Frame", {
        Name = "Accent", BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.fromScale(0, 0),
        ZIndex = 3, Parent = root,
    })

    local topbar = mk("Frame", {
        Name = "Topbar", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        ZIndex = 2, Parent = root,
    })
    padding(topbar, 16, 16, 0, 0)

    mk("TextLabel", {
        Name = "Title", BackgroundTransparency = 1,
        Text = cfg.Title or "xEz UI",
        Font = Enum.Font.GothamBold, TextSize = 15,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, -120, 0, 20),
        ZIndex = 2, Parent = topbar,
    })
    mk("TextLabel", {
        Name = "Subtitle", BackgroundTransparency = 1,
        Text = cfg.Subtitle or "v" .. xEz.Version,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, -120, 0, 14),
        ZIndex = 2, Parent = topbar,
    })

    local function winBtn(sym, x, col)
        local b = mk("TextButton", {
            Name = "WinBtn", AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, x, 0, 12), Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = col, BackgroundTransparency = 0.85,
            BorderSizePixel = 0, Text = sym,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = theme.Text, AutoButtonColor = false,
            ZIndex = 3, Parent = topbar,
        })
        corner(b, 7)
        b.MouseEnter:Connect(function()
            tween(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 })
        end)
        b.MouseLeave:Connect(function()
            tween(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 })
        end)
        return b
    end

    local minBtn = winBtn("—", -68, theme.SurfaceHigh)
    local themeBtn = winBtn("◐", -38, theme.SurfaceHigh)
    local closeBtn = winBtn("×", -8, theme.Danger)

    local sidebar = mk("Frame", {
        Name = "Sidebar", BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0, Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(0, 180, 1, -54),
        ZIndex = 2, Parent = root,
    })
    mk("Frame", {
        Name = "Border", BackgroundColor3 = theme.Border,
        BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.fromScale(1, 0), Parent = sidebar,
    })

    local profile = mk("Frame", {
        Name = "Profile", BackgroundColor3 = theme.SurfaceHigh,
        BorderSizePixel = 0, Size = UDim2.new(1, -16, 0, 60),
        Position = UDim2.fromOffset(8, 8), Parent = sidebar,
    })
    corner(profile, 10)
    stroke(profile, theme.Border, 0.5)

    local avatar = mk("ImageLabel", {
        Name = "Avatar", BackgroundColor3 = theme.Background,
        BorderSizePixel = 0, Size = UDim2.fromOffset(44, 44),
        Position = UDim2.fromOffset(8, 8), Parent = profile,
    })
    corner(avatar, 22)

    task.spawn(function()
        local ok2, img = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok2 and img then
            pcall(function() avatar.Image = img end)
        end
    end)

    mk("TextLabel", {
        BackgroundTransparency = 1, Text = LP.DisplayName,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(60, 12), Size = UDim2.new(1, -68, 0, 16),
        Parent = profile,
    })
    mk("TextLabel", {
        BackgroundTransparency = 1, Text = "@" .. LP.Name,
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(60, 32), Size = UDim2.new(1, -68, 0, 14),
        Parent = profile,
    })

    local tabScroll = mk("ScrollingFrame", {
        Name = "Tabs", BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = theme.Border,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Position = UDim2.fromOffset(8, 76),
        Size = UDim2.new(1, -16, 1, -84), Parent = sidebar,
    })
    mk("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabScroll,
    })

    local content = mk("Frame", {
        Name = "Content", BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 54),
        Size = UDim2.new(1, -180, 1, -54),
        ClipsDescendants = true,
        ZIndex = 1, Parent = root,
    })

    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, root.Position
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    root.Size = UDim2.fromOffset(winSize.X.Offset * 0.85, winSize.Y.Offset * 0.85)
    tween(root, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = winSize })

    --==========================================================================
    -- WINDOW API
    --==========================================================================
    win.Root = root
    win.Screen = screen

    local function AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local btn = mk("TextButton", {
            Name = "Tab", BackgroundColor3 = theme.Background,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 36), Parent = tabScroll,
        })
        corner(btn, 8)
        local accentLine = mk("Frame", {
            Name = "Accent", BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0, Size = UDim2.new(0, 2, 0.5, 0),
            Position = UDim2.new(0, 0, 0.25, 0), BackgroundTransparency = 1,
            Parent = btn,
        })
        corner(accentLine, 2)
        local iconLbl = mk("TextLabel", {
            BackgroundTransparency = 1, Text = tabCfg.Icon or "",
            Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = theme.TextDim,
            Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(18, 36),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })
        local label = mk("TextLabel", {
            BackgroundTransparency = 1, Text = tabCfg.Name or "Tab",
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.TextDim,
            Position = UDim2.fromOffset(tabCfg.Icon and 36 or 16, 0),
            Size = UDim2.new(1, -50, 0, 36),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })

        local page = mk("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Border,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 1), Visible = false, Parent = content,
        })
        padding(page, 16, 16, 14, 16)
        mk("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })

        local tab = { _btn = btn, _page = page, _window = win, _theme = theme }

        local function activate()
            for _, t in ipairs(win._tabs) do
                t._page.Visible = false
                tween(t._btn, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                local a = t._btn:FindFirstChild("Accent")
                if a then tween(a, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end
            end
            page.Visible = true
            tween(btn, TweenInfo.new(0.2), { BackgroundTransparency = 0 })
            tween(accentLine, TweenInfo.new(0.2), { BackgroundTransparency = 0 })
            tween(label, TweenInfo.new(0.2), { TextColor3 = theme.Text })
            tween(iconLbl, TweenInfo.new(0.2), { TextColor3 = theme.Accent })
        end

        btn.MouseButton1Click:Connect(activate)
        btn.MouseEnter:Connect(function()
            if page.Visible then return end
            tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 })
        end)
        btn.MouseLeave:Connect(function()
            if page.Visible then return end
            tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
        end)

        table.insert(win._tabs, tab)
        if #win._tabs == 1 then activate() end

        --==== SECTION ====
        local function AddSection(secCfg)
            secCfg = secCfg or {}
            local isRight = secCfg.Side == "Right" or secCfg.Side == "right"
            local secHolder = mk("Frame", {
                Name = "SectionHolder", BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Position = isRight and UDim2.new(0.5, 6, 0, 0) or UDim2.fromOffset(0, 0),
                Parent = page,
            })
            mk("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = secHolder,
            })

            local sec = { _holder = secHolder, _theme = theme }

            local card = mk("Frame", {
                Name = "Section", BackgroundColor3 = theme.Surface,
                BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Parent = secHolder,
            })
            corner(card, 10)
            stroke(card, theme.Border, 0.5)
            padding(card, 14, 14, 12, 12)
            mk("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = card,
            })

            if secCfg.Name then
                local secName = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = secCfg.Name,
                    Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 16), Parent = card,
                })
                secName.LayoutOrder = -9999
            end

            --==== BUTTON ====
            function sec:Button(cfg)
                cfg = cfg or {}
                local b = mk("TextButton", {
                    Name = "Button", BackgroundColor3 = theme.SurfaceHigh,
                    BorderSizePixel = 0, AutoButtonColor = false,
                    Text = "", Size = UDim2.new(1, 0, 0, 36),
                    Parent = card, ClipsDescendants = true,
                })
                corner(b, 8)
                local bStroke = stroke(b, theme.Border, 0.6)
                local bAccent = mk("Frame", {
                    Name = "Accent", BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0, Size = UDim2.new(0, 2, 0, 0),
                    Position = UDim2.fromScale(0, 0.5), AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1, Parent = b,
                })
                corner(bAccent, 2)
                local bText = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Button",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(12, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
                })
                local bIcon = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = "›",
                    Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = theme.TextDim,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = b,
                })

                b.MouseEnter:Connect(function()
                    tween(b, TweenInfo.new(0.15), { BackgroundColor3 = theme.Surface })
                    tween(bStroke, TweenInfo.new(0.15), { Transparency = 0.2, Color = theme.Accent })
                    tween(bAccent, TweenInfo.new(0.2), { Size = UDim2.new(0, 2, 0.6, 0), BackgroundTransparency = 0 })
                    tween(bIcon, TweenInfo.new(0.15), { TextColor3 = theme.Accent, Position = UDim2.new(1, -6, 0.5, 0) })
                end)
                b.MouseLeave:Connect(function()
                    tween(b, TweenInfo.new(0.15), { BackgroundColor3 = theme.SurfaceHigh })
                    tween(bStroke, TweenInfo.new(0.15), { Transparency = 0.6, Color = theme.Border })
                    tween(bAccent, TweenInfo.new(0.2), { Size = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1 })
                    tween(bIcon, TweenInfo.new(0.15), { TextColor3 = theme.TextDim, Position = UDim2.new(1, -10, 0.5, 0) })
                end)
                b.MouseButton1Down:Connect(function(x, y)
                    ripple(b, x - b.AbsolutePosition.X, y - b.AbsolutePosition.Y, theme.Accent)
                end)
                b.MouseButton1Click:Connect(function()
                    if cfg.Callback then task.spawn(cfg.Callback, b) end
                end)

                local api = {}
                function api:SetText(t) bText.Text = t end
                function api:SetVisible(v) b.Visible = v end
                function api:Destroy() b:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== TOGGLE ====
            function sec:Toggle(cfg)
                cfg = cfg or {}
                local state = cfg.Default == true
                local row = mk("Frame", {
                    Name = "Toggle", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34), Parent = card,
                })
                local label = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Toggle",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -60, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
                })
                if cfg.Description then
                    mk("TextLabel", {
                        BackgroundTransparency = 1, Text = cfg.Description,
                        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = theme.TextDim,
                        Size = UDim2.new(1, -60, 0, 14), Position = UDim2.fromOffset(0, 18),
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                    })
                    label.Size = UDim2.new(1, -60, 0, 16)
                end

                local track = mk("Frame", {
                    Name = "Track", BackgroundColor3 = state and theme.Accent or theme.SurfaceHigh,
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 22),
                    Parent = row,
                })
                corner(track, 11)
                local trackStroke = stroke(track, theme.Border, 0.5)
                local knob = mk("Frame", {
                    Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = track,
                })
                corner(knob, 8)

                local function set(v, run)
                    state = not not v
                    tween(track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = state and theme.Accent or theme.SurfaceHigh
                    })
                    tween(trackStroke, TweenInfo.new(0.2), { Transparency = state and 0.3 or 0.5 })
                    tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
                    })
                    if run and cfg.Callback then task.spawn(cfg.Callback, state) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        set(not state, true)
                    end
                end)

                local api = { Value = state }
                function api:Set(v) set(v, true) end
                function api:Get() return state end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                if cfg.Callback and cfg.RunOnStart ~= false then task.spawn(cfg.Callback, state) end
                return api
            end

            --==== SLIDER ====
            function sec:Slider(cfg)
                cfg = cfg or {}
                local minV = cfg.Min or 0
                local maxV = cfg.Max or 100
                local cur = cfg.Default or minV
                local step = cfg.Step or 1
                local precision = cfg.Precision

                local row = mk("Frame", {
                    Name = "Slider", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Slider",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -80, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local valLabel = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = fmtNumber(cur, precision),
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Accent,
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(80, 18),
                    TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
                })

                local track = mk("Frame", {
                    Name = "Track", BackgroundColor3 = theme.SurfaceHigh,
                    BorderSizePixel = 0, Position = UDim2.fromOffset(0, 28),
                    Size = UDim2.new(1, 0, 0, 6), Parent = row,
                })
                corner(track, 3)
                local fill = mk("Frame", {
                    Name = "Fill", BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((cur - minV) / (maxV - minV), 0, 1, 0),
                    Parent = track,
                })
                corner(fill, 3)
                local knob = mk("Frame", {
                    Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((cur - minV) / (maxV - minV), 0, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14), Parent = track,
                })
                corner(knob, 7)
                stroke(knob, theme.Accent, 0)

                local dragging = false
                local function set(v, run)
                    cur = math.clamp(v, minV, maxV)
                    if step and step > 0 then
                        cur = math.floor(cur / step + 0.5) * step
                    end
                    local alpha = (cur - minV) / (maxV - minV)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                    valLabel.Text = fmtNumber(cur, precision)
                    if run and cfg.Callback then task.spawn(cfg.Callback, cur) end
                end

                local function fromX(x)
                    local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
                    set(minV + alpha * (maxV - minV), true)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        fromX(input.Position.X)
                    end
                end)
                UserInput.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        fromX(input.Position.X)
                    end
                end)
                UserInput.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if cfg.OnRelease then task.spawn(cfg.OnRelease, cur) end
                    end
                end)

                local api = { Value = cur }
                function api:Set(v) set(v, true) end
                function api:Get() return cur end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                if cfg.Callback and cfg.RunOnStart ~= false then task.spawn(cfg.Callback, cur) end
                return api
            end

            --==== INPUT ====
            function sec:Input(cfg)
                cfg = cfg or {}
                local row = mk("Frame", {
                    Name = "Input", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Input",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, 0, 0, 16),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local box = mk("TextBox", {
                    Name = "Box", BackgroundColor3 = theme.SurfaceHigh,
                    BorderSizePixel = 0, Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Type...",
                    Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextDim, ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 24),
                    Parent = row,
                })
                corner(box, 6)
                local boxStroke = stroke(box, theme.Border, 0.5)
                padding(box, 8, 8, 0, 0)

                box.Focused:Connect(function()
                    tween(boxStroke, TweenInfo.new(0.15), { Color = theme.Accent, Transparency = 0.2 })
                end)
                box.FocusLost:Connect(function()
                    tween(boxStroke, TweenInfo.new(0.15), { Color = theme.Border, Transparency = 0.5 })
                    if cfg.Callback then task.spawn(cfg.Callback, box.Text) end
                end)
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if cfg.OnChanged then task.spawn(cfg.OnChanged, box.Text) end
                end)

                local api = { Value = box.Text }
                function api:Set(v) box.Text = tostring(v) end
                function api:Get() return box.Text end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== KEYBIND ====
            function sec:Keybind(cfg)
                cfg = cfg or {}
                local row = mk("Frame", {
                    Name = "Keybind", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Keybind",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -100, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local bindBox = mk("TextButton", {
                    Name = "Bind", BackgroundColor3 = theme.SurfaceHigh,
                    BorderSizePixel = 0, Text = cfg.Default and cfg.Default.Name or "None",
                    Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = theme.TextDim,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(90, 24), AutoButtonColor = false,
                    Parent = row,
                })
                corner(bindBox, 6)
                stroke(bindBox, theme.Border, 0.5)

                local current = cfg.Default
                local listening = false

                local function setKey(k, run)
                    current = k
                    bindBox.Text = k and (k.Name or tostring(k)) or "None"
                    if run and cfg.Callback then task.spawn(cfg.Callback, k) end
                end

                local inputConn
                bindBox.MouseButton1Click:Connect(function()
                    if listening then
                        listening = false
                        bindBox.Text = current and current.Name or "None"
                        if inputConn then inputConn:Disconnect() end
                        return
                    end
                    listening = true
                    bindBox.Text = "..."
                    tween(bindBox, TweenInfo.new(0.15), { TextColor3 = theme.Accent })

                    inputConn = UserInput.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(input.KeyCode, true)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            setKey(input.UserInputType, true)
                        end
                        listening = false
                        bindBox.Text = current and (current.Name or tostring(current)) or "None"
                        tween(bindBox, TweenInfo.new(0.15), { TextColor3 = theme.TextDim })
                        if inputConn then inputConn:Disconnect() end
                    end)
                end)

                local keyConn = UserInput.InputBegan:Connect(function(input, gpe)
                    if gpe or listening then return end
                    if input.KeyCode == current or input.UserInputType == current then
                        if cfg.Callback then task.spawn(cfg.Callback, current) end
                    end
                end)

                local api = { Value = current }
                function api:Set(k) setKey(k, true) end
                function api:Get() return current end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() keyConn:Disconnect(); row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== DROPDOWN ====
            function sec:Dropdown(cfg)
                cfg = cfg or {}
                local multi = cfg.Multi == true
                local options = cfg.Options or {}
                local selected = {}
                if multi then
                    if type(cfg.Default) == "table" then
                        for _, v in ipairs(cfg.Default) do selected[v] = true end
                    end
                else
                    selected[cfg.Default or options[1]] = true
                end

                local row = mk("Frame", {
                    Name = "Dropdown", BackgroundColor3 = theme.SurfaceHigh,
                    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 34),
                    ClipsDescendants = true, Parent = card,
                })
                corner(row, 8)
                stroke(row, theme.Border, 0.5)

                local header = mk("TextButton", {
                    Name = "Header", BackgroundTransparency = 1, Text = "",
                    Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false,
                    Parent = row,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Dropdown",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(12, 0),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
                })
                local valueLabel = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = "",
                    Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = theme.Accent,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -28, 0.5, 0),
                    Size = UDim2.fromOffset(80, 14),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
                })
                local arrow = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = "▾",
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.TextDim,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12), Parent = header,
                })

                local listHolder = mk("Frame", {
                    Name = "List", BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
                })
                padding(listHolder, 6, 6, 0, 6)
                mk("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = listHolder,
                })

                local function updateValueLabel()
                    local names = {}
                    for k in pairs(selected) do table.insert(names, k) end
                    if #names == 0 then valueLabel.Text = ""
                    elseif #names <= 2 then valueLabel.Text = table.concat(names, ", ")
                    else valueLabel.Text = names[1] .. " +" .. (#names - 1) end
                end
                updateValueLabel()

                local open = false
                local optionButtons = {}

                local function buildOptions()
                    for _, b in ipairs(optionButtons) do b:Destroy() end
                    optionButtons = {}
                    for _, opt in ipairs(options) do
                        local ob = mk("TextButton", {
                            Name = "Option", BackgroundColor3 = theme.Background,
                            BackgroundTransparency = 0.5, BorderSizePixel = 0,
                            Text = "", AutoButtonColor = false,
                            Size = UDim2.new(1, 0, 0, 26), Parent = listHolder,
                        })
                        corner(ob, 6)
                        local check = mk("Frame", {
                            Name = "Check", BackgroundColor3 = selected[opt] and theme.Accent or theme.Border,
                            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.fromOffset(8, 13), Size = UDim2.fromOffset(12, 12),
                            Parent = ob,
                        })
                        corner(check, 6)
                        mk("TextLabel", {
                            BackgroundTransparency = 1, Text = tostring(opt),
                            Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.Text,
                            Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(26, 0),
                            TextXAlignment = Enum.TextXAlignment.Left, Parent = ob,
                        })

                        ob.MouseEnter:Connect(function()
                            tween(ob, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 })
                        end)
                        ob.MouseLeave:Connect(function()
                            tween(ob, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 })
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then
                                selected[opt] = (not selected[opt]) or nil
                                check.BackgroundColor3 = selected[opt] and theme.Accent or theme.Border
                                updateValueLabel()
                                if cfg.Callback then
                                    local out = {}
                                    for k in pairs(selected) do table.insert(out, k) end
                                    task.spawn(cfg.Callback, out)
                                end
                            else
                                for k in pairs(selected) do selected[k] = nil end
                                selected[opt] = true
                                for _, b in ipairs(optionButtons) do
                                    local c = b:FindFirstChild("Check")
                                    if c then c.BackgroundColor3 = theme.Border end
                                end
                                check.BackgroundColor3 = theme.Accent
                                updateValueLabel()
                                if cfg.Callback then task.spawn(cfg.Callback, opt) end
                                open = false
                                tween(row, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                    Size = UDim2.new(1, 0, 0, 34)
                                })
                                tween(arrow, TweenInfo.new(0.2), { Rotation = 0 })
                            end
                        end)

                        table.insert(optionButtons, ob)
                    end
                end

                local function toggle()
                    open = not open
                    if open then
                        buildOptions()
                        local totalH = 34 + 6 + #options * 28 + 6
                        tween(row, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, totalH)
                        })
                        tween(arrow, TweenInfo.new(0.2), { Rotation = 180 })
                    else
                        tween(row, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, 34)
                        })
                        tween(arrow, TweenInfo.new(0.2), { Rotation = 0 })
                    end
                end

                header.MouseButton1Click:Connect(toggle)

                local api = { Value = selected }
                function api:Set(v)
                    for k in pairs(selected) do selected[k] = nil end
                    if type(v) == "table" then
                        for _, x in ipairs(v) do selected[x] = true end
                    elseif v then
                        selected[v] = true
                    end
                    updateValueLabel()
                    if cfg.Callback then
                        if multi then
                            local out = {}
                            for k in pairs(selected) do table.insert(out, k) end
                            task.spawn(cfg.Callback, out)
                        else
                            task.spawn(cfg.Callback, v)
                        end
                    end
                end
                function api:Get()
                    if multi then
                        local out = {}
                        for k in pairs(selected) do table.insert(out, k) end
                        return out
                    end
                    for k in pairs(selected) do return k end
                end
                function api:SetOptions(newOptions)
                    options = newOptions
                    if open then buildOptions() end
                end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== COLORPICKER ====
            function sec:Colorpicker(cfg)
                cfg = cfg or {}
                local current = cfg.Default or Color3.fromRGB(120, 160, 255)
                local row = mk("Frame", {
                    Name = "Colorpicker", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Color",
                    Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, -50, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
                })
                local swatch = mk("TextButton", {
                    Name = "Swatch", BackgroundColor3 = current,
                    BorderSizePixel = 0, Text = "",
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(40, 22), AutoButtonColor = false,
                    Parent = row,
                })
                corner(swatch, 6)
                stroke(swatch, theme.Border, 0.3)

                local popup
                swatch.MouseButton1Click:Connect(function()
                    if popup and popup.Parent then popup:Destroy(); popup = nil; return end
                    popup = mk("Frame", {
                        BackgroundColor3 = theme.Surface, BorderSizePixel = 0,
                        Size = UDim2.fromOffset(220, 200),
                        Position = UDim2.new(0, 0, 1, 8),
                        Parent = row, ZIndex = 20,
                    })
                    corner(popup, 8)
                    stroke(popup, theme.Border, 0.3)
                    padding(popup, 10, 10, 10, 10)

                    local R = math.floor(current.R * 255)
                    local G = math.floor(current.G * 255)
                    local B = math.floor(current.B * 255)

                    local function mkSlider(name, val, cb)
                        local holder = mk("Frame", {
                            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
                            Parent = popup,
                        })
                        mk("TextLabel", {
                            BackgroundTransparency = 1, Text = name,
                            Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = theme.TextDim,
                            Size = UDim2.fromOffset(20, 30),
                            TextXAlignment = Enum.TextXAlignment.Left, Parent = holder,
                        })
                        local t = mk("Frame", {
                            BackgroundColor3 = theme.SurfaceHigh, BorderSizePixel = 0,
                            Position = UDim2.fromOffset(24, 12), Size = UDim2.new(1, -80, 0, 6),
                            Parent = holder,
                        })
                        corner(t, 3)
                        local f = mk("Frame", {
                            BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
                            Size = UDim2.new(val / 255, 0, 1, 0), Parent = t,
                        })
                        corner(f, 3)
                        local vL = mk("TextLabel", {
                            BackgroundTransparency = 1, Text = tostring(val),
                            Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = theme.Text,
                            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                            Size = UDim2.fromOffset(40, 14),
                            TextXAlignment = Enum.TextXAlignment.Right, Parent = holder,
                        })
                        local drag = false
                        local function setFromX(x)
                            local a = math.clamp((x - t.AbsolutePosition.X) / math.max(1, t.AbsoluteSize.X), 0, 1)
                            local v = math.floor(a * 255)
                            f.Size = UDim2.new(a, 0, 1, 0)
                            vL.Text = tostring(v)
                            cb(v)
                        end
                        t.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                                drag = true; setFromX(i.Position.X)
                            end
                        end)
                        UserInput.InputChanged:Connect(function(i)
                            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                                setFromX(i.Position.X)
                            end
                        end)
                        UserInput.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                                drag = false
                            end
                        end)
                    end

                    local function apply()
                        current = Color3.fromRGB(R, G, B)
                        swatch.BackgroundColor3 = current
                        if cfg.Callback then task.spawn(cfg.Callback, current) end
                    end

                    mkSlider("R", R, function(v) R = v; apply() end)
                    mkSlider("G", G, function(v) G = v; apply() end)
                    mkSlider("B", B, function(v) B = v; apply() end)
                end)

                local api = { Value = current }
                function api:Set(c)
                    current = c
                    swatch.BackgroundColor3 = c
                    if cfg.Callback then task.spawn(cfg.Callback, c) end
                end
                function api:Get() return current end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== PARAGRAPH ====
            function sec:Paragraph(cfg)
                cfg = cfg or {}
                local holder = mk("Frame", {
                    BackgroundColor3 = theme.SurfaceHigh, BackgroundTransparency = 0.4,
                    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
                })
                corner(holder, 8)
                padding(holder, 12, 12, 10, 10)
                local hLbl = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Header or "Header",
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text,
                    Size = UDim2.new(1, 0, 0, 16),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = holder,
                })
                local body = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Body or "",
                    Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.TextDim,
                    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = holder,
                })

                local api = {}
                function api:SetHeader(t) hLbl.Text = t end
                function api:SetBody(t) body.Text = t end
                function api:SetVisible(v) holder.Visible = v end
                function api:Destroy() holder:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== HEADER ====
            function sec:Header(cfg)
                cfg = cfg or {}
                local h = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Header",
                    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 20), Parent = card,
                })
                local api = {}
                function api:Set(t) h.Text = t end
                function api:Destroy() h:Destroy() end
                return api
            end

            --==== LABEL ====
            function sec:Label(cfg)
                cfg = cfg or {}
                local l = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Text or cfg.Name or "",
                    Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.TextDim,
                    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
                })
                local api = {}
                function api:Set(t) l.Text = t end
                function api:Destroy() l:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==== DIVIDER ====
            function sec:Divider()
                local d = mk("Frame", {
                    BackgroundColor3 = theme.Border, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.5,
                    Parent = card,
                })
                return { Destroy = function() d:Destroy() end }
            end

            --==== SPACE ====
            function sec:Space(h)
                local s = mk("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h or 4),
                    Parent = card,
                })
                return { Destroy = function() s:Destroy() end }
            end

            return sec
        end

        tab.AddSection = AddSection
        tab.Section    = AddSection  -- alias

        return tab
    end

    win.AddTab = AddTab
    win.Tab    = AddTab  -- alias

    --==========================================================================
    -- WINDOW CONTROLS
    --==========================================================================
    local minimized = false
    local cachedSize = winSize

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local target = minimized and UDim2.fromOffset(cachedSize.X.Offset, 54) or cachedSize
        tween(root, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = target })
    end)

    themeBtn.MouseButton1Click:Connect(function()
        local keys = {}
        for k in pairs(xEz.Themes) do table.insert(keys, k) end
        table.sort(keys)
        local idx = table.find(keys, xEz.Theme) or 1
        idx = (idx % #keys) + 1
        xEz.Theme = keys[idx]
        win:Notify({ Title = "Theme", Description = "Changed to " .. xEz.Theme .. " (reload to apply)", Lifetime = 2 })
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(root, TweenInfo.new(0.2), { Size = UDim2.fromOffset(0, 0) })
        task.wait(0.2)
        screen:Destroy()
    end)

    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl
    UserInput.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            root.Visible = not root.Visible
        end
    end)

    --==========================================================================
    -- NOTIFY
    --==========================================================================
    function win:Notify(ncfg)
        ncfg = ncfg or {}
        local n = mk("Frame", {
            Name = "Notify", BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0, Size = UDim2.fromOffset(280, 0),
            AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true,
            Parent = notifyLayer,
        })
        corner(n, 10)
        stroke(n, theme.Border, 0.3)
        mk("Frame", {
            Name = "Accent", BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0),
            Parent = n,
        })
        padding(n, 14, 14, 12, 12)
        mk("TextLabel", {
            BackgroundTransparency = 1, Text = ncfg.Title or "Notice",
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 16), Parent = n,
        })
        mk("TextLabel", {
            BackgroundTransparency = 1, Text = ncfg.Description or "",
            Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.TextDim,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = n,
        })

        n.Position = UDim2.new(1, 300, 1, -#notifyLayer:GetChildren() * 60 - 60)
        tween(n, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, 0, 1, -#notifyLayer:GetChildren() * 60 - 60)
        })

        task.delay(ncfg.Lifetime or 3, function()
            if not n or not n.Parent then return end
            tween(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 320, 1, n.Position.Y.Offset),
                BackgroundTransparency = 1,
            })
            task.wait(0.3)
            if n then n:Destroy() end
        end)

        return { Dismiss = function() if n then n:Destroy() end end }
    end

    win._window = win
    UI._window = win
    return win
end

--==========================================================================
-- PUBLIC METHOD (uses dot, not colon - safe for all call styles)
--==========================================================================
UI.Make         = MakeWindow
UI.Window       = MakeWindow
UI.CreateWindow = MakeWindow
UI.NewWindow    = MakeWindow

--==========================================================================
-- CONFIG
--==========================================================================
xEz.SaveConfig = function(self, name)
    if isStudio or not writefile then return false, "No filesystem" end
    if not isfolder(xEz.Folder) then makefolder(xEz.Folder) end
    local data = {}
    for flag, opt in pairs(xEz.Options) do
        local ok, val = pcall(function()
            if opt.Get then return opt:Get() end
            return opt.Value
        end)
        if ok then data[flag] = val end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false, "Encode failed" end
    writefile(xEz.Folder .. "/" .. name .. ".json", encoded)
    return true
end

xEz.LoadConfig = function(self, name)
    if isStudio or not readfile then return false, "No filesystem" end
    local path = xEz.Folder .. "/" .. name .. ".json"
    if not isfile(path) then return false, "Not found" end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok then return false, "Decode failed" end
    for flag, val in pairs(decoded) do
        local opt = xEz.Options[flag]
        if opt and opt.Set then pcall(function() opt:Set(val) end) end
    end
    return true
end

xEz.ListConfigs = function(self)
    if isStudio or not listfiles then return {} end
    if not isfolder(xEz.Folder) then return {} end
    local out = {}
    for _, f in ipairs(listfiles(xEz.Folder)) do
        if f:sub(-5) == ".json" then
            local n = f:match("([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
    end
    return out
end

--==========================================================================
-- DEMO
--==========================================================================
UI.Demo = function(self)
    local Win = MakeWindow({
        Title = "xEz UI",
        Subtitle = "v" .. xEz.Version .. " • Minimal",
        Size = UDim2.fromOffset(760, 520),
    })
    if not Win then return nil end

    local MainTab   = Win:AddTab({ Name = "Main", Icon = "◇" })
    local VisualTab = Win:AddTab({ Name = "Visual", Icon = "◈" })
    local ConfigTab = Win:AddTab({ Name = "Config", Icon = "◆" })

    local gen = MainTab:AddSection({ Name = "GENERAL", Side = "Left" })
    gen:Button({ Name = "Simple Button", Callback = function()
        Win:Notify({ Title = "Clicked", Description = "Button pressed!", Lifetime = 2 })
    end })
    gen:Toggle({ Name = "Feature Toggle", Default = false, Callback = function(v)
        Win:Notify({ Title = "Toggle", Description = tostring(v), Lifetime = 2 })
    end, Flag = "demoToggle" })
    gen:Slider({ Name = "Speed", Min = 0, Max = 100, Default = 50, Flag = "demoSlider" })
    gen:Input({ Name = "Username", Placeholder = "Type here...", Flag = "demoInput" })

    local misc = MainTab:AddSection({ Name = "MISC", Side = "Right" })
    misc:Keybind({ Name = "Toggle Key", Default = Enum.KeyCode.T, Flag = "demoKey" })
    misc:Dropdown({ Name = "Mode", Options = { "Normal", "Fast", "Ultra" }, Default = "Normal", Flag = "demoMode" })
    misc:Dropdown({ Name = "Features", Multi = true, Options = { "A", "B", "C", "D" }, Default = { "A", "C" }, Flag = "demoMulti" })
    misc:Colorpicker({ Name = "Accent Color", Default = Color3.fromRGB(120, 160, 255), Flag = "demoColor" })

    local anim = VisualTab:AddSection({ Name = "ANIMATION", Side = "Left" })
    anim:Button({ Name = "Show Notification", Callback = function()
        Win:Notify({ Title = "Hello!", Description = "Animated notification.", Lifetime = 3 })
    end })
    anim:Paragraph({
        Header = "About",
        Body = "Minimal flat design with accent lines, ripples, and smooth tweens.",
    })

    local th = VisualTab:AddSection({ Name = "THEME", Side = "Right" })
    for _, name in ipairs({ "Dark", "Light", "Midnight", "Ocean", "Sunset", "Rose" }) do
        th:Button({ Name = "Theme: " .. name, Callback = function()
            xEz.Theme = name
            Win:Notify({ Title = "Theme", Description = name .. " applied on next reload.", Lifetime = 2 })
        end })
    end

    local cfgSec = ConfigTab:AddSection({ Name = "CONFIG SYSTEM", Side = "Left" })
    local cfgName = cfgSec:Input({ Name = "Config Name", Placeholder = "myconfig" })
    cfgSec:Button({ Name = "Save", Callback = function()
        local ok, err = xEz:SaveConfig(cfgName:Get())
        Win:Notify({ Title = "Config", Description = ok and "Saved!" or tostring(err), Lifetime = 2 })
    end })
    cfgSec:Button({ Name = "Load", Callback = function()
        local ok, err = xEz:LoadConfig(cfgName:Get())
        Win:Notify({ Title = "Config", Description = ok and "Loaded!" or tostring(err), Lifetime = 2 })
    end })

    return Win
end

return UI