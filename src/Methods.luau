local ContextActionService = game:GetService("ContextActionService")
local InputService = game:GetService("UserInputService")

local GetTemplate = require(script.Parent.Template)
local Types = require(script.Parent.Types)
local Signal = require(script.Parent.Signal)

local __button = Signal.new()
local __destroy = Signal.new()

function FireButtonPress(Name, State: Enum.UserInputState, Button: InputObject | Enum.KeyCode | Enum.UserInputType)
	__button:Fire(Name, State, Button)
end

local function assert(expression, MSG)
	if not expression then error(MSG) end
end

local function Enable(self: Keybind)
	assert(self.Enabled == false, "Cannot use :Enable() if already enabled")
	
	local Settings = self.Settings
	local Binds = self.Binds
	local IndexSearch = Binds.IndexSearch
	local CurrentBinds = Binds.CurrentBinds
	
	self.Enabled = true
	
	if CurrentBinds.Keyboard then
		for i = 1, #CurrentBinds.Keyboard do
			IndexSearch[CurrentBinds.Keyboard[i]] = true
		end
		ContextActionService:BindAction(Settings.Name.."_Keyboard", FireButtonPress, false, table.unpack(CurrentBinds.Keyboard))

	end

	if CurrentBinds.Console then
		for i = 1, #CurrentBinds.Console do
			IndexSearch[CurrentBinds.Console[i]] = true
		end

		ContextActionService:BindAction(Settings.Name.."_Console", FireButtonPress, false, table.unpack(CurrentBinds.Console))
	end

	return self
end

local function Disable(self: Keybind)
	assert(self.Enabled, "Cannot use :Disable() if already disabled")
	
	self.Enabled = false
	
	local Binds = self.Binds
	local CurrentBinds = Binds.CurrentBinds
	local IndexSearch = Binds.IndexSearch
	
	for i,v in pairs(CurrentBinds.Keyboard) do
		IndexSearch[v] = nil
	end

	for i,v in pairs(CurrentBinds.Console) do
		IndexSearch[v] = nil
	end
	
	ContextActionService:UnbindAction(self.Settings.Name.."_Keyboard")
	ContextActionService:UnbindAction(self.Settings.Name.."_Console")
	
	return self
end

local function Destroy(self: Keybind)
	if self.Enabled then self:Disable() end

	__destroy:Fire(self.Settings.Name)

	return self
end

local function SetPlatformBinds(self: Keybind, Platform: "Keyboard" | "Console", NewBindsList: { Enum.KeyCode | Enum.UserInputType })
	assert(self.Enabled == false, "Cannot use :SetPlatformBinds() on an enabled keybind.")
	
	self.Binds.CurrentBinds[Platform] = NewBindsList
	
	return self
end

local function ImportSignal(self: Keybind, SignalMask: string, SignalToImport: RBXScriptSignal, SimulatedBinds: { Enum.KeyCode | Enum.UserInputType })
	assert(self.Enabled == false, "Cannot use :ImportSignal() on an enabled keybind.") 

	self.Signals.ImportedSignals[SignalMask] = {
		Signal = SignalToImport,
		Binds = SimulatedBinds
	}
	
	return self
end

local function RemoveImportedSignal(self: Keybind, SignalMask: string)
	local ImportedSignals = self.Signals.ImportedSignals
	assert(ImportedSignals[SignalMask])
end

local function ConnectToDefaultSignal(self: Keybind, SignalType: Types.defaultSignals, Callback: (...any) -> ())
	assert(self.Enabled == false, "Cannot use :ConnectToDefaultSignal() on an enabled keybind.")
	self.Signals.CurrentConnections[SignalType] = self.Signals.Default[SignalType]:Connect(Callback)
	
	return self
end

local function ConnectToImportedSignal(self: Keybind, SignalMask: string, SignalType: Types.defaultSignals, InputState: "Begin" | "End")
	assert(self.Enabled == false, "Cannot use :ConnectToImportedSignal() on an enabled keybind.")

	local ImportedSignals = self.Signals.ImportedSignals
	local FoundSignal = ImportedSignals[SignalMask]
	local Settings = self.Settings
	
	FoundSignal.Proxy = FoundSignal.Signal:Connect(function()
		for i = 1, #FoundSignal.Binds do
			__button:Fire(Settings.Name .. "_Keyboard", Enum.UserInputState[InputState], FoundSignal.Binds[i])
		end
	end)
	
	return self
end

local function Construct(self: Keybind, KeyList: Types.KeyBuilder)
	assert(KeyList.Callbacks, "Callbacks Table was not provided.")
	assert(self.Enabled == false, "Cannot use :Construct() on an enabled keybind.")

	if KeyList.Keyboard then
		self:SetPlatformBinds("Keyboard", KeyList.Keyboard)
	end
	
	if KeyList.Console then
		self:SetPlatformBinds("Console", KeyList.Console)
	end
	
	if KeyList.CustomSignals then
		for SignalMask, Args in pairs(KeyList.CustomSignals) do
			self:ImportSignal(SignalMask, Args.Signal, Args.SimulatedButtons)
			self:ConnectToImportedSignal(SignalMask, Args.SignalToConnect, Args.InputState)
		end
	end
	
	for Name, Callback in pairs(KeyList.Callbacks) do
		self:ConnectToDefaultSignal(Name, Callback)
	end

	return self
end

local function AreEnoughButtonsPressed(self: Keybind, platform: "Keyboard" | "Console")	
	local Binds = self.Binds
	
	local CurrentBinds = Binds.CurrentBinds[platform]
	local requireAll = self.Settings.RequireAllButtons
	local PressedButtons = Binds.PressedButtons[platform]

	local detectedKeys = 0

	for i = 1,#CurrentBinds do
		if PressedButtons[CurrentBinds[i]] then
			detectedKeys += 1
		end
	end

	if requireAll then
		if detectedKeys >= #CurrentBinds then
			return true
		end
	else
		if detectedKeys <= #CurrentBinds then
			return true
		end
	end
	
	return false
end

local function Disconnect(self: Keybind, SignalMask: Types.defaultSignals | string)
	local default = self.Signals.Default[SignalMask]
	local imported = self.Signals.ImportedSignals[SignalMask]
	
	if default then
		default:DisconnectAll()
	end
	
	if imported then
		imported:DisconnectAll()
	end
end

local Methods = {}
Methods.__index = Methods

Methods.__pressed = __button
Methods.__destroy = __destroy

Methods.Enable = Enable
Methods.Disable = Disable
Methods.Destroy = Destroy
Methods.Construct = Construct
Methods.Disconnect = Disconnect
Methods.ImportSignal = ImportSignal
Methods.SetPlatformBinds = SetPlatformBinds
Methods.RemoveImportedSignal = RemoveImportedSignal
Methods.ConnectToDefaultSignal = ConnectToDefaultSignal
Methods.ConnectToImportedSignal = ConnectToImportedSignal
Methods.AreEnoughButtonsPressed = AreEnoughButtonsPressed

export type Keybind = typeof(setmetatable(GetTemplate(), Methods))
return Methods