-- ALS Auto Buy & Open SlimeCapsule
repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ItemsGui = PlayerGui:WaitForChild("Items")

local Items = ItemsGui:WaitForChild("BG"):WaitForChild("Items")

local SlimeCoins = Player:WaitForChild("SlimeCoins").Value
local SlimeCapsule = Items:FindFirstChild("SlimeCapsule")

local Count = math.floor(SlimeCoins / 15)

local function AutoBuyOpen()
	if SlimeCoins >= 15 then
		for i = 1, Count do
			task.wait()
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SummerEvent"):FireServer("SlimeCapsule")
			SlimeCoins = SlimeCoins - 15
		end
	else
		while SlimeCapsule do
			task.wait()
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OpenCapsule"):FireServer("SlimeCapsule")
			SlimeCapsule = Items:FindFirstChild("SlimeCapsule")
		end
	end
end

AutoBuyOpen()
