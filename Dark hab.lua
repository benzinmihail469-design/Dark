-- Загружаем обновленную библиотеку
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- Создаем главное окно
local Window = MacLib:Window({
    Title = "Мой Скрипт • Hub",
    Subtitle = "Версия 1.0",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

-- Создаем группу вкладок
local TabGroup = Window:TabGroup()

-- Создаем вкладку
local MainTab = TabGroup:Tab({ 
    Name = "Главная", 
    Image = "rbxassetid://18821914323" 
})

-- Создаем секцию (теперь с красивым градиентным контуром, одной иконкой и сворачиванием)
local MainSection = MainTab:Section({ 
    Side = "Left",
    Name = "Функции",
    Icon = "rbxassetid://18821914323" -- Одна корректная иконка
})

-- Добавляем кнопку
MainSection:Button({
    Name = "Кнопка",
    Callback = function()
        Window:Notify({
            Title = "Уведомление",
            Description = "Кнопка была нажата!",
            Lifetime = 3
        })
    end,
})

-- Добавляем переключатель (тоггл)
MainSection:Toggle({
    Name = "Аимбот",
    Default = false,
    Callback = function(state)
        print("Аимбот:", state)
    end,
})

-- Добавляем слайдер
MainSection:Slider({
    Name = "Скорость",
    Default = 16,
    Minimum = 16,
    Maximum = 100,
    DisplayMethod = "Value",
    Callback = function(value)
        print("Скорость изменена на:", value)
    end,
})

-- Выбираем вкладку при старте
MainTab:Select()
