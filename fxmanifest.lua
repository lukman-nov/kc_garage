fx_version 'adamant'

game 'gta5'

author 'Lukman_Nov#5797'
description 'KC Garage'
repository 'https://github.com/lukman-nov/kc_garage'

lua54 'yes'
version '2.2.0'

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
