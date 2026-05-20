local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Цветовая палитра Dark Fantasy
local colors = {
    bg = Color3.fromRGB(15, 5, 20),
    titleBg = Color3.fromRGB(25, 10, 35),
    tabBg = Color3.fromRGB(20, 8, 30),
    tabActive = Color3.fromRGB(80, 20, 100),
    tabInactive = Color3.fromRGB(30, 12, 45),
    accent = Color3.fromRGB(180, 50, 220),
    gold = Color3.fromRGB(255, 180, 50),
    text = Color3.fromRGB(220, 200, 230),
    textDark = Color3.fromRGB(150, 130, 160),
    close = Color3.fromRGB(180, 30, 30),
    stroke = Color3.fromRGB(100, 50, 130),
    toggleOn = Color3.fromRGB(100, 30, 160),
    toggleOff = Color3.fromRGB(35, 15, 55),
    toggleCircle = Color3.fromRGB(220, 180, 255),
    buttonBg = Color3.fromRGB(50, 20, 80),
    buttonHover = Color3.fromRGB(70, 30, 110),
}

-- Основной фрейм
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = colors.stroke
Stroke.Transparency = 0.4
Stroke.Thickness = 1.5

local AccentLine = Instance.new("Frame", Main)
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = colors.accent
AccentLine.BorderSizePixel = 0
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 12)

local Gradient = Instance.new("UIGradient", AccentLine)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 30, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 180))
}

-- Заголовок
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Name = "Title"
Title.Text = "Dark Fantasy | Auto Loot"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", Main)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 10
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)
MinimizeBtn.AutoButtonColor = false

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.AutoButtonColor = false

local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Name = "CollapsibleContent"
CollapsibleContent.Size = UDim2.new(1, 0, 1, -32)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 32)
CollapsibleContent.BackgroundTransparency = 1
CollapsibleContent.BorderSizePixel = 0

local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 26)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
TabButtonsFrame.BackgroundTransparency = 0.3
TabButtonsFrame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 2)

local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -32)
ContentContainer.Position = UDim2.new(0, 8, 0, 30)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 3, 15)
ContentContainer.BackgroundTransparency = 0.5
ContentContainer.BorderSizePixel = 0
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

-- === ФУНКЦИЯ ДЛЯ СКОРОСТИ ===
local function setWalkSpeed(speed)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

-- === АВТО-ЛУТ С ОТЛАДКОЙ ===
local autoLootEnabled = true
local lootFolder = nil
local childAddedConnection = nil

local TELEPORT_OFFSET = Vector3.new(0, 2, 0)
local DISTANCE_THRESHOLD = 500

-- Поиск папки Loot
local function findLootFolder()
    print("[DEBUG] Поиск папки Loot...")
    
    local folder = workspace:FindFirstChild("Loot")
    if folder then
        print("[DEBUG] Найдена папка: Loot")
        return folder
    end
    
    folder = workspace:FindFirstChild("loot")
    if folder then
        print("[DEBUG] Найдена папка: loot")
        return folder
    end
    
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("Loot") then
            print("[DEBUG] Найдена папка: " .. child.Name .. ".Loot")
            return child.Loot
        end
        if child:FindFirstChild("loot") then
            print("[DEBUG] Найдена папка: " .. child.Name .. ".loot")
            return child.loot
        end
    end
    
    print("[DEBUG] ПАПКА LOOT НЕ НАЙДЕНА!")
    return nil
end

-- Телепорт к части
local function teleportToPart(targetPart)
    if not autoLootEnabled then return end
    
    local character = player.Character
    if not character then
        print("[DEBUG] Персонаж не найден")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("[DEBUG] HumanoidRootPart не найден")
        return
    end
    
    if not targetPart or not targetPart.Parent then
        print("[DEBUG] Целевая часть недействительна")
        return
    end
    
    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
    print("[DEBUG] Дистанция до лута: " .. math.floor(distance))
    
    if distance > DISTANCE_THRESHOLD then
        print("[DEBUG] ТЕЛЕПОРТ к: " .. targetPart.Parent.Name)
        humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
    else
        print("[DEBUG] Слишком близко, телепорт не нужен")
    end
end

-- Обработка лута
local function processLoot(lootModel)
    if not autoLootEnabled then return end
    
    print("[DEBUG] Обработка лута: " .. lootModel.Name)
    
    local targetPart = lootModel.PrimaryPart
    if not targetPart then
        targetPart = lootModel:FindFirstChildWhichIsA("BasePart")
    end
    
    if targetPart then
        teleportToPart(targetPart)
    else
        print("[DEBUG] Не найдена BasePart в луте: " .. lootModel.Name)
    end
end

-- Новый лут
local function onLootAdded(loot)
    if not autoLootEnabled then return end
    print("[DEBUG] Новый лут появился в папке: " .. loot.Name)
    task.wait(0.1)
    processLoot(loot)
end

-- Включение
local function enableAutoLoot()
    if autoLootEnabled then
        print("[DEBUG] Авто-лут уже включён")
        return
    end
    autoLootEnabled = true
    print("[DEBUG] Авто-лут ВКЛЮЧЁН")
    
    if lootFolder and childAddedConnection then
        childAddedConnection = lootFolder.ChildAdded:Connect(onLootAdded)
    end
end

-- Выключение
local function disableAutoLoot()
    if not autoLootEnabled then
        print("[DEBUG] Авто-лут уже выключён")
        return
    end
    autoLootEnabled = false
    print("[DEBUG] Авто-лут ВЫКЛЮЧЁН")
end

-- Находим папку и запускаем
lootFolder = findLootFolder()

if lootFolder then
    print("[DEBUG] УСПЕХ! Папка найдена, подключаем события...")
    childAddedConnection = lootFolder.ChildAdded:Connect(onLootAdded)
    
    -- Обработка существующего лута
    local children = lootFolder:GetChildren()
    print("[DEBUG] Найдено существующих объектов в папке: " .. #children)
    
    for _, loot in pairs(children) do
        task.spawn(function()
            processLoot(loot)
        end)
    end
else
    print("[DEBUG] ОШИБКА: Папка Loot не найдена! Авто-лут не будет работать.")
end

-- === СОЗДАНИЕ SLIDER ===
local function createSlider(parent, name, min, max, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", container)
    label.Text = name .. ": " .. tostring(default)
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -48, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = colors.gold
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderFrame = Instance.new("Frame", container)
    sliderFrame.Size = UDim2.new(1, -16, 0, 4)
    sliderFrame.Position = UDim2.new(0, 8, 0, 25)
    sliderFrame.BackgroundColor3 = colors.toggleOff
    sliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local knob = Instance.new("TextButton", sliderFrame)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, -7, 0, -5)
    knob.BackgroundColor3 = colors.gold
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
    
    local value = default
    local sliderWidth = 0
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0, -5)
        label.Text = name .. ": " .. math.floor(value)
        valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end
    
    local function updateWidth()
        sliderWidth = sliderFrame.AbsoluteSize.X
        if sliderWidth > 0 then
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -7, 0, -5)
        end
    end
    
    sliderFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWidth)
    task.wait(0.1)
    updateWidth()
    updateSlider(default)
    
    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = sliderFrame.AbsolutePosition.X
            if sliderWidth > 0 then
                local newPercent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
                local newValue = min + (max - min) * newPercent
                updateSlider(newValue)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return container
end

-- Функция создания Toggle
local function createToggle(parent, name, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local button = Instance.new("TextButton", container)
    button.Text = name
    button.Size = UDim2.new(1, -60, 0, 28)
    button.Position = UDim2.new(0, 8, 0, 3)
    button.BackgroundColor3 = Color3.fromRGB(30, 12, 45)
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.ZIndex = 5
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    
    local toggleFrame = Instance.new("Frame", container)
    toggleFrame.Size = UDim2.new(0, 40, 0, 20)
    toggleFrame.Position = UDim2.new(1, -48, 0, 7)
    toggleFrame.BackgroundColor3 = colors.toggleOff
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 6
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)
    
    local toggleCircle = Instance.new("Frame", toggleFrame)
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(100, 80, 120)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 7
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 8)
    
    local isOn = default
    
    local function updateToggle()
        if isOn then
            toggleFrame.BackgroundColor3 = colors.toggleOn
            toggleCircle.BackgroundColor3 = colors.toggleCircle
            TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -18, 0, 2)
            }):Play()
        else
            toggleFrame.BackgroundColor3 = colors.toggleOff
            toggleCircle.BackgroundColor3 = Color3.fromRGB(100, 80, 120)
            TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    updateToggle()
    
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
        if callback then callback(isOn) end
    end)
    
    local toggleButton = Instance.new("TextButton", toggleFrame)
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = 8
    
    toggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
        if callback then callback(isOn) end
    end)
    
    return container
end

-- Вкладки
local tabs = {}
local tabButtons = {}
local tabNames = {"Main", "Info", "Settings"}
local isMinimized = false

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    if name == "Main" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
        
        createToggle(scrollFrame, "📦 Auto Loot", autoLootEnabled, function(val)
            if val then enableAutoLoot() else disableAutoLoot() end
        end)
        
        local distSlider = createSlider(scrollFrame, "Teleport Distance", 50, 1000, DISTANCE_THRESHOLD, function(newValue)
            DISTANCE_THRESHOLD = math.floor(newValue)
            print("[DEBUG] Дистанция изменена на: " .. DISTANCE_THRESHOLD)
        end)
        distSlider.Position = UDim2.new(0, 0, 0, 40)
        
        local line = Instance.new("Frame", scrollFrame)
        line.Size = UDim2.new(1, -16, 0, 1)
        line.Position = UDim2.new(0, 8, 0, 105)
        line.BackgroundColor3 = colors.stroke
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        
        local speedSlider = createSlider(scrollFrame, "Walk Speed", 16, 250, 16, function(newValue)
            setWalkSpeed(newValue)
        end)
        speedSlider.Position = UDim2.new(0, 0, 0, 120)
        
        local statusLabel = Instance.new("TextLabel", scrollFrame)
        statusLabel.Text = "✅ Auto Loot Ready\n📁 Watching folder: 'Loot'\n📏 Distance: " .. DISTANCE_THRESHOLD
        statusLabel.Size = UDim2.new(1, -16, 0, 60)
        statusLabel.Position = UDim2.new(0, 8, 0, 190)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextColor3 = colors.textDark
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 9
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Info" then
        local infoText = Instance.new("TextLabel", tabContent)
        infoText.Text = "Dark Fantasy GUI\nVersion 2.6\n\nAuto Loot - Teleports to loot\n\nСмотри консоль для отладки!"
        infoText.Size = UDim2.new(1, -16, 1, 0)
        infoText.Position = UDim2.new(0, 8, 0, 10)
        infoText.BackgroundTransparency = 1
        infoText.TextColor3 = colors.text
        infoText.Font = Enum.Font.Gotham
        infoText.TextSize = 11
        infoText.TextWrapped = true
        infoText.TextXAlignment = Enum.TextXAlignment.Left
        infoText.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Settings" then
        local unloadBtn = Instance.new("TextButton", tabContent)
        unloadBtn.Text = "Unload Script"
        unloadBtn.Size = UDim2.new(0, 150, 0, 35)
        unloadBtn.Position = UDim2.new(0.5, -75, 0.5, -17)
        unloadBtn.BackgroundColor3 = colors.buttonBg
        unloadBtn.TextColor3 = colors.text
        unloadBtn.Font = Enum.Font.GothamBold
        unloadBtn.TextSize = 12
        unloadBtn.BorderSizePixel = 0
        Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 6)
        
        unloadBtn.MouseButton1Click:Connect(function()
            disableAutoLoot()
            if childAddedConnection then childAddedConnection:Disconnect() end
            ScreenGui:Destroy()
        end)
        
        unloadBtn.MouseEnter:Connect(function()
            TweenService:Create(unloadBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = colors.buttonHover
            }):Play()
        end)
        
        unloadBtn.MouseLeave:Connect(function()
            TweenService:Create(unloadBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = colors.buttonBg
            }):Play()
        end)
    end
    
    return tabContent
end

local function switchTab(tabName)
    for name, content in pairs(tabs) do
        content.Visible = (name == tabName)
    end
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = colors.tabActive
            button.TextColor3 = colors.gold
        else
            button.BackgroundColor3 = colors.tabInactive
            button.TextColor3 = colors.textDark
        end
    end
end

local function toggleMinimize()
    isMinimized = not isMinimized
    local currentPos = Main.Position
    
    if isMinimized then
        Main.Size = UDim2.new(0, 220, 0, 32)
        Main.Position = currentPos
        Title.TextSize = 11
        Title.Size = UDim2.new(1, -56, 1, 0)
        Title.Position = UDim2.new(0, 28, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Center
        MinimizeBtn.Position = UDim2.new(1, -52, 0, 4)
        MinimizeBtn.Text = "+"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 80)
        CloseBtn.Position = UDim2.new(1, -26, 0, 4)
        CollapsibleContent.Visible = false
        AccentLine.Visible = false
    else
        Main.Size = UDim2.new(0, 520, 0, 420)
        Main.Position = currentPos
        Title.TextSize = 13
        Title.Size = UDim2.new(0, 200, 1, 0)
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
        CloseBtn.Position = UDim2.new(1, -26, 0, 5)
        CollapsibleContent.Visible = true
        AccentLine.Visible = true
    end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
CloseBtn.MouseButton1Click:Connect(function() 
    disableAutoLoot()
    if childAddedConnection then childAddedConnection:Disconnect() end
    ScreenGui:Destroy() 
end)

for _, name in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton", TabButtonsFrame)
    tabButton.Name = name
    tabButton.Text = name
    tabButton.Size = UDim2.new(0, 80, 1, 0)
    tabButton.BackgroundColor3 = colors.tabInactive
    tabButton.TextColor3 = colors.textDark
    tabButton.Font = Enum.Font.GothamBlack
    tabButton.TextSize = 9
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 5)
    
    tabs[name] = createTab(name)
    tabButtons[name] = tabButton
    
    tabButton.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Main")

local UIS = game:GetService("UserInputService")
local frame = TitleBar
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Main.Position = UDim2.new(0.5, -260, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -260, 0.5, -210)
}):Play()

print("Dark Fantasy GUI loaded! Auto Loot is ACTIVE")
