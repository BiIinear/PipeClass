local RunService = game:GetService("RunService")

local PipeClass = {}
PipeClass.__index = PipeClass

PipeClass.GIRTH = 2.0 -- The girth of the pipes
PipeClass.TURN_ANGLE = 90.0 -- The degrees the pipes will turn
PipeClass.LENGTH_INCREMENT = 3.0 -- How many studs the pipes will extend
PipeClass.TURN_CHANCE = 33.3 -- Range 0 to 100, flips coin per step
PipeClass.TIME_SCALE = 2^0 -- How many times the pipes will step per render stepped

function PipeClass.new(startCFrame: CFrame?, color: Color3?)
	
	local defaultColor = Color3.fromRGB(163, 162, 165) -- Medium stone grey
	local defaultCFrame = CFrame.new()
	local folderName = "Pipe"
	
	startCFrame = startCFrame or defaultCFrame
	color = color or defaultColor
	local vertexColor = Vector3.new(color.R, color.G, color.B) * Vector3.new(2, 2, 2)
	
	local self = setmetatable({}, PipeClass)
	
	self.Color = color
	self.VertexColor = vertexColor

	self.Folder = Instance.new("Folder")
	self.Folder.Name = folderName

	self.InitNode = instantiateNode()
	self.InitNode.CFrame = startCFrame
	self.InitNode.Mesh.VertexColor = self.VertexColor
	self.InitNode.Parent = self.Folder

	self.InitEdge = instantiateEdge()
	self.InitEdge.CFrame = startCFrame * CFrame.new(PipeClass.GIRTH / 2.0, 0.0, 0.0)
	self.InitEdge.Mesh.VertexColor = self.VertexColor
	self.InitEdge.Parent = self.Folder

	self.ActiveNode = self.InitNode
	self.ActiveEdge = self.InitEdge
	self.Steps = 0
	self.Turns = 0

	return self
end

function PipeClass:Start()

	self.Folder.Parent = workspace

	RunService.Stepped:Connect(function()

		for i = 1, PipeClass.TIME_SCALE do

			if flipCoin(PipeClass.TURN_CHANCE) then self:Turn() end
			self:Step()

			self.Steps += 1
		end
	end)
end

function PipeClass:Step()

	self.ActiveEdge.Size += Vector3.new(PipeClass.LENGTH_INCREMENT, 0.0, 0.0)
	self.ActiveEdge.Mesh.Scale = self.ActiveEdge.Size / Vector3.new(2.0, 2.0, 2.0)
	self.ActiveEdge.CFrame *= CFrame.new(PipeClass.LENGTH_INCREMENT / 2.0, 0.0, 0.0)
end

function PipeClass:Turn()
	
	local randomSign = math.random(0, 1) == 1 and 1 or -1
	local radian = math.rad(PipeClass.TURN_ANGLE) * randomSign
	
	local NewNode = instantiateNode()
	NewNode.CFrame = self:GetHeadCFrame() * CFrame.fromOrientation(radian, 0.0, radian)
	NewNode.Mesh.VertexColor = self.VertexColor
	NewNode.Parent = self.Folder

	local NewEdge = instantiateEdge()
	NewEdge.CFrame = NewNode.CFrame * CFrame.new(PipeClass.GIRTH / 2.0, 0.0, 0.0)
	NewEdge.Mesh.VertexColor = self.VertexColor
	NewEdge.Parent = self.Folder

	self.ActiveNode = NewNode
	self.ActiveEdge = NewEdge
	self.Turns += 1
end

function PipeClass:GetHeadCFrame(): CFrame

	local HeadCFrame = self.ActiveEdge.CFrame * CFrame.new(self.ActiveEdge.Size.X / 2.0, 0.0, 0.0)

	return HeadCFrame
end

function instantiateNode(): Part
	
	local partScale = PipeClass.GIRTH
	local meshScale = partScale / 20.0
	
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(partScale, partScale, partScale)
	Part.CastShadow = false
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.Anchored = true
	
	local SpecialMesh = Instance.new("SpecialMesh")
	SpecialMesh.MeshId = "rbxassetid://1111494591"
	SpecialMesh.TextureId = "rbxassetid://12754303778"
	SpecialMesh.Scale = Vector3.new(meshScale, meshScale, meshScale)
	SpecialMesh.Parent = Part

	return Part
end

function instantiateEdge(): Part
	
	local partScale = PipeClass.GIRTH
	local meshScale = partScale / 2.0
	
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(partScale, partScale, partScale)
	Part.CastShadow = false
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.Anchored = true

	local SpecialMesh = Instance.new("SpecialMesh")
	SpecialMesh.MeshId = "rbxassetid://11698095403"
	SpecialMesh.TextureId = "rbxassetid://12754303778"
	SpecialMesh.Scale = Vector3.new(meshScale, meshScale, meshScale)
	SpecialMesh.Parent = Part

	return Part
end

function flipCoin(desiredRange: number): boolean

	local possibleRange = math.random(1, 1000) / 10
	local outcome = possibleRange <= desiredRange

	return outcome
end

return PipeClass
