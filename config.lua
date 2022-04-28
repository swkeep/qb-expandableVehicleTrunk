Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================

Config.blowtorchTime = math.random(5000, 6000);
Config.commissionPercentage = 0.2 -- 20%

Config.Vehicles = {
    [7] = { -- table keys are vehicles classes https://docs.fivem.net/natives/?_0x29439776AAA00A62
    },
    [9] = {
        ["dubsta3"] = {
            minCarryCapacity = 30000,
            maxCarryCapacity = 150000,
            upgradeList = {
                [1] = { lable = "+20 kg", size = 20 * 1000, price = 5000 },
                [2] = { lable = "+50 kg", size = 50 * 1000, price = 11000 },
                [3] = { lable = "+100 kg", size = 100 * 1000, price = 20000 },
                [4] = { lable = "+150 kg", size = 150 * 1000, price = 25000 },
                [5] = { lable = "+200 kg", size = 200 * 1000, price = 30000 },
            }
        }
    },
    [12] = {
        ["rumpo3"] = {
            minCarryCapacity = 50000,
            maxCarryCapacity = 200000,
            upgradeList = {
                [1] = { lable = "+20 kg", size = 20 * 1000, price = 5000 },
                [2] = { lable = "+50 kg", size = 50 * 1000, price = 11000 },
                [3] = { lable = "+100 kg", size = 100 * 1000, price = 20000 },
            }
        }
    },
    -- All vehicles that don't exist inside this config file are gonna use this upgrade path
    ['Defualt'] = {
        minCarryCapacity = 20000,
        maxCarryCapacity = 200000,
        upgradeList = {
            [1] = { lable = "+20 kg", size = 20 * 1000, price = 5000 },
            [2] = { lable = "+50 kg", size = 50 * 1000, price = 11000 },
            [3] = { lable = "+100 kg", size = 100 * 1000, price = 20000 },
            [4] = { lable = "+155 kg", size = 155 * 1000, price = 50000 },
            [5] = { lable = "+200 kg", size = 200 * 1000, price = 100000 },
        }
    }
}
