local CoreName = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql

RegisterServerEvent('keep-carInventoryWeight:server:playerVehicleData')
AddEventHandler('keep-carInventoryWeight:server:playerVehicleData', function(plate, class, genInfo)
    local src = source

    if genInfo["stopped"] == 1 and genInfo["engineRunning"] == false then
        Result = oxmysql:fetchSync(
            'SELECT players.charinfo ,players.citizenid , player_vehicles.plate , player_vehicles.fakeplate , player_vehicles.vehicle , player_vehicles.hash ,player_vehicles.maxweight from players INNER join player_vehicles on players.citizenid = player_vehicles.citizenid WHERE plate = ?',
            {plate})
        if #Result ~= 0 then
            -- send requested vehicle to client  
            local sv_response = createServerResponse(Result, class)
            TriggerClientEvent("keep-carInventoryWeight:Client:Sv_OpenUI", src, sv_response)
            return true
        elseif #Result == 0 then
            TriggerClientEvent('QBCore:Notify', src, 'We cant find owner of this vehicle!', 'error', 2500)
        end
    elseif genInfo["stopped"] == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle must be stopped!', 'error', 2500)
    elseif genInfo["engineRunning"] == 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle engine is on trun it off!', 'error', 2500)

    end
    return false
end)


CoreName.Functions.CreateCallback('keep-carInventoryWeight:server:reciveUpgradeReq', function(source, cb, data)
    local src = source
    -- client wants to upgrade ==> start animation
    TriggerClientEvent('keep-carInventoryWeight:Client:startUpgrading', src, upgradeReqData)
    if found ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

-- RegisterNetEvent('keep-carInventoryWeight:server:reciveUpgradeReq', function(upgradeReqData)
--     local src = source
--     -- client wants to upgrade ==> start animation
--     TriggerClientEvent('keep-carInventoryWeight:Client:startUpgrading', src, upgradeReqData)
-- end)

RegisterNetEvent('keep-carInventoryWeight:server:proccesUpgradeReq', function(upgradeReqData)
    -- process upgrade request sent by client after animation is done
    local src = source
    -- upgradePocess(src, upgradeReqData)
end)

RegisterNetEvent('keep-carInventoryWeight:server:ssssssssss', function()
    local src = source
    TriggerClientEvent('keep-carInventoryWeight:Client:OpenUI', src)
end)

CoreName.Functions.CreateUseableItem("capacitytablet", function(source, item)
    local Player = CoreName.Functions.GetPlayer(source)
    local src = source
    if (Player.PlayerData.job.name == "mechanic" and Player.PlayerData.job.onduty) then
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent('keep-carInventoryWeight:Client:isPlayingAnimation', src)
        end
    elseif Player.PlayerData.job.onduty == false then
        TriggerClientEvent('QBCore:Notify', source, 'You must be onDuty!', 'error', 2500)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You must be a mechanic to use this tablet!', 'error', 2500)
    end
end)

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("testOpen", "(Admin Only)", {}, false, function(source)
    TriggerClientEvent('keep-carInventoryWeight:Client:OpenUI', source)
end, 'admin')

CoreName.Commands.Add("mechDuty", "(Admin Only)", {}, false, function(source)
    TriggerClientEvent("keep-carInventoryWeight:Client:mechDuty", source)
end, 'admin')

CoreName.Commands.Add('addTablet', 'add tablet to player inventory (Admin Only)', {}, false, function(source)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)

    Player.Functions.AddItem("capacitytablet", 1)
    TriggerClientEvent("inventory:client:ItemBox", src, CoreName.Shared.Items["capacitytablet"], "add")
end, 'admin')
