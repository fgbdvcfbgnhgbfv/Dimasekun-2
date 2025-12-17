local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local KillerFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local event = ReplicatedStorage.Events.Neutral.NeutralEvent
local edaevent = ReplicatedStorage.Events.Neutral.DenisEvents.EatPeoplsEvent
local RunControlEvent = game.ReplicatedStorage.Events.RunControlEvent
local KillerAnimId = "rbxassetid://94121830189737" -- ???????? ? ??????
local VictimAnimId = "rbxassetid://121684188900998" -- ???????? ? ??????

-- ?? ???????? ????????
local function createHitbox(character, damage, duration, interval)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local player = Players:GetPlayerFromCharacter(character)
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
			hitbox.Name = "Hitbox"
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar 
					and not alreadyHit[targetChar] 
					and (targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(KillerFolder)) then

					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 and not targetHumanoid:GetAttribute("IsBeingEaten") then
						local targetplayer = Players:GetPlayerFromCharacter(targetChar)
						alreadyHit[targetChar] = true
						targetHumanoid:SetAttribute("IsBeingEaten", true)

						-- ?? ???????? ? ??????
						RunControlEvent:FireClient(targetplayer, {
							type = "Slowdown",
							duration = 2,
							speed = 0,
							priority = 200
						})
						local victimAnimator = targetHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", targetHumanoid)
						local victimAnim = Instance.new("Animation")
						victimAnim.AnimationId = VictimAnimId
						local victimTrack = victimAnimator:LoadAnimation(victimAnim)
						victimTrack:Play()

						-- ?? ???????? ? ??????
						RunControlEvent:FireClient(player, {
							type = "Slowdown",
							duration = 2,
							speed = 0,
							priority = 200
						})
						local killerHumanoid = character:FindFirstChildOfClass("Humanoid")
						if killerHumanoid then
							local killerAnimator = killerHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", killerHumanoid)
							local killerAnim = Instance.new("Animation")
							killerAnim.AnimationId = KillerAnimId
							local killerTrack = killerAnimator:LoadAnimation(killerAnim)
							killerTrack:Play()
						end

						-- ?? ?????????? ??????
						local root = targetChar:FindFirstChild("HumanoidRootPart")
						if root then root.Anchored = true end
						targetHumanoid.WalkSpeed = 0

						-- ? ????? ????????? ???????? ?????? ???????
						local animDuration = victimTrack.Length > 0 and victimTrack.Length or 2.5
						task.delay(animDuration, function()
							if targetHumanoid and targetHumanoid.Health > 0 then
								targetHumanoid.Health = math.max(targetHumanoid.Health - 100, 0)
							end
							if root then root.Anchored = false end
							targetHumanoid:SetAttribute("IsBeingEaten", false)

							-- ?? ????? ??????
							if killerHumanoid then
								killerHumanoid.MaxHealth += 20
								killerHumanoid.Health = math.clamp(killerHumanoid.Health + 20, 0, killerHumanoid.MaxHealth)
							end

							if character:FindFirstChild("Pyso") then
								local Pyso = character.Pyso
								if Pyso.Transparency == 1 then
									Pyso.Transparency = 0
									Pyso.Massless = false
								else
									Pyso.Size += Vector3.new(0, 0.1, 0.1)
								end
							end

							edaevent:FireClient(player)
						end)
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

-- ?? ?????????? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	if action == "Devour" then 
		createHitbox(character, 100, 0.5, 0.05)

	elseif action == "potato_denis" then 
		character.Potato.Transparency = 0
		character.Potato.Union.Transparency = 0
		task.delay(0.77,function()
			character.Humanoid.Health = math.min(character.Humanoid.Health + 1, character.Humanoid.MaxHealth)
			character.Potato.Union.Transparency = 1
		end)
		task.delay(1.6,function()
			character.Potato.Transparency = 1
		end)

	elseif action == "burger_denis" then 
		character.Burger.Transparency = 0
		task.delay(0.77,function()
			character.Humanoid.Health = math.min(character.Humanoid.Health + 50, character.Humanoid.MaxHealth)
			character.Burger.Transparency = 1
		end)
	end
end)
