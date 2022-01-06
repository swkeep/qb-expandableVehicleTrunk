# keep-carInventoryWeight
Custom server-side cars inventory weight

add in line 690
```lua
    Result = exports.oxmysql:scalarSync('SELECT `maxweight` FROM player_vehicles WHERE plate = ?',
        {other.plate})
    if Result then
        local maxweight_Server = json.decode(Result)
        other.maxweight = maxweight_Server
    end
```