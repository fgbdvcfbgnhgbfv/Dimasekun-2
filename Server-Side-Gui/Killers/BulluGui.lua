local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")

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
					and (targetChar:IsDescendantOf(survivorsFolder) 
						or targetChar:IsDescendantOf(NeutralFolder)) then
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
					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
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

local function createMovingHitbox(character, damage, speed, interval)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local alreadyHit = {}
	local distance = 500 -- ????????? ?????? ?????
	local duration = distance / speed -- ??????? ????? ?? ????????

	-- ????????? ?????
	local toporModel = game.ReplicatedStorage.KillersParts.bully.Topor:Clone()
	toporModel.Parent = workspace

	for _, part in ipairs(toporModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
		end
	end

	local primaryPart = toporModel.PrimaryPart or toporModel:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	-- ????????? ???????
	local startCFrame = hrp.CFrame * CFrame.new(0, 0, -5)
	primaryPart.CFrame = startCFrame

	-- ?????
	local goalCFrame = startCFrame + (hrp.CFrame.LookVector * distance)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(primaryPart, tweenInfo, { CFrame = goalCFrame })
	tween:Play()

	-- ???????? ??????
	local direction = hrp.CFrame.LookVector.Unit
	local rotation = 0
	local spinConn
	spinConn = RunService.Heartbeat:Connect(function(dt)
		if primaryPart and primaryPart.Parent then
			rotation = rotation + math.rad(720) * dt
			primaryPart.CFrame = CFrame.new(primaryPart.Position, primaryPart.Position + direction) 
				* CFrame.Angles(rotation, 0, 0)
		else
			if spinConn then spinConn:Disconnect() end
		end
	end)

	-- ???????
	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(4, 7.5, 3)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Transparency = 1 -- ?????? ?????????
	hitbox.Name = "Hitbox"
	hitbox.Parent = workspace:FindFirstChild("Hitboxes") or workspace

	-- ????????????? ???????? ? ???????
	local hbConn
	hbConn = RunService.Heartbeat:Connect(function()
		if hitbox and hitbox.Parent and primaryPart and primaryPart.Parent then
			hitbox.CFrame = primaryPart.CFrame

			-- ???????? ?????????
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			overlapParams.FilterDescendantsInstances = { character, toporModel }

			local parts = workspace:GetPartsInPart(hitbox, overlapParams)
			for _, part in ipairs(parts) do
				local targetChar = part:FindFirstAncestorOfClass("Model")
				if targetChar
					and not alreadyHit[targetChar]
					and (targetChar:IsDescendantOf(survivorsFolder) 
						or targetChar:IsDescendantOf(NeutralFolder)) then

					local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.Health > 0 then
						targetHumanoid:TakeDamage(damage)
						alreadyHit[targetChar] = true
					end
				end
			end
		else
			if hbConn then hbConn:Disconnect() end
		end
	end)

	-- ???????
	task.delay(duration, function()
		if hbConn then hbConn:Disconnect() end
		if spinConn then spinConn:Disconnect() end
		if hitbox and hitbox.Parent then hitbox:Destroy() end
		if toporModel and toporModel.Parent then toporModel:Destroy() end
	end)
end

local function createHitboxJump(character, duration)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local alreadyHit = {}

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character }
	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(48.271, 20.152, 48.961)
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
		if targetChar 
			and not alreadyHit[targetChar] 
			and targetChar:IsDescendantOf(survivorsFolder)
			or targetChar:IsDescendantOf(NeutralFolder) then

			local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 then
				local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
				if targetPlayer then
					RunControlEvent:FireClient(targetPlayer, {
						type = "Slowdown",
						duration = 6,  
						speed = 12,      
						priority = 101  
					})
				end
				alreadyHit[targetChar] = true
			end
		end
	end

	task.delay(2, function()
		if hitbox and hitbox.Parent then
			hitbox:Destroy()
		end
	end)
end

-- ?????????? ???????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	if action == "Attack_Bullu" then 
		if character:FindFirstChild("Bullu2") then
			createHitbox(character, 25, 1, 0.05)
		else
			createHitbox(character, 20, 1, 0.05)
		end
	elseif action == "jump_Bullu" then
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 3,  
			speed = 0,      
			priority = 101  
		})
		createHitboxJump(character, 3)
	elseif action == "topor_bully" then
		createMovingHitbox(character, 20, 50, 0.05)
	end
end)
