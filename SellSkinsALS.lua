-- ALS Auto Sell Skins
repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ItemsGui = PlayerGui:WaitForChild("Items")

local Skins = ItemsGui.BG.Skins

local function AutoSellByRarities(TargetRarities)
	local Args = {
		[1] = {},
	}

	for _, Skin in pairs(Skins:GetChildren()) do
		local SkinRarity = Skin:GetAttribute("Rarity", false)
		local SkinID = Skin.Name

		if SkinRarity and table.find(TargetRarities, SkinRarity) then
			Args[1][SkinID] = true
		end
	end

	if next(Args[1]) then
		ReplicatedStorage.Remotes.Skins.Sell:InvokeServer(unpack(Args))
		print("Sold skins of rarities:", table.concat(TargetRarities, ", "))
	else
		print("No skins of rarities", table.concat(TargetRarities, ", "), "found.")
	end
end

Rarities = getgenv().Rarities or { "Rare", "Common" }

AutoSellByRarities(Rarities)
