repeat task.wait() until game:IsLoaded()

if game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Enabled == false or 
	game:GetService("Players").LocalPlayer.Rerolls.Value == 0 then
	return
end

local Glitched = "rbxassetid://14857416817"
local Avatar = "rbxassetid://14857393213"
local Overlord = "rbxassetid://14857401537"
local Shinigami = "rbxassetid://14857405207"
local AllSeeing = "rbxassetid://14857407287"
local Entrepreneur = "rbxassetid://14857394535"
local Vulture = "rbxassetid://15110769879"
local Diamond = "rbxassetid://14857403680"
local Cosmic = "rbxassetid://14857423915"
local DemiGod = "rbxassetid://14857390891"
local EdgeEyes = "rbxassetid://14857410430"
local Golden = "rbxassetid://14857415303"
local HyperSpeed = "rbxassetid://14857413772"
local Juggernaut = "rbxassetid://14857418354"
local ElementalMaster = "rbxassetid://14857412247"
local Scoped = "rbxassetid://14857396451"
local Sturdy = "rbxassetid://14857425345"
local Accelerate = "rbxassetid://14857421206"
local Shining = "rbxassetid://14857422439"

local WantedTechniques = {
	Glitched,
	Avatar,
	Overlord,
	Shinigami,
	AllSeeing,
	Entrepreneur,
}

StartAutoReroll = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local QuirksUI = Player.PlayerGui.QuirksUI
local RerollButton = QuirksUI.BG.Reroll
local ConfirmButton = QuirksUI.Confirm.Confirm.Accept

local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("GuiService")

local function Select(element)
	if element and element.Selectable then
		UIS.SelectedObject = element
	end
end

local function KeyPress(keyCode)
	VIM:SendKeyEvent(true, keyCode, false, game)
	VIM:SendKeyEvent(false, keyCode, false, game)
end

for i, v in pairs(WantedTechniques) do
	if v == QuirksUI.BG.Technique.Icon.Image then
		return
	end
end

while task.wait(0.1) do

	if QuirksUI.Enabled == false then
		StartAutoReroll = false
		KeyPress(Enum.KeyCode.BackSlash)
	end

	if Player.Rerolls.Value == 0 then
		StartAutoReroll = false
		KeyPress(Enum.KeyCode.BackSlash)
	end

	if StartAutoReroll == false then
		break
	end

	local CurrentTechnique = QuirksUI.BG.Technique.Icon.Image
	local GotTechnique = QuirksUI.BG.Technique.Title.Text

	if StartAutoReroll == true then
		for i, v in pairs(WantedTechniques) do
			if v == CurrentTechnique then
				for i, v in pairs(QuirksUI.BG.Select.ViewportFrame.WorldModel:GetChildren()) do
					if v:IsA("Model") then
						game:GetService("StarterGui"):SetCore("SendNotification",{
							Title = "Reroll Finished",
							Text = v.Name.. " Rolled " .. GotTechnique .. "!",
							KeyPress(Enum.KeyCode.BackSlash)
						})
					end
				end
				StartAutoReroll = false
			end
		end

		if StartAutoReroll == true then
			if QuirksUI.Confirm.Visible == false then
				Select(RerollButton)
				KeyPress(Enum.KeyCode.Return)
			elseif QuirksUI.Confirm.Visible == true then
				Select(ConfirmButton)
				KeyPress(Enum.KeyCode.Return)
			else
				wait()
				break	
			end
		else
			wait()
			break
		end
	end
end