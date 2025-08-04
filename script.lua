local O=loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
local P=game:GetService("Players").LocalPlayer
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local V=game:GetService("VirtualInputManager")
local RS=game:GetService("ReplicatedStorage")
local a,b,c,d,e,f,g,h,i=false,false,false,false,false,nil,{},30

local W=O:MakeWindow({Name="Script Anti-Cheat Test",HidePremium=true,SaveConfig=false,IntroEnabled=false})
local T=W:MakeTab({Name="Auto",Icon="rbxassetid://4483345998",PremiumOnly=false})
local F=W:MakeTab({Name="Farm",Icon="rbxassetid://6023426915",PremiumOnly=false})
local E=W:MakeTab({Name="Egg",Icon="rbxassetid://3926305904",PremiumOnly=false})
local M=W:MakeTab({Name="Movimento",Icon="rbxassetid://6023426915",PremiumOnly=false})

T:AddToggle({Name="Toggle Auto Click",Default=false,Callback=function(v) a=v end})

F:AddButton({Name="Atualizar NPCs",Callback=function()
    g={}
    for _,x in pairs(workspace:GetDescendants()) do
        if x:IsA("Model") and x:FindFirstChild("Humanoid") then
            table.insert(g,x)
        end
    end
    if #g>0 then
        O:MakeNotification({Name="NPCs Atualizados",Content=tostring(#g).." NPCs encontrados",Time=3})
    else
        O:MakeNotification({Name="NPCs Atualizados",Content="Nenhum NPC encontrado",Time=3})
    end
end})

F:AddButton({Name="Selecionar NPC",Callback=function()
    if #g>0 then
        local n=table.find(g,f) or 0
        n=(n%#g)+1
        f=g[n]
        O:MakeNotification({Name="NPC Selecionado",Content=f.Name,Time=3})
    else
        O:MakeNotification({Name="Erro",Content="Nenhum NPC selecionado. Atualize a lista.",Time=3})
    end
end})

F:AddToggle({Name="Toggle Auto Farm",Default=false,Callback=function(v) b=v end})

E:AddButton({Name="Girar Egg",Callback=function()
    local s=RS:FindFirstChild("OpenEgg")
    if s then
        s:FireServer("Egg1",false)
        O:MakeNotification({Name="Egg",Content="Egg girado!",Time=2})
    else
        O:MakeNotification({Name="Erro",Content="Remote 'OpenEgg' não encontrado.",Time=3})
    end
end})

M:AddToggle({Name="Toggle Speed",Default=false,Callback=function(v)
    c=v
    local h=P.Character and P.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=c and 80 or 16 end
end})

M:AddToggle({Name="Toggle Fly",Default=false,Callback=function(v)
    d=v
    local hrp=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    if d and hrp then
        local bv=Instance.new("BodyVelocity")
        bv.Name="FlyForce"
        bv.Velocity=Vector3.zero
        bv.MaxForce=Vector3.new(1e5,1e5,1e5)
        bv.Parent=hrp
        if not _G.fC then
            _G.fC=R.RenderStepped:Connect(function()
                if d and bv and bv.Parent then
                    local m=Vector3.zero
                    if U:IsKeyDown(Enum.KeyCode.W) then m+=workspace.CurrentCamera.CFrame.LookVector end
                    if U:IsKeyDown(Enum.KeyCode.S) then m-=workspace.CurrentCamera.CFrame.LookVector end
                    if U:IsKeyDown(Enum.KeyCode.A) then m-=workspace.CurrentCamera.CFrame.RightVector end
                    if U:IsKeyDown(Enum.KeyCode.D) then m+=workspace.CurrentCamera.CFrame.RightVector end
                    if m.Magnitude>0 then bv.Velocity=m.Unit*100 else bv.Velocity=Vector3.zero end
                else
                    if bv then bv:Destroy() end
                    if _G.fC then _G.fC:Disconnect() _G.fC=nil end
                end
            end)
        end
    elseif hrp then
        local f=hrp:FindFirstChild("FlyForce")
        if f then f:Destroy() end
        if _G.fC then _G.fC:Disconnect() _G.fC=nil end
    end
end})

M:AddSlider({Name="Tamanho dos Botões",Min=10,Max=60,Default=30,Increment=1,ValueName="px",Callback=function(v)
    i=v
    O:MakeNotification({Name="Ajuste",Content="Tamanho dos botões ajustado para "..i.."px (sem efeito visual)",Time=3})
end})

W:AddButton({Name="Fechar Interface",Callback=function() O:Destroy() end})

P.Idled:Connect(function() V:SendKeyEvent(true,Enum.KeyCode.Space,false,game) end)

R.RenderStepped:Connect(function()
    if a then V:SendMouseButtonEvent(0,0,0,true,nil,0) wait(0.1) V:SendMouseButtonEvent(0,0,0,false,nil,0) end
    if b and f and f:FindFirstChild("HumanoidRootPart") then
        if P.Character then P.Character:MoveTo(f.HumanoidRootPart.Position+Vector3.new(0,0,2)) end
    end
end)
