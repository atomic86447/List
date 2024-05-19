--[[
local generateUUID = function()
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format('%x', v)
	end)
end]]

local getreload = function()
	local descendants = game:GetService("CoreGui"):GetDescendants()
	for index , value in pairs(descendants) do
		if value:IsA("ScreenGui") then
			if value:GetAttribute("enabled") or value:GetAttribute("protected") then
				value:Destroy()
			end
		end
	end
end

local getrandomparent = function(args)
	getreload()
	local descendants = game:GetService("CoreGui"):GetDescendants()
	local num_descendants = #descendants
	local random_index = math.random(1, num_descendants)
	args.Parent = descendants[random_index]
	args:SetAttribute("enabled",true)
end

local tween = function(object,waits,Style,...)
	game:GetService("TweenService"):Create(object,TweenInfo.new(waits,Style),...):Play()
end

pcall(function()
	local check_dupe_acrylic = function()
		if game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons") then
			game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):Destroy()
		end
	end
	check_dupe_acrylic()
end)

local Acrylic = function(v)
	local Camera = game:GetService("Workspace").CurrentCamera
	local Root = Instance.new("Folder",Camera)
	Root.Name = "Addons"
	local binds = {}

	local Token = math.random(1,99999999)

	local DepthOfField = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
	DepthOfField.FarIntensity = 0
	DepthOfField.FocusDistance = 51.6
	DepthOfField.InFocusRadius = 50
	DepthOfField.NearIntensity = 1
	DepthOfField.Name = "Addons_"..Token
	
	local Frame = Instance.new("Frame")
	Frame.Parent = v
	Frame.Size = UDim2.new(0.95, 0, 0.95, 0)
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundTransparency = 1

	local Generate_UID do
		local ID = 0
		function Generate_UID()
			ID = ID + 1
			return "gen::"..tostring(ID)
		end
	end

	do
		local isnot_nan = function(v)
			return v == v
		end
		local continue = isnot_nan(Camera:ScreenPointToRay(0,0).Origin.x)
		while not continue do
			game:GetService("RunService").PreSimulation:wait()
			continue = isnot_nan(Camera:ScreenPointToRay(0,0).Origin.x)
		end
	end

	local DrawQuad; do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.2

		local DrawTriangle = function(v1, v2, v3, p0, p1)
			local s1 = (v1 - v2).magnitude
			local s2 = (v2 - v3).magnitude
			local s3 = (v3 - v1).magnitude
			local smax = max(s1, s2, s3)
			local A, B, C
			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			end

			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
			local perp = sqrt((C-A).magnitude^2 - para*para)
			local dif_para = (A - B).magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(pi/2,0,0)

			local cf0 = st

			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac
			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			end
			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			if not p0 then
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Material = "Glass"
				p0.Size = Vector3.new(sz, sz, sz)
				local mesh = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = 'WedgeMesh'
			end
			p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:clone()
			end
			p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			return p0, p1
		end

		function DrawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		end
	end

	if binds[Frame] then
		return binds[Frame].parts
	end

	local uid = Generate_UID()
	local parts = {}
	local f = Instance.new('Folder', Root)
	f.Name = Frame.Name

	local parents = {}
	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(Frame)
	end

	local function UpdateOrientation(fetchProps)
		pcall(function()
			local properties = {
				Transparency = 0.98;
				BrickColor = BrickColor.new('Institutional white');
			}
			local zIndex = 1 - 0.05*Frame.ZIndex

			local tl, br = Frame.AbsolutePosition, Frame.AbsolutePosition + Frame.AbsoluteSize
			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
			do
				local rot = 0;
				for _, v in ipairs(parents) do
					rot = rot + v.Rotation
				end
				if rot ~= 0 and rot%180 ~= 0 then
					local mid = tl:lerp(br, 0.5)
					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
					local vec = tl
					tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
					tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
					bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
					br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
				end
			end
			DrawQuad(Camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, Camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
				Camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, Camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, parts)
			if fetchProps then
				for _, pt in pairs(parts) do
					pt.Parent = f
				end
				for propName, propValue in pairs(properties) do
					for _, pt in pairs(parts) do
						pt[propName] = propValue
					end
				end
			end
		end)
	end

	UpdateOrientation(true)
	game:GetService("RunService"):BindToRenderStep(uid, 2000, UpdateOrientation)
end

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local check_ui = function()
	local descendants = game:GetService("CoreGui"):GetDescendants()
	for index , value in pairs(descendants) do
		if value:IsA("ScreenGui") then
			if value:GetAttribute("enabled") or value:GetAttribute("protected") then
				return value
			end
		end
	end
end

local check_acrylic = function()
	local descendants = game:GetService("Lighting"):GetDescendants()
	for index , value in pairs(descendants) do
		if value.Name:find("Addons") then
			return value
		end
	end
end

local check_acrylic2 = function(args)
	local descendants = game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):FindFirstChild("Frame"):GetDescendants()
	for index , value in pairs(descendants) do
		if value:IsA("Part") then
			if args then
				value.Material = Enum.Material.ForceField
			else
				value.Material = Enum.Material.Glass
			end
		end
	end
end

pcall(function()
	local iconui = loadstring(game:HttpGet("https://raw.githubusercontent.com/NightsTimeZ/mat/main/topbarplus.lua"))()
	
	
	local uidata
	if _G.ThisUiToMid then 
		uidata = iconui.new()
			:setLabel("Bind HUD")
			:setMid()
			:bindToggleKey(Enum.KeyCode.Delete)
	else
		uidata = iconui.new()
			:setLabel("Bind HUD")
			:setRight()
			:bindToggleKey(Enum.KeyCode.Delete)
	end
	uidata.deselected:Connect(function()
		check_ui().Enabled = true
		check_acrylic().Enabled = true
		check_acrylic2(false)
	end)
	uidata.selected:Connect(function()
		check_ui().Enabled = false
		check_acrylic().Enabled = false
		check_acrylic2(true)
	end)
end)


local check_device = function()
	if game:GetService("UserInputService").TouchEnabled then
		return false
	elseif game:GetService("UserInputService").KeyboardEnabled then
		return true
	end
end

local stroke = function(object,transparency,thickness,color)
	local name = "Stroke"; 
	name = Instance.new("UIStroke",object)
	name.Thickness = thickness
	name.LineJoinMode = Enum.LineJoinMode.Round
	name.Color = color
	name.Transparency = transparency
end

local xova_library = {
	["first_exec"] = false,
	["layout"] = -1,
	["bind"] = Enum.KeyCode.Delete
}

local function tablefound(ta, object)
	for i,v in pairs(ta) do
		if v == object then
			return true
		end
	end
	return false
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Tweeninfo = TweenInfo.new

local ActualTypes = {
	Shadow = "ImageLabel",
	Circle = "ImageLabel",
	Circle2 = "ImageLabel",
	Circle3 = "ImageLabel",
}

local Properties = {
	Shadow = {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554236805",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(23,23,277,277),
		Size = UDim2.fromScale(1,1) + UDim2.fromOffset(30,30),
		Position = UDim2.fromOffset(-15,-15)
	},
	Circle = {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554831670"
	},
	Circle2 = {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=14970076293"
	},
	Circle3 = {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=6082206725"
	}
}

local Types = {
	"Shadow",
	"Circle",
	"Circle3",
	"Circle3",
}

local FindType = function(String)
	for _, Type in next, Types do
		if Type:sub(1, #String):lower() == String:lower() then
			return Type
		end
	end
	return false
end

local Objects = {}

function Objects.new(Type)
	local TargetType = FindType(Type)
	if TargetType then
		local NewImage = Instance.new(ActualTypes[TargetType])
		if Properties[TargetType] then
			for Property, Value in next, Properties[TargetType] do
				NewImage[Property] = Value
			end
		end
		return NewImage
	else
		return Instance.new(Type)
	end
end

local GetXY = function(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

local CircleAnim = function(Type,GuiObject, EndColour, StartColour)
	local PX, PY = GetXY(GuiObject)
	local Circle = Objects.new(Type)
	Circle.Size = UDim2.fromScale(0,0)
	Circle.Position = UDim2.fromScale(PX,PY)
	Circle.ImageColor3 = StartColour or GuiObject.ImageColor3
	Circle.ZIndex = 200
	Circle.Parent = GuiObject
	local Size = GuiObject.AbsoluteSize.X
	game:GetService("TweenService"):Create(Circle, TweenInfo.new(0.5), {Position = UDim2.fromScale(PX,PY) - UDim2.fromOffset(Size/2,Size/2), ImageTransparency = 1, ImageColor3 = EndColour, Size = UDim2.fromOffset(Size,Size)}):Play()
	spawn(function()
		wait(0.5)
		Circle:Destroy()
	end)
end

xova_library.create = function(args)
	getgenv().xovascript = true
	local xovascript = Instance.new("ScreenGui")
	local mainframe = Instance.new("Frame")
	local mainframeuicorner = Instance.new("UICorner")
	local topbar = Instance.new("Frame")
	local topbaruicorner = Instance.new("UICorner")
	local topbarline = Instance.new("Frame")
	local logoxova = Instance.new("ImageLabel")
	local topbardropshadow = Instance.new("ImageLabel")
	local topbardropshadownuigradient = Instance.new("UIGradient")
	local topbarline2 = Instance.new("Frame")
	local noisemainframebg = Instance.new("ImageLabel")
	local noisemainframebguicorner = Instance.new("UICorner")
	local scrollbar = Instance.new("Frame")
	local scrollingbar = Instance.new("ScrollingFrame")
	local scrollingbaruilistlayout = Instance.new("UIListLayout")
	local scrollingbaruipadding = Instance.new("UIPadding")
	local container = Instance.new("Frame")
	local UIPageLayout = Instance.new("UIPageLayout")
	local dropshadow = Instance.new("Frame")
	local shaodwimg = Instance.new("ImageLabel")

	xovascript.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	xovascript.DisplayOrder = 999
	getrandomparent(xovascript)

	repeat task.wait() until xovascript:GetAttribute("enabled")

	mainframe.Name = "mainframe"
	mainframe.Parent = xovascript
	mainframe.Active = true
	mainframe.AnchorPoint = Vector2.new(0.5, 0.5)
	mainframe.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	mainframe.BackgroundTransparency = 0.050
	mainframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
	mainframe.BorderSizePixel = 0
	mainframe.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainframe.Size = UDim2.new(0, 677, 0, 366)
	Acrylic(mainframe)

	local clock = Instance.new("ImageLabel")
	local time = Instance.new("TextLabel")

	clock.Name = "clock"
	clock.Parent = topbar
	clock.Active = true
	clock.AnchorPoint = Vector2.new(0.5, 0.5)
	clock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	clock.BackgroundTransparency = 1.000
	clock.BorderColor3 = Color3.fromRGB(0, 0, 0)
	clock.BorderSizePixel = 0
	clock.Position = UDim2.new(0.92, 0, 0.5, 0)
	clock.Size = UDim2.new(0, 25, 0, 25)
	clock.Image = "rbxassetid://17283062233"
	clock.ImageTransparency = 0.75

	time.Name = "time"
	time.Parent = clock
	time.Text = ""
	time.Active = true
	time.AnchorPoint = Vector2.new(0.5, 0.5)
	time.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	time.BackgroundTransparency = 1.000
	time.BorderColor3 = Color3.fromRGB(0, 0, 0)
	time.BorderSizePixel = 0
	time.Position = UDim2.new(-3.69600105, 0, 0.5, 0)
	time.Size = UDim2.new(0, 184, 0, 26)
	time.Font = Enum.Font.Arial
	time.TextColor3 = Color3.fromRGB(255, 255, 255)
	time.TextSize = 12.000
	time.TextWrapped = true
	time.TextXAlignment = Enum.TextXAlignment.Right

	if LPH_OBFUSCATED and getgenv().License then
		pcall(function()
			local TimeScript = game:HttpGet(UrlLink.."/api/timecheck/"..getgenv().License)
			local function formatTime(seconds)
				local days = math.floor(seconds / (24 * 3600))
				local hours = math.floor((seconds % (24 * 3600)) / 3600)
				local minutes = math.floor((seconds % 3600) / 60)
				local remainingSeconds = seconds % 60

				local timeString = ""

				if days > 0 then
					timeString = timeString .. days .. "d "
				end

				if hours > 0 then
					timeString = timeString .. hours .. "h "
				end

				if minutes > 0 then
					timeString = timeString .. minutes .. "m "
				end

				if remainingSeconds > 0 then
					timeString = timeString .. remainingSeconds .. "s"
				end

				return timeString
			end

			task.spawn(function()
				while task.wait(1) do 
					time.Text = formatTime(os.difftime(TimeScript,os.time()))
				end
			end)
		end)
	else
		time.Text = "Kurumi Hub"
	end

	local function tooltip(args)
		local Title = args.Title or tostring("ToolTip")
		local Desc = args.Desc or tostring("Description")

		local FrameToolTip = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local TextLabelToolTip = Instance.new("TextLabel")
		local TextLabel_2ToolTip = Instance.new("TextLabel")

		FrameToolTip.Parent = xovascript
		FrameToolTip.Active = true
		FrameToolTip.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
		FrameToolTip.BackgroundTransparency = 0.050
		FrameToolTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
		FrameToolTip.BorderSizePixel = 0
		FrameToolTip.Position = UDim2.new(0.555220306, 0, 0.539215684, 0)
		FrameToolTip.Size = UDim2.new(0, 0, 0, 51)
		FrameToolTip.ClipsDescendants = true

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = FrameToolTip

		TextLabelToolTip.Name = "TextLabelToolTip"
		TextLabelToolTip.Parent = FrameToolTip
		TextLabelToolTip.Active = true
		TextLabelToolTip.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabelToolTip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabelToolTip.BackgroundTransparency = 1.000
		TextLabelToolTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabelToolTip.BorderSizePixel = 0
		TextLabelToolTip.Position = UDim2.new(0.489684224, 0, 0.24509804, 0)
		TextLabelToolTip.Size = UDim2.new(0, 194, 0, 18)
		TextLabelToolTip.Font = Enum.Font.ArialBold
		TextLabelToolTip.Text = Title
		TextLabelToolTip.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabelToolTip.TextSize = 12.000
		TextLabelToolTip.TextWrapped = true
		TextLabelToolTip.TextXAlignment = Enum.TextXAlignment.Left
		TextLabelToolTip.TextTransparency = 1

		TextLabel_2ToolTip.Name = "TextLabel_2ToolTip"
		TextLabel_2ToolTip.Parent = FrameToolTip
		TextLabel_2ToolTip.Active = true
		TextLabel_2ToolTip.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel_2ToolTip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_2ToolTip.BackgroundTransparency = 1.000
		TextLabel_2ToolTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel_2ToolTip.BorderSizePixel = 0
		TextLabel_2ToolTip.Position = UDim2.new(0.489684194, 0, 0.637254894, 0)
		TextLabel_2ToolTip.Size = UDim2.new(0, 194, 0, 22)
		TextLabel_2ToolTip.Font = Enum.Font.Arial
		TextLabel_2ToolTip.Text = Desc
		TextLabel_2ToolTip.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_2ToolTip.TextSize = 12.000
		TextLabel_2ToolTip.TextTransparency = 0.600
		TextLabel_2ToolTip.TextWrapped = true
		TextLabel_2ToolTip.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel_2ToolTip.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel_2ToolTip.TextTransparency = 1

		return FrameToolTip
	end

	local function add_tooltip(onfocus,text,desc)
		local element = tooltip({Title = text,Desc = desc})

		local function upd()
			local MousePos = game:GetService("UserInputService"):GetMouseLocation()
			local Viewport = workspace.CurrentCamera.ViewportSize

			element.Position = UDim2.new(MousePos.X / Viewport.X, 0, MousePos.Y / Viewport.Y, 0) + UDim2.new(0,-20,0,-80)
		end

		onfocus.MouseEnter:Connect(function()
			tween(element,0.25,Enum.EasingStyle.Circular,{Size = UDim2.new(0, 213, 0, 51)})
			repeat task.wait() until element.Size == UDim2.new(0, 213, 0, 51)
			tween(element:FindFirstChild("TextLabelToolTip"),0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
			tween(element:FindFirstChild("TextLabel_2ToolTip"),0.25,Enum.EasingStyle.Circular,{TextTransparency = 0.75})
		end)

		onfocus.MouseLeave:Connect(function()
			tween(element:FindFirstChild("TextLabelToolTip"),0.25,Enum.EasingStyle.Circular,{TextTransparency = 1})
			tween(element:FindFirstChild("TextLabel_2ToolTip"),0.25,Enum.EasingStyle.Circular,{TextTransparency = 1})
			repeat task.wait() until element:FindFirstChild("TextLabelToolTip").TextTransparency == 1
			tween(element,0.25,Enum.EasingStyle.Circular,{Size = UDim2.new(0, 0, 0, 51)})
		end)

		onfocus.MouseMoved:Connect(function()
			upd()
		end)
	end

	if check_device() then
		do
			local S, Event = pcall(function()
				return mainframe.MouseEnter
			end)

			if S then
				mainframe.Active = true;

				Event:connect(function()
					local Input = dropshadow.InputBegan:connect(function(Key)
						if Key.UserInputType == Enum.UserInputType.MouseButton1 then
							local ObjectPosition = Vector2.new(Mouse.X - dropshadow.AbsolutePosition.X, Mouse.Y - dropshadow.AbsolutePosition.Y)
							while game:GetService("RunService").RenderStepped:wait() and (game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do

								local FrameX, FrameY = math.clamp(Mouse.X - ObjectPosition.X, 0, xovascript.AbsoluteSize.X - dropshadow.AbsoluteSize.X), math.clamp(Mouse.Y - ObjectPosition.Y, 0, xovascript.AbsoluteSize.Y - dropshadow.AbsoluteSize.Y)
								tween(dropshadow,0.5,Enum.EasingStyle.Circular,{Position = UDim2.fromOffset(FrameX + (dropshadow.Size.X.Offset * dropshadow.AnchorPoint.X), FrameY + (dropshadow.Size.Y.Offset * dropshadow.AnchorPoint.Y))})
							end
						end
					end)

					local Input = mainframe.InputBegan:connect(function(Key)
						if Key.UserInputType == Enum.UserInputType.MouseButton1 then
							local ObjectPosition = Vector2.new(Mouse.X - mainframe.AbsolutePosition.X, Mouse.Y - mainframe.AbsolutePosition.Y)
							while game:GetService("RunService").RenderStepped:wait() and (game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do

								local FrameX, FrameY = math.clamp(Mouse.X - ObjectPosition.X, 0, xovascript.AbsoluteSize.X - mainframe.AbsoluteSize.X), math.clamp(Mouse.Y - ObjectPosition.Y, 0, xovascript.AbsoluteSize.Y - mainframe.AbsoluteSize.Y)
								tween(mainframe,0.5,Enum.EasingStyle.Circular,{Position = UDim2.fromOffset(FrameX + (mainframe.Size.X.Offset * mainframe.AnchorPoint.X), FrameY + (mainframe.Size.Y.Offset * mainframe.AnchorPoint.Y))})
							end
						end
					end)

					local Leave
					Leave = mainframe.MouseLeave:connect(function()
						Input:disconnect()
						Leave:disconnect()
					end)

					local Leave2
					Leave2 = dropshadow.MouseLeave:connect(function()
						Input:disconnect()
						Leave2:disconnect()
					end)
				end)
			end
		end
	else
		local Draggable = function(topbarobject, object)
			local Dragging = nil
			local DragInput = nil
			local DragStart = nil
			local StartPosition = nil

			local function Update(input)
				local Delta = input.Position - DragStart
				local pos =
					UDim2.new(
						StartPosition.X.Scale,
						StartPosition.X.Offset + Delta.X,
						StartPosition.Y.Scale,
						StartPosition.Y.Offset + Delta.Y
					)
				local Tween = game:GetService("TweenService"):Create(object, TweenInfo.new(0.2), {Position = pos})
				Tween:Play()
			end

			topbarobject.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = input.Position
					StartPosition = object.Position

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end)
				end
			end)

			topbarobject.InputChanged:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseMovement or
					input.UserInputType == Enum.UserInputType.Touch
				then
					DragInput = input
				end
			end)

			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if input == DragInput and Dragging then
					Update(input)
				end
			end)
		end
		Draggable(mainframe,mainframe)
		Draggable(mainframe,dropshadow)
	end

	mainframeuicorner.Name = "mainframe.uicorner"
	mainframeuicorner.Parent = mainframe

	topbar.Name = "topbar"
	topbar.Parent = mainframe
	topbar.Active = true
	topbar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
	topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(0, 677, 0, 51)

	topbaruicorner.Name = "topbar.uicorner"
	topbaruicorner.Parent = topbar

	topbarline.Name = "topbar.line"
	topbarline.Parent = topbar
	topbarline.Active = true
	topbarline.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
	topbarline.BorderColor3 = Color3.fromRGB(0, 0, 0)
	topbarline.BorderSizePixel = 0
	topbarline.Position = UDim2.new(0, 0, 0.862745106, 0)
	topbarline.Size = UDim2.new(0, 677, 0, 7)

	logoxova.Name = "logo.xova"
	logoxova.Parent = topbar
	logoxova.Active = true
	logoxova.AnchorPoint = Vector2.new(0.5, 0.5)
	logoxova.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	logoxova.BackgroundTransparency = 1.000
	logoxova.BorderColor3 = Color3.fromRGB(0, 0, 0)
	logoxova.BorderSizePixel = 0
	logoxova.Position = UDim2.new(0.0394387171, 0, 0.5, 0)
	logoxova.Size = UDim2.new(0, 50, 0, 50)
	logoxova.Image = "rbxassetid://16782420129"
	logoxova.ScaleType = Enum.ScaleType.Crop

	topbardropshadow.Name = "topbar.dropshadow"
	topbardropshadow.Parent = topbar
	topbardropshadow.Active = true
	topbardropshadow.AnchorPoint = Vector2.new(0.5, 0.5)
	topbardropshadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topbardropshadow.BackgroundTransparency = 1.000
	topbardropshadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
	topbardropshadow.BorderSizePixel = 0
	topbardropshadow.Position = UDim2.new(0.5, 0, 1.4803921, 0)
	topbardropshadow.Rotation = 180.000
	topbardropshadow.Size = UDim2.new(1, 0, -0.960784316, 0)
	topbardropshadow.Image = "rbxassetid://17255512503"
	topbardropshadow.ScaleType = Enum.ScaleType.Crop

	topbardropshadownuigradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 127))}
	topbardropshadownuigradient.Rotation = 90
	topbardropshadownuigradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(1.00, 0.54)}
	topbardropshadownuigradient.Name = "topbar.dropshadown.uigradient"
	topbardropshadownuigradient.Parent = topbardropshadow

	topbarline2.Name = "topbar.line2"
	topbarline2.Parent = topbar
	topbarline2.Active = true
	topbarline2.AnchorPoint = Vector2.new(0.5, 0.5)
	topbarline2.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	topbarline2.BackgroundTransparency = 0.850
	topbarline2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	topbarline2.BorderSizePixel = 0
	topbarline2.Position = UDim2.new(0.5, 0, 1.00980389, 0)
	topbarline2.Size = UDim2.new(1, 0, 0, 1)

	noisemainframebg.Name = "noise.main.frame.bg"
	noisemainframebg.Parent = mainframe
	noisemainframebg.Active = true
	noisemainframebg.AnchorPoint = Vector2.new(0.5, 0.5)
	noisemainframebg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	noisemainframebg.BackgroundTransparency = 1.000
	noisemainframebg.BorderColor3 = Color3.fromRGB(0, 0, 0)
	noisemainframebg.BorderSizePixel = 0
	noisemainframebg.Position = UDim2.new(0.499630719, 0, 0.50050205, 0)
	noisemainframebg.Size = UDim2.new(1.0007385, 0, 1.00100422, 0)
	noisemainframebg.Image = "rbxassetid://9968344105"
	noisemainframebg.ImageTransparency = 0.990
	noisemainframebg.ScaleType = Enum.ScaleType.Tile
	noisemainframebg.TileSize = UDim2.new(0, 128, 0, 128)

	noisemainframebguicorner.Name = "noise.main.frame.bg.uicorner"
	noisemainframebguicorner.Parent = noisemainframebg

	scrollbar.Name = "scrollbar"
	scrollbar.Parent = mainframe
	scrollbar.Active = true
	scrollbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	scrollbar.BackgroundTransparency = 1.000
	scrollbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	scrollbar.BorderSizePixel = 0
	scrollbar.Position = UDim2.new(0, 0, 0.142076507, 0)
	scrollbar.Size = UDim2.new(0, 162, 0, 314)

	scrollingbar.Name = "scrollingbar"
	scrollingbar.Parent = scrollbar
	scrollingbar.Active = true
	scrollingbar.AnchorPoint = Vector2.new(0.5, 0.5)
	scrollingbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	scrollingbar.BackgroundTransparency = 1.000
	scrollingbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	scrollingbar.BorderSizePixel = 0
	scrollingbar.Position = UDim2.new(0.5, 0, 0.484472036, 0)
	scrollingbar.Size = UDim2.new(1, 0, 0.968944073, 0)
	scrollingbar.ScrollBarThickness = 0
	scrollingbar.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingbar.ScrollingEnabled = true
	scrollingbar.Name = "scrollingbar"
	scrollingbar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingbar.CanvasSize = UDim2.new(0,0,0,0)
	scrollingbar.CanvasPosition = Vector2.new(0,0)

	scrollingbaruilistlayout.Name = "scrollingbar.uilistlayout"
	scrollingbaruilistlayout.Parent = scrollingbar
	scrollingbaruilistlayout.SortOrder = Enum.SortOrder.LayoutOrder

	scrollingbaruipadding.Name = "scrollingbar.uipadding"
	scrollingbaruipadding.Parent = scrollingbar
	scrollingbaruipadding.PaddingLeft = UDim.new(0, 5)
	scrollingbaruipadding.PaddingTop = UDim.new(0, 5)

	container.Name = "container"
	container.Parent = mainframe
	container.Active = true
	container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	container.BackgroundTransparency = 1.000
	container.BorderColor3 = Color3.fromRGB(0, 0, 0)
	container.BorderSizePixel = 0
	container.Position = UDim2.new(0.23190546, 0, 0.142076507, 0)
	container.Size = UDim2.new(0, 520, 0, 314)
	container.ClipsDescendants = true

	UIPageLayout.Parent = container
	UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIPageLayout.ScrollWheelInputEnabled = false
	UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	UIPageLayout.TweenTime = 0.5
	UIPageLayout.Circular = true
	UIPageLayout.EasingStyle = Enum.EasingStyle.Cubic

	dropshadow.Name = "dropshadow"
	dropshadow.Parent = xovascript
	dropshadow.AnchorPoint = Vector2.new(0.5, 0.5)
	dropshadow.BackgroundTransparency = 1.000
	dropshadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	dropshadow.Size = UDim2.new(0, 677, 0, 366)
	dropshadow.ZIndex = 0

	shaodwimg.Name = "shaodw.img"
	shaodwimg.Parent = dropshadow
	shaodwimg.Active = true
	shaodwimg.AnchorPoint = Vector2.new(0.5, 0.5)
	shaodwimg.BackgroundTransparency = 1.000
	shaodwimg.Position = UDim2.new(0.5, 0, 0.5, 0)
	shaodwimg.Size = UDim2.new(1.5, 0, 1.5, 0)
	shaodwimg.ZIndex = 0
	shaodwimg.Image = "rbxassetid://16389697796"
	shaodwimg.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shaodwimg.Archivable = false
	shaodwimg.Active = false
	shaodwimg.ClipsDescendants = true

	local xova_section = {}

	xova_section.create = function(args)

		local title = args.Title or tostring("Title")
		local icon = args.Icon or tonumber(6022668883)
		xova_library.layout = xova_library.layout + 1
		local name = "666"

		local buttonbar = Instance.new("TextButton")
		local buttonbartitle = Instance.new("TextLabel")
		local buttonbarimg = Instance.new("ImageLabel")

		buttonbar.Name = "buttonbar"
		buttonbar.Parent = scrollingbar
		buttonbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		buttonbar.BackgroundTransparency = 1.000
		buttonbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		buttonbar.BorderSizePixel = 0
		buttonbar.Size = UDim2.new(0, 152, 0, 30)
		buttonbar.Font = Enum.Font.SourceSans
		buttonbar.TextColor3 = Color3.fromRGB(0, 0, 0)
		buttonbar.TextSize = 14.000
		buttonbar.TextTransparency = 1.000

		buttonbartitle.Name = "buttonbar.title"
		buttonbartitle.Parent = buttonbar
		buttonbartitle.Active = true
		buttonbartitle.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonbartitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		buttonbartitle.BackgroundTransparency = 1.000
		buttonbartitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		buttonbartitle.BorderSizePixel = 0
		buttonbartitle.Position = UDim2.new(0.61250037, 0, 0.5, 0)
		buttonbartitle.Size = UDim2.new(0.775000632, 0, 1, 0)
		buttonbartitle.Font = Enum.Font.ArialBold
		buttonbartitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		buttonbartitle.TextSize = 14.000
		buttonbartitle.TextWrapped = true
		buttonbartitle.TextXAlignment = Enum.TextXAlignment.Left
		buttonbartitle.Text = title
		buttonbartitle.TextTransparency = 0.95

		buttonbarimg.Name = "buttonbar.img"
		buttonbarimg.Parent = buttonbar
		buttonbarimg.Active = true
		buttonbarimg.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonbarimg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		buttonbarimg.BackgroundTransparency = 1.000
		buttonbarimg.BorderColor3 = Color3.fromRGB(0, 0, 0)
		buttonbarimg.BorderSizePixel = 0
		buttonbarimg.Position = UDim2.new(0.119617261, 0, 0.5, 0)
		buttonbarimg.Size = UDim2.new(0, 19, 0, 19)
		buttonbarimg.Image = "http://www.roblox.com/asset/?id="..tostring(icon)
		buttonbarimg.ImageTransparency = 0.95

		local Frame = Instance.new("Frame")
		local UIListLayout = Instance.new("UIListLayout")
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local ScrollingFrame_2 = Instance.new("ScrollingFrame")

		Frame.Parent = container
		Frame.Active = true
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1.000
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.Name = name
		Frame.LayoutOrder = xova_library.layout

		UIListLayout.Parent = Frame
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		ScrollingFrame.Parent = Frame
		ScrollingFrame.Active = true
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Size = UDim2.new(0, 260, 0, 305)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		ScrollingFrame.ScrollingEnabled = true
		ScrollingFrame.Name = "scrollingbar"
		ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
		ScrollingFrame.CanvasPosition = Vector2.new(0,0)

		local UIListLayoutScrollingFrame = Instance.new("UIListLayout")
		local UIPaddingScrollingFrame = Instance.new("UIPadding")

		UIListLayoutScrollingFrame.Parent = ScrollingFrame
		UIListLayoutScrollingFrame.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayoutScrollingFrame.Padding = UDim.new(0, 5)

		UIPaddingScrollingFrame.Parent = ScrollingFrame
		UIPaddingScrollingFrame.PaddingLeft = UDim.new(0, 5)
		UIPaddingScrollingFrame.PaddingTop = UDim.new(0, 5)

		ScrollingFrame_2.Parent = Frame
		ScrollingFrame_2.Active = true
		ScrollingFrame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame_2.BackgroundTransparency = 1.000
		ScrollingFrame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame_2.BorderSizePixel = 0
		ScrollingFrame_2.Size = UDim2.new(0, 260, 0, 305)
		ScrollingFrame_2.ScrollBarThickness = 0
		ScrollingFrame_2.ScrollingDirection = Enum.ScrollingDirection.Y
		ScrollingFrame_2.ScrollingEnabled = true
		ScrollingFrame_2.Name = "scrollingbar"
		ScrollingFrame_2.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ScrollingFrame_2.CanvasSize = UDim2.new(0,0,0,0)
		ScrollingFrame_2.CanvasPosition = Vector2.new(0,0)

		local UIListLayoutScrollingFrame_2 = Instance.new("UIListLayout")
		local UIPaddingScrollingFrame_2 = Instance.new("UIPadding")

		UIListLayoutScrollingFrame_2.Parent = ScrollingFrame_2
		UIListLayoutScrollingFrame_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayoutScrollingFrame_2.Padding = UDim.new(0, 5)

		UIPaddingScrollingFrame_2.Parent = ScrollingFrame_2
		UIPaddingScrollingFrame_2.PaddingLeft = UDim.new(0, 5)
		UIPaddingScrollingFrame_2.PaddingTop = UDim.new(0, 5)

		local get_type = function(args)
			if args == 1 then
				return ScrollingFrame
			else
				return ScrollingFrame_2
			end
		end

		buttonbar.MouseButton1Down:Connect(function()
			if Frame.Name == name then
				UIPageLayout:JumpToIndex(Frame.LayoutOrder)
			end
			for i,v in pairs(scrollingbar:GetChildren()) do
				if v:IsA("TextButton") then
					for i,v in pairs(v:GetChildren()) do
						if v:IsA("TextLabel") then
							tween(v,0.25,Enum.EasingStyle.Circular,{TextColor3 = Color3.fromRGB(255, 255, 255),TextTransparency = 0.95})
						end
						if v:IsA("ImageLabel") then
							tween(v,0.25,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(255, 255, 255),ImageTransparency = 0.95})
						end
					end
				end
				tween(buttonbartitle,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
				tween(buttonbarimg,0.25,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(255, 0, 127),ImageTransparency = 0})
			end
		end)

		if not xova_library.first_exec then
			xova_library.first_exec = true
			if Frame.Name == name then
				UIPageLayout:JumpToIndex(Frame.LayoutOrder)
			end
			for i,v in pairs(scrollingbar:GetChildren()) do
				if v:IsA("TextButton") then
					for i,v in pairs(v:GetChildren()) do
						if v:IsA("TextLabel") then
							tween(v,0.25,Enum.EasingStyle.Circular,{TextColor3 = Color3.fromRGB(255, 255, 255),TextTransparency = 0.95})
						end
						if v:IsA("ImageLabel") then
							tween(v,0.25,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(255, 255, 255),ImageTransparency = 0.95})
						end
					end
				end
				tween(buttonbartitle,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
				tween(buttonbarimg,0.25,Enum.EasingStyle.Circular,{ImageColor3 = Color3.fromRGB(255, 0, 127),ImageTransparency = 0})
			end
		end

		local xova_page = {}

		xova_page.create = function(args)
			local Type = args.Side or 1
			local Title = args.Title or tostring("General")

			local FramePage = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIListLayoutFrame = Instance.new("UIListLayout")
			local TextLabel = Instance.new("TextLabel")
			local UIPadding = Instance.new("UIPadding")

			FramePage.Parent = get_type(Type)
			FramePage.Active = true
			FramePage.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
			FramePage.BackgroundTransparency = 0.500
			FramePage.BorderColor3 = Color3.fromRGB(0, 0, 0)
			FramePage.BorderSizePixel = 0
			FramePage.Size = UDim2.new(0, 250, 0, 291)

			stroke(FramePage,0,1,Color3.fromRGB(7, 7, 7))

			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = FramePage

			UIListLayoutFrame.Parent = FramePage
			UIListLayoutFrame.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayoutFrame.Padding = UDim.new(0,5)

			TextLabel.Parent = FramePage
			TextLabel.Active = true
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Size = UDim2.new(0, 230, 0, 18)
			TextLabel.Font = Enum.Font.ArialBold
			TextLabel.Text = Title
			TextLabel.TextColor3 = Color3.fromRGB(203, 0, 108)
			TextLabel.TextSize = 12.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			UIPadding.Parent = FramePage
			UIPadding.PaddingLeft = UDim.new(0, 10)
			UIPadding.PaddingTop = UDim.new(0, 5)

			UIListLayoutFrame:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				FramePage.Size = UDim2.new(0, 250, 0,UIListLayoutFrame.AbsoluteContentSize.Y + 10)
			end)

			local xova_func = {}

			xova_func.Slider = function(args)

				local Title = args.Title or tostring("Title")
				local Max = args.Max or 100
				local Min = args.Min or 0
				local Default = args.Default or 10
				local callback = args.Callback or function() end
				local Dec = args.Dec or false
				local Sliderfunc = {}
				local Desc = args.Desc or tostring("Description")
				local ToolTip = args.ToolTip or false

				local Frame = Instance.new("Frame")
				local TextButton = Instance.new("TextButton")
				local TextLabel = Instance.new("TextLabel")
				local TextBox = Instance.new("TextBox")
				local Frame_2 = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local Frame_3 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local Frame_4 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local ImageLabel = Instance.new("ImageLabel")

				Frame.Parent = FramePage
				Frame.Active = true
				Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Frame.BackgroundTransparency = 1.000
				Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(0, 0, 0.178321674, 0)
				Frame.Size = UDim2.new(0, 230, 0, 37)

				if ToolTip then
					add_tooltip(Frame,Title,Desc)
				end

				TextButton.Parent = Frame
				TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 1.000
				TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.BorderSizePixel = 0
				TextButton.Position = UDim2.new(0.5, 0, 0.681818187, 0)
				TextButton.Size = UDim2.new(1, 0, 1.36363637, 0)
				TextButton.Font = Enum.Font.SourceSans
				TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.TextSize = 14.000
				TextButton.TextTransparency = 1.000

				TextLabel.Parent = TextButton
				TextLabel.Active = true
				TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.202173918, 0, 0.247747749, 0)
				TextLabel.Size = UDim2.new(0, 93, 0, 18)
				TextLabel.Font = Enum.Font.ArialBold
				TextLabel.Text = Title
				TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.TextSize = 12.000
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.TextTransparency = 0.75

				TextBox.Parent = TextButton
				TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
				TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.BackgroundTransparency = 1.000
				TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextBox.BorderSizePixel = 0
				TextBox.ClipsDescendants = true
				TextBox.Position = UDim2.new(0.870456576, 0, 0.547013223, 0)
				TextBox.Size = UDim2.new(0, 57, 0, 12)
				TextBox.Font = Enum.Font.ArialBold
				TextBox.PlaceholderColor3 = Color3.fromRGB(76, 76, 76)
				TextBox.PlaceholderText = "%"
				TextBox.Text = ""
				TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.TextSize = 14.000
				TextBox.TextWrapped = true
				TextBox.TextXAlignment = Enum.TextXAlignment.Right

				Frame_2.Parent = Frame
				Frame_2.Active = true
				Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame_2.BackgroundColor3 = Color3.fromRGB(13, 0, 7)
				Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_2.BorderSizePixel = 0
				Frame_2.Position = UDim2.new(0.717391312, 0, 0.337837845, 0)
				Frame_2.Size = UDim2.new(0, 128, 0, 7)

				UICorner.Parent = Frame_2

				Frame_3.Parent = Frame_2
				Frame_3.Active = true
				Frame_3.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
				Frame_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_3.BorderSizePixel = 0
				Frame_3.Size = UDim2.new((Default)/ Max, 0, 0, 7)

				UICorner_2.Parent = Frame_3

				Frame_4.Parent = Frame_2
				Frame_4.Active = true
				Frame_4.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Frame_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_4.BorderSizePixel = 0
				Frame_4.Position = UDim2.new((Default or 0)/Max, 0.5, 0.5,0.5, 0)
				Frame_4.Size = UDim2.new(0, 13, 0, 13)

				UICorner_3.CornerRadius = UDim.new(0, 30)
				UICorner_3.Parent = Frame_4

				ImageLabel.Parent = Frame_4
				ImageLabel.Active = true
				ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1.000
				ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ImageLabel.BorderSizePixel = 0
				ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel.Size = UDim2.new(1.60000002, 0, 1.60000002, 0)
				ImageLabel.Image = "rbxassetid://17274099950"
				ImageLabel.ScaleType = Enum.ScaleType.Crop

				if Dec then
					TextBox.Text = tostring(Default and string.format("%.2f",Default or 0)).." %"
				else
					TextBox.Text = tostring(math.floor(((Default - Min) / (Max - Min)) * (Max - Min) + Min)).." %"
				end

				local function move(input)
					local pos =
						UDim2.new(
							math.clamp((input.Position.X - Frame.AbsolutePosition.X) / Frame.AbsoluteSize.X, 0, 1),
							0,
							0.5,
							0
						)
					local pos1 =
						UDim2.new(
							math.clamp((input.Position.X - Frame.AbsolutePosition.X) / Frame.AbsoluteSize.X, 0, 1),
							0,
							0,
							7
						)

					Frame_3:TweenSize(pos1, "Out", "Back", 0.5, true)
					Frame_4:TweenPosition(pos, "Out", "Back", 0.5, true)
					if Dec then
						local value = string.format("%.2f",((pos.X.Scale * Max) / Max) * (Max - Min) + Min)
						TextBox.Text = tostring(value).." %"
						callback(value)
					else
						local value = math.floor(((pos.X.Scale * Max) / Max) * (Max - Min) + Min)
						TextBox.Text = tostring(value).." %"
						callback(value)
					end
				end

				local dragging = false

				TextButton.MouseEnter:Connect(function()
					tween(TextLabel,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
				end)

				TextButton.MouseLeave:Connect(function()
					tween(TextLabel,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0.75})
				end)

				TextButton.InputBegan:Connect(
					function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							dragging = true
						end
					end)
				TextButton.InputEnded:Connect(
					function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							dragging = false
						end
					end)

				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						move(input)
					end
				end)

				TextBox.FocusLost:Connect(function()
					local value = tonumber(TextBox.Text)
					if value > Max then
						TextBox.Text = Max.." %"
						tween(Frame_3,0.5,Enum.EasingStyle.Back,{Size = UDim2.new((Max)/ Max, 0, 0, 7)})
						tween(Frame_4,0.5,Enum.EasingStyle.Back,{Position = UDim2.new((Max)/ Max, 0, 0.5, 0)})
					elseif value < Min then
						TextBox.Text = Min.." %"
						tween(Frame_3,0.5,Enum.EasingStyle.Back,{Size = UDim2.new((Min)/ Max, 0, 0, 7)})
						tween(Frame_4,0.5,Enum.EasingStyle.Back,{Position = UDim2.new((Min)/ Max, 0, 0.5, 0)})
					else
						TextBox.Text = value.." %"
						tween(Frame_3,0.5,Enum.EasingStyle.Back,{Size = UDim2.new((tonumber(value))/ Max, 0, 0, 7)})
						tween(Frame_4,0.5,Enum.EasingStyle.Back,{Position = UDim2.new((tonumber(value))/ Max, 0, 0.5, 0)})
					end
					pcall(args.Callback, tonumber(value))
				end)
			end

			xova_func.Dropdown = function(args)

				local Title = args.Title or tostring("Dropdown")
				local List = args.List or {}
				local Default = args.Default or {}
				local Callback = args.Callback or function() end
				local Dropdown_func = {}
				local Mode = args.Mode or false

				local DropdownFrame = Instance.new("Frame")
				local DropdownFrameUICorner = Instance.new("UICorner")
				local DropdownButton = Instance.new("TextButton")
				local TextHead = Instance.new("TextLabel")
				local Arrow = Instance.new("ImageLabel")
				local SelectionFrame = Instance.new("Frame")
				local SelectionFrameUICorner = Instance.new("UICorner")
				local ScrollingSelection = Instance.new("ScrollingFrame")
				local ScrollingSelectionUIListLayout = Instance.new("UIListLayout")
				local ScrollingSelectionUIPadding = Instance.new("UIPadding")
				local CheckIcon = Instance.new("ImageLabel")
				local SearchFrame = Instance.new("Frame")
				local SearchFrameUICorner = Instance.new("UICorner")
				local SearchBar = Instance.new("TextBox")

				DropdownFrame.Name = "DropdownFrame"
				DropdownFrame.Parent = FramePage
				DropdownFrame.Active = true
				DropdownFrame.BackgroundColor3 = Color3.fromRGB(5,5,5)
				DropdownFrame.BorderSizePixel = 0
				DropdownFrame.ClipsDescendants = true
				DropdownFrame.Position = UDim2.new(0, 0, 0.307692319, 0)
				DropdownFrame.Size = UDim2.new(0, 234, 0, 28)

				DropdownFrameUICorner.CornerRadius = UDim.new(0, 4)
				DropdownFrameUICorner.Name = "DropdownFrameUICorner"
				DropdownFrameUICorner.Parent = DropdownFrame

				DropdownButton.Name = "DropdownButton"
				DropdownButton.Parent = DropdownFrame
				DropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				DropdownButton.BackgroundTransparency = 1.000
				DropdownButton.Size = UDim2.new(0, 280, 0, 35)
				DropdownButton.Font = Enum.Font.GothamBold
				DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				DropdownButton.TextSize = 12.000
				DropdownButton.TextTransparency = 1.000

				TextHead.Name = "TextHead"
				TextHead.Parent = DropdownButton
				TextHead.Active = true
				TextHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextHead.BackgroundTransparency = 1.000
				TextHead.Position = UDim2.new(0.037785992, 0, 0, 0)
				TextHead.Size = UDim2.new(0, 193, 0, 28)
				TextHead.Font = Enum.Font.Arial
				TextHead.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextHead.TextSize = 12.000
				TextHead.TextTransparency = 0.450
				TextHead.TextXAlignment = Enum.TextXAlignment.Left
				TextHead.Text = Title

				Arrow.Name = "Arrow"
				Arrow.Parent = TextHead
				Arrow.Active = true
				Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
				Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Arrow.BackgroundTransparency = 1.000
				Arrow.Position = UDim2.new(1.0713675, 0, 0.5, 0)
				Arrow.Size = UDim2.new(0, 15, 0, 15)
				Arrow.Image = "rbxassetid://11409365068"
				Arrow.ImageTransparency = 0.450

				SelectionFrame.Name = "SelectionFrame"
				SelectionFrame.Parent = TextHead
				SelectionFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
				SelectionFrame.BackgroundTransparency = 0.200
				SelectionFrame.Position = UDim2.new(0, 0, 2.1714282, 0)
				SelectionFrame.Size = UDim2.new(0, 214, 0, 190)

				SelectionFrameUICorner.Name = "SelectionFrameUICorner"
				SelectionFrameUICorner.Parent = SelectionFrame
				SelectionFrameUICorner.CornerRadius = UDim.new(0,4)

				ScrollingSelection.Name = "ScrollingSelection"
				ScrollingSelection.Parent = SelectionFrame
				ScrollingSelection.Active = true
				ScrollingSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ScrollingSelection.BackgroundTransparency = 1.000
				ScrollingSelection.BorderSizePixel = 0
				ScrollingSelection.Size = UDim2.new(0, 260, 0, 180)
				ScrollingSelection.BottomImage = ""
				ScrollingSelection.ScrollBarThickness = 0
				ScrollingSelection.TopImage = ""

				ScrollingSelectionUIListLayout.Name = "ScrollingSelectionUIListLayout"
				ScrollingSelectionUIListLayout.Parent = ScrollingSelection
				ScrollingSelectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ScrollingSelectionUIListLayout.Padding = UDim.new(0, 5)

				ScrollingSelectionUIPadding.Name = "ScrollingSelectionUIPadding"
				ScrollingSelectionUIPadding.Parent = ScrollingSelection
				ScrollingSelectionUIPadding.PaddingLeft = UDim.new(0, 5)
				ScrollingSelectionUIPadding.PaddingTop = UDim.new(0, 5)

				SearchFrame.Name = "SearchFrame"
				SearchFrame.Parent = TextHead
				SearchFrame.BackgroundColor3 = Color3.fromRGB(26, 27, 31)
				SearchFrame.BackgroundTransparency = 1.000
				SearchFrame.Position = UDim2.new(0, 0, 1, 0)
				SearchFrame.Size = UDim2.new(0, 214, 0, 35)

				SearchFrameUICorner.Name = "SearchFrameUICorner"
				SearchFrameUICorner.Parent = SearchFrame

				SearchBar.Name = "SearchBar"
				SearchBar.Parent = SearchFrame
				SearchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				SearchBar.BackgroundTransparency = 1.000
				SearchBar.Size = UDim2.new(0, 261, 0, 35)
				SearchBar.Font = Enum.Font.Arial
				SearchBar.PlaceholderText = "Search..."
				SearchBar.Text = ""
				SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
				SearchBar.TextSize = 12.000
				SearchBar.TextTransparency = 0.450
				SearchBar.TextXAlignment = Enum.TextXAlignment.Left

				local dropdownfocus = false

				DropdownButton.MouseButton1Down:Connect(function()
					if dropdownfocus == false then
						tween(DropdownFrame,0.2,Enum.EasingStyle.Quart,{Size = UDim2.new(0, 234, 0, 262)})
						tween(Arrow,0.2,Enum.EasingStyle.Quart,{Rotation = 90})
						tween(Arrow,0.2,Enum.EasingStyle.Quart,{ImageTransparency = 0})
					else
						tween(DropdownFrame,0.2,Enum.EasingStyle.Quart,{Size = UDim2.new(0, 234, 0, 28)})
						tween(Arrow,0.2,Enum.EasingStyle.Quart,{Rotation = 0})
						tween(Arrow,0.2,Enum.EasingStyle.Quart,{ImageTransparency = 0.45})
					end
					dropdownfocus = not dropdownfocus
					ScrollingSelection.CanvasSize = UDim2.new(0,0,0,ScrollingSelectionUIListLayout.AbsoluteContentSize.Y + 10)
				end)

				SearchBar.Focused:Connect(function()
					tween(SearchBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
				end)

				SearchBar.FocusLost:Connect(function()
					tween(SearchBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
				end)

				function UpdateInputOfSearchText()
					local InputText = string.upper(SearchBar.Text)
					if not Mode then
						for _,button in pairs(ScrollingSelection:GetChildren())do
							if button:IsA("TextButton") then
								if InputText == "" or string.find(string.upper(button.Text),InputText) ~= nil then
									button.Visible = true
								else
									button.Visible = false
								end
							end
						end
					else
						for _,button in pairs(ScrollingSelection:GetChildren())do
							if button:IsA("TextButton") then
								for i,v in pairs(button:GetChildren()) do
									if v:IsA("TextLabel") then
										if InputText == "" or string.find(string.upper(v.Text),InputText) ~= nil then
											button.Visible = true
										else
											button.Visible = false
										end
									end
								end
							end
						end
					end
				end

				SearchBar.Changed:Connect(UpdateInputOfSearchText)

				if not Mode then
					for i,v in pairs(List) do
						local ButtonBar = Instance.new("TextButton")
						local ButtonBarUICorner = Instance.new("UICorner")

						ButtonBar.Name = "ButtonBar"
						ButtonBar.Parent = ScrollingSelection
						ButtonBar.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ButtonBar.BorderSizePixel = 0
						ButtonBar.ClipsDescendants = true
						ButtonBar.Size = UDim2.new(0, 205, 0, 20)
						ButtonBar.Font = Enum.Font.GothamBold
						ButtonBar.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonBar.TextSize = 12.000
						ButtonBar.TextTransparency = 0.450
						ButtonBar.Text = v
						ButtonBar.AutoButtonColor = false

						ButtonBarUICorner.CornerRadius = UDim.new(0, 4)
						ButtonBarUICorner.Name = "ButtonBarUICorner"
						ButtonBarUICorner.Parent = ButtonBar

						if Default == v then
							for i,v in next,ScrollingSelection:GetChildren() do
								if v:IsA("TextButton") then
									tween(v,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
									tween(v,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(14,14,14)})
								end
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
							end
							TextHead.Text = Title.." ( "..v.." )"
							Callback(Default)
						end

						ButtonBar.MouseButton1Down:Connect(function()
							for i,v in next,ScrollingSelection:GetChildren() do
								if v:IsA("TextButton") then
									tween(v,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
									tween(v,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(14,14,14)})
								end
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
							end
							TextHead.Text = Title.." ( "..v.." )"
							Callback(v)
						end)
					end

					local drop_func = {}

					drop_func.Clear = function()
						for i,v in next,ScrollingSelection:GetChildren() do
							if v:IsA("TextButton") then
								v:Destroy()
							end
						end
						Callback(nil)
						TextHead.Text = Title
					end

					drop_func.Add = function(v)
						local ButtonBar = Instance.new("TextButton")
						local ButtonBarUICorner = Instance.new("UICorner")

						ButtonBar.Name = "ButtonBar"
						ButtonBar.Parent = ScrollingSelection
						ButtonBar.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ButtonBar.BorderSizePixel = 0
						ButtonBar.ClipsDescendants = true
						ButtonBar.Size = UDim2.new(0, 205, 0, 20)
						ButtonBar.Font = Enum.Font.GothamBold
						ButtonBar.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonBar.TextSize = 12.000
						ButtonBar.TextTransparency = 0.450
						ButtonBar.Text = v
						ButtonBar.AutoButtonColor = false

						ButtonBarUICorner.CornerRadius = UDim.new(0, 4)
						ButtonBarUICorner.Name = "ButtonBarUICorner"
						ButtonBarUICorner.Parent = ButtonBar

						ButtonBar.MouseButton1Down:Connect(function()
							for i,v in next,ScrollingSelection:GetChildren() do
								if v:IsA("TextButton") then
									tween(v,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
									tween(v,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(14,14,14)})
								end
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
							end
							TextHead.Text = Title.." ( "..v.." )"
							Callback(v)
						end)
						ScrollingSelection.CanvasSize = UDim2.new(0,0,0,ScrollingSelectionUIListLayout.AbsoluteContentSize.Y + 10)
					end
					return drop_func
				else
					local MultiDropdown = {}

					for i,v in pairs(List) do
						local ButtonBar = Instance.new("TextButton")
						local ButtonText = Instance.new("TextLabel")
						local ToggleInner = Instance.new("ImageLabel")
						local ToggleInnerUICorner = Instance.new("UICorner")
						local ToggleInner2 = Instance.new("ImageLabel")
						local ToggleInnerUICorner_2 = Instance.new("UICorner")
						local ToggleInner2UIGradient = Instance.new("UIGradient")
						local CheckIcon = Instance.new("ImageLabel")

						ButtonBar.Name = "ButtonBar"
						ButtonBar.Parent = ScrollingSelection
						ButtonBar.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ButtonBar.BackgroundTransparency = 1.000
						ButtonBar.BorderSizePixel = 0
						ButtonBar.ClipsDescendants = true
						ButtonBar.Size = UDim2.new(0, 250, 0, 30)
						ButtonBar.Font = Enum.Font.GothamBold
						ButtonBar.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonBar.TextSize = 12.000
						ButtonBar.TextTransparency = 1.000

						ButtonText.Name = "ButtonText"
						ButtonText.Parent = ButtonBar
						ButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ButtonText.BackgroundTransparency = 1.000
						ButtonText.Position = UDim2.new(0.140000001, 0, 0, 0)
						ButtonText.Size = UDim2.new(0, 215, 0, 30)
						ButtonText.Font = Enum.Font.GothamBold
						ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonText.TextSize = 12.000
						ButtonText.TextTransparency = 0.450
						ButtonText.TextXAlignment = Enum.TextXAlignment.Left
						ButtonText.Text = v

						ToggleInner.Name = "ToggleInner"
						ToggleInner.Parent = ButtonBar
						ToggleInner.Active = true
						ToggleInner.AnchorPoint = Vector2.new(0.5, 0.5)
						ToggleInner.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ToggleInner.Position = UDim2.new(0.0700000003, 0, 0.5, 0)
						ToggleInner.Size = UDim2.new(0, 19, 0, 19)
						ToggleInner.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
						ToggleInner.ImageColor3 = Color3.fromRGB(40, 40, 40)
						ToggleInner.ImageTransparency = 1.000
						ToggleInner.BorderSizePixel = 0

						ToggleInnerUICorner.CornerRadius = UDim.new(0, 4)
						ToggleInnerUICorner.Name = "ToggleInnerUICorner"
						ToggleInnerUICorner.Parent = ToggleInner

						ToggleInner2.Name = "ToggleInner2"
						ToggleInner2.Parent = ToggleInner
						ToggleInner2.Active = true
						ToggleInner2.AnchorPoint = Vector2.new(0.5, 0.5)
						ToggleInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ToggleInner2.ClipsDescendants = true
						ToggleInner2.Position = UDim2.new(0.5, 0, 0.5, 0)
						ToggleInner2.Size = UDim2.new(0, 0, 0, 0)
						ToggleInner2.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
						ToggleInner2.ImageColor3 = Color3.fromRGB(255, 0, 127)
						ToggleInner2.ImageTransparency = 1.000
						ToggleInner2.BorderSizePixel = 0

						ToggleInnerUICorner_2.CornerRadius = UDim.new(0, 4)
						ToggleInnerUICorner_2.Name = "ToggleInnerUICorner"
						ToggleInnerUICorner_2.Parent = ToggleInner2

						ToggleInner2UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 127)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(198, 0, 99))}
						ToggleInner2UIGradient.Rotation = 90
						ToggleInner2UIGradient.Name = "ToggleInner2UIGradient"
						ToggleInner2UIGradient.Parent = ToggleInner2

						CheckIcon.Name = "CheckIcon"
						CheckIcon.Parent = ToggleInner2
						CheckIcon.Active = true
						CheckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
						CheckIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						CheckIcon.BackgroundTransparency = 1.000
						CheckIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
						CheckIcon.Size = UDim2.new(0, 15, 0, 15)
						CheckIcon.Image = "rbxassetid://11287988323"
						CheckIcon.ImageColor3 = Color3.fromRGB(26, 27, 31)

						for o,p in pairs(Default) do
							if v == p  then
								tween(ButtonText,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ToggleInner2,0.2,Enum.EasingStyle.Back,{Size = UDim2.new(0, 19, 0, 19)})
								table.insert(MultiDropdown,p)
								TextHead.Text = Title.." ( "..(table.concat(MultiDropdown,",")).." )"
								pcall(Callback,p)
								pcall(Callback,MultiDropdown)
							end
						end

						ButtonBar.MouseButton1Down:Connect(function()
							if tablefound(MultiDropdown,v) == false then
								table.insert(MultiDropdown,v)
								tween(ButtonText,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ToggleInner2,0.2,Enum.EasingStyle.Back,{Size = UDim2.new(0, 19, 0, 19)})
							else
								for ine,va in pairs(MultiDropdown) do
									if va == v then
										table.remove(MultiDropdown,ine)
									end
								end
								tween(ButtonText,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
								tween(ToggleInner2,0.2,Enum.EasingStyle.Back,{Size = UDim2.new(0, 0, 0, 0)})
							end
							TextHead.Text = Title.." ( "..(table.concat(MultiDropdown,",")).." )"
							pcall(Callback,MultiDropdown)
						end)
					end

					local drop_func = {}

					drop_func.Clear = function()
						for i,v in next,ScrollingSelection:GetChildren() do
							if v:IsA("TextButton") then
								v:Destroy()
							end
						end
						Callback({})
						TextHead.Text = Title
					end

					drop_func.Add = function(v)
						local ButtonBar = Instance.new("TextButton")
						local ButtonText = Instance.new("TextLabel")
						local ToggleInner = Instance.new("ImageLabel")
						local ToggleInnerUICorner = Instance.new("UICorner")
						local ToggleInner2 = Instance.new("ImageLabel")
						local ToggleInnerUICorner_2 = Instance.new("UICorner")
						local ToggleInner2UIGradient = Instance.new("UIGradient")
						local CheckIcon = Instance.new("ImageLabel")

						ButtonBar.Name = "ButtonBar"
						ButtonBar.Parent = ScrollingSelection
						ButtonBar.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ButtonBar.BackgroundTransparency = 1.000
						ButtonBar.BorderSizePixel = 0
						ButtonBar.ClipsDescendants = true
						ButtonBar.Size = UDim2.new(0, 250, 0, 30)
						ButtonBar.Font = Enum.Font.GothamBold
						ButtonBar.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonBar.TextSize = 12.000
						ButtonBar.TextTransparency = 1.000

						ButtonText.Name = "ButtonText"
						ButtonText.Parent = ButtonBar
						ButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ButtonText.BackgroundTransparency = 1.000
						ButtonText.Position = UDim2.new(0.140000001, 0, 0, 0)
						ButtonText.Size = UDim2.new(0, 215, 0, 30)
						ButtonText.Font = Enum.Font.GothamBold
						ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
						ButtonText.TextSize = 12.000
						ButtonText.TextTransparency = 0.450
						ButtonText.TextXAlignment = Enum.TextXAlignment.Left
						ButtonText.Text = v

						ToggleInner.Name = "ToggleInner"
						ToggleInner.Parent = ButtonBar
						ToggleInner.Active = true
						ToggleInner.AnchorPoint = Vector2.new(0.5, 0.5)
						ToggleInner.BackgroundColor3 = Color3.fromRGB(14,14,14)
						ToggleInner.Position = UDim2.new(0.0700000003, 0, 0.5, 0)
						ToggleInner.Size = UDim2.new(0, 19, 0, 19)
						ToggleInner.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
						ToggleInner.ImageColor3 = Color3.fromRGB(40, 40, 40)
						ToggleInner.ImageTransparency = 1.000
						ToggleInner.BorderSizePixel = 0

						ToggleInnerUICorner.CornerRadius = UDim.new(0, 4)
						ToggleInnerUICorner.Name = "ToggleInnerUICorner"
						ToggleInnerUICorner.Parent = ToggleInner

						ToggleInner2.Name = "ToggleInner2"
						ToggleInner2.Parent = ToggleInner
						ToggleInner2.Active = true
						ToggleInner2.AnchorPoint = Vector2.new(0.5, 0.5)
						ToggleInner2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						ToggleInner2.ClipsDescendants = true
						ToggleInner2.Position = UDim2.new(0.5, 0, 0.5, 0)
						ToggleInner2.Size = UDim2.new(0, 0, 0, 0)
						ToggleInner2.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
						ToggleInner2.ImageColor3 = Color3.fromRGB(255, 0, 127)
						ToggleInner2.ImageTransparency = 1.000
						ToggleInner2.BorderSizePixel = 0

						ToggleInnerUICorner_2.CornerRadius = UDim.new(0, 4)
						ToggleInnerUICorner_2.Name = "ToggleInnerUICorner"
						ToggleInnerUICorner_2.Parent = ToggleInner2

						ToggleInner2UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 127)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(198, 0, 99))}
						ToggleInner2UIGradient.Rotation = 90
						ToggleInner2UIGradient.Name = "ToggleInner2UIGradient"
						ToggleInner2UIGradient.Parent = ToggleInner2

						CheckIcon.Name = "CheckIcon"
						CheckIcon.Parent = ToggleInner2
						CheckIcon.Active = true
						CheckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
						CheckIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						CheckIcon.BackgroundTransparency = 1.000
						CheckIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
						CheckIcon.Size = UDim2.new(0, 15, 0, 15)
						CheckIcon.Image = "rbxassetid://11287988323"
						CheckIcon.ImageColor3 = Color3.fromRGB(26, 27, 31)

						ButtonBar.MouseButton1Down:Connect(function()
							if tablefound(MultiDropdown,v) == false then
								table.insert(MultiDropdown,v)
								tween(ButtonText,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
								tween(ToggleInner2,0.2,Enum.EasingStyle.Back,{Size = UDim2.new(0, 19, 0, 19)})
							else
								for ine,va in pairs(MultiDropdown) do
									if va == v then
										table.remove(MultiDropdown,ine)
									end
								end
								tween(ButtonText,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
								tween(ToggleInner2,0.2,Enum.EasingStyle.Back,{Size = UDim2.new(0, 0, 0, 0)})
							end
							TextHead.Text = Title.." ( "..(table.concat(MultiDropdown,",")).." )"
							pcall(Callback,MultiDropdown)
						end)
						ScrollingSelection.CanvasSize = UDim2.new(0,0,0,ScrollingSelectionUIListLayout.AbsoluteContentSize.Y + 10)
					end

					drop_func.Set = function(ta)
						for i,v in pairs(ta) do 
							drop_func.Add(v)
						end
					end

					return drop_func
				end
			end

			xova_func.Button = function(args)

				local Title = args.Title or tostring("Button")
				local Callback = args.Callback or function() end

				local ButtonBar = Instance.new("TextButton")
				local ButtonBarUICorner = Instance.new("UICorner")

				ButtonBar.Name = "ButtonBar"
				ButtonBar.Parent = FramePage
				ButtonBar.BackgroundColor3 = Color3.fromRGB(14,14,14)
				ButtonBar.BorderSizePixel = 0
				ButtonBar.ClipsDescendants = true
				ButtonBar.Size = UDim2.new(0, 234, 0, 20)
				ButtonBar.Font = Enum.Font.GothamBold
				ButtonBar.TextColor3 = Color3.fromRGB(255, 255, 255)
				ButtonBar.TextSize = 12.000
				ButtonBar.TextTransparency = 0.450
				ButtonBar.Text = Title
				ButtonBar.AutoButtonColor = false

				ButtonBarUICorner.CornerRadius = UDim.new(0, 4)
				ButtonBarUICorner.Name = "ButtonBarUICorner"
				ButtonBarUICorner.Parent = ButtonBar

				ButtonBar.MouseEnter:Connect(function()
					tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
					tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
				end)

				ButtonBar.MouseLeave:Connect(function()
					tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.45})
					tween(ButtonBar,0.2,Enum.EasingStyle.Quart,{BackgroundColor3 = Color3.fromRGB(14,14,14)})
				end)

				ButtonBar.MouseButton1Down:Connect(function()
					CircleAnim("Circle3",ButtonBar,Color3.fromRGB(0, 0, 0),Color3.fromRGB(0, 0, 0))
					pcall(Callback)
				end)
			end

			xova_func.TextBox = function(args)
				local Title = args.Title or "TextBox"
				local Holder = args.Holder or "Write"
				local callback = args.callback or function() end

				local TextBoxFrame = Instance.new("Frame")
				local TextBoxFrameUICorner = Instance.new("UICorner")
				local TextHead = Instance.new("TextLabel")
				local TextBox = Instance.new("TextBox")

				TextBoxFrame.Name = "TextBoxFrame"
				TextBoxFrame.Parent = FramePage
				TextBoxFrame.BackgroundColor3 = Color3.fromRGB(5,5,5)
				TextBoxFrame.Size = UDim2.new(0, 234, 0, 55)

				TextBoxFrameUICorner.CornerRadius = UDim.new(0, 4)
				TextBoxFrameUICorner.Name = "TextBoxFrameUICorner"
				TextBoxFrameUICorner.Parent = TextBoxFrame

				TextHead.Name = "TextHead"
				TextHead.Parent = TextBoxFrame
				TextHead.Active = true
				TextHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextHead.BackgroundTransparency = 1.000
				TextHead.Position = UDim2.new(0.037785992, 0, 0, 0)
				TextHead.Size = UDim2.new(0, 224, 0, 27)
				TextHead.Font = Enum.Font.Arial
				TextHead.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextHead.TextSize = 12.000
				TextHead.TextTransparency = 0.450
				TextHead.TextXAlignment = Enum.TextXAlignment.Left
				TextHead.Text = Title

				TextBox.Parent = TextBoxFrame
				TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.BackgroundTransparency = 1.000
				TextBox.Position = UDim2.new(0.037785992, 0, 0.4909091, 0)
				TextBox.Size = UDim2.new(0, 220, 0, 23)
				TextBox.Font = Enum.Font.ArialBold
				TextBox.PlaceholderText = ""
				TextBox.Text = Holder
				TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.TextSize = 12.000
				TextBox.TextTransparency = 0.9
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.ClipsDescendants = true

				TextBox.Focused:Connect(function()
					tween(TextBox,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0})
				end)

				TextBox.FocusLost:Connect(function()
					tween(TextBox,0.2,Enum.EasingStyle.Quart,{TextTransparency = 0.9})
				end)

				TextBox.FocusLost:Connect(function(ep)
					if ep then
						if #TextBox.Text > 0 then
							pcall(callback, TextBox.Text)
						end
					end
				end)
			end

			xova_func.Label = function(args)
				local Title = args.Title or tostring("Title")
				local label_func = {}

				local TextLabel = Instance.new("TextLabel")

				TextLabel.Parent = FramePage
				TextLabel.Active = true
				TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.393478274, 0, 0.5, 0)
				TextLabel.Size = UDim2.new(0, 220, 0, 18)
				TextLabel.Font = Enum.Font.ArialBold
				TextLabel.Text = Title
				TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.TextSize = 12.000
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.TextTransparency = 0.75

				label_func.Update = function()
					return TextLabel
				end
				return label_func
			end

			xova_func.Toggle = function(args)

				local Title = args.Title or tostring("Toggle")
				local Callback = args.Callback or function() end
				local Default = args.Default or false
				local Togglefunc = {}
				local Desc = args.Desc or tostring("Description")
				local ToolTip = args.ToolTip or false

				local Frame = Instance.new("Frame")
				local TextButton = Instance.new("TextButton")
				local TextLabel = Instance.new("TextLabel")
				local Frame_2 = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local Frame_3 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local ImageLabel = Instance.new("ImageLabel")

				if ToolTip then
					add_tooltip(Frame,Title,Desc)
				end

				Frame.Parent = FramePage
				Frame.Active = true
				Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Frame.BackgroundTransparency = 1.000
				Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(0, 0, 0.062937066, 0)
				Frame.Size = UDim2.new(0, 230, 0, 33)

				TextButton.Parent = Frame
				TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 1.000
				TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.BorderSizePixel = 0
				TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextButton.Size = UDim2.new(1, 0, 1, 0)
				TextButton.Font = Enum.Font.SourceSans
				TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.TextSize = 14.000
				TextButton.TextTransparency = 1.000

				TextLabel.Parent = TextButton
				TextLabel.Active = true
				TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Position = UDim2.new(0.393478274, 0, 0.5, 0)
				TextLabel.Size = UDim2.new(0, 181, 0, 18)
				TextLabel.Font = Enum.Font.ArialBold
				TextLabel.Text = Title
				TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel.TextSize = 12.000
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.TextTransparency = 0.75

				Frame_2.Parent = TextButton
				Frame_2.Active = true
				Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame_2.BackgroundColor3 = Color3.fromRGB(13, 0, 7)
				Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_2.BorderSizePixel = 0
				Frame_2.Position = UDim2.new(0.913043499, 0, 0.5, 0)
				Frame_2.Size = UDim2.new(0, 38, 0, 13)

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = Frame_2

				Frame_3.Parent = Frame_2
				Frame_3.Active = true
				Frame_3.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame_3.BackgroundColor3 = Color3.fromRGB(38, 0, 19)
				Frame_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_3.BorderSizePixel = 0
				Frame_3.Position = UDim2.new(0.25, 0, 0.5, 0)
				Frame_3.Size = UDim2.new(0, 19, 0, 19)

				UICorner_2.CornerRadius = UDim.new(0, 30)
				UICorner_2.Parent = Frame_3

				ImageLabel.Parent = Frame_3
				ImageLabel.Active = true
				ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1.000
				ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ImageLabel.BorderSizePixel = 0
				ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageLabel.Size = UDim2.new(1.6, 0, 1.6, 0)
				ImageLabel.Image = "rbxassetid://17274099950"
				ImageLabel.ImageColor3 = Color3.fromRGB(255, 0, 127)
				ImageLabel.ScaleType = Enum.ScaleType.Crop
				ImageLabel.ImageTransparency = 1

				local focus = false

				if Default then
					tween(Frame_2,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(38, 0, 19)})
					tween(TextLabel,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
					tween(Frame_3,0.25,Enum.EasingStyle.Circular,{Position = UDim2.new(0.75, 0, 0.5, 0),BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
					tween(ImageLabel,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 0})
					Callback(focus)
				end

				TextButton.MouseButton1Down:Connect(function()
					if not focus then
						tween(Frame_2,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(38, 0, 19)})
						tween(TextLabel,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0})
						tween(Frame_3,0.25,Enum.EasingStyle.Circular,{Position = UDim2.new(0.75, 0, 0.5, 0),BackgroundColor3 = Color3.fromRGB(255, 0, 127)})
						tween(ImageLabel,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 0})
					else
						tween(Frame_2,0.25,Enum.EasingStyle.Circular,{BackgroundColor3 = Color3.fromRGB(13, 0, 7)})
						tween(TextLabel,0.25,Enum.EasingStyle.Circular,{TextTransparency = 0.75})
						tween(Frame_3,0.25,Enum.EasingStyle.Circular,{Position = UDim2.new(0.25, 0, 0.5, 0),BackgroundColor3 = Color3.fromRGB(38, 0, 19)})
						tween(ImageLabel,0.25,Enum.EasingStyle.Circular,{ImageTransparency = 1})
					end
					focus = not focus
					Callback(focus)
				end)
			end
			return xova_func
		end
		return xova_page
	end
	return xova_section
end
return xova_library


 
