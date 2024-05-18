--[[ rbxassetid://14857396451 -  Scoped 
     rbxassetid://14857425345 - Sturdy 
     rbxassetid://14857421206 - Accelerate 
     rbxassetid://14857422439 - Shining
      rbxassetid://14857410430 - Edge Eyes
      rbxassetid://14857415303 - Golden
      rbxassetid://14857413772 - Hyper speed
      rbxassetid://14857418354 - Juggernaut
      rbxassetid://14857412247 - Elemental master

    
      rbxassetid://15110769879 - Vulture
      rbxassetid://14857403680 - Diamond  
      rbxassetid://14857423915 - Cosmic
      rbxassetid://14857390891 - Demi God
      rbxassetid://14857407287 - All Seeing
      rbxassetid://14857394535 - Entrepreneur 
      rbxassetid://14857405207 - Shinigami
      rbxassetid://14857401537 - Overlord
      rbxassetid://14857393213 - Avatar
      rbxassetid://14857416817 - Glitched




      -- replace the rbxassetid to what Technique you want.  
      For Example: getgenv().WantedTechique = "rbxassetid://14857401537" 
       and the script will auto roll until get the selected technique u want.
]]


local WantedTechniques = {
    "rbxassetid://14857416817", -- Glitched
    "rbxassetid://14857393213", -- Avatar
    "rbxassetid://14857401537", -- Overlord
    "rbxassetid://14857405207", -- Shinigami
    "rbxassetid://14857407287", -- All Seeing
    "rbxassetid://14857394535", -- Entrepreneur
}

getgenv().StartAutoReroll = true

while task.wait(0.5) do
    if StartAutoReroll == true then
        local Player = game.Players.LocalPlayer
        local vim = game:GetService("VirtualInputManager")

        local CurrentTechnique = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Technique.Icon.Image

        for i, v in pairs(WantedTechniques) do
            if v == CurrentTechnique then
                for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.BG.Select.ViewportFrame.WorldModel:GetChildren()) do
                    if v:IsA("Model") then
                        game:GetService("StarterGui"):SetCore("SendNotification",{
                            Title = "Auto Reroll ALS",
                            Text = v.Name.. " Already Got Wanted Technique",
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

                local partCenterX = part.AbsolutePosition.X + (part.AbsoluteSize.X / 2)
                local partCenterY = part.AbsolutePosition.Y + (part.AbsoluteSize.Y /0.7)

                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, true, game, 0)
                vim:SendMouseButtonEvent(partCenterX, partCenterY, 0, false, game, 0)

            elseif game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Confirm.Visible == true then
                local part = game:GetService("Players").LocalPlayer.PlayerGui.QuirksUI.Confirm.Confirm.Accept

                local partCenterX = part.AbsolutePosition.X + (part.AbsoluteSize.X / 2)
                local partCenterY = part.AbsolutePosition.Y + (part.AbsoluteSize.Y /0.7)

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