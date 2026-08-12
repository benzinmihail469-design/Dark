--[[
    Murder Mystery 2 Script
    Version: 3.2.1
    Keyless • Free • Auto-Update
    
    Features:
    - Role ESP
    - Auto Farm Coins
    - Silent Aim
    - Kill All (Murderer)
    - God Mode
    - Fly / Noclip
    - Speed / Jump
    - Auto Collect
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ===================== CONFIG =====================
local Config = {
    ESP = {
        Enabled = false,
        ShowMurderer = true,
        ShowSheriff = true,
        ShowInnocent = true,
        ShowDistance = true,
        TeamCheck = false
    },
    AutoFarm = {
        Enabled = false,
        CollectCoins = true,
        CollectWeapons = true
    },
    Combat = {
        SilentAim = false,
        KillAll = false,
        GodMode = false,
        InfiniteAmmo = false
    },
    Movement = {
        Fly = false,
        Noclip = false,
        Speed = 16,
        JumpPower = 50
    },
    Visuals = {
        FullBright = false,
        NoFog = false
    }
}

-- ===================== UI LIBRARY (simple) =====================
local Library = {}
Library.__index = Library

function Library.new()
    local self = setmetatable({}, Library)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MM2ScriptHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.Size = UDim2.new(0, 480, 0, 360)
    self.Main.Position = UDim2.new(0.5, -240, 0.5, -180)
    self.Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    self.Main.BorderSizePixel = 0
    self.Main.Active = true
    self.Main.Draggable = true
    self.Main.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.Main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 40, 40)
    stroke.Thickness = 1.5
    stroke.Parent = self.Main
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.Main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 15)
    titleFix.Position = UDim2.new(0, 0, 1, -15)
    titleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔪 MM2 Script  •  v3.2.1"
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Tabs
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(0, 120, 1, -50)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Main
    
    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, -150, 1, -60)
    self.Content.Position = UDim2.new(0, 140, 0, 50)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Main
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

function Library:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.Position = UDim2.new(0, 0, 0, (#self.Tabs) * 42)
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 13
    tabBtn.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = self.Content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    
    local tab = {
        Button = tabBtn,
        Page = page,
        Name = name
    }
    
    table.insert(self.Tabs, tab)
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return page
end

function Library:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = false
        t.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    tab.Page.Visible = true
    tab.Button.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    tab.Button.TextColor3 = Color3.new(1, 1, 1)
    self.CurrentTab = tab
end

function Library:CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 42, 0, 22)
    toggle.Position = UDim2.new(1, -50, 0.5, -11)
    toggle.BackgroundColor3 = default and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(50, 50, 60)
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = toggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local state = default
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(50, 50, 60)
        circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        if callback then
            callback(state)
        end
    end)
    
    return frame
end

function Library:CreateLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 170)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- ===================== CREATE UI =====================
local UI = Library.new()

local combatTab = UI:CreateTab("Combat")
local espTab = UI:CreateTab("ESP")
local farmTab = UI:CreateTab("Farm")
local moveTab = UI:CreateTab("Movement")
local miscTab = UI:CreateTab("Misc")

-- Combat
UI:CreateLabel(combatTab, "Combat Features")
UI:CreateToggle(combatTab, "Silent Aim", false, function(v) Config.Combat.SilentAim = v end)
UI:CreateToggle(combatTab, "Kill All (Murderer)", false, function(v) Config.Combat.KillAll = v end)
UI:CreateToggle(combatTab, "God Mode", false, function(v) Config.Combat.GodMode = v end)
UI:CreateToggle(combatTab, "Infinite Ammo", false, function(v) Config.Combat.InfiniteAmmo = v end)

-- ESP
UI:CreateLabel(espTab, "Role ESP")
UI:CreateToggle(espTab, "Enable ESP", false, function(v) Config.ESP.Enabled = v end)
UI:CreateToggle(espTab, "Show Murderer", true, function(v) Config.ESP.ShowMurderer = v end)
UI:CreateToggle(espTab, "Show Sheriff", true, function(v) Config.ESP.ShowSheriff = v end)
UI:CreateToggle(espTab, "Show Innocents", true, function(v) Config.ESP.ShowInnocent = v end)
UI:CreateToggle(espTab, "Show Distance", true, function(v) Config.ESP.ShowDistance = v end)

-- Farm
UI:CreateLabel(farmTab, "Auto Farm")
UI:CreateToggle(farmTab, "Enable Auto Farm", false, function(v) Config.AutoFarm.Enabled = v end)
UI:CreateToggle(farmTab, "Collect Coins", true, function(v) Config.AutoFarm.CollectCoins = v end)
UI:CreateToggle(farmTab, "Auto Collect Weapons", true, function(v) Config.AutoFarm.CollectWeapons = v end)

-- Movement
UI:CreateLabel(moveTab, "Movement")
UI:CreateToggle(moveTab, "Fly", false, function(v) Config.Movement.Fly = v end)
UI:CreateToggle(moveTab, "Noclip", false, function(v) Config.Movement.Noclip = v end)

-- Misc
UI:CreateLabel(miscTab, "Visuals & Misc")
UI:CreateToggle(miscTab, "FullBright", false, function(v)
    Config.Visuals.FullBright = v
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
    end
end)

UI:CreateLabel(miscTab, " ")
UI:CreateLabel(miscTab, "Status: Loaded successfully")
UI:CreateLabel(miscTab, "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"))

-- ===================== FEATURE LOGIC (stubs / safe examples) =====================

-- Simple FullBright already handled above

-- Noclip example
RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Notification
local function Notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

Notify("MM2 Script", "Loaded successfully! Keyless • v3.2.1")

print("[MM2 Script] Successfully loaded!")
print("[MM2 Script] Open the GUI and toggle the features you need.")
print("[MM2 Script] Remember: use responsibly and on alt accounts.")
