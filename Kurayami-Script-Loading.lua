local======================================================
--  Kurayami-Hub | Loading Screen v14 — Fixed Music + Particles ☠️🎵
--  Music fix: แยก pcall TimePosition / Play()  •  รอ IsLoaded
--============================================================
local TweenService    = game:GetService("TweenService")
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService    = game:GetService("SoundService")

local plr       = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

--============================================================
--  HELPERS
--============================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, p) end
local function circle(p) return new("UICorner", {CornerRadius = UDim.new(1, 0)}, p) end
local function stroke(p, c, t, tr)
    return new("UIStroke", {Color = c, Thickness = t, Transparency = tr or 0}, p)
end
local function tween(o, t, p, s, d)
    local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p)
    tw:Play(); return tw
end
local function randHex(n)
    local s = ""
    for i = 1, n do s = s .. string.format("%X", math.random(0, 15)) end
    return s
end

for _, n in ipairs({"KurayamiLoader", "KurayamiPreload"}) do
    local o = playerGui:FindFirstChild(n)
    if o then o:Destroy() end
end

--============================================================
--  MUSIC SYSTEM
--============================================================
local MUSIC_ID         = "rbxassetid://89610760702249"   -- STEREO LOVE
local MUSIC_VOLUME     = 0.67
local MUSIC_FADE_IN    = 0.1
local MUSIC_FADE_OUT   = 0.1
local MUSIC_START_TIME = 15    -- ⭐ ลอง 0 ก่อน

local music = Instance.new("Sound")
music.Name = "KurayamiMusic"
music.SoundId = MUSIC_ID
music.Volume = 0
music.Looped = true
music.PlayOnRemove = false
music.Parent = SoundService

--============================================================
--  PRE-NOTIFY
--============================================================
local preGui = new("ScreenGui", {
    Name = "KurayamiPreload", IgnoreGuiInset = true,
    ResetOnSpawn = false, DisplayOrder = 9100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local preBox = new("Frame", {
    Size = UDim2.new(0, 280, 0, 48),
    Position = UDim2.new(0.5, 0, 1, -70),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
    BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 1,
}, preGui)
corner(preBox, 24)
stroke(preBox, Color3.fromRGB(90, 90, 90), 1, 0.35)

local preSpinner = new("Frame", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 14, 0.5, -13),
    BackgroundTransparency = 1, ZIndex = 2,
}, preBox)
circle(preSpinner)
local preSpinStroke = stroke(preSpinner, Color3.fromRGB(230, 230, 230), 2, 0.25)
local preSpinGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40)),
    }),
}, preSpinStroke)
TweenService:Create(preSpinGrad,
    TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Rotation = 360 }
):Play()

new("TextLabel", {
    Size = UDim2.new(1, -55, 0, 16), Position = UDim2.new(0, 50, 0, 8),
    BackgroundTransparency = 1, Text = "Kurayami-Hub",
    TextColor3 = Color3.fromRGB(235, 235, 235),
    Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
}, preBox)

local preSub = new("TextLabel", {
    Size = UDim2.new(1, -55, 0, 14), Position = UDim2.new(0, 50, 0, 25),
    BackgroundTransparency = 1, Text = "Loading assets, please wait",
    TextColor3 = Color3.fromRGB(135, 135, 135),
    Font = Enum.Font.Gotham, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
}, preBox)

task.spawn(function()
    local dots = {"", ".", "..", "..."}
    local i = 1
    while preGui.Parent do
        preSub.Text = "Loading assets" .. dots[i] .. " please wait"
        i = i % 4 + 1
        task.wait(0.35)
    end
end)

preBox.Position = UDim2.new(0.5, 0, 1, -20)
tween(preBox, 0.45, { Position = UDim2.new(0.5, 0, 1, -70) }, Enum.EasingStyle.Back)
task.wait(0.1)

--============================================================
--  CUSTOM ASSETS
--============================================================
local function loadCustomAsset(url, filename)
    local ok, data = pcall(function() return game:HttpGet(url) end)
    if not ok or not data or type(data) ~= "string" or #data < 100 then return nil end
    local writeOk = pcall(function() writefile(filename, data) end)
    if not writeOk then return nil end
    local assetOk, asset = pcall(function() return getcustomasset(filename) end)
    if assetOk and asset and type(asset) == "string" then return asset end
    return nil
end

local BG_IMG = loadCustomAsset(
    "https://raw.githubusercontent.com/Kur4yami2/Kurayami-Hub-Script/refs/heads/main/media_1790369776.png",
    "kurayami_bg.png"
)
local ICON_IMG = loadCustomAsset(
    "https://raw.githubusercontent.com/Kur4yami2/Kurayami-Hub-Script/refs/heads/main/media_1790369629.png",
    "kurayami_icon.png"
)

--============================================================
--  CONFIG / THEME
--============================================================
local CONFIG = {
    ScriptURL    = "https://raw.githubusercontent.com/Kur4yami2/Kurayami-Hub-Script/refs/heads/main/Kurayami-Script-GUI.lua",
    MinDuration  = 8.0,
    DisplayOrder = 1000,          -- ⬅ 9000 → 1000 (ให้เมนูทับหน้าโหลด)
    AutoLoad     = true,          -- ⬅ false → true (ให้โหลด K42 อัตโนมัติ)
}

local C = {
    Bg           = Color3.fromRGB(8, 8, 8),
    BgSoft       = Color3.fromRGB(14, 14, 14),
    Border       = Color3.fromRGB(42, 42, 42),
    BorderLight  = Color3.fromRGB(90, 90, 90),
    BorderBright = Color3.fromRGB(230, 230, 230),
    Text         = Color3.fromRGB(235, 235, 235),
    TextDim      = Color3.fromRGB(135, 135, 135),
    Accent       = Color3.new(1, 1, 1),
    Green        = Color3.fromRGB(100, 200, 120),
    Red          = Color3.fromRGB(255, 60, 60),
    Blue         = Color3.fromRGB(60, 140, 255),
    BackgroundImage = BG_IMG,
    LogoImage       = ICON_IMG,
    Title           = "Kurayami-Hub",
    Subtitle        = "v18   •   By Kur4yami2",
}

--============================================================
--  ROOT
--============================================================
local gui = new("ScreenGui", {
    Name = "KurayamiLoader", IgnoreGuiInset = true,
    ResetOnSpawn = false, DisplayOrder = 1000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local bg = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.Bg,
    BorderSizePixel = 0, ZIndex = 1,
}, gui)
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.BgSoft),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 3)),
    }),
}, bg)

local bgImg = nil
if BG_IMG then
    bgImg = new("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = BG_IMG,
        ImageTransparency = 0.40,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 2,
    }, gui)
end

--============================================================
--  MATRIX RAIN
--============================================================
local rainCols = {}
for i = 1, 12 do
    local col = new("TextLabel", {
        Size = UDim2.new(0, 20, 0, 400),
        Position = UDim2.new((i - 0.5) / 12, 0, 0, -400),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = Color3.fromRGB(80, 80, 80),
        Font = Enum.Font.Code, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTransparency = 0.75,
        ZIndex = 4,
    }, gui)
    local chars = {}
    for j = 1, 40 do table.insert(chars, tostring(math.random(0, 9))) end
    col.Text = table.concat(chars, "\n")
    rainCols[i] = { obj = col, speed = 60 + math.random(0, 80), y = -400 }
end

--============================================================
--  AMBIENT PARTICLES  (ZIndex 12 — เหนือ vignette)
--============================================================
local ambientParticles = {}
local AMBIENT_COUNT = 45
for i = 1, AMBIENT_COUNT do
    local size = math.random(3, 6)
    local p = new("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = math.random(40, 70) / 100,
        BorderSizePixel = 0,
        ZIndex = 12,
    }, gui)
    circle(p)
    local g = stroke(p, Color3.fromRGB(255, 255, 255), 1, 0.85)

    ambientParticles[i] = {
        obj = p,
        vy = -(math.random(8, 25) / 1000),
        vx = (math.random(-8, 8) / 2000),
        phase = math.random(0, 360),
        glow = g,
    }
end

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end
    for _, a in ipairs(ambientParticles) do
        local pos = a.obj.Position
        local ny = pos.Y.Scale + a.vy * dt
        local nx = pos.X.Scale + math.sin(math.rad(a.phase)) * a.vx * dt
        a.phase = a.phase + 30 * dt
        if ny < -0.05 then ny = 1.05 end
        if nx < -0.05 then nx = 1.05 end
        if nx > 1.05 then nx = -0.05 end
        a.obj.Position = UDim2.new(nx, 0, ny, 0)
        a.obj.BackgroundTransparency = 0.45 + math.sin(math.rad(a.phase)) * 0.15
    end
end)

--============================================================
--  EXTRA FLOATING DOTS
--============================================================
local floatDots = {}
for i = 1, 20 do
    local size = math.random(2, 5)
    local x, y
    if math.random() > 0.5 then
        x = math.random(0, 20) / 100
        if math.random() > 0.5 then x = 1 - x end
        y = math.random(10, 90) / 100
    else
        x = math.random(10, 90) / 100
        y = math.random(0, 20) / 100
        if math.random() > 0.5 then y = 1 - y end
    end
    local p = new("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(x, 0, y, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = math.random(50, 80) / 100,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, gui)
    circle(p)
    floatDots[i] = {
        obj = p,
        baseX = x, baseY = y,
        phase = math.random(0, 360),
        amp = math.random(5, 15) / 1000,
        speed = math.random(20, 50) / 100,
    }
end

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end
    for _, f in ipairs(floatDots) do
        f.phase = f.phase + f.speed * dt * 60
        local offX = math.sin(math.rad(f.phase)) * f.amp
        local offY = math.cos(math.rad(f.phase * 0.7)) * f.amp
        f.obj.Position = UDim2.new(f.baseX + offX, 0, f.baseY + offY, 0)
        f.obj.BackgroundTransparency = 0.55 + math.sin(math.rad(f.phase)) * 0.2
    end
end)

--============================================================
--  EDGE PARTICLES
--============================================================
local edgeParticles = {}
local EDGE_COUNT = 6
for side = 1, 4 do
    for i = 1, EDGE_COUNT do
        local size = math.random(3, 6)
        local p = new("Frame", {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = C.BorderBright,
            BackgroundTransparency = math.random(20, 50) / 100,
            BorderSizePixel = 0,
            ZIndex = 13,
        }, gui)
        circle(p)
        local prog = (i - 1) / EDGE_COUNT
        edgeParticles[#edgeParticles + 1] = {
            obj = p, side = side, prog = prog,
            speed = 0.04 + math.random(0, 25) / 1000,
        }
    end
end

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end
    for _, e in ipairs(edgeParticles) do
        e.prog = e.prog + e.speed * dt
        if e.prog > 1 then e.prog = 0 end

        local pos
        if e.side == 1 then
            pos = UDim2.new(e.prog, 0, 0, 0)
        elseif e.side == 2 then
            pos = UDim2.new(1, -e.obj.AbsoluteSize.X, e.prog, 0)
        elseif e.side == 3 then
            pos = UDim2.new(1 - e.prog, -e.obj.AbsoluteSize.X, 1, -e.obj.AbsoluteSize.Y)
        else
            pos = UDim2.new(0, 0, 1 - e.prog, -e.obj.AbsoluteSize.Y)
        end
        e.obj.Position = pos
    end
end)

--============================================================
--  HUD CORNER BRACKETS
--============================================================
local function bracket(x, y, sx, sy)
    local wrap = new("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(x, 0, y, 0),
        AnchorPoint = Vector2.new(x, y),
        BackgroundTransparency = 1, ZIndex = 15,
    }, gui)
    local h = new("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, sy == 0 and 0 or 1, sy == 0 and 0 or -2),
        BackgroundColor3 = C.BorderBright,
        BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 15,
    }, wrap)
    local v = new("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(sx == 0 and 0 or 1, sx == 0 and 0 or -2, 0, 0),
        BackgroundColor3 = C.BorderBright,
        BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 15,
    }, wrap)
    return h, v
end

local brackets = {}
for _, pos in ipairs({
    {0, 0, 0, 0}, {1, 0, 1, 0}, {0, 1, 0, 1}, {1, 1, 1, 1}
}) do
    local h, v = bracket(pos[1], pos[2], pos[3], pos[4])
    table.insert(brackets, h); table.insert(brackets, v)
end

task.spawn(function()
    while gui.Parent do
        for _, b in ipairs(brackets) do
            tween(b, 1.2, { BackgroundTransparency = 0.85 }, Enum.EasingStyle.Sine)
        end
        task.wait(1.2)
        for _, b in ipairs(brackets) do
            tween(b, 1.2, { BackgroundTransparency = 0.4 }, Enum.EasingStyle.Sine)
        end
        task.wait(1.2)
    end
end)

--============================================================
--  WARNING HEADER
--============================================================
local warnLbl = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0.5, 0, 0, 14),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    Text = "[ SECURE CONNECTION ESTABLISHED ]",
    TextColor3 = C.BorderBright,
    Font = Enum.Font.Code, TextSize = 11,
    TextTransparency = 0.3, ZIndex = 15,
}, gui)

task.spawn(function()
    while gui.Parent do
        tween(warnLbl, 0.15, { TextTransparency = 0.9 })
        task.wait(0.3)
        tween(warnLbl, 0.15, { TextTransparency = 0.3 })
        task.wait(1.4)
    end
end)

--============================================================
--  SIDE DATA STREAMS
--============================================================
local function makeStream(xPos)
    return new("TextLabel", {
        Size = UDim2.new(0, 60, 0, 100),
        Position = UDim2.new(xPos, 0, 0.5, 0),
        AnchorPoint = Vector2.new(xPos, 0.5),
        BackgroundTransparency = 1, Text = "",
        TextColor3 = Color3.fromRGB(80, 80, 80),
        Font = Enum.Font.Code, TextSize = 9,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 11,
    }, gui)
end

local streams = { makeStream(0.02), makeStream(0.98) }
task.spawn(function()
    while gui.Parent do
        for _, s in ipairs(streams) do
            local lines = {}
            for i = 1, 8 do table.insert(lines, randHex(4)) end
            s.Text = table.concat(lines, "\n")
        end
        task.wait(0.35)
    end
end)

--============================================================
--  VIGNETTE
--============================================================
local vignette = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 8,
}, gui)
new("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 0),
    }),
}, vignette)

--============================================================
--  SCANLINE
--============================================================
local scanline = new("Frame", {
    Size = UDim2.new(1, 0, 0, 80),
    Position = UDim2.new(0, 0, -0.2, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 9,
}, gui)
new("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    }),
}, scanline)

task.spawn(function()
    while gui.Parent do
        scanline.Position = UDim2.new(0, 0, -0.2, 0)
        tween(scanline, 4, { Position = UDim2.new(0, 0, 1.2, 0) }, Enum.EasingStyle.Linear)
        task.wait(4)
    end
end)

--============================================================
--  GLITCH FLASH
--============================================================
task.spawn(function()
    while gui.Parent do
        task.wait(math.random(3, 6))
        local flash = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = C.BorderBright,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0, ZIndex = 40,
        }, gui)
        tween(flash, 0.05, { BackgroundTransparency = 0.7 })
        task.wait(0.05)
        flash:Destroy()
    end
end)

--============================================================
--  LAYOUT ANCHOR
--============================================================
local cx, cy = 0.5, 0.5
local LOGO_Y, TITLE_Y, BAR_Y, STATUS_Y, SUBTITLE_Y = -30, 50, 100, 115, 144
local logoSize = 100
local barW, barH = 280, 4

--============================================================
--  LOGO STACK
--============================================================
local glowStack = new("Frame", {
    Size = UDim2.new(0, logoSize + 60, 0, logoSize + 60),
    Position = UDim2.new(cx, 0, cy, LOGO_Y),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, ZIndex = 16,
}, gui)

local glowLayers = {}
for i = 1, 3 do
    local layer = new("Frame", {
        Size = UDim2.new(0, logoSize + i * 18, 0, logoSize + i * 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, ZIndex = 16,
    }, glowStack)
    circle(layer)
    glowLayers[i] = stroke(layer, C.Accent, 2, 0.55 + i * 0.12)
end

local orbit = {}
for i = 1, 8 do
    local p = new("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, BackgroundTransparency = 0.2, ZIndex = 15,
    }, glowStack)
    circle(p)
    orbit[i] = {
        obj = p, angle = (i - 1) * 45,
        speed = 0.7 + i * 0.06, radius = 78 + (i % 3) * 6,
    }
end

RunService.RenderStepped:Connect(function(dt)
    for _, o in ipairs(orbit) do
        o.angle = o.angle + o.speed * dt * 60
        local r = math.rad(o.angle)
        o.obj.Position = UDim2.new(0.5, math.cos(r) * o.radius, 0.5, math.sin(r) * o.radius)
        o.obj.BackgroundTransparency = 0.3 + math.sin(r * 2) * 0.2
    end
end)

local arcs = {}
for i = 1, 4 do
    local arc = new("Frame", {
        Size = UDim2.new(0, 120, 0, 1),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.BorderBright,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0, ZIndex = 17,
    }, glowStack)
    arcs[i] = { obj = arc, angle = i * 90 }
end

task.spawn(function()
    while gui.Parent do
        for _, a in ipairs(arcs) do
            a.angle = math.random(0, 360)
            a.obj.Rotation = a.angle
            a.obj.Size = UDim2.new(0, math.random(50, 110), 0, 1)
            a.obj.Position = UDim2.new(
                0.5,
                math.cos(math.rad(a.angle)) * 70,
                0.5,
                math.sin(math.rad(a.angle)) * 70
            )
            a.obj.BackgroundTransparency = math.random(30, 90) / 100
        end
        task.wait(math.random(20, 60) / 100)
    end
end)

task.spawn(function()
    while gui.Parent do
        task.wait(math.random(15, 30) / 10)
        for i = 1, 10 do
            local spark = new("Frame", {
                Size = UDim2.new(0, 3, 0, 3),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = C.BorderBright,
                BorderSizePixel = 0, ZIndex = 17,
            }, glowStack)
            circle(spark)
            local angle = math.random(0, 360)
            local dist = math.random(80, 130)
            local tx = math.cos(math.rad(angle)) * dist
            local ty = math.sin(math.rad(angle)) * dist
            tween(spark, 0.6, {
                Position = UDim2.new(0.5, tx, 0.5, ty),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 1, 0, 1),
            })
            task.delay(0.6, function() if spark then spark:Destroy() end end)
        end
    end
end)

local ringBox = new("Frame", {
    Size = UDim2.new(0, logoSize + 34, 0, logoSize + 34),
    Position = UDim2.new(cx, 0, cy, LOGO_Y),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, ZIndex = 18,
}, gui)
circle(ringBox)
local ringStroke = stroke(ringBox, C.BorderBright, 2, 0.15)
local ringGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 40, 40)),
    }),
}, ringStroke)
TweenService:Create(ringGrad,
    TweenInfo.new(3.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Rotation = 360 }
):Play()

local ringInner = new("Frame", {
    Size = UDim2.new(0, logoSize + 18, 0, logoSize + 18),
    Position = UDim2.new(cx, 0, cy, LOGO_Y),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, ZIndex = 19,
}, gui)
circle(ringInner)
local ringInnerStroke = stroke(ringInner, C.Border, 1.5, 0.3)
TweenService:Create(ringInnerStroke,
    TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.9, Thickness = 3 }
):Play()

local logoDisc = new("Frame", {
    Size = UDim2.new(0, logoSize, 0, logoSize),
    Position = UDim2.new(cx, 0, cy, LOGO_Y),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Bg,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0, ZIndex = 20,
}, gui)
circle(logoDisc)
stroke(logoDisc, C.BorderLight, 1.5, 0.2)

if ICON_IMG then
    local logoImg = new("ImageLabel", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = ICON_IMG, ScaleType = Enum.ScaleType.Crop, ZIndex = 21,
    }, logoDisc)
    circle(logoImg)
    TweenService:Create(logoImg,
        TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Size = UDim2.new(1, -18, 1, -18) }
    ):Play()
end

--============================================================
--  CHROMATIC TITLE
--============================================================
local titleGhostR = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(cx, 0, cy, TITLE_Y),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1, Text = C.Title,
    TextColor3 = C.Red,
    Font = Enum.Font.GothamBold, TextSize = 26,
    TextTransparency = 1, ZIndex = 21,
}, gui)

local titleGhostB = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(cx, 0, cy, TITLE_Y),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1, Text = C.Title,
    TextColor3 = C.Blue,
    Font = Enum.Font.GothamBold, TextSize = 26,
    TextTransparency = 1, ZIndex = 21,
}, gui)

local titleLbl = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(cx, 0, cy, TITLE_Y),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1, Text = C.Title,
    TextColor3 = C.Text,
    Font = Enum.Font.GothamBold, TextSize = 26,
    TextTransparency = 1, ZIndex = 22,
}, gui)

task.spawn(function()
    while gui.Parent do
        task.wait(math.random(15, 40) / 10)
        for i = 1, 4 do
            local ox = math.random(-4, 4)
            local oy = math.random(-2, 2)
            titleGhostR.Position = UDim2.new(cx, -ox, cy, TITLE_Y + oy)
            titleGhostB.Position = UDim2.new(cx, ox, cy, TITLE_Y - oy)
            titleGhostR.TextTransparency = math.random(10, 40) / 100
            titleGhostB.TextTransparency = math.random(10, 40) / 100
            task.wait(0.03)
        end
        titleGhostR.TextTransparency = 1
        titleGhostB.TextTransparency = 1
        titleGhostR.Position = UDim2.new(cx, 0, cy, TITLE_Y)
        titleGhostB.Position = UDim2.new(cx, 0, cy, TITLE_Y)
    end
end)

--============================================================
--  BAR + %
--============================================================
local barBg = new("Frame", {
    Size = UDim2.new(0, barW, 0, barH),
    Position = UDim2.new(cx, -24, cy, BAR_Y),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(24, 24, 24),
    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 22,
}, gui)
corner(barBg, barH/2)

local barFill = new("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.BorderBright,
    BorderSizePixel = 0, ZIndex = 23,
}, barBg)
corner(barFill, barH/2)

local shine = new("Frame", {
    Size = UDim2.new(0.35, 0, 1, 0),
    Position = UDim2.new(-0.4, 0, 0, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 24,
}, barFill)
new("UIGradient", {
    Rotation = 0,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    }),
}, shine)

local percentLbl = new("TextLabel", {
    Size = UDim2.new(0, 70, 0, 16),
    Position = UDim2.new(cx, 126, cy, BAR_Y),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1, Text = "0%",
    TextColor3 = C.Text,
    Font = Enum.Font.Code, TextSize = 13,
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
}, gui)

--============================================================
--  STATUS + SUBTITLE + FOOTER
--============================================================
local statusLbl = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(cx, 0, cy, STATUS_Y),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1, Text = "",
    TextColor3 = C.TextDim,
    Font = Enum.Font.Code, TextSize = 12,
    TextTransparency = 1, ZIndex = 22,
}, gui)

local typingTask = nil
local function typeStatus(text)
    if typingTask then task.cancel(typingTask) end
    typingTask = task.spawn(function()
        statusLbl.Text = ""
        for i = 1, #text do
            statusLbl.Text = text:sub(1, i)
            task.wait(0.018)
        end
    end)
end

local subtitleLbl = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(cx, 0, cy, SUBTITLE_Y),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1, Text = C.Subtitle,
    TextColor3 = C.TextDim,
    Font = Enum.Font.Gotham, TextSize = 16,
    TextTransparency = 1, ZIndex = 22,
}, gui)

local tickerLbl = new("TextLabel", {
    Size = UDim2.new(0, 200, 0, 14),
    Position = UDim2.new(0, 20, 1, -26),
    BackgroundTransparency = 1, Text = "",
    TextColor3 = C.TextDim,
    Font = Enum.Font.Code, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 1, ZIndex = 22,
}, gui)

task.spawn(function()
    while gui.Parent do
        tickerLbl.Text = "0x" .. randHex(4) .. " :: " .. randHex(8)
        task.wait(0.15)
    end
end)

local footerLbl = new("TextLabel", {
    Size = UDim2.new(1, -40, 0, 16),
    Position = UDim2.new(1, -20, 1, -26),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Text = "kurayami-hub   •   loading assets",
    TextColor3 = C.TextDim,
    Font = Enum.Font.Gotham, TextSize = 10,
    TextTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 22,
}, gui)

--============================================================
--  INTRO ANIMATION  (เพลงเริ่มเล่นตรงนี้)
--============================================================
logoDisc.Size = UDim2.new(0, 0, 0, 0)
ringBox.Size   = UDim2.new(0, 0, 0, 0)
ringInner.Size = UDim2.new(0, 0, 0, 0)
glowStack.Size = UDim2.new(0, 0, 0, 0)
barBg.BackgroundTransparency = 1
barBg.Size = UDim2.new(0, 0, 0, barH)

local introDone = false

task.spawn(function()
    -- ⭐ เริ่มเพลง — รอ sound โหลดก่อน, แยก pcall
    task.spawn(function()
        -- รอ sound โหลด (สูงสุด 10 วิ)
        local waited = 0
        while not music.IsLoaded and waited < 10 do
            task.wait(0.1)
            waited = waited + 0.1
        end

        -- ตั้ง TimePosition แยกออกมา
        pcall(function()
            if music.TimeLength > MUSIC_START_TIME then
                music.TimePosition = MUSIC_START_TIME
            else
                warn("[Kurayami] Music too short (" .. tostring(music.TimeLength) .. "s) for StartTime " .. MUSIC_START_TIME)
            end
        end)

        -- Play แยกออกมา
        pcall(function()
            music:Play()
        end)

        -- Fade in
        task.wait(0.05)
        local steps = 10
        for i = 1, steps do
            if music and music.Parent and music.IsPlaying then
                music.Volume = MUSIC_VOLUME * (i / steps)
            end
            task.wait(MUSIC_FADE_IN / steps)
        end
    end)

    -- ปิด pre-notify
    task.spawn(function()
        tween(preBox, 0.35, { Position = UDim2.new(0.5, 0, 1, -20) })
        tween(preBox, 0.35, { BackgroundTransparency = 1 })
        task.wait(0.4)
        preGui:Destroy()
    end)

    bg.BackgroundTransparency = 1
    tween(bg, 0.5, { BackgroundTransparency = 0 })
    if bgImg then
        bgImg.ImageTransparency = 1
        tween(bgImg, 0.7, { ImageTransparency = 0.40 })
    end

    task.wait(0.15)

    tween(logoDisc, 0.55, { Size = UDim2.new(0, logoSize, 0, logoSize) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(ringBox, 0.6, { Size = UDim2.new(0, logoSize + 34, 0, logoSize + 34) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(ringInner, 0.5, { Size = UDim2.new(0, logoSize + 18, 0, logoSize + 18) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(glowStack, 0.7, { Size = UDim2.new(0, logoSize + 60, 0, logoSize + 60) },
        Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    task.wait(0.45)

    local ty0 = titleLbl.Position
    titleLbl.Position = UDim2.new(cx, 0, cy, TITLE_Y + 8)
    tween(titleLbl, 0.5, { TextTransparency = 0, Position = ty0 })

    task.spawn(function()
        for i = 1, 5 do
            titleLbl.Position = UDim2.new(cx, math.random(-3, 3), cy, TITLE_Y + math.random(-1, 1))
            task.wait(0.03)
        end
        titleLbl.Position = UDim2.new(cx, 0, cy, TITLE_Y)
    end)

    task.wait(0.15)

    tween(barBg, 0.5, { BackgroundTransparency = 0, Size = UDim2.new(0, barW, 0, barH) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.wait(0.15)
    tween(percentLbl, 0.4, { TextTransparency = 0 })
    tween(statusLbl, 0.4, { TextTransparency = 0 })
    tween(subtitleLbl, 0.4, { TextTransparency = 0 })
    tween(footerLbl, 0.4, { TextTransparency = 0 })
    tween(tickerLbl, 0.4, { TextTransparency = 0 })

    introDone = true
end)

--============================================================
--  GLOW PULSE
--============================================================
for i, s in ipairs(glowLayers) do
    task.delay((i - 1) * 0.25, function()
        TweenService:Create(s,
            TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Transparency = 0.95, Thickness = 3 }
        ):Play()
    end)
end

task.spawn(function()
    while gui.Parent do
        shine.Position = UDim2.new(-0.4, 0, 0, 0)
        tween(shine, 1.2, { Position = UDim2.new(1.05, 0, 0, 0) }, Enum.EasingStyle.Quad)
        task.wait(1.6)
    end
end)

--============================================================
--  LOADING STEPS
--============================================================
local steps = {
    { at = 0,   msg = "Initializing core..." },
    { at = 6,   msg = "Loading modules..." },
    { at = 13,  msg = "Checking dependencies..." },
    { at = 20,  msg = "Fetching remote config..." },
    { at = 28,  msg = "Verifying signature..." },
    { at = 36,  msg = "Loading UI assets..." },
    { at = 44,  msg = "Compiling shaders..." },
    { at = 52,  msg = "Preparing environment..." },
    { at = 60,  msg = "Syncing player data..." },
    { at = 68,  msg = "Loading scripts..." },
    { at = 76,  msg = "Applying theme..." },
    { at = 84,  msg = "Building interface..." },
    { at = 90,  msg = "Loading background..." },
    { at = 95,  msg = "Finalizing setup..." },
    { at = 99,  msg = "Almost there..." },
    { at = 100, msg = "Ready." },
}

task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({ BG_IMG, ICON_IMG })
    end)
end)

--============================================================
--  PROGRESS DRIVER
--============================================================
local displayProgress = 0
local startTick = tick()
local finished = false
local lastMsg = ""

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end
    for _, r in ipairs(rainCols) do
        r.y = r.y + r.speed * dt
        if r.y > 500 then
            r.y = -400
            local chars = {}
            for j = 1, 40 do table.insert(chars, math.random(0, 9)) end
            r.obj.Text = table.concat(chars, "\n")
        end
        r.obj.Position = UDim2.new(r.obj.Position.X.Scale, 0, 0, r.y)
    end
end)

RunService.RenderStepped:Connect(function()
    if not introDone or finished then return end
    local elapsed = tick() - startTick
    local raw = math.clamp(elapsed / CONFIG.MinDuration, 0, 1)
    local eased = 1 - (1 - raw) * (1 - raw)

    local progress = eased * 100
    displayProgress = displayProgress + (progress - displayProgress) * 0.25
    if math.abs(progress - displayProgress) < 0.1 then displayProgress = progress end

    local shown = math.floor(displayProgress)
    barFill.Size = UDim2.new(displayProgress / 100, 0, 1, 0)
    percentLbl.Text = shown .. "%"

    if shown < 100 then
        for i = #steps, 1, -1 do
            if shown >= steps[i].at then
                if steps[i].msg ~= lastMsg then
                    lastMsg = steps[i].msg
                    typeStatus(steps[i].msg)
                end
                break
            end
        end
    end

    if raw >= 1 and not finished then
        finished = true
        task.spawn(function()
            if typingTask then task.cancel(typingTask) end
            percentLbl.Text = "100%"
            barFill.Size = UDim2.new(1, 0, 1, 0)
            statusLbl.Text = "Loading success ✓"
            tween(statusLbl, 0.25, { TextColor3 = C.Green })
            tween(barFill, 0.3, { BackgroundColor3 = C.Green })
            tween(percentLbl, 0.3, { TextColor3 = C.Green })

            -- หลัง 1.5 วิ เปลี่ยนข้อความเป็น "Waiting for menu..."
            task.spawn(function()
                task.wait(1.5)
                if statusLbl and statusLbl.Parent then
                    statusLbl.Text = "Waiting for menu..."
                    tween(statusLbl, 0.25, { TextColor3 = C.TextDim })
                end
            end)

            -- สร้าง BindableEvent รอสัญญาณ
            local readyEvent = Instance.new("BindableEvent")
            _G.KurayamiReadyEvent = readyEvent

            local gotSignal = false
            readyEvent.Event:Connect(function()
                gotSignal = true
            end)

            -- โหลดสคริปต์หลักเบื้องหลัง (ไม่ destroy GUI)
            task.spawn(function()
                if CONFIG.AutoLoad and CONFIG.ScriptURL ~= "" then
                    local ok, err = pcall(function()
                        local code = game:HttpGet(CONFIG.ScriptURL)
                        local fn = loadstring(code)
                        if not fn then error("loadstring failed") end
                        fn()
                    end)
                    if not ok then
                        warn("[Kurayami Loader] main script error:", err)
                        task.wait(1)
                        pcall(function() readyEvent:Fire() end)
                    end
                else
                    task.wait(2)
                    pcall(function() readyEvent:Fire() end)
                end
            end)

            -- รอสัญญาณ (สูงสุด 60 วิ)
            local startWait = tick()
            while not gotSignal and tick() - startWait < 60 do
                task.wait(0.1)
            end

            -- เผื่อ delay ให้เมนูเรนเดอร์เสร็จ
            task.wait(0.4)

            -- Flash + Fade out
            local flash = new("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0, ZIndex = 50,
            }, gui)
            tween(flash, 0.15, { BackgroundTransparency = 0.85 })
            tween(flash, 0.35, { BackgroundTransparency = 1 })
            task.wait(0.5)
            flash:Destroy()

            local fadeList = { bg, vignette, scanline, glowStack, ringBox, ringInner, logoDisc,
                               titleLbl, titleGhostR, titleGhostB, subtitleLbl,
                               barBg, percentLbl, statusLbl, footerLbl, tickerLbl,
                               warnLbl, muteBtn }
            for _, o in ipairs(fadeList) do
                if o:IsA("Frame") then
                    tween(o, 0.5, { BackgroundTransparency = 1 })
                elseif o:IsA("ImageLabel") then
                    tween(o, 0.5, { ImageTransparency = 1 })
                elseif o:IsA("TextLabel") or o:IsA("TextButton") then
                    tween(o, 0.5, { TextTransparency = 1 })
                    if o:IsA("TextButton") then
                        tween(o, 0.5, { BackgroundTransparency = 1 })
                    end
                end
            end
            for _, c in ipairs(rainCols) do tween(c.obj, 0.5, { TextTransparency = 1 }) end
            for _, s in ipairs(streams) do tween(s, 0.5, { TextTransparency = 1 }) end
            for _, b in ipairs(brackets) do tween(b, 0.5, { BackgroundTransparency = 1 }) end
            for _, a in ipairs(ambientParticles) do
                tween(a.obj, 0.5, { BackgroundTransparency = 1 })
                if a.glow then a.glow.Transparency = 1 end
            end
            for _, f in ipairs(floatDots) do tween(f.obj, 0.5, { BackgroundTransparency = 1 }) end
            for _, e in ipairs(edgeParticles) do tween(e.obj, 0.5, { BackgroundTransparency = 1 }) end
            if bgImg then tween(bgImg, 0.5, { ImageTransparency = 1 }) end
            task.wait(0.55)
            gui:Destroy()

            _G.KurayamiReadyEvent = nil
        end)
    end
end)
