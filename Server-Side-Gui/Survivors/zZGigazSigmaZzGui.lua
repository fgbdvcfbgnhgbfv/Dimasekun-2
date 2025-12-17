local Players = game:GetService("Players")
local event = game.ReplicatedStorage.Events.Survivors.SurvivorsRemovEvent
local RunControlEvent = game.ReplicatedStorage.Events.RunControlEvent
local KillerFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local stananimevent = game.ReplicatedStorage.Events.StanAnimEvent
local NeutralFolder = workspace:WaitForChild("Players"):WaitForChild("Neutral")
local SurvivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")
local slowwalkevent = game.ReplicatedStorage.Events.Slowwalkevent
local salo = game.ReplicatedStorage.SurvivorsParts.zZGigazSigmaZz.Salo
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

event.OnServerEvent:Connect(function(player, action)
	
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local plr = Players:GetPlayerFromCharacter(character)

	if action == "vistrel_zZGigazSigmaZz" then
		slowwalkevent:FireClient(
			plr, -- ????? ???????? ????????????? ?????
			14, -- ???????? ??????
			16, -- ???????? ????
			true, -- ???????????? ?? ???? ???
			2, -- ????????????
			false -- ?????????? ??? ??? false ??? true ?? (?????? ???? 4 ???????? false)
		)
		task.delay(2, function()
			local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
			if not hrp then return end

			-- ??????????? ??????? ?????? (?????? ??????)
			local forward = hrp.CFrame.LookVector

			-- ?????????? ?????? ?? ?????? (?????? ???????? 5 ?? ?????? ????????)
			local distance = 5

			local newposition = hrp.Position + forward * distance

			local saloclone = salo:Clone()
			saloclone.CFrame = CFrame.new(newposition, newposition + forward) -- ????????? ? ?? ?? ???????
			saloclone.Parent = workspace
			saloclone.Touched:Connect(function(hit)
				local character = hit.Parent
				if not character then return end
				local player = Players:GetPlayerFromCharacter(character)
				if not player then return end 
				local hasVar1 = player:FindFirstChild("ZloiSergayOpasno") 
					or character:FindFirstChild("ZloiSergayOpasno")
				-- ?????????, ????????? ?? ???????? ? KillerFolder
				if KillerFolder:FindFirstChild(character.Name) or NeutralFolder:FindFirstChild(character.Name)  then
					if hasVar1 then
						RunControlEvent:FireClient(player, {
							type = "Slowdown",
							duration = 5,
							speed = 0,
							priority = 100
						})
					stanevent:FireClient(Players:GetPlayerFromCharacter(character), 5)
					else
						RunControlEvent:FireClient(player, {
							type = "Slowdown",
							duration = 5,
							speed = 8,
							priority = 100
						})
					end
					task.delay(0.1, function()
						if saloclone and saloclone.Parent then
							saloclone:Destroy()
						end
					end)
				else
					print(character.Name .. " ?? ?? KillerFolder.")
				end
			end)
		end)
	end
end)
