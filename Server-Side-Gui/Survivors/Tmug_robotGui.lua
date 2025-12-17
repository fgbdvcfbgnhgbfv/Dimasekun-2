local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local morespeed = ReplicatedStorage.Events:WaitForChild("MoreSpeed")
local event = ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local RunControlEvent = ReplicatedStorage.Events.RunControlEvent
local animchanger = game.ReplicatedStorage.Events.AnimChange2
local survivorsFolder = Workspace:WaitForChild("Players"):WaitForChild("Survivors")
local killerFolder = Workspace:WaitForChild("Players"):WaitForChild("Killer")
local controlevent = game.ReplicatedStorage.Events.Control
local cancelHeal = ReplicatedStorage.Events.MetalTmug.CancelHeal
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
-- ??????? ???????? ??????
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local stananimevent = game.ReplicatedStorage.Events.StanAnimEvent
-- ???????????? ????????
local MAX_HEALTH = 300
local HEAL_AMOUNT = 50
local HEAL_TIME = 7
local COOLDOWN = 30

local playerCooldowns = {}

local function startHealing(player)
	if playerCooldowns[player] and tick() - playerCooldowns[player] < COOLDOWN then
		warn(player.Name .. " ??? ?? ????? ? ???????????!")
		return
	end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	stanevent:FireClient(player, 7)
	-- ???????? ?????????
	local highlight = character:FindFirstChild("HealHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "HealHighlight"
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
		highlight.FillTransparency = 0.6
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Enabled = false
		highlight.Parent = character
	end

	-- ?? ???????? ?? "???? ??????????"
	local fasterHeal = false
	for _, otherPlayer in pairs(game.Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local hgpoar = otherPlayer.Character:FindFirstChild("hgpoar")

			if hgpoar then
				-- ???? ??? StringValue, ???????? ????????
				if hgpoar:IsA("StringValue") then
					if hgpoar.Value ~= "hgpoar" then
						continue
					end
				end

				-- ????????? ??????? PrimaryPart, ????? ?? ???? ??????
				if not (otherPlayer.Character.PrimaryPart and character.PrimaryPart) then
					continue
				end

				local dist = (otherPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
				print(string.format("[DEBUG] ???????? %s — ?????????? %.1f", otherPlayer.Name, dist))

				-- ?????? ????? ???? ????????? ??? ??????????
				if dist <= 25 then
					print("? ???? ????????? ????? — ???????? ???????!")
					fasterHeal = true
					break
				end
			end
		end
	end

	local healDuration = fasterHeal and (HEAL_TIME / 2) or HEAL_TIME
	print(player.Name .. " ????? ?????????????????? (" .. healDuration .. " ???).")

	highlight.Enabled = true
	animchanger:FireClient(player, "StartHealing")
	controlevent:FireClient(player, "StartHealing")

	-- ?? ??????? ???????
	task.spawn(function()
		local startHealth = humanoid.Health
		local healRate = HEAL_AMOUNT / healDuration
		local startTime = tick()

		while tick() - startTime < healDuration and humanoid.Health > 0 do
			humanoid.Health = math.min(MAX_HEALTH, humanoid.Health + healRate * task.wait(0.1))
			highlight.FillTransparency = 0.2
			task.wait(0.2)
			highlight.FillTransparency = 0.6
		end

		humanoid.Health = math.min(humanoid.Health + (HEAL_AMOUNT - (humanoid.Health - startHealth)), MAX_HEALTH)
		print(player.Name .. " ???????? ??????????. +50 HP")

		highlight.Enabled = false
		animchanger:FireClient(player, "StopHealing")
		controlevent:FireClient(player, "StopHealing")

		playerCooldowns[player] = tick()

		task.delay(COOLDOWN, function()
			print(player.Name .. " ????? ? ?????? ???????????.")
		end)
	end)
end

-- ????????? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	if action == "speed_Tmug" then
		print("Yskorenie")
		morespeed:FireClient(player)
		for i = 1,10 do
			task.wait(1)
			character.Peregnev.Value = character.Peregnev.Value + 1.5
			if humanoid.Health > 10 then
				humanoid.Health = humanoid.Health - 2.5
			end
		end

	elseif action == "Energy_Shield_Tmug" then
		print(player.Name .. " ??????????? ?????????????? ???!")

		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp then return end

		-- === ????????? ???? ===
		local SHIELD_HEALTH = 70
		local SHIELD_DURATION = 5
		local originalSize = hrp.Size
		local active = true

		-- === ????????? ???????? ===
		if not character:FindFirstChild("TempShield") then
			local shieldValue = Instance.new("NumberValue")
			shieldValue.Name = "TempShield"
			shieldValue.Value = SHIELD_HEALTH
			shieldValue.Parent = character
		end
		local tempShield = character:FindFirstChild("TempShield")
		tempShield.Value = SHIELD_HEALTH

		-- === ?????????? ?????? ???? ===
		local highlight = character:FindFirstChild("ShieldHighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "ShieldHighlight"
			highlight.FillColor = Color3.fromRGB(0, 150, 255)
			highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
			highlight.FillTransparency = 0.6
			highlight.OutlineTransparency = 0
			highlight.Parent = character
		end
		highlight.Enabled = true

		-- === ??????????? ??????? ===
		local oldScale = character:FindFirstChild("BodyHeightScale")
		local humanoidScale = oldScale and oldScale.Value or 1
		if oldScale then
			oldScale.Value = humanoidScale * 1.2
		end

		-- === ???????????? ? ????? ===
		local connection
		connection = humanoid.HealthChanged:Connect(function(newHealth)
			if not active then return end
			if newHealth < humanoid.MaxHealth then
				local damageTaken = humanoid.MaxHealth - newHealth
				if tempShield.Value > 0 then
					local absorb = math.min(tempShield.Value, damageTaken)
					tempShield.Value -= absorb
					humanoid.Health += absorb -- ?????????? ??????????? ????
					print(player.Name .. " ??? ???????? " .. absorb .. " ?????. ???????? ????: " .. tempShield.Value)

					if tempShield.Value <= 0 then
						print(player.Name .. " ??? ?????????!")
						active = false
						highlight.FillColor = Color3.fromRGB(255, 100, 100)
					end
				end
			end
		end)

		-- === ?????? ????? ??? ????????? ===
		--playSound("rbxassetid://13808150047", hrp.Position, 2) -- ?????? ???????? ????

		-- === ????? 5 ?????? ??????? ??? ===
		task.delay(SHIELD_DURATION, function()
			if not character or not active then return end
			active = false
			print(player.Name .. " ??? ?????.")
			if connection then connection:Disconnect() end
			if highlight then highlight:Destroy() end
			if tempShield then tempShield:Destroy() end
			if oldScale then oldScale.Value = humanoidScale end
		end)
	elseif action == "DestructiveCharge" then
		print("Destructive Charge!")
		character.Peregnev.Value = character.Peregnev.Value + 38
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end

		-- === ???????? ?????? ===
		animchanger:FireClient(player, "DestructiveCharge_Start")
		stanevent:FireClient(player, 0.8)
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 1,
			speed = 0,
			priority = 100
		})
		task.wait(1)

		-- === ?????? ????? ===
		local chargeDuration = math.random(3,7)
		local chargeSpeed = 50
		local upwardBoost = 0.01
		stanevent:FireClient(player, chargeDuration)
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 1,
			speed = 0,
			priority = 100
		})

		animchanger:FireClient(player, "DestructiveCharge_Loop")

		-- ????????? ?????? ????? ????? ???????
		hrp.AssemblyLinearVelocity = Vector3.new(0, 60, 0)

		local lv = Instance.new("LinearVelocity")
		lv.MaxForce = 1e5
		lv.VectorVelocity = (hrp.CFrame.LookVector * chargeSpeed) + Vector3.new(0, upwardBoost, 0)
		lv.RelativeTo = Enum.ActuatorRelativeTo.World
		local att = Instance.new("Attachment")
		att.Parent = hrp
		lv.Attachment0 = att
		lv.Parent = hrp

		-- ???????
		local chargeActive = true
		local carryingEnemy = nil
		local grabWeld = nil
		local enemyPlayer, enemyHum, enemyHRP = nil, nil, nil

		-- ??????? ??????????/???????? ??? ???????
		local connections = {}

		local function SafeDestroy(obj)
			if obj and obj.Parent then
				obj:Destroy()
			end
		end

		local function ClearGrab()
			if grabWeld then
				SafeDestroy(grabWeld)
				grabWeld = nil
			end
			if carryingEnemy then
				carryingEnemy:SetAttribute("Grabbed", nil)
				carryingEnemy = nil
				enemyPlayer, enemyHum, enemyHRP = nil, nil, nil
			end
		end

		local function ClearAll()
			chargeActive = false
			for _, c in ipairs(connections) do
				if c and c.Disconnect then
					pcall(function() c:Disconnect() end)
				end
			end
			connections = {}

			SafeDestroy(lv)
			SafeDestroy(att)
			ClearGrab()
		end

		local diedConn = humanoid.Died:Connect(function()
			ClearAll()
		end)
		table.insert(connections, diedConn)

		-- === ???????? ? ???????? ????? ===
		local RunService = game:GetService("RunService")
		local moveConn = RunService.Heartbeat:Connect(function()
			if not chargeActive then return end

			-- ?????????? ??????? ???????? ??? ??????????? ????????
			local moveDir = humanoid.MoveDirection
			if moveDir.Magnitude > 0 then
				local target = (moveDir * chargeSpeed).Unit
				if lv and lv.Parent then
					lv.VectorVelocity = lv.VectorVelocity:Lerp(target * chargeSpeed, 0.08)
				end
			end

			-- --- ???????? ???????????? ?? ?????? ---
			local origin = hrp.Position
			local dir = hrp.CFrame.LookVector
			local rayParams = RaycastParams.new()

			-- ?????????? ??????????
			local ignoreList = {character, workspace:WaitForChild("Players")}
			rayParams.FilterDescendantsInstances = ignoreList
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			-- ??? ?????? 6–8 ??????
			local result = workspace:Raycast(origin, dir * 8, rayParams)

			if result and result.Instance and chargeActive then
				local hitPart = result.Instance
				local distance = (result.Position - origin).Magnitude

				-- ? ??????? “???????” ??????
				local isSolidWall =
					(hitPart.CanCollide and hitPart.Transparency < 0.7)
					and not hitPart:IsDescendantOf(workspace:WaitForChild("Players"))

				if not isSolidWall then
					return -- ?????????? ??????, ???? ? ?.?.
				end

				print(("?? ????????? ???????????? ?? ??????: %s ?? ?????????? %.1f"):format(hitPart.Name, distance))

				-- === ????????????? ????? ===
				chargeActive = false
				SafeDestroy(lv)
				SafeDestroy(att)

				-- ???? ????????
				humanoid:Move(Vector3.zero, false)

				if moveConn and moveConn.Connected then
					moveConn:Disconnect()
				end

				animchanger:FireClient(player, "DestructiveCharge_End")

				-- ?????? ? ?????????
				if carryingEnemy and enemyHum and enemyHRP and enemyHum.Health > 0 then
					print("? ???? ????? ?? ?????!")
					if grabWeld then grabWeld:Destroy() end
					enemyHRP.Anchored = true
					enemyHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
					task.delay(0.3, function()
						if enemyHRP then
							enemyHRP.Anchored = false
							enemyHRP.AssemblyLinearVelocity = hrp.CFrame.LookVector * -70 + Vector3.new(0, 25, 0)
						end
						ClearGrab()
					end)
				else
					print("?? ?????? ???????? ? ?????.")
				end
			end
		end)
		table.insert(connections, moveConn)

		-- === ?????? ?????? ===
		local hitCoroutine = coroutine.wrap(function()
			local localDuration = chargeDuration + 3
			stanevent:FireClient(player, localDuration)
			local steps = math.floor(localDuration / 0.2)

			for i = 1, steps do
				if not chargeActive then break end

				local hitbox = Instance.new("Part")
				hitbox.Size = Vector3.new(4, 7.5, 3)
				hitbox.Anchored = true
				hitbox.CanCollide = false
				hitbox.Transparency = 1
				hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
				hitbox.Parent = workspace
				game:GetService("Debris"):AddItem(hitbox, 0.05)

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				overlapParams.FilterDescendantsInstances = {character}

				local parts = workspace:GetPartsInPart(hitbox, overlapParams)
				for _, part in ipairs(parts) do
					local targetChar = part:FindFirstAncestorOfClass("Model")
					if targetChar and (killerFolder:FindFirstChild(targetChar.Name) or NeutralFolder:FindFirstChild(targetChar.Name)) then
						if not carryingEnemy and not targetChar:GetAttribute("Grabbed") then
							carryingEnemy = targetChar
							targetChar:SetAttribute("Grabbed", true)
							print("Executioner grabbed!")

							enemyHRP = carryingEnemy:FindFirstChild("HumanoidRootPart")
							enemyHum = carryingEnemy:FindFirstChildOfClass("Humanoid")
							enemyPlayer = Players:GetPlayerFromCharacter(carryingEnemy)

							if enemyHRP then
								grabWeld = Instance.new("WeldConstraint")
								grabWeld.Name = "GrabWeld"
								grabWeld.Part0 = hrp
								grabWeld.Part1 = enemyHRP
								grabWeld.Parent = hrp
								enemyHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
								enemyHRP.Anchored = false
							end

							if enemyHum then
								RunControlEvent:FireClient(enemyPlayer, {
									type = "Slowdown",
									duration = localDuration,
									speed = 0,
									priority = 99
								})
								stanevent:FireClient(enemyPlayer, localDuration)
								enemyHum:TakeDamage(74)
								stananimevent:FireClient(enemyPlayer, localDuration)
							end
						end
					end
				end
				task.wait(0.2)
			end
		end)
		hitCoroutine()

		task.delay(chargeDuration, function()
			if not chargeActive then return end
			chargeActive = false
			ClearAll()
			animchanger:FireClient(player, "DestructiveCharge_End")

			if carryingEnemy and enemyPlayer and enemyHum and enemyHum.Health > 0 then
				stanevent:FireClient(enemyPlayer, 3)
				stananimevent:FireClient(enemyPlayer, 3)
				RunControlEvent:FireClient(enemyPlayer, {
					type = "Slowdown",
					duration = 3,
					speed = 0,
					priority = 100
				})
			end
			ClearGrab()
		end)
	elseif action == "metal_heal" then
		startHealing(player)
	elseif action == "Ventelator_Tmug" then
		local ventav = 40
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 6,
			speed = 0,
			priority = 140
		})
		task.delay(6,function()
			while character.Peregnev.Value > 1 and ventav > 1 do
				character.Peregnev.Value = character.Peregnev.Value - 1
			end
		end)	
	end
end)


