repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local SettingsLibrary = loadstring(
	game:HttpGet(
		"https://raw.githubusercontent.com/Suricato006/Scripts-Made-by-me/master/Libraries/SaveSettingsLibrary.lua"
	)
)()

local FileName = "RerollConfig.JSON"
local SettingsTable = SettingsLibrary.LoadSettings(FileName)

local ALS = Material.Load({
	Title = "ALS Auto Roll [100% Luck Buff] ",
	Style = 1,
	SizeX = 400,
	SizeY = 350,
	Theme = "Dark",
	ColorOverrides = {
		MainFrame = Color3.fromRGB(30, 30, 30),
	},
})

local RerollTab = ALS.New({
	Title = "Reroll",
})

local Techniques = {
	"Glitched",
	"Avatar",
	"Overlord",
	"Shinigami",
	"All Seeing",
	"Entrepreneur",
	"Vulture",
	"Diamond",
	"Cosmic",
	"Demi God",
	"Edge Eyes",
	"Golden",
	"Hyper Speed",
	"Juggernaut",
	"Elemental Master",
	"Shining",
	"Scoped",
	"Sturdy",
	"Accelerate",
}

local TechniqueIds = {
	Glitched = "rbxassetid://14857416817",
	Avatar = "rbxassetid://14857393213",
	Overlord = "rbxassetid://14857401537",
	Shinigami = "rbxassetid://14857405207",
	["All Seeing"] = "rbxassetid://14857407287",
	Entrepreneur = "rbxassetid://14857394535",
	Vulture = "rbxassetid://15110769879",
	Diamond = "rbxassetid://14857403680",
	Cosmic = "rbxassetid://14857423915",
	["Demi God"] = "rbxassetid://14857390891",
	["Edge Eyes"] = "rbxassetid://14857410430",
	Golden = "rbxassetid://14857415303",
	["Hyper Speed"] = "rbxassetid://14857413772",
	Juggernaut = "rbxassetid://14857418354",
	["Elemental Master"] = "rbxassetid://14857412247",
	Shining = "rbxassetid://14857422439",
	Scoped = "rbxassetid://14857396451",
	Sturdy = "rbxassetid://14857425345",
	Accelerate = "rbxassetid://14857421206",
}

local WantedTechniques = SettingsTable.WantedTechniques or {}

local function GetTechniqueName(assetId)
	for name, id in pairs(TechniqueIds) do
		if id == assetId then
			return name
		end
	end
	return "Unknown"
end

local function CheckCurrentTechnique()
	local QuirksUI = Player.PlayerGui.QuirksUI
	local CurrentTechnique = QuirksUI.BG.Content.Selection.QuirkIcon.Image

	for _, v in pairs(WantedTechniques) do
		if v == CurrentTechnique then
			return true, GetTechniqueName(v)
		end
	end
	return false, nil
end

local function UpdateLabel(label)
	local selectedtraits = {}
	for _, name in ipairs(Techniques) do
		if WantedTechniques[name] then
			table.insert(selectedtraits, name)
		end
	end
	label:SetText(table.concat(selectedtraits, ", "))
end

local function RollTechnique()
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Quirks"):WaitForChild("Roll"):InvokeServer()
end

local function NotifyRollResult(techniqueName)
	local QuirksUI = Player.PlayerGui.QuirksUI
	for _, model in pairs(QuirksUI.BG.Content.Selection.Viewport.WorldModel:GetChildren()) do
		if model:IsA("Model") then
			StarterGui:SetCore("SendNotification", {
				Title = "Reroll Finished",
				Text = model.Name .. " Rolled " .. techniqueName .. "!",
			})
			break
		end
	end
end

local function RedeemCodes()
	pcall(function()
		local codes = loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/main/codes.lua"))()
		if codes then
			for _, v in pairs(codes) do
				pcall(function()
					ReplicatedStorage.Remotes.ClaimCode:InvokeServer(v)
				end)
			end
		end
	end)
end

local function saveSettings()
	SettingsTable.WantedTechniques = WantedTechniques
	SettingsLibrary.SaveSettings(FileName, SettingsTable)
end

AutoRoll = RerollTab.Toggle({
	Text = "Roll",
	Callback = function(Value)
		coroutine.wrap(function()
			StartAutoReroll = Value
			while StartAutoReroll do
				local GotTechnique, TechniqueName = CheckCurrentTechnique()

				if not Player.PlayerGui.QuirksUI.Enabled or Player.Rerolls.Value == 0 then
					AutoRoll:SetState(false)
					return
				end

				if not GotTechnique then
					RollTechnique()
				else
					StartAutoReroll = false
					AutoRoll:SetState(false)
					NotifyRollResult(TechniqueName)
				end

				task.wait()
			end
		end)()
	end,
	Enabled = StartAutoReroll,
})

SelectedTraitsLabel = RerollTab.TextField({
	Text = "None",
})

SelectTrait = RerollTab.Dropdown({
	Text = "Select Trait",
	Callback = function(Value)
		if WantedTechniques[Value] then
			WantedTechniques[Value] = nil
		else
			WantedTechniques[Value] = TechniqueIds[Value]
		end
		UpdateLabel(SelectedTraitsLabel)
		saveSettings()
	end,
	Options = Techniques,
})

ClearButton = RerollTab.Button({
	Text = "Clear",
	Callback = function()
		WantedTechniques = {}
		SelectedTraitsLabel:SetText("None")
		saveSettings()
	end,
})

Codes = RerollTab.Button({
	Text = "Redeem Codes",
	Callback = function()
		RedeemCodes()
	end,
})

UpdateLabel(SelectedTraitsLabel)
