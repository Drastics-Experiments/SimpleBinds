--!strict
-- // WIP OSS MODULE BY daz_. ON DISCORD

--[[
    TODO:
    
    // Internal logic/code
    MultipleTaps, StrictSequence
    Ensure all logic works correctly (1/3)
    Change all debugging warns to errors

    // Methods
    :Construct()
    :Destroy()

    // Other
    Add more debugging errors/warns
    Fix any typechecking mistakes (DONE)
    Optimize
]]

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local SignalModule = require(script.Signal)
local Types = require(script.Types)
local DefaultData = require(script.Default)
local Signal = SignalModule.new

local STATES = Enum.UserInputState
local KEYCODES, USER_INPUT_TYPES = Enum.KeyCode, Enum.UserInputType
local STRING_SPLIT, UNPACK = string.split, table.unpack
local HEARTBEAT = RunService.Heartbeat
local BEHAVIOR_FUNCTIONS = {
    Press = Press,
    Hold = Hold,
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

function SimpleBinds.CreateKeybind(KeybindName: string, KeybindType: "Press" | "Hold" | "Toggle" | "MultipleTaps" | "StrictSequence", RequireAll: boolean, KeybindSettings: {
    TimeWindow: number,
    ClickCount: number?,
}?)
    local self = setmetatable(DefaultData(), Methods)
    local Settings = self.KeybindSettings

    Settings.Name = KeybindName
    Settings.KeybindType = KeybindType
    Settings.RequireAllButtons = RequireAll
    self.BehaviorVars.KeybindConfig = KeybindSettings
    SimpleBinds._Binds[KeybindName] = self

    return self
end

function SimpleBinds.GetKeybind(KeybindName)
    return _Binds[KeybindName]
end

-- // QOL

function SimpleBinds.EnableAll()
    for i,v in _Binds do
        if v.Settings.Enabled then continue end
        v:Enable()
    end
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
    --assert(Condition, "Cannot use :Enable() on an enabled keybind!")

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

    if not Condition then
        assertWarn(Condition, "Cannot use :Disable() on an disabled keybind!")
        return self
    end

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
end

function Methods.AddCustomLogic(self: Types.Keybind, Func: (...any) -> (boolean))
    self.BehaviorVars.CustomLogic = Func
    return self
end

-- // TODO: Move this function to the private methods when on a PC again
function Methods._AreEnoughKeysPressed(self: Types.PrivateKeybind, Platform: "Keyboard" | "Console")
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

function Methods.WrapSignal(self: Types.Keybind, SignalName: string, Signal: RBXScriptSignal, Behavior: "PressAll" | {Enum.KeyCode | Enum.UserInputType}, InputState: "Began" | "Ended", Platform: "Keyboard" | "Console")
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

function Methods.SetSignalArgs(self: Types.Keybind, ...)
    local PackedData = {...}
    self.BehaviorVars.CustomArgs = PackedData
    return self
end

function Methods.SetPlatformBinds(self: Types.Keybind, Platform: "Keyboard" | "Console", NewBinds: {Enum.KeyCode | Enum.UserInputType})
    local Settings = self.Settings
    if Settings.Enabled then return self end -- too lazy to type out warn thing
    Settings.BindedKeys[Platform] = NewBinds
    return self
end

function Methods.Construct(self: Types.Keybind, InfoTable: Types.ConstructTable)
    local Comparison = self.Settings.Enabled == false
    if not Comparison then
        assertWarn(Comparison, "Could not run :Construst() because keybind is already enabled")
        return self
    end
end

function Methods.GetDatastoreKeybindFormat(self)
end

-- // Private Methods

-- // Signal connection example: (Keypressed: InputObject, CustomArg: ...any)
function Methods._FireSignal(self: Types.PrivateKeybind, SignalName: "Triggered" | "InputBegan" | "InputEnded", ButtonPressed: InputObject | Enum.KeyCode | Enum.UserInputType)
    self.Signals.Default[SignalName]:Fire(ButtonPressed, table.unpack(self.BehaviorVars.CustomArgs or {}))
end

function Methods._CreateConnection(self: Types.PrivateKeybind, SignalName: string)
    local Signal = self.Signals.Custom[SignalName]
    Signal.Signal:Connect(function()
        if Signal.Behavior == "PressAll" then
            local Binds = self.Settings.BindedKeys[Signal.Platform]
            local Name = self.Settings.Name
            for i,v in Binds do
                WhenKeyStatusChanges(Name, STATES[Signal.InputState], v)
            end
        else
            local Name = self.Settings.Name
            for i,v in Signal.Behavior do
                WhenKeyStatusChanges(Name, STATES[Signal.InputState], v)
            end
        end
            
    end)
end

function Methods._PerformCustomLogic(self: Types.PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: Types.InputChoices)
    if self.BehaviorVars.CustomLogic then
        local a,b = ProcessBind(BindName) -- typechecking warning fix
        local result = self.BehaviorVars.CustomLogic(self, a, b, InputState, Key)
        assert(typeof(result) == "boolean", "Custom logic must return a boolean")
        return result 
    end
    return true
end

-- // Utility

function SetNewBehaviorFunction(Bind: Types.Keybind)
    local BType = Bind.Settings.KeybindType
    Bind.BehaviorVars.Func = BEHAVIOR_FUNCTIONS[BType]
end

function BindVars(bind: Types.Keybind | Types.PrivateKeybind)
    return bind.Settings, bind.BehaviorVars
end

-- // Keybind Logic

function ProcessBind(BindName: string)
    local Name: string, Platform: "Keyboard" | "Console" = table.unpack(STRING_SPLIT(BindName, "_"))
    return Name, Platform
end

-- I am aware this function isnt the best atm but optimizing is very annoying on an ipad :(
function WhenKeyStatusChanges(BindName: string, InputState: Enum.UserInputState, Key: InputObject | Enum.KeyCode | Enum.UserInputType)
    local ObjectName, Platform = ProcessBind(BindName)
    local Bind = SimpleBinds.GetKeybind(ObjectName)
    if not Bind:_PerformCustomLogic(BindName, InputState, Key) then return end
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

function Press(Bind: Types.PrivateKeybind, BindName, InputState: Enum.UserInputState, Key: Types.InputChoices)
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
    if EnoughPressed then
        if BehaviorVars.Connection then return end
        Bind:_FireSignal("InputBegan", Key)
        BehaviorVars.Connection = HEARTBEAT:Connect(function(deltaTime)
            BehaviorVars.CurrentTimeDuration += deltaTime
            if BehaviorVars.CurrentTimeDuration >= KeybindConfig.TimeWindow then
                Bind:_FireSignal("Triggered", Key)
                Bind:_FireSignal("InputEnded", Key)
                BehaviorVars.CurrentTimeDuration = 0
                BehaviorVars.Connection:Disconnect()
                BehaviorVars.Connection = nil
            end
        end)
    else
        if BehaviorVars.Connection then
            BehaviorVars.Connection:Disconnect()
            BehaviorVars.Connection = nil
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

return table.freeze(SimpleBinds) :: Types.Module