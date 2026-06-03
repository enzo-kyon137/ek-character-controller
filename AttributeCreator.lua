--// ATTRIBUTE CREATOR V1.0 //--

-- This server script is required in ServerScriptService for Character Controller to work properly!
-- !! Place this script into ServerScriptService !!

local Players =
	game:GetService(
		"Players"
	)

local function setupCharacter(character)

	local humanoid =
		character:WaitForChild(
			"Humanoid"
		)

	if humanoid:GetAttribute(
		"CanMove"
		) == nil then

		humanoid:SetAttribute(
			"CanMove",
			true
		)

	end

	if humanoid:GetAttribute(
		"MoveMultiplier"
		) == nil then

		humanoid:SetAttribute(
			"MoveMultiplier",
			1
		)

	end

end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(
		setupCharacter
	)

end)

for _, player in ipairs(
	Players:GetPlayers()
	) do

	if player.Character then

		setupCharacter(
			player.Character
		)

	end

	player.CharacterAdded:Connect(
		setupCharacter
	)

end