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
        
        -- Fallback to local files if available
        if readfile and isfile then
            if isfile('auto-fishing.lua') then
                local localScript = readfile('auto-fishing.lua')
                loadstring(localScript)()
                print("🎣 Auto Fishing Pro loaded from local file!")
            elseif isfile('simple-ui.lua') then
                -- Load UI library first, then show error message
                local ui = loadstring(readfile('simple-ui.lua'))()
                local window = ui:MakeWindow({Name = "⚠️ Auto Fishing Pro - Error"})
                ui:MakeNotification({
                    Name = "Error",
                    Content = "Main script not found. Please download auto-fishing.lua",
                    Time = 10
                })
            else
                warn("❌ No local files found. Please check your connection or download the script manually.")
            end
        else
            warn("❌ Executor doesn't support file operations.")
        end
    end
end

loadScript()
