--[[
    Test Script for Rayfield UI Fix
    This script tests if the MakeWindow error has been resolved
]]

print("🧪 Testing Rayfield UI Fix...")

-- Load Rayfield UI
local success, OrionLib = pcall(function()
    return loadfile("rayfield-ui.lua")()
end)

if not success then
    print("❌ Failed to load rayfield-ui.lua:", OrionLib)
    return
end

print("✅ Rayfield UI loaded successfully")

-- Debug: Check if OrionLib is properly loaded
print("🔍 OrionLib type:", type(OrionLib))

-- Debug: Check available methods
print("📋 Available methods:")
for key, value in pairs(OrionLib) do
    if type(value) == "function" then
        print("   ✓", key, ":", type(value))
    end
end

-- Test MakeWindow method
print("🪟 Testing MakeWindow method...")

if OrionLib.MakeWindow then
    print("✅ MakeWindow method exists!")
    
    -- Try to create a test window
    local testSuccess, window = pcall(function()
        return OrionLib.MakeWindow({
            Name = "🧪 Test Window",
            HidePremium = false,
            SaveConfig = true,
            ConfigFolder = "FischTestConfig"
        })
    end)
    
    if testSuccess then
        print("✅ MakeWindow executed successfully!")
        print("🪟 Window type:", type(window))
        
        -- Test creating a tab
        if window.MakeTab then
            local tabSuccess, tab = pcall(function()
                return window:MakeTab({
                    Name = "🧪 Test Tab",
                    Icon = "rbxassetid://4483345998",
                    PremiumOnly = false
                })
            end)
            
            if tabSuccess then
                print("✅ Tab creation successful!")
                
                -- Test adding a button
                tab:AddButton({
                    Name = "✅ Test Button - UI is Working!",
                    Callback = function()
                        print("🎉 Button clicked! UI is fully functional!")
                        OrionLib:MakeNotification({
                            Name = "Success!",
                            Content = "Rayfield UI is working perfectly!",
                            Duration = 3
                        })
                    end    
                })
                
                print("✅ All tests passed! Rayfield UI is working correctly! 🎉")
            else
                print("❌ Tab creation failed:", tab)
            end
        else
            print("❌ MakeTab method not found on window")
        end
        
    else
        print("❌ MakeWindow execution failed:", window)
    end
else
    print("❌ MakeWindow method not found!")
    print("Available methods:", table.concat(OrionLib and OrionLib.__index and Object.keys(OrionLib.__index) or {}, ", "))
end

print("🏁 Test completed.")
