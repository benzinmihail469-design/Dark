
-- ============================================================
--  MacLib — шаблон для скрипта
-- ============================================================

local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- ─── ОКНО ───────────────────────────────────────────────────
local Window = MacLib:Window({
    Title = "My Hub",
    Subtitle = "v1.0 • by you",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,                              -- 1 = за иконку, 2 = за всё окно
    DisabledWindowControls = {},                -- {"Exit"} или {"Minimize"} — выключить кнопку
    ShowUserInfo = true,                        -- аватар и ник в сайдбаре
    Keybind = Enum.KeyCode.RightControl,        -- клавиша показать/скрыть
    AcrylicBlur = not game:GetService("UserInputService").TouchEnabled,
})

-- ─── ГЛОБАЛЬНЫЕ НАСТРОЙКИ (шестерёнка в сайдбаре) ───────────
Window:GlobalSetting({
    Name = "UI Blur",
    Default = Window:GetAcrylicBlurState(),
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

-- ─── ВКЛАДКИ ────────────────────────────────────────────────
local TabGroup = Window:TabGroup()

local CombatTab = TabGroup:Tab({
    Name = "Combat",
    Image = "rbxassetid://18821914323",        -- иконка вкладки (опционально)
})

local VisualsTab = TabGroup:Tab({
    Name = "Visuals",
    Image = "rbxassetid://18821914323",
})

local MiscTab = TabGroup:Tab({
    Name = "Misc",
    Image = "rbxassetid://18821914323",
})

-- ─── СЕКЦИИ (левая и правая колонки) ───────────────────────
local CombatL = CombatTab:Section({ Name = "Aimbot",  Icon = "rbxassetid://18821914323", Side = "Left"  })
local CombatR = CombatTab:Section({ Name = "Trigger", Icon = "rbxassetid://18821914323", Side = "Right" })

local VisL = VisualsTab:Section({ Name = "ESP",     Icon = "rbxassetid://18821914323", Side = "Left"  })
local VisR = VisualsTab:Section({ Name = "Chams",   Icon = "rbxassetid://18821914323", Side = "Right" })

local MiscL = MiscTab:Section({ Name = "Utility",  Icon = "rbxassetid://18821914323", Side = "Left"  })
local MiscR = MiscTab:Section({ Name = "Danger",   Icon = "rbxassetid://18821914323", Side = "Right" })

-- ============================================================
--  COMBAT — левая секция
-- ============================================================
CombatL:Header({ Name = "Основное" })

CombatL:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(state)
        print("Aimbot:", state)
        Window:Notify({ Title = "Aimbot", Description = state and "Enabled" or "Disabled", Lifetime = 2 })
    end,
})

CombatL:Slider({
    Name = "FOV",
    Default = 90, Minimum = 0, Maximum = 360,
    DisplayMethod = "Value",
    Callback = function(v) print("FOV:", v) end,
})

CombatL:Slider({
    Name = "Smoothness",
    Default = 5, Minimum = 1, Maximum = 30,
    DisplayMethod = "Value",
    Callback = function(v) print("Smooth:", v) end,
})

CombatL:Keybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("Aim pressed:", key.Name)
    end,
    onBinded = function(key)
        Window:Notify({ Title = "Keybind", Description = "Aim bound to " .. key.Name, Lifetime = 2 })
    end,
})

CombatL:Divider()

CombatL:Header({ Name = "Targets" })

CombatL:Dropdown({
    Name = "Hitbox",
    Options = { "Head", "Torso", "Random" },
    Default = 1,
    Callback = function(v) print("Hitbox:", v) end,
})

-- ============================================================
--  COMBAT — правая секция
-- ============================================================
CombatR:Toggle({
    Name = "Trigger Bot",
    Default = false,
    Callback = function(state) print("Trigger:", state) end,
})

CombatR:Slider({
    Name = "Delay (ms)",
    Default = 50, Minimum = 0, Maximum = 500,
    DisplayMethod = "Value",
    Callback = function(v) print("Delay:", v) end,
})

CombatR:Toggle({
    Name = "Team Check",
    Default = true,
    Callback = function(state) print("TeamCheck:", state) end,
})

-- ============================================================
--  VISUALS — левая секция (ESP)
-- ============================================================
VisL:Header({ Name = "ESP" })

VisL:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(state) print("ESP:", state) end,
})

VisL:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(color)
        print("Color:", color)
    end,
})

VisL:Colorpicker({
    Name = "Fill (с альфой)",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 0.3,
    Callback = function(color, alpha)
        print("Color:", color, "Alpha:", alpha)
    end,
})

VisL:Dropdown({
    Name = "Box Style",
    Options = { "Full", "Corner", "Circle", "3D" },
    Default = 1,
    Callback = function(v) print("Style:", v) end,
})

-- ============================================================
--  VISUALS — правая секция (Chams)
-- ============================================================
VisR:Toggle({
    Name = "Chams",
    Default = false,
    Callback = function(state) print("Chams:", state) end,
})

VisR:Dropdown({
    Name = "Режим",
    Multi = true,
    Search = true,
    Options = { "Player", "NPC", "Dummy" },
    Default = { "Player" },
    Callback = function(tbl)
        for k in pairs(tbl) do print("Selected:", k) end
    end,
})

VisR:Input({
    Name = "Material",
    Default = "ForceField",
    Placeholder = "Введите материал...",
    AcceptedCharacters = "All",
    Callback = function(text) print("Material:", text) end,
})

-- ============================================================
--  MISC — левая секция (Utility)
-- ============================================================
MiscL:Header({ Name = "Movement" })

MiscL:Toggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = state and 50 or 16 end
    end,
})

MiscL:Slider({
    Name = "WalkSpeed",
    Default = 16, Minimum = 16, Maximum = 200,
    DisplayMethod = "Value",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

MiscL:Slider({
    Name = "JumpPower",
    Default = 50, Minimum = 50, Maximum = 500,
    DisplayMethod = "Value",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end,
})

MiscL:Button({
    Name = "Reset Character",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end,
})

-- ============================================================
--  MISC — правая секция (Danger)
-- ============================================================
MiscR:Header({ Name = "Server" })

MiscR:Button({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})

MiscR:Button({
    Name = "Copy JobId",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Window:Notify({ Title = "Server", Description = "Job ID скопирован", Lifetime = 2 })
        end
    end,
})

MiscR:Divider()

MiscR:Header({ Name = "Danger Zone" })

MiscR:Button({
    Name = "Confirm Action",
    Callback = function()
        Window:Dialog({
            Title = "Ты уверен?",
            Description = "Это действие нельзя отменить.",
            Buttons = {
                { Name = "Да", Callback = function()
                    Window:Notify({ Title = "Готово", Description = "Подтверждено!", Lifetime = 2 })
                end },
                { Name = "Отмена" },
            },
        })
    end,
})

MiscR:Button({
    Name = "Unload Script",
    Callback = function()
        Window:Unload()
    end,
})

-- ─── СТАРТОВОЕ УВЕДОМЛЕНИЕ ──────────────────────────────────
task.wait(1)
Window:Notify({
    Title = "My Hub",
    Description = "Загружено! Правый Ctrl — открыть.",
    Lifetime = 5,
    Style = "Confirm",
})

-- ─── Открываем первую вкладку ──────────────────────────────
CombatTab:Select()

print("[My Hub] Script initialized.")
