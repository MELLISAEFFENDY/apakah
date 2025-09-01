--[[
    Utility System for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Utility features including No Oxygen, No Temperature, Noclip, Anti-Down, WalkSpeed, and Unlimited Jump
    Version: 1.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🛠️ Features:
    - Infinite Oxygen (No drowning)
    - No Temperature Effects (No winter/cold damage)
    - Noclip (Walk through walls)
    - Anti-Down (Anti falling damage)
    - WalkSpeed Control (Custom walking speed)
    - Unlimited Jump (Infinite jump power)
]]

local UtilitySystem = {}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--// State Variables
local noOxygenEnabled = false
local noTemperatureEnabled = false
local noclipEnabled = false
local antiDownEnabled = false
local walkSpeedEnabled = false
local unlimitedJumpEnabled = false

--// Default Values
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local customWalkSpeed = 16
local customJumpPower = 50

--// Connections
local connections = {}

--// Update character references when character spawns
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Store default values for new character
    defaultWalkSpeed = humanoid.WalkSpeed
    defaultJumpPower = humanoid.JumpPower
    
    -- Reapply active features
    if walkSpeedEnabled then
        UtilitySystem.setWalkSpeed(customWalkSpeed)
    end
    if unlimitedJumpEnabled then
        UtilitySystem.setJumpPower(customJumpPower)
    end
end)

--// No Oxygen System
function UtilitySystem.setNoOxygen(enabled)
    noOxygenEnabled = enabled
    
    if enabled then
        -- Create infinite oxygen tank
        if not character:FindFirstChild("DivingTank") then
            local oxygenTank = Instance.new("Decal")
            oxygenTank.Name = "DivingTank"
            oxygenTank.Parent = workspace
            oxygenTank:SetAttribute("Tier", math.huge)
            oxygenTank.Parent = character
        end
        
        -- Disable oxygen script if it exists
        local clientFolder = character:FindFirstChild("client")
        if clientFolder then
            local oxygenScript = clientFolder:FindFirstChild("oxygen")
            if oxygenScript then
                oxygenScript.Enabled = false
            end
        end
        
        print("🫁 No Oxygen: ENABLED - You can breathe underwater indefinitely!")
    else
        -- Remove infinite oxygen tank
        local oxygenTank = character:FindFirstChild("DivingTank")
        if oxygenTank then
            oxygenTank:Destroy()
        end
        
        -- Re-enable oxygen script
        local clientFolder = character:FindFirstChild("client")
        if clientFolder then
            local oxygenScript = clientFolder:FindFirstChild("oxygen")
            if oxygenScript then
                oxygenScript.Enabled = true
            end
        end
        
        print("🫁 No Oxygen: DISABLED")
    end
end

--// No Temperature System
function UtilitySystem.setNoTemperature(enabled)
    noTemperatureEnabled = enabled
    
    if enabled then
        -- Set attributes to prevent temperature effects
        character:SetAttribute("WinterCloakEquipped", true)
        character:SetAttribute("Refill", true)
        
        -- Continuously maintain no temperature effects
        connections.noTemperature = RunService.Heartbeat:Connect(function()
            if character and character.Parent then
                character:SetAttribute("WinterCloakEquipped", true)
                character:SetAttribute("Refill", true)
            end
        end)
        
        print("🌡️ No Temperature: ENABLED - Immune to cold and temperature effects!")
    else
        -- Remove temperature immunity
        if connections.noTemperature then
            connections.noTemperature:Disconnect()
            connections.noTemperature = nil
        end
        
        character:SetAttribute("WinterCloakEquipped", nil)
        character:SetAttribute("Refill", false)
        
        print("🌡️ No Temperature: DISABLED")
    end
end

--// Noclip System
function UtilitySystem.setNoclip(enabled)
    noclipEnabled = enabled
    
    if enabled then
        connections.noclip = RunService.Stepped:Connect(function()
            if character and character.Parent then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        print("👻 Noclip: ENABLED - You can walk through walls!")
    else
        if connections.noclip then
            connections.noclip:Disconnect()
            connections.noclip = nil
        end
        
        -- Restore collision
        if character and character.Parent then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        print("👻 Noclip: DISABLED")
    end
end

--// Anti-Down System (Anti Falling Damage)
function UtilitySystem.setAntiDown(enabled)
    antiDownEnabled = enabled
    
    if enabled then
        connections.antiDown = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 then
                -- Prevent fall damage by limiting fall velocity
                if humanoidRootPart.Velocity.Y < -50 then
                    local velocity = humanoidRootPart.Velocity
                    humanoidRootPart.Velocity = Vector3.new(velocity.X, -20, velocity.Z)
                end
                
                -- Prevent health loss from falling
                if humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 then
                    local currentHealth = humanoid.Health
                    wait(0.1)
                    if humanoid.Health < currentHealth then
                        humanoid.Health = currentHealth
                    end
                end
            end
        end)
        
        print("🛡️ Anti-Down: ENABLED - No more fall damage!")
    else
        if connections.antiDown then
            connections.antiDown:Disconnect()
            connections.antiDown = nil
        end
        
        print("🛡️ Anti-Down: DISABLED")
    end
end

--// WalkSpeed System
function UtilitySystem.setWalkSpeed(speed)
    customWalkSpeed = speed or defaultWalkSpeed
    
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = customWalkSpeed
        print("🏃 WalkSpeed set to:", customWalkSpeed)
    end
end

function UtilitySystem.enableWalkSpeed(enabled, speed)
    walkSpeedEnabled = enabled
    
    if enabled then
        UtilitySystem.setWalkSpeed(speed or customWalkSpeed)
        
        -- Keep walkspeed consistent
        connections.walkSpeed = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if walkSpeedEnabled and humanoid.WalkSpeed ~= customWalkSpeed then
                humanoid.WalkSpeed = customWalkSpeed
            end
        end)
        
        print("🏃 Custom WalkSpeed: ENABLED")
    else
        if connections.walkSpeed then
            connections.walkSpeed:Disconnect()
            connections.walkSpeed = nil
        end
        
        humanoid.WalkSpeed = defaultWalkSpeed
        print("🏃 Custom WalkSpeed: DISABLED")
    end
end

--// Unlimited Jump System
function UtilitySystem.setJumpPower(power)
    customJumpPower = power or defaultJumpPower
    
    if humanoid and humanoid.Parent then
        humanoid.JumpPower = customJumpPower
        print("🦘 JumpPower set to:", customJumpPower)
    end
end

function UtilitySystem.enableUnlimitedJump(enabled, power)
    unlimitedJumpEnabled = enabled
    
    if enabled then
        UtilitySystem.setJumpPower(power or customJumpPower)
        
        -- Keep jump power consistent
        connections.jumpPower = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if unlimitedJumpEnabled and humanoid.JumpPower ~= customJumpPower then
                humanoid.JumpPower = customJumpPower
            end
        end)
        
        print("🦘 Unlimited Jump: ENABLED")
    else
        if connections.jumpPower then
            connections.jumpPower:Disconnect()
            connections.jumpPower = nil
        end
        
        humanoid.JumpPower = defaultJumpPower
        print("🦘 Unlimited Jump: DISABLED")
    end
end

--// Get Status Functions
function UtilitySystem.getNoOxygenStatus()
    return noOxygenEnabled
end

function UtilitySystem.getNoTemperatureStatus()
    return noTemperatureEnabled
end

function UtilitySystem.getNoclipStatus()
    return noclipEnabled
end

function UtilitySystem.getAntiDownStatus()
    return antiDownEnabled
end

function UtilitySystem.getWalkSpeedStatus()
    return walkSpeedEnabled, customWalkSpeed
end

function UtilitySystem.getUnlimitedJumpStatus()
    return unlimitedJumpEnabled, customJumpPower
end

--// Cleanup function
function UtilitySystem.cleanup()
    for name, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    
    -- Reset all features
    UtilitySystem.setNoOxygen(false)
    UtilitySystem.setNoTemperature(false)
    UtilitySystem.setNoclip(false)
    UtilitySystem.setAntiDown(false)
    UtilitySystem.enableWalkSpeed(false)
    UtilitySystem.enableUnlimitedJump(false)
    
    print("🧹 UtilitySystem: All features disabled and cleaned up")
end

--// Initialize
function UtilitySystem.init()
    print("🛠️ Utility System v1.0 - Loaded successfully!")
    print("🫁 No Oxygen - Breathe underwater indefinitely")
    print("🌡️ No Temperature - Immune to cold/temperature effects") 
    print("👻 Noclip - Walk through walls")
    print("🛡️ Anti-Down - No fall damage")
    print("🏃 WalkSpeed - Custom walking speed")
    print("🦘 Unlimited Jump - Custom jump power")
    return UtilitySystem
end

return UtilitySystem
