local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local IncreaseStaminaEvent = ReplicatedStorage.Events:WaitForChild("IncreaseStaminaEvent")
local usedevent = ReplicatedStorage.Events:WaitForChild("Usedcheck")
local egg = game.ReplicatedStorage.KillersParts.Dima.Egg
local animchanger = game.ReplicatedStorage.Events.AnimChange
local zloi = false
local RunService = game:GetService("RunService")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
-- ?????????? ?????? ???????
local rage = 0 -- ?? 0 ?? 100
local Debris = game:GetService("Debris")

local function playHitSound(character, soundId)
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not hrp then return end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 1
	sound.Parent = hrp
	sound:Play()

	-- ????????? ??????? ????? Debris, ?? ???????? ??????????
	Debris:AddItem(sound, 3)
end

local function createHitbox(character, size, offset, damage, duration, interval, hitOncePerTarget)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local alreadyHit = {}
	local steps = math.floor(duration / interval)
	local ownerPlayer = Players:GetPlayerFromCharacter(character)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	-- ????? ?? ??? ?????
	local rageAddedThisAttack = false
	local wasHitThisAttack = false

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			local hitbox = Instance.new("Part")
			hitbox.Size = size
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.278431, 0.0588235)
			hitbox.Transparency = 0.55
			hitbox.CFrame = hrp.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
			hitbox.Parent = game.Workspace.AttackHitboxes

			local parts = workspace:GetPartsInPart(hitbox, params)
			local hitSomeone = false

			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar and targetChar:IsDescendantOf(survivorsFolder) or targetChar and targetChar:IsDescendantOf(NeutralFolder) then
					local torsonew = targetChar:FindFirstChild("Torso")
					playHitSound(character, "rbxassetid://125968415320847")
					if torsonew then
						local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()
						local newbloodefect = game.ReplicatedStorage.Effects.BloodEffect["Blood-02"]:Clone()
						local newbloodeffewctmain = game.ReplicatedStorage.Effects.BloodEffect.Main:Clone()
						local torsonew = targetChar:FindFirstChild("Torso")
						if torsonew then
							newbloodefect.Parent = torsonew
							newbloodeffewctmain.Parent = torsonew
							effectblood.Parent = torsonew
							task.delay(0.6,function()
								effectblood:Destroy()
								newbloodeffewctmain:Destroy()
								newbloodefect:Destroy()
							end)
						end
					end
					if not hitOncePerTarget or not alreadyHit[targetChar] then
						local hum = targetChar:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							hum:TakeDamage(damage)
							alreadyHit[targetChar] = true
							hitSomeone = true
							wasHitThisAttack = true -- ? ??????????, ??? ???? ??? ??????
						end
					end
				end
			end

			-- ???????? ??????? ?????
			if not rageAddedThisAttack and not wasHitThisAttack then
				local missRadius = (size.Magnitude / 2) + 8
				for _, survivor in ipairs(survivorsFolder:GetChildren()) do
					if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
						local hrpSurvivor = survivor.HumanoidRootPart
						local distance = (hrpSurvivor.Position - hitbox.Position).Magnitude
						if distance <= missRadius then
							rage = math.clamp(rage + 10, 0, 300)
							print("?? ?????? ?????! ?????? ?????????: " .. rage .. "%")

							if ownerPlayer then
								game.ReplicatedStorage.Events.KillersEvent.Dima.RAGE:FireClient(ownerPlayer, rage)
							end

							rageAddedThisAttack = true
							break
						end
					end
				end
			end

			task.delay(0.05, function()
				if hitbox and hitbox.Parent then hitbox:Destroy() end
			end)
		end)
	end
end

-- ??????? ? ????????? ???????? ?????? ??????
local Players = game:GetService("Players")
-- ?????? ???? ? ???????
local function changeFace(character, newFaceId)
	local head = character:FindFirstChild("Head")
	if head then
		local oldFace = head:FindFirstChild("face")
		if oldFace then oldFace:Destroy() end

		local newFace = Instance.new("Decal")
		newFace.Name = "face"
		newFace.Texture = "rbxassetid://" .. newFaceId
		newFace.Face = Enum.NormalId.Front
		newFace.Parent = head
	end
end

local function createMovingHitbox(character, size, startOffset, endOffset, damage, duration, interval, hitOncePerTarget)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local alreadyHit = {}
	local steps = math.floor(duration / interval)
	local stopped = false -- ???? ?????????

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	-- ??????? ??????, ???????? ??????????? character
	local player = Players:GetPlayerFromCharacter(character)

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			if stopped then return end -- ???? ??? ?????, ?????? ?? ???????

			-- ???????????? ??????? (?? 0 ?? 1)
			local alpha = i / steps
			local currentOffset = startOffset:Lerp(endOffset, alpha)

			local hitbox = Instance.new("Part")
			hitbox.Size = size
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.278431, 0.0588235)
			hitbox.Transparency = 0.55
			hitbox.CFrame = hrp.CFrame * CFrame.new(currentOffset.X, currentOffset.Y, currentOffset.Z)
			hitbox.Parent = workspace.AttackHitboxes

			-- ???????? ?????????
			local parts = workspace:GetPartsInPart(hitbox, params)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar and targetChar:IsDescendantOf(survivorsFolder) or targetChar and targetChar:IsDescendantOf(NeutralFolder) then
					if not hitOncePerTarget or not alreadyHit[targetChar] then
						local hum = targetChar:FindFirstChildOfClass("Humanoid")
						local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()
						local newbloodefect = game.ReplicatedStorage.Effects.BloodEffect["Blood-02"]:Clone()
						local newbloodeffewctmain = game.ReplicatedStorage.Effects.BloodEffect.Main:Clone()
						local torsonew = targetChar:FindFirstChild("Torso")
						if torsonew then
							newbloodefect.Parent = torsonew
							newbloodeffewctmain.Parent = torsonew
							effectblood.Parent = torsonew
							task.delay(0.6,function()
								effectblood:Destroy()
								newbloodeffewctmain:Destroy()
								newbloodefect:Destroy()
							end)
						end
						if hum and hum.Health > 0 then
							hum:TakeDamage(damage)
							alreadyHit[targetChar] = true
							stopped = true -- <<< ????????????? ?????????? ?????

							-- ???? ??? ???????
							if player then
								stanevent:FireClient(player, 3) -- 3 ?????? ?????
								RunControlEvent:FireClient(player, {
									type = "Slowdown",
									duration = 3,
									speed = 0,
									priority = 150
								})
							changeFace(character, 23489370)
							task.delay(3, function()
							if zloi == true then
							changeFace(character, 919060511)	
							else
							changeFace(character, 321741599)	
							end	
							end)
							end
							break
						end
					end
				end
			end

			-- ??????? ??????? ???? ?????
			task.delay(0.05, function()
				if hitbox and hitbox.Parent then hitbox:Destroy() end
			end)
		end)
	end
end


-- ??????? ?????? ????
local function spawnEgg(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local egg = egg:Clone()
	egg.CFrame = hrp.CFrame -- ?????????? ????? ? ?????
	egg.Anchored = false
	egg.CanCollide = false
	egg.Parent = workspace

	-- ????????? ????????????
	local touchedConn
	touchedConn = egg.Touched:Connect(function(hit)
		local targetChar = hit:FindFirstAncestorOfClass("Model")
		if targetChar and targetChar:IsDescendantOf(survivorsFolder) or targetChar and targetChar:IsDescendantOf(NeutralFolder) then
			local hum = targetChar:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				if zloi == true then
					hum:TakeDamage(10)
				else
					hum:TakeDamage(5)
				end
			end
			egg:Destroy()
			if touchedConn then touchedConn:Disconnect() end
		end
	end)

	-- ??????????????? ????? 5 ??????
	game:GetService("Debris"):AddItem(egg, 5)
end

-- ??????? ??? ?????? ?? ?????????? ?????
local hitCooldowns = {} -- [target.UserId] = ?????_?????_?????_?????_????

local function flyUpAndFall(player, character, height, duration)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end
	local flyeffect = game.ReplicatedStorage.Effects.Dima.MainFly:Clone()
	local grounded = false

	stanevent:FireClient(player, duration)
	RunControlEvent:FireClient(player, {
		type = "Slowdown",
		duration = duration,
		speed = 40,
		priority = 100
	})

	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp

	local force = Instance.new("VectorForce")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.Force = Vector3.new(0, hrp:GetMass() * workspace.Gravity, 0)
	force.Parent = hrp

	-- ?? ????????: ??? ?? ??????????? ??????
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local hit = workspace:Raycast(hrp.Position, Vector3.new(0, height, 0), rayParams)
	if hit then
		-- ????????? ??????, ????? ?? ????????? ???????
		height = math.max(2, (hit.Position - hrp.Position).Y - 2)
	end

	local bodyPos = Instance.new("BodyPosition")
	bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
	bodyPos.D = 100  -- ???????????
	bodyPos.P = 3000 -- ??????? ??????, ????? ?? ???????????
	bodyPos.Position = hrp.Position + Vector3.new(0, height, 0)
	bodyPos.Parent = hrp

	RunControlEvent:FireClient(player, {
		type = "SpeedBoost",
		duration = duration,
		speed = 40
	})
	character.Fly.Value = true
	print("?????? ??????")
	task.delay(duration, function()
		if force then force:Destroy() end
		if bodyPos then bodyPos:Destroy() end
		if attachment then attachment:Destroy() end

		task.spawn(function()
			character.Fly.Value = false
			print("????? ??????")
			while not grounded and character and hrp and humanoid and humanoid.Health > 0 do
				local result = workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), RaycastParams.new())

				if result and result.Instance and result.Instance.CanCollide then
					-- ?????? ??????? ??
					local fallEffect = game.ReplicatedStorage.Effects.Dima.MainFly:Clone()
					fallEffect.Parent = workspace
					fallEffect.CFrame = CFrame.new(hrp.Position.X, result.Position.Y + 0.2, hrp.Position.Z)

					-- ???????? ???????? ???? ????
					for _, obj in ipairs(fallEffect:GetDescendants()) do
						if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
							obj.Enabled = true
						end
					end

					-- ??????? ?????? ????? 1–2 ???????
					game:GetService("Debris"):AddItem(fallEffect, 2)

					-----------------------------------------------------

					task.delay(2.5, function()
						grounded = true
					end)

					stanevent:FireClient(player, 0)
					RunControlEvent:FireClient(player, {
						type = "Slowdown",
						duration = 0,
						speed = 16
					})

					for _, hb in ipairs(workspace.AttackHitboxes:GetChildren()) do
						if hb.Name == "FallHitbox" and hb:GetAttribute("Owner") == player.UserId then
							hb:Destroy()
						end
					end
					break
				end

				-- ?? ??????? ??????? ???????
				local hitbox = Instance.new("Part")
				hitbox.Name = "FallHitbox"
				hitbox.Size = Vector3.new(6, 3, 6)
				hitbox.Anchored = true
				hitbox.CanCollide = false
				hitbox.Color = Color3.new(1, 0, 0)
				hitbox.Transparency = 0.5
				hitbox.CFrame = CFrame.new(hrp.Position - Vector3.new(0, (hrp.Size.Y/2 + hitbox.Size.Y/2), 0))
				hitbox.Parent = workspace.AttackHitboxes
				hitbox:SetAttribute("Owner", player.UserId)

				local fallDamage = math.clamp(math.floor(height * 0.7), 20, 100)

				local parts = workspace:GetPartsInPart(hitbox)
				for _, part in ipairs(parts) do
					local targetChar = part:FindFirstAncestorOfClass("Model")
					if targetChar and (targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(NeutralFolder)) then
						local hum = targetChar:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							local targetPlayer = game.Players:GetPlayerFromCharacter(targetChar)
							if targetPlayer then
								local now = os.clock()
								local lastHit = hitCooldowns[targetPlayer.UserId]

								if not lastHit or now - lastHit >= 10 then
									hum:TakeDamage(fallDamage)
									hitCooldowns[targetPlayer.UserId] = now
								end
							end
						end
					end
				end

				game:GetService("Debris"):AddItem(hitbox, 0.2)
				task.wait(0.2)
			end
		end)
	end)

	-- ?? ????? ??????? (???? ?????)
	for i = 1, 20 do
		task.delay(0.5 * i, function()
			if character and character.Parent then
				spawnEgg(character)
			end
		end)
	end
end

-- ?????????? ????????????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if action == "Attack_Dima" then
		if zloi == false then
		createHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(0, 0, -5), 15, 0.2, 0.05, true)
		task.delay(0.2,function()
		createHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(0, 0, -5), 15, 0.2, 0.05, true)
		end)
		else
		createHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(0, 0, -5), 35, 0.5, 0.05, true)	
		end
	elseif action == "fly_Dima" then
		flyUpAndFall(player, character, 30, 10)
		print("Polet")
	elseif action == "cry_dima" then
		stanevent:FireClient(player, 4) -- 3 ?????? ?????
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 4,
			speed = 0,
			priority = 70
		})
		if zloi == false then
			createMovingHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(5, 0, -5), Vector3.new(-5, 0, -5), 50, 4, 0.05, true)
		else
			createMovingHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(5, 0, -5), Vector3.new(-5, 0, -5), 75, 4, 0.05, true)
		end
		character["Right Arm"].book.Transparency = 0
		task.wait(4)
		character["Right Arm"].book.Transparency = 1
	elseif action == "zloi_Dima" then
		if character:FindFirstChild("Torso") then

			-- ???????? ??????? ?? ???? ?????? ???? R6
			for _, limb in ipairs(character:GetChildren()) do
				if limb:IsA("BasePart") 
					and limb.Name ~= "Torso"
					and limb.Name ~= "HumanoidRootPart"
				then
					-- ???????? ???????, ???? ??? ?????????? ?? ????? ????
					local aura1 = limb:FindFirstChild("Aura1")
					local aura2 = limb:FindFirstChild("Aura2")
					local embers = limb:FindFirstChild("Embers1")

					if aura1 then aura1.Enabled = true end
					if aura2 then aura2.Enabled = true end
					if embers then embers.Enabled = true end
				end
			end
			character.Torso.Aura1.Enabled = true
			character.Torso.Aura2.Enabled = true
			character.Torso.Embers1.Enabled = true
			character.Torso.Light.Enabled = true
			-- ??? ??? ??? ???? ? ????:
			local ownerPlayer = Players:GetPlayerFromCharacter(character)
			rage = 0
			game.ReplicatedStorage.Events.KillersEvent.Dima.RAGE:FireClient(ownerPlayer, rage)

			local torso = character.Torso
			local sound = torso:FindFirstChild("Punch")

			if not sound then
				sound = Instance.new("Sound")
				sound.Name = "Punch"
				sound.SoundId = "rbxassetid://115767823971008"
				sound.Volume = 1
				sound.Parent = torso
			end

			sound:Stop()
			sound:Play()
		end

		changeFace(character, 919060511)
		character.Head.Color = Color3.new(0.666667, 0, 0)
		zloi = true

		-- ?????????? ????? 35 ???
		task.delay(35, function()
			zloi = false
			changeFace(character, 321741599)
			character.Head.Color = Color3.fromRGB(234, 184, 146)
			character.Torso.Aura1.Enabled = false
			character.Torso.Aura2.Enabled = false
			character.Torso.Embers1.Enabled = false
			character.Torso.Light.Enabled = false
			-- ????????? ??????? ???????
			for _, limb in ipairs(character:GetChildren()) do
				if limb:IsA("BasePart")
					and limb.Name ~= "Torso"
					and limb.Name ~= "HumanoidRootPart"
				then
					local aura1 = limb:FindFirstChild("Aura1")
					local aura2 = limb:FindFirstChild("Aura2")
					local embers = limb:FindFirstChild("Embers1")

					if aura1 then aura1.Enabled = false end
					if aura2 then aura2.Enabled = false end
					if embers then embers.Enabled = false end
				end
			end
		end)
	elseif action == "Attack_DimaRAGE" then
		createHitbox(character, Vector3.new(4, 7.5, 3), Vector3.new(0, 0, -5), 45, 0.5, 0.05, true)
	end
end)

