--SCRIPT PRONTO PARA DELTA EXECUTOR
--Funcionalidades: Auto Click, Auto Farm, Anti-AFK e Auto Rank Up (20s), com abas simples

local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- Interface
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "SimpleAntiCheatUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 360)
frame.Position = UDim2.new(0.5, -150, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Botão fechar e tecla de reabertura
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 60, 0, 25)
closeBtn.Position = UDim2.new(1, -65, 0, 5)
closeBtn.Text = "Fechar"
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14
closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.L then
		frame.Visible = true
	end
end)

-- Abas
local tabButtons = Instance.new("Frame", frame)
tabButtons.Size = UDim2.new(1,0,0,30)
tabButtons.BackgroundColor3 = Color3.fromRGB(45,45,45)

local pages = {}
local function createTab(name, order)
	local btn = Instance.new("TextButton", tabButtons)
	btn.Size = UDim2.new(0,75,1,0)
	btn.Position = UDim2.new(0, 75*(order-1), 0, 0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14

	local page = Instance.new("Frame", frame)
	page.Position = UDim2.new(0,0,0,30)
	page.Size = UDim2.new(1,0,1,-30)
	page.BackgroundTransparency = 1
	page.Visible = false
	pages[name] = page

	btn.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do p.Visible = false end
		page.Visible = true
	end)

	return page
end

local function makeButton(parent, text, y, callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,260,0,30)
	b.Position = UDim2.new(0,20,0,y)
	b.BackgroundColor3 = Color3.fromRGB(70,70,70)
	b.Text = text
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 14
	b.MouseButton1Click:Connect(callback)
end

-- Aba Auto
local autoTab = createTab("Auto", 1)
local autoClick, autoFarm = false, false
local selectedNPC, npcList = nil, {}

makeButton(autoTab, "Toggle Auto Click", 10, function()
	autoClick = not autoClick
end)
makeButton(autoTab, "Atualizar NPCs", 50, function()
	npcList = {}
	for _,obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			table.insert(npcList, obj)
		end
	end
end)
makeButton(autoTab, "Selecionar NPC", 90, function()
	if #npcList > 0 then
		local idx = table.find(npcList, selectedNPC) or 0
		idx = (idx % #npcList) + 1
		selectedNPC = npcList[idx]
	end
end)
makeButton(autoTab, "Toggle Auto Farm", 130, function()
	autoFarm = not autoFarm
end)

-- Aba Rank
local rankTab = createTab("Rank", 2)
local autoRank = false
makeButton(rankTab, "Toggle Auto Rank Up", 10, function()
	autoRank = not autoRank
end)

-- Lógicas
-- Auto Click e Farm
RunService.RenderStepped:Connect(function()
	if autoClick then
		VIM:SendMouseButtonEvent(0,0,0,true,nil,0)
		task.wait(0.1)
		VIM:SendMouseButtonEvent(0,0,0,false,nil,0)
	end
	if autoFarm and selectedNPC and selectedNPC:FindFirstChild("HumanoidRootPart") then
		lp.Character:MoveTo(selectedNPC.HumanoidRootPart.Position + Vector3.new(0,0,2))
	end
end)

-- Anti-AFK
lp.Idled:Connect(function()
	VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)

-- Auto Rank Up loop
task.spawn(function()
	while task.wait(20) do
		if autoRank then
			local r = RS:FindFirstChild("Ranks")
			if r then
				pcall(function() r:FireServer() end)
			end
		end
	end
end)

-- Ativar primeira aba
pages["Auto"].Visible = true
