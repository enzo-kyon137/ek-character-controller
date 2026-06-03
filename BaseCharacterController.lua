--// M.M.P //--

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

--// CUSTOM SHIFTLOCK REMAPPING WORKAROUND LOL
--// (so we can change MouseLockController's boundkeys to control keys instead)

task.spawn(function()

	local player = Players.LocalPlayer

	if not player then
		return
	end

	local success, mouseLockController = pcall(function()

		return player
			:WaitForChild("PlayerScripts")
			:WaitForChild("PlayerModule")
			:WaitForChild("CameraModule")
			:WaitForChild("MouseLockController")

	end)

	if not success or not mouseLockController then
		return
	end

	local boundKeys =
		mouseLockController:WaitForChild(
			"BoundKeys",
			5
		)

	if boundKeys then
		boundKeys.Value =
			"LeftControl,RightControl"
	end

end)

--// STATES

local isGrounded = false

local currentSpeed = 0
local isSprinting = false
local lastMoveDirection = Vector3.zero

local lastGroundedTime = 0

local isDead = false

--// SETTINGS

local ControllerPresets = {

	Vanilla = {

		WalkSpeed = 16,
		SprintSpeed = 24,

		Acceleration = 36,
		AirAcceleration = 18,

		GroundDeceleration = 40,
		AirDeceleration = 10,

		Friction = 0.75,

		TurnSpeed = 20,
		AirTurnSpeed = 8,

		InstantTurning = false,
	},

	Enhanced = {

		WalkSpeed = 16,
		SprintSpeed = 24,

		Acceleration = 18,
		AirAcceleration = 9,

		GroundDeceleration = 24,
		AirDeceleration = 5,

		Friction = 0.92,

		TurnSpeed = 14,
		AirTurnSpeed = 6,

		InstantTurning = false,
	},

	Precise = {

		WalkSpeed = 16,
		SprintSpeed = 24,

		Acceleration = 60,
		AirAcceleration = 60,

		GroundDeceleration = 60,
		AirDeceleration = 60,

		Friction = 0,

		TurnSpeed = 999,
		AirTurnSpeed = 999,

		InstantTurning = true,
	},
}

local Preset =
	ControllerPresets.Precise

local walkSpeed = Preset.WalkSpeed
local sprintSpeed = Preset.SprintSpeed

local acceleration = Preset.Acceleration
local airAcceleration = Preset.AirAcceleration

local groundDeceleration = Preset.GroundDeceleration
local airDeceleration = Preset.AirDeceleration

local friction = Preset.Friction

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

	local moveDirection =
		humanoid.MoveDirection

	if moveDirection.Magnitude <= 0 then
		return Vector3.zero
	end

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

	local state = humanoid:GetState()

	local canGroundJump =
		isGrounded
		or state == Enum.HumanoidStateType.Climbing
		or ((tick() - lastGroundedTime) <= coyoteTime)

	if canGroundJump then

		humanoid.JumpPower = jumpPower
		--jumpPower + (currentSpeed * 0.03)

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		return
	end

end

--// INPUT EVENTS

ContextActionService:BindAction(
	"EKJump",
	function(_, state)

		if state
			== Enum.UserInputState.Begin then

			doJump()

		end

		return Enum.ContextActionResult.Sink
	end,
	false,
	Enum.KeyCode.Space,
	Enum.KeyCode.ButtonA
)

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
			isGrounded
			and Preset.TurnSpeed
			or Preset.AirTurnSpeed

		if reversing then
			currentSpeed -=
				groundedDeceleration
				* 2
				* dt

			currentSpeed =
				math.max(currentSpeed, 0)
		end

		if Preset.InstantTurning then

			lastMoveDirection = moveDirection

		else

			if currentSpeed < 2 then

				lastMoveDirection = moveDirection

			else

				lastMoveDirection =
					lastMoveDirection:Lerp(
						moveDirection,
						dt * turnSpeed
					)
			end

		end

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