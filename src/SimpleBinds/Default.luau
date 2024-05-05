local Signal = require(script.Parent.Signal).new
local Types = require(script.Parent.Types)

return function()
    return {
        Settings = {
            Enabled = false,
            KeybindType = "Press",
            BindedKeys = {
                Keyboard = {},
                Console = {}
            },
        },
        Signals = {
            Default = {
                Triggered = Signal(),
                InputBegan = Signal(),
                InputEnded = Signal()
            },
            Custom = {}
        },
        BehaviorVars = {
            PressedKeys = {
                Keyboard = {},
                Console = {},
            }
        }
    }
end