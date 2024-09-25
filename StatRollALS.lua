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
	{ Name = "Damage", Instance = StatRerollGui.BG.Content.Stats.Damage },
	{ Name = "Range", Instance = StatRerollGui.BG.Content.Stats.Range },
	{ Name = "Speed", Instance = StatRerollGui.BG.Content.Stats.Speed },
}

local UnitId = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("UnitID", false)
local UnitName = StatRerollGui.BG.Content.Unit.Selection:GetAttribute("Unit", false)

local Items = ItemsGui.BG.Items
local StatCube = Items:FindFirstChild("StatCube")
local PerfectStatCube = Items:FindFirstChild("PerfectStatCube")

local StatCubeCount, PerfectStatCubeCount = 0, 0

local UseNormalStatCube = getgenv().UseNormalStatCube ~= nil and getgenv().UseNormalStatCube or true
local UsePerfectStatCube = getgenv().UsePerfectStatCube ~= nil and getgenv().UsePerfectStatCube or true
local AcceptLowerGrades = getgenv().AcceptLowerGrades ~= nil and getgenv().AcceptLowerGrades or true

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

local function CurrentGrades()
	local CurrentGrade = {}
	for _, Stat in ipairs(Stats) do
		if Stat.Instance then
			CurrentGrade[Stat.Name] = Stat.Instance.Grade.ContentText
		end
	end
	return CurrentGrade
end

local function HasWantedGrade()
	local Results = {}
	local CurrentGradesTable = CurrentGrades()

	for StatName, WantedGradesList in pairs(WantedGrades) do
		Results[StatName] = false
		local CurrentGradeValue = CurrentGradesTable[StatName]

		if CurrentGradeValue then
			for _, WantedGrade in ipairs(WantedGradesList) do
				if CurrentGradeValue == WantedGrade then
					Results[StatName] = true
					break
				end
			end
		end
	end

	return Results
end

local function MeetsMinGradeCount()
	local CurrentGradeCounts = CurrentGrades()
	local GradeCounts = {}

	for _, Stat in ipairs(Stats) do
		local CurrentGrade = CurrentGradeCounts[Stat.Name]
		if CurrentGrade then
			GradeCounts[CurrentGrade] = (GradeCounts[CurrentGrade] or 0) + 1
		end
	end

	local function GradeMeetsRequirement(Grade, MinCount)
		local Count = 0

		if GradeCounts[Grade] then
			Count = Count + GradeCounts[Grade]
		end

		if AcceptLowerGrades then
			local FoundCurrentGrade = false
			for _, WantedGrade in ipairs(WantedGrades[Grade] or {}) do
				if not FoundCurrentGrade then
					if WantedGrade == Grade then
						FoundCurrentGrade = true
					end
				elseif GradeCounts[WantedGrade] then
					Count = Count + GradeCounts[WantedGrade]
				end

				if Count >= MinCount then
					return true
				end
			end
		end

		return Count >= MinCount
	end

	for Grade, MinCount in pairs(MinGradeCount) do
		if not GradeMeetsRequirement(Grade, MinCount) then
			return false
		end
	end

	return true
end

local function StatToReroll()
	for _, Stat in ipairs(Stats) do
		if not HasWantedGrade()[Stat.Name] then
			return Stat.Name
		end
	end
	return nil
end

local function RollStats(Type)
	if Type == "Normal" then
		if not (StatCube and UseNormalStatCube) then
			return false
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId)
		StatCubeCount = StatCubeCount + 1
		return true
	elseif Type == "Perfect" then
		local StatToReroll = StatToReroll()
		if not StatToReroll then
			return false
		end
		if not (PerfectStatCube and UsePerfectStatCube) then
			return false
		end
		ReplicatedStorage.Remotes.RerollStats:FireServer(UnitId, StatToReroll)
		PerfectStatCubeCount = PerfectStatCubeCount + 1
		return true
	else
		return false
	end
end

local function PrintResults()
	print(string.rep("=", 40))
	print("Unit:" .. UnitName)
	print(string.rep("=", 40))
	for _, Stat in ipairs(Stats) do
		local Grade = CurrentGrades()[Stat.Name]
		print(Stat.Name .. ": " .. Grade)
	end
	print(string.rep("=", 40))
	print("Meets Requirements:", MeetsMinGradeCount())
	print(string.rep("=", 40))
end

local function AllStatsHaveWantedGrades()
	for _, result in pairs(HasWantedGrade()) do
		if not result then
			return false
		end
	end
	return true
end

local function Main()
	while StatRerollGui.Enabled do
		if AllStatsHaveWantedGrades() then
			break
		end

		if MeetsMinGradeCount() then
			if not RollStats("Perfect") then
				break
			end
		else
			if not RollStats("Normal") then
				break
			end
		end

		task.wait(0.5)
	end

	PrintResults()
end

Main()
