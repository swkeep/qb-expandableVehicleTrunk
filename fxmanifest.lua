fx_version 'bodacious'
games { 'gta5' }

author "Swkeep#7049"

client_scripts { '@PolyZone/client.lua', 'client/functions.lua', 'client/cl_main.lua' }

shared_script { 'config.lua', 'shared/shared.lua' }

server_script { '@oxmysql/lib/MySQL.lua', 'server/sv_main.lua', 'server/sv_functions.lua' }
