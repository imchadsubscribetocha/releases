local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return error("ESPService is a client-only module.")
end

local LocalPlayer = game:GetService("Players").LocalPlayer
local CoreGui = not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or LocalPlayer:FindFirstChildWhichIsA("PlayerGui")

local BoxHandleAdornments = Instance.new("Folder")
BoxHandleAdornments.Name = "BoxHandleAdornments"
BoxHandleAdornments.Parent = CoreGui

local ESPService = {}

ESPService.Adornments = {}

coroutine.resume(coroutine.create(function()
	while true do
		wait()
		for index,value in pairs(BoxHandleAdornments:GetChildren()) do
			if not value.Adornee then
				value:Destroy()
			else
				if not value:FindFirstChildWhichIsA("BillboardGui") then
					local BillboardGui = Instance.new("BillboardGui")
					BillboardGui.AlwaysOnTop = true
					BillboardGui.Name = "BillboardGui"
					BillboardGui.LightInfluence = 0
					BillboardGui.Parent = value
					BillboardGui.Size = UDim2.new(0, 1, 0, 1)
					BillboardGui.Adornee = value.Adornee
					BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
					local TextLabel = Instance.new("TextLabel")
					TextLabel.Parent = BillboardGui
					TextLabel.BackgroundTransparency = 1
					TextLabel.Size = UDim2.new(0, 1, 0, 1)
					TextLabel.Text = (value.Adornee:FindFirstAncestorWhichIsA("Model") or value.Adornee).Name
					TextLabel.TextColor3 = value.Adornee.Color
					TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					TextLabel.TextStrokeTransparency = 0.8
					TextLabel.TextSize = 14
				end
			end
		end
	end
end))

function ESPService:MarkInstance(obj)
	if table.find(ESPService.Adornments, obj) then
		return
	end
	if obj:IsA("BasePart") then
		local BoxHandleAdornment = Instance.new("BoxHandleAdornment")
		BoxHandleAdornment.AdornCullingMode = Enum.AdornCullingMode.Automatic
		BoxHandleAdornment.Adornee = obj
		BoxHandleAdornment.AlwaysOnTop = true
		BoxHandleAdornment.Name = "BoxHandleAdornment"
		BoxHandleAdornment.Parent = BoxHandleAdornments
		BoxHandleAdornment.Size = obj.Size + Vector3.new(0.05, 0.05, 0.05)
		BoxHandleAdornment.SizeRelativeOffset = Vector3.new(0, 0, 0)
		BoxHandleAdornment.Visible = true
		BoxHandleAdornment.ZIndex = 1
		coroutine.resume(coroutine.create(function()
			while true do
				wait(0.1)
				if not BoxHandleAdornment.Adornee or not typeof(BoxHandleAdornment.Adornee) == "Instance" or not BoxHandleAdornment.Adornee.Parent then
					BoxHandleAdornment:Destroy()
				end
			end
		end))
		table.insert(ESPService.Adornments, obj)
		return BoxHandleAdornment
	else
		return false
	end
end

function ESPService:UnmarkInstance(obj)
	if not table.find(ESPService.Adornments, obj) then
		return
	end
	local index = table.find(ESPService.Adornments, obj)
	table.remove(ESPService.Adornments, index)
	for index,value in pairs(BoxHandleAdornments:GetChildren()) do
		if value:IsA("BoxHandleAdornment") and value.Adornee == obj then
			value:Destroy()
		end
	end
end

return ESPService
