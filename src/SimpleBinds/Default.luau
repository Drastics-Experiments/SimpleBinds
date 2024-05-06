local Signal = require(script.Parent.Signal)
local NewSignal = Signal.new
local Types = require(script.Parent.Types)

local function f()end

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
				Triggered = NewSignal(),
				InputBegan = NewSignal(),
				InputEnded = NewSignal()
            },
            Custom = {}
        },
        BehaviorVars = {
            PressedKeys = {
                Keyboard = {},
                Console = {},
			},
			CurrentTimeDuration = 0,
			Connection = Signal.Wrap(game:GetService("RunService").Heartbeat),
			Func = f
		},
		KeybindConfig = {},
		_OverrideOtherContextActions = false
    }
end