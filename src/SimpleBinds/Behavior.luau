local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Template = require(script.Parent.Template)
local Methods = require(script.Parent.Methods)

type ButtonType = InputObject | Enum.KeyCode | Enum.UserInputType

local BeginState = Enum.UserInputState.Begin
local EndState = Enum.UserInputState.End

local function UpdatePressedKeys(self: Methods.Keybind, State: Enum.UserInputState, Button: ButtonType)
	local PressedButtons = self.Binds.PressedButtons
	local IndexSearch = self.Binds.IndexSearch
	local platform = "Keyboard"
	
	if InputService.GamepadEnabled then platform = "Console" end
	
	local PlatFormPressed = PressedButtons[platform]
	if typeof(Button) ~= "EnumItem" then
		-- should be nil or return a value, doesnt matter what the returned value is
		local IsKeyCode = IndexSearch[Button.KeyCode]
		local IsUserInputType = IndexSearch[Button.UserInputType]
		
		if State == BeginState then
			PlatFormPressed[Button.KeyCode] = IsKeyCode
			PlatFormPressed[Button.UserInputType] = IsUserInputType
		end
		
		if State == EndState then
			PlatFormPressed[Button.KeyCode] = nil
			PlatFormPressed[Button.UserInputType] = nil
		end
	end
	
	if typeof(Button) == "EnumItem" then
		local IsEnumFound = IndexSearch[Button]
		
		if State == BeginState then
			PlatFormPressed[Button] = IsEnumFound
		end

		if State == EndState then
			PlatFormPressed[Button] = nil
		end
	end
end

local function Behavior_Press(self: Methods.Keybind, Args, State: Enum.UserInputState, Button: ButtonType)
	UpdatePressedKeys(self, State, Button)
	
	if State ~= Enum.UserInputState.Begin then return end
	if not self:AreEnoughButtonsPressed(Args[2]) then return end
	
	self.Signals.Default.Triggered:Fire()
end

local function Behavior_Hold(self: Methods.Keybind, Args, State: Enum.UserInputState, Button: ButtonType)
	if not self.Enabled then return end
	UpdatePressedKeys(self, State, Button)
	local SpecialVars = self.SpecialVars


	if SpecialVars.InputProcessed then return end
	if self:AreEnoughButtonsPressed(Args[2]) then
		local timer = 0
		local settings = self.Settings
		local Default = self.Signals.Default
		
		Default.InputBegan:Fire()
		SpecialVars.InputProcessed = true

		repeat
			timer += RunService.Heartbeat:Wait()
		until timer >= settings.Duration or not self:AreEnoughButtonsPressed(Args[2])
		
		Default.InputEnded:Fire()
		SpecialVars.InputProcessed = false

		if not self:AreEnoughButtonsPressed(Args[2]) then return end
		Default.Triggered:Fire()
	end
end

local function Behavior_Toggle(self: Methods.Keybind, Args, State: Enum.UserInputState, Button: ButtonType)
	if not self.Enabled then return end
	UpdatePressedKeys(self, State, Button)

	local SpecialVars = self.SpecialVars
	local Default = self.Signals.Default
	
	if self:AreEnoughButtonsPressed(Args[2]) and State == BeginState then
		if SpecialVars.InputProcessed then return Enum.ContextActionResult.Pass end
		
		SpecialVars.InputProcessed = true
		Default.InputBegan:Fire()
		
		return Enum.ContextActionResult.Pass
	end
	
	if SpecialVars.InputProcessed == true and State == EndState then
		SpecialVars.InputProcessed = false
		Default.InputEnded:Fire()
	end
end

local function Behavior_MultipleTaps(self: Methods.Keybind, Args, State: Enum.UserInputState, Button: ButtonType)
	if not self.Enabled then return end
	if not self.Settings.RequireAllButtons then error("MultipleTaps Forces Settings.RequireAllButtons to equal true") end
	UpdatePressedKeys(self, State, Button)
	
	local SpecialVars = self.SpecialVars
	local Signals = self.Signals.Default
	local platform = Args[2]
	
	if State == BeginState then
		if not self:AreEnoughButtonsPressed(Args[2]) then return end
		if not SpecialVars.MultiTapReady then return end
		if typeof(SpecialVars.InputProcessed) ~= "number" then SpecialVars.InputProcessed = 0 end
		if SpecialVars.CurrentDuration == 0 or os.clock() - SpecialVars.CurrentDuration > self.Settings.Duration then 
			SpecialVars.InputProcessed = 0
			SpecialVars.CurrentDuration = os.clock() 
		end
		
		SpecialVars.MultiTapReady = false
		Signals.InputBegan:Fire()
		SpecialVars.InputProcessed += 1
		
		if SpecialVars.InputProcessed >= self.Settings.TapAmount then
			SpecialVars.CurrentDuration = 0
			Signals.Triggered:Fire()
		end
	end
	
	if State == EndState then
		if SpecialVars.MultiTapReady then return end
		
		local Binds = self.Binds
		local CurrentBinds = Binds.CurrentBinds[platform]
		local PressedButtons = Binds.PressedButtons[platform]
		
		for i = 1, #CurrentBinds do
			if PressedButtons[CurrentBinds[i]] then
				return
			end
		end
		
		SpecialVars.MultiTapReady = true
		Signals.InputEnded:Fire()
	end
end

local Behavior = {}

Behavior.Behavior_Hold = Behavior_Hold
Behavior.Behavior_Press = Behavior_Press
Behavior.Behavior_Toggle = Behavior_Toggle
Behavior.Behavior_MultipleTaps = Behavior_MultipleTaps

return Behavior