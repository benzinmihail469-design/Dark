-- ====================================================================
-- 1. ЗАГРУЗКА БИБЛИОТЕКИ ПО ТВОЕЙ ССЫЛКЕ
-- ====================================================================
local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- Разрешаем полную выгрузку UI через кнопку в настройках
NeverLose.UnloadEnabled = true

-- ====================================================================
-- 2. ИНИЦИАЛИЗАЦИЯ МОДУЛЕЙ (Уведомления, Логи, Индикаторы, Иконка)
-- ====================================================================
local Notifier = NeverLose:CreateNotification()
local Logger = NeverLose:CreateLogger()
local Indicators = NeverLose:CreateIndicator()

-- Плавающая иконка слева по центру (удобно для телефонов и ПК)
local MenuIcon = NeverLose:CreateMenuIcon({
	Size = 48,
	Image = "shield-check",
	Draggable = true
})

-- ====================================================================
-- 3. СОЗДАНИЕ ОКНА И ВОТЕРМАРКИ
-- ====================================================================
local Window = NeverLose:CreateWindow({
	Name = "Neverlose",
	Content = "UI Test Build",
	Size = NeverLose.Scales.Default, -- Small, Mobile, Default, Large
	ConfigFolder = "NL_TestConfigs",
	Keybind = "RightControl"
})

-- Привязываем иконку к окну (добавляет ползунок размера иконки в профиль)
Window:AttachMenuIcon(MenuIcon)

-- Настройка профиля слева внизу
Window:SetAccount({
	Username = "Benzin",
	Expires = "Lifetime"
})

-- Вотермарка в правом верхнем углу
local Watermark = Window:Watermark()
local WmToggleBlock = Watermark:AddBlock("hammer-code", "Neverlose.cc")
local WmStatusBlock = Watermark:AddBlock("clock", "Active")

-- Клик по первому блоку вотермарки тоже скрывает/открывает меню
WmToggleBlock:Input()

-- Экранный индикатор
local TestIndicator = Indicators.new({
	Name = "ESP ACTIVE",
	Icon = "eye",
	Color = "Green" -- Red, Green, White
})

-- ====================================================================
-- 4. ВКЛАДКИ И СЕКЦИИ
-- ====================================================================
Window:AddTabLabel("MAIN")

local MainTab = Window:AddTab({
	Name = "Combat",
	Icon = "crosshairs",
	Type = "Double" -- 2 колонки
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
	Type = "Single" -- 1 широкая колонка
})

-- Секции во вкладке Combat
local LeftSec = MainTab:AddSection({ Name = "MAIN FEATURES", Position = "left" })
local RightSec = MainTab:AddSection({ Name = "CONFIGURATION", Position = "right" })

-- Секции во вкладке Visuals
local EspSec = VisualsTab:AddSection({ Name = "ESP SETTINGS", Position = "left" })

-- ====================================================================
-- 5. ЭЛЕМЕНТЫ УПРАВЛЕНИЯ (Тест всех виджетов)
-- ====================================================================

-- 1. Строка с Toggle + ColorPicker + Вложенное меню (шестеренка)
local AimRow = LeftSec:AddLabel("Enable Aimbot"):ToolTip("Автоматическое наведение на цель")

AimRow:AddColorPicker({
	Default = Color3.fromRGB(78, 127, 252),
	Flag = "Aim_Color",
	Callback = function(color)
		print("Новый цвет:", color)
	end
})

local SubMenu = AimRow:AddOption(1) -- 1 = иконка шестеренки
SubMenu:AddLabel("Silent Mode"):AddToggle({
	Default = true,
	Flag = "Silent_Toggle",
	Callback = function(v) print("Silent Mode:", v) end
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

-- 2. Слайдер (Slider)
LeftSec:AddLabel("FOV Radius"):AddSlider({
	Min = 10,
	Max = 360,
	Default = 120,
	Rounding = 0,
	Type = "px",
	Flag = "FOV_Slider",
	Callback = function(val)
		print("FOV:", val)
	end
})

-- 3. Одиночный Dropdown
LeftSec:AddLabel("Target Part"):AddDropdown({
	Values = {"Head", "HumanoidRootPart", "Torso"},
	Default = "Head",
	Multi = false,
	Flag = "Part_Dropdown",
	Callback = function(val)
		print("Выбрана часть:", val)
	end
})

-- 4. Множественный Dropdown (Multi)
LeftSec:AddLabel("Checks"):AddDropdown({
	Values = {"Team Check", "Wall Check", "ForceField Check"},
	Default = {"Team Check"},
	Multi = true,
	Flag = "Checks_Multi",
	Callback = function(tbl)
		for k, v in next, tbl do
			print(k, v)
		end
	end
})

-- 5. Кнопка (Button)
LeftSec:AddButton({
	Name = "Send Test Notification",
	Icon = "bell",
	ToolTip = "Проверка всплывающих уведомлений",
	Callback = function()
		Notifier.new({
			Title = "Neverlose",
			Content = "Уведомление успешно доставлено!",
			Duration = 4
		})
	end
})

-- --- Правая колонка ---

-- 6. Бинд клавиши (Keybind)
RightSec:AddLabel("Trigger Key"):AddKeybind({
	Default = "E",
	Blacklist = {"W", "A", "S", "D"},
	Flag = "Trigger_Bind",
	Callback = function(key)
		Logger.new("key", "Бинд изменен на: " .. tostring(key), 2.5)
	end
})

-- 7. Текстовый ввод (TextInput)
RightSec:AddLabel("Watermark Text"):AddTextInput({
	Default = "Neverlose.cc",
	Placeholder = "Введите текст...",
	Numeric = false,
	Flag = "WM_Input",
	Callback = function(text)
		WmToggleBlock:SetText(text)
	end
})

-- --- Вкладка Visuals (Индикаторы и цвета) ---

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
-- 6. ВКЛАДКА SETTINGS (Масштаб, Темы, Выгрузка)
-- ====================================================================
local UiSec = SettingsTab:AddSection({ Name = "UI MANAGEMENT", Position = "left" })

UiSec:AddLabel("Window Size"):AddDropdown({
	Values = {"Small", "Mobile", "Default", "Large"},
	Default = "Default",
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

-- Уведомление об успешном запуске
Notifier.new({
	Title = "Библиотека загружена!",
	Content = "Используй иконку щита слева или RightControl для скрытия.",
	Duration = 5
})
