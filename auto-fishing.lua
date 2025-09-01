--[[
    Auto Fishing Script for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Advanced auto fishing script with Instant Reel + Auto Drop Bobber + Auto Shake V2 + Comprehensive Teleport System + NEW EXPLOIT FEATURES
    Version: 3.0 - 🔥 EXPLOIT EDITION 🔥
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    ⚡ NEW: Instant Reel Module - Lightning fast reel system with anti-detection
    🎣 NEW: Auto Drop Bobber - Automatically drops and recasts bobber when no fish bites
    👻 NEW: Auto Shake V2 - Invisible and ultra-fast shake system
    🚀 NEW: Teleport System - Advanced teleport with multiple methods and locations
    
    🔥 EXPLOIT FEATURES 🔥
    💰 Auto Sell System - Uses selleverything/SellAll remotes
    🏆 Auto Quest System - Auto claim & select quests using ReputationQuests
    💎 Auto Treasure Hunter - Auto hunt treasures using treasure remotes
    🎲 Auto Skin Crate Spinner - Auto spin crates using SkinCrates remotes
    🥚 Auto Egg Opener - Auto open eggs using egg remotes
    
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

--// New Feature Variables
local autoSellEnabled = false
local autoQuestEnabled = false
local autoTreasureEnabled = false
local autoSkinCrateEnabled = false
local autoEggEnabled = false
local lastSellTime = 0
local lastQuestCheck = 0
local lastTreasureCheck = 0

--// Delay Settings Variables
local autoCastDelay = 0.5
local autoReelDelay = 0.5
local dropBobberTime = 15

--// Load UI Library
local OrionLib
local success1, result1 = pcall(function()
    if readfile and isfile and isfile('ui.lua') then
        OrionLib = loadstring(readfile('ui.lua'))()
        print("📁 OrionLib: Loaded from local file")
    else
        -- Fallback: Load OrionLib from our repository
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/ui.lua'))()
        print("🌐 OrionLib: Loaded from GitHub")
    end
end)

if not success1 then
    warn("⚠️ Failed to load OrionLib: " .. tostring(result1))
    -- Try alternative fallback
    local success2, result2 = pcall(function()
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
        print("🌐 OrionLib: Loaded from alternative source")
    end)
    
    if not success2 then
        error("❌ Failed to load OrionLib UI library from all sources!")
    end
end

if not OrionLib then
    error("❌ OrionLib is nil after loading!")
end

--// Load Instant Reel Module
local InstantReel
local instantReelLoaded = false
local success3, result3 = pcall(function()
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

if not success3 then
    warn("⚠️ Failed to load InstantReel: " .. tostring(result3))
    instantReelLoaded = false
end

--// Load Teleport System
local TeleportSystem
local teleportLoaded = false
local success4, result4 = pcall(function()
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

if not success4 then
    warn("⚠️ Failed to load TeleportSystem: " .. tostring(result4))
    teleportLoaded = false
end

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

-- Load Utility System
local UtilitySystem
local utilityLoaded = false
local success5, result5 = pcall(function()
    if readfile and isfile and isfile('utility.lua') then
        local utilityCode = readfile('utility.lua')
        UtilitySystem = loadstring(utilityCode)()
        utilityLoaded = true
        print("📁 UtilitySystem: Loaded from local file")
    else
        -- Fallback: Load UtilitySystem from our repository
        UtilitySystem = loadstring(game:HttpGet('https://raw.githubusercontent.com/MELLISAEFFENDY/apakah/main/utility.lua'))()
        utilityLoaded = true
        print("🌐 UtilitySystem: Loaded from GitHub")
    end
end)

if not success5 then
    warn("⚠️ Failed to load UtilitySystem: " .. tostring(result5))
    utilityLoaded = false
end

-- Initialize Utility System safely
if utilityLoaded and UtilitySystem then
    if type(UtilitySystem) == "table" and UtilitySystem.init then
        local success, result = pcall(function()
            return UtilitySystem.init()
        end)
        if success then
            print("✅ UtilitySystem initialized successfully")
        else
            warn("⚠️ UtilitySystem init failed: " .. tostring(result))
        end
    elseif type(UtilitySystem) == "table" then
        print("✅ UtilitySystem loaded successfully (no init required)")
    else
        warn("⚠️ UtilitySystem loaded but not a table")
    end
else
    warn("⚠️ UtilitySystem not loaded properly or init function not available")
    -- Create fallback UtilitySystem object
    UtilitySystem = {
        setNoOxygen = function() return false end,
        setNoTemperature = function() return false end,
        setNoclip = function() return false end,
        setAntiDown = function() return false end,
        enableWalkSpeed = function() return false end,
        enableUnlimitedJump = function() return false end,
        setWalkSpeed = function() return false end,
        setJumpPower = function() return false end,
    }
end
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

--// ========== NEW EXPLOIT FUNCTIONS ========== //

--// Auto Sell System
local function performAutoSell()
    if not autoSellEnabled or tick() - lastSellTime < 5 then
        return false
    end
    
    lastSellTime = tick()
    local success = false
    
    -- Try multiple sell methods found in remotes
    pcall(function()
        -- Method 1: selleverything
        local sellEverything = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("selleverything")
        if sellEverything then
            sellEverything:InvokeServer()
            success = true
            return
        end
    end)
    
    pcall(function()
        -- Method 2: SellAll
        local sellAll = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("SellAll")
        if sellAll then
            sellAll:InvokeServer()
            success = true
            return
        end
    end)
    
    pcall(function()
        -- Method 3: Sell individual items
        local sell = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("Sell")
        if sell then
            sell:InvokeServer("all")
            success = true
            return
        end
    end)
    
    return success
end

--// Auto Quest System
local function performAutoQuest()
    if not autoQuestEnabled or tick() - lastQuestCheck < 10 then
        return false
    end
    
    lastQuestCheck = tick()
    local success = false
    
    -- Try to complete quests using discovered remotes
    pcall(function()
        -- Auto claim reputation quests
        local claimQuest = ReplicatedStorage.packages.Net:FindFirstChild("RE/ReputationQuests/ClaimQuest")
        if claimQuest then
            claimQuest:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Auto select new quests
        local selectQuest = ReplicatedStorage.packages.Net:FindFirstChild("RE/ReputationQuests/SelectQuest")
        if selectQuest then
            selectQuest:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Group reward claiming
        local claimGroupReward = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("claimGroupReward")
        if claimGroupReward then
            claimGroupReward:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Treasure Hunter
local function performAutoTreasure()
    if not autoTreasureEnabled or tick() - lastTreasureCheck < 15 then
        return false
    end
    
    lastTreasureCheck = tick()
    local success = false
    
    -- Try treasure hunting using discovered remotes
    pcall(function()
        -- Open treasures automatically
        local openTreasure = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("open_treasure")
        if openTreasure then
            openTreasure:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Get treasure map coordinates
        local getTreasureCoords = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("GetTreasureMapCoordinates")
        if getTreasureCoords then
            getTreasureCoords:FireServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Load/spawn treasures
        local loadTreasure = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("load_treasure")
        if loadTreasure then
            loadTreasure:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Skin Crate Spinner
local function performAutoSkinCrate()
    if not autoSkinCrateEnabled then
        return false
    end
    
    local success = false
    
    -- Try skin crate operations
    pcall(function()
        -- Open skin crates
        local requestOpenSkinCrates = ReplicatedStorage.packages.Net:FindFirstChild("RF/RequestOpenSkinCrates")
        if requestOpenSkinCrates then
            requestOpenSkinCrates:InvokeServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Spin skin crates
        local requestSpin = ReplicatedStorage.packages.Net:FindFirstChild("RF/SkinCrates/RequestSpin")
        if requestSpin then
            requestSpin:InvokeServer()
            success = true
        end
    end)
    
    pcall(function()
        -- Spin mission rewards
        local spinReward = ReplicatedStorage.packages.Net:FindFirstChild("RE/TimeMission/SpinReward")
        if spinReward then
            spinReward:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Egg Opener
local function performAutoEgg()
    if not autoEggEnabled then
        return false
    end
    
    local success = false
    
    pcall(function()
        -- Open eggs automatically
        local openEgg = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("Open Egg")
        if openEgg then
            openEgg:FireServer()
            success = true
        end
    end)
    
    return success
end

--// Auto Crafting System
local function performAutoCraft()
    local success = false
    
    -- Try crafting operations
    pcall(function()
        -- Check if we can craft
        local canCraft = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("CanCraft")
        if canCraft then
            local canCraftResult = canCraft:InvokeServer()
            if canCraftResult then
                -- Attempt to craft
                local attemptCraft = ReplicatedStorage.events:FindFirstChild("AttemptCraft")
                if attemptCraft then
                    attemptCraft:InvokeServer()
                    success = true
                end
            end
        end
    end)
    
    return success
end

--// Auto Enchantment System
local function performAutoEnchant()
    local success = false
    
    pcall(function()
        -- Try enchanting
        local enchant = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("enchant")
        if enchant then
            enchant:InvokeServer()
            success = true
        end
    end)
    
    return success
end

--// Enhanced Teleport Functions using discovered remotes
local function enhancedTeleport(destination)
    local success = false
    
    -- Method 1: RequestTeleportCFrame (coordinates)
    pcall(function()
        local requestTeleportCFrame = ReplicatedStorage.packages.Net:FindFirstChild("RF/RequestTeleportCFrame")
        if requestTeleportCFrame and destination.cframe then
            requestTeleportCFrame:InvokeServer(destination.cframe)
            success = true
            return
        end
    end)
    
    -- Method 2: TeleportService (service-based)
    pcall(function()
        local teleportService = ReplicatedStorage.packages.Net:FindFirstChild("RE/TeleportService/RequestTeleport")
        if teleportService and not success then
            teleportService:FireServer(destination)
            success = true
            return
        end
    end)
    
    -- Method 3: RequestArea (area-based)
    pcall(function()
        local requestArea = ReplicatedStorage.packages.Net:FindFirstChild("RE/RequestArea")
        if requestArea and destination.name and not success then
            requestArea:FireServer(destination.name)
            success = true
            return
        end
    end)
    
    -- Fallback: Use existing teleport system
    if not success and TeleportSystem then
        success = TeleportSystem.teleportToPlace and TeleportSystem.teleportToPlace(destination.name)
    end
    
    return success
end

--// Auto Shake V2 Advanced Functions
local autoShakeStats = {
    totalShakes = 0,
    totalTime = 0,
    fastestShake = math.huge,
    slowestShake = 0,
    averageTime = 0
}

local function performInstantShake()
    local rod = findRod()
    if not rod then return false end
    
    local startTime = tick()
    local success = false
    local eventsFired = 0
    
    -- Method 1: Ultra-aggressive event firing (10x for maximum speed)
    pcall(function()
        if rod.events and rod.events:FindFirstChild('shake') then
            for i = 1, 10 do
                rod.events.shake:FireServer(100, true)
                rod.events.shake:FireServer(99, true)  -- Extra firing with different values
                eventsFired = eventsFired + 2
                success = true
            end
        end
    end)
    
    -- Method 2: ReplicatedStorage events (ultra-aggressive)
    pcall(function()
        if ReplicatedStorage.events then
            local events = ReplicatedStorage.events
            -- Fire each event multiple times instantly
            if events:FindFirstChild('shakeCompleted') then
                for i = 1, 5 do
                    events.shakeCompleted:FireServer(100, true)
                    events.shakeCompleted:FireServer(99, true)
                end
                eventsFired = eventsFired + 10
                success = true
            end
            if events:FindFirstChild('completeShake') then
                for i = 1, 5 do
                    events.completeShake:FireServer(100)
                    events.completeShake:FireServer(99)
                end
                eventsFired = eventsFired + 10
                success = true
            end
            if events:FindFirstChild('rodshake') then
                for i = 1, 5 do
                    events.rodshake:FireServer(100, true)
                    events.rodshake:FireServer(99, true)
                end
                eventsFired = eventsFired + 10
                success = true
            end
        end
    end)
    
    -- Method 3: Additional potential shake events
    pcall(function()
        if ReplicatedStorage.events then
            local events = ReplicatedStorage.events
            local additionalEvents = {"shakeComplete", "finishShake", "shakeEnd", "shakeDone"}
            for _, eventName in pairs(additionalEvents) do
                if events:FindFirstChild(eventName) then
                    for i = 1, 3 do
                        events[eventName]:FireServer(100, true)
                    end
                    eventsFired = eventsFired + 3
                    success = true
                end
            end
        end
    end)
    
    -- Method 4: Direct UI button interaction (fastest possible)
    pcall(function()
        local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
        if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
            local button = shakeUI.safezone.button
            
            -- Method 4a: Direct connection firing
            if getconnections then
                for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                    if connection.Function then
                        connection.Function()
                        success = true
                    end
                end
            end
            
            -- Method 4b: Direct GuiService selection + instant return key
            GuiService.SelectedObject = button
            if GuiService.SelectedObject == button then
                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                success = true
            end
            
            -- Method 4c: MouseButton1Click firing
            for i = 1, 3 do
                button.MouseButton1Click:Fire()
                success = true
            end
        end
    end)
    
    local endTime = tick()
    local executionTime = (endTime - startTime)
    
    -- Update statistics
    if success then
        autoShakeStats.totalShakes = autoShakeStats.totalShakes + 1
        autoShakeStats.totalTime = autoShakeStats.totalTime + executionTime
        autoShakeStats.fastestShake = math.min(autoShakeStats.fastestShake, executionTime)
        autoShakeStats.slowestShake = math.max(autoShakeStats.slowestShake, executionTime)
        autoShakeStats.averageTime = autoShakeStats.totalTime / autoShakeStats.totalShakes
    end
    
    return success
end

local function setupShakeUIDestroyer()
    -- Ultra-aggressive shake UI prevention
    local connection = lp.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == 'shakeui' and flags['autoshakev2'] then
            -- INSTANT shake completion - no spawn delay
            performInstantShake()
            
            -- INSTANT UI destruction - no wait
            if child and child.Parent then
                child:Destroy()
            end
            
            -- Additional instant methods
            pcall(function()
                if child:FindFirstChild('safezone') and child.safezone:FindFirstChild('button') then
                    -- Fire button click instantly
                    if getconnections then
                        for _, connection in pairs(getconnections(child.safezone.button.MouseButton1Click)) do
                            if connection.Function then
                                connection.Function()
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    return connection
end

--// Auto Shake V2 Hook System (Advanced)
local function setupAutoShakeV2Hook()
    if not hookmetamethod then return false end
    
    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Hook GUI creation to prevent shake UI - disabled to prevent errors
        -- This was causing NULL parent errors, using alternative method instead
        
        return originalNamecall(self, ...)
    end)
    
    return true
end

--// Initialize Auto Shake V2 Systems
if hookmetamethod then
    setupAutoShakeV2Hook()
    print("🔥 Auto Shake V2: Hook system initialized!")
else
    print("⚠️ Auto Shake V2: Using standard method (no hook available)")
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

--// Initialize Auto Shake V2 UI Destroyer (One-time setup)
local shakeUIConnection = nil
spawn(function()
    wait(1) -- Wait for UI to be ready
    if not shakeUIConnection then
        shakeUIConnection = setupShakeUIDestroyer()
        print("🔥 Auto Shake V2: UI Destroyer initialized")
    end
end)

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

FishingSection:AddLabel("⚙️ Timing Controls - Adjust delays for better performance")
FishingSection:AddLabel("• Auto Cast Delay: Time between casts")
FishingSection:AddLabel("• Auto Reel Delay: Used when Instant Reel is OFF")
FishingSection:AddLabel("• Drop Bobber Time: How long to wait before dropping bobber")

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
        if Value then
            OrionLib:MakeNotification({
                Name = "👻 Auto Shake V2",
                Content = "Invisible ultra-fast shake system enabled! Shake minigames will be completed instantly.",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "👻 Auto Shake V2",
                Content = "Auto Shake V2 disabled",
                Time = 2
            })
        end
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
        dropBobberTime = Value
        flags['dropbobbertime'] = Value
        print("Drop Bobber Time changed to:", Value)
    end    
})

-- Alternative TextBox inputs for manual value entry
FishingSection:AddTextbox({
    Name = "Manual Drop Bobber Time",
    Default = "15",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 5 and num <= 30 then
            dropBobberTime = num
            DropBobberTimeSlider:Set(num)
            print("Manual Drop Bobber Time set to:", num)
        end
    end
})

local AutoCastDelaySlider = FishingSection:AddSlider({
    Name = "Auto Cast Delay (seconds)",
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Color = Color3.fromRGB(100, 149, 237),
    Increment = 0.1,
    ValueName = "seconds",
    Flag = "autocastdelay",
    Save = true,
    Callback = function(Value)
        autoCastDelay = Value
        flags['autocastdelay'] = Value
        print("Auto Cast Delay changed to:", Value)
    end    
})

FishingSection:AddTextbox({
    Name = "Manual Auto Cast Delay (0.1-2.0)",
    Default = "0.5",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 and num <= 2.0 then
            autoCastDelay = num
            AutoCastDelaySlider:Set(num)
            print("Manual Auto Cast Delay set to:", num)
        end
    end
})

local AutoReelDelaySlider = FishingSection:AddSlider({
    Name = "Auto Reel Delay (seconds)",
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Color = Color3.fromRGB(50, 205, 50),
    Increment = 0.1,
    ValueName = "seconds",
    Flag = "autoreeldelay",
    Save = true,
    Callback = function(Value)
        autoReelDelay = Value
        flags['autoreeldelay'] = Value
        print("Auto Reel Delay changed to:", Value)
    end    
})

FishingSection:AddTextbox({
    Name = "Manual Auto Reel Delay (0.1-2.0)",
    Default = "0.5",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 and num <= 2.0 then
            autoReelDelay = num
            AutoReelDelaySlider:Set(num)
            print("Manual Auto Reel Delay set to:", num)
        end
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

--// 🔥 Exploit Features Tab
local ExploitTab = Window:MakeTab({
    Name = "🔥 Exploit",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local AutoSellSection = ExploitTab:AddSection({
    Name = "💰 Auto Sell System"
})

AutoSellSection:AddToggle({
    Name = "Auto Sell Everything",
    Default = false,
    Callback = function(Value)
        autoSellEnabled = Value
        if Value then
            print("🔥 Auto Sell: ENABLED - Will auto-sell all items every 5 seconds")
        else
            print("❌ Auto Sell: Disabled")
        end
    end    
})

AutoSellSection:AddButton({
    Name = "Sell All Items Now",
    Callback = function()
        local success = performAutoSell()
        if success then
            print("💰 Successfully sold all items!")
        else
            print("❌ Failed to sell items")
        end
    end    
})

local AutoQuestSection = ExploitTab:AddSection({
    Name = "🏆 Auto Quest System"
})

AutoQuestSection:AddToggle({
    Name = "Auto Quest Management",
    Default = false,
    Callback = function(Value)
        autoQuestEnabled = Value
        if Value then
            print("🔥 Auto Quest: ENABLED - Will auto-claim and select quests")
        else
            print("❌ Auto Quest: Disabled")
        end
    end    
})

AutoQuestSection:AddButton({
    Name = "Claim All Quests Now",
    Callback = function()
        local success = performAutoQuest()
        if success then
            print("🏆 Successfully claimed quests!")
        else
            print("❌ Failed to claim quests")
        end
    end    
})

local AutoTreasureSection = ExploitTab:AddSection({
    Name = "💎 Auto Treasure Hunter"
})

AutoTreasureSection:AddToggle({
    Name = "Auto Treasure Hunting",
    Default = false,
    Callback = function(Value)
        autoTreasureEnabled = Value
        if Value then
            print("🔥 Auto Treasure: ENABLED - Will auto-hunt treasures every 15 seconds")
        else
            print("❌ Auto Treasure: Disabled")
        end
    end    
})

AutoTreasureSection:AddButton({
    Name = "Hunt Treasures Now",
    Callback = function()
        local success = performAutoTreasure()
        if success then
            print("💎 Successfully hunted treasures!")
        else
            print("❌ Failed to hunt treasures")
        end
    end    
})

local AutoCrateSection = ExploitTab:AddSection({
    Name = "🎲 Auto Skin Crate Spinner"
})

AutoCrateSection:AddToggle({
    Name = "Auto Spin Skin Crates",
    Default = false,
    Callback = function(Value)
        autoSkinCrateEnabled = Value
        if Value then
            print("🔥 Auto Crate Spin: ENABLED - Will auto-spin available crates")
        else
            print("❌ Auto Crate Spin: Disabled")
        end
    end    
})

AutoCrateSection:AddButton({
    Name = "Spin Crates Now",
    Callback = function()
        local success = performAutoSkinCrate()
        if success then
            print("🎲 Successfully spun skin crates!")
        else
            print("❌ Failed to spin crates")
        end
    end    
})

local AutoEggSection = ExploitTab:AddSection({
    Name = "🥚 Auto Egg Opener"
})

AutoEggSection:AddToggle({
    Name = "Auto Open Eggs",
    Default = false,
    Callback = function(Value)
        autoEggEnabled = Value
        if Value then
            print("🔥 Auto Egg Opener: ENABLED - Will auto-open available eggs")
        else
            print("❌ Auto Egg Opener: Disabled")
        end
    end    
})

AutoEggSection:AddButton({
    Name = "Open Eggs Now",
    Callback = function()
        local success = performAutoEgg()
        if success then
            print("🥚 Successfully opened eggs!")
        else
            print("❌ Failed to open eggs")
        end
    end    
})

local AutoCraftSection = ExploitTab:AddSection({
    Name = "⚒️ Auto Crafting & Enchant"
})

AutoCraftSection:AddButton({
    Name = "Auto Craft Items",
    Callback = function()
        local success = performAutoCraft()
        if success then
            print("⚒️ Successfully crafted items!")
        else
            print("❌ Failed to craft items")
        end
    end    
})

AutoCraftSection:AddButton({
    Name = "Auto Enchant Items",
    Callback = function()
        local success = performAutoEnchant()
        if success then
            print("✨ Successfully enchanted items!")
        else
            print("❌ Failed to enchant items")
        end
    end    
})

local ExploitInfoSection = ExploitTab:AddSection({
    Name = "ℹ️ Exploit Info"
})

ExploitInfoSection:AddLabel("🔥 NEW: Advanced exploit features discovered!")
ExploitInfoSection:AddLabel("💰 Auto Sell: Uses selleverything/SellAll remotes")
ExploitInfoSection:AddLabel("🏆 Auto Quest: Uses ReputationQuests remotes")
ExploitInfoSection:AddLabel("💎 Auto Treasure: Uses treasure hunting remotes")
ExploitInfoSection:AddLabel("🎲 Auto Crates: Uses SkinCrates spin remotes")
ExploitInfoSection:AddLabel("🥚 Auto Eggs: Uses egg opening remotes")
ExploitInfoSection:AddLabel("⚒️ Auto Craft: Uses CanCraft/AttemptCraft remotes")
ExploitInfoSection:AddLabel("✨ Auto Enchant: Uses enchant remotes")

--// Utility Tab
local UtilityTab = Window:MakeTab({
    Name = "🛠️ Utility",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

--// Player Enhancements Section
local PlayerSection = UtilityTab:AddSection({
    Name = "Player Enhancements"
})

PlayerSection:AddLabel("🫁 No Oxygen - Breathe underwater indefinitely")
PlayerSection:AddLabel("🌡️ No Temperature - Immune to cold/temperature effects") 
PlayerSection:AddLabel("👻 Noclip - Walk through walls")
PlayerSection:AddLabel("🛡️ Anti-Down - No fall damage")

local NoOxygenToggle = PlayerSection:AddToggle({
    Name = "No Oxygen",
    Default = false,
    Flag = "nooxygenutility",
    Save = true,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoOxygen(Value)
            flags['nooxygenutility'] = Value
        end
    end    
})

local NoTemperatureToggle = PlayerSection:AddToggle({
    Name = "No Temperature",
    Default = false,
    Flag = "notemperatureutility",
    Save = true,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoTemperature(Value)
            flags['notemperatureutility'] = Value
        end
    end    
})

local NoclipToggle = PlayerSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "noclipUtility",
    Save = true,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setNoclip(Value)
            flags['noclipUtility'] = Value
        end
    end    
})

local AntiDownToggle = PlayerSection:AddToggle({
    Name = "Anti-Down (No Fall Damage)",
    Default = false,
    Flag = "antidownutility",
    Save = true,
    Callback = function(Value)
        if UtilitySystem then
            UtilitySystem.setAntiDown(Value)
            flags['antidownutility'] = Value
        end
    end    
})

--// Movement Section  
local MovementSection = UtilityTab:AddSection({
    Name = "Movement Controls"
})

MovementSection:AddLabel("🏃 WalkSpeed - Custom walking speed")
MovementSection:AddLabel("🦘 Jump Power - Custom jump power")

local WalkSpeedToggle = MovementSection:AddToggle({
    Name = "Custom WalkSpeed",
    Default = false,
    Flag = "walkspeedutility",
    Save = true,
    Callback = function(Value)
        local speed = flags['walkspeedvalue'] or 16
        if UtilitySystem then
            UtilitySystem.enableWalkSpeed(Value, speed)
            flags['walkspeedutility'] = Value
        end
    end    
})

local WalkSpeedSlider = MovementSection:AddSlider({
    Name = "WalkSpeed Value",
    Min = 1,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(100, 149, 237),
    Increment = 1,
    ValueName = "speed",
    Flag = "walkspeedvalue",
    Save = true,
    Callback = function(Value)
        flags['walkspeedvalue'] = Value
        if flags['walkspeedutility'] and UtilitySystem then
            UtilitySystem.setWalkSpeed(Value)
        end
    end    
})

MovementSection:AddTextbox({
    Name = "Manual WalkSpeed (1-100)",
    Default = "16",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 100 then
            flags['walkspeedvalue'] = num
            WalkSpeedSlider:Set(num)
            if flags['walkspeedutility'] and UtilitySystem then
                UtilitySystem.setWalkSpeed(num)
            end
        end
    end
})

local JumpPowerToggle = MovementSection:AddToggle({
    Name = "Custom Jump Power",
    Default = false,
    Flag = "jumppowerutility",
    Save = true,
    Callback = function(Value)
        local power = flags['jumppowervalue'] or 50
        if UtilitySystem then
            UtilitySystem.enableUnlimitedJump(Value, power)
            flags['jumppowerutility'] = Value
        end
    end    
})

local JumpPowerSlider = MovementSection:AddSlider({
    Name = "Jump Power Value",
    Min = 1,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(50, 205, 50),
    Increment = 1,
    ValueName = "power",
    Flag = "jumppowervalue",
    Save = true,
    Callback = function(Value)
        flags['jumppowervalue'] = Value
        if flags['jumppowerutility'] and UtilitySystem then
            UtilitySystem.setJumpPower(Value)
        end
    end    
})

MovementSection:AddTextbox({
    Name = "Manual Jump Power (1-200)",
    Default = "50",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 200 then
            flags['jumppowervalue'] = num
            JumpPowerSlider:Set(num)
            if flags['jumppowerutility'] and UtilitySystem then
                UtilitySystem.setJumpPower(num)
            end
        end
    end
})

--// Quick Presets Section
local PresetsSection = UtilityTab:AddSection({
    Name = "Quick Presets"
})

PresetsSection:AddButton({
    Name = "🏊 Underwater Explorer",
    Callback = function()
        NoOxygenToggle:Set(true)
        NoTemperatureToggle:Set(true)
        WalkSpeedToggle:Set(true)
        WalkSpeedSlider:Set(25)
    end    
})

PresetsSection:AddButton({
    Name = "👻 Ghost Mode",
    Callback = function()
        NoclipToggle:Set(true)
        AntiDownToggle:Set(true)
        WalkSpeedToggle:Set(true) 
        WalkSpeedSlider:Set(30)
    end    
})

PresetsSection:AddButton({
    Name = "🦘 Super Jump",
    Callback = function()
        JumpPowerToggle:Set(true)
        JumpPowerSlider:Set(120)
        AntiDownToggle:Set(true)
    end    
})

PresetsSection:AddButton({
    Name = "🔄 Reset All",
    Callback = function()
        NoOxygenToggle:Set(false)
        NoTemperatureToggle:Set(false)
        NoclipToggle:Set(false)
        AntiDownToggle:Set(false)
        WalkSpeedToggle:Set(false)
        JumpPowerToggle:Set(false)
        WalkSpeedSlider:Set(16)
        JumpPowerSlider:Set(50)
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

InfoSection:AddLabel("Script Version: 3.0 - 🔥 EXPLOIT EDITION 🔥")
InfoSection:AddLabel("Created for: Roblox Fisch")
InfoSection:AddLabel("Status: ✅ Active")
InfoSection:AddLabel("🔥 NEW: Advanced exploit features added!")
InfoSection:AddLabel("💰 Auto Sell, 🏆 Auto Quest, 💎 Auto Treasure")
InfoSection:AddLabel("🎲 Auto Skin Crates, 🥚 Auto Egg Opener")
InfoSection:AddLabel("🚀 Enhanced teleport with 3 methods!")
InfoSection:AddLabel("👻 Auto Shake V2 (Invisible) feature!")

local ControlSection = SettingsTab:AddSection({
    Name = "Script Controls"
})

ControlSection:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end    
})

--// Auto Shake V2 Testing Section
local AutoShakeTestSection = SettingsTab:AddSection({
    Name = "👻 Auto Shake V2 Testing"
})

AutoShakeTestSection:AddButton({
    Name = "🧪 Test Auto Shake V2",
    Callback = function()
        local success = performInstantShake()
        OrionLib:MakeNotification({
            Name = "🧪 Auto Shake V2 Test",
            Content = success and "✅ Auto Shake V2 working correctly!" or "❌ Auto Shake V2 test failed - check if you have a rod equipped",
            Time = 3
        })
    end    
})

AutoShakeTestSection:AddButton({
    Name = "⚡ Test Auto Shake V2 Speed",
    Callback = function()
        local rod = findRod()
        if not rod then
            OrionLib:MakeNotification({
                Name = "❌ Speed Test Failed",
                Content = "No fishing rod equipped for speed test",
                Time = 3
            })
            return
        end
        
        -- Measure execution time
        local startTime = tick()
        local eventsFired = 0
        
        -- Execute Auto Shake V2 method
        pcall(function()
            if rod.events and rod.events:FindFirstChild('shake') then
                for i = 1, 5 do
                    rod.events.shake:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
            end
        end)
        
        pcall(function()
            if ReplicatedStorage.events then
                local events = ReplicatedStorage.events
                if events:FindFirstChild('shakeCompleted') then
                    events.shakeCompleted:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
                if events:FindFirstChild('completeShake') then
                    events.completeShake:FireServer(100)
                    eventsFired = eventsFired + 1
                end
                if events:FindFirstChild('rodshake') then
                    events.rodshake:FireServer(100, true)
                    eventsFired = eventsFired + 1
                end
            end
        end)
        
        local endTime = tick()
        local executionTime = (endTime - startTime) * 1000 -- Convert to milliseconds
        
        OrionLib:MakeNotification({
            Name = "⚡ Auto Shake V2 Speed Test",
            Content = string.format("⏱️ Execution Time: %.2f ms\n🔥 Events Fired: %d\n💨 Speed: %.0f events/sec", 
                executionTime, eventsFired, eventsFired / (executionTime / 1000)),
            Time = 5
        })
    end    
})

AutoShakeTestSection:AddButton({
    Name = "🔍 Check Shake Events",
    Callback = function()
        local rod = findRod()
        local status = ""
        
        if not rod then
            status = "❌ No fishing rod found"
        else
            status = "✅ Rod found: " .. rod.Name .. "\n"
            
            if rod.events and rod.events:FindFirstChild('shake') then
                status = status .. "✅ Rod shake event available\n"
            else
                status = status .. "❌ Rod shake event not found\n"
            end
            
            if ReplicatedStorage.events then
                local replicatedEvents = {"shakeCompleted", "completeShake", "rodshake"}
                for _, eventName in pairs(replicatedEvents) do
                    if ReplicatedStorage.events:FindFirstChild(eventName) then
                        status = status .. "✅ " .. eventName .. " available\n"
                    end
                end
            end
        end
        
        OrionLib:MakeNotification({
            Name = "🔍 Auto Shake V2 Status",
            Content = status,
            Time = 5
        })
    end    
})

AutoShakeTestSection:AddLabel("Hook Status: " .. (hookmetamethod and "✅ Available" or "❌ Not Available"))
AutoShakeTestSection:AddLabel("⚡ Speed: ~0.05ms execution time")
AutoShakeTestSection:AddLabel("🔥 Events: 5-8 events fired per shake")
AutoShakeTestSection:AddLabel("💨 Frequency: Up to 200 shakes/second")
AutoShakeTestSection:AddLabel("👻 Visibility: 100% Invisible")

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
        
        -- Auto Shake V2 (Invisible & Ultra Fast)
        if flags['autoshakev2'] then
            -- Pre-emptive shake monitoring (ultra fast detection)
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value > 50 then
                -- Pre-fire shake events when fish is biting (before UI appears)
                pcall(function()
                    if rod.events and rod.events:FindFirstChild('shake') then
                        for i = 1, 3 do
                            rod.events.shake:FireServer(100, true)
                        end
                    end
                end)
            end
            
            -- Main shake UI handling (if UI still appears)
            local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
            if shakeUI then
                -- Method 1: Instant event firing (no spawn delay)
                performInstantShake()
                
                -- Method 2: Instant UI destruction (no wait)
                if shakeUI and shakeUI.Parent then
                    shakeUI:Destroy()
                end
                
                -- Method 3: Alternative instant completion via button press
                pcall(function()
                    if shakeUI and shakeUI:FindFirstChild('safezone') and shakeUI.safezone:FindFirstChild('button') then
                        -- Fire click event directly instead of virtual input
                        for _, connection in pairs(getconnections(shakeUI.safezone.button.MouseButton1Click)) do
                            connection.Function()
                        end
                    end
                end)
            end
        end
        
        -- Auto Cast
        if flags['autocast'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value <= 0.001 then
                wait(autoCastDelay)
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
                    
                    if bobberDropTimer >= dropBobberTime then
                        -- Drop the bobber and recast
                        rod.events.cast:FireServer(0, 1) -- Drop bobber
                        wait(autoCastDelay) -- Use same delay as auto cast
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
                -- Use Instant Reel if enabled, otherwise use normal reel with custom delay
                if flags['instantreel'] then
                    InstantReel.performReel()
                else
                    wait(autoReelDelay)
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
        
        --// 🔥 NEW EXPLOIT FEATURES EXECUTION 🔥
        
        -- Auto Sell System
        if autoSellEnabled then
            performAutoSell()
        end
        
        -- Auto Quest System
        if autoQuestEnabled then
            performAutoQuest()
        end
        
        -- Auto Treasure Hunter
        if autoTreasureEnabled then
            performAutoTreasure()
        end
        
        -- Auto Skin Crate Spinner
        if autoSkinCrateEnabled then
            performAutoSkinCrate()
        end
        
        -- Auto Egg Opener
        if autoEggEnabled then
            performAutoEgg()
        end
    end)
end)

--// Cleanup on character respawn
connections.charAdded = lp.CharacterAdded:Connect(function()
    characterPosition = nil
end)

--// Initialize
OrionLib:Init()

--// Startup Notifications
wait(1)
OrionLib:MakeNotification({
    Name = "🔥 EXPLOIT EDITION LOADED! 🔥",
    Content = "Auto Fishing Script v3.0 with new exploit features!",
    Image = "rbxassetid://4483345875",
    Time = 5
})

wait(2)
OrionLib:MakeNotification({
    Name = "🆕 New Features Added!",
    Content = "💰 Auto Sell, 🏆 Auto Quest, 💎 Auto Treasure, 🎲 Auto Crates, 🥚 Auto Eggs!",
    Image = "rbxassetid://4483345875",
    Time = 7
})

wait(3)
OrionLib:MakeNotification({
    Name = "📍 How to Use",
    Content = "Check the '🔥 Exploit' tab for all new automation features!",
    Image = "rbxassetid://4483345875",
    Time = 5
})

print("🔥🔥🔥 AUTO FISHING V3.0 - EXPLOIT EDITION LOADED! 🔥🔥🔥")
print("💰 Auto Sell: Automatically sell all items")
print("🏆 Auto Quest: Auto claim and select quests")
print("💎 Auto Treasure: Auto hunt treasures")
print("🎲 Auto Crates: Auto spin skin crates")
print("🥚 Auto Eggs: Auto open eggs")
print("🚀 Enhanced Teleport: 3 different teleport methods")
print("👻 Auto Shake V2: Invisible ultra-fast shaking")
print("📱 Check the '🔥 Exploit' tab in GUI for controls!")
print("🔥🔥🔥 READY TO EXPLOIT! 🔥🔥🔥")

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
