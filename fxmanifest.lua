fx_version 	'adamant'
game 				'gta5'
lua54 			'yes'

name 				'kc_garage'
description 'Garages for ESX Legacy'
author 			'Lukman_Nov#5797'
repository 	'https://github.com/lukman-nov/kc_garage'
version 		'2.3.1'
license    	'GNU General Public License v3.0'

shared_scripts {
	'@ox_lib/init.lua',
  'locale.lua',
  'locales/*.lua',
  'config.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua'
}

dependencies { 
  '/server:5848',
  '/gameBuild:1868',
  '/onesync',
}