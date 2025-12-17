local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local event = ReplicatedStorage.EventsForParts:WaitForChild("SpawnHitboksTInky")
local Debris = game:GetService("Debris")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local eventMESSAGE = game.ReplicatedStorage.Events.ForMessangeLabel
local playersFolder = workspace:WaitForChild("Players")

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
					playHitSound(character, "rbxassetid://102299249994473")
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
	local character = player.Character
	if not character then return end
	if action == "Attack_NazrikJan" then
	if character.Rage.Value == true then
		createHitbox(character, 100, 0.5, 0.05)
		else
		createHitbox(character, 28, 0.5, 0.05)
	end
	elseif action == "Jump_NazrikJan" then
		slowwalkevent:FireClient(player, 50, 78, true, 1, false)
	elseif action == "Hide_NazrikJan" then
		-- ?????? ????????? ?????? (?????????)
		RunControlEvent:FireClient(player, { type = "Slowdown", duration = 15, speed = 0, priority = 110 })

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		-- ??????? BoolValue "Invincible" ??? ??????? ????????????
		local invincible = Instance.new("BoolValue")
		invincible.Name = "Invincible"
		invincible.Parent = character
		invincible.Value = true
		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr ~= player then -- ?? ?????????? ???????
				eventMESSAGE:FireClient(plr, "Hide while you can...", true)
			end
		end
		-- ?????????? 15 ????????? ????????????
		task.delay(15, function()
			-- ????? ??????? 15 ?????? ???????? "Rage"
			slowwalkevent:FireClient(player, 30, 38, true, 20, false)
			character.Rage.Value = true
			invincible.Value = false
			for _, plr in pairs(game.Players:GetPlayers()) do
				if plr ~= player then -- ?? ?????????? ???????
					eventMESSAGE:FireClient(plr, "The hunt begins...", true)
				end
			end
			task.delay(20,function()
				character.Rage.Value = false
				for _, plr in pairs(game.Players:GetPlayers()) do
					if plr ~= player then -- ?? ?????????? ???????
						eventMESSAGE:FireClient(plr, "The hunt begins...", false)
					end
				end
			end)
			-- ????? ?????? ?? +200 HP
			if humanoid.Health > 0 then
				humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 200)
			end

			-- ??????? ????? ????????????
			invincible:Destroy()
		end)
	elseif action == "Zvonok_NazrikJan" then
		print("Zvonok activated!")

		local playersFolder = workspace:WaitForChild("Players")
		local killersFolder = playersFolder:FindFirstChild("Killer") or workspace:FindFirstChild("Killer")

		-- ???????? ???? ????????? ??????? (????? ???????)
		local possiblePlayers = {}

		for _, plr in pairs(Players:GetPlayers()) do
			-- ?????????? ?????? ?????? ? ????????? ??????? ????????? ? Humanoid
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
				local charParent = plr.Character.Parent
				local hum = plr.Character:FindFirstChild("Humanoid")

				-- ?????????, ??? ????? ??? ? ??? ?? ???? ????????, ???? ???????
				if hum.Health > 0 and (charParent == game.Workspace.Players.Survivors or charParent == game.Workspace.Players.Neutral) then
					table.insert(possiblePlayers, plr)
				end
			end
		end


		if #possiblePlayers == 0 then
			warn("??? ?????????? ??????? ??? ??????.")
			return
		end

		-- ?? ???????? ?????????? ?????????
		local randomPlayer = possiblePlayers[math.random(1, #possiblePlayers)]
		local randomChar = randomPlayer.Character
		if not randomChar then return end
		local playerGui = randomPlayer:WaitForChild("PlayerGui")

		-- ?? ??????? GUI
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ZvonokGui"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = playerGui

		local background = Instance.new("ImageLabel")
		background.Size = UDim2.new(0, 253, 0, 316)
		background.Position = UDim2.new(0.413, 0, 0.288, 0)
		background.Image = "rbxassetid://76111073445184"
		background.BackgroundTransparency = 1
		background.Parent = screenGui

		local accept = Instance.new("TextButton")
		accept.Size = UDim2.new(0, 110, 0, 50)
		accept.Position = UDim2.new(0.43, 0, 0.65, 0)
		accept.Text = "?? ???????"
		accept.BackgroundTransparency = 1
		accept.TextScaled = true
		accept.TextColor3 = Color3.new(0, 1, 0)
		accept.Font = Enum.Font.GothamBold
		accept.Parent = screenGui

		local decline = Instance.new("TextButton")
		decline.Size = UDim2.new(0, 110, 0, 50)
		decline.Position = UDim2.new(0.43, 0, 0.78, 0)
		decline.Text = "? ?????????"
		decline.BackgroundTransparency = 1
		decline.TextScaled = true
		decline.TextColor3 = Color3.new(1, 0, 0)
		decline.Font = Enum.Font.GothamBold
		decline.Parent = screenGui

		local accepted, declined = false, false

		-- ? ??????? — ????
		accept.MouseButton1Click:Connect(function()
			if accepted or declined then return end
			accepted = true
			local humanoid = randomChar:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(25)
			end
			screenGui:Destroy()
		end)

		-- ? ????????? — ????????? ????????? + ???????? ???????
		decline.MouseButton1Click:Connect(function()
			if accepted or declined then return end
			declined = true
			screenGui:Destroy()

			local hrpTarget = randomChar:FindFirstChild("HumanoidRootPart")
			if not hrpTarget then return end
			event:FireClient(player,"Zvonok_Sbros",randomChar)
		end)

		-- ? ????? ?????? — ???? ?? ?????? ?????? ??????
		task.delay(5, function()
			if accepted or declined then return end -- ???? ???? ???? ???????? ???? — ???????
			screenGui:Destroy()

			local hrpTarget = randomChar:FindFirstChild("HumanoidRootPart")
			if not hrpTarget then return end

			print("????? ?????????????? ?????? — ???????????? ???????!")

			if killersFolder then
				for _, killer in ipairs(killersFolder:GetChildren()) do
					local killerRoot = killer:FindFirstChild("HumanoidRootPart")
					if killerRoot then
						killerRoot.CFrame = hrpTarget.CFrame * CFrame.new(0, 0, 5)
						break
					end
				end
			end
		end)
	elseif action == "ZvonokFake_NazrikJan" then
		print("ZvonokFake_NazrikJan activated!")

		local playersFolder = workspace:WaitForChild("Players")
		local killersFolder = playersFolder:FindFirstChild("Killer") or workspace:FindFirstChild("Killer")

		-- ???????? ???? ????????? ??????? (????? ???????)
		local possiblePlayers = {}

		for _, plr in pairs(Players:GetPlayers()) do
			-- ?????????? ?????? ?????? ? ????????? ??????? ????????? ? Humanoid
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
				local charParent = plr.Character.Parent
				local hum = plr.Character:FindFirstChild("Humanoid")

				-- ?????????, ??? ????? ??? ? ??? ?? ???? ????????, ???? ???????
				if hum.Health > 0 and (charParent == game.Workspace.Players.Survivors or charParent == game.Workspace.Players.Neutral) then
					table.insert(possiblePlayers, plr)
				end
			end
		end

		if #possiblePlayers == 0 then
			warn("??? ?????????? ??????? ??? ??????.")
			return
		end

		-- ?? ???????? ?????????? ?????????
		local randomPlayer = possiblePlayers[math.random(1, #possiblePlayers)]
		local randomChar = randomPlayer.Character
		if not randomChar then return end
		local playerGui = randomPlayer:WaitForChild("PlayerGui")

		-- ?? ??????? GUI
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ZvonokGui"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = playerGui

		local background = Instance.new("ImageLabel")
		background.Size = UDim2.new(0, 253, 0, 316)
		background.Position = UDim2.new(0.413, 0, 0.288, 0)
		background.Image = "rbxassetid://76111073445184"
		background.BackgroundTransparency = 1
		background.Parent = screenGui

		local accept = Instance.new("TextButton")
		accept.Size = UDim2.new(0, 110, 0, 50)
		accept.Position = UDim2.new(0.43, 0, 0.65, 0)
		accept.Text = "?? ???????"
		accept.BackgroundTransparency = 1
		accept.TextScaled = true
		accept.TextColor3 = Color3.new(0, 1, 0)
		accept.Font = Enum.Font.GothamBold
		accept.Parent = screenGui

		local decline = Instance.new("TextButton")
		decline.Size = UDim2.new(0, 110, 0, 50)
		decline.Position = UDim2.new(0.43, 0, 0.78, 0)
		decline.Text = "? ?????????"
		decline.BackgroundTransparency = 1
		decline.TextScaled = true
		decline.TextColor3 = Color3.new(1, 0, 0)
		decline.Font = Enum.Font.GothamBold
		decline.Parent = screenGui

		local accepted, declined = false, false

		-- ? ??????? — ????
		accept.MouseButton1Click:Connect(function()
			if accepted or declined then return end
			declined = true
			screenGui:Destroy()

			local hrpTarget = randomChar:FindFirstChild("HumanoidRootPart")
			if not hrpTarget then return end
			event:FireClient(player,"Zvonok_Sbros",randomChar)
		end)

		-- ? ????????? — ????????? ????????? + ???????? ???????
		decline.MouseButton1Click:Connect(function()
			if accepted or declined then return end
			accepted = true
			local humanoid = randomChar:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(25)
			end
			screenGui:Destroy()
		end)

		-- ? ????? ?????? — ???? ?? ?????? ?????? ??????
		task.delay(5, function()
			if accepted or declined then return end -- ???? ???? ???? ???????? ???? — ???????
			screenGui:Destroy()

			local hrpTarget = randomChar:FindFirstChild("HumanoidRootPart")
			if not hrpTarget then return end

			print("????? ?????????????? ?????? — ???????????? ???????!")

			if killersFolder then
				for _, killer in ipairs(killersFolder:GetChildren()) do
					local killerRoot = killer:FindFirstChild("HumanoidRootPart")
					if killerRoot then
						killerRoot.CFrame = hrpTarget.CFrame * CFrame.new(0, 0, 5)
						break
					end
				end
			end
		end)
	end
end)
