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

function upgradePocess(src, upgradeReqData)
    local plate = upgradeReqData["plate"]
    local weightUpgrades = oxmysql:scalarSync('SELECT weightUpgrades from player_vehicles where plate = ?', {plate})

    if weightUpgrades ~= nil then
        if saveCarWeight(src, upgradeReqData, weightUpgrades) then
            TriggerClientEvent('QBCore:Notify', src, 'Upgrade was successful', 'success', 3500)
            TriggerClientEvent('keep-carInventoryWeight:Client:CloseUI', src)
        else
            TriggerClientEvent('QBCore:Notify', src, 'unable to upgrade!', 'error', 3500)
        end
    else
        -- if for some reason it's still not exist in out database we init data here and then process to upgrade it
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle not found in database!', 'error', 2500)
    end
end

function saveCarWeight(src, upgradeReqData, weightUpgrades)
    -- save car Weight 
    local weightUpgradesChanges = {}
    local upgrades = upgradeReqData["upgrade"]
    local canUpgrade, maxweight = calculateUpgradeAmount(src, upgradeReqData, weightUpgrades)

    if maxweight ~= nil and canUpgrade then
        for i = 1, #upgrades, 1 do
            table.insert(weightUpgradesChanges, string.format('"%s":%s', i, upgrades[i]))
        end
        updateVehicleDatabaseValues(maxweight, weightUpgradesChanges, upgradeReqData)
        return true
    end
    return false
end

function calculateUpgradeAmount(src, upgradeReqData, weightUpgrades)
    local vehicleClass = upgradeReqData["class"]
    local vehiclePlate = upgradeReqData["plate"]
    local vehicleModel = upgradeReqData['model']
    local weightUpgradesTable = json.decode(weightUpgrades)
    local sortedUpgrades = sortTable(upgradeReqData["upgrade"])
    local canUpgrade = false

    for Type, Vehicle in pairs(Config.Vehicles) do
        if Type == vehicleClass then
            for model, vehicleMeta in pairs(Vehicle) do
                if model == vehicleModel then
                    local currentCarryWeight = oxmysql:scalarSync(
                        'SELECT maxweight from player_vehicles where plate = ?', {vehiclePlate})

                    local step = (vehicleMeta.maxWeight - vehicleMeta.minWeight) / vehicleMeta.upgrades
                    local total = 0
                    for key, value in pairs(sortedUpgrades) do
                        if value == true and weightUpgradesTable[tostring(key)] ~= value then
                            total = total + 1
                        end
                    end
                    canUpgrade = (currentCarryWeight + (total * step) <= vehicleMeta.maxWeight) and
                                     (currentCarryWeight + (total * step) ~= currentCarryWeight)
                    if canUpgrade == true then
                        local paid = removeMoney(src, 'cash', vehicleMeta.stepPrice * total, 'trunk')
                        if paid then
                            canUpgrade = true
                        else
                            canUpgrade = false
                        end
                    end
                    return canUpgrade, (currentCarryWeight + (total * step))
                end
            end
        end
    end
end

RegisterServerEvent('keep-carInventoryWeight:server:OpenUI')
AddEventHandler('keep-carInventoryWeight:server:OpenUI', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("testOpen", "Spawn Animals (Admin Only)", {{"model", "Animal Model"}}, false,
    function(source, args)
        TriggerClientEvent('keep-carInventoryWeight:Client:OpenUI', source, args[1])
    end, 'admin')
