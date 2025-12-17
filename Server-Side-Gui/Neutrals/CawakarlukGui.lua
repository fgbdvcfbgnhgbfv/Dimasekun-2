-- Server script (????????????)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- ????? ? ????????? (???????, ??? Workspace.Players ???????? ???????? Neutral, Killer, Survivors)
local playersFolder = Workspace:WaitForChild("Players")
local survivorsFolder = playersFolder:WaitForChild("Survivors")
local killerFolder = playersFolder:WaitForChild("Killer")
local neutralFolder = playersFolder:WaitForChild("Neutral")

-- ???????
local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Neutral"):WaitForChild("NeutralEvent")
local teamsevent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Neutral"):WaitForChild("Cawakarlukevents"):WaitForChild("Teamsevent")

-- ????????, ??? ???? ????? ??? ?????????
local hitboxesFolder = Workspace:FindFirstChild("Hitboxes")
if not hitboxesFolder then
	hitboxesFolder = Instance.new("Folder")
	hitboxesFolder.Name = "Hitboxes"
	hitboxesFolder.Parent = Workspace
end

local function createHitbox(character, damage, duration, interval, team)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local alreadyHit = {}
	local steps = math.max(1, math.floor(duration / interval))

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	-- ????????? ?????????? ????????? ????? ?? ???? ????
	overlapParams.FilterDescendantsInstances = { character }

	for i = 1, steps do
		task.delay(interval * (i - 1), function()
			-- ??????? ???????
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(4, 7.5, 3)
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Color = Color3.new(1, 0.28, 0.05)
			hitbox.Transparency = 0.55
			hitbox.Name = "Hitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = hitboxesFolder

			-- ???????? ?????????????? ??????
			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if not targetChar then continue end
				if alreadyHit[targetChar] then continue end

				-- ????? ?????? ?? ???????
				local valid = false
				if team == "neutral" then
					valid = targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(killerFolder)
				elseif team == "killer" then
					valid = targetChar:IsDescendantOf(neutralFolder) or targetChar:IsDescendantOf(survivorsFolder)
				elseif team == "survivors" then
					valid = targetChar:IsDescendantOf(neutralFolder) or targetChar:IsDescendantOf(killerFolder)
				end

				if valid then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					-- ?????? ????? (??????, ??? Torso ????? ????????????? ?? R15)
					local effectSource = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
					if effectSource and ReplicatedStorage:FindFirstChild("Effects") and ReplicatedStorage.Effects:FindFirstChild("Blood") then
						local effectblood = ReplicatedStorage.Effects.Blood:Clone()
						effectblood.Parent = effectSource
						if character.Humanoid.Health == character.Humanoid.MaxHealth then
							character.Humanoid.MaxHealth = character.Humanoid.MaxHealth + 17
							character.Humanoid.Health = math.clamp(character.Humanoid.Health + 17, 0, character.Humanoid.MaxHealth)
						else
							character.Humanoid.Health = math.clamp(character.Humanoid.Health + 17, 0, character.Humanoid.MaxHealth)
						end
						task.delay(0.6, function()
							if effectblood and effectblood.Parent then
								effectblood:Destroy()
							end
						end)
					end

					if targetHumanoid and targetHumanoid.Health > 0 then
						targetHumanoid:TakeDamage(damage)
						alreadyHit[targetChar] = true
						-- ????? ????????? ???????/??? ??? ?????????
						-- print(("Hit %s for %d"):format(targetChar.Name, damage))
					end
				end
			end

			-- ?????????? ???????
			task.delay(0.05, function()
				if hitbox and hitbox.Parent then
					hitbox:Destroy()
				end
			end)
		end)
	end
end

local function isValidTeam(character, team)
	if not character then return false end
	if team == "neutral" then
		return character:IsDescendantOf(neutralFolder)
	elseif team == "killer" then
		return character:IsDescendantOf(killerFolder)
	elseif team == "survivors" then
		return character:IsDescendantOf(survivorsFolder)
	end
	return false
end

-- ????????? ??????? ?? ???????
event.OnServerEvent:Connect(function(player, action, team)
	local character = player.Character
	if not character or not action then return end

	-- ?????????, ??? ????? — ??????? (???? ???????? ?????????? ?? ????????)
	local validTeam = (
		(team == "neutral" and character:IsDescendantOf(neutralFolder)) or
			(team == "killer" and character:IsDescendantOf(killerFolder)) or
			(team == "survivors" and character:IsDescendantOf(survivorsFolder))
	)

	if not validTeam and action ~= "teamsnap" then
		warn("[NeutralEvent] ????? "..player.Name.." ????????? ???????????? "..tostring(action).." ?? ?? ???????? ?????? ??????? "..tostring(team)..".")
		return
	end

	if action == "neutral" then
		createHitbox(character, 25, 0.5, 0.05, "neutral")
	elseif action == "killer" then
		createHitbox(character, 25, 0.5, 0.05, "killer")
	elseif action == "survivors" then
		createHitbox(character, 25, 0.5, 0.05, "survivors")
	elseif action == "teamsnap" then
		-- ???????? ?????? ???????? ????????? ?? ?????? ???????
		local rand = math.random(1,2)
		if rand == 1 then
			-- ?????? ?????? ????????
			character.Parent = killerFolder
			-- ????????? ???????? ??? ?? ????? ???? (????????? ????????? ?????)
			local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("LeftHand")
			local knifePart = leftArm and leftArm:FindFirstChild("Knife")
			if knifePart then knifePart.Transparency = 0 end

			teamsevent:FireClient(player, "killer")
			task.delay(25, function()
				teamsevent:FireClient(player, "neutral")
				if knifePart then knifePart.Transparency = 1 end
				character.Parent = neutralFolder
			end)
		else
			-- ?????? ?????? ????????
			character.Parent = survivorsFolder
			teamsevent:FireClient(player, "survivors")
			task.delay(25, function()
				character.Parent = neutralFolder
				teamsevent:FireClient(player, "neutral")
			end)
		end
	end
end)
