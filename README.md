# qb-expandableVehicleTrunk

Custom server-side vehicle inventory weight

# desc

\*\*IMPORTANT: Project is under development and not fully functional so bugs should be expected.

\*IMPORTANT: Config file doesn't contain vehicles and their classes. (it should be added manually)

# Commands

- admin only commands:
  -- /testOpen open Ui without tablet in hand
  -- /mechDuty toggle duty
  -- /addTablet and one tablet to player inventory

# working on

- Vehicle upgrade history (multiuser)
- Payment history (multiuser)
- move notifications to tablet
- add locksceen (if needed)
- mini game
- tax
- remove upgrades and recive refund
- add vehicles to config file

# Config

```lua
    [7] = { -- table keys are vehicles classes https://docs.fivem.net/natives/?_0x29439776AAA00A62
        ["sultanrsv8"] = {
            minCarryCapacity = 10000,
            maxCarryCapacity = 100000,
            upgrades = 4,
            stepPrice = 1000
        }
    },
```

\*\* [index] index is vehicle class you need to add them and set capacity manually

# instalation

- import expandableVehicleTrunk.sql
- find "if CurrentVehicle then -- Trunk" in qb-inventory/client/main.lua
- then add code below aftter first line ("local vehicleClass = GetVehicleClass(curVeh)")

```lua
local plate = QBCore.Functions.GetPlate(curVeh)
```

- now find code below and edit it as

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

- open "inventory:server:OpenInventory" in qb-inventory/server/main.lua and find code below

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

- replace ( ADD CODE HERE ) with code below

```lua
    local result = exports.oxmysql:scalarSync('SELECT `actualCarryCapacity` FROM player_vehicles WHERE plate = ?',
        {other.plate})
    if result then
        other.maxweight = json.decode(result)
    end
```

# Previews

![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/noVehicle.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/Vehicle.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/plate.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/upgradeList.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/Payment.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/animation.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/before.png)
![tablet](https://raw.githubusercontent.com/swkeep/qb-expandableVehicleTrunk/main/.github/images/afterUpgrade.png)
