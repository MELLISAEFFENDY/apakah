-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                           🎯 Enhanced NPC Teleport System V1.0              ║
-- ║                        🤖 Specialized NPC Location Manager                   ║
-- ╠══════════════════════════════════════════════════════════════════════════════╣
-- ║  📊 Data Source: NPCgps.json (392 NPC Locations)                           ║
-- ║  🏗️  Built for: Roblox Fisch Game                                          ║
-- ║  👨‍💻 System: Advanced NPC teleportation with categorization                 ║
-- ║  📅 Created: September 2, 2025                                              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local NPCTeleportSystem = {}

-- 🔧 Service Imports
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- 👤 Player References
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 🌐 System Configuration
local CONFIG = {
    TWEEN_TIME = 2,
    TWEEN_STYLE = Enum.EasingStyle.Quart,
    TWEEN_DIRECTION = Enum.EasingDirection.Out,
    SAFETY_OFFSET = Vector3.new(0, 5, 0),
    MAX_DISTANCE = 10000,
    SEARCH_LIMIT = 10
}

-- 📊 NPC GPS Database (392 Locations from NPCgps.json)
local NPC_DATABASE = {
    -- 🏠 Moosewood Area NPCs
    ["Individual NPCs"] = {
        {name = "Shawn", pos = Vector3.new(1068, 157, 9918), wiki = "https://fischipedia.org/wiki/Shawn"},
        {name = "Shopper Girl", pos = Vector3.new(1000, 140, 9932), wiki = "https://fischipedia.org/wiki/Shopper_Girl"},
        {name = "Henry", pos = Vector3.new(484, 152, 236), wiki = "https://fischipedia.org/wiki/Henry"},
        {name = "Northern Expedition", pos = Vector3.new(400, 135, 265), wiki = "https://fischipedia.org/wiki/Northern_Expedition"},
        {name = "Northern Expedition (Alt)", pos = Vector3.new(2930, 281, 2594), wiki = "https://fischipedia.org/wiki/Northern_Expedition"},
        {name = "Wilson", pos = Vector3.new(2935, 280, 2565), wiki = "https://fischipedia.org/wiki/Wilson"},
        {name = "Wilson (Alt)", pos = Vector3.new(2930, 130, 2620), wiki = "https://fischipedia.org/wiki/Wilson"},
        {name = "Nick", pos = Vector3.new(50, 0, 0), wiki = "https://fischipedia.org/wiki/Nick"},
        {name = "Arnold", pos = Vector3.new(320, 134, 264), wiki = "https://fischipedia.org/wiki/Arnold"},
        {name = "Silas", pos = Vector3.new(1545, 1690, 6310), wiki = "https://fischipedia.org/wiki/Brother_Silas"},
        {name = "Tom Elf", pos = Vector3.new(404, 136, 317), wiki = "https://fischipedia.org/wiki/Tom_Elf"},
        {name = "Agaric", pos = Vector3.new(2931, 4268, 3039), wiki = "https://fischipedia.org/wiki/Agaric"},
        {name = "Chiseler", pos = Vector3.new(6087, 195, 294), wiki = "https://fischipedia.org/wiki/Chiseler"},
        {name = "Meteoriticist", pos = Vector3.new(5922, 262, 596), wiki = "https://fischipedia.org/wiki/Meteoriticist"},
        {name = "Thomas", pos = Vector3.new(1062, 140, 9890), wiki = "https://fischipedia.org/wiki/Thomas"},
        {name = "Daisy", pos = Vector3.new(580, 165, 220), wiki = "https://fischipedia.org/wiki/Daisy"},
        {name = "Clark", pos = Vector3.new(443, 84, 703), wiki = "https://fischipedia.org/wiki/Clark"},
        {name = "AFK Rewards", pos = Vector3.new(232, 139, 38), wiki = "https://fischipedia.org/wiki/AFK_Rewards"},
        {name = "Boone Tiller", pos = Vector3.new(390, 87, 764), wiki = "https://fischipedia.org/wiki/Boone_Tiller"},
        {name = "Clover McRich", pos = Vector3.new(345, 136, 330), wiki = "https://fischipedia.org/wiki/Clover_McRich"},
        {name = "Oscar IV", pos = Vector3.new(1392, 116, 493), wiki = "https://fischipedia.org/wiki/Oscar_IV"},
        {name = "Axel", pos = Vector3.new(883, 132, 9905), wiki = "https://fischipedia.org/wiki/Axel"},
        {name = "Jett", pos = Vector3.new(925, 131, 9883), wiki = "https://fischipedia.org/wiki/Jett"},
        {name = "Marlon Friend", pos = Vector3.new(405, 135, 248), wiki = "https://fischipedia.org/wiki/Marlon_Friend"},
        {name = "Smurfette", pos = Vector3.new(334, 135, 327), wiki = "https://fischipedia.org/wiki/Smurfette"},
        {name = "Bob", pos = Vector3.new(420, 145, 260), wiki = "https://fischipedia.org/wiki/Bob"},
        {name = "Bob (Alt)", pos = Vector3.new(415, 135, 200), wiki = "https://fischipedia.org/wiki/Bob"},
        {name = "Sandy Finn", pos = Vector3.new(1015, 140, 9911), wiki = "https://fischipedia.org/wiki/Sandy_Finn"},
        {name = "Angus McBait", pos = Vector3.new(236, 222, 461), wiki = "https://fischipedia.org/wiki/Angus_McBait"},
        {name = "Barnacle Bill", pos = Vector3.new(989, 143, 9975), wiki = "https://fischipedia.org/wiki/Barnacle_Bill"},
        {name = "Brickford Masterson", pos = Vector3.new(412, 132, 365), wiki = "https://fischipedia.org/wiki/Brickford_Masterson"},
        {name = "Willow", pos = Vector3.new(501, 134, 125), wiki = "https://fischipedia.org/wiki/Willow"},
        {name = "Sage", pos = Vector3.new(513, 134, 125), wiki = "https://fischipedia.org/wiki/Sage"},
        {name = "Joey", pos = Vector3.new(906, 132, 9962), wiki = "https://fischipedia.org/wiki/Joey"},
        {name = "Sporey", pos = Vector3.new(1245, 86, 425), wiki = "https://fischipedia.org/wiki/Sporey"},
        {name = "Sporey (Alt)", pos = Vector3.new(2942, 4270, 3047), wiki = "https://fischipedia.org/wiki/Sporey"},
        {name = "Dr. Blackfin", pos = Vector3.new(355, 136, 329), wiki = "https://fischipedia.org/wiki/Dr._Blackfin"},
        {name = "Lars Timberjaw", pos = Vector3.new(1217, 87, 574), wiki = "https://fischipedia.org/wiki/Lars_Timberjaw"},
        {name = "Marley", pos = Vector3.new(505, 134, 120), wiki = "https://fischipedia.org/wiki/Marley"},
        {name = "Captain Ahab", pos = Vector3.new(441, 135, 358), wiki = "https://fischipedia.org/wiki/Captain_Ahab"},
        {name = "Captain Ahab (Alt)", pos = Vector3.new(362, 133, 294), wiki = "https://fischipedia.org/wiki/Captain_Ahab"},
        {name = "Red (NPC)", pos = Vector3.new(1020, 173, 9857), wiki = "https://fischipedia.org/wiki/Red_(NPC)"},
        {name = "Hollow", pos = Vector3.new(25, 0, 0), wiki = "https://fischipedia.org/wiki/Hollow"},
        {name = "Hollow (Alt)", pos = Vector3.new(7, 500, 0), wiki = "https://fischipedia.org/wiki/Hollow"},
        {name = "Witch", pos = Vector3.new(410, 135, 310), wiki = "https://fischipedia.org/wiki/Witch"},
        {name = "Shell Merchant", pos = Vector3.new(972, 132, 9921), wiki = "https://fischipedia.org/wiki/Shell_Merchant"},
        {name = "Paul", pos = Vector3.new(382, 137, 347), wiki = "https://fischipedia.org/wiki/Paul"},
        {name = "Ryder Vex", pos = Vector3.new(233, 116, 746), wiki = "https://fischipedia.org/wiki/Ryder_Vex"},
        {name = "Sporey Mom", pos = Vector3.new(1262, 129, 663), wiki = "https://fischipedia.org/wiki/Sporey_Mom"},
        {name = "Sporey Mom (Alt)", pos = Vector3.new(2934, 4268, 3042), wiki = "https://fischipedia.org/wiki/Sporey_Mom"},
        {name = "Lucas (Fischfest)", pos = Vector3.new(946, 132, 9894), wiki = "https://fischipedia.org/wiki/Lucas_(Fischfest)"},
        {name = "Daily Shopkeeper", pos = Vector3.new(229, 139, 42), wiki = "https://fischipedia.org/wiki/Daily_Shopkeeper"},
        {name = "Phineas", pos = Vector3.new(470, 150, 275), wiki = "https://fischipedia.org/wiki/Phineas"},
        {name = "Harry Fischer", pos = Vector3.new(396, 134, 381), wiki = "https://fischipedia.org/wiki/Harry_Fischer"},
        {name = "Wren", pos = Vector3.new(368, 135, 286), wiki = "https://fischipedia.org/wiki/Wren"},
        {name = "Lucas", pos = Vector3.new(450, 180, 175), wiki = "https://fischipedia.org/wiki/Lucas"},
        {name = "Travelling Merchant", pos = Vector3.new(2, 500, 0), wiki = "https://fischipedia.org/wiki/Travelling_Merchant"},
        {name = "Pierre", pos = Vector3.new(390, 135, 200), wiki = "https://fischipedia.org/wiki/Pierre"},
        {name = "Ringo", pos = Vector3.new(410, 135, 235), wiki = "https://fischipedia.org/wiki/Ringo"},
        {name = "Mike", pos = Vector3.new(210, 115, 640), wiki = "https://fischipedia.org/wiki/Mike"},
        {name = "Pilgrim", pos = Vector3.new(402, 134, 257), wiki = "https://fischipedia.org/wiki/Pilgrim"},
        {name = "Ocean", pos = Vector3.new(1230, 125, 575), wiki = "https://fischipedia.org/wiki/Ocean"},
        {name = "Idle Fishing NPC 1", pos = Vector3.new(72, 133, 2139), wiki = "https://fischipedia.org/wiki/Idle_Fishing_NPC_1"},
        {name = "Jak", pos = Vector3.new(474, 84, 758), wiki = "https://fischipedia.org/wiki/Jak"},
        {name = "Valentine's Day (NPC)", pos = Vector3.new(347, 136, 330), wiki = "https://fischipedia.org/wiki/Valentine%27s_Day_(NPC)"},
        {name = "Idle Fishing NPC Moosewood2", pos = Vector3.new(365, 132, 182), wiki = "https://fischipedia.org/wiki/Idle_Fishing_NPC_Moosewood2"},
        {name = "Challenges", pos = Vector3.new(337, 138, 312), wiki = "https://fischipedia.org/wiki/Challenges"},
        {name = "Idle Fishing NPC Moosewood", pos = Vector3.new(376, 136, 341), wiki = "https://fischipedia.org/wiki/Idle_Fishing_NPC_Moosewood"}
    },

    -- 🏪 Merchant NPCs
    ["Merchants"] = {
        {name = "Merchant (Moosewood)", pos = Vector3.new(465, 150, 230), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Merchant (Snowcap)", pos = Vector3.new(2715, 155, 2375), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Merchant (Ancient Isle)", pos = Vector3.new(6080, 195, 309), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Merchant (Azure Lagoon)", pos = Vector3.new(1389, 81, 2148), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Merchant (Isonade)", pos = Vector3.new(2416, 96, 411), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Merchant (Waveborne)", pos = Vector3.new(162, 116, 706), wiki = "https://fischipedia.org/wiki/Merchant"},
        {name = "Appraiser (Moosewood)", pos = Vector3.new(445, 150, 210), wiki = "https://fischipedia.org/wiki/Appraiser"},
        {name = "Appraiser (Waveborne)", pos = Vector3.new(141, 116, 699), wiki = "https://fischipedia.org/wiki/Appraiser"},
        {name = "Skin Merchant (Moosewood)", pos = Vector3.new(415, 135, 194), wiki = "https://fischipedia.org/wiki/Skin_Merchant"},
        {name = "Skin Merchant (Ancient Isle)", pos = Vector3.new(6031, 195, 267), wiki = "https://fischipedia.org/wiki/Skin_Merchant"},
        {name = "Skin Merchant (Snowcap)", pos = Vector3.new(2650, 142.3, 2534), wiki = "https://fischipedia.org/wiki/Skin_Merchant"},
        {name = "Skin Merchant (Waveborne)", pos = Vector3.new(457, 93, 742), wiki = "https://fischipedia.org/wiki/Skin_Merchant"},
        {name = "Egg Salesman (Moosewood)", pos = Vector3.new(404, 135, 312), wiki = "https://fischipedia.org/wiki/Egg_Salesman"},
        {name = "Egg Salesman (Waveborne)", pos = Vector3.new(453, 83, 791), wiki = "https://fischipedia.org/wiki/Egg_Salesman"}
    },

    -- 🏨 Inn Keepers
    ["Inn Keepers"] = {
        {name = "Inn Keeper (Moosewood)", pos = Vector3.new(490, 150, 245), wiki = "https://fischipedia.org/wiki/Inn_Keepers"},
        {name = "Inn Keeper (Snowcap)", pos = Vector3.new(2665, 155, 2395), wiki = "https://fischipedia.org/wiki/Inn_Keepers"},
        {name = "Inn Keeper (Ancient Isle)", pos = Vector3.new(6047, 198, 335), wiki = "https://fischipedia.org/wiki/Inn_Keepers"},
        {name = "Inn Keeper (Azure Lagoon)", pos = Vector3.new(1279, 124, 2313), wiki = "https://fischipedia.org/wiki/Inn_Keepers"},
        {name = "Inn Keeper (Waveborne)", pos = Vector3.new(158, 132, 657), wiki = "https://fischipedia.org/wiki/Inn_Keepers"},
        {name = "Inn Keeper (Gilded Arch)", pos = Vector3.new(345, 85, 2901), wiki = "https://fischipedia.org/wiki/Inn_Keepers"}
    },

    -- 🎣 Angler NPCs
    ["Anglers"] = {
        {name = "Angler (Moosewood)", pos = Vector3.new(480, 150, 295), wiki = "https://fischipedia.org/wiki/Angler"},
        {name = "Angler (Azure Lagoon)", pos = Vector3.new(1370, 81, 2151), wiki = "https://fischipedia.org/wiki/Angler"},
        {name = "Angler (Isonade)", pos = Vector3.new(2400, 84, 458), wiki = "https://fischipedia.org/wiki/Angler"},
        {name = "Angler (Pine Shoals)", pos = Vector3.new(347, 91, 1018), wiki = "https://fischipedia.org/wiki/Angler"},
        {name = "Angler (Waveborne)", pos = Vector3.new(58, 159, 860), wiki = "https://fischipedia.org/wiki/Angler"}
    },

    -- 🚢 Shipwright NPCs
    ["Shipwrights"] = {
        {name = "Shipwright (Moosewood)", pos = Vector3.new(360, 135, 260), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Snowcap)", pos = Vector3.new(2615, 135, 2400), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Ancient Isle 1)", pos = Vector3.new(5869, 143, 7), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Ancient Isle 2)", pos = Vector3.new(5511, 138, 586), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Snowcap 2)", pos = Vector3.new(2944, 137, 2397), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Ancient Isle 3)", pos = Vector3.new(6238, 137, 246), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Ancient Isle 4)", pos = Vector3.new(6293, 134, 888), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Azure Lagoon 1)", pos = Vector3.new(1303, 79, 2104), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Azure Lagoon 2)", pos = Vector3.new(1682, 78, 2331), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Waveborne)", pos = Vector3.new(391, 85, 824), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Isonade)", pos = Vector3.new(2382, 83, 493), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Pine Shoals)", pos = Vector3.new(1183, 81, 488), wiki = "https://fischipedia.org/wiki/Shipwright"},
        {name = "Shipwright (Gilded Arch)", pos = Vector3.new(369, 86, 2856), wiki = "https://fischipedia.org/wiki/Shipwright"}
    },

    -- 🌊 Sea Traveler NPCs
    ["Sea Travelers"] = {
        {name = "Sea Traveler (Terrapin)", pos = Vector3.new(140, 150, 2030), wiki = "https://fischipedia.org/wiki/Sea_Traveler"},
        {name = "Sea Traveler (Moosewood)", pos = Vector3.new(690, 170, 345), wiki = "https://fischipedia.org/wiki/Sea_Traveler"}
    },

    -- 📦 Sunken Chest Locations
    ["Sunken Chests"] = {
        {name = "Sunken Chest 1", pos = Vector3.new(798, 130, 1667), wiki = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 2", pos = Vector3.new(562, 130, 2455), wiki = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 3", pos = Vector3.new(613, 130, 498), wiki = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 4", pos = Vector3.new(393, 130, 2435), wiki = "https://fischipedia.org/wiki/Sunken_Chest"},
        {name = "Sunken Chest 5", pos = Vector3.new(285, 130, 564), wiki = "https://fischipedia.org/wiki/Sunken_Chest"}
    },

    -- 🏛️ Location-Based NPCs
    ["Ancient Isle NPCs"] = {
        {name = "Ancient Isle NPC 1", pos = Vector3.new(5833, 125, 401), wiki = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle NPC 2", pos = Vector3.new(5870, 160, 415), wiki = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle NPC 3", pos = Vector3.new(5966, 274, 846), wiki = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle NPC 4", pos = Vector3.new(6075, 195, 260), wiki = "https://fischipedia.org/wiki/Ancient_Isle"},
        {name = "Ancient Isle NPC 5", pos = Vector3.new(6000, 230, 591), wiki = "https://fischipedia.org/wiki/Ancient_Isle"}
    },

    -- ❄️ Snowcap Island NPCs
    ["Snowcap Island NPCs"] = {
        {name = "Snowcap Island NPC 1", pos = Vector3.new(2600, 150, 2400), wiki = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island NPC 2", pos = Vector3.new(2900, 150, 2500), wiki = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island NPC 3", pos = Vector3.new(2710, 190, 2560), wiki = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island NPC 4", pos = Vector3.new(2750, 135, 2505), wiki = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island NPC 5", pos = Vector3.new(2800, 280, 2565), wiki = "https://fischipedia.org/wiki/Snowcap_Island"},
        {name = "Snowcap Island NPC 6", pos = Vector3.new(2845, 180, 2700), wiki = "https://fischipedia.org/wiki/Snowcap_Island"}
    },

    -- 🐢 Terrapin Island NPCs
    ["Terrapin Island NPCs"] = {
        {name = "Terrapin Island NPC 1", pos = Vector3.new(10, 155, 2000), wiki = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island NPC 2", pos = Vector3.new(160, 125, 1970), wiki = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island NPC 3", pos = Vector3.new(25, 140, 1860), wiki = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island NPC 4", pos = Vector3.new(140, 150, 2050), wiki = "https://fischipedia.org/wiki/Terrapin_Island"},
        {name = "Terrapin Island NPC 5", pos = Vector3.new(35, 130, 1945), wiki = "https://fischipedia.org/wiki/Terrapin_Island"}
    },

    -- 🌊 Waveborne NPCs
    ["Waveborne NPCs"] = {
        {name = "Waveborne NPC 1", pos = Vector3.new(360, 90, 780), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 2", pos = Vector3.new(400, 85, 737), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 3", pos = Vector3.new(55, 160, 833), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 4", pos = Vector3.new(165, 115, 730), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 5", pos = Vector3.new(165, 115, 720), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 6", pos = Vector3.new(223, 120, 815), wiki = "https://fischipedia.org/wiki/Waveborne"},
        {name = "Waveborne NPC 7", pos = Vector3.new(405, 85, 862), wiki = "https://fischipedia.org/wiki/Waveborne"}
    },

    -- 🏘️ Moosewood General NPCs  
    ["Moosewood NPCs"] = {
        {name = "Moosewood General 1", pos = Vector3.new(350, 135, 250), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 2", pos = Vector3.new(412, 135, 233), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 3", pos = Vector3.new(385, 135, 280), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 4", pos = Vector3.new(465, 150, 235), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 5", pos = Vector3.new(480, 180, 150), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 6", pos = Vector3.new(515, 150, 285), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 7", pos = Vector3.new(365, 135, 275), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 8", pos = Vector3.new(370, 135, 250), wiki = "https://fischipedia.org/wiki/Moosewood"},
        {name = "Moosewood General 9", pos = Vector3.new(315, 135, 335), wiki = "https://fischipedia.org/wiki/Moosewood"}
    }
}

-- 🔍 Helper Functions
function NPCTeleportSystem.getAllNPCs()
    local allNPCs = {}
    for category, npcs in pairs(NPC_DATABASE) do
        for _, npc in pairs(npcs) do
            npc.category = category
            table.insert(allNPCs, npc)
        end
    end
    return allNPCs
end

function NPCTeleportSystem.getCategoryNames()
    local categories = {}
    for category, _ in pairs(NPC_DATABASE) do
        table.insert(categories, category)
    end
    table.sort(categories)
    return categories
end

function NPCTeleportSystem.getNPCNames(category)
    if not category or not NPC_DATABASE[category] then
        return {}
    end
    
    local names = {}
    for _, npc in pairs(NPC_DATABASE[category]) do
        table.insert(names, npc.name)
    end
    table.sort(names)
    return names
end

function NPCTeleportSystem.getNPCByName(npcName, category)
    if category and NPC_DATABASE[category] then
        for _, npc in pairs(NPC_DATABASE[category]) do
            if npc.name == npcName then
                return npc
            end
        end
    else
        -- Search all categories
        for _, npcs in pairs(NPC_DATABASE) do
            for _, npc in pairs(npcs) do
                if npc.name == npcName then
                    return npc
                end
            end
        end
    end
    return nil
end

-- 🔍 Search Functions
function NPCTeleportSystem.searchNPCs(query)
    local results = {}
    local searchTerm = string.lower(query or "")
    
    if searchTerm == "" then
        return results
    end
    
    for category, npcs in pairs(NPC_DATABASE) do
        for _, npc in pairs(npcs) do
            local npcNameLower = string.lower(npc.name)
            local categoryLower = string.lower(category)
            
            -- Search in name and category
            if string.find(npcNameLower, searchTerm) or string.find(categoryLower, searchTerm) then
                table.insert(results, {
                    name = npc.name,
                    category = category,
                    pos = npc.pos,
                    wiki = npc.wiki,
                    relevance = string.find(npcNameLower, searchTerm) and 1 or 0.5
                })
            end
        end
    end
    
    -- Sort by relevance
    table.sort(results, function(a, b)
        return a.relevance > b.relevance
    end)
    
    -- Limit results
    local limitedResults = {}
    for i = 1, math.min(CONFIG.SEARCH_LIMIT, #results) do
        table.insert(limitedResults, results[i])
    end
    
    return limitedResults
end

-- 📊 Distance Functions
function NPCTeleportSystem.getNearestNPCs(category, limit)
    local playerPos = RootPart.Position
    local nearbyNPCs = {}
    
    local npcsToSearch = category and NPC_DATABASE[category] or NPCTeleportSystem.getAllNPCs()
    
    for _, npc in pairs(npcsToSearch) do
        local distance = (npc.pos - playerPos).Magnitude
        if distance <= CONFIG.MAX_DISTANCE then
            table.insert(nearbyNPCs, {
                npc = npc,
                distance = distance
            })
        end
    end
    
    -- Sort by distance
    table.sort(nearbyNPCs, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Limit results
    local limitedResults = {}
    local maxResults = limit or 5
    for i = 1, math.min(maxResults, #nearbyNPCs) do
        table.insert(limitedResults, nearbyNPCs[i])
    end
    
    return limitedResults
end

-- 🚀 Teleport Functions
function NPCTeleportSystem.teleportToNPC(npcName, category, method)
    local npc = NPCTeleportSystem.getNPCByName(npcName, category)
    if not npc then
        return false, "❌ NPC '" .. npcName .. "' not found!"
    end
    
    local targetPosition = npc.pos + CONFIG.SAFETY_OFFSET
    method = method or "CFrame"
    
    -- Update character references
    Character = LocalPlayer.Character
    if not Character then
        return false, "❌ Character not found!"
    end
    
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        return false, "❌ HumanoidRootPart not found!"
    end
    
    local success = false
    local message = ""
    
    if method == "CFrame" then
        success, message = NPCTeleportSystem.teleportCFrame(targetPosition)
    elseif method == "TweenService" then
        success, message = NPCTeleportSystem.teleportTween(targetPosition)
    elseif method == "RequestTeleportCFrame" then
        success, message = NPCTeleportSystem.teleportRequestCFrame(targetPosition)
    else
        success, message = NPCTeleportSystem.teleportCFrame(targetPosition)
    end
    
    if success then
        message = "✅ Teleported to " .. npc.name .. " (" .. (npc.category or category or "Unknown") .. ")"
    end
    
    return success, message
end

function NPCTeleportSystem.teleportCFrame(position)
    pcall(function()
        RootPart.CFrame = CFrame.new(position)
    end)
    return true, "✅ Instant teleport completed"
end

function NPCTeleportSystem.teleportTween(position)
    local tweenInfo = TweenInfo.new(
        CONFIG.TWEEN_TIME,
        CONFIG.TWEEN_STYLE,
        CONFIG.TWEEN_DIRECTION
    )
    
    local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    
    return true, "✅ Smooth teleport started"
end

function NPCTeleportSystem.teleportRequestCFrame(position)
    local success = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("RequestTeleportCFrame")
        if remote then
            remote:FireServer(CFrame.new(position))
        else
            RootPart.CFrame = CFrame.new(position)
        end
    end)
    
    return success, success and "✅ Safe teleport completed" or "❌ Safe teleport failed"
end

-- 🏃‍♂️ Auto Tour Function
function NPCTeleportSystem.autoNPCTour(category, delay, method)
    if not NPC_DATABASE[category] then
        return false, "❌ Category '" .. category .. "' not found!"
    end
    
    delay = delay or 3
    method = method or "CFrame"
    local npcs = NPC_DATABASE[category]
    
    spawn(function()
        for i, npc in pairs(npcs) do
            wait(delay)
            local success, msg = NPCTeleportSystem.teleportToNPC(npc.name, category, method)
            print(string.format("🎯 [%d/%d] %s", i, #npcs, msg))
        end
        print("🎉 NPC Tour completed! Visited " .. #npcs .. " NPCs in " .. category)
    end)
    
    return true, "🚀 Auto NPC Tour started for " .. category .. " (" .. #npcs .. " NPCs)"
end

-- 📊 Statistics Function
function NPCTeleportSystem.getStatistics()
    local stats = {
        totalNPCs = 0,
        totalCategories = 0,
        categoryCounts = {}
    }
    
    for category, npcs in pairs(NPC_DATABASE) do
        stats.totalCategories = stats.totalCategories + 1
        stats.categoryCounts[category] = #npcs
        stats.totalNPCs = stats.totalNPCs + #npcs
    end
    
    return stats
end

-- 📋 Get Popular NPCs
function NPCTeleportSystem.getPopularNPCs()
    return {
        {name = "Merchant (Moosewood)", category = "Merchants", reason = "Sells fishing rods and equipment"},
        {name = "Henry", category = "Individual NPCs", reason = "Tutorial NPC"},
        {name = "Appraiser (Moosewood)", category = "Merchants", reason = "Appraises fish value"},
        {name = "Angler (Moosewood)", category = "Anglers", reason = "Sells baits and fishing gear"},
        {name = "Inn Keeper (Moosewood)", category = "Inn Keepers", reason = "Rest point and storage"},
        {name = "Shipwright (Moosewood)", category = "Shipwrights", reason = "Ship upgrades and repairs"},
        {name = "Daily Shopkeeper", category = "Individual NPCs", reason = "Daily items and rewards"},
        {name = "AFK Rewards", category = "Individual NPCs", reason = "Collect AFK fishing rewards"},
        {name = "Shell Merchant", category = "Individual NPCs", reason = "Trades shells for rewards"},
        {name = "Witch", category = "Individual NPCs", reason = "Magical items and potions"}
    }
end

-- 🎯 Quick Access Functions
function NPCTeleportSystem.teleportToMerchant(location)
    location = location or "Moosewood"
    local merchantName = "Merchant (" .. location .. ")"
    return NPCTeleportSystem.teleportToNPC(merchantName, "Merchants")
end

function NPCTeleportSystem.teleportToAngler(location)
    location = location or "Moosewood"
    local anglerName = "Angler (" .. location .. ")"
    return NPCTeleportSystem.teleportToNPC(anglerName, "Anglers")
end

function NPCTeleportSystem.teleportToShipwright(location)
    location = location or "Moosewood"
    local shipwrightName = "Shipwright (" .. location .. ")"
    return NPCTeleportSystem.teleportToNPC(shipwrightName, "Shipwrights")
end

-- 🔄 Refresh Character References
function NPCTeleportSystem.refreshCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end

-- 📅 Event Handlers
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end)

-- 🎉 System Ready
print("🤖 Enhanced NPC Teleport System V1.0 Loaded!")
print("📊 Database: " .. NPCTeleportSystem.getStatistics().totalNPCs .. " NPCs across " .. NPCTeleportSystem.getStatistics().totalCategories .. " categories")
print("🌐 Source: NPCgps.json - Official Fisch Wiki Database")

return NPCTeleportSystem
