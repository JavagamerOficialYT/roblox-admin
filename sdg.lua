local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

------------------------------------------------
-- STATE (single source of truth)
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
-- APPLY STATS (anti-reset fix)
------------------------------------------------
local function applyStats()
	if not state.hum then return end
	state.hum.WalkSpeed = state.walkSpeed
	state.hum.JumpPower = state.jumpPower
end

task.spawn(function()
	while true do
		task.wait(0.5)
		applyStats()
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
-- FLY SYSTEM
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

	local cam = workspace.CurrentCamera
	local dir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end

	state.flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * state.flySpeed) or Vector3.zero
	state.flyBG.CFrame = cam.CFrame
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
-- INPUT TOGGLE TESTS (replace with UI if you want)
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.F then
		state.flying = not state.flying
		if state.flying then startFly() else stopFly() end
	end

	if input.KeyCode == Enum.KeyCode.G then
		state.noclip = not state.noclip
	end

	if input.KeyCode == Enum.KeyCode.H then
		state.infiniteJump = not state.infiniteJump
	end
end)
