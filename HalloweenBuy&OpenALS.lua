-- ALS Auto Buy & Open HalloweenCapsule
repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ItemsGui = PlayerGui:WaitForChild("Items")

local Items = ItemsGui:WaitForChild("BG"):WaitForChild("Items")

local HalloweenCoins = Player:WaitForChild("Halloween_Currency").Value
local HalloweenCapsule = Items:FindFirstChild("Halloween_Capsule")

local Cost = 50

local Count = math.floor(HalloweenCoins / Cost)

local function AutoBuyOpen()
	if HalloweenCoins >= Cost then
		for i = 1, Count do
			task.wait()
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SummerEvent"):FireServer("Halloween_Capsule")
			HalloweenCoins = HalloweenCoins - Cost
		end
	else
		while HalloweenCapsule do
			task.wait()
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OpenCapsule"):FireServer("Halloween_Capsule")
			HalloweenCapsule = Items:FindFirstChild("Halloween_Capsule")
		end
	end
end

AutoBuyOpen()
