-- ============================================================
--  QUICK START TEMPLATE (расширенный)
-- ============================================================

local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

-- ─── 1. Создание окна ───────────────────────────────────────
local Window = MacLib:Window({
    Title = "My Hub",
    Subtitle = "v1.0 • by you",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,                              -- 1 = за иконку, 2 = за всё окно
    DisabledWindowControls = {},                -- {"Exit"} или {"Minimize"}
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = not game:GetService("UserInputService").TouchEnabled,
})

-- ─── 2. Глобальные настройки (шестерёнка) ──────────────────
Window:GlobalSetting({
    Name = "UI Blur",
    Default = Window:GetAcrylicBlurState(),
    Callback = function(state)
        Window:SetAcrylicBlurState(state)
        Window:Notify({
            Title = "Settings",
            Description = (state and "Enabled" or "Disabled") .. " UI Blur",
            Lifetime = 3,
        })
    end,
})

Window:GlobalSetting({
    Name = "Notifications",
    Default = true,
    Callback = function(state)
        Window:SetNotificationsState(state)
    end,
})

-- ─── 3. Переменные состояний ───────────────────────────────
local State = {
    espEnabled   = false,
    espColor     = Color3.fromRGB(0, 255, 255),
    espFillAlpha = 0.3,
    aimbot       = false,
    aimFov       = 90,
    aimSmooth    = 5,
    aimKey       = Enum.KeyCode.E,
    teamCheck    = true,
    walkSpeed    = 16,
    jumpPower    = 50,
    speedToggle  = false,
    nameTag      = false,
    selectedMode = "Default",
    targets      = {},
}

-- ─── 4. Вкладки ─────────────────────────────────────────────
local TabGroup = Window:TabGroup()

local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://18821914323",
})

local VisualTab = TabGroup:Tab({
    Name = "Visuals",
    Image = "rbxassetid://18821914323",
})

local MiscTab = TabGroup:Tab({
    Name = "Misc",
    Image = "rbxassetid://18821914323",
})

-- ─── 5. Секции (левая и правая колонки на каждой вкладке) ──
local MainL = MainTab:Section({ Side = "Left"  })
local MainR = MainTab:Section({ Side = "Right" })

local VisL  = VisualTab:Section({ Side = "Left"  })
local VisR  = VisualTab:Section({ Side = "Right" })

local MiscL = MiscTab:Section({ Side = "Left"  })
local MiscR = MiscTab:Section({ Side = "Right" })

-- ============================================================
--  MAIN TAB
-- ============================================================

MainL:Header({ Name = "Combat" })

MainL:Toggle({
    Name = "Aimbot",
    Default = State.aimbot,
    Callback = function(v)
        State.aimbot = v
        print("[Aimbot] ->", v)
        Window:Notify({
            Title = "Aimbot",
            Description = v and "Enabled" or "Disabled",
            Lifetime = 2,
        })
    end,
})

MainL:Slider({
    Name = "FOV",
    Default = State.aimFov,
    Minimum = 0,
    Maximum = 360,
    DisplayMethod = "Value",
    Callback = function(v)
        State.aimFov = v
    end,
})

MainL:Slider({
    Name = "Smoothness",
    Default = State.aimSmooth,
    Minimum = 1,
    Maximum = 30,
    DisplayMethod = "Value",
    Callback = function(v)
        State.aimSmooth = v
    end,
})

MainL:Keybind({
    Name = "Aim Key",
    Default = State.aimKey,
    Callback = function(key)
        print("Aim key pressed:", key.Name)
    end,
    onBinded = function(key)
        State.aimKey = key
        Window:Notify({
            Title = "Keybind",
            Description = "Aim bound to " .. key.Name,
            Lifetime = 2,
        })
    end,
})

MainL:Divider()

MainL:Header({ Name = "Movement" })

MainR:Toggle({
    Name = "Speed Hack",
    Default = State.speedToggle,
    Callback = function(v)
        State.speedToggle = v
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v and State.walkSpeed or 16
            end
        end
    end,
})

MainR:Slider({
    Name = "Walk Speed",
    Default = State.walkSpeed,
    Minimum = 16,
    Maximum = 200,
    DisplayMethod = "Value",
    Callback = function(v)
        State.walkSpeed = v
        if State.speedToggle then
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end,
})

MainR:Slider({
    Name = "Jump Power",
    Default = State.jumpPower,
    Minimum = 50,
    Maximum = 500,
    DisplayMethod = "Value",
    Callback = function(v)
        State.jumpPower = v
    end,
})

MainR:Button({
    Name = "Reset Character",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
        Window:Notify({ Title = "Character", Description = "Reset!", Lifetime = 2 })
    end,
})

-- ============================================================
--  VISUALS TAB
-- ============================================================

VisL:Header({ Name = "ESP" })

VisL:Toggle({
    Name = "Enable ESP",
    Default = State.espEnabled,
    Callback = function(v)
        State.espEnabled = v
        print("[ESP] ->", v)
    end,
})

VisL:Colorpicker({
    Name = "ESP Color",
    Default = State.espColor,
    Callback = function(color)
        State.espColor = color
    end,
})

VisL:Colorpicker({
    Name = "Fill Color",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = State.espFillAlpha,
    Callback = function(color, alpha)
        State.espFillAlpha = alpha
    end,
})

VisL:Toggle({
    Name = "Name Tags",
    Default = State.nameTag,
    Callback = function(v)
        State.nameTag = v
    end,
})

VisL:Dropdown({
    Name = "Box Style",
    Options = { "Full", "Corner", "Circle", "3D" },
    Default = 1,
    Callback = function(v)
        State.selectedMode = v
        print("Box style:", v)
    end,
})

VisR:Header({ Name = "Targets" })

VisR:Dropdown({
    Name = "Select Players",
    Multi = true,
    Search = true,
    Options = (function()
        local t = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            table.insert(t, p.Name)
        end
        return t
    end)(),
    Callback = function(selected)
        State.targets = selected
    end,
})

VisR:Button({
    Name = "Refresh Player List",
    Callback = function()
        Window:Notify({
            Title = "Targets",
            Description = "Player list refreshed",
            Lifetime = 2,
        })
    end,
})

VisR:Paragraph({
    Header = "Info",
    Body = "ESP and Aimbot are client-side only. Use only on games you own or have permission for.",
})

-- ============================================================
--  MISC TAB
-- ============================================================

MiscL:Header({ Name = "Utility" })

MiscL:Input({
    Name = "Custom Chat",
    Placeholder = "Введите сообщение...",
    AcceptedCharacters = "All",
    Callback = function(text)
        print("[Chat] ->", text)
    end,
    onChanged = function(text)
        -- вызывается на каждый ввод символа
    end,
})

MiscL:Button({
    Name = "Send Chat",
    Callback = function()
        Window:Notify({ Title = "Chat", Description = "Message sent!", Lifetime = 2 })
    end,
})

MiscL:Divider()

MiscL:Header({ Name = "Teleport" })

MiscL:Input({
    Name = "X",
    Placeholder = "0",
    AcceptedCharacters = "Numeric",
    Callback = function(v) print("X:", v) end,
})

MiscL:Input({
    Name = "Y",
    Placeholder = "0",
    AcceptedCharacters = "Numeric",
    Callback = function(v) print("Y:", v) end,
})

MiscL:Input({
    Name = "Z",
    Placeholder = "0",
    AcceptedCharacters = "Numeric",
    Callback = function(v) print("Z:", v) end,
})

MiscR:Header({ Name = "Server" })

MiscR:Button({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})

MiscR:Button({
    Name = "Server Hop",
    Callback = function()
        Window:Notify({ Title = "Server", Description = "Server hopping...", Lifetime = 3 })
        -- твой server hop код
    end,
})

MiscR:Button({
    Name = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Window:Notify({ Title = "Server", Description = "Job ID copied", Lifetime = 2 })
        end
    end,
})

MiscR:Divider()

MiscR:Header({ Name = "Danger" })

MiscR:Button({
    Name = "Unload Script",
    Callback = function()
        Window:Unload()
    end,
})

-- ============================================================
--  ДИАЛОГ-ПРИМЕР
-- ============================================================
MiscR:Button({
    Name = "Confirm Action",
    Callback = function()
        Window:Dialog({
            Title = "Are you sure?",
            Description = "This action cannot be undone.",
            Buttons = {
                {
                    Name = "Yes",
                    Callback = function()
                        Window:Notify({ Title = "Done", Description = "Action confirmed", Lifetime = 2 })
                    end,
                },
                { Name = "Cancel" },
            },
        })
    end,
})

-- ============================================================
--  ПРИВЕТСТВИЕ ПРИ СТАРТЕ
-- ============================================================
task.spawn(function()
    task.wait(1)
    Window:Notify({
        Title = "My Hub",
        Description = "Loaded successfully! Press RightControl to toggle.",
        Lifetime = 5,
        Style = "Confirm",
    })
end)

-- Выбираем первую вкладку активной
MainTab:Select()

print("[My Hub] Script initialized.")
