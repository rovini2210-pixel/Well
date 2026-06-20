-- =============================================
--  BLOX FRUITS - MEGA SCRIPT v3 (Beli Farm + All Sea Chests)
--  Criado por Grok | Use por sua conta e risco
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local Settings = {
    AutoFarm = false,
    AutoBeliFarm = true,
    AutoChest = true,
    AutoQuest = false,
    AutoDevilFruit = false,
    Fly = false,
    NoClip = false,
    KillAura = false,
    AutoSkill = false,
    Aimbot = false,
    MaxSpeed = 260,
    FarmRange = 250,
    KillAuraRange = 40,
    TweenSpeed = 300,
    ChestRange = 800,
}

-- Atualiza Personagem
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Settings.MaxSpeed
end)

humanoid.WalkSpeed = Settings.MaxSpeed

-- ==================== FLY + NOCLIP ====================
local BodyVelocity = nil
local function ToggleFly()
    if Settings.Fly then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Velocity = Vector3.new(0,0,0)
        BodyVelocity.Parent = root
        
        RunService.Heartbeat:Connect(function()
            if not Settings.Fly or not BodyVelocity then return end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown("W") then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown("S") then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown("A") then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown("D") then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown("Space") then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown("LeftControl") then dir -= Vector3.new(0,1,0) end
            BodyVelocity.Velocity = dir.Unit * 160
        end)
    elseif BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end

local noclipConnection
local function ToggleNoClip()
    if Settings.NoClip then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

-- ==================== AUTO CHEST (ALL SEA) ====================
local function GetChests()
    local chests = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("chest") and (v:FindFirstChild("TouchInterest") or v:FindFirstChild("ProximityPrompt")) then
            table.insert(chests, v)
        end
    end
    return chests
end

local function AutoChest()
    while Settings.AutoChest do
        for _, chest in ipairs(GetChests()) do
            if not Settings.AutoChest then break end
            local distance = (root.Position - chest.Position).Magnitude
            if distance < Settings.ChestRange then
                root.CFrame = chest.CFrame * CFrame.new(0, 8, 0)
                wait(0.5)
                if chest:FindFirstChild("TouchInterest") then
                    firetouchinterest(root, chest, 0)
                    wait(0.3)
                    firetouchinterest(root, chest, 1)
                end
            end
        end
        wait(1.5)
    end
end

-- ==================== AUTO BELI FARM ====================
local function AutoBeliFarm()
    while Settings.AutoBeliFarm do
        local target = nil
        local shortest = Settings.FarmRange

        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    target = enemy
                end
            end
        end

        if target then
            local tween = TweenService:Create(root, TweenInfo.new(shortest/Settings.TweenSpeed, Enum.EasingStyle.Linear), 
            {CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 15)})
            tween:Play()
            tween.Completed:Wait()
            
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new())
            wait(0.2)
        end
        wait(0.1)
    end
end

-- ==================== KILL AURA + AUTO SKILL ====================
RunService.Heartbeat:Connect(function()
    if not root then return end
    
    if Settings.KillAura then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                if (root.Position - enemy.HumanoidRootPart.Position).Magnitude <= Settings.KillAuraRange then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new())
                end
            end
        end
    end

    if Settings.AutoSkill then
        for _, skill in ipairs({"Z","X","C","V","F"}) do
            if math.random() < 0.45 then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[skill], false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode[skill], false, game)
            end
        end
    end
end)

-- ==================== TECLAS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode

    if key == Enum.KeyCode.F1 then Settings.AutoBeliFarm = not Settings.AutoBeliFarm print("🔥 Auto Beli Farm:", Settings.AutoBeliFarm and "ON" or "OFF") if Settings.AutoBeliFarm then spawn(AutoBeliFarm) end
    elseif key == Enum.KeyCode.F2 then Settings.AutoChest = not Settings.AutoChest print("📦 Auto Chest (All Sea):", Settings.AutoChest and "ON" or "OFF") if Settings.AutoChest then spawn(AutoChest) end
    elseif key == Enum.KeyCode.F3 then Settings.Fly = not Settings.Fly print("🕊️ Fly:", Settings.Fly and "ON" or "OFF") ToggleFly()
    elseif key == Enum.KeyCode.F4 then Settings.NoClip = not Settings.NoClip print("👻 NoClip:", Settings.NoClip and "ON" or "OFF") ToggleNoClip()
    elseif key == Enum.KeyCode.F5 then Settings.KillAura = not Settings.KillAura print("⚔️ Kill Aura:", Settings.KillAura and "ON" or "OFF")
    elseif key == Enum.KeyCode.F6 then Settings.AutoSkill = not Settings.AutoSkill print("🌀 Auto Skill:", Settings.AutoSkill and "ON" or "OFF")
    elseif key == Enum.KeyCode.F7 then Settings.AutoQuest = not Settings.AutoQuest print("📜 Auto Quest:", Settings.AutoQuest and "ON" or "OFF")
    elseif key == Enum.KeyCode.F8 then Settings.MaxSpeed = Settings.MaxSpeed + 50 humanoid.WalkSpeed = Settings.MaxSpeed print("⚡ Speed:", Settings.MaxSpeed)
    end
end)

print("✅ Script carregado com sucesso!")
print("F1 = Auto Beli Farm | F2 = Auto Chest (All Sea) | F3 = Fly | F4 = NoClip")
print("F5 = Kill Aura | F6 = Auto Skill | F7 = Auto Quest | F8 = +Velocidade")
