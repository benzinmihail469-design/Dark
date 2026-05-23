local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new(Color3.fromRGB(30, 30, 35), Color3.fromRGB(20, 20, 25))
UIGradient.Parent = MainFrame

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
Credits.Text = "Auto Prompt v2.0"
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
_G.PromptsList = {}

-- Функция для получения всех промптов вокруг игрока
local function getPromptsInRange()
    local prompts = {}
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return prompts end
    
    local rootPos = rootPart.Position
    
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local promptParent = prompt.Parent
            local promptPosition = promptParent and promptParent:FindFirstChild("HumanoidRootPart") or promptParent and promptParent:FindFirstChild("Head")
            
            if promptPosition and promptPosition.Position then
                local distance = (rootPos - promptPosition.Position).Magnitude
                if distance <= _G.ScanRange then
                    table.insert(prompts, {
                        prompt = prompt,
                        position = promptPosition.Position,
                        distance = distance
                    })
                end
            elseif promptParent and promptParent.PrimaryPart then
                local distance = (rootPos - promptParent.PrimaryPart.Position).Magnitude
                if distance <= _G.ScanRange then
                    table.insert(prompts, {
                        prompt = prompt,
                        position = promptParent.PrimaryPart.Position,
                        distance = distance
                    })
                end
            end
        end
    end
    
    -- Сортировка по расстоянию
    table.sort(prompts, function(a, b)
        return a.distance < b.distance
    end)
    
    return prompts
end

-- Функция для нахождения ближайшего промпта
local function findNearestPrompt()
    local prompts = getPromptsInRange()
    if #prompts > 0 then
        _G.NearestPrompt = prompts[1].prompt
        return _G.NearestPrompt
    end
    _G.NearestPrompt = nil
    return nil
end

-- Функция для автоматического взаимодействия с промптами
local function autoInteractLoop()
    while _G.AutoInteractEnabled do
        local nearest = findNearestPrompt()
        if nearest and nearest.Enabled then
            StatusLabel.Text = "Status: Interacting with prompt"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- Устанавливаем нулевую задержку для мгновенного взаимодействия
            local originalDuration = nearest.HoldDuration
            nearest.HoldDuration = 0
            
            -- Симулируем нажатие на промпт
            local args = {
                [1] = nearest
            }
            
            -- Запускаем взаимодействие
            nearest:Prompt()
            
            task.wait(0.1)
            
            -- Восстанавливаем оригинальную задержку
            if nearest and nearest.Parent then
                nearest.HoldDuration = originalDuration
            end
            
            task.wait(0.05)
        else
            StatusLabel.Text = "Status: Searching for prompts..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            task.wait(0.1)
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
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        table.clear(highlightEffects)
        
        -- Создаем новые подсветки для найденных промптов
        for _, promptData in pairs(prompts) do
            local prompt = promptData.prompt
            local promptParent = prompt.Parent
            
            if promptParent and not highlightEffects[promptParent] then
                local highlight = Instance.new("Highlight")
                highlight.Parent = promptParent
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.7
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0.3
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                table.insert(highlightEffects, highlight)
                
                highlightEffects[promptParent] = highlight
            end
        end
        
        StatusLabel.Text = string.format("Status: Found %d prompts", #prompts)
        
        if #prompts > 0 then
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        task.wait(0.5)
    end
    
    -- Очищаем подсветки при выключении
    for _, effect in pairs(highlightEffects) do
        if effect and effect.Parent then
            effect:Destroy()
        end
    end
end

-- Обработчик промптов
ProximityPromptService.PromptShown:Connect(function(prompt)
    if _G.AutoInteractEnabled then
        task.spawn(function()
            prompt.HoldDuration = 0
            prompt:Prompt()
            task.wait(0.05)
            if prompt and prompt.Parent then
                local originalDuration = prompt.HoldDuration
                prompt.HoldDuration = originalDuration or 1
            end
        end)
    end
end)

-- Функции для GUI
local function toggleAutoInteract()
    _G.AutoInteractEnabled = not _G.AutoInteractEnabled
    
    if _G.AutoInteractEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleButton.Text = "AUTO INTERACT ON"
        StatusLabel.Text = "Status: Auto interact enabled"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.spawn(autoInteractLoop)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.Text = "AUTO INTERACT OFF"
        StatusLabel.Text = "Status: Disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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
        StatusLabel.Text = "Status: Idle"
    end
end

-- Настройка дальности поиска
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
        local newRange = math.floor(relativeX * 45 + 5) -- От 5 до 50
        
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        _G.ScanRange = newRange
        RangeLabel.Text = string.format("Range: %d", newRange)
    end
end)

-- Обновление позиции слайдера при изменении диапазона
local function updateSliderPosition()
    local percentage = (_G.ScanRange - 5) / 45
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
end

updateSliderPosition()

-- Назначение кнопок
ToggleButton.MouseButton1Click:Connect(toggleAutoInteract)
AutoFindButton.MouseButton1Click:Connect(toggleFindPrompts)

-- Минимизация окна
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

-- Отслеживание персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("Auto Prompt Script Loaded!")
print("Hotkeys: V - Toggle Auto Interact | F - Find Prompts | P - Minimize")
