-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()
local blowtorchTime = Config.blowtorchTime
-- ============================
--      FUNCTIONS
-- ============================
function PrepareVehicleData()
    local DATA = {}
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    else
        veh = CoreName.Functions.GetClosestVehicle(pos)
    end
    DATA.plate = CoreName.Functions.GetPlate(veh)
    DATA.class = GetVehicleClass(veh)
    DATA.vehpos = GetEntityCoords(veh)
    DATA.namelbl = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    DATA.isVehicleStopped = IsVehicleStopped(veh)
    DATA.isEngineRunning = GetIsVehicleEngineRunning(veh)
    DATA.vehicleEstimatedMaxSpeed = GetVehicleEstimatedMaxSpeed(veh)
    if veh ~= nil and #(pos - DATA.vehpos) < 2.5 and IsPauseMenuActive() == false then
        -- data is ready to for server
    elseif IsPauseMenuActive() == 1 then
        DATA.error = {}
        DATA.error = {
            error = 'open_menu',
        }
        return DATA.error
    else
        DATA.error = {}
        DATA.error = {
            error = 'not_near_vehicle',
        }
        return DATA.error
    end
    return DATA
end

exports("PrepareVehicleData", PrepareVehicleData)

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

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    exports['swkeep-tablet']:AddAppToList({
        name = "expansiontrunk",
        icon = "carrep.png",
        lable = "Expansion trunk",
        to = "expansion",
        resourceName = 'qb-expandableVehicleTrunk',
        readEvent = 'qb-expandableVehicleTrunk:server:getDataFromNearbyVehicle',
        writeEvent = 'qb-expandableVehicleTrunk:server:updateRequestedData',
        exports = {}, -- get around callback not close to what we want
    })
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'qb-expandableVehicleTrunk' then
        exports['swkeep-tablet']:AddAppToList({
            name = "expansiontrunk",
            icon = "carrep.png",
            lable = "Expansion trunk",
            to = "expansion",
            resourceName = 'qb-expandableVehicleTrunk',
            readEvent = 'qb-expandableVehicleTrunk:server:getDataFromNearbyVehicle',
            writeEvent = 'qb-expandableVehicleTrunk:server:updateRequestedData',
            exports = {}, -- get around callback not close to what we want
        })
    end
end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:goOnDuty', function()
    TriggerServerEvent("QBCore:ToggleDuty")
end)
