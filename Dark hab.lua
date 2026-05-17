-- Dark Fantasy GUI для Slime RNG (полностью автономный, без HTTP запросов)
(function()
    -- Проверка на выполнение
    if shared and shared.DarkFantasyLoaded then
        print("⚠️ GUI уже загружен")
        return
    end
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then
        warn("Игрок не загружен")
        return
    end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старую GUI
    local oldGui = playerGui:FindFirstChild("DarkFantasyGUI")
    if oldGui then oldGui:Destroy() end
    
    -- === НАСТРОЙКИ ===
    local TELEPORT_OFFSET = Vector3.new(0, 2, 0)
    local DISTANCE_THRESHOLD = 3
    local PLAY_SOUND = true
    
    -- === ПОИСК ПАПКИ С ЛУТОМ ===
    local LOOT_FOLDER = workspace:FindFirstChild("Loot")
    if not LOOT_FOLDER then
        LOOT_FOLDER = workspace:FindFirstChild("loot")
    end
    if not LOOT_FOLDER then
        for _, child in pairs(workspace:GetChildren()) do
            if child:FindFirstChild("Loot") then
                LOOT_FOLDER = child.Loot
                break
            end
        end
    end
    
    if not LOOT_FOLDER then
        warn("⚠️ Папка Loot не найдена!")
    end
    
    -- === ЦВЕТА ===
    local C = {
        BG = Color3.fromRGB(18, 16, 22),
        Header = Color3.fromRGB(28, 24, 38),
        Accent = Color3.fromRGB(138, 92, 200),
        AccentDark = Color3.fromRGB(100, 60, 155),
        Text = Color3.fromRGB(240, 235, 255),
        TextDim = Color3.fromRGB(170, 160, 190),
        Button = Color3.fromRGB(38, 34, 48),
        Red = Color3.fromRGB(180, 60, 80),
        Green = Color3.fromRGB(70, 140, 100),
    }
    
    -- === СОЗДАНИЕ GUI ===
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkFantasyGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.6
    overlay.Visible = false
    overlay.Parent = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
    mainFrame.BackgroundColor3 = C.BG
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = C.Accent
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = C.Header
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ SLIME RNG | ТЁМНЫЙ ФАНТАЗИ ⚔️"
    title.TextColor3 = C.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 1, 0)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundColor3 = C.Red
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.Text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
    minimizeBtn.BackgroundColor3 = C.AccentDark
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = C.Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = titleBar
    
    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0, 60, 0, 60)
    openButton.Position = UDim2.new(0, 20, 1, -80)
    openButton.BackgroundColor3 = C.Accent
    openButton.Text = "⚔️"
    openButton.TextColor3 = C.Text
    openButton.TextSize = 30
    openButton.Font = Enum.Font.GothamBold
    openButton.BorderSizePixel = 1
    openButton.BorderColor3 = C.AccentDark
    openButton.Visible = true
    openButton.Parent = screenGui
    
    -- Вкладки
    local tabButtonsFrame = Instance.new("Frame")
    tabButtonsFrame.Size = UDim2.new(1, 0, 0, 45)
    tabButtonsFrame.Position = UDim2.new(0, 0, 0, 45)
    tabButtonsFrame.BackgroundColor3 = C.Button
    tabButtonsFrame.BorderSizePixel = 0
    tabButtonsFrame.Parent = mainFrame
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 1, -90)
    tabContainer.Position = UDim2.new(0, 0, 0, 90)
    tabContainer.BackgroundColor3 = C.BG
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabs = {"MAIN", "PLAYER", "INFO", "НАСТРОЙКИ"}
    local currentTab = nil
    local tabContents = {}
    
    local function createTab(tabName)
        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.new(1, -20, 1, -20)
        container.Position = UDim2.new(0, 10, 0, 10)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ScrollBarThickness = 6
        container.ScrollBarImageColor3 = C.Accent
        container.Visible = false
        container.Parent = tabContainer
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 12)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = container
        
        return container
    end
    
    for _, tab in pairs(tabs) do
        tabContents[tab] = createTab(tab)
    end
    
    local function switchTab(tabName)
        if currentTab then
            tabContents[currentTab].Visible = false
        end
        currentTab = tabName
        tabContents[tabName].Visible = true
    end
    
    local tabButtonsTable = {}
    for i, tab in pairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, -10)
        btn.Position = UDim2.new(0, 10 + (i-1)*105, 0, 5)
        btn.BackgroundColor3 = C.Button
        btn.Text = tab
        btn.TextColor3 = C.TextDim
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 1
        btn.BorderColor3 = C.AccentDark
        btn.Parent = tabButtonsFrame
        
        btn.MouseButton1Click:Connect(function()
            switchTab(tab)
            for _, b in pairs(tabButtonsTable) do
                b.BackgroundColor3 = C.Button
                b.TextColor3 = C.TextDim
            end
            btn.BackgroundColor3 = C.AccentDark
            btn.TextColor3 = C.Text
        end)
        
        tabButtonsTable[tab] = btn
    end
    
    -- === MAIN ВКЛАДКА ===
    local mainTab = tabContents["MAIN"]
    
    local lootStatusLabel = Instance.new("TextLabel")
    lootStatusLabel.Size = UDim2.new(0, 300, 0, 40)
    lootStatusLabel.BackgroundColor3 = C.Button
    lootStatusLabel.Text = "🔘 АВТО-ЛУТ: ВКЛЮЧЁН"
    lootStatusLabel.TextColor3 = C.Green
    lootStatusLabel.TextSize = 16
    lootStatusLabel.Font = Enum.Font.GothamBold
    lootStatusLabel.Parent = mainTab
    
    local lootToggleBtn = Instance.new("TextButton")
    lootToggleBtn.Size = UDim2.new(0, 200, 0, 35)
    lootToggleBtn.BackgroundColor3 = C.Accent
    lootToggleBtn.Text = "ВЫКЛЮЧИТЬ"
    lootToggleBtn.TextColor3 = C.Text
    lootToggleBtn.TextSize = 14
    lootToggleBtn.Font = Enum.Font.GothamBold
    lootToggleBtn.Parent = mainTab
    
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0, 250, 0, 45)
    teleportBtn.BackgroundColor3 = C.Accent
    teleportBtn.Text = "📦 ТЕЛЕПОРТ К БЛИЖАЙШЕМУ ЛУТУ"
    teleportBtn.TextColor3 = C.Text
    teleportBtn.TextSize = 16
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.Parent = mainTab
    
    local radiusLabel = Instance.new("TextLabel")
    radiusLabel.Size = UDim2.new(0, 250, 0, 25)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Text = "⚡ Радиус телепорта: " .. DISTANCE_THRESHOLD
    radiusLabel.TextColor3 = C.TextDim
    radiusLabel.TextSize = 14
    radiusLabel.Parent = mainTab
    
    local radiusPlus = Instance.new("TextButton")
    radiusPlus.Size = UDim2.new(0, 80, 0, 30)
    radiusPlus.BackgroundColor3 = C.Button
    radiusPlus.Text = "+ УВЕЛИЧИТЬ"
    radiusPlus.TextColor3 = C.TextDim
    radiusPlus.TextSize = 12
    radiusPlus.Parent = mainTab
    
    local radiusMinus = Instance.new("TextButton")
    radiusMinus.Size = UDim2.new(0, 80, 0, 30)
    radiusMinus.BackgroundColor3 = C.Button
    radiusMinus.Text = "- УМЕНЬШИТЬ"
    radiusMinus.TextColor3 = C.TextDim
    radiusMinus.TextSize = 12
    radiusMinus.Parent = mainTab
    
    -- === ЛОГИКА АВТО-ЛУТА ===
    local autoLootEnabled = true
    local childAddedConnection = nil
    
    local function teleportToPart(targetPart)
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and targetPart and targetPart.Parent then
            local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
            if distance > DISTANCE_THRESHOLD then
                humanoidRootPart.CFrame = CFrame.new(targetPart.Position + TELEPORT_OFFSET)
                print("✨ Телепорт к:", targetPart.Parent.Name)
            end
        end
    end
    
    local function teleportToNearestLoot()
        if not LOOT_FOLDER then 
            print("⚠️ Папка лута не найдена")
            return 
        end
        local nearest = nil
        local nearestDist = math.huge
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
            if loot:IsA("Model") then
                local part = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (hrp.Position - part.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = part
                    end
                end
            end
        end
        
        if nearest then
            teleportToPart(nearest)
            print("✅ Телепорт к ближайшему луту")
        else
            print("❌ Лут не найден")
        end
    end
    
    local function processLoot(lootModel)
        if not autoLootEnabled then return end
        task.wait(0.05)
        local targetPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")
        if targetPart then
            teleportToPart(targetPart)
        end
    end
    
    local function onLootAdded(loot)
        if loot:IsA("Model") then
            processLoot(loot)
        end
    end
    
    local function enableAutoLoot()
        if autoLootEnabled then return end
        autoLootEnabled = true
        lootStatusLabel.Text = "🔘 АВТО-ЛУТ: ВКЛЮЧЁН"
        lootStatusLabel.TextColor3 = C.Green
        lootToggleBtn.Text = "ВЫКЛЮЧИТЬ"
        if LOOT_FOLDER then
            childAddedConnection = LOOT_FOLDER.ChildAdded:Connect(onLootAdded)
            for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
                task.spawn(function() processLoot(loot) end)
            end
        end
    end
    
    local function disableAutoLoot()
        if not autoLootEnabled then return end
        autoLootEnabled = false
        lootStatusLabel.Text = "⭕ АВТО-ЛУТ: ВЫКЛЮЧЕН"
        lootStatusLabel.TextColor3 = C.Red
        lootToggleBtn.Text = "ВКЛЮЧИТЬ"
        if childAddedConnection then
            childAddedConnection:Disconnect()
            childAddedConnection = nil
        end
    end
    
    lootToggleBtn.MouseButton1Click:Connect(function()
        if autoLootEnabled then disableAutoLoot() else enableAutoLoot() end
    end)
    
    teleportBtn.MouseButton1Click:Connect(function()
        teleportToNearestLoot()
    end)
    
    radiusPlus.MouseButton1Click:Connect(function()
        DISTANCE_THRESHOLD = math.min(50, DISTANCE_THRESHOLD + 1)
        radiusLabel.Text = "⚡ Радиус телепорта: " .. DISTANCE_THRESHOLD
    end)
    
    radiusMinus.MouseButton1Click:Connect(function()
        DISTANCE_THRESHOLD = math.max(1, DISTANCE_THRESHOLD - 1)
        radiusLabel.Text = "⚡ Радиус телепорта: " .. DISTANCE_THRESHOLD
    end)
    
    -- === PLAYER ВКЛАДКА ===
    local playerTab = tabContents["PLAYER"]
    
    local playerStats = Instance.new("TextLabel")
    playerStats.Size = UDim2.new(0, 350, 0, 120)
    playerStats.BackgroundColor3 = C.Button
    playerStats.Text = "Загрузка..."
    playerStats.TextColor3 = C.Text
    playerStats.TextSize = 14
    playerStats.TextWrapped = true
    playerStats.Parent = playerTab
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 150, 0, 35)
    refreshBtn.BackgroundColor3 = C.Accent
    refreshBtn.Text = "🔄 ОБНОВИТЬ"
    refreshBtn.TextColor3 = C.Text
    refreshBtn.TextSize = 14
    refreshBtn.Parent = playerTab
    
    local function updatePlayerStats()
        local character = player.Character
        if not character then
            playerStats.Text = "⏳ Персонаж не загружен..."
            return
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.zero
        local humanoid = character:FindFirstChild("Humanoid")
        local health = humanoid and math.floor(humanoid.Health) or "?"
        local maxHealth = humanoid and humanoid.MaxHealth or "?"
        
        playerStats.Text = string.format(
            "📊 СТАТИСТИКА ИГРОКА\n\n👤 Имя: %s\n📍 X: %.1f | Y: %.1f | Z: %.1f\n❤️ Здоровье: %s / %s",
            player.Name, pos.X, pos.Y, pos.Z, tostring(health), tostring(maxHealth)
        )
    end
    
    refreshBtn.MouseButton1Click:Connect(function()
        updatePlayerStats()
    end)
    updatePlayerStats()
    
    -- Автообновление статистики
    task.spawn(function()
        while screenGui and screenGui.Parent do
            task.wait(2)
            if playerTab.Visible then
                updatePlayerStats()
            end
        end
    end)
    
    -- === INFO ВКЛАДКА ===
    local infoTab = tabContents["INFO"]
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(0, 400, 0, 250)
    infoText.BackgroundColor3 = C.Button
    infoText.Text = "⚔️ SLIME RNG - Тёмный Фантези\n\n📦 Авто-телепорт к луту\n📍 Телепорт к ближайшему луту\n🎚️ Настройка радиуса телепорта\n🎮 Кнопка открытия: ⚔️\n\n✨ Версия: 1.0\n📅 Обновлено: Сегодня"
    infoText.TextColor3 = C.TextDim
    infoText.TextSize = 14
    infoText.TextWrapped = true
    infoText.Parent = infoTab
    
    -- === НАСТРОЙКИ ===
    local settingsTab = tabContents["НАСТРОЙКИ"]
    
    local soundToggleBtn = Instance.new("TextButton")
    soundToggleBtn.Size = UDim2.new(0, 250, 0, 40)
    soundToggleBtn.BackgroundColor3 = C.Button
    soundToggleBtn.Text = "🔊 ЗВУК: ВЫКЛ (функция)"
    soundToggleBtn.TextColor3 = C.TextDim
    soundToggleBtn.TextSize = 14
    soundToggleBtn.Parent = settingsTab
    
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0, 200, 0, 45)
    unloadBtn.BackgroundColor3 = C.Red
    unloadBtn.Text = "❌ ВЫГРУЗИТЬ"
    unloadBtn.TextColor3 = C.Text
    unloadBtn.TextSize = 16
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.Parent = settingsTab
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 200, 0, 30)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Version: 1.0"
    versionLabel.TextColor3 = C.TextDim
    versionLabel.TextSize = 12
    versionLabel.Parent = settingsTab
    
    unloadBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        print("✅ GUI выгружен")
    end)
    
    soundToggleBtn.MouseButton1Click:Connect(function()
        print("🔊 Звук в разработке")
    end)
    
    -- === УПРАВЛЕНИЕ ОКНОМ ===
    local dragging = false
    local dragStart, frameStart
    local UIS = game:GetService("UserInputService")
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabContainer.Visible = not minimized
        tabButtonsFrame.Visible = not minimized
        mainFrame.Size = minimized and UDim2.new(0, 500, 0, 45) or UDim2.new(0, 500, 0, 550)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        overlay.Visible = false
        openButton.Visible = true
    end)
    
    openButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        overlay.Visible = true
        openButton.Visible = false
        if minimized then
            minimized = false
            tabContainer.Visible = true
            tabButtonsFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 500, 0, 550)
        end
    end)
    
    -- Анимация
    mainFrame.BackgroundTransparency = 1
    overlay.BackgroundTransparency = 1
    game:GetService("TweenService"):Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    game:GetService("TweenService"):Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
    
    -- Запуск
    switchTab("MAIN")
    tabButtonsTable["MAIN"].BackgroundColor3 = C.AccentDark
    tabButtonsTable["MAIN"].TextColor3 = C.Text
    enableAutoLoot()
    
    if shared then shared.DarkFantasyLoaded = true end
    
    print("✅ Dark Fantasy GUI загружен! Нажми ⚔️ в левом нижнем углу")
end)()
