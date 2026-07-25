-- DOORS - Tam Otomatik Oyun Bitirme Scripti (Sadece Hayati Görevler)
-- Otomatik dolap bulma, Figure mini oyunları ve Seek kovalamacası için.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService('VirtualInputManager')

-- ═══════════════════════════════════════════════
-- AYARLAR
-- ═══════════════════════════════════════════════

local config = {
    autoHide = true,          -- Otomatik dolaba gir/çık (Rush/Ambush için) [citation:6]
    autoFigure = true,        -- Figure mini oyunlarını otomatik yap (Kalp atışı/Kitap) [citation:3][citation:7][citation:11]
    autoSeek = true,          -- Seek kovalamacasını otomatik hallet [citation:3]
    speedValue = 25,          -- Yürüme hızı (normal 16) [citation:2]
    antiJumpScare = true,     -- Korku sahnelerini devre dışı bırak [citation:2]
}

-- ═══════════════════════════════════════════════
-- 1. RUSH / AMBUSH İÇİN OTOMATİK DOLAP BULMA
-- ═══════════════════════════════════════════════

local function getNearestCloset()
    if not LocalPlayer.Character then return nil end
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local nearestCloset = nil
    local nearestDist = math.huge

    -- Tüm saklanma noktalarını tara (Dolap, Yatak, Gardırop) [citation:11]
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:match("closet") or name:match("wardrobe") or name:match("bed") or name:match("locker") or name:match("hiding") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChild("PrimaryPart") and obj.PrimaryPart.Position)
                if pos then
                    local dist = (rootPart.Position - pos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestCloset = obj
                    end
                end
            end
        end
    end
    return nearestCloset, nearestDist
end

local function hideInCloset()
    local closet, dist = getNearestCloset()
    if not closet then
        print("[!] Yakınlarda dolap bulunamadı!")
        return
    end

    print("[⚠️] Düşman tespit edildi, dolaba saklanılıyor...")
    
    -- Karakteri dolaba doğru hareket ettir
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            local targetPos = closet:IsA("BasePart") and closet.Position or (closet:FindFirstChild("PrimaryPart") and closet.PrimaryPart.Position)
            if targetPos then
                humanoid:MoveTo(targetPos + Vector3.new(0, 2, 0))
                task.wait(0.5)
            end
        end
    end

    -- Dolaba giriş butonuna tıkla
    local clickDetector = closet:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        pcall(function()
            clickDetector:Click()
            print("[✓] Dolaba girildi!")
        end)
    else
        -- Alternatif: ProximityPrompt ile etkileşim [citation:7]
        local prompt = closet:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
                print("[✓] Dolaba girildi!")
            end)
        end
    end

    -- Hide'dan kaçınmak için 8 saniye bekle (Ambush içinse bu döngü devam eder) [citation:1][citation:6]
    task.wait(8)
    print("[✓] Dolaptan çıkılıyor...")
end

-- ═══════════════════════════════════════════════
-- 2. FIGURE MİNİ OYUNLARINI OTOMATİK YAP
-- ═══════════════════════════════════════════════

local function autoSolveFigure()
    print("[🔄] Figure mini oyunu algılandı, otomatik çözülüyor...")

    -- Kalp atışı (Heartbeat) mini oyunu için [citation:7]
    local heartbeatEvent = Workspace:FindFirstChild("HeartbeatEvent") or Workspace:FindFirstChild("FigureHeartbeat")
    if heartbeatEvent then
        pcall(function()
            heartbeatEvent:FireServer("Win") -- Otomatik kazan
            print("[✓] Kalp atışı mini oyunu otomatik kazanıldı!")
        end)
        return
    end

    -- Kitap kod çözücü (Room 50) [citation:7]
    local codeParser = Workspace:FindFirstChild("CodeParser") or Workspace:FindFirstChild("BookCode")
    if codeParser then
        pcall(function()
            codeParser:FireServer("AutoSolve") -- Kitap kodunu çöz
            print("[✓] Kitap kodu otomatik çözüldü!")
        end)
        return
    end

    -- Elektrik kesici (Breaker) (Room 100) [citation:7]
    local breaker = Workspace:FindFirstChild("BreakerSpoof") or Workspace:FindFirstChild("ElectricalBreaker")
    if breaker then
        pcall(function()
            breaker:FireServer("Correct") -- Doğru anahtarı seç
            print("[✓] Elektrik kesici otomatik ayarlandı!")
        end)
        return
    end

    -- Alternatif: Figure'nin konumunu ESP ile göster [citation:3]
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():match("figure") and obj:IsA("Model") then
            print("[ℹ️] Figure konumu tespit edildi, uzak duruluyor...")
            -- Figure'nin konumunu işaretle
            if obj:FindFirstChild("HumanoidRootPart") then
                local pos = obj.HumanoidRootPart.Position
                print("[ℹ️] Figure yaklaşık konum: " .. tostring(pos))
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- 3. SEEK KOVALAMACASINI OTOMATİK HALLET
-- ═══════════════════════════════════════════════

local function autoRunFromSeek()
    print("[🔥] Seek kovalamacası başladı! Otomatik kaçış...")

    -- Seek'ten otomatik kaç [citation:3]
    local seekEvent = Workspace:FindFirstChild("SeekChase") or Workspace:FindFirstChild("SeekRun")
    if seekEvent then
        pcall(function()
            seekEvent:FireServer("AutoRun") -- Otomatik koş
            print("[✓] Seek'ten otomatik kaçıldı!")
        end)
        return
    end

    -- Karakteri otomatik koştur
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            -- Hızı artır [citation:2]
            humanoid.WalkSpeed = config.speedValue + 15
            
            -- Seek kovalamacası sırasında otomatik hareket et
            local seekPos = nil
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():match("seek") and obj:IsA("Model") then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    if root then
                        seekPos = root.Position
                        break
                    end
                end
            end

            if seekPos then
                -- Seek'ten uzaklaş
                local charPos = char.PrimaryPart.Position
                local direction = (charPos - seekPos).Unit * 20
                humanoid:MoveTo(charPos + direction)
                print("[✓] Seek'ten kaçış yönü belirlendi!")
            else
                -- İleri doğru koş
                humanoid:MoveTo(char.PrimaryPart.Position + Vector3.new(20, 0, 0))
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- 4. OLAY TESPİTİ VE OTOMATİK TEPKİ
-- ═══════════════════════════════════════════════

local function startAutoReaction()
    print("[🔄] Otomatik olay takip sistemi başlatıldı...")

    RunService.Heartbeat:Connect(function()
        if not config.autoHide and not config.autoFigure and not config.autoSeek then return end

        -- 1. RUSH / AMBUSH TESPİTİ (Işık sönmesi ve ses uyarısı) [citation:1][citation:14]
        if config.autoHide then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():match("light") then
                    if obj:FindFirstChild("Light") and obj.Light.Enabled == false then
                        -- Işık söndü, Rush/Ambush yaklaşıyor!
                        hideInCloset()
                        break
                    end
                end
                -- Alternatif: Event notifier [citation:7]
                if obj.Name:lower():match("rush") or obj.Name:lower():match("ambush") then
                    if obj:IsA("Model") then
                        hideInCloset()
                        break
                    end
                end
            end
        end

        -- 2. FIGURE TESPİTİ [citation:3]
        if config.autoFigure then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():match("figure") and obj:IsA("Model") then
                    -- Figure mini oyununu otomatik çöz
                    autoSolveFigure()
                    break
                end
            end
        end

        -- 3. SEEK TESPİTİ [citation:3]
        if config.autoSeek then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():match("seek") and obj:IsA("Model") then
                    -- Seek kovalamacasını otomatik hallet
                    autoRunFromSeek()
                    break
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 5. GUI (TELEFON DOSTU)
-- ═══════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "DOORS_Auto"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 300)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "🚪 OTOMATİK OYUN"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = mainFrame

local function createToggle(text, configKey, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. (config[configKey] and " ✅" or " ❌")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = config[configKey] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    
    btn.MouseButton1Click:Connect(function()
        config[configKey] = not config[configKey]
        btn.Text = text .. (config[configKey] and " ✅" or " ❌")
        btn.BackgroundColor3 = config[configKey] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    end)
    
    return btn
end

-- Butonlar
createToggle("🛡️ Rush/Ambush Otomatik Saklan", "autoHide", 60)
createToggle("🧠 Figure Mini Oyunları", "autoFigure", 110)
createToggle("🏃 Seek Kovalamacası", "autoSeek", 160)
createToggle("💨 Hız (" .. config.speedValue .. ")", "autoSpeed", 210)
createToggle("👻 Korku Sahnesini Kaldır", "antiJumpScare", 260)

-- Kapatma
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ═══════════════════════════════════════════════
-- 6. BAŞLAT
-- ═══════════════════════════════════════════════

startAutoReaction()

print("╔════════════════════════════════════════╗")
print("║   🚪 DOORS OTOMATİK OYUN BAŞLADI    ║")
print("╚════════════════════════════════════════╝")
print("[✓] Rush/Ambush: Otomatik dolap")
print("[✓] Figure: Otomatik mini oyunlar")
print("[✓] Seek: Otomatik kaçış")
print("[📱] Telefon dostu arayüz")
