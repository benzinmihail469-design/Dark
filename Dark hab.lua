-- ================= КАСТОМНЫЙ GUI (ИСПРАВЛЕННЫЙ 2026) ================= --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IYMouse = LocalPlayer:GetMouse()

local FLYING = false
local QEfly = true
local flyKeyDown, flyKeyUp

local ActiveFly = false
local ActiveSpeedBoost = false
local ActiveSpeedBoost2 = false
local ActiveJump = false
local ActiveNoclip = false

local FlySpeed = 1
local RunSpeedValue = 24
local WalkSpeedValue = 15
local JumpPowerValue = 50

-- ================= СОЗДАНИЕ GUI ================= --
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MovementGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999  -- поднимаем поверх большинства интерфейсов

    -- Самый надёжный способ вставки
    local success, err = pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end)

    if not success or not ScreenGui.Parent then
        warn("[Movement GUI] PlayerGui не найден, пробуем CoreGui...")
        pcall(function()
            ScreenGui.Parent = game:GetService("CoreGui")
        end)
    end

    if not ScreenGui.Parent then
        warn("[Movement GUI] Не удалось вставить GUI никуда! Скрипт не сможет работать.")
        return nil
    end

    print("[Movement GUI] ScreenGui вставлен в:", ScreenGui.Parent.Name)

    -- Основной фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui

    -- Рамка
    local Border = Instance.new("UIStroke")
    Border.Color = Color3.fromRGB(255, 100, 50)
    Border.Thickness = 2
    Border.Parent = MainFrame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    Title.BorderSizePixel = 0
    Title.Text = "SPEED HACK v2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 3)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = MainFrame

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Контейнер
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 5
    Container.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 50)
    Container.CanvasSize = UDim2.new(0, 0, 0, 600)
    Container.Parent = MainFrame

    -- Функция создания кнопки
    local function CreateButton(Name, YPos, Callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.Position = UDim2.new(0, 0, 0, YPos)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.BorderSizePixel = 0
        Button.Text = Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.Font = Enum.Font.GothamSemibold
        Button.AutoButtonColor = false
        Button.Parent = Container

        local Active = false

        local function UpdateVisual()
            if Active then
                Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                Button.Text = "[ON] " .. Name
            else
                Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Button.Text = Name
            end
        end

        Button.MouseButton1Click:Connect(function()
            Active = not Active
            UpdateVisual()
            if Callback then Callback(Active) end
        end)

        return {
            SetActive = function(state) Active = state UpdateVisual() end,
            IsActive = function() return Active end
        }
    end

    -- Функция создания слайдера (оставил почти без изменений, только мелкие правки)
    local function CreateSlider(Name, YPos, Min, Max, Default, Callback)
        -- ... (твой код слайдера полностью оставил, он нормальный)
        -- Чтобы не делать сообщение слишком длинным, я оставил его как было.
        -- Если нужно — скажи, я подправлю и его тоже.
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 55)
        SliderFrame.Position = UDim2.new(0, 0, 0, YPos)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 18)
        Label.BackgroundTransparency = 1
        Label.Text = Name .. ": " .. tostring(Default)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.Parent = SliderFrame

        local SliderBG = Instance.new("Frame")
        SliderBG.Size = UDim2.new(1, 0, 0, 25)
        SliderBG.Position = UDim2.new(0, 0, 0, 22)
        SliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SliderBG.Parent = SliderFrame

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
        Fill.Parent = SliderBG

        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.BackgroundTransparency = 1
        SliderButton.Text = ""
        SliderButton.Parent = SliderBG

        local CurrentValue = Default

        local function UpdateFill()
            local percent = (CurrentValue - Min) / (Max - Min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Label.Text = Name .. ": " .. tostring(CurrentValue)
            if Callback then Callback(CurrentValue) end
        end

        local dragging = false

        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
            local function UpdateFromMouse()
                if not dragging then return end
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = SliderBG.AbsolutePosition
                local sliderSize = SliderBG.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                CurrentValue = math.floor(Min + (Max - Min) * relativeX + 0.5)
                CurrentValue = math.clamp(CurrentValue, Min, Max)
                UpdateFill()
            end
            UpdateFromMouse()

            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    UpdateFromMouse()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end)

        UpdateFill()
        return {GetValue = function() return CurrentValue end}
    end

    -- ================= СОЗДАНИЕ ЭЛЕМЕНТОВ ================= --
    local YPosition = 5

    CreateSlider("Fly Speed", YPosition, 0, 10, 1, function(v) FlySpeed = v end)
    YPosition += 60

    CreateButton("Fly (Press F)", YPosition, function(active)
        ActiveFly = active
        -- логика флая вызывается через клавишу F ниже
    end)
    YPosition += 40

    CreateSlider("Run Speed", YPosition, 0, 100, 24, function(v) RunSpeedValue = v end)
    YPosition += 60

    CreateButton("Active RunSpeed", YPosition, function(active) ActiveSpeedBoost = active end)
    YPosition += 40

    CreateSlider("Walk Speed", YPosition, 0, 50, 15, function(v) WalkSpeedValue = v end)
    YPosition += 60

    CreateButton("Active WalkSpeed", YPosition, function(active) ActiveSpeedBoost2 = active end)
    YPosition += 40

    CreateSlider("Jump Power", YPosition, 0, 200, 50, function(v) JumpPowerValue = v end)
    YPosition += 60

    CreateButton("Active JumpPower", YPosition, function(active) ActiveJump = active end)
    YPosition += 40

    CreateButton("Noclip", YPosition, function(active)
        ActiveNoclip = active
        ApplyNoclip()
    end)
    YPosition += 40

    Container.CanvasSize = UDim2.new(0, 0, 0, YPosition + 20)

    print("[Movement GUI] GUI успешно создан!")
    return ScreenGui
end

-- ================= ОСТАЛЬНЫЕ ФУНКЦИИ (FLY, NOCLIP и т.д.) ================= --
-- (твой код функций sFLY, NOFLY, MobileFly, UnMobileFly, ApplyNoclip оставил почти без изменений)

-- ... (вставь сюда весь свой код функций полёта, noclip и RenderStepped, который был ниже)

-- ================= ЗАПУСК GUI ================= --
LocalPlayer:WaitForChild("PlayerGui")
task.wait(0.8) -- небольшой запас, чтобы всё прогрузилось

local GUI = CreateGUI()

if GUI then
    print("[Movement GUI] Скрипт полностью загружен!")
else
    warn("[Movement GUI] Критическая ошибка при создании GUI")
end
