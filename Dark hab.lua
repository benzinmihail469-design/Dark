local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Состояние и соединения Anti-Fling
local antiFlingEnabled = false
local flingDetectionCon = nil
local flingNeutralizerCon = nil

-- =======================================================
-- 1. СИСТЕМА ANTI-FLING
-- =======================================================
local function toggleAntiFling(state)
    antiFlingEnabled = state

    if state then
        -- Отключаем коллизию с игроками, которые подозрительно быстро крутятся/летают
        flingDetectionCon = RunService.Heartbeat:Connect(function()
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= lp and pl.Character and pl.Character.PrimaryPart then
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

        -- Сбрасываем аномальную скорость собственного персонажа
        flingNeutralizerCon = RunService.Heartbeat:Connect(function()
            if lp.Character and lp.Character.PrimaryPart then
                local hrp = lp.Character.PrimaryPart
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

-- =======================================================
-- 2. СИСТЕМА FLING (ОТПРАВКА В КОСМОС)
-- =======================================================
local function executeFling(target)
    if not target or not target.Character then
        warn("[Fling]: Цель не найдена или персонаж отсутствует.")
        return
    end

    -- Если включен Anti-Fling, временно отключаем его на время атаки
    local wasAntiFlingOn = antiFlingEnabled
    if wasAntiFlingOn then
        toggleAntiFling(false)
        task.wait(0.2)
    end

    local SkidFling = function(TargetPlayer)
        local Character = lp.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter and TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")

        if Character and Humanoid and RootPart then
            -- Запоминаем стартовую позицию для возврата
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end

            -- Перемещаем камеру на цель
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

            -- Возврат на исходные координаты
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

    -- Возвращаем состояние Anti-Fling
    if wasAntiFlingOn then
        task.wait(0.5)
        toggleAntiFling(true)
    end
end
