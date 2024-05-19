repeat task.wait() until game:IsLoaded()

wait(2)

local Glitched = "rbxassetid://14857416817"
local Avatar = "rbxassetid://14857393213"
local Overlord = "rbxassetid://14857401537"
local Shinigami = "rbxassetid://14857405207"
local All_Seeing = "rbxassetid://14857407287"
local Entrepreneur = "rbxassetid://14857394535"
local Vulture = "rbxassetid://15110769879"
local Diamond = "rbxassetid://14857403680"
local Cosmic = "rbxassetid://14857423915"
local Demi_God = "rbxassetid://14857390891"
local Edge_Eyes = "rbxassetid://14857410430"
local Golden = "rbxassetid://14857415303"
local Hyper_speed = "rbxassetid://14857413772"
local Juggernaut = "rbxassetid://14857418354"
local Elemental_master = "rbxassetid://14857412247"
local Scoped = "rbxassetid://14857396451"
local Sturdy = "rbxassetid://14857425345"
local Accelerate = "rbxassetid://14857421206"
local Shining = "rbxassetid://14857422439"

local WantedTechniques = {
    Glitched,
    Avatar,
    Overlord,
    Shinigami,
    All_Seeing,
    Entrepreneur,
}

StartAutoReroll = true

while task.wait(0.5) do
    if game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Enabled == false then
        StartAutoReroll = false
        break
    end

    if game:GetService("Players").LocalPlayer.Rerolls.Value == 0 then
        StartAutoReroll = false
        break
    end

    if StartAutoReroll == true then
        local Player = game.Players.LocalPlayer
        local vim = game:GetService("VirtualInputManager")

        local CurrentTechnique = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Technique.Icon.Image
        local GotTechnique = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Technique.Title.Text

        for i, v in pairs(WantedTechniques) do
            if v == CurrentTechnique then
                for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Select.ViewportFrame.WorldModel:GetChildren()) do
                    if v:IsA("Model") then
                        game:GetService("StarterGui"):SetCore("SendNotification",{
                            Title = "Reroll Finished",
                            Text = v.Name.. " Rolled " .. GotTechnique .. "!",
                        })
                    end
                end
                StartAutoReroll = false
                break
            end
        end

        if StartAutoReroll == true then
            if game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Confirm.Visible == false then
                local part = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Reroll

                local partCenterX = part.AbsolutePosition.X + (part.AbsoluteSize.X / 1.50)
                local partCenterY = part.AbsolutePosition.Y + (part.AbsoluteSize.Y /0.68)

                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, true, game, 0)
                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, false, game, 0)

            elseif game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Confirm.Visible == true then
                local part = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Confirm.Confirm.Accept

                local partCenterX = part.AbsolutePosition.X + (part.AbsoluteSize.X / 1.50)
                local partCenterY = part.AbsolutePosition.Y + (part.AbsoluteSize.Y /0.68)

                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, true, game, 0)
                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, false, game, 0)
            end
        else
            wait()
            break
        end
    else
        wait()
        break
    end
end