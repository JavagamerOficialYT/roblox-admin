--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local OWNER_USER_ID = 11072973894
if player.UserId ~= OWNER_USER_ID then return end

------------------------------------------------
--// NOTIFICATIONS (SAFE)
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AdminNotify"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local function notify(text)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 240, 0, 45)
	f.Position = UDim2.new(1, 260, 1, -70)
	f.BackgroundColor3 = Color3.fromRGB(25,25,25)
	f.BorderSizePixel = 0
	f.Parent = gui

	Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1,-10,1,0)
	t.Position = UDim2.new(0,10,0,0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.Gotham
	t.TextSize = 14
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = f

	TweenService:Create(f, TweenInfo.new(0.25), {
		Position = UDim2.new(1,-260,1,-70)
	}):Play()

	task.delay(2, function()
		f:Destroy()
	end)
end

------------------------------------------------
--// STATE
------------------------------------------------
local flying = false
local noclip = false
local flySpeed = 60
local flyBV, flyBG

------------------------------------------------
--// FLY (SAFE SINGLE LOOP)
------------------------------------------------
local function getHRP()
	local char = player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function startFly()
	local hrp = getHRP()
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
	flyBV, flyBG = nil, nil
end

RunService.RenderStepped:Connect(function()
	if not flying then return end

	local hrp = getHRP()
	if not hrp or not flyBV or not flyBG then return end

	local cam = workspace.CurrentCamera
	local dir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

	flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * flySpeed) or Vector3.zero
	flyBG.CFrame = cam.CFrame
end)

------------------------------------------------
--// NOCLIP (SAFE)
------------------------------------------------
RunService.Stepped:Connect(function()
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
--// KEYBINDS (TEST FIRST)
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F then
		flying = not flying
		if flying then startFly() else stopFly() end
		notify("Fly: "..tostring(flying))
	end

	if input.KeyCode == Enum.KeyCode.G then
		noclip = not noclip
		notify("Noclip: "..tostring(noclip))
	end
end)

notify("Core Admin Loaded")
