local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

------------------------------------------------
-- SETTINGS
------------------------------------------------
local walkSpeed = 16
local jumpPower = 50
local infiniteJump = false

------------------------------------------------
-- APPLY CHARACTER STATS
------------------------------------------------
local function apply(char)
	local hum = char:WaitForChild("Humanoid")

	hum.WalkSpeed = walkSpeed
	hum.JumpPower = jumpPower
end

player.CharacterAdded:Connect(apply)
if player.Character then apply(player.Character) end

------------------------------------------------
-- INFINITE JUMP
------------------------------------------------
UserInputService.JumpRequest:Connect(function()
	if not infiniteJump then return end

	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

------------------------------------------------
-- UI (RAYFIELD)
------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Movement Controller",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Movement")

------------------------------------------------
-- SLIDERS + TOGGLES
------------------------------------------------

Tab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Increment = 1,
	CurrentValue = walkSpeed,
	Callback = function(v)
		walkSpeed = v

		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end
})

Tab:CreateSlider({
	Name = "JumpPower",
	Range = {50, 250},
	Increment = 1,
	CurrentValue = jumpPower,
	Callback = function(v)
		jumpPower = v

		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = v
		end
	end
})

Tab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Callback = function(v)
		infiniteJump = v
	end
})
