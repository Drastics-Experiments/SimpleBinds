local ContextActionService = game:GetService("ContextActionService")

local SignalModule = require(script.Signal)
local Types = require(script.Types)
local DefaultData = require(script.Default)
local Signal = SignalModule.new

local SimpleBinds = {}
SimpleBinds._Binds = {}

local Methods = {}
Methods.__index = Methods

function SimpleBinds.CreateKeybind(KeybindName: string, KeybindType: string, RequireAll: boolean)
    local self = setmetatable(Default(), Methods)
    local Settings = self.KeybindSettings

    Settings.KeybindType = KeybindType
    Settings.RequireAllButtons = RequireAllButtons
    SimpleBinds._Binds[KeybindName] = self
    self

    return self
end

function SimpleBinds.GetKeybind()
end

function Methods.Enable(self)
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

return SimpleBinds:: Types.Module