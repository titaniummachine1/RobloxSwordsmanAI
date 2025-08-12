-- Imports
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

-- Module declaration
local SwordAI = {}

-- Local constants / utilities --------
local AGGRO_RANGE = 100       -- studs
local ATTACK_RANGE = 6        -- studs
local PATH_RECOMPUTE_S = 1.0  -- seconds
local ATTACK_COOLDOWN_S = 1.5 -- seconds

local function getHumanoid(model)
    if not model then
        return nil
    end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:IsA("Humanoid") then
        return humanoid
    end
    return nil
end

local function getRootPart(model)
    if not model then
        return nil
    end
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:IsA("BasePart") then
        return rootPart
    end
    return nil
end

local function isPlayerAlive(player)
    if not player.Character then
        return false
    end
    local humanoid = getHumanoid(player.Character)
    if not humanoid then
        return false
    end
    return humanoid.Health > 0
end

local function getNearestTarget(npcRoot)
    local nearestPlayer = nil
    local nearestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if isPlayerAlive(player) then
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (hrp.Position - npcRoot.Position).Magnitude
                if distance < nearestDist and distance <= AGGRO_RANGE then
                    nearestDist = distance
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

-- Private helpers --------------------
local function followPathToTarget(npc, targetPos)
    local humanoid = getHumanoid(npc)
    local root = getRootPart(npc)
    if not humanoid or not root then
        return
    end

    local path = PathfindingService:CreatePath()
    path:ComputeAsync(root.Position, targetPos)
    local waypoints = path:GetWaypoints()
    for _, wp in ipairs(waypoints) do
        humanoid:MoveTo(wp.Position)
        humanoid.MoveToFinished:Wait()
    end
end

local function tryAttackTarget(npc, targetHumanoid)
    local humanoid = getHumanoid(npc)
    local root = getRootPart(npc)
    if not humanoid or not root then
        return
    end

    local lastAttack = npc:GetAttribute("LastAttackT")
    if lastAttack == nil then
        lastAttack = 0
    end

    if os.clock() - (lastAttack) < ATTACK_COOLDOWN_S then
        return
    end

    local targetRoot = targetHumanoid.Parent and targetHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not targetRoot:IsA("BasePart") then
        return
    end

    local distance = (targetRoot.Position - root.Position).Magnitude
    if distance <= ATTACK_RANGE then
        targetHumanoid:TakeDamage(10)
        npc:SetAttribute("LastAttackT", os.clock())
    end
end

-- Public API -------------------------
function SwordAI.initialize(npc)
    if not npc then
        return
    end

    npc.Name = npc.Name ~= "" and npc.Name or "SwordNPC"
    if npc:GetAttribute("LastAttackT") == nil then
        npc:SetAttribute("LastAttackT", 0)
    end

    task.spawn(function()
        while npc.Parent do
            local root = getRootPart(npc)
            local humanoid = getHumanoid(npc)
            if not root or not humanoid or humanoid.Health <= 0 then
                break
            end

            local targetPlayer = getNearestTarget(root)
            if targetPlayer and targetPlayer.Character then
                local targetHumanoid = getHumanoid(targetPlayer.Character)
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHumanoid and targetRoot then
                    local distance = (targetRoot.Position - root.Position).Magnitude
                    if distance > ATTACK_RANGE then
                        followPathToTarget(npc, targetRoot.Position)
                    else
                        tryAttackTarget(npc, targetHumanoid)
                        task.wait(0.1)
                    end
                end
            else
                task.wait(0.25)
            end

            task.wait(PATH_RECOMPUTE_S)
        end
    end)
end

return SwordAI
