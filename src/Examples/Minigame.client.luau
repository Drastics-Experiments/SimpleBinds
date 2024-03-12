--> havent verified if this works yet

local SimpleBinds = require(script.Parent.Parent.SimpleBinds)


local Keybind = SimpleBinds.CreateKeybind("Minigame", "MulipleTaps", true, 10, 4)

local kc = Enum.KeyCode

local PossibleButtons = {
    kc.F,
    kc.G,
    kc.H,
    kc.J,
    kc.K,
    kc.L
}

local function Refresh()
    if Keybind.Enabled then
        Keybind:Disable()
    end

    local RandomList = {}
    for i = 1,3 do
        local num = math.random(1, #PossibleButtons)
        RandomList[i] = PossibleButtons[num]
        PossibleButtons[num] = nil
    end

    print(RandomList)

    Keybind:SetPlatformBinds("Keyboard", RandomList)
    Keybind:Enable()
end

local won = false
local lost = false

local function AddToStreak()
    if lost then return end
    if won then return end

    Keybind:Disable()
    print(`Your current streak is: {Keybind.SpecialVars.InputProcessed}!`)
    task.wait(1)
    Refresh()
end

local function win()
    won = true
    print("You won!!")
    Keybind:Disable()
end

local function StartMinigame()
    won = false
    lost = false
    Keybind:ConnectToDefaultSignal("InputBegan", AddToStreak)
    Keybind:ConnectToDefaultSignal("Triggered", win)
    Refresh()

    task.delay(10, function()
        Keybind:Disable()
        if won then return end
        if Keybind.SpecialVars.InputProcessed < Keybind.Settings.TapAmount then
            lost = true
            print("You Lost!")
        end
    end)
end

StartMinigame()