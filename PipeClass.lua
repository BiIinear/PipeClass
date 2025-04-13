local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TestGui = Player.PlayerGui:WaitForChild("TestGui")

local PipeClass = {}
PipeClass.__index = PipeClass

PipeClass.START_RANGE = 0.0 -- Will be positive or negative
PipeClass.TURN_ANGLE = 90.0 -- Will be positive or negative
PipeClass.LENGTH_INCREMENT = 3.0
PipeClass.TURN_CHANCE = 33.3 -- Write as 0.0 to 100.0, rolls dice per iteration
PipeClass.TIME_SCALE = 5 -- The exponent to 2. Write as -1 to 10

function PipeClass.new(brickColor: BrickColor?)
	
	local self = setmetatable({}, PipeClass)
	
	self.Color = brickColor or BrickColor.Random()
	
	self.Folder = Instance.new("Folder")
	self.Folder.Name = tostring(self.Color).." pipe"
	
	self.InitNode = RepStorage.Node:Clone()
	self.InitNode.CFrame = CFrame.new()
	self.InitNode.Size *= Vector3.new(2, 2, 2)
	self.InitNode.BrickColor = self.Color
	self.InitNode.Parent = self.Folder
	
	self.InitEdge = RepStorage.Edge:Clone()
	self.InitEdge.CFrame = CFrame.new()
	self.InitEdge.BrickColor = self.Color
	self.InitEdge.Parent = self.Folder
	
	self.ActiveNode = self.InitNode
	self.ActiveEdge = self.InitEdge
	self.Steps = 0
	self.Surns = 0
	
	return self
end

function PipeClass:Start(startCFrame: CFrame?)
	
	self.Folder.Parent = workspace
	self.InitNode.CFrame = startCFrame or CFrame.new(randomStartPosition()) * CFrame.fromOrientation(randomRadian(), 0, randomRadian())
	self.InitEdge.CFrame = self.InitNode.CFrame
	
	RunService.Stepped:Connect(function()
		
		for i = 1, 2^PipeClass.TIME_SCALE do
			
			self:Increment()
			
			if randomOutcome(PipeClass.TURN_CHANCE) then self:TurnPipe() end
			
			self.Steps += 1
		end
	end)
end

function PipeClass:Increment()
	
	self.ActiveEdge.Size += Vector3.new(PipeClass.LENGTH_INCREMENT, 0, 0)
	self.ActiveEdge.CFrame *= CFrame.new(PipeClass.LENGTH_INCREMENT / 2, 0, 0)
end

function PipeClass:TurnPipe()
	
	local NewNode = RepStorage.Node:Clone()
	NewNode.CFrame = self:GetHeadCFrame() * CFrame.fromOrientation(randomRadian(), 0, randomRadian())
	NewNode.BrickColor = self.Color
	NewNode.Parent = self.Folder
	
	local NewEdge = RepStorage.Edge:Clone()
	NewEdge.CFrame = NewNode.CFrame * CFrame.new(1, 0, 0)
	NewEdge.BrickColor = self.Color
	NewEdge.Parent = self.Folder
	
	self.ActiveNode = NewNode
	self.ActiveEdge = NewEdge
	self.Turns += 1
end

function PipeClass:GetHeadCFrame(): CFrame
	
	local HeadCFrame = self.ActiveEdge.CFrame * CFrame.new(self.ActiveEdge.Size.X / 2, 0, 0)
	
	return HeadCFrame
end

function randomRadian(): number
	
	local randomSign = math.random(0, 1) == 1 and 1 or -1
	local radian = math.rad(PipeClass.TURN_ANGLE) * randomSign
	
	return radian
end

function randomOutcome(desiredRange: number): boolean
	
	local possibleRange = math.random(1, 1000) / 10
	local outcome = possibleRange <= desiredRange
	
	return outcome
end

function randomStartPosition(): Vector3
	
	local StartPosition = Vector3.new(math.random(-PipeClass.START_RANGE, PipeClass.START_RANGE), 1, 1)
	StartPosition *= Vector3.new(1, math.random(-PipeClass.START_RANGE, PipeClass.START_RANGE), 1)
	StartPosition *= Vector3.new(1, 1, math.random(-PipeClass.START_RANGE, PipeClass.START_RANGE))
	
	return StartPosition
end

return PipeClass
