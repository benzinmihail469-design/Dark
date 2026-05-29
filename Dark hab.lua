local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local newSpeed = 100000

local lastSpeed = 0

while true do
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= newSpeed then
            humanoid.WalkSpeed = newSpeed
            if lastSpeed ~= humanoid.WalkSpeed then
                print("🔄 Восстановил скорость: " .. humanoid.WalkSpeed)
                lastSpeed = humanoid.WalkSpeed
            end
        end
    end
    task.wait(0.05)  -- 20 раз в секунду
end
