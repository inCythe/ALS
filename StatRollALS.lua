-- ALS Auto Stat Roll Script

-- Wait until the game is fully loaded
repeat
	task.wait()
until game:IsLoaded()

-- Services and player setup
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local StatRerollGui = PlayerGui:WaitForChild("StatReroll")
local ItemsGui = PlayerGui:WaitForChild("Items")

-- Stat setup
local Stats = {
	{ Name = "Damage", Stat = StatRerollGui.BG.Content.Stats.Damage },
	{ Name = "Range", Stat = StatRerollGui.BG.Content.Stats.Range },
	{ Name = "Speed", Stat = StatRerollGui.BG.Content.Stats.Speed },
}

-- Unit info
local UnitId = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("UnitID", false)
local UnitName = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("Unit", false)

-- Item setup (Stat Cubes)
local Items = ItemsGui.BG.Items
local StatCube = Items:FindFirstChild("StatCube")
local PerfectStatCube = Items:FindFirstChild("PerfectStatCube")
local StatCubeCount, PerfectStatCubeCount = 0, 0

-- Configuration options
local UseNormalStatCube = getgenv().UseNormalStatCube ~= nil and getgenv().UseNormalStatCube or true
local UsePerfectStatCube = getgenv().UsePerfectStatCube ~= nil and getgenv().UsePerfectStatCube or true
local AcceptLowerGrades = getgenv().AcceptLowerGrades ~= nil and getgenv().AcceptLowerGrades or true

-- Wanted grades per stat
local WantedGrades = getgenv().WantedGrades
	or {
		Damage = { "SSS", "SS", "S+", "S", "S-" },
		Range = { "SSS", "SS", "S+", "S", "S-" },
		Speed = { "SSS", "SS", "S+", "S", "S-" },
	}

-- Minimum grade count for each stat
local MinGradeCount = getgenv().MinGradeCount or {
	["SSS"] = 1,
	["SS"] = 1,
	["S+"] = 2,
	["S"] = 2,
	["S-"] = 2,
}

-- Check if a stat has the Wanted grade
local function HasWantedGrade(Stat, StatName)
	return table.find(WantedGrades[StatName], Stat.Grade.ContentText) ~= nil
end

-- Check if the minimum required number of grades is met
local function MeetsMinGradeCount()
	local GradeCount = {}

	-- Count the occurrences of each grade
	for _, StatData in ipairs(Stats) do
		local Grade = StatData.Stat.Grade.ContentText
		GradeCount[Grade] = (GradeCount[Grade] or 0) + 1
	end

	-- Check if the minimum counts are met
	for Grade, MinCount in pairs(MinGradeCount) do
		local ActualCount = 0
		for _, StatData in ipairs(Stats) do
			if
				StatData.Stat.Grade.ContentText == Grade
				or (
					AcceptLowerGrades
					and table.find(WantedGrades[StatData.Name], StatData.Stat.Grade.ContentText) ~= nil
				)
			then
				ActualCount = ActualCount + 1
			end
		end
		if ActualCount >= MinCount then
			return true
		end
	end

	return false
end

-- Determine which stat to reroll
local function GetStatToReroll()
	for _, StatData in ipairs(Stats) do
		if not HasWantedGrade(StatData.Stat, StatData.Name) then
			return StatData.Name
		end
	end
	return nil
end

-- Perform stat rerolling based on cube type
local function RerollStats(Cube)
	if Cube == "Normal" then
		-- Use normal cube
		if not (StatCube and UseNormalStatCube) then
			return false
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId)
		StatCubeCount = StatCubeCount + 1
	elseif Cube == "Perfect" then
		-- Use perfect cube
		local StatToReroll = GetStatToReroll()
		if not StatToReroll then
			return false
		end
		if not (PerfectStatCube and UsePerfectStatCube) then
			return false
		end
		-- Check if reroll is necessary
		for _, StatData in ipairs(Stats) do
			if StatData.Name == StatToReroll and HasWantedGrade(StatData.Stat, StatData.Name) then
				return false
			end
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId, StatToReroll)
		PerfectStatCubeCount = PerfectStatCubeCount + 1
	end
	return true
end

-- Display final results after rerolling
local function ShowResults()
	print(string.rep("=", 40))
	print("Unit: " .. UnitName)
	print(string.rep("=", 40))
	print("Final Stats:")
	for _, StatData in ipairs(Stats) do
		print(string.format("  %s: %s", StatData.Name, StatData.Stat.Grade.ContentText))
	end
	print(string.rep("=", 40))
	print("Cubes Used:")
	print("  Stat Cubes: " .. StatCubeCount)
	print("  Perfect Stat Cubes: " .. PerfectStatCubeCount)
	print(string.rep("=", 40))
end

-- Main rerolling process
local function Main()
	while StatRerollGui.Enabled do
		if
			MeetsMinGradeCount()
			and not (function()
				for _, StatData in ipairs(Stats) do
					if not HasWantedGrade(StatData.Stat, StatData.Name) then
						return false
					end
				end
				return true
			end)()
		then
			break
		end

		-- Determine and pass the appropriate cube type
		if UseNormalStatCube and StatCube and not MeetsMinGradeCount() then
			if not RerollStats("Normal") then
				break
			end
		else
			if not RerollStats("Perfect") then
				break
			end
		end

		task.wait(0.5)
	end

	ShowResults()
end

Main()
