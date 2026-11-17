-- Загрузчик библиотеки Luna UI (обрати внимание: loadstring пишется с маленькой буквы!)
getgenv().ConfirmLuna = true
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()
​-- 1. Создание главного окна
local Window = Luna:CreateWindow({
Name = "Benzin Hub | Mobile & PC",
Subtitle = "v1.0",
LogoID = "", -- иконки вырезаны, оставляем пустым
LoadingEnabled = true,
LoadingTitle = "Benzin Interface",
LoadingSubtitle = "Загрузка скрипта...",
​ConfigSettings = {
RootFolder = nil,
ConfigFolder = "BenzinHub"
},
​KeySystem = false, -- поставь true, если нужна ключ-система
KeySettings = {
Title = "Benzin Hub | Key System",
Subtitle = "Проверка ключа",
Note = "Введите ваш ключ для доступа",
SaveInRoot = false,
SaveKey = true,
Key = {"12345"},
SecondAction = {
Enabled = false,
Type = "Discord", -- "Discord" или "Link"
Parameter = "invitecode"
}
}
})
​-- 2. Создание домашней вкладки (Home Tab)
Window:CreateHomeTab({
Icon = 1,
SupportedExecutors = {"Delta", "Vega X", "Codex", "Arceus X", "Fluxus", "Xeno", "Nihon"},
DiscordInvite = "noinvitelink"
})
​-- 3. Создание основных вкладок (Tabs)
local MainTab = Window:CreateTab({
Name = "Основные",
ShowTitle = true
})
​local ExtraTab = Window:CreateTab({
Name = "Дополнительно",
ShowTitle = true
})
​local SettingsTab = Window:CreateTab({
Name = "Настройки",
ShowTitle = true
})
​-- 4. Уведомление (Notification)
Luna:Notification({
Title = "Добро пожаловать!",
Content = "Интерфейс успешно загружен и адаптирован под телефон и ПК.",
Duration = 5
})
​-- ==========================================
-- ПРИМЕРЫ ВСЕХ ЭЛЕМЕНТОВ ВНУТРИ СЕКЦИИ
-- ==========================================
local MainSection = MainTab:CreateSection("Интерактивные элементы")
​-- Разделитель (Divider)
MainSection:CreateDivider()
​-- Кнопка (Button)
local MyButton = MainSection:CreateButton({
Name = "Обычная кнопка",
Description = "Нажми, чтобы выполнить действие",
Callback = function()
print("Кнопка нажата!")
Luna:Notification({
Title = "Кнопка",
Content = "Вы нажали на кнопку!",
Duration = 3
})
end
})
​-- Переключатель (Toggle)
local MyToggle = MainSection:CreateToggle({
Name = "Переключатель (Toggle)",
Description = "Включает или выключает функцию",
CurrentValue = false,
Callback = function(Value)
print("Состояние Toggle:", Value)
end
}, "MyToggleFlag")
​-- Ползунок (Slider) — адаптирован под тач на телефоне
local MySlider = MainSection:CreateSlider({
Name = "Ползунок (Slider)",
Range = {0, 200},
Increment = 1,
CurrentValue = 50,
Callback = function(Value)
print("Значение Slider:", Value)
end
}, "MySliderFlag")
​-- Выпадающий список с одним выбором (Single Dropdown)
local SingleDropdown = MainSection:CreateDropdown({
Name = "Список (Одиночный выбор)",
Description = "Выберите один вариант из списка",
Options = {"Вариант 1", "Вариант 2", "Вариант 3", "Вариант 4"},
CurrentOption = {"Вариант 1"},
MultipleOptions = false,
SpecialType = nil,
Callback = function(Option)
print("Выбран вариант:", Option)
end
}, "SingleDropdownFlag")
​-- Выпадающий список с мульти-выбором (Multi Dropdown)
local MultiDropdown = MainSection:CreateDropdown({
Name = "Список (Мульти-выбор)",
Description = "Можно выбрать сразу несколько вариантов",
Options = {"Меч", "Лук", "Щит", "Зелье"},
CurrentOption = {"Меч", "Щит"},
MultipleOptions = true,
SpecialType = nil,
Callback = function(OptionsTable)
print("Выбраны варианты:", table.concat(OptionsTable, ", "))
end
}, "MultiDropdownFlag")
​-- Выпадающий список игроков (Player Dropdown)
local PlayerDropdown = MainSection:CreateDropdown({
Name = "Выбор игрока",
Description = "Автоматически обновляет список игроков на сервере",
Options = {},
CurrentOption = {},
MultipleOptions = false,
SpecialType = "Player",
Callback = function(PlayerName)
print("Выбран игрок:", PlayerName)
end
})
​-- ==========================================
-- ВВОД, БИНДЫ, ЦВЕТА И ТЕКСТ НА ВТОРОЙ ВКЛАДКЕ
-- ==========================================
local InputSection = ExtraTab:CreateSection("Ввод, бинды и цвета")
​-- Поле ввода текста (Input)
local MyInput = InputSection:CreateInput({
Name = "Текстовое поле (Input)",
Description = "Введите любой текст",
CurrentValue = "",
PlaceholderText = "Введите текст...",
RemoveTextAfterFocusLost = false,
Numeric = false, -- поставь true, если нужны только цифры
Enter = false,   -- если true, сработает после завершения ввода
MaxCharacters = 30,
Callback = function(Text)
print("Введённый текст:", Text)
end
}, "MyInputFlag")
​-- Бинд клавиши / Тап-бинд на телефоне (Bind)
local MyBind = InputSection:CreateBind({
Name = "Бинд (Keybind)",
Description = "На ПК — по клавише, на телефоне — тап по плашке",
CurrentBind = "Q",
HoldToInteract = false,
Callback = function(Active)
print("Бинд сработал! Состояние:", Active)
end,
OnChangedCallback = function(NewKey)
print("Новая клавиша бинда:", NewKey)
end
}, "MyBindFlag")
​-- Выбор цвета (ColorPicker) — адаптирован под тач на телефоне
local MyColorPicker = InputSection:CreateColorPicker({
Name = "Выбор цвета (ColorPicker)",
Color = Color3.fromRGB(117, 164, 206),
Callback = function(Color)
print("Выбран цвет RGB:", math.floor(Color.R * 255), math.floor(Color.G * 255), math.floor(Color.B * 255))
end
}, "MyColorPickerFlag")
​-- Секция текстовых элементов
local TextSection = ExtraTab:CreateSection("Текстовые блоки (Labels & Paragraphs)")
​-- Обычный Label (Style = 1)
local NormalLabel = TextSection:CreateLabel({
Text = "Обычная текстовая метка (Style = 1)",
Style = 1
})
​-- Информационный Label (Style = 2)
local InfoLabel = TextSection:CreateLabel({
Text = "Информационная плашка (Style = 2)",
Style = 2
})
​-- Предупреждающий Label (Style = 3)
local WarnLabel = TextSection:CreateLabel({
Text = "Предупреждение / Внимание (Style = 3)",
Style = 3
})
​-- Параграф (Paragraph)
local MyParagraph = TextSection:CreateParagraph({
Title = "Заголовок параграфа",
Text = "Здесь можно размещать длинный многострочный текст, инструкции или описание функций. Высота плашки автоматически подстраивается под размер текста."
})
​-- Пример программного изменения значений через :Set()
TextSection:CreateButton({
Name = "Обновить элементы через :Set()",
Description = "Демонстрация динамического обновления",
Callback = function()
NormalLabel:Set("Текст метки успешно обновлён!")
MyParagraph:Set({
Title = "Новый заголовок",
Text = "Текст параграфа был изменён нажатием кнопки."
})
MyToggle:Set({CurrentValue = true})
MySlider:UpdateValue(125)
end
})
​-- ==========================================
-- ВКЛАДКА НАСТРОЕК ТЕМЫ И КОНФИГОВ
-- ==========================================
SettingsTab:BuildThemeSection()
SettingsTab:BuildConfigSection()
​-- Автозагрузка конфига (если был сохранён)
Luna:LoadAutoloadConfig()
