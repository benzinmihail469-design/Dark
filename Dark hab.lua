-- Kill Aura для Roblox: Арена Зомби
-- С GUI-кнопкой включения/выключения
-- Ищет папку Zombies_Local, внутри модели Zombie

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки атаки
local ATTACK_RADIUS = 50      -- Радиус атаки
local DAMAGE_AMOUNT = 10      -- Урон за удар
local COOLDOWN = 0.2          -- Интервал между ударами

-- Состояние
local auraEnabled = false
local lastAttackTime = 0

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillAuraGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "ButtonFrame"
buttonFrame.Size = UDim2.new(0, 70, 0, 70)
buttonFrame.Position = UDim2.new(1, -85, 0, 50)
buttonFrame.AnchorPoint = Vector2.new(1, 0)
buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
buttonFrame.BackgroundTransparency = 0.1
buttonFrame.BorderSizePixel = 0
buttonFrame.ClipsDescendants = true

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = buttonFrame

local buttonGlow = Instance.new("Frame")
buttonGlow.Name = "Glow"
buttonGlow.Size = UDim2.new(1, 0, 1, 0)
buttonGlow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
buttonGlow.BackgroundTransparency = 0.8
buttonGlow.BorderSizePixel = 0
buttonGlow.Parent = buttonFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = buttonGlow

local buttonIcon = Instance.new("ImageLabel")
buttonIcon.Name = "Icon"
buttonIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
buttonIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
buttonIcon.AnchorPoint = Vector2.new(0.5, 0.5)
buttonIcon.BackgroundTransparency = 1
buttonIcon.Image = "rbxassetid://3926305904" -- Иконка меча
buttonIcon.Parent = buttonFrame

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, 0, 0.3, 0)
statusText.Position = UDim2.new(0, 0, 1, 0)
statusText.AnchorPoint = Vector2.new(0, 1)
statusText.BackgroundTransparency = 1
statusText.Text = "OFF"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextScaled = true
statusText.Font = Enum.Font.GothamBold
statusText.TextStrokeTransparency = 0.5
statusText.Parent = buttonFrame

-- Добавляем возможность перетаскивания
local dragging = false
local dragStartPos = nil
local frameStartPos = nil

buttonFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = buttonFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        local newX = frameStartPos.X.Offset + delta.X
        local newY = frameStartPos.Y.Offset + delta.Y
        
        buttonFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Анимация пульсации для отключенного состояния
local function animateButton()
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local properties = {BackgroundTransparency = 0.05}
    local tween = TweenService:Create(buttonFrame, tweenInfo, properties)
    tween:Play()
end
animateButton()

-- Функция для плавного изменения цвета кнопки
local function setButtonState(state)
    if state then
        -- Включена - зелёный
        local tween = TweenService:Create(buttonGlow, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 255, 50), BackgroundTransparency = 0.4})
        tween:Play()
        buttonIcon.ImageColor3 = Color3.fromRGB(50, 255, 50)
        statusText.Text = "ON"
        statusText.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Вращение иконки
        local spinTween = TweenService:Create(buttonIcon, TweenInfo.new(0.3), {Rotation = 0})
        spinTween:Play()
    else
        -- Выключена - красный
        local tween = TweenService:Create(buttonGlow, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 50, 50), BackgroundTransparency = 0.8})
        tween:Play()
        buttonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        statusText.Text = "OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Обработчик нажатия на кнопку
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundTransparency = 1
button.Text = ""
button.Parent = buttonFrame

button.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    
    if auraEnabled then
        setButtonState(true)
        StarterGui:SetCore("SendNotification", {
            Title = "Kill Aura",
            Text = "🔪 ВКЛЮЧЕНА",
            Duration = 1.5,
            Icon = "rbxassetid://3926305904"
        })
    else
        setButtonState(false)
        StarterGui:SetCore("SendNotification", {
            Title = "Kill Aura",
            Text = "⚔️ ВЫКЛЮЧЕНА",
            Duration = 1.5,
            Icon = "rbxassetid://3926305904"
        })
    end
end)

-- Дополнительная кнопка: быстрая настройка (шестерёнка)
local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(0.3, 0, 0.3, 0)
settingsButton.Position = UDim2.new(1, -5, 1, -5)
settingsButton.AnchorPoint = Vector2.new(1, 1)
settingsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
settingsButton.BackgroundTransparency = 0.2
settingsButton.Text = "⚙️"
settingsButton.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsButton.TextSize = 20
settingsButton.Font = Enum.Font.GothamBold
settingsButton.Parent = buttonFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(1, 0)
settingsCorner.Parent = settingsButton

-- Выпадающее меню настроек (появляется при клике на шестерёнку)
local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(0, 200, 0, 120)
settingsPanel.Position = UDim2.new(1, -210, 0, 80)
settingsPanel.AnchorPoint = Vector2.new(1, 0)
settingsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
settingsPanel.BackgroundTransparency = 0.15
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
settingsPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = settingsPanel

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0.25, 0)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ НАСТРОЙКИ"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.TextScaled = true
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.Parent = settingsPanel

local radiusSliderLabel = Instance.new("TextLabel")
radiusSliderLabel.Size = UDim2.new(0.4, 0, 0.2, 0)
radiusSliderLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
radiusSliderLabel.BackgroundTransparency = 1
radiusSliderLabel.Text = "Радиус: " .. ATTACK_RADIUS
radiusSliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusSliderLabel.TextSize = 12
radiusSliderLabel.Font = Enum.Font.Gotham
radiusSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusSliderLabel.Parent = settingsPanel

local radiusSlider = Instance.new("TextBox")
radiusSlider.Size = UDim2.new(0.5, 0, 0.2, 0)
radiusSlider.Position = UDim2.new(0.45, 0, 0.3, 0)
radiusSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
radiusSlider.Text = tostring(ATTACK_RADIUS)
radiusSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusSlider.TextScaled = true
radiusSlider.Font = Enum.Font.Gotham
radiusSlider.Parent = settingsPanel

local radiusCorner = Instance.new("UICorner")
radiusCorner.CornerRadius = UDim.new(0, 6)
radiusCorner.Parent = radiusSlider

radiusSlider.FocusLost:Connect(function()
    local newValue = tonumber(radiusSlider.Text)
    if newValue and newValue > 0 then
        ATTACK_RADIUS = math.clamp(newValue, 10, 200)
        radiusSliderLabel.Text = "Радиус: " .. ATTACK_RADIUS
        radiusSlider.Text = tostring(ATTACK_RADIUS)
        
        StarterGui:SetCore("SendNotification", {
            Title = "Настройки",
            Text = "Радиус изменён на " .. ATTACK_RADIUS,
            Duration = 1
        })
    else
        radiusSlider.Text = tostring(ATTACK_RADIUS)
    end
end)

settingsButton.MouseButton1Click:Connect(function()
    settingsPanel.Visible = not settingsPanel.Visible
    if settingsPanel.Visible then
        -- Анимация появления
        settingsPanel.BackgroundTransparency = 0.15
    end
end)

-- Поиск папки Zombies_Local
local function findZombieContainer()
    local zombieParent = workspace:FindFirstChild("Zombies_Local")
    if zombieParent then return zombieParent end
    
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "Zombies_Local" then
            return child
        end
    end
    return nil
end

-- Получить всех живых зомби
local function getAliveZombies()
    local zombieContainer = findZombieContainer()
    local zombies = {}
    
    if zombieContainer then
        for _, zombieModel in pairs(zombieContainer:GetChildren()) do
            if zombieModel.Name == "Zombie" and zombieModel:IsA("Model") then
                local zombieHumanoid = zombieModel:FindFirstChild("Humanoid")
                if zombieHumanoid and zombieHumanoid.Health > 0 then
                    table.insert(zombies, zombieModel)
                end
            end
        end
    end
    
    return zombies
end

-- Нанести урон зомби
local function damageZombie(zombie)
    local zombieHumanoid = zombie:FindFirstChild("Humanoid")
    if zombieHumanoid and zombieHumanoid.Health > 0 then
        zombieHumanoid.Health = zombieHumanoid.Health - DAMAGE_AMOUNT
        
        local damageEvent = zombie:FindFirstChild("DamageEvent")
        if damageEvent and damageEvent:IsA("RemoteEvent") then
            damageEvent:FireServer(DAMAGE_AMOUNT)
        end
    end
end

-- Основная логика атаки
local function attackLoop()
    if not auraEnabled then return end
    
    local now = tick()
    if now - lastAttackTime < COOLDOWN then return end
    
    local zombies = getAliveZombies()
    local characterPos = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if characterPos and zombies then
        for _, zombie in pairs(zombies) do
            local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
            if zombieRoot then
                local distance = (characterPos.Position - zombieRoot.Position).Magnitude
                if distance <= ATTACK_RADIUS then
                    damageZombie(zombie)
                    lastAttackTime = now
                    break
                end
            end
        end
    end
end

-- Обновление персонажа
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
end)

-- Запуск
screenGui.Parent = Player:WaitForChild("PlayerGui")
setButtonState(false)
RunService.Heartbeat:Connect(attackLoop)

print("✅ Kill Aura загружена! Нажми на красную кнопку на экране для включения")
print("⚙️ Для настроек нажми на шестерёнку в правом нижнем углу кнопки")
