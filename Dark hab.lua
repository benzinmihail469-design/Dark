-- Локальный хак скрипт для урона по зомби
-- Наносит 1000 урона всем зомби в радиусе 200

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local DAMAGE = 1000
local RADIUS = 200

-- Поиск папки с зомби
local function findZombiesFolder()
    local zombiesFolder = workspace:FindFirstChild("Zombies_Local")
    if not zombiesFolder then
        zombiesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Zombies_Local")
    end
    return zombiesFolder
end

-- Нанесение урона
local function damageZombies()
    local zombiesFolder = findZombiesFolder()
    if not zombiesFolder then 
        warn("Папка Zombies_Local не найдена!")
        return 
    end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local playerPos = rootPart.Position
    local hitCount = 0
    
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") then
            local humanoid = zombie:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local zombiePos = zombie:GetPivot().Position
                local distance = (playerPos - zombiePos).Magnitude
                
                if distance <= RADIUS then
                    humanoid.Health = humanoid.Health - DAMAGE
                    hitCount = hitCount + 1
                    
                    -- Эффект попадания
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(2, 2, 2)
                    part.Shape = Enum.PartType.Ball
                    part.BrickColor = BrickColor.new("Really red")
                    part.Material = Enum.Material.Neon
                    part.CFrame = zombie:GetPivot()
                    part.Anchored = true
                    part.CanCollide = false
                    part.Parent = workspace
                    game:GetService("Debris"):AddItem(part, 0.3)
                end
            end
        end
    end
    
    if hitCount > 0 then
        print(string.format("[HACK] Убито зомби: %d", hitCount))
    end
end

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZombieHack"
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 45)
button.Position = UDim2.new(0, 10, 0, 10)
button.Text = "💀 УРОН 1000 💀"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
button.BorderSizePixel = 2
button.Parent = screenGui

-- Кнопка для урона
button.MouseButton1Click:Connect(function()
    damageZombies()
end)

-- Горячая клавиша X
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.X then
        damageZombies()
    end
end)

print("[✔] Хак загружен! Нажми на кнопку или клавишу X")
