Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================

Config.blowtorchTime = math.random(5000, 6000);
Config.commissionPercentage = 0.2 -- 20% -- you need to changed this value inside swkeep-tablet too!

local presets = {
    ['tiny'] = {
        [1] = { lable = "10 kg", size = 10 * 1000, price = 2000 },
        [2] = { lable = "15 kg", size = 15 * 1000, price = 4000 },
    },
    ['small'] = {
        [1] = { lable = "20 kg", size = 20 * 1000, price = 5000 },
        [2] = { lable = "40 kg", size = 40 * 1000, price = 10000 },
    },
    ['medium'] = {
        [1] = { lable = "50 kg", size = 50 * 1000, price = 1100 },
        [2] = { lable = "75 kg", size = 75 * 1000, price = 22000 },
        [3] = { lable = "100 kg", size = 100 * 1000, price = 33000 },
        [4] = { lable = "150 kg", size = 150 * 1000, price = 44000 },
        [5] = { lable = "200 kg", size = 200 * 1000, price = 55000 },
    },
    ['large'] = {
        [1] = { lable = "100 kg", size = 100 * 1000, price = 60000 },
        [2] = { lable = "200 kg", size = 200 * 1000, price = 110000 },
    },
    ['large_plus'] = {
        [1] = { lable = "250 kg", size = 250 * 1000, price = 120000 },
        [2] = { lable = "500 kg", size = 500 * 1000, price = 210000 },
    },
}

Config.Vehicles = {
    -- table keys are vehicles classes https://docs.fivem.net/natives/?_0x29439776AAA00A62
    [0] = {
        -- Compacts
    },
    [1] = {
        -- Sedans
    },
    [2] = {
        -- SUVs
    },
    [3] = {
        -- Coupes
    },
    [4] = {
        -- Muscle
    },
    [5] = {
        -- Sports Classics
    },
    [6] = {
        -- Sports
    },
    [7] = {
        -- Super
    },
    [8] = {
        -- Motorcycles
    },

    [9] = {
        -- Off-road
        ["dubsta3"] = {
            minCarryCapacity = 30000,
            maxCarryCapacity = 150000,
            upgradeList = presets.large
        },
        ['Default'] = {
            minCarryCapacity = 20000,
            maxCarryCapacity = 200000,
            upgradeList = presets.medium
        }
    },
    [10] = {
        -- Industrial
        ['Default'] = {
            minCarryCapacity = 20000,
            maxCarryCapacity = 200000,
            upgradeList = presets.large
        }
    },
    [11] = {
        -- Utility
    },
    [12] = {
        -- Vans
        ["rumpo3"] = {
            minCarryCapacity = 50000,
            maxCarryCapacity = 200000,
            upgradeList = presets.medium
        },
        ['Default'] = {
            minCarryCapacity = 20000,
            maxCarryCapacity = 200000,
            upgradeList = presets.medium
        }
    },
    [13] = {
        -- Cycles
    },
    [14] = {
        -- Boats
    },
    [15] = {
        -- Helicopters
    },
    [16] = {
        -- Planes
    },
    [17] = {
        -- Service
    },
    [18] = {
        -- Emergency
    },
    [19] = {
        -- Military
    },
    [20] = {
        -- Commercial
    },
    -- General Default value for eveything: All vehicles not listed above will use this upgrade path
    ['Default'] = {
        minCarryCapacity = 20000,
        maxCarryCapacity = 200000,
        upgradeList = presets.small
    }
}
