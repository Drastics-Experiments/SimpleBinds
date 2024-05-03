local ContextActionService = game:GetService("ContextActionService")

local SignalModule = require(script.Signal)
local Signal = SignalModule.new

local SimpleBinds = {}
SimpleBinds._Binds = {}

local Methods = {}
Methods.__index = Methods

function SimpleBinds.CreateKeybind(KeybindName: string)
    local self = setmetatable({}, Methods)
end

function SimpleBinds.GetKeybind()
end

function Methods.Enable(self)
end

function Methods.Disable(self)
end

function Methods.Destroy(self)
end

function Methods.SetKeybindType(self, KeybindType)
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

return SimpleBinds