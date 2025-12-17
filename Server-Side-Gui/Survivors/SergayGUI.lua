local Players = game:GetService("Players")
local event = game.ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local RunControlEvent = game.ReplicatedStorage.Events.RunControlEvent
local KillerFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local stananimevent = game.ReplicatedStorage.Events.StanAnimEvent
local pigevent = game.ReplicatedStorage.Events.Survivors.Sergay.Pigevent
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")

local function playSound(id, position, duration)
	local soundPart = Instance.new("Part")
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
	soundPart.CFrame = CFrame.new(position)
	soundPart.Parent = workspace

	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 1
	sound.Parent = soundPart
	sound:Play()

	-- ??????? ???? ? Part ????? ?????????
	game:GetService("Debris"):AddItem(soundPart, duration)
end

-- ?? ??????? ????????? ????????? ?????????
local function setCharacterVisibility(character, visible)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") and not (obj.Name == "Pig" or obj.Name == "Sword" or obj.Name == "Invo") then
			obj.Transparency = visible and 0 or 1
			local decal = obj:FindFirstChildOfClass("Decal")
			if decal then
				decal.Transparency = visible and 0 or 1
			end
		elseif obj:IsA("Accessory") then
			local handle = obj:FindFirstChild("Handle")
			if handle and not (handle.Name == "Pig" or handle.Name == "Sword" or handle.Name == "Invo") then
				handle.Transparency = visible and 0 or 1
				local decal = handle:FindFirstChildOfClass("Decal")
				if decal then
					decal.Transparency = visible and 0 or 1
				end
			end
		end
	end
end

-- ?? ?????????? ????????????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	-- ===========================
	-- ?? ???????????: ???????????
	-- ===========================
	if action == "Invisibli_Sergay" then
		-- ?????????? ??? ?????????
		local function playSoundOLD(id, duration) local sound = Instance.new("Sound") sound.SoundId = id sound.Volume = 1 sound.Parent = character.Torso sound:Play() task.delay(duration) sound:Destroy() end
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 2,
			speed = 10,
			priority = 40
		})

		-- Invo ??????? ??? ??????
		local invoPart = character:FindFirstChild("Invo")
		if invoPart then
			invoPart.Transparency = 0
		end

		-- ????? 2 ??? — ????????? ????? (????? Pig, Sword)
		task.delay(2, function()
			if invoPart then invoPart.Transparency = 1 end
			setCharacterVisibility(character, false)
			playSoundOLD("rbxassetid://15256979638", 2)
		end)
		-- ????? 8 ??? ?????????? ?????????
		task.delay(8, function()
			RunControlEvent:FireClient(player, {
				type = "Slowdown",
				duration = 1.5,
				speed = 0,
				priority = 50
			})
			setCharacterVisibility(character, true)

			-- ???????? Pig ? Sword
			if character:FindFirstChild("Sword") then character.Sword.Transparency = 1 end
				if character:FindFirstChild("pig") then
					character.pig.Transparency = 1
				end
				if character:FindFirstChild("HumanoidRootPart") then
					character.HumanoidRootPart.Transparency = 1
				end
		end)

		-- ???????? Invo ??? ???????????
		task.delay(8, function()
			local invoPart2 = character:FindFirstChild("Invo")
			if invoPart2 then
				invoPart2.Transparency = 0
				task.wait(1.5)
				invoPart2.Transparency = 1
			end
		end)

		-- ===========================
		-- ? ???????????: ???
		-- ===========================
	elseif action == "Sword_Sergay" then
		-- ??? ????????????
		local slaheffect = game.ReplicatedStorage.Effects.Sergay.SlashEffect:Clone()
		slaheffect.Parent = character.Torso
		character.Sword.Transparency = 0
		task.delay(1.5, function()
			if character:FindFirstChild("Sword") then
				character.Sword.Transparency = 1
				slaheffect:Destroy()
			end
		end)
		playSound("rbxassetid://12222225", character.Sword.Position, 3)
		-- ?????????? ?????????
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 1.5,
			speed = 10,
			priority = 50
		})

		local globalAlreadyHit = {}
		local duration = 1
		local interval = 0.05
		local steps = math.floor(duration / interval)

		-- ????????? ??????
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { character }

		for i = 1, steps do
			task.delay(interval * (i - 1), function()
				local hitbox = Instance.new("Part")
				hitbox.Size = Vector3.new(4, 7.542, 2.893)
				hitbox.Anchored = true
				hitbox.CanCollide = false
				hitbox.Color = Color3.new(1, 0.278431, 0.0588235)
				hitbox.Transparency = 0.55
				hitbox.Name = "AttackHitbox"
				hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
				hitbox.Parent = game.Workspace.AttackHitboxes

				-- ???????? ?????????
				local parts = workspace:GetPartsInPart(hitbox, overlapParams)
				for _, part in ipairs(parts) do
					local targetChar = part:FindFirstAncestorOfClass("Model")
					if targetChar 
						and not globalAlreadyHit[targetChar] 
						and (targetChar:IsDescendantOf(KillerFolder) or targetChar:IsDescendantOf(NeutralFolder)) then

						local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
						local playerHit = Players:GetPlayerFromCharacter(targetChar)

						if targetHumanoid and targetHumanoid.Health > 0 then
							local Specs = game.ReplicatedStorage.Effects.Sergay.Hiteffect.Sparks:Clone()
							local Specs1 = game.ReplicatedStorage.Effects.Sergay.Hiteffect.Specs1:Clone()
							local Specs2 = game.ReplicatedStorage.Effects.Sergay.Hiteffect.Specs2:Clone()
							local SlashImpact1 = game.ReplicatedStorage.Effects.Sergay.Hiteffect.SlashImpact1:Clone()
							Specs.Parent = targetChar.Torso
							Specs1.Parent = targetChar.Torso
							Specs2.Parent = targetChar.Torso
							SlashImpact1.Parent = targetChar.Torso
							targetHumanoid:TakeDamage(50)
							stanevent:FireClient(playerHit, 5)
							globalAlreadyHit[targetChar] = true
							print("? ???? ???????:", targetChar.Name)
							task.delay(1.5,function()
								Specs:Destroy()
								Specs1:Destroy()
								Specs2:Destroy()	
								SlashImpact1:Destroy()
							end)
                            stananimevent:FireClient(playerHit, 5)
							if playerHit then
								RunControlEvent:FireClient(playerHit, {
									type = "Slowdown",
									duration = 5,
									speed = 0,
									priority = 100
								})
							end
						end
					end
				end

				-- ??????? ???????
				task.delay(0.05, function()
					if hitbox and hitbox.Parent then
						hitbox:Destroy()
					end
				end)
			end)
		end
	elseif action == "Pig_Sergay" then
	local function playSoundOLD(id, duration) local sound = Instance.new("Sound") sound.SoundId = id sound.Volume = 1 sound.Parent = character.Torso sound:Play() task.wait(duration) sound:Destroy() end
	character.pig.Transparency = 0
	for i = 1, 25 do
		task.delay(i, function() 
			playSoundOLD("rbxassetid://15256979638",2)
		end)
	end
	task.delay(25, function()
		character.pig.Transparency = 1
	end)	
    pigevent:FireClient(player,27,25)
	end
end)
