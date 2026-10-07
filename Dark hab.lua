local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/benzinmihail469-design/Rararara/refs/heads/main/Esp.lua"))()



local Window = Library:Window({Name = "SALAD", SubTitle = "IN CASE OF EMERGENCY"})

-- Вкладка без SubPage
local Combat = Window:Page({Name = "Combat"})
Combat:Section({Name = "Aimbot", Side = 1}):Toggle({Name = "Enable"})
Combat:Section({Name = "Silent", Side = 2}):Toggle({Name = "Enable"})

-- Вкладка с SubPage
local Visuals = Window:Page({Name = "Visuals"})
local Players = Visuals:SubPage({Name = "Players"})
local World   = Visuals:SubPage({Name = "World"})
local Effects = Visuals:SubPage({Name = "Effects"})

Players:Section({Name = "Shaders", Side = 1}):Toggle({Name = "Fog", Default = true})
World:Section({Name = "Lighting", Side = 1}):Slider({Name = "Brightness", Min = 0, Max = 2, Default = 1})
Effects:Section({Name = "Bloom", Side = 1}):Toggle({Name = "Enabled"})
