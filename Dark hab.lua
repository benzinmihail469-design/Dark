local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

local Window = Library:Window({
    Name = "My Hub",
    SubTitle = "v1.0",
})

local Page = Window:Page({ Name = "Main" })
local Section = Page:Section({ Name = "Combat", Side = 1 })

Section:Button({
    Name = "Click Me",
    Callback = function()
        print("работает")
    end,
})
