-- ROXO9 | Murder Mystery 2
-- Recriado do zero | 1 aba | UI nova

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer

-- UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Roxo9 | MM2",
    LoadingTitle = "Roxo9",
    LoadingSubtitle = "Murder Mystery 2",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Murder Mystery 2", 4483362458)

-- ================= UTILS =================

local function getMurder()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife"))) then
            return p
        end
    end
end

local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun"))) then
            return p
        end
    end
end

local function tp(pos)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

-- ================= ESP =================

local esp = false
Tab:CreateToggle({
    Name = "ESPs",
    Callback = function(v)
        esp = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                if v and not p.Character:FindFirstChild("ESP") then
                    local gui = Instance.new("BillboardGui", p.Character)
                    gui.Name = "ESP"
                    gui.Size = UDim2.fromOffset(100, 40)
                    gui.StudsOffset = Vector3.new(0, 2, 0)
                    gui.Adornee = p.Character.Head

                    local t = Instance.new("TextLabel", gui)
                    t.Size = UDim2.fromScale(1,1)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1,0,0)
                    t.TextStrokeTransparency = 0
                    t.Text = p.Name
                elseif not v and p.Character:FindFirstChild("ESP") then
                    p.Character.ESP:Destroy()
                end
            end
        end
    end
})

-- ================= MM2 FUNCTIONS =================

Tab:CreateButton({
    Name = "Round timer",
    Callback = function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("timer") and v:IsA("StringValue") then
                Rayfield:Notify({Title="Round", Content=v.Value, Duration=4})
                return
            end
        end
        Rayfield:Notify({Title="Round", Content="Timer not found", Duration=3})
    end
})

Tab:CreateButton({
    Name = "Send sheriff and murder name into chat",
    Callback = function()
        local s = getSheriff()
        local m = getMurder()
        local chat = game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        if s then chat:FireServer("Sheriff: "..s.Name,"All") end
        if m then chat:FireServer("Murder: "..m.Name,"All") end
    end
})

Tab:CreateButton({
    Name = "Shoot murder",
    Callback = function()
        local m = getMurder()
        local gun = lp.Backpack:FindFirstChild("Gun")
        if m and gun then
            gun:FindFirstChildOfClass("RemoteEvent"):FireServer(m.Character.HumanoidRootPart.Position)
        end
    end
})

Tab:CreateButton({
    Name = "Fling murder",
    Callback = function()
        local m = getMurder()
        if m and lp.Character then
            lp.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
            lp.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,1000,0)
        end
    end
})

Tab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        local s = getSheriff()
        if s and lp.Character then
            lp.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
            lp.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,1000,0)
        end
    end
})

Tab:CreateButton({
    Name = "Teleport to dropped gun",
    Callback = function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "GunDrop" and v:IsA("BasePart") then
                tp(v.Position)
                break
            end
        end
    end
})

local autoGun = false
RunService.Heartbeat:Connect(function()
    if autoGun then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "GunDrop" and v:IsA("BasePart") then
                tp(v.Position)
            end
        end
    end
end)

Tab:CreateToggle({
    Name = "Automatically get gun on drop",
    Callback = function(v) autoGun = v end
})

local killAura = false
RunService.Heartbeat:Connect(function()
    if killAura and lp.Backpack:FindFirstChild("Knife") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                if (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 12 then
                    lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent")
                        :FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

Tab:CreateToggle({
    Name = "Murder kill aura",
    Callback = function(v) killAura = v end
})

Tab:CreateButton({
    Name = "Kill everyone as murder",
    Callback = function()
        if lp.Backpack:FindFirstChild("Knife") then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent")
                        :FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
})

Tab:CreateButton({
    Name = "Hold everyone hostage",
    Callback = function()
        local gun = lp.Backpack:FindFirstChild("Gun")
        if gun then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    gun:FindFirstChildOfClass("RemoteEvent")
                        :FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
})

Tab:CreateButton({
    Name = "Knife throw to closest",
    Callback = function()
        local closest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local d = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = p
                end
            end
        end
        if closest and lp.Backpack:FindFirstChild("Knife") then
            lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent")
                :FireServer(closest.Character.HumanoidRootPart.Position)
        end
    end
})

local autoThrow = false
RunService.Heartbeat:Connect(function()
    if autoThrow and lp.Backpack:FindFirstChild("Knife") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                if (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                    lp.Backpack.Knife:FindFirstChildOfClass("RemoteEvent")
                        :FireServer(p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

Tab:CreateToggle({
    Name = "Auto knife throw",
    Callback = function(v) autoThrow = v end
})

-- ================= UNIVERSAL (DENTRO DA MM2) =================

local fly, flySpeed = false, 60
RunService.RenderStepped:Connect(function()
    if fly and lp.Character then
        lp.Character.HumanoidRootPart.Velocity =
            lp.Character.Humanoid.MoveDirection * flySpeed
    end
end)

Tab:CreateToggle({ Name="Op Fly", Callback=function(v) fly=v end })
Tab:CreateSlider({
    Name="Fly speed", Range={20,150}, Increment=5, CurrentValue=60,
    Callback=function(v) flySpeed=v end
})

Tab:CreateToggle({
    Name="CTRL + Click teleport",
    Callback=function(v)
        if not v then return end
        local mouse = lp:GetMouse()
        mouse.Button1Down:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                tp(mouse.Hit.Position)
            end
        end)
    end
})

Tab:CreateToggle({
    Name="No clip",
    Callback=function(v)
        RunService.Stepped:Connect(function()
            if v and lp.Character then
                for _, p in ipairs(lp.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)
    end
})

Tab:CreateSlider({
    Name="Walkspeed", Range={16,200}, Increment=4, CurrentValue=16,
    Callback=function(v)
        if lp.Character then lp.Character.Humanoid.WalkSpeed=v end
    end
})

Tab:CreateSlider({
    Name="Fov changer", Range={70,120}, Increment=1, CurrentValue=70,
    Callback=function(v)
        Workspace.CurrentCamera.FieldOfView=v
    end
})

Tab:CreateToggle({
    Name="Flinger",
    Callback=function(v)
        RunService.Heartbeat:Connect(function()
            if v and lp.Character then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character then
                        if (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 10 then
                            p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,1000,0)
                        end
                    end
                end
            end
        end)
    end
})

Tab:CreateInput({
    Name="Teleport to player",
    PlaceholderText="Player name",
    Callback=function(txt)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():find(txt:lower()) then
                tp(p.Character.HumanoidRootPart.Position)
            end
        end
    end
})

Tab:CreateToggle({
    Name="Aim locking",
    Callback=function(v)
        RunService.RenderStepped:Connect(function()
            if v then
                local m = lp:GetMouse()
                if m.Target then
                    Workspace.CurrentCamera.CFrame =
                        CFrame.new(Workspace.CurrentCamera.CFrame.Position, m.Hit.Position)
                end
            end
        end)
    end
})
