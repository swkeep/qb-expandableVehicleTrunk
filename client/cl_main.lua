-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()
local blowtorchTime = Config.blowtorchTime
local tablet = false
local blowtorch = false
-- ============================
--      FUNCTIONS
-- ============================
RegisterNetEvent('qb-expandableVehicleTrunk:Client:OpenUI')
AddEventHandler('qb-expandableVehicleTrunk:Client:OpenUI', function()
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
        TriggerServerEvent("qb-expandableVehicleTrunk:server:playerVehicleData", plate, class, genInfo)
    elseif IsPauseMenuActive() == 1 then
        TriggerEvent('QBCore:Notify', 'close menu to open laptop!', 'error', 2500)
    else
        TriggerEvent('QBCore:Notify', 'You are not near a vehicle !', 'error', 2500)
    end
end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:Sv_OpenUI')
AddEventHandler('qb-expandableVehicleTrunk:Client:Sv_OpenUI', function(serverRes)
    -- when player used tablet server will trigger this event 
    SetNuiFocus(true, true)
    ToggleTablet(not tablet)
    SendNUIMessage({
        action = "open",
        data = serverRes
    })
end)

RegisterNUICallback('closeMenu', function()
    Wait(50)
    SetNuiFocus(false, false)
    ToggleTablet(not tablet)
end)

RegisterNUICallback('upgradeReq', function(data, cb)
    CoreName.Functions.TriggerCallback('qb-expandableVehicleTrunk:server:reciveUpgradeReq', function(isDone)
        cb(isDone)
    end, data)
end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:startUpgrading')
AddEventHandler('qb-expandableVehicleTrunk:Client:startUpgrading', function(upgradeReqData)
    Wait(50)
    TriggerEvent('qb-expandableVehicleTrunk:Client:CloseUI')
    ToggleBlowtorch(true)
    CoreName.Functions.Progressbar("start_upgrading", "Startpgrading", blowtorchTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function() -- Done
        ToggleBlowtorch(false)
        TriggerServerEvent('qb-expandableVehicleTrunk:server:proccesUpgradeReq', upgradeReqData)
    end, function()
        ToggleBlowtorch(false)
        CoreName.Functions.Notify("Failed!", "error")
    end)
end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:isPlayingAnimation')
AddEventHandler('qb-expandableVehicleTrunk:Client:isPlayingAnimation', function()
    Wait(50)
    local ped = PlayerPedId()
    if IsPedActiveInScenario(ped) == false then
        TriggerEvent("qb-expandableVehicleTrunk:Client:OpenUI")
    else
        CoreName.Functions.Notify("Wait for upgrade to end!", "error")
    end
end)

RegisterNetEvent('qb-expandableVehicleTrunk:Client:CloseUI')
AddEventHandler('qb-expandableVehicleTrunk:Client:CloseUI', function()
    Wait(50)
    SendNUIMessage({
        action = "close"
    })
end)

function ToggleTablet(toggle)
    local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
    local tabletAnim = "base"
    local tabletProp = "prop_cs_tablet"
    local tabletBone = 60309
    local tabletOffset = vector3(0.03, 0.002, -0.0)
    local tabletRot = vector3(10.0, 160.0, 0.0)
    local playerPed = PlayerPedId()

    if toggle and not tablet then
        tablet = true
        Citizen.CreateThread(function()
            RequestAnimDict(tabletDict)
            while not HasAnimDictLoaded(tabletDict) do
                Citizen.Wait(150)
            end
            RequestModel(tabletProp)
            while not HasModelLoaded(tabletProp) do
                Citizen.Wait(150)
            end
            local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
            local tabletBoneIndex = GetPedBoneIndex(playerPed, tabletBone)
            SetCurrentPedWeapon(playerPed, "weapon_unarmed", true)
            AttachEntityToEntity(tabletObj, playerPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(tabletProp)
            while tablet do
                Citizen.Wait(100)
                if not IsEntityPlayingAnim(playerPed, tabletDict, tabletAnim, 3) then
                    TaskPlayAnim(playerPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                end
            end
            ClearPedSecondaryTask(playerPed)
            Citizen.Wait(450)
            DetachEntity(tabletObj, true, false)
            DeleteEntity(tabletObj)
        end)
    elseif not toggle and tablet then
        tablet = false
    end
end

-- ============================
--     Command
-- ============================

RegisterNetEvent('qb-expandableVehicleTrunk:Client:mechDuty')
AddEventHandler('qb-expandableVehicleTrunk:Client:mechDuty', function()
    TriggerServerEvent("QBCore:ToggleDuty")
end)

