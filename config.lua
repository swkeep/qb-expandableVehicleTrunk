Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================

Config.Vehicles = {
    [7] = { -- table keys are vehicles classes https://docs.fivem.net/natives/?_0x29439776AAA00A62
        ["sultanrsv8"] = {
            minWeight = 10000,
            maxWeight = 100000,
            upgrades = 4,
            stepPrice = 1000
        }
    },
    [9] = {
        ["dubsta3"] = {
            minWeight = 30000,
            maxWeight = 150000,
            upgrades = 2,
            stepPrice = 5000
        }
    },
    [12] = {
        ["rumpo3"] = {
            minWeight = 50000,
            maxWeight = 200000,
            upgrades = 5,
            stepPrice = 800
        }
    }
}
