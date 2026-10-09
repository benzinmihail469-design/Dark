local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()


-- 1. Создаём окно
local Window = MacLib:Window({
	Title = "My Script",
	Subtitle = "by YourName",
	Size = UDim2.fromOffset(868, 650),
	DragStyle = 1,                -- 1 = перетаскивание за иконку, 2 = за всё окно
	ShowUserInfo = true,          -- показывать аватар/ник
	Keybind = Enum.KeyCode.RightControl, -- клавиша скрытия/показа
	AcrylicBlur = true,           -- размытие фона
	DisabledWindowControls = {},  -- {"Minimize"} чтобы отключить кнопку
})

-- 2. Глобальные настройки (шестерёнка справа сверху)
Window:GlobalSetting({
	Name = "UI Blur",
	Default = true,
	Callback = function(state)
		Window:SetAcrylicBlurState(state)
	end,
})

Window:GlobalSetting({
	Name = "Notifications",
	Default = true,
	Callback = function(state)
		Window:SetNotificationsState(state)
	end,
})

-- 3. Группа вкладок (слева в сайдбаре)
local TabGroup = Window:TabGroup()

-- 4. Вкладка
local MainTab = TabGroup:Tab({
	Name = "Main",
	Image = "rbxassetid://18821914323", -- иконка вкладки (необязательно)
})

-- 5. Секция внутри вкладки (Side = "Left" или "Right")
local Section = MainTab:Section({
	Name = "Combat",
	Icon = "rbxassetid://18821914323", -- иконка секции (необязательно)
	Side = "Left",
})
