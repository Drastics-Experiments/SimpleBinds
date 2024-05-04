local Signal = require(script.Parent.Signal).new
local Types = require(script.Parent.Types)

return function():: Types.KeybindSettings & Types.Internals
    return {
        KeybindType = "Press",
        BindedKeys = {
            Keyboard = {},
            Console = {}
        },
        Signals = {
            Default = {
                Triggered = Signal(),
                InputBegan = Signal(),
                InputEnded = Signal()
            },
            Custom = {}
        }
    }
end