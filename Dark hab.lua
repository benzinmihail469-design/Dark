-- Настройки интерфейса и полета
local SPEED = 50 -- Скорость полета

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local flying = false
local flyConnection = nil
local bv, bg = nil, nil

-- Создание UI (Адаптировано под ПК и Телефоны)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyGui_MobileFixed"
ScreenGui.ResetOnSpawn = false
-- Защита UI от удаления/обнаружения в зависимости от эксплоита
local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
ScreenGui.Parent = parent

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 60)
MainFrame.Position = UDim2.new(0.5, -80, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать пальцем или мышкой
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Обводка
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Кнопка Включения/Выключения полета
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 1, -20)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "FLY: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(240, 70, 70)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleButton

-- Функция полета
local function startFlying()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not root or not humanoid then return end
	
	-- Отключаем стандартные состояния, чтобы персонаж не падал
	humanoid.PlatformStand = true
	
	-- Настройка сил для удержания в воздухе
	bg = Instance.new("BodyGyro")
	bg.P = 9e4
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.cframe = root.CFrame
	bg.Parent = root
	
	bv = Instance.new("BodyVelocity")
	bv.velocity = Vector3.new(0, 0.1, 0)
	bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Parent = root
	
	-- Основной цикл полета (привязан к камере)
	local camera = workspace.CurrentCamera
	flyConnection = RunService.RenderStepped:Connect(localFunction()
		if root and humanoid then
			-- Направление движения зависит от того, куда смотрит камера
			local moveDirection = humanoid.MoveDirection
			
			if moveDirection.Magnitude > 0 then
				-- Если игрок жмет джойстик на телефоне или WASD на ПК
				bv.velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z * 1.5)) * SPEED
			else
				-- Если стоит на месте — зависаем
				bv.velocity = Vector3.new(0, 0, 0)
			end
			
			-- Персонаж всегда смотрит туда же, куда и камера
			bg.cframe = camera.CFrame
		end
	end)
end

local function stopFlying()
	flying = false
	ToggleButton.Text = "FLY: OFF"
	ToggleButton.TextColor3 = Color3.fromRGB(240, 70, 70)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	
	if flyConnection then flyConnection:Disconnect() end
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
end

-- Логика кнопки
ToggleButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		ToggleButton.Text = "FLY: ON"
		ToggleButton.TextColor3 = Color3.fromRGB(70, 240, 70)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
		startFlying()
	else
		stopFlying()
	end
end)

-- Сброс полета при возрождении (чтобы скрипт не ломался после смерти)
player.CharacterAdded:Connect(function()
	stopFlying()
end)
