local CoreName = exports['qb-core']:GetCoreObject()

function PrepareVehicleData()
    local DATA = {}
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    else
        veh = CoreName.Functions.GetClosestVehicle(pos)
    end
    DATA.plate = CoreName.Functions.GetPlate(veh)
    DATA.class = GetVehicleClass(veh)
    DATA.vehpos = GetEntityCoords(veh)
    DATA.namelbl = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    DATA.isVehicleStopped = IsVehicleStopped(veh)
    DATA.isEngineRunning = GetIsVehicleEngineRunning(veh)
    DATA.vehicleEstimatedMaxSpeed = GetVehicleEstimatedMaxSpeed(veh)
    if veh ~= nil and #(pos - DATA.vehpos) < 2.5 and IsPauseMenuActive() == false then
        -- data is ready to for server
    elseif IsPauseMenuActive() == 1 then
        DATA.error = {}
        DATA.error = {
            error = 'open_menu',
        }
        return DATA.error
    else
        DATA.error = {}
        DATA.error = {
            error = 'not_near_vehicle',
        }
        return DATA.error
    end
    return DATA
end

exports("PrepareVehicleData", PrepareVehicleData)

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)

    SetEntityHeading(entity1, heading)
end

function ToggleBlowtorch(toggle)
    local weaponHash = GetHashKey("WEAPON_UNARMED")
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = CoreName.Functions.GetClosestVehicle(pos)
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
        while IsPedInAnyVehicle(ped) do
            TaskLeaveVehicle(ped, veh, 1)
            Wait(750)
        end
    end
    Wait(500)
    makeEntityFaceEntity(ped, veh)
    if toggle then
        SetCurrentPedWeapon(ped, weaponHash, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
    elseif not toggle then
        SetCurrentPedWeapon(ped, weaponHash, true)
        ClearPedTasks(ped)
    end
end
