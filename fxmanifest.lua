fx_version 'bodacious'
games {'gta5'}

author "Swkeep#7049"

client_scripts {'@PolyZone/client.lua', 'client/functions.lua', 'client/cl_main.lua'}

shared_script {'config.lua', 'shared/shared.lua', "@qb-core/shared.lua"}

server_script {'server/sv_main.lua','server/sv_functions.lua'}

files {'html/*', 'html/css/*', 'html/css/font/*', 'html/js/*', 'html/img/*'}

ui_page('html/index.html')
