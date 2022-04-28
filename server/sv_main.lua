local CoreName = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql

CoreName.Functions.CreateCallback('qb-expandableVehicleTrunk:server:reciveUpgradeReq', function(source, cb, data)
    local src = source
    -- client wants to upgrade ==> start animation
    if TriggerClientEvent('qb-expandableVehicleTrunk:Client:startUpgrading', src, data) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('qb-expandableVehicleTrunk:server:proccesUpgradeReq', function(upgradeReqData)
    -- process upgrade request sent by client after animation is done
    local src = source
    upgradePocess(src, upgradeReqData)
end)

CoreName.Functions.CreateUseableItem("capacitytablet", function(source, item)
    local Player = CoreName.Functions.GetPlayer(source)
    local src = source
    if (Player.PlayerData.job.name == "mechanic" and Player.PlayerData.job.onduty) then
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent('qb-expandableVehicleTrunk:Client:isPlayingAnimation', src)
        end
    elseif Player.PlayerData.job.onduty == false then
        TriggerClientEvent('QBCore:Notify', source, 'You must be onDuty!', 'error', 2500)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You must be a mechanic to use this tablet!', 'error', 2500)
    end
end)

-- ============================
--      New Tablet Events
-- ============================


CoreName.Functions.CreateCallback('qb-expandableVehicleTrunk:server:getDataFromNearbyVehicle', function(source, cb, parameters)
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
    end
end)


CoreName.Functions.CreateCallback('qb-expandableVehicleTrunk:server:updateRequestedData', function(source, cb, data)
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
    -- check for downgrades
    for key, value in pairs(data.deselected) do
        if value.serverSideUpgraded == true then
            -- need to downgrade
            table.insert(request.Downgrades, value)
        end
    end
    --
    local res = upgradePocess(source, data.vehicleData, request)
    if res == true then
        TriggerClientEvent('qb-expandableVehicleTrunk:Client:startUpgrading', source)
    end
    cb(res)
end)


-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("goOnDuty", "(Admin Only)", {}, false, function(source)
    TriggerClientEvent("qb-expandableVehicleTrunk:Client:goOnDuty", source)
end, 'admin')
