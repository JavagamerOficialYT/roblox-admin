local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

------------------------------------------------
-- STATE
------------------------------------------------
local walkSpeed = 16
local jumpPower = 50
local infiniteJump = false
local hum = nil

------------------------------------------------
-- CHARACTER SETUP
------------------------------------------------
local function bind(char)
	hum = char:WaitForChild("Humanoid")

	hum.WalkSpeed = walkSpeed
	hum.JumpPower = jumpPower
end

player.CharacterAdded:Connect(bind)
if player.Character then bind(player.Character) end

------------------------------------------------
-- APPLY FUNCTION (fixes resets)
------------------------------------------------
local function apply()
	if not hum then return end
	hum.WalkSpeed = walkSpeed
	hum.JumpPower = jumpPower
end

------------------------------------------------
-- INFINITE JUMP
------------------------------------------------
UserInputService.JumpRequest:Connect(function()
	if not infiniteJump then return end
	if not hum then return end

	hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

------------------------------------------------
-- INPUT TEST CONTROLS (replace with your UI)
------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- Toggle infinite jump
	if input.KeyCode == Enum.KeyCode.H then
		infiniteJump = not infiniteJump
		print("Infinite Jump:", infiniteJump)
	end

	-- Example speed controls
	if input.KeyCode == Enum.KeyCode.Equals then
		walkSpeed += 5
		apply()
	end

	if input.KeyCode == Enum.KeyCode.Minus then
		walkSpeed -= 5
		apply()
	end

	if input.KeyCode == Enum.KeyCode.RightBracket then
		jumpPower += 10
		apply()
	end

	if input.KeyCode == Enum.KeyCode.LeftBracket then
		jumpPower -= 10
		apply()
	end
end)
