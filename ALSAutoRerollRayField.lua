repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

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

local WantedTechniques = {}
local StartAutoReroll = false

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
	label:Set(table.concat(selectedtraits, ", "))
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

local function AutoRoll()
	while StartAutoReroll do
		local GotTechnique, TechniqueName = CheckCurrentTechnique()
		if not GotTechnique then
			RollTechnique()
		else
			StartAutoReroll = false
			NotifyRollResult(TechniqueName)
		end
		task.wait()
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

local ALS = Rayfield:CreateWindow({
	Name = "ALS Auto Reroll",
	LoadingTitle = "ALS Auto Reroll [100% Luck Buff]",
	LoadingSubtitle = "W_W",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "SelectedTraits",
	},
})

local RerollTab = ALS:CreateTab("Reroll")

local SelectedTraitsLabel = RerollTab:CreateLabel("")

local AutoRollToggle = RerollTab:CreateToggle({
	Name = "Roll",
	CurrentValue = false,
	Callback = function(Value)
		StartAutoReroll = Value
		if Value then
			coroutine.wrap(AutoRoll)()
		end
	end,
})

local SelectTrait = RerollTab:CreateDropdown({
	Name = "Select Trait",
	CurrentOption = {},
	Flag = "SelectedTraits",
	MultipleOptions = true,
	Options = Techniques,
	Callback = function(Options)
		WantedTechniques = {}
		for _, Option in ipairs(Options) do
			WantedTechniques[Option] = TechniqueIds[Option]
		end
		UpdateLabel(SelectedTraitsLabel)
	end,
})

local ClearButton = RerollTab:CreateButton({
	Name = "Clear",
	Callback = function()
		WantedTechniques = {}
		SelectTrait:Set({})
		SelectedTraitsLabel:Set("")
	end,
})

local Codes = RerollTab:CreateButton({
	Name = "Redeem Codes",
	Callback = RedeemCodes,
})

local Close = RerollTab:CreateButton({
	Name = "Destroy Script",
	Callback = function()
		Rayfield:Destroy()
	end,
})

Rayfield:LoadConfiguration()
