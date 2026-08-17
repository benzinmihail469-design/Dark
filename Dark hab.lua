-- Создаем библиотеку
local Library = loadstring(game:HttpGet("ваша_ссылка"))()
local Window = Library:Window({
    Name = "My Cheat",
    SubName = "v1.0",
    Logo = "91508433366374"
})

-- Главная страница
local MainPage = Window:Page({
    Name = "Main",
    Icon = "100050851789190"
})

-- Секция настроек
local MainSection = MainPage:Section({
    Name = "Settings",
    Description = "Main settings",
    Side = 1
})

-- Toggle
MainSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnable",
    Default = false,
    Callback = function(val)
        _G.AimbotEnabled = val
    end
})

-- Slider
MainSection:Slider({
    Name = "Aimbot FOV",
    Flag = "AimbotFOV",
    Min = 0,
    Max = 360,
    Default = 90,
    Suffix = "°",
    Callback = function(val)
        _G.AimbotFOV = val
    end
})

-- Dropdown
MainSection:Dropdown({
    Name = "Target Part",
    Flag = "TargetPart",
    Items = {"Head", "Body", "Legs"},
    Default = "Head",
    Callback = function(val)
        _G.AimbotTarget = val
    end
})

-- Keybind
MainSection:Keybind({
    Name = "Aimbot Key",
    Flag = "AimbotKey",
    Default = Enum.KeyCode.LeftShift,
    Callback = function(val)
        print("Key changed:", val)
    end
})

-- Button
MainSection:Button({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

-- ============================================
-- ИСПОЛЬЗОВАНИЕ ФЛАГОВ В КОДЕ
-- ============================================

-- Получить значение флага
local espEnabled = Library.Flags["ESPToggle"]
local speedValue = Library.Flags["SpeedValue"]
local targetPart = Library.Flags["TargetPart"]

-- Установить значение флага программно
Library.SetFlags["ESPToggle"](true)
Library.SetFlags["SpeedValue"](75)

-- ============================================
-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================

-- Уведомления
Library:Notification({
    Title = "Готово!",
    Description = "Чит загружен успешно",
    Icon = "121760666525660",
    Duration = 3
})

-- Конфигурации (сохранение настроек)
-- Создать конфиг
local configData = Library:GetConfig()
writefile("config.json", configData)

-- Загрузить конфиг
local loadedConfig = readfile("config.json")
Library:LoadConfig(loadedConfig)

-- Ключи для Keybind
-- Enum.KeyCode.LeftShift
-- Enum.KeyCode.RightShift
-- Enum.KeyCode.LeftControl
-- Enum.KeyCode.RightControl
-- Enum.KeyCode.LeftAlt
-- Enum.KeyCode.RightAlt
-- Enum.KeyCode.Z
-- Enum.KeyCode.X
-- Enum.KeyCode.C
-- Enum.KeyCode.V
-- Enum.KeyCode.B
-- Enum.KeyCode.N
-- Enum.KeyCode.M
-- Enum.KeyCode.F
-- Enum.KeyCode.G
-- Enum.KeyCode.H
-- Enum.KeyCode.J
-- Enum.KeyCode.K
-- Enum.KeyCode.L
-- Enum.KeyCode.Q
-- Enum.KeyCode.E
-- Enum.KeyCode.R
-- Enum.KeyCode.T
-- Enum.KeyCode.Y
-- Enum.KeyCode.U
-- Enum.KeyCode.I
-- Enum.KeyCode.O
-- Enum.KeyCode.P
-- Enum.KeyCode.A
-- Enum.KeyCode.S
-- Enum.KeyCode.D
-- Enum.KeyCode.W
-- Enum.KeyCode.Insert
-- Enum.KeyCode.Home
-- Enum.KeyCode.PageUp
-- Enum.KeyCode.Delete
-- Enum.KeyCode.End
-- Enum.KeyCode.PageDown
-- Enum.KeyCode.F1
-- Enum.KeyCode.F2
-- Enum.KeyCode.F3
-- Enum.KeyCode.F4
-- Enum.KeyCode.F5
-- Enum.KeyCode.F6
-- Enum.KeyCode.F7
-- Enum.KeyCode.F8
-- Enum.KeyCode.F9
-- Enum.KeyCode.F10
-- Enum.KeyCode.F11
-- Enum.KeyCode.F12
