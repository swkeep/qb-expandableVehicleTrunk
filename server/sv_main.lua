local CoreName = exports['qb-core']:GetCoreObject()

-- ============================
--       EVENTS
-- ============================
local animalsEnity = {} -- prevent players to slaughter twice

RegisterServerEvent("cad-hunting:server:AddItem")
AddEventHandler("cad-hunting:server:AddItem", function(data, entity)
    local _source = source
    local Player = CoreName.Functions.GetPlayer(_source)

end)

-- ============================
--   SELLING
-- ============================
RegisterServerEvent('cad-hunting:server:sellmeat')
AddEventHandler('cad-hunting:server:sellmeat', function()
    Wait(10)
end)

CoreName.Functions.CreateUseableItem("huntingbait", function(source, item)
    TriggerClientEvent('keep-hunting:client:useBait', source)
end)

RegisterServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
AddEventHandler('keep-hunting:server:removeBaitFromPlayerInventory', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("spawnanimal", "Spawn Animals (Admin Only)",
    {{"model", "Animal Model"}, {"was_llegal", "area of hunt true/false"}}, false, function(source, args)
        TriggerClientEvent('cad-hunting:client:spawnanim', source, args[1], args[2])
    end, 'admin')
