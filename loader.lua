--[[
    Auto Fishing Pro - Quick Loader
    Load this script to automatically download and execute the latest version
]]

local function loadScript()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/auto-fishing.lua")
    end)
    
    if success then
        local executeSuccess, executeResult = pcall(function()
            return loadstring(result)()
        end)
        
        if executeSuccess then
            print("🎣 Auto Fishing Pro loaded successfully!")
        else
            warn("❌ Failed to execute script: " .. tostring(executeResult))
        end
    else
        warn("❌ Failed to download script: " .. tostring(result))
        warn("🔄 Trying to load local file...")
        
        -- Fallback to local file if available
        if readfile and isfile and isfile('auto-fishing.lua') then
            local localScript = readfile('auto-fishing.lua')
            loadstring(localScript)()
            print("🎣 Auto Fishing Pro loaded from local file!")
        else
            warn("❌ No local file found. Please check your connection or download the script manually.")
        end
    end
end

loadScript()
