# Qb-expandableVehicleTrunk

- Custom server-side vehicle inventory weight

# Working on

- add lock screen
- mini-game

# Installation

## Step 1

- install [swkeep-tablet](https://github.com/swkeep/swkeep-tablet)
- and then import expandableVehicleTrunk.sql into your SQL

## Step 2

- inside "qb-inventory/client/main.lua".
- try to find this code "if CurrentVehicle then -- Trunk".
- and then you should be abale to see this line >> "local vehicleClass = GetVehicleClass(curVeh)"
- then add code below

```lua
local plate = QBCore.Functions.GetPlate(curVeh)
```

## Step 3

- now try to find this code

```lua
local other = {
    maxweight = maxweight,
    slots = slots,
}
```

- and then add "plate = plate" to table

```lua
local other = {
    maxweight = maxweight,
    slots = slots,
    plate = plate
}
```

## Step 4

- inside "qb-inventory/server/main.lua".
- try to find this functions >> "inventory:server:OpenInventory".

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
replace ( ADD CODE HERE ) with code below
    local result = exports.oxmysql:scalarSync('SELECT `actualCarryCapacity` FROM player_vehicles WHERE plate = ?',
        {other.plate})
    if result then
        other.maxweight = json.decode(result)
    end
```

# Previews

![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/noVehicle.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/Vehicle.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/plate.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/upgradeList.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/Payment.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/animation.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/before.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/test/.github/images/afterUpgrade.png)
