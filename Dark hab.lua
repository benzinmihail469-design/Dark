local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

local Window = MacLib:Window({
    Title = "My Script",
    Subtitle = "v1.0",
    Size = UDim2.fromOffset(720, 480),
    DragStyle = 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = false
})

local TabGroup = Window:TabGroup()
local MainTab = TabGroup:Tab({ Name = "Main", Image = "" })

local LeftSection = MainTab:Section({ Side = "Left" })
local RightSection = MainTab:Section({ Side = "Right" })

LeftSection:Header({ Text = "ESP Settings" })

LeftSection:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
    end
})

LeftSection:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 212, 255),
    Alpha = 0,
    Callback = function(color, alpha)
        print("Color:", color, "Alpha:", alpha)
    end
})

RightSection:Slider({
    Name = "Max Distance",
    Default = 500,
    Minimum = 50,
    Maximum = 2000,
    DisplayMethod = "Value",
    Precision = 0,
    Callback = function(value)
        print("Distance:", value)
    end
})

RightSection:Keybind({
    Name = "Toggle Key",
    Default = Enum.KeyCode.E,
    Callback = function(binded)
        print("Pressed:", binded)
    end
})

MainTab:Select()
