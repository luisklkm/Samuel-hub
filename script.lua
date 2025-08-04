local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "DeltaInterface"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 350)
main.Position = UDim2.new(0.5, -160, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 60, 0, 25)
close.Position = UDim2.new(1, -65, 0, 5)
close.Text = "Fechar"
close.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.SourceSans
close.TextSize = 14
close.MouseButton1Click:Connect(function()
	main.Visible = false
end)

UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.L then
		main.Visible = true
	end
end)

local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local tabs = {}
local pages = {}

local function createTab(name)
	local tab = Instance.new("TextButton", tabFrame)
	tab.Size = UDim2.new(0, 80, 1, 0)
	tab.Text = name
	tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tab.TextColor3 = Color3.new(1, 1, 1)
	tab.Font = Enum.Font.SourceSansBold
	tab.TextSize = 14

	local page = Instance.new("Frame", main)
	page.Size = UDim2.new(1, 0, 1, -60)
	page.Position = UDim2.new(0, 0, 0, 60)
	page.BackgroundTransparency = 1
	page.Visible = false

	tab.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		page.Visible = true
	end)

	table.insert(tabs, tab)
	table.insert(pages, page)
	return page
end

local function makeButton(text, y, parent, callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0, 260, 0, 30)
	b.Position = UDim2.new(0, 30, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.MouseButton1Click:Connect(callback)
end

-- AUTO
local autoPage = createTab("Auto")

local autoClick = false
local autoFarm = false
local selectedNPC = nil
local npcList = {}

makeButton("Toggle Auto Click", 0.05, autoPage, function()
	autoClick = not autoClick
end)

makeButton("Atualizar NPCs", 0.20, autoPage, function()
	npcList = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			table.insert(npcList, obj)
		end
	end
end)

makeButton("Selecionar NPC", 0.35, autoPage, function()
	if #npcList > 0 then
		local i = table.find(npcList, selectedNPC) or 0
		i = (i % #npcList) + 1
		selectedNPC = npcList[i]
	end
end)

makeButton("Toggle Auto Farm", 0.50, autoPage, function()
	autoFarm = not autoFarm
end)

-- RANK
local rankPage = createTab("Rank")
local autoRank = false

makeButton("Toggle Auto Rank Up", 0.05, rankPage, function()
	autoRank = not autoRank
end)

-- MOVIMENTO (reserva se quiser adicionar speed/fly)
local movePage = createTab("Extra")
makeButton("Reset Player", 0.05, movePage, function()
	lp.Character:BreakJoints()
end)

-- LOOP DE FUNÇÕES
lp.Idled:Connect(function()
	VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)

RunService.RenderStepped:Connect(function()
	if autoClick then
		VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
		task.wait(0.1)
		VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
	end
	if autoFarm and selectedNPC and selectedNPC:FindFirstChild("HumanoidRootPart") then
		lp.Character:MoveTo(selectedNPC.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
	end
end)

task.spawn(function()
	while true do
		if autoRank then
			local remote = RS:FindFirstChild("Ranks")
			if remote and remote:IsA("RemoteEvent") then
				pcall(function()
					remote:FireServer()
				end)
			end
		end
		task.wait(20)
	end
end)

-- Mostrar primeira aba
pages[1].Visible = true
