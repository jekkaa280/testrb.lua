-- Ultimate Cheat Menu v3.8 - С оригинальным Pursuit меню

print("=== ЧИТ МЕНЮ v3.8: ЗАГРУЗКА ===")
wait(2)

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")

-- Локальный игрок
local player = Players.LocalPlayer
print("Игрок: " .. player.Name)

-- Ждем PlayerGui
while not player:FindFirstChild("PlayerGui") do
    wait(0.5)
    print("Ожидаем PlayerGui...")
end

-- ========== НАЙДЕННЫЙ REMOTEEVENT ==========
local shootRemote = ReplicatedStorage:FindFirstChild("GunRemotes")
if shootRemote then
    shootRemote = shootRemote:FindFirstChild("ShootEvent")
end

if shootRemote then
    print("✅ Найден RemoteEvent: " .. shootRemote:GetFullName())
else
    print("❌ ShootEvent не найден")
end

-- ========== СОЗДАЕМ ПОСТОЯННОЕ GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenuUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 9999

-- Защищаем GUI
if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    screenGui.Parent = gethui()
elseif game.CoreGui then
    screenGui.Parent = game.CoreGui
else
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

print("✅ GUI создано с защитой от скрытия")

-- 1. КНОПКА ДЛЯ ОТКРЫТИЯ МЕНЮ
local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenuButton"
openButton.Size = UDim2.new(0, 100, 0, 40)
openButton.Position = UDim2.new(0, 20, 0, 20)
openButton.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
openButton.Text = "📱 MENU"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 14
openButton.Visible = true
openButton.Parent = screenGui

-- 2. ОСНОВНОЕ МЕНЮ
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 600)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- 3. ЗАГОЛОВОК МЕНЮ
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 ULTIMATE CHEAT MENU v3.8"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- 4. КНОПКИ УПРАВЛЕНИЯ МЕНЮ
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = CloseButton

-- 5. КОНТЕЙНЕР ДЛЯ КНОПОК ЧИТОВ
local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(1, -20, 1, -70)
ButtonContainer.Position = UDim2.new(0, 10, 0, 60)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ScrollBarThickness = 6
ButtonContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ButtonContainer

-- ========== НАСТРОЙКИ ==========
local settings = {
    autoaim = false,
    autoshoot = false,
    esp = false,
    noclip = false,
    speed = false,
    fullbright = false,
    nofog = false,
    zoom = false,
    pursuit = false
}

local connections = {}
local autoAimDistance = 100
local pursuitSpeed = 30
local lastShot = 0
local shootCooldown = 0.08
local espHighlights = {}

-- Переменные для Auto Aim
local autoAimMode = "auto"
local autoAimCheckboxes = {}

-- Переменные для Pursuit
local selectedTarget = nil
local isAutoTarget = true
local currentTarget = nil
local waypoints = {}
local lastPathUpdate = 0
local pathUpdateInterval = 0.05
local pathVisuals = {}
local currentWaypointIndex = 1
local lastStuckCheck = 0
local stuckPosition = nil
local stuckTime = 0
local lastForceUpdate = 0
local forceUpdateInterval = 0.2
local targetSelectionFrame = nil
local isTargetListOpen = false

-- Переменные для других читов
local originalWalkspeed = 16
local originalFogEnd = Lighting.FogEnd
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalJumpPower = 50
local originalHipHeight = 0
local originalCameraMaxZoom = 0
local originalCameraMinZoom = 0

-- ========== ФУНКЦИЯ СОЗДАНИЯ КНОПКИ ==========
local function createCheatButton(name, description, id, showAdjustment, extraHeight, showModeSelection)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = name .. "Frame"
    ButtonFrame.Size = UDim2.new(1, 0, 0, (showAdjustment and 110 or 80) + (extraHeight or 0) + (showModeSelection and 80 or 0))
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ButtonFrame.Parent = ButtonContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    -- Иконка
    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 10, 0, 15)
    Icon.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Icon.Text = "⚡"
    Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 20
    Icon.Parent = ButtonFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 6)
    IconCorner.Parent = Icon
    
    -- Название
    local ButtonName = Instance.new("TextLabel")
    ButtonName.Name = "ButtonName"
    ButtonName.Size = UDim2.new(0.6, 0, 0, 30)
    ButtonName.Position = UDim2.new(0, 60, 0, 15)
    ButtonName.BackgroundTransparency = 1
    ButtonName.Text = name
    ButtonName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonName.Font = Enum.Font.GothamBold
    ButtonName.TextSize = 16
    ButtonName.TextXAlignment = Enum.TextXAlignment.Left
    ButtonName.Parent = ButtonFrame
    
    -- Описание
    local ButtonDesc = Instance.new("TextLabel")
    ButtonDesc.Name = "ButtonDesc"
    ButtonDesc.Size = UDim2.new(0.6, 0, 0, 20)
    ButtonDesc.Position = UDim2.new(0, 60, 0, 45)
    ButtonDesc.BackgroundTransparency = 1
    ButtonDesc.Text = description
    ButtonDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
    ButtonDesc.Font = Enum.Font.Gotham
    ButtonDesc.TextSize = 12
    ButtonDesc.TextXAlignment = Enum.TextXAlignment.Left
    ButtonDesc.Parent = ButtonFrame
    
    -- Кнопка переключения
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 80, 0, 35)
    ToggleButton.Position = UDim2.new(1, -90, 0, showAdjustment and 25 or 22)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = ButtonFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton
    
    -- Кнопки регулировки для автоаима
    if showAdjustment then
        local AdjustmentFrame = Instance.new("Frame")
        AdjustmentFrame.Name = "AdjustmentFrame"
        AdjustmentFrame.Size = UDim2.new(1, -20, 0, 30)
        AdjustmentFrame.Position = UDim2.new(0, 10, showModeSelection and 0.65 or 1, showModeSelection and -80 or -35)
        AdjustmentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        AdjustmentFrame.BorderSizePixel = 0
        AdjustmentFrame.Parent = ButtonFrame
        
        local AdjustmentCorner = Instance.new("UICorner")
        AdjustmentCorner.CornerRadius = UDim.new(0, 4)
        AdjustmentCorner.Parent = AdjustmentFrame
        
        -- Кнопка "-" (уменьшить)
        local MinusButton = Instance.new("TextButton")
        MinusButton.Name = "MinusButton"
        MinusButton.Size = UDim2.new(0, 40, 1, 0)
        MinusButton.Position = UDim2.new(0, 5, 0, 0)
        MinusButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        MinusButton.Text = "-10"
        MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinusButton.Font = Enum.Font.GothamBold
        MinusButton.TextSize = 16
        MinusButton.Parent = AdjustmentFrame
        
        local MinusCorner = Instance.new("UICorner")
        MinusCorner.CornerRadius = UDim.new(0, 4)
        MinusCorner.Parent = MinusButton
        
        -- Отображение текущего значения
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Name = "ValueLabel"
        ValueLabel.Size = UDim2.new(0.5, 0, 1, 0)
        ValueLabel.Position = UDim2.new(0.25, 0, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = autoAimDistance .. " studs"
        ValueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 14
        ValueLabel.Parent = AdjustmentFrame
        
        -- Кнопка "+" (увеличить)
        local PlusButton = Instance.new("TextButton")
        PlusButton.Name = "PlusButton"
        PlusButton.Size = UDim2.new(0, 40, 1, 0)
        PlusButton.Position = UDim2.new(1, -45, 0, 0)
        PlusButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        PlusButton.Text = "+10"
        PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlusButton.Font = Enum.Font.GothamBold
        PlusButton.TextSize = 16
        PlusButton.Parent = AdjustmentFrame
        
        local PlusCorner = Instance.new("UICorner")
        PlusCorner.CornerRadius = UDim.new(0, 4)
        PlusCorner.Parent = PlusButton
        
        -- Секция выбора режима
        if showModeSelection then
            local ModeSelectionFrame = Instance.new("Frame")
            ModeSelectionFrame.Name = "ModeSelectionFrame"
            ModeSelectionFrame.Size = UDim2.new(1, -20, 0, 70)
            ModeSelectionFrame.Position = UDim2.new(0, 10, 1, -75)
            ModeSelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            ModeSelectionFrame.BorderSizePixel = 0
            ModeSelectionFrame.Parent = ButtonFrame
            
            local ModeCorner = Instance.new("UICorner")
            ModeCorner.CornerRadius = UDim.new(0, 4)
            ModeCorner.Parent = ModeSelectionFrame
            
            local ModeTitle = Instance.new("TextLabel")
            ModeTitle.Name = "ModeTitle"
            ModeTitle.Size = UDim2.new(1, 0, 0, 20)
            ModeTitle.Position = UDim2.new(0, 0, 0, 0)
            ModeTitle.BackgroundTransparency = 1
            ModeTitle.Text = "📱 РЕЖИМ AUTO AIM:"
            ModeTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
            ModeTitle.Font = Enum.Font.GothamBold
            ModeTitle.TextSize = 11
            ModeTitle.TextXAlignment = Enum.TextXAlignment.Left
            ModeTitle.Parent = ModeSelectionFrame
            
            -- Создаем чекбоксы для режимов
            local modes = {
                {name = "AUTO", desc = "Гуманоид в 3-м лице, гуманоид+камера в 1-м", id = "auto"},
                {name = "ROOT", desc = "Только гуманоид поворачивается", id = "root"},
                {name = "ROOT + CAMERA", desc = "Гуманоид и камера всегда", id = "root+camera"}
            }
            
            local yOffset = 25
            for i, mode in ipairs(modes) do
                local modeFrame = Instance.new("Frame")
                modeFrame.Name = mode.id .. "Frame"
                modeFrame.Size = UDim2.new(1, -10, 0, 15)
                modeFrame.Position = UDim2.new(0, 5, 0, yOffset)
                modeFrame.BackgroundTransparency = 1
                modeFrame.Parent = ModeSelectionFrame
                
                -- Чекбокс
                local checkbox = Instance.new("TextButton")
                checkbox.Name = mode.id .. "Checkbox"
                checkbox.Size = UDim2.new(0, 15, 0, 15)
                checkbox.Position = UDim2.new(0, 0, 0, 0)
                checkbox.BackgroundColor3 = mode.id == "auto" and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 100)
                checkbox.Text = mode.id == "auto" and "✓" or ""
                checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
                checkbox.Font = Enum.Font.GothamBold
                checkbox.TextSize = 12
                checkbox.Parent = modeFrame
                
                local checkboxCorner = Instance.new("UICorner")
                checkboxCorner.CornerRadius = UDim.new(0, 3)
                checkboxCorner.Parent = checkbox
                
                -- Текст режима
                local modeLabel = Instance.new("TextLabel")
                modeLabel.Name = mode.id .. "Label"
                modeLabel.Size = UDim2.new(0.8, 0, 1, 0)
                modeLabel.Position = UDim2.new(0, 20, 0, 0)
                modeLabel.BackgroundTransparency = 1
                modeLabel.Text = mode.name .. " - " .. mode.desc
                modeLabel.TextColor3 = mode.id == "auto" and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(200, 200, 200)
                modeLabel.Font = Enum.Font.Gotham
                modeLabel.TextSize = 9
                modeLabel.TextXAlignment = Enum.TextXAlignment.Left
                modeLabel.Parent = modeFrame
                
                -- Сохраняем чекбокс
                autoAimCheckboxes[mode.id] = checkbox
                
                -- Обработчик нажатия
                checkbox.MouseButton1Click:Connect(function()
                    -- Сбрасываем все чекбоксы
                    for id, cb in pairs(autoAimCheckboxes) do
                        cb.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                        cb.Text = ""
                    end
                    
                    -- Устанавливаем выбранный режим
                    autoAimMode = mode.id
                    checkbox.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                    checkbox.Text = "✓"
                    
                    -- Обновляем текст
                    for id, cb in pairs(autoAimCheckboxes) do
                        local label = modeFrame.Parent:FindFirstChild(id .. "Label")
                        if label then
                            label.TextColor3 = id == mode.id and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(200, 200, 200)
                        end
                    end
                    
                    print("[Auto Aim] Режим изменен на: " .. mode.name .. " (" .. mode.desc .. ")")
                end)
                
                yOffset = yOffset + 18
            end
        end
        
        return {
            frame = ButtonFrame, 
            button = ToggleButton, 
            id = id,
            minusButton = MinusButton,
            plusButton = PlusButton,
            valueLabel = ValueLabel
        }
    end
    
    return {frame = ButtonFrame, button = ToggleButton, id = id}
end

-- ========== СОЗДАЕМ КНОПКИ ==========
local buttons = {
    autoaim = createCheatButton("AUTO AIM", "Быстрый поворот к врагу (до 300 studs)", "autoaim", true, 0, true),
    autoshoot = createCheatButton("AUTO SHOOT", "Авто-стрельба для МР5", "autoshoot"),
    esp = createCheatButton("ESP", "Подсветка всех игроков", "esp"),
    noclip = createCheatButton("NOCLIP", "Ходить сквозь стены", "noclip"),
    speed = createCheatButton("SPEED HACK", "Увеличение скорости до 30", "speed"),
    fullbright = createCheatButton("FULLBRIGHT", "Вечный день и яркость", "fullbright"),
    nofog = createCheatButton("NO FOG", "Убрать туман полностью", "nofog"),
    zoom = createCheatButton("MAX ZOOM", "Увеличить дальность обзора", "zoom"),
    pursuit = createCheatButton("PURSUIT", "Преследование цели", "pursuit", false, 140) -- Увеличена высота для всего интерфейса
}

-- Иконки для кнопок
local icons = {
    autoaim = "🎯",
    autoshoot = "🔫",
    esp = "👁️",
    noclip = "🚷",
    speed = "⚡",
    fullbright = "☀️",
    nofog = "🌫️",
    zoom = "🔍",
    pursuit = "🎯🏃‍♂️"
}

for id, buttonData in pairs(buttons) do
    if icons[id] then
        buttonData.frame.Icon.Text = icons[id]
    end
end

-- ========== ФУНКЦИЯ ОБНОВЛЕНИЯ ДИСПЛЕЯ АВТОАИМА ==========
local function updateAutoAimDisplay()
    if buttons.autoaim and buttons.autoaim.valueLabel then
        buttons.autoaim.valueLabel.Text = autoAimDistance .. " studs"
        
        if autoAimDistance <= 50 then
            buttons.autoaim.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif autoAimDistance <= 150 then
            buttons.autoaim.valueLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        elseif autoAimDistance <= 250 then
            buttons.autoaim.valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            buttons.autoaim.valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end
end

-- ========== ОБРАБОТЧИКИ КНОПОК РЕГУЛИРОВКИ ==========
if buttons.autoaim and buttons.autoaim.minusButton then
    buttons.autoaim.minusButton.MouseButton1Click:Connect(function()
        autoAimDistance = math.max(1, autoAimDistance - 10)
        updateAutoAimDisplay()
        print("[Auto Aim] Дистанция уменьшена: " .. autoAimDistance .. " studs")
        
        local originalColor = buttons.autoaim.minusButton.BackgroundColor3
        buttons.autoaim.minusButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        wait(0.1)
        buttons.autoaim.minusButton.BackgroundColor3 = originalColor
    end)
end

if buttons.autoaim and buttons.autoaim.plusButton then
    buttons.autoaim.plusButton.MouseButton1Click:Connect(function()
        autoAimDistance = math.min(300, autoAimDistance + 10)
        updateAutoAimDisplay()
        print("[Auto Aim] Дистанция увеличена: " .. autoAimDistance .. " studs")
        
        local originalColor = buttons.autoaim.plusButton.BackgroundColor3
        buttons.autoaim.plusButton.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        wait(0.1)
        buttons.autoaim.plusButton.BackgroundColor3 = originalColor
    end)
end

-- Инициализируем отображение
updateAutoAimDisplay()

-- ========== НОВАЯ СИСТЕМА ВЫБОРА ЦЕЛИ ДЛЯ PURSUIT ==========
local function updateTargetList()
    if not targetSelectionFrame then return end
    
    local scrollFrame = targetSelectionFrame:FindFirstChild("PlayersScroll")
    if not scrollFrame then return end
    
    -- Очищаем старые кнопки
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local function isEnemy(otherPlayer)
        if otherPlayer == player then return false end
        if player.Team and otherPlayer.Team then
            return player.Team ~= otherPlayer.Team
        end
        return true
    end
    
    -- Создаем кнопки для каждого игрока
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local playerButton = Instance.new("TextButton")
                playerButton.Name = otherPlayer.Name
                playerButton.Size = UDim2.new(1, -10, 0, 25)
                playerButton.Position = UDim2.new(0, 5, 0, 0)
                playerButton.BackgroundColor3 = isEnemy(otherPlayer) and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 120, 60)
                playerButton.Text = (isEnemy(otherPlayer) and "🔴 " or "🟢 ") .. otherPlayer.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.Font = Enum.Font.Gotham
                playerButton.TextSize = 12
                playerButton.TextXAlignment = Enum.TextXAlignment.Left
                playerButton.Parent = scrollFrame
                
                local playerCorner = Instance.new("UICorner")
                playerCorner.CornerRadius = UDim.new(0, 4)
                playerCorner.Parent = playerButton
                
                playerButton.MouseButton1Click:Connect(function()
                    selectedTarget = otherPlayer
                    isAutoTarget = false
                    print("[Target] Выбрана цель: " .. otherPlayer.Name)
                    
                    -- Обновляем отображение выбранной цели
                    if buttons.pursuit and buttons.pursuit.frame then
                        local targetLabel = buttons.pursuit.frame:FindFirstChild("TargetLabel")
                        if targetLabel then
                            targetLabel.Text = "Цель: " .. otherPlayer.Name .. (isEnemy(otherPlayer) and " (враг)" or " (союзник)")
                        end
                    end
                    
                    -- Закрываем список
                    closeTargetList()
                end)
            end
        end
    end
end

local function openTargetList()
    if isTargetListOpen or not buttons.pursuit then return end
    
    isTargetListOpen = true
    
    -- Создаем фрейм для списка игроков
    targetSelectionFrame = Instance.new("Frame")
    targetSelectionFrame.Name = "TargetSelectionFrame"
    targetSelectionFrame.Size = UDim2.new(0, 280, 0, 220)
    targetSelectionFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
    targetSelectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    targetSelectionFrame.BorderSizePixel = 0
    targetSelectionFrame.ZIndex = 10000
    targetSelectionFrame.Parent = screenGui
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = targetSelectionFrame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    titleLabel.Text = "👥 ВЫБОР ЦЕЛИ ДЛЯ ПРЕСЛЕДОВАНИЯ"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Parent = targetSelectionFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = titleLabel
    
    closeButton.MouseButton1Click:Connect(function()
        closeTargetList()
    end)
    
    -- Кнопка "Авто выбор"
    local autoButton = Instance.new("TextButton")
    autoButton.Name = "AutoButton"
    autoButton.Size = UDim2.new(0.4, 0, 0, 25)
    autoButton.Position = UDim2.new(0.05, 0, 0, 35)
    autoButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    autoButton.Text = "🤖 АВТО ВЫБОР"
    autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoButton.Font = Enum.Font.GothamBold
    autoButton.TextSize = 11
    autoButton.Parent = targetSelectionFrame
    
    autoButton.MouseButton1Click:Connect(function()
        selectedTarget = nil
        isAutoTarget = true
        print("[Target] Режим: Авто (ближайший враг)")
        
        if buttons.pursuit and buttons.pursuit.frame then
            local targetLabel = buttons.pursuit.frame:FindFirstChild("TargetLabel")
            if targetLabel then
                targetLabel.Text = "Цель: АВТО (ближайший враг)"
            end
        end
        
        closeTargetList()
    end)
    
    -- Кнопка обновления
    local refreshButton = Instance.new("TextButton")
    refreshButton.Name = "RefreshButton"
    refreshButton.Size = UDim2.new(0.4, 0, 0, 25)
    refreshButton.Position = UDim2.new(0.55, 0, 0, 35)
    refreshButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    refreshButton.Text = "🔄 ОБНОВИТЬ"
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.TextSize = 11
    refreshButton.Parent = targetSelectionFrame
    
    refreshButton.MouseButton1Click:Connect(function()
        updateTargetList()
    end)
    
    -- Прокручиваемый список
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayersScroll"
    scrollFrame.Size = UDim2.new(1, -20, 0, 130)
    scrollFrame.Position = UDim2.new(0, 10, 0, 65)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = targetSelectionFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 6)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Загружаем список игроков
    updateTargetList()
end

local function closeTargetList()
    if targetSelectionFrame then
        targetSelectionFrame:Destroy()
        targetSelectionFrame = nil
    end
    isTargetListOpen = false
end

-- ========== ИНТЕРФЕЙС ДЛЯ PURSUIT (ОРИГИНАЛЬНЫЙ) ==========
if buttons.pursuit then
    local pursuitFrame = buttons.pursuit.frame
    
    -- Кнопка "Выбрать цель"
    local selectButton = Instance.new("TextButton")
    selectButton.Name = "SelectTargetButton"
    selectButton.Size = UDim2.new(0.45, 0, 0, 25)
    selectButton.Position = UDim2.new(0.03, 0, 0.6, 0)
    selectButton.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
    selectButton.Text = "🎯 ВЫБРАТЬ ЦЕЛЬ"
    selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectButton.Font = Enum.Font.GothamBold
    selectButton.TextSize = 11
    selectButton.Parent = pursuitFrame
    
    selectButton.MouseButton1Click:Connect(function()
        openTargetList()
    end)
    
    -- Кнопка "Авто"
    local autoButton = Instance.new("TextButton")
    autoButton.Name = "AutoButton"
    autoButton.Size = UDim2.new(0.45, 0, 0, 25)
    autoButton.Position = UDim2.new(0.52, 0, 0.6, 0)
    autoButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    autoButton.Text = "🤖 АВТО"
    autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoButton.Font = Enum.Font.GothamBold
    autoButton.TextSize = 11
    autoButton.Parent = pursuitFrame
    
    autoButton.MouseButton1Click:Connect(function()
        selectedTarget = nil
        isAutoTarget = true
        print("[Target] Режим: Авто (ближайший враг)")
        
        local targetLabel = pursuitFrame:FindFirstChild("TargetLabel")
        if targetLabel then
            targetLabel.Text = "Цель: АВТО (ближайший враг)"
        end
    end)
    
    -- Индикатор текущей цели
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Name = "TargetLabel"
    targetLabel.Size = UDim2.new(0.94, 0, 0, 18)
    targetLabel.Position = UDim2.new(0.03, 0, 0.72, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Цель: АВТО (ближайший враг)"
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextSize = 10
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = pursuitFrame
    
    -- Регулировка скорости преследования
    local pursuitSpeedFrame = Instance.new("Frame")
    pursuitSpeedFrame.Name = "PursuitSpeedFrame"
    pursuitSpeedFrame.Size = UDim2.new(1, -20, 0, 30)
    pursuitSpeedFrame.Position = UDim2.new(0, 10, 0, 85)
    pursuitSpeedFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    pursuitSpeedFrame.BorderSizePixel = 0
    pursuitSpeedFrame.Parent = pursuitFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0.3, 0, 1, 0)
    speedLabel.Position = UDim2.new(0, 5, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Скорость:"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = pursuitSpeedFrame
    
    local pursuitSpeedLabel = Instance.new("TextLabel")
    pursuitSpeedLabel.Name = "PursuitSpeedLabel"
    pursuitSpeedLabel.Size = UDim2.new(0.2, 0, 1, 0)
    pursuitSpeedLabel.Position = UDim2.new(0.3, 0, 0, 0)
    pursuitSpeedLabel.BackgroundTransparency = 1
    pursuitSpeedLabel.Text = pursuitSpeed
    pursuitSpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    pursuitSpeedLabel.Font = Enum.Font.GothamBold
    pursuitSpeedLabel.TextSize = 14
    pursuitSpeedLabel.Parent = pursuitSpeedFrame
    
    local pursuitMinusButton = Instance.new("TextButton")
    pursuitMinusButton.Name = "PursuitMinusButton"
    pursuitMinusButton.Size = UDim2.new(0, 30, 0, 25)
    pursuitMinusButton.Position = UDim2.new(0.55, 0, 0.5, -12.5)
    pursuitMinusButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    pursuitMinusButton.Text = "-5"
    pursuitMinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    pursuitMinusButton.Font = Enum.Font.GothamBold
    pursuitMinusButton.TextSize = 12
    pursuitMinusButton.Parent = pursuitSpeedFrame
    
    local pursuitPlusButton = Instance.new("TextButton")
    pursuitPlusButton.Name = "PursuitPlusButton"
    pursuitPlusButton.Size = UDim2.new(0, 30, 0, 25)
    pursuitPlusButton.Position = UDim2.new(0.85, 0, 0.5, -12.5)
    pursuitPlusButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    pursuitPlusButton.Text = "+5"
    pursuitPlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    pursuitPlusButton.Font = Enum.Font.GothamBold
    pursuitPlusButton.TextSize = 12
    pursuitPlusButton.Parent = pursuitSpeedFrame
    
    local function updatePursuitSpeedDisplay()
        pursuitSpeedLabel.Text = tostring(pursuitSpeed)
        
        if pursuitSpeed <= 10 then
            pursuitSpeedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif pursuitSpeed <= 20 then
            pursuitSpeedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        elseif pursuitSpeed <= 40 then
            pursuitSpeedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            pursuitSpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        end
    end
    
    pursuitMinusButton.MouseButton1Click:Connect(function()
        pursuitSpeed = math.max(1, pursuitSpeed - 5)
        updatePursuitSpeedDisplay()
        print("[Pursuit] Скорость уменьшена: " .. pursuitSpeed)
    end)
    
    pursuitPlusButton.MouseButton1Click:Connect(function()
        pursuitSpeed = math.min(100, pursuitSpeed + 5)
        updatePursuitSpeedDisplay()
        print("[Pursuit] Скорость увеличена: " .. pursuitSpeed)
    end)
    
    updatePursuitSpeedDisplay()
    
    -- Индикатор состояния
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.94, 0, 0, 15)
    statusLabel.Position = UDim2.new(0.03, 0, 0.95, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Статус: Выключено"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = pursuitFrame
end

-- ========== УПРАВЛЕНИЕ МЕНЮ ==========
local function toggleMenu()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        openButton.Text = "📱 CLOSE"
        openButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeTargetList()
    else
        openButton.Text = "📱 MENU"
        openButton.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
        closeTargetList()
    end
    print("Меню: " .. (MainFrame.Visible and "Открыто" or "Закрыто"))
end

openButton.MouseButton1Click:Connect(toggleMenu)
CloseButton.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

-- ========== ОБЩИЕ ФУНКЦИИ ==========
local function isEnemy(otherPlayer)
    if otherPlayer == player then return false end
    if player.Team and otherPlayer.Team then
        return player.Team ~= otherPlayer.Team
    end
    return true
end

-- ========== БЫСТРЫЙ ПОИСК ВРАГА ==========
local lastEnemyCheck = 0
local enemyCheckInterval = 0.03
local cachedEnemy = nil
local cachedEnemyTime = 0
local cacheValidTime = 0.2

local function findClosestEnemyFast()
    local now = tick()
    
    if cachedEnemy and (now - cachedEnemyTime) < cacheValidTime then
        local enemyChar = cachedEnemy.Character
        if enemyChar then
            local enemyHumanoid = enemyChar:FindFirstChildOfClass("Humanoid")
            local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
            if enemyHumanoid and enemyRoot and enemyHumanoid.Health > 0 then
                return cachedEnemy
            end
        end
    end
    
    if now - lastEnemyCheck < enemyCheckInterval then
        return cachedEnemy
    end
    
    lastEnemyCheck = now
    
    local character = player.Character
    if not character then 
        cachedEnemy = nil
        return nil 
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        cachedEnemy = nil
        return nil 
    end
    
    local myPos = rootPart.Position
    local closest = nil
    local closestDist = math.huge
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if isEnemy(otherPlayer) and otherPlayer.Character then
            local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local dist = (myPos - enemyRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = otherPlayer
                end
            end
        end
    end
    
    cachedEnemy = closest
    cachedEnemyTime = now
    return closest
end

-- ========== УМНЫЙ AUTO AIM ==========
local function startAutoAim()
    if connections.autoaim then 
        connections.autoaim:Disconnect()
        connections.autoaim = nil
    end
    
    print("[Auto Aim] ✅ Активирован (режим: " .. autoAimMode .. ", дистанция: " .. autoAimDistance .. ")")
    
    connections.autoaim = RunService.RenderStepped:Connect(function()
        if not settings.autoaim then return end
        
        local character = player.Character
        if not character then return end
        
        local myRoot = character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local enemy = findClosestEnemyFast()
        if not enemy or not enemy.Character then 
            return 
        end
        
        local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
        if not enemyRoot then 
            return 
        end
        
        local distance = (myRoot.Position - enemyRoot.Position).Magnitude
        
        if distance > autoAimDistance then 
            return 
        end
        
        local camera = Workspace.CurrentCamera
        
        local aimPoint = nil
        local enemyHead = enemy.Character:FindFirstChild("Head")
        
        if enemyHead then
            aimPoint = enemyHead.Position + Vector3.new(0, -0.2, 0)
        else
            aimPoint = enemyRoot.Position + Vector3.new(0, 2.5, 0)
        end
        
        local cameraSubject = camera.CameraSubject
        local isFirstPerson = false
        
        if cameraSubject then
            if cameraSubject:IsA("Humanoid") then
                local humanoidParent = cameraSubject.Parent
                if humanoidParent then
                    local head = humanoidParent:FindFirstChild("Head")
                    if head then
                        local headScreenPos, headOnScreen = camera:WorldToViewportPoint(head.Position)
                        if headOnScreen then
                            local distanceToHead = (camera.CFrame.Position - head.Position).Magnitude
                            isFirstPerson = distanceToHead < 5
                        end
                    end
                end
            end
        end
        
        if autoAimMode == "auto" then
            if isFirstPerson then
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(aimPoint.X, myRoot.Position.Y, aimPoint.Z))
                camera.CFrame = CFrame.new(camera.CFrame.Position, aimPoint)
            else
                local horizontalLook = Vector3.new(aimPoint.X, myRoot.Position.Y, aimPoint.Z)
                myRoot.CFrame = CFrame.new(myRoot.Position, horizontalLook)
            end
        
        elseif autoAimMode == "root" then
            local horizontalLook = Vector3.new(aimPoint.X, myRoot.Position.Y, aimPoint.Z)
            myRoot.CFrame = CFrame.new(myRoot.Position, horizontalLook)
        
        elseif autoAimMode == "root+camera" then
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(aimPoint.X, myRoot.Position.Y, aimPoint.Z))
            camera.CFrame = CFrame.new(camera.CFrame.Position, aimPoint)
        end
    end)
end

local function stopAutoAim()
    if connections.autoaim then
        connections.autoaim:Disconnect()
        connections.autoaim = nil
    end
    
    cachedEnemy = nil
    
    print("[Auto Aim] ❌ Выключен")
end

-- ========== AUTO SHOOT ФУНКЦИИ ==========
local function startAutoShoot()
    if connections.autoshoot then 
        connections.autoshoot:Disconnect()
        connections.autoshoot = nil
    end
    
    print("[Auto Shoot] ✅ Активирован")
    
    connections.autoshoot = RunService.RenderStepped:Connect(function()
        if not settings.autoshoot or not shootRemote then return end
        
        local now = tick()
        if now - lastShot >= shootCooldown then
            local enemy = findClosestEnemyFast()
            
            if enemy and enemy.Character then
                local enemyHumanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
                if enemyHumanoid and enemyHumanoid.Health > 0 then
                    shootRemote:FireServer()
                    lastShot = now
                end
            end
        end
    end)
end

local function stopAutoShoot()
    if connections.autoshoot then
        connections.autoshoot:Disconnect()
        connections.autoshoot = nil
    end
    
    print("[Auto Shoot] ❌ Выключен")
end

-- ========== ESP ФУНКЦИИ ==========
local function startESP()
    print("[ESP] ✅ Активирован")
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            espHighlights[otherPlayer.Name] = Instance.new("Highlight")
            espHighlights[otherPlayer.Name].Parent = otherPlayer.Character or otherPlayer
            
            if isEnemy(otherPlayer) then
                espHighlights[otherPlayer.Name].FillColor = Color3.fromRGB(255, 50, 50)
                espHighlights[otherPlayer.Name].OutlineColor = Color3.fromRGB(200, 30, 30)
            else
                espHighlights[otherPlayer.Name].FillColor = Color3.fromRGB(50, 150, 255)
                espHighlights[otherPlayer.Name].OutlineColor = Color3.fromRGB(30, 100, 200)
            end
            
            espHighlights[otherPlayer.Name].FillTransparency = 0.6
            espHighlights[otherPlayer.Name].OutlineTransparency = 0
        end
    end
    
    connections.esp = Players.PlayerAdded:Connect(function(newPlayer)
        wait(1)
        if newPlayer ~= player then
            espHighlights[newPlayer.Name] = Instance.new("Highlight")
            espHighlights[newPlayer.Name].Parent = newPlayer.Character or newPlayer
            espHighlights[newPlayer.Name].FillColor = isEnemy(newPlayer) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            espHighlights[newPlayer.Name].OutlineColor = isEnemy(newPlayer) and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(30, 100, 200)
            espHighlights[newPlayer.Name].FillTransparency = 0.6
            espHighlights[newPlayer.Name].OutlineTransparency = 0
        end
    end)
    
    connections.espRemove = Players.PlayerRemoving:Connect(function(leftPlayer)
        if espHighlights[leftPlayer.Name] then
            espHighlights[leftPlayer.Name]:Destroy()
            espHighlights[leftPlayer.Name] = nil
        end
    end)
end

local function stopESP()
    if connections.esp then
        connections.esp:Disconnect()
        connections.esp = nil
    end
    if connections.espRemove then
        connections.espRemove:Disconnect()
        connections.espRemove = nil
    end
    
    for _, highlight in pairs(espHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    
    espHighlights = {}
    
    print("[ESP] ❌ Выключен")
end

-- ========== NOCLIP ФУНКЦИИ ==========
local function startNoclip()
    if connections.noclip then 
        connections.noclip:Disconnect()
        connections.noclip = nil
    end
    
    print("[Noclip] ✅ Активирован")
    
    connections.noclip = RunService.Stepped:Connect(function()
        if not settings.noclip then return end
        
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if connections.noclip then
        connections.noclip:Disconnect()
        connections.noclip = nil
    end
    
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    print("[Noclip] ❌ Выключен")
end

-- ========== SPEED ФУНКЦИИ ==========
local function startSpeed()
    print("[Speed Hack] ✅ Активирован")
    
    local function updateSpeed()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                originalWalkspeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = 30
                humanoid.JumpPower = 70
            end
        end
    end
    
    updateSpeed()
    
    connections.speed = player.CharacterAdded:Connect(updateSpeed)
end

local function stopSpeed()
    if connections.speed then
        connections.speed:Disconnect()
        connections.speed = nil
    end
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalWalkspeed
            humanoid.JumpPower = originalJumpPower
        end
    end
    
    print("[Speed Hack] ❌ Выключен")
end

-- ========== FULLBRIGHT ФУНКЦИИ ==========
local function startFullbright()
    print("[Fullbright] ✅ Активирован")
    
    originalBrightness = Lighting.Brightness
    originalClockTime = Lighting.ClockTime
    
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1000000
    
    -- Убираем все тени
    Lighting.GlobalShadows = false
    
    connections.fullbright = RunService.RenderStepped:Connect(function()
        if not settings.fullbright then return end
        Lighting.ClockTime = 14
    end)
end

local function stopFullbright()
    if connections.fullbright then
        connections.fullbright:Disconnect()
        connections.fullbright = nil
    end
    
    Lighting.Brightness = originalBrightness
    Lighting.ClockTime = originalClockTime
    Lighting.FogEnd = originalFogEnd
    Lighting.GlobalShadows = true
    
    print("[Fullbright] ❌ Выключен")
end

-- ========== NO FOG ФУНКЦИИ ==========
local function startNoFog()
    print("[No Fog] ✅ Активирован")
    
    originalFogEnd = Lighting.FogEnd
    Lighting.FogEnd = 1000000
end

local function stopNoFog()
    Lighting.FogEnd = originalFogEnd
    
    print("[No Fog] ❌ Выключен")
end

-- ========== ZOOM ФУНКЦИИ ==========
local function startZoom()
    print("[Max Zoom] ✅ Активирован")
    
    local camera = Workspace.CurrentCamera
    originalCameraMaxZoom = camera.MaxZoomDistance
    originalCameraMinZoom = camera.MinZoomDistance
    
    camera.MaxZoomDistance = 1000
    camera.MinZoomDistance = 0.5
end

local function stopZoom()
    local camera = Workspace.CurrentCamera
    camera.MaxZoomDistance = originalCameraMaxZoom
    camera.MinZoomDistance = originalCameraMinZoom
    
    print("[Max Zoom] ❌ Выключен")
end

-- ========== PURSUIT ФУНКЦИИ ==========
local function getPursuitTarget()
    if isAutoTarget then
        return findClosestEnemyFast()
    else
        if selectedTarget and selectedTarget.Character then
            local enemyHumanoid = selectedTarget.Character:FindFirstChildOfClass("Humanoid")
            if enemyHumanoid and enemyHumanoid.Health > 0 then
                return selectedTarget
            else
                isAutoTarget = true
                selectedTarget = nil
                if buttons.pursuit and buttons.pursuit.frame then
                    local targetLabel = buttons.pursuit.frame:FindFirstChild("TargetLabel")
                    if targetLabel then
                        targetLabel.Text = "Цель: АВТО (ближайший враг)"
                    end
                end
                return findClosestEnemyFast()
            end
        end
        return nil
    end
end

local function clearPathVisuals()
    for _, visual in pairs(pathVisuals) do
        if visual and visual.Parent then
            visual:Destroy()
        end
    end
    pathVisuals = {}
end

local function calculateSmartPath(startPos, endPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 1.5,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 4,
        Costs = {
            Water = 25,
            Lava = 100
        }
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPos, endPos)
    end)
    
    if not success then
        return nil
    end
    
    if path.Status == Enum.PathStatus.Success then
        local rawWaypoints = path:GetWaypoints()
        local filteredPoints = {}
        
        for i, waypoint in ipairs(rawWaypoints) do
            if i == 1 or i == #rawWaypoints or i % 2 == 0 or waypoint.Action == Enum.PathWaypointAction.Jump then
                table.insert(filteredPoints, waypoint.Position)
            end
        end
        
        if #filteredPoints < 3 and #rawWaypoints > 3 then
            filteredPoints = {}
            for i = 1, math.min(8, #rawWaypoints) do
                table.insert(filteredPoints, rawWaypoints[i].Position)
            end
        end
        
        return filteredPoints
    else
        local direction = (endPos - startPos)
        local distance = direction.Magnitude
        
        if distance > 0 then
            direction = direction.Unit
            local simplePoints = {}
            
            for i = 1, math.ceil(distance / 10) do
                local point = startPos + direction * (i * 10)
                table.insert(simplePoints, point)
            end
            
            table.insert(simplePoints, endPos)
            return simplePoints
        end
        
        return nil
    end
end

local function updatePursuitPath()
    local enemy = getPursuitTarget()
    
    if not enemy or not enemy.Character then
        currentTarget = nil
        waypoints = {}
        currentWaypointIndex = 1
        clearPathVisuals()
        return false
    end
    
    local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then
        currentTarget = nil
        waypoints = {}
        currentWaypointIndex = 1
        clearPathVisuals()
        return false
    end
    
    local character = player.Character
    if not character then
        waypoints = {}
        currentWaypointIndex = 1
        clearPathVisuals()
        return false
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        waypoints = {}
        currentWaypointIndex = 1
        clearPathVisuals()
        return false
    end
    
    local now = tick()
    local forceUpdate = (now - lastForceUpdate >= forceUpdateInterval)
    
    local needUpdate = forceUpdate or currentTarget ~= enemy or #waypoints == 0
    
    if needUpdate then
        currentTarget = enemy
        
        if forceUpdate then
            lastForceUpdate = now
        end
        
        local newPath = calculateSmartPath(rootPart.Position, enemyRoot.Position)
        
        if newPath and #newPath > 0 then
            waypoints = newPath
            
            local nearestIndex = 1
            local nearestDistance = math.huge
            
            for i, point in ipairs(waypoints) do
                local distance = (rootPart.Position - point).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestIndex = i
                end
            end
            
            currentWaypointIndex = nearestIndex
            return true
        else
            waypoints = {}
            clearPathVisuals()
            return false
        end
    end
    
    return #waypoints > 0
end

local function moveToTarget()
    if not waypoints or #waypoints == 0 then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    humanoid.WalkSpeed = pursuitSpeed
    
    local nearestIndex = currentWaypointIndex
    local nearestDistance = (rootPart.Position - waypoints[currentWaypointIndex]).Magnitude
    
    for i = currentWaypointIndex + 1, #waypoints do
        local distance = (rootPart.Position - waypoints[i]).Magnitude
        if distance < nearestDistance then
            nearestDistance = distance
            nearestIndex = i
        end
    end
    
    if nearestIndex > currentWaypointIndex then
        currentWaypointIndex = nearestIndex
    end
    
    if currentWaypointIndex > #waypoints then
        return false
    end
    
    local targetPoint = waypoints[currentWaypointIndex]
    local distance = (rootPart.Position - targetPoint).Magnitude
    
    if distance < 3 then
        currentWaypointIndex = math.min(currentWaypointIndex + 1, #waypoints)
        
        if currentWaypointIndex <= #waypoints then
            targetPoint = waypoints[currentWaypointIndex]
        else
            return false
        end
    end
    
    local now = tick()
    if now - lastStuckCheck > 1 then
        lastStuckCheck = now
        
        if not stuckPosition then
            stuckPosition = rootPart.Position
            stuckTime = now
        else
            local movedDistance = (rootPart.Position - stuckPosition).Magnitude
            
            if movedDistance < 3 and now - stuckTime > 3 then
                stuckPosition = nil
                stuckTime = 0
                waypoints = {}
                currentWaypointIndex = 1
                return false
            end
            
            if movedDistance > 5 then
                stuckPosition = rootPart.Position
                stuckTime = now
            end
        end
    end
    
    humanoid:MoveTo(targetPoint)
    return true
end

local function startPursuit()
    if connections.pursuit then 
        connections.pursuit:Disconnect()
        connections.pursuit = nil
    end
    
    print("[Pursuit] ✅ Активирован")
    
    -- Обновляем статус в интерфейсе
    if buttons.pursuit and buttons.pursuit.frame then
        local statusLabel = buttons.pursuit.frame:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = "Статус: Активно (преследование)"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end
    
    connections.pursuit = RunService.Heartbeat:Connect(function()
        if not settings.pursuit then return end
        
        local now = tick()
        
        if now - lastPathUpdate >= pathUpdateInterval then
            lastPathUpdate = now
            updatePursuitPath()
        end
        
        local moved = moveToTarget()
        
        if not moved then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:MoveTo(character:GetPivot().Position)
                end
            end
        end
    end)
end

local function stopPursuit()
    if connections.pursuit then
        connections.pursuit:Disconnect()
        connections.pursuit = nil
    end
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(character:GetPivot().Position)
            humanoid.WalkSpeed = 16
        end
    end
    
    clearPathVisuals()
    closeTargetList()
    
    currentTarget = nil
    waypoints = {}
    currentWaypointIndex = 1
    stuckPosition = nil
    stuckTime = 0
    
    -- Обновляем статус в интерфейсе
    if buttons.pursuit and buttons.pursuit.frame then
        local statusLabel = buttons.pursuit.frame:FindFirstChild("StatusLabel")
        if statusLabel then
            statusLabel.Text = "Статус: Выключено"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    print("[Pursuit] ❌ Выключен")
end

-- ========== ОБРАБОТЧИКИ КНОПОК ==========
local cheatFunctions = {
    autoaim = {on = startAutoAim, off = stopAutoAim},
    autoshoot = {on = startAutoShoot, off = stopAutoShoot},
    esp = {on = startESP, off = stopESP},
    noclip = {on = startNoclip, off = stopNoclip},
    speed = {on = startSpeed, off = stopSpeed},
    fullbright = {on = startFullbright, off = stopFullbright},
    nofog = {on = startNoFog, off = stopNoFog},
    zoom = {on = startZoom, off = stopZoom},
    pursuit = {on = startPursuit, off = stopPursuit}
}

for id, buttonData in pairs(buttons) do
    buttonData.button.MouseButton1Click:Connect(function()
        settings[id] = not settings[id]
        
        if settings[id] then
            buttonData.button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            buttonData.button.Text = "ON"
            buttonData.button.TextColor3 = Color3.fromRGB(255, 255, 255)
            buttonData.frame.BackgroundColor3 = Color3.fromRGB(40, 50, 60)
            
            if cheatFunctions[id] and cheatFunctions[id].on then
                cheatFunctions[id].on()
            end
            
            print("✅ " .. id .. " активирован")
        else
            buttonData.button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            buttonData.button.Text = "OFF"
            buttonData.button.TextColor3 = Color3.fromRGB(255, 255, 255)
            buttonData.frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            
            if cheatFunctions[id] and cheatFunctions[id].off then
                cheatFunctions[id].off()
            end
            
            print("❌ " .. id .. " выключен")
        end
    end)
end

-- ========== ГОРЯЧИЕ КЛАВИШИ ==========
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F5 then
        settings.pursuit = not settings.pursuit
        if settings.pursuit then
            startPursuit()
            buttons.pursuit.button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            buttons.pursuit.button.Text = "ON"
            print("🎯🏃‍♂️ Pursuit включено (F5)")
        else
            stopPursuit()
            buttons.pursuit.button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            buttons.pursuit.button.Text = "OFF"
            print("🎯🏃‍♂️ Pursuit выключено (F5)")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F11 then
        autoAimDistance = math.max(1, autoAimDistance - 10)
        updateAutoAimDisplay()
        print("[Auto Aim] Быстрое уменьшение: " .. autoAimDistance .. " studs (F11)")
    end
    
    if input.KeyCode == Enum.KeyCode.F12 then
        autoAimDistance = math.min(300, autoAimDistance + 10)
        updateAutoAimDisplay()
        print("[Auto Aim] Быстрое увеличение: " .. autoAimDistance .. " studs (F12)")
    end
    
    -- Горячие клавиши для других читов
    if input.KeyCode == Enum.KeyCode.F1 then
        settings.autoaim = not settings.autoaim
        if settings.autoaim then
            startAutoAim()
            buttons.autoaim.button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            buttons.autoaim.button.Text = "ON"
            print("🎯 Auto Aim включено (F1)")
        else
            stopAutoAim()
            buttons.autoaim.button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            buttons.autoaim.button.Text = "OFF"
            print("🎯 Auto Aim выключено (F1)")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        settings.autoshoot = not settings.autoshoot
        if settings.autoshoot then
            startAutoShoot()
            buttons.autoshoot.button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            buttons.autoshoot.button.Text = "ON"
            print("🔫 Auto Shoot включено (F2)")
        else
            stopAutoShoot()
            buttons.autoshoot.button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            buttons.autoshoot.button.Text = "OFF"
            print("🔫 Auto Shoot выключено (F2)")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        settings.esp = not settings.esp
        if settings.esp then
            startESP()
            buttons.esp.button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            buttons.esp.button.Text = "ON"
            print("👁️ ESP включено (F3)")
        else
            stopESP()
            buttons.esp.button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            buttons.esp.button.Text = "OFF"
            print("👁️ ESP выключено (F3)")
        end
    end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.Size = UDim2.new(0, 500, 0, 140)
notification.Position = UDim2.new(0.5, -250, 0, 100)
notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
notification.BackgroundTransparency = 0.2
notification.Parent = screenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 10)
NotifCorner.Parent = notification

local NotifTitle = Instance.new("TextLabel")
NotifTitle.Name = "NotifTitle"
NotifTitle.Size = UDim2.new(1, 0, 0, 30)
NotifTitle.Position = UDim2.new(0, 0, 0, 10)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "🎯 ULTIMATE CHEAT MENU v3.8 LOADED!"
NotifTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
NotifTitle.Font = Enum.Font.GothamBold
NotifTitle.TextSize = 18
NotifTitle.Parent = notification

local NotifText = Instance.new("TextLabel")
NotifText.Name = "NotifText"
NotifText.Size = UDim2.new(1, 0, 0, 100)
NotifText.Position = UDim2.new(0, 0, 0, 35)
NotifText.BackgroundTransparency = 1
NotifText.Text = "✅ ОРИГИНАЛЬНОЕ МЕНЮ PURSUIT ВОЗВРАЩЕНО:\n• Полный интерфейс выбора цели\n• Кнопки 'Выбрать цель' и 'Авто'\n• Регулировка скорости преследования\n• Индикатор текущей цели и статуса\n• Быстрый Auto Aim до 300 studs\n\n🎮 Горячие клавиши: F5 - Pursuit, F11/F12 - Auto Aim"
NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifText.Font = Enum.Font.Gotham
NotifText.TextSize = 12
NotifText.TextYAlignment = Enum.TextYAlignment.Top
NotifText.Parent = notification

delay(8, function()
    if notification then
        notification:Destroy()
    end
end)

print("\n" .. string.rep("=", 60))
print("🎯 ULTIMATE CHEAT MENU v3.8 ЗАГРУЖЕН!")
print(string.rep("=", 60))
print("✅ ОРИГИНАЛЬНОЕ МЕНЮ PURSUIT ВОЗВРАЩЕНО:")
print("   • Полный интерфейс выбора цели")
print("   • Кнопки 'Выбрать цель' и 'Авто'")
print("   • Регулировка скорости преследования")
print("   • Индикатор текущей цели и статуса")
print("   • Быстрый Auto Aim до 300 studs")
print(string.rep("-", 60))
print("🎮 ГОРЯЧИЕ КЛАВИШИ:")
print("   F1 - Auto Aim")
print("   F2 - Auto Shoot")
print("   F3 - ESP")
print("   F5 - Pursuit")
print("   F11/F12 - Регулировка дистанции Auto Aim")
print(string.rep("=", 60))
print("✅ Все кнопки теперь работают!")
print(string.rep("=", 60))

-- Автоматически обновляем ESP при добавлении игроков
Players.PlayerAdded:Connect(function(newPlayer)
    if settings.esp then
        wait(1)
        if newPlayer ~= player then
            espHighlights[newPlayer.Name] = Instance.new("Highlight")
            espHighlights[newPlayer.Name].Parent = newPlayer.Character or newPlayer
            espHighlights[newPlayer.Name].FillColor = isEnemy(newPlayer) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            espHighlights[newPlayer.Name].OutlineColor = isEnemy(newPlayer) and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(30, 100, 200)
            espHighlights[newPlayer.Name].FillTransparency = 0.6
            espHighlights[newPlayer.Name].OutlineTransparency = 0
        end
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    if espHighlights[leftPlayer.Name] then
        espHighlights[leftPlayer.Name]:Destroy()
        espHighlights[leftPlayer.Name] = nil
    end
end)
