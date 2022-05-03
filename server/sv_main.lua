local QBcore = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql
-- ============================
--      New Tablet Events
-- ============================


QBcore.Functions.CreateCallback('qb-expandableVehicleTrunk:server:getDataFromNearbyVehicle', function(source, cb, parameters)
    local src = source
    local vehicleInfoFromDatabase
    if parameters["isVehicleStopped"] == 1 and parameters["isEngineRunning"] == false then
        vehicleInfoFromDatabase = oxmysql:fetchSync(
            'SELECT players.charinfo ,players.citizenid , player_vehicles.plate , player_vehicles.fakeplate , player_vehicles.vehicle , player_vehicles.hash ,player_vehicles.actualCarryCapacity from players INNER join player_vehicles on players.citizenid = player_vehicles.citizenid WHERE plate = ?',
            { parameters.plate })
        if #vehicleInfoFromDatabase ~= 0 then
            -- send requested vehicle to client
            local sv_response = PrepareServerResponse(parameters, vehicleInfoFromDatabase[1])
            cb(sv_response)
        elseif #vehicleInfoFromDatabase == 0 then
            TriggerClientEvent('QBCore:Notify', src, 'We cant find owner of this vehicle!', 'error', 2500)
            cb(false)
        end
    elseif parameters["isVehicleStopped"] == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle must be stopped!', 'error', 2500)
        cb(false)
    elseif parameters["isEngineRunning"] == 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle engine is on trun it off!', 'error', 2500)
        cb(false)
    elseif parameters["error"] == 'not_near_vehicle' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not near a vehicle', 'error', 2500)
        cb(false)
    end
end)

QBcore.Functions.CreateCallback('qb-expandableVehicleTrunk:server:updateRequestedData', function(source, cb, data)
    -- seprate Upgrades && Downgrades
    local request = {
        Upgrades = {},
        Downgrades = {}
    }
    for key, value in pairs(data.selected) do
        if value.serverSideUpgraded == false then
            -- selected and we need to upgrade
            table.insert(request.Upgrades, value)
        end
    end
    for key, value in pairs(data.deselected) do
        if value.serverSideUpgraded == true then
            -- need to downgrade
            table.insert(request.Downgrades, value)
        end
    end
    -- start upgrade process
    local res = upgradeProcess(source, data, request)
    if res == true then
        TriggerClientEvent('qb-expandableVehicleTrunk:Client:startUpgrading', source)
    end
    cb(res)
end)

-- ============================
--      Commands
-- ============================

QBcore.Commands.Add("goOnDuty", "(Admin Only)", {}, false, function(source)
    TriggerClientEvent("qb-expandableVehicleTrunk:Client:goOnDuty", source)
end, 'admin')
