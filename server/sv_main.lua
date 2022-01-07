local CoreName = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql

RegisterServerEvent('keep-carInventoryWeight:server:playerVehicleData')
AddEventHandler('keep-carInventoryWeight:server:playerVehicleData', function(plate, class)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)

    Result = oxmysql:fetchSync(
        'SELECT players.charinfo ,players.citizenid , player_vehicles.plate , player_vehicles.fakeplate , player_vehicles.vehicle , player_vehicles.hash ,player_vehicles.maxweight from players INNER join player_vehicles on players.citizenid = player_vehicles.citizenid WHERE plate = ?',
        {plate})

    if Result then
        -- send requested vehicle to client  
        local sv_response = createServerResponse(Result, class)
        TriggerClientEvent("keep-carInventoryWeight:Client:Sv_OpenUI", src, sv_response)
        return true
    end
    return false
end)

RegisterNetEvent('keep-carInventoryWeight:server:reciveUpgradeReq', function(upgradeReqData)
    -- process upgrade request sent by client
    local src = source
    local upgrade = {}

    if upgrade ~= nil then
        -- client wants to upgrade
        upgradePocess(src, upgradeReqData)
    end
end)

RegisterServerEvent('keep-carInventoryWeight:server:OpenUI')
AddEventHandler('keep-carInventoryWeight:server:OpenUI', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("testOpen", "(Admin Only)", {}, false, function(source)
    TriggerClientEvent('keep-carInventoryWeight:Client:OpenUI', source)
end, 'admin')
