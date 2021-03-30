-- If you have any intentions of reading this code, I advise you don't... If you do, bring eye bleach, because I assure you it's the worst programming you'll ever see. Even Ubisoft can optimize better than this. I have improved *immensely* since I made this.

local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')

local LocalPlayer = Players.LocalPlayer
local Studio = RunService:IsStudio()
local ScreenGui = nil

local GameSenseStatusItems = setmetatable({
	["GetStatusItems"] = function(self, ...)
		local items = {}
		for _, value in pairs(self) do
			if value and table.find({"number", "string"}, string.lower(typeof(value))) then
				table.insert(items, value)
			end
		end
		return items
	end ;
	[1] = "AimingActive" ;
	[2] = "TriggerBotActive" ;
	[3] = "PathFindingActive" ;
	[4] = "AimAware" ;
	[5] = "Disabled" ;
	[6] = "" ;
}, {})

local GameSenseConfiguration = setmetatable({
	["Personalization"] = {
		["Sounds"] = {
			["LockOn"] = 538769304 ;
		} ;
		["MouseIcons"] = {
			["Default"] = 18671553 ;
		} ;
		["PerformanceMode"] = false ;
		["DisplayDistance"] = true ;
		["DropPredictionIntensity"] = 0.45 ;
		["FieldOfView"] = 4.5 ;
	} ;
	["AimBot"] = {
		["Enabled"] = true ;
		["Active"] = false ;
	} ;
	["TriggerBot"] = {
		["Enabled"] = true ;
		["Active"] = false ;
		["Delay"] = 0.2 ;
	} ;
	["ESP"] = {
		["Chams"] = {
			["Enabled"] = false ;
		} ;
		["Tracers"] = {
			["Enabled"] = false ;
		} ;
	} ;
	["GetStatus"] = function(self)
		if self.CurrentStatus ~= nil then
			return self.CurrentStatus
		end
		if self.AimBot and self.AimBot.Active == true then
			return GameSenseStatusItems[1]
		elseif self.TriggerBot and self.TriggerBot.Active == true then
			return GameSenseStatusItems[2]
		elseif self.PathFinding and self.PathFinding.Active == true then
			return GameSenseStatusItems[3]
		end
	end ;

}, {
	["__call"] = function(self, ...)
		return {
			["Version"] = "1.25 (RW)" ;
			["ScreenGui"] = ScreenGui ;
		}
	end ;
})

local Mouse = LocalPlayer:GetMouse()
local old_icon = Mouse.Icon
local targetpart = 'Head'
local target
local lockedon = false
local settingkey = false
local upvals = nil
local val = 1
local windows = {}

Mouse.TargetFilter = workspace.CurrentCamera

local toggle_aimbot = Enum.KeyCode.LeftAlt
local toggle_trigger = Enum.KeyCode.RightAlt
local toggle_esp = Enum.KeyCode.End
local ffatoggle = Enum.KeyCode.Home
local targetpart_change = Enum.KeyCode.BackSlash
local priority_toggle = Enum.KeyCode.Insert
local sethotkey = Enum.KeyCode.RightControl
-- aim GameSenseConfiguration.Personalization.FieldOfView
local fov_increase = Enum.KeyCode.KeypadPlus
local fov_decrease = Enum.KeyCode.KeypadMinus
-- aim sens (how smooth your crosshair will move)
local sens_increase = Enum.KeyCode.RightBracket
local sens_decrease = Enum.KeyCode.LeftBracket

-- parts
local parts = {
	'Head';
	'Torso'
}

local fonts = {
	Enum.Font.SourceSansBold,
	Enum.Font.Cartoon,
	Enum.Font.Arcade,
	Enum.Font.SciFi,
	Enum.Font.Fantasy,
	Enum.Font.Code,
	Enum.Font.Highway,
	Enum.Font.Bodoni
}

local textSet = false

local currentfont = 1
local ffa = false
local hidden = false
-- aim
local sens = 0.25
local aim_toggled, bottompos, aim_priority = false, true, 2
-- [2] FOV or [1] Distance
local aimingcolor =Color3.fromRGB(0, 128, 255)
local aimbot_toggled = true
local aim_line = true
local mouseiconid =  18671553

-- trigger

-- esp
local esp_toggled = true
local esp_bones = false
local esp_chams = true
local esp_tracers = true
-- item_esp (coming soon)
local linesize = 1
local showdists = true
local textsize = 14
local textoffset = 20
local visiblecolor = Color3.fromRGB(38,255,99)
local hiddencolor = Color3.fromRGB(255,37,40)
local headboxsize = 4
local headboxaimsize = 6
local headboxshape = 'diamond'
-- rectangle or diamond

-- box esp
local bounding_box = true
-- box_pointsize = 0 [UNUSED]
local box_line_size = 1
-- box_line_size_visible = 2 [UNUSED]

local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = "GameSense 1.25"
ScreenGui.ResetOnSpawn = false
_, ScreenGui.Parent = pcall(game.GetService, game, "CoreGui") or nil, LocalPlayer:FindFirstChildWhichIsA("PlayerGui")

local ESP = Instance.new('Folder')
ESP.Name = "ESP"
ESP.Parent = ScreenGui

local Bottom = Instance.new("Frame")
Bottom.Name = "Bottom"
Bottom.BackgroundTransparency = 1
Bottom.Size = UDim2.new(0, 1, 0, 1)
Bottom.Position = UDim2.new(0.5, 0, 1, 1)
Bottom.Parent = ESP

local Status = Instance.new('TextLabel',ScreenGui)
Status.Name = 'Status'
Status.BackgroundTransparency = 1
Status.Size = UDim2.new(0,500,0,50)
Status.Position = UDim2.new(.5,-250,.85,0)
Status.TextSize = 24
Status.Font = Enum.Font.SourceSansBold
Status.TextColor3 = Color3.new(1,1,1)
Status.TextStrokeColor3 = Color3.new(0,0,0)
Status.TextStrokeTransparency = .6
Status.Text = 'On Standby'
Status.ZIndex = 50

local Credits = Status:Clone()
Credits.Name = 'Credits'
Credits.Parent = ScreenGui
Credits.Position = UDim2.new(.5,-250,.85,-20)
Credits.TextSize = 16
Credits.Text = 'GameSense 1.25 by Avexus!'

local FovGui = Instance.new("ImageLabel")
FovGui.Name = "FovGui"
FovGui.AnchorPoint = Vector2.new(0.5, 0.5)
FovGui.Image = "rbxassetid://324848180"
FovGui.Size = UDim2.new(0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2)
FovGui.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
FovGui.BackgroundTransparency = 1
FovGui.ImageTransparency = 0.9
FovGui.ImageColor3 = Color3.fromRGB(255, 64, 64)
FovGui.ScaleType = Enum.ScaleType.Fit
FovGui.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Active = false
TextLabel.AnchorPoint = Vector2.new(0, 0)
TextLabel.AutoLocalize = Enum.AutomaticSize.None
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderMode = Enum.BorderMode.Outline
TextLabel.BorderSizePixel = 0
TextLabel.LayoutOrder = 6
TextLabel.Name = "Indicator"
TextLabel.Parent = FovGui
TextLabel.Position = UDim2.new(0.5, 0, 0.75, 0)
TextLabel.Rotation = 0
TextLabel.Selectable = false
TextLabel.Size = UDim2.new(0, 0, 0, 0)
TextLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY
TextLabel.Visible = true
TextLabel.ZIndex = 1
TextLabel.Archivable = false
TextLabel.ClipsDescendants = false
TextLabel.Font = Enum.Font.SourceSans
TextLabel.LineHeight = 1
TextLabel.MaxVisibleGraphemes = -1
TextLabel.RichText = false
TextLabel.Text = "{AimPriority}\n{Sensitivity}"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = false
TextLabel.TextSize = 14
TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextStrokeTransparency = 0.75
TextLabel.TextTransparency = 0
TextLabel.TextTruncate = Enum.TextTruncate.None
TextLabel.TextWrapped = false
TextLabel.TextXAlignment = Enum.TextXAlignment.Center
TextLabel.TextYAlignment = Enum.TextYAlignment.Center
TextLabel.AutoLocalize = false
local Indicator = TextLabel

local SensAdjust = Instance.new('TextBox')
SensAdjust.Name = 'SensAdjust'
SensAdjust.Font = Enum.Font.SourceSans
SensAdjust.BackgroundTransparency = .75
SensAdjust.BackgroundColor3 = Color3.new(0,0,0)
SensAdjust.BorderColor3 = Color3.new(1,1,1)
SensAdjust.Size = UDim2.new(0,50,0,20)
SensAdjust.TextStrokeTransparency = .6
SensAdjust.TextColor3 = Color3.new(1,1,1)
SensAdjust.TextSize = 14
SensAdjust.PlaceholderText = 'Sens'
SensAdjust.Text = tonumber(sens)
SensAdjust.Position = Credits.Position + UDim2.new(0,250,0,75)
SensAdjust.Parent = ScreenGui

local SensLabel = Instance.new('TextLabel')
SensLabel.Name = 'SensLabel'
SensLabel.Font = Enum.Font.SourceSans
SensLabel.Size = UDim2.new(1,0,1,0)
SensLabel.BackgroundTransparency = 1
SensLabel.TextSize = 14
SensLabel.TextColor3 = Color3.new(1,1,1)
SensLabel.TextStrokeColor3 = Color3.new(0,0,0)
SensLabel.TextStrokeTransparency = .6
SensLabel.Text = 'Sens:'
SensLabel.Position = UDim2.new(-1,0,0,0)
SensLabel.TextXAlignment = Enum.TextXAlignment.Left
SensLabel.Parent = SensAdjust

local FovAdjust = SensAdjust:Clone()
FovAdjust.PlaceholderText = 'FOV'
FovAdjust.Name = 'FovAdjust'
FovAdjust.Text = tonumber(GameSenseConfiguration.Personalization.FieldOfView)
FovAdjust.Position = SensAdjust.Position + UDim2.new(0,0,0,20)
FovAdjust.SensLabel.Name = 'FovLabel'
FovAdjust.FovLabel.Text = 'Fov:'
FovAdjust.Parent = ScreenGui

local DropAdjust = SensAdjust:Clone()
DropAdjust.PlaceholderText = 'Drop'
DropAdjust.Name = 'DropAdjust'
DropAdjust.Text = tonumber(GameSenseConfiguration.Personalization.DropPredictionIntensity)
DropAdjust.Position = SensAdjust.Position + UDim2.new(0,0,0,40)
DropAdjust.SensLabel.Name = 'DropLabel'
DropAdjust.DropLabel.Text = 'Drop:'
DropAdjust.Parent = ScreenGui

local KeysList = Instance.new("TextLabel")
KeysList.Name = "KeysList"
KeysList.Font = Enum.Font.SourceSans
KeysList.TextStrokeTransparency = 0.6
KeysList.TextSize = 14
KeysList.TextColor3 = Color3.fromRGB(248, 248, 248)
KeysList.Size = UDim2.new(0, 0, 1, 0)
KeysList.Position = UDim2.new(0, 5, 0, -280)
KeysList.BackgroundTransparency = 1
KeysList.Active = false
KeysList.TextXAlignment = Enum.TextXAlignment.Left
KeysList.TextYAlignment = Enum.TextYAlignment.Bottom
KeysList.Text = 'AimBot Toggle: '..toggle_aimbot.Name..'\nAim Toggle: '..Enum.UserInputType.MouseButton2.Name..'\nAim Part Toggle: '..targetpart_change.Name..'\nPriority Toggle: '..priority_toggle.Name..'\nESP Toggle: '..toggle_esp.Name..'\nBones Toggle: '..Enum.KeyCode.Delete.Name..'\nChams Toggle: '..Enum.KeyCode.F3.Name..'\nBoxes Toggle: '..Enum.KeyCode.F4.Name..'\nFOV Increase: '..fov_increase.Name..'\nFOV Decrease: '..fov_decrease.Name..'\nSens Increase: '..sens_increase.Name..'\nSens Decrease: '..sens_decrease.Name..'\nTrigger Toggle: '..toggle_trigger.Name..'\nFFA Toggle: '..ffatoggle.Name..'\nHide Cheats: '..Enum.KeyCode.F6.Name..'\nChange Font: '..Enum.KeyCode.F1.Name
KeysList.Parent = ScreenGui

local GameSense = setmetatable({["SetSubtitleText"] = function(self, ...)
	local tuple = {...}
	local Text = tuple[1]
	local DisplayTime = tuple[2]
	coroutine.resume(coroutine.create(function()
		textSet = true
		Status.Text = string.sub(Text, 1, string.len(Text) > 20 and 20 or string.len(Text))
		Status.TextColor3 = Color3.fromRGB(248, 248, 248)
		if DisplayTime and typeof(DisplayTime) == "number" then
			wait(DisplayTime)
		else
			wait(string.len(Text) / 4)
		end
		textSet = false
	end))
end ;}, {})

local n = 0

spawn(function()
	while Status do
		Indicator.TextColor3 = Color3.fromHSV(n,.5,1)
		FovGui.ImageColor3 = Indicator.TextColor3
		if not textSet then
			if GameSenseConfiguration.AimBot.Active and target then
				Status.TextColor3 = aimingcolor
				Status.Text = ('Aiming at '..target.Name)
			else
				Status.TextColor3 = Color3.fromHSV(n,.5,1)
				Status.Text = 'On Standby'
			end
		end
		n = (n+.005)%1
		RunService.Heartbeat:wait()
	end
end)

SensAdjust.InputEnded:Connect(function()
	if SensAdjust.Text~='' then
		sens = tonumber(SensAdjust.Text)>0 and tonumber(SensAdjust.Text) or sens
	end
end)

FovAdjust.InputEnded:Connect(function()
	if FovAdjust and typeof(FovAdjust) == "Instance" and FovAdjust.Text ~= "" then
		if tonumber(FovAdjust.Text) and tonumber(FovAdjust.Text) > 0 then
			GameSenseConfiguration.Personalization.FieldOfView = tonumber(FovAdjust.Text)
		end
		game:GetService("TweenService"):Create(FovGui, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
			["Size"] = UDim2.new(0,(workspace.CurrentCamera.ViewportSize.X/(90/GameSenseConfiguration.Personalization.FieldOfView)) * 2, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2) ;
		}):Play()
	end
end)

DropAdjust.InputEnded:Connect(function()
	if DropAdjust and typeof(DropAdjust) == "Instance" and DropAdjust.Text ~= "" then
		if tonumber(DropAdjust.Text) and tonumber(DropAdjust.Text) > 0 then
			GameSenseConfiguration.Personalization.DropPredictionIntensity = tonumber(DropAdjust.Text)
		end
	end
end)

local function playsound(id)
	local sound = Instance.new('Sound',workspace.CurrentCamera)
	sound.SoundId = 'rbxassetid://'..id
	sound.Volume = 3
	sound:Play()
	game:GetService('Debris'):AddItem(sound,5)
end

playsound(1168009121)
Mouse.Icon = 'rbxassetid://'..mouseiconid

local function Notification(...)
	playsound(140910211)
	StarterGui:SetCore('SendNotification',...)
end

local function DrawLine(Folder,P1,P2,Thickness,Color,LineTransparency,BorderThickness,BorderColor)
	-- Declare variables
	local Point1,Point2 = P1.Position,P2.Position
	if Point1 and Point2 then
		local X,Y = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
		local X1,X2 = (X * Point1.X.Scale + Point1.X.Offset + P1.Size.X.Offset/2), (X * Point2.X.Scale + Point2.X.Offset + P2.Size.X.Offset/2)
		local Y1,Y2 = (Y * Point1.Y.Scale + Point1.Y.Offset + P1.Size.Y.Offset/2), (Y * Point2.Y.Scale + Point2.Y.Offset + P2.Size.Y.Offset/2)
		local MidX,MidY = (X1+X2)/2, (Y1+Y2)/2
		-- Set defaults to prevent errors
		Thickness = Thickness or 1
		Color = Color or Color3.new(1,1,1)
		LineTransparency =  LineTransparency or 0
		BorderThickness = BorderThickness or 0
		BorderColor = BorderColor or Color3.new(0,0,0)
		-- Draw the line
		local Line = Folder:FindFirstChild(P1.Name..'-'..P2.Name) or Instance.new('Frame',Folder)
		Line.Visible = false
		Line.BackgroundTransparency = LineTransparency
		Line.BorderSizePixel = BorderThickness
		Line.BorderColor3 = BorderColor
		Line.Size = UDim2.new(0,(Vector2.new(X1,Y1) - Vector2.new(X2,Y2)).magnitude-1,0,Thickness)
		Line.Position = UDim2.new(0,MidX-Line.AbsoluteSize.X/2,0,MidY-Line.AbsoluteSize.Y)
		Line.BackgroundColor3 = Color
		Line.Rotation = math.deg(math.atan2((Y2-Y1),(X2-X1)))
		Line.Name = P1.Name..'-'..P2.Name
		Line.Visible = true
		return Line
	else
		return nil
	end
end

local function GetNearestCharacter()
	local Nearest = {
		["Distance"] = math.huge ;
		["Character"] = nil ;
	}

	if table.find({292439477}, game.PlaceId) then
		local Team = Players.LocalPlayer.Team
		local Enemies = Team.Name == "Ghosts" and workspace.Players.Phantoms or workspace.Players.Ghosts
		if aim_priority == 1 then
			for _, Character in pairs(Enemies:GetChildren()) do
				if Character and Character:FindFirstChild(targetpart) then
					local Distance = (LocalPlayer.Character.HumanoidRootPart.CFrame.Position - Character.HumanoidRootPart.CFrame.Position).Magnitude
					local RaycastParameters = RaycastParams.new()
					RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
					RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
					RaycastParameters.IgnoreWater = true
					local RaycastResult = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, (Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Unit * (2048 * 2), RaycastParameters)
					if RaycastResult and typeof(RaycastResult) == "RaycastResult" then
						local Z = workspace.CurrentCamera:WorldToScreenPoint(Character[targetpart].CFrame.Position).Z
						if RaycastResult.Instance and RaycastResult.Instance:IsDescendantOf(Character) then
							if Distance < Nearest.Distance then
								Nearest.Distance = Distance
								Nearest.Character = Character
							end
						end
						print("Object/terrain hit:", RaycastParameters.Instance:GetFullName())
						print("Hit position:", RaycastParameters.Position)
						print("Surface normal at the point of intersection:", RaycastParameters.Normal)
						print("Material hit:", RaycastParameters.Material.Name)
					else
						print("Nothing was hit!")
					end
				end
			end
		elseif aim_priority == 2 then
			for _, Character in pairs(Enemies:GetChildren()) do
				if Character and Character:FindFirstChild(targetpart) then
					local Position = workspace.CurrentCamera:WorldToScreenPoint(Character[targetpart].Position)
					local RaycastParameters = RaycastParams.new()
					RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
					RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
					RaycastParameters.IgnoreWater = true
					local RaycastResult = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.CFrame.Position, (Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Unit * 2048, RaycastParameters)
					if RaycastResult and typeof(RaycastResult) == "RaycastResult" then
						local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
						if RaycastResult.Instance and RaycastResult.Instance:IsDescendantOf(Character) then
							if Distance <= workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView) and Distance < Nearest.Distance then
								Nearest.Distance = Distance
								Nearest.Character = Character
							end
						end
						pcall(function()
							print("Object/terrain hit:", RaycastParameters.Instance:GetFullName())
							print("Hit position:", RaycastParameters.Position)
							print("Surface normal at the point of intersection:", RaycastParameters.Normal)
							print("Material hit:", RaycastParameters.Material.Name)
						end)
					else
						pcall(function()
							print("Nothing was hit!")
						end)
					end
				end
			end
		end
	else
		local Team = Players.LocalPlayer.Team
		local Enemies = {}

		for _, Player in pairs(Players:GetPlayers()) do
			if Player ~= LocalPlayer and (Player.Team ~= Team or ffa == true) then
				table.insert(Enemies, Player)
			end
		end

		if aim_priority == 1 then
			for _, Player in pairs(Enemies) do 
				local Character = Player.Character
				if Character and Character:FindFirstChild(targetpart) then
					local Distance = (LocalPlayer.Character.HumanoidRootPart.CFrame.Position - Character.HumanoidRootPart.CFrame.Position).Magnitude
					local RaycastParameters = RaycastParams.new()
					RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
					RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
					RaycastParameters.IgnoreWater = true
					local RaycastResult = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, (Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Unit * (2048 * 2), RaycastParameters)
					if RaycastResult and typeof(RaycastResult) == "RaycastResult" then
						local Z = workspace.CurrentCamera:WorldToScreenPoint(Character[targetpart].CFrame.Position).Z
						if RaycastResult.Instance and RaycastResult.Instance:IsDescendantOf(Character) then
							if Distance < Nearest.Distance then
								Nearest.Distance = Distance
								Nearest.Character = Character
							end
						end
						print("Object/terrain hit:", RaycastParameters.Instance:GetFullName())
						print("Hit position:", RaycastParameters.Position)
						print("Surface normal at the point of intersection:", RaycastParameters.Normal)
						print("Material hit:", RaycastParameters.Material.Name)
					else
						print("Nothing was hit!")
					end
				end
			end
		elseif aim_priority == 2 then
			for _, Player in pairs(Enemies) do
				local Character = Player.Character
				if Character and Character:FindFirstChild(targetpart) then
					local Position = workspace.CurrentCamera:WorldToScreenPoint(Character[targetpart].Position)
					local RaycastParameters = RaycastParams.new()
					RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
					RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
					RaycastParameters.IgnoreWater = true
					local RaycastResult = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.CFrame.Position, (Character.HumanoidRootPart.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.CFrame.Position).Unit * 2048, RaycastParameters)
					if RaycastResult and typeof(RaycastResult) == "RaycastResult" then
						local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
						if RaycastResult.Instance and RaycastResult.Instance:IsDescendantOf(Character) then
							if Distance <= workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView) and Distance < Nearest.Distance then
								Nearest.Distance = Distance
								Nearest.Character = Character
							end
						end
						pcall(function()
							print("Object/terrain hit:", RaycastParameters.Instance:GetFullName())
							print("Hit position:", RaycastParameters.Position)
							print("Surface normal at the point of intersection:", RaycastParameters.Normal)
							print("Material hit:", RaycastParameters.Material.Name)
						end)
					else
						pcall(function()
							print("Nothing was hit!")
						end)
					end
				end
			end
		end
	end
	return Nearest
end

local cursor

Mouse.Move:Connect(function()
	cursor = ESP:FindFirstChild('Cursor') or Instance.new('Frame',ESP)
	cursor.AnchorPoint = Vector2.new(0, 0)
	cursor.Name = 'Cursor'
	cursor.BackgroundTransparency = 1
	cursor.Size = UDim2.new(0, 1, 0, 1)
	cursor.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
end)

UserInputService.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton2 then
		GameSenseConfiguration.AimBot.Active = true
	elseif Input.KeyCode == Enum.KeyCode.LeftAlt then
		GameSenseConfiguration.AimBot.Enabled = not GameSenseConfiguration.AimBot.Enabled
		if GameSenseConfiguration.AimBot.Enabled == true then
			GameSense:SetSubtitleText(string.format("Toggled AimBot %s", "On"))
			StarterGui:SetCore("SendNotification", {
				["Title"] = "AimBot" ;
				["Text"] = string.format("AimBot was toggled %s", "On") ;
				["Duration"] = 2 ;
			})
		elseif GameSenseConfiguration.AimBot.Enabled == false then
			GameSense:SetSubtitleText(string.format("Toggled AimBot %s", "Off"))
			StarterGui:SetCore("SendNotification", {
				["Title"] = "AimBot" ;
				["Text"] = string.format("AimBot was toggled %s", "Off") ;
				["Duration"] = 2 ;
			})
		end
	elseif Input.KeyCode == Enum.KeyCode.RightAlt then
		GameSenseConfiguration.TriggerBot.Enabled = not GameSenseConfiguration.TriggerBot.Enabled
		if GameSenseConfiguration.TriggerBot.Enabled == true then
			GameSense:SetSubtitleText(string.format("Toggled TriggerBot %s", "On"))
			StarterGui:SetCore("SendNotification", {
				["Title"] = "TriggerBot" ;
				["Text"] = string.format("TriggerBot was toggled %s", "On") ;
				["Duration"] = 2 ;
			})
		elseif GameSenseConfiguration.TriggerBot.Enabled == false then
			GameSense:SetSubtitleText(string.format("Toggled TriggerBot %s", "Off"))
			StarterGui:SetCore("SendNotification", {
				["Title"] = "TriggerBot" ;
				["Text"] = string.format("TriggerBot was toggled %s", "Off") ;
				["Duration"] = 2 ;
			})
		end
		local SelectionBox = Instance.new("SelectionBox")
		SelectionBox["Adornee"] = nil
		SelectionBox["Name"] = "SelectionBox"
		SelectionBox["LineThickness"] = 0.05
		SelectionBox["Transparency"] = 0
		SelectionBox["SurfaceTransparency"] = 1
		SelectionBox["SurfaceColor3"] = Color3.fromRGB(255, 64, 64)
		SelectionBox["Color3"] = Color3.fromRGB(255, 64, 64)
		SelectionBox["Parent"] = game:GetService("CoreGui")
		if GameSenseConfiguration.TriggerBot.Delay > 0 then
			wait(GameSenseConfiguration.TriggerBot.Delay)
		end
		coroutine.resume(coroutine.create(function()
			while true do
				if GameSenseConfiguration.TriggerBot.Enabled == true then
					local Hit, Target, Delta = Mouse.Hit, Mouse.Target, UserInputService:GetMouseDelta()
					local Character = false
					local PlayerSpotted = false
					if game.PlaceId == 292439477 and Target:FindFirstAncestor("Players") and Target:FindFirstAncestor(LocalPlayer.Team.Name == "Ghosts" and "Phantoms" or "Ghosts") then
						Character = Target:FindFirstAncestor("Player")
						PlayerSpotted = true
					else
						Character = Target:FindFirstAncestorWhichIsA("Model")
						local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
						if Players:GetPlayerFromCharacter(Character) then
							PlayerSpotted = true
						end
					end
					if Character and PlayerSpotted == true then
						SelectionBox["Adornee"] = Target
						coroutine.wrap(mouse1press)()
						if GameSenseConfiguration.Personalization.PerformanceMode == true then
							wait(math.min(math.max(workspace:GetRealPhysicsFPS() / 75, 0.5), 1 / 20))
						else
							RunService.Heartbeat:Wait()			
						end
						coroutine.wrap(mouse2press)()
					end
				elseif GameSenseConfiguration.TriggerBot.Enabled == false then
					SelectionBox:Destroy()
					break
				end
			end
		end))
	elseif Input.KeyCode == toggle_esp then
		esp_toggled = not esp_toggled
		Notification({Title='ESP';Text='ESP was toggled '..(esp_toggled and 'On' or 'Off');Duration=2;})
		GameSense:SetSubtitleText('Toggled ESP '..(esp_toggled and 'On' or 'Off'))
	elseif Input.KeyCode == toggle_aimbot then
		aimbot_toggled = not aimbot_toggled	
		Notification({Title='AimBot';Text='AimBot was toggled '..(aimbot_toggled and 'On' or 'Off');Duration=2;})
		GameSense:SetSubtitleText('Toggled AimBot '..(aimbot_toggled and 'On' or 'Off'))
	elseif Input.KeyCode == Enum.KeyCode.KeypadPlus then
		GameSenseConfiguration.Personalization.FieldOfView = GameSenseConfiguration.Personalization.FieldOfView + .5
		FovAdjust.Text = tonumber(GameSenseConfiguration.Personalization.FieldOfView)
		if FovGui.Visible then
			game:GetService("TweenService"):Create(FovGui, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
				["Size"] = UDim2.new(0,(workspace.CurrentCamera.ViewportSize.X/(90/GameSenseConfiguration.Personalization.FieldOfView)) * 2, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2) ;
			}):Play()
		end
		GameSense:SetSubtitleText('Aim FOV: '..GameSenseConfiguration.Personalization.FieldOfView)
	elseif Input.KeyCode == Enum.KeyCode.KeypadMinus and GameSenseConfiguration.Personalization.FieldOfView>0 then
		GameSenseConfiguration.Personalization.FieldOfView = GameSenseConfiguration.Personalization.FieldOfView - .5
		FovAdjust.Text = tonumber(GameSenseConfiguration.Personalization.FieldOfView)
		if FovGui.Visible then
			game:GetService("TweenService"):Create(FovGui, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
				["Size"] = UDim2.new(0,(workspace.CurrentCamera.ViewportSize.X/(90/GameSenseConfiguration.Personalization.FieldOfView)) * 2, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2) ;
			}):Play()
		end
		GameSense:SetSubtitleText('Aim FOV: '..GameSenseConfiguration.Personalization.FieldOfView)
	elseif Input.KeyCode == sens_increase then
		sens = sens + .05
		SensAdjust.Text = tonumber(sens)
		GameSense:SetSubtitleText('Sens: '..sens)
	elseif Input.KeyCode == sens_decrease then
		sens = sens - .05
		SensAdjust.Text = tonumber(sens)
		GameSense:SetSubtitleText('Sens: '..sens)
	elseif Input.KeyCode == targetpart_change then
		val = val+1
		targetpart = val<=#parts and parts[val] or parts[1]
		if parts[1]==targetpart then val = 1 end
		Notification({Title='Target Part';Text='Target part set to '..targetpart;Duration=2;})
		GameSense:SetSubtitleText('Target Part: '..targetpart)
	elseif Input.KeyCode == ffatoggle then
		ffa = not ffa
		Notification({Title='FFA Mode';Text='FFA Mode is '..(ffa and 'Enabled' or 'Disabled');Duration=2;})
		GameSense:SetSubtitleText('FFA Mode: '..(ffa and 'Enabled' or 'Disabled'))
	elseif Input.KeyCode == priority_toggle then
		aim_priority = aim_priority+1>2 and 0 or 1
		aim_priority = aim_priority+1
		FovGui.Visible = aim_priority>1
		Notification({Title='Aim Priority';Text='Aim Priority: '..(aim_priority==1 and 'Distance' or 'FOV');Duration=2;})
		GameSense:SetSubtitleText('Aim Priority: '..(aim_priority==1 and 'Distance' or 'FOV'))
	elseif Input.KeyCode == Enum.KeyCode.Delete then
		esp_bones = not esp_bones
		if not esp_bones then
			for _,v in next,ESP:GetDescendants() do
				if v:IsA('Frame') and v.Name:match('-') then
					v:Destroy()
				end
			end
		end
		Notification({Title='ESP';Text='ESP Bones: '..(esp_bones and 'Enabled' or 'Disabled');Duration=2;})
		GameSense:SetSubtitleText('Toggled ESP Bones '..(esp_bones and 'Enabled' or 'Disabled'))
	elseif Input.KeyCode == Enum.KeyCode.F6 then
		hidden = not hidden
		for _,gui in next,ScreenGui:GetDescendants() do
			if gui:IsA('GuiObject') and not hidden and not gui.Visible then
				gui.Visible = true
				Mouse.Icon = 'rbxassetid://'..mouseiconid
			elseif gui:IsA('GuiObject') and gui.Visible then
				gui.Visible = false
				esp_toggled = false
				Mouse.Icon = old_icon
			end
		end
	elseif Input.KeyCode == Enum.KeyCode.F8 then
		GameSenseConfiguration.Personalization.PerformanceMode = not GameSenseConfiguration.Personalization.PerformanceMode
		if GameSenseConfiguration.Personalization.PerformanceMode == true then
			GameSense:SetSubtitleText(string.format("Performance Mode %s", "Enabled"))
		elseif GameSenseConfiguration.Personalization.PerformanceMode == false then
			GameSense:SetSubtitleText(string.format("Performance Mode %s", "Disabled"))
		end
	elseif Input.KeyCode == Enum.KeyCode.F3 then
		GameSenseConfiguration.ESP["Chams"].Enabled = not  GameSenseConfiguration.ESP["Chams"].Enabled
		if GameSenseConfiguration.ESP["Chams"].Enabled == true then
			GameSense:SetSubtitleText(string.format("Chams %s", "Enabled"), 2)
			game:GetService("StarterGui"):SendNotification({
				["Title"] = "ESP" ;
				["Text"] = string.format("Chams %s", "Enabled") ;
				["Duration"] = 2 ;
			})
		elseif GameSenseConfiguration.ESP["Chams"].Enabled == false then
			GameSense:SetSubtitleText(string.format("Chams %s", "Disabled"), 2)
			game:GetService("StarterGui"):SendNotification({
				["Title"] = "ESP" ;
				["Text"] = string.format("Chams %s", "Disabled") ;
				["Duration"] = 2 ;
			})
		end
	elseif Input.KeyCode == Enum.KeyCode.F2 then
		GameSenseConfiguration.ESP["Tracers"].Enabled = not  GameSenseConfiguration.ESP["Tracers"].Enabled
		if GameSenseConfiguration.ESP["Tracers"].Enabled == true then
			GameSense:SetSubtitleText(string.format("Tracers %s", "Enabled"), 2)
			game:GetService("StarterGui"):SendNotification({
				["Title"] = "ESP" ;
				["Text"] = string.format("Tracers %s", "Enabled") ;
				["Duration"] = 2 ;
			})
		elseif GameSenseConfiguration.ESP["Tracers"].Enabled == false then
			GameSense:SetSubtitleText(string.format("Tracers %s", "Disabled"), 2)
			game:GetService("StarterGui"):SendNotification({
				["Title"] = "ESP" ;
				["Text"] = string.format("Tracers %s", "Disabled") ;
				["Duration"] = 2 ;
			})
		end
	elseif Input.KeyCode == Enum.KeyCode.F4 then
		bounding_box = not bounding_box
		GameSense:SetSubtitleText('Bounding Boxes '..(bounding_box and 'Enabled' or 'Disabled'))
		Notification({Title='ESP';Text='Bounding Boxes: '..(bounding_box and 'Enabled' or 'Disabled');Duration=2;})
	elseif Input.KeyCode == Enum.KeyCode.F1 then
		currentfont = (currentfont+1)>#fonts and 1 or currentfont+1
		for _,v in next,ScreenGui:GetDescendants() do
			if v.Name~='KeysList' then
				if v:IsA('TextLabel') or v:IsA('TextButton') then
					v.Font = fonts[currentfont]
				end
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton2 then
		GameSenseConfiguration.AimBot.Active = false
	end
end)

LocalPlayer.CharacterAdded:Connect(function(c)
	for _,v in next,ESP:GetDescendants() do
		if v:IsA("Frame") and string.match(v.Name, '-') then
			v:Destroy()
		end
	end
end)

Notification({
	Title='GameSense 1.25';
	Text='Cheat loaded successfully.';
	Icon='rbxassetid://2572157833';
	Duration=10;
})
wait(.5)
Notification({
	Title='GameSense 1.25';
	Text='GameSense 2.0 has been released!.';
	Icon='rbxassetid://2572157833';
	Duration=10;
})
wait(.5)
Notification({
	Title='Main Coder';
	Text='AvexusDev';
	Duration=4;
	Icon='https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username=AvexusDev'
})
wait(.5)
Notification({
	Title='Thank you!';
	Text='If you like this script, please leave a vouch on my thread!';
	Duration=4;
})

RunService.RenderStepped:Connect(function()
	if cursor then
		FovGui.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
	end
end)

Mouse.Button1Down:Connect(function()
	if FovGui.Visible then
		local Tween = game:GetService("TweenService"):Create(FovGui, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
			["Size"] = UDim2.new(0,(workspace.CurrentCamera.ViewportSize.X/(90/GameSenseConfiguration.Personalization.FieldOfView)) * 2.35, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2.35) ;
		})
		Tween:Play()
		Tween.Completed:Wait()
		local Tween = game:GetService("TweenService"):Create(FovGui, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {
			["Size"] = UDim2.new(0,(workspace.CurrentCamera.ViewportSize.X/(90/GameSenseConfiguration.Personalization.FieldOfView)) * 2, 0, (workspace.CurrentCamera.ViewportSize.X / (90 / GameSenseConfiguration.Personalization.FieldOfView)) * 2) ;
		})
		Tween:Play()
		Tween.Completed:Wait()
	end
end)

coroutine.resume(coroutine.create(function()
	while true do
		if aim_priority == 1 then
			Indicator.Text = string.format("FOV: %s\n{Sensitivity}\n{Aiming}", tostring(GameSenseConfiguration.Personalization.FieldOfView))
		elseif aim_priority == 2 then
			Indicator.Text = ("Distance\n{Sensitivity}\n{Aiming}")
		end
		Indicator.Text = string.gsub(Indicator.Text, "{Sensitivity}", string.format("Sensitivity: %s", tostring(sens)))
		if GameSenseConfiguration.AimBot.Enabled == true and GameSenseConfiguration.AimBot.Active == true then
			Indicator.Text = string.gsub(Indicator.Text, "\n{Aiming}", "\nAiming")
		else
			Indicator.Text = string.gsub(Indicator.Text, "\n{Aiming}", "")
		end
		if not bottompos then
			Bottom.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
		end
		if esp_toggled then
			for _, GuiObject in pairs(ESP:GetChildren()) do
				if not GameSenseConfiguration.ESP["Chams"] or (GuiObject ~= Bottom and GuiObject:FindFirstChildWhichIsA("ObjectValue") and not GuiObject:FindFirstChildWhichIsA("ObjectValue").Value) then
					GuiObject:Destroy()
				end
			end
			if table.find({292439477}, game.PlaceId) then
				local Enemies = LocalPlayer.Team.Name == "Ghosts" and workspace.Players.Phantoms or workspace.Players.Ghosts

				for _, Character in pairs(Enemies:GetChildren()) do
					if Character:FindFirstChild(targetpart) then
						local GUID = Character:GetAttribute("TemporaryGUID") or game:GetService("HttpService"):GenerateGUID(false)
						Character:SetAttribute("TemporaryGUID", GUID)
						local X = workspace.CurrentCamera:GetPartsObscuringTarget({workspace.CurrentCamera.CFrame.p,Character[targetpart].CFrame.p},{Character,Character,workspace.CurrentCamera,unpack(windows)})
						local Dist = LocalPlayer:DistanceFromCharacter(Character:FindFirstChild(targetpart).Position)
						local Color = hiddencolor
						local Folder = ESP:FindFirstChild(GUID) or Instance.new('Folder',ESP)
						Folder.Name = GUID
						local ObjectValue = Folder:FindFirstChildWhichIsA("ObjectValue") or Instance.new("ObjectValue")
						ObjectValue.Name = "ObjectValue"
						ObjectValue.Value = Character
						ObjectValue.Parent = Folder
						local Head = Folder:FindFirstChild('Head') or Instance.new('Frame',Folder)
						if not Folder:FindFirstChild('Head') then
							Head.Name = 'Head'
							Head.BorderSizePixel = 1
							Head.BorderColor3 = Color3.new(0,0,0)
							Head.BackgroundTransparency = 0
						end
						Head.BackgroundColor3 = #X>0 and hiddencolor or #X==0 and visiblecolor
						Head.Rotation = headboxshape=='diamond' and 45 or 0
						Head.ZIndex = 3
						local HP = Folder:FindFirstChild('HP') or Instance.new('TextLabel',Folder)
						if not Folder:FindFirstChild('HP') then
							HP.Name = 'HP'
							HP.TextTransparency = Head.BackgroundTransparency-.4
							HP.Font = fonts[currentfont]
							HP.TextStrokeTransparency = .6
							HP.BackgroundTransparency = 1
							HP.TextScaled = true

							local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
							UITextSizeConstraint.MaxTextSize = 14
							UITextSizeConstraint.MinTextSize = 1

							HP:GetPropertyChangedSignal("TextSize"):Connect(function()
								UITextSizeConstraint.MaxTextSize = HP.TextSize
							end)
						end
						HP.Text = showdists and Character.Name..'\n'..math.floor(Dist+.5) or Character.Name
						if GameSenseConfiguration.AimBot.Active and target == Character then
							Head.Size = UDim2.new(0, headboxaimsize, 0, headboxaimsize)
							Head.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
							if GameSenseConfiguration.Personalization.DisplayDistance == true then
								HP.Text = string.format("[%s]\n%s", Character.Name, math.floor(Dist + 0.5))
							else
								HP.Text = string.format("[%s]", Character.Name)
							end
							HP.TextSize = 16
						else
							Head.Size = UDim2.new(0,headboxsize,0,headboxsize)
						end
						HP.TextColor3 = Head.BackgroundColor3
						local toScreen = workspace.CurrentCamera:WorldToScreenPoint(Character[targetpart].CFrame.p)
						if #X==0 then Color = visiblecolor end
						Head.Position = UDim2.new(0,toScreen.X-Head.Size.X.Offset/2,0,toScreen.Y-Head.Size.Y.Offset/2)
						HP.Position = Head.Position-UDim2.new(0,0,0,textoffset)
						if esp_tracers then
							local Line = DrawLine(Folder,ESP.Bottom,Head,linesize,Head.BackgroundColor3,.75,1,Color3.new(0,0,0))
							Line.Visible = Head.Visible
						else
							local imtired = Folder:FindFirstChild(ESP.Bottom.Name..'-'..Head.Name)
							if imtired then
								imtired:Destroy()
							end
						end
						if toScreen.Z<=0 then Head.Visible = false else Head.Visible = true end
						HP.Visible = Head.Visible

						local Neck = Folder:FindFirstChild('Neck') or Instance.new('Frame',Folder)
						Neck.Name = 'Neck'
						Neck.ZIndex = 2
						if Character['Torso']~=nil then
							local Pos = (Character.Torso.CFrame*CFrame.new(0,.8,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							Neck.Position = UDim2.new(0,X,0,Y)
							Neck.BorderSizePixel = 0
							if Z<=0 then Neck.Visible = false else Neck.Visible = true end
						else
							Neck.Visible = false
						end
						--
						local Pelvis = Folder:FindFirstChild('Pelvis') or Instance.new('Frame',Folder)
						Pelvis.Name = 'Pelvis'
						Pelvis.ZIndex = 2
						Pelvis.BorderSizePixel = 0
						if Character['Torso']~=nil then
							local Pos = (Character.Torso.CFrame*CFrame.new(0,-1,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							Pelvis.Position = UDim2.new(0,X,0,Y)
							if Z<=0 then Pelvis.Visible = false else Pelvis.Visible = true end
						else
							Pelvis.Visible = false
						end
						--
						local RightFoot = Folder:FindFirstChild('Right Foot') or Instance.new('Frame',Folder)
						RightFoot.Name = 'Right Foot'
						RightFoot.ZIndex = 2
						RightFoot.BorderSizePixel = 0
						if Character['Right Leg']~=nil then
							local Pos = (Character['Right Leg'].CFrame*CFrame.new(0,-1,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							RightFoot.Position = UDim2.new(0,X,0,Y)
							if Z<=0 then RightFoot.Visible = false else RightFoot.Visible = true end
						else
							RightFoot.Visible = false
						end
						--
						local LeftFoot = Folder:FindFirstChild('Left Foot') or Instance.new('Frame',Folder)
						LeftFoot.Name = 'Left Foot'
						if Character['Left Leg']~=nil then
							local Pos = (Character['Left Leg'].CFrame*CFrame.new(0,-1,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							LeftFoot.Position = UDim2.new(0,X,0,Y)
							LeftFoot.BorderSizePixel = 0
							if Z<=0 then LeftFoot.Visible = false else LeftFoot.Visible = true end
						else
							LeftFoot.Visible = false
						end
						--
						local RightHand = Folder:FindFirstChild('Right Hand') or Instance.new('Frame',Folder)
						RightHand.Name = 'Right Hand'
						RightHand.ZIndex = 2
						RightHand.BorderSizePixel = 0
						if Character['Right Arm']~=nil then
							local Pos = (Character['Right Arm'].CFrame*CFrame.new(0,-1,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							RightHand.Position = UDim2.new(0,X,0,Y)
							if Z<=0 then RightHand.Visible = false else RightHand.Visible = true end
						else
							RightHand.Visible = false
						end
						--
						local LeftHand = Folder:FindFirstChild('Left Hand') or Instance.new('Frame',Folder)
						LeftHand.Name = 'Left Hand'
						LeftHand.ZIndex = 2
						LeftHand.BorderSizePixel = 0
						if Character['Left Arm']~=nil then
							local Pos = (Character['Left Arm'].CFrame*CFrame.new(0,-1,0)).Position
							local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
							LeftHand.Position = UDim2.new(0,X,0,Y)
							if Z<=0 then LeftHand.Visible = false else LeftHand.Visible = true end
						else
							LeftHand.Visible = false
						end
						-- draw joints
						if esp_bones then
							if Head.Visible then DrawLine(Folder,Head,Neck,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
							if Neck.Visible then DrawLine(Folder,Neck,Pelvis,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
							if Neck.Visible then DrawLine(Folder,Neck,RightHand,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
							if Neck.Visible then DrawLine(Folder,Neck,LeftHand,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
							if Pelvis.Visible then DrawLine(Folder,Pelvis,RightFoot,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
							if Pelvis.Visible then DrawLine(Folder,Pelvis,LeftFoot,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
						end

						if esp_chams then
							for _,Part in next,Character:children() do
								if Part:IsA('BasePart') and Part.Name~='HumanoidRootPart' then
									local Adornment = Folder:FindFirstChild(Part.Name..'_Cham') or Instance.new('BoxHandleAdornment',Folder)
									if not Folder:FindFirstChild(Part.Name..'_Cham') then
										Adornment.Name = Part.Name..'_Cham'
										Adornment.Adornee = Part
										Adornment.AlwaysOnTop = true
										Adornment.Size = Part.Name=='Head' and Vector3.new(1,1,1) or Part.Size
										Adornment.ZIndex = 1
									end
									Adornment.Color3 = Head.BackgroundColor3
								end
							end
						else
							for _,v in next,Folder:GetDescendants() do
								if GUID:match('Cham') then
									v:Destroy()
								end
							end
						end

						if bounding_box and Character:FindFirstChild('HumanoidRootPart') then
							local Box = Character:FindFirstChild('Box') or Instance.new('BillboardGui',Character)
							if not Character:FindFirstChild('Box') then
								Box.Name = 'Box'
								Box.Adornee = Character:FindFirstChild('HumanoidRootPart')
								Box.AlwaysOnTop = true
								Box.LightInfluence = 0
								Box.StudsOffset = Vector3.new(0,-Box.Adornee.Size.Y/4,0)
								Box.Size = UDim2.new(4,1,5,1)
								local Top = Instance.new('Frame',Box)
								Top.Size = UDim2.new(1,0,0,box_line_size)
								Top.BorderSizePixel = 0
								local Bot = Top:Clone()
								Bot.Position = UDim2.new(0,0,1,-box_line_size)
								Bot.Parent = Box
								local Left = Top:Clone()
								Left.Size = UDim2.new(0,1,1,0)
								Left.Parent = Box
								local Right = Left:Clone()
								Right.Position = UDim2.new(1,-box_line_size,0,0)
								Right.Parent = Box
							end
							for _,v in next,Box:children() do
								if v:IsA('Frame') then
									v.BackgroundColor3 = Head.BackgroundColor3
								end
							end
						else
							local Box = Character:FindFirstChild('Box')
							if Box then
								Box:Destroy()
							end
						end

						if lockedon and target and aim_line and ESP:FindFirstChild(target.Name) then
							DrawLine(ESP,cursor,ESP:FindFirstChild(target.Name).Head,1,Head.BackgroundColor3,.5)
						end
					else
						if ESP:FindFirstChild(Character:GetAttribute("TemporaryGUID")) then
							ESP:FindFirstChild(Character:GetAttribute("TemporaryGUID")):Destroy()
						end
					end
				end
			else
				for _,v in pairs(Players:GetPlayers()) do
					local Char = v.Character
					if Char and v ~= LocalPlayer and Char:FindFirstChild(targetpart) then
						if ffa or v.TeamColor ~= LocalPlayer.TeamColor then
							local X = workspace.CurrentCamera:GetPartsObscuringTarget({workspace.CurrentCamera.CFrame.p,Char[targetpart].CFrame.p},{v.Character,Char,workspace.CurrentCamera,unpack(windows)})
							local Dist = LocalPlayer:DistanceFromCharacter(Char:FindFirstChild(targetpart).Position)
							local Color = hiddencolor
							local Folder = ESP:FindFirstChild(v.Name) or Instance.new('Folder',ESP)
							Folder.Name = v.Name
							local ObjectValue = Folder:FindFirstChildWhichIsA("ObjectValue") or Instance.new("ObjectValue")
							ObjectValue.Name = "ObjectValue"
							ObjectValue.Value = Char
							ObjectValue.Parent = Folder
							local Head = Folder:FindFirstChild('Head') or Instance.new('Frame',Folder)
							if not Folder:FindFirstChild('Head') then
								Head.Name = 'Head'
								Head.BorderSizePixel = 1
								Head.BorderColor3 = Color3.new(0,0,0)
								Head.BackgroundTransparency = 0
							end
							Head.BackgroundColor3 = #X>0 and hiddencolor or #X==0 and visiblecolor
							Head.Rotation = headboxshape=='diamond' and 45 or 0
							Head.ZIndex = 3
							local HP = Folder:FindFirstChild('HP') or Instance.new('TextLabel',Folder)
							if not Folder:FindFirstChild('HP') then
								HP.Name = 'HP'
								HP.TextTransparency = Head.BackgroundTransparency-.4
								HP.Font = fonts[currentfont]
								HP.TextStrokeTransparency = .6
								HP.BackgroundTransparency = 1
								HP.TextScaled = true

								local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
								UITextSizeConstraint.MaxTextSize = 14
								UITextSizeConstraint.MinTextSize = 1

								HP:GetPropertyChangedSignal("TextSize"):Connect(function()
									UITextSizeConstraint.MaxTextSize = HP.TextSize
								end)
							end
							HP.Text = showdists and Char.Name..'\n'..math.floor(Dist+.5) or Char.Name
							if aim_toggled and target==Char then
								Head.Size = UDim2.new(0,headboxaimsize,0,headboxaimsize)
								Head.BackgroundColor3 = aimingcolor
								HP.Text = showdists and '['..Char.Name..']'..'\n'..math.floor(Dist+.5) or '['..Char.Name..']'
								HP.TextSize = 16
							else
								Head.Size = UDim2.new(0,headboxsize,0,headboxsize)
							end
							HP.TextColor3 = Head.BackgroundColor3
							local toScreen = workspace.CurrentCamera:WorldToScreenPoint(Char[targetpart].CFrame.p)
							if #X==0 then Color = visiblecolor end
							Head.Position = UDim2.new(0,toScreen.X-Head.Size.X.Offset/2,0,toScreen.Y-Head.Size.Y.Offset/2)
							HP.Position = Head.Position-UDim2.new(0,0,0,textoffset)
							if esp_tracers then
								local Line = DrawLine(Folder,ESP.Bottom,Head,linesize,Head.BackgroundColor3,.75,1,Color3.new(0,0,0))
								Line.Visible = Head.Visible
							else
								local imtired = Folder:FindFirstChild(ESP.Bottom.Name..'-'..Head.Name)
								if imtired then
									imtired:Destroy()
								end
							end
							if toScreen.Z<=0 then Head.Visible = false else Head.Visible = true end
							HP.Visible = Head.Visible
							if Char:FindFirstChild('Humanoid') and Char.Humanoid.RigType==Enum.HumanoidRigType.R6 then
								local Neck = Folder:FindFirstChild('Neck') or Instance.new('Frame',Folder)
								Neck.Name = 'Neck'
								Neck.ZIndex = 2
								if Char['Torso']~=nil then
									local Pos = (Char.Torso.CFrame*CFrame.new(0,.8,0)).Position
									local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
									Neck.Position = UDim2.new(0,X,0,Y)
									Neck.BorderSizePixel = 0
									if Z<=0 then Neck.Visible = false else Neck.Visible = true end
								else
									Neck.Visible = false
								end
								--
								local Pelvis = Folder:FindFirstChild('Pelvis') or Instance.new('Frame',Folder)
								Pelvis.Name = 'Pelvis'
								Pelvis.ZIndex = 2
								Pelvis.BorderSizePixel = 0
								if Char:FindFirstChild("Torso") then
									local Pos = (Char.Torso.CFrame * CFrame.new(0,-1,0)).Position
									local ScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(Pos)
									Pelvis.Position = UDim2.new(0, ScreenPoint.X, 0, ScreenPoint.Y)
									if ScreenPoint.Z <= 0 then
										Pelvis.Visible = false
									else
										Pelvis.Visible = true
									end
								else
									Pelvis.Visible = false
								end
								--
								local RightFoot = Folder:FindFirstChild('Right Foot') or Instance.new('Frame',Folder)
								RightFoot.Name = 'Right Foot'
								RightFoot.ZIndex = 2
								RightFoot.BorderSizePixel = 0
								if Char['Right Leg']~=nil then
									local Pos = (Char['Right Leg'].CFrame*CFrame.new(0,-1,0)).Position
									local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
									RightFoot.Position = UDim2.new(0,X,0,Y)
									if Z<=0 then RightFoot.Visible = false else RightFoot.Visible = true end
								else
									RightFoot.Visible = false
								end
								--
								local LeftFoot = Folder:FindFirstChild('Left Foot') or Instance.new('Frame',Folder)
								LeftFoot.Name = 'Left Foot'
								if Char['Left Leg']~=nil then
									local Pos = (Char['Left Leg'].CFrame*CFrame.new(0,-1,0)).Position
									local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
									LeftFoot.Position = UDim2.new(0,X,0,Y)
									LeftFoot.BorderSizePixel = 0
									if Z<=0 then LeftFoot.Visible = false else LeftFoot.Visible = true end
								else
									LeftFoot.Visible = false
								end
								--
								local RightHand = Folder:FindFirstChild('Right Hand') or Instance.new('Frame',Folder)
								RightHand.Name = 'Right Hand'
								RightHand.ZIndex = 2
								RightHand.BorderSizePixel = 0
								if Char['Right Arm']~=nil then
									local Pos = (Char['Right Arm'].CFrame*CFrame.new(0,-1,0)).Position
									local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
									RightHand.Position = UDim2.new(0,X,0,Y)
									if Z<=0 then RightHand.Visible = false else RightHand.Visible = true end
								else
									RightHand.Visible = false
								end
								--
								local LeftHand = Folder:FindFirstChild('Left Hand') or Instance.new('Frame',Folder)
								LeftHand.Name = 'Left Hand'
								LeftHand.ZIndex = 2
								LeftHand.BorderSizePixel = 0
								if Char['Left Arm']~=nil then
									local Pos = (Char['Left Arm'].CFrame*CFrame.new(0,-1,0)).Position
									local X,Y,Z = workspace.CurrentCamera:WorldToScreenPoint(Pos).X,workspace.CurrentCamera:WorldToScreenPoint(Pos).Y,workspace.CurrentCamera:WorldToScreenPoint(Pos).Z
									LeftHand.Position = UDim2.new(0,X,0,Y)
									if Z<=0 then LeftHand.Visible = false else LeftHand.Visible = true end
								else
									LeftHand.Visible = false
								end
								-- draw joints
								if esp_bones then
									if Head.Visible then DrawLine(Folder,Head,Neck,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
									if Neck.Visible then DrawLine(Folder,Neck,Pelvis,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
									if Neck.Visible then DrawLine(Folder,Neck,RightHand,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
									if Neck.Visible then DrawLine(Folder,Neck,LeftHand,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
									if Pelvis.Visible then DrawLine(Folder,Pelvis,RightFoot,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
									if Pelvis.Visible then DrawLine(Folder,Pelvis,LeftFoot,1,Color3.new(1,1,1),Head.BackgroundTransparency) end
								end
							end

							if esp_chams then
								for _,Part in next,Char:children() do
									if Part:IsA('BasePart') and Part.Name~='HumanoidRootPart' then
										local Adornment = Folder:FindFirstChild(Part.Name..'_Cham') or Instance.new('BoxHandleAdornment',Folder)
										if not Folder:FindFirstChild(Part.Name..'_Cham') then
											Adornment.Name = Part.Name..'_Cham'
											Adornment.Adornee = Part
											Adornment.AlwaysOnTop = true
											Adornment.Size = Part.Name=='Head' and Vector3.new(1,1,1) or Part.Size
											Adornment.ZIndex = 1
										end
										Adornment.Color3 = Head.BackgroundColor3
									end
								end
							else
								for _,v in next,Folder:GetDescendants() do
									if v.Name:match('Cham') then
										v:Destroy()
									end
								end
							end

							if bounding_box and Char:FindFirstChild('HumanoidRootPart') then
								local Box = Char:FindFirstChild('Box') or Instance.new('BillboardGui',Char)
								if not Char:FindFirstChild('Box') then
									Box.Name = 'Box'
									Box.Adornee = Char:FindFirstChild('HumanoidRootPart')
									Box.AlwaysOnTop = true
									Box.LightInfluence = 0
									Box.StudsOffset = Vector3.new(0,-Box.Adornee.Size.Y/4,0)
									Box.Size = UDim2.new(4,1,5,1)
									local Top = Instance.new('Frame',Box)
									Top.Size = UDim2.new(1,0,0,box_line_size)
									Top.BorderSizePixel = 0
									local Bot = Top:Clone()
									Bot.Position = UDim2.new(0,0,1,-box_line_size)
									Bot.Parent = Box
									local Left = Top:Clone()
									Left.Size = UDim2.new(0,1,1,0)
									Left.Parent = Box
									local Right = Left:Clone()
									Right.Position = UDim2.new(1,-box_line_size,0,0)
									Right.Parent = Box
								end
								for _,v in next,Box:children() do
									if v:IsA('Frame') then
										v.BackgroundColor3 = Head.BackgroundColor3
									end
								end
							else
								local Box = Char:FindFirstChild('Box')
								if Box then
									Box:Destroy()
								end
							end

							if lockedon and target and aim_line and ESP:FindFirstChild(target.Name) then
								DrawLine(ESP,cursor,ESP:FindFirstChild(target.Name).Head,1,Head.BackgroundColor3,.5)
							end

						else
							if ESP:FindFirstChild(v.Name) then
								ESP:FindFirstChild(v.Name):Destroy()
							end
						end
					else
						if ESP:FindFirstChild(v.Name) then
							ESP:FindFirstChild(v.Name):Destroy()
						end
					end
				end
			end
		else
			for _,v in next,ESP:children() do
				if v:IsA('Folder') then
					v:Destroy()
				end
			end
		end
		if GameSenseConfiguration.Personalization.PerformanceMode == true then
			wait(math.min(math.max(workspace:GetRealPhysicsFPS() / 75, 0.5), 1 / 20))
		else
			RunService.Heartbeat:Wait()			
		end
	end
end))

coroutine.resume(coroutine.create(function()
	local aimpos
	local mousemoverel = getfenv().mousemoverel

	while true do
		if GameSenseConfiguration.AimBot.Active == true and GameSenseConfiguration.AimBot.Enabled == true then
			local Nearest = GetNearestCharacter()
			if Nearest and typeof(Nearest) == "table" and Nearest.Character and Nearest.Character:FindFirstChild("Head") then
				local HeadPosition = workspace.CurrentCamera:WorldToScreenPoint(Nearest.Character[targetpart].Position + Vector3.new(0, Nearest.Distance / (100 / GameSenseConfiguration.Personalization.DropPredictionIntensity), 0))
				local PredictedMousePosition = Vector2.new((HeadPosition.X - Mouse.X) * sens, (HeadPosition.Y - Mouse.Y) * sens)
				pcall(function()
					aimpos = ScreenGui:FindFirstChild("AimPos") or Instance.new('Frame')
					if not ScreenGui:FindFirstChild("AimPos") then
						aimpos.Name = "AimPos"
						aimpos.BorderSizePixel = 1
						aimpos.BorderColor3 = Color3.fromRGB(17, 17, 17)
						aimpos.BackgroundTransparency = 0
						aimpos.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
						aimpos.Rotation = 45
						aimpos.ZIndex = 4
						aimpos.Size = UDim2.new(0, 3, 0, 3)
						aimpos.Parent = ScreenGui
					end
					aimpos.Position = UDim2.new(0, HeadPosition.X - aimpos.AbsoluteSize.X / 2, 0, HeadPosition.Y - aimpos.AbsoluteSize.Y / 2)
					aimpos.Visible = true
				end)
				mousemoverel(PredictedMousePosition.X, PredictedMousePosition.Y)
				target = Nearest.Character
				lockedon = true
			end
		else
			lockedon = false
		end

		RunService.Heartbeat:Wait()
	end
end))
