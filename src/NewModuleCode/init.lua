local ContextActionService = game:GetService("ContextActionService")

local SignalModule = require(script.Signal)
local Types = require(script.Types)
local DefaultData = require(script.Default)
local Signal = SignalModule.new

local SimpleBinds = {}
SimpleBinds._Binds = {}

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
    return SimpleBinds._Binds[KeybindName]
end

-- // Methods

function Methods.Enable(self)
    local Condition = self.Settings.Enabled == false

    if not Condition then
        assertWarn(Condition, "Cannot use :Enable() on an enabled keybind!")
        return self
    end

    local Binds = self.Settings.BindedKeys
    local BindType = self.Settings.KeybindType
    local BehaviorVars = self.BehaviorVars

    self.Settings.Enabled = true

    if BindType == "Press" then
        BehaviorVars.Func = Press
    elseif BindType == "Toggle" then
        BehaviorVars.Func = Toggle
    elseif BindType == "MulipleTaps" then
        BehaviorVars.Func = MultipleTaps
    elseif BindType == "StrictSequence" then
        BehaviorVars.Func = StrictSequence
    end
    
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

function Methods._AreEnoughKeysPressed(self)
    local Binds = self.Settings.BindedKeys
    local Keyboard, Console = Binds.Keyboard, Binds.Console

end

function Methods.WrapSignal(self)
end

function Methods.SetSignalArgs(self, ...)
    local PackedData = {...}
    self.BehaviorVars.CustomArgs = PackedData
end

function Methods.SetPlatformBinds(self)
end

function Methods.Construct(self)
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

-- // Keybind Logic

local function ProcessBind(BindName)
    local Name, Platform = string.split(BindName, "_")
    return Name, Platform
end

function WhenKeyStatusChanges(BindName: string, InputState: Enum.UserInputState, Key: InputObject)
    local ObjectName, Platform = ProcessBind(BindName)
    local Bind = SimpleBinds._Binds[ObjectName]
    local PressedKeys = Bind.BehaviorVars.PressedKeys
    local State = InputState == Enum.UserInputState.Begin

    if State then
        PressedKeys[Key.KeyCode] = State
        PressedKeys[Key.UserInputType] = State
    else
        PressedKeys[Key.KeyCode] = nil
        PressedKeys[Key.UserInputType] = nil
    end

    Bind.BehaviorVars.Func(BindName, InputState, Key)
end

function Press(BindName: string, InputState: Enum.UserInputState, Key: InputObject)
    local ObjectName, Platform = ProcessBind(BindName)
    local Bind = SimpleBinds._Binds[ObjectName]

    if InputState == Enum.UserInputState.Begin then
        local State = Bind:AreEnoughKeysPressed()
        if State then
            Bind:FireSignal("Triggered", Key)
        end
    end
end

function Toggle()
    
end

function MultipleTaps()
    
end

function StrictSequence()
    
end

return SimpleBinds :: Types.Module