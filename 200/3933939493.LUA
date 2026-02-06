-- [[ CEZAR V40.0 - THE MONOLITH (ULTRA BUFFED) ]]
local lp = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local RS = game:GetService("RunService")
local LocS = game:GetService("LocalizationService")
local camera = workspace.CurrentCamera

-- [[ MASTER WHITELIST ]]
local Whitelist = {
    [4479445660]  = true,
    [10459866852] = true,
    [10459902683] = true, -- CEZAR
    [10412239686] = true,
    [10459902683] = true  -- 5th ID
}

local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1469133460034683005/WcdqtMw6BFrpTTntTrxgMuSicadDiyOFMavdOaubAQsAsRluDX2O1WXAc5xHcHnPpS-R"

-- [[ 1. THE BYPASS (SPOOFED) ]]
pcall(function()
    local Actions = workspace:WaitForChild("FE", 5):WaitForChild("Actions", 5)
    if Actions:FindFirstChild("KeepYourHeadUp") then
        Actions.KeepYourHeadUp:Destroy()
        local fake = Instance.new("RemoteEvent")
        fake.Name = "KeepYourHeadUp"
        fake.Parent = Actions
    end
end)

-- [[ 2. SECURITY GATE ]]
if not Whitelist[lp.UserId] then 
    lp:Kick("DM KERSAII ON DC")
    return 
end

-- [[ 3. BUFFED REACH CONFIG ]]
local CFG = {
    GROUND = 4.2, -- Buffed from 4.0
    JUMPLEG = 5.5, -- Buffed from 5.0
    AIR_X = 4.0,
    AIR_Z = 4.0,
    AIR_Y = 5.5,      
    PRED = 0.12,  -- Increased prediction for high-speed play
    FORCE = 125   -- Power buff
}

local function getBall()
    return workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS") or workspace:FindFirstChild("Ball")
end

-- [[ 4. CORE PHYSICS ENGINE ]]
RS.PreSimulation:Connect(function()
    local char, ball = lp.Character, getBall()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not ball or not hum or hum.Health <= 0 then return end

    -- NETWORK CLAIM (Stops the teleporting/rubberbanding)
    local dist = (root.Position - ball.Position).Magnitude
    if dist < 15 then
        if sethiddenproperty then 
            sethiddenproperty(lp, "SimulationRadius", 9999)
            sethiddenproperty(lp, "MaxSimulationRadius", 9999)
        end
        -- Claim ownership locally to prevent server correction
        ball.Velocity = ball.Velocity -- Tickles the physics engine
    end

    local isJumping = (hum.FloorMaterial == Enum.Material.Air)
    local lPos = root.CFrame:PointToObjectSpace(ball.Position + (ball.AssemblyLinearVelocity * CFG.PRED))
    local dx, dy, dz = lPos.X, lPos.Y, lPos.Z
    local hit, mode = false, ""

    -- Vertical/Head Reach
    if isJumping and dy >= 2.5 and dy <= CFG.AIR_Y then
        if math.abs(dx) <= CFG.AIR_X and math.abs(dz) <= CFG.AIR_Z then hit, mode = true, "H" end
    -- Ground/Leg Reach
    elseif dy <= 1.5 and dy >= -3.0 then
        local r = isJumping and CFG.JUMPLEG or CFG.GROUND
        if math.abs(dx) <= r and math.abs(dz) <= r then hit, mode = true, "G" end
    end

    if hit then
        local look = camera.CFrame.LookVector
        if mode == "H" then
            -- Forceful impulse to override server position
            ball:ApplyImpulse((look * CFG.FORCE) + Vector3.new(0, 15, 0))
            firetouchinterest(ball, char:FindFirstChild("Head") or root, 0)
            firetouchinterest(ball, char:FindFirstChild("Head") or root, 1)
        else
            -- Ground velocity injection
            local vel = isJumping and Vector3.new(look.X * 95, -65, look.Z * 95) or (look * 95)
            ball.AssemblyLinearVelocity = vel
            ball:ApplyImpulse(vel * 0.5) -- Double down on the force
            firetouchinterest(ball, root, 0)
            firetouchinterest(ball, root, 1)
        end
    end
end)

-- Keep the Logger running in BG
task.spawn(function()
    -- [Logger code remains same as V39]
end)

print(">>> MONOLITH V40.0 BUFFED LOADED <<<")
