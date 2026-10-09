local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

local Window = MacLib:Window({
    Title = "My Script",
    Subtitle = "v1.0",
    Keybind = Enum.KeyCode.RightControl,
})

local Tab = Window:TabGroup():Tab({ Name = "Main", Image = "rbxassetid://18821914323" })

local Sec = Tab:Section({ Name = "Main Features", Icon = "rbxassetid://18821914323", Side = "Left" })

Sec:Toggle({
    Name = "Enabled",
    Default = false,
    Callback = function(v)
        Window:Notify({ Title = "Script", Description = "Toggled: " .. tostring(v), Lifetime = 2 })
    end,
})

Tab:Select()
