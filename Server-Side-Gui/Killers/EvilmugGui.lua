local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local StanEvent = ReplicatedStorage.Events:WaitForChild("StanEvent")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local HitEvent = ReplicatedStorage.Events:WaitForChild("HitEvent")
local BlockingPlayers = {} -- ??? ?????? ?????????
local RecentlyHit = {} -- ??? ??????? ??????? ????
local evilmugxranenie = game.ReplicatedStorage.KillersParts.Evilmug -- ????? ???? ?????????? ???? ???????
local Debris = game:GetService("Debris")

-- ?????????? ??????? ??? ???????? ??????????? ?????????
local InvisBackups = {}

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

-- ??????? ??? ???????????? ???????? ?? ?????
local HealthBeforeBlock = {}

local function setCharacterInvisible(character, invisible)
	if not character then return end

	if invisible then
		local backup = {}
		for _, obj in ipairs(character:GetDescendants()) do
			if obj:IsA("BasePart") then
				backup[obj] = {
					Transparency = obj.Transparency,
					CanCollide = obj.CanCollide
				}
				obj.Transparency = 1
				obj.CanCollide = false
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				backup[obj] = {Transparency = obj.Transparency}
				obj.Transparency = 1
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
				backup[obj] = {Enabled = obj.Enabled}
				obj.Enabled = false
			end
		end

		-- ???????? ???
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			backup["__nameDisplay"] = hum.DisplayDistanceType
			pcall(function() hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
		end

		-- ????????? ??????? ? ????????? ??????????
		InvisBackups[character] = backup

	else
		local backup = InvisBackups[character]
		if backup then
			for obj, vals in pairs(backup) do
				if typeof(obj) == "Instance" and obj.Parent then
					if obj:IsA("BasePart") then
						if vals.Transparency then obj.Transparency = vals.Transparency end
						if vals.CanCollide ~= nil then obj.CanCollide = vals.CanCollide end
					elseif obj:IsA("Decal") or obj:IsA("Texture") then
						if vals.Transparency then obj.Transparency = vals.Transparency end
					elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
						if vals.Enabled ~= nil then obj.Enabled = vals.Enabled end
					end
				end
			end

			-- ??????????????? ???
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum and backup["__nameDisplay"] then
				pcall(function() hum.DisplayDistanceType = backup["__nameDisplay"] end)
			end

			InvisBackups[character] = nil
		else
			-- ?? ?????? ???? ??? ?????? (????????? ??????????????)
			for _, obj in ipairs(character:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.Transparency = 0
					obj.CanCollide = true
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = 0
				elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
					obj.Enabled = true
				end
			end
		end
	end
end

local function createHitbox(character, damage, duration, interval)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local alreadyHit = {}
	local steps = math.floor(duration / interval)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(4, 7.5, 3)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Transparency = 0.55
			hitbox.Name = "Hitbox" -- ???????? AttackHitbox ?? Hitbox
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar 
					and not alreadyHit[targetChar] 
					and (targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(NeutralFolder)) then
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

					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 then
						targetHumanoid:TakeDamage(damage)
						alreadyHit[targetChar] = true
					end
				end
			end

			task.delay(0.05, function()
				if hitbox and hitbox.Parent then
					hitbox:Destroy()
				end
			end)
		end)
	end
end

local function getClosestTarget(hrp)
	local closest, closestDist = nil, math.huge
	local folders = {survivorsFolder, NeutralFolder}
	for _, folder in ipairs(folders) do
		for _, targetChar in ipairs(folder:GetChildren()) do
			local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
			if targetHRP and targetHum and targetHum.Health > 0 then
				local dist = (targetHRP.Position - hrp.Position).Magnitude
				if dist < closestDist then
					closest = targetChar
					closestDist = dist
				end
			end
		end
	end
	return closest
end

-- ?? ????? ????? ???????? ???? (evilmugAbility)
local function evilmugAbility(player)
	local char = player.Character
	if not char then return end
	playHitSound(char, "rbxassetid://92889260624751")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	char.Torso.Main.ParticleEmitter.Enabled = true
	char.Torso.Main.ParticleEmitter2.Enabled = true
	-- ????????? ???????? ?? ?????
	HealthBeforeBlock[player] = hum.Health

	-- ?????????? ????
	BlockingPlayers[player] = true

	RunControlEvent:FireClient(player, {
		type = "Slowdown",
		duration = 3.2,
		speed = 0,
		priority = 200
	})
	RunControlEvent:FireClient(player, {
		type = "PlayAnim",
		anim = "Teleport",
		duration = 3.2
	})

	-- ???? ????????? 3.2 ???????
	task.delay(3.2, function()
		BlockingPlayers[player] = nil
		char.Torso.Main.ParticleEmitter.Enabled = false
		char.Torso.Main.ParticleEmitter2.Enabled = false
		-- ??????? ??????????? ???????? ???? ???? ?????????? ??? ??????????
		if HealthBeforeBlock[player] then
			HealthBeforeBlock[player] = nil
		end
	end)
end

-- ?? ????? ????? ???????? ???? (? ???????)
HitEvent.OnServerEvent:Connect(function(player, stunTime)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	print("?? ????? ??????? ????:", player.Name)
	RecentlyHit[player] = tick()

	-- ? ???? ????? ????????? ? ???????? ?? ????? ?????????? ????????? + ?????????????? ????????
	if BlockingPlayers[player] then
		BlockingPlayers[player] = nil
		print("?? ?????", player.Name, "??????? ????????????!")
		char.Torso.Main.ParticleEmitter.Enabled = false
		char.Torso.Main.ParticleEmitter2.Enabled = false
		-- ?? ??????????????? ???????? ?? ????? (??? ? ?????? ???????)
		if HealthBeforeBlock[player] then
			hum.Health = HealthBeforeBlock[player]
			HealthBeforeBlock[player] = nil
			print("?? ????????????? ???????? ??????", player.Name, "??:", hum.Health)
		end
		hum.MaxHealth = hum.MaxHealth + 50
		hum.Health = math.clamp(hum.Health + 50, 50, hum.MaxHealth)

		local targetChar = getClosestTarget(hrp)
		if targetChar then
			local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
			local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
			if targetHRP and targetHum and targetHum.Health > 0 then
				-- ?? ???????? ?? ????? ??????
				hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)

				RunControlEvent:FireClient(player, {
					type = "PlayAnim",
					anim = "Yspex",
					duration = 0.25
				})
				RunControlEvent:FireClient(player, {
					type = "Slowdown",
					duration = 0.25,
					speed = 0,
					priority = 100
				})

				task.wait(0.25)
				RunControlEvent:FireClient(player, { type = "PlayAnim", anim = "Attack" })
				targetHum:TakeDamage(25)

				-- ?????? ???????? ????
				StanEvent:FireClient(player, 2)
				RunControlEvent:FireClient(player, {
					type = "Slowdown",
					duration = 2,
					speed = 0,
					priority = 100
				})
				RunControlEvent:FireClient(player, {
					type = "PlayAnim",
					anim = "Smex",
					duration = 2
				})
			end
		end
	end
end)

-- ??????? ??? ???????????? ???????? ???????????? ?? ???????
local activeAbilities = {}

-- ?????????? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	if action == "Attack_Evilmug" then
		createHitbox(character, 21, 0.5, 0.05)
	elseif action == "Counter_Evilmug" then
		evilmugAbility(player)
	elseif action == "Rivor_Evilmug" then
		-- ... ????????? ??? Rivor_Evilmug ??? ????????? ...
		if activeAbilities[player] then
			print("STEVE OUTCOME already active for", player.Name)
			return
		end
		activeAbilities[player] = true

		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then
			activeAbilities[player] = nil
			return
		end

		print("?? STEVE OUTCOME activated by", player.Name)

		-- ?? 1. FLASH TWICE (telegraph)
		for i = 1, 2 do
			local flash = Instance.new("Highlight")
			flash.FillColor = Color3.fromRGB(255, 255, 255)
			flash.OutlineColor = Color3.fromRGB(0, 0, 255)
			flash.FillTransparency = 0.3
			flash.OutlineTransparency = 0
			flash.Parent = character
			game:GetService("Debris"):AddItem(flash, 0.25)
			task.wait(0.25)
		end

		-- ?? 2. SPIN ATTACK (melee burst)
		RunControlEvent:FireClient(player, { type = "PlayAnim", anim = "SpinAttack", duration = 1 })
		RunControlEvent:FireClient(player, { type = "Slowdown", duration = 1, speed = 0, priority = 100 })

		local spinHit = false
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = {character}

		for step = 1, 10 do
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(6, 8, 6)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Transparency = 1
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
			hitbox.Parent = workspace

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar and (survivorsFolder:FindFirstChild(targetChar.Name) or NeutralFolder:FindFirstChild(targetChar.Name)) then
					local hum = targetChar:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						hum:TakeDamage(20)
						spinHit = true
						print("STEVE OUTCOME spin hit:", targetChar.Name)
						break
					end
				end
			end
			game:GetService("Debris"):AddItem(hitbox, 0.1)
			task.wait(0.1)
			if spinHit then break end
		end

		-- ?? 3. IF HIT ? TELEPORT FAR AWAY + FLOAT SLOWLY TOWARD NEAREST SURVIVOR
		if spinHit then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://15256979638" -- drowning theme
			sound.Volume = 1.5
			sound.Looped = true
			sound.Parent = hrp
			sound:Play()

			local targetChar = getClosestTarget(hrp)
			if targetChar then
				local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
				local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
				if targetHRP and targetHum then
					-- ?? TELEPORT FAR AWAY — 150 studs behind target + 40 studs up
					local teleportPos = targetHRP.Position - targetHRP.CFrame.LookVector * 150 + Vector3.new(0, 40, 0)
					hrp.CFrame = CFrame.new(teleportPos, targetHRP.Position)

					-- ?? ????????? ???????? ???? ?????? ?????????
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end

					-- ?? FLOAT SLOWLY TOWARD TARGET
					local bodyGyro = Instance.new("BodyGyro")
					bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
					bodyGyro.P = 6000
					bodyGyro.Parent = hrp

					local bodyVel = Instance.new("BodyVelocity")
					bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
					bodyVel.P = 5000
					bodyVel.Parent = hrp

					local particle = Instance.new("ParticleEmitter")
					particle.Texture = "rbxassetid://241837157" -- spooky smoke effect
					particle.Color = ColorSequence.new(Color3.fromRGB(50, 50, 255))
					particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
					particle.Rate = 40
					particle.Lifetime = NumberRange.new(0.5, 1)
					particle.Speed = NumberRange.new(0)
					particle.Parent = hrp

					local flySpeed = 40 -- speed of flight
					local reached = false

					local rayParams = RaycastParams.new()
					rayParams.FilterType = Enum.RaycastFilterType.Exclude
					rayParams.FilterDescendantsInstances = {character}

					for i = 1, 300 do
						if not targetHRP.Parent or not hrp.Parent then break end

						local direction = (targetHRP.Position - hrp.Position)
						local dist = direction.Magnitude
						local dirUnit = direction.Unit

						-- ????????? ????? ??????? (? ??????? ????)
						local rayResult = workspace:Raycast(hrp.Position, dirUnit * 8, rayParams)
						if rayResult then
							-- ? ???? ??????? ????? — ??????????????? ?????? ???
							local hitPos = rayResult.Position
							-- ??????? ????????? ?????? ? ??????????? ???? (??????)
							local teleportPos = hitPos + dirUnit * 15 -- ???? ?? ????? ??????
							hrp.CFrame = CFrame.new(teleportPos, targetHRP.Position)

							print("?? ????? ?????????? — ???????? ?????? ???????????")
						end

						-- ???????? ? ????
						bodyVel.Velocity = dirUnit * flySpeed
						bodyGyro.CFrame = CFrame.lookAt(hrp.Position, targetHRP.Position)

						-- ????????? ?????????? ????
						if dist < 6 then
							reached = true
							break
						end

						task.wait(0.1)
					end

					-- ?? WHEN REACHED ? DAMAGE + RAGDOLL
					if reached and targetHum.Health > 0 then
						targetHum:TakeDamage(45)
					end

					bodyVel:Destroy()
					bodyGyro:Destroy()
					particle.Enabled = false
					game:GetService("Debris"):AddItem(particle, 2)

					-- ?? ?????????? ???????? ????? ??????
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = true
						end
					end
				end
			end

			sound:Stop()
			sound:Destroy()
		end

		activeAbilities[player] = nil
	elseif action == "Teleport_Evilmug" then
		-- ... ????????? ??? Teleport_Evilmug ??? ????????? ...
		if activeAbilities[player] then return end
		activeAbilities[player] = true

		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if not character or not hrp or not hum then
			activeAbilities[player] = nil
			return
		end

		-- ????? ????????? ???? (????? ???????? ?? ????????? ???????, ???? ?????)
		local targetChar = getClosestTarget(hrp)
		if not targetChar then
			activeAbilities[player] = nil
			return
		end

		local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
		local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
		if not targetHRP or not targetHum or targetHum.Health <= 0 then
			activeAbilities[player] = nil
			return
		end

		-- 1) ?????? ??????? ????????? ?????????
		setCharacterInvisible(character, true)

		-- 2) ??????????????? ?? ????? ???? (????? ????? ?????? ? ??????? ?? ???)
		-- ?????????? LookVector ???? ????? ????????? "?? ??????"
		local behindOffset = 3 -- ?????? ?????? doel (?????????????? ?? ??????)
		local teleportCFrame = CFrame.new(targetHRP.Position - targetHRP.CFrame.LookVector * behindOffset, targetHRP.Position)
		hrp.CFrame = teleportCFrame

		-- ???????????: ????????? ????????? ????????/?????? ?? ???????
		RunControlEvent:FireClient(player, { type = "PlayAnim", anim = "Teleport", duration = 0.2 })
		RunControlEvent:FireClient(player, { type = "Slowdown", duration = 0.2, speed = 0, priority = 100 })

		-- 3) ?????? ??????????? 5 ??????, ????? ?????????? ??????? (????????? ??????????????)
		task.delay(5, function()
			-- ????????, ??? ???????? ??? ??? ??????????
			playHitSound(character, "rbxassetid://92889260624751")
			if character and character.Parent then
				setCharacterInvisible(character, false)
			end
			activeAbilities[player] = nil
		end)
	end
end)