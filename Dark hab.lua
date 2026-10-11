-- 1. Подключение библиотеки
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- 2. Создание главного окна
local Window = MacLib:Window({
	Title = "Мой Скрипт • Hub",
	Subtitle = "Версия 1.0",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1, -- 1 = перетаскивание за иконку со стрелками в шапке, 2 = за любое место окна[span_0](start_span)[span_0](end_span)
	DisabledWindowControls = {}, -- Можно передать {"Exit", "Minimize"}, чтобы убрать ненужные кнопки[span_1](start_span)[span_1](end_span)
	ShowUserInfo = true, -- Отображение аватара и ника игрока внизу сайдбара[span_2](start_span)[span_2](end_span)
	Keybind = Enum.KeyCode.RightControl, -- Клавиша открытия/скрытия меню[span_3](start_span)[span_3](end_span)
	AcrylicBlur = true, -- Эффект размытия стеклянного фона[span_4](start_span)[span_4](end_span)
})

-- 3. Создание группы вкладок и вкладки
local TabGroup = Window:TabGroup() --[span_5](start_span)[span_5](end_span)

local MainTab = TabGroup:Tab({
	Name = "Главная",
	Image = "rbxassetid://18821914323" -- Иконка вкладки в левом меню[span_6](start_span)[span_6](end_span)
})

-- 4. Создание секции
local MainSection = MainTab:Section({
	Side = "Left", -- Колонка: "Left" или "Right[span_7](start_span)"[span_7](end_span)
	Name = "Функции",
	Icon = "rbxassetid://18821914323" -- Иконка секции слева от названия[span_8](start_span)[span_8](end_span)
})

-- =========================================================================
-- 5. Добавление элементов управления в секцию
-- =========================================================================

-- Кнопка (Button)
MainSection:Button({
	Name = "Выполнить действие",
	Callback = function()
		Window:Notify({
			Title = "Успешно",
			Description = "Действие выполнено!",
			Lifetime = 3
		})
	end
}) --[span_9](start_span)[span_9](end_span)

-- Переключатель (Toggle)
MainSection:Toggle({
	Name = "Аимбот",
	Default = false,
	Callback = function(state)
		print("Аимбот:", state)
	end
}) --[span_10](start_span)[span_10](end_span)

-- Ползунок (Slider)
MainSection:Slider({
	Name = "Скорость бега",
	Default = 16,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value", -- Варианты: "Value", "Percent", "Round", "Tenths", "Degrees[span_11](start_span)"[span_11](end_span)
	Callback = function(val)
		print("Текущая скорость:", val)
	end
}) --[span_12](start_span)[span_12](end_span)

-- Поле ввода текста (Input)
MainSection:Input({
	Name = "Телепорт к игроку",
	Placeholder = "Введите ник...",
	AcceptedCharacters = "All", -- "All", "Numeric", "Alphabetic[span_13](start_span)"[span_13](end_span)
	Callback = function(text)
		print("Введенный текст:", text)
	end
}) --[span_14](start_span)[span_14](end_span)

-- Бинд клавиши (Keybind)
MainSection:Keybind({
	Name = "Кнопка активации",
	Default = Enum.KeyCode.E,
	Callback = function(key)
		print("Нажата клавиша:", key.Name)
	end
}) --[span_15](start_span)[span_15](end_span)

-- Выпадающий список (Dropdown)
MainSection:Dropdown({
	Name = "Режим наводки",
	Multi = false, -- true для выбора нескольких вариантов, false для одиночного[span_16](start_span)[span_16](end_span)
	Required = true,
	Options = {"Голова", "Тело", "Случайно"},
	Default = 1,
	Callback = function(selected)
		print("Выбран режим:", selected)
	end
}) --[span_17](start_span)[span_17](end_span)

-- Палитра цветов (Colorpicker)
MainSection:Colorpicker({
	Name = "Цвет ESP",
	Default = Color3.fromRGB(0, 170, 255),
	Alpha = 0, -- Прозрачность от 0 до 1 (необязательно)[span_18](start_span)[span_18](end_span)
	Callback = function(color, alpha)
		print("Выбран цвет:", color, "Прозрачность:", alpha)
	end
}) --[span_19](start_span)[span_19](end_span)

-- Разделители и текст
MainSection:Divider() --[span_20](start_span)[span_20](end_span)

MainSection:Header({
	Text = "Дополнительно"
}) --[span_21](start_span)[span_21](end_span)

MainSection:Paragraph({
	Header = "Инфо",
	Body = "Секция поддерживает сворачивание по клику на шапку или стрелочку."
}) --[span_22](start_span)[span_22](end_span)

-- 6. Обязательный выбор вкладки при старте
MainTab:Select() --[span_23](start_span)[span_23](end_span)
