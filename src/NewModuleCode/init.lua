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

function SimpleBinds.GetKeybind()
end

-- // Methods

function Methods.Enable(self)
    local Condition = self.Settings.Enabled == false

    if not Condition then
        assertWarn(Condition, "Cannot use :Enable() on an enabled keybind!")
        return self
    end

    local Binds = self.Settings.BindedKeys

    self.Settings.Enabled = true
    
    if #Binds.Keyboard > 0 then
        ContextActionService:BindAction(`{self.Settings.Name}_Keyboard`, false, table.unpack(Binds.Keyboard))
    end

    if #Binds.Console > 0 then
        ContextActionService:BindAction(`{self.Settings.Name}_Console`, false, table.unpack(Binds.Console))
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

function Methods.AreEnoughKeysPressed(self)
    
end

function Methods.ConnectSignal(self)
end

function Methods.AddSignalArg(self)
end

function Methods.SetPlatformBinds(self)
end

function Methods.Construct(self)
end

function Methods.GetDatastoreKeybindFormat(self)
end

-- // Keybind Logic

local function ProcessBind(BindName)
    local Name, Platform = string.split(BindName, "_")
    return Name, Platform
end

local function GetObjectVars(BindName)
    local Bind = SimpleBinds._Binds[BindName]
    return Bind
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
            Bind.Signals.Default.Triggered:Fire()
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