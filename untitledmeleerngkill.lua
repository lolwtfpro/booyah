local stopScriptKeybind = "F6"

local weapon = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Weapons"):WaitForChild("Hellscape Greatsword")
local dmgMult = 1 + game:GetService("ReplicatedStorage").Remotes.GetUpgradeValue:InvokeServer("Damage Multiplier") / 100
print(dmgMult, weapon:GetAttribute("Damage"), dmgMult * weapon:GetAttribute("Damage") * 4)

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

for i, v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetEquippedWeapons"):InvokeServer(game:GetService("Players").LocalPlayer)) do
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnequipOneWeapon"):InvokeServer(v)
end

wait(2)

local args = {}
local mobsLocation = nil
local enemyTable = {}
local currEnemies = {}

task.spawn(function()
    while not stopScript do
        for i, v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetEquippedWeapons"):InvokeServer(game:GetService("Players").LocalPlayer)) do
	        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnequipOneWeapon"):InvokeServer(v)
        end
        wait(5)
    end
end)

while not stopScript do
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
                    local mobID = v:GetAttribute("ID")
                    table.insert(args, { mobID, damage, weapon})
                    currEnemies[mobID] = true
                    if enemyTable[mobID] then
                        enemyTable[mobID] = enemyTable[mobID] - damage
                    else
                        enemyTable[mobID] = v:GetAttribute("Health") - damage
                    end

                    if enemyTable[mobID] and enemyTable[mobID] <= 0 then
                        --print("Mob with ID " .. mobID .. " has been killed.")
                        enemyTable[mobID] = nil
                    end
                end
            end
        end
    end

    for i, v in pairs(enemyTable) do
        if not currEnemies[i] then
            --print("Mob with ID " .. i .. " is no longer in the mob list, removing from enemyTable.")
            enemyTable[i] = nil
        end
    end
    currEnemies = {}
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HitMob"):FireServer(args)
    args = {}
    wait(0.1)
    print("running")
end
print("Script stopped.")
UISConnection:Disconnect()
