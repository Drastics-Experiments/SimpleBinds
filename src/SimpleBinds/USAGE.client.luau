local SimpleBinds = require(script.Parent)

SimpleBinds.CreateKeybind({
    Name = "Example",
    KeybindType = "Press",
    RequireAll = false,
}):Construct({
    Keyboard = {Enum.UserInputType.MouseButton1},
    Console = {},
})