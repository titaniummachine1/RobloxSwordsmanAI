-- Simple hugger NPC that constantly walks toward the nearest player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("Server: starting simple hugger NPC")

local function createR15NPC()
    -- Build a standard R15 character using a fresh HumanoidDescription
    local description = Instance.new("HumanoidDescription")
    local model = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
    model.Name = "HuggerNPC"

    -- Ensure a sensible spawn position
    local root = model:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        root.CFrame = CFrame.new(0, 5, 0)
    end

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

local npc = createR15NPC()
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
