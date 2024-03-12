--!strict

--> SimpleBinds Module v1 <--

--> DM daz_. on Discord with any questions/bug reports
--> https://discordapp.com/users/679803821337215020

local Methods = require(script.Methods)
local Behavior = require(script.Behavior)
local Template = require(script.Template) 

local KeyStorage = {}

local function GetCorrectBehavior(Name: string, State: Enum.UserInputState, Button: InputObject | Enum.KeyCode | Enum.UserInputType)
	local Args = string.split(Name, "_")
	local self = KeyStorage[Args[1]]
	
	Behavior[`Behavior_{self.Settings.InputType}`](self, Args, State, Button)
end

local function __destroy(KeybindName)
	KeyStorage[KeybindName] = nil
end

local function CreateKeybind(Name: string, InputType: "Press" | "Hold" | "Toggle" | "MultipleTaps", RequireAllButtons: boolean, Duration: number?, TapAmount: number?) 
	local self = setmetatable(Template(), Methods)
	
	local Settings = self.Settings
	Settings.Name = Name
	Settings.InputType = InputType
	Settings.Duration = Duration
	Settings.TapAmount = TapAmount
	Settings.RequireAllButtons = RequireAllButtons
		
	KeyStorage[Name] = self

	return self
end

local function GetKeybind(Name: string)
	return KeyStorage[Name]
end

Methods.__pressed:Connect(GetCorrectBehavior)
Methods.__destroy:Connect(__destroy)

local SimpleBinds = {}

SimpleBinds.CreateKeybind = CreateKeybind
SimpleBinds.GetKeybind = GetKeybind

return SimpleBinds