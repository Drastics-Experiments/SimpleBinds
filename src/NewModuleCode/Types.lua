local SignalModule = require(script.Parent.Signal)
type Signal = typeof(SignalModule.new(table.unpack(...)))

export type KeybindSettings = {
    KeybindType: "Press" | "Toggle" | "MultipleTaps" | "StrictSequence",
    RequireAllButtons: boolean,
    Enabled: boolean,
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
        Custom: {[string]: Signal},
    },
}

export type BehaviorVars = {
    PressedKeys: {
        Keyboard: TableEnums,
        Console: TableEnums
    },
    CustomArgs: {any}?,
    Func: () -> ()
}

export type Keybind = Methods & Internals & {
    Settings: KeybindSettings,
    BehaviorVars: BehaviorVars
}

export type Methods = {
    Enable: (Keybind) -> (Keybind),
    Disable: (Keybind) -> (Keybind),
    Destroy: (Keybind) -> (Keybind),
    WrapSignal: (Keybind, Signal: RBXScriptSignal) -> (Keybind),
    Construct: (Keybind, InfoTable: ConstructTable) -> (Keybind),
    SetSignalArgs: (Keybind, ...any) -> (Keybind),
    SetPlatformBinds: (Keybind, Platform: "Keyboard" | "Console", NewBinds: TableEnums) -> (Keybind)
}

export type Module = {
    CreateKeybind: (KeybindName: string) -> (Keybind),
    GetKeybind: (KeybindName: string) -> (Keybind),
    EnableAll: () -> (),
    DisableAll: () ->()
}


type TableEnums = {Enum.KeyCode | Enum.UserInputType}


export type ConstructTable = {
    Keyboard: TableEnums?,
    Console: TableEnums?,
    CustomSignals: {
        [string]: {
            Signal: RBXScriptSignal,
            Behavior: "PressAll" | TableEnums,
            InputState: "Began" | "Ended"
        }
    }?,
    Callbacks: {
        ["Triggered" | "InputBegan" | "InputEnded"]: (KeyPressed: InputObject, ...any) -> ()
    }
}

return nil