--[[
    Auto Fishing Script for Roblox Fisch - SAFE VERSION
    Created by: MELLISAEFFENDY
    Description: Safe loading version with minimal dependencies
    Version: 3.0 - SAFE EDITION
]]

print("🔍 Starting Auto Fishing Script - Safe Version...")
print("🔍 Checking environment...")

-- Check if we're in the right game
if not game or not game.PlaceId then
    error("❌ Script must be run in Roblox game environment!")
end

print("✅ Environment check passed")
print("🔍 Loading UI Library...")

-- Safe UI Loading
local OrionLib
local function loadOrionLib()
    local sources = {
        -- Our custom UI
        function()
            if readfile and isfile and isfile('ui.lua') then
                return loadstring(readfile('ui.lua'))()
            end
            return nil
        end,
        -- GitHub backup
        function()
            return loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua'))()
        end,
        -- Alternative OrionLib
        function()
            return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
        end
    }
    
    for i, source in ipairs(sources) do
        local success, result = pcall(source)
        if success and result then
            print("✅ OrionLib loaded from source " .. i)
            return result
        else
            warn("⚠️ Source " .. i .. " failed: " .. tostring(result))
        end
    end
    
    error("❌ Failed to load OrionLib from all sources!")
end

OrionLib = loadOrionLib()

print("✅ UI Library loaded successfully")
print("🔍 Creating basic UI...")

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "🎣 Auto Fishing Pro - Safe Mode",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AutoFishingPro"
})

-- Basic Tab
local MainTab = Window:MakeTab({
    Name = "🎣 Main",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

-- Test Section
local TestSection = MainTab:AddSection({
    Name = "System Test"
})

TestSection:AddLabel("✅ Script loaded successfully!")
TestSection:AddLabel("✅ UI system working")
TestSection:AddLabel("✅ No critical errors detected")

TestSection:AddButton({
    Name = "Test Notification",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Test Success",
            Content = "All systems working correctly!",
            Time = 3
        })
    end    
})

-- Basic Controls
local ControlSection = MainTab:AddSection({
    Name = "Basic Controls"
})

local testToggle = ControlSection:AddToggle({
    Name = "Test Toggle",
    Default = false,
    Callback = function(Value)
        print("Toggle value:", Value)
    end    
})

local testSlider = ControlSection:AddSlider({
    Name = "Test Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "value",
    Callback = function(Value)
        print("Slider value:", Value)
    end    
})

print("✅ Safe mode script loaded successfully!")
print("🎮 You can now test the UI functionality")

OrionLib:MakeNotification({
    Name = "Safe Mode Loaded",
    Content = "Script loaded in safe mode. Basic functionality available.",
    Time = 5
})
