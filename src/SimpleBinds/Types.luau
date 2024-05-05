local SignalModule = require(script.Parent.Signal)
type Signal = SignalModule.Signal
type TableEnums = {Enum.KeyCode | Enum.UserInputType}
type PossibleBinds = {[Enum.KeyCode | Enum.UserInputType]: any}
export type InputChoices = InputObject | Enum.KeyCode | Enum.UserInputType

export type KeybindSettings = {
    KeybindType: "Press" | "Toggle" | "MultipleTaps" | "StrictSequence",
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
    PressedKeys: {
        Keyboard: PossibleBinds,
        Console: PossibleBinds
    },
    CustomArgs: {any}?,
    Func: (Bind: PrivateKeybind, BindName: string, InputState: Enum.UserInputState, Key: InputChoices) -> (nil),
    KeybindConfig: {
        TimeWindow: number,
        ClickCount: number?
    }?,
    Connection: RBXScriptConnection?,
    CurrentTimeDuration: number?,
    LastKeyCheck: any?,
    CustomLogic: (Bind: PrivateKeybind, Name: string, Platform: string, InputState: Enum.UserInputState, Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (boolean)
}

export type Keybind = Methods & Internals & {
    Settings: KeybindSettings,
    BehaviorVars: BehaviorVars
}

export type PrivateKeybind = Keybind & PrivateMethods

export type Methods = {
    Enable: (self: Keybind) -> (Keybind),
    Disable: (self: Keybind) -> (Keybind),
    Destroy: (self: Keybind) -> (Keybind),
    WrapSignal: (self: Keybind, SignalName: string, Signal: RBXScriptSignal, Behavior: "PressAll" | TableEnums, InputState: "Begin" | "End", Platform: "Keyboard" | "Console") -> (Keybind),
    Construct: (self:Keybind, InfoTable: ConstructTable) -> (Keybind),
    SetSignalArgs: (self: Keybind, ...any) -> (Keybind),
    AddCustomLogic: (self: Keybind, Func: (...any) -> (boolean)) -> (Keybind),
    SetPlatformBinds: (self: Keybind, Platform: "Keyboard" | "Console", NewBinds: TableEnums) -> (Keybind)
}

export type PrivateMethods = {
    _FireSignal: (self: PrivateKeybind, SignalName: "Triggered" | "InputBegan" | "InputEnded", Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (nil),
    _PerformCustomLogic: (self: PrivateKeybind, BindName: string, InputState: "Began" | "End", Key: InputObject | Enum.KeyCode | Enum.UserInputType) -> (boolean),
    _CreateConnection: (self: PrivateKeybind, SignalName: string) -> (nil),
    _AreEnoughKeysPressed: (self: PrivateKeybind, Platform: "Keyboard" | "Console") -> (boolean)
}

export type Module = {
    CreateKeybind: (KeybindName: string, KeybindType: "Press" | "Hold" | "Toggle" | "MultipleTaps" | "StrictSequence", RequireAll: boolean, KeybindSettings: {TimeWindow: number, ClickCount: number?}?) -> (Keybind),
    GetKeybind: (KeybindName: string) -> (Keybind),
    EnableAll: () -> (),
    DisableAll: () ->()
}




export type ConstructTable = {
    Keyboard: TableEnums?,
    Console: TableEnums?,
    CustomSignals: {
        {
            SignalName: string,
            Signal: RBXScriptSignal,
            Behavior: "PressAll" | TableEnums,
            InputState: "Began" | "Ended",
            Playform: "Keyboard" | "Console"
        }
    }?,
    Callbacks: {
        ["Triggered" | "InputBegan" | "InputEnded"]: (KeyPressed: InputObject, ...any) -> ()
    }
}

return nil