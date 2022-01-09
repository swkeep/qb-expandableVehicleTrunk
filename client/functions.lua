local DEBUG = Config.DEBUG
local CoreName = exports['qb-core']:GetCoreObject()

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

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)

    SetEntityHeading(entity1, heading)
end

function ToggleBlowtorch(toggle)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = CoreName.Functions.GetClosestVehicle(pos)
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
        while IsPedInAnyVehicle(ped) do
            TaskLeaveVehicle(ped --[[ Ped ]] , veh --[[ Vehicle ]] , 1 --[[ integer ]] )
            Wait(750)
        end
    end
    Wait(500)
    makeEntityFaceEntity(ped, veh)
    if toggle then
        SetCurrentPedWeapon(ped, "weapon_unarmed", true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
    elseif not toggle then
        ClearPedTasks(ped)
    end
end
