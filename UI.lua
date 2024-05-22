local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local ALS = Material.Load({
    Title = "ALS Auto Roll",
    Style = 1,
    SizeX = 400,
    SizeY = 350,
    Theme = "Dark",
})

local RerollTab = ALS.New({
    Title = "Reroll",
})

local RollToggle = RerollTab.Toggle({
    Text = "Roll",
    Callback = function(Value)
        if Value then
            StartAutoReroll = true
        else
            StartAutoReroll = false
        end
    end,
    Enabled = false,
})

local SelectedTraitsLabel = RerollTab.TextField({
    Text = "None",
})

WantedTechniques = {}

local Options = {
    "Glitched",
    "Avatar",
    "Overlord",
    "Shinigami",
    "AllSeeing",
    "Entrepreneur",
    "Vulture",
    "Diamond",
    "Cosmic",
    "DemiGod",
    "EdgeEyes",
    "Golden",
    "HyperSpeed",
    "Juggernaut",
    "ElementalMaster",
    "Scoped",
    "Sturdy",
    "Accelerate",
    "Shining",
}

local SelectTrait = RerollTab.Dropdown({
    Text = "Select Trait",
    Callback = function(Value)
        if WantedTechniques[Value] then
            WantedTechniques[Value] = nil
        else
            WantedTechniques[Value] = true
        end

        local selectedtraits = {}
        for _, trait in ipairs(Options) do
            if WantedTechniques[trait] then
                table.insert(selectedtraits, trait)
            end
        end
        SelectedTraitsLabel:SetText(table.concat(selectedtraits, ", "))
    end,
    Options = Options,
})

local ClearButton = RerollTab.Button({
    Text = "Clear",
    Callback = function()
        WantedTechniques = {}
        SelectedTraitsLabel:SetText("None")
    end,
})

local Codes = RerollTab.Button({
    Text = "Redeem Codes",
    Callback = function()
        pcall(function()
            local codes = loadstring(game:HttpGet("https://raw.githubusercontent.com/buang5516/buanghub/main/codes.lua"))();
            if codes then
                for i,v in pairs(codes) do
                    pcall(function()
                        game.ReplicatedStorage.Remotes.ClaimCode:InvokeServer(v)
                    end)
                end
            end
        end)
    end,
})