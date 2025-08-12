-- Classic Sword (clean, no Luau type annotations for compatibility)

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local BaseUrl = "rbxassetid://"

local DamageValues = { BaseDamage = 5, SlashDamage = 10, LungeDamage = 30 }
local AnimIds = { R15Slash = 522635514, R15Lunge = 522638767 }

local Grips = {
    Up = CFrame.new(0, 0, -1.7, 0, 0, 1, 1, 0, 0, 0, 1, 0),
    Out = CFrame.new(0, 0, -1.7, 0, 1, 0, 1, 0, 0, 0, 0, -1),
}

local Sounds = {
    Slash = Handle:WaitForChild("SwordSlash"),
    Lunge = Handle:WaitForChild("SwordLunge"),
    Unsheath = Handle:WaitForChild("Unsheath"),
}

for _, v in ipairs(Handle:GetChildren()) do
    if v:IsA("ParticleEmitter") then
        v.Rate = 20
    end
end

-- Damage gating
local ATTACK_WINDOW = 0.35
local LUNGE_WINDOW = 0.55
local HIT_COOLDOWN = 0.6
local attackActive = false
local lastHitT = {}
local touching = {}

-- State
local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil
local ToolEquipped = false
local Damage = DamageValues.BaseDamage
local LastAttackT = 0

local Mouse = nil
local MouseIcon = "rbxasset://textures/GunCursor.png"
local ReloadIcon = "rbxasset://textures/GunWaitCursor.png"

local function isTeamMate(a, b)
    if not a or not b then return false end
    if a.Neutral or b.Neutral then return false end
    return a.TeamColor == b.TeamColor
end

local function tagHumanoid(h, p)
    local tag = Instance.new("ObjectValue")
    tag.Name = "creator"
    tag.Value = p
    tag.Parent = h
    Debris:AddItem(tag, 2)
end

local function untagHumanoid(h)
    for _, v in ipairs(h:GetChildren()) do
        if v:IsA("ObjectValue") and v.Name == "creator" then
            v:Destroy()
        end
    end
end

local function checkAlive()
    return Player and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and
        Torso.Parent
end

local function ensureAnimations()
    if not Tool:FindFirstChild("R15Slash") then
        local a = Instance.new("Animation")
        a.Name = "R15Slash"
        a.AnimationId = BaseUrl .. AnimIds.R15Slash
        a.Parent = Tool
    end
    if not Tool:FindFirstChild("R15Lunge") then
        local a = Instance.new("Animation")
        a.Name = "R15Lunge"
        a.AnimationId = BaseUrl .. AnimIds.R15Lunge
        a.Parent = Tool
    end
end

local function loadAndPlay(animName)
    if not Humanoid then return end
    if Humanoid.RigType == Enum.HumanoidRigType.R6 then
        local sv = Instance.new("StringValue")
        sv.Name = "toolanim"
        sv.Value = (animName == "Slash") and "Slash" or "Lunge"
        sv.Parent = Tool
        return
    end
    local animator = Humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = Humanoid
    end
    local anim = Tool:FindFirstChild(animName)
    if anim then
        local track = animator:LoadAnimation(anim)
        track:Play(0)
    end
end

local function Blow(hit)
    if not attackActive or not hit or not hit.Parent or not checkAlive() or not ToolEquipped then
        return
    end

    local rightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
    if not rightArm then return end
    local rightGrip = rightArm:FindFirstChild("RightGrip")
    if not rightGrip or (rightGrip.Part0 ~= Handle and rightGrip.Part1 ~= Handle) then return end

    local victim = hit.Parent
    if victim == Character then return end

    local hum = victim:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local p = Players:GetPlayerFromCharacter(victim)
    if p and (p == Player or isTeamMate(Player, p)) then return end

    if touching[hum] then return end
    local now = os.clock()
    if lastHitT[hum] and (now - lastHitT[hum]) < HIT_COOLDOWN then return end

    untagHumanoid(hum)
    if Player then tagHumanoid(hum, Player) end
    hum:TakeDamage(Damage)

    lastHitT[hum] = now
    touching[hum] = true
end

Handle.TouchEnded:Connect(function(part)
    if not part or not part.Parent then return end
    local hum = part.Parent:FindFirstChildOfClass("Humanoid")
    if hum then touching[hum] = nil end
end)

local function Attack()
    Damage = DamageValues.SlashDamage
    Sounds.Slash:Play()
    loadAndPlay("R15Slash")
    attackActive = true
    task.delay(ATTACK_WINDOW, function()
        attackActive = false
    end)
end

local function Lunge()
    Damage = DamageValues.LungeDamage
    Sounds.Lunge:Play()
    loadAndPlay("R15Lunge")
    attackActive = true
    task.delay(LUNGE_WINDOW, function()
        attackActive = false
    end)
    task.wait(0.2)
    Tool.Grip = Grips.Out
    task.wait(0.6)
    Tool.Grip = Grips.Up
    Damage = DamageValues.SlashDamage
end

local function Activated()
    if not Tool.Enabled or not ToolEquipped or not checkAlive() then return end
    Tool.Enabled = false
    local now = os.clock()
    if (now - LastAttackT) < 0.2 then
        Lunge()
    else
        Attack()
    end
    LastAttackT = now
    Damage = DamageValues.BaseDamage
    Tool.Enabled = true
end

local function updateIcon()
    if Mouse then
        Mouse.Icon = Tool.Enabled and MouseIcon or ReloadIcon
    end
end

local function Equipped(toolMouse)
    Character = Tool.Parent
    Player = Players:GetPlayerFromCharacter(Character)
    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    Torso = Character and (Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart"))
    if not checkAlive() then return end
    ToolEquipped = true
    Sounds.Unsheath:Play()
    Mouse = toolMouse
    updateIcon()
end

local function Unequipped()
    Tool.Grip = Grips.Up
    ToolEquipped = false
    Mouse = nil
end

local function Changed(prop)
    if prop == "Enabled" then
        updateIcon()
    end
end

-- Init
Tool.Grip = Grips.Up
Tool.Enabled = true
ensureAnimations()

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Changed:Connect(Changed)
Handle.Touched:Connect(Blow)
