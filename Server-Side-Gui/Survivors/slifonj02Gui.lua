local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local stanevent = ReplicatedStorage.Events.StanEvent
local RunControlEvent = ReplicatedStorage.Events.RunControlEvent
local event = ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
-- ?????
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local neutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")

local function safeHealHumanoid(targetHumanoid, amount)
	if not targetHumanoid or amount <= 0 then return end
	targetHumanoid.Health = math.clamp(targetHumanoid.Health + amount, 0, targetHumanoid.MaxHealth)
end

-- ?? ?????????? ??????? ?? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if action == "Healing_slifonj02" then
		
		local alreadyHit = {}
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { character }

		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(6.182, 6.535, 5.607)
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
			if not targetChar then continue end
			print("HEAL")
			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			if not targetPlayer then continue end

			if not alreadyHit[targetPlayer.UserId] and targetChar:IsDescendantOf(survivorsFolder) then
				local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
				if targetHumanoid and targetHumanoid.Health > 0 then
					local hasVar1 = targetPlayer:FindFirstChild("tmugrobot") or targetChar:FindFirstChild("tmugrobot")
					if not hasVar1 then
						local effecthealing = game.ReplicatedStorage.Effects.Healinf["Main-01"]:Clone()
						local Highlight = game.ReplicatedStorage.Effects.Healinf.Highlight:Clone()
						local arrow = game.ReplicatedStorage.Effects.Healinf.Arrow:Clone()
						-- ???????? ?????, ????? ???????? ?????????? ???? ? ???? ?????
						effecthealing.Parent = targetChar.Torso
						Highlight.Parent = targetChar
						arrow.Parent = targetChar.Torso
						alreadyHit[targetPlayer.UserId] = true
						local healing = 0
						while healing <= 41 do
							task.wait(0.5)
							print("HEAL2")
							safeHealHumanoid(targetHumanoid, 10)
							healing += 10
							if healing >= 41 then
								effecthealing:Destroy()
								Highlight:Destroy()
								arrow:Destroy()
							end
						end
					end
				end
			end
		end

		task.delay(1.2, function()
			if hitbox and hitbox.Parent then hitbox:Destroy() end
		end)
	elseif action == "MedCit_slifonj02" then
		local effecthealing = game.ReplicatedStorage.Effects.Healinf["Main-01"]:Clone()
		local Highlight = game.ReplicatedStorage.Effects.Healinf.Highlight:Clone()
		local arrow = game.ReplicatedStorage.Effects.Healinf.Arrow:Clone()
		
		effecthealing.Parent = character.Torso
		Highlight.Parent = character
		arrow.Parent = character.Torso
		slowwalkevent:FireClient(player, 8, 12, true, 7, false)
		task.delay(7,function()
			character.Humanoid.Health = math.clamp(character.Humanoid.Health + 15, 0, character.Humanoid.MaxHealth)
			effecthealing:Destroy()
			Highlight:Destroy()
			arrow:Destroy()
		end)
	end
end)
