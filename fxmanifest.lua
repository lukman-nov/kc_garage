fx_version 'adamant'

game 'gta5'

author 'Lukman_Nov#5797'
description 'KC Garage'
repository 'https://github.com/lukman-nov/kc_garage'

lua54 'yes'
version '1.0.1'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
}
client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}
dependencies {
	'es_extended',
	'ox_lib'
}