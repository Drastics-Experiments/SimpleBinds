--!strict
-- // WIP OSS MODULE BY daz_. ON DISCORD

--[[
    TODO:
    
    // Internal logic/code
    MultipleTaps, StrictSequence
    Ensure all logic works correctly (DONE)
    Change all debugging warns to errors (DONE)

    // Methods
    :Construct() (DONE)
    :Destroy() (DONE)
	:DisconnectSignal() (DONE)

    // Other
    Add more debugging errors/warns (DONE)
    Fix any typechecking mistakes (DONE)
    Optimize (WIP)
]]

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local SignalModule = require(script.Signal)
local Types = require(script.Types)
local DefaultData = require(script.Default)
local Signal = SignalModule.new

local STATES = Enum.UserInputState
local SINK, PASS = Enum.ContextActionResult.Sink, Enum.ContextActionResult.Pass
local KEYCODES, USER_INPUT_TYPES = Enum.KeyCode, Enum.UserInputType
local STRING_SPLIT, UNPACK = string.split, table.unpack
local HEARTBEAT = RunService.Heartbeat

local SimpleBinds = {}
SimpleBinds._Binds = {}
local _Binds = SimpleBinds._Binds

local Methods = {}
Methods.__index = Methods

local function assert(condition, msg)
    if not condition then error("SimpleBinds Debugger: "..msg) end
end

-- // Constructor



function SimpleBinds.CreateKeybind(Args: Types.CreationArgs)
    local self = setmetatable(DefaultData(), Methods)
    local Settings = self.Settings

    Settings.Name = Args.Name
    Settings.KeybindType = Args.KeybindType
    Settings.RequireAllButtons = Args.RequireAll
	
	local KeybindConfig = {}
	for Arg, v in Args do
		if not Settings[Arg] then
			KeybindConfig[Arg] = v
		end
	end

    self.BehaviorVars.KeybindConfig = KeybindConfig
    _Binds[Settings.Name] = self

    return self
end

function SimpleBinds.GetKeybind(KeybindName)
    return _Binds[KeybindName]
end

-- // QOL

function SimpleBinds.EnableAll()
	print(_Binds)
    for i,v in _Binds do
        if v.Settings.Enabled then continue end
		v:Enable()
		print(v)
	end
	print(_Binds)
end

function SimpleBinds.DisableAll()
    for i,v in _Binds do
        if not v.Settings.Enabled then continue end
        v:Disable()
    end
end

-- // Methods

function Methods.Enable(self: Types.Keybind)
    local Settings, _ = BindVars(self)
    local Condition = Settings.Enabled == false
    assert(Condition, "Cannot use :Enable() on an enabled keybind!")

    local Binds = Settings.BindedKeys
    local Name = Settings.Name

    Settings.Enabled = true
    
    SetNewBehaviorFunction(self)

    if #Binds.Keyboard > 0 then
        ContextActionService:BindAction(`{Name}_Keyboard`, WhenKeyStatusChanges, false, table.unpack(Binds.Keyboard))
    end

    if #Binds.Console > 0 then
        ContextActionService:BindAction(`{Name}_Console`, WhenKeyStatusChanges, false, table.unpack(Binds.Console))
    end

    return self
end

function Methods.Disable(self: Types.Keybind)
    local Settings, _ = BindVars(self)
    local Condition = Settings.Enabled == true
	assert(Condition, "Cannot use :Disable() on an disabled keybind!")

    local Binds = Settings.BindedKeys
    local Name = Settings.Name

    Settings.Enabled = false
    
    if #Binds.Keyboard > 0 then
        ContextActionService:UnbindAction(`{Name}_Keyboard`)
    end

    if #Binds.Console > 0 then
        ContextActionService:UnbindAction(`{Name}_Console`)
    end

    return self
end

function Methods.Destroy(self)
	local Settings, BehaviorVars = BindVars(self)
	local Signals = self.Signals

	if Settings.Enabled then self:Disable() end

	for i,v in Signals.Default do
		v:Destroy()
	end

	for i,v in Signals.Custom do
		v.Signal:Destroy()
	end

	BehaviorVars.Connection:Destroy()

	_Binds[Settings.Name] = nil

	for i,v in self do
		self[i] = nil
	end
end

function Methods.AddCustomLogic(self: Types.Keybind, Func: (...any) -> (boolean))
	assert(Func ~= nil, "Must Give a function for custom logic")
	assert(typeof(Func(self, self.Settings.Name, "_Keyboard", STATES.Begin, self.Settings.BindedKeys.Keyboard[1] or self.Settings.BindedKeys.Console[1])) == "boolean", "Custom logic function must return a boolean type")
    self.BehaviorVars.CustomLogic = Func
    return self
end

function Methods.WrapSignal(self: Types.Keybind, SignalName: string, Signal: RBXScriptSignal, Behavior: "PressAll" | {Enum.KeyCode | Enum.UserInputType}, InputState: "Began" | "End", Platform: "Keyboard" | "Console")
    local Condition = self.Settings.Enabled == false
	assert(Condition, "Cannot Wrap a signal while keybind is enabled")

    local Signals = self.Signals
    local Custom = Signals.Custom
	
	assert(Custom[SignalName] == nil, "Wrapped signal has a counterpart using the same name") -- ima prob change this msg bru

    local CreatedSignal = SignalModule.Wrap(Signal)
    Custom[SignalName] = {
        Signal = CreatedSignal,
        Behavior = Behavior,
        InputState = InputState,
        Platform = Platform
	}
	self:CreateConnection(SignalName)

    return self
end

function Methods.CreateConnection(self: Types.Keybind, SignalName: string)
	local Signal = self.Signals.Custom[SignalName]
	Signal.Signal:Connect(function()
		if Signal.Behavior == "PressAll" then
			local Binds = self.Settings.BindedKeys[Signal.Platform]
			local Name = self.Settings.Name
			for i,v in Binds do
				WhenKeyStatusChanges(Name.."_"..Signal.Platform, STATES[Signal.InputState], v)
			end
		else
			local Name = self.Settings.Name
			for i,v in Signal.Behavior do
				WhenKeyStatusChanges(Name.."_"..Signal.Platform, STATES[Signal.InputState], v)
			end
		end

	end)
	return self
end

function Methods.Connect(self: Types.Keybind, SignalType: Types.EventTypes, Func: (InputObject, ...any) -> ())
	local Default = self.Signals.Default
	assert(Default[SignalType], "Invalid Signal Name")
	Default[SignalType]:Connect(Func)
	return self
end

function Methods.Once(self: Types.Keybind, SignalType: Types.EventTypes, Func: (InputObject, ...any) -> ())
	local Default = self.Signals.Default
	assert(Default[SignalType], "Invalid Signal Name")
	Default[SignalType]:Once(Func)
	return self
end

function Methods.DisconnectSignal(self: Types.Keybind, SignalName: string, SignalType: Types.EventTypes, IsCustomSignal: boolean)
	IsCustomSignal = IsCustomSignal or false
	local path = self.Signals[(IsCustomSignal and "Custom") or (not IsCustomSignal and "Default")]
	local FoundSignal = path[SignalName]

	assert(FoundSignal, "Could not find signal")
	FoundSignal:DisconnectAll()
	return self
end

function Methods.SetSignalArgs(self: Types.Keybind, ...)
	assert(... ~= nil, "No args provided")
    local PackedData = {...}
    self.BehaviorVars.CustomArgs = PackedData
    return self
end

function Methods.SetPlatformBinds(self: Types.Keybind, Platform: "Keyboard" | "Console", NewBinds: {Enum.KeyCode | Enum.UserInputType})
    local Settings = self.Settings
	assert(Settings.Enabled == false, "Could not run :SetPlatformBinds() because keybind is already enabled")
	Settings.BindedKeys[Platform] = NewBinds
    return self
end

function Methods.Construct(self: Types.Keybind, InfoTable: Types.ConstructTable)
	local Comparison = self.Settings.Enabled == false
	assert(Comparison, "Could not run :Construct() because keybind is already enabled")
	assert(InfoTable.Callbacks ~= nil, "Cannot run :Construct() without Callback parameters")
	
	if InfoTable.Keyboard then
		self:SetPlatformBinds("Keyboard", InfoTable.Keyboard)
	end
	
	if InfoTable.Console then
		self:SetPlatformBinds("Console", InfoTable.Console)
	end
	
	if InfoTable.CustomSignals then
		for _, SignalArgs: Types.SignalArgs in InfoTable.CustomSignals do
			self:WrapSignal(SignalArgs.SignalName, SignalArgs.Signal, SignalArgs.Behavior, STATES[SignalArgs.InputState], SignalArgs.Platform)
			self:CreateConnection(SignalArgs.SignalName)
		end
	end
	
	for SignalType: Types.EventTypes, Callback: (InputObject, ...any) -> () in InfoTable.Callbacks do
		self:Connect(SignalType, Callback)
	end
	
	return self
end

function Methods.GetDatastoreKeybindFormat(self)
end

-- // Private Methods

-- // Signal connection example: (Keypressed: InputObject, CustomArg: ...any)
function Methods._FireSignal(self: Types.PrivateKeybind, SignalName: "Triggered" | "InputBegan" | "InputEnded", ButtonPressed: InputObject | Enum.KeyCode | Enum.UserInputType)
    self.Signals.Default[SignalName]:Fire(ButtonPressed, table.unpack(self.BehaviorVars.CustomArgs or {}))
end

function Methods._AreEnoughKeysPressed(self: Types.PrivateKeybind, Platform: string)
	local Binds = self.Settings.BindedKeys[Platform]
	local PressedKeys = self.BehaviorVars.PressedKeys[Platform]
	local Required = self.Settings.RequireAllButtons
	local Detections = 0

	for _, Enum: Enum.KeyCode | Enum.UserInputType in Binds do
		if PressedKeys[Enum] then
			Detections += 1
		end
	end

	return (Required and Detections >= #Binds) or (Required == false and Detections > 0)
end

function Methods._PerformCustomLogic(self: Types.PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: Types.InputChoices)
	if not self.BehaviorVars.CustomLogic then return true end
	
    local a,b = ProcessBind(BindName) -- typechecking warning fix
	local result = self.BehaviorVars.CustomLogic(self, a, b, InputState, Key)
    assert(typeof(result) == "boolean", "Custom logic must return a boolean")
	
	return result 
end

function Methods._GetAmountPressed(self: Types.PrivateKeybind, Platform: string)
	local Detections = 0
	local PressedKeys = self.BehaviorVars.PressedKeys[Platform]
	local Binds = self.Settings.BindedKeys[Platform]

	for i,v in Binds do
		if PressedKeys[v] then
			Detections += 1
		end
	end

	return Detections
end

-- // Utility

function SetNewBehaviorFunction(Bind: Types.Keybind)
	local _, BehaviorVars = BindVars(Bind)
	local BindType = Bind.Settings.KeybindType
	
	if BindType == "Press" then
		BehaviorVars.Func = Press
	elseif BindType == "Hold" then
		BehaviorVars.Func = Hold
	elseif BindType == "Toggle" then
		BehaviorVars.Func = Toggle
	elseif BindType == "MulipleTaps" then
		BehaviorVars.Func = MultipleTaps
	elseif BindType == "StrictSequence" then
		BehaviorVars.Func = StrictSequence
	end
end

function BindVars(bind: Types.Keybind | Types.PrivateKeybind)
    return bind.Settings, bind.BehaviorVars
end

-- // Keybind Logic

function ProcessBind(...: string): ...string
	local name, platform = table.unpack(STRING_SPLIT(..., "_"))
	return name, platform
end

-- I am aware this function isnt the best atm but optimizing is very annoying on an ipad :(
function WhenKeyStatusChanges(BindName: string, InputState: Enum.UserInputState, Key: any)
    local ObjectName, Platform = ProcessBind(BindName)
    local Bind = SimpleBinds.GetKeybind(ObjectName)
	if not Bind:_PerformCustomLogic(BindName, InputState, Key) then return end
    local PressedKeys = Bind.BehaviorVars.PressedKeys[Platform]
    local State = InputState == STATES.Begin
	local t = typeof(Key)
	
	if t == "EnumItem" then
		print(Key, Bind)
		if State then
			PressedKeys[Key] = State
		else
			PressedKeys[Key] = nil
		end
		Bind.BehaviorVars.Func(Bind, BindName, InputState, Key)
		return (Bind._OverrideOtherContextActions and SINK) or (not Bind._OverrideOtherContextActions and PASS)
	end
	
    if State then
		PressedKeys[Key.KeyCode] = State
		PressedKeys[Key.UserInputType] = State
    else
		PressedKeys[Key.KeyCode] = nil
		PressedKeys[Key.UserInputType] = nil
    end

	Bind.BehaviorVars.Func(Bind, BindName, InputState, Key)
	return (Bind._OverrideOtherContextActions and SINK) or (not Bind._OverrideOtherContextActions and PASS)
end

function Press(Bind: Types.PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: Types.InputChoices)
	local ObjectName, Platform = ProcessBind(BindName)

    if InputState == STATES.Begin then
        local EnoughPressed = Bind:_AreEnoughKeysPressed(Platform)
        if not EnoughPressed then return end
        Bind:_FireSignal("Triggered", Key)
    end
end

function Hold(Bind: Types.PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: Types.InputChoices)
    local Settings, BehaviorVars = BindVars(Bind)
    local ObjectName, Platform = ProcessBind(BindName)
    local KeybindConfig = BehaviorVars.KeybindConfig
	local EnoughPressed = Bind:_AreEnoughKeysPressed(Platform)
    local Same = EnoughPressed == (BehaviorVars.LastKeyCheck or false)

	if Same then return end
	BehaviorVars.LastKeyCheck = EnoughPressed
	if EnoughPressed then		
		Bind:_FireSignal("InputBegan", Key)
		BehaviorVars.Connection:Connect(function(deltaTime)
            BehaviorVars.CurrentTimeDuration += deltaTime
            if BehaviorVars.CurrentTimeDuration >= KeybindConfig.TimeWindow then
                Bind:_FireSignal("Triggered", Key)
                Bind:_FireSignal("InputEnded", Key)
				BehaviorVars.CurrentTimeDuration = 0	
				BehaviorVars.Connection:DisconnectAll()
			end
		end)
    else
        if BehaviorVars.Connection then
            BehaviorVars.Connection:DisconnectAll()
            BehaviorVars.CurrentTimeDuration = 0
            Bind:_FireSignal("InputEnded", Key)
        end
    end
end

function Toggle(Bind: Types.PrivateKeybind, BindName, InputState, Key)
    local Settings, BehaviorVars = BindVars(Bind)
    local ObjectName, Platform = ProcessBind(BindName)
    local EnoughPressed = Bind:_AreEnoughKeysPressed(Platform)
    local Same = EnoughPressed == (BehaviorVars.LastKeyCheck or false)

    if not Same then
		BehaviorVars.LastKeyCheck = EnoughPressed
		-- Ignore typechecking error
        local str = (EnoughPressed and "InputBegan") or (not EnoughPressed and "InputEnded")
        Bind:_FireSignal(str, Key)
    end
end

function MultipleTaps(Bind: Types.PrivateKeybind, BindName, InputState, Key)
    local ObjectName, Platform = ProcessBind(BindName)
    local Settings, BehaviorVars = BindVars(Bind)

end

function StrictSequence()
    
end

return SimpleBinds :: Types.Module