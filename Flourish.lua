--[[

 ########  ##         .####.   ##    ##  ######:    ######    :####:   ##    ##
 ########  ##         ######   ##    ##  #######    ######   :######   ##    ##
 ##        ##        :##  ##:  ##    ##  ##   :##     ##     ##:  :#   ##    ##
 ##        ##        ##:  :##  ##    ##  ##    ##     ##     ##        ##    ##
 ##        ##        ##    ##  ##    ##  ##   :##     ##     ###:      ##    ##
 #######   ##        ##    ##  ##    ##  #######:     ##     :#####:   ########
 #######   ##        ##    ##  ##    ##  ######       ##      .#####:  ########
 ##        ##        ##    ##  ##    ##  ##   ##.     ##         :###  ##    ##
 ##        ##        ##:  :##  ##    ##  ##   ##      ##           ##  ##    ##
 ##        ##        :##  ##:  ##    ##  ##   :##     ##     #:.  :##  ##    ##
 ##        ########   ######   :######:  ##    ##:  ######   #######:  ##    ##
 ##        ########   .####.    :####:   ##    ###  ######   .#####:   ##    ##
                                                                                          
v0.1.0

CREDITS TO @AlexanderLindholt FOR CREATING TWEEN+ AND SIGNAL+

Configure your settings below!
]]

local Settings = {
	EXPAND_SCALE = 0.05,
	PULSE_SCALE = 0.05,

	LIFT_OFFSET = UDim2.fromScale(0, -0.005),
}

-------------------------------------------------------------------------------

local Flourish = {}
Flourish.__index = Flourish

--// VARIABLES

local TweenPlus = require(script.Tween)
local AllObjects = {}

local ConnectionTypes = {
	Click = "MouseButton1Down",
	Release = "MouseButton1Up",
	Hover = "MouseEnter",
	Unhover = "MouseLeave",
}

--// OBJECT CREATION

function Flourish.new(element : GuiObject) : typeof(setmetatable({}, Flourish))
	if not element.Parent then
		warn(`Failed to create object; {element} does not have a valid GuiObject parent`)
		return
	end
	
	if AllObjects[element.Name] then
		if AllObjects[element.Name].Element == element then
			warn(`{element.Name} is already in Flourish, object not created.`)
			return
		end

		warn(`A GuiObject with the name of {element.Name} is already in Flourish, consider renaming it or errors may occur`)
	end
	
	local self = setmetatable({}, Flourish)

	self.Element = element
	self.Connections = {}
	
	FixAnchorPoint(self.Element)
	
	self.BasePosition = self.Element.Position	
	self.BaseScale = self.Element.UIScale.Scale
	
	self.ActiveEffects = {}
		
	AllObjects[element.Name] = self
	
	return self
end

--// EFFECTS

function Flourish:Shake(connectionType : ConnectionType)
	local eventName = ConnectionTypes[connectionType]
	if not eventName then
		warn(`Invalid connection type {connectionType}`)
		return
	end
	
	local info = {Time = 0.05}
	
	local function shakeEffect()
		for i = 1, 4 do
			local direction = (i % 2 == 0) and 1 or -1
			local offset = self:_GetNewPosition() + UDim2.fromScale(0.005 * direction, 0)

			local tween = TweenPlus(self.Element, {Position = offset}, info)
			tween:Start()
			tween.Completed:Wait()
		end
		
		local resetTween = TweenPlus(self.Element, {Position = self:_GetNewPosition()}, info)
		resetTween:Start()
	end

	if connectionType == "Once" then
		shakeEffect()
		return
	end
	
	self:_Store("Shake", connectionType, self.Element[eventName]:Connect(shakeEffect))
end

function Flourish:Expand(connectionType : ConnectionType)
	local eventName = ConnectionTypes[connectionType]
	if not eventName then
		warn(`Invalid connection type {connectionType}`)
		return
	end
	
	if not self.ActiveEffects["Expand"] then
		self.ActiveEffects["Expand"] = {}
	end
	
	local UIScale = self.Element:FindFirstChildOfClass("UIScale")
	local info = {Time = 0.1}
	
	local otherConnectionType = connectionType == "Click" and "Release" or "Unhover"
	local otherEvent = ConnectionTypes[otherConnectionType]
	
	local function expandEffect()
		self.ActiveEffects["Expand"][connectionType] = true
		
		local tween = TweenPlus(UIScale, {Scale = self:_GetNewScale()}, info)
		tween:Start()
	end

	local function originalEffect()
		self.ActiveEffects["Expand"][connectionType] = false

		local tween = TweenPlus(UIScale, {Scale = self:_GetNewScale()}, info)
		tween:Start()
	end
	
	self:_Store("Expand", connectionType, self.Element[eventName]:Connect(expandEffect))
	self:_Store("Expand", otherConnectionType, self.Element[otherEvent]:Connect(originalEffect))
end

--// NON-DYNAMIC EFFECTS

function Flourish:Lift(connectionType : nil)
	if connectionType ~= nil then
		warn(`The Lift effect is non-dynamic, you cannot provide a connection type.`)
		return
	end
	
	if not self.ActiveEffects["Lift"] then
		self.ActiveEffects["Lift"] = {}
	end
	
	local info = {Time = 0.15, EasingStyle = "Quad"}
		
	local function liftUp()
		self.ActiveEffects["Lift"]["Active"] = true

		local tween = TweenPlus(self.Element, {Position = self:_GetNewPosition()}, info)
		tween:Start()
	end
	
	local function liftDown()
		self.ActiveEffects["Lift"]["Active"] = false

		local tween = TweenPlus(self.Element, {Position = self:_GetNewPosition()}, info)
		tween:Start()
	end
	
	self:_Store("Lift", "Hover", self.Element.MouseEnter:Connect(liftUp))
	self:_Store("Lift", "Unhover", self.Element.MouseLeave:Connect(liftDown))
end


function Flourish:Pulse(connectionType : nil)
	if connectionType ~= nil then
		warn(`The Pulse effect is non-dynamic, you cannot provide a connection type. This means it only runs once.`)
		return
	end
	
	if not self.ActiveEffects["Pulse"] then
		self.ActiveEffects["Pulse"] = {}
	end
	
	local UIScale = self.Element:FindFirstChildOfClass("UIScale")
	local info = {Time = 0.1, Reverses = true}
	
	local function pulseEffect()				
		self.ActiveEffects["Pulse"]["Active"] = true
		
		local pulseTween = TweenPlus(UIScale, {Scale = self:_GetNewScale()}, info)
		pulseTween:Start()
		
		pulseTween.Completed:Once(function()
			self.ActiveEffects["Pulse"]["Active"] = false
		end)
	end

	pulseEffect()
end

--// MISC

function Flourish:GetElement(name : string) : typeof(setmetatable({}, Flourish))
	if not AllObjects[name] then
		warn(`{name} is not in Flourish. Add it by doing Flourish.new({name})`)
		return
	end
	
	return AllObjects[name]
end

function Flourish:Disconnect(effectName : Effect & "All", connectionType : ConnectionType & "All")
	local effectConnections = self.Connections[effectName]
	if not effectConnections then
		warn(`Invalid effect {effectName}`)
		return
	end
	
	if effectName == "All" then
		for effect, connections in self.Connections do
			for connectionName, connection in connections do
				self.Connections[effect][connectionName]:Disconnect()
				self.Connections[effect][connectionName] = nil
			end
		end
		
		return
	end
	
	if connectionType == "All" then
		for connectionName, connection in effectConnections do
			effectConnections[connectionName]:Disconnect()
			effectConnections[connectionName] = nil
		end
		
		return
	end
	
	local connection = effectConnections[connectionType]
	
	if not connection then
		warn(`{connectionType} already does not exist for effect {effectName}`)
		return
	end
	
	connection:Disconnect()
	effectConnections[connectionType] = nil
end

function Flourish:_Store(effectName : Effect, connectionType : ConnectionType, connection : RBXScriptConnection)
	if not self.Connections[effectName] then
		self.Connections[effectName] = {}
	end

	local effectConnections = self.Connections[effectName]

	if effectConnections[connectionType] then
		effectConnections[connectionType]:Disconnect()
	end

	effectConnections[connectionType] = connection
end

function Flourish:_GetNewScale()
	local scale = self.BaseScale

	for effectName, effect in self.ActiveEffects do
		local addedScale = Settings[`{string.upper(effectName)}_SCALE`]

		if not addedScale then
			--warn(`Invalid effect name {effectName}`)
			continue
		end

		for _, active in effect do
			if active then
				scale += addedScale
			end
		end
	end

	return scale
end

function Flourish:_GetNewPosition()
	local position = self.BasePosition

	for effectName, effect in self.ActiveEffects do
		local addedPosition = Settings[`{string.upper(effectName)}_OFFSET`]
		if not addedPosition then
			--warn(`Invalid effect name {effectName}`)
			continue
		end

		for _, active in effect do
			if active then
				position += addedPosition
			end
		end
	end

	return position
end

function FixAnchorPoint(element : GuiObject)
	local UIScale = element:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Scale = 1
		UIScale.Parent = element
	end
	
	if element.AnchorPoint == Vector2.new(0.5, 0.5) then
		return
	end

	local size = element.AbsoluteSize
	local position = element.AbsolutePosition
	local parent = element.Parent
	local parentPosition = parent.AbsolutePosition
	local parentSize = parent.AbsoluteSize

	local centerX = (position.X - parentPosition.X) + size.X * 0.5
	local centerY = (position.Y - parentPosition.Y) + size.Y * 0.5

	local scaleX = centerX / parentSize.X
	local scaleY = centerY / parentSize.Y

	element.AnchorPoint = Vector2.new(0.5, 0.5)
	element.Position = UDim2.fromScale(scaleX, scaleY)
end

--// TYPES

type ConnectionType = "Click" | "Hover" | "Once"
type Effect = "Shake" | "Lift" | "Pulse" | "Expand"

return Flourish
