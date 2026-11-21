--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/BugBuster3000/sametlibs/refs/heads/main/Neverlose%20Reloaded/Source"))()

local Window = Library:Window({
    Name = "Neverlose",
    SubName = "Roblox",
    Logo = "119425601173954",
    TimeLeft = "Premium"
})

Window:Group("Main")
local MainPage = Window:Page({ Name = "Main", Icon = "104155143774171" })
local VisualsPage = Window:Page({ Name = "Visuals", Icon = "119425601173954" })

local CombatSub = MainPage:SubPage({ Name = "Combat", Icon = "98488959537895" })
local PlayerSub = MainPage:SubPage({ Name = "Player", Icon = "104155143774171" })

local CombatLeft = CombatSub:Section({ Name = "Aimbot", Side = 1 })
local CombatRight = CombatSub:Section({ Name = "Weapon Mods", Side = 2 })

CombatLeft.IsFirstElement = true

local AimbotToggle = CombatLeft:Toggle({
    Name = "Enable Aimbot",
    Flag = "Aimbot_Enabled",
    Default = false,
    Callback = function(state)
        print("Aimbot Enabled:", state)
    end
})

AimbotToggle:Colorpicker({
    Name = "FOV Color",
    Flag = "Aimbot_FOVColor",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 0.5,
    Callback = function(color, alpha)
        print("Aimbot Color:", color, "Alpha:", alpha)
    end
})

CombatLeft:Slider({
    Name = "FOV Radius",
    Flag = "Aimbot_FOV",
    Min = 10,
    Max = 500,
    Default = 120,
    Suffix = "°",
    Decimals = 1,
    Callback = function(val)
        print("FOV:", val)
    end
})

CombatLeft:TextSlider({
    Name = "Aim Smoothness",
    Flag = "Aimbot_Smoothness",
    Min = 1,
    Max = 3,
    Default = 2,
    Decimals = 1,
    TextProps = {
        [1] = "Slow",
        [2] = "Medium",
        [3] = "Fast"
    },
    Callback = function(val)
        print("Smoothness:", val)
    end
})

CombatLeft.IsLastElement = true
CombatLeft:RangedSlider({
    Name = "Target Distance",
    Flag = "Aimbot_Distance",
    Min = 0,
    Max = 1000,
    Default = { Min = 10, Max = 250 },
    Suffix = " studs",
    Decimals = 1,
    Callback = function(val)
        print("Min Distance:", val.Min, "Max Distance:", val.Max)
    end
})

CombatRight.IsFirstElement = true

CombatRight:Dropdown({
    Name = "Hit Part",
    Flag = "Aimbot_HitPart",
    Items = { "Head", "Torso", "Left Arm", "Right Arm", "Legs" },
    Default = "Head",
    Multi = false,
    Callback = function(val)
        print("Selected Part:", val)
    end
})

CombatRight:Dropdown({
    Name = "Weapon Mods",
    Flag = "Weapon_Mods",
    Items = { "No Recoil", "No Spread", "Fast Reload", "Infinite Ammo" },
    Default = { "No Recoil" },
    Multi = true,
    MaxSize = 120,
    Callback = function(val)
        print("Active Mods:")
        for _, mod in pairs(val) do print("-", mod) end
    end
})

CombatRight:Button({
    Name = "Reset Aimbot",
    Callback = function()
        print("Aimbot settings reset!")
        Library:Notification("Aimbot settings reset!", "107463660077553", Color3.fromRGB(0, 255, 0), 3)
    end
})

CombatRight:Label("Status: Ready")

CombatRight.IsLastElement = true
CombatRight:Textbox({
    Name = "Custom Name",
    Flag = "Player_Name",
    Placeholder = "Enter name...",
    Default = "",
    Finished = true, -- Only fires when Enter is pressed or you click away
    Callback = function(text)
        print("Textbox Value:", text)
    end
})

local PlayerSection = PlayerSub:Section({ Name = "Local Player", Side = 1 })
PlayerSection.IsFirstElement = true

local LabelWithColor = PlayerSection:Label("ESP Color")
LabelWithColor:Colorpicker({
    Flag = "Player_ESPColor",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(color)
        print("ESP Color changed to:", color)
    end
})

local AdvancedToggle = PlayerSection:Toggle({
    Name = "Advanced Fly",
    Flag = "Player_AdvFly",
    Default = false
})

local FlySettings = AdvancedToggle:Settings()

FlySettings.IsFirstElement = true
FlySettings:Slider({
    Name = "Fly Speed",
    Flag = "Fly_Speed",
    Min = 10, Max = 500, Default = 50,
    Callback = function(v) print("Fly speed:", v) end
})
FlySettings.IsFirstElement = false
FlySettings.IsLastElement = true
FlySettings:Button({
    Name = "Reset Speed",
    Callback = function() print("Speed reset!") end
})

PlayerSection.IsFirstElement = false
PlayerSection.IsLastElement = true
PlayerSection:Button({
    Name = "Kill Player (Test)",
    Callback = function()
        print("Button clicked!")
    end
})

local SettingsTab = Library:CreateSettingsPage(Window, SettingsPage, Window:Watermark(), Window:KeybindList())

Library:CheckAutoLoad(Window)
