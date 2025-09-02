--[[
    Test UI Loader - Debug UI Loading Issues
    Created by: MELLISAEFFENDY
    Description: Test script to debug UI loading problems
]]

print("🧪 Testing UI Library Loading...")

-- Test all UI libraries
local uiLibraries = {
    {name = "OrionLib", url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua"},
    {name = "Rayfield UI", url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/rayfield-ui.lua"},
    {name = "Kavo UI", url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/kavo-ui.lua"},
    {name = "UIv2", url = "https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/uiv2.lua"}
}

for _, ui in pairs(uiLibraries) do
    print("\n📦 Testing " .. ui.name .. "...")
    
    local success, result = pcall(function()
        local lib = loadstring(game:HttpGet(ui.url))()
        
        print("✅ " .. ui.name .. " loaded successfully!")
        print("   Type:", type(lib))
        
        if type(lib) == "table" then
            -- Check for MakeWindow method
            if lib.MakeWindow then
                print("   ✅ MakeWindow: " .. type(lib.MakeWindow))
            else
                print("   ❌ MakeWindow: NOT FOUND")
            end
            
            -- List some methods
            local methods = {}
            local count = 0
            for key, value in pairs(lib) do
                if type(value) == "function" and count < 5 then
                    table.insert(methods, key)
                    count = count + 1
                end
            end
            print("   Methods (first 5):", table.concat(methods, ", "))
            
            -- Try to create a test window
            if lib.MakeWindow then
                local testSuccess, testWindow = pcall(function()
                    return lib:MakeWindow({
                        Name = "Test Window",
                        HidePremium = true
                    })
                end)
                
                if testSuccess then
                    print("   ✅ Test window created successfully!")
                    if testWindow and testWindow.Destroy then
                        testWindow:Destroy()
                        print("   ✅ Test window destroyed successfully!")
                    end
                else
                    print("   ❌ Failed to create test window:", testWindow)
                end
            end
        else
            print("   ❌ Library is not a table!")
        end
        
        return lib
    end)
    
    if not success then
        print("❌ Failed to load " .. ui.name .. ":", result)
    end
end

print("\n🧪 UI Loading Test Complete!")
print("💡 Run this script to test all UI libraries")
