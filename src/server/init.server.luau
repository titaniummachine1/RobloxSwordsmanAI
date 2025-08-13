-- Idle R6 NPC with classic colors
local Players = game:GetService("Players")

print("Server: spawn idle R6 NPC")

local function createR6NPC()
    -- Build a classic R6 character and apply colors via BodyColors for compatibility
    local desc = Instance.new("HumanoidDescription")
    local ok, model = pcall(function()
        return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
    end)
    if not ok or not model then
        return nil
    end
    model.Name = "NPC_R6"

    -- Ensure BodyColors exists and apply classic "noob" palette
    local bodyColors = model:FindFirstChildOfClass("BodyColors")
    if not bodyColors then
        bodyColors = Instance.new("BodyColors")
        bodyColors.Parent = model
    end
    bodyColors.HeadColor = BrickColor.new("Bright yellow")
    bodyColors.LeftArmColor = BrickColor.new("Bright yellow")
    bodyColors.RightArmColor = BrickColor.new("Bright yellow")
    bodyColors.TorsoColor = BrickColor.new("Bright blue")
    bodyColors.LeftLegColor = BrickColor.new("Bright green")
    bodyColors.RightLegColor = BrickColor.new("Bright green")

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

-- Not used while idle; kept for future AI
-- idle: no AI loop

local npc = createR6NPC()
local npcHumanoid = getHumanoid(npc)
local npcRoot = npc:FindFirstChild("HumanoidRootPart")
