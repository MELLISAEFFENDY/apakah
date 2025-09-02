--[[
    UI File Detection Test
    Use this to test if UI files are detected properly
]]

print("🔍 Starting UI File Detection Test...")

-- Test file detection functions
if readfile and isfile then
    print("✅ File functions available")
    
    local testFiles = {
        "uiv2.lua",
        "ui.lua", 
        "uiv2-wrapper.lua",
        "loader.lua",
        "auto-fishing.lua"
    }
    
    for _, filename in pairs(testFiles) do
        local success, exists = pcall(function()
            return isfile(filename)
        end)
        
        if success and exists then
            print("✅ " .. filename .. " - Found")
            
            -- Try to read a small portion
            local readSuccess, content = pcall(function()
                local data = readfile(filename)
                return string.sub(data, 1, 100)
            end)
            
            if readSuccess then
                print("   📖 Preview: " .. string.sub(content, 1, 50) .. "...")
            end
        else
            print("❌ " .. filename .. " - Not found or error")
        end
    end
else
    print("❌ File functions not available")
    print("   readfile: " .. tostring(readfile))
    print("   isfile: " .. tostring(isfile))
end

print("🔍 Detection test complete!")

-- Also test the loader's detection function
print("\n🔧 Testing loader detection function...")

loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/loader.lua"))()
