local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local event = ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local RunControlEvent = ReplicatedStorage.Events.RunControlEvent
local survivorsFolder = Workspace:WaitForChild("Players"):WaitForChild("Survivors")

event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	-- ===== ?????? ??? Kalutka =====
	if action == "Kalutka" then
		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(13, 61, 3)
		hitbox.Anchored = true
		hitbox.CanCollide = true
		hitbox.Color = Color3.new(163/255, 162/255, 165/255)
		hitbox.Transparency = 0
		hitbox.Name = "Stena"
		hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
		hitbox.Parent = Workspace
		task.delay(12, function()
			if hitbox and hitbox.Parent then
				hitbox:Destroy()
			end
		end)
	end

	-- ===== ?????? ??? S1 Pad =====
	if action == "S1 Pad" then
		if character:FindFirstChild("Torso") and character:FindFirstChild("S1TAB") then
			character.S1TAB.Transparency = 0
			if character.S1TAB:FindFirstChild("Decal") then
				character.S1TAB.Decal.Transparency = 0
			end
		end

		task.wait(3.2)
		if character:FindFirstChild("Torso") and character:FindFirstChild("S1TAB") then
			character.S1TAB.Transparency = 1
			if character.S1TAB:FindFirstChild("Decal") then
				character.S1TAB.Decal.Transparency = 1
			end
		end
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 5,
			speed = 16,
			priority = 100
		})
			for i = 1, 13 do
				task.wait(1)
				if humanoid then
					humanoid.Health += 1.6
				end
			end
	end

	-- ===== ?????? ??? Cnopa =====
	if action == "Cnopa" then
		local used = false
		local function playSoundOLD(id, duration) local sound = Instance.new("Sound") sound.SoundId = id sound.Volume = 1 sound.Parent = character.Torso sound:Play() task.wait(duration) sound:Destroy() end
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 2.5,
			speed = 0,
			priority = 100
		})
		
		-- ???????? ???????
		local summonAnimation = Instance.new("Animation")
		summonAnimation.AnimationId = "rbxassetid://95313734977770"
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		local summonTrack = animator:LoadAnimation(summonAnimation)
		summonTrack:Play()
		playSoundOLD("rbxassetid://113569980200886", 2)

		local CnopaModel = ReplicatedStorage.SurvivorsParts.fghgfhggfu.Cnopa
		local CnopaAnimId = "rbxassetid://89202376321752"
		local offsetDistance = 3

		local function spawnPolong(offset)
			if used == false then
				local Cnopa = CnopaModel:Clone()
				Cnopa.Parent = Workspace
				used = true
				task.delay(1, function()
					used = false
				end)

				if Cnopa.PrimaryPart then
					Cnopa:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(offset, 3, -2))
				end

				local CnopaHumanoid = Cnopa:FindFirstChildOfClass("Humanoid")
				if CnopaHumanoid then
					local polongAnimator = CnopaHumanoid:FindFirstChildOfClass("Animator")
					if not polongAnimator then
						polongAnimator = Instance.new("Animator")
						polongAnimator.Parent = CnopaHumanoid
					end

					local CnopaAnim = Instance.new("Animation")
					CnopaAnim.AnimationId = CnopaAnimId

					local CnopaTrack = polongAnimator:LoadAnimation(CnopaAnim)
					CnopaTrack:Play()
				end
			end
		end
		spawnPolong(offsetDistance)
	elseif action == "Privikaet" then
		local highlight = Instance.new("Highlight")
		highlight.Name = "Teleport"
		highlight.FillColor = Color3.fromRGB(242, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(242, 255, 0)
		highlight.FillTransparency = 0.6
		highlight.OutlineTransparency = 0
		highlight.Enabled = true
		highlight.Parent = character
		character["Right Leg"].ParticleEmitter.Enabled = true
		character["Left Leg"].ParticleEmitter.Enabled = true
		local function getPart(name)
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == name then
					return obj 
				end
			end
			return nil
		end
		local summonAnimation = Instance.new("Animation")
		summonAnimation.AnimationId = "rbxassetid://84377115932412"
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		local summonTrack = animator:LoadAnimation(summonAnimation)
		summonTrack:Play()
		summonTrack.Priority = Enum.AnimationPriority.Action4
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 2,
			speed = 0,
			priority = 150
		})

		task.delay(2,function()
			RunControlEvent:FireClient(player, {
				type = "Slowdown",
				duration = 2,
				speed = 0,
				priority = 150
			})

			local part1 = getPart("Part1")
			if part1 then
				character:WaitForChild("HumanoidRootPart").CFrame = part1.CFrame
			else
				warn("Part1 ?? ?????? ? Workspace!")
			end
		task.delay(2,function()
			RunControlEvent:FireClient(player, {
				type = "Slowdown",
				duration = 2,
				speed = 0,
				priority = 150
			})

			local part2 = getPart("Part2")
			if part2 then
				character:WaitForChild("HumanoidRootPart").CFrame = part2.CFrame
			else
				warn("Part2 ?? ?????? ? Workspace!")
			end
				task.delay(2,function()
					RunControlEvent:FireClient(player, {
						type = "Slowdown",
						duration = 2,
						speed = 0,
						priority = 150
					})
					local part3 = getPart("Part3")
					if part3 then
						character:WaitForChild("HumanoidRootPart").CFrame = part3.CFrame
					else
						warn("Part3 ?? ?????? ? Workspace!")
					end
					task.delay(2,function()
						summonTrack:Stop()
						character["Right Leg"].ParticleEmitter.Enabled = false
						character["Left Leg"].ParticleEmitter.Enabled = false
						highlight:Destroy()
					end)
				end)
		    end)
		end)
	end
end)

