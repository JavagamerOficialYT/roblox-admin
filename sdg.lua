local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- STATE
------------------------------------------------
local state = {
	char = nil,
	hum = nil,

	walkSpeed = 16,
	jumpPower = 50,

	infiniteJump = false,

	flying = false,
	noclip = false,

	flySpeed = 60,

	flyBV = nil,
	flyBG = nil
}

------------------------------------------------
-- CHARACTER HANDLER
------------------------------------------------
local function bindCharacter(char)
	state.char = char
	state.hum = char:WaitForChild("Humanoid")

	state.hum.WalkSpeed = state.walkSpeed
	state.hum.JumpPower = state.jumpPower
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

------------------------------------------------
-- FORCE APPLY (fix resets)
------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.5)
		if state.hum then
			state.hum.WalkSpeed = state.walkSpeed
			state.hum.JumpPower = state.jumpPower
		end
	end
end)

------------------------------------------------
-- INFINITE JUMP
------------------------------------------------
UserInputService.JumpRequest:Connect(function()
	if not state.infiniteJump then return end
	if not state.hum then return end

	state.hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

------------------------------------------------
-- FLY
------------------------------------------------
local function startFly()
	local hrp = state.char and state.char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	state.flyBV = Instance.new("BodyVelocity")
	state.flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
	state.flyBV.Parent = hrp

	state.flyBG = Instance.new("BodyGyro")
	state.flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
	state.flyBG.Parent = hrp
end

local function stopFly()
	if state.flyBV then state.flyBV:Destroy() end
	if state.flyBG then state.flyBG:Destroy() end
	state.flyBV, state.flyBG = nil, nil
end

RunService.RenderStepped:Connect(function()
	if not state.flying then return end

	local char = state.char
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not state.flyBV then return end

	local dir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end

	state.flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * state.flySpeed) or Vector3.zero
	state.flyBG.CFrame = camera.CFrame
end)

------------------------------------------------
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
	if not state.noclip then return end

	local char = state.char
	if not char then return end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

------------------------------------------------
-- UI (RAYFIELD)
------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Admin Movement Hub",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main")

------------------------------------------------
-- WALK SPEED
------------------------------------------------
Tab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Callback = function(v)
		state.walkSpeed = v
	end
})

------------------------------------------------
-- JUMP POWER
------------------------------------------------
Tab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 250},
	Callback = function(v)
		state.jumpPower = v
	end
})

------------------------------------------------
-- FLY SPEED
------------------------------------------------
Tab:CreateSlider({
	Name = "Fly Speed",
	Range = {20, 200},
	Callback = function(v)
		state.flySpeed = v
	end
})

------------------------------------------------
-- TOGGLES
------------------------------------------------
Tab:CreateToggle({
	Name = "Infinite Jump",
	Callback = function(v)
		state.infiniteJump = v
	end
})

Tab:CreateToggle({
	Name = "Fly",
	Callback = function(v)
		state.flying = v
		if v then startFly() else stopFly() end
	end
})

Tab:CreateToggle({
	Name = "Noclip",
	Callback = function(v)
		state.noclip = v
	end
})
