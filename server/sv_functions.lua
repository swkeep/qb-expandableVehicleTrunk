local CoreName = exports['qb-core']:GetCoreObject()
local oxmysql = exports.oxmysql
local DefaultMetaData = Config.Vehicles

-- ============================
--      Upgrade Process
-- ============================
local function updateVehicleInfromation(options)
    local model = options.vehicleInfo.vehicle or options.vehicleInfo.model
    local hash  = options.vehicleInfo.hash
    local plate = options.vehicleInfo.plate

    if options.actualCarryCapacity ~= nil then
        oxmysql:update('UPDATE `player_vehicles` SET actualCarryCapacity = ? WHERE vehicle = ? AND hash = ? AND plate = ?',
            { options.actualCarryCapacity, model, hash, plate }, function(result)
        end)
    end
    if options.weightUpgrades ~= nil then
        oxmysql:update('UPDATE `player_vehicles` SET weightUpgrades = ? WHERE vehicle = ? AND hash = ? AND plate = ?',
            { options.weightUpgrades, model, hash, plate }, function(result)
        end)
    end
end

local function findByLable(lable, tbl)
    for key, value in pairs(tbl) do
        if value.lable == lable then
            return value, key
        end
    end
end

local function makeWeightUpgradesString(source, weightUpgrades, request, data)
    local vehiclePlate = data.vehicleData.plate
    local vehicleModel = data.vehicleData.model
    local vehicleClass = data.vehicleData.class
    local current_weightUpgradesTable = json.decode(weightUpgrades)
    local current_CarryWeight = oxmysql:scalarSync('SELECT actualCarryCapacity from player_vehicles where plate = ?', { vehiclePlate })
    local new_weightUpgradesTable = {}
    local new_carryWeightValue = current_CarryWeight
    local totalPrice = 0

    for class, Vehicle in pairs(Config.Vehicles) do
        if class == vehicleClass then
            for model, vehicleMeta in pairs(Vehicle) do
                if model == vehicleModel then
                    -- we found model
                    -- make string for upgrades
                    for key, value in pairs(request.Upgrades) do
                        -- just read from server config file rather than what we got from client! even tho thay samething
                        local upgrade, index = findByLable(value.lable, vehicleMeta.upgradeList)
                        new_carryWeightValue = new_carryWeightValue + upgrade.size
                        totalPrice = totalPrice + upgrade.price
                        current_weightUpgradesTable[index] = true
                    end

                    -- make string downgrades
                    for key, value in pairs(request.Downgrades) do
                        local upgrade, index = findByLable(value.lable, vehicleMeta.upgradeList)
                        new_carryWeightValue = new_carryWeightValue - upgrade.size
                        totalPrice = totalPrice + (upgrade.price * Config.commissionPercentage)
                        current_weightUpgradesTable[index] = false
                    end
                    goto finish
                end
            end

            if totalPrice == 0 and next(DefaultMetaData[class]) ~= nil then
                -- we didn't found model but we have defalut value for it's class
                for key, value in pairs(request.Upgrades) do
                    -- just read from server config file rather than what we got from client! even tho thay samething
                    local upgrade, index = findByLable(value.lable, DefaultMetaData[class].Default.upgradeList)
                    new_carryWeightValue = new_carryWeightValue + upgrade.size
                    totalPrice = totalPrice + upgrade.price
                    current_weightUpgradesTable[index] = true
                end

                -- make string downgrades
                for key, value in pairs(request.Downgrades) do
                    local upgrade, index = findByLable(value.lable, DefaultMetaData[class].Default.upgradeList)
                    new_carryWeightValue = new_carryWeightValue - upgrade.size
                    totalPrice = totalPrice + (upgrade.price * Config.commissionPercentage)
                    current_weightUpgradesTable[index] = false
                end
            end
        end
    end
    if totalPrice == 0 then
        -- we didn't found anything!
        for key, value in pairs(request.Upgrades) do
            -- just read from server config file rather than what we got from client! even tho thay samething
            local upgrade, index = findByLable(value.lable, DefaultMetaData.Default.upgradeList)
            new_carryWeightValue = new_carryWeightValue + upgrade.size
            totalPrice = totalPrice + upgrade.price
            current_weightUpgradesTable[index] = true
        end

        -- make string downgrades
        for key, value in pairs(request.Downgrades) do
            local upgrade, index = findByLable(value.lable, DefaultMetaData.Default.upgradeList)
            new_carryWeightValue = new_carryWeightValue - upgrade.size
            totalPrice = totalPrice + (upgrade.price * Config.commissionPercentage)
            current_weightUpgradesTable[index] = false
        end
    end
    ::finish::
    new_weightUpgradesTable = current_weightUpgradesTable
    return new_weightUpgradesTable, math.floor(new_carryWeightValue), math.floor(totalPrice)
end

local function RemoveMoney(src, type, amount, desc)
    local plyer = CoreName.Functions.GetPlayer(src)
    if plyer.Functions.RemoveMoney(type, amount, "vehicle-upgrade-bail-" .. desc) then
        TriggerClientEvent('QBCore:Notify', src, 'you paid: ' .. amount, 'success', 3500)
        return true
    end
    TriggerClientEvent('QBCore:Notify', src, 'unable to pay!', 'error', 3500)
    return false
end

local function saveCarWeight(source, weightUpgrades, request, data)
    -- save car Weight
    local new_weightUpgrades, newWeight, totalPrice = makeWeightUpgradesString(source, weightUpgrades, request, data)
    local tmp                                       = {}
    for key, value in pairs(new_weightUpgrades) do
        table.insert(tmp, string.format('%s:%s', key, value))
    end
    tmp = "{" .. table.concat(tmp, ",") .. "}"

    updateVehicleInfromation({
        vehicleInfo = data.vehicleData,
        weightUpgrades = tmp
    })

    updateVehicleInfromation({
        vehicleInfo = data.vehicleData,
        actualCarryCapacity = newWeight
    })
    if totalPrice == 0 then
        return false
    end
    RemoveMoney(source, 'bank', totalPrice, 'Trunk upgrade')
    return true
end

function upgradeProcess(source, data, request)
    local plate = data.vehicleData.plate
    local weightUpgrades = oxmysql:scalarSync('SELECT weightUpgrades from player_vehicles where plate = ?', { plate })
    local res
    if weightUpgrades ~= nil then
        res = saveCarWeight(source, weightUpgrades, request, data)
        if res == true then
            TriggerClientEvent('QBCore:Notify', source, 'Upgrade was successful', 'success', 3500)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Unable to upgrade', 'error', 3500)
        end
    else
        res = false
        TriggerClientEvent('QBCore:Notify', source, 'You can not upgrade this vehicle!', 'error', 2500)
    end
    return res
end

-- ============================
--        Read Data
--        #region
-- ============================
local function revalidate_weightUpgrades(weightUpgradesString, vehicleMeta, vehicleInfoFromDatabase)
    local upgrades = {}
    local weightUpgrades = json.decode(weightUpgradesString)
    local list = vehicleMeta.upgradeList

    if #weightUpgrades == #list then
        return
    end

    for key, value in pairs(list) do
        if weightUpgrades[key] ~= nil and weightUpgrades[key] == true then
            table.insert(upgrades, string.format('%s:%s', key, true))
        else
            table.insert(upgrades, string.format('%s:%s', key, false))
        end
    end
    upgrades = "{" .. table.concat(upgrades, ",") .. "}"
    updateVehicleInfromation({
        vehicleInfo = vehicleInfoFromDatabase,
        weightUpgrades = upgrades
    })
end

local function initializeActualCarryCapacity(vehicleMeta, vehicleInfoFromDatabase)
    updateVehicleInfromation({
        vehicleInfo = vehicleInfoFromDatabase,
        actualCarryCapacity = vehicleMeta.minCarryCapacity
    })
    return vehicleMeta.minCarryCapacity
end

local function initializeAvailableUpgrades(vehicleMeta, vehicleInfoFromDatabase)
    -- init vehicle
    local upgrades = {}
    for key, value in pairs(vehicleMeta.upgradeList) do
        --table.insert(upgrades, string.format('"%s":%s', key, false))
        table.insert(upgrades, string.format('%s:%s', key, false))
    end

    -- convert table to string to save inside database
    -- {"1":false,"2":false,"3":false}
    upgrades = "{" .. table.concat(upgrades, ",") .. "}"

    updateVehicleInfromation({
        vehicleInfo = vehicleInfoFromDatabase,
        weightUpgrades = upgrades
    })

    for key, value in pairs(vehicleMeta.upgradeList) do
        value.upgraded = false
    end

    return vehicleMeta.upgradeList
end

local function getAvailableUpgrades(weightUpgradesString, vehicleMeta, vehicleInfoFromDatabase)
    local weightUpgrades = json.decode(weightUpgradesString)

    for key, value in pairs(vehicleMeta.upgradeList) do
        value.upgraded = weightUpgrades[key]
    end

    return {
        upgradesAvailableForThisVehicle = vehicleMeta.upgradeList,
        actualCarryCapacity = vehicleInfoFromDatabase.actualCarryCapacity,
    }
end

local function upgradesInfromation(clientInfo, vehicleMeta, vehicleInfoFromDatabase)
    local info = {}
    local weightUpgrades = oxmysql:scalarSync('SELECT weightUpgrades from player_vehicles where plate = ?', { clientInfo.plate })
    if weightUpgrades ~= nil then
        revalidate_weightUpgrades(weightUpgrades, vehicleMeta, vehicleInfoFromDatabase)
        info = getAvailableUpgrades(weightUpgrades, vehicleMeta, vehicleInfoFromDatabase)
    else
        info = {
            upgradesAvailableForThisVehicle = initializeAvailableUpgrades(vehicleMeta, vehicleInfoFromDatabase),
            actualCarryCapacity = initializeActualCarryCapacity(vehicleMeta, vehicleInfoFromDatabase),
        }
    end
    return info
end

local function upgradeWithDefaultValue(Data, default, vehicleInfoFromDatabase)
    return upgradesInfromation(Data, default, vehicleInfoFromDatabase)
end

function PrepareServerResponse(Data, vehicleInfoFromDatabase)
    local upgrades = {}
    local playerInfo = json.decode(vehicleInfoFromDatabase['charinfo'])

    local Response = {
        vehicleData = {
            ownerID = playerInfo.cid,
            personalInfo = {
                firstname = playerInfo.firstname,
                lastname = playerInfo.lastname,
                phone = playerInfo.phone,
                gender = playerInfo.gender,
                birthdate = playerInfo.birthdate
            },
            class = Data.class,
            namelbl = Data.namelbl,
            model = vehicleInfoFromDatabase["vehicle"],
            plate = vehicleInfoFromDatabase["plate"],
            hash = vehicleInfoFromDatabase["hash"]
        },
        vehicleUpgradeData = {
            upgradesAvailableForThisVehicle = {},
            currentSize = 0,
            maxUpgradeSize = 0,
        }
    }

    -- calculate upgrade steps
    for class, Vehicles in pairs(DefaultMetaData) do
        -- find right class
        if class == Data.class then
            -- find right vehicle metaData
            for name, vehicleMeta in pairs(Vehicles) do
                if name == vehicleInfoFromDatabase["vehicle"] then
                    upgrades = upgradesInfromation(Data, vehicleMeta, vehicleInfoFromDatabase)
                    Response.vehicleUpgradeData.maxUpgradeSize = vehicleMeta.maxCarryCapacity
                    break
                end
            end
            -- we didn't found model
            if DefaultMetaData[class].Default ~= nil then
                upgrades = upgradeWithDefaultValue(Data, DefaultMetaData[class].Default, vehicleInfoFromDatabase)
                break
            end
        end
    end
    -- we didn't found class
    if next(upgrades) == nil then
        upgrades = upgradeWithDefaultValue(Data, DefaultMetaData.Default, vehicleInfoFromDatabase)
    end

    Response.vehicleUpgradeData.upgradesAvailableForThisVehicle = upgrades.upgradesAvailableForThisVehicle
    Response.vehicleUpgradeData.currentSize = upgrades.actualCarryCapacity
    return Response
end

--#endregion
