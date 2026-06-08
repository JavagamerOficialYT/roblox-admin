--// OWNER CHECK
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player.UserId ~= 11072973894 then
	return warn("Unauthorized user")
end

--// SAFE LOADER WRAPPER
local function safeLoad(url)
	local success, result = pcall(function()
		return loadstring(game:HttpGet(url))()
	end)

	if not success then
		warn("Failed to load:", url)
	end

	return result
end

------------------------------------------------
--// HUB UI
------------------------------------------------
local Rayfield = safeLoad("https://sirius.menu/rayfield")

local Window = Rayfield:CreateWindow({
	Name = "One Click Admin Hub",
	LoadingTitle = "Loading Hub...",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main")

------------------------------------------------
--// STATE
------------------------------------------------
local espEnabled = false
local flying = false
local noclip = false
local flySpeed = 60
local walkSpeed = 16
local jumpPower = 50

local flyBV, flyBG
local highlights = {}

------------------------------------------------
--// NOTIFY
------------------------------------------------
local function notify(msg)
	Rayfield:Notify({
		Title = "Hub",
		Content = msg,
		Duration = 2
	})
end

------------------------------------------------
--// ESP
------------------------------------------------
local function enableESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and not highlights[p] then
			local h = Instance.new("Highlight")
			h.FillColor = Color3.fromRGB(255,0,0)
			h.FillTransparency = 0.4
			h.OutlineColor = Color3.fromRGB(255,255,255)
			h.Parent = p.Character
			highlights[p] = h
		end
	end
end

local function disableESP()
	for _, h in pairs(highlights) do
		h:Destroy()
	end
	table.clear(highlights)
end

------------------------------------------------
--// SPEED
------------------------------------------------
local function applySpeed()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.WalkSpeed = walkSpeed
	hum.JumpPower = jumpPower
end

player.CharacterAdded:Connect(function()
	task.wait(1)
	applySpeed()
end)

------------------------------------------------
--// FLY
------------------------------------------------
local function startFly()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
	flyBV.Parent = hrp

	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
	flyBG.Parent = hrp
end

local function stopFly()
	if flyBV then flyBV:Destroy() end
	if flyBG then flyBG:Destroy() end
end

game:GetService("RunService").RenderStepped:Connect(function()
	if not flying then return end

	local cam = workspace.CurrentCamera
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not flyBV then return end

	local dir = Vector3.zero

	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end

	flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * flySpeed) or Vector3.zero
	flyBG.CFrame = cam.CFrame
end)

------------------------------------------------
--// NOCLIP
------------------------------------------------
game:GetService("RunService").Stepped:Connect(function()
	if not noclip then return end

	local char = player.Character
	if not char then return end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

------------------------------------------------
--// UI CONTROLS (ONE CLICK HUB)
------------------------------------------------

Tab:CreateButton({
	Name = "Toggle ESP",
	Callback = function()
		espEnabled = not espEnabled
		if espEnabled then
			enableESP()
		else
			disableESP()
		end
		notify("ESP: "..tostring(espEnabled))
	end
})

Tab:CreateButton({
	Name = "Toggle Fly",
	Callback = function()
		flying = not flying
		if flying then startFly() else stopFly() end
		notify("Fly: "..tostring(flying))
	end
})

Tab:CreateButton({
	Name = "Toggle Noclip",
	Callback = function()
		noclip = not noclip
		notify("Noclip: "..tostring(noclip))
	end
})

Tab:CreateSlider({
	Name = "Fly Speed",
	Range = {20,200},
	Callback = function(v)
		flySpeed = v
	end
})

Tab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16,200},
	Callback = function(v)
		walkSpeed = v
		applySpeed()
	end
})

Tab:CreateSlider({
	Name = "JumpPower",
	Range = {50,250},
	Callback = function(v)
		jumpPower = v
		applySpeed()
	end
})

notify("Hub Loaded Successfully")
