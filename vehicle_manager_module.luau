--[[
	This is a vehicle management module created by shawnjbragdon#0001.
	You may use this in your own work but you have to leave the credit.
	
	shawnjbragdon#0001
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local Autofarm = false

StarterGui:SetCore("SendNotification", {
	Title = "Notification",
	Text = "When using the autofarm, make sure your vehicle is in Drive or any gears following.",
	Duration = 30,
	Button1 = "Okay",
})

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
	LaunchAutofarm = function(self, MaximumSpeed)
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		local Vehicle, SeatPart = GetVehicle(Player)
		local Coordinate = SeatPart.Position
		pcall(function() Connection:Disconnect() end)
		Autofarm = true
		Connection = RunService.Stepped:Connect(function()
			if not Autofarm then
				Connection:Disconnect()
				return
			end
			Vehicle:SetPrimaryPartCFrame(CFrame.new(Coordinate))
			local MPH = (((10/12) * (60/88)) * SeatPart.Velocity.Magnitude)
			if MaximumSpeed ~= nil and MPH > MaximumSpeed then
				return
			elseif MPH > 350 then
				return
			end
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
		end)
		return true, "Successful."
	end,
	StopAutofarm = function(self)
		Autofarm = false
	end
}, {})

return VehicleManager
