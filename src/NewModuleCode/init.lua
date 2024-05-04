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
end

function Methods.Destroy(self)
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

return SimpleBinds :: Types.Module