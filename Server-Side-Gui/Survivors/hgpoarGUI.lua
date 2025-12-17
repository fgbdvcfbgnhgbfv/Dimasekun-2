local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local RunControlEvent = ReplicatedStorage.Events:WaitForChild("RunControlEvent")
local event = ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local killerfolder = game.Workspace.Players.Killer
local damageRadius = 20
local damageAmount = 50
local stananimevent = game.ReplicatedStorage.Events.StanAnimEvent
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")

-- ????????? ??? ???????? ????
local ActiveBombs = {}
-- ????????? ??? ???????? ????? ? ?????
local ActiveSeeds = {}
-- ????????? ???? ??????? ??????
local PlayerBombs = {}
-- ??????? ????????, ????? ?? ????? Killer
local function isKillerFolderEmpty()
	return #killerfolder:GetChildren() == 0
end

-- ??????? ???????? ???? ????? ? ?????
local function clearAllSeeds()
	for _, seed in ipairs(ActiveSeeds) do
		if seed and seed.Parent then
			seed:Destroy()
		end
	end
	ActiveSeeds = {} -- ??????? ???????
end

-- ?? ????? ????? ? ?????, ??????? ????? ??????
local function spawnSeeds(position)
	-- ???? ????? Killer ?????, ?? ??????? ??????
	if isKillerFolderEmpty() then
		return
	end
	local seed = Instance.new("Part")
	seed.Size = Vector3.new(1, 1, 1)
	seed.Shape = Enum.PartType.Ball
	seed.Color = Color3.fromRGB(34, 139, 34) -- ?????-??????? (????)
	seed.Anchored = true
	seed.CanCollide = false
	seed.Position = position + Vector3.new(0, -2.4, 0)
	seed.Name = "Seed"
	seed.Parent = game.Workspace.trash

	-- ????????? ???? ? ???????
	table.insert(ActiveSeeds, seed)

	-- ????? 15 ?????? ???? ?????????? ????????
	task.delay(15, function()
		if seed and seed.Parent then
			-- ???? ????? Killer ?????, ??????? ???? ? ???????
			if isKillerFolderEmpty() then
				seed:Destroy()
				for i, s in ipairs(ActiveSeeds) do
					if s == seed then
						table.remove(ActiveSeeds, i)
						break
					end
				end
				return
			end

			seed.Size = Vector3.new(5, 5, 5)
			seed.Shape = Enum.PartType.Block
			seed.Color = Color3.fromRGB(50, 205, 50) -- ????-??????? (????)
			seed.Name = "Grass"

			-- ?????? ????????? ProximityPrompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "?????? ?????"
			prompt.ObjectText = "?????"
			prompt.HoldDuration = 1.5
			prompt.RequiresLineOfSight = false
			prompt.Parent = seed

			-- ?????????? "????????"
			prompt.Triggered:Connect(function(player)
				local effecthealing = game.ReplicatedStorage.Effects.Healinf["Main-01"]:Clone()
				local Highlight = game.ReplicatedStorage.Effects.Healinf.Highlight:Clone()
				local arrow = game.ReplicatedStorage.Effects.Healinf.Arrow:Clone()
				local char = player.Character
				if not char then return end
				effecthealing.Parent = char.Torso
				Highlight.Parent = char
				arrow.Parent = char.Torso
				local hgpoar = char:FindFirstChild("hgpoar")
				if not (hgpoar and hgpoar:IsA("BoolValue") and hgpoar.Value == true) then
					return
				end
					-- ?????? ???? ????? — Survivor
					local survivorsFolder = workspace.Players:FindFirstChild("Survivors")
					if not survivorsFolder then return end
					if not char:IsDescendantOf(survivorsFolder) then
						return
					end

					-- ?????? ?? ????????
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 20)
						task.delay(3,function()
							effecthealing:Destroy()
							Highlight:Destroy()
							arrow:Destroy()
						end)
					end
				
					-- ??????? ???? ????? ????????
					seed:Destroy()
					for i, s in ipairs(ActiveSeeds) do
						if s == seed then
							table.remove(ActiveSeeds, i)
							break
						end
					end				
			end)
		end
	end)

	-- ??????? ????/???? ????? 40 ??????, ???? ????? ?? ????
	game:GetService("Debris"):AddItem(seed, 40)
end

local function createFakeExplosion(position)
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastPressure = 0
	explosion.BlastRadius = 0
	explosion.Visible = true
	explosion.Parent = workspace

	-- ???????? ???? ?????????? ?? killerfolder ? NeutralFolder
	local allCharacters = {}
	for _, character in ipairs(killerfolder:GetChildren()) do
		table.insert(allCharacters, character)
	end
	for _, character in ipairs(NeutralFolder:GetChildren()) do
		table.insert(allCharacters, character)
	end

	-- ????????? ?????????? ? ??????? ????
	for _, character in ipairs(allCharacters) do
		if character:IsA("Model") 
			and character:FindFirstChild("Humanoid") 
			and character:FindFirstChild("HumanoidRootPart") then

			local distance = (character.HumanoidRootPart.Position - explosion.Position).Magnitude
			if distance <= damageRadius then
				character.Humanoid:TakeDamage(200)

				local killerPlayer = Players:GetPlayerFromCharacter(character)
				if killerPlayer then
					stanevent:FireClient(killerPlayer, 15)
					stananimevent:FireClient(killerPlayer, 15)
					RunControlEvent:FireClient(killerPlayer, {
						type = "Slowdown",
						duration = 15,
						speed = 0,
						priority = 100
					})
				end
			end
		end
	end

	-- ??????? ????? ????? 2 ???????
	game:GetService("Debris"):AddItem(explosion, 2)
end

-- ?? ??????? ?????
local function throwBomb(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local bombPart = character:FindFirstChild("Bomb")
	if not hrp or not bombPart then return end
	stanevent:FireClient(player, 2)
	RunControlEvent:FireClient(player, {
		type = "Slowdown",
		duration = 2,
		speed = 16,
		priority = 70
	})
	-- ????????? Bomb
	local bombClone = bombPart:Clone()
	bombClone.Transparency = 0
	bombClone.Anchored = false
	bombClone.CanCollide = false
	bombClone.Parent = workspace
	bombClone.CFrame = hrp.CFrame * CFrame.new(0, -2, -2)
	bombClone.Anchored = true

	-- ????????? ????? ??????????? ??????
	PlayerBombs[player] = PlayerBombs[player] or {}
	table.insert(PlayerBombs[player], bombClone)

	-- ??????? ????? 60 ???, ???? ?? ?????????
	game:GetService("Debris"):AddItem(bombClone, 60)
end

-- ?? ????????? — ???????? ??? ?????, ??????? ???? 25 ? ?????? ?????? ????????
local function detonateBombs(player)
	if not PlayerBombs[player] then return end
	stanevent:FireClient(player, 2)
	RunControlEvent:FireClient(player, {
		type = "Slowdown",
		duration = 2,
		speed = 16,
		priority = 70
	})
	for i, bomb in ipairs(PlayerBombs[player]) do
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
		if bomb and bomb.Parent then
			local explosion = Instance.new("Explosion")
			explosion.Position = bomb.Position
			explosion.BlastPressure = 0
			explosion.BlastRadius = 0
			explosion.Visible = true
			explosion.Parent = workspace
			local allCharacters = {}

			for _, character in pairs(killerfolder:GetChildren()) do
				table.insert(allCharacters, character)
			end

			for _, character in pairs(NeutralFolder:GetChildren()) do
				table.insert(allCharacters, character)
			end

			-- ??????? ???? ?????? ???, ??? ? ???????
			for _, character in pairs(allCharacters) do
				if character:IsA("Model") 
					and character:FindFirstChild("Humanoid") 
					and character:FindFirstChild("HumanoidRootPart") then

					local distance = (character.HumanoidRootPart.Position - bomb.Position).Magnitude
					if distance <= damageRadius then
						-- ??????? ????
						character.Humanoid:TakeDamage(damageAmount)

						-- ???????? ?????? ?? ?????? ?????????
						local killerPlayer = Players:GetPlayerFromCharacter(character)
						if killerPlayer then
							stanevent:FireClient(killerPlayer, 5)
							stananimevent:FireClient(killerPlayer, 5)
							RunControlEvent:FireClient(killerPlayer, {
								type = "Slowdown",
								duration = 5,
								speed = 0,
								priority = 100
							})
						end
					end
				end
			end
			bomb:Destroy()
			playSound("rbxassetid://5801257793", bomb.Position, 5)
		end
	end

	-- ??????? ?????? ???? ??????
	PlayerBombs[player] = {}
end

-- ?? ?????????? ?? ?????? Killer
killerfolder.ChildAdded:Connect(function()
	-- ???? ????????? ??????, ?????? ?? ??????, ?????? ?????????? ????????
end)

killerfolder.ChildRemoved:Connect(function()
	-- ???? ????? Killer ????? ??????, ??????? ??? ?????? ? ?????
	if isKillerFolderEmpty() then
		clearAllSeeds()
	end
end)

-- ?? ?????????? ????????
event.OnServerEvent:Connect(function(player, action)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if action == "Seeds" then
		spawnSeeds(hrp.Position)
		stanevent:FireClient(player, 2)
		RunControlEvent:FireClient(player, {
			type = "Slowdown",
			duration = 2,
			speed = 16,
			priority = 70
		})

	elseif action == "Bomb" then
		throwBomb(player, character)
	elseif action == "Detonator" then
		detonateBombs(player)
	elseif action == "Self_Destruct_Travaedov" then
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not torso then return end

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

			-- ??????? ????? Debris
			game:GetService("Debris"):AddItem(soundPart, duration)
		end

		-- 5 ?????? ???????
		playSound("rbxassetid://104620601698793", torso.Position, 1) -- 1
		task.wait(1)

		playSound("rbxassetid://105970907356510", torso.Position, 1) -- 2
		task.wait(1)

		playSound("rbxassetid://70928471769738", torso.Position, 1) -- 3
		task.wait(1)

		playSound("rbxassetid://89833181520046", torso.Position, 1) -- 4
		task.wait(1)

		playSound("rbxassetid://74638497606561", torso.Position, 1) -- 5
		task.wait(1)

		-- ????????? ???? ??????
		playSound("rbxassetid://5801257793", torso.Position, 5)

		-- ????? ? ??????
		createFakeExplosion(torso.Position)
		character.Humanoid.Health = 0
	end
end)