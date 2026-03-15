local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local window = windUI:CreateWindow({
    Title = "booyah",
    Icon = "door-open", -- lucide icon
    Author = "by raiSe",
    Folder = "booyah",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    KeySystem = { 
        Key = { "booyah" },
        Note = "i'm dirty now...",
        URL = "https://discord.gg/Ur8jxDMhCx",
        SaveKey = true
    },
})


local cheat = {
    ["autoKill"] = function(state) end,
    ["enableTeleporter"] = function() end,
    ["spoofKills"] = function(state) end,
    ["enableAutoRaid"] = function() end,
    ["enableAutoRoll"] = function() end
}

local mainTab = window:Tab({
    Title = "main",
    Icon = "lucide:cpu"
})

local miscTab = window:Tab({
    Title = "misc",
    Icon = "lucide:parantheses"
})

local gamepassSection = miscTab:Section({ 
    Title = "gamepass",
    Box = false,
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
    Opened = true
})

local autoKill = mainTab:Toggle({
    Title = "auto kill",
    Desc = "hits every mob on a period of 0.1 seconds",
    Type = "Checkbox",
    Callback = function(state) cheat["autoKill"](state) end
})

local spoofKillCount = 6767676767676767
local gamepassSpoofKillCount = gamepassSection:Input({
    Title = "kills",
    Desc = "kill count to spoof to",
    Value = "6767676767676767",
    Callback = function(input)
        spoofKillCount = tonumber(input)
    end
})

local spoofAscendCount = 676767676767
local gamepassSpoofAscendCount = gamepassSection:Input({
    Title = "ascensions",
    Desc = "ascend count to spoof to",
    Value = "676767676767",
    Callback = function(input)
        spoofAscendCount = tonumber(input)
    end
})

local gamepassSpoofKills = gamepassSection:Toggle({
    Title = "spoof stats for teleport",
    Desc = "spoof to unlock all regions",
    Type = "Checkbox",
    Callback = function(state) cheat["spoofKills"](state) end
})

local gamepassTeleporter = gamepassSection:Button({
    Title = "enable teleporter",
    Desc = "unlocks the teleporter gamepass",
    Callback = function() cheat["enableTeleporter"]() end
})

local gamepassTeleporter = gamepassSection:Button({
    Title = "enable auto raid",
    Desc = "unlocks the auto raid gamepass",
    Callback = function() cheat["enableAutoRaid"]() end
})

local gamepassTeleporter = gamepassSection:Button({
    Title = "enable auto roll",
    Desc = "unlocks the auto roll gamepass",
    Callback = function() cheat["enableAutoRoll"]() end
})

mainTab:Select()

local stopScript = false
function autoKillFunc()
    local weapon = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Weapons"):WaitForChild("Hellscape Greatsword")
    local dmgMult = 1 + game:GetService("ReplicatedStorage").Remotes.GetUpgradeValue:InvokeServer("Damage Multiplier") / 100
    print(dmgMult, weapon:GetAttribute("Damage"), dmgMult * weapon:GetAttribute("Damage") * 4)

    task.spawn(function()
        while not stopScript do
            for i, v in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GetEquippedWeapons"):InvokeServer(game:GetService("Players").LocalPlayer)) do
    	        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnequipOneWeapon"):InvokeServer(v)
            end
            wait(5)
        end
    end)

    local args = {}
    local mobsLocation = nil
    local enemyTable = {}
    local currEnemies = {}

    local spawnMobConnection
    spawnMobConnection = game:GetService("ReplicatedStorage").Remotes.SpawnMob.OnClientEvent:Connect(function(mob)
        enemyTable[mob.ID] = mob.Health
        currEnemies[mob.ID] = true
    end)

    wait(2)

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
        for i, v in pairs(mobsLocation:GetChildren()) do
            if v then
                if v.ClassName == "Model" and v:FindFirstChild("HumanoidRootPart") then
                    local mobID = v:GetAttribute("ID")
                    table.insert(args, { mobID, damage, weapon})
                    currEnemies[mobID] = true
                    local enemy = enemyTable[mobID]
                    if enemy then
                        enemyTable[mobID] = enemy - damage
                    else
                        enemyTable[mobID] = 10000000 - damage
                    end
                    if enemy and enemy <= 0 then
                        --print("Mob with ID " .. mobID .. " has been killed.")
                        v:Destroy()
                        enemyTable[mobID] = nil
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
        print("running")
        currEnemies = {}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HitMob"):FireServer(args)
        args = {}
        wait(0.1)
    end
    spawnMobConnection:Disconnect()
end
local autoKillThread = nil
cheat["autoKill"] = function(state)
    if autoKillThread == nil and state then
        autoKillThread = task.spawn(autoKillFunc)
    elseif autoKillThread and state then
        if coroutine.status(autoKillThread) == "dead" then
            autoKillThread = task.spawn(autoKillFunc)
        end
    end
    stopScript = not state
end


local origKills = 0
local origAscends = 0
local killsConn, ascendConn
cheat["spoofKills"] = function(state)
    local leaderstats = game.Players.LocalPlayer:WaitForChild("leaderstats")
    local kills = leaderstats:WaitForChild("\240\159\142\175 Kills")
    local ascensions = leaderstats:WaitForChild("\240\159\140\159 Ascends")
    if state then
        origKills = kills.Value
        origAscends = ascensions.Value
        kills.Value = spoofKillCount
        ascensions.Value = spoofAscendCount
        killsConn = kills.Changed:Connect(function(newVal)
            if newVal ~= spoofKillCount then
                origKills = newVal
                kills.Value = spoofKillCount
            end
        end)
        ascendConn = ascensions.Changed:Connect(function(newVal)
            if newVal ~= spoofAscendCount then
                origAscends = newVal
                ascensions.Value = spoofAscendCount
            end
        end)
    else
        kills.Value = origKills
        ascensions.Value = origAscends
        killsConn:Disconnect()
        ascendConn:Disconnect()
    end
end

cheat["enableTeleporter"] = function()
    for i, v in pairs(getconnections(game.ReplicatedStorage.Remotes:WaitForChild("UnlockTeleporter").OnClientEvent)) do
        v.Function()
    end
end

cheat["enableAutoRaid"] = function()
    for i, v in pairs(getconnections(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EnableAutoRaid").OnClientEvent)) do
        v.Function()
    end
end

local hook
cheat["enableAutoRoll"] = function()
    hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self.Name == "AutoRollUnlocked" and method == "InvokeServer" then
            --print("AutoRollUnlocked called via __namecall")
            return true
        end
        return hook(self, ...)
    end))
end
