local DarkHub = {} -- Dark Hub UI (Pulse Hub Styled Sizes - Compact)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local lp = LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera

local IsMobile = UserInputService.TouchEnabled

-- === ПЕРЕМЕННЫЕ ДЛЯ РОЛЕЙ И ESP ===
local roleCache = {}
_G.ESPEnabled = true
_G.GunESPEnabled = false

-- ==========================================
-- ===  ЛОГИКА RENDER / FOV STRETCH      ===
-- ==========================================
local FOVEnabled = false
local FOVValue = 70 -- Значение по умолчанию (70 = стандартный FOV)
local originalFOV = Camera.FieldOfView
local fovConnection = nil

local function updateFOV()
    if FOVEnabled then
        if not fovConnection then
            fovConnection = RunService.RenderStepped:Connect(function()
                if FOVEnabled and Camera then
                    -- Плавно изменяем FOV для эффекта "растянутого" экрана
                    Camera.FieldOfView = FOVValue
                end
            end)
        end
        -- Применяем сразу
        Camera.FieldOfView = FOVValue
    else
        if fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
        -- Возвращаем стандартный FOV
        Camera.FieldOfView = originalFOV
    end
end

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ПОЛУЧЕНИЯ РОЛЕЙ ===
local function getPlayerRoleInfo(p)
    if not p then return "LOBBY", Color3.fromRGB(180, 180, 180) end
    local char = p.Character
    local backpack = p:FindFirstChild('Backpack')
    local hasKnife = (backpack and backpack:FindFirstChild('Knife')) or (char and char:FindFirstChild('Knife'))
    local hasGun = (backpack and backpack:FindFirstChild('Gun')) or (char and char:FindFirstChild('Gun'))
    local pData = roleCache[p.Name]
    local roleRaw = (pData and type(pData) == 'table' and pData.Role) or ''
    local isKilled = (pData and type(pData) == 'table' and (pData.Killed == true or pData.Dead == true or pData.IsDead == true))
    local hum = char and char:FindFirstChildOfClass('Humanoid')

    local isDead = not char or (hum and hum.Health <= 0) or isKilled or roleRaw == 'Dead' or roleRaw == 'Lobby' or roleRaw == ''

    if isDead then
        return "LOBBY", Color3.fromRGB(180, 180, 180)
    elseif hasKnife or roleRaw == 'Murderer' then
        return "MURDERER", Color3.fromRGB(255, 35, 35)
    elseif hasGun or roleRaw == 'Sheriff' or roleRaw == 'Hero' then
        return "SHERIFF", Color3.fromRGB(0, 162, 255)
    else
        return "INNOCENT", Color3.fromRGB(0, 255, 128)
    end
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local backpack = p:FindFirstChild('Backpack')
            local char = p.Character

            if backpack and backpack:FindFirstChild('Knife') then
                return p
            end
            if char and char:FindFirstChild('Knife') then
                return p
            end
        end
    end
    for name, data in pairs(roleCache) do
        if data.Role == 'Murderer' then
            local p = Players:FindFirstChild(name)
            if p then
                return p
            end
        end
    end

    return nil
end

local function getSheriff()
    if workspace:FindFirstChild('GunDrop', true) then
        return nil
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local backpack = p:FindFirstChild('Backpack')
            local char = p.Character
            local hasGun = char:FindFirstChild('Gun') or (backpack and backpack:FindFirstChild('Gun'))

            if hasGun then
                return p
            end
        end
    end
    for name, data in pairs(roleCache) do
        if data.Role == 'Sheriff' or data.Role == 'Hero' then
            local p = Players:FindFirstChild(name)
            if p then
                return p
            end
        end
    end

    return nil
end

-- === ОБНОВЛЕННАЯ СИСТЕМА ESP ИГРОКОВ ===
local function applyPlayerESP(p)
    if not p or p == lp then
        return
    end

    local function setup(char)
        if not char then
            return
        end

        local head = char:WaitForChild('Head', 10)
        if not head then
            return
        end

        local highlight = char:FindFirstChild('ExodusESP') or Instance.new('Highlight')
        highlight.Name = 'ExodusESP'
        highlight.Parent = char
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0

        local bill = head:FindFirstChild('ExodusBill') or Instance.new('BillboardGui')
        bill.Name = 'ExodusBill'
        bill.Parent = head
        bill.Adornee = head
        bill.Size = UDim2.new(0, 180, 0, 60)
        bill.AlwaysOnTop = true
        bill.ExtentsOffset = Vector3.new(0, 3, 0)

        local label = bill:FindFirstChild('TextLabel') or Instance.new('TextLabel')
        label.Parent = bill
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextStrokeTransparency = 0

        task.spawn(function()
            while char and char.Parent and p and p.Parent and p.Character == char do
                if _G.ESPEnabled then
                    highlight.Enabled = true
                    bill.Enabled = true

                    local roleName, roleColor = getPlayerRoleInfo(p)

                    local distance = 0
                    if Camera and head then
                        distance = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
                    end

                    highlight.FillColor = roleColor
                    highlight.OutlineColor = roleColor

                    label.TextColor3 = roleColor
                    label.Text = string.format("[%s]\n%s\n[%dm]", roleName, p.DisplayName, distance)
                else
                    highlight.Enabled = false
                    bill.Enabled = false
                end

                task.wait(0.15)
            end
        end)
    end

    p.CharacterAdded:Connect(setup)
    if p.Character then
        setup(p.Character)
    end
end

for _, player in pairs(Players:GetPlayers()) do
    applyPlayerESP(player)
end
Players.PlayerAdded:Connect(applyPlayerESP)

-- === СИСТЕМА ESP GUN (ВЫПАВШЕЕ ОРУЖИЕ) ===
local function applyGunESP(gun)
    if not gun then return end
    if gun:FindFirstChild("ExodusGunESP") then return end

    local handle = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle") or gun.PrimaryPart or gun:FindFirstChildWhichIsA("BasePart")
    if not handle then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ExodusGunESP"
    highlight.Parent = gun
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0

    local bill = Instance.new("BillboardGui")
    bill.Name = "ExodusGunBill"
    bill.Parent = handle
    bill.Adornee = handle
    bill.Size = UDim2.new(0, 120, 0, 40)
    bill.AlwaysOnTop = true
    bill.ExtentsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel")
    label.Parent = bill
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextStrokeTransparency = 0
    label.Text = "[GUN]"

    task.spawn(function()
        while gun and gun.Parent do
            if _G.GunESPEnabled then
                highlight.Enabled = true
                bill.Enabled = true
                if Camera and handle then
                    local dist = math.floor((handle.Position - Camera.CFrame.Position).Magnitude)
                    label.Text = string.format("[GUN]\n[%dm]", dist)
                end
            else
                highlight.Enabled = false
                bill.Enabled = false
            end
            task.wait(0.2)
        end
    end)
end

local function checkAndApplyGun(obj)
    if obj.Name == "GunDrop" or obj.Name == "NormalHandgun" then
        applyGunESP(obj)
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    checkAndApplyGun(obj)
end
workspace.DescendantAdded:Connect(checkAndApplyGun)

task.spawn(function()
    while task.wait(0.5) do
        local success, data = pcall(function()
            local remote = game:GetService('ReplicatedStorage'):FindFirstChild('GetPlayerData', true)
            if remote then
                return remote:InvokeServer()
            end
        end)

        if success and type(data) == 'table' then
            roleCache = data
        end
    end
end)

-- === ОБНОВЛЕННЫЕ НАСТРОЙКИ РАЗМЕРОВ ГУИ ===
local MainWidth = IsMobile and 530 or 570
local MainHeight = IsMobile and 320 or 340
local SidebarWidth = IsMobile and 140 or 150
local HeaderHeight = 36
local FooterHeight = 42

local function GetIconUri(Icon)
    if not Icon or Icon == "" then return "" end
    local StrIcon = tostring(Icon)
    if string.find(StrIcon, "rbxthumb://") or string.find(StrIcon, "rbxassetid://") then
        return StrIcon
    end
    local Id = string.match(StrIcon, "%d+")
    if Id then
        return "rbxthumb://type=Asset&id=" .. Id .. "&w=150&h=150"
    end
    return StrIcon
end

local DarkHubIcon = GetIconUri("91508433366374")

local function Create(Class, Properties)
    local Instance = Instance.new(Class)
    for Property, Value in pairs(Properties) do
        Instance[Property] = Value
    end
    return Instance
end

local function CreateTween(Instance, Info, Goal)
    local Tween = TweenService:Create(Instance, Info, Goal)
    Tween:Play()
    return Tween
end

local function CleanString(Str)
    if not Str then return "" end
    local Cleaned = string.lower(tostring(Str))
    Cleaned = string.gsub(Cleaned, "[%s%p]", "")
    return Cleaned
end

-- Цветовая схема (По умолчанию AMOLED Black)
local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Background2 = Color3.fromRGB(5, 5, 5),
    SectionBackground = Color3.fromRGB(6, 6, 6),
    SectionBackground2 = Color3.fromRGB(10, 10, 10),
    SectionTop = Color3.fromRGB(16, 16, 16),
    Element = Color3.fromRGB(12, 12, 12),
    Outline = Color3.fromRGB(22, 22, 22),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 116, 224),
    AccentGradient = Color3.fromRGB(0, 195, 255),
}

-- ПРЕСЕТЫ ТЕМ ДЛЯ UI
local ThemesPresets = {
    ["AMOLED Black"] = {
        Background = Color3.fromRGB(0, 0, 0),
        Background2 = Color3.fromRGB(5, 5, 5),
        SectionBackground = Color3.fromRGB(6, 6, 6),
        SectionBackground2 = Color3.fromRGB(10, 10, 10),
        SectionTop = Color3.fromRGB(16, 16, 16),
        Element = Color3.fromRGB(12, 12, 12),
        Outline = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 116, 224),
        AccentGradient = Color3.fromRGB(0, 195, 255),
    },
    ["Dark Blue"] = {
        Background = Color3.fromRGB(8, 12, 22),
        Background2 = Color3.fromRGB(12, 18, 30),
        SectionBackground = Color3.fromRGB(14, 20, 34),
        SectionBackground2 = Color3.fromRGB(18, 26, 42),
        SectionTop = Color3.fromRGB(22, 32, 52),
        Element = Color3.fromRGB(20, 28, 45),
        Outline = Color3.fromRGB(35, 48, 75),
        Text = Color3.fromRGB(240, 245, 255),
        Accent = Color3.fromRGB(0, 132, 255),
        AccentGradient = Color3.fromRGB(0, 210, 255),
    },
    ["Crimson Red"] = {
        Background = Color3.fromRGB(18, 8, 10),
        Background2 = Color3.fromRGB(24, 12, 14),
        SectionBackground = Color3.fromRGB(28, 14, 16),
        SectionBackground2 = Color3.fromRGB(35, 18, 20),
        SectionTop = Color3.fromRGB(45, 22, 25),
        Element = Color3.fromRGB(32, 16, 18),
        Outline = Color3.fromRGB(60, 25, 28),
        Text = Color3.fromRGB(255, 240, 242),
        Accent = Color3.fromRGB(225, 29, 72),
        AccentGradient = Color3.fromRGB(251, 113, 133),
    },
    ["Emerald Green"] = {
        Background = Color3.fromRGB(6, 16, 12),
        Background2 = Color3.fromRGB(10, 22, 16),
        SectionBackground = Color3.fromRGB(12, 26, 19),
        SectionBackground2 = Color3.fromRGB(16, 32, 24),
        SectionTop = Color3.fromRGB(22, 42, 32),
        Element = Color3.fromRGB(18, 35, 26),
        Outline = Color3.fromRGB(30, 58, 44),
        Text = Color3.fromRGB(240, 253, 244),
        Accent = Color3.fromRGB(16, 185, 129),
        AccentGradient = Color3.fromRGB(52, 211, 153),
    },
    ["Purple Velvet"] = {
        Background = Color3.fromRGB(14, 8, 20),
        Background2 = Color3.fromRGB(20, 12, 28),
        SectionBackground = Color3.fromRGB(24, 14, 34),
        SectionBackground2 = Color3.fromRGB(30, 18, 42),
        SectionTop = Color3.fromRGB(40, 24, 56),
        Element = Color3.fromRGB(28, 16, 40),
        Outline = Color3.fromRGB(55, 30, 78),
        Text = Color3.fromRGB(250, 245, 255),
        Accent = Color3.fromRGB(147, 51, 234),
        AccentGradient = Color3.fromRGB(192, 132, 252),
    },
    ["Cyberpunk"] = {
        Background = Color3.fromRGB(15, 10, 25),
        Background2 = Color3.fromRGB(22, 14, 36),
        SectionBackground = Color3.fromRGB(26, 16, 42),
        SectionBackground2 = Color3.fromRGB(32, 20, 50),
        SectionTop = Color3.fromRGB(42, 26, 65),
        Element = Color3.fromRGB(30, 18, 48),
        Outline = Color3.fromRGB(65, 35, 95),
        Text = Color3.fromRGB(255, 240, 255),
        Accent = Color3.fromRGB(236, 72, 153),
        AccentGradient = Color3.fromRGB(249, 115, 22),
    },
}

-- Шрифты
local FontSemiBold = Font.fromEnum(Enum.Font.FredokaOne)
local FontRegular = Font.fromEnum(Enum.Font.FredokaOne)

-- Холдер
local Holder = Create("ScreenGui", {
    Parent = CoreGui,
    Name = "DarkHub",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    DisplayOrder = 2,
    ResetOnSpawn = false,
})

-- Контейнер для уведомлений
local NotificationHolder = Create("Frame", {
    Parent = Holder,
    Name = "Notifications",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BorderSizePixel = 0,
})

Create("UIListLayout", {
    Parent = NotificationHolder,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = NotificationHolder,
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
})

-- Список флагов
local Flags = {}
local SetFlags = {}

-- === ГЛАВНОЕ ОКНО ===
local MainFrame = Create("Frame", {
    Parent = Holder,
    Name = "MainFrame",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, MainWidth, 0, MainHeight),
    ClipsDescendants = false,
})

Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 10) })

-- Затемнение фона (Blur)
do
    local BlurPart = Create("Part", {
        Parent = Camera,
        Material = Enum.Material.Glass,
        Transparency = 1,
        Reflectance = 1,
        CastShadow = false,
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        Size = Vector3.new(1, 1, 1) * 0.01,
        Color = Color3.new(0, 0, 0),
    })
    
    local BlockMesh = Create("BlockMesh", { Parent = BlurPart })
    
    Create("DepthOfFieldEffect", {
        Parent = Lighting,
        Enabled = true,
        FarIntensity = 0,
        FocusDistance = 0,
        InFocusRadius = 1000,
        NearIntensity = 1,
    })
    
    RunService.RenderStepped:Connect(function()
        if MainFrame.Visible then
            local Corner0 = MainFrame.AbsolutePosition
            local Corner1 = Corner0 + MainFrame.AbsoluteSize
            
            local Ray0 = Camera:ScreenPointToRay(Corner0.X, Corner0.Y, 1)
            local Ray1 = Camera:ScreenPointToRay(Corner1.X, Corner1.Y, 1)
            
            local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
            local Normal = Camera.CFrame.LookVector
            
            local function GetPlanePosition(RayOrigin, RayDirection)
                local N = Normal
                local D = RayDirection
                local V = RayOrigin - Origin
                local Number = (N.X * V.X) + (N.Y * V.Y) + (N.Z * V.Z)
                local Den = (N.X * D.X) + (N.Y * D.Y) + (N.Z * D.Z)
                local A = -Number / Den
                return RayOrigin + (A * RayDirection)
            end
            
            local Position0 = GetPlanePosition(Ray0.Origin, Ray0.Direction)
            local Position1 = GetPlanePosition(Ray1.Origin, Ray1.Direction)
            
            Position0 = Camera.CFrame:PointToObjectSpace(Position0)
            Position1 = Camera.CFrame:PointToObjectSpace(Position1)
            
            local Size = Position1 - Position0
            local Center = (Position0 + Position1) / 2
            
            BlockMesh.Offset = Center
            BlockMesh.Scale = Size / 0.0101
            BlurPart.CFrame = Camera.CFrame
            BlurPart.Transparency = 0.97
        end
    end)
end

-- ИКОНКА В ГЛАВНОМ ОКНЕ
local Logo = Create("ImageLabel", {
    Parent = MainFrame,
    Name = "Logo",
    ImageColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 8, 0, 5),
    Image = DarkHubIcon,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 5,
})
Create("UICorner", { Parent = Logo, CornerRadius = UDim.new(0, 6) })

Create("TextLabel", {
    Parent = MainFrame,
    Name = "Title",
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 12,
    Position = UDim2.new(0, 40, 0, 5),
    Size = UDim2.new(0, 0, 0, 13),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 5,
})

Create("TextLabel", {
    Parent = MainFrame,
    Name = "SubTitle",
    Text = "Premium Cheat",
    TextColor3 = Theme.Text,
    TextTransparency = 0.4,
    BackgroundTransparency = 1,
    FontFace = FontRegular,
    TextSize = 9,
    Position = UDim2.new(0, 40, 0, 18),
    Size = UDim2.new(0, 0, 0, 11),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 5,
})

-- КНОПКА ЗАКРЫТИЯ
local CloseButton = Create("TextButton", {
    Parent = MainFrame,
    Name = "ElementBG",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -8, 0, 5),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 26, 0, 26),
    ZIndex = 5,
})

Create("UICorner", { Parent = CloseButton, CornerRadius = UDim.new(0, 6) })

local CloseText = Create("TextLabel", {
    Parent = CloseButton,
    Text = "×",
    TextColor3 = Theme.Text,
    TextTransparency = 0.3,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 20,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0.5, -1),
    AnchorPoint = Vector2.new(0.5, 0.5),
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 6,
})

local CloseAccent = Create("Frame", {
    Parent = CloseButton,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
})

Create("UICorner", { Parent = CloseAccent, CornerRadius = UDim.new(0, 6) })

local CloseGradient = Create("UIGradient", {
    Parent = CloseAccent,
    Name = "AccentGradient",
    Rotation = -115,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

CloseButton.MouseEnter:Connect(function()
    CreateTween(CloseAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
    })
    CloseText.TextTransparency = 0
end)

CloseButton.MouseLeave:Connect(function()
    CreateTween(CloseAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })
    CloseText.TextTransparency = 0.3
end)

CloseButton.MouseButton1Down:Connect(function()
    MainFrame.Visible = false
end)

-- ПОЛЕ ПОИСКА В ШАПКЕ
local HeaderSearchContainer = Create("Frame", {
    Parent = MainFrame,
    Name = "ElementBG",
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -40, 0, 5),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 130, 0, 26),
    ZIndex = 5,
})

Create("UICorner", { Parent = HeaderSearchContainer, CornerRadius = UDim.new(0, 6) })

local HeaderSearchInput = Create("TextBox", {
    Parent = HeaderSearchContainer,
    Text = "",
    PlaceholderText = "Search...",
    PlaceholderColor3 = Color3.fromRGB(130, 130, 130),
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 0),
    Size = UDim2.new(1, -12, 1, 0),
    FontFace = FontRegular,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 6,
})

-- Левая панель вкладок (Сайдбар)
local LeftTabs = Create("ScrollingFrame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.1,
    Size = UDim2.new(0, SidebarWidth, 1, -(HeaderHeight + FooterHeight)),
    Position = UDim2.new(0, 0, 0, HeaderHeight),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})

Create("UICorner", { Parent = LeftTabs, CornerRadius = UDim.new(0, 10) })

Create("UIListLayout", {
    Parent = LeftTabs,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = LeftTabs,
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
})

-- ПОДВАЛ (ПРОФИЛЬ ИГРОКА)
local ProfileFooter = Create("Frame", {
    Parent = MainFrame,
    Name = "ProfileFooter",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    Size = UDim2.new(0, SidebarWidth, 0, FooterHeight),
    Position = UDim2.new(0, 0, 1, -FooterHeight),
    BorderSizePixel = 0,
    ZIndex = 8,
})

Create("UICorner", { Parent = ProfileFooter, CornerRadius = UDim.new(0, 10) })

Create("Frame", {
    Parent = ProfileFooter,
    BackgroundColor3 = Theme.Outline,
    BackgroundTransparency = 0.4,
    Size = UDim2.new(1, -12, 0, 1),
    Position = UDim2.new(0.5, 0, 0, 0),
    AnchorPoint = Vector2.new(0.5, 0),
    BorderSizePixel = 0,
})

local AvatarImage = Create("ImageLabel", {
    Parent = ProfileFooter,
    Name = "Avatar",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 8, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    ZIndex = 9,
})

Create("UICorner", { Parent = AvatarImage, CornerRadius = UDim.new(1, 0) })

Create("TextLabel", {
    Parent = ProfileFooter,
    Name = "Username",
    Text = LocalPlayer.DisplayName,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 11,
    Position = UDim2.new(0, 40, 0.5, -6),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, SidebarWidth - 60, 0, 12),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 9,
})

Create("TextLabel", {
    Parent = ProfileFooter,
    Name = "Subtext",
    Text = "@" .. LocalPlayer.Name,
    TextColor3 = Theme.Text,
    TextTransparency = 0.5,
    BackgroundTransparency = 1,
    FontFace = FontRegular,
    TextSize = 9,
    Position = UDim2.new(0, 40, 0.5, 6),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, SidebarWidth - 60, 0, 10),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 9,
})

local ArrowIcon = Create("ImageLabel", {
    Parent = ProfileFooter,
    Name = "Arrow",
    Image = GetIconUri("130510492706892"),
    ImageColor3 = Theme.Text,
    ImageTransparency = 0.5,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(1, -10, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    Rotation = -90,
    ZIndex = 9,
})
Create("UICorner", { Parent = ArrowIcon, CornerRadius = UDim.new(0, 3) })

-- ИНДИКАТОР АКТИВНОЙ ВКЛАДКИ (БЕЛАЯ ПОЛОСКА)
local ActiveIndicator = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0, 3, 0, 19),
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 6, 0, 0),
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 10,
})

Create("UICorner", { Parent = ActiveIndicator, CornerRadius = UDim.new(1, 0) })

-- Контентная зона
local Content = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.5,
    Position = UDim2.new(0, SidebarWidth, 0, HeaderHeight),
    Size = UDim2.new(1, -SidebarWidth, 1, -HeaderHeight),
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

Create("UICorner", { Parent = Content, CornerRadius = UDim.new(0, 10) })

-- Контейнер для результатов глобального поиска
local GlobalSearchFrame = Create("ScrollingFrame", {
    Parent = Content,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    BorderSizePixel = 0,
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
})

Create("UICorner", { Parent = GlobalSearchFrame, CornerRadius = UDim.new(0, 10) })

local GlobalSearchContent = Create("Frame", {
    Parent = GlobalSearchFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -10, 0, 0),
    Position = UDim2.new(0, 5, 0, 5),
    AutomaticSize = Enum.AutomaticSize.Y,
})

Create("UIListLayout", {
    Parent = GlobalSearchContent,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Страницы
local Pages = {}
local CurrentPage = nil

-- ФУНКЦИЯ ДИНАМИЧЕСКОЙ СМЕНЫ ТЕМЫ
local isCustomAccent = false

local function ApplyAccentColor(color, gradientColor)
    Theme.Accent = color
    if not gradientColor then
        local h, s, v = color:ToHSV()
        Theme.AccentGradient = Color3.fromHSV(h, math.clamp(s - 0.2, 0, 1), math.clamp(v + 0.1, 0, 1))
    else
        Theme.AccentGradient = gradientColor
    end

    for _, desc in ipairs(Holder:GetDescendants()) do
        if desc:IsA("UIGradient") and desc.Name == "AccentGradient" then
            if desc.Parent and desc.Parent.Name == "FloatStroke" then
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(0.5, Theme.Outline),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient)
                })
            else
                desc.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient)
                })
            end
        elseif desc.Name == "TabButton" and desc.BackgroundTransparency < 1 then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent})
        elseif desc.Name == "AccentBar" or desc.Name == "FloatAccent" or desc.Name == "SliderFill" or desc.Name == "ThumbGlow" or desc.Name == "ThumbInner" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent})
        elseif desc.Name == "ThumbStroke" and desc:IsA("UIStroke") then
            CreateTween(desc, TweenInfo.new(0.3), {Color = Theme.Accent})
        end
    end
end



-- ФУНКЦИЯ ДИНАМИЧЕСКОЙ СМЕНЫ ТЕМЫ (ФОНА, ЭЛЕМЕНТОВ И СЕКЦИЙ)
local function ApplyTheme(themeName)
    local t = ThemesPresets[themeName]
    if not t then return end

    Theme.Background = t.Background
    Theme.Background2 = t.Background2
    Theme.SectionBackground = t.SectionBackground
    Theme.SectionBackground2 = t.SectionBackground2
    Theme.SectionTop = t.SectionTop
    Theme.Element = t.Element
    Theme.Outline = t.Outline
    Theme.Text = t.Text

    if not isCustomAccent then
        Theme.Accent = t.Accent
        Theme.AccentGradient = t.AccentGradient
    end

    CreateTween(MainFrame, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
    CreateTween(LeftTabs, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
    CreateTween(Content, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
    CreateTween(ProfileFooter, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
    CreateTween(HeaderSearchContainer, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Element})
    CreateTween(CloseButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Element})

    local FloatHeader = Holder:FindFirstChild("DarkHubToggleHeader")
    if FloatHeader then
        CreateTween(FloatHeader, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
    end

    for _, desc in ipairs(Holder:GetDescendants()) do
        if desc.Name == "SectionTopBg" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.SectionTop})
        elseif desc.Name == "SectionContent" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.SectionBackground})
        elseif desc.Name == "SectionFrame" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.SectionBackground2})
        elseif desc.Name == "SectionTop" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Outline})
        elseif desc.Name == "ElementBG" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Element})
        elseif desc.Name == "DropdownList" or desc.Name == "ColorPicker" then
            CreateTween(desc, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background})
        elseif desc:IsA("UIStroke") and desc.Name ~= "StatusDotStroke" then
            CreateTween(desc, TweenInfo.new(0.3), {Color = Theme.Outline})
        end
    end

    ApplyAccentColor(Theme.Accent, Theme.AccentGradient)
end



-- Обновление позиции белой полоски
local function UpdateActiveIndicator(instant)
    if not CurrentPage or not CurrentPage.TabButton then return end
    local TabButton = CurrentPage.TabButton
    if TabButton.AbsoluteSize.Y == 0 or MainFrame.AbsoluteSize.Y == 0 then return end

    local TargetY = TabButton.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y + (TabButton.AbsoluteSize.Y / 2)
    local TargetPos = UDim2.new(0, 6, 0, TargetY)

    if not ActiveIndicator.Visible then
        ActiveIndicator.Position = TargetPos
        ActiveIndicator.Visible = true
    elseif instant then
        ActiveIndicator.Position = TargetPos
    else
        CreateTween(ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = TargetPos
        })
    end
end

LeftTabs:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    UpdateActiveIndicator(true)
end)

MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateActiveIndicator(true)
end)

-- Глобальная система поиска
local function GlobalSearch(Query)
    local CleanQuery = CleanString(Query)

    if CleanQuery == "" then
        GlobalSearchFrame.Visible = false
        
        for _, Page in ipairs(Pages) do
            for _, Section in ipairs(Page.Sections) do
                Section.Frame.Parent = Section.OriginalParent
                Section.Frame.Visible = true
                for _, Element in ipairs(Section.Elements) do
                    if Element.Frame then
                        Element.Frame.Visible = true
                    end
                end
            end
        end

        if CurrentPage then
            CurrentPage.Frame.Visible = true
        end
    else
        if CurrentPage then
            CurrentPage.Frame.Visible = false
        end
        GlobalSearchFrame.Visible = true

        for _, Page in ipairs(Pages) do
            for _, Section in ipairs(Page.Sections) do
                local CleanSectionName = CleanString(Section.Name)
                local SectionMatch = (CleanSectionName ~= "") and (string.find(CleanSectionName, CleanQuery, 1, true) ~= nil)
                local HasAnyElementMatch = false

                for _, Element in ipairs(Section.Elements) do
                    local CleanElementName = CleanString(Element.Name)
                    local ElementMatch = (CleanElementName ~= "") and (string.find(CleanElementName, CleanQuery, 1, true) ~= nil)
                    local IsVisible = SectionMatch or ElementMatch

                    if Element.Frame then
                        Element.Frame.Visible = IsVisible
                    end

                    if IsVisible then
                        HasAnyElementMatch = true
                    end
                end

                if SectionMatch or HasAnyElementMatch then
                    Section.Frame.Parent = GlobalSearchContent
                    Section.Frame.Visible = true
                else
                    Section.Frame.Visible = false
                    Section.Frame.Parent = Section.OriginalParent
                end
            end
        end
    end
end

HeaderSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    GlobalSearch(HeaderSearchInput.Text)
end)

local function CreatePage(PageConfig)
    local PageName = PageConfig.Name or "Page"
    local PageIcon = PageConfig.Icon or "100050851789190"
    
    local TabButton = Create("TextButton", {
        Parent = LeftTabs,
        Name = "TabButton",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    
    Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 8) })
    
    local TabIcon = Create("ImageLabel", {
        Parent = TabButton,
        Image = GetIconUri(PageIcon),
        ImageColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    })
    Create("UICorner", { Parent = TabIcon, CornerRadius = UDim.new(0, 4) })
    
    local TabLabel = Create("TextLabel", {
        Parent = TabButton,
        Text = PageName,
        TextColor3 = Theme.Text,
        TextTransparency = 0.5,
        BackgroundTransparency = 1,
        FontFace = FontRegular,
        TextSize = 11,
        Position = UDim2.new(0, 36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -52, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local DotsContainer = Create("Frame", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 3, 0, 13),
        BorderSizePixel = 0,
    })

    Create("UIListLayout", {
        Parent = DotsContainer,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    for i = 1, 3 do
        local Dot = Create("Frame", {
            Parent = DotsContainer,
            BackgroundColor3 = Theme.Text,
            BackgroundTransparency = 0.6,
            Size = UDim2.new(0, 3, 0, 3),
            BorderSizePixel = 0,
            LayoutOrder = i,
        })
        Create("UICorner", { Parent = Dot, CornerRadius = UDim.new(1, 0) })
    end
    
    local PageFrame = Create("ScrollingFrame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        BorderSizePixel = 0,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
    })
    
    Create("UICorner", { Parent = PageFrame, CornerRadius = UDim.new(0, 10) })
    
    local PageContent = Create("Frame", {
        Parent = PageFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 5),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    Create("UIListLayout", {
        Parent = PageContent,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    local PageData = {
        Name = PageName,
        Frame = PageFrame,
        Content = PageContent,
        TabButton = TabButton,
        TabLabel = TabLabel,
        Sections = {},
        Active = false,
    }
    
    TabButton.MouseEnter:Connect(function()
        if not PageData.Active then
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.92
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.25
            })
        end
    end)

    TabButton.MouseLeave:Connect(function()
        if not PageData.Active then
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.5
            })
        end
    end)
    
    local function SetActive(Active)
        if Active == PageData.Active and not GlobalSearchFrame.Visible then return end
        
        if HeaderSearchInput.Text ~= "" then
            HeaderSearchInput.Text = ""
        end

        if Active then
            if CurrentPage then
                CurrentPage.Active = false
                CurrentPage.Frame.Visible = false
                CreateTween(CurrentPage.TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                CreateTween(CurrentPage.TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 0.5
                })
                CurrentPage.TabLabel.FontFace = FontRegular
            end
            
            PageData.Active = true
            PageData.Frame.Visible = true
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.88
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0
            })
            PageData.TabLabel.FontFace = FontSemiBold
            CurrentPage = PageData

            UpdateActiveIndicator(false)
        else
            PageData.Active = false
            PageData.Frame.Visible = false
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.5
            })
            PageData.TabLabel.FontFace = FontRegular
        end
    end
    
    TabButton.MouseButton1Down:Connect(function()
        SetActive(true)
    end)
    
    PageData.SetActive = SetActive
    
    local function CreateSection(SectionConfig)
        local SectionName = SectionConfig.Name or "Section"
        local SectionDesc = SectionConfig.Description or ""
        local SectionIcon = SectionConfig.Icon
        
        local SectionFrame = Create("Frame", {
            Parent = PageContent,
            Name = "SectionFrame",
            BackgroundColor3 = Theme.SectionBackground2,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = false,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 8) })
        
        local SectionTop = Create("Frame", {
            Parent = SectionFrame,
            Name = "SectionTop",
            BackgroundColor3 = Theme.Outline,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionTop, CornerRadius = UDim.new(0, 8) })

        local SectionTopBg = Create("Frame", {
            Parent = SectionTop,
            Name = "SectionTopBg",
            BackgroundColor3 = Theme.SectionTop,
            BackgroundTransparency = 0.3,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionTopBg, CornerRadius = UDim.new(0, 7) })
        
        local AccentBar = Create("Frame", {
            Parent = SectionTopBg,
            Name = "AccentBar",
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 2, 0, 10),
            Position = UDim2.new(0, 6, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = AccentBar, CornerRadius = UDim.new(1, 0) })
        
        local TextXOffset = 14
        if SectionIcon then
            local SecImg = Create("ImageLabel", {
                Parent = SectionTopBg,
                Image = GetIconUri(SectionIcon),
                ImageColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 12, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
            })
            Create("UICorner", { Parent = SecImg, CornerRadius = UDim.new(0, 3) })
            TextXOffset = 28
        end

        Create("TextLabel", {
            Parent = SectionTopBg,
            Text = SectionName,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            FontFace = FontSemiBold,
            TextSize = 11,
            Position = UDim2.new(0, TextXOffset, 0.5, SectionDesc ~= "" and -5 or 0),
            AnchorPoint = Vector2.new(0, SectionDesc ~= "" and 0 or 0.5),
            Size = UDim2.new(0, 0, 0, 12),
            AutomaticSize = Enum.AutomaticSize.X,
        })
        
        if SectionDesc ~= "" then
            Create("TextLabel", {
                Parent = SectionTopBg,
                Text = SectionDesc,
                TextColor3 = Theme.Text,
                TextTransparency = 0.4,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 9,
                Position = UDim2.new(0, TextXOffset, 0, 13),
                Size = UDim2.new(0, 0, 0, 10),
                AutomaticSize = Enum.AutomaticSize.X,
            })
        end
        
        local SectionContent = Create("Frame", {
            Parent = SectionFrame,
            Name = "SectionContent",
            BackgroundColor3 = Theme.SectionBackground,
            BackgroundTransparency = 0.4,
            Position = UDim2.new(0, 1, 0, 27),
            Size = UDim2.new(1, -2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionContent, CornerRadius = UDim.new(0, 7) })
        
        Create("UIListLayout", {
            Parent = SectionContent,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        Create("UIPadding", {
            Parent = SectionContent,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        })
        
        local SectionData = {
            Name = SectionName,
            Frame = SectionFrame,
            OriginalParent = PageContent,
            Content = SectionContent,
            Elements = {},
        }
        
        -- Toggle
        function SectionData:Toggle(Data)
            local ToggleName = Data.Name or "Toggle"
            local Flag = Data.Flag or "toggle_" .. (#Flags + 1)
            local Default = Data.Default or false
            local Callback = Data.Callback or function() end
            
            local ToggleFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                BorderSizePixel = 0,
            })
            
            local ToggleButton = Create("TextButton", {
                Parent = ToggleFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
            })
            
            local Indicator = Create("Frame", {
                Parent = ToggleFrame,
                Name = "ElementBG",
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(0, 4) })
            
            local Accent = Create("Frame", {
                Parent = Indicator,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            
            Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(0, 4) })
            
            Create("UIGradient", {
                Parent = Accent,
                Name = "AccentGradient",
                Rotation = -115,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                })
            })
            
            local CheckImage = Create("ImageLabel", {
                Parent = Accent,
                Image = GetIconUri("121760666525660"),
                ImageColor3 = Theme.Text,
                ImageTransparency = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            Create("UICorner", { Parent = CheckImage, CornerRadius = UDim.new(0, 2) })
            
            Create("TextLabel", {
                Parent = ToggleFrame,
                Text = ToggleName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 20, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -22, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local Value = Default
            
            local function SetValue(NewValue)
                Value = NewValue
                Flags[Flag] = Value
                
                if Value then
                    CreateTween(Accent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                    })
                    CreateTween(CheckImage, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        ImageTransparency = 0,
                        Size = UDim2.new(0, 8, 0, 7),
                    })
                else
                    CreateTween(Accent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                    })
                    CreateTween(CheckImage, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        ImageTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                    })
                end
                
                Callback(Value)
            end
            
            ToggleButton.MouseButton1Down:Connect(function()
                SetValue(not Value)
            end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            table.insert(SectionData.Elements, { Frame = ToggleFrame, Name = ToggleName })
            return { Set = SetValue, Get = function() return Value end }
        end
        
        -- Button
        function SectionData:Button(Data)
            local ButtonName = Data.Name or "Button"
            local Icon = Data.Icon
            local Callback = Data.Callback or function() end
            
            local ButtonFrame = Create("TextButton", {
                Parent = SectionContent,
                Name = "ElementBG",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 26),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 6) })
            
            local Accent = Create("Frame", {
                Parent = ButtonFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            
            Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(0, 6) })
            
            Create("UIGradient", {
                Parent = Accent,
                Name = "AccentGradient",
                Rotation = -115,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                })
            })
            
            local ButtonText = Create("TextLabel", {
                Parent = ButtonFrame,
                Text = ButtonName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.2,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -10, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            if Icon then
                local BtnIcon = Create("ImageLabel", {
                    Parent = ButtonText,
                    Image = GetIconUri(Icon),
                    ImageColor3 = Theme.Text,
                    ImageTransparency = 0.3,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                })
                Create("UICorner", { Parent = BtnIcon, CornerRadius = UDim.new(0, 3) })
            end
            
            ButtonFrame.MouseEnter:Connect(function()
                CreateTween(Accent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 0,
                })
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                CreateTween(Accent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                })
            end)
            
            ButtonFrame.MouseButton1Down:Connect(function()
                CreateTween(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Accent,
                })
                task.wait(0.1)
                CreateTween(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Element,
                })
                Callback()
            end)
            
            table.insert(SectionData.Elements, { Frame = ButtonFrame, Name = ButtonName })
            return ButtonFrame
        end
        
        -- Slider
        function SectionData:Slider(Data)
            local SliderName = Data.Name or "Slider"
            local Flag = Data.Flag or "slider_" .. (#Flags + 1)
            local Min = Data.Min or 0
            local Max = Data.Max or 100
            local Default = Data.Default or 0
            local Suffix = Data.Suffix or ""
            local Decimals = Data.Decimals or 1
            local Callback = Data.Callback or function() end
            
            local SliderFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                BorderSizePixel = 0,
            })
            
            -- Заголовок и значение
            local LabelFrame = Create("Frame", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                BorderSizePixel = 0,
            })
            
            local NameLabel = Create("TextLabel", {
                Parent = LabelFrame,
                Text = SliderName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            local ValueText = Create("TextLabel", {
                Parent = LabelFrame,
                Text = tostring(Default) .. Suffix,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            -- Контейнер слайдера
            local SliderTrack = Create("Frame", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 10),
                Position = UDim2.new(0, 0, 1, -10),
                BorderSizePixel = 0,
                ClipsDescendants = false,
            })
            
            -- Фон слайдера
            local SliderBar = Create("Frame", {
                Parent = SliderTrack,
                Name = "ElementBG",
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            Create("UICorner", { Parent = SliderBar, CornerRadius = UDim.new(1, 0) })
            
            -- Заполнение полосы
            local SliderFill = Create("Frame", {
                Parent = SliderBar,
                Name = "SliderFill",
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
            })
            Create("UICorner", { Parent = SliderFill, CornerRadius = UDim.new(1, 0) })
            
            Create("UIGradient", {
                Parent = SliderFill,
                Name = "AccentGradient",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                }),
                Rotation = 90,
            })
            
            -- КРУГЛЯШОК (РУЧКА)
            local Thumb = Create("Frame", {
                Parent = SliderTrack,
                BackgroundColor3 = Theme.Text,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BorderSizePixel = 0,
                ZIndex = 2,
            })
            Create("UICorner", { Parent = Thumb, CornerRadius = UDim.new(1, 0) })
            
            -- Эффекты кругляшка
            local ThumbGlow = Create("Frame", {
                Parent = Thumb,
                Name = "ThumbGlow",
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.25,
                Size = UDim2.new(2, 0, 2, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BorderSizePixel = 0,
                ZIndex = 0,
            })
            Create("UICorner", { Parent = ThumbGlow, CornerRadius = UDim.new(1, 0) })
            
            local ThumbInner = Create("Frame", {
                Parent = Thumb,
                Name = "ThumbInner",
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(0.6, 0, 0.6, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BorderSizePixel = 0,
                ZIndex = 3,
            })
            Create("UICorner", { Parent = ThumbInner, CornerRadius = UDim.new(1, 0) })
            
            Create("UIGradient", {
                Parent = ThumbInner,
                Name = "AccentGradient",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                }),
                Rotation = 45,
            })
            
            Create("UIStroke", {
                Parent = Thumb,
                Name = "ThumbStroke",
                Color = Theme.Accent,
                Thickness = 2,
                Transparency = 0.4,
            })
            
            local ThumbHighlight = Create("Frame", {
                Parent = Thumb,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.6,
                Size = UDim2.new(0.3, 0, 0.3, 0),
                Position = UDim2.new(0.2, 0, 0.2, 0),
                BorderSizePixel = 0,
                ZIndex = 4,
            })
            Create("UICorner", { Parent = ThumbHighlight, CornerRadius = UDim.new(1, 0) })
            
            -- Зона клика и перетаскивания
            local DragButton = Create("TextButton", {
                Parent = SliderTrack,
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex = 3,
            })
            
            local Value = Default
            local Sliding = false
            
            -- Обновление позиции кругляшка по Scale (в процентах)
            local function UpdateSlider(percent)
                percent = math.clamp(percent, 0, 1)
                Thumb.Position = UDim2.new(percent, 0, 0.5, 0)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            end
            
            local function SetValue(NewValue)
                local rawValue = math.clamp(NewValue, Min, Max)
                local multiplier = 10 ^ Decimals
                Value = math.round(rawValue * multiplier) / multiplier
                
                local percent = (Max > Min) and ((Value - Min) / (Max - Min)) or 0
                UpdateSlider(percent)
                ValueText.Text = tostring(Value) .. Suffix
                
                Flags[Flag] = Value
                Callback(Value)
            end
            
            local function UpdateFromMouse(input)
                if not SliderBar or not SliderBar.AbsoluteSize or SliderBar.AbsoluteSize.X <= 0 then return end
                local barPos = SliderBar.AbsolutePosition.X
                local barWidth = SliderBar.AbsoluteSize.X
                
                local x = (input.Position.X - barPos) / barWidth
                local percent = math.clamp(x, 0, 1)
                local newValue = Min + (Max - Min) * percent
                SetValue(newValue)
            end
            
            DragButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Sliding = true
                    UpdateFromMouse(input)
                    
                    CreateTween(Thumb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 18, 0, 18),
                    })
                end
            end)
            
            DragButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Sliding = false
                    CreateTween(Thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 16, 0, 16),
                    })
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateFromMouse(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if Sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    Sliding = false
                    CreateTween(Thumb, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 16, 0, 16),
                    })
                end
            end)
            
            SetValue(Default)
            SetFlags[Flag] = function(val) SetValue(val) end
            
            table.insert(SectionData.Elements, { Frame = SliderFrame, Name = SliderName })
            return {
                Set = function(val) SetValue(val) end,
                Get = function() return Value end,
            }
        end

        -- Dropdown
        function SectionData:Dropdown(Data)
            local DropdownName = Data.Name or "Dropdown"
            local Flag = Data.Flag or "dropdown_" .. (#Flags + 1)
            local Items = Data.Items or {"Option 1", "Option 2", "Option 3"}
            local Default = Data.Default
            local Callback = Data.Callback or function() end
            
            local DropdownFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = DropdownFrame,
                Text = DropdownName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.45, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local DropdownButton = Create("TextButton", {
                Parent = DropdownFrame,
                Name = "ElementBG",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = DropdownButton, CornerRadius = UDim.new(0, 6) })
            
            local DropdownValue = Create("TextLabel", {
                Parent = DropdownButton,
                Text = "...",
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 6, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -18, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local DropIcon = Create("ImageLabel", {
                Parent = DropdownButton,
                Image = GetIconUri("123317177279443"),
                ImageColor3 = Color3.fromRGB(141, 141, 150),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 8, 0, 4),
                Position = UDim2.new(1, -6, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
            })
            Create("UICorner", { Parent = DropIcon, CornerRadius = UDim.new(0, 2) })
            
            local DropdownList = Create("Frame", {
                Parent = Holder,
                Name = "DropdownList",
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 100, 0, 100),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = DropdownList, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = DropdownList, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = DropdownList,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ZIndex = 101,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Options = {}
            local Selected = nil
            local IsOpen = false
            
            local function UpdatePosition()
                local Pos = DropdownButton.AbsolutePosition
                local Size = DropdownButton.AbsoluteSize
                DropdownList.Position = UDim2.new(0, Pos.X, 0, Pos.Y + Size.Y + 3)
                DropdownList.Size = UDim2.new(0, Size.X, 0, math.min(110, #Items * 20 + 4))
            end
            
            local function SetOpen(Open)
                IsOpen = Open
                DropdownList.Visible = Open
                if Open then UpdatePosition() end
            end
            
            local function SetValue(Option)
                Selected = Option
                DropdownValue.Text = Option
                Flags[Flag] = Option
                Callback(Option)
                SetOpen(false)
            end
            
            for _, Item in ipairs(Items) do
                local OptionButton = Create("TextButton", {
                    Parent = ListScroller,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                })
                
                Create("TextLabel", {
                    Parent = OptionButton,
                    Text = Item,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.3,
                    BackgroundTransparency = 1,
                    FontFace = FontRegular,
                    TextSize = 11,
                    Position = UDim2.new(0, 5, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -5, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 103,
                })
                
                Options[Item] = OptionButton
                OptionButton.MouseButton1Down:Connect(function() SetValue(Item) end)
            end
            
            DropdownButton.MouseButton1Down:Connect(function() SetOpen(not IsOpen) end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    local mX, mY = Input.Position.X, Input.Position.Y
                    local lPos, lSize = DropdownList.AbsolutePosition, DropdownList.AbsoluteSize
                    local bPos, bSize = DropdownButton.AbsolutePosition, DropdownButton.AbsoluteSize

                    local inList = (mX >= lPos.X and mX <= lPos.X + lSize.X and mY >= lPos.Y and mY <= lPos.Y + lSize.Y)
                    local inBtn = (mX >= bPos.X and mX <= bPos.X + bSize.X and mY >= bPos.Y and mY <= bPos.Y + bSize.Y)

                    if not inList and not inBtn then
                        SetOpen(false)
                    end
                end
            end)
            
            if Default and Options[Default] then SetValue(Default) end
            
            SetFlags[Flag] = function(Val) if Options[Val] then SetValue(Val) end end
            
            table.insert(SectionData.Elements, { Frame = DropdownFrame, Name = DropdownName })
            return {
                Set = function(Val) if Options[Val] then SetValue(Val) end end,
                Get = function() return Selected end,
                SetOpen = SetOpen,
                IsOpen = function() return IsOpen end,
            }
        end
        
        -- Keybind
        function SectionData:Keybind(Data)
            local KeybindName = Data.Name or "Keybind"
            local Flag = Data.Flag or "keybind_" .. (#Flags + 1)
            local Default = Data.Default or Enum.KeyCode.Z
            local Callback = Data.Callback or function() end
            
            local KeybindFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = KeybindFrame,
                Text = KeybindName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.6, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local KeybindButton = Create("TextButton", {
                Parent = KeybindFrame,
                Name = "ElementBG",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = KeybindButton, CornerRadius = UDim.new(0, 6) })
            
            local KeybindValue = Create("TextLabel", {
                Parent = KeybindButton,
                Text = "None",
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -4, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            local Key = Default
            local Picking = false
            
            local KeyNames = {
                ["LeftShift"] = "LShift",
                ["RightShift"] = "RShift",
                ["LeftControl"] = "LCtrl",
                ["RightControl"] = "RCtrl",
                ["LeftAlt"] = "LAlt",
                ["RightAlt"] = "RAlt",
                ["Backspace"] = "None",
            }
            
            local function GetKeyName(KeyCode)
                if type(KeyCode) == "string" then return KeyNames[KeyCode] or KeyCode end
                return KeyNames[KeyCode.Name] or KeyCode.Name
            end
            
            local function SetKey(NewKey)
                Key = NewKey
                KeybindValue.Text = GetKeyName(NewKey)
                Flags[Flag] = NewKey
                Picking = false
                Callback(NewKey)
            end
            
            KeybindButton.MouseButton1Down:Connect(function()
                if Picking then SetKey(Key) return end
                Picking = true
                KeybindValue.Text = "..."
                
                local Connection
                Connection = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        SetKey(Input.KeyCode)
                        Connection:Disconnect()
                    end
                end)
            end)
            
            SetKey(Default)
            SetFlags[Flag] = SetKey
            
            table.insert(SectionData.Elements, { Frame = KeybindFrame, Name = KeybindName })
            return { Set = SetKey, Get = function() return Key end }
        end
        
        -- Textbox
        function SectionData:Textbox(Data)
            local TextboxName = Data.Name or "Textbox"
            local Flag = Data.Flag or "textbox_" .. (#Flags + 1)
            local Placeholder = Data.Placeholder or "Enter text..."
            local Default = Data.Default or ""
            local Numeric = Data.Numeric or false
            local Callback = Data.Callback or function() end
            
            local TextboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = TextboxFrame,
                Text = TextboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.4, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local TextboxInput = Create("TextBox", {
                Parent = TextboxFrame,
                Name = "ElementBG",
                Text = "",
                PlaceholderText = Placeholder,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = TextboxInput, CornerRadius = UDim.new(0, 6) })
            Create("UIPadding", { Parent = TextboxInput, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
            
            local Value = Default
            
            local function SetValue(NewValue)
                if Numeric and NewValue ~= "" and not tonumber(NewValue) then return end
                Value = NewValue
                TextboxInput.Text = NewValue
                Flags[Flag] = NewValue
                Callback(NewValue)
            end
            
            TextboxInput:GetPropertyChangedSignal("Text"):Connect(function() SetValue(TextboxInput.Text) end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            table.insert(SectionData.Elements, { Frame = TextboxFrame, Name = TextboxName })
            return { Set = SetValue, Get = function() return Value end }
        end
        
        -- Colorpicker
        function SectionData:Colorpicker(Data)
            local ColorpickerName = Data.Name or "Colorpicker"
            local Flag = Data.Flag or "color_" .. (#Flags + 1)
            local Default = Data.Default or Color3.new(1, 1, 1)
            local Callback = Data.Callback or function() end
            
            local ColorFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ColorFrame,
                Text = ColorpickerName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.55, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorButton = Create("TextButton", {
                Parent = ColorFrame,
                Name = "ElementBG",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 65, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ColorButton, CornerRadius = UDim.new(0, 6) })
            
            local ColorPreview = Create("Frame", {
                Parent = ColorButton,
                BackgroundColor3 = Default,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 5, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ColorPreview, CornerRadius = UDim.new(1, 0) })
            
            local ColorValue = Create("TextLabel", {
                Parent = ColorButton,
                Text = "#" .. Default:ToHex(),
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 10,
                Position = UDim2.new(0, 20, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -22, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorPicker = Create("Frame", {
                Parent = Holder,
                Name = "ColorPicker",
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 160, 0, 170),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = ColorPicker, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = ColorPicker, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local Palette = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 0, 0),
                Size = UDim2.new(1, -12, 1, -65),
                Position = UDim2.new(0, 6, 0, 6),
                BorderSizePixel = 0,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = Palette, CornerRadius = UDim.new(0, 5) })
            
            local SatOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 102,
            })
            
            Create("UICorner", { Parent = SatOverlay, CornerRadius = UDim.new(0, 5) })
            
            Create("UIGradient", {
                Parent = SatOverlay,
                Name = "SatGradient",
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
            })
            
            local ValOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 103,
            })
            
            Create("UICorner", { Parent = ValOverlay, CornerRadius = UDim.new(0, 5) })
            
            Create("UIGradient", {
                Parent = ValOverlay,
                Name = "ValGradient",
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            })
            
            local Cursor = Create("Frame", {
                Parent = Palette,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 104,
            })
            
            Create("UIStroke", { Parent = Cursor, Color = Color3.new(1, 1, 1), Thickness = 1.5 })
            Create("UICorner", { Parent = Cursor, CornerRadius = UDim.new(1, 0) })
            
            local HueSlider = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, -12, 0, 8),
                Position = UDim2.new(0, 6, 1, -48),
                BorderSizePixel = 0,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = HueSlider, CornerRadius = UDim.new(1, 0) })
            
            Create("UIGradient", {
                Parent = HueSlider,
                Name = "HueGradient",
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                })
            })
            
            local HueCursor = Create("Frame", {
                Parent = HueSlider,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(0, 5, 0, 10),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BorderSizePixel = 0,
                ZIndex = 103,
            })
            
            Create("UICorner", { Parent = HueCursor, CornerRadius = UDim.new(1, 0) })
            Create("UIStroke", { Parent = HueCursor, Color = Color3.new(0, 0, 0), Thickness = 1 })
            
            local HexInput = Create("TextBox", {
                Parent = ColorPicker,
                Name = "ElementBG",
                Text = "#" .. Default:ToHex(),
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 75, 0, 18),
                Position = UDim2.new(1, -6, 1, -6),
                AnchorPoint = Vector2.new(1, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = HexInput, CornerRadius = UDim.new(0, 5) })
            Create("UIPadding", { Parent = HexInput, PaddingLeft = UDim.new(0, 4) })
            
            Create("TextLabel", {
                Parent = ColorPicker,
                Text = "Hex:",
                TextColor3 = Theme.Text,
                TextTransparency = 0.5,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 10,
                Position = UDim2.new(0, 6, 1, -6),
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(0, 22, 0, 18),
                ZIndex = 101,
            })
            
            local Color = Default
            local Hue, Sat, Val = Default:ToHSV()
            local IsOpen = false
            local DraggingPalette = false
            local DraggingHue = false
            
            local function UpdateColor(H, S, V)
                Hue = H or Hue
                Sat = S or Sat
                Val = V or Val
                Color = Color3.fromHSV(Hue, Sat, Val)
                ColorPreview.BackgroundColor3 = Color
                ColorValue.Text = "#" .. Color:ToHex()
                Palette.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                HexInput.Text = "#" .. Color:ToHex()
                Flags[Flag] = Color
                Callback(Color)
            end

            local function SyncCursors()
                Cursor.Position = UDim2.new(math.clamp(Sat, 0, 1), -3, math.clamp(1 - Val, 0, 1), -3)
                HueCursor.Position = UDim2.new(math.clamp(Hue, 0, 1), 0, 0.5, 0)
            end
            
            local function UpdatePosition()
                local Pos = ColorButton.AbsolutePosition
                local Size = ColorButton.AbsoluteSize
                ColorPicker.Position = UDim2.new(0, Pos.X - 85, 0, Pos.Y + Size.Y + 3)
                ColorPicker.Visible = IsOpen
            end
            
            local function SetOpen(Open)
                IsOpen = Open
                if Open then
                    UpdatePosition()
                    ColorPicker.Visible = true
                else
                    ColorPicker.Visible = false
                end
            end
            
            Palette.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingPalette = true
                    local X = math.clamp((Input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                    local Y = math.clamp((Input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                    Sat = X
                    Val = 1 - Y
                    Cursor.Position = UDim2.new(X, -3, Y, -3)
                    UpdateColor()
                end
            end)
            
            Palette.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingPalette = false
                end
            end)
            
            HueSlider.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = true
                    local X = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    Hue = X
                    HueCursor.Position = UDim2.new(X, 0, 0.5, 0)
                    UpdateColor()
                end
            end)
            
            HueSlider.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if DraggingPalette and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local X = math.clamp((Input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                    local Y = math.clamp((Input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                    Sat = X
                    Val = 1 - Y
                    Cursor.Position = UDim2.new(X, -3, Y, -3)
                    UpdateColor()
                end
                if DraggingHue and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local X = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    Hue = X
                    HueCursor.Position = UDim2.new(X, 0, 0.5, 0)
                    UpdateColor()
                end
            end)
            
            HexInput.FocusLost:Connect(function()
                local Hex = HexInput.Text:gsub("#", "")
                local Success, NewColor = pcall(Color3.fromHex, Hex)
                if Success then
                    local H, S, V = NewColor:ToHSV()
                    Hue, Sat, Val = H, S, V
                    SyncCursors()
                    UpdateColor()
                end
            end)
            
            ColorButton.MouseButton1Down:Connect(function() SetOpen(not IsOpen) end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    local mX, mY = Input.Position.X, Input.Position.Y
                    local lPos, lSize = ColorPicker.AbsolutePosition, ColorPicker.AbsoluteSize
                    local bPos, bSize = ColorButton.AbsolutePosition, ColorButton.AbsoluteSize

                    local inPicker = (mX >= lPos.X and mX <= lPos.X + lSize.X and mY >= lPos.Y and mY <= lPos.Y + lSize.Y)
                    local inBtn = (mX >= bPos.X and mX <= bPos.X + bSize.X and mY >= bPos.Y and mY <= bPos.Y + bSize.Y)

                    if not inPicker and not inBtn then
                        SetOpen(false)
                    end
                end
            end)
            
            SyncCursors()
            UpdateColor()
            
            SetFlags[Flag] = function(NewColor)
                if type(NewColor) == "Color3" then
                    local H, S, V = NewColor:ToHSV()
                    Hue, Sat, Val = H, S, V
                    SyncCursors()
                    UpdateColor()
                end
            end
            
            table.insert(SectionData.Elements, { Frame = ColorFrame, Name = ColorpickerName })
            return { Set = SetFlags[Flag], Get = function() return Color end, SetOpen = SetOpen, IsOpen = function() return IsOpen end }
        end
        
        -- Listbox
        function SectionData:Listbox(Data)
            local ListboxName = Data.Name or "Listbox"
            local Flag = Data.Flag or "listbox_" .. (#Flags + 1)
            local Items = Data.Items or {"Item 1", "Item 2", "Item 3"}
            local Default = Data.Default
            local Multi = Data.Multi or false
            local Callback = Data.Callback or function() end
            
            local ListboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ListboxFrame,
                Text = ListboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            local SearchBox = Create("TextBox", {
                Parent = ListboxFrame,
                Name = "ElementBG",
                Text = "",
                PlaceholderText = "Search...",
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 1, -20),
                AnchorPoint = Vector2.new(0, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = SearchBox, CornerRadius = UDim.new(0, 5) })
            Create("UIPadding", { Parent = SearchBox, PaddingLeft = UDim.new(0, 5) })
            
            local ListContainer = Create("Frame", {
                Parent = ListboxFrame,
                Name = "ElementBG",
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 36),
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            
            Create("UICorner", { Parent = ListContainer, CornerRadius = UDim.new(0, 5) })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = ListContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Selected = {}
            local FilteredItems = {}
            
            local function UpdateListHeight()
                local Count = #FilteredItems
                local Height = math.min(75, Count * 18 + 4)
                ListContainer.Size = UDim2.new(1, 0, 0, Height)
                ListboxFrame.Size = UDim2.new(1, 0, 0, 36 + Height)
            end
            
            local function FilterItems(Query)
                local CleanQ = CleanString(Query)
                FilteredItems = {}
                for _, Item in ipairs(Items) do
                    if CleanQ == "" or string.find(CleanString(Item), CleanQ, 1, true) then
                        table.insert(FilteredItems, Item)
                    end
                end
                
                for _, Child in ipairs(ListScroller:GetChildren()) do
                    if Child:IsA("TextButton") then Child:Destroy() end
                end
                
                for _, Item in ipairs(FilteredItems) do
                    local OptionButton = Create("TextButton", {
                        Parent = ListScroller,
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderSizePixel = 0,
                    })
                    
                    local OptionText = Create("TextLabel", {
                        Parent = OptionButton,
                        Text = Item,
                        TextColor3 = Theme.Text,
                        TextTransparency = 0.3,
                        BackgroundTransparency = 1,
                        FontFace = FontRegular,
                        TextSize = 10,
                        Position = UDim2.new(0, 5, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(1, -5, 0, 11),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    if table.find(Selected, Item) then
                        OptionText.TextTransparency = 0
                        OptionText.Position = UDim2.new(0, 8, 0.5, 0)
                    end
                    
                    OptionButton.MouseButton1Down:Connect(function()
                        if Multi then
                            local Index = table.find(Selected, Item)
                            if Index then table.remove(Selected, Index) else table.insert(Selected, Item) end
                        else
                            Selected = {Item}
                        end
                        Flags[Flag] = table.clone(Selected)
                        Callback(table.clone(Selected))
                        FilterItems(SearchBox.Text)
                    end)
                end
                
                UpdateListHeight()
            end
            
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function() FilterItems(SearchBox.Text) end)
            FilterItems("")
            
            if Default then
                local ItemsList = type(Default) == "table" and Default or {Default}
                for _, Item in ipairs(ItemsList) do
                    if table.find(Items, Item) and not table.find(Selected, Item) then
                        table.insert(Selected, Item)
                    end
                end
                Flags[Flag] = table.clone(Selected)
                Callback(table.clone(Selected))
                FilterItems(SearchBox.Text)
            end
            
            SetFlags[Flag] = function(Value)
                Selected = type(Value) == "table" and table.clone(Value) or {Value}
                FilterItems(SearchBox.Text)
                Callback(table.clone(Selected))
            end
            
            table.insert(SectionData.Elements, { Frame = ListboxFrame, Name = ListboxName })
            return {
                Set = SetFlags[Flag],
                Get = function() return table.clone(Selected) end,
                Refresh = function(NewItems)
                    Items = NewItems or {}
                    Selected = {}
                    FilterItems(SearchBox.Text)
                    Flags[Flag] = {}
                    Callback({})
                end,
            }
        end
        
        table.insert(PageData.Sections, SectionData)
        return SectionData
    end
    
    PageData.CreateSection = CreateSection
    Pages[#Pages + 1] = PageData
    
    return PageData
end

-- =======================================================
-- === АВТОНОМНАЯ СИСТЕМА FLING & ANTI-FLING ===
-- =======================================================
local antiFlingEnabled = false
local flingDetectionCon = nil
local flingNeutralizerCon = nil

local function toggleAntiFling(state)
    antiFlingEnabled = state

    if state then
        flingDetectionCon = RunService.Heartbeat:Connect(function()
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character.PrimaryPart then
                    local primary = pl.Character.PrimaryPart
                    if primary.AssemblyAngularVelocity.Magnitude > 50 or primary.AssemblyLinearVelocity.Magnitude > 100 then
                        for _, p in ipairs(pl.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            end
                        end
                    end
                end
            end
        end)

        flingNeutralizerCon = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                local hrp = LocalPlayer.Character.PrimaryPart
                if hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 250 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    else
        if flingDetectionCon then 
            flingDetectionCon:Disconnect() 
            flingDetectionCon = nil
        end
        if flingNeutralizerCon then 
            flingNeutralizerCon:Disconnect() 
            flingNeutralizerCon = nil
        end
    end
end

local function executeFling(target)
    if not target or not target.Character then
        warn("[Fling]: Цель не найдена или персонаж отсутствует.")
        return
    end

    local wasAntiFlingOn = antiFlingEnabled
    if wasAntiFlingOn then
        toggleAntiFling(false)
        task.wait(0.2)
    end

    local SkidFling = function(TargetPlayer)
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter and TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")

        if Character and Humanoid and RootPart then
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end

            if THead then
                workspace.CurrentCamera.CameraSubject = THead
            elseif not THead and Handle then
                workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid and TRootPart then
                workspace.CurrentCamera.CameraSubject = THumanoid
            end

            if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e8, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end

            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0

                repeat
                    if RootPart and THumanoid then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    else
                        break
                    end
                until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or TargetPlayer.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
            end

            getgenv().FPDH = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = 0 / 0

            local BV = Instance.new("BodyVelocity")
            BV.Name = "EpixVel"
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
            BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)

            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

            if TRootPart and THead then
                if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                    SFBasePart(THead)
                else
                    SFBasePart(TRootPart)
                end
            elseif TRootPart and not THead then
                SFBasePart(TRootPart)
            elseif not TRootPart and THead then
                SFBasePart(THead)
            elseif not TRootPart and not THead and Accessory and Handle then
                SFBasePart(Handle)
            end

            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid

            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                Humanoid:ChangeState("GettingUp")

                for _, x in pairs(Character:GetChildren()) do
                    if x:IsA("BasePart") then
                        x.Velocity = Vector3.new()
                        x.RotVelocity = Vector3.new()
                    end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25

            if getgenv().FPDH then
                workspace.FallenPartsDestroyHeight = getgenv().FPDH
            end
        end
    end

    SkidFling(target)

    if wasAntiFlingOn then
        task.wait(0.5)
        toggleAntiFling(true)
    end
end

-- === СОЗДАНИЕ СТРАНИЦ ===

-- Aimbot
local AimbotPage = CreatePage({Name = "Aimbot", Icon = "100050851789190"})
local AimbotSection = AimbotPage:CreateSection({Name = "Aimbot Settings"})
AimbotSection:Toggle({Name = "Enable Aimbot", Default = false})
AimbotSection:Slider({Name = "FOV", Min = 0, Max = 360, Default = 90, Suffix = "°"})
AimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 100, Default = 50, Suffix = "%"})
AimbotSection:Dropdown({Name = "Target", Items = {"Head", "Body", "Legs"}, Default = "Head"})
AimbotSection:Keybind({Name = "Aimbot Key", Default = Enum.KeyCode.LeftShift})

-- Settings (Вкладка настроек с выбором темы, цвета и изменением размера GUI)
local SettingsPage = CreatePage({Name = "settings", Icon = "123944728972740"})
local SettingsSection = SettingsPage:CreateSection({Name = "Theme Settings", Description = "Customize GUI colors"})

local themeDropdown
local customColorpicker

themeDropdown = SettingsSection:Dropdown({
    Name = "Ui Theme",
    Items = {"AMOLED Black", "Dark Blue", "Crimson Red", "Emerald Green", "Purple Velvet", "Cyberpunk"},
    Default = "AMOLED Black",
    Callback = function(selected)
        ApplyTheme(selected)
    end
})

customColorpicker = SettingsSection:Colorpicker({
    Name = "Custom Accent Color",
    Default = Color3.fromRGB(0, 116, 224),
    Callback = function(col)
        local h, s, v = col:ToHSV()
        local accentGrad = Color3.fromHSV((h + 0.05) % 1, s, v)

        local currentTheme = themeDropdown and themeDropdown.Get() or "AMOLED Black"
        if ThemesPresets[currentTheme] then
            ThemesPresets[currentTheme].Accent = col
            ThemesPresets[currentTheme].AccentGradient = accentGrad
        end

        ApplyTheme(currentTheme)
    end
})

-- Добавленная функция изменения размера GUI во вкладку Settings
local SizeSection = SettingsPage:CreateSection({Name = "UI Size Settings", Description = "Change interface scale"})

-- Базовые стандартные размеры для расчёта масштаба
local BaseWidth = MainWidth
local BaseHeight = MainHeight
local BaseSidebarWidth = SidebarWidth

SizeSection:Slider({
    Name = "UI Size",
    Min = 400,
    Max = 800,
    Default = MainWidth,
    Suffix = "px",
    Decimals = 1,
    Callback = function(newWidth)
        -- Вычисляем высоту пропорционально (сохраняя исходное соотношение сторон)
        local ratio = MainHeight / MainWidth
        local newHeight = math.floor(newWidth * ratio)
        local newSidebar = math.floor(SidebarWidth * (newWidth / MainWidth))

        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        LeftTabs.Size = UDim2.new(0, newSidebar, 1, -(HeaderHeight + FooterHeight))
        ProfileFooter.Size = UDim2.new(0, newSidebar, 0, FooterHeight)
        Content.Position = UDim2.new(0, newSidebar, 0, HeaderHeight)
        Content.Size = UDim2.new(1, -newSidebar, 1, -HeaderHeight)
        
        UpdateActiveIndicator(true)
    end
})

-- ==========================================
-- ===    UI ЭЛЕМЕНТЫ ДЛЯ FOV STRETCH    ===
-- ==========================================

-- Добавляем секцию для FOV настроек
local FOVSection = SettingsPage:CreateSection({Name = "FOV Settings", Description = "Adjust camera field of view"})

-- Включение / Выключение FOV
FOVSection:Toggle({
    Name = "FOV Stretch",
    Default = false,
    Callback = function(state)
        FOVEnabled = state
        updateFOV()
    end
})

-- Слайдер настройки FOV (от 40 до 150 градусов)
FOVSection:Slider({
    Name = "FOV Value",
    Min = 40,
    Max = 150,
    Default = 70,
    Suffix = "°",
    Decimals = 1,
    Callback = function(value)
        FOVValue = value
        if FOVEnabled then
            Camera.FieldOfView = value
        end
    end
})

-- Кнопка сброса FOV
FOVSection:Button({
    Name = "Reset FOV to Default",
    Callback = function()
        FOVEnabled = false
        FOVValue = 70
        updateFOV()
        -- Обновляем слайдер в UI (если есть доступ)
        task.wait(0.1)
    end
})

-- Visuals
local VisualsPage = CreatePage({Name = "Visuals", Icon = "122669828593160"})
local VisualsSection = VisualsPage:CreateSection({Name = "Players"})

VisualsSection:Toggle({
    Name = "Player ESP",
    Default = true,
    Callback = function(state)
        _G.ESPEnabled = state
    end
})

VisualsSection:Toggle({
    Name = "ESP Gun",
    Default = false,
    Callback = function(state)
        _G.GunESPEnabled = state
    end
})

-- Movement
local MovementPage = CreatePage({Name = "Movement", Icon = "101636617799068"})
local MovementSection = MovementPage:CreateSection({Name = "Movement Options"})
MovementSection:Toggle({Name = "Auto Jump", Default = false})
MovementSection:Toggle({Name = "Auto Strafe", Default = false})
MovementSection:Slider({Name = "Strafe Speed", Min = 0, Max = 100, Default = 60, Suffix = "%"})

-- === ВКЛАДКА FLING PLAYERS ===
local FlingIcon = "110220024060608"
local FlingPage = CreatePage({Name = "Fling Players", Icon = FlingIcon})
local FlingSection = FlingPage:CreateSection({
    Name = "Fling Players", 
    Description = "Tap a player to fling them",
    Icon = FlingIcon
})

FlingSection:Toggle({
    Name = "Anti-Fling Protection",
    Default = false,
    Callback = function(state)
        toggleAntiFling(state)
    end
})

local PlayerListContainer = Create("Frame", {
    Parent = FlingSection.Content,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BorderSizePixel = 0,
})

Create("UIListLayout", {
    Parent = PlayerListContainer,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local function RefreshFlingPlayerList()
    for _, Child in ipairs(PlayerListContainer:GetChildren()) do
        if Child:IsA("TextButton") then
            Child:Destroy()
        end
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Card = Create("TextButton", {
                Parent = PlayerListContainer,
                Name = "ElementBG",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 0, 0, 36),
                BorderSizePixel = 0,
            })

            Create("UICorner", { Parent = Card, CornerRadius = UDim.new(0, 6) })

            local Avatar = Create("ImageLabel", {
                Parent = Card,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(0, 6, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
                Active = false,
            })

            Create("UICorner", { Parent = Avatar, CornerRadius = UDim.new(1, 0) })

            Create("TextLabel", {
                Parent = Card,
                Text = Player.DisplayName,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                FontFace = FontSemiBold,
                TextSize = 11,
                Position = UDim2.new(0, 38, 0, 5),
                Size = UDim2.new(1, -45, 0, 13),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
            })

            local RoleLabel = Create("TextLabel", {
                Parent = Card,
                Name = "RoleLabel",
                Text = "LOBBY",
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextTransparency = 0.2,
                BackgroundTransparency = 1,
                FontFace = FontSemiBold,
                TextSize = 9,
                Position = UDim2.new(0, 38, 0, 18),
                Size = UDim2.new(1, -45, 0, 11),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
            })

            task.spawn(function()
                while Card and Card.Parent do
                    local roleName, roleColor = getPlayerRoleInfo(Player)
                    RoleLabel.Text = roleName
                    RoleLabel.TextColor3 = roleColor
                    task.wait(0.5)
                end
            end)

            Card.MouseEnter:Connect(function()
                CreateTween(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.SectionTop,
                    BackgroundTransparency = 0.1
                })
            end)

            Card.MouseLeave:Connect(function()
                CreateTween(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.3
                })
            end)

            Card.Activated:Connect(function()
                task.spawn(function()
                    executeFling(Player)
                end)
            end)
        end
    end
end

Players.PlayerAdded:Connect(RefreshFlingPlayerList)
Players.PlayerRemoving:Connect(RefreshFlingPlayerList)
RefreshFlingPlayerList()

-- Server
local MiscPage = CreatePage({Name = "Server", Icon = "81598136527047"})
local ServerSection = MiscPage:CreateSection({Name = "Server Control"})
ServerSection:Button({Name = "Rejoin Server"})
ServerSection:Button({Name = "Server Hop"})
ServerSection:Button({Name = "Join Small Server"})

local JobSection = MiscPage:CreateSection({Name = "Job ID"})
JobSection:Button({Name = "Copy Job ID"})
JobSection:Textbox({Name = "Job ID...", Placeholder = "Job ID..."})
JobSection:Button({Name = "Join"})

-- Configs
local ConfigsPage = CreatePage({Name = "Configs", Icon = "101500482366184"})
local ConfigsSection = ConfigsPage:CreateSection({Name = "Configs"})
local ConfigDropdown = ConfigsSection:Listbox({Name = "Configs", Items = {}, Multi = false})

ConfigsSection:Textbox({Name = "Config Name", Placeholder = "Enter name..."})

ConfigsSection:Button({Name = "Create", Callback = function()
    local Name = Flags["Config Name"] or "config"
    if Name and Name ~= "" then
        local Config = {}
        for Flag, Value in pairs(Flags) do
            if Flag ~= "Config Name" and Flag ~= "Configs" then
                Config[Flag] = Value
            end
        end
        local Data = HttpService:JSONEncode(Config)
        if not _G.ConfigsData then _G.ConfigsData = {} end
        _G.ConfigsData[Name] = Data
        
        local Keys = {}
        for K in pairs(_G.ConfigsData) do table.insert(Keys, K) end
        ConfigDropdown:Refresh(Keys)
    end
end})

ConfigsSection:Button({Name = "Load", Callback = function()
    local Selected = ConfigDropdown:Get()
    if Selected and #Selected > 0 and _G.ConfigsData then
        local Data = _G.ConfigsData[Selected[1]]
        if Data then
            local Decoded = HttpService:JSONDecode(Data)
            for Flag, Value in pairs(Decoded) do
                if SetFlags[Flag] then
                    SetFlags[Flag](Value)
                end
            end
        end
    end
end})

-- Активация первой страницы и привязка индикатора
if Pages[1] then
    Pages[1]:SetActive(true)
end

task.defer(function()
    task.wait(0.1)
    UpdateActiveIndicator(true)
end)

-- === ЗАГОЛОВОК-ТУГГЛ (DARK HUB) С ИНДИКАТОРОМ СОСТОЯНИЯ И АНИМАЦИЕЙ ===
local FloatHeader = Create("TextButton", {
    Parent = Holder,
    Name = "DarkHubToggleHeader",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.08,
    Size = UDim2.new(0, 148, 0, 32),
    Position = UDim2.new(0, IsMobile and 50 or 20, 0, IsMobile and 50 or 20),
    BorderSizePixel = 0,
    ZIndex = 127,
    ClipsDescendants = false,
})

Create("UICorner", { Parent = FloatHeader, CornerRadius = UDim.new(0, 8) })

local FloatStroke = Create("UIStroke", {
    Parent = FloatHeader,
    Name = "FloatStroke",
    Color = Theme.Outline,
    Thickness = 1.2,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
})

Create("UIGradient", {
    Parent = FloatStroke,
    Name = "AccentGradient",
    Rotation = 45,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Outline),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

local FloatAccent = Create("Frame", {
    Parent = FloatHeader,
    Name = "FloatAccent",
    BackgroundColor3 = Color3.new(1, 1, 1),
    Size = UDim2.new(0, 3, 0, 18),
    Position = UDim2.new(0, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BorderSizePixel = 0,
    ZIndex = 128,
})

Create("UICorner", { Parent = FloatAccent, CornerRadius = UDim.new(1, 0) })

Create("UIGradient", {
    Parent = FloatAccent,
    Name = "AccentGradient",
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

local FloatIcon = Create("ImageLabel", {
    Parent = FloatHeader,
    Name = "Icon",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(0, 10, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Image = DarkHubIcon,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 128,
})
Create("UICorner", { Parent = FloatIcon, CornerRadius = UDim.new(0, 4) })

local FloatTitle = Create("TextLabel", {
    Parent = FloatHeader,
    Name = "Title",
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 12,
    Position = UDim2.new(0, 36, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 0, 0, 14),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 128,
})

-- === КРУГЛЕШОК ИНДИКАТОРА (ЗЕЛЕНЫЙ = GUI ОТКРЫТ, КРАСНЫЙ = GUI ЗАКРЫТ) ===
local StatusDot = Create("Frame", {
    Parent = FloatHeader,
    Name = "StatusDot",
    BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 45, 45),
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(1, -12, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BorderSizePixel = 0,
    ZIndex = 128,
})

Create("UICorner", { Parent = StatusDot, CornerRadius = UDim.new(1, 0) })

local StatusDotStroke = Create("UIStroke", {
    Parent = StatusDot,
    Name = "StatusDotStroke",
    Color = StatusDot.BackgroundColor3,
    Transparency = 0.4,
    Thickness = 1.5,
})

local function UpdateStatusDot()
    local isOpen = MainFrame.Visible
    local targetColor = isOpen and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 45, 45)

    CreateTween(StatusDot, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    })
    CreateTween(StatusDotStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Color = targetColor
    })
end

MainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateStatusDot)

-- === ЛОГИКА ПЕРЕТАСКИВАНИЯ КНОПКИ И ГЛАВНОГО ОКНА ===
local DraggingFloat = false
local DragInputFloat, DragStartFloat, StartPosFloat

local function UpdateDragFloat(input)
    local Delta = input.Position - DragStartFloat
    FloatHeader.Position = UDim2.new(
        StartPosFloat.X.Scale,
        StartPosFloat.X.Offset + Delta.X,
        StartPosFloat.Y.Scale,
        StartPosFloat.Y.Offset + Delta.Y
    )
end

FloatHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DraggingFloat = true
        DragStartFloat = input.Position
        StartPosFloat = FloatHeader.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                DraggingFloat = false
            end
        end)
    end
end)

FloatHeader.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInputFloat = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInputFloat and DraggingFloat then
        UpdateDragFloat(input)
    end
end)

FloatHeader.MouseButton1Down:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Перетаскивание главного окна
local DraggingMain = false
local DragInputMain, DragStartMain, StartPosMain

local function UpdateDragMain(input)
    local Delta = input.Position - DragStartMain
    MainFrame.Position = UDim2.new(
        StartPosMain.X.Scale,
        StartPosMain.X.Offset + Delta.X,
        StartPosMain.Y.Scale,
        StartPosMain.Y.Offset + Delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = input.Position
        if mousePos.Y <= MainFrame.AbsolutePosition.Y + HeaderHeight then
            DraggingMain = true
            DragStartMain = input.Position
            StartPosMain = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    DraggingMain = false
                end
            end)
        end
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInputMain = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInputMain and DraggingMain then
        UpdateDragMain(input)
    end
end)

return DarkHub
