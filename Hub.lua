-- Slap Battles - Dreamscape Auto-Farm
-- Dreamscape'e girdikten SONRA çalıştır
-- Otomatik yastık tıklama, birlik satın alma, dalga savunma
-- Yer: LocalScript

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════
-- KONFIGÜRASYON
-- ═══════════════════════════════════════════════

local config = {
    autoClickPillows = true,        -- Otomatik yastık tıkla (Dreambucks kazan)
    clickSpeed = 0.05,              -- Tıklama hızı (saniye)
    autoBuyUnits = true,            -- Otomatik birlik satın al
    targetUnit = "Cloud McCoolio",  -- Hedef birlik (en etkili)
    autoDefend = true,              -- Otomatik savunma
    autoUpgrade = true,             -- Otomatik yükseltme
    spamUnits = true,               -- Sürekli birlik satın al
    maxUnits = 30,                  -- Maksimum birlik sayısı
}

-- ═══════════════════════════════════════════════
-- DURUM TAKİBİ
-- ═══════════════════════════════════════════════

local isRunning = true
local unitCount = 0
local dreambucks = 0

-- ═══════════════════════════════════════════════
-- 1. OTOMATİK YASTIK TIKLAMA
-- ═══════════════════════════════════════════════

local function startAutoClickPillows()
    print("[Dreamscape] Otomatik yastık tıklama başlatılıyor...")
    
    RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        if not config.autoClickPillows then return end
        
        -- Tüm yastıkları bul
        for _, obj in pairs(Workspace:GetDescendants()) do
            if not isRunning then break end
            
            -- Yastık objelerini tespit et
            if obj:IsA("ClickDetector") then
                -- ClickDetector'ı tetikle
                pcall(function()
                    obj:Click()
                end)
            elseif obj:IsA("BasePart") and obj.Name:lower():match("pillow") then
                -- Part'ın ClickDetector'ını bul
                local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    pcall(function()
                        clickDetector:Click()
                    end)
                end
                
                -- Alternatif: RemoteEvent ile tıkla
                local clickEvent = obj:FindFirstChild("ClickEvent")
                if clickEvent then
                    pcall(function()
                        clickEvent:FireServer()
                    end)
                end
            end
            
            -- Dreambucks göstergesini kontrol et (para kazanıldı mı)
            if obj:IsA("TextLabel") and obj.Name:lower():match("dream") and obj.Name:lower():match("buck") then
                local text = obj.Text or ""
                local num = tonumber(text:gsub("[^%d]", ""))
                if num and num > dreambucks then
                    dreambucks = num
                    print("[✓] Dreambucks: " .. dreambucks)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 2. OTOMATİK BİRLİK SATIN ALMA
-- ═══════════════════════════════════════════════

local function startAutoBuyUnits()
    print("[Dreamscape] Otomatik birlik satın alma başlatılıyor...")
    
    RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        if not config.autoBuyUnits then return end
        if unitCount >= config.maxUnits then return end
        
        -- GUI'deki butonları bul
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, gui in pairs(playerGui:GetDescendants()) do
            if not isRunning then break end
            
            -- Satın alma butonlarını bul
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local text = gui.Text or ""
                local name = gui.Name or ""
                
                -- Cloud McCoolio veya hedef birimi bul
                if text:lower():match("cloud") or text:lower():match("mccoolio") 
                   or name:lower():match("cloud") or name:lower():match("mccoolio") then
                    
                    -- Butona tıkla
                    pcall(function()
                        gui:Click()
                        unitCount = unitCount + 1
                        print("[✓] " .. config.targetUnit .. " #" .. unitCount .. " satın alındı!")
                    end)
                end
                
                -- Genel "Buy" butonları (alternatif)
                if text:lower():match("buy") and text:lower():match("unit") then
                    -- Tüm unit'leri satın al (önce Cloud McCoolio tercih edilir)
                    if not text:lower():match("cloud") then
                        pcall(function()
                            gui:Click()
                            unitCount = unitCount + 1
                            print("[✓] Unit satın alındı! Toplam: " .. unitCount)
                        end)
                    end
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 3. OTOMATİK YÜKSELTME (UPGRADE)
-- ═══════════════════════════════════════════════

local function startAutoUpgrade()
    print("[Dreamscape] Otomatik yükseltme başlatılıyor...")
    
    RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        if not config.autoUpgrade then return end
        
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, gui in pairs(playerGui:GetDescendants()) do
            if not isRunning then break end
            
            -- Upgrade butonlarını bul
            if gui:IsA("TextButton") then
                local text = gui.Text or ""
                local name = gui.Name or ""
                
                if text:lower():match("upgrade") or name:lower():match("upgrade") 
                   or text:lower():match("level") or text:lower():match("strength") then
                    pcall(function()
                        gui:Click()
                        print("[✓] Yükseltme yapıldı!")
                    end)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 4. OTOMATİK DÜŞMAN SAVUNMASI
-- ═══════════════════════════════════════════════

local function startAutoDefend()
    print("[Dreamscape] Otomatik savunma başlatılıyor...")
    
    RunService.Heartbeat:Connect(function()
        if not isRunning then return end
        if not config.autoDefend then return end
        
        -- Düşmanları bul ve yok et
        for _, enemy in pairs(Workspace:GetChildren()) do
            if not isRunning then break end
            
            -- Düşman modelleri
            if enemy:IsA("Model") then
                local enemyName = enemy.Name:lower()
                
                if enemyName:match("enemy") or enemyName:match("demon") 
                   or enemyName:match("monster") or enemyName:match("zombie") 
                   or enemyName:match("dark") or enemyName:match("shadow") then
                    
                    local humanoid = enemy:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        -- Tokat atarak saldır
                        local slapEvent = ReplicatedStorage:FindFirstChild("Slap")
                        if slapEvent then
                            pcall(function()
                                slapEvent:FireServer()
                            end)
                        end
                        
                        -- Alternatif: Remote saldırı
                        local attackEvent = ReplicatedStorage:FindFirstChild("Attack")
                        if attackEvent then
                            pcall(function()
                                attackEvent:FireServer(enemy)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════
-- 5. SÜREKLİ BİRLİK SPAM
-- ═══════════════════════════════════════════════

local function startSpamUnits()
    print("[Dreamscape] Sürekli birlik spam başlatılıyor...")
    
    while isRunning do
        task.wait(0.5)
        
        if not config.spamUnits then break end
        if unitCount >= config.maxUnits then 
            print("[✓] Maksimum birlik sayısına ulaşıldı: " .. config.maxUnits)
            break
        end
        
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then continue end
        
        -- Cloud McCoolio butonunu bul
        for _, gui in pairs(playerGui:GetDescendants()) do
            if not isRunning then break end
            
            if gui:IsA("TextButton") then
                local text = gui.Text or ""
                local name = gui.Name or ""
                
                if text:lower():match("cloud") or text:lower():match("mccoolio") 
                   or name:lower():match("cloud") or name:lower():match("mccoolio") then
                    
                    -- Hızlıca satın al
                    for i = 1, 3 do
                        pcall(function()
                            gui:Click()
                            unitCount = unitCount + 1
                            print("[✓] Cloud McCoolio #" .. unitCount .. " satın alındı!")
                        end)
                        task.wait(0.1)
                    end
                    
                    break
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════
-- 6. ROZET KONTROLÜ
-- ═══════════════════════════════════════════════

local function checkBadge()
    print("[Dreamscape] Rozet kontrolü başlatılıyor...")
    
    local badgeService = game:GetService("BadgeService")
    local pillowBadgeId = 2123456800 -- Gerçek badge ID'yi bulman gerek
    
    while isRunning do
        task.wait(5) -- Her 5 saniyede bir kontrol et
        
        local success, hasBadge = pcall(function()
            return badgeService:UserHasBadgeAsync(LocalPlayer.UserId, pillowBadgeId)
        end)
        
        if success and hasBadge then
            print("🎉🎉🎉 PILLOW ELDİVENİ AÇILDI! 🎉🎉🎉")
            print("[✓] 'Fortress of Dreams' rozeti kazanıldı!")
            isRunning = false
            break
        end
    end
end

-- ═══════════════════════════════════════════════
-- 7. DURUM BİLDİRİM SİSTEMİ
-- ═══════════════════════════════════════════════

local function createStatusUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.Name = "DreamscapeStatus"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0.5, -125, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "🌙 DREAMSCAPE FARM"
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 30)
    statusLabel.Text = "⏳ Çalışıyor..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 14
    statusLabel.Parent = frame
    
    local unitLabel = Instance.new("TextLabel")
    unitLabel.Size = UDim2.new(1, 0, 0, 25)
    unitLabel.Position = UDim2.new(0, 0, 0, 55)
    unitLabel.Text = "👾 Birlik: 0"
    unitLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    unitLabel.BackgroundTransparency = 1
    unitLabel.Font = Enum.Font.GothamMedium
    unitLabel.TextSize = 14
    unitLabel.Parent = frame
    
    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(1, 0, 0, 25)
    moneyLabel.Position = UDim2.new(0, 0, 0, 80)
    moneyLabel.Text = "💰 Dreambucks: 0"
    moneyLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Font = Enum.Font.GothamMedium
    moneyLabel.TextSize = 14
    moneyLabel.Parent = frame
    
    -- Güncelleme döngüsü
    RunService.Heartbeat:Connect(function()
        unitLabel.Text = "👾 Birlik: " .. unitCount
        moneyLabel.Text = "💰 Dreambucks: " .. dreambucks
        
        if not isRunning then
            statusLabel.Text = "✅ TAMAMLANDI! 🎉"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- ANA BAŞLATMA FONKSİYONU
-- ═══════════════════════════════════════════════

local function startFarm()
    print("╔════════════════════════════════════════╗")
    print("║   🌙 DREAMSCAPE AUTO-FARM BAŞLADI    ║")
    print("╚════════════════════════════════════════╝")
    
    -- GUI'yi oluştur
    createStatusUI()
    
    -- Tüm sistemleri başlat
    startAutoClickPillows()
    startAutoBuyUnits()
    startAutoUpgrade()
    startAutoDefend()
    
    -- Rozet kontrolünü başlat (arka planda)
    task.spawn(checkBadge)
    
    -- Birlik spam'ını başlat (arka planda)
    task.spawn(startSpamUnits)
    
    print("[✓] Tüm sistemler çalışıyor!")
    print("[✓] Rozet alındığında otomatik duracak.")
    print("[📱] 'L' tuşu ile durdurabilirsin.")
end

-- ═══════════════════════════════════════════════
-- KONTROLLER
-- ═══════════════════════════════════════════════

-- "L" tuşu ile durdur
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        isRunning = false
        print("[✓] Farm durduruldu.")
    end
end)

-- ═══════════════════════════════════════════════
-- BAŞLAT
-- ═══════════════════════════════════════════════

startFarm()
