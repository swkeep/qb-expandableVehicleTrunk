local CoreName = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql

-- ============================
--      Functions
-- ============================
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

                    local step = (vehicleMeta.maxCarryCapacity - vehicleMeta.minCarryCapacity) / vehicleMeta.upgrades
                    local total = 0
                    for key, value in pairs(sortedUpgrades) do
                        if value == true and weightUpgradesTable[tostring(key)] ~= value then
                            total = total + 1
                        end
                    end
                    canUpgrade = (currentCarryWeight + (total * step) <= vehicleMeta.maxCarryCapacity) and
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

function createServerResponse(Result, class)
    -- create server response when client fetch data
    local weightUpgrades = oxmysql:scalarSync('SELECT weightUpgrades from player_vehicles where plate = ?',
        {Result[1]["plate"]})
    local characterINFO = json.decode(Result[1]['charinfo'])
    local sv_response = {}
    Upgrades = {}

    sv_response['vehicleInfo'] = {
        vehicle = Result[1]["vehicle"],
        plate = Result[1]["plate"],
        maxweight = Result[1]["maxweight"],
        hash = Result[1]["hash"],
        class = class
    }
    sv_response['characterInfo'] = {
        firstname = characterINFO["firstname"],
        lastname = characterINFO["lastname"],
        cid = characterINFO["cid"],
        phone = characterINFO["phone"],
        gender = characterINFO["gender"]
    }

    -- calculate upgrade steps 
    for Type, Vehicle in pairs(Config.Vehicles) do
        if Type == class then
            for name, vehicleMeta in pairs(Vehicle) do
                if name == Result[1]["vehicle"] then
                    Upgrades = createUpgrades(vehicleMeta, weightUpgrades, Result[1])
                    sv_response['vehicleInfo']['maxCarryCapacity'] = vehicleMeta.maxCarryCapacity
                end
            end
        end
    end
    sv_response['upgrades'] = Upgrades

    -- need better implementation
    -- desc : when we init vehicle database client need to get new carryWeight not old one
    if sv_response['upgrades']["init"] == true then
        Wait(500)
        local currentCarryWeight = oxmysql:scalarSync('SELECT maxweight from player_vehicles where plate = ?',
            {sv_response['vehicleInfo']['plate']})
        sv_response['vehicleInfo']['maxweight'] = currentCarryWeight
        sv_response['upgrades']["init"] = nil
    end

    return sv_response
end

function createUpgrades(vehicleMeta, weightUpgrades, vehicle)
    local temp = {}
    local weightUpgrades = json.decode(weightUpgrades)
    local step = (vehicleMeta.maxCarryCapacity - vehicleMeta.minCarryCapacity) / vehicleMeta.upgrades

    if weightUpgrades ~= nil then
        for k, value in pairs(weightUpgrades) do
            temp[k] = value
        end
        temp["step"] = step
        temp["stepPrice"] = vehicleMeta.stepPrice
        return temp
    else
        return initWeightUpgradesData(vehicleMeta, vehicle, step)
    end
end

function initWeightUpgradesData(vehicleMeta, vehicle, step)
    -- init vehicle
    local initWeightUpgrades = {}
    for i = 1, vehicleMeta.upgrades, 1 do
        table.insert(initWeightUpgrades, string.format('"%s":%s', i, false))
    end

    updateVehicleDatabaseValues(vehicleMeta.minCarryCapacity, initWeightUpgrades, vehicle)

    -- step , stepPrice is for client to show to players
    table.insert(initWeightUpgrades, string.format('"%s":%s', 'step', step))
    table.insert(initWeightUpgrades, string.format('"%s":%s', 'stepPrice', vehicleMeta.stepPrice))
    table.insert(initWeightUpgrades, string.format('"%s":%s', 'init', true))

    initWeightUpgrades = "{" .. table.concat(initWeightUpgrades, ",") .. "}"
    return json.decode(initWeightUpgrades)
end

function updateVehicleDatabaseValues(maxweight, weightUpgradesChanges, upgradeReqData)
    local plate = upgradeReqData["plate"]
    local model = upgradeReqData["vehicle"] or upgradeReqData["model"]

    local hash = upgradeReqData["hash"]
    local weightUpgradesChanges2 = "{" .. table.concat(weightUpgradesChanges, ",") .. "}"

    oxmysql:update('UPDATE `player_vehicles` SET maxweight = ? WHERE vehicle = ? AND hash = ? AND plate = ?',
        {maxweight, model, hash, plate}, function(result)
        end)
    oxmysql:update('UPDATE `player_vehicles` SET weightUpgrades = ? WHERE vehicle = ? AND hash = ? AND plate = ?',
        {weightUpgradesChanges2, model, hash, plate}, function(result)
        end)
end

function removeMoney(src, type, amount, desc)
    local plyer = CoreName.Functions.GetPlayer(src)
    if plyer.Functions.RemoveMoney(type, amount, "vehicle-upgrade-bail-" .. desc) then
        TriggerClientEvent('QBCore:Notify', src, 'you paid: ' .. amount, 'success', 3500)
        return true
    end
    TriggerClientEvent('QBCore:Notify', src, 'unable to pay!', 'error', 3500)
    return false
end

function sortTable(table)
    local temp = {}
    for k, value in pairs(table) do
        temp[k] = value
    end
    return temp
end

function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end
