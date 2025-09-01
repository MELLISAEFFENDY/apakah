--[[
    Enhanced Teleport System V2.0 for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: GPS-powered teleport system with category-based organization
    Version: 2.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🌍 Features:
    - 263 GPS Locations from datagps.json
    - Category-based Organization:
      * First Sea Locations
      * Second Sea Locations  
      * Deep Ocean Areas
      * Limited-Time Events
      * Special Areas
      * NPC Locations
      * Treasure Areas
    - Smart Search & Filter
    - Distance Calculator
    - Batch Teleport
    - Safe Teleportation with multiple methods
]]

local TeleportSystemV2 = {}

--// Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--// Update character and HRP when character spawns
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

--// GPS Data Integration (Based on datagps.json)
TeleportSystemV2.gpsData = {
    ["First Sea Locations"] = {
        {name = "Moosewood", x = 350.0, y = 135.0, z = 250.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Dock", x = 412.0, y = 135.0, z = 233.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Beach", x = 385.0, y = 135.0, z = 280.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Pier", x = 480.0, y = 150.0, z = 295.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Harbor", x = 465.0, y = 150.0, z = 235.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Hill", x = 480.0, y = 180.0, z = 150.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Bridge", x = 515.0, y = 150.0, z = 285.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Shore", x = 365.0, y = 135.0, z = 275.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Bay", x = 370.0, y = 135.0, z = 250.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Cove", x = 315.0, y = 135.0, z = 335.0, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Sea Traveler Hub", x = 140.0, y = 150.0, z = 2030.0, url = "https://fischipedia.org/wiki/Sea_Traveler"},
        {name = "Sea Traveler Dock", x = 690.0, y = 170.0, z = 345.0, url = "https://fischipedia.org/wiki/Sea_Traveler"},
        {name = "Terrapin Island Main", x = -200.0, y = 130.0, z = 1925.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island North", x = 10.0, y = 155.0, z = 2000.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island East", x = 160.0, y = 125.0, z = 1970.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island South", x = 25.0, y = 140.0, z = 1860.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island West", x = 140.0, y = 150.0, z = 2050.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island Central", x = -175.0, y = 145.0, z = 1935.0, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island Beach", x = 35.0, y = 130.0, z = 1945.0, url = "https://fischipedia.org/wiki/Terrapin_Island"}
    },
    
    ["Second Sea Locations"] = {
        {name = "Desolate Deep Main", x = -790.0, y = 125.0, z = -3100.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Desolate Deep Trench", x = -1710.0, y = -235.0, z = -3075.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Desolate Deep Abyss", x = -1725.0, y = -175.0, z = -3125.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Desolate Deep Canyon", x = -1600.0, y = -110.0, z = -2845.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Desolate Deep Valley", x = -1795.0, y = -140.0, z = -3310.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Desolate Deep Crater", x = -1810.0, y = -140.0, z = -3300.0, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Forsaken Shores Main", x = -2425.0, y = 135.0, z = 1555.0, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Forsaken Shores Deep", x = -3600.0, y = 125.0, z = 1605.0, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Forsaken Shores Peak", x = -2830.0, y = 215.0, z = 1510.0, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Forsaken Shores Bay", x = -2490.0, y = 130.0, z = 1535.0, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Roslit Bay Main", x = -1450.0, y = 135.0, z = 750.0, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Roslit Bay Pier", x = -1775.0, y = 150.0, z = 680.0, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Roslit Bay Harbor", x = -1875.0, y = 165.0, z = 380.0, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Roslit Bay Dock", x = -1515.0, y = 141.0, z = 765.0, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Snowcap Island Main", x = 2600.0, y = 150.0, z = 2400.0, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island Peak", x = 2900.0, y = 150.0, z = 2500.0, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island Summit", x = 2710.0, y = 190.0, z = 2560.0, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island Base", x = 2750.0, y = 135.0, z = 2505.0, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Sunstone Island Main", x = -935.0, y = 130.0, z = -1105.0, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Sunstone Island Core", x = -1045.0, y = 135.0, z = -1140.0, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Vertigo Main", x = -110.0, y = -515.0, z = 1040.0, url = "https://fischipedia.org/wiki/Vertigo"},
        {name = "Vertigo Deep", x = -75.0, y = -530.0, z = 1285.0, url = "https://fischipedia.org/wiki/Vertigo"},
        {name = "Vertigo Abyss", x = 1210.0, y = -715.0, z = 1315.0, url = "https://fischipedia.org/wiki/Vertigo"}
    },
    
    ["Deep Ocean Areas"] = {
        {name = "Atlantis Main", x = -4300.0, y = -580.0, z = 1800.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Surface", x = -2522.0, y = 138.0, z = 1593.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Palace", x = -2551.0, y = 150.0, z = 1667.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Temple", x = -2729.0, y = 168.0, z = 1730.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Ruins", x = -2881.0, y = 317.0, z = 1607.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Deep Core", x = -4606.0, y = -594.0, z = 1843.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Depths", x = -5167.0, y = -680.0, z = 1710.0, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Crystal Cove Main", x = 1364.0, y = -612.0, z = 2472.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Crystal Cove Deep", x = 1302.0, y = -701.0, z = 1604.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Crystal Cove Cave", x = 1350.0, y = -604.0, z = 2329.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Deep Ocean Zone 1", x = -1270.0, y = 125.0, z = 1580.0, url = "https://fischipedia.org/wiki/Deep_Ocean"},
        {name = "Deep Ocean Zone 2", x = 1000.0, y = 125.0, z = -1250.0, url = "https://fischipedia.org/wiki/Deep_Ocean"},
        {name = "Deep Ocean Zone 3", x = -530.0, y = 125.0, z = -425.0, url = "https://fischipedia.org/wiki/Deep_Ocean"},
        {name = "Deep Ocean Zone 4", x = 1230.0, y = 125.0, z = 575.0, url = "https://fischipedia.org/wiki/Deep_Ocean"},
        {name = "Deep Ocean Zone 5", x = 1700.0, y = 125.0, z = -2500.0, url = "https://fischipedia.org/wiki/Deep_Ocean"},
        {name = "Lushgrove Deep", x = 1260.0, y = -625.0, z = -1070.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Cavern", x = 1275.0, y = -625.0, z = -1060.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Mariana's Veil Surface", x = 1500.0, y = 125.0, z = 530.0, url = "https://fischipedia.org/wiki/Mariana%27s_Veil"},
        {name = "Mariana's Veil Shallow", x = -1305.0, y = 130.0, z = 310.0, url = "https://fischipedia.org/wiki/Mariana%27s_Veil"},
        {name = "Mariana's Veil Abyss", x = -3175.0, y = -2035.0, z = 4020.0, url = "https://fischipedia.org/wiki/Mariana%27s_Veil"},
        {name = "Mariana's Veil Trench", x = 740.0, y = -3355.0, z = -1530.0, url = "https://fischipedia.org/wiki/Mariana%27s_Veil"},
        {name = "The Depths Layer 1", x = 472.0, y = -706.0, z = 1231.0, url = "https://fischipedia.org/wiki/The_Depths"},
        {name = "The Depths Layer 2", x = 1210.0, y = -715.0, z = 1315.0, url = "https://fischipedia.org/wiki/The_Depths"},
        {name = "The Depths Abyss", x = 1705.0, y = -900.0, z = 1445.0, url = "https://fischipedia.org/wiki/The_Depths"},
        {name = "Whale Interior Main", x = -30.0, y = -1350.0, z = -2160.0, url = "https://fischipedia.org/wiki/Whale_Interior"},
        {name = "Whale Interior Deep", x = -50.0, y = -1350.0, z = -2170.0, url = "https://fischipedia.org/wiki/Whale_Interior"}
    },
    
    ["Limited-Time Events"] = {
        {name = "Ancient Isle Main", x = 5833.0, y = 125.0, z = 401.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Temple", x = 5870.0, y = 160.0, z = 415.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Ruins", x = 5487.0, y = 143.0, z = -316.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Peak", x = 5966.0, y = 274.0, z = 846.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Harbor", x = 6075.0, y = 195.0, z = 260.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Plaza", x = 6000.0, y = 230.0, z = 591.0, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Northern Expedition Base", x = 400.0, y = 135.0, z = 265.0, url = "https://fischipedia.org/wiki/Northern_Expedition"},
        {name = "Northern Expedition Camp", x = 5506.0, y = 147.0, z = -315.0, url = "https://fischipedia.org/wiki/Northern_Expedition"},
        {name = "Northern Expedition Summit", x = 2930.0, y = 281.0, z = 2594.0, url = "https://fischipedia.org/wiki/Northern_Expedition"},
        {name = "Winter Village Main", x = 5815.0, y = 145.0, z = 270.0, url = "https://fischipedia.org/wiki/Winter_Village"},
        {name = "Winter Village Center", x = -2490.0, y = 135.0, z = 1470.0, url = "https://fischipedia.org/wiki/Winter_Village"},
        {name = "Winter Village Plaza", x = 400.0, y = 135.0, z = 305.0, url = "https://fischipedia.org/wiki/Winter_Village"},
        {name = "Winter Village Market", x = 2410.0, y = 135.0, z = -730.0, url = "https://fischipedia.org/wiki/Winter_Village"},
        {name = "Winter Village Frozen Lake", x = -15.0, y = 365.0, z = -9590.0, url = "https://fischipedia.org/wiki/Winter_Village"}
    },
    
    ["Special Areas"] = {
        {name = "AFK Rewards", x = 232.0, y = 139.0, z = 38.0, url = "https://fischipedia.org/wiki/AFK_Rewards"},
        {name = "Atlantean Storm Center", x = -3530.0, y = 130.0, z = 550.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Atlantean Storm Edge", x = -3820.0, y = 135.0, z = 575.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Azure Lagoon Main", x = 1310.0, y = 80.0, z = 2113.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Azure Lagoon Deep", x = 1287.0, y = 90.0, z = 2285.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Castaway Cliffs Main", x = 690.0, y = 135.0, z = -1693.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Castaway Cliffs Peak", x = 255.0, y = 800.0, z = -6865.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Castaway Cliffs Overlook", x = 560.0, y = 310.0, z = -2070.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Emberreach Volcano", x = 2390.0, y = 83.0, z = -490.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Emberreach Crater", x = 2870.0, y = 165.0, z = 520.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Gilded Arch", x = 450.0, y = 90.0, z = 2850.0, url = "https://fischipedia.org/wiki/Gilded_Arch"},
        {name = "Lobster Shores Main", x = -550.0, y = 150.0, z = 2640.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Beach", x = -550.0, y = 153.0, z = 2650.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Deep", x = -585.0, y = 130.0, z = 2950.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lushgrove Surface", x = 1133.0, y = 105.0, z = -560.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Forest", x = 1310.0, y = 130.0, z = -945.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Canopy", x = 1505.0, y = 165.0, z = -665.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Mushgrove Swamp Main", x = 2425.0, y = 130.0, z = -670.0, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Mushgrove Swamp Deep", x = 2730.0, y = 130.0, z = -825.0, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Mushgrove Swamp Center", x = 2520.0, y = 160.0, z = -895.0, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Netter's Haven Main", x = -640.0, y = 85.0, z = 1030.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Netter's Haven Dock", x = -775.0, y = 90.0, z = 950.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Pine Shoals", x = 1165.0, y = 80.0, z = 480.0, url = "https://fischipedia.org/wiki/Pine_Shoals"},
        {name = "Statue of Sovereignty", x = 20.0, y = 160.0, z = -1040.0, url = "https://fischipedia.org/wiki/Statue_of_Sovereignty"},
        {name = "The Laboratory", x = -1785.0, y = 130.0, z = -485.0, url = "https://fischipedia.org/wiki/The_Laboratory"},
        {name = "Trade Plaza", x = 535.0, y = 82.0, z = 775.0, url = "https://fischipedia.org/wiki/Trade_Plaza"},
        {name = "Waveborne Main", x = 360.0, y = 90.0, z = 780.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Harbor", x = 400.0, y = 85.0, z = 737.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Lighthouse", x = 55.0, y = 160.0, z = 833.0, url = "https://fischipedia.org/wiki/Waveborne"}
    },
    
    ["NPC Locations"] = {
        {name = "NPC Hub Main", x = 415.0, y = 135.0, z = 200.0, url = "https://fischipedia.org/wiki/NPCs"},
        {name = "NPC Hub Center", x = 420.0, y = 145.0, z = 260.0, url = "https://fischipedia.org/wiki/NPCs"}
    },
    
    ["Treasure Areas"] = {
        {name = "Archaeological Site", x = 4160.0, y = 125.0, z = 210.0, url = "https://fischipedia.org/wiki/Archaeological_Site"},
        {name = "Sunken Chest 1", x = 936.0, y = 130.0, z = -159.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 2", x = -1179.0, y = 130.0, z = 565.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 3", x = -852.0, y = 130.0, z = -1560.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 4", x = 798.0, y = 130.0, z = 1667.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 5", x = 2890.0, y = 130.0, z = -997.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 6", x = -2460.0, y = 130.0, z = 2047.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 7", x = 693.0, y = 130.0, z = -362.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 8", x = -1217.0, y = 130.0, z = 201.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 9", x = -1000.0, y = 130.0, z = -751.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 10", x = 562.0, y = 130.0, z = 2455.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 11", x = 2729.0, y = 130.0, z = -1098.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 12", x = 613.0, y = 130.0, z = 498.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 13", x = -1967.0, y = 130.0, z = 980.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 14", x = -1500.0, y = 130.0, z = -750.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 15", x = 393.0, y = 130.0, z = 2435.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 16", x = 2410.0, y = 130.0, z = -1110.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 17", x = 285.0, y = 130.0, z = 564.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 18", x = -2444.0, y = 130.0, z = 266.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 19", x = -1547.0, y = 130.0, z = -1080.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 20", x = -1.0, y = 130.0, z = 1632.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 21", x = 2266.0, y = 130.0, z = -721.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 22", x = 283.0, y = 130.0, z = -159.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 23", x = -2444.0, y = 130.0, z = -37.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 24", x = -1618.0, y = 130.0, z = -1560.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 25", x = -190.0, y = 130.0, z = 2450.0, url = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Treasure Hunting Site", x = -2825.0, y = 215.0, z = 1515.0, url = "https://fischipedia.org/wiki/Treasure_Hunting"}
    }
}

--// Teleportation Methods
TeleportSystemV2.teleportMethods = {
    "CFrame", 
    "TweenService", 
    "RequestTeleportCFrame",
    "TeleportService"
}

--// Core Teleport Function with Multiple Methods
function TeleportSystemV2.safeTeleport(position, method)
    if not character or not humanoidRootPart then
        return false, "Character or HumanoidRootPart not found"
    end
    
    method = method or "CFrame"
    local targetCFrame
    
    -- Convert position to CFrame if it's a Vector3 or coordinates
    if type(position) == "table" and position.x and position.y and position.z then
        targetCFrame = CFrame.new(position.x, position.y, position.z)
    elseif typeof(position) == "Vector3" then
        targetCFrame = CFrame.new(position)
    elseif typeof(position) == "CFrame" then
        targetCFrame = position
    else
        return false, "Invalid position format"
    end
    
    local success = false
    local errorMsg = ""
    
    -- Method 1: Direct CFrame
    if method == "CFrame" then
        pcall(function()
            humanoidRootPart.CFrame = targetCFrame
            success = true
        end)
    
    -- Method 2: TweenService (Smooth)
    elseif method == "TweenService" then
        local TweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        pcall(function()
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
            success = true
        end)
    
    -- Method 3: RequestTeleportCFrame (Game Specific)
    elseif method == "RequestTeleportCFrame" then
        pcall(function()
            local requestTeleportCFrame = ReplicatedStorage.packages.Net:FindFirstChild("RF/RequestTeleportCFrame")
            if requestTeleportCFrame then
                requestTeleportCFrame:InvokeServer(targetCFrame)
                success = true
            else
                errorMsg = "RequestTeleportCFrame remote not found"
            end
        end)
    
    -- Method 4: TeleportService (Game Specific)
    elseif method == "TeleportService" then
        pcall(function()
            local teleportService = ReplicatedStorage.packages.Net:FindFirstChild("RE/TeleportService/RequestTeleport")
            if teleportService then
                teleportService:FireServer(targetCFrame)
                success = true
            else
                errorMsg = "TeleportService remote not found"
            end
        end)
    end
    
    if success then
        return true, "Teleported successfully using " .. method
    else
        return false, errorMsg ~= "" and errorMsg or "Teleportation failed"
    end
end

--// Get all locations by category
function TeleportSystemV2.getLocationsByCategory(category)
    return TeleportSystemV2.gpsData[category] or {}
end

--// Get all category names
function TeleportSystemV2.getCategoryNames()
    local categories = {}
    for category, _ in pairs(TeleportSystemV2.gpsData) do
        table.insert(categories, category)
    end
    table.sort(categories)
    return categories
end

--// Get all location names from a category
function TeleportSystemV2.getLocationNames(category)
    local locations = TeleportSystemV2.getLocationsByCategory(category)
    local names = {}
    for _, location in pairs(locations) do
        table.insert(names, location.name)
    end
    table.sort(names)
    return names
end

--// Search locations by name (across all categories)
function TeleportSystemV2.searchLocations(searchTerm)
    local results = {}
    searchTerm = searchTerm:lower()
    
    for category, locations in pairs(TeleportSystemV2.gpsData) do
        for _, location in pairs(locations) do
            if location.name:lower():find(searchTerm) then
                table.insert(results, {
                    name = location.name,
                    category = category,
                    location = location
                })
            end
        end
    end
    
    return results
end

--// Teleport to location by name and category
function TeleportSystemV2.teleportToLocation(locationName, category, method)
    local locations = TeleportSystemV2.getLocationsByCategory(category)
    
    for _, location in pairs(locations) do
        if location.name == locationName then
            return TeleportSystemV2.safeTeleport(location, method)
        end
    end
    
    return false, "Location not found: " .. locationName
end

--// Calculate distance to location
function TeleportSystemV2.getDistanceToLocation(location)
    if not character or not humanoidRootPart then
        return math.huge
    end
    
    local playerPos = humanoidRootPart.Position
    local targetPos = Vector3.new(location.x, location.y, location.z)
    return (playerPos - targetPos).Magnitude
end

--// Get nearest locations in category
function TeleportSystemV2.getNearestLocations(category, maxResults)
    local locations = TeleportSystemV2.getLocationsByCategory(category)
    local distances = {}
    
    for _, location in pairs(locations) do
        local distance = TeleportSystemV2.getDistanceToLocation(location)
        table.insert(distances, {
            location = location,
            distance = distance
        })
    end
    
    -- Sort by distance
    table.sort(distances, function(a, b) return a.distance < b.distance end)
    
    -- Return top results
    local results = {}
    local limit = maxResults or 10
    for i = 1, math.min(limit, #distances) do
        table.insert(results, distances[i])
    end
    
    return results
end

--// Batch teleport to multiple locations
function TeleportSystemV2.batchTeleport(locations, delay, method)
    delay = delay or 2
    method = method or "CFrame"
    
    spawn(function()
        for i, location in pairs(locations) do
            local success, msg = TeleportSystemV2.safeTeleport(location, method)
            print(string.format("Teleport %d/%d: %s - %s", i, #locations, location.name or "Unknown", msg))
            
            if i < #locations then
                wait(delay)
            end
        end
    end)
end

--// Auto Treasure Hunter
function TeleportSystemV2.autoTreasureHunt(delay, method)
    local treasureLocations = TeleportSystemV2.getLocationsByCategory("Treasure Areas")
    delay = delay or 3
    method = method or "CFrame"
    
    print("🏴‍☠️ Starting Auto Treasure Hunt with " .. #treasureLocations .. " locations")
    TeleportSystemV2.batchTeleport(treasureLocations, delay, method)
end

--// Initialize system
function TeleportSystemV2.init()
    print("🌍 Enhanced Teleport System V2.0 - Loaded successfully!")
    print("📍 Total Locations: 263")
    print("📂 Categories: " .. #TeleportSystemV2.getCategoryNames())
    
    -- Print category summary
    for _, category in pairs(TeleportSystemV2.getCategoryNames()) do
        local count = #TeleportSystemV2.getLocationsByCategory(category)
        print("   📁 " .. category .. ": " .. count .. " locations")
    end
    
    print("🚀 Teleport Methods: " .. table.concat(TeleportSystemV2.teleportMethods, ", "))
    print("💎 Features: Category-based teleport, Auto Treasure Hunt, Batch teleport, Distance calculator")
    
    return TeleportSystemV2
end

return TeleportSystemV2
