-- Roxo9 Script (Recriado para MM2)
-- Versão simplificada com apenas uma aba: Murder Mystery 2
-- Inclui funções específicas solicitadas.

local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local ws = game:GetService("Workspace")

-- Assumindo que a biblioteca "fu" está carregada (como no script original)
local fu = loadstring(game:HttpGet("https://raw.githubusercontent.com/JustAP1ayer/ASalfinUiBackup/-beta-/lib.lua"))()

-- Função auxiliar para encontrar jogadores
local function getPlayer(name)
    for _, p in ipairs(plrs:GetPlayers()) do
        if string.lower(p.Name):find(string.lower(name)) then
            return p
        end
    end
    return nil
end

-- Função auxiliar para teleporte seguro
local function safeTeleport(pos)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Módulo único: Murder Mystery 2 (MM2)
local module = {}
module["Name"] = "Murder Mystery 2"

-- ESPs (Toggle para ativar ESP em jogadores)
local espEnabled = false
table.insert(module, {
    Type = "Toggle",
    Args = {"ESPs", function(state)
        espEnabled = state
        if state then
            for _, p in ipairs(plrs:GetPlayers()) do
                if p ~= lp and p.Character then
                    local esp = Instance.new("BillboardGui")
                    esp.Name = "ESP"
                    esp.Size = UDim2.new(0, 100, 0, 50)
                    esp.StudsOffset = Vector3.new(0, 2, 0)
                    esp.Adornee = p.Character:FindFirstChild("Head")
                    local label = Instance.new("TextLabel", esp)
                    label.Text = p.Name
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1, 0, 0)
                    esp.Parent = p.Character
                end
            end
        else
            for _, p in ipairs(plrs:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ESP") then
                    p.Character.ESP:Destroy()
                end
            end
        end
    end}
})

-- Round timer (Mostra tempo da rodada em notificação)
table.insert(module, {
    Type = "Button",
    Args = {"Round timer", function()
        local timer = ws:FindFirstChild("RoundTimer") or ws:FindFirstChild("Timer")
        if timer and timer:IsA("StringValue") then
            fu.notification("Round time: " .. timer.Value)
        else
            fu.notification("Round timer not found.")
        end
    end}
})

-- Send sheriff and murder name into chat
table.insert(module, {
    Type = "Button",
    Args = {"Send sheriff and murder name into chat", function()
        local sheriff = nil
        local murder = nil
        for _, p in ipairs(plrs:GetPlayers()) do
            if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                sheriff = p
            elseif p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                murder = p
            end
        end
        if sheriff then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Sheriff: " .. sheriff.Name, "All")
        end
        if murder then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Murder: " .. murder.Name, "All")
        end
    end}
})

-- Shoot murder
table.insert(module, {
    Type = "Button",
    Args = {"Shoot murder", function()
        local murder = nil
        for _, p in ipairs(plrs:GetPlayers()) do
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                murder = p
                break
            end
        end
        if murder and murder.Character and lp.Backpack:FindFirstChild("Gun") then
            lp.Backpack.Gun:FindFirstChildOfClass("RemoteEvent"):FireServer(murder.Character.HumanoidRootPart.Position)
        end
    end}
})

-- Fling murder
table.insert(module, {
    Type = "Button",
    Args = {"Fling murder", function()
        local murder = nil
        for _, p in ipairs(plrs:GetPlayers()) do
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                murder = p
                break
            end
        end
        if murder and murder.Character then
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = murder.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                task.wait(0.1)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 1000, 0)
            end
        end
    end}
})

-- Fling Sheriff
table.insert(module, {
    Type = "Button",
    Args = {"Fling Sheriff", function()
        local sheriff = nil
        for _, p in ipairs(plrs:GetPlayers()) do
            if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                sheriff = p
                break
            end
        end
        if sheriff and sheriff.Character then
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = sheriff.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                task.wait(0.1)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 1000, 0)
            end
        end
    end}
})

-- Teleport to dropped gun
table.insert(module, {
    Type = "Button",
    Args = {"Teleport to dropped gun", function()
        for _, obj in ipairs(ws:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                break
            end
        end
    end}
})

-- Automatically get gun on drop (Toggle)
local autoGun = false
table.insert(module, {
    Type = "Toggle",
    Args = {"Automatically get gun on drop", function(state)
        autoGun = state
        if state then
            rs.RenderStepped:Connect(function()
                if autoGun then
                    for _, obj in ipairs(ws:GetDescendants()) do
                        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                            safeTeleport(obj.Position)
                            task.wait(1)
                        end
                    end
                end
            end)
        end
    end}
})

-- Murder kill aura (Toggle - Mata jogadores próximos se você for o murder)
local killAura = false
table.insert(module, {
    Type = "Toggle",
    Args = {"Murder kill aura", function(state)
        killAura = state
        if state then
            rs.Heartbeat:Connect(function()
                if killAura and lp.Backpack:FindFirstChild("Knife") then
                    for _, p in ipairs(plrs:GetPlayers()) do
                        if p ~= lp and p.Character and (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 10 then
                            lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent"):FireServer(p.Character.HumanoidRootPart.Position)
                        end
                    end
                end
            end)
        end
    end}
})

-- Kill everyone as murder
table.insert(module, {
    Type = "Button",
    Args = {"Kill everyone as murder", function()
        if lp.Backpack:FindFirstChild("Knife") then
            for _, p in ipairs(plrs:GetPlayers()) do
                if p ~= lp and p.Character then
                    lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent"):FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end}
})

-- Hold everyone hostage
table.insert(module, {
    Type = "Button",
    Args = {"Hold everyone hostage", function()
        if lp.Backpack:FindFirstChild("Gun") then
            for _, p in ipairs(plrs:GetPlayers()) do
                if p ~= lp and p.Character then
                    lp.Backpack.Gun:FindFirstChildOfClass("RemoteEvent"):FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end}
})

-- Knife throw to closest
table.insert(module, {
    Type = "Button",
    Args = {"Knife throw to closest", function()
        local closest = nil
        local dist = math.huge
        for _, p in ipairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character then
                local d = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = p
                end
            end
        end
        if closest and lp.Backpack:FindFirstChild("Knife") then
            lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent"):FireServer(closest.Character.HumanoidRootPart.Position)
        end
    end}
})

-- Auto knife throw (Toggle)
local autoThrow = false
table.insert(module, {
    Type = "Toggle",
    Args = {"Auto knife throw", function(state)
        autoThrow = state
        if state then
            rs.Heartbeat:Connect(function()
                if autoThrow and lp.Backpack:FindFirstChild("Knife") then
                    for _, p in ipairs(plrs:GetPlayers()) do
                        if p ~= lp and p.Character and (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 20 then
                            lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent"):FireServer(p.Character.HumanoidRootPart.Position)
                        end
                    end
                end
            end)
        end
    end}
})

-- Funções da aba Universal (integradas aqui):

-- Op fly e fly speed (Toggle e Slider)
local flying = false
local flySpeed = 50
table.insert(module, {
    Type = "Toggle",
    Args = {"Op fly", function(state)
        flying = state
        if state then
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
                rs.RenderStepped:Connect(function()
                    if flying then
                        hrp.CFrame = hrp.CFrame + (lp.Character.Humanoid.MoveDirection * flySpeed / 10)
                    end
                end)
            end
        else
            if lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.Anchored = false
            end
        end
    end}
})
table.insert(module, {
    Type = "Slider",
    Args = {"Fly speed", 1, 100, flySpeed, function(value)
        flySpeed = value
    end}
})

-- CTRL + Click teleport (Toggle)
local ctrlTp = false
table.insert(module, {
    Type = "Toggle",
    Args = {"CTRL + Click teleport", function(state)
        ctrlTp = state
        if state then
            rs.RenderStepped:Connect(function()
                if ctrlTp and game.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and game.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local mouse = lp:GetMouse()
                    safeTeleport(mouse.Hit.Position)
                end
            end)
        end
    end}
})

-- No clip (Toggle)
local noclip = false
table.insert(module, {
    Type = "Toggle",
    Args = {"No clip", function(state)
        noclip = state
        if state then
            rs.Stepped:Connect(function()
                if noclip and lp.Character then
                    for _, part in ipairs(lp.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if lp.Character then
                for _, part in ipairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end}
})

-- Walkspeed (Slider)
table.insert(module, {
    Type = "Slider",
    Args = {"Walkspeed", 16, 200, 16, function(value)
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = value
        end
    end}
})

-- Fov changer (Slider)
table.insert(module, {
    Type = "Slider",
    Args = {"Fov changer", 70, 120, 70, function(value)
        game.Workspace.CurrentCamera.FieldOfView = value
    end}
})

-- Flinger (Toggle)
local flinger = false
table.insert(module, {
    Type = "Toggle",
    Args = {"Flinger", function(state)
        flinger = state
        if state then
            rs.Heartbeat:Connect(function()
                if flinger and lp.Character then
                    for _, p in ipairs(plrs:GetPlayers()) do
                        if p ~= lp and p.Character and (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 10 then
                            p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 1000, 0)
                        end
                    end
                end
            end)
        end
    end}
})

-- Teleport to player (Input para nome do jogador)
table.insert(module, {
    Type = "Input",
    Args = {"Teleport to player", "Player name", function(name)
        local target = getPlayer(name)
        if target and target.Character then
            safeTeleport(target.Character.HumanoidRootPart.Position)
        else
            fu.notification("Player not found.")
        end
    end}
})

-- Aim locking (Toggle)
local aimLock = false
table.insert(module, {
    Type = "Toggle",
    Args = {"Aim locking", function(state)
        aimLock = state
        if state then
            rs.RenderStepped:Connect(function()
                if aimLock then
                    local mouse = lp:GetMouse()
                    local target = mouse.Target
                    if target and target.Parent and plrs:GetPlayerFromCharacter(target.Parent) then
                        game.Workspace.CurrentCamera.CFrame = CFrame.new(game.Workspace.CurrentCamera.CFrame.Position, target.Position)
                    end
                end
            end)
        end
    end}
})

-- Carregar o módulo único
getgenv().Modules = {module}
repeat task.wait() until getgenv().Modules
fu.load("Roxo9")  -- Carrega a UI com o nome Roxo9
