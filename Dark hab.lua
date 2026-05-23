local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local AutoFindButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local Credits = Instance.new("TextLabel")
local RangeLabel = Instance.new("TextLabel")
local RangeSlider = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "AutoPromptHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 210)
MainFrame.BackgroundTransparency = 0.1

local UICorner_Frame = Instance.new("UICorner")
UICorner_Frame.CornerRadius = UDim.new(0, 10)
UICorner_Frame.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Size = UDim2.new(0, 170, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Auto Prompt"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.Position = UDim2.new(1, -35, 0, 12)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

local UICorner_Min = Instance.new("UICorner")
UICorner_Min.CornerRadius = UDim.new(0, 5)
UICorner_Min.Parent = MinimizeButton

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Position = UDim2.new(0.5, 0, 0.32, 0)
ToggleButton.Size = UDim2.new(0, 180, 0, 35)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "AUTO INTERACT OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

local UICorner_Button = Instance.new("UICorner")
UICorner_Button.CornerRadius = UDim.new(0, 8)
UICorner_Button.Parent = ToggleButton

AutoFindButton.Name = "AutoFindButton"
AutoFindButton.Parent = MainFrame
AutoFindButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
AutoFindButton.Position = UDim2.new(0.5, 0, 0.52, 0)
AutoFindButton.Size = UDim2.new(0, 180, 0, 35)
AutoFindButton.Font = Enum.Font.GothamSemibold
AutoFindButton.Text = "FIND PROMPTS"
AutoFindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFindButton.TextSize = 14

local UICorner_Auto = Instance.new("UICorner")
UICorner_Auto.CornerRadius = UDim.new(0, 8)
UICorner_Auto.Parent = AutoFindButton

RangeLabel.Name = "RangeLabel"
RangeLabel.Parent = MainFrame
RangeLabel.BackgroundTransparency = 1
RangeLabel.Position = UDim2.new(0, 10, 0, 110)
RangeLabel.Size = UDim2.new(0, 200, 0, 20)
RangeLabel.Font = Enum.Font.GothamSemibold
RangeLabel.Text = "Range: 15"
RangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeLabel.TextSize = 12
RangeLabel.TextXAlignment = Enum.TextXAlignment.Left

RangeSlider.Name = "RangeSlider"
RangeSlider.Parent = MainFrame
RangeSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
RangeSlider.Position = UDim2.new(0, 10, 0, 130)
RangeSlider.Size = UDim2.new(0, 200, 0, 15)
RangeSlider.Text = ""
RangeSlider.AutoButtonColor = false

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Parent = RangeSlider
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.Position = UDim2.new(0, 0, 0, 0)

local UICorner_Slider = Instance.new("UICorner")
UICorner_Slider.CornerRadius = UDim.new(0, 7)
UICorner_Slider.Parent = RangeSlider

local UICorner_Fill = Instance.new("UICorner")
UICorner_Fill.CornerRadius = UDim.new(0, 7)
UICorner_Fill.Parent = SliderFill

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 155)
StatusLabel.Size = UDim2.new(0, 200, 0, 20)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

Credits.Name = "Credits"
Credits.Parent = MainFrame
Credits.BackgroundTransparency = 1
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Font = Enum.Font.GothamSemibold
Credits.Text = "Auto Prompt v3.0"
Credits.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits.TextSize = 11

-- Перетаскивание окна
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Переменные
local _G = _G or {}
_G.AutoInteractEnabled = false
_G.FindPromptsEnabled = false
_G.ScanRange = 15
_G.NearestPrompt = nil

-- ПОЛУЧЕНИЕ ПОЗИЦИИ ОБЪЕКТА
local function getObjectPosition(obj)
    local hrp = obj:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        return hrp.Position
    end
    
    local head = obj:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head.Position
    end
    
    for _, child in pairs(obj:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    
    local success, pos = pcall(function()
        return obj.Position
    end)
    if success and type(pos) == "Vector3" then
        return pos
    end
    
    return nil
end

-- Функция для получения всех промптов вокруг игрока
local function getPromptsInRange()
    local prompts = {}
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return prompts end
    
    local rootPos = rootPart.Position
    
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local promptParent = prompt.Parent
            if promptParent then
                local promptPosition = getObjectPosition(promptParent)
                
                if promptPosition then
                    local distance = (rootPos - promptPosition).Magnitude
                    if distance <= _G.ScanRange then
                        table.insert(prompts, {
                            prompt = prompt,
                            position = promptPosition,
                            distance = distance,
                            parent = promptParent
                        })
                    end
                end
            end
        end
    end
    
    table.sort(prompts, function(a, b)
        return a.distance < b.distance
    end)
    
    return prompts
end

-- ОСНОВНАЯ ФУНКЦИЯ АВТОНАЖАТИЯ
local function interactWithPrompt(prompt)
    if not prompt or not prompt.Enabled then return false end
    
    -- Сохраняем оригинальную задержку
    local originalDuration = prompt.HoldDuration
    local originalRequiresHold = prompt.RequiresHold
    
    -- Устанавливаем мгновенное взаимодействие
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresHold = false
    end)
    
    -- Метод 1: Симуляция нажатия клавиши (обычно E или F)
    local success = pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    
    -- Метод 2: Использование PromptButtonEvent
    task.wait(0.05)
    pcall(function()
        local args = {
            [1] = prompt,
            [2] = player
        }
        game:GetService("ReplicatedStorage"):FindFirstChild("PromptButtonEvent"):FireServer(unpack(args))
    end)
    
    -- Метод 3: Вызов через ProximityPromptService
    task.wait(0.05)
    pcall(function()
        ProximityPromptService:PromptButtonHoldComplete(prompt, player)
    end)
    
    -- Метод 4: Прямой вызов Prompt через удаленное событие
    task.wait(0.05)
    pcall(function()
        local mouse = player:GetMouse()
        if mouse then
            mouse.KeyPress:Connect(function(key)
                if key == Enum.KeyCode.E then
                    -- Эмуляция нажатия
                end
            end)
        end
    end)
    
    -- Восстанавливаем оригинальные настройки
    task.wait(0.1)
    pcall(function()
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalDuration
            prompt.RequiresHold = originalRequiresHold
        end
    end)
    
    return true
end

-- Функция для автоматического взаимодействия
local function autoInteractLoop()
    local lastInteractTime = 0
    local currentTarget = nil
    
    while _G.AutoInteractEnabled do
        local success, prompts = pcall(getPromptsInRange)
        
        if success and prompts and #prompts > 0 then
            local nearest = prompts[1]
            
            -- Если новый промпт или прошло достаточно времени
            if currentTarget ~= nearest.prompt or tick() - lastInteractTime > 0.5 then
                currentTarget = nearest.prompt
                lastInteractTime = tick()
                
                StatusLabel.Text = string.format("Status: Interacting (%.1f studs)", nearest.distance)
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                -- Пытаемся взаимодействовать
                pcall(function()
                    interactWithPrompt(nearest.prompt)
                end)
                
                task.wait(0.15)
            else
                task.wait(0.05)
            end
        else
            StatusLabel.Text = "Status: No prompts in range"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            currentTarget = nil
            task.wait(0.2)
        end
    end
end

-- Функция для поиска и подсветки промптов
local function findPromptsLoop()
    local highlightEffects = {}
    
    while _G.FindPromptsEnabled do
        local prompts = getPromptsInRange()
        
        -- Удаляем старые подсветки
        for _, effect in pairs(highlightEffects) do
            pcall(function()
                if effect and effect.Parent then
                    effect:Destroy()
                end
            end)
        end
        table.clear(highlightEffects)
        
        -- Создаем новые подсветки
        for _, promptData in pairs(prompts) do
            local promptParent = promptData.parent
            
            if promptParent and not highlightEffects[promptParent] then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = promptParent
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0.2
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    table.insert(highlightEffects, highlight)
                    highlightEffects[promptParent] = highlight
                end)
            end
        end
        
        if #prompts > 0 then
            StatusLabel.Text = string.format("Found: %d | Nearest: %.1f", #prompts, prompts[1].distance)
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.Text = "No prompts found"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        task.wait(0.3)
    end
    
    -- Очистка
    for _, effect in pairs(highlightEffects) do
        pcall(function() effect:Destroy() end)
    end
end

-- Функции GUI
local function toggleAutoInteract()
    _G.AutoInteractEnabled = not _G.AutoInteractEnabled
    
    if _G.AutoInteractEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleButton.Text = "AUTO INTERACT ON"
        StatusLabel.Text = "Status: Starting..."
        task.spawn(autoInteractLoop)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.Text = "AUTO INTERACT OFF"
        StatusLabel.Text = "Status: Disabled"
    end
end

local function toggleFindPrompts()
    _G.FindPromptsEnabled = not _G.FindPromptsEnabled
    
    if _G.FindPromptsEnabled then
        AutoFindButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        AutoFindButton.Text = "SCANNING..."
        task.spawn(findPromptsLoop)
    else
        AutoFindButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        AutoFindButton.Text = "FIND PROMPTS"
        if not _G.AutoInteractEnabled then
            StatusLabel.Text = "Status: Idle"
        end
    end
end

-- Слайдер дальности
local draggingSlider = false

RangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

RangeSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp((input.Position.X - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
        local newRange = math.floor(relativeX * 45 + 5)
        
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        _G.ScanRange = newRange
        RangeLabel.Text = string.format("Range: %d", newRange)
    end
end)

-- Кнопки
ToggleButton.MouseButton1Click:Connect(toggleAutoInteract)
AutoFindButton.MouseButton1Click:Connect(toggleFindPrompts)

-- Минимизация
local minimized = false
local function toggleMinimize()
    minimized = not minimized
    if minimized then
        ToggleButton.Visible = false
        AutoFindButton.Visible = false
        RangeLabel.Visible = false
        RangeSlider.Visible = false
        StatusLabel.Visible = false
        Credits.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 200, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 210), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        MinimizeButton.Text = "-"
        task.wait(0.1)
        ToggleButton.Visible = true
        AutoFindButton.Visible = true
        RangeLabel.Visible = true
        RangeSlider.Visible = true
        StatusLabel.Visible = true
        Credits.Visible = true
    end
end

MinimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        toggleAutoInteract()
    elseif input.KeyCode == Enum.KeyCode.F then
        toggleFindPrompts()
    elseif input.KeyCode == Enum.KeyCode.P then
        toggleMinimize()
    end
end)

-- Переподключение персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("=== Auto Prompt v3.0 Loaded ===")
print("Hotkeys: V - Auto Interact | F - Find Prompts | P - Minimize")
print("The script will automatically interact with nearby prompts")
