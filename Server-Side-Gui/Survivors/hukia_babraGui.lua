local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local stanevent = ReplicatedStorage.Events.StanEvent
local RunControlEvent = ReplicatedStorage.Events.RunControlEvent
local event = ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent 
local Toilet = game.ReplicatedStorage.SurvivorsParts.hukia_babra["shrek toilet"]
-- ?????
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local neutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")

-- ?? ?????????? ??????? ?? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if action == "Podliwka_hukia_babra" then
		local alreadyHit = {}
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { character }

		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(12.37, 19.717, 15.191)
		hitbox.Anchored = true
		hitbox.CanCollide = false
		hitbox.Color = Color3.new(0, 1, 0)
		hitbox.Transparency = 1
		hitbox.Name = "GasPuddle"
		hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
		hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace
		
		local hitbox2 = Instance.new("Part")
		hitbox2.Size = Vector3.new(12.37, 4.717, 15.191)
		hitbox2.Anchored = true
		hitbox2.CanCollide = false
		hitbox2.Color = Color3.new(0, 1, 0)
		hitbox2.Transparency = 0.68
		hitbox2.Name = "GasPuddle"
		hitbox2.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
		hitbox2.Parent = workspace:FindFirstChild("Hitboxes") or workspace

		-- ????????? ??????? ??????
		local particle = Instance.new("ParticleEmitter")
		particle.Texture = "rbxassetid://241837157"
		particle.Color = ColorSequence.new(Color3.new(0, 1, 0))
		particle.Size = NumberSequence.new(2)
		particle.Rate = 20
		particle.Lifetime = NumberRange.new(1, 2)
		particle.Parent = hitbox

		-- ??????? ??? ???????????? ??????? ? ????
		local playersInPuddle = {}
		local lastHealTime = {}
		local lastDamageTime = {}

		-- ??????? ??????? ????????
		local function healSurvivors()
			local currentTime = tick()
			for targetPlayer, _ in pairs(playersInPuddle) do
				local targetChar = targetPlayer.Character
				if targetChar and targetChar:IsDescendantOf(workspace) then
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 then
						-- ????? ???????? ? ???????????
						if targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(neutralFolder) then
							if not lastHealTime[targetPlayer] or (currentTime - lastHealTime[targetPlayer]) >= 1 then
								targetHumanoid.Health = math.min(targetHumanoid.Health + 2, targetHumanoid.MaxHealth)
								lastHealTime[targetPlayer] = currentTime
							end
						end

						-- ??????? ???? ???????
						if targetChar:IsDescendantOf(killersFolder) then
							if not lastDamageTime[targetPlayer] or (currentTime - lastDamageTime[targetPlayer]) >= 1 then
								targetHumanoid:TakeDamage(10)
								lastDamageTime[targetPlayer] = currentTime
							end
						end
					end
				end
			end
		end

		-- ????????? ????? ? ????
		hitbox.Touched:Connect(function(part)
			local targetChar = part:FindFirstAncestorOfClass("Model")
			if not targetChar then return end

			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			if not targetPlayer then return end

			-- ?????????? ???????
			if targetPlayer == player then return end

			local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
			if not targetHumanoid or targetHumanoid.Health <= 0 then return end

			-- ?????? - ????????? ??? ?????
			if targetChar:IsDescendantOf(killersFolder) then
				if not playersInPuddle[targetPlayer] then
					playersInPuddle[targetPlayer] = true
					slowwalkevent:FireClient(
						targetPlayer,
						7, -- ???????? ??????
						10, -- ???????? ????
						false, -- ???????????? ?? ???? ???
						2, -- ????????????
						false -- ?????????? ??? ??? false ??? true ??
					)
					print("?????? ????? ? ????: ??????????")
				end
			end
			
			if targetChar:IsDescendantOf(neutralFolder) then
				if not playersInPuddle[targetPlayer] then
					playersInPuddle[targetPlayer] = true
					slowwalkevent:FireClient(
						targetPlayer,
						7, -- ???????? ??????
						10, -- ???????? ????
						false, -- ???????????? ?? ???? ???
						2, -- ????????????
						false -- ?????????? ??? ??? false ??? true ??
					)
					print("?????? ????? ? ????: ??????????")
				end
			end

			-- ???????? ? ??????????? - ????????? ? ?????? ??? ???????
			if targetChar:IsDescendantOf(survivorsFolder) or targetChar:IsDescendantOf(neutralFolder) then
				if not playersInPuddle[targetPlayer] then
					playersInPuddle[targetPlayer] = true
					print("???????? ????? ? ????: ???????")
				end
			end
		end)

		-- ????????? ?????? ?? ????
		hitbox.TouchEnded:Connect(function(part)
			local targetChar = part:FindFirstAncestorOfClass("Model")
			if not targetChar then return end

			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			if not targetPlayer then return end

			-- ??????? ?? ?????? ? ??????? ?????????? ? ???????
			if playersInPuddle[targetPlayer] then
				playersInPuddle[targetPlayer] = nil
				lastHealTime[targetPlayer] = nil
				lastDamageTime[targetPlayer] = nil

				-- ??????? ?????????? ? ???????
				if targetChar:IsDescendantOf(killersFolder) then
					slowwalkevent:FireClient(
						targetPlayer,
						11,
						13,
						false,
						1,
						true -- ??????? ??????????
					)
					print("?????? ????? ?? ????: ?????????? ?????")
				end
			end
		end)

		-- ???? ???????/?????
		local healConnection
		healConnection = RunService.Heartbeat:Connect(function()
			if not hitbox or not hitbox.Parent then
				healConnection:Disconnect()
				return
			end
			healSurvivors()
		end)

		-- ??????? ???? ????? 6 ??????
		task.delay(7, function()
			if hitbox and hitbox.Parent then 
				hitbox:Destroy() 
				hitbox2:Destroy()
			end
			-- ??????? ?????????? ?? ???? ??????? ??? ???????? ????
			for targetPlayer, _ in pairs(playersInPuddle) do
				if targetPlayer and targetPlayer.Character and targetPlayer.Character:IsDescendantOf(killersFolder) then
					slowwalkevent:FireClient(
						targetPlayer,
						11,
						13,
						false,
						1,
						true -- ??????? ??????????
					)
				end
			end
			if healConnection then
				healConnection:Disconnect()
			end
		end)
	elseif action == "TOILET_hukia_babra" then   
		local Toiletno = Toilet:Clone()
		Toiletno.Parent = workspace
		task.delay(3,function()
			Toiletno:Destroy()
		end)

		local function getPart(name)
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == name then
					return obj 
				end
			end
			return nil
		end

		local part1 = getPart("Part1")
		local part2 = getPart("Part2")
		local part3 = getPart("Part3")

		local random = Random.new():NextInteger(1, 3)

		if random == 1 and part1 then
			character:WaitForChild("HumanoidRootPart").CFrame = part1.CFrame
		elseif random == 2 and part2 then
			character:WaitForChild("HumanoidRootPart").CFrame = part2.CFrame
		elseif random == 3 and part3 then
			character:WaitForChild("HumanoidRootPart").CFrame = part3.CFrame
		end

		-- ???????? ??????
		if Toiletno.PrimaryPart then
			Toiletno:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
		else
			local root = Toiletno:FindFirstChild("HumanoidRootPart") or Toiletno:FindFirstChildWhichIsA("BasePart")
			if root then
				Toiletno.PrimaryPart = root
				Toiletno:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
			end
		end
	end
end)