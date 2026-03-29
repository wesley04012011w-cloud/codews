--[[
    BITCODE FRAMEWORK V11.0 - SAILOR PIECE (GEOGRAPHIC INTELLIGENCE)
    INTERFACE: WESLEY-CLOUD LIBRARY
    SISTEMA: AUTO-ISLAND DETECTION + RENDER BUFFER
]]

local Bitcode = loadstring(game:HttpGet("https://raw.githubusercontent.com/wesley04012011w-cloud/Library/refs/heads/main/library.lua"))()
local Window = Bitcode:Init()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Remotes
local CombatRemote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")
local TeleportRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal")
local PurchaseRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")

-- Configurações Globais
_G.AutoFarm = false
_G.SelectedNPC = "CoinFruitDealer"
_G.SelectedTarget = "Thiefs"
_G.IsTweening = false
_G.SelectedShopItem = "Trait Reroll"
_G.PurchaseAmount = 1
local FarmDistance = 10

-- [ BANCO DE DADOS GEOGRÁFICO ]
local NPC_Locations = {
    ["CoinFruitDealer"] = "Sailor",
    ["GemFruitDealer"] = "Sailor",
    ["ObservationBuyer"] = "Desert",
    ["DarkBladeNPC"] = "Snow",
    ["HakiQuestNPC"] = "Snow",
    ["GryphonBuyerNPC"] = "Shibuya",
    ["SummonBossNPC"] = "Boss",
    ["DungeonMerchantNPC"] = "Dungeon",
    ["GojoCraftNPC"] = "Shinjuku",
    ["RimuruSummonerNPC"] = "Shinjuku",
    ["SlimeCraftNPC"] = "Slime",
    ["SkillTreeNPC"] = "Slime"
}

-- [ SISTEMA DE MOVIMENTAÇÃO TWEEN ]
local function SmoothTween(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 170 
        local duration = distance / speed
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
        
        _G.IsTweening = true
        _G.AutoFarm = false 
        char.Humanoid.PlatformStand = true 
        
        tween:Play()
        tween.Completed:Connect(function()
            _G.IsTweening = false
            char.Humanoid.PlatformStand = false
        end)
    end
end

-- [ CRIAÇÃO DAS ABAS ]
local FarmTab = Window:CreateTab("Auto Farm")
local NPCTab = Window:CreateTab("NPCs")
local ShopTab = Window:CreateTab("Shop")
local TeleportTab = Window:CreateTab("Teleportes")

-- [ ABA NPCs - INTELIGÊNCIA GEOGRÁFICA ]
NPCTab:CreateDropdown("Selecionar NPC", {
    "CoinFruitDealer", "GemFruitDealer", "ObservationBuyer", "DarkBladeNPC", 
    "HakiQuestNPC", "GryphonBuyerNPC", "SummonBossNPC", "DungeonMerchantNPC", 
    "GojoCraftNPC", "RimuruSummonerNPC", "SlimeCraftNPC", "SkillTreeNPC"
}, function(selected)
    _G.SelectedNPC = selected
end)

NPCTab:CreateButton("Teleport to NPC", function()
    local targetIsland = NPC_Locations[_G.SelectedNPC]
    if targetIsland then
        print("bitcode: Alvo em " .. targetIsland .. ". Iniciando sequência...")
        _G.AutoFarm = false
        
        -- 1. Teleporte de Instância para carregar a ilha correta
        TeleportRemote:FireServer(targetIsland)
        
        -- 2. Buffer para carregar o mapa (Streaming)
        task.wait(2.5) 
        
        -- 3. Tween até o NPC na ilha renderizada
        local folder = workspace:FindFirstChild("ServiceNPCs")
        if folder then
            local target = folder:FindFirstChild(_G.SelectedNPC)
            if target and target:FindFirstChild("HumanoidRootPart") then
                SmoothTween(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
            else
                print("bitcode: Falha na renderização do NPC. Tente novamente.")
            end
        end
    end
end)

-- [ ABA SHOP ]
ShopTab:CreateDropdown("Selecionar Item", {"Trait Reroll", "Boss Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Passive Shard", "Dungeon Key", "Clan Reroll"}, function(s) _G.SelectedShopItem = s end)
ShopTab:CreateSlider("Quantidade", 1, 100, 1, function(v) _G.PurchaseAmount = v end)
ShopTab:CreateButton("Confirmar Compra", function() PurchaseRemote:InvokeServer(_G.SelectedShopItem, _G.PurchaseAmount) end)

-- [ ABA AUTO FARM ]
FarmTab:CreateDropdown("Selecionar Grupo", {"Thiefs", "ThiefBoss", "Monkeys", "MonkeyBoss", "Desert Bandits", "Desert Boss", "Frost Rogues", "SnowBoss", "Sorcerer", "PandaMiniBoss", "Hollow", "StrongSorcerer", "Curse", "Slime", "AcademyTeacher", "Swordsman", "ArenaFighter"}, function(s) _G.SelectedTarget = s end)
FarmTab:CreateToggle("Ativar Farm Aggro (1-5)", function(state) _G.AutoFarm = state end)
FarmTab:CreateToggle("Usar Habilidades", function(state) _G.AutoAbility = state end)

-- [ ABA TELEPORTES - ATUALIZADA ]
local Locations = {
    ["Início (Starter)"] = "Starter", ["Selva (Jungle)"] = "Jungle", ["Deserto (Desert)"] = "Desert",
    ["Neve (Snow)"] = "Snow", ["Marinheiro (Sailor)"] = "Sailor", ["Shibuya"] = "Shibuya",
    ["Ilha Hollow"] = "HollowIsland", ["Chefão (Boss)"] = "Boss", ["Dungeon"] = "Dungeon",
    ["Shinjuku"] = "Shinjuku", ["Academia (Academy)"] = "Academy", ["Julgamento (Judgement)"] = "Judgement",
    ["Ninja"] = "Ninja", ["Sem Lei (Lawless)"] = "Lawless", ["Torre (Tower)"] = "Tower",
    ["Slime (New)"] = "Slime" -- Novo Teleporte Adicionado
}

TeleportTab:CreateDropdown("Selecionar Destino", {
    "Início (Starter)", "Selva (Jungle)", "Deserto (Desert)", "Neve (Snow)", 
    "Marinheiro (Sailor)", "Shibuya", "Ilha Hollow", "Chefão (Boss)", 
    "Dungeon", "Shinjuku", "Academia (Academy)", "Julgamento (Judgement)", 
    "Ninja", "Sem Lei (Lawless)", "Torre (Tower)", "Slime (New)"
}, function(s) 
    _G.AutoFarm = false 
    TeleportRemote:FireServer(Locations[s]) 
end)

-- [ LÓGICA DE BACKEND ]
task.spawn(function()
    local NPCTable = { ["Thiefs"] = {"Thief1", "Thief2", "Thief3", "Thief4", "Thief5"}, ["ThiefBoss"] = {"ThiefBoss"}, ["Monkeys"] = {"Monkey1", "Monkey2", "Monkey3", "Monkey4", "Monkey5"}, ["MonkeyBoss"] = {"MonkeyBoss"}, ["Desert Bandits"] = {"DesertBandit1", "DesertBandit2", "DesertBandit3", "DesertBandit4", "DesertBandit5"}, ["Desert Boss"] = {"DesertBoss"}, ["Frost Rogues"] = {"FrostRogue1", "FrostRogue2", "FrostRogue3", "FrostRogue4", "FrostRogue5"}, ["SnowBoss"] = {"SnowBoss"}, ["Sorcerer"] = {"Sorcerer1", "Sorcerer2", "Sorcerer3", "Sorcerer4", "Sorcerer5"}, ["PandaMiniBoss"] = {"PandaMiniBoss"}, ["Hollow"] = {"Hollow1", "Hollow2", "Hollow3", "Hollow4", "Hollow5"}, ["StrongSorcerer"] = {"StrongSorcerer1", "StrongSorcerer2", "StrongSorcerer3", "StrongSorcerer4", "StrongSorcerer5"}, ["Curse"] = {"Curse1", "Curse2", "Curse3", "Curse4", "Curse5"}, ["Slime"] = {"Slime1", "Slime2", "Slime3", "Slime4", "Slime5"}, ["AcademyTeacher"] = {"AcademyTeacher1", "AcademyTeacher2", "AcademyTeacher3", "AcademyTeacher4", "AcademyTeacher5"}, ["Swordsman"] = {"Swordsman1", "Swordsman2", "Swordsman3", "Swordsman4", "Swordsman5"}, ["ArenaFighter"] = {"ArenaFighter1", "ArenaFighter2", "ArenaFighter3", "ArenaFighter4", "ArenaFighter5"} }
    while true do
        if _G.AutoFarm and not _G.IsTweening then
            local folder = workspace:FindFirstChild("NPCs")
            local currentList = NPCTable[_G.SelectedTarget]
            local char = LocalPlayer.Character
            if folder and currentList and char and char:FindFirstChild("HumanoidRootPart") then
                for i = 1, #currentList do
                    if not _G.AutoFarm or _G.IsTweening then break end
                    local target = folder:FindFirstChild(currentList[i])
                    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and target:FindFirstChild("HumanoidRootPart") then
                        char.Humanoid.PlatformStand = true
                        char.HumanoidRootPart.CFrame = CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, FarmDistance, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
                        CombatRemote:FireServer()
                        if _G.AutoAbility then AbilityRemote:FireServer(1) AbilityRemote:FireServer(2) end
                        task.wait(0.15) 
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

RunService.Stepped:Connect(function()
    if (_G.AutoFarm or _G.IsTweening) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

print("bitcode: Sailor Piece V11.0 Finalizado e Otimizado.")