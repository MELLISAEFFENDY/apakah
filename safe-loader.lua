--[[
    Safe Module Loader for Auto Fishing
    Created by: MELLISAEFFENDY
    Description: Safe module loading with comprehensive error handling
    Version: 1.0
]]

local SafeLoader = {}

--// Safe Module Loading Function
function SafeLoader.loadModule(moduleName, fallbackUrl)
    local module = nil
    local success = false
    
    -- Try loading from local file first
    local localSuccess = pcall(function()
        if readfile and isfile and isfile(moduleName) then
            local moduleCode = readfile(moduleName)
            if moduleCode and moduleCode ~= "" then
                local loadFunc = loadstring(moduleCode)
                if loadFunc then
                    module = loadFunc()
                    success = true
                    print("✅ " .. moduleName .. " loaded from local file")
                end
            end
        end
    end)
    
    -- If local loading failed, try fallback URL
    if not success and fallbackUrl then
        local urlSuccess = pcall(function()
            local moduleCode = game:HttpGet(fallbackUrl)
            if moduleCode and moduleCode ~= "" then
                local loadFunc = loadstring(moduleCode)
                if loadFunc then
                    module = loadFunc()
                    success = true
                    print("✅ " .. moduleName .. " loaded from GitHub")
                end
            end
        end)
        
        if not urlSuccess then
            warn("❌ Failed to load " .. moduleName .. " from both local and GitHub")
        end
    end
    
    return module, success
end

--// Create fallback objects for modules
function SafeLoader.createFallbackInstantReel()
    return {
        setEnabled = function(enabled) 
            print("InstantReel setEnabled:", enabled) 
        end,
        setInstantMode = function(enabled) 
            print("InstantReel setInstantMode:", enabled) 
        end,
        setFastMode = function(enabled) 
            print("InstantReel setFastMode:", enabled) 
        end,
        setDetectionAvoidance = function(enabled) 
            print("InstantReel setDetectionAvoidance:", enabled) 
        end,
        performReel = function() 
            print("InstantReel performReel called") 
        end,
        printTestResults = function() 
            print("InstantReel test: Fallback mode active") 
        end,
        getStatistics = function() 
            return {totalReels=0, successfulReels=0, successRate=0, averageTime=0} 
        end,
        resetStatistics = function() 
            print("InstantReel statistics reset") 
        end,
        init = function() 
            return SafeLoader.createFallbackInstantReel()
        end
    }
end

function SafeLoader.createFallbackTeleportSystem()
    return {
        teleportToLocation = function(location, method, smooth)
            warn("TeleportSystem not available - teleportToLocation called")
            return false, "TeleportSystem fallback mode"
        end,
        teleportToCoordinates = function(x, y, z, smooth)
            warn("TeleportSystem not available - teleportToCoordinates called")
            return false, "TeleportSystem fallback mode"
        end,
        teleportToPlayer = function(playerName)
            warn("TeleportSystem not available - teleportToPlayer called")
            return false, "TeleportSystem fallback mode"
        end,
        saveCurrentLocation = function(name)
            warn("TeleportSystem not available - saveCurrentLocation called")
            return false, "TeleportSystem fallback mode"
        end,
        returnToLastPosition = function()
            warn("TeleportSystem not available - returnToLastPosition called")
            return false, "TeleportSystem fallback mode"
        end,
        testConnections = function()
            return {CFrame=false, FastTravel=false, SeaTraveler=false, RequestTeleport=false}
        end,
        getStatistics = function()
            return {totalTeleports=0, successfulTeleports=0, successRate=0, favoriteLocation="None"}
        end,
        resetStatistics = function()
            print("TeleportSystem statistics reset")
        end,
        enableAutoReturn = function()
            print("TeleportSystem auto-return enabled (fallback)")
        end
    }
end

--// Load all modules safely
function SafeLoader.loadAllModules()
    local modules = {}
    
    -- Load OrionLib UI
    print("📦 Loading OrionLib UI...")
    modules.OrionLib, _ = SafeLoader.loadModule('ui.lua', 'https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua')
    
    if not modules.OrionLib then
        error("❌ Critical Error: OrionLib UI failed to load! Cannot continue without UI library.")
    end
    
    -- Load InstantReel Module
    print("📦 Loading InstantReel Module...")
    modules.InstantReel, _ = SafeLoader.loadModule('instant-reel.lua', 'https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/instant-reel.lua')
    
    if not modules.InstantReel then
        print("⚠️ InstantReel failed to load, using fallback")
        modules.InstantReel = SafeLoader.createFallbackInstantReel()
    else
        -- Initialize InstantReel safely
        if modules.InstantReel.init and type(modules.InstantReel.init) == "function" then
            local initSuccess = pcall(function()
                modules.InstantReel = modules.InstantReel.init()
            end)
            if not initSuccess then
                print("⚠️ InstantReel init failed, using fallback")
                modules.InstantReel = SafeLoader.createFallbackInstantReel()
            end
        end
    end
    
    -- Load TeleportSystem Module
    print("📦 Loading TeleportSystem Module...")
    modules.TeleportSystem, _ = SafeLoader.loadModule('teleport-system.lua', 'https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/teleport-system.lua')
    
    if not modules.TeleportSystem then
        print("⚠️ TeleportSystem failed to load, using fallback")
        modules.TeleportSystem = SafeLoader.createFallbackTeleportSystem()
    else
        -- Initialize TeleportSystem safely
        if modules.TeleportSystem.enableAutoReturn and type(modules.TeleportSystem.enableAutoReturn) == "function" then
            local initSuccess = pcall(function()
                modules.TeleportSystem.enableAutoReturn()
            end)
            if not initSuccess then
                print("⚠️ TeleportSystem enableAutoReturn failed")
            end
        end
    end
    
    print("✅ All modules loaded successfully!")
    return modules
end

return SafeLoader
