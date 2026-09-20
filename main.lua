-- [[ Kuryami Hub v2 - Modern Single UI (2026) ]] --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local fileName = "KuryamiHub_V2_Data.json"
local savedLocations = {}

-- 1. ระบบโหลด/เซฟข้อมูลผ่าน Executor
if isfile and isfile(fileName) then
    pcall(function() savedLocations = HttpService:JSONDecode(readfile(fileName)) end)
end
local function saveData()
    if writefile then pcall(function() writefile(fileName, HttpService:JSONEncode(savedLocations)) end) end
end

-- 2. สร้าง ScreenGui ใน CoreGui เพื่อความเสถียร
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KuryamiHub_V2"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

-- 3. หน้าต่างยืนยันความปลอดภัย (Anti-Misclick)
local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.new(0, 260, 0, 130)
confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -65)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
confirmFrame.ZIndex = 10
confirmFrame.Visible = false
confirmFrame.Parent = screenGui
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 8)
local cfStroke = Instance.new("UIStroke", confirmFrame)
cfStroke.Color = Color3.fromRGB(41, 128, 185)

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -20, 0, 40)
confirmText.Position = UDim2.new(0, 10, 0, 20)
confirmText.BackgroundTransparency = 1
confirmText.Text = "ยืนยันรายการ?"
confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmText.TextSize = 14
confirmText.Font = Enum.Font.SourceSansBold
confirmText.ZIndex = 10
confirmText.Parent = confirmFrame

local yesBtn = Instance.new("TextButton")
yesBtn.Size = UDim2.new(0, 90, 0, 32)
yesBtn.Position = UDim2.new(0, 30, 0, 75)
yesBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
yesBtn.Text = "ยืนยัน"
yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.ZIndex = 10
yesBtn.Parent = confirmFrame
Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 5)

local noBtn = Instance.new("TextButton")
noBtn.Size = UDim2.new(0, 90, 0, 32)
noBtn.Position = UDim2.new(0, 140, 0, 75)
noBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
noBtn.Text = "ยกเลิก"
noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noBtn.ZIndex = 10
noBtn.Parent = confirmFrame
Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 5)

local currentCallback = nil
local function askConfirmation(msg, cb)
    confirmText.Text = msg
    confirmFrame.Visible = true
    currentCallback = cb
end
yesBtn.MouseButton1Click:Connect(function() confirmFrame.Visible = false if currentCallback then currentCallback() end end)
noBtn.MouseButton1Click:Connect(function() confirmFrame.Visible = false end)

-- ==========================================
-- 4. ดีไซน์หน้าต่างหลัก (MAIN MENU V2 STYLE)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 560, 0, 360)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 16, 21)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local mfStroke = Instance.new("UIStroke", mainFrame)
mfStroke.Color = Color3.fromRGB(41, 128, 185)
mfStroke.Thickness = 1.5

-- [ แถบซ้ายมือ: โปรไฟล์ & เมนูแท็บ ]
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 160, 1, -20)
leftPanel.Position = UDim2.new(0, 10, 0, 10)
leftPanel.BackgroundColor3 = Color3.fromRGB(17, 22, 29)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame
Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 8)
local lpStroke = Instance.new("UIStroke", leftPanel)
lpStroke.Color = Color3.fromRGB(30, 40, 50)

-- กล่องโปรไฟล์ผู้เล่น (Player Card)
local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(1, -16, 0, 110)
profileCard.Position = UDim2.new(0, 8, 0, 8)
profileCard.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
profileCard.BorderSizePixel = 0
profileCard.Parent = leftPanel
Instance.new("UICorner", profileCard).CornerRadius = UDim.new(0, 6)
local pcStroke = Instance.new("UIStroke", profileCard)
pcStroke.Color = Color3.fromRGB(41, 128, 185)

-- รูปภาพโปรไฟล์ตัวละคร
local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(0, 40, 0, 40)
avatarImg.Position = UDim2.new(0, 8, 0, 8)
avatarImg.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"
avatarImg.Parent = profileCard
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

-- ชื่อผู้เล่น
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -60, 0, 20)
nameLabel.Position = UDim2.new(0, 54, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = player.DisplayName
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextSize = 12
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = profileCard

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(1, -60, 0, 15)
userLabel.Position = UDim2.new(0, 54, 0, 24)
userLabel.BackgroundTransparency = 1
userLabel.Text = "@"..player.Name
userLabel.TextColor3 = Color3.fromRGB(140, 150, 160)
userLabel.TextSize = 10
userLabel.Font = Enum.Font.SourceSans
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Parent = profileCard

-- หลอดเลือด (Health Bar)
local hpBg = Instance.new("Frame")
hpBg.Size = UDim2.new(1, -16, 0, 6)
hpBg.Position = UDim2.new(0, 8, 0, 55)
hpBg.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
hpBg.BorderSizePixel = 0
hpBg.Parent = profileCard
local hpBar = Instance.new("Frame")
hpBar.Size = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
hpBar.BorderSizePixel = 0
hpBar.Parent = hpBg

-- ข้อมูลแมพ & FPS
local statLabel = Instance.new("TextLabel")
statLabel.Size = UDim2.new(1, -16, 0, 40)
statLabel.Position = UDim2.new(0, 8, 0, 65)
statLabel.BackgroundTransparency = 1
statLabel.Text = "Map: Loading...\nFPS: 60 | HP: 100/100"
statLabel.TextColor3 = Color3.fromRGB(180, 190, 200)
statLabel.TextSize = 10
statLabel.Font = Enum.Font.SourceSans
statLabel.TextXAlignment = Enum.TextXAlignment.Left
statLabel.TextYAlignment = Enum.TextYAlignment.Top
statLabel.Parent = profileCard

-- รันข้อมูลสถานะแบบ Realtime
local fpsCount = 0
RunService.RenderStepped:Connect(function(dt)
    fpsCount = math.floor(1/dt)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hpBar.Size = UDim2.new(math.clamp(hum.Health/hum.MaxHealth, 0, 1), 0, 1, 0)
        statLabel.Text = "Map: [UP] ฐาน\nFPS: "..fpsCount.." | HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
    end
end)

-- ปุ่มเลือกหน้าหลัก (Home Tab Button)
local homeTabBtn = Instance.new("TextButton")
homeTabBtn.Size = UDim2.new(1, -16, 0, 35)
homeTabBtn.Position = UDim2.new(0, 8, 0, 130)
homeTabBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
homeTabBtn.Text = "🏠 หน้าหลัก"
homeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
homeTabBtn.Font = Enum.Font.SourceSansBold
homeTabBtn.TextSize = 13
homeTabBtn.Parent = leftPanel
Instance.new("UICorner", homeTabBtn).CornerRadius = UDim.new(0, 5)

-- ชื่อโปรเจกต์หัวข้อใหญ่บนขวา
local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(0, 200, 0, 30)
hubTitle.Position = UDim2.new(0, 180, 0, 10)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "RUNLUA-HUB STORE | KURYAMI V2"
hubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hubTitle.TextSize = 14
hubTitle.Font = Enum.Font.SourceSansBold
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.Parent = mainFrame

-- ปุ่มกากบาทปิดเมนู (X) พร้อมระบบยืนยัน
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function()
    askConfirmation("ปิดการทำงานของสคริปต์ Kuryami Hub v2?", function() screenGui:Destroy() end)
end)

-- [ แถบเนื้อหาขวามือ: กล่องฟังก์ชัน ]
local rightPanel = Instance.new("ScrollingFrame")
rightPanel.Size = UDim2.new(1, -190, 1, -60)
rightPanel.Position = UDim2.new(0, 180, 0, 50)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ScrollBarThickness = 4
rightPanel.Parent = mainFrame
local rpLayout = Instance.new("UIListLayout")
rpLayout.Padding = UDim.new(0, 6)
rpLayout.Parent = rightPanel

-- ช่องและปุ่มเซฟพิกัด (ย้ายมาอยู่ในบอร์ดขวา)
local actionHeader = Instance.new("Frame")
actionHeader.Size = UDim2.new(1, -10, 0, 40)
actionHeader.BackgroundTransparency = 1
actionHeader.Parent = rightPanel

local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(1, -100, 1, 0)
nameInput.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.PlaceholderText = "พิมพ์ชื่อจุดตำแหน่งใหม่..."
nameInput.Text = ""
nameInput.Parent = actionHeader
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", nameInput).Color = Color3.fromRGB(40, 50, 65)

local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(0, 90, 1, 0)
addButton.Position = UDim2.new(1, -90, 0, 0)
addButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
addButton.Text = "เซฟพิกัด"
addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addButton.Font = Enum.Font.SourceSansBold
addButton.Parent = actionHeader
-- 1. หน้าต่างยืนยันความปลอดภัย (Confirmation Pop-up)
-- ==========================================
local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.new(0, 260, 0, 140)
confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
confirmFrame.BorderSizePixel = 0
confirmFrame.ZIndex = 10
confirmFrame.Visible = false
confirmFrame.Parent = screenGui
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", confirmFrame).Color = Color3.fromRGB(155, 89, 182)

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -20, 0, 50)
confirmText.Position = UDim2.new(0, 10, 0, 20)
confirmText.BackgroundTransparency = 1
confirmText.Text = "คุณแน่ใจหรือไม่ที่จะทำรายการนี้?"
confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmText.TextSize = 14
confirmText.Font = Enum.Font.SourceSansBold
confirmText.TextWrapped = true
confirmText.ZIndex = 10
confirmText.Parent = confirmFrame

local yesBtn = Instance.new("TextButton")
yesBtn.Size = UDim2.new(0, 100, 0, 35)
yesBtn.Position = UDim2.new(0, 20, 0, 85)
yesBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
yesBtn.Text = "ใช่, ยืนยัน"
yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.ZIndex = 10
yesBtn.Parent = confirmFrame
Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)

local noBtn = Instance.new("TextButton")
noBtn.Size = UDim2.new(0, 100, 0, 35)
noBtn.Position = UDim2.new(0, 140, 0, 85)
noBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
noBtn.Text = "ยกเลิก"
noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noBtn.ZIndex = 10
noBtn.Parent = confirmFrame
Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)

local currentCallback = nil
local function askConfirmation(message, callback)
    confirmText.Text = message
    confirmFrame.Visible = true
    currentCallback = callback
end
yesBtn.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    if currentCallback then currentCallback() end
end)
noBtn.MouseButton1Click:Connect(function() confirmFrame.Visible = false end)


-- ==========================================
-- 2. หน้าต่างหลักของ HUB (Main Window Design)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 320)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- เพิ่มขอบแสงนีออนสีม่วงสุดเท่
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(142, 68, 173)
mainStroke.Thickness = 1.5

-- แถบซ้ายมือ (Sidebar / Tabs Menu)
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 120, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame
local sideCorner = Instance.new("UICorner", sideBar)
sideCorner.CornerRadius = UDim.new(0, 12)

-- โลโก้ของ Hub
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 50)
logo.BackgroundTransparency = 1
logo.Text = "Kuryami Hub"
logo.TextColor3 = Color3.fromRGB(187, 143, 206)
logo.TextSize = 18
logo.Font = Enum.Font.SourceSansBold
logo.Parent = sideBar

-- ปุ่มเลือกแท็บเมนู
local tab1 = Instance.new("TextButton")
tab1.Size = UDim2.new(1, -10, 0, 35)
tab1.Position = UDim2.new(0, 5, 0, 60)
tab1.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
tab1.Text = "📍 Teleport"
tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1.TextSize = 14
tab1.Font = Enum.Font.SourceSansBold
tab1.Parent = sideBar
Instance.new("UICorner", tab1).CornerRadius = UDim.new(0, 6)

-- แถบเนื้อหาฝั่งขวา (Content Area)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -130, 1, -20)
contentFrame.Position = UDim2.new(0, 125, 0, 10)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- ปุ่มกากบาทปิดสคริปต์หลัก (X Button) พร้อมระบบยืนยัน
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    askConfirmation("คุณต้องการปิดสคริปต์ Kuryami Hub ใช่หรือไม่?", function()
        screenGui:Destroy()
    end)
end)

-- ช่องกรอกชื่อพิกัด
local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0, 200, 0, 35)
nameInput.Position = UDim2.new(0, 5, 0, 10)
nameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.PlaceholderText = "พิมพ์ชื่อจุดตำแหน่งใหม่..."
nameInput.Text = ""
nameInput.Parent = contentFrame
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

-- ปุ่มบันทึกพิกัด (Add Location)
local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(0, 80, 0, 35)
addButton.Position = UDim2.new(0, 210, 0, 10)
addButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
addButton.Text = "เซฟพิกัด"
addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addButton.Font = Enum.Font.SourceSansBold
addButton.Parent = contentFrame
Instance.new("UICorner", addButton).CornerRadius = UDim.new(0, 6)
applyButtonEffect(addButton, Color3.fromRGB(46, 204, 113), Color3.fromRGB(39, 174, 96))

-- รายการเลื่อนแสดงจุดวาร์ป (Scrolling List)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -5, 1, -60)
scrollFrame.Position = UDim2.new(0, 5, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = contentFrame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.Parent = scrollFrame

-- ฟังก์ชันอัปเดตรีเฟรชลิสต์จุดวาร์ป
local function refreshList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for name, pos in pairs(savedLocations) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -8, 0, 40)
        itemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        itemFrame.Parent = scrollFrame
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)

        -- ปุ่มสำหรับกดวาร์ป
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(1, -110, 1, 0)
        tpBtn.BackgroundTransparency = 1
        tpBtn.Text = "  📍 " .. name
        tpBtn.TextColor3 = Color3.fromRGB(242, 243, 244)
        tpBtn.TextXAlignment = Enum.TextXAlignment.Left
        tpBtn.TextSize = 14
        tpBtn.Parent = itemFrame

        -- ปุ่มแก้ไขชื่อ (Edit) อยู่ข้างหน้าปุ่มลบพอดี
        local editBtn = Instance.new("TextButton")
        editBtn.Size = UDim2.new(0, 45, 1, -12)
        editBtn.Position = UDim2.new(1, -95, 0, 6)
        editBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        editBtn.Text = "แก้ไข"
        editBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        editBtn.TextSize = 11
        editBtn.Font = Enum.Font.SourceSansBold
        editBtn.Parent = itemFrame
        Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 4)
        applyButtonEffect(editBtn, Color3.fromRGB(52, 152, 219), Color3.fromRGB(41, 128, 185))

        -- ปุ่มลบ (Delete) พร้อมระบบถามยืนยันความปลอดภัย
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 40, 1, -12)
        delBtn.Position = UDim2.new(1, -45, 0, 6)
        delBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        delBtn.Text = "ลบ"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextSize = 11
        delBtn.Font = Enum.Font.SourceSansBold
        delBtn.Parent = itemFrame
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        applyButtonEffect(delBtn, Color3.fromRGB(231, 76, 60), Color3.fromRGB(192, 41, 43))

        -- ลอจิกการทำงานเมื่อคลิกปุ่มวาร์ป
        tpBtn.MouseButton1Click:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(pos.x, pos.y, pos.z)
            end
        end)

        -- ลอจิกการทำงานระบบแก้ไขชื่อ (Edit Mode)
        editBtn.MouseButton1Click:Connect(function()
            nameInput.Text = name
            nameInput:CaptureFocus()
            addButton.Text = "อัปเดต"
            addButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            
            local connection
            connection = addButton.MouseButton1Click:Connect(function()
                local newName = nameInput.Text
                if newName ~= "" and newName ~= name then
                    savedLocations[newName] = savedLocations[name]
                    savedLocations[name] = nil
                    saveData()
                end
                addButton.Text = "เซฟพิกัด"
                addButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                nameInput.Text = ""
                refreshList()
                connection:Disconnect() -- ตัดการเชื่อมต่อทันทีเพื่อไม่ให้รันเบิ้ล
            end)
        end)

        -- ลอจิกการทำงานเมื่อกดปุ่มลบ (เรียกใช้ Pop-up ยืนยันก่อน)
        delBtn.MouseButton1Click:Connect(function()
            askConfirmation("คุณแน่ใจไหมว่าต้องการลบจุดวาร์ป '"..name.."' นี้?", function()
                savedLocations[name] = nil
                refreshList()
                saveData()
            end)
        end)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end

-- ลอจิกการบันทึกจุดวาร์ปทั่วไป
addButton.MouseButton1Click:Connect(function()
    local locName = nameInput.Text
    if locName ~= "" and not savedLocations[locName] and addButton.Text == "เซฟพิกัด" then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPos = character.HumanoidRootPart.Position
            savedLocations[locName] = {x = currentPos.X, y = currentPos.Y, z = currentPos.Z}
            nameInput.Text = ""
            refreshList()
            saveData()
        end
    end
end)

-- ==========================================
-- 3. ปุ่มกลมลอยเปิด-ปิด เมนูหลัก (Toggle Button)
-- ==========================================
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 45, 0, 45)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
toggleButton.Text = "K"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleButton).Color = Color3.fromRGB(255, 255, 255)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ==========================================
-- 4. ระบบแถมพิเศษ: Ctrl + คลิกซ้ายเพื่อวาร์ปด่วน (Click to TP)
-- ==========================================
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

-- เรียกใช้งานเพื่อแสดงผลรายการครั้งแรก
refreshList()
