--[[
	Полный загрузчик (Loader) со всеми элементами MacLib UI (Esp.lua)
	Поддерживает ПК и мобильные экзекуторы (Delta, Arceus X, Fluxus, Synapse, Wave и др.)
]]

local REPO_URL = "https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"

-- Безопасная загрузка библиотеки через loadstring + game:HttpGet
local okFetch, sourceCode = pcall(function()
	return game:HttpGet(REPO_URL)
end)

if not okFetch or type(sourceCode) ~= "string" or #sourceCode == 0 then
	warn("[MacLib Loader] Ошибка загрузки файла по ссылке: " .. tostring(sourceCode))
	return
end

local chunk, syntaxErr = loadstring(sourceCode)
if not chunk then
	warn("[MacLib Loader] Синтаксическая ошибка в Esp.lua: " .. tostring(syntaxErr))
	return
end

local okRun, MacLib = pcall(chunk)
if not okRun or type(MacLib) ~= "table" then
	warn("[MacLib Loader] Ошибка инициализации библиотеки: " .. tostring(MacLib))
	return
end

-- ============================================================================
-- 1. СОЗДАНИЕ ГЛАВНОГО ОКНА
-- ============================================================================
local Window = MacLib:Window({
	Title = "MacLib ESP & Combat Hub",
	Subtitle = "v2.5 • Полная демонстрация всех элементов",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1, -- 1 = за иконку перемещения, 2 = за любое место окна
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true
})

-- ============================================================================
-- 2. ГЛОБАЛЬНЫЕ НАСТРОЙКИ (Иконка шестеренки в левой панели)
-- ============================================================================
Window:GlobalSetting({
	Name = "Размытие фона (Acrylic Blur)",
	Default = Window:GetAcrylicBlurState(),
	Callback = function(state)
		Window:SetAcrylicBlurState(state)
		Window:Notify({
			Title = "Глобальные настройки",
			Description = (state and "Включено" or "Выключено") .. " размытие фона",
			Lifetime = 3
		})
	end
})

Window:GlobalSetting({
	Name = "Уведомления (Notifications)",
	Default = Window:GetNotificationsState(),
	Callback = function(state)
		Window:SetNotificationsState(state)
		Window:Notify({
			Title = "Глобальные настройки",
			Description = (state and "Включены" or "Выключены") .. " уведомления",
			Lifetime = 3
		})
	end
})

Window:GlobalSetting({
	Name = "Показывать профиль игрока",
	Default = Window:GetUserInfoState(),
	Callback = function(state)
		Window:SetUserInfoState(state)
		Window:Notify({
			Title = "Глобальные настройки",
			Description = state and "Профиль отображается" or "Профиль скрыт",
			Lifetime = 3
		})
	end
})

-- ============================================================================
-- 3. ГРУППЫ ВКЛАДОК И ВКЛАДКИ (TABGROUPS & TABS)
-- ============================================================================
local MainGroup = Window:TabGroup()
local SettingsGroup = Window:TabGroup()

local CombatTab = MainGroup:Tab({
	Name = "Бой и Оружие",
	Image = "rbxassetid://18821914323"
})

local VisualsTab = MainGroup:Tab({
	Name = "Визуалы и ESP",
	Image = "rbxassetid://10734950309"
})

local MiscTab = SettingsGroup:Tab({
	Name = "Инфо и Текст",
	Image = "rbxassetid://18767849817"
})

-- ============================================================================
-- 4. ВКЛАДКА 1: БОЙ И ОРУЖИЕ (Toggles, Sliders, Keybinds, Dropdowns, Buttons)
-- ============================================================================
local AimbotSection = CombatTab:Section({
	Side = "Left",
	Name = "Настройки Аимбота",
	Icon = "rbxassetid://18821914323"
})

AimbotSection:Header({
	Text = "Основные параметры"
})

local AimToggle = AimbotSection:Toggle({
	Name = "Включить Silent Aim",
	Default = true,
	Callback = function(state)
		Window:Notify({
			Title = "Аимбот",
			Description = "Silent Aim: " .. (state and "Активен" or "Выключен"),
			Lifetime = 2
		})
	end
})

local FovSlider = AimbotSection:Slider({
	Name = "Радиус FOV",
	Default = 120,
	Minimum = 10,
	Maximum = 360,
	DisplayMethod = "Degrees", -- Доступно: Value, Percent, Degrees, Round, Tenths, Hundredths
	Callback = function(val)
		print("[Aimbot] Радиус FOV:", val)
	end
})

local SmoothSlider = AimbotSection:Slider({
	Name = "Плавность доводки",
	Default = 45,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Percent",
	Callback = function(val)
		print("[Aimbot] Плавность:", val)
	end
})

AimbotSection:Keybind({
	Name = "Клавиша захвата цели",
	Default = Enum.KeyCode.Q,
	Callback = function(bind)
		Window:Notify({
			Title = "Кейбинд сработал",
			Description = "Нажата клавиша: " .. tostring(bind.Name),
			Lifetime = 2
		})
	end,
	onBinded = function(newBind)
		Window:Notify({
			Title = "Кейбинд изменён",
			Description = "Новая клавиша: " .. tostring(newBind.Name),
			Lifetime = 3
		})
	end
})

local HitboxDropdown = AimbotSection:Dropdown({
	Name = "Часть тела для наводки (Single)",
	Multi = false,
	Required = true,
	Options = { "Голова", "Торс", "Руки", "Ноги", "Ближайшая часть" },
	Default = 1,
	Callback = function(selected)
		print("[Aimbot] Выбрана часть тела:", selected)
	end
})

local WeaponMultiDropdown = CombatTab:Section({
	Side = "Right",
	Name = "Фильтры и Управление",
	Icon = "rbxassetid://10734949856"
})

local ChecksDropdown = WeaponMultiDropdown:Dropdown({
	Name = "Проверки целей (Multi + Поиск)",
	Search = true,
	Multi = true,
	Required = false,
	Options = {
		"Проверка команды (Team Check)",
		"Проверка стен (Wall Check)",
		"Проверка здоровья (Alive Check)",
		"Игнорировать друзей",
		"Игнорировать невидимых"
	},
	Default = { "Проверка команды (Team Check)", "Проверка стен (Wall Check)" },
	Callback = function(selectedTable)
		local active = {}
		for optionName, isSelected in pairs(selectedTable) do
			if isSelected then
				table.insert(active, optionName)
			end
		end
		print("[Checks] Активные фильтры:", table.concat(active, ", "))
	end
})

WeaponMultiDropdown:Input({
	Name = "Лимит дистанции (Numeric)",
	Placeholder = "Например: 500",
	Default = "500",
	AcceptedCharacters = "Numeric", -- Доступно: All, Numeric, Alphabetic
	Callback = function(text)
		Window:Notify({
			Title = "Дистанция обновлена",
			Description = "Установлена дистанция: " .. tostring(text) .. " м",
			Lifetime = 3
		})
	end
})

WeaponMultiDropdown:Input({
	Name = "Тег конфигурации (All)",
	Placeholder = "Введите название...",
	Default = "Legit_v1",
	AcceptedCharacters = "All",
	Callback = function(text)
		print("[Config] Имя профиля:", text)
	end
})

WeaponMultiDropdown:Divider()

WeaponMultiDropdown:Button({
	Name = "Сбросить выбор дропдаунов",
	Callback = function()
		HitboxDropdown:UpdateSelection("Торс")
		ChecksDropdown:UpdateSelection({ "Проверка команды (Team Check)" })
		FovSlider:UpdateValue(90)
		Window:Notify({
			Title = "Сброс настроек",
			Description = "Параметры возвращены к базовым значениям",
			Style = "Confirm",
			Lifetime = 3
		})
	end
})

WeaponMultiDropdown:Button({
	Name = "Открыть диалоговое окно (Dialog)",
	Callback = function()
		Window:Dialog({
			Title = "Подтверждение действия",
			Description = "Ты уверен, что хочешь применить настройки боевого модуля?",
			Buttons = {
				{
					Name = "Подтвердить",
					Callback = function()
						Window:Notify({
							Title = "Диалог",
							Description = "Настройки успешно применены!",
							Style = "Confirm",
							Lifetime = 3
						})
					end
				},
				{
					Name = "Отмена",
					Callback = function()
						print("Действие отменено")
					end
				}
			}
		})
	end
})

-- ============================================================================
-- 5. ВКЛАДКА 2: ВИЗУАЛЫ И ESP (Исправленная палитра Colorpicker / Color)
-- ============================================================================
local EspLeftSection = VisualsTab:Section({
	Side = "Left",
	Name = "Палитра цветов ESP",
	Icon = "rbxassetid://10734950309"
})

EspLeftSection:Toggle({
	Name = "Боксы игроков (2D Box)",
	Default = true,
	Callback = function(state)
		print("[ESP] Боксы:", state)
	end
})

-- Обычный Colorpicker (без Alpha)
local BoxColorPicker = EspLeftSection:Colorpicker({
	Name = "Цвет боксов (Colorpicker)",
	Default = Color3.fromRGB(0, 225, 255),
	Callback = function(color)
		Window:Notify({
			Title = "Цвет боксов обновлён",
			Description = string.format("RGB: %d, %d, %d", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)),
			Lifetime = 3
		})
	end
})

-- Colorpicker с прозрачностью (Alpha)
local ChamsColorPicker = EspLeftSection:Colorpicker({
	Name = "Цвет Chams + Прозрачность (Alpha)",
	Default = Color3.fromRGB(255, 65, 110),
	Alpha = 0.25,
	Callback = function(color, alpha)
		Window:Notify({
			Title = "Chams обновлён",
			Description = string.format("RGB: %d, %d, %d | Alpha: %.2f", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255), alpha or 0),
			Lifetime = 3
		})
	end
})

-- Вызов через алиас :Color(...)
local TracerColorPicker = EspLeftSection:Color({
	Name = "Цвет линий (через алиас :Color)",
	Default = Color3.fromRGB(110, 255, 130),
	Callback = function(color)
		print("[ESP] Цвет линий:", color)
	end
})

local EspRightSection = VisualsTab:Section({
	Side = "Right",
	Name = "Динамические эффекты",
	Icon = "rbxassetid://10734974297"
})

local rainbowConnection = nil
local rainbowHue = 0

EspRightSection:Toggle({
	Name = "Радужное переливание (Rainbow)",
	Default = false,
	Callback = function(state)
		if state then
			rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
				rainbowHue = (rainbowHue + dt * 0.15) % 1
				local c = Color3.fromHSV(rainbowHue, 1, 1)
				BoxColorPicker:SetColor(c)
				ChamsColorPicker:SetColor(c)
			end)
		else
			if rainbowConnection then
				rainbowConnection:Disconnect()
				rainbowConnection = nil
			end
		end
	end
})

EspRightSection:Button({
	Name = "Установить неоново-фиолетовый цвет",
	Callback = function()
		local purple = Color3.fromRGB(175, 75, 255)
		BoxColorPicker:SetColor(purple)
		ChamsColorPicker:SetColor(purple)
		ChamsColorPicker:SetAlpha(0.15)
		TracerColorPicker:SetColor(purple)
	end
})

-- ============================================================================
-- 6. ВКЛАДКА 3: ИНФО И ТЕКСТОВЫЕ ЭЛЕМЕНТЫ (Header, Paragraph, Label, SubLabel, Divider, Spacer)
-- ============================================================================
local InfoSection = MiscTab:Section({
	Side = "Left",
	Name = "Текстовые компоненты",
	Icon = "rbxassetid://18767849817"
})

InfoSection:Header({
	Text = "Заголовок секции (Header)"
})

InfoSection:Paragraph({
	Header = "Параграф (Paragraph)",
	Body = "Это многострочный текстовый блок для описания функций, логов обновлений или инструкций по управлению меню."
})

InfoSection:Divider()

InfoSection:Label({
	Text = "Обычная текстовая метка (Label) для важной информации."
})

InfoSection:SubLabel({
	Text = "Вспомогательная подпись меньшего размера (SubLabel) для подсказок."
})

InfoSection:Spacer()

InfoSection:Button({
	Name = "Свернуть / Развернуть эту секцию",
	Callback = function()
		InfoSection:ToggleCollapse()
	end
})

local ControlSection = MiscTab:Section({
	Side = "Right",
	Name = "Управление окном",
	Icon = "rbxassetid://18767849817"
})

ControlSection:Button({
	Name = "Показать уведомление (Confirm)",
	Callback = function()
		Window:Notify({
			Title = "Проверка связи",
			Description = "Нажми на галочку справа для подтверждения.",
			Style = "Confirm",
			Lifetime = 5,
			Callback = function()
				print("Уведомление подтверждено пользователем!")
			end
		})
	end
})

ControlSection:Button({
	Name = "Выгрузить интерфейс (Unload)",
	Callback = function()
		Window:Unload()
	end
})

Window.onUnloaded(function()
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
	print("[MacLib] Интерфейс полностью выгружен и очищен!")
end)

-- Выбираем первую вкладку при старте
CombatTab:Select()s
