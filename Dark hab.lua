--[[
    NoClip GUI Script
    Работает только на клиенте (LocalScript).
    Помести в StarterGui или StarterPlayerScripts.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local noclipEnabled = false
local connection -- для отключения цикла

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoClipGUI"
screenGui.ResetOnSpawn = false -- GUI не исчезнет при смерти
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(0, 20, 0.5, -20) -- левый край по центру
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = "NoClip: OFF"
button.AutoButtonColor = true
button.BorderSizePixel = 0

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

button.Parent = screenGui

-- Функция для включения/выключения NoClip
local function toggleNoClip()
    noclipEnabled = not noclipEnabled
    button.Text = noclipEnabled and "NoClip: ON" or "NoClip: OFF"

    if noclipEnabled then
        -- Анимация подсветки кнопки
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goal = { BackgroundColor3 = Color3.fromRGB(0, 170, 80) }
        local tween = TweenService:Create(button, tweenInfo, goal)
        tween:Play()

        -- Запуск цикла NoClip
        connection = RunService.Stepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                -- Перебираем все части тела
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Возвращаем цвет кнопки
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goal = { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }
        local tween = TweenService:Create(button, tweenInfo, goal)
        tween:Play()

        -- Останавливаем цикл и включаем коллизию обратно
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- Восстанавливаем CanCollide
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Подключаем кнопку (с проверкой на двойные нажатия)
button.MouseButton1Click:Connect(toggleNoclip)

-- Дополнительно: Включение/выключение на клавишу "G" (можно убрать, если не нужно)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        toggleNoclip()
    end
end)

-- Очистка при удалении персонажа (на всякий случай)
player.CharacterAdded:Connect(function()
    if connection and noclipEnabled then
        -- Маленькая задержка, чтобы персонаж прогрузился
        task.wait(0.1)
        -- Перезапускаем цикл, так как старый потеряет ссылку на character
    end
end)
