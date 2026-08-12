Skip to content
 
Search Gists
Search...
All gists
Back to GitHub
@ffdrrdfdew-alt
ffdrrdfdew-alt/Mm2
Last active last month • Report abuse
Code
Revisions
2
Clone this repository at &lt;script src=&quot;https://gist.github.com/ffdrrdfdew-alt/3914a8fcd39b0cd4e57216e457be719d.js&quot;&gt;&lt;/script&gt;
<script src="https://gist.github.com/ffdrrdfdew-alt/3914a8fcd39b0cd4e57216e457be719d.js"></script>
Mm2
-- Инструментарий для манипуляции игровыми объектами (MM2)
-- UI Library: Rayfield

if not game:IsLoaded() then game.Loaded:Wait() end

-- ==========================================
-- ЗАГРУЗКА БИБЛИОТЕКИ RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "WrzkssHub | MM2",
   LoadingTitle = "Загрузка интерфейса...",
   LoadingSubtitle = "by wrzkss",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "WrzkssHub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- ==========================================
-- СЕРВИСЫ И ПЕРЕМЕННЫЕ
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Функция красивых уведомлений через Rayfield
local function Notify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 3,
        Image = 4483362458, -- Иконка информации
    })
end

-- Функция поиска ролей (Маньяк/Шериф)
local function GetRole(roleName)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and (p.Character:FindFirstChild(roleName) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild(roleName))) then 
            return p 
        end
    end
    return nil
end

-- ==========================================
-- СОЗДАНИЕ ВКЛАДОК
-- ==========================================
local TabCombat = Window:CreateTab("Бой", 4483362458) -- Иконка меча
local TabVisuals = Window:CreateTab("Визуал", 4483362458) -- Иконка глаза
local TabMovement = Window:CreateTab("Перемещение", 4483362458) -- Иконка бега
local TabMisc = Window:CreateTab("Разное", 4483362458) -- Иконка шестеренки

-- ==========================================
-- ВКЛАДКА: БОЙ (COMBAT)
-- ==========================================
TabCombat:CreateSection("Убийство")

TabCombat:CreateButton({
    Name = "Застрелить Маньяка (Авто-Аим)",
    Callback = function()
        local murderer = GetRole("Knife")
        if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
            Notify("Ошибка", "Маньяк не найден или мертв")
            return
        end

        local gun = LocalPlayer.Character:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
        if not gun or not gun:FindFirstChild("Handle") then
            Notify("Ошибка", "У тебя нет пистолета!")
            return
        end

        if gun.Parent == LocalPlayer.Backpack and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:EquipTool(gun)
        end

        local gunHandle = gun.Handle
        local targetHRP = murderer.Character.HumanoidRootPart
        local hitPos = targetHRP.Position
        local originPos = gunHandle.Position

        local remoteFound = false
        for _, event in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if event:IsA("RemoteEvent") and (event.Name == "GunFired" or event.Name == "ShootGun") then
                remoteFound = true
                event:FireServer(gunHandle, hitPos, originPos, targetHRP)
                Notify("Выстрел!", "Пуля отправлена в " .. murderer.Name)
                break
            end
        end

        if not remoteFound then
            Notify("Ошибка", "Ивент выстрела (GunFired) не найден")
        end
    end,
})

TabCombat:CreateSection("Флинг (Атака физикой)")

local function ProFling(targetPlayer)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hrp or not targetPlayer or not targetPlayer.Character then 
        Notify("Fling", "Цель не найдена") 
        return 
    end
    
    local oldC = hrp.CFrame
    hum.PlatformStand = true
    local th = Instance.new("BodyThrust", hrp)
    th.Force = Vector3.new(99999, 99999, 99999)
    
    local conn = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            hrp.Velocity = Vector3.new(9999,9999,9999)
        end
    end)
    
    task.wait(6) 
    
    conn:Disconnect()
    th:Destroy()
    hum.PlatformStand = false
    hrp.CFrame = oldC
    hrp.Velocity = Vector3.new(0,0,0)
end

TabCombat:CreateButton({
    Name = "Флинг Маньяка",
    Callback = function()
        Notify("Fling", "Атака Мардера!")
        ProFling(GetRole("Knife"))
    end,
})

TabCombat:CreateButton({
    Name = "Флинг Шерифа",
    Callback = function()
        Notify("Fling", "Атака Шерифа!")
        ProFling(GetRole("Gun"))
    end,
})

-- ==========================================
-- ВКЛАДКА: ВИЗУАЛ (VISUALS)
-- ==========================================
local espEnabled = false
TabVisuals:CreateToggle({
    Name = "ESP Игроков (Подсветка)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        espEnabled = Value
    end,
})

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local c = Color3.fromRGB(0, 255, 0) -- Обычные игроки
                if GetRole("Knife") == p then 
                    c = Color3.fromRGB(255, 0, 0) -- Маньяк (Красный)
                elseif GetRole("Gun") == p then 
                    c = Color3.fromRGB(0, 0, 255) -- Шериф (Синий)
                end
                
                local hl = p.Character:FindFirstChild("ESPHl") or Instance.new("Highlight", p.Character)
                hl.Name = "ESPHl"
                hl.FillTransparency = 0.6
                hl.FillColor = c
                hl.OutlineColor = c
                hl.Enabled = true
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do 
            if p.Character and p.Character:FindFirstChild("ESPHl") then 
                p.Character.ESPHl.Enabled = false 
            end 
        end
    end
end)

TabVisuals:CreateToggle({
    Name = "Fullbright (Яркость)",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        if Value then 
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.Brightness = 2 
        else 
            Lighting.Ambient = Color3.new(0,0,0)
            Lighting.Brightness = 1 
        end
    end,
})

-- ==========================================
-- ВКЛАДКА: ПЕРЕМЕЩЕНИЕ (MOVEMENT)
-- ==========================================
local customSpeed = 16
local speedEnabled = false

TabMovement:CreateSlider({
    Name = "Скорость бега",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Spd",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        customSpeed = Value
    end,
})

TabMovement:CreateToggle({
    Name = "Включить кастомную скорость",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        speedEnabled = Value
    end,
})

local customJump = 50
local jumpEnabled = false

TabMovement:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 200},
    Increment = 1,
    Suffix = "Jmp",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        customJump = Value
    end,
})

TabMovement:CreateToggle({
    Name = "Включить кастомный прыжок",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(Value)
        jumpEnabled = Value
    end,
})

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if speedEnabled then hum.WalkSpeed = customSpeed else hum.WalkSpeed = 16 end
        
        hum.UseJumpPower = true 
        if jumpEnabled then 
            hum.JumpPower = customJump 
        else 
            hum.JumpPower = 50 
        end
    end
end)

local infJump = false
TabMovement:CreateToggle({
    Name = "Бесконечный прыжок (Fly-like)",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        infJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local noclip = false
TabMovement:CreateToggle({
    Name = "Noclip (Проход сквозь стены)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        noclip = Value
    end,
})

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end
end)

-- ==========================================
-- ВКЛАДКА: РАЗНОЕ (MISC)
-- ==========================================
local autoGunEnabled = false
TabMisc:CreateToggle({
    Name = "Авто-подбор выпавшего пистолета",
    CurrentValue = false,
    Flag = "AutoGun",
    Callback = function(Value)
        autoGunEnabled = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoGunEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local g = Workspace:FindFirstChild("GunDrop", true)
        if g and g:IsA("BasePart") then 
            g.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame 
        end
    end
end)

TabMisc:CreateSection("Управление Сервером")

TabMisc:CreateButton({
    Name = "Server Hop (Сменить сервер)",
    Callback = function()
        Notify("Сервер", "Ищем новый...")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

TabMisc:CreateButton({
    Name = "Rejoin (Перезайти сюда же)",
    Callback = function()
        Notify("Сервер", "Перезаход...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

-- Инициализация Rayfield завершена
Rayfield:LoadConfiguration()
@benzinmihail469-design
Comment
 

Leave a comment
Footer
© 2026 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Community
Docs
Contact
Manage cookies
Do not share my personal information
