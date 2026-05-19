local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Цветовая палитра
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

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Основной фрейм
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = colors.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.4

-- Акцентная линия
local AccentLine = Instance.new("Frame", Main)
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = colors.accent
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 12)
local grad = Instance.new("UIGradient", AccentLine)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 30, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 180))
}

-- TitleBar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "Dark Fantasy | Auto Loot"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -52, 0.5, -12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -12)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Контент
local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Size = UDim2.new(1, 0, 1, -32)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 32)
CollapsibleContent.BackgroundTransparency = 1

local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
TabButtonsFrame.BackgroundTransparency = 0.3

local list = Instance.new("UIListLayout", TabButtonsFrame)
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Padding = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Size = UDim2.new(1, -16, 1, -36)
ContentContainer.Position = UDim2.new(0, 8, 0, 32)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 3, 15)
ContentContainer.BackgroundTransparency = 0.5
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

-- === Переменные AutoLoot ===
local autoLootEnabled = false
local lootConnection = nil
local DISTANCE_THRESHOLD = 500
local TELEPORT_OFFSET = Vector3.new(0, 3, 0)

local function findLootFolder()
    local possibleNames = {"Loot", "loot", "LOOT", "Drops", "DropsFolder"}
    for _, name in ipairs(possibleNames) do
        local folder = workspace:FindFirstChild(name, true)
        if folder then return folder end
    end
    return nil
end

local function getObjectPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, v in obj:GetDescendants() do
            if v:IsA("BasePart") then return v.Position end
        end
    end
    return nil
end

local function TeleportToLoot(loot)
    if not autoLootEnabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = getObjectPosition(loot)
    if not pos then return end

    if (hrp.Position - pos).Magnitude > DISTANCE_THRESHOLD then
        char:PivotTo(CFrame.new(pos + TELEPORT_OFFSET))
    end
end

local function onLootAdded(loot)
    task.wait(0.1)
    TeleportToLoot(loot)
end

local function enableAutoLoot()
    if autoLootEnabled then return end
    local folder = findLootFolder()
    if not folder then
        warn("❌ Loot folder not found!")
        return
    end

    autoLootEnabled = true

    -- Телепорт к существующему лута
    for _, loot in ipairs(folder:GetChildren()) do
        task.spawn(TeleportToLoot, loot)
    end

    lootConnection = folder.ChildAdded:Connect(onLootAdded)
    print("✅ Auto Loot Enabled | Folder:", folder.Name)
end

local function disableAutoLoot()
    autoLootEnabled = false
    if lootConnection then
        lootConnection:Disconnect()
        lootConnection = nil
    end
end

-- === UI Компоненты ===
local draggingSlider = false

local function createSlider(parent, name, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -100, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -58, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = colors.gold
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderFrame = Instance.new("Frame", container)
    sliderFrame.Size = UDim2.new(1, -16, 0, 6)
    sliderFrame.Position = UDim2.new(0, 8, 0, 28)
    sliderFrame.BackgroundColor3 = colors.toggleOff
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = colors.accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("TextButton", sliderFrame)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0, -5)
    knob.BackgroundColor3 = colors.gold
    knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)

    local value = default

    local function update(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0, -5)
        label.Text = name .. ": " .. math.floor(value)
        valueLabel.Text = math.floor(value)
        if callback then callback(value) end
    end

    knob.MouseButton1Down:Connect(function() draggingSlider = true end)

    UserInputService.InputChanged:Connect(function(input)
        if not draggingSlider then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = sliderFrame.AbsolutePosition.X
            local sliderW = sliderFrame.AbsoluteSize.X
            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
            update(min + (max - min) * percent)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    update(default)
    return container
end

local function createToggle(parent, name, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local button = Instance.new("TextButton", container)
    button.Size = UDim2.new(1, -70, 0, 30)
    button.Position = UDim2.new(0, 8, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(30, 12, 45)
    button.Text = "   " .. name
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local toggleFrame = Instance.new("Frame", container)
    toggleFrame.Size = UDim2.new(0, 46, 0, 22)
    toggleFrame.Position = UDim2.new(1, -54, 0, 9)
    toggleFrame.BackgroundColor3 = colors.toggleOff
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 11)

    local circle = Instance.new("Frame", toggleFrame)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = colors.toggleCircle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 9)

    local enabled = default

    local function update()
        if enabled then
            toggleFrame.BackgroundColor3 = colors.toggleOn
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0, 2)}):Play()
        else
            toggleFrame.BackgroundColor3 = colors.toggleOff
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
    end

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
        callback(enabled)
    end)

    update()
end

-- Вкладки
local tabs = {}
local tabButtons = {}

local function createTab(name)
    local tab = Instance.new("Frame")
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.Parent = ContentContainer

    if name == "Main" then
        local scroll = Instance.new("ScrollingFrame", tab)
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = colors.accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

        local uiList = Instance.new("UIListLayout", scroll)
        uiList.Padding = UDim.new(0, 8)
        uiList.SortOrder = Enum.SortOrder.LayoutOrder

        createToggle(scroll, "📦 Auto Loot", false, function(val)
            if val then enableAutoLoot() else disableAutoLoot() end
        end)

        createSlider(scroll, "Дистанция телепорта", 100, 2000, DISTANCE_THRESHOLD, function(v)
            DISTANCE_THRESHOLD = v
        end)

        createSlider(scroll, "Скорость ходьбы", 16, 250, 16, function(v)
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = v end
        end)

    elseif name == "Info" then
        local lbl = Instance.new("TextLabel", tab)
        lbl.Size = UDim2.new(1, -20, 1, -20)
        lbl.Position = UDim2.new(0, 10, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.TextWrapped = true
        lbl.TextColor3 = colors.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.Text = "Dark Fantasy GUI v2.1\n\n• Авто-лут с PivotTo\n• Регулируемая дистанция\n• Улучшенный поиск папки Loot"
    end

    return tab
end

local function switchTab(name)
    for n, t in pairs(tabs) do
        t.Visible = (n == name)
    end
    for n, b in pairs(tabButtons) do
        if n == name then
            b.BackgroundColor3 = colors.tabActive
            b.TextColor3 = colors.gold
        else
            b.BackgroundColor3 = colors.tabInactive
            b.TextColor3 = colors.textDark
        end
    end
end

-- Создание вкладок
for _, name in ipairs({"Main", "Info", "Settings"}) do
    local btn = Instance.new("TextButton", TabButtonsFrame)
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = colors.tabInactive
    btn.Text = name
    btn.TextColor3 = colors.textDark
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    tabs[name] = createTab(name)
    tabButtons[name] = btn

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Main")

-- Минимизация
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 240, 0, 32)
        MinimizeBtn.Text = "+"
        CollapsibleContent.Visible = false
    else
        Main.Size = UDim2.new(0, 520, 0, 420)
        MinimizeBtn.Text = "—"
        CollapsibleContent.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    disableAutoLoot()
    ScreenGui:Destroy()
end)

-- Dragging
local dragging, dragInput, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = Main.Position
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragInput.Position
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("✅ Dark Fantasy GUI успешно загружен!")
