-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()
-- ============================
--      FUNCTIONS
-- ============================

-- Citizen.CreateThread(function()
--     Wait(7)
-- end)

RegisterNUICallback('closeMenu', function()
    Wait(50)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('upgradeReq', function(data, cb)
    TriggerServerEvent("keep-carInventoryWeight:server:reciveUpgradeReq", data)
    cb('ok')
end)

-- ============================
--     Command
-- ============================
RegisterNetEvent('keep-carInventoryWeight:Client:CloseUI')
AddEventHandler('keep-carInventoryWeight:Client:CloseUI', function()
    Wait(50)
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
    -- IsVehicleStopped(vehicle)

    -- print(GetVehicleModelEstimatedMaxSpeed(veh), GetVehicleEstimatedMaxSpeed(veh))
    local plate = CoreName.Functions.GetPlate(veh)
    local class = GetVehicleClass(veh)
    local vehpos = GetEntityCoords(veh)

    if veh ~= nil and #(pos - vehpos) < 2.5 then
        TriggerServerEvent("keep-carInventoryWeight:server:playerVehicleData", plate, class)
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
end)
