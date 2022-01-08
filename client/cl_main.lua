-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()
local blowtorchTime = Config.blowtorchTime
-- ============================
--      FUNCTIONS
-- ============================

RegisterNUICallback('closeMenu', function()
    Wait(50)
    SetNuiFocus(false, false)
    ToggleTablet(false)
end)

RegisterNUICallback('upgradeReq', function(data, cb)
    CoreName.Functions.TriggerCallback('keep-carInventoryWeight:server:reciveUpgradeReq', function(hasDeleted)
        print(hasDeleted)
    end, data)
    cb('ok')
end)

-- ============================
--     Command
-- ============================
RegisterNetEvent('keep-carInventoryWeight:Client:startUpgrading')
AddEventHandler('keep-carInventoryWeight:Client:startUpgrading', function(upgradeReqData)
    Wait(50)
    TriggerEvent('keep-carInventoryWeight:Client:CloseUI')
    ToggleBlowtorch(true)
    CoreName.Functions.Progressbar("start_upgrading", "Startpgrading", blowtorchTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function() -- Done
        ToggleBlowtorch(false)
        TriggerServerEvent('keep-carInventoryWeight:server:proccesUpgradeReq', upgradeReqData)
    end, function()
        ToggleBlowtorch(false)
        CoreName.Functions.Notify("Failed!", "error")
    end)
end)

RegisterNetEvent('keep-carInventoryWeight:Client:isPlayingAnimation')
AddEventHandler('keep-carInventoryWeight:Client:isPlayingAnimation', function()
    Wait(50)
    local ped = PlayerPedId()
    if IsPedActiveInScenario(ped) == false then
        TriggerServerEvent("keep-carInventoryWeight:server:ssssssssss")
    else
        CoreName.Functions.Notify("Wait for upgrade to end!", "error")
    end
end)

RegisterNetEvent('keep-carInventoryWeight:Client:CloseUI')
AddEventHandler('keep-carInventoryWeight:Client:CloseUI', function()
    Wait(50)
    ToggleTablet(false)
    SendNUIMessage({
        action = "close"
    })
end)

RegisterNetEvent('keep-carInventoryWeight:Client:OpenUI')
AddEventHandler('keep-carInventoryWeight:Client:OpenUI', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = CoreName.Functions.GetClosestVehicle(pos)
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    end
    -- SetVehicleMaxSpeed(veh, 18.0556)

    -- (GetVehicleModelEstimatedMaxSpeed(veh), GetVehicleEstimatedMaxSpeed(veh))
    local plate = CoreName.Functions.GetPlate(veh)
    local class = GetVehicleClass(veh)
    local vehpos = GetEntityCoords(veh)
    local namelbl = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    local IsVehicleStopped = IsVehicleStopped(veh)
    local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning(veh)
    local GetVehicleEstimatedMaxSpeed = GetVehicleEstimatedMaxSpeed(veh)

    local genInfo = {
        stopped = IsVehicleStopped,
        engineRunning = GetIsVehicleEngineRunning,
        maxSpeed = GetVehicleEstimatedMaxSpeed,
        namelbl = namelbl
    }

    if veh ~= nil and #(pos - vehpos) < 2.5 and IsPauseMenuActive() == false then
        TriggerServerEvent("keep-carInventoryWeight:server:playerVehicleData", plate, class, genInfo)
    elseif IsPauseMenuActive() == 1 then
        TriggerEvent('QBCore:Notify', 'close menu to open laptop!', 'error', 2500)
    else
        TriggerEvent('QBCore:Notify', 'You are not near a vehicle !', 'error', 2500)
    end
end)

RegisterNetEvent('keep-carInventoryWeight:Client:Sv_OpenUI')
AddEventHandler('keep-carInventoryWeight:Client:Sv_OpenUI', function(serverRes)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = serverRes
    })
    ToggleTablet(true)
end)

RegisterNetEvent('keep-carInventoryWeight:Client:mechDuty')
AddEventHandler('keep-carInventoryWeight:Client:mechDuty', function()
    TriggerServerEvent("QBCore:ToggleDuty")
end)

