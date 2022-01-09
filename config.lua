Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================

Config.blowtorchTime = math.random(5000,6000);

Config.Vehicles = {
    [7] = { -- table keys are vehicles classes https://docs.fivem.net/natives/?_0x29439776AAA00A62
        ["sultanrsv8"] = {
            minCarryCapacity = 10000,
            maxCarryCapacity = 100000,
            upgrades = 4,
            stepPrice = 1000
        }
    },
    [9] = {
        ["dubsta3"] = {
            minCarryCapacity = 30000,
            maxCarryCapacity = 150000,
            upgrades = 2,
            stepPrice = 5000
        }
    },
    [12] = {
        ["rumpo3"] = {
            minCarryCapacity = 50000,
            maxCarryCapacity = 200000,
            upgrades = 5,
            stepPrice = 800
        }
    }
}
