local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Lighting    = game:GetService("Lighting")
local UIS         = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local SHAHED_MESH  = "rbxassetid://16830989936"
local FPV_MESH     = "rbxassetid://100872842045704"
local FPV_TEXTURE  = "rbxassetid://74708124172363"
local SHAHED_SOUND = "rbxassetid://138607998397546"
local FPV_SOUND    = "rbxassetid://104098792477741"

local parentGui
if gethui then local ok, r = pcall(gethui); if ok and r then parentGui = r end end
if not parentGui then
    local ok, r = pcall(function() return game:GetService("CoreGui") end)
    if ok and r then parentGui = r end
end
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) end
pcall(function()
    local old = parentGui:FindFirstChild("D3ATH_MENU")
    if old then old:Destroy() end
    local oldSnow = parentGui:FindFirstChild("D3ATH_Snow")
    if oldSnow then oldSnow:Destroy() end
end)

local ACCENT    = Color3.fromRGB(230, 50, 50)
local ACCENT_D  = Color3.fromRGB(120, 15, 15)
local BG        = Color3.fromRGB(10, 10, 14)
local BG_GLASS  = Color3.fromRGB(18, 18, 24)
local BG_CARD   = Color3.fromRGB(26, 26, 34)
local BG_HOVER  = Color3.fromRGB(38, 38, 48)
local BORDER    = Color3.fromRGB(48, 48, 60)
local TEXT      = Color3.fromRGB(242, 242, 248)
local TEXT_DIM  = Color3.fromRGB(120, 120, 140)
local FONT      = Enum.Font.GothamMedium
local FONT_B    = Enum.Font.GothamBold
local FONT_BC   = Enum.Font.GothamBlack

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end
local function corner(r, p) return new("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(c, t, tr, p)
    return new("UIStroke", { Color = c, Thickness = t, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p)
end
local function grad(c1, c2, rot, p)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0; g.Parent = p
    return g
end
local function pad(t, b, l, r, p)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
    }, p)
end
local function tween(obj, props, dur, style, dir)
    local ti = TweenInfo.new(dur or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props); t:Play(); return t
end

local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function isCaxarok(plr)
    if not plr or plr == LocalPlayer then return false end
    return plr:FindFirstChild("IsCaxapok") ~= nil
end
local function amICaxarok()
    return LocalPlayer:FindFirstChild("IsCaxapok") ~= nil
end
local function inRound(plr)
    return plr and plr:FindFirstChild("InRound") ~= nil
end

local ScreenGui = new("ScreenGui", {
    Name = "D3ATH_MENU", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 100,
}, parentGui)

local SnowGui = new("ScreenGui", {
    Name = "D3ATH_Snow", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 99,
    Enabled = false,
}, parentGui)

local snowflakes = {}
for i = 1, 120 do
    local size = math.random(2, 6)
    local flake = new("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(math.random(), 0, math.random() * 1.2 - 0.2, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = math.random(30, 80) / 100,
        BorderSizePixel = 0, ZIndex = 1,
    }, SnowGui)
    corner(math.floor(size / 2), flake)
    snowflakes[i] = {
        frame = flake,
        speed = math.random(20, 55) / 100,
        drift = math.random(-20, 20) / 100,
        wobble = math.random() * 6.28,
    }
end

task.spawn(function()
    while SnowGui.Parent do
        local dt = RunService.RenderStepped:Wait()
        if SnowGui.Enabled then
            for _, f in ipairs(snowflakes) do
                local pos = f.frame.Position
                local newY = pos.Y.Scale + f.speed * dt * 0.5
                f.wobble = f.wobble + dt * 2
                local newX = pos.X.Scale + (f.drift + math.sin(f.wobble) * 0.3) * dt * 0.15
                if newY > 1.1 then
                    newY = -0.1
                    newX = math.random()
                end
                if newX > 1.1 then newX = -0.05 end
                if newX < -0.1 then newX = 1.05 end
                f.frame.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end
end)

local MainShadow = new("Frame", {
    Size = UDim2.new(0, 640, 0, 470),
    Position = UDim2.new(0.5, -316, 0.5, -231),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 5,
}, ScreenGui)
corner(16, MainShadow)

local Main = new("Frame", {
    Name = "Main", Size = UDim2.new(0, 640, 0, 470),
    Position = UDim2.new(0.5, -320, 0.5, -235),
    BackgroundColor3 = BG, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 6,
}, ScreenGui)
corner(14, Main)
local rainbowStroke = stroke(Color3.new(1,1,1), 2, 0, Main)
local rainbowGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 60, 60)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 150, 60)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 240, 60)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 255, 120)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(80, 180, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 100, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 60, 60)),
    }),
}, rainbowStroke)
task.spawn(function()
    while Main.Parent do
        rainbowGrad.Rotation = (rainbowGrad.Rotation + 4) % 360
        RunService.RenderStepped:Wait()
    end
end)

local function showMenu(show)
    if show then
        Main.Visible = true
        MainShadow.Visible = true
        SnowGui.Enabled = true
        Main.Size = UDim2.new(0, 640, 0, 0)
        MainShadow.Size = UDim2.new(0, 640, 0, 0)
        tween(Main, { Size = UDim2.new(0, 640, 0, 470) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(MainShadow, { Size = UDim2.new(0, 640, 0, 470) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        SnowGui.Enabled = false
        tween(Main, { Size = UDim2.new(0, 640, 0, 0) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(MainShadow, { Size = UDim2.new(0, 640, 0, 0) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.2)
        Main.Visible = false
        MainShadow.Visible = false
        Main.Size = UDim2.new(0, 640, 0, 470)
        MainShadow.Size = UDim2.new(0, 640, 0, 470)
    end
end

local Header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = BG_GLASS,
    BorderSizePixel = 0, ZIndex = 8,
}, Main)
corner(14, Header)
new("Frame", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20),
    BackgroundColor3 = BG_GLASS, BorderSizePixel = 0, ZIndex = 8 }, Header)
grad(Color3.fromRGB(36, 36, 46), Color3.fromRGB(22, 22, 30), 90, Header)
new("Frame", {
    Size = UDim2.new(1, -32, 0, 1), Position = UDim2.new(0, 16, 1, -1),
    BackgroundColor3 = BORDER, BorderSizePixel = 0, ZIndex = 9,
}, Header)

local LogoC = new("Frame", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 16, 0.5, -15),
    BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 10,
}, Header)
corner(9, LogoC); grad(ACCENT, ACCENT_D, 45, LogoC)
new("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "D",
    TextColor3 = Color3.new(1,1,1), Font = FONT_BC, TextSize = 17, ZIndex = 11,
}, LogoC)

new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 56, 0, 0),
    BackgroundTransparency = 1, Text = "D3ATH",
    TextColor3 = TEXT, Font = FONT_BC, TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
}, Header)
new("TextLabel", {
    Size = UDim2.new(0, 320, 1, 0), Position = UDim2.new(0, 130, 0, 0),
    BackgroundTransparency = 1, Text = "zabbiv - сыновья шлюх",
    TextColor3 = TEXT_DIM, Font = FONT, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
}, Header)

local CloseBtn = new("TextButton", {
    Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(1, -44, 0.5, -17),
    BackgroundColor3 = BG_CARD, BorderSizePixel = 0, Text = "×",
    TextColor3 = TEXT_DIM, Font = FONT_B, TextSize = 22,
    AutoButtonColor = false, ZIndex = 9,
}, Header)
corner(9, CloseBtn)
CloseBtn.MouseEnter:Connect(function()
    tween(CloseBtn, { BackgroundColor3 = ACCENT, TextColor3 = Color3.new(1,1,1) }, 0.12)
end)
CloseBtn.MouseLeave:Connect(function()
    tween(CloseBtn, { BackgroundColor3 = BG_CARD, TextColor3 = TEXT_DIM }, 0.12)
end)
CloseBtn.MouseButton1Click:Connect(function()
    showMenu(false)
end)

do
    local dragging, dragStart, startPos, shadowStartPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position
            startPos = Main.Position; shadowStartPos = MainShadow.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainShadow.Position = UDim2.new(shadowStartPos.X.Scale, shadowStartPos.X.Offset + delta.X, shadowStartPos.Y.Scale, shadowStartPos.Y.Offset + delta.Y)
        end
    end)
end

local Sidebar = new("Frame", {
    Size = UDim2.new(0, 150, 1, -66), Position = UDim2.new(0, 10, 0, 56),
    BackgroundColor3 = BG_GLASS, BorderSizePixel = 0, ZIndex = 7,
}, Main)
corner(10, Sidebar)
pad(10, 10, 8, 8, Sidebar)
new("UIListLayout", {
    Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, Sidebar)

local Content = new("Frame", {
    Size = UDim2.new(1, -174, 1, -66), Position = UDim2.new(0, 168, 0, 56),
    BackgroundColor3 = BG_GLASS, BorderSizePixel = 0, ZIndex = 7,
}, Main)
corner(10, Content)
pad(10, 10, 10, 10, Content)

local ContentScroll = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarImageTransparency = 0.2,
}, Content)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, ContentScroll)

local TabButtons, TabPages, ActiveTab = {}, {}, nil
local function switchTab(name)
    if ActiveTab == name then return end
    for n, page in pairs(TabPages) do page.Visible = (n == name) end
    for n, btn in pairs(TabButtons) do
        local lbl = btn:FindFirstChild("Txt")
        local bar = btn:FindFirstChild("Bar")
        if n == name then
            tween(btn, { BackgroundColor3 = BG_CARD }, 0.12)
            if lbl then tween(lbl, { TextColor3 = ACCENT }, 0.12) end
            if bar then
                bar.Visible = true
                bar.Size = UDim2.new(0, 3, 0, 0)
                tween(bar, { Size = UDim2.new(0, 3, 0, 22) }, 0.18)
            end
        else
            tween(btn, { BackgroundColor3 = BG_GLASS }, 0.12)
            if lbl then tween(lbl, { TextColor3 = TEXT_DIM }, 0.12) end
            if bar then bar.Visible = false end
        end
    end
    ActiveTab = name
end

local function createTab(name, order)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = BG_GLASS,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        LayoutOrder = order or 1, ZIndex = 8,
    }, Sidebar)
    corner(8, btn)
    local bar = new("Frame", {
        Name = "Bar", Size = UDim2.new(0, 3, 0, 22), Position = UDim2.new(0, 0, 0.5, -11),
        BackgroundColor3 = ACCENT, BorderSizePixel = 0, Visible = false, ZIndex = 9,
    }, btn)
    corner(2, bar)
    new("TextLabel", {
        Name = "Txt", Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = name, TextColor3 = TEXT_DIM,
        Font = FONT_B, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, btn)
    local page = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Visible = false, LayoutOrder = 1, ZIndex = 7,
    }, ContentScroll)
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then tween(btn, { BackgroundColor3 = BG_CARD }, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then tween(btn, { BackgroundColor3 = BG_GLASS }, 0.1) end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    TabButtons[name] = btn; TabPages[name] = page
    return page
end

local function makeSection(parent, text, order)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
        LayoutOrder = order or 1, ZIndex = 7,
    }, parent)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Text = text, TextColor3 = ACCENT, Font = FONT_B, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, f)
    local line = new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = BORDER, BorderSizePixel = 0, ZIndex = 7,
    }, f)
    grad(Color3.fromRGB(230, 50, 50), Color3.fromRGB(48, 48, 60), 0, line)
    return f
end

local function makeButton(parent, text, cb, order)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = BG_CARD,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        LayoutOrder = order or 1, ZIndex = 7,
    }, parent)
    corner(8, btn)
    local s = stroke(BORDER, 1, 0.3, btn)
    new("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = TEXT,
        Font = FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, btn)
    local arrow = new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1, Text = "›", TextColor3 = TEXT_DIM,
        Font = FONT_B, TextSize = 20, ZIndex = 8,
    }, btn)
    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundColor3 = BG_HOVER }, 0.1)
        tween(s, { Color = ACCENT }, 0.1)
        tween(arrow, { TextColor3 = ACCENT, Position = UDim2.new(1, -26, 0, 0) }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundColor3 = BG_CARD }, 0.1)
        tween(s, { Color = BORDER }, 0.1)
        tween(arrow, { TextColor3 = TEXT_DIM, Position = UDim2.new(1, -30, 0, 0) }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then local ok, err = pcall(cb); if not ok then warn("[D3ATH]", err) end end
    end)
    return btn
end

local function makeToggle(parent, text, default, cb, order)
    local state = default or false
    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = BG_CARD,
        BorderSizePixel = 0, LayoutOrder = order or 1, ZIndex = 7,
    }, parent)
    corner(8, frame)
    local s = stroke(BORDER, 1, 0.3, frame)
    new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = TEXT,
        Font = FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, frame)
    local ind = new("Frame", {
        Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(48, 48, 58), BorderSizePixel = 0, ZIndex = 8,
    }, frame)
    corner(12, ind)
    local indStroke = stroke(Color3.fromRGB(60,60,72), 1, 0.3, ind)
    local dot = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(160, 160, 170), BorderSizePixel = 0, ZIndex = 9,
    }, ind)
    corner(9, dot)
    local function render()
        if state then
            ind.BackgroundColor3 = ACCENT; indStroke.Color = ACCENT
            dot:TweenPosition(UDim2.new(1, -21, 0.5, -9), "Out", "Quad", 0.15, true)
            dot.BackgroundColor3 = Color3.new(1,1,1); s.Color = ACCENT
        else
            ind.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
            indStroke.Color = Color3.fromRGB(60,60,72)
            dot:TweenPosition(UDim2.new(0, 3, 0.5, -9), "Out", "Quad", 0.15, true)
            dot.BackgroundColor3 = Color3.fromRGB(160, 160, 170); s.Color = BORDER
        end
    end
    local click = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, ZIndex = 11,
    }, frame)
    local ctrl = {}
    function ctrl.setState(v, silent)
        state = v; render()
        if not silent and cb then
            local ok, err = pcall(cb, state); if not ok then warn("[D3ATH]", err) end
        end
    end
    click.MouseButton1Click:Connect(function() ctrl.setState(not state) end)
    render()
    return ctrl
end

local function makeSlider(parent, text, min, max, default, cb, order, suffix)
    suffix = suffix or ""
    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = BG_CARD,
        BorderSizePixel = 0, LayoutOrder = order or 1, ZIndex = 7,
    }, parent)
    corner(8, frame); stroke(BORDER, 1, 0.3, frame)
    new("TextLabel", {
        Size = UDim2.new(1, -90, 0, 22), Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1, Text = text, TextColor3 = TEXT,
        Font = FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, frame)
    local valueLbl = new("TextLabel", {
        Size = UDim2.new(0, 76, 0, 22), Position = UDim2.new(1, -88, 0, 8),
        BackgroundTransparency = 1, Text = tostring(default) .. suffix,
        TextColor3 = ACCENT, Font = FONT_B, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 8,
    }, frame)
    local track = new("Frame", {
        Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 40),
        BackgroundColor3 = Color3.fromRGB(48, 48, 58), BorderSizePixel = 0, ZIndex = 8,
    }, frame)
    corner(3, track)
    local fill = new("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 9,
    }, track)
    corner(3, fill); grad(ACCENT, ACCENT_D, 0, fill)
    local dot = new("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 10,
    }, track)
    corner(8, dot); stroke(ACCENT, 2, 0, dot)
    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        dot.Position = UDim2.new(rel, -8, 0.5, -8)
        valueLbl.Text = tostring(val) .. suffix
        if cb then local ok, err = pcall(cb, val); if not ok then warn("[D3ATH]", err) end end
    end
    local hit = new("TextButton", {
        Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0, 14, 0, 34),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 11,
    }, frame)
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return frame
end

local NotifyHolder = new("Frame", {
    Size = UDim2.new(0, 260, 0, 200), Position = UDim2.new(1, -280, 0, 60),
    BackgroundTransparency = 1, ZIndex = 50,
}, ScreenGui)
new("UIListLayout", {
    Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, NotifyHolder)
local function notify(title, content, dur)
    local box = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = BG_GLASS, BorderSizePixel = 0, ZIndex = 50,
        BackgroundTransparency = 1,
    }, NotifyHolder)
    corner(8, box)
    local ns = stroke(ACCENT, 1.5, 0, box)
    local ng = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 220, 60)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 255, 120)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(80, 180, 255)),
        }),
    }, ns)
    task.spawn(function()
        while box.Parent do
            ng.Rotation = (ng.Rotation + 5) % 360
            RunService.RenderStepped:Wait()
        end
    end)
    pad(12, 12, 14, 14, box)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, box)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Text = title, TextColor3 = ACCENT, Font = FONT_B, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 51,
    }, box)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = content, TextColor3 = TEXT,
        Font = FONT, TextSize = 11, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 51,
    }, box)
    tween(box, { BackgroundTransparency = 0 }, 0.2)
    task.delay(dur or 3, function()
        tween(box, { BackgroundTransparency = 1 }, 0.2)
        task.wait(0.25)
        pcall(function() box:Destroy() end)
    end)
end

-- ============================================================
--  FLING / WALKFLING — 1в1 как в Infinity Yield
--  walkfling: БЕЗ спина, только velocity-глич + noclip
--  fling (spin): тяжёлый + BodyAngularVelocity 99999 + massless
--  НЕ обнуляем Velocity каждый кадр и НЕ ставим Anchored —
--  это убивало флинг в прошлой версии.
-- ============================================================
local walkFlingActive = false
local walkFlingThread = nil
local spinFlingOn = false
local spinFlingThread = nil
local flingSpin = nil
local flingDiedConn = nil
local flingBusy = false
local killTpActive = false
local killTpThread = nil
-- форвард-ссылки на тоглы UI (заполняются ниже, чтобы смерть гасила кнопки)
local walkFlingCtrl, spinFlingCtrl, killTpCtrl = nil, nil, nil
local function syncFlingToggles()
    pcall(function() if walkFlingCtrl then walkFlingCtrl.setState(false, true) end end)
    pcall(function() if spinFlingCtrl then spinFlingCtrl.setState(false, true) end end)
    pcall(function() if killTpCtrl then killTpCtrl.setState(false, true) end end)
end

local function killSpin()
    if flingSpin and flingSpin.Parent then
        pcall(function() flingSpin:Destroy() end)
    end
    flingSpin = nil
end

local function stopWalkFling()
    walkFlingActive = false
    spinFlingOn = false
    if walkFlingThread then task.cancel(walkFlingThread); walkFlingThread = nil end
    if spinFlingThread then task.cancel(spinFlingThread); spinFlingThread = nil end
    killSpin()
    -- чистим хвосты от старой (сломанной) версии + спин + физику spin-флинга
    -- (чтобы после смерти не остаться тяжёлым/massless)
    local char = getChar()
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BodyAngularVelocity") and (v.Name == "TWKS_WalkFlingSpin" or v.Name == "TWKS_FlingSpin") then
                pcall(function() v:Destroy() end)
            end
            if v:IsA("BasePart") then
                pcall(function()
                    v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                end)
                v.Massless = false
            end
        end
    end
end

-- WALKFLING (IY velocity-глич, спина НЕТ) + анти-самоотлёт:
-- тело не крутится, density обычная, только noclip + глич.
-- Себя всё равно может толкнуть при прямом таране — это норма
-- для walkfling (он для бега в толпу). Для таргета используй doFling.
local function startWalkFling()
    stopWalkFling()
    task.wait(0.05)
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if flingDiedConn then pcall(function() flingDiedConn:Disconnect() end); flingDiedConn = nil end
    if hum then flingDiedConn = hum.Died:Connect(function() stopWalkFling(); syncFlingToggles() end) end
    if hum then pcall(function() hum.AutoRotate = true end) end

    walkFlingActive = true
    walkFlingThread = task.spawn(function()
        local movel = 0.1
        while walkFlingActive do
            RunService.Heartbeat:Wait()
            local c = getChar()
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not (c and c.Parent and r and r.Parent) then
                while walkFlingActive do
                    RunService.Heartbeat:Wait()
                    c = getChar()
                    r = c and c:FindFirstChild("HumanoidRootPart")
                    if c and c.Parent and r and r.Parent then break end
                end
            end
            if not walkFlingActive then break end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            local vel = r.Velocity
            r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            if c.Parent and r.Parent then
                r.Velocity = vel
            end
            RunService.Stepped:Wait()
            if c.Parent and r.Parent then
                r.Velocity = vel + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        end
    end)
end

-- ============================================================
--  HAT-FLING (новая система, без самоотлёта):
--  Открепляем аксессуар (шляпу), крутим ТОЛЬКО его у жертвы.
--  Тело стоит далеко в сейв-позиции с noclip и нулевой скоростью,
--  поэтому тебя не откидывает. Юзает только твои сетевые парты
--  (аксессуары), новых партов не создаём — они бы не реплицировались.
-- ============================================================
local hatWeldBackup = nil -- {handle, weldParent, weld}
local hatSpin = nil

local function findAccessory(char)
    if not char then return nil end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then return acc, h end
        end
    end
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == "Handle" and d:IsA("BasePart") then
            local acc = d:FindFirstAncestorWhichIsA("Accessory")
            if acc then return acc, d end
        end
    end
    return nil
end

local function detachHat(char)
    local acc, handle = findAccessory(char)
    if not acc or not handle then return nil end
    -- бэкап сварки
    local weld = handle:FindFirstChildWhichIsA("Weld", true)
        or handle:FindFirstChildWhichIsA("WeldConstraint", true)
        or acc:FindFirstChildWhichIsA("Weld", true)
    hatWeldBackup = { acc = acc, handle = handle, weld = weld, parent = weld and weld.Parent }
    pcall(function() if weld then weld:Destroy() end end)
    -- шляпа — тяжёлый молот, тело — noclip
    pcall(function()
        handle.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
    end)
    handle.Massless = false
    handle.CanCollide = true
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v ~= handle then
            v.CanCollide = false
            v.Velocity = Vector3.zero
        end
    end
    if hatSpin and hatSpin.Parent then pcall(function() hatSpin:Destroy() end) end
    hatSpin = Instance.new("BodyAngularVelocity")
    hatSpin.Name = "TWKS_HatSpin"
    hatSpin.AngularVelocity = Vector3.new(0, 99999, 0)
    hatSpin.MaxTorque = Vector3.new(0, math.huge, 0)
    hatSpin.P = math.huge
    hatSpin.Parent = handle
    return handle
end

local function restoreHat(char)
    if hatSpin and hatSpin.Parent then pcall(function() hatSpin:Destroy() end) end
    hatSpin = nil
    local b = hatWeldBackup
    hatWeldBackup = nil
    if not b then return end
    local handle = b.handle
    if not (handle and handle.Parent) then return end
    pcall(function()
        handle.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
    end)
    handle.Massless = false
    handle.Velocity = Vector3.zero
    handle.RotVelocity = Vector3.zero
    -- переприварить к голове
    local head = char and char:FindFirstChild("Head")
    if head and char then
        pcall(function()
            handle.CFrame = head.CFrame * CFrame.new(0, 0.5, 0)
            local wc = Instance.new("WeldConstraint")
            wc.Name = "TWKS_HatRestore"
            wc.Part0 = head
            wc.Part1 = handle
            wc.Parent = handle
        end)
    end
end

-- Ручной SpinFling-тогл: оставлен для совместимости, но теперь
-- это tap-метод телом (короткие касания с отходом), а не вварка.
-- Меньше самоотлёта, чем постоянная вварка.
local function startSpinFling()
    stopWalkFling()
    task.wait(0.1)
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if flingDiedConn then pcall(function() flingDiedConn:Disconnect() end); flingDiedConn = nil end
    if hum then flingDiedConn = hum.Died:Connect(function() stopWalkFling(); syncFlingToggles() end) end

    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("BasePart") then
            pcall(function()
                child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            end)
            child.CanCollide = false
        end
    end
    task.wait(0.05)
    killSpin()
    flingSpin = Instance.new("BodyAngularVelocity")
    flingSpin.Name = "TWKS_FlingSpin"
    flingSpin.Parent = root
    flingSpin.AngularVelocity = Vector3.new(0, 99999, 0)
    flingSpin.MaxTorque = Vector3.new(0, math.huge, 0)
    flingSpin.P = math.huge
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            v.Massless = true
            v.Velocity = Vector3.zero
        end
    end
    spinFlingOn = true
    walkFlingActive = true
    spinFlingThread = task.spawn(function()
        while spinFlingOn do
            if flingSpin and flingSpin.Parent then
                flingSpin.AngularVelocity = Vector3.new(0, 99999, 0)
            end
            task.wait(0.2)
            if flingSpin and flingSpin.Parent then
                flingSpin.AngularVelocity = Vector3.new(0, 0, 0)
            end
            task.wait(0.1)
        end
    end)
    walkFlingThread = task.spawn(function()
        while walkFlingActive do
            local c = getChar()
            if c then
                for _, v in ipairs(c:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
            RunService.Stepped:Wait()
        end
    end)
end

local function stopSpinFlingCleanup()
    stopWalkFling()
    task.wait(0.05)
    local char = getChar()
    if char then
        pcall(restoreHat, char)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "Handle" then
                pcall(function()
                    v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                end)
                v.Massless = false
                v.Velocity = Vector3.zero
                v.RotVelocity = Vector3.zero
            end
        end
    end
end

-- ============================================================
--  DOFLING v3 (финал): бьёт ОТКРЕПЛЁННОЙ ШЛЯПОЙ, тело в сейве.
--  Ты НЕ отлетаешь, потому что твоё тело далеко от жертвы и без
--  спина/плотности. Если шляп нет — tap-тело с отходом.
--  Настройки: длительность 2.6с, тап 0.22с в цели / 0.1с отход.
-- ============================================================
local FLING_DURATION = 2.6
local FLING_TAP_IN = 0.22
local FLING_TAP_OUT = 0.1
local BODY_PARK_OFFSET = Vector3.new(0, 60, 0) -- тело паркуем высоко над сейвом

local function parkBody(myRoot, savedCF)
    if myRoot and myRoot.Parent then
        myRoot.CFrame = savedCF + BODY_PARK_OFFSET
        myRoot.Velocity = Vector3.zero
        myRoot.RotVelocity = Vector3.zero
    end
end

local function victimFlung(tRoot, startPos)
    if not (tRoot and tRoot.Parent) then return true end
    local v = tRoot.Velocity.Magnitude + tRoot.RotVelocity.Magnitude
    if v > 120 then return true end
    if (tRoot.Position - startPos).Magnitude > 40 then return true end
    return false
end

local function doHatFling(target, duration)
    duration = duration or FLING_DURATION
    if flingBusy then return false end
    if not target or not target.Character then return false end
    local myChar = getChar()
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and myRoot.Parent and tRoot and tRoot.Parent) then return false end

    flingBusy = true
    stopWalkFling()
    local flyBV = myRoot:FindFirstChild("TWKS_FlyBV")
    local flyBG = myRoot:FindFirstChild("TWKS_FlyBG")
    local flyBVSaved = flyBV and flyBV.Enabled
    local flyBGSaved = flyBG and flyBG.Enabled
    if flyBV then flyBV.Enabled = false end
    if flyBG then flyBG.Enabled = false end

    local savedCF = myRoot.CFrame
    local tStartPos = tRoot.Position
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local startPos = tRoot.Position

    -- глушим свои CFrame-конфликты (spinbot/tpBehind) на время флинга
    -- (читаются в главном цикле через flingBusy)

    local handle = detachHat(myChar)
    parkBody(myRoot, savedCF)

    local ok, err
    if handle then
        -- РЕЖИМ ШЛЯПЫ: тело в небе, шляпа молотит жертву тапами
        local startT = tick()
        local tapT = tick()
        local inside = true
        while tick() - startT < duration do
            myChar = getChar()
            myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not (myRoot and myRoot.Parent and tRoot and tRoot.Parent) then break end
            if not (handle and handle.Parent) then break end
            if tHum and tHum.Parent and tHum.Health <= 0 then break end
            -- тело держим в парке, гасим любую набранную скорость (анти-самоотлёт)
            parkBody(myRoot, savedCF)
            for _, v in ipairs(myChar:GetDescendants()) do
                if v:IsA("BasePart") and v ~= handle then
                    v.CanCollide = false
                    v.Velocity = Vector3.zero
                    v.RotVelocity = Vector3.zero
                end
            end
            -- шляпа: тап внутрь / отход (не вварка!)
            if inside then
                handle.CFrame = tRoot.CFrame * CFrame.new(0, 0.7, 0)
                handle.Velocity = Vector3.new(0, 9000, 0)
                handle.RotVelocity = Vector3.new(0, 99999, 0)
                if hatSpin and hatSpin.Parent then
                    hatSpin.AngularVelocity = Vector3.new(0, 99999, 0)
                end
                if tick() - tapT > FLING_TAP_IN then tapT = tick(); inside = false end
            else
                handle.CFrame = tRoot.CFrame * CFrame.new(0, 7, 0)
                if tick() - tapT > FLING_TAP_OUT then tapT = tick(); inside = true end
            end
            if victimFlung(tRoot, startPos) and (tick() - startT) > 0.6 then break end
            RunService.Heartbeat:Wait()
        end
        ok = true
    else
        -- FALLBACK БЕЗ ШЛЯП: tap телом с отходом (вварки нет)
        startSpinFling()
        local startT = tick()
        local tapT = tick()
        local inside = true
        while tick() - startT < duration do
            myChar = getChar()
            myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not (myRoot and myRoot.Parent and tRoot and tRoot.Parent) then break end
            if tHum and tHum.Parent and tHum.Health <= 0 then break end
            if inside then
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0.8, 0)
                if tick() - tapT > 0.18 then tapT = tick(); inside = false end
            else
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 8, 0)
                myRoot.Velocity = Vector3.zero -- на отходе гасим себя
                myRoot.RotVelocity = Vector3.zero
                if tick() - tapT > 0.12 then tapT = tick(); inside = true end
            end
            if victimFlung(tRoot, startPos) and (tick() - startT) > 0.6 then break end
            RunService.Heartbeat:Wait()
        end
        ok = true
    end

    -- чистка + возврат тела ровно в сейв
    pcall(restoreHat, getChar())
    stopSpinFlingCleanup()
    task.wait(0.05)
    myChar = getChar()
    myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myRoot and myRoot.Parent then
        myRoot.CFrame = savedCF
        myRoot.Velocity = Vector3.zero
        myRoot.RotVelocity = Vector3.zero
    end
    if flyBV and flyBV.Parent then flyBV.Enabled = flyBVSaved end
    if flyBG and flyBG.Parent then flyBG.Enabled = flyBGSaved end
    flingBusy = false
    return ok
end

local function doFling(target)
    local ok = doHatFling(target, FLING_DURATION)
    if ok == false then
        notify("Fling", "Не вышло: цель/персонаж недоступны", 2)
    end
end

local function stopKillTp()
    killTpActive = false
    if killTpThread then task.cancel(killTpThread); killTpThread = nil end
    if not flingBusy then
        stopWalkFling()
        pcall(restoreHat, getChar())
    end
end

local function startKillTp()
    stopKillTp()
    killTpActive = true
    killTpThread = task.spawn(function()
        -- тело НЕ ввариваем в жертв: каждая цель бьётся шляпой отдельно
        while killTpActive do
            local myChar = getChar()
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot and myRoot.Parent then
                local targets = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and inRound(plr) then
                        local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if tr and tr.Parent and hum and hum.Health > 0 then
                            table.insert(targets, plr)
                        end
                    end
                end
                for _, plr in ipairs(targets) do
                    if not killTpActive then break end
                    if flingBusy then task.wait(0.2) else doHatFling(plr, 1.4) end
                    task.wait(0.15)
                end
            end
            task.wait(0.3)
        end
        if not flingBusy then
            stopWalkFling()
            pcall(restoreHat, getChar())
        end
    end)
end

local espPlayers, espCaxapok, tagsEnabled = false, false, false

local function ensureHighlight(plr, color, name)
    local ch = plr.Character; if not ch then return end
    local hl = ch:FindFirstChild(name)
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = name
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = ch
    end
    hl.FillColor = color
    hl.OutlineColor = color
    if hl.Adornee ~= ch then hl.Adornee = ch end
end

local function smartRefreshESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local isCax = isCaxarok(plr)
            local char = plr.Character
            local hlP = char:FindFirstChild("TWKS_P")
            if espPlayers and not isCax then
                if not hlP then
                    ensureHighlight(plr, Color3.fromRGB(30, 255, 80), "TWKS_P")
                else
                    hlP.FillColor = Color3.fromRGB(30, 255, 80)
                    hlP.OutlineColor = Color3.fromRGB(30, 255, 80)
                    if hlP.Adornee ~= char then hlP.Adornee = char end
                end
            elseif hlP then
                hlP:Destroy()
            end
            local hlC = char:FindFirstChild("TWKS_C")
            if espCaxapok and isCax then
                if not hlC then
                    ensureHighlight(plr, Color3.fromRGB(255, 30, 30), "TWKS_C")
                else
                    hlC.FillColor = Color3.fromRGB(255, 30, 30)
                    hlC.OutlineColor = Color3.fromRGB(255, 30, 30)
                    if hlC.Adornee ~= char then hlC.Adornee = char end
                end
            elseif hlC then
                hlC:Destroy()
            end
        end
    end
end

local function stripAllHighlights()
    for _, plr in ipairs(Players:GetPlayers()) do
        local ch = plr.Character
        if ch then
            local a = ch:FindFirstChild("TWKS_P"); if a then a:Destroy() end
            local b = ch:FindFirstChild("TWKS_C"); if b then b:Destroy() end
        end
    end
end

local function refreshAll()
    stripAllHighlights()
    smartRefreshESP()
end

-- ============================================================
--  ESP ПРЕДМЕТОВ: живые предметы раунда в Workspace.
--  Шаблоны лежат в Workspace.Tools, точки спавна — "Pos" парты
--  в House.*, а живой предмет — клон с тем же именем у позиции.
--  Поэтому: имя из набора + НЕ под Workspace.Tools + не "Pos".
-- ============================================================
local espKeys, espLom, espMech, espMisc, espExit = false, false, false, false, false
local ITEM_SETS = {
    keys = { color = Color3.fromRGB(255, 210, 60), names = {
        PinkKey = "Розовый ключ", YellowKey = "Жёлтый ключ", PurpleKey = "Фиолетовый ключ",
        BlueKey = "Синий ключ", RedKey = "Красный ключ", OrangeKey = "Оранжевый ключ",
        GreenKey = "Зелёный ключ" } },
    lom = { color = Color3.fromRGB(255, 40, 40), names = { Lom = "ЛОМ" } },
    mech = { color = Color3.fromRGB(255, 140, 40), names = {
        RedShesterenka = "Шестерня", GreenShesterenka = "Шестерня", BlueShesterenka = "Шестерня",
        Knopki = "Кнопки", Knopka = "Кнопка", Korobka = "Коробка", Provoda = "Провода" } },
    misc = { color = Color3.fromRGB(90, 200, 255), names = { Spray = "Спрей", Tabletki = "Таблетки" } },
    exit = { color = Color3.fromRGB(60, 255, 110), names = { Escape = "ВЫХОД", ExitDoor = "Выход" } },
}
local itemEspTags = {}

local function anyItemEspOn()
    return espKeys or espLom or espMech or espMisc or espExit
end

local function clearItemESP()
    for _, o in ipairs(itemEspTags) do
        pcall(function() o:Destroy() end)
    end
    itemEspTags = {}
end

local function isUnderTools(inst)
    local wsTools = workspace:FindFirstChild("Tools")
    return wsTools and inst:IsDescendantOf(wsTools) or false
end

local function tagItemPart(part, label, color)
    local hl = Instance.new("Highlight")
    hl.Name = "TWKS_Item"
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.FillColor = color
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = part
    hl.Parent = part
    table.insert(itemEspTags, hl)
    local bg = Instance.new("BillboardGui")
    bg.Name = "TWKS_ItemTag"
    bg.Size = UDim2.new(0, 200, 0, 36)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = part
    table.insert(itemEspTags, bg)
    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, 0, 1, 0)
    tx.BackgroundTransparency = 1
    tx.Text = label
    tx.TextColor3 = color
    tx.TextStrokeTransparency = 0.2
    tx.TextScaled = true
    tx.Font = FONT_B
    tx.Parent = bg
end

local function firstPart(model)
    local pp = model.PrimaryPart
    if pp and pp:IsA("BasePart") then return pp end
    local f = model:FindFirstChildWhichIsA("BasePart", true)
    return f
end

local function refreshItemESP()
    clearItemESP()
    if not anyItemEspOn() then return end
    local map = {}
    if espKeys then for n, l in pairs(ITEM_SETS.keys.names) do map[n] = { l = l, c = ITEM_SETS.keys.color } end end
    if espLom then for n, l in pairs(ITEM_SETS.lom.names) do map[n] = { l = l, c = ITEM_SETS.lom.color } end end
    if espMech then for n, l in pairs(ITEM_SETS.mech.names) do map[n] = { l = l, c = ITEM_SETS.mech.color } end end
    if espMisc then for n, l in pairs(ITEM_SETS.misc.names) do map[n] = { l = l, c = ITEM_SETS.misc.color } end end
    if espExit then for n, l in pairs(ITEM_SETS.exit.names) do map[n] = { l = l, c = ITEM_SETS.exit.color } end end
    local count = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if count >= 70 then break end
        local entry = map[d.Name]
        if entry and not isUnderTools(d) then
            if d:IsA("BasePart") and d.Name ~= "Pos" then
                tagItemPart(d, entry.l, entry.c)
                count += 1
            elseif d:IsA("Tool") then
                local h = d:FindFirstChild("Handle") or d:FindFirstChildWhichIsA("BasePart", true)
                if h then
                    tagItemPart(h, entry.l .. " (в руках)", entry.c)
                    count += 1
                end
            elseif d:IsA("Model") or d:IsA("Folder") then
                if d.Name ~= "Pos" then
                    if d:IsA("Folder") then
                        for _, p in ipairs(d:GetDescendants()) do
                            if count >= 70 then break end
                            if p:IsA("BasePart") and p.Name ~= "Pos" then
                                tagItemPart(p, entry.l, entry.c)
                                count += 1
                                if count >= 3 then break end
                            end
                        end
                    else
                        local fp = firstPart(d)
                        if fp then
                            tagItemPart(fp, entry.l, entry.c)
                            count += 1
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(2.5) do
        if anyItemEspOn() then
            refreshItemESP()
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if espPlayers or espCaxapok then
            smartRefreshESP()
        end
    end
end)

local tagCache = {}
local function createTag(plr)
    if tagCache[plr] then return end
    local head = plr.Character and plr.Character:FindFirstChild("Head")
    if not head then return end
    local bg = Instance.new("BillboardGui")
    bg.Name = "TWKS_Tag"
    bg.Size = UDim2.new(0, 250, 0, 40)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = "zabbiv - сыновья шлюх"; lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0.3; lbl.TextScaled = true; lbl.Font = FONT_BC
    lbl.Parent = bg
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 255, 100)),
    })
    gradient.Parent = lbl
    tagCache[plr] = bg
end
local function updateTags()
    if not tagsEnabled then
        for plr, bg in pairs(tagCache) do pcall(function() bg:Destroy() end); tagCache[plr] = nil end
        return
    end
    -- БАГФИКС: чистим протухшие ссылки (после реса Head новый, старый bg мёртв —
    -- раньше createTag думал что тег уже есть и новый не вешал)
    for plr, bg in pairs(tagCache) do
        if not (bg and bg.Parent) then tagCache[plr] = nil end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then createTag(plr) end
    end
end

-- ============================================================
--  SKIN CHANGER (клиентский, только ты видишь):
--  ReplicatedStorage.Skins.Standart (36) + .Admin (27).
--  Копируем на своего перса: одежду, BodyColors, лицо, цвета/
--  меши частей тела, пропорции Humanoid, аксессуары и звуки
--  из UpperTorso (Dead/Hit/StunSound/Steps). Своего Humanoid и
--  персонажа НЕ меняем — раунд-скрипты целы.
-- ============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local selectedSkinCat, selectedSkinName = nil, nil
local autoSkinCaxarok = false
local morphAppliedKey = nil
local originalLook = nil

local SCALE_VALUE_NAMES = { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "BodyTypeScale", "BodyProportionScale", "HeadScale" }
local SKIN_SOUND_NAMES = { Dead = true, Hit = true, StunSound = true, Steps = true, Theme = true }

local function getSkinFolder(cat)
    local skins = ReplicatedStorage:FindFirstChild("Skins")
    if not skins then return nil end
    return skins:FindFirstChild(cat)
end
local function getSkinModel(cat, name)
    local f = getSkinFolder(cat)
    return f and f:FindFirstChild(name) or nil
end
local function listSkinNames(cat)
    local f = getSkinFolder(cat)
    if not f then return {} end
    local out = {}
    for _, m in ipairs(f:GetChildren()) do
        if m:IsA("Model") then table.insert(out, m.Name) end
    end
    table.sort(out)
    return out
end

local function snapshotLook(char)
    local snap = { accessories = {}, clothes = {}, face = nil, parts = {}, meshes = {}, headMesh = nil, scales = {}, sounds = {} }
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Accessory") then
            table.insert(snap.accessories, c:Clone())
        elseif c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c:IsA("BodyColors") then
            table.insert(snap.clothes, c:Clone())
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") and not snap.face then snap.face = d:Clone() end
        end
        local sm = head:FindFirstChildOfClass("SpecialMesh")
        if sm then
            snap.headMesh = { MeshId = sm.MeshId, TextureId = sm.TextureId, Scale = sm.Scale, Offset = sm.Offset, VertexColor = sm.VertexColor }
        end
    end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            snap.parts[p.Name] = { Color = p.Color, Material = p.Material, Transparency = p.Transparency }
            if p:IsA("MeshPart") then
                snap.meshes[p.Name] = { MeshId = p.MeshId, TextureID = p.TextureID, Size = p.Size }
            end
        elseif p:IsA("NumberValue") and table.find(SCALE_VALUE_NAMES, p.Name) then
            snap.scales[p.Name] = p.Value
        end
    end
    local torso = char:FindFirstChild("UpperTorso")
    if torso then
        for _, s in ipairs(torso:GetChildren()) do
            if s:IsA("Sound") and SKIN_SOUND_NAMES[s.Name] then
                table.insert(snap.sounds, s:Clone())
            end
        end
    end
    return snap
end

local function wipeVisual(char)
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c:IsA("BodyColors") then
            pcall(function() c:Destroy() end)
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") then pcall(function() d:Destroy() end) end
        end
    end
    local torso = char:FindFirstChild("UpperTorso")
    if torso then
        for _, s in ipairs(torso:GetChildren()) do
            if s:IsA("Sound") and SKIN_SOUND_NAMES[s.Name] then pcall(function() s:Destroy() end) end
        end
    end
end

-- БАГФИКС: точный поиск парта (прямой ребёнок в приоритете).
-- Старый FindFirstChild(name, true) мог вернуть левый инстанс с тем же
-- именем (звук/велью/хендл аксессуара) — отсюда "баганые" скины.
local function findOwnPart(char, name)
    local direct = char:FindFirstChild(name)
    if direct and direct:IsA("BasePart") then return direct end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == name then return d end
    end
    return nil
end

local function equipAccessory(char, hum, acc)
    local cl = acc:Clone()
    local h = cl:FindFirstChild("Handle")
    if h and h:IsA("BasePart") then
        h.CanCollide = false
        h.Massless = false
    end
    -- БАГФИКС: вешаем через Humanoid:AddAccessory (строит вельды),
    -- plain Parent иногда оставлял шляпу неприваренной/в нулях
    local done = false
    if hum then
        done = pcall(function() hum:AddAccessory(cl) end)
    end
    if not done then
        cl.Parent = char
    end
end

-- keepSelection=true для авто-снятия (выбор помним для след. раунда)
local function restoreLook(keepSelection)
    local char = getChar()
    if not char or not originalLook then
        if not keepSelection then notify("Скины", "Нечего снимать", 2) end
        return
    end
    wipeVisual(char)
    for _, c in ipairs(originalLook.clothes) do
        local cl = c:Clone()
        cl.Parent = char
    end
    local hum0 = char:FindFirstChildOfClass("Humanoid")
    for _, a in ipairs(originalLook.accessories) do
        equipAccessory(char, hum0, a)
    end
    local head = char:FindFirstChild("Head")
    if head and originalLook.face then
        originalLook.face:Clone().Parent = head
    end
    if head and originalLook.headMesh then
        local sm = head:FindFirstChildOfClass("SpecialMesh")
        local hm = originalLook.headMesh
        if sm then
            sm.MeshId, sm.TextureId = hm.MeshId, hm.TextureId
            sm.Scale, sm.Offset, sm.VertexColor = hm.Scale, hm.Offset, hm.VertexColor
        end
    end
    for name, pr in pairs(originalLook.parts) do
        local p = findOwnPart(char, name)
        if p then
            p.Color, p.Material, p.Transparency = pr.Color, pr.Material, pr.Transparency
        end
    end
    for name, mp in pairs(originalLook.meshes) do
        local p = findOwnPart(char, name)
        if p and p:IsA("MeshPart") then
            pcall(function() p.MeshId = mp.MeshId end)
            pcall(function() p.TextureID = mp.TextureID end)
            -- БАГФИКС: размер под меш скина, иначе тело растянуто/сплющено
            pcall(function() p.Size = mp.Size end)
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for n, v in pairs(originalLook.scales) do
            local val = hum:FindFirstChild(n)
            if val then pcall(function() val.Value = v end) end
        end
    end
    local torso = char:FindFirstChild("UpperTorso")
    if torso then
        for _, s in ipairs(originalLook.sounds) do
            s:Clone().Parent = torso
        end
    end
    morphAppliedKey = nil
    if not keepSelection then
        selectedSkinCat, selectedSkinName = nil, nil
        notify("Скины", "Свой вид возвращён", 2)
    end
end

local function applySkin(cat, name, silent)
    local char = getChar()
    if not char then
        if not silent then notify("Скины", "Нет персонажа", 2) end
        return false
    end
    local model = getSkinModel(cat, name)
    if not model then
        if not silent then notify("Скины", "Модель не найдена: " .. tostring(name), 2) end
        return false
    end
    if not originalLook then
        originalLook = snapshotLook(char)
    end
    wipeVisual(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    -- одежда
    for _, cname in ipairs({ "Body Colors", "Shirt", "Pants" }) do
        local src = model:FindFirstChild(cname)
        if src then src:Clone().Parent = char end
    end
    local sg = model:FindFirstChildOfClass("ShirtGraphic")
    if sg then sg:Clone().Parent = char end
    -- лицо с головы скина
    local skinHead = model:FindFirstChild("Head")
    local myHead = char:FindFirstChild("Head")
    if skinHead and myHead then
        for _, d in ipairs(skinHead:GetChildren()) do
            if d:IsA("Decal") then d:Clone().Parent = myHead end
        end
        local skinSM = skinHead:FindFirstChildOfClass("SpecialMesh")
        local mySM = myHead:FindFirstChildOfClass("SpecialMesh")
        if skinSM and mySM then
            mySM.MeshId, mySM.TextureId = skinSM.MeshId, skinSM.TextureId
            mySM.Scale, mySM.Offset = skinSM.Scale, skinSM.Offset
            pcall(function() mySM.VertexColor = skinSM.VertexColor end)
        end
    end
    -- цвета / материалы / меши тела по именам частей
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            -- пропускаем хендлы аксессуаров скина (их клонируем целиком ниже)
            if not p:FindFirstAncestorWhichIsA("Accessory") then
                local mine = findOwnPart(char, p.Name)
                if mine then
                    mine.Color = p.Color
                    mine.Transparency = p.Transparency
                    pcall(function() mine.Material = p.Material end)
                    if p:IsA("MeshPart") and mine:IsA("MeshPart") then
                        pcall(function() mine.MeshId = p.MeshId end)
                        pcall(function() mine.TextureID = p.TextureID end)
                        pcall(function() mine.Size = p.Size end)
                    end
                end
            end
        end
    end
    -- пропорции
    local skinHum = model:FindFirstChildOfClass("Humanoid")
    if skinHum and hum then
        for _, n in ipairs(SCALE_VALUE_NAMES) do
            local sv, mv = skinHum:FindFirstChild(n), hum:FindFirstChild(n)
            if sv and mv then pcall(function() mv.Value = sv.Value end) end
        end
    end
    -- аксессуары через Humanoid:AddAccessory (надёжные вельды)
    local accCount = 0
    for _, acc in ipairs(model:GetChildren()) do
        if acc:IsA("Accessory") then
            equipAccessory(char, hum, acc)
            accCount += 1
        end
    end
    -- звуки скина (Dead/Hit/StunSound/Steps)
    local sndCount = 0
    local skinTorso = model:FindFirstChild("UpperTorso")
    local myTorso = char:FindFirstChild("UpperTorso")
    if skinTorso and myTorso then
        for _, s in ipairs(skinTorso:GetChildren()) do
            if s:IsA("Sound") and SKIN_SOUND_NAMES[s.Name] then
                s:Clone().Parent = myTorso
                sndCount += 1
            end
        end
    end
    -- если дрон скрывал тело — прячем и новые аксессуары
    if activeDrone and myHead then
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local h = acc:FindFirstChild("Handle")
                if h and h:IsA("BasePart") then
                    h.Transparency = 1
                    h.LocalTransparencyModifier = 1
                end
            end
        end
    end
    morphAppliedKey = cat .. "/" .. name
    if not silent then
        notify("Скины", name .. " применён (" .. accCount .. " акс., " .. sndCount .. " звука)", 3)
    end
    return true
end

local flyActive = false
local flyConn = nil
local function setFly(state)
    flyActive = state
    local root = getRoot()
    if not root then
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        return
    end
    local oldBV = root:FindFirstChild("TWKS_FlyBV"); if oldBV then oldBV:Destroy() end
    local oldBG = root:FindFirstChild("TWKS_FlyBG"); if oldBG then oldBG:Destroy() end
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if not state then return end
    -- БАГФИКС: 1e5 не тянуло тяжёлого перса/дрон — ставим 9e9 как в IY
    local bv = new("BodyVelocity", { Name = "TWKS_FlyBV", MaxForce = Vector3.new(9e9,9e9,9e9) }, root)
    local bg = new("BodyGyro", { Name = "TWKS_FlyBG", MaxTorque = Vector3.new(9e9,9e9,9e9), P = 10000 }, root)
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive or not root.Parent then
            bv:Destroy(); bg:Destroy()
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            return
        end
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        bv.Velocity = move * 120
        bg.CFrame = Camera.CFrame
    end)
end

local activeDrone, dronePart, droneWeld, droneSound = nil, nil, nil, nil
local droneConfig = {
    shahed = { mesh = SHAHED_MESH, texture = nil, sound = SHAHED_SOUND,
        scale = 1.5, rotX = -177, rotY = 87,  rotZ = 0,  offsetY = -1.4 },
    fpv    = { mesh = FPV_MESH,    texture = FPV_TEXTURE, sound = FPV_SOUND,
        scale = 3,   rotX = 3,    rotY = 176, rotZ = -1, offsetY = -1.4 },
}
local hiddenParts = {}

local function hideBody(char)
    hiddenParts = {}
    for _, v in ipairs(char:GetDescendants()) do
        if v.Name ~= "TWKS_Drone" and v.Name ~= "TWKS_DroneMesh" then
            if v:IsA("BasePart") then
                hiddenParts[v] = { trans = v.Transparency, ltm = v.LocalTransparencyModifier }
                v.Transparency = 1; v.LocalTransparencyModifier = 1
            elseif v:IsA("Decal") or v:IsA("Texture") then
                hiddenParts[v] = { trans = v.Transparency }
                v.Transparency = 1
            end
        end
    end
    local hd = char:FindFirstChild("Head")
    if hd then
        for _, c in ipairs(hd:GetChildren()) do
            if c:IsA("BillboardGui") then
                hiddenParts[c] = { enabled = c.Enabled }; c.Enabled = false
            end
        end
    end
end

local function showBody()
    for obj, data in pairs(hiddenParts) do
        if obj and obj.Parent then
            if data.trans ~= nil then obj.Transparency = data.trans end
            if data.ltm ~= nil and obj:IsA("BasePart") then obj.LocalTransparencyModifier = data.ltm end
            if data.enabled ~= nil and obj:IsA("BillboardGui") then obj.Enabled = data.enabled end
        end
    end
    hiddenParts = {}
end

local function destroyDrone()
    local char = getChar()
    if char then
        local d = char:FindFirstChild("TWKS_Drone")
        if d then d:Destroy() end
        showBody()
    end
    droneSound = nil
    dronePart = nil
    droneWeld = nil
    activeDrone = nil
end

local function buildDrone(kind)
    if not kind then return end
    local cfg = droneConfig[kind]; if not cfg then return end
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    destroyDrone()

    local part = Instance.new("Part")
    part.Name = "TWKS_Drone"
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = false; part.CanCollide = false; part.Massless = true
    part.Transparency = 0; part.LocalTransparencyModifier = 0
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(220, 220, 220)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = char

    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "TWKS_DroneMesh"
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = cfg.mesh
    if cfg.texture then mesh.TextureId = cfg.texture end
    mesh.Scale = Vector3.new(cfg.scale, cfg.scale, cfg.scale)
    mesh.Parent = part

    local weld = Instance.new("Weld")
    weld.Name = "TWKS_DroneWeld"
    weld.Part0 = root; weld.Part1 = part
    weld.C1 = CFrame.new()
    weld.C0 = CFrame.new(0, cfg.offsetY, 0)
        * CFrame.Angles(math.rad(cfg.rotX), math.rad(cfg.rotY), math.rad(cfg.rotZ))
    weld.Parent = part

    if cfg.sound then
        local snd = Instance.new("Sound")
        snd.Name = "TWKS_DroneSound"
        snd.SoundId = cfg.sound
        snd.Looped = true
        snd.Volume = 1
        snd.RollOffMaxDistance = 200
        snd.RollOffMinDistance = 5
        snd.Parent = part
        snd:Play()
        droneSound = snd
    end

    dronePart = part
    droneWeld = weld
    hideBody(char)
    activeDrone = kind
    setFly(true)
end

local PlayerPage = createTab("Player", 1)
makeSection(PlayerPage, "ДВИЖЕНИЕ", 1)
local noclipActive = false
local noclipCtrl = makeToggle(PlayerPage, "Noclip", false, function(v)
    noclipActive = v
    -- БАГФИКС: при выключении возвращаем коллизию (раньше оставался noclip до реса)
    if not v then
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end, 2)
makeToggle(PlayerPage, "Полёт (WASD + Space/Ctrl)", false, function(v) setFly(v) end, 3)
local spinActive = false
makeToggle(PlayerPage, "Spinbot", false, function(v) spinActive = v end, 4)
local infJump = false
makeToggle(PlayerPage, "Infinite Jump", false, function(v) infJump = v end, 5)
local invisActive = false
makeToggle(PlayerPage, "Invisible", false, function(v)
    invisActive = v
    local char = getChar(); if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "TWKS_Drone" then
            p.LocalTransparencyModifier = v and 1 or 0
        end
    end
end, 6)

makeSection(PlayerPage, "СКОРОСТЬ / ПРЫЖОК", 7)
local desiredWalkSpeed, desiredJumpPower = 16, 50
local speedEnforce, jumpEnforce = false, false
local function applySpeed(hum)
    if not hum then return end
    if speedEnforce then
        pcall(function() hum.WalkSpeed = desiredWalkSpeed end)
    end
    if jumpEnforce then
        pcall(function()
            -- покрываем оба режима: UseJumpPower и JumpHeight
            hum.JumpPower = desiredJumpPower
            hum.JumpHeight = desiredJumpPower * 0.144
        end)
    end
end
makeSlider(PlayerPage, "Скорость ходьбы", 0, 250, 16, function(v)
    desiredWalkSpeed = v
    speedEnforce = true
    applySpeed(getHum())
end, 8, "")
makeSlider(PlayerPage, "Сила прыжка", 0, 300, 50, function(v)
    desiredJumpPower = v
    jumpEnforce = true
    applySpeed(getHum())
end, 9, "")
makeButton(PlayerPage, "Сбросить скорость/прыжок", function()
    desiredWalkSpeed, desiredJumpPower = 16, 50
    speedEnforce, jumpEnforce = false, false
    local hum = getHum()
    if hum then
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function() hum.JumpPower = 50; hum.JumpHeight = 7.2 end)
    end
    notify("Player", "Скорость и прыжок сброшены", 2)
end, 10)

makeSection(PlayerPage, "ВЫЖИВАНИЕ", 11)
local godmodeOn = false
makeToggle(PlayerPage, "Бессмертие (реген HP + анти-стан)", false, function(v)
    godmodeOn = v
    if v then
        notify("Player", "Бессмертие вкл: держу HP + снимаю стан", 2)
    end
end, 12)
local defenseOn = false
local defenseRadius = 14
local lastDefense = 0
makeToggle(PlayerPage, "Авто-защита: флингать Сахарка рядом", false, function(v)
    defenseOn = v
    if v then
        notify("Player", "Защита вкл: Сахарок близко = отлетает", 3)
    end
end, 13)
makeSlider(PlayerPage, "Радиус защиты", 6, 30, 14, function(v)
    defenseRadius = v
end, 14, "")

-- авто-защита: Сахарок подошёл близко — улетает шляпой (реальное
-- "не сможет убить": удар лома не проходит, если бьющего сносит)
task.spawn(function()
    while task.wait(0.5) do
        if defenseOn and not flingBusy and not killTpActive and not amICaxarok() then
            local myRoot = getRoot()
            if myRoot and myRoot.Parent and inRound(LocalPlayer) then
                local now = tick()
                if now - lastDefense > 4 then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if isCaxarok(plr) and plr.Character then
                            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            if tr and tr.Parent and hum and hum.Health > 0 then
                                if (tr.Position - myRoot.Position).Magnitude <= defenseRadius then
                                    lastDefense = now
                                    task.spawn(doHatFling, plr, 1.6)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

makeSection(PlayerPage, "ТЕГИ", 15)
makeToggle(PlayerPage, "Разноцветный тег над всеми", false, function(v)
    tagsEnabled = v; updateTags()
end, 16)

local VisualPage = createTab("Visual", 2)
makeSection(VisualPage, "ESP", 1)
makeToggle(VisualPage, "Игроки (зелёный)", false, function(v) espPlayers = v; refreshAll() end, 2)
makeToggle(VisualPage, "Сахарок (красный)", false, function(v) espCaxapok = v; refreshAll() end, 3)

makeSection(VisualPage, "ПРЕДМЕТЫ", 4)
makeToggle(VisualPage, "Ключи", false, function(v) espKeys = v; refreshItemESP() end, 5)
makeToggle(VisualPage, "Лом", false, function(v) espLom = v; refreshItemESP() end, 6)
makeToggle(VisualPage, "Механизмы (шестерни, провода)", false, function(v) espMech = v; refreshItemESP() end, 7)
makeToggle(VisualPage, "Спрей / таблетки", false, function(v) espMisc = v; refreshItemESP() end, 8)
makeToggle(VisualPage, "Выход", false, function(v) espExit = v; refreshItemESP() end, 9)

local TrollPage = createTab("Troll", 3)
makeSection(TrollPage, "FLING", 1)

makeButton(TrollPage, "Флингануть Сахарка", function()
    local found = false
    for _, p in ipairs(Players:GetPlayers()) do
        if isCaxarok(p) then
            found = true
            task.spawn(doFling, p)
        end
    end
    if not found then notify("Troll", "Сахарок не найден", 2) end
end, 2)

walkFlingCtrl = makeToggle(TrollPage, "WalkFling (бег в толпу)", false, function(v)
    if flingBusy then notify("Fling", "Дождись конца таргет-флинга", 2); walkFlingCtrl.setState(false, true); return end
    if v then startWalkFling() else stopWalkFling() end
end, 3)

spinFlingCtrl = makeToggle(TrollPage, "SpinFling (крутилка телом)", false, function(v)
    if flingBusy then notify("Fling", "Дождись конца таргет-флинга", 2); spinFlingCtrl.setState(false, true); return end
    if v then startSpinFling() else stopSpinFlingCleanup() end
end, 4)

makeSection(TrollPage, "ИГРОКИ", 4)

local PlayersListFrame = new("Frame", {
    Size = UDim2.new(1, 0, 0, 420), BackgroundColor3 = BG_CARD,
    BorderSizePixel = 0, LayoutOrder = 5, ZIndex = 7,
}, TrollPage)
corner(8, PlayersListFrame)
stroke(BORDER, 1, 0.3, PlayersListFrame)
pad(8, 8, 8, 8, PlayersListFrame)

local topBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ZIndex = 8,
}, PlayersListFrame)
local refreshBtn = new("TextButton", {
    Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -120, 0, 0),
    BackgroundColor3 = BG_HOVER, BorderSizePixel = 0, Text = "Обновить",
    TextColor3 = TEXT, Font = FONT_B, TextSize = 12, AutoButtonColor = false, ZIndex = 8,
}, topBar)
corner(6, refreshBtn)
refreshBtn.MouseEnter:Connect(function() tween(refreshBtn, { BackgroundColor3 = ACCENT, TextColor3 = Color3.new(1,1,1) }, 0.12) end)
refreshBtn.MouseLeave:Connect(function() tween(refreshBtn, { BackgroundColor3 = BG_HOVER, TextColor3 = TEXT }, 0.12) end)

local countLbl = new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 4, 0, 0),
    BackgroundTransparency = 1, Text = "Игроков: 0", TextColor3 = TEXT_DIM,
    Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
}, topBar)

local PlayersScroll = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, PlayersListFrame)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, PlayersScroll)

local playerRowCache = {}

local function createPlayerRow(plr, order)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = BG_GLASS,
        BorderSizePixel = 0, LayoutOrder = order, ZIndex = 7,
    }, PlayersScroll)
    corner(8, row); stroke(BORDER, 1, 0.4, row)

    local avatar = new("ImageLabel", {
        Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 8, 0.5, -22),
        BackgroundColor3 = BG_CARD, BorderSizePixel = 0, ZIndex = 8,
        Image = "", BackgroundTransparency = 1,
    }, row)
    corner(22, avatar)
    local avStroke = stroke(ACCENT, 2, 0, avatar)

    new("TextLabel", {
        Size = UDim2.new(1, -200, 0, 18), Position = UDim2.new(0, 60, 0, 8),
        BackgroundTransparency = 1, Text = plr.DisplayName,
        TextColor3 = TEXT, Font = FONT_B, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, row)
    new("TextLabel", {
        Size = UDim2.new(1, -200, 0, 14), Position = UDim2.new(0, 60, 0, 24),
        BackgroundTransparency = 1, Text = "@" .. plr.Name,
        TextColor3 = TEXT_DIM, Font = FONT, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, row)
    local roleLbl = new("TextLabel", {
        Size = UDim2.new(0, 80, 0, 14), Position = UDim2.new(0, 60, 0, 38),
        BackgroundTransparency = 1, Text = "—",
        TextColor3 = TEXT_DIM, Font = FONT_B, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, row)

    local flingBtn = new("TextButton", {
        Size = UDim2.new(0, 55, 0, 24), Position = UDim2.new(1, -125, 0.5, -13),
        BackgroundColor3 = BG_HOVER, BorderSizePixel = 0, Text = "Флинг",
        TextColor3 = TEXT, Font = FONT_B, TextSize = 11, AutoButtonColor = false, ZIndex = 8,
    }, row)
    corner(6, flingBtn)
    flingBtn.MouseEnter:Connect(function() tween(flingBtn, { BackgroundColor3 = ACCENT, TextColor3 = Color3.new(1,1,1) }, 0.1) end)
    flingBtn.MouseLeave:Connect(function() tween(flingBtn, { BackgroundColor3 = BG_HOVER, TextColor3 = TEXT }, 0.1) end)
    flingBtn.MouseButton1Click:Connect(function()
        task.spawn(doFling, plr)
    end)

    local tpBtn = new("TextButton", {
        Size = UDim2.new(0, 55, 0, 24), Position = UDim2.new(1, -66, 0.5, -13),
        BackgroundColor3 = BG_HOVER, BorderSizePixel = 0, Text = "ТП",
        TextColor3 = TEXT, Font = FONT_B, TextSize = 11, AutoButtonColor = false, ZIndex = 8,
    }, row)
    corner(6, tpBtn)
    tpBtn.MouseEnter:Connect(function() tween(tpBtn, { BackgroundColor3 = ACCENT, TextColor3 = Color3.new(1,1,1) }, 0.1) end)
    tpBtn.MouseLeave:Connect(function() tween(tpBtn, { BackgroundColor3 = BG_HOVER, TextColor3 = TEXT }, 0.1) end)
    tpBtn.MouseButton1Click:Connect(function()
        local myRoot = getRoot()
        local tr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and tr then
            myRoot.CFrame = tr.CFrame * CFrame.new(0, 0, 1.2)
        end
    end)

    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and url then avatar.Image = url end
    end)

    task.spawn(function()
        while row.Parent and plr.Parent do
            if isCaxarok(plr) then
                roleLbl.Text = "САХАРОК"
                roleLbl.TextColor3 = ACCENT
                avStroke.Color = ACCENT
            else
                roleLbl.Text = "Выживший"
                roleLbl.TextColor3 = Color3.fromRGB(80, 255, 120)
                avStroke.Color = BORDER
            end
            task.wait(0.5)
        end
    end)

    playerRowCache[plr] = row
    return row
end

local function rebuildPlayerList()
    for plr, row in pairs(playerRowCache) do
        row:Destroy(); playerRowCache[plr] = nil
    end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            count += 1
            createPlayerRow(plr, count)
        end
    end
    countLbl.Text = "Игроков: " .. count
end

refreshBtn.MouseButton1Click:Connect(function()
    rebuildPlayerList()
end)

Players.PlayerAdded:Connect(function() task.wait(0.2); rebuildPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); rebuildPlayerList() end)
task.defer(rebuildPlayerList)

local CombatPage = createTab("Combat", 4)
makeSection(CombatPage, "АВТО-ТП КО ВСЕМ (за Сахарка)", 1)

killTpCtrl = makeToggle(CombatPage, "Авто-флинг всех шляпой (в раунде)", false, function(v)
    if v then
        if flingBusy then notify("Fling", "Дождись конца таргет-флинга", 2); killTpCtrl.setState(false, true); return end
        startKillTp()
    else
        stopKillTp()
    end
end, 2)

makeSection(CombatPage, "УБИТЬ", 3)

makeButton(CombatPage, "Зафлингать ВСЕХ по очереди", function()
    -- БАГФИКС: Health=0 с клиента не реплицируется (FE) — кнопка была пустышкой.
    -- Теперь реально флингуем всех шляпой по очереди.
    task.spawn(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and inRound(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    doHatFling(p, 1.6)
                    task.wait(0.2)
                end
            end
        end
    end)
end, 4)

makeButton(CombatPage, "Убить себя (тест)", function()
    local h = getHum(); if h then h.Health = 0 end
end, 5)

makeSection(CombatPage, "ТЕЛЕПОРТ", 6)

local tpBehind = false
makeToggle(CombatPage, "Телепорт за спину ближайшего", false, function(v) tpBehind = v end, 7)

local ModelPage = createTab("Model", 5)
makeSection(ModelPage, "ДРОНЫ", 1)
local shahedCtrl, fpvCtrl

shahedCtrl = makeToggle(ModelPage, "Shahed", false, function(v)
    if v then
        if activeDrone == "fpv" then fpvCtrl.setState(false, true) end
        buildDrone("shahed")
    else
        destroyDrone(); setFly(false)
    end
end, 2)

fpvCtrl = makeToggle(ModelPage, "FPV Kamikaze", false, function(v)
    if v then
        if activeDrone == "shahed" then shahedCtrl.setState(false, true) end
        buildDrone("fpv")
    else
        destroyDrone(); setFly(false)
    end
end, 3)

makeSection(ModelPage, "РАЗМЕР МОДЕЛЕЙ", 4)
makeSlider(ModelPage, "Размер Шахеда x10", 5, 100, 15, function(v)
    droneConfig.shahed.scale = v / 10
    if activeDrone == "shahed" and dronePart then
        local m = dronePart:FindFirstChild("TWKS_DroneMesh")
        if m then m.Scale = Vector3.new(v/10, v/10, v/10) end
    end
end, 5, "")

makeSlider(ModelPage, "Размер FPV x10", 5, 100, 30, function(v)
    droneConfig.fpv.scale = v / 10
    if activeDrone == "fpv" and dronePart then
        local m = dronePart:FindFirstChild("TWKS_DroneMesh")
        if m then m.Scale = Vector3.new(v/10, v/10, v/10) end
    end
end, 6, "")

makeSection(ModelPage, "СКАЙБОКС", 7)
local galaxyIDs = { bk="rbxassetid://159454299", dn="rbxassetid://159454296", ft="rbxassetid://159454293", lf="rbxassetid://159454286", rt="rbxassetid://159454300", up="rbxassetid://159454288" }
local dayIDs    = { bk="rbxassetid://6444884337", dn="rbxassetid://6444884785", ft="rbxassetid://6444884337", lf="rbxassetid://6444884337", rt="rbxassetid://6444884337", up="rbxassetid://6412503613" }
local nightIDs  = { bk="rbxassetid://15536110634", dn="rbxassetid://15536112543", ft="rbxassetid://15536116141", lf="rbxassetid://15536114370", rt="rbxassetid://15536118762", up="rbxassetid://15536117282" }
local function setSkybox(ids)
    local sky = Lighting:FindFirstChild("TWKS_Sky")
    if not sky then sky = new("Sky", { Name = "TWKS_Sky" }, Lighting) end
    sky.SkyboxBk = ids.bk; sky.SkyboxDn = ids.dn; sky.SkyboxFt = ids.ft
    sky.SkyboxLf = ids.lf; sky.SkyboxRt = ids.rt; sky.SkyboxUp = ids.up
end
makeButton(ModelPage, "Галактика", function() setSkybox(galaxyIDs) end, 8)
makeButton(ModelPage, "День",      function() setSkybox(dayIDs) end, 9)
makeButton(ModelPage, "Ночь",      function() setSkybox(nightIDs) end, 10)

local ScriptsPage = createTab("Scripts", 6)
makeSection(ScriptsPage, "ВНЕШНИЕ", 1)
makeButton(ScriptsPage, "Infinity Yield", function()
    local fn = loadstring or load
    fn(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end, 2)
makeButton(ScriptsPage, "All Emotes", function()
    local fn = loadstring or load
    fn(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
end, 3)
makeButton(ScriptsPage, "Wallhop", function()
    local fn = loadstring or load
    fn(game:HttpGet("https://pastebin.com/raw/jrFZf0yN"))()
end, 4)

local SkinsPage = createTab("Skins", 7)
makeSection(SkinsPage, "АВТО-СКИН САХАРКА", 1)
makeToggle(SkinsPage, "Авто-применять выбранный за Сахарка", false, function(v)
    autoSkinCaxarok = v
    if v then
        if not selectedSkinName then
            notify("Скины", "Сначала нажми на скин ниже", 3)
        elseif amICaxarok() then
            applySkin(selectedSkinCat, selectedSkinName)
        else
            notify("Скины", "Запомнил: " .. selectedSkinName .. ". Применю как станешь Сахарком", 3)
        end
    end
end, 2)
makeButton(SkinsPage, "Снять скин (вернуть свой вид)", function()
    restoreLook(false)
end, 3)

makeSection(SkinsPage, "СТАНДАРТ", 4)
do
    local order = 5
    for _, sname in ipairs(listSkinNames("Standart")) do
        local cat, nm = "Standart", sname
        makeButton(SkinsPage, nm, function()
            -- скин живёт ТОЛЬКО на Сахарке: выжившим просто запоминаем выбор
            selectedSkinCat, selectedSkinName = cat, nm
            if amICaxarok() then
                applySkin(cat, nm)
            else
                notify("Скины", "Запомнил: " .. nm .. ". Надену как станешь Сахарком", 3)
            end
        end, order)
        order += 1
    end
    makeSection(SkinsPage, "АДМИН", order)
    order += 1
    for _, sname in ipairs(listSkinNames("Admin")) do
        local cat, nm = "Admin", sname
        makeButton(SkinsPage, "[A] " .. nm, function()
            selectedSkinCat, selectedSkinName = cat, nm
            if amICaxarok() then
                applySkin(cat, nm)
            else
                notify("Скины", "Запомнил: " .. nm .. ". Надену как станешь Сахарком", 3)
            end
        end, order)
        order += 1
    end
end

-- скин только на Сахарке: стал им — надеваем, перестал — снимаем
task.spawn(function()
    while task.wait(2) do
        if selectedSkinName and not flingBusy then
            if amICaxarok() then
                if autoSkinCaxarok then
                    local key = selectedSkinCat .. "/" .. selectedSkinName
                    if morphAppliedKey ~= key then
                        applySkin(selectedSkinCat, selectedSkinName, true)
                    end
                end
            else
                if morphAppliedKey then
                    restoreLook(true)
                end
            end
        end
    end
end)

local function attachPlayer(plr)
    if plr == LocalPlayer then return end
    plr.ChildAdded:Connect(function(c)
        if c.Name == "IsCaxapok" then
            smartRefreshESP()
        end
    end)
    plr.ChildRemoved:Connect(function(c)
        if c.Name == "IsCaxapok" then smartRefreshESP() end
    end)
    plr.CharacterAdded:Connect(function()
        task.wait(0.3)
        smartRefreshESP()
        if tagsEnabled then tagCache[plr] = nil; createTag(plr) end
    end)
end
for _, plr in ipairs(Players:GetPlayers()) do attachPlayer(plr) end
Players.PlayerAdded:Connect(attachPlayer)

LocalPlayer.CharacterAdded:Connect(function()
    -- БАГФИКС: смерть/рес гасят флинг-потоки и шляпу, иначе висят мёртвые ссылки
    -- и тоглы врут (вкл, а эффекта нет)
    stopKillTp()
    stopSpinFlingCleanup()
    flingBusy = false
    syncFlingToggles()
    -- скин: новый персонаж = чистый вид, при авто-режиме наденем заново ниже
    originalLook = nil
    morphAppliedKey = nil
    task.wait(0.3)
    if espPlayers or espCaxapok then smartRefreshESP() end
    if tagsEnabled then updateTags() end
    if autoSkinCaxarok and selectedSkinName then
        task.wait(0.8)
        if amICaxarok() then
            applySkin(selectedSkinCat, selectedSkinName, true)
        end
    end
    -- БАГФИКС: полёт слетал после смерти при включённом тогле — пересоздаём
    if flyActive then
        task.wait(0.3)
        local st = true
        flyActive = false
        setFly(false)
        task.wait(0.1)
        setFly(st)
    end
    if activeDrone then
        task.wait(0.5)
        local kind = activeDrone
        activeDrone = nil
        buildDrone(kind)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        if Main.Visible then
            showMenu(false)
        else
            showMenu(true)
        end
    end
    if input.KeyCode == Enum.KeyCode.Space and infJump then
        local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local lastTpBehind = 0
RunService.RenderStepped:Connect(function()
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    -- БАГФИКС: флинг владеет CFrame единолично — spinbot/tpBehind его перебивали
    local flingLock = flingBusy or killTpActive

    -- держим скорость/прыжок (переживает рес и сбросы игрой)
    if speedEnforce or jumpEnforce then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if speedEnforce and hum.WalkSpeed ~= desiredWalkSpeed then
                pcall(function() hum.WalkSpeed = desiredWalkSpeed end)
            end
            if jumpEnforce then
                pcall(function()
                    if hum.JumpPower ~= desiredJumpPower then hum.JumpPower = desiredJumpPower end
                    local jh = desiredJumpPower * 0.144
                    if math.abs(hum.JumpHeight - jh) > 0.01 then hum.JumpHeight = jh end
                end)
            end
        end
    end

    -- БЕССМЕРТИЕ: реген HP каждый кадр (лом бьёт постепенно — успеваем
    -- залить до максимума) + снимаем стан/рагдолл с себя
    if godmodeOn then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
        if hum and hum.PlatformStand then
            pcall(function() hum.PlatformStand = false end)
        end
    end

    if noclipActive then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
    if spinActive and root and not flingLock then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(15), 0)
    end
    if invisActive and not activeDrone then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "TWKS_Drone" then
                v.LocalTransparencyModifier = 1
            end
        end
    end
    -- БАГФИКС: было каждый кадр (60 ТП/сек — рвало физику и конфликтовало
    -- с флингом). Теперь не чаще 4 раз/сек и пауза на время флинга.
    if tpBehind and root and not flingLock then
        local now = tick()
        if now - lastTpBehind > 0.25 then
            lastTpBehind = now
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0,0,1.2); break end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if tagsEnabled then updateTags() end
    end
end)

Main.Size = UDim2.new(0, 640, 0, 0)
MainShadow.Size = UDim2.new(0, 640, 0, 0)
SnowGui.Enabled = true
tween(Main, { Size = UDim2.new(0, 640, 0, 470) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
tween(MainShadow, { Size = UDim2.new(0, 640, 0, 470) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

switchTab("Troll")
notify("D3ATH 0.1 beta", "K — скрыть меню", 4)