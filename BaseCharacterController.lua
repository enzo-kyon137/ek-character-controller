--// Momentum Movement Prototype
--// Blue Skye inspired approach
--// Keeps Humanoid alive instead of fighting it

--// SERVICES

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

--// PLAYER

local player = Players.LocalPlayer
local character = script.Parent

local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local camera = workspace.CurrentCamera

--// DISABLE DEFAULT JUMP INPUT

ContextActionService:UnbindAction("jumpAction")
ContextActionService:UnbindAction("GamepadJump")
ContextActionService:UnbindAction("TouchJump")

--// STATES

local isGrounded = false

local currentSpeed = 0
local isSprinting = false
local lastMoveDirection = Vector3.zero

local lastGroundedTime = 0

local isDead = false

--// SETTINGS

local walkSpeed = 16
local sprintSpeed = 24

local acceleration = 24
local airAcceleration = 12

local groundDeceleration = 20
local airDeceleration = 4

local friction = 0.88

local jumpPower = humanoid.JumpPower
local coyoteTime = 0.1

--// CHARACTER SETTINGS

humanoid.AutoRotate = true -- Needs to be enabled to make the script compatible with shift-lock!
humanoid.WalkSpeed = 0
humanoid.BreakJointsOnDeath = true -- if enabled, it will do classic Roblox death animation; otherwise it will just ragdoll

--// CAMERA SETTINGS

local defaultFOV = 70
local sprintFOV = 78

local fovLerpSpeed = 8

--// INPUT

local function getMoveDirection()

	local direction = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		direction += Vector3.new(0,0,-1)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		direction += Vector3.new(0,0,1)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		direction += Vector3.new(-1,0,0)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		direction += Vector3.new(1,0,0)
	end

	if direction.Magnitude <= 0 then
		return Vector3.zero
	end

	direction = direction.Unit

	local camCF = camera.CFrame

	local camForward =
		Vector3.new(
			camCF.LookVector.X,
			0,
			camCF.LookVector.Z
		).Unit

	local camRight =
		Vector3.new(
			camCF.RightVector.X,
			0,
			camCF.RightVector.Z
		).Unit

	local moveDirection =
		(camForward * -direction.Z)
		+ (camRight * direction.X)

	return moveDirection.Unit
end

--// GROUND CHECK

local function updateGrounded()

	local state = humanoid:GetState()

	if state == Enum.HumanoidStateType.Running
		or state == Enum.HumanoidStateType.Landed then

		isGrounded = true
		lastGroundedTime = tick()

	else
		isGrounded = false
	end
end

--// JUMP

local function doJump()

	if character:GetAttribute(
		"MovementLocked"
		) then

		return
	end

	local canGroundJump =
		isGrounded
		or ((tick() - lastGroundedTime) <= coyoteTime)

	if canGroundJump then

		humanoid.JumpPower = jumpPower
		--jumpPower + (currentSpeed * 0.03)

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		return
	end

end

--// INPUT EVENTS

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then return end

	--// JUMP

	if input.KeyCode == Enum.KeyCode.Space then
		doJump()
	end
end)

--// SPRINT
UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = true
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
	end
end)

--// MOVEMENT LOOP

local function updateMovement(dt)

	if character:GetAttribute(
		"MovementLocked"
		) then

		humanoid:Move(
			Vector3.zero
		)

		rootPart.AssemblyLinearVelocity =
			Vector3.zero

		return
	end

	updateGrounded()

	if isDead then
		return
	end

	local moveDirection = getMoveDirection()

	local groundedAcceleration =
		isGrounded and acceleration
		or airAcceleration

	local groundedDeceleration =
		isGrounded and groundDeceleration
		or airDeceleration

	local targetSpeed =
		isSprinting
		and sprintSpeed
		or walkSpeed

	--// MOVEMENT

	if moveDirection.Magnitude > 0 then

		currentSpeed +=
			groundedAcceleration * dt

		currentSpeed =
			math.clamp(
				currentSpeed,
				0,
				targetSpeed
			)

		local dot =
			lastMoveDirection:Dot(moveDirection)

		local reversing =
			dot < -0.35

		local turnSpeed =
			isGrounded and 8 or 4

		if reversing then
			currentSpeed -=
				groundedDeceleration
				* 2
				* dt

			currentSpeed =
				math.max(currentSpeed, 0)
		end

		lastMoveDirection =
			lastMoveDirection:Lerp(
				moveDirection,
				dt * turnSpeed
			)

	else

		currentSpeed -=
			groundedDeceleration * dt

		currentSpeed =
			math.max(currentSpeed, 0)

		lastMoveDirection *= friction
	end

	--// SPEED CAP

	currentSpeed =
		math.min(currentSpeed, targetSpeed)

	--// APPLY MOVEMENT

	humanoid.WalkSpeed = currentSpeed

	if currentSpeed > 0.05 then
		humanoid:Move(lastMoveDirection)
	end

	--// CAMERA

	local targetFOV =
		isSprinting
		and sprintFOV
		or defaultFOV

	camera.FieldOfView =
		camera.FieldOfView
		+ (
			targetFOV
			- camera.FieldOfView
		)
		* math.min(dt * fovLerpSpeed, 1)

end

--// FALL LIMIT

RunService.RenderStepped:Connect(function()

	local velocity =
		rootPart.AssemblyLinearVelocity

	if velocity.Y < -250 then

		rootPart.AssemblyLinearVelocity =
			Vector3.new(
				velocity.X,
				-250,
				velocity.Z
			)
	end
end)

--// DEATH SAFEGUARDS

humanoid.Died:Connect(function()

	isDead = true

	isSprinting = false

	camera.FieldOfView =
		defaultFOV
end)

--// MAIN LOOP

RunService.RenderStepped:Connect(updateMovement)

--// DISABLE BAD STATES

--[[ 

	// Bruh, these were making my character fall into the floor on its face instead of breaking apart, now it should make the oof death work

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.Ragdoll,
	false
)

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.FallingDown,
	false
)

]] 

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.Swimming,
	false
)