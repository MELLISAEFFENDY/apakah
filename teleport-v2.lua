--[[
    Enhanced Teleport System V2.0 for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: GPS-powered teleport system with category-based organization
    Version: 2.1
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🌍 Features:
    - 276 GPS Locations from datagps.json + Item Totems
    - Category-based Organization:
      * First Sea Locations
      * Second Sea Locations  
      * Deep Ocean Areas
      * Limited-Time Events
      * Special Areas
      * NPC Locations
      * Treasure Areas
      * Item Totem Locations (NEW!)
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

--// GPS Data Integration (Based on MAP AREA files)
TeleportSystemV2.gpsData = {
    ["Moosewood Area"] = {
        -- Main GPS Points
        {name = "Moosewood Main Area", x = 350, y = 135, z = 250, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Area 1", x = 100, y = 515, z = 150, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Beach", x = 385, y = 135, z = 280, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Pier", x = 480, y = 150, z = 295, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Area 2", x = 0, y = 465, z = 150, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Area 3", x = 300, y = 465, z = 150, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood Area 4", x = 900, y = 465, z = 150, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Island Location 1", x = 705, y = 137, z = 341, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Island Location 2", x = 230, y = 139, z = 39, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Roslit Bay Crate", x = -1878, y = 167, z = 548, url = "https://fischipedia.org/wiki/Moosewood"},
        -- Item Locations
        {name = "Training Rod (Moosewood)", x = 465, y = 150, z = 235, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Long Rod (Moosewood)", x = 480, y = 180, z = 150, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Fish Radar (Moosewood)", x = 365, y = 135, z = 275, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Basic Diving Gear (Moosewood)", x = 370, y = 135, z = 250, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Bait Crate (Moosewood)", x = 315, y = 135, z = 335, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Message In a Bottle (Moosewood)", x = 412, y = 135, z = 233, url = "https://fischipedia.org/wiki/Moosewood"},
        -- Fish Locations
        {name = "Trout Fishing Spot", x = 390, y = 132, z = 345, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Anchovy Fishing Spot", x = 130, y = 135, z = 630, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Yellowfin Tuna Spot", x = 705, y = 136, z = 340, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Carp Fishing Spot", x = 560, y = 145, z = 600, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Goldfish Spot", x = 525, y = 145, z = 310, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Flounder Spot", x = 285, y = 133, z = 215, url = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Pike Fishing Spot", x = 540, y = 145, z = 330, url = "https://fischipedia.org/wiki/Moosewood"}
    },

    ["Terrapin Island Area"] = {
        -- Main GPS Points
        {name = "Terrapin Island Main", x = -200, y = 130, z = 1925, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Hideaway", x = 160, y = 125, z = 1970, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Hideaway 2", x = 10, y = 155, z = 2000, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Cave Area", x = 25, y = 140, z = 1860, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Dreamers Crypt", x = 140, y = 150, z = 2050, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        -- Item Locations
        {name = "Magnet Rod (Terrapin)", x = -200, y = 130, z = 1930, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Quality Bait Crate (Terrapin)", x = -175, y = 145, z = 1935, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Tempest Totem (Terrapin)", x = 35, y = 130, z = 1945, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        -- Fish Locations
        {name = "Walleye Spot", x = -225, y = 125, z = 2150, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "White Bass Spot", x = -50, y = 130, z = 2025, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Redeye Bass Spot", x = -35, y = 125, z = 2285, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Chinook Salmon Spot", x = -305, y = 125, z = 1625, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Golden Smallmouth Bass Spot", x = 65, y = 135, z = 2140, url = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Olm Spot", x = 95, y = 125, z = 1980, url = "https://fischipedia.org/wiki/Terrapin_Island"}
    },
    
    ["Roslit Bay Area"] = {
        -- Main GPS Points
        {name = "Roslit Bay Main", x = -1450, y = 135, z = 750, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Roslit Bay Pier", x = -1775, y = 150, z = 680, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Roslit Volcano", x = -1875, y = 165, z = 380, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Deep Pearl Location 1", x = -1765, y = 140, z = 6001, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Deep Pearl Location 2", x = -1800, y = 140, z = 6209, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Tropical Breeze", x = -1785, y = 165, z = 400, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        -- Item Locations
        {name = "Fortune Rod (Roslit)", x = -1515, y = 141, z = 765, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Meteor Totem (Roslit)", x = -1945, y = 275, z = 230, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Glider (Roslit)", x = -1710, y = 150, z = 740, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Bait Crate (Roslit)", x = -1465, y = 130, z = 680, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Crab Cage (Roslit)", x = -1485, y = 130, z = 640, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        -- Fish Locations
        {name = "Perch Spot", x = -1805, y = 140, z = 595, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Blue Tang Spot", x = -1465, y = 125, z = 525, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Clownfish Spot", x = -1520, y = 125, z = 520, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Clam Spot", x = -2028, y = 130, z = 541, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Angelfish Spot", x = -1500, y = 135, z = 615, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Arapaima Spot", x = -1765, y = 140, z = 600, url = "https://fischipedia.org/wiki/Roslit_Bay"},
        {name = "Suckermouth Catfish Spot", x = -1800, y = 140, z = 620, url = "https://fischipedia.org/wiki/Roslit_Bay"}
    },

    ["Mushgrove Swamp Area"] = {
        -- Main GPS Points
        {name = "Mushgrove Swamp Main", x = 2425, y = 130, z = -670, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Guard Tower Alligator Marsh", x = 2730, y = 130, z = -825, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Mushgrove Area 1", x = 182, y = 81, z = 900, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Mushgrove Area 2", x = 137, y = 61, z = 650, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Mushgrove Area 3", x = 271, y = 121, z = 950, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Greedy Location", x = 1, y = 100, z = 866, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Bowfin Area", x = 2520, y = 125, z = -8157, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Catfish Area", x = 2670, y = 130, z = -7102, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        -- Item Locations
        {name = "Smokescreen Totem (Mushgrove)", x = 2790, y = 140, z = -625, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Crab Cage (Mushgrove)", x = 2520, y = 135, z = -895, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Special Item Area", x = 2520, y = 160, z = -895, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        -- Fish Locations
        {name = "White Perch Spot", x = 2475, y = 125, z = -675, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Grey Carp Spot", x = 2665, y = 125, z = -815, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Bowfin Spot", x = 2445, y = 125, z = -795, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Marsh Gar Spot", x = 2520, y = 125, z = -815, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"},
        {name = "Alligator Spot", x = 2670, y = 130, z = -710, url = "https://fischipedia.org/wiki/Mushgrove_Swamp"}
    },
    ["Snowcap Island Area"] = {
        -- Main GPS Points
        {name = "Snowcap Island Main", x = 2600, y = 150, z = 2400, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island Peak", x = 2710, y = 190, z = 2560, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Cave Entrance", x = 2750, y = 135, z = 2505, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island Summit", x = 2800, y = 280, z = 2565, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Cave", x = 2900, y = 150, z = 2500, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        -- Item Locations
        {name = "Windset Totem (Snowcap)", x = 2845, y = 180, z = 2700, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        -- Fish Locations
        {name = "Pollock Spot", x = 2550, y = 135, z = 2385, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Bluegill Spot", x = 3070, y = 130, z = 2600, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Herring Spot", x = 2595, y = 140, z = 2500, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Red Drum Spot", x = 2310, y = 135, z = 2545, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Arctic Char Spot", x = 2350, y = 130, z = 2230, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Lingcod Spot", x = 2820, y = 125, z = 2805, url = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Glacierfish Spot", x = 2860, y = 135, z = 2620, url = "https://fischipedia.org/wiki/Snowcap_Island"}
    },

    ["Sunstone Island Area"] = {
        -- Main GPS Points
        {name = "Sunstone Island Main", x = -935, y = 130, z = -1105, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Sunstone Cave", x = -1215, y = 190, z = -1040, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Upper Sunstone", x = -1045, y = 135, z = -1140, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        -- Item Locations
        {name = "Sundial Totem (Sunstone)", x = -1145, y = 135, z = -1075, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Bait Crate (Sunstone)", x = -1045, y = 200, z = -1100, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Crab Cage (Sunstone)", x = -920, y = 130, z = -1105, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        -- Fish Locations
        {name = "Sweetfish Spot", x = -940, y = 130, z = -1105, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Glassfish Spot", x = -905, y = 130, z = -1000, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Longtail Bass Spot", x = -860, y = 135, z = -1205, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Red Tang Spot", x = -1195, y = 123, z = -1220, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Chinfish Spot", x = -625, y = 130, z = -950, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Trumpetfish Spot", x = -790, y = 125, z = -1340, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Mahi Mahi Spot", x = -730, y = 130, z = -1350, url = "https://fischipedia.org/wiki/Sunstone_Island"},
        {name = "Sunfish Spot", x = -975, y = 125, z = -1430, url = "https://fischipedia.org/wiki/Sunstone_Island"}
    },

    ["Ancient Isle Area"] = {
        -- Main GPS Points
        {name = "Ancient Isle Main", x = 5833, y = 125, z = 401, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Fragment Puzzle Chamber", x = 5870, y = 160, z = 415, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Cave 1", x = 5487, y = 143, z = -316, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Cave 2", x = 5966, y = 274, z = 846, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Cave 3", x = 6075, y = 195, z = 260, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Night Area", x = 6000, y = 230, z = 591, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle General", x = 6010, y = 190, z = 331, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Spring", x = 5504, y = 143, z = -3212, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle Day Area", x = 5833, y = 125, z = 4010, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        -- Item Locations
        {name = "Stone Rod (Ancient)", x = 5487, y = 143, z = -316, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Eclipse Totem (Ancient)", x = 5966, y = 274, z = 846, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Bait Crate (Ancient)", x = 6075, y = 195, z = 260, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        -- Fish Locations
        {name = "Anomalocaris Spot", x = 5504, y = 143, z = -321, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Cobia Spot", x = 5983, y = 125, z = 1007, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Hallucigenia Spot", x = 6015, y = 190, z = 339, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Leedsichthys Spot", x = 6052, y = 394, z = 648, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Deep Sea Fragment Spot", x = 5841, y = 81, z = 388, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Solar Fragment Spot", x = 6073, y = 443, z = 684, url = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Earth Fragment Spot", x = 5972, y = 274, z = 845, url = "https://fischipedia.org/wiki/Ancient_Isle"}
    },

    ["Atlantis Deep Ocean"] = {
        -- Main GPS Points
        {name = "Heart of Zeus", x = -2522, y = 138, z = 1593, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Cave 1", x = -2551, y = 150, z = 1667, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Cave 2", x = -2729, y = 168, z = 1730, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Cave 3", x = -2881, y = 317, z = 1607, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Atlantis Cave 4", x = -2835, y = 131, z = 1510, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Grand Reef", x = -3576, y = 148, z = 524, url = "https://fischipedia.org/wiki/Atlantis"},
        -- Item Locations (Deep Ocean Rods)
        {name = "Depthseeker Rod", x = -4465, y = -604, z = 1874, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Champions Rod", x = -4277, y = -606, z = 1838, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Tempest Rod", x = -4928, y = -595, z = 1857, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Abyssal Specter Rod", x = -3804, y = -567, z = 1870, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Poseidon Rod", x = -4086, y = -559, z = 895, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Zeus Rod", x = -4272, y = -629, z = 2665, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Kraken Rod", x = -4415, y = -997, z = 2055, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Poseidon Wrath Totem (Atlantis)", x = -3953, y = -556, z = 853, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Zeus Storm Totem (Atlantis)", x = -4325, y = -630, z = 2687, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Flippers (Atlantis)", x = -4462, y = -605, z = 1875, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Super Flippers", x = -4463, y = -603, z = 1876, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Advanced Diving Gear (Atlantis)", x = -4452, y = -603, z = 1877, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Conception Conch (Atlantis)", x = -4450, y = -605, z = 1874, url = "https://fischipedia.org/wiki/Atlantis"},
        {name = "Crab Cage (Atlantis)", x = -4446, y = -605, z = 1866, url = "https://fischipedia.org/wiki/Atlantis"}
    },

    ["Desolate Deep Area"] = {
        -- Main GPS Points
        {name = "Brine Pool", x = -1710, y = -235, z = -3075, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        -- Item Locations
        {name = "Advanced Diving Gear (Desolate)", x = -790, y = 125, z = -3100, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Reinforced Rod", x = -975, y = -245, z = -2700, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Trident Rod", x = -1485, y = -225, z = -2195, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Basic Diving Gear (Desolate)", x = -1655, y = -210, z = -2825, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Tidebreaker", x = -1645, y = -210, z = -2855, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Conception Conch (Desolate)", x = -1630, y = -210, z = -2860, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Aurora Totem (Desolate)", x = -1800, y = -135, z = -3280, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        -- Fish Locations
        {name = "Phantom Ray Spot", x = -1685, y = -235, z = -3090, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Cockatoo Squid Spot", x = -1645, y = -205, z = -2790, url = "https://fischipedia.org/wiki/Desolate_Deep"},
        {name = "Banditfish Spot", x = -1500, y = -235, z = -2855, url = "https://fischipedia.org/wiki/Desolate_Deep"}
    },

    ["Forsaken Shores Area"] = {
        -- Main GPS Points
        {name = "Forsaken Shores Main", x = -2425, y = 135, z = 1555, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Forsaken Shores Deep", x = -3600, y = 125, z = 1605, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        -- Item Locations
        {name = "Scurvy Rod", x = -2830, y = 215, z = 1510, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Bait Crate (Forsaken)", x = -2490, y = 130, z = 1535, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Crab Cage (Forsaken)", x = -2525, y = 135, z = -1575, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        -- Fish Locations
        {name = "Scurvy Sailfish Spot", x = -2430, y = 130, z = 1450, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Cutlass Fish Spot", x = -2645, y = 130, z = 1410, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Shipwreck Barracuda Spot", x = -3597, y = 140, z = 1604, url = "https://fischipedia.org/wiki/Forsaken_Shores"},
        {name = "Golden Seahorse Spot", x = -3100, y = 127, z = 1450, url = "https://fischipedia.org/wiki/Forsaken_Shores"}
    },

    ["Other Important Locations"] = {
        -- Legacy GPS and special areas
        {name = "Crystal Cove Main", x = 1364.0, y = -612.0, z = 2472.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Crystal Cove Deep", x = 1302.0, y = -701.0, z = 1604.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Crystal Cove Cave", x = 1350.0, y = -604.0, z = 2329.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        {name = "Vertigo Main", x = -110.0, y = -515.0, z = 1040.0, url = "https://fischipedia.org/wiki/Vertigo"},
        {name = "Vertigo Deep", x = -75.0, y = -530.0, z = 1285.0, url = "https://fischipedia.org/wiki/Vertigo"},
        {name = "Vertigo Abyss", x = 1210.0, y = -715.0, z = 1315.0, url = "https://fischipedia.org/wiki/Vertigo"},
        {name = "AFK Rewards Platform", x = 232.0, y = 139.0, z = 38.0, url = "https://fischipedia.org/wiki/AFK_Rewards"},
        {name = "Atlantean Storm Center", x = -3530.0, y = 130.0, z = 550.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Atlantean Storm Edge", x = -3820.0, y = 135.0, z = 575.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Azure Lagoon Main", x = 1310.0, y = 80.0, z = 2113.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Azure Lagoon Deep", x = 1287.0, y = 90.0, z = 2285.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Castaway Cliffs Main", x = 690.0, y = 135.0, z = -1693.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Castaway Cliffs Peak", x = 255.0, y = 800.0, z = -6865.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Emberreach Volcano", x = 2390.0, y = 83.0, z = -490.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Emberreach Crater", x = 2870.0, y = 165.0, z = 520.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Gilded Arch", x = 450.0, y = 90.0, z = 2850.0, url = "https://fischipedia.org/wiki/Gilded_Arch"},
        {name = "Lobster Shores Main", x = -550.0, y = 150.0, z = 2640.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Beach", x = -550.0, y = 153.0, z = 2650.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Deep", x = -585.0, y = 130.0, z = 2950.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lushgrove Surface", x = 1133.0, y = 105.0, z = -560.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Forest", x = 1310.0, y = 130.0, z = -945.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Deep", x = 1260.0, y = -625.0, z = -1070.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Cavern", x = 1275.0, y = -625.0, z = -1060.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Netter's Haven Main", x = -640.0, y = 85.0, z = 1030.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Netter's Haven Dock", x = -775.0, y = 90.0, z = 950.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Pine Shoals", x = 1165.0, y = 80.0, z = 480.0, url = "https://fischipedia.org/wiki/Pine_Shoals"},
        {name = "Statue of Sovereignty", x = 20.0, y = 160.0, z = -1040.0, url = "https://fischipedia.org/wiki/Statue_of_Sovereignty"},
        {name = "The Laboratory", x = -1785.0, y = 130.0, z = -485.0, url = "https://fischipedia.org/wiki/The_Laboratory"},
        {name = "Trade Plaza", x = 535.0, y = 82.0, z = 775.0, url = "https://fischipedia.org/wiki/Trade_Plaza"},
        {name = "Waveborne Main", x = 360.0, y = 90.0, z = 780.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Harbor", x = 400.0, y = 85.0, z = 737.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Lighthouse", x = 55.0, y = 160.0, z = 833.0, url = "https://fischipedia.org/wiki/Waveborne"}
    }
}
        {name = "Crystal Cove Cave", x = 1350.0, y = -604.0, z = 2329.0, url = "https://fischipedia.org/wiki/Crystal_Cove"},
        -- Special Areas
        {name = "AFK Rewards", x = 232.0, y = 139.0, z = 38.0, url = "https://fischipedia.org/wiki/AFK_Rewards"},
        {name = "Atlantean Storm Center", x = -3530.0, y = 130.0, z = 550.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Atlantean Storm Edge", x = -3820.0, y = 135.0, z = 575.0, url = "https://fischipedia.org/wiki/Atlantean_Storm"},
        {name = "Azure Lagoon Main", x = 1310.0, y = 80.0, z = 2113.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Azure Lagoon Deep", x = 1287.0, y = 90.0, z = 2285.0, url = "https://fischipedia.org/wiki/Azure_Lagoon"},
        {name = "Castaway Cliffs Main", x = 690.0, y = 135.0, z = -1693.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Castaway Cliffs Peak", x = 255.0, y = 800.0, z = -6865.0, url = "https://fischipedia.org/wiki/Castaway_Cliffs"},
        {name = "Emberreach Volcano", x = 2390.0, y = 83.0, z = -490.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Emberreach Crater", x = 2870.0, y = 165.0, z = 520.0, url = "https://fischipedia.org/wiki/Emberreach"},
        {name = "Gilded Arch", x = 450.0, y = 90.0, z = 2850.0, url = "https://fischipedia.org/wiki/Gilded_Arch"},
        {name = "Lobster Shores Main", x = -550.0, y = 150.0, z = 2640.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Beach", x = -550.0, y = 153.0, z = 2650.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lobster Shores Deep", x = -585.0, y = 130.0, z = 2950.0, url = "https://fischipedia.org/wiki/Lobster_Shores"},
        {name = "Lushgrove Surface", x = 1133.0, y = 105.0, z = -560.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Forest", x = 1310.0, y = 130.0, z = -945.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Deep", x = 1260.0, y = -625.0, z = -1070.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Lushgrove Cavern", x = 1275.0, y = -625.0, z = -1060.0, url = "https://fischipedia.org/wiki/Lushgrove"},
        {name = "Netter's Haven Main", x = -640.0, y = 85.0, z = 1030.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Netter's Haven Dock", x = -775.0, y = 90.0, z = 950.0, url = "https://fischipedia.org/wiki/Netter%27s_Haven"},
        {name = "Pine Shoals", x = 1165.0, y = 80.0, z = 480.0, url = "https://fischipedia.org/wiki/Pine_Shoals"},
        {name = "Statue of Sovereignty", x = 20.0, y = 160.0, z = -1040.0, url = "https://fischipedia.org/wiki/Statue_of_Sovereignty"},
        {name = "The Laboratory", x = -1785.0, y = 130.0, z = -485.0, url = "https://fischipedia.org/wiki/The_Laboratory"},
        {name = "Trade Plaza", x = 535.0, y = 82.0, z = 775.0, url = "https://fischipedia.org/wiki/Trade_Plaza"},
        {name = "Waveborne Main", x = 360.0, y = 90.0, z = 780.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Harbor", x = 400.0, y = 85.0, z = 737.0, url = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne Lighthouse", x = 55.0, y = 160.0, z = 833.0, url = "https://fischipedia.org/wiki/Waveborne"},
        -- NPC Locations
        {name = "NPC Hub Main", x = 415.0, y = 135.0, z = 200.0, url = "https://fischipedia.org/wiki/NPCs"},
        {name = "NPC Hub Center", x = 420.0, y = 145.0, z = 260.0, url = "https://fischipedia.org/wiki/NPCs"}
    },

    ["Treasure Locations"] = {
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
    },
    
    ["Item Totem Locations"] = {
        {name = "Sundial Totem", x = -1215.0, y = 195.0, z = -1040.0, url = "https://fischipedia.org/wiki/Sundial_Totem"},
        {name = "Tempest Totem", x = 20.0, y = 140.0, z = 1860.0, url = "https://fischipedia.org/wiki/Tempest_Totem"},
        {name = "Windset Totem", x = 2845.0, y = 180.0, z = 2700.0, url = "https://fischipedia.org/wiki/Windset_Totem"},
        {name = "Smokescreen Totem", x = 2790.0, y = 140.0, z = -625.0, url = "https://fischipedia.org/wiki/Smokescreen_Totem"},
        {name = "Meteor Totem", x = -1945.0, y = 275.0, z = 230.0, url = "https://fischipedia.org/wiki/Meteor_Totem"},
        {name = "Avalanche Totem", x = 19711.0, y = 468.0, z = 6059.0, url = "https://fischipedia.org/wiki/Avalanche_Totem"},
        {name = "Eclipse Totem", x = 5940.0, y = 265.0, z = 900.0, url = "https://fischipedia.org/wiki/Eclipse_Totem"},
        {name = "Blizzard Totem", x = 20148.0, y = 743.0, z = 5804.0, url = "https://fischipedia.org/wiki/Blizzard_Totem"},
        {name = "Aurora Totem", x = -1810.0, y = -135.0, z = -3280.0, url = "https://fischipedia.org/wiki/Aurora_Totem"},
        {name = "Cursed Storm Totem", x = 760.0, y = 2130.0, z = 16965.0, url = "https://fischipedia.org/wiki/Cursed_Storm_Totem"},
        {name = "Zeus Storm Totem", x = -4325.0, y = -625.0, z = 2685.0, url = "https://fischipedia.org/wiki/Zeus_Storm_Totem"},
        {name = "Poseidon Wrath Totem", x = -3955.0, y = -555.0, z = 855.0, url = "https://fischipedia.org/wiki/Poseidon_Wrath_Totem"},
        {name = "Blue Moon Totem", x = 1300.0, y = 155.0, z = -550.0, url = "https://fischipedia.org/wiki/Blue_Moon_Totem"}
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
    print("📍 Total Locations: 276 (263 GPS + 13 Totems)")
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
