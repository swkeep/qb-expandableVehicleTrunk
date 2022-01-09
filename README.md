# qb-expandableVehicleTrunk
Custom server-side vehicle inventory weight

# desc
**IMPORTANT: Project is on development and not fully functional so bugs should be expected.

# instalation
* import expandableVehicleTrunk.sql
* find "if CurrentVehicle ~= nil then -- Trunk" in qb-inventory/client/main.lua
* then add code below aftter first line ("local vehicleClass = GetVehicleClass(curVeh)")

```lua
local plate = QBCore.Functions.GetPlate(curVeh)
```

* now find code below and edit it as

```lua
local other = {
    maxweight = maxweight,
    slots = slots,
}
```

```lua
local other = {
    maxweight = maxweight,
    slots = slots,
    plate = plate
}
```

* open "inventory:server:OpenInventory" in qb-inventory/server/main.lua and find code below

```lua
if Trunks[id].isOpen then
    local Target = QBCore.Functions.GetPlayer(Trunks[id].isOpen)
    if Target ~= nil then
        TriggerClientEvent('inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
    else
        Trunks[id].isOpen = false
    end
    end
end

    ( ADD CODE HERE )

secondInv.name = "trunk-"..id
secondInv.label = "Trunk-"..id
```

* replace ( ADD CODE HERE ) with code below

```lua
    Result = exports.oxmysql:scalarSync('SELECT `maxweight` FROM player_vehicles WHERE plate = ?',
        {other.plate})
    if Result then
        local maxweight_Server = json.decode(Result)
        other.maxweight = maxweight_Server
    end
```


# Previews
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/1.jpg)
![tabletInfo](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/2.jpg)
![TabletUpgrade](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/3.jpg)
![tabletC](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/4.jpg)
![upgradeAnimation](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/5.jpg)
![currentmaxweight](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/6.jpg)
![UpgradeCurrentmaxweight](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/7.jpg)

