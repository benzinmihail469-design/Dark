-- // Код ниже можно вставить в любой скрипт, предварительно загрузив библиотеку Zentrix // --
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/Zentrix"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IYMouse = LocalPlayer:GetMouse()

-- // ================= НАСТРОЙКИ ================= // --
local FlySpeed = 1
local RunSpeedValue = 24
local WalkSpeedValue = 15
local JumpPowerValue = 50

local ActiveFly = false
local ActiveSpeedBoost = false
local ActiveSpeedBoost2 = false
local ActiveJump = false
local ActiveNoclip = false

-- // ================= МЕХАНИКА ПОЛЁТА (ПК) ================= // --
local FLYING = false
local QEfly = true
local flyKeyDown, flyKeyUp

local function sFLY(vfly)
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    repeat wait() until IYMouse
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    
    local T = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            repeat wait()
                if not vfly and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((Camera.CoordinateFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((Camera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - Camera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((Camera.CoordinateFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((Camera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - Camera.CoordinateFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = Camera.CoordinateFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = FlySpeed
        elseif KEY:lower() == 's' then CONTROL.B = -FlySpeed
        elseif KEY:lower() == 'a' then CONTROL.L = -FlySpeed
        elseif KEY:lower() == 'd' then CONTROL.R = FlySpeed
        elseif QEfly and KEY:lower() == 'e' then CONTROL.Q = FlySpeed * 2
        elseif QEfly and KEY:lower() == 'q' then CONTROL.E = -FlySpeed * 2
        end
        pcall(function() Camera.CameraType = Enum.CameraType.Track end)
    end)
    
    flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = 0
        elseif KEY:lower() == 's' then CONTROL.B = 0
        elseif KEY:lower() == 'a' then CONTROL.L = 0
        elseif KEY:lower() == 'd' then CONTROL.R = 0
        elseif KEY:lower() == 'e' then CONTROL.Q = 0
        elseif KEY:lower() == 'q' then CONTROL.E = 0
        end
    end)
    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
end

-- // ================= МЕХАНИКА ПОЛЁТА (МОБИЛКИ) ================= // --
local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"
local mfly1, mfly2

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        root:FindFirstChild(velocityHandlerName):Destroy()
        root:FindFirstChild(gyroHandlerName):Destroy()
        LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        mfly1:Disconnect()
        mfly2:Disconnect()
    end)
end

local function MobileFly()
    UnMobileFly()
    FLYING = true
    local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local v3inf = Vector3.new(9e9, 9e9, 9e9)
    local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = Vector3.new(0, 0, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50
    
    mfly1 = LocalPlayer.CharacterAdded:Connect(function()
        bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = Vector3.new(0, 0, 0)
        bv.Velocity = Vector3.new(0, 0, 0)
        bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
    end)
    
    mfly2 = RunService.RenderStepped:Connect(function()
        root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)
            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = Camera.CoordinateFrame
            VelocityHandler.Velocity = Vector3.new()
            
            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then VelocityHandler.Velocity += Camera.CFrame.RightVector * (direction.X * (FlySpeed * 50)) end
            if direction.X < 0 then VelocityHandler.Velocity += Camera.CFrame.RightVector * (direction.X * (FlySpeed * 50)) end
            if direction.Z > 0 then VelocityHandler.Velocity -= Camera.CFrame.LookVector * (direction.Z * (FlySpeed * 50)) end
            if direction.Z < 0 then VelocityHandler.Velocity -= Camera.CFrame.LookVector * (direction.Z * (FlySpeed * 50)) end
        end
    end)
end

-- // ================= ОБРАБОТЧИК ДЛЯ КНОПКИ F (ПК) ================= // --
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if not FLYING and ActiveFly then
            if UserInputService.TouchEnabled then MobileFly() else NOFLY() wait() sFLY() end
        elseif FLYING and ActiveFly then
            if UserInputService.TouchEnabled then UnMobileFly() else NOFLY() end
        end
    end
end)

-- // ================= ФУНКЦИИ NOCLIP / SPEED / JUMP ================= // --
local function ApplyNoclip()
    if ActiveNoclip then
        if LocalPlayer.Character then
            for _, Parts in pairs(LocalPlayer.Character:GetDescendants()) do
                if Parts:IsA("BasePart") and Parts.CanCollide then
                    if not Parts:GetAttribute("OldCollide") then Parts:SetAttribute("OldCollide", Parts.CanCollide) end
                    Parts.CanCollide = false
                end
            end
        end
    else
        if LocalPlayer.Character then
            for _, Parts in pairs(LocalPlayer.Character:GetDescendants()) do
                if Parts:IsA("BasePart") and Parts:GetAttribute("OldCollide") then
                    Parts.CanCollide = Parts:GetAttribute("OldCollide")
                end
            end
        end
    end
end

-- Автоматическое применение при изменении персонажа
LocalPlayer.CharacterAdded:Connect(ApplyNoclip)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    -- Speed Hack
    if ActiveSpeedBoost then Char:SetAttribute("RunSpeed", RunSpeedValue) end
    if ActiveSpeedBoost2 then Char:SetAttribute("WalkSpeed", WalkSpeedValue) end
    
    -- Jump Hack
    if ActiveJump then
        local Humanoid = Char:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPowerValue
        end
    end
end)

-- // ================= СОЗДАНИЕ GUI ================= // --
local Window = library:CreateWindow({
    Title = "Movement Cheats",
    Theme = "Default",
    Icon = 0,
    Intro = false,
    CustomSize = UDim2.new(0, 400, 0, 300)
}, function(window) end)

local MainTab = Window:CreateTab("Movement", 0)

-- Fly
MainTab:AddSlider({Text = "Fly Speed", Min = 0, Max = 10, Default = 1, Increment = 0.1, Callback = function(v) FlySpeed = v end})
MainTab:AddToggle({Text = "Activate Fly (Press F)", Default = false, Callback = function(v)
    ActiveFly = v
    task.spawn(function()
        if not FLYING and ActiveFly then
            if UserInputService.TouchEnabled then MobileFly() else NOFLY() wait() sFLY() end
        elseif FLYING and not ActiveFly then
            if UserInputService.TouchEnabled then UnMobileFly() else NOFLY() end
        end
    end)
end})

-- Run Speed
MainTab:AddSlider({Text = "Run Speed", Min = 0, Max = 100, Default = 24, Callback = function(v) RunSpeedValue = v end})
MainTab:AddToggle({Text = "Active Run Speed", Default = false, Callback = function(v) ActiveSpeedBoost = v end})

-- Walk Speed
MainTab:AddSlider({Text = "Walk Speed", Min = 0, Max = 50, Default = 15, Callback = function(v) WalkSpeedValue = v end})
MainTab:AddToggle({Text = "Active Walk Speed", Default = false, Callback = function(v) ActiveSpeedBoost2 = v end})

-- Jump Power
MainTab:AddSlider({Text = "Jump Power", Min = 0, Max = 200, Default = 50, Callback = function(v) JumpPowerValue = v end})
MainTab:AddToggle({Text = "Active Jump Power", Default = false, Callback = function(v) ActiveJump = v end})

-- Noclip
MainTab:AddToggle({Text = "Noclip", Default = false, Callback = function(v)
    ActiveNoclip = v
    ApplyNoclip()
end})
