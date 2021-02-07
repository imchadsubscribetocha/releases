--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

--[[
	This script was created by shawnjbragdon#0001.
	If you are going to re-release this, please leave the credit.
	
	https://v3rmillion.net/member.php?action=profile&uid=1870134
	https://forum.robloxscripts.com/user-shawnjbragdon
	
	This script was made using Synapse X.
]]

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");
local RunService = game:GetService("RunService");
local StarterPlayer = game:GetService("StarterPlayer");
local TestService = game:GetService("TestService");
local VirtualUser = game:GetService("VirtualUser");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local WallyLibraryV2 = (RunService:IsStudio() and require(script:WaitForChild("WallyLibraryV2"))) or loadstring(game:HttpGet("https://raw.githubusercontent.com/Luminential/releases/main/wallyhub_modified.luau", true))();
local GPEService = (RunService:IsStudio() and require(script:WaitForChild("GPEService"))) or loadstring(game:HttpGet("https://raw.githubusercontent.com/Luminential/releases/main/gpeservice.luau", true))();

default = {
	topcolor = Color3.fromRGB(30, 30, 30);
	titlecolor = Color3.fromRGB(255, 255, 255);
	underlinecolor = Color3.fromRGB(255, 0, 0);
	bgcolor = Color3.fromRGB(35, 35, 35);
	boxcolor = Color3.fromRGB(35, 35, 35);
	btncolor = Color3.fromRGB(25, 25, 25);
	dropcolor = Color3.fromRGB(25, 25, 25);
	sectncolor = Color3.fromRGB(25, 25, 25);
	bordercolor = Color3.fromRGB(60, 60, 60);
	font = Enum.Font.Jura;
	titlefont = Enum.Font.Michroma;
	fontsize = 17;
	titlesize = 18;
	textstroke = 1;
	titlestroke = 1;
	strokecolor = Color3.fromRGB(0, 0, 0);
	textcolor = Color3.fromRGB(255, 255, 255);
	titletextcolor = Color3.fromRGB(255, 255, 255);
	placeholdercolor = Color3.fromRGB(255, 255, 255);
	titlestrokecolor = Color3.fromRGB(0, 0, 0);
};

WallyLibraryV2["options"] = setmetatable({}, {__index = default})

pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Luminential/releases/main/updated_credit_script", true))() end)

local LocalPlayer = Players.LocalPlayer
local S, CoreGui = pcall(function() return game:GetService("CoreGui") end)
local PlayerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")

local function GetVehicle(VehicleSeat)
	if table.find({1636712, --[[4148343 Urban Patrol?]]}, game.PlaceId) then
		local Character = LocalPlayer.Character
		local Model = Character:FindFirstChildWhichIsA("Model")
		return Model
	elseif table.find({4924922222}, game.PlaceId) then
		local VehicleFolder = workspace:WaitForChild("Vehicles")
		local VehicleContainer = VehicleFolder:WaitForChild(string.format("%sCar", LocalPlayer.Name))
		return VehicleContainer:FindFirstChildWhichIsA("Model")
	elseif table.find({4410049285}, game.PlaceId) then
		if workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA("BasePart") then
			return workspace.CurrentCamera.CameraSubject.Parent
		end
	else
		local Model = VehicleSeat:FindFirstAncestorWhichIsA("Model")
		for index, value in pairs({
			"Wheels",
			"Body",
			"Misc",
			"Core",
		}) do
			if Model:FindFirstAncestor(value) then
				Model = Model.Parent
			end
		end
		return Model
	end
	return
end

local function GetWheels(Vehicle)
	local Wheels = {};
	if table.find({1636712, --[[4148343 Urban Patrol?]]}, game.PlaceId) then
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value and value:IsA("BasePart") and table.find({
				"FLSteerWheel",
				"FRSteerWheel",
				"RLWheel",
				"RRWheel",
				"RLDouble",
				"RLDouble2",
				"RRDouble",
				"RRDouble2",
			}) then
				table.insert(Wheels, value)
			end
		end
	elseif table.find({4924922222}, game.PlaceId) then
		for index, value in pairs({
			"WheelFL",
			"WheelFR",
			"WheelBL",
			"WheelBR",
		}) do
			for _, BasePart in pairs(Vehicle:GetDescendants()) do
				if BasePart:FindFirstAncestor(value) then
					table.insert(Wheels, value)
				end
			end
		end
	elseif table.find({4410049285}, game.PlaceId) then
		local WheelsFolder = Vehicle:WaitForChild("Wheels")
		if WheelsFolder and WheelsFolder:IsA("Folder") then
			for _, BasePart in pairs(WheelsFolder:GetDescendants()) do
				if BasePart:IsA("BasePart") then
					table.insert(Wheels, BasePart)
				end
			end
		end
	else
		if Vehicle:FindFirstChild("Wheels") then
			for index, value in pairs(Vehicle["Wheels"]:GetDescendants()) do
				if value:IsA("BasePart") then
					table.insert(Wheels, value)
				end
			end
		elseif Vehicle:FindFirstChild("Core") then
			for index, value in pairs(Vehicle["Core"]:GetDescendants()) do
				if value:IsA("BasePart") then
					table.insert(Wheels, value)
				end
			end
		end
	end
	return Wheels
end

local Windows = {
	WallyLibraryV2:CreateWindow("AC6 Fucker", {["Parent"] = PlayerGui});
};

if game.PlaceId == 4924922222 then
	Slider = Windows[1]:Slider("Speed", {["flag"] = "max_speed", ["min"] = 25, ["max"] = 400}); Slider:Set(200)
	Toggle = Windows[1]:Toggle("Rainbow Car", {["flag"] = "bh_rainbowcar"})
	
	local HSV = Color3.fromRGB(1, 1, 1)
	local HUE = 0
	local SATURATION = 1
	local VALUE = 0.85
	
	RunService.RenderStepped:Connect(function()
		pcall(function()
			HUE = HUE + (1 / 100);
			if HUE > 1 then HUE = 0; end
			HSV = Color3.fromHSV(HUE, 1, 0.85)

			if Windows[1] and Windows[1]["flags"] then
				local flags = Windows[1]["flags"];
				if flags["max_speed"] then 
					LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").SeatPart.TopSpeed.Value = flags["max_speed"];
				end
				if flags["bh_rainbowcar"] == true then
					ReplicatedStorage.RemoteEvents.PlayersCar:FireServer(
						"PickingCarColor",
						{
							["Value"] = BrickColor.new(HSV).Color
						}
					)
				end
			end
		end)
	end)
else
	Slider			= Windows[1]:Slider("Accel.", {["flag"] = "acceleration", ["min"] = 0, ["max"] = 20}) Slider:Set(10)
	Slider			= Windows[1]:Slider("Speed", {["flag"] = "max_speed", ["min"] = 50, ["max"] = 800}); Slider:Set(400)
	TextBox			= Windows[1]:Box("KeyCode", {["flag"] = "activation_key"}, function(value)
		for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
			if string.lower(value) == string.lower(EnumItem.Name) then
				TextBox.Text = EnumItem.Name;
				Windows[1]["flags"]["activation_key"] = EnumItem;
				return;
			end;
		end;
		for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
			if string.lower(value) == string.lower(string.sub(EnumItem.Name, 1, string.len(value))) then
				TextBox.Text = EnumItem.Name;
				Windows[1]["flags"]["activation_key"] = EnumItem;
				return;
			end;
		end;
		TextBox.Text = "LeftShift";
		Windows[1]["flags"]["activation_key"] = Enum.KeyCode.LeftShift;
	end);

	TextBox.Text	= "LeftShift"; Windows[1]["flags"]["activation_key"] = Enum.KeyCode.LeftShift;

	Slider = Windows[1]:Slider("Brake Force", {["flag"] = "brake_force", ["min"] = 0, ["max"] = 100}); Slider:Set(20)
	TextBox2 = Windows[1]:Box("KeyCode", {["flag"] = "brake_key"}, function(value)
		for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
			if string.lower(value) == string.lower(EnumItem.Name) then
				TextBox2.Text = EnumItem.Name;
				Windows[1]["flags"]["brake_key"] = EnumItem;
				return;
			end;
		end;
		for _, EnumItem in pairs(Enum.KeyCode:GetEnumItems()) do
			if string.lower(value) == string.lower(string.sub(EnumItem.Name, 1, string.len(value))) then
				TextBox2.Text = EnumItem.Name;
				Windows[1]["flags"]["brake_key"] = EnumItem;
				return
			end;
		end;
		TextBox2.Text = "S";
		Windows[1]["flags"]["brake_key"] = Enum.KeyCode.S;
	end);

	TextBox2.Text = "S"; Windows[1]["flags"]["brake_key"] = Enum.KeyCode.S;

	Button			= Windows[1]:Button("Stop Vehicle", function()
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("BasePart") then
				TweenService:Create(value, TweenInfo.new(0.25), {
					["Velocity"] = Vector3.new(0, 0, 0);
					["RotVelocity"] = Vector3.new(0, 0, 0)
				}):Play();
			end;
		end;
	end)
	Button = Windows[1]:Button("Massless", function()
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("BasePart") then
				value.Massless = true;
			end;
		end;
	end)
	Button = Windows[1]:Button("Weightless", function()
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("BasePart") and value.Name == "#Weight" then
				value:Destroy()
			end;
		end;
	end)
	Button = Windows[1]:Button("No Hitbox", function()
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("BasePart") and table.find({"hitbox", "#hitbox"}, string.lower(value.Name)) then
				value:Destroy()
			end;
		end;
	end)
	Toggle			= Windows[1]:Toggle("(L) RotVelocity", {["flag"] = "limited_rotation_velocity"})
	Toggle			= Windows[1]:Toggle("Click-TP Car", {["flag"] = "clicktp_car"})
	Section			= Windows[1]:Section("Springs (Experimental)");
	Box				= Windows[1]:Box("Height", {}, function(number)
		if tonumber(number) then
			number = tonumber(number);
			local Character = LocalPlayer.Character;
			local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
			local VehicleSeat = Humanoid.SeatPart;
			local Vehicle = GetVehicle(VehicleSeat)
			for index, value in pairs(Vehicle:GetDescendants()) do
				if value:IsA("SpringConstraint") then
					TweenService:Create(value, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {["MaxLength"] = number + 2;["MinLength"] = number;}):Play();
				end;
			end;
		end;
	end)
	Box				= Windows[1]:Box("Stiffness", {}, function(number) if tonumber(number) then number = tonumber(number); local Character = LocalPlayer.Character; local Humanoid = Character:FindFirstChildWhichIsA("Humanoid"); local VehicleSeat = Humanoid.SeatPart; local Vehicle = VehicleSeat:FindFirstAncestorWhichIsA("Model"); if table.find({"wheels", "body", "misc", "core"}, Vehicle.Name) then Vehicle = Vehicle.Parent; end; for index, value in pairs(Vehicle:GetDescendants()) do if value:IsA("SpringConstraint") then TweenService:Create(value, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {["Stiffness"] = number}):Play(); end; end; end; end)
	Toggle			= Windows[1]:Toggle("Visible", {}, function(boolean)
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("SpringConstraint") then
				value.Visible = boolean == true;
			end;
		end;
	end)
	Toggle			= Windows[1]:Toggle("Limited", {}, function(boolean)
		local Character = LocalPlayer.Character;
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
		local VehicleSeat = Humanoid.SeatPart;
		local Vehicle = GetVehicle(VehicleSeat);
		for index, value in pairs(Vehicle:GetDescendants()) do
			if value:IsA("SpringConstraint") then
				value.LimitsEnabled = boolean == true;
			end;
		end;
	end)
	if game.PlaceId == 5232896677 then
		Section		= Windows[1]:Section("Wheels (Experimental)")
		Box			= Windows[1]:Box("+X DIST", {}, function(number) local Character = LocalPlayer.Character; local Humanoid = Character:FindFirstChildWhichIsA("Humanoid"); local VehicleSeat = Humanoid.SeatPart; local Vehicle = VehicleSeat:FindFirstAncestorWhichIsA("Model"); if table.find({"wheels", "body", "misc", "core"}, Vehicle.Name) then Vehicle = Vehicle.Parent; end; for index, value in pairs(Vehicle:GetDescendants()) do if value:IsA("Weld") and value.Name == "Weld" and value:FindFirstAncestor("#SB") then value.C0 = value.C0 * CFrame.new(number, 0, 0); end; end; end)
		Box			= Windows[1]:Box("+Y DIST", {}, function(number) local Character = LocalPlayer.Character; local Humanoid = Character:FindFirstChildWhichIsA("Humanoid"); local VehicleSeat = Humanoid.SeatPart; local Vehicle = VehicleSeat:FindFirstAncestorWhichIsA("Model"); if table.find({"wheels", "body", "misc", "core"}, Vehicle.Name) then Vehicle = Vehicle.Parent; end; for index, value in pairs(Vehicle:GetDescendants()) do if value:IsA("Weld") and value.Name == "Weld" and value:FindFirstAncestor("#SB") then value.C0 = value.C0 * CFrame.new(0, number, 0); end; end; end)
		Box			= Windows[1]:Box("+Z DIST", {}, function(number) local Character = LocalPlayer.Character; local Humanoid = Character:FindFirstChildWhichIsA("Humanoid"); local VehicleSeat = Humanoid.SeatPart; local Vehicle = VehicleSeat:FindFirstAncestorWhichIsA("Model"); if table.find({"wheels", "body", "misc", "core"}, Vehicle.Name) then Vehicle = Vehicle.Parent; end; for index, value in pairs(Vehicle:GetDescendants()) do if value:IsA("Weld") and value.Name == "Weld" and value:FindFirstAncestor("#SB") then if value:FindFirstAncestor("FL") or value:FindFirstAncestor("RL") then value.C0 = value.C0 * CFrame.new(0, 0, number); elseif value:FindFirstAncestor("FR") or value:FindFirstAncestor("RR") then value.C0 = value.C0 * CFrame.new(0, 0, -number); end; end; end; end)
		Box			= Windows[1]:Button("Reset Wheels", function(number) local Character = LocalPlayer.Character; local Humanoid = Character:FindFirstChildWhichIsA("Humanoid"); local VehicleSeat = Humanoid.SeatPart; local Vehicle = VehicleSeat:FindFirstAncestorWhichIsA("Model"); if table.find({"wheels", "body", "misc", "core"}, Vehicle.Name) then Vehicle = Vehicle.Parent; end; for index, value in pairs(Vehicle:GetDescendants()) do if value:IsA("Weld") and value.Name == "Weld" and value:FindFirstAncestor("#SB") then TweenService:Create(value, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0), {C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))}):Play(); end; end; end)
	end
end

if not RunService:IsStudio() then
	workspace.FallenPartsDestroyHeight = -1e6;
end;

local PlayerMouse = LocalPlayer:GetMouse()

UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
	if gameProcessedEvent == false and inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
		pcall(function()
			if Windows[1]["flags"]["clicktp_car"] then
				if not PlayerMouse.Target then
					return;
				end;
				local Character = LocalPlayer.Character;
				local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
				local VehicleSeat = Humanoid.SeatPart;
				local Vehicle = GetVehicle(VehicleSeat);
				if game.PlaceId == 4410049285 then
					Vehicle:MoveTo(PlayerMouse.Hit.Position);
				else
					Character.Parent = Vehicle;
					Vehicle:MoveTo(PlayerMouse.Hit.Position);
					Character.Parent = workspace;
				end
			end;
		end);
	end;
end)


RunService.Stepped:Connect(function()
	if Windows[1] and Windows[1]["flags"] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").SeatPart then
		local flags = Windows[1]["flags"];
		local Vehicle = GetVehicle(LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").SeatPart)
		local Wheels = GetWheels(Vehicle);
		
		if UserInputService:IsKeyDown(flags["activation_key"]) then 
			for index, value in pairs(Wheels) do
				if value and typeof(value) == "Instance" and value:IsA("BasePart") and flags["max_speed"] > value.Velocity.Magnitude then
					if flags["acceleration"] and flags["acceleration"] == true then
						local accel = (1 + (flags["acceleration"] / 100));
						value.Velocity = value.Velocity * Vector3.new(accel, 1, accel)
						print("Set velocity successfully!")
					else
						value.Velocity = value.Velocity * Vector3.new(1.1, 0.95, 1.1)
					end
					if flags["limited_rotation_velocity"] and flags["limited_rotation_velocity"] == true then
						local X = value.RotVelocity.X;
						local Y = value.RotVelocity.Y;
						local Z = value.RotVelocity.Z;
						local rotation_maxvelocity = 50;

						if X > rotation_maxvelocity then X = rotation_maxvelocity; end;
						if Y > rotation_maxvelocity then Y = rotation_maxvelocity; end;
						if Z > rotation_maxvelocity then Z = rotation_maxvelocity; end;
					end
				end
			end
		elseif UserInputService:IsKeyDown(flags["brake_key"]) then
			for index, value in pairs(Wheels) do
				if value and typeof(value) == "Instance" and value:IsA("BasePart") then
					if flags["brake_force"] and flags["brake_force"] == true then
						local brakeforce = (1 - (flags["brake_force"] / 100));
						value.Velocity = value.Velocity * Vector3.new(brakeforce, 1, brakeforce)
						print("Set velocity successfully!")
					else
						value.Velocity = value.Velocity * Vector3.new(0.5, 0.95, 0.5)
					end
					if flags["limited_rotation_velocity"] and flags["limited_rotation_velocity"] == true then
						local X = value.RotVelocity.X * 10;
						local Y = value.RotVelocity.Y * 10;
						local Z = value.RotVelocity.Z * 10;
						local rotation_maxvelocity = 50;

						if X > rotation_maxvelocity then X = rotation_maxvelocity; end;
						if Y > rotation_maxvelocity then Y = rotation_maxvelocity; end;
						if Z > rotation_maxvelocity then Z = rotation_maxvelocity; end;
						
						value.RotVelocity = Vector3.new(X / 10, Y / 10, Z / 10)
					end
				end
			end
		end
	end
end)
