local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/SourceCludeLib/refs/heads/main/NerverLoseLibEdited.lua"))()
    local Window = NEVERLOSE:AddWindow("NEVERLOSE","SSG-08",'original')

    
Window:AddTabLabel("Aimbot")
    local RageTab = Window:AddTab("Rage","crosshair")
    local LegitTab = Window:AddTab("Legit","mouse")
Window:AddTabLabel("Common")
local VisualTab = Window:AddTab("Visual","earth")

    local Main = RageTab:AddSection("MAIN","left")
    Main:AddToggle("Enabled",true,function(v)end)
    Main:AddToggle("Silent Aim",true,function(v)end)
    Main:AddToggle("Automatic Fire",true,function(v)end)
    Main:AddToggle("Penetrate Walls",true,function(v)end)
    Main:AddSlider("Field of View",1,180,180,function(v)end)

    local Selection = RageTab:AddSection("SELECTION","left")
    Selection:AddDropdown("Target",{"Highest Damage","Closest"},"Highest Damage",function(v)end)
    Selection:AddDropdown("Hitboxes",{"Head","Chest","Stomach"},"Head",function(v)end)
    Selection:AddDropdown("Multipoint",{"Head","Chest","Stomach"},"Head",function(v)end)
    Selection:AddSlider("Hit Chance",1,100,65,function(v)end)
    Selection:AddSlider("Min Damage",1,100,100,function(v)end)
    Selection:AddToggle("Auto Stop",true,function(v)end)
    Selection:AddToggle("Auto Scope",true,function(v)end)

    local Other = RageTab:AddSection("OTHER","right")
    Other:AddDropdown("History",{"Maximum","Medium","Low"},"Maximum",function(v)end)
    Other:AddToggle("Delay Shot",true,function(v)end)
    Other:AddToggle("Duck Peek Assist",false,function(v)end)
    Other:AddToggle("Quick Peek Assist",false,function(v)end)
    Other:AddDropdown("Magic Bullet",{"Off","On"},"Off",function(v)end)
    Other:AddDropdown("Rapid Fire",{"Default","Instant"},"Default",function(v)end)

    local AntiAim = RageTab:AddSection("ANTI-AIM","right")
    AntiAim:AddToggle("Enabled",false,function(v)end)
    AntiAim:AddDropdown("Pitch",{"Down","Up","Zero"},"Down",function(v)end)
    AntiAim:AddDropdown("Yaw",{"Backward","Forward","Zero"},"Backward",function(v)end)
    AntiAim:AddDropdown("Yaw Jitter",{"Disabled","Low","High"},"Disabled",function(v)end)
    AntiAim:AddToggle("Slow Walk",false,function(v)end)
    AntiAim:AddToggle("Freestanding",false,function(v)end)


