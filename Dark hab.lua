-- ========================================
-- ===== PLANET HUB v3.0 ULTIMATE =====
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local MaterialService = game:GetService("MaterialService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ОБХОД ЛИМИТА РЕГИСТРОВ
local function breakScope() end
breakScope()

-- УДАЛЯЕМ СТАРЫЕ GUI
if playerGui:FindFirstChild("PlanetHub") then
    playerGui.PlanetHub:Destroy()
end
if playerGui:FindFirstChild("PlanetHubOverlay") then
    playerGui.PlanetHubOverlay:Destroy()
end

-- УДАЛЯЕМ CORE СРАЗУ
pcall(function()
    if workspace:FindFirstChild("Core") then
        workspace.Core:Destroy()
    end
    if LocalPlayer.Character then
        local core = LocalPlayer.Character:FindFirstChild("Core")
        if core then core:Destroy() end
    end
end)

-- ИКОНКИ
local Icons = {
    Eye = "rbxassetid://10723407389",
    Target = "rbxassetid://10723415054",
    Sparkles = "rbxassetid://10747372992",
    Crosshair = "rbxassetid://10723434711",
    Zap = "rbxassetid://10747384394",
    Wind = "rbxassetid://10747383783",
    Tractor = "rbxassetid://10723434518",
    Music = "rbxassetid://10734896812",
    Settings = "rbxassetid://10734950309",
    Home = "rbxassetid://10734950309",
    Crown = "rbxassetid://10734950309",
    Sword = "rbxassetid://10723415054",
    Timer = "rbxassetid://10747372992",
    Smile = "rbxassetid://10723407389",
    Smartphone = "rbxassetid://10734896812",
}

-- ТЕМА
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Card = Color3.fromRGB(22, 22, 27),
    Element = Color3.fromRGB(30, 30, 37),
    Accent = Color3.fromRGB(88, 130, 255),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(130, 130, 145),
    Stroke = Color3.fromRGB(38, 38, 46),
    Danger = Color3.fromRGB(255, 60, 60),
    Success = Color3.fromRGB(60, 220, 100),
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

-- ЦВЕТА ПО УМОЛЧАНИЮ
local DEFAULT_COLORS = {
    Murder = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 120, 255),
    Innocent = Color3.fromRGB(150, 80, 240),
    Chams = Color3.fromRGB(138, 43, 226),
    Tracers = Color3.fromRGB(138, 43, 226),
    Trails = Color3.fromRGB(138, 43, 226),
    JumpCircles = Color3.fromRGB(138, 43, 226),
    Aura = Color3.fromRGB(133, 220, 255),
    ChinaHat = Color3.fromRGB(0, 255, 255),
}

-- ========================================
-- ===== НАСТРОЙКИ =====
-- ========================================

local Settings = {
    -- Visuals с цветами
    MurderESP = false, MurderColor = DEFAULT_COLORS.Murder,
    SheriffESP = false, SheriffColor = DEFAULT_COLORS.Sheriff,
    InnocentESP = false, InnocentColor = DEFAULT_COLORS.Innocent,
    ChamsEnabled = false, ChamsColor = DEFAULT_COLORS.Chams,
    TracersEnabled = false, TracersColor = DEFAULT_COLORS.Tracers,
    JumpCircles = false, JumpCirclesColor = DEFAULT_COLORS.JumpCircles,
    Trails = false, TrailsColor = DEFAULT_COLORS.Trails,
    RGBHumanoid = false, XRayEnabled = false,
    BloomEnabled = false, ColorCorrectionEnabled = false, VignetteEnabled = false,
    -- China Hat
    ChinaHatEnabled = false, ChinaHatStyle = "Classic", ChinaHatRainbow = false,
    ChinaHatRadius = 2.4, ChinaHatHeight = 1.6, ChinaHatRainbowSpeed = 5,
    ChinaHatTransparency = 0.3, ChinaHatColor = DEFAULT_COLORS.ChinaHat,
    ChinaHatReflectance = 0, ChinaHatSides = 25,
    -- Aura
    AuraEnabled = false, AuraColor = DEFAULT_COLORS.Aura,
    -- Effects
    OrbizEnabled = false, JerkEnabled = false,
    -- Movement
    FlyEnabled = false, FlySpeed = 50,
    BHopEnabled = false, BHopSpeed = 30,
    SpinBotEnabled = false, SpinBotSpeed = 9999,
    NoclipEnabled = false, AntiFlingEnabled = false, WallHopEnabled = false,
    -- Combat
    FovAimbotEnabled = false, FovRadius = 120,
    KillAllEnabled = false,
    ShootButtonEnabled = false, SheriffAutoShootEnabled = false,
    FlingMurderer = false,
    FlingSheriff = false,
    GrabGunEnabled = false,
    -- Aimbot Settings
    AimSmoothness = 0.5,
    AimPredict = true,
    AimWallCheck = true,
    AimHitChance = 80,
    AimTargetPart = "Head",
    -- Farm
    AutoFarmEnabled = false, AutoFarmSpeed = 20,
    AutoFarmCoinLimit = 40, AutoFarmCoinDelay = 0.15,
    AutoRespawn = true, AntiAFKEnabled = false,
    -- Animations
    AnimPackEnabled = false, AnimPack = "",
    -- Misc
    TexturePackEnabled = false,
    CustomSkyId = "",
    StretchEnabled = false,
    StretchFactor = 0.75,
    Binds = {},
}


-- ========================================
-- ===== КЭШ =====
-- ========================================

local Cache = {
    FlyKeys = {F=0, B=0, L=0, R=0},
    FlyRunning = false, FlyBodyGyro = nil, FlyBodyVelocity = nil,
    BHopConn = nil, BHopBV = nil, BHopActive = false,
    FlyConn = nil, FlyKeyConn = nil, FlyKeyEndConn = nil,
    Highlights = {},
    ChamsPartsList = {},
    PostEffects = {},
    JumpTracking = {wasJumping = false},
    RGBConnection = nil,
    AutoFarmConn = nil,
    CurrentTween = nil,
    XRayParts = {},
    Tracers = {},
    TrailAttachments = {},
    FovCircle = nil,
    FovConnection = nil,
    mainConn = nil,
    WallHopConnection = nil,
    SheriffAutoShootConnection = nil,
    ChinaHatParts = {},
    ChinaHatConnection = nil,
    ChinaHatDrawings = {},
    TextureState = {},
    TextureVariantsBuilt = false,
    AuraParticles = {},
    AuraCache = {},
    JerkConnection = nil,
    SpinConn = nil,
    OrbizFolder = nil,
    OrbizParticles = {},
    OrbizConnection = nil,
    KillAllConn = nil,
    KillAllRemote = nil,
    ShootButton = nil,
    GrabGunRunning = false,
    afkConn = nil,
    noclipConn = nil,
    BindConnections = {},
    BindPopup = nil,
    StretchConnection = nil,
}

-- ФУНКЦИЯ УДАЛЕНИЯ CORE
local function removeCore()
    pcall(function()
        if workspace:FindFirstChild("Core") then
            workspace.Core:Destroy()
        end
        if LocalPlayer.Character then
            local core = LocalPlayer.Character:FindFirstChild("Core")
            if core then core:Destroy() end
            for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
                if obj.Name == "Core" and obj:IsA("BasePart") then
                    obj:Destroy()
                end
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Core" and obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
                local char = obj.Parent
                if Players:GetPlayerFromCharacter(char) then
                    obj:Destroy()
                end
            end
        end
    end)
end

-- ========================================
-- ===== ANIMATION PACKS =====
-- ========================================

do end
local ANIM_PACKS = {
    ["Adidas Sports"] = {WalkAnim=18537392113, RunAnim=18537384940, JumpAnim=18537380791, FallAnim=18537367238, SwimIdle=18537387180, Swim=18537389531, Animation1=18537376492, Animation2=18537371272, ClimbAnim=18537363391},
    ["Adidas Community"] = {WalkAnim=122150855457006, RunAnim=82598234841035, JumpAnim=75290611992385, FallAnim=98600215928904, SwimIdle=109346520324160, Swim=133308483266208, Animation1=122257458498464, Animation2=102357151005774, ClimbAnim=88763136693023},
    ["Adidas Aura"] = {WalkAnim=83842218823011, RunAnim=118320322718866, JumpAnim=109996626521204, FallAnim=95603166884636, SwimIdle=94922130551805, Swim=134530128383903, Animation1=110211186840347, Animation2=114191137265065, ClimbAnim=97824616490448},
    ["Wicked Popular"] = {WalkAnim=92072849924640, RunAnim=72301599441680, JumpAnim=104325245285198, FallAnim=121152442762481, Animation1=118832222982049, ClimbAnim=131326830509784, SwimIdle=113199415118199, Swim=99384245425157, Animation2=76049494037641},
    Elder = {WalkAnim=10921111375, RunAnim=10921104374, JumpAnim=10921107367, FallAnim=10921105765, SwimIdle=10921110146, Swim=10921108971, ClimbAnim=10921100400, Animation1=10921101664, Animation2=10921102574},
    Zombie = {WalkAnim=10921355261, RunAnim=616163682, JumpAnim=10921351278, FallAnim=10921350320, SwimIdle=10921353442, Swim=10921352344, Animation1=10921344533, Animation2=10921345304, ClimbAnim=10921343576},
    Mage = {WalkAnim=10921152678, RunAnim=10921148209, JumpAnim=10921149743, FallAnim=10921148939, SwimIdle=10921151661, Swim=10921150788, ClimbAnim=10921143404, Animation1=10921144709, Animation2=10921145797},
    ["Catwalk Glam"] = {WalkAnim=109168724482748, RunAnim=81024476153754, JumpAnim=116936326516985, FallAnim=92294537340807, SwimIdle=98854111361360, Swim=134591743181628, ClimbAnim=119377220967554, Animation1=133806214992291, Animation2=94970088341563},
    Astronaut = {WalkAnim=10921046031, RunAnim=10921039308, JumpAnim=10921042494, FallAnim=10921040576, SwimIdle=10921045006, Swim=10921044000, ClimbAnim=10921032124, Animation1=10921034824, Animation2=10921036806},
    ["Wicked 'Dancing Through Life'"] = {WalkAnim=73718308412641, RunAnim=135515454877967, JumpAnim=78508480717326, FallAnim=78147885297412, SwimIdle=129183123083281, Swim=110657013921774, ClimbAnim=129447497744818, Animation1=92849173543269, Animation2=132238900951109},
    Werewolf = {WalkAnim=10921342074, RunAnim=10921336997, JumpAnim=nil, FallAnim=10921337907, SwimIdle=10921341319, Swim=10921340419, ClimbAnim=10921329322, Animation1=10921330408, Animation2=10921333667},
    Superhero = {WalkAnim=10921298616, RunAnim=10921291831, JumpAnim=10921294559, FallAnim=10921293373, SwimIdle=10921297391, Swim=10921295495, ClimbAnim=10921286911, Animation1=10921288909, Animation2=10921290167},
    Toy = {WalkAnim=10921312010, RunAnim=10921306285, JumpAnim=10921308158, FallAnim=10921307241, SwimIdle=10921310341, Swim=10921309319, ClimbAnim=10921300839, Animation1=10921301576, Animation2=nil},
    ["No Boundaries"] = {WalkAnim=18747074203, RunAnim=18747070484, JumpAnim=18747069148, FallAnim=18747062535, SwimIdle=18747071682, Swim=18747073181, ClimbAnim=18747060903, Animation1=18747067405, Animation2=18747063918},
    NFL = {WalkAnim=110358958299415, RunAnim=117333533048078, JumpAnim=119846112151352, FallAnim=129773241321032, SwimIdle=79090109939093, Swim=132697394189921, ClimbAnim=134630013742019, Animation1=92080889861410, Animation2=74451233229259},
    ["Amazon Unboxed"] = {WalkAnim=90478085024465, RunAnim=134824450619865, JumpAnim=121454505477205, FallAnim=94788218468396, SwimIdle=129126268464847, Swim=105962919001086, ClimbAnim=121145883950231, Animation1=98281136301627, Animation2=nil},
    Vampire = {WalkAnim=10921326949, RunAnim=10921320299, JumpAnim=10921322186, FallAnim=10921321317, SwimIdle=10921325443, Swim=10921324408, ClimbAnim=10921314188, Animation1=10921315373, Animation2=nil},
    Ninja = {Run=656118852, Walk=656121766, Jump=656117878, Fall=656115606, Swim=656119721, SwimIdle=656121397, Climb=656114359, Idle={656117400,656118341,886742569}},
    Robot = {Run=616091570, Walk=616095330, Jump=616090535, Fall=616087089, Swim=616092998, SwimIdle=616094091, Climb=616086039, Idle={616088211,616089559,885531463}},
    Levitation = {Run=616010382, Walk=616013216, Jump=616008936, Fall=616005863, Swim=616011509, SwimIdle=616012453, Climb=616003713, Idle={616006778,616008087,886862142}},
    Stylish = {Run=616140816, Walk=616146177, Jump=616139451, Fall=616134815, Swim=616143378, SwimIdle=616144772, Climb=616133594, Idle={616136790,616138447,886888594}},
    Bubbly = {Run=910025107, Walk=910034870, Jump=910016857, Fall=910001910, Swim=910028158, SwimIdle=910030921, Climb=909997997, Idle={910004836,910009958,1018536639}},
    Cartoon = {Run=742638842, Walk=742640026, Jump=742637942, Fall=742637151, Swim=742639220, SwimIdle=742639812, Climb=742636889, Idle={742637544,742638445,885477856}},
}

local ANIM_PACK_NAMES = {}
for name in pairs(ANIM_PACKS) do table.insert(ANIM_PACK_NAMES, name) end
table.sort(ANIM_PACK_NAMES)

-- ========================================
-- ===== ХЕЛПЕРЫ =====
-- ========================================

local function safeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

local function notify(title, content, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = duration or 3,
        })
    end)
end

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        return Color3.fromRGB(
            tonumber("0x" .. hex:sub(1,2)) or 255,
            tonumber("0x" .. hex:sub(3,4)) or 255,
            tonumber("0x" .. hex:sub(5,6)) or 255
        )
    end
    return Color3.fromRGB(255,255,255)
end

local function colorInputToColor3(value)
    if value:match("^#%x%x%x%x%x%x$") then
        return hexToRGB(value)
    end
    local parts = {}
    for p in value:gmatch("[^,]+") do
        table.insert(parts, tonumber(p))
    end
    if #parts == 3 then
        return Color3.fromRGB(parts[1], parts[2], parts[3])
    end
    return nil
end

local function checkKnife(p)
    if not p or not p.Character then return false end
    for _, item in ipairs(p.Character:GetDescendants()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("knife") or n:find("blade") or n:find("dagger") or n:find("butcher") then return true end
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") or n:find("blade") or n:find("dagger") or n:find("butcher") then return true end
            end
        end
    end
    return false
end

local function checkGun(p)
    if not p or not p.Character then return false end
    for _, item in ipairs(p.Character:GetDescendants()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("weapon") then return true end
        end
    end
    local bp = p:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("weapon") then return true end
            end
        end
    end
    return false
end

local function getRole(player)
    if checkKnife(player) then return "Убийца" end
    if checkGun(player) then return "Шериф" end
    return "Невинный"
end

local function getRoleColor(player)
    local r = getRole(player)
    if r == "Убийца" then return Settings.MurderColor end
    if r == "Шериф" then return Settings.SheriffColor end
    return Settings.InnocentColor
end

local function equipGun()
    if not LocalPlayer.Character then return false end
    for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("gun") or n:find("pistol") or n:find("revolver") then
                pcall(function() LocalPlayer.Character.Humanoid:EquipTool(item) end)
                return true
            end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("gun") or n:find("pistol") or n:find("revolver") then
                    pcall(function() LocalPlayer.Character.Humanoid:EquipTool(item) end)
                    return true
                end
            end
        end
    end
    return false
end

local function isPlayerVisible(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
    local result = Workspace:Raycast(myHRP.Position, hrp.Position - myHRP.Position, raycastParams)
    return not result
end

local function getGroundY(origin)
    local rayOrigin = origin
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    if char then raycastParams.FilterDescendantsInstances = {char} end
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result then return result.Position.Y end
    return origin.Y - 3
end

local function teleportToRole(role)
    if not LocalPlayer.Character then notify("Телепорт", "Персонаж не найден", 2); return end
    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then notify("Телепорт", "HRP не найден", 2); return end
    local target, targetDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hasRole = (role == "Убийца" and checkKnife(player)) or (role == "Шериф" and checkGun(player))
            if hasRole then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist < targetDist then targetDist = dist; target = player end
                end
            end
        end
    end
    if not target then notify("Телепорт", role .. " не найден", 2); return end
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if tHRP then myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 3, 2); notify("Телепорт", "Телепорт к " .. role, 2) end
end

-- ========================================
-- ===== BIND SYSTEM =====
-- ========================================

local function createBindPopup(callback)
    if Cache.BindPopup then
        Cache.BindPopup:Destroy()
        Cache.BindPopup = nil
    end
    
    local popup = Instance.new("Frame")
    popup.Name = "BindPopup"
    popup.Size = UDim2.new(0, 300, 0, 160)
    popup.Position = UDim2.new(0.5, -150, 0.5, -80)
    popup.BackgroundColor3 = Theme.Background
    popup.BorderSizePixel = 0
    popup.ZIndex = 1000
    popup.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = popup
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 36)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Выберите клавишу"
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.Font = FontBold
    title.Parent = popup
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 24)
    sub.Position = UDim2.new(0, 0, 0, 40)
    sub.BackgroundTransparency = 1
    sub.Text = "Нажмите любую клавишу на клавиатуре"
    sub.TextColor3 = Theme.SubText
    sub.TextSize = 12
    sub.Font = Font
    sub.Parent = popup
    
    local keyDisplay = Instance.new("TextLabel")
    keyDisplay.Size = UDim2.new(1, -40, 0, 36)
    keyDisplay.Position = UDim2.new(0, 20, 0, 70)
    keyDisplay.BackgroundColor3 = Theme.Card
    keyDisplay.Text = "Ожидание..."
    keyDisplay.TextColor3 = Theme.Accent
    keyDisplay.TextSize = 18
    keyDisplay.Font = FontBold
    keyDisplay.TextXAlignment = Enum.TextXAlignment.Center
    keyDisplay.Parent = popup
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyDisplay
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 80, 0, 30)
    cancelBtn.Position = UDim2.new(0.5, -100, 1, -40)
    cancelBtn.BackgroundColor3 = Theme.Card
    cancelBtn.Text = "Отмена"
    cancelBtn.TextColor3 = Theme.SubText
    cancelBtn.TextSize = 13
    cancelBtn.Font = Font
    cancelBtn.AutoButtonColor = false
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Parent = popup
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelBtn
    
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 80, 0, 30)
    acceptBtn.Position = UDim2.new(0.5, 20, 1, -40)
    acceptBtn.BackgroundColor3 = Theme.Accent
    acceptBtn.Text = "OK"
    acceptBtn.TextColor3 = Theme.Text
    acceptBtn.TextSize = 13
    acceptBtn.Font = FontBold
    acceptBtn.AutoButtonColor = false
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Parent = popup
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 6)
    acceptCorner.Parent = acceptBtn
    
    local selectedKey = nil
    local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            selectedKey = input.KeyCode.Name
            keyDisplay.Text = selectedKey
        end
    end)
    
    acceptBtn.MouseButton1Click:Connect(function()
        if selectedKey then
            callback(selectedKey)
            inputConn:Disconnect()
            popup:Destroy()
            Cache.BindPopup = nil
        end
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        inputConn:Disconnect()
        popup:Destroy()
        Cache.BindPopup = nil
    end)
    
    Cache.BindPopup = popup
end

-- ========================================
-- ===== ANIMATIONS =====
-- ========================================

local function applyAnimPack(packName)
    local pack = ANIM_PACKS[packName]
    if not pack then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local animate = char:FindFirstChild("Animate")
    if not animate then return false end
    
    local function setAnim(obj, id) if obj and id then obj.AnimationId = "rbxassetid://" .. tostring(id) end end
    local function ensureAnim(folder, name)
        if not folder then return nil end
        local a = folder:FindFirstChild(name)
        if not a then a = Instance.new("Animation"); a.Name = name; a.Parent = folder end
        return a
    end
    
    local runObj = ensureAnim(animate:FindFirstChild("run"), "RunAnim")
    local walkObj = ensureAnim(animate:FindFirstChild("walk"), "WalkAnim")
    local jumpObj = ensureAnim(animate:FindFirstChild("jump"), "JumpAnim")
    local fallObj = ensureAnim(animate:FindFirstChild("fall"), "FallAnim")
    local climbObj = ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
    local swimObj = ensureAnim(animate:FindFirstChild("swim"), "Swim")
    local swimIdleObj = ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
    local idleFolder = animate:FindFirstChild("idle")
    
    setAnim(walkObj, pack.WalkAnim or pack.Walk)
    setAnim(runObj, pack.RunAnim or pack.Run)
    setAnim(jumpObj, pack.JumpAnim or pack.Jump)
    setAnim(fallObj, pack.FallAnim or pack.Fall)
    setAnim(climbObj, pack.ClimbAnim or pack.Climb)
    setAnim(swimObj, pack.Swim)
    setAnim(swimIdleObj, pack.SwimIdle or pack.Swim)
    
    if idleFolder then
        local a1 = idleFolder:FindFirstChild("Animation1")
        local a2 = idleFolder:FindFirstChild("Animation2")
        if pack.Animation1 then setAnim(a1, pack.Animation1) end
        if pack.Animation2 then setAnim(a2, pack.Animation2) end
        if pack.Idle then
            if a1 and pack.Idle[1] then setAnim(a1, pack.Idle[1]) end
            if a2 and pack.Idle[2] then setAnim(a2, pack.Idle[2] or pack.Idle[1]) end
        end
    end
    
    animate.Disabled = true; task.wait(0.06); animate.Disabled = false
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed); task.wait(0.03); hum:ChangeState(Enum.HumanoidStateType.Running) end) end
    Settings.AnimPack = packName
    return true
end

-- ========================================
-- ===== FLY =====
-- ========================================

local function stopFly()
    Cache.FlyRunning = false
    if Cache.FlyBodyGyro then pcall(function() Cache.FlyBodyGyro:Destroy() end); Cache.FlyBodyGyro = nil end
    if Cache.FlyBodyVelocity then pcall(function() Cache.FlyBodyVelocity:Destroy() end); Cache.FlyBodyVelocity = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
    Cache.FlyKeys = {F=0, B=0, L=0, R=0}
    safeDisconnect(Cache.FlyConn); Cache.FlyConn = nil
    removeCore()
end

local function startFly()
    if Cache.FlyRunning then return end
    local char = LocalPlayer.Character
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    Cache.FlyRunning = true
    Cache.FlyKeys = {F=0, B=0, L=0, R=0}
    Cache.FlyBodyGyro = Instance.new("BodyGyro", torso)
    Cache.FlyBodyGyro.P = 9e4
    Cache.FlyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    Cache.FlyBodyGyro.cframe = torso.CFrame
    Cache.FlyBodyVelocity = Instance.new("BodyVelocity", torso)
    Cache.FlyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    Cache.FlyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    char.Humanoid.PlatformStand = true
    safeDisconnect(Cache.FlyConn)
    Cache.FlyConn = RunService.RenderStepped:Connect(function()
        if not Cache.FlyRunning or not LocalPlayer.Character then stopFly(); return end
        removeCore()
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local move = Vector3.new(
            (Cache.FlyKeys.R - Cache.FlyKeys.L) * right.X + (Cache.FlyKeys.F - Cache.FlyKeys.B) * forward.X,
            (Cache.FlyKeys.R - Cache.FlyKeys.L) * right.Y + (Cache.FlyKeys.F - Cache.FlyKeys.B) * forward.Y,
            (Cache.FlyKeys.R - Cache.FlyKeys.L) * right.Z + (Cache.FlyKeys.F - Cache.FlyKeys.B) * forward.Z
        ) * Settings.FlySpeed
        if move.Magnitude > 0 then Cache.FlyBodyVelocity.velocity = move
        else Cache.FlyBodyVelocity.velocity = Vector3.new(0, 0.1, 0) end
        Cache.FlyBodyGyro.cframe = cam.CFrame
    end)
    notify("Fly", "Включен (WASD - движение)", 2)
end

local function setupFlyKeys()
    safeDisconnect(Cache.FlyKeyConn); safeDisconnect(Cache.FlyKeyEndConn)
    Cache.FlyKeyConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not Cache.FlyRunning then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then Cache.FlyKeys.F = 1
        elseif k == Enum.KeyCode.S then Cache.FlyKeys.B = 1
        elseif k == Enum.KeyCode.A then Cache.FlyKeys.L = 1
        elseif k == Enum.KeyCode.D then Cache.FlyKeys.R = 1 end
    end)
    Cache.FlyKeyEndConn = UserInputService.InputEnded:Connect(function(input, gp)
        if gp or not Cache.FlyRunning then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then Cache.FlyKeys.F = 0
        elseif k == Enum.KeyCode.S then Cache.FlyKeys.B = 0
        elseif k == Enum.KeyCode.A then Cache.FlyKeys.L = 0
        elseif k == Enum.KeyCode.D then Cache.FlyKeys.R = 0 end
    end)
end
setupFlyKeys()

local function toggleFly(value)
    Settings.FlyEnabled = value
    if value then startFly() else stopFly() end
end

-- ========================================
-- ===== BHOP =====
-- ========================================

local function stopBHop()
    Cache.BHopActive = false
    safeDisconnect(Cache.BHopConn); Cache.BHopConn = nil
    if Cache.BHopBV then pcall(function() Cache.BHopBV:Destroy() end); Cache.BHopBV = nil end
end

local function startBHop()
    if not LocalPlayer.Character then return end
    if Cache.BHopActive then stopBHop() end
    local char = LocalPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    Cache.BHopActive = true
    Cache.BHopBV = Instance.new("BodyVelocity")
    Cache.BHopBV.MaxForce = Vector3.new(1e5, 0, 1e5)
    Cache.BHopBV.Velocity = Vector3.new(0, 0, 0)
    Cache.BHopBV.Parent = hrp
    local lastJump = 0
    Cache.BHopConn = RunService.Stepped:Connect(function()
        if not Cache.BHopActive then stopBHop(); return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if not Cache.BHopBV or not Cache.BHopBV.Parent then
            Cache.BHopBV = Instance.new("BodyVelocity")
            Cache.BHopBV.MaxForce = Vector3.new(1e5, 0, 1e5)
            Cache.BHopBV.Velocity = Vector3.new(0, 0, 0)
            Cache.BHopBV.Parent = hrp
        end
        local moveDir = hum.MoveDirection
        local isMoving = moveDir.Magnitude > 0.1
        local state = hum:GetState()
        local onGround = (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.RunningNoPhysics)
        if isMoving then
            local horizontal = Vector3.new(moveDir.X, 0, moveDir.Z)
            if horizontal.Magnitude > 0.01 then Cache.BHopBV.Velocity = horizontal.Unit * Settings.BHopSpeed end
            if onGround and tick() - lastJump > 0.15 then hum:ChangeState(Enum.HumanoidStateType.Jumping); lastJump = tick() end
        else Cache.BHopBV.Velocity = Vector3.new(0, 0, 0) end
    end)
    notify("BHop", "Включен", 2)
end

local function toggleBHop(value)
    Settings.BHopEnabled = value
    if value then startBHop() else stopBHop() end
end

-- ========================================
-- ===== SPIN BOT =====
-- ========================================

local SpinBot = {Enabled = false, Speed = 9999}

local function setupSpinBot()
    safeDisconnect(Cache.SpinConn); Cache.SpinConn = nil
    if not SpinBot.Enabled then return end
    Cache.SpinConn = RunService.Heartbeat:Connect(function(dt)
        if not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinBot.Speed * dt), 0) end
    end)
end

local function toggleSpinBot(value)
    SpinBot.Enabled = value
    setupSpinBot()
    notify("Spin Bot", value and "Включен" or "Выключен", 2)
end

-- ========================================
-- ===== JERK =====
-- ========================================

local function toggleJerk(value)
    Settings.JerkEnabled = value
    if value then
        if Cache.JerkConnection then Cache.JerkConnection:Disconnect() end
        Cache.JerkConnection = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character then return end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(math.random(-50,50), math.random(-30,30), math.random(-50,50)) end
        end)
        notify("Jerk", "Включен", 2)
    else
        if Cache.JerkConnection then Cache.JerkConnection:Disconnect() end; Cache.JerkConnection = nil
        notify("Jerk", "Выключен", 2)
    end
end

-- ========================================
-- ===== ORBIZ =====
-- ========================================

local function createOrbiz()
    if Cache.OrbizFolder then Cache.OrbizFolder:Destroy() end
    if Cache.OrbizConnection then Cache.OrbizConnection:Disconnect() end
    Cache.OrbizParticles = {}
    if not Settings.OrbizEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local folder = Instance.new("Folder")
    folder.Name = "Orbiz3D"
    folder.Parent = workspace
    Cache.OrbizFolder = folder

    local COUNT = 800
    for i = 1, COUNT do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.2 + math.random() * 0.3, 0.2 + math.random() * 0.3, 0.2 + math.random() * 0.3)
        part.BrickColor = BrickColor.new("Bright violet")
        part.Material = Enum.Material.Neon
        part.Transparency = 0.2 + math.random() * 0.5
        part.Anchored = true
        part.CanCollide = false
        part.Parent = folder
        local range = 80
        part.Position = root.Position + Vector3.new((math.random()-0.5)*range*2, math.random()*50+20, (math.random()-0.5)*range*2)
        table.insert(Cache.OrbizParticles, {part=part, speed=0.2+math.random()*0.8, driftX=(math.random()-0.5)*0.5, driftZ=(math.random()-0.5)*0.5, startY=part.Position.Y})
    end

    Cache.OrbizConnection = RunService.Heartbeat:Connect(function()
        if not Settings.OrbizEnabled then return end
        local rootPos = root and root.Position or Vector3.new(0,0,0)
        local range = 80
        for _, data in pairs(Cache.OrbizParticles) do
            local part = data.part
            if not part or not part.Parent then continue end
            local pos = part.Position
            pos = pos - Vector3.new(0, data.speed * 0.08, 0)
            pos = pos + Vector3.new(data.driftX * 0.03, 0, data.driftZ * 0.03)
            if pos.Y < rootPos.Y - 10 then
                pos = Vector3.new(rootPos.X + (math.random()-0.5)*range*2, rootPos.Y + 30 + math.random()*40, rootPos.Z + (math.random()-0.5)*range*2)
                part.Transparency = 0.2 + math.random() * 0.5
                part.Size = Vector3.new(0.2 + math.random() * 0.4, 0.2 + math.random() * 0.4, 0.2 + math.random() * 0.4)
            end
            part.Position = pos
        end
    end)
end

local function toggleOrbiz(value)
    Settings.OrbizEnabled = value
    createOrbiz()
    notify("Орбизы", value and "Включены" or "Выключены", 2)
end

-- ========================================
-- ===== CHAMS =====
-- ========================================

local function cacheCharacterParts(player)
    if not player or not player.Character then return end
    local list = {}
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            list[part] = {ogMaterial=part.Material, ogColor=part.Color, ogTransparency=part.Transparency, ogCastShadow=part.CastShadow}
        end
    end
    Cache.ChamsPartsList[player.UserId] = list
end

local function applyChams(player)
    if not player or not player.Character then return end
    local char = player.Character
    if not Cache.ChamsPartsList[player.UserId] then cacheCharacterParts(player) end
    local chamsColor = Settings.ChamsColor
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not Cache.ChamsPartsList[player.UserId] then Cache.ChamsPartsList[player.UserId] = {} end
            if not Cache.ChamsPartsList[player.UserId][part] then
                Cache.ChamsPartsList[player.UserId][part] = {ogMaterial=part.Material, ogColor=part.Color, ogTransparency=part.Transparency, ogCastShadow=part.CastShadow}
            end
            part.Material = Enum.Material.ForceField
            part.Color = chamsColor
            part.Transparency = 0.0
            part.CastShadow = false
        end
    end
end

local function removeChams(player)
    if not player or not player.Character then return end
    local char = player.Character
    local list = Cache.ChamsPartsList[player.UserId]
    if not list then return end
    for part, data in pairs(list) do
        if part and part.Parent then
            pcall(function() part.Material = data.ogMaterial; part.Color = data.ogColor; part.Transparency = data.ogTransparency; part.CastShadow = data.ogCastShadow end)
        end
    end
    Cache.ChamsPartsList[player.UserId] = nil
end

local function clearAllChams()
    for userId, _ in pairs(Cache.ChamsPartsList) do
        local p = Players:GetPlayerByUserId(userId)
        if p then removeChams(p) end
    end
    Cache.ChamsPartsList = {}
end

local function updateChamsForAll()
    if Settings.ChamsEnabled then for _, p in ipairs(Players:GetPlayers()) do cacheCharacterParts(p); applyChams(p) end
    else clearAllChams() end
end

-- ========================================
-- ===== ESP =====
-- ========================================

local function createOrUpdateHighlight(player, color)
    if not player or not player.Character then return end
    local char = player.Character
    local hl = char:FindFirstChild("PH_ESP")
    if not hl then hl = Instance.new("Highlight"); hl.Name = "PH_ESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char end
    hl.FillColor = color; hl.OutlineColor = color; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0; hl.Enabled = true
    Cache.Highlights[player.UserId] = hl
end

local function removeHighlight(player)
    if not player or not player.Character then return end
    local hl = player.Character:FindFirstChild("PH_ESP")
    if hl then pcall(function() hl:Destroy() end) end
    Cache.Highlights[player.UserId] = nil
end

local function clearAllHighlights()
    for _, hl in pairs(Cache.Highlights) do if hl then pcall(function() hl:Destroy() end) end end
    Cache.Highlights = {}
end

-- ========================================
-- ===== TRACERS =====
-- ========================================

local function createTracer(player)
    if not player or player == LocalPlayer then return end
    if Cache.Tracers[player.UserId] then return end
    local line = Drawing.new("Line")
    line.Thickness = 2; line.Transparency = 0.8; line.Visible = false
    line.Color = getRoleColor(player)
    Cache.Tracers[player.UserId] = line
end

local function updateTracers()
    if not Settings.TracersEnabled then
        for _, line in pairs(Cache.Tracers) do line.Visible = false end
        return
    end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    for userId, line in pairs(Cache.Tracers) do
        local player = Players:GetPlayerByUserId(userId)
        if not player or not player.Character then line.Visible = false continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then line.Visible = false continue end
        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then line.Visible = false continue end
        line.From = center; line.To = Vector2.new(sp.X, sp.Y); line.Visible = true
        line.Color = getRoleColor(player)
    end
end

local function clearAllTracers()
    for userId, line in pairs(Cache.Tracers) do pcall(function() line:Remove() end) end
    Cache.Tracers = {}
end

-- ========================================
-- ===== TRAILS =====
-- ========================================

local function createLocalPlayerTrail()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Cache.TrailAttachments.trail and Cache.TrailAttachments.trail.Parent then return end
    local att1 = Instance.new("Attachment"); att1.Position = Vector3.new(-1,0,0); att1.Parent = hrp
    local att2 = Instance.new("Attachment"); att2.Position = Vector3.new(1,0,0); att2.Parent = hrp
    local trail = Instance.new("Trail")
    trail.Attachment0 = att1; trail.Attachment1 = att2; trail.Lifetime = 0.8; trail.MinLength = 0
    trail.FaceCamera = true; trail.LightEmission = 1; trail.LightInfluence = 0
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    trail.Color = ColorSequence.new(Settings.TrailsColor)
    trail.Parent = hrp
    Cache.TrailAttachments = {trail=trail, att1=att1, att2=att2}
end

local function updateTrailColor()
    if Cache.TrailAttachments.trail then
        Cache.TrailAttachments.trail.Color = ColorSequence.new(Settings.TrailsColor)
    end
end

local function removeLocalPlayerTrail()
    if Cache.TrailAttachments.trail then pcall(function() Cache.TrailAttachments.trail:Destroy() end) end
    if Cache.TrailAttachments.att1 then pcall(function() Cache.TrailAttachments.att1:Destroy() end) end
    if Cache.TrailAttachments.att2 then pcall(function() Cache.TrailAttachments.att2:Destroy() end) end
    Cache.TrailAttachments = {}
end

-- ========================================
-- ===== JUMP CIRCLES =====
-- ========================================

local function createJumpCircle(originPos)
    local groundY = getGroundY(originPos)
    local ringPos = Vector3.new(originPos.X, groundY + 0.08, originPos.Z)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.08, 0.5, 0.5)
    ring.Material = Enum.Material.Neon
    ring.Color = Settings.JumpCirclesColor
    ring.Transparency = 0
    ring.Anchored = true
    ring.CanCollide = false
    ring.CastShadow = false
    ring.CFrame = CFrame.new(ringPos) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = Workspace
    local light = Instance.new("PointLight")
    light.Brightness = 4; light.Color = Settings.JumpCirclesColor; light.Range = 20; light.Parent = ring
    local t0 = tick(); local duration = 0.7
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not ring or not ring.Parent then safeDisconnect(conn); return end
        local p = (tick() - t0) / duration
        if p >= 1 then pcall(function() ring:Destroy() end); safeDisconnect(conn); return end
        local diameter = 0.5 + p * 6
        ring.Size = Vector3.new(0.08, diameter, diameter)
        ring.Transparency = p
        ring.CFrame = CFrame.new(ringPos) * CFrame.Angles(0, 0, math.rad(90))
        light.Brightness = 4 * (1 - p)
    end)
end

local function updateJumpCircles()
    if not Settings.JumpCircles or not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local isJumping = hum:GetState() == Enum.HumanoidStateType.Jumping
    if isJumping and not Cache.JumpTracking.wasJumping then createJumpCircle(hrp.Position) end
    Cache.JumpTracking.wasJumping = isJumping
end

-- ========================================
-- ===== RGB HUMANOID =====
-- ========================================

local function setupRGBHumanoid()
    safeDisconnect(Cache.RGBConnection); Cache.RGBConnection = nil
    if not Settings.RGBHumanoid then
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.Material = Enum.Material.Plastic; part.Color = Color3.fromRGB(255,255,255); part.Transparency = 0 end
            end
        end
        return
    end
    Cache.RGBConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local color = Color3.fromHSV(tick() % 1, 1, 1)
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Material = Enum.Material.ForceField
                part.Color = color
                part.Transparency = 0.3
            end
        end
    end)
end

-- ========================================
-- ===== XRAY =====
-- ========================================

local function setupXRay()
    if Settings.XRayEnabled then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsA("Terrain") then
                Cache.XRayParts[part] = part.LocalTransparencyModifier
                part.LocalTransparencyModifier = 0.6
            end
        end
    else
        for part, val in pairs(Cache.XRayParts) do
            if part and part.Parent then pcall(function() part.LocalTransparencyModifier = val end) end
        end
        Cache.XRayParts = {}
    end
end

-- ========================================
-- ===== POST EFFECTS =====
-- ========================================

local function setupBloom(en) Lighting.Brightness = en and 1.5 or 1 end
local function setupColorCorrection(en) Lighting.Ambient = en and Settings.AuraColor or Color3.fromRGB(0,0,0); Lighting.OutdoorAmbient = en and Settings.AuraColor or Color3.fromRGB(0,0,0) end

local function setupVignette(en)
    if en then
        if Cache.PostEffects.vignette then return end
        local sg = Instance.new("ScreenGui"); sg.Name = "VignetteEffect"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.fromRGB(0,0,0); f.BackgroundTransparency = 0.5; f.BorderSizePixel = 0; f.Parent = sg
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        Cache.PostEffects.vignette = sg
    else
        if Cache.PostEffects.vignette then pcall(function() Cache.PostEffects.vignette:Destroy() end) end
        Cache.PostEffects.vignette = nil
    end
end

-- ========================================
-- ===== SKYBOX =====
-- ========================================

local SKYBOX_ASSETS = {
    ["Black Storm"] = {Bk="rbxassetid://15502511288", Dn="rbxassetid://15502508460", Ft="rbxassetid://15502510289", Lf="rbxassetid://15502507918", Rt="rbxassetid://15502509398", Up="rbxassetid://15502511911"},
    ["HD"] = {Bk="http://www.roblox.com/asset/?id=16553658937", Dn="http://www.roblox.com/asset/?id=16553660713", Ft="http://www.roblox.com/asset/?id=16553662144", Lf="http://www.roblox.com/asset/?id=16553664042", Rt="http://www.roblox.com/asset/?id=16553665766", Up="http://www.roblox.com/asset/?id=16553667750"},
    ["Snow"] = {Bk="http://www.roblox.com/asset/?id=155657655", Dn="http://www.roblox.com/asset/?id=155674246", Ft="http://www.roblox.com/asset/?id=155657609", Lf="http://www.roblox.com/asset/?id=155657671", Rt="http://www.roblox.com/asset/?id=155657619", Up="http://www.roblox.com/asset/?id=155674931"},
    ["Blue Space"] = {Bk="rbxassetid://15536110634", Dn="rbxassetid://15536112543", Ft="rbxassetid://15536116141", Lf="rbxassetid://15536114370", Rt="rbxassetid://15536118762", Up="rbxassetid://15536117282"},
    ["Realistic"] = {Bk="rbxassetid://653719502", Dn="rbxassetid://653718790", Ft="rbxassetid://653719067", Lf="rbxassetid://653719190", Rt="rbxassetid://653718931", Up="rbxassetid://653719321"},
    ["Stormy"] = {Bk="http://www.roblox.com/asset/?id=18703245834", Dn="http://www.roblox.com/asset/?id=18703243349", Ft="http://www.roblox.com/asset/?id=18703240532", Lf="http://www.roblox.com/asset/?id=18703237556", Rt="http://www.roblox.com/asset/?id=18703235430", Up="http://www.roblox.com/asset/?id=18703232671"},
    ["Pink"] = {Bk="rbxassetid://12216109205", Dn="rbxassetid://12216109875", Ft="rbxassetid://12216109489", Lf="rbxassetid://12216110170", Rt="rbxassetid://12216110471", Up="rbxassetid://12216108877"},
    ["Sunset"] = {Bk="rbxassetid://600830446", Dn="rbxassetid://600831635", Ft="rbxassetid://600832720", Lf="rbxassetid://600886090", Rt="rbxassetid://600833862", Up="rbxassetid://600835177"},
    ["Space"] = {Bk="http://www.roblox.com/asset/?id=166509999", Dn="http://www.roblox.com/asset/?id=166510057", Ft="http://www.roblox.com/asset/?id=166510116", Lf="http://www.roblox.com/asset/?id=166510092", Rt="http://www.roblox.com/asset/?id=166510131", Up="http://www.roblox.com/asset/?id=166510114"},
    ["Roblox Default"] = {Bk="rbxasset://textures/sky/sky512_bk.tex", Dn="rbxasset://textures/sky/sky512_dn.tex", Ft="rbxasset://textures/sky/sky512_ft.tex", Lf="rbxasset://textures/sky/sky512_lf.tex", Rt="rbxasset://textures/sky/sky512_rt.tex", Up="rbxasset://textures/sky/sky512_up.tex"},
    ["Red Night"] = {Bk="http://www.roblox.com/asset/?id=401664839", Dn="http://www.roblox.com/asset/?id=401664862", Ft="http://www.roblox.com/asset/?id=401664960", Lf="http://www.roblox.com/asset/?id=401664881", Rt="http://www.roblox.com/asset/?id=401664901", Up="http://www.roblox.com/asset/?id=401664936"},
    ["Pink Skies"] = {Bk="http://www.roblox.com/asset/?id=151165214", Dn="http://www.roblox.com/asset/?id=151165197", Ft="http://www.roblox.com/asset/?id=151165224", Lf="http://www.roblox.com/asset/?id=151165191", Rt="http://www.roblox.com/asset/?id=151165206", Up="http://www.roblox.com/asset/?id=151165227"},
    ["Purple Sunset"] = {Bk="rbxassetid://264908339", Dn="rbxassetid://264907909", Ft="rbxassetid://264909420", Lf="rbxassetid://264909758", Rt="rbxassetid://264908886", Up="rbxassetid://264907379"},
    ["Blue Night"] = {Bk="http://www.roblox.com/asset/?id=12064107", Dn="http://www.roblox.com/asset/?id=12064152", Ft="http://www.roblox.com/asset/?id=12064121", Lf="http://www.roblox.com/asset/?id=12063984", Rt="http://www.roblox.com/asset/?id=12064115", Up="http://www.roblox.com/asset/?id=12064131"},
    ["Summer"] = {Bk="rbxassetid://16648590964", Dn="rbxassetid://16648617436", Ft="rbxassetid://16648595424", Lf="rbxassetid://16648566370", Rt="rbxassetid://16648577071", Up="rbxassetid://16648598180"},
    ["Galaxy"] = {Bk="rbxassetid://15983968922", Dn="rbxassetid://15983966825", Ft="rbxassetid://15983965025", Lf="rbxassetid://15983967420", Rt="rbxassetid://15983966246", Up="rbxassetid://15983964246"},
    ["Minecraft"] = {Bk="rbxassetid://8735166756", Dn="http://www.roblox.com/asset/?id=8735166707", Ft="http://www.roblox.com/asset/?id=8735231668", Lf="http://www.roblox.com/asset/?id=8735166755", Rt="http://www.roblox.com/asset/?id=8735166751", Up="http://www.roblox.com/asset/?id=8735166729"},
}

local function setupSky(skyName)
    local sb = SKYBOX_ASSETS[skyName]
    if not sb then
        local skyId = tostring(skyName):gsub("%s+",""):gsub("rbxassetid://","")
        if skyId:match("^%d+$") then
            local url = "rbxassetid://" .. skyId
            for _, obj in ipairs(Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end
            local sky = Instance.new("Sky")
            sky.SkyboxBk = url; sky.SkyboxDn = url; sky.SkyboxFt = url; sky.SkyboxLf = url; sky.SkyboxRt = url; sky.SkyboxUp = url
            sky.Parent = Lighting
            notify("Небо", "Загружено: " .. skyId, 2)
        else notify("Небо", "Неизвестный скибокс", 2) end
        return
    end
    task.spawn(function() ContentProvider:PreloadAsync({sb.Bk, sb.Dn, sb.Ft, sb.Lf, sb.Rt, sb.Up}) end)
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
    sky.Name = "Sky"; sky.Parent = Lighting
    sky.SkyboxBk = sb.Bk; sky.SkyboxDn = sb.Dn; sky.SkyboxFt = sb.Ft; sky.SkyboxLf = sb.Lf; sky.SkyboxRt = sb.Rt; sky.SkyboxUp = sb.Up
    notify("Небо", "Загружено: " .. skyName, 2)
end

local function removeSky()
    for _, obj in ipairs(Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end
    notify("Небо", "Удалено", 2)
end

-- ========================================
-- ===== TEXTURE PACK =====
-- ========================================

local TEXTURE_VARIANTS = {
    Brick = {BaseMaterial=Enum.Material.Brick, Texture='rbxassetid://10777285622'},
    Concrete = {BaseMaterial=Enum.Material.Concrete, Texture='rbxassetid://15622710576'},
    CorrodedMetal = {BaseMaterial=Enum.Material.CorrodedMetal, Texture='rbxassetid://78612695839404'},
    Grass = {BaseMaterial=Enum.Material.Grass, Texture='rbxassetid://9267183930'},
    Metal = {BaseMaterial=Enum.Material.Metal, Texture='rbxassetid://121650613091353'},
    Sand = {BaseMaterial=Enum.Material.Sand, Texture='rbxassetid://12624140843'},
    Slate = {BaseMaterial=Enum.Material.Slate, Texture='rbxassetid://8676746437'},
    Wood = {BaseMaterial=Enum.Material.Wood, Texture='rbxassetid://3258599312'},
    WoodPlanks = {BaseMaterial=Enum.Material.WoodPlanks, Texture='rbxassetid://8676581022'},
}

local TEXTURE_VARIANT_BY_MATERIAL = {
    [Enum.Material.Brick]='Brick', [Enum.Material.Concrete]='Concrete', [Enum.Material.CorrodedMetal]='CorrodedMetal',
    [Enum.Material.Grass]='Grass', [Enum.Material.Metal]='Metal', [Enum.Material.Sand]='Sand',
    [Enum.Material.Slate]='Slate', [Enum.Material.Wood]='Wood', [Enum.Material.WoodPlanks]='WoodPlanks',
}

local function ensureTextureVariants()
    if Cache.TextureVariantsBuilt then return end
    for name, data in pairs(TEXTURE_VARIANTS) do
        local variant = MaterialService:FindFirstChild(name)
        if not variant then variant = Instance.new('MaterialVariant'); variant.Name = name; variant.Parent = MaterialService end
        pcall(function()
            variant.BaseMaterial = data.BaseMaterial
            variant.ColorMap = data.Texture; variant.MetalnessMap = data.Texture; variant.NormalMap = data.Texture; variant.RoughnessMap = data.Texture
            variant.MaterialPattern = Enum.MaterialPattern.Regular
            variant.StudsPerTile = 5
        end)
    end
    Cache.TextureVariantsBuilt = true
end

local function rememberTexturePart(part)
    if not Cache.TextureState[part] then Cache.TextureState[part] = {Color=part.Color, Material=part.Material, MaterialVariant=part.MaterialVariant} end
    return Cache.TextureState[part]
end

local function shouldSkipTexturePart(part)
    if not part:IsDescendantOf(workspace) then return true end
    if part.Name == 'LarpticWeather' or part.Name == 'Part' then return true end
    local parent = part.Parent
    if parent and (parent:IsA('Tool') or parent:IsA('Accessory')) then return true end
    local model = part:FindFirstAncestorOfClass('Model')
    if model and game.Players:GetPlayerFromCharacter(model) then return true end
    return false
end

local function applyTexturePack()
    if not Settings.TexturePackEnabled then return end
    ensureTextureVariants()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA('BasePart') and not shouldSkipTexturePart(obj) then
            rememberTexturePart(obj)
            local variantName = TEXTURE_VARIANT_BY_MATERIAL[obj.Material]
            if variantName then pcall(function() obj.MaterialVariant = variantName end) end
        end
    end
end

local function clearTexturePack()
    for part, state in pairs(Cache.TextureState) do
        if part and part.Parent and state then
            pcall(function() part.Color = state.Color; part.Material = state.Material; part.MaterialVariant = state.MaterialVariant or '' end)
        end
    end
    Cache.TextureState = {}
    for name, _ in pairs(TEXTURE_VARIANTS) do
        local variant = MaterialService:FindFirstChild(name)
        if variant and variant:IsA('MaterialVariant') then pcall(function() variant:Destroy() end) end
    end
    Cache.TextureVariantsBuilt = false
end

local function toggleTexturePack(value)
    Settings.TexturePackEnabled = value
    if value then applyTexturePack(); notify("Texture Pack", "Включен", 2)
    else clearTexturePack(); notify("Texture Pack", "Выключен", 2) end
end


-- ========================================
-- ===== STRETCH (РАСТЯГ ЭКРАНА ИЗ FOGYHUB) =====
-- ========================================

local function applyStretch(state)
    Settings.StretchEnabled = state
    if not state then
        if Cache.StretchConnection then 
            pcall(function() Cache.StretchConnection:Disconnect() end)
            Cache.StretchConnection = nil 
        end
        pcall(function()
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame
        end)
        return
    end
    if not Cache.StretchConnection then
        Cache.StretchConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            if camera then 
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, Settings.StretchFactor, 0, 0, 0, 1) 
            end
        end)
    end
end

local function toggleStretch(value)
    Settings.StretchEnabled = value
    applyStretch(value)
    notify("Растяг", value and "Включен (" .. Settings.StretchFactor .. ")" or "Выключен", 2)
end

-- ========================================
-- ===== CHINA HAT =====
-- ========================================

local tau = math.pi * 2

local function createChinaHatDrawings()
    for i = 1, #Cache.ChinaHatDrawings do
        pcall(function() Cache.ChinaHatDrawings[i][1]:Remove(); Cache.ChinaHatDrawings[i][2]:Remove() end)
    end
    Cache.ChinaHatDrawings = {}
    for i = 1, Settings.ChinaHatSides do
        Cache.ChinaHatDrawings[i] = {Drawing.new('Line'), Drawing.new('Triangle')}
        Cache.ChinaHatDrawings[i][1].ZIndex = 2; Cache.ChinaHatDrawings[i][1].Thickness = 2
        Cache.ChinaHatDrawings[i][2].ZIndex = 1; Cache.ChinaHatDrawings[i][2].Filled = true
    end
end

local function hatRemoveClassic()
    if Cache.ChinaHatParts[LocalPlayer.Character] then
        pcall(function() Cache.ChinaHatParts[LocalPlayer.Character]:Destroy() end)
        Cache.ChinaHatParts[LocalPlayer.Character] = nil
    end
end

local function hatAddClassic(char)
    task.wait(0.1)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    hatRemoveClassic()
    local hat = Instance.new("Part")
    hat.Name = "ChineseHat"
    hat.Transparency = Settings.ChinaHatTransparency
    hat.Color = Settings.ChinaHatColor
    hat.Material = Enum.Material.Neon
    hat.CanCollide = false
    hat.Reflectance = Settings.ChinaHatReflectance
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(Settings.ChinaHatRadius, Settings.ChinaHatHeight, Settings.ChinaHatRadius)
    mesh.Parent = hat
    local weld = Instance.new("WeldConstraint"); weld.Part0 = head; weld.Part1 = hat; weld.Parent = hat
    hat.CFrame = head.CFrame * CFrame.new(0, 1.1, 0)
    hat.Parent = char
    Cache.ChinaHatParts[char] = hat
end

local function hatUpdateClassic()
    for char, hat in pairs(Cache.ChinaHatParts) do
        if hat and hat.Parent and char == LocalPlayer.Character then
            hat.Transparency = Settings.ChinaHatTransparency
            hat.Reflectance = Settings.ChinaHatReflectance
            if Settings.ChinaHatRainbow then
                hat.Color = Color3.fromHSV(tick() % Settings.ChinaHatRainbowSpeed / Settings.ChinaHatRainbowSpeed, 1, 1)
            else
                hat.Color = Settings.ChinaHatColor
            end
            local mesh = hat:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = Vector3.new(Settings.ChinaHatRadius, Settings.ChinaHatHeight, Settings.ChinaHatRadius) end
        end
    end
end

local function hatUpdateDrawing()
    local pass = Settings.ChinaHatEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Head') ~= nil and (Camera.CFrame.p - Camera.Focus.p).magnitude > 1 and LocalPlayer.Character.Humanoid.Health > 0
    for i = 1, #Cache.ChinaHatDrawings do
        local line, triangle = Cache.ChinaHatDrawings[i][1], Cache.ChinaHatDrawings[i][2]
        if pass then
            local color
            if Settings.ChinaHatRainbow then
                color = Color3.fromHSV((tick() % Settings.ChinaHatRainbowSpeed / Settings.ChinaHatRainbowSpeed - (i / #Cache.ChinaHatDrawings)) % 1, 0.5, 1)
            else
                color = Settings.ChinaHatColor
            end
            local pos = LocalPlayer.Character.Head.Position + Vector3.new(0, 0.75, 0)
            local topWorld = pos + Vector3.new(0, 0.75, 0)
            local last, next = (i / Settings.ChinaHatSides) * tau, ((i + 1) / Settings.ChinaHatSides) * tau
            local lastWorld = pos + (Vector3.new(math.cos(last), 0, math.sin(last)) * Settings.ChinaHatRadius)
            local nextWorld = pos + (Vector3.new(math.cos(next), 0, math.sin(next)) * Settings.ChinaHatRadius)
            local lastScreen = Camera:WorldToViewportPoint(lastWorld)
            local nextScreen = Camera:WorldToViewportPoint(nextWorld)
            local topScreen = Camera:WorldToViewportPoint(topWorld)
            line.From = Vector2.new(lastScreen.X, lastScreen.Y); line.To = Vector2.new(nextScreen.X, nextScreen.Y)
            line.Color = color; line.Transparency = 1 - Settings.ChinaHatTransparency; line.Visible = true
            triangle.PointA = Vector2.new(topScreen.X, topScreen.Y); triangle.PointB = line.From; triangle.PointC = line.To
            triangle.Color = color; triangle.Transparency = 0.35; triangle.Visible = true
        else
            line.Visible = false; triangle.Visible = false
        end
    end
end

local function toggleChinaHat(value)
    Settings.ChinaHatEnabled = value
    if value then
        createChinaHatDrawings()
        if Settings.ChinaHatStyle == "Classic" and LocalPlayer.Character then hatAddClassic(LocalPlayer.Character) end
        if Cache.ChinaHatConnection then safeDisconnect(Cache.ChinaHatConnection) end
        Cache.ChinaHatConnection = RunService.Heartbeat:Connect(function()
            if Settings.ChinaHatStyle == "Classic" then hatUpdateClassic()
            else hatUpdateDrawing() end
        end)
        notify("China Hat", "Включен (" .. Settings.ChinaHatStyle .. ")", 2)
    else
        hatRemoveClassic()
        for i = 1, #Cache.ChinaHatDrawings do pcall(function() Cache.ChinaHatDrawings[i][1].Visible = false; Cache.ChinaHatDrawings[i][2].Visible = false end) end
        if Cache.ChinaHatConnection then safeDisconnect(Cache.ChinaHatConnection); Cache.ChinaHatConnection = nil end
        notify("China Hat", "Выключен", 2)
    end
end

local function hatChangeStyle(value)
    local wasEnabled = Settings.ChinaHatEnabled
    Settings.ChinaHatStyle = value
    if wasEnabled then toggleChinaHat(false); task.wait(0.1); toggleChinaHat(true) end
    notify("China Hat", "Стиль: " .. value, 2)
end

-- ========================================
-- ===== AURA =====
-- ========================================

local AURA_IDS = {
    angel = "97658130917593", starlight = "134645216613107", heavenly = "139300897520961",
    ribbon = "132069507632161", sakura = "81755778619404", wind = "80694081850877",
    flow = "119913533725648", star = "73754563740680"
}
local AURA_ORDER = {"angel", "starlight", "heavenly", "ribbon", "sakura", "wind", "flow", "star"}
local AuraSelected = {}
for _, name in ipairs(AURA_ORDER) do AuraSelected[name] = false end

local function clearAura()
    for _, p in ipairs(Cache.AuraParticles) do pcall(function() p:Destroy() end) end
    Cache.AuraParticles = {}
end

local function loadAura(name)
    if Cache.AuraCache[name] then return Cache.AuraCache[name] end
    local id = AURA_IDS[name]
    if not id then return nil end
    local success, result = pcall(game.GetObjects, game, "rbxassetid://"..id)
    if success and result and result[1] then Cache.AuraCache[name] = result[1]; return result[1] end
    return nil
end

local function colorAura(model, color)
    local seq = ColorSequence.new(color)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("PointLight") then descendant.Color = color
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
            descendant.Color = seq
        end
    end
end

local function applyAura()
    clearAura()
    if not Settings.AuraEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, name in ipairs(AURA_ORDER) do
        if AuraSelected[name] then
            local aura_model = loadAura(name)
            if aura_model then
                colorAura(aura_model, Settings.AuraColor)
                local cloned = aura_model:Clone()
                for _, part in ipairs(cloned:GetChildren()) do
                    local target = char:FindFirstChild(part.Name)
                    if target and target:IsA("BasePart") then
                        for _, child in ipairs(part:GetChildren()) do
                            child.Parent = target
                            table.insert(Cache.AuraParticles, child)
                        end
                    end
                end
                cloned:Destroy()
            end
        end
    end
end

local function toggleAura(value)
    Settings.AuraEnabled = value
    if value then applyAura() else clearAura() end
end

-- ========================================
-- ===== FOV AIMBOT =====
-- ========================================

local function getClosestMurderInFov()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestP, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not checkKnife(player) then continue end
        if not player.Character then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local sp, onScreen = Camera:WorldToScreenPoint(hrp.Position)
        if not onScreen or sp.Z < 0 then continue end
        local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
        if d <= Settings.FovRadius and d < bestDist then bestDist = d; bestP = player end
    end
    return bestP
end

local function createFovCircle()
    if Cache.FovCircle then pcall(function() Cache.FovCircle:Remove() end) end
    local c = Drawing.new("Circle")
    c.Radius = Settings.FovRadius; c.Color = Color3.fromRGB(255,255,255); c.Thickness = 1.5; c.Transparency = 0.7; c.Filled = false; c.Visible = false; c.NumSides = 64
    Cache.FovCircle = c
end

local function setupFovAimbot()
    safeDisconnect(Cache.FovConnection); Cache.FovConnection = nil
    if Cache.FovCircle then Cache.FovCircle.Visible = false end
    if not Settings.FovAimbotEnabled then return end
    if not Cache.FovCircle then createFovCircle() end
    local circle = Cache.FovCircle
    Cache.FovConnection = RunService.RenderStepped:Connect(function()
        if not Settings.FovAimbotEnabled then circle.Visible = false; return end
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        circle.Position = center; circle.Radius = Settings.FovRadius; circle.Visible = true
        local target = getClosestMurderInFov()
        if target then
            circle.Color = Color3.fromRGB(255,50,50); circle.Thickness = 2.0
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity
                local predictedPos = hrp.Position + (vel * 0.1)
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos, Camera.CFrame.UpVector)
            end
        else
            circle.Color = Color3.fromRGB(255,255,255); circle.Thickness = 1.5
        end
    end)
end

-- ========================================
-- ===== KILL ALL =====
-- ========================================

local function FindKillRemote()
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local name = child.Name:lower()
            if name:find("kill") or name:find("attack") or name:find("damage") or name:find("murder") or name:find("slash") or name:find("stab") then
                Cache.KillAllRemote = child; return
            end
        end
    end
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then Cache.KillAllRemote = child; return end
    end
end
FindKillRemote()

local function KillAllPlayers()
    if not Cache.KillAllRemote then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            pcall(function() Cache.KillAllRemote:FireServer(player) end)
            pcall(function() Cache.KillAllRemote:FireServer(player.Character) end)
            pcall(function() Cache.KillAllRemote:FireServer(player.Character.HumanoidRootPart) end)
        end
    end
end

local function setupKillAll()
    safeDisconnect(Cache.KillAllConn); Cache.KillAllConn = nil
    if not Settings.KillAllEnabled then return end
    Cache.KillAllConn = RunService.Stepped:Connect(function() if Settings.KillAllEnabled then KillAllPlayers() end end)
end

local function toggleKillAll(value)
    Settings.KillAllEnabled = value
    if value then
        if not Cache.KillAllRemote then FindKillRemote() end
        setupKillAll()
        notify("Kill All", "Включен (нужна роль убийцы)", 2)
    else
        safeDisconnect(Cache.KillAllConn); notify("Kill All", "Выключен", 2)
    end
end

-- ========================================
-- ===== FLING FUNCTIONS (ИЗ FOGYHUB) =====
-- ========================================

local function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then 
        notify("Флинг", "Игрок не найден!", 2)
        return 
    end
    
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart or (Character and Character:FindFirstChild("HumanoidRootPart"))
    
    local TCharacter = targetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    
    if Character and Humanoid and RootPart then
        if THumanoid and THumanoid.Sit then
            notify("Флинг", targetPlayer.Name .. " сидит!", 2)
            return
        end
        
        notify("Флинг", "Выбиваем: " .. targetPlayer.DisplayName, 2)
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
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
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
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
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick()
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart 
        BV.Velocity = Vector3.new() 
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart then SFBasePart(TRootPart) elseif THead then SFBasePart(THead) end
        BV:Destroy() 
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    else
        notify("Флинг", "Персонаж не готов!", 2)
    end
end

-- Поиск Murderer и Sheriff для флинга
local function getMurdererFling()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if (bp and bp:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife") then
                return p
            end
        end
    end
    return nil
end

local function getSheriffFling()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            local hasGun = (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver"))) or 
                          p.Character:FindFirstChild("Gun") or 
                          p.Character:FindFirstChild("Revolver")
            if hasGun then
                return p
            end
        end
    end
    return nil
end


-- ========================================
-- ===== GRAB GUN (УЛУЧШЕННЫЙ ИЗ FOGYHUB) =====
-- ========================================

local grabbingGun = false

local function grabGunImproved()
    if grabbingGun then return end
    if not LocalPlayer.Character then return end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then
        notify("Grab Gun", "Персонаж не найден", 2)
        return
    end
    
    -- Проверка на убийцу (не должен подбирать пушку)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local isMurderer = (char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
    if isMurderer then
        notify("Grab Gun", "Ты убийца, пушка не нужна!", 2)
        return
    end
    
    -- Проверка есть ли уже пушка
    local function hasGun()
        local currentBp = LocalPlayer:FindFirstChild("Backpack")
        return (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")) or 
               (currentBp and (currentBp:FindFirstChild("Gun") or currentBp:FindFirstChild("Revolver")))
    end
    if hasGun() then 
        notify("Grab Gun", "У тебя уже есть пушка!", 2)
        return 
    end
    
    -- Поиск пушки на земле
    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
    local handle = gunDrop and (gunDrop:FindFirstChild("Handle", true) or gunDrop:FindFirstChildOfClass("Part", true) or gunDrop)
    if not handle then
        notify("Grab Gun", "Пушки нет на карте!", 2)
        return
    end
    
    grabbingGun = true
    
    local originalCFrame = hrp.CFrame
    local targetCFrame = handle:IsA("Model") and handle:GetPivot() or handle.CFrame
    
    -- Телепорт к пушке
    hrp.CFrame = targetCFrame * CFrame.new(0, -1, 0)
    
    -- Триггер подбора через TouchInterest
    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, handle, 0)
            task.wait(0.02)
            firetouchinterest(hrp, handle, 1)
        end)
    end
    
    task.wait(0.15)
    
    -- Возврат на место
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = originalCFrame
    end
    
    -- Проверка подобралась ли пушка
    task.wait(0.1)
    if hasGun() then
        notify("Grab Gun", "Пушка подобрана!", 2)
    else
        notify("Grab Gun", "Не удалось подобрать пушку!", 2)
    end
    
    grabbingGun = false
end

local function toggleGrabGun()
    grabGunImproved()
end

-- ========================================
-- ===== SHOOT BUTTON =====
-- ========================================

local function createGunBeam(startPos, endPos, color, duration)
    duration = duration or 0.2
    color = color or Color3.fromRGB(180, 50, 255)
    local distance = (startPos - endPos).Magnitude
    if distance < 1 then return end
    local beam = Instance.new("Part")
    beam.Name = "GunBeam"
    beam.Size = Vector3.new(0.15, 0.15, distance)
    beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Color = color
    beam.Transparency = 0.1
    beam.Parent = workspace
    local light = Instance.new("PointLight")
    light.Color = color; light.Brightness = 10; light.Range = 15; light.Parent = beam
    task.spawn(function()
        for i = 1, 10 do
            task.wait(duration / 10)
            beam.Transparency = beam.Transparency + 0.09
            beam.Size = Vector3.new(beam.Size.X * 0.95, beam.Size.Y * 0.95, beam.Size.Z)
        end
        beam:Destroy()
    end)
    return beam
end

local function createShootButton()
    if Cache.ShootButton then pcall(function() Cache.ShootButton:Destroy() end) end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShootButton"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = UDim2.new(0.5, -50, 0.6, 0)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    button.BackgroundTransparency = 0.15
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "Выстрел"
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderTransparency = 0.3
    button.Parent = screenGui
    button.ClipsDescendants = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local clickStartPos = nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragStart = input.Position
            clickStartPos = input.Position
            startPos = button.Position
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.BackgroundTransparency = 0.1
        end
    end)
    button.InputChanged:Connect(function(input)
        if not dragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude > 10 then isDragging = true end
            if isDragging then
                button.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            button.BackgroundTransparency = 0.15
            if clickStartPos and (input.Position - clickStartPos).Magnitude < 10 then
                task.spawn(function()
                    if not LocalPlayer.Character then return end
                    if not equipGun() then
                        notify("Выстрел", "Оружие не найдено", 2)
                        return
                    end
                    local target, targetDist = nil, math.huge
                    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not myHRP then return end
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and checkKnife(player) and isPlayerVisible(player) then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (myHRP.Position - hrp.Position).Magnitude
                                if dist < targetDist then
                                    targetDist = dist
                                    target = player
                                end
                            end
                        end
                    end
                    if not target then
                        notify("Выстрел", "Убийца не найден", 2)
                        return
                    end
                    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                    if not tHRP then return end
                    local beamStart = Camera.CFrame.Position
                    local vel = tHRP.AssemblyLinearVelocity
                    local predictedPos = tHRP.Position + (vel * 0.1)
                    createGunBeam(beamStart, predictedPos, Color3.fromRGB(180, 50, 255), 0.2)
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.MouseButton1, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.MouseButton1, false, game)
                    end)
                end)
            end
            isDragging = false
            dragStart = nil
            clickStartPos = nil
        end
    end)
    Cache.ShootButton = screenGui
    return screenGui
end

local function toggleShootButton(enabled)
    Settings.ShootButtonEnabled = enabled
    if enabled then
        createShootButton()
    else
        if Cache.ShootButton then
            pcall(function() Cache.ShootButton:Destroy() end)
            Cache.ShootButton = nil
        end
    end
end

-- ========================================
-- ===== SHERIFF AUTO SHOOT (С АИМОМ) =====
-- ========================================

local function getTargetPart(target)
    local char = target.Character
    if not char then return nil end
    if Settings.AimTargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif Settings.AimTargetPart == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function smoothAim(current, target, smoothness)
    return current + (target - current) * smoothness
end

local function isVisible(targetPart)
    if not Settings.AimWallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return true end
    local origin = char:FindFirstChild("HumanoidRootPart")
    if not origin then return true end
    if not targetPart then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char, targetPart.Parent}
    local result = workspace:Raycast(origin.Position, (targetPart.Position - origin.Position), raycastParams)
    return result == nil
end

local function sheriffAutoShootLoop()
    while Settings.SheriffAutoShootEnabled do
        task.wait(0.03)
        if not LocalPlayer.Character then continue end
        if not checkGun(LocalPlayer) then continue end
        
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
        
        local target, targetDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            if not checkKnife(player) then continue end
            
            local targetPart = getTargetPart(player)
            if not targetPart then continue end
            
            -- Wall Check
            if not isVisible(targetPart) then continue end
            
            local dist = (myHRP.Position - targetPart.Position).Magnitude
            if dist < targetDist and dist <= 100 then
                targetDist = dist
                target = player
            end
        end
        
        if target then
            local targetPart = getTargetPart(target)
            if not targetPart then continue end
            
            local targetPos = targetPart.Position
            
            -- Predict
            if Settings.AimPredict then
                local vel = targetPart.AssemblyLinearVelocity
                targetPos = targetPos + (vel * 0.12)
            end
            
            -- Smoothness
            local current = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(current, targetPos)
            
            if Settings.AimSmoothness < 1 then
                local smoothPos = smoothAim(current, lookAt.Position, Settings.AimSmoothness)
                local smoothLook = CFrame.lookAt(smoothPos, targetPos)
                Camera.CFrame = smoothLook
            else
                Camera.CFrame = lookAt
            end
            
            -- Shoot
            createGunBeam(Camera.CFrame.Position, targetPos, Color3.fromRGB(180, 50, 255), 0.15)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.MouseButton1, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.MouseButton1, false, game)
            end)
            task.wait(0.25)
        end
    end
end

local function toggleSheriffAutoShoot(value)
    Settings.SheriffAutoShootEnabled = value
    safeDisconnect(Cache.SheriffAutoShootConnection)
    Cache.SheriffAutoShootConnection = nil
    if value then
        Cache.SheriffAutoShootConnection = task.spawn(sheriffAutoShootLoop)
        notify("Sheriff AutoShoot", "Включен", 2)
    else
        notify("Sheriff AutoShoot", "Выключен", 2)
    end
end

-- ========================================
-- ===== WALL HOP =====
-- ========================================

local function setupWallHop()
    safeDisconnect(Cache.WallHopConnection); Cache.WallHopConnection = nil
    if not Settings.WallHopEnabled then return end
    Cache.WallHopConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function toggleWallHop(value)
    Settings.WallHopEnabled = value
    if value then
        setupWallHop()
        notify("Wall Hop", "Включен (зажми Space)", 2)
    else
        safeDisconnect(Cache.WallHopConnection)
        notify("Wall Hop", "Выключен", 2)
    end
end

-- ========================================
-- ===== ANTI FLING =====
-- ========================================

local function setupAntiFling()
    safeDisconnect(Cache.antiFlingConn); Cache.antiFlingConn = nil
    if not Settings.AntiFlingEnabled then return end
    Cache.antiFlingConn = RunService.Heartbeat:Connect(function()
        if not Settings.AntiFlingEnabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 200 then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if hrp.AssemblyAngularVelocity.Magnitude > 20 then
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end)
end

-- ========================================
-- ===== NOCLIP =====
-- ========================================

local function setupNoclip(value)
    if value then
        if not Cache.noclipConn then
            Cache.noclipConn = RunService.Stepped:Connect(function()
                if not LocalPlayer.Character then return end
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        if Cache.noclipConn then
            Cache.noclipConn:Disconnect()
            Cache.noclipConn = nil
        end
    end
end

-- ========================================
-- ===== ANTI AFK =====
-- ========================================

local function setupAntiAFK()
    safeDisconnect(Cache.afkConn); Cache.afkConn = nil
    if not Settings.AntiAFKEnabled then return end
    local last = 0
    Cache.afkConn = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local now = tick()
        if now - last > 60 then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
                last = now
            end
        end
    end)
end

-- ========================================
-- ===== AUTO FARM =====
-- ========================================

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        local gameGui = gui:FindFirstChild("Game")
        if not gameGui then return 0 end
        local coinBags = gameGui:FindFirstChild("CoinBags")
        if not coinBags then return 0 end
        local container = coinBags:FindFirstChild("Container")
        if not container then return 0 end
        local coin = container:FindFirstChild("Coin")
        if not coin then return 0 end
        local currencyFrame = coin:FindFirstChild("CurrencyFrame")
        if not currencyFrame then return 0 end
        local icon = currencyFrame:FindFirstChild("Icon")
        if not icon then return 0 end
        local coinsText = icon:FindFirstChild("Coins")
        if not coinsText then return 0 end
        return coinsText.Text
    end)
    return ok and (tonumber(res) or 0) or 0
end

local function getValidCoins()
    local coins = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return coins end
    for _, map in pairs(Workspace:GetChildren()) do
        local container = map:FindFirstChild("CoinContainer")
        if container then
            for _, coin in pairs(container:GetChildren()) do
                if coin.Name == "Coin_Server" and coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                    table.insert(coins, {part=coin, distance=(hrp.Position-coin.Position).Magnitude})
                end
            end
        end
    end
    table.sort(coins, function(a,b) return a.distance < b.distance end)
    return coins
end

local function tweenToCoin(coin)
    if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    local target = coin.Position + Vector3.new(0, 2, 0)
    if (hrp.Position - target).Magnitude < 5 then return true end
    if Cache.CurrentTween then pcall(function() Cache.CurrentTween:Cancel() end) end
    Cache.CurrentTween = TweenService:Create(hrp,
        TweenInfo.new((hrp.Position-target).Magnitude / Settings.AutoFarmSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(target)}
    )
    hum.Sit = true
    Cache.CurrentTween:Play()
    local done = false
    local c
    c = Cache.CurrentTween.Completed:Connect(function() done = true; safeDisconnect(c) end)
    local t0 = tick()
    while not done and Settings.AutoFarmEnabled do
        task.wait(0.1)
        if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then
            if Cache.CurrentTween then pcall(function() Cache.CurrentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
        if tick() - t0 > 30 then
            if Cache.CurrentTween then pcall(function() Cache.CurrentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
    end
    hum.Sit = false
    return done
end

local function collectCoin(coin)
    if not coin or not coin.Parent then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        firetouchinterest(hrp, coin, 0)
        task.wait(0.05)
        firetouchinterest(hrp, coin, 1)
    end)
end

local function farmLoop()
    while Settings.AutoFarmEnabled do
        if not LocalPlayer.Character then task.wait(1) continue end
        local coins = getCurrentCoins()
        if coins >= Settings.AutoFarmCoinLimit then
            if Settings.AutoRespawn then
                notify("Авто фарм", "Респавн... (" .. coins .. " монет)", 2)
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = 0
                    end
                end
                task.wait(5)
                continue
            else
                Settings.AutoFarmEnabled = false
                notify("Авто фарм", "Сумка полна - остановлено", 3)
                break
            end
        end
        local validCoins = getValidCoins()
        if #validCoins == 0 then task.wait(2) continue end
        local ok = tweenToCoin(validCoins[1].part)
        if ok and Settings.AutoFarmEnabled then
            collectCoin(validCoins[1].part)
            task.wait(Settings.AutoFarmCoinDelay)
        end
        task.wait(0.1)
    end
    Cache.AutoFarmConn = nil
end

local function setupAutoFarm()
    if Settings.AutoFarmEnabled then
        if not LocalPlayer.Character then return end
        Cache.AutoFarmConn = task.spawn(farmLoop)
        notify("Авто фарм", "Запущен", 3)
    else
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = false end
        end
        if Cache.CurrentTween then
            pcall(function() Cache.CurrentTween:Cancel() end)
            Cache.CurrentTween = nil
        end
    end
end

-- ========================================
-- ===== ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ =====
-- ========================================

local function updateVisuals()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            if Settings.ChamsEnabled then applyChams(player)
            elseif Cache.ChamsPartsList[player.UserId] then removeChams(player) end
            continue
        end
        if not player.Character then continue end
        local role = getRole(player)
        if Settings.MurderESP and role == "Убийца" then
            createOrUpdateHighlight(player, Settings.MurderColor)
        elseif Settings.SheriffESP and role == "Шериф" then
            createOrUpdateHighlight(player, Settings.SheriffColor)
        elseif Settings.InnocentESP and role == "Невинный" then
            createOrUpdateHighlight(player, Settings.InnocentColor)
        else
            removeHighlight(player)
        end
        if Settings.ChamsEnabled then
            applyChams(player)
        elseif Cache.ChamsPartsList[player.UserId] then
            removeChams(player)
        end
    end
end

local function startMainUpdate()
    safeDisconnect(Cache.mainConn); Cache.mainConn = nil
    Cache.mainConn = RunService.Heartbeat:Connect(function()
        removeCore()
        if Settings.MurderESP or Settings.SheriffESP or Settings.InnocentESP or Settings.ChamsEnabled or Settings.Trails or Settings.TracersEnabled then
            updateVisuals()
        end
        if Settings.TracersEnabled then
            updateTracers()
        end
        if Settings.JumpCircles then
            updateJumpCircles()
        end
    end)
end

local function setupSheriffDeadNotif()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterRemoving:Connect(function()
                if checkGun(player) then
                    notify("Шериф", player.Name .. " мёртв", 3)
                end
            end)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Died:Connect(function()
                    if checkGun(player) then
                        notify("Шериф", player.Name .. " мёртв", 3)
                    end
                end)
            end
        end)
    end)
end

-- ========================================
-- ===== GUI =====
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlanetHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 1, 0)
container.BackgroundTransparency = 1
container.Parent = screenGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 800, 0, 550)
main.Position = UDim2.new(0.5, -400, 0.5, -275)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.Parent = container

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = Theme.Card
header.BorderSizePixel = 0
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PLANET HUB"
title.TextColor3 = Theme.Text
title.TextSize = 18
title.Font = FontBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -46, 0.5, -18)
closeBtn.BackgroundColor3 = Theme.Element
closeBtn.Text = "х"
closeBtn.TextColor3 = Theme.SubText
closeBtn.TextSize = 16
closeBtn.Font = FontBold
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 90, 90), TextColor3 = Theme.Text}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element, TextColor3 = Theme.SubText}):Play()
end)

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(0, 160, 1, -64)
tabBar.Position = UDim2.new(0, 8, 0, 56)
tabBar.BackgroundColor3 = Theme.Card
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local tabBarLayout = Instance.new("UIListLayout")
tabBarLayout.Padding = UDim.new(0, 6)
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.FillDirection = Enum.FillDirection.Vertical
tabBarLayout.Parent = tabBar

local tabBarPadding = Instance.new("UIPadding")
tabBarPadding.PaddingTop = UDim.new(0, 10)
tabBarPadding.PaddingBottom = UDim.new(0, 10)
tabBarPadding.PaddingLeft = UDim.new(0, 10)
tabBarPadding.PaddingRight = UDim.new(0, 10)
tabBarPadding.Parent = tabBar

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -184, 1, -64)
contentArea.Position = UDim2.new(0, 176, 0, 56)
contentArea.BackgroundColor3 = Theme.Card
contentArea.BorderSizePixel = 0
contentArea.Parent = main

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, 0)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = Theme.Accent
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = contentArea

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 12)
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.PaddingLeft = UDim.new(0, 12)
contentPadding.PaddingRight = UDim.new(0, 12)
contentPadding.Parent = content

-- ТАБЫ
local tabs = {
    {name = "Visuals", icon = Icons.Eye},
    {name = "Combat", icon = Icons.Crosshair},
    {name = "Movement", icon = Icons.Wind},
    {name = "Farm", icon = Icons.Tractor},
    {name = "Animations", icon = Icons.Music},
    {name = "Fun", icon = Icons.Smile},
}

local tabButtons = {}
local tabPages = {}

local function updateCanvas()
    task.wait(0.05)
    local totalHeight = 24
    for _, page in pairs(tabPages) do
        if page.Visible then
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
                    totalHeight = totalHeight + child.AbsoluteSize.Y + 12
                end
            end
        end
    end
    content.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

local function switchTab(name)
    for n, btn in pairs(tabButtons) do
        if btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
            local lbl = btn:FindFirstChild("Label")
            if lbl then TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}):Play() end
            local ico = btn:FindFirstChild("Icon")
            if ico then TweenService:Create(ico, TweenInfo.new(0.2), {ImageColor3 = Theme.SubText}):Play() end
        end
    end
    for n, page in pairs(tabPages) do if page then page.Visible = false end end
    local btn = tabButtons[name]
    if btn then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
        local lbl = btn:FindFirstChild("Label")
        if lbl then TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play() end
        local ico = btn:FindFirstChild("Icon")
        if ico then TweenService:Create(ico, TweenInfo.new(0.2), {ImageColor3 = Theme.Accent}):Play() end
    end
    if tabPages[name] then tabPages[name].Visible = true end
    updateCanvas()
end

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tab.name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Theme.Card
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.BorderSizePixel = 0
    btn.Parent = tabBar

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = tab.icon
    icon.ImageColor3 = Theme.SubText
    icon.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 38, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tab.name
    label.TextColor3 = Theme.SubText
    label.TextSize = 14
    label.Font = Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    tabButtons[tab.name] = btn

    local page = Instance.new("Frame")
    page.Name = tab.name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 12)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.Parent = page
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    tabPages[tab.name] = page
    btn.MouseButton1Click:Connect(function() switchTab(tab.name) end)
end

-- UI ELEMENTS
local function createCard(page, titleText, order)
    local card = Instance.new("Frame")
    card.Name = titleText .. "Card"
    card.BackgroundColor3 = Theme.Element
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = card

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = card

    local head = Instance.new("TextLabel")
    head.Name = "CardTitle"
    head.Size = UDim2.new(1, 0, 0, 20)
    head.BackgroundTransparency = 1
    head.Text = titleText
    head.TextColor3 = Theme.Text
    head.TextSize = 15
    head.Font = FontBold
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.LayoutOrder = 0
    head.Parent = card

    local sep = Instance.new("Frame")
    sep.Name = "Separator"
    sep.Size = UDim2.new(1, 0, 0, 2)
    sep.BackgroundColor3 = Theme.Stroke
    sep.BorderSizePixel = 0
    sep.LayoutOrder = 1
    sep.Parent = card

    return card
end

local function createColorInput(card, name, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Color"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 11
    frame.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. " Цвет"
    label.TextColor3 = Theme.SubText
    label.TextSize = 13
    label.Font = Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.4, 0, 0, 26)
    box.Position = UDim2.new(0.5, 0, 0.5, -13)
    box.BackgroundColor3 = Theme.Card
    box.TextColor3 = Theme.Text
    local r = math.floor(defaultColor.R * 255)
    local g = math.floor(defaultColor.G * 255)
    local b = math.floor(defaultColor.B * 255)
    box.Text = r .. "," .. g .. "," .. b
    box.PlaceholderText = "R,G,B или #HEX"
    box.PlaceholderColor3 = Theme.SubText
    box.TextSize = 12
    box.Font = Font
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = frame

    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 20, 0, 20)
    colorPreview.Position = UDim2.new(0.92, 0, 0.5, -10)
    colorPreview.BackgroundColor3 = defaultColor
    colorPreview.BorderSizePixel = 1
    colorPreview.BorderColor3 = Theme.Stroke
    colorPreview.Parent = frame

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = colorPreview

    box.FocusLost:Connect(function(enter)
        if enter then
            local color = colorInputToColor3(box.Text)
            if color then
                colorPreview.BackgroundColor3 = color
                if callback then callback(color) end
            else
                notify("Цвет", "Неверный формат! Используй R,G,B или #HEX", 2)
            end
        end
    end)
end

local function createToggle(card, name, default, callback, bindName)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Toggle"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 10
    frame.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.SubText
    label.TextSize = 13
    label.Font = Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 24)
    btn.Position = UDim2.new(1, -44, 0.5, -12)
    btn.BackgroundColor3 = Theme.Card
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Theme.SubText
    knob.BorderSizePixel = 0
    knob.Parent = btn

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 20, 0, 20)
    bindBtn.Position = UDim2.new(1, -68, 0.5, -10)
    bindBtn.BackgroundTransparency = 1
    bindBtn.Text = "⋯"
    bindBtn.TextColor3 = Theme.SubText
    bindBtn.TextSize = 16
    bindBtn.Font = FontBold
    bindBtn.AutoButtonColor = false
    bindBtn.BorderSizePixel = 0
    bindBtn.Parent = frame

    local on = default or false
    local function upd()
        if on then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Theme.Text}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Theme.SubText}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}):Play()
        end
        if callback then callback(on) end
    end
    btn.MouseButton1Click:Connect(function() on = not on; upd() end)
    upd()

    if bindName then
        local currentBind = Settings.Binds[bindName] or ""
        local bindLabel = Instance.new("TextLabel")
        bindLabel.Size = UDim2.new(0, 30, 1, 0)
        bindLabel.Position = UDim2.new(1, -100, 0, 0)
        bindLabel.BackgroundTransparency = 1
        bindLabel.Text = currentBind
        bindLabel.TextColor3 = Theme.Accent
        bindLabel.TextSize = 10
        bindLabel.Font = Font
        bindLabel.TextXAlignment = Enum.TextXAlignment.Right
        bindLabel.Parent = frame

        bindBtn.MouseButton1Click:Connect(function()
            createBindPopup(function(key)
                Settings.Binds[bindName] = key
                bindLabel.Text = key
                if Cache.BindConnections[bindName] then
                    safeDisconnect(Cache.BindConnections[bindName])
                    Cache.BindConnections[bindName] = nil
                end
                Cache.BindConnections[bindName] = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.KeyCode.Name == key then
                        on = not on
                        upd()
                    end
                end)
            end)
        end)
    end
end

local function createButton(card, name, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Card
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13
    btn.Font = Font
    btn.AutoButtonColor = false
    btn.LayoutOrder = 10
    btn.BorderSizePixel = 0
    btn.Parent = card

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

local function createSlider(card, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Slider"
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 10
    frame.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.SubText
    label.TextSize = 13
    label.Font = Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.3, 0, 0, 20)
    val.Position = UDim2.new(0.7, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(default or min)
    val.TextColor3 = Theme.Accent
    val.TextSize = 13
    val.Font = FontBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = frame

    local back = Instance.new("Frame")
    back.Size = UDim2.new(1, 0, 0, 8)
    back.Position = UDim2.new(0, 0, 0, 30)
    back.BackgroundColor3 = Theme.Card
    back.BorderSizePixel = 0
    back.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = back

    local dragging = false
    local cur = default or min
    local function upd(input)
        local pos = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        cur = math.floor(min + (max - min) * pos)
        val.Text = tostring(cur)
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        if callback then callback(cur) end
    end
    back.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            upd(i)
        end
    end)
    back.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
end

local function createInput(card, name, default, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Input"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 10
    frame.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.SubText
    label.TextSize = 13
    label.Font = Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.65, 0, 0, 26)
    box.Position = UDim2.new(0.35, 0, 0.5, -13)
    box.BackgroundColor3 = Theme.Card
    box.TextColor3 = Theme.Text
    box.Text = default or ""
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Theme.SubText
    box.TextSize = 12
    box.Font = Font
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = frame
    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)
end

-- ========================================
-- ===== ПОСТРОЕНИЕ ТАБОВ =====
-- ========================================

-- Visuals Tab
local vp = tabPages["Visuals"]

local espCard = createCard(vp, "ESP", 1)
createToggle(espCard, "ESP Убийца", false, function(v) Settings.MurderESP = v; startMainUpdate() end, "MurderESP")
createColorInput(espCard, "Убийца", Settings.MurderColor, function(c) Settings.MurderColor = c; startMainUpdate() end)
createToggle(espCard, "ESP Шериф", false, function(v) Settings.SheriffESP = v; startMainUpdate() end, "SheriffESP")
createColorInput(espCard, "Шериф", Settings.SheriffColor, function(c) Settings.SheriffColor = c; startMainUpdate() end)
createToggle(espCard, "ESP Невинный", false, function(v) Settings.InnocentESP = v; startMainUpdate() end, "InnocentESP")
createColorInput(espCard, "Невинный", Settings.InnocentColor, function(c) Settings.InnocentColor = c; startMainUpdate() end)
createToggle(espCard, "Трассеры", false, function(v)
    Settings.TracersEnabled = v
    if v then
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then createTracer(p) end
        end
    else
        clearAllTracers()
    end
    startMainUpdate()
end, "Tracers")
createColorInput(espCard, "Трассеры", Settings.TracersColor, function(c)
    Settings.TracersColor = c
    for userId, line in pairs(Cache.Tracers) do
        line.Color = c
    end
end)

local chamsCard = createCard(vp, "Chams", 2)
createToggle(chamsCard, "Включить Chams", false, function(v) Settings.ChamsEnabled = v; updateChamsForAll(); startMainUpdate() end, "Chams")
createColorInput(chamsCard, "Chams", Settings.ChamsColor, function(c)
    Settings.ChamsColor = c
    if Settings.ChamsEnabled then updateChamsForAll() end
end)
createToggle(chamsCard, "RGB Humanoid", false, function(v) Settings.RGBHumanoid = v; setupRGBHumanoid() end, "RGBHumanoid")

local worldCard = createCard(vp, "World", 3)
createToggle(worldCard, "Texture Pack", false, function(v) toggleTexturePack(v) end, "TexturePack")
createToggle(worldCard, "Орбизы", false, function(v) toggleOrbiz(v) end, "Orbiz")
createInput(worldCard, "Выбор неба", "HD", "HD, Space, Galaxy, etc.", function(v) Settings.CustomSkyId = v end)
createButton(worldCard, "Применить небо", function()
    if Settings.CustomSkyId and Settings.CustomSkyId ~= "" then setupSky(Settings.CustomSkyId) end
end)
createButton(worldCard, "Удалить небо", function() removeSky() end)
createButton(worldCard, "Космос", function() setupSky("Space") end)
createButton(worldCard, "Галактика", function() setupSky("Galaxy") end)

local stretchCard = createCard(vp, "Screen Stretch", 4)
createToggle(stretchCard, "Растяг экрана (4:3)", false, function(v)
    Settings.StretchEnabled = v
    applyStretch(v)
end, "Stretch")
createSlider(stretchCard, "Сила растяга", 50, 100, 75, function(v)
    Settings.StretchFactor = v / 100
    if Settings.StretchEnabled then applyStretch(true) end
end)
local fxCard = createCard(vp, "Effects", 6)
createToggle(fxCard, "Круги прыжка", false, function(v) Settings.JumpCircles = v; startMainUpdate() end, "JumpCircles")
createColorInput(fxCard, "Круги", Settings.JumpCirclesColor, function(c)
    Settings.JumpCirclesColor = c
end)
createToggle(fxCard, "Фиолетовый след", false, function(v)
    Settings.Trails = v
    if v then createLocalPlayerTrail() else removeLocalPlayerTrail() end
    startMainUpdate()
end, "Trails")
createColorInput(fxCard, "След", Settings.TrailsColor, function(c)
    Settings.TrailsColor = c
    updateTrailColor()
end)
createToggle(fxCard, "XRay", false, function(v) Settings.XRayEnabled = v; setupXRay() end, "XRay")
createToggle(fxCard, "Bloom", false, function(v) Settings.BloomEnabled = v; setupBloom(v) end, "Bloom")
createToggle(fxCard, "Цветокоррекция", false, function(v) Settings.ColorCorrectionEnabled = v; setupColorCorrection(v) end, "ColorCorrection")
createToggle(fxCard, "Виньетка", false, function(v) Settings.VignetteEnabled = v; setupVignette(v) end, "Vignette")

-- China Hat
local chinaCard = createCard(vp, "China Hat", 5)
createToggle(chinaCard, "Включить", false, function(v) toggleChinaHat(v) end, "ChinaHat")
createColorInput(chinaCard, "Цвет", Settings.ChinaHatColor, function(c)
    Settings.ChinaHatColor = c
end)
createInput(chinaCard, "Стиль", "Classic", "Classic или Drawing", function(v)
    if v == "Classic" or v == "Drawing" then
        hatChangeStyle(v)
    else
        notify("China Hat", "Доступно: Classic, Drawing", 2)
    end
end)
createInput(chinaCard, "Прозрачность (0-1)", "0.3", "0.3", function(v)
    local n = tonumber(v)
    if n then Settings.ChinaHatTransparency = math.clamp(n, 0, 1) end
end)
createInput(chinaCard, "Радиус", "2.4", "2.4", function(v)
    local n = tonumber(v)
    if n then Settings.ChinaHatRadius = math.max(n, 0.5) end
end)
createInput(chinaCard, "Высота", "1.6", "1.6", function(v)
    local n = tonumber(v)
    if n then Settings.ChinaHatHeight = math.max(n, 0.5) end
end)
createToggle(chinaCard, "Радужный режим", false, function(v) Settings.ChinaHatRainbow = v end, "ChinaHatRainbow")

-- Aura
local auraCard = createCard(vp, "Aura", 6)
createToggle(auraCard, "Включить ауру", false, function(v) toggleAura(v) end, "Aura")
createColorInput(auraCard, "Цвет ауры", Settings.AuraColor, function(c)
    Settings.AuraColor = c
    if Settings.AuraEnabled then applyAura() end
end)
for _, name in ipairs(AURA_ORDER) do
    createToggle(auraCard, name:upper(), false, function(v)
        AuraSelected[name] = v
        if Settings.AuraEnabled then applyAura() end
    end, "Aura_" .. name)
end

-- Combat Tab
local cp = tabPages["Combat"]

local combatCard = createCard(cp, "Combat", 1)
createToggle(combatCard, "Кнопка выстрела", false, function(v) toggleShootButton(v) end, "ShootButton")
createToggle(combatCard, "Sheriff AutoShoot", false, function(v) toggleSheriffAutoShoot(v) end, "SheriffAutoShoot")
createToggle(combatCard, "Kill All (убийца)", false, function(v) toggleKillAll(v) end, "KillAll")
createToggle(combatCard, "Флинг Убийцу", false, function(v)
    Settings.FlingMurderer = v
    if v then
        local m = getMurdererFling()
        if m then flingPlayer(m) else 
            notify("Флинг", "Убийца не найден!", 2)
            Settings.FlingMurderer = false
        end
    end
end, "FlingMurderer")
createToggle(combatCard, "Флинг Шерифа", false, function(v)
    Settings.FlingSheriff = v
    if v then
        local s = getSheriffFling()
        if s then flingPlayer(s) else 
            notify("Флинг", "Шериф не найден!", 2)
            Settings.FlingSheriff = false
        end
    end
end, "FlingSheriff")
createToggle(combatCard, "Grab Gun", false, function(v)
    Settings.GrabGunEnabled = v
    if v then grabGunImproved() end
end, "GrabGunEnabled")

local aimCard = createCard(cp, "Aimbot", 2)
createToggle(aimCard, "FOV Аимбот", false, function(v)
    Settings.FovAimbotEnabled = v
    if v then createFovCircle() end
    setupFovAimbot()
end, "FovAimbot")
createSlider(aimCard, "Радиус FOV", 10, 600, 120, function(v)
    Settings.FovRadius = v
    if Cache.FovCircle then Cache.FovCircle.Radius = Settings.FovRadius end
end)

-- НАСТРОЙКИ АИМА (ОДИН РАЗ!)
createSlider(aimCard, "Smoothness", 1, 100, 50, function(v)
    Settings.AimSmoothness = v / 100
end)
createToggle(aimCard, "Predict (упреждение)", true, function(v)
    Settings.AimPredict = v
end, "AimPredict")
createToggle(aimCard, "Wall Check", true, function(v)
    Settings.AimWallCheck = v
end, "AimWallCheck")
createToggle(aimCard, "Auto Shoot (Шериф)", false, function(v)
    toggleSheriffAutoShoot(v)
end, "SheriffAutoShoot")

local teleCard = createCard(cp, "Teleports", 3)
createButton(teleCard, "TP to Murder", function() teleportToRole("Убийца") end)
createButton(teleCard, "TP to Sheriff", function() teleportToRole("Шериф") end)

-- Movement Tab
local mp = tabPages["Movement"]

local moveCard = createCard(mp, "Movement", 1)
createToggle(moveCard, "Fly", false, function(v) toggleFly(v) end, "Fly")
createSlider(moveCard, "Fly Speed", 10, 200, 50, function(v) Settings.FlySpeed = v end)
createToggle(moveCard, "BHop", false, function(v) toggleBHop(v) end, "BHop")
createSlider(moveCard, "BHop Speed", 10, 80, 30, function(v) Settings.BHopSpeed = v end)
createToggle(moveCard, "Spin Bot", false, function(v) toggleSpinBot(v) end, "SpinBot")
createSlider(moveCard, "Spin Speed", 100, 20000, 9999, function(v) SpinBot.Speed = v end)
createToggle(moveCard, "Ноклип", false, function(v) Settings.NoclipEnabled = v; setupNoclip(v) end, "Noclip")
createToggle(moveCard, "Защита от флинга", false, function(v) Settings.AntiFlingEnabled = v; setupAntiFling() end, "AntiFling")
createToggle(moveCard, "Wall Hop", false, function(v) toggleWallHop(v) end, "WallHop")

-- Farm Tab
local fp = tabPages["Farm"]

local farmCard = createCard(fp, "Auto Farm", 1)
createToggle(farmCard, "Авто фарм", false, function(v) Settings.AutoFarmEnabled = v; setupAutoFarm() end, "AutoFarm")
createToggle(farmCard, "Авто респавн", true, function(v) Settings.AutoRespawn = v end, "AutoRespawn")
createSlider(farmCard, "Скорость фарма", 5, 50, 20, function(v) Settings.AutoFarmSpeed = v end)
createSlider(farmCard, "Лимит монет", 10, 100, 40, function(v) Settings.AutoFarmCoinLimit = v end)
createSlider(farmCard, "Задержка монет", 0.05, 0.5, 0.15, function(v) Settings.AutoFarmCoinDelay = v end)

-- Animations Tab
local ap = tabPages["Animations"]

local animCard = createCard(ap, "Animation Packs", 1)
createToggle(animCard, "Enable Animations", false, function(v)
    Settings.AnimPackEnabled = v
    if v and Settings.AnimPack ~= "" then applyAnimPack(Settings.AnimPack) end
end, "AnimPackEnabled")

local animGrid = Instance.new("Frame")
animGrid.Name = "AnimGrid"
animGrid.Size = UDim2.new(1, 0, 0, 0)
animGrid.BackgroundTransparency = 1
animGrid.LayoutOrder = 11
animGrid.AutomaticSize = Enum.AutomaticSize.Y
animGrid.Parent = animCard

local gridLayout = Instance.new("UIListLayout")
gridLayout.Padding = UDim.new(0, 6)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection = Enum.FillDirection.Vertical
gridLayout.Parent = animGrid

local row = nil
for i, packName in ipairs(ANIM_PACK_NAMES) do
    local col = (i - 1) % 2
    if col == 0 then
        row = Instance.new("Frame")
        row.Name = "Row"
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundTransparency = 1
        row.Parent = animGrid

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.Padding = UDim.new(0, 6)
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Parent = row
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -3, 1, 0)
    btn.BackgroundColor3 = Theme.Card
    btn.Text = packName
    btn.TextColor3 = Theme.Text
    btn.TextSize = 11
    btn.Font = Font
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        Settings.AnimPack = packName
        if Settings.AnimPackEnabled then
            applyAnimPack(packName)
            notify("Анимации", "Применено: " .. packName, 2)
        else
            Settings.AnimPackEnabled = true
            applyAnimPack(packName)
            notify("Анимации", "Применено: " .. packName, 2)
        end
    end)
end

-- ========================================
-- ===== FUN TAB =====
-- ========================================

local funp = tabPages["Fun"]

local funCard = createCard(funp, "Fun", 1)
createToggle(funCard, "Jerk", false, function(v) toggleJerk(v) end, "Jerk")
createToggle(funCard, "Защита от АФК", false, function(v) Settings.AntiAFKEnabled = v; setupAntiAFK() end, "AntiAFK")
createButton(funCard, "Рейджоин", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)


-- ========================================
-- ===== МЕНЮ =====
-- ========================================

local menuOpen = false

local function setMenu(open)
    menuOpen = open
    if open then
        container.Visible = true
        main.Size = UDim2.new(0, 800, 0, 0)
        main.Position = UDim2.new(0.5, -400, 0.5, 0)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 800, 0, 550),
            Position = UDim2.new(0.5, -400, 0.5, -275)
        }):Play()
        task.wait(0.45)
        updateCanvas()
    else
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 800, 0, 0),
            Position = UDim2.new(0.5, -400, 0.5, 0)
        }):Play()
        task.delay(0.3, function()
            if not menuOpen then container.Visible = false end
        end)
    end
end

closeBtn.MouseButton1Click:Connect(function() setMenu(false) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.J and not gp then
        setMenu(not menuOpen)
    end
end)

-- DRAG
local dragData = {dragging = false, startPos = nil, dragStart = nil}
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.dragStart = input.Position
        dragData.startPos = main.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragData.dragStart
        main.Position = UDim2.new(
            dragData.startPos.X.Scale,
            dragData.startPos.X.Offset + delta.X,
            dragData.startPos.Y.Scale,
            dragData.startPos.Y.Offset + delta.Y
        )
    end
end)

-- ========================================
-- ===== FPS ОВЕРЛЕЙ =====
-- ========================================

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "PlanetHubOverlay"
overlayGui.ResetOnSpawn = false
overlayGui.IgnoreGuiInset = true
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
overlayGui.DisplayOrder = 999
overlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local oHeader = Instance.new("Frame")
oHeader.Name = "Header"
oHeader.Size = UDim2.new(0, 150, 0, 30)
oHeader.Position = UDim2.new(1, -160, 0, 10)
oHeader.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
oHeader.BackgroundTransparency = 0.05
oHeader.BorderSizePixel = 0
oHeader.ClipsDescendants = true
oHeader.Parent = overlayGui

local oCorner = Instance.new("UICorner")
oCorner.CornerRadius = UDim.new(1, 0)
oCorner.Parent = oHeader

local oStroke = Instance.new("UIStroke")
oStroke.Color = Color3.fromRGB(40, 40, 50)
oStroke.Thickness = 1
oStroke.Transparency = 0.5
oStroke.Parent = oHeader

local oTitle = Instance.new("TextLabel")
oTitle.Size = UDim2.new(0, 48, 1, 0)
oTitle.Position = UDim2.new(0, 4, 0, 0)
oTitle.BackgroundTransparency = 1
oTitle.Text = "PLANET"
oTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
oTitle.TextSize = 12
oTitle.Font = Enum.Font.GothamBold
oTitle.TextXAlignment = Enum.TextXAlignment.Center
oTitle.TextYAlignment = Enum.TextYAlignment.Center
oTitle.Parent = oHeader

local oSep1 = Instance.new("Frame")
oSep1.Size = UDim2.new(0, 1, 0, 16)
oSep1.Position = UDim2.new(0, 56, 0.5, -8)
oSep1.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
oSep1.BorderSizePixel = 0
oSep1.Parent = oHeader

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 38, 1, 0)
fpsLabel.Position = UDim2.new(0, 61, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "60"
fpsLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
fpsLabel.TextSize = 12
fpsLabel.Font = Enum.Font.GothamMedium
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
fpsLabel.Parent = oHeader

local oSep2 = Instance.new("Frame")
oSep2.Size = UDim2.new(0, 1, 0, 16)
oSep2.Position = UDim2.new(0, 103, 0.5, -8)
oSep2.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
oSep2.BorderSizePixel = 0
oSep2.Parent = oHeader

local freeLabel = Instance.new("TextLabel")
freeLabel.Size = UDim2.new(0, 40, 1, 0)
freeLabel.Position = UDim2.new(0, 108, 0, 0)
freeLabel.BackgroundTransparency = 1
freeLabel.Text = "Free"
freeLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
freeLabel.TextSize = 11
freeLabel.Font = Enum.Font.GothamMedium
freeLabel.TextXAlignment = Enum.TextXAlignment.Center
freeLabel.TextYAlignment = Enum.TextYAlignment.Center
freeLabel.Parent = oHeader

oHeader.MouseButton1Click:Connect(function()
    setMenu(not menuOpen)
end)

local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        fpsLabel.Text = fps
        if fps >= 60 then
            fpsLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
        frameCount = 0
        lastTime = currentTime
    end
end)

local oDragging = false
local oDragStart, oStartPos
oHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        oDragging = true
        oDragStart = input.Position
        oStartPos = oHeader.Position
    end
end)
oHeader.InputChanged:Connect(function(input)
    if oDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - oDragStart
        oHeader.Position = UDim2.new(
            oStartPos.X.Scale,
            oStartPos.X.Offset + delta.X,
            oStartPos.Y.Scale,
            oStartPos.Y.Offset + delta.Y
        )
    end
end)
oHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        oDragging = false
    end
end)

-- ========================================
-- ===== СОБЫТИЯ ИГРОКОВ =====
-- ========================================

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.ChamsEnabled then
            cacheCharacterParts(player)
            applyChams(player)
        end
        if Settings.TracersEnabled and player ~= LocalPlayer then
            createTracer(player)
        end
        if Settings.MurderESP or Settings.SheriffESP or Settings.InnocentESP then
            local r = getRole(player)
            if Settings.MurderESP and r == "Убийца" then
                createOrUpdateHighlight(player, Settings.MurderColor)
            elseif Settings.SheriffESP and r == "Шериф" then
                createOrUpdateHighlight(player, Settings.SheriffColor)
            elseif Settings.InnocentESP and r == "Невинный" then
                createOrUpdateHighlight(player, Settings.InnocentColor)
            end
        end
        if Settings.AntiFlingEnabled and player ~= LocalPlayer then
            task.spawn(function()
                task.wait(0.5)
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    Cache.ChamsPartsList[player.UserId] = nil
    Cache.Highlights[player.UserId] = nil
    if Cache.Tracers[player.UserId] then
        pcall(function() Cache.Tracers[player.UserId]:Remove() end)
        Cache.Tracers[player.UserId] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    removeCore()
    if Cache.FlyRunning then
        Cache.FlyRunning = false
        if Cache.FlyE1 then
            Cache.FlyE1:Disconnect()
            Cache.FlyE1 = nil
        end
        if Cache.FlyE2 then
            Cache.FlyE2:Disconnect()
            Cache.FlyE2 = nil
        end
        Cache.FlyKeys = {a=false,d=false,w=false,s=false}
    end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    clearAllHighlights()
    clearAllChams()
    clearAllTracers()
    Cache.ChamsPartsList = {}
    removeCore()

    for _, player in ipairs(Players:GetPlayers()) do
        if Settings.ChamsEnabled then
            cacheCharacterParts(player)
            applyChams(player)
        end
        if Settings.TracersEnabled and player ~= LocalPlayer then
            createTracer(player)
        end
        if Settings.MurderESP or Settings.SheriffESP or Settings.InnocentESP then
            local r = getRole(player)
            if Settings.MurderESP and r == "Убийца" then
                createOrUpdateHighlight(player, Settings.MurderColor)
            elseif Settings.SheriffESP and r == "Шериф" then
                createOrUpdateHighlight(player, Settings.SheriffColor)
            elseif Settings.InnocentESP and r == "Невинный" then
                createOrUpdateHighlight(player, Settings.InnocentColor)
            end
        end
    end

    setupRGBHumanoid()
    Cache.JumpTracking = {wasJumping = false}

    if Settings.Trails then
        task.wait(0.1)
        createLocalPlayerTrail()
    end
    if Settings.FlyEnabled then
        task.wait(0.5)
        startFly()
    end
    if Settings.BHopEnabled then
        startBHop()
    end
    if Settings.AntiFlingEnabled then
        setupAntiFling()
    end
    if Settings.FovAimbotEnabled then
        setupFovAimbot()
    end
    if Settings.ShootButtonEnabled then
        createShootButton()
    end
    if Settings.WallHopEnabled then
        setupWallHop()
    end
    if Settings.SheriffAutoShootEnabled then
        toggleSheriffAutoShoot(true)
    end
    if Settings.TexturePackEnabled then
        task.wait(0.3)
        applyTexturePack()
    end
    if Settings.ChinaHatEnabled then
        task.wait(0.2)
        if Settings.ChinaHatStyle == "Classic" then
            hatAddClassic(LocalPlayer.Character)
        end
    end
    if Settings.AuraEnabled then
        task.wait(0.3)
        applyAura()
    end
    if Settings.OrbizEnabled then
        task.wait(0.2)
        createOrbiz()
    end
    if Settings.KillAllEnabled then
        task.wait(0.2)
        if not Cache.KillAllRemote then
            FindKillRemote()
        end
        setupKillAll()
    end
    if Settings.AnimPackEnabled and Settings.AnimPack ~= "" then
        task.wait(0.3)
        applyAnimPack(Settings.AnimPack)
    end
end)

-- ========================================
-- ===== ЗАПУСК =====
-- ========================================

startMainUpdate()
setupSheriffDeadNotif()
createFovCircle()
createChinaHatDrawings()

switchTab("Visuals")
setMenu(true)

-- АВТО-ГРАБ ГУН (из FogyHub)
task.spawn(function()
    while wait(0.2) do
        if Settings.GrabGunEnabled then
            pcall(grabGunImproved)
        end
    end
end)


notify("Planet Hub", "загружен! Нажми J", 4)
print("✅ PLANET HUB LOADED!")
