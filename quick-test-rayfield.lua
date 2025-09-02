--[[
    Quick Test - Rayfield UI MakeWindow Fix
    Test if Rayfield UI now has proper MakeWindow method
]]

print("🧪 Testing Rayfield UI MakeWindow fix...")

local success, rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/rayfield-ui.lua'))()
end)

if success then
    print("✅ Rayfield UI loaded successfully!")
    print("Type:", type(rayfield))
    
    if rayfield.MakeWindow then
        print("✅ MakeWindow method found! Type:", type(rayfield.MakeWindow))
        
        -- Test creating a window
        local windowSuccess, window = pcall(function()
            return rayfield:MakeWindow({
                Name = "Test Window",
                LoadingTitle = "Testing...",
                LoadingSubtitle = "Quick test"
            })
        end)
        
        if windowSuccess then
            print("✅ Test window created successfully!")
            if window and window.Destroy then
                window:Destroy()
                print("✅ Test window destroyed!")
            end
        else
            print("❌ Failed to create window:", window)
        end
    else
        print("❌ MakeWindow method not found!")
        
        -- List available methods
        local methods = {}
        for key, value in pairs(rayfield) do
            if type(value) == "function" then
                table.insert(methods, key)
            end
        end
        print("Available methods:", table.concat(methods, ", "))
    end
else
    print("❌ Failed to load Rayfield UI:", rayfield)
end

print("🧪 Test complete!")
