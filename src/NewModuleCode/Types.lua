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



export type Keybind = Methods & Internals & KeybindSettings

export type Methods = {
    Enable: (Keybind) -> (Keybind),
    Disable: (Keybind) -> (Keybind),
    Destroy: (Keybind) -> (Keybind),
    WrapSignal: () -> ()
}

export type Module = {
    CreateKeybind: (KeybindName: string) -> (Keybind),
    GetKeybind: (KeybindName: string) -> (Keybind)
}

return {}