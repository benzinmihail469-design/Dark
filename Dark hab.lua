-- 1. Загрузка библиотеки (loadstring строго с маленькой буквы)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua", true))()

-- 2. Создание главного окна
local Window = Luna:CreateWindow({
    Name = "Benzin Hub",
    Subtitle = "v1.0 | Luna UI",
    LogoID = "82795327169782", -- ID логотипа (или nil)
    LoadingEnabled = true,
    LoadingTitle = "Benzin Hub",
    LoadingSubtitle = "Загрузка интерфейса...",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "BenzinHub_Configs"
    },
    KeySystem = false -- поставь true, если нужна система ключей
})

-- 3. Создание вкладки (Tab)
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "view_in_ar",
    ImageSource = "Material", -- "Material" или "Lucide"
    ShowTitle = true
})

-- ================= ВСЕ ЭЛЕМЕНТЫ LUNA UI =================

-- Секция (разделитель с заголовком)
MainTab:CreateSection("Основные элементы")

-- Кнопка (Button)
MainTab:CreateButton({
    Name = "Обычная кнопка",
    Description = "Описание действия кнопки",
    Callback = function()
        Luna:Notification({
            Title = "Успешно",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Кнопка была нажата!"
        })
    end
})

-- Переключатель (Toggle)
local MyToggle = MainTab:CreateToggle({
    Name = "Переключатель (Toggle)",
    Description = "Включает или выключает функцию",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
}, "MainToggleFlag")

-- Слайдер (Slider)
local MySlider = MainTab:CreateSlider({
    Name = "Слайдер значения",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        print("Slider:", Value)
    end
}, "MainSliderFlag")

-- Вторая секция
MainTab:CreateSection("Выбор и ввод данных")

-- Выпадающий список (Dropdown)
local MyDropdown = MainTab:CreateDropdown({
    Name = "Выпадающий список",
    Description = "Выберите один или несколько пунктов",
    Options = {"Вариант 1", "Вариант 2", "Вариант 3"},
    CurrentOption = {"Вариант 1"},
    MultipleOptions = false, -- true для мультивыбора
    SpecialType = nil, -- можно указать "Player" для списка игроков
    Callback = function(Options)
        print("Выбрано:", Options)
    end
}, "MainDropdownFlag")

-- Бинд клавиши (Keybind)
local MyBind = MainTab:CreateBind({
    Name = "Бинд клавиши",
    Description = "Нажмите для назначения клавиши",
    CurrentBind = "Q",
    HoldToInteract = false, -- true = работает только при удержании
    Callback = function(BindState)
        print("Бинд сработал! Состояние:", BindState)
    end,
    OnChangedCallback = function(NewBind)
        print("Новая клавиша:", NewBind)
    end
}, "MainBindFlag")

-- Палитра цветов (ColorPicker)
local MyColorPicker = MainTab:CreateColorPicker({
    Name = "Выбор цвета",
    Color = Color3.fromRGB(0, 170, 255),
    Flag = "MainColorFlag",
    Callback = function(Value)
        print("Новый цвет:", Value)
    end
}, "MainColorFlag")

-- Текстовое поле (Input)
local MyInput = MainTab:CreateInput({
    Name = "Поле ввода",
    Description = "Введите текст или число",
    PlaceholderText = "Введите сюда...",
    CurrentValue = "",
    Numeric = false, -- true = только цифры
    MaxCharacters = nil,
    Enter = false, -- true = срабатывает только после нажатия Enter
    Callback = function(Text)
        print("Введённый текст:", Text)
    end
}, "MainInputFlag")

-- Третья секция (Информационные блоки)
MainTab:CreateSection("Текст и уведомления")

-- Обычная строка (Label): Style 1 = обычный, 2 = инфо, 3 = предупреждение
MainTab:CreateLabel({
    Text = "Информационная строка (Label)",
    Style = 2
})

-- Абзац (Paragraph)
MainTab:CreateParagraph({
    Title = "Заголовок параграфа",
    Text = "Здесь можно написать подробную инструкцию или описание функций скрипта."
})

-- Разделительная линия
MainTab:CreateDivider()

-- 4. Автозагрузка сохранённого конфига (если есть)
Luna:LoadAutoloadConfig()
