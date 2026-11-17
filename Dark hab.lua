--[[
    ================================================================================
    ⚡ CYBERCORE UI — ГОТОВЫЙ ЗАГРУЗЧИК (ПОД ТВОЮ ССЫЛКУ Esp.lua)
    ================================================================================
    Ссылка библиотеки: https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua
    Работает на всех инжекторах (ПК и Телефон: Delta, Codex, Arceus X, Wave, Synapse Z)
    ================================================================================
]]

-- [1] ЗАГРУЗКА БИБЛИОТЕКИ С GITHUB
local LibraryURL = "https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"

local success, CyberCore = pcall(function()
    return loadstring(game:HttpGet(LibraryURL))()
end)

if not success or type(CyberCore) ~= "table" then
    warn("[CyberCore Loader] Ошибка загрузки библиотеки с GitHub:", tostring(CyberCore))
    return
end

-- [2] СОЗДАНИЕ ГЛАВНОГО ОКНА
local Window = CyberCore:CreateWindow({
    Name = "CYBERCORE // NEXUS",
    Subtitle = "NEURAL INTERFACE v2.4 • BENZIN",
    ToggleKey = Enum.KeyCode.RightShift
})

-- Стартовое уведомление
CyberCore:Notify({
    Title = "CyberCore Загружен",
    Content = "Все модули успешно инициализированы! Нажми RightShift или кнопку CYBERCORE сверху экрана.",
    Duration = 5,
    Type = "Success"
})

-- ============================================================================
-- ВКЛАДКА 1: COMBAT (АИМ И БОЕВЫЕ ФУНКЦИИ)
-- ============================================================================
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "combat"
})

local AimSection = CombatTab:CreateSection({
    Name = "Silent Aim & Targeting",
    Opened = true
})

AimSection:CreateToggle({
    Name = "Enable Silent Aim",
    Description = "Автоматическая наводка снарядов на ближайшую цель в радиусе FOV",
    Default = false,
    Flag = "SilentAim_Enabled",
    Callback = function(state)
        CyberCore:Notify({
            Title = "Silent Aim",
            Content = state and "Silent Aim активирован" or "Silent Aim выключен",
            Duration = 2.5,
            Type = state and "Success" or "Info"
        })
    end
})

AimSection:CreateSlider({
    Name = "FOV Radius",
    Range = {15, 360},
    Increment = 5,
    Suffix = " px",
    Default = 120,
    Flag = "SilentAim_FOV",
    Callback = function(val)
        -- Твой код изменения радиуса FOV
    end
})

AimSection:CreateSlider({
    Name = "Hit Chance",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    Default = 95,
    Flag = "SilentAim_HitChance",
    Callback = function(val)
        -- Твой код шанса попадания
    end
})

AimSection:CreateDropdown({
    Name = "Target Hitbox",
    Options = {"Head", "UpperTorso", "HumanoidRootPart", "Nearest Point"},
    Default = "Head",
    Multi = false,
    Flag = "SilentAim_Hitbox",
    Callback = function(option)
        print("[CyberCore] Выбран хитбокс:", option)
    end
})

AimSection:CreateKeybind({
    Name = "Target Lock Keybind",
    Default = Enum.KeyCode.Q,
    Flag = "TargetLock_Bind",
    Callback = function(key)
        CyberCore:Notify({
            Title = "Target Lock",
            Content = "Сработал бинд захвата цели [" .. key.Name .. "]",
            Duration = 2,
            Type = "Info"
        })
    end
})

-- ============================================================================
-- ВКЛАДКА 2: VISUALS (ESP И ПОДСВЕТКА)
-- ============================================================================
local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "visuals"
})

local EspSection = VisualsTab:CreateSection({
    Name = "Cyber ESP Overlay",
    Opened = true
})

EspSection:CreateToggle({
    Name = "Master ESP Switch",
    Description = "Отображение боксов, линий, здоровья и дистанции через стены",
    Default = true,
    Flag = "ESP_Enabled",
    Callback = function(state)
        print("[CyberCore] ESP:", state)
    end
})

EspSection:CreateDropdown({
    Name = "Active ESP Elements",
    Options = {"Corner Boxes", "2D Box", "Snaplines", "Health Bar", "Distance", "Nicknames"},
    Default = {"Corner Boxes", "Health Bar", "Distance"},
    Multi = true,
    Flag = "ESP_Elements",
    Callback = function(selectedTable)
        print("[CyberCore] Активные элементы ESP:", table.concat(selectedTable, ", "))
    end
})

EspSection:CreateColorPicker({
    Name = "Enemy ESP Color",
    Default = Color3.fromRGB(0, 240, 255),
    Flag = "ESP_EnemyColor",
    Callback = function(color)
        -- Цвет врагов
    end
})

EspSection:CreateColorPicker({
    Name = "Team ESP Color",
    Default = Color3.fromRGB(0, 255, 157),
    Flag = "ESP_TeamColor",
    Callback = function(color)
        -- Цвет союзников
    end
})

EspSection:CreateSlider({
    Name = "Max Render Distance",
    Range = {100, 5000},
    Increment = 50,
    Suffix = " studs",
    Default = 1500,
    Flag = "ESP_MaxDistance",
    Callback = function(dist)
        -- Максимальная дистанция прорисовки
    end
})

-- ============================================================================
-- ВКЛАДКА 3: PLAYER (ДВИЖЕНИЕ И ПЕРСОНАЖ)
-- ============================================================================
local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "player"
})

local MoveSection = PlayerTab:CreateSection({
    Name = "Character Movement & Physics",
    Opened = true
})

MoveSection:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = " ws",
    Default = 16,
    Flag = "Player_WalkSpeed",
    Callback = function(speed)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end
})

MoveSection:CreateSlider({
    Name = "JumpPower",
    Range = {50, 350},
    Increment = 5,
    Suffix = " jp",
    Default = 50,
    Flag = "Player_JumpPower",
    Callback = function(jp)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jp
        end
    end
})

MoveSection:CreateSlider({
    Name = "Camera FOV",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    Default = 90,
    Flag = "Player_FOV",
    Callback = function(fov)
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = fov
        end
    end
})

MoveSection:CreateButton({
    Name = "Reset Character Physics",
    Description = "Сбросить скорость, прыжок и FOV до стандартных значений",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
        CyberCore:Notify({
            Title = "Physics Reset",
            Content = "Параметры персонажа возвращены по умолчанию.",
            Duration = 3,
            Type = "Success"
        })
    end
})

-- ============================================================================
-- ВКЛАДКА 4: SETTINGS (НАСТРОЙКИ И УПРАВЛЕНИЕ UI)
-- ============================================================================
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings"
})

local InfoSection = SettingsTab:CreateSection({
    Name = "System & Configuration",
    Opened = true
})

InfoSection:CreateParagraph({
    Title = "CyberCore UI v2.4",
    Content = "Полная поддержка ПК и мобильных экранов (авто-масштабирование UIScale, плавная HSV-палитра и быстрый поиск по модулям в верхней панели)."
})

local StatusLabel = InfoSection:CreateLabel("Статус: Активен • Все системы в норме")

InfoSection:CreateDivider()

InfoSection:CreateInput({
    Name = "Название профиля",
    PlaceholderText = "Введи имя конфига...",
    Default = "benzin_main",
    RemoveTextAfterFocusLost = false,
    Flag = "Config_Name",
    Callback = function(text)
        StatusLabel:Set("Активный профиль: " .. tostring(text))
    end
})

InfoSection:CreateButton({
    Name = "Проверить уведомление",
    Description = "Отправляет тестовое кибер-уведомление в правый нижний угол",
    Callback = function()
        CyberCore:Notify({
            Title = "Синхронизация",
            Content = "Профиль [" .. tostring(CyberCore.Flags.Config_Name or "benzin_main") .. "] активен.",
            Duration = 3,
            Type = "Info"
        })
    end
})

InfoSection:CreateButton({
    Name = "Выгрузить интерфейс (Unload)",
    Description = "Отключает все соединения и полностью удаляет меню с экрана",
    Callback = function()
        CyberCore:Destroy()
    end
})
