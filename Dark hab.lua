local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()

local Window = Library:Window({
    Name = "SALAD",
    SubTitle = "IN CASE OF EMERGENCY"
})

local Combat = Window:Page({Name = "Combat"})
local Visuals = Window:Page({Name = "Visuals"})

local Aim = Combat:Section({Name = "Aimbot", Side = 1})
Aim:Toggle({Name = "Enabled", Flag = "AimbotEnabled", Default = true, Callback = print})
Aim:Slider({Name = "Smoothness", Flag = "AimSmooth", Min = 1, Max = 20, Default = 5})
Aim:Keybind({Name = "Aim Key", Flag = "AimKey", Default = Enum.KeyCode.E})

local Visual = Visuals:Section({Name = "ESP", Side = 1})
Visual:Textbox({Name = "Name", Flag = "EspName", Placeholder = "Type here..."})
Visual:MultiDropdown({Name = "Targets", Flag = "EspTargets", Items = {"Head", "Torso", "Legs"}})
Visual:Dropdown({Name = "Mode", Flag = "EspMode", Items = {"Box", "Name", "Distance"}, Default = "Box"})

Library:Watermark({Title = "SALAD UI"})
Library:AddTooltip(Visual.Items["Section"], "This is the ESP section")
Library:CreateSettingsPage(Window)
