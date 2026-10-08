local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

local Window = MacLib:Window({
    Title = "My Hub",
    Subtitle = "v1.0",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = not game:GetService("UserInputService").TouchEnabled,
})

local TabGroup = Window:TabGroup()
local Tab      = TabGroup:Tab({ Name = "Main" })
local Left     = Tab:Section({ Side = "Left"  })
local Right    = Tab:Section({ Side = "Right" })

Left:Header({ Name = "Combat" })

Left:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(v) print("Aimbot:", v) end,
})

Left:Slider({
    Name = "FOV",
    Default = 90, Minimum = 0, Maximum = 360,
    DisplayMethod = "Value",
    Callback = function(v) print("FOV:", v) end,
})

Left:Button({
    Name = "Click Me",
    Callback = function()
        Window:Notify({
            Title = "My Hub",
            Description = "Работает!",
            Lifetime = 3,
        })
    end,
})

Right:Header({ Name = "Visuals" })

Right:Toggle({
    Name = "ESP",
    Default = false,
    Callback = function(v) print("ESP:", v) end,
})

Right:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(c) print(c) end,
})

Right:Dropdown({
    Name = "Box Style",
    Options = { "Full", "Corner", "Circle" },
    Default = 1,
    Callback = function(v) print(v) end,
})

Right:Keybind({
    Name = "Key",
    Callback = function(k) print("Pressed:", k.Name) end,
})

Tab:Select()
