local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/main/Esp.lua"))()

-- Теперь MacLib доступен
local Window = MacLib:Window({
    Title = "My Script",
    Subtitle = "v1.0.0",
    Size = UDim2.fromOffset(868, 650),
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
    ShowUserInfo = true,
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({
    Name = "Main",
    Image = "rbxassetid://18821914323"
})

local Section = MainTab:Section({
    Side = "Left",
    Name = "Combat",
    Icon = "rbxassetid://18821914323",
})

Section:Button({
    Name = "Test",
    Callback = function()
        Window:Notify({
            Title = "OK",
            Description = "Работает!",
            Lifetime = 3
        })
    end,
})

MainTab:Select()
