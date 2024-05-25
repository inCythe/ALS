repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("GuiService")

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local SettingsLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Suricato006/Scripts-Made-by-me/master/Libraries/SaveSettingsLibrary.lua"))()

local FileName = "RerollConfig.JSON"
local SettingsTable = SettingsLibrary.LoadSettings(FileName)

local ALS = Material.Load({
    Title = "ALS Auto Roll [100% Luck Buff] ",
    Style = 1,
    SizeX = 400,
    SizeY = 350,
    Theme = "Dark",
    ColorOverrides = {
        MainFrame = Color3.fromRGB(30, 30, 30)
    }
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
    "Accelerate"
}

local TechniqueIds = {
    Glitched = "rbxassetid://14857416817",
    Avatar = "rbxassetid://14857393213",
    Overlord = "rbxassetid://14857401537",
    Shinigami = "rbxassetid://14857405207",
    ['All Seeing'] = "rbxassetid://14857407287",
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
    Accelerate = "rbxassetid://14857421206"
}

local WantedTechniques = SettingsTable.WantedTechniques or {}

local function saveSettings()
    SettingsTable.WantedTechniques = WantedTechniques
    SettingsLibrary.SaveSettings(FileName, SettingsTable)
end

local function Select(element)
    if element and element.Selectable then
        UIS.SelectedObject = element
    end
end

local function KeyPress(keyCode)
    VIM:SendKeyEvent(true, keyCode, false, game)
    VIM:SendKeyEvent(false, keyCode, false, game)
end

local function checkCurrentTechnique()
    local QuirksUI = Player.PlayerGui.QuirksUI
    local CurrentTechnique = QuirksUI.BG.Technique.Icon.Image

    for _, v in pairs(WantedTechniques) do
        if v == CurrentTechnique then
            return true
        end
    end
    return false
end

local AutoRoll = RerollTab.Toggle({
    Text = "Roll",
    Callback = function(Value)
        StartAutoReroll = Value
        coroutine.wrap(function()
            if not Player.PlayerGui.QuirksUI.Enabled or Player.Rerolls.Value == 0 then
                return
            end

            if checkCurrentTechnique() then
                return
            end

            while StartAutoReroll do
                task.wait(0.1)

                local QuirksUI = Player.PlayerGui.QuirksUI
                local RerollButton = QuirksUI.BG.Reroll
                local ConfirmButton = QuirksUI.Confirm.Confirm.Accept

                if not QuirksUI.Enabled or Player.Rerolls.Value == 0 then
                    KeyPress(Enum.KeyCode.BackSlash)
                    return
                end

                if not StartAutoReroll then
                    KeyPress(Enum.KeyCode.BackSlash)
                    break
                end

                local CurrentTechnique = QuirksUI.BG.Technique.Icon.Image
                local GotTechnique = QuirksUI.BG.Technique.Title.Text

                for _, v in pairs(WantedTechniques) do
                    if v == CurrentTechnique then
                        for _, model in pairs(QuirksUI.BG.Select.ViewportFrame.WorldModel:GetChildren()) do
                            if model:IsA("Model") then
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Reroll Finished",
                                    Text = model.Name .. " Rolled " .. GotTechnique .. "!",
                                })
                            end
                        end
                        KeyPress(Enum.KeyCode.BackSlash)
                        StartAutoReroll = false
                        return
                    end
                end

                if StartAutoReroll then
                    if not QuirksUI.Confirm.Visible then
                        Select(RerollButton)
                        KeyPress(Enum.KeyCode.Return)
                    elseif QuirksUI.Confirm.Visible then
                        Select(ConfirmButton)
                        KeyPress(Enum.KeyCode.Return)
                    else
                        task.wait()
                    end
                else
                    task.wait()
                end
            end
        end)()
    end,
    Enabled = StartAutoReroll,
})

local SelectedTraitsLabel = RerollTab.TextField({
    Text = "None",
})

local function updateSelectedTraitsLabel()
    local selectedtraits = {}
    for _, name in ipairs(Techniques) do
        if WantedTechniques[name] then
            table.insert(selectedtraits, name)
        end
    end
    SelectedTraitsLabel:SetText(table.concat(selectedtraits, ", "))
end

local SelectTrait = RerollTab.Dropdown({
    Text = "Select Trait",
    Callback = function(Value)
        if WantedTechniques[Value] then
            WantedTechniques[Value] = nil
        else
            WantedTechniques[Value] = TechniqueIds[Value]
        end
        updateSelectedTraitsLabel()
        saveSettings()
    end,
    Options = Techniques,
})

local ClearButton = RerollTab.Button({
    Text = "Clear",
    Callback = function()
        WantedTechniques = {}
        SelectedTraitsLabel:SetText("None")
        saveSettings()
    end,
})

local Codes = RerollTab.Button({
    Text = "Redeem Codes",
    Callback = function()
        pcall(function()
            local codes = loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/main/codes.lua"))()
            if codes then
                for _, v in pairs(codes) do
                    pcall(function()
                        game.ReplicatedStorage.Remotes.ClaimCode:InvokeServer(v)
                    end)
                end
            end
        end)
    end,
})

updateSelectedTraitsLabel()

print("Reroll Loaded!")