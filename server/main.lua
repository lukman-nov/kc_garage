local vehiclesCache = {}

RegisterServerEvent('kc_garage:updateOwnedVehicle')
AddEventHandler('kc_garage:updateOwnedVehicle', function(stored, parking, Impound, vehicleProps)
	local src = source
	local xPlayer  = ESX.GetPlayerFromId(src)
	MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `parking` = @parking, `pound` = @Impound, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
	{
		['@identifier'] = xPlayer.identifier,
		['@vehicle'] 	= json.encode(vehicleProps),
		['@plate'] 		= vehicleProps.plate,
		['@stored']     = stored,
		['@parking']    = parking,
		['@Impound']    	= Impound
	})
end)

ESX.RegisterServerCallback('kc_garage:getVehiclesInParking', function(source, cb)
  local src = source
	local xPlayer  = ESX.GetPlayerFromId(src)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = 1',
	{
		['@identifier'] 	= xPlayer.identifier
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate,
        parking   = result[i].parking
			})
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

RegisterNetEvent('kc_garage:RequestVehicleLock', function(netId, lockstatus, plate)
  local vehicle = NetworkGetEntityFromNetworkId(netId)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not plate then return end
  if not vehiclesCache[plate] then
		local result = MySQL.Sync.fetchAll('SELECT owner, peopleWithKeys FROM owned_vehicles WHERE plate = "'..plate..'"')
		if result and result[1] then
			vehiclesCache[plate] = {}
			vehiclesCache[plate][result[1].owner] = true
			local otherKeys = json.decode(result[1].peopleWithKeys)
			if not otherKeys then otherKeys = {} end
			for k, v in pairs(otherKeys) do
				vehiclesCache[plate][v] = true
			end
		end
  end
  if vehiclesCache[plate] and (vehiclesCache[plate][xPlayer.identifier] or vehiclesCache[plate][xPlayer.job.name]) then
    SetVehicleDoorsLocked(vehicle, lockstatus == 2 and 1 or 2)
    TriggerClientEvent('kc_garage:CarLockedEffect', xPlayer.source, netId, lockstatus ~= 2)
  else
    TriggerClientEvent('kc_garage:notify', xPlayer.source, 'inform', _U('no_keys'))
  end
end)

RegisterNetEvent('kc_garage:GiveKeyToPerson', function(plate, target)
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
				TriggerClientEvent('kc_garage:notify', xTarget.source, 'inform', _U('received_keys', plate))
				TriggerClientEvent('kc_garage:notify', xPlayer.source, 'inform', _U('gave_keys', plate))
			end
		end)
		
		if vehiclesCache[plate] then
			vehiclesCache[plate][xTarget.identifier] = true
		end
	
	else
		TriggerClientEvent('kc_garage:notify', xPlayer.source, 'inform', _U('not_yours_vehicle'))
	end
end)

exports('resetPlate', function(plate)
	vehiclesCache[plate] = nil
end)

exports('giveTempKeys', function(plate, identifier, timeout)
	if not vehiclesCache[plate] then
		vehiclesCache[plate] = {}
	end
	
	vehiclesCache[plate][identifier] = true
	if timeout then
		Citizen.SetTimeout(timeout, function()
			if vehiclesCache[plate] and vehiclesCache[plate][identifier] then
				vehiclesCache[plate][identifier] = nil
      end
  	end)
  end
end)