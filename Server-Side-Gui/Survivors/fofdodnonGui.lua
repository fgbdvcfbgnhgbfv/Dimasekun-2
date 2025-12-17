local Players = game:GetService("Players")
local event = game.ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local RunControlEvent = game.ReplicatedStorage.Events.RunControlEvent
local KillerFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local stananimevent = game.ReplicatedStorage.Events.StanAnimEvent
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local SurvivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local doclone = true
local TweenService = game:GetService("TweenService")

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

local function setCharacterVisibilityClone(character, visible)
	for _, obj in ipairs(character:GetDescendants()) do
		-- ? ??? ???? ?????????? ?????? ??????
		if obj:IsA("BasePart") and not (obj.Name == "Pig" or obj.Name == "Sword" or obj.Name == "Invo") then
			obj.Transparency = visible and 0 or 1
			obj.Anchored = true
			obj.CanCollide = false
			obj.Massless = true

			local decal = obj:FindFirstChildOfClass("Decal")
			if decal then
				decal.Transparency = visible and 0 or 1
			end

			-- ? ??? ??????????? (????????? ???????? ? Handle)
		elseif obj:IsA("Accessory") then
			local handle = obj:FindFirstChild("Handle")
			if handle then
				handle.Anchored = true
				handle.CanCollide = false
				handle.Massless = true

				if not (handle.Name == "Pig" or handle.Name == "Sword" or handle.Name == "Invo") then
					handle.Transparency = visible and 0 or 1

					local decal = handle:FindFirstChildOfClass("Decal")
					if decal then
						decal.Transparency = visible and 0 or 1
					end
				end
			end
		end
	end
end

-- helper: ????????? ???????? humanoid
local function safeHealHumanoid(targetHumanoid, amount)
	if not targetHumanoid or amount <= 0 then return end
	targetHumanoid.Health = math.clamp(targetHumanoid.Health + amount, 0, targetHumanoid.MaxHealth)
end

-- CREATE HITBOX OPERA (????)
local function createHitboxOpera(character, player)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local alreadyHit = {}
	local effectmusic = game.ReplicatedStorage.Effects.fofdodnon.fofdodnonMusic:Clone()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }

	local hitbox = Instance.new("Part")
	effectmusic.Parent = hitbox
	hitbox.Size = Vector3.new(15, 7.5, 14)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Color = Color3.new(1, 0.28, 0.05)
	hitbox.Transparency = 0.55
	hitbox.Name = "Hitbox"
	hitbox.CFrame = hrp.CFrame
	hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

	local parts = workspace:GetPartsInPart(hitbox, overlapParams)
	for _, part in ipairs(parts) do
		local targetChar = part:FindFirstAncestorOfClass("Model")
		if not targetChar then continue end

		-- ?????????? player id ??? ???? — ???????, ???? ???? ?????? ????????????
		local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
		if not targetPlayer then continue end

		if not alreadyHit[targetPlayer.UserId] and targetChar:IsDescendantOf(SurvivorsFolder) then
			local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 then
				local hasVar1 = targetPlayer:FindFirstChild("tmugrobot") or targetChar:FindFirstChild("tmugrobot")
				if not hasVar1 then
					-- ???????? ?????, ????? ???????? ?????????? ???? ? ???? ?????
					alreadyHit[targetPlayer.UserId] = true

					-- ?????????? ???????? ??????? — 10 HP
					local healAmount = 10
					safeHealHumanoid(targetHumanoid, healAmount)

					slowwalkevent:FireClient(targetPlayer, 20, 28, true, 7, false)
					slowwalkevent:FireClient(player, 20, 28, true, 7, false)
				end
			end
		end
	end

	task.delay(5, function()
		if hitbox and hitbox.Parent then hitbox:Destroy() end
	end)
end


local function createHitboxPigrat(character, player)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }

	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(15, 7.5, 14)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Color = Color3.new(1, 0.28, 0.05)
	hitbox.Transparency = 1
	hitbox.Name = "Hitbox"
	hitbox.CFrame = hrp.CFrame 
	hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

	-- ????????? ??? ?????
	local parts = workspace:GetPartsInPart(hitbox, overlapParams)
	local alliesNearby = 0

	for _, part in ipairs(parts) do
		local targetChar = part:FindFirstAncestorOfClass("Model")
		if targetChar and targetChar ~= character then
			-- ?????????, ??? ??? ???????
			if (character:IsDescendantOf(SurvivorsFolder) and targetChar:IsDescendantOf(SurvivorsFolder)) then

				alliesNearby += 1
			end
		end
	end

	-- ???? ???? ???????? ????? — ???????? ????????
	if alliesNearby > 0 and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
		humanoid.Health = math.clamp(humanoid.Health + 0.5, 0, humanoid.MaxHealth)
		task.delay(0.1,function()
			humanoid.Health = math.clamp(humanoid.Health + 0.5, 0, humanoid.MaxHealth)
			task.delay(0.1,function()
				humanoid.Health = math.clamp(humanoid.Health + 0.5, 0, humanoid.MaxHealth)
				task.delay(0.1,function()
					humanoid.Health = math.clamp(humanoid.Health + 0.5, 0, humanoid.MaxHealth)
				end)
			end)
		end)
		print("??", player.Name, "??????????? +1 HP (????? ?????????:", alliesNearby, ")")
	end

	-- ??????? ???????
	task.delay(2, function()
		if hitbox and hitbox.Parent then
			hitbox:Destroy()
		end
	end)
end

event.OnServerEvent:Connect(function(player, action)
	
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local plr = Players:GetPlayerFromCharacter(character)
	
	local function dashMovement(speed, hold, decel)
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local cam = workspace.CurrentCamera
		local look = cam.CFrame.LookVector
		local dir = Vector3.new(look.X, 0, look.Z).Unit

		rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + dir)

		for _, v in ipairs(rootPart:GetChildren()) do
			if v:IsA("BodyVelocity") and v.Name == "DashBV" then
				v:Destroy()
			end
		end
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "DashBV"
		bv.MaxForce = Vector3.new(1e6, 0, 1e6)
		bv.P = 1e5
		bv.Velocity = dir * speed
		bv.Parent = rootPart

		task.delay(hold, function()
			local tween = TweenService:Create(bv, TweenInfo.new(decel, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Velocity = Vector3.new(0,0,0) })
			tween:Play()
			tween.Completed:Connect(function()
				if bv and bv.Parent then bv:Destroy() end
			end)
		end)
	end
	
	local function createHitbox(character, damage, duration, interval)
		local function playSoundOLD(id, duration)
			local sound = character.Torso.Sound
			sound.SoundId = id
			sound.Volume = 1
			sound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character
			sound:Play()
		end
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
				hitbox.Transparency = 1
				hitbox.Name = "Hitbox" -- ???????? AttackHitbox ?? Hitbox
				hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
				hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

				local parts = workspace:GetPartsInPart(hitbox, overlapParams)
				for _, part in ipairs(parts) do
					local targetChar = part:FindFirstAncestorOfClass("Model")
					local playerHit = Players:GetPlayerFromCharacter(targetChar)
					if targetChar 
						and not alreadyHit[targetChar] 
						and (targetChar:IsDescendantOf(KillerFolder) or targetChar:IsDescendantOf(NeutralFolder)) then

						local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHumanoid and targetHumanoid.Health > 0 then
							targetHumanoid:TakeDamage(damage)
							local playerhumanoid = character:FindFirstChildOfClass("Humanoid")
							playerhumanoid:TakeDamage(5)
							stanevent:FireClient(playerHit, 1)
							stananimevent:FireClient(playerHit, 1)
							if playerHit then
								RunControlEvent:FireClient(playerHit, {
									type = "Slowdown",
									duration = 1,
									speed = 0,
									priority = 100
								})
								doclone = false
								playSoundOLD("rbxassetid://138831628253997", 2)
								dashMovement(120, 0.5, 0.5)
								task.delay(5,function()
									doclone = true
								end)
								setCharacterVisibility(character, true)
								character.HumanoidRootPart.Transparency = 1
							end
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
	
	if action == "scripatch_fofordan" then
		local function playSoundOLD(id, duration)
			local sound = character.Torso.Sound
			sound.SoundId = id
			sound.Volume = 1
			sound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character
			sound:Play()
		end

		local survivors = SurvivorsFolder:GetChildren()
		if #survivors == 1 then
			playSoundOLD("rbxassetid://136001193591937", 2)
			slowwalkevent:FireClient(player, 20, 30, true, 5, false)
		else
			playSoundOLD("rbxassetid://92801157023551", 2)
			slowwalkevent:FireClient(player, 20, 30, true, 5, false)
		end
	elseif action == "opera_fofordan" then
		local function playSoundOLD(id, duration)
			local sound = character.Torso.Sound
			sound.SoundId = id
			sound.Volume = 1
			sound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character
			sound:Play()
		end
		createHitboxOpera(character,player)
		playSoundOLD("rbxassetid://89875074588885", 2)
	elseif action == "Pigrat" then
		createHitboxPigrat(character, player)
	elseif action == "begyn_fofordan" then
		createHitbox(character, 10, 3, 0.05)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		setCharacterVisibility(character, false)
		for i = 1, 3 do
			task.delay((i - 1) * 1, function() -- ?? ?????? ???? ?????????? ????? 1 ???????
				if doclone == true then
				local clone = character:Clone()
				clone.Name = ""
				setCharacterVisibility(clone, true)
				clone.HumanoidRootPart.Transparency = 1

				-- ????????? ?????? ?????
				for _, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						part.Anchored = true
						part.Massless = true

						-- ????????? Highlight ? ?????? ?????
						local highlight = Instance.new("Highlight")
						highlight.FillColor = Color3.fromRGB(0, 170, 255)
						highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
						highlight.FillTransparency = 0.5
						highlight.OutlineTransparency = 0
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.Parent = part
					end
				end

				-- ????????? ???????? ?????? ??????
				local offset = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
				local hrpClone = clone:FindFirstChild("HumanoidRootPart")
				if hrpClone then
					hrpClone.CFrame = hrp.CFrame + offset
				end

				clone.Parent = workspace
				task.delay(0.1,function()
					clone.Parent = workspace
				end)
				-- ?????? ???????????
				task.spawn(function()
					for t = 1, 10 do
						for _, part in ipairs(clone:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = math.clamp(part.Transparency + 0.08, 0, 1)
							end
						end
						task.wait(0.25)
					end
					if clone then
						clone:Destroy()
					end
				end)
				-- ??????? ????? 3 ???????, ???? ?? ??????
				game:GetService("Debris"):AddItem(clone, 3)
				end
				task.delay(3,function()
					setCharacterVisibility(character, true)
					character.HumanoidRootPart.Transparency = 1
				end)
			end)
		end
	end
end)
