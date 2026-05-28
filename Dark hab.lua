-- Kill Aura для Roblox: Арена Зомби
-- Ищет папку Zombies_Local, внутри модели Zombie
-- Включение/выключение по клавише (по умолчанию G)
-- Радиус атаки: 50

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local ATTACK_RADIUS = 50      -- Радиус атаки
local DAMAGE_AMOUNT = 10      -- Урон за удар (подбери под свою игру)
local COOLDOWN = 0.2          -- Интервал между ударами (секунды)
local TOGGLE_KEY = Enum.KeyCode.G  -- Кнопка включения/выключения (можно поменять)

-- Состояние
local auraEnabled = false
local lastAttackTime = 0

-- Поиск папки Zombies_Local (обычно в workspace или в PlayerScripts)
local function findZombieContainer()
    -- Ищем в workspace
    local zombieParent = workspace:FindFirstChild("Zombies_Local")
    if zombieParent then return zombieParent end
    
    -- Альтернативный поиск (на всякий случай)
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "Zombies_Local" then
            return child
        end
    end
    
    return nil
end

-- Получить всех живых зомби
local function getAliveZombies()
    local zombieContainer = findZombieContainer()
    local zombies = {}
    
    if zombieContainer then
        for _, zombieModel in pairs(zombieContainer:GetChildren()) do
            -- Проверяем, что это модель с именем Zombie и у неё есть Humanoid
            if zombieModel.Name == "Zombie" and zombieModel:IsA("Model") then
                local zombieHumanoid = zombieModel:FindFirstChild("Humanoid")
                if zombieHumanoid and zombieHumanoid.Health > 0 then
                    table.insert(zombies, zombieModel)
                end
            end
        end
    end
    
    return zombies
end

-- Нанести урон зомби
local function damageZombie(zombie)
    local zombieHumanoid = zombie:FindFirstChild("Humanoid")
    if zombieHumanoid and zombieHumanoid.Health > 0 then
        -- Способ 1: нанести урон через Humanoid
        zombieHumanoid.Health = zombieHumanoid.Health - DAMAGE_AMOUNT
        
        -- Способ 2 (альтернативный): вызов события урона (если не работает способ 1)
        local damageEvent = zombie:FindFirstChild("DamageEvent")
        if damageEvent and damageEvent:IsA("RemoteEvent") then
            damageEvent:FireServer(DAMAGE_AMOUNT)
        end
        
        -- Способ 3: через удары (Tool)
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            -- Эмуляция удара
            local handle = tool.Handle
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {Character, tool}
            
            local origin = handle.Position
            local direction = (zombieHumanoid.RootPart.Position - origin).Unit * 10
            
            local rayResult = workspace:Raycast(origin, direction, raycastParams)
            if rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(zombie) then
                -- Если нашли, значит удар попал
                tool:Activate()
            end
        end
    end
end

-- Основная логика атаки
local function attackLoop()
    if not auraEnabled then return end
    
    local now = tick()
    if now - lastAttackTime < COOLDOWN then return end
    
    local zombies = getAliveZombies()
    local characterPos = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if characterPos and zombies then
        for _, zombie in pairs(zombies) do
            local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
            if zombieRoot then
                local distance = (characterPos.Position - zombieRoot.Position).Magnitude
                if distance <= ATTACK_RADIUS then
                    damageZombie(zombie)
                    lastAttackTime = now
                    break  -- Атакуем одного зомби за цикл (для баланса)
                end
            end
        end
    end
end

-- Обработчик кнопки включения
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        auraEnabled = not auraEnabled
        
        -- Уведомление (вывод в консоль)
        local status = auraEnabled and "ВКЛЮЧЕНА" or "ВЫКЛЮЧЕНА"
        print("Kill Aura " .. status)
        
        -- Визуальное уведомление в игре (если есть чат)
        if auraEnabled then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Kill Aura",
                Text = "Включена",
                Duration = 2
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Kill Aura",
                Text = "Выключена",
                Duration = 2
            })
        end
    end
end)

-- Обновление персонажа при респавне
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
end)

-- Запуск цикла атаки
RunService.Heartbeat:Connect(attackLoop)

print("Kill Aura загружена! Нажми G для включения/выключения")
