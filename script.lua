-- ✅ SCRIPT DE TESTE ANTI-CHEAT COMPATÍVEL COM DELTAR
-- Interface personalizada com abas, auto click invisível, auto farm, egg, movimentação, auto equip e auto sell

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- GUI Base
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local tabButtons = Instance.new("Frame")

-- Setup GUI
gui.Name = "AntiCheatGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

frame.Size = UDim2.new(0, 350, 0, 400)
frame.Position = UDim2.new(0.5, -175, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Tab Buttons
tabButtons.Size = UDim2.new(1, 0, 0, 35)
tabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tabButtons.Parent = frame

local tabs = {}
local pages = {}

local function createPage(name)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 70, 1, 0)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 14
	button.Parent = tabButtons

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -35)
	page.Position = UDim2.new(0, 0, 0, 35)
	page.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	page.Visible = false
	page.Parent = frame

	button.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		page.Visible = true
	end)

	table.insert(tabs, button)
	table.insert(pages, page)
	return page
end

local function createVerticalLayout(parent)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

local function createButton(text, parent, layout, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 300, 0, 30)
	button.Text = text
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 16
	button.Parent = parent
	button.MouseButton1Click:Connect(callback)
end

-- Auto Tab
local autoPage = createPage("Auto")
local autoLayout = createVerticalLayout(autoPage)

local autoClick = false
createButton("Toggle Auto Click", autoPage, autoLayout, function()
	autoClick = not autoClick
end)

LocalPlayer.Idled:Connect(function()
	VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
end)

RunService.RenderStepped:Connect(function()
	if autoClick then
		VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
		VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
	end
end)

-- Farm Tab
local farmPage = createPage("Farm")
local farmLayout = createVerticalLayout(farmPage)

local npcList = {}
local selectedNPC = nil
local autoFarm = false

createButton("Atualizar NPCs", farmPage, farmLayout, function()
	npcList = {}
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			table.insert(npcList, obj)
		end
	end
end)

createButton("Selecionar NPC", farmPage, farmLayout, function()
	if #npcList > 0 then
		local i = table.find(npcList, selectedNPC) or 0
		i = (i % #npcList) + 1
		selectedNPC = npcList[i]
	end
end)

createButton("Toggle Auto Farm", farmPage, farmLayout, function()
	autoFarm = not autoFarm
end)

RunService.RenderStepped:Connect(function()
	if autoFarm and selectedNPC and selectedNPC:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:MoveTo(selectedNPC.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
	end
end)

-- Extra Page
local miscPage = createPage("Extra")
local miscLayout = createVerticalLayout(miscPage)

createButton("Girar Egg", miscPage, miscLayout, function()
	local remote = RS:FindFirstChild("OpenEgg")
	if remote then
		remote:FireServer("Egg1", false)
	end
end)

-- Auto Equip
local autoEquip = false
createButton("Toggle Auto Equip", miscPage, miscLayout, function()
	autoEquip = not autoEquip
end)

-- Auto Sell (usando remote "Sell")
local autoSell = false
createButton("Toggle Auto Sell", miscPage, miscLayout, function()
	autoSell = not autoSell
end)

-- Auto Loop
task.spawn(function()
	while task.wait(5) do
		if autoEquip then
			local equipRemote = RS:FindFirstChild("EquipBest")
			if equipRemote then
				equipRemote:FireServer()
			end
		end

		if autoSell then
			local sellRemote = RS:FindFirstChild("Sell")
			if sellRemote then
				sellRemote:FireServer()
			end
		end
	end
end)

-- Movimento Tab
local movePage = createPage("Movimento")
local moveLayout = createVerticalLayout(movePage)

-- Speed
local speedOn = false
createButton("Toggle Speed", movePage, moveLayout, function()
	speedOn = not speedOn
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speedOn and 80 or 16
	end
end)

-- Fly
local flying = false
createButton("Toggle Fly", movePage, moveLayout, function()
	flying = not flying
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if flying and hrp then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyForce"
		bv.Velocity = Vector3.zero
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Parent = hrp

		RunService.RenderStepped:Connect(function()
			if flying and bv and bv.Parent then
				local move = Vector3.zero
				if UIS:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
				bv.Velocity = move.Magnitude > 0 and move.Unit * 100 or Vector3.zero
			end
		end)
	elseif hrp:FindFirstChild("FlyForce") then
		hr
p:FindFirstChild("FlyForce"):Destroy()
	end
end)

-- Botão para Fechar Interface
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Exibir primeira aba por padrão
pages[1].Visible = true
