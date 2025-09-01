--[[
    Teleport System for Roblox Fisch
    Created by: MELLISAEFFENDY
    Description: Comprehensive teleport system with safe teleportation
    Version: 1.0
    GitHub: https://github.com/MELLISAEFFENDY/apakah
    
    🌍 Features:
    - Place Teleports (27 locations)
    - Fish Area Teleports (27 areas) 
    - NPC Teleports (23 NPCs)
    - Item Teleports (20 items/rods)
    - Player Teleports
    - Safe Teleportation with error handling
]]

local TeleportSystem = {}

--// Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--// Update character and HRP when character spawns
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

--// Teleport Locations Data
TeleportSystem.teleportSpots = {
    altar = CFrame.new(1296.320068359375, -808.5519409179688, -298.93817138671875),
    arch = CFrame.new(998.966796875, 126.6849365234375, -1237.1434326171875),
    birch = CFrame.new(1742.3203125, 138.25787353515625, -2502.23779296875),
    brine = CFrame.new(-1794.10596, -145.849701, -3302.92358, -5.16176224e-05, 3.10316682e-06, 0.99999994, 0.119907647, 0.992785037, 3.10316682e-06, -0.992785037, 0.119907647, -5.16176224e-05),
    deep = CFrame.new(-1510.88672, -237.695053, -2852.90674, 0.573604643, 0.000580655003, 0.81913209, -0.000340352941, 0.999999762, -0.000470530824, -0.819132209, -8.89541116e-06, 0.573604763),
    deepshop = CFrame.new(-979.196411, -247.910156, -2699.87207, 0.587748766, 0, 0.809043527, 0, 1, 0, -0.809043527, 0, 0.587748766),
    enchant = CFrame.new(1296.320068359375, -808.5519409179688, -298.93817138671875),
    executive = CFrame.new(-29.836761474609375, -250.48486328125, 199.11614990234375),
    keepers = CFrame.new(1296.320068359375, -808.5519409179688, -298.93817138671875),
    mod_house = CFrame.new(-30.205902099609375, -249.40594482421875, 204.0529022216797),
    moosewood = CFrame.new(383.10113525390625, 131.2406005859375, 243.93385314941406),
    mushgrove = CFrame.new(2501.48583984375, 127.7583236694336, -720.699462890625),
    roslit = CFrame.new(-1476.511474609375, 130.16842651367188, 671.685302734375),
    snow = CFrame.new(2648.67578125, 139.06605529785156, 2521.29736328125),
    snowcap = CFrame.new(2648.67578125, 139.06605529785156, 2521.29736328125),
    spike = CFrame.new(-1254.800537109375, 133.88555908203125, 1554.2021484375),
    statue = CFrame.new(72.8836669921875, 138.6964874267578, -1028.4193115234375),
    sunstone = CFrame.new(-933.259705, 128.143951, -1119.52063, -0.342042685, 0, -0.939684391, 0, 1, 0, 0.939684391, 0, -0.342042685),
    swamp = CFrame.new(2501.48583984375, 127.7583236694336, -720.699462890625),
    terrapin = CFrame.new(-143.875244140625, 141.1676025390625, 1909.6070556640625),
    trident = CFrame.new(-1479.48987, -228.710632, -2391.39307, 0.0435845852, 0, 0.999049723, 0, 1, 0, -0.999049723, 0, 0.0435845852),
    vertigo = CFrame.new(-112.007278, -492.901093, 1040.32788, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    volcano = CFrame.new(-1888.52319, 163.847565, 329.238281, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    wilson = CFrame.new(2938.80591, 277.474762, 2567.13379, 0.4648332, 0, 0.885398269, 0, 1, 0, -0.885398269, 0, 0.4648332),
    wilsons_rod = CFrame.new(2879.2085, 135.07663, 2723.64233, 0.970463336, -0.168695927, -0.172460333, 0.141582936, -0.180552125, 0.973321974, -0.195333466, -0.968990743, -0.151334763),
    depths = CFrame.new(1294.50, -701.38, 1599.49),
    forsaken = CFrame.new(-2509.66, 135.71, 1572.59),
}

TeleportSystem.fishAreas = {
    roslit_bay = CFrame.new(-1663.73889, 149.234116, 495.498016, 0.0380855016, 4.08820178e-08, -0.999274492, 5.74658472e-08, 1, 4.3101906e-08, 0.999274492, -5.90657123e-08, 0.0380855016),
    ocean = CFrame.new(7665.104, 125.444443, 2601.59351, 0.999966085, -0.000609769544, -0.00821684115, 0.000612694537, 0.999999762, 0.000353460142, 0.00821662322, -0.000358482561, 0.999966204),
    snowcap_pond = CFrame.new(2778.09009, 283.283783, 2580.323, 1, 7.17688531e-09, -2.22843701e-05, -7.17796267e-09, 1, -4.83369114e-08, 2.22843701e-05, 4.83370712e-08, 1),
    moosewood_docks = CFrame.new(343.2359924316406, 133.61595153808594, 267.0580139160156),
    deep_ocean = CFrame.new(3569.07153, 125.480949, 6697.12695, 0.999980748, -0.00188910461, -0.00591362361, 0.00193980196, 0.999961317, 0.00857902411, 0.00589718809, -0.00859032944, 0.9999457),
    vertigo = CFrame.new(-137.697098, -736.86377, 1233.15271, 1, -1.61821543e-08, -2.01375751e-05, 1.6184277e-08, 1, 1.05423091e-07, 2.01375751e-05, -1.0542341e-07, 1),
    snowcap_ocean = CFrame.new(3088.66699, 131.534332, 2587.11304, 1, 4.30694858e-09, -1.19097813e-14, -4.30694858e-09, 1, -2.80603398e-08, 1.17889275e-14, 2.80603398e-08, 1),
    harvesters_spike = CFrame.new(-1234.61523, 125.228767, 1748.57166, 0.999991536, -0.000663080777, -0.00405627443, 0.000725277001, 0.999881923, 0.0153511297, 0.00404561637, -0.0153539423, 0.999873936),
    sunstone = CFrame.new(-845.903992, 133.172211, -1163.57776, 1, -7.93465915e-09, -2.09446498e-05, 7.93544608e-09, 1, 3.75741536e-08, 2.09446498e-05, -3.75743205e-08, 1),
    roslit_bay_ocean = CFrame.new(-1708.09302, 155.000015, 384.928009, 1, -9.84460868e-09, -3.24939563e-15, 9.84460868e-09, 1, 4.66220271e-08, 2.79042003e-15, -4.66220271e-08, 1),
    moosewood_pond = CFrame.new(509.735992, 152.000031, 302.173004, 1, -1.78487678e-08, -8.1329488e-14, 1.78487678e-08, 1, 8.45405168e-08, 7.98205428e-14, -8.45405168e-08, 1),
    terrapin_ocean = CFrame.new(58.6469994, 135.499985, 2147.41699, 1, 2.09643041e-08, -5.6023784e-15, -2.09643041e-08, 1, -9.92988376e-08, 3.52064755e-15, 9.92988376e-08, 1),
    isonade = CFrame.new(-1060.99902, 121.164787, 953.996033, 0.999958456, 0.000633197487, -0.00909138657, -0.000568434712, 0.999974489, 0.00712434994, 0.00909566507, -0.00711888634, 0.999933302),
    moosewood_ocean = CFrame.new(-167.642715, 125.19548, 248.009521, 0.999997199, -0.000432743778, -0.0023210498, 0.000467110571, 0.99988997, 0.0148265222, 0.00231437827, -0.0148275653, 0.999887407),
    roslit_pond = CFrame.new(-1811.96997, 148.047089, 592.642517, 1, 1.12983072e-08, -2.16573972e-05, -1.12998171e-08, 1, -6.97014357e-08, 2.16573972e-05, 6.97016844e-08, 1),
    moosewood_ocean_mythical = CFrame.new(252.802994, 135.849625, 36.8839989, 1, -1.98115071e-08, -4.50667564e-15, 1.98115071e-08, 1, 1.22230617e-07, 2.08510289e-15, -1.22230617e-07, 1),
    terrapin_olm = CFrame.new(22.0639992, 182.000015, 1944.36804, 1, 1.14953362e-08, -2.7011112e-15, -1.14953362e-08, 1, -7.09263972e-08, 1.88578841e-15, 7.09263972e-08, 1),
    the_arch = CFrame.new(1283.30896, 130.923569, -1165.29602, 1, -5.89772364e-09, -3.3183043e-15, 5.89772364e-09, 1, 3.63913486e-08, 3.10367822e-15, -3.63913486e-08, 1),
    scallop_ocean = CFrame.new(23.2255898, 125.236847, 738.952271, 0.999990165, -0.00109633175, -0.00429760758, 0.00115595153, 0.999902785, 0.0138949333, 0.00428195624, -0.013899764, 0.999894202),
    mushgrove_stone = CFrame.new(2555.99731, 140.100632, -640.015198, 1, -1.46543742e-08, -3.53710421e-15, 1.46543742e-08, 1, 9.04720633e-08, 1.75355831e-15, -9.04720633e-08, 1),
    keepers_altar = CFrame.new(1311.37061, -808.508911, -101.282776, 1, -1.25550149e-08, -3.13493205e-15, 1.25550149e-08, 1, 7.74785211e-08, 1.00467395e-15, -7.74785211e-08, 1),
    lava = CFrame.new(-1863.24268, 160.999939, 286.991058, 1, -2.17496063e-08, -6.10151291e-15, 2.17496063e-08, 1, 1.34281912e-07, 1.28477047e-15, -1.34281912e-07, 1),
    roslit_pond_seaweed = CFrame.new(-1793.95239, 148.047104, 639.168762, 1, 1.09795764e-08, -2.38419096e-15, -1.09795764e-08, 1, -6.77903009e-08, 1.25467721e-16, 6.77903009e-08, 1),
    depths_fishing_spot = CFrame.new(1023.84, -747.13, 1342.17),
    depths_event_spot = CFrame.new(1185.62, -709.63, 1467.38),
    forsaken_pond = CFrame.new(-2658.46, 135.72, 1584.99),
}

TeleportSystem.npcLocations = {
    witch = CFrame.new(409.638092, 134.451523, 311.403687, -0.74079144, 0, 0.671735108, 0, 1, 0, -0.671735108, 0, -0.74079144),
    quiet_synph = CFrame.new(566.263245, 152.000031, 353.872101, -0.753558397, 0, -0.657381535, 0, 1, 0, 0.657381535, 0, -0.753558397),
    pierre = CFrame.new(391.38855, 135.348389, 196.712387, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    phineas = CFrame.new(469.912292, 150.69342, 277.954987, 0.886104584, -0, -0.46348536, 0, 1, -0, 0.46348536, 0, 0.886104584),
    paul = CFrame.new(381.741882, 136.500031, 341.891022, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    shipwright = CFrame.new(357.972595, 133.615967, 258.154541, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    angler = CFrame.new(480.102478, 150.501053, 302.226898, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    marc = CFrame.new(466.160034, 151.00206, 224.497086, -0.996853352, 0, -0.0792675018, 0, 1, 0, 0.0792675018, 0, -0.996853352),
    lucas = CFrame.new(449.33963, 181.999893, 180.689072, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    lantern_keeper = CFrame.new(-39.0456772, -246.599976, 195.644363, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    lantern_keeper2 = CFrame.new(-17.4230175, -304.970276, -14.529892, -1, 0, 0, 0, 1, 0, 0, 0, -1),
    inn_keeper = CFrame.new(487.458466, 150.800034, 231.498932, -0.564704418, 0, -0.825293183, 0, 1, 0, 0.825293183, 0, -0.564704418),
    roslit_keeper = CFrame.new(-1512.37891, 134.500031, 631.24353, 0.738236904, 0, -0.674541533, 0, 1, 0, 0.674541533, 0, 0.738236904),
    fishing_npc_1 = CFrame.new(-1429.04138, 134.371552, 686.034424, 0, 0.0168599077, -0.999857903, 0, 0.999857903, 0.0168599077, 1, 0, 0),
    fishing_npc_2 = CFrame.new(-1778.55408, 149.791779, 648.097107, 0.183140755, 0.0223737024, -0.982832015, 0, 0.999741018, 0.0227586292, 0.983086705, -0.00416803267, 0.183093324),
    fishing_npc_3 = CFrame.new(-1778.26807, 147.83165, 653.258606, -0.129575253, 0.501478612, 0.855411887, -2.44146213e-05, 0.862683058, -0.505744994, -0.991569638, -0.0655529201, -0.111770131),
    henry = CFrame.new(483.539307, 152.383057, 236.296143, -0.789363742, 0, 0.613925934, 0, 1, 0, -0.613925934, 0, -0.789363742),
    daisy = CFrame.new(581.550049, 165.490753, 213.499969, -0.964885235, 0, -0.262671858, 0, 1, 0, 0.262671858, 0, -0.964885235),
    appraiser = CFrame.new(453.182373, 150.500031, 206.908783, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    merchant = CFrame.new(416.690521, 130.302628, 342.765289, -0.249025017, -0.0326484665, 0.967946589, -0.0040341015, 0.999457955, 0.0326734781, -0.968488574, 0.00423171744, -0.249021754),
    mod_keeper = CFrame.new(-39.0905838, -245.141144, 195.837891, -0.948549569, -0.0898146331, -0.303623199, -0.197293222, 0.91766715, 0.34490931, 0.247647122, 0.387066364, -0.888172567),
    ashe = CFrame.new(-1709.94055, 149.862411, 729.399536, -0.92290163, 0.0273250472, -0.384064913, 0, 0.997478604, 0.0709675401, 0.385035753, 0.0654960647, -0.920574605),
    alfredrickus = CFrame.new(-1520.60632, 142.923264, 764.522034, 0.301733732, 0.390740901, -0.869642735, 0.0273988936, 0.908225596, 0.417582989, 0.952998459, -0.149826124, 0.26333645),
    depths_merchant = CFrame.new(949.04, -711.56, 1262.58),
}

TeleportSystem.itemLocations = {
    training_rod = CFrame.new(457.693848, 148.357529, 230.414307, 1, -0, 0, 0, 0.975410998, 0.220393807, -0, -0.220393807, 0.975410998),
    plastic_rod = CFrame.new(454.425385, 148.169739, 229.172424, 0.951755166, 0.0709736273, -0.298537821, -3.42726707e-07, 0.972884834, 0.231290117, 0.306858391, -0.220131472, 0.925948203),
    lucky_rod = CFrame.new(446.085999, 148.253006, 222.160004, 0.974526405, -0.22305499, 0.0233404674, 0.196993902, 0.901088715, 0.386306256, -0.107199371, -0.371867687, 0.922075212),
    kings_rod = CFrame.new(1375.57642, -810.201721, -303.509247, -0.7490201, 0.662445903, -0.0116144121, -0.0837960541, -0.0773290396, 0.993478119, 0.657227278, 0.745108068, 0.113431036),
    flimsy_rod = CFrame.new(471.107697, 148.36171, 229.642441, 0.841614008, 0.0774728209, -0.534493923, 0.00678436086, 0.988063335, 0.153898612, 0.540036798, -0.13314943, 0.831042409),
    nocturnal_rod = CFrame.new(-141.874237, -515.313538, 1139.04529, 0.161644459, -0.98684907, 1.87754631e-05, 1.87754631e-05, 2.21133232e-05, 1, -0.98684907, -0.161644459, 2.21133232e-05),
    fast_rod = CFrame.new(447.183563, 148.225739, 220.187454, 0.981104493, 1.26492232e-05, 0.193478703, -0.0522461236, 0.962867677, 0.264870107, -0.186291039, -0.269973755, 0.944674432),
    carbon_rod = CFrame.new(454.083618, 150.590073, 225.328827, 0.985374212, -0.170404434, 1.41561031e-07, 1.41561031e-07, 1.7285347e-06, 1, -0.170404434, -0.985374212, 1.7285347e-06),
    long_rod = CFrame.new(485.695038, 171.656326, 145.746109, -0.630167365, -0.776459217, -5.33461571e-06, 5.33461571e-06, -1.12056732e-05, 1, -0.776459217, 0.630167365, 1.12056732e-05),
    mythical_rod = CFrame.new(389.716705, 132.588821, 314.042847, 0, 1, 0, 0, 0, -1, -1, 0, 0),
    midas_rod = CFrame.new(401.981659, 133.258316, 326.325745, 0.16456604, 0.986365497, 0.00103566051, 0.00017541647, 0.00102066994, -0.999999464, -0.986366034, 0.1645661, -5.00679016e-06),
    trident_rod = CFrame.new(-1484.34192, -222.325562, -2194.77002, -0.466092706, -0.536795318, 0.703284025, -0.319611132, 0.843386114, 0.43191275, -0.824988723, -0.0234660208, -0.56466186),
    enchanted_altar = CFrame.new(1310.54651, -799.469604, -82.7303467, 0.999973059, 0, 0.00733732153, 0, 1, 0, -0.00733732153, 0, 0.999973059),
    bait_crate = CFrame.new(384.57513427734375, 135.3519287109375, 337.5340270996094),
    quality_bait_crate = CFrame.new(-177.876, 144.472, 1932.844),
    crab_cage = CFrame.new(474.803589, 149.664566, 229.49469, -0.721874595, 0, 0.692023814, 0, 1, 0, -0.692023814, 0, -0.721874595),
    gps = CFrame.new(517.896729, 149.217636, 284.856842, 7.39097595e-06, -0.719539165, -0.694451928, -1, -7.39097595e-06, -3.01003456e-06, -3.01003456e-06, 0.694451928, -0.719539165),
    basic_diving_gear = CFrame.new(369.174774, 132.508835, 248.705368, 0.228398502, -0.158300221, -0.96061182, 1.58026814e-05, 0.986692965, -0.162594408, 0.973567724, 0.037121132, 0.225361705),
    fish_radar = CFrame.new(365.75177, 134.50499, 274.105804, 0.704499543, -0.111681774, -0.70086211, 1.32396817e-05, 0.987542748, -0.157350808, 0.709704578, 0.110844307, 0.695724905),
    rod_of_the_depths = CFrame.new(1704.92, -902.53, 1442.00)
}

--// Safe Teleport Function
function TeleportSystem.safeTeleport(targetCFrame, teleportName)
    local success, errorMsg = pcall(function()
        -- Safely get character and HumanoidRootPart
        local character = LocalPlayer.Character
        if not character then
            character = LocalPlayer.CharacterAdded:Wait()
        end
        
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if not hrp then
            error("HumanoidRootPart not found or timeout")
        end
        
        if typeof(targetCFrame) ~= "CFrame" then
            error("Invalid CFrame provided: " .. tostring(targetCFrame))
        end
        
        -- Ensure the CFrame is valid
        if not targetCFrame.Position then
            error("CFrame has no valid position")
        end
        
        -- Store current position for safety
        local oldPosition = hrp.CFrame
        
        -- Perform teleport with additional safety checks
        if hrp.Parent and hrp.Parent == character then
            hrp.CFrame = targetCFrame
        else
            error("HumanoidRootPart is not properly parented")
        end
        
        -- Wait a frame to ensure teleport completed
        wait(0.1)
        
        return true
    end)
    
    if success then
        return true, "Successfully teleported to " .. (teleportName or "location")
    else
        return false, "Teleport failed: " .. tostring(errorMsg)
    end
end

--// Get Formatted Location Lists
function TeleportSystem.getPlaceNames()
    local names = {}
    for name, _ in pairs(TeleportSystem.teleportSpots) do
        local formattedName = name:gsub("_", " ")
        -- Capitalize first letter of each word
        formattedName = formattedName:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        table.insert(names, formattedName)
    end
    table.sort(names)
    return names
end

function TeleportSystem.getFishAreaNames()
    local names = {}
    for name, _ in pairs(TeleportSystem.fishAreas) do
        local formattedName = name:gsub("_", " ")
        -- Capitalize first letter of each word
        formattedName = formattedName:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        table.insert(names, formattedName)
    end
    table.sort(names)
    return names
end

function TeleportSystem.getNPCNames()
    local names = {}
    for name, _ in pairs(TeleportSystem.npcLocations) do
        local formattedName = name:gsub("_", " ")
        -- Capitalize first letter of each word
        formattedName = formattedName:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        table.insert(names, formattedName)
    end
    table.sort(names)
    return names
end

function TeleportSystem.getItemNames()
    local names = {}
    for name, _ in pairs(TeleportSystem.itemLocations) do
        local formattedName = name:gsub("_", " ")
        -- Capitalize first letter of each word
        formattedName = formattedName:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        table.insert(names, formattedName)
    end
    table.sort(names)
    return names
end

--// Teleport Functions
function TeleportSystem.teleportToPlace(placeName)
    local key = placeName:lower():gsub(" ", "_")
    local targetCFrame = TeleportSystem.teleportSpots[key]
    
    if targetCFrame then
        return TeleportSystem.safeTeleport(targetCFrame, placeName)
    else
        return false, "Place '" .. placeName .. "' not found"
    end
end

function TeleportSystem.teleportToFishArea(areaName)
    local key = areaName:lower():gsub(" ", "_")
    local targetCFrame = TeleportSystem.fishAreas[key]
    
    if targetCFrame then
        return TeleportSystem.safeTeleport(targetCFrame, areaName)
    else
        return false, "Fish area '" .. areaName .. "' not found"
    end
end

function TeleportSystem.teleportToNPC(npcName)
    local key = npcName:lower():gsub(" ", "_")
    local targetCFrame = TeleportSystem.npcLocations[key]
    
    if targetCFrame then
        return TeleportSystem.safeTeleport(targetCFrame, npcName)
    else
        return false, "NPC '" .. npcName .. "' not found"
    end
end

function TeleportSystem.teleportToItem(itemName)
    local key = itemName:lower():gsub(" ", "_")
    local targetCFrame = TeleportSystem.itemLocations[key]
    
    if targetCFrame then
        return TeleportSystem.safeTeleport(targetCFrame, itemName)
    else
        return false, "Item '" .. itemName .. "' not found"
    end
end

function TeleportSystem.teleportToPlayer(playerName)
    local success, errorMsg = pcall(function()
        local targetPlayer = Players:FindFirstChild(playerName)
        if not targetPlayer then
            error("Player '" .. playerName .. "' not found")
        end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            error("Player '" .. playerName .. "' character not found")
        end
        
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            error("Player '" .. playerName .. "' HumanoidRootPart not found")
        end
        
        return TeleportSystem.safeTeleport(targetHRP.CFrame, "Player " .. playerName)
    end)
    
    if success then
        return true, "Successfully teleported to player " .. playerName
    else
        return false, tostring(errorMsg)
    end
end

--// Utility Functions
function TeleportSystem.getPlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    table.sort(playerNames)
    return playerNames
end

function TeleportSystem.getTeleportHistory()
    -- This could be expanded to track teleport history
    return {}
end

--// Statistics
TeleportSystem.stats = {
    totalTeleports = 0,
    successfulTeleports = 0,
    failedTeleports = 0,
    lastTeleportTime = 0,
    averageTime = 0
}

function TeleportSystem.updateStats(success, teleportTime)
    TeleportSystem.stats.totalTeleports = TeleportSystem.stats.totalTeleports + 1
    TeleportSystem.stats.lastTeleportTime = teleportTime or tick()
    
    if success then
        TeleportSystem.stats.successfulTeleports = TeleportSystem.stats.successfulTeleports + 1
    else
        TeleportSystem.stats.failedTeleports = TeleportSystem.stats.failedTeleports + 1
    end
    
    -- Calculate success rate
    TeleportSystem.stats.successRate = (TeleportSystem.stats.successfulTeleports / TeleportSystem.stats.totalTeleports) * 100
end

function TeleportSystem.getStats()
    return TeleportSystem.stats
end

function TeleportSystem.resetStats()
    TeleportSystem.stats = {
        totalTeleports = 0,
        successfulTeleports = 0,
        failedTeleports = 0,
        lastTeleportTime = 0,
        averageTime = 0,
        successRate = 0
    }
end

--// Initialize
function TeleportSystem.init()
    print("🌍 Teleport System v1.0 - Loaded successfully!")
    print("📍 Available locations:")
    print("   • " .. #TeleportSystem.getPlaceNames() .. " Places")
    print("   • " .. #TeleportSystem.getFishAreaNames() .. " Fish Areas") 
    print("   • " .. #TeleportSystem.getNPCNames() .. " NPCs")
    print("   • " .. #TeleportSystem.getItemNames() .. " Items")
    return TeleportSystem
end

return TeleportSystem
