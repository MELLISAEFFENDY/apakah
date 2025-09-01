--[[
    Auto Fishing Script for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Advanced auto fishing script with comprehensive features
    Version: 1.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
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

--// Load UI Library
local OrionLib
if readfile and isfile and isfile('ui.lua') then
    OrionLib = loadstring(readfile('ui.lua'))()
else
    OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
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

CharacterSection:AddToggle({
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

FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = false,
    Flag = "autocast",
    Save = true,
    Callback = function(Value)
        flags['autocast'] = Value
    end    
})

FishingSection:AddToggle({
    Name = "Auto Shake",
    Default = false,
    Flag = "autoshake",
    Save = true,
    Callback = function(Value)
        flags['autoshake'] = Value
    end    
})

FishingSection:AddToggle({
    Name = "Auto Reel",
    Default = false,
    Flag = "autoreel",
    Save = true,
    Callback = function(Value)
        flags['autoreel'] = Value
    end    
})

--// Enhancement Section
local EnhancementSection = AutoFishingTab:AddSection({
    Name = "Fishing Enhancements"
})

if checkFunc(hookmetamethod) then
    EnhancementSection:AddToggle({
        Name = "Perfect Cast",
        Default = false,
        Flag = "perfectcast",
        Save = true,
        Callback = function(Value)
            flags['perfectcast'] = Value
        end    
    })

    EnhancementSection:AddToggle({
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

--// Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})

local InfoSection = SettingsTab:AddSection({
    Name = "Script Information"
})

InfoSection:AddLabel("Script Version: 1.0")
InfoSection:AddLabel("Created for: Roblox Fisch")
InfoSection:AddLabel("Status: ✅ Active")

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
        
        -- Auto Cast
        if flags['autocast'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value <= 0.001 then
                wait(0.5)
                rod.events.cast:FireServer(100, 1)
            end
        end
        
        -- Auto Reel
        if flags['autoreel'] then
            local rod = findRod()
            if rod and rod.values and rod.values.lure.Value == 100 then
                wait(0.5)
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
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
    Name = "🎣 Auto Fishing Pro",
    Content = "Script loaded successfully! Ready to fish automatically.",
    Image = "rbxassetid://4483345875",
    Time = 5
})

print("🎣 Auto Fishing Pro - Script loaded successfully!")
print("📁 GitHub: https://github.com/MELLISAEFFENDY/apakah")
print("⚙️ Version: 1.0")
