--[[
=====================================================================
    Kurayami Hub v3 | Neon Obsidian
    Universal Script for Delta / Xeno
    Support: Mobile + PC
    Theme: Purple-Pink Neon (Obsidian)
    No Webhook | No External Calls | Local Save by PlaceId
=====================================================================
]]

-- ============================================================
-- [ SECTION 1 ] SERVICES & CONSTANTS
-- ============================================================
local Players            = game:GetService("Players")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local StarterGui         = game:GetService("StarterGui")
local ContextActionSvc   = game:GetService("ContextActionService")
local VirtualUser        = game:GetService("VirtualUser")
local Lighting           = game:GetService("Lighting")
local Workspace          = game:GetService("Workspace")
local player             = Players.LocalPlayer

-- ============================================================
-- [ SECTION 2 ] THEME (Neon Obsidian)
-- ============================================================
local Theme = {
    BgMain       = Color3.fromRGB(10, 7, 16),
    BgPanel      = Color3.fromRGB(20, 16, 32),
    BgCard       = Color3.fromRGB(28, 23, 48),
    BgCardHover  = Color3.fromRGB(36, 30, 60),
    Stroke       = Color3.fromRGB(142, 68, 173),
    StrokeSoft   = Color3.fromRGB(50, 38, 70),
    Accent       = Color3.fromRGB(236, 72, 153),
    Accent2      = Color3.fromRGB(34, 211, 238),
    ToggleOn     = Color3.fromRGB(142, 68, 173),
    ToggleOff    = Color3.fromRGB(55, 65, 81),
    TextMain     = Color3.fromRGB(245, 243, 255),
    TextSub      = Color3.fromRGB(167, 139, 250),
    TextDim      = Color3.fromRGB(120, 110, 140),
    Success      = Color3.fromRGB(16, 185, 129),
    Danger       = Color3.fromRGB(239, 68, 68),
    Warn         = Color3.fromRGB(245, 158, 11),
}

-- ============================================================
-- [ SECTION 3 ] UTILITY FUNCTIONS
-- ============================================================
local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local hasFileIO = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local hasHui    = (typeof(gethui) == "function")

local function getGuiParent()
    if hasHui then
        local h = safeCall(gethui)
        if h then return h end
    end
    return safeCall(function() return game:GetService("CoreGui") end) or player:WaitForChild("PlayerGui")
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(obj, r)
    return make("UICorner", {CornerRadius = UDim.new(0, r or 6)}, obj)
end

local function stroke(obj, color, thick)
    return make("UIStroke", {
        Color = color or Theme.StrokeSoft,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

local function gradient(obj, c1, c2, rot)
    return make("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 0
    }, obj)
end

-- ============================================================
-- [ SECTION 4 ] STATE MANAGEMENT
-- ============================================================
local State = {
    -- Player
    Speed        = false,  SpeedValue     = 80,
    Jump         = false,  JumpValue      = 120,
    InfJump      = false,
    Fly          = false,  FlyValue       = 60,
    Noclip       = false,
    Invisible    = false,
    AntiFling    = false,
    AntiVoid     = false,
    -- Defense
    God          = false,
    AntiKick     = false,
    LockHealth   = false,
    AutoHeal     = false,
    -- Teleport
    CtrlClickTP  = false,
    -- Visual
    Fullbright   = false,
    RemoveFog    = false,
    RemoveShadow = false,
    FPSBoost     = false,
    -- ESP
    ESP          = false,
    ESPName      = true,
    ESPUser      = false,
    ESPDist      = true,
    ESPHealth    = true,
    ESPTeamCheck = false,
    ESPColor     = Color3.fromRGB(236, 72, 153),
    ESPTransparency = 0.3,
    -- Settings
    AntiAFK      = true,
    AutoRejoin   = false,
    SoundOn      = true,
    UIKey        = Enum.KeyCode.RightShift,
    -- Session
    SessionStart = tick(),
    -- Keybinds (toggle name -> keycode)
    Keybinds     = {},
}

-- ============================================================
-- [ SECTION 5 ] SAVE / LOAD (PlaceId-based)
-- ============================================================
local SAVE_FILE = "KurayamiV3_Data.json"
local SaveData = {
    Version = "3.0",
    ByePlace = {},  -- [PlaceId] = { name, locations = {{name,x,y,z,order}} }
    Settings = {},
    Keybinds = {},
}

local function loadSaveFile()
    if not hasFileIO then return end
    safeCall(function()
        if isfile and isfile(SAVE_FILE) then
            local raw = readfile(SAVE_FILE)
            local decoded = HttpService:JSONDecode(raw)
            if type(decoded) == "table" then
                SaveData.ByePlace = decoded.ByePlace or {}
                SaveData.Settings = decoded.Settings or {}
                SaveData.Keybinds = decoded.Keybinds or {}
            end
        end
    end)
end

local function writeSaveFile()
    if not hasFileIO then return end
    safeCall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(SaveData))
    end)
end

loadSaveFile()

-- Restore settings from save
for k, v in pairs(SaveData.Settings or {}) do
    if State[k] ~= nil then State[k] = v end
end
for k, v in pairs(SaveData.Keybinds or {}) do
    local kc = Enum.KeyCode[v]
    if kc and State[k] ~= nil then State.Keybinds[k] = kc end
end

-- Current place key
local PLACE_KEY = tostring(game.PlaceId)
if not SaveData.ByePlace[PLACE_KEY] then
    SaveData.ByePlace[PLACE_KEY] = {
        name = safeCall(function() return game.Name end) or "Unknown",
        locations = {}
    }
end
local PlaceEntry = SaveData.ByePlace[PLACE_KEY]

-- ============================================================
-- [ SECTION 6 ] GUI ROOT
-- ============================================================
safeCall(function()
    local old = getGuiParent():FindFirstChild("KurayamiHub_V3")
    if old then old:Destroy() end
end)

local screenGui = make("ScreenGui", {
    Name = "KurayamiHub_V3",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, getGuiParent())

-- ============================================================
-- [ SECTION 7 ] TOAST NOTIFICATION
-- ============================================================
local toastHolder = make("Frame", {
    Size = UDim2.new(0, 260, 1, -40),
    Position = UDim2.new(1, -270, 0, 20),
    BackgroundTransparency = 1,
}, screenGui)
make("UIListLayout", {
    Padding = UDim.new(0, 8),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)

local function toast(msg, color, duration)
    color = color or Theme.Accent
    duration = duration or 2.5
    
    local frame = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.BgCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 100, 0, 0),
    }, toastHolder)
    corner(frame, 8)
    local st = stroke(frame, color, 1.5)
    st.Transparency = 1
    
    local label = make("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = Theme.TextMain,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1,
    }, frame)
    
    TweenService:Create(frame, TweenInfo.new(0.25), {
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
    TweenService:Create(label, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    TweenService:Create(st, TweenInfo.new(0.25), {Transparency = 0}):Play()
    
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 100, 0, 0),
        }):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.35)
        frame:Destroy()
    end)
end

-- Sound
local SOUND_ON  = "rbxassetid://6895079853"
local SOUND_OFF = "rbxassetid://6895079703"
local function playSound(on)
    if not State.SoundOn then return end
    safeCall(function()
        local s = Instance.new("Sound")
        s.SoundId = on and SOUND_ON or SOUND_OFF
        s.Volume = 0.3
        s.Parent = screenGui
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

-- ============================================================
-- [ SECTION 8 ] CONFIRM DIALOG
-- ============================================================
local confirmOverlay = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.5,
    Visible = false,
    ZIndex = 50,
}, screenGui)

local confirmBox = make("Frame", {
    Size = UDim2.new(0, 300, 0, 160),
    Position = UDim2.new(0.5, -150, 0.5, -80),
    BackgroundColor3 = Theme.BgPanel,
    ZIndex = 51,
}, confirmOverlay)
corner(confirmBox, 12)
stroke(confirmBox, Theme.Accent, 1.5)

local confirmTitle = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 12),
    BackgroundTransparency = 1,
    Text = "ยืนยันการทำงาน",
    TextColor3 = Theme.Accent,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    ZIndex = 51,
}, confirmBox)

local confirmMsg = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Theme.TextMain,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    ZIndex = 51,
}, confirmBox)

local confirmYes = make("TextButton", {
    Size = UDim2.new(0, 130, 0, 36),
    Position = UDim2.new(0, 15, 1, -50),
    BackgroundColor3 = Theme.Danger,
    Text = "ยืนยัน",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    ZIndex = 51,
}, confirmBox)
corner(confirmYes, 6)

local confirmNo = make("TextButton", {
    Size = UDim2.new(0, 130, 0, 36),
    Position = UDim2.new(1, -145, 1, -50),
    BackgroundColor3 = Theme.ToggleOff,
    Text = "ยกเลิก",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    ZIndex = 51,
}, confirmBox)
corner(confirmNo, 6)

local confirmCallback = nil
local function askConfirm(msg, cb)
    confirmMsg.Text = msg
    confirmOverlay.Visible = true
    confirmCallback = cb
end
confirmYes.MouseButton1Click:Connect(function()
    confirmOverlay.Visible = false
    if confirmCallback then confirmCallback() end
    confirmCallback = nil
end)
confirmNo.MouseButton1Click:Connect(function()
    confirmOverlay.Visible = false
    confirmCallback = nil
end)

-- ============================================================
-- [ SECTION 9 ] MAIN FRAME + TITLEBAR
-- ============================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local initW = isMobile and 380 or 640
local initH = isMobile and 500 or 400

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, initW, 0, initH),
    Position = UDim2.new(0.5, -initW/2, 0.5, -initH/2),
    BackgroundColor3 = Theme.BgMain,
    BorderSizePixel = 0,
    Active = true,
}, screenGui)
corner(main, 12)
local mainStroke = stroke(main, Theme.Stroke, 1.5)
gradient(mainStroke, Theme.Stroke, Theme.Accent, 45)

-- Title bar
local titleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Theme.BgPanel,
    BorderSizePixel = 0,
}, main)
corner(titleBar, 12)

local titleText = make("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency = 1,
    Text = "KURAYAMI HUB  |  v3 NEON OBSIDIAN",
    TextColor3 = Theme.TextMain,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

-- Mini mode button
local miniBtn = make("TextButton", {
    Size = UDim2.new(0, 30, 0, 26),
    Position = UDim2.new(1, -100, 0, 6),
    BackgroundColor3 = Theme.BgCard,
    Text = "–",
    TextColor3 = Theme.TextMain,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
}, titleBar)
corner(miniBtn, 5)

-- Close button
local closeBtn = make("TextButton", {
    Size = UDim2.new(0, 30, 0, 26),
    Position = UDim2.new(1, -40, 0, 6),
    BackgroundColor3 = Theme.Danger,
    Text = "✕",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
}, titleBar)
corner(closeBtn, 5)

closeBtn.MouseButton1Click:Connect(function()
    askConfirm("ต้องการปิด Kurayami Hub v3?\n(สคริปต์จะหยุดทำงานทั้งหมด)", function()
        safeCall(function() screenGui:Destroy() end)
    end)
end)

-- Custom drag (works with touch & mouse)
local dragging, dragStart, startPos
local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = main.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================
-- [ SECTION 10 ] SIDEBAR + TABS
-- ============================================================
local SIDEBAR_W = 140

local sidebar = make("Frame", {
    Size = UDim2.new(0, SIDEBAR_W, 1, -48),
    Position = UDim2.new(0, 8, 0, 44),
    BackgroundColor3 = Theme.BgPanel,
    BorderSizePixel = 0,
}, main)
corner(sidebar, 8)
stroke(sidebar, Theme.StrokeSoft, 1)

local sidebarScroll = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 4)}, sidebarScroll)
make("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
}, sidebarScroll)

local contentHolder = make("Frame", {
    Size = UDim2.new(1, -(SIDEBAR_W + 16), 1, -48),
    Position = UDim2.new(0, SIDEBAR_W + 12, 0, 44),
    BackgroundTransparency = 1,
}, main)

local tabs = {}
local activeTab = nil

local function switchTab(name)
    if activeTab == name then return end
    for n, frame in pairs(tabs) do
        frame.Visible = (n == name)
    end
    for _, btn in ipairs(sidebarScroll:GetChildren()) do
        if btn:IsA("TextButton") and btn:GetAttribute("TabName") then
            if btn:GetAttribute("TabName") == name then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Stroke}):Play()
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BgCard}):Play()
            end
        end
    end
    activeTab = name
end

local function createTab(name, icon, display)
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.BgCard,
        Text = "  " .. icon .. "  " .. display,
        TextColor3 = Theme.TextMain,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebarScroll)
    corner(btn, 6)
    btn:SetAttribute("TabName", name)
    
    local page = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Stroke,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, contentHolder)
    make("UIListLayout", {Padding = UDim.new(0, 8)}, page)
    make("UIPadding", {
        PaddingRight = UDim.new(0, 8),
    }, page)
    
    tabs[name] = page
    
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
        playSound(true)
    end)
    
    return page
end

-- ============================================================
-- [ SECTION 11 ] WIDGETS (Toggle / Slider / Button / Section / Search)
-- ============================================================
local function createSection(parent, title)
    local header = make("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
    }, parent)
    local lbl = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "▎ " .. title,
        TextColor3 = Theme.TextSub,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    return header
end

local function createSearchBar(parent, onSearch)
    local bar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.BgCard,
        BorderSizePixel = 0,
    }, parent)
    corner(bar, 6)
    stroke(bar, Theme.StrokeSoft, 1)
    
    local box = make("TextBox", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "🔎 ค้นหา...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.TextMain,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, bar)
    
    local clearBtn = make("TextButton", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -32, 0, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
    }, bar)
    
    box:GetPropertyChangedSignal("Text"):Connect(function()
        onSearch(box.Text)
    end)
    clearBtn.MouseButton1Click:Connect(function()
        box.Text = ""
    end)
    
    return bar
end

local function createToggle(parent, id, title, desc, default)
    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.BgCard,
        BorderSizePixel = 0,
    }, parent)
    corner(card, 8)
    stroke(card, Theme.StrokeSoft, 1)
    card:SetAttribute("SearchKey", string.lower(title .. " " .. desc))
    
    local nameLbl = make("TextLabel", {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextMain,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    
    local descLbl = make("TextLabel", {
        Size = UDim2.new(1, -100, 0, 16),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    
    local sw = make("TextButton", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff,
        Text = "",
        AutoButtonColor = false,
    }, card)
    corner(sw, 12)
    
    local ball = make("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, sw)
    corner(ball, 9)
    
    local infoBtn = make("TextButton", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -26, 0.5, -11),
        BackgroundColor3 = Theme.BgPanel,
        Text = "?",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
    }, card)
    corner(infoBtn, 11)
    infoBtn.MouseButton1Click:Connect(function()
        toast(desc, Theme.Accent2, 3)
    end)
    
    local toggled = default
    local function setValue(v, silent)
        toggled = v
        State[id] = v
        SaveData.Settings[id] = v
        writeSaveFile()
        local targetBg  = v and Theme.ToggleOn or Theme.ToggleOff
        local targetPos = v and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        TweenService:Create(ball, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if not silent then playSound(v) end
    end
    
    sw.MouseButton1Click:Connect(function()
        setValue(not toggled)
        toast((toggled and "✅ เปิด " or "⛔ ปิด ") .. title, toggled and Theme.Success or Theme.Danger, 1.5)
    end)
    
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgCardHover}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgCard}):Play()
    end)
    
    return card, setValue
end

local function createSlider(parent, id, title, min, max, default, callback, unlimited)
    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.BgCard,
        BorderSizePixel = 0,
    }, parent)
    corner(card, 8)
    stroke(card, Theme.StrokeSoft, 1)
    card:SetAttribute("SearchKey", string.lower(title))
    
    local nameLbl = make("TextLabel", {
        Size = UDim2.new(1, -100, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextMain,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    
    local valBox = make("TextBox", {
        Size = UDim2.new(0, 70, 0, 22),
        Position = UDim2.new(1, -84, 0, 6),
        BackgroundColor3 = Theme.BgPanel,
        Text = tostring(default),
        TextColor3 = Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ClearTextOnFocus = false,
    }, card)
    corner(valBox, 5)
    
    local track = make("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.new(0, 14, 0, 42),
        BackgroundColor3 = Theme.ToggleOff,
    }, card)
    corner(track, 4)
    
    local fill = make("Frame", {
        Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
    }, track)
    corner(fill, 4)
    gradient(fill, Theme.Stroke, Theme.Accent)
    
    local dragging = false
    local currentVal = default
    
    local function updateFromX(mouseX)
        local rel = (mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        currentVal = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valBox.Text = tostring(currentVal)
        State[id] = currentVal
        if callback then callback(currentVal) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    valBox.FocusLost:Connect(function()
        local num = tonumber(valBox.Text)
        if not num then
            valBox.Text = tostring(currentVal)
            return
        end
        if not unlimited then
            num = math.clamp(num, min, max)
        end
        currentVal = num
        local rel = unlimited and 1 or math.clamp((num - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valBox.Text = tostring(num)
        State[id] = num
        if callback then callback(num) end
    end)
    
    return card
end

local function createButton(parent, title, color, callback)
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = color or Theme.BgCard,
        Text = title,
        TextColor3 = Theme.TextMain,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
    }, parent)
    corner(btn, 8)
    stroke(btn, Theme.StrokeSoft, 1)
    
    btn.MouseButton1Click:Connect(function()
        playSound(true)
        if callback then callback() end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgCardHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or Theme.BgCard}):Play()
    end)
    return end

-- ============================================================
-- [ SECTION 12 ] TAB 1 - MAIN
-- ============================================================
local mainTab = createTab("Main", "🏠", "หน้าหลัก")
createSection(mainTab, "ข้อมูลผู้เล่น")

local profileCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 100),
    BackgroundColor3 = Theme.BgCard,
    BorderSizePixel = 0,
}, mainTab)
corner(profileCard, 8)
stroke(profileCard, Theme.StrokeSoft, 1)

local avatarFrame = make("Frame", {
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0, 14, 0, 14),
    BackgroundColor3 = Theme.BgPanel,
}, profileCard)
corner(avatarFrame, 30)
local avatarStroke = stroke(avatarFrame, Theme.Accent, 2)

local avatarImg = make("ImageLabel", {
    Size = UDim2.new(1, -4, 1, -4),
    Position = UDim2.new(0, 2, 0, 2),
    BackgroundTransparency = 1,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
}, avatarFrame)
corner(avatarImg, 28)

local displayLbl = make("TextLabel", {
    Size = UDim2.new(1, -90, 0, 22),
    Position = UDim2.new(0, 84, 0, 14),
    BackgroundTransparency = 1,
    Text = player.DisplayName,
    TextColor3 = Theme.TextMain,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profileCard)

local userLbl = make("TextLabel", {
    Size = UDim2.new(1, -90, 0, 16),
    Position = UDim2.new(0, 84, 0, 36),
    BackgroundTransparency = 1,
    Text = "@" .. player.Name,
    TextColor3 = Theme.TextSub,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profileCard)

local uidLbl = make("TextLabel", {
    Size = UDim2.new(1, -90, 0, 14),
    Position = UDim2.new(0, 84, 0, 52),
    BackgroundTransparency = 1,
    Text = "ID: " .. player.UserId,
    TextColor3 = Theme.TextDim,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profileCard)

local sessionLbl = make("TextLabel", {
    Size = UDim2.new(1, -90, 0, 14),
    Position = UDim2.new(0, 84, 0, 68),
    BackgroundTransparency = 1,
    Text = "Session: 00:00:00",
    TextColor3 = Theme.Accent2,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profileCard)

-- Live stats card
createSection(mainTab, "สถานะปัจจุบัน")

local statsCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 130),
    BackgroundColor3 = Theme.BgCard,
    BorderSizePixel = 0,
}, mainTab)
corner(statsCard, 8)
stroke(statsCard, Theme.StrokeSoft, 1)

local function statRow(y, label, valueColor)
    make("TextLabel", {
        Size = UDim2.new(0.5, -10, 0, 20),
        Position = UDim2.new(0, 14, 0, y),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.TextSub,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, statsCard)
    return make("TextLabel", {
        Size = UDim2.new(0.5, -14, 0, 20),
        Position = UDim2.new(0.5, 0, 0, y),
        BackgroundTransparency = 1,
        Text = "--",
        TextColor3 = valueColor or Theme.TextMain,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, statsCard)
end

local statFPS     = statRow(8,   "FPS",        Theme.Accent2)
local statPing    = statRow(30,  "Ping (ms)",  Theme.Accent2)
local statHealth  = statRow(52,  "Health",     Theme.Success)
local statMap     = statRow(74,  "Map",        Theme.Accent)
local statPlayers = statRow(96,  "Players",    Theme.Accent)

-- Buttons
createSection(mainTab, "การจัดการ")

createButton(mainTab, "🔄 เข้าเซิร์ฟเวอร์ใหม่ (Rejoin)", Theme.BgCard, function()
    askConfirm("ต้องการออกจากเซิร์ฟและเข้าใหม่?\n(JobId จะถูกใช้ถ้ามี)", function()
        local jobId = safeCall(function() return game.JobId end)
        if jobId and jobId ~= "" then
            safeCall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, player)
            end)
        else
            safeCall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, player)
            end)
        end
    end)
end)

createButton(mainTab, "💀 ฆ่าตัวเอง (Reset Character)", Theme.BgCard, function()
    askConfirm("ต้องการรีเซ็ตตัวละครหรือไม่?", function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end)

createButton(mainTab, "📋 คัดลอก JobId", Theme.BgCard, function()
    local id = safeCall(function() return game.JobId end) or ""
    safeCall(function() setclipboard(id) end)
    toast("คัดลอก JobId แล้ว: " .. id:sub(1, 12) .. "...", Theme.Success, 2)
end)

createButton(mainTab, "📋 คัดลอก PlaceId", Theme.BgCard, function()
    safeCall(function() setclipboard(tostring(game.PlaceId)) end)
    toast("คัดลอก PlaceId แล้ว: " .. game.PlaceId, Theme.Success, 2)
end)

createButton(mainTab, "📋 คัดลอก UserId", Theme.BgCard, function()
    safeCall(function() setclipboard(tostring(player.UserId)) end)
    toast("คัดลอก UserId แล้ว: " .. player.UserId, Theme.Success, 2)
end)

-- ============================================================
-- [ SECTION 13 ] TAB 2 - PLAYER
-- ============================================================
local playerTab = createTab("Player", "🏃", "ผู้เล่น")
createSection(playerTab, "การเคลื่อนที่")

createSlider(playerTab, "SpeedValue", "⚡ ความเร็วในการวิ่ง (WalkSpeed)", 16, 500, State.SpeedValue,
    function(v) State.SpeedValue = v end, true)

createSlider(playerTab, "JumpValue", "🦘 พลังกระโดด (JumpPower)", 50, 500, State.JumpValue,
    function(v) State.JumpValue = v end, true)

createSlider(playerTab, "FlyValue", "🕊️ ความเร็วในการบิน", 10, 500, State.FlyValue,
    function(v) State.FlyValue = v end, true)

createSection(playerTab, "สวิตช์เปิด-ปิด")

createToggle(playerTab, "Speed",     "🏃 วิ่งเร็ว (Speed Hack)",         "เพิ่มความเร็วในการเคลื่อนที่", false)
createToggle(playerTab, "Jump",      "🦘 กระโดดสูง (Jump Hack)",         "เพิ่มพลังกระโดด", false)
createToggle(playerTab, "InfJump",   "♾️ กระโดดไม่จำกัด (Infinite Jump)", "กระโดดกลางอากาศได้ไม่จำกัด", false)
createToggle(playerTab, "Fly",       "🕊️ บินได้ (Fly Hack)",             "บินอิสระกลางอากาศ", false)
createToggle(playerTab, "Noclip",    "🧱 ทะลุกำแพง (Noclip)",           "เดินผ่านสิ่งกีดขวางได้", false)
createToggle(playerTab, "Invisible", "👻 ล่องหน (Invisible)",            "ซ่อนตัวจากผู้เล่นอื่น", false)
createToggle(playerTab, "AntiFling", "🛡️ กันกระเด็น (Anti-Fling)",       "กันการถูกกระเด็นออกจากแมพ", false)
createToggle(playerTab, "AntiVoid",  "🕳️ กันตกแมพ (Anti-Void)",          "วาร์ปกลับเมื่อตกแมพ", false)

createButton(playerTab, "♻️ คืนค่า WalkSpeed / JumpPower", Theme.BgCard, function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.UseJumpPower = true
    end
    toast("คืนค่าเป็น 16 / 50 แล้ว", Theme.Success, 2)
end)

-- ============================================================
-- [ SECTION 14 ] TAB 3 - DEFENSE
-- ============================================================
local defenseTab = createTab("Defense", "🛡️", "ป้องกัน")
createSection(defenseTab, "ระบบป้องกันตัว")

createToggle(defenseTab, "God",        "🛡️ โหมดอมตะ (Godmode)",           "HP ไม่ลด กันดาเมจทุกชนิด", false)
createToggle(defenseTab, "LockHealth", "🔒 ล็อก HP (Lock Health)",        "ล็อก HP ไม่ให้ลดลง", false)
createToggle(defenseTab, "AutoHeal",   "💚 ฟื้น HP อัตโนมัติ (Auto-Heal)", "ฟื้น HP อัตโนมัติทุก 1 วินาที", false)
createToggle(defenseTab, "AntiKick",   "🚫 กันเตะ (Anti-Kick)",            "กันการถูกเตะออกจากเซิร์ฟ", false)

createSection(defenseTab, "Anti-AFK")
createToggle(defenseTab, "AntiAFK", "⏰ กัน AFK (Anti-AFK)", "กันการถูกเตะเพราะไม่ขยับ (เปิดอัตโนมัติ)", State.AntiAFK)

-- ============================================================
-- [ SECTION 15 ] TAB 4 - TELEPORT
-- ============================================================
local tpTab = createTab("Teleport", "📍", "วาร์ป")
createSection(tpTab, "ตำแหน่งที่บันทึกไว้ | " .. PlaceEntry.name)

local addBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
}, tpTab)

local tpNameInput = make("TextBox", {
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundColor3 = Theme.BgCard,
    Text = "",
    PlaceholderText = "ชื่อตำแหน่งใหม่...",
    PlaceholderColor3 = Theme.TextDim,
    TextColor3 = Theme.TextMain,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
}, addBar)
corner(tpNameInput, 6)
stroke(tpNameInput, Theme.StrokeSoft, 1)

local addLocBtn = make("TextButton", {
    Size = UDim2.new(0, 90, 1, 0),
    Position = UDim2.new(1, -90, 0, 0),
    BackgroundColor3 = Theme.Success,
    Text = "＋ บันทึก",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, addBar)
corner(addLocBtn, 6)

local locList = make("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
}, tpTab)
make("UIListLayout", {Padding = UDim.new(0, 6)}, locList)
make("UIPadding", {PaddingTop = UDim.new(0, 6)}, locList)

local locFrames = {}

local function refreshLocations()
    for _, f in ipairs(locFrames) do f:Destroy() end
    locFrames = {}
    
    table.sort(PlaceEntry.locations, function(a, b)
        return (a.order or 0) < (b.order or 0)
    end)
    
    for i, loc in ipairs(PlaceEntry.locations) do
        local card = make("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.BgCard,
            BorderSizePixel = 0,
        }, locList)
        corner(card, 8)
        stroke(card, Theme.StrokeSoft, 1)
        card:SetAttribute("Order", i)
        
        local nameBtn = make("TextButton", {
            Size = UDim2.new(1, -110, 1, 0),
            BackgroundTransparency = 1,
            Text = "  📍 " .. loc.name,
            TextColor3 = Theme.TextMain,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        
        nameBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z)
                toast("วาร์ปไป " .. loc.name, Theme.Success, 1.5)
            end
        end)
        
        local dragBtn = make("TextButton", {
            Size = UDim2.new(0, 30, 1, -8),
            Position = UDim2.new(1, -100, 0, 4),
            BackgroundColor3 = Theme.BgPanel,
            Text = "≡",
            TextColor3 = Theme.TextSub,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
        }, card)
        corner(dragBtn, 5)
        
        local renBtn = make("TextButton", {
            Size = UDim2.new(0, 30, 1, -8),
            Position = UDim2.new(1, -66, 0, 4),
            BackgroundColor3 = Theme.Stroke,
            Text = "✎",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
        }, card)
        corner(renBtn, 5)
        renBtn.MouseButton1Click:Connect(function()
            tpNameInput.Text = loc.name
            tpNameInput:CaptureFocus()
            toast("แก้ชื่อแล้วกด Enter", Theme.Accent2, 2)
        end)
        
        local delBtn = make("TextButton", {
            Size = UDim2.new(0, 30, 1, -8),
            Position = UDim2.new(1, -32, 0, 4),
            BackgroundColor3 = Theme.Danger,
            Text = "✕",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
        }, card)
        corner(delBtn, 5)
        delBtn.MouseButton1Click:Connect(function()
            askConfirm("ลบตำแหน่ง '" .. loc.name .. "'?", function()
                table.remove(PlaceEntry.locations, i)
                for j, l in ipairs(PlaceEntry.locations) do l.order = j end
                writeSaveFile()
                refreshLocations()
                toast("ลบแล้ว", Theme.Danger, 1.5)
            end)
        end)
        
        -- Drag & Drop
        local isDragging = false
        local dragStartY, startOrder
        dragBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStartY = input.Position.Y
                startOrder = i
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not isDragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                local deltaY = input.Position.Y - dragStartY
                local shift = math.floor(deltaY / 50)
                local newOrder = math.clamp(startOrder + shift, 1, #PlaceEntry.locations)
                if newOrder ~= loc.order then
                    table.remove(PlaceEntry.locations, i)
                    table.insert(PlaceEntry.locations, newOrder, loc)
                    for j, l in ipairs(PlaceEntry.locations) do l.order = j end
                    writeSaveFile()
                    refreshLocations()
                    isDragging = false
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        
        table.insert(locFrames, card)
    end
end

local function saveCurrentLocation(name)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        toast("ยังไม่เกิดตัวละคร", Theme.Danger, 2)
        return
    end
    local pos = hrp.Position
    for _, l in ipairs(PlaceEntry.locations) do
        if l.name == name then
            l.x, l.y, l.z = pos.X, pos.Y, pos.Z
            writeSaveFile()
            refreshLocations()
            toast("อัปเดตตำแหน่งแล้ว", Theme.Success, 2)
            return
        end
    end
    table.insert(PlaceEntry.locations, {
        name = name, x = pos.X, y = pos.Y, z = pos.Z,
        order = #PlaceEntry.locations + 1
    })
    writeSaveFile()
    refreshLocations()
    toast("บันทึก '" .. name .. "' แล้ว", Theme.Success, 2)
end

addLocBtn.MouseButton1Click:Connect(function()
    local n = tpNameInput.Text
    if n == "" then
        toast("ใส่ชื่อก่อน", Theme.Warn, 2)
        return
    end
    saveCurrentLocation(n)
    tpNameInput.Text = ""
end)

createSection(tpTab, "ตัวเลือกการวาร์ป")

createButton(tpTab, "🏠 วาร์ปไปจุดเกิด (Spawn)", Theme.BgCard, function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local sp = safeCall(function()
            return player.RespawnLocation or Workspace:FindFirstChildOfClass("SpawnLocation")
        end)
        if sp then
            hrp.CFrame = sp.CFrame + Vector3.new(0, 5, 0)
            toast("วาร์ปไปจุดเกิด", Theme.Success, 1.5)
        end
    end
end)

createButton(tpTab, "🎯 วาร์ปไปหาผู้เล่น (สุ่ม)", Theme.BgCard, function()
    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others == 0 then
        toast("ไม่มีผู้เล่นอื่น", Theme.Warn, 2)
        return
    end
    local target = others[math.random(1, #others)]
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        toast("วาร์ปไป " .. target.Name, Theme.Success, 2)
    end
end)

createToggle(tpTab, "CtrlClickTP", "🖱️ Ctrl + คลิก = วาร์ป", "กด Ctrl ค้างแล้วคลิกซ้ายเพื่อวาร์ป", false)

refreshLocations()
end

-- ============================================================
-- [ SECTION 16 ] TAB 5 - VISUAL
-- ============================================================
local visualTab = createTab("Visual", "🎨", "ภาพ")
createSection(visualTab, "ปรับภาพและแสง")

createToggle(visualTab, "Fullbright",   "☀️ สว่างทั้งแมพ (Fullbright)",  "ปรับความสว่างสูงสุด", false)
createToggle(visualTab, "RemoveFog",    "🌫️ ลบหมอก (Remove Fog)",        "ลบหมอกออกจากแมพ", false)
createToggle(visualTab, "RemoveShadow", "🌑 ลบเงา (Remove Shadow)",      "ปิดการแสดงเงา", false)
createToggle(visualTab, "FPSBoost",     "⚡ เพิ่ม FPS (FPS Boost)",       "ลดคุณภาพกราฟิกเพื่อเพิ่ม FPS", false)

-- ============================================================
-- [ SECTION 17 ] TAB 6 - ESP
-- ============================================================
local espTab = createTab("ESP", "👁️", "ESP")
createSection(espTab, "การแสดงผล ESP")

local espHighlights = {}

local function clearESP()
    for p, hl in pairs(espHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espHighlights = {}
end

local function applyESP(char, plr)
    if not char then return end
    local hl = espHighlights[plr]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "KurayamiESP"
        hl.FillColor = State.ESPColor
        hl.FillTransparency = State.ESPTransparency
        hl.OutlineColor = State.ESPColor
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        espHighlights[plr] = hl
    end
    hl.FillColor = State.ESPColor
    hl.OutlineColor = State.ESPColor
end

local function refreshESP()
    clearESP()
    if not State.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if State.ESPTeamCheck and p.Team == player.Team then continue end
            if p.Character then applyESP(p.Character, p) end
        end
    end
end

createToggle(espTab, "ESP",          "👁️ เปิดใช้งาน ESP",              "แสดงกรอบรอบตัวผู้เล่น", false)
createToggle(espTab, "ESPName",      "🏷️ แสดงชื่อที่แสดง (Display)",    "แสดง DisplayName", State.ESPName)
createToggle(espTab, "ESPUser",      "🔤 แสดง Username",               "แสดง @username", State.ESPUser)
createToggle(espTab, "ESPDist",      "📏 แสดงระยะห่าง",               "แสดงระยะห่างจากเรา", State.ESPDist)
createToggle(espTab, "ESPHealth",    "❤️ แสดง HP",                     "แสดงแถบ HP", State.ESPHealth)
createToggle(espTab, "ESPTeamCheck", "👥 ตรวจสอบทีม",                 "ไม่แสดงเพื่อนทีม", false)

createSection(espTab, "สีของ ESP")

local colorRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Theme.BgCard,
}, espTab)
corner(colorRow, 8)
stroke(colorRow, Theme.StrokeSoft, 1)

local presets = {
    {Color3.fromRGB(236, 72, 153),  "ชมพู"},
    {Color3.fromRGB(239, 68, 68),   "แดง"},
    {Color3.fromRGB(16, 185, 129),  "เขียว"},
    {Color3.fromRGB(34, 211, 238),  "ฟ้า"},
    {Color3.fromRGB(245, 158, 11),  "ทอง"},
    {Color3.fromRGB(167, 139, 250), "ม่วง"},
}

for i, p in ipairs(presets) do
    local b = make("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 12 + (i - 1) * 40, 0, 9),
        BackgroundColor3 = p[1],
        Text = "",
    }, colorRow)
    corner(b, 16)
    stroke(b, Color3.new(1, 1, 1), 1)
    b.MouseButton1Click:Connect(function()
        State.ESPColor = p[1]
        SaveData.Settings.ESPColor = tostring(p[1])
        writeSaveFile()
        refreshESP()
        toast("เปลี่ยนสี ESP: " .. p[2], p[1], 1.5)
    end)
end

-- ============================================================
-- [ SECTION 18 ] TAB 7 - SETTINGS
-- ============================================================
local settingsTab = createTab("Settings", "⚙️", "ตั้งค่า")
createSection(settingsTab, "การตั้งค่าทั่วไป")

createToggle(settingsTab, "SoundOn",    "🔊 เสียงแจ้งเตือน",        "เปิด-ปิดเสียงตอนกด toggle", State.SoundOn)
createToggle(settingsTab, "AutoRejoin", "🔁 เข้าเซิร์ฟใหม่ Auto",    "เข้าเซิร์ฟเดิมอัตโนมัติเมื่อหลุด", false)

createSection(settingsTab, "ข้อมูลที่บันทึก")

createButton(settingsTab, "💾 บันทึกข้อมูลลงไฟล์", Theme.BgCard, function()
    writeSaveFile()
    toast("บันทึกข้อมูลแล้ว", Theme.Success, 2)
end)

createButton(settingsTab, "🗑️ ล้างตำแหน่งในแมพนี้", Theme.Danger, function()
    askConfirm("ลบตำแหน่งทั้งหมดในแมพนี้?", function()
        PlaceEntry.locations = {}
        writeSaveFile()
        refreshLocations()
        toast("ล้างตำแหน่งในแมพนี้แล้ว", Theme.Danger, 2)
    end)
end)

createButton(settingsTab, "🧹 ล้างข้อมูลทั้งหมด", Theme.Danger, function()
    askConfirm("ลบข้อมูลทั้งหมดของทุกแมพ?", function()
        SaveData.ByePlace = {}
        SaveData.Settings = {}
        SaveData.Keybinds = {}
        writeSaveFile()
        toast("ล้างข้อมูลทั้งหมดแล้ว (ต้องรีสตาร์ทสคริปต์)", Theme.Danger, 3)
    end)
end)

createSection(settingsTab, "เกี่ยวกับ")

local aboutCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundColor3 = Theme.BgCard,
    BorderSizePixel = 0,
}, settingsTab)
corner(aboutCard, 8)
stroke(aboutCard, Theme.StrokeSoft, 1)

make("TextLabel", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "Kurayami Hub v3 | Neon Obsidian\nDeveloped for Delta / Xeno\nNo Webhook · Local Save · PlaceId-based",
    TextColor3 = Theme.TextSub,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center,
}, aboutCard)

createButton(settingsTab, "⛔ ทำลายสคริปต์ (Destroy)", Theme.Danger, function()
    askConfirm("ปิดสคริปต์ถาวร?", function()
        safeCall(function() screenGui:Destroy() end)
    end)
end)

-- ============================================================
-- [ SECTION 19 ] FLOATING TOGGLE BUTTON
-- ============================================================
local toggleBtn = make("TextButton", {
    Size = UDim2.new(0, 48, 0, 48),
    Position = UDim2.new(0, 20, 0, 200),
    BackgroundColor3 = Theme.Stroke,
    Text = "K",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Active = true,
}, screenGui)
corner(toggleBtn, 24)
stroke(toggleBtn, Theme.Accent, 1.5)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    playSound(main.Visible)
end)

local tDrag, tStart, tPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        tDrag = true
        tStart = input.Position
        tPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if tDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - tStart
        toggleBtn.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + d.X,
                                        tPos.Y.Scale, tPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        tDrag = false
    end
end)

-- Mini mode button
local minimized = false
local originalSize = main.Size
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        originalSize = main.Size
        main.Size = UDim2.new(0, 260, 0, 38)
    else
        main.Size = originalSize
    end
    sidebar.Visible = not minimized
    contentHolder.Visible = not minimized
end)

-- ============================================================
-- [ SECTION 20 ] MOVEMENT LOGIC
-- ============================================================
local flyAO, flyLV, flyAttach

local function cleanupFly()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, name in ipairs({"KurayamiFlyAO", "KurayamiFlyLV", "KurayamiFlyAttach"}) do
        local o = hrp:FindFirstChild(name)
        if o then o:Destroy() end
    end
    flyAO, flyLV, flyAttach = nil, nil, nil
end

local function setupFly()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    cleanupFly()

    local att = Instance.new("Attachment", hrp)
    att.Name = "KurayamiFlyAttach"
    flyAttach = att

    local ao = Instance.new("AlignOrientation", hrp)
    ao.Name = "KurayamiFlyAO"
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.Attachment0 = att
    ao.MaxTorque = 9e9
    ao.Responsiveness = 50
    flyAO = ao

    local lv = Instance.new("LinearVelocity", hrp)
    lv.Name = "KurayamiFlyLV"
    lv.Attachment0 = att
    lv.MaxForce = 9e9
    lv.VectorVelocity = Vector3.zero
    flyLV = lv
end

-- Movement loop
RunService.Stepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Speed
    hum.WalkSpeed = State.Speed and State.SpeedValue or 16

    -- Jump
    if State.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = State.JumpValue
    end

    -- Noclip
    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Invisible
    if State.Invisible then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = 1
            end
        end
    end

    -- Fly
    if State.Fly then
        if not flyLV or not flyLV.Parent then setupFly() end
        if flyLV then
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            flyLV.VectorVelocity = dir.Magnitude > 0 and dir.Unit * State.FlyValue or Vector3.zero
            flyAO.CFrame = cam.CFrame
        end
    else
        if flyLV then cleanupFly() end
    end

    -- Godmode + Lock Health
    if State.God or State.LockHealth then
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end

    -- Auto heal
    if State.AutoHeal and hum.Health < hum.MaxHealth then
        hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.02)
    end

    -- Anti-void
    if State.AntiVoid and hrp.Position.Y < -100 then
        local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then hrp.CFrame = sp.CFrame + Vector3.new(0, 5, 0) end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Ctrl+Click TP
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if State.CtrlClickTP and input.UserInputType == Enum.UserInputType.MouseButton1
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and mouse.Hit then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            toast("วาร์ปไปจุดที่คลิก", Theme.Success, 1.2)
        end
    end
end)

-- ============================================================
-- [ SECTION 21 ] VISUAL LOGIC
-- ============================================================
local originalLighting = {
    Brightness    = Lighting.Brightness,
    FogEnd        = Lighting.FogEnd,
    FogStart      = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient       = Lighting.Ambient,
}

task.spawn(function()
    while task.wait(0.5) do
        if State.Fullbright then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.Ambient = originalLighting.Ambient
        end

        if State.RemoveFog then
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 1e6
        else
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart
        end

        if State.RemoveShadow then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end

        if State.FPSBoost then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
end)

-- ============================================================
-- [ SECTION 22 ] ESP LOOP + PLAYER HANDLER
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        if State.ESP then
            refreshESP()
        else
            clearESP()
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        if State.ESP then applyESP(c, p) end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then
        safeCall(function() espHighlights[p]:Destroy() end)
    end
    espHighlights[p] = nil
end)

-- ============================================================
-- [ SECTION 23 ] CHARACTER RESPAWN HANDLER
-- ============================================================
local function onCharAdded(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and State.God then
        local ff = Instance.new("ForceField", char)
        ff.Name = "KurayamiGodFF"
    end
    if State.ESP then applyESP(char, player) end
end

if player.Character then onCharAdded(player.Character) end
player.CharacterAdded:Connect(onCharAdded)

-- ============================================================
-- [ SECTION 24 ] ANTI-AFK (เปิดอัตโนมัติ)
-- ============================================================
safeCall(function()
    player.Idled:Connect(function()
        if not State.AntiAFK then return end
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- ============================================================
-- [ SECTION 25 ] ANTI-FLING
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if State.AntiFling then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 200 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
end)

-- ============================================================
-- [ SECTION 26 ] AUTO REJOIN
-- ============================================================
safeCall(function()
    game:GetService("Players").PlayerRemoving:Connect(function()
        if State.AutoRejoin and #Players:GetPlayers() <= 1 then
            task.wait(2)
            safeCall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, player)
            end)
        end
    end)
end)

-- ============================================================
-- [ SECTION 27 ] KEYBIND SYSTEM
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == State.UIKey then
        main.Visible = not main.Visible
        playSound(main.Visible)
        return
    end
    for stateName, kc in pairs(State.Keybinds) do
        if input.KeyCode == kc and State[stateName] ~= nil then
            State[stateName] = not State[stateName]
            toast("Keybind: " .. stateName .. " = " .. tostring(State[stateName]), Theme.Accent2, 1.5)
        end
    end
end)

-- ============================================================
-- [ SECTION 28 ] LIVE STATS UPDATER (FPS ทุก 1.5 วิ)
-- ============================================================
local fpsCounter = 0
local lastFpsUpdate = tick()

RunService.RenderStepped:Connect(function()
    fpsCounter += 1
    if tick() - lastFpsUpdate >= 1.5 then
        local fps = math.floor(fpsCounter / (tick() - lastFpsUpdate))
        fpsCounter = 0
        lastFpsUpdate = tick()

        statFPS.Text = tostring(fps)

        local ping = safeCall(function()
            return math.floor(player:GetNetworkPing() * 1000)
        end) or 0
        statPing.Text = tostring(ping)

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            statHealth.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        else
            statHealth.Text = "-- / --"
        end

        statMap.Text = PlaceEntry.name
        statPlayers.Text = tostring(#Players:GetPlayers())

        local elapsed = math.floor(tick() - State.SessionStart)
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        sessionLbl.Text = string.format("Session: %02d:%02d:%02d", h, m, s)
    end
end)

-- ============================================================
-- [ SECTION 29 ] MOBILE UI SCALE + STARTUP
-- ============================================================
if isMobile then
    local vp = Workspace.CurrentCamera.ViewportSize
    main.Size = UDim2.new(0, math.min(400, vp.X - 30), 0, math.min(520, vp.Y - 80))
end

switchTab("Main")
toast("🌟 Kurayami Hub v3 โหลดสำเร็จ!", Theme.Accent, 3)
task.wait(0.5)
toast("กดปุ่ม K หรือ RightShift เพื่อเปิด-ปิด UI", Theme.Accent2, 3)
