--[[
    Enhanced FPS Booster Module
    Based on Space Hub FPS Booster with improvements
    Safe FPS optimization without white screen issues
    
    Usage:
    local FPSBooster = loadstring(readfile('fps-booster.lua'))()
    FPSBooster.enable() -- Enable FPS boost
    FPSBooster.disable() -- Disable FPS boost
]]

local FPSBooster = {}

-- Configuration
local Settings = {
    Players = {
        ["Ignore Me"] = true, -- Ignore your Character
        ["Ignore Others"] = true, -- Ignore other Characters
        ["Ignore Tools"] = true -- Ignore tools
    },
    Meshes = {
        Destroy = false, -- Destroy Meshes
        LowDetail = true, -- Low detail meshes
        NoTexture = false, -- Remove textures
        NoMesh = false -- Remove mesh
    },
    Images = {
        Invisible = false, -- Make images invisible (safer: false)
        LowDetail = true, -- Low detail images
        Destroy = false, -- Destroy Images
    },
    Particles = {
        Invisible = true, -- Disable particles
        Destroy = false -- Destroy particles
    },
    Other = {
        ["No Camera Effects"] = true, -- Disables all PostEffect's
        ["No Explosions"] = true, -- Makes Explosion's invisible
        ["No Clothes"] = false, -- Removes Clothing (safer: false)
        ["Low Water Graphics"] = true, -- Removes Water Quality
        ["No Shadows"] = true, -- Remove Shadows
        ["Low Rendering"] = true, -- Lower Rendering
        ["Low Quality Parts"] = true, -- Lower quality parts
        ["Low Quality Models"] = true, -- Lower quality models
        ["Reset Materials"] = true, -- Reset materials
        ["FPS Cap"] = 240 -- FPS cap (240 for stability)
    }
}

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local MaterialService = game:GetService("MaterialService")
local StarterGui = game:GetService("StarterGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Connections = {}
local OriginalSettings = {}
local IsEnabled = false

-- Utility Functions
local function isPlayerCharacter(instance)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and instance:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function shouldIgnore(instance)
    -- Ignore player characters if settings say so
    if Settings.Players["Ignore Me"] and LocalPlayer.Character and instance:IsDescendantOf(LocalPlayer.Character) then
        return true
    end
    
    if Settings.Players["Ignore Others"] and isPlayerCharacter(instance) and 
       LocalPlayer.Character and not instance:IsDescendantOf(LocalPlayer.Character) then
        return true
    end
    
    if Settings.Players["Ignore Tools"] and (instance:IsA("Tool") or instance:FindFirstAncestorWhichIsA("Tool")) then
        return true
    end
    
    return false
end

local function optimizeInstance(instance)
    if shouldIgnore(instance) then
        return
    end
    
    pcall(function()
        if instance:IsA("DataModelMesh") then
            if Settings.Meshes.NoMesh and instance:IsA("SpecialMesh") then
                instance.MeshId = ""
            end
            if Settings.Meshes.NoTexture and instance:IsA("SpecialMesh") then
                instance.TextureId = ""
            end
            if Settings.Meshes.Destroy then
                instance:Destroy()
            end
        elseif instance:IsA("FaceInstance") then
            if Settings.Images.Invisible then
                instance.Transparency = 1
                instance.Shiny = 1
            end
            if Settings.Images.LowDetail then
                instance.Shiny = 1
            end
            if Settings.Images.Destroy then
                instance:Destroy()
            end
        elseif instance:IsA("ShirtGraphic") then
            if Settings.Images.Invisible then
                instance.Graphic = ""
            end
            if Settings.Images.Destroy then
                instance:Destroy()
            end
        elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or 
               instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") then
            if Settings.Particles.Invisible then
                instance.Enabled = false
            end
            if Settings.Particles.Destroy then
                instance:Destroy()
            end
        elseif instance:IsA("PostEffect") and Settings.Other["No Camera Effects"] then
            instance.Enabled = false
        elseif instance:IsA("Explosion") then
            if Settings.Other["No Explosions"] then
                instance.Visible = false
                instance.BlastPressure = 1
                instance.BlastRadius = 1
            end
        elseif (instance:IsA("Clothing") or instance:IsA("SurfaceAppearance") or instance:IsA("BaseWrap")) 
               and Settings.Other["No Clothes"] then
            instance:Destroy()
        elseif instance:IsA("BasePart") and not instance:IsA("MeshPart") and Settings.Other["Low Quality Parts"] then
            instance.Material = Enum.Material.Plastic
            instance.Reflectance = 0
            instance.CastShadow = false
        elseif instance:IsA("MeshPart") then
            instance.RenderFidelity = Enum.RenderFidelity.Performance
            instance.Reflectance = 0
            instance.Material = Enum.Material.Plastic
            instance.CastShadow = false
        elseif instance:IsA("Model") and Settings.Other["Low Quality Models"] then
            instance.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
        end
    end)
end

-- Main Functions
function FPSBooster.enable()
    if IsEnabled then
        return false, "FPS Booster already enabled"
    end
    
    -- Store original settings
    OriginalSettings = {
        QualityLevel = settings().Rendering.QualityLevel,
        MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        ShadowSoftness = Lighting.ShadowSoftness,
        Use2022Materials = MaterialService.Use2022Materials
    }
    
    -- Apply optimizations
    pcall(function()
        -- Water optimization
        if Settings.Other["Low Water Graphics"] and workspace:FindFirstChildOfClass("Terrain") then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            
            if sethiddenproperty then
                sethiddenproperty(terrain, "Decoration", false)
            end
        end
        
        -- Shadow optimization
        if Settings.Other["No Shadows"] then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            
            if sethiddenproperty then
                sethiddenproperty(Lighting, "Technology", 2)
            end
        end
        
        -- Rendering optimization
        if Settings.Other["Low Rendering"] then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end
        
        -- Material optimization
        if Settings.Other["Reset Materials"] then
            for _, material in pairs(MaterialService:GetChildren()) do
                if material:IsA("MaterialVariant") then
                    material:Destroy()
                end
            end
            MaterialService.Use2022Materials = false
        end
        
        -- FPS cap
        if Settings.Other["FPS Cap"] and setfpscap then
            setfpscap(Settings.Other["FPS Cap"])
        end
    end)
    
    -- Optimize existing objects
    spawn(function()
        local descendants = workspace:GetDescendants()
        local waitPerAmount = 500
        local currentWait = waitPerAmount
        
        for i, instance in pairs(descendants) do
            optimizeInstance(instance)
            
            if i == currentWait then
                task.wait()
                currentWait = currentWait + waitPerAmount
            end
        end
    end)
    
    -- Monitor new objects
    Connections.DescendantAdded = workspace.DescendantAdded:Connect(function(instance)
        task.wait(0.1)
        optimizeInstance(instance)
    end)
    
    IsEnabled = true
    print("⚡ FPS Booster: ENABLED - Advanced optimization loaded!")
    return true, "FPS Booster enabled successfully"
end

function FPSBooster.disable()
    if not IsEnabled then
        return false, "FPS Booster not enabled"
    end
    
    -- Disconnect connections
    for name, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    Connections = {}
    
    -- Restore original settings
    pcall(function()
        if OriginalSettings.QualityLevel then
            settings().Rendering.QualityLevel = OriginalSettings.QualityLevel
        end
        if OriginalSettings.MeshPartDetailLevel then
            settings().Rendering.MeshPartDetailLevel = OriginalSettings.MeshPartDetailLevel
        end
        if OriginalSettings.GlobalShadows ~= nil then
            Lighting.GlobalShadows = OriginalSettings.GlobalShadows
        end
        if OriginalSettings.FogEnd then
            Lighting.FogEnd = OriginalSettings.FogEnd
        end
        if OriginalSettings.ShadowSoftness then
            Lighting.ShadowSoftness = OriginalSettings.ShadowSoftness
        end
        if OriginalSettings.Use2022Materials ~= nil then
            MaterialService.Use2022Materials = OriginalSettings.Use2022Materials
        end
        
        -- Remove FPS cap
        if setfpscap then
            setfpscap(0)
        end
        
        -- Restore terrain water
        if workspace:FindFirstChildOfClass("Terrain") then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            terrain.WaterWaveSize = 0.05
            terrain.WaterWaveSpeed = 10
            terrain.WaterReflectance = 1
            terrain.WaterTransparency = 0.3
        end
    end)
    
    IsEnabled = false
    print("⚡ FPS Booster: DISABLED - Settings restored")
    return true, "FPS Booster disabled successfully"
end

function FPSBooster.isEnabled()
    return IsEnabled
end

function FPSBooster.getSettings()
    return Settings
end

function FPSBooster.updateSettings(newSettings)
    for category, options in pairs(newSettings) do
        if Settings[category] then
            for option, value in pairs(options) do
                Settings[category][option] = value
            end
        end
    end
end

-- Initialize
return FPSBooster
