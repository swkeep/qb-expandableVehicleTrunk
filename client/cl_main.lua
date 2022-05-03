local CoreName = exports['qb-core']:GetCoreObject()
local blowtorchTime = Config.blowtorchTime
-- ============================
--      FUNCTIONS
-- ============================

RegisterNetEvent('qb-expandableVehicleTrunk:Client:startUpgrading')
AddEventHandler('qb-expandableVehicleTrunk:Client:startUpgrading', function()
    Wait(75)
    ToggleBlowtorch(true)
    CoreName.Functions.Progressbar("start_upgrading", "Startpgrading", blowtorchTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function() -- Done
        ToggleBlowtorch(false)
    end, function()
        ToggleBlowtorch(false)
        CoreName.Functions.Notify("Failed!", "error")
    end)
end)

-- ============================
--     Command
-- ============================

-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
--     exports['swkeep-tablet']:AddAppToList({
--         name = "expansiontrunk",
--         icon = "carrep.png",
--         lable = "Expansion trunk",
--         to = "expansion",
--         resourceName = 'qb-expandableVehicleTrunk',
--         readEvent = 'qb-expandableVehicleTrunk:server:getDataFromNearbyVehicle',
--         writeEvent = 'qb-expandableVehicleTrunk:server:updateRequestedData',
--         exports = {}, -- get around callback not close to what we want
--     })
-- end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:goOnDuty', function()
    TriggerServerEvent("QBCore:ToggleDuty")
end)
