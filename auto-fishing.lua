--[[
    Auto Fishing Script for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Advanced auto fishing script with Instant Reel + Auto Drop Bobber + Auto Shake V2 + Comprehensive Teleport System
    Version: 2.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    ⚡ NEW: Instant Reel Module - Lightning fast reel system with anti-detection
    🎣 NEW: Auto Drop Bobber - Automatically drops and recasts bobber when no fish bites
    👻 NEW: Auto Shake V2 - Invisible and ultra-fast shake system
    🚀 NEW: Teleport System - Advanced teleport with multiple methods and locations
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

--// Load UI Library
local OrionLib
pcall(function()
    if readfile and isfile and isfile('ui.lua') then
        OrionLib = loadstring(readfile('ui.lua'))()
    else
        -- Fallback: Load OrionLib from our repository
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua'))()
    end
end)

if not OrionLib then
    error("❌ Failed to load OrionLib UI library!")
end

--// Load Instant Reel Module
local InstantReel
local instantReelLoaded = false
pcall(function()
    if readfile and isfile and isfile('instant-reel.lua') then
        local instantReelCode = readfile('instant-reel.lua')
        InstantReel = loadstring(instantReelCode)()
        instantReelLoaded = true
        print("📁 InstantReel: Loaded from local file")
    else
        -- Fallback: Load from GitHub
        InstantReel = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/instant-reel.lua'))()
        instantReelLoaded = true
        print("🌐 InstantReel: Loaded from GitHub")
    end
end)

--// Load Teleport System
local TeleportSystem
local teleportLoaded = false
pcall(function()
    if readfile and isfile and isfile('teleport.lua') then
        local teleportCode = readfile('teleport.lua')
        TeleportSystem = loadstring(teleportCode)()
        teleportLoaded = true
        print("📁 TeleportSystem: Loaded from local file")
    else
        -- Fallback: Load from GitHub
        TeleportSystem = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/teleport.lua'))()
        teleportLoaded = true
        print("🌐 TeleportSystem: Loaded from GitHub")
    end
end)

-- Initialize InstantReel safely
if instantReelLoaded and InstantReel then
    if type(InstantReel) == "table" and InstantReel.init then
        InstantReel = InstantReel.init()
        print("✅ InstantReel module initialized successfully")
    elseif type(InstantReel) == "table" then
        print("✅ InstantReel module loaded successfully (no init required)")
    else
        warn("⚠️ InstantReel module loaded but not a table")
    end
else
    warn("⚠️ InstantReel module not loaded or init function not available")
    -- Create fallback InstantReel object
    InstantReel = {
        setEnabled = function() end,
        setInstantMode = function() end,
        setFastMode = function() end,
        setDetectionAvoidance = function() end,
        performReel = function() end,
        printTestResults = function() print("InstantReel not available") end,
        getStatistics = function() return {totalReels=0, successfulReels=0, successRate=0, averageTime=0} end,
        resetStatistics = function() end
    }
end

-- Initialize Teleport System safely
if teleportLoaded and TeleportSystem then
    if type(TeleportSystem) == "table" and TeleportSystem.init then
        local success, result = pcall(function()
            return TeleportSystem.init()
        end)
        if success then
            print("✅ TeleportSystem initialized successfully")
        else
            warn("⚠️ TeleportSystem init failed: " .. tostring(result))
        end
    elseif type(TeleportSystem) == "table" then
        print("✅ TeleportSystem loaded successfully (no init required)")
    else
        warn("⚠️ TeleportSystem loaded but not a table")
    end
else
    warn("⚠️ TeleportSystem not loaded properly or init function not available")
    -- Create fallback TeleportSystem object
    TeleportSystem = {
        teleportToPlace = function() return false, "TeleportSystem not available" end,
        teleportToFishArea = function() return false, "TeleportSystem not available" end,
        teleportToNPC = function() return false, "TeleportSystem not available" end,
        teleportToItem = function() return false, "TeleportSystem not available" end,
        teleportToPlayer = function() return false, "TeleportSystem not available" end,
        getPlaceNames = function() return {} end,
        getFishAreaNames = function() return {} end,
        getNPCNames = function() return {} end,
        getItemNames = function() return {} end,
        getPlayerList = function() return {} end,
        getStats = function() return {totalTeleports = 0, successfulTeleports = 0, successRate = 0} end,
        resetStats = function() end
    }
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
    Name = "🎣 Auto Fishing Pro",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AutoFishingPro",
    IntroText = "Auto Fishing Pro",
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
        InstantReel.setEnabled(Value)
    end    
})

local InstantModeToggle = InstantReelSection:AddToggle({
    Name = "Instant Mode (High Risk)",
    Default = false,
    Flag = "instantmode",
    Save = true,
    Callback = function(Value)
        flags['instantmode'] = Value
        InstantReel.setInstantMode(Value)
    end    
})

local FastModeToggle = InstantReelSection:AddToggle({
    Name = "Fast Mode (Safer)",
    Default = true,
    Flag = "fastmode",
    Save = true,
    Callback = function(Value)
        flags['fastmode'] = Value
        InstantReel.setFastMode(Value)
    end    
})

local SafeModeToggle = InstantReelSection:AddToggle({
    Name = "Anti-Detection Mode",
    Default = true,
    Flag = "safemode",
    Save = true,
    Callback = function(Value)
        flags['safemode'] = Value
        InstantReel.setDetectionAvoidance(Value)
    end    
})

local TestButton = InstantReelSection:AddButton({
    Name = "🧪 Test Reel Access",
    Callback = function()
        InstantReel.printTestResults()
    end    
})

local StatsButton = InstantReelSection:AddButton({
    Name = "📊 Show Statistics",
    Callback = function()
        local stats = InstantReel.getStatistics()
        OrionLib:MakeNotification({
            Name = "📊 Instant Reel Stats",
            Content = string.format("Total: %d | Success: %d (%.1f%%) | Avg Time: %.2fs", 
                stats.totalReels, stats.successfulReels, stats.successRate, stats.averageTime),
            Time = 5
        })
    end    
})

local ResetStatsButton = InstantReelSection:AddButton({
    Name = "🔄 Reset Statistics", 
    Callback = function()
        InstantReel.resetStatistics()
        OrionLib:MakeNotification({
            Name = "🔄 Statistics Reset",
            Content = "All instant reel statistics have been reset.",
            Time = 3
        })
    end    
})

--// Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "🚀 Teleport",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Places Section
local PlacesSection = TeleportTab:AddSection({
    Name = "🗺️ Places"
})

local PlaceDropdown = PlacesSection:AddDropdown({
    Name = "Select Place",
    Default = "Moosewood",
    Options = TeleportSystem.getPlaceNames(),
    Callback = function(Value)
        local success, msg = TeleportSystem.teleportToPlace(Value)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Fish Areas Section
local FishAreasSection = TeleportTab:AddSection({
    Name = "🐟 Fish Areas"
})

local FishAreaDropdown = FishAreasSection:AddDropdown({
    Name = "Select Fish Area",
    Default = "Ocean",
    Options = TeleportSystem.getFishAreaNames(),
    Callback = function(Value)
        local success, msg = TeleportSystem.teleportToFishArea(Value)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// NPCs Section
local NPCsSection = TeleportTab:AddSection({
    Name = "👥 NPCs"
})

local NPCDropdown = NPCsSection:AddDropdown({
    Name = "Select NPC",
    Default = "Appraiser",
    Options = TeleportSystem.getNPCNames(),
    Callback = function(Value)
        local success, msg = TeleportSystem.teleportToNPC(Value)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Items Section
local ItemsSection = TeleportTab:AddSection({
    Name = "📦 Items & Rods"
})

local ItemDropdown = ItemsSection:AddDropdown({
    Name = "Select Item/Rod",
    Default = "Training Rod",
    Options = TeleportSystem.getItemNames(),
    Callback = function(Value)
        local success, msg = TeleportSystem.teleportToItem(Value)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Players Section
local PlayersSection = TeleportTab:AddSection({
    Name = "👤 Players"
})

local PlayerDropdown = PlayersSection:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = TeleportSystem.getPlayerList(),
    Callback = function(Value)
        if Value and Value ~= "" then
            local success, msg = TeleportSystem.teleportToPlayer(Value)
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg,
                Time = 3
            })
        end
    end    
})

PlayersSection:AddButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        local newPlayers = TeleportSystem.getPlayerList()
        PlayerDropdown:SetOptions(newPlayers)
        OrionLib:MakeNotification({
            Name = "🔄 Player List Updated",
            Content = "Found " .. #newPlayers .. " players online",
            Time = 2
        })
    end    
})

--// Quick Teleport Section  
local QuickTeleportSection = TeleportTab:AddSection({
    Name = "⚡ Quick Access"
})

QuickTeleportSection:AddButton({
    Name = "� Moosewood Docks",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Moosewood")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🌊 Deep Ocean",
    Callback = function()
        local success, msg = TeleportSystem.teleportToFishArea("Deep Ocean")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🍄 Mushgrove Swamp", 
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Mushgrove")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "🏝️ Roslit Bay",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Roslit Bay")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "❄️ Snowcap Island",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Snowcap Island")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

QuickTeleportSection:AddButton({
    Name = "� Merchant",
    Callback = function()
        local success, msg = TeleportSystem.teleportToNPC("Merchant")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Special Locations Section
local SpecialLocationsSection = TeleportTab:AddSection({
    Name = "⭐ Special Locations"
})

SpecialLocationsSection:AddButton({
    Name = "🕳️ The Depths",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("The Depths")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "💀 Forsaken Shores",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Forsaken Shores")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "🏔️ Vertigo",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Vertigo")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

SpecialLocationsSection:AddButton({
    Name = "🏛️ Ancient Isle",
    Callback = function()
        local success, msg = TeleportSystem.teleportToPlace("Ancient Isle")
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg,
            Time = 3
        })
    end    
})

--// Teleport Options Section
local TeleportOptionsSection = TeleportTab:AddSection({
    Name = "🔧 Teleport Options"
})

local TweenToggle = TeleportOptionsSection:AddToggle({
    Name = "Smooth Teleport (Tween)",
    Default = false,
    Flag = "smoothteleport",
    Save = true,
    Callback = function(Value)
        flags['smoothteleport'] = Value
    end    
})

--// Custom Teleport Section  
local CustomTeleportSection = TeleportTab:AddSection({
    Name = "📍 Custom Teleport"
})

local coordX = 0
local coordY = 134
local coordZ = 0

CustomTeleportSection:AddTextbox({
    Name = "X Coordinate",
    Default = "0",
    TextDisappear = false,
    Callback = function(Value)
        coordX = tonumber(Value) or 0
    end	  
})

CustomTeleportSection:AddTextbox({
    Name = "Y Coordinate", 
    Default = "134",
    TextDisappear = false,
    Callback = function(Value)
        coordY = tonumber(Value) or 134
    end	  
})

CustomTeleportSection:AddTextbox({
    Name = "Z Coordinate",
    Default = "0", 
    TextDisappear = false,
    Callback = function(Value)
        coordZ = tonumber(Value) or 0
    end	  
})

CustomTeleportSection:AddButton({
    Name = "🎯 Teleport to Coordinates",
    Callback = function()
        local success, msg = TeleportSystem.teleportToCoordinates(coordX, coordY, coordZ)
        OrionLib:MakeNotification({
            Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
            Content = msg or (success and string.format("Teleported to (%d, %d, %d)", coordX, coordY, coordZ) or "Failed to teleport to coordinates"),
            Time = 3
        })
    end    
})

--// Player Teleport Section
local PlayerTeleportSection = TeleportTab:AddSection({
    Name = "👥 Player Teleport"
})

local targetPlayer = ""

PlayerTeleportSection:AddTextbox({
    Name = "Player Name",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        targetPlayer = Value
    end	  
})

PlayerTeleportSection:AddButton({
    Name = "🏃 Teleport to Player",
    Callback = function()
        if targetPlayer ~= "" then
            local success, msg = TeleportSystem.teleportToPlayer(targetPlayer)
            OrionLib:MakeNotification({
                Name = success and "✅ Teleport Success" or "❌ Teleport Failed",
                Content = msg or (success and "Teleported to " .. targetPlayer or "Failed to find player: " .. targetPlayer),
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "⚠️ Warning",
                Content = "Please enter a player name first",
                Time = 3
            })
        end
    end    
})

--// Teleport Utilities Section
local TeleportUtilitiesSection = TeleportTab:AddSection({
    Name = "🛠️ Teleport Utilities"
})

TeleportUtilitiesSection:AddButton({
    Name = "💾 Save Current Location",
    Callback = function()
        local locationName = "CustomLocation_" .. os.time()
        local success, msg = TeleportSystem.saveCurrentLocation(locationName)
        OrionLib:MakeNotification({
            Name = success and "✅ Location Saved" or "❌ Save Failed",
            Content = msg or (success and "Location saved as: " .. locationName or "Failed to save current location"),
            Time = 3
        })
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🔙 Return to Last Position",
    Callback = function()
        if TeleportSystem.returnToLastPosition then
            local success = TeleportSystem.returnToLastPosition()
            OrionLib:MakeNotification({
                Name = success and "✅ Returned" or "❌ Return Failed",
                Content = success and "Returned to last position" or "Failed to return to last position",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "⚠️ Warning",
                Content = "Auto-return not enabled or no previous position saved",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🧪 Test Teleport Methods",
    Callback = function()
        if TeleportSystem and TeleportSystem.testConnections then
            local results = TeleportSystem.testConnections()
            local status = ""
            for method, available in pairs(results) do
                status = status .. method .. ": " .. (available and "✅" or "❌") .. "\n"
            end
            OrionLib:MakeNotification({
                Name = "🧪 Teleport Test Results",
                Content = status,
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Test Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "📊 Show Teleport Stats",
    Callback = function()
        if TeleportSystem and TeleportSystem.getStatistics then
            local stats = TeleportSystem.getStatistics()
            OrionLib:MakeNotification({
                Name = "📊 Teleport Statistics",
                Content = string.format("Total: %d | Success: %d (%.1f%%) | Favorite: %s", 
                    stats.totalTeleports, stats.successfulTeleports, stats.successRate, stats.favoriteLocation),
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Stats Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
    end    
})

TeleportUtilitiesSection:AddButton({
    Name = "🔄 Reset Teleport Stats",
    Callback = function()
        if TeleportSystem and TeleportSystem.resetStatistics then
            TeleportSystem.resetStatistics()
            OrionLib:MakeNotification({
                Name = "🔄 Statistics Reset",
                Content = "All teleport statistics have been reset.",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Reset Failed",
                Content = "TeleportSystem not available",
                Time = 3
            })
        end
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

InfoSection:AddLabel("Script Version: 1.5")
InfoSection:AddLabel("Created for: Roblox Fisch")
InfoSection:AddLabel("Status: ✅ Active")
InfoSection:AddLabel("New: Teleport System with multiple methods!")
InfoSection:AddLabel("New: Auto Shake V2 (Invisible) feature!")
InfoSection:AddLabel("New: Auto Drop Bobber feature added!")

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
                if flags['instantreel'] then
                    InstantReel.performReel()
                else
                    wait(0.5)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        elseif flags['instantreel'] then
            -- Standalone Instant Reel (without Auto Reel)
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value >= 50 then
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
    Name = "🎣 Auto Fishing Pro v1.5",
    Content = "Script loaded with Teleport System! Explore 10+ fishing locations with advanced teleport methods.",
    Image = "rbxassetid://4483345875",
    Time = 5
})

-- Instant Reel startup notification
spawn(function()
    wait(2)
    OrionLib:MakeNotification({
        Name = "⚡ Instant Reel Module",
        Content = "Advanced instant reel system loaded! Check the new Instant Reel section.",
        Time = 4
    })
end)

-- Auto Drop Bobber notification
spawn(function()
    wait(4)
    OrionLib:MakeNotification({
        Name = "🎣 Auto Drop Bobber",
        Content = "New feature! Automatically drops and recasts bobber when no fish bites. Configure time in settings.",
        Time = 5
    })
end)

print("🎣 Auto Fishing Pro v1.5 - Script loaded successfully!")
print("⚡ Instant Reel Module - Loaded and ready!")
print("👻 Auto Shake V2 - Invisible ultra-fast shake system!")
print("🎣 Auto Drop Bobber - Automatically drops and recasts bobber!")
print("🚀 Teleport System - Advanced teleport with multiple methods!")
print("🎨 UI Library - OrionLib (ui.lua)")
print("📁 GitHub: https://github.com/MELLISAEFFENDY/apakah")
print("⚙️ Version: 1.5")
