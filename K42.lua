loadstring(game:HttpGet("https://rizz-rxs.xyz/Onyx-Zero/api?key=c40e1d634fa2bd89b1f8f97bc1048ee8&_s=734591b452252fba81e9d8d3a5d3f7691d311b6f799acb8615986f3c5994d185"))()    Fly = false, FlyValue = 60,
    Noclip = false,
    Fullbright = false,
    ESP = false, ESPColor = Color3.fromRGB(236, 72, 153),
    AntiAFK = true,
}
local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- Forward declarations (สำหรับปุ่ม Refresh ALL)
local refreshPlayerDropdown
local refreshWaypointDropdown
local refreshManageList

-- ============================================================
-- [ 4 ] WAYPOINT SYSTEM (Per-PlaceId + File I/O)
-- ============================================================
local SAVE_FILE = "k42_waypoints.json"
local hasFileIO = (typeof(writefile) == "function") and (typeof(readfile) == "function")

local WaypointData = {}  -- { ["PlaceId"] = { name = "Game", locations = {{name,x,y,z,order}} } }

local function loadWaypoints()
    if not hasFileIO then return end
    pcall(function()
        if isfile and isfile(SAVE_FILE) then
            local decoded = HttpService:JSONDecode(readfile(SAVE_FILE))
            if type(decoded) == "table" then
                WaypointData = decoded
            end
        end
    end)
end

local function saveWaypoints()
    if not hasFileIO then return end
    pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(WaypointData))
    end)
end

local function getPlaceKey()
    return tostring(game.PlaceId)
end

local function getCurrentPlace()
    local key = getPlaceKey()
    if not WaypointData[key] then
        WaypointData[key] = {
            name = game.Name or "Unknown",
            locations = {}
        }
    end
    return WaypointData[key]
end

local function getWaypoints()
    return getCurrentPlace().locations
end

local function addWaypoint(name, x, y, z)
    local locs = getWaypoints()
    for _, loc in ipairs(locs) do
        if loc.name == name then
            loc.x, loc.y, loc.z = x, y, z
            saveWaypoints()
            return true
        end
    end
    table.insert(locs, {
        name = name, x = x, y = y, z = z,
        order = #locs + 1
    })
    saveWaypoints()
    return true
end

local function removeWaypoint(index)
    local locs = getWaypoints()
    if locs[index] then
        table.remove(locs, index)
        for j, l in ipairs(locs) do l.order = j end
        saveWaypoints()
    end
end

local function renameWaypoint(index, newName)
    local locs = getWaypoints()
    if locs[index] then
        locs[index].name = newName
        saveWaypoints()
    end
end

local function reorderWaypoints(fromIdx, toIdx)
    local locs = getWaypoints()
    if fromIdx == toIdx then return end
    local item = table.remove(locs, fromIdx)
    table.insert(locs, toIdx, item)
    for j, l in ipairs(locs) do l.order = j end
    saveWaypoints()
end

loadWaypoints()
getCurrentPlace()

-- ============================================================
-- [ 5 ] CONFIRM DIALOG (Custom)
-- ============================================================
local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return player:WaitForChild("PlayerGui")
end

local confirmGui = Instance.new("ScreenGui")
confirmGui.Name = "k42_Confirm"
confirmGui.ResetOnSpawn = false
confirmGui.IgnoreGuiInset = true
confirmGui.DisplayOrder = 999
confirmGui.Parent = getGuiParent()

local confirmOverlay = Instance.new("Frame")
confirmOverlay.Size = UDim2.new(1, 0, 1, 0)
confirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
confirmOverlay.BackgroundTransparency = 0.5
confirmOverlay.Visible = false
confirmOverlay.ZIndex = 100
confirmOverlay.Parent = confirmGui

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0, 320, 0, 190)
confirmBox.Position = UDim2.new(0.5, -160, 0.5, -95)
confirmBox.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
confirmBox.BorderSizePixel = 0
confirmBox.ZIndex = 101
confirmBox.Parent = confirmOverlay
local cCorner = Instance.new("UICorner"); cCorner.CornerRadius = UDim.new(0, 12); cCorner.Parent = confirmBox
local cStroke = Instance.new("UIStroke"); cStroke.Color = Color3.fromRGB(142, 68, 173); cStroke.Thickness = 1.5; cStroke.Parent = confirmBox

local confirmTitle = Instance.new("TextLabel")
confirmTitle.Size = UDim2.new(1, -20, 0, 30)
confirmTitle.Position = UDim2.new(0, 10, 0, 12)
confirmTitle.BackgroundTransparency = 1
confirmTitle.Text = "ยืนยันการทำงาน"
confirmTitle.TextColor3 = Color3.fromRGB(236, 72, 153)
confirmTitle.TextSize = 15
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.ZIndex = 101
confirmTitle.Parent = confirmBox

local confirmMsg = Instance.new("TextLabel")
confirmMsg.Size = UDim2.new(1, -20, 0, 60)
confirmMsg.Position = UDim2.new(0, 10, 0, 45)
confirmMsg.BackgroundTransparency = 1
confirmMsg.Text = ""
confirmMsg.TextColor3 = Color3.fromRGB(245, 243, 255)
confirmMsg.TextSize = 13
confirmMsg.Font = Enum.Font.Gotham
confirmMsg.TextWrapped = true
confirmMsg.ZIndex = 101
confirmMsg.Parent = confirmBox

local confirmYes = Instance.new("TextButton")
confirmYes.Size = UDim2.new(0, 140, 0, 36)
confirmYes.Position = UDim2.new(0, 15, 1, -50)
confirmYes.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
confirmYes.Text = "ยืนยัน"
confirmYes.TextColor3 = Color3.new(1, 1, 1)
confirmYes.TextSize = 13
confirmYes.Font = Enum.Font.GothamBold
confirmYes.ZIndex = 101
confirmYes.Parent = confirmBox
local yCorner = Instance.new("UICorner"); yCorner.CornerRadius = UDim.new(0, 6); yCorner.Parent = confirmYes

local confirmNo = Instance.new("TextButton")
confirmNo.Size = UDim2.new(0, 140, 0, 36)
confirmNo.Position = UDim2.new(1, -155, 1, -50)
confirmNo.BackgroundColor3 = Color3.fromRGB(55, 65, 81)
confirmNo.Text = "ยกเลิก"
confirmNo.TextColor3 = Color3.new(1, 1, 1)
confirmNo.TextSize = 13
confirmNo.Font = Enum.Font.GothamBold
confirmNo.ZIndex = 101
confirmNo.Parent = confirmBox
local nCorner = Instance.new("UICorner"); nCorner.CornerRadius = UDim.new(0, 6); nCorner.Parent = confirmNo

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
-- [ 6 ] CREATE WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    name = "k42 Hub",
    subtitle = "Waypoint Edition",
    sidebarLayout = true,
    theme = "amethyst",
})

-- ============================================================
-- [ 7 ] TABS
-- ============================================================
local MainTab = Window:CreateTab("Main", nil)
local PlayerTab = Window:CreateTab("Player", nil)
local VisualTab = Window:CreateTab("Visual", nil)
local TeleportTab = Window:CreateTab("Teleport", nil)
local ManageTab = Window:CreateTab("Manage", nil)
local MiscTab = Window:CreateTab("Misc", nil)

-- ============================================================
-- [ 8 ] MAIN TAB
-- ============================================================
MainTab:CreateSection("Session")
MainTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})
MainTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
})
MainTab:CreateButton({
    Name = "Copy JobId",
    Callback = function()
        if setclipboard then setclipboard(game.JobId) end
    end
})

-- ============================================================
-- [ 9 ] PLAYER TAB (MOVEMENT)
-- ============================================================
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "sp",
    CurrentValue = 80,
    Flag = "SpeedSlider",
    Callback = function(v) State.SpeedValue = v end
})
PlayerTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(v) State.Speed = v end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = "jp",
    CurrentValue = 120,
    Flag = "JumpSlider",
    Callback = function(v) State.JumpValue = v end
})
PlayerTab:CreateToggle({
    Name = "Enable Jump",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(v) State.Jump = v end
})
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(v) State.InfJump = v end
})

PlayerTab:CreateSection("Flight")
PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 1,
    Suffix = "sp",
    CurrentValue = 60,
    Flag = "FlySlider",
    Callback = function(v) State.FlyValue = v end
})
PlayerTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(v) State.Fly = v end
})
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(v) State.Noclip = v end
})

-- ============================================================
-- [ 10 ] VISUAL TAB
-- ============================================================
VisualTab:CreateSection("Lighting")
VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(v) State.Fullbright = v end
})

VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(v) State.ESP = v end
})
VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = State.ESPColor,
    Flag = "ESPColor",
    Callback = function(color) State.ESPColor = color end
})

-- ============================================================
-- [ 11 ] TELEPORT TAB — PLAYER + WAYPOINT
-- ============================================================
TeleportTab:CreateSection("Teleport to Player")

local selectedPlayer = nil
local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(option) selectedPlayer = option[1] end
})

refreshPlayerDropdown = function()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    playerDropdown:Refresh(list)
end
refreshPlayerDropdown()

-- ⭐ ปุ่มรีเฟรชผู้เล่น
TeleportTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        refreshPlayerDropdown()
        Rayfield:Notify({Title = "Refreshed", Content = "Player list updated!", Duration = 2})
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if not selectedPlayer then
            Rayfield:Notify({Title = "Error", Content = "Please select a player first!", Duration = 3})
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        if not target or not target.Character then return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local mHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and mHRP then
            mHRP.CFrame = tHRP.CFrame + Vector3.new(3, 0, 3)
            Rayfield:Notify({Title = "Teleported", Content = "To " .. selectedPlayer, Duration = 2})
        end
    end
})

-- Auto-refresh player list
Players.PlayerAdded:Connect(function() task.wait(0.5) pcall(refreshPlayerDropdown) end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(refreshPlayerDropdown) end)

TeleportTab:CreateSection("Teleport to Waypoint")

local selectedWaypoint = nil
local waypointDropdown = TeleportTab:CreateDropdown({
    Name = "Select Waypoint",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "WaypointDropdown",
    Callback = function(option) selectedWaypoint = option[1] end
})

refreshWaypointDropdown = function()
    local list = {}
    for _, loc in ipairs(getWaypoints()) do
        table.insert(list, loc.name)
    end
    waypointDropdown:Refresh(list)
end
refreshWaypointDropdown()

-- ⭐ ปุ่มรีเฟรช Waypoint
TeleportTab:CreateButton({
    Name = "🔄 Refresh Waypoint List",
    Callback = function()
        refreshWaypointDropdown()
        Rayfield:Notify({Title = "Refreshed", Content = "Waypoint list updated!", Duration = 2})
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Waypoint",
    Callback = function()
        if not selectedWaypoint then
            Rayfield:Notify({Title = "Error", Content = "Please select a waypoint first!", Duration = 3})
            return
        end
        for _, loc in ipairs(getWaypoints()) do
            if loc.name == selectedWaypoint then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z)
                    Rayfield:Notify({Title = "Teleported", Content = "To " .. loc.name, Duration = 2})
                end
                return
            end
        end
    end
})

TeleportTab:CreateSection("Create Waypoint")

local newWaypointName = ""
TeleportTab:CreateInput({
    Name = "Waypoint Name",
    CurrentValue = "",
    PlaceholderText = "Enter name...",
    RemoveTextAfterFocusLost = false,
    Flag = "NewWaypointInput",
    Callback = function(text) newWaypointName = text end
})

TeleportTab:CreateButton({
    Name = "Save Current Location",
    Callback = function()
        if newWaypointName == "" then
            Rayfield:Notify({Title = "Error", Content = "Please enter a name!", Duration = 3})
            return
        end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Rayfield:Notify({Title = "Error", Content = "Character not found!", Duration = 3})
            return
        end
        local pos = hrp.Position
        askConfirm("บันทึกตำแหน่ง '" .. newWaypointName .. "'?\nตำแหน่ง: "
            .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z), function()
            addWaypoint(newWaypointName, pos.X, pos.Y, pos.Z)
            refreshWaypointDropdown()
            refreshManageList()
            Rayfield:Notify({Title = "Saved", Content = "'" .. newWaypointName .. "' saved!", Duration = 3})
            newWaypointName = ""
        end)
    end
})

-- ============================================================
-- [ 12 ] MANAGE TAB — WAYPOINT LIST (Drag, Edit, Delete)
-- ============================================================
ManageTab:CreateSection("Waypoint Manager | " .. game.Name)

local manageFrame = Instance.new("ScrollingFrame")
manageFrame.Size = UDim2.new(1, 0, 0, 320)
manageFrame.BackgroundTransparency = 1
manageFrame.BorderSizePixel = 0
manageFrame.ScrollBarThickness = 4
manageFrame.ScrollBarImageColor3 = Color3.fromRGB(142, 68, 173)
manageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
manageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
manageFrame.Parent = ManageTab

local manageLayout = Instance.new("UIListLayout")
manageLayout.Padding = UDim.new(0, 6)
manageLayout.Parent = manageFrame

local manageCards = {}

refreshManageList = function()
    for _, card in ipairs(manageCards) do
        if card and card.Parent then card:Destroy() end
    end
    manageCards = {}

    local locs = getWaypoints()
    table.sort(locs, function(a, b) return (a.order or 0) < (b.order or 0) end)

    for i, loc in ipairs(locs) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 44)
        card.BackgroundColor3 = Color3.fromRGB(28, 23, 48)
        card.BorderSizePixel = 0
        card.Parent = manageFrame
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = card
        local cs = Instance.new("UIStroke"); cs.Color = Color3.fromRGB(50, 38, 70); cs.Parent = card

        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(1, -120, 1, 0)
        nameBtn.BackgroundTransparency = 1
        nameBtn.Text = "  " .. i .. ". " .. loc.name
        nameBtn.TextColor3 = Color3.fromRGB(245, 243, 255)
        nameBtn.TextSize = 12
        nameBtn.Font = Enum.Font.GothamBold
        nameBtn.TextXAlignment = Enum.TextXAlignment.Left
        nameBtn.Parent = card
        nameBtn.MouseButton1Click:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z)
                Rayfield:Notify({Title = "Teleported", Content = "To " .. loc.name, Duration = 2})
            end
        end)

        -- ปุ่มลาก (≡)
        local dragBtn = Instance.new("TextButton")
        dragBtn.Size = UDim2.new(0, 30, 1, -8)
        dragBtn.Position = UDim2.new(1, -100, 0, 4)
        dragBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
        dragBtn.Text = "≡"
        dragBtn.TextColor3 = Color3.fromRGB(167, 139, 250)
        dragBtn.TextSize = 16
        dragBtn.Font = Enum.Font.GothamBold
        dragBtn.Parent = card
        local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0, 5); dc.Parent = dragBtn

        -- ปุ่มแก้ไข (✎)
        local editBtn = Instance.new("TextButton")
        editBtn.Size = UDim2.new(0, 30, 1, -8)
        editBtn.Position = UDim2.new(1, -66, 0, 4)
        editBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
        editBtn.Text = "✎"
        editBtn.TextColor3 = Color3.new(1, 1, 1)
        editBtn.TextSize = 13
        editBtn.Font = Enum.Font.GothamBold
        editBtn.Parent = card
                local ec = Instance.new("UICorner"); ec.CornerRadius = UDim.new(0, 5); ec.Parent = editBtn
        editBtn.MouseButton1Click:Connect(function()
            local editInput = Instance.new("TextBox")
            editInput.Size = UDim2.new(1, -20, 0, 30)
            editInput.Position = UDim2.new(0, 10, 0, 115)
            editInput.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
            editInput.Text = loc.name
            editInput.TextColor3 = Color3.fromRGB(245, 243, 255)
            editInput.TextSize = 12
            editInput.Font = Enum.Font.Gotham
            editInput.ClearTextOnFocus = false
            editInput.ZIndex = 102
            editInput.Parent = confirmBox
            local eiCorner = Instance.new("UICorner"); eiCorner.CornerRadius = UDim.new(0, 5); eiCorner.Parent = editInput

            confirmTitle.Text = "แก้ไขชื่อ Waypoint"
            confirmMsg.Text = "ใส่ชื่อใหม่:"
            confirmOverlay.Visible = true
            confirmCallback = function()
                local newName = editInput.Text
                if newName ~= "" then
                    renameWaypoint(i, newName)
                    refreshManageList()
                    refreshWaypointDropdown()
                    Rayfield:Notify({Title = "Renamed", Content = "'" .. loc.name .. "' → '" .. newName .. "'", Duration = 2})
                end
                editInput:Destroy()
            end
        end)

        -- ปุ่มลบ (✕)
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 30, 1, -8)
        delBtn.Position = UDim2.new(1, -32, 0, 4)
        delBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        delBtn.Text = "✕"
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.TextSize = 13
        delBtn.Font = Enum.Font.GothamBold
        delBtn.Parent = card
        local dlc = Instance.new("UICorner"); dlc.CornerRadius = UDim.new(0, 5); dlc.Parent = delBtn
        delBtn.MouseButton1Click:Connect(function()
            askConfirm("ลบ Waypoint '" .. loc.name .. "'?", function()
                removeWaypoint(i)
                refreshManageList()
                refreshWaypointDropdown()
                Rayfield:Notify({Title = "Deleted", Content = "'" .. loc.name .. "' deleted", Duration = 2})
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
                local newOrder = math.clamp(startOrder + shift, 1, #getWaypoints())
                if newOrder ~= i then
                    reorderWaypoints(i, newOrder)
                    isDragging = false
                    refreshManageList()
                    refreshWaypointDropdown()
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

        table.insert(manageCards, card)
    end
end

-- ============================================================
-- Refresh Options (Manage Tab)
-- ============================================================
ManageTab:CreateSection("Refresh Options")

ManageTab:CreateButton({
    Name = "🔄 Refresh Manage List",
    Callback = function()
        refreshManageList()
        Rayfield:Notify({Title = "Refreshed", Content = "Manage list updated!", Duration = 2})
    end
})

ManageTab:CreateButton({
    Name = "🔄 Refresh ALL (Dropdowns + List)",
    Callback = function()
        refreshManageList()
        pcall(refreshWaypointDropdown)
        pcall(refreshPlayerDropdown)
        Rayfield:Notify({Title = "Refreshed", Content = "All lists updated!", Duration = 2})
    end
})

ManageTab:CreateSection("Danger Zone")

ManageTab:CreateButton({
    Name = "🗑️ Clear All Waypoints (This Place)",
    Callback = function()
        askConfirm("ลบ Waypoint ทั้งหมดในแมพนี้?", function()
            getCurrentPlace().locations = {}
            saveWaypoints()
            refreshManageList()
            refreshWaypointDropdown()
            Rayfield:Notify({Title = "Cleared", Content = "All waypoints removed.", Duration = 2})
        end)
    end
})

-- เรียก refresh ครั้งแรก
task.wait(0.5)
refreshManageList()

-- ============================================================
-- [ 13 ] MISC TAB
-- ============================================================
MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFKToggle",
    Callback = function(v) State.AntiAFK = v end
})

-- ============================================================
-- [ 14 ] MOVEMENT LOGIC
-- ============================================================
local flyAttachment, flyLinearVelocity, flyAlignOrientation

local function setupFly()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if flyAttachment then flyAttachment:Destroy() end
    if flyLinearVelocity then flyLinearVelocity:Destroy() end
    if flyAlignOrientation then flyAlignOrientation:Destroy() end

    flyAttachment = Instance.new("Attachment", hrp)
    flyAttachment.Name = "k42FlyAttach"

    flyLinearVelocity = Instance.new("LinearVelocity", hrp)
    flyLinearVelocity.Attachment0 = flyAttachment
    flyLinearVelocity.MaxForce = math.huge
    flyLinearVelocity.VectorVelocity = Vector3.zero

    flyAlignOrientation = Instance.new("AlignOrientation", hrp)
    flyAlignOrientation.Attachment0 = flyAttachment
    flyAlignOrientation.MaxTorque = math.huge
    flyAlignOrientation.Responsiveness = 50
end

local function cleanupFly()
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    if flyLinearVelocity then flyLinearVelocity:Destroy() flyLinearVelocity = nil end
    if flyAlignOrientation then flyAlignOrientation:Destroy() flyAlignOrientation = nil end
end

RunService.Stepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    hum.WalkSpeed = State.Speed and State.SpeedValue or 16
    if State.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = State.JumpValue
    end
    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    if State.Fly then
        if not flyLinearVelocity or not flyLinearVelocity.Parent then setupFly() end
        if flyLinearVelocity then
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            flyLinearVelocity.VectorVelocity = dir.Magnitude > 0 and dir.Unit * State.FlyValue or Vector3.zero
            flyAlignOrientation.CFrame = cam.CFrame
        end
    else
        if flyLinearVelocity then cleanupFly() end
    end
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if State.InfJump and input.KeyCode == Enum.KeyCode.Space then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
-- [ 15 ] VISUAL LOGIC
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.Fullbright then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        end
    end
end)

-- ESP
local espHighlights = {}
local function clearESP()
    for plr, hl in pairs(espHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espHighlights = {}
end

local function applyESP(char, plr)
    if not char then return end
    local hl = espHighlights[plr]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "k42ESP"
        hl.FillColor = State.ESPColor
        hl.FillTransparency = 0.3
        hl.OutlineColor = State.ESPColor
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        espHighlights[plr] = hl
    end
    hl.FillColor = State.ESPColor
    hl.OutlineColor = State.ESPColor
end

task.spawn(function()
    while task.wait(1) do
        if State.ESP then
            clearESP()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then applyESP(p.Character, p) end
            end
        else
            if next(espHighlights) then clearESP() end
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
        pcall(function() espHighlights[p]:Destroy() end)
    end
    espHighlights[p] = nil
end)

-- ============================================================
-- [ 16 ] CHARACTER RESPAWN
-- ============================================================
local function onCharAdded(char)
    task.wait(1)
    cleanupFly()
    if State.ESP then applyESP(char, player) end
end
if player.Character then onCharAdded(player.Character) end
player.CharacterAdded:Connect(onCharAdded)

-- ============================================================
-- [ 17 ] ANTI-AFK
-- ============================================================
player.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- ============================================================
-- [ 18 ] NOTIFICATION
-- ============================================================
Rayfield:Notify({
    Title = "k42 Hub Loaded",
    Content = "Waypoint Edition พร้อมใช้งาน!",
    Duration = 5,
})
