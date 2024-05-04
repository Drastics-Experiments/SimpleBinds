-- // WIP OSS MODULE BY daz_. ON DISCORD

local ContextActionService = game:GetService("ContextActionService")

local SignalModule = require(script.Signal)
local Types = require(script.Types)
local DefaultData = require(script.Default)
local Signal = SignalModule.new

local STATES = Enum,UserInputState
local KEYCODES, USER_INPUT_TYPES = Enum.KeyCode, Enum.UserInputType
local STRING_SPLIT = string.split
local BEHAVIOR_FUNCTIONS = {
    Press = Press,
    Toggle = Toggle,
    MultipleTaps = MultipleTaps,
    StrictSequence = StrictSequence
}


local SimpleBinds = {}
SimpleBinds._Binds = {}
local _Binds = SimpleBinds._Binds

local Methods = {}
Methods.__index = Methods

local function assertWarn(condition, msg)
    if not condition then warn("SimpleBinds Debugger: "..msg) end
end

-- // Constructor

function SimpleBinds.CreateKeybind(KeybindName: string, KeybindType: string, RequireAll: boolean)
    local self = setmetatable(DefaultData(), Methods)
    local Settings = self.KeybindSettings

    Settings.Name = KeybindName
    Settings.KeybindType = KeybindType
    Settings.RequireAllButtons = RequireAll
    SimpleBinds._Binds[KeybindName] = self

    return self
end

function SimpleBinds.GetKeybind(KeybindName)
    return _Binds[KeybindName]
end

-- // QOL

function SimpleBinds.EnableAll()
    
end

function SimpleBinds.DisableAll()
    
end

-- // Methods

function Methods.Enable(self)
    local Condition = self.Settings.Enabled == false
    --assert(Condition, "Cannot use :Enable() on an enabled keybind!")

    local Binds = self.Settings.BindedKeys
    local BindType = self.Settings.KeybindType
    local BehaviorVars = self.BehaviorVars

    self.Settings.Enabled = true
    
    SetNewBehaviorFunction(self.Settings.Name)

    if #Binds.Keyboard > 0 then
        ContextActionService:BindAction(`{self.Settings.Name}_Keyboard`, false, WhenKeyStatusChanges, table.unpack(Binds.Keyboard))
    end

    if #Binds.Console > 0 then
        ContextActionService:BindAction(`{self.Settings.Name}_Console`, false, WhenKeyStatusChanges, table.unpack(Binds.Console))
    end

    return self
end

function Methods.Disable(self)
    local Condition = self.Settings.Enabled == true

    if not Condition then
        assertWarn(Condition, "Cannot use :Disable() on an disabled keybind!")
        return self
    end

    local Binds = self.Settings.BindedKeys
    local Name = self.Settings.Name

    self.Settings.Enabled = false
    
    if #Binds.Keyboard > 0 then
        ContextActionService:UnbindAction(`{Name}_Keyboard`)
    end

    if #Binds.Console > 0 then
        ContextActionService:BindAction(`{Name}_Console`)
    end

    return self
end

function Methods.Destroy(self)
end

function Methods._AreEnoughKeysPressed(self, Platform: "Keyboard" | "Console")
    local Binds = self.Settings.BindedKeys[Platform]
    local PressedKeys = self.BehaviorVars.PressedKeys[Platform]
    local Required = self.Settings.RequireAllButtons
    local Detections = 0

    for _, Enum in Binds do
        if PressedKeys[Enum] then
            Detections += 1
        end
    end

    return (Required and Detections >= #Binds) or (Required == false and Detections > 0)
end

function Methods.WrapSignal(self, SignalName: string, Signal: RBXScriptSignal, Behavior: "PressAll" | {Enum.KeyCode | Enum.UserInputType}, InputState: "Began" | "Ended", Platform)
    local Condition = self.Settings.Enabled == false
    if not Condition then
        assertWarn(Condition, "Cannot Wrap a signal while keybind is enabled")
        return self
    end

    local Signals = self.Signals
    local Custom = Signals.Custom

    if not Custom[SignalName] then
        local CreatedSignal = SignalModule.WrapSignal(Signal)
        Custom[SignalName] = {
            Signal = CreatedSignal,
            Behavior = Behavior,
            InputState = InputState,
            Platform = Platform
        }
    else
        assertWarn(false, "Wrapped signal has a counterpart using the same name") -- ima prob change this msg bru
    end
    return self
end

function Methods.SetSignalArgs(self, ...)
    local PackedData = {...}
    self.BehaviorVars.CustomArgs = PackedData
    return self
end

function Methods.SetPlatformBinds(self, Platform: "Keyboard" | "Console", NewBinds: {Enum.KeyCode | Enum.UserInputType})
    local Settings = self.Settings
    if Settings.Enabled then return self end -- too lazy to type out warn thing
    Settings.BindedKeys[Platform] = NewBinds
    return self
end

function Methods.Construct(self, InfoTable: Types.ConstructTable)
    local Comparison = self.Settings.Enabled == false
    if not Comparison then
        assertWarn(Comparison, "Could not run :Construst() because keybind is already enabled")
        return self
    end
end

function Methods.GetDatastoreKeybindFormat(self)
end

-- // Signal connection example: (Keypressed: InputObject, CustomArg: ...any)

function Methods._FireSignal(self, SignalName: string, ButtonPressed: InputObject)
    self.Signals.Default[SignalName]:Fire(ButtonPressed, table.unpack(self.BehaviorVars.CustomArgs or {}))
end

function Methods._CreateConnection(self, SignalName)
    local Signal = self.Signals.Custom[SignalName]
    Signal.Signal:Connect(function()
        if Signal.Behavior == "PressAll" then
            local Binds = self.Settings.BindedKeys[Signal.Platform]
            local Name = self.Settings.Name
            for i,v in Binds do
                WhenKeyStatusChanges(Name, STATES[Signal.State], v)
            end
        else
            local Name = self.Settings.Name
            for i,v in Signal.Behavior do
                WhenKeyStatusChanges(Name, STATES[Signal.State], v)
            end
        end
            
    end)
end

-- // Utility

function SetNewBehaviorFunction(Name)
    local Bind = SimpleBinds.GetKeybind(Name)
    local BType = Bind.Settings.KeybindType
    for Name, Func in BEHAVIOR_FUNCTIONS do
        if Name == BType then
            Bind.BehaviorVars.Func = Func
        end
    end
end

-- // Keybind Logic

local function ProcessBind(BindName)
    local Name, Platform = STRING_SPLIT(BindName, "_")
    return Name, Platform
end

-- I am aware this function isnt the best atm but optimizing is very annoying on an ipad :(
function WhenKeyStatusChanges(BindName: string, InputState: Enum.UserInputState, Key: InputObject)
    local ObjectName, Platform = ProcessBind(BindName)
    local Bind = SimpleBinds.GetKeybind(ObjectName)
    local PressedKeys = Bind.BehaviorVars.PressedKeys
    local State = InputState == STATES.Begin
    local t = typeof(Key)

    if t ~= "EnumItem" then
        if State then
            PressedKeys[Key.KeyCode] = State
            PressedKeys[Key.UserInputType] = State
        else
            PressedKeys[Key.KeyCode] = nil
            PressedKeys[Key.UserInputType] = nil
        end
    else
        if State then
            PressedKeys[Key] = State
        else
            PressedKeys[Key] = nil
        end
    end

    Bind.BehaviorVars.Func(Bind, BindName, InputState, Key)
end

function Press(Bind, BindName, InputState: Enum.UserInputState, Key: InputObject)
    local OnjectName, Platform = ProcessBind(BindName)
    if InputState == STATES.Begin then
        local EnoughPressed = Bind:_AreEnoughKeysPressed(Platform)
        if EnoughPressed then
            Bind:_FireSignal("Triggered", Key)
        end
    end
end

function Toggle(Bind, BindName, InputState, Key)
    local ObjectName, Platform = ProcessBind(BindName)
    local EnoughPressed = Bind:_AreEnoughKeysPressed(Platform)
end

function MultipleTaps()
    
end

function StrictSequence()
    
end

return SimpleBinds :: Types.Module