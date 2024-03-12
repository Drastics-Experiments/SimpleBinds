local starterPlayer = game:GetService("StarterPlayer")

local SimpleBinds = require(script.Parent.Parent.SimpleBinds)
local player = game.Players.LocalPlayer

local screen = Instance.new("ScreenGui")
local button = Instance.new("TextButton")

button.Parent = screen
screen.Parent = player:WaitForChild("PlayerGui")
button.Size = UDim2.new(0,200,0,100)
button.Position = UDim2.new(0.5,0,0.5,0)

screen.ResetOnSpawn = false

local function startSprint()
	if not player.Character then player.CharacterAdded:Wait() end
	local humanoid = player.Character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = starterPlayer.CharacterWalkSpeed * 3
end

local function endSprint()
	if not player.Character then player.CharacterAdded:Wait() end
	local humanoid = player.Character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = starterPlayer.CharacterWalkSpeed
end

local keys = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }

SimpleBinds.CreateKeybind("Sprint", "Toggle", false)
	:Construct({
		Keyboard = keys, 
		Console = { Enum.KeyCode.Thumbstick1 }, 
		CustomSignals = {
			buttonPressed = {
				Signal = button.MouseButton1Down,
				SimulatedButtons=keys,
				InputState = "Begin",
			},
			buttonReleased = {
				Signal = button.MouseButton1Up,
				SimulatedButtons=keys,
				InputState = "End",
			},    
		},
		Callbacks = {
			InputBegan = startSprint,
			InputEnded = endSprint
		}
	})

	:Enable()