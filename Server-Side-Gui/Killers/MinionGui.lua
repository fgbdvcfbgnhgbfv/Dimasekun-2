local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
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

					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					local effectblood = game.ReplicatedStorage.Effects.Blood:Clone()
					local torsonew = targetChar:FindFirstChild("Torso")
					playHitSound(character, "rbxassetid://102299249994473")
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

-- ?????????? ???????
event.OnServerEvent:Connect(function(player, action)
	if action ~= "Attack_Minion" then return end
	local character = player.Character
	if not character then return end

	createHitbox(character, 10, 0.5, 0.05)
end)
