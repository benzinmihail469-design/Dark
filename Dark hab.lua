local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local newSpeed = 100000
local oldSpeed = humanoid.WalkSpeed

humanoid.WalkSpeed = newSpeed
while true do 

-- Проверка: изменилась ли скорость?
if humanoid.WalkSpeed == newSpeed then
    print("✅ Скорость УВЕЛИЧЕНА! Было: " .. oldSpeed .. ", Стало: " .. humanoid.WalkSpeed)
else
    print("❌ Не удалось изменить скорость. Возможно, стоит ограничение.")
end
