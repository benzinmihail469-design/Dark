local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

-- Защита от дубликата GUI
if player.PlayerGui:FindFirstChild("DarkFantasy_GUI") then
	player.PlayerGui.DarkFantasy_GUI:Destroy()
end

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

-- Определение устройства
local isMobile = UserInputService.TouchEnabled

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

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = colors.stroke
Stroke.Transparency = 0.4
Stroke.Thickness = 1.5

local AccentLine = Instance.new("Frame", Main)
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = colors.accent
AccentLine.BorderSizePixel = 0

local Gradient = Instance.new("UIGradient", AccentLine)
Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 30, 180)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 180))
}

-- Заголовок
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "Dark Fantasy | Auto Loot + Equip Best"
Title.Size = UDim2.new(0, 280, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки
local MinimizeBtn = Instance.new("TextButton", Main)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.AutoButtonColor = false
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Size = UDim2.new(1, 0, 1, -32)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 32)
CollapsibleContent.BackgroundTransparency = 1

-- Tabs
local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 26)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
TabButtonsFrame.BackgroundTransparency = 0.3
TabButtonsFrame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0,2)

local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Size = UDim2.new(1, -16, 1, -32)
ContentContainer.Position = UDim2.new(0, 8, 0, 30)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10,3,15)
ContentContainer.BackgroundTransparency = 0.5
ContentContainer.BorderSizePixel = 0
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0,8)

-- Переменные
local autoLootEnabled = true
local equipBestEnabled = true
local lootFolder = nil
local childAddedConnection = nil
local TELEPORT_OFFSET = Vector3.new(0,2,0)

-- Поиск Loot
local function findLootFolder()
	local folder = workspace:FindFirstChild("Loot")
	if not folder then folder = workspace:FindFirstChild("loot") end

	if not folder then
		for _, child in pairs(workspace:GetChildren()) do
			if child:FindFirstChild("Loot") then
				folder = child.Loot
				break
			end
		end
	end

	return folder
end

-- Телепорт
local function teleportToPart(part)
	if not autoLootEnabled then return end

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	root.CFrame = CFrame.new(part.Position + TELEPORT_OFFSET)
end

-- Лут
local function processLoot(loot)
	if not autoLootEnabled then return end

	local target = loot.PrimaryPart or loot:FindFirstChildWhichIsA("BasePart")

	if target then
		teleportToPart(target)
	end
end

local function onLootAdded(loot)
	task.wait(0.05)
	processLoot(loot)
end

-- Prompt
local function autoTriggerPrompt(prompt)
	if not autoLootEnabled then return end

	pcall(function()
		fireproximityprompt(prompt)
	end)
end

-- Equip Best
local function findEquipBestButton()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then return end

	local inventory = gui:FindFirstChild("Inventory")
	if not inventory then return end

	local content = inventory:FindFirstChild("PageInventoryContent")
	if not content then return end

	local page = content:FindFirstChild("SlimesPage")
	if not page then return end

	return page:FindFirstChild("EquipBestButton")
end

local function autoEquipBest()
	if not equipBestEnabled then return end

	local button = findEquipBestButton()

	if button and button:IsA("TextButton") and button.Visible then
		pcall(function()
			for _, connection in pairs(getconnections(button.MouseButton1Click)) do
				connection:Fire()
			end
		end)
	end
end

-- Toggle
local function createToggle(parent, name, default, callback)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1,0,0,35)
	container.BackgroundTransparency = 1

	local button = Instance.new("TextButton", container)
	button.Text = name
	button.Size = UDim2.new(1,-60,0,28)
	button.Position = UDim2.new(0,8,0,3)
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

	local enabled = default

	local function update()
		if enabled then
			toggleFrame.BackgroundColor3 = colors.toggleOn

			TweenService:Create(toggleCircle,TweenInfo.new(0.15),{
				Position = UDim2.new(1,-18,0,2)
			}):Play()
		else
			toggleFrame.BackgroundColor3 = colors.toggleOff

			TweenService:Create(toggleCircle,TweenInfo.new(0.15),{
				Position = UDim2.new(0,2,0,2)
			}):Play()
		end
	end

	update()

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()

		if callback then
			callback(enabled)
		end
	end)

	return container
end

-- Tabs
local tabs = {}
local tabButtons = {}
local tabNames = {"Main","Info","Settings"}

local function createTab(name)
	local tab = Instance.new("Frame", ContentContainer)
	tab.Size = UDim2.new(1,0,1,0)
	tab.BackgroundTransparency = 1
	tab.Visible = false

	if name == "Main" then
		local scroll = Instance.new("ScrollingFrame", tab)
		scroll.Size = UDim2.new(1,0,1,0)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 2
		scroll.CanvasSize = UDim2.new(0,0,0,0)

		local list = Instance.new("UIListLayout", scroll)
		list.Padding = UDim.new(0,6)

		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 10)
		end)

		createToggle(scroll,"📦 Auto Loot",true,function(v)
			autoLootEnabled = v
		end)

		createToggle(scroll,"⚔️ Equip Best",true,function(v)
			equipBestEnabled = v
		end)

	elseif name == "Info" then
		local txt = Instance.new("TextLabel", tab)
		txt.Size = UDim2.new(1,-20,1,-20)
		txt.Position = UDim2.new(0,10,0,10)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = colors.text
		txt.Font = Enum.Font.Gotham
		txt.TextSize = 11
		txt.TextWrapped = true
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.TextYAlignment = Enum.TextYAlignment.Top
		txt.Text =
			"Dark Fantasy GUI\n\n" ..
			"• Auto Loot\n" ..
			"• Auto Prompt\n" ..
			"• Equip Best\n\n" ..
			(isMobile and "📱 Mobile" or "🖥️ PC")

	elseif name == "Settings" then
		local unload = Instance.new("TextButton", tab)
		unload.Text = "Unload Script"
		unload.Size = UDim2.new(0,150,0,35)
		unload.Position = UDim2.new(0.5,-75,0.5,-17)
		unload.BackgroundColor3 = colors.buttonBg
		unload.TextColor3 = colors.text
		unload.Font = Enum.Font.GothamBold
		unload.TextSize = 12
		unload.BorderSizePixel = 0

		Instance.new("UICorner", unload).CornerRadius = UDim.new(0,6)

		unload.MouseButton1Click:Connect(function()
			autoLootEnabled = false
			equipBestEnabled = false

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end

			ScreenGui:Destroy()
		end)
	end

	return tab
end

local function switchTab(name)
	for tabName, tab in pairs(tabs) do
		tab.Visible = (tabName == name)
	end

	for tabName, btn in pairs(tabButtons) do
		if tabName == name then
			btn.BackgroundColor3 = colors.tabActive
			btn.TextColor3 = colors.gold
		else
			btn.BackgroundColor3 = colors.tabInactive
			btn.TextColor3 = colors.textDark
		end
	end
end

for _, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", TabButtonsFrame)
	btn.Text = name
	btn.Size = UDim2.new(0,80,1,0)
	btn.BackgroundColor3 = colors.tabInactive
	btn.TextColor3 = colors.textDark
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 9
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)

	tabs[name] = createTab(name)
	tabButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

switchTab("Main")

-- Minimize
local minimized = false

local function toggleMinimize()
	minimized = not minimized

	if minimized then
		CollapsibleContent.Visible = false
		AccentLine.Visible = false

		TweenService:Create(Main,TweenInfo.new(0.2),{
			Size = UDim2.new(0,220,0,32)
		}):Play()

		MinimizeBtn.Text = "+"
	else
		CollapsibleContent.Visible = true
		AccentLine.Visible = true

		TweenService:Create(Main,TweenInfo.new(0.2),{
			Size = UDim2.new(0,520,0,420)
		}):Play()

		MinimizeBtn.Text = "—"
	end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
	autoLootEnabled = false
	equipBestEnabled = false

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	ScreenGui:Destroy()
end)

-- Drag
local dragging = false
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Запуск
lootFolder = findLootFolder()

if lootFolder then
	childAddedConnection = lootFolder.ChildAdded:Connect(onLootAdded)

	task.spawn(function()
		while autoLootEnabled do
			for _, loot in pairs(lootFolder:GetChildren()) do
				processLoot(loot)
				task.wait(0.15)
			end

			task.wait(0.5)
		end
	end)
end

ProximityPromptService.PromptShown:Connect(autoTriggerPrompt)

task.spawn(function()
	while task.wait(2) do
		autoEquipBest()
	end
end)

-- Анимация появления
Main.Position = UDim2.new(0.5,-260,0.8,0)

TweenService:Create(Main,TweenInfo.new(0.4,Enum.EasingStyle.Quad),{
	Position = UDim2.new(0.5,-260,0.5,-210)
}):Play()

print("Dark Fantasy GUI loaded")
