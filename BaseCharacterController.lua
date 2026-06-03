--// M.M.P //--

--// SERVICES

local Players = game:GetService("Players")
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
-- ContextActionService:UnbindAction("TouchJump") -- nah bro, let mobile players have their jump button back ;-;

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

local jumpHeld = false
local autoJumpConsumed = false

--// CONTROLLER PRESETS (very useful, you can make one yourself :D)

local ControllerPresets = {

	Vanilla = { --// Vanilla: Emulates the default Roblox movement, but with smooth turning. For general stuff.

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
		InstantAcceleration = true,
	},

	Enhanced = { --// Enhanced: Source-like, more forgiving but sluggish. For platformers and modern games.

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
		InstantAcceleration = false,
	},

	Precise = { --// Precise: Instant turning & acceleration without friction. Perfect for obbies and classic games (kinda).
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
		InstantAcceleration = true,
	},
}

--// SETTINGS

local Settings = {

	SprintEnabled = true, -- If you don't need sprinting, you can set this to false.

	DefaultFOV = 70,
	SprintFOV = 78,

	FOVLerpSpeed = 8,

	AutoJump = true, -- True = enables auto-jump (automatic); False = disables auto-jump (manual)

	UseJumpPower = true,

	JumpPower = 50,
	JumpHeight = 7.2,
}

local Keybinds = {

	Sprint = {
		Keyboard = Enum.KeyCode.LeftShift,
		Gamepad = Enum.KeyCode.ButtonL3,
	},

	Jump = {
		Keyboard = Enum.KeyCode.Space,
		Gamepad = Enum.KeyCode.ButtonA,
	},

	ShiftLock = {
		Keyboard = Enum.KeyCode.LeftControl,
	},

}

local Preset =
	ControllerPresets.Vanilla

local walkSpeed = Preset.WalkSpeed
local sprintSpeed = Preset.SprintSpeed

local acceleration = Preset.Acceleration
local airAcceleration = Preset.AirAcceleration

local groundDeceleration = Preset.GroundDeceleration
local airDeceleration = Preset.AirDeceleration

local friction = Preset.Friction

local coyoteTime = 0.1

--// CHARACTER SETTINGS

humanoid.AutoRotate = true -- Needs to be enabled to make the script compatible with shift-lock!
humanoid.WalkSpeed = 0
humanoid.BreakJointsOnDeath = true -- if enabled, it will do classic Roblox death animation; otherwise it will just ragdoll

humanoid.UseJumpPower = -- Internal approach to configuring jumping :D
	Settings.UseJumpPower

if Settings.UseJumpPower then -- if it is enabled, it will use JumpPower property, otherwise, it will use JumpHeight.

	humanoid.JumpPower =
		Settings.JumpPower

else -- just as said... it will use Jump Height :P

	humanoid.JumpHeight =
		Settings.JumpHeight

end

--// CAMERA SETTINGS

local defaultFOV = Settings.DefaultFOV
local sprintFOV = Settings.SprintFOV

local fovLerpSpeed = Settings.FOVLerpSpeed

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

		if Settings.UseJumpPower then

			humanoid.JumpPower =
				Settings.JumpPower

		else

			humanoid.JumpHeight =
				Settings.JumpHeight

		end

		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)

		return
	end

end

--// INPUT EVENTS

ContextActionService:BindAction(
	"EKJump",
	function(_, state)

		if state == Enum.UserInputState.Begin then

			jumpHeld = true
			doJump()

		elseif state == Enum.UserInputState.End then

			jumpHeld = false

		end

		return Enum.ContextActionResult.Sink
	end,
	false,
	Keybinds.Jump.Keyboard,
	Keybinds.Jump.Gamepad
)

--// SPRINT
ContextActionService:BindAction(
	"EKSprint",
	function(_, state)

		if not Settings.SprintEnabled then
			return Enum.ContextActionResult.Pass
		end

		if state == Enum.UserInputState.Begin then

			isSprinting = true

		elseif state == Enum.UserInputState.End then

			isSprinting = false

		end

		return Enum.ContextActionResult.Sink
	end,
	false,
	Keybinds.Sprint.Keyboard,
	Keybinds.Sprint.Gamepad
)

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

	--// AUTO JUMP

	if not isGrounded then
		autoJumpConsumed = false
	end

	if Settings.AutoJump
		and jumpHeld
		and isGrounded
		and not autoJumpConsumed then

		autoJumpConsumed = true

		doJump()

	end

	local moveDirection = getMoveDirection()

	local groundedAcceleration =
		isGrounded and acceleration
		or airAcceleration

	local groundedDeceleration =
		isGrounded and groundDeceleration
		or airDeceleration

	local targetSpeed =
		(Settings.SprintEnabled and isSprinting)
		and sprintSpeed
		or walkSpeed

	--// MOVEMENT

	if moveDirection.Magnitude > 0 then

		if Preset.InstantAcceleration then

			currentSpeed = targetSpeed

		else

			currentSpeed +=
				groundedAcceleration * dt

			currentSpeed =
				math.clamp(
					currentSpeed,
					0,
					targetSpeed
				)

		end

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

		if Preset.InstantAcceleration then

			currentSpeed = 0

		else

			currentSpeed -=
				groundedDeceleration * dt

			currentSpeed =
				math.max(currentSpeed, 0)

		end

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

	local speedAlpha =
		math.clamp(
			(currentSpeed - walkSpeed)
			/ (sprintSpeed - walkSpeed),
			0,
			1
		)

	local targetFOV =
		defaultFOV
		+ (
			(sprintFOV - defaultFOV)
			* speedAlpha
		)

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