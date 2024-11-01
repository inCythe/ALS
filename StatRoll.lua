repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local StatRerollGui = PlayerGui:WaitForChild("StatReroll")
local ItemsGui = PlayerGui:WaitForChild("Items")

-- Stats
local Stats = {
	{ Name = "Damage", Instance = StatRerollGui.BG.Content.Stats.Damage },
	{ Name = "Range", Instance = StatRerollGui.BG.Content.Stats.Range },
	{ Name = "Speed", Instance = StatRerollGui.BG.Content.Stats.Speed },
}

local UnitId = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("UnitID")

local Items = ItemsGui.BG.Items
local StatCube = Items:FindFirstChild("StatCube")
local PerfectStatCube = Items:FindFirstChild("PerfectStatCube")

local StatCubeCount, PerfectStatCubeCount = 0, 0

-- Grade Index
local GradeValues = {
	["SSS"] = 11,
	["SS"] = 10,
	["S+"] = 9,
	["S"] = 8,
	["S-"] = 7,
	["A+"] = 6,
	["A"] = 5,
	["A-"] = 4,
	["B"] = 3,
	["C+"] = 2,
	["C"] = 1,
	["C-"] = 0,
}

-- Configs
local UseNormalStatCube = type(getgenv().UseNormalStatCube) == nil and getgenv().UseNormalStatCube or true
local UsePerfectStatCube = type(getgenv().UsePerfectStatCube) == nil and getgenv().UsePerfectStatCube or true

local WantedGrades = getgenv().WantedGrades
	or {
		Damage = { "SSS", "SS", "S+", "S", "S-" },
		Range = { "SSS", "SS", "S+", "S", "S-" },
		Speed = { "SSS", "SS", "S+", "S", "S-" },
	}

local MinGradeCount = getgenv().MinGradeCount or {
	["SSS"] = 1,
	["SS"] = 1,
	["S+"] = 2,
	["S"] = 2,
	["S-"] = 2,
}

-- Get Current Grades
local function CurrentGrades()
	local CurrentGrade = {}
	for _, Stat in ipairs(Stats) do
		if Stat.Instance and Stat.Instance:FindFirstChild("Grade") then
			CurrentGrade[Stat.Name] = Stat.Instance.Grade.ContentText
		end
	end
	return CurrentGrade
end

-- Comapare Grades
local function CompareGrades(Grade1, Grade2)
	local Value1 = GradeValues[Grade1] or -1
	local Value2 = GradeValues[Grade2] or -1
	return Value1 >= Value2
end

-- Checks if Current Grade meets Min Grade Req
local function GradeMeetsMin(CurrentGrade, MinGrade)
	return CompareGrades(CurrentGrade, MinGrade)
end

-- Checks if Current Grade meets Min Grade Count
local function MeetsMinGradeCount()
	local CurrentGradesTable = CurrentGrades()
	local HighGradeCount = 0

	for MinGrade, RequiredCount in pairs(MinGradeCount) do
		local Count = 0
		for _, Grade in pairs(CurrentGradesTable) do
			if GradeMeetsMin(Grade, MinGrade) then
				Count = Count + 1
			end
		end
		if Count >= RequiredCount then
			HighGradeCount = HighGradeCount + 1
		end
	end

	return HighGradeCount > 0
end

-- Check if a Stat has Wanted Grade
local function HasWantedGrade(StatName, CurrentGrade)
	if not WantedGrades[StatName] or not CurrentGrade then
		return false
	end

	for _, WantedGrade in ipairs(WantedGrades[StatName]) do
		if GradeMeetsMin(CurrentGrade, WantedGrade) then
			return true
		end
	end
	return false
end

-- Get the Stat that needs rerolling
local function StatToReroll()
	local CurrentGradesTable = CurrentGrades()
	local WorstStat = nil
	local WorstValue = math.huge

	for StatName, CurrentGrade in pairs(CurrentGradesTable) do
		if not HasWantedGrade(StatName, CurrentGrade) then
			local Value = GradeValues[CurrentGrade] or -1
			if Value < WorstValue then
				WorstValue = Value
				WorstStat = StatName
			end
		end
	end

	return WorstStat
end

-- Roll Stats
local function RollStats(Type, StatToReroll)
	if Type == "Normal" then
		if not (StatCube and UseNormalStatCube) then
			return false
		end
		if MeetsMinGradeCount() then
			return false
		end

		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId)
		StatCubeCount = StatCubeCount + 1
		print("Using Normal Cube")
		return true
	elseif Type == "Perfect" then
		if not (PerfectStatCube and UsePerfectStatCube) then
			return false
		end
		if not StatToReroll then
			return false
		end
		if not MeetsMinGradeCount() then
			return false
		end

		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId, StatToReroll)
		PerfectStatCubeCount = PerfectStatCubeCount + 1
		print("Using Perfect Cube on: " .. StatToReroll)
		return true
	end
	return false
end

-- Main loop
local function Main()
	print("Starting reroll process...")

	while StatRerollGui.Enabled do
		if not UnitId then
			break
		end

		if not MeetsMinGradeCount() then
			if not RollStats("Normal") then
				break
			end
		else
			local RerollStat = StatToReroll()
			if not RerollStat then
				print("All Stats meet requirements")
				break
			end
			if not RollStats("Perfect", RerollStat) then
				break
			end
		end

		task.wait(0.5)
	end

	-- Print final results
	print("===================")
	print("  FINAL RESULTS")
	print("===================")
	print("Normal Cubes: " .. StatCubeCount)
	print("Perfect Cubes: " .. PerfectStatCubeCount)
	print("-------------------")

	local CurrentGradesTable = CurrentGrades()
	print("Final Grades:")
	print("DMG: " .. (CurrentGradesTable["Damage"] or "N/A"))
	print("RNG: " .. (CurrentGradesTable["Range"] or "N/A"))
	print("SPD: " .. (CurrentGradesTable["Speed"] or "N/A"))
	print("===================\n")
end

Main()
