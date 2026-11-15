-- 1. Загрузка библиотеки (loadstring с маленькой буквы)
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- 2. Создание главного окна
local Window = UI:Window({
    Title = "Benzin Hub",
    Subtitle = "v1.0 | Universal",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1, -- 1 = перетаскивание за шапку, 2 = за любое место
    DisabledWindowControls = {},
    ShowUserInfo = true, -- показывать профиль игрока внизу
    Keybind = Enum.KeyCode.RightControl, -- кнопка скрытия/открытия меню
    AcrylicBlur = true
})

-- 3. Группа вкладок и сами вкладки
local TabGroup = Window:TabGroup()

local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://10723407389" -- ID иконки
})

local VisualsTab = TabGroup:Tab({
    Name = "Visuals",
    Image = "rbxassetid://10723346959"
})

-- 4. Секции внутри вкладки (Левая и Правая колонки)
local LeftSection = MainTab:Section({ Side = "Left" })
local RightSection = MainTab:Section({ Side = "Right" })

-- ================= ВСЕ ЭЛЕМЕНТЫ В ЛЕВОЙ СЕКЦИИ =================

-- Заголовок секции
LeftSection:Header({
    Name = "Основные функции"
})

-- Кнопка (Button)
LeftSection:Button({
    Name = "Обычная кнопка",
    Callback = function()
        print("Кнопка нажата!")
        Window:Notify({
            Title = "Уведомление",
            Description = "Кнопка успешно сработала",
            Lifetime = 4
        })
    end
})

-- Переключатель (Toggle)
local MyToggle = LeftSection:Toggle({
    Name = "Включить функцию",
    Default = false,
    Callback = function(State)
        print("Состояние Toggle:", State)
    end
}, "ToggleFlag") -- Второй аргумент: уникальный флаг для сохранения конфига

-- Слайдер (Slider)
local MySlider = LeftSection:Slider({
    Name = "Скорость / Значение",
    Default = 50,
    Minimum = 0,
    Maximum = 100,
    DisplayMethod = "Percent", -- Варианты: "Percent", "Value", "Round"
    Callback = function(Value)
        print("Значение слайдера:", Value)
    end
}, "SliderFlag")

-- Текстовое поле (Input)
LeftSection:Input({
    Name = "Ввод текста",
    Placeholder = "Введите текст...",
    AcceptedCharacters = "All", -- Варианты: "All", "Numeric", "Alphabetic"
    Callback = function(Text)
        print("Введено:", Text)
    end
}, "InputFlag")

-- ================= ВСЕ ЭЛЕМЕНТЫ В ПРАВОЙ СЕКЦИИ =================

RightSection:Header({
    Name = "Дополнительно и настройки"
})

-- Выпадающий список (Dropdown)
local MyDropdown = RightSection:Dropdown({
    Name = "Выбор режима",
    Search = true, -- строка поиска внутри списка
    Multi = false, -- true = можно выбрать несколько вариантов
    Required = false,
    Options = { "Вариант 1", "Вариант 2", "Вариант 3" },
    Default = 1,
    Callback = function(Selected)
        print("Выбрано:", Selected)
    end
}, "DropdownFlag")

-- Бинд клавиши (Keybind)
local MyKeybind = RightSection:Keybind({
    Name = "Бинд на действие",
    Default = Enum.KeyCode.E,
    Blacklist = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D },
    Callback = function(BindedKey)
        print("Нажата забиндженная клавиша!")
    end,
    onBinded = function(NewKey)
        print("Назначена новая клавиша:", NewKey.Name)
    end
}, "KeybindFlag")

-- Палитра цветов (Colorpicker)
local MyColorpicker = RightSection:Colorpicker({
    Name = "Цвет подсветки",
    Default = Color3.fromRGB(0, 170, 255),
    Alpha = 0, -- прозрачность (от 0 до 1)
    Callback = function(Color, Alpha)
        print("Новый цвет:", Color, "Прозрачность:", Alpha)
    end
}, "ColorpickerFlag")

-- Разделитель
RightSection:Divider()

-- Текстовый блок (Paragraph) и обычная надпись (Label)
RightSection:Paragraph({
    Header = "Информация",
    Body = "Здесь можно разместить описание скрипта или подсказку для пользователя."
})

RightSection:Label({
    Text = "Простая текстовая строка (Label)"
})

-- 5. Активация первой вкладки при запуске
MainTab:Select()
w
