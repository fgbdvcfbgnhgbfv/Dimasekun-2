local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
-- ???????? ? ?????????? ??? ???? ????????
local lastUse = {} -- ??? Podarok
local podarokCooldown = 1
local usedPolong = false -- ??? Polong
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local Debris = game:GetService("Debris")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent

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

local function changeRig(player, morphPath)
	-- morphPath — ??? ??????, ???????? "Morphs.Survivors.Sergay"

	-- ???????? ?????? ?? ????
	local pathParts = string.split(morphPath, ".")
	local current = ReplicatedStorage
	for _, partName in ipairs(pathParts) do
		current = current:FindFirstChild(partName)
		if not current then
			warn("? ?? ?????? ???? ?? ????:", morphPath)
			return
		end
	end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		warn("? ? ?????? ??? ??????????? ?????????:", player.Name)
		return
	end

	-- ????????? ? ?????? ?????????
	local newChar = current:Clone()
	local pos = player.Character.HumanoidRootPart.CFrame
	local oldName = player.Name

	newChar.Name = oldName
	player.Character:Destroy()
	player.Character = newChar
	newChar.Parent = workspace.Players.Killer
	newChar.HumanoidRootPart.CFrame = pos

	print("? ??? ??????", player.Name, "??????? ??", morphPath)
end
-- =======================
-- ????? ??????? ???????? ???????? ?????
local function createHitbox(character, damage, duration, interval)
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
			hitbox.Size = Vector3.new(4, 7.5, 3)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Transparency = 0.55
			hitbox.Name = "AttackHitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = workspace:FindFirstChild("AttackHitboxes") or workspace

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

						RunControlEvent:FireClient(player, { type = "Slowdown", duration = 0, speed = 16, priority = 101 })
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
						
						if targetPlayer then
                        slowwalkevent:FireClient(targetPlayer,12,18,true,5,false)
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

local function createAttackHitbox(character, damage, duration, interval)
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
			hitbox.Size = Vector3.new(4, 7.5, 3)
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
				if targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(survivorsFolder) or targetChar and not globalAlreadyHit[targetChar] and targetChar:IsDescendantOf(NeutralFolder) then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 then
						local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
						if targetPlayer then
							playHitSound(character, "rbxassetid://102299249994473")
							local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()
							local torsonew = targetChar:FindFirstChild("Torso")
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
							targetHumanoid.Died:Once(function()
								local hasVar1 = targetPlayer:FindFirstChild("fghgfhggfu") 
									or targetChar:FindFirstChild("fghgfhggfu")
								local hasVar2 = targetPlayer:FindFirstChild("Sergay") 
									or targetChar:FindFirstChild("Sergay")
								local hasVar3 = targetPlayer:FindFirstChild("hgpoar")
									or targetChar:FindFirstChild("hgpoar")
								local hasVar4 = targetPlayer:FindFirstChild("Denis")
									or targetChar:FindFirstChild("Denis")
								local hasVar5 = targetPlayer:FindFirstChild("fofdodnon")
									or targetChar:FindFirstChild("fofdodnon")
								local hasVar6 = targetPlayer:FindFirstChild("Cawakarluk")
									or targetChar:FindFirstChild("Cawakarluk")
								local hasVar7 = targetPlayer:FindFirstChild("zZGigazSigmaZz")
									or targetChar:FindFirstChild("zZGigazSigmaZz")
								local hasVar8 = targetChar:FindFirstChild("slifonj02")
								local hasVar9 = targetChar:FindFirstChild("LOPKL2011")
								local hasVar10 = targetChar:FindFirstChild("hukia_babra")

								if hasVar1 then
									changeRig(targetPlayer, "Morphs.Killers.fghgfhggfuMinion")
								elseif hasVar2 then
									changeRig(targetPlayer, "Morphs.Killers.SergayMinion")
								elseif hasVar3 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.hgpoarMinion")
								elseif hasVar4 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.DenisMinion")
								elseif hasVar5 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.fofdodnonMinion")
								elseif hasVar6 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.CawakarlukMinion")
								elseif hasVar7 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.zZGigazSigmaZzMinion")
								elseif hasVar8 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.slifonj02Minion")
								elseif hasVar9 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.LOPKL2011Minion")
								elseif hasVar10 then
									changeRig(targetPlayer, "Morphs.SpecialKillers.hukia_babraMinion")
								end
							end)
						end
						targetHumanoid:TakeDamage(damage)
						globalAlreadyHit[targetChar] = true
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

-- =======================
-- ???????? ??????????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	-- ========== TELEFONER ==========
	if action == "Telefoner" then
		-- ?????????? ???????
		local phone = character:FindFirstChild("Right Arm") and character["Right Arm"]:FindFirstChild("telefon")
		if phone then
			if phone:FindFirstChild("Union") then phone.Union.Transparency = 0 end
			if phone:FindFirstChild("Part") then phone.Part.Transparency = 0 end
		end
		playHitSound(character, "rbxassetid://131021205064935")
		local spotlightEffect = phone:FindFirstChild("SpotLightEffect")
		if spotlightEffect then
			for _, beam in ipairs(spotlightEffect:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
					if beam:FindFirstChild("Attachment0") then
						beam.Attachment0.Enabled = true 
					end
				end
			end
		end

		RunControlEvent:FireClient(player, { type = "Slowdown", duration = 2, speed = 10, priority = 100 })
		createHitbox(character, 20, 2, 0.05)

		task.delay(2, function()
			if phone then
				if phone:FindFirstChild("Union") then phone.Union.Transparency = 1 end
				if phone:FindFirstChild("Part") then phone.Part.Transparency = 1 end
				local spotlightEffect = phone:FindFirstChild("SpotLightEffect")
				local spotlightEffect = phone:FindFirstChild("SpotLightEffect")
				if spotlightEffect then
					for _, beam in ipairs(spotlightEffect:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Enabled = false
							if beam:FindFirstChild("Attachment0") then
								beam.Attachment0.Enabled = false
							end
						end
					end
				end
			end
		end)
		return
	end
	
	if action == "Vision" then
		slowwalkevent:FireClient(player, 8, 16, true, 5, false)
	end
	-- ========== ?????????? ==========
	if action == "rosovinkoe_Cvatoc" then
		local generating = true -- ????, ???? ????? ????????????

		-- ??????? ???????? ?????????? ????????
		local function checkKillers()
			local killers = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killer")
			if killers and #killers:GetChildren() == 0 then
				-- ???? ???????? ??? – ????????????? ????????? ? ??????? ??? ??????????
				generating = false
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj.Name == "Rosovinkoe" then
						obj:Destroy()
					end
				end
			end
		end

		-- ????????? ???????? ?????? ???? ??????
		task.spawn(function()
			while true do
				checkKillers()
				task.wait(2)
			end
		end)

		local function spawnRosovinkoe(position)
			if not generating then return nil end -- ????????? ????????

			local part = Instance.new("Part")
			part.Size = Vector3.new(14, 1, 14)
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 105, 180)
			part.Position = position
			part.Name = "Rosovinkoe"
			part.Material = Enum.Material.Granite
			part.Parent = workspace:FindFirstChild("trash") or workspace

			-- ??????????? ??????? ?? ?????
			local touchingPlayers = {}

			part.Touched:Connect(function(hit)
				local char = hit.Parent
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local plr = game.Players:GetPlayerFromCharacter(char)
				if hum and plr and char:IsDescendantOf(workspace.Players.Survivors) or hum and plr and char:IsDescendantOf(workspace.Players.Neutral) then
					slowwalkevent:FireClient(plr,12,14,false,0,false)
				end
			end)

			part.TouchEnded:Connect(function(hit)
				local plr = game.Players:GetPlayerFromCharacter(hit.Parent)
				if plr then
					slowwalkevent:FireClient(plr,12,14,false,0,true)
				end
			end)

			return part
		end

		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local startPart = spawnRosovinkoe(Vector3.new(
			math.floor(hrp.Position.X / 14 + 0.5) * 14,
			hrp.Position.Y - 3,
			math.floor(hrp.Position.Z / 14 + 0.5) * 14
			))

		task.spawn(function()
			local lastPart = startPart
			while generating and lastPart and lastPart.Parent do
				task.wait(7)

				if not generating then break end -- ?????? ???? ???? ???????? ???

				local dirs = {
					Vector3.new(14, 0, 0),
					Vector3.new(-14, 0, 0),
					Vector3.new(0, 0, 14),
					Vector3.new(0, 0, -14),
				}
				local offset = dirs[math.random(1, #dirs)]
				local newPart = spawnRosovinkoe(lastPart.Position + offset)
				lastPart = newPart
				if newPart then
					newPart.Parent = workspace.trash
				end
			end
		end)
	end

	-- ========== POLONG ==========
	if action == "Polong" then
		if usedPolong then return end -- ?????? ?? ?????
		usedPolong = true
		task.delay(1, function() usedPolong = false end)

		RunControlEvent:FireClient(player, { type = "Slowdown", duration = 2.5, speed = 0, 	priority = 100 })

		local summonAnimation = Instance.new("Animation")
		summonAnimation.AnimationId = "rbxassetid://117645032581261"
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		local summonTrack = animator:LoadAnimation(summonAnimation)
		summonTrack:Play()

		local polongModel = ReplicatedStorage.KillersParts.Cvatoc:FindFirstChild("Polohng")
		local polongAnimId = "rbxassetid://89202376321752"
		local offsetDistance = 3

		local function spawnPolong(offset)
			local polong = polongModel:Clone()
			polong.Parent = workspace
			if polong.PrimaryPart then
				polong:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(offset, -2.8, -2))
			else
				warn("? ? Polong ??????????? PrimaryPart!")
			end

			local polongHumanoid = polong:FindFirstChildOfClass("Humanoid")
			if polongHumanoid then
				local polongAnimator = polongHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", polongHumanoid)
				local polongAnim = Instance.new("Animation")
				polongAnim.AnimationId = polongAnimId
				polongAnimator:LoadAnimation(polongAnim):Play()
			else
				warn("? ? Polong ??? Humanoid!")
			end
		end
		task.delay(2.25,function()
		spawnPolong(-offsetDistance)
		end)
		task.delay(2.5, function()
		spawnPolong(offsetDistance)
		end)
		return
	end

	-- ========== ATTACK ==========
	if action == "Attack" then
		createAttackHitbox(character, 30, 0.5, 0.05)
		return
	end

	-- ========== PODAROK ==========
	if action == "Podarok" then
		local now = tick()
		local userId = player.UserId
		if lastUse[userId] and now - lastUse[userId] < podarokCooldown then
			warn("? ?????", player.Name, "???????? ?????????? ??????? ??????? ??????")
			return
		end
		lastUse[userId] = now

		local giftFolder = ReplicatedStorage:FindFirstChild("KillersParts")
		if not giftFolder then
			warn("? ????? KillersParts ?? ??????? ? ReplicatedStorage!")
			return
		end

		local podarok = giftFolder.Cvatoc:FindFirstChild("podarok")
		if not podarok then
			warn("? Podarok ?? ?????? ? KillersParts!")
			return
		end

		local clonedGift = podarok:Clone()
		clonedGift.Parent = workspace
		clonedGift.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0)
		return
	end
end)
