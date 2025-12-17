local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local cherep = game.ReplicatedStorage.KillersParts.ZloiSergayOpasno.Cherep
local alreadyConnected = {} 
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local ryku = game.ReplicatedStorage.KillersParts.ZloiSergayOpasno.Colco
-- ???????? ???????? ?????
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
			hitbox.Size = Vector3.new(15.786, 30.798, 3)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Transparency = 0.55
			hitbox.Name = "Hitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar 
					and not alreadyHit[targetChar] 
					and (targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(NeutralFolder)) then
					local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					local torso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("HumanoidRootPart")
					local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()

					if torso then
						effectblood.Parent = torso
						task.delay(0.6,function()
							effectblood:Destroy()
						end)
					end

					if targetHumanoid and targetHumanoid.Health > 0 then
						targetHumanoid:TakeDamage(damage)
						alreadyHit[targetChar] = true
						if targetPlayer then
							slowwalkevent:FireClient(targetPlayer,12,18,true,0.5,false)
						end
						-- ? ????????? ??????????? ?
						if torso then
							local knockbackForce = Instance.new("BodyVelocity")
							knockbackForce.MaxForce = Vector3.new(100000, 100000, 100000)
							knockbackForce.Velocity = hrp.CFrame.LookVector * 60 + Vector3.new(0, 20, 0) -- ???? ?????
							knockbackForce.P = 1250
							knockbackForce.Parent = torso
							game.Debris:AddItem(knockbackForce, 0.25) -- ??????? ????? 0.25 ???
						end

						-- ?????????? Died
						if not alreadyConnected[targetHumanoid] then
							alreadyConnected[targetHumanoid] = true
							targetHumanoid.Died:Connect(function()
								local cherepnew = cherep:Clone()
								cherepnew.Parent = workspace
								cherepnew:MoveTo((torso and torso.Position) or Vector3.new(0, 5, 0))
							end)
						end
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

local function createHitboxGlaza(character, damage, duration, interval)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local player = Players:GetPlayerFromCharacter(character)

	local globalAlreadyHit = {}
	local steps = math.floor(duration / interval)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(15.786, 30.798, 96.694)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Transparency = 1
			hitbox.Name = "AttackHitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = workspace:FindFirstChild("AttackHitboxes") or workspace
			character.Glaza.Transparency = 0
			task.delay(duration,function()
				character.Glaza.Transparency = 1
			end)
			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(survivorsFolder) or targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(NeutralFolder) then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 then
						-- ? ??????? ????
						targetHumanoid:TakeDamage(damage)

						-- ? ???? ?????? ? ???????? ???
						local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
						
						local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()
						local torsonew = targetChar:FindFirstChild("Torso")
						if torsonew then
							effectblood.Parent = torsonew
							task.delay(0.6,function()
								effectblood:Destroy()
							end)
						end

						if targetPlayer then
							slowwalkevent:FireClient(targetPlayer,5,12,true,3,false)
						end

						globalAlreadyHit[targetChar] = true
						print("? ???? ? ????:", targetChar.Name)
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

-- ?????????? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	if action == "Attack_ZloiSergayOpasno" then 
		createHitbox(character, 37, 0.5, 0.05)	
	elseif action == "Glaza_ZloiSergayOpasno" then
		createHitboxGlaza(character, 20, 3, 0.05)
	elseif action == "Plaz_ZloiSergayOpasno" then
		local Player = Players:GetPlayerFromCharacter(character)
		slowwalkevent:FireClient(Player,30,70,true,12,false)
		setCharacterVisibility(character, false)
		task.delay(12,function()
			setCharacterVisibility(character, true)
			character.Glaza.Transparency = 1
			character.HumanoidRootPart.Transparency = 1
			character.Torso.Transparency = 1
		end)
	elseif action == "ryku_ZloiSergayOpasno" then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- ??? ????, ????? ????? ????? ??? ??????????
		local rayOrigin = hrp.Position
		local rayDirection = Vector3.new(0, -50, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		local spawnPosition
		if raycastResult then
			spawnPosition = raycastResult.Position + Vector3.new(0, 2, 0) -- ?? ???? ???? ????? (~2 ??????)
		else
			spawnPosition = hrp.Position - Vector3.new(0, 1, 0) -- ???????? ???????
		end

		-- ????????? ??????
		local rykuClone = ryku:Clone()
		rykuClone.Name = "ColcoEffect"
		rykuClone.Parent = workspace

		-- ????????? ? ????????? ???????
		if rykuClone:IsA("Model") then
			if rykuClone.PrimaryPart then
				rykuClone:SetPrimaryPartCFrame(CFrame.new(spawnPosition))
			else
				rykuClone:MoveTo(spawnPosition)
			end
		elseif rykuClone:IsA("BasePart") then
			rykuClone.CFrame = CFrame.new(spawnPosition)
		end

		-- ??????? ????? 20 ??????
		game.Debris:AddItem(rykuClone, 7)

		print("?? ?????? (Colco) ?????????? ???? ???? ????? ? ?????????:", character.Name)
	end
end)
