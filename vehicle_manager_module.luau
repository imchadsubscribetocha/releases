--[[
	This is a vehicle management module created by shawnjbragdon#0001.
	You may use this in your own work but you have to leave the credit.
	
	shawnjbragdon#0001
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Autofarm = false

local function GetVehicle(Player)
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	local SeatPart = Humanoid.SeatPart
	for index, value in pairs({"Wheels", "Core", "Body", "Misc"}) do
		if SeatPart:FindFirstAncestor(value) ~= nil then
			SeatPart.Parent = SeatPart:FindFirstAncestor(value).Parent
		end
	end
	local Vehicle = SeatPart.Parent
	local IsAVehicle = false
	for index, value in pairs(Vehicle:GetDescendants()) do
		if value:IsA("VehicleSeat") then
			IsAVehicle = true
		end
	end
	if not Vehicle.PrimaryPart then
		Vehicle.PrimaryPart = SeatPart
	end
	return (IsAVehicle == true and Vehicle) or nil, SeatPart
end

local function MoveVehicle(Player, Position)
	local Vehicle, SeatPart = GetVehicle(Player)
	Player.Character.Parent = Vehicle
	if typeof(Position) == "Vector3" then
		Vehicle:MoveTo(Position)
	elseif typeof(Position) == "CFrame" then
		Vehicle:SetPrimaryPartCFrame(Position)
	end
	Player.Character.Parent = workspace
	return true, "Successful."
end

local function LookAt(target, eye)
	local forwardVector = (eye - target).Unit
	local upVector = Vector3.new(0, 1, 0)
	local rightVector = forwardVector:Cross(upVector)
	local upVector2 = rightVector:Cross(forwardVector)

	return CFrame.fromMatrix(eye, rightVector, upVector2)
end

local VehicleManager = setmetatable({
	GetPlayerVehicle = function(self, Player)
		return GetVehicle(Player)
	end,
	MovePlayerVehicle = function(self, Player, Position)
		return MoveVehicle(Player, Position)
	end,
	GetPlayerInVehicleStatus = function(self, Player)
		local Character = Player.Character
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		local SeatPart = Humanoid.SeatPart
		
		for index, value in pairs({"Wheels", "Core", "Body", "Misc"}) do
			if SeatPart:FindFirstAncestor(value) ~= nil then
				SeatPart.Parent = SeatPart:FindFirstAncestor(value).Parent
			end
		end

		local Vehicle = SeatPart.Parent
		local IsAVehicle = false

		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("VehicleSeat") then
				IsAVehicle = true
			end
		end
		
		return true, string.format("%s is driving.", Player.Name)
	end,
	LaunchAutofarm = function(self, Start, Finish, CustomDirectionVector, MaximumSpeed)
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		local Vehicle, SeatPart = GetVehicle(Player)
		local DirectionVector = (Start - Finish).Unit
		local Distance = (Start - Finish).Magnitude
		if CustomDirectionVector ~= nil and typeof(CustomDirectionVector) == "Vector3" then
			DirectionVector = CustomDirectionVector
		end
		pcall(function() Connection:Disconnect() end)
		Autofarm = true
		MoveVehicle(Player, Start)
		Connection = RunService.Stepped:Connect(function()
			if not Autofarm then
				Connection:Disconnect()
				return
			end
			if (Start - SeatPart.Position).Magnitude > Distance then
				MoveVehicle(Player, Start)
			end
			Vehicle:SetPrimaryPartCFrame(LookAt(Finish * 2, SeatPart.Position) * CFrame.Angles(0, math.rad(180), 0))
			if MaximumSpeed ~= nil then
				local MPH = ((10/12) * (60/88)) * SeatPart.Velocity.Magnitude
				if (SeatPart.Velocity.Magnitude * Vector3.new(1, 0, 1)) < MPH then
					return
				end
			end
			if RunService:IsStudio() then
				-- VirtualInputManager is not writable in studio.
			else
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
			end
		end)
		return true, "Successful."
	end,
	StopAutofarm = function(self)
		Autofarm = false
	end
}, {})

return VehicleManager
