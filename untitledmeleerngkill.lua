local args = {}
local weapon = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Weapons"):WaitForChild("Hellscape Greatsword")
local dmgMult = 1 + game:GetService("ReplicatedStorage").Remotes.GetUpgradeValue:InvokeServer("Damage Multiplier") / 100
print(dmgMult, weapon:GetAttribute("Damage"), dmgMult * weapon:GetAttribute("Damage") * 4)

local stopScriptKeybind = "F6"


local stopScript = false
local UISConnection 
UISConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode[stopScriptKeybind] then
            stopScript = true
        end
    end
end)

print("Script loaded. Press " .. stopScriptKeybind .. " to stop the script.")

while not stopScript do
    local mobsLocation = nil
    if game.workspace:FindFirstChild("Mobs") then
        mobsLocation = game.Workspace.Mobs
    elseif game:GetService("ReplicatedStorage"):FindFirstChild("Mobs") then
        mobsLocation = game:GetService("ReplicatedStorage").Mobs
    else
        print("No mobs found in workspace or ReplicatedStorage.")
        wait(0.1)
        continue
    end

    local damage = dmgMult * weapon:GetAttribute("Damage") * 4
    for i, v in pairs(mobsLocation:GetChildren()) do -- game:GetService("ReplicatedStorage").Mobs:GetChildren() game.workspace.Mobs:GetChildren()
        if v then
            if v.ClassName == "Model" and v:FindFirstChild("HumanoidRootPart") then
                if v:GetAttribute("Health") ~= 0 then
                    table.insert(args, { v:GetAttribute("ID"), damage, weapon})
                    if v:GetAttribute("Health") - damage <= 0 then
                        v:Destroy()
                    else
                        v:SetAttribute("Health", v:GetAttribute("Health") - damage)
                    end
                end
            end
        end
    end
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HitMob"):FireServer(args)
    args = {}
    wait(0.1)
    print("running")
end

UISConnection:Disconnect()
