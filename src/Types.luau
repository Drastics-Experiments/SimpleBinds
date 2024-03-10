type importedSignal = {
	Signal : RBXScriptSignal,
	Binds : { Enum.KeyCode | Enum.UserInputType },
	Proxy : RBXScriptConnection
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