--[[
    xEz UI Library v3.0
    Redesigned from scratch
    Author: ZenLunarDev

    Design:
      • Layout: Sidebar + Content
      • Tone: Comfortable (40px controls)
      • Theme: Dark Gray (VSCode-like) + derived colors
      • 8-pt spacing grid
      • Type scale: 10/11/12/13/15/18/20
      • 220ms Quart animation standard
      • Float dropdowns (no clip)
      • Notifications: top-right + progress bar

    API:
      local UI = loadstring(...)()
      local Win = UI:Make({ Title = "My Hub", Subtitle = "v1" })
      local Tab = Win:AddTab({ Name = "Main", Icon = "◆" })
      local Sec = Tab:AddSection({ Name = "General" })
      Sec:Button({ Name = "Click", Callback = function() end })

    Demo:
      UI:Demo()
]]

local xEz = {
    Version  = "3.0.0",
    Folder   = "xEzUI",
    Options  = {},
    Themes   = {},
    Theme    = "DarkGray",
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
-- SPACING / TYPE SCALE / ANIMATION
--==========================================================================
local S = { xxs = 2, xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32 }
local T = { micro = 10, tiny = 11, small = 12, body = 13, title = 15, h1 = 18, h2 = 20 }
local ANIM = {
    fast   = 0.14,
    normal = 0.22,
    slow   = 0.32,
    ease   = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    easeIn = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
    back   = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

--==========================================================================
-- THEMES
--==========================================================================
local function lighten(c, t) return c:Lerp(Color3.new(1,1,1), t) end
local function darken(c, t) return c:Lerp(Color3.new(0,0,0), t) end

local function buildTheme(accent, opts)
    opts = opts or {}
    local isLight = opts.light == true
    return {
        Bg0 = isLight and Color3.fromRGB(248, 249, 251) or Color3.fromRGB(16, 17, 20),
        Bg1 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(21, 22, 26),
        Bg2 = isLight and Color3.fromRGB(243, 244, 246) or Color3.fromRGB(27, 28, 33),
        Bg3 = isLight and Color3.fromRGB(235, 237, 240) or Color3.fromRGB(34, 36, 42),

        Tx0 = isLight and Color3.fromRGB(20, 22, 26) or Color3.fromRGB(240, 242, 245),
        Tx1 = isLight and Color3.fromRGB(85, 90, 100) or Color3.fromRGB(160, 165, 175),
        Tx2 = isLight and Color3.fromRGB(140, 145, 155) or Color3.fromRGB(105, 110, 120),

        Line   = isLight and Color3.fromRGB(225, 227, 232) or Color3.fromRGB(38, 40, 48),
        LineHi = isLight and Color3.fromRGB(210, 213, 220) or Color3.fromRGB(48, 50, 60),

        Accent      = accent,
        AccentHover = lighten(accent, 0.15),
        AccentDim   = darken(accent, 0.35),
        AccentGlow  = lighten(accent, 0.5),

        Ok   = Color3.fromRGB(74, 192, 122),
        Warn = Color3.fromRGB(232, 178, 63),
        Err  = Color3.fromRGB(224, 85, 85),

        Stroke = isLight and 0.85 or 0.55,
    }
end

xEz.Themes = {
    DarkGray = buildTheme(Color3.fromRGB(88, 140, 240)),
    Midnight = buildTheme(Color3.fromRGB(140, 105, 250)),
    Ocean    = buildTheme(Color3.fromRGB(74, 190, 220)),
    Sunset   = buildTheme(Color3.fromRGB(255, 145, 90)),
    Rose     = buildTheme(Color3.fromRGB(240, 120, 170)),
    Emerald  = buildTheme(Color3.fromRGB(80, 200, 140)),
    Light    = buildTheme(Color3.fromRGB(70, 110, 235), { light = true }),
}

local function getTheme()
    return xEz.Themes[xEz.Theme] or xEz.Themes.DarkGray
end

--==========================================================================
-- PARENT
--==========================================================================
local function getGuiParent()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then return pg end
    local ok, pg2 = pcall(function() return LP:WaitForChild("PlayerGui", 10) end)
    if ok and pg2 then return pg2 end
    return nil
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
        Color = col, Transparency = t or 0.55, Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = obj,
    })
end

local function pad(obj, l, r, t, b)
    return mk("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        Parent = obj,
    })
end

local function tw(obj, info, goal)
    if not obj or not obj.Parent then return end
    local ok, t = pcall(function()
        local x = TweenService:Create(obj, info, goal)
        x:Play()
        return x
    end)
    return ok and t or nil
end

local function ripple(btn, x, y, color)
    local r = mk("Frame", {
        Name = "Ripple", BackgroundColor3 = color,
        BackgroundTransparency = 0.75, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(x or 0, y or 0),
        Size = UDim2.fromOffset(0, 0), ZIndex = 5, Parent = btn,
    })
    corner(r, 999)
    local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
    tw(r, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(sz, sz), BackgroundTransparency = 1,
    })
    task.delay(0.55, function() if r and r.Parent then r:Destroy() end end)
end

local function fmt(n, p)
    if p then return string.format("%." .. p .. "f", n) end
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
    local win = { _tabs = {}, _settings = cfg, _theme = theme, _popups = {} }

    local parent = getGuiParent()
    if not parent then warn("[xEzUI] No GUI parent!"); return nil end

    pcall(function()
        local old = parent:FindFirstChild("xEzUI")
        if old then old:Destroy() end
    end)

    local screen = mk("ScreenGui", {
        Name = "xEzUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 999999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })

    -- Popup layer
    local popupLayer = mk("Frame", {
        Name = "Popups", BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 500, Parent = screen,
    })

    -- Notification layer (top-right)
    local notifyLayer = mk("Frame", {
        Name = "Notifications", BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(320, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(1, 0), ZIndex = 400, Parent = screen,
    })
    mk("UIListLayout", {
        Padding = UDim.new(0, S.sm),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = notifyLayer,
    })

    -- Root window
    local winSize = cfg.Size or UDim2.fromOffset(820, 560)
    local root = mk("Frame", {
        Name = "Root", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = winSize,
        BackgroundColor3 = theme.Bg0, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 1, Parent = screen,
    })
    corner(root, 12)
    stroke(root, theme.LineHi, theme.Stroke)

    -- Titlebar
    local titlebar = mk("Frame", {
        Name = "Titlebar", BackgroundColor3 = theme.Bg1,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 3, Parent = root,
    })
    mk("Frame", {
        Name = "Divider", BackgroundColor3 = theme.Line,
        BorderSizePixel = 0, Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1), Parent = titlebar,
    })
    pad(titlebar, S.lg, S.sm, 0, 0)

    -- App icon
    local appIcon = mk("Frame", {
        Name = "AppIcon", BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0, Position = UDim2.fromOffset(S.lg, 14),
        Size = UDim2.fromOffset(20, 20), Parent = titlebar,
    })
    corner(appIcon, 6)
    mk("TextLabel", {
        BackgroundTransparency = 1, Text = "◆",
        Font = Enum.Font.GothamBold, TextSize = T.small,
        TextColor3 = Color3.new(1,1,1), Size = UDim2.fromScale(1, 1),
        Parent = appIcon,
    })

    mk("TextLabel", {
        Name = "Title", BackgroundTransparency = 1,
        Text = cfg.Title or "xEz UI",
        Font = Enum.Font.GothamBold, TextSize = T.body,
        TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(S.lg + 28, 8),
        Size = UDim2.new(1, -240, 0, 18),
        ZIndex = 3, Parent = titlebar,
    })
    mk("TextLabel", {
        Name = "Subtitle", BackgroundTransparency = 1,
        Text = cfg.Subtitle or "v" .. xEz.Version,
        Font = Enum.Font.Gotham, TextSize = T.micro,
        TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(S.lg + 28, 26),
        Size = UDim2.new(1, -240, 0, 12),
        ZIndex = 3, Parent = titlebar,
    })

    local function tbBtn(sym, x, hoverCol)
        local b = mk("TextButton", {
            Name = "TbBtn", AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(32, 32),
            BackgroundColor3 = theme.Bg2, BackgroundTransparency = 1,
            BorderSizePixel = 0, Text = sym,
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = theme.Tx1, AutoButtonColor = false,
            ZIndex = 4, Parent = titlebar,
        })
        corner(b, 6)
        b.MouseEnter:Connect(function()
            tw(b, ANIM.ease, { BackgroundTransparency = 0, TextColor3 = hoverCol or theme.Tx0 })
        end)
        b.MouseLeave:Connect(function()
            tw(b, ANIM.ease, { BackgroundTransparency = 1, TextColor3 = theme.Tx1 })
        end)
        return b
    end

    local minBtn   = tbBtn("−", -S.sm - 76, theme.Tx0)
    local themeBtn = tbBtn("◐", -S.sm - 40, theme.Accent)
    local closeBtn = tbBtn("✕", -S.sm, theme.Err)

    -- Body
    local body = mk("Frame", {
        Name = "Body", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 1, -48), Parent = root,
    })

    -- Sidebar
    local sidebar = mk("Frame", {
        Name = "Sidebar", BackgroundColor3 = theme.Bg1,
        BorderSizePixel = 0, Size = UDim2.new(0, 200, 1, 0),
        ZIndex = 2, Parent = body,
    })
    mk("Frame", {
        Name = "Divider", BackgroundColor3 = theme.Line,
        BorderSizePixel = 0, Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0), Parent = sidebar,
    })
    pad(sidebar, S.sm, S.sm, S.sm, S.sm)

    -- Profile
    local profile = mk("Frame", {
        Name = "Profile", BackgroundColor3 = theme.Bg2,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 56),
        Parent = sidebar,
    })
    corner(profile, 8)

    local avatar = mk("ImageLabel", {
        Name = "Avatar", BackgroundColor3 = theme.Bg3,
        BorderSizePixel = 0, Position = UDim2.fromOffset(S.sm, S.sm),
        Size = UDim2.fromOffset(40, 40), Parent = profile,
    })
    corner(avatar, 20)

    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then pcall(function() avatar.Image = img end) end
    end)

    mk("TextLabel", {
        Name = "DisplayName", BackgroundTransparency = 1,
        Text = LP.DisplayName, Font = Enum.Font.GothamBold, TextSize = T.small,
        TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(S.sm + 48, S.sm + 2),
        Size = UDim2.new(1, -(S.sm + 56), 0, 16), Parent = profile,
    })
    mk("TextLabel", {
        Name = "Username", BackgroundTransparency = 1,
        Text = "@" .. LP.Name, Font = Enum.Font.Gotham, TextSize = T.micro,
        TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.fromOffset(S.sm + 48, S.sm + 22),
        Size = UDim2.new(1, -(S.sm + 56), 0, 14), Parent = profile,
    })

    -- Tab list
    local tabScroll = mk("ScrollingFrame", {
        Name = "Tabs", BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = theme.Line,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Position = UDim2.fromOffset(0, 56 + S.md),
        Size = UDim2.new(1, 0, 1, -(56 + S.md)),
        Parent = sidebar,
    })
    mk("UIListLayout", {
        Padding = UDim.new(0, S.xs),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabScroll,
    })

    -- Content
    local content = mk("Frame", {
        Name = "Content", BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -200, 1, 0),
        ClipsDescendants = true, ZIndex = 1, Parent = body,
    })

    -- Drag
    local dragging, dragStart, startPos
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, root.Position
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Entrance
    root.Size = UDim2.fromOffset(winSize.X.Offset * 0.94, winSize.Y.Offset * 0.94)
    tw(root, ANIM.ease, { Size = winSize })

    --==========================================================================
    -- PUBLIC FIELDS
    --==========================================================================
    win.Root = root
    win.Screen = screen
    win.PopupLayer = popupLayer

    --==========================================================================
    -- ADD TAB
    --==========================================================================
    local function AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local btn = mk("TextButton", {
            Name = "Tab", BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 36), Parent = tabScroll,
        })
        corner(btn, 6)

        local accentBar = mk("Frame", {
            Name = "AccentBar", BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 0), Parent = btn,
        })
        corner(accentBar, 2)

        local iconLbl = mk("TextLabel", {
            Name = "TabIcon", BackgroundTransparency = 1,
            Text = tabCfg.Icon or "•",
            Font = Enum.Font.GothamBold, TextSize = T.small,
            TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Center,
            Position = UDim2.fromOffset(S.md, 0), Size = UDim2.fromOffset(16, 36),
            Parent = btn,
        })
        local label = mk("TextLabel", {
            Name = "TabLabel", BackgroundTransparency = 1,
            Text = tabCfg.Name or "Tab",
            Font = Enum.Font.GothamMedium, TextSize = T.small,
            TextColor3 = theme.Tx1, TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(S.md + 22, 0),
            Size = UDim2.new(1, -(S.md + 22), 0, 36),
            Parent = btn,
        })

        local page = mk("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 4, ScrollBarImageColor3 = theme.LineHi,
            ScrollBarImageTransparency = 0.4,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 1), Visible = false, Parent = content,
        })
        pad(page, S.lg, S.lg, S.lg, S.lg)
        mk("UIListLayout", {
            Padding = UDim.new(0, S.md),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })

        local tab = { _btn = btn, _page = page, _window = win, _theme = theme, _lastRow = nil }

        local function activate()
            for _, t in ipairs(win._tabs) do
                t._page.Visible = false
                tw(t._btn, ANIM.ease, { BackgroundTransparency = 1 })
                local ab = t._btn:FindFirstChild("AccentBar")
                if ab then tw(ab, ANIM.ease, { Size = UDim2.new(0, 3, 0, 0) }) end
                local il = t._btn:FindFirstChild("TabIcon")
                if il then tw(il, ANIM.ease, { TextColor3 = theme.Tx2 }) end
                local ll = t._btn:FindFirstChild("TabLabel")
                if ll then tw(ll, ANIM.ease, { TextColor3 = theme.Tx1 }) end
            end
            page.Visible = true
            tw(btn, ANIM.ease, { BackgroundTransparency = 0.6 })
            tw(accentBar, ANIM.ease, { Size = UDim2.new(0, 3, 0, 18) })
            tw(iconLbl, ANIM.ease, { TextColor3 = theme.Accent })
            tw(label, ANIM.ease, { TextColor3 = theme.Tx0 })
        end

        btn.MouseButton1Click:Connect(activate)
        btn.MouseEnter:Connect(function()
            if page.Visible then return end
            tw(btn, TweenInfo.new(ANIM.fast), { BackgroundTransparency = 0.85 })
        end)
        btn.MouseLeave:Connect(function()
            if page.Visible then return end
            tw(btn, TweenInfo.new(ANIM.fast), { BackgroundTransparency = 1 })
        end)

        table.insert(win._tabs, tab)
        if #win._tabs == 1 then activate() end

        --======================================================================
        -- ADD SECTION (auto-2-column)
        --======================================================================
        local function AddSection(secCfg)
            secCfg = secCfg or {}
            local side = secCfg.Side or "Left"

            local row = tab._lastRow
            local needNewRow = (not row) or (side == "Left") or (row._right ~= nil)
            if needNewRow then
                row = mk("Frame", {
                    Name = "Row", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = page,
                })
                mk("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, S.md),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = row,
                })
                row._left = nil
                row._right = nil
                tab._lastRow = row
            end

            local colWidth = UDim2.new(0.5, -(S.md / 2), 0, 0)
            local holder = mk("Frame", {
                Name = "SectionHolder", BackgroundTransparency = 1,
                Size = colWidth, AutomaticSize = Enum.AutomaticSize.Y,
                Parent = row,
            })
            if side == "Left" then row._left = holder else row._right = holder end

            local sec = { _holder = holder, _theme = theme }

            local card = mk("Frame", {
                Name = "Card", BackgroundColor3 = theme.Bg1,
                BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Parent = holder,
            })
            corner(card, 10)
            stroke(card, theme.Line, theme.Stroke)
            pad(card, S.md, S.md, S.md, S.md)
            mk("UIListLayout", {
                Padding = UDim.new(0, S.sm),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = card,
            })

            -- Section header
            if secCfg.Name then
                local hw = mk("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = -9999, Parent = card,
                })
                local line = mk("Frame", {
                    BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
                    Size = UDim2.new(0, 3, 0, 12),
                    Position = UDim2.fromOffset(0, 4), Parent = hw,
                })
                corner(line, 2)
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = string.upper(secCfg.Name),
                    Font = Enum.Font.GothamBold, TextSize = T.micro,
                    TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(S.sm, 0),
                    Size = UDim2.new(1, -S.sm, 1, 0),
                    Parent = hw,
                })
            end

            --==================================================================
            -- BUTTON
            --==================================================================
            function sec:Button(cfg)
                cfg = cfg or {}
                local b = mk("TextButton", {
                    Name = "Button", BackgroundColor3 = theme.Bg2,
                    BorderSizePixel = 0, AutoButtonColor = false,
                    Text = "", Size = UDim2.new(1, 0, 0, 40),
                    Parent = card, ClipsDescendants = true,
                })
                corner(b, 8)
                local bStroke = stroke(b, theme.Line, theme.Stroke)

                local bAccent = mk("Frame", {
                    Name = "Indicator", BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 3, 0, 0),
                    BackgroundTransparency = 1, Parent = b,
                })
                corner(bAccent, 2)

                local bText = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Button",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(S.md, 0),
                    Size = UDim2.new(1, -S.md - 20, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = b,
                })
                local bIcon = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Icon or "›",
                    Font = Enum.Font.GothamBold, TextSize = 15,
                    TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Right,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -S.sm, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = b,
                })

                b.MouseEnter:Connect(function()
                    tw(b, ANIM.ease, { BackgroundColor3 = theme.Bg3 })
                    tw(bStroke, ANIM.ease, { Color = theme.Accent, Transparency = 0.3 })
                    tw(bAccent, ANIM.ease,
                        { Size = UDim2.new(0, 3, 0, 20), BackgroundTransparency = 0 })
                    tw(bIcon, ANIM.ease,
                        { TextColor3 = theme.Accent, Position = UDim2.new(1, -S.md + 2, 0.5, 0) })
                end)
                b.MouseLeave:Connect(function()
                    tw(b, ANIM.ease, { BackgroundColor3 = theme.Bg2 })
                    tw(bStroke, ANIM.ease, { Color = theme.Line, Transparency = theme.Stroke })
                    tw(bAccent, ANIM.ease,
                        { Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1 })
                    tw(bIcon, ANIM.ease,
                        { TextColor3 = theme.Tx2, Position = UDim2.new(1, -S.sm, 0.5, 0) })
                end)
                b.MouseButton1Down:Connect(function(x, y)
                    ripple(b, x - b.AbsolutePosition.X, y - b.AbsolutePosition.Y, theme.AccentGlow)
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

            --==================================================================
            -- TOGGLE
            --==================================================================
            function sec:Toggle(cfg)
                cfg = cfg or {}
                local state = cfg.Default == true
                local row = mk("Frame", {
                    Name = "Toggle", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40), Parent = card,
                })
                local textWrap = mk("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -56, 1, 0), Parent = row,
                })
                local nameLbl = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Toggle",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 40),
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = textWrap,
                })
                if cfg.Description then
                    nameLbl.Size = UDim2.new(1, 0, 0, 18)
                    nameLbl.Position = UDim2.fromOffset(0, 0)
                    mk("TextLabel", {
                        BackgroundTransparency = 1, Text = cfg.Description,
                        Font = Enum.Font.Gotham, TextSize = T.micro,
                        TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Position = UDim2.fromOffset(0, 18),
                        Size = UDim2.new(1, 0, 0, 14), Parent = textWrap,
                    })
                end

                local track = mk("Frame", {
                    Name = "Track",
                    BackgroundColor3 = state and theme.Accent or theme.Bg3,
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(42, 22), Parent = row,
                })
                corner(track, 11)
                local tStroke = stroke(track, state and theme.Accent or theme.Line, 0.3)

                local knob = mk("Frame", {
                    Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = state and UDim2.new(1, -11, 0.5, 0)
                        or UDim2.new(0, 11, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = track,
                })
                corner(knob, 8)

                local function set(v, run)
                    state = not not v
                    tw(track, ANIM.ease, {
                        BackgroundColor3 = state and theme.Accent or theme.Bg3
                    })
                    tw(tStroke, ANIM.ease, {
                        Color = state and theme.Accent or theme.Line,
                        Transparency = 0.3
                    })
                    tw(knob, ANIM.back, {
                        Position = state and UDim2.new(1, -11, 0.5, 0)
                            or UDim2.new(0, 11, 0.5, 0)
                    })
                    if run and cfg.Callback then task.spawn(cfg.Callback, state) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        set(not state, true)
                    end
                end)

                local api = { Value = state }
                function api:Set(v) set(v, true) end
                function api:Get() return state end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy() row:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                if cfg.Callback and cfg.RunOnStart ~= false then
                    task.spawn(cfg.Callback, state)
                end
                return api
            end

            --==================================================================
            -- SLIDER
            --==================================================================
            function sec:Slider(cfg)
                cfg = cfg or {}
                local minV = cfg.Min or 0
                local maxV = cfg.Max or 100
                local cur = cfg.Default or minV
                local step = cfg.Step or 1
                local precision = cfg.Precision

                local row = mk("Frame", {
                    Name = "Slider", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Slider",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -80, 0, 18), Parent = row,
                })
                local valLabel = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = fmt(cur, precision),
                    Font = Enum.Font.GothamBold, TextSize = T.small,
                    TextColor3 = theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(80, 18), Parent = row,
                })

                local track = mk("Frame", {
                    Name = "Track", BackgroundColor3 = theme.Bg3,
                    BorderSizePixel = 0, Position = UDim2.fromOffset(0, 28),
                    Size = UDim2.new(1, 0, 0, 8), Parent = row,
                })
                corner(track, 4)

                local fill = mk("Frame", {
                    Name = "Fill", BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((cur - minV) / (maxV - minV), 0, 1, 0),
                    Parent = track,
                })
                corner(fill, 4)

                local knob = mk("Frame", {
                    Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((cur - minV) / (maxV - minV), 0, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = track,
                })
                corner(knob, 8)
                stroke(knob, theme.Accent, 0)

                local dragging = false
                local function set(v, run)
                    cur = math.clamp(v, minV, maxV)
                    if step and step > 0 then
                        cur = math.floor(cur / step + 0.5) * step
                    end
                    local alpha = (cur - minV) / (maxV - minV)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    tw(knob, ANIM.fast and TweenInfo.new(0.08), {
                        Position = UDim2.new(alpha, 0, 0.5, 0)
                    })
                    valLabel.Text = fmt(cur, precision)
                    if run and cfg.Callback then task.spawn(cfg.Callback, cur) end
                end

                local function fromX(x)
                    local alpha = math.clamp(
                        (x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X),
                        0, 1)
                    set(minV + alpha * (maxV - minV), true)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        fromX(input.Position.X)
                    end
                end)
                UserInput.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                        fromX(input.Position.X)
                    end
                end)
                UserInput.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
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
                if cfg.Callback and cfg.RunOnStart ~= false then
                    task.spawn(cfg.Callback, cur)
                end
                return api
            end

            --==================================================================
            -- INPUT
            --==================================================================
            function sec:Input(cfg)
                cfg = cfg or {}
                local row = mk("Frame", {
                    Name = "Input", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Input",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 16), Parent = row,
                })
                local box = mk("TextBox", {
                    Name = "Box", BackgroundColor3 = theme.Bg2,
                    BorderSizePixel = 0, Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Type...",
                    Font = Enum.Font.Gotham, TextSize = T.small,
                    TextColor3 = theme.Tx0, PlaceholderColor3 = theme.Tx2,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(0, 22),
                    Size = UDim2.new(1, 0, 0, 26), Parent = row,
                })
                corner(box, 6)
                local boxStroke = stroke(box, theme.Line, theme.Stroke)
                pad(box, S.sm, S.sm, 0, 0)

                box.Focused:Connect(function()
                    tw(boxStroke, ANIM.ease, { Color = theme.Accent, Transparency = 0.2 })
                end)
                box.FocusLost:Connect(function()
                    tw(boxStroke, ANIM.ease, { Color = theme.Line, Transparency = theme.Stroke })
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

            --==================================================================
            -- KEYBIND
            --==================================================================
            function sec:Keybind(cfg)
                cfg = cfg or {}
                local row = mk("Frame", {
                    Name = "Keybind", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Keybind",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -100, 1, 0), Parent = row,
                })
                local bindBox = mk("TextButton", {
                    Name = "Bind", BackgroundColor3 = theme.Bg2,
                    BorderSizePixel = 0, Text = cfg.Default and cfg.Default.Name or "None",
                    Font = Enum.Font.GothamBold, TextSize = T.micro,
                    TextColor3 = theme.Tx1, AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(90, 26), Parent = row,
                })
                corner(bindBox, 6)
                local bbStroke = stroke(bindBox, theme.Line, theme.Stroke)

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
                        tw(bbStroke, ANIM.ease, { Color = theme.Line })
                        if inputConn then inputConn:Disconnect() end
                        return
                    end
                    listening = true
                    bindBox.Text = "..."
                    tw(bindBox, ANIM.ease, { TextColor3 = theme.Accent })
                    tw(bbStroke, ANIM.ease, { Color = theme.Accent, Transparency = 0.2 })

                    inputConn = UserInput.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(input.KeyCode, true)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            setKey(input.UserInputType, true)
                        end
                        listening = false
                        bindBox.Text = current and (current.Name or tostring(current)) or "None"
                        tw(bindBox, ANIM.ease, { TextColor3 = theme.Tx1 })
                        tw(bbStroke, ANIM.ease, { Color = theme.Line })
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

            --==================================================================
            -- DROPDOWN (uses popup layer — never clipped)
            --==================================================================
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
                    Name = "Dropdown", BackgroundColor3 = theme.Bg2,
                    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36),
                    Parent = card,
                })
                corner(row, 8)
                local rStroke = stroke(row, theme.Line, theme.Stroke)

                local header = mk("TextButton", {
                    Name = "Header", BackgroundTransparency = 1, Text = "",
                    Size = UDim2.new(1, 0, 0, 36), AutoButtonColor = false,
                    Parent = row,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Dropdown",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2.fromOffset(S.md, 0),
                    Size = UDim2.new(1, -S.md - 60, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
                })
                local valueLabel = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = "",
                    Font = Enum.Font.Gotham, TextSize = T.micro,
                    TextColor3 = theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -28, 0.5, 0),
                    Size = UDim2.fromOffset(80, 14),
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
                })
                local arrow = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = "▾",
                    Font = Enum.Font.GothamBold, TextSize = 12,
                    TextColor3 = theme.Tx2, TextXAlignment = Enum.TextXAlignment.Center,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -S.sm, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14), Parent = header,
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
                local popup = nil

                local function closePopup()
                    if popup then
                        local p = popup
                        popup = nil
                        open = false
                        tw(p, TweenInfo.new(0.15, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.In), {
                            Size = UDim2.new(p.Size.X.Scale, p.Size.X.Offset,
                                0, 0),
                            BackgroundTransparency = 1,
                        })
                        task.delay(0.2, function()
                            if p and p.Parent then p:Destroy() end
                        end)
                        tw(arrow, ANIM.ease, { Rotation = 0 })
                        tw(rStroke, ANIM.ease, { Color = theme.Line, Transparency = theme.Stroke })
                    end
                end

                local function openPopup()
                    if popup then closePopup(); return end
                    open = true
                    tw(arrow, ANIM.ease, { Rotation = 180 })
                    tw(rStroke, ANIM.ease, { Color = theme.Accent, Transparency = 0.3 })

                    local pos = header.AbsolutePosition
                    local sz  = header.AbsoluteSize
                    local lineH = 32
                    local padV = 6
                    local totalH = #options * lineH + padV * 2

                    popup = mk("Frame", {
                        Name = "DropdownPopup",
                        BackgroundColor3 = theme.Bg1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(pos.X, pos.Y + sz.Y + 4),
                        Size = UDim2.fromOffset(sz.X, 0),
                        ClipsDescendants = true,
                        ZIndex = 501,
                        Parent = popupLayer,
                    })
                    corner(popup, 8)
                    stroke(popup, theme.Accent, 0.4)
                    pad(popup, padV, padV, padV, padV)
                    mk("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = popup,
                    })

                    for _, opt in ipairs(options) do
                        local ob = mk("TextButton", {
                            Name = "Option", BackgroundColor3 = theme.Bg2,
                            BackgroundTransparency = 0.5, BorderSizePixel = 0,
                            Text = "", AutoButtonColor = false,
                            Size = UDim2.new(1, 0, 0, lineH - 4),
                            Parent = popup,
                        })
                        corner(ob, 6)
                        local check = mk("Frame", {
                            Name = "Check",
                            BackgroundColor3 = selected[opt] and theme.Accent or theme.Line,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.fromOffset(S.sm, (lineH - 4) / 2),
                            Size = UDim2.fromOffset(12, 12), Parent = ob,
                        })
                        corner(check, 6)
                        mk("TextLabel", {
                            BackgroundTransparency = 1, Text = tostring(opt),
                            Font = Enum.Font.Gotham, TextSize = T.small,
                            TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                            Position = UDim2.fromOffset(S.sm + 20, 0),
                            Size = UDim2.new(1, -S.sm - 20, 1, 0),
                            Parent = ob,
                        })

                        ob.MouseEnter:Connect(function()
                            tw(ob, TweenInfo.new(ANIM.fast), { BackgroundTransparency = 0.15 })
                        end)
                        ob.MouseLeave:Connect(function()
                            tw(ob, TweenInfo.new(ANIM.fast), { BackgroundTransparency = 0.5 })
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then
                                selected[opt] = (not selected[opt]) or nil
                                check.BackgroundColor3 = selected[opt] and theme.Accent or theme.Line
                                updateValueLabel()
                                if cfg.Callback then
                                    local out = {}
                                    for k in pairs(selected) do table.insert(out, k) end
                                    task.spawn(cfg.Callback, out)
                                end
                            else
                                for k in pairs(selected) do selected[k] = nil end
                                selected[opt] = true
                                updateValueLabel()
                                if cfg.Callback then task.spawn(cfg.Callback, opt) end
                                closePopup()
                            end
                        end)
                    end

                    tw(popup, ANIM.ease, {
                        Size = UDim2.fromOffset(sz.X, totalH)
                    })
                end

                header.MouseButton1Click:Connect(openPopup)

                -- Close on click outside
                UserInput.InputBegan:Connect(function(input)
                    if not open then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1
                        and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    if not popup then return end
                    local mp = UserInput:GetMouseLocation()
                    local ap = popup.AbsolutePosition
                    local as_ = popup.AbsoluteSize
                    local insidePopup = mp.X >= ap.X and mp.X <= ap.X + as_.X
                        and mp.Y >= ap.Y and mp.Y <= ap.Y + as_.Y
                    local hp = header.AbsolutePosition
                    local hs = header.AbsoluteSize
                    local insideHeader = mp.X >= hp.X and mp.X <= hp.X + hs.X
                        and mp.Y >= hp.Y and mp.Y <= hp.Y + hs.Y
                    if not insidePopup and not insideHeader then
                        closePopup()
                    end
                end)

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
                    if open then closePopup() end
                end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy()
                    closePopup()
                    row:Destroy()
                end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==================================================================
            -- COLORPICKER
            --==================================================================
            function sec:Colorpicker(cfg)
                cfg = cfg or {}
                local current = cfg.Default or theme.Accent
                local row = mk("Frame", {
                    Name = "Colorpicker", BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36), Parent = card,
                })
                mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Color",
                    Font = Enum.Font.GothamMedium, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -50, 1, 0), Parent = row,
                })
                local swatch = mk("TextButton", {
                    Name = "Swatch", BackgroundColor3 = current,
                    BorderSizePixel = 0, Text = "", AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(48, 24), Parent = row,
                })
                corner(swatch, 6)
                stroke(swatch, theme.Line, 0.3)

                local popup
                swatch.MouseButton1Click:Connect(function()
                    if popup and popup.Parent then popup:Destroy(); popup = nil; return end

                    local pos = row.AbsolutePosition
                    local sz  = row.AbsoluteSize

                    popup = mk("Frame", {
                        BackgroundColor3 = theme.Bg1, BorderSizePixel = 0,
                        Size = UDim2.fromOffset(240, 200),
                        Position = UDim2.fromOffset(pos.X, pos.Y + sz.Y + 4),
                        ZIndex = 501, Parent = popupLayer,
                    })
                    corner(popup, 8)
                    stroke(popup, theme.Accent, 0.4)
                    pad(popup, S.md, S.md, S.md, S.md)

                    local R = math.floor(current.R * 255)
                    local G = math.floor(current.G * 255)
                    local B = math.floor(current.B * 255)

                    local function mkSlider(name, val, cb)
                        local holder = mk("Frame", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 36),
                            Parent = popup,
                        })
                        mk("TextLabel", {
                            BackgroundTransparency = 1, Text = name,
                            Font = Enum.Font.GothamBold, TextSize = T.micro,
                            TextColor3 = theme.Tx2,
                            Size = UDim2.fromOffset(20, 36),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = holder,
                        })
                        local t = mk("Frame", {
                            BackgroundColor3 = theme.Bg3, BorderSizePixel = 0,
                            Position = UDim2.fromOffset(24, 15),
                            Size = UDim2.new(1, -80, 0, 6), Parent = holder,
                        })
                        corner(t, 3)
                        local f = mk("Frame", {
                            BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
                            Size = UDim2.new(val / 255, 0, 1, 0), Parent = t,
                        })
                        corner(f, 3)
                        local vL = mk("TextLabel", {
                            BackgroundTransparency = 1, Text = tostring(val),
                            Font = Enum.Font.GothamBold, TextSize = T.micro,
                            TextColor3 = theme.Tx0,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, 0, 0.5, 0),
                            Size = UDim2.fromOffset(40, 14),
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Parent = holder,
                        })
                        local drag = false
                        local function setFromX(x)
                            local a = math.clamp(
                                (x - t.AbsolutePosition.X) / math.max(1, t.AbsoluteSize.X),
                                0, 1)
                            local v = math.floor(a * 255)
                            f.Size = UDim2.new(a, 0, 1, 0)
                            vL.Text = tostring(v)
                            cb(v)
                        end
                        t.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                                or i.UserInputType == Enum.UserInputType.Touch then
                                drag = true; setFromX(i.Position.X)
                            end
                        end)
                        UserInput.InputChanged:Connect(function(i)
                            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                                or i.UserInputType == Enum.UserInputType.Touch) then
                                setFromX(i.Position.X)
                            end
                        end)
                        UserInput.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                                or i.UserInputType == Enum.UserInputType.Touch then
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

                    UserInput.InputBegan:Connect(function(input)
                        if not popup or not popup.Parent then return end
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1
                            and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        local mp = UserInput:GetMouseLocation()
                        local ap = popup.AbsolutePosition
                        local as_ = popup.AbsoluteSize
                        local inside = mp.X >= ap.X and mp.X <= ap.X + as_.X
                            and mp.Y >= ap.Y and mp.Y <= ap.Y + as_.Y
                        local sp = swatch.AbsolutePosition
                        local ss = swatch.AbsoluteSize
                        local onSwatch = mp.X >= sp.X and mp.X <= sp.X + ss.X
                            and mp.Y >= sp.Y and mp.Y <= sp.Y + ss.Y
                        if not inside and not onSwatch then
                            popup:Destroy(); popup = nil
                        end
                    end)
                end)

                local api = { Value = current }
                function api:Set(c)
                    current = c
                    swatch.BackgroundColor3 = c
                    if cfg.Callback then task.spawn(cfg.Callback, c) end
                end
                function api:Get() return current end
                function api:SetVisible(v) row.Visible = v end
                function api:Destroy()
                    if popup then popup:Destroy() end
                    row:Destroy()
                end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            --==================================================================
            -- PARAGRAPH
            --==================================================================
            function sec:Paragraph(cfg)
                cfg = cfg or {}
                local holder = mk("Frame", {
                    BackgroundColor3 = theme.Bg2, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
                })
                corner(holder, 8)
                pad(holder, S.md, S.md, S.md, S.md)

                local hLbl = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Header or "Header",
                    Font = Enum.Font.GothamBold, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 16),
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
                })
                local body = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Body or "",
                    Font = Enum.Font.Gotham, TextSize = T.small,
                    TextColor3 = theme.Tx1, TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Position = UDim2.fromOffset(0, 20),
                    Size = UDim2.new(1, 0, 0, 0),
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

            --==================================================================
            -- HEADER / LABEL / DIVIDER / SPACE
            --==================================================================
            function sec:Header(cfg)
                cfg = cfg or {}
                local h = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Name or "Header",
                    Font = Enum.Font.GothamBold, TextSize = T.small,
                    TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 20), Parent = card,
                })
                return { Set = function(t) h.Text = t end, Destroy = function() h:Destroy() end }
            end

            function sec:Label(cfg)
                cfg = cfg or {}
                local l = mk("TextLabel", {
                    BackgroundTransparency = 1, Text = cfg.Text or cfg.Name or "",
                    Font = Enum.Font.Gotham, TextSize = T.small,
                    TextColor3 = theme.Tx1, TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
                })
                local api = {}
                function api:Set(t) l.Text = t end
                function api:Destroy() l:Destroy() end
                if cfg.Flag then xEz.Options[cfg.Flag] = api end
                return api
            end

            function sec:Divider()
                local d = mk("Frame", {
                    BackgroundColor3 = theme.Line, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.3,
                    Parent = card,
                })
                return { Destroy = function() d:Destroy() end }
            end

            function sec:Space(h)
                local s = mk("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, h or 4), Parent = card,
                })
                return { Destroy = function() s:Destroy() end }
            end

            return sec
        end

        tab.AddSection = AddSection
        tab.Section    = AddSection

        return tab
    end

    win.AddTab = AddTab
    win.Tab    = AddTab

    --==========================================================================
    -- WINDOW CONTROLS
    --==========================================================================
    local minimized = false
    local cachedSize = winSize

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local target = minimized
            and UDim2.fromOffset(cachedSize.X.Offset, 48)
            or cachedSize
        tw(root, ANIM.ease, { Size = target })
    end)

    themeBtn.MouseButton1Click:Connect(function()
        local keys = {}
        for k in pairs(xEz.Themes) do table.insert(keys, k) end
        table.sort(keys)
        local idx = table.find(keys, xEz.Theme) or 1
        idx = (idx % #keys) + 1
        xEz.Theme = keys[idx]
        win:Notify({
            Title = "Theme",
            Description = "Switched to " .. xEz.Theme .. " (reload for full effect)",
            Lifetime = 2,
        })
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tw(root, TweenInfo.new(0.22, Enum.EasingStyle.Quart,
            Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) })
        task.wait(0.22)
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
            Name = "Notify", BackgroundColor3 = theme.Bg1,
            BorderSizePixel = 0, Size = UDim2.fromOffset(320, 0),
            ClipsDescendants = true, Parent = notifyLayer,
        })
        corner(n, 10)
        stroke(n, theme.Line, theme.Stroke)

        local accent = mk("Frame", {
            Name = "Accent", BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0),
            Parent = n,
        })
        corner(accent, 2)

        pad(n, S.md + 4, S.md, S.md, S.md)

        mk("TextLabel", {
            BackgroundTransparency = 1, Text = ncfg.Title or "Notice",
            Font = Enum.Font.GothamBold, TextSize = T.small,
            TextColor3 = theme.Tx0, TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 16), Parent = n,
        })
        mk("TextLabel", {
            BackgroundTransparency = 1, Text = ncfg.Description or "",
            Font = Enum.Font.Gotham, TextSize = T.small,
            TextColor3 = theme.Tx1, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = n,
        })

        -- Progress bar
        local lifetime = ncfg.Lifetime or 3
        local progress = mk("Frame", {
            Name = "Progress", BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 2), Parent = n,
        })

        n.Position = UDim2.new(1, 360, 0, 0)
        tw(n, ANIM.ease, { Position = UDim2.new(1, 0, 0, 0) })
        tw(progress, TweenInfo.new(lifetime, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        })

        task.delay(lifetime, function()
            if not n or not n.Parent then return end
            tw(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 360, 0, 0),
                BackgroundTransparency = 1,
            })
            task.wait(0.3)
            if n then n:Destroy() end
        end)

        return {
            Dismiss = function()
                if n then n:Destroy() end
            end
        }
    end

    win._window = win
    UI._window = win
    return win
end

--==========================================================================
-- PUBLIC METHODS
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
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
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
        Subtitle = "v" .. xEz.Version .. " • Dark Gray",
        Size = UDim2.fromOffset(820, 560),
    })
    if not Win then return nil end

    local MainTab   = Win:AddTab({ Name = "Main", Icon = "◆" })
    local VisualTab = Win:AddTab({ Name = "Visual", Icon = "◈" })
    local ConfigTab = Win:AddTab({ Name = "Config", Icon = "◇" })

    -- Main / Left
    local gen = MainTab:AddSection({ Name = "General", Side = "Left" })
    gen:Button({ Name = "Simple Button", Icon = "→", Callback = function()
        Win:Notify({
            Title = "Clicked",
            Description = "Button pressed successfully.",
            Lifetime = 2,
        })
    end })
    gen:Toggle({
        Name = "Feature Toggle", Description = "Enable the special feature",
        Default = false, Flag = "demoToggle",
        Callback = function(v)
            Win:Notify({ Title = "Toggle", Description = tostring(v), Lifetime = 2 })
        end,
    })
    gen:Slider({ Name = "Speed", Min = 0, Max = 100, Default = 50, Flag = "demoSlider" })
    gen:Input({ Name = "Username", Placeholder = "Type here...", Flag = "demoInput" })

    -- Main / Right
    local misc = MainTab:AddSection({ Name = "Misc", Side = "Right" })
    misc:Keybind({ Name = "Toggle Key", Default = Enum.KeyCode.T, Flag = "demoKey" })
    misc:Dropdown({
        Name = "Mode", Options = { "Normal", "Fast", "Ultra" },
        Default = "Normal", Flag = "demoMode",
    })
    misc:Dropdown({
        Name = "Features", Multi = true,
        Options = { "A", "B", "C", "D" },
        Default = { "A", "C" }, Flag = "demoMulti",
    })
    misc:Colorpicker({
        Name = "Accent Color", Default = Color3.fromRGB(88, 140, 240),
        Flag = "demoColor",
    })

    -- Visual / Left
    local anim = VisualTab:AddSection({ Name = "Animation", Side = "Left" })
    anim:Button({ Name = "Show Notification", Icon = "!", Callback = function()
        Win:Notify({
            Title = "Hello!",
            Description = "This notification slides in from the right with a progress bar.",
            Lifetime = 3,
        })
    end })
    anim:Paragraph({
        Header = "About",
        Body = "Minimal flat design with 8-pt grid, type scale, and smooth Quart easing.",
    })
    anim:Divider()
    anim:Header({ Name = "Header Text" })
    anim:Label({ Text = "A simple wrapped label for description text." })

    -- Visual / Right
    local th = VisualTab:AddSection({ Name = "Theme", Side = "Right" })
    for _, name in ipairs({ "DarkGray", "Midnight", "Ocean", "Sunset", "Rose", "Emerald", "Light" }) do
        th:Button({ Name = "Theme: " .. name, Callback = function()
            xEz.Theme = name
            Win:Notify({
                Title = "Theme",
                Description = name .. " applied (reload for full effect).",
                Lifetime = 2,
            })
        end })
    end

    -- Config / Left
    local cfgSec = ConfigTab:AddSection({ Name = "Config System", Side = "Left" })
    local cfgName = cfgSec:Input({ Name = "Config Name", Placeholder = "myconfig" })
    cfgSec:Button({ Name = "Save", Icon = "↓", Callback = function()
        local ok, err = xEz:SaveConfig(cfgName:Get())
        Win:Notify({
            Title = "Config",
            Description = ok and "Saved!" or tostring(err),
            Lifetime = 2,
        })
    end })
    cfgSec:Button({ Name = "Load", Icon = "↑", Callback = function()
        local ok, err = xEz:LoadConfig(cfgName:Get())
        Win:Notify({
            Title = "Config",
            Description = ok and "Loaded!" or tostring(err),
            Lifetime = 2,
        })
    end })

    -- Config / Right
    local creds = ConfigTab:AddSection({ Name = "Credits", Side = "Right" })
    creds:Paragraph({
        Header = "xEz UI v" .. xEz.Version,
        Body = "Designed with 8-pt grid, 220ms Quart easing, derived theme colors, and 2-column layout.",
    })
    creds:Button({ Name = "Show Demo Notify", Icon = "★", Callback = function()
        Win:Notify({ Title = "Success", Description = "All systems operational.", Lifetime = 3 })
    end })

    return Win
end

--==========================================================================
-- RETURN
--==========================================================================
return UI