local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local morespeed = ReplicatedStorage.Events:WaitForChild("MoreSpeed")
local IncreaseStaminaEvent = ReplicatedStorage.Events:WaitForChild("IncreaseStaminaEvent")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
-- ????? ??? ?????????
local hitboxFolder = workspace:FindFirstChild("AttackHitboxes") or Instance.new("Folder")
hitboxFolder.Name = "AttackHitboxes"
hitboxFolder.Parent = workspace

-- ????????
local playerCooldowns = { MorePig = {} }

-- =======================
-- ????? ??????? ????????
local function createHitbox(character, damage, duration, interval)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local globalAlreadyHit = {}
	local steps = math.floor(duration / interval)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(4, 7.542, 2.893)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Transparency = 0.55
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Name = "AttackHitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = hitboxFolder

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(survivorsFolder) or targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(NeutralFolder) then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
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
					
					if targetHumanoid and targetHumanoid.Health > 0 then
						targetHumanoid:TakeDamage(damage)
						globalAlreadyHit[targetChar] = true
						print("? ???? ???????:", targetChar.Name)

						-- ?????????? ????
						local playerHit = Players:GetPlayerFromCharacter(targetChar)
						if playerHit then
							slowwalkevent:FireClient(playerHit,12,18,true,1.5,false)
						end
					end
				end
			end
			hitbox:Destroy()
		end)
	end
end


-- =======================
-- ???????? ??????????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	if action == "Attack_Pig" then
		createHitbox(character, 47, 0.5, 0.1)
		return
	end

	if action == "Glaza_Pig" then
		character.pig.glaza.Transparency = 0
		task.delay(4, function()
			character.pig.glaza.Transparency = 1
		end)
		return
	end

	if action == "MorePig" then
		local now = tick()
		if playerCooldowns.MorePig[player.UserId] and now < playerCooldowns.MorePig[player.UserId] then
			return
		end
		playerCooldowns.MorePig[player.UserId] = now + 1

		local summonAnimation = Instance.new("Animation")
		summonAnimation.AnimationId = "rbxassetid://95313734977770"
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		animator:LoadAnimation(summonAnimation):Play()

		local polongModel = ReplicatedStorage.KillersParts.Pig.PigMinuon
		local polongAnimId = "rbxassetid://89202376321752"
		local offsets = {
			Vector3.new(-3, -2.8, -2),
			Vector3.new(3, -2.8, -2),
			Vector3.new(-6, -2.8, -2),
			Vector3.new(6, -2.8, -2),
			Vector3.new(-9, -2.8, -2),
			Vector3.new(9, -2.8, -2),
		}

		for i, v in ipairs(offsets) do
			local polong = polongModel:Clone()
			polong.Parent = workspace
			if polong.PrimaryPart then
				polong:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(v))
			end

			local polongHumanoid = polong:FindFirstChildOfClass("Humanoid")
			if polongHumanoid then
				local polongAnimator = polongHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", polongHumanoid)
				local polongAnim = Instance.new("Animation")
				polongAnim.AnimationId = polongAnimId
				polongAnimator:LoadAnimation(polongAnim):Play()
			end
		end
		return
	end

	if action == "NaNogi_Pig" then
		morespeed:FireClient(player)
		IncreaseStaminaEvent:FireClient(player)
		character.pig.Transparency = 1
		character.pig.pixtwo.Transparency = 0
		task.delay(20,function()
			character.pig.Transparency = 0
			character.pig.pixtwo.Transparency = 1
		end)
		return
	end

	if action == "Xodud_Pig" then
		createHitbox(character, 47, 2, 0.02)
		return
	end
end)

