--//======================================================
--// SlideController V4
--// Momentum Traversal Architecture
--// Airborne Sliding + Ramp Launching
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players =
	game:GetService("Players")

local UserInputService =
	game:GetService("UserInputService")

local RunService =
	game:GetService("RunService")

--//======================================================
--// REFERENCES
--//======================================================

local Player =
	Players.LocalPlayer

local Character =
	script.Parent

local Humanoid =
	Character:WaitForChild("Humanoid")

local RootPart =
	Character:WaitForChild("HumanoidRootPart")

local Torso =
	Character:WaitForChild("Torso")

--//======================================================
--// SETTINGS
--//======================================================

local SLIDE_KEY =
	Enum.KeyCode.C

local SLIDE_ANIMATION_ID =
	"rbxassetid://78873789454352"

--// Entry

local MIN_ENTER_SPEED = 18

local ENTRY_BOOST = 8

local INITIAL_SPEED_MULTIPLIER = 1.05

--// Friction

local GROUND_FRICTION = 0.992

local AIR_FRICTION = 0.998

local MIN_STOP_SPEED = 3

--// Steering

local STEERING_ACCELERATION = 42

local MAX_STEERING_SPEED = 38

--// Terrain

local DOWNHILL_GRAVITY_SCALE = 1.35

--// Camera

local CAMERA_OFFSET =
	Vector3.new(0, -1.2, 0)

--// Airborne slide forgiveness

local AIRBORNE_GRACE_TIME = 0.35

--//======================================================
--// STATES
--//======================================================

local IsSliding = false

local SlideVelocity =
	Vector3.zero

local LastGroundedTime = 0

--//======================================================
--// ANIMATION
--//======================================================

local SlideAnimation =
	Instance.new("Animation")

SlideAnimation.AnimationId =
	SLIDE_ANIMATION_ID

local SlideTrack =
	Humanoid:LoadAnimation(SlideAnimation)

SlideTrack.Priority =
	Enum.AnimationPriority.Action

--//======================================================
--// MATH
--//======================================================

local function projectOnPlane(
	vector,
	normal
)

	return vector
	- normal
		* vector:Dot(normal)
end

local function getHorizontalVelocity()

	local velocity =
		RootPart.AssemblyLinearVelocity

	return Vector3.new(
		velocity.X,
		0,
		velocity.Z
	)
end

local function getHorizontalSpeed()

	return getHorizontalVelocity().Magnitude
end

local function getGroundNormal()

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances =
		{Character}

	local result =
		workspace:Raycast(
			RootPart.Position,
			Vector3.new(0, -6, 0),
			params
		)

	if result then
		return result.Normal
	end

	return Vector3.yAxis
end

local function isGrounded()

	local state =
		Humanoid:GetState()

	return (
		state == Enum.HumanoidStateType.Running
			or state == Enum.HumanoidStateType.Landed
	)
end

--//======================================================
--// SLIDE CONTROL
--//======================================================

local function beginSlide()

	if IsSliding then
		return
	end

	if not isGrounded() then
		return
	end

	local speed =
		getHorizontalSpeed()

	if speed < MIN_ENTER_SPEED then
		return
	end

	IsSliding = true

	Character:SetAttribute(
		"Sliding",
		true
	)

	--// Camera

	Humanoid.CameraOffset =
		CAMERA_OFFSET

	--// Humanoid

	Humanoid.AutoRotate = false

	--// Disable torso collision

	Torso.CanCollide = false

	--// Animation

	SlideTrack:Play(0.08)

	--// Preserve momentum

	SlideVelocity =
		RootPart.AssemblyLinearVelocity
		* INITIAL_SPEED_MULTIPLIER

	--// Entry shove

	SlideVelocity +=
		RootPart.CFrame.LookVector
		* ENTRY_BOOST

	LastGroundedTime = tick()
end

local function endSlide()

	if not IsSliding then
		return
	end

	IsSliding = false

	Character:SetAttribute(
		"Sliding",
		false
	)

	Humanoid.CameraOffset =
		Vector3.zero

	Humanoid.AutoRotate = true

	Torso.CanCollide = true

	SlideTrack:Stop(0.12)
end

--//======================================================
--// INPUT
--//======================================================

UserInputService.InputBegan:Connect(function(
	input,
	gameProcessed
)

	if gameProcessed then
		return
	end

	if input.KeyCode == SLIDE_KEY then
		beginSlide()
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.KeyCode == SLIDE_KEY then
		endSlide()
	end
end)

--//======================================================
--// UPDATE LOOP
--//======================================================

RunService.RenderStepped:Connect(function(dt)

	if not IsSliding then
		return
	end

	local grounded =
		isGrounded()

	--//==================================================
	--// GROUNDED TIMER
	--//==================================================

	if grounded then
		LastGroundedTime = tick()
	end

	local airborneTime =
		tick() - LastGroundedTime

	--//==================================================
	--// SURFACE PHYSICS
	--//==================================================

	if grounded then

		local groundNormal =
			getGroundNormal()

		--// Project momentum onto slope

		SlideVelocity =
			projectOnPlane(
				SlideVelocity,
				groundNormal
			)

		--// Gravity along slope

		local gravityForce =
			projectOnPlane(
				Vector3.new(
					0,
					-workspace.Gravity,
					0
				),
				groundNormal
			)

		SlideVelocity +=
			gravityForce
			* DOWNHILL_GRAVITY_SCALE
			* dt
	end

	--//==================================================
	--// STEERING
	--//==================================================

	local moveDirection =
		Humanoid.MoveDirection

	if moveDirection.Magnitude > 0 then

		local steeringFactor =
			math.clamp(
				(
					SlideVelocity.Magnitude
					/ MAX_STEERING_SPEED
				) ^ 1.4,
				0.02,
				1
			)

		local currentSpeed =
			SlideVelocity.Magnitude

		local targetDirection =
			moveDirection.Unit

		local currentDirection =
			SlideVelocity.Unit

		local blendedDirection =
			currentDirection:Lerp(
				targetDirection,
				steeringFactor
				* STEERING_ACCELERATION
				* dt
			).Unit

		SlideVelocity =
			blendedDirection
			* currentSpeed
	end

	--//==================================================
	--// FRICTION
	--//==================================================

	local friction =
		grounded
		and GROUND_FRICTION
		or AIR_FRICTION

	local airborneDamping =
		0.996 ^ (dt * 60)

	SlideVelocity =
		Vector3.new(
			SlideVelocity.X * airborneDamping,
			SlideVelocity.Y,
			SlideVelocity.Z * airborneDamping
		)

	--//==================================================
	--// APPLY VELOCITY
	--//==================================================

	local currentVelocity =
		RootPart.AssemblyLinearVelocity

	RootPart.AssemblyLinearVelocity =
		Vector3.new(
			SlideVelocity.X,
			currentVelocity.Y,
			SlideVelocity.Z
		)

	--//==================================================
	--// STOPPING
	--//==================================================

	if grounded then

		if SlideVelocity.Magnitude
			<= MIN_STOP_SPEED
		then
			endSlide()
		end

	else

		--// Airborne timeout

		if airborneTime
			>= AIRBORNE_GRACE_TIME
		then

			if SlideVelocity.Magnitude
				<= MIN_STOP_SPEED
			then
				endSlide()
			end
		end
	end
end)

--//======================================================
--// SAFETY
--//======================================================

Humanoid.Died:Connect(function()

	endSlide()
end)