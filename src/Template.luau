--!strict

local SignalModule = require(script.Parent.Signal)
local Signal = SignalModule.new

type importedSignal = {
	Signal : RBXScriptSignal,
	Binds : { Enum.KeyCode | Enum.UserInputType },
	Proxy : RBXScriptConnection
}

return function()
	local NewTemplate = {
		Settings = {
			Name = "" :: string,
			Duration = 0 :: number?,
			TapAmount = 0 :: number?,
			InputType = "Press" :: "Press" | "Hold" | "Toggle" | "MultipleTaps",
			RequireAllButtons = false :: boolean,
		},

		Binds = {
			IndexSearch = {},
			PressedButtons = {
				Keyboard = {},
				Console = {}
			},
			CurrentBinds = {
				Keyboard = {},
				Console = {}
			}
		},

		Signals = {
			Default = {} :: {
				Triggered : SignalModule.Signal,
				InputBegan : SignalModule.Signal,
				InputEnded : SignalModule.Signal,
			},
			ImportedSignals = {} :: { [string] : importedSignal },
			CurrentConnections = {} :: { [string] : RBXScriptConnection }, 
			ButtonPressed = Signal() :: SignalModule.Signal
		},

		SpecialVars = {
			CurrentDuration = 0,
			MultiTapReady = true,
			InputProcessed = false,
		} :: {
			CurrentDuration : number,
			InputProcessed : InputObject | boolean | number,
			MultiTapReady : boolean
		},

		Enabled = false :: boolean
	}


	local DefaultSignals = NewTemplate.Signals.Default
	DefaultSignals.Triggered = Signal()
	DefaultSignals.InputBegan = Signal()
	DefaultSignals.InputEnded = Signal()
	NewTemplate.Signals.ButtonPressed = Signal()

	return NewTemplate
end