-- ALS Auto Stat Roll
repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local StatRerollGui = PlayerGui:WaitForChild("StatReroll")
local ItemsGui = PlayerGui:WaitForChild("Items")

local Stats = {
	{ Name = "Damage", Stat = StatRerollGui.BG.Content.Stats.Damage },
	{ Name = "Range", Stat = StatRerollGui.BG.Content.Stats.Range },
	{ Name = "Speed", Stat = StatRerollGui.BG.Content.Stats.Speed },
}

local UnitId = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("UnitID", false)
local UnitName = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("Unit", false)

local Items = ItemsGui.BG.Items
local StatCube = Items:FindFirstChild("StatCube")
local PerfectStatCube = Items:FindFirstChild("PerfectStatCube")

local StatCubeCount, PerfectStatCubeCount = 0, 0

UseNormalStatCube = getgenv().UseNormalStatCube
UsePerfectStatCube = getgenv().UsePerfectStatCube
AcceptLowerGrades = getgenv().AcceptLowerGrades

WantedGrades = getgenv().WantedGrades

MinGradeCount = getgenv().MinGradeCount

local function HasWantedGrade(Stat, StatName)
	return table.find(WantedGrades[StatName], Stat.Grade.ContentText) ~= nil
end

local function MeetsMinGradeCount()
	local GradeCount = {}

	for _, StatData in ipairs(Stats) do
		local Grade = StatData.Stat.Grade.ContentText
		GradeCount[Grade] = (GradeCount[Grade] or 0) + 1
	end

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
		if ActualCount < MinCount then
			return false
		end
	end

	return true
end

local function GetStatToReroll()
	for _, StatData in ipairs(Stats) do
		if not HasWantedGrade(StatData.Stat, StatData.Name) then
			return StatData.Name
		end
	end
	return nil
end

local function RerollStats(UseNormalCube)
	if UseNormalCube then
		if not (StatCube and UseNormalStatCube) then
			return false
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId)
		StatCubeCount = StatCubeCount + 1
	else
		local StatToReroll = GetStatToReroll()
		if not StatToReroll then
			return false
		end
		if not (PerfectStatCube and UsePerfectStatCube) then
			return false
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId, StatToReroll)
		PerfectStatCubeCount = PerfectStatCubeCount + 1
	end
	return true
end

local function ShowResults()
	print("======================================")
	print("Unit: " .. UnitName)
	print("======================================")
	print("Final Stats:")
	for _, StatData in ipairs(Stats) do
		print(string.format("  %s: %s", StatData.Name, StatData.Stat.Grade.ContentText))
	end
	print("======================================")
	print("Cubes Used:")
	print("  Stat Cubes: " .. StatCubeCount)
	print("  Perfect Stat Cubes: " .. PerfectStatCubeCount)
	print("======================================\n\n\n")
end

local function Main()
	while StatRerollGui.Enabled do
		local MeetsMinimum = MeetsMinGradeCount()

		local UseNormal = UseNormalStatCube and StatCube

		if MeetsMinimum then
			print("Desired stats achieved!")
			UseNormal = false
		end

		if not RerollStats(UseNormal) then
			if not UseNormal and UsePerfectStatCube and PerfectStatCube then
				if not RerollStats(false) then
					break
				end
			else
				break
			end
		end

		task.wait(0.5)
	end

	ShowResults()
end

Main()
