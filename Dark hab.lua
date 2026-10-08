local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()





local Window = MacLib:Window({
    Title = "My Hub",
    Subtitle = "v1.0",
    AcrylicBlur = not game:GetService("UserInputService").TouchEnabled,
})

local Tab = Window:TabGroup():Tab({ Name = "Main" })
local Section = Tab:Section({ Side = "Left" })

Section:Button({
    Name = "Привет",
    Callback = function()
        Window:Notify({ Title = "My Hub", Description = "Работает!" })
    end,
})

Tab:Select()
