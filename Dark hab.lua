local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local noclipEnabled = false
local toggleKey = Enum.KeyCode.N

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleKey then
        noclipEnabled = not noclipEnabled
    end
end)

RunService.RenderStepped:Connect(function()
    if not noclipEnabled then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        -- Смещает персонажа вперед сквозь стены без изменения CanCollide
        hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * 0.35)
    end
end)
