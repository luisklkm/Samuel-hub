local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")

local autoClick = false
local autoFarm = false
local selectedNPC = nil
local npcList = {}

local Window = OrionLib:MakeWindow({
	Name = "Anti-Cheat Test",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "MyConfig"
})

-- ABA AUTO
local AutoTab = Window:MakeTab({Name = "Auto", Icon = "", PremiumOnly = false})
AutoTab:AddToggle({
	Name = "Auto Click",
	Default = false,
	Callback = function(Value)
		autoClick = Value
	end
})

-- ABA FARM
local FarmTab = Window:MakeTab({Name = "Farm", Icon = "", PremiumOnly = false})

FarmTab:AddButton({
	Name = "Atualizar NPCs",
	Callback = function()
		npcList = {}
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
				table.insert(npcList, obj)
			end
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
		end
	end
})

FarmTab:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(Value)
		autoFarm = Value
	end
})

-- ABA EGG
local EggTab = Window:MakeTab({Name = "Egg", Icon = "", PremiumOnly = false})

EggTab:AddButton({
	Name = "Girar Egg",
	Callback = function()
		local remote = RS:FindFirstChild("OpenEgg")
		if remote then
			remote:FireServer("Egg1", false)
		end
	end
})

-- ABA MOVIMENTO
local MoveTab = Window:MakeTab({Name = "Movimento", Icon = "", PremiumOnly = false})

local fly = false
MoveTab:AddToggle({
	Name = "Velocidade Alta",
	Default = false,
	Callback = function(Value)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = Value and 80 or 16
		end
	end
})

MoveTab:AddToggle({
	Name = "Ativar Voo",
	Default = false,
	Callback = function(Value)
		fly = Value
	end
})

-- Botão para fechar GUI
Window:AddButton({
	Name = "Fechar Interface",
	Callback = function()
		OrionLib:Destroy()
	end
})

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
	VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)

-- Loop Render
RunService.RenderStepped:Connect(function()
	if autoClick then
		VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
		wait(0.1)
		VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
	end

	if autoFarm and selectedNPC and selectedNPC:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:MoveTo(selectedNPC.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
	end
end)
