local SignalModule = require(script.Parent.Signal)
type Signal = typeof(SignalModule.new(table.unpack(...)))

type KeybindSettings = {
    KeybindType: "Press" | "Toggle" | "MultipleTaps" | "StrictSequence",
    RequireAllButtons: boolean,
    BindedKeys: {
        Keyboard: {Enum.KeyCode, Enum.UserInputType},
        Console: {Enum.KeyCode, Enum.UserInputType},
    },

}

type Internals = {
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
    Enable: (self: Keybind) -> (self: Keybind),
    Disable: (self: Keybind) -> (self: Keybind),
    Destroy: (self: Keybind) -> (self: Keybind),
    WrapSignal: () -> ()
}

export type Module = {
    CreateKeybind: (KeybindName: string) -> (Keybind),
    GetKeybind: (KeybindName: string) -> (Keybind)
}

return nil