--[[
    Teleport System for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Advanced teleport system with multiple methods
    Version: 1.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🚀 Features: Fast Travel, Sea Traveler, CFrame Teleport, Custom Locations
]]

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local Workspace = cloneref(game:GetService('Workspace'))
local TweenService = cloneref(game:GetService('TweenService'))

--// Variables
local lp = Players.LocalPlayer
local teleportSystem = {}

--// Predefined Locations (berdasarkan common fishing spots)
local predefinedLocations = {
    ["Moosewood"] = {
        name = "Moosewood Docks",
        position = CFrame.new(-1463, 134, 224),
        description = "Main starting area with basic fishing spots"
    },
    ["Ocean"] = {
        name = "Deep Ocean",
        position = CFrame.new(1000, 134, 1000),
        description = "Deep ocean fishing area"
    },
    ["Mushgrove"] = {
        name = "Mushgrove Swamp", 
        position = CFrame.new(-2471, 134, -724),
        description = "Swamp area with unique fish"
    },
    ["Roslit Bay"] = {
        name = "Roslit Bay",
        position = CFrame.new(-1478, 134, 689),
        description = "Bay area with calm waters"
    },
    ["Snowcap Island"] = {
        name = "Snowcap Island",
        position = CFrame.new(2648, 134, 2522),
        description = "Cold fishing area with rare fish"
    },
    ["Sunstone Island"] = {
        name = "Sunstone Island",
        position = CFrame.new(-943, 194, -1123),
        description = "Tropical island fishing spot"
    },
    ["The Depths"] = {
        name = "The Depths Entrance",
        position = CFrame.new(978, -711, 1270),
        description = "Deep underwater fishing area"
    },
    ["Forsaken Shores"] = {
        name = "Forsaken Shores",
        position = CFrame.new(-2813, 134, 1540),
        description = "Dangerous but rewarding fishing area"
    },
    ["Vertigo"] = {
        name = "Vertigo",
        position = CFrame.new(-112, 134, -990),
        description = "High altitude fishing spot"
    },
    ["Ancient Isle"] = {
        name = "Ancient Isle",
        position = CFrame.new(6406, 134, 272),
        description = "Ancient ruins with rare fish"
    }
}

--// Statistics
local teleportStats = {
    totalTeleports = 0,
    successfulTeleports = 0,
    failedTeleports = 0,
    lastTeleportTime = 0,
    favoriteLocation = "None"
}

--// Utility Functions
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild('HumanoidRootPart')
end

--// Teleport Methods
function teleportSystem.fastTravel(locationName)
    local success = false
    pcall(function()
        local fastTravelRemote = ReplicatedStorage.packages.Net.RE:FindFirstChild("FastTravel/Teleport")
        if fastTravelRemote then
            fastTravelRemote:FireServer(locationName)
            success = true
            teleportStats.totalTeleports = teleportStats.totalTeleports + 1
            teleportStats.successfulTeleports = teleportStats.successfulTeleports + 1
            teleportStats.lastTeleportTime = tick()
        end
    end)
    
    if not success then
        teleportStats.failedTeleports = teleportStats.failedTeleports + 1
    end
    
    return success
end

function teleportSystem.seaTraveler(destination)
    local success = false
    pcall(function()
        local seaTraveler = Workspace:FindFirstChild("Sea Traveler")
        if seaTraveler and seaTraveler:FindFirstChild("seatraveler") then
            local teleportRemote = seaTraveler.seatraveler:FindFirstChild("teleport")
            if teleportRemote then
                teleportRemote:InvokeServer(destination)
                success = true
                teleportStats.totalTeleports = teleportStats.totalTeleports + 1
                teleportStats.successfulTeleports = teleportStats.successfulTeleports + 1
                teleportStats.lastTeleportTime = tick()
            end
        end
    end)
    
    if not success then
        teleportStats.failedTeleports = teleportStats.failedTeleports + 1
    end
    
    return success
end

function teleportSystem.cframeTeleport(targetCFrame, useTween)
    local success = false
    pcall(function()
        local hrp = getHRP()
        if useTween then
            -- Smooth teleport with tween
            local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        else
            -- Instant teleport
            hrp.CFrame = targetCFrame
        end
        success = true
        teleportStats.totalTeleports = teleportStats.totalTeleports + 1
        teleportStats.successfulTeleports = teleportStats.successfulTeleports + 1
        teleportStats.lastTeleportTime = tick()
    end)
    
    if not success then
        teleportStats.failedTeleports = teleportStats.failedTeleports + 1
    end
    
    return success
end

function teleportSystem.requestTeleportCFrame(targetCFrame)
    local success = false
    pcall(function()
        local teleportRemote = ReplicatedStorage.packages.Net.RF:FindFirstChild("RequestTeleportCFrame")
        if teleportRemote then
            teleportRemote:InvokeServer(targetCFrame)
            success = true
            teleportStats.totalTeleports = teleportStats.totalTeleports + 1
            teleportStats.successfulTeleports = teleportStats.successfulTeleports + 1
            teleportStats.lastTeleportTime = tick()
        end
    end)
    
    if not success then
        teleportStats.failedTeleports = teleportStats.failedTeleports + 1
    end
    
    return success
end

function teleportSystem.teleportToLocation(locationKey, method, useTween)
    method = method or "cframe"
    useTween = useTween or false
    
    local location = predefinedLocations[locationKey]
    if not location then
        return false, "Location not found"
    end
    
    local success = false
    local errorMsg = ""
    
    if method == "fasttravel" then
        success = teleportSystem.fastTravel(locationKey)
        errorMsg = "Fast Travel failed"
    elseif method == "seatraveler" then
        success = teleportSystem.seaTraveler(locationKey)
        errorMsg = "Sea Traveler failed"
    elseif method == "request" then
        success = teleportSystem.requestTeleportCFrame(location.position)
        errorMsg = "Request Teleport failed"
    else -- cframe method (default)
        success = teleportSystem.cframeTeleport(location.position, useTween)
        errorMsg = "CFrame Teleport failed"
    end
    
    if success then
        teleportStats.favoriteLocation = locationKey
    end
    
    return success, success and "Teleported to " .. location.name or errorMsg
end

function teleportSystem.teleportToPlayer(playerName)
    local success = false
    pcall(function()
        local targetPlayer = Players:FindFirstChild(playerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.CFrame
            success = teleportSystem.cframeTeleport(targetPosition, false)
        end
    end)
    
    return success
end

function teleportSystem.teleportToCoordinates(x, y, z, useTween)
    local targetCFrame = CFrame.new(x, y or 134, z)
    return teleportSystem.cframeTeleport(targetCFrame, useTween)
end

function teleportSystem.saveCurrentLocation(name)
    local success = false
    pcall(function()
        local hrp = getHRP()
        local currentPosition = hrp.CFrame
        
        predefinedLocations[name] = {
            name = name,
            position = currentPosition,
            description = "Custom saved location"
        }
        success = true
    end)
    
    return success
end

function teleportSystem.getAvailableLocations()
    return predefinedLocations
end

function teleportSystem.getStatistics()
    return {
        totalTeleports = teleportStats.totalTeleports,
        successfulTeleports = teleportStats.successfulTeleports,
        failedTeleports = teleportStats.failedTeleports,
        successRate = teleportStats.totalTeleports > 0 and 
                     (teleportStats.successfulTeleports / teleportStats.totalTeleports * 100) or 0,
        lastTeleportTime = teleportStats.lastTeleportTime,
        favoriteLocation = teleportStats.favoriteLocation
    }
end

function teleportSystem.resetStatistics()
    teleportStats.totalTeleports = 0
    teleportStats.successfulTeleports = 0
    teleportStats.failedTeleports = 0
    teleportStats.lastTeleportTime = 0
    teleportStats.favoriteLocation = "None"
end

function teleportSystem.testConnections()
    local results = {
        fastTravel = ReplicatedStorage.packages.Net.RE:FindFirstChild("FastTravel/Teleport") ~= nil,
        seaTraveler = Workspace:FindFirstChild("Sea Traveler") ~= nil,
        requestTeleport = ReplicatedStorage.packages.Net.RF:FindFirstChild("RequestTeleportCFrame") ~= nil,
        teleportService = ReplicatedStorage.packages.Net.RE:FindFirstChild("TeleportService/RequestTeleport") ~= nil
    }
    
    return results
end

--// Auto-return to last location (for safety)
function teleportSystem.enableAutoReturn()
    local lastPosition = getHRP().CFrame
    
    -- Save position every 30 seconds
    spawn(function()
        while true do
            wait(30)
            if getChar() and getHRP() then
                lastPosition = getHRP().CFrame
            end
        end
    end)
    
    -- Return function
    teleportSystem.returnToLastPosition = function()
        return teleportSystem.cframeTeleport(lastPosition, true)
    end
end

return teleportSystem
