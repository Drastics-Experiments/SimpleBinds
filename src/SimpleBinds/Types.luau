local SignalModule = require(script.Parent.Signal)
type Signal = SignalModule.Signal<any>

type TableEnums = {Enum.KeyCode | Enum.UserInputType}
type PossibleBinds = {[Enum.KeyCode | Enum.UserInputType]: any}

export type KeybindTypes = "Press" | "Hold" | "Toggle" | "MultipleTaps" | "StrictSequence"
export type EventTypes = "Triggered" | "InputBegan" | "InputEnded"
export type InputChoices = InputObject | Enum.KeyCode | Enum.UserInputType






export type Keybind = Methods & Internals & {
	Settings: KeybindSettings,
	BehaviorVars: BehaviorVars,
	_OverrideOtherContextActions: boolean
}

export type PrivateKeybind = Keybind & PrivateMethods


export type KeybindSettings = {
    KeybindType: KeybindTypes,
    RequireAllButtons: boolean,
    Enabled: boolean,
    Name: string,
    BindedKeys: {
        Keyboard: {Enum.KeyCode | Enum.UserInputType},
        Console: {Enum.KeyCode | Enum.UserInputType},
    },

}

export type Internals = {
    Signals: {
        Default: {
            Triggered: Signal,
            InputBegan: Signal,
            InputEnded: Signal
        },
        Custom: {[string]: {
            Signal: Signal,
            InputState: "Began" | "End",
            Platform: "Keyboard" | "Console",
            Behavior: "PressAll" | TableEnums
        }},
    },
}



export type BehaviorVars = {
	CustomArgs: {any}?,
	LastKeyCheck: any?,
	CurrentTimeDuration: number,
	Connection: Signal,
	Func: (Bind: PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: InputChoices) -> (nil),
	CustomLogic: (Bind: PrivateKeybind, Name: string, Platform: string, InputState: Enum.UserInputState, Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (boolean),

    PressedKeys: {
        Keyboard: PossibleBinds,
        Console: PossibleBinds
	},
	
    KeybindConfig: {
        TimeWindow: number,
        ClickCount: number?
    },
}


export type Methods = {
    Enable: (self: Keybind) -> (Keybind),
    Disable: (self: Keybind) -> (Keybind),
    Destroy: (self: Keybind) -> (Keybind),
	SetSignalArgs: (self: Keybind, ...any) -> (Keybind),
	Construct: (self:Keybind, InfoTable: ConstructTable) -> (Keybind),
	CreateConnection: (self: Keybind, SignalName: string) -> (Keybind),
	DisconnectSignal: (self: Keybind, SignalType: EventTypes) -> (Keybind),
	Once: (self: Keybind, SignalType: EventTypes, Func: (InputObject, ...any) -> ()) -> (Keybind),
	Connect: (self: Keybind, SignalType: EventTypes, Func: (InputObject, ...any) -> ()) -> (Keybind),
	SetPlatformBinds: (self: Keybind, Platform: "Keyboard" | "Console", NewBinds: TableEnums) -> (Keybind),
	AddCustomLogic: (self: Keybind, Func: (Bind: Keybind, BindName: string, InputState: Enum.UserInputState, Key: any) -> (boolean)) -> (Keybind),
	WrapSignal: (self: Keybind, SignalName: string, Signal: RBXScriptSignal, Behavior: "PressAll" | TableEnums, InputState: "Begin" | "End", Platform: "Keyboard" | "Console") -> (Keybind),
}

export type PrivateMethods = {
    _FireSignal: (self: PrivateKeybind, SignalName: "Triggered" | "InputBegan" | "InputEnded", Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (nil),
    _PerformCustomLogic: (self: PrivateKeybind, BindName: string, InputState: "Began" | "End", Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (boolean),
    _AreEnoughKeysPressed: (self: PrivateKeybind, Platform: string) -> (boolean)
}

export type Module = {
    CreateKeybind: (KeybindName: string, KeybindType: KeybindTypes, RequireAll: boolean, KeybindSettings: {TimeWindow: number, ClickCount: number?}?) -> (Keybind),
    GetKeybind: (KeybindName: string) -> (Keybind),
    EnableAll: () -> (),
    DisableAll: () ->()
}


export type SignalArgs = {
	SignalName: string,
	Signal: RBXScriptSignal,
	Behavior: "PressAll" | TableEnums,
	InputState: "Began" | "End",
	Platform: "Keyboard" | "Console"
}

export type ConstructTable = {
    Keyboard: TableEnums?,
    Console: TableEnums?,
    CustomSignals: {SignalArgs}?,
    Callbacks: {
        [EventTypes]: (KeyPressed: InputObject, ...any) -> ()
    }
}

return nil