-- Slap Battles - Admin/Spektatör Scripti
-- Telefon dostu, kapsamlı özellikler
-- Yer: LocalScript

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════
-- KONFIGÜRASYON
-- ═══════════════════════════════════════════════

local config = {
    walkSpeed = 50,        -- Yürüme hızı (normal 16)
    jumpPower = 80,        -- Zıplama gücü (normal 50)
    noclip = false,        -- Nesnelerin içinden geçme
    invisible = false,     -- Görünmezlik
    teleportDistance = 50, -- Işınlanma mesafesi
}

-- ═══════════════════════════════════════════════
-- DURUM TAKİBİ
-- ═══════════════════════════════════════════════

local isRunning = true
local selectedPlayer = nil
local followingPlayer = false
local viewingPlayer = false
local teleportTarget = nil

-- ═══════════════════════════════════════════════
-- 1. OYUNCU LİSTESİ VE SEÇİM
-- ═══════════════════════════════════════════════

local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player)
        end
    end
    return list
end

local function findPlayerByName(name)
    for _, player in pairs(Players:GetPlayers()) do
        if string.lower(player.Name):match(string.lower(name)) then
            return player
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════
-- 2. OYUNCU ÇEKME (BRING)
-- ═══════════════════════════════════════════════

local function bringPlayer(player)
    if not player or not player.Character then return end
    
    local targetPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    if not targetPos then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = targetPos.CFrame + Vector3.new(0, 3, 0)
        print("[✓] " .. player.Name .. " yanına çekildi!")
    end
end

-- ═══════════════════════════════════════════════
-- 3. OYUNCU YANINA IŞINLANMA
-- ═══════════════════════════════════════════════

local function teleportToPlayer(player)
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local primary = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if primary then
            primary.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 2)
            print("[✓] " .. player.Name .. "'ın yanına ışınlandın!")
        end
    end
end

-- ═══════════════════════════════════════════════
-- 4. EKRAN İZLEME (SPECTATE)
-- ═══════════════════════════════════════════════

local function spectatePlayer(player)
    if not player or not player.Character then return end
    
    viewingPlayer = true
    selectedPlayer = player
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Kamerayı oyuncuya odakla
        Camera.CameraSubject = humanoidRootPart
        Camera.CameraType = Enum.CameraType.Follow
        print("[✓] " .. player.Name .. " izleniyor...")
    end
end

local function stopSpectating()
    viewingPlayer = false
    selectedPlayer = nil
    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    Camera.CameraType = Enum.CameraType.Custom
    print("[✓] İzleme durduruldu.")
end

-- ═══════════════════════════════════════════════
-- 5. HIZ AYARI
-- ═══════════════════════════════════════════════

local function setWalkSpeed(speed)
    config.walkSpeed = speed
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            print("[✓] Hız ayarlandı: " .. speed)
        end
    end
end

-- ═══════════════════════════════════════════════
-- 6. ZIPLAMA AYARI
-- ═══════════════════════════════════════════════

local function setJumpPower(power)
    config.jumpPower = power
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
            print("[✓] Zıplama ayarlandı: " .. power)
        end
    end
end

-- ═══════════════════════════════════════════════
-- 7. NO-CLIP (NESNELERİN İÇİNDEN GEÇME)
-- ═══════════════════════════════════════════════

local function toggleNoclip()
    config.noclip = not config.noclip
    
    if config.noclip then
        print("[✓] No-clip AKTİF")
        -- No-clip döngüsü
        RunService.Heartbeat:Connect(function()
            if not config.noclip then return end
            if not LocalPlayer.Character then return end
            
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        print("[✓] No-clip PASİF")
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- 8. GÖRÜNMEZLİK
-- ═══════════════════════════════════════════════

local function toggleInvisible()
    config.invisible = not config.invisible
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = config.invisible and 1 or 0
            end
            if part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = config.invisible and 1 or 0
            end
        end
    end
    
    print(config.invisible and "[✓] Görünmezlik AKTİF" or "[✓] Görünmezlik PASİF")
end

-- ═══════════════════════════════════════════════
-- 9. OTOMATİK TAKİP ETME
-- ═══════════════════════════════════════════════

local function followPlayer(player)
    if not player or not player.Character then return end
    
    followingPlayer = true
    selectedPlayer = player
    print("[✓] " .. player.Name .. " takip ediliyor...")
    
    RunService.Heartbeat:Connect(function()
        if not followingPlayer or not selectedPlayer then return end
        if not selectedPlayer.Character then return end
        if not LocalPlayer.Character then return end
        
        local targetPos = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        local primary = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        
        if targetPos and primary then
            primary.CFrame = targetPos.CFrame + Vector3.new(0, 0, 3)
        end
    end)
end

local function stopFollowing()
    followingPlayer = false
    selectedPlayer = nil
    print("[✓] Takip durduruldu.")
end

-- ═══════════════════════════════════════════════
-- 10. ANA GUI (TELEFON DOSTU)
-- ═══════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "AdminScript"

-- Ana Frame (Tam ekran)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = false -- Başlangıçta gizli

-- Açma/Kapama Butonu (Sağ üst)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 70, 0, 70)
toggleBtn.Position = UDim2.new(1, -80, 0, 10)
toggleBtn.Text = "🔧"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
toggleBtn.BackgroundTransparency = 0.3
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 30
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleBtn.Text = mainFrame.Visible and "✕" or "🔧"
end)

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "🛠️ ADMIN SCRIPT"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
title.BackgroundTransparency = 0.3
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Parent = mainFrame

-- Scroll Frame (Kaydırılabilir)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -70)
scrollFrame.Position = UDim2.new(0, 5, 0, 65)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.Spacing = UDim.new(0, 10)
layout.Padding = UDim.new(0, 10)

-- ═══════════════════════════════════════════════
-- 11. BUTON OLUŞTURMA FONKSİYONU
-- ═══════════════════════════════════════════════

local function createButton(text, color, callback, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 60)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = parent or scrollFrame
    
    button.MouseButton1Click:Connect(callback)
    
    -- Hover efekti
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.new(color.r * 0.7, color.g * 0.7, color.b * 0.7)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)
    
    return button
end

-- ═══════════════════════════════════════════════
-- 12. OYUNCU LİSTESİNİ OLUŞTUR
-- ═══════════════════════════════════════════════

local function createPlayerList()
    -- Başlık
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -10, 0, 30)
    header.Text = "👥 OYUNCULAR"
    header.TextColor3 = Color3.fromRGB(200, 200, 255)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.TextSize = 20
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = scrollFrame
    
    local players = getPlayerList()
    for _, player in pairs(players) do
        local playerFrame = Instance.new("Frame")
        playerFrame.Size = UDim2.new(1, -10, 0, 80)
        playerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        playerFrame.BackgroundTransparency = 0.3
        playerFrame.BorderSizePixel = 0
        playerFrame.Parent = scrollFrame
        
        -- İsim
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 0, 30)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 16
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = playerFrame
        
        -- Butonlar
        local btnBring = Instance.new("TextButton")
        btnBring.Size = UDim2.new(0, 60, 0, 35)
        btnBring.Position = UDim2.new(0.5, -120, 0, 35)
        btnBring.Text = "ÇEK"
        btnBring.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnBring.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        btnBring.Font = Enum.Font.GothamBold
        btnBring.TextSize = 14
        btnBring.BorderSizePixel = 0
        btnBring.Parent = playerFrame
        
        btnBring.MouseButton1Click:Connect(function()
            bringPlayer(player)
        end)
        
        local btnTeleport = Instance.new("TextButton")
        btnTeleport.Size = UDim2.new(0, 60, 0, 35)
        btnTeleport.Position = UDim2.new(0.5, -60, 0, 35)
        btnTeleport.Text = "IŞIN"
        btnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnTeleport.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        btnTeleport.Font = Enum.Font.GothamBold
        btnTeleport.TextSize = 14
        btnTeleport.BorderSizePixel = 0
        btnTeleport.Parent = playerFrame
        
        btnTeleport.MouseButton1Click:Connect(function()
            teleportToPlayer(player)
        end)
        
        local btnSpectate = Instance.new("TextButton")
        btnSpectate.Size = UDim2.new(0, 60, 0, 35)
        btnSpectate.Position = UDim2.new(0.5, 0, 0, 35)
        btnSpectate.Text = "İZLE"
        btnSpectate.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnSpectate.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
        btnSpectate.Font = Enum.Font.GothamBold
        btnSpectate.TextSize = 14
        btnSpectate.BorderSizePixel = 0
        btnSpectate.Parent = playerFrame
        
        btnSpectate.MouseButton1Click:Connect(function()
            if viewingPlayer and selectedPlayer == player then
                stopSpectating()
            else
                spectatePlayer(player)
            end
        end)
        
        local btnFollow = Instance.new("TextButton")
        btnFollow.Size = UDim2.new(0, 60, 0, 35)
        btnFollow.Position = UDim2.new(0.5, 60, 0, 35)
        btnFollow.Text = "TAKİP"
        btnFollow.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnFollow.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
        btnFollow.Font = Enum.Font.GothamBold
        btnFollow.TextSize = 14
        btnFollow.BorderSizePixel = 0
        btnFollow.Parent = playerFrame
        
        btnFollow.MouseButton1Click:Connect(function()
            if followingPlayer and selectedPlayer == player then
                stopFollowing()
            else
                followPlayer(player)
            end
        end)
    end
end

-- ═══════════════════════════════════════════════
-- 13. AYARLAR BUTONLARI
-- ═══════════════════════════════════════════════

local function createSettings()
    -- Başlık
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -10, 0, 30)
    header.Text = "⚙️ AYARLAR"
    header.TextColor3 = Color3.fromRGB(200, 200, 255)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.TextSize = 20
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = scrollFrame
    
    -- Hız Ayarı
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -10, 0, 50)
    speedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    speedFrame.BackgroundTransparency = 0.3
    speedFrame.BorderSizePixel = 0
    speedFrame.Parent = scrollFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
    speedLabel.Text = "🚀 Hız: " .. config.walkSpeed
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextSize = 16
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedFrame
    
    local speedSlider = Instance.new("TextBox")
    speedSlider.Size = UDim2.new(0.4, 0, 0.7, 0)
    speedSlider.Position = UDim2.new(0.5, 0, 0.15, 0)
    speedSlider.Text = tostring(config.walkSpeed)
    speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    speedSlider.Font = Enum.Font.GothamMedium
    speedSlider.TextSize = 16
    speedSlider.BorderSizePixel = 0
    speedSlider.Parent = speedFrame
    
    speedSlider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(speedSlider.Text)
            if num then
                setWalkSpeed(num)
                speedLabel.Text = "🚀 Hız: " .. num
            end
        end
    end)
    
    -- Zıplama Ayarı
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Size = UDim2.new(1, -10, 0, 50)
    jumpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    jumpFrame.BackgroundTransparency = 0.3
    jumpFrame.BorderSizePixel = 0
    jumpFrame.Parent = scrollFrame
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0.4, 0, 1, 0)
    jumpLabel.Text = "🦘 Zıplama: " .. config.jumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Font = Enum.Font.GothamMedium
    jumpLabel.TextSize = 16
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpFrame
    
    local jumpSlider = Instance.new("TextBox")
    jumpSlider.Size = UDim2.new(0.4, 0, 0.7, 0)
    jumpSlider.Position = UDim2.new(0.5, 0, 0.15, 0)
    jumpSlider.Text = tostring(config.jumpPower)
    jumpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    jumpSlider.Font = Enum.Font.GothamMedium
    jumpSlider.TextSize = 16
    jumpSlider.BorderSizePixel = 0
    jumpSlider.Parent = jumpFrame
    
    jumpSlider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(jumpSlider.Text)
            if num then
                setJumpPower(num)
                jumpLabel.Text = "🦘 Zıplama: " .. num
            end
        end
    end)
    
    -- Butonlar
    createButton("🔲 No-Clip (Aç/Kapa)", Color3.fromRGB(100, 100, 200), function()
        toggleNoclip()
    end, scrollFrame)
    
    createButton("👻 Görünmez (Aç/Kapa)", Color3.fromRGB(200, 100, 200), function()
        toggleInvisible()
    end, scrollFrame)
    
    createButton("🔄 Takip Durdur", Color3.fromRGB(200, 50, 50), function()
        stopFollowing()
        stopSpectating()
    end, scrollFrame)
end

-- ═══════════════════════════════════════════════
-- 14. GUI'YI OLUŞTUR
-- ═══════════════════════════════════════════════

createPlayerList()
createSettings()

-- Canvas güncelle
task.wait(0.2)
local totalHeight = 0
for _, child in pairs(scrollFrame:GetChildren()) do
    if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("TextButton") then
        totalHeight = totalHeight + child.Size.Y.Offset + 10
    end
end
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)

-- ═══════════════════════════════════════════════
-- 15. TELEFON OPTİMİZASYONU
-- ═══════════════════════════════════════════════

local isMobile = UserInputService.TouchEnabled
if isMobile then
    toggleBtn.Size = UDim2.new(0, 80, 0, 80)
    toggleBtn.TextSize = 35
    title.TextSize = 30
    
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child.Size = UDim2.new(1, -10, 0, 70)
            child.TextSize = 20
        end
        if child:IsA("Frame") then
            for _, sub in pairs(child:GetChildren()) do
                if sub:IsA("TextButton") then
                    sub.Size = UDim2.new(0, 70, 0, 40)
                    sub.TextSize = 16
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- 16. KISAYOL TUŞLARI
-- ═══════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- "L" tuşu ile GUI aç/kapa
    if input.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
        toggleBtn.Text = mainFrame.Visible a
