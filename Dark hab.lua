local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Удаление старого GUI
if player.PlayerGui:FindFirstChild("DarkFantasy_GUI") then
	player.PlayerGui.DarkFantasy_GUI:Destroy()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Исправляет отступы на мобильных устройствах

-- Цвета
local colors = {
	bg = Color3.fromRGB(15,5,20),
	titleBg = Color3.fromRGB(25,10,35),
	tabBg = Color3.fromRGB(20,8,30),
	tabActive = Color3.fromRGB(80,20,100),
	tabInactive = Color3.fromRGB(30,12,45),
	accent = Color3.fromRGB(180,50,220),
	gold = Color3.fromRGB(255,180,50),
	text = Color3.fromRGB(220,200,230),
	textDark = Color3.fromRGB(150,130,160),
	close = Color3.fromRGB(180,30,30),
	stroke = Color3.fromRGB(100,50,130),
	toggleOn = Color3.fromRGB(100,30,160),
	toggleOff = Color3.fromRGB(35,15,55),
	toggleCircle = Color3.fromRGB(220,180,255),
	buttonBg = Color3.fromRGB(50,20,80),
}

local isMobile = UserInputService.TouchEnabled

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,520,0,420)
Main.Position = UDim2.new(0.5,-260,0.5,-210)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.ClipsDescendants = true
Main.Active = true -- Для drag на мобильных устройствах

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = colors.stroke
Stroke.Transparency = 0.4
Stroke.Thickness = 1.5

local AccentLine = Instance.new("Frame", Main)
AccentLine.Size = UDim2.new(1,0,0,2)
AccentLine.BackgroundColor3 = colors.accent
AccentLine.BorderSizePixel = 0

-- TitleBar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.Position = UDim2.new(0,0,0,2)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-70,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Dark Fantasy | Auto Loot + Equip Best"
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons
local MinimizeBtn = Instance.new("TextButton", Main)
MinimizeBtn.Size = UDim2.new(0,24,0,24)
MinimizeBtn.Position = UDim2.new(1,-52,0,5)
MinimizeBtn.Text = "—"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40,15,60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.AutoButtonColor = false

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0,6)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0,24,0,24)
CloseBtn.Position = UDim2.new(1,-26,0,5)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,0,1,-32)
Content.Position = UDim2.new(0,0,0,32)
Content.BackgroundTransparency = 1

-- Scroll
local Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1,-16,1,-16)
Scroll.Position = UDim2.new(0,8,0,8)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,6)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
end)

-- Variables
local autoLootEnabled = true
local equipBestEnabled = true
local minimized = false
local TELEPORT_OFFSET = Vector3.new(0,2,0)

-- Функция для поиска папки с лутом
local function findLootFolder()
	return workspace:FindFirstChild("Loot") or workspace:FindFirstChild("loot")
end

-- Проверка существования и валидности лута
local function isValidLoot(loot)
	if not loot or not loot.Parent then return false end
	
	-- Проверяем, что объект существует и видим
	local primaryPart = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return false end
	
	return true
end

-- Безопасная телепортация с проверкой
local function teleportToPart(part)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	-- Проверка расстояния, чтобы не телепортироваться слишком часто к одному и тому же
	local distance = (root.Position - part.Position).Magnitude
	if distance < 5 then return end
	
	root.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
	task.wait(0.1) -- Небольшая задержка после телепортации
end

-- Обработка лута
local function processLoot(loot)
	if not autoLootEnabled then return end
	
	local target = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")
	if target and target:IsA("BasePart") then
		teleportToPart(target)
	end
end

-- Auto Prompt с проверкой
local promptConnection = nil

local function autoTriggerPrompt(prompt)
	if not autoLootEnabled then return end
	if not prompt or not prompt:IsA("ProximityPrompt") then return end
	
	-- Проверка, что игрок рядом с промптом
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	
	if rootPart and prompt.Parent then
		local promptPart = prompt.Parent:FindFirstChildWhichIsA("BasePart")
		if promptPart then
			local distance = (rootPart.Position - promptPart.Position).Magnitude
			if distance <= prompt.MaxActivationDistance then
				pcall(function()
					fireproximityprompt(prompt)
				end)
			end
		end
	end
end

if ProximityPromptService then
	promptConnection = ProximityPromptService.PromptShown:Connect(autoTriggerPrompt)
end

-- Equip Best с улучшенным поиском
local function findEquipBestButton()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then return nil end
	
	-- Рекурсивный поиск кнопки
	local function searchButton(container)
		for _, child in pairs(container:GetChildren()) do
			if child:IsA("TextButton") and child.Name and string.find(child.Name:lower(), "equip") and string.find(child.Name:lower(), "best") then
				return child
			end
			if child:IsA("Frame") or child:IsA("ScrollingFrame") then
				local found = searchButton(child)
				if found then return found end
			end
		end
		return nil
	end
	
	return searchButton(gui)
end

local function autoEquipBest()
	if not equipBestEnabled then return end
	
	local button = findEquipBestButton()
	
	if button and button:IsA("TextButton") and button.Visible and button.Active then
		pcall(function()
			-- Пытаемся нажать кнопку разными способами
			if button:FindFirstChild("UICorner") then
				button:CaptureMouse()
				button:ReleaseMouse()
			end
			
			for _, connection in pairs(getconnections(button.MouseButton1Click)) do
				connection:Fire()
			end
			
			-- Альтернативный метод
			button:Click()
		end)
	end
end

-- Toggle creator с улучшенной анимацией
local function createToggle(text, default, callback)
	local container = Instance.new("Frame", Scroll)
	container.Size = UDim2.new(1,-10,0,35)
	container.BackgroundTransparency = 1

	local button = Instance.new("TextButton", container)
	button.Size = UDim2.new(1,-60,0,28)
	button.Position = UDim2.new(0,5,0,3)
	button.Text = text
	button.BackgroundColor3 = Color3.fromRGB(30,12,45)
	button.TextColor3 = colors.text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.BorderSizePixel = 0
	button.AutoButtonColor = false

	Instance.new("UICorner", button).CornerRadius = UDim.new(0,5)

	local toggleFrame = Instance.new("Frame", container)
	toggleFrame.Size = UDim2.new(0,40,0,20)
	toggleFrame.Position = UDim2.new(1,-48,0,7)
	toggleFrame.BackgroundColor3 = colors.toggleOff
	toggleFrame.BorderSizePixel = 0

	Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0,10)

	local toggleCircle = Instance.new("Frame", toggleFrame)
	toggleCircle.Size = UDim2.new(0,16,0,16)
	toggleCircle.Position = UDim2.new(0,2,0,2)
	toggleCircle.BackgroundColor3 = colors.toggleCircle
	toggleCircle.BorderSizePixel = 0

	Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0,8)

	local clickArea = Instance.new("TextButton", toggleFrame)
	clickArea.Size = UDim2.new(1,0,1,0)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.BorderSizePixel = 0

	local enabled = default

	local update
	update = function()
		if enabled then
			toggleFrame.BackgroundColor3 = colors.toggleOn
			local tween = TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
				Position = UDim2.new(1,-18,0,2)
			})
			tween:Play()
		else
			toggleFrame.BackgroundColor3 = colors.toggleOff
			local tween = TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
				Position = UDim2.new(0,2,0,2)
			})
			tween:Play()
		end
	end

	local function toggle()
		enabled = not enabled
		update()
		if callback then
			callback(enabled)
		end
	end

	update()
	button.MouseButton1Click:Connect(toggle)
	clickArea.MouseButton1Click:Connect(toggle)
end

-- Создание UI элементов
createToggle("📦 Auto Loot", true, function(v)
	autoLootEnabled = v
end)

createToggle("⚔️ Equip Best", true, function(v)
	equipBestEnabled = v
end)

-- Info с обновляемой информацией
local Info = Instance.new("TextLabel", Scroll)
Info.Size = UDim2.new(1,-10,0,120)
Info.BackgroundTransparency = 1
Info.TextColor3 = colors.textDark
Info.Font = Enum.Font.Gotham
Info.TextSize = 10
Info.TextWrapped = true
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Text = "Dark Fantasy GUI\n\n📦 Auto Loot\n⚔️ Equip Best (каждую секунду)\n🔘 Auto Prompt\n\n" .. (isMobile and "📱 Mobile Mode" or "🖥️ PC Mode")

-- Unload button
local Unload = Instance.new("TextButton", Scroll)
Unload.Size = UDim2.new(0,160,0,35)
Unload.Text = "Unload Script"
Unload.BackgroundColor3 = colors.buttonBg
Unload.TextColor3 = colors.text
Unload.Font = Enum.Font.GothamBold
Unload.TextSize = 12
Unload.BorderSizePixel = 0
Unload.AutoButtonColor = false

Instance.new("UICorner", Unload).CornerRadius = UDim.new(0,6)

Unload.MouseButton1Click:Connect(function()
	if promptConnection then
		promptConnection:Disconnect()
	end
	ScreenGui:Destroy()
end)

-- Minimize
local function toggleMinimize()
	minimized = not minimized
	
	if minimized then
		Content.Visible = false
		AccentLine.Visible = false
		
		local tween = TweenService:Create(Main, TweenInfo.new(0.2), {
			Size = UDim2.new(0,220,0,32)
		})
		tween:Play()
		MinimizeBtn.Text = "+"
	else
		Content.Visible = true
		AccentLine.Visible = true
		
		local tween = TweenService:Create(Main, TweenInfo.new(0.2), {
			Size = UDim2.new(0,520,0,420)
		})
		tween:Play()
		MinimizeBtn.Text = "—"
	end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
CloseBtn.MouseButton1Click:Connect(function()
	if promptConnection then
		promptConnection:Disconnect()
	end
	ScreenGui:Destroy()
end)

-- Drag system с улучшениями
local dragging = false
local dragStart
local startPos
local dragConnection = nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

dragConnection = UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		
		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Auto Loot Loop с оптимизацией
local lootLoopConnection = nil

lootLoopConnection = RunService.Heartbeat:Connect(function()
	if autoLootEnabled then
		local lootFolder = findLootFolder()
		if lootFolder then
			local children = lootFolder:GetChildren()
			for _, loot in pairs(children) do
				if isValidLoot(loot) then
					processLoot(loot)
					task.wait(0.1) -- Небольшая задержка между телепортациями
				end
			end
		end
	end
end)

-- Equip Best Loop с оптимизацией
local equipLoopConnection = nil

equipLoopConnection = RunService.Heartbeat:Connect(function()
	if equipBestEnabled then
		autoEquipBest()
	end
end)

-- Cleanup function
ScreenGui.AncestryChanged:Connect(function()
	if not ScreenGui.Parent then
		if promptConnection then promptConnection:Disconnect() end
		if lootLoopConnection then lootLoopConnection:Disconnect() end
		if equipLoopConnection then equipLoopConnection:Disconnect() end
		if dragConnection then dragConnection:Disconnect() end
	end
end)

-- Анимация появления
Main.Position = UDim2.new(0.5,-260,0.8,0)

local appearTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
	Position = UDim2.new(0.5,-260,0.5,-210)
})
appearTween:Play()

print("Dark Fantasy GUI Loaded Successfully!")
