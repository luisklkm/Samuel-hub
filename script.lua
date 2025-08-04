local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local lp = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")

local autoClick = false
local autoFarm = false
local speedOn = false
local flying = false
local selectedNPC = nil
local npcList = {}
local buttonSizeY = 30

local Window = OrionLib:MakeWindow({
    Name = "Script Anti-Cheat Test",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
})

-- Aba Auto
local AutoTab = Window:MakeTab({
    Name = "Auto",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutoTab:AddToggle({
    Name = "Toggle Auto Click",
    Default = false,
    Callback = function(value)
        autoClick = value
    end
})

-- Aba Farm
local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://6023426915",
    PremiumOnly = false
})

FarmTab:AddButton({
    Name = "Atualizar NPCs",
    Callback = function()
        npcList = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                table.insert(npcList, obj)
            end
        end
        if #npcList > 0 then
            OrionLib:MakeNotification({
                Name = "NPCs Atualizados",
                Content = tostring(#npcList) .. " NPCs encontrados",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "NPCs Atualizados",
                Content = "Nenhum NPC encontrado",
                Time = 3
            })
        end
    end
})

FarmTab:AddButton({
    Name = "Selecionar NPC",
    Callback = function()
        if #npcList > 0 then
            local i = table.find(npcList, selectedNPC) or 0
            i = (i % #npcList) + 1
            selectedNPC = npcList[i]
            OrionLib:MakeNotification({
                Name = "NPC Selecionado",
                Content = selectedNPC.Name,
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Erro",
                Content = "Nenhum NPC selecionado. Atualize a lista.",
                Time = 3
            })
        end
    end
})

FarmTab:AddToggle({
    Name = "Toggle Auto Farm",
    Default = false,
    Callback = function(value)
        autoFarm = value
    end
})

-- Aba Egg
local EggTab = Window:MakeTab({
    Name = "Egg",
    Icon = "rbxassetid://3926305904",
    PremiumOnly = false
})

EggTab:AddButton({
    Name = "Girar Egg",
    Callback = function()
        local success, remote = pcall(function()
            return RS:FindFirstChild("OpenEgg")
        end)
        if success and remote then
            remote:FireServer("Egg1", false)
            OrionLib:MakeNotification({
                Name = "Egg",
                Content = "Egg girado!",
                Time = 2
            })
        else
            OrionLib:MakeNotification({
                Name = "Erro",
                Content = "Remote 'OpenEgg' não encontrado.",
                Time = 3
            })
        end
    end
})

-- Aba Movimento
local MoveTab = Window:MakeTab({
    Name = "Movimento",
    Icon = "rbxassetid://6023426915",
    PremiumOnly = false
})

MoveTab:AddToggle({
    Name = "Toggle Speed",
    Default = false,
    Callback = function(value)
        speedOn = value
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedOn and 80 or 16
        end
    end
})

MoveTab:AddToggle({
    Name = "Toggle Fly",
    Default = false,
    Callback = function(value)
        flying = value
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if flying and hrp then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyForce"
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp

            if not _G.flyConnection then
                _G.flyConnection = RunService.RenderStepped:Connect(function()
                    if flying and bv and bv.Parent then
                        local move = Vector3.zero
                        if UIS:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
                        if move.Magnitude > 0 then
                            bv.Velocity = move.Unit * 100
                        else
                            bv.Velocity = Vector3.zero
                        end
                    else
                        if bv then bv:Destroy() end
                        if _G.flyConnection then
                            _G.flyConnection:Disconnect()
                            _G.flyConnection = nil
                        end
                    end
                end)
            end
        elseif hrp then
            local flyForce = hrp:FindFirstChild("FlyForce")
            if flyForce then flyForce:Destroy() end
            if _G.flyConnection then
                _G.flyConnection:Disconnect()
                _G.flyConnection = nil
            end
        end
    end
})

MoveTab:AddSlider({
    Name = "Tamanho dos Botões",
    Min = 10,
    Max = 60,
    Default = 30,
    Increment = 1,
    ValueName = "px",
    Callback = function(value)
        buttonSizeY = value
        OrionLib:MakeNotification({
            Name = "Ajuste",
            Content = "Tamanho dos botões ajustado para "..buttonSizeY.."px (sem efeito visual)",
            Time = 3
        })
    end
})

Window:AddButton({
    Name = "Fechar Interface",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Evitar kick por idle
lp.Idled:Connect(function()
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)

-- Loop principal
RunService.RenderStepped:Connect(function()
    if autoClick then
        VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
        wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
    end

    if autoFarm and selectedNPC and selectedNPC:FindFirstChild("HumanoidRootPart") then
        if lp.Character then
            lp.Character:MoveTo(selectedNPC.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
        end
    end
end)
