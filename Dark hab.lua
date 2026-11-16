-- ====================================================================
-- 1. ЗАГРУЗКА ОБНОВЛЁННОЙ БИБЛИОТЕКИ
-- ====================================================================
local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

NeverLose.UnloadEnabled = true

-- ====================================================================
-- 2. ИНИЦИАЛИЗАЦИЯ МОДУЛЕЙ
-- ====================================================================
local Notifier = NeverLose:CreateNotification()
local Logger = NeverLose:CreateLogger()
local Indicators = NeverLose:CreateIndicator()

-- ====================================================================
-- 3. СОЗДАНИЕ ОКНА (Автоматически подстроится под телефон и ПК)
-- ====================================================================
local Window = NeverLose:CreateWindow({
	Name = "Neverlose",
	Content = "Mobile & PC Build",
	ConfigFolder = "NL_MobileConfigs",
	Keybind = "RightControl"
})

-- Если запущено на ПК, создадим иконку вручную (на телефоне она создастся сама)
if not Window._MenuIcon then
	local MenuIcon = NeverLose:CreateMenuIcon({
		Size = 46,
		Image = "shield-check",
		Draggable = true
	})
	MenuIcon.Root.Position = UDim2.new(0, 15, 0, 65)
	Window:AttachMenuIcon(MenuIcon)
end

Window:SetAccount({
	Username = "Benzin",
	Expires = "Lifetime"
})

-- Вотермарка в правом верхнем углу
local Watermark = Window:Watermark()
local WmMenuBlock = Watermark:AddBlock("hammer-code", "Neverlose")
local WmStatusBlock = Watermark:AddBlock("clock", "Active")

-- Тап или клик по первому блоку вотермарки открывает/закрывает меню
WmMenuBlock:Input()

-- Экранный индикатор
local TestIndicator = Indicators.new({
	Name = "ESP ACTIVE",
	Icon = "eye",
	Color = "Green"
})

-- ====================================================================
-- 4. ВКЛАДКИ И СЕКЦИИ
-- ====================================================================
Window:AddTabLabel("MAIN")

local MainTab = Window:AddTab({
	Name = "Combat",
	Icon = "crosshairs",
	Type = "Double" -- На телефоне автоматически станет 1 широкой колонкой
})

local VisualsTab = Window:AddTab({
	Name = "Visuals",
	Icon = "eye",
	Type = "Double"
})

Window:AddTabLabel("MISC")

local SettingsTab = Window:AddTab({
	Name = "Settings",
	Icon = "gear",
	Type = "Single"
})

local LeftSec = MainTab:AddSection({ Name = "MAIN FEATURES", Position = "left" })
local RightSec = MainTab:AddSection({ Name = "CONFIGURATION", Position = "right" })
local EspSec = VisualsTab:AddSection({ Name = "ESP SETTINGS", Position = "left" })

-- ====================================================================
-- 5. ТЕСТОВЫЕ ЭЛЕМЕНТЫ
-- ====================================================================
local AimRow = LeftSec:AddLabel("Enable Aimbot"):ToolTip("Автоматическое наведение")

AimRow:AddColorPicker({
	Default = Color3.fromRGB(78, 127, 252),
	Flag = "Aim_Color",
	Callback = function(color)
		print("Цвет:", color)
	end
})

local SubMenu = AimRow:AddOption(1)
SubMenu:AddLabel("Silent Mode"):AddToggle({
	Default = true,
	Flag = "Silent_Toggle"
})
SubMenu:AddLabel("Hit Chance"):AddSlider({
	Min = 0, Max = 100, Default = 85, Type = "%", Flag = "HitChance_Slider"
})

AimRow:AddToggle({
	Default = false,
	Flag = "Aim_Toggle",
	Callback = function(val)
		Logger.new("crosshairs", "Aimbot: " .. tostring(val), 2.5)
	end
})

LeftSec:AddLabel("FOV Radius"):AddSlider({
	Min = 10,
	Max = 360,
	Default = 120,
	Rounding = 0,
	Type = "px",
	Flag = "FOV_Slider"
})

LeftSec:AddLabel("Target Part"):AddDropdown({
	Values = {"Head", "HumanoidRootPart", "Torso"},
	Default = "Head",
	Multi = false,
	Flag = "Part_Dropdown"
})

LeftSec:AddLabel("Checks"):AddDropdown({
	Values = {"Team Check", "Wall Check", "ForceField Check"},
	Default = {"Team Check"},
	Multi = true,
	Flag = "Checks_Multi"
})

LeftSec:AddButton({
	Name = "Send Test Notification",
	Icon = "bell",
	Callback = function()
		Notifier.new({
			Title = "Neverlose",
			Content = "Уведомление работает!",
			Duration = 4
		})
	end
})

RightSec:AddLabel("Trigger Key"):AddKeybind({
	Default = "E",
	Blacklist = {"W", "A", "S", "D"},
	Flag = "Trigger_Bind"
})

RightSec:AddLabel("Watermark Text"):AddTextInput({
	Default = "Neverlose",
	Placeholder = "Введите текст...",
	Flag = "WM_Input",
	Callback = function(text)
		WmMenuBlock:SetText(text)
	end
})

EspSec:AddLabel("Show Screen Indicator"):AddToggle({
	Default = false,
	Flag = "Ind_Toggle",
	Callback = function(val)
		TestIndicator:SetRender(val)
	end
})

EspSec:AddLabel("Indicator Status"):AddDropdown({
	Values = {"Green", "Red", "White"},
	Default = "Green",
	Flag = "Ind_Color",
	Callback = function(col)
		TestIndicator:SetColor(col)
	end
})

-- ====================================================================
-- 6. ВКЛАДКА НАСТРОЕК
-- ====================================================================
local UiSec = SettingsTab:AddSection({ Name = "UI MANAGEMENT", Position = "left" })

UiSec:AddLabel("Window Size"):AddDropdown({
	Values = {"Mobile", "Small", "Default", "Large"},
	Default = "Mobile",
	Callback = function(scale)
		Window:SetSize(NeverLose.Scales[scale])
	end
})

UiSec:AddButton({
	Name = "Apply Cyberpunk Pink Theme",
	Icon = "paint-brush",
	Callback = function()
		NeverLose:AddTheme({
			Name        = "CyberPink",
			Accent      = Color3.fromRGB(255, 65, 160),
			Background  = Color3.fromRGB(14, 10, 20),
			Icon        = Color3.fromRGB(255, 130, 200),
		})
	end
})

UiSec:AddButton({
	Name = "Unload Interface",
	Icon = "trash-can",
	Callback = function()
		NeverLose:Unload()
	end
})

Notifier.new({
	Title = "Готово!",
	Content = "Меню адаптировано под мобильные устройства и ПК.",
	Duration = 4
})
a
