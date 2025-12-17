local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.Events.Neutral.NeutralEvent
local player = Players.LocalPlayer
local isStunned = false 
local Debris = game:GetService("Debris")
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killer")
local stanevent = game.ReplicatedStorage.Events.StanEvent
local eda = 0
local edaevent = game.ReplicatedStorage.Events.Neutral.DenisEvents.EatPeoplsEvent
function DenisGui()
	
	script.Parent.Parent.Parent.Parent.RoundTimeGui.FrameForShops.Visible = false
	
	local function StunPlayer(duration)
		if isStunned then return end
		isStunned = true
		task.delay(duration, function()
			isStunned = false
		end)
	end
	stanevent.OnClientEvent:Connect(function(durection)
		StunPlayer(durection)
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "DenisGui"
	gui.Enabled = true
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Универсальная функция для кнопок
	local function createButton(name, text, posX, posY, keybind, isImage, iconId, visible)
		local btn = isImage and Instance.new("ImageButton") or Instance.new("TextButton")

		-- Настройка иконки или текста
		if isImage then
			-- Иконка
			btn.Image = iconId or "rbxassetid://0"
			btn.ScaleType = Enum.ScaleType.Fit

			-- Название способности (красивое, компактное)
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Parent = btn
			nameLabel.BackgroundTransparency = 0.35
			nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			nameLabel.Text = text
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.TextScaled = true
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.AnchorPoint = Vector2.new(0.5, 1)
			nameLabel.Position = UDim2.new(0.5, 0, 1, 0) -- снизу по центру
			nameLabel.Size = UDim2.new(1, 0, 0.25, 0)

			-- Скругление нижнего блока
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 12)
			corner.Parent = nameLabel
		else
			btn.Text = text
			btn.TextScaled = true
			btn.Font = Enum.Font.GothamBold
		end

		btn.Name = name
		btn.BackgroundColor3 = Color3.fromRGB(250,1,0)
		btn.Position = UDim2.new(posX, 0, posY, 0)
		btn.Size = UDim2.new(0.06, 0, 0.08, 0)
		btn.AutoButtonColor = false
		btn.Parent = gui

		-- Красивая обводка
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		-- Скругление
		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(0, 12)
		UICorner.Parent = btn

		-- Keybind метка (внизу справа)
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Text = keybind
		keyLabel.AnchorPoint = Vector2.new(1, 1)
		keyLabel.Position = UDim2.new(1, -4, 1, -4)
		keyLabel.Size = UDim2.new(0.35, 0, 0.35, 0)
		keyLabel.BackgroundTransparency = 1
		keyLabel.TextScaled = true
		keyLabel.TextColor3 = Color3.new(1, 1, 1)
		keyLabel.Parent = btn

		-- Кулдаун — маленькая полоска сверху кнопки
		local cooldownLabel = Instance.new("TextLabel")
		cooldownLabel.AnchorPoint = Vector2.new(0.5, 1)
		cooldownLabel.Position = UDim2.new(0.5, 0, 0, -3)
		cooldownLabel.Size = UDim2.new(1, 0, 0.3, 0)
		cooldownLabel.BackgroundTransparency = 1
		cooldownLabel.TextColor3 = Color3.new(1, 1, 1)
		cooldownLabel.TextScaled = true
		cooldownLabel.Text = "0"
		cooldownLabel.Parent = btn

		-- Cooldown value
		local cooldownValue = Instance.new("IntValue")
		cooldownValue.Name = "Cooldown"
		cooldownValue.Value = 0
		cooldownValue.Parent = btn

		-- CanUse
		local canUse = Instance.new("BoolValue")
		canUse.Name = "CanUse"
		canUse.Value = true
		canUse.Parent = btn

		-- Кнопка-способность скрыта (невидима)
		if visible == true then
			btn.BackgroundTransparency = 1
			stroke.Enabled = false
			UICorner:Destroy()
		end

		return btn, cooldownValue, cooldownLabel, canUse
	end

	-- Создаём кнопки
	local devour, devourCooldownValue, devourCooldownLabel, devourUsed = createButton("Devour", "Devour \n player", 0.01, 0.92, "E")
	local potato, potatoCooldownValue, potatoCooldownLabel, potatoUsed = createButton("Potato", "Potato", 0.01, 0.82, "Q",true,"rbxassetid://119671918485546",true)
	local burger, burgerCooldownValue, burgerCooldownLabel, burgerUsed = createButton("burger", "Burger", 0.01, 0.72, "B",true,"rbxassetid://119671918485546",true)
	if eda == 0 then
		burger.Visible = false
	else
		burger.Visible = true
	end
	edaevent.OnClientEvent:Connect(function()
		eda += 1
		if eda == 0 then
			burger.Visible = false
		else
			burger.Visible = true
		end
	end)
	-- Устанавливаем начальный кулдаун для способности пожирания
	devourUsed.Value = false
	devourCooldownValue.Value = 30
	devourCooldownLabel.Text = "30"
	
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local framelowheart = Instance.new("Frame")
	framelowheart.Visible = false
	framelowheart.Size = UDim2.new(1, 0, 1, 0)
	framelowheart.Position = UDim2.new(0, 0, 0, 0)
	framelowheart.BackgroundTransparency = 0.85
	framelowheart.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	framelowheart.Parent = gui
	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < 50 then
			framelowheart.Visible = true
		else
			framelowheart.Visible = false
		end
	end)
	
	-- Запускаем начальный отсчёт кулдауна
	coroutine.wrap(function()
		for i = 30, 0, -1 do
			task.wait(1)
			devourCooldownValue.Value = i
			devourCooldownLabel.Text = tostring(i)
			if i == 0 then
				devourUsed.Value = true
			end
		end
	end)()

	local isGlobalLocked = false -- флаг блокировки всех способностей

	local function activateAbility(button, cooldownValue, cooldownLabel, usedFlag, cooldownTime, serverName, lockTime, globalLockTime,animId)
		if isStunned then return false end
		if isGlobalLocked then return false end
		if not gui.Enabled or not button.Visible or cooldownValue.Value >= 1 or not usedFlag.Value then return false end

		-- включаем глобальный лок, если указан
		if globalLockTime and globalLockTime > 0 then
			isGlobalLocked = true
			task.delay(globalLockTime, function()
				isGlobalLocked = false
			end)
		end

		-- лок кнопки
		usedFlag.Value = false
		task.delay(lockTime or 1, function()
			usedFlag.Value = true
		end)

		-- сразу шлём на сервер
		event:FireServer(serverName)

		-- выставляем кулдаун моментально
		cooldownValue.Value = cooldownTime
		cooldownLabel.Text = tostring(cooldownTime)
		
		if animId and animId ~= "" then
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
				local abilityAnim = Instance.new("Animation")
				abilityAnim.AnimationId = animId
				local track = animator:LoadAnimation(abilityAnim)
				track:Play()
			end
		end
		
		-- запускаем отсчёт, но не ждём его
		coroutine.wrap(function()
			for i = cooldownTime - 1, 0, -1 do
				task.wait(1)
				cooldownValue.Value = i
				cooldownLabel.Text = tostring(i)
			end
		end)()

		return true
	end

	-- Функции для активации способностей
	local function doDevour()
		activateAbility(devour, devourCooldownValue, devourCooldownLabel, devourUsed, 50, "Devour", 1, 2.5)
	end

	local function doPotato()
		activateAbility(potato, potatoCooldownValue, potatoCooldownLabel, potatoUsed, 5, "potato_denis", 0, 0, "rbxassetid://127067863510699")
	end

	local function doBurger()
		if activateAbility(burger, burgerCooldownValue, burgerCooldownLabel, burgerUsed, 20, "burger_denis", 0, 0, "rbxassetid://127067863510699") then
			eda -= 1
			burger.Visible = eda > 0
		end
	end

	-- Привязка клавиатуры, мыши и геймпада
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not gui.Enabled then return end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.E then doDevour()
			elseif input.KeyCode == Enum.KeyCode.Q then doPotato()
			elseif input.KeyCode == Enum.KeyCode.B then doBurger()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			doDevour()
		end
	end)

	-- Экранные кнопки
	devour.MouseButton1Click:Connect(doDevour)
	potato.MouseButton1Click:Connect(doPotato)
	burger.MouseButton1Click:Connect(doBurger)
end

local function checkGuiConditions(character)
	local SurvivorsFolder = workspace.Players:FindFirstChild("Neutral")
	local boolVar = character and character:FindFirstChild("Denis")

	return SurvivorsFolder
		and character
		and character:IsDescendantOf(SurvivorsFolder)
		and boolVar
		and boolVar:IsA("BoolValue")
		and boolVar.Value == true
end

local function setupCharacter(character)
	character:WaitForChild("Humanoid")
	game:GetService("RunService").Heartbeat:Connect(function()
		if not player:FindFirstChild("PlayerGui"):FindFirstChild("DenisGui") then
			if checkGuiConditions(character) then
				DenisGui()
			end
		end
	end)
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)
