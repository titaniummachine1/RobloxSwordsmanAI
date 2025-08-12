-- Simple hugger NPC that constantly walks toward the nearest player
local Players = game:GetService("Players")

print("Server: starting simple hugger NPC")

local function createDummyNPC()
    local model = Instance.new("Model")
    model.Name = "HuggerNPC"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 1)
    root.Anchored = false
    root.CanCollide = true
    root.Position = Vector3.new(0, 5, 0)
    root.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Position = Vector3.new(0, 6.5, 0)
    head.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = head
    weld.Parent = model

    model.PrimaryPart = root
    model.Parent = workspace
    return model
end

local function getHumanoid(model)
    if not model then
        return nil
    end
    return model:FindFirstChildOfClass("Humanoid")
end

local function getNearestAlivePlayer(targetFrom)
    local nearestPlayer = nil
    local nearestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoid.Health > 0 and hrp then
            local dist = (hrp.Position - targetFrom).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

local npc = createDummyNPC()
local npcHumanoid = getHumanoid(npc)
local npcRoot = npc:FindFirstChild("HumanoidRootPart")

task.spawn(function()
    while npc.Parent and npcHumanoid and npcHumanoid.Health > 0 do
        if not npcRoot then
            break
        end

        local targetPlayer = getNearestAlivePlayer(npcRoot.Position)
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                npcHumanoid:MoveTo(targetRoot.Position)
            end
        end

        task.wait(0.2)
    end
end)
