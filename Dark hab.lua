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
DrRay.MainBar
DRR["28"] = Instance.new("Frame", DRR["1"]);
DRR["28"]["BorderSizePixel"] = 0;
DRR["28"]["BackgroundColor3"] = Color3.fromRGB(42, 42, 58);
DRR["28"]["Size"] = UDim2.new(0.5404488444328308, 0, 0.5745577812194824, 0);
DRR["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
DRR["28"]["Position"] = UDim2.new(0.23000000417232513, 0, -0.6119999885559082, 0);
DRR["28"]["Name"] = [[MainBar]];

-- DrRay.MainBar.UICorner
DRR["29"] = Instance.new("UICorner", DRR["28"]);
DRR["29"]["CornerRadius"] = UDim.new(0.029999999329447746, 0);

-- DrRay.MainBar.UIGradient
DRR["2a"] = Instance.new("UIGradient", DRR["28"]);
DRR["2a"]["Rotation"] = 90;
DRR["2a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(90, 90, 90)),ColorSequenceKeypoint.new(0.231, Color3.fromRGB(154, 154, 154)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))};

-- DrRay.MainBar.UIAspectRatioConstraint
DRR["2b"] = Instance.new("UIAspectRatioConstraint", DRR["28"]);
DRR["2b"]["AspectRatio"] = 1.7326968908309937;

-- DrRay.MainBar.DropShadowHolder
DRR["2c"] = Instance.new("Frame", DRR["28"]);
DRR["2c"]["ZIndex"] = 0;
DRR["2c"]["BorderSizePixel"] = 0;
DRR["2c"]["BackgroundTransparency"] = 1;
DRR["2c"]["LayoutOrder"] = -1;
DRR["2c"]["Size"] = UDim2.new(1, 0, 1, 0);
DRR["2c"]["Name"] = [[DropShadowHolder]];

-- DrRay.MainBar.DropShadowHolder.DropShadow
DRR["2d"] = Instance.new("ImageLabel", DRR["2c"]);
DRR["2d"]["ZIndex"] = 0;
DRR["2d"]["BorderSizePixel"] = 0;
DRR["2d"]["SliceCenter"] = Rect.new(49, 49, 450, 450);
DRR["2d"]["ScaleType"] = Enum.ScaleType.Slice;
DRR["2d"]["ImageColor3"] = Color3.fromRGB(0, 0, 0);
DRR["2d"]["ImageTransparency"] = 0.5;
DRR["2d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
DRR["2d"]["Image"] = [[rbxassetid://6014261993]];
DRR["2d"]["Size"] = UDim2.new(1, 47, 1, 47);
DRR["2d"]["Name"] = [[DropShadow]];
DRR["2d"]["BackgroundTransparency"] = 1;
DRR["2d"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

-- DrRay.MainBar.Logo
DRR["2e"] = Instance.new("ImageLabel", DRR["28"]);
DRR["2e"]["BorderSizePixel"] = 0;
DRR["2e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
DRR["2e"]["Image"] = [[rbxassetid://14133403065]];
DRR["2e"]["Size"] = UDim2.new(0.18741475045681, 0, 0.3247329592704773, 0);
DRR["2e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
DRR["2e"]["Name"] = [[Logo]];
DRR["2e"]["BackgroundTransparency"] = 1;
DRR["2e"]["Position"] = UDim2.new(0.3991934061050415, 0, 0.33447495102882385, 0);

-- DrRay.MainBar.Logo.UIGradient
DRR["2f"] = Instance.new("UIGradient", DRR["2e"]);
DRR["2f"]["Rotation"] = 90;
DRR["2f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(5, 6, 23))};
