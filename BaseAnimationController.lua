--!strict

--//======================================================
--// EK_Animate
--// Enzo Kyon's Locomotion Animation Controller
--// R6 Momentum-Friendly Animator
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--//======================================================
--// REFERENCES
--//======================================================

local Player = Players.LocalPlayer
local Character = script.Parent

local Humanoid =
	Character:WaitForChild("Humanoid") :: Humanoid

local RootPart =
	Character:WaitForChild("HumanoidRootPart") :: BasePart

--//======================================================
--// SETTINGS
--//======================================================

local WALK_THRESHOLD = 2
local RUN_THRESHOLD = 16

local ANIMATION_SMOOTH_SPEED = 10

local MAX_ANIMATION_SPEED = 1.35
local MIN_ANIMATION_SPEED = 0.85

--//======================================================
--// ANIMATION IDS
--//======================================================

local Animations = {

	Idle = {
		180435571,
		180435792,
	},

	Walk = 180426354,
	Run = 180426354,

	Jump = 125750702,
	Fall = 180436148,

	Climb = 180436334,
	Sit = 178130996,
}

--//======================================================
--// ANIMATION TRACKS
--//======================================================

local Tracks = {}

--//======================================================
--// STATES
--//======================================================

local CurrentState = "Idle"
local CurrentDirection = "Forward"

local CurrentTrack : AnimationTrack? = nil

local CurrentAnimSpeed = 1
local TargetAnimSpeed = 1

--//======================================================
--// ANIMATION LOADING
--//======================================================

local function createTrack(animationId : number)

	local animation = Instance.new("Animation")
	animation.AnimationId =
		"rbxassetid://" .. tostring(animationId)

	local track =
		Humanoid:LoadAnimation(animation)

	return track
end

local function loadAnimations()

	--// Idle

	Tracks.Idle = {
		createTrack(Animations.Idle[1]),
		createTrack(Animations.Idle[2]),
	}

	--// Main movement

	Tracks.Walk =
		createTrack(Animations.Walk)

	Tracks.Run =
		createTrack(Animations.Run)

	Tracks.Jump =
		createTrack(Animations.Jump)

	Tracks.Fall =
		createTrack(Animations.Fall)

	Tracks.Climb =
		createTrack(Animations.Climb)

	Tracks.Sit =
		createTrack(Animations.Sit)
end

--//======================================================
--// TRACK MANAGEMENT
--//======================================================

local function stopCurrentTrack()

	if CurrentTrack then
		CurrentTrack:Stop(0.15)
	end
end

local function playTrack(track : AnimationTrack)

	if CurrentTrack == track then
		return
	end

	stopCurrentTrack()

	CurrentTrack = track

	track:Play(0.15)
end

--//======================================================
--// RANDOM IDLE
--//======================================================

local function getIdleTrack()

	return Tracks.Idle[
	math.random(1, #Tracks.Idle)
	]
end

--//======================================================
--// MOVEMENT ANALYSIS
--//======================================================

local function getHorizontalVelocity()

	local velocity =
		RootPart.AssemblyLinearVelocity

	return Vector3.new(
		velocity.X,
		0,
		velocity.Z
	)
end

local function getLocalVelocity()

	local velocity =
		getHorizontalVelocity()

	return RootPart.CFrame:VectorToObjectSpace(
		velocity
	)
end

local function getSpeed()

	return getHorizontalVelocity().Magnitude
end

--//======================================================
--// DIRECTIONAL ANALYSIS
--//======================================================

local function updateDirection()

	local localVelocity =
		getLocalVelocity()

	local x = localVelocity.X
	local z = localVelocity.Z

	--// Basic directional logic

	if math.abs(z) > math.abs(x) then

		if z < 0 then
			CurrentDirection = "Forward"
		else
			CurrentDirection = "Backward"
		end

	else

		if x > 0 then
			CurrentDirection = "Right"
		else
			CurrentDirection = "Left"
		end
	end
end

--//======================================================
--// STATE RESOLUTION
--//======================================================

local function resolveState()

	local humanoidState =
		Humanoid:GetState()

	--// Air states

	if humanoidState == Enum.HumanoidStateType.Jumping then
		return "Jump"
	end

	if humanoidState == Enum.HumanoidStateType.Freefall then
		return "Fall"
	end

	if humanoidState == Enum.HumanoidStateType.Climbing then
		return "Climb"
	end

	if humanoidState == Enum.HumanoidStateType.Seated then
		return "Sit"
	end

	--// Ground locomotion

	local speed = getSpeed()

	if speed <= WALK_THRESHOLD then
		return "Idle"
	end

	if speed <= RUN_THRESHOLD then
		return "Walk"
	end

	return "Run"
end

--//======================================================
--// ANIMATION SPEED
--//======================================================

local function updateAnimationSpeed(dt)

	local speed = getSpeed()

	--// Momentum-friendly scaling

	if CurrentState == "Walk" then

		TargetAnimSpeed =
			math.clamp(
				speed / 10,
				MIN_ANIMATION_SPEED,
				1.1
			)

	elseif CurrentState == "Run" then

		TargetAnimSpeed =
			math.clamp(
				speed / 18,
				1,
				MAX_ANIMATION_SPEED
			)

	else
		TargetAnimSpeed = 1
	end

	--// Smooth animation speed

	CurrentAnimSpeed =
		CurrentAnimSpeed
		+ (
			(TargetAnimSpeed - CurrentAnimSpeed)
			* math.min(dt * ANIMATION_SMOOTH_SPEED, 1)
		)

	--// Apply

	if CurrentTrack then
		CurrentTrack:AdjustSpeed(CurrentAnimSpeed)
	end
end

--//======================================================
--// ANIMATION SWITCHING
--//======================================================

local function updateAnimationState()

	local newState =
		resolveState()

	if newState == CurrentState then
		return
	end

	CurrentState = newState

	--// State playback

	if CurrentState == "Idle" then

		playTrack(
			getIdleTrack()
		)

	elseif CurrentState == "Walk" then

		playTrack(
			Tracks.Walk
		)

	elseif CurrentState == "Run" then

		playTrack(
			Tracks.Run
		)

	elseif CurrentState == "Jump" then

		playTrack(
			Tracks.Jump
		)

	elseif CurrentState == "Fall" then

		playTrack(
			Tracks.Fall
		)

	elseif CurrentState == "Climb" then

		playTrack(
			Tracks.Climb
		)

	elseif CurrentState == "Sit" then

		playTrack(
			Tracks.Sit
		)
	end
end

--//======================================================
--// INITIALIZATION
--//======================================================

loadAnimations()

playTrack(
	getIdleTrack()
)

--//======================================================
--// UPDATE LOOP
--//======================================================

RunService.RenderStepped:Connect(function(dt)

	updateDirection()

	updateAnimationState()

	updateAnimationSpeed(dt)
	
end)