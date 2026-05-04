if getgenv then getgenv().ConfirmLuna = true end
if not identifyexecutor then identifyexecutor = function() return "Unknown" end end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local TrapESP = {
    Enabled = false,
    LabelColor = Color3.fromRGB(255, 70, 70),
    LabelSize = 13,
    HighlightColor = Color3.fromRGB(255, 60, 60),
    HighlightOutline = Color3.fromRGB(255, 210, 0),
    HighlightFillTrans = 0.55,
    HighlightOutlineTrans = 0,
}
local GeneratorESP = {
    Enabled = false,
    ProximityRange = 20,
    HighlightColor = Color3.fromRGB(0, 210, 255),
    HighlightOutline = Color3.fromRGB(255, 255, 255),
    HighlightFillTrans = 0.35,
    HighlightOutlineTrans = 0,
}
local KillerESP = {
    Enabled = false,
    HighlightColor = Color3.fromRGB(220, 30, 30),
    HighlightOutline = Color3.fromRGB(255, 100, 0),
    HighlightFillTrans = 0.15,
    HighlightOutlineTrans = 0,
}

local TrackedTraps      = {}
local TrackedGenerators = {}
local TrackedKillers    = {}
local RenderConnection  = nil
local Unloaded          = false

local InfiniteStamina = { Enabled = false, Conn = nil }
local AutoGen         = { Enabled = false, Conn = nil, Done = false }
local Noclip          = { Enabled = false, Conn = nil }
local InfiniteJump    = { Enabled = false, Conn = nil }
local AllowJumping    = { Enabled = false, Conn = nil }
local AntiStun        = { Enabled = false, Conn = nil }

local FullBright = { Enabled = false, Conn = nil }
local NoFog       = { Enabled = false, Conn = nil, OriginalFogEnd = nil, ChildConn = nil }

local function W2S(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), v.Z, onScreen
end

local function GetCharRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function FindBasePart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
    end
    return nil
end

local function GetCenter(obj)
    if obj:IsA("Model") then
        local ok, cf = pcall(function() return obj:GetBoundingBox() end)
        if ok and cf then return cf.Position end
        local p = FindBasePart(obj)
        return p and p.Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function MakeHighlight(obj, fill, outline, fillTrans, outlineTrans)
    local part = FindBasePart(obj)
    if not part then return nil end
    local h = Instance.new("Highlight")
    h.FillColor           = fill
    h.OutlineColor        = outline
    h.FillTransparency    = fillTrans
    h.OutlineTransparency = outlineTrans
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee             = obj:IsA("Model") and obj or part
    h.Parent              = part
    return h
end

local function MakeLabel(text, color, size)
    local t   = Drawing.new("Text")
    t.Text    = text
    t.Size    = size or 13
    t.Color   = color
    t.Outline = true
    t.Center  = true
    t.Visible = false
    t.Font    = Drawing.Fonts.UI
    return t
end

local function DestroyEntry(e)
    if not e then return end
    pcall(function() e.label:Remove() end)
    if e.highlight then pcall(function() e.highlight:Destroy() end) end
end

local function ShowTable(t, show)
    for _, e in pairs(t) do
        if e.label     then e.label.Visible     = show end
        if e.highlight then e.highlight.Enabled = show end
    end
end

local function IsGeneratorDone(obj)
    local p = obj:GetAttribute("Progress") or obj:GetAttribute("progress")
    return p == 100
end

local function IsTrap(obj)
    return obj:IsA("Model") and obj.Name == "Trap"
end

local function GetTrapPos(model)
    local inner = model:FindFirstChild("Trap")
    if inner and inner:IsA("BasePart") then return inner.Position end
    local p = FindBasePart(model)
    return p and p.Position
end

local function TrackTrap(model)
    if TrackedTraps[model] or not IsTrap(model) then return end
    local h = MakeHighlight(model, TrapESP.HighlightColor, TrapESP.HighlightOutline, TrapESP.HighlightFillTrans, TrapESP.HighlightOutlineTrans)
    TrackedTraps[model] = {
        label     = MakeLabel("Bear Trap", TrapESP.LabelColor, TrapESP.LabelSize),
        highlight = h,
    }
end

local function UntrackTrap(model)
    DestroyEntry(TrackedTraps[model])
    TrackedTraps[model] = nil
end

local function TrackGenerator(obj)
    if TrackedGenerators[obj] or IsGeneratorDone(obj) or not FindBasePart(obj) then return end
    local h = MakeHighlight(obj, GeneratorESP.HighlightColor, GeneratorESP.HighlightOutline, GeneratorESP.HighlightFillTrans, GeneratorESP.HighlightOutlineTrans)
    if not h then return end
    TrackedGenerators[obj] = {
        label     = MakeLabel("Generator", Color3.fromRGB(0, 210, 255), 13),
        highlight = h,
    }
end

local function UntrackGenerator(obj)
    DestroyEntry(TrackedGenerators[obj])
    TrackedGenerators[obj] = nil
end

local function TrackKiller(model)
    if TrackedKillers[model] or not model:IsA("Model") then return end
    local h = MakeHighlight(model, KillerESP.HighlightColor, KillerESP.HighlightOutline, KillerESP.HighlightFillTrans, KillerESP.HighlightOutlineTrans)
    TrackedKillers[model] = {
        label     = MakeLabel("KILLER", Color3.fromRGB(220, 30, 30), 15),
        highlight = h,
    }
end

local function UntrackKiller(model)
    DestroyEntry(TrackedKillers[model])
    TrackedKillers[model] = nil
end

local function WireGenSignals(c)
    c:GetAttributeChangedSignal("Progress"):Connect(function()
        if IsGeneratorDone(c) then UntrackGenerator(c) end
    end)
    c:GetAttributeChangedSignal("progress"):Connect(function()
        if IsGeneratorDone(c) then UntrackGenerator(c) end
    end)
end

local function FullRescan()
    for m in pairs(TrackedTraps)      do UntrackTrap(m)      end
    for o in pairs(TrackedGenerators) do UntrackGenerator(o) end
    for m in pairs(TrackedKillers)    do UntrackKiller(m)    end

    local ignore = workspace:FindFirstChild("IGNORE")
    if ignore then
        for _, c in ipairs(ignore:GetChildren()) do
            if IsTrap(c) then TrackTrap(c) end
        end
    end

    local maps = workspace:FindFirstChild("MAPS")
    local gm   = maps and maps:FindFirstChild("GAME MAP")
    local gf   = gm and gm:FindFirstChild("Generators")
    if gf then
        for _, gen in ipairs(gf:GetChildren()) do
            if not IsGeneratorDone(gen) then
                TrackGenerator(gen)
                WireGenSignals(gen)
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            TrackKiller(plr.Character)
        end
    end
end

local function OnRender()
    if Unloaded then return end

    for model, data in pairs(TrackedTraps) do
        if model.Parent then
            local pos = GetTrapPos(model)
            if pos then
                local screen, depth, onScreen = W2S(pos)
                if onScreen then
                    data.label.Position = screen
                    data.label.Visible = TrapESP.Enabled
                else
                    data.label.Visible = false
                end
            end
        else
            UntrackTrap(model)
        end
    end

    for gen, data in pairs(TrackedGenerators) do
        if gen.Parent then
            local pos = GetCenter(gen)
            if pos then
                local screen, depth, onScreen = W2S(pos)
                if onScreen then
                    data.label.Position = screen
                    data.label.Visible = GeneratorESP.Enabled
                else
                    data.label.Visible = false
                end
            end
        else
            UntrackGenerator(gen)
        end
    end

    for model, data in pairs(TrackedKillers) do
        if model.Parent then
            local pos = GetCenter(model)
            if pos then
                local screen, depth, onScreen = W2S(pos + Vector3.new(0, 3, 0))
                if onScreen then
                    data.label.Position = screen
                    data.label.Visible = KillerESP.Enabled
                else
                    data.label.Visible = false
                end
            end
        else
            UntrackKiller(model)
        end
    end
end

-- ==================== Тогглы ====================

local function ToggleInfiniteStamina(state)
    InfiniteStamina.Enabled = state
    if state then
        InfiniteStamina.Conn = RunService.Heartbeat:Connect(function()
            local hum = GetHumanoid()
            if hum then
                hum:SetAttribute("Stamina", 100)
                hum:SetAttribute("stamina", 100)
            end
        end)
    else
        if InfiniteStamina.Conn then InfiniteStamina.Conn:Disconnect() end
    end
end

local function ToggleNoclip(state)
    Noclip.Enabled = state
    if state then
        Noclip.Conn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Noclip.Conn then Noclip.Conn:Disconnect() end
    end
end

local function ToggleInfiniteJump(state)
    InfiniteJump.Enabled = state
    if state then
        InfiniteJump.Conn = UserInputService.JumpRequest:Connect(function()
            local hum = GetHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfiniteJump.Conn then InfiniteJump.Conn:Disconnect() end
    end
end

local function ToggleAntiStun(state)
    AntiStun.Enabled = state
    if state then
        AntiStun.Conn = RunService.Heartbeat:Connect(function()
            local hum = GetHumanoid()
            if hum then
                hum:SetAttribute("Stunned", false)
                hum.PlatformStand = false
            end
        end)
    else
        if AntiStun.Conn then AntiStun.Conn:Disconnect() end
    end
end

-- ==================== GUI (Linoria) ====================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Bite By Night | abstravt",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
    Settings = Window:AddTab("Settings"),
}

-- Main
local MainGroup = Tabs.Main:AddLeftGroupbox("Cheats")
MainGroup:AddToggle("InfStamina", {Text = "Infinite Stamina", Default = false, Callback = ToggleInfiniteStamina})
MainGroup:AddToggle("AntiStun",   {Text = "Anti Stun", Default = false, Callback = ToggleAntiStun})

-- Visuals
local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPGroup:AddToggle("TrapESP",     {Text = "Trap ESP", Default = false, Callback = function(v) TrapESP.Enabled = v; ShowTable(TrackedTraps, v) end})
ESPGroup:AddToggle("GenESP",      {Text = "Generator ESP", Default = false, Callback = function(v) GeneratorESP.Enabled = v; ShowTable(TrackedGenerators, v) end})
ESPGroup:AddToggle("KillerESP",   {Text = "Killer ESP", Default = false, Callback = function(v) KillerESP.Enabled = v; ShowTable(TrackedKillers, v) end})

-- Misc
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Movement")
MiscGroup:AddToggle("Noclip",      {Text = "Noclip", Default = false, Callback = ToggleNoclip})
MiscGroup:AddToggle("InfJump",     {Text = "Infinite Jump", Default = false, Callback = ToggleInfiniteJump})

-- Settings
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function()
    Unloaded = true
    if RenderConnection then RenderConnection:Disconnect() end
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- ==================== Запуск ====================

FullRescan()

RenderConnection = RunService.RenderStepped:Connect(OnRender)

task.spawn(function()
    while not Unloaded do
        task.wait(5)
        FullRescan()
    end
end)

print("✅ Bite By Night успешно загружен!")
print("Executor:", identifyexecutor())
