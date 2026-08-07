local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local button = script.Parent

local noclipEnabled = false

local function toggleNoclip()
    noclipEnabled = not noclipEnabled

    if noclipEnabled then
        button.Text = "Noclip: ВКЛ"
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый
    else
        button.Text = "Noclip: ВЫКЛ"
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красный
    end
end

button.MouseButton1Click:Connect(toggleNoclip)

-- Логика самого Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and character and character.Parent then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
