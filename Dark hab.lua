local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IYMouse = LocalPlayer:GetMouse()

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MovementGUI"
ScreenGui.Parent = game:GetService("CoreGui") -- или PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0, 20, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
Title.BorderSizePixel = 0
Title.Text = "SPEED HACK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Контейнер для кнопок
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -40)
Container.Position = UDim2.new(0, 10, 0, 35)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- // ================= СТИЛИ ДЛЯ КНОПОК ================= //
local function CreateButton(Name, YPos, Callback)
    local Button = Instance.new("TextButton")
    Button.Name = Name
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Position = UDim2.new(0, 0, 0, YPos)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.BorderSizePixel = 0
    Button.Text = Name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = Container
    
    local function UpdateVisual(isActive)
        if isActive then
            Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            Button.Text = Name .. " [ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Button.Text = Name
        end
    end
    
    local Active = false
    Button.MouseButton1Click:Connect(function()
        Active = not Active
        UpdateVisual(Active)
        if Callback then Callback(Active) end
    end)
    
    return {
        UpdateVisual = UpdateVisual,
        IsActive = function() return Active end
    }
end

local function CreateSlider(Name, YPos, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = Name .. "Frame"
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.Position = UDim2.new(0, 0, 0, YPos)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = Name .. ": " .. tostring(Default)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.Parent = SliderFrame
    
    local Slider = Instance.new("TextButton")
    Slider.Name = "Slider"
    Slider.Size = UDim2.new(1, 0, 0, 25)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Slider.BorderSizePixel = 0
    Slider.Text = ""
    Slider.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    Fill.BorderSizePixel = 0
    Fill.Parent = Slider
    
    local CurrentValue = Default
    
    local function UpdateFill()
        local percent = (CurrentValue - Min) / (Max - Min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = Name .. ": " .. tostring(CurrentValue)
        if Callback then Callback(CurrentValue) end
    end
    
    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = Slider.AbsolutePosition
                local sliderSize = Slider.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                CurrentValue = math.floor(Min + (Max - Min) * relativeX + 0.5)
                UpdateFill()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    UpdateFill()
    return {GetValue = function() return CurrentValue end}
end

-- // ================= ПЕРЕМЕННЫЕ ================= //
local FlySpeed = 1
local RunSpeedValue = 24
local WalkSpeedValue = 15
local JumpPowerValue = 50

local ActiveFly = false
local ActiveSpeedBoost = false
local ActiveSpeedBoost2 = false
local ActiveJump = false
local ActiveNoclip = false

-- // ================= СОЗДАНИЕ ЭЛЕМЕНТОВ GUI ================= //
local YPosition = 0

local FlySlider = CreateSlider("Fly Speed", YPosition, 0, 10, 1, function(v) FlySpeed = v end)
YPosition += 65

local FlyToggle = CreateButton("Fly (Press F)", YPosition, function(active)
    ActiveFly = active
    task.spawn(function()
        if not FLYING and ActiveFly then
            if UserInputService.TouchEnabled then MobileFly() else NOFLY() wait() sFLY() end
        elseif FLYING and not ActiveFly then
            if UserInputService.TouchEnabled then UnMobileFly() else NOFLY() end
        end
    end)
end)
YPosition += 40

local RunSlider = CreateSlider("Run Speed", YPosition, 0, 100, 24, function(v) RunSpeedValue = v end)
YPosition += 65

local RunToggle = CreateButton("Active RunSpeed", YPosition, function(active) ActiveSpeedBoost = active end)
YPosition += 40

local WalkSlider = CreateSlider("Walk Speed", YPosition, 0, 50, 15, function(v) WalkSpeedValue = v end)
YPosition += 65

local WalkToggle = CreateButton("Active WalkSpeed", YPosition, function(active) ActiveSpeedBoost2 = active end)
YPosition += 40

local JumpSlider = CreateSlider("Jump Power", YPosition, 0, 200, 50, function(v) JumpPowerValue = v end)
YPosition += 65

local JumpToggle = CreateButton("Active JumpPower", YPosition, function(active) ActiveJump = active end)
YPosition += 40

local NoclipToggle = CreateButton("Noclip", YPosition, function(active)
    ActiveNoclip = active
    ApplyNoclip()
end)
YPosition += 40

-- Обновляем размер контейнера
Container.Size = UDim2.new(1, -20, 0, YPosition + 10)
MainFrame.Size = UDim2.new(0, 250, 0, YPosition + 50)

-- // ================= ФУНКЦИИ ПОЛЁТА ================= //
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

-- Мобильный флай
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

-- Обработчик клавиши F
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

-- // ================= NOCLIP И SPEED ================= //
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

LocalPlayer.CharacterAdded:Connect(ApplyNoclip)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    if ActiveSpeedBoost then Char:SetAttribute("RunSpeed", RunSpeedValue) end
    if ActiveSpeedBoost2 then Char:SetAttribute("WalkSpeed", WalkSpeedValue) end
    
    if ActiveJump then
        local Humanoid = Char:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = JumpPowerValue
        end
    end
end)

print("Custom Movement GUI Loaded!")
