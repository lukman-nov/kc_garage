ESX = exports["es_extended"]:getSharedObject()
local vehiclesCache = {}

ESX.RegisterServerCallback('kc_garage:getVehiclesInParking', function(source, cb, stored)
  local src = source
	local xPlayer  = ESX.GetPlayerFromId(src)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = @stored',
	{
		['@identifier'] = xPlayer.identifier,
		['@stored'] = stored
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			local currenType = result[i].type

			if currenType == 'helicopter' or currenType == 'airplane' then
				currenType = 'aircraft'
			end
			
			if result[i].parking then
				table.insert(vehicles, {
					vehicle 	= json.decode(result[i].vehicle),
					plate 		= result[i].plate,
					parking   = result[i].parking,
					vehType 	= currenType
				})
			end
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('kc_garage:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@plate']     		= plate
	}, function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('kc_garage:getPlayersGroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	for i = 1, #Config.GroupAdminList, 1 do
		if xPlayer.getGroup() == Config.GroupAdminList[i] then
			cb(true)
		end
	end
end)

ESX.RegisterServerCallback('kc_garage:checkMoney', function(source, cb, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.getMoney())
end)

RegisterNetEvent('kc_garage:removeMoney')
AddEventHandler('kc_garage:removeMoney', function(amount)

	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	xPlayer.removeAccountMoney(Config.PayIn, amount)
end)

RegisterServerEvent('kc_garage:updateOwnedVehicle')
AddEventHandler('kc_garage:updateOwnedVehicle', function(stored, parking, vehicleProps)
	local src = source
	local xPlayer  = ESX.GetPlayerFromId(src)

	MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `parking` = @parking, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
	{
		['@identifier'] = xPlayer.identifier,
		['@vehicle'] 	= json.encode(vehicleProps),
		['@plate'] 		= vehicleProps.plate,
		['@stored']     = stored,
		['@parking']    = parking,
	})
end)

RegisterNetEvent('kc_garage:updateVehicleProperties', function(plate, vehicleProps)
	MySQL.update('UPDATE owned_vehicles SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@vehicle'] 	= json.encode(vehicleProps),
		['@plate'] 		= vehicleProps.plate,
	})
end)

RegisterServerEvent('kc_garage:impoundVehicle')
AddEventHandler('kc_garage:impoundVehicle', function(currentParking, _type)
	MySQL.update('UPDATE owned_vehicles SET `stored` = 0, `parking` = @parking WHERE `type`=@type AND parking IS NULL',
	{
		['@type'] = _type,
		['@parking'] = currentParking
	})
end)

RegisterServerEvent('kc_garage:jobsImpoundVehicle')
AddEventHandler('kc_garage:jobsImpoundVehicle', function(currentParking, plate, vehicleProps, identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	local job = xPlayer.getJob()

	MySQL.update('UPDATE owned_vehicles SET `stored` = 0, `parking` = @parking, `vehicle` = @vehicle WHERE `plate` = @plate ',
	{
		['@plate'] = plate,
		['@parking'] = currentParking,
		['@vehicle'] 	= json.encode(vehicleProps),
	}, function(rowsUpdated)
		if rowsUpdated then
			MySQL.query('SELECT owner FROM `owned_vehicles` WHERE `plate` = @plate', 
			{
				['@plate'] = plate
			}, function(result)
				if result[1] then
					local xTarget = ESX.GetPlayerFromIdentifier(result[1].owner)
					TriggerClientEvent('kc_garage:notify', xTarget.source, 'inform', _K('target_impounded', plate, job.label))
				end
			end)
		end
		TriggerClientEvent('kc_garage:notify', xPlayer.source, 'inform', _K('player_impounded'))
	end)
end)

RegisterNetEvent('kc_garage:requestVehicleLock')
AddEventHandler('kc_garage:requestVehicleLock', function(netId, lockstatus, plate)
  local src = source
	local xPlayer  = ESX.GetPlayerFromId(src)
  if not plate then return end

	MySQL.query('SELECT owner, peopleWithKeys as count FROM owned_vehicles WHERE `plate` = @plate', 
	{
		['@plate'] = plate
	}, function (result)
		if result and result[1] then
			vehiclesCache[plate] = {}
			vehiclesCache[plate][result[1].owner] = true
			local otherKeys = json.decode(result[1].peopleWithKeys)
			if not otherKeys then otherKeys = {} end
			for k, v in pairs(otherKeys) do
				vehiclesCache[plate][v] = true
			end
			TriggerEvent('kc_garage:vehicleLock', xPlayer.source, netId, lockstatus, plate)
		end
	end)
end)

RegisterNetEvent('kc_garage:vehicleLock')
AddEventHandler('kc_garage:vehicleLock', function(src, netId, lockstatus, plate)
	local xPlayer = ESX.GetPlayerFromId(src)
  local vehicle = NetworkGetEntityFromNetworkId(netId)

  if vehiclesCache[plate] and (vehiclesCache[plate][xPlayer.identifier] or vehiclesCache[plate][xPlayer.job.name]) then
    SetVehicleDoorsLocked(vehicle, lockstatus == 2 and 1 or 2)
    TriggerClientEvent('kc_garage:vehLockedEffect', xPlayer.source, netId, lockstatus ~= 2)
  end

end)

RegisterNetEvent('kc_garage:giveKeyToPerson')
AddEventHandler('kc_garage:giveKeyToPerson', function(target, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local owner = MySQL.Sync.fetchScalar('SELECT owner FROM owned_vehicles WHERE plate = "'..plate..'"')
	if owner == xPlayer.identifier then
    local xTarget = ESX.GetPlayerFromId(target)
    local peopleWithKeys = MySQL.Sync.fetchScalar('SELECT peopleWithKeys FROM owned_vehicles WHERE plate = "'..plate..'"')
    local keysTable = json.decode(peopleWithKeys)
    keysTable[xTarget.identifier] = true
		
		MySQL.Async.execute('UPDATE owned_vehicles SET peopleWithKeys = @peopleWithKeys WHERE plate = @plate', {
			['@peopleWithKeys'] = json.encode(keysTable),
			['@plate'] = plate
		}, function(rowsUpdated)
			if rowsUpdated > 0 then
				TriggerClientEvent('kc_garage:notify', xTarget.source, 'inform', _K('received_keys', plate))
				TriggerClientEvent('kc_garage:notify', xPlayer.source, 'inform', _K('given_keys', plate))
			end
		end)
		
		if vehiclesCache[plate] then
			vehiclesCache[plate][xTarget.identifier] = true
		end
	
	else
		TriggerClientEvent('kc_garage:notify', xPlayer.source, 'error', _K('not_yours_veh'))
	end
end)

RegisterNetEvent('kc_garage:filterVehiclesType')
AddEventHandler('kc_garage:filterVehiclesType', function()
	MySQL.query('SELECT `type`, `vehicle` FROM `owned_vehicles` WHERE parking IS NULL',{ 
		}, function(result)
			if result then
				for i = 1, #result, 1 do
					local tempType = result[i].type
					if tempType == 'helicopter' or tempType == 'airplane'then
						tempType = 'aircraft'
					end
					for impoundName, impound in pairs(Config.Impound) do
						if tempType == impound.Type then
							if impound.IsDefaultImpound then
								TriggerEvent('kc_garage:impoundVehicle', impoundName, result[i].type)
							end
						end
					end
				end
			end
		end)
end)

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
	TriggerEvent('kc_garage:filterVehiclesType')
end)

if Config.AutoDelVeh then
	function DeleteVehTaskCoroutine()
		TriggerClientEvent('kc_garage:deleteVehicle', -1)
	end

	for i = 1, #Config.DeleteVehiclesAt, 1 do
		TriggerEvent('cron:runAt', Config.DeleteVehiclesAt[i].h, Config.DeleteVehiclesAt[i].m, DeleteVehTaskCoroutine)
	end
end