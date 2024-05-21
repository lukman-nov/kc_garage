fx_version 		'adamant'
game 					'gta5'
lua54 				'yes'

name 					'Kucluck Garage V2'
description 	'Advanced Garages for ESX & QB V2'
author 				'Lukman_Nov#5797'
version 			'2.5.1'
license    		'GNU General Public License v3.0'

shared_scripts {
	'@ox_lib/init.lua',
  'locales.lua',
  'shared/config.lua',
  'shared/garages.lua',
  'shared/impounds.lua',
  'locales/*.lua'
}

client_scripts {
	'bridge/**/client.lua',
	'client/main.lua',
	'client/function.lua',
	'client/mainAPI.lua',
	'client/deformation.lua',
	'client/vehicle_names.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'bridge/**/server.lua',
	'server/main.lua',
	'server/update.lua',
}

ui_page "web/index.html"

files {
	"web/assets/*",
	"web/assets/**/*",
	"web/index.html",
	"web/script.js",
	"web/style.css",
}

escrow_ignore {
	'bridge/**/*.lua',
	'client/main.lua',
	'client/function.lua',
	'client/mainAPI.lua',
	'client/vehicle_names.lua',
	'locales/*.lua',
	'server/main.lua',
	'shared/*.lua',
	'function.lua',
}
