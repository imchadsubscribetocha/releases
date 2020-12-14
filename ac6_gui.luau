local S = setmetatable({}, {__index = function(self, index) return game:GetService(index) end, __newindex = function(self, index, value) game[index] = value end})

local ScreenGui
local Frame

local BindableFunction = Instance.new("BindableFunction")
BindableFunction.Name = "BindableFunction"
BindableFunction.OnInvoke = function()
	if not setclipboard then
		S.StarterGui:SetCore("SendNotification", {
			Title = "Notification",
			Text = "Could not copy the Discord link because you don\'t have \'setclipboard\' on your exploit.",
			Button1 = "Okay",
		})
		return
	end
	return setclipboard("https://discord.gg/yxBRdKkNVJ")
end

S.StarterGui:SetCore("SendNotification", {
	Title = "Notification",
	Text = "Would you like to copy my Discord server link?",
	Button1 = "Yes",
	Button2 = "No",
	Callback = BindableFunction,
})

if S.RunService:IsStudio() then
	ScreenGui = script:FindFirstAncestorWhichIsA("ScreenGui")
	pcall(function() ScreenGui.Parent = S.CoreGui end)
else
	local Model = game:GetObjects("rbxassetid://6075692865")
	ScreenGui = Model[1]:Clone()
	for index, value in pairs(ScreenGui:GetDescendants()) do
		if value:IsA("Script") then
			value:Destroy()
		end
	end
	ScreenGui.Parent = S.CoreGui
end

Frame = ScreenGui:FindFirstChildWhichIsA("Frame")

local Values = {
	["MaxSpeed"] = 300,
	["SpeedUpKeybind"] = Enum.KeyCode.LeftShift,
	["TeleportKeybind"] = Enum.KeyCode.T,
	["StopVehicleKeybind"] = Enum.KeyCode.One,
}

local LocalPlayer = S.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GPEService = {}

coroutine.resume(coroutine.create(function()
	-- \\ taken from roblox admin post LOLOLOL
	local UserInputService = game:GetService("UserInputService")

	local gui = Frame

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end))

coroutine.resume(coroutine.create(function()
	-- \\ GPEService built-into the script.
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	if RunService:IsServer() then
		return error("GPEService is a client-only module.")
	end

	GPEService.KeysPressed = {}

	UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
		if gameProcessedEvent == true then
			return
		end
		if not table.find(GPEService.KeysPressed, inputObject.KeyCode) then
			table.insert(GPEService.KeysPressed, inputObject.KeyCode)
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		for index,value in pairs(GPEService.KeysPressed) do
			if value == inputObject.KeyCode then
				table.remove(GPEService.KeysPressed, table.find(GPEService.KeysPressed, value))
			end
		end
	end)

	function GPEService:IsProcessedKeyDown(KeyCode)
		return table.find(GPEService.KeysPressed, KeyCode) ~= nil
	end
end))

local CurrentVehicle
local SeatPart

local function CheckCondition()
	local success, response = pcall(function()
		return CurrentVehicle and SeatPart and LocalPlayer and LocalPlayer.Character and LocalPlayer.Humanoid
	end)
	return response == true
end

local function GetSeatVelocity()
	return SeatPart.Velocity, SeatPart.RotVelocity
end

local function GetWheelVelocity()
	local Wheels = CurrentVehicle:FindFirstChild("Wheels") or CurrentVehicle:FindFirstChild("Core")
	return Wheels["FL"].Velocity, Wheels["FL"].RotVelocity
end

local function SetWheelVelocity(Velocity, RotVelocity)
	local Wheels = CurrentVehicle:FindFirstChild("Wheels") or CurrentVehicle:FindFirstChild("Core")
	for index, value in pairs(Wheels:GetDescendants()) do
		pcall(function()
			value.Velocity = Velocity
			if RotVelocity ~= nil then
				value.RotVelocity = RotVelocity
			end
		end)
	end
end

local function TeleportVehicle(Position)
	-- \\ Will only accept Vector3 because many vehicles don't have a PrimaryPart.
	-- \\ Feel free to use this. ~ shawnjbragdon
	if LocalPlayer.Character.Humanoid.SeatPart:IsDescendantOf(CurrentVehicle) and GetWheelVelocity() ~= nil then
		LocalPlayer.Character.Parent = CurrentVehicle
		CurrentVehicle:MoveTo(Position)
		LocalPlayer.Character.Parent = workspace
	end
end

local function GetKeyCode(inf)
	if typeof(inf) == "string" then
		for index, value in pairs(Enum.KeyCode:GetEnumItems()) do
			if value.Name == inf then
				return value
			end
		end
	elseif typeof(inf) == "number" then
		for index, value in pairs(Enum.KeyCode:GetEnumItems()) do
			if value.Value == inf then
				return value
			end
		end
	end
	return Enum.KeyCode[inf]
end

Frame.Confirmation.MouseButton1Click:Connect(function()
	local success, response = pcall(function()
		Values["SpeedUpKeybind"] = GetKeyCode(Frame.SpeedUpKeybind:FindFirstChildWhichIsA("TextBox").Text)
		Values["TeleportKeybind"] = GetKeyCode(Frame.TeleportKeybind:FindFirstChildWhichIsA("TextBox").Text)
		Values["StopVehicleKeybind"] = GetKeyCode(Frame.StopVehicleKeybind:FindFirstChildWhichIsA("TextBox").Text)
		-- the issue was right fucking here bruh im so blind but it is fixed lol
		Values["MaxSpeed"] = tonumber(Frame.MaxSpeed:FindFirstChildWhichIsA("TextBox").Text)
		return true
	end)
	if not success then
		warn(response)
	else
		print("CONFIRMATION WORKED LOL WHAT THE FUCK bruh here is this: " .. tostring(response))
	end
end)

S.UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
	if inputObject.KeyCode == Values["StopVehicleKeybind"] and gameProcessedEvent == false then
		for index, value in pairs(CurrentVehicle:GetDescendants()) do
			if value:IsA("BasePart") then
				S.TweenService:Create(value, TweenInfo.new(0.3), {
					Velocity = Vector3.new(0, 0, 0),
					RotVelocity = Vector3.new(0, 0, 0),
				}):Play()
			end
		end
	elseif inputObject.KeyCode == Values.TeleportKeybind and gameProcessedEvent == false then
		TeleportVehicle(Mouse.Hit.Position + Vector3.new(0, 4, 0))
	end
end)

S.RunService.Stepped:Connect(function(deltaTime)
	pcall(function()
		local Character = LocalPlayer.Character ~= nil and LocalPlayer.Character:IsDescendantOf(workspace) and LocalPlayer.Character
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		SeatPart = Humanoid.SeatPart ~= nil and Humanoid.SeatPart
		CurrentVehicle = (not table.find({"misc", "wheels", "body"}, string.lower(SeatPart.Parent.Name)) and SeatPart.Parent) or SeatPart.Parent.Parent
	end)
	local s, r = pcall(function()
		local MPH = ((10/12) * (60/88)) * SeatPart.Velocity.Magnitude
		if GPEService:IsProcessedKeyDown(Values["SpeedUpKeybind"]) == true then
			spawn(function()
				if MPH > Values["MaxSpeed"] then
					return
				end
				local WV, WRV = GetSeatVelocity()
				SetWheelVelocity(WV * Vector3.new(1.2, 1, 1.2))
			end)
		end
		S.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	if not s then S.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) warn(r) end
end)
