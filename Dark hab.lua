-- =============================================
--   СКОРОСТЬ С ПРОСТЫМ GUI для Bite by Night
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основная рамка
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Speed Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Run Speed
local runLabel = Instance.new("TextLabel")
runLabel.Size = UDim2.new(0.6, 0, 0, 25)
runLabel.Position = UDim2.new(0.05, 0, 0, 40)
runLabel.BackgroundTransparency = 1
runLabel.Text = "Run Speed:"
runLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
runLabel.TextXAlignment = Enum.TextXAlignment.Left
runLabel.Parent = frame

local runSlider = Instance.new("TextBox")
runSlider.Size = UDim2.new(0.3, 0, 0, 25)
runSlider.Position = UDim2.new(0.65, 0, 0, 40)
runSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
runSlider.Text = "30"
runSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
runSlider.Parent = frame

local runToggle = Instance.new("TextButton")
runToggle.Size = UDim2.new(0.25, 0, 0, 25)
runToggle.Position = UDim2.new(0.7, 0, 0, 70)
runToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
runToggle.Text = "ON"
runToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
runToggle.Parent = frame

-- Walk Speed
local walkLabel = Instance.new("TextLabel")
walkLabel.Size = UDim2.new(0.6, 0, 0, 25)
walkLabel.Position = UDim2.new(0.05, 0, 0, 100)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "Walk Speed:"
walkLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
walkLabel.TextXAlignment = Enum.TextXAlignment.Left
walkLabel.Parent = frame

local walkSlider = Instance.new("TextBox")
walkSlider.Size = UDim2.new(0.3, 0, 0, 25)
walkSlider.Position = UDim2.new(0.65, 0, 0, 100)
walkSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
walkSlider.Text = "18"
walkSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
walkSlider.Parent = frame

local walkToggle = Instance.new("TextButton")
walkToggle.Size = UDim2.new(0.25, 0, 0, 25)
walkToggle.Position = UDim2.new(0.7, 0, 0, 130)
walkToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
walkToggle.Text = "ON"
walkToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
walkToggle.Parent = frame

-- Переменные
local RunSpeedValue = 30
local WalkSpeedValue = 18
local EnableRunSpeed = true
local EnableWalkSpeed = true

-- Применение скорости
local function ApplySpeed()
    local char = player.Character
    if not char then return end
    
    if EnableRunSpeed then
        char:SetAttribute("RunSpeed", RunSpeedValue)
    end
    if EnableWalkSpeed then
        char:SetAttribute("WalkSpeed", WalkSpeedValue)
    end
end

RunService.RenderStepped:Connect(ApplySpeed)

player.CharacterAdded:Connect(function()
    task.wait(0.6)
    ApplySpeed()
end)

-- Обработка слайдеров
runSlider.FocusLost:Connect(function()
    local num = tonumber(runSlider.Text)
    if num then
        RunSpeedValue = math.clamp(num, 0, 100)
        runSlider.Text = tostring(RunSpeedValue)
    end
end)

walkSlider.FocusLost:Connect(function()
    local num = tonumber(walkSlider.Text)
    if num then
        WalkSpeedValue = math.clamp(num, 0, 100)
        walkSlider.Text = tostring(WalkSpeedValue)
    end
end)

-- Тогглы
runToggle.MouseButton1Click:Connect(function()
    EnableRunSpeed = not EnableRunSpeed
    runToggle.Text = EnableRunSpeed and "ON" or "OFF"
    runToggle.BackgroundColor3 = EnableRunSpeed and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

walkToggle.MouseButton1Click:Connect(function()
    EnableWalkSpeed = not EnableWalkSpeed
    walkToggle.Text = EnableWalkSpeed and "ON" or "OFF"
    walkToggle.BackgroundColor3 = EnableWalkSpeed and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

print("✅ GUI скорости загружен!")
print("Окно можно перетаскивать мышкой")
