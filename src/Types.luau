type importedSignal = {
	Signal : RBXScriptSignal,
	Binds : { Enum.KeyCode | Enum.UserInputType },
	Proxy : RBXScriptConnection
}


export type Keybind = {
	Settings : {
		Duration : number,
		RequiresAllButtons : boolean,
		TapAmount : number,
		Name : string,
		InputType : inputString
	},

	Binds : {
		PressedButtons : {
			Keyboard : {},
			Console : {}
		},
		IndexSearch : {},
		CurrentBinds : {
			Keyboard : {},
			Console : {}
		}
	},

	Signals : {
		Default : {
			Triggered : BindableEvent,
			InputBegan : BindableEvent,
			InputEnded : BindableEvent,
		},
		CurrentConnections : { [string] : RBXScriptConnection },
		ImportedSignals : { [string] : importedSignal }
	},

	SpecialVars : {
		CurrentDuration : number,
		InputProcessed : InputObject | boolean | number,
		MultiTapReady : boolean
	},

	Enabled : boolean,
}

export type defaultSignals = "Triggered" | "InputBegan" | "InputEnded"

type customSignal = {
	Signal : RBXScriptSignal,
	SimulatedButtons : { Enum.KeyCode | Enum.UserInputType },
	SignalToConnect : defaultSignals,
	InputState : "Begin" | "End"
}

export type KeyBuilder = {
	Keyboard : { Enum.KeyCode | Enum.UserInputType }?,
	Console : { Enum.KeyCode | Enum.UserInputType }?,
	CustomSignals : { [string]: customSignal }?,
	Callbacks : { [defaultSignals] : (...any?)->(...any?) }
}

return nil