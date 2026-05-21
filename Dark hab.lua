local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

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
Title.Text = "Dark Fantasy | Auto Loot + Equip Best"
Title.Size = UDim2.new(0, 280, 1, 0)
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

-- === ОПРЕДЕЛЕНИЕ УСТРОЙСТВА ===
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

-- === АВТО-ЛУТ (ПОЛНАЯ ВЕРСИЯ) ===
local autoLootEnabled = true
local equipBestEnabled = true
local lootFolder = nil
local childAddedConnection = nil
local equipBestConnection = nil

local TELEPORT_OFFSET = Vector3.new(0, 2, 0)

-- Поиск папки Loot
local function findLootFolder()
    local folder = workspace:FindFirstChild("Loot")
    if not folder then folder = workspace:FindFirstChild("loot") end
    if not folder then
        for _, child in pairs(workspace:GetChildren()) do
            if child:FindFirstChild("Loot") then
                folder = child.Loot
                break
            end
            if child:FindFirstChild("loot") then
                folder = child.loot
                break
            end
        end
    end
    return folder
end

-- Телепорт к луту
local function teleportToPart(targetPart)
    if not autoLootEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not targetPart or not targetPart.Parent then return end
    
    humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
end

-- Обработка лута
local function processLoot(lootModel)
    if not autoLootEnabled then return end
    
    local targetPart = lootModel.PrimaryPart
    if not targetPart then
        targetPart = lootModel:FindFirstChildWhichIsA("BasePart")
    end
    
    if targetPart then
        teleportToPart(targetPart)
    end
end

-- Новый лут
local function onLootAdded(loot)
    if not autoLootEnabled then return end
    task.wait(0.05)
    processLoot(loot)
end

-- === АВТОМАТИЧЕСКОЕ НАЖАТИЕ ЧЕРЕЗ PROXIMITY PROMPT ===
local function autoTriggerPrompt(prompt)
    if not autoLootEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local promptParent = prompt.Parent
    if promptParent and promptParent:IsA("BasePart") then
        local distance = (rootPart.Position - promptParent.Position).Magnitude
        
        if distance <= (prompt.MaxActivationDistance or 0) then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
            prompt:InputHoldEnd()
        end
    end
end

-- === ФУНКЦИЯ EQUIP BEST ===
local function findEquipBestButton()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local inventory = playerGui:FindFirstChild("Inventory")
    if not inventory then return nil end
    
    local pageInventoryContent = inventory:FindFirstChild("PageInventoryContent")
    if not pageInventoryContent then return nil end
    
    local slimesPage = pageInventoryContent:FindFirstChild("SlimesPage")
    if not slimesPage then return nil end
    
    local equipBestButton = slimesPage:FindFirstChild("EquipBestButton")
    return equipBestButton
end

-- Автоматическое нажатие Equip Best
local function autoEquipBest()
    if not equipBestEnabled then return end
    
    local button = findEquipBestButton()
    if button and button:IsA("TextButton") and button.Visible then
        button:Click()
    end
end

-- === ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ===
local function enableAutoLoot()
    if autoLootEnabled then return end
    autoLootEnabled = true
    
    if lootFolder and not childAddedConnection then
        childAddedConnection = lootFolder.ChildAdded:Connect(onLootAdded)
    end
end

local function disableAutoLoot()
    if not autoLootEnabled then return end
    autoLootEnabled = false
end

local function enableEquipBest()
    if equipBestEnabled then return end
    equipBestEnabled = true
end

local function disableEquipBest()
    if not equipBestEnabled then return end
    equipBestEnabled = false
end

-- Находим папку и запускаем авто-лут
lootFolder = findLootFolder()

if lootFolder then
    childAddedConnection = lootFolder.ChildAdded:Connect(onLootAdded)
    
    -- Обработка существующего лута
    for _, loot in pairs(lootFolder:GetChildren()) do
        task.spawn(function()
            processLoot(loot)
        end)
    end
    print("[Auto Loot] Папка найдена: " .. lootFolder.Name)
else
    print("[Auto Loot] Папка Loot не найдена!")
end

-- Запускаем отслеживание ProximityPrompt
ProximityPromptService.PromptShown:Connect(autoTriggerPrompt)

-- Запускаем Equip Best (каждые 2 секунды)
equipBestConnection = RunService.Heartbeat:Connect(function()
    autoEquipBest()
end)

print("[Auto Loot] Включён | Устройство: " .. (isMobile and "Телефон" or "ПК"))
print("[Equip Best] Включён")

-- === СОЗДАНИЕ TOGGLE ===
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
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 150)
        
        createToggle(scrollFrame, "📦 Auto Loot", autoLootEnabled, function(val)
            if val then enableAutoLoot() else disableAutoLoot() end
        end)
        
        createToggle(scrollFrame, "⚔️ Equip Best", equipBestEnabled, function(val)
            if val then enableEquipBest() else disableEquipBest() end
        end)
        
        local buttonExists = findEquipBestButton() ~= nil
        local statusLabel = Instance.new("TextLabel", scrollFrame)
        statusLabel.Text = "✅ Auto Loot Ready\n📁 Watching folder: 'Loot'\n🔘 Auto-press ProximityPrompt\n⚔️ Equip Best: " .. (buttonExists and "✅ Доступна" or "❌ Не найдена") .. "\n📱 " .. (isMobile and "Телефон режим" or "ПК режим")
        statusLabel.Size = UDim2.new(1, -16, 0, 110)
        statusLabel.Position = UDim2.new(0, 8, 0, 80)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextColor3 = colors.textDark
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 9
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Info" then
        local infoText = Instance.new("TextLabel", tabContent)
        infoText.Text = "Dark Fantasy GUI\nVersion 3.3\n\nAuto Loot:\n- Телепорт к луту (папка Loot)\n- Автонажатие ProximityPrompt\n\nEquip Best:\n- Автонажатие кнопки EquipBestButton\n- Путь: PlayerGui → Inventory → PageInventoryContent → SlimesPage → EquipBestButton"
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
            autoLootEnabled = false
            equipBestEnabled = false
            if childAddedConnection then childAddedConnection:Disconnect() end
            if equipBestConnection then equipBestConnection:Disconnect() end
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
        Title.Size = UDim2.new(0, 280, 1, 0)
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
    autoLootEnabled = false
    equipBestEnabled = false
    if childAddedConnection then childAddedConnection:Disconnect() end
    if equipBestConnection then equipBestConnection:Disconnect() end
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

print("Dark Fantasy GUI загружен | Auto Loot + Equip Best")
