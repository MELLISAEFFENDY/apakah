--[[
    Auto Fishing Script for Roblox Fisch - SAFE VERSION
    Created by: MELLISAEFFENDY
    Description: Advanced auto fishing script with Safe Module Loading
    Version: 1.6 - SAFE EDITION
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    ⚡ NEW: Safe Module Loader - No more nil errors!
    🎣 Features: Auto Drop Bobber + Auto Shake V2 + Teleport System + Instant Reel
    👻 Auto Shake V2 - Invisible and ultra-fast shake system
    🚀 Teleport System - Advanced teleport with multiple methods and locations
    🎨 UI: Uses OrionLib (ui.lua) for professional interface
]]

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))
local UserInputService = cloneref(game:GetService('UserInputService'))

--// Variables
local lp = Players.LocalPlayer
local flags = {}
local characterPosition = nil
local connections = {}
local lastCastTime = 0
local bobberDropTimer = 0

--// Load Safe Module Loader
print("🔄 Initializing Safe Module Loader...")
local SafeLoader
local loaderSuccess = pcall(function()
    if readfile and isfile and isfile('safe-loader.lua') then
        SafeLoader = loadstring(readfile('safe-loader.lua'))()
    else
        -- Fallback: Load from GitHub
        SafeLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/safe-loader.lua'))()
    end
end)

if not loaderSuccess or not SafeLoader then
    error("❌ CRITICAL ERROR: Safe Module Loader failed to load! Cannot continue.")
end

--// Load all modules using Safe Loader
print("📦 Loading all modules...")
local modules = SafeLoader.loadAllModules()

local OrionLib = modules.OrionLib
local InstantReel = modules.InstantReel  
local TeleportSystem = modules.TeleportSystem

--// Helper Functions
local function safeTeleportCall(func, ...)
    if TeleportSystem and type(TeleportSystem) == "table" and TeleportSystem[func] and type(TeleportSystem[func]) == "function" then
        local success, result = pcall(TeleportSystem[func], ...)
        if success then
            return true, result or "Teleport successful"
        else
            warn("TeleportSystem call failed: " .. tostring(result))
            return false, "Teleport failed: " .. tostring(result)
        end
    else
        warn("⚠️ TeleportSystem function not available: " .. tostring(func))
        return false, "TeleportSystem not available"
    end
end

--// Utility Functions
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild('HumanoidRootPart')
end

local function getHumanoid()
    return getChar():WaitForChild('Humanoid')
end

local function findRod()
    local char = getChar()
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA('Tool') and tool:FindFirstChild('values') then
            return tool
        end
    end
    return nil
end

local function checkFunc(func)
    return typeof(func) == 'function'
end

--// Hooks Setup (if available)
local old
if checkFunc(hookmetamethod) then
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = getnamecallmethod(), {...}
        
        -- Perfect Cast Hook
        if method == 'FireServer' and self.Name == 'cast' and flags['perfectcast'] then
            args[1] = 100
            return old(self, unpack(args))
        end
        
        -- Always Catch Hook
        if method == 'FireServer' and self.Name == 'reelfinished' and flags['alwayscatch'] then
            args[1] = 100
            args[2] = true
            return old(self, unpack(args))
        end
        
        return old(self, ...)
    end)
end

--// Create Main Window
local Window = OrionLib:MakeWindow({
    Name = "🎣 Auto Fishing Pro v1.6",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AutoFishingPro",
    IntroText = "Auto Fishing Pro - Safe Edition",
    IntroIcon = "rbxassetid://4483345875"
})

--// Auto Fishing Tab
local AutoFishingTab = Window:MakeTab({
    Name = "🤖 Auto Fishing",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Character Section
local CharacterSection = AutoFishingTab:AddSection({
    Name = "Character Control"
})

local FreezeToggle = CharacterSection:AddToggle({
    Name = "Freeze Character",
    Default = false,
    Flag = "freezechar",
    Save = true,
    Callback = function(Value)
        flags['freezechar'] = Value
        if not Value then
            characterPosition = nil
        end
    end    
})

--// Fishing Automation Section
local FishingSection = AutoFishingTab:AddSection({
    Name = "Fishing Automation"
})

local AutoCastToggle = FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = false,
    Flag = "autocast",
    Save = true,
    Callback = function(Value)
        flags['autocast'] = Value
    end    
})

local AutoShakeToggle = FishingSection:AddToggle({
    Name = "Auto Shake",
    Default = false,
    Flag = "autoshake",
    Save = true,
    Callback = function(Value)
        flags['autoshake'] = Value
    end    
})

local AutoShakeV2Toggle = FishingSection:AddToggle({
    Name = "Auto Shake V2 (Invisible)",
    Default = false,
    Flag = "autoshakev2",
    Save = true,
    Callback = function(Value)
        flags['autoshakev2'] = Value
    end    
})

local AutoReelToggle = FishingSection:AddToggle({
    Name = "Auto Reel",
    Default = false,
    Flag = "autoreel",
    Save = true,
    Callback = function(Value)
        flags['autoreel'] = Value
    end    
})

local AutoDropBobberToggle = FishingSection:AddToggle({
    Name = "Auto Drop Bobber",
    Default = false,
    Flag = "autodropbobber", 
    Save = true,
    Callback = function(Value)
        flags['autodropbobber'] = Value
    end    
})

local DropBobberTimeSlider = FishingSection:AddSlider({
    Name = "Drop Bobber Time (seconds)",
    Min = 5,
    Max = 30,
    Default = 15,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "seconds",
    Flag = "dropbobbertime",
    Save = true,
    Callback = function(Value)
        flags['dropbobbertime'] = Value
    end    
})

--// Enhancement Section
local EnhancementSection = AutoFishingTab:AddSection({
    Name = "Fishing Enhancements"
})

if checkFunc(hookmetamethod) then
    local PerfectCastToggle = EnhancementSection:AddToggle({
        Name = "Perfect Cast",
        Default = false,
        Flag = "perfectcast",
        Save = true,
        Callback = function(Value)
            flags['perfectcast'] = Value
        end    
    })

    local AlwaysCatchToggle = EnhancementSection:AddToggle({
        Name = "Always Catch",
        Default = false,
        Flag = "alwayscatch",
        Save = true,
        Callback = function(Value)
            flags['alwayscatch'] = Value
        end    
    })
else
    EnhancementSection:AddLabel("⚠️ Hooks not available - Perfect Cast & Always Catch disabled")
end

--// Instant Reel Section
local InstantReelSection = AutoFishingTab:AddSection({
    Name = "⚡ Instant Reel System"
})

local InstantReelToggle = InstantReelSection:AddToggle({
    Name = "Enable Instant Reel",
    Default = false,
    Flag = "instantreel",
    Save = true,
    Callback = function(Value)
        flags['instantreel'] = Value
        if InstantReel and InstantReel.setEnabled then
            InstantReel.setEnabled(Value)
        end
    end    
})

local InstantModeToggle = InstantReelSection:AddToggle({
    Name = "Instant Mode (High Risk)",
    Default = false,
    Flag = "instantmode",
    Save = true,
    Callback = function(Value)
        flags['instantmode'] = Value
        if InstantReel and InstantReel.setInstantMode then
            InstantReel.setInstantMode(Value)
        end
    end    
})

local FastModeToggle = InstantReelSection:AddToggle({
    Name = "Fast Mode (Safer)",
    Default = true,
    Flag = "fastmode",
    Save = true,
    Callback = function(Value)
        flags['fastmode'] = Value
        if InstantReel and InstantReel.setFastMode then
            InstantReel.setFastMode(Value)
        end
    end    
})

local SafeModeToggle = InstantReelSection:AddToggle({
    Name = "Anti-Detection Mode",
    Default = true,
    Flag = "safemode",
    Save = true,
    Callback = function(Value)
        flags['safemode'] = Value
        if InstantReel and InstantReel.setDetectionAvoidance then
            InstantReel.setDetectionAvoidance(Value)
        end
    end    
})

local TestButton = InstantReelSection:AddButton({
    Name = "🧪 Test Reel Access",
    Callback = function()
        if InstantReel and InstantReel.printTestResults then
            InstantReel.printTestResults()
        else
            print("InstantReel module not available")
        end
    end    
})

local StatsButton = InstantReelSection:AddButton({
    Name = "📊 Show Statistics",
    Callback = function()
        if InstantReel and InstantReel.getStatistics then
            local stats = InstantReel.getStatistics()
            OrionLib:MakeNotification({
                Name = "📊 Instant Reel Stats",
                Content = string.format("Total: %d | Success: %d (%.1f%%) | Avg Time: %.2fs", 
                    stats.totalReels, stats.successfulReels, stats.successRate, stats.averageTime),
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "📊 Instant Reel Stats",
                Content = "InstantReel module not available",
                Time = 3
            })
        end
    end    
})

local ResetStatsButton = InstantReelSection:AddButton({
    Name = "🔄 Reset Statistics", 
    Callback = function()
        if InstantReel and InstantReel.resetStatistics then
            InstantReel.resetStatistics()
            OrionLib:MakeNotification({
                Name = "🔄 Statistics Reset",
                Content = "All instant reel statistics have been reset.",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "🔄 Statistics Reset",
                Content = "InstantReel module not available",
                Time = 3
            })
        end
    end    
})

--// Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "🚀 Teleport",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Quick Teleport Section
local QuickTeleportSection = TeleportTab:AddSection({
    Name = "🗺️ Quick Teleport Locations"
})

-- Popular fishing locations
QuickTeleportSection:AddButton({
    Name = "🏠 Moosewood Docks",
    Callback = function()
        local success, msg = safeTeleportCall("teleportToLocation", "Moosewood", "cframe", false)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and "Teleported successfully" or "Teleport failed"),
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🌊 Deep Ocean",
    Callback = function()
        local success, msg = safeTeleportCall("teleportToLocation", "Ocean", "cframe", false)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and "Teleported successfully" or "Teleport failed"),
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🍄 Mushgrove Swamp", 
    Callback = function()
        local success, msg = safeTeleportCall("teleportToLocation", "Mushgrove", "cframe", false)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and "Teleported successfully" or "Teleport failed"),
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🏝️ Roslit Bay",
    Callback = function()
        local success, msg = safeTeleportCall("teleportToLocation", "Roslit Bay", "cframe", false)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and "Teleported successfully" or "Teleport failed"),
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "❄️ Snowcap Island",
    Callback = function()
        local success, msg = safeTeleportCall("teleportToLocation", "Snowcap Island", "cframe", false)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and "Teleported successfully" or "Teleport failed"),
            Time = 3
        })
    end    
})

--// Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local InfoSection = SettingsTab:AddSection({
    Name = "Script Information"
})

InfoSection:AddLabel("Script Version: 1.6 - SAFE EDITION")
InfoSection:AddLabel("Created for: Roblox Fisch")
InfoSection:AddLabel("Status: ✅ Active with Safe Loading")
InfoSection:AddLabel("New: Safe Module Loader - No more nil errors!")
InfoSection:AddLabel("All modules load with comprehensive error handling!")

local ControlSection = SettingsTab:AddSection({
    Name = "Script Controls"
})

ControlSection:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end    
})

--// Main Loop
connections.mainLoop = RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Freeze Character
        if flags['freezechar'] then
            local rod = findRod()
            if rod and not characterPosition then
                characterPosition = getHRP().CFrame
            elseif rod and characterPosition then
                getHRP().CFrame = characterPosition
            end
        else
            characterPosition = nil
        end
        
        -- Auto Shake
        if flags['autoshake'] then
            local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
            if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
                GuiService.SelectedObject = shakeUI.safezone.button
                if GuiService.SelectedObject == shakeUI.safezone.button then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            end
        end
        
        -- Auto Shake V2 (Invisible & Fast)
        if flags['autoshakev2'] then
            local rod = findRod()
            if rod and rod.events and rod.events:FindFirstChild('shake') then
                -- Check if shake event should be triggered
                local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
                if shakeUI then
                    -- Instantly fire shake event without UI interaction
                    rod.events.shake:FireServer(100, true)
                    -- Hide the shake UI to make it invisible
                    shakeUI.Enabled = false
                    wait(0.1)
                    shakeUI.Enabled = true
                end
            end
        end
        
        -- Auto Cast
        if flags['autocast'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value <= 0.001 then
                wait(0.5)
                rod.events.cast:FireServer(100, 1)
                lastCastTime = tick()
                bobberDropTimer = 0
            end
        end
        
        -- Auto Drop Bobber
        if flags['autodropbobber'] then
            local rod = findRod()
            if rod and rod.values then
                local lureValue = rod.values.lure.Value
                -- If bobber is in water but no fish caught
                if lureValue > 0.001 and lureValue < 100 then
                    bobberDropTimer = bobberDropTimer + RunService.Heartbeat:Wait()
                    local dropTime = flags['dropbobbertime'] or 15
                    
                    if bobberDropTimer >= dropTime then
                        -- Drop the bobber and recast
                        rod.events.cast:FireServer(0, 1) -- Drop bobber
                        wait(0.5)
                        rod.events.cast:FireServer(100, 1) -- Recast
                        lastCastTime = tick()
                        bobberDropTimer = 0
                    end
                else
                    bobberDropTimer = 0
                end
            end
        end
        
        -- Auto Reel / Instant Reel
        if flags['autoreel'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value == 100 then
                -- Use Instant Reel if enabled, otherwise use normal reel
                if flags['instantreel'] and InstantReel and InstantReel.performReel then
                    InstantReel.performReel()
                else
                    wait(0.5)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        elseif flags['instantreel'] then
            -- Standalone Instant Reel (without Auto Reel)
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value >= 50 and InstantReel and InstantReel.performReel then
                InstantReel.performReel()
            end
        end
    end)
end)

--// Cleanup on character respawn
connections.charAdded = lp.CharacterAdded:Connect(function()
    characterPosition = nil
end)

--// Initialize
OrionLib:Init()

--// Notification
OrionLib:MakeNotification({
    Name = "🎣 Auto Fishing Pro v1.6 - SAFE EDITION",
    Content = "Script loaded with Safe Module Loader! No more nil errors - all modules protected!",
    Image = "rbxassetid://4483345875",
    Time = 5
})

print("🎣 Auto Fishing Pro v1.6 - SAFE EDITION - Script loaded successfully!")
print("🛡️ Safe Module Loader - All modules protected from nil errors!")
print("⚡ Instant Reel Module - " .. (InstantReel and "Loaded" or "Fallback"))
print("🚀 Teleport System - " .. (TeleportSystem and "Loaded" or "Fallback"))
print("🎨 UI Library - OrionLib")
print("📁 GitHub: https://github.com/MELLISAEFFENDY/apakah")
print("⚙️ Version: 1.6 - SAFE EDITION")
