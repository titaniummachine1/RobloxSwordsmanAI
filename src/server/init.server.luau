-- Imports
local ServerStorage = game:GetService("ServerStorage")
local SwordAI = require(script.Parent.ai.sword_ai)

-- Public API -------------------------
print("Server starting Sword AI demo")

local function createDummyNPC()
    local model = Instance.new("Model")
    model.Name = "SwordNPC"

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

local npc = createDummyNPC()
SwordAI.initialize(npc)
