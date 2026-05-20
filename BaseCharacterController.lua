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

local rootJoint =
	rootPart:WaitForChild("RootJoint")

local camera = workspace.CurrentCamera

--// DISABLE DEFAULT JUMP INPUT

ContextActionService:UnbindAction("jumpAction")
ContextActionService:UnbindAction("GamepadJump")
ContextActionService:UnbindAction("TouchJump")

--// STATES

local isGrounded = false
local touchingWall = false

local wallNormal = Vector3.zero

local currentSpeed = 0
local isSprinting = false
local lastMoveDirection = Vector3.zero

local lastGroundedTime = 0

local oldHipHeight = humanoid.HipHeight

--// SETTINGS

local walkSpeed = 16
local sprintSpeed = 24

local maxMomentumSpeed = 100

local acceleration = 7
local airAcceleration = 3

local groundDeceleration = 7
local airDeceleration = 1.25

local friction = 0.9

local jumpPower = humanoid.JumpPower
local coyoteTime = 0.1

--// WALLKICK

local wallKickForce = 60
local wallDetectionDistance = 3

--// CHARACTER SETTINGS

humanoid.AutoRotate = true -- enabled to make the script compatible with shift-lock
humanoid.WalkSpeed = 0

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

--// WALL CHECK

local function updateWallCheck()

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(
		rootPart.Position,
		-- rootPart.CFrame.LookVector * wallDetectionDistance, // commented to try fix the wallkick mechanism
		lastMoveDirection * wallDetectionDistance, -- should fix for now
		params
	)
	
	--[[ no longer need this since it doesnt allow for chained walljumps and proper wallkicks
	if result and not isGrounded then
		touchingWall = true
	else
		touchingWall = false
	end
	]]
	
	if result and not isGrounded then -- new wallcheck implementation

		touchingWall = true
		wallNormal = result.Normal

	else

		touchingWall = false
		wallNormal = Vector3.zero
	end
end

--// JUMP

local function doJump()

	local canGroundJump =
		isGrounded
		or ((tick() - lastGroundedTime) <= coyoteTime)

	if canGroundJump then

		humanoid.JumpPower = jumpPower
		--jumpPower + (currentSpeed * 0.03)

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		return
	end

	--// WALLKICK

	if touchingWall then

		local boostDirection =
			-rootPart.CFrame.LookVector

		rootPart.Velocity =
			(boostDirection * wallKickForce)
			+ Vector3.new(
				0,
				jumpPower,
				0
			)
		
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

	updateGrounded()
	updateWallCheck()

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

		currentSpeed = targetSpeed

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
			turnSpeed *= 0.35
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

	--// ROTATION
	
	--[[ commented this because it makes shiftlock not work since it's overriding, roblox autorotate already does it better
	if lastMoveDirection.Magnitude > 0.1 then

		rootPart.CFrame = CFrame.lookAt(
			rootPart.Position,
			rootPart.Position + lastMoveDirection
		)
	end
	]]
end

--// FALL LIMIT

RunService.RenderStepped:Connect(function()

	local velocity = rootPart.Velocity

	if velocity.Y < -250 then

		rootPart.Velocity = Vector3.new(
			velocity.X,
			-250,
			velocity.Z
		)
	end
end)

--// MAIN LOOP

RunService.RenderStepped:Connect(updateMovement)

--// DISABLE BAD STATES

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.Ragdoll,
	false
)

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.FallingDown,
	false
)

humanoid:SetStateEnabled(
	Enum.HumanoidStateType.Swimming,
	false
)