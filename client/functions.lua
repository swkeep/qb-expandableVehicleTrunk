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
    end
    makeEntityFaceEntity(ped, veh)
    if toggle then
        SetCurrentPedWeapon(ped, "weapon_unarmed", true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
    elseif not toggle then
        ClearPedTasks(ped)
    end
end

function ToggleTablet(toggle)
    local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
    local tabletAnim = "base"
    local tabletProp = "prop_cs_tablet"
    local tabletBone = 60309
    local tabletOffset = vector3(0.03, 0.002, -0.0)
    local tabletRot = vector3(10.0, 160.0, 0.0)
    local playerPed = PlayerPedId()
    local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(playerPed, tabletBone)

    if toggle then
        RequestAnimDict(tabletDict)
        while not HasAnimDictLoaded(tabletDict) do
            Citizen.Wait(150)
        end
        RequestModel(tabletProp)
        while not HasModelLoaded(tabletProp) do
            Citizen.Wait(150)
        end
        SetCurrentPedWeapon(playerPed, "weapon_unarmed", true)
        AttachEntityToEntity(tabletObj, playerPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z,
            tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(tabletProp)
        playerPed = PlayerPedId()
        if not IsEntityPlayingAnim(playerPed, tabletDict, tabletAnim, 3) then
            TaskPlayAnim(playerPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
        end
    elseif not toggle then
        ClearPedSecondaryTask(playerPed)
        Citizen.Wait(450)
        DetachEntity(tabletObj, true, false)
        DeleteEntity(tabletObj)
    end
end
